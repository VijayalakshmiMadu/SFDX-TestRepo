public with sharing class PersonAccountSideBarController {

Public Account Acc{get;set;}
Public Id AccId{get;set;}

    public PersonAccountSideBarController(){
        AccId = ApexPages.CurrentPage().getParameters().get('id');
        Acc=[SELECT Id,FirstName,LastName,phone,BillingCountryCode,isPersonAccount,BillingStreet,BillingCity,BillingStateCode,BillingPostalCode,Treatment__c,BGTestFrequency__c,ServiceInstruction__c,CustomerInsight__c,Status__c,PersonBirthdate,InsuranceNumber__c,PersonEmail,InsuranceStatus__c FROM Account WHERE Id =:Accid ];
    }
    public PageReference save(){
         try{
            update Acc;  
        }catch (DMLException ex) {
             ApexPages.addMessages(ex);
          }
        return null;
    }
    public void edit(){
    
    }
}