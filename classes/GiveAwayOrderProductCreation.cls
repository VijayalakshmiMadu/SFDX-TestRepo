Public Class GiveAwayOrderProductCreation{
    Public static Void orderProductCreation(List<OrderItem> newOrderItem){
        Id FOCDirectRecordTypeId= Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC Direct').getRecordTypeId();
        Id FocUsRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC US').getRecordTypeId();
        set<id> ItemIds= new set<id>();
        set<id>OrdIds= new set<id>();
        List<OrderItem > ListItems= new List<OrderItem >();
        List<order> orderlist= new List<order >();
        Map<id,string> orMap= new map<id,string>();
        Map<id,string> GAMap= new map<id,string>();
        for(OrderItem Oitemid:newOrderItem){
            ItemIds.add(Oitemid.orderid);           
        } 
        list<order> pordrlist = [Select Id,AccountId,Status,Pricebook2Id,EffectiveDate,Give_Away__c,RecordTypeId from Order Where Id in: ItemIds];
        
        for(order mOrder: pordrlist ){  
            orMap.put(mOrder.id,mOrder.RecordTypeId);                      
            GAMap.put(mOrder.id,mOrder.Give_Away__c);      
        }
        for(orderitem orderItm1:newOrderItem){
            if(orMap.get(orderItm1.OrderId)  == FOCDirectRecordTypeId && GAMap.get(orderItm1.OrderId)!=null ){
                OrderItem ordItm2 = orderItm1.clone(false,true);
                ordItm2.orderid = GAMap.get(orderItm1.OrderId);
                ListItems.add(ordItm2);
            }
            else if(orMap.get(orderItm1.OrderId)  == FocUsRecordTypeId &&GAMap.get(orderItm1.OrderId)!=null ){
                OrderItem ordItm2 = orderItm1.clone(false,true);
                ordItm2.orderid = GAMap.get(orderItm1.OrderId);
                ListItems.add(ordItm2);
            }
        }
        if(!ListItems.isEmpty()){
        insert ListItems;  
        }       
    }    
}