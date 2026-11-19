/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Dynamic Gates System

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

#include <YSI_Coding\y_hooks>

stock bool:IsGateLoaded(gateid)
{
	return 0 <= gateid < MAX_GATES && GateLoaded[gateid];
}

stock bool:IsGateActive(gateid)
{
	return IsGateLoaded(gateid) && Iter_Contains(ActiveGates, gateid) && IsValidDynamicObject(GateInfo[gateid][gGATE]);
}

stock bool:IsPlayerNearGate(playerid, gateid, Float:range = -1.0)
{
	if(!IsGateActive(gateid) || GetPlayerVirtualWorld(playerid) != GateInfo[gateid][gVW] || GetPlayerInterior(playerid) != GateInfo[gateid][gInt]) 
	{
		return false;
	}

	new Float:x, Float:y, Float:z;
	if(!GetDynamicObjectPos(GateInfo[gateid][gGATE], x, y, z)) return false;
	if(range < 0.0) range = GateInfo[gateid][gRange];
	return IsPlayerInRangeOfPoint(playerid, range, x, y, z);
}

stock bool:HasGateGroupAccess(playerid, gateid)
{
	new groupid = PlayerInfo[playerid][pMember];
	if(!(0 <= groupid < MAX_GROUPS)) return false;
	if(GateInfo[gateid][gGroupID] == groupid) return true;
	if(GateInfo[gateid][gAllegiance] == 0 && GateInfo[gateid][gGroupType] == 0) return false;
	
	return (GateInfo[gateid][gAllegiance] == 0 || GateInfo[gateid][gAllegiance] == arrGroupData[groupid][g_iAllegiance])
		&& (GateInfo[gateid][gGroupType] == 0 || GateInfo[gateid][gGroupType] == arrGroupData[groupid][g_iGroupType]);
}

stock bool:IsGateHeldOpen(gateid)
{
	new facility = GateInfo[gateid][gFacility];
	return 0 <= facility < MAX_CRATE_FACILITY && (AdminOpened[facility]
		|| (CrateFacility[facility][cfRaidable] && CrateFacility[facility][cfRaidTimer] > 0));
}

stock CancelGateTimer(gateid)
{
	if(GateCloseTimer[gateid]) KillTimer(GateCloseTimer[gateid]);
	GateCloseTimer[gateid] = 0;
	++GateRevision[gateid];
}

stock ClearGateEditor(playerid)
{
	new gateid = GetPVarInt(playerid, "EditingGateID");
	if(GetPVarType(playerid, "EditingGateID") && 0 <= gateid < MAX_GATES && GateEditor[gateid] == playerid + 1)
	{
		GateEditor[gateid] = 0;
	}
	DeletePVar(playerid, "gEdit");
	DeletePVar(playerid, "EditingGateID");
	DeletePVar(playerid, "GateEditRevision");
}

stock GetGateHoldTime(gateid)
{
	switch(GateInfo[gateid][gTimer])
	{
		case 1: return 3000;
		case 2: return 5000;
		case 3: return 8000;
		case 4: return 10000;
	}
	return 0;
}

CMD:gate(playerid, params[])
{
	foreach(new gateid : ActiveGates)
	{
		if(!HasGateGroupAccess(playerid, gateid) || !IsPlayerNearGate(playerid, gateid)) 
		{
			continue;
		}

		if(GateInfo[gateid][gLocked]) 
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "This gate is currently locked.");
		}
		
		if(!GateInfo[gateid][gAutomate]) MoveGate(playerid, gateid);
	}
	return 1;
}

CMD:agate(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use that command.");
	foreach(new gateid : ActiveGates)
	{
		if(IsPlayerNearGate(playerid, gateid, 15.0)) MoveGate(playerid, gateid);
	}
	return 1;
}

CMD:gsave(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
        SendClientMessageEx(playerid, COLOR_YELLOW, "You have force saved the Gate database.");
        SaveGates();
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
    }
    return 1;
}



alias:movegate("hgate")
CMD:movegate(playerid, params[])
{
	if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /movegate [pass]");
	foreach(new gateid : ActiveGates)
	{
		if(GateInfo[gateid][gGroupID] != INVALID_GROUP_ID || !IsPlayerNearGate(playerid, gateid)) continue;
		if(strcmp(params, GateInfo[gateid][gPass], true)) continue;
		if(GateInfo[gateid][gLocked]) 
			return SendClientMessageEx(playerid, COLOR_GREY, "This gate is currently locked.");
		
		if(!GateInfo[gateid][gAutomate]) MoveGate(playerid, gateid);
	}
	return 1;
}

