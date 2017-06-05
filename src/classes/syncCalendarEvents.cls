global class syncCalendarEvents implements Schedulable {
   global void execute(SchedulableContext SC) {
       Gcal_settings__c  gcal = [SELECT Id,Name,Auth_Token_Generated_Time__c,Auth_Token__c, Refresh_Token__c, Expires_In__c,Token_Type__c FROM Gcal_settings__c limit 1];
       //User u = [select id,Google_Email__c,Google_Access_Token__c,Google_Refresh_Token__c, Token_Generated_TIme__c,Token_Expire_time__c from User where id = :userInfo.getUserId() LIMIT 1];
        boolean isAccessTokenExpired = googleAuthorizationController.RequestAuthTokenCheck(gcal.Auth_Token_Generated_Time__c,DateTime.now());
        if(!isAccessTokenExpired){
            httpRequest req = new httpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/primary/events');
            req.setHeader('Authorization','Bearer '+gcal.Auth_Token__c);
            req.setMethod('GET');
            httpResponse res = new http().send(req);
            CalendarWrapper cw = (CalendarWrapper)System.JSON.deserialize(res.getBody(), CalendarWrapper.class);
            system.debug('Not refreshed token'+cw);
        }
        else{
           // Gcal_settings__c  gcal = googleCalendarAPI.refreshToken(gcal);
            httpRequest req = new httpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/primary/events');
            req.setHeader('Authorization','Bearer '+gcal.Auth_Token__c);
            req.setMethod('GET');
            httpResponse res = new http().send(req);
            CalendarWrapper cw = (CalendarWrapper)System.JSON.deserialize(res.getBody(), CalendarWrapper.class);
            system.debug('refreshed token'+cw);
        }
         getCalendarEvents syncCal = new getCalendarEvents();
        String sch = '0 1 * * * ?';
        system.schedule('Sync of Events', sch, syncCal);
   }  
}