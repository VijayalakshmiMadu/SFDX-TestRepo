/*
@author : Rajasekhara Kasoju
Description : This Class is used for Helper class for OrderReciprocalAfterInsertAfterUpdate Trigger, It implements the logic of reciprocal of New Order Creation
Created Date : 28-Aug-2014
Change History           
*/
public with sharing class OrderReciprocalhelperclass {
    
    private  Map<Id,Order> ordeMap = New Map<Id,Order>(); 
    private Map<Id,Order> childOrdeMap = New Map<Id,Order>();
    private  List<Order> orderList = New List<Order>();
    private  List<Order> childList = New List<Order>();
    
    
    
    private map<Id,OrderItem> orderItemMap=new map<Id,OrderItem>();
    private map<Id,OrderItem> childOrderItemMap=new map<Id,OrderItem>();
    private  List<OrderItem> orderItemList = New List<OrderItem>();
    private  List<OrderItem> childOrderItemList = New List<OrderItem>();
    /*Constants to remove Hard Coding and Constant should be in upper case letters*/
    private static final String  GIVE_AWAY='Give Away';
    private static final String  HAND_OVER = 'Hand Over';
    private static final String  RETURN_ORDER = 'Return Order';  
    
    private List<Database.UpsertResult> dbUpsertResult = new List<Database.UpsertResult>();
    private List<Database.SaveResult> dbUpdateResult = new List<Database.SaveResult>();    
    
    /* Constant should be in upper case*/ 
    private static final String CLASS_NAME = 'OrderReciprocalhelperclass';
    private static final String METHOD_NAME1 = 'reciprocalOrder';
    private static final String METHOD_NAME2 = 'updatechildOrder';
    private static final String METHOD_NAME3 = 'orderItemCreate';
    private static final String METHOD_NAME4 = 'orderItemUpdate';  
    
    private static final String SERVICE = 'Service'; 
    private static final String germanyCountryCode = 'DE';
    private static final Id PersonAccRecordTypeID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    private static final Id ChargeableDRecordTypeID= Schema.SObjectType.Order.getRecordTypeInfosByName().get('Chargeable Direct').getRecordTypeId();    
    
    
    /* reciprocalOrder Method is Used to Order Creation*/
    public  void reciprocalOrder(Map<Id,Order> ordeMap)
    {
        
        for(Order ord : [SELECT IsReciprocalOrder__c,EffectiveDate,EndDate,Id,OrderExternelField__c,OwnerId,OrderRecordType__c,TransactionPartner__c,Pricebook2Id,RecordTypeId,Status FROM Order Where Id in : ordeMap.keySet() limit 1000 ])
        {
            
            if(ordeMap.containsKey(ord.id) )
            {
                Order ordr = New Order();          
                ordr.AccountId = ordeMap.get(ord.Id).TransactionPartner__c;
                ordr.TransactionPartner__c = ordeMap.get(ord.Id).AccountId;
                ordr.EffectiveDate =  ordeMap.get(ord.Id).EffectiveDate;
                ordr.EndDate = ordeMap.get(ord.Id).EndDate;
                ordr.RecordTypeId = ordeMap.get(ord.Id).RecordTypeId;
                ordr.OwnerId = ordeMap.get(ord.Id).OwnerId;
                ordr.Status = ordeMap.get(ord.Id).Status;
                ordr.Pricebook2Id = ordeMap.get(ord.Id).Pricebook2Id;
                ordr.OrderExternelField__c = ordeMap.get(ord.Id).Id;
                ordr.RelatedOrder__c = ordeMap.get(ord.Id).Id;
                ordr.CurrencyIsoCode = ordeMap.get(ord.Id).CurrencyIsoCode;
                if(ordeMap.get(ord.Id).OrderRecordType__c==GIVE_AWAY|| ordeMap.get(ord.Id).OrderRecordType__c==HAND_OVER)
                {
                    ordr.IsReciprocalOrder__c=true;
                }
                else
                {
                    ordr.IsReciprocalOrder__c=false;    
                }
                
                if(ordeMap.get(ord.Id).OrderRecordType__c==RETURN_ORDER)
                {
                    ordr.IsReturnReciprocalOrder__c=true;
                }
                else
                {
                    ordr.IsReturnReciprocalOrder__c=false;
                }
                
                
                orderList.add(ordr);
                //     system.debug('..11.. '+orderList);
                
            }
        }
        
        
    }
    
    /* reciprocalOrder Method is Used to Order & Duplicate Order Creation END***/   
    
    
    
    /* updatechildOrder Method is Used to Order Updation*/
    public  void updatechildOrder(Map<Id,Order> childOrdeMap)
    {
        
        if(childOrdeMap.keyset().size()>0)
        {
            
            for(Order ord : [SELECT EffectiveDate,EndDate,Id,OrderExternelField__c,IsReciprocalOrder__c,OwnerId,OrderRecordType__c,TransactionPartner__c,Pricebook2Id,RecordTypeId,Status FROM Order Where Id in : childOrdeMap.keySet() limit 1000 ] )
            {
                if(childOrdeMap.containskey(ord.Id))
                {
                    ord.OrderExternelField__c= childOrdeMap.get(ord.Id).Id;
                    ord.RelatedOrder__c = childOrdeMap.get(ord.Id).Id;
                    
                    if(childOrdeMap.get(ord.Id).OrderRecordType__c==RETURN_ORDER )
                    {
                        ord.IsReciprocalOrder__c=true;
                    }
                    else
                    {
                        ord.IsReciprocalOrder__c=false;
                    }
                    childList.add(ord);
                }
            }
            
        }
        
        orderDMLOperation(orderList,childList);
    }
    
    public void orderDMLOperation(List<Order> ordUpsertList,List<Order> ordUpdateList){
        try {
            if(triggerCount.firstRun)
            {     
                if(ordUpsertList.size() > 0 )
                {
                    TriggerCount.firstRun = false;  
                    Schema.SObjectField f = Order.fields.OrderExternelField__c; 
                    //upsert orderList OrderExternelField__c;
                    dbUpsertResult = Database.upsert(ordUpsertList,f,false);
                }
            }
            
            
            
            if(ordUpdateList.size() > 0)
            {
                dbUpdateResult= Database.update(ordUpdateList); 
            }
        }
        catch(DMLException e)
        {
            UTIL_LoggingService.logDmlResults(dbUpdateResult,null,dbUpsertResult,null,CLASS_NAME,METHOD_NAME1,null);
            UTIL_LoggingService.logDmlResults(dbUpdateResult,null,dbUpsertResult,null,CLASS_NAME,METHOD_NAME2,null);                            
        } 
    }
    
    
    /* updatechildOrder Method is Used to Order Updation END***/
    
    
    /* orderItemCreate Method is Used to OrderItem Creation*/
    public  void orderItemCreate(Map<Id,OrderItem> orderItemMap, Boolean updateFlag)
    {                        
        for (OrderItem odrItm: [SELECT Id,OrderId,RecOrderID__c,CreatedDate,OrderItemExternalText__c,PricebookEntryId,Quantity,UnitPrice FROM OrderItem where Id in:orderItemMap.keySet() limit 1000 ])
        {
            OrderItem orderItemObj=new OrderItem();
            orderItemObj.OrderId=orderItemMap.get(odrItm.Id).RecOrderID__c;
            orderItemObj.OrderItemExternalText__c=orderItemMap.get(odrItm.Id).Id;
            
            if(!updateFlag)
            {
                orderItemObj.PricebookEntryId=orderItemMap.get(odrItm.Id).PricebookEntryId;
            }
            orderItemObj.Quantity=orderItemMap.get(odrItm.Id).Quantity;
            orderItemObj.UnitPrice=orderItemMap.get(odrItm.Id).UnitPrice;
            orderItemList.add(OrderItemObj);
        }
        
    }
    
    
    /* orderItemUpdate Method is Used to OrderItem Creation END**/
    
    /*  orderItemUpdate  Method is used to OrderItem Update */     
    public  void orderItemUpdate(Map<Id,OrderItem> childOrderItemMap)
        
    {  
        for (OrderItem childOrdItem: [SELECT Id,OrderItemExternalText__c  FROM OrderItem where Id in:childOrderItemMap.keySet() limit 1000 ])
        {
            if(childOrderItemMap.containskey(childOrdItem.Id))
            {                       
                childOrdItem.OrderItemExternalText__c= childOrderItemMap.get(childOrdItem.Id).Id;
                
                childOrderItemList.add(childOrdItem);
            }
            
        }
        orderItemDMLOperation(orderItemList,childOrderItemList);
    }    
    /*  orderItemUpdate  Method is used to OrderItem Update End * */   
    
    
    public void orderItemDMLOperation(List<OrderItem> ordItemUpsert,List<OrderItem> ordItemUpdate){
        try {       
            if(TriggerCount.firstRun)
            {    
                if(ordItemUpsert.size() >0)
                {
                    TriggerCount.firstRun = false;
                    //Upsert orderItemList OrderItemExternalText__c;
                    Schema.SObjectField g = OrderItem.Fields.OrderItemExternalText__c;
                    dbUpsertResult = Database.upsert(ordItemUpsert,g,false);  
                    
                    
                }
            }
            if(ordItemUpsert.size()>0)
            {   
                dbUpdateResult=Database.update(ordItemUpdate); 
            }
        }
        catch(DMLException e)
        {
            UTIL_LoggingService.logDmlResults(dbUpdateResult,null,dbUpsertResult,null,CLASS_NAME,METHOD_NAME3,null);
            UTIL_LoggingService.logDmlResults(dbUpdateResult,null,dbUpsertResult,null,CLASS_NAME,METHOD_NAME4,null);  
            
        }              
        
    } 
    //Start - CRID_0698 By Vasavi Inuguru
    public static void updateOrderCaptureDate(List<Order> neworders,Map<ID,Order> ordersOldMap){
        List<Order> orderList = [SELECT id,status FROM order WHERE status =: system.label.Completely_Processed_Status AND id IN :ordersOldMap.keySet()];
        for(order ord : neworders){
            for(order listcomass : orderList){
                if(listcomass.status != ord.status){
                    ord.OrderStatusCaptureDate__c = Null;
                }else{
                    ord.OrderStatusCaptureDate__c = System.today(); 
                    //ord.OrderStatusCaptureDate__c = Date.valueOf('2018-03-23');
                }
            }
        }
    }
    //End - CRID_0698  
    //Start - CRID_0698 By Vasavi Inuguru & Chiranjeevi Gogulakonda
    @future
    public static void chargeableDirectEmailNotification(set<id> OrderIDs){
        Map<ID,Order> allOrdsmapids = new Map<ID,Order>();
        List<order> ordertoupdate = new List<order>();
        List<Order> ords = [SELECT id,status,Accountid,Chargeable_Direct_Email_Trigger__c,OrderCustomerCountry__c,OrderCustomerLanguage__c FROM Order WHERE RecordType.id =:ChargeableDRecordTypeID AND Order.Account.RecordType.id =: PersonAccRecordTypeID AND Chargeable_Direct_Email_Trigger__c != true AND id IN :OrderIDs];
        if(ords.size() > 0 && !ords.contains(Null)){
            for(Order ord : ords){
                allOrdsmapids.put(ord.Accountid, ord);
            }
        }
        List<Account> allAcc = [SELECT id,PersonEmail,PersonContactId FROM Account WHERE PersonEmail != Null AND Id IN :allOrdsmapids.keySet() AND Recordtype.Id =: PersonAccRecordTypeID];
        EmailTemplate et = new EmailTemplate();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>(); 
        for(Order chargeableDOrders : ords){
            for(OrderEmailTemplates__c allTemplates :OrderEmailTemplates__c.getAll().Values()){
                if(allTemplates.Name.contains(chargeableDOrders.OrderCustomerCountry__c)){
                    et = [SELECT id FROM EmailTemplate WHERE Name =: allTemplates.Email_Template__c ];
                }else if(chargeableDOrders.OrderCustomerCountry__c == 'CH' && chargeableDOrders.OrderCustomerLanguage__c != Null){
                    for(CountryRelatedLanguages__c lang : CountryRelatedLanguages__c.getAll().Values()){
                        if(lang.name.contains(chargeableDOrders.OrderCustomerLanguage__c)){
                            et = [Select id from EmailTemplate where name=: lang.Email_Template__c];  
                        }
                    }
                }
                else if(chargeableDOrders.OrderCustomerCountry__c == 'BE'){
                    for(BelgiumCountryEmailTemplates__c lang : BelgiumCountryEmailTemplates__c.getAll().Values()){
                        if(chargeableDOrders.OrderCustomerLanguage__c != Null){
                            if(lang.name.contains(chargeableDOrders.OrderCustomerLanguage__c)){
                                et = [Select id from EmailTemplate where name=: lang.Email_Template__c];  
                            }
                            else{
                                et= [Select id from EmailTemplate where name = 'Belgium No Language Email Template'];
                            }
                        }                                    
                    }
                } 
            } 
            for(Account acc :allAcc){
                if(acc.PersonEmail != null && chargeableDOrders.Accountid == acc.id && chargeableDOrders.Chargeable_Direct_Email_Trigger__c == false){
                    Messaging.SingleEmailMessage singlemail = new Messaging.SingleEmailMessage();
                    singleMail.setTargetObjectId(acc.PersonContactId);
                    singlemail.setTemplateId(et.Id);
                    singlemail.setWhatId(chargeableDOrders.id);
                    singlemail.setSaveAsActivity(true);
                    emails.add(singlemail);
                    ordertoupdate.add(chargeableDOrders);
                }  
            }  
        }
        if(emails.size()>0 && et.id != null && ordertoupdate.size()>0){
            Messaging.sendEmail(emails); 
            For(Order o : ordertoupdate ){
                o.Chargeable_Direct_Email_Trigger__c=true;
            }
            update ordertoupdate ;
        }
        
    }
    //End - CRID_0698
    @future
    public static void FocDirectAndFocOrderEmailNotify(set<id> focOrderIDs){
        Map<ID,Order> allFOCOrdsmapids = new Map<ID,Order>();
        List<order> FOCordertoupdate = new List<order>();
        List<Order> FOCords = [SELECT id,status,Accountid,FOC_Email_Triggered__c,OrderCustomerCountry__c,OrderCustomerLanguage__c FROM Order WHERE RecordType.Name IN ('FOC Direct','FOC Order') AND FoCReason__c =:SERVICE  AND Order.Account.RecordType.id =: PersonAccRecordTypeID AND id in :focOrderIDs AND FOC_Email_Triggered__c != true];
        if(FOCords.size() > 0 && !FOCords.contains(Null)){
            for(Order ord : FOCords){
                allFOCOrdsmapids.put(ord.Accountid, ord);
            }
        }
        List<Account> allAcc = [SELECT id,PersonEmail,PersonContactId FROM Account WHERE PersonEmail != Null AND Id IN :allFOCOrdsmapids.keySet() AND Recordtype.Id =: PersonAccRecordTypeID];
        EmailTemplate et = new EmailTemplate();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>(); 
        for(Order FocOrders : FOCords){
            for(OrderEmailTemplates__c allTemplates :OrderEmailTemplates__c.getAll().Values()){
                if(allTemplates.Name.contains(FocOrders.OrderCustomerCountry__c)){
                    et = [SELECT id FROM EmailTemplate WHERE Name =: allTemplates.Email_Template__c ];
                }else if(FocOrders.OrderCustomerCountry__c == 'CH' && FocOrders.OrderCustomerLanguage__c != Null){
                    for(CountryRelatedLanguages__c lang : CountryRelatedLanguages__c.getAll().Values()){
                        if(lang.name.contains(FocOrders.OrderCustomerLanguage__c)){
                            et = [Select id from EmailTemplate where name=: lang.Email_Template__c];  
                        }
                    }
                }
                else if(FocOrders.OrderCustomerCountry__c == 'BE'){
                    for(BelgiumCountryEmailTemplates__c lang : BelgiumCountryEmailTemplates__c.getAll().Values()){
                        if(FocOrders.OrderCustomerLanguage__c != Null){
                            if(lang.name.contains(FocOrders.OrderCustomerLanguage__c)){
                                et = [Select id from EmailTemplate where name=: lang.Email_Template__c];  
                            }
                            else{
                                et= [Select id from EmailTemplate where name = 'Belgium No Language Email Template'];
                            }
                        }                                    
                    }
                } 
            } 
            for(Account acc :allAcc){
                if(acc.PersonEmail != null && FocOrders.Accountid == acc.id && FocOrders.FOC_Email_Triggered__c == false){
                    Messaging.SingleEmailMessage singlemail = new Messaging.SingleEmailMessage();
                    singleMail.setTargetObjectId(acc.PersonContactId);
                    singlemail.setTemplateId(et.Id);
                    singlemail.setWhatId(FocOrders.id);
                    singlemail.setSaveAsActivity(true);
                    emails.add(singlemail);
                    FOCordertoupdate.add(FocOrders);
                }  
            }  
        }
        if(emails.size()>0 && et.id != null && FOCordertoupdate.size()>0){
            Messaging.sendEmail(emails); 
            For(Order o : FOCordertoupdate ){
                o.FOC_Email_Triggered__c=true;
            }
            update FOCordertoupdate ;
        }
    }                     
}