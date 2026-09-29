enumextension 71100 "OG Test Rule Provider Ext" extends "RuleProvider_OG_SRT"
{
    value(71100; "OG Test Failure")
    {
        Caption = 'Test Failure';
        Implementation = "RuleProvider_OG_SRT" = "OG Test Failure Provider";
    }
}
