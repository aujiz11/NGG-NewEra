/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

    	    		  Point System (Re-done)
    			        by Shane Roberts

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

CMD:getmats(playerid, params[])
{	
	if(!Job_HasJob(playerid, JOB_ARMS_DEALER) && !Job_HasJob(playerid, JOB_CRAFTSMAN)) 
		return SendClientMessageEx(playerid,COLOR_GREY,"   Ban khong phai Arms Dealer hoac Craftsman!");
	
	if(CheckPointCheck(playerid)) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
	
	new point, drank[64], vip = ((0 <= PlayerInfo[playerid][pDonateRank] < 5) ? PlayerInfo[playerid][pDonateRank] : 0);
	switch(vip)
	{
		case 0: drank = "Non-VIP";
		case 1: drank = "Bronze VIP";
		case 2: drank = "Silver VIP";
		case 3: drank = "Gold VIP";
		case 4: drank = "Platinum VIP";
	}
	FetchPoint(playerid, point, (IsABoat(GetPlayerVehicleID(playerid)) ? 15.0 : 3.0));
	if(point == -1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o diem vat lieu!");
	if(DynPoints[point][poType] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem nay khong co tuyen giao vat lieu!");
	if(DynPoints[point][poAmount][vip] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem nay chua dat luong vat lieu cho %s!", drank);
	if(PlayerInfo[playerid][pMats] < 0 || PlayerInfo[playerid][pMats] > cellmax - DynPoints[point][poAmount][vip])
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the mang so vat lieu tu chuyen giao nay.");
	if(DynPoints[point][poPos2][0] == 0.0 || DynPoints[point][poPos2][1] == 0.0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem giao cuoi chua duoc cau hinh!");
	if(DynPoints[point][poBoat] && !IsABoat(GetPlayerVehicleID(playerid))) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban can o tren thuyen!");
	if(vip == 0) {
		if(GetPlayerCash(playerid) < 500) return SendClientMessageEx(playerid, COLOR_RED, "Ban khong du $500 de mua goi vat lieu!");
		GivePlayerCash(playerid, -500);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mua %s goi vat lieu voi gia $500", number_format(DynPoints[point][poAmount][vip]));
	} else {
		if(GetPlayerCash(playerid) < (500 * vip)) return SendClientMessageEx(playerid, COLOR_RED, "Ban khong du $%s de mua goi vat lieu!", number_format((500 * vip)));
		GivePlayerCash(playerid, -(500 * vip));
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mua %s goi vat lieu voi gia $%s", number_format(DynPoints[point][poAmount][vip]), number_format((500 * vip)));
	}
	MatsAmount[playerid] = DynPoints[point][poAmount][vip];
	if(vip > 0) SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "VIP: Ban nhan them goi vat lieu nho %s.", drank);
	MatDeliver[playerid] = point;
	SetPVarInt(playerid, "tpMatRunTimer", 10);
	SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_TPMATRUNTIMER);

	if((0 <= DynPoints[point][poCaptureGroup] < MAX_GROUPS)) arrGroupData[DynPoints[point][poCaptureGroup]][g_iBudget] +=500;

	SetPlayerCheckpoint(playerid, DynPoints[point][poPos2][0], DynPoints[point][poPos2][1], DynPoints[point][poPos2][2], 5);
	return 1;
}

CMD:getdrugs(playerid, params[]) {

	if(!Job_HasJob(playerid, JOB_DRUG_SMUGGLER) && !IsACriminal(playerid)) return SendClientMessageEx(playerid,COLOR_GREY,"  Ban khong phai Drug Smuggler hoac thanh vien family!");
	if(CheckPointCheck(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
	new point, drank[64], vip = ((0 <= PlayerInfo[playerid][pDonateRank] < 5) ? PlayerInfo[playerid][pDonateRank] : 0), string[128];
	switch(vip)
	{
		case 0: drank = "Non-VIP";
		case 1: drank = "Bronze VIP";
		case 2: drank = "Silver VIP";
		case 3: drank = "Gold VIP";
		case 4: drank = "Platinum VIP";
	}
	FetchPoint(playerid, point, (IsABoat(GetPlayerVehicleID(playerid)) ? 15.0 : 3.0));
	if(point == -1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o diem ma tuy!");
	if(DynPoints[point][poType] < 1 || DynPoints[point][poType] > 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem nay khong co tuyen giao ma tuy! (TYPE: %d)", DynPoints[point][poType]);
	if(DynPoints[point][poAmount][vip] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem nay chua dat luong vat lieu cho %s!", drank);
	if(DynPoints[point][poPos2][0] == 0.0 || DynPoints[point][poPos2][1] == 0.0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem giao cuoi chua duoc cau hinh!");
	if(DynPoints[point][poBoat] && !IsABoat(GetPlayerVehicleID(playerid))) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban can o tren thuyen!");

	if(DynPoints[point][poType] == 1) { // Pot
		if(GetPlayerMoney(playerid) < 2000) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du $2,000!");
		GivePlayerCashEx(playerid, TYPE_ONHAND, -2000);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mua %sg goi pot voi gia $2,000", number_format(DynPoints[point][poAmount][vip]));
	}
	if(DynPoints[point][poType] == 2) { // Crack
		if(GetJobLevel(playerid, JOB_DRUG_SMUGGLER) < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can Drug Smuggler cap hai tro len de chay tuyen nay!");
		if(GetPlayerMoney(playerid) < 10000) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du $10,000!");
		GivePlayerCashEx(playerid, TYPE_ONHAND, -10000);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mua %sg goi crack voi gia $10,000!", number_format(DynPoints[point][poAmount][vip]));
	}
	if(DynPoints[point][poType] == 3) { // Meth
		if(PlayerInfo[playerid][pDrugSmuggler] < 200) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can Drug Smuggler cap bon tro len de chay tuyen nay!");
		if(GetPlayerMoney(playerid) < 25000) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du $25,000!");
		GivePlayerCashEx(playerid, TYPE_ONHAND, -25000);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mua %sg goi meth voi gia $25,000!", number_format(DynPoints[point][poAmount][vip]));
	}
	if(DynPoints[point][poType] == 4) { // Ecstasy
		if(GetJobLevel(playerid, JOB_DRUG_SMUGGLER) < 5) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can Drug Smuggler cap nam tro len de chay tuyen nay!");
		if(GetPlayerMoney(playerid) < 50000) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du $50,000!");
		GivePlayerCashEx(playerid, TYPE_ONHAND, -50000);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mua %sg goi ecstasy voi gia $50,000!", number_format(DynPoints[point][poAmount][vip]));
	}
	format(string, sizeof(string), "* %s lay mot goi ma tuy.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	MatsAmount[playerid] = DynPoints[point][poAmount][vip];
	MatDeliver[playerid] = point;
	if(vip > 0) SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "VIP: Ban nhan them goi hang nho %s.", drank);
	SetPlayerCheckpoint(playerid, DynPoints[point][poPos2][0], DynPoints[point][poPos2][1], DynPoints[point][poPos2][2], 5);
	SetPVarInt(playerid, "tpMatRunTimer", 10);
	SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_TPMATRUNTIMER);
	return 1;
}

CMD:pointtime(playerid, params[])
{
	new point;
	if(sscanf(params, "i", point)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /pointtime [pointid]");
	if((1 <= point <= MAX_POINTS)) {
		if(strcmp(DynPoints[point-1][poName], "NULL", true) == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem nay chua duoc cau hinh chinh thuc!");
		if(DynPoints[point-1][poCapturable] != 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "%s chua san sang bi chiem.", DynPoints[point-1][poName]);
		if(!DynPoints[point-1][poTimeLeft]) return SendClientMessageEx(playerid, COLOR_GRAD1, "%s hien khong bi chiem!", DynPoints[point-1][poName]);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Diem nay dang bi chiem boi: %s | Con lai: %d phut", arrGroupData[DynPoints[point-1][poCapperGroup]][g_szGroupName], DynPoints[point-1][poTimeLeft]);
	} else {
		SendClientMessageEx(playerid, COLOR_GRAD1, "ID diem khong hop le - Chi duoc chon tu 1 - %d!", MAX_POINTS);
	}
	return 1;
}

CMD:gotodpoint(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
		new pid;
		if(sscanf(params, "d", pid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotodpoint [number]");
		if((1 <= pid <= MAX_POINTS)) {
			if(DynPoints[pid-1][poPos][0] == 0.0 || DynPoints[pid-1][poPos][1] == 0.0) return SendClientMessageEx(playerid, COLOR_GRAD1, "ID diem da chon chua duoc cau hinh!");
			SetPlayerPos(playerid, DynPoints[pid-1][poPos][0], DynPoints[pid-1][poPos][1], DynPoints[pid-1][poPos][2]);
			PlayerInfo[playerid][pInt] = DynPoints[pid-1][poInt];
			SetPlayerInterior(playerid,DynPoints[pid-1][poInt]);
			PlayerInfo[playerid][pVW] = DynPoints[pid-1][poVW];
	  		SetPlayerVirtualWorld(playerid,DynPoints[pid-1][poVW]);
			GameTextForPlayer(playerid, "~w~Dang dich chuyen", 5000, 1);
		} else {
			SendClientMessageEx(playerid, COLOR_GRAD1, "ID diem khong hop le - Chi duoc chon tu 1 - %d!", MAX_POINTS);
		}
	}
	return 1;
}

CMD:capture(playerid, params[])
{
	new point, string[128];
	if(!IsACriminal(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban phai thuoc to chuc toi pham de lam viec nay!");
	FetchPoint(playerid, point, 1.0);
	if(point == -1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o diem chiem dong!");
	if(PlayerInfo[playerid][pRank] < arrGroupData[PlayerInfo[playerid][pMember]][g_iPointCapRank]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Hang cua ban chua du cao de chiem diem!");
	if(DynPoints[point][poLocked]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem nay khong cho phep chiem!");
	if(DynPoints[point][poCapturable] != 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem nay chua san sang bi chiem!");
	if(DynPoints[point][poCapperGroup] == PlayerInfo[playerid][pMember]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Family cua ban dang xu ly viec chiem diem nay!");
	if(DynPoints[point][poCapping] != INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "Da co nguoi bat dau chiem diem nay!");
	if(GetPlayerPing(playerid) > 500) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the chiem diem voi ping 500+!");

	format(string, sizeof(string), "%s dang co chiem diem (VW: %d).", GetPlayerNameEx(playerid), DynPoints[point][poVW]);
	ProxDetector(70.0, playerid, string, COLOR_RED,COLOR_RED,COLOR_RED,COLOR_RED,COLOR_RED);
	GetPlayerPos(playerid, DynPoints[point][CapturePos][0], DynPoints[point][CapturePos][1], DynPoints[point][CapturePos][2]);

	DynPoints[point][poCapping] = playerid;
	DynPoints[point][poTimeCapLeft] = 10;
	SetTimerEx("ProgressTimer", 1000, false, "d", point);
	return 1;
}

forward ProgressTimer(id);
public ProgressTimer(id)
{
	szMiscArray[0] = 0;
	new Float: x, Float: y, Float: z;
	if(DynPoints[id][poCapping] != INVALID_PLAYER_ID && IsPlayerConnected(DynPoints[id][poCapping])) {
		if(--DynPoints[id][poTimeCapLeft] > 0) {
			format(szMiscArray, sizeof(szMiscArray), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Con %d giay", DynPoints[id][poTimeCapLeft]);
			GameTextForPlayer(DynPoints[id][poCapping], szMiscArray, 1100, 3);
			format(szMiscArray, sizeof(szMiscArray), "%s dang co chiem diem, con lai: %d", GetPlayerNameEx(DynPoints[id][poCapping]), DynPoints[id][poTimeCapLeft]);
			UpdateDynamic3DTextLabelText(DynPoints[id][poTextID], COLOR_RED, szMiscArray);
			SetTimerEx("ProgressTimer", 1000, false, "d", id);
		} else {
			GetPlayerPos(DynPoints[id][poCapping], x, y, z);
			if (DynPoints[id][CapturePos][0] != x || DynPoints[id][CapturePos][1] != y || DynPoints[id][CapturePos][2] != z || GetPVarInt(DynPoints[id][poCapping],"Injured") == 1) {
				SendClientMessageEx(DynPoints[id][poCapping], COLOR_LIGHTBLUE, "Chiem that bai. Ban da di chuyen hoac chet trong luc chiem.");
				DynPoints[id][poCapping] = INVALID_PLAYER_ID;
				DynPoints[id][poTimeCapLeft] = 0;
				UpdatePoint(id);
				return 1;
			}
			if(DynPoints[id][poCapturable] < 1)
			{
			    SendClientMessageEx(DynPoints[id][poCapping], COLOR_LIGHTBLUE, "Chiem that bai. Diem nay da bi chiem.");
				DynPoints[id][poCapping] = INVALID_PLAYER_ID;
				DynPoints[id][poTimeCapLeft] = 0;
				UpdatePoint(id);
				return 1;
			}
			if(playerTabbed[DynPoints[id][poCapping]] != 0)
			{
			    SendClientMessageEx(DynPoints[id][poCapping], COLOR_LIGHTBLUE, "Chiem that bai. Ban da alt-tab.");
			    format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) co the da alt-tab de chiem diem.", GetPlayerNameEx(DynPoints[id][poCapping]), DynPoints[id][poCapping]);
				ABroadCast( COLOR_YELLOW, szMiscArray, 2 );
   				DynPoints[id][poCapping] = INVALID_PLAYER_ID;
				DynPoints[id][poTimeCapLeft] = 0;
				UpdatePoint(id);
			    return 1;
			}
			if(GetPlayerVirtualWorld(DynPoints[id][poCapping]) != DynPoints[id][poVW] || GetPlayerInterior(DynPoints[id][poCapping]) != DynPoints[id][poInt])
			{
			    SendClientMessageEx(DynPoints[id][poCapping], COLOR_LIGHTBLUE, "Chiem that bai. Ban khong o dung virtual world/interior cua diem.");
			    format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) co the da tu gay desync de chiem diem.", GetPlayerNameEx(DynPoints[id][poCapping]), DynPoints[id][poCapping]);
				ABroadCast( COLOR_YELLOW, szMiscArray, 2 );
   				DynPoints[id][poCapping] = INVALID_PLAYER_ID;
				DynPoints[id][poTimeCapLeft] = 0;
				UpdatePoint(id);
			    return 1;
			}
			if(!IsACriminal(DynPoints[id][poCapping])) {
			    SendClientMessageEx(DynPoints[id][poCapping], COLOR_LIGHTBLUE, "Chiem that bai. Ban da roi hoac bi duoi khoi to chuc!");
				DynPoints[id][poCapping] = INVALID_PLAYER_ID;
				DynPoints[id][poTimeCapLeft] = 0;
				UpdatePoint(id);
				return 1;
			}
			new fam = PlayerInfo[DynPoints[id][poCapping]][pMember];
			DynPoints[id][poPName] = GetPlayerNameEx(DynPoints[id][poCapping]);

			if(IsValidDynamicPickup(DynPoints[id][poPickupID])) DestroyDynamicPickup(DynPoints[id][poPickupID]);
			DynPoints[id][poPickupID] = CreateDynamicPickup(1313, 23, DynPoints[id][poPos][0], DynPoints[id][poPos][1], DynPoints[id][poPos][2], .worldid = DynPoints[id][poVW], .interiorid = DynPoints[id][poInt]);
		   	format(szMiscArray, sizeof(szMiscArray), "%s da bat dau chiem %s cho %s, diem se thuoc ho sau 10 phut.", DynPoints[id][poPName], DynPoints[id][poName], arrGroupData[fam][g_szGroupName]);
			foreach(new i: Player) ChatTrafficProcess(i, COLOR_YELLOW, szMiscArray, CHAT_POINTS);
			UpdateDynamic3DTextLabelText(DynPoints[id][poTextID], COLOR_YELLOW, szMiscArray);

			DynPoints[id][poCapping] = INVALID_PLAYER_ID;
			DynPoints[id][poTimeCapLeft] = 0;
			DynPoints[id][poCapperGroup] = fam;
			DynPoints[id][poTimeLeft] = 10;
			if(DynPoints[id][CapTimer] != 0) KillTimer(DynPoints[id][CapTimer]);
			DynPoints[id][CapTimer] = SetTimerEx("CaptureTimer", 60000, true, "d", id);
		}
	} else {
		DynPoints[id][poCapping] = INVALID_PLAYER_ID;
		DynPoints[id][poTimeCapLeft] = 0;
		UpdatePoint(id);
	}
	return 1;
}

forward CaptureTimer(id);
public CaptureTimer(id)
{
	szMiscArray[0] = 0;
	if(--DynPoints[id][poTimeLeft] > 0) {
		format(szMiscArray, sizeof(szMiscArray), "%s da bat dau chiem %s cho %s, diem se thuoc ho sau %d phut!", DynPoints[id][poPName], DynPoints[id][poName], arrGroupData[DynPoints[id][poCapperGroup]][g_szGroupName], DynPoints[id][poTimeLeft]);
		UpdateDynamic3DTextLabelText(DynPoints[id][poTextID], COLOR_YELLOW, szMiscArray);
	} else {
		format(szMiscArray, sizeof(szMiscArray), "%s da chiem duoc %s cho %s.", DynPoints[id][poPName], DynPoints[id][poName], arrGroupData[DynPoints[id][poCapperGroup]][g_szGroupName]);
		foreach(new i: Player) ChatTrafficProcess(i, COLOR_YELLOW, szMiscArray, CHAT_POINTS);
		DynPoints[id][poCaptureGroup] = DynPoints[id][poCapperGroup];
		DynPoints[id][poCapperGroup] = INVALID_GROUP_ID;
		strmid(DynPoints[id][poCaptureName], DynPoints[id][poPName], 0, 32, 32);
		DynPoints[id][poTimeLeft] = 0;
		DynPoints[id][poCapturable] = 0;
		DynPoints[id][poTimer] = 25;
		KillTimer(DynPoints[id][CapTimer]);
		DynPoints[id][CapTimer] = 0;
		UpdatePoint(id);
		SavePoint(id);
	}
	return 1;
}

stock FetchPoint(playerid, &point, Float:range)
{
	point = -1;
    for(new p = 0; p < MAX_POINTS; p++)
    {
 	    if(IsPlayerInRangeOfPoint(playerid,range,DynPoints[p][poPos][0], DynPoints[p][poPos][1], DynPoints[p][poPos][2]))
		{
			if(GetPlayerVirtualWorld(playerid) == DynPoints[p][poVW] && GetPlayerInterior(playerid) == DynPoints[p][poInt]) {
				point = p;
			}
			break;
	    }
 	}
}

CMD:points(playerid, params[])
{
	szMiscArray[0] = 0;

	for(new i; i < MAX_POINTS; i++)
	{
		if(strcmp(DynPoints[i][poName], "NULL", true) != 0) {
			if(DynPoints[i][poID] != 0)
			{
				if (DynPoints[i][poType] >= 0)
				{
					if(DynPoints[i][poLocked] != 1)
					{
						if((0 <= DynPoints[i][poCaptureGroup] < MAX_GROUPS)) {
							format(szMiscArray, sizeof(szMiscArray), "ID diem: %d | Ten: %s | Chu: %s | Nguoi chiem: %s | Gio: %d", DynPoints[i][poID], DynPoints[i][poName],arrGroupData[DynPoints[i][poCaptureGroup]][g_szGroupName],DynPoints[i][poCaptureName],DynPoints[i][poTimer]);
						}
						else {
							format(szMiscArray, sizeof(szMiscArray), "ID diem: %d | Ten: %s | Chu: Khong co | Nguoi chiem: Khong co | Gio: %d", DynPoints[i][poID], DynPoints[i][poName], DynPoints[i][poTimer]);
						}
						SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
					}
				}
			}
		}
	}
	return 1;
}

CMD:editpoint(playerid, params[])
{
	if(PlayerInfo[playerid][pFactionModerator] >= 2 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
		ListPoints(playerid);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

ListPoints(playerid) {

	new szDialogStr[MAX_POINTS * 25], i;

	while(i < MAX_POINTS) 
	{
		if(strcmp(DynPoints[i][poName], "NULL", true) != 0)
			format(szDialogStr, sizeof szDialogStr, "%s\n(%i) %s{FFFFFF}", szDialogStr, i + 1, DynPoints[i][poName]);
		else
			format(szDialogStr, sizeof szDialogStr, "%s\n(%i) (trong)", szDialogStr, i + 1);
		++i;
	}
	return ShowPlayerDialogEx(playerid, DIALOG_LISTPOINTS, DIALOG_STYLE_LIST, "Sua diem", szDialogStr, "Chon", "Huy");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	new szDialogStr[1256];
	switch(dialogid)
	{
		case DIALOG_LISTPOINTS:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0 .. MAX_POINTS:
				{
					SetPVarInt(playerid, "pEditingPoint", listitem);
					format(szDialogStr, sizeof szDialogStr, "Ten: %s\n\
						Loai: %s\n\
						Sua vi tri ngoai/trong\n\
						Luong moi gio (%s)\n\
						Sua goi giao hang\n\
						Sua thoi gian chiem\n\
						Chi dung thuyen (%s)\n\
						Khoa (%s)\n\
						Dat lai\n\
						Xoa", DynPoints[listitem][poName],
						PointTypeToName(DynPoints[listitem][poType]),
						number_format(DynPoints[listitem][poAmountHour]),
						(DynPoints[listitem][poBoat]) ? ("Co") : ("Khong"),
						(DynPoints[listitem][poLocked]) ? ("Co") : ("Khong")
						);
					ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT, DIALOG_STYLE_LIST, "Sua diem", szDialogStr, "Chon", "Huy");
				}
			}
		}
		case DIALOG_EDITPOINT:
		{
			if(!response) return 1;
			szMiscArray[0] = 0;
			switch(listitem)
			{
				case 0:
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_NAME, DIALOG_STYLE_INPUT, "Sua diem - Ten", "Nhap ten moi cho diem.", "Chon", "Huy");
				}
				case 1:
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_TYPE, DIALOG_STYLE_LIST, "Sua diem - Loai", "Materials\nPot\nCrack\nMeth\nEcstasy", "Chon", "Huy");
				}
				case 2:
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_POSITION, DIALOG_STYLE_LIST, "Sua diem - Vi tri", "Diem lay hang\nDiem giao hang", "Chon", "Huy");
				}
				case 3:
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_MATERIALS, DIALOG_STYLE_INPUT, "Sua diem - Luong moi gio", "Nhap luong diem nay cung cap moi gio cho to chuc so huu.", "Chon", "Huy");
				}
				case 4:
				{
					if(!response) return ResetDialog(playerid);
					format(szDialogStr, sizeof szDialogStr, "Goi Non-VIP (%s)\n\
						Goi Bronze VIP (%s)\n\
						Goi Silver VIP (%s)\n\
						Goi Gold VIP (%s)\n\
						Goi Platinum VIP (%s)", 
						number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][0]),
						number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][1]),
						number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][2]),
						number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][3]),
						number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][4])
						);
					ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_MATVIPLIST, DIALOG_STYLE_LIST, "Sua diem - Sua goi giao hang", szDialogStr, "Chon", "Huy");
				}
				case 5:
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_CAPTIME, DIALOG_STYLE_INPUT, "Sua diem - Hen gio chiem", "Nhap thoi gian (gio) truoc khi duoc chiem diem.\nDat 0 se thong bao diem san sang bi chiem!", "Chon", "Huy");
				}
				case 6:
				{
					switch(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poBoat])
					{
						case 0: DynPoints[GetPVarInt(playerid, "pEditingPoint")][poBoat] = 1;
						case 1: DynPoints[GetPVarInt(playerid, "pEditingPoint")][poBoat] = 0;
					}
					ResetDialog(playerid);
					SavePoint(GetPVarInt(playerid, "pEditingPoint"));
				}
				case 7:
				{
					switch(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poLocked])
					{
						case 0: DynPoints[GetPVarInt(playerid, "pEditingPoint")][poLocked] = 1;
						case 1: DynPoints[GetPVarInt(playerid, "pEditingPoint")][poLocked] = 0;
					}
					UpdatePoint(GetPVarInt(playerid, "pEditingPoint"));
					ResetDialog(playerid);
					SavePoint(GetPVarInt(playerid, "pEditingPoint"));
				}
				case 8:
				{
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poTimer] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCapturable] = 1;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCaptureGroup] = INVALID_GROUP_ID;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poTimeLeft] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poTimeCapLeft] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapturePos][0] = 0.00000;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapturePos][1] = 0.00000;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapturePos][2] = 0.00000;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCapperGroup] = INVALID_GROUP_ID;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCapping] = INVALID_PLAYER_ID;
					format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPName], MAX_PLAYER_NAME, "No One");
					if(DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapTimer] != 0) KillTimer(DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapTimer]);
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapTimer] = 0;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Da dat lai hen gio chiem / chu cua %s.", DynPoints[GetPVarInt(playerid, "pEditingPoint")][poName]);
					UpdatePoint(GetPVarInt(playerid, "pEditingPoint"));
					SavePoint(GetPVarInt(playerid, "pEditingPoint"));
					ResetDialog(playerid);
				}
				case 9:
				{
					for(new p; p < 3; p++)
					{
						DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos][p] = 0.00000;
						DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos2][p] = 0.00000;
						DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapturePos][p] = 0.00000;
					}
					for(new m; m < 5; m++)
					{
						DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][m] = 0;
					}
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poLocked] = 1;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmountHour] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poInt] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][po2Int] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poVW] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][po2VW] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poTimer] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCapturable] = 1;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCaptureGroup] = INVALID_GROUP_ID;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poTimeLeft] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poTimeCapLeft] = 0;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCapperGroup] = INVALID_GROUP_ID;
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCapping] = INVALID_PLAYER_ID;
					format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPName], MAX_PLAYER_NAME, "No One");
					if(DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapTimer] != 0) KillTimer(DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapTimer]);
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][CapTimer] = 0;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Da xoa diem: %s.", DynPoints[GetPVarInt(playerid, "pEditingPoint")][poName]);
					format(szMiscArray, sizeof(szMiscArray), "%s has deleted point ID: %d", GetPlayerNameEx(playerid), GetPVarInt(playerid, "pEditingPoint"));
					Log("logs/editpoint.log", szMiscArray);
					format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poName], MAX_PLAYER_NAME, "NULL");
					UpdatePoint(GetPVarInt(playerid, "pEditingPoint"));
					SavePoint(GetPVarInt(playerid, "pEditingPoint"));
					ResetDialog(playerid);
				}
			}
		}
		case DIALOG_EDITPOINT_NAME:
		{
			szMiscArray[0] = 0;
			if(!response) return ResetDialog(playerid);

			if(strlen(inputtext) > 24) return ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_NAME, DIALOG_STYLE_INPUT, "Sua diem - Ten", "Nhap ten moi cho diem.\n\nTen phai duoi 25 ky tu.", "Chon", "Huy"); 
			strcpy(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poName], (isnull(inputtext) ? "NULL" : inputtext), 24);
			format(szMiscArray, sizeof(szMiscArray), "%s has edited point %d's name to %s", GetPlayerNameEx(playerid), GetPVarInt(playerid, "pEditingPoint"), inputtext);
			Log("logs/editpoint.log", szMiscArray);
			ResetDialog(playerid);
			UpdatePoint(GetPVarInt(playerid, "pEditingPoint"));
			SavePoint(GetPVarInt(playerid, "pEditingPoint"));
		}
		case DIALOG_EDITPOINT_TYPE:
		{
			szMiscArray[0] = 0;
			if(!response) return ResetDialog(playerid);
			switch(listitem)
			{
				case 0 .. 4:
				{
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poType] = listitem;
					format(szMiscArray, sizeof(szMiscArray), "%s has edited point %d's type to %s.", GetPlayerNameEx(playerid), GetPVarInt(playerid, "pEditingPoint"), PointTypeToName(listitem));
					Log("logs/editpoint.log", szMiscArray);
					SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi loai diem %d thanh %s", GetPVarInt(playerid, "pEditingPoint"), PointTypeToName(listitem));
					ResetDialog(playerid);
					UpdatePoint(GetPVarInt(playerid, "pEditingPoint"));
					SavePoint(GetPVarInt(playerid, "pEditingPoint"));
				}
			}
		}
		case DIALOG_EDITPOINT_POSITION:
		{
			new Float: pvPos[3];
			GetPlayerPos(playerid, pvPos[0], pvPos[1], pvPos[2]);
			if(!response) return ResetDialog(playerid);
			switch(listitem)
			{
				case 0:
				{
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos][0] = pvPos[0];
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos][1] = pvPos[1];
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos][2] = pvPos[2];
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poVW] = GetPlayerVirtualWorld(playerid);
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poInt] = GetPlayerInterior(playerid);
					SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi vi tri mac dinh cua diem.");
					SavePoint(GetPVarInt(playerid, "pEditingPoint"));
				}
				case 1:
				{
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos2][0] = pvPos[0];
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos2][1] = pvPos[1];
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][poPos2][2] = pvPos[2];
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][po2VW] = GetPlayerVirtualWorld(playerid);
					DynPoints[GetPVarInt(playerid, "pEditingPoint")][po2Int] = GetPlayerInterior(playerid);
					SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi diem giao hang cua %s", DynPoints[GetPVarInt(playerid, "pEditingPoint")][poName]);
					SavePoint(GetPVarInt(playerid, "pEditingPoint"));
				}
			}
			UpdatePoint(GetPVarInt(playerid, "pEditingPoint"));
			format(szMiscArray, sizeof(szMiscArray), "%s has edited point %d's position %d amount to X: %f, Y: %f, Z: %f, VW: %d", GetPlayerNameEx(playerid), GetPVarInt(playerid, "pEditingPoint"), listitem, pvPos[0], pvPos[0], pvPos[0], GetPlayerVirtualWorld(playerid));
			Log("logs/editpoint.log", szMiscArray);
		}
		case DIALOG_EDITPOINT_MATERIALS:
		{
			szMiscArray[0] = 0;
			if(!response) return ResetDialog(playerid);
			if(!IsNumericString(inputtext) || strval(inputtext) < 0) return ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_MATERIALS, DIALOG_STYLE_INPUT, "Sua diem - Luong moi gio", "Nhap luong diem nay cung cap moi gio cho to chuc so huu.\n\nNhap so nguyen tu 0 tro len.", "Chon", "Huy");

			DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmountHour] = strval(inputtext);

			format(szMiscArray, sizeof(szMiscArray), "%s has edited point %d's per hour amount to %d", GetPlayerNameEx(playerid), GetPVarInt(playerid, "pEditingPoint"), inputtext);
			Log("logs/editpoint.log", szMiscArray);
			ResetDialog(playerid);
			SavePoint(GetPVarInt(playerid, "pEditingPoint"));
		}
		case DIALOG_EDITPOINT_MATVIPLIST:
		{
			if(response) {
				SetPVarInt(playerid, "pEditingVIPPoint", listitem);
				ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_MATVIPSET, DIALOG_STYLE_INPUT, "Sua diem - Goi hang", "Nhap so luong goi hang cung cap moi chuyen giao.", "Chon", "Huy");
			} else {
				ResetDialog(playerid);
			}
		}
		case DIALOG_EDITPOINT_CAPTIME:
		{
			szMiscArray[0] = 0;
			if(!response) return ResetDialog(playerid);
			if(!IsNumericString(inputtext) || strval(inputtext) < 0) return ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_CAPTIME, DIALOG_STYLE_INPUT, "Sua diem - Hen gio chiem", "Nhap thoi gian (gio) truoc khi duoc chiem diem.\nDat 0 se thong bao diem san sang bi chiem!\n\nNhap so nguyen tu 0 tro len.", "Chon", "Huy");
			DynPoints[GetPVarInt(playerid, "pEditingPoint")][poCapturable] = (strval(inputtext) == 0 ? 1 : 0);
			DynPoints[GetPVarInt(playerid, "pEditingPoint")][poTimer] = strval(inputtext);
			format(szMiscArray, sizeof(szMiscArray), "%s has edited point %d's capturable timer to %d", GetPlayerNameEx(playerid), GetPVarInt(playerid, "pEditingPoint"), inputtext);
			Log("logs/editpoint.log", szMiscArray);
			ResetDialog(playerid);
			UpdatePoint(GetPVarInt(playerid, "pEditingPoint"));
			SavePoint(GetPVarInt(playerid, "pEditingPoint"));
		}
		case DIALOG_EDITPOINT_MATVIPSET:
		{
			if(response) {
				if(!IsNumericString(inputtext) || strval(inputtext) < 1) return ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_MATVIPSET, DIALOG_STYLE_INPUT, "Sua diem - Goi hang", "Nhap so luong goi hang cung cap moi chuyen giao.\n\nNhap so nguyen tu 0 tro len.", "Chon", "Huy");
				new drank[16];
				szMiscArray[0] = 0;
				switch(GetPVarInt(playerid, "pEditingVIPPoint"))
				{
					case 0: drank = "Non-VIP";
					case 1: drank = "Bronze VIP";
					case 2: drank = "Silver VIP";
					case 3: drank = "Gold VIP";
					case 4: drank = "Platinum VIP";
				}
				DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][GetPVarInt(playerid, "pEditingVIPPoint")] = strval(inputtext);
				DeletePVar(playerid, "pEditingVIPPoint");
				SavePoint(GetPVarInt(playerid, "pEditingPoint"));
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da dat %s nhan %s moi chuyen giao!", drank, number_format(strval(inputtext)));
				format(szMiscArray, sizeof(szMiscArray), "%s has edited point %d's delivery package to %s for %s.", GetPlayerNameEx(playerid), GetPVarInt(playerid, "pEditingPoint"), number_format(strval(inputtext)), drank);
				Log("logs/editpoint.log", szMiscArray);
				format(szDialogStr, sizeof szDialogStr, "Goi Non-VIP (%s)\n\
					Goi Bronze VIP (%s)\n\
					Goi Silver VIP (%s)\n\
					Goi Gold VIP (%s)\n\
					Goi Platinum VIP (%s)", 
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][0]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][1]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][2]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][3]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][4])
					);
				ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_MATVIPLIST, DIALOG_STYLE_LIST, "Sua diem - Sua goi giao hang", szDialogStr, "Chon", "Huy");
			} else {
				format(szDialogStr, sizeof szDialogStr, "Goi Non-VIP (%s)\n\
					Goi Bronze VIP (%s)\n\
					Goi Silver VIP (%s)\n\
					Goi Gold VIP (%s)\n\
					Goi Platinum VIP (%s)", 
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][0]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][1]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][2]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][3]),
					number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmount][4])
					);
				ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT_MATVIPLIST, DIALOG_STYLE_LIST, "Sua diem - Sua goi giao hang", szDialogStr, "Chon", "Huy");
			}
		}
	}
	return 0;
}

