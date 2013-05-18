package salechaser;

import java.io.IOException;
import java.io.PrintWriter;
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
	
	private boolean UpdateUserDB(String id, String name, String picture, String email) {
		MemoryDB db = new MemoryDB();
		String query = "SELECT id FROM users WHERE id='" + id + "'";
		ResultSet result = db.ExecuteQuery(query);
		try {
			if (!result.next()) {
				query = "INSERT INTO users VALUES (";
				query += "'" + id + "', ";
				query += "'" + name + "', ";
				query += "'" + picture + "', ";
				query += "'" + email + "');";
			}
			else {
				query = "UPDATE users SET ";
				query += "name='" + name + "', ";
				query += "picture='" + picture + "', ";
				query += "email='" + email + "' WHERE ";
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
		String facebookEmail = request.getParameter("email");
		
		String urlString = url_facebook_graph + facebookID + "?fields=name,picture";
		String resultJson = JavaHttpManager.JavaHttpGet(urlString);
		
		JSONObject object = new JSONObject(resultJson);
		String username = object.getString("name");
		String userpicture = object.getJSONObject("picture").getJSONObject("data").getString("url");
		UpdateUserDB(facebookID, username, userpicture, facebookEmail);
		
		PrintWriter out=response.getWriter();
		out.write(resultJson);
		out.close();
	}
}
