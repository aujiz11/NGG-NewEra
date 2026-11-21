/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Report System

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

forward ReplyTimer(reportid);
public ReplyTimer(reportid)
{
    Reports[reportid][ReportPriority] = 0;
    Reports[reportid][ReportLevel] = 0;
    Reports[reportid][BeingUsed] = 0;
	Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
    Reports[reportid][CheckingReport] = INVALID_PLAYER_ID;
}

stock SendReportToQue(reportfrom, const report[], reportlevel, reportpriority)
{
    new newid = INVALID_REPORT_ID, string[128];

	for(new i; i < MAX_REPORTS; ++i)
	{
		if(Reports[i][HasBeenUsed] == 0)
		{
			newid = i;
			break;
		}
    }
    if(newid != INVALID_REPORT_ID)
    {
        switch(reportpriority)
       	{
   	    	case 1:
   	    	{
	        	foreach(new i: Player)
				{
					if(PlayerInfo[i][pAdmin] >= 2 && PlayerInfo[i][pTogReports] == 0)
					{
						GameTextForPlayer(i, "~r~Canh bao DM", 1500, 1);
					}
				}	
    		}
 	    	case 2:
  	    	{
        		foreach(new i: Player)
				{
					if(PlayerInfo[i][pAdmin] >= reportlevel && PlayerInfo[i][pTogReports] == 0)
					{
						GameTextForPlayer(i, "~p~Bao cao uu tien", 1500, 1);
					}
				}	
			}
   			case 3..4:
 	    	{
       			foreach(new i: Player)
				{
					if(PlayerInfo[i][pAdmin] >= reportlevel && PlayerInfo[i][pTogReports] == 0)
					{
						TextDrawSetString(PriorityReport[i], "~y~Bao cao moi");
						TextDrawShowForPlayer(i, PriorityReport[i]);
						SetTimerEx("HideReportText", 2000, false, "d", i);
					}
				}	
    		}
 	    	case 5:
  	    	{
        		foreach(new i: Player)
				{
					if(PlayerInfo[i][pAdmin] >= reportlevel && PlayerInfo[i][pTogReports] == 0)
					{
						//GameTextForPlayer(i, "~w~~n~n~n~Priority 5 Item Pending", 1500, 3);
						TextDrawSetString(PriorityReport[i], "~w~Dang cho muc uu tien 5");
						TextDrawShowForPlayer(i, PriorityReport[i]);
						SetTimerEx("HideReportText", 2000, false, "d", i);
					}
				}	
    		}
     	}
     	foreach(new i: Player)
		{
			if(PlayerInfo[i][pAdmin] >= 2 && PlayerInfo[i][pTogReports] == 0 && !GetPVarType(i, "TogReports")) {
				SendClientMessageEx(i, COLOR_REPORT, "%s (ID: %i) | RID: %i | %s | Cho: 0 phut | UT: %i", GetPlayerNameEx(reportfrom), reportfrom, newid, report, reportpriority);
			}
			else if((reportpriority == 1 || reportpriority == 2) && PlayerInfo[i][pTogReports] == 0 && GetPVarType(i, "TogReports")) {
				SendClientMessageEx(i, COLOR_REPORT, "%s (ID: %i) | RID: %i | %s | Cho: 0 phut | UT: %i", GetPlayerNameEx(reportfrom), reportfrom, newid, report, reportpriority);
			}
		}	
     	SetPVarInt(reportfrom, "HasReport", 1);

     	format(string, sizeof(string), "%s | SQLID: %i | RID: %i | Report: %s | Pr: %i", GetPlayerNameEx(reportfrom), GetPlayerSQLId(reportfrom), newid, report, reportpriority);
     	Log("logs/report.log", string);

        if(reportlevel == 2)
		{
        	strmid(Reports[newid][Report], report, 0, strlen(report), 128);
        	Reports[newid][ReportFrom] = reportfrom;
        	Reports[newid][TimeToExpire] = 0;
        	Reports[newid][HasBeenUsed] = 1;
        	Reports[newid][BeingUsed] = 1;
        	Reports[newid][ReportPriority] = reportpriority;
            Reports[newid][ReportExpireTimer] = SetTimerEx("ReportTimer", 60000, false, "d", newid);
		}
		else
		{
		    strmid(Reports[newid][Report], report, 0, strlen(report), 128);
        	Reports[newid][ReportFrom] = reportfrom;
        	Reports[newid][TimeToExpire] = 0;
        	Reports[newid][HasBeenUsed] = 1;
        	Reports[newid][BeingUsed] = 1;
        	Reports[newid][ReportPriority] = reportpriority;
            Reports[newid][ReportExpireTimer] = SetTimerEx("ReportTimer", 60000, false, "d", newid);
		}
    }
    else
    {
        ClearReports();
        SendReportToQue(reportfrom, report, reportlevel, reportpriority);
    }
}

stock ClearReports()
{
	for(new i=0;i<MAX_REPORTS;i++)
	{
	    if(Reports[i][BeingUsed] == 1) {
			DeletePVar(Reports[i][ReportFrom], "HasReport");
		}
		if(GetPVarInt(Reports[i][ReportFrom], "AlertedThisPlayer"))
		{
			DeletePVar(Reports[i][ReportFrom], "AlertedThisPlayer");
			DeletePVar(Reports[i][ReportFrom], "AlertType");
			if(AlertTime[Reports[i][ReportFrom]] != 0) AlertTime[Reports[i][ReportFrom]] = 0;
		}
		strmid(Reports[i][Report], "None", 0, 4, 4);
		Reports[i][CheckingReport] = INVALID_PLAYER_ID;
        Reports[i][ReportFrom] = INVALID_PLAYER_ID;
        Reports[i][TimeToExpire] = 0;
        Reports[i][HasBeenUsed] = 0;
        Reports[i][BeingUsed] = 0;
        Reports[i][ReportPriority] = 0;
        Reports[i][ReportLevel] = 0;
	}
	return 1;
}

forward ReportTimer(reportid);
public ReportTimer(reportid)
{
	if(Reports[reportid][BeingUsed] == 1)
	{
	    if(Reports[reportid][TimeToExpire] >= 0)
	    {
	        Reports[reportid][TimeToExpire]++;
            Reports[reportid][ReportExpireTimer] = SetTimerEx("ReportTimer", 60000, false, "d", reportid);
		}
	}
	return 1;
}

