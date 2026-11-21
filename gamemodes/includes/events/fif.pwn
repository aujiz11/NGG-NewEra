/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Fall into Fun Event

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

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_FIFMENU:
		{
			if(!response) return 1;
			if(PlayerInfo[playerid][pPR] < 2 && PlayerInfo[playerid][pAdmin] < 1338) return 1;
			switch(listitem)
			{
				case 0:
				{
					if(FIFEnabled == 0)
					{
						FIFEnabled = 1; 
						SendClientMessageEx(playerid, COLOR_WHITE, "Da bat gio Fall Into Fun.");
						if(IsValidDynamicPickup(FIFPickup)) DestroyDynamicPickup(FIFPickup);
						if(IsValidDynamic3DTextLabel(FIFText)) DestroyDynamic3DTextLabel(FIFText);
						FIFPickup = CreateDynamicPickup(1239, 23, FIFGamble[0], FIFGamble[1], FIFGamble[2], 0);
						FIFText = CreateDynamic3DTextLabel("Chance Gambler\n/gamblechances de cuoc het luot hoac nhan doi", COLOR_RED, FIFGamble[0], FIFGamble[1], FIFGamble[2]+0.5,10.0);
					}
					else if(FIFEnabled == 1)
					{
						FIFEnabled = 0; 
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tat gio Fall Into Fun.");
						if(IsValidDynamicPickup(FIFPickup)) DestroyDynamicPickup(FIFPickup);
						if(IsValidDynamic3DTextLabel(FIFText)) DestroyDynamic3DTextLabel(FIFText);
					}
				}
				case 1:
				{
					switch(FIFType)
					{
						case 1:
						{
							ShowPlayerDialogEx(playerid, DIALOG_FIFMENU2, DIALOG_STYLE_LIST, "Sua che do FIF", "{00FF00}Che do thuong (1 luot / 3 gio){FFFFFF}\nChe do doi (2 luot / 3 gio)\nChe do ba(3 luot / 3 gio)", "Chon", "Huy");
						}
						case 2:
						{
							ShowPlayerDialogEx(playerid, DIALOG_FIFMENU2, DIALOG_STYLE_LIST, "Sua che do FIF", "Che do thuong (1 luot / 3 gio)\n{00FF00}Che do doi (2 luot / 3 gio){FFFFFF}\nChe do ba(3 luot / 3 gio)", "Chon", "Huy");
						}
						case 3:
						{
							ShowPlayerDialogEx(playerid, DIALOG_FIFMENU2, DIALOG_STYLE_LIST, "Sua che do FIF", "Che do thuong (1 luot / 3 gio)\nChe do doi (2 luot / 3 gio)\n{00FF00}Che do ba(3 luot / 3 gio){FFFFFF}", "Chon", "Huy");
						}
					}
				}
				case 2:
				{
					if(FIFGP3 == 0)
					{
						FIFGP3 = 1;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da bat Gold & Platinum VIP x3.");
					}
					else
					{
						FIFGP3 = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tat Gold & Platinum VIP x3.");
					}
				}
				case 3:
				{
					if(FIFTimeWarrior == 0)
					{
						FIFTimeWarrior = 1;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da bat Time Warrior.");
					}
					else
					{
						FIFTimeWarrior = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tat Time Warrior.");
					}
				}
				case 4:
				{
					if(FIFGThurs == 0)
					{
						FIFGThurs = 1;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da bat Golden Thursday.");
					}
					else
					{
						FIFGThurs = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tat Golden Thursday.");
					}
				}
				case 5:
				{
					GetPlayerPos(playerid, FIFGamble[0], FIFGamble[1], FIFGamble[2]);
					if(IsValidDynamicPickup(FIFPickup)) DestroyDynamicPickup(FIFPickup);
					if(IsValidDynamic3DTextLabel(FIFText)) DestroyDynamic3DTextLabel(FIFText);
					FIFPickup = CreateDynamicPickup(1239, 23, FIFGamble[0], FIFGamble[1], FIFGamble[2], -1, -1, -1, 100.0);
					FIFText = CreateDynamic3DTextLabel("Chance Gambler\n/gamblechances de cuoc het luot hoac nhan doi", COLOR_RED, FIFGamble[0], FIFGamble[1], FIFGamble[2]+0.5,10.0);  
					SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vi tri cuoc FIF");
				}
			}
			Misc_Save();
		}
		case DIALOG_FIFMENU2:
		{
			if(!response) return 1;
			if(PlayerInfo[playerid][pPR] < 2 && PlayerInfo[playerid][pAdmin] < 1338) return 1;
			switch(listitem)
			{
				case 0:
				{
					FIFType = 1;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da dat che do FIF la x1");
				}
				case 1:
				{
					FIFType = 2;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da dat che do FIF la x2");
				}
				case 2:
				{
					FIFType = 3;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da dat che do FIF la x3");
				}
			}
			Misc_Save();
		}
	}
	return 0;
}

