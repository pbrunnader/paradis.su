package task2;

import java.util.List;
import java.util.ArrayList;

public class MoneyTransfer implements IAction, Runnable {
	int amount = 0;
	BankAccount fromAccount = null;
	BankAccount toAccount = null;
	List<Long> accountList = new ArrayList<Long>();
	
	public MoneyTransfer(int amount, BankAccount fromAccount, BankAccount toAccount)
	{
		this.amount = amount;
		this.fromAccount = fromAccount;
		this.toAccount = toAccount;	
		if( this.fromAccount.getObjectId() < this.toAccount.getObjectId() ) {
			accountList.add(this.fromAccount.getObjectId());
			accountList.add(this.toAccount.getObjectId());
		}else{
			accountList.add(this.toAccount.getObjectId());
			accountList.add(this.fromAccount.getObjectId());
		}
	}
	
	public void execute() {
		int balance = fromAccount.getBalance();
		balance = balance - amount;
		fromAccount.setBalance(balance);
		balance = toAccount.getBalance();
		balance = balance + amount;		
		toAccount.setBalance(balance);
	}
	
	public void run() {
		Database.transaction(this);
	}
	
	public List<Long> getKeys() {
		return accountList;
	}
}

