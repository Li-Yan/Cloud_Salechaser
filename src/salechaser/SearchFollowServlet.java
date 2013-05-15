package salechaser;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

public class SearchFollowServlet extends HttpServlet {

	private static final long serialVersionUID = -1634502873430193186L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		
		String facebookID = request.getParameter("id");
		boolean add_follow_string = Boolean.valueOf(request.getParameter("add_follow_string"));
		
		MemoryDB db = new MemoryDB();
		JSONArray jsonArray = new JSONArray();
		String query = "SELECT followeeID,followeeName FROM follow WHERE followerID='" + facebookID + "'";
		ResultSet result = db.ExecuteQuery(query);
		try {
			while (result.next()) {
				JSONObject object = new JSONObject();
				if (add_follow_string) {
					object.put("name", result.getString("followeeName") + " (followed)");
				}
				else {
					object.put("name", result.getString("followeeName"));
				}
				object.put("id", result.getString("followeeID"));
				jsonArray.put(object);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		db.DB_Close();
		
		PrintWriter out=response.getWriter();
		out.write(jsonArray.toString());
		out.close();
	}
}
