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

public class SearchShareServlet extends HttpServlet {
	
	private static final long serialVersionUID = -4316296569123903121L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		
		String userID = request.getParameter("id");
		
		JSONArray jsonArray = new JSONArray();
		MemoryDB db = new MemoryDB();
		String query = "SELECT * FROM share WHERE userID='" + userID + "' ORDER BY shareID DESC";
		ResultSet result = db.ExecuteQuery(query);
		try {
			while (result.next()) {
				JSONObject object = new JSONObject();
				object.put("userID", result.getString("userID"));
				object.put("userName", result.getString("userName"));
				object.put("item", result.getString("item"));
				object.put("price", result.getString("price"));
				object.put("address", result.getString("address"));
				object.put("comment", result.getString("comment"));
				object.put("picture", result.getString("picture"));
				object.put("date", result.getString("date"));
				object.put("latitude", result.getDouble("latitude"));
				object.put("longitude", result.getDouble("longitude"));
				jsonArray.put(object);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		PrintWriter out = response.getWriter();
		out.write(jsonArray.toString());
		out.close();
	}
}
