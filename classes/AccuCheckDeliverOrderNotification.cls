/************************************
Name         : AccuCheckDeliverOrderNotification
Created By   : Chiranjeevi Gogulakonda
Company Name : TechMahindra
Project      : Roche Diabetes-CRID_1077.
Created Date : 2nd Feb 2018
Test Class   : AccuCheckDeliverOrderNotificationTest  
Usages       : Sending Email Notification to Customer with the order products when the status is changed to Completely Processed and Foc Reason is Marketing/DME or Samples for the FOC Order && Foc Direct Record Types.
***********************************/
Public Class AccuCheckDeliverOrderNotification{
Public static void sendNotification(List<Order> OrderIds){
 Id SalesRepRecordTypeID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('SalesRep').getRecordTypeId();
 Id CustomerAccRecordTypeID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    
 Map<ID,Order> allOrdsmap = new Map<ID,Order>();
        for(Order ord : OrderIds){
            allOrdsmap.put(ord.Accountid,Ord);          
        }
List<Account> allSalesRepCont = [select id,PersonEmail,PersonContactId,RecordType.name from Account where id IN :allOrdsmap.keyset() AND RecordType.id =: SalesRepRecordTypeID];
List<Contact> allCustomerCont = [SELECT id,Email,Accountid FROM Contact WHERE Email != null AND PrimaryContact__c = true  AND Accountid IN :allOrdsmap.keyset() and account.RecordType.id =: CustomerAccRecordTypeID ];
EmailTemplate et = [Select id from EmailTemplate where name='FOC Direct & FOC Us Order Notification'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();      
        if(allSalesRepCont.size()>0 || allCustomerCont.size()>0){
        for(Order ord :OrderIds){               
            System.debug('If Enters*********');
                Messaging.SingleEmailMessage singlemail = new Messaging.SingleEmailMessage();               
                 if(allSalesRepCont.size()>0){
                    for(Account acc :allSalesRepCont ){ 
                        system.debug('PersonContactId'+acc.PersonContactId);
                        singleMail.setTargetObjectId(acc.PersonContactId);
                    }
                }else if(allCustomerCont.size()>0){
                    for(Contact cont : allCustomerCont){
                        singleMail.setTargetObjectId(cont.id);
                    }
                    }
                singleMail.setWhatId(ord.id);
                singlemail.setTemplateId(et.Id);
                singlemail.setSaveAsActivity(True);
                emails.add(singlemail);
                                                                  
        }
        if(emails.size()>0){
        Messaging.sendEmail(emails);
        }
        }

}

}