stock ResetDialog(playerid) {
	new szDialogStr[1256];
	format(szDialogStr, sizeof szDialogStr, "Ten: %s\n\
		Loai: %s\n\
		Sua vi tri ngoai/trong\n\
		Luong moi gio (%s)\n\
		Sua goi giao hang\n\
		Sua thoi gian chiem\n\
		Chi dung thuyen (%s)\n\
		Khoa (%s)\n\
		Dat lai\n\
		Xoa", DynPoints[GetPVarInt(playerid, "pEditingPoint")][poName],
		PointTypeToName(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poType]),
		number_format(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poAmountHour]),
		(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poBoat]) ? ("Co") : ("Khong"),
		(DynPoints[GetPVarInt(playerid, "pEditingPoint")][poLocked]) ? ("Co") : ("Khong")
		);
	return ShowPlayerDialogEx(playerid, DIALOG_EDITPOINT, DIALOG_STYLE_LIST, "Sua diem", szDialogStr, "Chon", "Huy");
}

PointTypeToName(id)
{
	new type[24];
	switch(id)
	{
		case 0: format(type, 24, "Materials");
		case 1: format(type, 24, "Pot");
		case 2: format(type, 24, "Crack");
		case 3: format(type, 24, "Meth");
		case 4: format(type, 24, "Ecstasy");
	}
	return type;
}

