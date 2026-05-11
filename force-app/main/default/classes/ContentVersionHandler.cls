public class ContentVersionHandler {
    
    public static void relateAttachment(List<ContentVersion> cvList){
        List <ContentDocumentLink> cdlList = new List <ContentDocumentLink>();
        if(cvList !=null && !cvList.isEmpty()){
            for (ContentVersion cvRecord : cvList) { 
                if (String.isNotBlank(cvRecord.Guest_Record_fileupload__c)) {
                    cdlList.add( new ContentDocumentLink(LinkedEntityId = cvRecord.Guest_Record_fileupload__c,
                                                         ContentDocumentId = cvRecord.ContentDocumentId));            
                }
            }
            
            if (!cdlList.isEmpty()) {        
                insert cdlList;       
            }
        }
        
    }
}