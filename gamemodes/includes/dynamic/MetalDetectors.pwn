#include <YSI_Coding\y_hooks>

hook OnPlayerEnterDynamicArea(playerid, areaid)
{
	new i = MetDet_GetIDFromArea(areaid);
	if(i == -1) return 1;

	new wepid, iammo;
	for(new idx = 0; idx <= 12; ++idx)
	{
		GetPlayerWeaponData(playerid, idx, wepid, iammo);
		switch(wepid)
		{
			case 24 .. 40: { MetDet_Alarm(i); break; }
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_METDET_LIST:
		{
			if(response)
			{
				new Float:fPos[3],
					iAssignData[2];
				GetDynamicObjectPos(arrMetalDetector[listitem][metdet_iObjectID], fPos[0], fPos[1], fPos[2]);
				iAssignData[0] = Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrMetalDetector[listitem][metdet_iObjectID], E_STREAMER_WORLD_ID);
				iAssignData[1] = Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrMetalDetector[listitem][metdet_iObjectID], E_STREAMER_INTERIOR_ID);
				SetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
				SetPlayerVirtualWorld(playerid, iAssignData[0]);
				SetPlayerInterior(playerid, iAssignData[1]);
			}
		}
	}
	return 0;
}

MetDet_CreateMetDet(playerid)
{
	new Float:fPos[3],
		iVW = GetPlayerVirtualWorld(playerid),
		iINT = GetPlayerInterior(playerid);

	GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
	for(new i; i < MAX_METALDETECTORS; ++i)
	{
		if(!IsValidDynamicObject(arrMetalDetector[i][metdet_iObjectID]))
		{
			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "INSERT INTO `metaldetectors` (`id`, `posx`, `posy`, `posz`, `rotx`, `roty`, `rotz`, `vw`, `int`)\
			 VALUES (%d, %f, %f, %f, %f, %f, %f, %i, %i)", i, fPos[0], fPos[1], fPos[2], 0.0, 0.0, 0.0, iVW, iINT);
			mysql_tquery(MainPipeline, szMiscArray, "MetDet_OnCreateMetDet", "iifffii", playerid, i, fPos[0], fPos[1], fPos[2], iVW, iINT);
			return 1;
		}
	}
	return SendClientMessageEx(playerid, COLOR_GRAD1, "Da dat gioi han tao may do kim loai.");
}

forward MetDet_OnCreateMetDet(playerid, i, Float:X, Float:Y, Float:Z, iVW, iINT);
public MetDet_OnCreateMetDet(playerid, i, Float:X, Float:Y, Float:Z, iVW, iINT)
{
	SendClientMessageEx(playerid, COLOR_WHITE, "Da tao may do kim loai ID %d", i);
	MetDet_Process(i, X, Y, Z, 0.0, 0.0, 0.0, iVW, iINT);
	return 1;
}

MetDet_DeleteMetDet(playerid, i)
{
	if(!IsValidDynamicObject(arrMetalDetector[i][metdet_iObjectID])) return SendClientMessageEx(playerid, COLOR_GRAD1, "ID may do kim loai khong hop le.");
	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "DELETE FROM `metaldetectors` WHERE `id` = %d", i);
	return mysql_tquery(MainPipeline, szMiscArray, "MetDet_OnDeleteMetDet", "ii", playerid, i);
}

