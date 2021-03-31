package memo.servlets;

import memo.misc.Carousel;
import memo.misc.Domain;
import memo.misc.Option;
import memo.misc.Utils;
import memo.request.*;
import memo.resource.ResourceGroup;
import memo.user.*;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet(name = "MiscServlet", urlPatterns = {"/misc"})
public class MiscServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setCharacterEncoding("utf-8");
        HttpSession session = request.getSession();
        User user = Utils.getSessionUser(session);
        AccessLevel level = user == null ? AccessLevel.NONE : user.getLevel();
        /*if (level.getValue() < AccessLevel.MEMBER.getValue()){
            response.setContentType("application/json");
            response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
            return;
        }*/
        String type = request.getParameter("type");
        if ("create_request".equals(type)){
            if (!Objects.requireNonNull(Utils.getOption("EnableRequest")).getValue()){
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
                return;
            }
            short category = Short.parseShort(request.getParameter("category"));
            RequestCategory rc = RequestCategory.fromValue(category);
            Request req = null;
            if (rc == RequestCategory.DELETE_ALBUM) {
                String name = request.getParameter("name");
                String reason = request.getParameter("reason");
                req = new DeleteAlbumRequest(user, new Date(), name, reason);
            }
            else if (rc == RequestCategory.DELETE_ARTICLE) {
                String idString = request.getParameter("id");
                UUID id = UUID.fromString(idString);
                String reason = request.getParameter("reason");
                req = new DeleteArticleRequest(user, new Date(), id, reason);
            }
            if (req != null){
                try {
                    Utils.addRequest(req);
                } catch (SQLException throwable) {
                    throwable.printStackTrace();
                    return;
                }
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            }
        }
        else if ("delete_request".equals(type)){
            int id = Integer.parseInt(request.getParameter("id"));
            try {
                if (level != AccessLevel.ADMIN && !Utils.listRequests().get(id).getUser().equals(user)){
                    response.setContentType("application/json");
                    response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
                    return;
                }
                Utils.deleteRequest(id);
            } catch (SQLException throwable) {
                throwable.printStackTrace();
                return;
            }
            response.setContentType("application/json");
            response.getWriter().print(new Utils.Result().toJson());
        }
        else {
            /*if (level.getValue() < AccessLevel.ADMIN.getValue()){
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
                return;
            }*/
            if ("fulfill_request".equals(type)) {
                int id = Integer.parseInt(request.getParameter("id"));
                try {
                    Utils.listRequests().fulfill(id);
                } catch (Exception e) {
                    e.printStackTrace();
                    return;
                }
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            } else if ("blacklist_user".equals(type)) {
                String name = request.getParameter("username");
                try {
                    Utils.blacklistUser(name);
                } catch (SQLException e) {
                    e.printStackTrace();
                    return;
                }
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            } else if ("whitelist_user".equals(type)) {
                String name = request.getParameter("username");
                AccessLevel originalLevel;
                try {
                    originalLevel = Utils.whitelistUser(name);
                } catch (SQLException e) {
                    e.printStackTrace();
                    return;
                }
                Map<String, Object> map = new HashMap<>();
                map.put("original", Objects.requireNonNull(originalLevel).getValue());
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            } else if ("put_carousel".equals(type)) {
                String title = request.getParameter("title");
                String desc = request.getParameter("description");
                String fileName = request.getParameter("filename");
                String base64 = request.getParameter("data");
                byte[] image = Utils.decodeBase64(base64);
                Utils.putCarousel(title, desc, fileName, image);
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            } else if ("delete_carousel".equals(type)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Utils.deleteCarousel(id);
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            }
            else if ("put_domain".equals(type)){
                String name = request.getParameter("name");
                String path = request.getParameter("path");
                boolean space = Boolean.parseBoolean(request.getParameter("space"));
                Domain domain = new Domain(name, path, space);
                Utils.addDomain(domain);
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            }
            else if ("delete_domain".equals(type)){
                String name = request.getParameter("name");
                Utils.deleteDomain(name);
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            }
            else if ("toggle_option".equals(type)){
                String name = request.getParameter("name");
                boolean value = Boolean.parseBoolean(request.getParameter("value"));
                Utils.setOption(name, value);
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result().toJson());
            }
            else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setCharacterEncoding("utf-8");
        String type = request.getParameter("type");
        if ("list_carousels".equals(type)) {
            Collection<Carousel> carousels;
            carousels = Utils.listCarousels();
            JSONArray array = new JSONArray(carousels.stream().map(Carousel::toJson).toArray());
            Map<String, Object> map = new HashMap<>();
            map.put("data", array);
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
            return;
        }
        else if ("image_carousel".equals(type)) {
            int id = Integer.parseInt(request.getParameter("id"));
            Carousel carousel;
            carousel = Utils.getCarouselById(id);
            if (carousel == null) {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_CAROUSEL);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            } else {
                File image = carousel.getImage();
                response.setContentType("application/octet-stream");
                response.setHeader("Content-Disposition", "attachment; filename=" + image.getName());
                response.getOutputStream().write(
                        Utils.readBinaryFile(image.getAbsolutePath())
                );
            }
            return;
        }
        HttpSession session = request.getSession();
        User user = Utils.getSessionUser(session);
        AccessLevel level = user == null ? AccessLevel.NONE : user.getLevel();
        /*if (level.getValue() < AccessLevel.MEMBER.getValue()){
            response.setContentType("application/json");
            response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
            return;
        }*/
        if ("list_requests".equals(type)){
            /*if (level.getValue() < AccessLevel.ADMIN.getValue()){
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
                return;
            }*/
            IdRequestCollection requests;
            try {
                requests = Utils.listRequests();
            } catch (SQLException throwable) {
                throwable.printStackTrace();
                return;
            }
            Map<String, Object> map = new HashMap<>();
            map.put("data", requests.toJson());
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("list_records".equals(type)){
            UserRecords records;
            try {
                records = Utils.getRecords(user);
            } catch (SQLException throwable) {
                throwable.printStackTrace();
                return;
            }
            Objects.requireNonNull(records);
            Map<String, Object> map = new HashMap<>();
            map.put("records", records.toJson());
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else {
            /*if (level.getValue() < AccessLevel.ADMIN.getValue()){
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
                return;
            }*/
            if ("list_users".equals(type)) {
                Collection<User> users;
                try {
                    users = Utils.listUsers();
                } catch (SQLException e) {
                    e.printStackTrace();
                    return;
                }
                JSONArray array = new JSONArray(users.stream().map(u -> {
                    JSONObject json = new JSONObject();
                    json.put("username", u.getUserName());
                    json.put("level", u.getLevel().getValue());
                    return json;
                }).toArray());
                Map<String, Object> map = new HashMap<>();
                map.put("data", array);
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else if ("list_domains".equals(type)) {
                JSONArray array = new JSONArray(Utils.listDomains().stream().map(Domain::toJson).toArray());
                Map<String, Object> map = new HashMap<>();
                map.put("data", array);
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else if ("list_options".equals(type)){
                JSONArray array = new JSONArray(Utils.listOptions().stream().map(Option::toJson).toArray());
                Map<String, Object> map = new HashMap<>();
                map.put("data", array);
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else if ("list_resources".equals(type)){
                JSONArray array = new JSONArray(Utils.listResourceManagers().stream().map(m -> {
                    JSONObject json = new JSONObject();
                    json.put("name", m.getName());
                    json.put("groups", new JSONArray(m.listGroups().stream().map(ResourceGroup::toJson).toArray()));
                    return json;
                }).toArray());
                Map<String, Object> map = new HashMap<>();
                map.put("data", array);
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
            }
        }
    }
}
