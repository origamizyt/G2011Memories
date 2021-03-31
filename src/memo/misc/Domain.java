package memo.misc;

import org.json.JSONObject;

public final class Domain {
    /**
     * The name of this domain.
     */
    private final String name;
    /**
     * The path to the domain.
     */
    private final String path;
    /**
     * Whether this domain is a space.
     */
    private final boolean space;

    /**
     * Initializes a new instance of the {@code Domain} class.
     * @param name The name of the domain.
     * @param path The path to the domain.
     * @param space Whether the domain is a space.
     */
    public Domain(String name, String path, boolean space){
        this.name = name;
        this.path = path;
        this.space = space;
    }

    /**
     * Gets the name of this domain.
     * @return The name of this domain.
     */
    public String getName() {
        return name;
    }

    /**
     * Gets the path to the domain.
     * @return The path to the domain.
     */
    public String getPath() {
        return path;
    }

    /**
     * Gets whether this domain is a space.
     * @return Whether the domain is a space.
     */
    public boolean isSpace() {
        return space;
    }

    /**
     * Converts this instance to json format.
     * @return A json representation of this object.
     */
    public Object toJson(){
        JSONObject json = new JSONObject();
        json.put("name", name);
        json.put("path", path);
        json.put("space", space);
        return json;
    }
}
