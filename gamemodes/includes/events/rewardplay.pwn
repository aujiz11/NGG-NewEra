/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Reward Play System

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

CMD:rewards(playerid, params[]) {
	SendClientMessageEx(playerid, COLOR_GREEN, "Thong tin thuong:");
	SendClientMessageEx(playerid, COLOR_YELLOW, "Tong gio thuong: %d", floatround(PlayerInfo[playerid][pRewardHours]));
	SendClientMessageEx(playerid, COLOR_YELLOW, "Luot boc tham #FallIntoFun: %d", PlayerInfo[playerid][pRewardDrawChance]);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Gold Giftbox Tokens: %d", PlayerInfo[playerid][pGoldBoxTokens]);
	if(!iRewardBox)
	{
		SendClientMessageEx(playerid, COLOR_RED, "Luu y: Hop qua vang hien dang tat.");
	}
	return 1;
}

CMD:goldgiftbox(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1337) switch(iRewardBox) {
	    case 0: {

	        new
				Float: fPos[3],
				szMessage[64];

			GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
			iRewardObj = CreateDynamicObject(19055, fPos[0], fPos[1], fPos[2], 0.0, 0.0, 0.0, .streamdistance = 100.0);
			tRewardText = CreateDynamic3DTextLabel("Gold Reward Gift Box\n{FFFFFF}/getrewardgift{F3FF02} de nhan qua!", COLOR_YELLOW, fPos[0], fPos[1], fPos[2], 10.0, .testlos = 1, .streamdistance = 50.0);
			iRewardBox = true;

			format(szMessage, sizeof szMessage, "AdmCmd: %s da dat hop qua thuong.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMessage, 2);
			Misc_Save();
		}
	    default: {
	        new
	            szMessage[64];

	        iRewardBox = false;
	        DestroyDynamic3DTextLabel(tRewardText);
			DestroyDynamicObject(iRewardObj);

			format(szMessage, sizeof szMessage, "AdmCmd: %s da go hop qua thuong.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMessage, 2);
			Misc_Save();
	    }
	}
	return 1;
}

CMD:rewardplay(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1337) switch(iRewardPlay) {
		case 0: {

			new
				szMessage[64];

			iRewardPlay = true;

			format(szMessage, sizeof szMessage, "AdmCmd: %s da bat Reward Play.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMessage, 2);
			Misc_Save();
		}
		default: {

			new
				szMessage[64];

			format(szMessage, sizeof szMessage, "AdmCmd: %s da tat Reward Play.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMessage, 2);

			iRewardPlay = false;
			Misc_Save();
		}
	}
	return 1;
}

CMD:getrewardgift(playerid, params[]) {
	if(iRewardBox) {
		if(IsPlayerInRangeOfDynamicObject(playerid, iRewardObj, 5.0)) {
			if(PlayerInfo[playerid][pGoldBoxTokens] >= 1) {

				--PlayerInfo[playerid][pGoldBoxTokens];

				new
					szMessage[128];

				switch(random(10)) {
					case 0..6: switch(random(7)) { // 70%
						case 0:
						{
							GivePlayerCash(playerid, 500000);
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan $500,000!");
							format(szMessage, sizeof(szMessage), "* %s vua nhan $500,000, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						case 1:
						{
							PlayerInfo[playerid][pMats] += 20000;
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan 20,000 vat lieu!");
							format(szMessage, sizeof(szMessage), "* %s vua nhan 20,000 vat lieu, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						case 2:
						{
							PlayerInfo[playerid][pExp] += 10;
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan 10 diem kinh nghiem!");
							format(szMessage, sizeof(szMessage), "* %s vua nhan 10 diem kinh nghiem!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						case 3:
						{
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan mot xe mien phi!");
							SendClientMessageEx(playerid, COLOR_CYAN, " Da them 1 Car Voucher vao tai khoan.");
							SendClientMessageEx(playerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
							PlayerInfo[playerid][pVehVoucher]++;

							format(szMessage, sizeof(szMessage), "AdmCmd: %s(%d) was just gifted by the system and he won one free car", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
							Log("logs/gifts.log", szMessage);
							format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang mot xe mien phi.", GetPlayerNameEx(playerid));
							ABroadCast(COLOR_YELLOW, szMessage, 4);
							format(szMessage, sizeof(szMessage), "* %s vua nhan mot xe mien phi!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						case 4:
						{
							PlayerInfo[playerid][pSVIPVoucher]++;
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan mot thang Silver VIP!");
							SendClientMessageEx(playerid, COLOR_CYAN, " Da them 1 Silver VIP Voucher vao tai khoan.");
							SendClientMessageEx(playerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
							format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s da nhan mot thang Silver VIP.", GetPlayerNameEx(playerid));
							ABroadCast(COLOR_YELLOW, szMessage, 2);
							format(szMessage, sizeof(szMessage), "* %s vua nhan mot thang Silver VIP, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						case 5:
						{
							PlayerInfo[playerid][pTokens] += 50;
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan 50 VIP tokens!");
							format(szMessage, sizeof(szMessage), "* %s vua nhan 50 VIP tokens, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						default:
						{
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan Free Laser Pointer!");
							format(szMessage, sizeof(szMessage), "* %s vua nhan Free Laser Pointer, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
							new icount = GetPlayerToySlots(playerid);
							for(new v = 0; v < icount; v++)
							{
								if(PlayerToyInfo[playerid][v][ptModelID] == 0)
								{
									PlayerToyInfo[playerid][v][ptModelID] = 18643;
									PlayerToyInfo[playerid][v][ptBone] = 6;
									PlayerToyInfo[playerid][v][ptPosX] = 0.0;
									PlayerToyInfo[playerid][v][ptPosY] = 0.0;
									PlayerToyInfo[playerid][v][ptPosZ] = 0.0;
									PlayerToyInfo[playerid][v][ptRotX] = 0.0;
									PlayerToyInfo[playerid][v][ptRotY] = 0.0;
									PlayerToyInfo[playerid][v][ptRotZ] = 0.0;
									PlayerToyInfo[playerid][v][ptScaleX] = 1.0;
									PlayerToyInfo[playerid][v][ptScaleY] = 1.0;
									PlayerToyInfo[playerid][v][ptScaleZ] = 1.0;
									PlayerToyInfo[playerid][v][ptTradable] = 1;
									
									g_mysql_NewToy(playerid, v);
									return 1;
								}
							}
							
							for(new i = 0; i < MAX_PLAYERTOYS; i++)
							{
								if(PlayerToyInfo[playerid][i][ptModelID] == 0)
								{
									PlayerToyInfo[playerid][i][ptModelID] = 18643;
									PlayerToyInfo[playerid][i][ptBone] = 6;
									PlayerToyInfo[playerid][i][ptPosX] = 0.0;
									PlayerToyInfo[playerid][i][ptPosY] = 0.0;
									PlayerToyInfo[playerid][i][ptPosZ] = 0.0;
									PlayerToyInfo[playerid][i][ptRotX] = 0.0;
									PlayerToyInfo[playerid][i][ptRotY] = 0.0;
									PlayerToyInfo[playerid][i][ptRotZ] = 0.0;
									PlayerToyInfo[playerid][i][ptScaleX] = 1.0;
									PlayerToyInfo[playerid][i][ptScaleY] = 1.0;
									PlayerToyInfo[playerid][i][ptScaleZ] = 1.0;
									PlayerToyInfo[playerid][i][ptTradable] = 1;
									PlayerToyInfo[playerid][i][ptSpecial] = 1;
									
									SendClientMessageEx(playerid, COLOR_GRAD1, "Do khong con o trong, ban duoc cap tam mot o de dung/ban/doi laser.");
									SendClientMessageEx(playerid, COLOR_RED, "Luu y: Sau khi ban laser, o toy duoc cap tam se bi xoa.");
									break;
								}	
							}
						}
					}
					case 7, 8: switch(random(3)) {// 20%
						case 0:
						{

							format(szMessage, sizeof(szMessage), "AdmCmd: %s(%d) was just gifted by the system and he won a free house", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
							Log("logs/gifts.log", szMessage);
							format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang mot can nha mien phi.", GetPlayerNameEx(playerid));
							ABroadCast(COLOR_YELLOW, szMessage, 2);
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan mot can nha mien phi!");
							SendClientMessageEx(playerid, COLOR_GRAD2, " Luu y: Qua hiem nay co the mat toi 48 gio de duoc trao.");
							AddFlag(playerid, INVALID_PLAYER_ID, "Free House (Gift)");
							format(szMessage, sizeof(szMessage), "* %s vua nhan nha mien phi, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						case 1:
						{
							PlayerInfo[playerid][pTokens] += 150;
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan 150 VIP tokens!");
							format(szMessage, sizeof(szMessage), "* %s vua nhan 150 VIP tokens, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
						default:
						{

							format(szMessage, sizeof(szMessage), "AdmCmd: %s(%d) was just gifted by the system and he won a set of neons", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
							Log("logs/gifts.log", szMessage);
							format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s vua duoc he thong tang mot bo den neon mien phi.", GetPlayerNameEx(playerid));
							ABroadCast(COLOR_YELLOW, szMessage, 2);
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan mot bo den neon mien phi!");
							SendClientMessageEx(playerid, COLOR_GRAD2, " Luu y: Qua hiem nay co the mat toi 48 gio de duoc trao.");
							AddFlag(playerid, INVALID_PLAYER_ID, "Free set of neons (Gift)");
							format(szMessage, sizeof(szMessage), "* %s vua nhan mot bo den neon mien phi!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}

					}
					default:
					{ // 10%
						new gift = Random(1, 6);
						if(gift >= 1 && gift <= 3)
						{
							if(RimMod > 0) // Rim Kit
							{
								PlayerInfo[playerid][pRimMod]++;
								RimMod--;
								g_mysql_SaveMOTD();

								format(szMessage, sizeof(szMessage), "AdmWarning: %s(%d) was just gifted by the system and he won a rim modification kit. (%d left)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), RimMod);

								Log("logs/gifts.log", szMessage);
								format(szMessage, sizeof(szMessage), "* %s vua nhan bo do mam xe, chuc vui ve! Chi con %d bo.", GetPlayerNameEx(playerid), RimMod);
								ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
							}
							else
							{
								gift = 5;
							}
						}
						else if(gift == 4) //
						{
							if(CarVoucher > 0)
							{
								PlayerInfo[playerid][pCarVoucher]++;
								CarVoucher--;
								g_mysql_SaveMOTD();

								format(szMessage, sizeof(szMessage), "AdmWarning: %s(%d) was just gifted by the system and he won a restricted car voucher. (%d left)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), CarVoucher);

								Log("logs/gifts.log", szMessage);
								format(szMessage, sizeof(szMessage), "* %s vua nhan Restricted Car Voucher, chuc vui ve! Chi con %d voucher.", GetPlayerNameEx(playerid), CarVoucher);
								ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
								SendClientMessageEx(playerid, COLOR_CYAN, " Da them 1 Restricted Car Voucher vao tai khoan.");
								SendClientMessageEx(playerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
							}
							else gift = 5;
						}
						if(gift == 5)
						{
							PlayerInfo[playerid][pGVIPVoucher]++;
							SendClientMessageEx(playerid, COLOR_GRAD2, " Chuc mung, ban da nhan mot thang Gold VIP!");
							SendClientMessageEx(playerid, COLOR_CYAN, " Da them 1 Gold VIP Voucher vao tai khoan.");
							SendClientMessageEx(playerid, COLOR_GRAD2, " Xem voucher bang /myvouchers");
							format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s da nhan mot thang Gold VIP.", GetPlayerNameEx(playerid));
							ABroadCast(COLOR_YELLOW, szMessage, 2);
							format(szMessage, sizeof(szMessage), "* %s vua nhan mot thang Gold VIP, chuc vui ve!", GetPlayerNameEx(playerid));
							ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
						}
					}
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, "Ban khong co Gold Box Gift tokens.");
		}
		else SendClientMessage(playerid, COLOR_GREY, "Ban khong o gan Gold Box.");
	}
	else SendClientMessage(playerid, COLOR_GREY, "Reward Playing hien chua bat.");
	return 1;
}