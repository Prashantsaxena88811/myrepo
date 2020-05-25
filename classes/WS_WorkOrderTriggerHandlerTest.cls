@isTest
private class WS_WorkOrderTriggerHandlerTest {
    //Creating FSL_GlobalConstants__c Custom Settings data for test data.
    /*commented this for deployment */
   static List < sObject > fslGlobalSettingData = Test.loadData(FSL_GlobalConstants__c.sObjectType, 'FSL_GlobalConstantsCS'); 
    
    
   /* static testmethod List<String> fslGlobalCSValues(){
        List<String> fslGlobalValues = new List<String>();
        fslGlobalValues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SHIP_TO','EMEA_Ship_To'));
        fslGlobalValues.add(FSL_TestDataUtility.createGlobalConstantSettings('EMEA_DEFAULT_PRICEBOOK','EMEA Default Pricebook'));
        fslGlobalValues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SHIP_TO_RO','EMEA_Ship_To_Read_Only'));
        fslGlobalValues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SOLD_TO','EMEA_Sold_To'));
        fslGlobalValues.add(FSL_TestDataUtility.createGlobalConstantSettings('RT_EMEA_SOLD_TO_RO','EMEA_Sold_To_Read_Only'));
        fslGlobalValues.add(FSL_TestDataUtility.createGlobalConstantSettings('SERVICE_COMPLETION_STATUS','Completed'));
        fslGlobalValues.add(FSL_TestDataUtility.createGlobalConstantSettings('SERVICE_SHARE_OBJ','CKSW_BASE__Service__Share'));
        return fslGlobalValues;
    }*/
    /*commented this for deployment */
    @isTest
    static void testSyncAccountWithSAP(){
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockAccountResponse());

