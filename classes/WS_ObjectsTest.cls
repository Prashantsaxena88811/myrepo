@isTest
private class WS_ObjectsTest {
    
    private static testMethod void test() {
        
        WS_Objects.ServicePriceRequest servPriceReq = new WS_Objects.ServicePriceRequest();
        servPriceReq.SoldToAccount = 'SoldToAccount';
        servPriceReq.DocType = 'DocType';
        servPriceReq.SalesOrganization = '3100';
        servPriceReq.DistributionChannel = 'DistributionChannel';
        servPriceReq.Division = 'Division';
        //List<String> ListOfMaterialString = new List<String>;
        servPriceReq.ListOfMaterial = new List<String>();
        servPriceReq.convertToJSONFormat();
        
        WS_Objects.ServiceResponseItem servRespItem = new WS_Objects.ServiceResponseItem();
        servRespItem.Material = 'Material';
        servRespItem.NetPrice = 'NetPrice';
        servRespItem.Curr = 'Curr';
        servRespItem.BasePrice = 'BasePrice';
        servRespItem.StandardDiscount = 'StandardDiscount';
        
        WS_Objects.SAPMessage SAPMsg = new WS_Objects.SAPMessage();
        SAPMsg.TYPE = 'TYPEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';       
        SAPMsg.MESSAGEID = 'MESSAGEID';
        SAPMsg.MESSAGENUM = 1;
        SAPMsg.MESSAGE = 'MESSAGE';
        SAPMsg.LOG_NO = 'LOG_NO';
        SAPMsg.LOG_MSG_NO = 'LOG_MSG_NO';
        SAPMsg.MESSAGE_V1 = 'MESSAGE_V1';
        SAPMsg.MESSAGE_V2 = 'MESSAGE_V2';
        SAPMsg.MESSAGE_V3 = 'MESSAGE_V3';
        SAPMsg.MESSAGE_V4 = 'MESSAGE_V4';
        SAPMsg.PARAMETER = 'PARAMETER';
        SAPMsg.ROW = 'ROW';
        SAPMsg.FIELD = 'FIELD';
        
        WS_Objects.ERPMessage ERPMsg = new WS_Objects.ERPMessage();
        ERPMsg.SFDC_RecordId = 'SFDC_RecordId';
        ERPMsg.SFDC_Object = 'SFDC_Object';
        ERPMsg.SFDC_Action = 'SFDC_Action';
        ERPMsg.convertToJSONFormat();
        
        WS_Objects.SAPMessageContainer SAPMsgContainer = new WS_Objects.SAPMessageContainer();
        SAPMsgContainer.item = new list<WS_Objects.SAPMessage>();
        
        WS_Objects.LineItems LineItms = new WS_Objects.LineItems();
        LineItms.SapID = 'SapID';
        LineItms.RecordID = 'RecordID';
        
        WS_Objects.CreditRequest credReq = new WS_Objects.CreditRequest();
        credReq.CustomerNumber = 'CustomerNumber';
        credReq.SalesOrganization = '3100';
        credReq.CurrencyIsoCode = 'GBP';
        credReq.convertToJSONFormat();
        
        WS_Objects.DenialReason denReas = new WS_Objects.DenialReason();
        denReas.Credit_Denial_Reason = new list<String>();
        
        WS_Objects.AllocationRequest allocReq = new WS_Objects.AllocationRequest();
        allocReq.ListOfMaterial = new List<String>();
        allocReq.Plant = 'Plant';
        allocReq.ListofStorageLocation = new List<String>();
        allocReq.SoldToAccount = 'SoldToAccount';
        allocReq.SalesOrganization = '3100';
        allocReq.DistributionChannel = 'DistributionChannel';
        allocReq.Division = 'Division';
        allocReq.convertToJSONFormat();
        
        WS_Objects.RelatedAccountResp relAccResp = new WS_Objects.RelatedAccountResp();
        relAccResp.Status = 'Status';
        relAccResp.ErrorMessage = 'ErrorMessage';
        relAccResp.SAP_External_Id = 'SAP_External_Id';
        
        WS_Objects.RelatedAccountResponse relAccResponse = new WS_Objects.RelatedAccountResponse();
        relAccResponse.MT_inboundlink_res_ib = relAccResp;
        
        WS_Objects.Allocations alloc = new WS_Objects.Allocations();
        alloc.AvailableStock = 'AvailableStock';
        alloc.Material = 'Material';
        alloc.PhysicalStock = 'PhysicalStock';
        alloc.NetPrice = 'NetPrice';
        alloc.Discount = 'Discount';
        alloc.BasePrice = 'BasePrice';
        alloc.ValuationType = 'ValuationType';
        alloc.Curr = 'Curr';
        alloc.Plant = 'Plant';
        alloc.StorageLocation = 'StorageLocation';
        
        WS_Objects.AllocationMessageResponse allocMsgResp = new WS_Objects.AllocationMessageResponse();
        allocMsgResp.item = new list<WS_Objects.SAPMessage>();
        
        WS_Objects.AllocationResponse allocResp = new WS_Objects.AllocationResponse();
        allocResp.Allocations = new List<WS_Objects.Allocations>();
        allocResp.Messages = new List<WS_Objects.SAPMessageContainer>();
        
        /* commented to deploy - NEXTGEN-ACN (this is commented on the class)
        WS_Objects.CreditResponse credResp = new WS_Objects.CreditResponse();
        credResp.SAP_Customer_Number = '1234';
        credResp.Sales_Organization = '3100';
        credResp.Credit_Limit = 100;
        credResp.CurrencyIsoCode = 'GBP';
        credResp.SAP_Comm_Total = 100;
        credResp.Credit_Status = 'Credit_Status';
        credResp.Denial_Reason = new list<WS_Objects.DenialReason>();
        */
        
        WS_Objects.LineItem LineItm = new WS_Objects.LineItem();
        LineItm.item = new list<WS_Objects.LineItems>();
        
        WS_Objects.WorkOrderResponse WorkOrdResp = new WS_Objects.WorkOrderResponse();
        WorkOrdResp.OrderNumber = 'OrderNumber';
        WorkOrdResp.Messages = new list<WS_Objects.SAPMessageContainer>();
        WorkOrdResp.LineItems = LineItm;
        WorkOrdResp.Status = 'Status';
        
        WS_Objects.ServicePriceResponse servPriceResp = new WS_Objects.ServicePriceResponse();
        //list<WS_Objects.ServiceResponseItem> servRespItemList = new list<WS_Objects.ServiceResponseItem>();
        //servPriceResp.Response = servRespItemList;
        servPriceResp.Response = new list<WS_Objects.ServiceResponseItem>();
        servPriceResp.Messages = new list<WS_Objects.SAPMessageContainer>();
        
        
    }

}