#if defined event_chancegambler
CMD:togchancegambler(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pPR] >= 2)
	{
		if(chancegambler == 0)
		{
			chancegambler = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da bat su kien Chance Gambler.");
		}
		else
		{
			chancegambler = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da tat su kien Chance Gambler.");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:gamblechances(playerid, params[])
{
	if(FIFEnabled == 1)
	{
		new iChances = FIFInfo[playerid][FIFChances];
		if(iChances < 1)
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co luot de cuoc.");
		if(!IsPlayerInRangeOfPoint(playerid, 20, FIFGamble[0], FIFGamble[1], FIFGamble[2]))
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o vi tri Chance Gambler.");
		ShowPlayerDialogEx(playerid, DIALOG_ROLL, DIALOG_STYLE_MSGBOX, "Chance Gambler! - Duoc an ca, nga ve khong","Ban phai do duoc so lon hon 4 de nhan doi luot.", "Do", "Huy");
	}
	else return 0;
	return 1;
}
#endif
 
CMD:chances(playerid, params[])
{
	if(chancegambler == 1)
	{
		new iChances = PlayerInfo[playerid][pRewardDrawChance] / 3;
		SendClientMessageEx(playerid, COLOR_CYAN, "Luot: %d", iChances);
	}
	else return 0;
	return 1;
}

CMD:fifmenu(playerid, params[])
{
	if(PlayerInfo[playerid][pPR] >= 2 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new FIFString[256];
		if(FIFEnabled == 0)
		{
			format(FIFString, sizeof(FIFString), "{00FF00}Bat Fall Into Fun{FFFFFF}\nDat loai gio");
		}
		else 
		{
			format(FIFString, sizeof(FIFString), "{B70000}Tat Fall Into Fun{FFFFFF}\nDat loai gio");
		}
		if(FIFGP3 == 0)
		{
			format(FIFString, sizeof(FIFString), "%s\n{00FF00}Bat GVIP & PVIP x3{FFFFFF}", FIFString);
		}
		else
		{
			format(FIFString, sizeof(FIFString), "%s\n{B70000}Bat GVIP & PVIP x3{FFFFFF}", FIFString);
	
		}
		if(FIFTimeWarrior == 0)
		{
			format(FIFString, sizeof(FIFString), "%s\n{00FF00}Bat Time Warrior{FFFFFF}", FIFString);
		}
		else
		{
			format(FIFString, sizeof(FIFString), "%s\n{B70000}Tat Time Warrior{FFFFFF}", FIFString);
	
		}
		if(FIFGThurs == 0)
		{
			format(FIFString, sizeof(FIFString), "%s\n{00FF00}Bat Golden Thursday{FFFFFF}", FIFString);
		}
		else
		{
			format(FIFString, sizeof(FIFString), "%s\n{B70000}Tat Golden Thursday{FFFFFF}", FIFString);
	
		}
		format(FIFString,sizeof(FIFString), "%s\nDat vi tri Chance Gambler", FIFString);
		ShowPlayerDialogEx(playerid, DIALOG_FIFMENU, DIALOG_STYLE_LIST, "Menu Fall Into Fun", FIFString, "Chon", "Huy");
	}
	return 1;
}

CMD:festivalload(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 1338) return 1;

	if(!GetGVarType("FallLoaded")) {
		SendRconCommand("loadfs FallFestival2014");
		SendRconCommand("loadfs FallFestival2014mapping");
		SendClientMessageEx(playerid, COLOR_GREY, "Da tai Fall Festival");
		SetGVarInt("FallLoaded", 1);
	}
	else {
		SendRconCommand("unloadfs FallFestival2014");
		SendRconCommand("unloadfs FallFestival2014mapping");
		SendClientMessageEx(playerid, COLOR_GREY, "Da go Fall Festival");
		DeleteGVar("FallLoaded");
	}


	return 1;
}