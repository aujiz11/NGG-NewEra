/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Mail System

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
#define		MAILBOX_RANGE	8.0

stock SaveMailboxes()
{
	for(new i = 0; i < MAX_MAILBOXES; i++)
	{
		SaveMailbox(i);
	}
	return 1;
}

stock IsAtPostOffice(playerid)
{
	return IsPlayerInRangeOfPoint(playerid,100.0,-262.0643, 6.0924, 2000.9038);
}

stock IsNearHouseMailbox(playerid)
{
	if (PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID && IsPlayerInRangeOfPoint(playerid,3.0,HouseInfo[PlayerInfo[playerid][pPhousekey]][hMailX], HouseInfo[PlayerInfo[playerid][pPhousekey]][hMailY], HouseInfo[PlayerInfo[playerid][pPhousekey]][hMailZ])) return 1;
	if (PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && IsPlayerInRangeOfPoint(playerid,3.0,HouseInfo[PlayerInfo[playerid][pPhousekey2]][hMailX], HouseInfo[PlayerInfo[playerid][pPhousekey2]][hMailY], HouseInfo[PlayerInfo[playerid][pPhousekey2]][hMailZ])) return 1;
	if (PlayerInfo[playerid][pPhousekey3] != INVALID_HOUSE_ID && IsPlayerInRangeOfPoint(playerid,3.0,HouseInfo[PlayerInfo[playerid][pPhousekey3]][hMailX], HouseInfo[PlayerInfo[playerid][pPhousekey3]][hMailY], HouseInfo[PlayerInfo[playerid][pPhousekey3]][hMailZ])) return 1;	
	return 0;
}

stock IsNearPublicMailbox(playerid)
{
    for(new i = 0; i < sizeof(MailBoxes); i++) if (IsPlayerInRangeOfPoint(playerid, 3.0, MailBoxes[i][mbPosX], MailBoxes[i][mbPosY], MailBoxes[i][mbPosZ])) return 1;
	return 0;
}

stock DisplayStampDialog(playerid)
{
	ShowPlayerDialogEx(playerid, DIALOG_POSTAMP, DIALOG_STYLE_LIST, "Mua tem", "Thu thuong		$100\nThu uu tien		$250\nThu cao cap		$500 (Gold VIP+)\nThu cong vu	Mien phi", "Tiep", "Huy");
}

stock RenderHouseMailbox(h)
{
	DestroyDynamicObject(HouseInfo[h][hMailObjectId]);
	DestroyDynamic3DTextLabel(HouseInfo[h][hMailTextID]);
	if (HouseInfo[h][hMailX] != 0.0)
	{
		HouseInfo[h][hMailObjectId] = CreateDynamicObject((HouseInfo[h][hMailType] == 1) ? 1478 : 3407, HouseInfo[h][hMailX], HouseInfo[h][hMailY], HouseInfo[h][hMailZ], 0, 0, HouseInfo[h][hMailA]);
		new string[10];
		format(string, sizeof(string), "HID: %d",h);
		HouseInfo[h][hMailTextID] = CreateDynamic3DTextLabel(string, 0xFFFFFF88, HouseInfo[h][hMailX], HouseInfo[h][hMailY], HouseInfo[h][hMailZ]+0.5,10.0, .streamdistance = 10.0);
	}
}

stock RenderStreetMailbox(id)
{
	DestroyDynamicObject(MailBoxes[id][mbObjectId]);
	DestroyDynamic3DTextLabel(MailBoxes[id][mbTextId]);
	if(MailBoxes[id][mbPosX] != 0.0)
	{
	    new string[128];
		MailBoxes[id][mbObjectId] = CreateDynamicObject(1258, MailBoxes[id][mbPosX], MailBoxes[id][mbPosY], MailBoxes[id][mbPosZ], 0.0, 0.0, MailBoxes[id][mbAngle], MailBoxes[id][mbVW], MailBoxes[id][mbInt], .streamdistance = 100.0);
		format(string,sizeof(string),"Hop thu (ID: %d)\nDung /sendmail de gui thu.", id);
		MailBoxes[id][mbTextId] = CreateDynamic3DTextLabel(string, COLOR_YELLOW, MailBoxes[id][mbPosX], MailBoxes[id][mbPosY], MailBoxes[id][mbPosZ] + 0.5, 10.0, .worldid = MailBoxes[id][mbVW], .testlos = 0, .streamdistance = 25.0);
	}
}

