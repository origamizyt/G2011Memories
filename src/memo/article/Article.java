package memo.article;

import com.itextpdf.io.font.PdfEncodings;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfDocumentInfo;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Text;
import memo.Config;
import memo.misc.Utils;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.util.Arrays;
import java.util.Comparator;

public final class Article {
    /**
     * The content of this article.
     */
    private String content = null;
    /**
     * The path to this article.
     */
    private final String path;
    /**
     * The properties of this instance.
     */
    private final ArticleProperties properties;

    /**
     * Initializes a new instance of the {@code Article} class.
     * @param path The path to the article directory.
     * @param properties The properties of the article.
     */
    public Article(String path, ArticleProperties properties) {
        this.path = path;
        this.properties = properties;
    }

    /**
     * Gets the path to this article.
     * @return The path to this article.
     */
    public String getPath(){
        return path;
    }

    /**
     * Gets the string content (raw) of this article.
     * @return The string content in plain text.
     * @throws IOException If an I/O error occurs.
     */
    public String getContent() throws IOException {
        if (content == null) {
            File articleXML = new File(path, "article.xml");
            if (articleXML.exists())
                content = Utils.readFile(articleXML.getAbsolutePath());
        }
        return content;
    }

    /**
     * Put the contents of this article into an xml file.
     * This is an one-time operation, which means it will fail
     * if this article already has content.
     * @param content The contents of this article in xml format.
     * @throws IOException I/O error.
     */
    public void putContent(String content) throws IOException {
        File articleXML = new File(path, "article.xml");
        if (articleXML.exists()) return;
        Utils.writeFile(articleXML.getAbsolutePath(), content);
        this.content = content;
    }

    /**
     * Gets the properties of this article.
     * @return The properties of this article.
     */
    public ArticleProperties getProperties(){
        return properties;
    }

    /**
     * Gets the images of this article.
     * @return The images of this article.
     */
    public File[] getImages(){
        File dir = new File(path);
        File[] files = dir.listFiles((dir1, name) -> {
            String contentType = HttpURLConnection.guessContentTypeFromName(name);
            if (contentType == null) return false;
            return contentType.startsWith("image/");
        });
        if (files == null) return null;
        return Arrays.stream(files).sorted((f1, f2) -> {
            int indexF1 = Integer.parseInt(f1.getName().split("\\.")[0]);
            int indexF2 = Integer.parseInt(f2.getName().split("\\.")[0]);
            return Integer.compare(indexF1, indexF2);
        }).toArray(File[]::new);
    }

    /**
     * Gets a image of specific index.
     * @param index The index to get.
     * @return The image if present.
     */
    public File getImage(int index){
        File[] images = getImages();
        if (images == null) return null;
        return images[index];
    }

    /**
     * Parses the xml file to a w3c xml document.
     * @return A xml document.
     * @throws IOException I/O error.
     * @throws SAXException SAX error.
     */
    private org.w3c.dom.Document parseXML() throws IOException, SAXException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder;
        try {
            builder = factory.newDocumentBuilder();
        }
        catch (ParserConfigurationException e) { return null; }
        return builder.parse(new File(path, "article.xml"));
    }

    /**
     * Generates a pdf version of this article.
     * @throws IOException I/O error.
     * @throws SAXException SAX error.
     */
    public void generatePDF() throws IOException, SAXException {
        org.w3c.dom.Document xmlDocument = parseXML();
        if (xmlDocument == null) return;
        NodeList nodes = xmlDocument.getDocumentElement().getChildNodes();
        File file = new File(path, "article.pdf");
        PdfWriter writer = new PdfWriter(file);
        PdfDocument pdfDocument = new PdfDocument(writer);
        Document document = new Document(pdfDocument);
        PdfFont normal = PdfFontFactory.createFont(Config.FONT_PATH, PdfEncodings.IDENTITY_H,true);
        for (int i = 0; i < nodes.getLength(); i++){
            Node node = nodes.item(i);
            switch (node.getNodeName()) {
                case "headline":
                    Paragraph headline = new Paragraph();
                    headline.setFont(normal).setFontSize(20);
                    headline.add(node.getTextContent());
                    document.add(headline);
                    break;
                case "image":
                    File imageFile = getImage(Integer.parseInt(node.getAttributes().getNamedItem("index").getNodeValue()));
                    if (imageFile == null) continue;
                    Paragraph imageParagraph = new Paragraph();
                    Image image = new Image(ImageDataFactory.create(imageFile.getAbsolutePath()));
                    image.setWidth(300);
                    imageParagraph.add(image);
                    Text newLine = new Text("\n");
                    Text description = new Text(node.getAttributes().getNamedItem("desc").getNodeValue());
                    description.setFont(normal);
                    description.setFontColor(ColorConstants.GRAY);
                    imageParagraph.add(newLine);
                    imageParagraph.add(description);
                    document.add(imageParagraph);
                    break;
                case "paragraph":
                    Paragraph paragraph = new Paragraph();
                    paragraph.setFont(normal);
                    paragraph.setFirstLineIndent(16);
                    paragraph.add(node.getTextContent());
                    document.add(paragraph);
                    break;
            }
        }
        PdfDocumentInfo info = pdfDocument.getDocumentInfo();
        info.setTitle(getProperties().getTitle());
        info.setAuthor(getProperties().getAuthor().getUserName());
        document.flush();
        document.close();
        writer.close();
    }

    /**
     * Gets the pdf version of this article.
     * @return The pdf file of this article.
     * @throws IOException I/O error.
     * @throws SAXException SAX error.
     */
    public File getPDF() throws IOException, SAXException {
        File pdf = new File(path, "article.pdf");
        if (!pdf.exists()) generatePDF();
        return pdf;
    }

    /**
     * Adds an image to this article.
     * @param extension The extension of the image.
     * @param imageData The data of the image.
     * @throws IOException I/O error.
     */
    public void addImage(String extension, byte[] imageData) throws IOException {
        String fileName = getProperties().getImageCount() + "." + extension;
        File image = new File(path, fileName);
        Utils.writeBinaryFile(image.getAbsolutePath(), imageData);
        getProperties().increaseImageCount();
        getProperties().saveProperties(new File(path, "article.json").getAbsolutePath());
    }
}
