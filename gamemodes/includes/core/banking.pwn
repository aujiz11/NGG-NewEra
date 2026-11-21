/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Banking System

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

PayDay(i) {
	if(!gPlayerLogged{i}) return 1;
	new
		string[128],
		interest,
		pVIPTax,
		year,
		month,
		day;
		
	getdate(year, month, day);
	
 	if(PlayerInfo[i][pLevel] > 0 && (PlayerInfo[i][pTogReports] == 1 || PlayerInfo[i][pAdmin] < 2)) {
		if(GetPVarType(i, "debtMsg")) {
			if(GetPlayerCash(i) < 0 && PlayerInfo[i][pJailTime] < 1 && !IsACop(i) && PlayerInfo[i][pWantedLevel] < 6) {
				format(string,sizeof(string),"Ban dang no $%s, hay tim cach tra de tranh gap rac roi!", number_format(GetPlayerCash(i)));
				SendClientMessageEx(i, COLOR_LIGHTRED, string);
			}
			else DeletePVar(i, "debtMsg");
		}

		if(0 <= PlayerInfo[i][pRenting] < sizeof HouseInfo) {
			if(HouseInfo[PlayerInfo[i][pRenting]][hRentFee] > PlayerInfo[i][pAccount]) {
				PlayerInfo[i][pRenting] = INVALID_HOUSE_ID;
				SendClientMessageEx(i, COLOR_WHITE, "Ban da bi duoi khoi nha vi khong tra tien thue.");
			}
			else {
				HouseInfo[PlayerInfo[i][pRenting]][hSafeMoney] += HouseInfo[PlayerInfo[i][pRenting]][hRentFee];
				PlayerInfo[i][pAccount] -= HouseInfo[PlayerInfo[i][pRenting]][hRentFee];
			}
		}
		if(PlayerInfo[i][pConnectSeconds] >= 3600) {
			if(GetPVarInt(i, "pBirthday") == 1) {
				PlayerInfo[i][pPayCheck] = PlayerInfo[i][pPayCheck] * 2;
			}
			if(GetPVarType(i, "AdvisorDuty")) {
				PlayerInfo[i][pDutyHours]++;
			}
			if(SpecTimer) AddSpecialToken(i);
			SendClientMessageEx(i, COLOR_WHITE, "________ SAO KE NGAN HANG ________");
			if(PlayerInfo[i][pNation] == 0)
			{
				if(PlayerInfo[i][pDonateRank] < 4)
				{
					format(string, sizeof(string), "Luong: $%s  |  Thue SA Gov: $%s (%d phan tram)", number_format(PlayerInfo[i][pPayCheck]), number_format((PlayerInfo[i][pPayCheck] / 100) * TaxValue), TaxValue);
					PlayerInfo[i][pAccount] -= (PlayerInfo[i][pPayCheck] / 100) * TaxValue;
					Tax += (PlayerInfo[i][pPayCheck] / 100) * TaxValue;
				}
				else
				{
					pVIPTax = TaxValue - 15;
					if(pVIPTax < 0) { pVIPTax = 0; }
					format(string, sizeof(string), "Luong: $%s | Thue SA Gov: $%s (%d phan tram) {FFFF00}(Platinum VIP: giam 15 phan tram)", number_format(PlayerInfo[i][pPayCheck]), number_format((PlayerInfo[i][pPayCheck] / 100) * pVIPTax), pVIPTax);
					PlayerInfo[i][pAccount] -= (PlayerInfo[i][pPayCheck] / 100) * pVIPTax;
					Tax += (PlayerInfo[i][pPayCheck] / 100) * pVIPTax;
				}
			}
			else if(PlayerInfo[i][pNation] == 1)
			{
				if(PlayerInfo[i][pDonateRank] < 4)
				{
					format(string, sizeof(string), "Luong: $%s  |  Thue NE Gov: $%s (%d phan tram)", number_format(PlayerInfo[i][pPayCheck]), number_format((PlayerInfo[i][pPayCheck] / 100) * TRTaxValue), TRTaxValue);	
					PlayerInfo[i][pAccount] -= (PlayerInfo[i][pPayCheck] / 100) * TRTaxValue;
					TRTax += (PlayerInfo[i][pPayCheck] / 100) * TRTaxValue;
				}
				else
				{
					pVIPTax = TRTaxValue - 15;
					if(pVIPTax < 0) { pVIPTax = 0; }
					format(string, sizeof(string), "Luong: $%s | Thue NE Gov: $%s (%d phan tram) {FFFF00}(Platinum VIP: giam 15 phan tram)", number_format(PlayerInfo[i][pPayCheck]), number_format((PlayerInfo[i][pPayCheck] / 100) * pVIPTax), pVIPTax);	
					PlayerInfo[i][pAccount] -= (PlayerInfo[i][pPayCheck] / 100) * pVIPTax;
					TRTax += (PlayerInfo[i][pPayCheck] / 100) * pVIPTax;
				}
			}
			SendClientMessageEx(i, COLOR_GRAD1, string);
			interest = (PlayerInfo[i][pAccount] + 1) / 1000;

			switch(PlayerInfo[i][pDonateRank]) {
				case 0: {
					if(interest > 50000) interest = 50000;
					SendClientMessageEx(i, COLOR_GRAD1, "So du: $%s  |  Lai suat: 0.1 phan tram (toi da 50k)", number_format(PlayerInfo[i][pAccount]));
				}
				case 1: {
					if(interest > 100000) interest = 100000;
					SendClientMessageEx(i, COLOR_GRAD1, "So du: $%s  |  Lai suat: 0.1 phan tram {FFFF00}(Bronze VIP: toi da 100k)", number_format(PlayerInfo[i][pAccount]));
				}
				case 2:	{
					if(interest > 150000) interest = 150000;
					SendClientMessageEx(i, COLOR_GRAD1, "So du: $%s  |  Lai suat: 0.1 phan tram {FFFF00}(Silver VIP: toi da 150k)", number_format(PlayerInfo[i][pAccount]));
				}
				case 3: {
					if(interest > 200000) interest = 200000;
					SendClientMessageEx(i, COLOR_GRAD1, "So du: $%s  |  Lai suat: 0.1 phan tram {FFFF00}(Gold VIP: toi da 200k)", number_format(PlayerInfo[i][pAccount]));
				}
				case 4, 5: {
					if(interest > 250000) interest = 250000;
					SendClientMessageEx(i, COLOR_GRAD1, "So du: $%s  |  Lai suat: 0.1 phan tram {FFFF00}(Platinum VIP: toi da 250k)", number_format(PlayerInfo[i][pAccount]));
				}
			}
			if(PlayerInfo[i][pTaxiLicense] == 1) {
				PlayerInfo[i][pAccount] -= (PlayerInfo[i][pPayCheck] / 100) * 5;
				Tax += (PlayerInfo[i][pPayCheck] / 100) * 5;
				SendClientMessageEx(i, COLOR_GRAD2, "Phi giay phep Taxi (5 phan tram): $%s", number_format((PlayerInfo[i][pPayCheck] / 100) * 5));
			}
			for(new iGroupID; iGroupID < MAX_GROUPS; iGroupID++)
			{
				if(PlayerInfo[i][pNation] == 0)
				{
					if(arrGroupData[iGroupID][g_iAllegiance] == 1)
					{
						if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_GOV)
						{
							new str[128];
							if(PlayerInfo[i][pDonateRank] < 4) {
								format(str, sizeof(str), "%s has paid $%s in tax.", GetPlayerNameEx(i), number_format((PlayerInfo[i][pPayCheck] / 100) * TaxValue));
							} else {
								format(str, sizeof(str), "%s has paid $%s in tax.", GetPlayerNameEx(i), number_format((PlayerInfo[i][pPayCheck] / 100) * pVIPTax));
							}
							GroupPayLog(iGroupID, str);
						}
					}
				}
				else if (PlayerInfo[i][pNation] == 1)
				{
					if(arrGroupData[iGroupID][g_iAllegiance] == 2)
					{
						if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_GOV)
						{
							new str[128];
							if(PlayerInfo[i][pDonateRank] < 4) {
								format(str, sizeof(str), "%s has paid $%s in tax.", GetPlayerNameEx(i), number_format((PlayerInfo[i][pPayCheck] / 100) * TRTaxValue));
							} else {
								format(str, sizeof(str), "%s has paid $%s in tax.", GetPlayerNameEx(i), number_format((PlayerInfo[i][pPayCheck] / 100) * pVIPTax));
							}
							GroupPayLog(iGroupID, str);
						}
					}
				}
			}
			PlayerInfo[i][pAccount] += interest;
			SendClientMessageEx(i, COLOR_GRAD3, "Tien lai: $%s", number_format(interest));
			SendClientMessageEx(i, COLOR_GRAD4, "______________________________________");
			SendClientMessageEx(i, COLOR_GRAD5, "So du moi: $%s  |  Tien thue: $%s", number_format(PlayerInfo[i][pAccount]), number_format((0 <= PlayerInfo[i][pRenting] < sizeof HouseInfo) ? (HouseInfo[PlayerInfo[i][pRenting]][hRentFee]) : (0)));

			//GivePlayerCash(i, PlayerInfo[i][pPayCheck]);
			GivePlayerCashEx(i, TYPE_BANK, PlayerInfo[i][pPayCheck]);
			HourDedicatedPlayer(i);
			/*if(month == 12 && day == 5)
			{
				if(++PlayerInfo[i][pFallIntoFun] == 5)
				{
					if(PlayerInfo[i][pReceivedPrize] == 0)
					{
						PlayerInfo[i][pGVIPExVoucher] += 1;
						SendClientMessageEx(i, COLOR_LIGHTBLUE, "You have received a 7 day Gold VIP voucher for playing 5 hours.");
						PlayerInfo[i][pReceivedPrize] = 1;
					}
					PlayerInfo[i][pFallIntoFun] = 0;
				}
			}*/
			
			// Fall Into Fun - 100 HP every 5 paychecks
			/*PlayerInfo[i][pFallIntoFun]++;
			
			if(PlayerInfo[i][pFallIntoFun] == 5)
			{	
				new Float: health;
				GetHealth(i, health);
				
				if(health == 100)
				{
					PlayerInfo[i][pFirstaid]++;
					SendClientMessageEx(i, COLOR_LIGHTBLUE, "You have played for 5 hours and received a firstaid kit due to having 100 percent health already.");
					PlayerInfo[i][pFallIntoFun] = 0;
				}
				else 
				{
					SetHealth(i, 100.0);
					SendClientMessageEx(i, COLOR_LIGHTBLUE, "You have played for 5 hours and received 100 percent HP.");
					PlayerInfo[i][pFallIntoFun] = 0;
				}
			}*/
			PayGroupMember(i);
   			if (PlayerInfo[i][pBusiness] != INVALID_BUSINESS_ID) {
				if (Businesses[PlayerInfo[i][pBusiness]][bAutoPay] && PlayerInfo[i][pBusinessRank] >= 0 && PlayerInfo[i][pBusinessRank] < 5) {
				    if (Businesses[PlayerInfo[i][pBusiness]][bSafeBalance] < Businesses[PlayerInfo[i][pBusiness]][bRankPay][PlayerInfo[i][pBusinessRank]]) {
				    	SendClientMessageEx(i,COLOR_RED,"Doanh nghiep khong du tien tra luong cho ban.");
				    }
					else {
						//GivePlayerCash(i, Businesses[PlayerInfo[i][pBusiness]][bRankPay][PlayerInfo[i][pBusinessRank]]);
						GivePlayerCashEx(i, TYPE_BANK, Businesses[PlayerInfo[i][pBusiness]][bRankPay][PlayerInfo[i][pBusinessRank]]);
						Businesses[PlayerInfo[i][pBusiness]][bSafeBalance] -= Businesses[PlayerInfo[i][pBusiness]][bRankPay][PlayerInfo[i][pBusinessRank]];
						SaveBusiness(PlayerInfo[i][pBusiness]);
						SendClientMessageEx(i, COLOR_GRAD2, "Luong DN: $%s", number_format(Businesses[PlayerInfo[i][pBusiness]][bRankPay][PlayerInfo[i][pBusinessRank]]));
					}
				}
			}
			
			GameTextForPlayer(i, "~y~PayDay~n~~w~Tien luong", 5000, 1);
			//SendAudioToPlayer(i, 63, 100);
			PlayerInfo[i][pConnectSeconds] = 0;
			PlayerInfo[i][pPayCheck] = 0;
			if(++PlayerInfo[i][pConnectHours] == 2) {
				SendClientMessageEx(i, COLOR_LIGHTRED, "Ban da duoc phep giu/dung vu khi!");
			}
			if(PlayerInfo[i][pDonateRank] > 0 && ++PlayerInfo[i][pPayDayHad] >= 5) {
				PlayerInfo[i][pExp]++;
				PlayerInfo[i][pPayDayHad] = 0;
			}
			// Auto Levels
			if(PlayerInfo[i][pAdmin] < 2) LevelCheck(i);
			
			// Zombie Halloween
			if(month == 10 && day == 30)
			{
				if(PlayerInfo[i][pFallIntoFun] < 4)
				{
					PlayerInfo[i][pFallIntoFun]++;
				}
				else {
					 PlayerInfo[i][pFallIntoFun] = 0;
					 PlayerInfo[i][pVials] += 1;
				}
			}	
			/*
			if((month == 12 && day == 24) || (month == 10 && day == 31))
			{
				if(PlayerInfo[i][pTrickortreat] > 0)
				{
					PlayerInfo[i][pTrickortreat]--;
				}
			}*/
			if(month == 10 && (day == 29 || day == 30 || day == 31))
			{
				++PlayerInfo[i][pTrickortreat];
				if(PlayerInfo[i][pTrickortreat] == 15) {
					GiveHtoy(i, 2590, "Scythe");
				}
				if(PlayerInfo[i][pTrickortreat] == 30) {
					GiveHtoy(i, 2907, "Zombie Torso");
				}
			}
			if(month == 5 && day == 25) //Memorial Day 2015
			{
				if(++PlayerInfo[i][pTrickortreat] == 3)
					SendClientMessageEx(i, -1, "Ban nhan 1 Double EXP Token vi da choi 3 gio!"), PlayerInfo[i][pEXPToken]++, PlayerInfo[i][pTrickortreat] = 0;
			}
			//Weekday Madness for Fall Into Fun event; re-using Trickortreat variable to check connected time
			/*if(month == 10 && (day == 9 || day == 16))
			{
				PlayerInfo[i][pRewardDrawChance] += 2;
			}
			else if(month == 10 && day == 19)
			{
				PlayerInfo[i][pRewardDrawChance] += 3;
			}
			else PlayerInfo[i][pRewardDrawChance]++;
			
			if(PlayerInfo[i][pDonateRank] >= 3 && month == 10 && day == 13)
			{
				PlayerInfo[i][pRewardDrawChance] += 3;
			}*/
			Misc_Save();
			if(iRewardPlay) {
				PlayerInfo[i][pRewardHours]++;
				if(floatround(PlayerInfo[i][pRewardHours]) % 16 == 0) {
					PlayerInfo[i][pGoldBoxTokens]++;
					SendClientMessage(i, COLOR_LIGHTBLUE, "Ban nhan 1 Gold Giftbox token!  #FallIntoFun");
				}
				SendClientMessageEx(i, COLOR_YELLOW, "Ban co %d Reward Hours, dung /rewards de xem them.", floatround(PlayerInfo[i][pRewardHours]));
			}

			if(PlayerInfo[i][pDoubleEXP] > 0) {
				PlayerInfo[i][pDoubleEXP]--;
				SendClientMessageEx(i, COLOR_YELLOW, "Ban nhan 2 diem kinh nghiem thay vi 1. Double EXP token con %d gio.", PlayerInfo[i][pDoubleEXP]);
				PlayerInfo[i][pExp] += 2;
			}
			else PlayerInfo[i][pExp]++;

			if(GetPVarInt(i, "pBirthday") == 1) {
				SendClientMessageEx(i, COLOR_YELLOW, "Gold VIP: Ban nhan x2 luong lam qua sinh nhat!");
			}
			
			if(PlayerInfo[i][pWRestricted] > 0 && --PlayerInfo[i][pWRestricted] == 0) {
				SendClientMessageEx(i, COLOR_LIGHTRED, "Vu khi cua ban khong con bi han che!");
			}
			
			if(PlayerInfo[i][pShopNotice] > 0) PlayerInfo[i][pShopNotice]--;
			if(ShopReminder == 1 && PlayerInfo[i][pShopNotice] == 0)
			{
				PlayerInfo[i][pShopCounter]++;
				PlayerInfo[i][mShopCounter]++;
				/*if(PlayerInfo[i][pLevel] <= 5 && PlayerInfo[i][mShopCounter] == 3 || (PlayerInfo[i][pLevel] > 5 && PlayerInfo[i][mShopCounter] >= 4 && PlayerInfo[i][pCredits] >= 10))
				{
					PlayerTextDrawSetString(i, MicroNotice[i], ShopMsg[PlayerInfo[i][mNotice]]);
					PlayerTextDrawShow(i, MicroNotice[i]);
					SetTimerEx("HidePlayerTextDraw", 10000, false, "ii", i, _:MicroNotice[i]);
					if(++PlayerInfo[i][mNotice] > 3) PlayerInfo[i][mNotice] = 0;
					PlayerInfo[i][mShopCounter] = 0;
				}
				if(PlayerInfo[i][pLevel] <= 5 && PlayerInfo[i][pShopCounter] == 5 || PlayerInfo[i][pLevel] > 5 && PlayerInfo[i][pShopCounter] == 10)
				{
					format(string, sizeof(string), "Hey check this out, type: ~y~/nggshop");
					if(PlayerInfo[i][pConnectHours] >= 50)
					{
						strcat(string, "~w~~n~To disable this notice for 24 hours, type: ~y~/togshopnotice");
					}
					PlayerInfo[i][pShopCounter] = 0;
					PlayerTextDrawSetString(i, ShopNotice[i], string);
					PlayerTextDrawShow(i, ShopNotice[i]);
					SetTimerEx("HidePlayerTextDraw", 10000, false, "ii", i, _:ShopNotice[i]);
				}*/
			}
			if(FIFEnabled == 1)
			{
				FIFInfo[i][FIFHours] += 1;
				if((FIFInfo[i][FIFHours] % 3) == 0)
				{
					if(FIFGThurs == 1)
					{
						GThursChances += 1;
						if(GThursChances == 23)
						{
							PlayerInfo[i][pGVIPVoucher] += 1;
							SendClientMessageEx(i, COLOR_WHITE, "Ban trung 1 Month Gold VIP Voucher tu Fall Into Fun! Dung /myvouchers de nhan.");
							GThursChances = 0;
							format(string, sizeof(string), "%s(%d) won a 1 Month GVIP Voucher", GetPlayerNameEx(i), GetPlayerSQLId(i));
							Log("logs/fif.log", string);
						}
					}
					if(FIFGP3 == 1 && PlayerInfo[i][pDonateRank] >= 3)
					{
						FIFInfo[i][FIFChances] += 3;
						SendClientMessageEx(i, COLOR_WHITE, "Ban nhan 3 FIF Chances! Hien co %d luot!", FIFInfo[i][FIFChances]);
						format(string, sizeof(string), "%s(%d) won 3 FIF Chances", GetPlayerNameEx(i), GetPlayerSQLId(i));
						Log("logs/fif.log", string);
					}
					else
					{
						switch(FIFType)
						{
							case 1:
							{
								FIFInfo[i][FIFChances] += 1;
								SendClientMessageEx(i, COLOR_WHITE, "Ban nhan 1 FIF Chance! Hien co %d luot!", FIFInfo[i][FIFChances]);
								format(string, sizeof(string), "%s(%d) won 1 FIF Chance.", GetPlayerNameEx(i), GetPlayerSQLId(i));
								Log("logs/fif.log", string);
							}
							case 2:
							{
								FIFInfo[i][FIFChances] += 2;
								SendClientMessageEx(i, COLOR_WHITE, "Ban nhan 2 FIF Chance's! Hien co %d luot!", FIFInfo[i][FIFChances]);
								format(string, sizeof(string), "%s(%d) won 2 FIF Chances.", GetPlayerNameEx(i), GetPlayerSQLId(i));
								Log("logs/fif.log", string);
							}
							case 3:
							{
								FIFInfo[i][FIFChances] += 3;
								SendClientMessageEx(i, COLOR_WHITE, "Ban nhan 3 FIF Chances! Hien co %d luot!", FIFInfo[i][FIFChances]);
								format(string, sizeof(string), "%s(%d) won 3 FIF Chances.", GetPlayerNameEx(i), GetPlayerSQLId(i));
								Log("logs/fif.log", string);
							}
						}
					}
				}
				if(FIFTimeWarrior == 1)
				{
					if(FIFInfo[i][FIFHours] % 28 == 0)
					{
						PlayerInfo[i][pGoldBoxTokens] += 1;
						SendClientMessageEx(i, COLOR_WHITE, "Ban trung Gold Box Token tu Fall Into Fun! Dung /getrewardgift de nhan.");
						format(string, sizeof(string), "%s(%d) won a Gold Box Token", GetPlayerNameEx(i), GetPlayerSQLId(i));
						Log("logs/fif.log", string);
					}
				}
				g_mysql_SaveFIF(i);
			}
			if(month == 4 && (day == 25 || day == 26)) // NGG B-Day 2015
			{
				SendClientMessageEx(i, -1, "Ban nhan 3 event tokens vi da choi 1 gio! Dung /inv de xem so token.");
				PlayerInfo[i][pEventTokens] += 3;
			}
			CallLocalFunction("InactivityCounter", "i", i);
		}
		else SendClientMessageEx(i, COLOR_LIGHTRED, "* Ban chua choi du lau de nhan luong.");
	}

	if (GetPVarType(i, "UnreadMails") && HasMailbox(i))
	{
		SendClientMessageEx(i, COLOR_YELLOW, "Ban co thu chua doc trong hop thu");
	}
	return 1;
}

