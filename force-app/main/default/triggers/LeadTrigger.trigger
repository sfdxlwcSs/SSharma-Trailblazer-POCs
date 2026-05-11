trigger LeadTrigger on Lead (before update) {
    
    List<Lead> leadsBeingConverted = new List<Lead>();
    
    for (Lead newLead : Trigger.new) {
        Lead oldLead = Trigger.oldMap.get(newLead.Id);
        
        // Fire only when IsConverted flips from false → true
        //if (newLead.IsConverted && !oldLead.IsConverted) {
            leadsBeingConverted.add(newLead);
       // }
    }
    
    if (!leadsBeingConverted.isEmpty()) {
        LeadConversionHandler.convertToPersonAccount(leadsBeingConverted);
    }
}