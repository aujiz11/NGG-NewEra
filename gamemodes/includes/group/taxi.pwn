/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Taxi Group Type

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
stock SendTaxiMessage(color, const string[])
{
	foreach(new i: Player)
	{
		if((IsATaxiDriver(i) && PlayerInfo[i][pDuty] > 0) || (IsATaxiDriver(i) && TransportDuty[i] > 0)) {
			SendClientMessageEx(i, color, string);
		}
	}	
}

stock Taxi_StopDuty(playerid)
{
	if(TransportDuty[playerid] == 0) return 1;
	new payment = TransportMoney[playerid] / 100 * 50;
	if(GetPlayerCash(playerid) > cellmax - payment)
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the nhan so tien cuoc con lai."), 0;

	if(TransportDuty[playerid] == 1)
	{
		TaxiDrivers -= 1;
	}
	else if(TransportDuty[playerid] == 2)
	{
		BusDrivers -= 1;
	}

	TransportDuty[playerid] = 0;
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nghi truc va kiem duoc $%d.", TransportMoney[playerid]);
	GivePlayerCash(playerid, payment);
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_TAXI))
	{
		arrGroupData[PlayerInfo[playerid][pMember]][g_iBudget] += (TransportMoney[playerid] / 100 * 50);
		if(TransportMoney[playerid]) format(szMiscArray, sizeof(szMiscArray), "%s is now off duty and earned $%s", GetPlayerNameEx(playerid), number_format(TransportMoney[playerid])), GroupLog(PlayerInfo[playerid][pMember], szMiscArray);
	}
	TransportValue[playerid] = 0; TransportMoney[playerid] = 0;
	SetPlayerToTeamColor(playerid);
	return 1;
}

CMD:fare(playerid, params[])
{
	if(IsATaxiDriver(playerid))
	{
		new string[128], fare;
		if(sscanf(params, "d", fare)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /fare [price]");

		if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");

		if(TransportDuty[playerid] > 0) return Taxi_StopDuty(playerid);
		if(GetPVarInt(playerid, "MechanicDuty") == 1 || GetPVarInt(playerid, "LawyerDuty") == 1) return SendClientMessageEx(playerid,COLOR_GREY,"Ban can nghi truc Mechanic/Lawyer truoc.");
		if(GetPlayerState(playerid) != 2) return SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong phai nguoi lai!");
		if(fare < 1 || fare > 2000) return SendClientMessageEx(playerid, COLOR_GREY, "   Gia cuoc phai tu $1 den $2000!");
		new newcar = GetPlayerVehicleID(playerid);
		if(IsAnBus(newcar))
		{
			fare = 1500;
			BusDrivers += 1; TransportDuty[playerid] = 2; TransportValue[playerid] = fare;
			format(string, sizeof(string), "Ban da truc Bus Driver, gia cuoc: $%d.", TransportValue[playerid]);
		}
		else
		{
			TaxiDrivers += 1; TransportDuty[playerid] = 1; TransportValue[playerid] = fare;
			format(string, sizeof(string), "Ban da truc Taxi Driver, gia cuoc: $%d.", TransportValue[playerid]);
		}
		SendClientMessageEx(playerid, COLOR_WHITE, string);
		if(IsATaxiDriver(playerid)) SetPlayerColor(playerid, COLOR_TAXI); else SetPlayerColor(playerid,TEAM_TAXI_COLOR);
	}
	else
	{
		return SendClientMessageEx(playerid,COLOR_GREY,"Ban khong phai tai xe taxi/bus duoc cap phep!");
	}
	return 1;
}





alias:emergencybutton("eba")
CMD:emergencybutton(playerid, params[]) {

	if(arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == 7 || arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] == 7 || IsAReporter(playerid)) {
		
		new
			szLocation[MAX_ZONE_NAME];
				
        if(PlayerCuffed[playerid] >= 1 || PlayerInfo[playerid][pJailTime] > 0 || PlayerInfo[playerid][pHospital] > 0 || PlayerTied[playerid] > 0 ) {
			return SendClientMessageEx(playerid, COLOR_WHITE, "Ban chua the lam viec nay.");
		}

		if(GetPVarType(playerid, "UsedEBA")) {

			if(!IsAReporter(playerid)) {
				format(szMiscArray, sizeof(szMiscArray), "HQ: Tin hieu cau cuu SA News cua %s da bi huy", GetPlayerNameEx(playerid));
				SendGroupMessage(GROUP_TYPE_NEWS, TEAM_BLUE_COLOR, szMiscArray);
			}
			else {
				format(szMiscArray, sizeof(szMiscArray), "HQ: Tin hieu cau cuu hang taxi cua %s da bi huy", GetPlayerNameEx(playerid));
				SendTaxiMessage(TEAM_AZTECAS_COLOR, szMiscArray);
			}
			foreach(new i: Player) {

				if(IsACop(i)) SendClientMessageEx(i, TEAM_BLUE_COLOR, szMiscArray);
			}
			
			SendClientMessage(playerid, COLOR_WHITE, "Ban da huy nut khan cap.");
			DeletePVar(playerid, "UsedEBA");
			return 1;
		}

		GetPlayer2DZone(playerid, szLocation, MAX_ZONE_NAME);
	    foreach(new i: Player) {

	    	if(IsACop(i)) {
				if(!IsAReporter(playerid)) SendClientMessageEx(i, TEAM_BLUE_COLOR, "HQ: Moi don vi APB: Nguoi bao: Taxi Company Office");
				else SendClientMessageEx(i, TEAM_BLUE_COLOR, "HQ: Moi don vi APB: Nguoi bao: SA News");

				if(!IsAReporter(playerid)) format(szMiscArray, sizeof(szMiscArray), "HQ: Taxi Company Office chuyen tin hieu cau cuu cua %s tai %s",GetPlayerNameEx(playerid), szLocation);
				else format(szMiscArray, sizeof szMiscArray, "HQ: SA News chuyen tin hieu cau cuu cua %s tai %s", GetPlayerNameEx(playerid), szLocation);

				SendClientMessageEx(i, TEAM_BLUE_COLOR, szMiscArray);
			}
		}
		format(szMiscArray, sizeof(szMiscArray), "* Bao dong xe %s vang len tai %s. Tin nhan duoc gui ve van phong cong ty.", GetPlayerNameEx(playerid), szLocation);
		SendTaxiMessage(TEAM_AZTECAS_COLOR, szMiscArray);
		SendClientMessage(playerid, COLOR_WHITE, "Ban da nhan nut khan cap. Canh sat da duoc thong bao.");
		SetPVarInt(playerid, "UsedEBA", 1);
	}
	return 1;
}


