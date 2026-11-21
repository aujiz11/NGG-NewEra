/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

    	    		  Horse Race Gambling System
    			        by Hector 

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

CMD:placebet(playerid, params[])
{
	if(!IsAtCasino(playerid)) return SendClientMessage(playerid, COLOR_GREY, "Ban khong o trong Casino."); // Check to see if the player is inside of a casino 
	if((PlayerInfo[playerid][pHorse] > 0)) return SendClientMessage(playerid, COLOR_GREY, "Ban dang tham gia mot van choi."); // Check to make sure the player can't place another bet while he has horsetimer going
	#if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the dung.");
	#endif
	if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban chua the lam viec nay.");
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] || (PlayerInfo[playerid][pJailTime] > 0 && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1))
   		return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam viec nay!");

	/*ShowPlayerDialog(playerid, DIALOG_HORSE_RACE, DIALOG_STYLE_TABLIST_HEADERS, "Inside Track Betting",
		"Horse\tBet\tPayout\n\
		Wong's Wang\t$18000\t$40000\n\
		Flaps's Ahoy\t$32000\t$70000\n\
		Beanflicker\t$46000\t$101000\n\
		Axe Wound\t$55000\t$123000\n\
		McTagnut & Fries\t$73000\t$161000\n\
		Love Torpedo\t$150000\t$330000\n\
		Arthur or Martha\t$425000\t$935000\n\
		Purple Love\t$875000\t$1900000\n\
		Billy Sastard\t$10000000\t$22000000",
		"Select", "Cancel");*/

	new dialogInfo[] = "Ngua\tTien cuoc\tTien thang\n\
		Wong's Wang\t$18000\t$40000\n\
		Flaps's Ahoy\t$32000\t$70000\n\
		Beanflicker\t$46000\t$101000\n\
		Axe Wound\t$55000\t$123000\n\
		McTagnut & Fries\t$73000\t$161000\n\
		Love Torpedo\t$150000\t$330000\n\
		Arthur or Martha\t$425000\t$935000\n\
		Purple Love\t$875000\t$1900000\n\
		Billy Sastard\t$10000000\t$22000000";
	Dialog_Show(playerid, PlaceHorseBet, DIALOG_STYLE_TABLIST_HEADERS, "Inside Track Betting",
		dialogInfo,
		"Chon", "Huy");


	SendClientMessage(playerid, COLOR_GREY, "Chao mung den Inside Track Betting!.");
	return 1;
}

