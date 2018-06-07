global class AssignLcsCaseToCountryBatchClass implements Database.Batchable<SObject>{
    List<LocalComplaint__c> localC  =new List<LocalComplaint__c>();
    List<Case> UpdatedCases = new List<Case>();
    private String queryBatch ='';
    private static final Id PersonAccRecordTypeID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    private static final Id CustomerAccRecordTypeID= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    
    public AssignLcsCaseToCountryBatchClass(String Query){
        queryBatch = Query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryBatch);
    }
    global void execute(Database.BatchableContext BC,List<ComplaintAssets__c> lcom){
        Set<Id> allLocalCids = new Set<Id>();
        
        for(ComplaintAssets__c allLcs : lcom){
            allLocalCids.add(allLcs.Complaint__r.id);
        }
        List<LocalComplaint__c> ListOfLC = new List<LocalComplaint__c>([select id,Case__c,case__r.accountid from LocalComplaint__c where id in :allLocalCids]);
        Map<ID,Id> LcCases = new Map<Id,Id>();
        Map<ID,Id> LcCaseAccountIds = new Map<Id,Id>();
        for(LocalComplaint__c allLc : ListOfLC){
            LcCases.put(allLc.id,allLc.Case__r.id);
            LcCaseAccountIds.put(allLc.id,allLc.case__r.accountid);
        }
        system.debug('LcCaseAccountIds'+LcCaseAccountIds);
        List<Case> UpdatedCases = new List<Case>([SELECT id,Country__c,Last_Reminder_Sent__c,Last_Reminder_Sent_Date__c,ownerid,Accountid from Case where id in :LcCases.values() AND Last_Reminder_Sent__c != true ]);
        /*for(case c : UpdatedCases){
for(AssignCaseToProductQueue__c countWithQueues : AssignCaseToProductQueue__c.getAll().Values()){
if(c.Country__c.contains(countWithQueues.name)){
c.OwnerId = countWithQueues.Product_Queue__c;
} 
}
}*/
        List<Account> allPersonCont = [select id,PersonEmail,PersonContactId,RecordType.name from Account where id IN :LcCaseAccountIds.Values() AND RecordType.id =: PersonAccRecordTypeID AND PersonEmail != Null];
        system.debug('allPersonCont'+allPersonCont);
        List<Contact> allCustomerCont = [SELECT id,Email,Accountid FROM Contact WHERE Email != null AND PrimaryContact__c = true  AND Accountid IN :LcCaseAccountIds.Values() and account.RecordType.id =: CustomerAccRecordTypeID ];
        system.debug('allCustomerCont'+allCustomerCont);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage singlemail = new Messaging.SingleEmailMessage();
        for(case allc : UpdatedCases){
            for(AssignCaseToQueue__c allPRITemplates :  AssignCaseToQueue__c.getAll().Values()){
                if(allPRITemplates.Name.contains(allc.Country__c)){
                    EmailTemplate et = [Select id from EmailTemplate where name=:allPRITemplates.Email_Template__c];
                    system.debug('et:'+et);
                    for(LocalComplaint__c lcs : ListOfLC){
                        if((allPersonCont.size()>0 || allCustomerCont.size()>0)){               
                            if(allPersonCont.size()>0){
                                for(Account acc :allPersonCont){
                                    if(LcCaseAccountIds.get(lcs.id) == acc.id){
                                        singleMail.setTargetObjectId(acc.PersonContactId);
                                        singleMail.setWhatId(lcs.id);
                                        singlemail.setTemplateId(et.Id);
                                        singlemail.setSaveAsActivity(true);
                                        emails.add(singlemail);
                                        system.debug('Emails'+emails);
                                    }
                                }
                            }else if(allCustomerCont.size()>0){
                                for(Contact cont : allCustomerCont){
                                    if(LcCaseAccountIds.get(lcs.id) == cont.Accountid){
                                        singleMail.setTargetObjectId(cont.id);
                                        singleMail.setWhatId(lcs.id);
                                        singlemail.setTemplateId(et.Id);
                                        singlemail.setSaveAsActivity(true);
                                        emails.add(singlemail);
                                        system.debug('Emails'+emails);
                                    }
                                }
                            }
                            
                        }
                    }
                    if(emails.size()>0 && et.Id != Null){
                        Messaging.sendEmail(emails);
                    }
                }
            }
        }
        for(case caseupdate : UpdatedCases){
            if((allPersonCont.size()>0 || allCustomerCont.size()>0)){
                if(allPersonCont.size()>0){
                    for(Account ac : allPersonCont){
                        if(ac.id == caseupdate.AccountId){
                            for(AssignCaseToQueue__c allCountWithQueues : AssignCaseToQueue__c.getAll().Values()){
                                if(caseupdate.Country__c.contains(allCountWithQueues.name)){
                                    caseupdate.OwnerId = allCountWithQueues.QueueID__c;
                                    caseupdate.Last_Reminder_Sent__c = true;
                                    caseupdate.Last_Reminder_Sent_Date__c = system.today();
                                } 
                            }  
                        }   
                    }    
                } else if(allCustomerCont.size()>0 ){
                    for(Contact con : allCustomerCont){
                        if(con.AccountId == caseupdate.AccountId){
                            for(AssignCaseToQueue__c allCountWithQueues : AssignCaseToQueue__c.getAll().Values()){
                                if(caseupdate.Country__c.contains(allCountWithQueues.name)){
                                    caseupdate.OwnerId = allCountWithQueues.QueueID__c;
                                    caseupdate.Last_Reminder_Sent__c = true;
                                    caseupdate.Last_Reminder_Sent_Date__c = system.today();
                                } 
                            } 
                        }
                    }
                } 
            }else{
                for(AssignCaseToQueue__c allCountWithQueues : AssignCaseToQueue__c.getAll().Values()){
                    if(caseupdate.Country__c.contains(allCountWithQueues.name)){
                        caseupdate.OwnerId = allCountWithQueues.Product_Queue_ID__c;
                    } 
                }
            }
        }
        update UpdatedCases;
    }
    global void finish(Database.BatchableContext BC){
    }
}