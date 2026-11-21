/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Event Kernal System

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

forward ERequested();
public ERequested()
{
	EventKernel[EventAdvisor] = 0;
	return 1;
}

CMD:joinevent(playerid, params[]) {
	if( EventKernel[ EventStatus ] == 0 ) {
		SendClientMessageEx( playerid, COLOR_WHITE, "Hien khong co su kien dang chay." );
	}
	else if( GetPVarInt( playerid, "EventToken" ) == 1 ) {
		SendClientMessageEx( playerid, COLOR_WHITE, "Ban da o trong su kien." );
	}
	else if(GetPVarType(playerid, "IsInArena")) {
		SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o dau truong!");
	}
	else if( PlayerCuffed[ playerid ] >= 1 || PlayerInfo[ playerid ][ pJailTime ] > 0 || PlayerInfo[playerid][pHospital] > 0 || GetPVarInt(playerid, "Injured")) {
		SendClientMessageEx( playerid, COLOR_WHITE, "Ban chua the lam viec nay." );
	}
	else if(PlayerInfo[playerid][pAccountRestricted] != 0) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the lam viec nay khi tai khoan bi han che!");
	}
	else if(EventKernel[VipOnly] == 1 && PlayerInfo[playerid][pDonateRank] < 1) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Su kien nay chi danh cho VIP.");
	}
	else if(EventKernel[EventPlayers] >= EventKernel[EventLimit] && EventKernel[EventTime] == 0) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Su kien da du nguoi choi.");
	}
	else if( EventKernel[ EventStatus ] == 2 || (EventKernel[ EventStatus ] == 1 && PlayerInfo[playerid][pDonateRank] >= 3)) {
		if(EventKernel[EventType] == 3)
		{
            new string[128];
			if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
				DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
				RFLTeamN3D[playerid] = Text3D:-1;
			}
			format(string, sizeof(string), "%s da tham gia su kien dua!", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
			SendClientMessageEx( playerid, COLOR_WHITE, EventKernel[ EventInfo ] );
		    if(EventKernel[EventFootRace]) {
		    	SendClientMessageEx( playerid, COLOR_YELLOW, "Ban da tham gia dua di bo va duoc dich chuyen den checkpoint ngau nhien." );
			}
			else {
			    SendClientMessageEx( playerid, COLOR_YELLOW, "Ban da tham gia dua xe va duoc dich chuyen den checkpoint ngau nhien." );
			}
			SetPVarInt( playerid, "EventToken", 1 );
			TotalJoinsRace++;
			SetPlayerPos( playerid, EventKernel[ EventPositionX ], EventKernel[ EventPositionY ], EventKernel[ EventPositionZ ] );
			RCPIdCurrent[playerid] = 0;
		    new randcpscount = -1;
		    for(new i = 0; i < 20; i++)
		    {
		        if(EventRCPU[i] && EventRCPT[i] == 1) randcpscount = i;
		    }
		    ResetPlayerWeapons( playerid );
			pTazer{playerid} = 0;
			GetHealth(playerid, EventFloats[playerid][4]);
			GetArmour(playerid, EventFloats[playerid][5]);
			EventLastVW[playerid] = GetPlayerVirtualWorld(playerid);
			EventLastInt[playerid] = GetPlayerInterior(playerid);
			GetPlayerPos(playerid, EventFloats[playerid][1], EventFloats[playerid][2], EventFloats[playerid][3]);
			GetPlayerFacingAngle(playerid, EventFloats[playerid][0]);
		    new randrcp = randcpscount;
		    //SetPlayerPos(playerid, EventRCPX[randrcp], EventRCPY[randrcp], EventRCPZ[randrcp]);
			SetPlayerInterior( playerid, EventKernel[ EventInterior ] );
			SetPlayerVirtualWorld( playerid, EventKernel[ EventWorld ] );
			if(PlayerInfo[playerid][pRFLTeam] != -1) {
				new Float:X, Float:Y, Float:Z;
				GetPlayerPos( playerid, X, Y, Z );
				format(string, sizeof(string), "Doi: %s", RFLInfo[PlayerInfo[playerid][pRFLTeam]][RFLname]);
				RFLTeamN3D[playerid] = CreateDynamic3DTextLabel(string,0x008080FF,X,Y,Z,10.0,.attachedplayer = playerid, .worldid = GetPlayerVirtualWorld(playerid));
			}
		    if(EventRCPT[randrcp] != 1)
		    {
				DisablePlayerCheckpoint(playerid);
		    	SetPlayerCheckpoint(playerid, EventRCPX[randrcp], EventRCPY[randrcp], EventRCPZ[randrcp], EventRCPS[randrcp]);
			}
			else
			{
			    DisablePlayerCheckpoint(playerid);
		    	SetPlayerCheckpoint(playerid, EventRCPX[randrcp], EventRCPY[randrcp], EventRCPZ[randrcp], EventRCPS[randrcp]);
			}
		}
		else
		{
			if(IsPlayerInAnyVehicle(playerid)) {
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the tham gia khi o trong xe.");
			}

			SetPVarInt( playerid, "EventToken", 1 );
			ResetPlayerWeapons( playerid );
			pTazer{playerid} = 0;
			GetHealth(playerid, EventFloats[playerid][4]);
			GetArmour(playerid, EventFloats[playerid][5]);
			EventLastVW[playerid] = GetPlayerVirtualWorld(playerid);
			EventLastInt[playerid] = GetPlayerInterior(playerid);
			GetPlayerPos(playerid, EventFloats[playerid][1], EventFloats[playerid][2], EventFloats[playerid][3]);
			GetPlayerFacingAngle(playerid, EventFloats[playerid][0]);
			if(EventKernel[EventType] != 2)
			{
				SetPlayerPos( playerid, EventKernel[ EventPositionX ], EventKernel[ EventPositionY ], EventKernel[ EventPositionZ ] );
				if(EventKernel[EventCustomInterior] == 1) Player_StreamPrep(playerid, EventKernel[EventPositionX], EventKernel[EventPositionY], EventKernel[EventPositionZ], FREEZE_TIME);
			}
			SetPlayerInterior( playerid, EventKernel[ EventInterior ] );
			SetPlayerVirtualWorld( playerid, EventKernel[ EventWorld ] );
			SendClientMessageEx( playerid, COLOR_WHITE, EventKernel[ EventInfo ] );
			
			SetHealth( playerid, EventKernel[ EventHealth ] );
			if(EventKernel[EventArmor] > 0) {
				SetArmour( playerid, EventKernel[ EventArmor ]);
			}
			//if(PlayerInfo[playerid][pBEquipped]) PlayerInfo[playerid][pBEquipped] = 0;
			for(new x;x<MAX_PLAYERTOYS;x++) {
				if(IsPlayerAttachedObjectSlotUsed(playerid, x)) 
				{
					if(x == 9 && PlayerInfo[playerid][pBEquipped]) 
						break;
					RemovePlayerAttachedObject(playerid, x); 
				}
			}
			for(new i; i < 10; i++) {
				PlayerHoldingObject[playerid][i] = 0;
			}

			if(EventKernel[EventType] == 2)
			{
				SetPlayerSkin(playerid, EventKernel[EventTeamSkin][nextteam]);
				new color = EventKernel[EventTeamColor][nextteam];
				if (color==0) SetPlayerColor(playerid, 0x00000000);
				if (color==1) SetPlayerColor(playerid, 0xFFFFFF00);
				if (color==2) SetPlayerColor(playerid, 0x2641FE00);
				if (color==3) SetPlayerColor(playerid, 0xAA333300);
				if (color==16) SetPlayerColor(playerid, 0x33AA3300);
				if (color==5) SetPlayerColor(playerid, 0xC2A2DA00);
				if (color==6) SetPlayerColor(playerid, 0xFFFF0000);
				if (color==7) SetPlayerColor(playerid, 0x33CCFF00);
				//if (strcmp(clr, "navy", true)==0) color=94;
				//if (strcmp(clr, "beige", true)==0) color=102;
				if (color==51) SetPlayerColor(playerid, 0x2D6F0000);
				if (color==103) SetPlayerColor(playerid, 0x0B006F00);
				if (color==13) SetPlayerColor(playerid, 0x52525200);
				if (color==55) SetPlayerColor(playerid, 0xB46F0000);
				if (color==84) SetPlayerColor(playerid, 0x814F0000);
				if (color==74) SetPlayerColor(playerid, 0x750A0000);
				//if (strcmp(clr, "maroon", true)==0) color=115;
				if (color==126) SetPlayerColor(playerid, 0xFF51F100);
				if(nextteam == 0)
				{
					SetPlayerPos(playerid, EventKernel[EventTeamPosX1], EventKernel[EventTeamPosY1], EventKernel[EventTeamPosZ1]);
					if(EventKernel[EventCustomInterior] == 1) Player_StreamPrep(playerid, EventKernel[EventTeamPosX1], EventKernel[EventTeamPosY1], EventKernel[EventTeamPosZ1], FREEZE_TIME);
				}
				else
				{
					SetPlayerPos(playerid, EventKernel[EventTeamPosX2], EventKernel[EventTeamPosY2], EventKernel[EventTeamPosZ2]);
					if(EventKernel[EventCustomInterior] == 1) Player_StreamPrep(playerid, EventKernel[EventTeamPosX2], EventKernel[EventTeamPosY2], EventKernel[EventTeamPosZ2], FREEZE_TIME);
				}
				if(nextteam == 0) nextteam++;
				else if(nextteam == 1) nextteam--;
			}
			if(EventKernel[EventType] == 4)
			{
			    SetPlayerColor(playerid, 0xAA333300);
			}
		}
		EventKernel[EventPlayers] ++;
		if(EventKernel[EventPlayers] == EventKernel[EventLimit] && EventKernel[EventTime] == 0)
		{
			ABroadCastText(COLOR_YELLOW, "Su kien da du nguoi choi, ban co the bat dau.", 2);
		}
	}

	else if( EventKernel[ EventStatus ] == 3 )
	{
		SendClientMessageEx( playerid, COLOR_WHITE, "Su kien da khoa, ban khong the tham gia." );
	}
	else if( EventKernel[ EventStatus ] == 4 )
	{
		SendClientMessageEx( playerid, COLOR_WHITE, "Su kien da bat dau, ban khong the tham gia." );
	}

	return 1;
}

