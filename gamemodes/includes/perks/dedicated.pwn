/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Dedicated System

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

/** Austin's DP system **/


#include <YSI_Coding\y_hooks>

SendDedicatedMessage(color, const string[])
{
	foreach(new i: Player) 
	{
		if((PlayerInfo[i][pDedicatedPlayer] > 0 || PlayerInfo[i][pAdmin] >= 4) && PlayerInfo[i][pDedicatedEnabled] == 1)
		{
			SendClientMessageEx(i, color, string);
		}
	}
}

HourDedicatedPlayer(playerid)
{
	new	thedate[3];	
	getdate(thedate[0], thedate[1], thedate[2]);
	PlayerInfo[playerid][pDedicatedHours]++;
	if(PlayerInfo[playerid][pDedicatedHours] >= 50 && PlayerInfo[playerid][pDedicatedPlayer] == 0)
	{
		if(PlayerInfo[playerid][pDedicatedPlayer] != 4) PlayerInfo[playerid][pDedicatedPlayer] = 1;
		SendClientMessageEx(playerid, COLOR_YELLOW, "Chuc mung ban la Tier 1 Dedicated Player!");
		format(szMiscArray, sizeof(szMiscArray), "%s dat Tier 1 Dedicated Player sau 50 gio choi!", GetPlayerNameEx(playerid));
		SendClientMessageToAll(-1, szMiscArray);
	}
	else if(PlayerInfo[playerid][pDedicatedHours] >= 75 && PlayerInfo[playerid][pDedicatedPlayer] == 1)
	{
		if(PlayerInfo[playerid][pDedicatedPlayer] != 4) PlayerInfo[playerid][pDedicatedPlayer] = 2;
		format(PlayerInfo[playerid][pDedicatedTimestamp], 11, "%d-%02d-%02d", thedate[0], thedate[1], thedate[2]);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Chuc mung ban la Tier 2 Dedicated Player!");
		format(szMiscArray, sizeof(szMiscArray), "%s dat Tier 2 Dedicated Player sau 75 gio choi!", GetPlayerNameEx(playerid));
		SendClientMessageToAll(-1, szMiscArray);
	} 
	else if(PlayerInfo[playerid][pDedicatedHours] >= 90 && PlayerInfo[playerid][pDedicatedPlayer] == 2)
	{
		if(PlayerInfo[playerid][pDedicatedPlayer] != 4) PlayerInfo[playerid][pDedicatedPlayer] = 3;
		SendClientMessageEx(playerid, COLOR_YELLOW, "Chuc mung ban la Tier 3 Dedicated Player!");
		format(szMiscArray, sizeof(szMiscArray), "%s dat Tier 3 Dedicated Player sau 90 gio choi!.", GetPlayerNameEx(playerid));
		SendClientMessageToAll(-1, szMiscArray);	
	} 
}

DayDedicatedPlayer(playerid)
{
	new	thedate[3],
	    tdate[3];	
	getdate(thedate[0], thedate[1], thedate[2]);
	sscanf(PlayerInfo[playerid][pDedicatedTimestamp], "p<->iii", tdate[0], tdate[1], tdate[2]);
	if(tdate[2]+1 == thedate[2] && PlayerInfo[playerid][pDedicatedPlayer] >= 2)
	{
		GiftPlayer(MAX_PLAYERS, playerid);
		format(PlayerInfo[playerid][pDedicatedTimestamp], 11, "%d-%02d-%02d", thedate[0], thedate[1], thedate[2]);
		PlayerInfo[playerid][pGiftTime] = 0;
	} 
	/*
	else if(thedate[2] == 1 && thedate[1] != tdate[1])
	{
		SendClientMessageEx(playerid, COLOR_RED, "Dedicated: It's a new month your dedicated rank has been reset!");
		PlayerInfo[playerid][pDedicatedPlayer] = 0;
		PlayerInfo[playerid][pDedicatedHours] = 0;
	}
	*/
}


