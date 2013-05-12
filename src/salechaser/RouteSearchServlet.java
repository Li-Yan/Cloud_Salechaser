package salechaser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

public class RouteSearchServlet extends HttpServlet  {

	private static final long serialVersionUID = 6225911314483416295L;
	private static final String api_google_distance_matrix = "http://maps.googleapis.com/maps/api/distancematrix/json?";
	
	private String GetDistances(double[] latitudes, double[] longitudes) {
		String originsString = "origins=";
		String destinationsString = "&destinations=";
		for (int i = 0; i < latitudes.length; i++) {
			if (i > 0) {
				originsString += "|";
				destinationsString += "|";
			}
			originsString += latitudes[i] + "," + longitudes[i];
			destinationsString += latitudes[i] + "," + longitudes[i];
		}
		
		String response = "";
		String line;
		try {
			String urlString = api_google_distance_matrix + originsString + destinationsString 
					+ "&language=en-EN&sensor=false";
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
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		
		PrintWriter out=response.getWriter();
		JSONObject retureObject = new JSONObject();
		String locationWord = request.getParameter("location");
		String searchWord = request.getParameter("search");
		String chooseWord = request.getParameter("choose");
		ArrayList<String> locationStrings = SaleStore.getStoresLocation(searchWord, chooseWord);
		
		//Initialization
		double[] latitudes = new double[locationStrings.size() + 1];
		double[] longitudes = new double[locationStrings.size() + 1];
		String[] locationWords = locationWord.substring(1, locationWord.length() - 2).split(",");
		latitudes[0] = Double.parseDouble(locationWords[0]);
		longitudes[0] = Double.parseDouble(locationWords[1]);
		for (int i = 0; i < locationStrings.size(); i++) {
			locationWords = locationStrings.get(i).split(",");
			latitudes[i + 1] = Double.parseDouble(locationWords[0]);
			longitudes[i + 1] = Double.parseDouble(locationWords[1]);
		}
		long[][] durationMatrix = new long[locationStrings.size() + 1][locationStrings.size() + 1];
		Distance[][] distanceMatrix = new Distance[locationStrings.size() + 1][locationStrings.size() + 1];
		
		//Get duration
		String distanceJSON = GetDistances(latitudes, longitudes);
		
		//Parse JSON
		JSONObject mainObject = new JSONObject(distanceJSON);
		retureObject.put("status", mainObject.getString("status"));
		if (!mainObject.getString("status").equalsIgnoreCase("OK")) {
			out.write(retureObject.toString());
			out.close();
			return;
		}
		JSONArray matrixArray = mainObject.getJSONArray("rows");
		for (int i = 0; i < matrixArray.length(); i++) {
			JSONArray rowArray = matrixArray.getJSONObject(i).getJSONArray("elements");
			for (int j = 0; j < rowArray.length(); j++) {
				JSONObject elementObject = rowArray.getJSONObject(j);
				Distance distance = new Distance(elementObject);
				distanceMatrix[i][j] = distance; 
				durationMatrix[i][j] = distance.durationValue;
			}
		}
		
		//Calculate the best route
		TSP tsp = new TSP(durationMatrix);
		ArrayList<Integer> routeList = tsp.DynamicProgramming();
		routeList.add(0);
		
		JSONArray jsonArray = new JSONArray();
		for (int i = 0; i < routeList.size() - 1; i++) {
			JSONObject jsonObject = new JSONObject();
			int fromIndex = routeList.get(i);
			int toIndex = routeList.get(i + 1);
			jsonObject.put("from", fromIndex);
			jsonObject.put("to", toIndex);
			jsonObject.put("distanceText", distanceMatrix[fromIndex][toIndex].distanceText);
			jsonObject.put("distanceValue", distanceMatrix[fromIndex][toIndex].distanceValue);
			jsonObject.put("durationText", distanceMatrix[fromIndex][toIndex].durationText);
			jsonObject.put("durationValue", distanceMatrix[fromIndex][toIndex].durationValue);
			jsonArray.put(jsonObject);
		}
		retureObject.put("route", jsonArray);
		out.write(retureObject.toString());
		out.close();
	}
}
