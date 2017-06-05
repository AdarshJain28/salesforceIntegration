global with sharing class LiveAgentChatWidget_Controller {

    public LiveAgentChatWidget_Controller(ApexPages.StandardController controller) {

    }

Public String customerlogo{get;set;}
    global LiveAgentChatWidget_Controller(){
        string logo = 'Customer Logo';
        List<Document> lstDocument ;
        if (Schema.sObjectType.Document.isAccessible())
               lstDocument = [Select Id,Name,LastModifiedById from Document where Name = :logo limit 1];
        System.debug('document is:' +lstDocument );
        string strOrgId = UserInfo.getOrganizationId();
        System.debug('orgId is:' +strOrgId);
        string baseurl=URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('baseurl----->'+baseurl);
        //string strDocUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id='+lstDocument[0].Id+'&oid=' + strOrgId;
        
        /* base url */
        List<Live_Agent_Settings__c> Orgsettings = new  List<Live_Agent_Settings__c>();
         if (Schema.sObjectType.Live_Agent_Settings__c .isAccessible()){
           Orgsettings = [SELECT APIKey__c,DetectionLimit__c,Id,isActive__c FROM Live_Agent_Settings__c limit 1];
         }
         string strDocUrl = '';
        
    }
    
     @RemoteAction
    public static liveAgentLanguageWrapper.TranslatedResponse TextTranslation(string TexttoTranslate,string sourceLanguage,String TargetLanguage){
            return LiveAgentRestServicesClass.textTranslation(TargetLanguage,sourceLanguage,TexttoTranslate);
   }
    
   
   global static Map<String,String> getLanguageCodes(){
       Map<String,String> langCodeMap = new Map<String,String>();
        langCodeMap.put('zh_TW','Chinese (Traditional, Taiwan)');
        langCodeMap.put('en_US','English');
        langCodeMap.put('zh_CN','Chinese (Simplified, PRC)');
        langCodeMap.put('da','Danish');
        langCodeMap.put('da_DK','Danish');
        langCodeMap.put('nl','Dutch');
        langCodeMap.put('nl_BE','Dutch');
        langCodeMap.put('nl_NL','Dutch');
        langCodeMap.put('nl_SR','Dutch');
        langCodeMap.put('hi','Hindi');
        langCodeMap.put('hi_IN','Hindi');
        langCodeMap.put('so','Somali');
        langCodeMap.put('so_DJ','Somali');
        langCodeMap.put('so_SO','Somali');
        langCodeMap.put('ko_KP','Korean');
        langCodeMap.put('ko_KR','Korean');
        langCodeMap.put('ko','Korean');
        langCodeMap.put('fa','Persian');
        langCodeMap.put('fa_IR','Persian');
        langCodeMap.put('cs','Czech');
        langCodeMap.put('cs_CZ','Czech');
        langCodeMap.put('pl','Polish');
        langCodeMap.put('pl_PL','Polish');
        langCodeMap.put('sv','Swedish');
        langCodeMap.put('sv_SE','Swedish');
        langCodeMap.put('sv_FI','Swedish');
        langCodeMap.put('it','Italian');
        langCodeMap.put('it_IT','Italian');
        langCodeMap.put('it_CH','Italian');
        langCodeMap.put('ha','Hausa');
        langCodeMap.put('pt','Portuguese');
        langCodeMap.put('pt_AO','Portuguese');
        langCodeMap.put('pt_BR','Portuguese');
        langCodeMap.put('pt_PT','Portuguese');
        langCodeMap.put('ur','Urdu');
        langCodeMap.put('ur_PK','Urdu');
        langCodeMap.put('hu','Hungarian');
        langCodeMap.put('hu_HU','Hungarian');
        langCodeMap.put('el','Greek');
        langCodeMap.put('el_GR','Greek');
        langCodeMap.put('no','Norwegian');
        langCodeMap.put('no_NO','Norwegian');
        langCodeMap.put('iw_IL','Hebrew');
        langCodeMap.put('iw','Hebrew');
        langCodeMap.put('th','Thai');
        langCodeMap.put('th_TH','Thai');
        langCodeMap.put('tr','Turkish');
        langCodeMap.put('tr_TR','Turkish');
        langCodeMap.put('in','Indonesian');
        langCodeMap.put('in_ID','Indonesian');
        langCodeMap.put('bn','Bengali');
        langCodeMap.put('en_AU','English');
        langCodeMap.put('en_BB','English');
        langCodeMap.put('en_BM','English');
        langCodeMap.put('en_CA','English');
        langCodeMap.put('en_GH','English');
        langCodeMap.put('en_HK','English');
        langCodeMap.put('en_IN','English');
        langCodeMap.put('en_ID','English');
        langCodeMap.put('en_IE','English');
        langCodeMap.put('en_IE_EURO','English');
        langCodeMap.put('en_MY','English');
        langCodeMap.put('en_NZ','English');
        langCodeMap.put('en_NG','English');
        langCodeMap.put('en_PK','English');
        langCodeMap.put('en_PH','English');
        langCodeMap.put('en_SG','English');
        langCodeMap.put('en_ZA','English');
        langCodeMap.put('en_GB','English');
        langCodeMap.put('sr','Serbian');
        langCodeMap.put('sr_BA','Serbian');
        langCodeMap.put('sr_CS','Serbian');
        langCodeMap.put('sh','Serbian');
        langCodeMap.put('sh_BA','Serbian');
        langCodeMap.put('sh_CS','Serbian');
        langCodeMap.put('fi','Finnish');
        langCodeMap.put('fi_FI','Finnish');
        langCodeMap.put('fi_FI_EURO','Finnish');
        langCodeMap.put('ps','Pashto');
        langCodeMap.put('sk','Slovak');
        langCodeMap.put('sk_SK','Slovak');
        langCodeMap.put('sl','Slovenian');
        langCodeMap.put('sl_SI','Slovenian');
        langCodeMap.put('et','Estonian');
        langCodeMap.put('et_EE','Estonian');
        langCodeMap.put('lt','Lithuanian');
        langCodeMap.put('lt_LT','Lithuanian');
        langCodeMap.put('ms','Malay');
        langCodeMap.put('ms_BN','Malay');
        langCodeMap.put('ms_MY','Malay');
        langCodeMap.put('vi','Vietnamese');
        langCodeMap.put('vi_VN','Vietnamese');
        langCodeMap.put('sq','Albanian');
        langCodeMap.put('sq_AL','Albanian');
        langCodeMap.put('es','Spanish');
        langCodeMap.put('es_AR','Spanish');
        langCodeMap.put('es_MX','Spanish');
        langCodeMap.put('es_BO','Spanish');
        langCodeMap.put('es_CL','Spanish');
        langCodeMap.put('es_CO','Spanish');
        langCodeMap.put('es_CR','Spanish');
        langCodeMap.put('es_DO','Spanish');
        langCodeMap.put('es_EC','Spanish');
        langCodeMap.put('es_SV','Spanish');
        langCodeMap.put('es_GT','Spanish');
        langCodeMap.put('es_HN','Spanish');
        langCodeMap.put('es_NI','Spanish');
        langCodeMap.put('es_PA','Spanish');
        langCodeMap.put('es_PY','Spanish');
        langCodeMap.put('es_PE','Spanish');
        langCodeMap.put('es_PR','Spanish');
        langCodeMap.put('es_ES_EURO','Spanish');
        langCodeMap.put('es_ES','Spanish');
        langCodeMap.put('es_US','Spanish');
        langCodeMap.put('es_UY','Spanish');
        langCodeMap.put('es_VE','Spanish');
        langCodeMap.put('uk','Ukranian');
        langCodeMap.put('uk_UA','Ukranian');
        langCodeMap.put('lv','Latvian');
        langCodeMap.put('lv_LV','Latvian');
        langCodeMap.put('fr','French');
        langCodeMap.put('fr_BE','French');
        langCodeMap.put('fr_CA','French');
        langCodeMap.put('fr_LU','French');
        langCodeMap.put('fr_KM','French');
        langCodeMap.put('fr_FR_EURO','French');
        langCodeMap.put('fr_FR','French');
        langCodeMap.put('fr_GN','French');
        langCodeMap.put('fr_HT','French');
        langCodeMap.put('fr_MR','French');
        langCodeMap.put('fr_MC','French');
        langCodeMap.put('fr_CH','French');
        langCodeMap.put('fr_WF','French');
        langCodeMap.put('ar','Arabic');
        langCodeMap.put('ar_DZ','Arabic');
        langCodeMap.put('ar_BH','Arabic');
        langCodeMap.put('ar_EG','Arabic');
        langCodeMap.put('ar_IQ','Arabic');
        langCodeMap.put('ar_JO','Arabic');
        langCodeMap.put('ar_KW','Arabic');
        langCodeMap.put('ar_LB','Arabic');
        langCodeMap.put('ar_LY','Arabic');
        langCodeMap.put('ar_MA','Arabic');
        langCodeMap.put('ar_OM','Arabic');
        langCodeMap.put('ar_QA','Arabic');
        langCodeMap.put('ar_SA','Arabic');
        langCodeMap.put('ar_SD','Arabic');
        langCodeMap.put('ar_SY','Arabic');
        langCodeMap.put('ar_TN','Arabic');
        langCodeMap.put('ar_AE','Arabic');
        langCodeMap.put('ar_YE','Arabic');
        langCodeMap.put('ru','Russian');
        langCodeMap.put('ru_RU','Russian');
        langCodeMap.put('ja','Japanese');
        langCodeMap.put('ja_JP','Japanese');
        langCodeMap.put('ro','Romanian');
        langCodeMap.put('de','German');
        langCodeMap.put('de_AT_EURO','German');
        langCodeMap.put('de_AT','German');
        langCodeMap.put('de_DE_EURO','German');
        langCodeMap.put('de_DE','German');
        langCodeMap.put('de_LU_EURO','German');
        langCodeMap.put('de_LU','German');
        langCodeMap.put('de_CH','German');
        return langCodeMap;
   
   }
   
   global class AdminSettings{
       public Live_Agent_Settings__c liveAgentSettings;
       public List<String> languagePairs;
       public string AgentLanguage;
   }
   
   @RemoteAction
   public static String SendEmailToAgent(String sourceLang, String TargetLang){
       String resultString = '';
       String UserName = UserInfo.getName();
       String BodyMessage = 'Language Pair with ' + sourceLang + '->' + TargetLang  + ' not Found';
       Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
       message.setTargetObjectId(UserInfo.getUserId());
       message.subject = 'Language Pair Validation';
       message.setHtmlBody('Hello '+ UserName + ', ' + '<br/><br/>' + BodyMessage);
       message.setSaveAsActivity(false);
       Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
       if(!Test.isRunningtest()){
               Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
               if (results[0].success) {
                    resultString = 'SUCCESS';
               } else {
                    resultString = 'FAILED';
               }
       }
       return resultString;
   }
   
   @RemoteAction
   public static Map<string,string> SDLLanguagePairs()  {
               /******** on page load get language pairs ********/
        List<SDL_Language_Pair__c> langpairs = new List<SDL_Language_Pair__c>();
        if (Schema.sObjectType.SDL_Language_Pair__c.isAccessible()){
            langpairs=[Select Id,Status__c,FromCode__c,FromLanguage__c,ToCode__c,ToLanguage__c,DomainDescription__c From SDL_Language_Pair__c Where Status__c=true ORDER BY FromLanguage__c ASC Limit 200 ];
        }
        Map<string,string> langmap=new Map<string,string>();
        Map<string,string> tomap=new Map<string,string>();
        if(langpairs.size()>0){
           for(SDL_Language_Pair__c lan:langpairs) 
           {
               langmap.put(lan.FromCode__c, lan.FromLanguage__c);
           }     
           return langmap;
         }
        else{
           return  null;
        }     
    }
     
    
     @RemoteAction
     public static Map<string,string> ToLanguage(String fromid)  {
               /******** on page load get language pairs ********/
        List<SDL_Language_Pair__c> tolang = new List<SDL_Language_Pair__c>();
        if (Schema.sObjectType.SDL_Language_Pair__c.isAccessible()){
             tolang=[Select Id,Status__c,FromCode__c,FromLanguage__c,ToCode__c,ToLanguage__c,DomainDescription__c From SDL_Language_Pair__c Where Status__c=:true And FromCode__c =:fromid ORDER BY ToLanguage__c ASC  Limit 200];
        }
        Map<string,string> tomap=new Map<string,string>();
        if(tolang.size()>0){
           for(SDL_Language_Pair__c lan:tolang) 
           {
               tomap.put(lan.ToCode__c, lan.ToLanguage__c);
           }     
          return tomap;
         }
        else{
           return  null;
        }     
               
               
     }
  
     
     
}