CMD:eventstaff(playerid, params[])
{
	new Float:health, Float:armor;
    if( PlayerInfo[ playerid ][ pAdmin ] >= 1 || PlayerInfo[playerid][pHelper] >= 2 || PlayerInfo[playerid][pSEC] >= 1) {
		if(GetPVarType(playerid, "pGodMode"))
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Hay tat bat tu truoc khi vao nhom dieu hanh su kien (/god)");
        if(EventKernel[EventJoinStaff] == 1) {
			if(GetPVarInt(playerid, "eventStaff") == 0) {
				for(new i; i < sizeof(EventKernel[EventStaff]); i++) if(EventKernel[EventStaff][i] == INVALID_PLAYER_ID) {
					SetPVarInt( playerid, "EventToken", 1 );
					EventLastVW[playerid] = GetPlayerVirtualWorld(playerid);
					EventLastInt[playerid] = GetPlayerInterior(playerid);
					GetPlayerPos(playerid, EventFloats[playerid][1], EventFloats[playerid][2], EventFloats[playerid][3]);
					GetPlayerFacingAngle(playerid, EventFloats[playerid][0]);
					SetPlayerPos( playerid, EventKernel[ EventPositionX ], EventKernel[ EventPositionY ], EventKernel[ EventPositionZ ] );
					SetPlayerInterior( playerid, EventKernel[ EventInterior ] );
					SetPlayerVirtualWorld( playerid, EventKernel[ EventWorld ] );
					PlayerInfo[playerid][pAGuns][GetLoadoutWeaponSlot(38)] = 38;
					GivePlayerValidWeapon(playerid, 38);
					EventKernel[EventStaff][i] = playerid;
					GetHealth(playerid,health);
					SetPVarFloat(playerid, "pPreGodHealth", health);
					GetArmour(playerid,armor);
					SetPVarFloat(playerid, "pPreGodArmor", armor);
					SetHealth(playerid, 0x7FB00000);
					SetArmour(playerid, 0x7FB00000);
					SetPVarInt(playerid, "eventStaff", 1);
					return SendClientMessageEx( playerid, COLOR_WHITE, "Ban da vao nhom dieu hanh su kien." );
				}
				SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the vao nhom dieu hanh su kien, toi da 5 nguoi.");
			}	
        }
    }
    return 1;
}