forward GiveHtoy(giveplayerid, toyid, const name[]);
public GiveHtoy(giveplayerid, toyid, const name[]) {
	new icount = GetPlayerToySlots(giveplayerid), success = 0, string[128];
	for(new v = 0; v < icount; v++)
	{
		if(PlayerToyInfo[giveplayerid][v][ptModelID] == 0)
		{
			PlayerToyInfo[giveplayerid][v][ptModelID] = toyid;
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
				PlayerToyInfo[giveplayerid][i][ptModelID] = toyid;
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
				
				SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Vi da het o trong, ban duoc them tam mot o de dung/ban/doi %s.", name);
				SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: O toy them tam se bi xoa sau khi ban %s.", name);
				break;
			}	
		}
	}

	SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Choi du %d gio, ban nhan duoc %s!", PlayerInfo[giveplayerid][pTrickortreat], name);
	format(string, sizeof(string), "* %s vua duoc tang %s!", GetPlayerNameEx(giveplayerid), name);
	ProxDetector(30.0, giveplayerid, string, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
	format(string, sizeof(string), "* %s(%d) was just gifted a %s for playing %d hours during the zombie event.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), name, PlayerInfo[giveplayerid][pTrickortreat]);
	Log("logs/giftbox.log", string), OnPlayerStatsUpdate(giveplayerid);
	return 1;
}

stock IsAtATM(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsPlayerInRangeOfPoint(playerid,3.0,2065.439453125, -1897.5510253906, 13.19670009613) || IsPlayerInRangeOfPoint(playerid,3.0,1497.7467041016, -1749.8747558594, 15.088212013245) || IsPlayerInRangeOfPoint(playerid,3.0,2093.5124511719, -1359.5474853516, 23.62727355957) || IsPlayerInRangeOfPoint(playerid,3.0,1155.6235351563, -1464.9141845703, 15.44321346283))
		{//ATMS
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,3.0,2139.4487304688, -1164.0811767578, 23.63508605957) || IsPlayerInRangeOfPoint(playerid,3.0,1482.7761230469, -1010.3353881836, 26.48664855957) || IsPlayerInRangeOfPoint(playerid,3.0,1482.7761230469, -1010.3353881836, 26.48664855957) || IsPlayerInRangeOfPoint(playerid,3.0,387.16552734375, -1816.0512695313, 7.4834146499634))
		{//ATMS
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,3.0,-24.385023117065, -92.001075744629, 1003.1897583008) || IsPlayerInRangeOfPoint(playerid,3.0,-31.811220169067, -58.106018066406, 1003.1897583008) || IsPlayerInRangeOfPoint(playerid,3.0,1212.7785644531, 2.451762676239, 1000.5647583008) || IsPlayerInRangeOfPoint(playerid,3.0,2324.4028320313, -1644.9445800781, 14.469946861267))
		{//ATMS
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,3.0,2228.39, -1707.78, 13.25) || IsPlayerInRangeOfPoint(playerid,3.0,651.19305419922, -520.48815917969, 15.978837013245) || IsPlayerInRangeOfPoint(playerid, 3.0, 45.78035736084, -291.80926513672, 1.5024013519287) || IsPlayerInRangeOfPoint(playerid,3.0,1275.7958984375, 368.31481933594, 19.19758605957) || IsPlayerInRangeOfPoint(playerid,3.0,2303.4577636719, -13.539554595947, 26.12727355957))/*End of Red County Random ATM's*/
		{//ATMS
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,3.0,294.80, -84.01, 1001.0) || /*Start of Red County Random ATM's*/IsPlayerInRangeOfPoint(playerid,3.0,691.08215332031, -618.5625, 15.978837013245) || IsPlayerInRangeOfPoint(playerid,3.0,173.23471069336, -155.07606506348, 1.2210245132446) || IsPlayerInRangeOfPoint(playerid,3.0,1260.8796386719, 209.30152893066, 19.19758605957) || IsPlayerInRangeOfPoint(playerid,3.0,2316.1015625, -88.522567749023, 26.12727355957))/*End of Red County Random ATM's*/
		{//ATMS
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,3.0,1311.0361,-1446.2249,0.2216))
		{//ATMS
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,3.0,2052.9246, -1660.6346, 13.1300) || IsPlayerInRangeOfPoint(playerid,3.0,-1980.6300,121.5300,27.3100))
		{
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,3.0,-2453.7600,754.8200,34.8000) || IsPlayerInRangeOfPoint(playerid,3.0,-2678.6201,-283.3400,6.8000))
		{
		    return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,5.0,519.8157,-2890.8601,4.4609))
		{
		    return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,5.0,2565.667480, 1406.839355, 7699.584472) || IsPlayerInRangeOfPoint(playerid, 5.0, 3265.30004883, -631.90002441, 8423.90039062) || IsPlayerInRangeOfPoint(playerid, 5.0, 1829.5000, 1391.0000, 1464.0000) || IsPlayerInRangeOfPoint(playerid, 5.0, 1755.8000, 1434.1000, 2013.4000))
		{// VIP Lounge ATM || Package Club Interior
			return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid,5.0,-665.975341, -4033.334716, 20.779014) || IsPlayerInRangeOfPoint(playerid,5.0,-1619.9645996094,713.67535400391, 19995.501953125))
		{// Random Island ATM
			return 1;
		}
		// Famed Lounge
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 883.7170, 1442.4282, -82.3370))
		{
		    return 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 2926.9199, -1529.9800, 10.6900)) return 1; //NGG Shop
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 986.4434,2056.2480,1085.8531) || IsPlayerInRangeOfPoint(playerid, 3.0, 1014.1396,2060.8284,1085.8531) || IsPlayerInRangeOfPoint(playerid, 3.0, 1013.4720,2023.8784,1085.8531)) return 1; //Glen Park
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1378.0894, 1740.0106, 927.3564)) return 1; //Olympics
	}
	return 0;
}


