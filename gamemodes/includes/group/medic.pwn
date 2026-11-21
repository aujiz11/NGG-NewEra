/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Medic Group Type

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

forward ShowPlayerBeaconForMedics(playerid);
public ShowPlayerBeaconForMedics(playerid)
{
	foreach(new i: Player)
	{
		if(IsAMedic(i))
		{
			SetPlayerMarkerForPlayer(i, playerid, COP_GREEN_COLOR);
		}
	}	
	return 1;
}

forward HidePlayerBeaconForMedics(playerid);
public HidePlayerBeaconForMedics(playerid)
{
	foreach(new i: Player)
	{
		if(IsAMedic(i))
		{
			SetPlayerMarkerForPlayer(i, playerid, TEAM_HIT_COLOR);
		}
	}	
	SetPlayerToTeamColor(playerid);
	return 1;
}

Medic_StopMovingPatient(playerid)
{
	if(!GetPVarType(playerid, "MovingStretcher")) return 0;
	new target = GetPVarInt(playerid, "MovingStretcher");
	KillTimer(GetPVarInt(playerid, "TickEMSMove"));
	if(IsPlayerConnected(target) && g_arrQueryHandle[target] == GetPVarInt(playerid, "StretcherSession")) 
	{
		DeletePVar(target, "OnStretcher");
	}
	DeletePVar(playerid, "TickEMSMove");
	DeletePVar(playerid, "MovingStretcher");
	DeletePVar(playerid, "StretcherSession");
	return 1;
}

Medic_CancelStretcher(playerid)
{
	Medic_StopMovingPatient(playerid);
	foreach(new i : Player)
	{
		if(GetPVarType(i, "MovingStretcher") && GetPVarInt(i, "MovingStretcher") == playerid) 
		{
			Medic_StopMovingPatient(i);
		}
	}
	return 1;
}

forward MoveEMS(playerid, session, targetSession);
public MoveEMS(playerid, session, targetSession)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || !GetPVarType(playerid, "MovingStretcher")) return 0;
	if(GetPVarInt(playerid, "StretcherSession") != targetSession) return 0;
	new target = GetPVarInt(playerid, "MovingStretcher");
	if(!IsPlayerConnected(target) || g_arrQueryHandle[target] != targetSession || GetPVarInt(target, "Injured") != 1 || IsPlayerInAnyVehicle(target) || IsPlayerInAnyVehicle(playerid) || PlayerBusy(playerid) || (!IsAMedic(playerid) && !IsFirstAid(playerid))) 
	{
		return Medic_StopMovingPatient(playerid);
	}

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	SetPVarFloat(target, "MedicX", x);
	SetPVarFloat(target, "MedicY", y);
	SetPVarFloat(target, "MedicZ", z);
	SetPVarInt(target, "MedicVW", GetPlayerVirtualWorld(playerid));
	SetPVarInt(target, "MedicInt", GetPlayerInterior(playerid));
	SetPlayerInterior(target, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(target, GetPlayerVirtualWorld(playerid));
	Streamer_UpdateEx(target, x, y, z);
	SetPlayerPos(target, x, y, z);
	ClearAnimationsEx(target);
	ApplyAnimation(target, "SWAT", "gnstwall_injurd", 4.0, false, true, true, true, 0, 1);
	return Medic_StopMovingPatient(playerid);
}

forward KillEMSQueue(playerid);
public KillEMSQueue(playerid)
{
	Medic_CancelStretcher(playerid);
	if(EMSCallTime[playerid] > 0) DisablePlayerCheckpoint(playerid);
	EMSCallTime[playerid] = 0;
	EMSAccepted[playerid] = INVALID_PLAYER_ID;
	foreach(new i : Player)
	{
		if(EMSAccepted[i] == playerid)
		{
			EMSAccepted[i] = INVALID_PLAYER_ID;
			EMSCallTime[i] = 0;
			DisablePlayerCheckpoint(i);
		}
	}
	if(GetPVarType(playerid, "DS_OBJ")) DestroyObject(GetPVarInt(playerid, "DS_OBJ"));
	DeletePVar(playerid, "DS_OBJ");
    DeletePVar(playerid, "Injured");
    DeletePVar(playerid, "InjuredWait");
    DeletePVar(playerid, "EMSAttempt");
	SetPVarInt(playerid, "MedicBill", 1);
	DeletePVar(playerid, "MedicCall");
	DeletePVar(playerid, "EMSWarns");
	DeletePVar(playerid, "_energybar");
	DestroyDynamic3DTextLabel(Text3D:GetPVarInt(playerid, "InjuredTL"));
	DeletePVar(playerid, "InjuredTL");
	SetCameraBehindPlayer(playerid);
	return 1;
}

