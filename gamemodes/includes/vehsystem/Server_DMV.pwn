/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Licensing System

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

#define DMV_MAIN 10026
#define DMVRELEASE_TARGET 10027

new DMVPointArea;

hook OnGameModeInit() {
	CreateDynamic3DTextLabel("Nhan Y de nop phat\nhoac chuoc xe.",COLOR_YELLOW,833.60, 3.23, 1004.17+0.6,4.0);
	DMVPointArea = CreateDynamicSphere(833.60, 3.23, 1004.17, 3.0);

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if(newkeys & KEY_YES) {

		if(IsPlayerInDynamicArea(playerid, DMVPointArea)) ShowDMVMenu(playerid);
		else if(IsPlayerInRangeOfPoint(playerid, 2.0, 833.60, 3.23, 1004.17)) ShowDMVMenu(playerid);
	}
	return 1;
}

CMD:revokelicense(playerid, params[])
{
	if(IsACop(playerid) || (IsAMedic(playerid) && arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 2) || IsAGovernment(playerid) || IsAJudge(playerid))
	{
		new string[128], giveplayerid, type, reason[64], sz_FacInfo[3][64];
		if(sscanf(params, "uds[64]", giveplayerid, type, reason))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /revokelicense [player] [type] [reason]");
			SendClientMessageEx(playerid, COLOR_GRAD2, "Loai: 1 = Lai xe, 2 = Lai thuyen, 3 = Lai may bay, 4 = Giay phep sung");
			return 1;
		}

		if (playerid == giveplayerid) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the thu hoi giay phep cua minh!");

		if((IsPlayerConnected(giveplayerid)) && giveplayerid != INVALID_PLAYER_ID)
		{
			if(GetPVarInt(playerid, "Injured") != 0) return SendClientMessageEx (playerid, COLOR_GRAD2, "Ban khong the lam viec nay luc nay.");
			if(!ProxDetectorS(8.0, playerid, giveplayerid)) return SendClientMessageEx (playerid, COLOR_GRAD2, "Ban khong o gan nguoi do!");
			switch(type)
			{
				case 1:
				{
					if(PlayerInfo[giveplayerid][pCarLic] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay khong co bang lai xe de thu hoi.");

					GetPlayerGroupInfo(playerid, sz_FacInfo[0], sz_FacInfo[1], sz_FacInfo[2]);
					SendClientMessageEx(giveplayerid,COLOR_LIGHTBLUE,"%s da thu hoi bang lai xe cua ban, ly do: %s.", sz_FacInfo[2], reason);
					format(string,sizeof(string),"HQ: %s %s %s da thu hoi bang lai xe cua %s, ly do: %s.", sz_FacInfo[2], sz_FacInfo[0], GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					SendGroupMessage(GROUP_TYPE_LEA,TEAM_BLUE_COLOR,string);
					SendClientMessageEx(playerid,COLOR_WHITE,"Ban da thu hoi bang lai xe cua %s.",GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has taken %s'(%d) driver's license. reason: %s.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), reason);
					Log("logs/licenses.log", string);
					PlayerInfo[giveplayerid][pCarLic] = 0;
					return 1;
				}
				case 2:
				{
					if(PlayerInfo[giveplayerid][pBoatLic] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay khong co bang lai thuyen de thu hoi.");

					GetPlayerGroupInfo(playerid, sz_FacInfo[0], sz_FacInfo[1], sz_FacInfo[2]);
					SendClientMessageEx(giveplayerid,COLOR_LIGHTBLUE,"%s da thu hoi bang lai thuyen cua ban, ly do: %s.", sz_FacInfo[2], reason);
					format(string,sizeof(string),"HQ: %s %s %s da thu hoi bang lai thuyen cua %s, ly do: %s.", sz_FacInfo[2], sz_FacInfo[0], GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					SendGroupMessage(GROUP_TYPE_LEA,TEAM_BLUE_COLOR,string);
					SendClientMessageEx(playerid,COLOR_WHITE,"Ban da thu hoi bang lai thuyen cua %s.",GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has taken %s'(%d) boater's license. reason: %s.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), reason);
					Log("logs/licenses.log", string);
					PlayerInfo[giveplayerid][pBoatLic] = 0;
					return 1;
				}
				case 3:
				{
					if(PlayerInfo[giveplayerid][pFlyLic] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay khong co bang lai may bay de thu hoi.");

					GetPlayerGroupInfo(playerid, sz_FacInfo[0], sz_FacInfo[1], sz_FacInfo[2]);
					SendClientMessageEx(giveplayerid,COLOR_LIGHTBLUE,"%s da thu hoi bang lai may bay cua ban, ly do: %s.", sz_FacInfo[2], reason);
					format(string,sizeof(string),"HQ: %s %s %s thu bang lai may bay cua %s, ly do: %s.", sz_FacInfo[2], sz_FacInfo[0], GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					SendGroupMessage(GROUP_TYPE_LEA,TEAM_BLUE_COLOR,string);
					SendClientMessageEx(playerid,COLOR_WHITE,"Ban da thu hoi bang lai may bay cua %s.",GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has taken %s'(%s) pilot's license. reason: %s.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), reason);
					Log("logs/licenses.log", string);
					PlayerInfo[giveplayerid][pFlyLic] = 0;
					return 1;
				}
				case 4:
				{
					//if((!IsAGovernment(playerid) && PlayerInfo[playerid][pLeader] != 1))) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to revoke this license.");
					if(PlayerInfo[giveplayerid][pGunLic] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay khong co giay phep sung de thu hoi.");

					GetPlayerGroupInfo(playerid, sz_FacInfo[0], sz_FacInfo[1], sz_FacInfo[2]);
					SendClientMessageEx(giveplayerid,COLOR_LIGHTBLUE,"%s da thu hoi giay phep sung cua ban, ly do: %s.", sz_FacInfo[2], reason);
					format(string,sizeof(string),"HQ: %s %s %s da thu hoi giay phep sung cua %s, ly do: %s.", sz_FacInfo[2], sz_FacInfo[0], GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					SendGroupMessage(GROUP_TYPE_LEA,TEAM_BLUE_COLOR,string);
					SendClientMessageEx(playerid,COLOR_WHITE,"Ban da thu hoi giay phep sung cua %s.",GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has taken %s'(%d) firearm's license. reason: %s.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), reason);
					Log("logs/licenses.log", string);
					++GunLicenseRequest[giveplayerid];
					PlayerInfo[giveplayerid][pGunLic] = 0;
					return 1;
				}
			}
		}
		SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
		return 1;
	}
	SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen lam viec nay.");
	return 1;
}

CMD:givelicense(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], giveplayerid, type;
		if(sscanf(params, "ud", giveplayerid, type))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givelicense [player] [type]");
			SendClientMessageEx(playerid, COLOR_GRAD2, "Loai: 1 = Lai xe, 2 = Lai thuyen, 3 = Lai may bay, 4 = Taxi.");
			return 1;
		}

		if(!IsPlayerConnected(giveplayerid))
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
			return 1;
		}

		switch(type)
		{
		case 1:
			{
				if(PlayerInfo[giveplayerid][pCarLic] > 0)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay da co bang lai xe.");
					return 1;
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cap bang lai xe cho %s.",GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "Administrator %s da cap bang lai xe cho ban.",GetPlayerNameEx(playerid));
				format(string, sizeof(string), "Administrator %s has given a driver's license to %s(%d)",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
				Log("logs/licenses.log", string);
				PlayerInfo[giveplayerid][pCarLic] = gettime() + (86400*80);
				return 1;
			}
		case 2:
			{
				if(PlayerInfo[giveplayerid][pBoatLic] == 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay da co bang lai thuyen.");
					return 1;
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cap bang lai thuyen cho %s.",GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "Administrator %s da cap bang lai thuyen cho ban.",GetPlayerNameEx(playerid));
				format(string, sizeof(string), "Administrator %s has given a boating license to %s(%d)",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
				Log("logs/licenses.log", string);
				PlayerInfo[giveplayerid][pBoatLic] = 1;
				return 1;
			}
		case 3:
			{
				if(PlayerInfo[giveplayerid][pFlyLic] == 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay da co bang lai may bay.");
					return 1;
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cap bang lai may bay cho %s.",GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "Administrator %s da cap bang lai may bay cho ban.",GetPlayerNameEx(playerid));
				format(string, sizeof(string), "Administrator %s has given a pilot license to %s(%d)",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
				Log("logs/licenses.log", string);
				PlayerInfo[giveplayerid][pFlyLic] = 1;
				return 1;
			}
		case 4:
			{
				if(PlayerInfo[giveplayerid][pTaxiLicense] == 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay da co giay phep Taxi.");
					return 1;
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cap giay phep Taxi cho %s.",GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "Administrator %s da cap giay phep Taxi cho ban.",GetPlayerNameEx(playerid));
				format(string, sizeof(string), "Administrator %s has given a taxi license to %s(%d)",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
				Log("logs/licenses.log", string);
				PlayerInfo[giveplayerid][pTaxiLicense] = 1;
				return 1;
			}
		default:
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Loai giay phep khong hop le! /givelicense [player] [type]");
				SendClientMessageEx(playerid, COLOR_GRAD2, "Loai: 1 = Lai xe, 2 = Lai thuyen, 3 = Lai may bay, 4 = Taxi.");
			}
		}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:droplicense(playerid, params[])
{
	new type;
	if(sscanf(params, "d", type))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /droplicense [type]");
		SendClientMessageEx(playerid, COLOR_GRAD2, "Loai: 1 = Lai xe, 2 = Lai thuyen, 3 = Lai may bay, 4 = Taxi.");
		return 1;
	}

	switch(type)
	{
		case 1:
		{
			if(PlayerInfo[playerid][pCarLic] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co bang lai xe de huy.");
				return 1;
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy bang lai xe.");
			PlayerInfo[playerid][pCarLic] = 0;
			return 1;
		}
		case 2:
		{
			if(PlayerInfo[playerid][pBoatLic] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co bang lai thuyen de huy.");
				return 1;
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy bang lai thuyen.");
			PlayerInfo[playerid][pBoatLic] = 0;
			return 1;
		}
		case 3:
		{
			if(PlayerInfo[playerid][pFlyLic] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co bang lai may bay de huy.");
				return 1;
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy bang lai may bay.");
			PlayerInfo[playerid][pFlyLic] = 0;
			return 1;
		}
		case 4:
		{
			if(PlayerInfo[playerid][pTaxiLicense] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co giay phep Taxi de huy.");
				return 1;
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy giay phep Taxi.");
			PlayerInfo[playerid][pTaxiLicense] = 0;
			return 1;
		}
		default:
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Loai giay phep khong hop le! /droplicense [type]");
			SendClientMessageEx(playerid, COLOR_GRAD2, "Loai: 1 = Lai xe, 2 = Lai thuyen, 3 = Lai may bay, 4 = Taxi.");
		}
	}
	return 1;
}

CMD:licenses(playerid, params[])
{
	new text1[40], text2[20], text3[20], text4[20], text5[40];
	if(PlayerInfo[playerid][pCarLic] == 0) { text1 = "Chua co"; }
	else { text1 = date(PlayerInfo[playerid][pCarLic], 1); }
	if(PlayerInfo[playerid][pFlyLic]) { text4 = "Da co"; } else { text4 = "Chua co"; }
	if(PlayerInfo[playerid][pBoatLic]) { text2 = "Da co"; } else { text2 = "Chua co"; }
	if(PlayerInfo[playerid][pTaxiLicense]) { text3 = "Da co"; } else { text3 = "Chua co"; }
	if(PlayerInfo[playerid][pGunLic] == 0) {text5 = "Chua co"; }
	else {text5 = date(PlayerInfo[playerid][pGunLic], 1);}
	SendClientMessageEx(playerid, COLOR_WHITE, "Giay phep cua ban...");
	SendClientMessageEx(playerid, COLOR_GREY, "** Bang lai xe: %s.", text1);
	SendClientMessageEx(playerid, COLOR_GREY, "** Bang lai Pilot: %s.", text4);
	SendClientMessageEx(playerid, COLOR_GREY, "** Bang lai thuyen: %s.", text2);
	SendClientMessageEx(playerid, COLOR_GREY, "** Giay phep Taxi: %s.", text3);
	SendClientMessageEx(playerid, COLOR_GREY, "** Giay phep sung SA: %s.", text5);
	return 1;
}



alias:showlicenses("showid")
CMD:showlicenses(playerid, params[])
{
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /showlicenses [player]");

	if(IsPlayerConnected(giveplayerid))
	{
		if (ProxDetectorS(8.0, playerid, giveplayerid))
		{
			if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the dua giay phep cho chinh minh, dung /licenses de xem."); return 1; }
			new text1[40], text2[20], text3[20], text4[20], text5[40];
			if(PlayerInfo[playerid][pCarLic] == 0) { text1 = "Chua co"; }
			else { text1 = date(PlayerInfo[playerid][pCarLic], 1); }
			if(PlayerInfo[playerid][pFlyLic]) { text4 = "Da co"; } else { text4 = "Chua co"; }
			if(PlayerInfo[playerid][pBoatLic]) { text2 = "Da co"; } else { text2 = "Chua co"; }
			if(PlayerInfo[playerid][pTaxiLicense]) { text3 = "Da co"; } else { text3 = "Chua co"; }
			if(PlayerInfo[playerid][pGunLic] == 0) {text5 = "Chua co"; }
			else {text5 = date(PlayerInfo[playerid][pGunLic], 1);}

			switch(PlayerInfo[playerid][pNation])
			{
				case 0:	SendClientMessageEx(giveplayerid, COLOR_WHITE, "** Cong dan San Andreas **");
				case 1: SendClientMessageEx(giveplayerid, COLOR_TR, "** Cong dan New Robada **");
				default: SendClientMessageEx(giveplayerid, COLOR_TR, "** Khong co quoc tich **");
			}
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Danh sach giay phep cua %s...", GetPlayerNameEx(playerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ngay sinh: %s", PlayerInfo[playerid][pBirthDate]);
			SendClientMessageEx(giveplayerid, COLOR_GREY, "** Bang lai xe: %s.", text1);
			SendClientMessageEx(giveplayerid, COLOR_GREY, "** Bang lai Pilot: %s.", text4);
			SendClientMessageEx(giveplayerid, COLOR_GREY, "** Bang lai thuyen: %s.", text2);
			SendClientMessageEx(giveplayerid, COLOR_GREY, "** Giay phep Taxi: %s.", text3);
			SendClientMessageEx(giveplayerid, COLOR_GREY, "** Giay phep sung SA: %s.", text5);
			SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s da dua giay phep cho ban xem.", GetPlayerNameEx(playerid));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da dua giay phep cho %s xem.", GetPlayerNameEx(giveplayerid));
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
			return 1;
		}

	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		return 1;
	}
	return 1;
}

ShowDMVMenu(playerid, menu = 0, iTargetID = INVALID_PLAYER_ID) {
	new vehicleName[18];

	switch(menu) {

		case 0: { // main DMV menu
			if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && MAX_GROUP_RANKS > PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iDMVAccess]) format(szMiscArray, sizeof(szMiscArray), "Nop phat\nGia han bang lai ($10,000)\nGiay phep khac\nChuoc xe");
			if(PlayerInfo[playerid][pCarLic] == 0 || PlayerInfo[playerid][pLevel] < 2) format(szMiscArray, sizeof(szMiscArray), "Nop phat\nThi lai xe\nGiay phep khac");
			else format(szMiscArray, sizeof(szMiscArray), "Nop phat\nGia han bang lai xe\nMua giay phep khac\n[LEO only] Chuoc xe bi tam giu");
			return ShowPlayerDialogEx(playerid, DMV_MAIN, DIALOG_STYLE_LIST, "Menu chinh DMV", szMiscArray, "Chon", "Huy");



		}
		case 1: { // this is the old /dmvmenu migrated to use the new system
			new icount, icountz = GetPlayerVehicleSlots(playerid);

			if(PlayerInfo[playerid][pFreezeCar] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the lam viec nay khi tai san dang bi dong bang!");
			if(PlayerInfo[playerid][pCarLic] < gettime()) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban can bang lai xe con han de chuoc xe hoac nop phat.");

			for(new i; i < icountz; i++) {
				if(PlayerVehicleInfo[playerid][i][pvPrice] < 1) PlayerVehicleInfo[playerid][i][pvPrice] = 2000000;
				if(400 <= PlayerVehicleInfo[playerid][i][pvModelId] <= 611)
				{
					if(PlayerVehicleInfo[playerid][i][pvId] > INVALID_PLAYER_VEHICLE_ID) {
						if(PlayerVehicleInfo[playerid][i][pvTicket]) {
							strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
							format(szMiscArray, sizeof(szMiscArray), "%s\n%s (phat - $%i)", szMiscArray, vehicleName, PlayerVehicleInfo[playerid][i][pvTicket]);
							++icount;
						}
						else {
							strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
							format(szMiscArray, sizeof(szMiscArray), "%s\n%s", szMiscArray, vehicleName);
						}
					}
					else if(PlayerVehicleInfo[playerid][i][pvImpounded]) {
						strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s\n%s (tam giu - $%i de chuoc)", szMiscArray, vehicleName, (PlayerVehicleInfo[playerid][i][pvPrice] / 20) + PlayerVehicleInfo[playerid][i][pvTicket] + (PlayerInfo[playerid][pLevel] * 3000));
						++icount;
					}
					else format(szMiscArray, sizeof(szMiscArray), "%s\nRong", szMiscArray);
				}
			}
			if(icount) {
				return ShowPlayerDialogEx(playerid, MPSPAYTICKETS, DIALOG_STYLE_LIST, "Vehicles", szMiscArray, "Tha", "Huy");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co tien phat can nop hoac xe can chuoc.");
		}

		case 2: {
			if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iDMVAccess] && arrGroupData[PlayerInfo[playerid][pMember]][g_iDMVAccess] != INVALID_RANK)
				return ShowPlayerDialogEx(playerid, DMVRELEASE_TARGET, DIALOG_STYLE_INPUT, "DMV - Chuoc xe", "Nhap ten nguoi ban muon chuoc xe giup.", "Chon", "Huy");
			else
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai Law Enforcement Officer!");

		}

		case 3: {

			new
				iCount,
				pVehSlots = GetPlayerVehicleSlots(iTargetID);

			for(new i; i < pVehSlots; i++) {
				if(PlayerVehicleInfo[iTargetID][i][pvPrice] < 1) PlayerVehicleInfo[iTargetID][i][pvPrice] = 2000000;
				if(PlayerVehicleInfo[iTargetID][i][pvId] > INVALID_PLAYER_VEHICLE_ID) {
					if(PlayerVehicleInfo[iTargetID][i][pvTicket]) {
						strunpack(vehicleName, VehicleName[PlayerVehicleInfo[iTargetID][i][pvModelId] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s\n%s (phat - $%i)", szMiscArray, vehicleName, PlayerVehicleInfo[iTargetID][i][pvTicket]);
						++iCount;
					}
					else {
						strunpack(vehicleName, VehicleName[PlayerVehicleInfo[iTargetID][i][pvModelId] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s\n%s", szMiscArray, vehicleName);
					}
				}
				else if(PlayerVehicleInfo[iTargetID][i][pvImpounded]) {
					strunpack(vehicleName, VehicleName[PlayerVehicleInfo[iTargetID][i][pvModelId] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (tam giu - $%i de chuoc)", szMiscArray, vehicleName, (PlayerVehicleInfo[iTargetID][i][pvPrice] / 20) + PlayerVehicleInfo[iTargetID][i][pvTicket] + (PlayerInfo[iTargetID][pLevel] * 3000));
					++iCount;
				}
				else format(szMiscArray, sizeof(szMiscArray), "%s\nRong", szMiscArray);
			}
			if(iCount) ShowPlayerDialogEx(playerid, MPSPAYTICKETSCOP, DIALOG_STYLE_LIST, "Vehicles", szMiscArray, "Tha", "Huy"), SetPVarInt(playerid, "vRel", iTargetID);
			else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay khong co tien phat can nop hoac xe can chuoc.");
		}

		case 4: {
			if (PlayerInfo[playerid][pWantedLevel] > 0) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban dang co lenh bat giu, khong duoc phep lam giay phep.");
			ShowPlayerDialogEx(playerid, DIALOG_LICENSE_BUY, DIALOG_STYLE_LIST, "Chon loai giay phep ban muon lam.", "Bang lai thuyen ($5,000)\r\nBang lai may bay ($25,000)\r\nGiay phep Taxi ($35,000)", "Mua", "Huy");
		}

		case 5: {
			ShowPlayerDialogEx(playerid,
			DIALOG_DSVEH_CAUTION,
			DIALOG_STYLE_MSGBOX,
			"THI LAI XE",
			"{FE2C2C}DOC KY\n{FFFFFF}Ban sap tham gia ky thi bang lai xe.\nTren duong chinh, gioi han toc do la {FE2C2C}50{FFFFFF}, tren cao toc la {FE2C2C}100{FFFFFF}.\nBan se truot neu vuot qua gioi han toc do, nhung co the thi lai.\nNeu roi xe qua mot phut, ban se truot.", "Agree", "Disagree");
		}

	}

	return 1;

}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;

	switch(dialogid) {

		case DMV_MAIN: {

			if(!response) {
				return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong con o diem DMV");
			}

			if(strcmp("Nop phat", inputtext) == 0) ShowDMVMenu(playerid, 1);
			if(strcmp("Gia han bang lai xe", inputtext) == 0) {

				if(GetPlayerCash(playerid) < 10000) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du tien de gia han bang lai.");
				GivePlayerCash(playerid, -10000);
				PlayerInfo[playerid][pCarLic] = gettime() + (86400*80);
				SendClientMessageEx(playerid, COLOR_WHITE, "Bang lai cua ban da duoc gia han 80 ngay");
			}
			if(strcmp("Giay phep khac", inputtext) == 0) ShowDMVMenu(playerid, 4);
			if(strcmp("Mua giay phep khac", inputtext) == 0) ShowDMVMenu(playerid, 4);
			if(strcmp("[LEO only] Chuoc xe bi tam giu", inputtext) == 0) ShowDMVMenu(playerid, 2);
			if(strcmp("Thi lai xe", inputtext) == 0) ShowDMVMenu(playerid, 5);


			/*switch(listitem) {

				case 0: return ShowDMVMenu(playerid, 1); // this is the Pay Tickets option
				case 1: {

					if(PlayerInfo[playerid][pCarLic] == 0 || PlayerInfo[playerid][pLevel] < 2) { // driving test
						return ShowDMVMenu(playerid, 5);
					}
					else if(PlayerInfo[playerid][pCarLic] > 0) {
						if(GetPlayerCash(playerid) < 10000) return SendClientMessageEx(playerid, COLOR_WHITE, "You do not have enough money to renew your license.");
						GivePlayerCash(playerid, -10000);
						PlayerInfo[playerid][pCarLic] = gettime() + (86400*80);
						SendClientMessageEx(playerid, COLOR_WHITE, "Your license has been renewed for 80 days");
					}
				}
				case 2: return ShowDMVMenu(playerid, 4);
				case 3: return ShowDMVMenu(playerid, 2); // LEOs only DMV release
			}*/
		}

		case DMVRELEASE_TARGET: {

			if(!response) return ShowDMVMenu(playerid);

			new id = strval(inputtext);

			if(IsPlayerConnected(id)) return ShowDMVMenu(playerid, 3, id);
		}

	}
	return 0;
}
