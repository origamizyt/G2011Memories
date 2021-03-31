package memo.album;

import java.util.Vector;

/**
 * A collection of {@code AlbumTag}.
 */
public final class TagCollection extends Vector<AlbumTag> {
    /**
     * Initializes a new instance of the {@code TagCollection} class.
     */
    public TagCollection(){
        super();
    }
    /**
     * Indicate whether the specified tag name exists in this collection.
     * @param tagName The name of the tag to search.
     * @return A {@code boolean} value, indicating whether the specified tag exists.
     */
    public boolean tagExists(String tagName){
        return stream().anyMatch(tag -> tag.getName().equals(tagName));
    }
}
