package memo.request;

import memo.misc.Utils;
import memo.user.User;

import org.json.*;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * A request for deleting the album.
 */
public final class DeleteAlbumRequest extends Request {

    /**
     * The name of the album.
     */
    private final String name;

    /**
     * The reason of deleting this album.
     */
    private final String reason;

    /**
     * Initializes a new instance of the {@code DeleteAlbumRequest} class.
     * @param user The user who requested.
     * @param date The date when the user requested.
     * @param name The name of the album.
     * @param reason The reason to delete.
     */
    public DeleteAlbumRequest(User user, Date date, String name, String reason){
        super(user, date);
        category = RequestCategory.DELETE_ALBUM;
        this.name = name;
        this.reason = reason;
    }
    /**
     * Fulfill the request.
     */
    @Override
    public void fulfill() throws RequestFulfillException {
        Utils.deleteAlbum(name);
    }

    /**
     * Serialize this request as string.
     * @return The string format.
     */
    @Override
    public Map<String, String> serialize() {
        Map<String, String> map = new HashMap<>();
        map.put("name", name);
        map.put("reason", reason);
        return map;
    }

    /**
     * Converts this instance to json.
     * @return A json object.
     */
    @Override
    public Object toJson() {
        JSONObject json = (JSONObject)super.toJson();
        json.put("name", name);
        json.put("reason", reason);
        return json;
    }

    /**
     * Generate a request from serialized data.
     * @param user The user who requested.
     * @param date The date when requested.
     * @param data Serialized data.
     * @return An instance generated from the data.
     */
    public static DeleteAlbumRequest fromSerializedData(User user, Date date, Map<String, String> data){
        JSONObject json = new JSONObject(data);
        return new DeleteAlbumRequest(user, date, json.getString("name"), json.getString("reason"));
    }

    /**
     * Gets the album name of this request.
     * @return The album name.
     */
    public String getName() {
        return name;
    }

    /**
     * Test whether this request is similar to another request.
     * @param other Another request.
     * @return Whether this request is similar to ths provided request.
     */
    @Override
    public boolean isSimilarTo(Request other) {
        if (other == this) return true;
        if (other.getCategory() != RequestCategory.DELETE_ALBUM) return false;
        DeleteAlbumRequest dar = (DeleteAlbumRequest)other;
        return name.equals(dar.name);
    }
}
