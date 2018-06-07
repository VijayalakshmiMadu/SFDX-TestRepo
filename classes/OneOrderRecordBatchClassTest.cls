/************************************
Name         : OneOrderRecordBatchClassTest
Created By   : Chiranjeevi Gogulakonda
Company Name : Tech Mahindra
Project      : Roche Major Relase CRM 2018 Wave1(CRID_2002)
Created Date : 24/May/2018
Usages       : This batch Class is used to create FOC Direct,FOC US,Give Away orders based on standing order frequency.
Modified By  : 
*************************************/
@isTest(SeeAllData =false)
private with sharing class OneOrderRecordBatchClassTest {   
    /* Test clas method */
    static testmethod void OneOrderRecordBatchClass(){
        test.startTest(); 
        Id FOCDirectRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC Direct').getRecordTypeId();
        Id FocUsRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC US').getRecordTypeId();
        Id GiveAwayRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Give Away').getRecordTypeId();     
        Id StandingRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standing Order').getRecordTypeId();
        Id prodRcdType = Schema.SObjectType.Product2.RecordTypeInfosByName.get('Product Record').RecordTypeId;
        List<Order> OrderList = new List<Order>(); 
        List<Order> FinalList= new List<Order>(); 
         User us1 = [Select Id,name from User where profile.name ='System Administrator' AND IsActive= true limit 1];
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
         /*Creating Standing Order Record*/ 
        Order Standing = new Order();
        Standing.RecordtypeId = StandingRecordTypeId ; 
        Standing.AccountId= acc.id;
        Standing.EffectiveDate= System.Today(); 
        Standing.Status= 'Draft';
        Standing.Approver__c= us1.id; 
        Standing.Recurring_Order__c= True;         
        Standing.Recurrence_Start_Date__c= System.Today()-2;
        Standing.Recurrence_Frequency__c= 'Weekly';
        Standing.Recurrence_End_Date__c= System.Today()+24;
        Standing.One_Order__c = True;
        Database.insert(Standing);  
               
        /*Creating FocDirect Order Record*/         
        Order FocDirect = new Order();
        FocDirect.AccountId= label.Accu_Check_Account_Id;
        FocDirect.FoCReason__c= 'Marketing/DME';
        FocDirect.EffectiveDate= System.Today();
        FocDirect.RequestedDeliveryDate__c = System.Today()+7;
        FocDirect.status='Draft'; 
        FocDirect.RecordtypeId = FOCDirectRecordTypeId;
        FocDirect.Recipient_Name__c= Con.Id;
        FocDirect.Recipient_Text__c= 'Test';
        FocDirect.RecipientName__c= 'Contact Test' ;        
        FocDirect.One_Order__c = True;
        FocDirect.Standing_Order__c = Standing.id;
        Database.insert (FocDirect);          
        /*Creating FocUs Order Record*/  
        Order FocUs= new Order();
        FocUs.RecordtypeId = FocUsRecordTypeId ;
        FocUs.AccountId = acc.id;
        FocUs.FoCReason__c= 'Samples';
        FocUs.EffectiveDate= System.Today();
        FocUs.RequestedDeliveryDate__c = System.Today()+7;
        FocUs.Status = 'Draft';
        FocUs.Approver__c= us1.id; 
        FocUs.One_Order__c = True;
        FocUs.Standing_Order__c = Standing.id;
        Database.insert (FocUs);
        /*Creating GiveAway Order Record*/ 
        Order GiveAway= new Order();
        GiveAway.RecordtypeId = GiveAwayRecordTypeId ;
        GiveAway.AccountId = acc.id;
        GiveAway.Status = 'Draft';
        GiveAway.EffectiveDate= System.Today();
        GiveAway.One_Order__c = True;  
        GiveAway.Standing_Order__c = Standing.id;      
        Database.insert(GiveAway);
             
       /* OrderList.add(FocDirect);
        OrderList.add(FocUs);
        OrderList.add(GiveAway);
        OrderList.add(Standing);        
        For(order ord :OrderList){
            if(ord.RecordTypeId != StandingRecordTypeId ){
                ord.Standing_Order__c = Standing.id;
                FinalList.add(ord);
            }
        }
        if(FinalList.size()>0){
        Update FinalList; 
        }   
        */   
        /*Creating Product2 Record*/
        Product2 prod1=New Product2();
        Prod1.Name='ProductName1';
        Prod1.IsActive=true;
        Prod1.ProductCode='12334';
        Prod1.Family='ProdFamily';
        prod1.RecordTypeId = prodRcdType;
        Database.insert(prod1);        
        /*Creating PricebookEntry Record*/     
        PricebookEntry entyPb  = new PricebookEntry();
        entypb.Pricebook2Id = Test.getStandardPricebookId();
        entyPb.Product2Id = Prod1.Id;
        entyPb.UnitPrice = 0;
        entyPb.UseStandardPrice = false;
        Database.insert(entyPb);  
        List<OrderItem> listItems = new List<OrderItem>();
        for(integer j =0;j < orderlist.size();j++)
        {
            OrderItem orditem =new OrderItem();
            orditem.OrderId = orderlist[j].Id;
            orditem.PricebookEntryId = entyPb.Id;
            orditem.Quantity = 24;
            orditem.UnitPrice = 0;
            listItems.add(orditem);
        }
        string query = System.label.OneOrderRecurringBatchQuery;
        OneOrderRecordBatchClass new2 = new OneOrderRecordBatchClass(query);    
        Database.executeBatch(new2);                              
        Test.stopTest(); 
    }       
}