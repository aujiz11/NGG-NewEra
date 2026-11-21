/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Backpack System

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

stock IsBackpackAvailable(playerid)
{
	#if defined zombiemode
		if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie"))
			return 0;
	#endif
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen") || GetPVarInt(playerid, "EMSAttempt") != 0 || HungerPlayerInfo[playerid][hgInEvent] != 0 || PlayerInfo[playerid][pHospital] > 0 || PlayerInfo[playerid][pAccountRestricted] != 0)
		return 0;
	if(GetPVarType(playerid, "IsInArena") || GetPVarInt( playerid, "EventToken") != 0 || IsPlayerInAnyVehicle(playerid) || GetPVarType(playerid, "AttemptingLockPick") || GetPVarInt(playerid, "WatchingTV") || PlayerInfo[playerid][pJailTime] > 0 || !PlayerInfo[playerid][pBEquipped])
		return 0;

	return 1;
}

stock GetBackpackFreeSlotGun(playerid) {
	new slot;
	for(new g = 6; g < 11; g++)
	{

		if(PlayerInfo[playerid][pBItems][g] == 0)
		{
			slot = g;
			break;
		}
	}
	return slot;
}

ShowBackpackMenu(playerid, dialogid, const extramsg[]) {
	new dgTitle[128],
		string[15];

	szMiscArray[0] = 0;
	if(!IsBackpackAvailable(playerid)) {
		DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
		return 1;
	}
	if(!GetPVarType(playerid, "BackpackOpen") || !GetPVarType(playerid, "BackpackProt")) {
		DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
		return 1;
	}

	format(dgTitle, sizeof(dgTitle), "%s Do %s", GetBackpackName(PlayerInfo[playerid][pBackpack]), extramsg);
	switch(dialogid) {
		case DIALOG_OBACKPACK: {
			format(szMiscArray, sizeof(szMiscArray), "Thuc an ({FFF94D}%d Suat{FFFFFF})\nMa tuy ({FFF94D}%d Gram{FFFFFF})\nSung\nEnergy Bars ({FFF94D}%d Thanh{FFFFFF})", PlayerInfo[playerid][pBItems][0], GetBackpackNarcoticsGrams(playerid), PlayerInfo[playerid][pBItems][11]);
			if(PlayerInfo[playerid][pBItems][5] != 0 && (IsACop(playerid) || IsAMedic(playerid) || IsAGovernment(playerid) || IsATowman(playerid))) format(szMiscArray, sizeof(szMiscArray), "%s\nMedic & Kevlar Vest Kits ({FFF94D}%d{FFFFFF})",szMiscArray, PlayerInfo[playerid][pBItems][5]);
			ShowPlayerDialogEx(playerid, DIALOG_OBACKPACK, DIALOG_STYLE_LIST, dgTitle, szMiscArray, "Chon", "Huy");
		}
		case DIALOG_BFOOD: {
			ShowPlayerDialogEx(playerid, DIALOG_BFOOD, DIALOG_STYLE_MSGBOX, dgTitle, "Ban chac muon dung suat an nay?", "Xac nhan", "Huy");
		}
		case DIALOG_BMEDKIT: {
			ShowPlayerDialogEx(playerid, DIALOG_BMEDKIT, DIALOG_STYLE_MSGBOX, dgTitle, "Ban chac muon dung Medical & Kevlar Vest kit nay?", "Xac nhan", "Huy");
		}
		case DIALOG_BNARCOTICS: {

			for(new i; i < sizeof(Drugs); ++i) {

				format(szMiscArray, sizeof(szMiscArray), "%s%s({FFF94D}%d{A9C4E4} Gram)\n", szMiscArray, Drugs[i], PlayerInfo[playerid][pBDrugs][i]);
			}
			ShowPlayerDialogEx(playerid, DIALOG_BNARCOTICS, DIALOG_STYLE_LIST, dgTitle, szMiscArray, "Chon", "Huy");
		}
		case DIALOG_BNARCOTICS2: {
			new pbi = GetPVarInt(playerid, "pbitemindex");
			format(dgTitle, sizeof(dgTitle), "{FFF94D}%d{A9C4E4} Gram %s ({B20400}%d{A9C4E4} Tong gram)", PlayerInfo[playerid][pBDrugs][pbi], Drugs[pbi], GetBackpackNarcoticsGrams(playerid));
			ShowPlayerDialogEx(playerid, DIALOG_BNARCOTICS2, DIALOG_STYLE_LIST, dgTitle, "Rut ra\nGui vao", "Chon", "Huy");
		}
		case DIALOG_BNARCOTICS3: {
			new pbi = GetPVarInt(playerid, "pbitemindex");

			format(dgTitle, sizeof(dgTitle), "{FFF94D}%d{A9C4E4} Gram %s({B20400}%d{A9C4E4} Tong gram)\n", PlayerInfo[playerid][pBDrugs][pbi], Drugs[pbi], GetBackpackNarcoticsGrams(playerid));
			format(szMiscArray, sizeof(szMiscArray), "%s\nNhap so luong muon %s                                                        ", extramsg, (GetPVarInt(playerid, "bnwd")) ? ("gui vao") : ("rut ra"));
			ShowPlayerDialogEx(playerid, DIALOG_BNARCOTICS3, DIALOG_STYLE_INPUT, dgTitle, szMiscArray, "Chon", "Huy");
		}

		case DIALOG_BGUNS: {
			new weapname[20], itemcount;
			for(new i = 6; i < 11; i++)
			{
				if(PlayerInfo[playerid][pBItems][i] > 0)
				{
					GetWeaponName(PlayerInfo[playerid][pBItems][i], weapname, sizeof(weapname));
					format(szMiscArray, sizeof(szMiscArray), "%s%s (%i)\n", szMiscArray, weapname, i);
					format(string, sizeof(string), "ListItem%dSId", itemcount);
					SetPVarInt(playerid, string, i);
					itemcount++;
				}
			}
			SetPVarInt(playerid, "DepositGunId", itemcount);
			strcat(szMiscArray, "Cat vu khi");
			ShowPlayerDialogEx(playerid, DIALOG_BGUNS, DIALOG_STYLE_LIST, dgTitle, szMiscArray, "Chon", "Huy");
		}
		case DIALOG_ENERGYBARS: {
			DeletePVar(playerid, "bnwd");
			ShowPlayerDialogEx(playerid, DIALOG_ENERGYBARS, DIALOG_STYLE_LIST, dgTitle, "Rut ra\nGui vao", "Chon", "Huy");
		}
		case DIALOG_ENERGYBARS*2: {
			format(dgTitle, sizeof(dgTitle), "{FFF94D}%d {02B0F5}Energy Bars%s", (GetPVarInt(playerid, "bnwd")) ? PlayerInfo[playerid][mInventory][4]:PlayerInfo[playerid][pBItems][11], (GetPVarInt(playerid, "bnwd")) ? (" dang mang"):(""));
			format(szMiscArray, sizeof(szMiscArray), "%s\nNhap so luong muon %s:", extramsg, (GetPVarInt(playerid, "bnwd")) ? ("gui vao") : ("rut ra"));
			ShowPlayerDialogEx(playerid, DIALOG_ENERGYBARS, DIALOG_STYLE_INPUT, dgTitle, szMiscArray, "Chon", "Huy");
		}
	}
	return 1;
}

