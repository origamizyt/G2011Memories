package memo.servlets;

import memo.album.Album;
import memo.album.AlbumProperties;
import memo.misc.Utils;
import memo.user.AccessLevel;
import memo.user.User;
import org.json.JSONArray;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

@WebServlet(name = "AlbumServlet", urlPatterns = {"/album/album"})
public class AlbumServlet extends HttpServlet {
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
            String name = request.getParameter("name");
            if (!Objects.requireNonNull(Utils.getOption("EnableUpload")).getValue()){
                Utils.Result result = new Utils.Result(Utils.ERROR_ACCESS_DENIED);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            if (Utils.albumExists(name)){
                Utils.Result result = new Utils.Result(Utils.ERROR_ALBUM_ALREADY_EXISTS);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            String[] tags = request.getParameter("tags").split(",");
            long date = Long.parseLong(request.getParameter("date"));
            AlbumProperties ap = AlbumProperties.create(name, tags, date);
            Utils.createAlbum(ap);
            Utils.updateAlbumCache();
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("put".equals(type)) {
            String name = request.getParameter("name");
            if (!Utils.albumExists(name)) {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            Album album = Objects.requireNonNull(Utils.getAlbumByName(name));
            String fileName = request.getParameter("filename");
            if (album.isFileNameUsed(fileName)){
                Utils.Result result = new Utils.Result(Utils.ERROR_FILENAME_USED);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            String base64 = request.getParameter("data");
            byte[] imageData = Utils.decodeBase64(base64);
            int index = album.addImage(fileName, imageData);
            Map<String, Object> map = new HashMap<>();
            map.put("index", index);
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().write(result.toJson());
        }
        else if ("delete".equals(type)){
            if (level.getValue() < AccessLevel.ADMIN.getValue()){
                response.setContentType("application/json");
                response.getWriter().print(new Utils.Result(Utils.ERROR_ACCESS_DENIED).toJson());
                return;
            }
            String name = request.getParameter("name");
            if (!Utils.albumExists(name)) {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            Utils.deleteAlbum(name);
            Utils.updateAlbumCache();
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().write(result.toJson());
        }
        else if ("pop".equals(type)){
            if (!Objects.requireNonNull(Utils.getOption("CanDeleteAlbumImage")).getValue()){
                Utils.Result result = new Utils.Result(Utils.ERROR_ACCESS_DENIED);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            String name = request.getParameter("name");
            if (!Utils.albumExists(name)) {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            Album album = Objects.requireNonNull(Utils.getAlbumByName(name));
            int index = Integer.parseInt(request.getParameter("index"));
            album.deleteImage(index);
            Utils.Result result = new Utils.Result();
            response.setContentType("application/json");
            response.getWriter().write(result.toJson());
        }
        else if ("lock".equals(type)){
            String name = request.getParameter("name");
            if (!Utils.albumExists(name)){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            if (Utils.lockAlbum(name, user)){
                Utils.Result result = new Utils.Result();
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                Utils.Result result = new Utils.Result(Utils.ERROR_ALREADY_LOCKED);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
        }
        else if ("unlock".equals(type)){
            String name = request.getParameter("name");
            if (!Utils.albumExists(name)){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            if (Utils.unlockAlbum(name, user)){
                Utils.Result result = new Utils.Result();
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                Utils.Result result = new Utils.Result(Utils.ERROR_UNMATCHED_LOCKER);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
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
        if ("latest".equals(type)) {
            Optional<Album> optionalAlbum =
                    Utils.listAlbums().stream().min((a, b) -> -Long.signum(a.getProperties().getDate().getTime() - b.getProperties().getDate().getTime()));
            if (optionalAlbum.isPresent()){
                Album album = optionalAlbum.get();
                Map<String, Object> map = new HashMap<>();
                map.put("album", album.getProperties().toJson());
                Utils.Result result = new Utils.Result(map);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            return;
        }
        else if ("index".equals(type)){
            String name = request.getParameter("name");
            Album album = Utils.getAlbumByName(name);
            if (album == null){
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
            }
            else{
                int index = Integer.parseInt(request.getParameter("index"));
                if (index < 0 || index >= album.getProperties().getCount()){
                    Utils.Result result = new Utils.Result(Utils.ERROR_INVALID_INDEX);
                    response.setContentType("application/json");
                    response.getWriter().print(result.toJson());
                }
                else {
                    File image = Objects.requireNonNull(album.getImage(index));
                    String[] parts = album.getPath().split("\\\\");
                    String id = parts[parts.length-1];
                    response.sendRedirect("/album/files/" + id + "/" + image.getName());
                }
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
            map.put("data", new JSONArray(Utils.listAlbums().stream().map(a -> a.getProperties().toJson()).toArray()));
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("get".equals(type)){
            String name = request.getParameter("name");
            Album album = Utils.getAlbumByName(name);
            Utils.Result result;
            if (album == null){
                result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
            }
            else{
                Map<String, Object> map = new HashMap<>();
                map.put("album", album.getProperties().toJson());
                result = new Utils.Result(map);
            }
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("check".equals(type)){
            String name = request.getParameter("name");
            boolean exists = Utils.albumExists(name);
            Map<String, Object> map = new HashMap<>();
            map.put("result", exists);
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("usage".equals(type)){
            String tag = request.getParameter("tag");
            int count = Utils.getTagUsage(tag);
            Map<String, Object> map = new HashMap<>();
            map.put("result", count);
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("locked".equals(type)){
            String name = request.getParameter("name");
            if (!Utils.albumExists(name)) {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            Map<String, Object> map = new HashMap<>();
            map.put("result", Utils.isAlbumLocked(name)
                    && !Objects.requireNonNull(Utils.getAlbumByName(name)).getLock().getLocker().equals(user));
            Utils.Result result = new Utils.Result(map);
            response.setContentType("application/json");
            response.getWriter().print(result.toJson());
        }
        else if ("download".equals(type)){
            String name = request.getParameter("name");
            if (!Utils.albumExists(name)) {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                response.setContentType("application/json");
                response.getWriter().print(result.toJson());
                return;
            }
            Album album = Objects.requireNonNull(Utils.getAlbumByName(name));
            String indicesString = request.getParameter("indices");
            if (indicesString == null) {
                File zip = album.getZip();
                response.setContentType("application/zip");
                response.setHeader("Content-Disposition", "attachment; filename=album.zip");
                response.getOutputStream().write(
                        Utils.readBinaryFile(zip.getAbsolutePath())
                );
            }
            else {
                String[] indicesArray = indicesString.split(",");
                int[] indices = new int[indicesArray.length];
                for (int i = 0; i < indicesArray.length; i++){
                    indices[i] = Integer.parseInt(indicesArray[i]);
                }
                byte[] zipData = album.partialZip(indices);
                response.setContentType("application/zip");
                response.setHeader("Content-Disposition", "attachment; filename=partial-album.zip");
                response.getOutputStream().write(zipData);
            }
        }
        else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid value for parameter 'type'.");
        }
    }
}