CMD:clearallreports(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 1337) {
        new string[128];
        ClearReports();
        SendClientMessageEx(playerid,COLOR_GRAD1, "Ban da xoa tat ca bao cao dang cho.");
        format(string, sizeof(string), "AdmCmd: %s da xoa tat ca bao cao dang cho.", GetPlayerNameEx(playerid));
        ABroadCast(COLOR_LIGHTRED, string, 2);
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:checkreportcount(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], adminname[MAX_PLAYER_NAME], tdate[11];
		if(sscanf(params, "s[24]s[11]", adminname, tdate)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /checkreportcount [admin name] [date (YYYY-MM-DD)]");
		new giveplayerid = ReturnUser(adminname);
		if(IsPlayerConnected(giveplayerid) && PlayerInfo[giveplayerid][pAdmin] >= 2)
		{
			mysql_format(MainPipeline, string, sizeof(string), "SELECT SUM(count) FROM `tokens_report` WHERE `playerid` = %d AND `date` = '%s'", GetPlayerSQLId(giveplayerid), tdate);
			mysql_tquery(MainPipeline, string, "QueryCheckCountFinish", "issi", playerid, GetPlayerNameEx(giveplayerid), tdate, 0);
			mysql_format(MainPipeline, string, sizeof(string), "SELECT `count`, `hour` FROM `tokens_report` WHERE `playerid` = %d AND `date` = '%s' ORDER BY `hour` ASC", GetPlayerSQLId(giveplayerid), tdate);
			mysql_tquery(MainPipeline, string, "QueryCheckCountFinish", "issi", playerid, GetPlayerNameEx(giveplayerid), tdate, 1);
		}
		else
		{
			new tmpName[MAX_PLAYER_NAME];
			mysql_escape_string(adminname, tmpName);
			mysql_format(MainPipeline, string, sizeof(string), "SELECT `id`, `Username` FROM `accounts` WHERE `Username` = '%s'", tmpName);
			mysql_tquery(MainPipeline, string, "QueryUsernameCheck", "isi", playerid, tdate, 0);
		}
    }
    return 1;
}

CMD:togchatreports(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2) {

	    if(GetPVarType(playerid, "TogReports")) {

	        DeletePVar(playerid, "TogReports");
	        SendClientMessageEx(playerid, COLOR_WHITE, "Ban se thay tat ca bao cao.");
	    }
	    else {
	        SetPVarInt(playerid, "TogReports", 1);
	        SendClientMessageEx(playerid, COLOR_WHITE, "Ban se chi thay bao cao uu tien.");
	    }
	}
	return 1;
}

