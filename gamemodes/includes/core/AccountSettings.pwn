#include <YSI_Coding\y_hooks>

#define ACCOUNT_SETTINGS	10020
#define ACCOUNT_TOGGLEMENU	10021

enum eAccountToggle
{
	toggleID,
	toggleName[32],
	toggleCommand[16]
}

static const AccountToggles[][eAccountToggle] =
{
	{CHAT_NEWBIE, "Newbie Chat", "newbie"},
	{CHAT_NEWS, "News", "news"},
	{CHAT_OOC, "Global OOC", "ooc"},
	{CHAT_WHISPERS, "Whispers", "whisper"},
	{CHAT_PRIVATE_RADIO, "Private Radio", "pr"},
	{CHAT_PHONE, "Phone", "phone"},
	{CHAT_FAMED, "Famed Chat", "famed"},
	{CHAT_VIP, "VIP Chat", "vip"},
	{CHAT_DEPARTMENT, "Department Radio", "dept"},
	{CHAT_INTERNATIONAL, "International Radio", "int"},
	{CHAT_GROUP_OOC, "OOC Group", "gooc"},
	{CHAT_GROUP_RADIO, "Group Radio", "radio"},
	{CHAT_BUG, "Bug Chat", "bug"},
	{CHAT_BUSINESS, "Business Radio", "biz"},
	{CHAT_POINTS, "Point Messages", "points"},
	{CHAT_REPFAM_HUD, "RepFam HUD", "rf"},
	{CHAT_STAFF, "Staff Chat", "staff"},
	{CHAT_ADVISOR, "Advisor Chat", "advisor"},
	{CHAT_WATCHDOG, "Watchdog Chat", "watchdog"}
};

stock bool:AccountToggle_CanAccess(playerid, id)
{
	new group = PlayerInfo[playerid][pMember];
	switch(id)
	{
		case CHAT_FAMED: return PlayerInfo[playerid][pFamed] >= 1 || PlayerInfo[playerid][pAdmin] >= 4;
		case CHAT_VIP: return PlayerInfo[playerid][pDonateRank] >= 1 || PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pVIPMod] > 0;
		case CHAT_DEPARTMENT: return PlayerInfo[playerid][pReceiver] > 0 || PlayerInfo[playerid][pAdmin] >= 2 || (0 <= group < MAX_GROUPS && PlayerInfo[playerid][pRank] >= arrGroupData[group][g_iDeptRadioAccess]);
		case CHAT_INTERNATIONAL: return 0 <= group < MAX_GROUPS && PlayerInfo[playerid][pRank] >= arrGroupData[group][g_iIntRadioAccess];
		case CHAT_GROUP_OOC: return 0 <= group < MAX_GROUPS;
		case CHAT_GROUP_RADIO: return 0 <= group < MAX_GROUPS || PlayerInfo[playerid][pAdmin] >= 2;
		case CHAT_BUG: return 0 <= group < MAX_GROUPS && PlayerInfo[playerid][pRank] >= arrGroupData[group][g_iBugAccess];
		case CHAT_BUSINESS: return IsValidBusinessID(PlayerInfo[playerid][pBusiness]) != 0;
		case CHAT_REPFAM_HUD: return IsACriminal(playerid) != 0;
		case CHAT_STAFF: return PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pHelper] >= 2 || PlayerInfo[playerid][pVIPMod] > 0 || PlayerInfo[playerid][pWatchdog] >= 1;
		case CHAT_ADVISOR: return PlayerInfo[playerid][pHelper] >= 1 || PlayerInfo[playerid][pAdmin] >= 2;
		case CHAT_WATCHDOG: return PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 1;
	}
	return true;
}

stock ToggleAccountSetting(playerid, id)
{
	if(!gPlayerLogged{playerid}) return SendClientMessageEx(playerid, COLOR_WHITE, "You must be logged in to use this.");
	new entry = -1;
	for(new i; i < sizeof(AccountToggles); ++i)
	{
		if(AccountToggles[i][toggleID] == id)
		{
			entry = i;
			break;
		}
	}
	if(entry == -1 || !AccountToggle_CanAccess(playerid, id)) return SendClientMessageEx(playerid, COLOR_GREY, "This setting is not available to you.");
	if(id == CHAT_WATCHDOG && PlayerInfo[playerid][pAdmin] < 2 && PlayerInfo[playerid][pWatchdog] < 3)
		return SendClientMessageEx(playerid, COLOR_GREY, "Watchdog chat must remain enabled for your rank.");

	new disabled = PlayerInfo[playerid][pToggledChats][id] == 0;
	if(id == CHAT_PHONE && !disabled && (PlayerInfo[playerid][pJailTime] > 0 || PlayerInfo[playerid][pBeingSentenced] > 0))
		return SendClientMessageEx(playerid, COLOR_GREY, "You cannot switch on your phone while in custody.");

	PlayerInfo[playerid][pToggledChats][id] = disabled;
	switch(id)
	{
		case CHAT_PHONE: PhoneOnline[playerid] = disabled;
		case CHAT_REPFAM_HUD:
		{
			if(disabled) TextDrawHideForPlayer(playerid, TD_RepFam);
			else if(GetPVarType(playerid, "RepFam_TL")) TextDrawShowForPlayer(playerid, TD_RepFam);
		}
	}
	SendClientMessageEx(playerid, COLOR_GRAD1, "%s is now %s.", AccountToggles[entry][toggleName], disabled ? "off" : "on");
	return 1;
}

