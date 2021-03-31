package memo.user;

import javax.servlet.http.HttpSession;

/**
 * Represents the user / session pair.
 */
public final class UserSessionPair {
    /**
     * The user in this pair.
     */
    private final User user;
    /**
     * The session in this pair.
     */
    private final HttpSession session;

    public UserSessionPair(User user, HttpSession session){
        this.user = user;
        this.session = session;
    }

    /**
     * The user in this pair.
     * @return The user in this pair.
     */
    public User getUser() {
        return user;
    }

    /**
     * The session in this pair.
     * @return The session in this pair.
     */
    public HttpSession getSession() {
        return session;
    }
}