CMD:pay(playerid, params[])
{
	new id, amount, amountText[32];
	if(sscanf(params, "us[32]", id, amountText)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /pay [player] [amount]");
	if(!ParseBankTransferAmount(amountText, amount)) return SendClientMessageEx(playerid, COLOR_GRAD1, "So tien moi lan phai tu $1 den $99,999,999.");
	return Interact_PayPlayer(playerid, id, amount);
}

CMD:writecheck(playerid, params[])
{
	new string[128], giveplayerid, monies, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, monies, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /writecheck [Playerid/PartOfName] [Amount] [Reason]");

    if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
    if(monies < 1 || monies > 99999999)
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Gia tri sec phai tu $1 den $99,999,999!");
        return 1;
    }
	if(PlayerInfo[playerid][pCash] < 0 || PlayerInfo[playerid][pAccount] < 0)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Tien mat hoac so du ngan hang cua ban dang am!");
	}
    if(PlayerInfo[playerid][pChecks] == 0)
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Can co so sec de viet sec!");
        return 1;
    }
    if(gettime()-GetPVarInt(playerid, "LastTransaction") < 10) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chi duoc giao dich moi 10 giay, hay cho!");
    if(strlen(reason) > 64) return SendClientMessageEx(playerid, COLOR_GRAD1, "Noi dung sec khong duoc vuot 64 ky tu.");
    if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the viet sec cho chinh minh!"); return 1; }
    if(ProxDetectorS(5.0, playerid, giveplayerid))
	{
     	new playermoney = PlayerInfo[playerid][pAccount];
      	if(monies > 0 && playermoney >= monies)
		{
			//GivePlayerCashEx(playerid, TYPE_BANK, -monies);
			//GivePlayerCashEx(giveplayerid, TYPE_BANK, monies);
			PlayerInfo[playerid][pAccount] = PlayerInfo[playerid][pAccount] - monies;
     		PlayerInfo[giveplayerid][pCheckCash] = PlayerInfo[giveplayerid][pCheckCash]+monies;
       		if(PlayerInfo[playerid][pDonateRank] == 0)
			{
   				new fee = (monies*8)/100;
       			GivePlayerCash(playerid, (0 - fee));
				SendClientMessageEx(playerid, COLOR_GRAD1, "Da viet sec $%d cho %s (vi %s), thu phi 8 phan tram.",monies,GetPlayerNameEx(giveplayerid),reason);
             	PlayerInfo[playerid][pChecks]--;
				SendClientMessageEx(playerid, COLOR_GRAD1, "Ban con %d to sec.",PlayerInfo[playerid][pChecks]);
      		}
          	else
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Da viet sec $%d cho %s (vi %s), mien phi 8 phan tram.",monies,GetPlayerNameEx(giveplayerid),reason);
          		PlayerInfo[playerid][pChecks]--;
				SendClientMessageEx(playerid, COLOR_GRAD1, "Ban con %d to sec.",PlayerInfo[playerid][pChecks]);
			}
			SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Ban nhan sec $%d tu %s voi noi dung: %s", monies,GetPlayerNameEx(playerid),reason);
        	format(string, sizeof(string), "* %s lay so sec, viet va dua mot to sec cho %s.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid));
         	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
          	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
           	PlayerPlaySound(giveplayerid, 1052, 0.0, 0.0, 0.0);
           	SetPVarInt(playerid, "LastTransaction", gettime());

           	/*OnPlayerStatsUpdate(playerid);
			OnPlayerStatsUpdate(giveplayerid);*/

			new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));
 			format(string, sizeof(string), "[CHECK] %s(%d) (IP:%s) has paid $%s to %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, number_format(monies), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), ipex);
  			Log("logs/pay.log", string);
		}
  		else
		{
  			SendClientMessageEx(playerid, COLOR_GRAD1, "So tien khong hop le hoac ban khong du tien!");
     	}
	}
 	else
	{
 		SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
   	}
    return 1;
}

