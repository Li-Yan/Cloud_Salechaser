package salechaser;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;


public class MemoryDB {
	private Connection dbConnection;
	
	public MemoryDB() {
		String dbName = "salechaser";
		String userName = "root";
		String password = "salechaser";
		String hostname = "salechaser.ccdolhqfikzh.us-east-1.rds.amazonaws.com";
		String port = "3306";
		String driver = "com.mysql.jdbc.Driver";
		String jdbcUrl = "jdbc:mysql://" + hostname + ":" + port + "/" + dbName;
		
		try {
			Class.forName(driver);
			dbConnection = DriverManager.getConnection(jdbcUrl, userName, password);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void DB_Close() {
		try {
			dbConnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void Table_Reset(String tableName) {
		if (tableName.equalsIgnoreCase("stores")) {
			Execute("DROP TABLE IF EXISTS stores;");
			Execute("CREATE TABLE stores (id VARCHAR(32), resultid INTEGER, name VARCHAR(256), "
				+ "address VARCHAR(256), phone VARCHAR(32), showImage VARCHAR(1024), postDate VARCHAR(64), "
				+ "expirationDate VARCHAR(64), dealTitle VARCHAR(1024), dealinfo VARCHAR(1024), "
				+ "URL VARCHAR(1024), latitude double, longitude double, date INTEGER, searchWord VARCHAR(1024));");
		}
		else if (tableName.equalsIgnoreCase("users")) {
			Execute("DROP TABLE IF EXISTS users;");
			Execute("CREATE TABLE users (id VARCHAR(32) PRIMARY KEY, name VARCHAR(64), picture VARCHAR(1024), mail VARCHAR(64))");
		}
		else if (tableName.equalsIgnoreCase("share")) {
			Execute("DROP TABLE IF EXISTS share;");
			Execute("CREATE TABLE share (userID VARCHAR(32), userName VARCHAR(64), shareID VARCHAR(32), " 
				+ "item VARCHAR(1024), price VARCHAR(32), address VARCHAR(1024), comment VARCHAR(1024), " 
				+ "picture VARCHAR(256), date VARCHAR(32), latitude double, longitude double)");
		}
		else if (tableName.equalsIgnoreCase("follow")) {
			Execute("DROP TABLE IF EXISTS follow;");
			Execute("CREATE TABLE follow (followerID VARCHAR(32), followeeID VARCHAR(32), followeeName VARCHAR(32))");
		}
	}
	
	public boolean DataExist(String Query) {
		ResultSet result = ExecuteQuery(Query);
		boolean exist = false;
		try {
			exist = result.next();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return exist;
	}
	
	public ResultSet ExecuteQuery(String Query) {
		ResultSet result = null;
		try {
			Statement statement = dbConnection.createStatement();
			result = statement.executeQuery(Query);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	public boolean Execute(String Query) {
		PreparedStatement preparedStatement;
		boolean succeed = true;
		try {
			preparedStatement = dbConnection.prepareStatement(Query);
			preparedStatement.execute();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			succeed = false;
		}
		return succeed;
	}
}