        WS_TestHelper.setupIntegrationCalloutParameters();
        
        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        Account acc = WS_TestHelper.insertSoldToAccount();
        acc.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(acc);
        Account shipTo = WS_TestHelper.insertShipToAccount(acc.Id);
        shipTo.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipTo);

        test.startTest();

        WorkOrderSAPSyncButtonController.syncAccountWithSAP(shipTo.Id);

        test.stopTest();
    }

    @isTest
    static void testSyncWorkOrderWithSAP(){
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        WS_TestHelper.setupIntegrationCalloutParameters();
        
        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);
        
        Account acc = WS_TestHelper.insertSoldToAccount();
        acc.CurrencyIsoCode = 'CAD';
        acc.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(acc);
        Account shipTo = WS_TestHelper.insertShipToAccount(acc.Id);
        shipTo.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipTo);

        WorkOrder wo = WS_TestHelper.createWorkOrder(acc, shipTo, camsoPricebook);

        wo.SAP_External_Id__c = '0005000975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.CurrencyIsoCode = 'CAD';
        wo.Work_Order_Source__c = 'Email';
        Database.insert(wo);
        
        //get the CurrencyIsoCode of the method
        //List<CurrencyType> curr = [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive = TRUE];

        // Create Products
        List<Product2> createProducts = WS_TestHelper.insertProducts();
            
        Database.upsert(createProducts);
        
        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, createProducts);
        for (PricebookEntry pb : pbEntryList){
            pb.CurrencyIsoCode = wo.CurrencyIsoCode;
        }
        Database.upsert(pbEntryList); 
        
        List<WorkOrderLineItem> woliList = WS_TestHelper.createWOLinesItems(wo, pbEntryList);
        
        Database.insert(woliList);

        test.startTest();

        WorkOrderSAPSyncButtonController.syncOrderWithSAP(wo.Id);

        test.stopTest();
    }

    
    @isTest
    static void testSyncWorkOrderWithSAPNoLineItems(){
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        WS_TestHelper.setupIntegrationCalloutParameters();
        
        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);

        Account acc = WS_TestHelper.insertSoldToAccount();
        acc.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(acc);
        Account shipTo = WS_TestHelper.insertShipToAccount(acc.Id);
        shipTo.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipTo);

        WorkOrder wo = WS_TestHelper.createWorkOrder(acc, shipTo, camsoPricebook);

        wo.SAP_External_Id__c = '0005001975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Work_Order_Source__c = 'Email';

        Database.insert(wo);

        // Create Products
        //List<Product2> createProducts = WS_TestHelper.insertProducts();
        //Database.upsert(createProducts);

        //List<WorkOrderLineItem> woliList = WS_TestHelper.createWOLinesItems(wo, createProducts);
        //Database.insert(woliList);

        test.startTest();

        String msg = WorkOrderSAPSyncButtonController.syncOrderWithSAP(wo.Id);


        test.stopTest();
        System.assert(msg.contains('Please add line items to this Order before you sync to SAP'));
    }


    @isTest
    static void testSelectionOfProductOnWorkOrderLineItem() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();
        
        Test.startTest();
        //fslGlobalCSValues();        
        Pricebook2 camsoPricebook = WS_TestHelper.createEMEAPricebook();
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        // Create Sold To
        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(soldToAccount);

        // Create Ship To
        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);
        // - This should also create the Related Account junction in the background

        // Create Work Order
        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        wo.SAP_External_Id__c = '0105000975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'Order Placed';
        wo.Work_Order_Source__c = 'Email';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';

        List<WorkOrder> woList = new List<WorkOrder>();
        
        woList.add(wo);

        Test.stopTest();

        // TRY UPSERTING THE WORK ORDER IN SALESFORCE AND ENSURE CODE HAS RUN
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='joppe.koning@kvnconsultancy.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='joppe.koning@kvnconsultancy.com');

        // Insert products
        List<Product2> prodList = WS_TestHelper.insertProducts();
        Database.upsert(prodList);

        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, prodList);
        Database.upsert(pbEntryList); 

        System.runAs(u) {

            Database.upsert(woList);

            // Create Necessary Work Order Line Items
            WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId=wo.Id,PricebookEntryId=pbEntryList.get(0).Id, Product__c=prodList.get(0).Id  );
            
            List<WorkOrderLineItem> woliList = new List<WorKOrderLineItem>();
            woliList.add(woli);

            WorkOrderLineItemTriggerHandler.selectPricebookEntryForWOLI(woliList);

            //Database.insert(woli);


            //WorkOrderLineItem woliRet = [SELECT Id, PricebookEntryId FROM WorkOrderLineItem WHERE Id = :woli.Id];
            
            System.assert(woli.PricebookEntryId != null);

        }
    }

    @isTest
    static void testSetDefaultPricebookOnWorkOrder() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }
        
        WS_TestHelper.setupIntegrationCalloutParameters();

        Test.startTest();
        //fslGlobalCSValues();
        Pricebook2 camsoPricebook = WS_TestHelper.createEMEAPricebook();
        Database.insert(camsoPricebook);
        
        // Create Sold To
        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;   
        soldToAccount.IsToyotaAccount__c = True;
        Database.insert(soldToAccount);
        
        // Create Ship To
        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);
        // - This should also create the Related Account junction in the background
        
        List<ServiceTerritory> location1 = WS_TestHelper.insertLocations();
        
        
        // Create Work Order
        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        wo.SAP_External_Id__c = '0005100975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'Order Placed';
        wo.ServiceTerritoryId = location1[0].id;
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Order_Placed_Date__c = System.now();
        wo.Order_Completed_Date__c = System.now().addDays(10);
        wo.SAP_Sync_Required__c = true;
        wo.Data_Source__c = 'Salesforce';
        wo.Work_Order_Source__c = 'Email';
        database.insert(wo);
        System.debug('WO details'+wo);
        
        wo.SAP_External_Id__c = null;
        update wo;
        List<WorkOrder> woList1 = new List<WorkOrder>();
        woList1.add(wo);
        wo.SAP_External_Id__c = '0005000975';
        wo.SAP_Sync_Required__c = false;
        update wo;
        map<id,WorkOrder> wkMap = new map<id,WorkOrder>();       
        wkMap.put(wo.id, wo);
        wo.SAP_Sync_Required__c = true;
        wo.Status = 'Completed';
        update wo;
        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);
        
        // DateTime StartdDate;
        // DateTime CompletedDate;
        // StartdDate = System.now();
        // CompletedDate = System.now().addDays(10);
        
        Test.stopTest();

        // TRY UPSERTING THE WORK ORDER IN SALESFORCE AND ENSURE CODE HAS RUN
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='joppe.koning@kvnconsultancy.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='joppe.koning@kvnconsultancy.com');

        System.runAs(u) {
            
            WorkOrderTriggerHandler.setDefaultPricebookOnWorkOrder(woList);
            //Integer test = WorkOrderTriggerHandler.getNumberOfBusinessDaysBetweenTwoDates(StartdDate, CompletedDate);
            //WorkOrderTriggerHandler.JobCompletionNotificationToEndUsers(woList, wkMap);
            System.assert(wo.Pricebook2Id == camsoPricebook.Id);
        }
    }
    
    /*@isTest
    static Integer testGetNumberOfBusinessDaysBetweenTwoDates() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();
        
        Test.startTest();
        DateTime StartdDate;
        DateTime CompletedDate;
        StartdDate = System.now();
        CompletedDate = System.now().addDays(10);

        Test.stopTest();

        // TRY UPSERTING THE WORK ORDER IN SALESFORCE AND ENSURE CODE HAS RUN
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='joppe.koning@kvnconsultancy.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='joppe.koning@kvnconsultancy.com');

        System.runAs(u) {

            WorkOrderLineItemTriggerHandler.getNumberOfBusinessDaysBetweenTwoDates(StartdDate, CompletedDate);
            //WorkOrderLineItemTriggerHandler.getNumberOfBusinessDaysBetweenTwoDates();
            
        }
    }*/
    
    @isTest
    static void testWithParent() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }
        
        WS_TestHelper.setupIntegrationCalloutParameters();

        Test.startTest();
        //fslGlobalCSValues();
        Pricebook2 camsoPricebook = WS_TestHelper.createEMEAPricebook();
        Database.insert(camsoPricebook);
        
        // Create Sold To
        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;   
        soldToAccount.IsToyotaAccount__c = False;
        Database.insert(soldToAccount);
        
        // Create Sold To2
        Account soldToAccount2 = WS_TestHelper.insertSoldToAccount();
        soldToAccount2.Name = 'test2';
        soldToAccount2.Assigned_Price_Book__c = camsoPricebook.Id;   
        soldToAccount2.IsToyotaAccount__c = True;
        soldToAccount2.ParentId = soldToAccount.Id;
        soldToAccount2.SAP_External_Id__c = '1234';
        soldToAccount2.ShippingCity = 'London';
        Database.upsert(soldToAccount2);
        
        // Create Ship To
        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount2.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        shipToAccount.EMEA_Sold_To__c =soldToAccount2.Id;
        Database.insert(shipToAccount);
        // - This should also create the Related Account junction in the background
        
        List<ServiceTerritory> location1 = WS_TestHelper.insertLocations();
        
        
        // Create Work Order
        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount2, shipToAccount, camsoPricebook);

        wo.SAP_External_Id__c = '0005100975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'Order Placed';
        wo.ServiceTerritoryId = location1[0].id;
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Order_Placed_Date__c = System.now();
        wo.Order_Completed_Date__c = System.now().addDays(10);
        wo.SAP_Sync_Required__c = true;
        wo.Data_Source__c = 'Salesforce';
        wo.Work_Order_Source__c = 'Email';
        database.insert(wo);
        System.debug('WO details'+wo);
        
        wo.SAP_External_Id__c = null;
        update wo;
        List<WorkOrder> woList1 = new List<WorkOrder>();
        woList1.add(wo);
        wo.SAP_External_Id__c = '0005000975';
        wo.SAP_Sync_Required__c = false;
        update wo;
        map<id,WorkOrder> wkMap = new map<id,WorkOrder>();       
        wkMap.put(wo.id, wo);
        wo.SAP_Sync_Required__c = true;
        wo.Status = 'Service Completed';
        wo.Data_Source__c = 'Salesforce';
        update wo;
        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);
        
        //DateTime StartdDate;
        //DateTime CompletedDate;
        //StartdDate = System.now();
        //CompletedDate = System.now().addDays(10);
        

        Test.stopTest();

        // TRY UPSERTING THE WORK ORDER IN SALESFORCE AND ENSURE CODE HAS RUN
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='joppe.koning@kvnconsultancy.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='joppe.koning@kvnconsultancy.com');

        System.runAs(u) {
            
            WorkOrderTriggerHandler.setDefaultPricebookOnWorkOrder(woList);
            //Integer test = WorkOrderTriggerHandler.getNumberOfBusinessDaysBetweenTwoDates(StartdDate, CompletedDate);
            //WorkOrderTriggerHandler.JobCompletionNotificationToEndUsers(woList, wkMap);
            System.assert(wo.Pricebook2Id == camsoPricebook.Id);
        }
    }
    
    @isTest
    static void testWithoutParent() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }
        
        WS_TestHelper.setupIntegrationCalloutParameters();

        Test.startTest();
        //fslGlobalCSValues();
        Pricebook2 camsoPricebook = WS_TestHelper.createEMEAPricebook();
        Database.insert(camsoPricebook);
        
        // Create Sold To
        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;   
        soldToAccount.IsToyotaAccount__c = True;
        Database.insert(soldToAccount);
        
        // Create Ship To
        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        shipToAccount.EMEA_Sold_To__c =soldToAccount.Id;
        Database.insert(shipToAccount);
        // - This should also create the Related Account junction in the background
        
        List<ServiceTerritory> location1 = WS_TestHelper.insertLocations();
        
        
        // Create Work Order
        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        wo.SAP_External_Id__c = '0005100975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'Order Placed';
        wo.ServiceTerritoryId = location1[0].id;
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Order_Placed_Date__c = System.now();
        wo.Order_Completed_Date__c = System.now().addDays(10);
        wo.SAP_Sync_Required__c = true;
        wo.Data_Source__c = 'Salesforce';
        wo.Order_Completed_Date__c = System.now();
        wo.Order_Placed_Date__c = System.now();
        wo.Work_Order_Source__c = 'Email';
        database.insert(wo);
        System.debug('WO details'+wo);
        
        wo.SAP_External_Id__c = null;
        update wo;
        List<WorkOrder> woList1 = new List<WorkOrder>();
        woList1.add(wo);
        wo.SAP_External_Id__c = '0005000975';
        wo.SAP_Sync_Required__c = false;
        update wo;
        map<id,WorkOrder> wkMap = new map<id,WorkOrder>();       
        wkMap.put(wo.id, wo);
        wo.SAP_Sync_Required__c = true;
        wo.Status = 'Completed';
        update wo;
        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);
        
        //DateTime StartdDate;
        //DateTime CompletedDate;
        //StartdDate = System.now();
        //CompletedDate = System.now().addDays(10);
        

        Test.stopTest();

        // TRY UPSERTING THE WORK ORDER IN SALESFORCE AND ENSURE CODE HAS RUN
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='joppe.koning@kvnconsultancy.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='joppe.koning@kvnconsultancy.com');

        System.runAs(u) {
            
            WorkOrderTriggerHandler.setDefaultPricebookOnWorkOrder(woList);
            //Integer test = WorkOrderTriggerHandler.getNumberOfBusinessDaysBetweenTwoDates(StartdDate, CompletedDate);
            //WorkOrderTriggerHandler.JobCompletionNotificationToEndUsers(woList, wkMap);
            System.assert(wo.Pricebook2Id == camsoPricebook.Id);
        }
    }
    
    @isTest 
    static void testUpdateSAPBasedPicklists() {

        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();

        Test.startTest();

        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }
        
        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        soldToAccount.IsToyotaAccount__c = False;
        Database.insert(soldToAccount);

        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);
        List<ServiceTerritory> location1 = WS_TestHelper.insertLocations();
        // Mimic an API based insert of a Work Order

        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        wo.SAP_External_Id__c = '0005000975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'Needs Follow Up';
        wo.Work_Order_Source__c = 'Email';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Data_Source__c = 'Salesforce';
        database.insert(wo);
        map<id,WorkOrder> wkMap = new map<id,WorkOrder>();       
        wkMap.put(wo.id, wo);
        wo.Status = 'Completed';
        //wo.SAP_External_Id__c = null;
        update wo;
        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);
        Test.stopTest();

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='joppe.koning@kvnconsultancy.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='joppe.koning@kvnconsultancy.com');

        System.runAs(u) {
            
            WorkOrderTriggerHandler.updateSAPBasedPicklists(woList);
            //WorkOrderTriggerHandler.JobCompletionNotificationToEndUsers(woList, wkMap);
            System.assert(wo.SAP_Order_Type__c == 'ZE01');
        }
        
        //Database.insert(wo);
    
        
    }

    @isTest 
    static void testWorkOrderIntegrationCreditCallout() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();

        Test.startTest();

        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(soldToAccount);

        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);
        
        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        //wo.SAP_External_Id__c = '0005000975';
        //wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';
        wo.Work_Order_Source__c = 'Email';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Pricebook2 = camsoPricebook;
        wo.Account = shipToAccount;
        wo.Sold_To_Account__c = soldToAccount.Id;

        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);

        
        Database.insert(woList);
        
        Test.stopTest();

        WorkOrder resWo = [SELECT Id, Account_Credit_Status__c FROM WorkOrder WHERE Id = :wo.Id];
        System.assertEquals(resWo.Account_Credit_Status__c, soldToAccount.Credit_Status__c);


    }
    
    /*@isTest 
    static void testWorkOrderIntegrationViaTriggerExecution() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();

        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);

        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(soldToAccount);

        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);

        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        //wo.SAP_External_Id__c = '0005000975';
        //wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';

        wo.SAP_Order_Type__c = 'ZES1';
        wo.Billing_Block__c = '3';
        wo.Pricebook2 = camsoPricebook;
        wo.Account = shipToAccount;
        wo.Sold_To_Account__c = soldToAccount.Id;

        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);



        Database.insert(woList);

        List<Product2> prodList = WS_TestHelper.insertProducts();
        Database.upsert(prodList);

        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, prodList);
        Database.upsert(pbEntryList); 

        // Create Work Order Line Items

        // Insert WorkOrderLineItem
        List<WorkOrderLineItem> woliItems = WS_TestHelper.createWOLinesItems(wo, pbEntryList);
        Database.insert(woliItems);

        // Change Work Order to Order place and do an upsert
        wo.Status = 'Order Placed';
        wo.SAP_External_Id__c = '111232';
        update wo;

        

        // Assert that the Work Order SAP Sync Required field has moved to True
        //WorkOrder wo = [SELECT Id, SAP_Sync_Required__c FROM WorkOrder wo]

        // Update one of the integration fields on the work order
        wo.Billing_Block__c = '05 - testing';
        wo.Status = 'Completed';
        update wo;
        // An integration callout should not been fired in this instance.

        WorkOrder resWO = [SELECT Id, SAP_Sync_Required__c FROM WorkOrder WHERE Id = :wo.Id];
        System.assertEquals(resWO.SAP_Sync_Required__c, false);


    }
    */
