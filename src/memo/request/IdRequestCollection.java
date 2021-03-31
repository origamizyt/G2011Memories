package memo.request;

import memo.user.User;
import org.json.*;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * A collection of id and requests.
 */
public final class IdRequestCollection extends HashMap<Integer, Request>{
    /**
     * Fulfill the request with specific id.
     * @param id The id of the request.
     */
    public void fulfill(int id) throws RequestFulfillException{
        Request req = get(id);
        if (req != null) {
            req.fulfill();
            ArrayList<Integer> similarId = new ArrayList<>();
            forEach((_id, request) -> {
                if (req.isSimilarTo(request)) similarId.add(_id);
            });
            similarId.forEach(this::remove);
        }
    }

    /**
     * Generate another collection from specific user.
     * @param user The user to filter.
     * @return Another collection.
     */
    public IdRequestCollection filterUser(User user){
        IdRequestCollection irc = new IdRequestCollection();
        forEach((id, req) -> {
            if (req.getUser().equals(user)) irc.put(id, req);
        });
        return irc;
    }

    /**
     * Gets a json representation of this instance.
     * @return A json string.
     */
    public Object toJson(){
        return new JSONArray(entrySet().stream().map(entry -> {
            JSONObject json = new JSONObject();
            json.put("id", (int)entry.getKey());
            json.put("req", entry.getValue().toJson());
            return json;
        }).toArray());
    }
}