stock HasMailbox(playerid)
{
	if (PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID &&	HouseInfo[PlayerInfo[playerid][pPhousekey]][hMailX] != 0.0) return 1;
	if (PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey2]][hMailX] != 0.0) return 1;
	if (PlayerInfo[playerid][pPhousekey3] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey3]][hMailX] != 0.0) return 1;
	return 0;
}

stock GetFreeMailboxId()
{
    for (new i; i < MAX_MAILBOXES; i++) {
		if (MailBoxes[i][mbPosX] == 0.0) return i;
	}
	return -1;
}

stock ClearHouseMailbox(houseid)
{
	HouseInfo[houseid][hMailX] = 0.0;
	HouseInfo[houseid][hMailY] = 0.0;
	HouseInfo[houseid][hMailZ] = 0.0;
	HouseInfo[houseid][hMailA] = 0.0;
	HouseInfo[houseid][hMailType] = 0;
	SaveHouse(houseid);
}

stock ClearStreetMailbox(boxid)
{
	MailBoxes[boxid][mbVW] = 0;
	MailBoxes[boxid][mbInt] = 0;
	MailBoxes[boxid][mbModel] = 0;
	MailBoxes[boxid][mbPosX] = 0.0;
	MailBoxes[boxid][mbPosY] = 0.0;
	MailBoxes[boxid][mbPosZ] = 0.0;
	MailBoxes[boxid][mbAngle] = 0.0;
	SaveMailbox(boxid);
}

CMD:mailhelp(playerid, params[])
{
	SetPVarInt(playerid, "HelpResultCat0", 7);
	Help_ListCat(playerid, DIALOG_HELPCATOTHER1);
	return 1;
}

CMD:omailhelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Huong dan gui thu");
	SendClientMessageEx(playerid, COLOR_GRAD2, "Ban co the mua giay viet tai bat ky 24/7 nao de gui thu cho ban be");
	SendClientMessageEx(playerid, COLOR_GRAD2, "va dong nghiep du ho co online hay khong. Ban co the gui thu");
	SendClientMessageEx(playerid, COLOR_GRAD2, "tu hop thu cong cong gan nhat hoac hop thu tai nha cua minh.");
	SendClientMessageEx(playerid, COLOR_GRAD2, "Thoi gian chuyen thu tuy thuoc dich vu ban da chon.");
	SendClientMessageEx(playerid, COLOR_GRAD3, "Lenh gui thu: /sendmail /getmail /placemailbox /movemailbox /destroymailbox /postdirectory");
	if(PlayerInfo[playerid][pAdmin] > 3)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Lenh Admin");
	    SendClientMessageEx(playerid, COLOR_GRAD1, "/createmailbox (Tao hop thu cong cong)   /removemailbox [id] (Xoa hop thu cong cong)");
	    SendClientMessageEx(playerid, COLOR_GRAD1, "/gotomailbox [id] (Dich chuyen den hop thu cong cong)    /adestroymailbox [houseid] (Xoa hop thu tai nha)");
	}
	return 1;
}

CMD:sendmail(playerid, params[])
{
	if (!IsNearHouseMailbox(playerid) && !IsAtPostOffice(playerid) && !IsNearPublicMailbox(playerid)) {
    	return SendClientMessageEx(playerid, COLOR_GREY, "Can o buu dien, gan hop thu cong cong hoac hop thu nha ban.");
    }
	if (PlayerInfo[playerid][pPaper] < 1) {
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban da het giay viet. Hay mua them tai 24/7.");
	}
	if(GetPVarInt(playerid, "MailTime") > 0) {
		return SendClientMessageEx(playerid, COLOR_GREY, "Can cho %d giay truoc khi gui thu tiep.", GetPVarInt(playerid, "MailTime"));
	}
	DisplayStampDialog(playerid);
	return 1;
}

