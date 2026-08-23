enum 71003 "OG Rule Provider" implements "OG Rule Provider"
{
    Extensible = true;
    DefaultImplementation = "OG Rule Provider" = "OG Null Rule Provider";
    UnknownValueImplementation = "OG Rule Provider" = "OG Null Rule Provider";

    value(0; "OG None")
    {
        Caption = 'None';
        Implementation = "OG Rule Provider" = "OG Null Rule Provider";
    }
    value(1; "OG Sales")
    {
        Caption = 'Sales';
        Implementation = "OG Rule Provider" = "OG Sales Rules";
    }
    value(2; "OG Purchasing")
    {
        Caption = 'Purchasing';
        Implementation = "OG Rule Provider" = "OG Purchase Rules";
    }
    value(3; "OG Inventory")
    {
        Caption = 'Inventory';
        Implementation = "OG Rule Provider" = "OG Inventory Rules";
    }
    value(4; "OG Warehouse")
    {
        Caption = 'Warehouse';
        Implementation = "OG Rule Provider" = "OG Warehouse Rules";
    }
    value(5; "OG Manufacturing")
    {
        Caption = 'Manufacturing';
        Implementation = "OG Rule Provider" = "OG Manufacturing Rules";
    }
    value(6; "OG System")
    {
        Caption = 'System';
        Implementation = "OG Rule Provider" = "OG System Rules";
    }
    value(7; "OG Approvals")
    {
        Caption = 'Approvals';
        Implementation = "OG Rule Provider" = "OG Approval Rules";
    }
}
