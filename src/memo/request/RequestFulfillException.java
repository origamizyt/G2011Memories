package memo.request;

/**
 * Represents the errors occurs in method {@code Request.fulfill}.
 * @see Request#fulfill()
 */
public class RequestFulfillException extends Exception {
    /**
     * Initializes a new instance of the {@code RequestFulfillException} class.
     * @param cause The cause of this exception.
     */
    public RequestFulfillException(Throwable cause){
        super(cause);
    }
}
