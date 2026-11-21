/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Service Commands

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

CMD:service(playerid, const params[])
{
	new string[128], choice[32];
	if(sscanf(params, "s[32]", choice))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /service [name]");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Taxi, Bus, Medic, Mechanic, EMS");
		return 1;
	}

	if(PlayerInfo[playerid][pJailTime] > 0)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung khi o tu.");
		return 1;
	}
	if(gettime() < PlayerInfo[playerid][pServiceTime]) return SendClientMessage(playerid, COLOR_WHITE, "Can cho 30 giay truoc khi dung lai lenh nay." );

	if(strcmp(choice,"ems",true) == 0)
	{
		if(GetPVarInt(playerid, "Injured") == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong bi thuong, chua the goi EMS!");
			return 1;
		}
		new zone[MAX_ZONE_NAME];
		GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
		SetPVarInt(playerid, "EMSAttempt", 1);
		SendClientMessageEx(playerid, COLOR_WHITE, "EMS da nhan vi tri va dang den.");
		format(string, sizeof(string), "Emergency Dispatch bao (%d) %s tai %s can xe cap cuu ngay (/emslist).",playerid, GetPlayerNameEx(playerid), zone);
		SendMedicMessage(TEAM_MED_COLOR, string);
		PlayerInfo[playerid][pServiceTime] = gettime()+30;
		return 1;
	}
	else if(strcmp(choice,"taxi",true) == 0)
	{
		if(TaxiDrivers < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co Taxi Driver truc, hay thu lai sau!");
		if(TransportDuty[playerid] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Luc nay khong the goi taxi!");

		if(GetPVarInt(playerid, "TaxiCall")) return SendClientMessage(playerid, COLOR_GREY, "	Ban da co yeu cau taxi dang cho (/cancel taxi).");

		new szZoneName[MAX_ZONE_NAME];
		GetPlayer2DZone(playerid, szZoneName, MAX_ZONE_NAME);
		format(string, sizeof(string), "** %s (%d) can taxi tai %s - dung /ataxi de nhan cuoc.", GetPlayerNameEx(playerid), playerid, szZoneName );
		SendTaxiMessage(TEAM_AZTECAS_COLOR, string);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da goi taxi, hay cho phan hoi.");
		SetPVarInt(playerid, "TaxiCall", 1);
		PlayerInfo[playerid][pServiceTime] = gettime()+30;
		return 1;
	}
	else if(strcmp(choice,"bus",true) == 0)
	{
		if(BusDrivers < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co Bus Driver, hay thu lai sau!");
		if(TransportDuty[playerid] > 0) SendClientMessageEx(playerid, COLOR_GREY, "Luc nay khong the goi xe buyt!");
		
		new szZoneName[MAX_ZONE_NAME];
		GetPlayer2DZone(playerid, szZoneName, sizeof(szZoneName));
		format(string, sizeof(string), "** %s(%d) can xe buyt tai %s - dung /abus de nhan cuoc.", GetPlayerNameEx(playerid), playerid, szZoneName );
		SendTaxiMessage(TEAM_AZTECAS_COLOR, string);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da goi xe buyt, hay cho phan hoi.");
		SetPVarInt(playerid, "BusCall", 1);
		PlayerInfo[playerid][pServiceTime] = gettime()+30;
		return 1;
	}
	else if(strcmp(choice,"medic",true) == 0)
	{
		new OnDutyMedics;
		foreach(new i: Player)
		{
			if(IsAMedic(i) || IsFirstAid(i) && PlayerInfo[i][pDuty] == 1)
			{
				OnDutyMedics++;
			}
		}	
		if(OnDutyMedics < 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co Medic truc, hay thu lai sau!");
			return 1;
		}
		else
		{
			format(string, sizeof(string), "** %s can Medic - dung /accept medic de nhan cuoc.", GetPlayerNameEx(playerid));
			SendDivisionMessage(12, 2, TEAM_AZTECAS_COLOR, string);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da goi Medic, hay cho phan hoi.");
			MedicCall = playerid;
			PlayerInfo[playerid][pServiceTime] = gettime()+30;
			return 1;
		}
	}
	else if(strcmp(choice,"mechanic",true) == 0)
	{
		if(Mechanics < 1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co Mechanic truc, hay thu lai sau!");
			return 1;
		}
		format(string, sizeof(string), "** %s can Mechanic - dung /accept mechanic de nhan cuoc.", GetPlayerNameEx(playerid));
		SendJobMessage(JOB_MECHANIC, TEAM_AZTECAS_COLOR, string);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da goi Mechanic, hay cho phan hoi.");
		MechanicCall = playerid;
		PlayerInfo[playerid][pServiceTime] = gettime()+30;
		return 1;
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ten dich vu khong hop le!");
		return 1;
	}
}