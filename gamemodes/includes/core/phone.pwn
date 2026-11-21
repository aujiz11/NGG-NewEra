/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Phone System

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

forward RingToner();
public RingToner()
{
	foreach(new i: Player)
	{
		if(RingTone[i] != 6 && RingTone[i] != 0 && RingTone[i] < 11)
		{
			RingTone[i] = RingTone[i] -1;
			PlayerPlaySound(i, 1138, 0.0, 0.0, 0.0);
		}
		if(RingTone[i] == 6)
		{
			RingTone[i] = RingTone[i] -1;
		}
		if(RingTone[i] == 20)
		{
			RingTone[i] = RingTone[i] -1;
			PlayerPlaySound(i, 1139, 0.0, 0.0, 0.0);
		}
	}
	SetTimer("RingTonerRev", 1000, false);
	return 1;
}

forward RingTonerRev();
public RingTonerRev()
{
	foreach(new i: Player)
	{
		if(RingTone[i] != 5 && RingTone[i] != 0 && RingTone[i] < 10)
		{
			RingTone[i] = RingTone[i] -1;
			PlayerPlaySound(i, 1137, 0.0, 0.0, 0.0);
		}
		if(RingTone[i] == 5)
		{
			RingTone[i] = RingTone[i] -1;
		}
		if(RingTone[i] == 19)
		{
			PlayerPlaySound(i, 1139, 0.0, 0.0, 0.0);
			RingTone[i] = 0;
		}
	}
	SetTimer("RingToner", 1000, false);
	return 1;
}

CMD:cellphonehelp(playerid, params[])
{
	SetPVarInt(playerid, "HelpResultCat0", 4);
	Help_ListCat(playerid, DIALOG_HELPCATOTHER1);
	return 1;
}

CMD:ocellphonehelp(playerid, params[])
{
    SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
    if (PlayerInfo[playerid][pPnumber] != 0) {
        SendClientMessageEx(playerid, COLOR_WHITE,"*** HUONG DAN *** - nhap lenh de xem chi tiet.");
        SendClientMessageEx(playerid, COLOR_GRAD3,"*** DIEN THOAI *** /call 'vi du: /call 911' /sms (/p)ickup (/h)angup /speakerphone /number");
    }
    else {
        SendClientMessageEx(playerid, COLOR_WHITE,"Co the mua dien thoai tai bat ky 24-7 nao");
    }
    return 1;
}

CMD:phoneprivacy(playerid, params[])
{
    if(PlayerInfo[playerid][pPnumber] != 0 && PlayerInfo[playerid][pDonateRank] >= 2)
	{
        if(PlayerInfo[playerid][pPhonePrivacy] == 1)
		{
            PlayerInfo[playerid][pPhonePrivacy] = 0;
            SendClientMessageEx(playerid, COLOR_WHITE, "Da tat che do rieng tu dien thoai.");
        }
        else
		{
            PlayerInfo[playerid][pPhonePrivacy] = 1;
            SendClientMessageEx(playerid, COLOR_WHITE, "Da bat che do rieng tu dien thoai.");
        }
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co dien thoai hoac chua la Silver VIP.");
    }
    return 1;
}

CMD:speakerphone(playerid, params[])
{
    if(PlayerInfo[playerid][pPnumber] != 0)
	{
        if(PlayerInfo[playerid][pSpeakerPhone] == 1)
		{
            PlayerInfo[playerid][pSpeakerPhone] = 0;
            SendClientMessageEx(playerid, COLOR_WHITE, "Da tat loa ngoai dien thoai.");
        }
        else
		{
            PlayerInfo[playerid][pSpeakerPhone] = 1;
            SendClientMessageEx(playerid, COLOR_WHITE, "Da bat loa ngoai dien thoai.");
        }
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co dien thoai.");
    }
    return 1;
}

