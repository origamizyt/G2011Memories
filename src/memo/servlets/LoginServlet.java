package memo.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

import memo.misc.Utils;
import memo.user.User;

import java.util.*;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login/login"})
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setCharacterEncoding("utf-8");
        String type = request.getParameter("type");
        HttpSession session = request.getSession();
        if ("login".equals(type)){
            String username = request.getParameter("username");
            String passwordBase64 = request.getParameter("password");
            byte[] passwordSha = Utils.decodeBase64(passwordBase64);
            try {
                boolean verified = Utils.verifyUser(username, passwordSha);
                Utils.Result result;
                if (verified){
                    User user = Utils.getUserByName(username);
                    session.setAttribute("address", request.getRemoteAddr());
                    int code = Utils.initializeSession(session, user);
                    if (code == Utils.ERROR_SUCCESS) {
                        HashMap<String, Object> map = new HashMap<>();
                        map.put("level", Objects.requireNonNull(user).getLevel().getValue());
                        result = new Utils.Result(map);
                    }
                    else {
                        result = new Utils.Result(code);
                    }
                }
                else{
                    result = new Utils.Result(Utils.ERROR_INCORRECT_USER);
                }
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
        else if ("check".equals(type)){
            HashMap<String, Object> map = new HashMap<>();
            if (Utils.isSessionInitialized(session)){
                map.put("result", true);
                User user = Utils.getSessionUser(session);
                map.put("username", user.getUserName());
                map.put("level", user.getLevel().getValue());
                map.put("guest", User.isGuestUser(user));
            }
            else map.put("result", false);
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("logout".equals(type)){
            if (!Utils.isSessionInitialized(session)){
                Utils.Result result = new Utils.Result(Utils.ERROR_NOT_LOGGED_YET);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            User user = Utils.getSessionUser(session);
            Utils.onlineUser.offline(user);
            Utils.finalizeSession(session);
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("guest".equals(type)) {
            if (!Objects.requireNonNull(Utils.getOption("EnableGuest")).getValue()){
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
                return;
            }
            Utils.initializeSession(session, User.GUEST);
            response.setContentType("application/json");
            response.getWriter().print(new Utils.Result().toJson());
        }
        else if ("change".equals(type)){
            User current = Utils.getSessionUser(session);
            if (current == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_NOT_LOGGED_YET);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            String oldPasswordBase64 = request.getParameter("oldPassword");
            byte[] oldPassword = Utils.decodeBase64(oldPasswordBase64);
            try {
                if (!Arrays.equals(current.getPassword(), oldPassword)){
                    Utils.Result result = new Utils.Result(Utils.ERROR_INCORRECT_USER);
                    response.setContentType("application/json");
                    response.getWriter().print(result.toJson());
                }
                else {
                    String passwordBase64 = request.getParameter("newPassword");
                    byte[] password = Utils.decodeBase64(passwordBase64);
                    Utils.changePassword(current, password);
                    Utils.Result result = new Utils.Result();
                    response.setContentType("application/json");
                    response.getWriter().print(result.toJson());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use POST instead.");
    }
}
