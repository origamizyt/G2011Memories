package memo.user;

import memo.article.Article;
import memo.request.IdRequestCollection;
import memo.request.Request;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Collection;

/**
 * Represents the user records.
 */
public final class UserRecords {
    /**
     * The user of the records.
     */
    private final User user;
    /**
     * The articles of this user.
     */
    private final Collection<Article> articles;
    /**
     * The requests of this user.
     */
    private final IdRequestCollection requests;

    /**
     * Initializes a new instance of the {@code UserRecords} class.
     * @param user The user of this records.
     * @param articles The articles of this user.
     * @param requests The requests of this user.
     */
    public UserRecords(User user, Collection<Article> articles, IdRequestCollection requests){
        this.user = user;
        this.articles = articles;
        this.requests = requests;
    }

    /**
     * The user of the records.
     * @return The user of the records.
     */
    public User getUser() {
        return user;
    }

    /**
     * The articles of this user.
     * @return The articles of this user.
     */
    public Collection<Article> getArticles() {
        return articles;
    }

    /**
     * The requests of this user.
     * @return The requests of this user.
     */
    public IdRequestCollection getRequests() { return requests; }

    /**
     * Converts this object to json format.
     * @return Json representation of this object.
     */
    public Object toJson(){
        JSONObject json = new JSONObject();
        JSONArray articles = new JSONArray(this.articles.stream().map(a -> a.getProperties().toJson()).toArray());
        json.put("user", user.getUserName());
        json.put("articles", articles);
        json.put("requests", requests.toJson());
        return json;
    }
}
