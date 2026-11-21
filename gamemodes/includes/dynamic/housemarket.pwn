#include <YSI_Coding\y_hooks>

#define MAX_LISTINGS_PER_PAGE (35)

hook OnPlayerConnect(playerid)
{
	AdTracking[playerid] = 0;
	HouseMarketTracking[playerid] = 0;
	ClearDoorSaleVariables(playerid);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	for(new i = 0; i < sizeof(HouseInfo); i ++) if(HouseInfo[i][hOwnerID] == GetPlayerSQLId(playerid) && HouseInfo[i][Listed] == 1 && HouseInfo[i][PendingApproval] == 1) ClearHouseSaleVariables(i);
	foreach(new i : Player)
	{
		if(DDSaleTarget[i] == playerid && i != playerid)
		{
			SendClientMessageEx(i, COLOR_GREY, "Nguoi mua cua dong cua ban da ngat ket noi.");
			ClearDoorSaleVariables(i);
			break;
		}
	}
	return 1;
}

ClearHouseSaleVariables(houseid)
{
	HouseInfo[houseid][Listed] = 0;
	HouseInfo[houseid][PendingApproval] = 0;
	HouseInfo[houseid][ListedTimeStamp] = 0;
	HouseInfo[houseid][ListingPrice] = 0;
	for(new i = 0; i < 5; i ++)
	{
		if(i < 2) HouseInfo[houseid][LinkedGarage][i] = 0;
		HouseInfo[houseid][LinkedDoor][i] = 0;
	}
	strcpy(HouseInfo[houseid][ListingDescription], "N/A", 128);
	SaveHouse(houseid);
	return 1;
}

ShowListingInformation(playerid, houseid, dialogid)
{
	new count[3];
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "Thong tin chung:\n\n  * ID nha: %d\n  * Gia: $%s\n  * Nguoi ban: %s", houseid, number_format(HouseInfo[houseid][ListingPrice]), StripUnderscore(HouseInfo[houseid][hOwnerName]));
	if(strcmp("N/A", HouseInfo[houseid][ListingDescription], true) != 0) format(szMiscArray, sizeof(szMiscArray), "%s\n  * Mo ta: %s", szMiscArray, HouseInfo[houseid][ListingDescription]);
	format(szMiscArray, sizeof(szMiscArray), "%s\n  * Het han: %s", szMiscArray, date(HouseInfo[houseid][ListedTimeStamp], 4));
	strcat(szMiscArray, "\n\nCua dong lien ket:\n");
	for(new i = 0; i < 5; i ++)
	{
		if(HouseInfo[houseid][LinkedDoor][i] != 0 && DDoorsInfo[HouseInfo[houseid][LinkedDoor][i]][ddOwner] == HouseInfo[houseid][hOwnerID]) 
		{
			format(szMiscArray, sizeof(szMiscArray), "%s\n  * ID cua: %d (%s)", szMiscArray, HouseInfo[houseid][LinkedDoor][i], DDoorsInfo[HouseInfo[houseid][LinkedDoor][i]][ddDescription]);
			count[0] ++;
		}
	}
	if(count[0] == 0) strcat(szMiscArray, "\n  * Khong co");
	strcat(szMiscArray, "\n\nCong dong lien ket:\n");
	for(new i = 0; i < sizeof(GateInfo); i ++)
	{
		if(GateInfo[i][gHID] == houseid) 
		{
			format(szMiscArray, sizeof(szMiscArray), "%s\n  * ID cong: %d", szMiscArray, i);
			count[1] ++;
		}
	}
	if(count[1] == 0) strcat(szMiscArray, "\n  * Khong co");
	strcat(szMiscArray, "\n\nGarage lien ket:\n");
	for(new i = 0; i < 2; i ++)
	{
		if(HouseInfo[houseid][LinkedGarage][i] != 0 && GarageInfo[HouseInfo[houseid][LinkedGarage][i]][gar_Owner] == HouseInfo[houseid][hOwnerID]) 
		{
			format(szMiscArray, sizeof(szMiscArray), "%s\n  * ID garage: %d", szMiscArray, HouseInfo[houseid][LinkedGarage][i]);
			count[2] ++;
		}
	}
	if(count[2] == 0) strcat(szMiscArray, "\n  * Khong co");
	ShowPlayerDialogEx(playerid, dialogid, DIALOG_STYLE_MSGBOX, "Thong tin tin ban nha", szMiscArray, "Dong y", "Huy");
	return 1;
}

GetNearestOwnedHouse(playerid)
{
	for(new i = 0; i < sizeof(HouseInfo); i ++) if(GetPlayerSQLId(playerid) == HouseInfo[i][hOwnerID] && IsPlayerInRangeOfPoint(playerid, 3.0, HouseInfo[i][hExteriorX], HouseInfo[i][hExteriorY], HouseInfo[i][hExteriorZ]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hExtVW] && GetPlayerInterior(playerid) == HouseInfo[i][hExtIW]) return i;
	return -1;
}

