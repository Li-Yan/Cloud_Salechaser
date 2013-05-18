package salechaser;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.amazonaws.services.dynamodbv2.model.GetItemRequest;
import com.amazonaws.services.dynamodbv2.model.GetItemResult;
import com.amazonaws.services.dynamodbv2.model.PutItemRequest;


public class DynamoDB {
	static AmazonDynamoDBClient dynamolDB;
	
	public DynamoDB() {
		try {
			AWSCredentials credentials = new PropertiesCredentials(
					ShareServlet.class.getResourceAsStream("../AwsCredentials.properties"));
			dynamolDB = new AmazonDynamoDBClient(credentials);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public boolean PutItem(String tableName, HashMap<String, String> itemMap) {
		Map<String, AttributeValue> item = new HashMap<String, AttributeValue>();
		
		Iterator<Entry<String, String>> iter = itemMap.entrySet().iterator();
		while (iter.hasNext()) {
		    Map.Entry<String, String> entry = iter.next();
		    String attribute = entry.getKey();
		    String value = entry.getValue();
		    item.put(attribute, new AttributeValue().withS(value));
		} 
		
		PutItemRequest putItemRequest = new PutItemRequest()
			.withTableName(tableName)
			.withItem(item);
		dynamolDB.putItem(putItemRequest);
		
		return true;
	}
	
	public HashMap<String, String> GetItem(String tableName, HashMap<String, String> itemMap) {
		Map<String, AttributeValue> key = new HashMap<String, AttributeValue>();
		
		Iterator<Entry<String, String>> iter = itemMap.entrySet().iterator();
		while (iter.hasNext()) {
		    Map.Entry<String, String> entry = iter.next();
		    String attribute = entry.getKey();
		    String value = entry.getValue();
		    key.put(attribute, new AttributeValue().withS(value));
		}
		
		GetItemRequest getItemRequest = new GetItemRequest()
			.withTableName(tableName)
			.withKey(key);

		GetItemResult result = dynamolDB.getItem(getItemRequest);
		Map<String, AttributeValue> item = result.getItem();
		
		HashMap<String, String> resultMap = new HashMap<String, String>();
		itemMap.entrySet().iterator();
		while (iter.hasNext()) {
		    Map.Entry<String, String> entry = iter.next();
		    String attribute = entry.getKey();
		    String value = item.get(attribute).getS();
		    resultMap.put(attribute, value);
		    System.out.println(attribute + " " + value);
		}
		
		return resultMap;
	}
}
