package memo.share;

import memo.Config;
import memo.misc.Utils;

import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;

/**
 * Represents a partial file.
 */
public final class PartialFile {
    /**
     * The file name.
     */
    private final String name;
    /**
     * The excepted digest provided by the file.
     */
    private final byte[] expectedDigest;
    /**
     * The chunks of the file.
     */
    private final Collection<byte[]> chunks;
    /**
     * Whether this file is encrypted.
     */
    private final boolean encrypted;
    /**
     * The internal message digest.
     */
    private final MessageDigest md5;

    /**
     * Initializes a new instance of the {@code PartialFile} class.
     * @param name The name of the file.
     * @param digest The expected digest.
     * @param encrypted Whether this file is encrypted.
     */
    public PartialFile(String name, byte[] digest, boolean encrypted) throws NoSuchAlgorithmException {
        this.name = name;
        expectedDigest = digest;
        this.encrypted = encrypted;
        chunks = new ArrayList<>();
        md5 = MessageDigest.getInstance("md5");
    }

    /**
     * Put a chunk of bytes into the buffer.
     * @param chunk The chunk to put.
     */
    public void putChunk(byte[] chunk){
        chunks.add(chunk);
        md5.update(chunk);
    }

    /**
     * Finish a <b>UNENCRYPTED</b> partial file.
     * @return Whether this operation succeeds.
     */
    public boolean finish() throws IOException {
        assert !encrypted;
        if (!Arrays.equals(md5.digest(), expectedDigest)) return false;
        File file = new File(Config.FILES_PATH, name);
        Utils.writeBinaryChunks(file.getAbsolutePath(), chunks.toArray(byte[][]::new));
        return true;
    }

    /**
     * Finish a <b>ENCRYPTED</b> partial file.
     * @param password The password used to encrypt.
     * @return Whether this operation succeeds.
     */
    public boolean finish(String password) throws GeneralSecurityException, IOException {
        assert encrypted;
        if (!Arrays.equals(md5.digest(), expectedDigest)) return false;
        EncryptedFile.writeEncrypted(name, password, concatChunks());
        return true;
    }

    /**
     * Gets the concatenated chunks.
     * @return The chunks in sum.
     */
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
