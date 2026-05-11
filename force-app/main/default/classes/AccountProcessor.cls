//Create an Abstract Base Class
public abstract class AccountProcessor {
    
    // Concrete method (has body)
    public void processAccounts() {
        
        List<Account> accList = fetchAccounts();
        
        for(Account acc : accList) {
            processSingleAccount(acc);
        }
    }
    
    // Abstract method (child MUST implement)
    protected abstract void processSingleAccount(Account acc);
    
    // Virtual method (child MAY override)
    protected virtual List<Account> fetchAccounts() {
        return [SELECT Id, Name, Industry FROM Account LIMIT 5];
    }
}