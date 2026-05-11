public class AccountIndustryUpdater extends AccountProcessor {
    
    // REQUIRED (because abstract)
    protected override void processSingleAccount(Account acc) {
        acc.Industry = 'Technology';
    }
    
    // OPTIONAL (because virtual)
    protected override List<Account> fetchAccounts() {
        return [SELECT Id, Name, Industry 
                FROM Account 
                WHERE Industry = NULL 
                LIMIT 5];
    }
}