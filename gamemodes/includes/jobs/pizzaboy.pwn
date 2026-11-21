/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Pizzaboy System

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

enum ePizzaDelivery
{
	Float:pizzaX,
	Float:pizzaY,
	Float:pizzaZ,
	pizzaDeadline,
	pizzaEarliest
}
new PizzaDelivery[MAX_PLAYERS][ePizzaDelivery];

Pizza_HasCheckpoint(playerid)
{
	new Float:x, Float:y, Float:z, Float:radius;
	return gPlayerCheckpointStatus[playerid] == CHECKPOINT_PIZZA && GetPlayerCheckpoint(playerid, x, y, z, radius)
		&& x == PizzaDelivery[playerid][pizzaX] && y == PizzaDelivery[playerid][pizzaY]
		&& z == PizzaDelivery[playerid][pizzaZ] && radius == 5.0;
}

Pizza_StopDelivery(playerid)
{
	if(!GetPVarType(playerid, "Pizza")) return 1;
	if(Pizza_HasCheckpoint(playerid)) DisablePlayerCheckpoint(playerid);
	if(gPlayerCheckpointStatus[playerid] == CHECKPOINT_PIZZA) gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
	DeletePVar(playerid, "Pizza");
	PizzaDelivery[playerid][pizzaDeadline] = 0;
	PizzaDelivery[playerid][pizzaEarliest] = 0;
	return 1;
}

Pizza_CanWork(playerid)
{
	return gPlayerLogged{playerid} && !PlayerIsDead[playerid] && !GetPVarInt(playerid, "Injured") && !PlayerInfo[playerid][pHospital]
		&& (Job_HasJob(playerid, JOB_PIZZA))
		&& GetPlayerSkin(playerid) == 155 && GetPlayerState(playerid) != PLAYER_STATE_SPECTATING
		&& GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0
		&& !GetPVarType(playerid, "WatchingTV") && !GetPVarType(playerid, "PreviewingTV")
		&& !GetPVarType(playerid, "IsInArena") && !GetPVarType(playerid, "EventToken")
		&& HungerPlayerInfo[playerid][hgInEvent] == 0 && !PlayerBoxing[playerid] && !GetPVarInt(playerid, "_BoxingFight");
}

Pizza_Update(playerid, bool:deliver = false)
{
	if(!GetPVarType(playerid, "Pizza")) return 1;
	new houseid = GetPVarInt(playerid, "Pizza");
	if(!(0 <= houseid < MAX_HOUSES) || !Pizza_CanWork(playerid) || !Pizza_HasCheckpoint(playerid))
	{
		Pizza_StopDelivery(playerid);
		return SendClientMessageEx(playerid, COLOR_GREY, "Chuyen giao pizza da bi huy.");
	}
	if(!HouseInfo[houseid][hOwned] || HouseInfo[houseid][hExtIW] != 0 || HouseInfo[houseid][hExtVW] != 0
		|| HouseInfo[houseid][hExteriorX] != PizzaDelivery[playerid][pizzaX]
		|| HouseInfo[houseid][hExteriorY] != PizzaDelivery[playerid][pizzaY]
		|| HouseInfo[houseid][hExteriorZ] != PizzaDelivery[playerid][pizzaZ])
	{
		Pizza_StopDelivery(playerid);
		return SendClientMessageEx(playerid, COLOR_GREY, "Diem giao pizza khong con hop le.");
	}
	new now = gettime(), remaining = PizzaDelivery[playerid][pizzaDeadline] - now;
	if(remaining <= 0)
	{
		Pizza_StopDelivery(playerid);
		return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong giao kip pizza truoc khi nguoi!");
	}
	if(!deliver)
	{
		new message[96];
		format(message, sizeof(message), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Con %d giay", remaining);
		GameTextForPlayer(playerid, message, 1100, 3);
		return 1;
	}
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, PizzaDelivery[playerid][pizzaX], PizzaDelivery[playerid][pizzaY], PizzaDelivery[playerid][pizzaZ])) return 1;
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT
		&& (GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !IsAPizzaCar(GetPlayerVehicleID(playerid))))
		return SendClientMessageEx(playerid, COLOR_GREY, "Giao pizza khi di bo hoac lai Pizzaboy.");
	if(remaining > cellmax / 70 || GetPlayerCash(playerid) > cellmax - remaining * 70)
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the nhan tien giao pizza.");

	if(now < PizzaDelivery[playerid][pizzaEarliest])
	{
		new message[128];
		format(message, sizeof(message), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) co dau hieu teleport de giao pizza.", GetPlayerNameEx(playerid), playerid);
		ABroadCast(COLOR_YELLOW, message, 2);
	}
	new payment = remaining * 70;
	Pizza_StopDelivery(playerid);
	GivePlayerCash(playerid, payment);
	SendClientMessageEx(playerid, COLOR_WHITE, "Da giao pizza den noi! Ban nhan $%d.", payment);
	return 1;
}

