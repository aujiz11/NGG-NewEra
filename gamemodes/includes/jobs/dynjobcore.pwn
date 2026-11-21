#include <YSI_Coding\y_hooks>

#define PVAR_JOB_OBTAINING "JOB_OB"
#define PVAR_JOB_POINT "JOB_POINT"
#define JOBPOINT_PAGE_SIZE 20

new JobCount;

hook OnGameModeInit()
{
	for(new i; i < MAX_JOBPOINTS; ++i)
	{
		JobData[i][jId] = -1;
		JobData[i][jLevel] = 1;
	}
	for(new i; i < MAX_JOBTYPES; ++i) 
	{
		format(JobName[i], sizeof(JobName[]), "%s", JobDefinitions[i][jobDefaultName]);
	}
	return 1;
}

Job_FindPoint(playerid)
{
	new areas[128], data[2];
	Streamer_Update(playerid, STREAMER_TYPE_AREA);
	if(GetPlayerNumberDynamicAreas(playerid) > sizeof(areas)) return -1;
	new count = GetPlayerDynamicAreas(playerid, areas, sizeof(areas));
	for(new n; n < count; ++n)
	{
		if(Streamer_GetArrayDataLength(STREAMER_TYPE_AREA, areas[n], E_STREAMER_EXTRA_ID) != sizeof(data)) continue;
		Streamer_GetArrayData(STREAMER_TYPE_AREA, areas[n], E_STREAMER_EXTRA_ID, data, sizeof(data));
		if(data[0] == STREAMER_AREATYPE_JOB && 0 <= data[1] < MAX_JOBPOINTS && JobData[data[1]][jAreaID] == areas[n]) return data[1];
	}
	return -1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if((newkeys & KEY_YES) && !(oldkeys & KEY_YES) && gPlayerLogged{playerid} && GetPlayerDialogID(playerid) == INVALID_DIALOG_ID)
	{
		new point = Job_FindPoint(playerid);
		if(point != -1)
		{
			Job_GetJob(playerid, point);
			if(GetPlayerDialogID(playerid) != INVALID_DIALOG_ID) return ~1;
		}
	}
	return 1;
}

stock LoadJobNames()
{
	mysql_tquery(MainPipeline, "SELECT `id`, `name` FROM `jobs_types`", "OnLoadJobNames");
}

forward OnLoadJobNames();
public OnLoadJobNames()
{
	new rows, loaded;
	cache_get_row_count(rows);
	for(new row; row < rows; ++row)
	{
		new id;
		cache_get_value_name_int(row, "id", id);
		if(!Job_IsKnownType(id)) continue;
		new name[MAX_JOBNAME_LEN];
		cache_get_value_name(row, "name", name, sizeof(name));
		if(name[0] == EOS || !strcmp(name, "-----") || strfind(name, "\n") != -1 || strfind(name, "\r") != -1 || strfind(name, "\t") != -1) continue;
		format(JobName[id], sizeof(JobName[]), "%s", name);
		++loaded;
	}
	printf("[Dynamic Job Names] Loaded %d job names.", loaded);
	return 1;
}

stock LoadJobPoints()
{
	LoadJobNames();
	mysql_tquery(MainPipeline, "SELECT * FROM `jobs`", "OnLoadJobPoints");
}

forward OnLoadJobPoints();
public OnLoadJobPoints()
{
	new rows, skipped;
	JobCount = 0;
	cache_get_row_count(rows);
	for(new row; row < rows; ++row)
	{
		new id;
		cache_get_value_name_int(row, "id", id);
		if(!(1 <= id <= MAX_JOBPOINTS))
		{
			++skipped;
			continue;
		}
		new point = id - 1;
		JobData[point][jId] = id;
		cache_get_value_name_int(row, "type", JobData[point][jType]);
		cache_get_value_name_float(row, "posx", JobData[point][jPos][0]);
		cache_get_value_name_float(row, "posy", JobData[point][jPos][1]);
		cache_get_value_name_float(row, "posz", JobData[point][jPos][2]);
		cache_get_value_name_int(row, "vw", JobData[point][jVw]);
		cache_get_value_name_int(row, "int", JobData[point][jInt]);
		cache_get_value_name_int(row, "marker", JobData[point][jMarkerID]);
		cache_get_value_name_int(row, "level", JobData[point][jLevel]);
		UpdateJobPoint(point);
		++JobCount;
	}
	printf("[Dynamic Job Points] Loaded %d backing rows, skipped %d IDs outside 1..%d.", JobCount, skipped, MAX_JOBPOINTS);
	return 1;
}

