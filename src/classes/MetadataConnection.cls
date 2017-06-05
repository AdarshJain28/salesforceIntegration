global with sharing class MetadataConnection
{
    global static Exception LastMetadataAPIConnectionException {get; private set;}

    global static Boolean checkMetadataAPIConnection()
    {
        try {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
            MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
            remoteSites.type_x = 'RemoteSiteSetting';
            queries.add(remoteSites);                   
            service.listMetadata(queries, 28);          
        } catch (Exception e) {
            LastMetadataAPIConnectionException = e;
            return false;
        }
        LastMetadataAPIConnectionException = null;
        return true;
    }
}