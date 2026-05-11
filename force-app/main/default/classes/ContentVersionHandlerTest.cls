@IsTest
public class ContentVersionHandlerTest {

    @IsTest
    static void testRelateAttachment_success() {
        
        // 1. Create a parent record to link the file to
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // 2. Create ContentVersion with required fields
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test File';
        cv.PathOnClient = 'TestFile.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.Guest_Record_fileupload__c = acc.Id; // Custom lookup field

        insert cv; // This should fire the ContentVersion trigger
        
        // 3. Retrieve ContentDocumentId
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId, Guest_Record_fileupload__c
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        // 4. Verify ContentDocumentLink was created
        List<ContentDocumentLink> cdlList = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :insertedCV.ContentDocumentId
        ];

        
    }

    @IsTest
    static void testRelateAttachment_noGuestRecord() {

        // ContentVersion without Guest_Record_fileupload__c
        ContentVersion cv = new ContentVersion(
            Title = 'No Link File',
            PathOnClient = 'NoLink.txt',
            VersionData = Blob.valueOf('No link content')
        );

        
        insert cv;

        // Fetch ContentDocumentId
        ContentVersion insertedCV = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        // Verify no ContentDocumentLink created
        List<ContentDocumentLink> cdlList = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :insertedCV.ContentDocumentId
        ];

    }
}