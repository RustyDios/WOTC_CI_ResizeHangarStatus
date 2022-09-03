//*******************************************************************************************
//  FILE:    UIFacilityGrid_FacilityOverlay
//  
//	File created by RustyDios	05/07/21	01:30	
//	LAST UPDATED				07/07/21	18:00
//
//	Override to fix the background panel for the hanger to adjust to new 3line format
//	HUGE props to kdm2k6 for help with this!
//	includes the UI facility indicator fix from -bg-
//
//*******************************************************************************************

class UIFacilityGrid_FacilityOverlay_Rusty extends UIFacilityGrid_FacilityOverlay;

	/////////////////////////////////////////////////////
	//	FIX FACILITY UI INDICATOR by BG -- shares same MCO, so I included
	//	https://steamcommunity.com/sharedfiles/filedetails/?id=1130714554
	/////////////////////////////////////////////////////

function array<EUIStaffIconType> GetStaffIconDataForClearingSlots()
{
	local int i;
	local array<EUIStaffIconType> NewIcons;
	local XComGameState_HeadquartersRoom Room;

	Room = GetRoom();

	for (i = 0; i < Room.BuildSlots.Length; ++i)
	{
		if (Room.GetBuildSlot(i).IsSlotFilled())
		{
			NewIcons.AddItem(eUIFG_Engineer);
		}
		else
		{
			NewIcons.AddItem(eUIFG_EngineerEmpty);
		}
	}

	return NewIcons;
}

	//////////////////////////////////////////////////////
	//	RESIZE FLASH ELEMENT FOR HANGER DISPLAY
	/////////////////////////////////////////////////////

simulated function OnReceiveFocus()
{
	local XComGameState_HeadquartersRoom Room;
	local X2FacilityTemplate FacilityTemplate;

	//DO NOT CALL SUPER. We don't want to activate all of the children. 
	//super.OnReceiveFocus();

	if(!bIsFocused) 
	{
		bIsFocused = true;
		MC.FunctionVoid("onReceiveFocus");
	}

	BGPanel.OnReceiveFocus();

	UpdateData();
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_Mouseover");

	/////////////////////////////////////////////////////

	Room = GetRoom();

	if( Room.HasFacility() )
	{
		FacilityTemplate = GetFacility().GetMyTemplate();

		switch(FacilityTemplate.DataName)
		{
			//Within Flash : FacilityGridHighlight : this.statusLabel.bg._width = this.statusLabel.label.textWidth + 24;
			//ONLY DO THIS FOR THE HANGER ? FOR SAFETY ?
			case 'Hangar':
				//`LOG("Hangar Recieved Focus",,'WOTC_CI_ResizeHangerStatus');

				MC.ChildSetBool("queueLabel.label","multiline", true);
				MC.ChildSetBool("queueLabel.label", "wordWrap", true);
				MC.ChildSetBool("queueLabel.label", "autoSize", true);

				MC.ChildSetNum("queueLabel.bg", "_width", MC.GetNum("queueLabel.label.textWidth") +24);
				MC.ChildSetNum("queueLabel.bg", "_height", MC.GetNum("queueLabel.label.textHeight") +10);

			break;
		}
	}

	/////////////////////////////////////////////////////

}
