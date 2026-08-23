enumextension 71100 "OG Test Rule Provider Ext" extends "OG Rule Provider"
{
    value(71100; "OG Test Failure")
    {
        Caption = 'Test Failure';
        Implementation = "OG Rule Provider" = "OG Test Failure Provider";
    }
}
