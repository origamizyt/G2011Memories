package memo.servlets;

import memo.album.Album;
import memo.misc.Utils;
import memo.user.AccessLevel;
import memo.user.User;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;

import org.json.JSONObject;

@ServerEndpoint(value = "/album/put", configurator = WebsocketConfigurator.class)
public final class AlbumUploadWebsocket {
    private Session session;
    private User user;
    private Album album;
    private boolean firstPacket = true;
    private final ArrayList<byte[]> chunks = new ArrayList<>();
    private String fileName;
    private static final int CODE_ACCESS_DENIED = 4002;
    private static final int CODE_MISSING_ALBUM = 4003;
    private static final int CODE_UNMATCHED_LOCKER = 4004;
    @OnOpen
    public void onOpen(Session session) throws IOException {
        Object _user = session.getUserProperties().get("user");
        if (_user == null || (user = (User)_user).getLevel().getValue() < AccessLevel.MEMBER.getValue()){
            Utils.Result result = new Utils.Result(Utils.ERROR_ACCESS_DENIED);
            session.getBasicRemote().sendText(result.toJson());
            session.close(new CloseReason(CloseReason.CloseCodes.getCloseCode(CODE_ACCESS_DENIED), ""));
        }
        this.session = session;
    }
    @OnMessage
    public void onMessage(String message) throws IOException {
        if (firstPacket) {
            JSONObject json = new JSONObject(message);
            firstPacket = false;
            String name = json.getString("name");
            if ((album = Utils.getAlbumByName(name)) == null) {
                Utils.Result result = new Utils.Result(Utils.ERROR_MISSING_ALBUM);
                session.getBasicRemote().sendText(result.toJson());
                session.close(new CloseReason(CloseReason.CloseCodes.getCloseCode(CODE_MISSING_ALBUM), ""));
                return;
            }
            if (album.getLock().isLocked() && !album.getLock().getLocker().equals(user)) {
                Utils.Result result = new Utils.Result(Utils.ERROR_UNMATCHED_LOCKER);
                session.getBasicRemote().sendText(result.toJson());
                session.close(new CloseReason(CloseReason.CloseCodes.getCloseCode(CODE_UNMATCHED_LOCKER), ""));
            }
            fileName = json.getString("file");
        }
        else {
            byte[] chunk = Utils.decodeBase64(message);
            chunks.add(chunk);
        }
        Utils.Result result = new Utils.Result();
        session.getBasicRemote().sendText(result.toJson());
    }

    @OnClose
    public void onClose(CloseReason reason) throws IOException {
        if (reason.getCloseCode().getCode() != 1000) return;
        byte[] image = concatChunks();
        album.addImage(fileName, image);
    }

    private byte[] concatChunks(){
        int length = 0;
        for (byte[] chunk: chunks){
            length += chunk.length;
        }
        byte[] sum = new byte[length];
        int calculatedLength = 0;
        for (byte[] chunk: chunks){
            System.arraycopy(chunk, 0, sum, calculatedLength, chunk.length);
            calculatedLength += chunk.length;
        }
        return sum;
    }
}