CMD:getpizza(playerid, params[])
{
	if(!Job_HasJob(playerid, JOB_PIZZA))
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Pizza Boy!");
	
	if(GetPVarType(playerid, "Pizza")) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang giao pizza!");
	
	if(GetPlayerSkin(playerid) != 155) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Can mac dong phuc Pizza Stack!");
	
	if(!Pizza_CanWork(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the nhan pizza.");
	
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !IsAPizzaCar(GetPlayerVehicleID(playerid)))
		return SendClientMessageEx(playerid, COLOR_GREY, "Can lai Pizzaboy o ben hong Pizza Stack!");
	
	if(CheckPointCheck(playerid) || IsPlayerCheckpointActive(playerid))
		return SendClientMessageEx(playerid, COLOR_GREY, "Xong hoac huy checkpoint truoc khi nhan pizza.");

	new bool:sanFierro = IsPlayerInRangeOfPoint(playerid, 5.0, -1713.961425, 1348.545166, 7.180452);
	if(!sanFierro && !IsPlayerInRangeOfPoint(playerid, 5.0, 2103.6714, -1785.5222, 12.9849))
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o diem nhan Pizza Stack!");
	new now = gettime(), remaining = GetPVarInt(playerid, "PizzaCoolDown") - now;
	if(remaining > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Cho %d giay de nhan pizza tiep!", remaining);

	new houseid = random(MAX_HOUSES), distance, bool:found;
	for(new checked; checked < MAX_HOUSES; ++checked)
	{
		if(HouseInfo[houseid][hOwned] && HouseInfo[houseid][hExteriorZ] <= 100.0
			&& HouseInfo[houseid][hExtIW] == 0 && HouseInfo[houseid][hExtVW] == 0)
		{
			new bool:inCity = sanFierro
				? (-2802.389648 < HouseInfo[houseid][hExteriorX] < -1400.710327 && -216.298019 < HouseInfo[houseid][hExteriorY] < 2800.0)
				: (516.5287 < HouseInfo[houseid][hExteriorX] < 2881.0891 && -1785.5222 < HouseInfo[houseid][hExteriorY] < -909.6716);
			if(inCity)
			{
				distance = floatround(GetPlayerDistanceFromPoint(playerid, HouseInfo[houseid][hExteriorX], HouseInfo[houseid][hExteriorY], HouseInfo[houseid][hExteriorZ]));
				if(distance >= 10)
				{
					found = true;
					break;
				}
			}
		}
		if(++houseid == MAX_HOUSES) houseid = 0;
	}
	if(!found) return SendClientMessageEx(playerid, COLOR_GREY, "Khong co nha hop le de giao pizza trong thanh pho.");

	PizzaDelivery[playerid][pizzaX] = HouseInfo[houseid][hExteriorX];
	PizzaDelivery[playerid][pizzaY] = HouseInfo[houseid][hExteriorY];
	PizzaDelivery[playerid][pizzaZ] = HouseInfo[houseid][hExteriorZ];
	PizzaDelivery[playerid][pizzaDeadline] = now + distance / 10;
	PizzaDelivery[playerid][pizzaEarliest] = now + distance / 80;
	SetPVarInt(playerid, "Pizza", houseid);
	SetPVarInt(playerid, "PizzaCoolDown", now + 60);
	gPlayerCheckpointStatus[playerid] = CHECKPOINT_PIZZA;
	SetPlayerCheckpoint(playerid, PizzaDelivery[playerid][pizzaX], PizzaDelivery[playerid][pizzaY], PizzaDelivery[playerid][pizzaZ], 5.0);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban nhan pizza cho %s. Co %d giay de giao!", StripUnderscore(HouseInfo[houseid][hOwnerName]), distance / 10);
	return 1;
}
