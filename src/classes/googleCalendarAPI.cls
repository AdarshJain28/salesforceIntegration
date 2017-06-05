public with sharing class googleCalendarAPI {

    public static String googleApiClientId = '54903706821-m530ehv2cng8jjb1f65me1i10s3ols4f.apps.googleusercontent.com';
    public static String googleApiClientSecret = '5NvoW3EF6YZ1fjBQjs80XJk1';
    
    public static String googleCalendarScope = 'https://www.googleapis.com/auth/calendar';
    public static String googleCalendarBaseUrl = 'https://www.googleapis.com/calendar/v3/calendars/';
    public static String googleCalendarEventsPath = '/events';
    
    public static String auth_Page = 'https://adarshjaintest-dev-ed--c.ap4.visual.force.com/apex/googleAuthPage';
    public static map<id,User> userMap = new map<id,User>([select id, name, Google_Email__c, Google_Access_Token__c, Google_Refresh_Token__c from User where isActive=true]);

    public static httpResponse callGoogle(String endpoint, String method, String body){
        HttpResponse res = new HttpResponse();
        try{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setCompressed(false);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setTimeout(120000);
                if( body != null ){
                    req.setBody(body);
                    req.setHeader('Content-length',string.valueOf(body.length()));
                }
            //HttpResponse res = new http().send(req);
            res = http.send(req);
            system.debug('---res---'+res.getBody());
            return res;
        }
        catch(Exception e) {
            res.setHeader('Error','Error Message : '+e.getMessage());
            system.debug('----adarsh----'+e.getMessage());
            return res;
        }
    }
    
    public static User parseGoogleAuth(String body, User u){
        JsonParser parser = Json.createParser(body);
        while(parser.nextToken() != null){
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() != null && parser.getText() == 'access_token'){
                parser.nextToken();
                u.Google_Access_Token__c = parser.getText();
            } else
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() != null && parser.getText() == 'refresh_token'){
                parser.nextToken();
                u.Google_Refresh_Token__c = parser.getText();
            }
        }
        return u;
    }
    
    public static PageReference loginRequestPage(String redirectURI, String state){
        PageReference p = new PageReference('https://accounts.google.com/o/oauth2/auth');
        p.getParameters().put('response_type','code');  
        p.getParameters().put('client_id',googleApiClientId);
        p.getParameters().put('redirect_uri',redirectURI);
        p.getParameters().put('approval_prompt','force');
        p.getParameters().put('scope',googleCalendarScope);
        p.getParameters().put('state',state);   
        p.getParameters().put('access_type','offline');
        system.debug(googleApiClientId);
        system.debug(redirectURI);
        system.debug(googleCalendarScope);
        system.debug(state);
        return p;
    }
    
    public static User obtainAccessToken(User u, String code, String redirectURL){
        PageReference p = new PageReference('https://accounts.google.com/o/oauth2/auth');
        p.getParameters().put('client_id',googleApiClientId);
        p.getParameters().put('client_secret',googleApiClientSecret);
        p.getParameters().put('scope','');
        p.getParameters().put('redirect_uri',redirectURL);
        p.getParameters().put('grant_type','authorization_code');
        p.getParameters().put('code',code);
        String body = p.getURL();
        body = body.subStringAfter('?');
        httpResponse res = callGoogle('https://accounts.google.com/o/oauth2/token','POST',body);
        system.debug('--res-->'+res.getBody());
        system.debug('--body--'+body);
            if(res.getStatusCode() == 200){
                u = parseGoogleAuth(res.getBody(), u);
                system.debug('ObtainAccessToken res'+res.getBody());
            }
            else{
             u.Google_Access_Token__c ='error';
             }
        return u;
    }

    
    public static User refreshToken(User u){
        PageReference p = new PageReference('https://accounts.google.com/o/oauth2/auth');
        p.getParameters().put('client_id',googleApiClientId);
        p.getParameters().put('client_secret',googleApiClientSecret);
        p.getParameters().put('refresh_token',u.Google_Refresh_Token__c);
        p.getParameters().put('grant_type','refresh_token');
        String body = p.getURL();
        body = body.subStringAfter('?');
        httpResponse res = callGoogle('https://accounts.google.com/o/oauth2/token','POST',body);
            if ( res.getStatusCode() == 200 ){
                u = parseGoogleAuth(res.getBody(), u);
                system.debug('--refreshToken res-->'+res.getBody());
            }
        return u;
    }
}