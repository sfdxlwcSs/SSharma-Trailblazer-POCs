@isTest
private class LeadConversionHandlerTest {

    @testSetup
    static void setupData() {
        // Ensure Person Account Record Type exists in org
        Id personAccountRTId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        System.assertNotEquals(null, personAccountRTId, 
            'Person Account Record Type not found');
    }

    @isTest
    static void testPersonAccountCreatedOnLeadConversion() {
        Lead testLead = new Lead(
            FirstName   = 'Test',
            LastName    = 'User',
            Company     = 'Individual',
            Email       = 'test.user@example.com',
            MobilePhone = '9876543210',
            Status      = 'Open'
        );
        insert testLead;

        LeadStatus convertedStatus = [
            SELECT MasterLabel FROM LeadStatus 
            WHERE IsConverted = TRUE LIMIT 1
        ];

        Test.startTest();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(testLead.Id);
            lc.setConvertedStatus(convertedStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true);
            Database.convertLead(lc);
        Test.stopTest();

        Lead convertedLead = [
            SELECT IsConverted, ConvertedAccountId 
            FROM Lead WHERE Id = :testLead.Id
        ];

        System.assert(convertedLead.IsConverted, 'Lead should be converted');
        
        Account pa = [
            SELECT IsPersonAccount, FirstName, LastName 
            FROM Account WHERE Id = :convertedLead.ConvertedAccountId
        ];
        System.assert(pa.IsPersonAccount, 'Account should be a Person Account');
        System.assertEquals('Test', pa.FirstName);
        System.assertEquals('User', pa.LastName);
    }
}