CMD:getmail(playerid, params[])
{
	if (!IsNearHouseMailbox(playerid) && !IsAtPostOffice(playerid)) {
	 	return SendClientMessageEx(playerid, COLOR_GREY, "Can o gan buu dien hoac hop thu nha ban.");
	}
	DeletePVar(playerid, "UnreadMails");
	DisplayMails(playerid);
 	return 1;
}

CMD:createmailbox(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
    }

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)	{
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the lam vay khi dang theo doi.");
	}

    new i = GetFreeMailboxId();
	if (i == -1) return	SendClientMessageEx(playerid, COLOR_GRAD1, "Da dat gioi han hop thu cong cong.");

	GetPlayerPos(playerid, MailBoxes[i][mbPosX], MailBoxes[i][mbPosY], MailBoxes[i][mbPosZ]);
	GetPlayerFacingAngle(playerid, MailBoxes[i][mbAngle]);
	MailBoxes[i][mbPosZ] -= 0.30;
	MailBoxes[i][mbInt] = GetPlayerInterior(playerid);
	MailBoxes[i][mbVW] = GetPlayerVirtualWorld(playerid);

	SaveMailbox(i);
	RenderStreetMailbox(i);

	new string[128], area[MAX_ZONE_NAME];
	SendClientMessageEx(playerid, COLOR_GRAD2, "Da tao hop thu cong cong ID %d.", i);
	GetPlayer2DZone(playerid, area, MAX_ZONE_NAME);
	format(string, sizeof(string), "Admin %s has placed street mailbox %d at %s", GetPlayerNameEx(playerid), i, area);
	Log("logs/mail.log", string);

	Streamer_UpdateEx(playerid, MailBoxes[i][mbPosX], MailBoxes[i][mbPosY], MailBoxes[i][mbPosZ]);

	return 1;

}

CMD:removemailbox(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
    }
	new id;
	if(sscanf(params, "d", id)) {
        return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /removemailbox [street mailbox id]");
    }
    if(id < 0 || id >= MAX_MAILBOXES) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "ID hop thu cong cong khong hop le.");
    }
    if(MailBoxes[id][mbPosX] == 0.0) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong tim thay hop thu cong cong co ID nay.");
    }

	ClearStreetMailbox(id);
	RenderStreetMailbox(id);

	new string[128], area[MAX_ZONE_NAME];
	SendClientMessageEx(playerid, COLOR_GRAD2, "Da xoa hop thu cong cong ID %d.", id);
	GetPlayer2DZone(playerid, area, MAX_ZONE_NAME);
	format(string, sizeof(string), "Administrator %s has removed a street mailbox %d, at %s", GetPlayerNameEx(playerid), id, area);
	Log("logs/mail.log", string);

    return 1;
}

CMD:gotomailbox(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
    }
	new id;
	if(sscanf(params, "d", id)) {
        SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotomailbox [street mailbox id]");
        return 1;
    }
    if(id < 0 || id >= MAX_MAILBOXES) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "ID hop thu cong cong khong hop le.");
    }
    if(MailBoxes[id][mbPosX] == 0.0) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong tim thay hop thu cong cong co ID nay.");
    }

	GameTextForPlayer(playerid, "~w~Dang dich chuyen", 5000, 1);
	SetPlayerVirtualWorld(playerid, MailBoxes[id][mbVW]);
	SetPlayerInterior(playerid, MailBoxes[id][mbInt]);
	SetPlayerPos(playerid,MailBoxes[id][mbPosX],MailBoxes[id][mbPosY] - 2.5,MailBoxes[id][mbPosZ]);
	PlayerInfo[playerid][pVW] = MailBoxes[id][mbVW];
	PlayerInfo[playerid][pInt] = MailBoxes[id][mbInt];

    return 1;
}