forward SendEMSQueue(playerid,type);
public SendEMSQueue(playerid,type)
{
    #if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie"))
	{
		KillEMSQueue(playerid);
		SpawnPlayer(playerid);
		return 1;
	}
	if(zombieevent == 1 && GetPVarType(playerid, "pZombieBit"))
	{
 		KillEMSQueue(playerid);
		ClearAnimationsEx(playerid);
		MakeZombie(playerid);
		return 1;
	}
	#endif
	switch (type)
	{
		case 1:
		{
		    Streamer_UpdateEx(playerid, GetPVarFloat(playerid,"MedicX"), GetPVarFloat(playerid,"MedicY"), GetPVarFloat(playerid,"MedicZ"));
			SetPlayerPos(playerid, GetPVarFloat(playerid,"MedicX"), GetPVarFloat(playerid,"MedicY"), GetPVarFloat(playerid,"MedicZ"));
			SetPlayerVirtualWorld(playerid, GetPVarInt(playerid,"MedicVW"));
	  		SetPlayerInterior(playerid, GetPVarInt(playerid,"MedicInt"));

			SetPVarInt(playerid, "EMSAttempt", -1);

			if(GetPlayerInterior(playerid) > 0) Player_StreamPrep(playerid, GetPVarFloat(playerid,"MedicX"), GetPVarFloat(playerid,"MedicY"), GetPVarFloat(playerid,"MedicZ"), FREEZE_TIME);
			GameTextForPlayer(playerid, "~r~Bi thuong~n~~w~/accept death hoac /service ems", 5000, 3);
			ClearAnimationsEx(playerid);
			PlayDeathAnimation(playerid);
			SetHealth(playerid, 100);
			RemoveArmor(playerid);
			if(GetPVarInt(playerid, "usingfirstaid") == 1)
			{
			    firstaidexpire(playerid, g_arrQueryHandle[playerid]);
			}
			SetPVarInt(playerid,"MedicCall",1);
		}
		case 2:
		{
		    SetPVarInt(playerid,"EMSAttempt", 2);
			ClearAnimationsEx(playerid);
            if(!IsPlayerInAnyVehicle(playerid)) ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.0, false, true, true, true, 0, 1);
			SetHealth(playerid, 50); // Set to 50.
			RemoveArmor(playerid);
		}
	}
	return 1;
}

PlayDeathAnimation(playerid) {

	new i = random(5);
	switch(i) {
		case 0: ApplyAnimation(playerid, "KNIFE", "KILL_Knife_Ped_Die", 4.0, false, true, true, true, 0, 1);
		case 1: ApplyAnimation(playerid, "PED", "KO_shot_stom", 4.0, false, true, true, true, 0, 1);
		case 2: ApplyAnimation(playerid, "PED", "KO_shot_stom", 4.0, false, true, true, true, 0, 1);
		case 3: ApplyAnimation(playerid, "PED", "BIKE_fall_off", 4.1, false, true, true, true, 0, 1);
		case 4: ApplyAnimation(playerid, "BASEBALL", "Bat_Hit_3", 4.1, false, true, true, true, 0, 1);
		default: ApplyAnimation(playerid, "FIGHT_E", "Hit_fightkick_B", 4.1, false, true, true, true, 0, 1);
	}
}

