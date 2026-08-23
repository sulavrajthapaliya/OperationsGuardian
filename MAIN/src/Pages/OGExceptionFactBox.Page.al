page 71001 "OG Exception FactBox"
{
    PageType = CardPart;
    SourceTable = "OG Exception";
    Caption = 'Exception Details';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(OGDetailsGroup)
            {
                ShowCaption = false;

                field(OGDetails; Rec."OG Details")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Shows detailed information about the exception.';
                }
                field(OGRecommendation; Rec."OG Recommendation")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Shows the recommended next action.';
                }
                field(OGResolvedAt; Rec."OG Resolved At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the exception was resolved.';
                }
            }
        }
    }
}