Dialog:PlaceHorseBet(playerid, response, listitem, inputtext[]) {
	new string[128];
	if(!response) return 1;

	switch(listitem) {
		case 0:
    	{
   			if(PlayerInfo[playerid][pCash] >= 18000)			
     		{
				if(Businesses[InBusiness(playerid)][bSafeBalance] < 40000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 1;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -18000);
				format(string, sizeof(string), "%s has bet $18000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 18000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Wong's Wang voi $18000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 1:
    	{
   			if(PlayerInfo[playerid][pCash] >= 32000)
     		{
			if(Businesses[InBusiness(playerid)][bSafeBalance] < 70000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
			PlayerInfo[playerid][pHorse] = 2;
			TogglePlayerControllable(playerid, false);
			GivePlayerCash(playerid, -32000);
			format(string, sizeof(string), "%s has bet $32000 on a horse", GetPlayerNameEx(playerid));
			Log("logs/horse.log", string);
			Businesses[InBusiness(playerid)][bSafeBalance] += 32000; // Adds the money to the biz
			SaveBusiness(InBusiness(playerid));
			SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Flap's Ahoy voi $32000.");
			SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
			PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
			format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
			ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 2:
    	{
   			if(PlayerInfo[playerid][pCash] >= 46000)
     		{
				if(Businesses[InBusiness(playerid)][bSafeBalance] < 101000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 3;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -46000);
				format(string, sizeof(string), "%s has bet $46000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 46000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Beanflicker voi $46000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 1142, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 3:
    	{
   			if(PlayerInfo[playerid][pCash] >= 55000)
     		{
     			if(Businesses[InBusiness(playerid)][bSafeBalance] < 123000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 4;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -55000);
				format(string, sizeof(string), "%s has bet $55000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 55000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Axe Wound voi $55000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 4:
    	{
   			if(PlayerInfo[playerid][pCash] >= 73000)
     		{
				if(Businesses[InBusiness(playerid)][bSafeBalance] < 161000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 5;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -73000);
				format(string, sizeof(string), "%s has bet $73000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 73000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc McTagnut & Fries voi $73000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 1142, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 5:
    	{
   			if(PlayerInfo[playerid][pCash] >= 150000)
     		{
				if(Businesses[InBusiness(playerid)][bSafeBalance] < 330000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 6;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -150000);
				format(string, sizeof(string), "%s has bet $150000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 150000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Love Torpedo voi $150000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 6:
    	{
   			if(PlayerInfo[playerid][pCash] >= 425000)
     		{
				if(Businesses[InBusiness(playerid)][bSafeBalance] < 935000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 7;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -425000);
				format(string, sizeof(string), "%s has bet $425000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 425000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Arthur or Martha voi $425000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 1142, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 7:
    	{
   			if(PlayerInfo[playerid][pCash] >= 875000)
     		{
				if(Businesses[InBusiness(playerid)][bSafeBalance] < 1900000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 8;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -875000);
				format(string, sizeof(string), "%s has bet $875000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 875000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Purple Love voi $875000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
		case 8:
    	{
   			if(PlayerInfo[playerid][pCash] >= 10000000)
     		{
				if(Businesses[InBusiness(playerid)][bSafeBalance] < 22000000) return SendClientMessage(playerid, COLOR_GREY, "Casino khong du tien.");
				PlayerInfo[playerid][pHorse] = 9;
				TogglePlayerControllable(playerid, false);
				GivePlayerCash(playerid, -10000000);
				format(string, sizeof(string), "%s has bet $100000000 on a horse", GetPlayerNameEx(playerid));
				Log("logs/horse.log", string);
				Businesses[InBusiness(playerid)][bSafeBalance] += 10000000; // Adds the money to the biz
				SaveBusiness(InBusiness(playerid));
				SendClientMessage(playerid, COLOR_GREY, "Ban da cuoc Billy Sastard voi $10000000.");
				SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
				PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
				format(szMiscArray, sizeof(szMiscArray), "%s dat cuoc va cho cuoc dua bat dau", GetPlayerNameEx(playerid)); 
				ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_GREY, "**Announcer** Da xuat phat!.");
			}
			else return SendClientMessage(playerid, COLOR_GREY,"Ban khong du tien dat cuoc.");
		}
	}
	return 1;
}

/*
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) 
{

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	new string[128];

	switch(dialogid) {

		case DIALOG_HORSE_RACE: {
		if(!response)return 1;
	    	else
		    {
      			switch(listitem)
       			{
          			case 0:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 18000)			
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 40000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 1;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -18000);
										format(string, sizeof(string), "%s has bet $18000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 18000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Wong's Wang for $18000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
            		case 1:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 32000)
                 		{
										if(Businesses[InBusiness(playerid)][bSafeBalance] < 70000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 2;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -32000);
										format(string, sizeof(string), "%s has bet $32000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 32000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Flap's Ahoy for $32000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
         			case 2:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 46000)
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 101000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 3;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -46000);
										format(string, sizeof(string), "%s has bet $46000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 46000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Beanflicker for $46000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 1142, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
            		case 3:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 55000)
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 123000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 4;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -55000);
										format(string, sizeof(string), "%s has bet $55000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 55000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Axe Wound for $55000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
         			case 4:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 73000)
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 161000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 5;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -73000);
										format(string, sizeof(string), "%s has bet $73000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 73000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on McTagnut & Fries for $73000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 1142, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
            		case 5:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 150000)
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 330000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 6;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -150000);
										format(string, sizeof(string), "%s has bet $150000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 150000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Love Torpedo for $150000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
         			case 6:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 425000)
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 935000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 7;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -425000);
										format(string, sizeof(string), "%s has bet $425000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 425000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Arthur or Martha for $425000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 1142, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
            		case 7:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 875000)
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 1900000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 8;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -875000);
										format(string, sizeof(string), "%s has bet $875000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 875000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Purple Love for $875000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
         			case 8:
	            	{
               			if(PlayerInfo[playerid][pCash] >= 10000000)
                 		{
                 						if(Businesses[InBusiness(playerid)][bSafeBalance] < 22000000) return SendClientMessage(playerid, COLOR_GREY, "The casino doesn't have enough money.");
                 						PlayerInfo[playerid][pHorse] = 9;
                 						TogglePlayerControllable(playerid, 0);
										GivePlayerCash(playerid, -10000000);
										format(string, sizeof(string), "%s has bet $100000000 on a horse", GetPlayerNameEx(playerid));
                        				Log("logs/horse.log", string);
										Businesses[InBusiness(playerid)][bSafeBalance] += 10000000; // Adds the money to the biz
										SaveBusiness(InBusiness(playerid));
										SendClientMessage(playerid, COLOR_GREY, "You have placed a bet on Billy Sastard for $10000000.");
										SetTimerEx("HorseTimer", 15000, false, "i", playerid); 
										PlayerPlaySound(playerid, 3200, 0.0, 0.0, 0.0);
										format(szMiscArray, sizeof(szMiscArray), "%s places their bet and waits for the race to start", GetPlayerNameEx(playerid)); 
										ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										SendClientMessage(playerid, COLOR_GREY, "**Announcer** And they're off!.");
						}
						else return SendClientMessage(playerid, COLOR_GREY,"You don't have enough money to place the bet.");
         			}
				}
			}
		}
	}
	return 1;
}*/

forward HorseTimer(playerid);
public HorseTimer(playerid)
{
	TogglePlayerControllable(playerid, true);
    new
	a = PlayerInfo[playerid][pHorse];
	switch (a)
	{
	case 1: // If the player selected the first horse
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $40000.");
			GivePlayerCash(playerid, 40000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 40000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 2:
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $70000.");
			GivePlayerCash(playerid, 70000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 70000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 3:
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $101000.");
			GivePlayerCash(playerid, 101000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 101000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 4:
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $123000.");
			GivePlayerCash(playerid, 123000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 123000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 5:
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $161000.");
			GivePlayerCash(playerid, 161000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 161000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 6:
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $330000.");
			GivePlayerCash(playerid, 330000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 330000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 7:
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $935000.");
			GivePlayerCash(playerid, 935000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 935000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 8:
	{
	new Bet1 = random(3); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $1900000.");
			GivePlayerCash(playerid, 1900000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 1900000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
	case 9:
	{
	new Bet1 = random(5); // The chance 
	if (Bet1 == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Chuc mung, ngua cua ban da thang.");
			SendClientMessage(playerid, COLOR_GREY, "Ban thang $22000000.");
			GivePlayerCash(playerid, 22000000);
			PlayerInfo[playerid][pHorse] = 0;
			Businesses[InBusiness(playerid)][bSafeBalance] -= 22000000; // Removes the money from the biz
			SaveBusiness(InBusiness(playerid));
		}
	else
		{
		SendClientMessage(playerid, COLOR_GREY, "Ngua cua ban da thua.");
		PlayerInfo[playerid][pHorse] = 0;
		}	
	}
}
	return 1;
}
