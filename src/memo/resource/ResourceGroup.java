package memo.resource;

import java.util.*;
import java.util.stream.Stream;
import memo.misc.Utils;
import org.json.JSONArray;
import org.json.JSONObject;
import redis.clients.jedis.Jedis;

/**
 * Represents a list of similar resources.
 */
public final class ResourceGroup {
    /**
     * The name of this group.
     */
    private final String name;
    /**
     * The resources of this group.
     */
    private final List<Resource> resources;
    /**
     * Whether items from this group has been deleted.
     */
    private boolean deleted;
    /**
     * Initializes a new instance of the {@code ResourceGroup} class.
     * @param name The name of this group.
     */
    public ResourceGroup(String name){
        this.name = name;
        Jedis jedis = Utils.getJedis();
        int length = jedis.keys("resource@" + name + "#*").size();
        jedis.close();
        resources = new ArrayList<>();
        for (int i = 0; i < length; i++){
            resources.add(Resource.fromDatabase(name + "#" + i));
        }
    }

    /**
     * Gets the name of this group.
     * @return The name of this group.
     */
    public String getName(){
        return name;
    }

    /**
     * Gets this instance as a list.
     * @return A list containing all resources.
     */
    public List<Resource> asList(){
        return Collections.unmodifiableList(resources);
    }

    /**
     * Gets this instance as a stream.
     * @return A stream containing all resources.
     */
    public Stream<Resource> asStream(){
        return resources.stream();
    }

    /**
     * Converts this instance to json format.
     * @return A json representation of this object.
     */
    public Object toJson(){
        JSONObject json = new JSONObject();
        json.put("name", name);
        json.put("res", new JSONArray(asStream().map(Resource::toJson).toArray()));
        return json;
    }

    /**
     * Append a resource to this group.
     * @param res The resource to put.
     */
    public void putResource(Resource res){
        res.save(name + "#" + resources.size());
        resources.add(res);
    }

    /**
     * Flush this group to the database.
     */
    public void flush(){
        String[] parts = name.split(":");
        ResourceManager manager = new ResourceManager(parts[0]);
        String group = parts[1];
        if (!manager.groupExists(group)) manager.putGroup(group);
        if (deleted){
            Jedis jedis = Utils.getJedis();
            jedis.keys("resource@" + name + "#*").forEach(jedis::del);
            jedis.close();
        }
        for (int i = 0; i < resources.size(); i++){
            Resource res = resources.get(i);
            if (res.modified || deleted) {
                res.save(name + "#" + i);
                res.modified = false;
            }
        }
        deleted = false;
    }

    /**
     * Remove a resource from this group.
     * @param res The resource to remove.
     */
    public void removeResource(Resource res){
        deleted = true;
        resources.remove(res);
    }
}
