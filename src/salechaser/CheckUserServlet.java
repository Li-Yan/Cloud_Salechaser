package salechaser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

public class CheckUserServlet extends HttpServlet {

	private static final long serialVersionUID = 1561454411586813548L;
	private static final String url_facebook_graph = "https://graph.facebook.com/";
	
	private String searchUser(String facebookID) {
		String response = "";
		String line;
		try {
			String urlString = url_facebook_graph + facebookID + "?fields=name,picture";
			URL url = new URL(urlString);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			BufferedReader rd = new BufferedReader(new InputStreamReader(connection.getInputStream()));
	         while ((line = rd.readLine()) != null) {
	            response = response + line;
	         }
	         rd.close();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return response;
	}
	
	private boolean UpdateUserDB(String id, String name, String picture) {
		MemoryDB db = new MemoryDB();
		String query = "SELECT id FROM users WHERE id='" + id + "'";
		System.out.println(query);
		ResultSet result = db.ExecuteQuery(query);
		try {
			if (!result.next()) {
				query = "INSERT INTO users VALUES (";
				query += "'" + id + "', ";
				query += "'" + name + "', ";
				query += "'" + picture + "');";
			}
			else {
				query = "UPDATE users SET ";
				query += "name='" + name + "', ";
				query += "picture='" + picture + "' WHERE ";
				query += "id='" + id + "'";
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		db.Execute(query);
		db.DB_Close();
		return true;
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		String facebookID = request.getParameter("id");
		String resultJson = searchUser(facebookID);
		
		JSONObject object = new JSONObject(resultJson);
		String username = object.getString("name");
		String userpicture = object.getJSONObject("picture").getJSONObject("data").getString("url");
		UpdateUserDB(facebookID, username, userpicture);
		
		PrintWriter out=response.getWriter();
		out.write(resultJson);
		out.close();
	}
}