CMD:charity(playerid, params[])
{
	new moneys;
	if(sscanf(params, "d", moneys)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /charity [amount]");
	if(moneys < 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "So tien chua du.");
	if(GetPlayerCash(playerid) < moneys) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du tien.");
	GivePlayerCash(playerid, -moneys);

	format(szMiscArray, sizeof(szMiscArray), "%s, cam on ban da quyen gop $%s.", GetPlayerNameEx(playerid), number_format(moneys));
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	SendClientMessageEx(playerid, COLOR_GRAD1, szMiscArray);
	format(szMiscArray, sizeof(szMiscArray), "[CHARITY] %s has donated $%s", GetPlayerNameEx(playerid), number_format(moneys));
	Log("logs/pay.log", szMiscArray);
	return 1;
}

CMD:nextpaycheck(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_YELLOW, "So phut tu lan nhan luong truoc: %d  Con khoang %d phut de nhan luong", floatround(PlayerInfo[playerid][pConnectSeconds]/60), floatround((3600-PlayerInfo[playerid][pConnectSeconds]) / 60));
	SendClientMessageEx(playerid, COLOR_GRAD2, "Luu y, thoi gian khong duoc tinh khi ban tam dung game.");
	return 1;
}

ParseBankTransferAmount(const text[], &amount) {
	amount = 0;
	if(!text[0]) return 0;
	for(new i; text[i]; ++i) {
		if(text[i] < '0' || text[i] > '9') return 0;
		new digit = text[i] - '0';
		if(amount > (cellmax - digit) / 10) return 0;
		amount = amount * 10 + digit;
	}
	return amount > 0;
}