CMD:colorcar(playerid, params[]) {
	new iColors[2];
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o trong xe.");
	else if(PlayerInfo[playerid][pSpraycan] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Binh son da het.");
	if(sscanf(params, "ii", iColors[0], iColors[1])) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /colorcar [ID 1] [ID 2]. Colors must be an ID.");
	else if((PlayerInfo[playerid][pDonateRank] == 0) && (iColors[0] > 127 || iColors[1] > 127)) return SendClientMessageEx(playerid, COLOR_GREY, "Chi VIP duoc dung ID mau dac biet tren 127.");
	else if(!(0 <= iColors[0] <= 255 && 0 <= iColors[1] <= 255)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
	for(new i = 0; i < MAX_PLAYERVEHICLES; i++)
	{
		if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][i][pvId]))
		{
			PlayerVehicleInfo[playerid][i][pvColor1] = iColors[0], PlayerVehicleInfo[playerid][i][pvColor2] = iColors[1];
			ChangeVehicleColor(PlayerVehicleInfo[playerid][i][pvId], PlayerVehicleInfo[playerid][i][pvColor1], PlayerVehicleInfo[playerid][i][pvColor2]);
			PlayerInfo[playerid][pSpraycan]--;
			g_mysql_SaveVehicle(playerid, i);
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Da doi mau xe cua ban sang ID %d, %d.", iColors[0], iColors[1]);
		}
	}
	for(new i = 0; i < sizeof(VIPVehicles); i++)
	{
		if(IsPlayerInVehicle(playerid, VIPVehicles[i]))
		{
			ChangeVehicleColor(VIPVehicles[i], iColors[0], iColors[1]);
			PlayerInfo[playerid][pSpraycan]--;
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Da doi mau xe nay sang ID %d, %d.", iColors[0], iColors[1]);
		}
	}
	for(new i = 0; i < sizeof(FamedVehicles); i++)
	{
		if(IsPlayerInVehicle(playerid, FamedVehicles[i]))
		{
			ChangeVehicleColor(FamedVehicles[i], iColors[0], iColors[1]);
			PlayerInfo[playerid][pSpraycan]--;
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Da doi mau xe nay sang ID %d, %d.", iColors[0], iColors[1]);
		}
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Khong the son xe cua nguoi khac.");
	return 1;
}

CMD:number(playerid, params[]) {
	if(PlayerInfo[playerid][pPhoneBook] == 1) {

		new
			iTarget;

		if(sscanf(params, "u", iTarget)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /number [player]");
		}
		else if(IsPlayerConnected(iTarget)) {

			SendClientMessageEx(playerid, COLOR_GRAD1, "* %s (%i)", GetPlayerNameEx(iTarget), PlayerInfo[iTarget][pPnumber]);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co danh ba dien thoai.");
	return 1;
}



alias:tempnumber("tempnum")
CMD:tempnumber(playerid, params[]){
	if (PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][gTempNum] || IsAHitman(playerid)) {
        new num;
        if(TempNumber[playerid] == 1) {
			SendClientMessageEx(playerid, COLOR_GREY, "Da tat so tam va khoi phuc so dien thoai goc.");
			TempNumber[playerid] = 0;
			PlayerInfo[playerid][pPnumber] = GetPVarInt(playerid, "oldnum");
			DeletePVar(playerid, "oldnum");
			DeletePVar(playerid, "tempnum");
			return 1;
		}
        if(sscanf(params, "i", num) && TempNumber[playerid] == 0)
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /tempnumber [number]");

		if(strlen(params) > 10 || strlen(params) < 2) 
			return SendClientMessage(playerid, COLOR_GREY, "So dien thoai tam phai dai tu 2 den 10 chu so.");

		if(PlayerInfo[playerid][pPnumber] == num)
			return SendClientMessageEx(playerid,COLOR_GREY,"So tam khong duoc trung so hien tai");

		else {

			SetPVarInt(playerid, "oldnum", PlayerInfo[playerid][pPnumber]);
			SetPVarInt(playerid, "tempnum", num);
			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",num);
			mysql_tquery(MainPipeline, szMiscArray, "OnPhoneNumberCheck", "ii", playerid, 5);
		}
	} else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

/*
CMD:ringtone(playerid, params[])
{
    if(GetPVarType(playerid, "PlayerCuffed") || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen")) {
   		return SendClientMessage(playerid, COLOR_GRAD2, "You can't do that at this time!");
	}

	if(!IsPlayerInAnyVehicle(playerid))
	{
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		SetPlayerAttachedObject(playerid, 9, 330, 6);
	}
	return ShowPlayerDialogEx(playerid,RTONEMENU,DIALOG_STYLE_LIST,"Ringtone - Change Your Ringtone:","Ringtone 1\nRingtone 2\nRingtone 3\nRingtone 4\nRingtone 5\nRingtone 6\nRingtone 7\nRingtone 8\nRingtone 9\nTurn Off","Select","Close");
}
*/

CMD:setautoreply(playerid, params[])
{
	if(strlen(PlayerInfo[playerid][pAutoTextReply]) > 0)
	{
		strdel(PlayerInfo[playerid][pAutoTextReply], 0, 64);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da tat tra loi tu dong.");
		return 1;
	}

	if(PlayerInfo[playerid][pDonateRank] < 2)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai VIP.");
		return 1;
	}

	if(isnull(params))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setautoreply [text]");
		return 1;
	}

	if(strlen(params) >= 1 && strlen(params) < 63)
	{
		format(PlayerInfo[playerid][pAutoTextReply], 64, "%s", params);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi tin tra loi tu dong thanh: %s", params);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "LOI: Tin tra loi tu dong phai tu 1 den 64 ky tu.");
	}
	return 1;
}

