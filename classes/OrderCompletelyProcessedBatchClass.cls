global class OrderCompletelyProcessedBatchClass implements Database.Batchable<SObject>{
    
    private String queryBatch = '';
    private static final String  germanyCountryCode = 'DE';
    private static final Id PersonAccRecordTypeID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    
    public OrderCompletelyProcessedBatchClass(String Query){
        queryBatch = Query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryBatch);
    }
    global void execute(Database.BatchableContext BC,List<Order> allOrds){
        Map<ID,Order> allOrdsmapids = new Map<ID,Order>();
        List<String> prodMatNos = new List<String>();
        Set<Id> allOrderIds = new Set<Id>();
        Set<Id> allGermanIds = new Set<Id>();
        Set<Id> allAccids = new Set<ID>();
        List<order> updateorders = new List<Order>();
        for(Order ord : allOrds){
            allOrdsmapids.put(ord.id, ord);
        }
        for(ProductMaterialNumbers__c prodCustomValues : ProductMaterialNumbers__c.getAll().values()){
            prodMatNos.add(prodCustomValues.Name);
        }
        List<OrderItem> allGermanyprods = [SELECT id,Product2.id,Product2.name,Product2.Material_Number__c,orderid,order.OrderCustomerCountry__c from OrderItem where Product2.Material_Number__c  IN:prodMatNos and order.OrderCustomerCountry__c =: germanyCountryCode and orderid IN: allOrdsmapids.keySet()];     
        if(allGermanyprods.size() > 0 && !allGermanyprods.contains(Null)){
            for(OrderItem allGermanyProducts : allGermanyprods){
                allGermanIds.add(allGermanyProducts.orderid);
            }
        }
        List<OrderItem> allProdRelatedToOrder = [SELECT id,Product2.id,Product2.name,Product2.Material_Number__c,orderid,order.OrderCustomerCountry__c from OrderItem where orderid IN: allOrdsmapids.keySet() AND orderid NOT IN :allGermanIds];
         system.debug('allProdRelatedToOrder'+allProdRelatedToOrder);
        if(allProdRelatedToOrder.size() > 0 && !allProdRelatedToOrder.contains(Null)){
            for(OrderItem ordi : allProdRelatedToOrder){
                allOrderIds.add(ordi.orderid);
                system.debug('allOrderIds'+allOrderIds);
            }    
        }
        List<Order> finalOrds = [select id,accountid,Email_Triggered__c,OrderCustomerCountry__c,OrderCustomerLanguage__c from order where id IN:allOrderIds];
        if(finalOrds.size() > 0 && !finalOrds.contains(Null)){
            for(Order od : finalOrds){
                allAccids.add(od.accountid);
                system.debug('allAccids'+allAccids);
            }
        }
        if(allAccids.size() > 0 && !allAccids.contains(Null)){
            List<Account> allAcc = [select id,PersonEmail,PersonContactId from Account where PersonEmail != null and Id IN :allAccids and Recordtype.id =: PersonAccRecordTypeID];
            EmailTemplate et = new EmailTemplate();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();             
            for(Order ordid : finalOrds){
                for(OrderProductsEmailTemplate__c alltemp : OrderProductsEmailTemplate__c.getAll().Values()){
                    if(alltemp.name.contains(ordid.OrderCustomerCountry__c)){
                        et = [Select id from EmailTemplate where name=: alltemp.Products_Email_Template__c];
                        system.debug('EmailTemplate'+et.id);
                    }/*else if(ordid.OrderCustomerCountry__c == 'CH' && ordid.OrderCustomerLanguage__c != Null){
                        for(CountryRelatedLanguages__c lang : CountryRelatedLanguages__c.getAll().Values()){
                            if(lang.name.contains(ordid.OrderCustomerLanguage__c)){
                                et = [Select id from EmailTemplate where name=: lang.Language_Product_Email_Templates__c];  
                            }
                        }
                    }*/
                }
                for(Account acc :allAcc){
                    if(acc.PersonEmail != null && ordid.Accountid == acc.id && ordid.Email_Triggered__c == false){
                        Messaging.SingleEmailMessage singlemail = new Messaging.SingleEmailMessage();
                        singleMail.setTargetObjectId(acc.PersonContactId);
                        singlemail.setTemplateId(et.Id);
                        singlemail.setWhatId(ordid.id);
                        singlemail.setSaveAsActivity(true);
                        emails.add(singlemail);
                        system.debug('emails'+emails);
                        updateorders.add(ordid);
                    } 
                }  
            }
            if(emails.size()>0 && et.Id != Null && updateorders.size()>0){
                Messaging.sendEmail(emails); 
                for(Order updateord : updateorders){
                    system.debug('updateorders'+updateorders);
                    updateord.Email_Triggered__c = true;
                }
                update updateorders;
            }
        } 
    }
    global void finish(Database.BatchableContext BC){
    }
}