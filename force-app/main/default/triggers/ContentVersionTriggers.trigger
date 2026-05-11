trigger ContentVersionTriggers on ContentVersion (after insert) {
    
    Switch on trigger.operationType{
        When AFTER_INSERT {
            ContentVersionHandler.relateAttachment(trigger.new);
        }
    }
}