/*commented this for deployment */
    @isTest
    static void testChangingOfLocations(){
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();
        // fslGlobalCSValues();
        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.CurrencyIsoCode = 'CAD';
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(soldToAccount);

        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);

        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        List<ServiceTerritory> locationList =  WS_TestHelper.insertLocations();

        //wo.SAP_External_Id__c = '0005000975';
        //wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';
        wo.CurrencyIsoCode = 'CAD';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Pricebook2 = camsoPricebook;
        wo.Account = shipToAccount;
        wo.Sold_To_Account__c = soldToAccount.Id;
        wo.Work_Order_Source__c = 'Email';

        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);

        Database.insert(woList);

        List<Product2> prodList = WS_TestHelper.insertProducts();
        Database.upsert(prodList);

        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, prodList);
        for (PricebookEntry pb : pbEntryList){
            pb.CurrencyIsoCode = wo.CurrencyIsoCode;
        }
        Database.upsert(pbEntryList); 

        // Create Work Order Line Items

        // Insert WorkOrderLineItem
        List<WorkOrderLineItem> woliItems = WS_TestHelper.createWOLinesItems(wo, pbEntryList);
        Database.insert(woliItems);
          

        // Change Work Order to Order place and do an upsert
        wo.Status = 'Order Placed';
        wo.SAP_External_Id__c = '1111111';
        wo.ServiceTerritoryId = locationList.get(1).Id;
        update wo;


    }

         /*@isTest 
    static void testWorkOrderLineItemIntegrationViaTriggerExecution() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();


        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);

        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(soldToAccount);

        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);

        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        //wo.SAP_External_Id__c = '0005000975';
        //wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';

        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '3';
        wo.Pricebook2 = camsoPricebook;
        wo.Account = shipToAccount;
        wo.Sold_To_Account__c = soldToAccount.Id;

        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);

        Database.insert(woList);

        List<Product2> prodList = WS_TestHelper.insertProducts();
        Database.upsert(prodList);

        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, prodList);
        Database.upsert(pbEntryList); 

        // Create Work Order Line Items

        // Insert WorkOrderLineItem
        List<WorkOrderLineItem> woliItems = WS_TestHelper.createWOLinesItems(wo, pbEntryList);
        Database.insert(woliItems);

    

        // Change Work Order to Order place and do an upsert
        wo.Status = 'Order Placed';
        wo.SAP_External_Id__c = '1111111';
        update wo;

        Test.startTest();
        // Update one of the integration fields on the work order
        WorkOrderLineItem currentWOLI = [SELECT Id, Quantity, Product2Id, PricebookEntryId FROM WorkOrderLineItem WHERE Id = :woliItems.get(0).Id];
        System.debug('##### currentWOLI: ' + currentWOLI);

        //currentWOLI.Quantity = 7;
        //Database.upsert(currentWOLI);
        // An integration callout should have been fired in this instance.

        // Delete a WOLI item to trigger integration.

        Database.delete(currentWOLI);

        WorkOrder resWO = [SELECT Id, SAP_Sync_Required__c, SAP_Sync_Status__c FROM WorkOrder WHERE Id = :wo.Id];
        
        Test.stopTest();
        System.assertEquals(resWO.SAP_Sync_Status__c, 'In Progress');

        resWO.Status = 'Completed';
        resWO.Order_Completed_Date__c = Date.today();
        Database.update(resWO);


    }*/
