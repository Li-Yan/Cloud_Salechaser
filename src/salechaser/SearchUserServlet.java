package salechaser;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

public class SearchUserServlet extends HttpServlet {

	private static final long serialVersionUID = -1116175608904852753L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		String searchString = request.getParameter("search");
		String facebookID = request.getParameter("id");
		
		MemoryDB db = new MemoryDB();
		
		//Get searched user
		ArrayList<String> idList = new ArrayList<String>();
		ArrayList<String> nameList = new ArrayList<String>();
		String query = "SELECT id,name FROM users WHERE name LIKE '%" + searchString + "%'";
		ResultSet result = db.ExecuteQuery(query);
		try {
			while (result.next()) {
				String s = result.getString("id");
				if (s.equals(facebookID)) {
					nameList.add(result.getString("name") + " (self)");
				}
				else {
					nameList.add(result.getString("name"));
				}
				idList.add(s);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//Check followed all not
		HashSet<String> idSet = new HashSet<String>();
		query = "SELECT followeeID FROM follow WHERE followerID='" + facebookID + "'";
		result = db.ExecuteQuery(query);
		try {
			while (result.next()) {
				idSet.add(result.getString("followeeID"));
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		db.DB_Close();
		
		for (int i = 0; i < idList.size(); i++) {
			if (idSet.contains(idList.get(i))) {
				String s = nameList.get(i) + " (followed)";
				nameList.set(i, s);
			}
		}
		
		JSONArray jsonArray = new JSONArray();
		for (int i = 0; i < idList.size(); i++) {
			JSONObject object = new JSONObject();
			object.put("id", idList.get(i));
			object.put("name", nameList.get(i));
			jsonArray.put(object);
		}
		
		PrintWriter out = response.getWriter();
		out.write(jsonArray.toString());
		out.close();
	}
}
