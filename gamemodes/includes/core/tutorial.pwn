/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Tutorial System
								Winterfield

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

new TutorialTime[MAX_PLAYERS];

AdvanceTutorial(playerid) 
{
	switch(PlayerInfo[playerid][pTut])
	{
		case -1:
		{
			TogglePlayerSpectating(playerid, false);
			SetPlayerPos(playerid, 1715.0687, -1899.5597, 13.5665);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetHealth(playerid, 100);
			ClearChatbox(playerid);
		}
		case 0:
		{
			IsSpawned[playerid] = 1;
			ClearChatbox(playerid);
			TogglePlayerSpectating(playerid, 1);

			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, playerid + 1);

			InterpolateCameraPos(playerid, 1333.5521, -1388.1493, 67.2808, 1387.4829, -923.4698, 90.6020, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 1333.5950, -1387.1521, 67.3258, 1387.7191, -922.5004, 90.4920, 15000, CAMERA_MOVE);

			KillTimer(TutorialTime[playerid]);
			SetPVarInt(playerid, "pTutorialTimer", 15);
			TutorialTime[playerid] = SetTimerEx("TutorialTimer", 1000, true, "i", playerid);
			ShowTutorialDialog(playerid, 0);
		}
		case 1:
		{
			InterpolateCameraPos(playerid, 725.9147, -1610.8770, 3.0359, 734.8999, -1962.6320, -6.3299, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 725.9500, -1611.8734, 3.0057, 734.9311, -1963.6292, -6.5201, 15000, CAMERA_MOVE);

			KillTimer(TutorialTime[playerid]);
			SetPVarInt(playerid, "pTutorialTimer", 15);
			TutorialTime[playerid] = SetTimerEx("TutorialTimer", 1000, true, "i", playerid);
			ShowTutorialDialog(playerid, 1);
		}
		case 2:
		{
			InterpolateCameraPos(playerid, 1104.7491, -1401.8911, 14.6202, 1145.8008, -1471.2203, 27.1695, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 1105.5040, -1402.5443, 14.5450, 1145.2341, -1470.3988, 26.7043, 15000, CAMERA_MOVE);

			KillTimer(TutorialTime[playerid]);
			SetPVarInt(playerid, "pTutorialTimer", 15);
			TutorialTime[playerid] = SetTimerEx("TutorialTimer", 1000, true, "i", playerid);
			ShowTutorialDialog(playerid, 2);
		}
		case 3:
		{
			InterpolateCameraPos(playerid, 1517.0358, -1616.2576, 17.8788, 1520.4496, -1715.3738, 18.1261, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 1517.4991, -1617.1411, 17.8737, 1521.0973, -1714.6147, 18.0459, 15000, CAMERA_MOVE);

			KillTimer(TutorialTime[playerid]);
			SetPVarInt(playerid, "pTutorialTimer", 15);
			TutorialTime[playerid] = SetTimerEx("TutorialTimer", 1000, true, "i", playerid);
			ShowTutorialDialog(playerid, 3);
		}
		case 4:
		{
			InterpolateCameraPos(playerid, 938.9750, -1324.3108, 14.0205, 1039.5808, -1324.3224, 14.4793, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 939.9739, -1324.3015, 14.0254, 1040.5797, -1324.3134, 14.4891, 15000, CAMERA_MOVE);

			KillTimer(TutorialTime[playerid]);
			SetPVarInt(playerid, "pTutorialTimer", 15);
			TutorialTime[playerid] = SetTimerEx("TutorialTimer", 1000, true, "i", playerid);
			ShowTutorialDialog(playerid, 4);
		}
		case 5:
		{
			InterpolateCameraPos(playerid, 366.2238, -1798.2668, 9.5036, 369.1093, -2030.7736, 8.7837, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 366.3326, -1799.2593, 9.5184, 369.2533, -2031.7618, 8.7687, 15000, CAMERA_MOVE);

			ShowTutorialDialog(playerid, 5);
		}
		case 6 .. 10: ShowTutorialDialog(playerid, PlayerInfo[playerid][pTut]);
		case 11:
		{
			InterpolateCameraPos(playerid, 1457.7699, -870.9628, 63.1767, 1525.9520, -805.8469, 72.9416, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 1458.4862, -870.2654, 63.1212, 1526.6012, -805.0862, 72.9162, 15000, CAMERA_MOVE);

			ShowTutorialDialog(playerid, 11);
			SetPlayerInterior(playerid, 0);
		}
		case 12:
		{
			InterpolateCameraPos(playerid, 1569.0149, -1812.5513, 16.1676, 1568.5962, -1889.8837, 13.8242, 15000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 1569.0370, -1813.5509, 16.1273, 1568.5488, -1890.8818, 13.7888, 15000, CAMERA_MOVE);

			ShowTutorialDialog(playerid, 12);
		}
		case 13:
		{
			AdjustActor(playerid, 2);
			CharacterCreation(playerid);

			InterpolateCameraPos(playerid, 237.6108, 1822.9670, 7.8454, 224.6772, 1820.0587, 7.6625, 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, 236.6068, 1822.9495, 7.7454, 223.7760, 1820.5018, 7.6224, 5000, CAMERA_MOVE);
			SetPlayerInterior(playerid, 0);
		}
		case 14: CharacterCreation(playerid);
		case 15:
		{
			if(IsSpawned[playerid] == 0) return 1;
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
			SendClientMessageEx(playerid, COLOR_WHITE, "Muc tieu: Mua xe.");
			SendClientMessageEx(playerid, COLOR_WHITE, "Den checkpoint tren ban do de mua xe.");
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");

			SetPlayerCheckpoint(playerid, 1645.9091,-1897.6914,13.5521, 5.0);

		}
		case 16:
		{
			if(IsSpawned[playerid] == 0) return 1;
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
			SendClientMessageEx(playerid, COLOR_WHITE, "Muc tieu: Rut tien tu ngan hang.");
			SendClientMessageEx(playerid, COLOR_WHITE, "Den checkpoint tren ban do de rut tien.");
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
			SetPlayerCheckpoint(playerid, 1457.0022,-1011.3710,26.8438, 5.0);
		}
		case 17:
		{
			if(IsSpawned[playerid] == 0) return 1;
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
			SendClientMessageEx(playerid, COLOR_WHITE, "Muc tieu: Mua dien thoai.");
			SendClientMessageEx(playerid, COLOR_WHITE, "Den checkpoint tren ban do de mua dien thoai.");
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");

			SetPlayerCheckpoint(playerid, 999.6548,-919.9871,42.3281, 5.0);
		}
		case 18:
		{
			if(IsSpawned[playerid] == 0) return 1;
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
			SendClientMessageEx(playerid, COLOR_WHITE, "Da hoan tat huong dan muc tieu. Chao mung den Next Generation Gaming!");
			SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");

			PlayerInfo[playerid][pTut] = -1;
		}
	}
	return 1;
}