stock SavePoint(point) {
	new szQuery[2048];
	mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `dynpoints` SET \
	`pointname` = '%e', \
	`type` = %d, \
	`posx` = %f, \
	`posy` = %f, \
	`posz` = %f, \
	`pos2x` = %f, \
	`pos2y` = %f, \
	`pos2z` = %f, \
	`vw` = %d, \
	`int` = %d, \
	`vw2` = %d, \
	`int2` = %d, \
	`boatonly` = %d, \
	`capturename` = '%e', \
	`capturegroup` = %d, \
	`ready` = %d, \
	`timer` = %d, \
	`amounthour` = %d, \
	`amount0` = %d, \
	`amount1` = %d, \
	`amount2` = %d, \
	`amount3` = %d, \
	`amount4` = %d, \
	`locked` = %d WHERE `id` = %d",
	DynPoints[point][poName],
	DynPoints[point][poType],
	DynPoints[point][poPos][0],
	DynPoints[point][poPos][1],
	DynPoints[point][poPos][2],
	DynPoints[point][poPos2][0],
	DynPoints[point][poPos2][1],
	DynPoints[point][poPos2][2],
	DynPoints[point][poVW],
	DynPoints[point][poInt],
	DynPoints[point][po2VW],
	DynPoints[point][po2Int],
	DynPoints[point][poBoat],
	DynPoints[point][poCaptureName],
	DynPoints[point][poCaptureGroup],
	DynPoints[point][poCapturable],
	DynPoints[point][poTimer],
	DynPoints[point][poAmountHour],
	DynPoints[point][poAmount][0],
	DynPoints[point][poAmount][1],
	DynPoints[point][poAmount][2],
	DynPoints[point][poAmount][3],
	DynPoints[point][poAmount][4],
	DynPoints[point][poLocked],
	point + 1);
	mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);
}