CMD:placemailbox(playerid, params[])
{
	if (PlayerInfo[playerid][pPhousekey] == INVALID_HOUSE_ID && PlayerInfo[playerid][pPhousekey2] == INVALID_HOUSE_ID && PlayerInfo[playerid][pPhousekey3] == INVALID_HOUSE_ID) {
	    return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong so huu nha!");
	}
	if (PlayerInfo[playerid][pMailbox] < 1) {
	    return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co vat pham hop thu!");
	}
	new style;
	if (sscanf(params, "d", style)) {
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /placemailbox [1 or 2] (1=go 2=thep)");
    }
	if (HasMailbox(playerid)) {
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da dat hop thu, khong the dat them.");
	}
	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) {
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Can di bo de dung lenh nay!");
	}
	new h = InRangeOfWhichHouse(playerid, MAILBOX_RANGE);
	if (h == INVALID_HOUSE_ID) {
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o nha minh!");
	}

	new Float: f_ZOffset;
	if (style == 1) f_ZOffset = -0.38; else if (style == 2) f_ZOffset = -0.95;
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "So khong hop le!");

	PlayerInfo[playerid][pMailbox]--;

	GetPlayerPos(playerid, HouseInfo[h][hMailX], HouseInfo[h][hMailY], HouseInfo[h][hMailZ]);
	GetPlayerFacingAngle(playerid, HouseInfo[h][hMailA]);
	HouseInfo[h][hMailZ] += f_ZOffset;
	HouseInfo[h][hMailType] = style;
	SaveHouse(h);

	RenderHouseMailbox(h);

	SendClientMessageEx(playerid, COLOR_WHITE, "Da dat hop thu thanh cong!");
	SendClientMessageEx(playerid, COLOR_GRAD2, "GOI Y: Dung /movemailbox de doi vi tri hop thu." );

	new szLog[128];
	format(szLog, sizeof(szLog), "%s(%d) has placed a mailbox for their house (House ID: %d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), h);
	Log("logs/house.log", szLog);

	return 1;
}

