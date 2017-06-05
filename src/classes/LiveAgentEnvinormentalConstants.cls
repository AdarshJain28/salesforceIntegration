public with sharing class LiveAgentEnvinormentalConstants{
    public LiveAgentEnvinormentalConstants instance;
    public String LiveAgentBaseUrl{get;set;}
    public String LiveAgent_Lc_Api_Key{get;set;}
    public String LanguageDetectUrl{get;set;}
    public String ViewLanguagesUrl{get;set;}
    public String TextTranslationUrl{get;set;}
    public String TranslationEnginesUrl{get;set;}
    public string TermBasesUrl{get;set;}
    public List<string> TermBaseID{get;set;}
    public LiveAgentEnvinormentalConstants(){
        TermBaseID = new List<string>();
        List<Live_Agent_Settings__c> settings = new List<Live_Agent_Settings__c>();
        if (Schema.sObjectType.Live_Agent_Settings__c.isAccessible())
        settings = [SELECT APIKey__c,Id FROM Live_Agent_Settings__c limit 1];
        if(settings != null && settings.size() > 0){
             LiveAgent_Lc_Api_Key = settings[0].APIKey__c;
        }
        LiveAgentBaseUrl = 'https://lc-api.sdl.com';
        ViewLanguagesUrl = LiveAgentBaseUrl+'/languages?';
        LanguageDetectUrl = LiveAgentBaseUrl+'/detect-language';
        TranslationEnginesUrl = LiveAgentBaseUrl+'/translation-engines';
        TextTranslationUrl = LiveAgentBaseUrl+'/translate';
        TermBasesUrl = LiveAgentBaseUrl+'/termbases';
       
    }

}