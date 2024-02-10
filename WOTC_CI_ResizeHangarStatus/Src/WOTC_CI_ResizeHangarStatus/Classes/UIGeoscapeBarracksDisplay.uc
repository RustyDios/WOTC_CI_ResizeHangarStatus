//*******************************************************************************************
//  FILE:   Show Barracks Status On Geo by RustyDios                           
//  
//	File CREATED	02/09/21	10:15
//	LAST UPDATED    21/02/22	09:30
//
//	ADDS A NEW PANEL TO THE GEOSCAPE THAT DISPLAYS THE BARRACKS STATUS
//  CODED WITH HELP FROM XYMANEK
//
//*******************************************************************************************
class UIGeoscapeBarracksDisplay extends UIPanel dependson (X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus) ;

const PanelName = 'RustyGeoscapeBarracksDisplay' ;

//panels and things used just for this UI
var UIBGBox GeoBarracksTextBG;
var UIPanel GeoBarracksText, GeoBarracksSplitLine;
var UIButton GeoBarracksButton;
var UIX2PanelHeader GeoBarracksTitleHeader;
var UITextContainer GeoBarracksTextDescription;

var bool bSingleLine, bFlatLine, bEnableLogging;

var string strSoldiers, strReady, strTired, strWounded, strInfiltrating, strOnCovertAction, strUnavailable, strCaptured, strInHaven;
var string HexSoldiers, HexReady, HexTired, HexWounded, HexInfiltrating, HexOnCovertAction, HexUnavailable, HexCaptured, HexInHaven;

// Watch handle, to automatically hide panel if ComVid is on
var int ComVidWatch;

function InitBarracksDisplay (int AnchorY, int AnchorX, int PanelW, int PanelH, bool IsSingleLine = false, bool IsFlatLine = false)
{
    InitPanel(PanelName);

	CopySettingsFromDLCinfo();

	bSingleLine = IsSingleLine;
	bFlatline = IsFlatline;

    // Init the elements
    AddPanel(AnchorY,AnchorX,PanelW,PanelH);

    // initial Update
    UpdateGeoBarracksText();

	//set up a watch variable to show hide the panel if comvid is visible .. watch this.. .. for this .. use this.. & call function
	ComVidWatch = WorldInfo.MyWatchVariableMgr.RegisterWatchVariable( Movie.Pres.GetUIComm(), 'bIsVisible',  self, ToggleForComVid);

}

//copy settings so the Hanger Barracks String and this one use the same Localisation and colours
simulated function CopySettingsFromDLCInfo()
{
	//logging toggle
	bEnableLogging		= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.bEnableLogging;

	//title
	strSoldiers			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strSoldiers;

	//strings
	strReady			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strReady;
	strTired			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strTired;
	strWounded			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strWounded;
	strInfiltrating		= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strInfiltrating;
	strOnCovertAction	= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strOnCovertAction;
	strUnavailable		= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strUnavailable;
	strCaptured			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strCaptured;
	strInHaven			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.strInHaven;

	//colours
	HexSoldiers			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexSoldiers;
	HexReady			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexReady;
	HexTired			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexTired;
	HexWounded			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexWounded;
	HexInfiltrating		= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexInfiltrating;
	HexOnCovertAction	= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexOnCovertAction;
	HexUnavailable		= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexUnavailable;
	HexCaptured			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexCaptured;
	HexInHaven			= class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.default.HexInHaven;

}

///////////////////////////////////////////////////////////////////////////////
//  NEW PANEL
///////////////////////////////////////////////////////////////////////////////