stock SaveJobPoint(i)
{
	if(!(0 <= i < MAX_JOBPOINTS) || JobData[i][jId] != i + 1) return 0;
	new query[512];
	mysql_format(MainPipeline, query, sizeof(query),
		"UPDATE `jobs` SET `type`=%d, `posx`=%.2f, `posy`=%.2f, `posz`=%.2f, `vw`=%d, `int`=%d, `marker`=%d, `level`=%d WHERE `id`=%d",
		JobData[i][jType], JobData[i][jPos][0], JobData[i][jPos][1], JobData[i][jPos][2],
		JobData[i][jVw], JobData[i][jInt], JobData[i][jMarkerID], JobData[i][jLevel], JobData[i][jId]);
	mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
	return 1;
}

forward UpdateJobPoint(id);
public UpdateJobPoint(id)
{
	if(!(0 <= id < MAX_JOBPOINTS)) return 0;
	if(IsValidDynamicArea(JobData[id][jAreaID])) DestroyDynamicArea(JobData[id][jAreaID]);
	if(IsValidDynamicPickup(JobData[id][jPickupID])) DestroyDynamicPickup(JobData[id][jPickupID]);
	if(IsValidDynamic3DTextLabel(JobData[id][jTextID])) DestroyDynamic3DTextLabel(JobData[id][jTextID]);
	if(IsValidDynamicMapIcon(JobData[id][jMapMarker])) DestroyDynamicMapIcon(JobData[id][jMapMarker]);
	JobData[id][jAreaID] = INVALID_STREAMER_ID;
	JobData[id][jPickupID] = INVALID_STREAMER_ID;
	JobData[id][jTextID] = Text3D:INVALID_STREAMER_ID;
	JobData[id][jMapMarker] = INVALID_STREAMER_ID;
	if(JobData[id][jId] != id + 1 || !Job_IsKnownType(JobData[id][jType])
		|| (JobData[id][jPos][0] == 0.0 && JobData[id][jPos][1] == 0.0 && JobData[id][jPos][2] == 0.0)) return 1;

	JobData[id][jAreaID] = CreateDynamicSphere(JobData[id][jPos][0], JobData[id][jPos][1], JobData[id][jPos][2], 3.0, .worldid = JobData[id][jVw], .interiorid = JobData[id][jInt]);
	new data[2];
	data[0] = STREAMER_AREATYPE_JOB;
	data[1] = id;
	Streamer_SetArrayData(STREAMER_TYPE_AREA, JobData[id][jAreaID], E_STREAMER_EXTRA_ID, data);
	JobData[id][jMapMarker] = CreateDynamicMapIcon(JobData[id][jPos][0], JobData[id][jPos][1], JobData[id][jPos][2], (JobData[id][jMarkerID] < 5 || JobData[id][jMarkerID] > 63) ? 56 : JobData[id][jMarkerID], 0,
		.worldid = JobData[id][jVw], .interiorid = JobData[id][jInt], .streamdistance = 500.0, .style = MAPICON_GLOBAL);
	JobData[id][jPickupID] = CreateDynamicPickup(1239, 23, JobData[id][jPos][0], JobData[id][jPos][1], JobData[id][jPos][2], .worldid = JobData[id][jVw], .interiorid = JobData[id][jInt], .streamdistance = 200.0);
	format(szMiscArray, sizeof(szMiscArray), "{FFFF00}Diem cong viec ({FFFFFF}ID: %i{FFFF00})\n\nTen: {FFFFFF}%s\n{FFFF00}Nhan {FFFFFF}~k~~CONVERSATION_YES~ {FFFF00}de xin viec.", id, GetJobName(JobData[id][jType]));
	JobData[id][jTextID] = CreateDynamic3DTextLabel(szMiscArray, COLOR_YELLOW, JobData[id][jPos][0], JobData[id][jPos][1], JobData[id][jPos][2] + 0.6, 10.0, .testlos = true, .worldid = JobData[id][jVw], .interiorid = JobData[id][jInt], .streamdistance = 10.0);
	return 1;
}

