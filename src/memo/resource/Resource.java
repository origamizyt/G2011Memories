package memo.resource;

import java.nio.charset.StandardCharsets;
import java.util.*;

import memo.misc.Utils;
import org.json.JSONObject;
import redis.clients.jedis.Jedis;

/**
 * Represents a single resource item.
 */
public class Resource {
    /**
     * The mapping of this resource.
     */
    protected final Map<String, String> resourceMapping;

    /**
     * Whether this resource has been modified since last flush.
     */
    protected boolean modified;

    /**
     * Initializes a new instance of the {@code Resource} class.
     */
    public Resource(){
        modified = true;
        resourceMapping = new HashMap<>();
    }

    /**
     * Initializes a new instance of the {@code Resource} class with specified mapping.
     * @param mapping The resource mapping.
     */
    public Resource(Map<String, String> mapping){
        modified = true;
        resourceMapping = new HashMap<>(mapping);
    }

    /**
     * Gets the value of a field.
     * @param field The name of the field.
     * @return The value of the field if present, otherwise {@code null}.
     */
    public String getField(String field){
        return new String(resourceMapping.get(field).getBytes(), StandardCharsets.UTF_8);
    }

    /**
     * Sets the value of a field.
     * May be used to create a new field.
     * @param field The name of the field.
     * @param value The value of the field.
     */
    public void setField(String field, String value){
        modified = true;
        resourceMapping.put(field, value);
    }

    /**
     * Gets the mapping of this resource.
     * @return The mapping of this resource.
     */
    public Map<String, String> getMapping(){
        return Collections.unmodifiableMap(resourceMapping);
    }

    /**
     * Converts this instance to json format.
     * @return A json representation of this object.
     */
    public Object toJson(){
        return new JSONObject(resourceMapping);
    }

    /**
     * Creates a new instance from redis database.
     * @param resName The resource name.
     * @return The resource value.
     */
    public static Resource fromDatabase(String resName){
        String key = "resource@" + resName;
        Jedis jedis = Utils.getJedis();
        Resource res = new Resource(jedis.hgetAll(key));
        res.modified = false;
        jedis.close();
        return res;
    }

    /**
     * Save this resource to database.
     * @param resName The resource name.
     */
    public void save(String resName){
        String key = "resource@" + resName;
        Jedis jedis = Utils.getJedis();
        resourceMapping.forEach((k,v) -> jedis.hset(key, k, v));
        jedis.close();
    }
}
