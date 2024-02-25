//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTC_CI_ResizeHangarStatus.uc     by RustyDios                                
//           
//	File created	06/07/21	01:30	LAST UPDATED	25/02/24	17:45
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
	var int Busy;
	var int Total;
};

// new strings for display for Hangar display based on CI one
var localized string strSoldiers, strReady, strTired, strWounded, strInfiltrating, strOnCovertAction, strUnavailable, strCaptured, strInHaven;
var config string    HexSoldiers, HexReady, HexTired, HexWounded, HexInfiltrating, HexOnCovertAction, HexUnavailable, HexCaptured, HexInHaven;

var localized string strBusy;
var config string    HexBusy;

var config bool bEnableLogging, bEnableXWynnesStatGroups;
var config bool bEnableOnAvenger, bAvengerIsFlatLine, bAvengerIsOneLinePerStat;
var config bool bEnableOnGeoscape, bGeoscapeIsFlatLine, bGeoscapeIsOneLinePerStat;

var config array<string> FormatOrderF, FormatOrderS;
var config array<string> FormatOrderA1, FormatOrderA2, FormatOrderA3, FormatOrderA4;
var config array<string> FormatOrderG1, FormatOrderG2, FormatOrderG3;

var config array<name> StaffSlotNames_Haven, StaffSlotNames_Infil;
var config int ReadyThreshold;

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

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

static function string AddPartsInOrder(array<string> FormatOrder, array<string> LocalOrder, string Separator, optional bool bAlwaysAddSeparator)
{
	local string strStatus, locOrder;
	local int i;

	strStatus = "";

	for (i = 0 ; i < FormatOrder.length ; i++)
	{
		foreach LocalOrder(locOrder)
		{
			if (InStr(locOrder, FormatOrder[i]) != INDEX_NONE)
			{
				strStatus $= locOrder;

				if (i < FormatOrder.length -1 || bAlwaysAddSeparator)
				{
					strStatus $= Separator;
				}
				continue;
			}
		}
	}

	return strStatus;
}

