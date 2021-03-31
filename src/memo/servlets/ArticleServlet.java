package memo.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.*;
import memo.misc.Utils;
import memo.article.Article;
import memo.article.ArticleProperties;
import memo.user.AccessLevel;
import memo.user.User;
import org.json.JSONArray;
import org.xml.sax.SAXException;

@WebServlet(name = "ArticleServlet", urlPatterns = { "/article/article" })
public class ArticleServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setCharacterEncoding("utf-8");
        HttpSession session = request.getSession();
        User user = Utils.getSessionUser(session);
        AccessLevel level = user == null ? AccessLevel.NONE : user.getLevel();
        if (level.getValue() < AccessLevel.MEMBER.getValue()){
            response.setContentType("application/json");
            response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
            return;
        }
        String type = request.getParameter("type");
        if ("create".equals(type)){
            if (!Objects.requireNonNull(Utils.getOption("EnableUpload")).getValue()){
                Utils.Result result = new Utils.Result(Utils.ERROR_ACCESS_DENIED);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            String title = request.getParameter("title");
            UUID id = Utils.generateUUID();
            ArticleProperties properties = ArticleProperties.create(id, title, user, new Date());
            Utils.createArticle(properties);
            Utils.updateArticleCache();
            Map<String, Object> map = new HashMap<>();
            map.put("id", id.toString());
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("put".equals(type)){
            String idString = request.getParameter("id");
            UUID id = UUID.fromString(idString);
            Article article = Utils.getArticleById(id);
            if (article == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ARTICLE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            String base64 = request.getParameter("data");
            String extension = request.getParameter("extension");
            byte[] imageData = Utils.decodeBase64(base64);
            article.addImage(extension, imageData);
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("content".equals(type)){
            String idString = request.getParameter("id");
            UUID id = UUID.fromString(idString);
            Article article = Utils.getArticleById(id);
            if (article == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ARTICLE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            String content = request.getParameter("content");
            article.putContent(content);
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("delete".equals(type)){
            String idString = request.getParameter("id");
            UUID id = UUID.fromString(idString);
            Utils.deleteArticle(id);
            Utils.updateArticleCache();
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setCharacterEncoding("utf-8");
        String type = request.getParameter("type");
        if ("latest".equals(type)){
            Optional<Article> optionalArticle = Utils.listArticles().stream()
                    .min((a, b) -> -Long.signum(a.getProperties().getDate().getTime() - b.getProperties().getDate().getTime()));
            if (optionalArticle.isPresent()){
                Article article = optionalArticle.get();
                Map<String, Object> map = new HashMap<>();
                map.put("article", article.getProperties().toJson());
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ARTICLE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            return;
        }
        else if ("index".equals(type)){
            String idString = request.getParameter("id");
            UUID id = UUID.fromString(idString);
            Article article = Utils.getArticleById(id);
            if (article == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ARTICLE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                int index = Integer.parseInt(request.getParameter("index"));
                if (index < 0 || index >= article.getProperties().getImageCount()) {
                    Utils.Result result = new Utils.Result(Utils.ERROR_INVALID_INDEX);
                    response.setContentType("application/json");
                    response.getWriter().print(result.toJson());
                    return;
                }
                File image = article.getImage(index);
                Objects.requireNonNull(image);
                response.sendRedirect("/article/files/" + idString + "/" + image.getName());
            }
            return;
        }
        HttpSession session = request.getSession();
        User user = Utils.getSessionUser(session);
        AccessLevel level = user == null ? AccessLevel.NONE : user.getLevel();
        if (level.getValue() < AccessLevel.GUEST.getValue()){
            response.setContentType("application/json");
            response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
            return;
        }
        if ("list".equals(type)){
            Map<String, Object> map = new HashMap<>();
            map.put("data", new JSONArray(Utils.listArticles().stream().map(a -> a.getProperties().toJson()).toArray()));
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("get".equals(type)){
            String idString = request.getParameter("id");
            UUID id = UUID.fromString(idString);
            Article article = Utils.getArticleById(id);
            if (article == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ARTICLE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                Map<String, Object> map = new HashMap<>();
                map.put("article", article.getProperties().toJson());
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
        }
        else if ("content".equals(type)){
            String idString = request.getParameter("id");
            UUID id = UUID.fromString(idString);
            Article article = Utils.getArticleById(id);
            if (article == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ARTICLE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                response.setContentType("application/xml");
                response.getWriter().print(article.getContent());
            }
        }
        else if ("download".equals(type)){
            String idString = request.getParameter("id");
            UUID id = UUID.fromString(idString);
            Article article = Utils.getArticleById(id);
            if (article == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ARTICLE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                String format = request.getParameter("format");
                if ("xml".equals(format)) {
                    response.setContentType("application/octet-stream");
                    response.setHeader("Content-Disposition", "attachment; filename=article.xml");
                    response.getOutputStream().write(article.getContent().getBytes(StandardCharsets.UTF_8));
                }
                else if ("pdf".equals(format)) {
                    File pdf;
                    try {
                        pdf = article.getPDF();
                    } catch (SAXException e) {
                        e.printStackTrace();
                        return;
                    }
                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=" + pdf.getName());
                    response.getOutputStream().write(
                            Utils.readBinaryFile(pdf.getAbsolutePath())
                    );
                }
                else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'format'.");
                }
            }
        }
        else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
        }
    }
}