Medic_GetPatient(playerid, const params[]) {
	if(PlayerBusy(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the cuu chua luc nay.");

	if(IsAMedic(playerid) || IsFirstAid(playerid))
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /getpt(patient) [player]");

		if(IsPlayerConnected(giveplayerid))
		{
		    if (giveplayerid == playerid)
		    {
		        SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Khong the nhan cuoc goi Emergency Dispatch cua minh!");
				return 1;
		    }
			if(GetPVarInt(giveplayerid,"MedicCall") == 1 && GetPVarInt(giveplayerid, "Injured") == 1 && GetPVarInt(giveplayerid, "EMSAttempt") <= 1)
			{
				if(PlayerInfo[giveplayerid][pJailTime] > 0 && strfind(PlayerInfo[giveplayerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay voi nguoi choi trong tu.");
				if(EMSCallTime[playerid] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Hay hoan tat hoac huy cuoc goi EMS hien tai.");
				foreach(new i : Player)
				{
					if(EMSCallTime[i] > 0 && EMSAccepted[i] == giveplayerid) return SendClientMessageEx(playerid, COLOR_GREY, "Medic khac da nhan cuoc goi nay.");
				}
				format(string, sizeof(string), "EMS Driver %s (%s, R%d) da nhan cuoc goi Emergency Dispatch cho (%d) %s.", GetPlayerNameEx(playerid), arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName], PlayerInfo[playerid][pRank], giveplayerid, GetPlayerNameEx(giveplayerid));
				SendMedicMessage(TEAM_MED_COLOR, string);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan cuoc goi EMS tu %s, diem danh dau hien den khi ban den noi.",GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* EMS Driver %s da nhan cuoc goi EMS, hay cho tai vi tri hien tai.",GetPlayerNameEx(playerid));
				GameTextForPlayer(playerid, "~w~Nguoi goi EMS~n~~r~Den diem do.", 5000, 1);
				EMSCallTime[playerid] = 1;
				EMSAccepted[playerid] = giveplayerid;
				SetPVarInt(giveplayerid, "EMSAttempt", 1);
				PlayerInfo[playerid][pCallsAccepted]++;
				if(GetPlayerInterior(giveplayerid)) SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi nay dang o trong interior.");
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi do chua yeu cau EMS!");
			}
		}
	}
	return 1;
}

stock IsAnAmbulance(carid)
{
	if(!IsValidVehicle(carid)) return 0;
	if(GetVehicleModel(carid) == 416) return 1;
	if(0 <= DynVeh[carid] < MAX_DYNAMIC_VEHICLES)
	{
	    new iDvSlotID = DynVeh[carid], iGroupID = DynVehicleInfo[iDvSlotID][gv_igID];
	    if((0 <= iGroupID < MAX_GROUPS))
	    {
	    	if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_MEDIC) return 1;
			else if(arrGroupData[iGroupID][g_iMedicAccess] != INVALID_DIVISION) return 1;
		}
	}
	return 0;
}

/*
CMD:aid(playerid, params[]) {

	if(IsAMedic(playerid) || IsFirstAid(playerid)) {

	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "   You are not a medic!");
	return 1;
}
*/

CMD:emslist(playerid, params[])
{
	if(!IsAMedic(playerid) && !IsFirstAid(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong phai Medic.");
	
	new zone[MAX_ZONE_NAME], row[160], key[32], count;
	for(new i = 0; i < GetPVarInt(playerid, "EMSListCount"); i++)
	{
		format(key, sizeof(key), "EMSListSession%d", i);
		DeletePVar(playerid, key);
	}
	SetPVarInt(playerid, "EMSListCount", 0);
	szMiscArray[0] = EOS;
	foreach(new i : Player)
	{
		new status = GetPVarInt(i, "EMSAttempt");
		if(status < -1 || status == 0 || status > 3) continue;
		GetPlayer3DZone(i, zone, sizeof(zone));
		switch(status)
		{
			case -1: format(row, sizeof(row), "{FF0000}Cap cuu - %s - %s\n", GetPlayerNameEx(i), zone);
			case 1: format(row, sizeof(row), "{FF0000}Cap cuu - %s - %s\n", GetPlayerNameEx(i), zone);
			case 2: format(row, sizeof(row), "{FFFF00}Da chua - %s - %s\n", GetPlayerNameEx(i), zone);
			case 3: format(row, sizeof(row), "{FF00FF}Da cuu - %s - %s\n", GetPlayerNameEx(i), zone);
		}
		if(count >= sizeof(ListItemTrackId[]) || strlen(szMiscArray) + strlen(row) >= sizeof(szMiscArray)) break;
		strcat(szMiscArray, row, sizeof(szMiscArray));
		ListItemTrackId[playerid][count] = i;
		format(key, sizeof(key), "EMSListSession%d", count);
		SetPVarInt(playerid, key, g_arrQueryHandle[i]);
		count++;
	}
	SetPVarInt(playerid, "EMSListCount", count);
	if(!count) return SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co cuoc goi EMS.");
	ShowPlayerDialogEx(playerid, DIALOG_MEDIC_LIST, DIALOG_STYLE_LIST, "Medic | Dispatch", szMiscArray, "Len duong", "Huy");
	return 1;
}

CMD:loadpt(playerid, params[])
{
	if(PlayerBusy(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the cuu chua luc nay.");
    
	if(IsAMedic(playerid) || IsFirstAid(playerid))
	{
        if(IsPlayerInAnyVehicle(playerid))
		{
            SendClientMessageEx(playerid, COLOR_GREY, "   Khong the dung khi o trong xe!");
            return 1;
        }

        new string[128], giveplayerid, seat;
        if(sscanf(params, "ud", giveplayerid, seat)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /loadpt [player] [seatid]");

        if(IsPlayerConnected(giveplayerid))
		{
            if(giveplayerid != INVALID_PLAYER_ID)
			{
                if(!(2 <= seat <= 3))
				{
                    SendClientMessageEx(playerid, COLOR_GRAD1, "ID ghe khong duoc tren 3 hoac duoi 2.");
                    return 1;
                }
                if(GetPVarInt(giveplayerid, "Injured") != 1)
				{
                    SendClientMessageEx(playerid, COLOR_GREY, "Benh nhan khong bi thuong, khong the dua len xe.");
                    return 1;
                }
                if(IsPlayerInAnyVehicle(giveplayerid))
				{
                    SendClientMessageEx(playerid, COLOR_GREY, "Benh nhan dang trong xe, khong the dua len xe.");
                    return 1;
                }
                new Float:x, Float:y, Float:z;
				GetPlayerPos(giveplayerid, x, y, z);
                if (GetPlayerInterior(playerid) == GetPlayerInterior(giveplayerid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(giveplayerid) && IsPlayerInRangeOfPoint(playerid, 8.0, x, y, z))
				{
                    if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu dua minh len xe!"); return 1; }
                    if(PlayerInfo[giveplayerid][pJailTime] > 0 && strfind(PlayerInfo[giveplayerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay voi nguoi choi trong tu.");
                    // if(GetPVarType(playerid, "MedicAid")) return SendClientMessage(playerid, COLOR_GREY, "This patient requires aid! Use /aid [playerid] to aid them.");
                    new carid = gLastCar[playerid];
                    if(IsAnAmbulance(carid))
					{
                        if(IsVehicleSeatOccupied(carid, seat)) {
							SendClientMessageEx(playerid, COLOR_GREY, "Ghe do da co nguoi.");
							return 1;
						}
						if(GetVehicleInterior(carid) == GetPlayerInterior(playerid) && GetVehicleVirtualWorld(carid) == GetPlayerVirtualWorld(playerid) && IsPlayerInRangeOfVehicle(giveplayerid, carid, 10.0) && IsPlayerInRangeOfVehicle(playerid, carid, 10.0)) {
							SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban duoc paramedic %s dua len xe.", GetPlayerNameEx(playerid));
							SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da dua benh nhan %s len xe.", GetPlayerNameEx(giveplayerid));
							format(string, sizeof(string), "* %s dua %s len %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetVehicleName(carid));
							ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							Medic_CancelStretcher(giveplayerid);
							SetPVarInt(giveplayerid, "EMSAttempt", 3);
							ClearAnimationsEx(giveplayerid);
							IsPlayerEntering{giveplayerid} = true;
							PutPlayerInVehicle(giveplayerid,carid,seat);
							TogglePlayerControllable(giveplayerid, false);
						}
						else SendClientMessageEx(playerid, COLOR_GREY, "Ban va benh nhan phai o gan xe cuu thuong.");
                    }
                    else
					{
                        SendClientMessageEx(playerid, COLOR_GRAD2, "Xe gan nhat cua ban phai la xe cuu thuong!");
                    }
                }
                else
				{
                    SendClientMessageEx(playerid, COLOR_GREY, " Ban khong o du gan nguoi do hoac xe cua minh!");
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
    else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "   Ban khong phai Medic!");
    }
    return 1;
}

CMD:triage(playerid, params[])
{
	if(PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the cuu chua luc nay.");
    if(IsAMedic(playerid) || IsFirstAid(playerid))
	{
 		if(PlayerInfo[playerid][pTriageTime] != 0)
   		{
     		SendClientMessageEx(playerid, COLOR_GREY, "Phai cho 2 phut de dung lenh nay.");
       		return 1;
	    }

	    new string[128], giveplayerid;
	    if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /triage [player]");

   		if(IsPlayerConnected(giveplayerid))
   		{
    	    if(playerid == giveplayerid) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay voi chinh minh.");
			new Float:x, Float:y, Float:z;
			GetPlayerPos(giveplayerid, x, y, z);
			if (GetPlayerInterior(playerid) == GetPlayerInterior(giveplayerid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(giveplayerid) && IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
			{
	    	    new Float: health;
	    	    GetHealth(giveplayerid, health);
	    	    if(health >= 85) SetHealth(giveplayerid, 100);
				else SetHealth(giveplayerid, health+15.0);
	    	    format(string, sizeof(string), "* %s da hoi cho %s 15 mau.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	    	    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				PlayerInfo[playerid][pTriageTime] = 120;
			}
			else
			{
			    SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
			}
 		}
	}
	return 1;
}

CMD:heal(playerid, params[])
{
	if(PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the cuu chua luc nay.");
	new giveplayerid, price = 1000;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /heal [player]");

	if (giveplayerid == playerid)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tu chua cho minh.");
		return 1;
	}

	if(gettime() < GetPVarInt(playerid, "pHealTimer")) return SendClientMessage(playerid, COLOR_GRAD1, "Phai cho 1 phut truoc khi chua tiep.");

	if (IsPlayerConnected(giveplayerid))
	{
		if(IsAMedic(playerid) || IsFirstAid(playerid))
		{
			new Float:X, Float:Y, Float:Z;
	   		GetPlayerPos(giveplayerid, X, Y, Z);

			if(GetPlayerInterior(playerid) != GetPlayerInterior(giveplayerid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(giveplayerid) || !IsPlayerInRangeOfPoint(playerid, 10, X, Y, Z)) return SendClientMessageEx(playerid, TEAM_GREEN_COLOR," Ban khong o gan ho!");

			if(GetPlayerCash(giveplayerid) < 1000) return SendClientMessage(playerid, COLOR_GRAD1, "Nguoi choi do khong du tien dieu tri.");

			if(GetPlayerCash(playerid) > cellmax - price / 2 || Tax > cellmax - price / 2) return SendClientMessageEx(playerid, COLOR_GREY, "Thanh toan nay se vuot gioi han so du.");
			new Float:tempheal;
			GetHealth(giveplayerid,tempheal);
			if(tempheal >= 100.0)
			{
				SendClientMessageEx(playerid, TEAM_GREEN_COLOR,"Nguoi do da day mau.");
				return 1;
			}
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da chua %s, gia $%d.", GetPlayerNameEx(giveplayerid), price);
			GivePlayerCash(playerid, price / 2);
			Tax += price / 2;
			GivePlayerCash(giveplayerid, -price);
			SetHealth(giveplayerid, 100);
			PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
			PlayerPlaySound(giveplayerid, 1150, 0.0, 0.0, 0.0);
			SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc hoi 100 mau voi gia $%d boi %s.",price, GetPlayerNameEx(playerid));

			SetPVarInt(playerid, "pHealTimer", gettime() + 60); // Adding a minute check.

			if(GetPVarType(giveplayerid, "STD"))
			{
				DeletePVar(giveplayerid, "STD");
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban da khoi STD nho Medic.");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	return 1;
}

CMD:getpt(playerid, params[])
{
	Medic_GetPatient(playerid, params);
	return 1;
}

CMD:movept(playerid, params[])
{
	if(PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the cuu chua luc nay.");
	if(IsAMedic(playerid) || IsFirstAid(playerid))
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /movepatient [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid == playerid || IsPlayerInAnyVehicle(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Chon nguoi choi khac bi thuong o ngoai xe.");
			if(GetPVarType(playerid, "MovingStretcher")) return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang di chuyen benh nhan.");
			if(GetPVarInt(giveplayerid,"Injured") == 1)
			{
				if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay khi o trong xe.");
				if(PlayerInfo[giveplayerid][pJailTime] > 0 && strfind(PlayerInfo[giveplayerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay voi nguoi choi trong tu.");
				if(GetPVarInt(giveplayerid, "OnStretcher") == 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do da o tren cang, chua the lam viec nay!");
					return 1;
				}

				new Float:mX, Float:mY, Float:mZ;
				GetPlayerPos(giveplayerid, mX, mY, mZ);
				if(GetPlayerInterior(playerid) != GetPlayerInterior(giveplayerid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(giveplayerid) || !IsPlayerInRangeOfPoint(playerid, 5.0, mX, mY, mZ))
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai o gan benh nhan de di chuyen ho!");
					return 1;
				}
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban co 30 giay de di chuyen hoac nhan nut '{AA3333}FIRE{BFC0C2}'.");
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban duoc %s dat len cang.", GetPlayerNameEx(playerid));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da dat %s len cang, co the di chuyen ho.", GetPlayerNameEx(giveplayerid));
				format(string, sizeof(string), "* %s dat %s len cang va that chat day an toan.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

				SetPVarInt(giveplayerid, "OnStretcher", 1);
				SetPVarInt(playerid, "TickEMSMove", SetTimerEx("MoveEMS", 30000, false, "iii", playerid, g_arrQueryHandle[playerid], g_arrQueryHandle[giveplayerid]));
				SetPVarInt(playerid, "MovingStretcher", giveplayerid);
				SetPVarInt(playerid, "StretcherSession", g_arrQueryHandle[giveplayerid]);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do phai bi thuong moi di chuyen duoc!");
			}
		}
	}
	return 1;
}

CMD:deliverpt(playerid, params[])
{
	if(PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the cuu chua luc nay.");
    if(IsAMedic(playerid) || IsFirstAid(playerid))
	{
        if(IsPlayerInAnyVehicle(playerid))
		{
			new string[128], giveplayerid;
		    if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /deliverpt [player]");

            if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			new carid = GetPlayerVehicleID(playerid);
            new caridex = GetPlayerVehicleID(giveplayerid);
            if(IsAnAmbulance(carid))
			{
                if(carid == caridex)
				{
                    if(GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0 && IsAtDeliverPatientPoint(playerid))
					{
                        if(playerid == giveplayerid)
						{
                            SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the tu giao minh den benh vien!");
                            return 1;
                        }
                        if(GetPVarInt(giveplayerid, "Injured") == 0)
						{
                            return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do khong bi thuong!");
                        }
                        if(playerTabbed[giveplayerid] >= 1)
						{
                            SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang tam dung, chua the giao ho!");
                            return 1;
                        }
                        new group = PlayerInfo[playerid][pMember];
						if(!(0 <= group < MAX_GROUPS) || arrGroupData[group][g_iBudget] < 20000) return SendClientMessageEx(playerid, COLOR_GREY, "To chuc khong du tien tra thuong giao benh nhan.");
						new iHospitalDeliver = GetClosestDeliverPatientPoint(playerid);
						new iHospital = ReturnDeliveryPoint(iHospitalDeliver);
						new nation = ReturnDeliveryPointNation(iHospitalDeliver);
						if(arrHospitalBedData[iHospital][bBedOccupied][GetFreeHospitalBed(iHospital)]) return SendClientMessageEx(playerid, COLOR_GREY, "Benh vien nay khong con giuong trong.");
						if(GetPlayerCash(playerid) > cellmax - 20000 || GetPlayerCash(giveplayerid) < cellmin + 1000
							|| (nation == 0 && Tax > cellmax - 1000) || (nation == 1 && TRTax > cellmax - 1000)) return SendClientMessageEx(playerid, COLOR_GREY, "Thanh toan nay se vuot gioi han so du.");
                        SetHealth(giveplayerid, 100);
                        if(GetPVarType(giveplayerid, "STD"))
						{
							DeletePVar(giveplayerid, "STD");
                            SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban da khoi STD nho benh vien!");
                        }
                        GivePlayerCash(giveplayerid, -1000);
						GivePlayerCash(playerid, 20000);

						//SendClientMessageEx(giveplayerid, TEAM_CYAN_COLOR, "Doc: Your medical bill comes in at $1000. Have a nice day!");
                        SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Ban nhan $20,000 vi giao benh nhan thanh cong!");
						
                        KillEMSQueue(giveplayerid);
                        SetPVarInt(giveplayerid, "_HospitalBeingDelivered", 1);
                        
						switch(nation)
						{
							case 0: Tax += 1000;
							case 1: TRTax += 1000;
						}

						arrGroupData[group][g_iBudget] -= 20000;
						SaveGroup(group);
                        						
						DeliverPlayerToHospital(giveplayerid, iHospital);
                        PlayerInfo[playerid][pPatientsDelivered]++;
                        
						format(string, sizeof(string), "EMS Driver %s has successfully delivered Patient %s to the hospital.",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						GroupLog(PlayerInfo[playerid][pMember], string);
						format(string, sizeof(string), "EMS Driver %s da giao benh nhan %s den benh vien.",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						SendGroupMessage(GROUP_TYPE_MEDIC, TEAM_MED_COLOR, string);
						foreach(new i: Player)
						{
							if(IsFirstAid(i))
							{
								SendClientMessage(i, TEAM_MED_COLOR, string);
							}
						}
						PlayerInfo[giveplayerid][pHydration] = 100;
					}
                    else
					{
                        SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan diem giao benh nhan, hay tim gan benh vien.");
                    }
                }
                else
				{
                    SendClientMessageEx(playerid, COLOR_GRAD2, "Benh nhan phai o trong xe cua ban de giao.");
                }
            }
            else
			{
                SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o trong xe FDSA.");
            }
        }
    }
    return 1;
}

CMD:renderaid(playerid, params[])
{
	if(PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the cuu chua luc nay.");
	if(!(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc to chuc nao.");
	if(GetPVarInt(playerid, "MedVestKit") != 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong mang bo cuu thuong.");
	new target;
	if(sscanf(params, "u", target)) return SendClientMessageEx(playerid, COLOR_GRAD2, "CACH DUNG: /renderaid [player]");
	if(!IsPlayerConnected(target)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
	if(target == playerid) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the tu so cuu minh!");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(target, x, y, z);
	if(GetPlayerInterior(playerid) != GetPlayerInterior(target) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target) || !IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong o gan ban.");
	
	if(!GetPVarType(target, "Injured")) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong bi thuong.");
	
	SetPVarInt(target, "renderaid", playerid);
	SetPVarInt(target, "RenderAidSession", g_arrQueryHandle[playerid]);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban de nghi so cuu %s.", GetPlayerNameEx(target));
	SendClientMessageEx(target, COLOR_LIGHTBLUE, "* %s muon so cuu ban, dung (/accept renderaid) de dong y.", GetPlayerNameEx(playerid));
	return 1;
}
