/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Token System

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

CMD:tokenhelp(playerid, params[])
{
    SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
    SendClientMessageEx(playerid, COLOR_WHITE,"*** HUONG DAN TOKEN ***");
    SendClientMessageEx(playerid, COLOR_GRAD3,"Doi VIP tokens lay vu khi tai VIP Locker.");
    SendClientMessageEx(playerid, COLOR_GRAD3,"VIP tokens co the nhan tu su kien hoac qua.");
    SendClientMessageEx(playerid, COLOR_GRAD3,"Vu khi gia 1-5 tokens moi mon, tu can chien den sung manh.");

    SendClientMessageEx(playerid, COLOR_GRAD3,"De tang tokens cho VIP khac, dung /givetokens.");
    return 1;
}

CMD:random(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] >= 1337) {

		new
			iHours,
			iBroadcast;

		if(sscanf(params, "dd", iHours, iBroadcast)) {
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /random [hours] [broadcast]");
		}

		new
			arr_Winners[MAX_PLAYERS],
			iWinCount;

		foreach(new i: Player)
		{
			if(SeeSpecialTokens(i, iHours)) arr_Winners[iWinCount++] = i;
		}
		if(iWinCount > 0) {

			new
				iWinrar = arr_Winners[random(iWinCount)],
				szMessage[48 + MAX_PLAYER_NAME];

			if(iBroadcast == 1) {
				SendClientMessageToAllEx(COLOR_WHITE, "%s vua duoc chon ngau nhien! Chuc mung!", GetPlayerNameEx(iWinrar));
			}
			else {
				format(szMessage, sizeof(szMessage), "%s (ID %d) duoc chon ngau nhien.", GetPlayerNameEx(iWinrar), iWinrar);
				ABroadCast(COLOR_YELLOW, szMessage, 1338);
			}
		}
		else SendClientMessageEx(playerid, COLOR_WHITE, "Khong co nguoi online du dieu kien thang!");
	}
	return 1;
}

CMD:vrandom(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] >= 1337) {

		new
			iHours,
			iBroadcast;

		if(sscanf(params, "dd", iHours, iBroadcast)) {
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /vrandom [hours] [broadcast]");
		}

		new
			arr_Winners[MAX_PLAYERS],
			iWinCount;

		foreach(new i: Player)
		{
			if(SeeSpecialTokens(i, iHours) && PlayerInfo[i][pDonateRank] > 0) arr_Winners[iWinCount++] = i;
		}	
		if(iWinCount > 0) {

			new
				iWinrar = arr_Winners[random(iWinCount)],
				szMessage[48 + MAX_PLAYER_NAME];

			if(iBroadcast == 1) {
				SendClientMessageToAllEx(COLOR_WHITE, "%s vua duoc chon ngau nhien! Chuc mung!", GetPlayerNameEx(iWinrar));
			}
			else {
				format(szMessage, sizeof(szMessage), "%s (ID %d) duoc chon ngau nhien.", GetPlayerNameEx(iWinrar), iWinrar);
				ABroadCast(COLOR_YELLOW, szMessage, 1338);
			}
		}
		else SendClientMessageEx(playerid, COLOR_WHITE, "Khong co nguoi online du dieu kien thang!");
	}
	return 1;
}

CMD:givetokens(playerid, params[])
{
	if(PlayerInfo[playerid][pDonateRank] > 0)
	{
		new string[128], giveplayerid, amount;
		if(sscanf(params, "ud", giveplayerid, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givetokens [player] [amount]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pDonateRank] > 0)
			{
				if(PlayerInfo[playerid][pTokens] >= amount)
				{
					if(amount < 1)
					{
						SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tang so luong do!");
						return 1;
					}
					if(giveplayerid == playerid)
					{
						SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tu tang tokens cho minh!");
						return 1;
					}
					if (!ProxDetectorS(5.0, playerid, giveplayerid))
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
						return 1;
					}
					PlayerInfo[playerid][pTokens] -= amount;
					PlayerInfo[giveplayerid][pTokens] += amount;

					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban nhan %d Tokens tu %s.", amount, GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da tang %s %d Tokens.", GetPlayerNameEx(giveplayerid), amount);
					format(string, sizeof(string), "* %s tang %s mot it Tokens.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du tokens!");
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong phai VIP!");
			}

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong phai VIP!");
	}
	return 1;
}

CMD:settoken(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new string[128], giveplayerid, amount;
		if(sscanf(params, "ud", giveplayerid, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /settoken [player] [amount]");

		if(IsPlayerConnected(giveplayerid))
		{
			PlayerInfo[giveplayerid][pTokens] = amount;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat tokens cua %s thanh %d !",GetPlayerNameEx(giveplayerid),amount);
			SendClientMessageEx(giveplayerid, COLOR_YELLOW, "VIP: Admin %s da dat tokens cua ban thanh %d.",GetPlayerNameEx(playerid),amount);

			format(string, sizeof(string), "%s has set %s's(%d) tokens to %d.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
			Log("logs/stats.log", string);

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:givetoken(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new string[128], giveplayerid, amount;
		if(sscanf(params, "ud", giveplayerid, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givetoken [player] [amount]");

		if(IsPlayerConnected(giveplayerid))
		{
			PlayerInfo[giveplayerid][pTokens] += amount;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da tang %s %d tokens !",GetPlayerNameEx(giveplayerid),amount);
			SendClientMessageEx(giveplayerid, COLOR_YELLOW, "VIP: Admin %s tang ban %d tokens.",GetPlayerNameEx(playerid),amount);

			format(string, sizeof(string), "%s has given %s(%d) %d tokens.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
			Log("logs/stats.log", string);

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}