package memo.servlets;

import memo.misc.Utils;
import memo.user.User;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

@WebListener()
public class OnlineUserListener implements HttpSessionListener{

    /**
     * Initializes a new instance of the {@code OnlineUserListener} class.
     */
    public OnlineUserListener() { }

    /**
     * Called when a session is created.
     * @param se The event.
     */
    public void sessionCreated(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        session.setMaxInactiveInterval(0);
    }

    /**
     * Called when a session is destroyed.
     * @param se The event.
     */
    public void sessionDestroyed(HttpSessionEvent se) {
        System.out.println("session destroyed");
        HttpSession session = se.getSession();
        if (Utils.isSessionInitialized(session)){
            User user = Utils.getSessionUser(session);
            Utils.finalizeSession(session);
            Utils.onlineUser.offline(user);
        }
    }
}
