package salechaser;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

import javax.mail.*;
import javax.mail.internet.*;

public class SendEmail {
	public static void postMail(String recipient, String subject,
			String message, String from) throws MessagingException {
		Properties props = new Properties();
		props.put("mail.smtp.host", "smtp.gmail.com");
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtp.port", "587");

		Authenticator authenticator = new Authenticator() {
			public PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication("salechaser.cu@gmail.com",
						"12345678abcde");
			}
		};

		Session session = Session.getDefaultInstance(props, authenticator);
		Message msg = new MimeMessage(session);
		InternetAddress addressFrom = new InternetAddress(from);
		msg.setFrom(addressFrom);
		InternetAddress addressTo = new InternetAddress(recipient);
		msg.setRecipient(Message.RecipientType.TO, addressTo);
		msg.setSubject(subject);
		msg.setContent(message, "text/plain");

		Transport.send(msg);
	}
	
	public static boolean SendToAllFollower(String facebookID, String content) {
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
					postMail(email, "Salechaser: New Share Posted", content, "salechaser.cu@gmail.com");
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (MessagingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		db.DB_Close();
		return true;
	}

}