GetDPRankName(playerid)
{
	new rank[77];
	
	if(PlayerInfo[playerid][pAdmin] >= 4 && (PlayerInfo[playerid][pTogReports] == 1 || GetPVarType(playerid, "Undercover")))
	{
		rank = "Tier 1 Dedicated Player";
	}
	else if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0)
	{
		switch(PlayerInfo[playerid][pAdmin])
		{
			case 2: rank = "Junior Admin";
			case 3: rank = "General Admin";
			case 4: rank = "Senior Admin";
			case 1337: rank = "Head Admin";
			case 99999: rank = "Executive Admin";
		}
	}
	else 
	{
		switch(PlayerInfo[playerid][pDedicatedPlayer])
		{
			case 1: rank = "Tier 1 Dedicated Player";
			case 2: rank = "Tier 2 Dedicated Player";
			case 3: rank = "Tier 3 Dedicated Player";
			case 4: rank = "Dedicated Moderator";
		}
	}
	return rank;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(dialogid == DIALOG_LOCKER_DP1)
	{
		if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi tu do.");
		if(!IsPlayerInRangeOfPoint(playerid, 4.0, 166.6046,-2001.0406,3499.6482))  return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan DP Locker.");// Need co-ordinates
		if(listitem == 0)
		{
			new Float:health;
			GetHealth(playerid, health);
			new hpint = floatround( health, floatround_round );
			if( hpint >= 100 )
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day mau.");
				return 1;
			}
			else {
				SetHealth(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban da dung bo so cuu, hien co 100.0 HP.");
			}
		}
		if(listitem == 1)
		{
			new Float:armour;
			GetArmour(playerid, armour);
			if(armour >= 100)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day giap.");
				return 1;
			}
			else if(GetPlayerCash(playerid) < 10000)
			{
				SendClientMessageEx(playerid, COLOR_GREY,"Ban khong co $10,000");
				return 1;
			}
			else 
			{
				GivePlayerCash(playerid, -10000);
				SetArmour(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban tra $10,000 cho kevlar vest.");
			}
		}
	}
	else if(dialogid == DIALOG_LOCKER_DP2)
	{
		if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi tu do.");
		if(!IsPlayerInRangeOfPoint(playerid, 4.0, 166.6046,-2001.0406,3499.6482))  return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan DP Locker.");// Need co-ordinates
		if(listitem == 0)
		{
			new Float:health;
			GetHealth(playerid, health);
			new hpint = floatround( health, floatround_round );
			if( hpint >= 100 )
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day mau.");
				return 1;
			}
			else {
				SetHealth(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban da dung bo so cuu, hien co 100.0 HP.");
			}
		}
		if(listitem == 1)
		{
			new Float:armour;
			GetArmour(playerid, armour);
			if(armour >= 100)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day giap.");
				return 1;
			}
			else if(GetPlayerCash(playerid) < 5000 && PlayerInfo[playerid][pDedicatedPlayer] < 3)
			{
				SendClientMessageEx(playerid, COLOR_GREY,"Ban khong co $5,000");
				return 1;
			}
			else 
			{
				if(PlayerInfo[playerid][pDedicatedPlayer] < 3) GivePlayerCash(playerid, -5000);
				SetArmour(playerid, 100);
				if(PlayerInfo[playerid][pDedicatedPlayer] < 3)
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban tra $5,000 cho kevlar vest.");
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban lay kevlar vest tu tu do.");
				}
			}
		}
		if(listitem == 2)
		{
			if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan cua ban bi han che!");
			if(PlayerInfo[playerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban dang bi han che vu khi, khong the lay vu khi!");
			ShowPlayerDialogEx(playerid, DIALOG_DEDICATED_WEAPON, DIALOG_STYLE_LIST, "Kho vu khi Dedicated", "Desert Eagle (Mien phi)\nSemi-Automatic MP5 (Mien phi)\nPump Shotgun (Mien phi)", "Lay", "Huy");
		}
	}
	else if(dialogid == DIALOG_DEDICATED_WEAPON)
	{
		if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi tu do.");
		if(!IsPlayerInRangeOfPoint(playerid, 4.0, 166.6046,-2001.0406,3499.6482))  return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan DP Locker.");// Need co-ordinates
		switch(listitem)
		{
			case 0: //Deagle
			{
				GivePlayerValidWeapon(playerid, 24);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban da lay Desert Eagle tu tu do.");
			}
			case 1: //MP5
			{
				GivePlayerValidWeapon(playerid, 29);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban da lay Semi-Automatic MP5 tu tu do.");
			}
			case 2: //Shotgun
			{
				GivePlayerValidWeapon(playerid, 25);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Dedicated Locker] Ban da lay Pump Shotgun tu tu do.");
			}
		}

	}
	return 0;
}

