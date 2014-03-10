package task1;

public class MoneyTransfer implements IAction, Runnable {
	int amount = 0;
	BankAccount fromAccount = null;
	BankAccount toAccount = null;
	
	public MoneyTransfer(int amount, BankAccount fromAccount, BankAccount toAccount)
	{
		this.amount = amount;
		this.fromAccount = fromAccount;
		this.toAccount = toAccount;	
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
}

