/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						House List Module

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

#define 	INTERIOR_TYPE_SMALL		(0)
#define 	INTERIOR_TYPE_MEDIUM 	(1)
#define 	INTERIOR_TYPE_LARGE		(2)

new Float:InteriorsList[42][4] = {
	{140.17, 1366.07, 1083.65, 5.0},
	{2324.53, -1149.54, 1050.71, 12.0},
	{225.68, 1021.45, 1084.02, 7.0},
	{234.19, 1063.73, 1084.21, 6.0},
	{226.30, 1114.24, 1080.99, 5.0},
	{235.34, 1186.68, 1080.26, 3.0},
	{491.07, 1398.50, 1080.26, 2.0},
	{24.04, 1340.17, 1084.38, 10.0},
	{-283.44, 1470.93, 1084.38, 15.0},
	{-260.49, 1456.75, 1084.37, 4.0},
	{83.03, 1322.28, 1083.87, 9.0},
	{2317.89, -1026.76, 1050.22, 9.0},
	{2495.98, -1692.08, 1014.74, 3.0},
	{2807.48, -1174.76, 1025.57, 8.0},
	{2196.85, -1204.25, 1049.02, 6.0},
	{377.15, 1417.41, 1081.33, 15.0},
	{2270.38, -1210.35, 1047.56, 10.0},
	{446.99, 1397.07, 1084.30, 2.0},
	{387.22, 1471.70, 1080.19, 15.0},
	{22.88, 1403.33, 1084.44, 5.0},
	{2365.31, -1135.60, 1050.88, 8.0},
	{2237.59, -1081.64, 1049.02, 2.0},
	{295.04, 1472.26, 1080.26, 15.0},
	{261.12, 1284.30, 1080.26, 4.0},
	{221.92, 1140.20, 1082.61, 4.0},
	{-68.81, 1351.21, 1080.21, 6.0},
	{260.85, 1237.24, 1084.26, 9.0},
	{2468.84, -1698.24, 1013.51, 2.0},
	{223.20, 1287.08, 1082.14, 1.0},
	{2283.04, -1140.28, 1050.90, 11.0},
	{328.05, 1477.73, 1084.44, 15.0},
	{223.20, 1287.08, 1082.14, 1.0},
	{-42.59, 1405.47, 1084.43, 8.0},
	{446.90, 506.35, 1001.42, 12.0},
	{299.78, 309.89, 1003.30, 4.0},
	{2308.77, -1212.94, 1049.02, 6.0},
	{2233.64, -1115.26, 1050.88, 5.0},
	{2218.40, -1076.18, 1050.48, 1.0},
	{266.50, 304.90, 999.15, 2.0},
	{243.72, 304.91, 999.15, 1.0},
	{343.81, 304.86, 999.15, 6.0},
	{2259.38, -1135.77, 1050.64, 10.0}
};

ListInteriors(playerid, iType)
{
	szMiscArray[0] = 0; // this must be done to null initiate the global variable. 

	switch(iType)
	{
		case INTERIOR_TYPE_SMALL:
		{
			format(szMiscArray, sizeof(szMiscArray),
				"Noi that (30)\n\
				Noi that (31)\n\
				Noi that (32)\n\
				Noi that (33)\n\
				Noi that (34)\n\
				Noi that (35)\n\
				Noi that (36)\n\
				Noi that (37)\n\
				Noi that (38)\n\
				Noi that (39)\n\
				Noi that (40)\n\
				Noi that (41)\n\
				Noi that (42)\n\
				Noi that (43)"
			);

		}
		case INTERIOR_TYPE_MEDIUM:
		{
			format(szMiscArray, sizeof(szMiscArray),
				"Noi that (7)\n\
				Noi that (8)\n\
				Noi that (9)\n\
				Noi that (10\n\
				Noi that (11)\n\
				Noi that (12)\n\
				Noi that (13)\n\
				Noi that (14)\n\
				Noi that (15)\n\
				Noi that (16)\n\
				Noi that (17)\n\
				Noi that (18)\n\
				Noi that (19)\n\
				Noi that (20)\n\
				Noi that (21)\n\
				Noi that (22)\n\
				Noi that (23)\n\
				Noi that (24)\n\
				Noi that (25)\n\
				Noi that (26)\n\
				Noi that (27)\n\
				Noi that (28)\n\
				Noi that (29)"
			);

		}
		case INTERIOR_TYPE_LARGE:
		{
			format(szMiscArray, sizeof(szMiscArray),
				"Noi that (2)\n\
				Noi that (3)\n\
				Noi that (4)\n\
				Noi that (5)\n\
				Noi that (6)"
			);
		}
	}
	return ShowPlayerDialogEx(playerid, DIALOG_LIST_INTERIORS2, DIALOG_STYLE_LIST, "Danh sach noi that", szMiscArray, "Di den", "Huy");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(dialogid == DIALOG_LIST_INTERIORS && response)
	{
		ListInteriors(playerid, listitem);
	}
	if(dialogid == DIALOG_LIST_INTERIORS2 && response)
	{
		new stpos = strfind(inputtext, "(");
	    new fpos = strfind(inputtext, ")");
	    new idstr[4], id;
	    strmid(idstr, inputtext, stpos+1, fpos);
	    id = strval(idstr);

	    SetPlayerInterior(playerid, floatround(InteriorsList[id][3]));
	    SetPlayerPos(playerid, InteriorsList[id][0], InteriorsList[id][1], InteriorsList[id][2]);
	}
	return 0;
}

CMD:interiors(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co quyen dung lenh nay!");
	ShowPlayerDialogEx(playerid, DIALOG_LIST_INTERIORS, DIALOG_STYLE_LIST, "Chon danh muc", "Noi that nho\nNoi that vua\nNoi that lon", "Chon", "Huy");
	return 1;
}