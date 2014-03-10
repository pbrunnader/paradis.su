package task1;

public class BankAccount {
	// Database references.
	private long objectId;
	private static final byte BALANCEID = 0;
	
	// Create a BankAccount object representing a new bank account.
	public BankAccount() {
		objectId = Database.getUniqueObjectId();
		// Initiate properties.
		Database.writeInteger(objectId, BALANCEID, 0);
	}
	
	// Create a BankAccount object representing an existing bank account.
	public BankAccount(long objectId)
	{
		this.objectId = objectId;
	}
	
	public long getObjectId() {
		return objectId;
	}
	
	public int getBalance() {
		return Database.readInteger(objectId, BALANCEID);
	}
	
	public void setBalance(int balance) {
		Database.writeInteger(objectId, BALANCEID, balance);
	}
}
