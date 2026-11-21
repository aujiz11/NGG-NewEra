/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Toy System

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

stock CompleteToyTrade(playerid)
{
	new string[156],
		sellerid = GetPVarInt(playerid, "ttSeller"),
		name[24],
		toyid = GetPVarInt(sellerid, "ttToy");

	for(new i;i<sizeof(HoldingObjectsAll);i++)
	{
		if(HoldingObjectsAll[i][holdingmodelid] == toyid)
		{
			new toyName[24];
			strunpack(toyName, HoldingObjectsAll[i][holdingmodelname], sizeof(toyName));
			format(name, sizeof(name), "(%s)", toyName);
		}
	}
	if(toyid != 0 && (strcmp(name, "None", true) == 0))
	{
		format(name, sizeof(name), "(ID: %d)", toyid);
	}

	new icount = GetPlayerToySlots(playerid);

	if(!toyCountCheck(playerid))
	{
		SendClientMessageEx(sellerid, COLOR_GREY, "%s tu choi de nghi toy. (het o toy trong)", GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong con o toy trong.");
		DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttBuyer");
		DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttCost");
		DeletePVar(playerid, "ttSeller");

		HideTradeToysGUI(playerid);
		return 1;
	}

	if(GetPlayerCash(playerid) < GetPVarInt(sellerid, "ttCost"))
	{
		SendClientMessageEx(sellerid, COLOR_GREY, "%s tu choi de nghi toy. (khong du tien)", GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mat.");
		DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttBuyer");
		DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttCost");
		DeletePVar(playerid, "ttSeller");

		HideTradeToysGUI(playerid);
		return 1;
	}

	GivePlayerCash(playerid, -GetPVarInt(sellerid, "ttCost"));
	GivePlayerCash(sellerid, GetPVarInt(sellerid, "ttCost"));

	for(new i = 0; i < icount; i++)
	{
		if(!PlayerToyInfo[playerid][i][ptModelID])
		{
			PlayerToyInfo[playerid][i][ptModelID] = toyid;
			PlayerToyInfo[playerid][i][ptBone] = 1; // Doesn't need to be accurate, you can let the player choose.
			PlayerToyInfo[playerid][i][ptPosX] = 1.0;
			PlayerToyInfo[playerid][i][ptPosY] = 1.0;
			PlayerToyInfo[playerid][i][ptPosZ] = 1.0;
			PlayerToyInfo[playerid][i][ptRotX] = 0.0;
			PlayerToyInfo[playerid][i][ptRotY] = 0.0;
			PlayerToyInfo[playerid][i][ptRotZ] = 0.0;
			PlayerToyInfo[playerid][i][ptScaleX] = 1.0;
			PlayerToyInfo[playerid][i][ptScaleY] = 1.0;
			PlayerToyInfo[playerid][i][ptScaleZ] = 1.0;
			PlayerToyInfo[playerid][i][ptTradable] = 1;

			if(PlayerToyInfo[sellerid][GetPVarInt(sellerid, "ttToySlot")][ptSpecial] == 1)
			{
				PlayerToyInfo[playerid][i][ptSpecial] = 0;
			}
			else
				PlayerToyInfo[playerid][i][ptSpecial] = PlayerToyInfo[sellerid][GetPVarInt(sellerid, "ttToySlot")][ptSpecial];
			if(PlayerToyInfo[playerid][i][ptSpecial] == 2)
			{
				PlayerToyInfo[playerid][i][ptBone] = 2;
				PlayerToyInfo[playerid][i][ptPosX] = 0.07;
				PlayerToyInfo[playerid][i][ptPosY] = 0.0;
				PlayerToyInfo[playerid][i][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][i][ptRotX] = 88.0;
				PlayerToyInfo[playerid][i][ptRotY] = 75.0;
				PlayerToyInfo[playerid][i][ptRotZ] = 0.0;
				PlayerToyInfo[playerid][i][ptScaleX] = 0.0;
				PlayerToyInfo[playerid][i][ptScaleY] = 0.0;
				PlayerToyInfo[playerid][i][ptScaleZ] = 0.0;
			}
			// Seller
			mysql_format(MainPipeline, string, sizeof(string), "DELETE FROM `toys` WHERE `id` = '%d'", PlayerToyInfo[sellerid][GetPVarInt(sellerid, "ttToySlot")][ptID]);
			mysql_tquery(MainPipeline, string, "OnQueryFinish", "ii", SENDDATA_THREAD, sellerid);

			g_mysql_NewToy(playerid, i);
			break;
		}
	}

	PlayerToyInfo[sellerid][GetPVarInt(sellerid, "ttToySlot")][ptID] = 0;
	PlayerToyInfo[sellerid][GetPVarInt(sellerid, "ttToySlot")][ptModelID] = 0;
	PlayerToyInfo[sellerid][GetPVarInt(sellerid, "ttToySlot")][ptBone] = 0;
	PlayerToyInfo[sellerid][GetPVarInt(sellerid, "ttToySlot")][ptSpecial] = 0;
	for(new i; i < 10; i++)
	{
		if(PlayerHoldingObject[sellerid][i] == GetPVarInt(sellerid, "ttToySlot"))
		{
			if(IsPlayerAttachedObjectSlotUsed(sellerid, i))
			{
				RemovePlayerAttachedObject(sellerid, i);
				PlayerHoldingObject[sellerid][i] = 0;
				break;
			}
		}
	}
	if(PlayerInfo[sellerid][pBackpack] > 0 && PlayerInfo[sellerid][pBEquipped])
	{
		switch(PlayerInfo[sellerid][pBackpack])
		{
			case 1: // Small
			{
				if(PlayerHoldingObject[sellerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(sellerid, 9))
					RemovePlayerAttachedObject(sellerid, 9), PlayerHoldingObject[sellerid][9] = 0;
				SetPlayerAttachedObject(sellerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
			}
			case 2: // Med
			{
				if(PlayerHoldingObject[sellerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(sellerid, 9))
					RemovePlayerAttachedObject(sellerid, 9), PlayerHoldingObject[sellerid][9] = 0;
				SetPlayerAttachedObject(sellerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
			}
			case 3: // Large
			{
				if(PlayerHoldingObject[sellerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(sellerid, 9))
					RemovePlayerAttachedObject(sellerid, 9), PlayerHoldingObject[sellerid][9] = 0;
				SetPlayerAttachedObject(sellerid, 9, 3026, 1, -0.254999, -0.109, -0.022999, 10.6, -1.20002, 3.4, 1.265, 1.242, 1.062);
			}
		}
	}
	OnPlayerStatsUpdate(playerid);
	OnPlayerStatsUpdate(sellerid);

	SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "%s da nhan de nghi, mua toy cua ban gia $%s. %s", GetPlayerNameEx(playerid), number_format(GetPVarInt(sellerid, "ttCost")), name);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban nhan de nghi cua %s, mua toy gia $%s. %s", GetPlayerNameEx(sellerid), number_format(GetPVarInt(sellerid, "ttCost")), name);
	format(string, sizeof(string), "[S %s(%d)][IP %s][B %s(%d)][IP %s][P $%s][T: %s(%d)]", GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid),
	GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(GetPVarInt(sellerid, "ttCost")), name, toyid);
	Log("logs/toys.log", string);

	format(szMiscArray, sizeof(szMiscArray), "[TOYSALE][$%s] %s(%d) sold toy %s(%d) to %s(%d)", number_format(GetPVarInt(sellerid, "ttCost")), GetPlayerNameEx(playerid), playerid, name, toyid, GetPlayerNameEx(sellerid), sellerid);
	ABroadCast(COLOR_YELLOW, szMiscArray, 2);

	DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttSeller");
	DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttBuyer");
	DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttCost");
	DeletePVar(playerid, "ttSeller");

	HideTradeToysGUI(playerid);
	return 1;
}

stock ShowEditMenu(playerid)
{
	new boneName[16];
	new
		iIndex = GetPVarInt(playerid, "ToySlot");

	new toys = 99999;
	for(new i; i < 10; i++)
	{
		if(PlayerHoldingObject[playerid][i] == iIndex + 1)
		{
			toys = i;
			if(IsPlayerAttachedObjectSlotUsed(playerid, toys))
			{
				PlayerHoldingObject[playerid][i] = 0;
				if(!PlayerInfo[playerid][pBEquipped]) RemovePlayerAttachedObject(playerid, toys);
			}
			break;
		}
	}
	if(PlayerToyInfo[playerid][iIndex][ptScaleX] == 0) {
		PlayerToyInfo[playerid][iIndex][ptScaleX] = 1.0;
		PlayerToyInfo[playerid][iIndex][ptScaleY] = 1.0;
		PlayerToyInfo[playerid][iIndex][ptScaleZ] = 1.0;
	}
	if(IsPlayerInAnyVehicle(playerid) && PlayerToyInfo[playerid][iIndex][ptSpecial] == 2)
		return ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Sua toy cua ban", "Khong the sua toy khi dang trong xe!", "Dong y", "");
	new toycount = GetFreeToySlot(playerid);
	if(toycount == -1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da gan 10 object, hay thao bot object.");
	if(toycount == 9 && PlayerInfo[playerid][pBEquipped]) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the gan object vao o 10 khi dang deo ba lo.");
	PlayerHoldingObject[playerid][toycount] = iIndex;
	SetPlayerAttachedObject(playerid, toycount, PlayerToyInfo[playerid][iIndex][ptModelID],
	PlayerToyInfo[playerid][iIndex][ptBone], PlayerToyInfo[playerid][iIndex][ptPosX],
	PlayerToyInfo[playerid][iIndex][ptPosY], PlayerToyInfo[playerid][iIndex][ptPosZ],
	PlayerToyInfo[playerid][iIndex][ptRotX], PlayerToyInfo[playerid][iIndex][ptRotY],
	PlayerToyInfo[playerid][iIndex][ptRotZ], PlayerToyInfo[playerid][iIndex][ptScaleX],
	PlayerToyInfo[playerid][iIndex][ptScaleY], PlayerToyInfo[playerid][iIndex][ptScaleZ]);

    new stringg[128];
    strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][iIndex][ptBone]], sizeof(boneName));
    format(stringg, sizeof(stringg), "Xuong (%s)\nDo lech\nBat/tat tu dong gan", boneName);
 	ShowPlayerDialogEx(playerid, EDITTOYS2, DIALOG_STYLE_LIST, "Menu toy: Sua", stringg, "Chon", "Huy");
	return 1;
}

stock FindFreeAttachedObjectSlot(playerid)
{
	new index;
 	while (index < MAX_PLAYER_ATTACHED_OBJECTS && IsPlayerAttachedObjectSlotUsed(playerid, index))
	{
		index++;
	}
	if (index == MAX_PLAYER_ATTACHED_OBJECTS) return -1;
	return index;
}

toyCountCheck(playerid) {

	new
		iCount = GetPlayerToyCount(playerid),
		special = GetSpecialPlayerToyCount(playerid);
	if(iCount >= 10 + PlayerInfo[playerid][pToySlot] + special) return 0;
	return 1;
}

GetPlayerToyCount(playerid)
{
	new toys = 0;
	for(new i = 0; i < MAX_PLAYERTOYS; i++) if(PlayerToyInfo[playerid][i][ptModelID]) ++toys;
	return toys;
}

GetSpecialPlayerToyCount(playerid)
{
	new toys = 0;
	for(new i = 0; i < MAX_PLAYERTOYS; i++) if(PlayerToyInfo[playerid][i][ptSpecial] != 0) ++toys;
	return toys;
}

GetSpecialPlayerToyCountEx(playerid, special)
{
	new toys = 0;
	for(new i = 0; i < MAX_PLAYERTOYS; i++) if(PlayerToyInfo[playerid][i][ptSpecial] == special) ++toys;
	return toys;
}

/* GetSpecialFuncPlayerToyCount(playerid)
{
	new toys = 0;
	for(new i = 0; i < MAX_PLAYERTOYS; i++) if(PlayerToyInfo[playerid][i][ptSpecial] > 1) ++toys;
	return toys;
} */

GetFreeToySlot(playerid)
{
	for(new i = 0; i < 10; i++) {
		if(PlayerHoldingObject[playerid][i] == 0) {
			return i;
		}
	}
	return -1;
}

GetPlayerToySlots(playerid)
{
	new special =  GetSpecialPlayerToyCount(playerid);
	return PlayerInfo[playerid][pToySlot] + 10 + special;
}

AttachToy(playerid, toyid, msg = 1)
{
	new toycount = GetFreeToySlot(playerid);
	if(toycount == -1)
	{
		if(msg) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the gan hon 10 object.");
		else return 1;
	}
	if(toycount == 9 && PlayerInfo[playerid][pBEquipped])
	{
		if(msg) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the gan object vao o 10 khi dang deo ba lo.");
		else return 1;
	}

	if(PlayerToyInfo[playerid][toyid][ptScaleX] == 0) {
		PlayerToyInfo[playerid][toyid][ptScaleX] = 1.0;
		PlayerToyInfo[playerid][toyid][ptScaleY] = 1.0;
		PlayerToyInfo[playerid][toyid][ptScaleZ] = 1.0;
	}
	new name[24];
	format(name, sizeof(name), "None");

	for(new i; i < sizeof(HoldingObjectsAll); i++)
	{
		if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][toyid][ptModelID])
		{
			strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
		}
	}
	if(msg)
	{
		new boneName[16];
		strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][toyid][ptBone]], sizeof(boneName));
		SendClientMessageEx(playerid, COLOR_RED, "Da gan %s (Xuong: %s) (O: %d)", name, boneName, toyid);
	}
	PlayerHoldingObject[playerid][toycount] = toyid;
	SetPlayerAttachedObject(playerid, toycount, PlayerToyInfo[playerid][toyid][ptModelID], PlayerToyInfo[playerid][toyid][ptBone], PlayerToyInfo[playerid][toyid][ptPosX], PlayerToyInfo[playerid][toyid][ptPosY], PlayerToyInfo[playerid][toyid][ptPosZ],
	PlayerToyInfo[playerid][toyid][ptRotX], PlayerToyInfo[playerid][toyid][ptRotY], PlayerToyInfo[playerid][toyid][ptRotZ], PlayerToyInfo[playerid][toyid][ptScaleX], PlayerToyInfo[playerid][toyid][ptScaleY], PlayerToyInfo[playerid][toyid][ptScaleZ]);
	return 1;
}

