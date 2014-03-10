package task2;

public class Program {

	private void runTest() {
		for (int i = 0; i < 10000; i++) {
			BankAccount account1 = new BankAccount();
			account1.setBalance(200);
			BankAccount account2 = new BankAccount();
			account2.setBalance(200);

			Thread thread1 = new Thread(new MoneyTransfer(100, account1, account2));
			Thread thread2 = new Thread(new MoneyTransfer(100, account1, account2));
			thread1.start();
			thread2.start();
			try {
				thread1.join();
				thread2.join();
				if (account1.getBalance() != 0 || account2.getBalance() != 400)
					System.out.println("The account balances are incorrectly: " + account1.getBalance() + 
						" and " + account2.getBalance() + ".");
			}
			catch (InterruptedException exception) {
				System.out.println(exception);
			}
		}
	}
	
	public static void main(String[] args) {
		Program program = new Program();
		program.runTest();
	}
}

