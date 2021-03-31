package memo.request;

import memo.misc.Utils;
import memo.user.User;
import org.json.JSONObject;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class DeleteArticleRequest extends Request {

    /**
     * The id of the article.
     */
    public final UUID id;
    /**
     * The reason to delete.
     */
    public final String reason;

    /**
     * Initializes a new instance of the {@code DeleteArticleRequest} class.
     * @param user The user who requested.
     * @param date The date when the user requested.
     * @param id The id of the article.
     * @param reason The reason to delete.
     */
    public DeleteArticleRequest(User user, Date date, UUID id, String reason){
        super(user, date);
        category = RequestCategory.DELETE_ARTICLE;
        this.id = id;
        this.reason = reason;
    }
    /**
     * Fulfill the request.
     */
    @Override
    public void fulfill() {
        Utils.deleteArticle(id);
    }

    /**
     * Serialize this request as string.
     * @return The string format.
     */
    @Override
    public Map<String, String> serialize() {
        Map<String, String> map = new HashMap<>();
        map.put("id", id.toString());
        map.put("reason", reason);
        return map;
    }


    /**
     * Converts this instance to json.
     * @return A json object.
     */
    @Override
    public Object toJson() {
        JSONObject json = (JSONObject) super.toJson();
        json.put("id", id.toString());
        json.put("reason", reason);
        return json;
    }

    /**
     * Gets the id of the article.
     * @return The id of the article.
     */
    public UUID getId(){
        return id;
    }

    /**
     * Generate a request from serialized data.
     * @param user The user who requested.
     * @param date The date when requested.
     * @param data Serialized data.
     * @return An instance generated from the data.
     */
    public static DeleteArticleRequest fromSerializedData(User user, Date date, Map<String, String> data){
        JSONObject json = new JSONObject(data);
        return new DeleteArticleRequest(user, date, UUID.fromString(json.getString("id")), json.getString("reason"));
    }

    /**
     * Test whether this request is similar to another request.
     * @param other Another request.
     * @return Whether this request is similar to ths provided request.
     */
    @Override
    public boolean isSimilarTo(Request other) {
        if (other == this) return true;
        if (other.getCategory() != RequestCategory.DELETE_ARTICLE) return false;
        DeleteArticleRequest dar = (DeleteArticleRequest)other;
        return id.equals(dar.id);
    }
}
