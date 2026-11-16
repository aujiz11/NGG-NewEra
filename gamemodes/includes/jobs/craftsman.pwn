/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Craftsman System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

	* Copyright (c) 2016, Next Generation Gaming, LLC
	*
	* All rights reserved.
	*
	* Redistribution and use in source and binary forms, with or without modification,
	* are not permitted in any case.
	*
	*
	* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

Craftsman_StopFirstAid(playerid)
{
	KillTimer(GetPVarInt(playerid, "firstaid5"));
	KillTimer(GetPVarInt(playerid, "firstaidexpire"));
	DeletePVar(playerid, "firstaid5");
	DeletePVar(playerid, "firstaidexpire");
	DeletePVar(playerid, "usingfirstaid");
	return 1;
}

Craftsman_StopRCCam(playerid, bool:restore = true)
{
	if(!GetPVarInt(playerid, "rccam")) return 0;
	new vehicleid = GetPVarInt(playerid, "rcveh");
	DeletePVar(playerid, "rccam");
	DeletePVar(playerid, "rcveh");
	KillTimer(GetPVarInt(playerid, "rccamtimer"));
	DeletePVar(playerid, "rccamtimer");
	if(IsValidVehicle(vehicleid)) DestroyVehicle(vehicleid);
	if(restore) SetPlayerPos(playerid, GetPVarFloat(playerid, "rcX"), GetPVarFloat(playerid, "rcY"), GetPVarFloat(playerid, "rcZ"));
	return 1;
}

Craftsman_StopCameraView(playerid, bool:restore = true)
{
	if(!GetPVarInt(playerid, "camerasc")) return 0;
	DeletePVar(playerid, "camerasc");
	if(restore)
	{
		SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "cameravw2"));
		SetPlayerInterior(playerid, GetPVarInt(playerid, "cameraint2"));
		SetPlayerPos(playerid, GetPVarFloat(playerid, "cameraX2"), GetPVarFloat(playerid, "cameraY2"), GetPVarFloat(playerid, "cameraZ2"));
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
	}
	return 1;
}

Craftsman_DestroyCamera(playerid, bool:restore = true)
{
	if(!GetPVarInt(playerid, "cameraactive")) return 0;
	Craftsman_StopCameraView(playerid, restore);
	KillTimer(GetPVarInt(playerid, "cameraexpire"));
	DeletePVar(playerid, "cameraexpire");
	DeletePVar(playerid, "cameraactive");
	DestroyDynamic3DTextLabel(Camera3D[playerid]);
	Camera3D[playerid] = Text3D:INVALID_STREAMER_ID;
	return 1;
}

forward firstaid5(playerid, session);
public firstaid5(playerid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || !GetPVarInt(playerid, "usingfirstaid")) return 1;
	new Float:health;
	GetHealth(playerid, health);
	if(0.0 < health < 100.0 && !PlayerIsDead[playerid] && !GetPVarInt(playerid, "Injured")) SetHealth(playerid, health + 5.0 > 100.0 ? 100.0 : health + 5.0);
	return 1;
}

forward firstaidexpire(playerid, session);
public firstaidexpire(playerid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || !GetPVarInt(playerid, "usingfirstaid")) return 1;
	Craftsman_StopFirstAid(playerid);
	SendClientMessageEx(playerid, COLOR_GRAD1, "Your first aid kit no longer takes effect.");
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pAdmin] >= 2 && GetPVarType(i, "_dCheck") && GetPVarInt(i, "_dCheck") == playerid)
		{
			SendClientMessageEx(i, COLOR_ORANGE, "Note{ffffff}: First Aid effect has expired on the person you are damage checking.");
		}
	}
	return 1;
}

forward rccam(playerid, session);
public rccam(playerid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || !GetPVarInt(playerid, "rccam")) return 1;
	Craftsman_StopRCCam(playerid);
	SendClientMessageEx(playerid, COLOR_GRAD1, "Your RC Cam has run out of batteries!");
	return 1;
}

forward cameraexpire(playerid, session);
public cameraexpire(playerid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || !GetPVarInt(playerid, "cameraactive")) return 1;
	Craftsman_DestroyCamera(playerid);
	SendClientMessageEx(playerid, COLOR_GRAD1, "Your camera ran out of batteries!");
	return 1;
}

