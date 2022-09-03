This was a fun little project...

sets CI barracks status over multiple lines

many thanks to MrNiceUK, Kdm2k6, BountyGiver, NSLW and Xymanek
many thanks to AzureWind on twitch for the reminder about captured units!

https://steamcommunity.com/sharedfiles/filedetails/?id=2567230730 CI
https://steamcommunity.com/sharedfiles/filedetails/?id=1545241386 LSO
https://steamcommunity.com/sharedfiles/filedetails/?id=2734579315 LSO CI BRIDGE

=======================================================================================
STEAM DESC			https://steamcommunity.com/sharedfiles/filedetails/?id=2540649820
=======================================================================================
[h1]What is this?[/h1]
This is a simple little mod that changes the single long line of soldier status in the hangar to a compact block. This issue really becomes apparent with Covert Infiltrations improved display message for where your soldiers are.

Also adds a barracks status display on the Geoscape, can be turned off in the configs if you wish. The title on the Geoscape Display will change colour based on the barracks status.
[list]
[*]Green is >= 6 soldiers Ready
[*]Yellow is < 6 Ready, but people active doing things
[*]Red is < 6 Ready and no-one doing anything, at least one wounded
[*]Grey is anything not in the above (?!)
[/list]
The box on the Geoscape also has a shortcut [b]{?} Icon[/b] that you can click on to bring up the [i]Living Quarters Crew List[/i], which displays detailed crew information.

[h1]Config Options[/h1]
It wouldn't be a 'RustyMod' without some would it?
[b]XComGame.ini[/b] contains all the options I have here which involves choosing text colours and making it a compact block (default) or stacked lines per status display.

[h1]Compatibility/Known Issues[/h1]
[strike]None that I know[/strike] ... Might not work 'correctly' outside of a CI game
It appears that sometimes the avenger tooltip doesn't initialise correctly. I thought I had eliminated this bug in my testing and it seems super rare, but I had a report of the avenger tooltip not sizing correctly in a 2560*1440 resolution until a config clear reset.

Support added for [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1545241386] Lightweight Strategy Overhaul [/url] Resistance/Advisor/Cell shows as "Haven Advisor" ..

For LWOTC soldiers 'On Infiltration' will show as 'On Covert Action'. This is due to how LWOTC sets it's infiltration status different to how Covert Infiltration does (and this mod was initially designed for CI). I am working hard to bring all the features to LWOTC but find building for LWOTC a difficult process. When I can figure out how to correctly account for LWotC I will update.

[h1]Credits and Thanks[/h1]
Many thanks to [b]MrNiceUK[/b], [b]kdm2k6[/b] and [b]-bg-[/b]for the UI/flash aspect help
Huge thanks to [b]NotSoLoneWolf[/b] and [b]Xymanek[/b] for Covert Infiltration, which this is designed to work alongside and was based upon
As always, much appreciation to -all- the people on the XCOM2 Modders Discord !!

~ Enjoy [b]!![/b] and please [url=https://www.buymeacoffee.com/RustyDios] buy me a Cuppa Tea[/url]

=======================================================================================

`define LWOUTPOSTMGR class'XComGameState_LWOutpostManager'.static.GetOutpostManager()

`define LWSQUADMGR class'XComGameState_LWSquadManager'.static.GetSquadManager()

`define LWACTIVITYMGR class'XComGameState_LWAlienActivityManager'.static.GetAlienActivityManager()

`define LWOVERHAULOPTIONS class'XComGameState_LWOverhaulOptions'.static.GetLWOverhaulOptions()

`define LWPODMGR class'XComGameState_LWPodManager'.static.GetPodManager()

/* Pod Manager tracing */
`define LWPMTrace(msg, cond, tag) `Log(`msg, `cond, 'LWPMTrace')

`define DYNAMIC_ID_PROP(propset,prop) `XCOMHISTORY.GetGameStateForObjectID(class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(`propset, `prop))
`define DYNAMIC_ALERT_PROP(alert,prop) `XCOMHISTORY.GetGameStateForObjectID(class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(`alert.DisplayPropertySet, `prop))

`define MIN_INFIL_FOR_CONCEAL class'X2DownloadableContentInfo_LongWarOfTheChosen'.default.MINIMUM_INFIL_FOR_CONCEAL
