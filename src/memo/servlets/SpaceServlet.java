package memo.servlets;

import memo.misc.Utils;
import memo.share.EncryptedFile;
import memo.share.FileCollection;
import memo.share.PublicFile;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "SpaceServlet", urlPatterns = {"/space/space"})
public class SpaceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        response.setCharacterEncoding("utf-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credential", "true");
        if ("verify".equals(type)){
            String name = request.getParameter("name");
            PublicFile file = Utils.getFile(name);
            if (file == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_FILE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            else if (!(file instanceof EncryptedFile)){
                Utils.Result result = new Utils.Result(Utils.ERROR_NOT_ENCRYPTED);
                response.setContentType("application/json");
                response.setContentType(result.toJson());
                return;
            }
            EncryptedFile encryptedFile = (EncryptedFile)file;
            byte[] password = Utils.decodeBase64(request.getParameter("password"));
            Map<String, Object> map = new HashMap<>();
            map.put("result", encryptedFile.verifyPassword(password));
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("delete".equals(type)){
            String name = request.getParameter("name");
            Utils.deleteFile(name);
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        response.setCharacterEncoding("utf-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credential", "true");
        if ("list".equals(type)){
            FileCollection files = Utils.listFiles();
            Map<String, Object> map = new HashMap<>();
            map.put("data", files.toJson());
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("get".equals(type)){
            String name = request.getParameter("name");
            PublicFile file = Utils.getFile(name);
            if (file == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_FILE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else{
                Map<String, Object> map = new HashMap<>();
                map.put("data", file.toJson());
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
        }
        else if ("decrypt".equals(type)){
            String name = request.getParameter("name");
            String password = request.getParameter("password");
            PublicFile file = Utils.getFile(name);
            if (file == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_FILE);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            else if (!(file instanceof EncryptedFile)){
                Utils.Result result = new Utils.Result(Utils.ERROR_NOT_ENCRYPTED);
                response.setContentType("application/json");
                response.setContentType(result.toJson());
                return;
            }
            EncryptedFile encryptedFile = (EncryptedFile)file;
            byte[] data;
            try {
                data = encryptedFile.decrypt(password);
            } catch (GeneralSecurityException e) {
                e.printStackTrace();
                return;
            }
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=" + name);
            response.getOutputStream().write(data);
        }
        else{
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
        }
    }
}