/*commented this for deployment */
        @isTest 
    static void testRohitWOLIMethods() {
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();
    
        
        
        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(soldToAccount);

        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);

        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        //wo.SAP_External_Id__c = '0005000975';
        //wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';

        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Pricebook2 = camsoPricebook;
        wo.Account = shipToAccount;
        wo.Sold_To_Account__c = soldToAccount.Id;
        wo.Work_Order_Source__c = 'Email';

        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);



        Database.insert(woList);

        List<Product2> prodList = WS_TestHelper.insertProducts();
        Database.upsert(prodList);

        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, prodList);
        Database.upsert(pbEntryList); 

        // Create Work Order Line Items

        
        List<SM_WorkOrderLineItemController.ProductWrapper> searchData;

         //WS_TestHelper.setupIntegrationCalloutParameters();
         //System.runAs(new User(Id = Userinfo.getUserId())){
             //search in the lineItem Component
             searchData = SM_WorkOrderLineItemController.searchProduct(pbEntryList[0].Product2Id,wo.Id);




        // Insert WorkOrderLineItem
        /*List<WorkOrderLineItem> woliItems = WS_TestHelper.createWOLinesItems(wo, pbEntryList);
        Database.insert(woliItems);

        // Change Work Order to Order place and do an upsert
        wo.Status = 'Order Placed';
        wo.SAP_External_Id__c = '1111111';
        update wo;

        

        // Assert that the Work Order SAP Sync Required field has moved to True
        //WorkOrder wo = [SELECT Id, SAP_Sync_Required__c FROM WorkOrder wo]

        // Update one of the integration fields on the work order
        wo.Billing_Block__c = '05 - testing';
        wo.Status = 'Completed';
        update wo;
        // An integration callout should have been fired in this instance.

        WorkOrder resWO = [SELECT Id, SAP_Sync_Required__c FROM WorkOrder WHERE Id = :wo.Id];
        System.assertEquals(resWO.SAP_Sync_Required__c, true);*/