alias:ataxi("abus")
CMD:ataxi(playerid, params[])
{
	if(!IsATaxiDriver(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai tai xe taxi/bus!");
	if(TransportDuty[playerid] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua truc.");

	new
		szMessage[128],
		iTarget;
	if(TransportDuty[playerid] == 1)
	{
		if(sscanf(params, "u", iTarget)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ataxi [player]");
		if(!IsPlayerConnected(iTarget)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		if(iTarget == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the nhan cuoc goi taxi cua minh.");
		if(TaxiCallTime[playerid] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhan mot cuoc goi.");
		if(!GetPVarType(iTarget, "TaxiCall")) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong goi taxi.");

		format(szMessage, sizeof(szMessage), "** Taxi Driver %s da nhan cuoc goi Taxi tu %s(%d)" , GetPlayerNameEx(playerid), GetPlayerNameEx(iTarget), iTarget);
		SendTaxiMessage(TEAM_AZTECAS_COLOR, szMessage);
		SendClientMessageEx(iTarget, COLOR_LIGHTBLUE, "* Taxi Driver %s da nhan cuoc goi Taxi, hay cho tai vi tri hien tai.", GetPlayerNameEx(playerid));
		GameTextForPlayer(playerid, "~w~Nguoi goi Taxi~n~~r~Den diem do.", 5000, 1);
		TaxiCallTime[playerid] = 1;
		TaxiAccepted[playerid] = iTarget;
		DeletePVar(iTarget, "TaxiCall");
	}
	if(TransportDuty[playerid] == 2)
	{
		if(sscanf(params, "u", iTarget)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /abus [player]");
		if(!IsPlayerConnected(iTarget)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		if(iTarget == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the nhan cuoc goi bus cua minh.");
		if(BusCallTime[playerid] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhan mot cuoc goi.");
		if(!GetPVarType(iTarget, "BusCall")) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong goi bus.");
		
		format(szMessage, sizeof(szMessage), "** Bus Driver %s da nhan cuoc goi Bus tu %s(%d)" , GetPlayerNameEx(playerid), GetPlayerNameEx(iTarget), iTarget);
		SendTaxiMessage(TEAM_AZTECAS_COLOR, szMessage);
		SendClientMessageEx(iTarget, COLOR_LIGHTBLUE, "* Bus Driver %s da nhan cuoc goi Bus, hay cho tai vi tri hien tai.", GetPlayerNameEx(playerid));
		GameTextForPlayer(playerid, "~w~Nguoi goi Bus~n~~r~Den diem do", 5000, 1);
		BusCallTime[playerid] = 1;
		BusAccepted[playerid] = iTarget;
		DeletePVar(iTarget, "BusCall");
	}
	PlayerInfo[playerid][pCallsAccepted]++;
	return 1;
}
