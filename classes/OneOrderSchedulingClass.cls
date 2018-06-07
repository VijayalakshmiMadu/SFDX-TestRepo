/************************************
Name         : OneOrderSchedulingClass  
Created By   : Chiranjeevi Gogulakonda
Company Name : Tech Mahindra
Project      : Roche Major Relase CRM 2018(CRID_2002)
Created Date : 
Test Class   : OneOrderRecordBatchClassTest
Usages       : This class is used scheduled the OneOrderRecordBatchClass
Modified By  : 
*************************************/
global class OneOrderSchedulingClass  implements Schedulable
 {
    global void execute(SchedulableContext sc)
    {
        string query = System.label.OneOrderRecurringBatchQuery;
        OneOrderRecordBatchClass bObj = new OneOrderRecordBatchClass(query); 
        database.executebatch(bObj);
    } 


}