package salechaser;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class FollowServlet extends HttpServlet {

	private static final long serialVersionUID = -1852614650953717179L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		PrintWriter out=response.getWriter();
		boolean isFollow = Boolean.valueOf(request.getParameter("follow"));
		String followerID = request.getParameter("followerID");
		String followeeID = request.getParameter("followeeID");
		String followeeName = request.getParameter("followeeName");
		
		if (followerID.equals(followeeID)) {
			if (isFollow) {
				out.write("You cannot follow yourself!");
			}
			else {
				out.write("You cannot unfollow yourself!");
			}
			out.close();
			return;
		}
		
		MemoryDB db = new MemoryDB();
		String query = "SELECT followerID FROM follow WHERE followerID='" + followerID + "' AND followeeID='" + followeeID +"'";
		boolean dataExit = db.DataExist(query);
		if ((dataExit) && (isFollow)) {
			out.write("You have already followed this user!");
		}
		else if ((dataExit) && (!isFollow)) {
			query = "DELETE FROM follow WHERE followerID='" + followerID + "' AND followeeID='" + followeeID +"'";
			db.Execute(query);
			out.write("OK");
		}
		else if ((!dataExit) && (isFollow)) {
			query = "INSERT INTO follow VALUES (";
			query += "'" + followerID + "', ";
			query += "'" + followeeID + "', ";
			query += "'" + followeeName + "')";
			db.Execute(query);
			out.write("OK");
		}
		else { //(!dataExit) && (!isFollow)
			out.write("You haven't followed this user!");
		}
		db.DB_Close();
		out.close();
		return;
	}
}
