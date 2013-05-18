package salechaser;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.util.Streams;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.Bucket;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.PutObjectRequest;

public class ShareServlet extends HttpServlet {

	private static final long serialVersionUID = -9088787724725266951L;
	private static final String BUCKET_NAME = "salechaser";
	private static final String CLOUDFRONT_URL = "http://d1ytnmsoxy5l7w.cloudfront.net/";
	
	static AmazonS3Client s3;
	
	private boolean validJPG(String fileName) {
		if (fileName.length() < 5) {
			return false;
		}
		if (fileName.substring(fileName.length() - 4).equalsIgnoreCase(".jpg")) {
			return true;
		}
		return false;
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		
		AWSCredentials credentials = new PropertiesCredentials(
				ShareServlet.class.getResourceAsStream("../AwsCredentials.properties"));

		String returnString = "";
		FileOutputStream outStream = null;
		File file = null;
		boolean bucketExist = false;
		
		String facebookID = null;
		String facebookName = null;
		String shareID = null;
		String itemString = null;
		String priceString = null;
		String addressString = null;
		String commentString = null;
		String latitudeString = null;
		String longitudeString = null;
		String[] shareStrings = null;
		
		boolean isMulti = ServletFileUpload.isMultipartContent(request);
		if (isMulti) {
			ServletFileUpload upload = new ServletFileUpload();
			try {
				FileItemIterator iter = upload.getItemIterator(request);
				while (iter.hasNext()) {
					FileItemStream item = iter.next();
					InputStream inputStream = item.openStream();
					if (item.isFormField()) {
						String fieldName = item.getFieldName();
						if (fieldName.equalsIgnoreCase("share_parameter")) {
							shareStrings = Streams.asString(inputStream).trim().split(",");
						}
						else if (fieldName.equalsIgnoreCase("share_item_textField")) {
							itemString = Streams.asString(inputStream);
						}
						else if (fieldName.equalsIgnoreCase("share_price_textField")) {
							priceString = Streams.asString(inputStream);
						}
						else if (fieldName.equalsIgnoreCase("share_address_textField")) {
							addressString = Streams.asString(inputStream);
						}
						else if (fieldName.equalsIgnoreCase("share_comment_textArea")) {
							commentString = Streams.asString(inputStream);
						}
					} else {
						String fileName = item.getName();
						if (fileName != null && validJPG(fileName)) {
							file = File.createTempFile(fileName, "");
							file.deleteOnExit();
							outStream = new FileOutputStream(file);
							byte buffer[] = new byte[1024];
							int len = 0;
							while ((len = inputStream.read(buffer)) > 0) {
								outStream.write(buffer, 0, len);
							}
							returnString = "Share Succeeds!";
						}
						else {
							if ((fileName != null) && (!fileName.equalsIgnoreCase(""))) {
								returnString = "Only support JPG file!";
								response.sendRedirect("index.jsp?share=" + returnString);
								return;
							}
							else {
								returnString = "Share Succeeds!";
							}
						}
					}
					inputStream.close();
				}
			} catch (FileUploadException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		facebookID = shareStrings[0];
		shareID = String.valueOf(Calendar.getInstance().getTimeInMillis());
		facebookName = shareStrings[1];
		latitudeString = shareStrings[2];
		longitudeString = shareStrings[3];
		
		if (file != null) {
			s3 = new AmazonS3Client(credentials);
			List<Bucket> list = s3.listBuckets();
			for (Bucket bucket : list) {
				if (BUCKET_NAME.equals(bucket.getName())) {
					bucketExist = true;
				}
			}
			if (!bucketExist) {
				s3.createBucket(BUCKET_NAME);
			}
			PutObjectRequest putRequest = new PutObjectRequest(BUCKET_NAME, shareID + "_" + facebookID + ".jpg", file);
			putRequest.setCannedAcl(CannedAccessControlList.PublicRead);
			s3.putObject(putRequest);
			outStream.close();
			s3.shutdown();
		}
		
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy-HH:mm");
		MemoryDB db = new MemoryDB();
		String query = "INSERT INTO share VALUES (";
		query += "'" + facebookID + "', ";
		query += "'" + facebookName + "', ";
		query += "'" + shareID + "', ";
		query += "'" + itemString.replaceAll("\\'", "\\\\'") + "', ";
		query += "'" + priceString.replaceAll("\\'", "\\\\'") + "', ";
		query += "'" + addressString.replaceAll("\\'", "\\\\'") + "', ";
		query += "'" + commentString.replaceAll("\\'", "\\\\'") + "', ";
		if (file != null) {
			query += "'" + CLOUDFRONT_URL + shareID + "_" + facebookID + ".jpg', ";
		}
		else {
			query += "'" + CLOUDFRONT_URL + "default.jpg', ";
		}
		query += "'" + simpleDateFormat.format(Calendar.getInstance().getTime()) + "', ";
		query += latitudeString + ", ";
		query += longitudeString + ")";
		db.Execute(query);
		
		//Send email to all other followers
		String messageContentString = facebookName + " shares a new item!!!\n";
		messageContentString += "Item: " + itemString + "\n";
		messageContentString += "Price: " + priceString + "\n";
		messageContentString += "Address: " + addressString + "\n";
		messageContentString += "Comment: " + commentString + "\n";
		if (file != null) {
			messageContentString += "Picture: " + CLOUDFRONT_URL + shareID + "_" + facebookID + ".jpg\n";
		}
		messageContentString += "\n\nBy Salechaser";
		SendEmail.SendToAllFollower(facebookID, messageContentString);
		
		response.sendRedirect("index.jsp?share_result=" + returnString);
	}
}
