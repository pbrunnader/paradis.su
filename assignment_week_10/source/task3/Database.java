package task2;

import java.util.Map;
import java.util.HashMap;

import java.util.List;
import java.util.ArrayList;

public class Database {
	
	private static long objectIdCounter = 0;
	private static Map<Long, Integer> integerData = new HashMap<Long, Integer>();
	private static Map<Long, Object> lockList = new HashMap<Long, Object>();
	private static Object lock = new Object();

	public static long createKey(long objectId, byte propertyId) {
		return objectId * 256 + propertyId;
	}
	
	public static long getUniqueObjectId() {
		return objectIdCounter++;
	}
	
	public static int readInteger(long objectId, byte propertyId) {
		long key = createKey(objectId, propertyId);
		return integerData.get(key);
	}

	public static void writeInteger(long objectId, byte propertyId, int data) {
		long key = createKey(objectId, propertyId);
		integerData.put(key, data);
	}

	public static void transaction(IAction action) {
		List<Long> accountList = action.getKeys();

		Object lock0 = null;
		Object lock1 = null;

		if( !lockList.containsKey(accountList.get(0)) || !lockList.containsKey(accountList.get(1)) )
			synchronized (lock) {
				if(!lockList.containsKey(accountList.get(0)))
					lockList.put(accountList.get(0), new Object());
				if(!lockList.containsKey(accountList.get(1)))
					lockList.put(accountList.get(1), new Object());
			}
		
		lock0 = lockList.get(accountList.get(0));
		lock1 = lockList.get(accountList.get(1));

		synchronized (lock0) {
			synchronized (lock1) {
				action.execute();
			}
		}
	}
}
