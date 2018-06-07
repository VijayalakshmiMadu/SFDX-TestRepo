@istest(seeAllData=False)
Public Class AccuCheckDeliverOrderNotificationTest{
Public static testmethod void AccuCheckDeliverOrderNotification(){
 Id FOCDirectRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC Direct').getRecordTypeId();
 Id FocUsRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC US').getRecordTypeId();
 List<Order> OrderList = new List<Order>(); 
  /*Creating Account Record*/
  Account acc = new Account();
  acc.name = 'Test Account 01';
  acc.BillingCity = 'Bangalore';
  acc.BillingCountry ='India';
  acc.BillingPostalCode='545662';
  acc.BillingStreet='Tk Road';       
  Database.insert (acc); 
  /*Creating Contact Record*/
  Contact con = new Contact();
  con.LastName='Contact Test01';
  con.FirstName='Test01';
  con.AccountId=acc.Id;
  con.IsActive__c=true;
  con.PrimaryContact__c=true;
  Database.insert (con);         
 /*Creating FocDirect Order Record*/         
 Order FocDirect = new Order();
 FocDirect.AccountId= label.Accu_Check_Account_Id;
 FocDirect.FoCReason__c= 'Marketing/DME';
 FocDirect.EffectiveDate= System.Today();
 FocDirect.RequestedDeliveryDate__c = System.Today()+7;
 FocDirect.status='Draft'; 
 FocDirect.RecordtypeId = FOCDirectRecordTypeId;
 FocDirect.AccountId = acc.id;
 FocDirect.Recipient_Name__c= Con.Id;
 FocDirect.Recipient_Text__c= 'Test';
 FocDirect.RecipientName__c= 'Contact Test' ;        
 FocDirect.One_Order__c = True;
 OrderList.add(FocDirect);
 //Database.insert (FocDirect);
 
 Order FocUs = new Order();
 FocUs.AccountId= label.Accu_Check_Account_Id;
 FocUs.FoCReason__c= 'Samples';
 FocUs.EffectiveDate= System.Today();
 FocUs.RequestedDeliveryDate__c = System.Today()+7;
 FocUs.status='Draft'; 
 FocUs.RecordtypeId = FOCDirectRecordTypeId;
 FocUs.AccountId = acc.id;
 FocUs.Recipient_Name__c= Con.Id;
 FocUs.Recipient_Text__c= 'Test';
 FocUs.RecipientName__c= 'Contact Test' ;        
 
 FocUs.One_Order__c = True;
 //Database.insert (FocUs);
  OrderList.add(FocUs);
 Insert OrderList;
 AccuCheckDeliverOrderNotification.sendNotification(OrderList);
}

}