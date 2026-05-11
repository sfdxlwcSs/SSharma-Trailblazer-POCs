public class LeadConversionHandler {
    
    // Replace with your org's Person Account Record Type Developer Name
    private static final String PERSON_ACCOUNT_RT = 'PersonAccount';
    
    public static void convertToPersonAccount(List<Lead> leads) {
        // Fetch Person Account Record Type Id
        Id personAccountRTId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get(PERSON_ACCOUNT_RT)
            .getRecordTypeId();
        
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        LeadStatus convertedStatus = [
            SELECT MasterLabel 
            FROM LeadStatus 
            WHERE IsConverted = TRUE 
            LIMIT 1
        ];
        
        for (Lead lead : leads) {
            // Step 1: Create Person Account manually
            Account personAccount = new Account(
                RecordTypeId   = personAccountRTId,
                FirstName      = lead.FirstName,
                LastName       = lead.LastName,
                PersonEmail    = lead.Email,
                PersonMobilePhone = lead.MobilePhone,
                Phone          = lead.Phone,
                BillingStreet  = lead.Street,
                BillingCity    = lead.City,
                BillingState   = lead.State,
                BillingPostalCode = lead.PostalCode,
                BillingCountry = lead.Country,
                Description    = lead.Description
            );
            insert personAccount;
            
            // Step 2: Set up lead conversion pointing to the Person Account
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setAccountId(personAccount.Id);
            
            // Person Accounts don't use a separate Contact — 
            // suppress Contact creation (it's merged into the Account)
            lc.setDoNotCreateOpportunity(true); // Set false if you want Opportunity
            lc.setConvertedStatus(convertedStatus.MasterLabel);
            lc.setBypassAccountDedupeCheck(false);
            lc.setBypassContactDedupeCheck(false);
            
            conversions.add(lc);
        }
        
        if (!conversions.isEmpty()) {
            List<Database.LeadConvertResult> results = 
                Database.convertLead(conversions, false);
            
            for (Database.LeadConvertResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        System.debug('Lead Conversion Error: ' + err.getMessage());
                    }
                }
            }
        }
    }
}