/** Austin's Dedicated Player System **/

CMD:dp(playerid, params[]) 
{
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && !PlayerInfo[playerid][pDedicatedPlayer]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai Dedicated player.");
	if(PlayerInfo[playerid][pDedicatedEnabled] != 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Phai bat chat Dedicated de su dung. (/togdp)");
	if(PlayerInfo[playerid][pDedicatedMuted] != 0 || PlayerInfo[playerid][pDedicatedWarn] != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang bi cam chat Dedicated.");
	if(GetPVarInt(playerid, "LastDPChat") > gettime()) return SendClientMessageEx(playerid, COLOR_GRAD2, "Phai cho 5 giay giua cac tin nhan.");
	new szMessage[128];
	if(sscanf(params, "s[128", szMessage)) return SendClientMessageEx(playerid, COLOR_GRAD2, "CACH DUNG: /dp [message]");
	format(szMessage, sizeof(szMessage), "%s %s: %s", GetDPRankName(playerid), GetPlayerNameEx(playerid), szMessage);
	SendDedicatedMessage(0x2FC660FF, szMessage);
	SetPVarInt(playerid, "LastDPChat", gettime()+5);
	return 1;
}

CMD:togdp(playerid, params[])
{
	if(PlayerInfo[playerid][pDedicatedPlayer] > 0 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		if(PlayerInfo[playerid][pDedicatedEnabled] == 0) 
		{
			PlayerInfo[playerid][pDedicatedEnabled] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da bat chat Dedicated.");
		}
		else 
		{
			PlayerInfo[playerid][pDedicatedEnabled] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tat chat Dedicated va khong nhan tin nua.");
		}
	}
	else 
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai Dedicated player.");
	}
	return 1;
}

CMD:dplocker(playerid, params[])
{
	#if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the dung.");
	#endif
	if(IsPlayerInRangeOfPoint(playerid, 4.0, 166.6540, -2001.0413, 3499.6482)) // Need co-ordinates
	{
	    switch(PlayerInfo[playerid][pDedicatedPlayer])
	    {
			case 0: SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai Dedicated player!");
			case 1: ShowPlayerDialogEx(playerid, DIALOG_LOCKER_DP1, DIALOG_STYLE_LIST, "Dedicated Player 1", "First Aid Kit (Mien phi)\nKevlar Vest ($10,000)", "Chon", "Huy");
			case 2: ShowPlayerDialogEx(playerid, DIALOG_LOCKER_DP2, DIALOG_STYLE_LIST, "Dedicated Player 2", "First Aid Kit (Mien phi)\nKevlar Vest ($5,000)\nVu khi (Mien phi)", "Chon", "Huy");
			default:  ShowPlayerDialogEx(playerid, DIALOG_LOCKER_DP2, DIALOG_STYLE_LIST, "Dedicated Player 3", "First Aid Kit (Mien phi)\nKevlar Vest (Mien phi)\nVu khi (Mien phi)", "Chon", "Huy");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o tai Dedicated Locker!");
	return 1;
}
/*
CMD:dpplate(playerid, params[])
{
	if(PlayerInfo[playerid][pDedicatedPlayer] < 1)
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You're not a Dedicated player!");
		
	new string[128], Float: vHealth, inpveh;
	if(IsPlayerConnected(playerid))
	{
	    if(isnull(params))
	        return SendClientMessageEx(playerid, COLOR_GREY, "Usage: /dpplate [dp/superdp/remove]");

		inpveh = false;
	    for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
	    {
     		if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId]))
       		{
				GetVehicleHealth(PlayerVehicleInfo[playerid][d][pvId], vHealth);
				inpveh = 1;
	                
    			if(vHealth < 800)
       				return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Please repair your vehicle before replacing your plate.");
       				
    			if(strcmp(params, "dp", true) == 0)
    			{
    			    format(string, sizeof(string), "{2FC660}DEDICATED");
   			    	format(PlayerVehicleInfo[playerid][d][pvPlate], 32, "%s", string);
    			    SendClientMessageEx(playerid, COLOR_WHITE, "Your vehicle will now appear with the Dedicated Player Plate, parking your vehicle momentarily...");
					pc_cmd_park(playerid, "");
	            }
	            else if(strcmp(params, "superdp", true) == 0)
	            {
	                if(PlayerInfo[playerid][pDedicatedPlayer] < 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "You're not a high enough Dedicated player for this plate.");
                    format(string, sizeof(string), "{2FC660}SUPERDP");
					format(PlayerVehicleInfo[playerid][d][pvPlate], 32, "%s", string);
    			    SendClientMessageEx(playerid, COLOR_WHITE, "Your vehicle will now appear with the Super Dedicated Player Plate.");
					pc_cmd_park(playerid, "");
	            }
	            else if(strcmp(params, "remove", true) == 0)
	            {
					PlayerVehicleInfo[playerid][d][pvPlate] = 0;
    			    SendClientMessageEx(playerid, COLOR_WHITE, "Your vehicle will now appear with the default plate.");
					pc_cmd_park(playerid, "");
	            }
	            else
	            {
	                SendClientMessageEx(playerid, COLOR_GREY, "Usage: /dpplate [dp/superdp/remove]");
	            }
			}
		}
		
		if(inpveh == 0) SendClientMessageEx(playerid, COLOR_GRAD2, "You're not inside a vehicle that you own!");
	}
	return 1;
}
*/
CMD:dpwarn(playerid, params[])
{
	new giveplayerid, reason[24], string[164];
	if(PlayerInfo[playerid][pDedicatedPlayer] >= 4 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) 
	{
		if(!sscanf(params, "us[24]", giveplayerid, reason))
		{
			if(!IsPlayerConnected(giveplayerid))
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua ket noi.");
			if(PlayerInfo[giveplayerid][pDedicatedMuted] != 0) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang bi cam chat.");
			if(PlayerInfo[giveplayerid][pDedicatedWarn] > 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang chiu canh cao.");
			
			format(string, sizeof(string), "AdmCmd: %s tam cam %s chat Dedicated, ly do: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
			ABroadCast(COLOR_LIGHTRED, string, 4);
			SendDedicatedMessage(COLOR_LIGHTRED, string);
			format(string, sizeof(string), "AdmCmd: %s has temporarily muted %s from Dedicated chat, reason: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
			Log("logs/dedicated.log", string);

			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban bi %s canh cao tren chat Dedicated, ly do: %s", GetPlayerNameEx(playerid), reason);
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Hinh phat keo dai hai gio. Khieu nai tai dien dan: www.ng-gaming.net/forums");

			PlayerInfo[giveplayerid][pDedicatedWarn] = 120;
		}	
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Cach dung: /dpwarn [playerid] [reason]");
		}
	}	
	else 
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:setdedicated(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
        new string[128], targetid, level;
	    if(sscanf(params, "ui", targetid, level)) 
	    {
			SendClientMessageEx(playerid, COLOR_GRAD1, "Cach dung: /setdedicated [player] [level]");
			SendClientMessageEx(playerid, COLOR_GRAD2, "(1) Tier 1 Dedicated - (2) Tier 2 Dedicated - (3) Tier 3 Dedicated 3 - (4) DP Moderator");
			return 1;
		}

		if(IsPlayerConnected(targetid))
		{
		    if(targetid != INVALID_PLAYER_ID)
		    {
			    if(PlayerInfo[targetid][pDedicatedPlayer] > PlayerInfo[playerid][pDedicatedPlayer])
			        return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho nguoi nay!");

				PlayerInfo[targetid][pDedicatedPlayer] = level;
				format(string, sizeof(string), "AdmCmd: %s da dat cap Dedicated cua %s thanh %d.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), level);
				ABroadCast(COLOR_LIGHTRED, string, 4);
				SendDedicatedMessage(COLOR_LIGHTRED, string);
				format(string, sizeof(string), "AdmCmd: %s has set %s Dedicated level to %d.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), level);
				Log("logs/dedicated.log", string);
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		} 
	}
	else 
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

CMD:osetdedicated(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
        new pname[MAX_PLAYER_NAME], level;
	    if(sscanf(params, "s[32]i", pname, level))
			return SendClientMessageEx(playerid, COLOR_WHITE, "Cach dung: /osetdedicated [player] [level]");

        new targetid = ReturnUser(pname);
		if(IsPlayerConnected(targetid))
		{
		    SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi do dang online, hay dung /setdedicated.");
		}
		else 
		{
		    new
				szQuery[128],
				szPlayerName[MAX_PLAYER_NAME];

			mysql_escape_string(pname, szPlayerName);		
			SetPVarInt(playerid, "Offline_Dedicated", level);
			SetPVarString(playerid, "Offline_DName", szPlayerName);
			
            mysql_format(MainPipeline, szQuery, sizeof(szQuery), "SELECT `pDedicatedPlayer` FROM `accounts` WHERE `Username` = '%s'", szPlayerName);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "iii", OFFLINE_DEDICATED_THREAD, playerid, g_arrQueryHandle[playerid]);
 			
			SendClientMessageEx(playerid, COLOR_WHITE, "Dang dat tai khoan %s ngoai tuyen thanh Dedicated cap %d.", szPlayerName, level);
 		}
 	}
 	else 
 	{
 		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
 	}
 	return 1;
}

CMD:dpmute(playerid, params[])
{
	if(PlayerInfo[playerid][pDedicatedPlayer] >= 4 || PlayerInfo[playerid][pAdmin] >= 4)
	{
	    new string[128], targetid, reason[64];
	    if(sscanf(params, "us[64]", targetid, reason))
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Cach dung: /dpmute [player] [reason]");

		if(IsPlayerConnected(targetid))
		{
		    if(PlayerInfo[targetid][pDedicatedMuted] == 0)
		    {
		        if(targetid != INVALID_PLAYER_ID)
		        {
			        if(PlayerInfo[targetid][pDedicatedPlayer] > PlayerInfo[playerid][pDedicatedPlayer] && PlayerInfo[playerid][pAdmin] <= 0 || PlayerInfo[targetid][pAdmin] > PlayerInfo[playerid][pAdmin])
		 				return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho nguoi nay!");

					PlayerInfo[targetid][pDedicatedMuted] = 1;
					SendClientMessageEx(targetid, COLOR_GRAD2, "Ban bi %s cam chat Dedicated, ly do: %s. Khieu nai tai www.ng-gaming.net/forums", GetPlayerNameEx(playerid), reason);
					format(string, sizeof(string), "AdmCmd: %s cam %s chat Dedicated, ly do: %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), reason);
					ABroadCast(COLOR_LIGHTRED, string, 4);
					SendClientMessageEx(playerid, COLOR_LIGHTRED, string);
					format(string, sizeof(string), "AdmCmd: %s has muted %s from the Dedicated chat, reason: %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), reason);
					Log("logs/dedicated.log", string);
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do da bi cam chat Dedicated!");
			}
		}
		else 
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		}
	}
	else 
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

CMD:dpunmute(playerid, params[])
{
	if(PlayerInfo[playerid][pDedicatedPlayer] >= 4 || PlayerInfo[playerid][pAdmin] >= 4)
	{
	    new string[128], targetid, reason[64];
	    if(sscanf(params, "us[64]", targetid, reason))
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Cach dung: /dpunmute [player] [reason]");

		if(IsPlayerConnected(targetid))
		{
		    if(PlayerInfo[targetid][pDedicatedMuted] == 1)
		    {
		        if(targetid != INVALID_PLAYER_ID)
		        {
			        //if(PlayerInfo[targetid][pDedicatedPlayer] > PlayerInfo[playerid][pDedicatedPlayer] || PlayerInfo[targetid][pAdmin] > PlayerInfo[playerid][pAdmin])
		 			//	return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot use this command on this person!");

					PlayerInfo[targetid][pDedicatedMuted] = 0;
					SendClientMessageEx(targetid, COLOR_GRAD2, "Ban duoc %s go cam chat Dedicated, ly do: %s.", GetPlayerNameEx(playerid), reason);
					format(string, sizeof(string), "AdmCmd: %s go cam %s chat Dedicated, ly do: %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), reason);
					ABroadCast(COLOR_LIGHTRED, string, 4);
					SendClientMessageEx(playerid, COLOR_LIGHTRED, string);
					format(string, sizeof(string), "AdmCmd: %s has unmuted %s from the Dedicated chat, reason: %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), reason);
					Log("logs/dedicated.log", string);
				}
			}
			else 
			{  
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong bi cam chat Dedicated!");
			}
		}
		else 
		{ 
			SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		}
	}
	else 
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

CMD:dedicatedplayers(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pDedicatedPlayer] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[1024];
		foreach(new i : Player)
		{
			if(PlayerInfo[i][pDedicatedPlayer] >= 1)
			{
				format(string, sizeof(string), "%s\nDedicated cap %d %s", string, PlayerInfo[i][pDedicatedPlayer], GetPlayerNameEx(i));
			}
		}
		ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_LIST, "Dedicated Player online", string, "Dong", "");
	}
	else
	{
		 SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

CMD:dpdraw(playerid, params[]) 
{
    if(PlayerInfo[playerid][pDedicatedPlayer] >= 4 || PlayerInfo[playerid][pAdmin] >= 1337) 
    {

		new
			arr_Winners[MAX_PLAYERS],
			iWinCount,
			iBroadcast;

		if(sscanf(params, "d", iBroadcast)) 
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Cach dung: /dpdraw [broadcast(0-1)]");
			return 1;
		}

		foreach(new i: Player)
		{
			if(PlayerInfo[i][pDedicatedPlayer] > 0) arr_Winners[iWinCount++] = i;
		}

		if(iWinCount > 0) 
		{

			new
				iWinrar = arr_Winners[random(iWinCount)],
				szMessage[128];

			if(iBroadcast == 1) 
			{
				format(szMessage, sizeof(szMessage), "%s vua duoc chon ngau nhien! Chuc mung! (Dedicated Player Draw)", GetPlayerNameEx(iWinrar));
				SendDedicatedMessage(COLOR_WHITE, szMessage);
			}
			else 
			{
				format(szMessage, sizeof(szMessage), "%s (ID %d) duoc chon ngau nhien (/dpdraw).", GetPlayerNameEx(iWinrar), iWinrar);
				SendClientMessageEx(playerid, COLOR_YELLOW, szMessage);
				ABroadCast(COLOR_YELLOW, szMessage, 1338);
			}
			format(szMessage, sizeof(szMessage), "%s has used /dpdraw and %s won.", GetPlayerNameEx(playerid), GetPlayerNameEx(iWinrar));
			Log("logs/dedicated.log", szMessage);
		}
		else 
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong co nguoi online du dieu kien thang!");
		}
	}
	return 1;
}
