package memo.misc;

import memo.Config;
import memo.album.Album;
import memo.album.AlbumProperties;
import memo.article.Article;
import memo.article.ArticleProperties;
import memo.request.IdRequestCollection;
import memo.request.Request;
import memo.request.RequestCategory;
import memo.resource.Resource;
import memo.resource.ResourceGroup;
import memo.resource.ResourceManager;
import memo.user.*;
import memo.share.*;
import org.json.JSONObject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

import javax.servlet.http.HttpSession;
import java.io.*;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Utility members and methods.
 */
public final class Utils {
    // error codes
    public static final int ERROR_SUCCESS = 0;
    public static final int ERROR_INCORRECT_USER = 1;
    public static final int ERROR_ALREADY_LOGGED = 2;
    public static final int ERROR_NOT_LOGGED_YET = 3;
    public static final int ERROR_MISSING_ALBUM = 4;
    public static final int ERROR_INVALID_INDEX = 5;
    public static final int ERROR_ALBUM_ALREADY_EXISTS = 6;
    public static final int ERROR_FILENAME_USED = 7;
    public static final int ERROR_ACCESS_DENIED = 8;
    public static final int ERROR_ALREADY_LOCKED = 9;
    public static final int ERROR_UNMATCHED_LOCKER = 10;
    public static final int ERROR_MISSING_ARTICLE = 11;
    public static final int ERROR_MISSING_CAROUSEL = 12;
    public static final int ERROR_MISSING_FILE = 13;
    public static final int ERROR_NOT_ENCRYPTED = 14;
    public static final int ERROR_FILE_INTEGRITY_FAIL = 15;
    public static final int ERROR_FILE_ALREADY_EXISTS = 16;
    /**
     * The page levels.
     */
    public static final Map<String, AccessLevel> pageLevels = new HashMap<>(){{
        put("/album", AccessLevel.GUEST);
        put("/album/index.jsp", AccessLevel.GUEST);
        put("/album/detail.jsp", AccessLevel.GUEST);
        put("/album/create.jsp", AccessLevel.MEMBER);
        put("/album/modify.jsp", AccessLevel.MEMBER);
        put("/article", AccessLevel.GUEST);
        put("/article/index.jsp", AccessLevel.GUEST);
        put("/article/detail.jsp", AccessLevel.GUEST);
        put("/article/post.jsp", AccessLevel.MEMBER);
        put("/admin.jsp", AccessLevel.ADMIN);
        put("/space/upload.jsp", AccessLevel.MEMBER);
    }};
    // static members
    /**
     * The SQL connection to MySQL.
     */
    static Connection sqlConnection = null;
    /**
     * The redis connection.
     */
    static JedisPool jedisPool = null;
    /**
     * The cache albums.
     */
    static Vector<Album> albumCache = null;
    /**
     * The cache articles.
     */
    static Vector<Article> articleCache = null;
    /**
     * The cache carousels.
     */
    static Vector<Carousel> carouselCache = null;
    /**
     * The cache domains.
     */
    static Vector<Domain> domainCache = null;
    /**
     * The cache options.
     */
    static Vector<Option> optionCache = null;
    /**
     * The requests.
     */
    static IdRequestCollection requests = null;
    /**
     * The cache files.
     */
    static FileCollection fileCache = null;
    /**
     * The global resource manager.
     */
    static ResourceManager globalResourceManager = new ResourceManager("global");
    /**
     * The online users.
     */
    public static final OnlineUserCollection onlineUser = new OnlineUserCollection();

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            sqlConnection = DriverManager.getConnection(
                    "jdbc:mysql://"
                            + Config.MYSQL_HOST + ":" + Config.MYSQL_PORT
                            + "/" + Config.MYSQL_DATABASE
                            + "?serverTimezone=UTC&autoReconnect=true",
                    Config.MYSQL_USER, Config.MYSQL_PASSWORD);
            Runtime.getRuntime().addShutdownHook(new Thread(new SQLShutdownHook()));
            updateRequests();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(0);
        }
    }

    /**
     * Prevent user from initiating this class.
     */
    private Utils() { }

    /**
     * The sql shutdown hook.
     */
    private static class SQLShutdownHook implements Runnable {

        /**
         * Shutdown the sql connection.
         */
        @Override
        public void run() {
            try {
                sqlConnection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Represents a result responded to the user.
     */
    public static class Result {
        /**
         * A boolean value indicating whether the operation succeeded.
         */
        public boolean success = true;
        /**
         * A int value indicating the error message of the operation.
         * Must be {@code null} if {@code success} is {@code true}.
         */
        public int error = ERROR_SUCCESS;
        /**
         * An object value representing the result of the operation.
         * Must be {@code null} is {@code success} is {@code false}.
         */
        public Map<String, Object> data = null;
        /**
         * Initializes a new instance of the {@code Result} class.
         * {@code success} is implicitly {@code true}.
         */
        public Result() {}

        /**
         * Initializes a new instance of the {@code Result} class.
         * {@code success} is implicitly {@code false}.
         * @param error The code describing the error.
         */
        public Result(int error){
            success = false;
            this.error = error;
        }

        /**
         * Initializes a new instance of the {@code Result} class.
         * {@code success} is implicitly {@code true}.
         * @param data The result of the operation.
         */
        public Result(Map<String, Object> data){
            this.data = data;
        }

        /**
         * Gets a string representation of this result.
         * @return A json representation.
         */
        public String toJson(){
            JSONObject json;
            if (success){
                json = new JSONObject(data);
            }
            else {
                json = new JSONObject();
                json.put("error", error);
            }
            json.put("success", success);
            return json.toString();
        }
    }

    /**
     * Read the contents of a file.
     * @param fileName The name of the file.
     * @return The string contents of the file.
     * @throws IOException If the file does not exist.
     */
    public static String readFile(String fileName)
            throws IOException {
        FileReader file = new FileReader(fileName, StandardCharsets.UTF_8);
        BufferedReader reader = new BufferedReader(file);
        Optional<String> content = reader.lines().reduce((a, b) -> a+"\n"+b);
        reader.close();
        file.close();
        return content.orElse("");
    }

    /**
     * Write the contents to a file.
     * @param fileName The file name to write to.
     * @param content The content to write in.
     * @throws IOException If an I/O error occurs.
     */
    public static void writeFile(String fileName, String content)
        throws IOException {
        FileWriter file = new FileWriter(fileName, StandardCharsets.UTF_8, false);
        file.write(content);
        file.close();
    }

    /**
     * Read the contents of a file.
     * @param fileName The name of the file.
     * @return The string contents of the file.
     * @throws IOException If the file does not exist.
     */
    public static byte[] readBinaryFile(String fileName)
            throws IOException {
        FileInputStream stream = new FileInputStream(fileName);
        byte[] result = stream.readAllBytes();
        stream.close();
        return result;
    }

    /**
     * Reads chunks from specific file.
     * @param fileName The name of the file.
     * @param lengths The lengths to read.
     * @return The read chunks.
     * @throws IOException I/O error.
     */
    public static byte[][] readBinaryChunks(String fileName, int ...lengths)
            throws IOException {
        FileInputStream stream = new FileInputStream(fileName);
        ArrayList<byte[]> result = new ArrayList<>();
        for (int length: lengths){
            result.add(stream.readNBytes(length));
        }
        result.add(stream.readAllBytes());
        return result.toArray(byte[][]::new);
    }

    /**
     * Write binary contents to a file.
     * @param fileName The file name to write to.
     * @param content The content to write in.
     * @throws IOException If an I/O error occurs.
     */
    public static void writeBinaryFile(String fileName, byte[] content)
            throws IOException {
        FileOutputStream stream = new FileOutputStream(fileName, false);
        stream.write(content);
        stream.close();
    }

    /**
     * Write byte chunks to a file.
     * @param fileName The name of the file to write to.
     * @param chunks The chunks to write in.
     */
    public static void writeBinaryChunks(String fileName, byte[] ...chunks)
            throws IOException{
        FileOutputStream stream = new FileOutputStream(fileName, false);
        for (byte[] chunk : chunks){
            stream.write(chunk);
        }
        stream.close();
    }

    /**
     * Gets a user by name.
     * @param name The name of the user.
     * @return The user with specific name, or {@code null} if user does not exist.
     * @throws SQLException SQL error.
     */
    public static User getUserByName(String name)
        throws SQLException {
        PreparedStatement ps = sqlConnection.prepareStatement("SELECT * FROM users WHERE username = ?");
        ps.setString(1, name);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) return null;
        String userName = rs.getString("username");
        String passwordBase64 = rs.getString("password");
        AccessLevel level = AccessLevel.fromValue((short)rs.getInt("level"));
        int id = rs.getInt("user_id");
        byte[] password = decodeBase64(passwordBase64);
        return new User(id, userName, password, level);
    }

    /**
     * Gets a user by id.
     * @param userId The id of the user.
     * @return The user with specific name, or {@code null} if user does not exist.
     * @throws SQLException SQL error.
     */
    public static User getUserById(int userId)
        throws SQLException {
        PreparedStatement ps = sqlConnection.prepareStatement("SELECT * FROM users WHERE user_id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) return null;
        String userName = rs.getString("username");
        String passwordBase64 = rs.getString("password");
        AccessLevel level = AccessLevel.fromValue((short)rs.getInt("level"));
        int id = rs.getInt("user_id");
        byte[] password = decodeBase64(passwordBase64);
        return new User(id, userName, password, level);
    }

    /**
     * Verifies the user's password with the given sha-digested password.
     * @param name The user's name.
     * @param passwordSha The provided sha256 digested password.
     * @return {@code true} if the user exists and password matches, else {@code false}.
     * @throws SQLException SQL error.
     */
    public static boolean verifyUser(String name, byte[] passwordSha)
        throws SQLException{
        User user = getUserByName(name);
        if (user == null) return false;
        return Arrays.equals(user.getPassword(), passwordSha);
    }

    /**
     * Changes the password of a user.
     * @param user The user.
     * @param password The new password.
     * @throws SQLException SQL error.
     */
    public static void changePassword(User user, byte[] password)
            throws SQLException {
        if (user == null) return;
        user.setPassword(password);
        PreparedStatement p = sqlConnection.prepareStatement("UPDATE users SET password = ? WHERE user_id = ?");
        p.setString(1, encodeBase64(password));
        p.setInt(2, user.getUserId());
        p.executeUpdate();
        p.close();
    }

    /**
     * Initialize a session with specified user.
     * @param session Session to initialize.
     * @param user The user.
     * @return {@code ERROR_SUCCESS} if success, else error code.
     */
    public static int initializeSession(HttpSession session, User user){
        if (session.getAttribute("user") == null){
            if (onlineUser.isOnline(user)){
                HttpSession oldSession = onlineUser.getSessionOf(user);
                finalizeSession(Objects.requireNonNull(oldSession));
                onlineUser.offline(user);
            }
            session.setAttribute("user", user);
            onlineUser.online(new UserSessionPair(user, session));
            return ERROR_SUCCESS;
        }
        else return ERROR_ALREADY_LOGGED;
    }

    /**
     * Gets a user by its remote address.
     * @param address The remote address.
     * @return The user if present, otherwise {@code null}.
     */
    public static User getUserByAddress(String address){
        return onlineUser.getUserByAddress(address);
    }

    /**
     * Check whether the session is initialized with a user.
     * @param session The session to check.
     * @return Whether the session is initialized.
     */
    public static boolean isSessionInitialized(HttpSession session){
        return session.getAttribute("user") != null;
    }

    /**
     * Log off the session.
     * @param session The session to log off.
     */
    public static void finalizeSession(HttpSession session){
        session.removeAttribute("user");
    }

    /**
     * Gets the logged user of the specific session.
     * @param session The session.
     * @return The user logged.
     */
    public static User getSessionUser(HttpSession session){
        return (User)session.getAttribute("user");
    }

    /**
     * Gets the hex representation of the byte array.
     * @param s The byte array to convert.
     * @return The converted hex string.
     */
    public static String convertToHex(byte[] s) {
        StringBuilder sb = new StringBuilder();
        for (byte aByte : s) {
            String hex = Integer.toHexString(aByte & 0xFF);
            if (hex.length() < 2) {
                sb.append(0);
            }
            sb.append(hex);
        }
        return sb.toString();
    }

    /**
     * Converts hex string to byte array.
     * @param hex The hex string to convert.
     * @return The converted byte array.
     */
    public static byte[] fromHex(String hex){
        int hexLength = hex.length();
        if (hexLength % 2 != 0){
            hexLength++;
            hex = "0" + hex;
        }
        ByteBuffer buffer = ByteBuffer.allocate(hexLength/2);
        for (int i = 0; i<hexLength/2; i++){
            String digit = hex.substring(i*2, i*2+2);
            buffer.put(Integer.valueOf(digit, 16).byteValue());
        }
        return buffer.array();
    }

    /**
     * Encodes a byte array to base64 string.
     * @param s The array to encode.
     * @return A base64 string.
     */
    public static String encodeBase64(byte[] s){
        return Base64.getEncoder().encodeToString(s);
    }

    /**
     * Decodes a base64 string to byte array.
     * @param s The base64 string to decode.
     * @return A byte array.
     */
    public static byte[] decodeBase64(String s){
        return Base64.getDecoder().decode(s.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Gets a page level from a relative path.
     * @param relativePath The path to get.
     * @return The level of the page.
     */
    public static AccessLevel getPageLevel(String relativePath){
        if (!relativePath.startsWith("/")) relativePath = "/" + relativePath;
        if (relativePath.endsWith("/")) relativePath = relativePath.substring(0, relativePath.length() - 2);
        relativePath = relativePath.toLowerCase();
        return pageLevels.getOrDefault(relativePath, AccessLevel.NONE);
    }

    /**
     * Lists the albums in the system.
     * @return The albums in the system.
     */
    public static Collection<Album> listAlbums(){
        if (albumCache == null)
            updateAlbumCache();
        return albumCache;
    }

    /**
     * Update the album cache.
     */
    public static void updateAlbumCache(){
        File albumDir = new File(Config.ALBUM_PATH);
        ArrayList<Album> albums = new ArrayList<>();
        for (File dir : Objects.requireNonNull(albumDir.listFiles())){
            try{
                String configPath = new File(dir, "album.json").getAbsolutePath();
                AlbumProperties properties = AlbumProperties.loadProperties(configPath);
                albums.add(new Album(dir.getAbsolutePath(), properties));
            }
            catch (Throwable ignored){
            }
        }
        albumCache = new Vector<>(albums);
    }

    /**
     * Gets an album by its name.
     * @param name The name of the album.
     * @return The album with specific name if exists, otherwise {@code null}.
     */
    public static Album getAlbumByName(String name){
        for (Album album : listAlbums()){
            if (album.getProperties().getName().equals(name)) return album;
        }
        return null;
    }

    /**
     * Check whether an album with specific name exists.
     * @param name The name to check.
     * @return Whether it exists.
     */
    public static boolean albumExists(String name){
        return listAlbums().stream().anyMatch(a -> a.getProperties().getName().equals(name));
    }

    /**
     * Gets the tag usage of the albums.
     * @param tag The tag name to count.
     * @return The tag usage.
     */
    public static int getTagUsage(String tag){
        return (int)listAlbums().stream().filter(a -> a.getProperties().getTags().tagExists(tag)).count();
    }

    /**
     * Creates an album from specific properties.
     * @param properties The properties.
     * @throws IOException If an I/O error occurs.
     */
    public static void createAlbum(AlbumProperties properties) throws IOException {
        UUID uuid = UUID.nameUUIDFromBytes(properties.getName().getBytes(StandardCharsets.UTF_8));
        File dir = new File(Config.ALBUM_PATH, uuid.toString());
        if (dir.mkdir()){
            properties.saveProperties(new File(dir, "album.json").getAbsolutePath());
        }
    }

    /**
     * Deletes an album, including removing it from the file system.
     * @param name The name of the album.
     */
    public static void deleteAlbum(String name) {
        Album album = getAlbumByName(name);
        if (album == null) return;
        File dir = new File(album.getPath());
        for (File f : Objects.requireNonNull(dir.listFiles())){
            if (!f.delete()) return;
        }
        dir.delete();
        updateAlbumCache();
    }

    /**
     * Locks an album.
     * @param name The name of the album.
     * @param user The user as locker.
     * @return Whether the album was successfully locked.
     */
    public static boolean lockAlbum(String name, User user){
        Album album = getAlbumByName(name);
        if (album == null) return false;
        return album.getLock().lock(user);
    }

    /**
     * Unlocks an album.
     * @param name The name of the album.
     * @param user The user as locker.
     * @return Whether the album was successfully unlocked.
     */
    public static boolean unlockAlbum(String name, User user){
        Album album = getAlbumByName(name);
        if (album == null) return false;
        return album.getLock().unlock(user);
    }

    /**
     * Check whether an album is locked.
     * @param name The name of the album.
     * @return Whether the album is locked.
     */
    public static boolean isAlbumLocked(String name){
        Album album = getAlbumByName(name);
        return album != null && album.getLock().isLocked();
    }

    /**
     * Unlock all albums locked by specific user.
     * @param user The specified user.
     */
    public static void unlockAllAlbums(User user){
        for (Album album: listAlbums()){
            if (album.getLock().isLocked() && album.getLock().getLocker().equals(user))
                album.getLock().unlock(user);
        }
    }

    /**
     * Adds a request to the database.
     * @param request The request to add.
     * @throws SQLException SQL error.
     */
    public static void addRequest(Request request) throws SQLException {
        int id = increaseIdFor("requests");
        Resource requestResource = new Resource();
        requestResource.setField("req-id", String.valueOf(id));
        requestResource.setField("user", String.valueOf(request.getUser().getUserId()));
        requestResource.setField("date", String.valueOf(request.getDate().getTime()));
        request.serialize().forEach(requestResource::setField);
        ResourceGroup requestsGroup = globalResourceManager.findGroup("requests");
        Objects.requireNonNull(requestsGroup);
        requestsGroup.putResource(requestResource);
        requestsGroup.flush();
        if (requests == null) updateRequests();
        else requests.put(id, request);
    }

    /**
     * Deletes a request.
     * @param id The id of the request.
     * @throws SQLException SQL error.
     */
    public static void deleteRequest(int id) throws SQLException {
        ResourceGroup requestsGroup = globalResourceManager.findGroup("requests");
        Objects.requireNonNull(requestsGroup);
        Resource request = requestsGroup.asStream()
                .filter(r -> Integer.parseInt(r.getField("req-id")) == id)
                .findFirst()
                .orElseThrow();
        requestsGroup.removeResource(request);
        requestsGroup.flush();
        if (requests == null) updateRequests();
        else requests.remove(id);
    }

    /**
     * List the requests.
     * @return The requests listed.
     * @throws SQLException SQL error.
     */
    public static IdRequestCollection listRequests() throws SQLException {
        if (requests == null) updateRequests();
        return requests;
    }

    /**
     * Update the list of requests.
     * @throws SQLException SQL error.
     */
    public static void updateRequests() throws SQLException {
        requests = new IdRequestCollection();
        ResourceGroup requestsGroup = globalResourceManager.findGroup("requests");
        Objects.requireNonNull(requestsGroup);
        for (Resource request: requestsGroup.asList()){
            RequestCategory category = RequestCategory.fromValue(Short.parseShort(request.getField("category")));
            java.util.Date date = new java.util.Date(Long.parseLong(request.getField("date")));
            User user = getUserById(Integer.parseInt(request.getField("user")));
            int id = Integer.parseInt(request.getField("req-id"));
            requests.put(id, Request.dispatchRequest(category, user, date, request.getMapping()));
        }
    }

    /**
     * Gets the article list.
     * @return The article list.
     */
    public static Collection<Article> listArticles(){
        if (articleCache == null) updateArticleCache();
        return articleCache;
    }

    /**
     * Updates the articles cache.
     */
    public static void updateArticleCache(){
        File articleDir = new File(Config.ARTICLE_PATH);
        ArrayList<Article> articles = new ArrayList<>();
        for (File dir : Objects.requireNonNull(articleDir.listFiles())){
            try{
                String configPath = new File(dir, "article.json").getAbsolutePath();
                ArticleProperties properties = ArticleProperties.loadProperties(configPath);
                articles.add(new Article(dir.getAbsolutePath(), properties));
            }
            catch (Throwable ignored){
            }
        }
        articleCache = new Vector<>(articles);
    }

    /**
     * Creates an article from specific properties.
     * @param properties The properties.
     * @throws IOException If an I/O error occurs.
     */
    public static void createArticle(ArticleProperties properties) throws IOException{
        UUID uuid = properties.getId();
        File dir = new File(Config.ARTICLE_PATH, uuid.toString());
        if (dir.mkdir()){
            properties.saveProperties(new File(dir, "article.json").getAbsolutePath());
        }
    }

    /**
     * Gets the user's records by user name.
     * @param user The user.
     * @return The records of the user.
     * @throws SQLException SQL error.
     */
    public static UserRecords getRecords(User user) throws SQLException {
        if (user == null) return null;
        IdRequestCollection requests = listRequests().filterUser(user);
        Collection<Article> articles = listArticles().stream().filter(a -> a.getProperties().getAuthor().equals(user)).collect(Collectors.toList());
        return new UserRecords(user, articles, requests);
    }

    /**
     * Generate a random uuid.
     * @return A random uuid.
     */
    public static UUID generateUUID(){
        return UUID.randomUUID();
    }

    /**
     * Gets an article by its id.
     * @param id The id of the article.
     * @return The article if present, else {@code null}.
     */
    public static Article getArticleById(UUID id){
        for (Article article : listArticles()){
            if (article.getProperties().getId().equals(id)) return article;
        }
        return null;
    }

    /**
     * Deletes an article by its id.
     * @param id The id of the article.
     */
    public static void deleteArticle(UUID id) {
        Article article = getArticleById(id);
        if (article == null) return;
        File dir = new File(article.getPath());
        for (File f : Objects.requireNonNull(dir.listFiles())){
            if (!f.delete()) return;
        }
        dir.delete();
        updateArticleCache();
    }

    /**
     * Increases the reading amount of an article.
     * @param id The id of the article.
     * @throws IOException I/O error.
     */
    public static void increaseAmount(UUID id) throws IOException {
        Article article = getArticleById(id);
        if (article == null) return;
        article.getProperties().increaseAmount();
        article.getProperties().saveProperties(new File(article.getPath(), "article.json").getAbsolutePath());
    }

    /**
     * Updates the carousel cache.
     */
    public static void updateCarouselCache() {
        ArrayList<Carousel> carousels = new ArrayList<>();
        ResourceGroup carouselGroup = globalResourceManager.findGroup("carousels");
        Objects.requireNonNull(carouselGroup);
        for (Resource carousel: carouselGroup.asList()){
            int id = Integer.parseInt(carousel.getField("id"));
            String title = carousel.getField("title");
            String desc = carousel.getField("desc");
            String file = carousel.getField("file");
            carousels.add(new Carousel(id, title, desc, file));
        }
        carouselCache = new Vector<>(carousels);
    }

    /**
     * Lists the carousels.
     * @return A list of carousels.
     */
    public static Collection<Carousel> listCarousels() {
        if (carouselCache == null) updateCarouselCache();
        return carouselCache;
    }

    /**
     * Gets a carousel by its id.
     * @param id The id of the carousel.
     * @return The carousel if present, else {@code null}.
     */
    public static Carousel getCarouselById(int id) {
        for (Carousel carousel : listCarousels()){
            if (carousel.getId() == id) return carousel;
        }
        return null;
    }

    /**
     * Deletes a carousel from the file system.
     * @param id The id of the carousel.
     */
    public static void deleteCarousel(int id) {
        Carousel carousel = getCarouselById(id);
        if (carousel == null) return;
        carousel.getImage().delete();
        ResourceGroup carouselGroup = globalResourceManager.findGroup("carousels");
        Objects.requireNonNull(carouselGroup);
        Resource carouselResource = carouselGroup.asStream()
                .filter(r -> Integer.parseInt(r.getField("id")) == id)
                .findFirst()
                .orElse(null);
        if (carouselResource == null) return;
        carouselGroup.removeResource(carouselResource);
        carouselGroup.flush();
        updateCarouselCache();
    }

    /**
     * Gets a list of users.
     * @return A list of users.
     * @throws SQLException SQL error.
     */
    public static Collection<User> listUsers() throws SQLException{
        PreparedStatement ps = sqlConnection.prepareStatement("SELECT * FROM users");
        ResultSet rs = ps.executeQuery();
        ArrayList<User> users = new ArrayList<>();
        while (rs.next()){
            int id = rs.getInt("user_id");
            String userName = rs.getString("username");
            String passwordBase64 = rs.getString("password");
            byte[] password = decodeBase64(passwordBase64);
            AccessLevel level = AccessLevel.fromValue((short)rs.getInt("level"));
            users.add(new User(id, userName, password, level));
        }
        rs.close();
        ps.close();
        return users;
    }

    /**
     * Black-list a user.
     * @param name The user name.
     * @throws SQLException SQL error.
     */
    public static void blacklistUser(String name) throws SQLException {
        User user = getUserByName(name);
        if (user == null || user.getLevel() == AccessLevel.NONE) return;
        AccessLevel original = user.getLevel();
        user.setLevel(AccessLevel.NONE);
        PreparedStatement ps = sqlConnection.prepareStatement("UPDATE users SET level = 0 WHERE user_id = ?");
        ps.setInt(1, user.getUserId());
        ps.executeUpdate();
        ps.close();
        ps = sqlConnection.prepareStatement("INSERT INTO blacklist (user_id, original) VALUES (?, ?)");
        ps.setInt(1, user.getUserId());
        ps.setInt(2, original.getValue());
        ps.executeUpdate();
        ps.close();
        HttpSession session = onlineUser.getSessionOf(user);
        if (session != null)
            getSessionUser(session).setLevel(AccessLevel.NONE);
    }

    /**
     * White-list a user.
     * @param name The user name.
     * @throws SQLException SQL error.
     * @return The original level of the user.
     */
    public static AccessLevel whitelistUser(String name) throws SQLException {
        User user = getUserByName(name);
        if (user == null || user.getLevel() != AccessLevel.NONE) return null;
        PreparedStatement ps = sqlConnection.prepareStatement("SELECT original FROM blacklist WHERE user_id = ?");
        ps.setInt(1, user.getUserId());
        ResultSet rs = ps.executeQuery();
        rs.next();
        AccessLevel original = AccessLevel.fromValue((short)rs.getInt("original"));
        rs.close();
        ps.close();
        Objects.requireNonNull(original);
        user.setLevel(original);
        ps = sqlConnection.prepareStatement("UPDATE users SET level = ? WHERE user_id = ?");
        ps.setInt(1, original.getValue());
        ps.setInt(2, user.getUserId());
        ps.executeUpdate();
        ps.close();
        ps = sqlConnection.prepareStatement("DELETE FROM blacklist WHERE user_id = ?");
        ps.setInt(1, user.getUserId());
        ps.executeUpdate();
        ps.close();
        HttpSession session = onlineUser.getSessionOf(user);
        if (session != null)
            getSessionUser(session).setLevel(original);
        return original;
    }

    /**
     * Creates a new carousel item.
     * @param title The title of the item.
     * @param description The description of the item.
     * @param fileName The file name of the image.
     * @param image The image in bytes.
     * @throws IOException I/O error.error.
     */
    public static void putCarousel(String title, String description, String fileName, byte[] image) throws IOException {
        File imageFile = new File(Config.CAROUSEL_PATH, fileName);
        int extra = 0;
        while (imageFile.exists()){
            imageFile = new File(Config.CAROUSEL_PATH, fileName + "_" + (++extra));
        }
        writeBinaryFile(imageFile.getAbsolutePath(), image);
        ResourceGroup carouselGroup = globalResourceManager.findGroup("carousels");
        Objects.requireNonNull(carouselGroup);
        Resource carousel = new Resource();
        carousel.setField("id", String.valueOf(increaseIdFor("carousels")));
        carousel.setField("title", title);
        carousel.setField("desc", description);
        carousel.setField("file", imageFile.getName());
        carouselGroup.putResource(carousel);
        carouselGroup.flush();
        updateCarouselCache();
    }

    /**
     * Gets a domain's path by its name.
     * @param name The domain name.
     * @return The domain path if exists, otherwise {@code null}.
     */
    public static Domain getDomainByName(String name) {
        for (Domain domain: listDomains()){
            if (domain.getName().equals(name)) return domain;
        }
        return null;
    }

    /**
     * Updates the domain cache.
     */
    public static void updateDomainCache(){
        ArrayList<Domain> domainList = new ArrayList<>();
        ResourceGroup domainGroup = globalResourceManager.findGroup("domains");
        Objects.requireNonNull(domainGroup);
        for (Resource domain: domainGroup.asList()){
            String name = domain.getField("name");
            String path = domain.getField("path");
            boolean space = Boolean.parseBoolean(domain.getField("space"));
            domainList.add(new Domain(name, path, space));
        }
        domainCache = new Vector<>(domainList);
    }

    /**
     * List the domains.
     * @return The domains.
     */
    public static Collection<Domain> listDomains(){
        if (domainCache == null) updateDomainCache();
        return domainCache;
    }

    /**
     * Adds a domain.
     * @param domain The domain to add.
     */
    public static void addDomain(Domain domain){
        ResourceGroup domainGroup = globalResourceManager.findGroup("domains");
        Objects.requireNonNull(domainGroup);
        Resource domainResource = new Resource();
        domainResource.setField("name", domain.getName());
        domainResource.setField("path", domain.getPath());
        domainResource.setField("space", String.valueOf(domain.isSpace()));
        domainGroup.putResource(domainResource);
        domainGroup.flush();
        updateDomainCache();
    }

    /**
     * Deletes a domain by its name.
     * @param name The name of the domain.
     */
    public static void deleteDomain(String name){
        ResourceGroup domainGroup = globalResourceManager.findGroup("domains");
        Objects.requireNonNull(domainGroup);
        Resource domainToDelete = domainGroup.asStream()
                .filter(r -> r.getField("name").equals(name))
                .findFirst()
                .orElse(null);
        if (domainToDelete == null) return;
        domainGroup.removeResource(domainToDelete);
        domainGroup.flush();
        updateDomainCache();
    }
    /**
     * Initializes the jedis pool.
     */
    public static synchronized void initializeJedisPool(){
        jedisPool = new JedisPool(Config.REDIS_HOST, Config.REDIS_PORT);
    }
    /**
     * Gets the redis connection.
     * @return The redis connection.
     */
    public static synchronized Jedis getJedis(){
        if (jedisPool == null) initializeJedisPool();
        return jedisPool.getResource();
    }

    /**
     * Gets a resource manager by its name.
     * @param name The name of the manager.
     * @return The resource manager.
     */
    public static ResourceManager resourceManager(String name){
        ResourceGroup managers = globalResourceManager.findGroup("managers");
        Objects.requireNonNull(managers);
        for (Resource manager: managers.asList()){
            if (manager.getField("name").equals(name) && Boolean.parseBoolean(manager.getField("enabled")))
                return new ResourceManager(name);
        }
        return null;
    }

    /**
     * Lists the resource managers.
     * @return The resource managers.
     */
    public static Collection<ResourceManager> listResourceManagers(){
        ResourceGroup managers = globalResourceManager.findGroup("managers");
        Objects.requireNonNull(managers);
        ArrayList<ResourceManager> managerList = new ArrayList<>();
        for (Resource manager: managers.asList()){
            if (Boolean.parseBoolean(manager.getField("enabled")))
                managerList.add(new ResourceManager(manager.getField("name")));
        }
        return managerList;
    }

    /**
     * Increase the id for specific name.
     * @param idName The name of the counter.
     * @return The increased id.
     */
    public static int increaseIdFor(String idName){
        ResourceGroup ids = Objects.requireNonNull(globalResourceManager.findGroup("ids"));
        Resource carouselId = ids.asStream()
                .filter(r -> r.getField("name").equals(idName))
                .findFirst()
                .orElseThrow();
        int id = Integer.parseInt(carouselId.getField("value"));
        carouselId.setField("value", String.valueOf(++id));
        ids.flush();
        return id;
    }

    /**
     * Updates the option cache.
     */
    public static void updateOptionCache(){
        ResourceGroup options = Objects.requireNonNull(globalResourceManager.findGroup("options"));
        optionCache = options.asStream().map(r -> {
            String name = r.getField("name");
            String desc = r.getField("desc");
            boolean value = Boolean.parseBoolean(r.getField("value"));
            return new Option(name, desc, value);
        }).collect(Collectors.toCollection(Vector::new));
    }

    /**
     * Lists the options.
     * @return The options.
     */
    public static Collection<Option> listOptions(){
        if (optionCache == null) updateOptionCache();
        return optionCache;
    }

    /**
     * Gets an option by its name.
     * @param name The name of the option.
     * @return The option if present, else {@code null}.
     */
    public static Option getOption(String name){
        for (Option option: listOptions()){
            if (option.getName().equals(name)) return option;
        }
        return null;
    }

    /**
     * Sets the value of an option.
     * @param name The name of the option.
     * @param value The value of the option.
     */
    public static void setOption(String name, boolean value){
        ResourceGroup options = Objects.requireNonNull(globalResourceManager.findGroup("options"));
        for (Resource option: options.asList()){
            if (option.getField("name").equals(name)){
                option.setField("value", String.valueOf(value));
            }
        }
        options.flush();
        updateOptionCache();
    }

    /**
     * Updates the files cache.
     */
    public static void updateFileCache(){
        ResourceGroup files = globalResourceManager.findGroup("files");
        Objects.requireNonNull(files);
        FileCollection fileCollection = new FileCollection();
        for (Resource file: files.asList()){
            PublicFile publicFile;
            String name = file.getField("file");
            String tag = file.getField("tag");
            if (Boolean.parseBoolean(file.getField("encrypted"))){
                byte[] password = decodeBase64(file.getField("password"));
                publicFile = new EncryptedFile(name, tag, password);
            }
            else{
                publicFile = new PublicFile(name, tag);
            }
            if (file.getMapping().containsKey("series")){
                String seriesName = file.getField("series");
                Series series = fileCollection.getSeries(seriesName);
                if (series == null){
                    series = new Series(seriesName);
                    series.add(publicFile);
                    fileCollection.addSeries(series);
                }
                else {
                    series.add(publicFile);
                }
            }
            else {
                fileCollection.addSingleFile(publicFile);
            }
        }
        fileCache = fileCollection;
    }

    /**
     * Lists the files.
     * @return The files.
     */
    public static FileCollection listFiles(){
        if (fileCache == null) updateFileCache();
        return fileCache;
    }

    /**
     * Gets a specific file.
     * @param fileName The name of the file.
     * @return The file if present, otherwise {@code null}.
     */
    public static PublicFile getFile(String fileName){
        for (PublicFile file: listFiles().allFiles()){
            if (file.getName().equals(fileName)) return file;
        }
        return null;
    }

    /**
     * Called when a new file is being uploaded.
     * @param fileName The name of the file.
     * @param tag The tag of the file.
     * @param series The series of the file, {@code null} if not present.
     */
    public static void fileUploaded(String fileName, String tag, String series){
        ResourceGroup files = globalResourceManager.findGroup("files");
        Objects.requireNonNull(files);
        Resource file = new Resource();
        file.setField("file", fileName);
        file.setField("tag", tag);
        file.setField("encrypted", "false");
        if (series != null)
            file.setField("series", series);
        files.putResource(file);
        files.flush();
        updateFileCache();
    }

    /**
     * Called when a new file is being uploaded.
     * @param fileName The name of the file.
     * @param tag The tag of the file.
     * @param series The series of the file, {@code null} if not present.
     * @param password The password of the file.
     */
    public static void fileUploaded(String fileName, String tag, String series, byte[] password){
        ResourceGroup files = globalResourceManager.findGroup("files");
        Objects.requireNonNull(files);
        Resource file = new Resource();
        file.setField("file", fileName);
        file.setField("tag", tag);
        file.setField("encrypted", "true");
        file.setField("password", encodeBase64(password));
        if (series != null)
            file.setField("series", series);
        files.putResource(file);
        files.flush();
        updateFileCache();
    }

    /**
     * Creates the sha-256 digest of the data.
     * @param data The data to digest.
     * @return The digested data.
     * @throws NoSuchAlgorithmException If the platform does not support sha-256.
     */
    public static byte[] sha256digest(String data) throws NoSuchAlgorithmException {
        MessageDigest sha = MessageDigest.getInstance("SHA-256");
        return sha.digest(data.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Test whether the file exists.
     * @param fileName The name of the file.
     * @return Whether this file exists.
     */
    public static boolean fileExists(String fileName){
        ResourceGroup files = globalResourceManager.findGroup("files");
        Objects.requireNonNull(files);
        for (Resource file: files.asList()){
            if (file.getField("file").equalsIgnoreCase(fileName)) return true;
        }
        return false;
    }

    /**
     * Deletes a file with specific file name.
     * @param fileName The name of the file.
     */
    public static void deleteFile(String fileName){
        File file = new File(Config.FILES_PATH, fileName);
        file.delete();
        ResourceGroup files = globalResourceManager.findGroup("files");
        Objects.requireNonNull(files);
        Resource resourceToDelete = null;
        for (Resource fRes: files.asList()){
            if (fRes.getField("file").equalsIgnoreCase(fileName)){
                resourceToDelete = fRes;
            }
        }
        if (resourceToDelete != null){
            files.removeResource(resourceToDelete);
            files.flush();
            updateFileCache();
        }
    }
}
