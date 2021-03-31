package memo.album;

import memo.misc.Utils;

import java.io.*;
import java.net.HttpURLConnection;
import java.util.*;
import java.util.zip.*;

/**
 * The class representing the album of pictures.
 */
public final class Album {
    /**
     * The absolute path of this album.
     */
    private final String path;
    /**
     * The properties of this album.
     */
    private final AlbumProperties properties;
    /**
     * The lock of this album.
     */
    private final AlbumLock lock;
    /**
     * Initializes a new instance of the {@code Album} class.
     * @param path The absolute path of the album.
     * @param properties The properties of the album.
     */
    public Album(String path, AlbumProperties properties) {
        this.path = path;
        this.properties = properties;
        lock = new AlbumLock();
    }

    /**
     * The properties of this album.
     * @return The properties of this album.
     */
    public AlbumProperties getProperties(){
        return properties;
    }

    /**
     * The absolute path of this album.
     * @return The absolute path of this album.
     */
    public String getPath() { return path; }

    /**
     * Gets the lock of this album.
     * @return The lock of this album.
     */
    public AlbumLock getLock(){
        return lock;
    }

    /**
     * Gets a image of the specific index.
     * @param index The index.
     * @return The image file at the index.
     */
    public File getImage(int index){
        File[] images = getImages();
        if (images == null) return null;
        return images[index];
    }

    /**
     * Gets all the images sorted by file name.
     * @return The image files.
     */
    public File[] getImages(){
        File dir = new File(path);
        File[] files = dir.listFiles((dir1, name) -> {
            String contentType = HttpURLConnection.guessContentTypeFromName(name);
            if (contentType == null) return false;
            return contentType.startsWith("image/");
        });
        if (files == null) return null;
        return Arrays.stream(files).sorted(Comparator.comparing(File::getName)).toArray(File[]::new);
    }

    /**
     * Check whether a file name was used in this album.
     * @param fileName The file name to check.
     * @return Whether the file name was used.
     */
    public boolean isFileNameUsed(String fileName){
        return indexOf(fileName) != -1;
    }

    /**
     * Adds a image to the album.
     * @param fileName The file name to add.
     * @param imageData The image binary data.
     * @return The index of the image added.
     * @throws IOException If an I/O error occurs.
     */
    public int addImage(String fileName, byte[] imageData) throws IOException {
        File dir = new File(path);
        File image = new File(dir, fileName);
        if (image.createNewFile()){
            Utils.writeBinaryFile(image.getAbsolutePath(), imageData);
            properties.increaseCount();
            properties.setModified(true);
            properties.saveProperties(new File(path, "album.json").getAbsolutePath());
            return indexOf(fileName);
        }
        else return -1;
    }

    /**
     * Deletes an image from this album.
     * @param index The index of the image.
     * @throws IOException If an I/O error occurs.
     */
    public void deleteImage(int index) throws IOException {
        File[] images = getImages();
        if (images == null) return;
        File image = images[index];
        if (image.delete()){
            properties.decreaseCount();
            properties.setModified(true);
            properties.saveProperties(new File(path, "album.json").getAbsolutePath());
        }
    }

    /**
     * Gets the index of the specific file name.
     * @param fileName The file name to find.
     * @return The index of the file name.
     */
    public int indexOf(String fileName){
        File[] images = getImages();
        if (images == null) return -1;
        for (int i = 0; i < images.length; i++){
            if (images[i].getName().equalsIgnoreCase(fileName)) return i;
        }
        return -1;
    }

    /**
     * Updates the zip file of this album.
     * @throws IOException If an I/O error occurs.
     */
    public void updateZip() throws IOException {
        File[] images = getImages();
        if (images == null) return;
        File zip = new File(path, "album.zip");
        FileOutputStream fos = new FileOutputStream(zip, false);
        CheckedOutputStream cos = new CheckedOutputStream(fos, new CRC32());
        ZipOutputStream zos = new ZipOutputStream(cos);
        for (File image: images){
            zos.putNextEntry(new ZipEntry(image.getName()));
            FileInputStream fis = new FileInputStream(image);
            zos.write(fis.readAllBytes());
            fis.close();
            zos.closeEntry();
        }
        zos.close();
        cos.close();
        fos.close();
        properties.setModified(false);
        properties.saveProperties(new File(path, "album.json").getAbsolutePath());
    }

    /**
     * Gets the zip file of this album.
     * @return The zip file.
     */
    public File getZip() throws IOException {
        if (properties.isModified()) updateZip();
        return new File(path, "album.zip");
    }

    /**
     * Gets a partially zipped album.
     * @param indices The indices of the images to zip.
     * @return The zipped album in bytes.
     * @throws IOException If an I/O error occurs.
     */
    public byte[] partialZip(int[] indices) throws IOException {
        File[] images = getImages();
        if (images == null) return new byte[]{};
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        CheckedOutputStream cos = new CheckedOutputStream(bos, new CRC32());
        ZipOutputStream zos = new ZipOutputStream(cos);
        for (int index: indices){
            File image = images[index];
            zos.putNextEntry(new ZipEntry(image.getName()));
            FileInputStream fis = new FileInputStream(image);
            zos.write(fis.readAllBytes());
            fis.close();
            zos.closeEntry();
        }
        zos.close();
        cos.close();
        return bos.toByteArray();
    }
}
