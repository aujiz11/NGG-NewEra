#include <YSI_Coding\y_hooks>

#define BANK					10004
#define BANK_AMOUNT 			10005
#define BANK_TRANSFER_TO		10006
#define BANK_TRANSFER_AMT		10007


// use the below for bank VWs so that all actors are created properly.
#define BANK_RODEO			1
#define BANK_MULLHOLLAND	2
#define BANK_SF				3
#define BANK_LV				4
#define BANK_DILLIMORE		5
#define BANK_LASBARANCAS	6

new Bankers[12];
new BankPoint[12];

LoadBanks() {

	// rodeo
	Bankers[0] = CreateActor(150, 2319.2590,-15.7090,26.7496, 90);
	Bankers[1] = CreateActor(150, 2319.1768,-7.2503,26.7496, 90);

	SetActorVirtualWorld(Bankers[0], BANK_RODEO);
	SetActorVirtualWorld(Bankers[1], BANK_RODEO);

	// mullholland
	Bankers[2] = CreateActor(150, 2319.2590,-15.7090,26.7496, 90);
	Bankers[3] = CreateActor(150, 2319.1768,-7.2503,26.7496, 90);

	SetActorVirtualWorld(Bankers[2], BANK_MULLHOLLAND);
	SetActorVirtualWorld(Bankers[3], BANK_MULLHOLLAND);

	// san fierro
	Bankers[4] = CreateActor(150, 2319.2590,-15.7090,26.7496, 90);
	Bankers[5] = CreateActor(150, 2319.1768,-7.2503,26.7496, 90);

	SetActorVirtualWorld(Bankers[4], BANK_SF);
	SetActorVirtualWorld(Bankers[5], BANK_SF);

	// las venturas
	Bankers[6] = CreateActor(150, 2319.2590,-15.7090,26.7496, 90);
	Bankers[7] = CreateActor(150, 2319.1768,-7.2503,26.7496, 90);

	SetActorVirtualWorld(Bankers[6], BANK_LV);
	SetActorVirtualWorld(Bankers[7], BANK_LV);

	// dillimore
	Bankers[8] = CreateActor(150, 2319.2590,-15.7090,26.7496, 90);
	Bankers[9] = CreateActor(150, 2319.1768,-7.2503,26.7496, 90);

	SetActorVirtualWorld(Bankers[8], BANK_DILLIMORE);
	SetActorVirtualWorld(Bankers[9], BANK_DILLIMORE);

	// las barrancas
	Bankers[10] = CreateActor(150, 2319.2590,-15.7090,26.7496, 90);
	Bankers[11] = CreateActor(150, 2319.1768,-7.2503,26.7496, 90);

	SetActorVirtualWorld(Bankers[10], BANK_LASBARANCAS);
	SetActorVirtualWorld(Bankers[11], BANK_LASBARANCAS);

	// pickups for interaction.
	BankPoint[0] = CreateDynamicSphere(2316.2263,-7.3651, 26.7422, 3.0);
	BankPoint[1] = CreateDynamicSphere(2316.4480,-15.4179,26.7422, 3.0);

	print("[Streamer] Bank System Loaded");

	return 1;


}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if((newkeys & KEY_YES) && (IsPlayerInDynamicArea(playerid, BankPoint[0]) || IsPlayerInDynamicArea(playerid, BankPoint[1]))) {
		format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s den va noi chuyen voi nhan vien ngan hang.", GetPlayerNameEx(playerid));
		//ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SetPlayerChatBubble(playerid, szMiscArray, COLOR_PURPLE, 15.0, 5000);
		ShowBankMenu(playerid);
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid) {

		case BANK: {
			
			if(!response) {
				TogglePlayerControllable(playerid, true);
				return SendClientMessageEx(playerid, COLOR_YELLOW, "Nhan vien ngan hang da ngung phuc vu ban.");
			}

			TogglePlayerControllable(playerid, false);

			switch(listitem) {		
				case 0: ShowBankMenu(playerid, 1);
				case 1: ShowBankMenu(playerid, 2);
				case 2: ShowBankMenu(playerid, 3);
				case 3: {
		 	
				 	if(PlayerInfo[playerid][pCheckCash] > 0) {
				    	//GivePlayerCash(playerid,PlayerInfo[playerid][pCheckCash]);
				    	GivePlayerCashEx(playerid, TYPE_BANK, PlayerInfo[playerid][pCheckCash]);
				     	PlayerInfo[playerid][pCheckCash] = 0;
				      	SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi toan bo sec va gui tien vao ngan hang.");
				       	return ShowBankMenu(playerid);
					}		
					else {
						SendClientMessageEx(playerid, COLOR_YELLOW, "Ban khong co sec nao chua doi.");
						return ShowBankMenu(playerid);
					}
				}
			}
		}

		case BANK_AMOUNT: {
			if(!response) {
				DeletePVar(playerid, "BankWithdraw");
				DeletePVar(playerid, "BankDeposit");
				return ShowBankMenu(playerid);
			}

			new 
				iAmount = strval(inputtext);

			if(GetPVarType(playerid, "BankWithdraw")) {
				
				if(iAmount < 1) {
					SendClientMessageEx(playerid, COLOR_WHITE, "Khong the giao dich so tien am!");
					return ShowBankMenu(playerid, 1);
				}

				if(iAmount > PlayerInfo[playerid][pAccount]) {
					SendClientMessageEx(playerid, COLOR_WHITE, "So tien rut vuot qua so du!");
					return ShowBankMenu(playerid, 1);
				}

				if(gettime()-GetPVarInt(playerid, "LastTransaction") < 10) {
					SendClientMessageEx(playerid, COLOR_GRAD2, "Chi duoc giao dich moi 10 giay, hay cho!");
					ShowBankMenu(playerid, 1);
				}
				SetPVarInt(playerid, "LastTransaction", gettime());
				
				GivePlayerCash(playerid, iAmount);
				PlayerInfo[playerid][pAccount] -= iAmount;
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da rut $%s tu tai khoan.", number_format(iAmount));

				if(PlayerInfo[playerid][pTut] == 16)
				{
					PlayerInfo[playerid][pTut]++;
					AdvanceTutorial(playerid);
				}

				OnPlayerStatsUpdate(playerid);

				DeletePVar(playerid, "BankWithdraw");

				return ShowBankMenu(playerid);
			}
			else if(GetPVarType(playerid, "BankDeposit")) {

				if(iAmount < 1) {
					SendClientMessageEx(playerid, COLOR_WHITE, "Khong the giao dich so tien am!");
					return ShowBankMenu(playerid, 2);
				}

				if(iAmount > GetPlayerCash(playerid)) {
					SendClientMessageEx(playerid, COLOR_WHITE, "So tien gui vuot qua tien ban co!");
					return ShowBankMenu(playerid, 2);
				}

				if(gettime()-GetPVarInt(playerid, "LastTransaction") < 10) {
					SendClientMessageEx(playerid, COLOR_GRAD2, "Chi duoc giao dich moi 10 giay, hay cho!");
					ShowBankMenu(playerid, 2);
				}
				SetPVarInt(playerid, "LastTransaction", gettime());
				
				GivePlayerCash(playerid, -iAmount);
				PlayerInfo[playerid][pAccount] += iAmount; 
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da gui $%s vao tai khoan.", number_format(iAmount));

				OnPlayerStatsUpdate(playerid);

				DeletePVar(playerid, "BankDeposit");

				return ShowBankMenu(playerid);
			}
		}

		case BANK_TRANSFER_TO: {
			DeletePVar(playerid, "BankTransferTo");
			DeletePVar(playerid, "BankTransferAccount");
			DeletePVar(playerid, "BankTransferSession");
			
			if(!response) {
				return ShowBankMenu(playerid);
			}

			new id;
			if(!strlen(inputtext) || strlen(inputtext) > 3 || !IsNumericString(inputtext)) return ShowBankMenu(playerid, 3);
			id = strval(inputtext);
			
			if(id < 0 || id >= MAX_PLAYERS || id == playerid || !IsPlayerConnected(id) || !gPlayerLogged{id}) {
				SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi nhan chua ket noi!");
				return ShowBankMenu(playerid, 3);
			}

			SetPVarInt(playerid, "BankTransferTo", id);
			SetPVarInt(playerid, "BankTransferSource", GetPlayerSQLId(playerid));
			SetPVarInt(playerid, "BankTransferActorSession", g_arrQueryHandle[playerid]);
			SetPVarInt(playerid, "BankTransferAccount", GetPlayerSQLId(id));
			SetPVarInt(playerid, "BankTransferSession", g_arrQueryHandle[id]);
			return ShowBankMenu(playerid, 4);
		}

		case BANK_TRANSFER_AMT: {

			if(!response) {
				DeletePVar(playerid, "BankTransferTo");
				return ShowBankMenu(playerid, 3);
			}

			new id = GetPVarInt(playerid, "BankTransferTo"), iAmount;
			if(!gPlayerLogged{playerid} || GetPlayerSQLId(playerid) != GetPVarInt(playerid, "BankTransferSource")
				|| g_arrQueryHandle[playerid] != GetPVarInt(playerid, "BankTransferActorSession") || !GetPVarType(playerid, "BankTransferTo") || id < 0 || id >= MAX_PLAYERS || id == playerid
				|| !IsPlayerConnected(id) || !gPlayerLogged{id} || GetPlayerSQLId(id) <= 0
				|| GetPlayerSQLId(id) != GetPVarInt(playerid, "BankTransferAccount")
				|| g_arrQueryHandle[id] != GetPVarInt(playerid, "BankTransferSession")) {
				DeletePVar(playerid, "BankTransferTo");
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi nhan da doi hoac ngat ket noi. Hay chon lai.");
				return ShowBankMenu(playerid, 3);
			}
			if(!ParseBankTransferAmount(inputtext, iAmount)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nhap so tien nguyen duong trong gioi han cho phep.");
			return TransferBankAccount(playerid, id, iAmount, false);

		}
	}
	return 0;
}

