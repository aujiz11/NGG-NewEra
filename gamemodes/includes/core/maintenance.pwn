#include <YSI_Coding\y_hooks>

new SystemUpdate, SystemTimer;
new Text:UpdateIn[2];

hook OnGameModeInit() {
	UpdateIn[0] = TextDrawCreate(483.999969, 431.007720, "Server_update_in:");
	TextDrawLetterSize(UpdateIn[0], 0.424666, 1.612444);
	TextDrawAlignment(UpdateIn[0], 1);
	TextDrawColor(UpdateIn[0], -1);
	TextDrawSetShadow(UpdateIn[0], 0);
	TextDrawSetOutline(UpdateIn[0], 1);
	TextDrawBackgroundColor(UpdateIn[0], 255);
	TextDrawFont(UpdateIn[0], 1);
	TextDrawSetProportional(UpdateIn[0], true);
	TextDrawSetShadow(UpdateIn[0], 0);

	UpdateIn[1] = TextDrawCreate(595.181335, 431.007720, "00:00");
	TextDrawLetterSize(UpdateIn[1], 0.424666, 1.612444);
	TextDrawAlignment(UpdateIn[1], 1);
	TextDrawColor(UpdateIn[1], -1);
	TextDrawSetShadow(UpdateIn[1], 0);
	TextDrawSetOutline(UpdateIn[1], 1);
	TextDrawBackgroundColor(UpdateIn[1], 255);
	TextDrawFont(UpdateIn[1], 1);
	TextDrawSetProportional(UpdateIn[1], true);
	TextDrawSetShadow(UpdateIn[1], 0);
	return 1;
}

