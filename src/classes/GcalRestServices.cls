public with sharing class GcalRestServices{
    public static String googleApiClientId = '54903706821-m530ehv2cng8jjb1f65me1i10s3ols4f.apps.googleusercontent.com';
    public static String googleApiClientSecret = '5NvoW3EF6YZ1fjBQjs80XJk1';
    
    public static String googleCalendarScope = 'https://www.googleapis.com/auth/calendar';
    public static String googleCalendarBaseUrl = 'https://www.googleapis.com/calendar/v3/calendars/';
    public static String googleCalendarEventsPath = '/events';
    
    public static AuthWrapper getAuthToken(){
        HttpResponse res = new HttpResponse();
        AuthWrapper auth = new AuthWrapper();
        if(Test.isRunningTest()){
             auth.tokenType = 'testToken';
             auth.accessToken = 'testAccessToken';
         } else {
             try {
                    Map<String,String> mapHeader = new Map<String,String>();
                    mapHeader.put('Content-Type', 'application/x-www-form-urlencoded');
                  //String body = 'grant_type='+TMSEnvinormentalConstants.grantType+'&username='+TMSEnvinormentalConstants.authUserName+'&password='+TMSEnvinormentalConstants.authPassword;
                    String body =  'client_id=54903706821-m530ehv2cng8jjb1f65me1i10s3ols4f.apps.googleusercontent.com&client_secret=5NvoW3EF6YZ1fjBQjs80XJk1&code=4%2F1wTE_rb4kyc2ePiOgrbiSroF4s6SbwlzXgifPSBnxUY&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fadarshjaintest-dev-ed--c.ap4.visual.force.com%2Fapex%2FgoogleAuthPage&scope=';
                    res = GcalWebServiceCallout.invoke('https://accounts.google.com/o/oauth2/token',mapHeader,'POST',body);
                    Set<String> tmp = new Set<String>();
                    tmp.addAll(res.getHeaderKeys());
                    system.debug('Response '+tmp);
                    if(tmp.contains('Error')) {
                        auth.errorMessage = res.getHeader('Error');
                        return auth;
                    }
                    system.debug('res.getStatusCode()==='+res.getStatusCode());
                    if(res.getStatusCode() == 200) {
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken()!= null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                            String fieldName = parser.getText();
                            parser.nextToken();
                            if(fieldName == 'access_token') {
                                auth.accessToken = parser.getText();
                            } else if(fieldName == 'expires_in'){
                                auth.expiresIn = parser.getIntegerValue();
                            } else if(fieldName == 'token_type'){
                                auth.tokenType = parser.getText();
                            }
                        }
                    }
                }
                system.debug('auth token =='+auth);
            } catch(System.CalloutException e) {
                auth.errorMessage = e.getMessage();
                system.debug('exception in get auth method'+e.getMessage());
                //Create Log instance
                //ReportServiceException(e);
            }
        }
        return auth;
    }
    
    public class AuthWrapper {
        public String accessToken;
        public String refreshToken;
        public String errorMessage;
        public Integer expiresIn;
        public String TokenType;
    }
    
    @future
    public static void UpdateSettingsWithNewAuth(DateTime dt,string authToken,Integer expiresIn,String tokenType){
        
        Gcal_settings__c gcal= new Gcal_settings__c();
        if(Schema.sObjectType.Gcal_settings__c.isAccessible())
                 gcal = [SELECT Id,Name,Auth_Token_Generated_Time__c,Auth_Token__c,Expires_In__c,Token_Type__c FROM Gcal_settings__c limit 1];
         
         if(gcal != null ){
            if(Schema.sObjectType.Gcal_settings__c.fields.Auth_Token_Generated_Time__c.isUpdateable()) 
                gcal.Auth_Token_Generated_Time__c = dt;
            if(Schema.sObjectType.Gcal_settings__c.fields.Auth_Token__c.isUpdateable()) 
                gcal.Auth_Token__c = authToken;
            if(Schema.sObjectType.Gcal_settings__c.fields.Expires_In__c.isUpdateable()) 
                gcal.Expires_In__c = expiresIn;
            if(Schema.sObjectType.Gcal_settings__c.fields.Token_Type__c.isUpdateable()) 
                gcal.Token_Type__c = tokenType;
            if(Schema.sObjectType.Gcal_settings__c.isUpdateable()){
                update gcal;
            } 
        }
           
    }
    
     public static Boolean RequestAuthTokenCheck(DateTime oldAuthTime,DateTime NewAuthTime){
        try{
            system.debug('Old Auth Time ==='+oldAuthTime.getTime());
            system.debug('NewAuthTime Auth Time ==='+NewAuthTime.getTime());
            
            Long millisecondsDiff = NewAuthTime.getTime() - oldAuthTime.getTime();
            Long secondsDiff = millisecondsDiff / 1000;
            
            if(secondsDiff < 3600){
                return false;
            }else{
                return true;
            }
        }catch(Exception e){
            system.debug('--Auth token Request token check --'+e.getMessage());
            return true;
        }    }    
}