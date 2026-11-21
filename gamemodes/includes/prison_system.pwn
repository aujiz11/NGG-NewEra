/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Prison System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

	* Copyright (c) 2014, Next Generation Gaming, LLC
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

new g_aMaleSkins[185] = {
	1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
	30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60,
	61, 62, 66, 68, 72, 73, 78, 79, 80, 81, 82, 83, 84, 94, 95, 96, 97, 98, 99, 100, 101, 102,
	103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
	121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146,
	147, 153, 154, 155, 156, 158, 159, 160, 161, 162, 167, 168, 170, 171, 173, 174, 175, 176,
	177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 200, 202, 203, 204, 206,
	208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 228, 229, 230, 234, 235, 236, 239, 240,
	241, 242, 247, 248, 249, 250, 253, 254, 255, 258, 259, 260, 261, 262, 268, 272, 273, 289,
	290, 291, 292, 293, 294, 295, 296, 297, 299
};

new g_aFemaleSkins[77] = {
    9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 65, 69,
    75, 76, 77, 85, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 140, 141,
    145, 148, 150, 151, 152, 157, 169, 178, 190, 191, 192, 193, 194, 195,
    196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 219, 224, 225,
    226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298
};

DocIsolate(playerid, cellid, ooc)
{
	SetPlayerPos(playerid, DocIsolation[cellid][0], DocIsolation[cellid][1], DocIsolation[cellid][2]);
	SetPlayerFacingAngle(playerid, 0);
	SetPlayerInterior(playerid, 1);
	Player_StreamPrep(playerid, DocIsolation[cellid][0], DocIsolation[cellid][1], DocIsolation[cellid][2], FREEZE_TIME);

	PlayerInfo[playerid][pIsolated] = cellid + 1;
	if(ooc >= 1)
	{
	    SetPlayerVirtualWorld(playerid, 666);
	    PlayerInfo[playerid][pVW] = 666;
	}
}

ListDetainees(playerid)
{
	new szPrisoners[1028],
		iCount = 0,
		temp[4];

	foreach(new i : Player)
	{
		if(GetPVarInt(i, "ArrestPoint") == GetArrestPointID(playerid) + 1)
		{
			strcat(szPrisoners, "{3333CC}Prisoner:{FFFFFF}");
			strcat(szPrisoners, "(");
			valstr(temp, i);
			strcat(szPrisoners, temp);
			strcat(szPrisoners, ")");
			strcat(szPrisoners, GetPlayerNameEx(i));
			strcat(szPrisoners, "\n");
			iCount++;
		}
	}
	if(iCount == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong co tu nhan tai diem bat giu nay.");
	return ShowPlayerDialogEx(playerid, DIALOG_LOAD_DETAINEES, DIALOG_LOAD_DETAINEES, "Danh sach nguoi bi giam", szPrisoners, "Len xe", "Huy");
}

LoadPrisoner(iLoadingID, iPrisonerID, iVehicleID, iVehicleSeat, iNewVW, iNewIW)
{
	SetPlayerVirtualWorld(iPrisonerID, iNewVW);
	PlayerInfo[iPrisonerID][pVW] = iNewVW;
	SetPlayerInterior(iPrisonerID, iNewIW);
	PlayerInfo[iPrisonerID][pInt] = iNewIW;
	PutPlayerInVehicle(iPrisonerID, iVehicleID, iVehicleSeat);
	TogglePlayerControllable(iPrisonerID, false);
	DeletePVar(iPrisonerID, "ArrestPoint");

	SendClientMessageEx(iPrisonerID, COLOR_LIGHTBLUE, "Ban da duoc dua len xe cho tu va se duoc chuyen den DOC");
	ListDetainees(iLoadingID);
}

ShowDocPrisonControls(playerid, icontrolid)
{
	szMiscArray[0] = 0;

	switch(icontrolid)
	{
		case 0:
		{
			// main dialog
			format(szMiscArray, sizeof(szMiscArray), "Cell-block A\nIsolation Cells\nCua khu vuc\nPhong toa\nLoa noi bo");
			ShowPlayerDialogEx(playerid, DIALOG_DOC_CP, DIALOG_STYLE_LIST, "Bang dieu khien Doc", szMiscArray, "Chon", "Huy");
		}
		case 1:
		{
			// sub-dialog
			format(szMiscArray, sizeof(szMiscArray), "Floor 1\nFloor 2\nToan bo Floor 1\nToan bo Floor 2");
			ShowPlayerDialogEx(playerid, DIALOG_DOC_CP_SUB, DIALOG_STYLE_LIST, "Bang dieu khien Doc", szMiscArray, "Chon", "Quay lai");
		}
		case 2:
		{
			// floor 1
			format(szMiscArray, sizeof(szMiscArray), "Cell 1 (%s)\n\
			Cell 2 (%s)\n\
			Cell 3 (%s)\n\
			Cell 4 (%s)\n\
			Cell 5 (%s)\n\
			Cell 6 (%s)\n\
			Cell 7 (%s)\n\
			Cell 8 (%s)\n\
			Cell 9 (%s)\n\
			Cell 10 (%s)\n\
			Cell 11 (%s)\n\
			Cell 12 (%s)\n\
			Cell 13 (%s)\n\
			Cell 14 (%s)\n\
			Cell 15 (%s)\n\
			Cell 16 (%s)",
			((bDocCellOpen[0] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[1] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[2] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[3] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[4] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[5] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[6] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[7] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[8] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[9] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[10] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[11] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[12] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[13] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[14] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[15] == false) ? ("{FF0000}Dong"):("{00FF00}Mo"))
			);
			ShowPlayerDialogEx(playerid, DIALOG_DOC_CP_C1F1, DIALOG_STYLE_LIST, "Bang dieu khien Doc", szMiscArray, "Chon", "Quay lai");
		}
		case 3:
		{
			// floor 2
			format(szMiscArray, sizeof(szMiscArray), "Cell 1 (%s)\n\
			Cell 2 (%s)\n\
			Cell 3 (%s)\n\
			Cell 4 (%s)\n\
			Cell 5 (%s)\n\
			Cell 6 (%s)\n\
			Cell 7 (%s)\n\
			Cell 8 (%s)\n\
			Cell 9 (%s)\n\
			Cell 10 (%s)\n\
			Cell 11 (%s)\n\
			Cell 12 (%s)\n\
			Cell 13 (%s)\n\
			Cell 14 (%s)\n\
			Cell 15 (%s)",
			((bDocCellOpen[16] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[17] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[18] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[19] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[20] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[21] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[22] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[23] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[24] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[25] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[26] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[27] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[28] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[29] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocCellOpen[30] == false) ? ("{FF0000}Dong"):("{00FF00}Mo"))
			);
			ShowPlayerDialogEx(playerid, DIALOG_DOC_CP_C1F2, DIALOG_STYLE_LIST, "Bang dieu khien Doc", szMiscArray, "Chon", "Quay lai");
		}
		case 4:
		{
			// area controls
			format(szMiscArray, sizeof(szMiscArray), "Cell-block 1(%s)\n\
			Cell-block 2 (%s)\n\
			Showers (%s)\n\
			Cafe 1 (%s)\n\
			Cafe 2 (%s)\n\
			Laundry Room (%s)\n\
			Isolation Block (%s)\n\
			Control Room (%s)\n\
			Processing 1 (%s)\n\
			Processing 2 (%s)\n\
			Processing 3 (%s)\n\
			Classroom (%s)\n\
			Janitor's Closet (%s)\n\
			Medical Ward (%s)\n\
			Hallway(%s)\n\
			Lobby 1 (%s)\n\
			Lobby 2 (%s)\n\
			Visitation (%s)",
			((bDocAreaOpen[0] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[1] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[2] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[3] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[4] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[5] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[6] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[7] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[8] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[9] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[10] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[11] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[12] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[13] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[14] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[15] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[16] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[17] == false) ? ("{FF0000}Dong"):("{00FF00}Mo")),
			((bDocAreaOpen[18] == false) ? ("{FF0000}Dong"):("{00FF00}Mo"))
			);
			ShowPlayerDialogEx(playerid, DIALOG_DOC_CP_AREA, DIALOG_STYLE_LIST, "Bang dieu khien Doc", szMiscArray, "Chon", "Quay lai");
		}
	}
	return 1;
}

DocLockdown(playerid)
{
	new szWarning[128];

	if(bDocLockdown == false)
	{

		bDocLockdown = true;
		for(new i = 0; i < 31; i++)
		{
			OpenDocCells(i, 0);
		}
		for(new i = 0; i < 19; i++)
		{
			OpenDocAreaDoors(i, 0);
		}
		format( szWarning, sizeof(szWarning), "CANH BAO: DeMorgan Correctional Facility dang phong toa khan cap (( %s ))", GetPlayerNameEx(playerid));
		SendGroupMessage(1, COLOR_RED, szWarning);

		format(szMiscArray, sizeof szMiscArray, "%s has set the DeMorgan Correctional Facilty on lockdown.", GetPlayerNameEx(playerid));
 		GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
	}
	else
	{
		bDocLockdown = false;
		format( szWarning, sizeof(szWarning), "CANH BAO: DeMorgan Correctional Facility da go phong toa (( %s ))", GetPlayerNameEx(playerid));
		SendGroupMessage(1, COLOR_YELLOW, szWarning);

		format(szMiscArray, sizeof szMiscArray, "%s has removed the DeMorgan Correctional Facilty from lockdown.", GetPlayerNameEx(playerid));
 		GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
	}
}

Prison_SetPlayerSkin(playerid) {
	switch(PlayerInfo[playerid][pSex]) {
		case 1: {
			SetPlayerSkin(playerid, 8);
			PlayerInfo[playerid][pModel] = 8;
		}
		case 2: {
			SetPlayerSkin(playerid, 211);
			PlayerInfo[playerid][pModel] = 211;
		}
	}
}

GetClosestPrisonPhone(playerid)
{
	new returnval;
	for(new i = 0; i < 5; i++)
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2, JailPhonePos[i][0], JailPhonePos[i][1], JailPhonePos[i][2]))
		{
			returnval = i;
			break;
		}
	}
	return returnval;
}

forward OpenDocAreaDoors(doorid, open);
public OpenDocAreaDoors(doorid, open)
{
	switch(doorid)
	{
		case 0: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[0], 568.36981, 1453.9955, 5999.47168, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[0], 568.36981, 1455.3355, 5999.47168, 0.9);
		}
		case 1: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[1], 572.8498, 1453.9955, 5999.47168, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[1], 572.8498, 1455.3155, 5999.47168, 0.9);
		}
		case 2: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[2], 585.77289, 1448.87915, 5999.45947, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[2], 585.7729, 1447.5592, 5999.4595, 0.9);
		}
		case 3: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[3], 553.98120, 1466.11426, 5999.44971, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[3], 552.6612, 1466.1143, 5999.4497, 0.9);
		}
		case 4: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[4], 553.98169, 1474.47205, 5999.48877, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[4], 552.6617, 1474.4720, 5999.4888, 0.9);
		}
		case 5: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[5], 583.51978, 1455.05212, 5999.47266, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[5], 582.1798, 1455.0521, 5999.4727, 0.9);
		}
		case 6: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[6], 531.66589, 1428.00647, 10999.45703, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[6], 530.3259, 1428.0065, 10999.4570, 0.9);
		}
		case 7: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[7], 566.54053, 1462.30774, 6003.41699, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[7], 565.2205, 1462.30774, 6003.41699, 0.9);
		}
		case 8: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[8], 572.98657, 1447.5975, 5999.4727, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[8], 572.98657, 1449.12683, 5999.4727, 0.9);
		}
		case 9: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[9], 597.01477, 1452.43774, 5999.44873 , 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[9], 597.0148, 1451.0177, 5999.4487, 0.9);
		}
		case 10: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[10], 599.12000, 1451.45422, 5999.47754, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[10],  597.7200, 1451.4742, 5999.4775, 0.9);
		}
		case 11: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[11],  589.21820, 1448.87537, 5999.46826, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[11],  589.2182, 1447.4754, 5999.4683, 0.9);
		}
		case 12: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[12],  579.57898, 1463.63379, 5999.46143, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[12],  579.5790, 1462.3338, 5999.4614, 0.9);
		}
		case 13: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[13], 572.99377, 1468.63940, 5999.43994, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[13],  572.9938, 1467.3394, 5999.4399, 0.9);
		}
		case 14: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[14],  572.98419, 1434.65295, 5999.52295, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[14],  572.9842, 1433.2330, 5999.5229, 0.9);
		}
		case 15: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[15],  575.50751, 1461.82019, 5999.47168, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[15],  574.1475, 1461.82019, 5999.47168, 0.9);
		}
		case 16: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[16],  526.92139, 1414.63281, 10999.45703, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[16],  526.92139, 1415.9528, 10999.45703, 0.9);
		}
		case 17: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[17],  529.96143, 1414.63281, 10999.45703, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[17],  529.96143, 1415.9528, 10999.45703, 0.9);
		}
		case 18: {
			if(open == 0) MoveDynamicObject(DocCellRoomDoors[18],  542.2069, 1417.86682, 10999.45703, 0.9);
			if(open == 1) MoveDynamicObject(DocCellRoomDoors[18],  542.2069, 1416.5468, 10999.45703, 0.9);
		}
	}
	if(open == 0) bDocAreaOpen[doorid] = false;
	else if(open == 1) bDocAreaOpen[doorid] = true;
}