stock UpdatePoint(id)
{
	new string[256];
	if(IsValidDynamicPickup(DynPoints[id][poPickupID])) DestroyDynamicPickup(DynPoints[id][poPickupID]);
	if(IsValidDynamic3DTextLabel(DynPoints[id][poTextID])) DestroyDynamic3DTextLabel(DynPoints[id][poTextID]);

	if(DynPoints[id][poPos][0] == 0.0) return 1;
	DynPoints[id][poPickupID] = CreateDynamicPickup(((DynPoints[id][poType] == 1) ? 1279 : (DynPoints[id][poType] == 2 || DynPoints[id][poType] == 3 || DynPoints[id][poType] == 4) ? 1241 : 1239), 23, DynPoints[id][poPos][0], DynPoints[id][poPos][1], DynPoints[id][poPos][2], .worldid = DynPoints[id][poVW], .interiorid = DynPoints[id][poInt]);
	switch(DynPoints[id][poType])
	{
		case 0: format(string, sizeof(string), "Diem lay vat lieu (ID: %d)\nDung /getmats de lay vat lieu.", DynPoints[id][poID]);
		case 1: format(string, sizeof(string), "Diem pot (ID: %d)\nDung /getdrugs de lay pot.", DynPoints[id][poID]);
		case 2: format(string, sizeof(string), "Diem crack (ID: %d)\nDung /getdrugs de lay crack.", DynPoints[id][poID]);
		case 3: format(string, sizeof(string), "Diem meth (ID: %d)\nDung /getdrugs de lay meth.", DynPoints[id][poID]);
		case 4: format(string, sizeof(string), "Diem ecstasy (ID: %d)\nDung /getdrugs de lay ecstasy.", DynPoints[id][poID]);
	}
	if(DynPoints[id][poCapturable] && !DynPoints[id][poLocked]) {
		format(string, sizeof(string), "%s\n%s da san sang bi chiem! Dung day va dung /capture de chiem.", string, DynPoints[id][poName]);
	}
	DynPoints[id][poTextID] = CreateDynamic3DTextLabel(string, COLOR_YELLOW, DynPoints[id][poPos][0], DynPoints[id][poPos][1], DynPoints[id][poPos][2]+0.6, 10.0, .testlos = 1, .worldid = DynPoints[id][poVW], .interiorid = DynPoints[id][poInt], .streamdistance = 10.0);
	return 1;
}

