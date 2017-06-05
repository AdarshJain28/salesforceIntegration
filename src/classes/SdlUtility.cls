public with sharing class SdlUtility {

    public static boolean isTest = false;
    
    /* Passing a list of weblinks for the Sdltranslation settings controller */
    public static List<string> weblinkListing (List<SelectOption> listOfWeblinksInSelectOption,List<string> ListOfWeblink) {
        listOfWeblinksInSelectOption=new List<SelectOption>();
        listOfWeblinksInSelectOption.add(new selectOption('Account.translate','Account.translate'));
        listOfWeblinksInSelectOption.add(new selectOption('Contact.translate','Contact.translate'));
        String weblinknames='Account.translate'; 
        ListOfWeblink.add(weblinknames);
        return ListOfWeblink;
    }   
    
    /* Selected PageLayouts are passed manually for test cases via SdlTranslation settings controller */
    public static void settingLayouts (List<SelectOption> MetaDataItems,List<SelectOption> selectedLayouts){
        selectedLayouts.add(new SelectOption('Account-Account Layout','Account : Account Layout'));
        selectedLayouts.add(new SelectOption('Case-Case Layout','Case : Case Layout'));
        MetaDataItems.add(new SelectOption('Contact-Contact Layout','Contact : Contact Layout'));
       // return (MetaDataItems,selectedLayouts);
    }
    
    public static List<SelectOption> listingWebLinks (List<SelectOption> listOfWeblinksInSelectOption){
        listOfWeblinksInSelectOption=new List<SelectOption>();
        listOfWeblinksInSelectOption.add(new SelectOption('account.translate','account.translate'));
        return listOfWeblinksInSelectOption;
    }
    
    /* Sends a email notification to the selected System administrators.
     * Fetches the Email template.
    */ 
    public Static void sdlEmailNotifying(List<string> sendMailTo,Decimal sdlUsage,Decimal sdlMaxUsage){
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      
      DateTime todayDate = datetime.now();
      String monthName= todayDate.format('MMMMMMMMM');
      
      if(sendMailTo.size() > 0 && sendMailTo != null){
          // creating new email
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          // setting the receiver email
          mail.setToAddresses(sendMailTo); 
          mail.setTargetObjectId(UserInfo.getUserId());
          mail.setSaveAsActivity(false);
          
          // from address
          mail.setReplyTo('quicktranslate@sdl.com');
          mail.setSenderDisplayName('SDL Global Team for Salesforce - Please contact us');
          mail.setSubject('SDL Global Team for Salesforce - Please contact us');  
          
          List<String> ccTo = new List<String>(); 
          ccTo.add('globalteam@sdl.com');
             mail.setCcAddresses(ccTo);  

          // setting the body
          EmailTemplate etid= new EmailTemplate() ;
          etid =[Select id,body,htmlvalue from EmailTemplate where DeveloperName = 'SDL_Notification' limit 1];
          
          String usage=sdlUsage.intValue().format();
          String maxUsage=sdlMaxUsage.intValue().format();
              
          string emailTemplateBody= etid.htmlvalue.replace('{month}',monthName);     
          string emailTemplateBodyReplace = emailTemplateBody.replace('{charactercount}',''+usage);     
          string emailTemplateBodyReplaced = emailTemplateBodyReplace.replace('{maxcharactercount}',''+maxUsage);
          
          mail.setHtmlBody(emailTemplateBodyReplaced);
          mails.add(mail);
         // sdlTrans.isActive__c=false;
      
      } 
      if(!isTest)
         Messaging.sendEmail(mails);  
   }
   
   public static void recordInsertionCheck( list<SDL_Translation_Settings__c> sdlNewTriggerValues){
    list<SDL_Translation_Settings__c> sdlSettings= new list<SDL_Translation_Settings__c>();  
      try{
          sdlSettings = [select id from SDL_Translation_Settings__c limit 1];
      }
      catch(Exception e){
      
      }
      
      for(SDL_Translation_Settings__c sdlTranslation : sdlNewTriggerValues){
        if(sdlSettings.size() > 0){
            sdlTranslation .addError('Already a record exists. Cannot create more than one record !');
        } 
      }  
  }

  public static void recordDeletionCheck(list<SDL_Translation_Settings__c> sdloldTriggerValues) {
   list<SDL_Translation_Settings__c> sdlTranslationSetting= new list<SDL_Translation_Settings__c>();
        sdlTranslationSetting=[select id from SDL_Translation_Settings__c limit 1];
        
        if(sdlTranslationSetting.size() < 2 ){
            for(SDL_Translation_Settings__c sdlDel : sdloldTriggerValues){
                sdlDel.adderror('cannot DELETE this record');
            }
        } 
   }
   
  public static void recordUpdationCheck(list<SDL_Translation_Settings__c> sdlSettingoldTriggerValues ,list<SDL_Translation_Settings__c> sdlSettingNewTriggerValues){
      
      for(SDL_Translation_Settings__c sdlTrans : sdlSettingNewTriggerValues){
        if((sdlSettingoldTriggerValues[0].Usage__c  < sdlTrans.MaxUsage__c) && (sdlTrans.Usage__c > sdlTrans.MaxUsage__c)){
            List<String> sendTo = new List<String>();
            SDL_Translation_Settings__c sdlsetting = new SDL_Translation_Settings__c();
            
            sdlsetting =  [select APIKey__c,isActive__c,MaxUsage__c,Target_Language_Preference__c,Usage__c,name,id,AdminsEmailAddress__c from SDL_Translation_Settings__c limit 1];
            string adminEmails=sdlSetting.AdminsEmailAddress__c;
            if( adminEmails != null && adminEmails.containsAny(',') ){
                list<string> emailList =adminEmails.split(',');
                   sendTo=emailList;
            }
            else
                sendTo.add(adminEmails);
                
            SdlUtility.sdlEmailNotifying(sendTo,sdlTrans.Usage__c,sdlTrans.MaxUsage__c);
        }
             
      }      
  
  }
 
}