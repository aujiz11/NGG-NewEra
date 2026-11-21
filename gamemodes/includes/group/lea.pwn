/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						LEA Group Type

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

new LEADragTimer[MAX_PLAYERS], 
	LEADragToken[MAX_PLAYERS];

new LEACuffTimer[MAX_PLAYERS], 
	LEACuffToken[MAX_PLAYERS], 
	LEATackleGeneration[MAX_PLAYERS];

new LEABackupToken[MAX_PLAYERS];

stock StopDragging(dragger) {
	if(!(0 <= dragger < MAX_PLAYERS)) return 0;
	if(LEADragTimer[dragger]) KillTimer(LEADragTimer[dragger]);
	LEADragTimer[dragger] = 0;
	++LEADragToken[dragger];
	if(GetPVarType(dragger, "DraggingPlayer")) {
		new target = GetPVarInt(dragger, "DraggingPlayer");
		if(0 <= target < MAX_PLAYERS && IsPlayerConnected(target)
			&& g_arrQueryHandle[target] == GetPVarInt(dragger, "DragTargetSession")
			&& GetPVarType(target, "DraggedBy") && GetPVarInt(target, "DraggedBy") == dragger) {
			DeletePVar(target, "BeingDragged");
			DeletePVar(target, "DraggedBy");
		}
	}
	DeletePVar(dragger, "DraggingPlayer");
	DeletePVar(dragger, "DragTargetSession");
	return 1;
}

stock StartDragging(playerid, target) {
	if(!(0 <= target < MAX_PLAYERS) || !IsPlayerConnected(target) || target == playerid) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	if(!IsACop(playerid) || PlayerBusy(playerid) || PlayerTied[playerid] || PlayerInfo[playerid][pJailTime]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the keo nguoi khac luc nay.");
	
	if(IsPlayerInAnyVehicle(playerid) || IsPlayerInAnyVehicle(target))
	 	return SendClientMessageEx(playerid, COLOR_GREY, "Ca hai phai o ngoai xe.");
	
	if(PlayerCuffed[target] != 2) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua bi cong.");
	
	if(GetPVarType(playerid, "DraggingPlayer") || GetPVarInt(target, "BeingDragged")) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Mot nguoi dang keo hoac bi keo boi nguoi khac.");
	
	if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target) || GetPlayerInterior(playerid) != GetPlayerInterior(target) || !ProxDetectorS(5.0, playerid, target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nghi pham khong o gan ban.");
	
	StopDragging(playerid);
	SetPVarInt(target, "BeingDragged", 1);
	SetPVarInt(target, "DraggedBy", playerid);
	SetPVarInt(playerid, "DraggingPlayer", target);
	SetPVarInt(playerid, "DragTargetSession", g_arrQueryHandle[target]);
	LEADragTimer[playerid] = SetTimerEx("DragPlayer", 1000, false, "iiiii", playerid, target, g_arrQueryHandle[playerid], g_arrQueryHandle[target], LEADragToken[playerid]);
	SendClientMessageEx(target, COLOR_WHITE, "* %s dang keo ban.", GetPlayerNameEx(playerid));
	SendClientMessageEx(playerid, COLOR_WHITE, "* Ban dang keo %s. Nhan FIRE de dung.", GetPlayerNameEx(target));
	new string[128];
	format(string, sizeof(string), "* %s nam lay %s va bat dau keo di.", GetPlayerNameEx(playerid), GetPlayerNameEx(target));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	return 1;
}

stock BeginCuffTackled(playerid, target) {
	if(!(0 <= target < MAX_PLAYERS) || !IsPlayerConnected(target) || !GetPVarType(target, "IsTackled")) return 0;
	if(LEACuffTimer[playerid]) KillTimer(LEACuffTimer[playerid]);
	++LEACuffToken[playerid];
	LEACuffTimer[playerid] = SetTimerEx("CuffTackled", 4000, false, "iiiiii", playerid, target, g_arrQueryHandle[playerid], g_arrQueryHandle[target], LEATackleGeneration[target], LEACuffToken[playerid]);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	StopDragging(playerid);
	if(GetPVarType(playerid, "DraggedBy")) StopDragging(GetPVarInt(playerid, "DraggedBy"));
	if(GetPVarType(playerid, "IsTackled")) ClearTackle(playerid);
	if(GetPVarType(playerid, "Tackling")) {
		new target = GetPVarInt(playerid, "Tackling");
		if(0 <= target < MAX_PLAYERS && g_arrQueryHandle[target] == GetPVarInt(playerid, "TackleTargetSession")) ClearTackle(target);
	}
	++LEATackleGeneration[playerid];
	++LEACuffToken[playerid];
	if(LEACuffTimer[playerid]) KillTimer(LEACuffTimer[playerid]);
	LEACuffTimer[playerid] = 0;
	if(BackupClearTimer[playerid]) KillTimer(BackupClearTimer[playerid]);
	BackupClearTimer[playerid] = 0;
	++LEABackupToken[playerid];
	return 1;
}

forward FinishCopGetUp(playerid, session);
public FinishCopGetUp(playerid, session) {
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session) return 1;
	return CopGetUp(playerid);
}

forward ExpireBackup(playerid, session, token);
public ExpireBackup(playerid, session, token) {
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || LEABackupToken[playerid] != token) return 1;
	return BackupClear(playerid, 1);
}

stock ShowBackupActiveForPlayer(playerid)
{
	PlayerTextDrawShow(playerid, BackupText[playerid]);
}

stock HideBackupActiveForPlayer(playerid)
{
	PlayerTextDrawHide(playerid, BackupText[playerid]);
}

forward SetPlayerFree(playerid,declare,const reason[]);
public SetPlayerFree(playerid,declare,const reason[])
{
	if(IsPlayerConnected(playerid))
	{
		ClearCrimes(playerid, declare);
		foreach(new i: Player)
		{
			if(IsACop(i))
			{
				SendClientMessageEx(i, COLOR_DBLUE, "HQ: Moi don vi, officer %s da hoan tat nhiem vu.", GetPlayerNameEx(declare));
				SendClientMessageEx(i, COLOR_DBLUE, "HQ: %s da duoc xu ly, %s.", GetPlayerNameEx(playerid), reason);
			}
		}	
	}
}

stock IsACopCar(carid)
{
	if(!(0 < carid < MAX_VEHICLES) || !IsValidVehicle(carid)) return 0;
	if(0 <= DynVeh[carid] < MAX_DYNAMIC_VEHICLES)
	{
	    new iDvSlotID = DynVeh[carid], iGroupID = DynVehicleInfo[iDvSlotID][gv_igID];
	    if((0 <= iGroupID < MAX_GROUPS))
	    {
	    	if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_LEA) return 1;
		}
	}
	return 0;
}

stock CuffTacklee(playerid, giveplayerid)
{
	new string[128], Float: health, Float: armor;
    ClearTackle(giveplayerid);
	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban bi %s cong tay.", GetPlayerNameEx(playerid));
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cong %s cho den khi thao.", GetPlayerNameEx(giveplayerid));
	format(string, sizeof(string), "* %s cong tay %s va siet chat cong.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	GameTextForPlayer(giveplayerid, "~r~Da bi cong", 2500, 3);
	TogglePlayerControllable(giveplayerid, false);
	ClearAnimationsEx(giveplayerid);
	ClearAnimationsEx(playerid);
	GetHealth(giveplayerid, health);
	GetArmour(giveplayerid, armor);
	SetPVarFloat(giveplayerid, "cuffhealth",health);
	SetPVarFloat(giveplayerid, "cuffarmor",armor);
	SetPlayerSpecialAction(giveplayerid, SPECIAL_ACTION_CUFFED);
	ApplyAnimation(giveplayerid,"ped","cower",1,true,false,false,false,0,1);
	PlayerCuffed[giveplayerid] = 2;
	SetPVarInt(giveplayerid, "PlayerCuffed", 2);
	SetPVarInt(giveplayerid, "IsFrozen", 1);
	//Frozen[giveplayerid] = 1;
	PlayerCuffedTime[giveplayerid] = 300;
	PlayerFacePlayer(playerid, giveplayerid);
	return 1;
}

stock ClearTackle(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !GetPVarType(playerid, "IsTackled")) return 0;
	++LEATackleGeneration[playerid];
	new officer = GetPVarInt(playerid, "IsTackled");
	if(0 <= officer < MAX_PLAYERS && IsPlayerConnected(officer) && g_arrQueryHandle[officer] == GetPVarInt(playerid, "TackleSession")
		&& GetPVarType(officer, "Tackling") && GetPVarInt(officer, "Tackling") == playerid) {
		DeletePVar(officer, "Tackling");
		DeletePVar(officer, "TackleTargetSession");
	}
	DeletePVar(playerid, "TackleSession");
    TogglePlayerControllable(playerid, true);
	//PreloadAnimLib(playerid, "SUNBATHE");
	//PreloadAnimLib(GetPVarInt(playerid, "IsTackled"), "SUNBATHE");
    ApplyAnimation(playerid, "SUNBATHE", "Lay_Bac_out", 4.1, false, true, true, false, 0, 1);
	SetPVarInt(playerid, "CantBeTackledCount", 15); // cant be tackled again for 15 seconds
	DeletePVar(playerid, "IsTackled");
	DeletePVar(playerid, "TackleCooldown");
	DeletePVar(playerid, "TackledResisting");
	DeletePVar(playerid, "IsFrozen");
	ShowPlayerDialogEx(playerid, -1, DIALOG_STYLE_LIST, "Dong", "Dong", "Dong", "Dong");
	return 1;
}

forward DragPlayer(dragger, dragee, draggerSession, targetSession, token);
public DragPlayer(dragger, dragee, draggerSession, targetSession, token) {
	if(!IsPlayerConnected(dragger) || g_arrQueryHandle[dragger] != draggerSession || LEADragToken[dragger] != token) return 1;
	LEADragTimer[dragger] = 0;
	if(!IsPlayerConnected(dragee) || g_arrQueryHandle[dragee] != targetSession
		|| !GetPVarType(dragger, "DraggingPlayer") || GetPVarInt(dragger, "DraggingPlayer") != dragee
		|| !GetPVarType(dragee, "DraggedBy") || GetPVarInt(dragee, "DraggedBy") != dragger || !GetPVarInt(dragee, "BeingDragged")
		|| !IsACop(dragger) || PlayerBusy(dragger) || PlayerTied[dragger] || PlayerInfo[dragger][pJailTime]
		|| PlayerCuffed[dragee] != 2 || IsPlayerInAnyVehicle(dragger) || IsPlayerInAnyVehicle(dragee)) return StopDragging(dragger);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(dragger, x, y, z);
	GetXYBehindPlayer(dragger, x, y, 1.0);
	SetPVarFloat(dragee, "DragX", x);
	SetPVarFloat(dragee, "DragY", y);
	SetPVarFloat(dragee, "DragZ", z);
	SetPVarInt(dragee, "DragWorld", GetPlayerVirtualWorld(dragger));
	SetPVarInt(dragee, "DragInt", GetPlayerInterior(dragger));
	SetPlayerInterior(dragee, GetPlayerInterior(dragger));
	SetPlayerVirtualWorld(dragee, GetPlayerVirtualWorld(dragger));
	SetPlayerPos(dragee, x, y, z);
	Streamer_UpdateEx(dragee, x, y, z);
	ClearAnimationsEx(dragee);
	ApplyAnimation(dragee, "ped", "cower", 1.0, true, false, false, false, 0, 1);
	LEADragTimer[dragger] = SetTimerEx("DragPlayer", 1000, false, "iiiii", dragger, dragee, draggerSession, targetSession, token);
	return 1;
}