static function string GetPatchedHangarQueueMessage_Rusty(StateObjectReference FacilityRef)
{
	local BarracksStatusReport_Rusty CurrentBarracksStatus;
	local string strStatus, MultiLine1, MultiLine2, MultiLine3, MultiLine4;
	local array<string> LocalOrder;

	//get report of all xcom HQ soldiers current activities
	CurrentBarracksStatus = GetBarracksStatusReport_Rusty();

	//set up strings
	strStatus = "";

 	/* Ready */ 	LocalOrder.AddItem(ColourText(default.strReady, CurrentBarracksStatus.Ready, default.HexReady));
	/* Tired */ 	LocalOrder.AddItem(ColourText(default.strTired, CurrentBarracksStatus.Tired, default.HexTired));
	/* Wounded */	LocalOrder.AddItem(ColourText(default.strWounded, CurrentBarracksStatus.Wounded, default.HexWounded));
	/* Infil */ 	LocalOrder.AddItem(ColourText(default.strInfiltrating, CurrentBarracksStatus.Infiltrating, default.HexInfiltrating));
	/* OnCA */		LocalOrder.AddItem(ColourText(default.strOnCovertAction, CurrentBarracksStatus.OnCovertAction, default.HexOnCovertAction));
	/* UA */ 		LocalOrder.AddItem(ColourText(default.strUnavailable, CurrentBarracksStatus.Unavailable, default.HexUnavailable));
	/* Busy */		LocalOrder.AddItem(ColourText(default.strBusy, CurrentBarracksStatus.Busy, default.HexBusy));
	
	//only show if you have advisors in havens or captured units
	/* Haven */		if (CurrentBarracksStatus.InHaven > 0)
					{
						LocalOrder.AddItem(ColourText(default.strInHaven, CurrentBarracksStatus.InHaven, default.HexInHaven));
					}

	/* Captured */	if (CurrentBarracksStatus.Captured > 0)
					{
						LocalOrder.AddItem(ColourText(default.strCaptured, CurrentBarracksStatus.Captured, default.HexCaptured));
					}

	//check mode and formulate correct string response
	if (default.bAvengerIsFlatLine)
	{
		//all one line -- text: # , text: # , text: # , text: # , text: # , text: # , text: # , text: #
		strStatus = default.strSoldiers $ ":";
		strStatus $= AddPartsInOrder(default.FormatOrderF, LocalOrder, " , " );

		`LOG("Hangar Status Display Flat Line Active",default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');
	}
	if (default.bAvengerIsOneLinePerStat)
	{
		//single line stacked, each line -- # : text
		strStatus = default.strSoldiers $ ":\n";
		strStatus $= AddPartsInOrder(default.FormatOrderS, LocalOrder, "\n" );

		`LOG("Hangar Status Display Single Stack Active",default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');
	}
	else
	{
		//Compact Block layout
		//	Soldiers: Unavailable XX
		//	[Haven Advisors xx , ] (Captured xx) 
		//	Infiltrating xx, On Covert Actions xx
		//	Ready xx, Tired xx, Wounded xx

		MultiLine1 = AddPartsInOrder(default.FormatOrderA1, LocalOrder, " , ", true );
		MultiLine2 = AddPartsInOrder(default.FormatOrderA2, LocalOrder, " , ", true );
		MultiLine3 = AddPartsInOrder(default.FormatOrderA3, LocalOrder, " , ", true ); 
		MultiLine4 = AddPartsInOrder(default.FormatOrderA4, LocalOrder, " , "); 

		strStatus = default.strSoldiers $ ":" @ MultiLine1 $"\n";
		strStatus $= MultiLine2; if (MultiLine2 != "") { strStatus $= "\n"; }
		strStatus $= MultiLine3; if (MultiLine3 != "") { strStatus $= "\n"; }
		strStatus $= MultiLine4; 

		`LOG("Hangar Status Display Multi Line Active",default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');
	}

	return strStatus;
}

	/////////////////////////////////////////////////////////////////

static function BarracksStatusReport_Rusty GetBarracksStatusReport_Rusty()
{
	local BarracksStatusReport_Rusty CurrentBarracksStatus;
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Unit Soldier;
	local name StaffSlotTemplateName;
	local XComLWTuple Tuple;	//LWotC Tedster integration

	//only create and pass around one tuple...
	Tuple = new class'XComLWTuple';
	Tuple.Id = 'GetLWUnitInfo';
	Tuple.Data.Add(9);
	Tuple.Data[0].kind = XComLWTVBool;		Tuple.Data[0].b = false;	//Is the unit an Officer
	Tuple.Data[1].kind = XComLWTVInt;		Tuple.Data[1].i = -1;		//Officer Rank integer value
	Tuple.Data[2].kind = XComLWTVString;	Tuple.Data[2].s = "";		//Officer Rank Full Name string
	Tuple.Data[3].kind = XComLWTVString;	Tuple.Data[3].s = "";		//Officer Rank Short string
	Tuple.Data[4].kind = XComLWTVString;	Tuple.Data[4].s = "";		//Officer Rank Icon Path
	Tuple.Data[5].kind = XComLWTVBool;		Tuple.Data[5].b = false;	//Is a Haven Liason
	Tuple.Data[6].kind = XComLWTVObject;	Tuple.Data[6].o = none;		//XComGameState_WorldRegion object for the region the unit is located in
	Tuple.Data[7].kind = XComLWTVBool;		Tuple.Data[7].b = false;	//Is the unit Locked in their Haven
	Tuple.Data[8].kind = XComLWTVBool;		Tuple.Data[8].b = false;	//Is this unit on a mission right now

	//get all ALIVE xcom soldiers
	Soldiers = `XCOMHQ.GetSoldiers();

	//make a note of what they are currently doing
	foreach Soldiers(Soldier)
	{
		//Add to total unit count
		CurrentBarracksStatus.Total++;

		//check LWotC Statuses for this unit
		ResetTupleData(Tuple);
		`XEVENTMGR.TriggerEvent('GetLWUnitInfo', Tuple, Soldier);

		//Check for a staffed location
		//due to how some mods are using unique staff slot names we can just look for a slot template name, this check doesn't need to be gated behind a DLC check
		StaffSlotTemplateName = '';
		if (Soldier.GetStaffSlot() != none)
		{
			StaffSlotTemplateName = Soldier.GetStaffSlot().GetMyTemplateName();
		}

		// ===== BEGIN FILTERING =====
		if (Soldier.bCaptured)
		{
			//Vanilla capture includes by Advent and Chosen
			CurrentBarracksStatus.Captured++;
		}
		else if (Tuple.Data[5].b || default.StaffSlotNames_Haven.Find(StaffSlotTemplateName) != INDEX_NONE )
		{
			//Tuple data response from LWotC or in config list of Staff Slot names
			default.bEnableXWynnesStatGroups ? CurrentBarracksStatus.Busy++ : CurrentBarracksStatus.InHaven++;
		}
		else if (Tuple.Data[8].b || default.StaffSlotNames_Infil.Find(StaffSlotTemplateName) != INDEX_NONE )
		{
			//Tuple data response from LWotC or in config list of Staff Slot names
			CurrentBarracksStatus.Infiltrating++;
		}
		else if (Soldier.IsOnCovertAction())
		{
			//Covert actions
			default.bEnableXWynnesStatGroups ? CurrentBarracksStatus.Unavailable++ : CurrentBarracksStatus.OnCovertAction++;
		}
		else if (Soldier.IsInjured())
		{
			//any and all wounds
			default.bEnableXWynnesStatGroups ? CurrentBarracksStatus.Unavailable++ : CurrentBarracksStatus.Wounded++;
		}
		else if (Soldier.CanGoOnMission())
		{
			//Can go on mission, tired or ready
			if (Soldier.GetMentalState() == eMentalState_Tired)
			{
				default.bEnableXWynnesStatGroups ? CurrentBarracksStatus.Busy++ : CurrentBarracksStatus.Tired++;
			}
			else
			{
				CurrentBarracksStatus.Ready++;
			}
		}
		else
		{
			//so this counts shaken, gts training, psi training, bond training, pexm testing, soldier conditioning etc etc
			//basically anyone that can't go on a mission and doesn't fit any of the above criteria
			default.bEnableXWynnesStatGroups ? CurrentBarracksStatus.Busy++ :CurrentBarracksStatus.Unavailable++;
		}
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
			@ "\n Busy:			" @CurrentBarracksStatus.Busy
			@ "\n Total:		" @CurrentBarracksStatus.Total
			, default.bEnableLogging,'WOTC_CI_ResizeHangarStatus');

	return CurrentBarracksStatus;
}
	/////////////////////////////////////////////////////////////////

static function ResetTupleData(out XComLWTuple Tuple)
{
	Tuple.Data[0].b = false;	//Is the unit an Officer
	Tuple.Data[1].i = -1;		//Officer Rank integer value
	Tuple.Data[2].s = "";		//Officer Rank Full Name string
	Tuple.Data[3].s = "";		//Officer Rank Short string
	Tuple.Data[4].s = "";		//Officer Rank Icon Path
	Tuple.Data[5].b = false;	//Is a Haven Liason
	Tuple.Data[6].o = none;		//XComGameState_WorldRegion object for the region the unit is located in
	Tuple.Data[7].b = false;	//Is the unit Locked in their Haven
	Tuple.Data[8].b = false;	//Is this unit on a mission right now
}

	/////////////////////////////////////////////////////////////////

//A = text, B = number
static function string ColourText(string strValueA, coerce string strValueB, string strColour)
{
	local string strValue;
	strValue = default.bAvengerIsOneLinePerStat ? (strValueB @ ":" @ strValueA) : (strValueA $ ":" @ strValueB) ;

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
