package salechaser;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

public class SearchAddressServlet extends HttpServlet {

	private static final long serialVersionUID = 5387452153778571961L;
	private static final String url_google_address = "http://maps.googleapis.com/maps/api/geocode/json?address=";
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		String address = request.getParameter("address");
		String urlString = url_google_address + address + "&sensor=false";
		String result = JavaHttpManager.JavaHttpGet(urlString);
		
		JSONObject object = new JSONObject(result).getJSONArray("results").getJSONObject(0);
		String resultAddress = object.getString("formatted_address");
		JSONObject locationObject = object.getJSONObject("geometry").getJSONObject("location");
		
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("formatted_address", resultAddress);
		jsonObject.put("latitude", locationObject.getDouble("lat"));
		jsonObject.put("longitude", locationObject.getDouble("lng"));
		
		PrintWriter out=response.getWriter();
		out.write(jsonObject.toString());
		out.close();
	}
}
