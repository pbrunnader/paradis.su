// package task2;

import java.util.Map;
import java.util.HashMap;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class Database {
	
	private static long objectIdCounter = 0;
	private static Map<Long, Integer> integerData = new HashMap<Long, Integer>();
	private static Lock lock = new ReentrantLock(false);

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
		lock.lock();
		action.execute();
		lock.unlock();
	}
}