CMD:call(playerid, const params[])
{
	new string[128], phonenumb;
	if(Mobile[playerid] != INVALID_PLAYER_ID || GetPVarType(playerid, "CallingPayPhone")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang trong cuoc goi.");
	if(GetPVarType(playerid, "PayPhone")) {
		new i = GetPVarInt(playerid, "PayPhone");
		if(!PayPhone_Valid(i) || gPayPhonesLoading || arrPayPhoneData[i][pp_bPending]
			|| arrPayPhoneData[i][pp_iUserID] != playerid || !IsPlayerInDynamicArea(playerid, arrPayPhoneData[i][pp_iAreaID])) {
			PayPhone_EndCall(playerid);
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong con o gan dien thoai cong cong kha dung.");
		}
	}

	if(sscanf(params, "d", phonenumb) || phonenumb <= 0) {
		if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /call [phonenumber]");
	}

	if(PlayerInfo[playerid][pJailTime] > 0 && !GetPVarType(playerid, "PayPhone"))
	{
		SendClientMessageEx(playerid,COLOR_GREY,"Khong the dung dien thoai khi o tu.");
		return 1;
	}
	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || GetPVarInt(playerid, "pBagged") >= 1)
	{
		if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
		SendClientMessageEx(playerid,COLOR_GREY,"Khong the dung dien thoai khi bi khong che.");
		return 1;
	}
	if(!GetPVarType(playerid, "PayPhone")) {

		if(PlayerInfo[playerid][pPnumber] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co dien thoai.");
			return 1;
		}
		if(PhoneOnline[playerid] > 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Dien thoai dang tat.");
			return 1;
		}
	}
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] > 0) {
		if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
   		return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam viec nay!");
	}
	format(string, sizeof(string), "* %s lay dien thoai ra.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

	switch(phonenumb) {

		case 911: {

			if(PlayerInfo[playerid][pJailTime] > 0 && !GetPVarType(playerid, "PayPhone")) return SendClientMessageEx(playerid, COLOR_WHITE, "Cannot use this whilst in prison!");
			if(GetPVarType(playerid, "Has911Call")) SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co mot cuoc goi dang hoat dong. (/cancelcall)");
			else if(PlayerInfo[playerid][p911Muted] != 0) ShowPlayerDialogEx(playerid, 7955, DIALOG_STYLE_MSGBOX, "Cuoc goi bi chan", "Ban dang bi cam dung dich vu cap cuu 911, thuong do lam dung dich vu.\n\n((Dung /report de xin mo cam))", "Dong", "");
			else ShowPlayerDialogEx(playerid, DIALOG_911MENU, DIALOG_STYLE_LIST, "Dich vu khan cap 911", "Khan cap\nY te\nCanh sat (Khong khan cap)\nCuu ho xe\nTrom xe (Dang xay ra)\nHoa hoan", "Chon", "Gac may");
			return 1;
		}
		case 18004444, 18001800, 18008080, 18001111, 18001020: {

			if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi o tu!");
			if(GetPVarType(playerid, "Has911Call")) SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co mot cuoc goi dang hoat dong. (/cancelcall)");
			else {

				new iGroupID;

				if(phonenumb == 18004444) iGroupID = 5;
				if(phonenumb == 18001800) iGroupID = 12;
				if(phonenumb == 18008080) iGroupID = 4;
				if(phonenumb == 18001111) iGroupID = 6; // SATR
				if(phonenumb == 18001020) iGroupID = 2; // SAPS

				if(GetPVarType(playerid, "PayPhone")) TogglePlayerControllable(playerid, false);

				format(szMiscArray, sizeof(szMiscArray), "GROUP ID: %d", iGroupID);
				SendClientMessage(playerid, COLOR_YELLOW, szMiscArray);
				SetPVarInt(playerid, "GRPCALL", iGroupID);
				format(szMiscArray, sizeof(szMiscArray), "{%s}Duong day nong cua %s", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				ShowPlayerDialogEx(playerid, DIALOG_HOTLINE, DIALOG_STYLE_INPUT, szMiscArray, "Hay tom tat nhu cau cua ban.", "Nhap", "Gac may");
			}
			return 1;
		}
		/*case 1738: {

			if(!GetPVarType(playerid, "ShipmentCallActive"))
			{
				SetPVarInt(playerid, "ShipmentCallActive", 1);

				SendClientMessageEx(playerid, COLOR_PINK, "** An unknown person picks up the phone.");
				SetTimerEx("ShipmentConvo", 2000, false, "ii", playerid, 1);
			}
			return 1;
		}*/
	}

	if(GetPVarType(playerid, "BUSICALL")) {


		if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi o tu!");
		if(GetPVarType(playerid, "Has911Call")) SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co mot cuoc goi dang hoat dong. (/cancelcall)");
		else {

			new i = GetPVarInt(playerid, "BUSICALL");
			format(szMiscArray, sizeof(szMiscArray), "DT ban: %s | %d", Businesses[i][bName], Businesses[i][bPhoneNr]);
			ShowPlayerDialogEx(playerid, DIALOG_HOTLINE, DIALOG_STYLE_INPUT, szMiscArray, "Hay tom tat nhu cau cua ban.", "Nhap", "Gac may");
		}
		return 1;
	}
	if(GetPVarType(playerid, "PayPhone")) {

		new i = GetPVarInt(playerid, "PayPhone");
		if(arrPayPhoneData[i][pp_iNumber] == phonenumb) {
			PayPhone_EndCall(playerid);
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the goi chinh dien thoai cong cong dang dung.");
		}
	}
	for(new i; i < MAX_PAYPHONES; ++i) {
		if(!PayPhone_Valid(i) || phonenumb != arrPayPhoneData[i][pp_iNumber]) continue;
		if(gPayPhonesLoading || arrPayPhoneData[i][pp_bPending] || arrPayPhoneData[i][pp_iCallerID] != INVALID_PLAYER_ID || arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID) {
			if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Dien thoai cong cong dang ban hoac khong kha dung.");
		}
		SetPVarInt(playerid, "CallingPayPhone", i);
		arrPayPhoneData[i][pp_iCallerID] = playerid;
		PayPhone_UpdateTextLabel(i, 1);
		if(GetPVarType(playerid, "PayPhone")) {
			TogglePlayerControllable(playerid, false);
			PayPhone_UpdateTextLabel(GetPVarInt(playerid, "PayPhone"), 2);
		}
		SendClientMessageEx(playerid, COLOR_GRAD1, "Dang goi dien thoai cong cong...");
		SendClientMessageEx(playerid, COLOR_WHITE, "GOI Y: Dung T de noi qua dien thoai, /hangup de gac may.");
		CellTime[playerid] = 1;
		SetPlayerAttachedObject(playerid, 8, 330, 6);
		return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	}
	for(new i; i < MAX_BUSINESSES; ++i) {

		if(IsValidBusinessID(i)) {

			if(phonenumb == Businesses[i][bPhoneNr]) {

				if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi o tu!");
				if(GetPVarType(playerid, "Has911Call")) SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co mot cuoc goi dang hoat dong. (/cancelcall)");
				else {

					SetPVarInt(playerid, "BUSICALL", i);
					format(szMiscArray, sizeof(szMiscArray), "DT cong ty %s | %d", Businesses[i][bName], Businesses[i][bPhoneNr]);
					ShowPlayerDialogEx(playerid, DIALOG_HOTLINE, DIALOG_STYLE_INPUT, szMiscArray, "Hay tom tat nhu cau cua ban.", "Nhap", "Gac may");
				}
				return 1;
			}
		}
	}
	if(phonenumb == PlayerInfo[playerid][pPnumber])
	{
		if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
		SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the goi chinh minh...");
		return 1;
	}
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pPnumber] == phonenumb && phonenumb != 0)
		{
			Mobile[playerid] = i; //caller connecting
			if(IsPlayerConnected(i))
			{
				if(i != INVALID_PLAYER_ID)
				{
					if(PhoneOnline[i] > 0)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Dien thoai nguoi do dang tat.");
						Mobile[playerid] = INVALID_PLAYER_ID;
						if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
						return 1;
					}
					if(Mobile[i] != INVALID_PLAYER_ID || GetPVarType(i, "PayPhone") || GetPVarType(i, "CallingPayPhone"))
					{
						SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chi nghe tin hieu ban...");
						Mobile[playerid] = INVALID_PLAYER_ID;
						if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
						return 1;
					}
					if(Spectating[i]!=0)
					{
						SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chi nghe tin hieu ban...");
						Mobile[playerid] = INVALID_PLAYER_ID;
						if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
						return 1;
					}
					if(Mobile[i] == INVALID_PLAYER_ID)
					{
						if(GetPVarType(playerid, "PayPhone")) {

							format(string, sizeof(string), "Dien thoai reo, dung /p de nghe. [Nguoi goi: DT cong cong (%d)]", arrPayPhoneData[GetPVarInt(playerid, "PayPhone")][pp_iNumber]);
							TogglePlayerControllable(playerid, false);
							PayPhone_UpdateTextLabel(GetPVarInt(playerid, "PayPhone"), 2);
							SendClientMessageEx(i, COLOR_YELLOW, string);
						}
						else {
							SendClientMessageEx(i, COLOR_YELLOW, "Dien thoai reo, dung /p de nghe. [So nguoi goi: %d]", PlayerInfo[playerid][pPnumber]);
							FetchContact(i, PlayerInfo[playerid][pPnumber]);
						}
						RingTone[i] = 10;
						format(string, sizeof(string), "* Dien thoai %s reo.", GetPlayerNameEx(i));
						SendClientMessageEx(playerid, COLOR_WHITE, "GOI Y: Dung T de noi qua dien thoai, /hangup de gac may.");
						ProxDetector(30.0, i, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						CellTime[playerid] = 1;
						SetPlayerAttachedObject(playerid, 8, 330, 6);
						Phone_Calling(playerid, i);
						return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
					}
				}
			}
		}
	}
	SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the ket noi cuoc goi, kiem tra so va thu lai.");
	if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
	return 1;
}