CharacterCreation(playerid)
{
	switch(PlayerInfo[playerid][pTut])
	{
		case 13:
		{
			szMiscArray[0] = 0;
			new genderstring[12];

			switch(PlayerInfo[playerid][pSex])
			{
				case 1: genderstring = "Nam";
				case 2: genderstring = "Nu";
				default: genderstring = "Chua chon";
			}

			format(szMiscArray, sizeof(szMiscArray), "Ten:\t%s\n\
				Gioi tinh:\t%s\n\
				Ngay sinh\t%s\n\
				Quoc gia\t%s\n\
				Giong noi:\t%s\n\
				Skin ID:\t%i\n\
				Hoan tat",
				GetPlayerNameEx(playerid),
				genderstring,
				PlayerInfo[playerid][pBirthDate],
				GetPlayerNation(playerid),
				GetPlayerAccent(playerid),
				PlayerInfo[playerid][pModel]);
			return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_CREATION, DIALOG_STYLE_TABLIST, "NG:RP | Tao nhan vat", szMiscArray, "Chon", "");
		}
		case 14: {

			DestroyActor(GetPVarInt(playerid, "pActor"));
			TogglePlayerSpectating(playerid, false);
			SetPlayerPos(playerid, 1715.0687, -1899.5597, 13.5665);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetHealth(playerid, 100);
			ClearChatbox(playerid);

			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - Chao mung", "Ban muon may chu giao muc tieu de huong dan kham pha khong?", "Co!", "Khong, cam on.");
		}
	}
	return 1;
}

