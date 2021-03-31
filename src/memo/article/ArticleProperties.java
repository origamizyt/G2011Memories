package memo.article;

import memo.misc.Utils;
import memo.user.User;
import org.json.JSONObject;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Date;
import java.util.UUID;

/**
 * Represents the properties of an article.
 */
public class ArticleProperties {
    /**
     * The count of images.
     */
    private int imageCount;
    /**
     * The title of this article.
     */
    private String title;
    /**
     * The author of this article.
     */
    private User author;
    /**
     * The upload date.
     */
    private Date date;
    /**
     * The id of this article.
     */
    private UUID id;
    /**
     * The amount of viewing.
     */
    private int viewAmount;

    /**
     * Loads a {@code ArticleProperties} from a json file.
     * @param fileName The name of the file.
     * @return The parsed {@code AlbumProperties}.
     * @throws IOException If the file does not exist.
     * @throws SQLException SQL error.
     */
    public static ArticleProperties loadProperties(String fileName)
            throws IOException, SQLException {
        String content = Utils.readFile(fileName);
        JSONObject json = new JSONObject(content);
        ArticleProperties ap = new ArticleProperties();
        ap.imageCount = json.getInt("image_count");
        ap.title = json.getString("title");
        ap.author = Utils.getUserById(json.getInt("author_id"));
        ap.id = UUID.fromString(json.getString("id"));
        ap.date = new Date(json.getLong("date"));
        ap.viewAmount = json.getInt("amount");
        return ap;
    }

    /**
     * Save this object to a .json file.
     * @param fileName The file name to save.
     * @throws IOException If an I/O error occurs.
     */
    public void saveProperties(String fileName)
            throws IOException {
        Utils.writeFile(fileName, toJsonInternal().toString(2));
    }

    /**
     * Gets the title of this article.
     * @return The title of this article.
     */
    public String getTitle(){
        return title;
    }

    /**
     * The count of images in this article.
     * @return The count of images;
     */
    public int getImageCount(){
        return imageCount;
    }

    /**
     * Increases the image count of this article by 1.
     */
    public void increaseImageCount(){
        imageCount++;
    }

    /**
     * Gets the date when this article was posted.
     * @return The date when this article was posted.
     */
    public Date getDate(){
        return date;
    }

    /**
     * Converts this object to json format.
     * @return Json representation of this object.
     */
    public Object toJson() {
        JSONObject json = new JSONObject();
        json.put("image_count", imageCount);
        json.put("title", title);
        json.put("author", author.getUserName());
        json.put("id", id.toString());
        json.put("date", date.getTime());
        json.put("amount", viewAmount);
        return json;
    }

    /**
     * Gets the author of this article.
     * @return The author of this article.
     */
    public User getAuthor(){
        return author;
    }

    /**
     * Gets the id of this article.
     * @return The unique id.
     */
    public UUID getId(){
        return id;
    }

    /**
     * Gets a JSON representation of this object.
     * @return A JSON object.
     */
    protected JSONObject toJsonInternal(){
        JSONObject json = new JSONObject();
        json.put("image_count", imageCount);
        json.put("title", title);
        json.put("author_id", author.getUserId());
        json.put("id", id.toString());
        json.put("date", date.getTime());
        json.put("amount", viewAmount);
        return json;
    }

    /**
     * Increases the amount of reading by 1.
     */
    public void increaseAmount(){
        viewAmount++;
    }

    /**
     * Creates an instance of the {@code ArticleProperties} class.
     * @param id The id of this article.
     * @param title The title of this article.
     * @param author The author of this article.
     * @param date The date of this article.
     * @return The created instance.
     */
    public static ArticleProperties create(UUID id, String title, User author, Date date){
        ArticleProperties ap = new ArticleProperties();
        ap.id = id;
        ap.title = title;
        ap.date = date;
        ap.viewAmount = 0;
        ap.imageCount = 0;
        ap.author = author;
        return ap;
    }
}
