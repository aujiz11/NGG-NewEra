/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

    	    		  Drug System (Revision)
    			        by Winterfield

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

new dr_iPlayerTimeStamp[MAX_PLAYERS];

CMD:odrughelp(playerid, const params[])
{
	SendClientMessageEx(playerid, COLOR_WHITE,"-----------------------------------------------------------------------------------");
	SendClientMessageEx(playerid, COLOR_GREY, "CHUNG: /mydrugs, /usedrug, /buypot, /buyopium, /plantpot, /plantopium, /pickplant, /checkplant /makeheroin");
	if(IsACop(playerid)) SendClientMessageEx(playerid, COLOR_GREY, "CANH SAT: /destroyplant, /searchcar");
	if(IsAdminLevel(playerid, ADMIN_JUNIOR, 0)) SendClientMessageEx(playerid, COLOR_GREY, "ADMIN: /adestroyplant");
	SendClientMessageEx(playerid, COLOR_WHITE,"-----------------------------------------------------------------------------------");
	return 1;
}

CMD:mydrugs(playerid, params[])
{
	new string[450];
	SendClientMessageEx(playerid, COLOR_WHITE,"-----------------------------------------------------------------------------------");
	for(new i; i < sizeof(Drugs); i++) format(string, sizeof(string),"%s | %s: %dg", string, Drugs[i], PlayerInfo[playerid][pDrugs][i]);
	format(string, sizeof(string),"%s | Hat pot: %d | Hat opium: %d | Ong tiem: %d |", string, PlayerInfo[playerid][pWSeeds], PlayerInfo[playerid][pOpiumSeeds], PlayerInfo[playerid][pSyringes]);
	SendClientMessageEx(playerid, COLOR_GREY, string);
	SendClientMessageEx(playerid, COLOR_WHITE,"-----------------------------------------------------------------------------------");
	return 1;
}

