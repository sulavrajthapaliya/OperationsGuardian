page 71001 "ExceptionFactBox_OG_SRT"
{
    ApplicationArea = All;
    Caption = 'Exception Details';
    PageType = CardPart;
    SourceTable = "Exception_OG_SRT";

    layout
    {
        area(Content)
        {
            group(OGDetailsGroup)
            {
                ShowCaption = false;

                field(OGDetails; Rec."Details")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Shows detailed information about the exception.';
                }
                field(OGRecommendation; Rec."Recommendation")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Shows the recommended next action.';
                }
                field(OGResolvedAt; Rec."Resolved At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the exception was resolved.';
                }
            }
        }
    }
}