CMD:admingatepw(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pShopTech] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use that command.");
	
	new gateid, pass[128];
	if(sscanf(params, "ds[128]", gateid, pass)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /admingatepw [gateid] [pass]");
	
	if(!IsGateActive(gateid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Invalid or unconfigured gate ID.");
	
	if(strlen(pass) > 23) 
		return SendClientMessageEx(playerid, COLOR_GREY, "The password must contain at most 23 characters.");
	
	format(GateInfo[gateid][gPass], 24, "%s", pass);
	SaveGate(gateid);
	return SendClientMessageEx(playerid, COLOR_WHITE, "Password updated for gate %d.", gateid);
}

CMD:housegatepw(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_GREY, "/housegatepw has been changed to /setgatepass!");
	return 1;
}

CMD:setgatepass(playerid, params[])
{
	if(isnull(params))
	 	return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /setgatepass [pass]");
	
	if(strlen(params) > 23) 
		return SendClientMessageEx(playerid, COLOR_GREY, "The password must contain at most 23 characters.");
	
	foreach(new gateid : ActiveGates)
	{
		new houseid = GateInfo[gateid][gHID];
		if(GateInfo[gateid][gGroupID] != INVALID_GROUP_ID || !(0 <= houseid < MAX_HOUSES)) continue;
		if(HouseInfo[houseid][hOwnerID] != GetPlayerSQLId(playerid) || !IsPlayerNearGate(playerid, gateid)) continue;
		format(GateInfo[gateid][gPass], 24, "%s", params);
		SaveGate(gateid);
		return SendClientMessageEx(playerid, COLOR_WHITE, "Password updated for house gate %d.", gateid);
	}
	return SendClientMessageEx(playerid, COLOR_GREY, "You are not near a gate that you own.");
}

CMD:lockgate(playerid, params[])
{
	foreach(new gateid : ActiveGates)
	{
		if(!IsPlayerNearGate(playerid, gateid)) continue;
		new houseid = GateInfo[gateid][gHID], groupid = GateInfo[gateid][gGroupID];
		new bool:allowed = GateInfo[gateid][gGroupType] != 0 && PlayerInfo[playerid][pFactionModerator] >= 1;
		if(0 <= groupid < MAX_GROUPS) 
		{
			allowed = allowed || PlayerInfo[playerid][pLeader] == groupid;
		}
		else if(groupid == INVALID_GROUP_ID && 0 <= houseid < MAX_HOUSES)
		{
			allowed = allowed || HouseInfo[houseid][hOwnerID] == GetPlayerSQLId(playerid);
		}

		if(!allowed) continue;
		GateInfo[gateid][gLocked] = !GateInfo[gateid][gLocked];
		SaveGate(gateid);
		new message[128];
		format(message, sizeof(message), "* %s has %s the gate.", GetPlayerNameEx(playerid), GateInfo[gateid][gLocked] ? ("locked") : ("unlocked"));
		ProxDetector(GateInfo[gateid][gRange], playerid, message, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
		format(message, sizeof(message), "%s(%d) has %s gate ID %d.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GateInfo[gateid][gLocked] ? ("locked") : ("unlocked"), gateid);
		Log("logs/gedit.log", message);
	}
	return 1;
}

CMD:gotogate(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		new gatenum;
		if(sscanf(params, "d", gatenum)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /gotogate [gatenumber]");

		if(!IsGateActive(gatenum))
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "Invalid or unconfigured gate ID.");
		}

		SetPlayerPos(playerid,GateInfo[gatenum][gPosX],GateInfo[gatenum][gPosY],GateInfo[gatenum][gPosZ] + 1);
		GameTextForPlayer(playerid, "~w~Teleporting", 5000, 1);
		SetPlayerInterior(playerid, GateInfo[gatenum][gInt]);
		PlayerInfo[playerid][pInt] = GateInfo[gatenum][gInt];
		SetPlayerVirtualWorld(playerid,  GateInfo[gatenum][gVW]);
		PlayerInfo[playerid][pVW] =  GateInfo[gatenum][gVW];
	}
	return 1;
}

CMD:gstatus(playerid, params[])
{
	new gateid;
	if(sscanf(params, "i", gateid))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /gstatus [gateid]");
		return 1;
	}
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		if(!IsGateLoaded(gateid)) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid or unloaded gate ID.");
		new timertxt = GetGateHoldTime(gateid) / 1000, distancetxt;

		switch(GateInfo[gateid][gRenderHQ])
		{
			case 1: distancetxt = 100;
			case 2: distancetxt = 150;
			case 3: distancetxt = 200;
			default: distancetxt = 60;
		}

		SendClientMessageEx(playerid, COLOR_GREEN, "|___________ Gate Status (ID: %d) ___________|", gateid);
		SendClientMessageEx(playerid, COLOR_WHITE, "Closed: %.2f, %.2f, %.2f m | Rotation: %.2f, %.2f, %.2f deg", GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ], GateInfo[gateid][gRotX], GateInfo[gateid][gRotY], GateInfo[gateid][gRotZ]);
		SendClientMessageEx(playerid, COLOR_WHITE, "Open: %.2f, %.2f, %.2f m | Rotation: %.2f, %.2f, %.2f deg", GateInfo[gateid][gPosXM], GateInfo[gateid][gPosYM], GateInfo[gateid][gPosZM], GateInfo[gateid][gRotXM], GateInfo[gateid][gRotYM], GateInfo[gateid][gRotZM]);
		SendClientMessageEx(playerid, COLOR_WHITE, "Model: %d | HID: %d | VW: %d | Int: %d | Allegiance: %d | Group Type: %d | Group: %d", GateInfo[gateid][gModel], GateInfo[gateid][gHID], GateInfo[gateid][gVW], GateInfo[gateid][gInt], GateInfo[gateid][gAllegiance], GateInfo[gateid][gGroupType], GateInfo[gateid][gGroupID]);
		SendClientMessageEx(playerid, COLOR_WHITE, "Range: %.2f m | Speed: %.2f m/s | Timer: %d second(s) | Stream: %d | Automated: %d | Locked: %d", GateInfo[gateid][gRange], GateInfo[gateid][gSpeed], timertxt, distancetxt, GateInfo[gateid][gAutomate], GateInfo[gateid][gLocked]);
		SendClientMessageEx(playerid, COLOR_WHITE, "Assigned Facility: %d", GateInfo[gateid][gFacility]);
		if(GateInfo[gateid][gTModel] != INVALID_OBJECT_ID)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Texture index: %d | Model: %d | Color: %x", GateInfo[gateid][gTIndex], GateInfo[gateid][gTModel], GateInfo[gateid][gTColor]);
			SendClientMessageEx(playerid, COLOR_WHITE, "TXD file: %s", GateInfo[gateid][gTTXD]);
			SendClientMessageEx(playerid, COLOR_WHITE, "Texture: %s", GateInfo[gateid][gTTexture]);
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
	return 1;
}

CMD:gnear(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pShopTech] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use that command.");
	
	new world = GetPlayerVirtualWorld(playerid), Float:x, Float:y, Float:z;
	if(!isnull(params) && sscanf(params, "d", world)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /gnear [world, -1 = all worlds]");
	
	SendClientMessageEx(playerid, COLOR_WHITE, "Gates within 30 m in world %d:", world);
	foreach(new gateid : ActiveGates)
	{
		if(world != -1 && GateInfo[gateid][gVW] != world) continue;
		if(isnull(params) && GetPlayerInterior(playerid) != GateInfo[gateid][gInt]) continue;
		if(!GetDynamicObjectPos(GateInfo[gateid][gGATE], x, y, z) || !IsPlayerInRangeOfPoint(playerid, 30.0, x, y, z)) continue;
		SendClientMessageEx(playerid, COLOR_WHITE, "Gate %d | VW: %d | Interior: %d | %.1f m", gateid, GateInfo[gateid][gVW], GateInfo[gateid][gInt], GetPlayerDistanceFromPoint(playerid, x, y, z));
	}
	return 1;
}

