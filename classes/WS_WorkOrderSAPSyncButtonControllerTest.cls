@isTest
public class WS_WorkOrderSAPSyncButtonControllerTest {
    Static Account actSoldTo;
    Static Account actShipTo;
    static Contact contSoldTo;
    static Contact contShipTo;
    static Pricebook2 customPB;
    static WorkOrder workorders;
    static List<PriceBookEntry> priceBookEntryRecords;
    
    //Creating FSL_GlobalConstants__c Custom Settings data for test data.
    /* commented for deployment*/
  static List < sObject > fslGlobalSettingData = Test.loadData(FSL_GlobalConstants__c.sObjectType, 'FSL_GlobalConstantsCS'); 
    /*static testmethod List<String> fslGlobalCSValues(){
        List<String> globalCSvalues= new List<String>();
        globalCSvalues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SHIP_TO','EMEA_Ship_To'));
        globalCSvalues.add(FSL_TestDataUtility.createGlobalConstantSettings('EMEA_DEFAULT_PRICEBOOK','EMEA Default Pricebook'));
        globalCSvalues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SHIP_TO_RO','EMEA_Ship_To_Read_Only'));
        globalCSvalues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SOLD_TO','EMEA_Sold_To'));
        globalCSvalues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SOLD_TO_RO','EMEA_Sold_To_Read_Only'));
        globalCSvalues.add(FSL_TestDataUtility.createGlobalConstantSettings('SERVICE_COMPLETION_STATUS','Completed'));
        globalCSvalues.add(FSL_TestDataUtility.createGlobalConstantSettings('SERVICE_SHARE_OBJ','CKSW_BASE__Service__Share'));
        return globalCSvalues;
    }*/
    private static void setUpTestData(){
        String nextgenSoldTo = CS_Utilities.getRecordTypeId('Account','NextGen_Sold_To');
        String nextgenShipTo = CS_Utilities.getRecordTypeId('Account','NextGen_Ship_To');

        // Create FSL_GlobalConstantsDetail Custom Settings
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        } 
        
        //insert act
        //Create Sold To Account
        actSoldTo = FSL_TestDataUtility.newAccount('NextGen Sold To',nextgenSoldTo,'GBP',1,true)[0];
        
        //Create Sold To Contact  
        contSoldTo = FSL_TestDataUtility.newContact('NextGen Sold To',actSoldTo.Id,1,true)[0]; 
        
        //Create Ship To Account
        actShipTo = FSL_TestDataUtility.newAccount('NextGen Ship To',nextgenShipTo,'GBP',1,false)[0];
        actShipTo.EMEA_Sold_To__c = actSoldTo.id; //Update Sold To Reference
        actShipTo.SAP_External_Id__c = '210111';
        
        insert actShipTo; //insert act
        
        //Create Sold To Contact 
        contShipTo = FSL_TestDataUtility.newContact('Ship To',actShipTo.Id,1,true)[0];
        
        //Create a Pricebook
        customPB = FSL_TestDataUtility.createPriceBook('EMEA Default Pricebook',true);
        
        // Create Pricebook Entry 
        priceBookEntryRecords = FSL_TestDataUtility.createPriceBookEntry(FSL_TestDataUtility.createProducts('TestData','GBP',1,true),customPB.Id,true);

        workorders = FSL_TestDataUtility.createWorkOrder('Draft', actSoldTo.id,actShipTo.id,contSoldTo.id,contShipTo.id,customPB.Id,2,false)[0];
        workorders.Work_Order_Source__c = 'Email';
        //workorders.CurrencyIsoCode = 'GBP';
        //workorders.SAP_Sync_Status__c = 'Success';
        
        insert workorders;
        
    }
    /* commented for deployment */
    @isTest
    static void testSyncAccountWithSAP(){
        
        //fslGlobalCSValues();
        // WS_TestHelper.setupIntegrationCalloutParameters();
        CS_Test_Utilities.createIntigrationSettings();
        
        setUpTestData();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_AccountSyncResponse());
        WorkOrderSAPSyncButtonController.syncAccountWithSAP(actShipTo.Id);

        test.stopTest();
    }
    
    @isTest
    static void testSyncRelAccountWithSAP(){
        
        //fslGlobalCSValues();
        // WS_TestHelper.setupIntegrationCalloutParameters();
        CS_Test_Utilities.createIntigrationSettings();
        
        setUpTestData();
        
        //Create Ship To Account
        Acc_Junction__c relAct = CS_Test_Utilities.createRelatedAccount(actSoldTo.Id, actShipTo.Id);
        relAct.CurrencyIsoCode = 'GBP';
        insert relAct; //insert act

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_AccountSyncResponse());
        WorkOrderSAPSyncButtonController.syncRelatedAccountWithSAP(relAct.Id);

        test.stopTest();
    }

    @isTest
    static void testSyncWorkOrderWithSAP(){
        
        //WS_TestHelper.setupIntegrationCalloutParameters();

        CS_Test_Utilities.createIntigrationSettings();
        
        setUpTestData();
        
        List<WorkOrderLineItem> woliList = WS_TestHelper.createWOLinesItems(workOrders, priceBookEntryRecords);
        for(WorkOrderLineItem woli : woliList){
            woli.Status = 'Delete';
        }
        Database.insert(woliList);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WorkOrderSAPSyncButtonController.syncOrderWithSAP(workOrders.Id);

        test.stopTest();
    }
    
    @isTest
    static void testSyncWorkOrderWithSAPCreate(){
        
        CS_Test_Utilities.createIntigrationSettings();
        
        setUpTestData();

        List<WorkOrderLineItem> woliList = WS_TestHelper.createWOLinesItems(workOrders, priceBookEntryRecords);
        Database.insert(woliList);
        
        // create location
        ServiceTerritory location = FSL_TestDataUtility.createServiceTerritory();
        
        // Update the Work Order to 'Completed'
        workOrders.Status = 'Order Placed';
        workOrders.ServiceTerritoryId = location.id;
        Database.update(workOrders);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WorkOrderSAPSyncButtonController.syncOrderWithSAP(workOrders.Id);

        test.stopTest();
    }
    
}