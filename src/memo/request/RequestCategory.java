package memo.request;

/**
 * The category of the request.
 */
public enum RequestCategory {
    /**
     * Request to delete an album.
     */
    DELETE_ALBUM((short)1),
    /**
     * Request to delete an article.
     */
    DELETE_ARTICLE((short)2);
    /**
     * The integer value of this category.
     */
    private final short value;

    /**
     * Initializes a new instance of the {@code RequestCategory} enumeration.
     * @param value The integer value.
     */
    RequestCategory(short value){
        this.value = value;
    }
    /**
     * Gets the integer value of this category.
     * @return The integer value.
     */
    public short getValue() {
        return value;
    }

    /**
     * Gets the category from an integer value.
     * @param value The integer value.
     * @return The category with specific value.
     */
    public static RequestCategory fromValue(short value){
        switch (value){
            case 1: return DELETE_ALBUM;
            case 2: return DELETE_ARTICLE;
            default: return null;
        }
    }
}
