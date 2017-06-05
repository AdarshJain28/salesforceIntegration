global class getCalendarEvents implements Schedulable,Database.AllowsCallouts{
   global void execute(SchedulableContext SC) {
       getgoogleAuth();
   }  
    @future(callout=true)
    public static void getgoogleAuth(){
        User u = [select id,Google_Email__c,Google_Access_Token__c,Google_Refresh_Token__c, Token_Generated_TIme__c,Token_Expire_time__c from User where id = :userInfo.getUserId() LIMIT 1];
        boolean isAccessTokenExpired = googleAuthorizationController.RequestAuthTokenCheck(u.Token_Generated_TIme__c,DateTime.now());
        calWrapper cw;
        if(!isAccessTokenExpired){
            httpRequest req = new httpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/primary/events');
            req.setHeader('Authorization','Bearer '+u.Google_Access_Token__c);
            req.setMethod('GET');
            httpResponse res = new http().send(req);
            system.debug('res---->'+res.getBody());
            String jsonString = res.getBody();
            jsonString  = jsonString.replace('\bend\b','end_Z');
            jsonString  = jsonString.replace('\bdate\b','date_x');
            jsonString  = jsonString.replace('dateTime','dateTime_x');
            cw = calWrapper.parse(jsonString);
            system.debug('jsonString--->'+jsonString);
            system.debug(cw.Items.size());
            system.debug('items-->'+cw.Items);
        }
        else{
            User  uv = googleCalendarAPI.refreshToken(u);
            uv.Token_Generated_TIme__c = Datetime.Now();
            httpRequest req = new httpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/primary/events');
            req.setHeader('Authorization','Bearer '+uv.Google_Access_Token__c);
            req.setMethod('GET');
            httpResponse res = new http().send(req);
            system.debug('res---->'+res.getBody());
            String jsonString = res.getBody();
            jsonString  = jsonString.replace('\bend\b','end_Z');
            jsonString  = jsonString.replace('\bdate\b','date_x');
            jsonString  = jsonString.replace('dateTime','dateTime_x');
            cw = calWrapper.parse(jsonString);
            system.debug('jsonString--->'+jsonString);
            system.debug('refreshed token'+cw);
            system.debug(cw.Items.size());
            system.debug('items-->'+cw.Items);
            update uv;
        }
        
        List<Event> lstNewEvents = new List<Event>();
        Set<String> subjctSet = new Set<String>();
        for(Event eachEvent : [SELECT EndDateTime,Id,StartDateTime,Subject FROM Event LIMIT 50000]){
            subjctSet.add(eachEvent.Subject);
        }
        for(calWrapper.Items eachItem : cw.Items){
            system.debug('eachItem ---->'+eachItem);
            system.debug('eachItem start ---->'+eachItem.start);
            system.debug('eachItem start ---->'+eachItem.start.dateTime_x);
            system.debug('eachItem end'+ eachItem.end_Z);
            Event e = new Event();
            e.StartDateTime = (Datetime)JSON.deserialize(eachItem.start.dateTime_x, Datetime.class);
            e.EndDateTime = (Datetime)JSON.deserialize(eachItem.end_Z.dateTime_x, Datetime.class);
            e.Subject = eachItem.summary;
            if(!subjctSet.contains(eachItem.summary)){
                lstNewEvents.add(e);
            }
        }
        if(lstNewEvents.size() > 0)
        insert lstNewEvents;
        
    }
}