stock LoadPoints()
{
	printf("[Dynamic Points] Loading Dynamic Points from the database, please wait...");
	mysql_tquery(MainPipeline, "SELECT * FROM `dynpoints`", "OnLoadPoints", "");
}

forward OnLoadPoints();
public OnLoadPoints()
{
	new i, rows, szField[24];
	cache_get_row_count(rows);

	while(i < rows)
	{
		cache_get_value_name(i, "pointname", DynPoints[i][poName], MAX_PLAYER_NAME);
		cache_get_value_name_int(i, "type", DynPoints[i][poType]);
		cache_get_value_name_int(i, "id", DynPoints[i][poID]);
		cache_get_value_name_float(i, "posx", DynPoints[i][poPos][0]);
		cache_get_value_name_float(i, "posy", DynPoints[i][poPos][1]);
		cache_get_value_name_float(i, "posz", DynPoints[i][poPos][2]);
		cache_get_value_name_float(i, "pos2x", DynPoints[i][poPos2][0]);
		cache_get_value_name_float(i, "pos2y", DynPoints[i][poPos2][1]);
		cache_get_value_name_float(i, "pos2z", DynPoints[i][poPos2][2]);
		cache_get_value_name_int(i, "vw", DynPoints[i][poVW]);
		cache_get_value_name_int(i, "int", DynPoints[i][poInt]);
		cache_get_value_name_int(i, "vw2", DynPoints[i][po2VW]);
		cache_get_value_name_int(i, "int2", DynPoints[i][po2Int]);
		cache_get_value_name_int(i, "boatonly", DynPoints[i][poBoat]);
		cache_get_value_name(i, "capturename", DynPoints[i][poCaptureName], MAX_PLAYER_NAME);
		cache_get_value_name_int(i, "capturegroup", DynPoints[i][poCaptureGroup]);
		cache_get_value_name_int(i, "ready", DynPoints[i][poCapturable]);
		cache_get_value_name_int(i, "timer", DynPoints[i][poTimer]);
		cache_get_value_name_int(i, "amounthour", DynPoints[i][poAmountHour]);
		for(new m; m < 5; m++)
		{
			format(szField, sizeof(szField), "amount%d", m);
			cache_get_value_name_int(i, szField, DynPoints[i][poAmount][m]);
		}
		cache_get_value_name_int(i, "locked", DynPoints[i][poLocked]);
		// Ensure our non-loaded data has something.
		DynPoints[i][poTimeLeft] = 0; // 10 minute timer
		DynPoints[i][poTimeCapLeft] = 0; // 10 second timer
		DynPoints[i][CapturePos][0] = 0.00000;
		DynPoints[i][CapturePos][1] = 0.00000;
		DynPoints[i][CapturePos][2] = 0.00000;
		DynPoints[i][poCapperGroup] = INVALID_GROUP_ID;
		DynPoints[i][poCapping] = INVALID_PLAYER_ID;
		format(DynPoints[i][poPName], MAX_PLAYER_NAME, "No One");
		DynPoints[i][CapTimer] = 0;
		UpdatePoint(i);
		i++;
	}
	if(i > 0) printf("[Dynamic Points] %d dynamic points has been loaded.", i);
	else printf("[Dynamic Points] No dynamic points has been loaded.");
	return 1;
}