CMD:checkdrugs(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /checkdrugs [player]");
		if(IsPlayerConnected(giveplayerid))
		{
			new string[450];
			SendClientMessageEx(playerid, COLOR_WHITE,"-----------------------------------------------------------------------------------");
			for(new i; i < sizeof(Drugs); i++) format(string, sizeof(string),"%s | %s: %dg", string, Drugs[i], PlayerInfo[giveplayerid][pDrugs][i]);
			format(string, sizeof(string),"%s | Hat pot: %d | Hat opium: %d | Ong tiem: %d |", string, PlayerInfo[giveplayerid][pWSeeds], PlayerInfo[giveplayerid][pOpiumSeeds], PlayerInfo[giveplayerid][pSyringes]);
			SendClientMessageEx(playerid, COLOR_GREY, string);
			SendClientMessageEx(playerid, COLOR_WHITE,"-----------------------------------------------------------------------------------");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:usedrug(playerid, params[])
{
	if(GetPVarInt(playerid, "pDrugTime") > gettime()) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can cho 60 giay truoc khi dung lai ma tuy.");
	if(GetPVarType(playerid, "WatchingTV") || GetPVarType(playerid, "PreviewingTV")) return SendClientMessage(playerid, COLOR_GRAD1, "Khong the dung ma tuy khi dang xem TV.");
	if(HungerPlayerInfo[playerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   Khong the lam vay trong Hunger Games Event!");
   	#if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombies can't use this.");
	#endif
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] || (PlayerInfo[playerid][pJailTime] > 0 && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1))
   		return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam viec nay!");
	if(GetPVarType(playerid, "AttemptingLockPick")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang mo khoa xe, hay cho.");
	if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o dau truong!");
	if(PlayerBoxing[playerid] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung ma tuy khi dang danh nhau.");
	if(UsedCrack[playerid] == 1) return SendClientMessageEx(playerid, COLOR_WHITE, "Can cho 5 giay truoc khi dung them ma tuy.");
	if(PlayerInfo[playerid][pHospital]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");

	new drugstring[16], amount;
	if(sscanf(params, "s[16]d", drugstring, amount))
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /usedrug [drug name] [amount]");
		ListDrugs(playerid);
		return 1;
	}

	if(amount < 1 || amount > 20) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung luong nay.");

	new drug = GetDrugID(drugstring);
	if(drug == -1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /usedrug [drug name] [amount]");
		ListDrugs(playerid);
		return 1;
	}

	if(PlayerInfo[playerid][pDrugs][drug] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du ma tuy.");
	if(drug == 4 && amount != 10) return SendClientMessageEx(playerid, COLOR_GRAD1, "Moi lan chi duoc dung 10 heroin.");
	if(drug == 4 && PlayerInfo[playerid][pSyringes] <= 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can ong tiem. Hay che tao hoac mua tu Craftsman.");
	if(drug != 4 && dr_iPlayerTimeStamp[playerid] > gettime() - 60) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da bi thuong trong phut vua qua");
	if(drug != 4 && GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban chua the lam viec nay.");
	if(!IsPlayerInAnyVehicle(playerid) && drug != 4) ApplyAnimation(playerid,"SMOKING","M_smkstnd_loop",2.1,false,false,false,false,0);

	PlayerInfo[playerid][pDrugs][drug] -= amount;

	SetPVarInt(playerid, "pDrugTime", gettime() + 60);
	GivePlayerDrugEffects(playerid, drug, amount);
	return 1;
}

CMD:buypot(playerid, params[])
{
	new string[256];
	if(!Job_HasJob(playerid, JOB_DRUG_SMUGGLER)) return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong phai Drug Smuggler!");

	for (new i=0; i<MAX_POINTS; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0, DynPoints[i][poPos][0], DynPoints[i][poPos][1], DynPoints[i][poPos][2]) && DynPoints[i][poType] == 1)
		{
			if(GetPlayerMoney(playerid) < 10000) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du $10,000!");
			GivePlayerCashEx(playerid, TYPE_ONHAND, -10000);

			PlayerInfo[playerid][pWSeeds] += 1;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da mua tui hat can sa tai Drug House.");

			format(string, sizeof(string), "* %s mua hat can sa.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
	}
	return 1;
}

CMD:buyopium(playerid, params[])
{
	new string[256];
	if(!Job_HasJob(playerid, JOB_DRUG_SMUGGLER)) return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong phai Drug Smuggler!");
	if(GetPlayerMoney(playerid) < 100000) return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong du tien mua Opium");

	for (new i=0; i<MAX_POINTS; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 5.0, DynPoints[i][poPos][0], DynPoints[i][poPos][1], DynPoints[i][poPos][2]) && DynPoints[i][poType] == 2)
		{
			if(GetPlayerMoney(playerid) < 100000) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du $100,000!");
			GivePlayerCashEx(playerid, TYPE_ONHAND, -100000);

			PlayerInfo[playerid][pOpiumSeeds] += 1;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da mua tui hat thuoc phien tai Drug House.");

			format(string, sizeof(string), "* %s mua hat thuoc phien.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
	}
	return 1;
}

forward DrugEffectTime(playerid);
public DrugEffectTime(playerid)
{
	SyncPlayerTime(playerid);
    SetPlayerDrunkLevel(playerid, 0);
	SetPlayerWeather(playerid, gWeather);

	SendClientMessageEx(playerid, COLOR_GRAD1, "Tac dung phu da het.");
    return 1;
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	dr_iPlayerTimeStamp[playerid] = gettime();
}

GivePlayerDrugEffects(playerid, id, amount)
{
	new Float:health, Float:armour, string[256];
 	GetHealth(playerid, health);
 	GetArmour(playerid, armour);

	switch(id)
	{
		case 0: // Pot
		{
			new Float:increase = amount * 2;
			SetHealth(playerid, health + increase);
			if(health + increase > 100) SetHealth(playerid, 100);

			format(string, sizeof(string), "* %s dung can sa.", GetPlayerNameEx(playerid));
			ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		case 1: // Crack
		{
			new Float:increase = amount * 2;
			SetArmour(playerid, armour + increase);
			if(armour + increase > 100) SetArmour(playerid, 100);

			format(string, sizeof(string), "* %s dung crack.", GetPlayerNameEx(playerid));
			ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		case 2: // Meth
		{
			new Float:increase = amount * 4;
			if(armour < 100 && amount == 20) SetArmour(playerid, 100);
			SetHealth(playerid, armour + increase);

			if(health + increase > 150) SetHealth(playerid, 150);

			format(string, sizeof(string), "* %s dung meth.", GetPlayerNameEx(playerid));
			ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		case 3: // Ecstasy
		{
			new Float:increase = amount * 5;
			SetHealth(playerid, health + increase);
			SetArmour(playerid, armour + increase);

			if(health + increase > 150) SetHealth(playerid, 150);
			if(armour + increase > 150) SetArmour(playerid, 150);

			format(string, sizeof(string), "* %s dung ecstasy.", GetPlayerNameEx(playerid));
			ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		case 4: // Heroin
		{
			if(GetPVarInt(playerid, "Injured") != 1)
			{
				SetPVarInt(playerid, "HeroinLastUsed", gettime());
				PlayerInfo[playerid][pSyringes] -= 1;

				SetPVarInt(playerid, "InjectHeroinStanding", SetTimerEx("InjectHeroinStanding", 5000, false, "i", playerid));

				if(!IsPlayerInAnyVehicle(playerid)) ApplyAnimation(playerid,"SMOKING","M_smkstnd_loop",2.1,false,false,false,false,0);

				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban tiem heroin, tac dung se bat dau sau 5 giay.");
				format(string, sizeof(string), "* %s tu tiem heroin.", GetPlayerNameEx(playerid));
				ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
        		return 1;
			}

			SetPVarInt(playerid, "HeroinLastUsed", gettime());
			PlayerInfo[playerid][pSyringes] -= 1;

			SetPVarInt(playerid, "Health", 30);
			SetPVarInt(playerid, "InjectHeroin", SetTimerEx("InjectHeroin", 5000, false, "i", playerid));

			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban tiem heroin, tac dung se bat dau sau 5 giay.");
			format(string, sizeof(string), "* %s tu tiem heroin.", GetPlayerNameEx(playerid));
			ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
	}

	if(id != 4) GivePlayerDrugSideEffect(playerid, id, amount);
	return 1;
}

forward InjectHeroin(playerid);
public InjectHeroin(playerid)
{
    KillEMSQueue(playerid);
	ClearAnimationsEx(playerid);
	SetHealth(playerid, 30);
	SetPVarInt(playerid, "HeroinEffect", SetTimerEx("HeroinEffect", 1000, true, "i", playerid));

	SendClientMessageEx(playerid, COLOR_GREEN, "Heroin bat dau co tac dung.");
	return 1;
}

forward HeroinEffectStanding(playerid);
public HeroinEffectStanding(playerid)
{
	SetPVarInt(playerid, "HeroinDamageResist", 0);
	SendClientMessageEx(playerid, COLOR_GREEN, "Heroin da het tac dung.");
	return 1;
}

forward HeroinEffect(playerid);
public HeroinEffect(playerid)
{
	if(GetPVarInt(playerid, "Health") != 0)
	{
		SetPVarInt(playerid, "Health", GetPVarInt(playerid, "Health")-1);
		SetHealth(playerid, GetPVarInt(playerid, "Health"));
	}
	else
	{
	    KillTimer(GetPVarInt(playerid, "HeroinEffect"));
	    DeletePVar(playerid, "HeroinEffect");
	}
	return 1;
}

forward InjectHeroinStanding(playerid);
public InjectHeroinStanding(playerid)
{
	SetPVarInt(playerid, "HeroinDamageResist", 1);
	SendClientMessageEx(playerid, COLOR_GREEN, "Heroin bat dau co tac dung.");
	SetPVarInt(playerid, "HeroinEffectStanding", SetTimerEx("HeroinEffectStanding", 30000, false, "i", playerid));
	return 1;
}

GivePlayerDrugSideEffect(playerid, id, amount)
{
	switch(id)
	{
		case 0:
		{
			SetPlayerDrunkLevel(playerid, 50000);
			SetPlayerWeather(playerid, 9);
			SetPlayerTime(playerid, 0, 0);
		}
		case 1:
		{
			SetPlayerDrunkLevel(playerid, 50000);
			SetPlayerWeather(playerid, 19);
			SetPlayerTime(playerid, 0, 0);
		}
		case 2:
		{
			SetPlayerDrunkLevel(playerid, 50000);
			SetPlayerWeather(playerid, 111);
			SetPlayerTime(playerid, 0, 0);
		}
		case 3:
		{
			SetPlayerDrunkLevel(playerid, 50000);
			SetPlayerWeather(playerid, 700);
			SetPlayerTime(playerid, 0, 0);
		}
		default: return 1;
	}
	switch(amount)
	{
		case 1 .. 2: SetTimerEx("DrugEffectTime", 10000, false, "i", playerid);
		case 3 .. 7: SetTimerEx("DrugEffectTime", 15000, false, "i", playerid);
		case 8 .. 12: SetTimerEx("DrugEffectTime", 20000, false, "i", playerid);
		case 13 .. 16: SetTimerEx("DrugEffectTime", 25000, false, "i", playerid);
		case 17 .. 20: SetTimerEx("DrugEffectTime", 30000, false, "i", playerid);
		default: SetTimerEx("DrugEffectTime", 30000, false, "i", playerid);
	}
	return 1;
}

GetDrugName(id)
{
	switch(id)
	{
		case 0: szMiscArray = "Pot";
		case 1: szMiscArray = "Crack";
		case 2: szMiscArray = "Meth";
		case 3: szMiscArray = "Ecstasy";
		case 4: szMiscArray = "Heroin";
	}
	return szMiscArray;
}

ListDrugs(playerid)
{
	szMiscArray[0] = 0;
	for(new i; i < sizeof(Drugs); ++i)
	{
		format(szMiscArray, sizeof(szMiscArray),"%s | %s | %s | %s | %s", Drugs[0], Drugs[1], Drugs[2], Drugs[3], Drugs[4]);
	}

	SendClientMessageEx(playerid, COLOR_GRAD1, szMiscArray);
}

GetDrugID(const Drug[])
{
	for(new i; i < sizeof(Drugs); ++i) {

		if(strcmp(Drugs[i], Drug, true) == 0) return i;
	}
	return -1;
}

IncreaseSmugglerLevel(playerid)
{

    if(PlayerInfo[playerid][pDoubleEXP] > 0)
    {
        PlayerInfo[playerid][pDrugSmuggler] += 2;
        // PlayerInfo[playerid][pXP] += PlayerInfo[playerid][pLevel] * XP_RATE * 2;
    }
    else
    {
        PlayerInfo[playerid][pDrugSmuggler] += 1;
        // PlayerInfo[playerid][pXP] += PlayerInfo[playerid][pLevel] * XP_RATE;
    }
    return 1;
}

Smuggle_VehicleLoad(playerid, iTargetID, iVehID)
{
	new iTotalAmount;

	szMiscArray = "Nguyen lieu\tSo luong trong xe\n";

	if(iTotalAmount == 0) {
		szMiscArray[0] = 0;
		szMiscArray = "Ma tuy\tSo luong trong xe\n";
		for(new i; i < sizeof(Drugs); ++i) {

			if(PlayerVehicleInfo[iTargetID][iVehID][pvDrugs][i] > 0) {

				format(szMiscArray, sizeof(szMiscArray), "%s%s\t%d\n", szMiscArray, Drugs[i], PlayerVehicleInfo[iTargetID][iVehID][pvDrugs][i]);
				iTotalAmount += PlayerVehicleInfo[iTargetID][iVehID][pvDrugs][i];
			}
		}
		if(iTotalAmount == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Xe nay khong co ma tuy.");
	}
	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Xe | Kien ma tuy", szMiscArray, "Chon", "");

	SendClientMessageEx(playerid, COLOR_GREEN, "_________ %s | Kho ma tuy _________", GetVehicleName(iVehID));
	SendClientMessageEx(playerid, COLOR_GRAD1, "Tong: %d don vi.", iTotalAmount);
	SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________________");
	return 1;
}

Character_Actor(playerid, choice)
{
	switch(choice) {

		case 0:	{

			PlayerInfo[playerid][pModel] = GetPlayerSkin(playerid);

			new Float:fPos[4],
				iVW = GetPlayerVirtualWorld(playerid),
				iActorID,
				Float:fHealth;

			GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
			GetPlayerFacingAngle(playerid, fPos[3]);
			GetHealth(playerid, fHealth);
			iActorID = CreateActor(PlayerInfo[playerid][pModel], fPos[0], fPos[1], fPos[2], fPos[3]);
			SetActorVirtualWorld(iActorID, iVW);
			SetActorInvulnerable(iActorID, false);
			SetActorHealth(iActorID, fHealth);
			SetPVarInt(playerid, PVAR_TEMPACTOR, iActorID);
			format(szMiscArray, sizeof(szMiscArray), "%s (%d)", GetPlayerNameEx(playerid), playerid);
			SetPVarInt(playerid, PVAR_TEMPTEXT, _:CreateDynamic3DTextLabel(szMiscArray, COLOR_WHITE, fPos[0], fPos[1], fPos[2] + 1.0, 5.0, .worldid = iVW));

		}
		case 1:	{

			DestroyActor(GetPVarInt(playerid, PVAR_TEMPACTOR));

			#if defined TEXTLABEL_DEBUG
			Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, Text3D:GetPVarInt(playerid, PVAR_TEMPTEXT), E_STREAMER_EXTRA_ID, 6);
			#endif

			DestroyDynamic3DTextLabel(Text3D:GetPVarInt(playerid, PVAR_TEMPTEXT));
			DeletePVar(playerid, PVAR_TEMPACTOR);
			DeletePVar(playerid, PVAR_TEMPTEXT);
		}
	}
}

// PLANT SYSTEM //

stock LoadPlants() {
	printf("[LoadPlants] Loading data from database...");
	mysql_tquery(MainPipeline, "SELECT * FROM `plants`", "PlantsLoadQuery", "");
}

forward PlantsLoadQuery();
public PlantsLoadQuery() {

	new
		iRows,
		iIndex;

	cache_get_row_count(iRows);

	while((iIndex < iRows))
	{
		cache_get_value_name_int(iIndex, "Owner", Plants[iIndex][pOwner]);
		cache_get_value_name_int(iIndex, "Object", Plants[iIndex][pObject]);
		cache_get_value_name_int(iIndex, "PlantType", Plants[iIndex][pPlantType]);
		cache_get_value_name_float(iIndex, "PositionX", Plants[iIndex][pPos][0]);
		cache_get_value_name_float(iIndex, "PositionY", Plants[iIndex][pPos][1]);
		cache_get_value_name_float(iIndex, "PositionZ", Plants[iIndex][pPos][2]);
		cache_get_value_name_int(iIndex, "Virtual", Plants[iIndex][pVirtual]);
		cache_get_value_name_int(iIndex, "Interior", Plants[iIndex][pInterior]);
		cache_get_value_name_int(iIndex, "Growth", Plants[iIndex][pGrowth]);
		cache_get_value_name_int(iIndex, "Expires", Plants[iIndex][pExpires]);
		cache_get_value_name_int(iIndex, "DrugsSkill", Plants[iIndex][pPlantDrugsSkill]);

		if(Plants[iIndex][pOwner] != 0)
		{
		    Plants[iIndex][pObjectSpawned] = CreateDynamicObject(Plants[iIndex][pObject], Plants[iIndex][pPos][0], Plants[iIndex][pPos][1], Plants[iIndex][pPos][2], 0.0, 0.0, 0.0, Plants[iIndex][pVirtual], Plants[iIndex][pInterior]);
		}
		iIndex++;
	}
	if(iIndex > 0) printf("[LoadPlants] Successfully loaded %d plants", iIndex);
	else printf("[LoadPlants] Error: Failed to load any plants!");
	return 1;
}

stock SavePlant(plant)
{
	new query[300];
	mysql_format(MainPipeline, query, sizeof(query), "UPDATE `plants` SET `Owner` = %d, `Object` = %d, `PlantType` = %d, `PositionX` = %f, `PositionY` = %f, `PositionZ` = %f, `Virtual` = %d, \
	`Interior` = %d, `Growth` = %d, `Expires` = %d, `DrugsSkill` = %d WHERE `PlantID` = %d",Plants[plant][pOwner], Plants[plant][pObject], Plants[plant][pPlantType], Plants[plant][pPos][0], Plants[plant][pPos][1], Plants[plant][pPos][2],
	Plants[plant][pVirtual], Plants[plant][pInterior], Plants[plant][pGrowth], Plants[plant][pExpires], Plants[plant][pPlantDrugsSkill], plant+1);
	mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
	return 1;
}

stock SavePlants()
{
	new i = 0;
	while(i < MAX_PLANTS)
	{
		SavePlant(i);
		i++;
	}
	if(i > 0) printf("[plant] %i plants saved", i);
	else printf("[plant] Error: No plants saved!");
	return 1;
}

CMD:makeheroin(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 15.0, -882.2048,1109.3385,5442.8193))
	    return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o phong tinh che.");

	if(PlayerInfo[playerid][pRawOpium] == 0)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co thuoc phien tho de tinh che.");

	if(Purification[0] == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Moi lan chi mot nguoi duoc tinh che thuoc phien.");

	new szMessage[128];
	SendClientMessageEx(playerid, COLOR_GREEN, "Can cho 30 giay de tinh che xong.");

    format(szMessage, sizeof(szMessage), "* %s bat dau tinh che.", GetPlayerNameEx(playerid));
	ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

	Purification[0] = 1;
	SetPVarInt(playerid, "AttemptPurify", SetTimerEx("AttemptPurify", 1000, true, "i", playerid));
	return 1;
}

CMD:plantopium(playerid, params[])
{
 	if(PlayerInfo[playerid][pOpiumSeeds] > 0)
 	{
		if(PlayerInfo[playerid][pWeedObject] > 0)
		{
		    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da co cay dang lon." );
		    return 1;
		}
		if(GetPlayerInterior(playerid) == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can o trong noi that!");
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the gieo hat trong xe!");
		for(new i = 0; i < MAX_PLANTS; ++i)
		{
		    if(Plants[i][pObject] == 0)
		    {
		        new
					szMessage[48],
					Float:xyz[3];

                ApplyAnimation(playerid,"BOMBER","BOM_Plant_Crouch_In", 4.0, false, false, false, false, 0, 1);
				SendClientMessageEx(playerid, COLOR_GREEN, "Da trong thuoc phien, can khoang 2 gio de lon.");
		        GetPlayerPos(playerid, xyz[0], xyz[1], xyz[2]);
		        xyz[2] -= 1.0;

		        PlayerInfo[playerid][pOpiumSeeds]--;
		        PlayerInfo[playerid][pWeedObject] = 1;
				PlacePlant(i, GetPlayerSQLId(playerid), 2, 859, PlayerInfo[playerid][pDrugSmuggler], xyz[0], xyz[1], xyz[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
				SavePlant(i);
				new string[128];
				format(string, sizeof(string), "%s(%d) (IP:%s) has placed opium plant (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), i);
				Log("logs/plant.log", string);
				format(szMessage, sizeof(szMessage), "* %s trong thuoc phien.", GetPlayerNameEx(playerid));
				ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "May chu da dat gioi han so cay. Hay thu lai sau!");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Khong du hat thuoc phien, hay mua tai Crack House (/buyopium).");
	return 1;
}

CMD:plantpot(playerid, params[])
{
 	if(PlayerInfo[playerid][pWSeeds] > 0)
 	{
		if(PlayerInfo[playerid][pWeedObject] > 0)
		{
		    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da co cay dang lon." );
		    return 1;
		}
		if(GetPlayerInterior(playerid) == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can o trong noi that!");
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the gieo hat trong xe!");
		for(new i = 0; i < MAX_PLANTS; ++i)
		{
		    if(Plants[i][pObject] == 0)
		    {
		        new
					szMessage[48],
					Float: xyz[3];

                ApplyAnimation(playerid,"BOMBER","BOM_Plant_Crouch_In", 4.0, false, false, false, false, 0, 1);
				SendClientMessageEx(playerid, COLOR_GREEN, "Da trong can sa, can khoang 20-45 phut de lon.");
		        GetPlayerPos(playerid, xyz[0], xyz[1], xyz[2]);
				xyz[2] -= 1.5;

		        Plants[i][pPlantDrugsSkill] = PlayerInfo[playerid][pDrugSmuggler];
		        PlayerInfo[playerid][pWeedObject] = 1;
		        PlayerInfo[playerid][pWSeeds]--;
                PlacePlant(i, GetPlayerSQLId(playerid), 1, 19473, PlayerInfo[playerid][pDrugSmuggler], xyz[0], xyz[1], xyz[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
                SavePlant(i);
                new string[128];
				format(string, sizeof(string), "%s(%d) (IP:%s) has placed weed plant (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), i);
				Log("logs/plant.log", string);
				format(szMessage, sizeof(szMessage), "* %s trong can sa.", GetPlayerNameEx(playerid));
				ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "May chu da dat gioi han so cay.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Khong du hat can sa, hay mua tai Drug House (/buypot).");
	return 1;
}

CMD:adestroyplant(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {

		new
			iTargetID;

		if(sscanf(params, "u", iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /adestroyplant [player]");
		}
		else if(IsPlayerConnected(iTargetID)) {

			for(new i = 0; i < MAX_PLANTS; ++i)
			{
			    if(Plants[i][pOwner] == GetPlayerSQLId(iTargetID))
			    {

                    foreach(new z : Player)
					{
						if(Plants[i][pOwner] == GetPlayerSQLId(z))
						{
							PlayerInfo[z][pWeedObject] = 0;
						}
					}
					SendClientMessageEx(playerid, COLOR_GREY, "Ban da pha cay cua %s.", GetPlayerNameEx(iTargetID), Plants[i][pGrowth]);

					SendClientMessageEx(iTargetID, COLOR_GREY, "Admin %s da pha cay cua ban.", GetPlayerNameEx(playerid), Plants[i][pGrowth]);
                    new string[128];
					format(string, sizeof(string), "%s (IP:%s) has destroyed %s(%d) (IP:%s) plant (%d)", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), GetPlayerIpEx(iTargetID), i);
					Log("logs/plant.log", string);
                    PlayerInfo[iTargetID][pWeedObject] = 0;
                    DestroyPlant(i);
                    SavePlant(i);
					return 1;
			    }
			}
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:destroyplant(playerid, params[])
{
	if(IsACop(playerid) || IsAMedic(playerid))
	{
		for(new i = 0; i < MAX_PLANTS; ++i)
		{
			if(IsValidDynamicObject(Plants[i][pObjectSpawned]) && IsPlayerInRangeOfPoint(playerid, 2.5, Plants[i][pPos][0], Plants[i][pPos][1], Plants[i][pPos][2]))
			{
				if(GetPlayerVirtualWorld(playerid) == Plants[i][pVirtual] && GetPlayerInterior(playerid) == Plants[i][pInterior]) {

					new
						szMessage[128];

					ApplyAnimation(playerid,"BOMBER","BOM_Plant_Crouch_Out", 4.0, false, false, false, false, 0, 1);

					switch(Plants[i][pPlantType]) {
	    				case 1:
					    {
							SendClientMessageEx(playerid, COLOR_GREY, "* Ban tich thu cay can sa nang %d grams.", Plants[i][pGrowth]);
							format(szMessage, sizeof(szMessage), "* %s tich thu cay can sa.", GetPlayerNameEx(playerid), GetPlayerNameEx(i));
							ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							foreach(new z : Player)
							{
								if(Plants[i][pOwner] == GetPlayerSQLId(z))
								{
									PlayerInfo[z][pWeedObject] = 0;
								}
							}
							format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has destroyed weed plant (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), i);
							Log("logs/plant.log", szMessage);
							DestroyPlant(i);
							SavePlant(i);
							return 1;
						}
						case 2:
						{
						    new Grams = Random(10, 30);
							SendClientMessageEx(playerid, COLOR_GREY, "* Ban tich thu cay thuoc phien nang %d milligrams.", Grams);
							format(szMessage, sizeof(szMessage), "* %s tich thu cay opium.", GetPlayerNameEx(playerid), GetPlayerNameEx(i));
							ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							foreach(new z : Player)
							{
								if(Plants[i][pOwner] == GetPlayerSQLId(z))
								{
									PlayerInfo[z][pWeedObject] = 0;
								}
							}
							format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has destroyed opium plant (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), i);
							Log("logs/plant.log", szMessage);
							DestroyPlant(i);
							SavePlant(i);
							return 1;
						}
					}
				}
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan cay.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nhan vien hanh phap.");
	}
	return 1;
}

CMD:checkplant(playerid, params[])
{
    for(new i = 0; i < MAX_PLANTS; ++i)
	{
		if(IsValidDynamicObject(Plants[i][pObjectSpawned]) && IsPlayerInRangeOfPoint(playerid, 2.5, Plants[i][pPos][0], Plants[i][pPos][1], Plants[i][pPos][2]))
		{
		    if(GetPlayerVirtualWorld(playerid) == Plants[i][pVirtual] && GetPlayerInterior(playerid) == Plants[i][pInterior])
		    {
		        switch(Plants[i][pPlantType])
		        {
		            case 1:
		            {
		                if(Plants[i][pGrowth] > 10)
		                {

							SendClientMessageEx(playerid, COLOR_WHITE, "Cay dang co %i grams, dung /pickplant de thu hoach.", Plants[i][pGrowth]);
							return 1;
						}
						else SendClientMessageEx(playerid, COLOR_YELLOW, "Cay chua the thu hoach.");
						return 1;
					}
					case 2:
					{
					    if(Plants[i][pGrowth] >= 120)
					    {
							SendClientMessageEx(playerid, COLOR_WHITE, "Cay da san sang, dung /pickplant de thu hoach.");
							return 1;
						}
						else SendClientMessageEx(playerid, COLOR_WHITE, "Cay thuoc phien can them thoi gian de lon.");
						return 1;
					}
				}
		    }
		}
	}
	return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan cay.");
}

CMD:pickplant(playerid, params[])
{
	for(new i = 0; i < MAX_PLANTS; ++i)
	{
		if(IsValidDynamicObject(Plants[i][pObjectSpawned]) && IsPlayerInRangeOfPoint(playerid, 2.5, Plants[i][pPos][0], Plants[i][pPos][1], Plants[i][pPos][2]))
		{
		    if(GetPlayerVirtualWorld(playerid) == Plants[i][pVirtual] && GetPlayerInterior(playerid) == Plants[i][pInterior])
		    {
		        switch(Plants[i][pPlantType])
		        {
		            case 1:
		            {
						if(Plants[i][pGrowth] > 10)
						{
							new szMessage[128];

							ApplyAnimation(playerid,"BOMBER","BOM_Plant_Crouch_Out", 4.0, false, false, false, false, 0, 1);

							SendClientMessageEx(playerid, COLOR_GREY, "Da thu hoach cay va nhan %d grams can sa.", Plants[i][pGrowth]);
							format(szMessage, sizeof(szMessage), "* %s thu hoach cay can sa.", GetPlayerNameEx(playerid));
							ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                            foreach(new z : Player)
							{
								if(Plants[i][pOwner] == GetPlayerSQLId(z))
								{
									PlayerInfo[z][pWeedObject] = 0;
								}
							}
							format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has picked weed plant (%d) and recieved %d grams", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), i, Plants[i][pGrowth]);
							Log("logs/plant.log", szMessage);
							PlayerInfo[playerid][pDrugs][0] += Plants[i][pGrowth];
							DestroyPlant(i);
							SavePlant(i);
							return 1;
						}
						else SendClientMessageEx(playerid, COLOR_GREY, "Cay chua the thu hoach.");
						return 1;
					}
					case 2:
					{
					    if(Plants[i][pGrowth] >= 120)
					    {
							new szMessage[128],
								Grams = Random(10, 30);

							ApplyAnimation(playerid,"BOMBER","BOM_Plant_Crouch_Out", 4.0, false, false, false, false, 0, 1);

							SendClientMessageEx(playerid, COLOR_GREY, "Da thu hoach cay va nhan %d milligrams thuoc phien.", Grams);
							format(szMessage, sizeof(szMessage), "* %s thu hoach cay opium.", GetPlayerNameEx(playerid));
							ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							foreach(new z : Player)
							{
								if(Plants[i][pOwner] == GetPlayerSQLId(z))
								{
									PlayerInfo[z][pWeedObject] = 0;
								}
							}
							format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has picked opium plant (%d) and recieved %d milligrams", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), i, Grams);
							Log("logs/plant.log", szMessage);
							PlayerInfo[playerid][pRawOpium] += Grams;
							DestroyPlant(i);
							SavePlant(i);
							return 1;
					    }
					    else SendClientMessageEx(playerid, COLOR_GREY, "Cay chua the thu hoach.");
						return 1;
					}
				}
	   		}
		}
	}
	return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan cay.");
}

forward AttemptPurify(playerid);
public AttemptPurify(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid, 5.0, -882.2048,1109.3385,5442.8193))
	{
	    if(playerTabbed[playerid] != 0)
		{
   			SendClientMessageEx(playerid, COLOR_GREY, "Ban da alt-tab khi dang tinh che.");
			Purification[0] = 0;
	    	KillTimer(GetPVarInt(playerid, "AttemptPurify"));
	    	DeletePVar(playerid, "PurifyTime");
	    	DeletePVar(playerid, "AttemptPurify");
    		return 1;
		}
	    if(GetPVarInt(playerid, "PurifyTime") == 30)
	    {
	        new szMessage[128];
	        if(PlayerInfo[playerid][pRawOpium] > 30)
	        {
				SendClientMessageEx(playerid, COLOR_GREEN, "Da tinh che %d milligrams heroin!", 30);

	        	format(szMessage, sizeof(szMessage), "* %s tinh che thanh cong %d milligrams heroin.", GetPlayerNameEx(playerid), 30);
				ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

				PlayerInfo[playerid][pDrugs][4] += 30;
	        	PlayerInfo[playerid][pRawOpium] -= 30;
            	KillTimer(GetPVarInt(playerid, "AttemptPurify"));
	        	Purification[0] = 0;
	        	DeletePVar(playerid, "PurifyTime");
	        	DeletePVar(playerid, "AttemptPurify");
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREEN, "Da tinh che %d milligrams heroin!", PlayerInfo[playerid][pRawOpium]);

	        	format(szMessage, sizeof(szMessage), "* %s tinh che thanh cong %d milligrams heroin.", GetPlayerNameEx(playerid), PlayerInfo[playerid][pRawOpium]);
				ProxDetector(25.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

				PlayerInfo[playerid][pDrugs][4] += PlayerInfo[playerid][pRawOpium];
	        	PlayerInfo[playerid][pRawOpium] = 0;
            	KillTimer(GetPVarInt(playerid, "AttemptPurify"));
	        	Purification[0] = 0;
	        	DeletePVar(playerid, "PurifyTime");
	        	DeletePVar(playerid, "AttemptPurify");
			}
		}
	    else
	    {
	    	SetPVarInt(playerid, "PurifyTime", GetPVarInt(playerid, "PurifyTime")+1);
		}
	}
	else
	{
	    DeletePVar(playerid, "PurifyTime");
	    Purification[0] = 0;
	    KillTimer(GetPVarInt(playerid, "AttemptPurify"));
	    DeletePVar(playerid, "AttemptPurify");
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban da dung tinh che.");
	}
	return 1;
}

GetMaxDrugsAllowed(iDrugID) {


	switch(iDrugID) {

		case 0: return 1000;
		case 1: return 1000;
		case 2: return 1000;
		case 3: return 1000;
		case 4: return 1000;
		case 5: return 1000;
		case 6: return 1000;
		case 7: return 1000;
		case 8: return 1000;
		case 9: return 1000;
		case 10: return 1000;
		case 11: return 1000;
		case 12: return 1000;
		case 13: return 1000;
		case 14: return 1000;
	}
	return 0;
}

PlacePlant(id, ownerid, planttype, objectid, drugskill, Float:x, Float:y, Float:z, virtualworld, interior)
{
    Plants[id][pObjectSpawned] = 0;
	Plants[id][pOwner] = ownerid;
	Plants[id][pPlantType] = planttype;
	Plants[id][pObject] = objectid;
	Plants[id][pGrowth] = 0;
	Plants[id][pPos][0] = x;
	Plants[id][pPos][1] = y;
	Plants[id][pPos][2] = z;
	Plants[id][pVirtual] = virtualworld;
	Plants[id][pInterior] = interior;
	Plants[id][pExpires] = gettime()+86400;
	Plants[id][pPlantDrugsSkill] = drugskill;
	Plants[id][pObjectSpawned] = CreateDynamicObject(objectid, x, y, z, 0.0, 0.0, 0.0, virtualworld, interior);
	return id;
}

DestroyPlant(i)
{
    DestroyDynamicObject(Plants[i][pObjectSpawned]);
	Plants[i][pObjectSpawned] = 0;
	Plants[i][pOwner] = 0;
	Plants[i][pPlantType] = 0;
	Plants[i][pObject] = 0;
	Plants[i][pGrowth] = 0;
	Plants[i][pPos][0] = 0.0;
	Plants[i][pPos][1] = 0.0;
	Plants[i][pPos][2] = 0.0;
	Plants[i][pVirtual] = 0;
	Plants[i][pInterior] = 0;
	Plants[i][pExpires] = 0;
	Plants[i][pPlantDrugsSkill] = 0;
	if(IsValidDynamicObject(Plants[i][pObjectSpawned])) DestroyDynamicObject(Plants[i][pObjectSpawned]);
	return i;
}

PlantTimer()
{
	szMiscArray[0] = 0;
	for(new i = 0; i < MAX_PLANTS; i++)
	{
		if(IsValidDynamicObject(Plants[i][pObjectSpawned]))
		{
			if(Plants[i][pExpires] > gettime())
			{
				switch(Plants[i][pPlantType])
				{
					case 1:
					{
						if(Plants[i][pGrowth] < 45)
						{
							switch(Plants[i][pPlantDrugsSkill])
							{
								case 0 .. 50: Plants[i][pGrowth] += 1;
								case 51 .. 100: Plants[i][pGrowth] += 2;
								case 101 .. 200: Plants[i][pGrowth] += 3;
								case 201 .. 400: Plants[i][pGrowth] += 4;
								default: Plants[i][pGrowth] += 5;
							}
						}
					}
					case 2:
					{
						if(Plants[i][pGrowth] < 120) Plants[i][pGrowth] += 1;
						if(Plants[i][pGrowth] == 120)
						{
							DestroyDynamicObject(Plants[i][pObjectSpawned]);
							Plants[i][pObjectSpawned] = CreateDynamicObject(862, Plants[i][pPos][0], Plants[i][pPos][1], Plants[i][pPos][2], 0.0, 0.0, 0.0, Plants[i][pVirtual], Plants[i][pInterior]);
							Plants[i][pGrowth] = 121;
							Plants[i][pObject] = 862;
							format(szMiscArray, sizeof(szMiscArray), "Opium plant (%d) is ready to be picked.", i);
							Log("logs/plant.log", szMiscArray);
						}
					}
				}
			}
			else if(Plants[i][pExpires] == 0) { }
			else
			{
				format(szMiscArray, sizeof(szMiscArray), "Plant (%d) has expired.", i);
				Log("logs/plant.log", szMiscArray);
				DestroyPlant(i);
				SavePlant(i);
			}
		}
	}
}