alias:sms("t", "txt")
CMD:sms(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap!");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	if(PlayerInfo[playerid][pPnumber] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co dien thoai.");
	if(PhoneOnline[playerid] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Dien thoai dang tat.");
	if(GetPVarInt(playerid, "Injured") != 0 || PlayerInfo[playerid][pHospital] != 0) return SendClientMessageEx (playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || GetPVarInt(playerid, "pBagged") >= 1) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung dien thoai khi bi khong che.");
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung dien thoai khi dang o tu!");

	szMiscArray[0] = 0;

	new phonenumb, text[100];
	if(sscanf(params, "ds[100]", phonenumb, text)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/t)ext [phonenumber] [text chat]");

	if(Spectating[playerid] == 0 || !GetPVarType(playerid, "FlyMode"))
	{
		format(szMiscArray, sizeof(szMiscArray), "* %s lay dien thoai ra.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	}

	if(phonenumb == 555)
	{
		if ((strcmp("yes", text, true, strlen(text)) == 0) && (strlen(text) == strlen("yes")))
		{
			ChatTrafficProcess(playerid, COLOR_YELLOW, "Da gui tin nhan.", 7);
			ChatTrafficProcess(playerid, COLOR_YELLOW, "SMS: Toi dang theo doi ban, Nguoi gui: MOLE (555)", 7);
			//SendAudioToPlayer(playerid, 47, 100);
			RingTone[playerid] = 20;
			return 1;
		}
		else
		{
			ChatTrafficProcess(playerid, COLOR_YELLOW, "SMS: Toi dang theo doi ban, Nguoi gui: MOLE (555)", 7);
			//SendAudioToPlayer(playerid, 47, 100);
			RingTone[playerid] = 20;
			return 1;
		}
	}
	szMiscArray[0] = 0;
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pPnumber] == phonenumb && phonenumb != 0)
		{
			new giveplayerid = i;
			if(Mobile[giveplayerid] != INVALID_PLAYER_ID)
			{
				ChatTrafficProcess(playerid, COLOR_GREY, "Dien thoai nguoi do dang ban (co cuoc goi).", 7);
				return 1;
			}
			if(IsPlayerConnected(giveplayerid))
			{
				if(giveplayerid != INVALID_PLAYER_ID)
				{

					if(PhoneOnline[giveplayerid] > 0)
					{
						ChatTrafficProcess(playerid, COLOR_GREY, "Dien thoai nguoi do dang tat.", 7);
						return 1;
					}
					foreach(new u: Player)
					{
						if(GetPVarInt(u, "BigEar") == 6 && (GetPVarInt(u, "BigEarPlayer") == playerid || GetPVarInt(u, "BigEarPlayer") == giveplayerid))
						{
							format(szMiscArray, sizeof(szMiscArray), "(BE)%s SMS den %s: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), text);
							ChatTrafficProcess(u, COLOR_YELLOW, szMiscArray, 7);
						}
					}
					if(PlayerInfo[playerid][pPhonePrivacy] == 1)
					{
						format(szMiscArray, sizeof(szMiscArray), "SMS: %s, Tu: An danh.", text);
					}
					else
					{
						format(szMiscArray, sizeof(szMiscArray), "SMS: %s, Tu: %d (( %s ))", text, PlayerInfo[playerid][pPnumber], GetPlayerNameEx(playerid));
					}

					if(i != playerid)
					{
						if(PlayerInfo[i][pSmslog] > 0)
						{
							new query[384], ftext[128];
							mysql_escape_string(text, ftext);
							if(PlayerInfo[playerid][pPhonePrivacy] == 1) mysql_format(MainPipeline, query, sizeof(query), "INSERT INTO `sms` (`id`, `sender`, `senderid`, `sendernumber`, `receiver`, `receiverid`, `receivernumber`, `message`, `date`) VALUES (NULL, '%s', %d, 0, '%s', %d, %d, '%s', NOW())", GetPlayerNameExt(playerid), GetPlayerSQLId(playerid), GetPlayerNameExt(i), GetPlayerSQLId(i), phonenumb, ftext);
							else mysql_format(MainPipeline, query, sizeof(query), "INSERT INTO `sms` (`id`, `sender`, `senderid`, `sendernumber`, `receiver`, `receiverid`, `receivernumber`, `message`, `date`) VALUES (NULL, '%s', %d, %d, '%s', %d, %d, '%s', NOW())", GetPlayerNameExt(playerid), GetPlayerSQLId(playerid), PlayerInfo[playerid][pPnumber], GetPlayerNameExt(i), GetPlayerSQLId(i), phonenumb, ftext);
							mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
						}
					}

					//format(szMiscArray, sizeof(szMiscArray), "* %s's phone beeps.", sendername);
					RingTone[giveplayerid] =20;
					ChatTrafficProcess(giveplayerid, COLOR_YELLOW, szMiscArray, 7);
					ChatTrafficProcess(playerid, COLOR_YELLOW, szMiscArray, 7);
					ChatTrafficProcess(playerid, COLOR_YELLOW, "Da gui tin nhan", 7);
					FetchContact(giveplayerid, PlayerInfo[playerid][pPnumber]);
					format(szMiscArray, sizeof(szMiscArray), "~r~$-%d", 25);
					GameTextForPlayer(playerid, szMiscArray, 5000, 1);
					GivePlayerCash(playerid,-25);
					//PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
					//SendAudioToPlayer(playerid, 47, 100);
					//SendAudioToPlayer(giveplayerid, 47, 100);

					if(strcmp(PlayerInfo[giveplayerid][pAutoTextReply], "Nothing", true) != 0)
					{
						format(szMiscArray, sizeof(szMiscArray), "SMS: %s, Tu: %d [automated response]", PlayerInfo[giveplayerid][pAutoTextReply], PlayerInfo[giveplayerid][pPnumber]);
						ChatTrafficProcess(playerid, COLOR_YELLOW, szMiscArray, 7);
					}

					return 1;
				}
			}
		}
	}
	SendClientMessageEx(playerid, COLOR_GRAD2, "Gui tin nhan that bai...");
	return 1;
}



