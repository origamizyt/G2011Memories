package memo;

import java.util.List;
import java.util.Arrays;

/**
 * Global configuration class.
 */
public final class Config {
    /**
     * The base path of this server.
     */
    public static final String BASE_PATH = "C:\\Program Files\\Tomcat\\apache-tomcat-9.0.21\\webapps\\ROOT\\";
    //public static final String BASE_PATH = "D:\\Program Files\\Java\\workspace\\G2011Memories\\out\\artifacts\\G2011Memories_war_exploded\\";
    /**
     * The path to the albums.
     */
    public static final String ALBUM_PATH = BASE_PATH + "album\\files";
    /**
     * The path to the articles.
     */
    public static final String ARTICLE_PATH = BASE_PATH + "article\\files";
    /**
     * The path to the public file space.
     */
    public static final String FILES_PATH = BASE_PATH + "space\\files";
    /**
     * The user name of mysql account.
     */
    public static final String MYSQL_USER = "memo_user";
    /**
     * The password of mysql account.
     */
    public static final String MYSQL_PASSWORD = "iZh6QSb9fj";
    /**
     * The host of mysql database.
     */
    public static final String MYSQL_HOST = "127.0.0.1";
    /**
     * The database of mysql.
     */
    public static final String MYSQL_DATABASE = "memo";
    /**
     * The port of mysql database.
     */
    public static final int MYSQL_PORT = 3306;
    /**
     * The host of redis database.
     */
    public static final String REDIS_HOST = "localhost";
    /**
     * The port of redis database.
     */
    public static final int REDIS_PORT = 6379;
    /**
     * The path to asset directory.
     */
    public static final String ASSET_PATH = "C:\\Users\\Administrator\\public\\G2011Memories\\assets";
    /**
     * The path to font.
     */
    public static final String FONT_PATH = ASSET_PATH + "Deng.ttf";
    /**
     * The path to carousel images.
     */
    public static final String CAROUSEL_PATH = "C:\\Users\\Administrator\\public\\G2011Memories\\carousels\\";
    //public static final String CAROUSEL_PATH = "D:\\public\\G2011Memories\\carousels\\";
    /**
     * Contains the domains which does not represent a special domain.
     */
    public static final List<String> NON_SPECIAL_DOMAIN = Arrays.asList("www", "g2011");
}