CMD:togreports(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pUndercover] >= 1)
	{
		switch(PlayerInfo[playerid][pTogReports])
		{
			case 0:
			{
				PlayerInfo[playerid][pTogReports] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bat che do spec ops, ban se khong thay thong bao Admin.");
			}
			case 1:
			{
				PlayerInfo[playerid][pTogReports] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da tat che do spec ops, ban se thay lai thong bao Admin.");
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:reporttips(playerid, params[])
{
	ShowPlayerDialogEx(playerid,7955,DIALOG_STYLE_MSGBOX,"Luu y khi bao cao","Luu y khi bao cao:\n- Neu ro viec can ho tro, khong yeu cau ten Admin.\n- Mo ta cu the van de.\n- Khong bao cao sai su that.\n- Khong xuc pham Admin.\n- Chi bao cao van de trong game.\n- Don hang shop dung lenh /shoporder","Dong", "");
	return 1;
}

CMD:reply(playerid, params[])
{
	new reportid = INVALID_REPORT_ID;
	for(new i = 0; i < MAX_REPORTS; i++)
	{
		if(Reports[i][ReportFrom] == playerid && Reports[i][CheckingReport] != INVALID_PLAYER_ID)
		{
			reportid = i;
		}
	}
	if(reportid == INVALID_REPORT_ID)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co bao cao dang duoc xem xet.");
		return 1;
	}
	if (IsPlayerConnected(Reports[reportid][CheckingReport]))
	{
		SendClientMessageEx(Reports[reportid][CheckingReport], COLOR_YELLOW, "%s(ID: %d) tra loi: %s", GetPlayerNameEx(playerid), playerid, params);

		SendClientMessageEx(playerid,  COLOR_YELLOW, "Da tra loi %s: %s", GetPlayerNameEx(Reports[reportid][CheckingReport]), params);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi chua ket noi.");
	return 1;
}

CMD:rmute(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rmute [player]");
		if(PlayerInfo[giveplayerid][pAdmin] > 1) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the cam Admin gui bao cao.");
		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pRMuted] == 0)
			{
				PlayerInfo[giveplayerid][pRMuted] = 1;
				format(string, sizeof(string), "AdmCmd: %s da cam vo thoi han %s gui bao cao.",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Ban bi %s cam gui /reports.", GetPlayerNameEx(playerid));
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Ban khong the gui bao cao cho den khi duoc go cam. Lien he hr@ng-gaming.net de khieu nai.");
				format(string, sizeof(string), "AdmCmd: %s(%d) was blocked from /report by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/mute.log", string);
			}
			else
			{
				PlayerInfo[giveplayerid][pRMuted] = 0;
				format(string, sizeof(string), "AdmCmd: %s da duoc %s cho phep gui bao cao tro lai",GetPlayerNameEx(giveplayerid),GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Ban duoc %s cho phep gui /reports tro lai.", GetPlayerNameEx(playerid));
				format(string, sizeof(string), "AdmCmd: %s(%d) was unblocked from /report by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/mute.log", string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:rto(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		new string[512], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rto [player] [reason]");
		if(PlayerInfo[giveplayerid][pAdmin] > 1) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the cam Admin gui bao cao.");
		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pRMuted] == 0)
			{
			    if(PlayerInfo[giveplayerid][pRMutedTotal] == 0)
			    {
  					PlayerInfo[giveplayerid][pRMutedTotal] = 1;
					format(string, sizeof(string), "AdmCmd: %s da canh bao %s lan dau vi lam dung bao cao, ly do: %s",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					ABroadCast(COLOR_LIGHTRED,string,2);

					format(string, sizeof(string), "Admin canh bao ban khong duoc lam dung /report.\n\nTai pham voi /report co the bi tam cam /report hoac mat han quyen nay.");
					ShowPlayerDialogEx(giveplayerid,7954,DIALOG_STYLE_MSGBOX,"Canh bao lam dung bao cao", string,"Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s has given %s(%d) their first warning about report abuse, reason: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), reason);
					Log("logs/mute.log", string);

			    }
			    else if(PlayerInfo[giveplayerid][pRMutedTotal] == 1)
			    {
  					PlayerInfo[giveplayerid][pRMuted] = 2;
  					PlayerInfo[giveplayerid][pRMutedTotal] = 2;
					PlayerInfo[giveplayerid][pRMutedTime] = 15*60;
					format(string, sizeof(string), "AdmCmd: %s da tam cam %s gui bao cao, ly do: %s",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					ABroadCast(COLOR_LIGHTRED,string,2);

					format(string, sizeof(string), "Ban bi %s tam cam gui bao cao, ly do: %s.\n\nDay la lan thu hai, ban khong the dung /report trong 15 phut.\n\nTai pham voi /report co the bi cam /report lau hon hoac mat han quyen nay.", GetPlayerNameEx(playerid), reason);
					ShowPlayerDialogEx(giveplayerid,7954,DIALOG_STYLE_MSGBOX,"Tam cam gui bao cao", string,"Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) was temporarily blocked from /report by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
					Log("logs/mute.log", string);
			    }
			    else if(PlayerInfo[giveplayerid][pRMutedTotal] == 2)
			    {
  					PlayerInfo[giveplayerid][pRMuted] = 2;
  					PlayerInfo[giveplayerid][pRMutedTotal] = 3;
					PlayerInfo[giveplayerid][pRMutedTime] = 30*60;
					format(string, sizeof(string), "AdmCmd: %s da tam cam %s gui bao cao, ly do: %s",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					ABroadCast(COLOR_LIGHTRED,string,2);

					format(string, sizeof(string), "Ban bi %s tam cam gui bao cao, ly do: %s.\n\nDay la lan thu ba, ban khong the dung /report trong 30 phut.\n\nTai pham voi /report co the bi cam /report lau hon hoac mat han quyen nay.", GetPlayerNameEx(playerid), reason);
					ShowPlayerDialogEx(giveplayerid,7954,DIALOG_STYLE_MSGBOX,"Tam cam gui bao cao", string,"Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) was temporarily blocked from /report by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
					Log("logs/mute.log", string);
			    }
			    else if(PlayerInfo[giveplayerid][pRMutedTotal] == 3)
			    {
  					PlayerInfo[giveplayerid][pRMuted] = 2;
  					PlayerInfo[giveplayerid][pRMutedTotal] = 4;
					PlayerInfo[giveplayerid][pRMutedTime] = 45*60;
					format(string, sizeof(string), "AdmCmd: %s da tam cam %s gui bao cao, ly do: %s",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					ABroadCast(COLOR_LIGHTRED,string,2);

					format(string, sizeof(string), "Ban bi %s tam cam gui bao cao, ly do: %s.\n\nDay la lan thu tu, ban khong the dung /report trong 45 phut.\n\nTai pham voi /report co the bi cam /report lau hon hoac mat han quyen nay.", GetPlayerNameEx(playerid), reason);
					ShowPlayerDialogEx(giveplayerid,7954,DIALOG_STYLE_MSGBOX,"Tam cam gui bao cao", string,"Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) was temporarily blocked from /report by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
					Log("logs/mute.log", string);
				}
			    else if(PlayerInfo[giveplayerid][pRMutedTotal] == 4)
			    {
  					PlayerInfo[giveplayerid][pRMuted] = 2;
  					PlayerInfo[giveplayerid][pRMutedTotal] = 5;
					PlayerInfo[giveplayerid][pRMutedTime] = 60*60;
					format(string, sizeof(string), "AdmCmd: %s da tam cam %s gui bao cao, ly do: %s",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					ABroadCast(COLOR_LIGHTRED,string,2);

					format(string, sizeof(string), "Ban bi %s tam cam gui bao cao, ly do: %s.\n\nDay la lan thu nam, ban khong the dung /report trong 60 phut.\n\nTai pham voi /report co the mat han quyen nay.", GetPlayerNameEx(playerid), reason);
					ShowPlayerDialogEx(giveplayerid,7954,DIALOG_STYLE_MSGBOX,"Tam cam gui bao cao", string,"Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) was temporarily blocked from /report by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
					Log("logs/mute.log", string);
				}
			    else if(PlayerInfo[giveplayerid][pRMutedTotal] >= 5)
			    {
  					PlayerInfo[giveplayerid][pRMuted] = 2;
  					PlayerInfo[giveplayerid][pRMutedTotal] = 6;
					PlayerInfo[giveplayerid][pRMutedTime] = 300*60;
					format(string, sizeof(string), "AdmCmd: %s da tam cam %s gui bao cao, ly do: %s",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
					ABroadCast(COLOR_LIGHTRED,string,2);

					format(string, sizeof(string), "Ban bi %s tam cam gui bao cao, ly do: %s.\n\nDay la lan thu sau, ban khong the dung /report trong 5 gio.\n\nTai pham voi /report co the mat han quyen nay.", GetPlayerNameEx(playerid), reason);
					ShowPlayerDialogEx(giveplayerid,7954,DIALOG_STYLE_MSGBOX,"Tam cam gui bao cao", string,"Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) was temporarily blocked from /report by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
					Log("logs/mute.log", string);
				}

				for(new i = 0; i < MAX_REPORTS; i++)
				{
					if(Reports[i][ReportFrom] == giveplayerid)
					{
						Reports[i][BeingUsed] = 0;
					}
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do da bi cam /reports.");
			}

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:rtoreset(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rtoreset [player] [reason]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pRMuted] == 2)
			{
				PlayerInfo[giveplayerid][pRMuted] = 0;
				PlayerInfo[giveplayerid][pRMutedTotal]--;
				PlayerInfo[giveplayerid][pRMutedTime] = 0;
				format(string, sizeof(string), "AdmCmd: %s da go cam gui bao cao cho %s, ly do: %s",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid), reason);
				ABroadCast(COLOR_LIGHTRED,string,2);
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Ban da duoc go cam va co the gui bao cao tro lai.");
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chung toi xin loi ve sai sot va bat tien da gay ra.");
				format(string, sizeof(string), "AdmCmd: %s(%d) was unblocked from /report by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
				Log("logs/mute.log", string);
			}
			else
			{
			    SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong bi cam gui bao cao!");
			}

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:report(playerid, params[])
{
    if(GetPVarType(playerid, "HasReport")) {
		SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc gui 1 bao cao cung luc. (/cancelreport)");
	}
 	else if(PlayerInfo[playerid][pAdmin] >= 2 && PlayerInfo[playerid][pAdmin] < 1338) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Admin khong duoc gui bao cao.");
	}
	else if(PlayerInfo[playerid][pRMuted] != 0) {
	    ShowPlayerDialogEx(playerid, 7955, DIALOG_STYLE_MSGBOX,"Da chan bao cao","Ban dang bi cam gui bao cao!\n\nLuu y khi bao cao:\n- Neu ro viec can ho tro, khong yeu cau ten Admin.\n- Mo ta cu the van de.\n- Khong bao cao sai su that.\n- Khong xuc pham Admin.\n- Chi bao cao van de trong game.\n- Don hang shop dung lenh /shoporder","Dong", "");
	}
	else {
	    ShowPlayerDialogEx(playerid, DIALOG_REPORTMENU, DIALOG_STYLE_LIST, "Menu bao cao [1/2]", "Deathmatch\nBi roi\nGian lan\nChicken Running\nDam xe\nPower Gaming\nMeta Gaming\nLoi ban sung (QS/CS)\nSpam\nMoney Farming\nNe lenh cam\nLoi co the loi dung\nTiet lo ten Hitman\nLoi Running Man\nDung tren xe\nHanh vi NonRP\nTrang tiep","Chon", "Thoat");
	}
	return 1;
}

CMD:cancelreport(playerid, params[])
{
	for(new i = 999; i > 0; i--)
	{
		if(Reports[i][ReportFrom] == playerid)
		{
			if(GetPVarType(Reports[i][ReportFrom], "AlertedThisPlayer"))
			{
				DeletePVar(Reports[i][ReportFrom], "AlertedThisPlayer");
				DeletePVar(Reports[i][ReportFrom], "AlertType");
				if(AlertTime[Reports[i][ReportFrom]] != 0) AlertTime[Reports[i][ReportFrom]] = 0;
			}
			if(GetPVarInt(Reports[i][ReportFrom], "RequestingAdP") == 1)
			{
				DeletePVar(Reports[i][ReportFrom], "PriorityAdText");
				DeletePVar(Reports[i][ReportFrom], "RequestingAdP");
			}
			Reports[i][ReportFrom] = INVALID_PLAYER_ID;
			Reports[i][BeingUsed] = 0;
			Reports[i][TimeToExpire] = 0;
			Reports[i][ReportPriority] = 0;
			Reports[i][ReportLevel] = 0;
			strmid(Reports[i][Report], "None", 0, 4, 4);
			DeletePVar(playerid, "HasReport");
			DeletePVar(playerid, "_rAutoM");
			DeletePVar(playerid, "_rRepID");
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy bao cao." );
			return 1;
		}
	}
	SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co bao cao dang cho.");
	return 1;
}

CMD:reports(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		SendClientMessageEx(playerid, COLOR_GREEN, "____________________ BAO CAO _____________________");
		for(new i = 999; i >= 0; i--)
		{
			if(Reports[i][BeingUsed] == 1 && Reports[i][ReportPriority] == 5)
			{
			    if(Reports[i][ReportLevel] == 2 || PlayerInfo[playerid][pAdmin] >= 2)
			    {
					SendClientMessageEx(playerid, COLOR_REPORT, "%s (ID: %i) | RID: %i | %s | Cho: %d phut | UT: %i", GetPlayerNameEx(Reports[i][ReportFrom]), Reports[i][ReportFrom], i, (Reports[i][Report]), Reports[i][TimeToExpire], Reports[i][ReportPriority]);
				}
			}
		}
		for(new i = 999; i >= 0; i--)
		{
			if(Reports[i][BeingUsed] == 1 && Reports[i][ReportPriority] == 4)
			{
			    if(Reports[i][ReportLevel] == 2 || PlayerInfo[playerid][pAdmin] >= 2)
			    {
					SendClientMessageEx(playerid, COLOR_REPORT, "%s (ID: %i) | RID: %i | %s | Cho: %d phut | UT: %i", GetPlayerNameEx(Reports[i][ReportFrom]), Reports[i][ReportFrom], i, (Reports[i][Report]), Reports[i][TimeToExpire], Reports[i][ReportPriority]);
				}
			}
		}
		for(new i = 999; i >= 0; i--)
		{
			if(Reports[i][BeingUsed] == 1 && Reports[i][ReportPriority] == 3)
			{
			    if(Reports[i][ReportLevel] == 2 || PlayerInfo[playerid][pAdmin] >= 2)
			    {
					SendClientMessageEx(playerid, COLOR_REPORT, "%s (ID: %i) | RID: %i | %s | Cho: %d phut | UT: %i", GetPlayerNameEx(Reports[i][ReportFrom]), Reports[i][ReportFrom], i, (Reports[i][Report]), Reports[i][TimeToExpire], Reports[i][ReportPriority]);
				}
			}
		}
		for(new i = 999; i >= 0; i--)
		{
			if(Reports[i][BeingUsed] == 1 && Reports[i][ReportPriority] == 2)
			{
			    if(Reports[i][ReportLevel] == 2 || PlayerInfo[playerid][pAdmin] >= 2)
			    {
					SendClientMessageEx(playerid, COLOR_REPORT, "%s (ID: %i) | RID: %i | %s | Cho: %d phut | UT: %i", GetPlayerNameEx(Reports[i][ReportFrom]), Reports[i][ReportFrom], i, (Reports[i][Report]), Reports[i][TimeToExpire], Reports[i][ReportPriority]);
				}
			}
		}
		for(new i = 999; i >= 0; i--)
		{
			if(Reports[i][BeingUsed] == 1 && Reports[i][ReportPriority] == 1)
			{
			    if(Reports[i][ReportLevel] == 2 || PlayerInfo[playerid][pAdmin] >= 2)
			    {
					SendClientMessageEx(playerid, COLOR_REPORT, "%s (ID: %i) | RID: %i | %s | Cho: %d phut | UT: %i", GetPlayerNameEx(Reports[i][ReportFrom]), Reports[i][ReportFrom], i, (Reports[i][Report]), Reports[i][TimeToExpire], Reports[i][ReportPriority]);
				}
			}
		}
		SendClientMessageEx(playerid, COLOR_GREEN, "___________________________________________________");
	}
	return 1;
}

CMD:sta(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], reportid;
		if(sscanf(params, "d", reportid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /sta [reportid]");

		if(reportid < 0 || reportid > 999) { SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!"); return 1; }
		if(Reports[reportid][BeingUsed] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
			return 1;
		}
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo/dang quang cao nay, hay chap nhan bang /ar.");
		}
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			DeletePVar(Reports[reportid][ReportFrom], "AlertedThisPlayer");
			DeletePVar(Reports[reportid][ReportFrom], "AlertType");
			if(AlertTime[Reports[reportid][ReportFrom]] != 0) AlertTime[Reports[reportid][ReportFrom]] = 0;
		}
		if(Advisors < 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Chua co Advisor dang truc, hay thu lai sau!");
			return 1;
		}

		format(string, sizeof(string), "AdmCmd: %s chuyen bao cao cua %s (ID: %i) RID: %i) den Advisor.", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has sent %s (ID: %i) report RID: %i) to the Advisors.", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
		Log("logs/report.log", string);
		if(PlayerInfo[playerid][pAdmin] == 1)
		{
			SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Admin da xem va chuyen bao cao cua ban den Advisor.");
			SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Advisor se den ho tro ban som.");
			SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Nguoi moi nen dung /requesthelp de hoi dap. Lenh /report dung de bao cao vi pham va yeu cau Admin ho tro.");
			SetPVarInt( Reports[reportid][ReportFrom], "COMMUNITY_ADVISOR_REQUEST", 1 );
			format(string, sizeof(string), "Admin da chuyen bao cao den ban. %s (ID: %d) cho biet: %s", GetPlayerNameEx(Reports[reportid][ReportFrom]), Reports[reportid][ReportFrom], Reports[reportid][Report]);
			SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
			SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, "Dung /accepthelp de den cho nguoi choi.");
		}
		else
		{
			SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "%s da xem va chuyen bao cao cua ban den Advisor.", GetPlayerNameEx(playerid));
			SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Advisor se den ho tro ban som.");
			SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Nguoi moi nen dung /requesthelp de hoi dap. Lenh /report dung de bao cao vi pham va yeu cau Admin ho tro.");
			SetPVarInt( Reports[reportid][ReportFrom], "COMMUNITY_ADVISOR_REQUEST", 1 );
			format(string, sizeof(string), "Admin %s da chuyen bao cao den ban. %s (ID: %d) cho biet: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), Reports[reportid][ReportFrom], Reports[reportid][Report]);
			SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
			SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, "Dung /accepthelp de den cho nguoi choi.");
		}

		PlayerInfo[playerid][pAcceptReport]++;
		ReportCount[playerid]++;
		ReportHourCount[playerid]++;
		Reports[reportid][BeingUsed] = 0;
		DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");		Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
		Reports[reportid][CheckingReport] = INVALID_PLAYER_ID;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
	}
	return 1;
}

CMD:ar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], reportid;
		if(sscanf(params, "d", reportid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ar [reportid]");

		if(reportid < 0 || reportid > 999) { SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!"); return 1; }
		if(Reports[reportid][BeingUsed] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
			return 1;
		}
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "ReverseReport") == 1) 
		{
			new reversereason[24];
			GetPVarString(Reports[reportid][ReportFrom], "ReverseReason", reversereason, 24);
			DeletePVar(Reports[reportid][ReportFrom], "ReverseReport");
			SetPVarInt(playerid, "ReverseFromID", Reports[reportid][ReportFrom]);
			format(string, 128, "%s muon huy hinh phat da ap dung voi %s.\n\nLy do: %s", GetPlayerNameEx(Reports[reportid][ReportFrom]), GetPlayerNameEx(GetPVarInt(Reports[reportid][ReportFrom], "ReverseID")), reversereason);
			ShowPlayerDialogEx(playerid, DIALOG_REVERSE, DIALOG_STYLE_MSGBOX, "Huy hinh phat", string, "Cho phep", "Tu choi");
			format(string, sizeof(string), "AdmCmd: %s da nhan bao cao cua %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			ABroadCast(COLOR_ORANGE, string, 2);
     		format(string, sizeof(string), "AdmCmd: %s has accepted the report from %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
     		Log("logs/report.log", string);
			PlayerInfo[playerid][pAcceptReport]++;
			ReportCount[playerid]++;
			ReportHourCount[playerid]++;
			Reports[reportid][BeingUsed] = 0;
			Reports[reportid][TimeToExpire] = 0;
			strmid(Reports[reportid][Report], "None", 0, 4, 4);
			DeletePVar(Reports[reportid][ReportFrom], "HasReport");
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "AccountRestrictionReport") == 1)
		{
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong duoc nhan bao cao nay!");
			SetPVarInt(playerid, "PendingAction4", GetPVarInt(Reports[reportid][ReportFrom], "AccountRestID"));
			DeletePVar(Reports[reportid][ReportFrom], "AccountRestrictionReport");
			DeletePVar(Reports[reportid][ReportFrom], "AccountRestID");
			ShowPlayerDialogEx(playerid, DIALOG_NONRPACTION, DIALOG_STYLE_MSGBOX, "Han che tai khoan", "Nguoi choi co 15+ diem Non RP, ban muon han che tai khoan nay khong?", "Co", "Khong");
		}
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			if(AlertTime[Reports[reportid][ReportFrom]] != 0)
			{
				SetPVarInt(playerid, "PendingAction", GetPVarInt(Reports[reportid][ReportFrom], "AlertType"));
				SetPVarInt(playerid, "PendingAction2", GetPVarInt(Reports[reportid][ReportFrom], "AlertedThisPlayer"));
				SetPVarInt(playerid, "PendingAction3", Reports[reportid][ReportFrom]);
				DeletePVar(Reports[reportid][ReportFrom], "AlertedThisPlayer");
			}
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1)
		{
			new advert[128];
			GetPVarString(Reports[reportid][ReportFrom], "PriorityAdText", advert, 128);
			SetPVarInt(playerid, "ReporterID", Reports[reportid][ReportFrom]);
			ShowPlayerDialogEx(playerid, DIALOG_CONFIRMADP, DIALOG_STYLE_MSGBOX, "Xac nhan quang cao", advert, "Duyet", "Tu choi");
			
			format(string, sizeof(string), "AdmCmd: %s da nhan bao cao cua %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			ABroadCast(COLOR_ORANGE, string, 2);
			format(string, sizeof(string), "AdmCmd: %s has accepted the report from %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			Log("logs/report.log", string);
			PlayerInfo[playerid][pAcceptReport]++;
			ReportCount[playerid]++;
			ReportHourCount[playerid]++;
			Reports[reportid][BeingUsed] = 0;
			Reports[reportid][TimeToExpire] = 0;
			strmid(Reports[reportid][Report], "None", 0, 4, 4);
			DeletePVar(Reports[reportid][ReportFrom], "HasReport");
			return true;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingNameChange") == 1) {
		    new newname[MAX_PLAYER_NAME];
			GetPVarString(Reports[reportid][ReportFrom], "NewNameRequest", newname, MAX_PLAYER_NAME);

			if(GetPVarInt(Reports[reportid][ReportFrom], "NameChangeCost") > 2) format(string, sizeof(string), "{00BFFF}Ten cu: {FFFFFF}%s\n\n{00BFFF}Ten moi: {FFFFFF}%s\n\n{00BFFF}Gia: ${FFFFFF}%s", GetPlayerNameExt(Reports[reportid][ReportFrom]), newname, number_format(GetPVarInt(Reports[reportid][ReportFrom], "NameChangeCost")));
			else format(string, sizeof(string), "{00BFFF}Ten cu: {FFFFFF}%s\n\n{00BFFF}Ten moi: {FFFFFF}%s\n\n{00BFFF}Gia: {FFFFFF}Mien phi", GetPlayerNameExt(Reports[reportid][ReportFrom]), newname);
			ShowPlayerDialogEx(playerid, DIALOG_REPORTNAME,DIALOG_STYLE_MSGBOX,"{00BFFF}Yeu cau doi ten",string,"Duyet","Tu choi");

			format(string, sizeof(string), "AdmCmd: %s da nhan bao cao cua %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			ABroadCast(COLOR_ORANGE, string, 2);
			format(string, sizeof(string), "AdmCmd: %s has accepted the report from %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			Log("logs/report.log", string);
			PlayerInfo[playerid][pAcceptReport]++;
			ReportCount[playerid]++;
			ReportHourCount[playerid]++;
			Reports[reportid][BeingUsed] = 0;
			Reports[reportid][TimeToExpire] = 0;
			strmid(Reports[reportid][Report], "None", 0, 4, 4);
			DeletePVar(Reports[reportid][ReportFrom], "HasReport");

			SetPVarInt(playerid, "NameChange",Reports[reportid][ReportFrom]);
		    return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RFLNameRequest") == 1) {
		    new newname[MAX_PLAYER_NAME];
			new gid = Reports[reportid][ReportFrom];
			GetPVarString(Reports[reportid][ReportFrom], "NewRFLName", newname, MAX_PLAYER_NAME);

			format(string, sizeof(string), "{00BFFF}Ten doi cu: {FFFFFF}%s\n\n{00BFFF}Ten doi moi: {FFFFFF}%s", RFLInfo[PlayerInfo[gid][pRFLTeam]][RFLname], newname);
			ShowPlayerDialogEx(playerid, DIALOG_REPORTTEAMNAME,DIALOG_STYLE_MSGBOX,"{00BFFF}Yeu cau doi ten doi",string,"Duyet","Tu choi");

			format(string, sizeof(string), "AdmCmd: %s da nhan bao cao cua %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			ABroadCast(COLOR_ORANGE, string, 2);
			format(string, sizeof(string), "AdmCmd: %s has accepted the report from %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			Log("logs/report.log", string);
			PlayerInfo[playerid][pAcceptReport]++;
			ReportCount[playerid]++;
			ReportHourCount[playerid]++;
			Reports[reportid][BeingUsed] = 0;
			Reports[reportid][TimeToExpire] = 0;
			strmid(Reports[reportid][Report], "None", 0, 4, 4);
			DeletePVar(Reports[reportid][ReportFrom], "HasReport");

			SetPVarInt(playerid, "RFLNameChange",Reports[reportid][ReportFrom]);
		    return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "hSignRequest")) {
			new hSignTxt[64];
			GetPVarString(Reports[reportid][ReportFrom], "hSignRequestText", hSignTxt, 64);
			ShowPlayerDialogEx(playerid, DIALOG_REPORT_HSIGN, DIALOG_STYLE_MSGBOX, "{00BFFF}Doi noi dung bien ban nha", hSignTxt, "Duyet", "Tu choi");

			format(string, sizeof(string), "AdmCmd: %s da nhan bao cao cua %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			ABroadCast(COLOR_ORANGE, string, 2);
			format(string, sizeof(string), "AdmCmd: %s has accepted the report from %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
			Log("logs/report.log", string);
			PlayerInfo[playerid][pAcceptReport]++;
			ReportCount[playerid]++;
			ReportHourCount[playerid]++;
			Reports[reportid][BeingUsed] = 0;
			Reports[reportid][TimeToExpire] = 0;
			strmid(Reports[reportid][Report], "None", 0, 4, 4);
			DeletePVar(Reports[reportid][ReportFrom], "HasReport");
			SetPVarInt(playerid, "hSignTextChange", Reports[reportid][ReportFrom]);
			return 1;
		}
		format(string, sizeof(string), "AdmCmd: %s da nhan bao cao cua %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has accepted the report from %s (ID: %i, RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]),Reports[reportid][ReportFrom],reportid);
		Log("logs/report.log", string);
		AddReportToken(playerid); // Report Tokens
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "%s da nhan va dang xem bao cao cua ban, dung /reply de gui tin nhan cho Admin nay.", GetPlayerNameEx(playerid));
		new giveplayerid;
		if(GetPVarType(Reports[reportid][ReportFrom], "_rAutoM")) {
			switch(GetPVarInt(Reports[reportid][ReportFrom], "_rAutoM")) {
				case 1: { // Ad Unmute
					ShowAdMuteFine(Reports[reportid][ReportFrom]);
					SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban da de nghi go cam /ads cho %s.", GetPlayerNameEx(Reports[reportid][ReportFrom]));
				}
				case 2: { // NUnmute
					ShowNMuteFine(Reports[reportid][ReportFrom]);
					SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban da de nghi go cam /newb cho %s.", GetPlayerNameEx(Reports[reportid][ReportFrom]));
				}
				case 3: { // NRN
					giveplayerid = GetPVarInt(Reports[reportid][ReportFrom], "_rRepID");
					if(IsPlayerConnected(giveplayerid)) {
						if (PlayerInfo[giveplayerid][pAdmin] < 2) {
							format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s da de nghi cho %s doi ten mien phi vi ten khong dung RP.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
							foreach(new i: Player)
							{	
								if(PlayerInfo[i][pSMod] == 1) {
									SendClientMessageEx(i, COLOR_YELLOW, string);
								}
							}	
							ABroadCast( COLOR_YELLOW, string, 2);
							ShowPlayerDialogEx(giveplayerid, DIALOG_NAMECHANGE2, DIALOG_STYLE_INPUT, "Doi ten mien phi","May chu roleplay yeu cau ten theo dang: Firstname_Lastname.\nVi du: John_Smith hoac Jimmy_Johnson\n\nAdmin cho phep ban doi ten dung dinh dang mien phi. Nhap ten mong muon ben duoi.\n\nLuu y: Nhan huy se bi ngat ket noi khoi may chu.", "Doi", "Huy" );
						}
						else
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Khong the de nghi Admin doi ten nrn.");
						}
					}
				}
				case 4: { // RK /kills
					giveplayerid = GetPVarInt(Reports[reportid][ReportFrom], "_rRepID");
					if(IsPlayerConnected(giveplayerid)) {
						SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
						SendClientMessageEx(playerid, COLOR_YELLOW, "<< 10 lan giet/chet moi cua %s >>", GetPlayerNameEx(giveplayerid));
						GetLatestKills(playerid, giveplayerid);
						SpectatePlayer(playerid, giveplayerid);
					}
				}
				case 5: { // Auto Spectate
					giveplayerid = GetPVarInt(Reports[reportid][ReportFrom], "_rRepID");
					if(IsPlayerConnected(giveplayerid)) {
						SpectatePlayer(playerid, giveplayerid);
					}
				}
				case 6: { // Bug Player
					giveplayerid = GetPVarInt(Reports[reportid][ReportFrom], "_rRepID");
					if(IsPlayerConnected(giveplayerid)) {
						SetPVarInt(playerid, "BigEar", 6);
						SetPVarInt(playerid, "BigEarPlayer", giveplayerid);
						rBigEarT[playerid] = 30;
						SendClientMessageEx(playerid, COLOR_WHITE, "Ban se nghe moi tin nhan cua %s (ID: %d) trong 30 giay. Dung /bigears de tat.", GetPlayerNameEx(giveplayerid), giveplayerid);
					}	
				}
			}
		}		PlayerInfo[playerid][pAcceptReport]++;
		ReportCount[playerid]++;
		ReportHourCount[playerid]++;
		Reports[reportid][ReplyTimerr] = SetTimerEx("ReplyTimer", 30000, false, "d", reportid);
		Reports[reportid][CheckingReport] = playerid;
		Reports[reportid][BeingUsed] = 0;
		Reports[reportid][TimeToExpire] = 0;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
		DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");	}
	return 1;
}

CMD:tr(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], reportid;
		if(sscanf(params, "d", reportid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /tr [reportid]");

		if(reportid < 0 || reportid > 999) { SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!"); return 1; }
		if(Reports[reportid][BeingUsed] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
			return 1;
		}
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo/dang quang cao nay, hay chap nhan bang /ar.");
		}
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			DeletePVar(Reports[reportid][ReportFrom], "AlertedThisPlayer");
			DeletePVar(Reports[reportid][ReportFrom], "AlertType");
			if(AlertTime[Reports[reportid][ReportFrom]] != 0) AlertTime[Reports[reportid][ReportFrom]] = 0;
		}
		format(string, sizeof(string), "AdmCmd: %s da loai bao cao cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]));
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has trashed the report from %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]));
		Log("logs/report.log", string);
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "%s danh dau bao cao khong hop le, khong xem xet. Hay doc /reporttips", GetPlayerNameEx(playerid));
		PlayerInfo[playerid][pTrashReport]++;
        DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");		Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
		Reports[reportid][BeingUsed] = 0;
		Reports[reportid][TimeToExpire] = 0;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
	}
	return 1;
}

CMD:dmr(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], reportid, giveplayerid;
		if(sscanf(params, "du", reportid, giveplayerid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /dmr [reportid] [DM'ers ID]");

		if(reportid < 0 || reportid > 999) { SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!"); return 1; }
		if(Reports[reportid][BeingUsed] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
			return 1;
		}
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo/dang quang cao nay, hay chap nhan bang /ar.");
		}
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the chuyen canh bao DM den Watch Dogs Team.");
		}
		format(string, sizeof(string), "AdmCmd: %s da chuyen bao cao cua %s (RID: %d) den he thong bao cao DM", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has forwarded the report from %s (RID: %d) to the DM Report system", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		Log("logs/report.log", string);
		format(string, sizeof(string), "%s da tiep nhan bao cao DM cua ban.", GetPlayerNameEx(playerid));
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, string);
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Lan sau hay dung /dmreport de bao cao DM.");

		if(PlayerInfo[Reports[reportid][ReportFrom]][pAdmin] >= 2 || PlayerInfo[Reports[reportid][ReportFrom]][pSMod] == 1) mysql_format(MainPipeline, string, sizeof(string), "INSERT INTO dm_watchdog (id,reporter,timestamp,superwatch) VALUES (%d,%d,%d,1)", GetPlayerSQLId(giveplayerid), GetPlayerSQLId(Reports[reportid][ReportFrom]), gettime());
		else mysql_format(MainPipeline, string, sizeof(string), "INSERT INTO dm_watchdog (id,reporter,timestamp) VALUES (%d,%d,%d)", GetPlayerSQLId(giveplayerid), GetPlayerSQLId(Reports[reportid][ReportFrom]), gettime());
		mysql_tquery(MainPipeline, string, "OnQueryFinish", "ii", SENDDATA_THREAD, Reports[reportid][ReportFrom]);

        DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");     	Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
		Reports[reportid][BeingUsed] = 0;
		Reports[reportid][TimeToExpire] = 0;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
	}
	return 1;
}

CMD:nao(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], reportid;
		if(sscanf(params, "d", reportid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /nao [reportid]");

		if(reportid < 0 || reportid > 999) { SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!"); return 1; }
		if(Reports[reportid][BeingUsed] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
			return 1;
		}
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo/dang quang cao nay, hay chap nhan bang /ar.");
		}
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			DeletePVar(Reports[reportid][ReportFrom], "AlertedThisPlayer");
			DeletePVar(Reports[reportid][ReportFrom], "AlertType");
			if(AlertTime[Reports[reportid][ReportFrom]] != 0) AlertTime[Reports[reportid][ReportFrom]] = 0;
		}
		format(string, sizeof(string), "AdmCmd: %s da dong bao cao cua %s (RID: %d) vi khong co Admin du quyen online.", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has cleared report from %s (RID: %d) due to not having admin of sufficient authority online.", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		Log("logs/report.log", string);
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "%s da xem bao cao, nhung hien khong co Admin du quyen xu ly yeu cau cua ban.", GetPlayerNameEx(playerid));
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Ban co the dang yeu cau tren dien dan (www.ng-gaming.net/forums) de duoc ho tro them. Xin loi ve su bat tien nay.");
        DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");	
		Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
		Reports[reportid][BeingUsed] = 0;
		Reports[reportid][TimeToExpire] = 0;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
	}
	return 1;
}

CMD:post(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], reportid;
		if(sscanf(params, "d", reportid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /post [reportid]");

		if(reportid < 0 || reportid > 999) { SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!"); return 1; }
		if(Reports[reportid][BeingUsed] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
			return 1;
		}
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo/dang quang cao nay, hay chap nhan bang /ar.");
		}
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			DeletePVar(Reports[reportid][ReportFrom], "AlertedThisPlayer");
			DeletePVar(Reports[reportid][ReportFrom], "AlertType");
			if(AlertTime[Reports[reportid][ReportFrom]] != 0) AlertTime[Reports[reportid][ReportFrom]] = 0;
		}
		format(string, sizeof(string), "AdmCmd: %s da dong bao cao cua %s (RID: %d) vi can xu ly tren dien dan", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has cleared report from %s (RID: %d) due to it needing to be handled on the forums", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		Log("logs/report.log", string);
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "%s da xem va xac dinh bao cao cua ban can xu ly tren dien dan (khieu nai hoac yeu cau).", GetPlayerNameEx(playerid));
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Chi bao cao su viec dang dien ra trong game. (www.ng-gaming.net/forums)");
        DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");		Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
		Reports[reportid][BeingUsed] = 0;
		Reports[reportid][TimeToExpire] = 0;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
	}
	return 1;
}

CMD:st(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], reportid;
		if(sscanf(params, "d", reportid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /st [reportid]");

		if(reportid < 0 || reportid > 999) { SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!"); return 1; }
		if(Reports[reportid][BeingUsed] == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
			return 1;
		}
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo/dang quang cao nay, hay chap nhan bang /ar.");
		}
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			DeletePVar(Reports[reportid][ReportFrom], "AlertedThisPlayer");
			DeletePVar(Reports[reportid][ReportFrom], "AlertType");
			if(AlertTime[Reports[reportid][ReportFrom]] != 0) AlertTime[Reports[reportid][ReportFrom]] = 0;
		}
		format(string, sizeof(string), "AdmCmd: %s da dong bao cao cua %s (RID: %d) vi can xu ly qua /shoporder", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has cleared report from %s (RID: %d) due to it needing to be handled via /shoporder", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		Log("logs/report.log", string);
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "%s da xem va xac dinh bao cao can duoc Shop Tech xu ly.", GetPlayerNameEx(playerid));
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Hay dung /shoporder de Shop Tech xu ly don hang cua ban.");
        DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
		Reports[reportid][BeingUsed] = 0;
		Reports[reportid][TimeToExpire] = 0;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
	}
	return 1;
}

CMD:ts(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], reportid;
		if(sscanf(params, "d", reportid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /ts [reportid]");
		if(reportid < 0 || reportid > 999) return SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao phai tu 0 den 999!");
		if(Reports[reportid][BeingUsed] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
		if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			return 1;
		}
		if(GetPVarInt(Reports[reportid][ReportFrom], "RequestingAdP") == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo/ts quang cao nay, hay chap nhan bang /ar.");
		if(GetPVarType(Reports[reportid][ReportFrom], "AlertedThisPlayer"))
		{
			DeletePVar(Reports[reportid][ReportFrom], "AlertedThisPlayer");
			DeletePVar(Reports[reportid][ReportFrom], "AlertType");
			if(AlertTime[Reports[reportid][ReportFrom]] != 0) AlertTime[Reports[reportid][ReportFrom]] = 0;
		}
		format(string, sizeof(string), "AdmCmd: %s da dong bao cao cua %s (RID: %d) vi can xu ly tren TeamSpeak", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		ABroadCast(COLOR_ORANGE, string, 2);
		format(string, sizeof(string), "AdmCmd: %s has cleared report from %s (RID: %d) due to it needing to be handled on TeamSpeak", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
		Log("logs/report.log", string);
		SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "%s da xem va xac dinh bao cao can xu ly tren TeamSpeak (Admin Assistance Channels)", GetPlayerNameEx(playerid));
        DeletePVar(Reports[reportid][ReportFrom], "HasReport");
		DeletePVar(Reports[reportid][ReportFrom], "_rAutoM");
		DeletePVar(Reports[reportid][ReportFrom], "_rRepID");
		Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
		Reports[reportid][BeingUsed] = 0;
		Reports[reportid][TimeToExpire] = 0;
		strmid(Reports[reportid][Report], "None", 0, 4, 4);
	}
	return 1;
}