forward MetDet_OnDeleteMetDet(playerid, i);
public MetDet_OnDeleteMetDet(playerid, i)
{
	if(mysql_errno(MainPipeline) == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the xu ly truy van cua ban.");
	DestroyDynamicObject(arrMetalDetector[i][metdet_iObjectID]);
	DestroyDynamic3DTextLabel(arrMetalDetector[i][metdet_iTextID]);
	DestroyDynamicArea(arrMetalDetector[i][metdet_iAreaID]);
	return 1;
}

MetDet_CheckMetDets(playerid)
{
	return mysql_tquery(MainPipeline, "SELECT * FROM `metaldetectors` WHERE 1", "MetDet_OnCheckMetDets", "i", playerid);
}

forward MetDet_OnCheckMetDets(playerid);
public MetDet_OnCheckMetDets(playerid)
{
	szMiscArray[0] = 0;
	new iRows, value;
	cache_get_row_count(iRows);

	if(!iRows) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong co may do kim loai trong co so du lieu.");
	for(new row; row < iRows; ++row)
	{
		format(szMiscArray, sizeof(szMiscArray), "%sMay do kim loai: %d\n", szMiscArray, cache_get_value_name_int(row, "id", value));
	}
	ShowPlayerDialogEx(playerid, DIALOG_METDET_LIST, DIALOG_STYLE_LIST, "May do kim loai | Danh sach", szMiscArray, "Chon", "");
	return 1;
}

MetDet_LoadMetDets()
{
	return mysql_tquery(MainPipeline, "SELECT * FROM `metaldetectors` WHERE 1", "MetDet_OnLoadMetDets", "");
}

forward MetDet_OnLoadMetDets();
public MetDet_OnLoadMetDets()
{
	new iRows,
		iCount,
		value,
		Float:fValue;
	
	cache_get_row_count(iRows);

	if(!iRows) return print("[Metal Detectors] There are no metaldetectors in the database.");
	while(iCount < iRows)
	{
		MetDet_Process(iCount, cache_get_value_name_float(iCount, "posx", fValue), cache_get_value_name_float(iCount, "posy", fValue), cache_get_value_name_float(iCount, "posz", fValue),
				cache_get_value_name_float(iCount, "rotx", fValue), cache_get_value_name_float(iCount, "roty", fValue), cache_get_value_name_float(iCount, "rotz", fValue),
				cache_get_value_name_int(iCount, "vw", value), cache_get_value_name_int(iCount, "int", value));
		iCount++;
	}
	printf("[Metal Detectors] Successfully loaded %d metal detectors", iCount);
	return 1;
}

MetDet_Process(id, Float:X = 0.0, Float:Y = 0.0, Float:Z = 0.0, Float:RX = 0.0, Float:RY = 0.0, Float:RZ = 0.0, iVW = 0, iINT = 0)
{
	if(IsValidDynamicObject(arrMetalDetector[id][metdet_iObjectID])) DestroyDynamicObject(arrMetalDetector[id][metdet_iObjectID]);
	arrMetalDetector[id][metdet_iObjectID] = CreateDynamicObject(1892, X-0.6, Y, Z, RX, RY, RZ, .worldid = iVW, .interiorid = iINT);
	if(IsValidDynamic3DTextLabel(arrMetalDetector[id][metdet_iTextID])) DestroyDynamic3DTextLabel(arrMetalDetector[id][metdet_iTextID]);
	format(szMiscArray, sizeof(szMiscArray), "May do kim loai (ID: %d)\n\n{FFFF00}Binh thuong", id);
	arrMetalDetector[id][metdet_iTextID] = CreateDynamic3DTextLabel(szMiscArray, COLOR_WHITE, X, Y, Z+1.0, 10.0);
	if(IsValidDynamicArea(arrMetalDetector[id][metdet_iAreaID])) DestroyDynamicArea(arrMetalDetector[id][metdet_iAreaID]);
	arrMetalDetector[id][metdet_iAreaID] = CreateDynamicSphere(X, Y, Z, 3.0, .worldid = iVW, .interiorid = iINT);

 	// Streamer_SetIntData(STREAMER_TYPE_AREA, arrMetalDetector[id][metdet_iAreaID], E_STREAMER_EXTRA_ID, id);
}

MetDet_Alarm(i)
{
	// ProxDetector(20.0, playerid, "** [Metal Detector]: ** ALARM **", COLOR_LIGHTRED, COLOR_LIGHTRED, COLOR_LIGHTRED, COLOR_LIGHTRED, COLOR_LIGHTRED);
	UpdateDynamic3DTextLabelText(arrMetalDetector[i][metdet_iTextID], COLOR_WHITE, "May do kim loai \n\n{FF0000}** BAO DONG **");
	SetTimerEx("MetDet_Restore", 5000, false, "i", i);
}

forward MetDet_Restore(i);
public MetDet_Restore(i)
{
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "May do kim loai (ID: %d)\n\n{FFFF00}Binh thuong", i);
	UpdateDynamic3DTextLabelText(arrMetalDetector[i][metdet_iTextID], COLOR_WHITE, szMiscArray);
}

