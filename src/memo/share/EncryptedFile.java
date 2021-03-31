package memo.share;


import memo.Config;
import memo.misc.Utils;
import org.json.JSONObject;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.security.AlgorithmParameters;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.security.spec.KeySpec;

/**
 * Represents a encrypted file.
 */
public final class EncryptedFile extends PublicFile{

    /**
     * The sha-256 digested password.
     */
    private final byte[] sha256password;

    /**
     * Initializes a new instance of the {@code EncryptedFile} class.
     * @param name The name of the file.
     * @param tag  The tag of this file.
     * @param password The sha-256 digested password.
     */
    public EncryptedFile(String name, String tag, byte[] password) {
        super(name, tag);
        sha256password = password;
    }

    /**
     * Verify the password.
     * @param password The password to test.
     * @return {@code true} if match, otherwise {@code false}.
     */
    public boolean verifyPassword(byte[] password){
        return Arrays.equals(password, sha256password);
    }

    /**
     * Write the encrypted contents of a file.
     * @param fileName The name of the file.
     * @param password The password used to derive the secret key.
     * @param content The unencrypted content of a file.
     * @throws GeneralSecurityException Encryption error.
     * @throws IOException I/O error.
     */
    public static void writeEncrypted(String fileName, String password, byte[] content) throws GeneralSecurityException, IOException {
        SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        KeySpec keySpec = new PBEKeySpec(password.toCharArray(), salt, 1000, 128);
        byte[] aesKey = factory.generateSecret(keySpec).getEncoded();
        SecretKey key = new SecretKeySpec(aesKey, "AES");
        byte[] iv = new byte[16];
        random.nextBytes(iv);
        AlgorithmParameters params = AlgorithmParameters.getInstance("AES");
        params.init(new IvParameterSpec(iv));
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key, params);
        byte[] encrypted = cipher.doFinal(content);
        File file = new File(Config.FILES_PATH, fileName);
        Utils.writeBinaryChunks(file.getAbsolutePath(), salt, iv, encrypted);
    }

    /**
     * Converts this object to json format.
     * @return A json representation of this object.
     */
    @Override
    public Object toJson() {
        JSONObject json = (JSONObject) super.toJson();
        json.put("encrypted", true);
        return json;
    }

    /**
     * Decrypt the file using specific password.
     * @param password The password used to decrypt.
     * @return The decrypted bytes if success, otherwise {@code null}.
     * @throws IOException I/O error.
     */
    public byte[] decrypt(String password) throws IOException, GeneralSecurityException {
        File file = new File(Config.FILES_PATH, name);
        byte[][] chunks = Utils.readBinaryChunks(file.getAbsolutePath(), 16, 16);
        byte[] salt = chunks[0], iv = chunks[1], encrypted = chunks[2];
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
        KeySpec keySpec = new PBEKeySpec(password.toCharArray(), salt, 1000, 128);
        byte[] aesKey = factory.generateSecret(keySpec).getEncoded();
        SecretKey key = new SecretKeySpec(aesKey, "AES");
        AlgorithmParameters params = AlgorithmParameters.getInstance("AES");
        params.init(new IvParameterSpec(iv));
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, key, params);
        return cipher.doFinal(encrypted);
    }
}
