package memo.resource;

import memo.misc.Utils;
import redis.clients.jedis.Jedis;

import java.util.ArrayList;
import java.util.Collection;

/**
 * Represents a resource manager.
 */
public final class ResourceManager {
    /**
     * The name of this manager.
     */
    private final String name;

    /**
     * Initializes a new instance of the {@code ResourceManager} class.
     * @param name The name of this manager.
     */
    public ResourceManager(String name){
        this.name = name;
    }

    /**
     * Gets a resource group if exists.
     * @param groupName The name of the group.
     * @return The resource group if exists, otherwise {@code null}.
     */
    public ResourceGroup findGroup(String groupName){
        return groupExists(groupName) ? new ResourceGroup(name + ":" + groupName) : null;
    }

    /**
     * Test whether a group exists.
     * @param groupName The name of the group.
     * @return Whether the specified group exists.
     */
    public boolean groupExists(String groupName){
        Jedis jedis = Utils.getJedis();
        String key = "resource-groups@" + name;
        boolean exists =  jedis.lrange(key, 0, -1).contains(groupName);
        jedis.close();
        return exists;
    }

    /**
     * Puts a new group into this manager.
     * @param groupName The name of the group.
     */
    public void putGroup(String groupName){
        Jedis jedis = Utils.getJedis();
        String key = "resource-groups@" + name;
        jedis.rpush(key, groupName);
        jedis.close();
    }

    /**
     * Lists the groups of this manager.
     * @return The groups of this manager.
     */
    public Collection<ResourceGroup> listGroups(){
        Jedis jedis = Utils.getJedis();
        ArrayList<ResourceGroup> groups = new ArrayList<>();
        for (String group: jedis.lrange("resource-groups@" + name, 0, -1)){
            groups.add(new ResourceGroup(name + ":" + group));
        }
        jedis.close();
        return groups;
    }

    /**
     * Gets the name of this manager.
     * @return The name of this manager.
     */
    public String getName() {
        return name;
    }
}
