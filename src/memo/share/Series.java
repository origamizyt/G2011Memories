package memo.share;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Vector;

/**
 * Represents a series of public files.
 */
public final class Series {
    /**
     * The name of this series.
     */
    private final String name;
    /**
     * The collection of public files.
     */
    private final Collection<PublicFile> files;

    /**
     * Initializes a new instance of the {@code Series} class.
     * @param name The name of this series.
     */
    public Series(String name){
        this.name = name;
        files = new ArrayList<>();
    }

    /**
     * Adds a file to the collection.
     * @param file The file to add.
     */
    public void add(PublicFile file){
        files.add(file);
    }

    /**
     * Converts this object to json format.
     * @return A json representation of this object.
     */
    public Object toJson(){
        JSONObject json = new JSONObject();
        json.put("name", name);
        json.put("files", new JSONArray(files.stream().map(PublicFile::toJson).toArray()));
        return json;
    }

    /**
     * The name of this series.
     * @return The name of this series.
     */
    public String getName() {
        return name;
    }

    /**
     * Gets the files of this series.
     * @return The files of this series.
     */
    public Collection<PublicFile> getFiles(){
        return new Vector<>(files);
    }
}