ShowTutorialDialog(playerid, stage)
{
	new countstring[10];

	if(GetPVarInt(playerid, "pTutorialTimer") == 0) { format(countstring, 10, "Tiep tuc"); }
	else valstr(countstring, GetPVarInt(playerid, "pTutorialTimer"));

	switch(stage)
	{
		case 0:
		{
			if(betaserver == 0) {
				szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
				strcat(szMiscArray, "{7091B8}Chao mung den Next Generation Gaming!{FFFFFF}\n\n");
				strcat(szMiscArray, "Chung toi la cong dong noi tieng Anh. NG:RP tap trung vao Roleplay, ban dong vai mot nhan vat va hanh dong\n");
				strcat(szMiscArray, "nhu ngoai doi thuc. Nhan vat se hoc hoi thong tin moi va phat trien trong qua trinh choi.\n\n");
				strcat(szMiscArray, "Cong dong hinh thanh tu 2010 va da phat trien dang ke.\n\n");
				strcat(szMiscArray, "{FF0000}Dich vu lien quan NG:RP{FFFFFF}:\n");
				strcat(szMiscArray, "\t{F69500}Website{FFFFFF}: ng-gaming.net - Dang ky dien dan va giao luu cung cong dong!\n");
				strcat(szMiscArray, "\t{F69500}User Control Panel{FFFFFF}: cp.ng-gaming.net - Quan ly va bao ve tai khoan cua ban!\n");
				strcat(szMiscArray, "\t{F69500}Shop{FFFFFF}: shop.ng-gaming.net - Mua credits de mua vat pham trong game!\n");
				strcat(szMiscArray, "\t{F69500}TeamSpeak{FFFFFF}: ts.ng-gaming.net - Ket noi va tro chuyen voi cong dong!\n");
				strcat(szMiscArray, "\t{F69500}Chia se anh{FFFFFF}: ngg.up - Chia se anh yeu thich voi ban be chi bang mot nut bam.\n\n");
				strcat(szMiscArray, "Hay doc ky, cuoi huong dan se co cau hoi.");
				strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
				ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - Chao mung", szMiscArray, countstring, "");
			}
			else {
				szMiscArray = "{FFFFFF}___________________________________________________________________________________________\n\n\n";
				strcat(szMiscArray, "{7091B8}Chao mung den Next Generation Gaming Beta Server!{FFFFFF}\n\n");
				strcat(szMiscArray, "Ban khong can xem het huong dan, chi can nhan \"Da hieu\" ben duoi.\n");
				strcat(szMiscArray, "Ban se duoc dua thang den man hinh tao nhan vat.\n\n");
				strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________");
				ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Beta Server - Chao mung", szMiscArray, "Da hieu", "");
			}
		}
		case 1:
		{
			szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
			strcat(szMiscArray, "{F69500}Roleplay{FFFFFF}\n\n");
			strcat(szMiscArray, "De roleplay, hay tao nhan vat co cau chuyen rieng. Ho la ai? Ho den tu\n");
			strcat(szMiscArray, "dau? Vi sao ho o San Andreas? Ban tu quyet dinh!\n\n");
			strcat(szMiscArray, "Truoc tien, hay lam quen cac thuat ngu tai Next Generation Gaming.\n\n");
			strcat(szMiscArray, "\t{FF0000}In Character (IC){FFFFFF}: Moi thu thuoc ve nhan vat, qua chat trong game, radio, dien thoai, v.v.\n");
			strcat(szMiscArray, "\t\tVi du: Nhan vat noi voi nhan vat khac \"Chao, ban ten gi?\". Day la hoi thoai IC.\n\n");
			strcat(szMiscArray, "\t{FF0000}Out Of Character (OOC){FFFFFF}: Loi cua ban, khong phai nhan vat. Moi viec lien quan ca nhan ban nam ngoai nhan vat.\n");
			strcat(szMiscArray, "\tOOC phai dat trong 'OOC Brackets', vi du: (( Day la chat OOC vi co hai dau ngoac )).\n");
			strcat(szMiscArray, "\t\tVi du: Noi voi ban be ve tran bong toi qua, \"(( Ban thay pha bat bong do chu? ))\". Day\n");
			strcat(szMiscArray, "\t\tla loi ngoai nhan vat vi duoc dat trong 'OOC Brackets'.\n\n");
			strcat(szMiscArray, "Hay hoc hai lenh thuong dung de roleplay.\n\n");
			strcat(szMiscArray, "\t{FF0000}/me [action]{FFFFFF} - Thuc hien hanh dong hay loi dien giai, gui thong bao den nguoi choi xung quanh.\n");
			strcat(szMiscArray, "\t\tVi du: /me nhat mot canh cay duoi dat.\n");
			strcat(szMiscArray, "\t{FF0000}/do [action]{FFFFFF} - Mo ta hanh dong, tinh huong hoac hoi thong tin IC ve nhan vat khac.\n");
			strcat(szMiscArray, "\t\tVi du: /do Canh cay mau nau.\n\n");
			strcat(szMiscArray, "Hay doc ky cac dinh nghia, ban se phai tra loi cau hoi.");
			strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - Roleplay", szMiscArray, countstring, "");
		}
		case 2:
		{
			szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
			strcat(szMiscArray, "{F69500}Quy tac{FFFFFF}\n\n");
			strcat(szMiscArray, "Tiep theo la cac quy tac roleplay quan trong de trai nghiem NG:RP tot hon.\n\n");
			strcat(szMiscArray, "\t{FF0000}Metagaming (MG){FFFFFF}: Tron thong tin IC voi OOC hoac nguoc lai.\n");
			strcat(szMiscArray, "\t\tVi du: John_Doe khong biet Jane_Doe nhung bao canh sat toi cua co ay va noi ro ten Jane_Doe.\n");
			strcat(szMiscArray, "\t\tVi du: John_Doe buc minh nen gui bieu tuong mat buon trong chat IC.\n\n");
			strcat(szMiscArray, "\t{FF0000}Powergaming (PG){FFFFFF}: Ep nguoi khac roleplay hoac nhap vai viec bat kha thi.\n");
			strcat(szMiscArray, "\t\tVi du: John_Doe dung /tie voi Jane_Doe ma khong roleplay truoc hay cho co ay thoi gian phan hoi.\n\n");
			strcat(szMiscArray, "\t{FF0000}Deathmatching (DM){FFFFFF}: Tim giet nguoi khac khi khong co ly do roleplay hop ly.\n");
			strcat(szMiscArray, "\t\tVi du: John_Doe den ban Jane_Doe du hai nguoi chua tung gap nhau.\n\n");
			strcat(szMiscArray, "\t{FF0000}Killing On Sight (KoS){FFFFFF}: Tim giet nguoi khac khi chua roleplay du truoc do.\n");
			strcat(szMiscArray, "\t\tVi du: John_Doe ban Jane_Doe vi co ay trom xe minh ma khong roleplay truoc.\n\n");
			strcat(szMiscArray, "\t{FF0000}Revenge Killing (RK){FFFFFF}: Quay lai noi minh chet hoac roleplay voi nguoi gay ra cai chet cua minh.\n");
			strcat(szMiscArray, "\t\tVi du: Jane_Doe giet John_Doe, John_Doe quay lai va roleplay giet Jane_Doe.\n\n");
			strcat(szMiscArray, "Hay doc ky, ban se phai tra loi cau hoi va co the bi phat neu vi pham!");
			strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - Quy tac", szMiscArray, countstring, "");
		}
		case 3:
		{
			szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
			strcat(szMiscArray, "{F69500}To chuc{FFFFFF}\n\n");
			strcat(szMiscArray, "Lam dan thuong rat vui, tham gia to chuc con thu vi hon.\n\n");
			strcat(szMiscArray, "\t Next Generation Gaming co nhieu loai to chuc de gia nhap:\n");
			strcat(szMiscArray, "\t{FF0000}Government (GOV){FFFFFF}: Ban hanh luat va quan ly ngan sach San Andreas.\n");
			strcat(szMiscArray, "\t{FF0000}Judicial (JUD){FFFFFF}: Quan ly hien phap San Andreas va cac vu kien ca nhan, co quan.\n");
			strcat(szMiscArray, "\t{FF0000}Law Enforcement Agency (LEA){FFFFFF}: Thi hanh luat cua chinh phu va bat nguoi vi pham.\n");
			strcat(szMiscArray, "\t{FF0000}Medic (MED){FFFFFF}: Nhan cuoc goi cap cuu va dua nguoi can giup den benh vien.\n");
			strcat(szMiscArray, "\t{FF0000}News Agency{FFFFFF}: Phat tin truc tiep ve su viec hang ngay den toan may chu.\n");
			strcat(szMiscArray, "\t{FF0000}Towing & Reposession{FFFFFF}: Keo xe dau sai phep hoac no ve phat ve bai giam tai San Andreas.\n");
			strcat(szMiscArray, "\t{FF0000}Transportation{FFFFFF}: Cho khach co nhu cau va thu mot khoan phi nho.\n");
			strcat(szMiscArray, "\t{FF0000}Contract Agency{FFFFFF}: Thuc hien hop dong am sat bat hop phap.\n");
			strcat(szMiscArray, "\t{FF0000}Criminal{FFFFFF}: To chuc toi pham thuc hien hanh vi bat hop phap.\n\n");
			strcat(szMiscArray, "Mot so to chuc nhan don gia nhap khi ban du dieu kien! Xem cac to chuc tai ng-gaming.net.");
			strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - To chuc", szMiscArray, countstring, "");
		}
		case 4:
		{
			szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
			strcat(szMiscArray, "{F69500}Tai san{FFFFFF}\n\n");
			strcat(szMiscArray, "Ban co the so huu nhieu loai tai san, voi gia khac nhau, de tang trai nghiem roleplay.\n\n");
			strcat(szMiscArray, "\tCo cac loai tai san sau:\n");
			strcat(szMiscArray, "\t{FF0000}Nha{FFFFFF}: Bieu tuong mau xanh la, co khap may chu.\n");
			strcat(szMiscArray, "\t{FF0000}Doanh nghiep{FFFFFF}: Co nhieu bieu tuong tuy loai, cho phep mua nhieu vat pham.\n");
			strcat(szMiscArray, "\t{FF0000}Cua{FFFFFF}: Co loi vao, noi that va nhieu cong dung, thuong co mui ten chi xuong hoac bieu tuong khac.\n");
			strcat(szMiscArray, "\t{FF0000}Garage{FFFFFF}: Loi vao/ra cho xe, hien nhan \"Garage\".\n");
			strcat(szMiscArray, "\t{FF0000}Xe{FFFFFF}: Co the mua xe tai dai ly va su dung khi muon.\n\n");
			strcat(szMiscArray, "Nhan 'N' khi o gan bieu tuong de vao hoac ra.");
			strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - To chuc", szMiscArray, countstring, "");
		}
		case 5:
		{
			szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
			strcat(szMiscArray, "{F69500}Hoan tat{FFFFFF}\n\n");
			strcat(szMiscArray, "Huong dan da ket thuc. Bay gio ban se tra loi cau hoi ve cac noi dung vua hoc.\n\n");
			strcat(szMiscArray, "\tNeu chua san sang, nhan \"Lap lai\" de xem lai. Neu da san sang, nhan \"Tiep tuc\".\n");
			strcat(szMiscArray, "\tTra loi sai bat ky cau nao, ban se phai hoc va thi lai.\n\n");
			strcat(szMiscArray, "{FF0000}Ban muon lam gi?{FFFFFF}");
			strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - To chuc", szMiscArray, "Tiep tuc", "Lap lai");
		}
		case 6:
		{
			SetPlayerCameraPos(playerid, -2026.9594, -117.1733, 1036.1282);
			SetPlayerCameraLookAt(playerid, -2026.5365, -116.2688, 1035.9733);
			SetPlayerInterior(playerid, 3);

			SendClientMessage(playerid, -1, "Hay doc ky cau hoi va dap an. Sai mot cau se phai hoc lai huong dan!");

			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_LIST, "Cach viet mot cau OOC dung la gi?", "Viet thang vao khung chat.\n\"Dat trong dau ngoac kep\".\n(( Dung hai dau ngoac don. ))", "Tiep tuc", "");
		}
		case 7: ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_LIST, "{FF0000}Metagaming la gi?", "Tron thong tin IC voi OOC.\nChoi nhieu game cung luc.\nEp nguoi khac vao tinh huong roleplay.", "Tiep tuc", "");
		case 8: ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_LIST, "{FF0000}Powergaming la gi?", "Dang nhap nhieu tai khoan cung luc.\nChoi nhieu game cung luc.\nEp nguoi khac vao tinh huong roleplay.", "Tiep tuc", "");
		case 9: ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_LIST, "{FF0000}Deathmatching la gi?", "Tu sat de tranh tinh huong.\nChay tron canh sat.\nGiet nguoi khi khong co ly do roleplay hop ly.", "Tiep tuc", "");
		case 10: ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_LIST, "{FF0000}Killing on Sight la gi?", "Tu sat de tranh tinh huong.\nGiet nguoi khi chua roleplay du truoc do.\nGiet canh sat.", "Tiep tuc", "");
		case 11:
		{
			szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
			strcat(szMiscArray, "{F69500}Lenh huu ich{FFFFFF}\n\n");
			strcat(szMiscArray, "Next Generation Gaming co nhieu lenh ho tro trai nghiem. Dung /help de xem cac lenh.\n\n");
			strcat(szMiscArray, "\t{FF0000}/newb(ie){FFFFFF} - Dat cau hoi de Advisor tra loi!\n");
			strcat(szMiscArray, "\t{FF0000}/(cancel)report{FFFFFF} - Lien he Admin hoac bao cao nguoi vi pham.\n");
			strcat(szMiscArray, "\t{FF0000}/stats{FFFFFF} - Xem thong tin tai khoan.\n");
			strcat(szMiscArray, "\t{FF0000}/inv(entory){FFFFFF} - Xem so luong tung vat pham trong tui.\n");
			strcat(szMiscArray, "\t{FF0000}/interact{FFFFFF} - Dua/ban vat pham va tuong tac voi nguoi khac. (Co the ngam RMB+Y vao nguoi do)\n");
			strcat(szMiscArray, "\t{FF0000}/pay{FFFFFF} - Tra mot so tien cho nguoi choi khac.\n");
			strcat(szMiscArray, "\n\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP Huong dan - Lenh", szMiscArray, "Tiep tuc", "");
		}
		case 12:
		{
			szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n\n";
			strcat(szMiscArray, "Ban da hoan tat huong dan. Nhan nut tiep theo de den menu tao nhan vat.\n\n");
			strcat(szMiscArray, "\t{F69521}Developers\n");
			strcat(szMiscArray, "\t\t{F69521}Director of Development{FFFFFF}:\n\t\t\tShane\n\n");
			strcat(szMiscArray, "\t\t{F69521}Developers{FFFFFF}:\n\
				\t\t\tMiguel\n\
				\t\t\tFarva\n\
				\t\t\tHector\n\
				\t\t\tThomas\n\
				\t\t{F69500}Past Developers{FFFFFF}:\n\
				\t\t\tAkatony\tJohn\t\tBrendan\n\
				\t\t\tBrian\t\tScott\t\tGhoulSlayer\n\
				\t\t\tZhao\t\tDonuts\t\tMo Cena\n\
				\t\t\tCalgon\t\tNeo\t\tThomasJ\n\
				\t\t\tBeren\t\tKareemtastic\tSew Sumi\n\
				\t\t\tRazbit\t\tAlexR\t\tAustin\n\
				\t\t\tDom\t\tRothschild\tWinterfield\n\
				\t\t\tJingles\tBehemoth\tWesten\n\
				\t\t\tConnolly\n");
			strcat(szMiscArray, "\n\n{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
			ShowPlayerDialogEx(playerid, DIALOG_TUTORIAL, DIALOG_STYLE_MSGBOX, "NG:RP - Developers", szMiscArray, "Tiep tuc", "");
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_TUTORIAL:
		{
			switch(PlayerInfo[playerid][pTut])
			{
				case 0 .. 4:
				{
					if(betaserver == 0) {
						if(GetPVarInt(playerid, "pTutorialTimer") != 0) return ShowTutorialDialog(playerid, PlayerInfo[playerid][pTut]);
						else
						{
							PlayerInfo[playerid][pTut]++;
							AdvanceTutorial(playerid);
						}
					} else {
						PlayerInfo[playerid][pTut] = 13;
						AdvanceTutorial(playerid);
					}
				}
				case 5:
				{
					if(!response)
					{
						PlayerInfo[playerid][pTut] = 0;
						AdvanceTutorial(playerid);

						SendClientMessage(playerid, -1, "Ban chon hoc lai huong dan. Hay doc ky truoc khi tiep tuc!");
					}
					else
					{
						PlayerInfo[playerid][pTut]++;
						AdvanceTutorial(playerid);
					}
				}
				case 6:
				{
					if(!response) return AdvanceTutorial(playerid);
					switch(listitem)
					{
						case 0, 1:
						{
							PlayerInfo[playerid][pTut] = 0;
							AdvanceTutorial(playerid);

							SendClientMessage(playerid, -1, "Sai dap an! Ban phai hoc lai huong dan. Hay chu y hon!");
						}
						default:
						{
							PlayerInfo[playerid][pTut]++;
							AdvanceTutorial(playerid);
						}
					}
				}
				case 7:
				{
					if(!response) return AdvanceTutorial(playerid);
					switch(listitem)
					{
						case 1, 2:
						{
							PlayerInfo[playerid][pTut] = 0;
							AdvanceTutorial(playerid);

							SendClientMessage(playerid, -1, "Sai dap an! Ban phai hoc lai huong dan. Hay chu y hon!");
						}
						default:
						{
							PlayerInfo[playerid][pTut]++;
							AdvanceTutorial(playerid);
						}
					}
				}
				case 8:
				{
					if(!response) return AdvanceTutorial(playerid);
					switch(listitem)
					{
						case 0, 1:
						{
							PlayerInfo[playerid][pTut] = 0;
							AdvanceTutorial(playerid);

							SendClientMessage(playerid, -1, "Sai dap an! Ban phai hoc lai huong dan. Hay chu y hon!");
						}
						default:
						{
							PlayerInfo[playerid][pTut]++;
							AdvanceTutorial(playerid);
						}
					}
				}
				case 9:
				{
					if(!response) return AdvanceTutorial(playerid);
					switch(listitem)
					{
						case 0, 1:
						{
							PlayerInfo[playerid][pTut] = 0;
							AdvanceTutorial(playerid);

							SendClientMessage(playerid, -1, "Sai dap an! Ban phai hoc lai huong dan. Hay chu y hon!");
						}
						default:
						{
							PlayerInfo[playerid][pTut]++;
							AdvanceTutorial(playerid);
						}
					}
				}
				case 10:
				{
					if(!response) return AdvanceTutorial(playerid);
					switch(listitem)
					{
						case 0, 2:
						{
							PlayerInfo[playerid][pTut] = 0;
							AdvanceTutorial(playerid);

							SendClientMessage(playerid, -1, "Sai dap an! Ban phai hoc lai huong dan. Hay chu y hon!");
						}
						default:
						{
							PlayerInfo[playerid][pTut]++;
							AdvanceTutorial(playerid);
						}
					}
				}
				case 11, 12:
				{
					PlayerInfo[playerid][pTut]++;
					AdvanceTutorial(playerid);
				}
				case 13: CharacterCreation(playerid);
				case 14:
				{
					if(!response) 
					{
						PlayerInfo[playerid][pTut] = -1;
						DisablePlayerCheckpoint(playerid);
						return SendClientMessageEx(playerid, -1, "Chao mung den Next Generation Gaming! Dung /help de xem lai lenh hoac /newb(ie) de hoi!");
					}
					else
					{
						PlayerInfo[playerid][pTut]++;
						AdvanceTutorial(playerid);
						SendClientMessageEx(playerid, COLOR_WHITE, "Ban da chon muc tieu. Dung \"/cancel objectives\" bat cu luc nao de huy.");
					}
				}
			}
		}
		case DIALOG_REGISTER_CREATION:
		{
			if(!response) return CharacterCreation(playerid);
			switch(listitem)
			{
				case 0: return CharacterCreation(playerid);
				case 1: return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_SEX, DIALOG_STYLE_LIST, "NG:RP Tao nhan vat | Gioi tinh", "Nam\nNu", "Chon", "<<");
				case 2: return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_MONTH, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh thang nao?", "Thang mot\nThang hai\nThang ba\nThang tu\nThang nam\nThang sau\nThang bay\nThang tam\nThang chin\nThang muoi\nThang muoi mot\nThang muoi hai", "Chon", "<<");
				case 3: return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_NATION, DIALOG_STYLE_LIST, "NG:RP Tao nhan vat | Quoc gia", "San Andreas\nNew Robada", "Chon", "<<");
				case 4:
				{
					szMiscArray[0] = 0;
					szMiscArray = "No accent\n\
					British accent\n\
					Japanese accent\n\
					Chinese accent\n\
					Korean accent\n\
					Scottish accent\n\
					Irish accent\n\
					Russian accent\n\
					American accent\n\
					Spanish accent\n\
					Southern accent\n\
					Italian accent\n\
					Southern accent\n\
					Gangster accent\n\
					Australian accent\n\
					Arabic accent\n\
					Balkan accent\n\
					Canadian accent\n\
					Jamaican accent\n\
					Israeli accent\n\
					Dutch accent\n\
					Brazilian accent\n\
					German accent\n\
					Turkish accent\n\
					Kiwi accent\n\
					French accent\n\
					Korean accent\n\
					Thai accent";
					return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_ACCENT, DIALOG_STYLE_LIST, "NG:RP Tao nhan vat | Giong noi", szMiscArray, "Chon", "<<");
				}
				case 5:
				{
					if(PlayerInfo[playerid][pSex] == 0) { 
						SendClientMessage(playerid, COLOR_YELLOW, "Hay chon gioi tinh truoc.");
						return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_SEX, DIALOG_STYLE_LIST, "NG:RP Tao nhan vat | Model skin", "Nam\nNu", "Chon", "<<");
					}

               		ShowPlayerDialogEx(playerid, DIALOG_REGISTER_SKIN, DIALOG_STYLE_INPUT, "NG:RP Tao nhan vat | Model skin", "Nhap skin ID cho nhan vat.", "Chon", "<<");
               	}
				
				case 6:
				{
					if(PlayerInfo[playerid][pSex] == 0)
					{
						SendClientMessage(playerid, COLOR_YELLOW, "Hay chon gioi tinh.");
						return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_SEX, DIALOG_STYLE_LIST, "NG:RP Tao nhan vat | Model skin", "Nam\nNu", "Chon", "<<");

					}
					if(strcmp(PlayerInfo[playerid][pBirthDate], "0000-00-00") == 0)
					{
						SendClientMessage(playerid, COLOR_YELLOW, "Hay chon ngay sinh.");
						return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_MONTH, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh thang nao?", "Thang mot\nThang hai\nThang ba\nThang tu\nThang nam\nThang sau\nThang bay\nThang tam\nThang chin\nThang muoi\nThang muoi mot\nThang muoi hai", "Chon", "<<");
					}

					if(PlayerInfo[playerid][pNation] != 0 && PlayerInfo[playerid][pNation] != 1) return ShowPlayerDialogEx(playerid, DIALOG_REGISTER_NATION, DIALOG_STYLE_LIST, "NG:RP Tao nhan vat | Quoc gia", "San Andreas\nNew Robada", "Chon", "<<");

					ShowPlayerDialogEx(playerid, DIALOG_REGISTER_REFERRED, DIALOG_STYLE_INPUT, "{FF0000}He thong gioi thieu", "Co nguoi choi nao gioi thieu ban den may chu khong?\nNeu co, nhap ten ho ben duoi.\n\nNeu khong, nhan nut Bo qua.\n\n{FF0000}Luu y: Ten phai co dau gach duoi (Vi du: FirstName_LastName)", "Nhap", "Bo qua");
					return 1;
				}
			}
		}
		case DIALOG_REGISTER_SKIN: {

			if(response && !isnull(inputtext) && IsNumericString(inputtext) && IsValidSkin(strval(inputtext))) {

			    PlayerInfo[playerid][pModel] = strval(inputtext);
				AdjustActor(playerid, strval(inputtext));
			}
			CharacterCreation(playerid);
		}
		case DIALOG_REGISTER_SEX:
	    {
		    if(response)
		    {
			    if(listitem == 0) {
					PlayerInfo[playerid][pSex] = 1;
					PlayerInfo[playerid][pModel] = 2;
					AdjustActor(playerid, 2);
					SendClientMessage(playerid, COLOR_YELLOW2, "Da chon nhan vat nam!");
					CharacterCreation(playerid);
				}
				else if(listitem == 1) {
					PlayerInfo[playerid][pSex] = 2;
					PlayerInfo[playerid][pModel] = 91;
					AdjustActor(playerid, 91);
					SendClientMessage(playerid, COLOR_YELLOW2, "Da chon nhan vat nu!");
					CharacterCreation(playerid);
				}
			}
			else ShowPlayerDialogEx(playerid, DIALOG_REGISTER_SEX, DIALOG_STYLE_LIST, "{FF0000}Nhan vat cua ban la nam hay nu?", "Nam\nNu", "Gui", "");
		}
		case DIALOG_REGISTER_NATION: 
		{
			if(response) 
			{
				PlayerInfo[playerid][pNation] = listitem;
				switch(listitem) 
				{
					case 0: SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da la cong dan San Andreas.");
					case 1: SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da la cong dan New Robada.");
				}
			}
			CharacterCreation(playerid);
		}
		case DIALOG_REGISTER_MONTH:
	    {
			if(response)
			{
				szMiscArray[0] = 0;
				new month = listitem+1;
				SetPVarInt(playerid, "RegisterMonth", month);

				new lastdate;
				if(listitem == 0 || listitem == 2 || listitem == 4 || listitem == 6 || listitem == 7 || listitem == 9 || listitem == 11) lastdate = 32;
				else if(listitem == 3 || listitem == 5 || listitem == 8 || listitem == 10) lastdate = 31;
				else lastdate = 29;
				for(new x = 1; x < lastdate; x++)
				{
					format(szMiscArray, sizeof(szMiscArray), "%s%d\n", szMiscArray, x);
				}
				ShowPlayerDialogEx(playerid, DIALOG_REGISTER_DAY, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh ngay nao?", szMiscArray, "Gui", "");
			}
			else return CharacterCreation(playerid);
		}
		case DIALOG_REGISTER_DAY:
	    {
	    	szMiscArray[0] = 0;
			if(response)
			{
				new setday = listitem+1;
				SetPVarInt(playerid, "RegisterDay", setday);

				new month, day, year;
				getdate(year,month,day);
				new startyear = year-100;
				for(new x = startyear; x < year; x++)
				{
					format(szMiscArray, sizeof(szMiscArray), "%s%d\n", szMiscArray, x);
				}
				ShowPlayerDialogEx(playerid, DIALOG_REGISTER_YEAR, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh nam nao?", szMiscArray, "Gui", "");
			}
			else ShowPlayerDialogEx(playerid, DIALOG_REGISTER_MONTH, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh thang nao?", "Thang mot\nThang hai\nThang ba\nThang tu\nThang nam\nThang sau\nThang bay\nThang tam\nThang chin\nThang muoi\nThang muoi mot\nThang muoi hai", "Gui", "");
		}
		case DIALOG_REGISTER_YEAR:
	    {
	    	szMiscArray[0] = 0;
			new month, day, year;
			getdate(year,month,day);
			new startyear = year-100;
			if(response)
			{
				new setyear = listitem+startyear;
				format(PlayerInfo[playerid][pBirthDate], 11, "%d-%02d-%02d", setyear, GetPVarInt(playerid, "RegisterMonth"), GetPVarInt(playerid, "RegisterDay"));
				DeletePVar(playerid, "RegisterMonth");
				DeletePVar(playerid, "RegisterDay");
				SendClientMessage(playerid, COLOR_LIGHTRED, "Da dat ngay sinh.");
				return CharacterCreation(playerid);
			}
			else
			{
				for(new x = startyear; x < year; x++)
				{
					format(szMiscArray, sizeof(szMiscArray), "%s%d\n", szMiscArray, x);
				}
				ShowPlayerDialogEx(playerid, DIALOG_REGISTER_YEAR, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh nam nao?", szMiscArray, "Gui", "");
			}
		}
		case DIALOG_REGISTER_ACCENT:
		{
			if(response)
			{
				if(listitem == 0) PlayerInfo[playerid][pAccent] = listitem;
				if(listitem > 0) PlayerInfo[playerid][pAccent] = listitem+1;
			}
			return CharacterCreation(playerid);
		}
		case DIALOG_REGISTER_REFERRED:
		{
		    if(response)
		    {
		        if(IsNumericString(inputtext))
		        {
		            ShowPlayerDialogEx(playerid, DIALOG_REGISTER_REFERRED, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten khong dung roleplay\nHay nhap ten roleplay hop le.\n\nVi du: FirstName_LastName", "Nhap", "Bo qua");
		            return 1;
				}
				if(strfind(inputtext, "_", true) == -1)
				{
				    ShowPlayerDialogEx(playerid, DIALOG_REGISTER_REFERRED, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten khong dung roleplay\nHay nhap ten roleplay hop le.\n\nVi du: FirstName_LastName", "Nhap", "Bo qua");
		            return 1;
		        }
		        if(strlen(inputtext) > 20)
		        {
		            ShowPlayerDialogEx(playerid, DIALOG_REGISTER_REFERRED, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten qua dai\nHay rut ngan ten.\n\nVi du: FirstName_LastName (Toi da 20 ky tu)", "Nhap", "Bo qua");
		            return 1;
		        }
		        if(strcmp(inputtext, GetPlayerNameExt(playerid), true) == 0)
		        {
		            ShowPlayerDialogEx(playerid, DIALOG_REGISTER_REFERRED, DIALOG_STYLE_INPUT, "{FF0000}Loi", "Khong the tu gioi thieu minh.\nNhap ten nguoi gioi thieu hoac nhan 'Bo qua'.\n\nVi du: FirstName_LastName (Toi da 20 ky tu)", "Nhap", "Bo qua");
		            return 1;
		        }
				for(new sz = 0; sz < strlen(inputtext); sz++)
				{
				    if(inputtext[sz] == ' ')
				    {
					    ShowPlayerDialogEx(playerid, DIALOG_REGISTER_REFERRED, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten khong dung roleplay\nHay nhap ten roleplay hop le.\n\nVi du: FirstName_LastName", "Nhap", "Bo qua");
			            return 1;
			        }
			    }
			  	mysql_escape_string(inputtext, szMiscArray);
                format(PlayerInfo[playerid][pReferredBy], MAX_PLAYER_NAME, "%s", szMiscArray);
                mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT `Username` FROM `accounts` WHERE `Username` = '%e'", inputtext);
				mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "iii", MAIN_REFERRAL_THREAD, playerid, g_arrQueryHandle[playerid]);
			}
			else
			{
			    format(szMiscArray, sizeof(szMiscArray), "Nobody");
				strmid(PlayerInfo[playerid][pReferredBy], szMiscArray, 0, strlen(szMiscArray), MAX_PLAYER_NAME);
				PlayerInfo[playerid][pTut] = 14;
				AdvanceTutorial(playerid);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Cam on ban da dien du thong tin!");
			}
		}
	}
	return 0;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(PlayerInfo[playerid][pTut] >= 0)
	{
		switch(PlayerInfo[playerid][pTut])
		{
			case 15:
			{
				DisablePlayerCheckpoint(playerid);
				SendClientMessage(playerid, COLOR_WHITE, "Vao xe ban du tien de mua!");
			}
			case 16:
			{
				DisablePlayerCheckpoint(playerid);
				SendClientMessage(playerid, COLOR_WHITE, "Vao toa nha, nhan chuot phai ngam nhan vien ngan hang va nhan Y de tuong tac!");
			}
			case 17:
			{
				DisablePlayerCheckpoint(playerid);
				SendClientMessage(playerid, COLOR_WHITE, "Vao toa nha va dung /buy de mua dien thoai.");
			}
		}
	}
}

forward AdjustActor(playerid, skinid);
public AdjustActor(playerid, skinid) 
{
	new id;
	if(PlayerInfo[playerid][pTut] == 13 && GetPVarType(playerid, "pActor")) 
	{
		id = GetPVarInt(playerid, "pActor");
		if(IsValidActor(id)) DestroyActor(id);
	}

	id = CreateActor(skinid, 221.1730, 1823.6620, 7.5124, 270.0);
	SetPVarInt(playerid, "pActor", id);
	SetActorVirtualWorld(id, playerid + 1);
	SetPlayerSkin(playerid, skinid);
	return 1;
}

forward TutorialTimer(playerid);
public TutorialTimer(playerid)
{
	if(GetPVarInt(playerid, "pTutorialTimer") > 0) 
	{
		SetPVarInt(playerid, "pTutorialTimer", GetPVarInt(playerid, "pTutorialTimer") - 1);
		ShowTutorialDialog(playerid, PlayerInfo[playerid][pTut]);
	}
	else KillTimer(TutorialTime[playerid]);
	return 1;
}

GetPlayerAccent(iPlayerID) 
{
	new accent[26];
	switch(PlayerInfo[iPlayerID][pAccent]) 	
	{
		case 0, 1: accent = "";
		case 2: accent = "British accent";
		case 3: accent = "Japanese accent";
		case 4: accent = "Chinese accent";
		case 5: accent = "Korean accent";
		case 6: accent = "Scottish accent";
		case 7: accent = "Irish accent";
		case 8: accent = "Russian accent";
		case 9: accent = "American accent";
		case 10, 12: accent = "Spanish accent";
		case 11: accent = "Southern accent";
		case 13: accent = "Italian accent";
		case 14: accent = "Gangster accent";
		case 15: accent = "Australian accent";
		case 16: accent = "Arabic accent";
		case 17: accent = "Balkan accent";
		case 18: accent = "Canadian accent";
		case 19: accent = "Jamaican accent";
		case 20: accent = "Israeli accent";
		case 21: accent = "Dutch accent";
		case 22: accent = "Brazilian accent";
		case 23: accent = "German accent";
		case 24: accent = "Turkish accent";
		case 25: accent = "Kiwi accent";
		case 26: accent = "French accent";
		case 27: accent = "Korean accent";
		case 28: accent = "Thai accent";
	}
	return accent;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(GetPVarType(playerid, "pActor")) DestroyActor(GetPVarInt(playerid, "pActor"));
	return 1;
}

CMD:forcetutorial(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		new id;
		if(sscanf(params, "u", id)) return SendClientMessageEx(playerid, COLOR_WHITE, "CU PHAP: /forcetutorial [playerid]");

		if(IsPlayerConnected(id))
		{
			szMiscArray[0] = 0;
			switch(PlayerInfo[id][pTut])
			{
				case 0 .. 12:
				{
					PlayerInfo[id][pTut] = 13;
					AdvanceTutorial(id);

					format(szMiscArray, 128, "Da dua %s den menu tao nhan vat.", GetPlayerNameEx(id));
					SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
					format(szMiscArray, 128, "Admin %s dua ban den menu tao nhan vat.", GetPlayerNameEx(playerid));
					SendClientMessage(id, COLOR_WHITE, szMiscArray);
				}
				case 13: return SendClientMessage(playerid, COLOR_WHITE, "Nguoi nay dang trong menu tao nhan vat, hay cho.");
				case 14 .. 18:
				{
					PlayerInfo[id][pTut] = -1;
					AdvanceTutorial(id);

					format(szMiscArray, 128, "Da buoc %s roi huong dan.", GetPlayerNameEx(id));
					SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
					format(szMiscArray, 128, "Admin %s buoc ban roi huong dan.", GetPlayerNameEx(playerid));
					SendClientMessage(id, COLOR_WHITE, szMiscArray);
				}
				default: return SendClientMessage(playerid, COLOR_WHITE, "Nguoi nay khong o trong huong dan.");
			}
		}
		else return SendClientMessage(playerid, COLOR_WHITE, "Nguoi nay chua ket noi!");
	}
	else SendClientMessage(playerid, COLOR_WHITE, "Ban khong co quyen dung lenh nay!");
	return 1;
}