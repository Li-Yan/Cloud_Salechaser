package salechaser;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import com.amazonaws.AmazonClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient;
import com.amazonaws.services.simpleemail.model.Body;
import com.amazonaws.services.simpleemail.model.Content;
import com.amazonaws.services.simpleemail.model.Destination;
import com.amazonaws.services.simpleemail.model.Message;
import com.amazonaws.services.simpleemail.model.SendEmailRequest;


public class SendEmailAWS {
	public static void send(String to, String subject, String bodycontent, String mode) throws IOException {
		AWSCredentials credentials = new PropertiesCredentials(
				SendEmailAWS.class.getResourceAsStream("../AwsCredentials.properties"));
		
		SendEmailRequest request = new SendEmailRequest()
				.withSource("salechaser.cu@gmail.com");

		List<String> toAddresses = new ArrayList<String>();
		toAddresses.add(to);
		Destination dest = new Destination().withToAddresses(toAddresses);
		request.setDestination(dest);

		Content subjContent = new Content().withData(subject);
		Message msg = new Message().withSubject(subjContent);

		// Include a body in both text and HTML formats.
		Content mailContent = new Content().withData(bodycontent);
		Body body = null;
		if (mode.equalsIgnoreCase("text")) {
			body = new Body().withText(mailContent);
		}
		else if (mode.equalsIgnoreCase("html")) {
			body = new Body().withHtml(mailContent);
		}
		msg.setBody(body);

		request.setMessage(msg);

		// Set AWS access credentials.
		AmazonSimpleEmailServiceClient client = new AmazonSimpleEmailServiceClient(
				credentials);

		// Call Amazon SES to send the message.
		try {
			client.sendEmail(request);
		} catch (AmazonClientException e) {
			System.out.println(e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public static boolean SendToAllFollower(String facebookID, String content, String mode) {
		MemoryDB db = new MemoryDB();
		HashSet<String> followerIDSet = new HashSet<String>();
		String query = "SELECT followerID FROM follow WHERE followeeID='" + facebookID + "'";
		ResultSet result = db.ExecuteQuery(query);
		try {
			while (result.next()) {
				followerIDSet.add(result.getString("followerID"));
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		for (String followerID : followerIDSet) {
			query = "SELECT email FROM users WHERE id='" + followerID + "'";
			result = db.ExecuteQuery(query);
			try {
				while (result.next()) {
					String email = result.getString("email");
					send(email, "Salechaser: New Share Posted", content, mode);
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		db.DB_Close();
		return true;
	}
}
