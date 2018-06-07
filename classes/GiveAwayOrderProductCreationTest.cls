@isTest(SeeAllData = False)
Public Class GiveAwayOrderProductCreationTest{
Public Static testMethod void GiveAwayOrderProductCreation(){
User[] userArray = TestDataUtilityClass.createUser(1,'Core - Sales Rep','it_IT','India');
        
        System.RunAs(userArray[0]){  
            
            Account[] accountArray = TestDataUtilityClass.createAccounts(1);
            
            Id salesAccRcdType = Schema.SObjectType.Account.RecordTypeInfosByName.get('SalesRep').RecordTypeId;
            system.assertNotEquals(salesAccRcdType,null); 
            
            Account salesAccountObj = new Account();
            salesAccountObj.LastName='Last Name';
            salesAccountObj.RecordTypeId=salesAccRcdType;
            salesAccountObj.CurrencyIsoCode='CHF';
            salesAccountObj.OwnerId=userinfo.getuserid();
            Database.insert(salesAccountObj);
            
            Product2[] productArray =  TestDataUtilityClass.createProducts(1);
            List<Id> prdList = new List<Id>();
            for(Product2 prd : productArray){
                prdList.add(prd.Id);
            }
            
            PricebookEntry[] pbeArray =  TestDataUtilityClass.createPricebookEntry(1,prdList);
            
            Id ordRcdType = Schema.SObjectType.order.RecordTypeInfosByName.get('Give Away').RecordTypeId;
            system.assertNotEquals(ordRcdType ,null);
            
            Test.startTest();
            Order giveorderObject = new Order();
            giveorderObject.AccountId=accountArray[0].Id;
            giveorderObject.RecordTypeId=ordRcdType;
            giveorderObject.Status='Draft';
            giveorderObject.Pricebook2Id =Test.getStandardPricebookId();
            giveorderObject.EffectiveDate = Date.today();
            Database.insert(giveorderObject);
            
            Order selectOrderObj = [SELECT Id,TransactionPartner__r.Id  from Order where Id=:giveorderObject.Id LIMIT 1];
            system.assertequals(selectOrderObj.TransactionPartner__r.Id,salesAccountObj.Id);
            
            Id handordRcdType = Schema.SObjectType.order.RecordTypeInfosByName.get('Hand Over').RecordTypeId;
            system.assertNotEquals(handordRcdType ,null);
            
            Order handOverOrderObj = new Order();
            handOverOrderObj.AccountId=accountArray[0].Id;
            handOverOrderObj.RecordTypeId=handordRcdType;
            handOverOrderObj.Status='Draft';
            handOverOrderObj.Pricebook2Id =Test.getStandardPricebookId();
            handOverOrderObj.EffectiveDate = Date.today();
            Database.insert(handOverOrderObj);
            
            Order selectHandOverOrderObj = [SELECT Id,TransactionPartner__r.Id  from Order where Id=:handOverOrderObj.Id LIMIT 1];
            system.assertequals(selectHandOverOrderObj.TransactionPartner__r.Id,salesAccountObj.Id);
            
            Id returnordRcdType = Schema.SObjectType.order.RecordTypeInfosByName.get('Return Order').RecordTypeId;
            system.assertNotEquals(returnordRcdType ,null);
            
            Order returnOrderObj = new Order();
            returnOrderObj.AccountId=accountArray[0].Id;
            returnOrderObj.RecordTypeId=returnordRcdType;
            returnOrderObj.Status='Draft';
            returnOrderObj.Pricebook2Id =Test.getStandardPricebookId();
            //returnOrderObj.IsReturnReciprocalOrder__c=true;
            returnOrderObj.EffectiveDate = Date.today();
            Database.insert(returnOrderObj);
            
            
            OrderItem[] ordItemArray =  TestDataUtilityClass.createOrderItem(1,handOverOrderObj.Id,pbeArray[0].Id);
            
            OrderItem orderList = [SELECT ID,Quantity from OrderItem where Id=:ordItemArray[0].Id LIMIT 1];
            orderList.Quantity=20;
            Database.update(orderList);
            
            OrderItem[] giveOrdArray =  TestDataUtilityClass.createOrderItem(1,giveorderObject.Id,pbeArray[0].Id);        
            Test.stopTest();       
            OrderItem handorditem =new OrderItem();
            handorditem.OrderId = giveorderObject.Id;
            handorditem.PricebookEntryId = pbeArray[0].Id;
            handorditem.Quantity = 24;
            handorditem.UnitPrice = 0;
            handorditem.OrderItemExternalText__c = giveOrdArray[0].Id;
            Database.insert(handorditem);
            
            OrderItem orderItemList1 = [SELECT ID,Quantity from OrderItem where Id=:giveOrdArray[0].Id LIMIT 1];
            orderItemList1.Quantity=20;
            TriggerCount.getRunTimes();
            TriggerCount.setRunTimes();
            TriggerCount.firstRun = true; 
            Database.update(orderItemList1);
            
            OrderItem[] returnOrdArray =  TestDataUtilityClass.createOrderItem(1,returnOrderObj.Id,pbeArray[0].Id); 
            
            GiveAwayOrderProductCreation.orderProductCreation(returnOrdArray);
            
        }
        
}

}