forward CuffTackled(playerid, giveplayerid, session, targetSession, generation, token);
public CuffTackled(playerid, giveplayerid, session, targetSession, generation, token)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || LEACuffToken[playerid] != token) return 1;
	LEACuffTimer[playerid] = 0;
	if(!IsPlayerConnected(giveplayerid) || g_arrQueryHandle[giveplayerid] != targetSession || LEATackleGeneration[giveplayerid] != generation) return 1;
	if(!IsACop(playerid) || PlayerInfo[playerid][pHasCuff] < 1 || PlayerBusy(playerid) || PlayerTied[playerid] || PlayerInfo[playerid][pJailTime]
		|| PlayerCuffed[giveplayerid] == 2 || GetPVarInt(giveplayerid, "Injured") || IsPlayerInAnyVehicle(playerid) || IsPlayerInAnyVehicle(giveplayerid)
		|| GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(giveplayerid) || GetPlayerInterior(playerid) != GetPlayerInterior(giveplayerid)
		|| !ProxDetectorS(8.0, playerid, giveplayerid)) return 1;
	new string[128];
	if(!GetPVarType(giveplayerid, "IsTackled"))
	{
	    return SendClientMessageEx(playerid, COLOR_GRAD1, "Nghi pham da thoat. Hay vat nga, chich dien hoac yeu cau ho hop tac!");
	}
	if(GetPVarType(giveplayerid, "TackledResisting")) // If they haven't chosen - we assume they're resisting
	{
	    if(GetPVarInt(giveplayerid, "TackledResisting") == 1) // complying
	    {
			if(GetPVarType(giveplayerid, "IsTackled"))
			{
				return CuffTacklee(playerid, giveplayerid);
			}
		}
	    if(GetPVarInt(giveplayerid, "TackledResisting") == 2) // resisting
	    {
	        new copcount;
			foreach(new j: Player)
			{
				if(ProxDetectorS(4.0, giveplayerid, j) && IsACop(j) && j != giveplayerid)
				{
					copcount++;
				}
			}	
	        format(string, sizeof(string), "* %s day ra va co chong lai %s.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
    		ProxDetector(30.0, giveplayerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	        new cuffchance = random(11);
	        if(copcount >= 2 && copcount < 5) cuffchance = random(6);
			else if(copcount >= 5) cuffchance = 1;
			switch(cuffchance)
			{
			    case 0..4: // success
			    {
			        return CuffTacklee(playerid, giveplayerid);
			    }
				default: // fail
				{
					format(string, sizeof(string), "* %s day %s sang ben va thoat duoc.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
    				ProxDetector(30.0, giveplayerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    TogglePlayerControllable(playerid, false);
					ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, true, true, true, true, 0, 1);
					SetTimerEx("FinishCopGetUp", 3500, false, "ii", playerid, g_arrQueryHandle[playerid]);
				 	ClearTackle(giveplayerid);
				}
			}
	    }
	}
	else
	{
	    ShowPlayerDialogEx(giveplayerid, -1, DIALOG_STYLE_LIST, "Dong", "Dong", "Dong", "Dong");
	    SetPVarInt(giveplayerid, "TackledResisting", 2);
		CuffTackled(playerid, giveplayerid, session, targetSession, generation, token);
	}
	return 1;
}

forward CopGetUp(playerid);
public CopGetUp(playerid)
{
    SetPVarInt(playerid, "CopTackleCooldown", 30); // a Cooldown on when the cop can tackle again after tackling someone
	DeletePVar(playerid, "Tackling");
    SendClientMessageEx(playerid, COLOR_GRAD2, "Hay cho 30 giay de vat nga tiep.");
	TogglePlayerControllable(playerid, true);
	//PreloadAnimLib(playerid, "SUNBATHE");
	ApplyAnimation(playerid, "SUNBATHE", "Lay_Bac_out", 4.0, false, true, true, false, 0, 1);
	return 1;
}

stock TacklePlayer(playerid, tacklee)
{
	if(!(0 <= tacklee < MAX_PLAYERS) || !IsPlayerConnected(tacklee) || tacklee == playerid) return 0;
	new groupid = PlayerInfo[playerid][pMember];
	if(!ValidGroup(groupid) || PlayerInfo[playerid][pRank] < arrGroupData[groupid][g_iTackleAccess] || PlayerBusy(playerid) || PlayerTied[playerid] || PlayerInfo[playerid][pJailTime]) return 0;
	if(GetPVarType(tacklee, "IsTackled") || GetPVarType(playerid, "Tackling") || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(tacklee) || GetPlayerInterior(playerid) != GetPlayerInterior(tacklee) || !ProxDetectorS(4.0, playerid, tacklee)) return 0;
	++LEATackleGeneration[tacklee];
	SetPVarInt(tacklee, "TackleSession", g_arrQueryHandle[playerid]);
	SetPVarInt(playerid, "TackleTargetSession", g_arrQueryHandle[tacklee]);
	new string[128], Float: posx, Float: posy, Float: posz, group[GROUP_MAX_NAME_LEN], rank[GROUP_MAX_RANK_LEN], division[GROUP_MAX_DIV_LEN];
	//PreloadAnimLib(playerid, "PED");
	format(string, sizeof(string), "** %s lao vao vat nga %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(tacklee));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	SetPVarInt(tacklee, "IsTackled", playerid);
	TogglePlayerControllable(tacklee, false);
	SetPVarInt(tacklee, "IsFrozen", 1);
	SetPVarInt(tacklee, "TackleCooldown", 20); //Actually a countdown till the tackle is over
	SetPVarInt(playerid, "Tackling", tacklee);
	GetPlayerPos(tacklee, posx, posy,posz);
	SetPlayerFacingAngle(playerid, 180.0);
	SetPlayerFacingAngle(tacklee, 0.0);
	GetXYBehindPlayer(tacklee, posx, posy, 0.5);
	ApplyAnimation(playerid, "PED", "KO_shot_stom", 4.0, false, true, true, true, 20000, 1);
	ApplyAnimation(tacklee, "DILDO", "Dildo_Hit_3", 4.1, false, true, true, true, 20000, 1);
	GetPlayerGroupInfo(playerid, group, rank, division);
	GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~w~Nhan ~r~'~k~~CONVERSATION_YES~' ~n~~w~de dung day khoi nghi pham.", 15000, 3);
	format(string, sizeof(string), "%s %s %s da vat nga ban. Ban muon hop tac hay chong cu?", group, rank, GetPlayerNameEx(playerid));
	ShowPlayerDialogEx(tacklee, DIALOG_TACKLED, DIALOG_STYLE_MSGBOX, "Ban da bi vat nga", string, "Hop tac", "Chong cu");
	Mechanic_CancelFix(tacklee, false);
	CancelTruckDelivery(tacklee, false, false);
	return 1;
}

forward TazerTimer(playerid, session);
public TazerTimer(playerid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session) return 1;
	if(TazerTimeout[playerid] > 0)
   	{
		new string[128];
   		format(string,sizeof(string),"~n~~n~~n~~n~~n~~n~~n~~n~~r~Tazer dang nap... ~w~%d", TazerTimeout[playerid]);
		GameTextForPlayer(playerid, string,1500, 3);
		TazerTimeout[playerid] -= 1;
		SetTimerEx("TazerTimer",1000,false,"ii",playerid,session);
   	}
	return 1;
}

forward BackupClear(playerid, calledbytimer);
public BackupClear(playerid, calledbytimer) {
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	if(BackupClearTimer[playerid]) KillTimer(BackupClearTimer[playerid]);
	BackupClearTimer[playerid] = 0;
	++LEABackupToken[playerid];
	new scope = Backup[playerid], group = GetPVarType(playerid, "BackupGroup") ? GetPVarInt(playerid, "BackupGroup") : PlayerInfo[playerid][pMember];
	Backup[playerid] = 0;
	DeletePVar(playerid, "BackupGroup");
	if(!scope) {
		if(!calledbytimer) SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua goi ho tro!");
		return 1;
	}
	new string[128];
	if(calledbytimer) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Yeu cau ho tro cua ban da tu dong huy.");
		format(string, sizeof(string), "* Yeu cau ho tro cua %s het han.", GetPlayerNameEx(playerid));
	} else {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da huy yeu cau ho tro.");
		format(string, sizeof(string), "* %s khong can ho tro nua.", GetPlayerNameEx(playerid));
	}
	foreach(new i : Player) {
		SetPlayerMarkerForPlayer(i, playerid, TEAM_HIT_COLOR);
		if(!ValidGroup(group)) continue;
		switch(scope) {
			case 1, 2: if(PlayerInfo[i][pMember] == group) SendClientMessageEx(i, arrGroupData[group][g_hRadioColour] * 256 + 255, string);
			case 3: if(IsACop(i) && arrGroupData[group][g_iAllegiance] == arrGroupData[PlayerInfo[i][pMember]][g_iAllegiance]) SendClientMessageEx(i, COLOR_LIGHTGREEN, string);
			case 4: if(IsACop(i)) SendClientMessageEx(i, COLOR_LIGHTGREEN, string);
		}
	}
	SetPlayerToTeamColor(playerid);
	HideBackupActiveForPlayer(playerid);
	return 1;
}

forward SetAllCopCheckpoint(Float:allx, Float:ally, Float:allz, Float:radi);
public SetAllCopCheckpoint(Float:allx, Float:ally, Float:allz, Float:radi)
{
	foreach(new i: Player)
	{
		if(IsACop(i))
		{
			SetPlayerCheckpoint(i,allx,ally,allz, radi);
		}
	}	
	return 1;
}

forward ShowPlayerBeaconForCops(playerid);
public ShowPlayerBeaconForCops(playerid)
{
	foreach(new i: Player)
	{
		if(IsACop(i))
		{
			SetPlayerMarkerForPlayer(i, playerid, COP_GREEN_COLOR);
		}
	}
	return 1;
}

forward HidePlayerBeaconForCops(playerid);
public HidePlayerBeaconForCops(playerid)
{
	foreach(new i: Player)
	{
		if(IsACop(i))
		{
			SetPlayerMarkerForPlayer(i, playerid, TEAM_HIT_COLOR);
		}
	}
	SetPlayerToTeamColor(playerid);
	return 1;
}


CMD:placekit(playerid, params[]) {
	if(IsACop(playerid) || IsAMedic(playerid) || IsAReporter(playerid) || IsAGovernment(playerid) || IsATowman(playerid))
	{
		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o trong xe!");
		if(GetPVarInt(playerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the dung lenh nay!");
		if(!GetPVarInt(playerid, "MedVestKit")) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong mang bo dung cu.");
		new choice[9];
		if(sscanf(params, "s[9]", choice))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /placekit [name]");
			SendClientMessageEx(playerid, COLOR_GREY, "Ten hop le: Car, Backpack");
			return 1;
		}
		new string[128];
		if(strcmp(choice, "Car", true)  == 0)
		{
			new vehicleid = GetClosestCar(playerid, INVALID_VEHICLE_ID, 10.0);
			if( vehicleid != INVALID_VEHICLE_ID && GetDistanceToCar(playerid, vehicleid) < 10 )
			{
				if(!IsABike(vehicleid) && !IsAPlane(vehicleid)) {
					new engine,lights,alarm,doors,bonnet,boot,objective;
					GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
					if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)
					{
						SendClientMessageEx(playerid, COLOR_GRAD1, "Phai mo cop xe de cat vao.");
						return 1;
					}
				}
				if(VehInfo[vehicleid][vCarVestKit] >= 2)
				{
					return SendClientMessageEx(playerid, COLOR_GRAD1, "Xe da co hai bo dung cu.");
				}
				format(string, sizeof(string), "{FF8000}** {C2A2DA}%s cui vao cop, cat Kevlar Vest va First Aid Kit.", GetPlayerNameEx(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat Med Kit vao cop. Dung /usekit de su dung.");
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPVarInt(playerid, "MedVestKit", 0);
				VehInfo[vehicleid][vCarVestKit] += 1;
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe nao.");
		}
		else if(strcmp(choice, "Backpack", true)  == 0)
		{
			if(PlayerInfo[playerid][pBackpack] > 0 && PlayerInfo[playerid][pBEquipped])
			{
				if(PlayerInfo[playerid][pBItems][5] > 0 && PlayerInfo[playerid][pBackpack] == 1)
				{
					return SendClientMessageEx(playerid, COLOR_GRAD1, "Ba lo cua ban chi chua duoc 1 Med Kit.");
				}
				else if(PlayerInfo[playerid][pBItems][5] > 1 && PlayerInfo[playerid][pBackpack] == 2)
				{
					return SendClientMessageEx(playerid, COLOR_GRAD1, "Ba lo cua ban chi chua duoc 2 Med Kit.");
				}
				else if(PlayerInfo[playerid][pBItems][5] > 2 && PlayerInfo[playerid][pBackpack] == 3)
				{
					return SendClientMessageEx(playerid, COLOR_GRAD1, "Ba lo cua ban chi chua duoc 3 Med Kit.");
				}
				format(string, sizeof(string), "{FF8000}** {C2A2DA}%s mo ba lo, cat Kevlar Vest va First Aid Kit.", GetPlayerNameEx(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat Med Kit vao ba lo. Dung /usekit de su dung.");
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPVarInt(playerid, "MedVestKit", 0);
				PlayerInfo[playerid][pBItems][5] += 1;
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua deo ba lo. Dung /miscshop de mua.");
		}
		else 
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /placekit [name]");
			SendClientMessageEx(playerid, COLOR_GREY, "Ten hop le: Car, Backpack");
			return 1;
		}
	}
	return 1;
}

CMD:givekit(playerid, params[])
{
	if(IsACop(playerid) || IsAMedic(playerid) || IsAGovernment(playerid) || IsATowman(playerid))
	{
		if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay trong dau truong!");
		if(IsPlayerInAnyVehicle(playerid)) { SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o trong xe!"); return 1; }
		if(GetPVarInt(playerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the dung lenh nay!");

		new iTarget;
		if(sscanf(params, "u", iTarget)) return SendClientMessage(playerid, COLOR_GRAD2, "CACH DUNG: /givekit [playerid]");

		if(!IsPlayerConnected(iTarget)) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");

		new Float:X, Float:Y, Float:Z; GetPlayerPos(iTarget, X, Y, Z);
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, X, Y, Z)) return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua du gan nguoi do.");

		if(IsACop(iTarget) || IsAMedic(iTarget) || IsAGovernment(iTarget) || IsATowman(iTarget))
		{
			if(GetPVarInt(playerid, "MedVestKit") > 0)
			{
				if(GetPVarInt(iTarget, "MedVestKit") > 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do da co bo dung cu.");

				format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s dua Med Kit cho %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTarget));
				SendClientMessageEx(iTarget, COLOR_WHITE, "Ban nhan duoc Med Kit. Dung /placekit roi /usekit de su dung.");
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPVarInt(playerid, "MedVestKit", 0);
				SetPVarInt(iTarget, "MedVestKit", 1);
			}
			else SendClientMessage(playerid, COLOR_GRAD2, "Ban khong co bo dung cu.");
		}
		else SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong the dung bo dung cu.");
	}
	return 1;
}

CMD:usekit(playerid, params[]) {
	if(IsACop(playerid) || IsAMedic(playerid) || IsAReporter(playerid) || IsAGovernment(playerid) || IsATowman(playerid))
	{
		if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay trong dau truong!");
		if(IsPlayerInAnyVehicle(playerid)) { SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o trong xe!"); return 1; }
		if(GetPVarInt(playerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the dung lenh nay!");
		new string[128];
		new vehicleid = GetClosestCar(playerid, INVALID_VEHICLE_ID, 10.0);
		if(vehicleid != INVALID_VEHICLE_ID && GetDistanceToCar(playerid, vehicleid) < 10)
		{
		    if(VehInfo[vehicleid][vCarVestKit] > 0)
		    {
		    	if(!IsABike(vehicleid) && !IsAPlane(vehicleid)) {
					new engine,lights,alarm,doors,bonnet,boot,objective;
					GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
					if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)
					{
						SendClientMessageEx(playerid, COLOR_GRAD1, "Phai mo cop xe de kiem tra.");
						return 1;
					}
				}
		        format(string, sizeof(string), "{FF8000}** {C2A2DA}%s cui vao cop, lay Kevlar Vest va First Aid Kit.", GetPlayerNameEx(playerid));
            	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da dung Med Kit trong cop xe.");
            	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetHealth(playerid, 100);
				SetArmour(playerid, 150);
            	VehInfo[vehicleid][vCarVestKit] -= 1;
				return 1;
		    }
			else return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong co Med Kit trong xe nay."); 
		}
		else if(IsBackpackAvailable(playerid))
		{
			if(PlayerInfo[playerid][pBackpack] > 0 && PlayerInfo[playerid][pBEquipped])
			{
				if(PlayerInfo[playerid][pBItems][5] > 0)
				{
					if(GetPVarInt(playerid, "BackpackMedKit") == 1) {
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da yeu cau dung Med Kit.");
					}
					else 
					{
						defer FinishMedKit(playerid);
						SetPVarInt(playerid, "BackpackMedKit", 1);
						ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, false, false, false, false, 0, 1);
						format(string, sizeof(string), "{FF8000}** {C2A2DA}%s mo ba lo, lay Kevlar Vest va First Aid Kit.", GetPlayerNameEx(playerid));
						SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang lay Med Kit tu ba lo, vui long cho.");
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					}
				}
				else return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong co Med Kit trong ba lo.");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong co Med Kit trong ba lo.");
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o gan xe hoac chua deo ba lo!");
	}
	return 1;
}

CMD:searchcar(playerid, params[])
{
	if(!IsACop(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nhan vien hanh phap!");
	if(GetPVarInt(playerid, "Injured") != 0 || GetPVarInt(playerid, "EventToken") != 0) return SendClientMessageEx (playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	new closestcar = GetClosestCar(playerid), v, string[128];
	if(!(0 < closestcar < MAX_VEHICLES) || !IsValidVehicle(closestcar) || !IsPlayerInRangeOfVehicle(playerid, closestcar, 9.0)) return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong o gan xe nao.");
	if(IsABike(closestcar) || IsAPlane(closestcar)) return SendClientMessageEx(playerid,COLOR_GREY,"Khong the kiem tra loai xe nay!");

	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(closestcar,engine,lights,alarm,doors,bonnet,boot,objective);
	if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET) return SendClientMessageEx(playerid, COLOR_GRAD1, "Phai mo cop xe de kiem tra.");

	foreach(new i: Player)
	{
		v = GetPlayerVehicle(i, closestcar);
		string[0] = 0;
		if(v != -1) {
			Smuggle_VehicleLoad(playerid, i, v);
			for(new x = 0; x < 3; x++)
			{
				if(PlayerVehicleInfo[i][v][pvWeapons][x] != 0)
				{
					new
						szWep[20];

					GetWeaponName(PlayerVehicleInfo[i][v][pvWeapons][x], szWep, sizeof(szWep));
					if(isnull(string)) format(string, sizeof(string), "* Trong cop: %s", szWep);
					else format(string, sizeof(string), "%s, %s", string, szWep);
				}
			}
			if(!isnull(string)) {
				SendClientMessageEx(playerid, COLOR_WHITE, string);
				if(VehInfo[closestcar][vCarVestKit]) {
					SendClientMessageEx(playerid, COLOR_WHITE, "* Trong cop:");
					SendClientMessageEx(playerid, COLOR_WHITE, "* Kevlar Vest.");
					SendClientMessageEx(playerid, COLOR_WHITE, "* First Aid Kit.");
				}
			}
			else if(VehInfo[closestcar][vCarVestKit] > 0) SendClientMessageEx(playerid, COLOR_WHITE, "* Trong cop: %d bo Kevlar Vest va First Aid Kit.", VehInfo[closestcar][vCarVestKit]);
			else SendClientMessageEx(playerid, COLOR_WHITE, "* Cop trong.");
			return 1;
		}
	}
    if(isnull(string)) {
        if(VehInfo[closestcar][vCarVestKit] > 0) {
            SendClientMessageEx(playerid, COLOR_WHITE, "* Trong cop:");
            SendClientMessageEx(playerid, COLOR_WHITE, "* Kevlar Vest (x%d).", VehInfo[closestcar][vCarVestKit]);
            SendClientMessageEx(playerid, COLOR_WHITE, "* First Aid Kit(x%d).", VehInfo[closestcar][vCarVestKit]);
		}
		else SendClientMessageEx(playerid, COLOR_WHITE, "* Cop trong.");
    }
    return 1;
}


CMD:takecarweapons(playerid, params[])
{
    if (!IsACop(playerid))
	{
        SendClientMessageEx(playerid,COLOR_GREY,"Ban khong phai nhan vien hanh phap.");
        return 1;
    }
    new carid = GetPlayerVehicleID(playerid);
    new closestcar = GetClosestCar(playerid,carid);
    if(!(0 < closestcar < MAX_VEHICLES) || !IsValidVehicle(closestcar) || !IsPlayerInRangeOfVehicle(playerid, closestcar, 9.0))
	{
        SendClientMessageEx(playerid,COLOR_GREY,"Ban khong o gan xe nao.");
        return 1;
    }
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(closestcar,engine,lights,alarm,doors,bonnet,boot,objective);
	if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Phai mo cop xe de kiem tra.");
		return 1;
	}
    foreach(new i: Player)
	{
		new v = GetPlayerVehicle(i, closestcar);
		if(v != -1)
		{
			if (!PlayerVehicleInfo[i][v][pvWeapons][0] && !PlayerVehicleInfo[i][v][pvWeapons][1] && !PlayerVehicleInfo[i][v][pvWeapons][2])
			{
				SendClientMessageEx(playerid, COLOR_WHITE,  "Cop khong co vu khi.");
				return 1;
			}
			else
			{
				PlayerVehicleInfo[i][v][pvWeapons][0] = 0;
				PlayerVehicleInfo[i][v][pvWeapons][1] = 0;
				PlayerVehicleInfo[i][v][pvWeapons][2] = 0;
				g_mysql_SaveVehicle(i, v);
				SendClientMessageEx(playerid, COLOR_WHITE,  "Da thu giu het vu khi trong xe.");
				new string[MAX_PLAYER_NAME + 44];
				format(string, sizeof(string), "* %s da lay het vu khi trong cop.", GetPlayerNameEx(playerid));
				ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
		}
	}	
    return 1;
}

CMD:mdc(playerid, params[])
{
    if(IsMDCPermitted(playerid))
	{
        if(IsPlayerInAnyVehicle(playerid) || Bit_State(arrPlayerBits[playerid], phone_bitState))
		{
            ShowPlayerDialogEx(playerid, MDC_MAIN, DIALOG_STYLE_LIST, "MDC - Da dang nhap", "*Thong tin cong dan\n*Truy na nghi pham\n*Xoa truy na\n*Dang ky xe\n*Tim LEO\n*Co quan hanh phap\n*Tin nhan MDC\n*SMS", "Dong y", "Huy");
            ConnectedToPC[playerid] = 1337;
        }
        else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong xe.");
    }
    return 1;
}

CMD:clearcargo(playerid, params[])
{
	if(!IsACop(playerid))
	{
        SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai nhan vien hanh phap!");
        return 1;
	}

	new carid = GetPlayerVehicleID(playerid);
 	new closestcar = GetClosestCar(playerid, carid);
	if(0 < closestcar < MAX_VEHICLES && IsValidVehicle(closestcar) && GetVehicleVirtualWorld(closestcar) == GetPlayerVirtualWorld(playerid)
		&& GetVehicleInterior(closestcar) == GetPlayerInterior(playerid) && IsPlayerInRangeOfVehicle(playerid, closestcar, 6.0) && IsATruckerCar(closestcar))
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the thu giu hang khi dang trong xe.");
		    return 1;
		}
		if(TruckContents{closestcar} == 0)
		{
			if(0 <= TruckDeliveringTo[closestcar] < MAX_BUSINESSES && (Businesses[TruckDeliveringTo[closestcar]][bType] != BUSINESS_TYPE_GASSTATION || Businesses[TruckDeliveringTo[closestcar]][bType] == BUSINESS_TYPE_NEWCARDEALERSHIP))
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong the thu giu hang.");
				return 1;
			}
		}
		new truckcontentname[50];
		new iTruckContents = TruckContents{closestcar};
		if(iTruckContents >= 0 && iTruckContents < 5)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Xe khong chua hang cam.");
			return 1;
		}
		else if(TruckDeliveringTo[closestcar] == INVALID_BUSINESS_ID && iTruckContents == 0)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Xe khong chua hang cam.");
			return 1;
		}
		if(iTruckContents == 5)
		{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}vu khi trai phep"); }
		else if(iTruckContents == 6)
		{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}ma tuy"); }
		else if(iTruckContents == 7)
		{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}vat lieu trai phep"); }
		else format(truckcontentname, sizeof(truckcontentname), "{FF0606}vat lieu trai phep");
 		foreach(new i: Player)
		{
			if(TruckUsed[i] == closestcar || GetPVarInt(i, "ShipmentVehicle") == closestcar)
			{
				Shipment_ClearVehicleWork(i, closestcar);
				SendClientMessageEx(i, COLOR_WHITE, "Giao hang that bai. Luc luong hanh phap da tich thu hang cam.");
			}
		}	
		TruckDeliveringTo[closestcar] = INVALID_BUSINESS_ID;
		TruckContents{closestcar} = 0;
		TruckRoute[closestcar] = 0;
		new string[128];
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da thu giu %s {FFFFFF}trong xe.", truckcontentname);
		format(string, sizeof(string), "* %s da thu giu hang cam trong xe.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    }
   	else
	{
 		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o gan Shipment Transport Vehicle.");
 	}
    return 1;
}

CMD:backup(playerid, params[])
{
	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0 || GetPVarInt(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) {

		return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	}

    if(IsACop(playerid) || IsAMedic(playerid) || IsATowman(playerid))
	{
	    new code[10],
		zone[MAX_ZONE_NAME],
		string[128];
	    GetPlayer3DZone(playerid, zone, sizeof(zone));
		if(sscanf(params, "s[10]", code) && (Backup[playerid] == 0 || Backup[playerid] == 2)) {
			format(string, sizeof(string), "* %s goi ho tro qua radio.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			format(string, sizeof(string), "* %s can ho tro tai %s. {AA3333}Ung cuu Code 3 [Lights and Sirens].", GetPlayerNameEx(playerid), zone);
            ShowBackupActiveForPlayer(playerid);
			Backup[playerid] = 1;

			foreach(new i : Player)
			{
				if(PlayerInfo[playerid][pMember] == PlayerInfo[i][pMember])
				{
      				SetPlayerMarkerForPlayer(i, playerid, 0x2641FEAA);
					SendClientMessageEx(i, arrGroupData[PlayerInfo[playerid][pMember]][g_hRadioColour] * 256 + 255, string);
				}
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Dung '/backup' lan nua de ha xuong code 2.");
			SendClientMessageEx(playerid, COLOR_WHITE, "Dung /nobackup de huy yeu cau ho tro.");
			if(BackupClearTimer[playerid] != 0)
			{
				KillTimer(BackupClearTimer[playerid]);
				BackupClearTimer[playerid] = 0;
			}
			SetPVarInt(playerid, "BackupGroup", PlayerInfo[playerid][pMember]);
			++LEABackupToken[playerid];
			BackupClearTimer[playerid] = SetTimerEx("ExpireBackup", 300000, false, "iii", playerid, g_arrQueryHandle[playerid], LEABackupToken[playerid]);
		}
		else if((strcmp(code, "code2", true) == 0 || (!code[0] && Backup[playerid] == 1)) && (Backup[playerid] == 0 || Backup[playerid] == 1))
		{
			format(string, sizeof(string), "* %s goi ho tro qua radio.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			format(string, sizeof(string), "* %s can ho tro tai %s. {00FF33}Ung cuu Code 2 [No Lights and Sirens].", GetPlayerNameEx(playerid), zone);
            ShowBackupActiveForPlayer(playerid);
			Backup[playerid] = 2;

			foreach(new i : Player)
			{
				if(PlayerInfo[playerid][pMember] == PlayerInfo[i][pMember])
				{
      				SetPlayerMarkerForPlayer(i, playerid, 0x00FF33AA);
					SendClientMessageEx(i,  arrGroupData[PlayerInfo[playerid][pMember]][g_hRadioColour] * 256 + 255, string);
				}
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Dung /backup lan nua de nang len code 3.");
			SendClientMessageEx(playerid, COLOR_WHITE, "Dung /nobackup de huy yeu cau ho tro.");
			if(BackupClearTimer[playerid] != 0)
			{
				KillTimer(BackupClearTimer[playerid]);
				BackupClearTimer[playerid] = 0;
			}
			SetPVarInt(playerid, "BackupGroup", PlayerInfo[playerid][pMember]);
			++LEABackupToken[playerid];
			BackupClearTimer[playerid] = SetTimerEx("ExpireBackup", 300000, false, "iii", playerid, g_arrQueryHandle[playerid], LEABackupToken[playerid]);
		}
		else if(code[0] && !(strcmp(code, "code2", true) == 0))
		{
		    return SendClientMessageEx(playerid, COLOR_GREY, "Sai tham so, chi dung /backup hoac /backup code2");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da goi ho tro! Dung /nobackup de huy.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai nhan vien hanh phap hoac Medic!");
	}
	return 1;
}

CMD:backupall(playerid, params[])
{
	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0 || GetPVarInt(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) {
		
		return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	}
    if(IsACop(playerid) || IsAMedic(playerid))
	{
	    new
			zone[MAX_ZONE_NAME],
			string[128];
	    GetPlayer3DZone(playerid, zone, sizeof(zone));
		if(Backup[playerid] == 0 || Backup[playerid] == 1)
		{
			format(string, sizeof(string), "* %s goi ho tro qua radio.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			format(string, sizeof(string), "* %s can ho tro tai %s. {AA3333}Ung cuu Code 3A [Lights and Sirens].", GetPlayerNameEx(playerid), zone);
            ShowBackupActiveForPlayer(playerid);
			Backup[playerid] = 3;
			foreach(new i : Player)
			{
				if(IsACop(i) && arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == arrGroupData[PlayerInfo[i][pMember]][g_iAllegiance])
				{
      				SetPlayerMarkerForPlayer(i, playerid, 0x2641FEAA);
					SendClientMessageEx(i, DEPTRADIO, string);
				}
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Dung /nobackup de huy yeu cau ho tro.");
			if(BackupClearTimer[playerid] != 0)
			{
				KillTimer(BackupClearTimer[playerid]);
				BackupClearTimer[playerid] = 0;
			}
			SetPVarInt(playerid, "BackupGroup", PlayerInfo[playerid][pMember]);
			++LEABackupToken[playerid];
			BackupClearTimer[playerid] = SetTimerEx("ExpireBackup", 300000, false, "iii", playerid, g_arrQueryHandle[playerid], LEABackupToken[playerid]);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da goi ho tro! Dung /nobackup de huy.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai nhan vien hanh phap hoac Medic!");
	}
	return 1;
}

CMD:backupint(playerid, params[])
{
	if(PlayerTied[playerid] || PlayerCuffed[playerid] || PlayerBusy(playerid) || PlayerInfo[playerid][pJailTime]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) {
		
		return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	}
    if(IsACop(playerid) || IsAMedic(playerid))
	{
	    new
			zone[MAX_ZONE_NAME],
			string[128];
	    GetPlayer3DZone(playerid, zone, sizeof(zone));
		if(Backup[playerid] == 0 || Backup[playerid] == 1)
		{
			format(string, sizeof(string), "* %s goi ho tro qua radio.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			format(string, sizeof(string), "* %s can ho tro quoc te tai %s. {AA3333}Ung cuu Code 3A [Lights and Sirens].", GetPlayerNameEx(playerid), zone);
            ShowBackupActiveForPlayer(playerid);
			Backup[playerid] = 4;
			foreach(new i : Player)
			{
				if(IsACop(i))
				{
      				SetPlayerMarkerForPlayer(i, playerid, 0x2641FEAA);
					SendClientMessageEx(i, DEPTRADIO, string);
				}
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Dung /nobackup de huy yeu cau ho tro.");
			if(BackupClearTimer[playerid] != 0)
			{
				KillTimer(BackupClearTimer[playerid]);
				BackupClearTimer[playerid] = 0;
			}
			SetPVarInt(playerid, "BackupGroup", PlayerInfo[playerid][pMember]);
			++LEABackupToken[playerid];
			BackupClearTimer[playerid] = SetTimerEx("ExpireBackup", 300000, false, "iii", playerid, g_arrQueryHandle[playerid], LEABackupToken[playerid]);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da goi ho tro! Dung /nobackup de huy.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai nhan vien hanh phap hoac Medic!");
	}
	return 1;
}

CMD:nobackup(playerid, params[])
{
    BackupClear(playerid, 0);
	return 1;
}

CMD:vmdc(playerid, params[])
{
    if(IsACop(playerid) || IsATowman(playerid) || IsAHitman(playerid) || PlayerInfo[playerid][pAdmin] >= 2)
    {
        new giveplayerid;
        if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /vmdc [player]");

   		if(IsPlayerConnected(giveplayerid))
    	{
	        SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________");
			SendClientMessageEx(playerid, COLOR_GRAD2, "*** Xe cua %s ***", GetPlayerNameEx(giveplayerid));
	        for(new i=0; i<MAX_PLAYERVEHICLES; i++)
         	{
			    if(PlayerVehicleInfo[giveplayerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten xe: %s | Tien phat: $%d.",PlayerVehicleInfo[giveplayerid][i][pvId],GetVehicleName(PlayerVehicleInfo[giveplayerid][i][pvId]),PlayerVehicleInfo[giveplayerid][i][pvTicket]);
	    		}
				else if(PlayerVehicleInfo[giveplayerid][i][pvImpounded])
				{
					new vehicleName[18];
					strunpack(vehicleName, VehicleName[PlayerVehicleInfo[giveplayerid][i][pvModelId]-400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: Da huy (tam giu) | Ten xe: %s | Tien phat: $%d.",vehicleName,PlayerVehicleInfo[giveplayerid][i][pvTicket]);
	    		}
	    	}
	    	SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________");
   		}
    }
	return 1;
}

CMD:vticket(playerid, params[])
{
	if(IsACop(playerid) || IsATowman(playerid)) {
		new vehid, amount;
		if(sscanf(params, "ii", vehid, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /vticket [registration] [amount]");
		if(PlayerInfo[playerid][pTicketTime] != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Hay cho mot phut de dung lai lenh nay!");
		if(amount > 50000) return SendClientMessageEx(playerid, COLOR_GREY, "Tien phat xe toi da la $50,000.");
		if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Tien phat xe toi thieu la $1.");
		if(!(0 < vehid < MAX_VEHICLES) || !IsValidVehicle(vehid)) return SendClientMessageEx(playerid, COLOR_GREY, "Dang ky xe khong hop le.");
		if(PlayerBusy(playerid) || PlayerTied[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
		new string[128], Float: x, Float: y, Float: z, veh = -1;
		GetVehiclePos(vehid, x, y, z);
		if(GetVehicleVirtualWorld(vehid) == GetPlayerVirtualWorld(playerid) && GetVehicleInterior(vehid) == GetPlayerInterior(playerid) && IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z)) {
			foreach(new i: Player) {
				if((veh = GetPlayerVehicle(i, vehid)) != -1) {
					if(PlayerVehicleInfo[i][veh][pvTicket] < 0 || PlayerVehicleInfo[i][veh][pvTicket] > cellmax - amount) return SendClientMessageEx(playerid, COLOR_GREY, "Xe khong the nhan them phat.");
					PlayerVehicleInfo[i][veh][pvTicket] += amount;
					g_mysql_SaveVehicle(i, veh);
					PlayerInfo[playerid][pTicketTime] = 60;
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban da phat $%s cho xe cua %s: %s.", number_format(amount), GetPlayerNameEx(i), GetVehicleName(PlayerVehicleInfo[i][veh][pvId]));
					format(string, sizeof(string), "[VTICKET] Officer %s has ticketed %s's %s (%d) for $%s.", GetPlayerNameEx(playerid), GetPlayerNameEx(i), GetVehicleName(PlayerVehicleInfo[i][veh][pvId]), PlayerVehicleInfo[i][veh][pvSlotId], number_format(amount));
					GroupLog(PlayerInfo[playerid][pMember], string);
					return 1;
				}
			}
			if((veh = IsDynamicCrateVehicle(vehid)) != -1) {
				if(ValidGroup(CrateVehicle[veh][cvGroupID])) {
					new vehicleName[18];
					if(PlayerInfo[playerid][pMember] == CrateVehicle[veh][cvGroupID]) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* To chuc cua ban so huu xe nay, khong the phat!");
					if(CrateVehicle[veh][cvTickets] < 0 || CrateVehicle[veh][cvTickets] > cellmax - amount) return SendClientMessageEx(playerid, COLOR_GREY, "Xe khong the nhan them phat.");
					CrateVehicle[veh][cvTickets] += amount;
					PlayerInfo[playerid][pTicketTime] = 60;
					strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban da phat $%s cho %s.", number_format(amount), vehicleName);
					format(string, sizeof(string), "[VTICKET] Officer %s has ticketed %s's %s (%d) for $%s.", GetPlayerNameEx(playerid), arrGroupData[CrateVehicle[veh][cvGroupID]][g_szGroupName], vehicleName, CrateVehicle[veh][cvId], number_format(amount));
					GroupLog(PlayerInfo[playerid][pMember], string);
					SaveCrateVehicle(veh);
				} else veh = -1;
			}
			if(veh == -1) {
				SendClientMessageEx(playerid, COLOR_GRAD2, "Xe khong co dang ky!");
			}
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban can o gan xe do!");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
    return 1;
}

CMD:vlookup(playerid, params[]) {

	if(IsACop(playerid) || IsATowman(playerid) || IsAHitman(playerid) || PlayerInfo[playerid][pAdmin] >= 2)
	{
        if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /vlookup [vehicle registration]");
        new carid;
		if(sscanf(params, "i", carid) || !(0 < carid < MAX_VEHICLES) || !IsValidVehicle(carid)) return SendClientMessageEx(playerid, COLOR_GREY, "Dang ky xe khong hop le.");
        new dynveh = DynVeh[carid];
        new cveh = IsDynamicCrateVehicle(carid);
		foreach(new i: Player)
		{
			new v = GetPlayerVehicle(i, carid);

			if(v != -1)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: $%s", carid, GetVehicleName(PlayerVehicleInfo[i][v][pvId]), GetPlayerNameEx(i), number_format(PlayerVehicleInfo[i][v][pvTicket]));
				return 1;
			}
		}	
        if(0 <= dynveh < MAX_DYNAMIC_VEHICLES)
		{
		    if(ValidGroup(DynVehicleInfo[dynveh][gv_igID]) && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] != GROUP_TYPE_CONTRACT && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] != GROUP_TYPE_CRIMINAL)
		    {
                SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: MIEN", carid, GetVehicleName(carid), arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_szGroupName]);
                return 1;
			}
			else if(ValidGroup(DynVehicleInfo[dynveh][gv_igID]) && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] == GROUP_TYPE_CRIMINAL)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s", carid, GetVehicleName(carid), arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_szGroupName]);
				return 1;
			}
        }
        if(cveh != -1) {
        	if(ValidGroup(CrateVehicle[cveh][cvGroupID])) {
        		SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: $%s", carid, GetVehicleName(carid), arrGroupData[CrateVehicle[cveh][cvGroupID]][g_szGroupName], number_format(CrateVehicle[cveh][cvTickets]));
        		return 1;
        	}
        }
        SendClientMessageEx(playerid, COLOR_GRAD2, "Xe nay chua co chu!");
    }
    return 1;
}

CMD:vcheck(playerid, params[])
{
    if(IsACop(playerid) || IsATowman(playerid) || IsAHitman(playerid) || PlayerInfo[playerid][pAdmin] >= 2)
	{
        new carid = GetPlayerVehicleID(playerid);
        new closestcar = GetClosestCar(playerid, carid);
        if(IsValidVehicle(carid) && IsTrailerAttachedToVehicle(carid))
		{
            new carbeingtowed = GetVehicleTrailer(carid);
            if(!(0 < carbeingtowed < MAX_VEHICLES) || !IsValidVehicle(carbeingtowed)) return SendClientMessageEx(playerid, COLOR_GREY, "Xe duoc keo khong con ton tai.");
            new dynveh = DynVeh[carbeingtowed];
            new cveh = IsDynamicCrateVehicle(carbeingtowed);
			foreach(new i: Player)
			{
				new v = GetPlayerVehicle(i, carbeingtowed);

				if(v != -1)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: $%s", carbeingtowed, GetVehicleName(PlayerVehicleInfo[i][v][pvId]), GetPlayerNameEx(i), number_format(PlayerVehicleInfo[i][v][pvTicket]));
					return 1;
				}
			}	
            if(0 <= dynveh < MAX_DYNAMIC_VEHICLES)
			{
			    if(ValidGroup(DynVehicleInfo[dynveh][gv_igID]) && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] != GROUP_TYPE_CONTRACT && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] != GROUP_TYPE_CRIMINAL)
			    {
                    SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: MIEN", carbeingtowed, GetVehicleName(carbeingtowed), arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_szGroupName]);
                    return 1;
				}
				else if(ValidGroup(DynVehicleInfo[dynveh][gv_igID]) && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] == GROUP_TYPE_CRIMINAL)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s", carbeingtowed, GetVehicleName(carbeingtowed), arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_szGroupName]);
					return 1;
				}
            }
            if(cveh != -1) {
            	if(ValidGroup(CrateVehicle[cveh][cvGroupID])) {
					SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: $%s", carbeingtowed, GetVehicleName(carbeingtowed), arrGroupData[CrateVehicle[cveh][cvGroupID]][g_szGroupName], number_format(CrateVehicle[cveh][cvTickets]));
        			return 1;
        		}
            }
            SendClientMessageEx(playerid, COLOR_GRAD2, "Xe nay chua co chu!");
        }
        else if(0 < closestcar < MAX_VEHICLES && IsValidVehicle(closestcar) && IsPlayerInRangeOfVehicle(playerid, closestcar, 9.0) && !IsTrailerAttachedToVehicle(carid) && (GetVehicleVirtualWorld(closestcar) == GetPlayerVirtualWorld(playerid)))
		{
		    new dynveh = DynVeh[closestcar], szClamp[16], cveh = IsDynamicCrateVehicle(closestcar);
		    if(WheelClamp{closestcar}) {
		    	format(szClamp, sizeof(szClamp), "| Khoa banh: Co");
		    }
            foreach(new i: Player)
			{

				new v = GetPlayerVehicle(i, closestcar);
				if(v != -1)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: $%d | Toc do: %.0f MPH %s", closestcar, GetVehicleName(PlayerVehicleInfo[i][v][pvId]), GetPlayerNameEx(i), PlayerVehicleInfo[i][v][pvTicket],  vehicle_get_speed(closestcar), szClamp);
					return 1;
				}
			}	
            if(0 <= dynveh < MAX_DYNAMIC_VEHICLES)
			{
			    if(ValidGroup(DynVehicleInfo[dynveh][gv_igID]) && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] != GROUP_TYPE_CONTRACT && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] != GROUP_TYPE_CRIMINAL)
			    {
                    SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: MIEN %s", closestcar, GetVehicleName(closestcar), arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_szGroupName], szClamp);
                    return 1;
				}
				else if(ValidGroup(DynVehicleInfo[dynveh][gv_igID]) && arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_iGroupType] == GROUP_TYPE_CRIMINAL)
			    {
                    SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s %s", closestcar, GetVehicleName(closestcar), arrGroupData[DynVehicleInfo[dynveh][gv_igID]][g_szGroupName], szClamp);
                    return 1;
				}
            }
            if(cveh != -1) {
            	if(ValidGroup(CrateVehicle[cveh][cvGroupID])) {
            		SendClientMessageEx(playerid, COLOR_WHITE, "Dang ky: %d | Ten: %s | Chu: %s | Phat: $%s %s", closestcar, GetVehicleName(closestcar), arrGroupData[CrateVehicle[cveh][cvGroupID]][g_szGroupName], number_format(CrateVehicle[cveh][cvTickets]), szClamp);
        			return 1;
        		}
            }
            SendClientMessageEx(playerid, COLOR_GRAD2, "Xe nay chua co chu!");
        }
        else SendClientMessageEx(playerid, COLOR_GRAD1, "LOI: Ban khong keo xe hoac khong o gan xe khac.");
    }
    else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    return 1;
}



CMD:ram(playerid, params[])
{
	if(IsACop(playerid) || IsAMedic(playerid) || IsAHitman(playerid))
	{
		if(GetPVarType(playerid, "IsInArena"))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay trong dau truong!");
			return 1;
		}
		if( PlayerCuffed[playerid] >= 1 )
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban chua the lam viec nay.");
			return 1;
		}

		new string[128];
		for(new i = 0; i < sizeof(HouseInfo); i++)
		{
			if (IsPlayerInRangeOfPoint(playerid,3,HouseInfo[i][hExteriorX], HouseInfo[i][hExteriorY], HouseInfo[i][hExteriorZ]) && PlayerInfo[playerid][pVW] == HouseInfo[i][hExtVW])
			{
				format(string, sizeof(string), "* %s pha cua va di vao.", GetPlayerNameEx(playerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPlayerInterior(playerid,HouseInfo[i][hIntIW]);
				SetPlayerPos(playerid,HouseInfo[i][hInteriorX],HouseInfo[i][hInteriorY],HouseInfo[i][hInteriorZ]);
				GameTextForPlayer(playerid, "~r~Da pha cua", 5000, 1);
				PlayerInfo[playerid][pInt] = HouseInfo[i][hIntIW];
				PlayerInfo[playerid][pVW] = HouseInfo[i][hIntVW];
				SetPlayerVirtualWorld(playerid,HouseInfo[i][hIntVW]);
				if(HouseInfo[i][hCustomInterior] == 1) Player_StreamPrep(playerid, HouseInfo[i][hInteriorX],HouseInfo[i][hInteriorY],HouseInfo[i][hInteriorZ], FREEZE_TIME);
				return 1;
			}
		}
		if(PlayerInfo[playerid][pRank] > 3)
		{
			for(new i = 0; i < sizeof(DDoorsInfo); i++)
			{
				if (IsPlayerInRangeOfPoint(playerid,3.0,DDoorsInfo[i][ddExteriorX], DDoorsInfo[i][ddExteriorY], DDoorsInfo[i][ddExteriorZ]) && PlayerInfo[playerid][pVW] == DDoorsInfo[i][ddExteriorVW] && DDoorsInfo[i][ddVIP] > 0)
				{
					SetPlayerInterior(playerid,DDoorsInfo[i][ddInteriorInt]);
					PlayerInfo[playerid][pInt] = DDoorsInfo[i][ddInteriorInt];
					PlayerInfo[playerid][pVW] = DDoorsInfo[i][ddInteriorVW];
					SetPlayerVirtualWorld(playerid, DDoorsInfo[i][ddInteriorVW]);
					if(DDoorsInfo[i][ddVehicleAble] > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
						SetVehiclePos(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddInteriorX],DDoorsInfo[i][ddInteriorY],DDoorsInfo[i][ddInteriorZ]);
						SetVehicleZAngle(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddInteriorA]);
						if(GetPVarInt(playerid, "tpDeliverVehTimer") > 0)
							SetPVarInt(playerid, "tpJustEntered", 1);
						SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddInteriorVW]);
						LinkVehicleToInterior(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddInteriorInt]);
					}
					else {
						SetPlayerPos(playerid,DDoorsInfo[i][ddInteriorX],DDoorsInfo[i][ddInteriorY],DDoorsInfo[i][ddInteriorZ]);
						SetPlayerFacingAngle(playerid,DDoorsInfo[i][ddInteriorA]);
						SetCameraBehindPlayer(playerid);
					}
					if(DDoorsInfo[i][ddCustomInterior]) Player_StreamPrep(playerid, DDoorsInfo[i][ddInteriorX],DDoorsInfo[i][ddInteriorY],DDoorsInfo[i][ddInteriorZ], FREEZE_TIME);
					return 1;
				}
			}
		}
	    for(new i = 0; i < sizeof(Businesses); i++) {
	        if (IsPlayerInRangeOfPoint(playerid,3,Businesses[i][bExtPos][0], Businesses[i][bExtPos][1], Businesses[i][bExtPos][2])) {
		        if (Businesses[i][bExtPos][1] == 0.0) return 1;
				format(string, sizeof(string), "* %s pha cua va di vao.", GetPlayerNameEx(playerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPlayerInterior(playerid,Businesses[i][bInt]);
		        if(Businesses[i][bVW] == 0) SetPlayerVirtualWorld(playerid, BUSINESS_BASE_VW + i), PlayerInfo[playerid][pVW] = BUSINESS_BASE_VW + i;
		        else SetPlayerVirtualWorld(playerid, Businesses[i][bVW]), PlayerInfo[playerid][pVW] = Businesses[i][bVW];
		        SetPlayerPos(playerid,Businesses[i][bIntPos][0],Businesses[i][bIntPos][1],Businesses[i][bIntPos][2]);
			    SetPlayerFacingAngle(playerid, Businesses[i][bIntPos][3]);
		        SetCameraBehindPlayer(playerid);
				GameTextForPlayer(playerid, "~r~Da pha cua", 5000, 1);
				return 1;
	        }
	    }
		if (IsPlayerInRangeOfPoint(playerid,4.0,648.7888,-1360.7708,13.5875))
		{
			format(string, sizeof(string), "* %s pha cua va di vao.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPlayerInterior(playerid,1);
			PlayerInfo[playerid][pInt] = 1;
			SetPlayerVirtualWorld(playerid, 4225);
			PlayerInfo[playerid][pVW] = 4225;
			SetPlayerPos(playerid,626.4980,21.4223,1107.9686);
			SetPlayerFacingAngle(playerid, 178.6711);
			Player_StreamPrep(playerid, 626.4980,21.4223,1107.9686, FREEZE_TIME);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nhan vien hanh phap.");
	}
	return 1;
}

CMD:take(playerid, params[])
{
	if(IsACop(playerid))
	{
		new string[128], choice[32], giveplayerid;
		if(sscanf(params, "s[32]u", choice, giveplayerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /take [name] [player]");
			SendClientMessageEx(playerid, COLOR_GREY, "Ten hop le: Weapons, Pot, Crack, Meth, Ecstasy, Materials, Radio, Heroin, Rawopium, Syringes, PotSeeds, OpiumSeeds, DrugCrates");
			return 1;
		}
		if(!(0 <= giveplayerid < MAX_PLAYERS) || !IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		if(PlayerBusy(playerid) || PlayerTied[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
		if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(giveplayerid) || GetPlayerInterior(playerid) != GetPlayerInterior(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
		if(PlayerInfo[playerid][pAdmin] < 2 && (PlayerInfo[giveplayerid][pJailTime] && strfind(PlayerInfo[giveplayerid][pPrisonReason], "[OOC]", true) != -1)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the thu do cua tu nhan OOC.");
		if (playerid == giveplayerid)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu thu do cua minh!");
			return 1;
		}
		else if(strcmp(choice,"opiumseeds",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pOpiumSeeds] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co hat anh tuc.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu hat anh tuc cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu hat anh tuc cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu hat anh tuc cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's opiumseeds.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pOpiumSeeds] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"PotSeeds",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pWSeeds] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co hat can sa.");
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu hat can sa cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu hat can sa cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu hat can sa cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's Cannabisseeds.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pWSeeds] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"drugcrates",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pCrates] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co thung ma tuy.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu thung ma tuy cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu thung ma tuy cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu thung ma tuy cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's Drug Crates.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pCrates] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"Syringes",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pSyringes] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co ong tiem.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu ong tiem cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu ong tiem cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu ong tiem cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's syringes.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pSyringes] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"Rawopium",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pRawOpium] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co thuoc phien tho.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu thuoc phien tho cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu thuoc phien cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu thuoc phien tho cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's raw opium.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pRawOpium] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"Meth",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pDrugs][2] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co meth.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu Meth cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu Meth cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu Meth cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's Meth.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pDrugs][2] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"Ecstasy",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pDrugs][3] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co ecstasy.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu Ecstasy cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu Ecstasy cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu Ecstasy cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's Ecstasy.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pDrugs][3] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"Heroin",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pDrugs][4] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co heroin.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu Heroin cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu Heroin cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu Heroin cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's Heroin.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pDrugs][4] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"radio",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pRadio] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co radio.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu radio cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu radio cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu radio cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's radio.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pRadio] = 0;
					PlayerInfo[giveplayerid][pRadioFreq] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"weapons",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu vu khi cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu vu khi cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu vu khi cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's weapons.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ResetPlayerWeaponsEx(giveplayerid);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"Pot",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pDrugs][0] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co can sa.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu Cannabis cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu Cannabis cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu Cannabis cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's Cannabis.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pDrugs][0] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"crack",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pDrugs][1] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co crack.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu crack cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu crack cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu crack cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's crack.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pDrugs][1] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else if(strcmp(choice,"materials",true) == 0)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(PlayerInfo[giveplayerid][pMats] == 0) return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong co vat lieu.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu vat lieu cua %s.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu vat lieu cua ban.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* Officer %s da thu vat lieu cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					format(string, sizeof(string), "* Officer %s has taken away %s's materials.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					PlayerInfo[giveplayerid][pMats] = 0;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}

			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
				return 1;
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Vat pham khong hop le.");
			return 1;
		}
		GroupLog(PlayerInfo[playerid][pMember], string);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong phai nhan vien hanh phap.");
		return 1;
	}
	return 1;
}

CMD:tackle(playerid, params[])
{
	#if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the vat nga nguoi!");
	#endif
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iTackleAccess])
	{
		if(GetPVarInt(playerid, "ReTackleCooldown") != 0 && gettime() < GetPVarInt(playerid, "ReTackleCooldown") + 30)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Hay cho %d giay de bat lai che do vat nga!", GetPVarInt(playerid, "ReTackleCooldown") + 30 - gettime());
		}
		if(GetPVarInt(playerid, "WeaponsHolstered") == 0) //Unholstered
	    {
	        pc_cmd_holster(playerid, params);
			//UnholsterWeapon(playerid, 0);
		}
        if(GetPVarInt(playerid, "TackleMode") == 0)
        {
	        SetPVarInt(playerid, "TackleMode", 1);
	        return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da bat che do vat nga. Nham nghi pham va nhan enter de vat nga.");
		}
		else
		{
	        SetPVarInt(playerid, "TackleMode", 0);
	        SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da tat che do vat nga. Ban co the rut vu khi.");
			pc_cmd_holster(playerid, params);
			return SetPVarInt(playerid, "ReTackleCooldown", gettime());
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong duoc dung lenh nay.");
}

CMD:tazer(playerid, params[])
{
	if(HungerPlayerInfo[playerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   Khong the lam vay trong Hunger Games Event!");
	if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan cua ban bi han che!");
    #if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the dung.");
	#endif
	if(IsACop(playerid))
	{
		new string[128];
		if(PlayerInfo[playerid][pConnectHours] < 2 || PlayerInfo[playerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung vi ban dang bi cam so huu vu khi!");

		if(IsPlayerInAnyVehicle(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay khi dang trong xe.");
			return 1;
		}

		if(GetPVarType(playerid, "IsInArena"))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o dau truong!");
			return 1;
		}
		if(GetPVarInt( playerid, "EventToken") != 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung tazer trong su kien.");
			return 1;
		}
		if(PlayerCuffedTime[playerid] > 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
			return 1;
		}
		if(GetPVarInt(playerid, "Injured") == 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
			return 1;
		}

		if(PlayerInfo[playerid][pJailTime] > 0)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi o tu.");
			return 1;
		}
		if(PlayerCuffed[playerid] >= 1) {
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi bi chich dien/cong.");
			return 1;
		}
		if(PlayerInfo[playerid][pHasTazer] < 1)
		{
		    SendClientMessage(playerid, COLOR_WHITE, "Ban khong co tazer!");
		    return 1;
		}

		if(pTazer{playerid} == 0)
		{
			if(TazerTimeout[playerid] > 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Tazer dang nap lai");

			pTazerReplace{playerid} = PlayerInfo[playerid][pGuns][2];
			if(PlayerInfo[playerid][pGuns][2] != 0) RemovePlayerLoadoutWeapon(playerid, PlayerInfo[playerid][pGuns][2]);
			format(string, sizeof(string), "* %s rut tazer.", GetPlayerNameEx(playerid));
			ProxDetector(4.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			GivePlayerValidWeapon(playerid, 23);
			pTazer{playerid} = 1;
			SetPlayerAmmo(playerid, 23, 60000);
			SetPVarInt(playerid, "TazerShots", 2);
			SetPlayerAmmo(playerid, WEAPON_SILENCED, 3);
		}
		else
		{
			RemovePlayerLoadoutWeapon(playerid, 23);
			GivePlayerValidWeapon(playerid, pTazerReplace{playerid});
			format(string, sizeof(string), "* %s cat tazer.", GetPlayerNameEx(playerid));
			ProxDetector(4.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			pTazer{playerid} = 0;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai nhan vien hanh phap!");
		return 1;
	}
	return 1;
}

CMD:vradar(playerid, params[])
{
	if (!IsPlayerInAnyVehicle(playerid))
		return SendClientMessageEx(playerid, 0xFF0000FF, "Khong the dung radar tap lo khi o ngoai xe.");

	if(!IsACop(playerid) && !IsATowman(playerid))
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nhan vien hanh phap/Towman!");

	switch (CarRadars[playerid])
	{
		case 0: // player has not deployed dashboard radar
		{
			CarRadars[playerid] = 1;
			PlayerTextDrawShow(playerid, _crTextTarget[playerid]);
			PlayerTextDrawShow(playerid, _crTextSpeed[playerid]);
			PlayerTextDrawShow(playerid, _crTickets[playerid]);

			SendClientMessageEx(playerid, COLOR_WHITE, "Da bat radar tap lo, dung /vradar lan nua de tat.");
			SetPVarInt(playerid, "_lastTicketWarning", 0);
		}

		case 1..2: // dashboard radar has been deployed
		{
			CarRadars[playerid] = 0;
			PlayerTextDrawHide(playerid, _crTextTarget[playerid]);
			PlayerTextDrawHide(playerid, _crTextSpeed[playerid]);
			PlayerTextDrawHide(playerid, _crTickets[playerid]);
			
			SendClientMessageEx(playerid, COLOR_WHITE, "Da tat radar tap lo.");
			DeletePVar(playerid, "_lastTicketWarning");
		}
	}

	return 1;
}

CMD:radargun(playerid, params[])
{
	if(IsACop(playerid))
	{
		new string[128];
		if(IsPlayerInAnyVehicle(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay khi dang trong xe.");
			return 1;
		}

		if(GetPVarType(playerid, "IsInArena"))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o dau truong!");
			return 1;
		}
		if(GetPVarInt( playerid, "EventToken") != 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung tazer trong su kien.");
			return 1;
		}

		if(GetPVarInt(playerid, "Injured") == 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
			return 1;
		}

		if(PlayerInfo[playerid][pJailTime] > 0)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi o tu.");
			return 1;
		}
		if(PlayerCuffed[playerid] >= 1) {
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi bi chich dien/cong.");
			return 1;
		}

		new SpeedRadar = GetPVarInt(playerid, "SpeedRadar");
		if(SpeedRadar == 0)
		{
			SetPVarInt(playerid, "RadarReplacement", PlayerInfo[playerid][pGuns][9]);
			if(PlayerInfo[playerid][pGuns][9] != 0) RemovePlayerLoadoutWeapon(playerid, PlayerInfo[playerid][pGuns][9]);
			format(string, sizeof(string), "* %s lay sung do toc do LIDAR.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			GivePlayerValidWeapon(playerid, 43);
			SetPVarInt(playerid, "SpeedRadar", 1);
		}
		else
		{
			RemovePlayerLoadoutWeapon(playerid, 43);
			GivePlayerValidWeapon(playerid, GetPVarInt(playerid, "RadarReplacement"));
			format(string, sizeof(string), "* %s cat sung do toc do LIDAR.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			DeletePVar(playerid, "SpeedRadar");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai nhan vien hanh phap!");
		return 1;
	}
	return 1;
}

CMD:cuff(playerid, params[])
{
	if(IsACop(playerid))
	{
		if(PlayerTied[playerid] || GetPVarInt(playerid, "Injured") == 1 || PlayerCuffed[ playerid ] >= 1 || PlayerInfo[ playerid ][ pJailTime ] > 0 || PlayerInfo[playerid][pHospital] > 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
			return 1;
		}

		if(PlayerInfo[playerid][pHasCuff] < 1)
		{
		    SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co cong tay!");
		    return 1;
		}

		new string[128], giveplayerid, Float:health, Float:armor;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cuff [player]");
		if(IsPlayerConnected(giveplayerid))
		{
			if (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(giveplayerid) && GetPlayerInterior(playerid) == GetPlayerInterior(giveplayerid) && ProxDetectorS(8.0, playerid, giveplayerid))
			{
				if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu cong tay!"); return 1; }
				if(PlayerCuffed[giveplayerid] == 2) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da bi cong.");
				if(GetPVarInt(giveplayerid, "Injured") == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the cong nguoi bi thuong.");
				if(PlayerCuffed[giveplayerid] == 1 || GetPlayerSpecialAction(giveplayerid) == SPECIAL_ACTION_HANDSUP || GetPVarInt(giveplayerid, "pBagged") >= 1)
				{
					if(PlayerInfo[giveplayerid][pConnectHours] < 32) SendClientMessageEx(giveplayerid, COLOR_WHITE, "Neu thoat luc nay ban se bi tu tu dong 2+ gio!");
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban bi %s cong tay.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cong %s cho den khi thao.", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* %s cong tay %s va siet chat cong.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					if(GetPVarType(giveplayerid, "IsTackled")) ClearTackle(giveplayerid);
					GameTextForPlayer(giveplayerid, "~r~Da bi cong", 2500, 3);
					TogglePlayerControllable(giveplayerid, false);
					ClearAnimationsEx(giveplayerid);
					GetHealth(giveplayerid, health);
					GetArmour(giveplayerid, armor);
					SetPVarFloat(giveplayerid, "cuffhealth",health);
					SetPVarFloat(giveplayerid, "cuffarmor",armor);
					SetPlayerSpecialAction(giveplayerid, SPECIAL_ACTION_CUFFED);
					ApplyAnimation(giveplayerid,"ped","cower",1,true,false,false,false,0,1);
					PlayerCuffed[giveplayerid] = 2;
					SetPVarInt(giveplayerid, "PlayerCuffed", 2);
					SetPVarInt(giveplayerid, "IsFrozen", 1);
					DeletePVar(giveplayerid, "pBagged");
					//Frozen[giveplayerid] = 1;
					PlayerCuffedTime[giveplayerid] = 300;
				}
				else if(GetPVarType(giveplayerid, "IsTackled"))
				{
				    format(string, sizeof(string), "* %s lay cong tu that lung va thu cong tay %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					BeginCuffTackled(playerid, giveplayerid);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua bi khong che!");
					return 1;
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
				return 1;
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nhan vien hanh phap.");
	}
	return 1;
}

CMD:uncuff(playerid, params[])
{
	if(IsACop(playerid))
	{
		if(PlayerTied[playerid] || PlayerBusy(playerid) || PlayerInfo[playerid][pJailTime]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the thao cong cho nguoi khac!");
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /uncuff [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(giveplayerid) && GetPlayerInterior(playerid) == GetPlayerInterior(giveplayerid) && ProxDetectorS(8.0, playerid, giveplayerid))
			{
				/*if(PlayerInfo[giveplayerid][pJailTime] >= 1)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "You can't uncuff a jailed player.");
					return 1;
				} */
				if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu thao cong."); return 1; }
				if(PlayerCuffed[giveplayerid] > 1)
				{
					DeletePVar(giveplayerid, "IsFrozen");
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban duoc %s thao cong.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da thao cong %s.", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* %s thao cong %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					GameTextForPlayer(giveplayerid, "~g~Da thao cong", 2500, 3);
					TogglePlayerControllable(giveplayerid, true);
					ClearAnimationsEx(giveplayerid);
					SetPlayerSpecialAction(giveplayerid, SPECIAL_ACTION_NONE);
					if(GetPVarType(giveplayerid, "DraggedBy")) {
						StopDragging(GetPVarInt(giveplayerid, "DraggedBy"));
					}
					PlayerCuffed[giveplayerid] = 0;
                    PlayerCuffedTime[giveplayerid] = 0;
                    SetHealth(giveplayerid, GetPVarFloat(giveplayerid, "cuffhealth"));
                    SetArmour(giveplayerid, GetPVarFloat(giveplayerid, "cuffarmor"));
                    DeletePVar(giveplayerid, "cuffhealth");
					DeletePVar(giveplayerid, "PlayerCuffed");
					DeletePVar(giveplayerid, "jailcuffs");
				}
				else if(GetPVarInt(giveplayerid, "jailcuffs") == 1)
				{
					DeletePVar(giveplayerid, "IsFrozen");
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban duoc %s thao cong.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da thao cong %s.", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* %s thao cong %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					GameTextForPlayer(giveplayerid, "~g~Da thao cong", 2500, 3);
					ClearAnimationsEx(giveplayerid);
					SetPlayerSpecialAction(giveplayerid, SPECIAL_ACTION_NONE);
					DeletePVar(giveplayerid, "jailcuffs");
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua bi cong.");
					return 1;
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
				return 1;
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nhan vien hanh phap.");
	}
	return 1;
}

CMD:detain(playerid, params[])
{
	if(IsACop(playerid))
	{
		if(PlayerBusy(playerid) || PlayerTied[playerid] || PlayerInfo[playerid][pJailTime]) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the ap giai ai luc nay.");
		
		if(IsPlayerInAnyVehicle(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay khi dang trong xe.");
			return 1;
		}

		new string[128], giveplayerid, seat;
		if(sscanf(params, "ud", giveplayerid, seat)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /detain [player] [seatid 1-3]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(seat < 1 || seat > 3)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "ID ghe khong duoc tren 3 hoac duoi 1.");
				return 1;
			}
			/*if(IsACop(giveplayerid))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "You can't detain other law enforcement officers.");
				return 1;
			}*/
			if(IsPlayerInAnyVehicle(giveplayerid))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang trong xe, hay dua ra truoc.");
				return 1;
			}
			if (ProxDetectorS(8.0, playerid, giveplayerid))
			{
				if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu ap giai!"); return 1; }
				if(PlayerCuffed[giveplayerid] == 2)
				{
					new carid = gLastCar[playerid];
					if(!(0 < carid < MAX_VEHICLES) || !IsValidVehicle(carid) || GetVehicleVirtualWorld(carid) != GetPlayerVirtualWorld(playerid) || GetVehicleInterior(carid) != GetPlayerInterior(playerid)
						|| GetPlayerVirtualWorld(giveplayerid) != GetPlayerVirtualWorld(playerid) || GetPlayerInterior(giveplayerid) != GetPlayerInterior(playerid)
						|| !IsPlayerInRangeOfVehicle(playerid, carid, 10.0) || !IsPlayerInRangeOfVehicle(giveplayerid, carid, 10.0)) 
					{
						return SendClientMessageEx(playerid, COLOR_GREY, "Ban va nghi pham phai o gan cung mot xe.");
					}

					if(IsSeatAvailable(carid, seat))
					{
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban bi %s ap giai.", GetPlayerNameEx(playerid));
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da ap giai %s.", GetPlayerNameEx(giveplayerid));
						format(string, sizeof(string), "* %s nem %s vao xe.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						GameTextForPlayer(giveplayerid, "~r~Da ap giai", 2500, 3);
						ClearAnimationsEx(giveplayerid);
						TogglePlayerControllable(giveplayerid, false);
						if(GetPVarType(giveplayerid, "DraggedBy")) StopDragging(GetPVarInt(giveplayerid, "DraggedBy"));
						IsPlayerEntering{giveplayerid} = true;
						PutPlayerInVehicle(giveplayerid, carid, seat);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ghe do khong trong!");
						return 1;
					}
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua bi cong.");
					return 1;
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, " Ban chua du gan nguoi do hoac xe!");
				return 1;
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai nhan vien hanh phap!");
	}
	return 1;
}

CMD:drag(playerid, params[]) {
	new target;
	if(sscanf(params, "u", target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /drag [player]");
	
	return StartDragging(playerid, target);
}

CMD:wanted(playerid, params[])
{
	if(IsACop(playerid) || IsAJudge(playerid) || IsAGovernment(playerid) || Job_HasJob(playerid, JOB_LAWYER))
	{
		szMiscArray[0] = 0;
		
		new x,
			szNation[24];

		SendClientMessageEx(playerid, COLOR_GREEN, "Nghi pham dang bi truy na:");
		foreach(new i: Player)
		{
			if(PlayerInfo[i][pWantedLevel] >= 1)
			{
				switch(PlayerInfo[i][pNation]) {
					case 0: szNation = "San Andreas";
					case 1: szNation = "New Robada";
					default: szNation = "Khong co";
				}
				format(szMiscArray, sizeof(szMiscArray), "%s%s: %d (%s)", szMiscArray, GetPlayerNameEx(i),PlayerInfo[i][pWantedLevel], szNation);
				x++;
				if(x > 3) {
					SendClientMessageEx(playerid, COLOR_YELLOW, szMiscArray);
					x = 0;
					format(szMiscArray, sizeof(szMiscArray), " ");
				} else {
					format(szMiscArray, sizeof(szMiscArray), "%s, ", szMiscArray);
				}
			}
		}	
		if(x <= 3 && x > 0)
		{
			szMiscArray[strlen(szMiscArray)-2] = '.';
			SendClientMessageEx(playerid, COLOR_YELLOW, szMiscArray);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Lawyer hoac nhan vien hanh phap!");
	}
	return 1;
}

CMD:ticket(playerid, params[])
{
	if(IsACop(playerid))
	{

		new string[128], giveplayerid, moneys, reason[64];
		if(sscanf(params, "uds[64]", giveplayerid, moneys, reason)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ticket [player] [price] [reason]");
		
		if(!(0 <= giveplayerid < MAX_PLAYERS) || !IsPlayerConnected(giveplayerid)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		
		if(PlayerBusy(playerid) || PlayerTied[playerid]) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
		
		if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(giveplayerid) || GetPlayerInterior(playerid) != GetPlayerInterior(giveplayerid)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");

		if(giveplayerid == playerid)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu phat minh.");
			return 1;
		}

		if(moneys < 1 || moneys > 100000) { SendClientMessageEx(playerid, COLOR_GREY, "Tien phat phai tu $1 den $100,000."); return 1; }
		if(PlayerInfo[giveplayerid][pConnectHours] < 30 && moneys > 5000) { SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi duoi 30 gio chi bi phat toi da $5000"); return 1; }
		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(giveplayerid == playerid) return 1;

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da phat %s so tien $%d, ly do: %s", GetPlayerNameEx(giveplayerid), moneys, reason);
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da phat ban so tien $%d, ly do: %s", GetPlayerNameEx(playerid), moneys, reason);
					format(string, sizeof(string), "* Officer %s viet ve phat va dua cho %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Dung /accept ticket, de chap nhan.");
					TicketOffer[giveplayerid] = playerid;
					SetPVarInt(giveplayerid, "TicketOfferSession", g_arrQueryHandle[playerid]);
					TicketMoney[giveplayerid] = moneys;
					SetPVarString(giveplayerid, "ticketreason", reason);
					return 1;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			return 1;
		}
	}
	return 1;
}

CMD:wheelclamp(playerid, params[])
{
	if(ValidGroup(PlayerInfo[playerid][pMember]) && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iWheelClamps]) {
		new vehicleid = GetClosestCar(playerid, INVALID_VEHICLE_ID, 5.0),
			szMessage[24 + 51 + MAX_PLAYER_NAME];
		if(vehicleid != INVALID_VEHICLE_ID && GetDistanceToCar(playerid, vehicleid) < 5 && !IsPlayerInAnyVehicle(playerid)) {
			if(IsAPlane(vehicleid) || IsWeaponizedVehicle(GetVehicleModel(vehicleid)) || IsABike(vehicleid) || IsABoat(vehicleid))
				return SendClientMessageEx(playerid,COLOR_GREY,"(( Khong the khoa banh xe nay. ))");
			if(WheelClamp{vehicleid}) {
				WheelClamp{vehicleid} = 0;
				format(szMessage, sizeof(szMessage), "* %s thao Wheel Clamp khoi banh truoc cua %s.", GetPlayerNameEx(playerid), GetVehicleName(vehicleid));
				ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessageEx(playerid, COLOR_PURPLE, "(( Da thao Wheel Clamp khoi banh truoc cua xe. ))");
			}
			else {
				SetPVarInt(playerid, "wheelclampvehicle", vehicleid);
				SetPVarInt(playerid, "wheelclampcountdown", 10);
				format(szMessage, sizeof(szMessage), "* %s dang gan Wheel Clamp vao banh truoc cua %s.", GetPlayerNameEx(playerid), GetVehicleName(vehicleid));
				ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessageEx(playerid, COLOR_PURPLE, "(( Dang khoa banh truoc cua xe, vui long cho. ))");
			}
			RemoveVehicleFromMeter(vehicleid);
		} 
		else
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o gan xe nao.");
	}
	else
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co quyen dung lenh nay.");
	return 1;
}
