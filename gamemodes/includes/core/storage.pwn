/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Storage System

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

// TODO: implement Bag/Backpack/Briefcase ownership, equipping, capacity checks, transfers and save/load before enabling container selectors.
stock TransferStorage(playerid, storageid, fromplayerid, fromstorageid, itemid, amount, price, special)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid}
		|| GetPlayerSQLId(playerid) <= 0 || amount <= 0 || storageid != 0 || price != -1) return 0;

	new sourceid, destination, source, query[512];
	if(itemid == 1) {
		if(fromplayerid < 0 || fromplayerid >= MAX_PLAYERS || fromplayerid == playerid || fromstorageid != 0 || special != -1
			|| !IsPlayerConnected(fromplayerid) || !gPlayerLogged{fromplayerid}) return 0;
		sourceid = GetPlayerSQLId(fromplayerid);
		if(sourceid <= 0 || sourceid == GetPlayerSQLId(playerid) || PlayerInfo[fromplayerid][pCash] < amount
			|| PlayerInfo[playerid][pCash] < 0 || PlayerInfo[playerid][pCash] > cellmax - amount) return 0;
		source = PlayerInfo[fromplayerid][pCash] - amount;
		destination = PlayerInfo[playerid][pCash] + amount;
		mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` a JOIN `accounts` b ON b.`id`=%d SET a.`Money`=%d,b.`Money`=%d WHERE a.`id`=%d",
			GetPlayerSQLId(playerid), source, destination, sourceid);
	}
	else if(itemid == 4 && fromplayerid == -1 && fromstorageid == -1 && special == 2) {
		if(PlayerInfo[playerid][pMats] < 0 || PlayerInfo[playerid][pMats] > cellmax - amount) {
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the mang tung nay vat lieu. Chuyen hang chua hoan tat.");
			return 0;
		}
		destination = PlayerInfo[playerid][pMats] + amount;
		mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `Materials`=%d WHERE `id`=%d", destination, GetPlayerSQLId(playerid));
	}
	else return 0;

	new notifyid = itemid == 1 ? fromplayerid : playerid;
	if(restarting || !gAccountsInnoDB || mysql_unprocessed_queries(MainPipeline)) {
		SendClientMessageEx(notifyid, COLOR_GREY, "Kho chua san sang hoac dang ban. Hay thu lai.");
		return 0;
	}
	new Cache:result = mysql_query(MainPipeline, query);
	if(!cache_is_valid(result)) {
		SendClientMessageEx(notifyid, COLOR_GREY, "Cap nhat kho chua duoc xac nhan. Hay thu lai.");
		return 0;
	}
	new affected = cache_affected_rows();
	cache_delete(result);
	if(affected == 0) {
		// Legacy cash/material helpers can leave SQL already equal to the new values.
		if(itemid == 1) mysql_format(MainPipeline, query, sizeof(query), "SELECT `id` FROM `accounts` WHERE `id` IN (%d,%d)", sourceid, GetPlayerSQLId(playerid));
		else mysql_format(MainPipeline, query, sizeof(query), "SELECT `id` FROM `accounts` WHERE `id`=%d", GetPlayerSQLId(playerid));
		result = mysql_query(MainPipeline, query);
		new rows;
		if(cache_is_valid(result)) {
			cache_get_row_count(rows);
			cache_delete(result);
		}
		if(rows != (itemid == 1 ? 2 : 1)) {
			SendClientMessageEx(notifyid, COLOR_GREY, "Chua xac nhan duoc tai khoan cho kho. Hay thu lai.");
			return 0;
		}
	}

	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	if(itemid == 4) {
		PlayerInfo[playerid][pMats] = destination;
		SendClientMessageEx(playerid, COLOR_WHITE, "Da chuyen %s vat lieu vao tui (%s).", number_format(amount), number_format(destination));
		return 1;
	}
	PlayerInfo[fromplayerid][pCash] = source;
	PlayerInfo[playerid][pCash] = destination;
	new string[128];
	format(string, sizeof(string), "Da chuyen $%d vao tui ($%d).", amount, destination);
	SendClientMessage(playerid, COLOR_WHITE, string);
	format(string, sizeof(string), "Da chuyen $%d tu tui ban sang tui cua %s.", amount, GetPlayerNameEx(playerid));
	SendClientMessage(fromplayerid, COLOR_WHITE, string);
	PlayerPlaySound(fromplayerid, 1052, 0.0, 0.0, 0.0);
	format(string, sizeof(string), "* %s lay tien mat tu tui va dua cho %s.", GetPlayerNameEx(fromplayerid), GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[fromplayerid][pAdmin] >= 2) {
		format(string, sizeof(string), "[Admin] %s(%d) (IP:%s) has given $%s Cash to %s(%d) (IP:%s)", GetPlayerNameEx(fromplayerid), GetPlayerSQLId(fromplayerid), GetPlayerIpEx(fromplayerid), number_format(amount), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid));
		Log("logs/adminpay.log", string);
		format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s dua $%s tien mat cho %s", GetPlayerNameEx(fromplayerid), number_format(amount), GetPlayerNameEx(playerid));
		if(!strcmp(GetPlayerIpEx(playerid), GetPlayerIpEx(fromplayerid), true)) strcat(string, " (1)");
		ABroadCast(COLOR_YELLOW, string, 4);
	}
	else {
		format(string, sizeof(string), "%s(%d) (IP:%s) has given $%s Cash to %s(%d) (IP:%s)", GetPlayerNameEx(fromplayerid), GetPlayerSQLId(fromplayerid), GetPlayerIpEx(fromplayerid), number_format(amount), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid));
		Log("logs/pay.log", string);
		format(string, sizeof(string), "%s (IP:%s) has given $%s Cash to %s (IP:%s)", GetPlayerNameEx(fromplayerid), GetPlayerIpEx(fromplayerid), number_format(amount), GetPlayerNameEx(playerid), GetPlayerIpEx(playerid));
		if(amount >= 100000 && PlayerInfo[fromplayerid][pLevel] <= 3) ABroadCast(COLOR_YELLOW, string, 2);
		if(amount >= 1000000) ABroadCast(COLOR_YELLOW, string, 2);
	}
	return 1;
}

stock ShowInventory(playerid,targetid)
{
	if(IsPlayerConnected(targetid))
	{
		new resultline[1024], header[64], pnumber[20], toolboxstring[30];
		if(PlayerInfo[targetid][pPnumber] == 0) pnumber = "None"; else format(pnumber, sizeof(pnumber), "%d", PlayerInfo[targetid][pPnumber]);

		new totalwealth;
		totalwealth = PlayerInfo[targetid][pAccount] + GetPlayerCash(targetid);
		if(PlayerInfo[targetid][pPhousekey] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[targetid][pPhousekey]][hOwnerID] == GetPlayerSQLId(targetid)) totalwealth += HouseInfo[PlayerInfo[targetid][pPhousekey]][hSafeMoney];
		if(PlayerInfo[targetid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[targetid][pPhousekey2]][hOwnerID] == GetPlayerSQLId(targetid)) totalwealth += HouseInfo[PlayerInfo[targetid][pPhousekey2]][hSafeMoney];
		if(PlayerInfo[targetid][pPhousekey3] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[targetid][pPhousekey3]][hOwnerID] == GetPlayerSQLId(targetid)) totalwealth += HouseInfo[PlayerInfo[targetid][pPhousekey3]][hSafeMoney];

		if(PlayerInfo[targetid][pToolBox] >= 1) format(toolboxstring, 50, "Dung cu: 1, con %s", number_format(PlayerInfo[targetid][pToolBox]));
		else format(toolboxstring, 50, "Hop dung cu: 0");
		
		SetPVarInt(playerid, "ShowInventory", targetid);
		format(header, sizeof(header), "Tui do cua %s", GetPlayerNameEx(targetid));
		format(resultline, sizeof(resultline),"{FFFFFF}Tai san: $%s\n\
		Tien mat: $%s\n\
		Ngan hang: $%s\n\
		So dien thoai: %s\n\
		Tan so bo dam: %dkhz\n\
		Vat lieu: %s\n\
		Day thung: %s\n\
		Gie: %s\n\
		Tua vit: %s\n\
		Lop xe: %s\n\
		Giay: %s\n\
		Xi ga: %s\n\
		Lon Sprunk: %s\n\
		Binh son: %s\n\
		%s\n\
		Xa beng: %d",
		number_format(totalwealth),
		number_format(GetPlayerCash(targetid)),
		number_format(PlayerInfo[targetid][pAccount]),
		pnumber,
		PlayerInfo[targetid][pRadioFreq],
		number_format(PlayerInfo[targetid][pMats]),
		number_format(PlayerInfo[targetid][pRope]),
		number_format(PlayerInfo[targetid][pRags]),
		number_format(PlayerInfo[targetid][pScrewdriver]),
		number_format(PlayerInfo[targetid][pTire]),
		number_format(PlayerInfo[targetid][pPaper]),		
		number_format(PlayerInfo[targetid][pCigar]),
		number_format(PlayerInfo[targetid][pSprunk]),
		number_format(PlayerInfo[targetid][pSpraycan]),
		toolboxstring,
		PlayerInfo[targetid][pCrowBar]);
		ShowPlayerDialogEx(playerid, DISPLAY_INV, DIALOG_STYLE_MSGBOX, header, resultline, "Trang tiep", "Dong");
	}
	return 1;
}

stock FindGunInVehicleForPlayer(ownerid, slot, playerid)
{
	new
		i = 0;
	while (i < (PlayerVehicleInfo[ownerid][slot][pvWepUpgrade] + 1) && (!PlayerVehicleInfo[ownerid][slot][pvWeapons][i] || PlayerInfo[playerid][pGuns][GetLoadoutWeaponSlot(PlayerVehicleInfo[ownerid][slot][pvWeapons][i])] == PlayerVehicleInfo[ownerid][slot][pvWeapons][i]))
	{
		i++;
	}
	if (i == (PlayerVehicleInfo[ownerid][slot][pvWepUpgrade] + 1)) return -1;
	return i;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	szMiscArray[0] = 0;
	switch(dialogid)
	{
		case DISPLAY_INV:
		{
			new targetid = GetPVarInt(playerid, "ShowInventory");
			if(IsPlayerConnected(targetid))
			{
				if(response)
				{
					new resultline[1024], header[64];

					format(header, sizeof(header), "Tui do cua %s", GetPlayerNameEx(targetid));
					format(resultline, sizeof(resultline),"{FFFFFF}Khoa: %d\n\
					Tui so cuu: %d\n\
					May thu: %d\n\
					GPS: %d\n\
					May quet: %d\n\
					Phao hoa: %d\n\
					Boombox: %d\n\
					Hop thu: %d\n\
					Rim Kits: %d\n\
					Sec: %s\n\
					O xe them: %s\n\
					O toy them: %s",
					PlayerInfo[targetid][pLock],
					PlayerInfo[targetid][pFirstaid],
					PlayerInfo[targetid][pReceiver],
					PlayerInfo[targetid][pGPS],
					PlayerInfo[targetid][pSweep],
					PlayerInfo[targetid][pFirework],
					PlayerInfo[targetid][pBoombox],
					PlayerInfo[targetid][pMailbox],
					PlayerInfo[targetid][pRimMod],
					number_format(PlayerInfo[targetid][pChecks]),
					number_format(PlayerInfo[targetid][pVehicleSlot]),
					number_format(PlayerInfo[targetid][pToySlot]));
					if(zombieevent) format(resultline, sizeof(resultline), "%s\nCure Vials: %d\nSat vun: %d\nAntibiotic Injections: %d\n.50 Cals: %d\nSurvivor Kits: %d\nBinh xang: %d%%", resultline, PlayerInfo[targetid][pVials], PlayerInfo[targetid][mInventory][16], PlayerInfo[targetid][mInventory][17], PlayerInfo[targetid][mPurchaseCount][18], PlayerInfo[targetid][mInventory][19], PlayerInfo[targetid][zFuelCan]);
					ShowPlayerDialogEx(playerid, DISPLAY_INV2, DIALOG_STYLE_MSGBOX, header, resultline, "Trang dau", "Dong");
				}
				else DeletePVar(playerid, "ShowInventory");
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi dang duoc kiem tra da dang xuat.");
				DeletePVar(playerid, "ShowInventory");
				return 1;
			}
		}
		case DISPLAY_INV2:
		{
			new targetid = GetPVarInt(playerid, "ShowInventory");
			if(IsPlayerConnected(targetid))
			{
				if(response)
				{
					ShowInventory(playerid, targetid);
				}
				else DeletePVar(playerid, "ShowInventory");
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi dang duoc kiem tra da dang xuat.");
				DeletePVar(playerid, "ShowInventory");
				return 1;
			}
		}
	}
	return 0;
}

alias:inventory("inv")
CMD:inventory(playerid, params[])
{
	if(gPlayerLogged{playerid} != 0) ShowInventory(playerid, playerid);
	return 1;
}

CMD:mytokens(playerid, params[])
{
	szMiscArray[0] = 0;

	SendClientMessage(playerid, COLOR_GREY, "------------------------------------------------------------------------------------------------");

	format(szMiscArray, sizeof(szMiscArray), "VIP Tokens: %s, Paintball Tokens: %s, EXP Tokens: %s (Gio: %s), Event Tokens: %s, Gold Giftbox: %s",
		number_format(PlayerInfo[playerid][pTokens]),
		number_format(PlayerInfo[playerid][pPaintTokens]),
		number_format(PlayerInfo[playerid][pEXPToken]),
		number_format(PlayerInfo[playerid][pDoubleEXP]),
		number_format(PlayerInfo[playerid][pEventTokens]),
		number_format(PlayerInfo[playerid][pGoldBoxTokens]));

	SendClientMessage(playerid, COLOR_WHITE, szMiscArray);

	SendClientMessage(playerid, COLOR_GREY, "------------------------------------------------------------------------------------------------");
	return 1;
}

CMD:trunkput(playerid, params[])
{
	if(GetPVarType(playerid, "IsInArena"))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o dau truong!");
		return 1;
	}
	if(GetPVarInt( playerid, "EventToken") != 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang tham gia su kien.");
		return 1;
	}
	if(IsPlayerInAnyVehicle(playerid)) { SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o trong xe!"); return 1; }
	if(GetPVarInt(playerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the dung lenh nay!");

	new string[128], weaponchoice[32], slot;
	if(sscanf(params, "s[32]D(0)", weaponchoice, slot)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /trunkput [weapon] [slot]");

	new pvid = -1, Float: x, Float: y, Float: z;

	for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
	{
		if(PlayerVehicleInfo[playerid][d][pvId] != INVALID_PLAYER_VEHICLE_ID) GetVehiclePos(PlayerVehicleInfo[playerid][d][pvId], x, y, z);
		if(IsPlayerInRangeOfPoint(playerid, 3.0, x, y, z))
		{
			pvid = d;
			break;
		}
	}
	if(pvid == -1) return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong o gan xe do minh so huu.");
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(PlayerVehicleInfo[playerid][pvid][pvId],engine,lights,alarm,doors,bonnet,boot,objective);
	if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET) return SendClientMessageEx(playerid, COLOR_GRAD3, "Cop dang dong, khong the lay/cat do!(/car trunk de mo)");
	if(GetVehicleModel(PlayerVehicleInfo[playerid][pvid][pvId]) == 481 || GetVehicleModel(PlayerVehicleInfo[playerid][pvid][pvId]) == 510)  return SendClientMessageEx(playerid,COLOR_GREY,"Xe nay khong co cop.");

	new Float: Health;
	GetHealth(playerid, Health);
	if(Health < 80.0) return SendClientMessageEx(playerid,COLOR_GREY,"Khong the cat vu khi hay ma tuy vao xe khi mau duoi 80.");
	if (GetPVarInt(playerid, "GiveWeaponTimer") > 0)
	{
		SendClientMessageEx(playerid,COLOR_GREY,"Can cho %d giay truoc khi cat them vu khi.", GetPVarInt(playerid, "GiveWeaponTimer"));
		return 1;
	}
	
	new maxslots = PlayerVehicleInfo[playerid][pvid][pvWepUpgrade]+1;
	if(slot > maxslots || slot < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "O khong hop le.");
		return 1;
	}

	if( PlayerVehicleInfo[playerid][pvid][pvWeapons][slot-1] != 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "O nay da co vu khi.");
		return 1;
	}

	new weapon;
	if(strcmp(weaponchoice, "sdpistol", true, strlen(weaponchoice)) == 0)
	{
		if(pTazer{playerid} == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the cat sung dien!");
		if( PlayerInfo[playerid][pGuns][2] == 23 && PlayerInfo[playerid][pAGuns][2] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat silenced pistol vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][2];
			format(string,sizeof(string), "* %s cat silenced pistol vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "9mm", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][2] == 22 && PlayerInfo[playerid][pAGuns][2] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat 9mm vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][2];
			format(string,sizeof(string), "* %s cat 9mm vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "deagle", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][2] == 24 && PlayerInfo[playerid][pAGuns][2] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat Desert Eagle vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][2];
			format(string,sizeof(string), "* %s cat Desert Eagle vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "shotgun", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][3] == 25 && PlayerInfo[playerid][pAGuns][3] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat shotgun vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][3];
			format(string,sizeof(string), "* %s cat Shotgun vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "spas12", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][3] == 27 && PlayerInfo[playerid][pAGuns][3] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat combat shotgun vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][3];
			format(string,sizeof(string), "* %s cat Combat Shotgun vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "mp5", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][4] == 29 && PlayerInfo[playerid][pAGuns][4] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat MP5 vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][4];
			format(string,sizeof(string), "* %s cat MP5 vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}

	else if(strcmp(weaponchoice, "tec9", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][4] == 32 && PlayerInfo[playerid][pAGuns][4] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat TEC9 vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][4];
			format(string,sizeof(string), "* %s cat TEC9 vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}

	else if(strcmp(weaponchoice, "ak47", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][5] == 30 && PlayerInfo[playerid][pAGuns][5] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat AK-47 vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][5];
			format(string,sizeof(string), "* %s cat AK-47 vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "m4", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][5] == 31 && PlayerInfo[playerid][pAGuns][5] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat M4 vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][5];
			format(string,sizeof(string), "* %s cat M4 vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "rifle", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][6] == 33 && PlayerInfo[playerid][pAGuns][6] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat rifle vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][6];
			format(string,sizeof(string), "* %s cat rifle vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "sniper", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][6] == 34 && PlayerInfo[playerid][pAGuns][6] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat sniper rifle vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][6];
			format(string,sizeof(string), "* %s cat sniper rifle vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "golfclub", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][1] == 2 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat golf club vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][1];
			format(string,sizeof(string), "* %s cat golf club vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "baseballbat", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][1] == 5 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat baseball bat vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][1];
			format(string,sizeof(string), "* %s cat baseball bat vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "shovel", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][1] == 6 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat shovel vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][1];
			format(string,sizeof(string), "* %s cat shovel vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "poolcue", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][1] == 7 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat pool cue vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][1];
			format(string,sizeof(string), "* %s cat pool cue vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "katana", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][1] == 8 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat katana vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][1];
			format(string,sizeof(string), "* %s cat katana vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "cane", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][10] == 15 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat cane vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][10];
			format(string,sizeof(string), "* %s cat cane vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "flowers", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][10] == 14 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat flowers vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][10];
			format(string,sizeof(string), "* %s cat flowers vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "parachute", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][11] == 46 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat parachute vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][11];
			format(string,sizeof(string), "* %s cat parachute vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}
	else if(strcmp(weaponchoice, "dildo", true, strlen(weaponchoice)) == 0)
	{
		if( PlayerInfo[playerid][pGuns][10] == 10 && PlayerInfo[playerid][pAGuns][1] == 0 )
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat dildo vao tu vu khi tren xe.");
			weapon = PlayerInfo[playerid][pGuns][10];
			format(string,sizeof(string), "* %s cat dildo vao ket xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
	}	
	else { SendClientMessageEx(playerid,COLOR_GREY,"Ten vu khi khong hop le!"); return 1; }
	if(PlayerVehicleInfo[playerid][pvid][pvWeapons][slot-1] == 0)
	{
		PlayerVehicleInfo[playerid][pvid][pvWeapons][slot-1] = weapon;
		RemovePlayerLoadoutWeapon(playerid, weapon);
		g_mysql_SaveVehicle(playerid, pvid);
	}
	return 1;
}

CMD:trunktake(playerid, params[]) {
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay trong xe.");
	if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan cua ban bi han che!");
	else if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi o dau truong!");
	else if(GetPVarInt( playerid, "EventToken") != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang tham gia su kien.");
	else if(PlayerInfo[playerid][pConnectHours] < 2 || PlayerInfo[playerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung vi ban dang bi cam so huu vu khi!");
	else if(GetPVarInt(playerid, "GiveWeaponTimer") >= 1)
	{
		return SendClientMessageEx(playerid, COLOR_GREY, "Can cho %d giay truoc khi lay them vu khi.", GetPVarInt(playerid, "GiveWeaponTimer"));
	}

	new
		Float: fVehPos[3],
		iWeaponSlot = strval(params);

	for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++) {
		if(PlayerVehicleInfo[playerid][d][pvId] != INVALID_PLAYER_VEHICLE_ID) {
			GetVehiclePos(PlayerVehicleInfo[playerid][d][pvId], fVehPos[0], fVehPos[1], fVehPos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 4.0, fVehPos[0], fVehPos[1], fVehPos[2])) {
				if(isnull(params)) {


					SendClientMessageEx(playerid, COLOR_WHITE, "*** Ket %s - %s ***", GetPlayerNameEx(playerid), GetVehicleName(PlayerVehicleInfo[playerid][d][pvId]));
					for(new s = 0; s < 3; s++) if(PlayerVehicleInfo[playerid][d][pvWeapons][s] != 0) {

						new
							szWeapon[16];

						GetWeaponName(PlayerVehicleInfo[playerid][d][pvWeapons][s], szWeapon, sizeof(szWeapon));
						SendClientMessageEx(playerid, COLOR_WHITE, "O %d: %s", s+1, szWeapon);
					}
					return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /trunktake [slot]");
				}
				else if(GetVehicleModel(PlayerVehicleInfo[playerid][d][pvId]) == 481 || GetVehicleModel(PlayerVehicleInfo[playerid][d][pvId]) == 509) {
					return SendClientMessageEx(playerid,COLOR_GREY,"Xe nay khong co cop.");
				}

				new
					engine, lights, alarm, doors, bonnet, boot, objective;

				GetVehicleParamsEx(PlayerVehicleInfo[playerid][d][pvId], engine, lights, alarm, doors, bonnet, boot, objective);

				if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET) {
					return SendClientMessageEx(playerid, COLOR_GRAD3, "Cop dang dong, khong the lay vu khi! /car trunk de mo.");
				}

				new maxslots = PlayerVehicleInfo[playerid][d][pvWepUpgrade]+1;
				if(iWeaponSlot > maxslots || iWeaponSlot < 1) {
					return SendClientMessageEx(playerid, COLOR_GREY, "O duoc chon khong hop le.");
				}

				else if(PlayerVehicleInfo[playerid][d][pvWeapons][iWeaponSlot - 1] != 0) {
					new
						szWeapon[16],
						szMessage[128];


					new aWeapons[13][2];

					for(new i; i < 13; ++i) {
						GetPlayerWeaponData(playerid, i, aWeapons[i][0], aWeapons[i][1]);
						if(aWeapons[i][0] == PlayerVehicleInfo[playerid][d][pvWeapons][iWeaponSlot - 1]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da mang vu khi nay.");
					}

					GetWeaponName(PlayerVehicleInfo[playerid][d][pvWeapons][iWeaponSlot - 1], szWeapon, sizeof(szWeapon));
					GivePlayerValidWeapon(playerid, PlayerVehicleInfo[playerid][d][pvWeapons][iWeaponSlot - 1]);
					PlayerVehicleInfo[playerid][d][pvWeapons][iWeaponSlot - 1] = 0;
					g_mysql_SaveVehicle(playerid, d);

					SendClientMessageEx(playerid, COLOR_WHITE, "Ban lay %s tu tu vu khi tren xe.", szWeapon);

					format(szMessage, sizeof(szMessage), "* %s lay %s tu ket xe.", GetPlayerNameEx(playerid), szWeapon);
					return ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
				else return SendClientMessageEx(playerid, COLOR_WHITE, "O nay khong co vu khi.");
			}
		}
	}
	return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong o gan xe do minh so huu.");
}

CMD:storegun(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi o dau truong!");
		if(GetPVarInt( playerid, "EventToken") != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang tham gia su kien.");
		if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen")) return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam viec nay!");
		new string[128], weaponchoice[32], slot;
		if(sscanf(params, "s[32]d", weaponchoice, slot)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /storegun [weapon] [slot]");

		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				if (GetPVarInt(playerid, "GiveWeaponTimer") > 0)
				{
					SendClientMessageEx(playerid,COLOR_GREY,"Can cho %d giay truoc khi cat them vu khi.", GetPVarInt(playerid, "GiveWeaponTimer"));
					return 1;
				}

				new maxslots = HouseInfo[i][hGLUpgrade];
				if(slot > maxslots || slot == 0)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "O khong hop le. Cac o tu 1-5.");
					return 1;
				}

				if( HouseInfo[i][hWeapons][slot-1] != 0)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "O nay da co vu khi.");
					return 1;
				}

				new weapon;
				if(strcmp(weaponchoice, "sdpistol", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][2] == 23 && PlayerInfo[playerid][pAGuns][2] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat silenced pistol vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][2];
						format(string,sizeof(string), "* %s cat silenced pistol vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "deagle", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][2] == 24 && PlayerInfo[playerid][pAGuns][2] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat Desert Eagle vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][2];
						format(string,sizeof(string), "* %s cat Desert Eagle vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "shotgun", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][3] == 25 && PlayerInfo[playerid][pAGuns][3] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat shotgun vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][3];
						format(string,sizeof(string), "* %s cat Shotgun vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "spas12", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][3] == 27 && PlayerInfo[playerid][pAGuns][3] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat combat shotgun vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][3];
						format(string,sizeof(string), "* %s cat Combat Shotgun vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "mp5", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][4] == 29 && PlayerInfo[playerid][pAGuns][4] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat MP5 vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][4];
						format(string,sizeof(string), "* %s cat MP5 vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "ak47", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][5] == 30 && PlayerInfo[playerid][pAGuns][5] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat AK-47 vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][5];
						format(string,sizeof(string), "* %s cat AK-47 vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "m4", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][5] == 31 && PlayerInfo[playerid][pAGuns][5] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat M4 vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][5];
						format(string,sizeof(string), "* %s cat M4 vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "rifle", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][6] == 33 && PlayerInfo[playerid][pAGuns][6] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat rifle vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][6];
						format(string,sizeof(string), "* %s cat rifle vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "sniper", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][6] == 34 && PlayerInfo[playerid][pAGuns][6] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat sniper rifle vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][6];
						format(string,sizeof(string), "* %s cat sniper rifle vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "uzi", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][4] == 28 && PlayerInfo[playerid][pAGuns][4] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat uzi vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][4];
						format(string,sizeof(string), "* %s cat uzi vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				else if(strcmp(weaponchoice, "tec9", true, strlen(weaponchoice)) == 0)
				{
					if( PlayerInfo[playerid][pGuns][4] == 32 && PlayerInfo[playerid][pAGuns][4] == 0 )
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cat tec9 vao tu vu khi.");
						weapon = PlayerInfo[playerid][pGuns][4];
						format(string,sizeof(string), "* %s cat tec9 vao ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
				}
				if(weapon == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co vu khi do.");
				if(HouseInfo[i][hWeapons][slot-1] == 0)
				{
					HouseInfo[i][hWeapons][slot-1] = weapon;
					RemovePlayerLoadoutWeapon(playerid, weapon);
					SaveHouse(i);
					return 1;
				}
				else { SendClientMessageEx(playerid,COLOR_GREY,"Ten vu khi khong hop le!"); return 1; }
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}

CMD:getgun(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		new string[128], slot;

		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				if(PlayerInfo[playerid][pConnectHours] < 2 || PlayerInfo[playerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung vi ban dang bi cam so huu vu khi!");

				if(sscanf(params, "d", slot))
				{
					new weaponname[50];
					SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
					SendClientMessageEx(playerid, COLOR_WHITE, "*** Ket %s ***", GetPlayerNameEx(playerid));
					for(new s = 0; s < 5; s++)
					{
						if( HouseInfo[i][hWeapons][s] != 0 )
						{
							GetWeaponName(HouseInfo[i][hWeapons][s], weaponname, sizeof(weaponname));
							SendClientMessageEx(playerid, COLOR_WHITE, "O %d: %s", s+1, weaponname);
						}
					}
					SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /getgun [slot]");
					return 1;
				}

				if (GetPVarInt(playerid, "GiveWeaponTimer") > 0)
				{
					SendClientMessageEx(playerid,COLOR_GREY,"Can cho %d giay truoc khi lay them vu khi.", GetPVarInt(playerid, "GiveWeaponTimer"));
					return 1;
				}
				new maxslots = HouseInfo[i][hGLUpgrade];
				if(slot > maxslots)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "O khong hop le.");
					return 1;
				}

				if(HouseInfo[i][hWeapons][slot-1] != 0)
				{
					new weaponname[50];
					GetWeaponName(HouseInfo[i][hWeapons][slot-1], weaponname, sizeof(weaponname));
					GivePlayerValidWeapon(playerid, HouseInfo[i][hWeapons][slot-1]);
					HouseInfo[i][hWeapons][slot-1] = 0;
					if(strcmp(weaponname, "silenced pistol", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay silenced pistol tu tu vu khi.");
						format(string,sizeof(string), "* %s lay silenced pistol tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "desert eagle", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay Desert Eagle tu tu vu khi.");
						format(string,sizeof(string), "* %s lay Desert Eagle tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "shotgun", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay shotgun tu tu vu khi.");
						format(string,sizeof(string), "* %s lay shotgun tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "combat shotgun", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay combat shotgun tu tu vu khi.");
						format(string,sizeof(string), "* %s lay combat shotgun tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "mp5", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay MP5 tu tu vu khi.");
						format(string,sizeof(string), "* %s lay MP5 tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "ak47", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay AK-47 tu tu vu khi.");
						format(string,sizeof(string), "* %s lay AK-47 tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "m4", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay M4 tu tu vu khi.");
						format(string,sizeof(string), "* %s lay M4 tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "rifle", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay rifle tu tu vu khi.");
						format(string,sizeof(string), "* %s lay rifle tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
					}
					if(strcmp(weaponname, "sniper rifle", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay sniper rifle tu tu vu khi.");
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
						format(string,sizeof(string), "* %s lay sniper rifle tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					}
					if(strcmp(weaponname, "micro smg", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay uzi tu tu vu khi.");
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
						format(string,sizeof(string), "* %s lay uzi tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					}
					if(strcmp(weaponname, "tec9", true, strlen(weaponname)) == 0)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da lay uzi tu tu vu khi.");
						SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
						format(string,sizeof(string), "* %s lay uzi tu ket nha.", GetPlayerNameEx(playerid));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					}
					SaveHouse(i);
					return 1;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "O nay khong co vu khi.");
					return 1;
				}
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}


CMD:hwithdraw(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				new itemid, amount, string[128];

				if(sscanf(params, "dd", itemid, amount))
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /hwithdraw [itemid] [amount]");
					SendClientMessageEx(playerid, COLOR_GREY, "ItemIDs: (1) Tien mat - (2) Pot - (3) Crack - (4) Vat lieu - (5) Meth - (6) Ecstasy - (7) Heroin");
					return 1;
				}
				if(itemid < 1 || itemid > 7) {
					SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /hwithdraw [itemid] [amount]");
					SendClientMessageEx(playerid, COLOR_GREY, "ItemIDs: (1) Tien mat - (2) Pot - (3) Crack - (4) Vat lieu - (5) Meth - (6) Ecstasy - (7) Heroin");
					return 1;
				}

				if(amount < 1) return SendClientMessageEx(playerid, COLOR_WHITE, "So luong lay ra khong the duoi 1.");

				switch(itemid)
				{
					case 1: // Cash
					{
						if(HouseInfo[i][hSafeMoney] >= amount)
						{
							HouseInfo[i][hSafeMoney] -= amount;
							GivePlayerCash(playerid, amount);
							OnPlayerStatsUpdate(playerid);
							SaveHouse(i);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da lay $%d tu ket nha.", amount);
							format(string, sizeof(string), "%s (SQL: %d) has withdrawn $%d from their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
							Log("logs/hsafe.log", string);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de rut!");
					}
					case 2: // Pot
					{
						if(HouseInfo[i][hPot] >= amount)
						{
							HouseInfo[i][hPot] -= amount;
							PlayerInfo[playerid][pDrugs][0] += amount;
							OnPlayerStatsUpdate(playerid);
							SaveHouse(i);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d Pot tu ket nha.", amount);
							format(string, sizeof(string), "%s (SQL: %d) has withdrawn %d Pot from their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
							Log("logs/hsafe.log", string);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de rut!");
					}
					case 3: // Crack
					{
						if(HouseInfo[i][hCrack] >= amount)
						{
							HouseInfo[i][hCrack] -= amount;
							PlayerInfo[playerid][pDrugs][1] += amount;
							OnPlayerStatsUpdate(playerid);
							SaveHouse(i);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d crack tu ket nha.", amount);
							format(string, sizeof(string), "%s (SQL: %d) has withdrawn %d crack from their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
							Log("logs/hsafe.log", string);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de rut!");
					}
					case 4: // Materials
					{
						if(HouseInfo[i][hMaterials] >= amount)
						{
							HouseInfo[i][hMaterials] -= amount;
							PlayerInfo[playerid][pMats] += amount;
							OnPlayerStatsUpdate(playerid);
							SaveHouse(i);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d vat lieu tu ket nha.", amount);
							format(string, sizeof(string), "%s (SQL: %d) has withdrawn %d materials from their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
							Log("logs/hsafe.log", string);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de rut!");
					}
					case 5: // Meth
					{
						if(HouseInfo[i][hMeth] >= amount)
						{
							HouseInfo[i][hMeth] -= amount;
							PlayerInfo[playerid][pDrugs][2] += amount;
							OnPlayerStatsUpdate(playerid);
							SaveHouse(i);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d meth tu ket nha.", amount);
							format(string, sizeof(string), "%s (SQL: %d) has withdrawn %d meth from their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
							Log("logs/hsafe.log", string);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de rut!");
					}
					case 6: // Ecstasy
					{
						if(HouseInfo[i][hEcstasy] >= amount)
						{
							HouseInfo[i][hEcstasy] -= amount;
							PlayerInfo[playerid][pDrugs][3] += amount;
							OnPlayerStatsUpdate(playerid);
							SaveHouse(i);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d ecstasy tu ket nha.", amount);
							format(string, sizeof(string), "%s (SQL: %d) has withdrawn %d ecstasy from their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
							Log("logs/hsafe.log", string);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de rut!");
					}
					case 7: // Heroin
					{
						if(HouseInfo[i][hHeroin] >= amount)
						{
							HouseInfo[i][hHeroin] -= amount;
							PlayerInfo[playerid][pDrugs][4] += amount;
							OnPlayerStatsUpdate(playerid);
							SaveHouse(i);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d heroin tu ket nha.", amount);
							format(string, sizeof(string), "%s (SQL: %d) has withdrawn %d heroin from their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
							Log("logs/hsafe.log", string);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de rut!");
					}
				}
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}

CMD:hdeposit(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				new string[128], itemid, amount;

				if(sscanf(params, "dd", itemid, amount))
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /hdeposit [itemid] [amount]");
					SendClientMessageEx(playerid, COLOR_GREY, "ItemIDs: (1) Tien mat - (2) Pot - (3) Crack - (4) Vat lieu - (5) Meth - (6) Ecstasy - (7) Heroin");
					return 1;
				}
				if(itemid < 1 || itemid > 7) {
					SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /hdeposit [itemid] [amount]");
					SendClientMessageEx(playerid, COLOR_GREY, "ItemIDs: (1) Tien mat - (2) Pot - (3) Crack - (4) Vat lieu - (5) Meth - (6) Ecstasy - (7) Heroin");
					return 1;
				}

				if(amount < 1) return SendClientMessageEx(playerid, COLOR_WHITE, "So luong cat vao khong the duoi 1.");
				switch(itemid)
				{
					case 1: // Cash
					{
						if(PlayerInfo[playerid][pCash] >= amount) PlayerInfo[playerid][pCash] -= amount;
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de gui!");

						HouseInfo[i][hSafeMoney] += amount;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da cat $%d vao ket nha.", amount);
						OnPlayerStatsUpdate(playerid);
						SaveHouse(i);
						format(string, sizeof(string), "%s (SQL: %d) has deposited $%d into their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
						Log("logs/hsafe.log", string);
						return 1;
					}
					case 2: // Pot
					{
						if(PlayerInfo[playerid][pDrugs][0] >= amount) PlayerInfo[playerid][pDrugs][0] -= amount;
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de gui!");

						HouseInfo[i][hPot] += amount;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d Pot vao ket nha.", amount);
						OnPlayerStatsUpdate(playerid);
						SaveHouse(i);
						format(string, sizeof(string), "%s (SQL: %d) has deposited %d Pot into their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
						Log("logs/hsafe.log", string);
						return 1;
					}
					case 3: // Crack
					{
						if(PlayerInfo[playerid][pDrugs][1] >= amount) PlayerInfo[playerid][pDrugs][1] -= amount;
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de gui!");

						HouseInfo[i][hCrack] += amount;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d Crack vao ket nha.", amount);
						OnPlayerStatsUpdate(playerid);
						SaveHouse(i);
						format(string, sizeof(string), "%s (SQL: %d) has deposited %d crack into their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
						Log("logs/hsafe.log", string);
						return 1;
					}
					case 4: // Materials
					{
						if(PlayerInfo[playerid][pMats] >= amount) PlayerInfo[playerid][pMats] -= amount;
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de gui!");

						HouseInfo[i][hMaterials] += amount;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d Materials vao ket nha.", amount);
						OnPlayerStatsUpdate(playerid);
						SaveHouse(i);
						format(string, sizeof(string), "%s (SQL: %d) has deposited %d materials into their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
						Log("logs/hsafe.log", string);
						return 1;
					}
					case 5: // Meth
					{
						if(PlayerInfo[playerid][pDrugs][2] >= amount) PlayerInfo[playerid][pDrugs][2] -= amount;
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de gui!");

						HouseInfo[i][hMeth] += amount;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d Meth vao ket nha.", amount);
						OnPlayerStatsUpdate(playerid);
						SaveHouse(i);
						format(string, sizeof(string), "%s (SQL: %d) has deposited %d meth into their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
						Log("logs/hsafe.log", string);
						return 1;
					}
					case 6: // Ecstasy
					{
						if(PlayerInfo[playerid][pDrugs][3] >= amount) PlayerInfo[playerid][pDrugs][3] -= amount;
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de gui!");

						HouseInfo[i][hEcstasy] += amount;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d Ecstasy vao ket nha.", amount);
						OnPlayerStatsUpdate(playerid);
						SaveHouse(i);
						format(string, sizeof(string), "%s (SQL: %d) has deposited %d Ecstasy into their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
						Log("logs/hsafe.log", string);
						return 1;
					}
					case 7: // Heroin
					{
						if(PlayerInfo[playerid][pDrugs][4] >= amount) PlayerInfo[playerid][pDrugs][4] -= amount;
						else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du de gui!");

						HouseInfo[i][hHeroin] += amount;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d Heroin vao ket nha.", amount);
						OnPlayerStatsUpdate(playerid);
						SaveHouse(i);
						format(string, sizeof(string), "%s (SQL: %d) has deposited %d heroin into their house (ID: %d) safe.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount, i);
						Log("logs/hsafe.log", string);
						return 1;
					}
				}
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}

/*
CMD:workbench(playerid, params[]) {
        new szType[10], iChoice, iAmount, houseid;
        if(sscanf(params, "s[6]ii", szType, iChoice, iAmount)) {
            SendClientMessageEx(playerid, COLOR_GRAD2, "USAGE: /workbench [type] [choice] [amount]");
            SendClientMessageEx(playerid, COLOR_GRAD2, "TYPE: melee, gun");
            SendClientMessageEx(playerid, COLOR_GRAD2, "CHOICE GUN: 9mm (0), SDPistol (1), Shotgun (2), Rifle (3)");
            SendClientMessageEx(playerid, COLOR_GRAD2, "CHOICE MELEE: Brass Knuckles (0), Baseball Bat (1), Shovel (2), Pool Cue (3), Cane (4)");
            return SendClientMessageEx(playerid, COLOR_GRAD2, "CHOICE MELEE: Dildo (5), Vibrator (6), Katana (7), Flowers (8), SprayCan (9)");
        }
        for(new i = 0; i < 3; i++)
        {
            if(i == 0) houseid = PlayerInfo[playerid][pPhousekey];
            if(i == 1) houseid = PlayerInfo[playerid][pPhousekey2];
            if(i == 2) houseid = PlayerInfo[playerid][pPhousekey3];
            if(houseid != INVALID_HOUSE_ID && HouseInfo[houseid][hOwnerID] == GetPlayerSQLId(playerid) && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[houseid][hInteriorX], HouseInfo[houseid][hInteriorY], HouseInfo[houseid][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[houseid][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[houseid][hIntIW])
            {
       			if(iAmount <= 0) return SendClientMessageEx(playerid, -1, "You can't have negative amount values.");
				if(strcmp(szType,"melee",true) == 0) 
				{
           			if(playerid != INVALID_PLAYER_ID && iChoice >= 0 || iChoice <= 9) 
           	   		  	{
                    		if(PlayerInfo[playerid][pMats] < 150) return SendClientMessageEx(playerid, COLOR_GRAD2, "You dont have enough materials to produce the weapon.");
                    		if(PlayerInfo[playerid][pMats] < 2000 && iChoice == 9) return SendClientMessageEx(playerid, COLOR_GRAD2, "You dont have enough materials to produce the weapon.");
                    		switch(iChoice)
                    		{
                    			case 0: GivePlayerValidWeapon(playerid, WEAPON_BRASSKNUCKLE);
								case 1: GivePlayerValidWeapon(playerid, WEAPON_BAT);
								case 2: GivePlayerValidWeapon(playerid, WEAPON_SHOVEL);	
								case 3: GivePlayerValidWeapon(playerid, WEAPON_POOLSTICK);
								case 4: GivePlayerValidWeapon(playerid, WEAPON_CANE);
								case 5:	GivePlayerValidWeapon(playerid, WEAPON_DILDO);
								case 6:	GivePlayerValidWeapon(playerid, WEAPON_VIBRATOR);
								case 7:	GivePlayerValidWeapon(playerid, WEAPON_KATANA);
								case 8: GivePlayerValidWeapon(playerid, WEAPON_FLOWER);
								case 9: GivePlayerValidWeapon(playerid, WEAPON_SPRAYCAN);
                    		}
                    		if(iChoice == 9) { PlayerInfo[playerid][pMats] -= 1850; }
                    		PlayerInfo[playerid][pMats] -= 150;
                    		format(szMiscArray, sizeof(szMiscArray), "You have crafted a melee weapon.", iAmount);
                    		return SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
               			}
				}
				if(strcmp(szType,"gun",true) == 0) 
				{
            		if(playerid != INVALID_PLAYER_ID && iChoice >= 0 || iChoice <= 3) 
               		{
                   		switch(iChoice)
                   		{
                   			case 0:
                   			{
                   				if(PlayerInfo[playerid][pMats] < 3000) return SendClientMessageEx(playerid, COLOR_GRAD2, "You dont have enough materials to produce the gun.");
                   				GivePlayerValidWeapon(playerid, WEAPON_COLT45);
                   				PlayerInfo[playerid][pMats] -= 3000;
                    			format(szMiscArray, sizeof(szMiscArray), "You have crafted a 9mm weapon.", iAmount);
                   			}
                   			case 1:
                   			{
                   				if(PlayerInfo[playerid][pMats] < 3000) return SendClientMessageEx(playerid, COLOR_GRAD2, "You dont have enough materials to produce the gun.");
                   				GivePlayerValidWeapon(playerid, WEAPON_SILENCED);
                   				PlayerInfo[playerid][pMats] -= 3000;
                    			format(szMiscArray, sizeof(szMiscArray), "You have crafted a Silenced weapon.", iAmount);
                   			}
                   			case 2:
                   			{
                   				if(PlayerInfo[playerid][pMats] < 4000) return SendClientMessageEx(playerid, COLOR_GRAD2, "You dont have enough materials to produce the gun.");
                   				GivePlayerValidWeapon(playerid, WEAPON_SHOTGUN);
                   				PlayerInfo[playerid][pMats] -= 4000;
                    			format(szMiscArray, sizeof(szMiscArray), "You have crafted a Shotgun weapon.", iAmount);
                   			}
                   			case 3:
                   			{
                   				if(PlayerInfo[playerid][pMats] < 4000) return SendClientMessageEx(playerid, COLOR_GRAD2, "You dont have enough materials to produce the gun.");
                   				GivePlayerValidWeapon(playerid, WEAPON_RIFLE);
                   				PlayerInfo[playerid][pMats] -= 4000;
                    			format(szMiscArray, sizeof(szMiscArray), "You have crafted a Country Rifle weapon.", iAmount);
                   			}
                   		}
                    	return SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
                	}
            	}
       		}
        	SendClientMessageEx(playerid, COLOR_WHITE, "You're not in a house you own.");
    	}
		return 1;
}*/

CMD:hbalance(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				SendClientMessageEx(playerid, COLOR_GREEN, "|___________________________________ Ket nha ___________________________________|");
				SendClientMessageEx(playerid, COLOR_WHITE, "Tien: $%s | Pot: %s | Crack: %s | Vat lieu: %s | Meth: %s | Ecstasy: %s | Heroin: %s", number_format(HouseInfo[i][hSafeMoney]), number_format(HouseInfo[i][hPot]), number_format(HouseInfo[i][hCrack]), number_format(HouseInfo[i][hMaterials]), number_format(HouseInfo[i][hMeth]), number_format(HouseInfo[i][hEcstasy]), number_format(HouseInfo[i][hHeroin]));
				
				SendClientMessageEx(playerid, COLOR_GREEN, "|__________________________________________________________________________________|");
				return 1;
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}

CMD:closet(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				if(HouseInfo[i][hClosetX] != 0)
				{
					if(IsPlayerInRangeOfPoint(playerid, 3.0, HouseInfo[i][hClosetX], HouseInfo[i][hClosetY], HouseInfo[i][hClosetZ]))
					{
						return DisplaySkins(playerid);
					}
					else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan tu quan ao!");
				}
				else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu tu quan ao trong nha nay!");
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}

CMD:closetadd(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				if(HouseInfo[i][hClosetX] != 0)
				{
					if(IsPlayerInRangeOfPoint(playerid, 3.0, HouseInfo[i][hClosetX], HouseInfo[i][hClosetY], HouseInfo[i][hClosetZ]))
					{
						CountSkins(playerid);
						if((PlayerInfo[playerid][pDonateRank] <= 0 && PlayerInfo[playerid][pSkins] <= 10) || (PlayerInfo[playerid][pDonateRank] > 0 && PlayerInfo[playerid][pSkins] <= 25))
						{
							new skinid = GetPlayerSkin(playerid);
							AddSkin(playerid, skinid);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da them skin ID %d vao tu quan ao.", skinid);
							return 1;
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "Tu quan ao da het cho!");
					}
					else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan tu quan ao!");
				}
				else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu tu quan ao trong nha nay!");
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}

CMD:closetremove(playerid, params[])
{
	if(Homes[playerid] > 0)
	{
		for(new i; i < MAX_HOUSES; i++)
		{
			if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
			{
				if(HouseInfo[i][hClosetX] != 0)
				{
					if(IsPlayerInRangeOfPoint(playerid, 3.0, HouseInfo[i][hClosetX], HouseInfo[i][hClosetY], HouseInfo[i][hClosetZ]))
					{
						new query[128];
						mysql_format(MainPipeline, query, sizeof(query), "SELECT `skinid` FROM `house_closet` WHERE playerid = %d ORDER BY `skinid` ASC", GetPlayerSQLId(playerid));
						mysql_tquery(MainPipeline, query, "SkinQueryFinish", "ii", playerid, Skin_Query_Delete);
						return 1;
					}
					else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan tu quan ao!");
				}
				else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu tu quan ao trong nha nay!");
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
	return 1;
}

CMD:drop(playerid, params[])
{
	new string[128], amount, choice[32];
	if(sscanf(params, "s[32]D(0)", choice, amount))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /drop [name] [(optional) amount]");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Weapons, Materials, Packages, Radio, Pizza, Syringes, Backpack, Phone");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Pot, Crack, Meth, Ecstasy, Heroin");
		return 1;
	}
	else if(strcmp(choice,"backpack",true) == 0)
	{
		if(PlayerInfo[playerid][pBackpack] > 0)
		{
			ShowPlayerDialogEx(playerid, DIALOG_BDROP, DIALOG_STYLE_MSGBOX, "Xac nhan bo ba lo", "{FFFFFF}Ban chac chan muon bo ba lo?\n{FF8000}Luu y{FFFFFF}: Ba lo va moi thu ben trong se bi xoa {FF0000}vinh vien{FFFFFF}!", "Co", "Khong");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co ba lo!");
		}
	}
	else if(strcmp(choice,"syringes",true) == 0)
	{
		if(PlayerInfo[playerid][pSyringes] > 0)
		{
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hay nhap so luong.");
			if(amount > PlayerInfo[playerid][pSyringes]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du ong tiem!");
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo %d ong tiem.", amount);
			PlayerInfo[playerid][pSyringes] -= amount;
			format(string, sizeof(string), "* %s bo ong tiem.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang ong tiem de bo!");
		}
	}
	else if(strcmp(choice,"pot",true) == 0)
	{
		if(PlayerInfo[playerid][pDrugs][0] > 0)
		{
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hay nhap so luong.");
			if(amount > PlayerInfo[playerid][pDrugs][0]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du grams pot!");
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo %d pot.", amount);
			PlayerInfo[playerid][pDrugs][0] -= amount;
			format(string, sizeof(string), "* %s bo pot.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang pot de bo!");
		}
	}
	else if(strcmp(choice,"crack",true) == 0)
	{
		if(PlayerInfo[playerid][pDrugs][1] > 0)
		{
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hay nhap so luong.");
			if(amount > PlayerInfo[playerid][pDrugs][1]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du grams crack!");
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo %d crack.", amount);
			PlayerInfo[playerid][pDrugs][1] -= amount;
			format(string, sizeof(string), "* %s bo crack.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang crack de bo!");
		}
	}
	else if(strcmp(choice,"meth",true) == 0)
	{
		if(PlayerInfo[playerid][pDrugs][2] > 0)
		{
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hay nhap so luong.");
			if(amount > PlayerInfo[playerid][pDrugs][2]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du grams meth!");
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo %d meth.", amount);
			PlayerInfo[playerid][pDrugs][2] -= amount;
			format(string, sizeof(string), "* %s bo meth.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang meth de bo!");
		}
	}
	else if(strcmp(choice,"ecstasy",true) == 0)
	{
		if(PlayerInfo[playerid][pDrugs][3] > 0)
		{
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hay nhap so luong.");
			if(amount > PlayerInfo[playerid][pDrugs][3]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du grams ecstasy!");
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo %d ecstasy.", amount);
			PlayerInfo[playerid][pDrugs][3] -= amount;
			format(string, sizeof(string), "* %s bo ecstasy.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang ecstasy de bo!");
		}
	}
	else if(strcmp(choice,"heroin",true) == 0)
	{
		if(PlayerInfo[playerid][pDrugs][4] > 0)
		{
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hay nhap so luong.");
			if(amount > PlayerInfo[playerid][pDrugs][4]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du grams heroin!");
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo %d heroin.", amount);
			PlayerInfo[playerid][pDrugs][4] -= amount;
			format(string, sizeof(string), "* %s bo heroin.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang heroin de bo!");
		}
	}

	else if(strcmp(choice,"materials",true) == 0)
	{
		if(PlayerInfo[playerid][pMats] > 0)
		{
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hay nhap so luong.");
			if(amount > PlayerInfo[playerid][pMats]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du vat lieu!");
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo %d vat lieu.", amount);
			format(string, sizeof(string), "* %s bo vat lieu.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			PlayerInfo[playerid][pMats] -= amount;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang vat lieu de bo!");
		}
	}
	else if(strcmp(choice,"radio",true) == 0)
	{
		if(PlayerInfo[playerid][pRadio] != 0)
		{
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			format(string, sizeof(string), "* %s bo bo dam.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			PlayerInfo[playerid][pRadio] = 0;
			PlayerInfo[playerid][pRadioFreq] = 0;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang bo dam de bo!");
		}
	}
	else if(strcmp(choice,"weapons",true) == 0)
	{
		if(GetPVarType(playerid, "IsInArena"))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o dau truong!");
			return 1;
		}
		if(GetPVarInt( playerid, "EventToken") != 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang tham gia su kien.");
			return 1;
		}
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		ResetPlayerWeaponsEx(playerid);
		format(string, sizeof(string), "* %s bo vu khi.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	}
	else if(strcmp(choice,"packages",true) == 0)
	{
		if(GetPVarInt(playerid, "Packages") > 0)
		{
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			format(string, sizeof(string), "* %s bo cac kien vat lieu.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			DeletePVar(playerid, "Packages");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong mang kien vat lieu de bo!");
		}
	}
	else if(strcmp(choice,"pizza",true) == 0)
	{
		if(GetPVarType(playerid, "Pizza"))
		{
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			format(string, sizeof(string), "* %s bo don pizza dang giao.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			Pizza_StopDelivery(playerid);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong dang giao pizza!");
		}
	}
	else if(strcmp(choice,"phone", true) == 0)
	{
		if(PlayerInfo[playerid][pPnumber] != 0)
		{
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			format(string, sizeof(string), "* %s bo dien thoai.", GetPlayerNameEx(playerid));
			ProxChatBubble(playerid, string);
			PlayerInfo[playerid][pPnumber] = 0;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co dien thoai.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /drop [name] [(optional) amount]");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Weapons, Materials, Packages, Radio, Pizza, Syringes, Backpack, Phone");
		return SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Pot, Crack, Meth, Ecstasy, Heroin");
	}
	return 1;
}

CMD:show(playerid, params[])
{
	new string[128], giveplayerid, choice[32];
	if(sscanf(params, "us[32]", giveplayerid, choice))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /show [player] [name]");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Pot, Crack, Meth, Ecstasy, Heroin, Materials, Credits");
		return 1;
	}

	if(giveplayerid == playerid)
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Khong the cho chinh minh xem!");
		return 1;
	}

	if(IsPlayerConnected(giveplayerid))
	{
		if(giveplayerid != INVALID_PLAYER_ID)
		{
			if (!ProxDetectorS(5.0, playerid, giveplayerid))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
				return 1;
			}

			if (strcmp(choice, "materials", true) == 0)
			{
			    new amount = PlayerInfo[playerid][pMats];
			    if(amount < 1)
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co vat lieu!");
					return 1;
			    }
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "%s cho ban xem %d vat lieu.",  GetPlayerNameEx(playerid), amount);

				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban cho %s xem %d vat lieu.", GetPlayerNameEx(giveplayerid), amount);

				format(string, sizeof(string), "* %s cho %s xem vat lieu.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
			if (strcmp(choice, "pot", true) == 0)
			{
			    new amount = PlayerInfo[playerid][pDrugs][0];
			    if(amount < 1)
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co pot!");
					return 1;
			    }
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "%s cho ban xem %d grams pot.",  GetPlayerNameEx(playerid), amount);

				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban cho %s xem %d grams pot.", GetPlayerNameEx(giveplayerid), amount);

				format(string, sizeof(string), "* %s cho %s xem pot.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
			if (strcmp(choice, "crack", true) == 0)
			{
			    new amount = PlayerInfo[playerid][pDrugs][1];
			    if(amount < 1)
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co crack!");
					return 1;
			    }
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "%s cho ban xem %d grams crack.",  GetPlayerNameEx(playerid), amount);

				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban cho %s xem %d grams crack.", GetPlayerNameEx(giveplayerid), amount);

				format(string, sizeof(string), "* %s cho %s xem crack.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
			if (strcmp(choice, "meth", true) == 0)
			{
			    new amount = PlayerInfo[playerid][pDrugs][2];
			    if(amount < 1)
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co meth!");
					return 1;
			    }
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "%s cho ban xem %d grams meth.",  GetPlayerNameEx(playerid), amount);

				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban cho %s xem %d grams meth.", GetPlayerNameEx(giveplayerid), amount);

				format(string, sizeof(string), "* %s cho %s xem meth.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
			if (strcmp(choice, "ecstasy", true) == 0)
			{
			    new amount = PlayerInfo[playerid][pDrugs][3];
			    if(amount < 1)
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co ecstasy!");
					return 1;
			    }
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "%s cho ban xem %d grams ecstasy.",  GetPlayerNameEx(playerid), amount);

				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban cho %s xem %d grams ecstasy.", GetPlayerNameEx(giveplayerid), amount);

				format(string, sizeof(string), "* %s cho %s xem ecstasy.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
   			if (strcmp(choice, "heroin", true) == 0)
			{
			    new amount = PlayerInfo[playerid][pDrugs][4];
			    if(amount < 1)
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co heroin!");
					return 1;
			    }
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "%s cho ban xem %d milligrams heroin.",  GetPlayerNameEx(playerid), amount);

				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban cho %s xem %d milligrams heroin.", GetPlayerNameEx(giveplayerid), amount);

				format(string, sizeof(string), "* %s cho %s xem heroin.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
			if (strcmp(choice, "credits", true) == 0)
			{
			    new amount = PlayerInfo[playerid][pCredits];
			    if(amount < 1)
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co credits!");
					return 1;
			    }
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "%s cho ban xem %d credits.",  GetPlayerNameEx(playerid), amount);

				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban cho %s xem %d credits.", GetPlayerNameEx(giveplayerid), amount);

				format(string, sizeof(string), "* %s cho %s xem credits.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
		}
	}
	return 1;
}

CMD:sell(playerid, params[])
{
	new string[128], giveplayerid, choice[32], amount, price;
    if(sscanf(params, "us[32]dd", giveplayerid, choice, amount, price))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sell [player] [name] [amount] [price]");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Pot, Crack, Materials, Firework, Syringes, Rawopium, Heroin, RimKit, Carvoucher, PVIPVoucher");
		return 1;
	}
	if(PlayerCuffed[playerid] >= 1 || GetPVarInt(playerid, "pBagged") >= 1 ||PlayerInfo[playerid][pHospital] > 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban chua the lam viec nay.");
	if(GetPVarInt(playerid, "WatchingTV")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay khi dang xem TV!");
	if(price < 50000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia khong the duoi $50,000. Dung /give cho giao dich duoi nguong chong lua dao.");
	if(price > 500000000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia khong the duoi $50,000. Dung /give cho giao dich duoi nguong chong lua dao.");
	if(price > 100000000) 
	{
		format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s dang chao ban %s cho %s gia $%d.", GetPlayerNameEx(playerid), choice, GetPlayerNameEx(giveplayerid), price);
		ABroadCast(COLOR_YELLOW, string, 2);
	}
	if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "So luong khong the duoi 1.");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	if(playerid == giveplayerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the ban cho chinh minh!");
	if(!ProxDetectorS(8.0, playerid, giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");

    else if (strcmp(choice, "rimkit", true) == 0)
	{
		if(amount > PlayerInfo[playerid][pRimMod])
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co du rim kits.");

		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban de nghi %s mua %d rim kits gia $%s.", GetPlayerNameEx(giveplayerid), amount, number_format(price));
		SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s muon ban %d rim kits gia $%s, (dung /accept rimkit) de mua.", GetPlayerNameEx(playerid), amount, number_format(price));
	 	SetPVarInt(giveplayerid, "RimOffer", playerid);
		SetPVarInt(giveplayerid, "RimOfferSession", g_arrQueryHandle[playerid]);
	 	SetPVarInt(giveplayerid, "RimPrice", price);
	 	SetPVarInt(giveplayerid, "RimCount", amount);
	 	SetPVarInt(giveplayerid, "RimSeller_SQLId", GetPlayerSQLId(playerid));
	}
	else if (strcmp(choice, "pvipvoucher", true) == 0)
	{
		if(amount > PlayerInfo[playerid][pPVIPVoucher])
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co du 1 month PVIP Vouchers.");

		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban de nghi %s mua %d 1 month PVIP Voucher(s) gia $%s.", GetPlayerNameEx(giveplayerid), amount, number_format(price));
		SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s muon ban %d 1 month PVIP Voucher(s) gia $%s, (dung /accept pvipvoucher) de mua.", GetPlayerNameEx(playerid), amount, number_format(price));
	 	SetPVarInt(giveplayerid, "PVIPVoucherOffer", playerid);
	 	SetPVarInt(giveplayerid, "PVIPVoucherPrice", price);
	 	SetPVarInt(giveplayerid, "PVIPVoucherCount", amount);
	 	SetPVarInt(giveplayerid, "PVIPVoucherSeller_SQLId", GetPlayerSQLId(playerid));
	}
	return 1;

}
