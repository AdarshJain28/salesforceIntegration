public class languageWrapper {

    @AuraEnabled public Integer totalCount {get;set;} 
    @AuraEnabled public List<TranslationEngines> translationEngines {get;set;}
    public class TranslationEngines {
        @AuraEnabled public Boolean trustScoreEnabled {get;set;} 
        @AuraEnabled public From_Z from_Z {get;set;} // in json: from
        @AuraEnabled public From_Z to {get;set;} 
        @AuraEnabled public String fromLanguageId {get;set;} 
        @AuraEnabled public String fromLanguageCode {get;set;} 
        @AuraEnabled public String fromCulture {get;set;} 
        @AuraEnabled public String toLanguageId {get;set;} 
        @AuraEnabled public String toLanguageCode {get;set;} 
        @AuraEnabled public String toCulture {get;set;} 
        @AuraEnabled public String domainCode {get;set;} 
        @AuraEnabled public String domainDescription {get;set;} 
        @AuraEnabled public String type_Z {get;set;} // in json: type
    }
    
    public class From_Z {
        @AuraEnabled public String code {get;set;} 
        @AuraEnabled public String locale {get;set;} 
        @AuraEnabled public String name {get;set;} 
        @AuraEnabled public String fullName {get;set;} 
        @AuraEnabled public String comments {get;set;} 
        @AuraEnabled public Boolean active {get;set;} 
        @AuraEnabled public Boolean rightToLeft {get;set;} 
    }
    
}