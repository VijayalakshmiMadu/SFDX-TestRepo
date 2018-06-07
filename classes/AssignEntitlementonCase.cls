/************************************
Name         : AssignEntitlementonCase
Created By   : Chiranjeevi Gogulakonda
Company Name : Tech Mahindra
Project      : Roche Major Relase CRM 2018(CRID_698)
Created Date : 19/03/2018
Test Class   : AssignEntitlementonCaseTest
Usages       : This is class is used to Assigning entitlement process for Sweeden Cases also Sending email notifcation for Denmark Cases.
Modified By  : 02/05/2018
*************************************/
Public Class AssignEntitlementonCase{
    Public Static void updateCase(List<Case> cas,Map<Id,Case> triggerOldMap){       
        Map<ID,Case> allcasesmap = new Map<ID,Case>();              
        Set<Id> SetofCaseIds = new set<Id>();       
        For(Case c : cas){ 
            if(c.OwnerId <> triggerOldMap.get(c.id).ownerId && (c.ownerid == label.SE_IDS_Lifecycle_campaign || c.ownerid == label.DK_ICC_IDS_Welcome_Process )){
                allcasesmap.put(c.Contactid,c);  
                SetofCaseIds.add(c.id);             
                system.debug('allcasesmap'+allcasesmap);
            }
        }   
        system.debug('SetofCaseIds'+SetofCaseIds);
        List<case> CasestoUpdate =[Select id,country__C,Ownerid,EntitlementId,ContactId from case where id in :SetofCaseIds];     
        
        Entitlement IdsEntls = [Select Name,StartDate,Id,EndDate,AccountId,AssetId From Entitlement  Where Name ='IDS Lifecycle' AND EndDate >= Today And StartDate <= Today];      
        //Entitlement PumpIdsEntls = [Select Name,StartDate,Id,EndDate,AccountId,AssetId From Entitlement  Where Name ='Pump Welcome Process for Denmark' AND EndDate >= Today And StartDate <= Today];
        
        List<Contact> allCon = [SELECT id,email,Recordtype.name from Contact where email != null AND Id IN :allcasesmap.keyset() ];
        system.debug('@@@@@@@@:'+allCon.size());
        EmailTemplate et = [Select id from EmailTemplate where name='DK_ICC IDS Welcome Email Template'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Document Doc=[select id,name,body,contenttype, developername,type from Document  where name='Pump Welcome Process DK Email Attachments'];
        Document Doc1=[select id,name,body,contenttype, developername,type from Document  where name='Pump Welcome Process DK Email Attachments Two'];
        if(IdsEntls.id != Null){
            for(Case cs : CasestoUpdate){ 
                if(cs.EntitlementId == Null && cs.Ownerid == label.SE_IDS_Lifecycle_campaign){                  
                    cs.EntitlementId = IdsEntls.id;                    
                    cs.SlaStartDate = system.now();
                }
                if(allCon.size()>0){
                    if(cs.EntitlementId == Null ){
                        if(cs.Country__c == 'Denmark' && cs.Ownerid == label.DK_ICC_IDS_Welcome_Process){
                            for(Contact con :allCon){
                                if(con.email != null){
                                    //cs.SlaStartDate = system.now();
                                    //cs.EntitlementId = PumpIdsEntls.id;
                                    Messaging.SingleEmailMessage singlemail = new Messaging.SingleEmailMessage();   
                                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                    Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
                                    attach.setContentType(doc.contentType);
                                    attach.setFileName(doc.developerName+'.'+doc.type);
                                    attach.setInline(false);
                                    attach.Body = doc.Body;
                                    attach1.setContentType(doc1.contentType);
                                    attach1.setFileName(doc1.developerName+'.'+doc1.type);
                                    attach1.setInline(false);
                                    attach1.Body = doc1.Body;            
                                    singleMail.setTargetObjectId(con.Id);
                                    singleMail.setWhatId(cs.id);
                                    singleMail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach,attach1 });
                                    singlemail.setTemplateId(et.Id);
                                    singlemail.setSaveAsActivity(true);
                                   
                                    emails.add(singlemail);
                                }
                            }
                        }
                    }
                }
                
            }
            if(emails.size()>0){
                system.debug('@@@@@@@@:'+emails.size());
                Messaging.sendEmail(emails);
            }
            if(!CasestoUpdate.isEmpty()){
                Update CasestoUpdate ;
                updateCases(SetofCaseIds);
            }
        }
    }    
    @future
    Public static Void updateCases(set<id> IdstoUpdate){
        List<case> CasestoUpdate = new List<Case>([Select id,country__C,Ownerid,EntitlementId,ContactId,IDS_LC_Follow_up_call_1__c,IDS_LC_Follow_up_call_2__c from case where id in :IdstoUpdate]);     
        for(Case cs :CasestoUpdate  ){
            cs.IDS_LC_Follow_up_call_1__c=true;
            cs.IDS_LC_Follow_up_call_2__c=true;
        }
        update CasestoUpdate ;  
    }       
    
}