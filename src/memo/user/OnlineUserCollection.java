package memo.user;

import javax.servlet.http.HttpSession;
import java.util.Objects;
import java.util.Vector;

public final class OnlineUserCollection {
    /**
     * Inner user list.
     */
    private final Vector<UserSessionPair> innerList = new Vector<>();

    /**
     * Initializes a new instance of the {@code OnlineUserCollection} class.
     */
    public OnlineUserCollection(){ }

    /**
     * Test whether a user is online.
     * @param user The user to test.
     * @return Whether the user is online.
     */
    public boolean isOnline(User user){
        return innerList.stream().anyMatch(u -> u.getUser().equals(user));
    }

    /**
     * Make a user online.
     * @param pair The user / session pair.
     */
    public void online(UserSessionPair pair){
        if (isOnline(pair.getUser())) return;
        innerList.add(Objects.requireNonNull(pair));
    }

    /**
     * Make a user offline.
     * @param user The user.
     */
    public void offline(User user){
        if (!isOnline(user)) return;
        for (UserSessionPair p : innerList) {
            if (p.getUser().equals(user)) {
                innerList.remove(p);
                return;
            }
        }
    }

    /**
     * Get the matching session of a user.
     * @param user The user to find.
     * @return The session of the user.
     */
    public HttpSession getSessionOf(User user){
        for (UserSessionPair p : innerList){
            if (p.getUser().equals(user)) return p.getSession();
        }
        return null;
    }

    /**
     * Gets the user specified by address.
     * @param address The remote address.
     * @return The user if present, otherwise {@code null}.
     */
    public User getUserByAddress(String address){
        for (UserSessionPair pair: innerList){
            if (address.equals(pair.getSession().getAttribute("address"))) return pair.getUser();
        }
        return null;
    }
}
