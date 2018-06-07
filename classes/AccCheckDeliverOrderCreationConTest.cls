@istest(seeAllData=False)
Public class AccCheckDeliverOrderCreationConTest{
Public static testmethod void AccCheckDeliverOrderCreation(){
 Id FOCDirectRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC Direct').getRecordTypeId();
 Id FocUsRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC US').getRecordTypeId();
 Id GiveAwayRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Give Away').getRecordTypeId();     
 Id StandingRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standing Order').getRecordTypeId();
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
 //FocDirect.ShippingCountrycode = 'United States';
 //FocDirect.ShippingStreet= 'Wall Mart Street';
// FocDirect.ShippingCity= 'South Carolina';
 //FocDirect.ShippingStateCode= 'South Carolina';
 //FocDirect.ShippingPostalCode= '637456';
 FocDirect.Pricebook2Id = label.Accu_Check_Pricebook_Id; 
 FocDirect.One_Order__c = True;
 Database.insert (FocDirect);
 PageReference pgr = page.AccCheckDeliverOrderCreationPage;
 pgr.getParameters().put('id',FocDirect.id);
 Test.SetCurrentPage(pgr);
 System.currentPageReference().getparameters().put('id',FocDirect.id);                   
 AccCheckDeliverOrderCreationController AccuCheckOrd = new AccCheckDeliverOrderCreationController();
 AccuCheckOrd.orderSave();
 AccuCheckOrd.cancelBtn();
 AccuCheckOrd.priceBookPopulate();
 AccuCheckOrd.getPricebookOptions();
 AccuCheckOrd.addressPopulate();

}
}