ShowBankMenu(playerid, menu = 0) {

	new szTitle[48];

	szMiscArray[0] = 0;

	format(szTitle, sizeof(szTitle), "Ngan hang: $%s", number_format(PlayerInfo[playerid][pAccount]));

	if(PlayerInfo[playerid][pFreezeBank] == 1) return ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, szTitle, "Tai san da bi dong bang! Hay lien he Judicial!", "Dong y", "");

	switch(menu) {

		case 0: { // main menu
			ShowPlayerDialogEx(playerid, BANK, DIALOG_STYLE_LIST, szTitle, "Rut tien\nGui tien\nChuyen tien\nDoi sec", "Chon", "Huy");
		}

		case 1: { // iAmount withdraw
			ShowPlayerDialogEx(playerid, BANK_AMOUNT, DIALOG_STYLE_INPUT, szTitle, "Nhap so tien muon rut tu tai khoan.", "Rut", "Huy");
			SetPVarInt(playerid, "BankWithdraw", 1);
		}

		case 2: { // iAmount deposit
			ShowPlayerDialogEx(playerid, BANK_AMOUNT, DIALOG_STYLE_INPUT, szTitle, "Nhap so tien muon gui vao tai khoan.", "Gui", "Huy");
			SetPVarInt(playerid, "BankDeposit", 1);
		}

		case 3: { // transfer to
			ShowPlayerDialogEx(playerid, BANK_TRANSFER_TO, DIALOG_STYLE_INPUT, szTitle, "Nhap ID nguoi nhan tien.", "Tiep", "Huy");
		}

		case 4: { // transfer iAmount
			format(szMiscArray, sizeof(szMiscArray), "Nhap so tien muon chuyen cho {FF0000}%s", GetPlayerNameEx(GetPVarInt(playerid, "BankTransferTo")));
			ShowPlayerDialogEx(playerid, BANK_TRANSFER_AMT, DIALOG_STYLE_INPUT, szTitle, szMiscArray, "Chuyen", "Huy");
		}
	}

	return 1;
}