//here we init the BG boxes
simulated function AddPanel(int AnchorY, int AnchorX, int PanelW, int PanelH)
{
    //setup the background panel
    GeoBarracksTextBG = Spawn(class'UIBGBox', self);
    GeoBarracksTextBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
    GeoBarracksTextBG.InitBG('ShowGeoBarracksText_GeoBarracksText_BG', AnchorX, AnchorY, PanelW, PanelH); // pos x, pos y , width, height

    //setup the text panel to the same size and position
    GeoBarracksText = Spawn(class'UIPanel', self);
    GeoBarracksText.InitPanel('ShowGeoBarracksText_GeoBarracksText');
    GeoBarracksText.SetSize(GeoBarracksTextBG.Width, GeoBarracksTextBG.Height);
    GeoBarracksText.SetPosition(GeoBarracksTextBG.X, GeoBarracksTextBG.Y);

    //setup the text panel title
	GeoBarracksTitleHeader = Spawn(class'UIX2PanelHeader', GeoBarracksText);
	GeoBarracksTitleHeader.InitPanelHeader('ShowGeoBarracksText_GeoBarracksTitle', class'UIUtilities_Text'.static.GetColoredText(strSoldiers, GetTitleColor(), 28), "");
	GeoBarracksTitleHeader.SetPosition(GeoBarracksTitleHeader.X + 10, GeoBarracksTitleHeader.Y + 10);
	GeoBarracksTitleHeader.SetHeaderWidth(GeoBarracksText.Width - 20);
	GeoBarracksTitleHeader.bRealizeOnSetText = true;	//allows recolouring of the title based on status

	//setup the detailed list button, no text is a ? icon ... thanks to Xymanek 
	GeoBarracksButton = Spawn(class'UIButton', GeoBarracksText);
	GeoBarracksButton.bAnimateOnInit = false;
	GeoBarracksButton.LibID = 'X2InfoButton';
	GeoBarracksButton.InitButton('ShowGeoBarracksButton', "", OnShowPersonnel, -1, '');

	//setup a 'linebreak'
	GeoBarracksSplitLine = Spawn(class'UIPanel', GeoBarracksText);
	GeoBarracksSplitLine.InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
    GeoBarracksSplitLine.SetColor( class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR );
	GeoBarracksSplitLine.SetPosition(GeoBarracksTextDescription.X + 10, GeoBarracksTextDescription.Y + 48);
	GeoBarracksSplitLine.SetSize( GeoBarracksTextBG.Width - 20, 2 );
    GeoBarracksSplitLine.SetAlpha( 15 );

	if (bSingleLine)
	{
		//Set Icon for Stacked Single Line compressed block .. why - 26? ... icon size 24 .. icon padding 2
		GeoBarracksButton.SetPosition( GeoBarracksButton.X + (PanelW - 26), GeoBarracksButton.Y + (GeoBarracksTitleHeader.Height / 4) );
	}
	else
	{	//Set Icon for Long Flat Line or Compact Box .. why -44? ... icon size 24, header padding right 10, icon padding 10
		GeoBarracksButton.SetPosition( GeoBarracksButton.X + (PanelW - 44), GeoBarracksButton.Y + (GeoBarracksTitleHeader.Height / 4) ); 
	}

    //setup the main body description text, size and position
    GeoBarracksTextDescription = Spawn(class'UITextContainer', GeoBarracksText);
    GeoBarracksTextDescription.InitTextContainer();            
    GeoBarracksTextDescription.bAutoScroll = true;
    GeoBarracksTextDescription.SetSize(GeoBarracksTextBG.Width - 20, GeoBarracksTextBG.Height - 55);
    GeoBarracksTextDescription.SetPosition(GeoBarracksTextDescription.X + 10, GeoBarracksTextDescription.Y + 50);

    GeoBarracksTextDescription.Text.SetHeight(GeoBarracksTextDescription.Text.Height * 3.0f);                   

    `LOG("===== GEOSCAPE BARRACKS INFO PANEL ADDED =====",bEnableLogging,'RustyShowBarracksGeo');
}

///////////////////////////////////////////////////////////////////////////////
//  Button Functions = Living Quarters DSL, incase I need to change adjust at a later date
//	In XComHQPresentationLayer ... Living Quarters displays all three tabs, has no action on selected
//
//	function UIPersonnel_LivingQuarters(delegate<UIPersonnel.OnPersonnelSelected> onSelected)
//	{
//		local UIPersonnel_LivingQuarters kPersonnelList;
//
//		if (ScreenStack.IsNotInStack(class'UIPersonnel_LivingQuarters'))
//		{
//			kPersonnelList = Spawn(class'UIPersonnel_LivingQuarters', self);
//			kPersonnelList.onSelectedDelegate = onSelected;
//			ScreenStack.Push(kPersonnelList);
//		}
//	}
//
///////////////////////////////////////////////////////////////////////////////

simulated function OnShowPersonnel(UIButton Button)
{
	`HQPRES.UIPersonnel_LivingQuarters(OnPersonnelSelected);
}