stock GetBackpackName(backpackid) {
	new bpName[16];
	switch(backpackid) {
		case 1: bpName = "Small Backpack";
		case 2: bpName = "Medium Backpack";
		case 3: bpName = "Large Backpack";
	}
	return bpName;
}

stock GetBackpackNarcoticsGrams(playerid) {

	new grams;
	for(new i; i < sizeof(Drugs); ++i) grams += PlayerInfo[playerid][pBDrugs][i];
	return grams;
}

stock GetBackpackIngredientsGrams(playerid) {

	new grams;
	for(new i; i < sizeof(szIngredients); ++i) grams += PlayerInfo[playerid][pBIngredients][i];
	return grams;
}

stock CountBackpackGuns(playerid) {
	new count;
	for(new i = 6; i < 11); i++)
		if(PlayerInfo[playerid][pBItems][i] > 0)
			count++;
	return count;
}

CMD:shopbpack(playerid, params[]) {
	if(PlayerInfo[playerid][pShopTech] >= 1 || PlayerInfo[playerid][pAdmin] > 3)
	{
		new playertogive, type, orderid;

		if(sscanf(params, "uii", playertogive, type, orderid)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopbpack [player] [type] [orderid]");
			SendClientMessageEx(playerid, COLOR_WHITE, "Loai: 1(Small Backpack), 2(Medium Backpack), 3(Large Backpack)");
		}
		else if(!(0 <= type <= 4)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopbpack [player] [type] [orderid]");
			SendClientMessageEx(playerid, COLOR_WHITE, "Loai: 1(Small Backpack), 2(Medium Backpack), 3(Large Backpack)");
		}
		else {

			new
				TypeName[7],
				szMessage[87];


			switch(type)
			{
				case 1:
				{
					TypeName = "Small";
					SetPlayerAttachedObject(playertogive, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
				}
				case 2:
				{
					TypeName = "Medium";
					SetPlayerAttachedObject(playertogive, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
				}
				case 3:
				{
					TypeName = "Large";
					SetPlayerAttachedObject(playertogive, 9, 3026, 1, -0.254999, -0.109, -0.022999, 10.6, -1.20002, 3.4, 1.265, 1.242, 1.062);
				}
			}

			PlayerInfo[playertogive][pBackpack] = type;
			PlayerInfo[playertogive][pBEquipped] = 1;
			PlayerInfo[playertogive][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
			PlayerInfo[playertogive][pBStoredH] = INVALID_HOUSE_ID;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da tao %s Backpack cho %s (OrderID: %d).", TypeName, GetPlayerNameEx(playertogive), orderid);

			SendClientMessageEx(playertogive, COLOR_WHITE, "Ban nhan %s Backpack tu %s (OrderID: %d).", TypeName, GetPlayerNameEx(playerid), orderid);

			SendClientMessageEx(playertogive, COLOR_GREY, "Dung /backpackhelp de xem danh sach lenh.");

			format(szMessage, sizeof(szMessage), "%s created a %s Backpack (%i) for %s(%d) (OrderID: %d).", GetPlayerNameEx(playerid), TypeName, type, GetPlayerNameEx(playertogive), GetPlayerSQLId(playertogive), orderid);
			Log("logs/shoplog.log", szMessage);
		}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_OBACKPACK: {
			if(response) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}
				switch(listitem) {
					case 0: { // Food
						if(PlayerInfo[playerid][pBItems][0] > 0) {
							ShowBackpackMenu(playerid, DIALOG_BFOOD, "- {02B0F5}Xac nhan dung suat an");
						}
						else {
							ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "- {A80000}Ban khong co suat an");
						}
					}
					case 1: { // Narcotics
						ShowBackpackMenu(playerid, DIALOG_BNARCOTICS, "- {02B0F5}Chon ma tuy");
					}
					case 2: { // Guns
						if(PlayerInfo[playerid][pWRestricted] || PlayerInfo[playerid][pAccountRestricted]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung muc nay khi bi han che.");
						ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chon vu khi");
					}
					case 3: { // Energy Bars
						ShowBackpackMenu(playerid, DIALOG_ENERGYBARS, "- {02B0F5}Energy Bars");
					}
					case 4: { // Med Kits
						if(PlayerInfo[playerid][pBItems][5] > 0) {
							ShowBackpackMenu(playerid, DIALOG_BMEDKIT, "- {02B0F5}Xac nhan dung Med Kit");
						}
						else {
							ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "- {A80000}Ban khong co Med Kit");
						}
					}
				}
			}
			else {
				DeletePVar(playerid, "BackpackProt");
				DeletePVar(playerid, "BackpackOpen");
			}
		}
		case DIALOG_BFOOD: {
			if(response) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}
				if(GetPVarInt(playerid, "BackpackMeal") == 1) {
					ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "- {A80000}Ban dang dung suat an.");
				}
				else
				{
					defer FinishMeal(playerid);
					SetPVarInt(playerid, "BackpackMeal", 1);
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, false, false, false, false, 0, 1);
					format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s mo ba lo va lay Full Meal ra.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang lay suat an tu ba lo, vui long cho.");
					ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
			}
			else {
				ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "");
			}
		}
		case DIALOG_BMEDKIT: {
			if(response && (IsACop(playerid) || IsAMedic(playerid) || IsAGovernment(playerid))) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}
				if(GetPVarInt(playerid, "BackpackMedKit") == 1) {
					ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "- {A80000}Ban dang dung Med Kit.");
				}
				else
				{
					defer FinishMedKit(playerid);
					SetPVarInt(playerid, "BackpackMedKit", 1);
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, false, false, false, false, 0, 1);
					format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s mo ba lo, lay Kevlar Vest va First Aid Kit.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang lay Med Kit tu ba lo, vui long cho.");
					ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
			}
			else {
				ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "");
			}
		}
		case DIALOG_BNARCOTICS: {
			if(response) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}
				SetPVarInt(playerid, "pbitemindex", listitem);
				ShowBackpackMenu(playerid, DIALOG_BNARCOTICS2, "");
			}
			else {
				ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "");
			}
		}
		case DIALOG_BNARCOTICS2: {
			if(response) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}
				SetPVarInt(playerid, "bnwd", listitem);
				ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, "");
			}
			else {
				ShowBackpackMenu(playerid, DIALOG_BNARCOTICS, "- {02B0F5}Chon ma tuy");
			}
		}
		case DIALOG_BNARCOTICS3: {
			if(response) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}

				new pbi = GetPVarInt(playerid, "pbitemindex");
				if(GetPVarInt(playerid, "bnwd")) {
					new namount, maxgrams, dInfo[135];
					if(sscanf(inputtext, "d", namount)) return ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, "{B20400}Du lieu sai{A9C4E4}");
					if(namount < 1) return ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, "{B20400}Du lieu sai{A9C4E4}\nSo luong phai tu 1 tro len");
					switch(PlayerInfo[playerid][pBackpack]) {
						case 1: maxgrams = 40;
						case 2: maxgrams = 100;
						case 3: maxgrams = 250;
					}
					if(namount > (maxgrams-GetBackpackNarcoticsGrams(playerid)))
					{
						format(dInfo, sizeof(dInfo), "{B20400}Du lieu sai, chi chua duoc %d gram{A9C4E4}\nCon cho chua {FFF600}%d{A9C4E4} gram\nNhap so luong gui vao", maxgrams, maxgrams-GetBackpackNarcoticsGrams(playerid));
						ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, dInfo);
						return 1;
					}

					if(PlayerInfo[playerid][pDrugs][pbi] >= namount) PlayerInfo[playerid][pDrugs][pbi] -= namount;
					else return ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, "{B20400}Du lieu sai{A9C4E4}\nBan khong co du so gram do.");

					PlayerInfo[playerid][pBDrugs][pbi] += namount;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d gram %s vao ba lo.", namount, Drugs[pbi]);
					new ip[MAX_PLAYER_NAME];
					GetPlayerIp(playerid, ip, sizeof(ip));
					format(szMiscArray, sizeof(szMiscArray), "[DRUGS] %s(%d) (IP:%s) deposited %d grams of %s (%d grams Total) [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, namount, Drugs[pbi], PlayerInfo[playerid][pDrugs][pbi], PlayerInfo[playerid][pBackpack]);
					Log("logs/backpack.log", szMiscArray);
					ShowBackpackMenu(playerid, DIALOG_BNARCOTICS, "- {02B0F5}Chon ma tuy");
				}
				else {
					new namount, dInfo[135];
					if(sscanf(inputtext, "d", namount)) return ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, "{B20400}Du lieu sai{A9C4E4}");
					if(namount < 1) return ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, "{B20400}Du lieu sai{A9C4E4}\nSo luong phai tu 1 tro len");
					if(namount > PlayerInfo[playerid][pBDrugs][pbi])
					{
						format(dInfo, sizeof(dInfo), "{B20400}Du lieu sai, chi co %d gram %s{A9C4E4}\nDang rut {FFF600}%d{A9C4E4} gram\nNhap so luong gui vao", PlayerInfo[playerid][pBDrugs][pbi], Drugs[pbi], namount);
						ShowBackpackMenu(playerid, DIALOG_BNARCOTICS3, dInfo);
						return 1;
					}
					PlayerInfo[playerid][pBDrugs][pbi] -= namount;
					PlayerInfo[playerid][pDrugs][pbi] += namount;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d gram %s tu ba lo.", namount, Drugs[pbi]);
					new ip[MAX_PLAYER_NAME];
					GetPlayerIp(playerid, ip, sizeof(ip));
					format(szMiscArray, sizeof(szMiscArray), "[DRUGS] %s(%d) (IP:%s) withdrawn %d grams of %s (%d grams Total) [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, namount, Drugs[pbi], PlayerInfo[playerid][pBDrugs][pbi], PlayerInfo[playerid][pBackpack]);
					Log("logs/backpack.log", szMiscArray);
					ShowBackpackMenu(playerid, DIALOG_BNARCOTICS, "- {02B0F5}Chon ma tuy");
				}
			}
			else {
				ShowBackpackMenu(playerid, DIALOG_BNARCOTICS2, "");
			}
		}
		case DIALOG_BGUNS: {
			if(response) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}
				new szDialog[130], weapname[20];
				if(listitem == GetPVarInt(playerid, "DepositGunId")) {
					switch(PlayerInfo[playerid][pBackpack]) {
						case 1: {
							new myweapons[2], itemcount;
							GetPlayerWeaponData(playerid, 1, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && myweapons[0] != 9 && myweapons[0] != 4 && PlayerInfo[playerid][pGuns][1] == myweapons[0] && PlayerInfo[playerid][pAGuns][1] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 10, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && PlayerInfo[playerid][pGuns][10] == myweapons[0] && PlayerInfo[playerid][pAGuns][10] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 2, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && pTazer{playerid} == 0 && PlayerInfo[playerid][pGuns][2] == myweapons[0] && PlayerInfo[playerid][pAGuns][2] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
							}
							if(strlen(szDialog) > 0) ShowPlayerDialogEx(playerid, DIALOG_BGUNS2, DIALOG_STYLE_LIST, "Chon vu khi de cat", szDialog, "Chon", "Huy");
							else {
								ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chon vu khi - Khong co sung de cat");
							}
						}
						case 2, 3: {
							new myweapons[2], itemcount;
							GetPlayerWeaponData(playerid, 1, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && myweapons[0] != 9 && myweapons[0] != 4 && PlayerInfo[playerid][pGuns][1] == myweapons[0] && PlayerInfo[playerid][pAGuns][1] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 10, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && PlayerInfo[playerid][pGuns][10] == myweapons[0] && PlayerInfo[playerid][pAGuns][10] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 2, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && pTazer{playerid} == 0 && PlayerInfo[playerid][pGuns][2] == myweapons[0] && PlayerInfo[playerid][pAGuns][2] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 3, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && PlayerInfo[playerid][pGuns][3] == myweapons[0] && PlayerInfo[playerid][pAGuns][3] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 4, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && PlayerInfo[playerid][pGuns][4] == myweapons[0] && PlayerInfo[playerid][pAGuns][4] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 5, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && PlayerInfo[playerid][pGuns][5] == myweapons[0] && PlayerInfo[playerid][pAGuns][5] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
								itemcount++;
							}
							GetPlayerWeaponData(playerid, 6, myweapons[0], myweapons[1]);
							if(myweapons[0] > 0 && PlayerInfo[playerid][pGuns][6] == myweapons[0] && PlayerInfo[playerid][pAGuns][6] == 0)
							{
								GetWeaponName(myweapons[0], weapname, sizeof(weapname));
								format(szDialog, sizeof(szDialog), "%s%s (%d)\n", szDialog, weapname, myweapons[0]);
								format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", itemcount);
								SetPVarInt(playerid, szMiscArray, myweapons[0]);
							}
							if(strlen(szDialog) > 0) ShowPlayerDialogEx(playerid, DIALOG_BGUNS2, DIALOG_STYLE_LIST, "Chon vu khi de cat", szDialog, "Chon", "Huy");
							else {
								ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chon vu khi - Khong co sung de cat");
							}
						}
					}
				}
				else {

					format(szMiscArray, sizeof(szMiscArray), "ListItem%dSId", listitem);
					new slot = GetPVarInt(playerid, szMiscArray);
					if(PlayerInfo[playerid][pBItems][slot] > 0) {

						new aWeapons[13][2];

						for(new i; i < 13; ++i) {
							GetPlayerWeaponData(playerid, i, aWeapons[i][0], aWeapons[i][1]);
							if(aWeapons[i][0] == PlayerInfo[playerid][pBItems][slot]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da mang vu khi nay.");
						}

						GetWeaponName(PlayerInfo[playerid][pBItems][slot], weapname, sizeof(weapname));
						GivePlayerValidWeapon(playerid, PlayerInfo[playerid][pBItems][slot]);

						DeletePVar(playerid, szMiscArray);

						SendClientMessageEx(playerid, COLOR_WHITE, "Ban da lay %s tu ba lo.", weapname);

						format(szMiscArray, sizeof(szMiscArray), "* %s lay %s tu ba lo.", GetPlayerNameEx(playerid), weapname);
						ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						new ip[MAX_PLAYER_NAME];
						GetPlayerIp(playerid, ip, sizeof(ip));
						format(szMiscArray, sizeof(szMiscArray), "[WEAPONS] %s(%d) (IP:%s) withdrawn a %s(%d) [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, weapname, PlayerInfo[playerid][pBItems][slot], PlayerInfo[playerid][pBackpack]);
						Log("logs/backpack.log", szMiscArray);
						PlayerInfo[playerid][pBItems][slot] = 0;
						ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chon vu khi");
						return 1;
					}
				}
			}
			else {
				ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "");
			}
		}
		case DIALOG_BGUNS2: {
			if(response) {
				if(!IsBackpackAvailable(playerid)) {
					DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
					return 1;
				}
				new handguns, primguns, wbid, slot = GetBackpackFreeSlotGun(playerid), weapname[32];
				for(new i = 6; i < 11; i++) {
					if(PlayerInfo[playerid][pBItems][i] > 0) {
						if(IsWeaponHandgun(PlayerInfo[playerid][pBItems][i])) handguns++;
						else if(IsWeaponPrimary(PlayerInfo[playerid][pBItems][i])) primguns++;
					}
				}
				switch(PlayerInfo[playerid][pBackpack]) {
					case 1: {
						format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", listitem);
						wbid = GetPVarInt(playerid, szMiscArray);
						if(handguns > 1 || primguns > 0 || IsWeaponPrimary(wbid)) {
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chi mang duoc 2 sung ngan");
							return 1;
						}
						if(slot != 0 && PlayerInfo[playerid][pGuns][GetLoadoutWeaponSlot(wbid)] == wbid && PlayerInfo[playerid][pAGuns][GetLoadoutWeaponSlot(wbid)] == 0) {
							RemovePlayerLoadoutWeapon(playerid, wbid);
							PlayerInfo[playerid][pBItems][slot] = wbid;
							GetWeaponName(wbid, weapname, sizeof(weapname));
							SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat %s vao ba lo.", weapname);

							format(szMiscArray, sizeof(szMiscArray), "* %s cat %s vao ba lo.", GetPlayerNameEx(playerid), weapname);
							ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							new ip[MAX_PLAYER_NAME];
							GetPlayerIp(playerid, ip, sizeof(ip));
							format(szMiscArray, sizeof(szMiscArray), "[WEAPONS] %s(%d) (IP:%s) deposited a %s(%d) in slot %d [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, weapname, wbid, slot, PlayerInfo[playerid][pBackpack]);
							Log("logs/backpack.log", szMiscArray);
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chon vu khi");
							return 1;
						}
						else {
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chon vu khi LOI");
						}
					}
					case 2: {
						format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", listitem);
						wbid = GetPVarInt(playerid, szMiscArray);
						if((handguns >= 2 && IsWeaponHandgun(wbid)) || (IsWeaponPrimary(wbid) && primguns >= 1) || (handguns >= 2 && primguns >= 1)) {
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chi mang duoc 2 sung ngan va 1 sung chinh");
							return 1;
						}
						if(slot != 0 && PlayerInfo[playerid][pGuns][GetLoadoutWeaponSlot(wbid)] == wbid && PlayerInfo[playerid][pAGuns][GetLoadoutWeaponSlot(wbid)] == 0) {
							RemovePlayerLoadoutWeapon(playerid, wbid);
							PlayerInfo[playerid][pBItems][slot] = wbid;
							GetWeaponName(wbid, weapname, sizeof(weapname));
							SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat %s vao ba lo.", weapname);

							format(szMiscArray, sizeof(szMiscArray), "* %s cat %s vao ba lo.", GetPlayerNameEx(playerid), weapname);
							ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							new ip[MAX_PLAYER_NAME];
							GetPlayerIp(playerid, ip, sizeof(ip));
							format(szMiscArray, sizeof(szMiscArray), "[WEAPONS] %s(%d) (IP:%s) deposited a %s(%d) in slot %d [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, weapname, wbid, slot, PlayerInfo[playerid][pBackpack]);
							Log("logs/backpack.log", szMiscArray);
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- {02B0F5}Chon vu khi");
							return 1;
						}
						else {
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- Chon vu khi LOI");
						}
					}
					case 3: {
						format(szMiscArray, sizeof(szMiscArray), "ListItem%dWId", listitem);
						wbid = GetPVarInt(playerid, szMiscArray);
						if((handguns >= 2 && primguns >= 3) || (primguns >= 3 && IsWeaponPrimary(wbid)) || (handguns >= 2 && IsWeaponHandgun(wbid))) {
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- Chi mang duoc 2 sung ngan va 3 sung chinh");
							return 1;
						}
						if(slot != 0 && PlayerInfo[playerid][pGuns][GetLoadoutWeaponSlot(wbid)] == wbid && PlayerInfo[playerid][pAGuns][GetLoadoutWeaponSlot(wbid)] == 0) {
							RemovePlayerLoadoutWeapon(playerid, wbid);
							PlayerInfo[playerid][pBItems][slot] = wbid;
							GetWeaponName(wbid, weapname, sizeof(weapname));
							SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat %s vao ba lo.", weapname);

							format(szMiscArray, sizeof(szMiscArray), "* %s cat %s vao ba lo.", GetPlayerNameEx(playerid), weapname);
							ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							new ip[MAX_PLAYER_NAME];
							GetPlayerIp(playerid, ip, sizeof(ip));
							format(szMiscArray, sizeof(szMiscArray), "[WEAPONS] %s(%d) (IP:%s) deposited a %s(%d) in slot %d [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, weapname, wbid, slot, PlayerInfo[playerid][pBackpack]);
							Log("logs/backpack.log", szMiscArray);
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- Chon vu khi");
							return 1;
						}
						else {
							ShowBackpackMenu(playerid, DIALOG_BGUNS, "- Chon vu khi LOI");
						}
					}
				}
			}
			else {
				ShowBackpackMenu(playerid, DIALOG_BGUNS, "- Chon vu khi");
			}
		}
		case DIALOG_BMEALSTORE: {
			if(response) {
				PlayerInfo[playerid][pBItems][0]++;
				format(szMiscArray,sizeof(szMiscArray),"* Da cat Full Meal vao ba lo(%d suat).",PlayerInfo[playerid][pBItems][0]);
				SendClientMessage(playerid, COLOR_GRAD2, szMiscArray);
			}
			else {
				if (PlayerInfo[playerid][pFitness] >= 5)
					PlayerInfo[playerid][pFitness] -= 5;
				else
					PlayerInfo[playerid][pFitness] = 0;
				SetHealth(playerid, 100.0);
			}
		}
		case DIALOG_BDROP:
		{
			if(!response) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy bo ba lo.");
			if(PlayerInfo[playerid][pBackpack] > 0)
			{
				new choice[7];
				switch(PlayerInfo[playerid][pBackpack])
				{
					case 1: choice = "Small";
					case 2: choice = "Medium";
					case 3: choice = "Large";
				}
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da bo %s Backpack.", choice);
				RemovePlayerAttachedObject(playerid, 9);
				PlayerInfo[playerid][pBackpack] = 0;
				PlayerInfo[playerid][pBEquipped] = 0;
				PlayerInfo[playerid][pBStoredH] = INVALID_HOUSE_ID;
				PlayerInfo[playerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
				for(new i = 0; i < 10; i++)
				{
					PlayerInfo[playerid][pBItems][i] = 0;
				}
				format(szMiscArray, sizeof(szMiscArray), "* %s vut bo ba lo.", GetPlayerNameEx(playerid));
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				new ip[MAX_PLAYER_NAME];
				GetPlayerIp(playerid, ip, sizeof(ip));
				format(szMiscArray, sizeof(szMiscArray), "[DROP] %s(%d) (IP:%s) has thrown away his %s Backpack", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), choice);
				Log("logs/backpack.log", szMiscArray);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co ba lo!");
			}
		}
	}
	return 0;
}

CMD:sellbackpack(playerid, params[])
{
	if(PlayerInfo[playerid][pBackpack] > 0)
	{
		if(!PlayerInfo[playerid][pBEquipped]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua deo ba lo, dung /bwear de deo.");
		if(!IsBackpackAvailable(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
		if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang o dau truong, chua the lam vay!");
		if(GetPVarInt( playerid, "EventToken") != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang trong su kien.");
		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o trong xe!");
		if(GetPVarInt(playerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay!");
		if(GetPVarInt(playerid, "sellingbackpack")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang ban ba lo!");

		new giveplayerid, price, bptype[8];
		if(sscanf(params, "ui", giveplayerid, price)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sellbackpack [player] [price]");
			SendClientMessageEx(playerid, COLOR_YELLOW, "CANH BAO: /sellbackpack se tu dong xoa moi vat pham trong ba lo.");
			return 1;
		}
		if(price < 0) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sellbackpack [player] [price]");
			SendClientMessageEx(playerid, COLOR_YELLOW, "CANH BAO: /sellbackpack se tu dong xoa moi vat pham trong ba lo.");
			return 1;
		}
		if(IsPlayerConnected(giveplayerid))
		{
			if(playerid == giveplayerid) return 1;
			if (ProxDetectorS(8.0, playerid, giveplayerid))
			{
				switch(PlayerInfo[playerid][pBackpack])
				{
					case 1: bptype = "Small";
					case 2: bptype = "Medium";
					case 3: bptype = "Large";
				}
				if(PlayerInfo[giveplayerid][pBackpack] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da co ba lo!");
				SetPVarInt(giveplayerid, "sellbackpack", playerid);
				SetPVarInt(giveplayerid, "BackpackOfferSession", g_arrQueryHandle[playerid]);
				SetPVarInt(giveplayerid, "sellbackpackprice", price);
				SetPVarInt(playerid, "sellingbackpack", 1);
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s chao ban %s Backpack gia $%s. /accept backpack de nhan ba lo.", GetPlayerNameEx(playerid), bptype, number_format(price));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban chao %s mua %s Backpack gia $%s.",GetPlayerNameEx(giveplayerid), bptype, number_format(price));
			}
			else
			{
				return SendClientMessageEx(playerid, COLOR_GREY, " Nguoi do khong o gan ban!");
			}
		}
		else
		{
			return SendClientMessageEx(playerid, COLOR_GREY, " Nguoi do chua ket noi!");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co ba lo(Dung /miscshop de mua bang credits)");
	return 1;
}

CMD:listbitems(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 1 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /listbitems [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pBackpack] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co ba lo!");
			new btype[8], weaponname[50];
			switch(PlayerInfo[giveplayerid][pBackpack])
			{
				case 1: btype = "Small";
				case 2: btype = "Medium";
				case 3: btype = "Large";
			}
			SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
			SendClientMessageEx(playerid, COLOR_WHITE, "*** Vat pham cua %s trong %s Backpack...  ***", GetPlayerNameEx(giveplayerid), btype);
			if(PlayerInfo[giveplayerid][pBItems][0] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d suat an.", PlayerInfo[giveplayerid][pBItems][0]);
			}

			for(new i; i < sizeof(Drugs); ++i) {

				if(PlayerInfo[giveplayerid][pBDrugs][i] > 0) {

					SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d gram %s.", PlayerInfo[giveplayerid][pBDrugs][i], Drugs[i]);
				}
			}
			if(PlayerInfo[giveplayerid][pBItems][5] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d Medical Kits.", PlayerInfo[giveplayerid][pBItems][5]);
			}

			if(PlayerInfo[giveplayerid][pBItems][11] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d Energy Bars.", PlayerInfo[giveplayerid][pBItems][11]);
			}
			new sent;
			for (new i = 6; i < 11; i++)
			{
				if(PlayerInfo[giveplayerid][pBItems][i] > 0)
				{
					if(!sent)
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "*** Vu khi cua %s trong %s Backpack...  ***", GetPlayerNameEx(giveplayerid), btype);
						sent = 1;
					}
					GetWeaponName(PlayerInfo[giveplayerid][pBItems][i], weaponname, sizeof(weaponname));
					SendClientMessageEx(playerid, COLOR_GRAD1, "Vu khi: %s.", weaponname);
				}
			}
			SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:bsearch(playerid, params[])
{
	if(IsACop(playerid) || Job_HasJob(playerid, JOB_BODYGUARD))
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /bsearch [player]");

		if(IsPlayerConnected(giveplayerid) && ProxDetectorS(8.0, playerid, giveplayerid))
		{
			if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu kham minh!");
			if(PlayerInfo[giveplayerid][pBEquipped] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong deo ba lo!");
			new btype[8], weaponname[50];
			switch(PlayerInfo[giveplayerid][pBackpack])
			{
				case 1: btype = "Small";
				case 2: btype = "Medium";
				case 3: btype = "Large";
			}
			SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
			SendClientMessageEx(playerid, COLOR_WHITE, "*** Vat pham cua %s trong %s Backpack...  ***", GetPlayerNameEx(giveplayerid), btype);
			if(PlayerInfo[giveplayerid][pBItems][0] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d suat an.", PlayerInfo[giveplayerid][pBItems][0]);
			}

			for(new i; i < sizeof(Drugs); ++i) {

				if(PlayerInfo[giveplayerid][pBDrugs][i] > 0) {

					SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d gram %s.", PlayerInfo[giveplayerid][pBDrugs][i], Drugs[i]);
				}
			}

			if(PlayerInfo[giveplayerid][pBItems][5] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d Medical Kits.", PlayerInfo[giveplayerid][pBItems][5]);
			}

			if(PlayerInfo[giveplayerid][pBItems][11] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "(Backpack) %d Energy Bars.", PlayerInfo[giveplayerid][pBItems][11]);
			}
			new sent;
			for (new i = 6; i < 11; i++)
			{
				if(PlayerInfo[giveplayerid][pBItems][i] > 0)
				{
					if(!sent)
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "*** Vu khi cua %s trong %s Backpack...  ***", GetPlayerNameEx(giveplayerid), btype);
						sent = 1;
					}
					GetWeaponName(PlayerInfo[giveplayerid][pBItems][i], weaponname, sizeof(weaponname));
					SendClientMessageEx(playerid, COLOR_GRAD1, "Vu khi: %s.", weaponname);
				}
			}
			SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
			format(string, sizeof(string), "* %s kham ba lo cua %s de tim hang cam.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:bremove(playerid, params[])
{
    if (!IsACop(playerid))
	{
        SendClientMessageEx(playerid,COLOR_GREY,"Ban khong phai nhan vien hanh phap.");
        return 1;
    }
    new string[128], giveplayerid, item[6], bptype[8];
	if(sscanf(params, "us[6]", giveplayerid, item)) {
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /bremove [player] [item]");
		SendClientMessageEx(playerid, COLOR_YELLOW, "VAT PHAM: [All drugs - see /mydrugs], Guns, Meals");
		return 1;
	}
	if(IsPlayerConnected(giveplayerid))
	{
		if(playerid == giveplayerid) return 1;
		if (ProxDetectorS(8.0, playerid, giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pBEquipped] < 1 && PlayerInfo[giveplayerid][pBackpack] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong deo ba lo!");
			switch(PlayerInfo[playerid][pBackpack])
			{
				case 1: bptype = "Small";
				case 2: bptype = "Medium";
				case 3: bptype = "Large";
			}

			new iDrugID = GetDrugID(item);
			if(iDrugID != -1) {

				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da thu do cua %s: %s trong ba lo.", GetPlayerNameEx(giveplayerid), Drugs[iDrugID]);
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu %s cua ban trong ba lo.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), Drugs[iDrugID]);
				format(string, sizeof(string), "* Officer %s thu do cua %s: %s trong ba lo.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), Drugs[iDrugID]);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				PlayerInfo[giveplayerid][pBDrugs][iDrugID] = 0;
			}
			else if(strcmp(item,"meals",true) == 0)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu suat an cua %s trong ba lo.", GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu suat an cua ban trong ba lo.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				format(string, sizeof(string), "* Officer %s da thu suat an cua %s trong ba lo.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				PlayerInfo[giveplayerid][pBItems][0] = 0;
			}
			else if(strcmp(item,"guns",true) == 0)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da thu vu khi cua %s trong ba lo.", GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Officer %s da thu vu khi cua ban trong ba lo.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				format(string, sizeof(string), "* Officer %s da thu vu khi cua %s trong ba lo.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				for(new i = 6; i < 11; i++)
				{
					PlayerInfo[giveplayerid][pBItems][i] = 0;
				}
			}
		}
		else
		{
			return SendClientMessageEx(playerid, COLOR_GREY, " Nguoi do khong o gan ban!");
		}
	}
	else
	{
		return SendClientMessageEx(playerid, COLOR_GREY, " Nguoi do chua ket noi!");
	}
    return 1;
}

CMD:bwear(playerid, params[])
{
	if(PlayerInfo[playerid][pBackpack] > 0)
	{
		if(!IsBackpackAvailable(playerid) && PlayerInfo[playerid][pBEquipped]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
		if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang o dau truong, chua the lam vay!");
		if(GetPVarInt( playerid, "EventToken") != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang trong su kien.");
		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o trong xe!");
		if(GetPVarInt(playerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay!");
		if(PlayerInfo[playerid][pBEquipped]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang deo ba lo, dung /bstore de cat vao xe/nha.");
		new string[128], btype[8], i = 0, Float: x, Float: y, Float: z, pvid = -1;
		if(PlayerInfo[playerid][pBStoredV] != INVALID_PLAYER_VEHICLE_ID)
		{
			for(i = 0 ; i < MAX_PLAYERVEHICLES; i++)
			{
				if(PlayerVehicleInfo[playerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID && PlayerVehicleInfo[playerid][i][pvSlotId] == PlayerInfo[playerid][pBStoredV]) GetVehiclePos(PlayerVehicleInfo[playerid][i][pvId], x, y, z);
				if(IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
				{
					pvid = i;
					break;
				}
			}
			if(pvid == -1) return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong o gan xe dang cat ba lo.");
			new engine,lights,alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(PlayerVehicleInfo[playerid][pvid][pvId],engine,lights,alarm,doors,bonnet,boot,objective);
			if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET) return SendClientMessageEx(playerid, COLOR_GRAD3, "Phai mo cop de lay/cat do!(/car trunk de mo)");
			if(PlayerHoldingObject[playerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 9))
				RemovePlayerAttachedObject(playerid, 9), PlayerHoldingObject[playerid][9] = 0;
			switch(PlayerInfo[playerid][pBackpack])
			{
				case 1:
				{
					btype = "Small";
					SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
				}
				case 2:
				{
					btype = "Medium";
					SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
				}
				case 3:
				{
					btype = "Large";
					SetPlayerAttachedObject(playerid, 9, 3026, 1, -0.254999, -0.109, -0.022999, 10.6, -1.20002, 3.4, 1.265, 1.242, 1.062);
				}
			}
			SendClientMessageEx(playerid, COLOR_GREY, "Ban lay %s Backpack tu %s, dung /bstore de cat.", btype, GetVehicleName(PlayerVehicleInfo[playerid][pvid][pvId]));
			PlayerInfo[playerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
			PlayerInfo[playerid][pBEquipped] = 1;

			format(string, sizeof(string), "* %s lay ba lo tu cop xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else if(PlayerInfo[playerid][pBStoredH] != INVALID_HOUSE_ID)
		{
			for(i = 0; i < MAX_HOUSES; i++)
			{
				if(HouseInfo[i][hSQLId] == PlayerInfo[playerid][pBStoredH])
				{
					pvid = i;
					break;
				}
			}
			if(IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[pvid][hInteriorX], HouseInfo[pvid][hInteriorY], HouseInfo[pvid][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[pvid][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[pvid][hIntIW])
			{
				if(PlayerHoldingObject[playerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 9))
					RemovePlayerAttachedObject(playerid, 9), PlayerHoldingObject[playerid][9] = 0;
				switch(PlayerInfo[playerid][pBackpack])
				{
					case 1:
					{
						btype = "Small";
						SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
					}
					case 2:
					{
						btype = "Medium";
						SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
					}
					case 3:
					{
						btype = "Large";
						SetPlayerAttachedObject(playerid, 9, 3026, 1, -0.254999, -0.109, -0.022999, 10.6, -1.20002, 3.4, 1.265, 1.242, 1.062);
					}
				}
				SendClientMessageEx(playerid, COLOR_GREY, "Ban lay %s Backpack tu nha, dung /bstore de cat.", btype);
				PlayerInfo[playerid][pBStoredH] = INVALID_HOUSE_ID;
				PlayerInfo[playerid][pBEquipped] = 1;

				format(string, sizeof(string), "* %s lay ba lo tu nha.", GetPlayerNameEx(playerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o trong nha dang cat ba lo!");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co ba lo(Dung /miscshop de mua bang credits)");
	return 1;
}

CMD:bstore(playerid, params[])
{
	if(PlayerInfo[playerid][pBackpack] > 0)
	{
		if(!PlayerInfo[playerid][pBEquipped]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua deo ba lo, dung /bwear de deo.");
		if(!IsBackpackAvailable(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
		if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang o dau truong, chua the lam vay!");
		if(GetPVarInt(playerid, "EventToken") != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung khi dang trong su kien.");
		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o trong xe!");
		if(GetPVarInt(playerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay!");
		new Float: Health;
		GetHealth(playerid, Health);
		if(Health < 50.0) return SendClientMessageEx(playerid,COLOR_GREY,"Khong the cat ba lo vao nha/xe khi mau duoi 80.");

		new string[128], housecar[6];
		if(sscanf(params, "s[6]", housecar)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /bstore [house/car]");


		if(strcmp(housecar, "car", true, strlen(housecar)) == 0)
		{
			new pvid = -1, Float: x, Float: y, Float: z;

			for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
			{
				if(PlayerVehicleInfo[playerid][d][pvId] != INVALID_PLAYER_VEHICLE_ID) GetVehiclePos(PlayerVehicleInfo[playerid][d][pvId], x, y, z);
				if(IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
				{
					pvid = d;
					break;
				}
			}
			if(pvid == -1) return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong o gan xe cua minh.");
			new engine,lights,alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(PlayerVehicleInfo[playerid][pvid][pvId],engine,lights,alarm,doors,bonnet,boot,objective);
			if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET) return SendClientMessageEx(playerid, COLOR_GRAD3, "Phai mo cop de lay/cat do!(/car trunk de mo)");
			if(GetVehicleModel(PlayerVehicleInfo[playerid][pvid][pvId]) == 481 || GetVehicleModel(PlayerVehicleInfo[playerid][pvid][pvId]) == 510)  return SendClientMessageEx(playerid,COLOR_GREY,"Xe do khong co cop.");
			new btype[7];
			switch(PlayerInfo[playerid][pBackpack])
			{
				case 1: btype = "Small";
				case 2: btype = "Medium";
				case 3: btype = "Large";
			}
			SendClientMessageEx(playerid, COLOR_GREY, "Da cat %s Backpack vao %s, dung /bwear de deo.", btype, GetVehicleName(PlayerVehicleInfo[playerid][pvid][pvId]));
			RemovePlayerAttachedObject(playerid, 9);
			PlayerInfo[playerid][pBEquipped] = 0;
			PlayerInfo[playerid][pBStoredV] = PlayerVehicleInfo[playerid][pvid][pvSlotId];
			format(string, sizeof(string), "* %s cat ba lo vao cop xe.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			format(string, sizeof(string), "[TRUNK] %s(%d) (%s) stored their %s backpack in [SQLID:%d][SlotID:%d][ModelID:%d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), btype, PlayerVehicleInfo[playerid][pvid][pvSlotId], pvid, PlayerVehicleInfo[playerid][pvid][pvModelId]);
			Log("logs/backpack.log", string);
		}
		else if(strcmp(housecar, "house", true, strlen(housecar)) == 0)
		{
			if(Homes[playerid] > 0)
			{
				new hid = -1;
				for(new i; i < MAX_HOUSES; i++)
				{
					if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 50, HouseInfo[i][hInteriorX], HouseInfo[i][hInteriorY], HouseInfo[i][hInteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hIntVW] && GetPlayerInterior(playerid) == HouseInfo[i][hIntIW])
					{
						hid = i;
						break;
					}
				}
				if(hid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o trong nha cua minh.");
				new btype[7];
				switch(PlayerInfo[playerid][pBackpack])
				{
					case 1: btype = "Small";
					case 2: btype = "Medium";
					case 3: btype = "Large";
				}
				SendClientMessageEx(playerid, COLOR_GREY, "Da cat %s Backpack vao nha, dung /bwear de deo.", btype);
				RemovePlayerAttachedObject(playerid, 9);
				PlayerInfo[playerid][pBEquipped] = 0;
				PlayerInfo[playerid][pBStoredH] = HouseInfo[hid][hSQLId];
				format(string, sizeof(string), "* %s cat ba lo vao nha.", GetPlayerNameEx(playerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				format(string, sizeof(string), "[HOUSE] %s(%d) (%s) stored his %s backpack in [HouseID:%d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), btype, hid);
				Log("logs/backpack.log", string);
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu nha.");
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /bstore [house/car]");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co ba lo(Dung /miscshop de mua bang credits)");
	return 1;
}


CMD:bopen(playerid, params[])
{
	if(PlayerInfo[playerid][pBackpack] > 0)
	{
		if(dr_iPlayerTimeStamp[playerid] > gettime() - 60) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da bi thuong trong phut vua qua");
		if(!IsBackpackAvailable(playerid)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Hien ban khong the dung ba lo.");
			return 1;
		}
		new string[122];
		if(GetPVarInt(playerid, "BackpackDisabled") > 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban vua bi thuong khi dung menu ba lo, ba lo bi khoa %d giay", GetPVarInt(playerid, "BackpackDisabled"));
			return 1;
		}
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, false, false, false, false, 0, 1);
		format(string, sizeof(string), "{FF8000}** {C2A2DA}%s dat ba lo xuong va mo ra.", GetPlayerNameEx(playerid));
		SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 15.0, 5000);
		// ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SetPVarInt(playerid, "BackpackProt", 1);
		SetPVarInt(playerid, "BackpackOpen", 1);

		ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "");
	}
	return 1;
}

CMD:backpackhelp(playerid, params[])
{
	SetPVarInt(playerid, "HelpResultCat0", 2);
	Help_ListCat(playerid, DIALOG_HELPCATOTHER1);
	return 1;
}

CMD:obackpackhelp(playerid, params[]) {

	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "Vat pham: Small Backpack\nThuc an: 1 Suat\nMa tuy: 40 Gram\nVu khi: 2 Khau(Chi sung ngan)\nGia: {FFD700}%s{A9C4E4}\n\n", number_format(ShopItems[36][sItemPrice]));
	format(szMiscArray, sizeof(szMiscArray), "%sVat pham: Medium Backpack\nThuc an: 4 Suat\nMa tuy: 100 Gram\nVu khi: 3 Khau(2 Sung ngan va 1 Sung chinh)\nGia: {FFD700}%s{A9C4E4}\n\n", szMiscArray, number_format(ShopItems[37][sItemPrice]));
	format(szMiscArray, sizeof(szMiscArray), "%sVat pham: Large Backpack\nThuc an: 5 Suat\nMa tuy: 250 Gram\nVu khi: 5 Khau(2 Sung ngan va 3 Sung chinh)\nGia: {FFD700}%s{A9C4E4}\n\n\n", szMiscArray, number_format(ShopItems[38][sItemPrice]));
	format(szMiscArray, sizeof(szMiscArray), "%sLenh: /bstore /bwear /bopen /sellbackpack /drop backpack (/miscshop de mua bang credits)", szMiscArray);

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Thong tin ba lo", szMiscArray, "Thoat", "");
    return 1;
}
