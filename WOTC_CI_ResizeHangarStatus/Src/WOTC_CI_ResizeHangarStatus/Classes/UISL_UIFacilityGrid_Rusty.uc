//*******************************************************************************************
//  FILE:    UIFacilityGrid_FacilityOverlay
//  
//	File created by RustyDios	05/07/21	01:30	
//	LAST UPDATED				08/07/21	05:00
//
//	Override to fix the background panel for the Hangar to adjust to new 3line format
//	HUGE props to kdm2k6 for help with this!
//	HUGE props to BountyGiver for help with this in UISL form
//
//*******************************************************************************************

class UISL_UIFacilityGrid_Rusty extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local UIFacilityGrid FGrid;
    local UIFacilityGrid_FacilityOverlay FacilityOverlay;

    //make sure we have the right screen type
    FGrid = UIFacilityGrid(Screen);

    if (FGrid != none)
    {    
        //get all facility overlays
        foreach FGrid.FacilityOverlays(FacilityOverlay)
        {
            //narrow to just the Hangar one
            if( FacilityOverlay.GetFacility().GetMyTemplateName() == 'Hangar' )
            {
                //check mode and set default sizes
                if (class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bAvengerIsOneLinePerStat)
                {
                    FacilityOverlay.MC.ChildSetNum("queueLabel.bg", "_width", 275);
                    FacilityOverlay.MC.ChildSetNum("queueLabel.bg", "_height", 140);
                }
                else
                {
                    FacilityOverlay.MC.ChildSetNum("queueLabel.bg", "_width", 275);
                    FacilityOverlay.MC.ChildSetNum("queueLabel.bg", "_height", 60);
                }
            }
        }
    }
}

// This event is triggered after a screen receives focus
event OnReceiveFocus(UIScreen Screen)
{
    local UIFacilityGrid FGrid;
    local UIFacilityGrid_FacilityOverlay FacilityOverlay;

    //make sure we have the right screen type
    FGrid = UIFacilityGrid(Screen);

    if (FGrid != none)
    {    
        //get all facility overlays
        foreach FGrid.FacilityOverlays(FacilityOverlay)
        {
            //narrow to just the Hangar one
            if( FacilityOverlay.GetFacility().GetMyTemplateName() == 'Hangar' )
            {
                //set Panel to adjust to text
                FacilityOverlay.MC.ChildSetBool("queueLabel.label","multiline", true);
                //FacilityOverlay.MC.ChildSetBool("queueLabel.label", "wordWrap", true);
                FacilityOverlay.MC.ChildSetBool("queueLabel.label", "autoSize", true);

                //set BG to match panel text
                FacilityOverlay.MC.ChildSetNum("queueLabel.bg", "_width", FacilityOverlay.MC.GetNum("queueLabel.label.textWidth") +25);
                FacilityOverlay.MC.ChildSetNum("queueLabel.bg", "_height", FacilityOverlay.MC.GetNum("queueLabel.label.textHeight") +10);

                //log for obs
				`LOG("Hangar BG focused: w h:" @FacilityOverlay.MC.GetNum("queueLabel.bg._width") - 25
											   @FacilityOverlay.MC.GetNum("queueLabel.bg._height") - 10
							, class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');
            
				`LOG("Hangar BG textsize: w h:" @FacilityOverlay.MC.GetNum("queueLabel.label.textWidth")
											    @FacilityOverlay.MC.GetNum("queueLabel.label.textHeight")
							, class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');


            }
        }
    }
}

// This event is triggered after a screen loses focus
//event OnLoseFocus(UIScreen Screen);

// This event is triggered when a screen is removed
//event OnRemoved(UIScreen Screen);

/*defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
}*/