CMD:quitevent(playerid, params[])
{
	new Float:health, Float:armor;
	if( GetPVarInt( playerid, "eventStaff" ) == 1) {
		if( EventKernel[ EventStatus ] == 1 || EventKernel[ EventStatus ] == 2 ) {
       		if(EventKernel[EventType] == 3) {
					DisablePlayerCheckpoint(playerid);
            	    ResetPlayerWeapons( playerid );
        			DeletePVar(playerid, "EventToken");
        			SetPlayerWeapons(playerid);
       				SetPlayerToTeamColor(playerid);
        			SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
        			SetPlayerPos(playerid,EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3]);
        			SetPlayerVirtualWorld(playerid, EventLastVW[playerid]);
        			SetPlayerFacingAngle(playerid, EventFloats[playerid][0]);
        			SetPlayerInterior(playerid,EventLastInt[playerid]);
        			Player_StreamPrep(playerid, EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3], FREEZE_TIME);
                    RemovePlayerLoadoutWeapon(playerid, 38);
        			for(new i = 0; i < 6; i++) {
        	   			EventFloats[playerid][i] = 0.0;
    	   			}
       		}
       		EventLastVW[playerid] = 0;
       		EventLastInt[playerid] = 0;
       		SendClientMessageEx( playerid, COLOR_LIGHTBLUE, "* Ban da roi nhom dieu hanh su kien." );
       		return 1;
		}
      	ResetPlayerWeapons( playerid );
       	DeletePVar(playerid, "EventToken");
       	SetPlayerWeapons(playerid);
       	SetPlayerToTeamColor(playerid);
       	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
       	SetPlayerPos(playerid,EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3]);
      	SetPlayerVirtualWorld(playerid, EventLastVW[playerid]);
       	SetPlayerFacingAngle(playerid, EventFloats[playerid][0]);
       	SetPlayerInterior(playerid,EventLastInt[playerid]);
       	Player_StreamPrep(playerid, EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3], FREEZE_TIME);
       	if(EventKernel[EventType] == 4)
		{
			if(GetPVarType(playerid, "pEventZombie")) DeletePVar(playerid, "pEventZombie");
 			SetPlayerToTeamColor(playerid);
		}
       	for(new i = 0; i < 6; i++) {
        	EventFloats[playerid][i] = 0.0;
        }
        EventLastVW[playerid] = 0;
        EventLastInt[playerid] = 0;
        RemovePlayerLoadoutWeapon(playerid, 38);
		health = GetPVarFloat(playerid, "pPreGodHealth");
		SetHealth(playerid,health);
		armor = GetPVarFloat(playerid, "pPreGodArmor");
		SetArmour(playerid, armor);
		DeletePVar(playerid, "pPreGodHealth");
		DeletePVar(playerid, "pPreGodArmor");
		DeletePVar(playerid, "eventStaff");
        return SendClientMessageEx( playerid, COLOR_LIGHTBLUE, "* Ban da roi nhom dieu hanh su kien." );
	}	
    else if( GetPVarInt( playerid, "EventToken" ) == 1 ) {
        if( EventKernel[ EventStatus ] == 1 || EventKernel[ EventStatus ] == 2 ) {
       		if(EventKernel[EventType] == 3) {
					if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
						DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
						RFLTeamN3D[playerid] = Text3D:-1;
					}
					DisablePlayerCheckpoint(playerid);
            	    ResetPlayerWeapons( playerid );
        			DeletePVar(playerid, "EventToken");
        			SetPlayerWeapons(playerid);
       				SetPlayerToTeamColor(playerid);
        			SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
        			SetPlayerPos(playerid,EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3]);
        			SetPlayerVirtualWorld(playerid, EventLastVW[playerid]);
        			SetPlayerFacingAngle(playerid, EventFloats[playerid][0]);
        			SetPlayerInterior(playerid,EventLastInt[playerid]);
        			SetHealth(playerid, EventFloats[playerid][4]);
        			if(EventFloats[playerid][5] > 0) {
        				SetArmour(playerid, EventFloats[playerid][5]);
        			}
        			Player_StreamPrep(playerid, EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3], FREEZE_TIME);
                    RemovePlayerLoadoutWeapon(playerid, 38);
        			for(new i = 0; i < 6; i++) {
        	   			EventFloats[playerid][i] = 0.0;
    	   			}
       		}
       		EventLastVW[playerid] = 0;
       		EventLastInt[playerid] = 0;
       		SendClientMessageEx( playerid, COLOR_LIGHTBLUE, "* Ban da roi su kien." );
       		return 1;
		}
      	ResetPlayerWeapons( playerid );
       	DeletePVar(playerid, "EventToken");
       	SetPlayerWeapons(playerid);
       	SetPlayerToTeamColor(playerid);
       	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
       	SetPlayerPos(playerid,EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3]);
      	SetPlayerVirtualWorld(playerid, EventLastVW[playerid]);
       	SetPlayerFacingAngle(playerid, EventFloats[playerid][0]);
       	SetPlayerInterior(playerid,EventLastInt[playerid]);
       	SetHealth(playerid, EventFloats[playerid][4]);
       	if(EventFloats[playerid][5] > 0) {
       		SetArmour(playerid, EventFloats[playerid][5]);
       	}
       	Player_StreamPrep(playerid, EventFloats[playerid][1],EventFloats[playerid][2],EventFloats[playerid][3], FREEZE_TIME);
       	if(EventKernel[EventType] == 4)
		{
			if(GetPVarType(playerid, "pEventZombie")) DeletePVar(playerid, "pEventZombie");
 			SetPlayerToTeamColor(playerid);
		}
       	for(new i = 0; i < 6; i++) {
        	EventFloats[playerid][i] = 0.0;
        }
        EventLastVW[playerid] = 0;
        EventLastInt[playerid] = 0;
        RemovePlayerLoadoutWeapon(playerid, 38);
		health = GetPVarFloat(playerid, "pPreGodHealth");
		if(health > 0) {
			SetHealth(playerid,health);
		}
		armor = GetPVarFloat(playerid, "pPreGodArmor");
		if(armor > 0) {
			SetArmour(playerid, armor);
		}	
		DeletePVar(playerid, "pPreGodHealth");
		DeletePVar(playerid, "pPreGodArmor");
        SendClientMessageEx( playerid, COLOR_LIGHTBLUE, "* Ban da roi su kien." );
    }
    return 1;
}

