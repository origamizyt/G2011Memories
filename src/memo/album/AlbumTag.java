package memo.album;

/**
 * Represents a tag for the album.
 */
public final class AlbumTag {
    /**
     * The name of this tag.
     */
    private final String name;
    /**
     * Initializes a new instance of the {@code AlbumTag} class.
     * @param name The name of this tag.
     */
    public AlbumTag(String name){
        this.name = name;
    }
    /**
     * Gets the name of this tag.
     * @return The name of this tag.
     */
    public String getName(){
        return name;
    }
}
