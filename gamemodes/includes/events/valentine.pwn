/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Valentines Events

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

CMD:valgifts(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pPR] == 2)
    {
     	if(ValGifts == 0)
     	{
           	ValGifts = 1;
			format(szMiscArray, sizeof(szMiscArray), "AdmCmd: %s da bat lenh /bemine.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMiscArray, 1337);
		}
		else
		{
		    ValGifts = 0;
	   		format(szMiscArray, sizeof(szMiscArray), "AdmCmd: %s da tat lenh /bemine.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMiscArray, 1337);
		}
	}
	return 1;
}

CMD:bemine(playerid, params[])
{
	if(ValGifts == 0)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Lenh nay da bi tat!");
		return 1;
	}
	new giveplayerid, style;
	if(sscanf(params, "ud", giveplayerid, style)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /bemine [player] [kissing style (1-6)]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua ket noi");
	if(playerid == giveplayerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the chon chinh minh. </3");
	if(!(0 < style < 7)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /bemine [player] [kissing style (1-6)]");

	new Float:ppFloats[3];
	GetPlayerPos(giveplayerid, ppFloats[0], ppFloats[1], ppFloats[2]);

	if(!IsPlayerInRangeOfPoint(playerid, 2, ppFloats[0], ppFloats[1], ppFloats[2]) || Spectating[giveplayerid] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban o qua xa! (hay den sat nhau!)");
		return 1;
	}
	if(PlayerInfo[playerid][pGiftTime] > 0)
	{
		format(szMiscArray, sizeof(szMiscArray),"Vat pham: Reset Gift Timer\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCredits con: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[17][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[17][sItemPrice]));
		ShowPlayerDialogEx(playerid, DIALOG_SHOPGIFTRESET, DIALOG_STYLE_MSGBOX, "Dat lai thoi gian qua", szMiscArray, "Mua", "Thoat" );
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da nhan qua trong 5 gio qua!");
		return 1;
	}
	else if(PlayerInfo[giveplayerid][pGiftTime] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi do da nhan qua trong 5 gio qua!");
		return 1;
	}
	SetPVarInt(playerid, "kissvalstyle", style);
	SetPVarInt(giveplayerid, "kissvaloffer", playerid);
	SetPVarInt(giveplayerid, "ValentineOfferSession", g_arrQueryHandle[playerid]);
	SetPVarInt(giveplayerid, "kissvalsqlid", GetPlayerSQLId(playerid));

	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da moi %s lam valentine cua minh, hay cho ho tra loi.", GetPlayerNameEx(giveplayerid));

	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "%s muon lam valentine cua ban, dung '/accept valentine' de dong y.", GetPlayerNameEx(playerid));
	return 1;
}