ShowMainListingDialog(playerid)
{
	new houseid;
	szMiscArray[0] = 0;
	houseid = GetNearestOwnedHouse(playerid);
	if(houseid == -1) return 1;
	format(szMiscArray, sizeof(szMiscArray), "Cai dat\tGia tri\nGia\t$%s\nCua lien ket 1\t%s\nCua lien ket 2\t%s\nCua lien ket 3\t%s\nCua lien ket 4\t%s\nCua lien ket 5\t%s\nGarage lien ket 1\t%s\nGarage lien ket 2\t%s\nMo ta\t%s\nHoan tat va gui",
	number_format(HouseInfo[houseid][ListingPrice]), ReturnDoorLineDetails(playerid, HouseInfo[houseid][LinkedDoor][0]),
	ReturnDoorLineDetails(playerid, HouseInfo[houseid][LinkedDoor][1]), ReturnDoorLineDetails(playerid, HouseInfo[houseid][LinkedDoor][2]),
	ReturnDoorLineDetails(playerid, HouseInfo[houseid][LinkedDoor][3]), ReturnDoorLineDetails(playerid, HouseInfo[houseid][LinkedDoor][4]), 
	ReturnGarageLineDetails(playerid, HouseInfo[houseid][LinkedGarage][0]), ReturnGarageLineDetails(playerid, HouseInfo[houseid][LinkedGarage][1]), HouseInfo[houseid][ListingDescription]);
	ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEMAIN, DIALOG_STYLE_TABLIST_HEADERS, "Cho nha", szMiscArray, "Dong y", "Huy");
	return 1;
}

AdditionalAdvertisements(index)
{
	for(new i = index; i < sizeof(HouseInfo); i ++) if(HouseInfo[i][Listed] == 1 && HouseInfo[i][PendingApproval] == 0) return true;
	return false;
}

task HouseMarket[60000]()
{
	new bool:notification;
	for(new i = 0; i < sizeof(HouseInfo); i ++)
	{
		if(HouseInfo[i][Listed] == 1)
		{
			switch(HouseInfo[i][PendingApproval])
			{
				case 0:
				{
					if(gettime() >= HouseInfo[i][ListedTimeStamp])
					{
						ClearHouseSaleVariables(i);
						foreach(new p: Player) 
						{
							if(gPlayerLogged{p} == 1 && HouseInfo[i][hOwnerID] == GetPlayerSQLId(p))
							{
								SendClientMessageEx(p, COLOR_GREY, "Tin ban nha cua ban da het han va bi go khoi cho nha.");
								break;
							}
						}
					}
				}
				case 1:
				{
					if(notification == false)
					{
						ABroadCastText(COLOR_LIGHTRED, "Co tin ban nha dang cho duyet.", 4, true);
						notification = true;
					}
				}
			}
		}
	}
	return 1;
}




CMD:houselistinghelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_WHITE, "** LENH DANG BAN NHA **");
	SendClientMessageEx(playerid, COLOR_GREY, "* /listhouse - Dang tin ban nha ($500,000).");
	SendClientMessageEx(playerid, COLOR_GREY, "* /renewlisting - Gia han tin ban nha ($100,000).");
	SendClientMessageEx(playerid, COLOR_GREY, "* /listingdate - Xem ngay het han tin ban nha.");
	SendClientMessageEx(playerid, COLOR_GREY, "* /deletelisting - Xoa tin ban nha da dang.");
	SendClientMessageEx(playerid, COLOR_GREY, "* /houselistings - Xem danh sach tin ban nha.");
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /pendinglistings - Xem tin ban nha dang cho Admin duyet.");
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /listingdetails [House ID] - Xem chi tiet tin ban nha dang cho duyet.");
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /(a)pprove(l)isting [House ID] - Duyet tin ban nha.");
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /(d)eny(li)sting [House ID] - Tu choi tin ban nha.");
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /adeletelisting [House ID] - Xoa tin ban nha.");
		SendClientMessageEx(playerid, COLOR_GREY, "* CHU Y: Lenh (/admute) se cam nguoi choi dang tin ban nha. *");
	}
	return 1;
}

alias:denylisting("dli")
CMD:denylisting(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new houseid, reason[64], string[128];
	if(sscanf(params, "ds[64]", houseid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /denylisting [House ID] [Reason]");
	if(houseid < 1 || houseid >= MAX_HOUSES)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID nha phai tu 1 den %d.", MAX_HOUSES - 1);
		return 1;
	}
	if(strlen(reason) < 3 || strlen(reason) > 60) return SendClientMessageEx(playerid, COLOR_GREY, "Ly do khong duoc duoi 3 ky tu hoac qua 60 ky tu.");
	if(HouseInfo[houseid][hOwned] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua co chu.");
	if(HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay khong dang cho duyet tin ban.");
	ClearHouseSaleVariables(houseid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da tu choi tin ban nha ID %d (chu: %s), ly do: %s.", houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]), reason);
	foreach(new i: Player) 
	{
		if(gPlayerLogged{i} == 1 && HouseInfo[houseid][hOwnerID] == GetPlayerSQLId(i))
		{
			SendClientMessageEx(i, COLOR_LIGHTRED, "%s da tu choi tin ban nha cua ban (ID nha %d), ly do: %s.", GetPlayerNameEx(playerid), houseid, reason);
			break;
		}
	}
	PlayerInfo[playerid][pTrashReport] ++;
	format(string, sizeof(string), "AdmCmd: %s tu choi tin ban nha ID %d (chu: %s), ly do: %s.", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]), reason);
	ABroadCast(COLOR_LIGHTRED, string, 4);
	format(string, sizeof(string), "AdmCmd: %s denied house ID %d's house listing request (owner: %s), reason: %s.", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]), reason);
	Log("logs/admin.log", string);
	return 1;
}

