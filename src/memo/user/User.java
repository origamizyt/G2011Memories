package memo.user;

import java.util.Objects;

public final class User {
    /**
     * The "GUEST" user.
     */
    public static final User GUEST = new User(-1, "访客", new byte[] {}, AccessLevel.GUEST);
    /**
     * The id of this user.
     */
    private final int userId;
    /**
     * The name of this user.
     */
    private final String userName;
    /**
     * The password of this user.
     */
    private byte[] password;
    /**
     * The access level this user holds.
     */
    private AccessLevel level;

    /**
     * Initializes a new instance of the {@code User} class.
     * @param id The id of the user.
     * @param name The name of the user.
     * @param password The password of the user.
     * @param accessLevel The level of the user.
     */
    public User(int id, String name, byte[] password, AccessLevel accessLevel){
        userId = id;
        userName = name;
        this.password = password;
        level = accessLevel;
    }

    /**
     * The id of this user.
     * @return The id of this user.
     */
    public int getUserId() {
        return userId;
    }

    /**
     * The name of this user.
     * @return The name of this user.
     */
    public String getUserName() {
        return userName;
    }

    /**
     * The password of this user.
     * @return The password of this user.
     */
    public byte[] getPassword() {
        return password;
    }

    /**
     * The access level this user holds.
     * @return The access level this user holds.
     */
    public AccessLevel getLevel() {
        return level;
    }

    /**
     * Sets the level of this user.
     * @param level The new access level.
     */
    public void setLevel(AccessLevel level) {
        this.level = level;
    }

    /**
     * Test whether this object is equal to another.
     * GUEST user is always NOT equal to other users.
     * @param o Another object.
     * @return {@code true} if the two objects are identical, otherwise {@code false}.
     */
    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        if (userId == -1) return false;
        if (this == o) return true;
        User user = (User) o;
        return userId == user.userId;
    }

    /**
     * Gets the hash code of this object.
     * @return The hash code of this object.
     */
    @Override
    public int hashCode() {
        return Objects.hash(userId);
    }

    /**
     * Check whether a user is a guest.
     * @param user The user to check.
     * @return Whether the user is guest user.
     */
    public static boolean isGuestUser(User user){
        return user.userId < 0;
    }

    /**
     * Sets the password of this instance.
     * @param password The new password.
     */
    public void setPassword(byte[] password){
        this.password = password;
    }
}
