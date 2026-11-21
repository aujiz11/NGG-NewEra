/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Bartender System

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

CMD:selldrink(playerid, params[])
{
	if(Job_HasJob(playerid, JOB_BARTENDER))
	{
		if(IsAtBar(playerid))
		{
			new giveplayerid;
			if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /selldrink [player]");

			if(IsPlayerConnected(giveplayerid))
			{
				if(playerid == giveplayerid)
				{
					return SendClientMessageEx(playerid, COLOR_GREY, " Khong the ban do uong cho chinh minh.");
				}
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					DrinkOffer[giveplayerid] = playerid;
					SetPVarInt(giveplayerid, "DrinkOfferSession", g_arrQueryHandle[playerid]);
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Bartender %s muon moi ban do uong. /accept drink de chon.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban moi %s do uong.",GetPlayerNameEx(giveplayerid));
				}
				else
				{
					return SendClientMessageEx(playerid, COLOR_GREY, " Nguoi do khong o gan ban!");
				}
			}
			else
			{
				return SendClientMessageEx(playerid, COLOR_GREY, " Nguoi do chua ket noi!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong o tai Bar!");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong phai bartender!");
		return 1;
	}
	return 1;
}