package salechaser;

import java.text.SimpleDateFormat;
import java.util.Calendar;

public class Initialization {

	public static void main(String[] args) {
		MemoryDB db = new MemoryDB();
		//db.Table_Reset("users");
		//db.Table_Reset("share");
		//db.Table_Reset("follow");
		db.DB_Close();
	}

}
