//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTC_CI_ResizeHangarStatus.uc     by RustyDios                                
//           
//	File created	06/07/21	01:30	
//	LAST UPDATED	09/02/22	03:30
// 
//	Patch CI Hangar Display over 3 lines
//	Old issue: BG Panel does not resize to list height -- FIXED with help from kdm2k6
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus extends X2DownloadableContentInfo;

//new struct to not override CI Hangar based one
struct BarracksStatusReport_Rusty
{
	var int Ready;
	var int Tired;
	var int Wounded;
	var int Infiltrating;
	var int OnCovertAction;
	var int Captured;
	var int Unavailable;
	var int InHaven;
	var int Total;
};

// new strings for display for Hangar display based on CI one
var localized string strSoldiers, strReady, strTired, strWounded, strInfiltrating, strOnCovertAction, strUnavailable, strCaptured, strInHaven;
var config string    HexSoldiers, HexReady, HexTired, HexWounded, HexInfiltrating, HexOnCovertAction, HexUnavailable, HexCaptured, HexInHaven;

var config bool bEnableLogging, bAvengerIsOneLinePerStat, bEnableOnAvenger;

static event OnLoadedSavedGame(){}

static event InstallNewCampaign(XComGameState StartState){}

//////////////////////////////////////////////////////////////////////////////////////////
// OPTC		COVERT INFILTRATION TWEAKS:		RESTRUCT HANGAR STATUS DISPLAY
//////////////////////////////////////////////////////////////////////////////////////////

