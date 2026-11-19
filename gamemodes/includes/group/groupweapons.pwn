/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Group Weapons Handler (Locker)

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

new LockerReq[MAX_PLAYERS][4];

hook OnPlayerConnect(playerid) {
	LockerReq[playerid][0] = 0; // Gun ID
	LockerReq[playerid][1] = -1; // Slot
	LockerReq[playerid][2] = gettime(); // Time of request
	LockerReq[playerid][3] = INVALID_GROUP_ID;
	return 1;
}

stock CanUseGroupWeaponLocker(playerid) {
	new group = PlayerInfo[playerid][pMember];
	if(!gPlayerLogged{playerid} || !ValidGroup(group) || !GetPVarType(playerid, "WeaponLockerGroup")
		|| GetPVarInt(playerid, "WeaponLockerGroup") != group) return 0;
	if(PlayerInfo[playerid][pAccountRestricted] || PlayerInfo[playerid][pWRestricted] || PlayerInfo[playerid][pConnectHours] < 2
		|| PlayerBusy(playerid) || PlayerInfo[playerid][pJailTime] || PlayerCuffed[playerid] || PlayerTied[playerid]
		|| HungerPlayerInfo[playerid][hgInEvent] || (zombieevent && GetPVarType(playerid, "pIsZombie"))) return 0;
	for(new i; i < MAX_GROUPS; ++i) {
		if(i != group && arrGroupData[i][g_iGroupType] != arrGroupData[group][g_iGroupType]) continue;
		for(new j; j < MAX_GROUP_LOCKERS; ++j) {
			if(i != group && !arrGroupLockers[i][j][g_iLockerShare]) continue;
			if(arrGroupLockers[i][j][g_fLockerPos][0] == 0.0 && arrGroupLockers[i][j][g_fLockerPos][1] == 0.0
				&& arrGroupLockers[i][j][g_fLockerPos][2] == 0.0) continue;
			if(arrGroupLockers[i][j][g_iLockerVW] == GetPlayerVirtualWorld(playerid)
				&& IsPlayerInRangeOfPoint(playerid, 3.0, arrGroupLockers[i][j][g_fLockerPos][0], arrGroupLockers[i][j][g_fLockerPos][1], arrGroupLockers[i][j][g_fLockerPos][2])) return 1;
		}
	}
	return 0;
}

stock ShowGroupWeapons(playerid, group) {
	if(!ValidGroup(group) || group != PlayerInfo[playerid][pMember]) return 1;
	SetPVarInt(playerid, "WeaponLockerGroup", group);
	new title[54];
	format(title, sizeof(title), "Weapon Safe - Mats: %s", number_format(arrGroupData[group][g_iLockerStock]));
	new dialogInfo[] = "Withdraw Weapon\nDeposit Weapon";
	Dialog_Show(playerid, wep_option, DIALOG_STYLE_LIST, title, dialogInfo, "Select", "Go Back");
	return 1;
}

stock WeaponMenu(playerid, group, crate = 0) {
	szMiscArray[0] = 0;
	new title[54];
	if(!ValidGroup(group) || group != PlayerInfo[playerid][pMember]) return 1;
	SetPVarInt(playerid, "WeaponLockerGroup", group);
	format(title, sizeof(title), "Safe Weapon Withdraw - Mats: %s", number_format(arrGroupData[group][g_iLockerStock]));
	format(szMiscArray, sizeof(szMiscArray), "Weapon\tCost");
	for(new i = 0; i != MAX_GROUP_WEAPONS; ++i) {
		if(arrGroupData[group][g_iLockerGuns][i]) {
			format(szMiscArray, sizeof szMiscArray, "%s\n%s\t%d", szMiscArray, Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][i]), arrGroupData[group][g_iLockerCost][i]);
		}
		else strcat(szMiscArray, "\nEmpty\t--");
	}
	if(crate) {
		Dialog_Show(playerid, crate_withdraw, DIALOG_STYLE_TABLIST_HEADERS, "Transfer to Crate", szMiscArray, "Select", "Go Back");
	} else {
		Dialog_Show(playerid, weapon_withdraw, DIALOG_STYLE_TABLIST_HEADERS, title, szMiscArray, "Select", "Go Back");
	}
	return 1;
}

