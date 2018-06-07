public class AccountUpdate {
public static void UpdateAccount(list<CampaignMember> camlist){
Set<Id> conIds = new Set<Id>();
Map<id,id> mapids = new Map<id,id>();
For(CampaignMember cm: camlist){
       conIds.add(cm.contactid);
        }
        
        list<contact> Conlist1 =[ select id , name,accountid from contact where id in:conIds];
        for(contact con :Conlist1 ){
        mapids.put(con.id ,con.accountid);
        }
        
        For(CampaignMember cm: camlist){
        if(mapids.containskey(cm.contactid)!=null){
        
        cm.Account_on_Campaign__c= mapids.get(cm.contactid);
        }
      }
   }

}