OpenDocCells(cellid, open)
{
	switch(cellid)
	{
		case 0:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[0], 567.21069, 1445.88171, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[0], 567.21069 - 1.58, 1445.88171, 6000.74609, 0.9);
		}
		case 1:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[1], 563.58539, 1445.88171, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[1], 563.58539 - 1.58, 1445.88171, 6000.74609, 0.9);
		}
		case 2:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[2], 559.87738, 1445.88171, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[2], 559.87738 - 1.58, 1445.88171, 6000.74609, 0.9);
		}
		case 3:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[3], 556.21832, 1445.88171, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[3], 556.21832 - 1.58, 1445.88171, 6000.74609, 0.9);
		}
		case 4:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[4], 552.55121, 1445.88171, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[4], 552.55121 - 1.58, 1445.88171, 6000.74609, 0.9);
		}
		case 5:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[5], 548.86353, 1445.88171, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[5], 548.86353 - 1.58, 1445.88171, 6000.74609, 0.9);
		}
		case 6:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[6], 545.21039, 1445.86316, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[6], 545.21039 - 1.58, 1445.86316, 6000.74609, 0.9);
		}
		case 7:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[7], 542.56842, 1446.81152, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[7], 542.56842, 1446.81152 + 1.58, 6000.74609, 0.9);
		}
		case 8:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[8], 542.54321, 1450.46936, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[8], 542.54321, 1450.46936  + 1.58, 6000.74609, 0.9);
		}
		case 9:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[9], 542.55432, 1454.13354, 6000.74609, 0.9);//
			if(open == 1) MoveDynamicObject(DocCellsFloor1[9], 542.55432, 1454.13354 + 1.58, 6000.74609, 0.9);//
		}
		case 10:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[10], 542.55432, 1457.79626, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[10], 542.55432, 1457.79626 + 1.58, 6000.74609, 0.9);
		}
		case 11:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[11], 543.48657, 1462.26819, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[11], 543.48657  + 1.58, 1462.26819, 6000.74609, 0.9);
		}
		case 12:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[12], 547.16162, 1462.26819, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[12], 547.16162 + 1.58, 1462.26819, 6000.74609, 0.9);
		}
		case 13:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[13], 550.84277, 1462.28821, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[13], 550.84277  + 1.58, 1462.28821, 6000.74609, 0.9);
		}
		case 14:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[14], 556.91632, 1462.26819, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[14], 556.91632  + 1.58, 1462.26819, 6000.74609, 0.9);
		}
		case 15:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor1[15], 560.60620, 1462.26819, 6000.74609, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor1[15],560.60620 + 1.58, 1462.26819, 6000.74609, 0.9);
		}
		case 16:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[0], 567.23071, 1445.88171, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[0], 567.23071 - 1.58, 1445.88171, 6004.63135, 0.9);
		}
		case 17:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[1], 563.58539, 1445.88171, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[1], 563.58539 - 1.58, 1445.88171, 6004.63135, 0.9);
		}
		case 18:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[2], 559.87738, 1445.88171, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[2], 559.87738 - 1.58, 1445.88171, 6004.63135, 0.9);
		}
		case 19:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[3], 556.21832, 1445.88171, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[3], 556.21832 - 1.58, 1445.88171, 6004.63135, 0.9);
		}
		case 20:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[4], 552.55121, 1445.88171, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[4], 552.55121 - 1.58, 1445.88171, 6004.63135, 0.9);
		}
		case 21:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[5], 548.86353, 1445.88171, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[5], 548.86353 - 1.58, 1445.88171, 6004.63135, 0.9);
		}
		case 22:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[6], 545.21039, 1445.86316, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[6], 545.21039 - 1.58, 1445.86316, 6004.63135, 0.9);
		}
		case 23:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[7], 542.56842, 1446.81152, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[7], 542.56842, 1446.81152 + 1.58, 6004.63135, 0.9);
		}
		case 24:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[8], 542.54321, 1450.46936, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[8], 542.54321, 1450.46936 + 1.58, 6004.63135, 0.9);
		}
		case 25:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[9], 542.55432, 1454.13354, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[9], 542.55432, 1454.13354 + 1.58, 6004.63135, 0.9);
		}
		case 26:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[10], 542.55432, 1457.79626, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[10], 542.55432, 1457.79626 + 1.58, 6004.63135, 0.9);
		}
		case 27:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[11], 543.48657, 1462.26819, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[11], 543.48657 + 1.58, 1462.26819, 6004.63135, 0.9);
		}
		case 28:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[12], 547.16162, 1462.26819, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[12], 547.16162 + 1.58, 1462.26819, 6004.63135, 0.9);
		}
		case 29:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[13], 550.84277, 1462.28821, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[13], 550.84277 + 1.58, 1462.28821, 6004.63135, 0.9);
		}
		case 30:
		{
			if(open == 0) MoveDynamicObject(DocCellsFloor2[14], 556.91632, 1462.26819, 6004.63135, 0.9);
			if(open == 1) MoveDynamicObject(DocCellsFloor2[14], 556.91632 + 1.58, 1462.26819, 6004.63135, 0.9);
		}
	}
	if(open == 0) bDocCellOpen[cellid] = false;
	else if(open == 1) bDocCellOpen[cellid] = true;
}

/*GetClosestJailBoxingRing(iTargetID)
{
	new iClosest;
	for(new i = 0; i < MAX_JAIL_BOXINGS; i++)
	{
		if(IsPlayerInRangeOfPoint(iTargetID, 5, JailBoxingPos[i][0], JailBoxingPos[i][1], JailBoxingPos[i][2]))
		{
			iClosest = i;
			break;
		}
	}
	return iClosest;
}

IsPlayerAtJailBoxing(iTargetID)
{
	for(new i = 0; i < MAX_JAIL_BOXINGS; i++)
	{
		if(IsPlayerInRangeOfPoint(iTargetID, 5, JailBoxingPos[i][0], JailBoxingPos[i][1], JailBoxingPos[i][2]))
		{
			return true;
		}
	}
	return 0;
}

SetPlayerIntoJailBoxing(iTargetID)
{
	new index = GetClosestJailBoxingRing(iTargetID);

	if(arrJailBoxingData[index][bInProgress] == false && arrJailBoxingData[index][iParticipants] < 2)
	{
		SetPlayerPos(iTargetID, JailBoxingPos[index][0], JailBoxingPos[index][1], JailBoxingPos[index][2]);
		arrJailBoxingData[index][iParticipants]++;
		SetPVarInt(iTargetID, "_InJailBoxing", index + 1);
		SendClientMessageEx(iTargetID, COLOR_WHITE, "You have joined the boxing queue.");

		if(arrJailBoxingData[index][iParticipants] == 2)
		{
			foreach(Player, i)
			{
				if(GetPVarInt(i, "_InJailBoxing") == index + 1 && i != iTargetID)
				{
					SetPVarInt(iTargetID, "_JailBoxingChallenger", i);
					SetPVarInt(i, "_JailBoxingChallenger", iTargetID);
					break;
				}
			}
			arrJailBoxingData[index][iDocBoxingCountdown] = 4;
			arrJailBoxingData[index][iDocCountDownTimer] = SetTimerEx("StartJailBoxing", 1000, true, "i", index);
		}
	}
	else SendClientMessageEx(iTargetID, COLOR_WHITE, "You cannot join this arena at the moment.");
}*/

RemoveFromJailBoxing(iTargetID)
{
	arrJailBoxingData[GetPVarInt(iTargetID, "_InJailBoxing") - 1][iParticipants]--;

	//DeletePVar(GetPVarInt(iTargetID, "_JailBoxingChallenger"));

	DeletePVar(iTargetID, "_InJailBoxing");
	DeletePVar(iTargetID, "_JailBoxingChallenger");
}