stock DepositMenu(playerid, group) {
	szMiscArray[0] = 0;
	if(!ValidGroup(group) || group != PlayerInfo[playerid][pMember]) return 1;
	SetPVarInt(playerid, "WeaponLockerGroup", group);
	for(new g = 0; g < 12; g++)	{
		if(PlayerInfo[playerid][pGuns][g] != 0 && PlayerInfo[playerid][pAGuns][g] == 0) {
			if(CanDeposit(PlayerInfo[playerid][pGuns][g])) {
				format(szMiscArray, sizeof(szMiscArray), "%s%s(%i) %s", szMiscArray, szMiscArray[0] ? ("\n") : (""), PlayerInfo[playerid][pGuns][g], Weapon_ReturnName(PlayerInfo[playerid][pGuns][g]));
			}
		}
	}
	if(isnull(szMiscArray)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can only deposit: Spas12, AK-47, M4 & Sniper Rifle."), ShowGroupWeapons(playerid, PlayerInfo[playerid][pMember]);
	return Dialog_Show(playerid, weapon_deposit, DIALOG_STYLE_LIST, "Safe Weapon Deposit", szMiscArray, "Deposit", "Go Back");
}

Dialog:wep_option(playerid, response, listitem, inputtext[]) {
	if(!ValidGroup(PlayerInfo[playerid][pMember])) return 1;
	if(response) {
		switch(listitem) {
			case 0: {
				//if(PlayerInfo[playerid][pRank] < arrGroupData[PlayerInfo[playerid][pMember]][g_iWithdrawRank][3]) return SendClientMessageEx(playerid, COLOR_WHITE, "You are not authorized to withdraw weapons from the locker!"), ShowGroupWeapons(playerid, PlayerInfo[playerid][pMember]);
				WeaponMenu(playerid, PlayerInfo[playerid][pMember]);
			}
			case 1: {
				DepositMenu(playerid, PlayerInfo[playerid][pMember]);
			}
		}
	} else {
		return pc_cmd_locker(playerid, "");
	}
	return 1;
}

Dialog:weapon_withdraw(playerid, response, listitem, inputtext[]) {
	if(!ValidGroup(PlayerInfo[playerid][pMember])) return 1;
	new group = PlayerInfo[playerid][pMember];
	if(response) {
		szMiscArray[0] = 0;
		if(!CanUseGroupWeaponLocker(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this weapon locker at this time.");
		if(!(0 <= listitem < MAX_GROUP_WEAPONS)) return 1;
		new GunID = arrGroupData[group][g_iLockerGuns][listitem];

		if(GetLoadoutWeaponSlot(GunID) < 0 || !GunID) return SendClientMessageEx(playerid, COLOR_WHITE, "Theres no weapon assigned to that slot!"), WeaponMenu(playerid, PlayerInfo[playerid][pMember]);
		if(arrGroupData[group][g_iLockerCost][listitem] < 0) return SendClientMessageEx(playerid, COLOR_RED, "This weapon has an invalid locker cost.");
		if(PlayerInfo[playerid][pRank] < LockerWep[group][lwRank][listitem]) {
			if(LockerReq[playerid][2] > gettime()) return SendClientMessageEx(playerid, COLOR_YELLOW, "A request was already sent please wait %d seconds before trying again!", LockerReq[playerid][2]-gettime()), WeaponMenu(playerid, PlayerInfo[playerid][pMember]);
			SendClientMessageEx(playerid, COLOR_WHITE, "You are not authorized to withdraw a %s from the locker! (Requires rank %d+)", Weapon_ReturnName(GunID), LockerWep[group][lwRank][listitem]);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* A request was sent to the leaders who may grant you access. - Ensure you don't move away from the locker!");
			LockerReq[playerid][0] = GunID;
			LockerReq[playerid][1] = listitem;
			LockerReq[playerid][2] = gettime()+60;
			LockerReq[playerid][3] = group;
			foreach(new p: Player) {
				if(PlayerInfo[p][pLeader] == PlayerInfo[playerid][pMember]) {
					SendClientMessageEx(p, COLOR_YELLOW, "* %s is requesting to withdraw a %s from the locker. (( /allow %d ))", GetPlayerNameEx(playerid), Weapon_ReturnName(GunID), playerid);
				}
			}
			return 1;
		}
		if(arrGroupData[group][g_iLockerStock] < arrGroupData[group][g_iLockerCost][listitem]) return SendClientMessageEx(playerid, COLOR_RED, "Your locker doesn't have the materials to craft a %s.", Weapon_ReturnName(GunID));
		if(PlayerInfo[playerid][pGuns][GetLoadoutWeaponSlot(GunID)] != GunID) {
			arrGroupData[group][g_iLockerStock] -= arrGroupData[group][g_iLockerCost][listitem];
			GivePlayerValidWeapon(playerid, GunID);
			SaveGroup(group);
			LockerReq[playerid][0] = 0;
			LockerReq[playerid][1] = -1;
			SendClientMessageEx(playerid, COLOR_WHITE, "You withdraw a %s from the locker.", Weapon_ReturnName(GunID));
			format(szMiscArray, sizeof(szMiscArray), "%s has withdrawn a %s from the weapon locker (Cost: %d)", GetPlayerNameEx(playerid), Weapon_ReturnName(GunID), arrGroupData[group][g_iLockerCost][listitem]);
			GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
			return WeaponMenu(playerid, PlayerInfo[playerid][pMember]);
		} else {
			SendClientMessageEx(playerid, COLOR_RED, "You already have a %s on you!", Weapon_ReturnName(GunID));
			return WeaponMenu(playerid, PlayerInfo[playerid][pMember]);
		}
	} else {
		ShowGroupWeapons(playerid, PlayerInfo[playerid][pMember]);
	}
	return 1;
}

Dialog:weapon_deposit(playerid, response, listitem, inputtext[]) {
	if(response) {
		szMiscArray[0] = 0;
		if(!ValidGroup(PlayerInfo[playerid][pMember])) return 1;
		if(!CanUseGroupWeaponLocker(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this weapon locker at this time.");
		new fpos = strfind(inputtext, ")"), gid[3], id, slot;
		if(inputtext[0] != '(' || fpos < 2 || fpos > 3) return 1;
		strmid(gid, inputtext, 1, fpos, sizeof(gid));
		if(!IsNumericString(gid)) return 1;
		id = strval(gid);
		if(!CanDeposit(id)) return SendClientMessageEx(playerid, COLOR_RED, "You can't deposit that weapon!");
		new weaponSlot = GetLoadoutWeaponSlot(id);
		if(PlayerInfo[playerid][pGuns][weaponSlot] != id || PlayerInfo[playerid][pAGuns][weaponSlot] != 0)
			return SendClientMessageEx(playerid, COLOR_RED, "The weapon you tried to deposit doesn't exist!");
	    IsInSlot(PlayerInfo[playerid][pMember], id, slot);
	    if(slot == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Your locker doesn't have that weapon so it can't be stored!"), DepositMenu(playerid, PlayerInfo[playerid][pMember]);
		new cost = arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerCost][slot];
		if(cost < 0 || arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerStock] > cellmax - cost)
			return SendClientMessageEx(playerid, COLOR_RED, "The locker cannot accept these materials.");
		PlayerInfo[playerid][pGuns][weaponSlot] = 0;
		SetPlayerWeaponsEx(playerid);
		SendClientMessageEx(playerid, COLOR_WHITE, "You have deposited a %s into the locker.", Weapon_ReturnName(id));
		format(szMiscArray, sizeof(szMiscArray), "%s has deposited a %s into the locker.", GetPlayerNameEx(playerid), Weapon_ReturnName(id));
		GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
		arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerStock] += cost;
		SaveGroup(PlayerInfo[playerid][pMember]);
		DepositMenu(playerid, PlayerInfo[playerid][pMember]);
	} else {
		ShowGroupWeapons(playerid, PlayerInfo[playerid][pMember]);
	}
	return 1;
}

stock SaveLockerRanks(i) {
	if(!ValidGroup(i)) return 0;
	new query[2048], wep[12];
	format(query, 2048, "UPDATE `locker_restrict` SET ");
	for(new w = 0; w < 16; w++) {
		format(wep, sizeof(wep), "%d", w+1);
		SaveInteger(query, "locker_restrict", i+1, wep, LockerWep[i][lwRank][w]);
	}
	SQLUpdateFinish(query, "locker_restrict", i+1);
	return 1;
}

stock SaveWeapons(i) {
	if(!ValidGroup(i)) return 0;
	new query[2048], wep[12];
	format(query, 2048, "UPDATE `gweaponsnew` SET ");
	for(new w = 0; w < 46; w++) {
		if(18 <= w <= 20) continue;
		format(wep, sizeof(wep), "%d", w+1);
		SaveInteger(query, "gweaponsnew", i+1, wep, LockerWep[i][lwWep][w]);
	}
	SQLUpdateFinish(query, "gweaponsnew", i+1);
	return 1;
}

stock CrateTransferOption(playerid, group) {
	if(!ValidGroup(group) || group != PlayerInfo[playerid][pMember]) return 1;
	SetPVarInt(playerid, "WeaponLockerGroup", group);
	if(!CanUseGroupWeaponLocker(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this weapon locker at this time.");
	if(PlayerInfo[playerid][pLeader] == group) {
		new dialogInfo[] = "Deploy Crate Box\nTransfer to Crate\nDeposit Crate\nRecall Crate";
		Dialog_Show(playerid, crate_tran_option, DIALOG_STYLE_LIST, "Crate Transfer", dialogInfo, "Select", "Go Back");
	} else {
		new dialogInfo[] = "Deposit Crate";
		Dialog_Show(playerid, crate_tran_option, DIALOG_STYLE_LIST, "Crate Transfer", dialogInfo, "Select", "Go Back");
	}
	return 1;
}

Dialog:crate_tran_option(playerid, response, listitem, inputtext[]) {
	if(!CanUseGroupWeaponLocker(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this weapon locker at this time.");
	if(response) {
		if(!ValidGroup(PlayerInfo[playerid][pMember])) return 1;
		szMiscArray[0] = 0;
		new gbox;
		GetGroupCrate(playerid, gbox);
		if(PlayerInfo[playerid][pLeader] == PlayerInfo[playerid][pMember]) {
			switch(listitem) {
				case 0: {
					if(gbox == -1) {
						szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
						strcat(szMiscArray, "{F69500}WARNING: Are you sure you want to deply a transfer crate?{FFFFFF}\n\n");
						strcat(szMiscArray, "Deploying a transfer crate will allow you to sell weapons to another group\n\n");
						strcat(szMiscArray, "You must be careful with the crate as anyone is able to steal it from you and dump the contents into their locker - Only leaders can deploy a transfer crate.\n");
						strcat(szMiscArray, "Anyone within the group has the ability to deposit any crate they come across or mange to steal from another group into your own group locker.\n\n");
						strcat(szMiscArray, "There is no time limit for when the crate will despawn, you must wait 24 hours before you can 'recall' it so be careful with the crate.\n");
						strcat(szMiscArray, "The only time the crate will despawned if it's been deposited into any locker or you recall it.\n\n");
						strcat(szMiscArray, "Note: You can recall the crate after 24 hours if you've lost it but all contents of the crate will be lost!\n\n");
						strcat(szMiscArray, "{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
						Dialog_Show(playerid, deploy_transfer_crate, DIALOG_STYLE_MSGBOX, "Deploy Transfer Crate?", szMiscArray, "Deploy", "Go Back");
					} else {
						SendClientMessageEx(playerid, COLOR_YELLOW, "There is already a transfer crate in use find it or wait until you can recall it.");
						return CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
					}
				}
				case 1: {
					if(CarryCrate[playerid] == -1) return SendClientMessageEx(playerid, COLOR_RED, "Your not carrying a group crate!"), CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
					if(CarryCrate[playerid] != gbox) return SendClientMessageEx(playerid, COLOR_RED, "You can't transfer items to a crate not owned by your group!"), CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
					return WeaponMenu(playerid, PlayerInfo[playerid][pMember], 1);
				}
				case 2: { // Deposit Crate
					if(CarryCrate[playerid] == -1) return SendClientMessageEx(playerid, COLOR_RED, "You need to be holding a crate to deposit!"), CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
					return DepositCrateContents(playerid, CarryCrate[playerid]);
				}
				case 3: {
					if(gbox == -1) return SendClientMessageEx(playerid, COLOR_YELLOW, "SMS: There was no response from the signal. (( No active crate )), Sender: MOLE (555)");
					if(CrateBox[gbox][cbLifespan] > gettime()) return SendClientMessageEx(playerid, COLOR_YELLOW, "SMS: Signal will be active after %s, Sender: MOLE (555)", date(CrateBox[gbox][cbLifespan], 1));
					strcat(szMiscArray, "{F69500}WARNING: Are you sure you want to recall your group crate?{FFFFFF}\n\n");
					strcat(szMiscArray, "By recalling the crate it will be destroyed along with all of it's contents!\n");
					SetPVarInt(playerid, "RecallCrate", gbox);
					SetPVarInt(playerid, "RecallCrateGeneration", CrateGeneration[gbox]);
					Dialog_Show(playerid, recall_box_check, DIALOG_STYLE_MSGBOX, "Recall Crate?", szMiscArray, "Recall", "Cancel");
				}
			}
		} else {
			switch(listitem) {
				case 0: {
					if(CarryCrate[playerid] == -1) return SendClientMessageEx(playerid, COLOR_RED, "You need to be holding a crate to deposit!"), CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
					return DepositCrateContents(playerid, CarryCrate[playerid]);
				}
			}
		}
	} else {
		return pc_cmd_locker(playerid, "");
	}
	return 1;
}

Dialog:recall_box_check(playerid, response, listitem, inputtext[]) {
	new box = GetPVarInt(playerid, "RecallCrate"), generation = GetPVarInt(playerid, "RecallCrateGeneration");
	new bool:pending = GetPVarType(playerid, "RecallCrate") != 0;
	DeletePVar(playerid, "RecallCrate");
	DeletePVar(playerid, "RecallCrateGeneration");
	if(!CanUseGroupWeaponLocker(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this weapon locker at this time.");
	if(response) {
		if(!pending || !IsGroupLeader(playerid)) return 1;
		if(!IsValidCrate(box) || !CrateBox[box][cbActive] || CrateBox[box][cbGroup] != PlayerInfo[playerid][pMember] || CrateGeneration[box] != generation) return SendClientMessageEx(playerid, COLOR_GREY, "The group crate has changed. Open the crate menu again.");
		if(CrateBox[box][cbLifespan] > gettime()) return SendClientMessageEx(playerid, COLOR_YELLOW, "You can recall this crate after %s.", date(CrateBox[box][cbLifespan], 1));
		DestroyCrate(box);
		SendClientMessageEx(playerid, COLOR_YELLOW, "You have recalled your group crate, all contents were removed.");
	}
	return CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
}

Dialog:deploy_transfer_crate(playerid, response, listitem, inputtext[]) {
	if(!CanUseGroupWeaponLocker(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this weapon locker at this time.");
	
	if(response) {
		szMiscArray[0] = 0;
		if(!IsGroupLeader(playerid)) 
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Only group leaders can deploy a transfer crate.");
		
		if(CrateAction[playerid][caTimer]) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Please finish your current crate action first.");
		
		new box;
		GetGroupCrate(playerid, box);
		if(box != -1) return SendClientMessageEx(playerid, COLOR_YELLOW, "Your group already has an active transfer crate.");
		new Float: pcbPos[3];
		if(CarryCrate[playerid] != -1) return SendClientMessageEx(playerid, COLOR_RED, "Your carrying a crate put it down before deploying a transfer crate!"), CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
		GetPlayerPos(playerid, pcbPos[0], pcbPos[1], pcbPos[2]);
		GetXYInFrontOfPlayer(playerid, pcbPos[0], pcbPos[1], 1);
		for(new c = 0; c < MAX_CRATES; c++) {
			if(!CrateBox[c][cbActive] && CrateBox[c][cbFacility] == -1 && CrateBox[c][cbGroup] == -1) {
				CrateBox[c][cbGroup] = PlayerInfo[playerid][pMember];
				CrateBox[c][cbPos][0] = pcbPos[0];
				CrateBox[c][cbPos][1] = pcbPos[1];
				CrateBox[c][cbPos][2] = pcbPos[2]-1.0;
				CrateBox[c][cbInt] = GetPlayerInterior(playerid);
				CrateBox[c][cbVw] = GetPlayerVirtualWorld(playerid);
				CrateBox[c][cbPlacedBy] = GetPlayerNameEx(playerid);
				if(PlayerHoldingObject[playerid][8] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 8))
					RemovePlayerAttachedObject(playerid, 8), PlayerHoldingObject[playerid][8] = 0;
				SetPlayerAttachedObject(playerid, 8, 964, 1, -0.071, 0.536, -0.026999, -2.19999, 87.1999, 0.699999, 0.479999, 0.538999, 0.419999);
				if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_CARRY) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
				CarryCrate[playerid] = c;
				BeingMoved[c] = playerid;
				CrateBox[c][cbLifespan] = gettime()+86400; // 24 hours.
				CrateBox[c][cbActive] = 1;
				SaveCrate(c);
				UpdateCrateBox(c);
				SendClientMessageEx(playerid, COLOR_YELLOW, "You take out a transfer crate from the locker!");
				Streamer_Update(playerid);
				return CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
			}
		}
		SendClientMessageEx(playerid, COLOR_RED, "No free crate slots are available.");
	} else {
		CrateTransferOption(playerid, PlayerInfo[playerid][pMember]);
	}
	return 1;
}

Dialog:crate_withdraw(playerid, response, listitem, inputtext[]) {
	if(!ValidGroup(PlayerInfo[playerid][pMember])) return 1;
	szMiscArray[0] = 0;
	if(response) {
		new group = PlayerInfo[playerid][pMember];
		if(!CanUseGroupWeaponLocker(playerid) || PlayerInfo[playerid][pLeader] != group) return 1;
		if(!(0 <= listitem < MAX_GROUP_WEAPONS)) return 1;
		new GunID = arrGroupData[group][g_iLockerGuns][listitem];
		if(arrGroupData[group][g_iLockerCost][listitem] < 0) return 1;

		if(!GunID) return SendClientMessageEx(playerid, COLOR_WHITE, "Theres no weapon assigned to that slot!"), WeaponMenu(playerid, PlayerInfo[playerid][pMember], 1);
		if(PlayerInfo[playerid][pRank] < LockerWep[group][lwRank][listitem]) return SendClientMessageEx(playerid, COLOR_WHITE, "You are not authorized to withdraw a %s from the locker! (Requires rank %d+)", Weapon_ReturnName(GunID), LockerWep[group][lwRank][listitem]), WeaponMenu(playerid, PlayerInfo[playerid][pMember], 1);
		if(!CanTransferToCrate(GunID)) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't transfer that item to the crate!"), WeaponMenu(playerid, PlayerInfo[playerid][pMember], 1);
		if(arrGroupData[group][g_iLockerStock] < arrGroupData[group][g_iLockerCost][listitem]) return SendClientMessageEx(playerid, COLOR_RED, "Your locker doesn't have the materials to craft a %s.", Weapon_ReturnName(GunID)), WeaponMenu(playerid, PlayerInfo[playerid][pMember], 1);

		new box = CarryCrate[playerid];
		if(!IsValidCrate(box) || !CrateBox[box][cbActive] || CrateBox[box][cbGroup] != group || BeingMoved[box] != playerid) return SendClientMessageEx(playerid, COLOR_RED, "You must be holding your group's transfer crate.");
		SetPVarInt(playerid, "GunCrateBox", box);
		SetPVarInt(playerid, "GunCrateGeneration", CrateGeneration[box]);
		SetPVarInt(playerid, "GunCrateID", GunID);
		SetPVarInt(playerid, "GunCrateSlot", listitem);
		format(szMiscArray, sizeof(szMiscArray), "Please enter the amount you would like to transfer to the crate.\n\nLocker Stock: %s\nCost Per %s: %s", number_format(arrGroupData[group][g_iLockerStock]), Weapon_ReturnName(GunID), number_format(arrGroupData[group][g_iLockerCost][listitem]));
		Dialog_Show(playerid, crate_tran_amount, DIALOG_STYLE_INPUT, "How many to withdraw?", szMiscArray, "Submit", "Go Back");
	} else {
		CrateTransferOption(playerid, PlayerInfo[playerid][pMember]); 
	}
	return 1;
}

Dialog:crate_tran_amount(playerid, response, listitem, inputtext[]) {
	szMiscArray[0] = 0;
	if(!ValidGroup(PlayerInfo[playerid][pMember])) return 1;
	if(response) {
		new group = PlayerInfo[playerid][pMember], slot = GetPVarInt(playerid, "GunCrateSlot"), gun = GetPVarInt(playerid, "GunCrateID");
		if(!CanUseGroupWeaponLocker(playerid) || PlayerInfo[playerid][pLeader] != group
			|| !GetPVarType(playerid, "GunCrateSlot") || !(0 <= slot < MAX_GROUP_WEAPONS)) return 1;
		if(arrGroupData[group][g_iLockerGuns][slot] != gun || !CanTransferToCrate(gun)
			|| PlayerInfo[playerid][pRank] < LockerWep[group][lwRank][slot]) return 1;
		new gbox = GetPVarInt(playerid, "GunCrateBox"), amount, cost = arrGroupData[group][g_iLockerCost][slot];
		if(CrateAction[playerid][caTimer]) return SendClientMessageEx(playerid, COLOR_GREY, "Please finish your current crate action first.");
		if(cost < 0 || !ParseBankTransferAmount(inputtext, amount)) return SendClientMessageEx(playerid, COLOR_RED, "Enter a valid positive amount.");
		if(!GetPVarType(playerid, "GunCrateBox") || !IsValidCrate(gbox) || !CrateBox[gbox][cbActive]
			|| CarryCrate[playerid] != gbox || BeingMoved[gbox] != playerid || CrateBox[gbox][cbGroup] != group
			|| CrateGeneration[gbox] != GetPVarInt(playerid, "GunCrateGeneration")) return SendClientMessageEx(playerid, COLOR_RED, "You are no longer holding the selected group crate.");
		if(arrGroupData[group][g_iLockerStock] < 0 || (cost > 0 && amount > arrGroupData[group][g_iLockerStock] / cost)) {
			format(szMiscArray, sizeof(szMiscArray), "Please enter the amount you would like to transfer to the crate.\n\nLocker Stock: %s\nCost Per %s: %s\n\n{FF0000}Error: You can't go below 0 or you don't have enough materials.", number_format(arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerStock]), Weapon_ReturnName(GetPVarInt(playerid, "GunCrateID")), number_format(arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerCost][GetPVarInt(playerid, "GunCrateSlot")]));
	    	Dialog_Show(playerid, crate_tran_amount, DIALOG_STYLE_INPUT, "How many to transfer?", szMiscArray, "Submit", "Go Back");
			return 1;
		}
		if(CrateBox[gbox][cbWepAmount][slot] < 0 || CrateBox[gbox][cbWepAmount][slot] > cellmax - amount
			|| (CrateBox[gbox][cbWepAmount][slot] > 0 && CrateBox[gbox][cbWep][slot] != gun))
			return SendClientMessageEx(playerid, COLOR_RED, "The crate cannot accept these weapons.");
		new total = cost * amount;
		CrateBox[gbox][cbWep][slot] = gun;
		CrateBox[gbox][cbWepAmount][slot] += amount;
		arrGroupData[group][g_iLockerStock] -= total;
		SendClientMessageEx(playerid, COLOR_WHITE, "You transferred %s %s(s) to the crate.", number_format(amount), Weapon_ReturnName(GetPVarInt(playerid, "GunCrateID")));
		SaveGroup(PlayerInfo[playerid][pMember]);
		SaveCrate(CarryCrate[playerid]);
		format(szMiscArray, sizeof(szMiscArray), "%s has withdrawn %d %ss from the weapon locker into the transfer crate (Cost: %d)", GetPlayerNameEx(playerid), amount, Weapon_ReturnName(GetPVarInt(playerid, "GunCrateID")), total);
		GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
		DeletePVar(playerid, "GunCrateID");
		DeletePVar(playerid, "GunCrateSlot");
		DeletePVar(playerid, "GunCrateBox");
		DeletePVar(playerid, "GunCrateGeneration");
		WeaponMenu(playerid, PlayerInfo[playerid][pMember], 1);
	} else {
		DeletePVar(playerid, "GunCrateID");
		DeletePVar(playerid, "GunCrateSlot");
		DeletePVar(playerid, "GunCrateBox");
		DeletePVar(playerid, "GunCrateGeneration");
		WeaponMenu(playerid, PlayerInfo[playerid][pMember], 1);
	}
	return 1;
}

stock DepositCrateContents(playerid, boxid) {
	if(!CanUseGroupWeaponLocker(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this weapon locker at this time.");
	
	if(!IsValidCrate(boxid) || !CrateBox[boxid][cbActive] || CarryCrate[playerid] != boxid || BeingMoved[boxid] != playerid) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You must be holding the crate to deposit it.");
	
	if(CrateAction[playerid][caTimer]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Please finish your current crate action first.");
	
	new group = PlayerInfo[playerid][pMember], materials, remaining;
	if(arrGroupData[group][g_iLockerStock] < 0) 
		return SendClientMessageEx(playerid, COLOR_RED, "The locker material stock is invalid.");
	
	if(CrateBox[boxid][cbGroup] != -1) {
		new slots[MAX_GROUP_WEAPONS], accepted;
		for(new c; c < MAX_GROUP_WEAPONS; ++c) {
			slots[c] = -1;
			new gun = CrateBox[boxid][cbWep][c], amount = CrateBox[boxid][cbWepAmount][c];
			if(amount < 0 || (amount > 0 && !CanTransferToCrate(gun))) return SendClientMessageEx(playerid, COLOR_RED, "The crate contains an invalid weapon amount or type.");
			if(!amount) continue;
			IsInSlot(group, gun, slots[c]);
			if(slots[c] == -1) {
				++remaining;
				continue;
			}
			new cost = arrGroupData[group][g_iLockerCost][slots[c]];
			if(cost < 0 || (cost > 0 && amount > (cellmax - materials) / cost)) return SendClientMessageEx(playerid, COLOR_RED, "The crate material value is invalid or too large.");
			materials += amount * cost;
			++accepted;
		}
		if(!accepted) return SendClientMessageEx(playerid, COLOR_GREY, "This locker does not accept any of the weapons in this crate.");
		if(arrGroupData[group][g_iLockerStock] > cellmax - materials) return SendClientMessageEx(playerid, COLOR_RED, "The locker cannot accept these materials.");
		for(new c; c < MAX_GROUP_WEAPONS; ++c) {
			if(slots[c] == -1) continue;
			CrateBox[boxid][cbWep][c] = 0;
			CrateBox[boxid][cbWepAmount][c] = 0;
		}
	} else {
		new facility = CrateBox[boxid][cbFacility];
		if(!(0 <= facility < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_GREY, "This crate has no valid source facility.");
		if(CrateFacility[facility][cfGroup] == group && !CrateBox[boxid][cbPaid]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot deposit an unpaid crate from your own facility. Use /ordercrates to buy locker stock.");
		new multiplier = CrateFacility[facility][cfProdMulti];
		if(multiplier < 1 || CrateBox[boxid][cbMats] < 0 || CrateBox[boxid][cbMats] > cellmax / multiplier) return SendClientMessageEx(playerid, COLOR_RED, "The crate material amount is invalid.");
		materials = CrateBox[boxid][cbMats] * multiplier;
		if(arrGroupData[group][g_iLockerStock] > cellmax - materials) return SendClientMessageEx(playerid, COLOR_RED, "The locker cannot accept these materials.");
	}
	arrGroupData[group][g_iLockerStock] += materials;
	SaveGroup(group);
	if(remaining) {
		SaveCrate(boxid);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Deposited %s materials. Weapons not accepted by this locker remain in the crate.", number_format(materials));
	} else DestroyCrate(boxid);
	format(szMiscArray, sizeof(szMiscArray), "%s deposited crate contents into the weapon locker (Materials: %d).", GetPlayerNameEx(playerid), materials);
	GroupLog(group, szMiscArray);
	format(szMiscArray, sizeof(szMiscArray), "* %s has unloaded the accepted contents of the crate into the locker.", GetPlayerNameEx(playerid));
	ProxDetector(25.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	return 1;
}

stock CanTransferToCrate(WepID) {
	switch(WepID) {
		case 1: return 1; // Brass Knuckle
		case 2: return 1; // Golf Club
		case 3: return 1; // Nitestick
		case 5: return 1; // Bat
		case 6: return 1; // Shovel
		case 7: return 1; // Pool Cue
		case 8: return 1; // Katana Sword
		case 10: return 1; // Dildo (Purple)
		case 11: return 1; // Dildo
		case 12: return 1; // Vibrator
		case 13: return 1; // Silver Vibrator
		case 14: return 1; // Flower
		case 15: return 1; // Cane
		case 17: return 1; // Tear Gas
		case 22: return 1; // 9MM
		case 23: return 1; // Silenced 9mm
		case 24: return 1; // Desert Eagle
		case 25: return 1; // Pump Shotgun
		case 26: return 1; // Sawnoff Shotgun
		case 27: return 1; // Combat Shotgun
		case 28: return 1; // Micro SMG
		case 29: return 1; // MP5
		case 30: return 1; // AK-47
		case 31: return 1; // M4
		case 32: return 1; // Tec9
		case 33: return 1; // Rifle
		case 34: return 1; // Sniper Rifle
		case 46: return 1; // Parachute
		default: return 0;
	}
	return 0;
}

stock CanDeposit(WepID) {
	switch(WepID) {
		case 27: return 1; // Combat Shotgun
		case 30: return 1; // AK-47
		case 31: return 1; // M4
		case 34: return 1; // Sniper Rifle
		default: return 0;
	}
	return 0;
}

CMD:editweprank(playerid, params[]) {
	if(!IsGroupLeader(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Only group leaders can use this command!");
	WeaponRankList(playerid);
	return 1;
}

stock WeaponRankList(playerid) {
	szMiscArray[0] = 0;
	if(!IsGroupLeader(playerid)) return 1;

	new group = PlayerInfo[playerid][pMember];

	format(szMiscArray, sizeof(szMiscArray), "Weapon\tRank");
	for(new i = 0; i != MAX_GROUP_WEAPONS; ++i) {
		if(arrGroupData[group][g_iLockerGuns][i]) {
			format(szMiscArray, sizeof szMiscArray, "%s\n%s\t%d", szMiscArray, Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][i]), LockerWep[group][lwRank][i]);
		}
		else strcat(szMiscArray, "\nEmpty\t--");
	}
	Dialog_Show(playerid, wep_restrict, DIALOG_STYLE_TABLIST_HEADERS, "Weapon Restriction", szMiscArray, "Select", "Close");
	return 1;
}

Dialog:wep_restrict(playerid, response, listitem, inputtext[]) {
	szMiscArray[0] = 0;
	if(!IsGroupLeader(playerid)) return 1;
	new group = PlayerInfo[playerid][pMember];
	if(response) {
		if(!(0 <= listitem < MAX_GROUP_WEAPONS)) return 1;
		if(!arrGroupData[group][g_iLockerGuns][listitem]) return SendClientMessageEx(playerid, COLOR_GRAD1, "The selected slot is currently empty!"), WeaponRankList(playerid);
		SetPVarInt(playerid, "RGunID", listitem);
		SetPVarInt(playerid, "RGunGroup", group);
		SetPVarInt(playerid, "RGunWeapon", arrGroupData[group][g_iLockerGuns][listitem]);
		format(szMiscArray, sizeof(szMiscArray), "Please specify what rank & above can access the %s.\n\nCurrent Rank: %d+", Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][listitem]), LockerWep[group][lwRank][listitem]);
		Dialog_Show(playerid, set_weprank, DIALOG_STYLE_INPUT, "Restrict Weapon Withdraw", szMiscArray, "Ok", "Go Back");
	}
	return 1;
}

Dialog:set_weprank(playerid, response, listitem, inputtext[]) {
	szMiscArray[0] = 0;
	if(!IsGroupLeader(playerid)) return 1;
	new group = PlayerInfo[playerid][pMember];
	if(response) {
		if(!GetPVarType(playerid, "RGunID") || !(0 <= GetPVarInt(playerid, "RGunID") < MAX_GROUP_WEAPONS) || GetPVarInt(playerid, "RGunGroup") != group) return 1;
		if(!arrGroupData[group][g_iLockerGuns][GetPVarInt(playerid, "RGunID")] || arrGroupData[group][g_iLockerGuns][GetPVarInt(playerid, "RGunID")] != GetPVarInt(playerid, "RGunWeapon")) return SendClientMessageEx(playerid, COLOR_GREY, "The weapon slot changed. Open the restriction menu again.");
		if(isnull(inputtext)) {
			format(szMiscArray, sizeof(szMiscArray), "Please specify what rank & above can access the %s.\n\nCurrent Rank: %d+\n\n{FF0000}ERROR: You must specify a rank number!", Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][GetPVarInt(playerid, "RGunID")]), LockerWep[group][lwRank][GetPVarInt(playerid, "RGunID")], MAX_GROUP_RANKS-1);
			Dialog_Show(playerid, set_weprank, DIALOG_STYLE_INPUT, "Restrict Weapon Withdraw", szMiscArray, "Ok", "Go Back");
			return 1;
		}
		if(!IsNumericString(inputtext)) {
			format(szMiscArray, sizeof(szMiscArray), "Please specify what rank & above can access the %s.\n\nCurrent Rank: %d+\n\n{FF0000}ERROR: You can only use numeric values.", Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][GetPVarInt(playerid, "RGunID")]), LockerWep[group][lwRank][GetPVarInt(playerid, "RGunID")], MAX_GROUP_RANKS-1);
			Dialog_Show(playerid, set_weprank, DIALOG_STYLE_INPUT, "Restrict Weapon Withdraw", szMiscArray, "Ok", "Go Back");
			return 1;
		}
		if(strlen(inputtext) > 2 || !(0 <= strval(inputtext) < MAX_GROUP_RANKS)) {
			format(szMiscArray, sizeof(szMiscArray), "Please specify what rank & above can access the %s.\n\nCurrent Rank: %d+\n\n{FF0000}ERROR: Invalid rank ID (0 - %d only!)", Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][GetPVarInt(playerid, "RGunID")]), LockerWep[group][lwRank][GetPVarInt(playerid, "RGunID")], MAX_GROUP_RANKS-1);
			Dialog_Show(playerid, set_weprank, DIALOG_STYLE_INPUT, "Restrict Weapon Withdraw", szMiscArray, "Ok", "Go Back");
			return 1;
		}
		format(szMiscArray, sizeof(szMiscArray), "%s has set %s weapon restriction from rank %d+ to %d.", GetPlayerNameEx(playerid), Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][GetPVarInt(playerid, "RGunID")]), LockerWep[group][lwRank][GetPVarInt(playerid, "RGunID")], strval(inputtext));
		GroupLog(group, szMiscArray);
		LockerWep[group][lwRank][GetPVarInt(playerid, "RGunID")] = strval(inputtext);
		SendClientMessageEx(playerid, COLOR_YELLOW, "You have set the %s weapon restriction to %d+ only.", Weapon_ReturnName(arrGroupData[group][g_iLockerGuns][GetPVarInt(playerid, "RGunID")]), strval(inputtext));
		SaveLockerRanks(group);
		DeletePVar(playerid, "RGunID");
		DeletePVar(playerid, "RGunGroup");
		DeletePVar(playerid, "RGunWeapon");
		WeaponRankList(playerid);
	} else {
		DeletePVar(playerid, "RGunID");
		DeletePVar(playerid, "RGunGroup");
		DeletePVar(playerid, "RGunWeapon");
		WeaponRankList(playerid);
	}
	return 1;
}

stock IsInSlot(group, id, &wep)
{
	wep = -1;
	if(ValidGroup(group)) {
		for(new i = 0; i != MAX_GROUP_WEAPONS; i++) {
			if(arrGroupData[group][g_iLockerGuns][i] == id) {
				wep = i; // Slot ID.
				break;
			}
		}
	}
}

CMD:allow(playerid, params[]) {
	new target;
	if(!IsGroupLeader(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Only group leaders can use this command!");
	if(sscanf(params, "u", target)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /allow [player]");
	if(target < 0 || target >= MAX_PLAYERS || !IsPlayerConnected(target)) return SendClientMessageEx(playerid, COLOR_GRAD2, "The player selected isn't connected!");
	if(PlayerInfo[playerid][pMember] != PlayerInfo[target][pMember]) return SendClientMessageEx(playerid, COLOR_GRAD2, "%s isn't apart of your group!", GetPlayerNameEx(target));
	if(playerid == target) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can't use this weapon on yourself!");
	if(!LockerReq[target][0]) return SendClientMessageEx(playerid, COLOR_GRAD2, "%s hasn't requested to withdraw a weapon!", GetPlayerNameEx(target));
	if(LockerReq[target][2] <= gettime()) return SendClientMessageEx(playerid, COLOR_GRAD2, "%s's request either expired or one wasn't made!", GetPlayerNameEx(target));
	new group = PlayerInfo[target][pMember], slot = LockerReq[target][1], gun = LockerReq[target][0];
	if(LockerReq[target][3] != group || !(0 <= slot < MAX_GROUP_WEAPONS)
		|| arrGroupData[group][g_iLockerGuns][slot] != gun || GetLoadoutWeaponSlot(gun) < 0) {
		LockerReq[target][0] = 0;
		LockerReq[target][1] = -1;
		return SendClientMessageEx(playerid, COLOR_GRAD2, "The weapon request changed. Ask the player to request it again.");
	}
	if(!CanUseGroupWeaponLocker(target)) return SendClientMessageEx(playerid, COLOR_GRAD1, "The player cannot use the weapon locker at this time.");
	if(arrGroupData[group][g_iLockerCost][slot] < 0) return SendClientMessageEx(playerid, COLOR_RED, "This weapon has an invalid locker cost.");
	if(arrGroupData[PlayerInfo[target][pMember]][g_iLockerStock] < arrGroupData[PlayerInfo[target][pMember]][g_iLockerCost][LockerReq[target][1]]) return SendClientMessageEx(playerid, COLOR_RED, "Your locker doesn't have the materials to craft a %s.", Weapon_ReturnName(LockerReq[target][0]));
	if(PlayerInfo[target][pGuns][GetLoadoutWeaponSlot(LockerReq[target][0])] != LockerReq[target][0]) {
		arrGroupData[PlayerInfo[target][pMember]][g_iLockerStock] -= arrGroupData[PlayerInfo[target][pMember]][g_iLockerCost][LockerReq[target][1]];
		GivePlayerValidWeapon(target, LockerReq[target][0]);
		SaveGroup(group);
		SendClientMessageEx(target, COLOR_WHITE, "You withdraw a %s from the locker - authorized by %s.", Weapon_ReturnName(LockerReq[target][0]), GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_WHITE, "You have authorized %s to withdraw a %s from the locker.", GetPlayerNameEx(target), Weapon_ReturnName(LockerReq[target][0]));
		format(szMiscArray, sizeof(szMiscArray), "%s has authorized %s to withdraw a %s from the weapon locker (Cost: %d)", GetPlayerNameEx(playerid), GetPlayerNameEx(target), Weapon_ReturnName(LockerReq[target][0]), arrGroupData[PlayerInfo[target][pMember]][g_iLockerCost][LockerReq[target][1]]);
		GroupLog(PlayerInfo[target][pMember], szMiscArray);
	} else {
		SendClientMessageEx(playerid, COLOR_RED, "%s already has an %s!", GetPlayerNameEx(target), Weapon_ReturnName(LockerReq[target][0]));
		SendClientMessageEx(target, COLOR_RED, "You already have a %s on you!", Weapon_ReturnName(LockerReq[target][0]));
	}
	LockerReq[target][0] = 0;
	LockerReq[target][1] = -1;
	return 1;
}

ptask LockerTimer[1000](i) {
	if(!LockerReq[i][0]) return 1;
	if(LockerReq[i][2] <= gettime()) {
		SendClientMessageEx(i, COLOR_LIGHTBLUE, "* Your weapon withdraw request for the %s has expired.", Weapon_ReturnName(LockerReq[i][0]));
	} else {
		new group = LockerReq[i][3], slot = LockerReq[i][1];
		if(ValidGroup(group) && PlayerInfo[i][pMember] == group && 0 <= slot < MAX_GROUP_WEAPONS
			&& arrGroupData[group][g_iLockerGuns][slot] == LockerReq[i][0]
			&& !PlayerBusy(i) && !PlayerInfo[i][pJailTime] && !PlayerCuffed[i] && !PlayerTied[i]) return 1;
		SendClientMessageEx(i, COLOR_LIGHTBLUE, "* Your weapon withdraw request for the %s was interrupted.", Weapon_ReturnName(LockerReq[i][0]));
	}
	LockerReq[i][0] = 0;
	LockerReq[i][1] = -1;
	LockerReq[i][3] = INVALID_GROUP_ID;
	return 1;
}

stock GetLockerConversion(group, &total, &materials) {
	total = 0;
	materials = 0;
	if(!ValidGroup(group)) return 0;
	for(new w; w < 46; ++w) {
		new amount = LockerWep[group][lwWep][w], slot;
		if(amount < 0) return 0;
		if(!amount) continue;
		IsInSlot(group, w + 1, slot);
		if(slot == -1) continue;
		new cost = arrGroupData[group][g_iLockerCost][slot];
		if(cost < 0) return 0;
		if(!cost) continue;
		if(amount > cellmax - total || amount > (cellmax - materials) / cost) return 0;
		total += amount;
		materials += amount * cost;
	}
	return 1;
}

CMD:convertlocker(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pFactionModerator] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to use this command!");
	new group, total, materials;
	if(sscanf(params, "i", group)) return SendClientMessageEx(playerid, COLOR_GREY, "Usage: /convertlocker [groupid]");
	if(!ValidGroup(group)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Invalid group specified!");
	if(!GetLockerConversion(group, total, materials)) return SendClientMessageEx(playerid, COLOR_RED, "The old locker contains invalid quantities or weapon costs.");
	if(!materials) return SendClientMessageEx(playerid, COLOR_GREY, "There are no priced weapons to convert. Configure the locker weapons and costs first.");
	if(arrGroupData[group][g_iLockerStock] < 0 || arrGroupData[group][g_iLockerStock] > cellmax - materials) return SendClientMessageEx(playerid, COLOR_RED, "The locker cannot accept these materials.");
	SetPVarInt(playerid, "converttotal", total);
	SetPVarInt(playerid, "convertamount", materials);
	SetPVarInt(playerid, "convertgroup", group);
	format(szMiscArray, sizeof(szMiscArray), "Convert %s's old locker into high grade materials?\n\nWeapons to convert: %s\nMaterials to add: %s\n\nWeapons without a configured positive cost will remain in the old locker.", arrGroupData[group][g_szGroupName], number_format(total), number_format(materials));
	return Dialog_Show(playerid, convert_locker, DIALOG_STYLE_MSGBOX, "Convert Old Locker", szMiscArray, "Convert", "Cancel");
}

Dialog:convert_locker(playerid, response, listitem, inputtext[]) {
	new group = GetPVarInt(playerid, "convertgroup"), quotedTotal = GetPVarInt(playerid, "converttotal"), quotedMaterials = GetPVarInt(playerid, "convertamount");
	new bool:pending = GetPVarType(playerid, "convertgroup") != 0;
	DeletePVar(playerid, "convertgroup");
	DeletePVar(playerid, "converttotal");
	DeletePVar(playerid, "convertamount");
	if(!response || !pending) return 1;
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pFactionModerator] < 1) return 1;
	new total, materials;
	if(!ValidGroup(group) || !GetLockerConversion(group, total, materials) || materials < 1) return SendClientMessageEx(playerid, COLOR_GREY, "The old locker is no longer available for conversion.");
	if(total != quotedTotal || materials != quotedMaterials) return SendClientMessageEx(playerid, COLOR_GREY, "The locker contents or costs changed. Use /convertlocker again.");
	if(arrGroupData[group][g_iLockerStock] < 0 || arrGroupData[group][g_iLockerStock] > cellmax - materials) return SendClientMessageEx(playerid, COLOR_RED, "The locker cannot accept these materials.");
	for(new w; w < 46; ++w) {
		if(!LockerWep[group][lwWep][w]) continue;
		new slot;
		IsInSlot(group, w + 1, slot);
		if(slot != -1 && arrGroupData[group][g_iLockerCost][slot] > 0) LockerWep[group][lwWep][w] = 0;
	}
	arrGroupData[group][g_iLockerStock] += materials;
	SaveWeapons(group);
	SaveGroup(group);
	format(szMiscArray, sizeof(szMiscArray), "%s converted %d old locker weapons into %d materials.", GetPlayerNameEx(playerid), total, materials);
	GroupLog(group, szMiscArray);
	SendClientMessageEx(playerid, COLOR_YELLOW, "%s weapons have been converted into %s materials.", number_format(total), number_format(materials));
	return 1;
}
