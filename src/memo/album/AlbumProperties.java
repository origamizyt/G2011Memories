package memo.album;

import org.json.JSONArray;
import org.json.JSONObject;
import java.io.IOException;
import java.util.Date;

import memo.misc.Utils;

/**
 * The properties of an album.
 */
public class AlbumProperties {
    /**
     * The name of the album.
     */
    protected String name;
    /**
     * The count of images in the album.
     */
    protected int count;
    /**
     * The collection of tags.
     */
    protected TagCollection tags;
    /**
     * The date this album was created.
     */
    private Date date;
    /**
     * Whether this album's zip file is not up-to-date.
     */
    protected boolean modified;
    /**
     * Initializes a new instance of the {@code AlbumProperties} class.
     */
    protected AlbumProperties() {}
    /**
     * Loads a {@code AlbumProperties} from a json file.
     * @param fileName The name of the file.
     * @return The parsed {@code AlbumProperties}.
     * @throws IOException If the file does not exist.
     */
    public static AlbumProperties loadProperties(String fileName)
            throws IOException {
        String content = Utils.readFile(fileName);
        JSONObject json = new JSONObject(content);
        AlbumProperties ap = new AlbumProperties();
        ap.name = json.getString("name");
        ap.count = json.getInt("count");
        TagCollection tags = new TagCollection();
        for (Object tag: json.getJSONArray("tags")){
            String tagName = tag.toString();
            tags.add(new AlbumTag(tagName));
        }
        ap.date = new Date(json.getLong("date"));
        ap.tags = tags;
        ap.modified = json.getBoolean("modified");
        return ap;
    }

    /**
     * Creates a new instance of the {@code AlbumProperties} class.
     * @param name The name of the album.
     * @param tags The tags of the album.
     * @param date The date of the album in long.
     * @return The created {@code AlbumProperties}.
     */
    public static AlbumProperties create(String name, String[] tags, long date){
        AlbumProperties ap = new AlbumProperties();
        ap.name = name;
        ap.tags = new TagCollection();
        for (String tag: tags){
            ap.tags.add(new AlbumTag(tag));
        }
        ap.date = new Date(date);
        ap.count = 0;
        ap.modified = true;
        return ap;
    }

    /**
     * The name of the album.
     * @return The name of the album.
     */
    public String getName() {
        return name;
    }

    /**
     * The count of images in the album.
     * @return The count of images in the album.
     */
    public int getCount() {
        return count;
    }

    /**
     * The collection of tags.
     * @return The collection of tags.
     */
    public TagCollection getTags() {
        return tags;
    }

    /**
     * Gets a JSON representation of this object.
     * @return A JSON object.
     */
    public Object toJson(){
        return toJsonInternal();
    }

    /**
     * Gets a JSON representation of this object.
     * @return A JSON object.
     */
    protected JSONObject toJsonInternal(){
        JSONObject json = new JSONObject();
        json.put("name", name);
        json.put("date", date.getTime());
        json.put("count", count);
        json.put("tags", new JSONArray(tags.stream().map(AlbumTag::getName).toArray()));
        json.put("modified", modified);
        return json;
    }

    /**
     * Save this object to a .json file.
     * @param fileName The file name to save.
     * @throws IOException If an I/O error occurs.
     */
    public void saveProperties(String fileName)
        throws IOException {
        Utils.writeFile(fileName, toJsonInternal().toString(2));
    }

    /**
     * Increase the count of images by 1.
     */
    public void increaseCount(){
        this.count++;
    }

    /**
     * Decrease the count of images by 1.
     */
    public void decreaseCount(){
        this.count--;
    }

    /**
     * Sets whether the zip file is up-to-date.
     * @param modified The new value of 'modified' entry.
     */
    public void setModified(boolean modified){
        this.modified = modified;
    }

    /**
     * Gets whether the zip file is up-to-date.
     * @return The value of 'modified' entry.
     */
    public boolean isModified() {
        return modified;
    }

    /**
     * The date this album was created.
     * @return The date this album was created.
     */
    public Date getDate() {
        return date;
    }
}
