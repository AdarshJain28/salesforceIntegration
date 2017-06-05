global with sharing class liveAgentLanguageWrapper{
    
    /****** added in the wrapper for Error Handling ******/
    @AuraEnabled
    public boolean isError {get; set;}  
    @AuraEnabled
    public String errorMessage {get; set;}
    
    /****** wrapper classes which is used for parsing the language pairs json response ******/
    public class Q1 {
        @AuraEnabled
        public LanguagePair languagePair {get;set;} 
        @AuraEnabled
        public String activity {get;set;} 
    }
    @AuraEnabled
    public LanguageExpertise languageExpertise {get;set;} 
    
    
    public class From_Z {
        @AuraEnabled
        public String id {get;set;} 
        @AuraEnabled
        public String apiVersion {get;set;} 
        @AuraEnabled
        public String code {get;set;} 
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String fullName {get;set;}
        @AuraEnabled 
        public Boolean rightToLeft {get;set;} 
        @AuraEnabled
        public String locale {get;set;} 
        @AuraEnabled
        public String comments {get;set;} 
        @AuraEnabled
        public Boolean active {get;set;} 
    }
    public class LanguagePair {
        @AuraEnabled
        public From_Z from_Z {get;set;} // in json: from
        @AuraEnabled
        public From_Z to {get;set;} 
        
    }
    public class LanguageExpertise {
        @AuraEnabled
        public List<Q1> Q1 {get;set;} 
        
    }
    
    /****** wrapper classes which is used for parsing the detect language json response ******/
    public class Language {
        @AuraEnabled
        public String threeLetterCode;
        @AuraEnabled
        public String languageCode;
        @AuraEnabled
        public String defaultSpecificLanguageCode;
        @AuraEnabled
        public String englishName;
        @AuraEnabled
        public String parentLanguageCode;
        @AuraEnabled
        public String direction;
    }
    @AuraEnabled
    public Integer totalCount;
    @AuraEnabled
    public List<Result> result;
    public class Result {
        @AuraEnabled
        public Double confidence;
        @AuraEnabled
        public Language language;
    }
    public liveAgentLanguageWrapper(){
        isError = false;
        errorMessage = '';
    }
    @AuraEnabled
    public List<TranslationEngines> translationEngines {get;set;} 
    public class TranslationEngines {
        @AuraEnabled
        public Boolean trustScoreEnabled {get;set;} 
        @AuraEnabled
        public From_Z From_Z {get;set;} 
        @AuraEnabled
        public From_Z to {get;set;} 
        @AuraEnabled
        public String From_ZLanguageId {get;set;}
        @AuraEnabled 
        public String From_ZLanguageCode {get;set;} 
        @AuraEnabled
        public String From_ZCulture {get;set;} 
        @AuraEnabled
        public String toLanguageId {get;set;} 
        @AuraEnabled
        public String toLanguageCode {get;set;} 
        @AuraEnabled
        public String toCulture {get;set;} 
        @AuraEnabled
        public String domainCode {get;set;} 
        @AuraEnabled
        public String domainDescription {get;set;} 
        @AuraEnabled
        public String type_Z {get;set;} // in json: type
    }
    public class To {
        @AuraEnabled
        public Boolean rightToLeft {get;set;} 
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String locale {get;set;} 
        @AuraEnabled
        public Boolean active {get;set;} 
        @AuraEnabled
        public String fullName {get;set;} 
        @AuraEnabled
        public String code {get;set;} 
        @AuraEnabled
        public String comments {get;set;} 
    
    }
    
    public class TranslatedResponse{
        @AuraEnabled
        public String to {get;set;} 
        @AuraEnabled
        public String translation {get;set;} 
        @AuraEnabled
        public String from_Z {get;set;} // in json: from
        @AuraEnabled
        public Boolean partialTranslation {get;set;} 
        @AuraEnabled
        public Integer wordCount {get;set;} 
        @AuraEnabled
        public Integer charcount {get;set;}
        @AuraEnabled
        public boolean isError {get; set;} 
        @AuraEnabled 
        public String errorMessage {get; set;}
        
        public TranslatedResponse(){
            isError = false;
            errorMessage = '';
        }
     
    }
    public class Termbases {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String description;
    }
    @AuraEnabled
    public List<Termbases> termbases;

    public class Details {
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String code {get;set;} 
        @AuraEnabled
        public String value {get;set;} 
    }
    @AuraEnabled
    public String message {get;set;} 
    @AuraEnabled
    public String errorCode {get;set;} 
    @AuraEnabled
    public List<Details> details {get;set;} 


    }