simulated function OnPersonnelSelected(StateObjectReference selectedUnitRef)
{
	//TODO: add any logic here for selecting someone from the geoscape .. default nothing
	Movie.Pres.PlayUISound(eSUISound_MenuClickNegative);
}

///////////////////////////////////////////////////////////////////////////////
//  UPDATING TEXT
///////////////////////////////////////////////////////////////////////////////

//update and change the text based on current barracks info
simulated function UpdateGeoBarracksText()
{
	local BarracksStatusReport_Rusty CurrentBarracksStatus;
	local string strStatus;

	//get report of all xcom HQ soldiers current activities
	CurrentBarracksStatus = class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.static.GetBarracksStatusReport_Rusty();

	strStatus = "";

	//check mode and formulate correct string response
	if (bFlatLine)
	{
		//all one line -- text: # , text: # , text: # , text: # , text: # , text: # , text: # , text: #
		strStatus $= 		 ColourText(strReady $ ":" @ CurrentBarracksStatus.Ready, HexReady);
		strStatus $= " , " $ ColourText(strTired $ ":" @ CurrentBarracksStatus.Tired, HexTired);
		strStatus $= " , " $ ColourText(strWounded $ ":" @ CurrentBarracksStatus.Wounded, HexWounded);
			//insert DLC check for CI or LWotC ?
		strStatus $= " , " $ ColourText(strInfiltrating $ ":" @ CurrentBarracksStatus.Infiltrating, HexInfiltrating);
			//end DLC check
		strStatus $= " , " $ ColourText(strOnCovertAction $ ":" @ CurrentBarracksStatus.OnCovertAction, HexOnCovertAction);
		strStatus $= " , " $ ColourText(strUnavailable $ ":" @ CurrentBarracksStatus.Unavailable, HexUnavailable);
		
		//only show if you have advisors in havens
		if (CurrentBarracksStatus.InHaven > 0)
		{
			strStatus $= " , " $ ColourText(default.strInHaven $ ":" @ CurrentBarracksStatus.InHaven, default.HexInHaven);
		}

		//only show captured if you have captured
		if (CurrentBarracksStatus.Captured > 0)
		{
			strStatus $= " , " $ ColourText(strCaptured $ ":" @ CurrentBarracksStatus.Captured, HexCaptured);
		}

		`LOG("Geoscape Barracks Status Display Flat Line Active",bEnableLogging,'RustyShowBarracksGeo');
	}
	else if (bSingleLine)
	{
		//single line stacked each line -- # : text
		strStatus $= 		ColourText(CurrentBarracksStatus.Ready @ ":" @ strReady, HexReady);
		strStatus $= "\n" $ ColourText(CurrentBarracksStatus.Tired @ ":" @ strTired, HexTired);
		strStatus $= "\n" $	ColourText(CurrentBarracksStatus.Wounded @ ":" @ strWounded, HexWounded);
			//insert DLC check for CI or LWotC ?
		strStatus $= "\n" $	ColourText(CurrentBarracksStatus.Infiltrating @ ":" @ strInfiltrating, HexInfiltrating);
			//end DLC check
		strStatus $= "\n" $	ColourText(CurrentBarracksStatus.OnCovertAction @ ":" @ strOnCovertAction, HexOnCovertAction);
		strStatus $= "\n" $	ColourText(CurrentBarracksStatus.Unavailable @ ":" @ strUnavailable, HexUnavailable);

		//only show if you have advisors in havens
		if (CurrentBarracksStatus.InHaven > 0)
		{
			strStatus $= "\n" $ ColourText(CurrentBarracksStatus.InHaven @ ":" @ strInHaven, HexInHaven);
		}

		//only show captured if you have captured
		if (CurrentBarracksStatus.Captured > 0)
		{
			strStatus $= "\n" $ ColourText(CurrentBarracksStatus.Captured @ ":" @ strCaptured, HexCaptured);
		}

		`LOG("Geoscape Barracks Status Display Single Stack Active",bEnableLogging,'RustyShowBarracksGeo');
	}
	else
	{
		//Compact Block multiline layout
		//	U/a XX , [Haven Advisor xx] , (Captured xx), 
		//	Infiltrating xx, Covert Action xx
		//	Ready xx, Tired xx, Wounded xx

		strStatus $= ColourText(strUnavailable $ ":" @ CurrentBarracksStatus.Unavailable, HexUnavailable);

		//only show if you have advisors in havens
		if (CurrentBarracksStatus.InHaven > 0)
		{
			strStatus $= " , " $ ColourText(strInHaven $ ":" @ CurrentBarracksStatus.InHaven, HexInHaven);
		}

		//only show captured if you have captured
		if (CurrentBarracksStatus.Captured > 0)
		{
			strStatus $= " , " $ ColourText(strCaptured $ ":" @ CurrentBarracksStatus.Captured, HexCaptured);
		}

			//Insert if DLC for CI or LWotC ?
		strStatus $= "\n" $ ColourText(strInfiltrating $ ":" @ CurrentBarracksStatus.Infiltrating, HexInfiltrating);
			//end DLC Check
		strStatus $= " , " $ ColourText(strOnCovertAction $ ":" @ CurrentBarracksStatus.OnCovertAction, HexOnCovertAction);

		strStatus $= "\n" $ ColourText(strReady $ ":" @ CurrentBarracksStatus.Ready, HexReady);
		strStatus $= " , " $ ColourText(strTired $ ":" @ CurrentBarracksStatus.Tired, HexTired);
		strStatus $= " , " $ ColourText(strWounded $ ":" @ CurrentBarracksStatus.Wounded, HexWounded);

		`LOG("Geoscape Barracks Status Display Multi Line Active",bEnableLogging,'RustyShowBarracksGeo');
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
			, bEnableLogging,'RustyShowBarracksGeo');

    //change the Description in the panel
    GeoBarracksTextDescription.SetText(class'UIUtilities_Text'.static.AddFontInfo(strStatus, false, false, false, 18) );

	//update Title colour based on new data
   	GeoBarracksTitleHeader.SetText(class'UIUtilities_Text'.static.GetColoredText(strSoldiers, GetTitleColor() , 28), "");

    `LOG("===== GEOSCAPE BARRACKS STATUS TEXT UPDATE DONE =====",bEnableLogging,'RustyShowBarracksGeo');
}

	/////////////////////////////////////////////////////////////////

//PERFORM TEXT UPDATES ON TICK
event Tick (float DeltaTime)
{
	if (bIsVisible && Screen.bIsVisible)
	{
		UpdateGeoBarracksText();
	}

	SuppressForComVidDuringTransitions();
	SuppressForResistanceReport_AndEndGameStats();
}

///////////////////////////////////////////////////////////////////////////////
//  COLOURING THE TITLE BAR BASED ON STATUS
///////////////////////////////////////////////////////////////////////////////

static function EUIState GetTitleColor()
{
	local BarracksStatusReport_Rusty CurrentBarracksStatus;

	//get report of all xcom HQ soldiers current activities
	CurrentBarracksStatus = class'X2DownloadableContentInfo_WOTC_CI_ResizeHangarStatus'.static.GetBarracksStatusReport_Rusty();

	if (CurrentBarracksStatus.Ready >= 6)																				{ return eUIState_Cash;		}
	else if (CurrentBarracksStatus.Infiltrating + CurrentBarracksStatus.OnCovertAction >= 1 )							{ return eUIState_Warning; 	}
	else if (CurrentBarracksStatus.Tired + CurrentBarracksStatus.InHaven >= 1 )											{ return eUIState_Warning2; }
	else if (CurrentBarracksStatus.Wounded + CurrentBarracksStatus.Captured >= 1)										{ return eUIState_Bad; 		}

	// default if above criteria not met, CurrentBarracksStatus.Unavailable >=1 .. or LOGIC ERROR ?
	return eUIState_Faded;
}

	/////////////////////////////////////////////////////////////////

static function string ColourText(string strValue, string strColour)
{
	//colour a html string by hex value input
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}


///////////////////////////////////////////////////////////////////////////////
//  TOGGLE VISIBILITY BASED ON COMVID - final code from Xymanek
///////////////////////////////////////////////////////////////////////////////

// Toggle barracks display when ComVid is visible.
function ToggleForComVid()
{
	//if the Presentation layer says the ComVid is visible.. hide our panel, or not
	//if (`BATTLE.PRES().GetUIComm().bIsVisible)	//<< also works in tactical
	//if( `HQPRES.GetUIComm().bIsVisible ) 			//<< also works in strategy
    if (Movie.Pres.GetUIComm().bIsVisible)
    {
        Hide();
    }
    else
    {
        Show();
        AnimateIn(0.10);	//if blank it is 0.05 x ParentChildIndex which is ??
    }
}

// Delay barracks display when ComVid is visible on transitions.
function SuppressForComVidDuringTransitions()
{
	//if the Presentation layer says the ComVid is visible.. hide our panel
	//if (`BATTLE.PRES().GetUIComm().bIsVisible)	//<< also works in tactical
	//if( `HQPRES.GetUIComm().bIsVisible ) 			//<< also works in strategy
    if (Movie.Pres.GetUIComm().bIsVisible)
    {
        Hide();
    }
}

// suppress barracks display when resistance reports or endgame stats are shown.
function SuppressForResistanceReport_AndEndGameStats()
{
	//if any of these screens is visible.. hide our panel
    if (`SCREENSTACK.IsInStack(class'UIEndGameStats') 
		|| `SCREENSTACK.IsInStack(class'UIResistanceReport')
		|| `SCREENSTACK.IsInStack(class'UIResistanceReport_ChosenEvents')
		|| `SCREENSTACK.IsInStack(class'UIResistanceReport_FactionEvents')
	 	)
    {
        Hide();
    }
}

///////////////////////////////////////////////////////////////////////////////
//  REMOVE CODE TO ENSURE WE REMOVE THE WATCH VARIABLE
///////////////////////////////////////////////////////////////////////////////

// Called during Remove
simulated event Removed()
{
	//AT END OF STRATEGY PLAY (GEOSCAPE REMOVED) ENSURE WE REMOVE THE WATCH ORDER!!
	WorldInfo.MyWatchVariableMgr.EnableDisableWatchVariable(ComVidWatch, true);
	WorldInfo.MyWatchVariableMgr.UnRegisterWatchVariable( ComVidWatch );

	super.Removed();
}

///////////////////////////////////////////////////////////////////////////////
//  COMMAND TO BRING UP THE MENU
//	SEE ALSO THE UISL FOR HANDLEINPUT
///////////////////////////////////////////////////////////////////////////////

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	// Only pay attention to presses or repeats; ignoring other input types
	if ( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	switch( cmd )
	{
		case class'UIUtilities_Input'.const.FXS_DPAD_DOWN:
			`HQPRES.UIPersonnel_LivingQuarters(OnPersonnelSelected);
			break;
	}

	return super.OnUnrealCommand(cmd, arg);
}
