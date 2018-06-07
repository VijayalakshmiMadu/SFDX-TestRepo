/************************************
Name         : AccCheckDeliverOrderCreationController 
Created By   : Chiranjeevi Gogulakonda
Company Name : Tech Mahindra
Project      : Roche Major Relase CRM 2018(CRID_2001,CRID_2002,CRID_1037)
Created Date : 
Test Class   : AccCheckDeliverOrderCreationControllerTest
Usages       : This Class is used to create FOC Direct,FOC US,Give Away and Standing orders at a time. 
Modified By  : 
*************************************/

public with sharing class AccCheckDeliverOrderCreationController {
    Public Order ord{get;set;}    
    Public Order FocDirectOrd{get;set;}
    Public Order FocUsOrd{get;set;}
    Public Order GiveAwayOrd{get;set;} 
    Public Order StandingOrd{get;set;} 
    Public Id FOCDirectRecordTypeId;
    Public Id FocUsRecordTypeId ;
    Public Id GiveAwayRecordTypeId ;
    Public Id StandingRecordTypeId ;
    Public List<Order> OrderList{get;set;}  
    Public List<Order> AllOrderList{get;set;}  
    Public List<Order> UpdateOrderList{get;set;}  
    Public Account acc{get;set;}   
    public string selectedPricebook {get;set;} 
    public string selectedPricebookFOCUS{get;set;}
    public string selectedPricebookGiveAway{get;set;}
    public List<PricebookEntry> pricebookEntries {get; private set;}
    Public Boolean SaveHide{get;set;}
    public AccCheckDeliverOrderCreationController (){ 
        FOCDirectRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC Direct').getRecordTypeId();
        FocUsRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('FOC US').getRecordTypeId();
        GiveAwayRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Give Away').getRecordTypeId();     
        StandingRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standing Order').getRecordTypeId();   
        FocDirectOrd= new Order();
        FocDirectOrd.AccountId= label.Accu_Check_Account_Id;
        FocDirectOrd.FoCReason__c= 'Marketing/DME';
        FocDirectOrd.EffectiveDate= System.Today();
        FocDirectOrd.RequestedDeliveryDate__c = System.Today()+7;
        FocDirectOrd.status='Draft';          
        FocUsOrd= new Order();  
        try {
        acc=[SELECT id,Name,Recordtype.name FROM Account where Name =: userinfo.getName() and (Recordtype.name='SalesRep' OR Recordtype.name='Person Account')];
        FocUsOrd.AccountId=acc.id;
        }
        catch (System.QueryException e) {
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Sales Rep Account is not available for this User');
        }               
        FocUsOrd.FoCReason__c= 'Samples';
        FocUsOrd.EffectiveDate= System.Today();
        FocUsOrd.RequestedDeliveryDate__c = System.Today()+7;
        FocUsOrd.status='Draft'; 
        FocUsOrd.Pricebook2Id=label.Accu_Check_Pricebook_Id;   
        
        GiveAwayOrd= new Order();
        GiveAwayOrd.status='Draft';  
        GiveAwayOrd.EffectiveDate= System.Today();
        GiveAwayOrd.Pricebook2Id=label.Accu_Check_Pricebook_Id;
        
        StandingOrd = new Order();
        StandingOrd.EffectiveDate= System.Today();
        StandingOrd.status='Draft';       
        SaveHide =true;    
        
    }
    public void orderSave() {       
        OrderList = new  List<Order>(); 
        UpdateOrderList = new  List<Order>();       
        Order FocDirect = new Order();
        FocDirect.RecordtypeId = FOCDirectRecordTypeId;
        FocDirect.AccountId = FocDirectOrd.AccountId;
        FocDirect.FoCReason__c= FocDirectOrd.FoCReason__c;
        FocDirect.EffectiveDate= FocDirectOrd.EffectiveDate; 
        FocDirect.RequestedDeliveryDate__c = FocDirectOrd.RequestedDeliveryDate__c; 
        FocDirect.Status= FocDirectOrd.Status; 
        FocDirect.Recipient_Name__c= FocDirectOrd.Recipient_Name__c;   
        FocDirect.Recipient_Text__c= FocDirectOrd.Recipient_Text__c;
        if(FocDirectOrd.Recipient_Name__c != Null){
            contact con=[SELECT id,Name FROM Contact where id =: FocDirectOrd.Recipient_Name__c];
            FocDirect.RecipientName__c= con.name +';'+  FocDirectOrd.Recipient_Text__c;   
        }  
        FocDirect.ShippingCountrycode = FocDirectOrd.ShippingCountrycode;
        FocDirect.ShippingStreet= FocDirectOrd.ShippingStreet;
        FocDirect.ShippingCity= FocDirectOrd.ShippingCity;
        FocDirect.ShippingStateCode= FocDirectOrd.ShippingStateCode;
        FocDirect.ShippingPostalCode= FocDirectOrd.ShippingPostalCode;
        FocDirect.Pricebook2Id = selectedPricebook; 
        FocDirect.One_Order__c = True;
        FocDirect.CurrencyIsoCode='USD'; 
        Order FocUs= new Order();
        FocUs.RecordtypeId = FocUsRecordTypeId ;
        FocUs.AccountId = FocUsOrd.AccountId;
        FocUs.FoCReason__c= FocUsOrd.FoCReason__c;
        FocUs.EffectiveDate= FocUsOrd.EffectiveDate;
        FocUs.RequestedDeliveryDate__c = FocUsOrd.RequestedDeliveryDate__c;
        FocUs.Status = FocUsOrd.Status;
        FocUs.Approver__c=FocUsOrd.Approver__c;  
        FocUs.Approval_Queue__c = FocUsord.Approval_Queue__c;
        FocUs.CurrencyIsoCode='USD';
        //FocUs.RecipientName__c =FocUsOrd.RecipientName__c;
        //FocUs.Recipient_Text__c= FocUsOrd.Recipient_Text__c;
        if(FocDirectOrd.Recipient_Name__c != Null){          
            FocUs.RecipientName__c= FocDirect.RecipientName__c;   
        }  
        
        //FocUs.RecipientName__c= FocUsOrd.Recipient_Name__r.name +','+ FocUsOrd.Recipient_Text__c;         
        FocUs.ShippingCountrycode = FocUsOrd.ShippingCountrycode;
        FocUs.ShippingStreet= FocUsOrd.ShippingStreet;
        FocUs.ShippingCity= FocUsOrd.ShippingCity;
        FocUs.ShippingStateCode= FocUsOrd.ShippingStateCode;
        FocUs.ShippingPostalCode= FocUsOrd.ShippingPostalCode;
        FocUs.Pricebook2Id = FocUsOrd.Pricebook2Id ;
        FocUs.One_Order__c = True;
        Order GiveAway= new Order();
        GiveAway.RecordtypeId = GiveAwayRecordTypeId ;
        GiveAway.AccountId = GiveAwayOrd.AccountId;
        GiveAway.Status = GiveAwayOrd.Status;
        GiveAway.EffectiveDate= GiveAwayOrd.EffectiveDate;
        //GiveAway.Pricebook2Id = selectedPricebookGiveAway;
        GiveAway.Pricebook2Id = GiveAwayOrd.Pricebook2Id;
        GiveAway.One_Order__c = True;        
        GiveAway.Campaign__c = GiveAwayOrd.Campaign__c;
        GiveAway.CurrencyIsoCode='USD';
        
        Order Standing = new Order();
        Standing.RecordtypeId = StandingRecordTypeId ; 
        Standing.AccountId= StandingOrd.AccountId;
        Standing.EffectiveDate= StandingOrd.EffectiveDate; 
        Standing.Approver__c= StandingOrd.Approver__c;
        Standing.Approval_Queue__c = StandingOrd.Approval_Queue__c;
        Standing.Status= StandingOrd.Status;
        Standing.Recurring_Order__c= StandingOrd.Recurring_Order__c;
        Standing.Recurrence_Start_Date__c= StandingOrd.Recurrence_Start_Date__c;
        Standing.Recurrence_Frequency__c= StandingOrd.Recurrence_Frequency__c;
        Standing.Recurrence_End_Date__c= StandingOrd.Recurrence_End_Date__c;
        Standing.One_Order__c = True;
        Standing.CurrencyIsoCode='USD';
        if(FocDirectOrd.AccountId != Null){
            OrderList.add(FocDirect);
        }
        if(FocUs.AccountId != Null || FocUsOrd.AccountId != Null){            
            OrderList.add(FocUs);
        }
        if(GiveAwayOrd.AccountId != Null ){ 
            OrderList.add(GiveAway);
        }
        if(StandingOrd.Recurring_Order__c != False){
            OrderList.add(Standing);
        }
        try{
            if(OrderList.size()>0){
                if(FocUs.AccountId != Null){
                 if(FocUs.AccountId != acc.id ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select only respective Sales Rep Account'));                  
                   
                } 
                }                             
                database.insert(OrderList);
                SaveHide = False;
                
               OneOrderTracking__c OneOrder = new OneOrderTracking__c();
                for(Order ord:OrderList){
                    if(Ord.RecordTypeId == FOCDirectRecordTypeId ){
                    OneOrder.FOC_Direct__c= ord.id; 
                    }
                    if(Ord.RecordTypeId == FocUsRecordTypeId ){
                    OneOrder.FOC_US__c= ord.id; 
                    }
                    if(Ord.RecordTypeId == GiveAwayRecordTypeId ){
                    OneOrder.Give_Away__c= ord.id; 
                    }
                    if(Ord.RecordTypeId == StandingRecordTypeId ){
                    OneOrder.Standing_Order__c= ord.id; 
                    }                   
                }
                database.insert(OneOrder);

                if(OrderList.size()>0){
                    AllOrderList =[SELECT Id,OrderNumber,recordtype.name,Account.name,status From Order where id in : OrderList];  
                    if(AllOrderList.size()>0){
                        for(Order ord: AllOrderList ) {                  
                            if(ord.Recordtypeid != GiveAwayRecordTypeId || ord.Recordtypeid != StandingRecordTypeId ){
                                if(GiveAwayOrd.AccountId != Null){
                                    if( FocUsOrd.AccountId != Null && FocDirectOrd.AccountId != Null){
                                        ord.Give_Away__c= OrderList[2].id;                     
                                    }
                                    if((FocUsOrd.AccountId != Null && FocDirectOrd.AccountId == Null) || (FocUsOrd.AccountId == Null && FocDirectOrd.AccountId != Null)){
                                        ord.Give_Away__c= OrderList[1].id;   
                                    }
                                }
                            }
                            if(ord.Recordtypeid != StandingRecordTypeId ){
                                if(StandingOrd.Recurring_Order__c != False ||StandingOrd.AccountId  != Null){  
                                    if( FocUsOrd.AccountId != Null && FocDirectOrd.AccountId != Null && GiveAwayOrd.AccountId != Null){
                                        //ord.Standing_Order__c = OrderList[3].id;  
                                        ord.Standing_Order__c= OrderList[3].id;                                   
                                    } 
                                    if( (FocUsOrd.AccountId == Null && FocDirectOrd.AccountId != Null && GiveAwayOrd.AccountId != Null) || (FocUsOrd.AccountId != Null && FocDirectOrd.AccountId == Null && GiveAwayOrd.AccountId != Null)|| (FocUsOrd.AccountId != Null && FocDirectOrd.AccountId != Null && GiveAwayOrd.AccountId == Null)){
                                        //ord.Standing_Order__c = OrderList[2].id;
                                        ord.Standing_Order__c= OrderList[2].id;                                       
                                    } 
                                    if( (FocUsOrd.AccountId == Null && FocDirectOrd.AccountId == Null && GiveAwayOrd.AccountId != Null) || (FocUsOrd.AccountId != Null && FocDirectOrd.AccountId == Null && GiveAwayOrd.AccountId == Null)|| (FocUsOrd.AccountId == Null && FocDirectOrd.AccountId != Null && GiveAwayOrd.AccountId == Null)){
                                        //ord.Standing_Order__c = OrderList[0].id;
                                        ord.Standing_Order__c= OrderList[1].id;                                      
                                    } 
                                }
                            }  
                            UpdateOrderList.add(ord);
                        }
                    }   
                    update UpdateOrderList;                 
                }
            }
        }
         catch (NullPointerException ex) {
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Sales Rep Account is not available for this User OR Please Select only respective Sales Rep Account');
              ApexPages.addMessage(myMsg);
        }  
        catch(DMLException e){ApexPages.addMessages(e);}    
        //PageReference acctPage= new PageReference('/'+FocDirectOrd.AccountId);
        // acctPage.setRedirect(true);
        // return acctPage;       
    }    
    public PageReference cancelBtn() {
        pageReference cancelpge= new pageReference('/home/home.jsp');
        cancelpge.setRedirect(true);
        return cancelpge;
    }
    public void addressPopulate() {  
        if(FocDirectOrd.Recipient_Name__c != Null){    
            Contact Con=[SELECT Id,Name,AccountId,MailingCountrycode,MailingStreet,MailingCity,MailingStateCode,MailingPostalCode FROM Contact Where Id =: FocDirectOrd.Recipient_Name__c];
            FocDirectOrd.ShippingCountrycode= Con.MailingCountrycode;
            FocDirectOrd.ShippingStreet = Con.MailingStreet;
            FocDirectOrd.ShippingCity= Con.MailingCity;
            FocDirectOrd.ShippingStateCode= Con.MailingStateCode;
            FocDirectOrd.ShippingPostalCode = Con.MailingPostalCode;  
            FocUsOrd.Recipient_Name__c= FocDirectOrd.Recipient_Name__c;
            FocUsOrd.ShippingCountrycode= Con.MailingCountrycode;
            FocUsOrd.ShippingStreet = Con.MailingStreet;
            FocUsOrd.ShippingCity= Con.MailingCity;
            FocUsOrd.ShippingStateCode= Con.MailingStateCode;
            FocUsOrd.ShippingPostalCode = Con.MailingPostalCode;
            GiveAwayOrd.AccountId = Con.AccountId; 
        }    
    }
    Public void priceBookPopulate(){
    system.debug('selectedPricebook '+selectedPricebook );
       if(selectedPricebook != Null){    
          FocUsOrd.Pricebook2Id = selectedPricebook ;
          GiveAwayOrd.Pricebook2Id = selectedPricebook ;
       
       }
    
    }
    /* public void focUSAddPopulate() {      
Contact Con=[SELECT Id,Name,AccountId,MailingCountrycode,MailingStreet,MailingCity,MailingStateCode,MailingPostalCode FROM Contact Where Id =: FocUsOrd.Recipient_Name__c];
FocUsOrd.ShippingCountrycode= Con.MailingCountrycode;
FocUsOrd.ShippingStreet = Con.MailingStreet;
FocUsOrd.ShippingCity= Con.MailingCity;
FocUsOrd.ShippingStateCode= Con.MailingStateCode;
FocUsOrd.ShippingPostalCode = Con.MailingPostalCode;  
GiveAwayOrd.AccountId = Con.AccountId;    
}*/
    public List<SelectOption> getPricebookOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<Pricebook2> pricebooks = [SELECT Id, Name from Pricebook2 where IsActive = true ]; //AND Country__c = 'United States'
        options.add(new SelectOption(label.Accu_Check_Pricebook_Id,'US Accu-Chek Delivers Price Book Order'));
        for(Pricebook2 pricebook : pricebooks) {        
            options.add(new SelectOption(pricebook.Id,pricebook.Name));
        }
        return options;
    }  
    
}