package memo.misc;

import org.json.JSONObject;

/**
 * Represents an option of the website.
 */
public final class Option {
    /**
     * The name of the option.
     */
    private final String name;
    /**
     * The description of the option.
     */
    private final String description;
    /**
     * The value of the option.
     */
    private final boolean value;

    /**
     * Initializes a new instance of the {@code Option} class.
     * @param name The name of the option.
     * @param description The description of the option.
     * @param value The value of the option.
     */
    public Option(String name, String description, boolean value){
        this.name = name;
        this.description = description;
        this.value = value;
    }

    /**
     * Gets the name of this option.
     * @return The name of this option.
     */
    public String getName(){
        return name;
    }
    /**
     * Gets the value of this option.
     * @return The value of this option.
     */
    public boolean getValue(){
        return value;
    }

    /**
     * Converts this instance to json format.
     * @return A json representation of this object.
     */
    public Object toJson(){
        JSONObject json = new JSONObject();
        json.put("name", name);
        json.put("desc", description);
        json.put("value", value);
        return json;
    }
}