CMD:destroymailbox(playerid, params[])
{
	if (!HasMailbox(playerid)) {
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua dat hop thu.");
	}
	new h;
	if (PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID && IsPlayerInRangeOfPoint(playerid,3.0,HouseInfo[PlayerInfo[playerid][pPhousekey]][hMailX], HouseInfo[PlayerInfo[playerid][pPhousekey]][hMailY], HouseInfo[PlayerInfo[playerid][pPhousekey]][hMailZ])) h = PlayerInfo[playerid][pPhousekey];
	else if (PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && IsPlayerInRangeOfPoint(playerid,3.0,HouseInfo[PlayerInfo[playerid][pPhousekey2]][hMailX], HouseInfo[PlayerInfo[playerid][pPhousekey2]][hMailY], HouseInfo[PlayerInfo[playerid][pPhousekey2]][hMailZ])) h = PlayerInfo[playerid][pPhousekey2];
	else if (PlayerInfo[playerid][pPhousekey3] != INVALID_HOUSE_ID && IsPlayerInRangeOfPoint(playerid,3.0,HouseInfo[PlayerInfo[playerid][pPhousekey3]][hMailX], HouseInfo[PlayerInfo[playerid][pPhousekey3]][hMailY], HouseInfo[PlayerInfo[playerid][pPhousekey3]][hMailZ])) h = PlayerInfo[playerid][pPhousekey3];
	else return SendClientMessageEx(playerid, COLOR_GREY, "Can dung gan hop thu cua ban.");

	ClearHouseMailbox(h);
	RenderHouseMailbox(h);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da pha huy hop thu.");

	new szLog[128];
	format(szLog, sizeof(szLog), "%s(%d) has destroyed their house mailbox (House ID: %d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), h);
	Log("logs/house.log", szLog);

	return 1;
}

CMD:movemailbox(playerid, params[])
{
	if (!HasMailbox(playerid)) {
   		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dat hop thu.");
   	}
	new h = InRangeOfWhichHouse(playerid, MAILBOX_RANGE);
	if (h == INVALID_HOUSE_ID || HouseInfo[h][hMailX] == 0.0) {
		return SendClientMessageEx(playerid, COLOR_GREY, "Vi tri moi cua hop thu qua xa cua nha ban!");
	}
	GetPlayerPos(playerid, HouseInfo[h][hMailX], HouseInfo[h][hMailY], HouseInfo[h][hMailZ]);
	GetPlayerFacingAngle(playerid, HouseInfo[h][hMailA]);
	new Float: f_ZOffset;
	if (HouseInfo[h][hMailType] == 1) f_ZOffset = -0.38; else if (HouseInfo[h][hMailType] == 2) f_ZOffset = -0.95;
	HouseInfo[h][hMailZ] += f_ZOffset;
	SaveHouse(h);
    RenderHouseMailbox(h);
	SendClientMessageEx(playerid, COLOR_WHITE, "Da di chuyen hop thu thanh cong!");
	return 1;
}

CMD:adestroymailbox(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
        return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
    }
    new houseid;
    if(sscanf(params,"d",houseid)) {
        return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /adestroymailbox [houseid]");
    }
    if (houseid < 0 || houseid >= MAX_HOUSES) {
    	return SendClientMessageEx(playerid, COLOR_GRAD2, "ID nha khong hop le!");
	}
    if (HouseInfo[houseid][hMailX] == 0.0) {
    	return SendClientMessageEx(playerid, COLOR_GRAD2, "Nha nay khong co hop thu.");
	}

    ClearHouseMailbox(houseid);
	RenderHouseMailbox(houseid);

	new string[64];
	SendClientMessageEx(playerid, COLOR_GREY, "Da xoa hop thu cua nha %d.", houseid);
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pPhousekey] == houseid || PlayerInfo[i][pPhousekey2] == houseid || PlayerInfo[i][pPhousekey3] == houseid)	{
			SendClientMessageEx(i, COLOR_GREY, "Admin %s da xoa hop thu cua ban.", GetPlayerNameEx(playerid));
			break;
		}
	}	

	format(string, sizeof(string), "Administrator %s has destroyed the mailbox of house %d.", GetPlayerNameEx(playerid), houseid);
	Log("logs/house.log", string);

	return 1;
}

CMD:postdirectory(playerid, params[])
{
	if (!IsAtPostOffice(playerid)) {
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o buu dien!");
	}
	if(strcmp(params, "on", true) == 0)	{
	    PlayerInfo[playerid][pMailEnabled] = 1;
		SendClientMessage(playerid, COLOR_WHITE, "Da cho phep tra ten ban trong danh ba buu dien.");
    }
    else if(strcmp(params, "off", true) == 0)	{
	    PlayerInfo[playerid][pMailEnabled] = 0;
        SendClientMessage(playerid, COLOR_WHITE, "Da an ten ban khoi danh ba buu dien.");
    }
    else {
	    SendClientMessage(playerid, COLOR_GREY, "CACH DUNG: /postdirectory [on/off]");
    }
	return 1;
}

CMD:mnear(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	SendClientMessageEx(playerid, COLOR_RED, "* Liet ke hop thu trong ban kinh 30 met...");
	for(new i, szMessage[32]; i < MAX_HOUSES; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 30, HouseInfo[i][hMailX], HouseInfo[i][hMailY], HouseInfo[i][hMailZ]))
		{
			format(szMessage, sizeof(szMessage), "ID %d | Cach %f", i, GetPlayerDistanceFromPoint(playerid, HouseInfo[i][hMailX], HouseInfo[i][hMailY], HouseInfo[i][hMailZ]));
			SendClientMessageEx(playerid, COLOR_WHITE, szMessage);
		}
	}
	return 1;
}