public class RestApi{
   
  public static Boolean isTest = false;
    
 @AuraEnabled public static Map<String, Object> invoke(String url, String method, Map<String,object> body, String apiKey){
        system.debug('Url : '+url);
        system.debug('Method : '+method);
        system.debug('Api Key : '+apiKey);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'LC apiKey='+apiKey);
        req.setHeader('Tracking', EnvinormentalConstants.getInstance().sdlSettings.Tracking_Key__c);
        system.debug('Tracking : '+EnvinormentalConstants.getInstance().sdlSettings.Tracking_Key__c);
        if(body!=null && !body.isEmpty()){
            String JSONString = JSON.serialize(body);   
            system.debug('JSONString Body === '+JSONString);
            req.setBody(JSONString);
        }
        Http http = new Http();
        HTTPResponse res;
        Map<String, Object> responseMap = new Map<String, Object>();
        if(!isTest){
            res = http.send(req);
            System.debug('JSONString === '+res.getBody()); 
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        }else{
            if(url.contains(EnvinormentalConstants.SDL_Dictionaries_url)){
                String response = '{"totalCount": 1,"termbases": [{"id": "527919b584ae25278e8cefe8","name": "MyTermbase","description": "This is my first Termbase" },{"id": "12331gjhgjhgjh","name": "MyTermbase","description": "This is my first Termbase" }]}';
                responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            }
             if(url.contains('/translation-engines')){
                String response = '{"translationEngines":[{"trustScoreEnabled":false,"from":{"code":"eng","locale":"en","name":"English","fullName":"English","comments":null,"active":true,"rightToLeft":false},"fromLanguageId":"505037985fe01ac20407b7fb","To":{"code":"spa","locale":"es","name":"Spanish","fullName":"Spanish","comments":null,"active":true,"rightToLeft":false},"toLanguageId":"505037985fe01ac20407b81f","domainCode":null,"domainDescription":null,"type":"BASELINE"},{"trustScoreEnabled":false,"from":{"code":"eng","locale":"en","name":"English","fullName":"English","comments":null,"active":true,"rightToLeft":false},"fromLanguageId":"505037985fe0c20405","To":{"code":"fra","locale":"fr","name":"French","fullName":"French","comments":"fra (T) chosen over fre (B)","active":true,"rightToLeft":false},"toLanguageId":"505037985fe01ac20407b","domainCode":null,"domainDescription":null,"type":"BASELINE"}]},{"trustScoreEnabled":false,"from":{"code":"eng","locale":"en","name":"English","fullName":"English","comments":null,"active":true,"rightToLeft":false},"fromLanguageId":"505037985fe12207b7fb","To":{"code":"urd","locale":"es","name":"Urdu","fullName":"Urdu","comments":null,"active":true,"rightToLeft":false},"toLanguageId":"505037985fe01ac20407b81f","domainCode":"wersds","domainDescription":null,"type":"VERTICAL"';  
             responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            }
        }
        
        return responseMap;
    }
}