/**
 * @description Controller for guest QR scanner functionality
 * Handles check-in operations for event attendees
 * @security without sharing - intentional for guest user access
 */
public without sharing class GuestQrScannerController {
    
    private static final String ERROR_QR_MISSING = 'QR value missing';
    private static final String ERROR_INVALID_QR = 'Invalid QR Code';
    private static final String ERROR_UPDATE_FAILED = 'Failed to update attendee';
    private static final String ERROR_CHECKOUT_TOO_SOON = ' must stay for at least 30 minutes before checking out';
    private static final String SUCCESS_CHECKIN = ' checked in successfully';
    private static final String SUCCESS_CHECKOUT = ' checked out successfully';
    private static final String INFO_ALREADY_CHECKED = ' already checked in';
    private static final Integer MIN_CHECKOUT_MINUTES = 30;
    
    /**
     * @description Checks in an attendee using their badge number from QR code
     * @param qrValue The badge number scanned from QR code
     * @return String Success or status message
     * @throws AuraHandledException for validation errors
     */
    @AuraEnabled
    public static String checkIn(String qrValue) {
        // Input validation
        if (String.isBlank(qrValue)) {
            throw new AuraHandledException(ERROR_QR_MISSING);
        }
        
        // Query for attendee - select only necessary fields
        List<Event_Attendee__c> attendees = queryAttendeeByBadgeNumber(qrValue);
        
        if (attendees.isEmpty()) {
            throw new AuraHandledException(ERROR_INVALID_QR);
        }
        
        Event_Attendee__c attendee = attendees[0];
        
        // Check if already checked in - handle check-out logic
        if (attendee.Checked_In__c == true) {
            // If already checked out, inform user
            if (attendee.Checked_Out__c == true) {
                return attendee.Name + INFO_ALREADY_CHECKED;
            }
            // Attempt to check out with time validation
            return performCheckOut(attendee);
        }
        
        // Perform check-in with error handling
        return performCheckIn(attendee);
    }
    
    /**
     * @description Queries attendee by badge number
     * @param badgeNumber The badge number to search for
     * @return List<Event_Attendee__c> Matching attendees (max 1)
     */
    @TestVisible
    private static List<Event_Attendee__c> queryAttendeeByBadgeNumber(String badgeNumber) {
        return [
            SELECT Id, Name, Checked_In__c, Checked_Out__c, Check_In_Time__c, Checked_Out_Time__c
            FROM Event_Attendee__c
            WHERE Badge_Number__c = :badgeNumber
            LIMIT 1
        ];
    }
    
    /**
     * @description Performs the check-in operation with error handling
     * @param attendee The attendee to check in
     * @return String Success message
     * @throws AuraHandledException if DML operation fails
     */
    @TestVisible
    private static String performCheckIn(Event_Attendee__c attendee) {
        try {
            attendee.Checked_In__c = true;
            attendee.Check_In_Time__c = System.now();
            attendee.Checked_Out__c = false;
            update attendee;
            return attendee.Name + SUCCESS_CHECKIN;
        } catch (DmlException e) {
            throw new AuraHandledException(ERROR_UPDATE_FAILED + ': ' + e.getMessage());
        }
    }
    
    /**
     * @description Performs the check-out operation with 30-minute minimum stay validation
     * @param attendee The attendee to check out
     * @return String Success or validation message
     * @throws AuraHandledException if time validation fails or DML operation fails
     */
    @TestVisible
    private static String performCheckOut(Event_Attendee__c attendee) {
        // Validate check-in time exists
        if (attendee.Check_In_Time__c == null) {
            throw new AuraHandledException('Check-in time not recorded');
        }
        
        // Calculate time elapsed since check-in
        Datetime checkInTime = attendee.Check_In_Time__c;
        Datetime currentTime = System.now();
        Long minutesElapsed = (currentTime.getTime() - checkInTime.getTime()) / (1000 * 60);
        
        // Validate minimum stay duration
        if (minutesElapsed < MIN_CHECKOUT_MINUTES) {
            Long minutesRemaining = MIN_CHECKOUT_MINUTES - minutesElapsed;
            throw new AuraHandledException(
                attendee.Name + ERROR_CHECKOUT_TOO_SOON + 
                '. Please wait ' + minutesRemaining + ' more minute(s).'
            );
        }
        
        // Perform check-out and populate checkout time
        try {
            attendee.Checked_Out__c = true;
            attendee.Checked_Out_Time__c = System.now();
            update attendee;
            return attendee.Name + SUCCESS_CHECKOUT;
        } catch (DmlException e) {
            throw new AuraHandledException(ERROR_UPDATE_FAILED + ': ' + e.getMessage());
        }
    }
}