forward StartJailBoxing(iArenaID);
public StartJailBoxing(iArenaID)
{
	new string[60 + MAX_PLAYER_NAME];
	new iRangePoint;

	foreach(new i : Player)
	{
		if(GetPVarType(i, "_InJailBoxing") && GetPVarInt(i, "_InJailBoxing") - 1 == iArenaID)
		iRangePoint = i;
		break;
	}

	arrJailBoxingData[iArenaID][iDocBoxingCountdown]--;
	if(arrJailBoxingData[iArenaID][iDocBoxingCountdown] == 0)
	{
		format(string, sizeof(string), "** [Boxing Countdown (Arena:%d)] Chuong vang len **", iArenaID);
		ProxDetector(10.0, iRangePoint, string, 0xEB41000, 0xEB41000, 0xEB41000, 0xEB41000, 0xEB41000);
		arrJailBoxingData[iArenaID][bInProgress] = true;
		KillTimer(arrJailBoxingData[iArenaID][iDocCountDownTimer]);
		arrJailBoxingData[iArenaID][iDocBoxingCountdown] = 4;
	}
	else
	{
		format(string, sizeof(string), "** [Boxing Countdown (Arena:%d)] Con %d giay de bat dau! **", iArenaID, arrJailBoxingData[iArenaID][iDocBoxingCountdown]);
		ProxDetector(10.0, iRangePoint, string, 0xEB41000, 0xEB41000, 0xEB41000, 0xEB41000, 0xEB41000);
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_DOC_CP:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: ShowDocPrisonControls(playerid, 1);
					case 1: ShowDocPrisonControls(playerid, 5);
					case 2: ShowDocPrisonControls(playerid, 4);
					case 3: DocLockdown(playerid);
					case 4: ShowPlayerDialogEx(playerid, DIALOG_DOC_CP_INT, DIALOG_STYLE_LIST, "Doc Control Pannel - Loa noi bo", "Prison\nYard\nTat ca", "Chon", "Quay lai");
				}
			}
		}
		case DIALOG_DOC_CP_SUB:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: // floor 1
					{
						ShowDocPrisonControls(playerid, 2);
					}
					case 1: // floor 2
					{
						ShowDocPrisonControls(playerid, 3);
					}
					case 2: // all floor 1
					{
						if(bDocCellsFloorOpen[0] == false)
						{
							for(new i = 0; i < 16; i++)
							{
								OpenDocCells(i, 1);
							}
							bDocCellsFloorOpen[0] = true;
						}
						else if(bDocCellsFloorOpen[0] == true)
						{
							for(new i = 0; i < 16; i++)
							{
								OpenDocCells(i, 0);
							}
							bDocCellsFloorOpen[0] = false;
						}
					}
					case 3: // all floor 2
					{
						if(bDocCellsFloorOpen[1] == false)
						{
							for(new i = 16; i < 31; i++)
							{
								OpenDocCells(i, 1);
							}
							bDocCellsFloorOpen[1] = true;
						}
						else if(bDocCellsFloorOpen[1] == true)
						{
							for(new i = 16; i < 31; i++)
							{
								OpenDocCells(i, 0);
							}
							bDocCellsFloorOpen[1] = false;
						}
					}
				}
			}
			else ShowDocPrisonControls(playerid, 0);
		}
		case DIALOG_DOC_CP_AREA:
		{
			if(response)
			{
				if(listitem == 9)
				{
					if(bDocAreaOpen[9] == false) bDocAreaOpen[9] = true;
					else bDocAreaOpen[9] = false;
				}
				else if(listitem == 10)
				{
					if(bDocAreaOpen[10] == false) bDocAreaOpen[10] = true;
					else bDocAreaOpen[10] = false;
				}
				else
				{
					if(bDocAreaOpen[listitem] == false) OpenDocAreaDoors(listitem, 1);
					else OpenDocAreaDoors(listitem, 0);
				}
				ShowDocPrisonControls(playerid, 4);
			}
			else ShowDocPrisonControls(playerid, 0);
		}
		case DIALOG_DOC_CP_C1F1:
		{
			if(response)
			{
				if(bDocCellOpen[listitem] == false) OpenDocCells(listitem, 1);
				else OpenDocCells(listitem, 0);
				ShowDocPrisonControls(playerid, 2);
			}
			else ShowDocPrisonControls(playerid, 1);
		}
		case DIALOG_DOC_CP_C1F2:
		{
			if(response)
			{
				if(bDocCellOpen[listitem + 16] == false) OpenDocCells(listitem + 16, 1);
				else OpenDocCells(listitem + 16, 0);
				ShowDocPrisonControls(playerid, 3);
			}
			else ShowDocPrisonControls(playerid, 1);
		}
		case DIALOG_DOC_CP_INT:
		{
			if(response)
			{
				ShowPlayerDialogEx(playerid, DIALOG_DOC_CP_INT2, DIALOG_STYLE_INPUT, "DoC Control Panel - Loa noi bo", "Nhap noi dung ben duoi:", "Dang nhap", "Huy");
				switch(listitem)
				{
					case 0: SetPVarInt(playerid, "pPrisonIntercom", 1);
					case 1: SetPVarInt(playerid, "pPrisonIntercom", 2);
					case 2: SetPVarInt(playerid, "pPrisonIntercom", 3);
					default: return 0;
				}
			}
		}
		case DIALOG_DOC_CP_INT2:
		{
			if(response)
			{
				new string[256];
				format(string, sizeof(string), "[Intercom] %s: %s", GetPlayerNameEx(playerid), inputtext);
				switch(GetPVarInt(playerid, "pPrisonIntercom"))
				{
					case 1: 
					{
						foreach(new i: Player)
						{
							if(IsPlayerInRangeOfPoint(i, 90.0, 584.2271,1443.5724,6000.4751) || IsPlayerInRangeOfPoint(i, 90.0, 554.5073,1424.2986,11000.4756) && GetPlayerVirtualWorld(i) != 666) 
							{
								SendClientMessageEx(i, COLOR_YELLOW, string); 
							}
						}
						DeletePVar(playerid, "pPrisonIntercom");
					}
					case 2: 
					{
						foreach(new i: Player)
						{
							if(IsPlayerInRangeOfPoint(i, 90.0, 129.0239,1847.9410,17.6697)) 
							{
								SendClientMessageEx(i, COLOR_YELLOW, string); 
							}
						}
						DeletePVar(playerid, "pPrisonIntercom");
					}
					case 3: 
					{
						foreach(new i: Player)
						{
							if(IsPlayerInRangeOfPoint(i, 90.0, 584.2271,1443.5724,6000.4751) || IsPlayerInRangeOfPoint(i, 90.0, 554.5073,1424.2986,11000.4756) && GetPlayerVirtualWorld(i) != 666 || IsPlayerInRangeOfPoint(i, 90.0, 129.0239,1847.9410,17.6697)) 
							{							
								SendClientMessageEx(i, COLOR_YELLOW, string); 
							}
						}
						DeletePVar(playerid, "pPrisonIntercom");
					}
					default: return 0;
				}
			}
		}
		case DIALOG_LOAD_DETAINEES:
		{
			if(response)
			{
				new stpos = strfind(inputtext, "(");
			    new fpos = strfind(inputtext, ")");
			    new prisoneridstr[4], prisonerid;
			    strmid(prisoneridstr, inputtext, stpos+1, fpos);
			    prisonerid = strval(prisoneridstr);

				new	getVW = GetPlayerVirtualWorld(playerid);
				new	getIW = GetPlayerInterior(playerid);
				new	getVeh = GetPlayerVehicleID(playerid);
				new iVehicleSeat = 0;

				for(new i = 1; i < 9; i++)
				{
					if(IsSeatAvailable(getVeh, i))
					{
						iVehicleSeat = i;
						break;
					}
				}
				LoadPrisoner(playerid, prisonerid, getVeh, iVehicleSeat, getVW, getIW);
			}
		}
    	case DIALOG_STAYPRISON:
    	{
        	if(!response)
        	{
            	strcpy(PlayerInfo[playerid][pPrisonReason], "[IC] [DNRL] Prison Gang", 128);
            	SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da chon o lai tu. Dung /docrelease neu muon ket thuc thu an.");
            	PlayerInfo[playerid][pJailTime] = 9999999;
        	}
        	else
        	{
            	ReleasePlayerFromPrison(playerid);
        	}
    	}
    	case DIALOG_PRISONCREDS:
    	{
        	if(response)
        	{
            	switch(listitem)
            	{
           	 		case 5:
                	{
                	    if(PlayerInfo[playerid][pPrisonCredits] >= 10)
                	    {
							PlayerInfo[playerid][pCigar] = 1;
							PlayerInfo[playerid][pPrisonCredits] -= 10;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

							SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua thuoc la tai prison shop voi gia 10 credits.");
						}
					 	else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
                	case 0:
                	{
                	    if(PlayerInfo[playerid][pPrisonCredits] >= 5)
						{
                    		if(PlayerInfo[playerid][pDice] >= 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co xuc xac!");

							PlayerInfo[playerid][pDice] = 1;
							PlayerInfo[playerid][pPrisonCredits] -= 5;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

							SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua xuc xac tai prison shop voi gia 5 credits.");
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
                	case 1:
                	{
                	    if(PlayerInfo[playerid][pPrisonCredits] >= 5)
						{
                	    	PlayerInfo[playerid][pPaper] += 1;
							PlayerInfo[playerid][pPrisonCredits] -= 5;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

							SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua giay tai prison shop voi gia 5 credits.");
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
                	case 6:
                	{
                    	if(PlayerInfo[playerid][pCDPlayer] >= 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co MP3!");

                    	if(PlayerInfo[playerid][pPrisonCredits] >= 50)
                    	{
							PlayerInfo[playerid][pCDPlayer] = 1;
							PlayerInfo[playerid][pPrisonCredits] -= 50;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

							SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua MP3 Player tai prison shop voi gia 50 credits.");
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
                	case 7:
                	{

                    	if(PlayerInfo[playerid][pPrisonCredits] >= 250)
                    	{
                    		SetPVarInt(playerid, "pPrisonSelectingSkin", 1);
							switch(PlayerInfo[playerid][pSex])
							{
	                    		case 1: return ShowModelSelectionMenuEx(playerid, g_aMaleSkins, sizeof(g_aMaleSkins), "Skin Model", PRISON_SKINSELECT, -16.0, 0.0, -55.0);
								case 2: return ShowModelSelectionMenuEx(playerid, g_aFemaleSkins, sizeof(g_aFemaleSkins), "Skin Model", PRISON_SKINSELECT, -16.0, 0.0, -55.0);
               				}
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
                	case 2:
                	{
                	    if(PlayerInfo[playerid][pPrisonCredits] >= 5)
                	    {
                	        if(GetPVarInt(playerid, "pPrisonSoap") >= 5) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chi co the mang nam banh xa phong cung luc!");

							SetPVarInt(playerid, "pPrisonSoap", GetPVarInt(playerid, "pPrisonSoap") + 1); // these need to be added to the db and the enum
							PlayerInfo[playerid][pPrisonCredits] -= 5;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

							SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua mot banh xa phong tai prison shop voi gia 5 credits.");
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
                	case 3:
                	{
                	    if(PlayerInfo[playerid][pPrisonCredits] >= 5)
                	    {

							SetPVarInt(playerid, "pPrisonSugar", GetPVarInt(playerid, "pPrisonSugar") + 1); // these need to be added to the db and the enum
							PlayerInfo[playerid][pPrisonCredits] -= 5;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

							SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua mot goi duong tai prison shop voi gia 5 credits.");
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
                	case 4:
                	{
                	    if(PlayerInfo[playerid][pPrisonCredits] >= 5)
                	    {
                	        if(GetPVarInt(playerid, "pPrisonBread") >= 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chi co the mang mot o banh mi cung luc!");

							SetPVarInt(playerid, "pPrisonBread", 1); // these need to be added to the db and the enum
							PlayerInfo[playerid][pPrisonCredits] -= 10;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

							SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua mot o banh mi tai prison shop voi gia 10 credits.");
						}
						else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong du prison credits!");
                	}
            	}
			}
        }
	}
	return 0;
}

CMD:bail(playerid, params[])
{
	if(PlayerInfo[playerid][pJailTime] > 0)
	{
		if(PlayerInfo[playerid][pBailPrice] > 0)
		{
			if(GetPlayerCash(playerid) > PlayerInfo[playerid][pBailPrice])
			{
				new string[128];

				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da tu bao lanh voi gia $%d.", PlayerInfo[playerid][pBailPrice]);
				GivePlayerCash(playerid, -PlayerInfo[playerid][pBailPrice]);
				PlayerInfo[playerid][pBailPrice] = 0;
				WantLawyer[playerid] = 0; CallLawyer[playerid] = 0;
				PlayerInfo[playerid][pJailTime] = 1;

				format(string, sizeof string, "%s has bailed themselves out for $%s.", GetPlayerNameEx(playerid), number_format(PlayerInfo[playerid][pBailPrice]));
 				GroupLog(2, string); // Prison Group ID (September 2015).
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du tien bao lanh.");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co muc tien bao lanh.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o trong tu.");
	}
	return 1;
}

CMD:docarrest(playerid, params[])
{
	new giveplayerid, time, fine;
	if(!IsACop(playerid)) SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc faction LEO. ");
	else if(!IsAtArrestPoint(playerid, 2)) SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o diem bat giu DoC Prison." );
	else if(sscanf(params, "udd", giveplayerid, time, fine))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /docarrest [playerid] [time] [fine]");
		return 1;
	}
	else
	{
   		new string[256];
   		new totalwealth = PlayerInfo[giveplayerid][pCash] + PlayerInfo[giveplayerid][pAccount];
		if(!IsPlayerConnected(giveplayerid)) SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		else if(!ProxDetectorS(5.0, playerid, giveplayerid)) SendClientMessageEx(playerid, COLOR_GREY, "Ban o du gan nghi pham.");
		else if(PlayerInfo[giveplayerid][pWantedLevel] < 1 && PlayerInfo[playerid][pMember] != 12) SendClientMessageEx(playerid, COLOR_GREY, "Nguoi nay phai co it nhat mot sao truy na.");
		else if(time > 60 || time < 5)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Thoi gian phai tu 5-60 phut.");
		}
		else if(fine > 250000 || fine < 0)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Tien phat phai tu $0 - $250,000");
		}
		else if(totalwealth < 250000 && fine > 50000)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Ban chi co the phat nguoi nay $50, 000.");
		}
		else {
			SetPVarInt(playerid, "Arrest_Price", fine);
			SetPVarInt(playerid, "Arrest_Time", time);
			SetPVarInt(playerid, "Arrest_Bail", 1);
			SetPVarInt(playerid, "Arrest_BailPrice", fine*2);
			SetPVarInt(playerid, "Arrest_Suspect", giveplayerid);
			SetPVarInt(playerid, "Arrest_Type", 2);
			format(string, sizeof(string), "Hay viet bao cao ngan ve cach %s hanh xu khi bi bat.\n\nBao cao phai dai tu 30 den 128 ky tu.", GetPlayerNameEx(giveplayerid));
			ShowPlayerDialogEx(playerid, DIALOG_ARRESTREPORT, DIALOG_STYLE_INPUT, "Bao cao bat giu", string, "Gui", "");
	    }
	}
	return 1;
}

CMD:arrest(playerid, params[])
{
	new giveplayerid, time, fine;
	if(!IsACop(playerid)) {
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc faction LEO. ");
	}
	else if(!IsAtArrestPoint(playerid, 0) && !IsAtArrestPoint(playerid, 1)) {
 		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o diem bat giu." );
 	} else if(sscanf(params, "udd", giveplayerid, time, fine))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /arrest [playerid] [time] [fine]");
		return 1;
	}

	else {


   		new	string[256], totalwealth;
		totalwealth = PlayerInfo[giveplayerid][pCash] + PlayerInfo[giveplayerid][pAccount];
		if(!IsPlayerConnected(giveplayerid)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		}
		else if(!ProxDetectorS(5.0, playerid, giveplayerid)) {
		    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o du gan nghi pham.");
		}
		else if(time > 30 || time < 5)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Thoi gian phai tu 5-30 phut.");
		}
		else if(fine > 250000 || fine < 0)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Tien phat phai tu $0 - $250,000");
		}
		else if(PlayerInfo[giveplayerid][pWantedLevel] < 1 && !IsAJudge(playerid)) {
		    SendClientMessageEx(playerid, COLOR_GREY, "Nguoi nay phai co it nhat mot sao truy na.");
		}
		else if(totalwealth < 250000 && fine > 50000)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Ban chi co the phat nguoi nay $50, 000.");
		}
		else {
			SetPVarInt(playerid, "Arrest_Price", fine);
			SetPVarInt(playerid, "Arrest_Time", time);
			SetPVarInt(playerid, "Arrest_Bail", 1);
			SetPVarInt(playerid, "Arrest_BailPrice", fine*2);
			SetPVarInt(playerid, "Arrest_Suspect", giveplayerid);
			SetPVarInt(playerid, "Arrest_Type", 0);
			format(string, sizeof(string), "Hay viet bao cao ngan ve cach %s hanh xu khi bi bat.\n\nBao cao phai dai tu 30 den 128 ky tu.", GetPlayerNameEx(giveplayerid));
			ShowPlayerDialogEx(playerid, DIALOG_ARRESTREPORT, DIALOG_STYLE_INPUT, "Bao cao bat giu", string, "Gui", "");
	    }
	}
	return 1;
}

CMD:listprisoners(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	new szInmates[1024],
		szString[20],
		id;
	if(sscanf(params, "d", id)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /listprisoners [arrestpoint id]");
	foreach(new i : Player)
	{
		if((GetPVarInt(i, "ArrestPoint") == id + 1) && PlayerInfo[i][pJailTime] > 0)
		{
			format(szInmates, sizeof(szInmates), "%s\n* [%d] Ten tu nhan: %s", szInmates, i, GetPlayerNameEx(i));
		}
	}
	if(strlen(szInmates) == 0) format(szInmates, sizeof(szInmates), "Buong tam giam trong!");
	format(szString, sizeof(szString), "Buong %d", id);
	ShowPlayerDialogEx(playerid, DIALOG_DOC_INMATES, DIALOG_STYLE_LIST, szString, szInmates, "Dong", "");

	return 1;
}

CMD:inmates(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	ListInmates(playerid);
	return 1;
}

ListInmates(playerid)
{
	new szInmates[2000], IsoString[24], BailString[50], TimeString[50];

	foreach(new i : Player)
	{
		if(PlayerInfo[i][pJailTime] > 0 && strfind(PlayerInfo[i][pPrisonReason], "[IC]", true) != -1)
		{
			if(PlayerInfo[i][pIsolated] >= 1) 
			{
				if(GetPlayerVirtualWorld(i) == 666) {
					format(IsoString, sizeof(IsoString), "[OOC-ISO] ");
				}
				else { format(IsoString, sizeof(IsoString), "[ISO] "); }
			}
			else format(IsoString, sizeof(IsoString), "");

			if(PlayerInfo[i][pBailPrice]) 
			{
				format(BailString, sizeof(BailString), "| Bao lanh: $%s", number_format(PlayerInfo[i][pBailPrice]));
			}
			else format(BailString, sizeof(BailString), "", number_format(PlayerInfo[i][pBailPrice]));

			if(strfind(PlayerInfo[i][pPrisonReason], "[DNRL]", true) != -1)
			{
				format(TimeString, sizeof(TimeString), "Chung than");
			}
			else format(TimeString, sizeof(TimeString), "%s", TimeConvert(PlayerInfo[i][pJailTime]));

			format(szInmates, sizeof(szInmates), "%s\n* %s%s: %s | Buong:%d | Credits: %d %s", szInmates, IsoString, GetPlayerNameEx(i), TimeString, PlayerInfo[i][pPrisonCell], PlayerInfo[i][pPrisonCredits], BailString);
		}
	}
	if(strlen(szInmates) == 0) format(szInmates, sizeof(szInmates), "Khong co tu nhan");
	ShowPlayerDialogEx(playerid, DIALOG_DOC_INMATES, DIALOG_STYLE_LIST, "So theo doi tu nhan DOC", szInmates, "Dong", "");
}

CMD:loadprisoners(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	if(GetArrestPointID(playerid) == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan diem bat giu.");
	new	getVeh = GetPlayerVehicleID(playerid);

	if(GetVehicleModel(getVeh) == 431 || GetVehicleModel(getVeh) == 427)
	{
		ListDetainees(playerid);
	}
	else SendClientMessage(playerid, COLOR_WHITE, "Ban can ngoi trong xe bus de cho tu nhan.");
	return 1;
}

CMD:deliverinmates(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	if(!IsPlayerInRangeOfPoint(playerid, 4, -2053.6279,-198.0207,15.0703)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o diem giao tu nhan doc");
	foreach(new i : Player)
	{
		if(IsPlayerInVehicle(i, GetPlayerVehicleID(playerid)) && GetPlayerVehicleSeat(i) != 0)
		{
			new rand = random(sizeof(DocPrison));
			SetPlayerFacingAngle(i, 0);
			SetPlayerPos(i, DocPrison[rand][0], DocPrison[rand][1], DocPrison[rand][2]);
			DeletePVar(i, "IsFrozen");
			TogglePlayerControllable(i, true);
			SetPlayerInterior(i, 10);
			SetPlayerVirtualWorld(i, 0);
			PlayerInfo[i][pVW] = 0;
			Player_StreamPrep(i, DocPrison[rand][0], DocPrison[rand][1], DocPrison[rand][2], FREEZE_TIME);
		}
	}
	return 1;
}

CMD:getinmatefood(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 8, 555.8644,1485.1359,6000.4258))
	{
		new string[64];
		if(GetPVarInt(playerid, "inmatefood") < 5)
		{
			SetPVarInt(playerid, "inmatefood", 5);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			SetPlayerAttachedObject(playerid, 9, 2767, 6, 0.195999, 0.042999, -0.191, -108.6, 168.6, -83.4999);
			format(string, sizeof(string), "* %s da lay mot khay thuc an.", GetPlayerNameEx(playerid));
			ProxDetector(4.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khay cua ban khong the chua them thuc an.");
		}
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o Prison Cafe!");
	return 1;
}

CMD:dropfoodtray(playerid, params[])
{
	new string[64];
	if(GetPVarInt(playerid, "inmatefood") > 0 || GetPVarInt(playerid, "carryingfood") > 0)
	{
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		RemovePlayerAttachedObject(playerid, 9);
		format(string, sizeof(string), "* %s da bo khay thuc an xuong.", GetPlayerNameEx(playerid));
		ProxDetector(4.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		DeletePVar(playerid, "inmatefood");
		DeletePVar(playerid, "carryingfood");
		DeletePVar(playerid, "OfferedMealTo");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co khay con thuc an.");
	}
	return 1;
}

CMD:offerinmatefood(playerid, params[])
{
	new iGiveTo;
	if(sscanf(params, "u", iGiveTo)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /offerinmatefood [playerid]");
	else if(iGiveTo == playerid) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong the tu moi minh an.");
	else if(!IsPlayerConnected(iGiveTo)) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi do chua ket noi");
	//else if(GetPVarInt(playerid, "OfferingMeal") == 1) return SendClientMessageEx(playerid, COLOR_WHITE, "You may only offer food to one person at a time.");
	else if(!PlayerInfo[iGiveTo][pJailTime]) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban chi co the moi tu nhan an.");
	else if(!GetPVarInt(playerid, "inmatefood")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co thuc an trong tu de moi.");
	else if(ProxDetectorS(5.0, playerid, iGiveTo))
	{
		if(GetPVarInt(playerid, "OfferingMeal") == 1) { // added as a bug report fix
			new iOfferingToOld = GetPVarInt(playerid, "OfferedMealTo");
			DeletePVar(iOfferingToOld, "OfferedMeal");
			DeletePVar(iOfferingToOld, "OfferedMealBy");
			DeletePVar(playerid, "OfferingMeal");
			DeletePVar(playerid, "OfferedMealTo");
		}

		SetPVarInt(iGiveTo, "OfferedMeal", 1);
		SetPVarInt(iGiveTo, "OfferedMealBy", playerid);
		SetPVarInt(playerid, "OfferingMeal", 1);
		SetPVarInt(playerid, "OfferedMealTo", iGiveTo);
		SendClientMessageEx(iGiveTo, COLOR_LIGHTBLUE, "%s moi ban mot bua an. Dung /acceptjailfood de nhan.", GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da moi %s thuc an trong tu", GetPlayerNameEx(iGiveTo));
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o gan nguoi choi do.");
	return 1;
}

CMD:acceptjailfood(playerid, params[])
{
	new iOffering = GetPVarInt(playerid, "OfferedMealBy"),
		string[101];
	if(GetPVarInt(playerid, "OfferedMeal") == 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong ai moi ban an.");
	else if(!IsPlayerConnected(GetPVarInt(playerid, "OfferedMealBy"))) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi moi ban an da ngat ket noi.");
	else if(ProxDetectorS(5.0, playerid, iOffering))
	{
		SetPVarInt(iOffering, "inmatefood", GetPVarInt(iOffering, "inmatefood") - 1);
		if(!GetPVarInt(iOffering, "inmatefood")) {
			RemovePlayerAttachedObject(iOffering, 9);
			SetPlayerSpecialAction(iOffering, SPECIAL_ACTION_NONE);
		}
		if (PlayerInfo[playerid][pFitness] >= 3)
		{
			PlayerInfo[playerid][pFitness] -= 3;
		}
		else
		{
			PlayerInfo[playerid][pFitness] = 0;
		}
		DeletePVar(playerid, "OfferedMeal");
		DeletePVar(playerid, "OfferedMealBy");
		DeletePVar(iOffering, "OfferingMeal");
		DeletePVar(iOffering, "OfferedMealTo");
		format(string, sizeof(string), "* %s nhan dia thuc an tu %s va bat dau an.", GetPlayerNameEx(playerid), GetPlayerNameEx(iOffering));
		ProxChatBubble(playerid, string);
		ProxDetector(4.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		//PlayAnimEx(playerid, "FOOD", "EAT_Burger", 4.1, 0, 1, 0, 4000, 1);
		PlayAnimEx(playerid, "FOOD", "EAT_Burger", 4.0, false, false, false, true, 0, 0);
		SetTimerEx("ClearAnims", 3000, false, "d", playerid);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o gan nguoi moi an.");
	return 1;
}

CMD:getfood(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 8, 555.8644,1485.1359,6000.4258))
	{
		new string[94];
		if(GetPVarInt(playerid, "carryingfood") < 1)
		{
			SetPVarInt(playerid, "carryingfood", 1);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			SetPlayerAttachedObject(playerid, 9, 2767, 6, 0.195999, 0.042999, -0.191, -108.6, 168.6, -83.4999);
			format(string, sizeof(string), "* %s voi tay den quay, lay mot khay thuc an.", GetPlayerNameEx(playerid));
			ProxDetector(4.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Khay cua ban khong the chua them thuc an.");
		}
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o Prison Cafe!");
	return 1;
}

CMD:eatfood(playerid, params[])
{
	if(GetPVarInt(playerid, "carryingfood") == 1)
	{
		new string[94];
		if (PlayerInfo[playerid][pFitness] >= 3)
		{
			PlayerInfo[playerid][pFitness] -= 3;
		}
		else
		{
			PlayerInfo[playerid][pFitness] = 0;
		}
		format(string, sizeof(string), "* %s lay thuc an tu khay va an.", GetPlayerNameEx(playerid));
		ProxDetector(4.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		DeletePVar(playerid, "carryingfood");
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		PlayAnimEx(playerid, "FOOD", "EAT_Burger", 4.0, false, false, false, true, 0, 0);
		SetTimerEx("ClearAnims", 3000, false, "d", playerid);
		RemovePlayerAttachedObject(playerid, 9);

	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong cam khay thuc an");
	return 1;
}

CMD:extendsentence(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	new iTargetID,
		iExtended,
		string[64];
	if(sscanf(params, "ud", iTargetID, iExtended)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /extendsentence [playerid] [percentage to extend (1 - 30)]");
	else if(strfind(PlayerInfo[iTargetID][pPrisonReason], "[IC]", true) == -1)  return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do khong o IC Jail.");
	else if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Nguoi do chua ket noi.");
	else if(iTargetID == playerid) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Khong the dung lenh nay cho chinh minh.");
	else if(strfind(PlayerInfo[iTargetID][pPrisonReason], "[EXT]", true) != -1) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do da duoc tang an tu.");
	else if(iExtended >= 1 && iExtended <= 30)
	{
		new StartJail = PlayerInfo[iTargetID][pJailTime];
		new Float:EndJail;
		new Float:Manip;
		Manip = 1.0 + (float(iExtended) / 100);
		EndJail = StartJail * Manip;
		PlayerInfo[iTargetID][pJailTime] = floatround(EndJail);
		SendClientMessageEx(iTargetID, COLOR_RED, "%s da tang an tu cua ban them %d percent.", GetPlayerNameEx(playerid), iExtended);
		SendClientMessageEx(playerid, COLOR_RED, "Ban da tang an tu cua %s them %d percent.", GetPlayerNameEx(iTargetID), iExtended);
		SendClientMessageEx(playerid, COLOR_RED, "Thoi gian cu: %s ------ Thoi gian moi: %s", TimeConvert(StartJail), TimeConvert(PlayerInfo[iTargetID][pJailTime]));
		strcat(PlayerInfo[iTargetID][pPrisonReason], "[EXT]", 128);

		format(string, sizeof string, "%s has extended %s's sentence by %d percent. (Original: %s, New: %s)", GetPlayerNameEx(playerid), GetPlayerNameExt(iTargetID), iExtended, TimeConvert(StartJail), TimeConvert(PlayerInfo[iTargetID][pJailTime]));
 		GroupLog(PlayerInfo[playerid][pMember], string);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Ty le tang khong duoc duoi 1 hoac tren 10.");
	return 1;
}

CMD:reducesentence(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	new iTargetID,
		iReduce,
		string[64];
	if(sscanf(params, "ud", iTargetID, iReduce)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /reducesentence [playerid] [percentage to reduce (1 - 30)]");
	else if(strfind(PlayerInfo[iTargetID][pPrisonReason], "[IC]", true) == -1)  return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do khong o IC Jail.");
	else if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Nguoi do chua ket noi.");
	else if(iTargetID == playerid) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Khong the dung lenh nay cho chinh minh.");
	else if(strfind(PlayerInfo[iTargetID][pPrisonReason], "[RED]", true) != -1) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do da duoc giam an.");
	else if(iReduce >= 1 && iReduce <= 30)
	{
		new StartJail = PlayerInfo[iTargetID][pJailTime];
		new Float:EndJail;
		new Float:Manip;
		Manip = 1.0 - (float(iReduce) / 100);
		EndJail = StartJail * Manip;
		PlayerInfo[iTargetID][pJailTime] = floatround(EndJail);
		SendClientMessageEx(iTargetID, COLOR_RED, "%s da giam an tu cua ban di %d percent.", GetPlayerNameEx(playerid), iReduce);
		SendClientMessageEx(playerid, COLOR_RED, "Ban da giam an tu cua %s di %d percent.", GetPlayerNameEx(iTargetID), iReduce);
		SendClientMessageEx(playerid, COLOR_RED, "Thoi gian cu: %s ------ Thoi gian moi: %s", TimeConvert(StartJail), TimeConvert(PlayerInfo[iTargetID][pJailTime]));
		strcat(PlayerInfo[iTargetID][pPrisonReason], "[RED]", 128);

		format(string, sizeof string, "%s has reduced %s's sentence by %d percent. (Original: %s, New: %s)", GetPlayerNameEx(playerid), GetPlayerNameExt(iTargetID), iReduce, TimeConvert(StartJail), TimeConvert(PlayerInfo[iTargetID][pJailTime]));
 		GroupLog(PlayerInfo[playerid][pMember], string);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Ty le giam khong duoc duoi 1 hoac tren 10.");

	return 1;
}

CMD:isolateinmate(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	new iTargetID,
		iCellID,
		string[128];

	if(sscanf(params, "ud", iTargetID, iCellID)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /isolateinmate [playerid] [cellid]");
	else if(iTargetID == playerid) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Khong the dung lenh nay cho chinh minh.");
	else if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Nguoi do chua ket noi.");
	else if(strfind(PlayerInfo[iTargetID][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do khong o IC Jail.");
	else if(!(0 <= iCellID < sizeof(DocIsolation))) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Buong biet giam hop le [0-24]");
	else if(PlayerInfo[iTargetID][pIsolated] == 0)
	{
		DocIsolate(iTargetID, iCellID, 0);

		SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "Ban da bi %s dua vao biet giam.", GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da dua %s vao biet giam.", GetPlayerNameEx(iTargetID));

		format(string, sizeof string, "%s has sent %s to isolation.", GetPlayerNameEx(playerid), GetPlayerNameExt(iTargetID));
 		GroupLog(PlayerInfo[playerid][pMember], string);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do da o trong biet giam.");

	return 1;
}

CMD:unisolateinmate(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	new iTargetID,
		string[128];

	if(sscanf(params, "u", iTargetID)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /unisolateinmate [playerid]");
	else if(strfind(PlayerInfo[iTargetID][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do khong o IC Jail");
	else if(iTargetID == playerid) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Khong the dung lenh nay cho chinh minh.");
	else if(PlayerInfo[iTargetID][pIsolated] == 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do khong o biet giam");
	else if(IsPlayerConnected(iTargetID))
	{
		PlayerInfo[iTargetID][pIsolated] = 0;
		PlayerInfo[iTargetID][pVW] = 0;

		SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "Ban da duoc %s dua ra khoi biet giam.", GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da dua %s ra khoi biet giam.", GetPlayerNameEx(iTargetID));

		format(string, sizeof string, "%s has brought %s back from isolation.", GetPlayerNameEx(playerid), GetPlayerNameExt(iTargetID));
 		GroupLog(PlayerInfo[playerid][pMember], string);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Nguoi do chua ket noi.");
	return 1;
}

/*CMD:joinjailboxing(playerid, params[])
{
	if(IsPlayerAtJailBoxing(playerid))
	{
		if(GetPVarInt(playerid, "_InJailBoxing") != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "You're already in a boxing arena. Use /leavejailboxing to leave.");
		else if(arrJailBoxingData[GetClosestJailBoxingRing(playerid)][bInProgress] == true) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are unable to join a boxing match that is in progress.");
		else SetPlayerIntoJailBoxing(playerid);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "You are not in range of a jail boxing ring.");

	return 1;
}

CMD:leavejailboxing(playerid, params[])
{
	if(GetPVarInt(playerid, "_InJailBoxing") == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not in a boxing arena. Please use /joinjailboxing to join one.");
	else if(arrJailBoxingData[GetClosestJailBoxingRing(playerid)][bInProgress] == true) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are unable to leave a boxing match that is in progress.");
	else
	{
		RemoveFromJailBoxing(playerid);
		SendClientMessageEx(playerid, COLOR_WHITE, "You have withdrawn yourself from the boxing arena queue.");
	}
	return 1;
}*/

/*CMD:startbrawl(playerid, params[])
{
	new iTargetID,
		string[MAX_PLAYER_NAME + 35];

	if(sscanf(params, "u", iTargetID)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /startbrawl [playerid]");
	else if(strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_WHITE, "You must be in IC jail to do this.");
	else if(!ProxDetectorS(8.0, playerid, iTargetID)) return SendClientMessageEx(playerid, COLOR_WHITE, "You are not in range of that player.");
	else if(IsPlayerConnected(iTargetID))
	{
		SetPVarInt(playerid, "_InJailBrawl", iTargetID + 1);
		SetPVarInt(iTargetID, "_InJailBrawl", playerid + 1);

		format(string, sizeof(string), "You have initiated a brawl with %s", GetPlayerNameEx(iTargetID));
		SendClientMessageEx(playerid, COLOR_RED, string);

		format(string, sizeof(string), "%s has initiated a brawl with you", GetPlayerNameEx(playerid));
		SendClientMessageEx(iTargetID, COLOR_RED, string);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "That player is not connected.");

	return 1;
}*/

CMD:docjudgesubpoena(playerid, params[])
{
	new iTargetID,
		szCaseName[128];

	if(sscanf(params, "us[128]", iTargetID, szCaseName)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /docjudgesubpoena [playerid] [case reason]");
	if(!IsPlayerConnected(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Nguoi choi do chua ket noi");
	if(!IsPlayerInRangeOfPoint(playerid, 15, 525.86, 1427.05, 11001.28)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o toa an DOC de dung tinh nang nay");
	else if(IsAJudge(playerid))
	{
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da trieu tap %s. Vu an: %s", GetPlayerNameEx(iTargetID), szCaseName);

		SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "Ban da bi %s trieu tap. Vu an %s", GetPlayerNameEx(playerid), szCaseName);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban phai la judge de dung lenh nay");
	return 1;
}

CMD:docjudgecharge(playerid, params[])
{
	new iTargetID,
		iTime,
		iFine,
		szCountry[5],
		szReason[128],
		szCrime[128],
		szMessage[128];

	if(sscanf(params, "udds[128]", iTargetID, iTime, iFine, szReason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /docjudgecharge [playerid] [time] [fine] [reason]");
	if(!IsPlayerInRangeOfPoint(playerid, 15, 525.86, 1427.05, 11001.28)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o toa an DOC de dung tinh nang nay");
	if(!IsPlayerConnected(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Nguoi choi do chua ket noi");
	if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai la judge de dung lenh nay");
	if(ProxDetectorS(14.0, playerid, iTargetID))
	{
		PlayerInfo[iTargetID][pWantedJailTime] += iTime;
		PlayerInfo[iTargetID][pWantedJailFine] += iFine;
		if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 1)
		{
			format(szCountry, sizeof(szCountry), "[SA] ");
		}
		else if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 2)
		{
			format(szCountry, sizeof(szCountry), "[NE] ");
		}
		strcat(szCrime, szCountry);
		strcat(szCrime, szReason);
		AddCrime(playerid, iTargetID, szCrime);

		SendClientMessageEx(iTargetID, COLOR_LIGHTRED, "Ban da pham toi ( %s ). Nguoi bao: %s.", szCrime, GetPlayerNameEx(playerid));

		SendClientMessageEx(iTargetID, COLOR_YELLOW, "Muc truy na hien tai: %d", PlayerInfo[iTargetID][pWantedLevel]);

		format(szMessage, sizeof(szMessage), "Ban da cao buoc %s pham toi.", GetPlayerNameEx(iTargetID));
		SendClientMessage(playerid, COLOR_LIGHTRED, szMessage);

		format(szMessage, sizeof(szMessage), "%s: %i phut. Phat: %i", szCrime, iTime, iFine);
		SendClientMessage(playerid, COLOR_LIGHTRED, szMessage);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Ban phai o gan nguoi choi do");
	return 1;
}

CMD:docjudgesentence(playerid, params[])
{
	new iSuspect,
		string[256];

	if(sscanf(params, "u", iSuspect)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /docjudgesentence [suspect]");
	if(!IsPlayerInRangeOfPoint(playerid, 15, 525.86, 1427.05, 11001.28)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o toa an DOC de dung tinh nang nay");
	if(!IsPlayerConnected(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Nguoi choi do chua ket noi");
	if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai la judge de dung lenh nay");
	if(ProxDetectorS(14.0, playerid, iSuspect))
	{
		SetPVarInt(playerid, "Arrest_Price", PlayerInfo[iSuspect][pWantedJailFine]);
		SetPVarInt(playerid, "Arrest_Time", PlayerInfo[iSuspect][pWantedJailTime]);
		SetPVarInt(playerid, "Arrest_Suspect", iSuspect);
		SetPVarInt(playerid, "Arrest_Type", 3);
		format(string, sizeof(string), "Hay viet bao cao ngan ve cach %s hanh xu trong qua trinh xu ly.\n\nBao cao phai dai tu 30 den 128 ky tu.", GetPlayerNameEx(iSuspect));
		ShowPlayerDialogEx(playerid, DIALOG_ARRESTREPORT, DIALOG_STYLE_INPUT, "Bao cao bat giu", string, "Gui", "");
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "Ban phai o gan nguoi choi do");

	return 1;
}

CMD:jailcuff(playerid, params[])
{
	if(IsACop(playerid))
	{
		if(GetPVarInt(playerid, "Injured") == 1 || GetPVarInt(playerid, "jailcuffs") > 0 || PlayerCuffed[ playerid ] >= 1 || PlayerInfo[ playerid ][ pJailTime ] > 0 || PlayerInfo[playerid][pHospital] > 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
			return 1;
		}

		if(PlayerInfo[playerid][pHasCuff] < 1)
		{
		    SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co cong tay!");
		    return 1;
		}

		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /jailcuff [player]");
		if(IsPlayerConnected(giveplayerid))
		{
			if (ProxDetectorS(8.0, playerid, giveplayerid))
			{
				if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the tu cong minh!"); return 1; }
				if(GetPlayerSpecialAction(giveplayerid) == SPECIAL_ACTION_HANDSUP || PlayerCuffed[giveplayerid] == 1 || GetPVarInt(playerid, "pBagged") >= 1)
				{
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban da bi %s cong tay.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da cong tay %s den khi duoc thao.", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "* %s cong tay %s va siet chat cong.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					GameTextForPlayer(giveplayerid, "~r~Da bi cong", 2500, 3);
					ClearAnimationsEx(giveplayerid);
					TogglePlayerControllable(giveplayerid, false);
					SetPlayerSpecialAction(giveplayerid, SPECIAL_ACTION_CUFFED);
					TogglePlayerControllable(giveplayerid, true);
					DeletePVar(playerid, "pBagged");
					SetPVarInt(giveplayerid, "jailcuffs", 1);
				}
				else if(GetPVarType(giveplayerid, "IsTackled"))
				{
				    format(string, sizeof(string), "* %s lay cong tu that lung va co gang cong tay %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					BeginCuffTackled(playerid, giveplayerid);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong bi khong che!");
					return 1;
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
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nhan vien hanh phap.");
	}
	return 1;
}

// WINTERFIELD: VERSION .278 PRISON SYSTEM

CMD:prisonhelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_WHITE, "-------------------------------------------------------------------------------------------------------------------------------------");
 	SendClientMessageEx(playerid, COLOR_GREY, "CHUNG: /prisonhelp, /getfood, /eatfood, /dropfoodtray, /acceptinmatefood, /jailcall, /jailhangup, /prisoncraft, /prisoninv(entory)");
 	if(strfind(PlayerInfo[playerid][pPrisonReason], "[DNRL]", true) != -1) { SendClientMessageEx(playerid, COLOR_GREY, "AN CHUNG THAN: /docrelease"); }
 	if(IsADocGuard(playerid)) { 
 		SendClientMessageEx(playerid, COLOR_GREY, "GUARD:	/reducesentence, /extendsentence, /(jail)cuff, /(get)(offer)inmatefood, /listprisoners, /inmates, /acceptrelease"); 
 		SendClientMessageEx(playerid, COLOR_GREY, "GUARD:	/denyrelease, /beanbag, /(un)isolateinmate, /oocisolateinmate, /loadinmates, /deliverinmates, /giveprisoncredits"); 
 	}
 	if(IsADocGuard(playerid) && PlayerInfo[playerid][pLeader] != INVALID_GROUP_ID) { 
 		SendClientMessageEx(playerid, COLOR_GREY, "LEADER:	/setbail, /takeprisoncredits, /changeinmatecell, /prisonermotd"); 
 	}
  	if(IsAJudge(playerid)) { SendClientMessageEx(playerid, COLOR_GREY, "JUDGE:	/docjudgesentence, /docjudgecharge, /docjudgesubpoena"); }
   	if(GetPVarInt(playerid, "pPrisonShank") >= 1) { SendClientMessageEx(playerid, COLOR_GREY, "SHANK:	/shank - tang sat thuong khi dam. | Dung duoc 15 lan truoc khi 'hong.'"); }
   	if(GetPVarInt(playerid, "pPrisonCellChisel") >= 1) { SendClientMessageEx(playerid, COLOR_GREY, "BUONG:	/celldeposit, /cellwithdraw"); }
   	if(GetPVarInt(playerid, "pPrisonWine") >= 1 || GetPVarInt(playerid, "pPrisonMWine") >= 1) { SendClientMessageEx(playerid, COLOR_GREY, "WINE:	/finishpruno, /drinkpruno - tang sat thuong khi dam. | Buoc di say ruou."); }
    SendClientMessageEx(playerid, COLOR_WHITE, "-------------------------------------------------------------------------------------------------------------------------------------");
	return 1;
}

CMD:beanbag(playerid, params[])
{
    if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");

    if(GetPlayerWeapon(playerid) == 25)
    {
        new string[128];
    	if(GetPVarInt(playerid, "pBeanBag") >= 1)
    	{
            format(string, sizeof string, "{FF8000}* {C2A2DA}%s nap dan that vao shotgun.", GetPlayerNameEx(playerid));
    		SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 6000);
    		format(string, sizeof string, "{FF8000}> {C2A2DA}%s nap dan that vao shotgun.", GetPlayerNameEx(playerid));
    		SendClientMessage(playerid, COLOR_PURPLE, string);

    		DeletePVar(playerid, "pBeanBag");
    	}
    	else
    	{
    		format(string, sizeof string, "{FF8000}* {C2A2DA}%s nap dan beanbag vao shotgun.", GetPlayerNameEx(playerid));
    		SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 6000);
    		format(string, sizeof string, "{FF8000}> {C2A2DA}%s nap dan beanbag vao shotgun.", GetPlayerNameEx(playerid));
    		SendClientMessage(playerid, COLOR_PURPLE, string);

    		SetPVarInt(playerid, "pBeanBag", 1);
    	}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban can cam shotgun!");
	return 1;
}

CMD:giveprisoncredits(playerid, params[]) // these NEED to show up on /frisk and /inv (only when the player is in prison)
{
	new id, amount, string[128];
    if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");

    if(sscanf(params, "ud", id, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /giveprisoncredits [playerid] [amount]");
    if(strfind(PlayerInfo[id][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi nay khong o trong tu!");
    if(!(0 < amount < 51)) return SendClientMessageEx(playerid, COLOR_GRAD1, "So luong khong hop le (1 - 50).");

    if (ProxDetectorS(16.0, playerid, id))
    {
        if(GetPVarInt(playerid, "pGivePCred") < gettime())
        {
    		format(string, sizeof string, "{FF8000}* {C2A2DA}%s dua cho %s mot it prison credits.", GetPlayerNameEx(playerid), GetPlayerNameEx(id));
    		SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 6000);
    		SendClientMessage(playerid, COLOR_PURPLE, string);
			PlayerInfo[id][pPrisonCredits] += amount; // these need to be added to the db and the enum

			SetPVarInt(playerid, "pGivePCred", gettime() + 10);

			format(string, sizeof string, "%s has gifted %s %d prison credits.", GetPlayerNameEx(playerid), GetPlayerNameEx(id), amount);
			GroupLog(PlayerInfo[playerid][pMember], string);
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban phai cho 10 giay giua cac giao dich prison credits.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "  Ban phai o gan nguoi choi nay.");
    return 1;
}

CMD:takeprisoncredits(playerid, params[])
{
	new id, amount, string[128];
    if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
    if(PlayerInfo[playerid][pLeader] == INVALID_GROUP_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai la lanh dao to chuc.");

    if(sscanf(params, "ud", id, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /takeprisoncredits [playerid] [amount]");
    if(!(0 < amount < 100)) return SendClientMessageEx(playerid, COLOR_GRAD1, "So luong khong hop le (1 - 100).");
    if(amount > PlayerInfo[id][pPrisonCredits]) return SendClientMessageEx(playerid, COLOR_GRAD1, "  Ho khong co du so luong do.");
    if(strfind(PlayerInfo[id][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi nay khong o trong tu!");

    if (ProxDetectorS(16.0, playerid, id))
    {
    	if(GetPVarInt(playerid, "pGivePCred") < gettime())
        {
    		format(string, sizeof string, "{FF8000}* {C2A2DA}%s lay mot it prison credits cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(id));
    		SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 6000);
    		SendClientMessage(playerid, COLOR_PURPLE, string);
			PlayerInfo[id][pPrisonCredits] -= amount; // these need to be added to the db and the enum

			SetPVarInt(playerid, "pGivePCred", gettime() + 10);

			format(string, sizeof string, "%s has taken %d prison credits from %s.", GetPlayerNameEx(playerid), amount, GetPlayerNameEx(id));
			GroupLog(PlayerInfo[playerid][pMember], string);
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban phai cho 10 giay giua cac giao dich prison credits.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "  Ban phai o gan nguoi choi nay.");
    return 1;
}

CMD:changeinmatecell(playerid, params[])
{
	new id, amount;
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
    if(PlayerInfo[playerid][pLeader] == INVALID_GROUP_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai la lanh dao to chuc.");
	if(sscanf(params, "ud", id, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /changeinmatecell [playerid] [cell]");
	if(!(-1 < amount < 30)) return SendClientMessageEx(playerid, COLOR_GRAD1, "So luong khong hop le (0 - 29).");
	if(PlayerInfo[id][pIsolated] >= 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the doi buong cho tu nhan dang biet giam.");
	if(strfind(PlayerInfo[id][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi nay khong o trong tu!");

	PlayerInfo[id][pPrisonCell] = amount;

	SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da dat buong cua %s thanh: %d", GetPlayerNameEx(id), amount);
	SendClientMessageEx(id, COLOR_YELLOW, "Buong cua ban da duoc dat thanh %d boi %s", amount, GetPlayerNameEx(playerid));

	format(szMiscArray, sizeof szMiscArray, "%s has set %s's bail price to $%s.", GetPlayerNameEx(playerid), GetPlayerNameEx(id), PlayerInfo[id][pPrisonCell]);
 	GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
	return 1;
}

CMD:setbail(playerid, params[]) { // Can no longer set negative bail prices & bail price deducted significantly.

	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai thuoc DoC de dung lenh nay.");
	if(PlayerInfo[playerid][pLeader] == INVALID_GROUP_ID) return SendClientMessageEx(playerid, COLOR_GREY, "  Ban phai la lanh dao to chuc.");

	new uPlayer,
		iBail;

	if(sscanf(params, "ud", uPlayer, iBail)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /setbail [player] [amount]");
	if(strfind(PlayerInfo[uPlayer][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi nay khong o trong tu!");

	if(!(0 < iBail <= 15000000)) return SendClientMessageEx(playerid, COLOR_GRAD1, "So luong khong hop le ($1 - $15,000,000).");

	PlayerInfo[uPlayer][pBailPrice] = iBail;

	SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da dat tien bao lanh cua %s thanh: $%s", GetPlayerNameEx(uPlayer), number_format(iBail));
	SendClientMessageEx(uPlayer, COLOR_YELLOW, "Tien bao lanh cua ban duoc dat thanh $%s boi %s", number_format(iBail), GetPlayerNameEx(playerid));

	format(szMiscArray, sizeof szMiscArray, "%s has set %s's bail price to $%s.", GetPlayerNameEx(playerid), GetPlayerNameEx(uPlayer), number_format(PlayerInfo[uPlayer][pBailPrice]));
 	GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
	return 1;
}


CMD:shank(playerid, params[])
{
    if(strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1)
    {
        if(GetPVarInt(playerid, "pPrisonShank") >= 1)
        {
            new string[156];
            if(GetPVarInt(playerid, "pPrisonShankOut") == 1)
            {
                format(string, sizeof string, "{FF8000}> {C2A2DA}%s bi mat cat dao tu che.", GetPlayerNameEx(playerid));
    			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
    			SendClientMessage(playerid, COLOR_PURPLE, string);
                DeletePVar(playerid, "pPrisonShankOut");
                RemovePlayerAttachedObject(playerid, 9);
            }
            else
            {
                format(string, sizeof string, "{FF8000}> {C2A2DA}%s bi mat rut dao tu che.", GetPlayerNameEx(playerid));
    			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
    			SendClientMessage(playerid, COLOR_PURPLE, string);
                SetPVarInt(playerid, "pPrisonShankOut", 1);
                SetPlayerAttachedObject(playerid, 9, 335, 6);
            }
        }
        else return SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong co dao tu che!");
    }
    else SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong o trong tu!");
	return 1;
}

CMD:oocisolateinmate(playerid, params[])
{
	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
	new id, cell, string[128];

	if(sscanf(params, "ud", id, cell)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /oocisolateinmate [playerid] [cellid]");
	else if(id == playerid) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Khong the dung lenh nay cho chinh minh.");
	else if(!IsPlayerConnected(id)) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Nguoi do chua ket noi.");
	else if(strfind(PlayerInfo[id][pPrisonReason], "[IC]", true) == -1) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi do khong o IC Jail.");
	else if(!(0 <= cell < sizeof(DocIsolation))) return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Buong biet giam hop le [0-24]");
	else if(PlayerInfo[id][pIsolated] == 0)
	{
		DocIsolate(id, cell, 1);

		SendClientMessageEx(id, COLOR_LIGHTBLUE, "Ban da bi %s dua vao biet giam OOC.", GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da dua %s vao biet giam OOC.", GetPlayerNameEx(id));

		format(string, sizeof string, "%s has sent %s to OOC isolation.", GetPlayerNameEx(playerid), GetPlayerNameEx(id));
 		GroupLog(PlayerInfo[playerid][pMember], string);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Nguoi choi do da o trong biet giam (ooc).");

	return 1;
}

CMD:docrelease(playerid, params)
{
	if(PlayerInfo[playerid][pJailTime] > 0 && strfind(PlayerInfo[playerid][pPrisonReason], "[DNRL]", true) != -1)
	{
		if(GetPVarInt(playerid, "Injured") == 1 || GetPVarInt(playerid, "jailcuffs") > 0 || GetPVarInt(playerid, "_pBeingReleased") >= 1 || PlayerCuffed[ playerid ] >= 1 || PlayerInfo[playerid][pHospital] > 0)
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
		}

		if(GetPVarInt(playerid, "_pBeingReleased") == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai cho 45 giay truoc khi lam lai.");

		new string[258];
		format( string, sizeof(string), "CANH BAO: Tu nhan %s yeu cau duoc tha. Dung /acceptrelease hoac /denyrelease. Ho se duoc tha sau 45 giay.", GetPlayerNameEx(playerid));
		foreach(new i: Player)
		{
			if(IsADocGuard(i)) { SendClientMessageEx(i, COLOR_RED, string); }
		}
		SetPVarInt(playerid, "_pBeingReleased", 1);
		TogglePlayerControllable(playerid, FALSE);

		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da yeu cau duoc tha tu, dang cho guard chap nhan...");
		SetTimerEx("_ReleaseTimer", 45000, false, "d", playerid);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Chi dung lenh nay khi dang thu an chung than.");
	return 1;
}

CMD:acceptrelease(playerid, params[])
{
    if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
    new id;

    if(sscanf(params, "u", id)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /acceptrelease [player]");

    if(strfind(PlayerInfo[id][pPrisonReason], "[DNRL]", true) != -1 && GetPVarInt(id, "_pBeingReleased") >= 1)
    {
        ReleasePlayerFromPrison(id);
        SendClientMessageEx(playerid, COLOR_GREY, "Ban da chap nhan yeu cau tha tu cua %s.", GetPlayerNameEx(id));

        DeletePVar(id, "_pBeingReleased");

        format(szMiscArray, sizeof szMiscArray, "%s has accepted %s's release request.", GetPlayerNameEx(playerid), GetPlayerNameEx(id));
 		GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
    }
    else SendClientMessage(playerid, COLOR_GRAD1, "Khong the dung lenh nay voi tu nhan chua thu xong an ban dau hoac chua yeu cau duoc tha.");
    return 1;
}

CMD:denyrelease(playerid, params[])
{
    if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");
    new id, reason[128];

    if(sscanf(params, "us[128]", id, reason)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /denyrelease [player] [reason]");

    if(strfind(PlayerInfo[id][pPrisonReason], "[DNRL]", true) != -1 && GetPVarInt(id, "_pBeingReleased") >= 1)
    {
        SendClientMessageEx(playerid, COLOR_GREY, "Ban da tu choi yeu cau tha tu cua %s vi: %s.", GetPlayerNameEx(id), reason);

        SendClientMessageEx(id, COLOR_GREY, "%s da tu choi yeu cau tha tu cua ban. Ly do: %s", GetPlayerNameEx(playerid), reason);

        DeletePVar(id, "_pBeingReleased");

        TogglePlayerControllable(id, TRUE);

        format(szMiscArray, sizeof szMiscArray, "%s has denied %s's release request. Reason: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(id), reason);
 		GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
    }
    else SendClientMessage(playerid, COLOR_GRAD1, "Khong the dung lenh nay voi tu nhan chua thu xong an ban dau hoac chua yeu cau duoc tha.");
    return 1;
}

CMD:prisoncraft(playerid, params[])
{
    if (PlayerInfo[playerid][pJailTime] > 0)
	{
	    if(GetPVarInt(playerid, "Injured") == 1 || GetPVarInt(playerid, "jailcuffs") > 0 || GetPVarInt(playerid, "_pBeingReleased") >= 1 || PlayerCuffed[ playerid ] >= 1 || PlayerInfo[playerid][pHospital] > 0)
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
		}

		new value[32], string[128];
		if(sscanf(params, "s[32]", value))
		{
			SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
   			SendClientMessageEx(playerid, COLOR_YELLOW, "<< Cac mon co the che tao trong tu >>");
			SendClientMessageEx(playerid, COLOR_GRAD1, "shank\t\t\t\t\t\t\t\t\t\tpruno");
			SendClientMessageEx(playerid, COLOR_GRAD1, "radio\t\t\t\t\t\t\t\t\t\tchisel");
			SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /prisoncraft [craftname]");
			return 1;
		}

		if(strcmp(value, "shank", true) == 0)
		{
			if(GetPVarInt(playerid, "pPrisonShank") >= 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co dao tu che.");
			if(PlayerInfo[playerid][pPrisonMaterials] <= 3) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can 4 vat lieu trong tu.");

            format(string, sizeof string, "{FF8000}> {C2A2DA}%s bi mat che tao dao tu che.", GetPlayerNameEx(playerid));
			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
			SendClientMessage(playerid, COLOR_PURPLE, string);

			PlayerInfo[playerid][pPrisonMaterials] -= 3;
			SetPVarInt(playerid, "pPrisonShank", 1);
			SetPVarInt(playerid, "pShankUsages", 15);
	        DeletePVar(playerid, "pPrisonShankOut");
		}

		else if(strcmp(value, "pruno", true) == 0)
		{
			if(GetPVarInt(playerid, "pPrisonWine") >= 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co ruou.");
			if(PlayerInfo[playerid][pPrisonMaterials] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can mot vat lieu trong tu.");
			if(GetPVarInt(playerid, "pPrisonSugar") < 2) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can mua 3 goi duong.");
			if(GetPVarInt(playerid, "pPrisonBread") == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can mua mot o banh mi.");

			if(IsPlayerInCell(playerid))
			{
            	format(string, sizeof string, "{FF8000}> {C2A2DA}%s nhet banh mi vao bon cau va do duong len.", GetPlayerNameEx(playerid));
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
				SendClientMessage(playerid, COLOR_PURPLE, string);

				SendClientMessage(playerid, COLOR_GREY, "Ban da bat dau u pruno. Ruou se san sang sau muoi hai gio. Dung /prisoninv(entory) de xem tien do.");

				PlayerInfo[playerid][pPrisonMaterials] -= 1;
				SetPVarInt(playerid, "pPrisonSugar", GetPVarInt(playerid, "pPrisonSugar") - 3);
				SetPVarInt(playerid, "pPrisonBread", GetPVarInt(playerid, "pPrisonBread") - 1);
				SetPVarInt(playerid, "pPrisonMWine", 1);

				PlayerInfo[playerid][pPrisonWineTime] = gettime()+43200;
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong buong giam cua minh!");
		}

		else if(strcmp(value, "radio", true) == 0)
		{
			if(PlayerInfo[playerid][pPrisonMaterials] < 9) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can muoi vat lieu trong tu.");
			if(PlayerInfo[playerid][pRadio] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co radio.");

			format(string, sizeof string, "{FF8000}> {C2A2DA}%s dung vat lieu che tao radio.", GetPlayerNameEx(playerid));
			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
			SendClientMessage(playerid, COLOR_PURPLE, string);
			PlayerInfo[playerid][pRadio] = 1;

			SendClientMessage(playerid, COLOR_GREY, "Ban da che tao radio. Dung /pr de lien lac.");
		}

		else if(strcmp(value, "chisel", true) == 0)
		{
			if(GetPVarInt(playerid, "pPrisonChisel") >= 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co duc.");
			if(PlayerInfo[playerid][pPrisonMaterials] < 4) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can nam vat lieu trong tu.");

			format(string, sizeof string, "{FF8000}> {C2A2DA}%s dap det kim loai thanh mot vat.", GetPlayerNameEx(playerid));
			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
			SendClientMessage(playerid, COLOR_PURPLE, string);
			SetPVarInt(playerid, "pPrisonChisel", 1);

			SendClientMessage(playerid, COLOR_GREY, "Ban da che tao duc. Nhan Y trong buong giam de dao lo. Duc se mat sau mot lan dung.");

			PlayerInfo[playerid][pPrisonMaterials] -= 5;
		}

		else if(isnull(value))
		{
			SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
			SendClientMessageEx(playerid, COLOR_YELLOW, "<< Cac mon co the che tao trong tu >>");
			SendClientMessageEx(playerid, COLOR_GRAD1, "shank\t\t\t\t\t\t\t\t\t\tpruno");
			SendClientMessageEx(playerid, COLOR_GRAD1, "radio\t\t\t\t\t\t\t\t\t\tchisel");
			SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /prisoncraft [craftname]");
			return 1;
		}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong tu!");
	return 1;
}

CMD:drinkpruno(playerid, params[])
{
    if(PlayerInfo[playerid][pJailTime] > 0)
    {
        if(GetPVarInt(playerid, "pPrisonWine") >= 1)
        {
            new string[256];
    	    SetPVarInt(playerid, "pPrisonWine", GetPVarInt(playerid, "pPrisonWine") - 1);

    	    format(string, sizeof string, "{FF8000}> {C2A2DA}%s uong pruno tu chai.", GetPlayerNameEx(playerid));
			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
			SendClientMessage(playerid, COLOR_PURPLE, string);

			SetPVarInt(playerid, "pWineConsumed", 1);
			ApplyAnimation(playerid, "PED", "WALK_DRUNK", 4.1, true, true, true, true, 1, 1);
			SetPlayerDrunkLevel(playerid, 10000);
			SetTimerEx("_DrinkWineTimer", 30000, false, "d", playerid);

		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong co ruou!");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong tu!");
	return 1;
}

CMD:finishpruno(playerid, params[]) // add to /interact
{
    if(PlayerInfo[playerid][pJailTime] > 0)
    {
        if(GetPVarInt(playerid, "pPrisonMWine") >= 2)
        {
    		if(PlayerInfo[playerid][pPrisonWineTime] <= gettime())
			{
			    if(IsPlayerInCell(playerid))
			    {
			    	new string[256];
					SetPVarInt(playerid, "pPrisonWine", GetPVarInt(playerid, "pPrisonWine") + 1);
					DeletePVar(playerid, "pPrisonMWine");
					SendClientMessage(playerid, COLOR_WHITE, "Ban da co pruno, dung /prisonhelp de hoc cach dung.");

					PlayerInfo[playerid][pPrisonWineTime] = 0;

					format(string, sizeof string, "{FF8000}> {C2A2DA}%s nhung chai vao bon cau, bi mat lay day pruno.", GetPlayerNameEx(playerid));
					SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
					SendClientMessage(playerid, COLOR_PURPLE, string);
				}
				else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong buong cua minh");
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "  Pruno cua ban chua u xong!");
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong u pruno hoac pruno chua u xong!");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong tu!");
	return 1;
}

CMD:celldeposit(playerid, params[])
{
    if(PlayerInfo[playerid][pJailTime] > 0)
    {
    	new value, amount;
     	if(sscanf(params, "dd", value, amount))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /celldeposit [value] [amount]");
			SendClientMessageEx(playerid, COLOR_GREY, "Ma tuy: (1) LSD - (2) Cannabis - (3) Meth - (4) Heroin - (5) Cocaine - (6) Crack - (7) Opium");
			SendClientMessageEx(playerid, COLOR_GREY, "Ma tuy: (8) Ecstasy - (9) Speed - (10) Alcohol - (11) Demerol - (12) Morphine - (13) Haloperidol - (14) Aspirin");
			return 1;
		}
        if(IsPlayerInCell(playerid))
        {
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_WHITE, "So luong phai lon hon mot.");

			if(GetPVarInt(playerid, "pPrisonCellChisel") <= 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban can dung duc tao cho giau do. Neu khong, guard se tim thay.");

			switch(value)
			{
			    case 1 .. 14:
			    {
					new string[255];
			        if(PlayerInfo[playerid][pDrugs][value - 1] >= amount)
			        {
			        	PlayerInfo[playerid][pDrugs][value - 1] -= amount;
			        	PlayerInfo[playerid][p_iPrisonDrug][value - 1] += amount;

			        	format(string, sizeof string, "{FF8000}> {C2A2DA}%s giau ma tuy trong buong giam.", GetPlayerNameEx(playerid));
						SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
						SendClientMessage(playerid, COLOR_PURPLE, string);
					}
					else return SendClientMessage(playerid, COLOR_GREY, "Ban khong co du.");
				}
				default:
				{
				    return SendClientMessageEx(playerid, COLOR_GREY, "Gia tri tu 1-14");
				}
			}
        }
        else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong buong cua minh!");
    }
    else SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong tu!");
	return 1;
}

CMD:cellwithdraw(playerid, params[])
{
    if(PlayerInfo[playerid][pJailTime] > 0)
    {
    	new value, amount;
     	if(sscanf(params, "dd", value, amount))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /prisoncellwithdraw [value] [amount]");
			SendClientMessageEx(playerid, COLOR_GREY, "Ma tuy: (1) LSD - (2) Cannabis - (3) Meth - (4) Heroin - (5) Cocaine - (6) Crack - (7) Opium");
			SendClientMessageEx(playerid, COLOR_GREY, "Ma tuy: (8) Ecstasy - (9) Speed - (10) Alcohol - (11) Demerol - (12) Morphine - (13) Haloperidol - (14) Aspirin");
			return 1;
		}
        if(IsPlayerInCell(playerid))
        {
			if(amount < 1) return SendClientMessageEx(playerid, COLOR_WHITE, "So luong phai lon hon mot.");

			if(GetPVarInt(playerid, "pPrisonCellChisel") <= 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban can dung duc tao cho giau do. Neu khong, guard se tim thay.");

			switch(value)
			{
			    case 1 .. 14:
			    {
					new string[255];
			        if(PlayerInfo[playerid][p_iPrisonDrug][value - 1] >= amount)
			        {
			        	PlayerInfo[playerid][pDrugs][value - 1] += amount;
			        	PlayerInfo[playerid][p_iPrisonDrug][value - 1] -= amount;

			        	format(string, sizeof string, "{FF8000}> {C2A2DA}%s lay ma tuy giau trong buong giam.", GetPlayerNameEx(playerid));
						SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
						SendClientMessage(playerid, COLOR_PURPLE, string);
					}
					else return SendClientMessage(playerid, COLOR_GREY, "Ban khong co du.");
				}
				default:
				{
					return SendClientMessageEx(playerid, COLOR_GREY, "Gia tri tu 1-14");
				}
			}
        }
        else return SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong buong cua minh!");
    }
    else SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong tu!");
	return 1;
}

CMD:prisoninv(playerid, params[])
{
	if(PlayerInfo[playerid][pJailTime] > 0)
	{
		ShowPrisonInventory(playerid);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong tu!");
	return 1;
}

CMD:prisoninventory(playerid, params[])
{
	if(PlayerInfo[playerid][pJailTime] > 0)
	{
		ShowPrisonInventory(playerid);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "  Ban khong o trong tu!");
	return 1;
}

IsPlayerInCell(playerid)
{
	switch(PlayerInfo[playerid][pPrisonCell])
	{
	    case 0: { if(IsPlayerInRangeOfPoint(playerid, 2, 566.7456,1444.0634,6000.4751)) return 1; }
	    case 1: { if(IsPlayerInRangeOfPoint(playerid, 2, 563.0581,1444.1854,6000.4751)) return 1; }
	    case 2: { if(IsPlayerInRangeOfPoint(playerid, 2, 559.4159,1443.9288,6000.4751)) return 1; }
	    case 3: { if(IsPlayerInRangeOfPoint(playerid, 2, 555.6315,1444.2306,6000.4751)) return 1; }
	    case 4: { if(IsPlayerInRangeOfPoint(playerid, 2, 552.0065,1444.1968,6000.4751)) return 1; }
	    case 5: { if(IsPlayerInRangeOfPoint(playerid, 2, 548.0844,1444.0985,6000.4751)) return 1; }
	    case 6: { if(IsPlayerInRangeOfPoint(playerid, 2, 544.6454,1444.1449,6000.4751)) return 1; }
	    case 7: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.5981,1447.5231,6000.4751)) return 1; }
	    case 8: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.4813,1450.9047,6000.4751)) return 1; }
	    case 9: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.4357,1454.4258,6000.4751)) return 1; }
	    case 10: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.7283,1458.2170,6000.4751)) return 1; }
	    case 11: { if(IsPlayerInRangeOfPoint(playerid, 2, 544.1293,1464.5228,6000.4751)) return 1; }
	    case 12: { if(IsPlayerInRangeOfPoint(playerid, 2, 547.7798,1464.7081,6000.4751)) return 1; }
	    case 13: { if(IsPlayerInRangeOfPoint(playerid, 2, 551.2144,1464.6027,6000.4751)) return 1; }
	    case 14: { if(IsPlayerInRangeOfPoint(playerid, 2, 557.2998,1464.8198,6000.4751)) return 1; }
	    // end of first floor
	    case 15: { if(IsPlayerInRangeOfPoint(playerid, 2, 566.3901,1443.7551,6004.4946)) return 1; }
	    case 16: { if(IsPlayerInRangeOfPoint(playerid, 2, 562.5015,1443.7295,6004.4946)) return 1; }
	    case 17: { if(IsPlayerInRangeOfPoint(playerid, 2, 559.0636,1444.0476,6004.4946)) return 1; }
	    case 18: { if(IsPlayerInRangeOfPoint(playerid, 2, 555.3583,1444.0355,6004.4946)) return 1; }
	    case 19: { if(IsPlayerInRangeOfPoint(playerid, 2, 551.9474,1443.7928,6004.4946)) return 1; }
	    case 20: { if(IsPlayerInRangeOfPoint(playerid, 2, 548.2891,1444.0117,6004.4946)) return 1; }
	    case 21: { if(IsPlayerInRangeOfPoint(playerid, 2, 544.8405,1444.0632,6004.4946)) return 1; }
	    case 22: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.6741,1447.4341,6004.4946)) return 1; }
	    case 23: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.6885,1451.2081,6004.4946)) return 1; }
	    case 24: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.7267,1454.9779,6004.4946)) return 1; }
	    case 25: { if(IsPlayerInRangeOfPoint(playerid, 2, 540.4955,1458.8861,6004.4946)) return 1; }
	    case 26: { if(IsPlayerInRangeOfPoint(playerid, 2, 543.8416,1464.8979,6004.4946)) return 1; }
	    case 27: { if(IsPlayerInRangeOfPoint(playerid, 2, 547.9120,1464.5593,6004.4946)) return 1; }
	    case 28: { if(IsPlayerInRangeOfPoint(playerid, 2, 551.5958,1464.7749,6004.4946)) return 1; }
	    case 29: { if(IsPlayerInRangeOfPoint(playerid, 2, 557.6133,1464.9932,6004.4946)) return 1; }
	    // end of second floor
	}
	return 0;
}

IsPlayerInAShower(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid, 1, 588.8344,1445.8480,6000.4751)) return 1; 
	if(IsPlayerInRangeOfPoint(playerid, 1, 588.8367,1444.4164,6000.4751)) return 1; 
	if(IsPlayerInRangeOfPoint(playerid, 1, 588.8370,1443.2065,6000.4751)) return 1; 
	if(IsPlayerInRangeOfPoint(playerid, 1, 588.8370,1441.8711,6000.4751)) return 1; 
	if(IsPlayerInRangeOfPoint(playerid, 1, 588.7004,1438.7772,6000.4751)) return 1; 
	if(IsPlayerInRangeOfPoint(playerid, 1, 587.4869,1438.7759,6000.4751)) return 1; 
	if(IsPlayerInRangeOfPoint(playerid, 1, 586.3864,1438.7767,6000.4751)) return 1;
	if(IsPlayerInRangeOfPoint(playerid, 1, 585.2564,1438.7821,6000.4751)) return 1;
	if(IsPlayerInRangeOfPoint(playerid, 1, 584.0064,1438.7770,6000.4751)) return 1;
	if(IsPlayerInRangeOfPoint(playerid, 1, 582.7442,1438.7784,6000.4751)) return 1;
	if(IsPlayerInRangeOfPoint(playerid, 1, 581.4688,1438.7760,6000.4751)) return 1;
	if(IsPlayerInRangeOfPoint(playerid, 1, 580.2315,1438.7755,6000.4751)) return 1;
	else return 0;
}


/* TESTING COMANDS - REMOVE removed*/

/*CMD:givemematerials(playerid, params[])
{
    PlayerInfo[playerid][pPrisonMaterials] += 100000;
	return 1;
}

CMD:givemeprisoncredits(playerid, params[])
{
    PlayerInfo[playerid][pPrisonCredits] += 100000;
	return 1;
}

CMD:mycell(playerid, params[])
{
	new string[255];
	format(string, sizeof(string), "%d.", PlayerInfo[playerid][pPrisonCell]);
	SendClientMessage(playerid, COLOR_WHITE, string);
	return 1;
}*/

ShowPrisonInventory(playerid)
{
	new string[64];
	SendClientMessageEx(playerid, COLOR_GREY, "------------------------------------------------------");

	SendClientMessageEx(playerid, COLOR_GREY, "Buong giam: %d.", PlayerInfo[playerid][pPrisonCell]);
	SendClientMessage(playerid, COLOR_WHITE, "");

	if(PlayerInfo[playerid][pPrisonCredits] >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Prison Credits: %d.", PlayerInfo[playerid][pPrisonCredits]);
	}

	if(PlayerInfo[playerid][pPrisonMaterials] >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Vat lieu trong tu: %d.", PlayerInfo[playerid][pPrisonMaterials]);
	}

	if(GetPVarInt(playerid, "pPrisonSoap") >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Xa phong: %d.", GetPVarInt(playerid, "pPrisonSoap"));
	}

	if(GetPVarInt(playerid, "pPrisonSugar") >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Duong: %d.", GetPVarInt(playerid, "pPrisonSugar"));
	}

	if(GetPVarInt(playerid, "pPrisonBread") >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Banh mi: %d.", GetPVarInt(playerid, "pPrisonBread"));
	}

	if(GetPVarInt(playerid, "pPrisonWine") >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Pruno: %d.", GetPVarInt(playerid, "pPrisonWine"));
	}

	if(GetPVarInt(playerid, "pPrisonShank") >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Dao tu che: %d | Luot dung: %d", GetPVarInt(playerid, "pPrisonShank"), GetPVarInt(playerid, "pShankUsages"));
	}

	if(GetPVarInt(playerid, "pPrisonMWine") >= 1)
	{
	    if(PlayerInfo[playerid][pPrisonWineTime] <= gettime())
		{
		    SendClientMessageEx(playerid, COLOR_WHITE, "");
			SendClientMessageEx(playerid, COLOR_GREY, "Pruno con: 0 giay.");
		}
		else
		{
	    	format(string, sizeof(string), "Pruno con: %s.", TimeConvert(PlayerInfo[playerid][pPrisonWineTime]-gettime()));
	    	SendClientMessageEx(playerid, COLOR_WHITE, "");
	    	SendClientMessageEx(playerid, COLOR_GREY, string);
		}
	}

	SendClientMessageEx(playerid, COLOR_GREY, "------------------------------------------------------");
	return 1;
}

forward _UnbeanbagTimer(playerid);
public _UnbeanbagTimer(playerid)
{
	if(GetPVarInt(playerid, "pBagged") >= 1)
	{
		ClearAnimationsEx(playerid);
		TogglePlayerControllable(playerid, TRUE);
		DeletePVar(playerid, "IsFrozen");

		SetPlayerDrunkLevel(playerid, 0);
		DeletePVar(playerid, "pBagged");

		ClearAnimationsEx(playerid);
	}
	else
	{
		SetPlayerDrunkLevel(playerid, 0);
	}
	return 1;
}

forward _ShowerTimer(playerid);
public _ShowerTimer(playerid)
{
	new Float: health;
	GetPlayerHealth(playerid, health);

	SetHealth(playerid, 150.0);

	ClearAnimationsEx(playerid);

	switch(GetPVarInt(playerid, "pPrisonShowerStage"))
	{
		case 1:
		{
			SendClientMessage(playerid, COLOR_GREY, "Ban da tam xong.");
			TogglePlayerControllable(playerid, TRUE);
			DeletePVar(playerid, "pPrisonShowerStage");
			DeletePVar(playerid, "IsFrozen");
		}
		default: 
		{
			ApplyAnimation(playerid, "MISC", "Scratchballs_01", 4.0, false, false, false, false, 0, 1);
			SetPVarInt(playerid, "pPrisonShowerStage", 1);

			SetTimerEx("_ShowerTimer", 8000, false, "d", playerid);
		}
	}
	RandomMaterialChance(playerid);
	return 1;
}

forward _DrinkWineTimer(playerid);
public _DrinkWineTimer(playerid)
{
	new Float: health;
	GetPlayerHealth(playerid, health);

	SetHealth(playerid, 200.0);

	SendClientMessage(playerid, COLOR_GREY, "Ban dan on dinh va cam thay khoe hon.");
	SetPVarInt(playerid, "pWineConsumed", 2);
	SetTimerEx("_DrinkWineTimer2", 60000, false, "d", playerid);

	SetPlayerDrunkLevel(playerid, 1000);
	ClearAnimationsEx(playerid);
	return 1;
}

forward _DrinkWineTimer2(playerid);
public _DrinkWineTimer2(playerid)
{
	new Float: health;
	GetPlayerHealth(playerid, health);

	SendClientMessage(playerid, COLOR_GREY, "Pruno da het tac dung.");
	DeletePVar(playerid, "pWineConsumed");

	SetPlayerDrunkLevel(playerid, 0);
	ClearAnimationsEx(playerid);
	return 1;
}

forward _KitchenTimer(playerid);
public _KitchenTimer(playerid)
{
	PlayerInfo[playerid][pMechTime] = gettime()+60;
	SendClientMessage(playerid, COLOR_GREY, "Ban da chuan bi xong thuc an.");
	TogglePlayerControllable(playerid, TRUE);
	DeletePVar(playerid, "pDoingPJob");

	PlayerInfo[playerid][pPrisonCredits] += 3;
	RandomMaterialChance(playerid);
	DeletePVar(playerid, "IsFrozen");

	ClearAnimationsEx(playerid);
	return 1;
}

forward _ReleaseTimer(playerid);
public _ReleaseTimer(playerid)
{
    if(strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1 && GetPVarInt(playerid, "_pBeingReleased") >= 1)
	{
 		ReleasePlayerFromPrison(playerid);
 		DeletePVar(playerid, "_pBeingReleased");
	}
	else if(GetPVarInt(playerid, "_pBeingReleased") == -1) { DeletePVar(playerid, "_pBeingReleased"); }
	return 1;
}

ReleasePlayerFromPrison(playerid)
{
	if(playerTabbed[playerid] == 0)
	{
		if(PlayerInfo[playerid][pJailTime] > 0 && --PlayerInfo[playerid][pJailTime] <= 0)
		{
			if(strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1)
	    	{
				SetPlayerInterior(playerid, 0);
				PlayerInfo[playerid][pInt] = 0;
				SetPlayerVirtualWorld(playerid, 0);
				PlayerInfo[playerid][pVW] = 0;
				SetPlayerPos(playerid, -1528.5812,489.6914,7.1797);

				PlayerInfo[playerid][pPrisonCredits] = 0;
				PlayerInfo[playerid][pPrisonMaterials] = 0;
				PlayerInfo[playerid][pPrisonWineTime] = 0;
				PlayerInfo[playerid][pPrisonCell] = 0;

				DeletePVar(playerid, "pPrisonSoap");
				DeletePVar(playerid, "pPrisonSugar");
				DeletePVar(playerid, "pPrisonBread");
				DeletePVar(playerid, "pPrisonShank");
				DeletePVar(playerid, "pPrisonShankOut");
				DeletePVar(playerid, "pShankUsages");
				DeletePVar(playerid, "pPrisonWine");
				DeletePVar(playerid, "pPrisonMWine");
				DeletePVar(playerid, "pPrisonChisel");
				DeletePVar(playerid, "pPrisonCellChisel");
				DeletePVar(playerid, "_pBeingReleased");
	 		}
		}
		else
		{
			SetPlayerInterior(playerid, 0);
			PlayerInfo[playerid][pInt] = 0;
			SetPlayerVirtualWorld(playerid, 0);
			PlayerInfo[playerid][pVW] = 0;
			SetPlayerPos(playerid, 1544.5059,-1675.5673,13.5585);
		}
	}

	SetHealth(playerid, 100);
	PlayerInfo[playerid][pJailTime] = 0;
	PlayerInfo[playerid][pIsolated] = 0;
	PlayerInfo[playerid][pPrisonCredits] = 0;
	strcpy(PlayerInfo[playerid][pPrisonReason], "None");
	PhoneOnline[playerid] = 0;
	SendClientMessageEx(playerid, COLOR_GRAD1,"   Ban da tra het mon no voi xa hoi.");
	GameTextForPlayer(playerid, "~g~Tu do~n~~w~Hay la cong dan tot hon", 5000, 1);
	TogglePlayerControllable(playerid, TRUE);
	SetPlayerToTeamColor(playerid); //For some reason this is a being a bitch now so let's reset their colour to white and let the script decide what colour they should have afterwords
	ClearCrimes(playerid);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if ((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
    {
        if(IsPlayerInRangeOfPoint(playerid, 2, 567.7756,1450.0720,6000.4751))
        {
            if(strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1) { ShowPlayerDialogEx(playerid, DIALOG_PRISONCREDS, DIALOG_STYLE_LIST, "Prison Canteen", "Xuc xac\t\t\t\t\t\t5\nGiay\t\t\t\t\t\t5\nXa phong\t\t\t\t\t\t5\nDuong\t\t\t\t\t\t5\nBanh mi\t\t\t\t\t\t10\nThuoc la\t\t\t\t\t10\n\nMP3 Player\t\t\t\t\t50\nQuan ao\t\t\t\t\t250", "Mua", "Huy"); }
        }

        else if(IsPlayerInRangeOfPoint(playerid, 5, 546.7458,1484.4885,6000.4678))
        {
            new string[255];
    		if(gettime() < PlayerInfo[playerid][pMechTime])
			{
				return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban phai cho %d giay!", PlayerInfo[playerid][pMechTime]-gettime());
     		}
     		if(GetPVarInt(playerid, "pDoingPJob") >= 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "  Ban dang lam mot cong viec!");

            TogglePlayerControllable(playerid, FALSE);
			SetTimerEx("_KitchenTimer", 25000, false, "d", playerid);

			SetPVarInt(playerid, "IsFrozen", 1);

			format(string, sizeof string, "{FF8000}> {C2A2DA}%s bat dau chuan bi thuc an cho bep.", GetPlayerNameEx(playerid));
    		SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 6000);
    		SendClientMessage(playerid, COLOR_PURPLE, string);
    		SetPVarInt(playerid, "pDoingPJob", 1);

    		TogglePlayerControllable(playerid, FALSE);

            PlayAnimEx(playerid, "BD_FIRE", "wash_up", 4.0, true, false, false, false, 0, 1);
        }
	    else if(IsPlayerInAShower(playerid))
	    {
	        if(GetPVarInt(playerid, "pPrisonSoap") >= 1)
			{
				new string[128];
	        	new Float: health;
				GetPlayerHealth(playerid, health);
	        	if(health >= 150.0) return SendClientMessage(playerid, COLOR_GREY, "  Ban khong can tam.");

      	  		format(string, sizeof string, "{FF8000}> {C2A2DA}%s dung xa phong lau nguoi.", GetPlayerNameEx(playerid));
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
				SendClientMessage(playerid, COLOR_PURPLE, string);

				SetPVarInt(playerid, "pPrisonSoap", GetPVarInt(playerid, "pPrisonSoap") - 1);
				TogglePlayerControllable(playerid, FALSE);
				SetPVarInt(playerid, "IsFrozen", 1);

				SetTimerEx("_ShowerTimer", 10000, false, "d", playerid);

				PlayAnimEx(playerid, "BD_FIRE", "wash_up", 4.0, true, false, false, false, 0, 1);
			}
			else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co xa phong.");
	    }

	    else if(GetPVarInt(playerid, "pPrisonChisel") >= 1 && IsPlayerInCell(playerid))
	    {
	        new string[255];
	        format(string, sizeof string, "{FF8000}> {C2A2DA}%s dung vat nho duc tuong buong giam.", GetPlayerNameEx(playerid));
			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 4000);
			SendClientMessage(playerid, COLOR_PURPLE, string);

			SetPVarInt(playerid, "pPrisonCellChisel", 1);
			SetPVarInt(playerid, "pPrisonChisel", 0);

			PlayAnimEx(playerid,"BOMBER","BOM_Plant",4.0,false,false,false,false,0,0);

			SendClientMessage(playerid, COLOR_WHITE, "Ban da duc mot lo trong buong giam, dung /celldeposit de giau hang cam.");
	    }
    }
	return 1;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
	new string[128];
	if(GetPVarInt(playerid, "pPrisonShankOut") >= 1 && weaponid == 0)
	{
	    new Float:health;
	    GetPlayerHealth(damagedid, health);
	    SetHealth(damagedid, health - random(40));

	    SetPVarInt(playerid, "pShankUsages", GetPVarInt(playerid, "pShankUsages") - 1);

	    if(GetPVarInt(playerid, "pShankUsages") <= 0)
	    {
	        SetPVarInt(playerid, "pShankUsages", 0);
	        SetPVarInt(playerid, "pPrisonShank", 0);
	        SetPVarInt(playerid, "pPrisonShankOut", 0);

	        format(string, sizeof string, "{FF8000}> {C2A2DA}%s co dao tu che da cun.", GetPlayerNameEx(playerid));
    		SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 30.0, 6000);

    		SendClientMessageEx(playerid, COLOR_GREY, "Dao tu che cua ban da het luot dung.");

	        RemovePlayerAttachedObject(playerid, 9);
	    }
	}

	if(GetPVarInt(playerid, "pWineConsumed") >= 2)
	{
	    new Float:health;
    	GetPlayerHealth(damagedid, health);
    	SetHealth(damagedid, health - 15.0);
	}
    return 1;
}

RandomMaterialChance(playerid)
{
	switch(random(100))
	{
	    case 0 .. 80:
	    {
	        return 0;
	    }
	    default:
	    {
	    	switch(random(10))
	    	{
	    		case 0 .. 5: 
	    		{
	        		PlayerInfo[playerid][pPrisonMaterials] +=1;
	        		SendClientMessage(playerid, COLOR_WHITE, "Ban tim thay mot vat lieu bi mat trong tu. Dung trong /prisoncraft.");
	        	}
	        	case 6 .. 8: 
	    		{
	        		PlayerInfo[playerid][pPrisonMaterials] +=2;
	        		SendClientMessage(playerid, COLOR_WHITE, "Ban tim thay hai vat lieu bi mat trong tu. Dung trong /prisoncraft.");
	        	}
	        	default: 
	    		{
	        		PlayerInfo[playerid][pPrisonMaterials] +=3;
	        		SendClientMessage(playerid, COLOR_WHITE, "Ban tim thay ba vat lieu bi mat trong tu. Dung trong /prisoncraft.");
	        	}
	        }
	    }
	}
	return 1;
}