CMD:eventreset(playerid, params[])
{
    if( PlayerInfo[ playerid ][ pAdmin ] >= 4 || PlayerInfo[playerid][pShopTech] >= 3) {
        new string[128];
        if( EventKernel[EventAdvisor] >= 1 ) {
            EventKernel[EventAdvisor] = 0;
            KillTimer( EventTimerHandle );
            format( string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s da dat lai hen gio su kien.", GetPlayerNameEx( playerid ) );
            ABroadCast( COLOR_YELLOW, string, 4 );
        }
        else {
            SendClientMessageEx( playerid, COLOR_GREY, "Thoi gian cho da het truoc khi ban dung lenh. Ban co the tao su kien." );
        }
    }
    return 1;
}

CMD:requestevent(playerid, params[])
{
    if( PlayerInfo[ playerid ][ pAdmin ] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4 || PlayerInfo[playerid][pSEC] >= 2) {
        new string[128];
        if( EventKernel[ EventStatus ] == 0 ) {
            if(EventKernel[EventRequest] != INVALID_PLAYER_ID || EventKernel[EventCreator] != INVALID_PLAYER_ID) {
                SendClientMessageEx(playerid, COLOR_GRAD2, "Da co nguoi de nghi/tao su kien.");
                return 1;
            }
            if(EventKernel[EventAdvisor] == 1) {
                SendClientMessageEx(playerid, COLOR_GRAD2, "Admin/advisor/coordinator khac da de nghi/tao su kien trong ba gio qua, hay thu lai sau!");
                return 1;
            }
            if(PlayerInfo[ playerid ][ pAdmin ] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4 || PlayerInfo[playerid][pSEC] >= 2) {
                EventKernel[ EventRequest ] = playerid;
                SendClientMessageEx( playerid, COLOR_GRAD2, "Ban da de nghi tao su kien, hay cho Senior Admin duyet." );
                format( string, sizeof( string ), "{AA3333}AdmWarning{FFFF00}: %s muon tao su kien, ban dong y? /acceptevent hoac /denyevent.", GetPlayerNameEx(playerid) );
                ABroadCast( COLOR_YELLOW, string, 4 );
                EventKernel[EventAdvisor] = 1;
                EventTimerHandle = SetTimer("ERequested", 9600000, false);
            }
        }
        else {
            SendClientMessageEx( playerid, COLOR_WHITE, "Da co su kien dang chay (dung /endevent)." );
        }
    }
    return 1;
}

CMD:vipparty(playerid, params[])
{
    if(PlayerInfo[playerid][pVIPMod])
	{
        new string[128+MAX_PLAYER_NAME];
        if( EventKernel[ EventStatus ] == 0 )
		{
            if(EventKernel[EventRequest] != INVALID_PLAYER_ID || EventKernel[EventCreator] != INVALID_PLAYER_ID)
			{
                SendClientMessageEx(playerid, COLOR_GRAD2, "Da co nguoi de nghi/tao su kien.");
                return 1;
            }
            if(EventKernel[EventAdvisor] == 1)
			{
                SendClientMessageEx(playerid, COLOR_GRAD2, "Admin/advisor khac da de nghi/tao su kien trong ba gio qua, hay thu lai sau!");
                return 1;
            }
            if(PlayerInfo[ playerid ][ pAdmin ] >= 4 || PlayerInfo[playerid][pVIPMod]) {
                EventKernel[ EventRequest ] = playerid;
                SendClientMessageEx( playerid, COLOR_GRAD2, "Ban da de nghi tao su kien, hay cho Senior Admin duyet." );
                format( string, sizeof( string ), "{AA3333}AdmWarning{FFFF00}: VIP Mod %s muon tao su kien VIP - /acceptevent hoac /denyevent", GetPlayerNameEx(playerid) );
                ABroadCast( COLOR_YELLOW, string, 4 );
                EventKernel[EventAdvisor] = 1;
                EventKernel[VipOnly] = 1;
                EventTimerHandle = SetTimer("ERequested", 9600000, false);
            }
        }
        else
		{
            SendClientMessageEx( playerid, COLOR_WHITE, "Da co su kien dang chay (dung /endevent)." );
        }
    }
    return 1;
}

CMD:denyevent(playerid, params[])
{
    if( PlayerInfo[ playerid ][ pAdmin ] >= 4 ) {
        new string[128];
        SendClientMessageEx( EventKernel[EventRequest], COLOR_GRAD2, "Yeu cau cua ban bi tu choi." );
        EventKernel[EventRequest] = INVALID_PLAYER_ID;
        EventKernel[EventCreator] = INVALID_PLAYER_ID;
        format( string, sizeof( string ), "{AA3333}AdmWarning{FFFF00}: %s da tu choi yeu cau tao su kien.", GetPlayerNameEx(playerid) );
        ABroadCast( COLOR_YELLOW, string, 4 );
        for(new i; i < sizeof(EventKernel[EventStaff]); i++) {
            if(EventKernel[EventStaff][i] != INVALID_PLAYER_ID) {
                SetPlayerWeapons(EventKernel[EventStaff][i]);
                SetPlayerPos(EventKernel[EventStaff][i],EventFloats[EventKernel[EventStaff][i]][1],EventFloats[EventKernel[EventStaff][i]][2],EventFloats[EventKernel[EventStaff][i]][3]);
                SetPlayerVirtualWorld(EventKernel[EventStaff][i], EventLastVW[EventKernel[EventStaff][i]]);
                SetPlayerFacingAngle(EventKernel[EventStaff][i], EventFloats[EventKernel[EventStaff][i]][0]);
                SetPlayerInterior(EventKernel[EventStaff][i],EventLastInt[EventKernel[EventStaff][i]]);
                SetHealth(EventKernel[EventStaff][i], EventFloats[EventKernel[EventStaff][i]][4]);
                if(EventFloats[EventKernel[EventStaff][i]][5] > 0) {
                	SetArmour(EventKernel[EventStaff][i], EventFloats[EventKernel[EventStaff][i]][5]);
                }
                for(new d = 0; d < 6; d++) {
                    EventFloats[EventKernel[EventStaff][i]][d] = 0.0;
                }
                EventLastVW[EventKernel[EventStaff][i]] = 0;
                EventLastInt[EventKernel[EventStaff][i]] = 0;
                EventKernel[EventStaff][i] = INVALID_PLAYER_ID;
                ResetPlayerWeapons( i );
            }
        }

        EventKernel[ EventStatus ] = 0;
        EventKernel[ EventType ] = 0;
        EventKernel[ EventLimit ] = 0;
        EventKernel[ EventPlayers ] = 0;
        EventKernel[ EventWeapons ][0] = 0;
        EventKernel[ EventWeapons ][1] = 0;
        EventKernel[ EventWeapons ][2] = 0;
        EventKernel[ EventWeapons ][3] = 0;
        EventKernel[ EventWeapons ][4] = 0;
        EventKernel[EventCreator] = INVALID_PLAYER_ID;
        EventKernel[VipOnly] = 0;
        EventKernel[EventJoinStaff] = 0;
		EventKernel[EventCustomInterior] = 0;
    }

    return 1;
}

CMD:acceptevent(playerid, params[])
{
    if( PlayerInfo[ playerid ][ pAdmin ] >= 4 ) {
        if( EventKernel[ EventStatus ] == 0 ) {
            if(EventKernel[EventRequest] != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(EventKernel[EventRequest])) {
                    if(EventKernel[EventCreator] != INVALID_PLAYER_ID) {
                        SendClientMessageEx(playerid, COLOR_GRAD2, "Da co nguoi tao su kien.");
                        return 1;
                    }
                    new string[128];
                    EventKernel[EventCreator] = EventKernel[EventRequest];
                    EventKernel[EventRequest] = INVALID_PLAYER_ID;
                    SetPVarInt( EventKernel[EventCreator], "EventToken", 1 );
                    SendClientMessageEx( EventKernel[EventCreator], COLOR_GRAD2, "Yeu cau su kien da duoc duyet, dung /seteventpos de dat vi tri, sau do moi nguoi co the /eventstaff." );
                    if(PlayerInfo[EventKernel[EventCreator]][pHelper] >= 2) {
                        SendClientMessageEx( EventKernel[EventCreator], COLOR_GRAD2, "Ban tam thoi duoc dung (/o)oc va /goto." );
                    }
                    format( string, sizeof( string ), "{AA3333}AdmWarning{FFFF00}: %s da duyet yeu cau tao su kien cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(EventKernel[EventCreator]) );
                    ABroadCast( COLOR_YELLOW, string, 4 );
                    return 1;
                }
            }
        }
    }
    return 1;
}

CMD:approveevent(playerid, params[])
{
    if( PlayerInfo[ playerid ][ pAdmin ] >= 4 ) {
        if( EventKernel[ EventStartRequest ] == 1 ) {
            new string[128];
            EventKernel[ EventStatus ] = 1;
            EventKernel[EventStartRequest] = 0;
            SendClientMessageEx( EventKernel[EventCreator], COLOR_GRAD2, "Yeu cau bat dau su kien da duoc duyet, dung /announceevent de thong bao toan may chu." );
            format( string, sizeof( string ), "{AA3333}AdmWarning{FFFF00}: %s da duyet yeu cau bat dau su kien cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(EventKernel[EventCreator]) );
            ABroadCast( COLOR_YELLOW, string, 4 );
            foreach(new i: Player)
			{
				if(PlayerInfo[i][pDonateRank] >= 3) {
					SendClientMessageEx(i, COLOR_YELLOW, "* Tinh nang Gold+ VIP: Su kien da mo! /joinevent de vao som");
				}
			}	
            return 1;
        }
    }
    return 1;
}

CMD:eventhelp(playerid, params[])
{
	if (EventKernel[EventCreator] == playerid || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
	    SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
		SendClientMessageEx(playerid, COLOR_GRAD4,"*** TRO GIUP SU KIEN *** Nhap lenh de xem chi tiet");
		SendClientMessageEx(playerid, COLOR_WHITE,"*** TRO GIUP SU KIEN *** /event /seteventpos /seteventinfo /startevent /lockevent /endevent /announceevent /beginevent /quitevent");
		SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	}
	return 1;
}

CMD:seteventpos(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4 || PlayerInfo[playerid][pSEC] >= 2)
	{
		if(EventKernel[EventCreator] == playerid || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
			new string[128];

			GetPlayerPos(playerid, EventKernel[EventPositionX], EventKernel[EventPositionY], EventKernel[EventPositionZ]);
			EventKernel[EventInterior] = GetPlayerInterior(playerid);
			EventKernel[EventWorld] = GetPlayerVirtualWorld(playerid);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat vi tri su kien, dung /seteventinfo de doi thuoc tinh su kien.");
			EventKernel[EventJoinStaff] = 1;
			format(string, sizeof( string ), "{AA3333}AdmWarning{FFFF00}: %s da tao su kien, dung /eventstaff de vao nhom dieu hanh.", GetPlayerNameEx(playerid) );
			ABroadCast(COLOR_YELLOW, string, 1);
			CBroadCast(COLOR_YELLOW, string, 2);
			foreach(new i: Player) if(PlayerInfo[i][pSEC] >= 1) SendClientMessageEx(i, COLOR_YELLOW, string);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong tao su kien hoac chua du cap Admin.");
		}
	}
	return 1;
}

CMD:seteventtype(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4 || PlayerInfo[playerid][pSEC] >= 2)
	{
		if(EventKernel[EventCreator] == playerid || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
			if(isnull(params))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /seteventtype [type]");
				SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: DM, TDM, Infection");
				return 1;
			}

			if(strcmp(params,"dm",true) == 0)
			{
				EventKernel[ EventType ] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai su kien thanh DM.");
			}
			else if(strcmp(params,"tdm",true) == 0)
			{
				EventKernel[ EventType ] = 2;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai su kien thanh TDM.");
			}
			else if(strcmp(params,"race",true) == 0)
			{
				EventKernel[ EventType ] = 3;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai su kien thanh Race.");
			}
			else if(strcmp(params,"infection",true) == 0)
			{
				EventKernel[ EventType ] = 4;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai su kien thanh infection.");
			}
			else if(strcmp(params,"none",true) == 0)
			{
				EventKernel[ EventType ] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai su kien thanh None.");
			}
		}
	}
	return 1;
}

