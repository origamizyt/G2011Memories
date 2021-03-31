package memo.servlets;

import memo.Config;
import memo.misc.Domain;
import memo.misc.Utils;
import memo.user.AccessLevel;
import memo.user.User;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Objects;

@WebFilter(filterName = "AccessFilter")
public class AccessFilter extends HttpFilter {
    protected void doFilter(HttpServletRequest req, HttpServletResponse resp, FilterChain chain) throws ServletException, IOException {
        resp.setCharacterEncoding("utf-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");
        String requestPath = req.getServletPath();
        String url = req.getRequestURL().toString();
        String domain, rest;
        String[] parts = url.split("/")[2].split("\\.", 2);
        domain = parts[0];
        Domain path = null;
        if (!Config.NON_SPECIAL_DOMAIN.contains(domain)){
            path = Utils.getDomainByName(domain);
            if (path != null) {
                if (path.isSpace()) {
                    requestPath = path.getPath() + requestPath;
                }
                else{
                    requestPath = path.getPath();
                }
                if (parts.length <= 1)
                    rest = parts[0];
                else rest = parts[1];
            }
            else {
                rest = url.split("/")[2];
            }
        }
        else {
            rest = url.split("/")[2];
        }
        User user = Utils.getSessionUser(req.getSession());
        AccessLevel level = user == null ? AccessLevel.NONE : user.getLevel();
        AccessLevel pageLevel = Utils.getPageLevel(requestPath);
        if (pageLevel.getValue() > level.getValue()){
            String query = req.getQueryString();
            String target = query != null ? requestPath + "?" + query : requestPath;
            resp.sendRedirect("http://" + rest + "/login?target=" + URLEncoder.encode(target, StandardCharsets.UTF_8));
            return;
        }
        if (path != null){
            resp.sendRedirect("http://" + rest  + requestPath);
            return;
        }
        chain.doFilter(req, resp);
    }
}
