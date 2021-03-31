package memo.user;

/**
 * The level hold by the user to access different pages.
 */
public enum AccessLevel {
    /**
     * The user has no privileges, or is black-listed.
     */
    NONE((short)0),
    /**
     * The user has basic privileges like downloading and viewing.
     */
    GUEST((short)1),
    /**
     * The user has full privileges to albums and articles,
     * including uploading and posting them.
     */
    MEMBER((short)2),
    /**
     * The user has all privileges to administrator tools,
     * as well as common pages and operations.
     */
    ADMIN((short)3);
    /**
     * The numeric value of the level.
     */
    private final short value;

    /**
     * Initializes a new instance of the {@code AccessLevel} enumeration.
     * @param value The numeric value of the level.
     */
    AccessLevel(short value){
        this.value = value;
    }

    /**
     * Gets the numeric value of this level.
     * @return The numeric value of this level.
     */
    public short getValue(){
        return value;
    }

    /**
     * Gets an instance of this enum from a integer value.
     * @param value The integer value.
     * @return An instance of this enumeration.
     */
    public static AccessLevel fromValue(short value){
        switch (value){
            case 0: return NONE;
            case 1: return GUEST;
            case 2: return MEMBER;
            case 3: return ADMIN;
        }
        return null;
    }
}
