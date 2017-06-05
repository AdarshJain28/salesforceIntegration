public class GcalWebServiceCallout{
    public static HttpResponse invoke(String endpoint, Map<String,String> headers, String method, String body) {
        HttpResponse res = new HttpResponse();
        try {
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setTimeout(120000);
            system.debug('Body : '+body);
            req.setEndpoint(endpoint);
            req.setMethod(method);
            for(String key : headers.keySet()) {
                req.setHeader(key,headers.get(key));
            }
            if(body != null)
                req.setBody(body);
            res = http.send(req);
            //throw new applicationException('You cannot do that here its an exception');
            return res;
        } catch(Exception e) {
            res.setHeader('Error','Error Message : '+e.getMessage());
            system.debug('----ramya2----'+e.getMessage());
            }
            return res;
          } 
        }