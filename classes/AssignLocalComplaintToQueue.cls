public class AssignLocalComplaintToQueue {
    public static void assignLcToQueue(List<ComplaintAssets__c> complass,Map<ID,ComplaintAssets__c> complasOldMap){
        List<ComplaintAssets__c> allcompassets = [SELECT id,ProductReceived__c,Complaint__c,Complaint__r.ownerId 
                                                  FROM ComplaintAssets__c WHERE  id IN :complasOldMap.keySet()];
        set<Id> LclCmptIds = new set<Id>();
        if(allcompassets.size() > 0 && !allcompassets.contains(Null)){
            for(ComplaintAssets__c comp : complass){
                for(ComplaintAssets__c comasslist : allcompassets){
                    if(comasslist.ProductReceived__c != comp.ProductReceived__c && comp.ProductReceived__c == 'Yes'){
                        LclCmptIds.add(comasslist.Complaint__c);
                    }
                }
            } 
        }
        List<String> countries = new List<String>();
        for(FLIUGoodsReceiptCountries__c countryValues : FLIUGoodsReceiptCountries__c.getAll().values()){
            countries.add(countryValues.Name);
        }
        List<LocalComplaint__c> lcids = [SELECT Id,Name,OwnerId,CaseCountry__c FROM LocalComplaint__c WHERE Id =: LclCmptIds];
        if(lcids.size() > 0){
            for(LocalComplaint__c lcl :lcids){
                if(countries.contains(lcl.CaseCountry__c)){
                    lcl.OwnerId = system.label.MHM_FLIU_Investigation_Queue;  
                }     
            }
            update lcids;  
        }  
    }
    public static void updateProductReceivedDate(List<ComplaintAssets__c> complassets,Map<ID,ComplaintAssets__c> complasstOldMap){
        List<ComplaintAssets__c> complassetList = [SELECT id,ProductReceivedCaptureDate__c,RequestforReturn__c,ProductReceived__c 
                                                   FROM ComplaintAssets__c WHERE ProductReceived__c != 'Yes' and id IN :complasstOldMap.keySet()];
        for(ComplaintAssets__c comp : complassets){
            for(ComplaintAssets__c listcomass : complassetList){
                if(listcomass.ProductReceived__c != comp.ProductReceived__c){
                    comp.ProductReceivedCaptureDate__c = Null;
                }else{
                    comp.ProductReceivedCaptureDate__c = system.today();
                }
            }
        }
    }
    
}