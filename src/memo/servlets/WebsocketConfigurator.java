package memo.servlets;

import memo.misc.Utils;
import memo.user.User;

import javax.servlet.http.HttpSession;
import javax.websocket.HandshakeResponse;
import javax.websocket.server.HandshakeRequest;
import javax.websocket.server.ServerEndpointConfig;
import javax.websocket.server.ServerEndpointConfig.Configurator;

public final class WebsocketConfigurator extends Configurator {
    @Override
    public void modifyHandshake(ServerEndpointConfig sec, HandshakeRequest request, HandshakeResponse response) {
        HttpSession session = (HttpSession) request.getHttpSession();
        User user = Utils.getSessionUser(session);
        sec.getUserProperties().put("user", user);
        super.modifyHandshake(sec, request, response);
    }
}