alias:approvelisting("al")
CMD:approvelisting(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new houseid, seller, string[128];
	if(sscanf(params, "d", houseid)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /approvelisting [House ID]");
	if(houseid < 1 || houseid >= MAX_HOUSES)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID nha phai tu 1 den %d.", MAX_HOUSES - 1);
		return 1;
	}
	if(HouseInfo[houseid][hOwned] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua co chu.");
	if(HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay khong dang cho duyet tin ban.");
	seller = INVALID_PLAYER_ID;
	foreach(new i: Player) 
	{
		if(gPlayerLogged{i} == 1 && HouseInfo[houseid][hOwnerID] == GetPlayerSQLId(i))
		{
			seller = i;
			break;
		}
	}
	switch(seller)
	{
		case INVALID_PLAYER_ID:
		{
			PlayerInfo[playerid][pAcceptReport] ++;
			ReportCount[playerid] ++;
			ReportHourCount[playerid] ++;
			SendClientMessageEx(playerid, COLOR_YELLOW, "Tin ban nha ID %d bi loi nen da bi go.", houseid);
			return 1;
		}
		default:
		{
			if(GetPlayerCash(seller) < 500000)
			{
				ClearHouseSaleVariables(houseid);
				SendClientMessageEx(seller, COLOR_GREY, "Admin da duyet tin ban nha, nhung ban khong con du $500,000.");
				SendClientMessageEx(seller, COLOR_GREY, "Tin chua duoc dang len cho nha vi ban khong du tien tra phi dang tin.");
				PlayerInfo[playerid][pAcceptReport] ++;
				ReportCount[playerid] ++;
				ReportHourCount[playerid] ++;
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da duyet tin ban nha ID %d (khong du tien - chu: %s).", houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
				format(string, sizeof(string), "AdmCmd: %s duyet tin ban nha ID %d (khong du tien - chu: %s).", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
				ABroadCast(COLOR_LIGHTRED, string, 4);
				format(string, sizeof(string), "AdmCmd: %s approved house ID %d's house listing request (insufficient funds - owner: %s).", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
				Log("logs/admin.log", string);
				return 1;
			}
			else if(GetPlayerCash(seller) >= 500000)
			{
				GivePlayerCashEx(seller, TYPE_ONHAND, -500000);
				HouseInfo[houseid][PendingApproval] = 0;
				HouseInfo[houseid][ListedTimeStamp] = gettime() + 259200;
				SaveHouse(houseid);
				SendClientMessageEx(seller, COLOR_GREEN, "Admin da duyet tin ban nha cua ban, ban bi tru $500,000.");
				PlayerInfo[playerid][pAcceptReport] ++;
				ReportCount[playerid] ++;
				ReportHourCount[playerid] ++;
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da duyet tin ban nha ID %d (chu: %s).", houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
				format(string, sizeof(string), "AdmCmd: %s duyet tin ban nha ID %d (chu: %s).", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
				ABroadCast(COLOR_LIGHTRED, string, 4);
				format(string, sizeof(string), "AdmCmd: %s approved house ID %d's house listing request (owner: %s).", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
				Log("logs/admin.log", string);
				return 1;
			}
			return 1;
		}
	}
	return 1;
}

CMD:adeletelisting(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new houseid, string[128];
	if(sscanf(params, "d", houseid)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /adeletelisting [House ID]");
	if(houseid < 1 || houseid >= MAX_HOUSES)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID nha phai tu 1 den %d.", MAX_HOUSES - 1);
		return 1;
	}
	if(HouseInfo[houseid][hOwned] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua co chu.");
	if(HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua duoc dang ban.");
	ClearHouseSaleVariables(houseid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da xoa tin ban nha ID %d (chu: %s).", houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
	format(string, sizeof(string), "AdmCmd: %s xoa tin ban nha ID %d (chu: %s).", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
	ABroadCast(COLOR_LIGHTRED, string, 4);
	format(string, sizeof(string), "AdmCmd: %s deleted house ID %d's house listing (owner: %s).", GetPlayerNameEx(playerid), houseid, StripUnderscore(HouseInfo[houseid][hOwnerName]));
	Log("logs/admin.log", string);
	return 1;
}

CMD:listingdetails(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new houseid;
	if(sscanf(params, "d", houseid)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /listingdetails [House ID]");
	szMiscArray[0] = 0;
	if(houseid < 1 || houseid >= MAX_HOUSES)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID nha phai tu 1 den %d.", MAX_HOUSES - 1);
		return 1;
	}
	if(HouseInfo[houseid][hOwned] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua co chu.");
	if(HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay khong dang cho duyet tin ban.");
	ShowListingInformation(playerid, houseid, DIALOG_LISTINGINFORMATION);
	return 1;
}

CMD:pendinglistings(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new count;
	SendClientMessageEx(playerid, COLOR_WHITE, "** TIN BAN NHA CHO DUYET: **");
	for(new i = 0; i < sizeof(HouseInfo); i ++)
	{
		if(HouseInfo[i][hOwned] == 1 && HouseInfo[i][Listed] == 1 && HouseInfo[i][PendingApproval] == 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "(ID nha: %d) Chu: %s", i, StripUnderscore(HouseInfo[i][hOwnerName]));
			count ++;
		}
	}
	if(count == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co tin ban nha cho duyet.");
	return 1;
}

CMD:listhouse(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
	if(PlayerInfo[playerid][pADMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
	if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
	if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
	if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
	if(GetPlayerCash(playerid) < 500000) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat $500,000 de dang ban nha.");
	new houseid;
	if(servernumber == 2) return SendClientMessage(playerid, COLOR_WHITE, "Lenh nay da bi tat!");
	houseid = GetNearestOwnedHouse(playerid);
	if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
	if(HouseInfo[houseid][Listed] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay da duoc dang ban tren cho nha.");
	HouseInfo[houseid][ListingPrice] = 0;
	HouseInfo[houseid][PendingApproval] = 0;
	HouseInfo[houseid][ListedTimeStamp] = 0;
	for(new i = 0; i < 5; i ++) 
	{
		if(i < 2) HouseInfo[houseid][LinkedGarage][i] = 0;
		HouseInfo[houseid][LinkedDoor][i] = 0;
	}
	strcpy(HouseInfo[houseid][ListingDescription], "N/A", 128);
	SaveHouse(houseid);
	ShowMainListingDialog(playerid);	
    return 1;
}

CMD:listingdate(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
	if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
	if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
	if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
	new houseid;
	if(servernumber == 2) return SendClientMessage(playerid, COLOR_WHITE, "Lenh nay da bi tat!");
	houseid = GetNearestOwnedHouse(playerid);
	if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
	if(HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua duoc dang tren cho nha.");
	SendClientMessageEx(playerid, COLOR_WHITE, "Tin ban nha se het han vao %s.", date(HouseInfo[houseid][ListedTimeStamp], 4));
    return 1;
}

CMD:renewlisting(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
	if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
	if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
	if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
	if(GetPlayerCash(playerid) < 100000) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat $100,000 de gia han tin ban nha.");
	new houseid;
	if(servernumber == 2) return SendClientMessage(playerid, COLOR_WHITE, "Lenh nay da bi tat!");
	houseid = GetNearestOwnedHouse(playerid);
	if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
	if(HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua duoc dang tren cho nha.");
	HouseInfo[houseid][ListedTimeStamp] += 86400;
	SaveHouse(houseid);
	SendClientMessageEx(playerid, COLOR_GREEN, "Da gia han tin ban nha them mot ngay, het han vao %s.", date(HouseInfo[houseid][ListedTimeStamp], 4));
	GivePlayerCashEx(playerid, TYPE_ONHAND, -100000);
    return 1;
}

CMD:deletelisting(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
	if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
	if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
	if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
	new houseid;
	if(servernumber == 2) return SendClientMessage(playerid, COLOR_WHITE, "Lenh nay da bi tat!");
	houseid = GetNearestOwnedHouse(playerid);
	if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
	if(HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay chua duoc dang tren cho nha.");
	ClearHouseSaleVariables(houseid);
	SendClientMessageEx(playerid, COLOR_GREY, "Ban da go tin ban nha khoi cho nha.");
    return 1;
}

CMD:houselistings(playerid, const params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
	if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
	if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
	if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
	new count[4], location[MAX_ZONE_NAME];
	szMiscArray[0] = 0;
	for(new i = 0; i < sizeof(HouseInfo); i ++)
	{
		if(HouseInfo[i][hOwned] == 1 && HouseInfo[i][Listed] == 1 && HouseInfo[i][PendingApproval] == 0)
		{
			location = "San Andreas";
			for(new l = 1; l < sizeof(count); l ++) count[l] = 0;
			for(new l = 0; l < 5; l ++) 
			{
				if(l < 2) if(HouseInfo[i][LinkedGarage][l] != 0) count[3] ++;
				if(HouseInfo[i][LinkedDoor][l] != 0) count[1] ++;
			}
			for(new l = 0; l < sizeof(GateInfo); l ++) if(GateInfo[l][gHID] == i) count[2] ++;
			Get3DZone(HouseInfo[i][hExteriorX], HouseInfo[i][hExteriorY], HouseInfo[i][hExteriorZ], location, sizeof(location));
			format(szMiscArray, sizeof(szMiscArray), "%s\n(%d) [$%s] [%s] [%d DD(s)] [%d DG(s)] [%d G(s)]", szMiscArray, i, number_format(HouseInfo[i][ListingPrice]), location, count[1], count[2], count[3]);
			AdTracking[playerid] = i;
			count[0] ++;
		}
		if(count[0] == MAX_LISTINGS_PER_PAGE) break;
	}
	if(count[0] == 0) return SendClientMessage(playerid, COLOR_GREY, "Hien khong co tin ban nha nao.");
	if(count[0] == MAX_LISTINGS_PER_PAGE) format(szMiscArray, sizeof(szMiscArray), "%s\n[Trang sau...]", szMiscArray);
	ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSELISTINGS, DIALOG_STYLE_LIST, "Danh sach ban nha", szMiscArray, "Dong y", "Huy");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	new string[128];
	switch(dialogid)
	{
		case DIALOG_LISTHOUSEMAIN:
		{
			new houseid;
			houseid = GetNearestOwnedHouse(playerid);
			switch(response)
			{
				case false: if(houseid != -1)  return ClearHouseSaleVariables(houseid);
				case true:
				{
					if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
					if(PlayerInfo[playerid][pADMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
					if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
					if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
					if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
					if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
					if(GetPlayerCash(playerid) < 500000) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat $500,000 de dang ban nha.");
					if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
					if(HouseInfo[houseid][Listed] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay da duoc dang ban tren cho nha.");
					switch(listitem)
					{
						case 0: return ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEPRICE, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap gia ban nha ben duoi.", "Dong y", "Huy");
						case 1..5:
						{
							HouseMarketTracking[playerid] = listitem - 1;
							ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDOORS, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID cua de lien ket voi tin ban nha. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
							return 1;
						}
						case 6, 7:
						{
							HouseMarketTracking[playerid] = listitem - 6;
							ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEGARAGES, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID garage de lien ket voi tin ban nha. Nhap \"0\" de go garage.", "Dong y", "Huy");
							return 1;
						}
						case 8: return ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDESCRIPTION, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap mo ta tin ban nha ben duoi.", "Dong y", "Huy");
						case 9:
						{
							if(HouseInfo[houseid][ListingPrice] == 0)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban phai dat gia truoc khi gui tin ban nha.");
								ShowMainListingDialog(playerid);
								return 1;
							}
							for(new i = 0; i < 5; i ++) 
							{
								if(i < 2) if(HouseInfo[houseid][LinkedGarage][i] != 0 && GetPlayerSQLId(playerid) != GarageInfo[HouseInfo[houseid][LinkedGarage][i]][gar_Owner]) HouseInfo[houseid][LinkedGarage][i] = 0;
								if(HouseInfo[houseid][LinkedDoor][i] != 0 && GetPlayerSQLId(playerid) != DDoorsInfo[HouseInfo[houseid][LinkedDoor][i]][ddOwner]) HouseInfo[houseid][LinkedDoor][i] = 0;
							}
							HouseInfo[houseid][Listed] = 1;
							HouseInfo[houseid][PendingApproval] = 1;
							SaveHouse(houseid);
							SendClientMessageEx(playerid, COLOR_GREEN, "Tin ban nha da duoc gui cho Admin xet duyet.");
							format(string, sizeof(string), "[New House Listing Request]: ID nha %d, Chu: %s.", houseid, GetPlayerNameEx(playerid));
							ABroadCast(COLOR_LIGHTRED, string, 4);
							return 1;
						}
					}
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_LISTHOUSEPRICE:
		{
			switch(response)
			{
				case false: return ShowMainListingDialog(playerid);
				case true:
				{
					if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
					if(PlayerInfo[playerid][pADMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
					if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
					if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
					if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
					if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
					if(GetPlayerCash(playerid) < 500000) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat $500,000 de dang ban nha.");
					new houseid, price;
					houseid = GetNearestOwnedHouse(playerid);
					if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
					if(HouseInfo[houseid][Listed] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay da duoc dang ban tren cho nha.");
					if(sscanf(inputtext, "d", price))
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Gia phai la so.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEPRICE, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap gia ban nha ben duoi.", "Dong y", "Huy");
						return 1;
					}
					if(price < 100000 || price > 500000000)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Gia khong duoc duoi $100,000 hoac tren $500,000,000.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEPRICE, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap gia ban nha ben duoi.", "Dong y", "Huy");
						return 1;
					}
					if(price == HouseInfo[houseid][ListingPrice])
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Gia tin ban nha da la $%s.", number_format(price));
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEPRICE, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap gia ban nha ben duoi.", "Dong y", "Huy");
						return 1;
					}
					HouseInfo[houseid][ListingPrice] = price;
					SaveHouse(houseid);
					SendClientMessageEx(playerid, COLOR_WHITE, "Da doi gia tin ban nha.");
					ShowMainListingDialog(playerid);
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_LISTHOUSEDESCRIPTION:
		{
			switch(response)
			{
				case false: return ShowMainListingDialog(playerid);
				case true:
				{
					if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
					if(PlayerInfo[playerid][pADMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
					if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
					if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
					if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
					if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
					if(GetPlayerCash(playerid) < 500000) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat $500,000 de dang ban nha.");
					new houseid;
					houseid = GetNearestOwnedHouse(playerid);
					if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
					if(HouseInfo[houseid][Listed] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay da duoc dang ban tren cho nha.");
					if(strlen(inputtext) < 1 || strlen(inputtext) > 128)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Mo ta khong duoc duoi 1 ky tu hoac qua 128 ky tu.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDESCRIPTION, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap mo ta tin ban nha ben duoi.", "Dong y", "Huy");
						return 1;
					}
					if(strcmp(inputtext, HouseInfo[houseid][ListingDescription], false) == 0)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Mo ta nay trung voi mo ta da dat.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDESCRIPTION, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap mo ta tin ban nha ben duoi.", "Dong y", "Huy");
						return 1;
					}
					for(new i = 0; i < strlen(inputtext) - 7; i ++)
					{
						if(inputtext[i] == '{' && inputtext[i + 7] == '}')
						{
							strmid(string, inputtext, i + 1, i + 7);
							if(IsHex(string))
							{
								strdel(inputtext, i, i + 8);
								continue;
							}
						}
					}
					strcpy(HouseInfo[houseid][ListingDescription], inputtext, 128);
					SaveHouse(houseid);
					SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mo ta tin ban nha.");
					ShowMainListingDialog(playerid);
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_LISTHOUSEDOORS:
		{
			switch(response)
			{
				case false: return ShowMainListingDialog(playerid);
				case true:
				{
					if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
					if(PlayerInfo[playerid][pADMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
					if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
					if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
					if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
					if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
					if(GetPlayerCash(playerid) < 500000) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat $500,000 de dang ban nha.");
					new houseid, doorid;
					houseid = GetNearestOwnedHouse(playerid);
					if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
					if(HouseInfo[houseid][Listed] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay da duoc dang ban tren cho nha.");
					if(sscanf(inputtext, "d", doorid))
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID cua phai la so.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDOORS, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID cua de lien ket voi tin ban nha. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
						return 1;
					}
					if(doorid < 0 || doorid >= MAX_DDOORS)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID cua khong hop le.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDOORS, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID cua de lien ket voi tin ban nha. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
						return 1;
					}
					for(new i = 0; i < 5; i ++)
					{
						if(HouseInfo[houseid][LinkedDoor][i] == doorid && doorid != 0)
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Cua dong nay da lien ket voi tin ban nha.");
							ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDOORS, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID cua de lien ket voi tin ban nha. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
							return 1;
						}
					}
					switch(doorid)
					{
						case 0:
						{
							if(HouseInfo[houseid][LinkedDoor][HouseMarketTracking[playerid]] == 0)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "O nay chua co cua dong lien ket.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDOORS, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID cua de lien ket voi tin ban nha. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
								return 1;
							}
							HouseInfo[houseid][LinkedDoor][HouseMarketTracking[playerid]] = 0;
							SaveHouse(houseid);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da cap nhat/go cua dong lien ket voi tin ban nha.");
							ShowMainListingDialog(playerid);
							return 1;
						}
						default:
						{
							if(DDoorsInfo[doorid][ddOwner] != GetPlayerSQLId(playerid))
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu cua dong nay.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDOORS, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID cua de lien ket voi tin ban nha. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
								return 1;
							}
							if(HouseInfo[houseid][hIntIW] != DDoorsInfo[doorid][ddInteriorInt] || HouseInfo[houseid][hIntVW] != DDoorsInfo[doorid][ddInteriorVW])
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Cua dong nay khong lien ket voi nha ban.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEDOORS, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID cua de lien ket voi tin ban nha. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
								return 1;
							}
							HouseInfo[houseid][LinkedDoor][HouseMarketTracking[playerid]] = doorid;
							SaveHouse(houseid);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da cap nhat cua dong lien ket voi tin ban nha.");
							ShowMainListingDialog(playerid);
							return 1;
						}
					}
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_LISTHOUSEGARAGES:
		{
			switch(response)
			{
				case false: return ShowMainListingDialog(playerid);
				case true:
				{
					if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
					if(PlayerInfo[playerid][pADMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
					if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
					if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
					if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
					if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
					if(GetPlayerCash(playerid) < 500000) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat $500,000 de dang ban nha.");
					new houseid, garageid;
					houseid = GetNearestOwnedHouse(playerid);
					if(houseid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nha cua minh.");
					if(HouseInfo[houseid][Listed] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nha nay da duoc dang ban tren cho nha.");
					if(sscanf(inputtext, "d", garageid))
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID garage phai la so.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEGARAGES, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID garage de lien ket voi tin ban nha. Nhap \"0\" de go garage.", "Dong y", "Huy");
						return 1;
					}
					if(garageid < 0 || garageid >= MAX_GARAGES)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID garage khong hop le.");
						ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEGARAGES, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID garage de lien ket voi tin ban nha. Nhap \"0\" de go garage.", "Dong y", "Huy");
						return 1;
					}
					for(new i = 0; i < 2; i ++)
					{
						if(HouseInfo[houseid][LinkedGarage][i] == garageid && garageid != 0)
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Garage nay da lien ket voi tin ban nha.");
							ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEGARAGES, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID garage de lien ket voi tin ban nha. Nhap \"0\" de go garage.", "Dong y", "Huy");
							return 1;
						}
					}
					switch(garageid)
					{
						case 0:
						{
							if(HouseInfo[houseid][LinkedGarage][HouseMarketTracking[playerid]] == 0)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "O nay chua co garage lien ket.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEGARAGES, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID garage de lien ket voi tin ban nha. Nhap \"0\" de go garage.", "Dong y", "Huy");
								return 1;
							}
							HouseInfo[houseid][LinkedGarage][HouseMarketTracking[playerid]] = 0;
							SaveHouse(houseid);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da cap nhat/go garage lien ket voi tin ban nha.");
							ShowMainListingDialog(playerid);
							return 1;
						}
						default:
						{
							if(DDoorsInfo[garageid][ddOwner] != GetPlayerSQLId(playerid))
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu garage nay.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSEGARAGES, DIALOG_STYLE_INPUT, "Danh sach ban nha", "Nhap ID garage de lien ket voi tin ban nha. Nhap \"0\" de go garage.", "Dong y", "Huy");
								return 1;
							}
							HouseInfo[houseid][LinkedGarage][HouseMarketTracking[playerid]] = garageid;
							SaveHouse(houseid);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da cap nhat garage lien ket voi tin ban nha.");
							ShowMainListingDialog(playerid);
							return 1;
						}
					}
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_LISTHOUSELISTINGS:
		{
			if(response)
			{
				if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
				if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
				if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
				if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
				if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
				szMiscArray[0] = 0;
				new houseid, position[2], count[4], location[MAX_ZONE_NAME];
				if(strcmp(inputtext, "[Trang sau...]", true) == 0)
				{
					for(new i = AdTracking[playerid] + 1; i < sizeof(HouseInfo); i ++)
					{
						if(HouseInfo[i][hOwned] == 1 && HouseInfo[i][Listed] == 1 && HouseInfo[i][PendingApproval] == 0)
						{
							location = "San Andreas";
							for(new l = 1; l < sizeof(count); l ++) count[l] = 0;
							for(new l = 0; l < 5; l ++) 
							{
								if(l < 2) if(HouseInfo[i][LinkedGarage][l] != 0) count[3] ++;
								if(HouseInfo[i][LinkedDoor][l] != 0) count[1] ++;
							}
							for(new l = 0; l < sizeof(GateInfo); l ++) if(GateInfo[l][gHID] == i) count[2] ++;
							Get3DZone(HouseInfo[i][hExteriorX], HouseInfo[i][hExteriorY], HouseInfo[i][hExteriorZ], location, sizeof(location));
							format(szMiscArray, sizeof(szMiscArray), "%s\n(%d) [$%s] [%s] [%d DD(s)] [%d DG(s)] [%d G(s)]", szMiscArray, i, number_format(HouseInfo[i][ListingPrice]), location, count[1], count[2], count[3]);
							AdTracking[playerid] = i;
							count[0] ++;
						}
						if(count[0] == MAX_LISTINGS_PER_PAGE) break;
					}
					if(count[0] == 0) return SendClientMessage(playerid, COLOR_GREY, "Hien khong co tin ban nha nao.");
					if(count[0] == MAX_LISTINGS_PER_PAGE && AdditionalAdvertisements(AdTracking[playerid] + 1)) strcat(szMiscArray, "\n[Trang sau...]");
					ShowPlayerDialogEx(playerid, DIALOG_LISTHOUSELISTINGS, DIALOG_STYLE_LIST, "Danh sach ban nha", szMiscArray, "Dong y", "Huy");
					return 1;
				}
				position[0] = strfind(inputtext, "(");
				position[1] = strfind(inputtext, ")");
				strmid(string, inputtext, position[0] + 1, position[1]);
				houseid = strval(string);
				if(HouseInfo[houseid][hOwned] == 0 || HouseInfo[houseid][Listed] == 0 || HouseInfo[houseid][PendingApproval] == 1)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nha nay hien khong duoc ban.");
					pc_cmd_houselistings(playerid, "");
					return 1;
				}
				HouseMarketTracking[playerid] = houseid;
				ShowListingInformation(playerid, houseid, DIALOG_SELECTEDLISTING);
				return 1;
			}
		}
		case DIALOG_SELECTEDLISTING:
		{
			if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
			if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
			if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
			if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
			if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
			switch(response)
			{
				case false: return pc_cmd_houselistings(playerid, "");
				case true: 
				{
					if(HouseInfo[HouseMarketTracking[playerid]][hOwned] == 0 || HouseInfo[HouseMarketTracking[playerid]][Listed] == 0 || HouseInfo[HouseMarketTracking[playerid]][PendingApproval] == 1)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Nha nay hien khong duoc ban.");
						pc_cmd_houselistings(playerid, "");
						return 1;
					}
					ShowPlayerDialogEx(playerid, DIALOG_LISTINGOPTIONS, DIALOG_STYLE_LIST, "Danh sach ban nha", "Den xem nha\nMua nha", "Dong y", "Huy");
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_LISTINGOPTIONS:
		{
			if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
			if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung cho nha khi bi thuong.");
			if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung danh sach ban nha.");
			if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the xem danh sach ban nha khi o tu.");
			if(PlayerInfo[playerid][pLevel] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de xem danh sach ban nha.");
			if(HouseInfo[HouseMarketTracking[playerid]][hOwned] == 0 || HouseInfo[HouseMarketTracking[playerid]][Listed] == 0 || HouseInfo[HouseMarketTracking[playerid]][PendingApproval] == 1)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nha nay hien khong duoc ban.");
				pc_cmd_houselistings(playerid, "");
				return 1;
			}
			switch(response)
			{
				case false: return ShowListingInformation(playerid, HouseMarketTracking[playerid], DIALOG_SELECTEDLISTING);
				case true:
				{
					switch(listitem)
					{
						case 0:
						{
							if(GetPlayerSQLId(playerid) == HouseInfo[HouseMarketTracking[playerid]][hOwnerID])
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Khong the den nha minh qua cho nha, dung (/home).");
								ShowPlayerDialogEx(playerid, DIALOG_LISTINGOPTIONS, DIALOG_STYLE_LIST, "Danh sach ban nha", "Den xem nha\nMua nha", "Dong y", "Huy");
								return 1;
							}
							if(HouseInfo[HouseMarketTracking[playerid]][hExtIW] != 0 || HouseInfo[HouseMarketTracking[playerid]][hExtVW] != 0)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Loi vao nha nay khong o ngoai troi. Hay lien he chu nha de den xem.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTINGOPTIONS, DIALOG_STYLE_LIST, "Danh sach ban nha", "Den xem nha\nMua nha", "Dong y", "Huy");
								return 1;
							}
							DisablePlayerCheckpoint(playerid);
							SetPlayerCheckpoint(playerid, HouseInfo[HouseMarketTracking[playerid]][hExteriorX], HouseInfo[HouseMarketTracking[playerid]][hExteriorY], HouseInfo[HouseMarketTracking[playerid]][hExteriorZ], 4.0);
							gPlayerCheckpointStatus[playerid] = CHECKPOINT_HOME;
							hInviteHouse[playerid] = HouseMarketTracking[playerid];
							SendClientMessageEx(playerid, COLOR_WHITE, "Da dat checkpoint den nha nay.");
							return 1;
						}
						case 1:
						{
							if(GetPlayerSQLId(playerid) == HouseInfo[HouseMarketTracking[playerid]][hOwnerID])
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Khong the mua nha cua chinh minh.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTINGOPTIONS, DIALOG_STYLE_LIST, "Danh sach ban nha", "Den xem nha\nMua nha", "Dong y", "Huy");
								return 1;
							}
							if(Homes[playerid] >= MAX_OWNABLE_HOUSES)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the so huu them nha.");
								ShowPlayerDialogEx(playerid, DIALOG_LISTINGOPTIONS, DIALOG_STYLE_LIST, "Danh sach ban nha", "Den xem nha\nMua nha", "Dong y", "Huy");
								return 1;
							}
							if(GetPlayerCash(playerid) < HouseInfo[HouseMarketTracking[playerid]][ListingPrice])
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du $%s de mua nha nay.", number_format(HouseInfo[HouseMarketTracking[playerid]][ListingPrice]));
								ShowPlayerDialogEx(playerid, DIALOG_LISTINGOPTIONS, DIALOG_STYLE_LIST, "Danh sach ban nha", "Den xem nha\nMua nha", "Dong y", "Huy");
								return 1;
							}
							new name[24], bool:online;
							foreach(new i: Player) 
							{
								if(gPlayerLogged{i} == 1 && HouseInfo[HouseMarketTracking[playerid]][hOwnerID] == GetPlayerSQLId(i))
								{
									GivePlayerCashEx(i, TYPE_BANK, HouseInfo[HouseMarketTracking[playerid]][ListingPrice]);
									SendClientMessageEx(i, COLOR_GREEN, "%s da mua nha cua ban (ID nha: %d) voi gia $%s.", GetPlayerNameEx(playerid), HouseMarketTracking[playerid], number_format(HouseInfo[HouseMarketTracking[playerid]][ListingPrice]));
									online = true;
									break;
								}
							}
							if(online == false)
							{
								szMiscArray[0] = 0;
								mysql_escape_string(HouseInfo[HouseMarketTracking[playerid]][hOwnerName], name);
								mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `accounts` SET `Bank`=`Bank`+%d WHERE `Username`='%s'", HouseInfo[HouseMarketTracking[playerid]][ListingPrice], name);
								mysql_tquery(MainPipeline, szMiscArray, "", "i", playerid);
								format(string, sizeof(string), "Toi mua nha cua ban (ID: %d) gia $%s.", HouseMarketTracking[playerid], number_format(HouseInfo[HouseMarketTracking[playerid]][ListingPrice]));
								mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "INSERT INTO `letters` (`Sender_Id`, `Receiver_Id`, `Date`, `Message`, `Delivery_Min`, `Notify`) VALUES (%d, %d, NOW(), '%e', 0, 1)", GetPlayerSQLId(playerid), HouseInfo[HouseMarketTracking[playerid]][hOwnerID], string);
								mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
								
							}
							SendClientMessageEx(playerid, COLOR_GREEN, "Ban da mua nha ID %d voi gia $%s.", HouseMarketTracking[playerid], number_format(HouseInfo[HouseMarketTracking[playerid]][ListingPrice]));
							Homes[playerid] ++;
							GivePlayerCashEx(playerid, TYPE_ONHAND, -HouseInfo[HouseMarketTracking[playerid]][ListingPrice]);
							for(new i = 0; i < 5; i ++)
							{
								if(i < 2)
								{
									if(HouseInfo[HouseMarketTracking[playerid]][LinkedGarage][i] != 0 && HouseInfo[HouseMarketTracking[playerid]][hOwnerID] == GarageInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedGarage][i]][gar_Owner])
									{
										strcpy(GarageInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedGarage][i]][gar_OwnerName], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
										GarageInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedGarage][i]][gar_Owner] = GetPlayerSQLId(playerid);
										CreateGarage(HouseInfo[HouseMarketTracking[playerid]][LinkedGarage][i]);
										SaveGarage(HouseInfo[HouseMarketTracking[playerid]][LinkedGarage][i]);
									}
								}
								if(HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i] != 0 && HouseInfo[HouseMarketTracking[playerid]][hOwnerID] == DDoorsInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]][ddOwner])
								{
									strcpy(DDoorsInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]][ddOwnerName], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
									DDoorsInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]][ddOwner] = GetPlayerSQLId(playerid);
									DestroyDynamicPickup(DDoorsInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]][ddPickupID]);
									if(IsValidDynamic3DTextLabel(DDoorsInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]][ddTextID])) DestroyDynamic3DTextLabel(DDoorsInfo[HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]][ddTextID]);
									CreateDynamicDoor(HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]);
									SaveDynamicDoor(HouseInfo[HouseMarketTracking[playerid]][LinkedDoor][i]);
								}
							}
							if(PlayerInfo[playerid][pPhousekey] == INVALID_HOUSE_ID) PlayerInfo[playerid][pPhousekey] = HouseMarketTracking[playerid];
							else PlayerInfo[playerid][pPhousekey2] = HouseMarketTracking[playerid];
							HouseInfo[HouseMarketTracking[playerid]][hOwnerID] = GetPlayerSQLId(playerid);
							strcpy(HouseInfo[HouseMarketTracking[playerid]][hOwnerName], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
							ReloadHouseText(HouseMarketTracking[playerid]);
							ClearHouseSaleVariables(HouseMarketTracking[playerid]);
							return 1;
						}
					}
				}
			}
			return 1;
		}
	}
	return 0;
}