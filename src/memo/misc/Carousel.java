package memo.misc;

import memo.Config;
import org.json.JSONObject;

import java.io.File;

/**
 * Represents a carousel in the main page.
 */
public final class Carousel {
    /**
     * The title of the carousel.
     */
    private final String title;
    /**
     * The description of the carousel.
     */
    private final String description;
    /**
     * The file name of the image.
     */
    private final String fileName;
    /**
     * The id of the carousel.
     */
    private final int id;

    /**
     * Initializes a new instance of the {@code Carousel} class.
     * @param id The id of the carousel.
     * @param title The title of the carousel.
     * @param description The description of the carousel.
     * @param fileName The file name of the image.
     */
    public Carousel(int id, String title, String description, String fileName){
        this.id = id;
        this.title = title;
        this.description = description;
        this.fileName = fileName;
    }

    /**
     * Converts this object to json format.
     * @return A json representation of this object.
     */
    public Object toJson(){
        JSONObject json = new JSONObject();
        json.put("id", id);
        json.put("title", title);
        json.put("desc", description);
        return json;
    }

    /**
     * Gets the image file of this carousel.
     * @return The image file of this carousel.
     */
    public File getImage(){
        return new File(Config.CAROUSEL_PATH, fileName);
    }

    /**
     * Gets the id of this carousel.
     * @return The id of this carousel.
     */
    public int getId() {
        return id;
    }
}