BankTransferDebit(amount, bool:chargeFee, &fee) {
	fee = 0;
	if(amount <= 0) return 0;
	if(chargeFee) fee = (amount / 100) * 3 + (amount % 100) * 3 / 100;
	if(amount > cellmax - fee) return 0;
	return amount + fee;
}

CommitBankTransfer(playerid, targetid, amount, debit) {
    if(playerid < 0 || playerid >= MAX_PLAYERS || targetid < 0 || targetid >= MAX_PLAYERS || playerid == targetid
        || !IsPlayerConnected(playerid) || !IsPlayerConnected(targetid) || !gPlayerLogged{playerid} || !gPlayerLogged{targetid}
        || !gAccountsInnoDB || mysql_unprocessed_queries(MainPipeline) != 0 || amount <= 0 || debit < amount) return 0;
    new sourceid = GetPlayerSQLId(playerid), destid = GetPlayerSQLId(targetid);
    if(sourceid <= 0 || destid <= 0 || sourceid == destid || PlayerInfo[playerid][pAccount] < debit || PlayerInfo[targetid][pAccount] > cellmax - amount) return 0;
    new source = PlayerInfo[playerid][pAccount] - debit, destination = PlayerInfo[targetid][pAccount] + amount, query[512];
    mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` a JOIN `accounts` b ON b.`id`=%d SET a.`Bank`=%d,b.`Bank`=%d WHERE a.`id`=%d AND a.`Bank`=%d AND b.`Bank`=%d",
        destid, source, destination, sourceid, PlayerInfo[playerid][pAccount], PlayerInfo[targetid][pAccount]);
    new Cache:result = mysql_query(MainPipeline, query);
    if(!cache_is_valid(result)) return 0;
    new affected = cache_affected_rows();
    cache_delete(result);
    if(affected != 2) return 0;
    PlayerInfo[playerid][pAccount] = source;
    PlayerInfo[targetid][pAccount] = destination;
    return 1;
}

TransferBankAccount(playerid, targetid, amount, bool:atATM) {
	if(restarting) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Giao dich da tam dung de khoi dong lai may chu bao tri.");
		return atATM ? ShowATMMenu(playerid, 3) : ShowBankMenu(playerid, 3);
	}
	if(PlayerInfo[playerid][pLevel] < 3) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Can dat cap 3 de dung tinh nang nay!");
		return atATM ? ShowATMMenu(playerid, 3) : ShowBankMenu(playerid, 3);
	}
	if(gettime()-GetPVarInt(playerid, "LastTransaction") < 10) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Chi duoc giao dich moi 10 giay, hay cho!");
		return atATM ? ShowATMMenu(playerid, 3) : ShowBankMenu(playerid, 3);
	}

	new fee, debit = BankTransferDebit(amount, atATM && PlayerInfo[playerid][pDonateRank] == 0, fee);
	if(!debit || debit > PlayerInfo[playerid][pAccount] || PlayerInfo[targetid][pAccount] > cellmax - amount)
		return SendClientMessageEx(playerid, COLOR_WHITE, "Khong du tien gom ca phi, hoac so du nguoi nhan vuot gioi han.");
	
	DeletePVar(playerid, atATM ? ("ATMTransferTo") : ("BankTransferTo"));
	DeletePVar(playerid, atATM ? ("ATMTransferAccount") : ("BankTransferAccount"));
	DeletePVar(playerid, atATM ? ("ATMTransferSession") : ("BankTransferSession"));
	
	if(!CommitBankTransfer(playerid, targetid, amount, debit)) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Chuyen tien chua duoc xac nhan. Hay cho va chon lai nguoi nhan.");
		return atATM ? ShowATMMenu(playerid, 3) : ShowBankMenu(playerid, 3);
	}
	if(fee) {
		SendClientMessageEx(playerid, COLOR_YELLOW, "Phi chuyen tien 3 phan tram: -$%d.", fee);
	}

	SendClientMessageEx(playerid, COLOR_YELLOW, "Da chuyen $%s vao tai khoan cua %s.", number_format(amount), GetPlayerNameEx(targetid));
	SendClientMessageEx(targetid, COLOR_YELLOW, "Ban nhan $%s vao tai khoan ngan hang tu %s.", number_format(amount), GetPlayerNameEx(playerid));
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	PlayerPlaySound(targetid, 1052, 0.0, 0.0, 0.0);

	new ip[32], ipex[32];
	GetPlayerIp(playerid, ip, sizeof(ip));
	GetPlayerIp(targetid, ipex, sizeof(ipex));
	format(szMiscArray, sizeof(szMiscArray), "[%s] %s(%d) (IP:%s) has transferred $%s to %s(%d) (IP:%s).", atATM ? ("ATM") : ("Bank"), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, number_format(amount), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), ipex);
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[targetid][pAdmin] >= 2) Log("logs/adminpay.log", szMiscArray); else Log("logs/pay.log", szMiscArray);
	format(szMiscArray, sizeof(szMiscArray), "[%s] %s (IP:%s) has transferred $%s to %s (IP:%s).", atATM ? ("ATM") : ("Bank"), GetPlayerNameEx(playerid), ip, number_format(amount), GetPlayerNameEx(targetid), ipex);
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[targetid][pAdmin] >= 2) {
		format(szMiscArray, sizeof(szMiscArray), "[%s] Admin %s has transferred $%s to %s", atATM ? ("ATM") : ("Bank"), GetPlayerNameEx(playerid), number_format(amount), GetPlayerNameEx(targetid));
		if(!strcmp(GetPlayerIpEx(playerid), GetPlayerIpEx(targetid), true)) strcat(szMiscArray, " (1)");
		ABroadCast(COLOR_YELLOW, szMiscArray, 4);
	}
	else ABroadCast(COLOR_YELLOW, szMiscArray, 2);

	SetPVarInt(playerid, "LastTransaction", gettime());
	return atATM ? ShowATMMenu(playerid) : ShowBankMenu(playerid);
}
