global with sharing class AdarshCustomLoginController {
    global String username {get; set;}
    global String password {get; set;}
      String communityUrl = 'https://adarshjaintest-dev-ed--c.ap4.visual.force.com/apex/customLogin';
      String customHomePage = '_ui/core/chatter/ui/ChatterPage';
    
    global AdarshCustomLoginController () {
       
      
       }
    global PageReference login() {
        //return new PageReference( '/_ui/core/chatter/ui/ChatterPage');
        AdarshCustomLoginController a = new AdarshCustomLoginController();
        a.username = 'test@salesforce.com';
        a.password = '123456';
        return Site.login(username, password, null);
       
               
    }
}