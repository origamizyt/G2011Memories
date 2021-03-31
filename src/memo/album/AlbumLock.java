package memo.album;

import memo.user.User;

/**
 * Represents a album lock.
 */
public final class AlbumLock {
    /**
     * The user that locked this album.
     * {@code null} if unlocked.
     */
    private User lockedBy = null;
    /**
     * If this lock is locked.
     */
    private boolean locked = false;
    /**
     * Initializes a new instance of the {@code AlbumLock} class.
     */
    public AlbumLock(){}

    /**
     * Lock this lock.
     * @param user The user as locker.
     * @return Whether this lock was successfully locked.
     */
    public boolean lock(User user){
        if (locked) return false;
        lockedBy = user;
        locked = true;
        return true;
    }

    /**
     * Unlock this lock.
     * @param user The user as locker.
     * @return Whether this lock was successfully unlocked.
     */
    public boolean unlock(User user){
        if (!lockedBy.equals(user)) return false;
        locked = false;
        lockedBy = null;
        return true;
    }

    /**
     * Gets the locker of this lock.
     * @return The user that locked this album. {@code null} if unlocked.
     */
    public User getLocker(){
        return lockedBy;
    }

    /**
     * Check whether this lock is locked.
     * @return Whether this lock is locked.
     */
    public boolean isLocked() {
        return locked;
    }
}
