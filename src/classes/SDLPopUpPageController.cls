/*
 *@Author: Bit Order Technologies
 * This class is used as a Controller for SDLPopUpPage  and does following funtionalities:
 * - Gets all SDL language pairs from custom object SDL_Language_Pairs
 * - Detects user selected language using REST API call to remote server
 * - Displays 'from language' and 'to language' options for translation
 * - Based on chosen 'to language' option translates selected text into it.
 
*/
global with sharing class SDLPopUpPageController{

    public Boolean isInitialLoad;
    public String myString{get;set;}
    public String myString1{get;set;}
    public static Map<String,String> fromLanguageCodes = new Map<String,String>();
    public String fromLanguage { get; set; }
    public String toLanguage { get; set; }
    
    public Map<String,String> languageCodes = new Map<String,String>();
    
    public Map<String,String> languageToCodeMap = new Map<String,String>();
    
    public Boolean isSwaped;
    public EnvinormentalConstants con;
    public SDL_Translation_Settings__c settings {get; set;}
    
    public PageReference myMethod() {
        System.debug('in my method '+myString);
        fromLanguage = myString;
        toLanguage = myString1;
        return null;
    }

    public SDLPopUpPageController(){
          settings = [select Target_Language_Preference__c,isActive__c from SDL_Translation_Settings__c limit 1];
          
          isInitialLoad = true;
          myString = '';
          
          Map<String,SDL_Language_Pairs__c> allPairs = SDL_Language_Pairs__c.getAll();
          for(SDL_Language_Pairs__c slp: allPairs.values()){
              languageCodes.put(slp.fromCode__c, slp.FromLanguage__c);
              languageToCodeMap.put(slp.FromLanguage__c, slp.FromCode__c);
          }
          
     }
  
     @RemoteAction
     global static String detectLanguage(String str){
                  
         if(str.length() > 0 && !str.equals('') && str != NULL){
             if(str.length() > 100){
                str = str.substring(0,100);
             } 
             Map<String,object> mapEmp = new Map<String,object>();
             System.debug('Json string ==='+str);
             mapEmp.put('text',str);  
             Map<String, Object> resMap = new Map<String, Object>();
             resMap = RestApi.invoke(EnvinormentalConstants.SDL_BASE_URL+EnvinormentalConstants.SDL_Detect_Language_url,'PUT',mapEmp,EnvinormentalConstants.getInstance().sdlSettings.APIKey__c);
             System.debug('detected Language is '+(String)resMap.get('detectedLanguage'));
             return (String)resMap.get('detectedLanguage');    
        }
        return '';
     }
     
     @RemoteAction
     global static String detectLanguageNew(String str){
     
         EnvinormentalConstants env = EnvinormentalConstants.getInstance();
         
         Boolean isLimit = false;
         if(env.sdlSettings.Detection_limit__c.equals('100')){
             isLimit = true;
         }
         
         if(str.length() > 0 && !str.equals('') && str != NULL){
             if(isLimit){
                 if(str.length() > 100){
                    str = str.substring(0,100);
                 }
             }
             
             String encodedString = EncodingUtil.URLENCODE(str,'UTF-8');
             //String encodedString = str;
             System.debug('Json string ==='+str); 
             Map<String,object> mapEmp = new Map<String,object>();
             mapEmp.put('text',encodedString);  
             Map<String, Object> resMap = new Map<String, Object>();
             System.debug('resMap jsonString'+resMap);
             resMap = RestApi.invoke(EnvinormentalConstants.SDL_BASE_URL+EnvinormentalConstants.SDL_Detect_Language_url_new ,'POST',mapEmp,EnvinormentalConstants.getInstance().sdlSettings.APIKey__c);
             String serialized = JSON.serialize(resMap);
             
             System.debug('serialized == '+serialized );
             System.debug('resMap == ');
             
             JSONParser parser = JSON.createParser(serialized );
             LanguageDetectResponce lang =(LanguageDetectResponce)parser.readValueAs(LanguageDetectResponce.class); 
             
             System.debug('lang.result'  );
             System.debug(lang.result  );
            
             String detectedLanguage = '';
             Map<Integer,String> confidentialityMap = new Map<Integer,String>(); 
             for(LanguageDetectResult ldr: lang.result){
                 confidentialityMap.put(Integer.valueOf(ldr.confidence),ldr.language.threeLetterCode);
             }
             
             if(confidentialityMap!=null && confidentialityMap.size()>0){
                 List<Integer> aList = new List<Integer>();
                 aList.addAll(confidentialityMap.keySet());
                 aList.sort();
                 System.debug('list is ='+aList );
                 Integer key = aList.get(aList.size()-1);
                 system.debug('key='+key);
                 detectedLanguage = confidentialityMap.get(key);
             }
             
            System.debug('detectedLanguage === '+detectedLanguage );
             
             return detectedLanguage;    
        }
        return '';
     }
    
    /*@RemoteAction
    global static Map<String,String> getAllFromLanguagesCode(){
        Map<String,SDL_Language_Pair__c> allPairs = SDL_Language_Pair__c.getAll();
        for(SDL_Language_Pair__c slp : allPairs.values()){
            fromLanguageCodes.put(slp.FromCode__c,slp.FromLanguage__c);
        }
        return fromLanguageCodes;
    }*/
  
    public List<SelectOption> getFromLanguageOptions() {
    
        List<SelectOption> options = new List<SelectOption>();
        if(!isInitialLoad)
        {
           
            if(myString == 'unk')
            {
                options.add(new SelectOption('Select language','Select language'));
            }
            Map<String,String> lanuageMap = new Map<String,String>();
            Map<String,SDL_Language_Pairs__c> datasetMap = SDL_Language_Pairs__c.getAll();
            Set<String> keyset = datasetMap.keySet();
            for(String dataSetName:keyset)
            {
                SDL_Language_Pairs__c language = SDL_Language_Pairs__c.getValues(dataSetName);
                if(lanuageMap.containsKey(language.FromLanguage__c) == false)
                {
                if(language.FromLanguage__c!=null)
                {
                options.add(new SelectOption(language.FromCode__c,language.FromLanguage__c));
                
                lanuageMap.put(language.FromLanguage__c,language.FromLanguage__c);
                }
                }
            }
             
       }
       options.sort();
       return options;
    }
    
     public List<SelectOption> getToLanguageOptions() {
     List<SelectOption> options = new List<SelectOption>();
     if(!isInitialLoad)
     {
         System.debug('from language is '+fromLanguage);
         String country;
         Boolean localefound = false;
     
     
         Map<String,String> lanuageMap = new Map<String,String>();
         Map<String,SDL_Language_Pairs__c> datasetMap = SDL_Language_Pairs__c.getAll();
         Set<String> keyset = datasetMap.keySet();
     
         if(settings.Target_Language_Preference__c == 'English')
         {
             System.debug('param is '+myString);
             System.debug('country is '+myString1);
         
             country = myString1;
        
             if(country !=null && country != languageCodes.get(fromLanguage))
             options.add(new SelectOption(languageToCodeMap.get(country),country));
             else
             {
                System.debug('in no language found');
                options.add(new SelectOption('',''));
             }
                 
         }
         System.debug('load is '+isInitialLoad);
         System.debug('target is '+settings.Target_Language_Preference__c);
         if(settings.Target_Language_Preference__c == 'User Language Preference')
         {
             System.debug('param is '+languageCodes.get(fromLanguage));
             System.debug('country is '+myString1);
         
             country = myString1;
             //System.debug('country is '+myString1);
             if(country !=null && country != languageCodes.get(fromLanguage))
                 options.add(new SelectOption(languageToCodeMap.get(country),country));
             else
                 options.add(new SelectOption('',''));
         
         }
         for(String dataSetName : keyset)
         {
             SDL_Language_Pairs__c language = SDL_Language_Pairs__c.getValues(dataSetName);
             System.debug('in loop fromlan '+fromLanguage);
             System.debug('in loop tolan '+language.ToLanguage__c);
             System.debug('languageCodes === '+languageCodes.get(fromLanguage));
            
             if(language.FromLanguage__c == languageCodes.get(fromLanguage) && language.Status__c == true)
             {
                 System.debug('check status');
                 if(language.ToLanguage__c != country)
                 options.add(new SelectOption(language.ToCode__c,language.ToLanguage__c));
                 if(language.ToLanguage__c == country)
                 {
                     localefound = true;
                     System.debug('locale found?');
                    
                 }
             }
         }
     
         System.debug('options are '+options);
         if(localefound == false)
         {
             options.set(0,new SelectOption('Select language','Select language'));
         }
     
         System.debug('options are '+options);
     }
     isInitialLoad = false;
     List<SelectOption> sortedOpt = new List<SelectOption>();
     System.debug('options size is '+options.size());
     if(options.size()>0)
     {
     sortedOpt.add(options.get(0));
     options.remove(0);
     options.sort();
     sortedOpt.addAll(options);
     }
     return sortedOpt;
           
    }
    @RemoteAction @AuraEnabled
    global static Map<String, Object> translateText(String fromLanguage, String toLanguage, String selectedText){
        
        List<SDL_Dictionaries__c> languageDic = new list<SDL_Dictionaries__c>();
        Map<String,SDL_Dictionaries__c> allFields= SDL_Dictionaries__c.getAll();
        languageDic= allFields.values();
        List<String> templateId = new List<String>();
        for(SDL_Dictionaries__c sd: languageDic){
            if(sd.Status__c){ 
            templateId.add(sd.Id__c);
            break;
            }
        }
        
        SDL_Language_Pairs__c sdlLangaugePair;
        
        try{
            sdlLangaugePair = [select id, Domain_Code__c from SDL_Language_Pairs__c where FromCode__c =:fromLanguage and ToCode__c =:toLanguage and status__c = true];
        }catch(Exception e){}
        
        
        Map<String,object> requestMap = new Map<String,object>();
        requestMap.put('text',selectedText);
        requestMap.put('from',fromLanguage);
        requestMap.put('to',toLanguage);
        /*if(templateId!=null && templateId.size() > 0)
          requestMap.put('termbaseIds', templateId);*/
        if(sdlLangaugePair !=null && sdlLangaugePair.Domain_Code__c!=null){
            requestMap.put('domainCode', sdlLangaugePair.Domain_Code__c+'');
        //system.debug('doaminCode='+sdlLangaugePair.Domain_Code__c);    
        }  
        
        Map<String, Object> resMap = new Map<String, Object>();
        SDL_Translation_Settings__c sdlSettings = EnvinormentalConstants.getInstance().sdlSettings;
        system.debug('requestMap='+requestMap);
        resMap = RestApi.invoke(EnvinormentalConstants.SDL_BASE_URL+EnvinormentalConstants.SDL_Translate_url,'POST',requestMap,sdlSettings.APIKey__c);
        
        if(resMap.get('charCount')!=null){
            sdlSettings.Usage__c = sdlSettings.Usage__c+(Integer)resMap.get('charCount');
            upsert sdlSettings;
        }
        
        return resMap;
        
    }
   
   public class LanguageDetectResponce{
       public LanguageDetectResult[] result{set;get;}
   
   }
   
   public class LanguageDetectResult{
       public String confidence{set;get;}
       public LanguageDetectDetails language{set;get;}
       
   }
   
   public class LanguageDetectDetails{
       public String threeLetterCode{set;get;}
       public String languageCode{set;get;}
       public String defaultSpecificLanguageCode{set;get;}
       public String englishName{set;get;}
       public String parentLanguageCode{set;get;}
       public String direction{set;get;}
   }
   
 }