stock player_remove_vip_toys(iTargetID)
{
	if(PlayerInfo[iTargetID][pDonateRank] >= 3) return 1;
	else for(new iToyIter; iToyIter < MAX_PLAYER_ATTACHED_OBJECTS; ++iToyIter) {
		for(new LoopRapist; LoopRapist < sizeof(HoldingObjectsCop); ++LoopRapist) {
			if(HoldingObjectsCop[LoopRapist][holdingmodelid] == PlayerToyInfo[iTargetID][iToyIter][ptModelID]) {
				PlayerToyInfo[iTargetID][iToyIter][ptModelID] = 0;
				PlayerToyInfo[iTargetID][iToyIter][ptBone] = 0;
				PlayerToyInfo[iTargetID][iToyIter][ptPosX] = 0.0;
				PlayerToyInfo[iTargetID][iToyIter][ptPosY] = 0.0;
				PlayerToyInfo[iTargetID][iToyIter][ptPosZ] = 0.0;
				PlayerToyInfo[iTargetID][iToyIter][ptPosX] = 0.0;
				PlayerToyInfo[iTargetID][iToyIter][ptPosY] = 0.0;
				PlayerToyInfo[iTargetID][iToyIter][ptPosZ] = 0.0;
				if(IsPlayerAttachedObjectSlotUsed(iTargetID, iToyIter)) RemovePlayerAttachedObject(iTargetID, iToyIter);

				g_mysql_SaveToys(iTargetID, iToyIter);
			}
		}
	}
	SendClientMessageEx(iTargetID, COLOR_WHITE, "Da go moi phu kien/toy thuoc co quan cu cua ban.");
	return 1;
}

