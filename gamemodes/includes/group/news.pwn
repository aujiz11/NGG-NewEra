/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						News Group Type

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
stock IsANewsCar(carid)
{
	if(DynVeh[carid] != -1)
	{
	    new iDvSlotID = DynVeh[carid], iGroupID = DynVehicleInfo[iDvSlotID][gv_igID];
	    if((0 <= iGroupID < MAX_GROUPS))
	    {
	    	if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_NEWS) return 1;
		}
	}
	return 0;
}

stock OOCNews(color, const string[])
{
	foreach(new i: Player) {
		
		ChatTrafficProcess(i, color, string, CHAT_NEWS);
	}	
}


CMD:tognews(playerid, params[])
{
	return ToggleAccountSetting(playerid, CHAT_NEWS);
}

CMD:liveban(playerid, params[])
{
	if (IsAReporter(playerid))
	{
	    new giveplayerid,
	        string[128];

	    if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /liveban [player]");
		if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua ket noi.");
	    if(PlayerInfo[giveplayerid][pLiveBanned] == 0)
	    {
	        PlayerInfo[giveplayerid][pLiveBanned] = 1;
	        format(string, sizeof(string), "%s cam %s len phong van", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	        SendGroupMessage(GROUP_TYPE_NEWS, RADIO, string);
	        return 1;
	    }
	    else SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do da bi cam phong van.");
	}
	return 1;
}

CMD:liveunban(playerid, params[])
{
	new string[128],
		giveplayerid;
		
	if(IsAReporter(playerid) && PlayerInfo[playerid][pRank] >= 7)
	{
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /liveban [player]");
		if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua ket noi.");
		if(PlayerInfo[giveplayerid][pLiveBanned] == 1)
		{
			PlayerInfo[giveplayerid][pLiveBanned] = 0;
			format(string, sizeof(string), "%s da go cam phong van cho %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			SendGroupMessage(GROUP_TYPE_NEWS, RADIO, string);
		}
		else SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do khong bi cam phong van");
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Can it nhat Rank 7 de dung lenh nay");
	
	return 1;
}


CMD:live(playerid, params[])
{
	if(IsAReporter(playerid) && PlayerInfo[playerid][pRank] > 0)
	{
	    if(shutdown == 1) return SendClientMessageEx(playerid, COLOR_WHITE, "He thong tin tuc da tam dung." );
		if(TalkingLive[playerid] != INVALID_PLAYER_ID)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Cuoc tro chuyen truc tiep da ket thuc.");
			SendClientMessageEx(TalkingLive[playerid], COLOR_LIGHTBLUE, "* Cuoc tro chuyen truc tiep da ket thuc.");
			TogglePlayerControllable(playerid, true);
			TogglePlayerControllable(TalkingLive[playerid], true);
			DeletePVar(playerid, "IsLive");
			DeletePVar(TalkingLive[playerid], "IsLive");
			TalkingLive[TalkingLive[playerid]] = INVALID_PLAYER_ID;
			TalkingLive[playerid] = INVALID_PLAYER_ID;
			return 1;
		}

		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /live [player]");

		if (IsPlayerConnected(giveplayerid))
		{
			if (ProxDetectorS(5.0, playerid, giveplayerid))
			{
			    if(PlayerInfo[giveplayerid][pLiveBanned] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do bi cam phong van.");
				if(PlayerCuffed[giveplayerid] >= 1 || PlayerCuffed[playerid] >= 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
				}
				else
				{
					if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the phong van chinh minh!"); return 1; }
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban moi %s tro chuyen truc tiep.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s moi ban tro chuyen truc tiep, dung /accept live de dong y.", GetPlayerNameEx(playerid));
					LiveOffer[giveplayerid] = playerid;
					SetPVarInt(giveplayerid, "LiveOfferSession", g_arrQueryHandle[playerid]);
				}
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
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong phai News Reporter!");
	}
	return 1;
}