CMD:editevent(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4 || PlayerInfo[playerid][pSEC] >= 2)
	{
		if(EventKernel[EventCreator] == playerid || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
			new choice[32], opstring[64];
			if(EventKernel[EventType] == 1)
			{
			    if(sscanf(params, "s[32]S[64]", choice, opstring))
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent [name]");
					SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: Jointext, Limit, Health, Armor, Gun1, Gun2, Gun3, Gun4, Gun5");
					return 1;
				}
			}
			else if(EventKernel[EventType] == 2)
			{
			    if(sscanf(params, "s[32]S[64]", choice, opstring))
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent [name]");
					SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: Jointext, Limit, CustomInterior, Team1Skin, Team2Skin, Team1Color, Team2Color");
					SendClientMessageEx(playerid, COLOR_GREY, "Team1Spawn, Team2Spawn, Health, Armor, Gun1, Gun2, Gun3, Gun4, Gun5");
					return 1;
				}
			}
			else if(EventKernel[EventType] == 3)
			{
			    if(sscanf(params, "s[32]S("")[64]", choice, opstring))
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent [name]");
					SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: Jointext, Limit, Health, Hours, CheckPoints, RaceType(Chua hoan thien), OnFoot(0/1)");
					SendClientMessageEx(playerid, COLOR_GREY, "Luu y Relay For Life: Dat hours tu 1-5 va khong doi limit!");
					SendClientMessageEx(playerid, COLOR_GREY, "Luu y Relay For Life: Bat OnFoot!");
					return 1;
				}
			}
			else if(EventKernel[EventType] == 4)
			{
			    if(sscanf(params, "s[32]S[64]", choice, opstring))
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent [name]");
					SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: Jointext, Limit, Health, Armor, Gun1, Gun2, Gun3, Gun4, Gun5");
					return 1;
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban can dat loai su kien truoc!");
				return 1;
			}

			if(strcmp(choice, "jointext",true) == 0)
			{
				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent jointext [text]");
					return 1;
				}
				strmid(EventKernel[EventInfo], opstring, 0, strlen(opstring), 64);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi noi dung moi tham gia su kien.");
			}
			else if(strcmp(choice, "health", true) == 0)
			{
				if(EventKernel[EventType] != 1 && EventKernel[EventType] != 2 && EventKernel[EventType] != 3 && EventKernel[EventType] != 4)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent health [health]");
					return 1;
				}
				new Float: health;
				health = floatstr(opstring);
				EventKernel[EventHealth] = health;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau su kien.");
			}
			else if(strcmp(choice, "armor", true) == 0)
			{
				if(EventKernel[EventType] != 1 && EventKernel[EventType] != 2 && EventKernel[EventType] != 4)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent armor [armor]");
					return 1;
				}
				new Float: armor;
				armor = floatstr(opstring);
				if(armor == 100) armor = 99;
				EventKernel[EventArmor] = armor;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi giap su kien.");
			}
			else if(strcmp(choice, "team1skin", true) == 0)
			{
				if(EventKernel[EventType] != 2)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent team1skin [skinid]");
					return 1;
				}

				new skin;
				skin = strval(opstring);
				EventKernel[EventTeamSkin][0] = skin;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi skin doi 1 cua su kien.");
			}
			else if(strcmp(choice, "team2skin", true) == 0)
			{
				if(EventKernel[EventType] != 2)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent team2skin [skinid]");
					return 1;
				}

				new skin;
				skin = strval(opstring);
				EventKernel[EventTeamSkin][1] = skin;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi skin doi 2 cua su kien.");
			}
			else if(strcmp(choice, "team1color", true) == 0)
			{
				if(EventKernel[EventType] != 2)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!strlen(opstring))
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent team1color [color]");
					SendClientMessageEx(playerid, COLOR_GREY, "black | white | blue | red | green | purple | yellow | lightblue |");
					SendClientMessageEx(playerid, COLOR_GREY, "darkgreen | darkblue | darkgrey | brown | darkbrown | darkred | pink ");
					return 1;
				}
				EventKernel[EventTeamColor][0] = GetColorCode(opstring);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau sac doi 1 cua su kien.");
			}
			else if(strcmp(choice, "team2color", true) == 0)
			{
				if(EventKernel[EventType] != 2)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!strlen(opstring))
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent team2color [color]");
					SendClientMessageEx(playerid, COLOR_GREY, "black | white | blue | red | green | purple | yellow | lightblue |");
					SendClientMessageEx(playerid, COLOR_GREY, "darkgreen | darkblue | darkgrey | brown | darkbrown | darkred | pink ");
					return 1;
				}
				EventKernel[EventTeamColor][1] = GetColorCode(opstring);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau sac doi 2 cua su kien.");
			}
			else if(strcmp(choice, "team1spawn", true) == 0)
			{
				if(EventKernel[EventType] != 2)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}
				GetPlayerPos(playerid, EventKernel[ EventTeamPosX1 ], EventKernel[ EventTeamPosY1 ], EventKernel[ EventTeamPosZ1 ] );
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi diem xuat hien doi 1.");
			}
			else if(strcmp(choice, "team2spawn", true) == 0)
			{
				if(EventKernel[EventType] != 2)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Tinh nang nay khong dung duoc voi loai su kien nay.");
					return 1;
				}
				GetPlayerPos(playerid, EventKernel[ EventTeamPosX2 ], EventKernel[ EventTeamPosY2 ], EventKernel[ EventTeamPosZ2 ]);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi diem xuat hien doi 2.");
			}
			else if(strcmp(choice, "limit", true) == 0)
			{
			    if(EventKernel[EventTime] != 0)
			        return SendClientMessageEx(playerid, COLOR_GRAD2, "Tinh nang nay khong dung duoc voi su kien nay, moi nguoi deu duoc vao. Dat hours la 0 de bat gioi han.");
				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent limit [limit 0-60]");
					return 1;
				}

				new limit;
				limit = strval(opstring);
				if(limit < 0 || limit > 120) return SendClientMessageEx(playerid, COLOR_RED, "Gioi han su kien khong duoc tren 120 hoac duoi 0");
				EventKernel[EventLimit] = limit;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi gioi han nguoi choi trong su kien.");
			}
			else if(strcmp(choice, "hours", true) == 0)
			{
			    if(EventKernel[EventType] != 3)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Tinh nang nay khong dung duoc voi loai su kien nay.");
					return 1;
				}
				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent hours [hours 0-5]");
					return 1;
				}

				new hours, seconds;
				hours = strval(opstring);
				if(hours < 0 || hours > 5) return SendClientMessageEx(playerid, COLOR_RED, "So gio su kien khong duoc tren 5 hoac duoi 0");
				seconds = hours*3600;
				EventKernel[EventTime] = seconds;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi so gio su kien hoat dong, hen gio se chay khi su kien chinh thuc bat dau.");
                SendClientMessageEx(playerid, COLOR_GREY, "LUU Y: Neu dat so gio la 0, su kien ket thuc khi tay dua cuoi cung den checkpoint cuoi.");
				if(hours != 0)
					SendClientMessageEx(playerid, COLOR_YELLOW, "Gioi han nguoi choi(/editevent limit) da tat vi ban dat so gio lon hon 0.");
			}
   			else if(strcmp(choice, "checkpoints", true) == 0)
			{
				if(EventKernel[EventType] != 3)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Tinh nang nay khong dung duoc voi loai su kien nay.");
					return 1;
				}
				ConfigEventCPs[playerid][0] = 1;
				ConfigEventCPs[playerid][1] = 0;
				ConfigEventCPs[playerid][2] = 0;
				ConfigEventCPId[playerid] = 0;
				new string[279];
				format(string,sizeof(string),"Chao mung den phan cau hinh checkpoint dua!\nHuong dan nay giup ban thiet lap cac checkpoint cho duong dua.\nCan tao checkpoint dung thu tu, tu vach xuat phat den vach dich.");
				ShowPlayerDialogEx(playerid,RCPINTRO,DIALOG_STYLE_MSGBOX,"Huong dan checkpoint dua",string,"Tiep","Bo qua");
			}
			else if(strcmp(choice, "onfoot", true) == 0)
			{
				if(EventKernel[EventFootRace])
				{
				    EventKernel[EventFootRace] = 0;
					SendClientMessageEx(playerid, COLOR_GRAD2, "Da tat che do di bo, nguoi choi duoc dung xe(Chua hoan thien, chua on dinh, khong nen dung)");
				}
				else {
				    EventKernel[EventFootRace] = 1;
					SendClientMessageEx(playerid, COLOR_GRAD2, "Da bat che do di bo, nguoi choi khong duoc dung xe.");
				}
			}
			else if(strcmp(choice, "gun1", true) == 0)
			{
				if(EventKernel[EventType] != 1 && EventKernel[EventType] != 2 && EventKernel[EventType] != 4)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent gun1 [weaponid]");
					return 1;
				}

				new weapon;
				weapon = strval(opstring);
				if(weapon == 16 || weapon == 18 || weapon == 35 || weapon == 37 || weapon == 38 || weapon == 39) return SendClientMessageEx(playerid, COLOR_WHITE, "Vu khi nay khong dung duoc cho su kien!");
				EventKernel[EventWeapons][0] = weapon;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vu khi 1 cua su kien.");
			}
			else if(strcmp(choice, "gun2", true) == 0)
			{
				if(EventKernel[EventType] != 1 && EventKernel[EventType] != 2 && EventKernel[EventType] != 4)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent gun1 [weaponid]");
					return 1;
				}

				new weapon;
				weapon = strval(opstring);
				if(weapon == 16 || weapon == 18 || weapon == 35 || weapon == 37 || weapon == 38 || weapon == 39) return SendClientMessageEx(playerid, COLOR_WHITE, "Vu khi nay khong dung duoc cho su kien!");
				EventKernel[EventWeapons][1] = weapon;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vu khi 2 cua su kien.");
			}
			else if(strcmp(choice, "gun3", true) == 0)
			{
				if(EventKernel[EventType] != 1 && EventKernel[EventType] != 2 && EventKernel[EventType] != 4)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent gun1 [weaponid]");
					return 1;
				}

				new weapon;
				weapon = strval(opstring);
				if(weapon == 16 || weapon == 18 || weapon == 35 || weapon == 37 || weapon == 38 || weapon == 39) return SendClientMessageEx(playerid, COLOR_WHITE, "Vu khi nay khong dung duoc cho su kien!");
				EventKernel[EventWeapons][2] = weapon;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vu khi 3 cua su kien.");
			}
			else if(strcmp(choice, "gun4", true) == 0)
			{
				if(EventKernel[EventType] != 1 && EventKernel[EventType] != 2 && EventKernel[EventType] != 4)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent gun1 [weaponid]");
					return 1;
				}

				new weapon;
				weapon = strval(opstring);
				if(weapon == 35 || weapon == 37 || weapon == 38) return SendClientMessageEx(playerid, COLOR_WHITE, "Vu khi nay khong dung duoc cho su kien!");
				EventKernel[EventWeapons][3] = weapon;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vu khi 4 cua su kien.");
			}
			else if(strcmp(choice, "gun5", true) == 0)
			{
				if(EventKernel[EventType] != 1 && EventKernel[EventType] != 2 && EventKernel[EventType] != 4)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ten nay khong dung duoc cho loai su kien nay.");
					return 1;
				}

				if(!opstring[0])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent gun1 [weaponid]");
					return 1;
				}

				new weapon;
				weapon = strval(opstring);
				if(weapon == 35 || weapon == 37 || weapon == 38) return SendClientMessageEx(playerid, COLOR_WHITE, "Vu khi nay khong dung duoc cho su kien!");
				EventKernel[EventWeapons][4] = weapon;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vu khi 5 cua su kien.");
			}
			else if(strcmp(choice, "custominterior", true) == 0)
			{
				if(!opstring[0]) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editevent custominterior [0/1]");
				
				EventKernel[EventCustomInterior] = strval(opstring);
				
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat gia tri Custom Interior la %d.", strval(opstring));
			}
		}
	}
	return 1;
}