alias:pickup("p")
CMD:pickup(playerid, const params[])
{
	new string[128];
	if(Mobile[playerid] != INVALID_PLAYER_ID || GetPVarType(playerid, "CallingPayPhone"))
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang trong cuoc goi.");
		return 1;
	}
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] > 0) {
		if(GetPVarType(playerid, "PayPhone")) PayPhone_EndCall(playerid);
   		return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam viec nay!");
	}
	if(GetPVarType(playerid, "PayPhone")) {
		new i = GetPVarInt(playerid, "PayPhone");
		if(!PayPhone_Valid(i) || gPayPhonesLoading || arrPayPhoneData[i][pp_bPending] || !IsPlayerInDynamicArea(playerid, arrPayPhoneData[i][pp_iAreaID])) return PayPhone_EndCall(playerid), 1;
		new caller = arrPayPhoneData[i][pp_iCallerID];
		if(arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID || caller == playerid || caller < 0 || caller >= MAX_PLAYERS || !IsPlayerConnected(caller)
			|| !GetPVarType(caller, "CallingPayPhone") || GetPVarInt(caller, "CallingPayPhone") != i || Mobile[caller] != INVALID_PLAYER_ID) {
			PayPhone_EndCall(playerid);
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Dien thoai cong cong khong reo hoac dang duoc dung.");
		}
		arrPayPhoneData[i][pp_iUserID] = playerid;
		Mobile[playerid] = caller;
		Mobile[caller] = playerid;
		PayPhone_UpdateTextLabel(i, 2);
		SendClientMessageEx(caller, COLOR_GRAD2, "Co nguoi da nhac may.");
		format(string, sizeof(string), "* %s nghe dien thoai cong cong.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		TogglePlayerControllable(playerid, false);
		SetPlayerAttachedObject(playerid, 8, 330, 6);
		return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	}

	foreach(new i: Player)
	{
		if(Mobile[i] == playerid)
		{
			Mobile[playerid] = i; //caller connecting
			SendClientMessageEx(i,  COLOR_GRAD2, "Nguoi do da nhac may.");
			format(string, sizeof(string), "* %s nghe dien thoai.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RingTone[playerid] = 0;
			SetPlayerAttachedObject(playerid, 8, 330, 6);
			Phone_PickupCall(playerid, i);
			return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		}
	}
	return 1;
}



alias:hangup("h")
CMD:hangup(playerid,params[])
{
	new string[128];
	if(GetPVarInt(playerid, "Injured") != 0||PlayerCuffed[playerid]!=0||PlayerInfo[playerid][pHospital]!=0)
	{
		SendClientMessageEx (playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
		return 1;
	}
	if(GetPVarType(playerid, "Has911Call")) {

		if(GetPVarType(playerid, "PayPhone")) TogglePlayerControllable(playerid, true);
		pc_cmd_cancelcall(playerid, "");
	}
	if(PayPhone_EndCall(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da gac may.");
	new caller = Mobile[playerid];
	if((IsPlayerConnected(caller)/* && caller != INVALID_PLAYER_ID*/))
	{
		if(caller < MAX_PLAYERS)
		{
			if(GetPVarInt(caller, "_UsingJailPhone") == 1)
			{
				TogglePlayerControllable(caller, true);
				DeletePVar(caller, "_UsingJailPhone");
				bJailPhoneUse[GetClosestPrisonPhone(caller)] = false;
			}

			SendClientMessageEx(caller,  COLOR_GRAD2, "Nguoi do da gac may.");
			format(string, sizeof(string), "* %s cat dien thoai.", GetPlayerNameEx(caller));
			ProxDetector(30.0, caller, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			CellTime[caller] = 0;
			Mobile[caller] = INVALID_PLAYER_ID;
		}

		DeletePVar(playerid, "GRPCALL");
		DeletePVar(caller, "GRPCALL");
		DeletePVar(playerid, "BUSICALL");
		DeletePVar(caller, "BUSICALL");
		CellTime[playerid] = 0;
		Phone_HangupCall(playerid, Mobile[playerid]);
		SendClientMessageEx(playerid,  COLOR_GRAD2, "Ban da gac may.");
		format(string, sizeof(string), "* %s cat dien thoai.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		Mobile[playerid] = INVALID_PLAYER_ID;
		CellTime[playerid] = 0;
		RingTone[playerid] = 0;
		RemovePlayerAttachedObject(playerid, 8);
		RemovePlayerAttachedObject(caller, 8);
		SetPlayerSpecialAction(caller, SPECIAL_ACTION_STOPUSECELLPHONE);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
		return 1;
	}
	SendClientMessageEx(playerid,  COLOR_GRAD2, "Dien thoai dang o trong tui.");
	return 1;
}

FetchContact(iReceiverID, iCallerNumber) {

	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT `contactname` FROM `phone_contacts` WHERE `id` = '%d' AND `contactnr` = '%d' LIMIT 1", GetPlayerSQLId(iReceiverID), iCallerNumber);
	mysql_tquery(MainPipeline, szMiscArray, "OnFetchContact", "i", iReceiverID);
}

forward OnFetchContact(iReceiverID);
public OnFetchContact(iReceiverID) {

	new
		iRows,
		szName[MAX_PLAYER_NAME];

	szMiscArray[0] = 0;
	cache_get_row_count(iRows);

	if(!iRows) return 1;
	cache_get_value_name(0, "contactname", szName, MAX_PLAYER_NAME);
	format(szMiscArray, sizeof(szMiscArray), "[CONTACT]: %s", szName);
	ChatTrafficProcess(iReceiverID, COLOR_GRAD1, szMiscArray, 7);
	return 1;
}