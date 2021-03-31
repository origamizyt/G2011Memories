package memo.servlets;

import memo.misc.Utils;
import memo.share.PartialFile;
import org.json.JSONObject;

import javax.websocket.CloseReason;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.security.GeneralSecurityException;

@ServerEndpoint("/space/put")
public class PublicFileWebsocket {
    private boolean firstPacket = true;
    private boolean encrypted = false;
    private String series = null, name = null, tag = null;
    private PartialFile partial = null;
    private int count = 0;
    private int total = 0;
    private String password = null;
    private Session session = null;
    private static final int CODE_FILE_EXISTS = 4000;
    private static final int CODE_FILE_INTEGRITY_FAIL = 4001;
    @OnOpen
    public void onOpen(Session session){
        this.session = session;
    }
    @OnMessage
    public void onMessage(String message) throws GeneralSecurityException, IOException {
        if (firstPacket){
            firstPacket = false;
            JSONObject json = new JSONObject(message);
            if (!json.isNull("series"))
                series = json.getString("series");
            encrypted = json.getBoolean("encrypted");
            if (encrypted)
                password = json.getString("password");
            total = json.getInt("count");
            name = json.getString("name");
            if (Utils.fileExists(name)){
                Utils.Result result = new Utils.Result(Utils.ERROR_FILE_ALREADY_EXISTS);
                session.getBasicRemote().sendText(result.toJson());
                session.close(new CloseReason(CloseReason.CloseCodes.getCloseCode(CODE_FILE_EXISTS), ""));
                return;
            }
            tag = json.getString("tag");
            byte[] digest = Utils.fromHex(json.getString("digest"));
            partial = new PartialFile(name, digest, encrypted);
        }
        else {
            count += 1;
            byte[] chunk = Utils.decodeBase64(message);
            partial.putChunk(chunk);
            if (count >= total){
                if (encrypted){
                    if (partial.finish(password)) {
                        Utils.fileUploaded(name, tag, series, Utils.sha256digest(password));
                        session.close(new CloseReason(CloseReason.CloseCodes.NORMAL_CLOSURE, ""));
                    }
                    else{
                        Utils.Result result = new Utils.Result(Utils.ERROR_FILE_INTEGRITY_FAIL);
                        session.getBasicRemote().sendText(result.toJson());
                        session.close(new CloseReason(CloseReason.CloseCodes.getCloseCode(CODE_FILE_INTEGRITY_FAIL), ""));
                    }
                }
                else {
                    if (partial.finish()) {
                        Utils.fileUploaded(name, tag, series);
                        session.close(new CloseReason(CloseReason.CloseCodes.NORMAL_CLOSURE, ""));
                    }
                    else{
                        Utils.Result result = new Utils.Result(Utils.ERROR_FILE_INTEGRITY_FAIL);
                        session.getBasicRemote().sendText(result.toJson());
                        session.close(new CloseReason(CloseReason.CloseCodes.getCloseCode(CODE_FILE_INTEGRITY_FAIL), ""));
                    }
                }
                return;
            }
        }
        Utils.Result result = new Utils.Result();
        session.getBasicRemote().sendText(result.toJson());
    }
}
