package memo.request;

import memo.user.User;
import org.json.JSONObject;
import java.util.Date;
import java.util.Map;

/**
 * The request sent by users.
 */
public abstract class Request {
    /**
     * The category of this request.
     */
    protected RequestCategory category;
    /**
     * The time when the user sent the request.
     */
    protected Date date;
    /**
     * The user who requested.
     */
    protected User user;
    /**
     * Initializes a new instance of the {@code Request} class.
     * @param user The user who requested.
     */
    protected Request(User user, Date date){
        this.user = user;
        this.date = date;
    }
    /**
     * Fulfill the request.
     */
    public abstract void fulfill() throws RequestFulfillException;

    /**
     * Serialize this request as string.
     * @return The string format.
     */
    public abstract Map<String, String> serialize();

    /**
     * Dispatch a request.
     * @param category The category of the request.
     * @param user The user who requested.
     * @param date The date when requested.
     * @param data The serialized data.
     * @return The dispatched request.
     */
    public static Request dispatchRequest(RequestCategory category, User user, Date date, Map<String, String> data){
        if (category == RequestCategory.DELETE_ALBUM) {
            return DeleteAlbumRequest.fromSerializedData(user, date, data);
        }
        else if (category == RequestCategory.DELETE_ARTICLE){
            return DeleteArticleRequest.fromSerializedData(user, date, data);
        }
        return null;
    }

    /**
     * The category of this request.
     */
    public RequestCategory getCategory() {
        return category;
    }

    /**
     * The time when the user sent the request.
     */
    public Date getDate() {
        return date;
    }

    /**
     * The user who requested.
     */
    public User getUser() {
        return user;
    }

    /**
     * Converts this instance to json.
     * @return A json object.
     */
    public Object toJson() {
        JSONObject json = new JSONObject();
        json.put("date", date.getTime());
        json.put("user", user.getUserName());
        json.put("type", category.getValue());
        return json;
    }

    /**
     * Test whether this request is similar to another request.
     * @param other Another request.
     * @return Whether this request is similar to ths provided request.
     */
    public abstract boolean isSimilarTo(Request other);
}