CMD:seteventviponly(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4)
	{
		if(EventKernel[EventCreator] == playerid || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
			if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /seteventviponly [0/1]");

			if(PlayerInfo[playerid][pVIPMod] && PlayerInfo[playerid][pAdmin] == 0)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Loi: Ban khong duoc doi gia tri nay!");
				return 1;
			}

			if(strcmp(params,"0",true) == 0)
			{
				EventKernel[ VipOnly ] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bo han che chi VIP cho su kien.");
			}
			else if(strcmp(params,"1",true) == 0)
			{
				EventKernel[ VipOnly ] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat su kien chi danh cho VIP.");
			}

		}
	}
	return 1;
}

CMD:seteventinfo(playerid, params[])
{
	if( PlayerInfo[ playerid ][ pAdmin ] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4 || PlayerInfo[playerid][pSEC] >= 2)
	{
		if( EventKernel[EventCreator] == playerid || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /seteventtype /editevent /seteventviponly (khi san sang, dung /startevent)");
			return 1;
		}
	}
	return 1;
}

CMD:endevent(playerid, params[])
{
	new Float: health, Float:armor;
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || EventKernel[EventCreator] == playerid)
	{
		if(EventKernel[EventStatus] != 0)
		{
			foreach(new i: Player)
			{
				if( GetPVarInt( i, "eventStaff" ) == 1)
				{
					ResetPlayerWeapons( i );
					DeletePVar(i, "EventToken");
					for(new w = 0; w < 12; w++)
						if(PlayerInfo[i][pAGuns][w]) PlayerInfo[i][pGuns][w] = 0, PlayerInfo[i][pAGuns][w] = 0;
					SetPlayerWeapons(i);
					SetPlayerToTeamColor(i);
					SetPlayerSkin(i, PlayerInfo[i][pModel]);
					SetPlayerPos(i,EventFloats[i][1],EventFloats[i][2],EventFloats[i][3]);
					SetPlayerVirtualWorld(i, EventLastVW[i]);
					SetPlayerFacingAngle(i, EventFloats[i][0]);
					SetPlayerInterior(i,EventLastInt[i]);
					Player_StreamPrep(i, EventFloats[i][1],EventFloats[i][2],EventFloats[i][3], FREEZE_TIME);
					if(EventKernel[EventType] == 4)
					{
						if(GetPVarType(i, "pEventZombie")) DeletePVar(i, "pEventZombie");
						SetPlayerToTeamColor(i);
					}
					
					for(new d = 0; d < 6; d++)
					{
						EventFloats[i][d] = 0.0;
					}
					EventLastVW[i] = 0;
					EventLastInt[i] = 0;
					RemovePlayerLoadoutWeapon(i, 38);
					health = GetPVarFloat(i, "pPreGodHealth");
					SetHealth(i,health);
					armor = GetPVarFloat(i, "pPreGodArmor");
					SetArmour(i, armor);
					DeletePVar(i, "pPreGodHealth");
					DeletePVar(i, "pPreGodArmor");
					SetPVarInt(i, "eventStaff", 0);
					SendClientMessageEx( i, COLOR_YELLOW, "Ban da roi su kien vi Admin da ket thuc su kien." );
				}	
				else if( GetPVarInt( i, "EventToken" ) == 1 )
				{
					if(EventKernel[EventType] == 3)  {
						if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
							DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
						}
						DisablePlayerCheckpoint(i);
					} 
					else if(EventKernel[EventType] == 4) {
						if(GetPVarType(i, "pEventZombie")) DeletePVar(i, "pEventZombie");
					}
					ResetPlayerWeapons( i );
					for(new w = 0; w < 12; w++)
						if(PlayerInfo[i][pAGuns][w]) PlayerInfo[i][pGuns][w] = 0, PlayerInfo[i][pAGuns][w] = 0;
					SetPlayerWeapons(i);
					SetPlayerToTeamColor(i);
					SetPlayerSkin(i, PlayerInfo[i][pModel]);
					SetPlayerPos(i,EventFloats[i][1],EventFloats[i][2],EventFloats[i][3]);
					Player_StreamPrep(i, EventFloats[i][1],EventFloats[i][2],EventFloats[i][3], FREEZE_TIME);
					SetPlayerVirtualWorld(i, EventLastVW[i]);
					SetPlayerFacingAngle(i, EventFloats[i][0]);
					SetPlayerInterior(i,EventLastInt[i]);
					SetHealth(i, EventFloats[i][4]);
					if(EventFloats[i][5] > 0) {
						SetArmour(i, EventFloats[i][5]);
					}
					for(new d = 0; d < 6; d++)
					{
						EventFloats[i][d] = 0.0;
					}
					EventLastVW[i] = 0;
					EventLastInt[i] = 0;
					DeletePVar(i, "EventToken");
					SendClientMessageEx( i, COLOR_YELLOW, "Ban da roi su kien vi Admin da ket thuc su kien." );
				}
			}	
			EventKernel[ EventPositionX ] = 0;
			EventKernel[ EventPositionY ] = 0;
			EventKernel[ EventPositionZ ] = 0;
			EventKernel[ EventTeamPosX1 ] = 0;
			EventKernel[ EventTeamPosY1 ] = 0;
			EventKernel[ EventTeamPosZ1 ] = 0;
			EventKernel[ EventTeamPosX2 ] = 0;
			EventKernel[ EventTeamPosY2 ] = 0;
			EventKernel[ EventTeamPosZ2 ] = 0;
			EventKernel[ EventStatus ] = 0;
			EventKernel[ EventType ] = 0;
			EventKernel[ EventHealth ] = 0;
			EventKernel[ EventLimit ] = 0;
			EventKernel[ EventPlayers ] = 0;
			EventKernel[ EventTime ] = 0;
			EventKernel[ EventWeapons ][0] = 0;
			EventKernel[ EventWeapons ][1] = 0;
			EventKernel[ EventWeapons ][2] = 0;
			EventKernel[ EventWeapons ][3] = 0;
			EventKernel[ EventWeapons ][4] = 0;
			for(new i = 0; i < 20; i++)
			{
				EventRCPU[i] = 0;
				EventRCPX[i] = 0.0;
				EventRCPY[i] = 0.0;
				EventRCPZ[i] = 0.0;
				EventRCPS[i] = 0.0;
				EventRCPT[i] = 0;
			}
			EventKernel[EventCreator] = INVALID_PLAYER_ID;
			EventKernel[VipOnly] = 0;
			EventKernel[EventJoinStaff] = 0;
			for(new i; i < sizeof(EventKernel[EventStaff]); i++) {
				EventKernel[EventStaff][i] = INVALID_PLAYER_ID;
			}	
			EventKernel[EventCustomInterior] = 0;
			SendClientMessageToAllEx( COLOR_LIGHTBLUE, "* Admin da ket thuc su kien." );
		}
		else
		{
			SendClientMessageEx( playerid, COLOR_WHITE, "Hien khong co su kien dang chay." );
		}
	}
	return 1;
}
 
