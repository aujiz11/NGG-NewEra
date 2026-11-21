/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Bodyguard System

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

Bodyguard_ClearOffer(playerid)
{
	GuardOffer[playerid] = INVALID_PLAYER_ID;
	GuardPrice[playerid] = 0;
	DeletePVar(playerid, "GuardOfferSession");
	return 1;
}

Bodyguard_CanTrade(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid}) return 0;
	new PLAYER_STATE:playerState = GetPlayerState(playerid);
	return (playerState == PLAYER_STATE_ONFOOT || playerState == PLAYER_STATE_DRIVER || playerState == PLAYER_STATE_PASSENGER)
		&& !PlayerIsDead[playerid] && !GetPVarInt(playerid, "Injured") && !PlayerInfo[playerid][pHospital]
		&& !GetPVarType(playerid, "WatchingTV") && !GetPVarType(playerid, "PreviewingTV")
		&& !GetPVarType(playerid, "IsInArena") && !GetPVarType(playerid, "EventToken")
		&& HungerPlayerInfo[playerid][hgInEvent] == 0 && !PlayerBoxing[playerid] && !GetPVarInt(playerid, "_BoxingFight");
}

Bodyguard_IsNear(playerid, target, Float:range)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !(0 <= target < MAX_PLAYERS) || playerid == target
		|| !IsPlayerConnected(playerid) || !IsPlayerConnected(target) || !gPlayerLogged{playerid} || !gPlayerLogged{target}) return 0;
	if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target) || GetPlayerInterior(playerid) != GetPlayerInterior(target)) return 0;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(target, x, y, z);
	return IsPlayerInRangeOfPoint(playerid, range, x, y, z);
}

CMD:frisk(playerid, params[])
{
	if(IsACop(playerid) || Job_HasJob(playerid, JOB_BODYGUARD))
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /frisk [player]");
			return 1;
		}
		if(GetPVarType(playerid, "WatchingTV") || GetPVarType(playerid, "PreviewingTV") || Spectating[playerid])
			return SendClientMessageEx(playerid, COLOR_GREY, "Khong the kham nguoi khi xem TV hoac theo doi.");
		if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the kham chinh minh!");

		if(0 <= giveplayerid < MAX_PLAYERS && IsPlayerConnected(giveplayerid) && gPlayerLogged{giveplayerid})
		{
			if (Bodyguard_IsNear(playerid, giveplayerid, 8.0))
			{
				if(Spectating[giveplayerid] && PlayerInfo[playerid][pAdmin] < 2) return 1;
				if(PlayerInfo[giveplayerid][pAdmin] >= 2 && !PlayerInfo[giveplayerid][pTogReports]) return 1;

				PlayerFriskPlayer(playerid, giveplayerid); // It did a frisk ... why request?
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
			}

		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong phai nhan vien hanh phap hay bodyguard!");
		return 1;
	}
	return 1;
}

PlayerFriskPlayer(playerid, giveplayerid)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !(0 <= giveplayerid < MAX_PLAYERS) || playerid == giveplayerid) return 1;
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(giveplayerid)) return 1;
	szMiscArray[0] = 0;
	new packages = GetPVarInt(giveplayerid, "Packages");
	new crates = PlayerInfo[giveplayerid][pCrates];
	SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________");
	SendClientMessageEx(playerid, COLOR_YELLOW, "Do trong tui cua %s.", GetPlayerNameEx(giveplayerid));
	SendClientMessageEx(playerid, COLOR_WHITE, "** Vat pham **");
	format(szMiscArray, sizeof(szMiscArray), "* %s kham %s de tim hang cam.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid));
	ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	if(PlayerInfo[giveplayerid][pMats] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "(Tui) %d vat lieu.", PlayerInfo[giveplayerid][pMats]);
	}
	if(PlayerInfo[giveplayerid][pSyringes] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "(Tui) %d ong tiem.", PlayerInfo[giveplayerid][pSyringes]);
	}
    if(packages > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "(Tui) %d goi vat lieu.", packages);
	}
	if(crates > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "(Tui) %d thung ma tuy.", crates);
	}

	SendClientMessageEx(playerid, COLOR_WHITE, "** Ma tuy **");
	for(new i = 0; i < sizeof(Drugs); ++i) {

		if(PlayerInfo[giveplayerid][pDrugs][i] > 0) {
			SendClientMessageEx(playerid, COLOR_GRAD1, "%s: %dg", Drugs[i], PlayerInfo[giveplayerid][pDrugs][i]);
			}
	}
	if(PlayerInfo[giveplayerid][pFishWeight] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "(Tui) %d lbs ca.", PlayerInfo[giveplayerid][pFishWeight]);
	}
	SendClientMessageEx(playerid, COLOR_WHITE, "** Khac **");
	if(PlayerInfo[giveplayerid][pPhoneBook] > 0) SendClientMessageEx(playerid, COLOR_GREY, "Danh ba.");
	if(PlayerInfo[giveplayerid][pCDPlayer] > 0) SendClientMessageEx(playerid, COLOR_GREY, "May nghe nhac.");
	new weaponname[50];
	SendClientMessageEx(playerid, COLOR_WHITE, "** Vu khi **");
	for (new i = 0; i < 12; i++)
	{
		if(PlayerInfo[giveplayerid][pGuns][i] > 0)
		{
			GetWeaponName(PlayerInfo[giveplayerid][pGuns][i], weaponname, sizeof(weaponname));
			SendClientMessageEx(playerid, COLOR_GRAD1, "Vu khi: %s.", weaponname);
		}
	}
	SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________");
	return 0;
}

CMD:guard(playerid, params[])
{
	if(!Job_HasJob(playerid, JOB_BODYGUARD))
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai bodyguard.");
	if(!Bodyguard_CanTrade(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the de nghi bao ve.");

	new giveplayerid, money;
	if(sscanf(params, "ud", giveplayerid, money)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /guard [player] [price]");
	new now = gettime(), remaining = GetPVarInt(playerid, "GuardUntil") - now;
	if(remaining > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Cho %d giay truoc khi ban ao giap tiep.", remaining);
	if(money < 2000 || money > 10000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia phai tu $2,000 den $10,000.");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the /guard chinh minh.");
	if(!Bodyguard_CanTrade(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua the nhan bao ve.");
	if(!Bodyguard_IsNear(playerid, giveplayerid, 8.0))
		return SendClientMessageEx(playerid, COLOR_GREY, "Hai nguoi phai o gan, cung interior va world.");

	SetPVarInt(playerid, "GuardUntil", now + 10);
	GuardOffer[giveplayerid] = playerid;
	SetPVarInt(giveplayerid, "GuardOfferSession", g_arrQueryHandle[playerid]);
	GuardPrice[giveplayerid] = money;
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban de nghi bao ve %s voi gia $%d.", GetPlayerNameEx(giveplayerid), money);
	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Bodyguard %s muon bao ve ban voi gia $%d, dung /accept bodyguard de dong y.", GetPlayerNameEx(playerid), money);
	return 1;
}
