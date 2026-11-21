CMD:togemailcheck(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return 1;
	SendClientMessageEx(playerid, -1, emailcheck ? ("Da tat kiem tra e-mail"):("Da bat kiem tra e-mail"));
	emailcheck = !emailcheck;
	return 1;
}

InvalidEmailCheck(playerid, email[], task)
{
	if(isnull(email))
		return ShowPlayerDialogEx(playerid, EMAIL_VALIDATION, DIALOG_STYLE_INPUT, "Dang ky e-mail", "Nhap e-mail hop le de lien ket tai khoan.", "Gui", "");
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "%s/email_check.php?t=%d&e=%s", SAMP_WEB, task, email);
	HTTP(playerid, HTTP_GET, szMiscArray, "", "OnInvalidEmailCheck");
	return 1;
}

forward OnInvalidEmailCheck(playerid, response_code, data[]);
public OnInvalidEmailCheck(playerid, response_code, data[])
{
	if(response_code == 200)
	{
		new result = strval(data);
		if(result == 0) // Invalid, Show dialog
			ShowPlayerDialogEx(playerid, EMAIL_VALIDATION, DIALOG_STYLE_INPUT, "Dang ky e-mail - {FF0000}Loi", "Nhap e-mail hop le de lien ket tai khoan.", "Gui", "");
		if(result == 1) // Valid from login check
			if(!GetPVarInt(playerid, "EmailConfirmed"))
			{
				SendClientMessageEx(playerid, COLOR_LIGHTRED, "E-mail chua duoc xac nhan. Hay xac nhan hoac vao cp.ng-gaming.net de doi e-mail.");
			}
		if(result == 2) // Valid from dialog
		{
			szMiscArray[0] = 0;
			GetPVarString(playerid, "pEmail", szMiscArray, 128);
			mysql_escape_string(szMiscArray, PlayerInfo[playerid][pEmail]);
			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `accounts` SET `Email` = '%s', `EmailConfirmed` = 0 WHERE `id` = %d", PlayerInfo[playerid][pEmail], PlayerInfo[playerid][pId]);
			mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
			format(szMiscArray, sizeof(szMiscArray), "Thu xac nhan se som duoc gui den '%s'.\n\
			Hay xac nhan trong 7 ngay, neu khong ban se phai nhap e-mail moi.\n\
			Hay xac nhan e-mail de nhan thong bao va thuc hien cac thay doi quan trong cho tai khoan.", PlayerInfo[playerid][pEmail]);
			ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Xac nhan e-mail", szMiscArray, "Dong y", "");
			format(szMiscArray, sizeof(szMiscArray), "%s/mail.php?id=%d", CP_WEB, PlayerInfo[playerid][pId]);
			HTTP(playerid, HTTP_HEAD, szMiscArray, "", "");
		}
	}
	return 1;
}

#include <YSI_Coding\y_hooks>
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(dialogid == EMAIL_VALIDATION)
	{
		if(!response || isnull(inputtext))
			ShowPlayerDialogEx(playerid, EMAIL_VALIDATION, DIALOG_STYLE_INPUT, "Dang ky e-mail - {FF0000}Loi", "Nhap e-mail hop le de lien ket tai khoan.", "Gui", "");
		SetPVarString(playerid, "pEmail", inputtext);
		InvalidEmailCheck(playerid, inputtext, 2);
	}
	return 0;
}