CMD:startevent(playerid, params[])
{
	if( PlayerInfo[ playerid ][ pAdmin ] >= 2 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pDonateRank] >= 4 || PlayerInfo[playerid][pSEC] >= 2)
	{
		new string[128];

		if( EventKernel[ EventStatus ] == 0)
		{
			if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
			{
				if(EventKernel[ EventHealth ] == 0)
				{
					SendClientMessageEx( playerid, COLOR_GRAD2, "Ban chua dat mau cho su kien!" );
					return 1;
				}
				if((EventKernel[ EventPositionX ] == 0 || EventKernel[ EventPositionY ] == 0 || EventKernel[ EventPositionZ ] == 0) && EventKernel[EventType] != 3)
				{
					SendClientMessageEx( playerid, COLOR_GRAD2, "Ban chua dat vi tri su kien!" );
					return 1;
				}
				if( (EventKernel[ EventTeamPosX1 ] == 0 || EventKernel[ EventTeamPosY1 ] == 0 || EventKernel[ EventTeamPosZ1 ] == 0) && EventKernel[ EventType ] == 2)
				{
					SendClientMessageEx( playerid, COLOR_GRAD2, "Ban chua dat diem xuat hien doi 1!" );
					return 1;
				}
				if( (EventKernel[ EventTeamPosX2 ] == 0 || EventKernel[ EventTeamPosY2 ] == 0 || EventKernel[ EventTeamPosZ2 ] == 0) && EventKernel[ EventType ] == 2)
				{
					SendClientMessageEx( playerid, COLOR_GRAD2, "Ban chua dat diem xuat hien doi 2!" );
					return 1;
				}
				if(EventKernel[ EventLimit ] == 0)
				{
					EventKernel[ EventLimit ] = 60;
				}
				EventKernel[ EventStatus ] = 1;
				SendClientMessageEx( playerid, COLOR_GRAD2, "Ban da tao su kien, dung /announceevent de thong bao toan may chu." );
				foreach(new i: Player)
				{
					if(PlayerInfo[i][pDonateRank] >= 3)
					{
						SendClientMessageEx(i, COLOR_YELLOW, "* Tinh nang Gold+ VIP: Su kien da mo! /joinevent de vao som");
					}
				}	
				return 1;
			}
			else if( EventKernel[EventCreator] == playerid)
			{
				if(EventKernel[ EventHealth ] == 0)
				{
					SendClientMessageEx( playerid, COLOR_GRAD2, "Ban chua dat mau cho su kien!" );
					return 1;
				}
				if((EventKernel[ EventPositionX ] == 0 || EventKernel[ EventPositionY ] == 0 || EventKernel[ EventPositionZ ] == 0) && EventKernel[EventType] != 3)
				{
					SendClientMessageEx( playerid, COLOR_GRAD2, "Ban chua dat vi tri su kien!" );
					return 1;
				}
				if(EventKernel[ EventLimit ] == 0)
				{
					EventKernel[ EventLimit ] = 60;
				}
				EventKernel[ EventStartRequest ] = 1;
				SendClientMessageEx( playerid, COLOR_GRAD2, "Ban de nghi bat dau su kien, hay cho Senior Admin duyet." );
				if(EventKernel[EventType] != 3)
				{
					format( string, sizeof( string ), "Vi tri su kien: x:%f y:%f z:%f.", EventKernel[EventPositionX], EventKernel[EventPositionY], EventKernel[EventPositionZ] );
					ABroadCast( COLOR_GRAD2, string, 4 );
					format( string, sizeof( string ), "Loi moi su kien: %s Gioi han: %d.", EventKernel[EventInfo], EventKernel[EventLimit] );
					ABroadCast( COLOR_GRAD2, string, 4 );
					format( string, sizeof( string ), "Mau su kien: %f Giap su kien: %f.", EventKernel[EventHealth], EventKernel[EventArmor] );
					ABroadCast( COLOR_GRAD2, string, 4 );
					if(EventKernel[EventWeapons][0] != 0)
					{
						format( string, sizeof( string ), "Vu khi 1: %d.", EventKernel[EventWeapons][0] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
					if(EventKernel[EventWeapons][1] != 0)
					{
						format( string, sizeof( string ), "Vu khi 2: %d.", EventKernel[EventWeapons][1] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
					if(EventKernel[EventWeapons][2] != 0)
					{
						format( string, sizeof( string ), "Vu khi 3: %d.", EventKernel[EventWeapons][2] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
					if(EventKernel[EventWeapons][3] != 0)
					{
						format( string, sizeof( string ), "Vu khi 4: %d.", EventKernel[EventWeapons][3] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
					if(EventKernel[EventWeapons][4] != 0)
					{
      					format( string, sizeof( string ), "Vu khi 5: %d.", EventKernel[EventWeapons][4] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
					if(EventKernel[EventType] == 2)
					{
						format( string, sizeof( string ), "Mau doi su kien 1: %d Skin doi su kien 1: %d.", EventKernel[EventTeamColor][0], EventKernel[EventTeamSkin][0] );
						ABroadCast( COLOR_GRAD2, string, 4 );
						format( string, sizeof( string ), "Mau doi su kien 2: %d Skin doi su kien 2: %d.", EventKernel[EventTeamColor][1], EventKernel[EventTeamSkin][1] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
				}
				else {
				    if(EventKernel[EventTime] != 0) {
				    	format( string, sizeof( string ), "Loi moi su kien: %s Gioi han gio: %d.", EventKernel[EventInfo], EventKernel[EventTime] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
					else {
						format( string, sizeof( string ), "Loi moi su kien: %s Gioi han: %d.", EventKernel[EventInfo], EventKernel[EventLimit] );
						ABroadCast( COLOR_GRAD2, string, 4 );
					}
					ABroadCastText( COLOR_GRAD2, "Day la su kien dua, dung /edit checkpoints de xem cac checkpoint", 4 );
				}
				format( string, sizeof( string ), "{AA3333}AdmWarning{FFFF00}: %s muon bat dau su kien, ban dong y? /approveevent hoac /denyevent.", GetPlayerNameEx(playerid) );
				ABroadCast( COLOR_YELLOW, string, 4 );
			}
		}
		else
		{
			SendClientMessageEx( playerid, COLOR_WHITE, "Da co su kien dang chay (dung /endevent)." );
		}
	}

	return 1;
}

CMD:beginevent(playerid, params[])
{
	if( PlayerInfo[ playerid ][ pAdmin ] >= 4 || EventKernel[EventCreator] == playerid)
	{
		if( EventKernel[ EventStatus ] == 3 )
		{
		    if(EventKernel[EventType] == 3 && EventKernel[EventTime] != 0) return SendClientMessageEx(playerid, COLOR_RED, "LOI: Tinh nang nay khong dung duoc voi cau hinh su kien nay.");
			EventKernel[ EventStatus ] = 4;
   			new zombiemade;
			foreach(new i: Player)
			{
				if( GetPVarType( i, "EventToken" ) == 1 )
				{
					if( EventKernel[ EventType ] == 1 )
					{
						//GivePlayerEventWeapons( i );
						SendClientMessageEx( i, COLOR_LIGHTBLUE, "BAT DAU! Su kien da bat dau." );
						if(GetPVarInt(i, "eventStaff") < 1) {
							SetHealth( i, EventKernel[ EventHealth ] );
						}	
						if(EventKernel[EventArmor] > 0 && GetPVarInt(i, "eventStaff") < 1) {
							SetArmour( i, EventKernel[ EventArmor ]);
						}
						GivePlayerEventWeapons( i );
					}
					else if( EventKernel[ EventType ] == 2 )
					{
						//GivePlayerEventWeapons( i );
						SendClientMessageEx( i, COLOR_LIGHTBLUE, "BAT DAU! Su kien da bat dau." );
						if(GetPVarInt(i, "eventStaff") < 1) {
							SetHealth( i, EventKernel[ EventHealth ] );
						}
						if(EventKernel[EventArmor] > 0 && GetPVarInt(i, "eventStaff") < 1) {
							SetArmour( i, EventKernel[ EventArmor ]);
						}	
						GivePlayerEventWeapons( i );
					}
					else if( EventKernel[ EventType ] == 4 )
					{
						if(zombiemade == 0)
						{
							SendClientMessageEx(playerid, COLOR_WHITE, "Ban la zombie! Dung /bite de lay nhiem nguoi khac");
							SetHealth(playerid, 30);
							RemoveArmor(playerid);
							SetPlayerSkin(playerid, 134);
							SetPlayerColor(playerid, 0x0BC43600);
							SetPVarInt(playerid, "pEventZombie", 1);
							zombiemade=1;
							continue;
						}
						else
						{
							//GivePlayerEventWeapons( i );
							SendClientMessageEx( i, COLOR_LIGHTBLUE, "Su kien da bat dau, hay diet zombie (ten mau xanh!)" );
							if(GetPVarInt(i, "eventStaff") < 1) {
								SetHealth( i, EventKernel[ EventHealth ] );
							}	
							if(EventKernel[EventArmor] > 0 && GetPVarInt(i, "eventStaff") < 1) {
								SetArmour( i, EventKernel[ EventArmor ]);
							}
							GivePlayerEventWeapons( i );
						}
					}
				}
				else
				{
					SendClientMessageEx( i, COLOR_WHITE, "Su kien da bat dau. Dung /joinevent de tham gia lan sau." );
				}
			}	
		}
		else
		{
			SendClientMessageEx( playerid, COLOR_WHITE, "Da co su kien dang chay (dung /endevent)." );
		}
	}
	return 1;
}

CMD:announceevent(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || EventKernel[EventCreator] == playerid)
	{
		if( EventKernel[ EventStatus ] == 1)
		{
			EventKernel[ EventStatus ] = 2;
			SendClientMessageEx(playerid, COLOR_GRAD2, "Dung /lockevent de khoa su kien");
			if(EventKernel[VipOnly] == 1) SendClientMessageToAllEx( COLOR_LIGHTBLUE, "* Admin da mo su kien chi danh cho VIP, VIP dung /joinevent de tham gia." );
			else SendClientMessageToAllEx( COLOR_LIGHTBLUE, "* Admin da mo su kien, dung /joinevent de tham gia." );
		}
		else
		{
			SendClientMessageEx( playerid, COLOR_WHITE, "Da co su kien dang chay (dung /endevent)." );
		}
	}
	return 1;
}

CMD:lockevent(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || EventKernel[EventCreator] == playerid)
	{
		if( EventKernel[ EventStatus ] == 2 )
		{
		    if(EventKernel[EventType] == 3 && EventKernel[EventTime] != 0) return SendClientMessageEx(playerid, COLOR_RED, "LOI: Tinh nang nay khong dung duoc voi cau hinh su kien nay.");
			EventKernel[ EventStatus ] = 3;
			SendClientMessageEx( playerid, COLOR_GRAD2, "Da khoa su kien, dung /beginevent de chinh thuc bat dau." );
			SendClientMessageToAllEx( COLOR_LIGHTBLUE, "* Admin da khoa su kien." );
		}
		else
		{
			SendClientMessageEx( playerid, COLOR_WHITE, "Da co su kien dang chay (dung /endevent)." );
		}
	}
	return 1;
}

CMD:event(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || EventKernel[EventCreator] == playerid)
	{
		if(EventKernel[ EventStatus ] == 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Hien khong co su kien dang chay.");
		new string[128];
		format(string, sizeof(string), "[Event] %s: %s", GetPlayerNameEx(playerid), params);
		foreach(new i: Player)
		{
			if(GetPVarInt(i, "EventToken") || PlayerInfo[i][pAdmin] >= 2 || EventKernel[EventCreator] == i || GetPVarInt(i, "eventStaff"))
			{
				SendClientMessageEx(i, COLOR_OOC, string);
			}
		}
	}
	return 1;
}