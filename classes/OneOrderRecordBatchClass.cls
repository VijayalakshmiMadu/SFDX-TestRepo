/************************************
Name         : OneOrderRecordBatchClass 
Created By   : Chiranjeevi Gogulakonda
Company Name : Tech Mahindra
Project      : Roche Major Relase CRM 2018(CRID_2002)
Created Date : 
Test Class   : OneOrderRecordBatchClassTest
Usages       : This batch Class is used to create FOC Direct,FOC US,Give Away orders based on standing order frequency.
Modified By  : 
*************************************/

global without sharing class OneOrderRecordBatchClass implements Database.Batchable<sObject>, Database.Stateful{    
    private String queryBatch = NULL;   
    /*To initialize and pass query*/
    Public OneOrderRecordBatchClass(String Query){
        queryBatch=Query;
    }   
    /*Start Method for the batch returns List of Values*/
    global Database.Querylocator start(Database.BatchableContext bc){  
        return Database.getQueryLocator(queryBatch);
    }  
    /* execute method for batch*/
    global void execute(Database.BatchableContext BC, List<order> scope){
        List<order> orderList = new List<order>();
        List<OrderItem> orderItemList = new List<OrderItem>();
        Map<String, RecurrenceOrder_CopyFields__c> rcoFields = new Map<String, RecurrenceOrder_CopyFields__c>();
        Map<String, RecurrenceOrderProduct_CopyFields__c> rcopFields = new Map<String, RecurrenceOrderProduct_CopyFields__c>();
        rcoFields = RecurrenceOrder_CopyFields__c.getAll();
        rcopFields = RecurrenceOrderProduct_CopyFields__c.getAll();
        
        Id FOCDirectRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC Direct').getRecordTypeId();
        Id FocUsRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC US').getRecordTypeId();
        Id GiveAwayRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Give Away').getRecordTypeId();
        
        List<Order> FinalList =  [SELECT Id,Standing_Order__c,Approver__c,Campaign__c,RecipientName__c,One_Order_External_Field__c,RelatedOrder__c,ShipToContactId,ShippingAddress__c,BillingAddress__c,RecordType.Name,PoNumber,OwnerId, RecordTypeId,FoCReason__c, currencyISOCode, AccountId,EffectiveDate,EndDate,Number_of_Reccurrence_Orders__c,BillingCountry,Recurring_Order__c,Recurrence_End_Date__c,RequestedDeliveryDate__c,Recurrence_Frequency__c,Recipient_Name__c,Recurrence_Start_Date__c,Status,Pricebook2Id,NoteOnInvoice__c,NoteToWarehouse__c,SupplementaryAddressLine__c,BillToContactId,One_Order__c,ShippingCountrycode,ShippingStreet,ShippingCity,ShippingStateCode,ShippingPostalCode,(Select UnitPrice, Quantity, PricebookEntryId, OrderItemNumber, OrderId, ListPrice, Id From OrderItems limit 1000) from Order where Standing_Order__c in : scope AND Status !='Completely Processed'];       
        system.debug('FinalList size'+FinalList.size() );                   
        /* Iterate over  return list  of order elements*/                 
        for(Order ord: scope){
            for(Order OneOrder: FinalList){
                system.debug('FinalList11'+FinalList);
                /* checks the condition Reccurrence frequency weekly*/
                if(ord.Number_of_Reccurrence_Orders__c > 0 && RecurrenceOrderSetting__c.getValues(ord.Recurrence_Frequency__c) <> NULL && Math.mod(ord.Recurrence_start_Date__c.DaysBetween(Date.today()),Integer.valueOf(RecurrenceOrderSetting__c.getValues(ord.Recurrence_Frequency__c).frequencyValue__c))==0){                
                    system.debug('&&&&&&');
                    Order FocDirect = new Order();
                    Order FocUs= new Order();
                    Order GiveAway= new Order();
                    
                    if(OneOrder.RecordTypeId == FOCDirectRecordTypeId)
                    {
                        system.debug('FOCDirectRecordTypeId'+FOCDirectRecordTypeId);
                        FocDirect.RecordtypeId = FOCDirectRecordTypeId;
                        FocDirect.AccountId = OneOrder.AccountId;
                        FocDirect.FoCReason__c= OneOrder.FoCReason__c;
                        FocDirect.EffectiveDate= OneOrder.EffectiveDate; 
                        FocDirect.RequestedDeliveryDate__c = OneOrder.RequestedDeliveryDate__c; 
                        FocDirect.Status= OneOrder.Status; 
                        FocDirect.CurrencyIsoCode ='USD';
                        FocDirect.Recipient_Name__c= OneOrder.Recipient_Name__c;      
                        FocDirect.ShippingCountrycode = OneOrder.ShippingCountrycode;
                        FocDirect.ShippingStreet= OneOrder.ShippingStreet;
                        FocDirect.ShippingCity= OneOrder.ShippingCity;
                        FocDirect.ShippingStateCode= OneOrder.ShippingStateCode;
                        FocDirect.ShippingPostalCode= OneOrder.ShippingPostalCode;
                        FocDirect.Pricebook2Id = OneOrder.Pricebook2Id;
                        FocDirect.One_Order__c = OneOrder.One_Order__c;             
                        FocDirect.RelatedOrder__c = ord.id;
                        //FocDirect.One_Order_External_Field__c = string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrder.id+1;
                        FocDirect.OrderExternelField__c = string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrder.id+1;  
                        orderList.add(FocDirect); 
                    }
                    if(OneOrder.RecordTypeId == FocUsRecordTypeId)
                    {
                        system.debug('FocUsRecordTypeId'+FocUsRecordTypeId);
                        FocUs.RecordtypeId = FocUsRecordTypeId ;
                        FocUs.AccountId = OneOrder.AccountId;
                        FocUs.FoCReason__c= OneOrder.FoCReason__c;
                        FocUs.EffectiveDate= OneOrder.EffectiveDate;
                        FocUs.RequestedDeliveryDate__c = OneOrder.RequestedDeliveryDate__c;
                        FocUs.Status = OneOrder.Status;
                        FocUs.CurrencyIsoCode ='USD';
                        FocUs.Approver__c=OneOrder.Approver__c;
                        FocUs.RecipientName__c =OneOrder.RecipientName__c;
                        FocUs.ShippingCountrycode = OneOrder.ShippingCountrycode;
                        FocUs.ShippingStreet= OneOrder.ShippingStreet;
                        FocUs.ShippingCity= OneOrder.ShippingCity;
                        FocUs.ShippingStateCode= OneOrder.ShippingStateCode;
                        FocUs.ShippingPostalCode= OneOrder.ShippingPostalCode;
                        FocUs.Pricebook2Id = OneOrder.Pricebook2Id;
                        FocUs.One_Order__c = OneOrder.One_Order__c;             
                        FocUs.RelatedOrder__c = ord.id;                
                        //FocUs.One_Order_External_Field__c = string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrder.id+2; 
                        FocUs.OrderExternelField__c = string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrder.id+2;                          
                        orderList.add(FocUs);
                    }
                    if(OneOrder.RecordTypeId == GiveAwayRecordTypeId)
                    {
                        system.debug('GiveAwayRecordTypeId'+GiveAwayRecordTypeId);
                        GiveAway.RecordtypeId = GiveAwayRecordTypeId ;
                        GiveAway.AccountId = OneOrder.AccountId;
                        GiveAway.Status = OneOrder.Status;
                        GiveAway.EffectiveDate= OneOrder.EffectiveDate;
                        GiveAway.CurrencyIsoCode ='USD';
                        GiveAway.Pricebook2Id = OneOrder.Pricebook2Id;
                        GiveAway.One_Order__c = OneOrder.One_Order__c;        
                        GiveAway.Campaign__c = OneOrder.Campaign__c;        
                        GiveAway.RelatedOrder__c = ord.id;
                        //GiveAway.One_Order_External_Field__c = string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrder.id+3;   
                        GiveAway.OrderExternelField__c = string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrder.id+3;                       
                        orderList.add(GiveAway);
                    }                                                                           
                }       
            } 
        }
        system.debug('%%%%%%%%%'+orderList.size());
        List<Database.Saveresult> dsrs = new List<Database.Saveresult>();
        if(orderList != null && orderList.size() >0){
            system.debug('%%%%%%%%%'+orderList.size());
            dsrs = Database.insert(orderList,true);
            //Insert orderList;
            system.debug('^^^^^^^^'+orderList.size()) ;
            system.debug('OrderIds'+dsrs) ;
            
        }    
        set<id> ordersId = new set<id>();
        for(Database.Saveresult sr: dsrs){
             system.debug('ordersId@@'+ordersId);
            if(sr.isSuccess()){
                 system.debug('ordersId###'+ordersId);
                ordersId.add(sr.getId());
                system.debug('ordersId'+ordersId);
            } 
            else{
                for(Database.Error err : sr.getErrors()) {}               
            }           
        }
        
        Map<String,Id> extIds = new Map<String,Id>();
        for(Order ord : orderList){
            if(ord.Id <> NULL){
                if(ordersId.contains(ord.Id)){
                    extIds.put(ord.One_Order_External_Field__c, ord.Id);
                }
            }
        }       
        system.debug('Enter the loop');
        for(Order ord: scope){
            if(ord.Number_of_Reccurrence_Orders__c > 0 && RecurrenceOrderSetting__c.getValues(ord.Recurrence_Frequency__c) <> NULL && Math.mod(ord.Recurrence_start_Date__c.DaysBetween(Date.today()),Integer.valueOf(RecurrenceOrderSetting__c.getValues(ord.Recurrence_Frequency__c).frequencyValue__c))==0){
                for(Order OneOrderItems: FinalList ){
                    for(OrderItem ordli: OneOrderItems.OrderItems){   
                        system.debug('Enter the loop');                                                            
                        //for(String str : rcoPFields.keySet()){  
                                OrderItem FocDirectOrderItem = new OrderItem();
                                OrderItem FocUsOrderItem = new OrderItem();
                                OrderItem GiveAwayOrderItem = new OrderItem(); 
                            if(OneOrderItems.RecordTypeId == FOCDirectRecordTypeId){
                                
                                //FocDirectOrderItem.put(rcoPFields.get(str).name,ordli.get((rcoPFields.get(str).name)));
                                FocDirectOrderItem.PricebookEntryId = ordli.PricebookEntryId;                              
                                FocDirectOrderItem.Quantity= ordli.Quantity;
                                FocDirectOrderItem.UnitPrice=ordli.UnitPrice;
                                //FocDirectOrderItem.OrderId = OneOrderItems.id; 
                                FocDirectOrderItem.Orderid = extids.get(string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrderItems.id+1);                                 
                                orderItemList.add(FocDirectOrderItem); 
                                system.debug('FocDirectOrderItem'+FocDirectOrderItem);
                            }
                            if(OneOrderItems.RecordTypeId == FocUsRecordTypeId){
                                //FocUsOrderItem.put(rcoPFields.get(str).name,ordli.get((rcoPFields.get(str).name)));
                                FocUsOrderItem.PricebookEntryId = ordli.PricebookEntryId;                               
                                FocUsOrderItem.Quantity= ordli.Quantity;
                                FocUsOrderItem.UnitPrice=ordli.UnitPrice;
                                FocUsOrderItem.OrderId = OneOrderItems.id;
                                FocUsOrderItem.Orderid = extids.get(string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrderItems.id+2);
                                orderItemList.add(FocUsOrderItem); 
                                system.debug('FocUsOrderItem'+FocUsOrderItem);
                            }
                            if(OneOrderItems.RecordTypeId == GiveAwayRecordTypeId){
                                //GiveAwayOrderItem.put(rcoPFields.get(str).name,ordli.get((rcoPFields.get(str).name)));  
                                GiveAwayOrderItem.PricebookEntryId = ordli.PricebookEntryId;                             
                                GiveAwayOrderItem.Quantity= ordli.Quantity;
                                GiveAwayOrderItem.UnitPrice=ordli.UnitPrice;
                                GiveAwayOrderItem.Orderid = extids.get(string.valueOf((integer)ord.Recurrence_start_Date__c.DaysBetween(Date.today())/7)+OneOrderItems.id+3);                    
                                //GiveAwayOrderItem.OrderId = OneOrderItems.id;
                                orderItemList.add(GiveAwayOrderItem); 
                                system.debug('GiveAwayOrderItem'+GiveAwayOrderItem);
                            }                       
                       // }                                                                                                                  
                        system.debug('orderItemList Final'+orderItemList.size());
                    }  
                }
            }                
        }
       
        if(orderItemList!= null && orderItemList.size() >0){
            system.debug('orderItemList$$$$$$'+orderItemList);
            insert orderItemList;
            //dsrs = Database.insert(orderItemList,false);
        }
        
        for(Database.Saveresult sr: dsrs){
            if(sr.isSuccess()){
                ordersid.add(sr.getId());
            } 
            else{
                for(Database.Error err : sr.getErrors()) {}               
            }           
        }
    }         
    
    /* finish method for batch class */
    global void finish(Database.BatchableContext BC)
    {}
    /*End of class*/
}