hook OnPlayerConnect(playerid) {
	if(SystemUpdate > 0) {
		TextDrawShowForPlayer(playerid, UpdateIn[0]);
		TextDrawShowForPlayer(playerid, UpdateIn[1]);
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	new string[6];
	switch(dialogid)
	{
		case DIALOG_MAINTENANCE:
		{
			if(response) {
				if(isnull(inputtext)) return ShowPlayerDialogEx(playerid, DIALOG_MAINTENANCE, DIALOG_STYLE_INPUT, "How long should the timer run?", "Please specify in seconds how long before the server kicks all users & shuts down?\n\nWARNING: This action can't be undone!", "Shutdown", "Exit");
				if(!(30 <= strval(inputtext) < 3541)) return ShowPlayerDialogEx(playerid, DIALOG_MAINTENANCE, DIALOG_STYLE_INPUT, "How long should the timer run?", "Please specify in seconds how long before the server kicks all users & shuts down?\n\nWARNING: This action can't be undone!", "Shutdown", "Exit");
				if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to perform this action!");

			    SendClientMessageToAllEx(COLOR_LIGHTBLUE, "* The server will be going down for Scheduled Maintenance. (See bottom right screen)");
			    GameTextForAll("~n~~n~~n~~n~~y~] Scheduled Maintenance Alert ]", 5000, 3);
			    SystemUpdate = strval(inputtext);
			    format(string, sizeof(string), "%s", STimeConvert(SystemUpdate));
			    TextDrawShowForAll(UpdateIn[0]);
			    TextDrawSetString(UpdateIn[1], string);
			    TextDrawShowForAll(UpdateIn[1]);
			    if(SystemUpdate != 0) KillTimer(SystemTimer);
			    SystemTimer = SetTimer("MaintenanceTimer", 1000, true);
			}
			else SendClientMessageEx(playerid, COLOR_WHITE, "You have cancelled doing a maintenance restart.");

		}
	}
	return 1;
}

CMD:announcem(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to use this command.");
    ShowPlayerDialogEx(playerid, DIALOG_MAINTENANCE, DIALOG_STYLE_INPUT, "How long should the timer run?", "Please specify in seconds how long before the server kicks all users & shuts down?\n\nWARNING: This action can't be undone!", "Shutdown", "Exit");
    return 1;
}

forward MaintenanceTimer();
public MaintenanceTimer() {
	new string[6];
	if(--SystemUpdate == 0) KillTimer(SystemTimer), Maintenance();
	if(SystemUpdate == 15) GameTextForAll("~n~~n~~n~~n~~w~Please ~r~log out ~w~now to ensure ~y~account data ~w~has been ~g~saved~w~!", 5000, 3);
	if(SystemUpdate < 0) SystemUpdate = 0;
	format(string, sizeof(string), "%s", STimeConvert(SystemUpdate));
	TextDrawSetString(UpdateIn[1], string);
	TextDrawShowForAll(UpdateIn[1]);
	return 1;
}

STimeConvert(time) {
    new jmin;
    new jsec;
    new string[128];
	if(time > 59 && time < 3600){
        jmin = floatround(time/60);
        jsec = floatround(time - jmin*60);
        format(string,sizeof(string),"%02d:%02d",jmin,jsec);
    }
    else{
        jsec = floatround(time);
        format(string,sizeof(string),"00:%02d",jsec);
    }
    return string;
}



forward Maintenance();
public Maintenance()
{
	new string[128];
    ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Freezing Accounts...", 1);

    foreach(new i: Player)
	{
		TogglePlayerControllable(i, false);
	}

    ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Locking Paintball Arenas...", 1);

    for(new i = 0; i < MAX_ARENAS; i++)
    {
		foreach(new p: Player)
		{
			if(!GetPVarType(p, "IsInArena")) continue;
			new arenaid = GetPVarInt(p, "IsInArena");
			if(arenaid == i)
			{
				if(PaintBallArena[arenaid][pbBidMoney] > 0)
				{
					GivePlayerCash(p,PaintBallArena[GetPVarInt(p, "IsInArena")][pbBidMoney]);
					format(string,sizeof(string),"You have been refunded a total of $%d because of premature closure.",PaintBallArena[GetPVarInt(p, "IsInArena")][pbBidMoney]);
					SendClientMessageEx(p, COLOR_WHITE, string);
				}
				if(arenaid == GetPVarInt(p, "ArenaNumber"))
				{
					switch(PaintBallArena[arenaid][pbGameType])
					{
						case 1:
						{
							if(PlayerInfo[p][pDonateRank] < 3)
							{
								PlayerInfo[p][pPaintTokens] += 3;
								format(string,sizeof(string),"You have been refunded a total of %d Paintball Tokens because of premature closure.",3);
								SendClientMessageEx(p, COLOR_WHITE, string);
							}
						}
						case 2:
						{
							if(PlayerInfo[p][pDonateRank] < 3)
							{
								PlayerInfo[p][pPaintTokens] += 4;
								format(string,sizeof(string),"You have been refunded a total of %d Paintball Tokens because of premature closure.",4);
								SendClientMessageEx(p, COLOR_WHITE, string);
							}
						}
						case 3:
						{
							if(PlayerInfo[p][pDonateRank] < 3)
							{
								PlayerInfo[p][pPaintTokens] += 5;
								format(string,sizeof(string),"You have been refunded a total of %d Paintball Tokens because of premature closure.",5);
								SendClientMessageEx(p, COLOR_WHITE, string);
							}
						}
						case 4:
						{
							if(PlayerInfo[p][pDonateRank] < 3)
							{
								PlayerInfo[p][pPaintTokens] += 5;
								format(string,sizeof(string),"You have been refunded a total of %d Paintball Tokens because of premature closure.",5);
								SendClientMessageEx(p, COLOR_WHITE, string);
							}
						}
						case 5:
						{
							if(PlayerInfo[p][pDonateRank] < 3)
							{
								PlayerInfo[p][pPaintTokens] += 6;
								format(string,sizeof(string),"You have been refunded a total of %d Paintball Tokens because of premature closure.",6);
								SendClientMessageEx(p, COLOR_WHITE, string);
							}
						}
					}
				}
				LeavePaintballArena(p, arenaid);
			}
		}	
		ResetPaintballArena(i);
		PaintBallArena[i][pbLocked] = 2;
    }
    foreach(new i: Player)
	{
		GameTextForPlayer(i, "Scheduled Maintenance..", 5000, 5);
	}	


    ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Accounts...", 1);
	SendRconCommand("password asdatasdhwda");
	SendRconCommand("hostname Next Generation Roleplay [Restarting for Maintenance]");
	SaveAllAccountsUpdate(true);

	return 1;
}

forward FinishMaintenance();
public FinishMaintenance()
{
	if(gAccountSavesPending) {
		SetTimer("FinishMaintenance", 1000, false);
		return 0;
	}
	if(gAccountSaveErrors || gAccountSaveBatch != ACCOUNT_SAVE_NONE) return 0;
	gAccountSaveBatch = ACCOUNT_SAVE_WORLD;
    foreach(new i: Player) Kick(i);
    ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Houses...", 1);
	SaveHouses();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Dynamic Doors...", 1);
	SaveDynamicDoors();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Garages...", 1);
	SaveGarages();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Map Icons...", 1);
	SaveDynamicMapIcons();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Gates...", 1);
	SaveGates();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Event Points...", 1);
	SaveEventPoints();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Paintball Arenas...", 1);
	SavePaintballArenas();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Server Configuration", 1);
    Misc_Save();
    ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Office Elevator...", 1);
	SaveElevatorStuff();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Mail Boxes...", 1);
	SaveMailboxes();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Speed Cameras...", 1);
	SaveSpeedCameras();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Points...", 1);
	for (new i=0; i<MAX_POINTS; i++)
	{
		SavePoint(i);	
	}
	if(rflstatus > 0) {
		ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving RFL Teams...", 1);
		SaveRelayForLifeTeams();
	}
	g_mysql_SavePrices();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Force Saving Turfs...", 1);
	SaveTurfWars();
	ABroadCastText(COLOR_YELLOW, "{AA3333}Maintenance{FFFF00}: Streamer Plugin Shutting Down...", 1);
	DestroyAllDynamicObjects();
	DestroyAllDynamic3DTextLabels();
	DestroyAllDynamicCPs();
	DestroyAllDynamicMapIcons();
	DestroyAllDynamicRaceCPs();
	DestroyAllDynamicAreas();
	g_mysql_SaveMOTD();
	SetTimer("ShutDown", 5000, false);
	return 1;
}


forward ShutDown();
public ShutDown()
{
	if(gAccountSaveBatch != ACCOUNT_SAVE_WORLD) return 0;
	if(mysql_unprocessed_queries(MainPipeline) || (ShopToggle == 1 && mysql_unprocessed_queries(ShopPipeline))) {
		SetTimer("ShutDown", 1000, false);
		return 0;
	}
	if(gAccountSaveErrors) {
		print("[MySQL] Maintenance shutdown cancelled because a save query failed.");
		gAccountSaveBatch = ACCOUNT_SAVE_NONE;
		return 0;
	}
	if(!mysql_tquery(MainPipeline, "DO 0", "OnMaintenanceSaved", "i", 0)) {
		gAccountSaveBatch = ACCOUNT_SAVE_NONE;
		print("[MySQL] Maintenance shutdown cancelled: unable to confirm the write queue.");
		return 0;
	}
	return 1;
}

forward OnMaintenanceSaved(pipeline);
public OnMaintenanceSaved(pipeline)
{
	if(gAccountSaveBatch != ACCOUNT_SAVE_WORLD) return 0;
	if(gAccountSaveErrors) {
		gAccountSaveBatch = ACCOUNT_SAVE_NONE;
		print("[MySQL] Maintenance shutdown cancelled because a save query failed.");
		return 0;
	}
	if(!pipeline && ShopToggle == 1) {
		if(!mysql_tquery(ShopPipeline, "DO 0", "OnMaintenanceSaved", "i", 1)) {
			gAccountSaveBatch = ACCOUNT_SAVE_NONE;
			print("[MySQL] Maintenance shutdown cancelled: unable to confirm the shop write queue.");
			return 0;
		}
		return 1;
	}
	if(mysql_unprocessed_queries(MainPipeline) || (ShopToggle == 1 && mysql_unprocessed_queries(ShopPipeline))) {
		SetTimer("ShutDown", 1000, false);
		return 0;
	}
	print("[MySQL] Maintenance write queues acknowledged.");
	return SendRconCommand("exit");
}