package memo.share;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Vector;

/**
 * Represents the collection of files.
 */
public final class FileCollection {
    /**
     * Single files.
     */
    private final Collection<PublicFile> singleFiles;
    /**
     * Series.
     */
    private final Collection<Series> series;

    /**
     * Initializes a new instance of the {@code FileCollection} class.
     */
    public FileCollection(){
        singleFiles = new Vector<>();
        series = new Vector<>();
    }

    /**
     * Add a single file.
     * @param file The file to add.
     */
    public void addSingleFile(PublicFile file){
        singleFiles.add(file);
    }

    /**
     * Add a series of files.
     * @param series The series to add.
     */
    public void addSeries(Series series){
        this.series.add(series);
    }

    /**
     * Gets a series.
     * @param name The name of the series.
     * @return The series if present, otherwise {@code null}.
     */
    public Series getSeries(String name){
        for (Series series: series){
            if (series.getName().equals(name)) return series;
        }
        return null;
    }

    /**
     * Converts this object to json format.
     * @return A json representation of this object.
     */
    public Object toJson(){
        JSONObject json = new JSONObject();
        json.put("files", new JSONArray(
                singleFiles.stream().map(PublicFile::toJson).toArray()
        ));
        json.put("series", new JSONArray(
                series.stream().map(Series::toJson).toArray()
        ));
        return json;
    }

    /**
     * Gets all of the files in this instance.
     * @return All files, including those which is in series.
     */
    public Collection<PublicFile> allFiles(){
        ArrayList<PublicFile> files = new ArrayList<>(singleFiles);
        for (Series series: series){
            files.addAll(series.getFiles());
        }
        return files;
    }
}