stock Job_CheckApplication(playerid, point)
{
	if(!gPlayerLogged{playerid} || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || PlayerIsDead[playerid]
		|| GetPVarInt(playerid, "Injured") || PlayerInfo[playerid][pJailTime] > 0 || PlayerCuffed[playerid] || PlayerTied[playerid]
		|| GetPVarInt(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged"))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Phai san sang va di bo de xin viec."), 0;
	if(!(0 <= point < MAX_JOBPOINTS) || JobData[point][jId] != point + 1 || !Job_IsKnownType(JobData[point][jType])
		|| !IsValidDynamicArea(JobData[point][jAreaID]))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Diem xin viec khong con hop le."), 0;
	if(GetPlayerVirtualWorld(playerid) != JobData[point][jVw] || GetPlayerInterior(playerid) != JobData[point][jInt]
		|| !IsPlayerInRangeOfPoint(playerid, 3.0, JobData[point][jPos][0], JobData[point][jPos][1], JobData[point][jPos][2]))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Phai o tai diem xin viec."), 0;
	if(PlayerInfo[playerid][pLevel] < JobData[point][jLevel])
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Can cap %i de xin cong viec nay.", JobData[point][jLevel]), 0;
	new job = JobData[point][jType];
	if(!Job_IsAvailable(job)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Cong viec cu nay khong nhan nguoi moi."), 0;
	if(Job_HasJob(playerid, job))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da co cong viec nay."), 0;
	for(new slot = 1; slot <= 3; ++slot) if(Job_CanUseSlot(playerid, slot) && Job_GetSlot(playerid, slot) == JOB_NONE) return slot;
	return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the nhan them cong viec. Dung /quitjob de nghi cong viec cu truoc."), 0;
}

stock Job_GetJob(playerid, i)
{
	if(!Job_CheckApplication(playerid, i)) return 1;
	SetPVarInt(playerid, PVAR_JOB_OBTAINING, JobData[i][jType]);
	SetPVarInt(playerid, PVAR_JOB_POINT, i);
	format(szMiscArray, sizeof(szMiscArray), "Ban muon bat dau lam {FFFF00}%s{FFFFFF}?", GetJobName(JobData[i][jType]));
	return Dialog_Show(playerid, acceptjob, DIALOG_STYLE_MSGBOX, "Diem cong viec", szMiscArray, "Co", "Khong");
}

Dialog:acceptjob(playerid, response, listitem, inputtext[])
{
	if(!GetPVarType(playerid, PVAR_JOB_OBTAINING) || !GetPVarType(playerid, PVAR_JOB_POINT)) return 1;
	new job = GetPVarInt(playerid, PVAR_JOB_OBTAINING), point = GetPVarInt(playerid, PVAR_JOB_POINT);
	DeletePVar(playerid, PVAR_JOB_OBTAINING);
	DeletePVar(playerid, PVAR_JOB_POINT);
	if(!response) return 1;
	if(!(0 <= point < MAX_JOBPOINTS) || JobData[point][jType] != job)
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Don xin viec khong con hop le.");
	new slot = Job_CheckApplication(playerid, point);
	if(!slot) return 1;
	if(!Job_SetPlayerSlot(playerid, slot, job)) return 1;
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da nhan cong viec %s. Dung /jobhelp de xem.", GetJobName(job));
	if(slot > 1) SendClientMessageEx(playerid, COLOR_YELLOW, "Da dat cong viec nay vao o %d.", slot);
	if(job == JOB_PIZZA)
	{
		SetPlayerSkin(playerid, 155);
		PlayerInfo[playerid][pModel] = 155;
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da duoc cap dong phuc Pizza Stack!");
	}
	return 1;
}

stock GetJobName(i)
{
	if(!(0 <= i < MAX_JOBTYPES)) i = JOB_NONE;
	return JobName[i];
}

stock Job_CanEdit(playerid)
{
	return gPlayerLogged{playerid} && (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1);
}

stock Job_GetEditPoint(playerid)
{
	if(!Job_CanEdit(playerid) || !GetPVarType(playerid, "JobEditID")) return -1;
	new id = GetPVarInt(playerid, "JobEditID");
	return 0 <= id < MAX_JOBPOINTS && JobData[id][jId] == id + 1 ? id : -1;
}

CMD:getjob(playerid, params[])
{
	return SendClientMessageEx(playerid, COLOR_GRAD1, "Nhan Y gan diem xin viec hoac dung /join de xin viec.");
}

CMD:jobpointhelp(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	SendClientMessageEx(playerid, COLOR_GREEN, "Lenh diem cong viec: /gotojob");
	if(Job_CanEdit(playerid)) SendClientMessageEx(playerid, COLOR_GRAD2, "Sua cong viec: /editjobpoint, /editjob");
	return 1;
}

CMD:gotojob(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	new id;
	if(sscanf(params, "i", id)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /gotojob [job point ID]");
	if(!(0 <= id < MAX_JOBPOINTS) || !IsValidDynamicArea(JobData[id][jAreaID])) return SendClientMessageEx(playerid, COLOR_GRAD2, "Diem cong viec chua duoc dat.");
	SetPlayerPos(playerid, JobData[id][jPos][0], JobData[id][jPos][1], JobData[id][jPos][2]);
	SetPlayerInterior(playerid, JobData[id][jInt]);
	PlayerInfo[playerid][pInt] = JobData[id][jInt];
	SetPlayerVirtualWorld(playerid, JobData[id][jVw]);
	PlayerInfo[playerid][pVW] = JobData[id][jVw];
	return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da toi diem cong viec ID %i.", id);
}

CMD:editjobpoint(playerid, params[])
{
	return ListJobPoints(playerid);
}

CMD:editjob(playerid, params[])
{
	if(!Job_CanEdit(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen lam vay.");
	Job_BuildMenu(szMiscArray, sizeof(szMiscArray));
	return Dialog_Show(playerid, job_name, DIALOG_STYLE_LIST, "Sua ten cong viec", szMiscArray, "Chon", "Huy");
}

Dialog:job_name(playerid, response, listitem, inputtext[])
{
	if(!response || !Job_CanEdit(playerid)) return 1;
	new type = Job_GetMenuType(listitem);
	if(type == JOB_NONE) return 1;
	SetPVarInt(playerid, "JobEditName", type);
	format(szMiscArray, sizeof(szMiscArray), "Nhap ten moi cho %s (ID: %d), dai tu 1 den %d ky tu.", GetJobName(type), type, sizeof(JobName[]) - 1);
	return Dialog_Show(playerid, job_name_confirm, DIALOG_STYLE_INPUT, "Sua ten cong viec", szMiscArray, "Sua", "Dong");
}

Dialog:job_name_confirm(playerid, response, listitem, inputtext[])
{
	if(!Job_CanEdit(playerid) || !GetPVarType(playerid, "JobEditName")) return 1;
	new id = GetPVarInt(playerid, "JobEditName");
	if(!response || !Job_IsAvailable(id)) return DeletePVar(playerid, "JobEditName");
	if(!(1 <= strlen(inputtext) < sizeof(JobName[])) || strfind(inputtext, "\n") != -1 || strfind(inputtext, "\r") != -1 || strfind(inputtext, "\t") != -1)
		return Dialog_Show(playerid, job_name_confirm, DIALOG_STYLE_INPUT, "Sua ten cong viec", "Dung tu 1 den 31 ky tu tren mot dong.", "Sua", "Dong");
	format(szMiscArray, sizeof(szMiscArray), "%s changed job %d's name from %s to %s.", GetPlayerNameEx(playerid), id, GetJobName(id), inputtext);
	Log("logs/jobedit.log", szMiscArray);
	format(JobName[id], sizeof(JobName[]), "%s", inputtext);
	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `jobs_types` SET `name`='%e' WHERE `id`=%d", inputtext, id);
	mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
	DeletePVar(playerid, "JobEditName");
	for(new point; point < MAX_JOBPOINTS; ++point) if(JobData[point][jType] == id) UpdateJobPoint(point);
	return SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi ten cong viec %d thanh %s.", id, GetJobName(id));
}

stock ListJobPoints(playerid, page = 0)
{
	if(!Job_CanEdit(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen lam vay.");
	if(!(0 <= page <= (MAX_JOBPOINTS - 1) / JOBPOINT_PAGE_SIZE)) return 1;
	SetPVarInt(playerid, "JobPointPage", page);
	szMiscArray[0] = EOS;
	new line[64], first = page * JOBPOINT_PAGE_SIZE, last = min(first + JOBPOINT_PAGE_SIZE, MAX_JOBPOINTS);
	for(new id = first; id < last; ++id)
	{
		format(line, sizeof(line), "%s(%d) %s{FFFFFF}", id > first ? "\n" : "", id, IsValidDynamicArea(JobData[id][jAreaID]) ? GetJobName(JobData[id][jType]) : "(Chua dat)");
		strcat(szMiscArray, line, sizeof(szMiscArray));
	}
	if(page > 0) strcat(szMiscArray, "\nTrang truoc", sizeof(szMiscArray));
	if(last < MAX_JOBPOINTS) strcat(szMiscArray, "\nTrang sau", sizeof(szMiscArray));
	return Dialog_Show(playerid, jobpoints, DIALOG_STYLE_LIST, "Sua diem cong viec", szMiscArray, "Chon", "Dong");
}

Dialog:jobpoints(playerid, response, listitem, inputtext[])
{
	if(!Job_CanEdit(playerid) || !GetPVarType(playerid, "JobPointPage")) return 1;
	new page = GetPVarInt(playerid, "JobPointPage");
	DeletePVar(playerid, "JobPointPage");
	if(!response || !(0 <= page <= (MAX_JOBPOINTS - 1) / JOBPOINT_PAGE_SIZE)) return 1;
	new first = page * JOBPOINT_PAGE_SIZE, count = min(JOBPOINT_PAGE_SIZE, MAX_JOBPOINTS - first);
	if(0 <= listitem < count) return JobEditID(playerid, first + listitem);
	if(page > 0 && listitem == count) return ListJobPoints(playerid, page - 1);
	if(first + count < MAX_JOBPOINTS && listitem == count + (page > 0 ? 1 : 0)) return ListJobPoints(playerid, page + 1);
	return 1;
}

stock JobEditID(playerid, jobid)
{
	if(!Job_CanEdit(playerid) || !(0 <= jobid < MAX_JOBPOINTS)) return 1;
	if(JobData[jobid][jId] != jobid + 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Chua tai ban ghi nen cua diem cong viec nay.");
	SetPVarInt(playerid, "JobEditID", jobid);
	new title[64];
	format(title, sizeof(title), "Sua %s | Diem %d", GetJobName(JobData[jobid][jType]), jobid);
	format(szMiscArray, sizeof(szMiscArray), "Loai cong viec:\t%s\nChuyen diem cong viec den cho toi\nCap nguoi choi toi thieu:\t%d\nXoa vi tri cong viec", GetJobName(JobData[jobid][jType]), JobData[jobid][jLevel]);
	return Dialog_Show(playerid, editjob, DIALOG_STYLE_TABLIST, title, szMiscArray, "Chon", "Quay lai");
}

Dialog:editjob(playerid, response, listitem, inputtext[])
{
	new id = Job_GetEditPoint(playerid);
	if(id == -1) return 1;
	if(!response)
	{
		DeletePVar(playerid, "JobEditID");
		return ListJobPoints(playerid, id / JOBPOINT_PAGE_SIZE);
	}
	switch(listitem)
	{
		case 0:
		{
			Job_BuildMenu(szMiscArray, sizeof(szMiscArray));
			Dialog_Show(playerid, job_type, DIALOG_STYLE_LIST, "Sua loai cong viec", szMiscArray, "Chon", "Quay lai");
		}
		case 1: Dialog_Show(playerid, moveconfirm, DIALOG_STYLE_MSGBOX, "Chuyen diem cong viec", "Chuyen diem cong viec den vi tri, interior va world hien tai cua ban?", "Co", "Khong");
		case 2: Dialog_Show(playerid, job_level, DIALOG_STYLE_INPUT, "Yeu cau cap do", "Nhap cap nguoi choi toi thieu, tu 1 tro len.", "Luu", "Quay lai");
		case 3: Dialog_Show(playerid, pointdeleteconfirm, DIALOG_STYLE_MSGBOX, "Xoa vi tri cong viec", "Xoa diem cong viec khoi the gioi? Ban ghi database duoc giu de tai su dung.", "Co", "Khong");
	}
	return 1;
}

Dialog:job_type(playerid, response, listitem, inputtext[])
{
	new id = Job_GetEditPoint(playerid);
	if(id == -1) return 1;
	if(!response) return JobEditID(playerid, id);
	new type = Job_GetMenuType(listitem);
	if(type == JOB_NONE) return 1;
	format(szMiscArray, sizeof(szMiscArray), "%s changed job point %d's type from %d to %d.", GetPlayerNameEx(playerid), id, JobData[id][jType], type);
	Log("logs/jobedit.log", szMiscArray);
	JobData[id][jType] = type;
	SaveJobPoint(id);
	UpdateJobPoint(id);
	return JobEditID(playerid, id);
}

Dialog:job_level(playerid, response, listitem, inputtext[])
{
	new id = Job_GetEditPoint(playerid);
	if(id == -1) return 1;
	if(!response) return JobEditID(playerid, id);
	new level;
	for(new n; inputtext[n] != EOS; ++n)
	{
		if(!('0' <= inputtext[n] <= '9') || level > (cellmax - (inputtext[n] - '0')) / 10)
			return Dialog_Show(playerid, job_level, DIALOG_STYLE_INPUT, "Yeu cau cap do", "Nhap so nguyen hop le, tu 1 tro len.", "Luu", "Quay lai");
		level = level * 10 + inputtext[n] - '0';
	}
	if(level < 1) return Dialog_Show(playerid, job_level, DIALOG_STYLE_INPUT, "Yeu cau cap do", "Cap nguoi choi toi thieu phai tu 1 tro len.", "Luu", "Quay lai");
	format(szMiscArray, sizeof(szMiscArray), "%s changed job point %d's level from %d to %d.", GetPlayerNameEx(playerid), id, JobData[id][jLevel], level);
	Log("logs/jobedit.log", szMiscArray);
	JobData[id][jLevel] = level;
	SaveJobPoint(id);
	return JobEditID(playerid, id);
}

Dialog:moveconfirm(playerid, response, listitem, inputtext[])
{
	new id = Job_GetEditPoint(playerid);
	if(id == -1) return 1;
	if(!response) return JobEditID(playerid, id);
	format(szMiscArray, sizeof(szMiscArray), "%s moved job point %d from %.2f, %.2f, %.2f.", GetPlayerNameEx(playerid), id, JobData[id][jPos][0], JobData[id][jPos][1], JobData[id][jPos][2]);
	Log("logs/jobedit.log", szMiscArray);
	GetPlayerPos(playerid, JobData[id][jPos][0], JobData[id][jPos][1], JobData[id][jPos][2]);
	JobData[id][jInt] = GetPlayerInterior(playerid);
	JobData[id][jVw] = GetPlayerVirtualWorld(playerid);
	SaveJobPoint(id);
	UpdateJobPoint(id);
	return JobEditID(playerid, id);
}

Dialog:pointdeleteconfirm(playerid, response, listitem, inputtext[])
{
	new id = Job_GetEditPoint(playerid);
	if(id == -1) return 1;
	if(!response) return JobEditID(playerid, id);
	format(szMiscArray, sizeof(szMiscArray), "%s removed job point %d (%s).", GetPlayerNameEx(playerid), id, GetJobName(JobData[id][jType]));
	Log("logs/jobedit.log", szMiscArray);
	JobData[id][jType] = JOB_NONE;
	JobData[id][jPos][0] = JobData[id][jPos][1] = JobData[id][jPos][2] = 0.0;
	JobData[id][jVw] = JobData[id][jInt] = JobData[id][jMarkerID] = 0;
	JobData[id][jLevel] = 1;
	SaveJobPoint(id);
	UpdateJobPoint(id);
	DeletePVar(playerid, "JobEditID");
	return ListJobPoints(playerid, id / JOBPOINT_PAGE_SIZE);
}
