/*
 *@Author: Bit Order Technologies
 * This class is used as a Controller for SDL Translation Settings page and does following funtionalities:
 * - Saves On/Off of the translation.
 * - Updates SDL Translation API key.
 * - Fetches all page layout names from the org.
 * - Creates Translate Custom button in the selected objects.
 * - Updates the page layouts to add/remove the Translate button.
 * - Saves the page layout details in SDL Translation PageLayout settings object.
 * - Displays all Language pairs along with status in order to add/remove the Language pair for translation.
 * - Fetches all available language Dictionary from the user supscription.
 * - Updates the dictionary when it is removed/added in the SDL translation user account.  
 * - Fetches all the System administrator in the org.
 * - Allows to select the System administrator for mailing when translation limit is exceeded.
 * - Sends a email notification to all the selected System administrators when the translation usage is exceeded.
 * - Fetched the Usage history Dashboard in order to display the monthly usage history.
*/
public with sharing class SDLTranslationSettingsController {
    
    public SDL_Translation_Settings__c sdlSettings {get;set;}
    
    private static final Integer METADATA_API_VERSION = 
        Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));

    public List<SelectOption> MetaDataTypes {get; set;}
    public String MetaDataType {get; set;}      
    public List<SelectOption> MetaDataItems {get; set;}
    public List<SelectOption> selectedLayouts {get; set;}
    public String MetaDataFolder {get; set;} 
    public String MetaDataItem {get; set;}  
    public String MetadataFileData {get; set;}
    public MetadataService.AsyncResult AsyncResult {get; private set;}
    public String MetaDataRetrieveZip { get; private set; } 
    public Set<String> objectNames {get; set;}
    public List<SDL_Language_Pairs__c> languagePairs {get; set;}
    public String selectedDictionary {get; set;}
    public List<SelectOption> availableDictionaries {get; set;}
    public List<SDL_Dictionaries__c> languageDictionaries {get; set;}
    public List<user> systemAdminUserList {get; set;}
    public List<SelectOption> systemAdmins {get; set;}
    public List<SelectOption> selectedSystemAdmins {get; set;}
    public Decimal usagePercentage {get; set;}  
    public Dashboard sdlUsageHistoryDashboard {get; set;}
    public List<SelectOption> listOfWeblinksInSelectOption{get; set;}
    private MetadataService.MetadataPort service;
    public Boolean isTestMode = false;
    
    public Map<String, SDL_Translate_Page_Layout_Settings__c> sdlPageLayoutSettingsMap {get;set;}
    public Set<String> orgWebLinksSet = new Set<String>();
    
    public Boolean metadataConnectionWarning {get;set;}
    public String metadataApiException {get;set;}
    
    List<MetadataService.Layout> reItegrateLayoutsToAddButton{get;set;}
    
    List<MetadataService.WebLink> reItegrateToCreateButton{get;set;}

    /*
     * Fetches sdlSettings and SDL_Translate_Page_Layout_Settings details
     * Calls Metadata API to fetch all page layouts from the org.
     * Fetches Sdl Language pairs and displays all the availabe Language pairs along with the status selection.
     * Fetches the dictionary which are available for the organisation.
     * Fetches the Sdl transation usgae history dashboard for viewing the monthly translation usage.
     * Calculates the organinsations usage percentage.
    */
    public SDLTranslationSettingsController(){
        try{
            
            sdlSettings = EnvinormentalConstants.getInstance().sdlSettings; //[SELECT id, APIKey__c, isActive__c, MaxUsage__c, Usage__c, Target_Language_Preference__c,AdminsEmailAddress__c,(select id, Object_Id__c, Object_Name__c, Page_Layout_Id__c, Page_Layout_Name__c, Status__c from SDL_Translate_Page_Layout_Settings__r) FROM SDL_Translation_Settings__c limit 1];
            selectedLayouts =  new List<SelectOption>();
            systemAdmins = new list<SelectOption>();
            selectedSystemAdmins = new list<SelectOption>();
            systemAdminUserList = new list<user>();
            availableDictionaries = new list<selectOption>();
            objectNames = new Set<String>();
            sdlPageLayoutSettingsMap = new Map<String, SDL_Translate_Page_Layout_Settings__c>();
            
            
            for(SDL_Translate_Page_Layout_Settings__c stp: sdlSettings.SDL_Translate_Page_Layout_Settings__r){
                objectNames.add(stp.Page_Layout_Name__c.split('-')[0]);
                sdlPageLayoutSettingsMap.put(stp.Page_Layout_Name__c, stp);
            }
            
            getOrgPageLayouts();
            getOrgWebLinks();
            String showMessage = ApexPages.currentPage().getParameters().get('showMessage'); 
            if(showMessage != null && showMessage == 'false')
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'You can only select one Language Cloud Engine for each Language Pair (Baseline, Vertical or Custom). Please ensure only your prefered engine is selected for each language pair.'));
            
            if(showMessage != null && showMessage == 'true'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,'Setting details are updated successfully'));
            }
            
            /*** Calculates the organizations usage ***/
            usagePercentage=0.0;
            if((sdlSettings.Usage__c > 0) && (sdlSettings.MaxUsage__c > 0)&& (sdlSettings.Usage__c != null) && (sdlSettings.MaxUsage__c !=null)){
              Decimal usage= ((sdlSettings.Usage__c/sdlSettings.MaxUsage__c) * 100);
              usagePercentage=usage.setScale(1);
            }

            /*** Fetching Language Pairs for the organisation ***/
            languagePairs = new list<SDL_Language_Pairs__c>();
            Map<String,SDL_Language_Pairs__c> allFields = SDL_Language_Pairs__c.getAll();
            languagePairs = allFields.values();
            languagePairs.sort();
            
            map<String,String> fromToDomainMap = new Map<string,String>();
            for(SDL_Language_Pairs__c entry : allFields.values()){
                fromToDomainMap.put(entry.FromLanguage__c+entry.ToLanguage__c+entry.Domain_Code__c,entry.Name);   
            }
             
            list<String> fromToDomainList = new List<string>();
            fromToDomainList.addAll(fromToDomainMap.keySet());
            fromToDomainList.sort();
            System.debug('fromListSize'+fromToDomainList.size());
            
            languagePairs.clear(); 
            for(String lp : fromToDomainList){
                String fromLang =  fromToDomainMap.get(lp);
                languagePairs.add(allFields.get(fromLang));
                
            } 
            
            /*** Language Dictionaries for the organiosation ***/
            languageDictionaries = new list<SDL_Dictionaries__c>();
            Map<String,SDL_Dictionaries__c> allDictionariesFields = SDL_Dictionaries__c.getAll();
            languageDictionaries = allDictionariesFields.values();
            languageDictionaries.sort();
           
            availableDictionaries.add(new SelectOption('','--None--'));
             for(SDL_Dictionaries__c dictionary : languageDictionaries) 
                 {
                  availableDictionaries.add(new SelectOption(dictionary.name__c,dictionary.name__c)); 
                 } 
             for(SDL_Dictionaries__c sdlLangDictionary : languageDictionaries)
                {
                   if(sdlLangDictionary.status__c == true)  
                    selectedDictionary=sdlLangDictionary.name__c;
                } 
            /*** method called to display the  System Administration of the organisation***/
                     adminUserDisplay(); 
              
        }catch(Exception e){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,''+e.getMessage()));
        system.debug('Exception message:'+e.getMessage());
        if(e.getMessage().contains('Remote'))
        {
        MetadataConnectionWarning = true;
        System.debug('exception occured');
        }
        
        }
        try{
            if (Schema.sObjectType.Dashboard.isAccessible()) 
                sdlUsageHistoryDashboard = [SELECT DeveloperName,Id FROM Dashboard WHERE DeveloperName = 'SDL_Global_Team_usage_Dashboard' limit 1];
        }
        catch(exception ex){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,''+ex.getMessage()));
          system.debug('Exception message:'+ex.getMessage());
        }

    }
    
    /*
     * Fetches all the System administrators of the organization.
     * Adds the System administrators to a multiselect picklist. 
     * All the selected System administrator's email address is stored in the database for future reference.
     * If multiple System administrators are selected, then email address is split with comma as a key separation.
    */ 
    public void adminUserDisplay(){
       if (Schema.sObjectType.User.isAccessible()) 
           systemAdminUserList = [Select user.id, user.Email, user.FirstName, user.LastName, user.profile.name, user.Username, user.IsActive FROM user, user.profile where user.profile.name ='System Administrator' AND user.IsActive = true];  
       Set<string> emailslist = new Set<string>();
       String email = sdlSettings.AdminsEmailAddress__c;
          if(email != null){
              if(email.containsAny(',')){
                 emailslist.addAll(email.split(','));
              }
              else
                 emailslist.add(email);
          }       
          for(user record : systemAdminUserList){
              if(emailslist.contains(record.Email))
                 selectedSystemAdmins.add(new SelectOption(record.email,record.firstname+' '+record.lastname));
              else
                 systemAdmins.add(new SelectOption(record.email,record.firstname+' '+record.lastname));
             } 
    }
    
    /*
     * All the selected System administrator's email address is stored in database. 
     * If multiple System administrators are selected, then email address is stored with comma separated values.
     * All the email address are stored in the database for sending email when the usage is exceeded.
     * Updates all the changes made in sdlSettings.
    */ 
    public void saveAdminSetting(){
      list<string> email = new list<string>();
      if(selectedSystemAdmins.size() == 0 && selectedSystemAdmins == null)
        sdlSettings.AdminsEmailAddress__c ='';
      else{
        for(SelectOption selectopt : selectedSystemAdmins){
            String emailaddress= selectopt.getvalue();
            email.add(emailaddress);                  
        } 
        sdlSettings.AdminsEmailAddress__c = '';
        if(email != null)
          sdlSettings.AdminsEmailAddress__c =  String.join(email, ',');
      }
      if(Schema.sObjectType.SDL_Translation_Settings__c.fields.AdminsEmailAddress__c.isUpdateable())
          update sdlSettings;
    }

    /*
     * Fetches all the dictionary available for the user.
     * Checkes for the status of the sdlDictionary.
     * For a particlular instance of time only one dictionary can be selected.
     * None option is provided, so that we can ignore the dictionary if its not necessary.
    */
    public void saveDictionarySetting(){
      list<SDL_Dictionaries__c> sdlDictionary =  new list<SDL_Dictionaries__c>();
      Map<String,SDL_Dictionaries__c> allDictionariesFields = SDL_Dictionaries__c.getAll();
      sdlDictionary = allDictionariesFields.values();
      for(SDL_Dictionaries__c sdlDict : sdlDictionary){
         sdlDict.status__c = false;
      }   
      for(SDL_Dictionaries__c sdlDiction : sdlDictionary){
          if( (selectedDictionary != '--None--') && (selectedDictionary == sdlDiction.name__c) ){ 
            sdlDiction.status__c=true;
          }
      }
      update sdlDictionary; 
    }
    
    /*
     * Makes call to metadata API to create Translate Custom button in selected sobjects
     * Updates the Translate custom buttons for the selected sobjects.
    */
    public Boolean createCustomButtons(Set<String> sobjectNames){
        if(service == null)
            service = createService();
        
        List<MetadataService.WebLink> webLinks = new List<MetadataService.WebLink>();
        
        for(String sobjectName : sobjectNames){
            if(!orgWebLinksSet.contains(sobjectName)){
                System.debug('creating buttons for the objects :'+sobjectName);
                MetadataService.WebLink webLink = new MetadataService.WebLink();
                webLink.fullName = sobjectName+'.Translate';
                webLink.availability = 'online';
                webLink.displayType = 'button';
                webLink.encodingKey = 'UTF-8';
                webLink.linkType = 'javascript';
                webLink.masterLabel = 'Instant Translation';
                webLink.openType = 'onClickJavaScript';
                webLink.protected_x = false;
                //webLink.url = '{!REQUIRESCRIPT("/resource/jQueryForPopup/jQuery/jquery-1.8.2.min.js")}  {!REQUIRESCRIPT("/resource/jQueryForPopup/jQuery/ui/jquery-ui-1.9.1.custom.min.js")}  {!REQUIRESCRIPT("/resource/SDLTest")}';
                webLink.url = '{!REQUIRESCRIPT("/soap/ajax/30.0/connection.js")} {!REQUIRESCRIPT("/soap/ajax/30.0/apex.js")} {!REQUIRESCRIPT("/resource/SDL_Translate__SDL/SDL/JS/jquery.min.js")} {!REQUIRESCRIPT("/resource/SDL_Translate__SDL/SDL/JS/jquery-ui.js")} {!REQUIRESCRIPT("/resource/SDL_Translate__SDL/SDL/JS/SDLTranslate.js")}  ';
                webLinks.add(webLink);
            }
        }
        
        System.debug('webLinks === '+webLinks);
        
        Double webLinkSize = webLinks.size();
        
        if(webLinks!=null && webLinks.size()>0){
            Integer numberOfCalls = Integer.valueOf(Math.ceil(webLinkSize/10)); 
            Integer startIndex = 0;
            Integer endIndex = 10;
            System.debug('numberOfCalls === '+numberOfCalls);
            List<MetadataService.WebLink> subWebLinks = new List<MetadataService.WebLink>();
            for(Integer i = 0;i < numberOfCalls;i ++){
                subWebLinks.clear();
                if(i == numberOfCalls-1){
                    endIndex = webLinks.size();
                }else{
                    endIndex = 10*(i+1);
                }
                for(Integer j=(i*10)+1;j<=endIndex;j++){
                    subWebLinks.add(webLinks.get(j-1));
                }
                
                System.debug('subWebLinks === '+subWebLinks);
                 if(!istestmode){
                 try{
                    String status = handleSaveResults(service.createMetadata(subWebLinks)[0]);
                    if(!status.equals('true')){
                        reItegrateToCreateButtonInObjects(subWebLinks,status );
                    }
                 }catch(Exception e){
                     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,''+e.getMessage()));
                 }
              } 
              else{
                    handleSaveResults(null);
                }
            }
        }              
        return null;
    }
    
    /*
     * This method iterates for Translate button creation on the objects which are skipped.
     * Status specifies true or false whether to creation/non-creation of the button.
    */ 
    private void reItegrateToCreateButtonInObjects(List<MetadataService.WebLink> webLinks, String status){
        if(reItegrateToCreateButton == null)
            reItegrateToCreateButton = new List<MetadataService.WebLink>();
        else
            reItegrateToCreateButton.clear();
        if(!status.equals('true')){
          Integer j = 0;
          Boolean found = false;
          for(j = 0;j<webLinks.size();j++){
             MetadataService.WebLink webLink = webLinks.get(j);
             if(webLink.fullName.equals(status)){
               found = true;
             }
             if(found && !webLink.fullName.equals(status)){
                 reItegrateToCreateButton.add(webLink);
             }
                                                         
          }
          
          try{
              if(reItegrateToCreateButton!=null && reItegrateToCreateButton.size()>0){
                  String newStatus = handleSaveResults(service.createMetadata(reItegrateToCreateButton)[0]);
                  if(!newStatus.equals('true')){
                      reItegrateToCreateButtonInObjects(reItegrateToCreateButton ,newStatus );
                  }
              }
          }catch(Exception e){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,''+e.getMessage()));
          }
                         
        }
    }
    
    
    /*
     * Makes call to metadata API to update PageLayouts To Add Translate Button.
     * Checks whether the Translate custom button is present for the selected layout.
     * if the button is present in the sobject then it will update the PageLayout with the Translate button.
     * if button is deleted then the Translate button is created later added to the PageLayout.
    */
    public void updateLayoutsToAddTranslateButton(List<String> addButtonLayoutNames){
        if(service == null)
            service = createService();
            
        List<MetadataService.Layout> updatedLayouts = new List<MetadataService.Layout>();
        
        Double addButtonLayoutNamesSize = addButtonLayoutNames.size();
        
        Integer numberOfCalls = Integer.valueOf(Math.ceil(addButtonLayoutNamesSize/10));   
        Integer endIndex = 10;
            
        system.debug('addButtonLayoutNames === '+addButtonLayoutNames);
        system.debug('numberOfCalls === '+numberOfCalls);
        if(!istestmode)
        {
        if(addButtonLayoutNames!=null && addButtonLayoutNames.size()>0){   
            List<MetadataService.Layout> selectedLayoutMetadata = new List<MetadataService.Layout>();
            for(Integer i = 0;i < numberOfCalls;i ++){
                List<String> subUpdatedLayouts = new List<String>();
                if(i == numberOfCalls-1){
                    endIndex = addButtonLayoutNames.size();
                }else{
                    endIndex = 10*(i+1);
                }
                system.debug('endIndex === '+endIndex);
                for(Integer j=(i*10)+1;j<=endIndex;j++){
                    subUpdatedLayouts.add(addButtonLayoutNames.get(j-1));
                }
                system.debug('subUpdatedLayouts === '+subUpdatedLayouts.size());
                system.debug('subUpdatedLayouts === '+subUpdatedLayouts);
                selectedLayoutMetadata.clear();
                selectedLayoutMetadata =  (List<MetadataService.Layout>) service.readMetadata('Layout',subUpdatedLayouts).getRecords();
               
                System.debug('selectedLayoutMetadata: '+selectedLayoutMetadata);
                 for(MetadataService.Layout layout: selectedLayoutMetadata){
                    //if(layout.summaryLayout!=null){

                        System.debug('layout: '+layout);
                        
                        System.debug('layout.customButtons: '+layout.customButtons);
                        System.debug('layout.summaryLayout === : '+layout.summaryLayout);
                        /*if(layout.customButtons == null)
                            layout.customButtons = new List<String>();
                       layout.customButtons.add('Translate');*/
                       
                       if(layout.customButtons == null){
                            layout.customButtons = new List<String>();
                            layout.customButtons.add('Translate'); 
                        }else{
                            Boolean foundButton = false;
                            for(String buttonName: layout.customButtons){
                                if(buttonName.contains('Translate')){
                                    foundButton = true;
                                    break;
                                }
                            }
                            if(!foundButton){
                                layout.customButtons.add('Translate'); 
                            }
                        }
                        layout.customConsoleComponents = null;
                    //}     
                 } 
                 try{
                     String status = handleSaveResults(service.updateMetadata(selectedLayoutMetadata)[0]);
                     reItegrateLayoutsToAddButton = new List<MetadataService.Layout>();
                     if(!status.equals('true')){
                         reItegrateToAddButtonsInLayout(selectedLayoutMetadata,status );
                         
                     }
                 }catch(Exception e){
                     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,''+e.getMessage()));
                 }
            }
         }    
       }
    }
    
    /*
     * This method iterates for Translate button updating in the page layouts which are skipped.
     * Status specifies true or false whether to adding/removing of the button from the page layout.
    */ 
    private void reItegrateToAddButtonsInLayout(List<MetadataService.Layout> selectedLayoutMetadata, String status){
        if(reItegrateLayoutsToAddButton == null)
            reItegrateLayoutsToAddButton = new List<MetadataService.Layout>();
        else
            reItegrateLayoutsToAddButton.clear();
            
        if(!status.equals('true')){
          Integer j = 0;
          Boolean found = false;
          for(j = 0;j<selectedLayoutMetadata.size();j++){
             MetadataService.Layout layout = selectedLayoutMetadata.get(j);
             system.debug('999----'+layout.fullName);
             system.debug('888----'+layout);
             if(layout.fullName.equals(status)){
               found = true;
             }
             if(found && !layout.fullName.equals(status)){
                 reItegrateLayoutsToAddButton.add(layout);
             }
                                                         
          }
          
          try{
              if(reItegrateLayoutsToAddButton!=null && reItegrateLayoutsToAddButton.size()>0){
                  String newStatus = handleSaveResults(service.updateMetadata(reItegrateLayoutsToAddButton)[0]);
                  if(!newStatus.equals('true')){
                      reItegrateToAddButtonsInLayout(reItegrateLayoutsToAddButton,newStatus );
                  }
              }
          }catch(Exception e){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,''+e.getMessage()));
          }
                         
        }
    }
    
    /*
     * Makes call to metadata API to update PageLayouts To remove Translate Button.
     * Checks whether Translate custom button is exist for the selected PageLayout.
     * Removes the Translate custom button from the PageLayout.
     * Updates the Pagelayout after removing the Translate custom button.
    */
    private void updateLayoutsToRemoveTranslateButton(List<String> removeButtonLayoutNames){
        if(service == null)
            service = createService();
            
        List<MetadataService.Layout> updatedLayouts = new List<MetadataService.Layout>();
        
        Double removeButtonLayoutNamesSize = removeButtonLayoutNames.size();
        
        Integer numberOfCalls = Integer.valueOf(Math.ceil(removeButtonLayoutNamesSize/10));   
        Integer endIndex = 10;
            
        system.debug('removeButtonLayoutNames=== '+removeButtonLayoutNames);
        system.debug('numberOfCalls === '+numberOfCalls);
          if(!istestmode){
           if(removeButtonLayoutNames!=null && removeButtonLayoutNames.size()>0){    
            for(Integer i = 0;i < numberOfCalls;i ++){
                List<String> subUpdatedLayouts = new List<String>();
                if(i == numberOfCalls-1){
                    endIndex = removeButtonLayoutNames.size();
                }else{
                    endIndex = 10*(i+1);
                }
                system.debug('endIndex === '+endIndex);
                for(Integer j=(i*10)+1;j<=endIndex;j++){
                    subUpdatedLayouts.add(removeButtonLayoutNames.get(j-1));
                }
                system.debug('subUpdatedLayouts === '+subUpdatedLayouts.size());
                system.debug('subUpdatedLayouts === '+subUpdatedLayouts);
                
                List<MetadataService.Layout> deSelectedLayoutMetadata =  (List<MetadataService.Layout>) service.readMetadata('Layout',subUpdatedLayouts).getRecords();
                System.debug('deSelectedLayoutMetadata: '+deSelectedLayoutMetadata);
              
                 for(MetadataService.Layout layout: deSelectedLayoutMetadata){
                    //if(layout.summaryLayout!=null){
                        if(layout.customButtons != null){
                            system.debug('layout.customButtons = '+layout.customButtons);
                            for(integer k =0;k<layout.customButtons.size();k++){
                                String buttonName = layout.customButtons.get(k);
                                if(buttonName.contains('Translate')){
                                    layout.customButtons.remove(k);  
                                }
                            }
                        }
                        layout.customConsoleComponents = null;  
                    //}
                }
                try{
                    handleSaveResults(service.updateMetadata(deSelectedLayoutMetadata)[0]);
                }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,''+e.getMessage()));
                }
              }
           }
        } 
    }
    
    /*
     * Creates a quick action link name SDLTranslate on the global Object.
     * If the quick action link is already present then it skips the quick action link creation.
     * A boolean parameter specifies whether to add/remove the quick action link on the chatter page.
     * When the quick action link is added/removed from the chatter page, it is updated in the database about its status.
    */      
    private void chatterPageTranslation(Boolean chatterTranslate,String chatterLayoutName){
        
        if(chatterTranslate == true){
          MetadataService.MetadataPort service = createService();
            MetadataService.QuickAction quickaction = new MetadataService.QuickAction();
            quickaction.type_x = 'VisualforcePage';
            quickaction.height = 150;
            quickaction.width = 250;
            quickaction.label = 'SDLTranslate';
            quickaction.fullName = 'SDLTranslate';
            quickaction.page_x = 'SDL_Translate__SDLQuickActionLinkForChatter';
            List<MetadataService.SaveResult> results =service.createMetadata(new MetadataService.Metadata[] { quickaction});
            try{
               handleSaveResults(results[0]);
            }
            catch(Exception ex){    
            }         
            system.debug('adding layout name is ='+chatterLayoutName);
            boolean isTranslate = checkOrgQuickActions();
            system.debug('isTranslate ------->' +isTranslate);
            if(isTranslate){
                MetadataService.Layout layout = (MetadataService.Layout) service.readMetadata('Layout',new String[] {chatterLayoutName}).getRecords()[0];
                //MetadataService.Layout layout = (MetadataService.Layout) service.readMetadata('Layout',new String[] {'Account-botdev__Account Layout' }).getRecords()[0];
                
                System.debug('global layout=');
                
                MetadataService.QuickActionListItem quickActionItem = new MetadataService.QuickActionListItem();
                quickActionItem.quickActionName = 'SDLTranslate';
                
                
                  if(layout.quickActionList != null && layout.quickActionList.quickActionListItems != null){
                  
                 // if(layout.quickActionList.quickActionListItems.size() > 1){
                      layout.quickActionList.quickActionListItems.add(1,quickActionItem);  //}
                //  else{
                //      layout.quickActionList.quickActionListItems.add(0,quickActionItem);  }
                  }
                try{
                     handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]); 
                }
                catch(Exception ex){    
                } 
            }    
        }
        else{
            MetadataService.MetadataPort service = createService();
            system.debug('removed layout name is ='+chatterLayoutName);       
            MetadataService.Layout layout = (MetadataService.Layout) service.readMetadata('Layout',new String[] {chatterLayoutName}).getRecords()[0];             
            //MetadataService.Layout layout = (MetadataService.Layout) service.readMetadata('Layout',new String[] {'Account-botdev__Account Layout' }).getRecords()[0];
            
            
            for(Integer i=0;i<layout.quickActionList.quickActionListItems.size();i++){
             System.debug('removed3'+layout.quickActionList.quickActionListItems[i].quickActionName);
                if(layout.quickActionList.quickActionListItems[i].quickActionName.contains('SDLTranslate')){
                    system.debug('inside removed 3'+i);
                    layout.quickActionList.quickActionListItems.remove(i);               
                    break;
                }
            }
            
            try{
                 handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);  
        
            }
            catch(Exception ex){    
            }           
        }
    
    }
    
    /*
     * Custom Exception class when an exception is trown if erros=rs are found.
    */        
    public class SDLTranslateSettingsException extends Exception { }
    
    /*
     * Example helper method to interpret a SaveResult, throws an exception if errors are found.
     * Error message is displayed when exception is thrown.
    */
    public static String handleSaveResults(MetadataService.SaveResult saveResult){
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return 'true';
        // Construct error message and throw an exception
        if(saveResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' + 
                    ( error.fields!=null && error.fields.size()>0 ? 
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            //if(messages.size()>0)
                //throw new SDLTranslateSettingsException(String.join(messages, ' '));
        }
        //if(!saveResult.success)
            //throw new SDLTranslateSettingsException('Request failed with no specified error.');
      
        return saveResult.fullName;
    }
    
    /*
     * This method is used to save all the SDL Translation settings.
     * Makes a check whether the PageLayout has a Translate custom button.
     * Creates a Translate custom button on the selected PageLayouts.
     * Updating the Translate custom button on the layouts.
     * Saves the Language pairs for the changes made.
     * Page message is displayed when all the updation is successful.
    */
    public PageReference saveSettings(){
        system.debug('test111-----');
         try{
            Boolean results = validatingSDLLanguageEngine();
            if(results == false){
               PageReference sdlSettingsPage = new PageReference('/apex/SDLTranslationSettings?showMessage=false');
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'You can only select one Language Cloud Engine for each Language Pair (Baseline, Vertical or Custom). Please ensure only your prefered engine is selected for each language pair.'));
               return sdlSettingsPage; 
            }
            else{
            
            Set<String> createButtonForobjectNames = new Set<String>();
            List<String> addButtonLayoutNames = new List<String>();
            List<String> removeButtonLayoutNames = new List<String>();
            List<String> objectNameIs = new List<string>();
            List<String> ListOfWeblink = new List<String>();
            String chatterLayoutName;
            Boolean chatterTranslate = false;
            //getOrgWebLinks();
            if(!isTestMode){
            for ( SelectOption selectops : listOfWeblinksInSelectOption ){
                String weblinknames = selectops.getValue();
                ListOfWeblink.add(weblinknames);
                System.debug('weblinks are'+ListOfWeblink);
                }
            }
            else{
               SdlUtility.weblinkListing(listOfWeblinksInSelectOption,ListOfWeblink);
            } 
            system.debug('selectedLayouts--- '+selectedLayouts);
             if(selectedLayouts.size() > 0){
                for ( SelectOption so : selectedLayouts ) {
                    String pageLayoutName = so.getValue();
                    if(sdlPageLayoutSettingsMap.keySet().size()>0 && sdlPageLayoutSettingsMap.keySet().contains(pageLayoutName)){
                        SDL_Translate_Page_Layout_Settings__c stp = sdlPageLayoutSettingsMap.get(pageLayoutName);
                        if(stp.Status__c == false|| stp.Status__c == true){
                            stp.Status__c = true;
                            String objectName=pageLayoutName.split('-')[0];
                            Boolean flag = false;
                            for(String wb : ListOfWeblink){
                            system.debug('weblinks are:'+wb);
                            string obj = (objectName+'.Translate');
                            system.debug('object and translate '+obj);
                               if((obj.contains(wb))){
                                flag = true;
                                system.debug('falg is set to true');
                                }    
                             }
                              if(!flag){
                                createButtonForobjectNames.add(objectName);
                                    system.debug('objects to create button are :'+createButtonForobjectNames);
                                }  
                              if(pageLayoutName.contains('Global')){
                               chatterLayoutName = pageLayoutName;
                               chatterTranslate = true;
                            }     
                            else   
                                addButtonLayoutNames.add(pageLayoutName);
                        }
                    }else{
                        SDL_Translate_Page_Layout_Settings__c stp = new SDL_Translate_Page_Layout_Settings__c();
                        stp.Object_Name__c = pageLayoutName.split('-')[0];
                        stp.Page_Layout_Name__c = pageLayoutName;
                        stp.Status__c = true;
                        stp.SDL_Translation_Settings__c = sdlSettings.id;
                        sdlPageLayoutSettingsMap.put(pageLayoutName, stp);
                        if(!objectNames.contains(pageLayoutName.split('-')[0])){
                            createButtonForobjectNames.add(pageLayoutName.split('-')[0]);   
                        }
                        if(pageLayoutName.contains('Global')){
                            chatterLayoutName = pageLayoutName; 
                            chatterTranslate = true;   
                        }     
                        else
                            addButtonLayoutNames.add(pageLayoutName);
                    }  
                }
            }
            
            for ( SelectOption so : MetaDataItems ) {
                String pageLayoutName = so.getValue();
                system.debug('sdlPageLayoutSettingsMap = '+sdlPageLayoutSettingsMap);
                if(sdlPageLayoutSettingsMap.keySet().size()>0 && sdlPageLayoutSettingsMap.keySet().contains(pageLayoutName)){
                    system.debug('inside for loop = '+pageLayoutName);
                    if(pageLayoutName.contains('Chatter'))
                        pageLayoutName = pageLayoutName.replace('Chatter','Global');
                    SDL_Translate_Page_Layout_Settings__c stp = sdlPageLayoutSettingsMap.get(pageLayoutName);
                    if(pageLayoutName.contains('Global')){
                        stp.Status__c = false;
                        chatterLayoutName = pageLayoutName; 
                        chatterTranslate = false;   
                    }   
                    else{
                    if(stp.Status__c == true){
                        stp.Status__c = false;
                        removeButtonLayoutNames.add(pageLayoutName);
                    }    
                  }
                }
            }            
                
            if(createButtonForobjectNames.size() > 0)
                Boolean cStatus = createCustomButtons(createButtonForobjectNames);
            
            if((addButtonLayoutNames != null && addButtonLayoutNames.size() > 0))
                updateLayoutsToAddTranslateButton(addButtonLayoutNames);
                
            if((removeButtonLayoutNames!=null && removeButtonLayoutNames.size()>0))
                updateLayoutsToRemoveTranslateButton(removeButtonLayoutNames);
            system.debug('chatterLayoutName----------->  '+chatterLayoutName);
            system.debug('chatterTranslate-------------> '+chatterTranslate);
            if(chatterLayoutName != null){
                chatterPageTranslation(chatterTranslate,chatterLayoutName);}
            if (Schema.sObjectType.SDL_Translation_Settings__c.fields.AdminsEmailAddress__c.isUpdateable())
                update sdlSettings;
            
            List<SDL_Translate_Page_Layout_Settings__c> sdlPageLayoutSettingsList = sdlPageLayoutSettingsMap.values();
            if(sdlPageLayoutSettingsList.size() > 0){
                if (Schema.sObjectType.SDL_Translate_Page_Layout_Settings__c.isCreateable())
                    upsert sdlPageLayoutSettingsList;
            }
            
            //saves SDL language dictionary.
              saveAdminSetting();
              saveDictionarySetting();
              
            //saveLanguagePairs when status is changed
                update languagePairs;
            
                PageReference sdlSettingsPage = new PageReference('/apex/SDLTranslationSettings?showMessage=true');
    
                sdlSettingsPage.setRedirect(true);
                
                return sdlSettingsPage;    
             
           } 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,''+e.getMessage()));
        }
        
        return null;
    }
    
    public static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    
    /*
     * This method is used to fetch all the page layouts from the Org by making call to metadata API.
     * Fetches all the PageLayouts existing in the org.
     * PageLayout is organised when the orgs have Namespace.
    */
    private void getOrgPageLayouts() {
        MetadataService.FileProperties[] fileProperties = listMetadataItems('Layout');
        
        // Sort
        List<String> fullNames = new List<String>();
        Map<String,String> fullNamesAndNamespaces = new Map<String,String>();
        Set<String> pageLayoutSet = sdlPageLayoutSettingsMap.keySet();
        if(!istestmode){
        if(fileProperties!=null){
            for(MetadataService.FileProperties fileProperty : fileProperties){
                System.debug('fullName = '+fileProperty.fullName);
                System.debug('namespacePrefix = '+fileProperty.namespacePrefix);
                //fullNames.add(fileProperty.fullName);  
                String namespace = '';
                if(fileProperty.namespacePrefix!=null && fileProperty.namespacePrefix!=''){
                    namespace = fileProperty.namespacePrefix;
                }
                fullNamesAndNamespaces.put(fileProperty.fullName,namespace);
            }
            
            fullNames.addAll(fullNamesAndNamespaces.keySet());
            fullNames.sort();
            //Set<String> fullNamesSet = fullNamesAndNamespaces.keySet();
            for(String fullName : fullNames){
                if(fullName!=null && !fullName.equals('CaseInteraction-Case Feed Layout') && !fullName.equals('CaseClose-Close Case Layout') && !fullName.equals('EnvironmentHubMemberRel-Environment Hub Member Relationship Layout') && !fullName.equals('SocialPersona-Social Persona Layout') && !fullName.equals('SocialPost-Social Post Layout') && !fullName.equals('SsoUserMapping-Single Sign-On User Mapping Layout') && !fullName.equals('CollaborationGroup-Group Layout') && !fullName.equals('FeedItem-Feed Item Layout') && !fullName.equals('SDL_Translate_Page_Layout_Settings__c-SDL Translate Page Layout Settings Layout') && !fullName.equals('UserAlt-User Profile Layout') && !fullName.equals('CaseMilestone-Case Milestone Layout') && !fullName.equals('UserProvisioningRequest-User Provisioning Request Layout') && !fullName.equals('UserProvisioningLog-User Provisioning Log Layout') && !fullName.equals('UserProvAccount-User Provisioning Account Layout') && !fullName.equals('SOSSessionActivity-SOS Session Activity Layout') && !fullName.equals('SDL_Translate__SDL_Translate_Page_Layout_Settings__c-SDL Translate Page Layout Settings Layout') && !fullName.equals('SDL_Translate__SDL_Translation_Settings__c-SDL Translation Settings Layout') && !fullName.equals('SDL_Translate__SDL_Translation_Usage_History__c-SDL Translation Usage History Layout')){
                String objectName = fullName.split('-')[0];
                String layoutName; 
                if(!objectName.endswith('__x') && (!objectName.endsWithIgnoreCase('Role')) && !objectName.equals('User') && !objectName.equals('Pricebook2') && !objectName.equals('PricebookEntry') && !objectName.equals('CaseClose')){
                    String namespace = fullNamesAndNamespaces.get(fullName);
                    
                    if(namespace.equals('')){
                        layoutName = fullName.split('-',2)[1];
                    }else{
                        layoutName = namespace+'__'+fullName.split('-',2)[1];
                        if(objectName.endswith('__c')){
                            if(!objectName.split('-')[0].contains(namespace+'__'))
                                objectName = namespace+'__'+objectName;
                        }
                    }
                    
                    if(fullName.split('-')[1].contains('Global Layout')){
                    //String objName = fullName.split('-')[0];
                    //fullName = fullName.replace(objName,'Chatter');
                    fullName = fullName.replace('Global Layout','Chatter Layout');
                    } 
                    
                    String displayName = fullName.split('-')[0]+' : '+fullName.split('-',2)[1];
                    if(displayName.contains('__c')){
                         displayName = displayName.replaceAll('__c',' ');
                     }
                    if(displayName.contains('__')){
                        displayName = displayName.split('__')[1];
                     }                        
                    if(displayName.contains('_')){ 
                         displayName = displayName.replaceAll('_',' ');
                       }     
                    String optionValue = EncodingUtil.urlDecode(objectName+'-'+layoutName, 'UTF-8');
                    if(!pageLayoutSet.contains(optionValue)){
                        MetaDataItems.add(new SelectOption(optionValue,EncodingUtil.urlDecode(displayName, 'UTF-8')));
                    }else{
                        SDL_Translate_Page_Layout_Settings__c stp = sdlPageLayoutSettingsMap.get(optionValue);
                        System.debug('stp==='+stp);
                        if(stp.Status__c==true){
                            selectedLayouts.add(new SelectOption(optionValue,EncodingUtil.urlDecode(displayName, 'UTF-8')));
                        }else{
                            MetaDataItems.add(new SelectOption(optionValue,EncodingUtil.urlDecode(displayName, 'UTF-8')));
                        }
                    }
                    
                }
              }
              }
            }
            else{
                  SdlUtility.settingLayouts(MetaDataItems,selectedLayouts);
            }     
        }
    }
    
    /*
     * Fetches all the weblinks through Metadata api call.
     * All weblinks present in the org is retrieved inorder to avoid dupication of Translate custom button creation.
    */ 
    
    public boolean checkOrgQuickActions(){
        boolean isSdlTranslate = false;
        listOfWeblinksInSelectOption= new List<SelectOption>();
        List<String> orgQuickActionSet = new List<String>();    
        MetadataService.MetadataPort service = createService();          
        List<MetadataService.ListMetadataQuery> queries1 = new List<MetadataService.ListMetadataQuery>();       
        MetadataService.ListMetadataQuery queryweblink= new MetadataService.ListMetadataQuery();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0)
            queryweblink.folder = MetaDataFolder;
        queryweblink.type_x = 'QuickAction';
        queries1.add(queryweblink);
        if(!istestmode){
         MetadataService.FileProperties[] fileProperties = service.listMetadata(queries1, METADATA_API_VERSION); 
         if(fileProperties!=null){
            for(MetadataService.FileProperties fileProperty : fileProperties){
                String[] tempNames = fileProperty.fullName.replace('.','-').split('-');
                String objectName = tempNames[0];
                orgQuickActionSet.add(objectName);
            }
            
         }
       }
       for(string eachorgQuickActionSet : orgQuickActionSet){
          if(eachorgQuickActionSet == 'SDLTranslate')
                isSdlTranslate = true;
         }
     return isSdlTranslate;
    }
    
    
    public void getOrgWebLinks() {
        listOfWeblinksInSelectOption= new List<SelectOption>();
        List<String> fullNames = new List<String>();    
        MetadataService.MetadataPort service = createService();             
        List<MetadataService.ListMetadataQuery> queries1 = new List<MetadataService.ListMetadataQuery>();       
        MetadataService.ListMetadataQuery queryweblink= new MetadataService.ListMetadataQuery();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0)
            queryweblink.folder = MetaDataFolder;
        queryweblink.type_x = 'WebLink';
        queries1.add(queryweblink);
        if(!istestmode){
         MetadataService.FileProperties[] fileProperties = service.listMetadata(queries1, METADATA_API_VERSION); 
         /* MetadataService.FileProperties[] fileProperties = listMetadataItems('WebLink');
         List<String> fullNames = new List<String>();   */
        
         if(fileProperties!=null){
            for(MetadataService.FileProperties fileProperty : fileProperties){
                String[] tempNames = fileProperty.fullName.replace('.','-').split('-');
                String objectName = tempNames[0];
                //orgWebLinksSet.add(objectName);
                if(tempNames[1].contains('Translate')){
                    if(tempNames[0].contains('__c') && fileProperty.namespacePrefix!=null && fileProperty.namespacePrefix!=''){ 
                        objectName = fileProperty.namespacePrefix+'__'+tempNames[0];
                        system.debug('web ==== '+objectName  );
                    }
                    orgWebLinksSet.add(objectName);
                    
                }
                    
                fullNames.add(fileProperty.fullName);
            }
            System.debug('orgWebLinksSet === '+orgWebLinksSet);
            fullNames.sort();
            for(String fullName : fullNames){               
                listOfWeblinksInSelectOption.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
            }
         }
       }  
       else{
            SdlUtility.listingWebLinks(listOfWeblinksInSelectOption);
        }
    }
    
    /*
     *This is a generic method to the metadata details for a particular metadata type.
    */
    public MetadataService.FileProperties[] listMetadataItems(String metaDataType) {
        // List Metadata items for the selected Metadata Type
        MetaDataItems = new List<SelectOption>();       
        MetadataService.MetadataPort service = createService();             
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0)
            queryLayout.folder = MetaDataFolder;
        queryLayout.type_x = metaDataType;
        queries.add(queryLayout);       
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);
        
        return fileProperties;
    }
    
    /*
     * The SDL user supscription available dictionaries are fetched with help of Rest api.
     * Addition/Removal of the dictionary for the user subscription is updated to the database.
     * At a particular instance of time only one dictionary can be selected and status will be set.
     * Status is set to false for Dictionary which are not selected.
    */ 
    public void getSDLDictionaries(){
         
        languageDictionaries = new list<SDL_Dictionaries__c>();
        Map<String,SDL_Dictionaries__c> allDictionariesFields = SDL_Dictionaries__c.getAll();
        languageDictionaries = allDictionariesFields.values();
        system.debug('langDictValue'+languageDictionaries);
        languageDictionaries.sort();
        
        List<SDL_Dictionaries__c> sdlDicList = new List<SDL_Dictionaries__c>();
        Map<String, Object> resMap = new Map<String, Object>();
        resMap = RestApi.invoke(EnvinormentalConstants.SDL_BASE_URL+EnvinormentalConstants.SDL_Dictionaries_url,'GET',null,sdlSettings.APIKey__c);
        List<Object> lstObject = (List<Object>)resMap.get('termbases');
        if(lstObject!=null && lstObject.size()>0){
            for(Object result :lstObject) {
                Map<String,Object> dicParsed = (Map<String,Object>)result;
                Boolean contains = false;

                if(languageDictionaries!=null && languageDictionaries.size()>0){
                    allDictionariesFields = SDL_Dictionaries__c.getAll();
                    
                    String sdlId = (String)dicParsed.get('id');
                    if(allDictionariesFields.keySet().contains(sdlId)){
                        contains = true;
                    }
                }
                                
                if(!contains){
                    SDL_Dictionaries__c sd = new SDL_Dictionaries__c();
                    sd.name = (String)dicParsed.get('id');
                    sd.name__c = (String)dicParsed.get('name');
                    sd.Description__c = (String)dicParsed.get('description');
                    sd.Id__c = (String)dicParsed.get('id');
                    sdlDicList.add(sd);
                }
                
            }
            
            if(sdlDicList!=null && sdlDicList.size()>0){
                if (Schema.sObjectType.SDL_Dictionaries__c.isCreateable())
                    upsert sdlDicList;
            }
        }
       set<string> sdlIds = new set<string>();
       set<string> sdlToolIds = new set<string>();
       set<string> sdlIdToDel = new set<string>();
        
       if(lstObject!=null && lstObject.size()>0){
           for(Object output : lstObject) {
            Map<String,Object> outputParsed = (Map<String,Object>)output;
            String sdlId = (String)outputParsed.get('id');
            sdlToolIds.add(sdlId);
           }
       }
        
        for(SDL_Dictionaries__c sdlDict : languageDictionaries){
          boolean flag = true;
          string sdlId= sdlDict.id__c;
          if(!(sdlToolIds.contains(sdlId)))
            flag=false;
          if(flag==false)
            sdlIdToDel.add(sdlDict.id__c);
          system.debug('toDeleteDictionary'+sdlIdToDel);
        }
        if(sdlIdToDel.size() > 0 && sdlIdToDel != null){
        list<SDL_Dictionaries__c> LanguageDictToDelete = new list<SDL_Dictionaries__c>();
        for(string sdlid: sdlIdToDel){
          SDL_Dictionaries__c sdlDictionary = new SDL_Dictionaries__c();
          sdlDictionary = [select id,name from SDL_Dictionaries__c where id__c=:sdlid limit 1];
          LanguageDictToDelete.add(sdlDictionary);
        }
        delete LanguageDictToDelete;
       }
     } 
    
    /*
     * The SDL user supscription available Language pairs are fetched with help of Rest api.
     * Available Language pairs for the user subscription is updated to the database. 
     */
     
    public void saveLanguagePairs(){
     
        languagePairs = new list<SDL_Language_Pairs__c>();
        Map<String,SDL_Language_Pairs__c> allFields = SDL_Language_Pairs__c.getAll();
        languagePairs = allFields.values(); 
        languagePairs.sort();
        
        list<SDL_Language_Pairs__c> sdlLanguagePairs = new list<SDL_Language_Pairs__c>();
        Map<String, Object> resultMap = new Map<String, Object>();
         resultMap = RestApi.invoke(EnvinormentalConstants.SDL_BASE_URL+'/translation-engines','GET',null,EnvinormentalConstants.getInstance().sdlSettings.APIKey__c);
       
        String sdlJsonString = JSON.Serialize(resultMap); 
        String sdlJson = sdlJsonString .replaceAll('"from"','"froms"');
        
        JSONParser parser = JSON.createParser(sdlJson);
        SDLEngines engine = (SDLEngines)parser.readValueAs(SDLEngines.class);  
       
         for(Integer i=0;i<engine.translationEngines.size();i++)
          {
           SDL_Language_Pairs__c langPairs = new SDL_Language_Pairs__c();
               langPairs.name = String.valueOf(i+1);
               langPairs.FromLanguage__c = engine.translationEngines[i].froms.fullName;
               langPairs.FromCode__c = engine.translationEngines[i].froms.code;
               langPairs.FromID__c = engine.translationEngines[i].fromLanguageId;
               langPairs.ToLanguage__c = engine.translationEngines[i].to.fullName;
               langPairs.ToCode__c = engine.translationEngines[i].to.code;
               langPairs.ToID__c = engine.translationEngines[i].toLanguageId;
               langPairs.Domain_Code__c = engine.translationEngines[i].domainCode;
               langPairs.Type__c = engine.translationEngines[i].type;
               langPairs.Domain__c = engine.translationEngines[i].domainDescription;
               if(langPairs.Type__c.equals('BASELINE'))
                   langPairs.Status__c = true;    
            sdlLanguagePairs.add(langPairs);
        } 
         if(languagePairs.size() == 0 )
             insert sdlLanguagePairs;  
          else{
          List<Integer> count = new List<Integer>();
            for(SDL_Language_Pairs__c lang : languagePairs){
               Integer c = integer.valueof(lang.name);
               count.add(c);
              system.debug('count'+count); 
            }
            
            Integer largest = count[0];
            for(Integer i=0;i<count.size();i++)
            {
             if(count[i]>largest )
                Largest = count[i];
                
            }
            system.debug('largest'+largest);      
             list<SDL_Language_Pairs__c> sdlLanguagePairsNew = new list<SDL_Language_Pairs__c>();
    
             if(sdlLanguagePairs != null && sdlLanguagePairs.size() > 0 ){
                for(SDL_Language_Pairs__c result :sdlLanguagePairs){
           
                     Boolean contains = false; 
                      
                    for(SDL_Language_Pairs__c lang : languagePairs){  
                      if((lang.FromID__c.equals(result.FromID__c)) && (lang.ToID__c.equals(result.ToID__c)) && (lang.Type__c.equals(result.Type__c)) )
                         contains = true;                
                     }
                    
                    if(!contains){
                        SDL_Language_Pairs__c langPair = new SDL_Language_Pairs__c();
                        langPair.name = String.valueOf(++largest);
                        langPair.FromLanguage__c = result.FromLanguage__c;
                        langPair.FromCode__c = result.FromCode__c;  
                        langPair.FromID__c = result.FromID__c;
                        langPair.ToLanguage__c = result.ToLanguage__c;
                        langPair.ToCode__c = result.ToCode__c; 
                        langPair.ToID__c = result.ToID__c; 
                        langPair.Domain_Code__c = result.Domain_Code__c;
                        langPair.Domain__c= result.Domain__c;
                        langPair.Type__c = result.Type__c;
                        if(langPair.Type__c.equals('BASELINE'))
                            langPair.Status__c = true;
                        sdlLanguagePairsNew.add(langPair);
                     }
                   }
                   
                   if(sdlLanguagePairsNew != null && sdlLanguagePairsNew.size() > 0){
                       insert sdlLanguagePairsNew;
                   }
              }
             
       } 
       
       /* Delete the SDL language pairs which are not in the SDL api */   
        languagePairs = new list<SDL_Language_Pairs__c>();
        Map<String,SDL_Language_Pairs__c> allField = SDL_Language_Pairs__c.getAll();
        languagePairs = allField.values();
        languagePairs.sort();
               
        list<SDL_Language_Pairs__c> sdlLanguagePairsDel = new list<SDL_Language_Pairs__c>();
        if(languagePairs != null && languagePairs.size() > 0 ){
        
            for(SDL_Language_Pairs__c lan : languagePairs){
               Boolean flag = false;
               for(SDL_Language_Pairs__c res : sdlLanguagePairs ){
                   if( res.FromID__c.equals(lan.FromID__c) && res.ToID__c.equals(lan.ToID__c) && res.Type__c.equals(lan.Type__c) )  
                          
                       if(res.Type__c!='BASELINE'){
                           if(res.Domain_Code__c.equals(lan.Domain_code__c)){
                               flag = true;
                           }
                       }else{
                           flag = true;
                       }
                      
               } 
               if(!flag)
                   sdlLanguagePairsDel.add(lan); 
            }
            if(sdlLanguagePairsDel.size() > 0 && sdlLanguagePairsDel!= null){
                delete sdlLanguagePairsDel;
           } 
        } 
    }
    
    /*
     * This methods validates if more than one translation engine is selected for same language pair.
     * Their are three Translation engines viz., Baseline,Vertical,Custom.
     * When the admin selected more that one translation engine an error message is displayed.
    */
    public boolean validatingSDLLanguageEngine(){
    
         set<String> sdlLang = new set<string>();
         Boolean Flag = true;
         
         for(SDL_Language_Pairs__c lang : languagePairs ){
             //String s1 = lang.FromID__c+lang.ToID__c+lang.Status__c;
             if(lang.Status__c == true){
                String s1 = lang.FromID__c+lang.ToID__c+lang.Status__c;             
             flag = sdlLang.add(s1);
             if(flag == false)
               break;   
          } 
         }
         /* if(flag==false){
             system.debug('duplicate present');
         }
         else
           update languagePairs; */ 
           
       return flag;            
        
  }  
    
    public class SDLEngines{
      public List<LanguagePair> translationEngines;
    }
    
    public class LanguagePair{
        public Boolean trustScoreEnabled;
        public fromSubTypes froms;
        public String fromLanguageId;
        public ToSubTypes to;
        public String toLanguageId;
        public String domainCode;
        public String domainDescription;
        public String type;
    }
    
    public class fromSubTypes{
       public String code;
       public String locale;
       public String name;
       public String fullName;
       public String comments;
       public Boolean active;
       public Boolean rightToLeft;
    }
    
    public class ToSubTypes{ 
       public String code;
       public String locale;
       public String name;
       public String fullName;
       public String comments;
       public Boolean active;
       public Boolean rightToLeft;
    }  
}