CMD:settings(playerid, params[])
{
	return ShowAccountSettings(playerid);
}

ShowAccountSettings(playerid, menu = 0)
{
	if(!gPlayerLogged{playerid}) return SendClientMessageEx(playerid, COLOR_WHITE, "You must be logged in to use this.");
	szMiscArray[0] = EOS;
	switch(menu)
	{
		case 0:
		{
			new title[48];
			format(title, sizeof(title), "Account Settings - %s", GetPlayerNameEx(playerid));
			ShowPlayerDialogEx(playerid, ACCOUNT_SETTINGS, DIALOG_STYLE_LIST, title, "Toggle Menu\nChange Account Email\nAccount Password\nChange Shop Pin", "Select", "Cancel");
		}
		case 1:
		{
			new line[128], row;
			for(new i; i < sizeof(AccountToggles); ++i) ListItemTrackId[playerid][i] = -1;
			strcat(szMiscArray, "Item\tStatus\tCommand\n", sizeof(szMiscArray));
			for(new i; i < sizeof(AccountToggles); ++i)
			{
				new id = AccountToggles[i][toggleID];
				if(!AccountToggle_CanAccess(playerid, id)) continue;
				ListItemTrackId[playerid][row++] = id;
				if(id == CHAT_WATCHDOG && PlayerInfo[playerid][pAdmin] < 2 && PlayerInfo[playerid][pWatchdog] < 3)
					format(line, sizeof(line), "%s\t{00FF00}On (required)\t/tog %s\n", AccountToggles[i][toggleName], AccountToggles[i][toggleCommand]);
				else if(id == CHAT_PHONE && (PlayerInfo[playerid][pJailTime] > 0 || PlayerInfo[playerid][pBeingSentenced] > 0))
					format(line, sizeof(line), "%s\t{FF0000}Off (in custody)\t/tog %s\n", AccountToggles[i][toggleName], AccountToggles[i][toggleCommand]);
				else
					format(line, sizeof(line), "%s\t%s\t/tog %s\n", AccountToggles[i][toggleName], PlayerInfo[playerid][pToggledChats][id] == 0 ? "{00FF00}On" : "{FF0000}Off", AccountToggles[i][toggleCommand]);
				strcat(szMiscArray, line, sizeof(szMiscArray));
			}
			ShowPlayerDialogEx(playerid, ACCOUNT_TOGGLEMENU, DIALOG_STYLE_TABLIST_HEADERS, "Toggle Menu", szMiscArray, "Toggle", "Back");
		}
		case 3: { // account email 
			ShowPlayerDialogEx(playerid, EMAIL_VALIDATION, DIALOG_STYLE_INPUT, "E-mail Registration", "Please enter a valid e-mail address to associate with your account.", "Submit", "");
		}

		case 4: { // account password
			ShowPlayerDialogEx(playerid, DIALOG_CHANGEPASS, DIALOG_STYLE_INPUT, "Password Change", "Please enter your new password!\nStaff members will never ask for your password!", "Change", "Exit" );
		}

		case 5: { // shop pin
			
			if(GetPVarInt(playerid, "PinConfirmed")) {
				SetPVarInt(playerid, "ChangePin", 1);
				ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN, DIALOG_STYLE_INPUT, "Change Pin Number", "Enter a new pin number to change your current one.", "Change", "Cancel");
			}
			else PinLogin(playerid);
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case ACCOUNT_SETTINGS:
		{
			if(!response || !gPlayerLogged{playerid}) return 1;
			switch(listitem)
			{
				case 0: ShowAccountSettings(playerid, 1);
				case 1: ShowAccountSettings(playerid, 3);
				case 2: ShowAccountSettings(playerid, 4);
				case 3: ShowAccountSettings(playerid, 5);
			}
			return 1;
		}
		case ACCOUNT_TOGGLEMENU:
		{
			if(!gPlayerLogged{playerid}) return 1;
			if(!response) return ShowAccountSettings(playerid);
			if(0 <= listitem < sizeof(AccountToggles) && ListItemTrackId[playerid][listitem] != -1)
				ToggleAccountSetting(playerid, ListItemTrackId[playerid][listitem]);
			return ShowAccountSettings(playerid, 1);
		}
	}
	return 0;
}

CMD:tog(playerid, params[])
{
	if(!gPlayerLogged{playerid}) return SendClientMessageEx(playerid, COLOR_WHITE, "You must be logged in to use this.");
	if(isnull(params)) return ShowAccountSettings(playerid, 1);
	for(new i; i < sizeof(AccountToggles); ++i)
	{
		if(!strcmp(params, AccountToggles[i][toggleCommand], true)) return ToggleAccountSetting(playerid, AccountToggles[i][toggleID]);
	}
	return SendClientMessageEx(playerid, COLOR_GREY, "Unknown toggle. Use /tog to view the available settings.");
}