CMD:gnext(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pShopTech] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use that command.");
	
	for(new gateid; gateid < MAX_GATES; ++gateid)
	{
		if(IsGateLoaded(gateid) && (GateInfo[gateid][gModel] == 0 || (GateInfo[gateid][gPosX] == 0.0 && GateInfo[gateid][gPosY] == 0.0 && GateInfo[gateid][gPosZ] == 0.0)))
		{
			return SendClientMessageEx(playerid, COLOR_WHITE, "Gate %d is available to use.", gateid);
		}
	}
	return SendClientMessageEx(playerid, COLOR_GREY, "No empty gate rows are available.");
}

CMD:gedit(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		new x_job[128], gateid, Float:ofloat, string[128], input[64];

		if(sscanf(params, "s[128]iS()[64]", x_job, gateid, input))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /gedit [name] [gateid] [value]");
			SendClientMessageEx(playerid, COLOR_GREY, "Available names: HID, Model, VW, Int, Open, Closed, PosX(M), PosY(M), PosZ(M), RotX(M), RotZ(M), ToMe(M)");
			SendClientMessageEx(playerid, COLOR_GREY, "Available names: Range, Speed, Allegiance, GroupType, GroupID, Stream, Timer, Facility");
			return 1;
		}

		if(!IsGateLoaded(gateid)) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid or unloaded gate ID.");
		if(GateEditor[gateid]) return SendClientMessageEx(playerid, COLOR_GREY, "This gate is being edited.");
		if(!strcmp(x_job, "range", true)
			|| !strcmp(x_job, "speed", true)
			|| !strcmp(x_job, "posx", true)
			|| !strcmp(x_job, "posy", true)
			|| !strcmp(x_job, "posz", true)
			|| !strcmp(x_job, "posxm", true)
			|| !strcmp(x_job, "posym", true)
			|| !strcmp(x_job, "poszm", true)
			|| !strcmp(x_job, "rotx", true)
			|| !strcmp(x_job, "roty", true)
			|| !strcmp(x_job, "rotz", true)
			|| !strcmp(x_job, "rotxm", true)
			|| !strcmp(x_job, "rotym", true)
			|| !strcmp(x_job, "rotzm", true))
		{
			if(sscanf(input, "f", ofloat)) return SendClientMessageEx(playerid, COLOR_GREY, "A numeric value is required.");
			if(!(-20000.0 <= ofloat <= 20000.0)) return SendClientMessageEx(playerid, COLOR_GREY, "Value must be between -20000 and 20000.");
		}

		if(strcmp(x_job, "hid", true) == 0)
		{
			new value;
			if(sscanf(input, "d", value) || !(-1 <= value < MAX_HOUSES)) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid hid value.");

		    GateInfo[gateid][gHID] = value;
		    SendClientMessageEx(playerid, COLOR_WHITE, "HID %d assigned to Gate %d", GateInfo[gateid][gHID], gateid);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's House ID to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "model", true) == 0)
		{
		    new value;
			if(sscanf(input, "d", value) || !(value == 0 || (0 < value < 20000) || IsValidCustomModel(value))) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid model value.");

			if(value == 0)
			{
				DeleteGate(gateid, playerid);
				return SendClientMessageEx(playerid, COLOR_WHITE, "Gate %d has been deleted.", gateid);
			}

		    GateInfo[gateid][gModel] = value;
		    format(string, sizeof(string), "Model %d assigned to Gate %d", GateInfo[gateid][gModel], gateid);
            CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's Model to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "vw", true) == 0)
		{
		    new value;
			if(sscanf(input, "d", value) || !(value >= 0)) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid vw value.");
		    GateInfo[gateid][gVW] = value;
		    format(string, sizeof(string), "Virtual World %d assigned to Gate %d", GateInfo[gateid][gVW], gateid);
            CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's VW to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "int", true) == 0)
		{
		    new value;
			if(sscanf(input, "d", value) || !(0 <= value <= 255)) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid int value.");
		    GateInfo[gateid][gInt] = value;
		    format(string, sizeof(string), "Interior %d assigned to Gate %d", GateInfo[gateid][gInt], gateid);
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's InteriorID to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(!strcmp(x_job, "open", true) || !strcmp(x_job, "closed", true))
		{
			if(!IsGateActive(gateid)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Configure the gate model and closed position first.");
			
			if(IsGateHeldOpen(gateid)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "The facility is holding this gate open.");
			
			if(GetPVarType(playerid, "gEdit")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Finish editing your current gate first.");
			
			CancelGateTimer(gateid);
			StopDynamicObject(GateInfo[gateid][gGATE]);
			new bool:opening = !strcmp(x_job, "open", true);
			GateEditor[gateid] = playerid + 1;
			SetPVarInt(playerid, "gEdit", opening ? 1 : 2);
			SetPVarInt(playerid, "EditingGateID", gateid);
			SetPVarInt(playerid, "GateEditRevision", GateRevision[gateid]);
			if(opening && (GateInfo[gateid][gPosXM] != 0.0 || GateInfo[gateid][gPosYM] != 0.0 || GateInfo[gateid][gPosZM] != 0.0))
			{
				SetDynamicObjectPos(GateInfo[gateid][gGATE], GateInfo[gateid][gPosXM], GateInfo[gateid][gPosYM], GateInfo[gateid][gPosZM]);
				SetDynamicObjectRot(GateInfo[gateid][gGATE], GateInfo[gateid][gRotXM], GateInfo[gateid][gRotYM], GateInfo[gateid][gRotZM]);
			}
			else
			{
				SetDynamicObjectPos(GateInfo[gateid][gGATE], GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ]);
				SetDynamicObjectRot(GateInfo[gateid][gGATE], GateInfo[gateid][gRotX], GateInfo[gateid][gRotY], GateInfo[gateid][gRotZ]);
			}
			if(!EditDynamicObject(playerid, GateInfo[gateid][gGATE]))
			{
				ClearGateEditor(playerid);
				CreateGate(gateid);
				return SendClientMessageEx(playerid, COLOR_GREY, "Unable to start the gate editor.");
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Editing the %s position of gate %d.", opening ? ("open") : ("closed"), gateid);
		}
		else if(strcmp(x_job, "range", true) == 0)
		{
		    if(!(0.1 <= ofloat <= 300.0)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Range must be between 0.1 and 300 m.");
		    
			GateInfo[gateid][gRange] = ofloat;
		    SendClientMessageEx(playerid, COLOR_WHITE, "Range of %.3f assigned to Gate %d", GateInfo[gateid][gRange], gateid);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's Range to %.3f.", GetPlayerNameEx(playerid), gateid, ofloat);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "speed", true) == 0)
		{
		    if(!(0.1 <= ofloat <= 1000.0)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Speed must be between 0.1 and 1000 m/s.");
		    
			GateInfo[gateid][gSpeed] = ofloat;
		    CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "Speed of %.3f assigned to Gate %d", GateInfo[gateid][gSpeed], gateid);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's Speed to %.3f.", GetPlayerNameEx(playerid), gateid, ofloat);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "posx", true) == 0)
		{
		    GateInfo[gateid][gPosX] = ofloat;
		    format(string, sizeof(string), "PosX %f assigned to Gate %d", GateInfo[gateid][gPosX], gateid);
		    CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "posy", true) == 0)
		{
		    GateInfo[gateid][gPosY] = ofloat;
		    format(string, sizeof(string), "PosY %f assigned to Gate %d", GateInfo[gateid][gPosY], gateid);
		    CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "posz", true) == 0)
		{
			GateInfo[gateid][gPosZ] = ofloat;
		    format(string, sizeof(string), "PosZ %f assigned to Gate %d", GateInfo[gateid][gPosZ], gateid);
		    CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "posxm", true) == 0)
		{
		    GateInfo[gateid][gPosXM] = ofloat;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "PosXM %f assigned to Gate %d", GateInfo[gateid][gPosXM], gateid);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "posym", true) == 0)
		{
		    GateInfo[gateid][gPosYM] = ofloat;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "PosYM %f assigned to Gate %d", GateInfo[gateid][gPosYM], gateid);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "poszm", true) == 0)
		{
		    GateInfo[gateid][gPosZM] = ofloat;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "PosZM %f assigned to Gate %d", GateInfo[gateid][gPosZM], gateid);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "rotx", true) == 0)
		{
		    GateInfo[gateid][gRotX] = ofloat;
		    format(string, sizeof(string), "RotX %f assigned to Gate %d", GateInfo[gateid][gRotX], gateid);
		    CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "roty", true) == 0)
		{
		    GateInfo[gateid][gRotY] = ofloat;
		    format(string, sizeof(string), "RotY %f assigned to Gate %d", GateInfo[gateid][gRotY], gateid);
		    CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "rotz", true) == 0)
		{
			GateInfo[gateid][gRotZ] = ofloat;
		    format(string, sizeof(string), "RotZ %f assigned to Gate %d", GateInfo[gateid][gRotZ], gateid);
		    CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "rotxm", true) == 0)
		{
		    GateInfo[gateid][gRotXM] = ofloat;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "RotXM %f assigned to Gate %d", GateInfo[gateid][gRotXM], gateid);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "rotym", true) == 0)
		{
		    GateInfo[gateid][gRotYM] = ofloat;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "RotYM %f assigned to Gate %d", GateInfo[gateid][gRotYM], gateid);
		    SaveGate(gateid);
		}
		else if(strcmp(x_job, "rotzm", true) == 0)
		{
		    GateInfo[gateid][gRotZM] = ofloat;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "RotZM %f assigned to Gate %d", GateInfo[gateid][gRotZM], gateid);
		    SaveGate(gateid);
		}
        else if(strcmp(x_job, "tome", true) == 0)
		{
		    GetPlayerPos(playerid,GateInfo[gateid][gPosX],GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ]);
		    GateInfo[gateid][gVW] = GetPlayerVirtualWorld(playerid);
		    GateInfo[gateid][gInt] = GetPlayerInterior(playerid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "Gate %d Pos moved to %f %f %f, VW: %d INT: %d", gateid, GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ], GateInfo[gateid][gVW], GateInfo[gateid][gInt]);
		    if(GateInfo[gateid][gModel] == 0)
			{
			    GateInfo[gateid][gModel] = 18631;
			    GateInfo[gateid][gRange] = 10;
			    GateInfo[gateid][gSpeed] = 5.0;
			}
			CreateGate(gateid);
			SaveGate(gateid);

			format(string, sizeof(string), "%s has edited GateID %d's Position.", GetPlayerNameEx(playerid), gateid);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "tomem", true) == 0)
		{
		    GetPlayerPos(playerid,GateInfo[gateid][gPosXM],GateInfo[gateid][gPosYM], GateInfo[gateid][gPosZM]);
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "Gate %d PosM moved to %f %f %f", gateid, GateInfo[gateid][gPosXM], GateInfo[gateid][gPosYM], GateInfo[gateid][gPosZM]);
			SaveGate(gateid);

			format(string, sizeof(string), "%s has edited GateID %d's Moved Position.", GetPlayerNameEx(playerid), gateid);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "allegiance", true) == 0)
		{
		    new value;
			if(sscanf(input, "d", value) || !(0 <= value < MAX_GROUP_ALLEGIANCES)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Invalid allegiance value.");
		    GateInfo[gateid][gAllegiance] = value;

		    SendClientMessageEx(playerid, COLOR_WHITE, "Allegiance %d assigned to Gate %d", GateInfo[gateid][gAllegiance], gateid);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's Allegiance to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "grouptype", true) == 0)
		{
		    new value;
			if(sscanf(input, "d", value) || !(0 <= value < MAX_GROUP_TYPES)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Invalid grouptype value.");
		    
			GateInfo[gateid][gGroupType] = value;
		    SendClientMessageEx(playerid, COLOR_WHITE, "Group Type %d assigned to Gate %d", GateInfo[gateid][gGroupType], gateid);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's Group Type to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "groupid", true) == 0)
		{
		    new value;
			if(sscanf(input, "d", value) || !(-1 <= value < MAX_GROUPS)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Invalid groupid value.");
		    
			GateInfo[gateid][gGroupID] = value;
		    SendClientMessageEx(playerid, COLOR_WHITE, "Group ID %d assigned to Gate %d", GateInfo[gateid][gGroupID], gateid);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's Group ID to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "stream", true) == 0)
		{
		    new value;
			if(sscanf(input, "d", value) || !(0 <= value <= 3)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Invalid stream value.");
		    
			GateInfo[gateid][gRenderHQ] = value;
		    format(string, sizeof(string), "Stream distance %d assigned to Gate %d", GateInfo[gateid][gRenderHQ], gateid);
            CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's stream distance to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "timer", true) == 0)
		{
			new value;
			if(sscanf(input, "d", value) || !(0 <= value <= 4)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Invalid timer value.");
		    
			GateInfo[gateid][gTimer] = value;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "Timer %d assigned to Gate %d", GateInfo[gateid][gTimer], gateid);
		    SaveGate(gateid);

		    format(string, sizeof(string), "%s has edited GateID %d's timer to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else if(strcmp(x_job, "facility", true) == 0)
		{
			new value;
			if(sscanf(input, "d", value) || !(-1 <= value < MAX_CRATE_FACILITY)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Invalid facility value.");

		    GateInfo[gateid][gFacility] = value;
			CreateGate(gateid);
		    SendClientMessageEx(playerid, COLOR_WHITE, "Facility %d assigned to Gate %d", value, gateid);
		    SaveGate(gateid);
		    format(string, sizeof(string), "%s has edited GateID %d's assigned facility to %d.", GetPlayerNameEx(playerid), gateid, value);
		    Log("logs/gedit.log", string);
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Unknown gate option. Use /gedit for available options.");
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to use that command.");
		return 1;
	}
	return 1;
}

CMD:gedittexture(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pShopTech] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use that command.");
	
	new gateid, option[16], input[128], value;
	if(sscanf(params, "is[16]S()[128]", gateid, option, input))
		return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /gedittexture [gateid] [index/model/txd/texture/color/delete] [value]");
	
	if(!IsGateActive(gateid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Invalid or unconfigured gate ID.");
	
	if(GateEditor[gateid]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "This gate is being edited.");
	
	if(!strcmp(option, "delete", true))
	{
		GateInfo[gateid][gTIndex] = -1;
		GateInfo[gateid][gTModel] = INVALID_OBJECT_ID;
		GateInfo[gateid][gTTXD][0] = EOS;
		GateInfo[gateid][gTTexture][0] = EOS;
		GateInfo[gateid][gTColor] = 0;
	}
	else if(!strcmp(option, "index", true))
	{
		if(sscanf(input, "d", value) || !(0 <= value <= 15)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Material index must be between 0 and 15.");
		
		GateInfo[gateid][gTIndex] = value;
	}
	else if(!strcmp(option, "model", true))
	{
		if(sscanf(input, "d", value) || !(0 <= value < 20000)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Invalid texture model ID.");
		
		GateInfo[gateid][gTModel] = value;
		if(GateInfo[gateid][gTIndex] == -1) GateInfo[gateid][gTIndex] = 0;
	}
	else if(!strcmp(option, "txd", true) || !strcmp(option, "texture", true))
	{
		if(isnull(input) || strlen(input) > 63) 
			return SendClientMessageEx(playerid, COLOR_GREY, "A name of 1 to 63 characters is required.");
		
		if(!strcmp(option, "txd", true)) format(GateInfo[gateid][gTTXD], 64, "%s", input);
		else format(GateInfo[gateid][gTTexture], 64, "%s", input);
	}
	else if(!strcmp(option, "color", true))
	{
		if(isnull(input) || strlen(input) > 6 || !IsHex(input) || sscanf(input, "h", value))
			return SendClientMessageEx(playerid, COLOR_GREY, "Use an RGB hexadecimal color, for example BCA3FF.");
		
		GateInfo[gateid][gTColor] = value | 0xFF000000;
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Unknown texture option.");
	CreateGate(gateid);
	SaveGate(gateid);
	new message[192];
	format(message, sizeof(message), "%s has edited gate %d texture option %s.", GetPlayerNameEx(playerid), gateid, option);
	Log("logs/gedit.log", message);
	return SendClientMessageEx(playerid, COLOR_WHITE, "Texture updated for gate %d.", gateid);
}

CMD:listgates(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
	
	new hid;
	if(sscanf(params, "d", hid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /listgates [houseid]");
	
	if(!(0 <= hid < MAX_HOUSES))
	{
		return SendClientMessageEx(playerid, COLOR_GREY, "House ID must be between 0 and %d.", MAX_HOUSES - 1);
	}
	SendClientMessageEx(playerid, COLOR_WHITE, "Listing gates linked to house id: %d", hid);
	for(new i = 0; i < MAX_GATES; i++)
	{
		if(IsGateLoaded(i) && GateInfo[i][gHID] == hid)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "- %d", i);
		}
	}
	return 1;
}

CMD:gmove(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use this command.");
	
	new gateid, target, percent, minimum, fine;
	if(sscanf(params, "dudd", gateid, target, percent, minimum))
		return SendClientMessageEx(playerid, COLOR_WHITE, "USAGE: /gmove [gateid] [playerid] [fine percent 0-100, 0 = free] [minimum fine]");
	
	if(!IsGateActive(gateid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Invalid or unconfigured gate ID.");
	
	if(GateEditor[gateid]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "This gate is being edited.");
	
	if(!(0 <= target < MAX_PLAYERS) || !IsPlayerConnected(target) || !gPlayerLogged{target})
		return SendClientMessageEx(playerid, COLOR_GREY, "That player is not logged in.");
	
	if(GetPVarInt(target, "FurniturePurchaseUncertain"))
		return SendClientMessageEx(playerid, COLOR_GREY, "That player's account is awaiting a furniture purchase result.");
	
	if(!CalculatePropertyMoveFine(target, percent, minimum, fine))
		return SendClientMessageEx(playerid, COLOR_GREY, "Invalid fee or the calculated fine exceeds the supported money range.");
	
	GetPlayerPos(playerid, GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ]);
	GateInfo[gateid][gVW] = GetPlayerVirtualWorld(playerid);
	GateInfo[gateid][gInt] = GetPlayerInterior(playerid);
	CreateGate(gateid);
	SaveGate(gateid);
	new message[192];
	format(message, sizeof(message), "%s has edited gate %d's closed position.", GetPlayerNameEx(playerid), gateid);
	Log("logs/gedit.log", message);
	SendClientMessageEx(playerid, COLOR_WHITE, "Moved gate %d's closed position.", gateid);
	if(fine > 0)
	{
		GivePlayerCashEx(target, TYPE_ONHAND, -fine);
		format(message, sizeof(message), "AdmCmd: %s(%d) was fined $%s by %s, reason: Dynamic Gate Move", GetPlayerNameEx(target), GetPlayerSQLId(target), number_format(fine), GetPlayerNameEx(playerid));
		Log("logs/admin.log", message);
		SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s was fined $%s by %s, reason: Dynamic Gate Move", GetPlayerNameEx(target), number_format(fine), GetPlayerNameEx(playerid));
	}
	return 1;
}

CMD:reloadgate(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
	
	new gateid;
	if(sscanf(params, "d", gateid)) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "USAGE: /reloadgate <gateid>");
	
	if(!IsGateLoaded(gateid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Invalid or unloaded gate ID.");
	
	CreateGate(gateid);
	SendClientMessageEx(playerid, COLOR_WHITE, "Reloading Gate ID %d...", gateid);
	return 1;
}

CreateGate(gateid)
{
	if(!IsGateLoaded(gateid)) return 0;
	CancelGateTimer(gateid);
	if(GateEditor[gateid])
	{
		new playerid = GateEditor[gateid] - 1;
		ClearGateEditor(playerid);
		if(IsPlayerConnected(playerid)) CancelEdit(playerid);
	}

	Iter_Remove(ActiveGates, gateid);
	if(IsValidDynamicObject(GateInfo[gateid][gGATE])) 
		DestroyDynamicObject(GateInfo[gateid][gGATE]);
	
	GateInfo[gateid][gGATE] = INVALID_STREAMER_ID;
	GateInfo[gateid][gStatus] = 0;
	if(GateInfo[gateid][gModel] == 0 || (GateInfo[gateid][gPosX] == 0.0 && GateInfo[gateid][gPosY] == 0.0 && GateInfo[gateid][gPosZ] == 0.0)) 
	{
		return 1;
	}

	new Float:distance = 60.0;
	switch(GateInfo[gateid][gRenderHQ])
	{
		case 1: distance = 100.0;
		case 2: distance = 150.0;
		case 3: distance = 200.0;
	}
	GateInfo[gateid][gGATE] = CreateDynamicObject(GateInfo[gateid][gModel], GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ], GateInfo[gateid][gRotX], GateInfo[gateid][gRotY], GateInfo[gateid][gRotZ], GateInfo[gateid][gVW], GateInfo[gateid][gInt], -1, distance);
	if(!IsValidDynamicObject(GateInfo[gateid][gGATE])) return 0;
	Iter_Add(ActiveGates, gateid);
	
	if(GateInfo[gateid][gTModel] != INVALID_OBJECT_ID && 0 <= GateInfo[gateid][gTIndex] <= 15)
	{
		SetDynamicObjectMaterial(GateInfo[gateid][gGATE], GateInfo[gateid][gTIndex], GateInfo[gateid][gTModel], GateInfo[gateid][gTTXD], GateInfo[gateid][gTTexture], GateInfo[gateid][gTColor]);
	}

	if(IsGateHeldOpen(gateid) && (GateInfo[gateid][gPosXM] != 0.0 || GateInfo[gateid][gPosYM] != 0.0 || GateInfo[gateid][gPosZM] != 0.0))
	{
		SetDynamicObjectPos(GateInfo[gateid][gGATE], GateInfo[gateid][gPosXM], GateInfo[gateid][gPosYM], GateInfo[gateid][gPosZM]);
		SetDynamicObjectRot(GateInfo[gateid][gGATE], GateInfo[gateid][gRotXM], GateInfo[gateid][gRotYM], GateInfo[gateid][gRotZM]);
		GateInfo[gateid][gStatus] = 1;
	}
	return 1;
}

stock LoadGates()
{
	printf("[LoadGates] Loading data from database...");
	mysql_tquery(MainPipeline, "SELECT * FROM `gates`", "OnLoadGates", "");
}

forward OnLoadGates();
public OnLoadGates()
{
	new rows, sqlid, gateid;
	cache_get_row_count(rows);
	for(new id; id < MAX_GATES; ++id)
	{
		if(IsGateLoaded(id))
		{
			GateInfo[id][gModel] = 0;
			CreateGate(id);
			GateLoaded[id] = false;
		}
	}
	for(new i; i < rows; ++i)
	{
		cache_get_value_name_int(i, "ID", sqlid);
		if(!(1 <= sqlid <= MAX_GATES)) continue;
		gateid = sqlid - 1;
		GateLoaded[gateid] = true;
		cache_get_value_name_int(i, "HID", GateInfo[gateid][gHID]);
		cache_get_value_name_float(i, "Speed", GateInfo[gateid][gSpeed]);
		cache_get_value_name_float(i, "Range", GateInfo[gateid][gRange]);
		cache_get_value_name_int(i, "Model", GateInfo[gateid][gModel]);
		cache_get_value_name_int(i, "VW", GateInfo[gateid][gVW]);
		cache_get_value_name_int(i, "Int", GateInfo[gateid][gInt]);
		cache_get_value_name(i, "Pass", GateInfo[gateid][gPass], 24);
		cache_get_value_name_float(i, "PosX", GateInfo[gateid][gPosX]);
		cache_get_value_name_float(i, "PosY", GateInfo[gateid][gPosY]);
		cache_get_value_name_float(i, "PosZ", GateInfo[gateid][gPosZ]);
		cache_get_value_name_float(i, "RotX", GateInfo[gateid][gRotX]);
		cache_get_value_name_float(i, "RotY", GateInfo[gateid][gRotY]);
		cache_get_value_name_float(i, "RotZ", GateInfo[gateid][gRotZ]);
		cache_get_value_name_float(i, "PosXM", GateInfo[gateid][gPosXM]);
		cache_get_value_name_float(i, "PosYM", GateInfo[gateid][gPosYM]);
		cache_get_value_name_float(i, "PosZM", GateInfo[gateid][gPosZM]);
		cache_get_value_name_float(i, "RotXM", GateInfo[gateid][gRotXM]);
		cache_get_value_name_float(i, "RotYM", GateInfo[gateid][gRotYM]);
		cache_get_value_name_float(i, "RotZM", GateInfo[gateid][gRotZM]);
		cache_get_value_name_int(i, "Allegiance", GateInfo[gateid][gAllegiance]);
		cache_get_value_name_int(i, "GroupType", GateInfo[gateid][gGroupType]);
		cache_get_value_name_int(i, "GroupID", GateInfo[gateid][gGroupID]);
		cache_get_value_name_int(i, "RenderHQ",  GateInfo[gateid][gRenderHQ]);
		cache_get_value_name_int(i, "Timer", GateInfo[gateid][gTimer]);
		cache_get_value_name_int(i, "Automate", GateInfo[gateid][gAutomate]);
		cache_get_value_name_int(i, "Locked", GateInfo[gateid][gLocked]);
		cache_get_value_name_int(i, "TIndex", GateInfo[gateid][gTIndex]);
		cache_get_value_name_int(i, "TModel", GateInfo[gateid][gTModel]);
		cache_get_value_name(i, "TTXD", GateInfo[gateid][gTTXD], 64);
		cache_get_value_name(i, "TTexture", GateInfo[gateid][gTTexture], 64);
		cache_get_value_name_int(i, "TColor", GateInfo[gateid][gTColor]);
		cache_get_value_name_int(i, "Facility", GateInfo[gateid][gFacility]);
		if(!(0.1 <= GateInfo[gateid][gSpeed] <= 1000.0)) GateInfo[gateid][gSpeed] = 10.0;
		if(!(0.1 <= GateInfo[gateid][gRange] <= 300.0)) GateInfo[gateid][gRange] = 10.0;
		if(!(0 <= GateInfo[gateid][gTimer] <= 4)) GateInfo[gateid][gTimer] = 0;
		CreateGate(gateid);
	}
}

stock SaveGate(id) {
	if(!IsGateLoaded(id)) return 0;

	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `gates` SET \
		`HID`=%d, \
		`Speed`=%f, \
		`Range`=%f, \
		`Model`=%d, \
		`VW`=%d, \
		`Int`=%d, \
		`Pass`='%e', \
		`PosX`=%f, \
		`PosY`=%f, \
		`PosZ`=%f, \
		`RotX`=%f, \
		`RotY`=%f, \
		`RotZ`=%f, \
		`PosXM`=%f, \
		`PosYM`=%f, \
		`PosZM`=%f, \
		`RotXM`=%f, \
		`RotYM`=%f, \
		`RotZM`=%f, \
		`Allegiance`=%d, \
		`GroupType`=%d, \
		`GroupID`=%d, \
		`RenderHQ`=%d, \
		`Timer`=%d, \
		`Automate`=%d, \
		`Locked`=%d, \
		`TIndex`=%d, \
		`TModel`=%d, \
		`TTXD`='%e', \
		`TTexture`='%e', \
		`TColor`=%d, \
		`Facility`=%d \
		WHERE `ID` = %d",
		GateInfo[id][gHID],
		GateInfo[id][gSpeed],
		GateInfo[id][gRange],
		GateInfo[id][gModel],
		GateInfo[id][gVW],
		GateInfo[id][gInt],
		GateInfo[id][gPass],
		GateInfo[id][gPosX],
		GateInfo[id][gPosY],
		GateInfo[id][gPosZ],
		GateInfo[id][gRotX],
		GateInfo[id][gRotY],
		GateInfo[id][gRotZ],
		GateInfo[id][gPosXM],
		GateInfo[id][gPosYM],
		GateInfo[id][gPosZM],
		GateInfo[id][gRotXM],
		GateInfo[id][gRotYM],
		GateInfo[id][gRotZM],
		GateInfo[id][gAllegiance],
		GateInfo[id][gGroupType],
		GateInfo[id][gGroupID],
		GateInfo[id][gRenderHQ],
		GateInfo[id][gTimer],
		GateInfo[id][gAutomate],
		GateInfo[id][gLocked],
		GateInfo[id][gTIndex],
		GateInfo[id][gTModel],
		GateInfo[id][gTTXD],
		GateInfo[id][gTTexture],
		GateInfo[id][gTColor],
		GateInfo[id][gFacility],
		id+1
	);
	mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
	return 0;
}

stock SaveGates()
{
	for(new i = 0; i < MAX_GATES; i++)
	{
		SaveGate(i);
	}
	return 1;
}

stock SetGateOpen(gateid, bool:opening, bool:facilityOverride = false)
{
	if(!IsGateActive(gateid) || GateEditor[gateid]) return -1;
	if(opening && GateInfo[gateid][gPosXM] == 0.0 && GateInfo[gateid][gPosYM] == 0.0 && GateInfo[gateid][gPosZM] == 0.0) return -1;
	if(!opening && !facilityOverride && IsGateHeldOpen(gateid)) return -1;
	if(!(0.1 <= GateInfo[gateid][gSpeed] <= 1000.0)) return -1;

	CancelGateTimer(gateid);
	new duration;
	if(opening) 
	{
		duration = MoveDynamicObject(GateInfo[gateid][gGATE], GateInfo[gateid][gPosXM], GateInfo[gateid][gPosYM], GateInfo[gateid][gPosZM], GateInfo[gateid][gSpeed], GateInfo[gateid][gRotXM], GateInfo[gateid][gRotYM], GateInfo[gateid][gRotZM]);
	}
	else
	{
		duration = MoveDynamicObject(GateInfo[gateid][gGATE], GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ], GateInfo[gateid][gSpeed], GateInfo[gateid][gRotX], GateInfo[gateid][gRotY], GateInfo[gateid][gRotZ]);
	}

	if(duration < 0) return -1;
	GateInfo[gateid][gStatus] = opening ? 1 : 0;
	return duration;
}

forward MoveTimerGate(gateid, revision);
public MoveTimerGate(gateid, revision)
{
	if(!IsGateActive(gateid) || GateRevision[gateid] != revision) return 1;
	GateCloseTimer[gateid] = 0;
	if(GateInfo[gateid][gStatus]) SetGateOpen(gateid, false);
	return 1;
}

stock MoveGate(playerid, gateid)
{
	if(!IsGateActive(gateid) || GateEditor[gateid]) return 0;
	new bool:opening = GateInfo[gateid][gStatus] == 0;
	if(!opening && GateInfo[gateid][gTimer] != 0) return 1;
	if(!opening && IsGateHeldOpen(gateid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "The facility is holding this gate open.");
	
	new duration = SetGateOpen(gateid, opening);
	if(duration < 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "The gate cannot move. Check its open position and speed.");
	
	new message[128];
	format(message, sizeof(message), "* %s uses their remote to %s the gates.", GetPlayerNameEx(playerid), opening ? ("open") : ("close"));
	ProxChatBubble(playerid, message);
	new hold = GetGateHoldTime(gateid);
	if(opening && hold && duration <= cellmax - hold) {
		GateCloseTimer[gateid] = SetTimerEx("MoveTimerGate", duration + hold, false, "ii", gateid, GateRevision[gateid]);
	}
	return 1;
}

// TODO: Define automatic gate activation before enabling this dormant polling path.
stock MoveAutomaticGate(playerid, gateid)
{
	if(!IsGateActive(gateid) || !GateInfo[gateid][gAutomate] || GateInfo[gateid][gLocked] || !IsPlayerNearGate(playerid, gateid) || !HasGateGroupAccess(playerid, gateid)) 
	{
		return 0;
	}

	new duration = SetGateOpen(gateid, true);
	if(duration < 0) return 0;
	new hold = GetGateHoldTime(gateid);
	if(!hold) hold = 3000;
	if(duration <= cellmax - hold)
	{
		GateCloseTimer[gateid] = SetTimerEx("AutomaticGateTimerClose", duration + hold, false, "iiii", playerid, gateid, g_arrQueryHandle[playerid], GateRevision[gateid]);
	}
	return 1;
}

forward AutomaticGateTimer(playerid, gateid, session, revision);
public AutomaticGateTimer(playerid, gateid, session, revision)
{
	if(!IsGateActive(gateid) || GateRevision[gateid] != revision) return 1;
	GateCloseTimer[gateid] = 0;
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || !GateInfo[gateid][gAutomate] || GateInfo[gateid][gLocked] || GateEditor[gateid]) 
	{
		return 1;
	}

	if(GateInfo[gateid][gStatus] == 0 && MoveAutomaticGate(playerid, gateid)) return 1;
	GateCloseTimer[gateid] = SetTimerEx("AutomaticGateTimer", 1000, false, "iiii", playerid, gateid, session, revision);
	return 1;
}

forward AutomaticGateTimerClose(playerid, gateid, session, revision);
public AutomaticGateTimerClose(playerid, gateid, session, revision)
{
	if(!IsGateActive(gateid) || GateRevision[gateid] != revision) return 1;
	GateCloseTimer[gateid] = 0;
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session)
	{
		SetGateOpen(gateid, false);
		return 1;
	}
	if(IsPlayerNearGate(playerid, gateid) && !GateInfo[gateid][gLocked])
		GateCloseTimer[gateid] = SetTimerEx("AutomaticGateTimerClose", 1000, false, "iiii", playerid, gateid, session, revision);
	else
	{
		SetGateOpen(gateid, false);
		if(GateInfo[gateid][gAutomate])
			GateCloseTimer[gateid] = SetTimerEx("AutomaticGateTimer", 1000, false, "iiii", playerid, gateid, session, GateRevision[gateid]);
	}
	return 1;
}

forward DeleteGate(gateid, adminid);
public DeleteGate(gateid, adminid)
{
	if(!IsGateLoaded(gateid)) return 0;
	GateInfo[gateid][gHID] = INVALID_HOUSE_ID;
	GateInfo[gateid][gSpeed] = 1.0;
	GateInfo[gateid][gRange] = 1.0;
	GateInfo[gateid][gModel] = 0;
	GateInfo[gateid][gVW] = 0;
	GateInfo[gateid][gInt] = 0;
	GateInfo[gateid][gPosX] = 0.0;
	GateInfo[gateid][gPosY] = 0.0;
	GateInfo[gateid][gPosZ] = 0.0;
	GateInfo[gateid][gRotX] = 0.0;
	GateInfo[gateid][gRotY] = 0.0;
	GateInfo[gateid][gRotZ] = 0.0;
	GateInfo[gateid][gPosXM] = 0.0;
	GateInfo[gateid][gPosYM] = 0.0;
	GateInfo[gateid][gPosZM] = 0.0;
	GateInfo[gateid][gRotXM] = 0.0;
	GateInfo[gateid][gRotYM] = 0.0;
    GateInfo[gateid][gRotZM] = 0.0;
    GateInfo[gateid][gStatus] = 0;
    GateInfo[gateid][gPass][0] = 0;
	GateInfo[gateid][gAllegiance] = 0;
	GateInfo[gateid][gGroupType] = 0;
	GateInfo[gateid][gGroupID] = INVALID_GROUP_ID;
    GateInfo[gateid][gRenderHQ] = 0;
	GateInfo[gateid][gTimer] = 0;
	GateInfo[gateid][gAutomate] = 0;
	GateInfo[gateid][gLocked] = 0;
	GateInfo[gateid][gFacility] = -1;
	GateInfo[gateid][gTIndex] = -1;
	GateInfo[gateid][gTModel] = INVALID_OBJECT_ID;
	GateInfo[gateid][gTTXD][0] = EOS;
	GateInfo[gateid][gTTexture][0] = EOS;
	GateInfo[gateid][gTColor] = 0;
	CreateGate(gateid);
	SaveGate(gateid);
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "%s has deleted gate id %d", adminid != INVALID_PLAYER_ID ? GetPlayerNameEx(adminid) : ("(Inactive Player Resource System)"), gateid);
	Log("logs/gedit.log", szMiscArray);
	return 1;
}
hook OnPlayerDisconnect(playerid, reason)
{
	if(GetPVarType(playerid, "gEdit"))
	{
		new gateid = GetPVarInt(playerid, "EditingGateID");
		if(IsGateLoaded(gateid) && GateEditor[gateid] == playerid + 1)
		{
			ClearGateEditor(playerid);
			CreateGate(gateid);
		}
	}
	return 1;
}

hook OnGameModeExit()
{
	for(new gateid; gateid < MAX_GATES; ++gateid)
	{
		if(IsGateLoaded(gateid)) CancelGateTimer(gateid);
	}
	return 1;
}