package memo.share;

import memo.Config;
import memo.misc.Utils;

import java.io.File;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.json.JSONObject;

/**
 * The public file shared in the space.
 */
public class PublicFile {
    /**
     * The name of this file.
     */
    protected final String name;
    /**
     * The md5 digest of this file.
     */
    private byte[] digest;
    /**
     * The tag of this file.
     * Can be {@code null}, if this file has no tag.
     */
    protected final String tag;

    /**
     * Initializes a new instance of the {@code PublicFile} class.
     * @param name The name of the file.
     * @param tag The tag of this file.
     */
    public PublicFile(String name, String tag){
        this.name = name;
        this.tag = tag;
        this.digest = null;
    }

    /**
     * Updates the digest of this file.
     */
    public void updateDigest() {
        File file = new File(Config.FILES_PATH, name);
        if (!file.exists()) return;
        try {
            byte[] data = Utils.readBinaryFile(file.getAbsolutePath());
            MessageDigest md5 = MessageDigest.getInstance("md5");
            digest = md5.digest(data);
        }
        catch (NoSuchAlgorithmException | IOException ignored){ }
    }

    /**
     * Gets the md5 digest of this file.
     * @return The md5 digest of this file.
     */
    public byte[] getDigest() {
        if (digest == null) updateDigest();
        return digest;
    }

    /**
     * Converts this object to json format.
     * @return A json representation of this object.
     */
    public Object toJson() {
        JSONObject json = new JSONObject();
        json.put("name", name);
        json.put("tag", tag);
        json.put("digest", Utils.convertToHex(getDigest()));
        json.put("encrypted", false);
        return json;
    }

    /**
     * Gets the name of this file.
     * @return The name of this file.
     */
    public String getName() {
        return name;
    }
}