/*commented this for deployment */
    }
    @isTest
    static void workorder(){
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());

        WS_TestHelper.setupIntegrationCalloutParameters();
        
        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        camsoPricebook.CurrencyIsoCode = 'GBP';
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        Account acc = WS_TestHelper.insertSoldToAccount();
        acc.Assigned_Price_Book__c = camsoPricebook.Id;
        acc.CurrencyIsoCode = 'CAD';
        Database.insert(acc);
        Account shipTo = WS_TestHelper.insertShipToAccount(acc.Id);
        shipTo.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipTo);
        Asset frli=FSL_TestDataUtility.createAssetItem('Toyota','5FD18',shipTo.id,acc.id,true);
        
        WorkOrder wo = WS_TestHelper.createWorkOrder(acc, shipTo, camsoPricebook);
        wo.assetid = frli.id;
        wo.SAP_External_Id__c = '0005000975';
        wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.CurrencyIsoCode = 'CAD';
        wo.Work_Order_Source__c = 'Email';

        Database.insert(wo);

        // Create Products
        List<Product2> createProducts = WS_TestHelper.insertProducts();
        //createProducts.CurrencyIsoCode = 'GBP';
        Database.upsert(createProducts);

        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, createProducts);
        for (PricebookEntry pb : pbEntryList){
            pb.CurrencyIsoCode = wo.CurrencyIsoCode;
        }
        Database.upsert(pbEntryList); 

        List<WorkOrderLineItem> woliList = WS_TestHelper.createWOLinesItems(wo, pbEntryList);
        
        Database.insert(woliList);
        WorkOrderLineItemTriggerHandler.updateForkLiftOnLineItem(woliList);
        


    }
     @isTest
    static void testChangingOfLocations1(){
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_MockMultiResponse());
        WS_TestHelper.setupIntegrationCalloutParameters();
        // fslGlobalCSValues();
        Pricebook2 camsoPricebook = WS_TestHelper.createPricebook();
        Database.insert(camsoPricebook);
        
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        System.debug('***globalConstantDetailList: ' + globalConstantDetailList);
        if(globalConstantDetailList.size() > 0){
            insert globalConstantDetailList;    
        }

        Account soldToAccount = WS_TestHelper.insertSoldToAccount();
        soldToAccount.CurrencyIsoCode = 'CAD';
        soldToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(soldToAccount);

        Account shipToAccount = WS_TestHelper.insertShipToAccount(soldToAccount.Id);
        shipToAccount.Assigned_Price_Book__c = camsoPricebook.Id;
        Database.insert(shipToAccount);

        WorkOrder wo = WS_TestHelper.createWorkOrder(soldToAccount, shipToAccount, camsoPricebook);

        List<ServiceTerritory> locationList =  WS_TestHelper.insertLocations();

        //wo.SAP_External_Id__c = '0005000975';
        //wo.SAP_Sync_Status__c = 'Success';
        wo.Status = 'New';
        wo.CurrencyIsoCode = 'CAD';
        wo.SAP_Order_Type__c = 'ZE01';
        wo.Billing_Block__c = '03';
        wo.Pricebook2 = camsoPricebook;
        wo.Account = shipToAccount;
        wo.Sold_To_Account__c = soldToAccount.Id;
        wo.Work_Order_Source__c = 'Email';

        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(wo);

        Database.insert(woList);

        List<Product2> prodList = WS_TestHelper.insertProducts();
        Database.upsert(prodList);

        // Insert PricebookEntry records
        List<PricebookEntry> pbEntryList = WS_TestHelper.addProductsToPricebook(camsoPricebook, prodList);
        for (PricebookEntry pb : pbEntryList){
            pb.CurrencyIsoCode = wo.CurrencyIsoCode;
        }
        Database.upsert(pbEntryList); 

        // Create Work Order Line Items

        // Insert WorkOrderLineItem
        List<WorkOrderLineItem> woliItems = WS_TestHelper.createWOLinesItems(wo, pbEntryList);
        Database.insert(woliItems);
        /*******************************************/
        /*commented this for deployment */
        Map<id, WorkOrderLineItem> newWoliMap = new Map<id, WorkOrderLineItem>();
        //Set<id> WliSet = new Set<Id>;
        for(WorkOrderLineItem wl : woliItems){
              newWoliMap.put(wl.id, wl);  
        }
                // Change Work Order to Order place and do an upsert
        wo.Status = 'Order Placed';
        wo.SAP_External_Id__c = '1111111';
        wo.ServiceTerritoryId = locationList.get(1).Id;
        wo.SAP_Sync_Status__c = 'In Progress';
        update wo;
        WorkOrderLineItemTriggerHandler.triggerWorkOrderLineItemIntegration(woliItems, newWoliMap, 'Update');
        WorkOrderLineItemTriggerHandler.triggerWorkOrderLineItemIntegration(woliItems, newWoliMap, 'Delete');
        Map<id, WorkOrderLineItem> newWoliMap1 = new Map<id, WorkOrderLineItem>();
        //Set<id> WliSet = new Set<Id>;
        for(WorkOrderLineItem wl1 : woliItems){
              newWoliMap1.put(wl1.id, wl1);  
        }
                // Change Work Order to Order place and do an upsert
        wo.Status = 'Order Placed';
        wo.ServiceTerritoryId = locationList.get(1).Id;
        wo.SAP_External_Id__c = '1234567';
        wo.SAP_Sync_Status__c = 'Success';
        update wo;
        WorkOrderLineItemTriggerHandler.triggerWorkOrderLineItemIntegration(woliItems, newWoliMap1, 'Update');
        WorkOrderLineItemTriggerHandler.triggerWorkOrderLineItemIntegration(woliItems, newWoliMap1, 'Delete');
    

    }
    static String accountSoldToRecType = CS_Utilities.getRecordTypeId('Account', CS_CONSTANTS.sAccount_RecTypeDevName_NG_Sold_To);
    static String accountShipToRecType = CS_Utilities.getRecordTypeId('Account', CS_CONSTANTS.sAccount_RecTypeDevName_NG_Ship_To);
    static String woPartsOnlyRecType = CS_Utilities.getRecordTypeId('WorkOrder', CS_CONSTANTS.sWorkOrder_RecTypeDevName_NG_PartsOrder);
    static Pricebook2 emeaPB;
    static Account SoldTo;
    static Account ShipTo;
    static Contact soldToContact;
    static Contact shipToContact;
    static PricebookEntry pbe;
    static Schema.Location location;
    static Schema.Location storageLocation;
    static ServiceTerritory servTerritory1;
    static ServiceTerritory servTerritory2;
    
    private static void setupData(){
        CS_Test_Utilities.createPricebookEntryRecords();
        emeaPB = [SELECT Id FROM Pricebook2 WHERE Name =: CS_CONSTANTS.PB_EMEA_DEFAULT];
        pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id =: emeaPB.Id AND Product2.ProductCode = :CS_CONSTANTS.PRODUCT_CODE1];
        
        SoldTo = CS_Test_Utilities.createNewAccount('SoldTo1', accountSoldToRecType, CS_CONSTANTS.SALESORG_3100, 'EUR', CS_CONSTANTS.STREET_UK, CS_CONSTANTS.CITY_UK, CS_CONSTANTS.COUNTRY_UK, CS_CONSTANTS.POSTALCODE_UK);
        SoldTo.Assigned_Price_Book__c = emeaPB.Id;
        SoldTo.SAP_Customer_Number__c = CS_CONSTANTS.CUSTOMER_NUMBER;
        SoldTo.SAP_External_Id__c = CS_CONSTANTS.SOLDTO_SAPID;
        SoldTo.IsToyotaAccount__c = true;
        insert SoldTo;
        ShipTo = CS_Test_Utilities.createNewAccount('ShipTo1', accountShipToRecType, CS_CONSTANTS.SALESORG_3100, 'EUR', CS_CONSTANTS.STREET_UK, CS_CONSTANTS.CITY_UK, CS_CONSTANTS.COUNTRY_UK, CS_CONSTANTS.POSTALCODE_UK);
        ShipTo.EMEA_Sold_To__c = SoldTo.Id;
        insert ShipTo;
        
        //create contact records
        List<Contact> contactList = new List<Contact>();
        soldToContact = CS_Test_Utilities.createNewContact('Test1', SoldTo.Id);
        shipToContact = CS_Test_Utilities.createNewContact('Test2', ShipTo.Id);
        contactList.add(soldToContact);
        contactList.add(shipToContact);
        insert contactList;
        
        location = CS_Test_Utilities.createNewLocation(CS_CONSTANTS.LOC_DC_NAME1, CS_CONSTANTS.LOC_CODE_3101, CS_CONSTANTS.LOC_TYPE_DC, CS_CONSTANTS.SALESORG_3100);
        insert location;
        storageLocation = CS_Test_Utilities.createNewLocation(CS_CONSTANTS.LOC_DC_NAME1, CS_CONSTANTS.LOC_CODE_SC01, CS_CONSTANTS.LOC_TYPE_SL, CS_CONSTANTS.SALESORG_3100);
        insert storageLocation;
        
        OperatingHours hours = CS_Test_Utilities.createOperatingHours();
        
        List<ServiceTerritory> serviceTerritoryList = new List<ServiceTerritory>();
        servTerritory1 = CS_Test_Utilities.createnewServiceTerritory('Test ServiceTerritory', CS_CONSTANTS.SALESORG_3100, location.Id, hours.Id, CS_CONSTANTS.STREET_UK, CS_CONSTANTS.CITY_UK, CS_CONSTANTS.COUNTRY_UK, CS_CONSTANTS.POSTALCODE_UK);
        servTerritory2 = CS_Test_Utilities.createnewServiceTerritory('ServiceTerritoryTest', CS_CONSTANTS.SALESORG_3100, location.Id, hours.Id, CS_CONSTANTS.STREET_UK, CS_CONSTANTS.CITY_UK, CS_CONSTANTS.COUNTRY_UK, CS_CONSTANTS.POSTALCODE_UK);
        
        serviceTerritoryList.add(servTerritory1);
        serviceTerritoryList.add(servTerritory2);
        insert serviceTerritoryList;
        system.debug('servTerritory1: ' + servTerritory1.Id);
        system.debug('servTerritory2: ' + servTerritory2.Id);
        
    }
    
    private static testMethod void setDefaultPricebookOnWorkOrderTest(){
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        insert globalConstantDetailList;
        
        User integUser = CS_Test_Utilities.createTestUser('Integration User', 'joppe.koning@kvnconsultancy.com');
        integUser.Sales_Organization__c = CS_CONSTANTS.SALESORG_3100;
        insert integUser;
        
        setupData();
        
        WS_TestHelper.setupIntegrationCalloutParameters();
        
        WorkOrder wo = CS_Test_Utilities.createWorkOrderRecord(woPartsOnlyRecType, SoldTo.Id, ShipTo.Id, soldToContact.Id, shipToContact.Id, emeaPB.Id, 'ZE01');
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_CreditCheckResponseWithMessage());
        system.runAs(integUser){
            insert wo;
        }
        test.stopTest();
    }
    
    private static testMethod void workOrderUpdateIntegratedFieldsTest(){
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        insert globalConstantDetailList;
        
        User integUser = CS_Test_Utilities.createTestUser('Integration User', 'joppe.koning@kvnconsultancy.com');
        integUser.Sales_Organization__c = CS_CONSTANTS.SALESORG_3100;
        insert integUser;
        
        setupData();
        
        WS_TestHelper.setupIntegrationCalloutParameters();
        
        WorkOrder wo = CS_Test_Utilities.createWorkOrderRecord(woPartsOnlyRecType, SoldTo.Id, ShipTo.Id, soldToContact.Id, shipToContact.Id, emeaPB.Id, 'ZE01');
        wo.SAP_External_Id__c = '1420006379';
        wo.Line_Item_Refresh_Date__c = system.today();
        wo.ServiceTerritoryId = servTerritory1.Id;
        wo.PO_Number__c = 'workorder test';
        insert wo;
        List<WorkOrderLineItem> woliList = CS_Test_Utilities.createWOLineItems(wo.Id, 3, emeaPB.Id);
        for(WorkOrderLineItem woli : woliList){
            woli.PricebookEntryId = pbe.Id;
            woli.LocationId = location.Id;
            woli.Quantity = 1;
            woli.Storage_Location__c = storageLocation.Id;
        }
        insert woliList;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_CreditCheckResponseWithMessage());
        
        //system.runAs(integUser){
            WorkOrder wrkorder = [SELECT Id, PO_Number__c, ServiceTerritoryId FROM WorkOrder Limit 1];
            wrkorder.PO_Number__c = 'work order test 123';
            Database.SaveResult sr = Database.update(wrkorder);
            
            WorkOrder updatedWO = [SELECT Id, PO_Number__c, SAP_Sync_Status__c FROM WorkOrder Limit 1];
            
            system.assertEquals('work order test 123', updatedWO.PO_Number__c);
            system.assertEquals('In Progress', updatedWO.SAP_Sync_Status__c);
            
        //}
        
        test.stopTest();
    }
    
    private static testMethod void workOrderUpdateServiceTerritoryTest(){
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        insert globalConstantDetailList;
        
        User integUser = CS_Test_Utilities.createTestUser('Integration User', 'joppe.koning@kvnconsultancy.com');
        integUser.Sales_Organization__c = CS_CONSTANTS.SALESORG_3100;
        insert integUser;
        
        setupData();
        
        WS_TestHelper.setupIntegrationCalloutParameters();
        
        WorkOrder wo = CS_Test_Utilities.createWorkOrderRecord(woPartsOnlyRecType, SoldTo.Id, ShipTo.Id, soldToContact.Id, shipToContact.Id, emeaPB.Id, 'ZE01');
        wo.SAP_External_Id__c = '1420006379';
        wo.Line_Item_Refresh_Date__c = system.today();
        wo.ServiceTerritoryId = servTerritory1.Id;
        wo.PO_Number__c = 'workorder test';
        insert wo;
        List<WorkOrderLineItem> woliList = CS_Test_Utilities.createWOLineItems(wo.Id, 3, emeaPB.Id);
        for(WorkOrderLineItem woli : woliList){
            woli.PricebookEntryId = pbe.Id;
            woli.LocationId = location.Id;
            woli.Quantity = 1;
            woli.Storage_Location__c = storageLocation.Id;
        }
        insert woliList;
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_CreditCheckResponseWithMessage());
            
            WorkOrder wrkorder = [SELECT Id, PO_Number__c, ServiceTerritoryId FROM WorkOrder Limit 1];
            wrkorder.ServiceTerritoryId = servTerritory2.Id;
            Database.SaveResult sr = Database.update(wrkorder);
            
            WorkOrder updatedWO = [SELECT Id, ServiceTerritoryId, SAP_Sync_Status__c FROM WorkOrder Limit 1];
            system.assertEquals(servTerritory2.Id, updatedWO.ServiceTerritoryId);
            system.assertEquals('In Progress', updatedWO.SAP_Sync_Status__c);
            
        test.stopTest();
    }
    
    private static testMethod void setServiceCompletionTimeTest(){
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        insert globalConstantDetailList;
        
        User integUser = CS_Test_Utilities.createTestUser('Integration User', 'joppe.koning@kvnconsultancy.com');
        integUser.Sales_Organization__c = CS_CONSTANTS.SALESORG_3100;
        insert integUser;
        
        setupData();
        
        WS_TestHelper.setupIntegrationCalloutParameters();
        
        WorkOrder wo = CS_Test_Utilities.createWorkOrderRecord(woPartsOnlyRecType, SoldTo.Id, ShipTo.Id, soldToContact.Id, shipToContact.Id, emeaPB.Id, 'ZE01');
        wo.SAP_External_Id__c = '1420006379';
        wo.Line_Item_Refresh_Date__c = system.today();
        wo.ServiceTerritoryId = servTerritory1.Id;
        wo.Order_Placed_Date__c = system.today();
        insert wo;
        List<WorkOrderLineItem> woliList = CS_Test_Utilities.createWOLineItems(wo.Id, 3, emeaPB.Id);
        for(WorkOrderLineItem woli : woliList){
            woli.PricebookEntryId = pbe.Id;
            woli.LocationId = location.Id;
            woli.Quantity = 1;
            woli.Storage_Location__c = storageLocation.Id;
        }
        insert woliList;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_CreditCheckResponseWithMessage());
        system.runAs(integUser){
            wo.Order_Completed_Date__c = system.today().addDays(3);
            update wo;
        }
        test.stopTest();
    }
    
    private static testMethod void shareRecordWithCommunityUsergroupTest(){
        List<FSL_GlobalConstants__c> globalConstantDetailList = CS_Test_Utilities.createFSLGlobalConstantDetailCustomSetting(); 
        insert globalConstantDetailList;
        
        User integUser = CS_Test_Utilities.createTestUser('Integration User', 'joppe.koning@kvnconsultancy.com');
        integUser.Sales_Organization__c = CS_CONSTANTS.SALESORG_3100;
        insert integUser;
        
        setupData();
        
        WS_TestHelper.setupIntegrationCalloutParameters();
        
        WorkOrder wo = CS_Test_Utilities.createWorkOrderRecord(woPartsOnlyRecType, SoldTo.Id, ShipTo.Id, soldToContact.Id, shipToContact.Id, emeaPB.Id, 'ZE01');
        wo.SAP_External_Id__c = '1420006379';
        wo.Line_Item_Refresh_Date__c = system.today();
        wo.ServiceTerritoryId = servTerritory1.Id;
        wo.Order_Placed_Date__c = system.today();
        insert wo;
        List<WorkOrderLineItem> woliList = CS_Test_Utilities.createWOLineItems(wo.Id, 3, emeaPB.Id);
        for(WorkOrderLineItem woli : woliList){
            woli.PricebookEntryId = pbe.Id;
            woli.LocationId = location.Id;
            woli.Quantity = 1;
            woli.Storage_Location__c = storageLocation.Id;
        }
        insert woliList;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new WS_MockHTTPCalloutResponder.WS_CreditCheckResponseWithMessage());
        system.runAs(integUser){
            WorkOrderTriggerHandler.shareRecordWithCommunityUsergroup(new List<WorkOrder>{wo});
        }
        test.stopTest();
    }
}