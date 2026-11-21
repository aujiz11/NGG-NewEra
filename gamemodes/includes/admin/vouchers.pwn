/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Vouchers System

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

stock ShowVouchers(playerid, targetid)
{
	if(IsPlayerConnected(targetid))
	{
		new szDialog[1024], szTitle[MAX_PLAYER_NAME+9];
		SetPVarInt(playerid, "WhoIsThis", targetid);
		
		format(szTitle, sizeof(szTitle), "Voucher %s", GetPlayerNameEx(targetid));
		format(szDialog, sizeof(szDialog), "Car Voucher:\t\t\t{18F0F0}%d\nSilver VIP Voucher:\t\t{18F0F0}%d\nGold VIP Voucher:\t\t{18F0F0}%d\nPVIP Voucher 1 thang:\t{18F0F0}%d\nRestricted Car Voucher:\t{18F0F0}%d\nGift Reset Voucher:\t\t{18F0F0}%d\n" \
		"Priority Advert Voucher:\t{18F0F0}%d\nSVIP Voucher 7 ngay: \t{18F0F0}%d\nGVIP Voucher 7 ngay:\t{18F0F0}%d\n",
		PlayerInfo[targetid][pVehVoucher], PlayerInfo[targetid][pSVIPVoucher], PlayerInfo[targetid][pGVIPVoucher], PlayerInfo[targetid][pPVIPVoucher], PlayerInfo[targetid][pCarVoucher], PlayerInfo[targetid][pGiftVoucher], PlayerInfo[targetid][pAdvertVoucher], PlayerInfo[targetid][pSVIPExVoucher], PlayerInfo[targetid][pGVIPExVoucher]);
		ShowPlayerDialogEx(playerid, DIALOG_VOUCHER, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Dong");
	}
	return 1;
}	

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	szMiscArray[0] = 0;
	switch(dialogid)
	{
		case DIALOG_VOUCHER:
		{
			if(response)
			{
				new playeridd = GetPVarInt(playerid, "WhoIsThis");
				switch(listitem)
				{

					case 0: // Car Voucher
					{
						if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
						{
							SetPVarInt(playerid, "voucherdialog", 1);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
						}
						else if(PlayerInfo[playeridd][pVehVoucher] > 0 && (playerid == playeridd))
						{
							SetPVarInt(playerid, "voucherdialog", 1);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHER2, DIALOG_STYLE_MSGBOX, "He thong Voucher", "Ban muon su dung Car Voucher nay khong?", "Co", "Khong");
						}
						else if(PlayerInfo[playeridd][pVehVoucher] < 1)
						{
							if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
							{
								SetPVarInt(playerid, "voucherdialog", 1);
								return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
							}
							else 
							{
								new szDialog[128];
								format(szDialog, sizeof(szDialog), "%s khong co Car Voucher.", GetPlayerNameEx(GetPVarInt(playerid, "WhoIsThis")));
								ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
								DeletePVar(playerid, "WhoIsThis");
							}	
						}	
					}
					case 1: // SVIP Voucher
					{
						if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
						{
							SetPVarInt(playerid, "voucherdialog", 2);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
						}
						else if(PlayerInfo[playeridd][pSVIPVoucher] > 0 && (playerid == playeridd))
						{
							SetPVarInt(playerid, "voucherdialog", 2);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHER2, DIALOG_STYLE_MSGBOX, "He thong Voucher", "Ban muon su dung voucher Silver VIP nay khong?", "Co", "Khong");
						}
						else if(PlayerInfo[playeridd][pSVIPVoucher] < 1)
						{
							if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
							{
								SetPVarInt(playerid, "voucherdialog", 2);
								return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
							}
							else 
							{
								new szDialog[128];
								format(szDialog, sizeof(szDialog), "%s khong co voucher Silver VIP.", GetPlayerNameEx(GetPVarInt(playerid, "WhoIsThis")));
								ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
								DeletePVar(playerid, "WhoIsThis");
							}	
						}	
					}
					case 2: // GVIP Voucher
					{
						if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1) 
						{
							SetPVarInt(playerid, "voucherdialog", 3);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
						}
						else if(PlayerInfo[playeridd][pGVIPVoucher] > 0 && (playerid == playeridd))
						{
							SetPVarInt(playerid, "voucherdialog", 3);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHER2, DIALOG_STYLE_MSGBOX, "He thong Voucher", "Ban muon su dung voucher Gold VIP nay khong?", "Co", "Khong");
						}
						else if(PlayerInfo[playeridd][pGVIPVoucher] < 1)
						{
							if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
							{
								SetPVarInt(playerid, "voucherdialog", 3);
								return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
							}
							else 
							{
								new szDialog[128];
								format(szDialog, sizeof(szDialog), "%s khong co voucher Gold VIP.", GetPlayerNameEx(playeridd));
								ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
								DeletePVar(playerid, "WhoIsThis");
							}	
						}	
					}
					case 3: // PVIP Voucher
					{
						if(playerid != playeridd) return 1;
						if(PlayerInfo[playeridd][pPVIPVoucher] < 1) 
						{
							new szDialog[128];
							format(szDialog, sizeof(szDialog), "%s khong co PVIP Voucher 1 thang.", GetPlayerNameEx(playeridd));
							DeletePVar(playerid, "WhoIsThis");
							return ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
						}
						
						if(PlayerInfo[playerid][pDonateRank] >= 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da co Platinum VIP+, co the ban voucher bang /sellvoucher."), DeletePVar(playerid, "WhoIsThis");
						
						ShowPlayerDialogEx(playerid, DIALOG_PVIPVOUCHER, DIALOG_STYLE_MSGBOX, "PVIP Voucher 1 thang", "Ban se nhan Platinum VIP khi dung voucher nay.", "Xac nhan", "Huy");	
					}
					case 4: // Restricted Car Voucher
					{
						if(playerid != playeridd) return 1;
						
						if(ShopClosed == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");
						
						if(PlayerInfo[playeridd][pCarVoucher] < 1) 
						{
							new szDialog[128];
							format(szDialog, sizeof(szDialog), "%s khong co Restricted Car Voucher.", GetPlayerNameEx(playeridd));
							DeletePVar(playerid, "WhoIsThis");
							return ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
						}
						if(!IsPlayerInDynamicArea(playerid, NGGShop) && GetPlayerVirtualWorld(playerid) != 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai den shop NGG de doi voucher nay.");
						ShowModelSelectionMenu(playerid, CarList3, "Car Shop");
					}
					case 5: // Gift Reset Voucher
					{
						if((PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pHR] >= 1) && PlayerInfo[playerid][pTogReports] == 0)
						{
							SetPVarInt(playerid, "voucherdialog", 4);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
						}
						else if(PlayerInfo[playeridd][pGiftVoucher] > 0 && (playerid == playeridd))
						{
							SetPVarInt(playerid, "voucherdialog", 4);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHER2, DIALOG_STYLE_MSGBOX, "He thong Voucher", "Ban muon su dung Gift Reset Voucher nay khong?", "Co", "Khong");
						}
						else if(PlayerInfo[playeridd][pGiftVoucher] < 1)
						{
							if((PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pHR] >= 1) && PlayerInfo[playerid][pTogReports] == 0)
							{
								SetPVarInt(playerid, "voucherdialog", 4);
								return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
							}
							else 
							{
								new szDialog[128];
								format(szDialog, sizeof(szDialog), "%s khong co Gift Reset Voucher.", GetPlayerNameEx(playeridd));
								ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
								DeletePVar(playerid, "WhoIsThis");
							}	
						}	
					}
					case 6: // Priority Advertisement Voucher
					{
						if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
						{
							SetPVarInt(playerid, "voucherdialog", 5);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
						}
						else if(PlayerInfo[playeridd][pAdvertVoucher] > 0 && (playerid == playeridd))
						{
							return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung voucher o day. Menu quang cao se hien hop thoai de ban dung voucher nay.");
						}
						else if(PlayerInfo[playeridd][pAdvertVoucher] < 1)
						{
							if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
							{
								SetPVarInt(playerid, "voucherdialog", 5);
								return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
							}
							else 
							{
								new szDialog[128];
								format(szDialog, sizeof(szDialog), "%s khong co Priority Advertisement Voucher.", GetPlayerNameEx(playeridd));
								ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
								DeletePVar(playerid, "WhoIsThis");
							}	
						}	
					}
					case 7: // 7 Days Silver VIP
					{
						if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
						{
							SetPVarInt(playerid, "voucherdialog", 6);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
						}
						else if(PlayerInfo[playeridd][pSVIPExVoucher] > 0 && (playerid == playeridd))
						{
							SetPVarInt(playerid, "voucherdialog", 5);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHER2, DIALOG_STYLE_MSGBOX, "He thong Voucher", "Ban muon su dung voucher Silver VIP 7 ngay khong?", "Co", "Khong");
						}
						else if(PlayerInfo[playeridd][pSVIPExVoucher] < 1)
						{
							if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
							{
								SetPVarInt(playerid, "voucherdialog", 6);
								return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
							}
							else 
							{
								new szDialog[128];
								format(szDialog, sizeof(szDialog), "%s khong co voucher Silver VIP 7 ngay.", GetPlayerNameEx(playeridd));
								ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
								DeletePVar(playerid, "WhoIsThis");
							}	
						}	
					}
					case 8: // 7 Days Gold VIP
					{
						if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
						{
							SetPVarInt(playerid, "voucherdialog", 7);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
						}
						else if(PlayerInfo[playeridd][pGVIPExVoucher] > 0 && (playerid == playeridd))
						{
							SetPVarInt(playerid, "voucherdialog", 6);
							return ShowPlayerDialogEx(playerid, DIALOG_VOUCHER2, DIALOG_STYLE_MSGBOX, "He thong Voucher", "Ban muon su dung voucher Gold VIP 7 ngay khong?", "Co", "Khong");
						}
						else if(PlayerInfo[playeridd][pGVIPExVoucher] < 1)
						{
							if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[playerid][pTogReports] == 0 || PlayerInfo[playerid][pTogReports] == 0 && PlayerInfo[playerid][pASM] >= 1)
							{
								SetPVarInt(playerid, "voucherdialog", 7);
								return ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
							}
							else 
							{
								new szDialog[128];
								format(szDialog, sizeof(szDialog), "%s khong co voucher Gold VIP 7 ngay.", GetPlayerNameEx(playeridd));
								ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "He thong Voucher", szDialog, "Dong", "");
								DeletePVar(playerid, "WhoIsThis");
							}	
						}	
					}
				}
			} 
		}		
		case DIALOG_VOUCHERADMIN:
		{
			if(response)
			{
				if(!isnull(inputtext))
				{
					if(IsNumericString(inputtext))
					{
						if(!IsPlayerConnected(GetPVarInt(playerid, "WhoIsThis"))) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi da ngat ket noi khoi may chu.");
						if(strval(inputtext) < 1) return DeletePVar(playerid, "voucherdialog"), DeletePVar(playerid, "WhoIsThis"), SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tang it hon 1 voucher.");
						if(GetPVarInt(playerid,	"voucherdialog") == 1) // Car Voucher
						{
							new targetid = GetPVarInt(playerid, "WhoIsThis"), 
								amount = strval(inputtext),
								szString[128];
								
							PlayerInfo[targetid][pVehVoucher] += amount;
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tang %s %d Car Voucher.", GetPlayerNameEx(targetid), amount);
							SendClientMessageEx(targetid, COLOR_CYAN, "Ban nhan duoc %d Car Voucher tu %s.", amount, GetPlayerNameEx(playerid));
							format(szString, sizeof(szString), "%s has given %s(%d) %d car voucher(s).", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), amount);
							Log("logs/vouchers.log", szString);
						}
						if(GetPVarInt(playerid,	"voucherdialog") == 2) // SVIP Voucher
						{
							new targetid = GetPVarInt(playerid, "WhoIsThis"), 
								amount = strval(inputtext),
								szString[128];
								
							PlayerInfo[targetid][pSVIPVoucher] += amount;
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tang %s %d voucher Silver VIP.", GetPlayerNameEx(targetid), amount);
							SendClientMessageEx(targetid, COLOR_CYAN, "Ban nhan duoc %d voucher Silver VIP tu %s.", amount, GetPlayerNameEx(playerid));
							format(szString, sizeof(szString), "%s has given %s(%d) %d Silver VIP voucher(s).", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), amount);
							Log("logs/vouchers.log", szString);
						}
						if(GetPVarInt(playerid,	"voucherdialog") == 3) // GVIP Voucher
						{
							new targetid = GetPVarInt(playerid, "WhoIsThis"), 
								amount = strval(inputtext),
								szString[128];
								
							PlayerInfo[targetid][pGVIPVoucher] += amount;
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tang %s %d voucher Gold VIP.", GetPlayerNameEx(targetid), amount);
							SendClientMessageEx(targetid, COLOR_CYAN, "Ban nhan duoc %d voucher Gold VIP tu %s.", amount, GetPlayerNameEx(playerid));
							format(szString, sizeof(szString), "%s has given %s(%d) %d Gold VIP voucher(s).", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), amount);
							Log("logs/vouchers.log", szString);
						}
						if(GetPVarInt(playerid, "voucherdialog") == 4) // Gift Reset Voucher
						{
							new targetid = GetPVarInt(playerid, "WhoIsThis"),
								amount = strval(inputtext),
								szString[128];
							PlayerInfo[targetid][pGiftVoucher] += amount;
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tang %s %d Gift Reset Voucher.", GetPlayerNameEx(targetid), amount);
							SendClientMessageEx(targetid, COLOR_CYAN, "Ban nhan duoc %d Gift Reset Voucher tu %s.", amount, GetPlayerNameEx(playerid));
							format(szString, sizeof(szString), "[Admin] %s(IP:%s) has given %s(%d)(IP:%s) %d free gift reset voucher(s).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), GetPlayerIpEx(targetid), amount);
							Log("logs/adminrewards.log", szString);	
						}
						if(GetPVarInt(playerid, "voucherdialog") == 5) // Priority Advertisement Voucher
						{
							new targetid = GetPVarInt(playerid, "WhoIsThis"),
								amount = strval(inputtext),
								szString[128];
							PlayerInfo[targetid][pAdvertVoucher] += amount;
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tang %s %d Priority Advertisement Voucher.", GetPlayerNameEx(targetid), amount);
							SendClientMessageEx(targetid, COLOR_CYAN, "Ban nhan duoc %d Priority Advertisement Voucher tu %s.", amount, GetPlayerNameEx(playerid));
							format(szString, sizeof(szString), "[Admin] %s(IP:%s) has given %s(%d)(IP:%s) %d free Priority Advertisement voucher(s).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), GetPlayerIpEx(targetid), amount);
							Log("logs/vouchers.log", szString);	
						}
						if(GetPVarInt(playerid, "voucherdialog") == 6) // 7 Days Silver VIP Voucher
						{
							new targetid = GetPVarInt(playerid, "WhoIsThis"),
								amount = strval(inputtext),
								szString[128];
							PlayerInfo[targetid][pSVIPExVoucher] += amount;
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tang %s %d voucher Silver VIP 7 ngay.", GetPlayerNameEx(targetid), amount);
							SendClientMessageEx(targetid, COLOR_CYAN, "Ban nhan duoc %d voucher Silver VIP 7 ngay tu %s.", amount, GetPlayerNameEx(playerid));
							format(szString, sizeof(szString), "[Admin] %s(IP:%s) has given %s(%d)(IP:%s) %d free 7 Days Silver VIP voucher(s).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), GetPlayerIpEx(targetid), amount);
							Log("logs/vouchers.log", szString);	
						}
						if(GetPVarInt(playerid, "voucherdialog") == 7) // 7 Days Gold VIP Voucher
						{
							new targetid = GetPVarInt(playerid, "WhoIsThis"),
								amount = strval(inputtext),
								szString[128];
							PlayerInfo[targetid][pGVIPExVoucher] += amount;
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tang %s %d voucher Gold VIP 7 ngay.", GetPlayerNameEx(targetid), amount);
							SendClientMessageEx(targetid, COLOR_CYAN, "Ban nhan duoc %d voucher Gold VIP 7 ngay tu %s.", amount, GetPlayerNameEx(playerid));
							format(szString, sizeof(szString), "[Admin] %s(IP:%s) has given %s(%d)(IP:%s) %d free 7 Days Gold VIP voucher(s).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(targetid), GetPlayerSQLId(targetid), GetPlayerIpEx(targetid), amount);
							Log("logs/vouchers.log", szString);	
						}
					}
					else ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher - {FF0000}Khong phai so", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");
				}	
				else ShowPlayerDialogEx(playerid, DIALOG_VOUCHERADMIN, DIALOG_STYLE_INPUT, "He thong Voucher", "Nhap so luong muon tang cho nguoi choi nay.", "Nhap", "Huy");	
			}
			DeletePVar(playerid, "voucherdialog");
			DeletePVar(playerid, "WhoIsThis");
		}										
		case DIALOG_VOUCHER2:
		{
			if(response) // Clicked "Use"
			{	
				if(PlayerInfo[playerid][pJailTime] > 0)
				{
					DeletePVar(playerid, "voucherdialog");
					DeletePVar(playerid, "WhoIsThis");
					return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay khi dang bi giam.");
				}
				if(GetPVarInt(playerid, "voucherdialog") == 1) // Car Voucher
				{
					if(GetPlayerInterior(playerid) != 0 || !IsPlayerInDynamicArea(playerid, NGGShop)) 
					{
						DeletePVar(playerid, "voucherdialog");
						DeletePVar(playerid, "WhoIsThis");
						if(GetPlayerInterior(playerid) != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung khi dang o trong noi that.");
						if(!IsPlayerInDynamicArea(playerid, NGGShop) && GetPlayerVirtualWorld(playerid) != 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai den shop NGG de doi voucher nay.");
					}
					else
					{
						return ShowModelSelectionMenu(playerid, CarList2, "Chon Car Voucher");
					}
				}
				if(GetPVarInt(playerid, "voucherdialog") == 2) // SVIP Voucher
				{
					if(PlayerInfo[playerid][pDonateRank] >= 2)
					{
						DeletePVar(playerid, "voucherdialog");
						DeletePVar(playerid, "WhoIsThis");
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da co VIP Silver+");
					}
					if(PlayerInfo[playerid][pSVIPVoucher] <= 0) return DeletePVar(playerid, "voucherdialog"), DeletePVar(playerid, "WhoIsThis"), SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co SVIP Voucher.");
					PlayerInfo[playerid][pSVIPVoucher]--;
					PlayerInfo[playerid][pDonateRank] = 2;
					PlayerInfo[playerid][pTempVIP] = 0;
					PlayerInfo[playerid][pBuddyInvited] = 0;
					PlayerInfo[playerid][pVIPSellable] = 0;
					PlayerInfo[playerid][pVIPExpire] = gettime()+2592000*1;
					if(PlayerInfo[playerid][pVIPM] == 0)
					{
						PlayerInfo[playerid][pVIPM] = VIPM;
						VIPM++;
					}
					LoadPlayerDisabledVehicles(playerid);
					new playerip[32];
					GetPlayerIp(playerid, playerip, sizeof(playerip));
					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (He thong Voucher) da dat VIP cua %s thanh Silver (2).", GetPlayerNameEx(playerid));
					ABroadCast(COLOR_LIGHTRED, szMiscArray, 4);
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung mot voucher Silver VIP, ban con %d voucher Silver VIP.", PlayerInfo[playerid][pSVIPVoucher]);
					SendClientMessageEx(playerid, COLOR_GRAD2, "** Luu y: Silver VIP se het han sau 30 ngay.");

					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (Voucher System) has set %s's(%d) (IP:%s) VIP level to Silver (2) (Voucher Left: %d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerip, PlayerInfo[playerid][pSVIPVoucher]);
					Log("logs/vouchers.log", szMiscArray);
					OnPlayerStatsUpdate(playerid);
				}
				if(GetPVarInt(playerid, "voucherdialog") == 3) // GVIP Voucher - Not renewable
				{
					if(PlayerInfo[playerid][pDonateRank] >= 3)
					{
						DeletePVar(playerid, "voucherdialog");
						DeletePVar(playerid, "WhoIsThis");
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da co VIP Gold+");
					}
					if(PlayerInfo[playerid][pGVIPVoucher] <= 0) return DeletePVar(playerid, "voucherdialog"), DeletePVar(playerid, "WhoIsThis"), SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co GVIP Voucher.");
					PlayerInfo[playerid][pGVIPVoucher]--;
					PlayerInfo[playerid][pDonateRank] = 3;
					PlayerInfo[playerid][pTempVIP] = 0;
					PlayerInfo[playerid][pBuddyInvited] = 0;
					PlayerInfo[playerid][pVIPSellable] = 0;
					PlayerInfo[playerid][pVIPExpire] = gettime()+2592000*1;
					if(PlayerInfo[playerid][pVIPM] == 0)
					{
						PlayerInfo[playerid][pVIPM] = VIPM;
						VIPM++;
					}
					LoadPlayerDisabledVehicles(playerid);
					new playerip[32];
					GetPlayerIp(playerid, playerip, sizeof(playerip));
					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (He thong Voucher) da dat VIP cua %s thanh Gold (3).", GetPlayerNameEx(playerid));
					ABroadCast(COLOR_LIGHTRED, szMiscArray, 4);
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung mot voucher Gold VIP, ban con %d voucher Gold VIP.", PlayerInfo[playerid][pGVIPVoucher]);
					SendClientMessageEx(playerid, COLOR_GRAD2, "** Luu y: Gold VIP se het han sau 30 ngay.");

					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (Voucher System) has set %s's(%d) (IP:%s) VIP level to Gold (3) (Voucher Left: %d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerip, PlayerInfo[playerid][pGVIPVoucher]);
					Log("logs/vouchers.log", szMiscArray);
					OnPlayerStatsUpdate(playerid);
				}
				if(GetPVarInt(playerid, "voucherdialog") == 4) // Gift Reset Voucher
				{
					if(PlayerInfo[playerid][pGiftTime] <= 0)
					{
						DeletePVar(playerid, "voucherdialog");
						DeletePVar(playerid, "WhoIsThis");
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da co the nhan qua tu hop qua hoac ket sat.");
					}
					if(PlayerInfo[playerid][pGiftVoucher] <= 0) return DeletePVar(playerid, "voucherdialog"), DeletePVar(playerid, "WhoIsThis"), SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Gift Reset Voucher.");
					PlayerInfo[playerid][pGiftVoucher]--;
					PlayerInfo[playerid][pGiftTime] = 0;
					new playerip[32];
					GetPlayerIp(playerid, playerip, sizeof(playerip));
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung mot Gift Reset Voucher, ban con %d Gift Reset Voucher.", PlayerInfo[playerid][pGiftVoucher]);
					SendClientMessageEx(playerid, COLOR_GRAD2, "** Luu y: Ban da co the nhan qua tiep.");
					format(szMiscArray, sizeof(szMiscArray), "%s(%d)(IP:%s) has used a Gift Reset Voucher. (Vouchers Left: %d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerip, PlayerInfo[playerid][pGiftVoucher]);
					Log("logs/vouchers.log", szMiscArray);	
					OnPlayerStatsUpdate(playerid);
				}
				if(GetPVarInt(playerid, "voucherdialog") == 5) // 7 Days Silver VIP
				{
					if(PlayerInfo[playerid][pDonateRank] >= 2)
					{
						DeletePVar(playerid, "voucherdialog");
						DeletePVar(playerid, "WhoIsThis");
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da co VIP Silver+");
					}
					if(PlayerInfo[playerid][pSVIPExVoucher] <= 0) return DeletePVar(playerid, "voucherdialog"), DeletePVar(playerid, "WhoIsThis"), SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co voucher Silver VIP 7 ngay.");
					PlayerInfo[playerid][pSVIPExVoucher]--;
					PlayerInfo[playerid][pDonateRank] = 2;
					PlayerInfo[playerid][pTempVIP] = 0;
					PlayerInfo[playerid][pBuddyInvited] = 0;
					PlayerInfo[playerid][pVIPSellable] = 1;
					PlayerInfo[playerid][pVIPExpire] = gettime()+604800*1;
					if(PlayerInfo[playerid][pVIPM] == 0)
					{
						PlayerInfo[playerid][pVIPM] = VIPM;
						VIPM++;
					}
					LoadPlayerDisabledVehicles(playerid);
					new playerip[32];
					GetPlayerIp(playerid, playerip, sizeof(playerip));
					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (He thong Voucher) da dat VIP cua %s thanh Silver (7 ngay)(3).", GetPlayerNameEx(playerid));
					ABroadCast(COLOR_LIGHTRED, szMiscArray, 4);
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung mot voucher Silver VIP 7 ngay, ban con %d voucher Silver VIP 7 ngay.", PlayerInfo[playerid][pSVIPExVoucher]);
					SendClientMessageEx(playerid, COLOR_GRAD2, "** Luu y: Silver VIP se het han sau 7 ngay.");

					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (Voucher System) has set %s's(%d) (IP:%s) VIP level to Silver (7 Days)(3) (Voucher Left: %d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerip, PlayerInfo[playerid][pSVIPExVoucher]);
					Log("logs/vouchers.log", szMiscArray);
					OnPlayerStatsUpdate(playerid);
				}
				if(GetPVarInt(playerid, "voucherdialog") == 6) // 7 Days Gold VIP
				{
					if(PlayerInfo[playerid][pDonateRank] >= 3)
					{
						DeletePVar(playerid, "voucherdialog");
						DeletePVar(playerid, "WhoIsThis");
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da co VIP Gold+");
					}
					if(PlayerInfo[playerid][pGVIPExVoucher] <= 0) return DeletePVar(playerid, "voucherdialog"), DeletePVar(playerid, "WhoIsThis"), SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co voucher Gold VIP 7 ngay.");
					PlayerInfo[playerid][pGVIPExVoucher]--;
					PlayerInfo[playerid][pDonateRank] = 3;
					PlayerInfo[playerid][pTempVIP] = 0;
					PlayerInfo[playerid][pBuddyInvited] = 0;
					PlayerInfo[playerid][pVIPSellable] = 1;
					PlayerInfo[playerid][pVIPExpire] = gettime()+604800*1;
					if(PlayerInfo[playerid][pVIPM] == 0)
					{
						PlayerInfo[playerid][pVIPM] = VIPM;
						VIPM++;
					}
					LoadPlayerDisabledVehicles(playerid);
					new playerip[32];
					GetPlayerIp(playerid, playerip, sizeof(playerip));
					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (He thong Voucher) da dat VIP cua %s thanh Gold (7 ngay)(3).", GetPlayerNameEx(playerid));
					ABroadCast(COLOR_LIGHTRED, szMiscArray, 4);
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung mot voucher Gold VIP 7 ngay, ban con %d voucher Gold VIP 7 ngay.", PlayerInfo[playerid][pGVIPExVoucher]);
					SendClientMessageEx(playerid, COLOR_GRAD2, "** Luu y: Gold VIP se het han sau 7 ngay.");

					format(szMiscArray, sizeof(szMiscArray), "AdmCmd: Server (Voucher System) has set %s's(%d) (IP:%s) VIP level to Gold (7 Days)(3) (Voucher Left: %d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerip, PlayerInfo[playerid][pGVIPExVoucher]);
					Log("logs/vouchers.log", szMiscArray);
					OnPlayerStatsUpdate(playerid);
				}
			}
			DeletePVar(playerid, "voucherdialog");
			DeletePVar(playerid, "WhoIsThis");
		}
	}
	return 0;
}

// Start of the voucher commands
CMD:myvouchers(playerid, params[])
{
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay khi dang bi giam.");
	
	ShowVouchers(playerid, playerid);
	return 1;
}

CMD:checkvouchers(playerid, params[])
{
	new targetid;
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	if(sscanf(params, "u", targetid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /checkvouchers [player]");
	if(!IsPlayerConnected(targetid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	
	ShowVouchers(playerid, targetid);
	return 1;
}		

CMD:sellvoucher(playerid, params[])
{
	new choice[32], amount, price, buyer;
    if(sscanf(params, "s[32]ddu", choice, amount, price, buyer))
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sellvoucher [name] [amount] [price] [buyer]");
		SendClientMessageEx(playerid, COLOR_GREY, "Ten hop le: CarVoucher, SilverVIP, GoldVIP, PVIP, RestrictedCar, Advert, 7DaySVIP, 7DayGVIP");
		return 1;
	}
	
	new Float: bPos[3];
	GetPlayerPos(buyer, bPos[0], bPos[1], bPos[2]);
	if(GetPlayerVirtualWorld(buyer) != GetPlayerVirtualWorld(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o gan nguoi choi nay.");
	if(price < 1 || price > 99999999) return SendClientMessageEx(playerid, COLOR_GRAD1, "Gia phai lon hon $0 hoac nho hon $99,999,999.");
	if(amount < 1) return SendClientMessageEx(playerid, COLOR_GREY, "So luong khong hop le.");
	if(!IsPlayerConnected(buyer)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi chua ket noi.");
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, bPos[0], bPos[1], bPos[2])) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o gan nguoi choi nay.");
	if(GetPVarInt(playerid, "Injured") != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(GetPVarInt(buyer, "Injured") != 0 || PlayerCuffed[buyer] != 0 || PlayerInfo[buyer][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the moi nguoi dang bi giam hoac bi thuong mua voucher.");
	if(GetPVarType(buyer, "buyingVoucher")) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi dang mua voucher khac, hay thu lai sau.");
	
	if(strcmp(choice, "carvoucher", true) == 0) 
	{
		if(amount > PlayerInfo[playerid][pVehVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");
		
		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 1);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d Car Voucher gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d Car Voucher gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
		SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else if(strcmp(choice, "silvervip", true) == 0) 
	{
		if(amount > PlayerInfo[playerid][pSVIPVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");
		
		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 2);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d voucher Silver VIP gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d voucher Silver VIP gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
		SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else if(strcmp(choice, "goldvip", true) == 0) 
	{
		if(amount > PlayerInfo[playerid][pGVIPVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");
		
		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 3);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d voucher Gold VIP gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d voucher Gold VIP gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
		SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else if(strcmp(choice, "pvip", true) == 0)
	{
		if(amount > PlayerInfo[playerid][pPVIPVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");

		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 4);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d PVIP Voucher 1 thang gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d PVIP Voucher 1 thang gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
	 	SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else if(strcmp(choice, "restrictedcar", true) == 0)
	{
		if(amount > PlayerInfo[playerid][pCarVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");

		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 5);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d Restricted Car Voucher gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d Restricted Car Voucher gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
	 	SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else if(strcmp(choice, "advert", true) == 0)
	{
		if(amount > PlayerInfo[playerid][pAdvertVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");

		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 6);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d Priority Advertisement Voucher gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d Priority Advertisement Voucher gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
	 	SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else if(strcmp(choice, "7daysvip", true) == 0)
	{
		if(amount > PlayerInfo[playerid][pSVIPExVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");

		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 7);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d voucher Silver VIP 7 ngay gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d voucher Silver VIP 7 ngay gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
	 	SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else if(strcmp(choice, "7daygvip", true) == 0)
	{
		if(amount > PlayerInfo[playerid][pGVIPExVoucher]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co du voucher.");

		SetPVarInt(buyer, "priceVoucher", price);
		SetPVarInt(buyer, "amountVoucher", amount);
		SetPVarInt(buyer, "buyingVoucher", 8);
		SetPVarInt(buyer, "sellerVoucher", playerid);
		SetPVarInt(buyer, "VoucherOfferSession", g_arrQueryHandle[playerid]);
		SetPVarInt(playerid, "buyerVoucher", buyer);
		SendClientMessageEx(buyer, COLOR_LIGHTBLUE, "%s de nghi ban %d voucher Gold VIP 7 ngay gia $%s - Dung /accept voucher hoac /denyvoucher.", GetPlayerNameEx(playerid), amount, number_format(price));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban de nghi ban cho %s %d voucher Gold VIP 7 ngay gia $%s, hay cho ho chap nhan hoac tu choi.", GetPlayerNameEx(buyer), amount, number_format(price));
	 	SetPVarInt(buyer, "SQLID_Voucher", GetPlayerSQLId(playerid));
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Lua chon khong hop le.");
	return 1;
}	

CMD:denyvoucher(playerid, params[])
{
	if(GetPVarType(playerid, "buyingVoucher"))
	{
		SendClientMessageEx(GetPVarInt(playerid, "sellerVoucher"), COLOR_LIGHTBLUE, "* %s tu choi mua voucher cua ban.", GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban tu choi mua voucher cua %s.", GetPlayerNameEx(GetPVarInt(playerid, "sellerVoucher")));
		DeletePVar(playerid, "priceVoucher");
		DeletePVar(playerid, "amountVoucher");
		DeletePVar(playerid, "buyingVoucher");
		DeletePVar(playerid, "sellerVoucher");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong co ai de nghi ban voucher cho ban.");
	return 1;
}		

CMD:voucherhelp(playerid, params[])
{
	SetPVarInt(playerid, "HelpResultCat0", 10);
	Help_ListCat(playerid, DIALOG_HELPCATOTHER1);
	return 1;
}

CMD:ovoucherhelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_GRAD1, "** Lenh nguoi choi: /myvouchers /denyvoucher /accept voucher");
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "** Lenh Admin: /checkvouchers");
	}
	return 1;
}
//end of the voucher commands