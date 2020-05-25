public with sharing class WS_TestHelper {

    public static WS_IntegrationSettings__c getCalloutParameter(String parameterName){
        WS_IntegrationSettings__c setting = [SELECT Id, Endpoint__c, Enabled__c, Name FROM WS_IntegrationSettings__c WHERE Name = :parameterName];

        return setting;
    }


    public static void setupIntegrationCalloutParameters(){

        WS_IntegrationSettings__c calloutCreditURL = new WS_IntegrationSettings__c();
        calloutCreditURL.Name = 'WS_CreditCheckIntegration';
        calloutCreditURL.Endpoint__c = 'creditCallout';
        calloutCreditURL.Enabled__c = true;
        //insert calloutCreditURL;

        WS_IntegrationSettings__c calloutWorkOrderURL = new WS_IntegrationSettings__c();
        calloutWorkOrderURL.Name = 'WS_WorkOrderIntegration';
        calloutWorkOrderURL.Endpoint__c = 'workOrderCallout';
        calloutWorkOrderURL.Enabled__c = true;
        //insert calloutWorkOrderURL;


        WS_IntegrationSettings__c calloutAccountURL = new WS_IntegrationSettings__c();
        calloutAccountURL.Name = 'WS_AccountIntegration';
        calloutAccountURL.Endpoint__c = 'accountCallout';
        calloutAccountURL.Enabled__c = true;

        WS_IntegrationSettings__c allocationReportURL = new WS_IntegrationSettings__c();
        allocationReportURL.Name = 'WS_AllocationReportIntegration';
        allocationReportURL.Endpoint__c = 'allocationCallout';
        allocationReportURL.Enabled__c = true;

        WS_IntegrationSettings__c servicePricesURL = new WS_IntegrationSettings__c();
        servicePricesURL.Name = 'WS_ServicePriceIntegration';
        servicePricesURL.Endpoint__c = 'serviceCallout';
        servicePricesURL.Enabled__c = true;

        WS_IntegrationSettings__c integrationUser = new WS_IntegrationSettings__c();
        integrationUser.Name = 'IntegrationUser';
        integrationUser.Value__c = 'joppe.koning@kvnconsultancy.com';
        //insert integrationUser;

        WS_IntegrationSettings__c enabledSalesOrgs = new WS_IntegrationSettings__c();
        enabledSalesOrgs.Name = 'WS_EnabledSalesOrganizations';
        enabledSalesOrgs.Value__c = '3100';

        List<WS_IntegrationSettings__c> intSettingsList = new List<WS_IntegrationSettings__c>();
        intSettingsList.add(calloutCreditURL);
        intSettingsList.add(calloutWorkOrderURL);
        intSettingsList.add(calloutAccountURL);
        intSettingsList.add(allocationReportURL);
        intSettingsList.add(servicePricesURL);
        intSettingsList.add(integrationUser);
        intSettingsList.add(enabledSalesOrgs);
        Database.insert(intSettingsList);

        WS_IntegratedFields__c integratedWOFields = new WS_IntegratedFields__c();
        integratedWOFields.Name = 'WorkOrder';
        integratedWOFields.Field_List__c = 'PO_Number__c';
        integratedWOFields.Picklist_Fields__c = 'SAP_Order_Type__c,Billing_Block__c';

        WS_IntegratedFields__c integratedWOLIFields = new WS_IntegratedFields__c();
        integratedWOLIFields.Name = 'WorkOrderLineItem';
        integratedWOLIFields.Field_List__c = 'Quantity,ERP_Price__c';
        //integratedWOLIFields.Picklist_Fields__c = 'SAP_Order_Type__c,Billing_Block__c';


        WS_IntegratedFields__c integratedAccountFields = new WS_IntegratedFields__c();
        integratedAccountFields.Name = 'Account';
        integratedAccountFields.Field_List__c = 'Name,Sales_Organization__c,Division__c';
        integratedAccountFields.Picklist_Fields__c = 'Sales_Organization__c,Division__c,Distribution_Channel__c';


        List<WS_IntegratedFields__c> integratedFieldsList = new List<WS_IntegratedFields__c>();
        integratedFieldsList.add(integratedWOFields);
        integratedFieldsList.add(integratedAccountFields);
        integratedFieldsList.add(integratedWOLIFields);
        Database.insert(integratedFieldsList);

    }


    public static Acc_Junction__c createRelatedAccount(Id soldToId, Id shipToId, Id pricebookId){
        Acc_Junction__c accJunct = new Acc_Junction__c();
        accJunct.Sold_To__c = soldToId;
        accJunct.Ship_To__c = shipToId;
        accJunct.Pricebook__c = pricebookId;

        return accJunct;

    }

    public static Account insertSoldToAccount(){
        Account acc = CS_Test_Utilities.createNewAccount('MITESHTEST', 'NextGen_Sold_To', 'GBP');
        acc.CurrencyIsoCode = 'GBP';       
        acc.Sales_Organization__c = '3100';
        acc.Distribution_Channel__c = '11 - Domestic';
        acc.Division__c = '00 - Cross Division';
        acc.SAP_External_Id__c = '110011';
        acc.Warehouse__c = '2100';
        acc.ShippingCity = 'Wolverhampton';
        acc.ShippingCountry = 'United Kingdom';
        acc.ShippingPostalCode = 'SW19 2UP';
        System.debug('insertSoldToAccount val'+acc);
         System.debug('recordtype val'+acc.RecordType.Name);
        return acc;
    }
    public static Pricebook2 createPricebook(){
    String str=FSL_TestDataUtility.createGlobalConstantSettings('DEFAULT_CAMSO_PRICEBOOK', 'Default Camso Pricebook');
        //Pricebook2 camsoPricebook = CS_Test_Utilities.NewPricebook(GlobalConstants.DEFAULT_CAMSO_PRICEBOOK);
        Pricebook2 camsoPricebook = CS_Test_Utilities.NewPricebook(str);
        camsoPricebook.IsActive = true;
        return camsoPricebook;
    }

    public static Pricebook2 createEMEAPricebook(){
         /* July 27 - Replaced Global Constant varibles with Custom Settings */
        //Pricebook2 camsoPricebook = CS_Test_Utilities.NewPricebook(GlobalConstants.EMEA_DEFAULT_PRICEBOOK);
        // commented for deployment
        Pricebook2 camsoPricebook = CS_Test_Utilities.NewPricebook(FSL_GlobalConstants__c.getInstance('EMEA_DEFAULT_PRICEBOOK').Value__c);
        camsoPricebook.IsActive = true;
        return camsoPricebook;
    }

    public static List<PricebookEntry> addProductsToPricebook(Pricebook2 pBook, List<Product2> prodList){
        List<PricebookEntry> pbEntry = new List<PricebookEntry>();

        for (Product2 prod : prodList){
            PricebookEntry pe = new PricebookEntry();
            pe.UnitPrice = 10;
            pe.IsActive = true;
            pe.Product2Id = prod.Id;
            pe.Product2 = prod;
            pe.Pricebook2Id = pBook.Id;
            pe.Pricebook2 = pBook;
            pbEntry.add(pe);
        }

        return pbEntry;
    }

    public static Account insertShipToAccount(Id soldToId){
        Account acc = CS_Test_Utilities.createNewAccount('MITESHTEST', 'NextGen_Ship_To', 'GBP');
        acc.CurrencyIsoCode = 'GBP';            
        //acc.Sales_Organization__c = 'Domestic';
        acc.Distribution_Channel__c = '11 - Domestic';
        acc.Division__c = '00 - Cross Division';
        acc.SAP_External_Id__c = '210111';
        acc.Warehouse__c = '2100';
        acc.EMEA_Sold_To__c = soldToId;
        acc.ShippingCity = 'Wolverhamptoasan';
        acc.ShippingCountry = 'United Kingdom';
        acc.ShippingPostalCode = 'SW19 2UP';
        return acc;
    }

    public static WorkOrder createWorkOrder(Account soldTo, Account shipTo, Pricebook2 pb){
        //Create Sold To Contact  
        Contact contSoldTo = FSL_TestDataUtility.newContact('Sold To',soldTo.Id,1,true)[0];
        //Create Ship To Contact 
        Contact contShipTo = FSL_TestDataUtility.newContact('Ship To',shipTo.Id,1,true)[0];
        // create location
        ServiceTerritory location = FSL_TestDataUtility.createServiceTerritory();
        // Create work Type
        WorkType serviceType = FSL_TestDataUtility.createServiceTypeItem('Onsite Mounting Resilient x2',true);
        WorkOrder wo = FSL_TestDataUtility.createWorkOrder('Draft', soldTo.id,shipTo.id,contSoldTo.id,contShipTo.id,pb.Id,2,'Regular',false,location.id, serviceType.id)[0];
        
        return wo;
    }
    
    /*public static list<Quote> createQuote(String quoteName, Account soldTo, integer count, boolean insertRecord){
        //Create Sold To Contact  
        Contact contSoldTo = FSL_TestDataUtility.newContact('Sold To',soldTo.Id,1,true)[0];
        List<Quote> lstQuotes = new List<Quote>();
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.Account = soldTo;
        opp.Type = 'New Business';
        opp.StageName = 'Proposal/Price Quote';
        opp.NextStep = 'testNext Step';
        opp.CloseDate = date.parse(date.today().format());
        opp.RecordType.Name = 'Sales_Service_Opportunity';

        insert opp;
        
        for(integer size = 0 ; size < count ; size ++){
            lstQuotes.add(new Quote(Name = quoteName, Opportunity = opp, Sold_To_Account__c = soldTo.Id, ContactId = contSoldTo.Id, SAP_Order_Type__c = 'ZE01'));
        }
         if(insertRecord){
                 insert lstQuotes;
        }
        return lstQuotes;
    }*/
    
    public static List<WorkOrderLineItem> createWOLinesItems(WorkOrder wo, List<PricebookEntry> pricebookEntryList){
        
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        List<Schema.Location> locList = new List<Schema.Location>();
        Schema.Location location = CS_Test_Utilities.createNewLocation(CS_CONSTANTS.LOC_DC_NAME1, CS_CONSTANTS.LOC_CODE_3101, CS_CONSTANTS.LOC_TYPE_DC, CS_CONSTANTS.SALESORG_3100);
        Schema.Location storageLocation = CS_Test_Utilities.createNewLocation(CS_CONSTANTS.LOC_DC_NAME1, CS_CONSTANTS.LOC_CODE_SC01, CS_CONSTANTS.LOC_TYPE_SL, CS_CONSTANTS.SALESORG_3100);
        locList.add(location);
        locList.add(storageLocation);
        insert locList;
        for (PricebookEntry pbe : pricebookEntryList){
            WorkOrderLineItem woli = new WorkOrderLineItem();
            woli.WorkOrderId = wo.Id;
            woli.PricebookEntryId = pbe.Id;
            woli.PricebookEntry = pbe;
            woli.Quantity = 2;
            woli.UnitPrice = 100;
            woli.LocationId = location.Id;
            woli.Storage_Location__c = storageLocation.Id;
            woliList.add(woli);
        }

        return woliList;
    }

    public static List<ServiceTerritory> insertLocations(){
        OperatingHours oh = FSL_TestDataUtility.createOperatingHours();
        /**
         * need to create standard location object to assign to warehouse field on service territory object.
        **/
        // commented for deployment
        ServiceTerritory location1 = new ServiceTerritory(Name = '3100 - UK HO +SC Cowbridge',Sales_Organization__c='3100', /*Warehouse__c = '3100 - UK HO +SC Cowbridge',*//* commented for deployment*/ OperatingHoursId = oh.id, IsActive= true);
        // commented for deployment
        ServiceTerritory location2 = new ServiceTerritory(Name = '3104 - UK SC Leeds',Sales_Organization__c='3100', /*Warehouse__c = '3104 - UK SC Leeds',*//* commented for deployment*/ OperatingHoursId =  oh.id, IsActive = true);

        // commented for deployment
        List<ServiceTerritory> locationList = new List<ServiceTerritory>();
        locationList.add(location1);
        locationList.add(location2);

        Database.insert(locationList);

        return locationList;
    }



    public static List<Product2> insertProducts(){
        List<Product2> prodList = CS_Test_Utilities.setupProducts();

        Integer count = 1;

        for (Product2 prod : prodList){
            prod.SAP_External_Id__c = String.valueOf(count);
            count++;
            prod.CurrencyIsoCode = 'GBP';
        }

        return prodList;
    }

    public static List<Product2> insertServiceProducts(){
        List<Product2> prodList = CS_Test_Utilities.setupProducts();

        Integer count = 11;

        for (Product2 prod : prodList){
            prod.SAP_External_Id__c = String.valueOf(count);
            prod.Is_Service__c = true;
            count++;
        }

        return prodList;
    }
    
}