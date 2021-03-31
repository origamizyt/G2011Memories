package memo.servlets;

import memo.misc.Utils;
import memo.user.User;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.util.Objects;

@ServerEndpoint(value = "/album/lock", configurator = WebsocketConfigurator.class)
public class AlbumLockWebsocket {
    private User user;
    @OnOpen
    public void onOpen(Session session, EndpointConfig config){
        user = (User)config.getUserProperties().get("user");
        session.setMaxIdleTimeout(0);
    }
    @OnClose
    public void onClose(){
        if (Objects.requireNonNull(Utils.getOption("EnableAlbumLock")).getValue()){
            Utils.unlockAllAlbums(user);
        }
    }
}
