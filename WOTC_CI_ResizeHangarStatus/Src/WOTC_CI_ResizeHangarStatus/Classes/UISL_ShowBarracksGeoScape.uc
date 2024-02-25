//*******************************************************************************************
//  FILE:   Show Barracks Status On Geo by RustyDios                           
//  
//	File CREATED	31/08/21    01:00
//	LAST UPDATED    09/02/24	23:00
//
//	ADDS A NEW PANEL TO THE GEOSCAPE THAT DISPLAYS THE BARRACKS STATUS
//  CODED WITH HELP FROM XYMANEK
//
//*******************************************************************************************
class UISL_ShowBarracksGeoScape extends UIScreenListener config(Game) dependson (X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus) ;

var config int PANEL_ANCHOR_Y_GEO;
var config int PANEL_ANCHOR_X_GEO_CB, PANEL_WIDTH_GEO_CB, PANEL_HEIGHT_GEO_CB; 
var config int PANEL_ANCHOR_X_GEO_ST, PANEL_WIDTH_GEO_ST, PANEL_HEIGHT_GEO_ST;
var config int PANEL_ANCHOR_X_GEO_FL, PANEL_WIDTH_GEO_FL, PANEL_HEIGHT_GEO_FL;

//var config bool bEnableOnGeoscape, bGeoIsSingleLinePerStat, bGeoIsFlatLine;

///////////////////////////////////////////////////////////////////////////////
//  SCREEN MANIPULATION
///////////////////////////////////////////////////////////////////////////////

//  Check we have the right screen on init
event OnInit(UIScreen Screen)
{
	local UIGeoscapeBarracksDisplay GBD;

	if (Screen.IsA(class'UIStrategyMap'.Name))
	{
		if (class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableOnGeoscape)
		{
			GBD = Screen.Spawn(class'UIGeoscapeBarracksDisplay', Screen);
			`LOG("Screen was one we wanted on init  ::" @Screen.Class.Name , class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging,'RustyShowBarracksGeo');

			//check mode and set default sizes ... init display. xpos, ypos, width, height, singleline, flatline
			if (class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bGeoscapeIsFlatLine)
			{
				`LOG("SETUP PANEL FOR FLATLINE" , class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging,'RustyShowBarracksGeo');
				GBD.InitBarracksDisplay(default.PANEL_ANCHOR_Y_GEO, default.PANEL_ANCHOR_X_GEO_FL, default.PANEL_WIDTH_GEO_FL, default.PANEL_HEIGHT_GEO_FL);
			}
			else if (class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bGeoscapeIsOneLinePerStat)
			{
				`LOG("SETUP PANEL FOR STACK" , class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging,'RustyShowBarracksGeo');
				GBD.InitBarracksDisplay(default.PANEL_ANCHOR_Y_GEO, default.PANEL_ANCHOR_X_GEO_ST, default.PANEL_WIDTH_GEO_ST, default.PANEL_HEIGHT_GEO_ST);
			}
			else
			{
				`LOG("SETUP PANEL FOR COMPACT" , class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging,'RustyShowBarracksGeo');
				GBD.InitBarracksDisplay(default.PANEL_ANCHOR_Y_GEO, default.PANEL_ANCHOR_X_GEO_CB, default.PANEL_WIDTH_GEO_CB, default.PANEL_HEIGHT_GEO_CB);
			}

			//GBD.UpdateGeoBarracksText(); called from the Init, stop putting it back in here!!
			HandleInput(true);
		}
		else
		{
			`LOG("Screen was one we wanted on init :: " @Screen.Class.Name @" :: but display was disabled in config options", class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging,'RustyShowBarracksGeo');
		}
	}
}

// update the panel on lose focus
event OnLoseFocus(UIScreen Screen)
{
	local UIGeoscapeBarracksDisplay GBD;

	if (Screen.IsA(class'UIStrategyMap'.Name))
	{
		if (class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableOnGeoscape)
		{
			GBD = UIGeoscapeBarracksDisplay(Screen.GetChildByName(class'UIGeoscapeBarracksDisplay'.const.PanelName, false));

			if (GBD != none)
			{
				//geoscape not in focus hide the screen, fast
				GBD.Hide();
			}
		
			HandleInput(false);
		}
	}
}

// update the panel on recieve focus
event OnReceiveFocus(UIScreen Screen)
{
	local UIGeoscapeBarracksDisplay GBD;

	if (Screen.IsA(class'UIStrategyMap'.Name))
	{
		if (class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableOnGeoscape)
		{
			GBD = UIGeoscapeBarracksDisplay(Screen.GetChildByName(class'UIGeoscapeBarracksDisplay'.const.PanelName, false));

			if (GBD != none)
			{
				//geoscape in focus, update the text first, then bring it back fast
				GBD.UpdateGeoBarracksText();
				GBD.Show();
			}
		
			HandleInput(true);
		}
	}
}

// This event is triggered when a screen is removed
event OnRemoved(UIScreen screen)
{
	if (UIStrategyMap(Screen) == none) return;
	
	HandleInput(false);
}

//SEETUP CONTROLLER SUPPORT FOR GEOSCAPE
function HandleInput(bool isSubscribing)
{
	local delegate<UIScreenStack.CHOnInputDelegate> inputDelegate;
	inputDelegate = OnUnrealCommand;

	if(isSubscribing)
	{
		`SCREENSTACK.SubscribeToOnInput(inputDelegate);
	}
	else
	{
		`SCREENSTACK.UnsubscribeFromOnInput(inputDelegate);
	}
}

static protected function bool OnUnrealCommand(int cmd, int arg)
{
	// Only pay attention to presses or repeats; ignoring other input types
	if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_R3 && arg == class'UIUtilities_Input'.const.FXS_ACTION_HOLD)
	{
		// Cannot open screen during flight
		if (`HQPRES.StrategyMap2D.m_eUIState != eSMS_Flight)
		{
			`HQPRES.UIPersonnel_LivingQuarters(OnPersonnelSelected);
		}

		return true;
	}

	return `SCREENSTACK.GetCurrentScreen().OnUnrealCommand(cmd, arg);
}

simulated function OnPersonnelSelected(StateObjectReference selectedUnitRef)
{
	//TODO: add any logic here for selecting someone from the geoscape .. default nothing
	`SCREENSTACK.GetCurrentScreen().Movie.Pres.PlayUISound(eSUISound_MenuClickNegative);
}

//////////////////////////////////////////////////////////
defaultproperties
{	
	ScreenClass = none
}