MetDet_GetIDFromArea(areaid) {

	for(new i; i < MAX_METALDETECTORS; ++i) {
		if(areaid == arrMetalDetector[i][metdet_iAreaID]) return i;
	}
	return -1;
}

MetDet_SaveMetDet(id)
{
	new Float:fPos[6],
		iAssignData[2];

	GetDynamicObjectPos(arrMetalDetector[id][metdet_iObjectID], fPos[0], fPos[1], fPos[2]);
	GetDynamicObjectRot(arrMetalDetector[id][metdet_iObjectID], fPos[3], fPos[4], fPos[5]);
	iAssignData[0] = Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrMetalDetector[id][metdet_iObjectID], E_STREAMER_WORLD_ID);
	iAssignData[1] = Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrMetalDetector[id][metdet_iObjectID], E_STREAMER_INTERIOR_ID);

	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `metaldetectors` SET `posx` = %f, `posy` = %f, `posz` = %f, `rotx` = %f, `roty` = %f, `rotz` = %f, `vw` = %d, `int` = %d WHERE id = %d",
			fPos[0], fPos[1], fPos[2], fPos[3], fPos[4], fPos[5], iAssignData[0], iAssignData[1], id);
	mysql_tquery(MainPipeline, szMiscArray, "MetDet_OnSaveMetDets", "i", id);

}

forward MetDet_OnSaveMetDet(id);
public MetDet_OnSaveMetDet(id)
{
	if(mysql_errno(MainPipeline) == 1) return printf("[Metal Detectors] Something went wrong when saving ID %d", id);
	return 1;
}


CMD:createmetaldetector(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 2) MetDet_CreateMetDet(playerid);
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:metaldetector(playerid, params[])
{
	new Float:fPos[3],
		choice[16],
		id,
		amount,
		iAssignData[2];
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	if(sscanf(params, "s[32]dD(1)", choice, id, amount))
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "DUNG: /metaldetector [choice] [ID] [value]");
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Tuy chon: tome, goto, Position, Delete");
	}
	if(!IsValidDynamicObject(arrMetalDetector[id][metdet_iObjectID])) return SendClientMessageEx(playerid, COLOR_GRAD1, "May do kim loai nay khong ton tai.");
	if(strcmp(choice, "tome", true) == 0)
	{
		GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
		MetDet_Process(id, fPos[0], fPos[1], fPos[2], 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
		MetDet_SaveMetDet(id);
	}
	if(strcmp(choice, "goto", true) == 0)
	{
		GetDynamicObjectPos(arrMetalDetector[id][metdet_iObjectID], fPos[0], fPos[1], fPos[2]);
		
		iAssignData[0] = Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrMetalDetector[id][metdet_iObjectID], E_STREAMER_WORLD_ID);
		iAssignData[1] = Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrMetalDetector[id][metdet_iObjectID], E_STREAMER_INTERIOR_ID);
		
		SetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
		SetPlayerVirtualWorld(playerid, iAssignData[0]);
		SetPlayerInterior(playerid, iAssignData[1]);
	}
	if(strcmp(choice, "position", true) == 0)
	{
		GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
		if(!IsPlayerInRangeOfPoint(playerid, 10.0,  fPos[0], fPos[1], fPos[2])) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o gan may do kim loai.");
		SetPVarInt(playerid, PVAR_EMETDET, id);
		EditDynamicObject(playerid, arrMetalDetector[id][metdet_iObjectID]);
	}
	if(strcmp(choice, "delete", true) == 0)
	{
		MetDet_DeleteMetDet(playerid, id);
	}
	return 1;
}

CMD:metdets(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 2) MetDet_CheckMetDets(playerid);
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}