static event OnPostTemplatesCreated()
{
	PatchHangar_Rusty();
	`LOG("Patched Hangar Status Display",default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');
}

	/////////////////////////////////////////////////////////////////

static function PatchHangar_Rusty()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate HangarTemplate;

	if (default.bEnableOnAvenger)
	{
		TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		HangarTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('Hangar'));

		HangarTemplate.GetQueueMessageFn = GetPatchedHangarQueueMessage_Rusty;
	}
}

	/////////////////////////////////////////////////////////////////

static function string GetPatchedHangarQueueMessage_Rusty(StateObjectReference FacilityRef)
{
	local BarracksStatusReport_Rusty CurrentBarracksStatus;
	local string strStatus;

	//get report of all xcom HQ soldiers current activities
	CurrentBarracksStatus = GetBarracksStatusReport_Rusty();

	strStatus = "";

	//check mode and formulate correct string response
	if (default.bAvengerIsOneLinePerStat)
	{
		//single line stacked, each line -- # : text
		strStatus = default.strSoldiers $ ":";
		strStatus $= "\n" $ 	ColourText(CurrentBarracksStatus.Ready @ ":" @ default.strReady , default.HexReady);
		strStatus $= "\n" $ 	ColourText(CurrentBarracksStatus.Tired @ ":" @ default.strTired, default.HexTired);
		strStatus $= "\n" $ 	ColourText(CurrentBarracksStatus.Wounded @ ":" @ default.strWounded, default.HexWounded);
			//insert DLC check for CI or LWotC ?
		strStatus $= "\n" $ 	ColourText(CurrentBarracksStatus.Infiltrating @ ":" @ default.strInfiltrating, default.HexInfiltrating);
			//end DLC check
		strStatus $= "\n" $ 	ColourText(CurrentBarracksStatus.OnCovertAction @ ":" @ default.strOnCovertAction, default.HexOnCovertAction);
		strStatus $= "\n" $ 	ColourText(CurrentBarracksStatus.Unavailable @ ":" @ default.strUnavailable, default.HexUnavailable);

		//only show if you have advisors in havens!
		if (CurrentBarracksStatus.InHaven > 0)
		{
			strStatus $= "\n" $ ColourText(CurrentBarracksStatus.InHaven @ ":" @ default.strInHaven, default.HexInHaven);
		}

		//only show captured if you have captured!
		if (CurrentBarracksStatus.Captured > 0)
		{
			strStatus $= "\n" $ ColourText(CurrentBarracksStatus.Captured @ ":" @ default.strCaptured, default.HexCaptured);
		}

		`LOG("Hangar Status Display Single Stack Active",default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');
	}
	else
	{
		//Compact Block layout
		//	Soldiers: Unavailable XX
		//	[Haven Advisors xx , ] (Captured xx) 
		//	Infiltrating xx, On Covert Actions xx
		//	Ready xx, Tired xx, Wounded xx

		strStatus = default.strSoldiers $ ": ";
		strStatus $= ColourText(default.strUnavailable $ ":" @ CurrentBarracksStatus.Unavailable, default.HexUnavailable);

		//only show if you have advisors in havens or captured!
		if (CurrentBarracksStatus.InHaven > 0 || CurrentBarracksStatus.Captured > 0)
		{
			strStatus $= "\n";
		}

		////only show if you have advisors in havens!
		if (CurrentBarracksStatus.InHaven > 0)
		{
			strStatus $= ColourText(default.strInHaven $ ":" @ CurrentBarracksStatus.InHaven, default.HexInHaven) $" , ";
		}

		//only show captured if you have captured!
		if (CurrentBarracksStatus.Captured > 0)
		{
			strStatus $= ColourText(default.strCaptured $ ":" @ CurrentBarracksStatus.Captured, default.HexCaptured);
		}

			//Insert if DLC for CI or LWotC ?
		strStatus $= "\n" $  ColourText(default.strInfiltrating $ ":" @ CurrentBarracksStatus.Infiltrating, default.HexInfiltrating);
			//end DLC Check
		strStatus $= " , " $ ColourText(default.strOnCovertAction $ ":" @ CurrentBarracksStatus.OnCovertAction, default.HexOnCovertAction);

		strStatus $= "\n" $  ColourText(default.strReady $ ":" @ CurrentBarracksStatus.Ready, default.HexReady);
		strStatus $= " , " $ ColourText(default.strTired $ ":" @ CurrentBarracksStatus.Tired, default.HexTired);
		strStatus $= " , " $ ColourText(default.strWounded $ ":" @ CurrentBarracksStatus.Wounded, default.HexWounded);

		`LOG("Hangar Status Display Multi Line Active",default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');
	}

	//log numbers for obs
	`LOG("Barrack Numbers :: " 
			@ "\n U/A:			" @CurrentBarracksStatus.Unavailable
			@ "\n Infiltrating:	" @CurrentBarracksStatus.Infiltrating 
			@ "\n On Covert:	" @CurrentBarracksStatus.OnCovertAction 
			@ "\n Ready:		" @CurrentBarracksStatus.Ready 
			@ "\n Tired:		" @CurrentBarracksStatus.Tired 
			@ "\n Wounded:		" @CurrentBarracksStatus.Wounded 
			@ "\n Captured:		" @CurrentBarracksStatus.Captured
			@ "\n In Havens:	" @CurrentBarracksStatus.InHaven
			@ "\n Total:		" @CurrentBarracksStatus.Total
			, default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');

	return strStatus;
}

	/////////////////////////////////////////////////////////////////

static function BarracksStatusReport_Rusty GetBarracksStatusReport_Rusty()
{
	local BarracksStatusReport_Rusty CurrentBarracksStatus;
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Unit Soldier;
	
	//get all ALIVE xcom soldiers
	Soldiers = `XCOMHQ.GetSoldiers();

	//make a note of what they are currently doing
	foreach Soldiers(Soldier)
	{
		CurrentBarracksStatus.Total++;

		if (Soldier.bCaptured)
		{
			CurrentBarracksStatus.Captured++;
		}
		else if (Soldier.GetStaffSlot() != none && Soldier.GetStaffSlot().GetMyTemplateName() == 'RM_CellStaffSlot' )
		{
			//due to how Lightweight Strategy Overhaul is just looking for a slot template name this check doesn't need to be gated behind a DLC check
			CurrentBarracksStatus.InHaven++;
		}
		/*
		else if (IsModActive('LWOTC') && `LWOUTPOSTMGR.IsUnitAHavenLiaison(Soldier.GetReference()))
			{
				CurrentBarracksStatus.InHaven++;
			} 
		else if (IsModActive('LWOTC') && `LWSQUADMGR.UnitIsOnMission(Soldier.GetReference()))
			{
				CurrentBarracksStatus.Infiltrating++;
			} 
		*/
		else if (Soldier.GetStaffSlot() != none && Soldier.GetStaffSlot().GetMyTemplateName() == 'InfiltrationStaffSlot' )
		{
			//due to how CI is just looking for a slot template name this check doesn't need to be gated behind a DLC check
			CurrentBarracksStatus.Infiltrating++;
		}
		else if (Soldier.IsOnCovertAction())
		{
			CurrentBarracksStatus.OnCovertAction++;
		}
		else if (Soldier.IsInjured())
		{
			CurrentBarracksStatus.Wounded++;
		}
		else if (Soldier.CanGoOnMission())
		{
			if (Soldier.GetMentalState() == eMentalState_Tired)
			{
				CurrentBarracksStatus.Tired++;
			}
			else
			{
				CurrentBarracksStatus.Ready++;
			}
		}
		else
		{
			//so this counts gts training, psi training, bond training, pexm testing, soldier conditioning etc etc
			//basically anyone that can't go on a mission and doesn't fit the above criteria
			CurrentBarracksStatus.Unavailable++;
		}
	}

	return CurrentBarracksStatus;
}

	/////////////////////////////////////////////////////////////////

static function string ColourText(string strValue, string strColour)
{
	//colour a html string by hex value input
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}

	/////////////////////////////////////////////////////////////////
/*

//the barracks display function gets called a BUNCH of times, not sure having a DLC check in it is a GOOD thing
//as intention is purely for CI so far and I don't mind the "OnInfil" line even in non CI, I can't warrant this include yet
//even more so as CI's infil slot count won't crash a non-CI game , unlike the LWotC implementation which I don't care about tbh... 
static function bool IsModActive(name DLCName)
{
    local XComOnlineEventMgr    EventManager;
    local int                   Index;

    EventManager = `ONLINEEVENTMGR;

    for(Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--)  
    {
        if(EventManager.GetDLCNames(Index) == DLCName)  
        {
            return true;
        }
    }
    return false;
}
*/
	/////////////////////////////////////////////////////////////////
