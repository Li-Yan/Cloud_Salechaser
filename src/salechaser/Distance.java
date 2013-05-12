package salechaser;

import org.json.JSONObject;

public class Distance {
	public String distanceText;
	public long distanceValue;
	public String durationText;
	public long durationValue;
	
	public Distance() {
		distanceText = "";
		distanceValue = 0;
		durationText = "";
		durationValue = 0;
	}
	
	public Distance(JSONObject jsonObject) {
		JSONObject distanceObject = jsonObject.getJSONObject("distance");
		JSONObject durationObject = jsonObject.getJSONObject("duration");
		distanceText = distanceObject.getString("text");
		distanceValue = distanceObject.getLong("value");
		durationText = durationObject.getString("text");
		durationValue = durationObject.getLong("value");
	}
}