CMD:pc(playerid, params[])
{
	if(PlayerInfo[playerid][pSurveillance] <= 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have a surveillance camera!");
	if(GetPVarInt(playerid, "cameraactive")) return SendClientMessageEx(playerid, COLOR_GRAD1, "Wait for your other camera to expire.");
	new Float:X, Float:Y, Float:Z, string[128];
	GetPlayerPos(playerid, X, Y, Z);
	Camera3D[playerid] = CreateDynamic3DTextLabel("** A small camera. **", 0x008080FF, X, Y, Z, 4.0, .worldid = GetPlayerVirtualWorld(playerid), .interiorid = GetPlayerInterior(playerid));
	if(Camera3D[playerid] == Text3D:INVALID_STREAMER_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "Unable to place your camera right now.");
	SetPVarInt(playerid, "cameraactive", 1);
	SetPVarFloat(playerid, "cameraX", X);
	SetPVarFloat(playerid, "cameraY", Y);
	SetPVarFloat(playerid, "cameraZ", Z);
	SetPVarInt(playerid, "cameravw", GetPlayerVirtualWorld(playerid));
	SetPVarInt(playerid, "cameraint", GetPlayerInterior(playerid));
	SetPVarInt(playerid, "cameraexpire", SetTimerEx("cameraexpire", 120000, false, "ii", playerid, g_arrQueryHandle[playerid]));
	PlayerInfo[playerid][pSurveillance]--;
	SendClientMessageEx(playerid, COLOR_GRAD1, "You placed your camera, go hide and use /sc. Batteries expire in 2 minutes.");
	format(string, sizeof(string), "* %s places something on the ground.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	return 1;
}

CMD:sc(playerid, params[])
{
	if(!GetPVarInt(playerid, "cameraactive")) return SendClientMessageEx(playerid, COLOR_GRAD1, "You have no active camera!");
	if(GetPVarInt(playerid, "camerasc"))
	{
		Craftsman_StopCameraView(playerid);
		return 1;
	}
	if(GetPVarInt(playerid, "rccam") || GetPVarType(playerid, "WatchingTV")
		|| GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || PlayerIsDead[playerid] || GetPVarInt(playerid, "Injured") || PlayerInfo[playerid][pHospital] > 0)
		return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now.");
	new Float:X, Float:Y, Float:Z, string[128];
	format(string, sizeof(string), "* %s stares into a small screen.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	GetPlayerPos(playerid, X, Y, Z);
	SetPVarFloat(playerid, "cameraX2", X);
	SetPVarFloat(playerid, "cameraY2", Y);
	SetPVarFloat(playerid, "cameraZ2", Z);
	SetPVarInt(playerid, "cameravw2", GetPlayerVirtualWorld(playerid));
	SetPVarInt(playerid, "cameraint2", GetPlayerInterior(playerid));
	SetPVarInt(playerid, "camerasc", 1);
	TogglePlayerControllable(playerid, false);
	SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "cameravw"));
	SetPlayerInterior(playerid, GetPVarInt(playerid, "cameraint"));
	SetPlayerPos(playerid, GetPVarFloat(playerid, "cameraX"), GetPVarFloat(playerid, "cameraY"), GetPVarFloat(playerid, "cameraZ") - 30.0);
	SetPlayerCameraPos(playerid, GetPVarFloat(playerid, "cameraX"), GetPVarFloat(playerid, "cameraY"), GetPVarFloat(playerid, "cameraZ") + 20.0);
	SetPlayerCameraLookAt(playerid, GetPVarFloat(playerid, "cameraX"), GetPVarFloat(playerid, "cameraY"), GetPVarFloat(playerid, "cameraZ"));
	return 1;
}

CMD:dc(playerid, params[])
{
	if(!GetPVarInt(playerid, "cameraactive")) return SendClientMessageEx(playerid, COLOR_GRAD1, "There is nothing to destroy!");
	if(!GetPVarInt(playerid, "camerasc") && (GetPlayerVirtualWorld(playerid) != GetPVarInt(playerid, "cameravw")
		|| GetPlayerInterior(playerid) != GetPVarInt(playerid, "cameraint")
		|| !IsPlayerInRangeOfPoint(playerid, 5.0, GetPVarFloat(playerid, "cameraX"), GetPVarFloat(playerid, "cameraY"), GetPVarFloat(playerid, "cameraZ"))))
		return SendClientMessageEx(playerid, COLOR_WHITE, "You are not near your camera.");
	Craftsman_DestroyCamera(playerid);
	SendClientMessageEx(playerid, COLOR_GRAD1, "Camera Destroyed!");
	return 1;
}

CMD:rccam(playerid, params[])
{
	if(GetPVarInt(playerid, "rccam"))
	{
		Craftsman_StopRCCam(playerid);
		return 1;
	}
	if(PlayerInfo[playerid][pRccam] <= 0) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have an RC Cam!");
	
	if(GetPVarType(playerid, "IsInArena") || GetPVarType(playerid, "WatchingTV") || GetPVarInt(playerid, "camerasc")) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now.");
	
	if(GetPVarInt(playerid, "Injured") || PlayerIsDead[playerid] || PlayerInfo[playerid][pHospital] > 0 || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now.");
	
	if(GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now.");
	
	if(PlayerInfo[playerid][pJailTime] > 0) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "You cannot use this while in prison.");
	
	new Float:X, Float:Y, Float:Z, string[128];
	GetPlayerPos(playerid, X, Y, Z);
	new vehicleid = CreateVehicle(594, X, Y, Z, 0.0, 0, 0, -1);
	if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "Unable to place your RC Cam right now.");
	SetPVarFloat(playerid, "rcX", X);
	SetPVarFloat(playerid, "rcY", Y);
	SetPVarFloat(playerid, "rcZ", Z);
	SetPVarInt(playerid, "rcveh", vehicleid);
	SetPVarInt(playerid, "rccam", 1);
	IsPlayerEntering{playerid} = true;
	if(!PutPlayerInVehicle(playerid, vehicleid, 0))
	{
		IsPlayerEntering{playerid} = false;
		Craftsman_StopRCCam(playerid, false);
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Unable to use your RC Cam right now.");
	}
	SetPVarInt(playerid, "rccamtimer", SetTimerEx("rccam", 60000, false, "ii", playerid, g_arrQueryHandle[playerid]));
	PlayerInfo[playerid][pRccam]--;
	format(string, sizeof(string), "* %s places something on the ground.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	return 1;
}

CMD:firstaid(playerid, params[])
{
	if(HungerPlayerInfo[playerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   You cannot do this while being in the Hunger Games Event!");
	if(GetPVarType(playerid, "IsInArena"))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this while being in an arena!");
		return 1;
	}
	if(GetPVarInt(playerid, "Injured") == 1)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now.");
		return 1;
	}
	if(PlayerInfo[playerid][pFirstaid] > 0)
	{
		if(GetPVarInt(playerid, "usingfirstaid") == 0)
		{
			new string[128];
			PlayerInfo[playerid][pFirstaid]--;
			SetPVarInt(playerid, "firstaid5", SetTimerEx("firstaid5", 5000, true, "ii", playerid, g_arrQueryHandle[playerid]));
			SetPVarInt(playerid, "firstaidexpire", SetTimerEx("firstaidexpire", 10*60000, false, "ii", playerid, g_arrQueryHandle[playerid]));
			SetPVarInt(playerid, "usingfirstaid", 1);
			format(string, sizeof(string), "* %s uses a first aid kit.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "You're already using first aid!");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have a first aid kit!");
	}
	return 1;
}

CMD:sweep(playerid, params[])
{
	if(PlayerInfo[playerid][pSweep] > 0)
	{
		if(PlayerInfo[playerid][pSweepLeft] > 0)
		{
			new string[128], giveplayerid;
			if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /sweep [player]");

			if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Invalid player specified.");
			new Float:X, Float:Y, Float:Z;
			GetPlayerPos(giveplayerid, X, Y, Z);
			if((Spectating[giveplayerid] != 0 && PlayerInfo[playerid][pAdmin] < 2)
				|| GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(giveplayerid) || GetPlayerInterior(playerid) != GetPlayerInterior(giveplayerid)
				|| !IsPlayerInRangeOfPoint(playerid, 4.0, X, Y, Z)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be close to the person.");
			
			PlayerInfo[playerid][pSweepLeft]--;
			format(string, sizeof(string), "* %s sweeps a large wand around %s's body...", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			if(PlayerInfo[giveplayerid][pBugged] != INVALID_GROUP_ID)
			{
				format(string, sizeof(string), "* A small spark is seen as the bug on %s shorts out.", GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				format(string, sizeof(string), "(bug) %s: *static*", GetPlayerNameEx(giveplayerid));
				SendBugMessage(giveplayerid, PlayerInfo[giveplayerid][pBugged], string);
				PlayerInfo[giveplayerid][pBugged] = INVALID_GROUP_ID;
			}
			else
			{
				ProxDetector(30.0, playerid, "Nothing happens.", COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Your Bug Sweeper has ran out of batteries!");
			PlayerInfo[playerid][pSweep]--;
			PlayerInfo[playerid][pSweepLeft] = 3;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have a bug sweep!");
	}
	return 1;
}

CMD:gps(playerid, params[])
{
	if(PlayerInfo[playerid][pGPS] > 0)
	{
		new string[128];
		if(GetPVarInt(playerid, "gpsonoff") == 0)
		{
			format(string, sizeof(string), "* %s turns on their GPS.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "gpsonoff", 1);
			PlayerTextDrawSetString(playerid, GPS[playerid], "Loading...");
			PlayerTextDrawShow(playerid, GPS[playerid]);
		}
		else
		{
			format(string, sizeof(string), "* %s turns off their GPS.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			DeletePVar(playerid, "gpsonoff");
			PlayerTextDrawHide(playerid, GPS[playerid]);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have a GPS!");
	}
	return 1;
}



alias:wristwatch("ww")
CMD:wristwatch(playerid, params[])
{
	if(PlayerInfo[playerid][pWristwatch] > 0)
	{
		new string[128];
		if(GetPVarInt(playerid, "wristwatchonoff") == 0)
		{
			SetPVarInt(playerid, "wristwatchonoff", 1);
			TextDrawShowForPlayer(playerid, WristWatch);
			format(string, sizeof(string), "* %s turns on their wristwatch.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			KillTimer(GetPVarInt(playerid, "wristwatchtimer"));
			TextDrawHideForPlayer(playerid, WristWatch);
			DeletePVar(playerid, "wristwatchonoff");
			format(string, sizeof(string), "* %s turns off their wristwatch.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have a wristwatch!");
	}
	return 1;
}

CMD:receiver(playerid, params[])
{
	if(PlayerInfo[playerid][pReceiver] > 0)
	{
		if(!GetPVarType(playerid, "pReceiverOn"))
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "You've turned on your receiver.");
			SetPVarInt(playerid, "pReceiverOn", 1);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "You've turned off your receiver.");
			DeletePVar(playerid, "pReceiverOn");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have a receiver.");
	}
	return 1;
}

CMD:smslog(playerid, params[])
{
	if(PlayerInfo[playerid][pSmslog] > 0) GetSMSLog(playerid);
	else return SendClientMessageEx(playerid, COLOR_YELLOW, "    You don't have a SMS log!");
	return 1;
}

CMD:craft(playerid, params[])
{
	if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now, you are in an arena!");
	if(HungerPlayerInfo[playerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   You cannot do this while being in the Hunger Games Event!");
	if (PlayerInfo[playerid][pJob] != 18 && PlayerInfo[playerid][pJob2] != 18 && PlayerInfo[playerid][pJob3] != 18)
	{
		SendClientMessageEx(playerid,COLOR_GREY,"   You are not a Craftsman!");
		return 1;
	}
	if (PlayerInfo[playerid][pJailTime] > 0)
	{
		SendClientMessageEx(playerid,COLOR_GREY,"   You can not make things while in jail or prison!");
		return 1;
	}
	new string[128];
	if (GetPVarInt(playerid, "ArmsTimer") > 0)
	{
		SendClientMessageEx(playerid,COLOR_GREY,"   You must wait %d seconds before crafting again.", GetPVarInt(playerid, "ArmsTimer"));
		return 1;
	}
	if(PlayerInfo[playerid][pHospital] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "You can't craft while in the Hospital.");
		return 1;
	}
	new giveplayerid, choice[32], weapon, price;
	if(sscanf(params, "us[32]", giveplayerid, choice))
	{
		SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
		SendClientMessageEx(playerid, COLOR_YELLOW, "<< Available crafts >>");
		SendClientMessageEx(playerid, COLOR_GRAD1, "screwdriver(1,000)	 smslog(2,000)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "wristwatch(500)	 surveillance(8,000)");
		SendClientMessageEx(playerid, COLOR_GRAD1, "tire(250)	         lock(500)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "firstaid(1,000)	 camera(250)");
		SendClientMessageEx(playerid, COLOR_GRAD1, "rccam(8,000)	     receiver(5,000)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "gps(1,000)          bugsweep(10,000)");
		//SendClientMessageEx(playerid, COLOR_GRAD1, "parachute(50)          bag(6000)");
		SendClientMessageEx(playerid, COLOR_GRAD1, "parachute(50)		mailbox(15,000)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "metaldetector(12,500) syringe(500)");
		SendClientMessageEx(playerid, COLOR_GRAD1, "closet(3,000)		toolbox(12,000)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "crowbar(7,000)      flowers(25)");
		SendClientMessageEx(playerid, COLOR_GRAD1, "knuckles(100)        baseballbat(100)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "cane (100)           shovel(100)");
		SendClientMessageEx(playerid, COLOR_GRAD1, "poolcue (100)        katana(300)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "dildo (300)          spraycan(2000)");
		SendClientMessageEx(playerid, COLOR_GRAD2, "rimkit (400000)");
		SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
		SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /craft [player] [craftname]");
		return 1;
	}
	if(IsPlayerConnected(giveplayerid))
	{
		if(HungerPlayerInfo[giveplayerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   This person is not able to receive anything at the moment.");
		enum eCraftRecipe { craftRecipeName[16], craftRecipeMats };
		static const recipes[][eCraftRecipe] = {
			{"screwdriver", 1000},
			{"smslog", 2000},
			{"wristwatch", 500},
			{"surveillance", 8000},
			{"tire", 250},
			{"lock", 500},
			{"firstaid", 1000},
			{"camera", 250},
			{"rccam", 8000},
			{"receiver", 5000},
			{"gps", 1000},
			{"bugsweep", 10000},
			{"parachute", 50},
			{"metaldetector", 12500},
			{"mailbox", 15000},
			{"syringe", 500},
			{"closet", 3000},
			{"toolbox", 12000},
			{"crowbar", 7000},
			{"flowers", 25},
			{"knuckles", 100},
			{"baseballbat", 100},
			{"cane", 100},
			{"shovel", 100},
			{"poolcue", 100},
			{"katana", 300},
			{"dildo", 300},
			{"spraycan", 2000},
			{"rimkit", 400000}
		};
		for(new i; i < sizeof(recipes); ++i)
		{
			if(strcmp(choice, recipes[i][craftRecipeName], true) != 0) continue;
			weapon = i + 1;
			price = recipes[i][craftRecipeMats];
			break;
		}
		if(!weapon) return SendClientMessageEx(playerid, COLOR_GREY, "   Invalid Craft name!");
		if(weapon == 14) return SendClientMessageEx(playerid, COLOR_WHITE, "You cannot craft this right now!");
		if(PlayerInfo[playerid][pMats] < price) return SendClientMessageEx(playerid, COLOR_GREY, "   Not enough Materials for that!");
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(giveplayerid, X, Y, Z);
		if((Spectating[giveplayerid] == 0 || PlayerInfo[playerid][pAdmin] >= 2)
			&& GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(giveplayerid) && GetPlayerInterior(playerid) == GetPlayerInterior(giveplayerid)
			&& IsPlayerInRangeOfPoint(playerid, 5.0, X, Y, Z))
		{
			if(weapon == 17)
			{
				if(PlayerInfo[giveplayerid][pPhousekey] == INVALID_HOUSE_ID && PlayerInfo[giveplayerid][pPhousekey2] == INVALID_HOUSE_ID && PlayerInfo[giveplayerid][pPhousekey3] == INVALID_HOUSE_ID)
				{
					if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "You don't own a house!");
					else
					{
						SendClientMessageEx(playerid, COLOR_GREY, "They don't own a house!");
						SendClientMessageEx(giveplayerid, COLOR_GREY, "You don't own a house!");
						return 1;
					}
				}
			}
			if(giveplayerid == playerid)
			{
				if(weapon != 16 && weapon != 17)
				{
					PlayerInfo[playerid][pMats] -= price;
				}

				switch(weapon)
				{
				case 1:
					{
						PlayerInfo[playerid][pScrewdriver]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/sellgun");
					}
				case 2:
					{
						PlayerInfo[playerid][pSmslog]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/smslog");
					}
				case 3:
					{
						PlayerInfo[playerid][pWristwatch]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/wristwatch");
					}
				case 4:
					{
						PlayerInfo[playerid][pSurveillance]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/(p)lace(c)amera /(s)ee(c)amera /(d)estroy(c)amera");
					}
				case 5:
					{
						PlayerInfo[playerid][pTire]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/repair");
					}
				case 6:
					{
						PlayerInfo[playerid][pLock]=1;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/lock");
					}
				case 7:
					{
						PlayerInfo[playerid][pFirstaid]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/firstaid");
					}
				case 8:
					{
						GivePlayerValidWeapon(playerid, 43);
					}
				case 9:
					{
						PlayerInfo[playerid][pRccam]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/rccam");
					}
				case 10:
					{
						PlayerInfo[playerid][pReceiver]++;
						SetPVarInt(playerid, "pReceiverMLeft", 4);
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "You will receive the next four department radio messages.");
					}
				case 11:
					{
						PlayerInfo[playerid][pGPS] = 1;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/gps");
					}
				case 12:
					{
						PlayerInfo[playerid][pSweep]++;
						PlayerInfo[playerid][pSweepLeft] = 3;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/sweep");
					}
				case 13:
					{
						GivePlayerValidWeapon(playerid, 46);
					}
				case 14:
					{
						if(PlayerInfo[playerid][pTreasureSkill] >=0 && PlayerInfo[playerid][pTreasureSkill] <= 24) PlayerInfo[playerid][pMetalDetector] += 25;
						else if(PlayerInfo[playerid][pTreasureSkill] >=25 && PlayerInfo[playerid][pTreasureSkill] <= 149) PlayerInfo[playerid][pMetalDetector] += 50;
						else if(PlayerInfo[playerid][pTreasureSkill] >=150 && PlayerInfo[playerid][pTreasureSkill] <= 299) PlayerInfo[playerid][pMetalDetector] += 75;
						else if(PlayerInfo[playerid][pTreasureSkill] >=300 && PlayerInfo[playerid][pTreasureSkill] <= 599) PlayerInfo[playerid][pMetalDetector] += 100;
						else if(PlayerInfo[playerid][pTreasureSkill] >=600) PlayerInfo[playerid][pMetalDetector] += 125;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/search");
					}
				case 15:
					{
						PlayerInfo[playerid][pMailbox]++;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Type /placemailbox where you want mailbox to be at.");
					}
				case 16:
					{
						if(PlayerInfo[playerid][pSyringes] < 3)
						{
							PlayerInfo[playerid][pMats] -= price;
							PlayerInfo[playerid][pSyringes]++;
							SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/usedrug heroin");
						}
						else
						{
							return SendClientMessageEx(playerid, COLOR_GREY, "You can't hold anymore syringes.");
						}
					}
				case 17:
					{
						new closet = INVALID_HOUSE_ID;
						new pInfo:keys[] = {pPhousekey, pPhousekey2, pPhousekey3};
						for(new i; i < sizeof(keys); ++i)
						{
							new houseid = PlayerInfo[playerid][keys[i]];
							if(!(0 <= houseid < MAX_HOUSES)) continue;
							if(HouseInfo[houseid][hOwnerID] != GetPlayerSQLId(playerid) || gHouseSaleUncertain[houseid]) continue;
							if(GetPlayerVirtualWorld(playerid) != HouseInfo[houseid][hIntVW] || GetPlayerInterior(playerid) != HouseInfo[houseid][hIntIW]) continue;
							if(!IsPlayerInRangeOfPoint(playerid, 50.0, HouseInfo[houseid][hInteriorX], HouseInfo[houseid][hInteriorY], HouseInfo[houseid][hInteriorZ])) continue;
							closet = houseid;
							break;
						}
						if(closet == INVALID_HOUSE_ID) return SendClientMessageEx(playerid, COLOR_GREY, "You aren't inside of your house!");
						GetPlayerPos(playerid, HouseInfo[closet][hClosetX], HouseInfo[closet][hClosetY], HouseInfo[closet][hClosetZ]);
						if(IsValidDynamic3DTextLabel(HouseInfo[closet][hClosetTextID])) DestroyDynamic3DTextLabel(HouseInfo[closet][hClosetTextID]);
						HouseInfo[closet][hClosetTextID] = CreateDynamic3DTextLabel("Closet\n/closet to use", 0xFFFFFF88, HouseInfo[closet][hClosetX], HouseInfo[closet][hClosetY], HouseInfo[closet][hClosetZ] + 0.5, 10.0, .testlos = 1, .worldid = HouseInfo[closet][hIntVW], .interiorid = HouseInfo[closet][hIntIW], .streamdistance = 10.0);
						SaveHouse(closet);
						PlayerInfo[playerid][pMats] -= price;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "/closet(add/remove)");
						format(szMiscArray, sizeof(szMiscArray), "%s(%d) has placed a closet for their house (House ID: %d) at X: %f | Y: %f | Z: %f", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), closet, HouseInfo[closet][hClosetX], HouseInfo[closet][hClosetY], HouseInfo[closet][hClosetZ]);
						Log("logs/house.log", szMiscArray);
					}
				case 18:
					{
						PlayerInfo[playerid][pToolBox] += 15;
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Type /pickveh(icle) in any car to attempt to lock pick it.");
					}
				case 19:
					{
						PlayerInfo[playerid][pCrowBar] += 25;
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Type /cracktrunk in any car that you already lock picked to attempt to open the trunk.");
					}
				case 20: GivePlayerValidWeapon(playerid, WEAPON_FLOWER);
				case 21: GivePlayerValidWeapon(playerid, WEAPON_BRASSKNUCKLE);
				case 22: GivePlayerValidWeapon(playerid, WEAPON_BAT);
				case 23: GivePlayerValidWeapon(playerid, WEAPON_CANE);
				case 24: GivePlayerValidWeapon(playerid, WEAPON_SHOVEL);	
				case 25: GivePlayerValidWeapon(playerid, WEAPON_POOLSTICK);
				case 26: GivePlayerValidWeapon(playerid, WEAPON_KATANA);
				case 27: GivePlayerValidWeapon(playerid, WEAPON_DILDO);
				case 28: GivePlayerValidWeapon(playerid, WEAPON_SPRAYCAN);
				case 29: {
					PlayerInfo[playerid][pRimMod]++;
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Type /userimkit as a mechanic in any car to modify your rims.");
				}
				
				}
				SendClientMessageEx(playerid, COLOR_GRAD1, "   You have given yourself a %s.", choice);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
				switch( PlayerInfo[playerid][pSex] )
				{
					case 1: format(string, sizeof(string), "* %s created something from Materials, and hands it to himself.", GetPlayerNameEx(playerid));
					case 2: format(string, sizeof(string), "* %s created something from Materials, and hands it to herself.", GetPlayerNameEx(playerid));
				}
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* You offered %s to buy a %s.", GetPlayerNameEx(giveplayerid), choice);
			SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Craftsman %s wants to sell you a %s, (type /accept craft) to buy.", GetPlayerNameEx(playerid), choice);
			CraftOffer[giveplayerid] = playerid;
			SetPVarInt(giveplayerid, "CraftOfferSession", g_arrQueryHandle[playerid]);
			CraftId[giveplayerid] = weapon;
			CraftMats[giveplayerid] = price;
			format(CraftName[giveplayerid], 50, "%s", choice);
			if(PlayerInfo[playerid][pAdmin] < 3)
			{
				SetPVarInt(playerid, "ArmsTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_ARMSTIMER);
			}
			return 1;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "That person isn't near you.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Invalid player specified.");
		return 1;
	}
}