CMD:shopvest(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1 && PlayerInfo[playerid][pAdmin] < 1338)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new string[128], giveplayerid, slot, invoice[64];
	if(sscanf(params, "uds[64]", giveplayerid, slot, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopvest [player] [slot(0-9)] [invoice #]");

	PlayerToyInfo[giveplayerid][slot][ptModelID] = 19142;
	PlayerToyInfo[giveplayerid][slot][ptBone] = 1;
	PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
	g_mysql_NewToy(giveplayerid, slot);
	SendClientMessageEx(giveplayerid, COLOR_LIGHTGREEN, "Ban nhan ao giap canh sat tai o %d, dung /toys de quan ly", slot);
	SendClientMessageEx(playerid, COLOR_LIGHTGREEN, "Ban cap cho %s ao giap canh sat tai o %d", GetPlayerNameEx(giveplayerid), slot);
	format(string, sizeof(string), "[SHOPVEST] %s has given %s(%d) a police vest toy - Invoice %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
	Log("logs/shoplog.log", string);

	g_mysql_SaveToys(giveplayerid, slot);
	return 1;
}

CMD:listtoys(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1) {

		new giveplayerid, string[64];
		szMiscArray[0] = 0;
		if(sscanf(params, "u", giveplayerid)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /listtoys [player]");
		}
		else if(IsPlayerConnected(giveplayerid))
		{
			new icount = GetPlayerToySlots(giveplayerid);
		    for(new x;x<icount;x++)
			{
				new boneName[16];
				new name[24] = "None";

				for(new i;i<sizeof(HoldingObjectsAll);i++)
				{
					if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[giveplayerid][x][ptModelID])
					{
						strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
						break;
					}
				}
				if(PlayerToyInfo[giveplayerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
				{
				    format(name, sizeof(name), "ID: %d", PlayerToyInfo[giveplayerid][x][ptModelID]);
				}
				strunpack(boneName, HoldingBones[PlayerToyInfo[giveplayerid][x][ptBone]], sizeof(boneName));
				format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s (Gan: %s%s)\n", szMiscArray, x, name, boneName, (PlayerToyInfo[giveplayerid][x][ptSpecial] > 1) ? (", Dac biet") : (""));
			}
			format(string, sizeof(string), "Toy cua %s - Chon o", GetPlayerNameEx(giveplayerid));
			ShowPlayerDialogEx(playerid, LISTTOYS_DELETETOY, DIALOG_STYLE_LIST, string, szMiscArray, "Xoa", "Huy");
			SetPVarInt(playerid, "listtoys_giveplayerid", giveplayerid);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
	}
	return 1;
}

CMD:shoplaser(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1 && PlayerInfo[playerid][pAdmin] < 1338)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new string[128], giveplayerid, slot, color[32], invoice[64];
	if(sscanf(params, "udss[64]", giveplayerid, slot, color, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shoplaser [player] [slot(0-9)] [red/green/orange/yellow/pink/blue] [invoice #]");

	if(strcmp(color,"red",true) == 0)
	{
		PlayerToyInfo[giveplayerid][slot][ptModelID] = 18643;
		PlayerToyInfo[giveplayerid][slot][ptBone] = 6;
		PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
		g_mysql_NewToy(giveplayerid, slot);
	}
	else if(strcmp(color,"green",true) == 0)
	{
		PlayerToyInfo[giveplayerid][slot][ptModelID] = 19083;
		PlayerToyInfo[giveplayerid][slot][ptBone] = 6;
		PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
		g_mysql_NewToy(giveplayerid, slot);
	}
	else if(strcmp(color,"orange",true) == 0)
	{
		PlayerToyInfo[giveplayerid][slot][ptModelID] = 19082;
		PlayerToyInfo[giveplayerid][slot][ptBone] = 6;
		PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
		g_mysql_NewToy(giveplayerid, slot);
	}
	else if(strcmp(color,"yellow",true) == 0)
	{
		PlayerToyInfo[giveplayerid][slot][ptModelID] = 19084;
		PlayerToyInfo[giveplayerid][slot][ptBone] = 6;
		PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
		g_mysql_NewToy(giveplayerid, slot);
	}
	else if(strcmp(color,"pink",true) == 0)
	{
		PlayerToyInfo[giveplayerid][slot][ptModelID] = 19081;
		PlayerToyInfo[giveplayerid][slot][ptBone] = 6;
		PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
		g_mysql_NewToy(giveplayerid, slot);
	}
	else if(strcmp(color,"blue",true) == 0)
	{
		PlayerToyInfo[giveplayerid][slot][ptModelID] = 19080;
		PlayerToyInfo[giveplayerid][slot][ptBone] = 6;
		PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
		g_mysql_NewToy(giveplayerid, slot);
	}
	SendClientMessageEx(giveplayerid, COLOR_LIGHTGREEN, "Ban nhan laser %s tai o %d, dung /toys de quan ly", color, slot);
	SendClientMessageEx(playerid, COLOR_LIGHTGREEN, "Ban cap cho %s laser %s tai o %d", GetPlayerNameEx(giveplayerid), color, slot);
	format(string, sizeof(string), "[SHOPLASER] %s has given %s(%d) a laser toy - Invoice %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
	Log("logs/shoplog.log", string);

	g_mysql_SaveToys(giveplayerid, slot);
	return 1;
}

CMD:giveobject(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4)
	{
		new giveplayerid, object;
		if(sscanf(params, "ud", giveplayerid, object)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /giveobject [player] [object]");
		if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le");
		szMiscArray[0] = 0;
		SetPVarInt(playerid, "giveplayeridtoy", giveplayerid);
		SetPVarInt(playerid, "toyid", object);
		new icount = GetPlayerToySlots(giveplayerid);
		for(new x;x<icount;x++)
		{
		    new boneName[16];
		    new name[24];
		    format(name, sizeof(name), "None");

			for(new i;i<sizeof(HoldingObjectsAll);i++)
			{
				if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[giveplayerid][x][ptModelID])
		        {
					strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
				}
			}
			if(PlayerToyInfo[giveplayerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
			{
			    format(name, sizeof(name), "ID: %d", PlayerToyInfo[giveplayerid][x][ptModelID]);
			}
			strunpack(boneName, HoldingBones[PlayerToyInfo[giveplayerid][x][ptBone]], sizeof(boneName));
			format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s (Gan: %s)\n", szMiscArray, x, name, boneName);
		}
   		ShowPlayerDialogEx(playerid, GIVETOY, DIALOG_STYLE_LIST, "Chon o", szMiscArray, "Chon", "Huy");
	}
	else {
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

CMD:shopobject(playerid, params[])
{
	if(PlayerInfo[playerid][pShopTech] >= 1)
	{
		ShowPlayerDialogEx(playerid, SHOPOBJECT_ORDERID, DIALOG_STYLE_INPUT, "Shop Objects - Ma don", "Nhap Order ID", "Dong y", "Huy");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		return 1;
	}
	return 1;
}

CMD:buytoys(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 4, 2787.095947, 2390.353027, 1240.531127) || IsPlayerInRangeOfPoint(playerid, 4, 1774.7533, 1422.6665, 2013.4979) || IsPlayerInRangeOfPoint(playerid, 4, 775.0900, 1742.4900, 1938.3800))
	{
		if(PlayerInfo[playerid][pDonateRank] < 3)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "* Ban khong phai Gold hoac Platinum VIP!");
		}
		else
		{
			ShowPlayerDialogEx( playerid, BUYTOYSGOLD, DIALOG_STYLE_MSGBOX, "Toy Store", "Chao mung den VIP toy store! Mua phu kien de gan len nhan vat.\n\nTruoc tien, chon o de cat toy.","Tiep tuc", "Huy" );
		}
	}
	else
	{
		new biz = InBusiness(playerid);
	   	if (biz == INVALID_BUSINESS_ID || Businesses[biz][bType] != BUSINESS_TYPE_CLOTHING) {
	        SendClientMessageEx(playerid, COLOR_GRAD2, "   Ban khong o trong cua hang quan ao!");
	        return 1;
	    }
		if (Businesses[biz][bInventory] < 1) {
	    	SendClientMessageEx(playerid, COLOR_GRAD2, "   Cua hang khong co quan ao!");
		    return 1;
		}
		if (!Businesses[biz][bStatus]) {
		    SendClientMessageEx(playerid, COLOR_GRAD2, "   Cua hang quan ao nay dang dong cua!");
		    return 1;
		}
		ShowPlayerDialogEx( playerid, BUYTOYS, DIALOG_STYLE_MSGBOX, "Toy Store", "Chao mung den toy store! Mua phu kien de gan len nhan vat.\n\nTruoc tien, chon o de cat toy.","Tiep tuc", "Huy" );
	}
	return 1;
}

CMD:toyhelp(playerid, params[])
{
	SetPVarInt(playerid, "HelpResultCat0", 9);
	Help_ListCat(playerid, DIALOG_HELPCATOTHER1);
	return 1;
}

CMD:otoyhelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	SendClientMessageEx(playerid, COLOR_WHITE,"*** HUONG DAN TOY ***");
	SendClientMessageEx(playerid, COLOR_GRAD3,"Den cua hang quan ao va dung {AA3333}/buytoys de mua toy");
	SendClientMessageEx(playerid, COLOR_GRAD3,"De gan/thao, sua hoac xoa toy, dung {AA3333}/toys");
	SendClientMessageEx(playerid, COLOR_GRAD3,"De gan nhanh tat ca toy, dung {AA3333}/wat");
	SendClientMessageEx(playerid, COLOR_GRAD3,"De thao nhanh tat ca toy, dung {AA3333}/dat");
	SendClientMessageEx(playerid, COLOR_GRAD3,"De gan nhanh toy tai mot o, dung {AA3333}/wt [toyslot]");
	SendClientMessageEx(playerid, COLOR_GRAD3,"De thao nhanh toy tai mot o, dung {AA3333}/dt [toyslot]");
	return 1;
}

CMD:toys(playerid, params[])
{
	if(GetPVarInt(playerid, "EventToken" ) == 1 || PlayerInfo[playerid][pJailTime] != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the dung lenh nay.");
	ShowPlayerDialogEx( playerid, TOYS, DIALOG_STYLE_LIST, "Menu toy", "Gan/Thao toy\nSua toy\nXoa toy","Chon", "Huy" );
	return 1;
}

CMD:wt(playerid, params[])
{
	new toyslot;
	if(sscanf(params, "d", toyslot)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /wt [toyslot]");

	if(toyslot < 1 || toyslot > MAX_PLAYERTOYS+1) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /wt [toyslot]");
	if(GetPVarInt(playerid, "EventToken" ) == 1 || PlayerInfo[playerid][pJailTime] != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the dung lenh nay.");

	for(new i; i < 10; i++)
	{
		if(PlayerHoldingObject[playerid][i] == toyslot)
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, i))
			{
				return 1;
			}
		}
	}
	// Toy Slot is -1 since players see their toys list starting off from 1
	if(PlayerToyInfo[playerid][toyslot-1][ptScaleX] == 0) {
		PlayerToyInfo[playerid][toyslot-1][ptScaleX] = 1.0;
		PlayerToyInfo[playerid][toyslot-1][ptScaleY] = 1.0;
		PlayerToyInfo[playerid][toyslot-1][ptScaleZ] = 1.0;
	}

	if(PlayerToyInfo[playerid][toyslot-1][ptModelID] != 0 && PlayerToyInfo[playerid][toyslot-1][ptSpecial] != 2)
	{
		new toycount = GetFreeToySlot(playerid);
		if(PlayerInfo[playerid][pBEquipped] && toycount == 9) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the gan toy nay khi dang deo ba lo.");
		PlayerHoldingObject[playerid][toycount] = toyslot;
		SetPlayerAttachedObject(playerid, toycount,
			PlayerToyInfo[playerid][toyslot-1][ptModelID],
			PlayerToyInfo[playerid][toyslot-1][ptBone],
			PlayerToyInfo[playerid][toyslot-1][ptPosX],
			PlayerToyInfo[playerid][toyslot-1][ptPosY],
			PlayerToyInfo[playerid][toyslot-1][ptPosZ],
			PlayerToyInfo[playerid][toyslot-1][ptRotX],
			PlayerToyInfo[playerid][toyslot-1][ptRotY],
			PlayerToyInfo[playerid][toyslot-1][ptRotZ],
			PlayerToyInfo[playerid][toyslot-1][ptScaleX],
			PlayerToyInfo[playerid][toyslot-1][ptScaleY],
			PlayerToyInfo[playerid][toyslot-1][ptScaleZ]
		);
	}
	return 1;
}

CMD:dt(playerid, params[])
{
	new toyslot;
	if(sscanf(params, "d", toyslot)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dt [toyslot]");

	if(toyslot < 1 || toyslot > MAX_PLAYERTOYS) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dt [toyslot]");


	for(new i; i < 10; i++)
	{
		if(PlayerHoldingObject[playerid][i] == toyslot)
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, i) || PlayerHoldingObject[playerid][i])
			{
				if(i == 9 && PlayerInfo[playerid][pBEquipped] || PlayerToyInfo[playerid][toyslot-1][ptSpecial] == 2)
					break;
				RemovePlayerAttachedObject(playerid, i);
				PlayerHoldingObject[playerid][i] = 0;
				break;
			}
		}
	}
	return 1;
}

CMD:wat(playerid, params[])
{
	if(GetPVarInt(playerid, "EventToken" ) == 1 || PlayerInfo[playerid][pJailTime] != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the dung lenh nay");
	new count = 0;
	SendClientMessageEx(playerid, COLOR_WHITE, "* Da gan so toy toi da.");
	for(new x;x<MAX_PLAYERTOYS;x++)
	{
		if(PlayerToyInfo[playerid][x][ptScaleX] == 0) {
			PlayerToyInfo[playerid][x][ptScaleX] = 1.0;
			PlayerToyInfo[playerid][x][ptScaleY] = 1.0;
			PlayerToyInfo[playerid][x][ptScaleZ] = 1.0;
		}
		if(PlayerToyInfo[playerid][x][ptModelID] != 0 && PlayerToyInfo[playerid][x][ptSpecial] != 2)
		{
			if(x == 9 && PlayerInfo[playerid][pBEquipped])
				break;
			SetPlayerAttachedObject(playerid, x, PlayerToyInfo[playerid][x][ptModelID], PlayerToyInfo[playerid][x][ptBone], PlayerToyInfo[playerid][x][ptPosX], PlayerToyInfo[playerid][x][ptPosY], PlayerToyInfo[playerid][x][ptPosZ], PlayerToyInfo[playerid][x][ptRotX], PlayerToyInfo[playerid][x][ptRotY], PlayerToyInfo[playerid][x][ptRotZ], PlayerToyInfo[playerid][x][ptScaleX], PlayerToyInfo[playerid][x][ptScaleY], PlayerToyInfo[playerid][x][ptScaleZ]),
			PlayerHoldingObject[playerid][count] = x;
			count++;
		}
		if(count == 10)
			break;
	}
	return 1;
}

CMD:dat(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_WHITE, "* Da thao tat ca toy.");
	for(new i; i < 10; i++)
	{
		if((IsPlayerAttachedObjectSlotUsed(playerid, i) || PlayerHoldingObject[playerid][i]) && PlayerToyInfo[playerid][PlayerHoldingObject[playerid][i]][ptSpecial] != 2)
		{
			if(i == 9 && PlayerInfo[playerid][pBEquipped])
				break;
			PlayerHoldingObject[playerid][i] = 0;
			RemovePlayerAttachedObject(playerid, i);
		}
	}
    return 1;
}

CMD:selltoy(playerid, params[])
{
	new name[24], targetid, cost;
	if(GetPVarType(playerid, "ttBuyer")) return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang giao dich voi nguoi khac.");
	if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid,COLOR_GREY,"Khong the lam vay trong dau truong!");
   	if(GetPVarInt( playerid, "EventToken") != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang trong su kien.");
	if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi bi cong.");
    if(GetPVarInt(playerid, "WatchingTV")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay khi dang xem TV!");
    if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid,COLOR_GREY,"Khong the lam vay khi dang o tu!");
    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
	if(sscanf(params, "ud", targetid, cost)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /selltoy [playerid] [price]");
	if(!IsPlayerConnected(targetid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	if(targetid == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh nay voi chinh minh.");
	if(!ProxDetectorS(5.0, playerid, targetid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
	if(InsideTradeToys[targetid] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang giao dich, hay thu lai sau.");
	if(cost < 1 || cost > 1000000000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia ban toy khong duoc duoi $1.");

	SetPVarInt(targetid, "ttSeller", playerid);
	SetPVarInt(playerid, "ttBuyer", targetid);
	SetPVarInt(playerid, "ttCost", cost);

	new icount = GetPlayerToySlots(playerid);
	for(new x;x<icount;x++)
	{
		format(name, sizeof(name), "None");
		for(new i;i<sizeof(HoldingObjectsAll);i++)
		{
			if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][x][ptModelID])
			{
				strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
			}
		}
		if(PlayerToyInfo[playerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
		{
			format(name, sizeof(name), "ID: %d", PlayerToyInfo[playerid][x][ptModelID]);
		}
		format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s\n", szMiscArray, x+1, name);
	}
	ShowPlayerDialogEx(playerid, SELLTOY, DIALOG_STYLE_LIST, "Chon toy de ban", szMiscArray, "Ban", "Huy"); // x+1 since toys list starts off from 1 (From players view)
	return 1;
}
