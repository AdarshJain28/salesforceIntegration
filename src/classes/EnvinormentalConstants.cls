public with sharing class EnvinormentalConstants{
    
    public static String SDL_BASE_URL = 'https://lc-api.sdl.com';
    public static String SDL_Translate_url = '/translate';
    public static String SDL_LanguagePair_url = '/languages';
    public static String SDL_Dictionaries_url = '/termbases';
    public static String SDL_Detect_Language_url = '/detectLanguage';
    public static String SDL_Detect_Language_url_new = '/detect-language'; 
    
    public static EnvinormentalConstants instance;
    public SDL_Translation_Settings__c sdlSettings;
    
    private EnvinormentalConstants(){
        if (Schema.sObjectType.User.isAccessible()) 
            sdlSettings = [SELECT id, Detection_limit__c, APIKey__c,Tracking_Key__c, isActive__c, MaxUsage__c, Usage__c, Target_Language_Preference__c,AdminsEmailAddress__c,(select id, Object_Id__c, Object_Name__c, Page_Layout_Id__c, Page_Layout_Name__c, Status__c from SDL_Translate_Page_Layout_Settings__r) FROM SDL_Translation_Settings__c limit 1];
    }
    
    @AuraEnabled public static EnvinormentalConstants getInstance(){
        if(instance == null) 
            instance = new EnvinormentalConstants();
        return instance;
    }
    
   public static final Map<String,String> localeMap = new Map<String,String>();
      
       static{
            
            localeMap.put('en_US','English');
            localeMap.put('zh_TW','Chinese (Traditional)');
            localeMap.put('zh_CN','Chinese (Simplified)');
            localeMap.put('da','Danish');
            localeMap.put('da_DK','Danish');
            localeMap.put('nl','Dutch');
            localeMap.put('nl_BE','Dutch');
            localeMap.put('nl_NL','Dutch');
            localeMap.put('nl_SR','Dutch');
            localeMap.put('hi','Hindi');
            localeMap.put('hi_IN','Hindi');
            localeMap.put('so','Somali');
            localeMap.put('so_DJ','Somali');
            localeMap.put('so_SO','Somali');
            localeMap.put('ko_KP','Korean');
            localeMap.put('ko_KR','Korean');
            localeMap.put('ko','Korean');
            localeMap.put('fa','Persian');
            
            localeMap.put('fa_IR','Persian');
            localeMap.put('cs','Czech');
            localeMap.put('cs_CZ','Czech');
            localeMap.put('pl','Polish');
            localeMap.put('pl_PL','Polish');
            localeMap.put('sv','Swedish');
            localeMap.put('sv_SE','Swedish');
            localeMap.put('sv_FI','Swedish');
           
            localeMap.put('it','Italian');
            localeMap.put('it_IT','Italian');
            localeMap.put('it_CH','Italian');
            localeMap.put('ha','Hausa');
            localeMap.put('pt','Portuguese');
            localeMap.put('pt_AO','Portuguese');
            localeMap.put('pt_BR','Portuguese');
            localeMap.put('pt_PT','Portuguese');
            
            localeMap.put('ur','Urdu');
            localeMap.put('ur_PK','Urdu');
            localeMap.put('hu','Hungarian');
            localeMap.put('hu_HU','Hungarian');
            localeMap.put('el','Greek');
            localeMap.put('el_GR','Greek');
            localeMap.put('no','Norwegian');
            localeMap.put('no_NO','Norwegian');
            localeMap.put('iw_IL','Hebrew');
            localeMap.put('iw','Hebrew');
            localeMap.put('th','Thai');
            localeMap.put('th_TH','Thai');
            localeMap.put('tr','Turkish');
            localeMap.put('tr_TR','Turkish');
            //dari remaining
            localeMap.put('in','Indonesian');
            localeMap.put('in_ID','Indonesian');
            localeMap.put('bn','Bengali');
            localeMap.put('en_AU','Englsih');
            localeMap.put('en_BB','Englsih');
            localeMap.put('en_BM','Englsih');
            localeMap.put('en_CA','English');
            localeMap.put('en_GH','English');
            localeMap.put('en_HK','English');
            localeMap.put('en_IN','English');
            localeMap.put('en_ID','English');
            localeMap.put('en_IE','English');
            localeMap.put('en_IE_EURO','English');
            localeMap.put('en_MY','English');
            localeMap.put('en_NZ','English');
            localeMap.put('en_NG','English');
            localeMap.put('en_PK','English');
            localeMap.put('en_PH','English');
            localeMap.put('en_SG','English');
            localeMap.put('en_ZA','English');
            localeMap.put('en_GB','English');
            localeMap.put('sr','Serbian');
            localeMap.put('sr_BA','Serbian');
            localeMap.put('sr_CS','Serbian');
            localeMap.put('sh','Serbian');
            localeMap.put('sh_BA','Serbian');
            localeMap.put('sh_CS','Serbian');
            localeMap.put('fi','Finnish');
            localeMap.put('fi_FI','Finnish');
            localeMap.put('fi_FI_EURO','Finnish');
            localeMap.put('ps','Pashto');
            localeMap.put('sk','Slovak');
            localeMap.put('sk_SK','Slovak');
            localeMap.put('sl','Slovenian');
            localeMap.put('sl_SI','Slovenian');
            localeMap.put('et','Estonian');
            localeMap.put('et_EE','Estonian');
            localeMap.put('lt','Lithuanian');
            localeMap.put('lt_LT','Lithuanian');
            localeMap.put('ms','Malay');
            localeMap.put('ms_BN','Malay');
            localeMap.put('ms_MY','Malay');
            localeMap.put('vi','Vietnamese');
            localeMap.put('vi_VN','Vietnamese');
            localeMap.put('sq','Albanian');
            localeMap.put('sq_AL','Albanian');
            localeMap.put('es','Spanish');
            localeMap.put('es_AR','Spanish');
            localeMap.put('es_MX','Spanish');
            localeMap.put('es_BO','Spanish');
            localeMap.put('es_CL','Spanish');
            localeMap.put('es_CO','Spanish');
            localeMap.put('es_CR','Spanish');
            localeMap.put('es_DO','Spanish');
            localeMap.put('es_EC','Spanish');
            localeMap.put('es_SV','Spanish');
            localeMap.put('es_GT','Spanish');
            localeMap.put('es_HN','Spanish');
            localeMap.put('es_NI','Spanish');
            localeMap.put('es_PA','Spanish');
            localeMap.put('es_PY','Spanish');
            localeMap.put('es_PE','Spanish');
            localeMap.put('es_PR','Spanish');
            localeMap.put('es_ES_EURO','Spanish');
            localeMap.put('es_ES','Spanish');
            localeMap.put('es_US','Spanish');
            localeMap.put('es_UY','Spanish');
            localeMap.put('es_VE','Spanish');
            localeMap.put('uk','Ukranian');
            localeMap.put('uk_UA','Ukranian');
            localeMap.put('lv','Latvian');
            localeMap.put('lv_LV','Latvian');
            localeMap.put('fr','Frech');
            localeMap.put('fr_BE','Frech');
            localeMap.put('fr_CA','Frech');
            localeMap.put('fr_LU','French');
            localeMap.put('fr_CH','French');
            localeMap.put('fr_CA','Frech');
            localeMap.put('fr_LU','French');
            localeMap.put('fr_CH','French');
            localeMap.put('ar','Arabic');
            localeMap.put('ar_DZ','Arabic');
            localeMap.put('ar_BH','Arabic');
            localeMap.put('ar_EG','Arabic');
            localeMap.put('ar_IQ','Arabic');
            localeMap.put('ar_JO','Arabic');
            localeMap.put('ar_KW','Arabic');
            localeMap.put('ar_LB','Arabic');
            localeMap.put('ar_LY','Arabic');
            localeMap.put('ar_MA','Arabic');
            localeMap.put('ar_OM','Arabic');
            localeMap.put('ar_QA','Arabic');
            localeMap.put('ar_SA','Arabic');
            localeMap.put('ar_SD','Arabic');
            localeMap.put('ar_SY','Arabic');
            localeMap.put('ar_TN','Arabic');
            localeMap.put('ar_AE','Arabic');
            localeMap.put('ar_YE','Arabic');
            localeMap.put('ru','Russian');
            localeMap.put('ru_RU','Russian');
            localeMap.put('ja','Japaneese');
            localeMap.put('ja_JP','Japaneese');
            localeMap.put('ro','Romanian');
            localeMap.put('de','German');
            localeMap.put('de_AT_EURO','German');
            localeMap.put('de_AT','German');
            localeMap.put('de_DE_EURO','German');
            localeMap.put('de_DE','German');
            localeMap.put('de_LU_EURO','German');
            localeMap.put('de_LU','German');
            localeMap.put('de_CH','German');
            System.debug('locale map is '+localeMap);
        }
}