public with sharing class LiveAgentCallOutClass{

/******
        PURPOSE: To generate a request and make a webservice call out.
        Author: Sankar
        Parameters: endpoint(url to hit)
                    headers(headers for Request)
                    method(Type of method)
                    body(Body of the Request)
        Return: HttpResponse
******/
    public static HttpResponse invoke(String endpoint, Map<String,String> headers, String method, String body) {
           HttpResponse res = new HttpResponse();
            try {
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setTimeout(120000);
                req.setEndpoint(endpoint);
                req.setMethod(method);
                for(String key : headers.keySet()) {
                    req.setHeader(key,headers.get(key));
                }
                if(body != null)
                    req.setBody(body);  
                system.debug('request---->'+req.getHeader('Authorization'));
                system.debug('request BODY--->'+req.getBody());
                if(Test.isRunningtest()){
                    res.setStatusCode(200);
                    res.setStatus('OK');
                }
                else{
                    res = http.send(req);
                }
                system.debug('response---->'+res);
                system.debug('response body ---->'+res.getBody());
                if(res.getStatusCode() != 200){
                    liveAgentLanguageWrapper lp = (liveAgentLanguageWrapper) System.JSON.deserialize(res.getBody(), liveAgentLanguageWrapper.class);
                    res.setHeader('Error',lp.message);
                    res.setHeader('ErrorCode',lp.errorCode);
                    return res;
                }
                else{
                    return res;
                }
             } catch(Exception e) {
                liveAgentLanguageWrapper lp = (liveAgentLanguageWrapper) System.JSON.deserialize(res.getBody(), liveAgentLanguageWrapper.class);
                res.setHeader('Error','Error Message : '+ lp.message);
                res.setHeader('ErrorCode',lp.errorCode);
                return res;
            }
        }
   @AuraEnabled     
   public static String getErrorMessageByStatus(Integer statusCode){
       String errorMessage = '';
           if(statusCode == 400){
               errorMessage = 'Please Contact Administrator';
           }
           else if(statusCode == 401){
               errorMessage = 'Please Contact Administrator';
           }
           else if(statusCode == 403){
               errorMessage = 'Please Contact Administrator';
           }
           else if(statusCode == 404){
               errorMessage = 'Please Contact Administrator';
           }
           else if(statusCode == 409){
               errorMessage = 'Please Contact Administrator';
           }
           else if(statusCode == 420){
               errorMessage = 'Please Contact Administrator';
           }
           else if(statusCode == 422){
               errorMessage = 'Please Contact Administrator';
           }
           else if(statusCode == 500){
               errorMessage = 'Please Contact Administrator';
           }
           else{
               errorMessage = 'Please Contact Administrator';
           }
       return errorMessage;
   }
}