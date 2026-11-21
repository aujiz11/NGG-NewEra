/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Gift System

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

forward GiftPlayer_(playerid, giveplayerid, gtype); // For use via CallRemoteFunction
public GiftPlayer_(playerid, giveplayerid, gtype) return GiftPlayer(playerid, giveplayerid, gtype);

stock GiftPlayer(playerid, giveplayerid, gtype = 2) // Default is the normal giftbox
{
	if(gtype == 1)
	{
		if(GetPVarInt(giveplayerid, "GiftFail") >= 20) 
		{ 
			new string[128];
			GivePlayerCash(giveplayerid, 20000);
			SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan $20,000!");
			format(string, sizeof(string), "* %s vua nhan $20,000!", GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
			format(string, sizeof(string), "* %s(%d) was just gifted $20,000, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
			return true;
		}
		SetPVarInt(giveplayerid, "GiftFail", GetPVarInt(giveplayerid, "GiftFail")+1);
	}
	
	new string[128], value = 0;
	if(gtype == 1)
	{
		if(IsPlayerConnected(giveplayerid))
		{
			if(playerid != MAX_PLAYERS && PlayerInfo[playerid][pAdmin] < 2) return true;
			
			if(playerid != MAX_PLAYERS) return GiftPlayer(MAX_PLAYERS, giveplayerid, 1);
			
			new randgift = random(100);
			printf("randgift %d", randgift);
			switch(randgift)
			{
				case 0..50: // cat 1 - Common gifts
				{
					new randy = random(32);
					printf("cat 1 %d", randy);
					if(randy == 0)
					{
						if(dgVar[dgMoney][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCash(giveplayerid, dgVar[dgMoney][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan $%s!", number_format(dgVar[dgMoney][2]));
						format(string, sizeof(string), "* %s vua nhan $%s!", GetPlayerNameEx(giveplayerid), number_format(dgVar[dgMoney][2]));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMoney][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted $%s, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(dgVar[dgMoney][2]));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 1)
					{
						if(dgVar[dgRimKit][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pRimMod] += dgVar[dgRimKit][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo do mam!", dgVar[dgRimKit][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo do mam!", GetPlayerNameEx(giveplayerid), dgVar[dgRimKit][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRimKit][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d rimkit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRimKit][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 2)
					{
						if(dgVar[dgFirework][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirework] += dgVar[dgFirework][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d phao hoa!", dgVar[dgFirework][2]);
						format(string, sizeof(string), "* %s vua nhan %d phao hoa!", GetPlayerNameEx(giveplayerid), dgVar[dgFirework][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirework][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d firework(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirework][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 3)
					{
						if(dgVar[dgGVIP][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPExVoucher] += dgVar[dgGVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP bay ngay!", dgVar[dgGVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 4)
					{
						if(dgVar[dgGVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPVoucher] += dgVar[dgGVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP mot thang!", dgVar[dgGVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}

					if(randy == 5)
					{
						if(dgVar[dgSVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPExVoucher] += dgVar[dgSVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP bay ngay!", dgVar[dgSVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 6)
					{
						if(dgVar[dgSVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPVoucher] += dgVar[dgSVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP mot thang!", dgVar[dgSVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 7)
					{
						if(dgVar[dgCarSlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehicleSlot] += dgVar[dgCarSlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua xe!", dgVar[dgCarSlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua xe!", GetPlayerNameEx(giveplayerid), dgVar[dgCarSlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarSlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarSlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 8)
					{
						if(dgVar[dgToySlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pToySlot] += dgVar[dgToySlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua toy!", dgVar[dgToySlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua toy!", GetPlayerNameEx(giveplayerid), dgVar[dgToySlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgToySlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Toy Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgToySlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 9)
					{
						if(dgVar[dgArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						new Float: armor;
						GetArmour(giveplayerid, armor);
						
						if(armor+dgVar[dgArmor][2] >= 100) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetArmour(giveplayerid, armor + dgVar[dgArmor][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d giap!", dgVar[dgArmor][2]);
						format(string, sizeof(string), "* %s vua nhan %d giap!", GetPlayerNameEx(giveplayerid), dgVar[dgArmor][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Armour, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgArmor][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 10)
					{
						if(dgVar[dgFirstaid][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirstaid] += dgVar[dgFirstaid][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo so cuu!", dgVar[dgFirstaid][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo so cuu!", GetPlayerNameEx(giveplayerid), dgVar[dgFirstaid][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirstaid][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Firstaid(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirstaid][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 11)
					{
						if(dgVar[dgDDFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Door");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Dynamic Door Flag!", dgVar[dgDDFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Door!", GetPlayerNameEx(giveplayerid), dgVar[dgDDFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgDDFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Door Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgDDFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 12)
					{
						if(dgVar[dgGateFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Gate");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d flag cong!", dgVar[dgGateFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Gate!", GetPlayerNameEx(giveplayerid), dgVar[dgGateFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGateFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Gate Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGateFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 13)
					{
						if(dgVar[dgCredits][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCredits(giveplayerid, dgVar[dgCredits][2], 1);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Credit!", dgVar[dgCredits][2]);
						format(string, sizeof(string), "* %s vua nhan %d Credit!", GetPlayerNameEx(giveplayerid), dgVar[dgCredits][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCredits][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Credit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCredits][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 14)
					{
						if(dgVar[dgPriorityAd][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pAdvertVoucher] += dgVar[dgPriorityAd][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Priority Advertisement Voucher!", dgVar[dgPriorityAd][2]);
						format(string, sizeof(string), "* %s vua nhan %d Priority Advertisement Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgPriorityAd][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPriorityAd][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Priority Advertisement Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPriorityAd][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 15)
					{
						if(dgVar[dgHealthNArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetHealth(giveplayerid, 100.0);
						SetArmour(giveplayerid, 100);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan day mau va giap!");
						format(string, sizeof(string), "* %s vua nhan %d day mau va giap!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgHealthNArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Full Health & Armor, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 16)
					{
						if(dgVar[dgGiftReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGiftVoucher] += dgVar[dgGiftReset][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Gift Reset Voucher!", dgVar[dgGiftReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d Gift Reset Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgGiftReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGiftReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Gift Reset Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGiftReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 17)
					{
						if(dgVar[dgMaterial][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pMats] += dgVar[dgMaterial][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d vat lieu!", dgVar[dgMaterial][2]);
						format(string, sizeof(string), "* %s vua nhan %d vat lieu!", GetPlayerNameEx(giveplayerid), dgVar[dgMaterial][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMaterial][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Material(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgMaterial][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 18)
					{
						if(dgVar[dgWarning][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						if(dgVar[dgWarning][2] > 3 || dgVar[dgWarning][2] < 0)
						{						
							if(PlayerInfo[giveplayerid][pWarns] == 0) return GiftPlayer(playerid, giveplayerid, 1);
							
							PlayerInfo[giveplayerid][pWarns] -= dgVar[dgWarning][2];
						}
						else
							return GiftPlayer(playerid, giveplayerid, 1);
							
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot xoa canh bao!", dgVar[dgWarning][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot xoa canh bao!", GetPlayerNameEx(giveplayerid), dgVar[dgWarning][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgWarning][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Warning(s) Removal, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgWarning][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 19)
					{
						if(dgVar[dgPot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][0] += dgVar[dgPot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d can sa!", dgVar[dgPot][2]);
						format(string, sizeof(string), "* %s vua nhan %d can sa!", GetPlayerNameEx(giveplayerid), dgVar[dgPot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d pot, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 20)
					{
						if(dgVar[dgCrack][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][1] += dgVar[dgCrack][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Crack!", dgVar[dgCrack][2]);
						format(string, sizeof(string), "* %s vua nhan %d Crack!", GetPlayerNameEx(giveplayerid), dgVar[dgCrack][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCrack][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Crack, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCrack][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 21)
					{
						if(dgVar[dgPaintballToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPaintTokens] += dgVar[dgPaintballToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Paintball Token!", dgVar[dgPaintballToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d Paintball Token!", GetPlayerNameEx(giveplayerid), dgVar[dgPaintballToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPaintballToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Paintball Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPaintballToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 22)
					{
						if(dgVar[dgVIPToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pTokens] += dgVar[dgVIPToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d VIP Token!", dgVar[dgVIPToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d VIP Token!", GetPlayerNameEx(giveplayerid), dgVar[dgVIPToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgVIPToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d VIP Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgVIPToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 23)
					{
						if(dgVar[dgRespectPoint][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pExp] += dgVar[dgRespectPoint][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d diem kinh nghiem!", dgVar[dgRespectPoint][2]);
						format(string, sizeof(string), "* %s vua nhan %d diem kinh nghiem!", GetPlayerNameEx(giveplayerid), dgVar[dgRespectPoint][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRespectPoint][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Respect Point(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRespectPoint][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 24)
					{
						if(dgVar[dgCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehVoucher] += dgVar[dgCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Car Voucher!", dgVar[dgCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 25)
					{
						if(dgVar[dgBuddyInvite][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] != 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDonateRank] = 1;
						PlayerInfo[giveplayerid][pTempVIP] = 180;
						PlayerInfo[giveplayerid][pBuddyInvited] = 1;
						format(string, sizeof(string), "BUDDY INVITE: %s(%d) has been invited to VIP by System", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/setvip.log", string);
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Buddy Invite!");
						format(string, sizeof(string), "* %s vua nhan mot BuddyInvite!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						format(string, sizeof(string), "* %s was just gifted a BuddyInvite, enjoy!", GetPlayerNameEx(giveplayerid));
						dgVar[dgBuddyInvite][1]--;
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 26)
					{
						if(dgVar[dgLaser][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = 18643;
								PlayerToyInfo[giveplayerid][v][ptBone] = 6;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = 18643;
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Do khong con o trong, ban duoc cap tam mot o de dung/ban/doi laser.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: Sau khi ban laser, o toy duoc cap tam se bi xoa.");
									break;
								}	
							}
						}
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Laser!");
						format(string, sizeof(string), "* %s vua nhan mot Laser!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgLaser][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Laser, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 27)
					{
						if(dgVar[dgCustomToy][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						/*new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = dgVar[dgCustomToy][2];
								PlayerToyInfo[giveplayerid][v][ptBone] = 1;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = dgVar[dgCustomToy][2];
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Due to you not having any available slots, we've temporarily gave you an additional slot to use/sell/trade your custom toy.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Note: Please take note that after selling the custom toy, the temporarily additional toy slot will be removed.");
									break;
								}	
							}
						}*/

						AddFlag(giveplayerid, INVALID_PLAYER_ID, "[GIFTBOX] 1x Custom Toy");
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Custom Toy!");
						format(string, sizeof(string), "* %s vua nhan mot Custom Toy!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCustomToy][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Custom Toy, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 28)
					{
						if(dgVar[dgAdmuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pADMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pADMuteTotal] -= dgVar[dgAdmuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam quang cao!", dgVar[dgAdmuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam quang cao!", GetPlayerNameEx(giveplayerid), dgVar[dgAdmuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgAdmuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Admute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgAdmuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 29)
					{
						if(dgVar[dgNewbieMuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pNMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pNMuteTotal] -= dgVar[dgNewbieMuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam Newbie!", dgVar[dgNewbieMuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam Newbie!", GetPlayerNameEx(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgNewbieMuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Newbie Mute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 30)
					{
						if(dgVar[dgRestrictedCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pCarVoucher] += dgVar[dgRestrictedCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Restricted Car Voucher!", dgVar[dgRestrictedCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Restricted Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRestrictedCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Restricted Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 31)
					{
						if(dgVar[dgPlatinumVIPVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][3] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPVIPVoucher] += dgVar[dgPlatinumVIPVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d PVIP Voucher 1 thang!", dgVar[dgPlatinumVIPVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d PVIP Voucher 1 thang!", GetPlayerNameEx(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPlatinumVIPVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d 1 month PVIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					else return SendClientMessageEx(giveplayerid, COLOR_RED, "Hop qua dong da het qua, hay thu lai.");
				}
				case 51..80: // cat 2 - Slightly more rare gifts
				{
					new randy = random(32);
					printf("cat 1 %d", randy);

					if(randy == 0)
					{
						if(dgVar[dgMoney][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCash(giveplayerid, dgVar[dgMoney][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan $%s!", number_format(dgVar[dgMoney][2]));
						format(string, sizeof(string), "* %s vua nhan $%s!", GetPlayerNameEx(giveplayerid), number_format(dgVar[dgMoney][2]));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMoney][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted $%s, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(dgVar[dgMoney][2]));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 1)
					{
						if(dgVar[dgRimKit][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pRimMod] += dgVar[dgRimKit][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo do mam!", dgVar[dgRimKit][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo do mam!", GetPlayerNameEx(giveplayerid), dgVar[dgRimKit][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRimKit][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d rimkit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRimKit][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 2)
					{
						if(dgVar[dgFirework][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirework] += dgVar[dgFirework][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d phao hoa!", dgVar[dgFirework][2]);
						format(string, sizeof(string), "* %s vua nhan %d phao hoa!", GetPlayerNameEx(giveplayerid), dgVar[dgFirework][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirework][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d firework(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirework][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 3)
					{
						if(dgVar[dgGVIP][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPExVoucher] += dgVar[dgGVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP bay ngay!", dgVar[dgGVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 4)
					{
						if(dgVar[dgGVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPVoucher] += dgVar[dgGVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP mot thang!", dgVar[dgGVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 5)
					{
						if(dgVar[dgSVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPExVoucher] += dgVar[dgSVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP bay ngay!", dgVar[dgSVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 6)
					{
						if(dgVar[dgSVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPVoucher] += dgVar[dgSVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP mot thang!", dgVar[dgSVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 7)
					{
						if(dgVar[dgCarSlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehicleSlot] += dgVar[dgCarSlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua xe!", dgVar[dgCarSlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua xe!", GetPlayerNameEx(giveplayerid), dgVar[dgCarSlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarSlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarSlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 8)
					{
						if(dgVar[dgToySlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pToySlot] += dgVar[dgToySlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua toy!", dgVar[dgToySlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua toy!", GetPlayerNameEx(giveplayerid), dgVar[dgToySlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgToySlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Toy Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgToySlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 9)
					{
						if(dgVar[dgArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						new Float: armor;
						GetArmour(giveplayerid, armor);
						
						if(armor+dgVar[dgArmor][2] >= 100) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetArmour(giveplayerid, armor + dgVar[dgArmor][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d giap!", dgVar[dgArmor][2]);
						format(string, sizeof(string), "* %s vua nhan %d giap!", GetPlayerNameEx(giveplayerid), dgVar[dgArmor][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Armour, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgArmor][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 10)
					{
						if(dgVar[dgFirstaid][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirstaid] += dgVar[dgFirstaid][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo so cuu!", dgVar[dgFirstaid][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo so cuu!", GetPlayerNameEx(giveplayerid), dgVar[dgFirstaid][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirstaid][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Firstaid(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirstaid][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 11)
					{
						if(dgVar[dgDDFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Door");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Dynamic Door Flag!", dgVar[dgDDFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Door!", GetPlayerNameEx(giveplayerid), dgVar[dgDDFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgDDFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Door Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgDDFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 12)
					{
						if(dgVar[dgGateFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Gate");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Dynamic Door Flag!", dgVar[dgGateFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Gate!", GetPlayerNameEx(giveplayerid), dgVar[dgGateFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGateFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Gate Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGateFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 13)
					{
						if(dgVar[dgCredits][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCredits(giveplayerid, dgVar[dgCredits][2], 1);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Credit!", dgVar[dgCredits][2]);
						format(string, sizeof(string), "* %s vua nhan %d Credit!", GetPlayerNameEx(giveplayerid), dgVar[dgCredits][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCredits][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Credit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCredits][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 14)
					{
						if(dgVar[dgPriorityAd][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pAdvertVoucher] += dgVar[dgPriorityAd][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Priority Advertisement Voucher!", dgVar[dgPriorityAd][2]);
						format(string, sizeof(string), "* %s vua nhan %d Priority Advertisement Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgPriorityAd][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPriorityAd][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Priority Advertisement Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPriorityAd][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 15)
					{
						if(dgVar[dgHealthNArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetHealth(giveplayerid, 100.0);
						SetArmour(giveplayerid, 100);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan day mau va giap!");
						format(string, sizeof(string), "* %s vua nhan %d day mau va giap!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgHealthNArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Full Health & Armor, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 16)
					{
						if(dgVar[dgGiftReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGiftVoucher] += dgVar[dgGiftReset][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Gift Reset Voucher!", dgVar[dgGiftReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d Gift Reset Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgGiftReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGiftReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Gift Reset Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGiftReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 17)
					{
						if(dgVar[dgMaterial][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pMats] += dgVar[dgMaterial][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d vat lieu!", dgVar[dgMaterial][2]);
						format(string, sizeof(string), "* %s vua nhan %d vat lieu!", GetPlayerNameEx(giveplayerid), dgVar[dgMaterial][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMaterial][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Material(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgMaterial][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 18)
					{
						if(dgVar[dgWarning][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						if(dgVar[dgWarning][2] > 3 || dgVar[dgWarning][2] < 0)
						{						
							if(PlayerInfo[giveplayerid][pWarns] == 0) return GiftPlayer(playerid, giveplayerid, 1);
							
							PlayerInfo[giveplayerid][pWarns] -= dgVar[dgWarning][2];
						}
						else
							return GiftPlayer(playerid, giveplayerid, 1);
							
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot xoa canh bao!", dgVar[dgWarning][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot xoa canh bao!", GetPlayerNameEx(giveplayerid), dgVar[dgWarning][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgWarning][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Warning(s) Removal, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgWarning][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 19)
					{
						if(dgVar[dgPot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][0] += dgVar[dgPot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d can sa!", dgVar[dgPot][2]);
						format(string, sizeof(string), "* %s vua nhan %d can sa!", GetPlayerNameEx(giveplayerid), dgVar[dgPot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d pot, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 20)
					{
						if(dgVar[dgCrack][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][1] += dgVar[dgCrack][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Crack!", dgVar[dgCrack][2]);
						format(string, sizeof(string), "* %s vua nhan %d Crack!", GetPlayerNameEx(giveplayerid), dgVar[dgCrack][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCrack][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Crack, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCrack][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 21)
					{
						if(dgVar[dgPaintballToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPaintTokens] += dgVar[dgPaintballToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Paintball Token!", dgVar[dgPaintballToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d Paintball Token!", GetPlayerNameEx(giveplayerid), dgVar[dgPaintballToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPaintballToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Paintball Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPaintballToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 22)
					{
						if(dgVar[dgVIPToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pTokens] += dgVar[dgVIPToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d VIP Token!", dgVar[dgVIPToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d VIP Token!", GetPlayerNameEx(giveplayerid), dgVar[dgVIPToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgVIPToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d VIP Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgVIPToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 23)
					{
						if(dgVar[dgRespectPoint][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pExp] += dgVar[dgRespectPoint][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d diem kinh nghiem!", dgVar[dgRespectPoint][2]);
						format(string, sizeof(string), "* %s vua nhan %d diem kinh nghiem!", GetPlayerNameEx(giveplayerid), dgVar[dgRespectPoint][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRespectPoint][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Respect Point(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRespectPoint][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 24)
					{
						if(dgVar[dgCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehVoucher] += dgVar[dgCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Car Voucher!", dgVar[dgCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 25)
					{
						if(dgVar[dgBuddyInvite][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] != 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDonateRank] = 1;
						PlayerInfo[giveplayerid][pTempVIP] = 180;
						PlayerInfo[giveplayerid][pBuddyInvited] = 1;
						format(string, sizeof(string), "BUDDY INVITE: %s(%d) has been invited to VIP by System", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/setvip.log", string);
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Buddy Invite!");
						format(string, sizeof(string), "* %s vua nhan mot BuddyInvite!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						format(string, sizeof(string), "* %s was just gifted a BuddyInvite, enjoy!", GetPlayerNameEx(giveplayerid));
						dgVar[dgBuddyInvite][1]--;
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 26)
					{
						if(dgVar[dgLaser][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = 18643;
								PlayerToyInfo[giveplayerid][v][ptBone] = 6;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = 18643;
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Do khong con o trong, ban duoc cap tam mot o de dung/ban/doi laser.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: Sau khi ban laser, o toy duoc cap tam se bi xoa.");
									break;
								}	
							}
						}
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Laser!");
						format(string, sizeof(string), "* %s vua nhan mot Laser!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgLaser][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Laser, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 27)
					{
						if(dgVar[dgCustomToy][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = dgVar[dgCustomToy][2];
								PlayerToyInfo[giveplayerid][v][ptBone] = 1;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = dgVar[dgCustomToy][2];
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Ban het o chua toy nen duoc cap tam mot o de dung, ban hoac trao doi Custom Toy.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: O chua toy tam thoi se bi thu hoi sau khi ban Custom Toy.");
									break;
								}	
							}
						}
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Custom Toy!");
						format(string, sizeof(string), "* %s vua nhan mot Custom Toy!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCustomToy][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Custom Toy, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 28)
					{
						if(dgVar[dgAdmuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pADMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pADMuteTotal] -= dgVar[dgAdmuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam quang cao!", dgVar[dgAdmuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam quang cao!", GetPlayerNameEx(giveplayerid), dgVar[dgAdmuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgAdmuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Admute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgAdmuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 29)
					{
						if(dgVar[dgNewbieMuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pNMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pNMuteTotal] -= dgVar[dgNewbieMuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam Newbie!", dgVar[dgNewbieMuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam Newbie!", GetPlayerNameEx(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgNewbieMuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Newbie Mute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 30)
					{
						if(dgVar[dgRestrictedCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pCarVoucher] += dgVar[dgRestrictedCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Restricted Car Voucher!", dgVar[dgRestrictedCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Restricted Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRestrictedCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Restricted Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 31)
					{
						if(dgVar[dgPlatinumVIPVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][3] == 1) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPVIPVoucher] += dgVar[dgPlatinumVIPVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d PVIP Voucher 1 thang!", dgVar[dgPlatinumVIPVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d PVIP Voucher 1 thang!", GetPlayerNameEx(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPlatinumVIPVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d 1 month PVIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					else return SendClientMessageEx(giveplayerid, COLOR_RED, "Hop qua dong da het qua, hay thu lai.");
				}
				case 81..95: // cat 3 rarish
				{
					new randy = random(32);
					printf("cat 1 %d", randy);

					if(randy == 0)
					{
						if(dgVar[dgMoney][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCash(giveplayerid, dgVar[dgMoney][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan $%s!", number_format(dgVar[dgMoney][2]));
						format(string, sizeof(string), "* %s vua nhan $%s!", GetPlayerNameEx(giveplayerid), number_format(dgVar[dgMoney][2]));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMoney][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted $%s, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(dgVar[dgMoney][2]));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 1)
					{
						if(dgVar[dgRimKit][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pRimMod] += dgVar[dgRimKit][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo do mam!", dgVar[dgRimKit][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo do mam!", GetPlayerNameEx(giveplayerid), dgVar[dgRimKit][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRimKit][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d rimkit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRimKit][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 2)
					{
						if(dgVar[dgFirework][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirework] += dgVar[dgFirework][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d phao hoa!", dgVar[dgFirework][2]);
						format(string, sizeof(string), "* %s vua nhan %d phao hoa!", GetPlayerNameEx(giveplayerid), dgVar[dgFirework][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirework][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d firework(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirework][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 3)
					{
						if(dgVar[dgGVIP][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPExVoucher] += dgVar[dgGVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP bay ngay!", dgVar[dgGVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 4)
					{
						if(dgVar[dgGVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPVoucher] += dgVar[dgGVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP mot thang!", dgVar[dgGVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 5)
					{
						if(dgVar[dgSVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPExVoucher] += dgVar[dgSVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP bay ngay!", dgVar[dgSVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 6)
					{
						if(dgVar[dgSVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPVoucher] += dgVar[dgSVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP mot thang!", dgVar[dgSVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 7)
					{
						if(dgVar[dgCarSlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehicleSlot] += dgVar[dgCarSlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua xe!", dgVar[dgCarSlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua xe!", GetPlayerNameEx(giveplayerid), dgVar[dgCarSlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarSlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarSlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 8)
					{
						if(dgVar[dgToySlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pToySlot] += dgVar[dgToySlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua toy!", dgVar[dgToySlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua toy!", GetPlayerNameEx(giveplayerid), dgVar[dgToySlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgToySlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Toy Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgToySlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 9)
					{
						if(dgVar[dgArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						new Float: armor;
						GetArmour(giveplayerid, armor);
						
						if(armor+dgVar[dgArmor][2] >= 100) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetArmour(giveplayerid, armor + dgVar[dgArmor][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d giap!", dgVar[dgArmor][2]);
						format(string, sizeof(string), "* %s vua nhan %d giap!", GetPlayerNameEx(giveplayerid), dgVar[dgArmor][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Armour, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgArmor][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 10)
					{
						if(dgVar[dgFirstaid][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirstaid] += dgVar[dgFirstaid][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo so cuu!", dgVar[dgFirstaid][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo so cuu!", GetPlayerNameEx(giveplayerid), dgVar[dgFirstaid][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirstaid][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Firstaid(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirstaid][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 11)
					{
						if(dgVar[dgDDFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Door");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Dynamic Door Flag!", dgVar[dgDDFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Door!", GetPlayerNameEx(giveplayerid), dgVar[dgDDFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgDDFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Door Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgDDFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 12)
					{
						if(dgVar[dgGateFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Gate");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Dynamic Door Flag!", dgVar[dgGateFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Gate!", GetPlayerNameEx(giveplayerid), dgVar[dgGateFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGateFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Gate Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGateFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 13)
					{
						if(dgVar[dgCredits][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCredits(giveplayerid, dgVar[dgCredits][2], 1);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Credit!", dgVar[dgCredits][2]);
						format(string, sizeof(string), "* %s vua nhan %d Credit!", GetPlayerNameEx(giveplayerid), dgVar[dgCredits][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCredits][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Credit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCredits][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 14)
					{
						if(dgVar[dgPriorityAd][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pAdvertVoucher] += dgVar[dgPriorityAd][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Priority Advertisement Voucher!", dgVar[dgPriorityAd][2]);
						format(string, sizeof(string), "* %s vua nhan %d Priority Advertisement Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgPriorityAd][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPriorityAd][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Priority Advertisement Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPriorityAd][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 15)
					{
						if(dgVar[dgHealthNArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetHealth(giveplayerid, 100.0);
						SetArmour(giveplayerid, 100);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan day mau va giap!");
						format(string, sizeof(string), "* %s vua nhan %d day mau va giap!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgHealthNArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Full Health & Armor, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 16)
					{
						if(dgVar[dgGiftReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGiftVoucher] += dgVar[dgGiftReset][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Gift Reset Voucher!", dgVar[dgGiftReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d Gift Reset Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgGiftReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGiftReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Gift Reset Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGiftReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 17)
					{
						if(dgVar[dgMaterial][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pMats] += dgVar[dgMaterial][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d vat lieu!", dgVar[dgMaterial][2]);
						format(string, sizeof(string), "* %s vua nhan %d vat lieu!", GetPlayerNameEx(giveplayerid), dgVar[dgMaterial][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMaterial][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Material(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgMaterial][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 18)
					{
						if(dgVar[dgWarning][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						if(dgVar[dgWarning][2] > 3 || dgVar[dgWarning][2] < 0)
						{						
							if(PlayerInfo[giveplayerid][pWarns] == 0) return GiftPlayer(playerid, giveplayerid, 1);
							
							PlayerInfo[giveplayerid][pWarns] -= dgVar[dgWarning][2];
						}
						else
							return GiftPlayer(playerid, giveplayerid, 1);
							
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot xoa canh bao!", dgVar[dgWarning][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot xoa canh bao!", GetPlayerNameEx(giveplayerid), dgVar[dgWarning][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgWarning][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Warning(s) Removal, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgWarning][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 19)
					{
						if(dgVar[dgPot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][0] += dgVar[dgPot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d can sa!", dgVar[dgPot][2]);
						format(string, sizeof(string), "* %s vua nhan %d can sa!", GetPlayerNameEx(giveplayerid), dgVar[dgPot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d pot, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 20)
					{
						if(dgVar[dgCrack][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][1] += dgVar[dgCrack][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Crack!", dgVar[dgCrack][2]);
						format(string, sizeof(string), "* %s vua nhan %d Crack!", GetPlayerNameEx(giveplayerid), dgVar[dgCrack][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCrack][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Crack, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCrack][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 21)
					{
						if(dgVar[dgPaintballToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPaintTokens] += dgVar[dgPaintballToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Paintball Token!", dgVar[dgPaintballToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d Paintball Token!", GetPlayerNameEx(giveplayerid), dgVar[dgPaintballToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPaintballToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Paintball Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPaintballToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 22)
					{
						if(dgVar[dgVIPToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pTokens] += dgVar[dgVIPToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d VIP Token!", dgVar[dgVIPToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d VIP Token!", GetPlayerNameEx(giveplayerid), dgVar[dgVIPToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgVIPToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d VIP Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgVIPToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 23)
					{
						if(dgVar[dgRespectPoint][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pExp] += dgVar[dgRespectPoint][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d diem kinh nghiem!", dgVar[dgRespectPoint][2]);
						format(string, sizeof(string), "* %s vua nhan %d diem kinh nghiem!", GetPlayerNameEx(giveplayerid), dgVar[dgRespectPoint][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRespectPoint][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Respect Point(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRespectPoint][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 24)
					{
						if(dgVar[dgCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehVoucher] += dgVar[dgCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Car Voucher!", dgVar[dgCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 25)
					{
						if(dgVar[dgBuddyInvite][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] != 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDonateRank] = 1;
						PlayerInfo[giveplayerid][pTempVIP] = 180;
						PlayerInfo[giveplayerid][pBuddyInvited] = 1;
						format(string, sizeof(string), "BUDDY INVITE: %s(%d) has been invited to VIP by System", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/setvip.log", string);					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Buddy Invite!");
						format(string, sizeof(string), "* %s vua nhan mot BuddyInvite!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgBuddyInvite][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a BuddyInvite, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 26)
					{
						if(dgVar[dgLaser][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = 18643;
								PlayerToyInfo[giveplayerid][v][ptBone] = 6;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = 18643;
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Do khong con o trong, ban duoc cap tam mot o de dung/ban/doi laser.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: Sau khi ban laser, o toy duoc cap tam se bi xoa.");
									break;
								}	
							}
						}
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Laser!");
						format(string, sizeof(string), "* %s vua nhan mot Laser!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgLaser][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Laser, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 27)
					{
						if(dgVar[dgCustomToy][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = dgVar[dgCustomToy][2];
								PlayerToyInfo[giveplayerid][v][ptBone] = 1;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = dgVar[dgCustomToy][2];
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Ban het o chua toy nen duoc cap tam mot o de dung, ban hoac trao doi Custom Toy.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: O chua toy tam thoi se bi thu hoi sau khi ban Custom Toy.");
									break;
								}	
							}
						}
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Custom Toy!");
						format(string, sizeof(string), "* %s vua nhan mot Custom Toy!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCustomToy][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Custom Toy, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 28)
					{
						if(dgVar[dgAdmuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pADMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pADMuteTotal] -= dgVar[dgAdmuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam quang cao!", dgVar[dgAdmuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam quang cao!", GetPlayerNameEx(giveplayerid), dgVar[dgAdmuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgAdmuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Admute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgAdmuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 29)
					{
						if(dgVar[dgNewbieMuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pNMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pNMuteTotal] -= dgVar[dgNewbieMuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam Newbie!", dgVar[dgNewbieMuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam Newbie!", GetPlayerNameEx(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgNewbieMuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Newbie Mute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 30)
					{
						if(dgVar[dgRestrictedCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pCarVoucher] += dgVar[dgRestrictedCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Restricted Car Voucher!", dgVar[dgRestrictedCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Restricted Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRestrictedCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Restricted Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 31)
					{
						if(dgVar[dgPlatinumVIPVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][3] == 2) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPVIPVoucher] += dgVar[dgPlatinumVIPVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d PVIP Voucher 1 thang!", dgVar[dgPlatinumVIPVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d PVIP Voucher 1 thang!", GetPlayerNameEx(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPlatinumVIPVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d 1 month PVIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					else return SendClientMessageEx(giveplayerid, COLOR_RED, "Hop qua dong da het qua, hay thu lai.");			
				}
				case 96..100: // cat 4 super rare
				{
					new randy = random(32);
					printf("cat 1 %d", randy);

					if(randy == 0)
					{
						if(dgVar[dgMoney][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMoney][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCash(giveplayerid, dgVar[dgMoney][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan $%s!", number_format(dgVar[dgMoney][2]));
						format(string, sizeof(string), "* %s vua nhan $%s!", GetPlayerNameEx(giveplayerid), number_format(dgVar[dgMoney][2]));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMoney][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted $%s, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(dgVar[dgMoney][2]));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 1)
					{
						if(dgVar[dgRimKit][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRimKit][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pRimMod] += dgVar[dgRimKit][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo do mam!", dgVar[dgRimKit][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo do mam!", GetPlayerNameEx(giveplayerid), dgVar[dgRimKit][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRimKit][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d rimkit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRimKit][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 2)
					{
						if(dgVar[dgFirework][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirework][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirework] += dgVar[dgFirework][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d phao hoa!", dgVar[dgFirework][2]);
						format(string, sizeof(string), "* %s vua nhan %d phao hoa!", GetPlayerNameEx(giveplayerid), dgVar[dgFirework][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirework][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d firework(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirework][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 3)
					{
						if(dgVar[dgGVIP][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPExVoucher] += dgVar[dgGVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP bay ngay!", dgVar[dgGVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 4)
					{
						if(dgVar[dgGVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGVIPEx][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGVIPVoucher] += dgVar[dgGVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Gold VIP mot thang!", dgVar[dgGVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Gold VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgGVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Gold VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 5)
					{
						if(dgVar[dgSVIP][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIP][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPExVoucher] += dgVar[dgSVIP][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP bay ngay!", dgVar[dgSVIP][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP bay ngay!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIP][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIP][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Seven day Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIP][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 6)
					{
						if(dgVar[dgSVIPEx][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgSVIPEx][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pSVIPVoucher] += dgVar[dgSVIPEx][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d voucher Silver VIP mot thang!", dgVar[dgSVIPEx][2]);
						format(string, sizeof(string), "* %s vua nhan %d voucher Silver VIP mot thang!", GetPlayerNameEx(giveplayerid), dgVar[dgSVIPEx][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgSVIPEx][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d One Month Silver VIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgSVIPEx][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 7)
					{
						if(dgVar[dgCarSlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehicleSlot] += dgVar[dgCarSlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua xe!", dgVar[dgCarSlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua xe!", GetPlayerNameEx(giveplayerid), dgVar[dgCarSlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarSlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarSlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 8)
					{
						if(dgVar[dgToySlot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarSlot][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pToySlot] += dgVar[dgToySlot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d o chua toy!", dgVar[dgToySlot][2]);
						format(string, sizeof(string), "* %s vua nhan %d o chua toy!", GetPlayerNameEx(giveplayerid), dgVar[dgToySlot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgToySlot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Toy Slot(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgToySlot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 9)
					{
						if(dgVar[dgArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgArmor][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						new Float: armor;
						GetArmour(giveplayerid, armor);
						
						if(armor+dgVar[dgArmor][2] >= 100) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetArmour(giveplayerid, armor + dgVar[dgArmor][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d giap!", dgVar[dgArmor][2]);
						format(string, sizeof(string), "* %s vua nhan %d giap!", GetPlayerNameEx(giveplayerid), dgVar[dgArmor][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Armour, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgArmor][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 10)
					{
						if(dgVar[dgFirstaid][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgFirstaid][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pFirstaid] += dgVar[dgFirstaid][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d bo so cuu!", dgVar[dgFirstaid][2]);
						format(string, sizeof(string), "* %s vua nhan %d bo so cuu!", GetPlayerNameEx(giveplayerid), dgVar[dgFirstaid][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgFirstaid][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Firstaid(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgFirstaid][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 11)
					{
						if(dgVar[dgDDFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgDDFlag][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Door");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Dynamic Door Flag!", dgVar[dgDDFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Door!", GetPlayerNameEx(giveplayerid), dgVar[dgDDFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgDDFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Door Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgDDFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 12)
					{
						if(dgVar[dgGateFlag][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGateFlag][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						AddFlag(giveplayerid, INVALID_PLAYER_ID, "Hop qua dong: 1 Dynamic Gate");
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Dynamic Door Flag!", dgVar[dgGateFlag][2]);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Co the can toi 48 gio de nhan thuong..");
						format(string, sizeof(string), "* %s vua nhan %d flag Dynamic Gate!", GetPlayerNameEx(giveplayerid), dgVar[dgGateFlag][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGateFlag][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Dynamic Gate Flag(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGateFlag][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 13)
					{
						if(dgVar[dgCredits][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCredits][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						GivePlayerCredits(giveplayerid, dgVar[dgCredits][2], 1);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Credit!", dgVar[dgCredits][2]);
						format(string, sizeof(string), "* %s vua nhan %d Credit!", GetPlayerNameEx(giveplayerid), dgVar[dgCredits][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCredits][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Credit(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCredits][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 14)
					{
						if(dgVar[dgPriorityAd][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPriorityAd][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pAdvertVoucher] += dgVar[dgPriorityAd][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Priority Advertisement Voucher!", dgVar[dgPriorityAd][2]);
						format(string, sizeof(string), "* %s vua nhan %d Priority Advertisement Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgPriorityAd][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPriorityAd][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Priority Advertisement Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPriorityAd][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 15)
					{
						if(dgVar[dgHealthNArmor][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgHealthNArmor][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						SetHealth(giveplayerid, 100.0);
						SetArmour(giveplayerid, 100);
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan day mau va giap!");
						format(string, sizeof(string), "* %s vua nhan %d day mau va giap!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgHealthNArmor][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Full Health & Armor, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 16)
					{
						if(dgVar[dgGiftReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgGiftReset][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pGiftVoucher] += dgVar[dgGiftReset][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Gift Reset Voucher!", dgVar[dgGiftReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d Gift Reset Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgGiftReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgGiftReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Gift Reset Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgGiftReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 17)
					{
						if(dgVar[dgMaterial][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgMaterial][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pMats] += dgVar[dgMaterial][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d vat lieu!", dgVar[dgMaterial][2]);
						format(string, sizeof(string), "* %s vua nhan %d vat lieu!", GetPlayerNameEx(giveplayerid), dgVar[dgMaterial][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgMaterial][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Material(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgMaterial][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 18)
					{
						if(dgVar[dgWarning][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgWarning][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						if(dgVar[dgWarning][2] > 3 || dgVar[dgWarning][2] < 0)
						{						
							if(PlayerInfo[giveplayerid][pWarns] == 0) return GiftPlayer(playerid, giveplayerid, 1);
							
							PlayerInfo[giveplayerid][pWarns] -= dgVar[dgWarning][2];
						}
						else
							return GiftPlayer(playerid, giveplayerid, 1);
							
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot xoa canh bao!", dgVar[dgWarning][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot xoa canh bao!", GetPlayerNameEx(giveplayerid), dgVar[dgWarning][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgWarning][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Warning(s) Removal, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgWarning][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 19)
					{
						if(dgVar[dgPot][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPot][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][0] += dgVar[dgPot][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d can sa!", dgVar[dgPot][2]);
						format(string, sizeof(string), "* %s vua nhan %d can sa!", GetPlayerNameEx(giveplayerid), dgVar[dgPot][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPot][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d pot, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPot][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 20)
					{
						if(dgVar[dgCrack][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCrack][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDrugs][1] += dgVar[dgCrack][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Crack!", dgVar[dgCrack][2]);
						format(string, sizeof(string), "* %s vua nhan %d Crack!", GetPlayerNameEx(giveplayerid), dgVar[dgCrack][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCrack][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Crack, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCrack][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 21)
					{
						if(dgVar[dgPaintballToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPaintballToken][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPaintTokens] += dgVar[dgPaintballToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Paintball Token!", dgVar[dgPaintballToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d Paintball Token!", GetPlayerNameEx(giveplayerid), dgVar[dgPaintballToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPaintballToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Paintball Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPaintballToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 22)
					{
						if(dgVar[dgVIPToken][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgVIPToken][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pTokens] += dgVar[dgVIPToken][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d VIP Token!", dgVar[dgVIPToken][2]);
						format(string, sizeof(string), "* %s vua nhan %d VIP Token!", GetPlayerNameEx(giveplayerid), dgVar[dgVIPToken][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgVIPToken][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d VIP Token(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgVIPToken][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 23)
					{
						if(dgVar[dgRespectPoint][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRespectPoint][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pExp] += dgVar[dgRespectPoint][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d diem kinh nghiem!", dgVar[dgRespectPoint][2]);
						format(string, sizeof(string), "* %s vua nhan %d diem kinh nghiem!", GetPlayerNameEx(giveplayerid), dgVar[dgRespectPoint][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRespectPoint][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Respect Point(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRespectPoint][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 24)
					{
						if(dgVar[dgCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCarVoucher][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pVehVoucher] += dgVar[dgCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Car Voucher!", dgVar[dgCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 25)
					{
						if(dgVar[dgBuddyInvite][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgBuddyInvite][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pDonateRank] != 0) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pDonateRank] = 1;
						PlayerInfo[giveplayerid][pTempVIP] = 180;
						PlayerInfo[giveplayerid][pBuddyInvited] = 1;
						format(string, sizeof(string), "BUDDY INVITE: %s(%d) has been invited to VIP by System", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/setvip.log", string);
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Buddy Invite!");
						format(string, sizeof(string), "* %s vua nhan mot BuddyInvite!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgBuddyInvite][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a BuddyInvite, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 26)
					{
						if(dgVar[dgLaser][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgLaser][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = 18643;
								PlayerToyInfo[giveplayerid][v][ptBone] = 6;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = 18643;
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Do khong con o trong, ban duoc cap tam mot o de dung/ban/doi laser.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: Sau khi ban laser, o toy duoc cap tam se bi xoa.");
									break;
								}	
							}
						}
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Laser!");
						format(string, sizeof(string), "* %s vua nhan mot Laser!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgLaser][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Laser, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 27)
					{
						if(dgVar[dgCustomToy][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgCustomToy][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						new icount = GetPlayerToySlots(giveplayerid), success = 0;
						for(new v = 0; v < icount; v++)
						{
							if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
							{
								PlayerToyInfo[giveplayerid][v][ptModelID] = dgVar[dgCustomToy][2];
								PlayerToyInfo[giveplayerid][v][ptBone] = 1;
								PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
								PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
								PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
								
								g_mysql_NewToy(giveplayerid, v);
								success = 1;
								break;
							}
						}
						
						if(success == 0)
						{
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[giveplayerid][i][ptModelID] = dgVar[dgCustomToy][2];
									PlayerToyInfo[giveplayerid][i][ptBone] = 6;
									PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
									PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
									
									g_mysql_NewToy(giveplayerid, i); 
									
									SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Ban het o chua toy nen duoc cap tam mot o de dung, ban hoac trao doi Custom Toy.");
									SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: O chua toy tam thoi se bi thu hoi sau khi ban Custom Toy.");
									break;
								}	
							}
						}
					
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan mot Custom Toy!");
						format(string, sizeof(string), "* %s vua nhan mot Custom Toy!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgCustomToy][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted a Custom Toy, enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 28)
					{
						if(dgVar[dgAdmuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgAdmuteReset][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pADMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pADMuteTotal] -= dgVar[dgAdmuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam quang cao!", dgVar[dgAdmuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam quang cao!", GetPlayerNameEx(giveplayerid), dgVar[dgAdmuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgAdmuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Admute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgAdmuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 29)
					{
						if(dgVar[dgNewbieMuteReset][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgNewbieMuteReset][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						if(PlayerInfo[giveplayerid][pNMuteTotal] == 0) return GiftPlayer(playerid, giveplayerid, 1);									
					
						PlayerInfo[giveplayerid][pNMuteTotal] -= dgVar[dgNewbieMuteReset][2];
						
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d luot go cam Newbie!", dgVar[dgNewbieMuteReset][2]);
						format(string, sizeof(string), "* %s vua nhan %d luot go cam Newbie!", GetPlayerNameEx(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgNewbieMuteReset][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Newbie Mute Reset(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgNewbieMuteReset][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 30)
					{
						if(dgVar[dgRestrictedCarVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgRestrictedCarVoucher][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pCarVoucher] += dgVar[dgRestrictedCarVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d Restricted Car Voucher!", dgVar[dgRestrictedCarVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d Restricted Car Voucher!", GetPlayerNameEx(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgRestrictedCarVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d Restricted Car Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgRestrictedCarVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					
					if(randy == 31)
					{
						if(dgVar[dgPlatinumVIPVoucher][1] == value) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][0] == 0) return GiftPlayer(playerid, giveplayerid, 1);
						if(dgVar[dgPlatinumVIPVoucher][3] == 3) return GiftPlayer(playerid, giveplayerid, 1);
						
						PlayerInfo[giveplayerid][pPVIPVoucher] += dgVar[dgPlatinumVIPVoucher][2];
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chuc mung, ban nhan %d PVIP Voucher 1 thang!", dgVar[dgPlatinumVIPVoucher][2]);
						format(string, sizeof(string), "* %s vua nhan %d PVIP Voucher 1 thang!", GetPlayerNameEx(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
						dgVar[dgPlatinumVIPVoucher][1]--;
						format(string, sizeof(string), "* %s(%d) was just gifted %d 1 month PVIP Voucher(s), enjoy!", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), dgVar[dgPlatinumVIPVoucher][2]);
						SetPVarInt(giveplayerid, "GiftFail", 0), PlayerInfo[giveplayerid][pGiftTime] = 300, Log("logs/giftbox.log", string), SaveDynamicGiftBox(), OnPlayerStatsUpdate(giveplayerid);
						return true;
					}
					else return SendClientMessageEx(giveplayerid, COLOR_RED, "Hop qua dong da het qua, hay thu lai.");			
				}
			}	
		}
		SaveDynamicGiftBox();
	}
	if(gtype == 2)
	{
		if(playerid == MAX_PLAYERS || PlayerInfo[playerid][pAdmin] >= 2)
		{
			new randgift = Random(1, 103);
			if(randgift >= 1 && randgift <= 83)
			{
				new gift = Random(1, 12);
				if(gift == 1)
				{
					if(PlayerInfo[giveplayerid][pConnectHours] < 2 || PlayerInfo[giveplayerid][pWRestricted] > 0) return GiftPlayer(playerid, giveplayerid);
					return GiftPlayer(playerid, giveplayerid);
					/* GivePlayerValidWeapon(giveplayerid, 27, 100);
					GivePlayerValidWeapon(giveplayerid, 24, 100);
					GivePlayerValidWeapon(giveplayerid, 31, 100);
					GivePlayerValidWeapon(giveplayerid, 34, 100);
					GivePlayerValidWeapon(giveplayerid, 29, 100);
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Congratulations - you have won a full weapon set!");
					format(string, sizeof(string), "* %s was just gifted a full weapon set, enjoy!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW); */
				}
				else if(gift == 2)
				{
					if(PlayerInfo[giveplayerid][pDonateRank] > 2) return GiftPlayer(playerid, giveplayerid);
					PlayerInfo[giveplayerid][pFirstaid]++;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot bo so cuu!");
					format(string, sizeof(string), "* %s vua nhan mot bo so cuu!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 3)
				{
					PlayerInfo[giveplayerid][pMats] += 2000;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 2,000 vat lieu!");
					format(string, sizeof(string), "* %s vua nhan 2,000 vat lieu!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 4)
				{
					if(PlayerInfo[giveplayerid][pWarns] != 0)
					{
						PlayerInfo[giveplayerid][pWarns]--;
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot luot xoa canh bao!");
						format(string, sizeof(string), "* %s vua nhan mot luot xoa canh bao!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
					}
					else
					{
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Qua ngau nhien la xoa mot canh bao, hay thu lai!");
						GiftPlayer(playerid, giveplayerid);
						return 1;
					}
				}
				else if(gift == 5)
				{
					PlayerInfo[giveplayerid][pDrugs][0] += 50;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 50 gram can sa!");
					format(string, sizeof(string), "* %s vua nhan 50 gram can sa!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 6)
				{
					PlayerInfo[giveplayerid][pDrugs][1] += 25;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 25 gram crack!");
					format(string, sizeof(string), "* %s vua nhan 25 gram crack!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 7)
				{
					GivePlayerCash(giveplayerid, 20000);
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan $20,000!");
					format(string, sizeof(string), "* %s vua nhan $20,000!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 8)
				{
					if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid);
					PlayerInfo[giveplayerid][pPaintTokens] += 10;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 10 Paintball Token!");
					format(string, sizeof(string), "* %s vua nhan 10 Paintball Token!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 9)
				{
					if(PlayerInfo[giveplayerid][pDonateRank] < 1) return GiftPlayer(playerid, giveplayerid);
					if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid);
					PlayerInfo[giveplayerid][pTokens] += 5;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 5 VIP Token!");
					format(string, sizeof(string), "* %s vua nhan 5 VIP Token!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 10)
				{
					PlayerInfo[giveplayerid][pFirework] += 2;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 2 phao hoa!");
					format(string, sizeof(string), "* %s vua nhan 2 phao hoa!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 11)
				{
					PlayerInfo[giveplayerid][pExp] += 5;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 5 diem kinh nghiem!");
					format(string, sizeof(string), "* %s vua nhan 5 diem kinh nghiem!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
			}
			else if(randgift > 83 && randgift <= 98)
			{
				new gift = Random(1, 9);
				if(gift == 1)
				{
					GivePlayerCash(giveplayerid, 150000);
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan $150,000!");
					format(string, sizeof(string), "* %s vua nhan $150,000!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 2)
				{
					PlayerInfo[giveplayerid][pMats] += 15000;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 15,000 vat lieu!");
					format(string, sizeof(string), "* %s vua nhan 15,000 vat lieu!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 3)
				{
					PlayerInfo[giveplayerid][pExp] += 10;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 10 diem kinh nghiem!");
					format(string, sizeof(string), "* %s vua nhan 10 diem kinh nghiem!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 4)
				{
					PlayerInfo[giveplayerid][pVehVoucher]++;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot xe mien phi!");
					SendClientMessageEx(giveplayerid, COLOR_CYAN, " Da them 1 Car Voucher vao tai khoan cua ban.");
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
					
					format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won a free car", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
					Log("logs/gifts.log", string);
					format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang mot xe mien phi.", GetPlayerNameEx(giveplayerid));
					ABroadCast(COLOR_YELLOW, string, 4);
					format(string, sizeof(string), "* %s vua nhan mot xe mien phi!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 5)
				{
					if(PlayerInfo[giveplayerid][pDonateRank] > 0)
					{
						if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid);
						PlayerInfo[giveplayerid][pTokens] += 15;
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 15 VIP Token!");
						format(string, sizeof(string), "* %s vua nhan 15 VIP Token!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
					}
					else
					{
						PlayerInfo[giveplayerid][pDonateRank] = 1;
						PlayerInfo[giveplayerid][pTempVIP] = 180;
						PlayerInfo[giveplayerid][pBuddyInvited] = 1;
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc moi lam VIP cap 1 trong 3 gio. Chuc vui ve!", GetPlayerNameEx(giveplayerid));
						format(string, sizeof(string), "BUDDY INVITE: %s(%d) has won a buddyinvite.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/setvip.log", string);
						format(string, sizeof(string), "* %s vua nhan 3 gio VIP!", GetPlayerNameEx(giveplayerid));
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
					}
				}
				else if(gift == 6)
				{
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot Laser Pointer mien phi!");
					format(string, sizeof(string), "* %s vua nhan mot Laser Pointer mien phi!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
					new icount = GetPlayerToySlots(giveplayerid);
					for(new v = 0; v < icount; v++)
					{
						if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
						{
							PlayerToyInfo[giveplayerid][v][ptModelID] = 18643;
							PlayerToyInfo[giveplayerid][v][ptBone] = 6;
							PlayerToyInfo[giveplayerid][v][ptPosX] = 0.0;
							PlayerToyInfo[giveplayerid][v][ptPosY] = 0.0;
							PlayerToyInfo[giveplayerid][v][ptPosZ] = 0.0;
							PlayerToyInfo[giveplayerid][v][ptRotX] = 0.0;
							PlayerToyInfo[giveplayerid][v][ptRotY] = 0.0;
							PlayerToyInfo[giveplayerid][v][ptRotZ] = 0.0;
							PlayerToyInfo[giveplayerid][v][ptScaleX] = 1.0;
							PlayerToyInfo[giveplayerid][v][ptScaleY] = 1.0;
							PlayerToyInfo[giveplayerid][v][ptScaleZ] = 1.0;
							PlayerToyInfo[giveplayerid][v][ptTradable] = 1;
							
							g_mysql_NewToy(giveplayerid, v);
							PlayerInfo[giveplayerid][pGiftTime] = 300;
							return 1;
						}
					}
					
					for(new i = 0; i < MAX_PLAYERTOYS; i++)
					{
						if(PlayerToyInfo[giveplayerid][i][ptModelID] == 0)
						{
							PlayerToyInfo[giveplayerid][i][ptModelID] = 18643;
							PlayerToyInfo[giveplayerid][i][ptBone] = 6;
							PlayerToyInfo[giveplayerid][i][ptPosX] = 0.0;
							PlayerToyInfo[giveplayerid][i][ptPosY] = 0.0;
							PlayerToyInfo[giveplayerid][i][ptPosZ] = 0.0;
							PlayerToyInfo[giveplayerid][i][ptRotX] = 0.0;
							PlayerToyInfo[giveplayerid][i][ptRotY] = 0.0;
							PlayerToyInfo[giveplayerid][i][ptRotZ] = 0.0;
							PlayerToyInfo[giveplayerid][i][ptScaleX] = 1.0;
							PlayerToyInfo[giveplayerid][i][ptScaleY] = 1.0;
							PlayerToyInfo[giveplayerid][i][ptScaleZ] = 1.0;
							PlayerToyInfo[giveplayerid][i][ptTradable] = 1;
							PlayerToyInfo[giveplayerid][i][ptSpecial] = 1;
							
							g_mysql_NewToy(giveplayerid, i); 
							
							SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Do khong con o trong, ban duoc cap tam mot o de dung/ban/doi laser.");
							SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: Sau khi ban laser, o toy duoc cap tam se bi xoa.");
							break;
						}	
					}
					//AddFlag(giveplayerid, INVALID_PLAYER_ID, "Free Laser Pointer (Gift)");
					//SendClientMessageEx(giveplayerid, COLOR_GREY, "You have no empty toy slots, so you have been flagged for a free laser.");
				}
				else if(gift == 7)
				{
					if(PlayerInfo[giveplayerid][pADMuteTotal] < 1) return GiftPlayer(playerid, giveplayerid);
					PlayerInfo[giveplayerid][pADMuteTotal] = 0;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot luot go cam quang cao!");
					format(string, sizeof(string), "* %s vua nhan mot luot go cam quang cao!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 8)
				{
					if(PlayerInfo[giveplayerid][pNMuteTotal] < 1) return GiftPlayer(playerid, giveplayerid);
					PlayerInfo[giveplayerid][pNMuteTotal] = 0;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot luot go cam Newbie!");
					format(string, sizeof(string), "* %s vua nhan mot luot go cam Newbie!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
			}
			else if(randgift > 98 && randgift <= 100)
			{
				new gift = Random(1, 6);
				if(gift == 1 && PlayerInfo[giveplayerid][pDonateRank] <= 2) // Silver VIP can get it extended, I suppose
				{
					PlayerInfo[giveplayerid][pSVIPVoucher]++;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot thang Silver VIP!");
					SendClientMessageEx(giveplayerid, COLOR_CYAN, " Da them 1 Silver VIP Voucher vao tai khoan cua ban.");
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
					if(playerid == MAX_PLAYERS) {
						format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won one month of Silver VIP.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/gifts.log", string);
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang mot thang Silver VIP.", GetPlayerNameEx(giveplayerid));
					}
					else {
						format(string, sizeof(string), "AdmCmd: %s has just gifted %s(%d) and he won one month of Silver VIP.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/gifts.log", string);
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s tang qua cho %s, thuong mot thang Silver VIP.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					}
					ABroadCast(COLOR_YELLOW, string, 2);
					format(string, sizeof(string), "* %s vua nhan mot thang Silver VIP!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 2)
				{

					format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won a free house", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
					Log("logs/gifts.log", string);
					format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang mot can nha mien phi.", GetPlayerNameEx(giveplayerid));
					ABroadCast(COLOR_YELLOW, string, 2);
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot can nha mien phi!");
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Luu y: Phan thuong hiem nay co the can toi 48 gio de trao.");
					AddFlag(giveplayerid, INVALID_PLAYER_ID, "Nha mien phi (Qua)");
					format(string, sizeof(string), "* %s vua nhan mot can nha mien phi!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 3)
				{
					if(PlayerInfo[giveplayerid][pDonateRank] < 1) return GiftPlayer(playerid, giveplayerid);
					if(PlayerInfo[giveplayerid][pDonateRank] >= 4) return GiftPlayer(playerid, giveplayerid);
					PlayerInfo[giveplayerid][pTokens] += 50;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan 50 VIP Token!");
					format(string, sizeof(string), "* %s vua nhan 50 VIP Token!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 4)
				{

					GivePlayerCash(giveplayerid, 500000);
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan $500,000!");
					if(playerid == MAX_PLAYERS) {
						format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won $500,000.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/gifts.log", string);
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang $500,000.", GetPlayerNameEx(giveplayerid));
					}
					else {
						format(string, sizeof(string), "AdmCmd: %s has just gifted %s(%d) and he won $500,000.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/gifts.log", string);
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s tang qua cho %s, thuong $500,000.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					}
					ABroadCast(COLOR_YELLOW, string, 2);
					format(string, sizeof(string), "* %s vua nhan $500,000!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				else if(gift == 5)
				{
					PlayerInfo[giveplayerid][pGVIPVoucher]++;
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Chuc mung, ban nhan mot thang Gold VIP!");
					SendClientMessageEx(giveplayerid, COLOR_CYAN, " Da them 1 Gold VIP Voucher vao tai khoan cua ban.");
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
					if(playerid == MAX_PLAYERS) {
						format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won one month of Gold VIP.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/gifts.log", string);
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang mot thang Gold VIP.", GetPlayerNameEx(giveplayerid));
					}
					else {
						format(string, sizeof(string), "AdmCmd: %s has just gifted %s(%d) and he won one month of Gold VIP.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
						Log("logs/gifts.log", string);
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s tang qua cho %s, thuong mot thang Gold VIP.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					}
					ABroadCast(COLOR_YELLOW, string, 2);
					format(string, sizeof(string), "* %s vua nhan mot thang Gold VIP!", GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
			}
			else if(randgift > 100 && randgift <= 103) // Rim Mod
			{
				new gift = Random(1, 10);
				if(gift >= 1 && gift <= 3)
				{
					if(RimMod > 0) // Rim Kit
					{
						PlayerInfo[giveplayerid][pRimMod]++;
						RimMod--;
						g_mysql_SaveMOTD();

						if(playerid == MAX_PLAYERS) {
							format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won a rim modification kit. (%d left)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), RimMod);
						}
						else {
							format(string, sizeof(string), "AdmCmd: %s has just gifted %s(%d) and he won a rim modification kit. (%d left)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), RimMod);
						}

						Log("logs/gifts.log", string);
						format(string, sizeof(string), "* %s vua nhan mot bo do mam! Chi con %d bo.", GetPlayerNameEx(giveplayerid), RimMod);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
					}
					else
					{
						GiftPlayer(MAX_PLAYERS, giveplayerid);
						return 1;
					}
				}
				else if(gift == 4) //
				{
					if(CarVoucher > 0)
					{
						PlayerInfo[giveplayerid][pCarVoucher]++;
						CarVoucher--;
						g_mysql_SaveMOTD();

						if(playerid == MAX_PLAYERS) {
							format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won a restricted car voucher. (%d left)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), CarVoucher);
						}
						else {
							format(string, sizeof(string), "AdmCmd: %s has just gifted %s(%d) and he won a restricted car voucher. (%d left)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), CarVoucher);
						}

						Log("logs/gifts.log", string);
						format(string, sizeof(string), "* %s vua nhan mot Restricted Car Voucher! Chi con %d voucher.", GetPlayerNameEx(giveplayerid), CarVoucher);
						ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						SendClientMessageEx(giveplayerid, COLOR_CYAN, " Da them 1 Restricted Car Voucher vao tai khoan cua ban.");
						SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
					}
					else
					{
						GiftPlayer(MAX_PLAYERS, giveplayerid);
						return 1;
					}
				}
				else if(gift == 5) //
				{
					new gift2 = Random(1, 15);
					if(gift2 == 3)
					{
						if(PVIPVoucher > 0)
						{
							PlayerInfo[giveplayerid][pPVIPVoucher]++;
							PVIPVoucher--;
							g_mysql_SaveMOTD();
							
							if(playerid == MAX_PLAYERS)
							{
								format(string, sizeof(string), "AdmCmd: %s(%d) was just gifted by the system and he won a 1 month PVIP Voucher. (%d left)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), PVIPVoucher);
							}
							else
							{
								format(string, sizeof(string), "AdmCmd: %s has just gifted %s(%d) and he won a 1 month PVIP Voucher. (%d left)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), PVIPVoucher);
							}	
						
							Log("logs/gifts.log", string);
							format(string, sizeof(string), "* %s vua nhan mot PVIP Voucher 1 thang! Con %d PVIP Voucher 1 thang.", GetPlayerNameEx(giveplayerid), PVIPVoucher);
							ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
							SendClientMessageEx(giveplayerid, COLOR_CYAN, " Da them 1 PVIP Voucher 1 thang vao tai khoan cua ban.");
							SendClientMessageEx(giveplayerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
							
							SendClientMessageToAll(COLOR_WHITE, string);
						}
						else
						{
							GiftPlayer(MAX_PLAYERS, giveplayerid);
							return 1;
						}
					}
					else
					{
						GiftPlayer(MAX_PLAYERS, giveplayerid);
						return 1;
					}
				}
				else
				{
					GiftPlayer(MAX_PLAYERS, giveplayerid);
					return 1;
				}
			}
			PlayerInfo[giveplayerid][pGiftTime] = 300;
		}
	}
	return 1;
}

stock GetDynamicGiftBoxType(value)
{
	new string[128];
	if(value == 0)
		format(string, sizeof(string), "It pho bien");
	else if(value == 1)
		format(string, sizeof(string), "Pho bien");
	else if(value == 2)
		format(string, sizeof(string), "Hiem");
	else if(value == 3)
		format(string, sizeof(string), "Sieu hiem");
	return string;
}

stock ShowPlayerDynamicGiftBox(playerid)
{
	szMiscArray[0] = 0;

	szMiscArray = "{1B7A3C}Cai dat hop qua{FFFFFF}";
	if(dgVar[dgMoney][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Tien", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Tien", szMiscArray);
	if(dgVar[dgRimKit][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Bo do mam", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Bo do mam", szMiscArray);
	if(dgVar[dgFirework][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Phao hoa", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Phao hoa", szMiscArray);
	if(dgVar[dgGVIP][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Gold VIP 7 ngay", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Gold VIP 7 ngay", szMiscArray);
	if(dgVar[dgGVIPEx][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Gold VIP 1 thang", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Gold VIP 1 thang", szMiscArray);
	if(dgVar[dgSVIP][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Silver VIP 7 ngay", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Silver VIP 7 ngay", szMiscArray);
	if(dgVar[dgSVIPEx][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Silver VIP 1 thang", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Silver VIP 1 thang", szMiscArray);
	if(dgVar[dgCarSlot][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}O chua xe", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}O chua xe", szMiscArray);
	if(dgVar[dgToySlot][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}O chua toy", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}O chua toy", szMiscArray);
	if(dgVar[dgArmor][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Day giap", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Day giap", szMiscArray);
	if(dgVar[dgFirstaid][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Bo so cuu", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Bo so cuu", szMiscArray);
	if(dgVar[dgDDFlag][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Flag Dynamic Door", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Flag Dynamic Door", szMiscArray);
	if(dgVar[dgGateFlag][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Flag Dynamic Gate", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Flag Dynamic Gate", szMiscArray);
	if(dgVar[dgCredits][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Credit", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Credit", szMiscArray);
	if(dgVar[dgPriorityAd][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Quang cao uu tien", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Quang cao uu tien", szMiscArray);
	if(dgVar[dgHealthNArmor][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Mau va giap", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Mau va giap", szMiscArray);
	if(dgVar[dgGiftReset][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Dat lai qua", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Dat lai qua", szMiscArray);
	if(dgVar[dgMaterial][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Vat lieu", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Vat lieu", szMiscArray);
	if(dgVar[dgWarning][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Canh bao", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Canh bao", szMiscArray);
	if(dgVar[dgPot][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Can sa", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Can sa", szMiscArray);
	if(dgVar[dgCrack][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Crack", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Crack", szMiscArray);
	if(dgVar[dgPaintballToken][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Paintball Token", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Paintball Token", szMiscArray);
	if(dgVar[dgVIPToken][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}VIP Token", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}VIP Token", szMiscArray);
	if(dgVar[dgRespectPoint][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Diem kinh nghiem", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Diem kinh nghiem", szMiscArray);
	if(dgVar[dgCarVoucher][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Car Voucher", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Car Voucher", szMiscArray);
	if(dgVar[dgBuddyInvite][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Buddy Invite", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Buddy Invite", szMiscArray);
	if(dgVar[dgLaser][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Laser", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Laser", szMiscArray);
	if(dgVar[dgCustomToy][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Custom Toy", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Custom Toy", szMiscArray);
	if(dgVar[dgAdmuteReset][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Go cam quang cao", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Go cam quang cao", szMiscArray);
	if(dgVar[dgNewbieMuteReset][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Go cam Newbie", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Go cam Newbie", szMiscArray);
	if(dgVar[dgRestrictedCarVoucher][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}Restricted Car Voucher", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}Restricted Car Voucher", szMiscArray);
	if(dgVar[dgPlatinumVIPVoucher][0] == 1)
		format(szMiscArray, sizeof(szMiscArray), "%s\n{00FF61}PVIP Voucher 1 thang", szMiscArray);
	else
		format(szMiscArray, sizeof(szMiscArray), "%s\n{F2070B}PVIP Voucher 1 thang", szMiscArray);
		
	return ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_VIEW, DIALOG_STYLE_LIST, "Hop qua dong", szMiscArray, "Chon", "Dong");
}

CMD:gifts(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
     	if(Gifts == 0)
     	{
           	Gifts = 1;
			format(szMiscArray, sizeof(szMiscArray), "AdmCmd: %s da bat lenh /gift.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMiscArray, 1337 );
		}
		else
		{
		    Gifts = 0;
		   
	   		format(szMiscArray, sizeof(szMiscArray), "AdmCmd: %s da tat lenh /gift.", GetPlayerNameEx(playerid));
			ABroadCast( COLOR_LIGHTRED, szMiscArray, 1337 );
		}
	}
	return 1;
}

CMD:vipgifts(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
     	if(VIPGifts == 0)
     	{
           	VIPGifts = 1;
			format(szMiscArray, sizeof(szMiscArray), "%s moi ban den Club VIP de nhan qua mien phi va vui choi [20 phut con lai]", GetPlayerNameEx(playerid));
			SendVIPMessage(COLOR_LIGHTGREEN, szMiscArray);
			VIPGiftsTimeLeft = 20;
			format(VIPGiftsName, sizeof(VIPGiftsName), "%s", GetPlayerNameEx(playerid));
		}
		else
		{
		    VIPGifts = 0;
	   		format(szMiscArray, sizeof(szMiscArray), "AdmCmd: %s da tat som lenh /getgift", GetPlayerNameEx(playerid));
			ABroadCast( COLOR_LIGHTRED, szMiscArray, 1337 );
			format(szMiscArray, sizeof(szMiscArray), "Club VIP da ngung phat qua mien phi. Cam on ban da tham gia!", VIPGiftsName, VIPGiftsTimeLeft);
			SendVIPMessage(COLOR_LIGHTGREEN, szMiscArray);
			VIPGiftsTimeLeft = 0;
		}
	}
	return 1;
}

CMD:resetgift(playerid, params[])
{
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /resetgift [player]");

    if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		if(IsPlayerConnected(giveplayerid))
		{
	   		if(PlayerInfo[giveplayerid][pGiftTime] > 0)
    		{
	    	    PlayerInfo[giveplayerid][pGiftTime] = 0;
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da dat lai thoi gian nhan qua cua %s", GetPlayerNameEx(giveplayerid));
   			}
   			else
   			{
	   		    SendClientMessageEx(playerid, COLOR_GRAD2, "Thoi gian nhan qua cua nguoi do da la 0!");
			}
		}
		else
		{
   			SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do chua ket noi.");
		}
	}
	return 1;
}

CMD:giftnear(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
       	new range;
		if(sscanf(params, "d", range)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /giftnear [range]");

		if(range < 1)
		{
		    SendClientMessageEx(playerid, COLOR_WHITE, "Pham vi khong duoc nho hon 1.");
			return 1;
		}

        new count;
        foreach(new i: Player)
		{
			if(ProxDetectorS(range, playerid, i))
			{
				if(PlayerInfo[i][pGiftTime] <= 0)
				{
					GiftPlayer(playerid, i);
					count++;
				}
			}
		}	
        SendClientMessageEx(playerid, COLOR_WHITE, "Da tang qua cho moi nguoi (%d) o gan.", count);
    }
    return 1;
}

CMD:resetgiftall(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da cho moi nguoi nhan qua ngay.", GetPlayerNameEx(playerid));
		ABroadCast(COLOR_YELLOW, szMiscArray, 2);
		foreach(new i: Player)
		{
			PlayerInfo[i][pGiftTime] = 0;
		}
	}
	return 1;
}

CMD:gift(playerid, params[])
{
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gift [player]");

    if(PlayerInfo[playerid][pAdmin] >= 2)
	{
 		if(Gifts == 1 || PlayerInfo[playerid][pAdmin] >= 1337)
   		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
			    if(PlayerInfo[giveplayerid][pGiftTime] > 0)
	           	{
	               	SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do da nhan qua trong 5 gio qua!");
					return 1;
	           	}
			    GiftPlayer(playerid, giveplayerid);
			}
			else
			{
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do chua ket noi.");
			}
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GRAD2, "Lenh nay chua duoc kich hoat!");
		}
	}
	return 1;
}

CMD:giftall(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
    	if(GiftAllowed || PlayerInfo[playerid][pAdmin] >= 99999)
     	{
      		format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s vua tang qua cho tat ca nguoi choi.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW, szMiscArray, 2);
			GiftAllowed = 0;
			foreach(new i: Player)
			{
				GiftPlayer(playerid, i);
			}	
		}
		else
		{
		    return SendClientMessageEx(playerid, COLOR_GRAD2, "Lenh nay da duoc dung, hay cho ky luong tiep theo!");
		}
	}
	return 1;
}

CMD:giftreset(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1338) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /giftreset [player]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	if(PlayerInfo[giveplayerid][pGiftTime] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi da co the nhan qua.");
	format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da cho %s nhan qua ngay.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	ABroadCast(COLOR_YELLOW, szMiscArray, 2);
	PlayerInfo[giveplayerid][pGiftTime] = 0;
	return 1;
}

CMD:setcode(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 99999 || PlayerInfo[playerid][pShopTech] >= 3)
	{
		new code[32], bypass;
		if (sscanf(params, "s[32]d", code, bypass))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setcode <code> <bypass 0/1>");
			SendClientMessageEx(playerid, COLOR_GREY, "Nhap code 'off' de tat ma qua dang hoat dong.");
			return 1;
		}

		format(GiftCode, 32, code);
		GiftCodeBypass = bypass;
        g_mysql_SaveMOTD();
		mysql_tquery(MainPipeline, "UPDATE `accounts` SET `GiftCode` = 0;", "OnQueryFinish", "i", SENDDATA_THREAD);
		foreach(new i : Player)
		{
			if(PlayerInfo[i][pGiftCode] == 1)
				PlayerInfo[i][pGiftCode] = 0;
		}		


		if (strcmp(code, "off") == 0)
		{
			format(szMiscArray, sizeof(szMiscArray), "Ban da tat ma qua.");
		}
		else
		{
			format(szMiscArray, sizeof(szMiscArray), "Ban da dat ma qua la \"%s\".", code);
		}

		SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}

	return 1;
}

CMD:giftcode(playerid, params[])
{
	if (isnull(params))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /giftcode <code>");
		return 1;
	}
	if(PlayerInfo[playerid][pLevel] < 3) {
		SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat cap 3 de dung lenh nay.");
		return 1;
	}
	if (strcmp(GiftCode, "off") == 0)
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co ma qua nao hoat dong.");
		return 1;
	}
	else
	{
	    if (strcmp(params, GiftCode) == 0)
		{
		    if(GiftCodeBypass > 0)
		    {
		        if(PlayerInfo[playerid][pGiftCode] == 0)
		        {
		            SendClientMessageEx(playerid, COLOR_WHITE, "Ma qua ban nhap hop le!");
		        	PlayerInfo[playerid][pGiftCode] = 1;
		        	GiftPlayer(MAX_PLAYERS, playerid);
				}
				else
				{
				    SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhap ma qua nay roi.");
				}
			}
			else
			{
			    if(PlayerInfo[playerid][pGiftTime] == 0)
			    {
					if(PlayerInfo[playerid][pGiftCode] == 0)
					{
					    SendClientMessageEx(playerid, COLOR_WHITE, "Ma qua ban nhap hop le!");
			  			PlayerInfo[playerid][pGiftCode] = 1;
			  			GiftPlayer(MAX_PLAYERS, playerid);
					}
					else
					{
					    SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhap ma qua nay roi.");
					}
			    }
			    else
			    {
			        SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhan qua trong 5 gio qua.");
			    }
			}
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Ma qua ban nhap khong hop le.");
		}
	}
	return 1;
}

CMD:dynamicgift(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Phai di bo de dung lenh nay.");
			return 1;
		}

		new string[128], Float:Position[4];
		if(dynamicgift == 0)
		{
			GetPlayerPos(playerid, Position[0], Position[1], Position[2]);
			GetPlayerFacingAngle(playerid, Position[3]);
			dynamicgift = CreateDynamicObject(19054, Position[0], Position[1], Position[2]-0.4, 0.0, 0.0, Position[3], -1, -1, -1, 200.0);
			dynamicgift3DText = CreateDynamic3DTextLabel("/getgift\nDe lay qua ben trong.",COLOR_YELLOW,Position[0], Position[1], Position[2]+0.25,8.0);
			SetPlayerPos(playerid, Position[0], Position[1], Position[2]+3);
			format(string, sizeof(string), "AdmCmd: %s da dat hop qua dong.", GetPlayerNameEx(playerid));
			
			if(IsDynamicGiftBoxEnabled == true)
			{
				SendClientMessageEx(playerid, COLOR_RED, "Hop qua dong dang bat, ban co the xem phan thuong ben trong.");
				
				if(PlayerInfo[playerid][pAdmin] == 99999 || PlayerInfo[playerid][pShopTech] >= 3) 
				{
					SendClientMessageEx(playerid, COLOR_RED, "Luu y: Hay dung /dgedit de them qua vao hop.");
				}
				ShowPlayerDynamicGiftBox(playerid);
			}
			ABroadCast( COLOR_LIGHTRED, string, 1337);
		}
		else
		{
			DestroyDynamicObject(dynamicgift);
			dynamicgift = 0;
			DestroyDynamic3DTextLabel( Text3D:dynamicgift3DText );
			format(string, sizeof(string), "AdmCmd: %s da xoa hop qua dong.", GetPlayerNameEx(playerid));
			ABroadCast( COLOR_LIGHTRED, string, 1337);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:nextgift(playerid, params[])
{
	if(PlayerInfo[playerid][pGiftTime] < 1)
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da co the nhan qua tu hop qua hoac ket sat.");
	}
	else {	
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban co the nhan qua sau %d phut.", PlayerInfo[playerid][pGiftTime]);
	}	
	return 1;
}

CMD:getgift(playerid, params[])
{
	new string[128], year, month, day;
	getdate(year, month, day);

	if(IsPlayerInRangeOfPoint(playerid, 3.0,2546.680908, 1403.430786, 7699.584472) || IsPlayerInRangeOfPoint(playerid, 3.0,1726.1000, 1370.1000, 1449.9000) || IsPlayerInRangeOfPoint(playerid, 3.0,1763.5000, 1432.5000, 2015.7000) || IsPlayerInRangeOfPoint(playerid, 3.0,772.4000, 1743.2000, 1938.8800))
	{
		if(PlayerInfo[playerid][pDonateRank] >= 1)
		{
			if(VIPGifts == 0 && PlayerInfo[playerid][pDonateRank] < 4)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ket sat dang khoa!");
				return 1;
			}
			if(PlayerInfo[playerid][pGiftTime] > 0)
			{
			    format(string, sizeof(string),"Vat pham: Dat lai cho qua\nCredit: %s\nGia: {FFD700}%s{A9C4E4}\nCon: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[17][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[17][sItemPrice]));
	    		ShowPlayerDialogEx( playerid, DIALOG_SHOPGIFTRESET, DIALOG_STYLE_MSGBOX, "Dat lai thoi gian qua", string, "Mua", "Thoat" );
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da nhan qua trong 5 gio qua!");
				return 1;
			}
			format(string, sizeof(string), "* %s nham mat va tho tay vao ket sat.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			GiftPlayer(MAX_PLAYERS, playerid);
		}
	}
	else if(dynamicgift != 0)
	{
		new Float:Position[3];
		GetDynamicObjectPos(dynamicgift, Position[0], Position[1], Position[2]);

		if(IsPlayerInRangeOfPoint(playerid, 5.0, Position[0], Position[1], Position[2]))
		{
			if(PlayerInfo[playerid][pLevel] >= 3)
			{
				if(PlayerInfo[playerid][pGiftTime] > 0 && (IsDynamicGiftBoxEnabled == false || (IsDynamicGiftBoxEnabled == true && !dgGoldToken)))
				{
				    format(string, sizeof(string),"Vat pham: Dat lai cho qua\nCredit: %s\nGia: {FFD700}%s{A9C4E4}\nCon: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[17][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[17][sItemPrice]));
	    			ShowPlayerDialogEx( playerid, DIALOG_SHOPGIFTRESET, DIALOG_STYLE_MSGBOX, "Dat lai thoi gian qua", string, "Mua", "Thoat" );
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da nhan qua trong 5 gio qua!");
					return 1;
				}
				if(IsDynamicGiftBoxEnabled == true)
				{
					if(dgGoldToken)
					{
						if(!PlayerInfo[playerid][pGoldBoxTokens]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Gold Giftbox Token!");
						PlayerInfo[playerid][pGoldBoxTokens]--;
					}
					GiftPlayer(MAX_PLAYERS, playerid, 1);
				}
				else if(IsDynamicGiftBoxEnabled == false)
				{
					GiftPlayer(MAX_PLAYERS, playerid);
				}
				format(string, sizeof(string), "* %s nham mat va tho tay vao tui qua.", GetPlayerNameEx(playerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "* Can it nhat cap 3 de su dung, rat tiec!");
			}
		}
	}
	return 1;
}

// Dynamic Giftbox
CMD:dgedit(playerid, const params[])
{
	if(PlayerInfo[playerid][pAdmin] < 99999 && PlayerInfo[playerid][pShopTech] < 3) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	new string[128], choice[32], type, amount, var;
	if(strcmp(params, "autoreset", true) == 0)
	{
		DeletePVar(playerid, "dgInputSel");
		format(string, sizeof(string), "Cho: %d phut\nSo luong: %d\n%s", dgTimerTime, dgAmount, (dgTimer != -1)?("{FF0606}Tat"):("{00ff00}Bat"));
		return ShowPlayerDialogEx(playerid, DIALOG_DGRAUTORESET, DIALOG_STYLE_LIST, "Tu dat lai hop qua dong - Chon de sua", string, "Chon", "Dong");
	}
	if(sscanf(params, "s[32]dD", choice, type, amount))
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /dgedit [choice] [type] [value]");
		SendClientMessageEx(playerid, COLOR_GRAD1, "Lua chon hop le: Money, RimKit, Firework, 7DayGVIP, 1MonthGVIP, 7DaySVIP, 1MonthSVIP, CarSlot, ToySlot");
		SendClientMessageEx(playerid, COLOR_GRAD1, "Lua chon hop le: FullArmor, Firstaid, DDFlag, GateFlag, Credits, PriorityAd, HealthNArmor, Giftreset, Material");
		SendClientMessageEx(playerid, COLOR_GRAD1, "Lua chon hop le: Warning, Pot, Crack, PaintballToken, VIPToken, RespectPoint, CarVoucher, BuddyInvite, Laser");
		SendClientMessageEx(playerid, COLOR_GRAD1, "Lua chon hop le: CustomToy, AdmuteReset, NewbieMuteReset, RestrictedCarVoucher, PlatVIPVoucher");
		SendClientMessageEx(playerid, COLOR_GRAD1, "Lua chon hop le: AutoReset, UseGoldTokens");
		return SendClientMessageEx(playerid, COLOR_RED, "Type hop le: 0 = Bat/Tat | 1 = So luong con | 2 = So luong trao | 3 = Do hiem");
	}
	if(type < 0 || type > 3) 
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Type khong hop le!");
		return SendClientMessageEx(playerid, COLOR_RED, "Type hop le: 0 = Bat/Tat | 1 = So luong con | 2 = So luong trao | 3 = Do hiem");
	}
	if(amount < 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the chon so luong nho hon 0!");
	if(strcmp(choice, "money", true) == 0) var = dgMoney;
	else if(strcmp(choice, "rimkit", true) == 0) var = dgRimKit;
	else if(strcmp(choice, "firework", true) == 0) var = dgFirework;
	else if(strcmp(choice, "7daygvip", true) == 0) var = dgGVIP;
	else if(strcmp(choice, "1monthgvip", true) == 0) var = dgGVIPEx;
	else if(strcmp(choice, "7daysvip", true) == 0) var = dgSVIPEx;
	else if(strcmp(choice, "1monthsvip", true) == 0) var = dgSVIP;
	else if(strcmp(choice, "carslot", true) == 0) var = dgCarSlot;
	else if(strcmp(choice, "toyslot", true) == 0) var = dgToySlot;
	else if(strcmp(choice, "fullarmor", true) == 0) var = dgArmor;
	else if(strcmp(choice, "firstaid", true) == 0) var = dgFirstaid;
	else if(strcmp(choice, "ddflag", true) == 0) var = dgDDFlag;
	else if(strcmp(choice, "gateflag", true) == 0) var = dgGateFlag;
	else if(strcmp(choice, "credits", true) == 0) var = dgCredits;
	else if(strcmp(choice, "priorityad", true) == 0) var = dgPriorityAd;
	else if(strcmp(choice, "healthnarmor", true) == 0) var = dgHealthNArmor;
	else if(strcmp(choice, "giftreset", true) == 0) var = dgGiftReset;
	else if(strcmp(choice, "material", true) == 0) var = dgMaterial;
	else if(strcmp(choice, "warning", true) == 0) var = dgWarning;
	else if(strcmp(choice, "pot", true) == 0) var = dgPot;
	else if(strcmp(choice, "crack", true) == 0) var = dgCrack;
	else if(strcmp(choice, "paintballtoken", true) == 0) var = dgPaintballToken;
	else if(strcmp(choice, "viptoken", true) == 0) var = dgVIPToken;
	else if(strcmp(choice, "respectpoint", true) == 0) var = dgRespectPoint;
	else if(strcmp(choice, "carvoucher", true) == 0) var = dgCarVoucher;
	else if(strcmp(choice, "buddyinvite", true) == 0) var = dgBuddyInvite;
	else if(strcmp(choice, "laser", true) == 0) var = dgLaser;
	else if(strcmp(choice, "customtoy", true) == 0) var = dgCustomToy;
	else if(strcmp(choice, "admutereset", true) == 0) var = dgAdmuteReset;
	else if(strcmp(choice, "newbiemutereset", true) == 0) var = dgNewbieMuteReset;
	else if(strcmp(choice, "restrictedcarvoucher", true) == 0) var = dgRestrictedCarVoucher;
	else if(strcmp(choice, "platvipvoucher", true) == 0) var = dgPlatinumVIPVoucher;
	else if(strcmp(choice, "autoreset", true) == 0) return pc_cmd_dgedit(playerid, "autoreset");
	else if(strcmp(choice, "usegoldtokens", true) == 0)
	{
		if(dgGoldToken) dgGoldToken = 0, SendClientMessageEx(playerid, COLOR_WHITE, "Da tat yeu cau dung Gold Giftbox Token de nhan qua.");
		else dgGoldToken = 1, SendClientMessageEx(playerid, COLOR_WHITE, "Da bat yeu cau dung Gold Giftbox Token de nhan qua.");
		return 1;
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Lua chon khong hop le!");
	// Prepare the proper and approriate string
	switch(type)
	{
		case 0:
		{
			// Little check to make sure they're not inserting invalid values
			if(amount < 0 || amount > 1) return SendClientMessage(playerid, COLOR_RED, "0 = Tat | 1 - Bat");
			switch(amount)
			{
				case 0: format(string, sizeof(string), "Ban da tat phan thuong.");
				case 1: format(string, sizeof(string), "Ban da bat phan thuong.");
				default: return true;
			}
		}
		case 1:
		{
			format(string, sizeof(string), "Da dat so luong qua con lai la %s.", number_format(amount));
		}
		case 2:
		{
			format(string, sizeof(string), "Da dat so qua moi lan la %s.", number_format(amount));
		}
		case 3:
		{
			if(amount < 0 || amount > 3) return SendClientMessageEx(playerid, COLOR_RED, "0 = Pho bien | 1 = It pho bien | 2 = Hiem | 3 = Sieu hiem");
			switch(amount)
			{
				case 0: format(string, sizeof(string), "Da dat do hiem thanh Pho bien.");
				case 1: format(string, sizeof(string), "Da dat do hiem thanh It pho bien.");
				case 2: format(string, sizeof(string), "Da dat do hiem thanh Hiem.");
				case 3: format(string, sizeof(string), "Da dat do hiem thanh Sieu hiem.");
				default: return true;
			}
		}
		default: return true;
	}
	// Set the data to the variable
	dgVar[dgItems:var][type] = amount;
	// Save the GiftBox Stuff
	SaveDynamicGiftBox();
	// Send the client message
	SendClientMessageEx(playerid, COLOR_WHITE, string);
	return true;
}

CMD:viewgiftbox(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] == 99999 || PlayerInfo[playerid][pShopTech] >= 3)
	{
		ShowPlayerDynamicGiftBox(playerid);
	}
	else
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong phai Executive Administrator!");
	return true;
}

CMD:togdynamicgift(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] == 99999 || PlayerInfo[playerid][pShopTech] >= 3)
	{
		if(IsDynamicGiftBoxEnabled == false)
		{
			IsDynamicGiftBoxEnabled = true;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da bat hop qua dong, dung /dgedit de sua phan thuong.");
		}
		else if(IsDynamicGiftBoxEnabled == true)
		{
			IsDynamicGiftBoxEnabled = false;
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tat hop qua dong.");
		}
	}
	else
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong phai Executive Administrator!");
	return true;
}

CMD:giftbox(playerid, params[])
{
	if(dynamicgift != 0)
	{
		new Float: pos[3];
		SendClientMessageEx(playerid, COLOR_YELLOW, "** Hien co hop qua tren ban do, da dat checkpoint den vi tri hop qua.");
		if(CheckPointCheck(playerid)) pc_cmd_killcheckpoint(playerid, params); //If they have a checkpoint, just remove it
		DisablePlayerCheckpoint(playerid);
		GetDynamicObjectPos(dynamicgift, pos[0], pos[1], pos[2]);
		SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 5);
		SetPVarInt(playerid, "GiftBoxCP", 1);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "** Hien khong co hop qua tren ban do.");
	}
	return true;
}