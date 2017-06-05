public with sharing class googleAuthorizationController {
    public string googleEmail {get;set;}
    public string code {get;set;} 
    public User u {get;set;}
    
    public googleAuthorizationController() {
        googleEmail = userInfo.getUserEmail();
    }
    
    public pagereference doOnLoad(){
        Pagereference p = ApexPages.currentPage();
        code = p.getParameters().get('code');
        system.debug('--code-->'+ code);
        if (string.isBlank(code)) return null;
        string passedEmail = p.getParameters().get('state');
        boolean isTokenExpired = true;
        u = [select id,Google_Email__c,Google_Access_Token__c,Google_Refresh_Token__c, Token_Generated_TIme__c,Token_Expire_time__c from User where id = :userInfo.getUserId() LIMIT 1];
        if(u.Token_Generated_TIme__c != null && u != null && u.Google_Access_Token__c != null)
            isTokenExpired = RequestAuthTokenCheck(u.Token_Generated_TIme__c,DateTime.now());
            
        if(!isTokenExpired){
            u = googleCalendarAPI.obtainAccessToken(u, code, googleCalendarAPI.auth_Page);
            if(u.Google_Access_Token__c != null){
                u.Google_Email__c = passedEmail;
                u.Token_Generated_TIme__c = DateTime.now();
                update u;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.confirm,'Authorized Successfully!'));
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Authorization Error.'));   
            }
        }
        else{
            u = googleCalendarAPI.refreshToken(u);
            if(u.Google_Refresh_Token__c != null){
                u.Google_Email__c = passedEmail;
                u.Token_Generated_TIme__c = DateTime.now();
                u.Google_Access_Token__c = u.Google_Access_Token__c;
                update u;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.confirm,'Authorized Refresh Successfully!'));
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Authorization Refresh Error.'));   
            }
        }
        return null;
       
    }
    
    public pagereference refreshAccessToken(){
        Pagereference p = ApexPages.currentPage();
        code = p.getParameters().get('code');
        if (string.isBlank(code)) return null;
        string passedEmail = p.getParameters().get('state');
        u = [select id,Google_Email__c,Google_Access_Token__c,Google_Refresh_Token__c, Token_Generated_TIme__c,Token_Expire_time__c from User where id = :userInfo.getUserId() LIMIT 1];
    
         u = googleCalendarAPI.refreshToken(u);
            if(u.Google_Refresh_Token__c != null){
                u.Google_Email__c = passedEmail;
                u.Token_Generated_TIme__c = DateTime.now();
                update u;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.confirm,'Authorized Refresh Successfully!'));
            }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Authorization Refresh Error.'));   
        }
        return null;
    }

    public pagereference requestAuthorization(){
        return googleCalendarAPI.loginRequestPage(googleCalendarAPI.auth_Page,googleEmail);
    }
    public void getgoogleAuth(){
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
            system.debug('eachItem end'+ eachItem.end_Z.dateTime_x);
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
    
    public static Boolean RequestAuthTokenCheck(DateTime oldTokenTime,DateTime NewTokenTime){
        try{
            system.debug('Old Token Time ==='+oldTokenTime.getTime());
            system.debug('NewTokenTime Token Time ==='+NewTokenTime.getTime());
            
            Long millisecondsDiff = NewTokenTime.getTime() - oldTokenTime.getTime();
            Long secondsDiff = millisecondsDiff / 1000;
            if(secondsDiff < 3600){
                return false;
            }else{
                return true;
            }
        }catch(Exception e){
            system.debug('--Auth token Request token check --'+e.getMessage());
            return true;
        }
    }
    

}