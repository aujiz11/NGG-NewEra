/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Shop Core

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

CreateHouseSaleSign(houseid)
{
	if(!HouseInfo[houseid][hSign][0]) return 1;
	if(IsValidDynamicObject(HouseInfo[houseid][hSignObj])) DestroyDynamicObject(HouseInfo[houseid][hSignObj]);
	if(IsValidDynamic3DTextLabel(HouseInfo[houseid][hSignText])) DestroyDynamic3DTextLabel(HouseInfo[houseid][hSignText]);
	new string[64];
	HouseInfo[houseid][hSignObj] = CreateDynamicObject(19471, HouseInfo[houseid][hSign][0], HouseInfo[houseid][hSign][1], HouseInfo[houseid][hSign][2], 0, 0, HouseInfo[houseid][hSign][3], HouseInfo[houseid][hExtVW], HouseInfo[houseid][hExtIW]);
	format(string,sizeof(string),"ID: %d\nDung /readsign de doc loi nhan cua chu nha.", houseid);
	HouseInfo[houseid][hSignText] = CreateDynamic3DTextLabel(string, COLOR_YELLOW, HouseInfo[houseid][hSign][0], HouseInfo[houseid][hSign][1], HouseInfo[houseid][hSign][2] + 0.5, 10.0, .worldid = HouseInfo[houseid][hExtVW], .streamdistance = 25.0);
	return 1;
}

DeleteHouseSaleSign(houseid)
{
	format(HouseInfo[houseid][hSignDesc], 64, "None");
	HouseInfo[houseid][hSign][0] = 0.0;
	HouseInfo[houseid][hSign][1] = 0.0;
	HouseInfo[houseid][hSign][2] = 0.0;
	HouseInfo[houseid][hSign][3] = 0.0;
	HouseInfo[houseid][hSignExpire] = 0;
	if(IsValidDynamicObject(HouseInfo[houseid][hSignObj])) DestroyDynamicObject(HouseInfo[houseid][hSignObj]);
	if(IsValidDynamic3DTextLabel(HouseInfo[houseid][hSignText])) DestroyDynamic3DTextLabel(HouseInfo[houseid][hSignText]);
	SaveHouse(houseid);
	return 1;
}

forward FuelCan(playerid, vehicleid, amount);
public FuelCan(playerid, vehicleid, amount)
{
	new string[128];
	if(GetPVarInt(playerid, "fuelcan") == 1)
	{
		PlayerInfo[playerid][mInventory][7]--;
		format(string, sizeof(string), "[FUELCAN] %s(%d) used a fuel can. Left: %d", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), PlayerInfo[playerid][mInventory][7]);
		Log("logs/micro.log", string);
	}
	if(GetPVarInt(playerid, "fuelcan") == 2)
	{
		format(string, sizeof(string), "[ZFUELCAN] %s(%d) used a fuel can with %d%% fuel.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), PlayerInfo[playerid][zFuelCan]);
		Log("logs/micro.log", string);
		PlayerInfo[playerid][zFuelCan] = 0;
	}
	VehicleFuel[vehicleid] += float(amount);
	if(VehicleFuel[vehicleid] > 100) VehicleFuel[vehicleid] = 100.0;
	format(string, sizeof(string), "%s dung Fuel Can de do xang cho xe.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da dung Fuel Can de do xang cho xe.");
	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, false, false, false, false, 0, 1);
	DeletePVar(playerid, "fuelcan");
	return 1;
}

forward JumpStart(playerid, vehicleid);
public JumpStart(playerid, vehicleid)
{
	PlayerInfo[playerid][mInventory][8]--;
	RepairVehicle(vehicleid);
	Vehicle_Armor(vehicleid);
	if(IsTrailerAttachedToVehicle(vehicleid))
	{
		RepairVehicle(GetVehicleTrailer(vehicleid));
		Vehicle_Armor(GetVehicleTrailer(vehicleid));
	}
	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid, engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehicleid, engine,lights,alarm,doors,VEHICLE_PARAMS_ON,boot,objective);
	new string[128];
	format(string, sizeof(string), "%s da kich no xe.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	SendClientMessage(playerid, COLOR_WHITE, "Xe cua ban da duoc kich no!");
	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, false, false, false, false, 0, 1);
	format(string, sizeof(string), "[JUMPSTART] %s(%d) used a jump start. Left: %d", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), PlayerInfo[playerid][mInventory][8]);
	Log("logs/micro.log", string);
	DeletePVar(playerid, "jumpstarting");
	return 1;
}

forward EatBar(playerid);
public EatBar(playerid)
{
	PlayerInfo[playerid][mInventory][4]--;
	PlayerInfo[playerid][mCooldown][4] = 60;
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, false, false, false, false, 0, 1);
	SendClientMessageEx(playerid, -1, "Ban da dung Energy Bar, tac dung keo dai 1 gio.");
	SendClientMessageEx(playerid, -1, "Mau cua ban se giam cham hon khi bi thuong.");
	new string[128];
	format(string, sizeof(string), "[ENERGYBAR] %s(%d) used a energy bar. Left: %d", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), PlayerInfo[playerid][mInventory][4]);
	Log("logs/micro.log", string);
	DeletePVar(playerid, "eatingbar");
	return 1;
}

stock HireCost(carid)
{
	switch (carid)
	{
		case 69:
		{
			return 90000; //bullit
		}
		case 70:
		{
			return 130000; //infurnus
		}
		case 71:
		{
			return 100000; //turismo
		}
		case 72:
		{
			return 80000;
		}
		case 73:
		{
			return 70000;
		}
		case 74:
		{
			return 60000;
		}
	}
	return 0;
}

forward TeleportToShop(playerid);
public TeleportToShop(playerid)
{
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] || PlayerInfo[playerid][pJailTime] > 0 || GetPVarInt(playerid, "EventToken") == 1 || GetPVarInt(playerid, "IsInArena") || !GetPVarInt(playerid, "ShopTP"))
		return DeletePVar(playerid, "ShopTP"), SendClientMessage(playerid, COLOR_GRAD2, "SERVER: Da huy dich chuyen den shop.");
	if(gettime() - LastShot[playerid] < 30) {
		TogglePlayerControllable(playerid, true);
		DeletePVar(playerid, "ShopTP");
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban bi thuong trong 30 giay qua, khong the dich chuyen den shop.");
	}
	if(GetPVarInt(playerid, "ShopTP") == 1)
	{
		SetPlayerPos(playerid, 2957.9670, -1459.4045, 10.8092);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 1);
		TogglePlayerControllable(playerid, true);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Dung /leaveshop de roi shop va quay ve vi tri cu.");
		SendClientMessageEx(playerid, COLOR_ORANGE, "Chu y{ffffff}: Ban se {ff0000}khong{ffffff} the ve vi tri cu sau khi mua xe.");
	}
	return 1;
}

CMD:shopplate(playerid, params[])
{
    if(PlayerInfo[playerid][pShopTech] >= 1 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new iVehType, iVehIndex, iTargetOwner, carid, orderid, plate[32];
        if(sscanf(params, "dds[32]", carid, orderid, plate))
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopplate [carid] [orderid] [plate/remove]");
		    SendClientMessageEx(playerid, COLOR_GREY, "MAU: (black/white/blue/red/green/purple/yellow/lightblue/navy/beige/darkgreen/darkblue/darkgrey/gold/brown/darkbrown/darkred");
			SendClientMessageEx(playerid, COLOR_GREY, "/pink) CACH DUNG: (red)Chao(white)ban! CHU Y: Moi mau chiem 8 ky tu");
			return 1;
		}

		foreach(new i: Player)
		{
			iVehIndex = GetPlayerVehicle(i, carid);
			if(iVehIndex != -1)
			{
				iVehType = 1;
				iTargetOwner = i;
				break;
			}
		}	
		if(iVehType == 1)
		{
		    format(plate, sizeof(plate), "%s", str_replace("(black)", "{000000}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(white)", "{FFFFFF}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(blue)", "{0000FF}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(red)", "{FF0000}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(green)", "{008000}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(purple)", "{800080}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(yellow)", "{FFFF00}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(lightblue)", "{ADD8E6}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(navy)", "{000080}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(beige)", "{F5F5DC}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(darkgreen)", "{006400}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(darkblue)", "{00008B}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(darkgrey)", "{A9A9A9}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(gold)", "{FFD700}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(brown)", "{A52A2A}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(darkbrown)", "{5C4033}", plate));
		    format(plate, sizeof(plate), "%s", str_replace("(darkred)", "{8B0000}", plate));
			format(plate, sizeof(plate), "%s", str_replace("(pink)", "{FF5B77}", plate));

			new string[128], Float:X, Float:Y, Float:Z;
			GetVehiclePos(carid, X, Y, Z);
			if(strcmp(plate, "remove", true) == 0)
			{
				PlayerVehicleInfo[iTargetOwner][iVehIndex][pvPlate] = 0;
			}
			else
			{
				format(PlayerVehicleInfo[iTargetOwner][iVehIndex][pvPlate], 32, "%s", plate);
			}
			SetVehicleToRespawn(carid);
			SetVehiclePos(carid, X, Y, Z);
			g_mysql_SaveVehicle(iTargetOwner, iVehIndex);

			format(string, sizeof(string), "Da dat bien cho %s (ID: %d) %s (ID: %d)", GetPlayerNameEx(iTargetOwner), iTargetOwner, GetVehicleName(carid), carid);
			SendClientMessage(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "(OrderID: %d) Bien so: %s", orderid, plate);
			SendClientMessage(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "%s set %s(%d) %s (Slot %d) plate to %s (order %d)", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetOwner), GetPlayerSQLId(iTargetOwner), GetVehicleName(carid), iVehIndex, plate, orderid);
			Log("logs/shoplog.log", string);
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GRAD1, "Day khong phai xe ca nhan, khong the cap bien so rieng.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:shopcredits(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pShopTech] >= 2)
	{
		new szMessage[128], player, amount, invid;

		if(sscanf(params, "udd", player, amount, invid))
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givecredits [player] [amount] [invoiceid]");

		if(!IsPlayerConnected(player))
		    return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

		if(!(1 < amount < 2401)) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc cap tu 1 den 2400 credits!");
		if(PlayerInfo[player][pAdmin] > 2) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc cap Credits cho tai khoan roleplay!");

		if(amount > 999)
		{
			format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s cap %s %s credits. (Invoice ID: %d)", GetPlayerNameEx(playerid), GetPlayerNameEx(player), invid);
			ABroadCast(COLOR_YELLOW, szMessage, 2);
		}

		PlayerInfo[player][pCredits] += amount;

		mysql_format(MainPipeline, szMessage, sizeof(szMessage), "UPDATE `accounts` SET `Credits` = %d WHERE `id` = %d", PlayerInfo[player][pCredits], GetPlayerSQLId(player));
		mysql_tquery(MainPipeline, szMessage, "OnQueryFinish", "ii", SENDDATA_THREAD, player);
		print(szMessage);

        SendClientMessageEx(player, COLOR_LIGHTBLUE, "* %s cap cho ban %s credits (Tong moi: %s)", GetPlayerNameEx(playerid), number_format(amount), number_format(PlayerInfo[player][pCredits]));

		format(szMessage, sizeof(szMessage), "%s has given %s %s credits. [TC: %s] (Invoice ID: %d)", GetPlayerNameEx(playerid), GetPlayerNameEx(player), number_format(amount), number_format(PlayerInfo[player][pCredits]), invid);
		Log("logs/shoplog.log", szMessage), print(szMessage);

		SendClientMessageEx(playerid, COLOR_CYAN, "Da cap cho %s %s credits. (Invoice ID: %d)", GetPlayerNameEx(player), number_format(amount), invid);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay."); 
	return 1;
}

CMD:shopcar(playerid, params[]) {
	if(PlayerInfo[playerid][pShopTech] >= 1) {

		new
			szInvoice[32],
			iColors[2],
			iTargetID,
			iModelID;

		if(sscanf(params, "uiiis[32]", iTargetID, iModelID, iColors[0], iColors[1], szInvoice)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopcar [player] [model] [color 1] [color 2] [invoice #]");
		}
		else if(!(400 <= iModelID <= 611)) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Model khong hop le (ID tu 400 den 611).");
		}
		else if(IsATrain(iModelID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the tao tau khi may chu dang chay.");
		}
		else if(IsRestrictedVehicle(iModelID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the cap xe bi han che!");
		}
		else if(!(0 <= iColors[0] <= 255 && 0 <= iColors[1] <= 255)) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
		}
		else if(!vehicleCountCheck(iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da co qua nhieu xe, khong the nhan them.");
		}
		else if(!vehicleSpawnCountCheck(iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da tao qua nhieu xe, phai cat bot truoc.");
		}
		else {
			new vehicleName[18];

			new
				Float: arr_fPlayerPos[4],
				szMessage[84];

			GetPlayerPos(iTargetID, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2]);
			GetPlayerFacingAngle(iTargetID, arr_fPlayerPos[3]);
			CreatePlayerVehicle(iTargetID, GetPlayerFreeVehicleId(iTargetID), iModelID, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2], arr_fPlayerPos[3], iColors[0], iColors[1], 2000000, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

			strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
			SendClientMessageEx(playerid, COLOR_WHITE, "Da tao %s cho %s (invoice %s).", vehicleName, GetPlayerNameEx(iTargetID), szInvoice);

			format(szMessage, sizeof(szMessage), "%s created a %s (%i) for %s(%d) (invoice %s).", GetPlayerNameEx(playerid), vehicleName, iModelID, GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), szInvoice);
			Log("logs/shoplog.log", szMessage);
		}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
    return 1;
}

CMD:shopcardel(playerid, params[])
{
	if(PlayerInfo[playerid][pShopTech] >= 1)
	{
		new string[128], invoicenum[32], giveplayerid, vehicleid;
		if(sscanf(params, "uds[32]", giveplayerid, vehicleid, invoicenum)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopcardel [player] [vehicleid] [invoice #]");

		new playervehicleid = GetPlayerVehicle(giveplayerid, vehicleid);
		if(playervehicleid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Nguoi do khong so huu xe nay.");

		SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa xe cua %s: %s (ID xe %d).", GetPlayerNameEx(giveplayerid), GetVehicleName(vehicleid), vehicleid);
		SendClientMessageEx(giveplayerid, COLOR_GREY, "Administrator da xoa %s cua ban.", GetVehicleName(vehicleid));
		format(string, sizeof(string), "[SHOPCARDEL] %s deleted vehicle ID %d - Invoice %s for %s(%d)", GetPlayerNameEx(playerid), playervehicleid, invoicenum, GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
		Log("logs/shoplog.log", string);
		DestroyPlayerVehicle(giveplayerid, playervehicleid);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc dung lenh nay.");
	return 1;
}

CMD:setstpay(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] == 99999)
	{
	    new string[128];
		if(sscanf(params, "f", ShopTechPay))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Cach dung: /setstpay [value]");
			SendClientMessageEx(playerid, COLOR_WHITE, "Luong hien tai: $%.2f", ShopTechPay);
			return 1;
		}
		mysql_format(MainPipeline, string, sizeof(string), "UPDATE `misc` SET `ShopTechPay` = '%.2f'", ShopTechPay);
		mysql_tquery(MainPipeline, string, "OnQueryFinish", "i", SENDDATA_THREAD);

        SendClientMessageEx(playerid, COLOR_WHITE, "Da dat luong Shop Tech thanh $%.2f", ShopTechPay);
	}
	return 1;
}

CMD:resetstpay(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] == 99999)
	{
	    if(GetPVarInt(playerid, "resetstpay"))
	    {
	        mysql_tquery(MainPipeline, "UPDATE `shoptech` SET `total` = 0, dtotal = 0", "OnQueryFinish", "i", SENDDATA_THREAD);
            SendClientMessage(playerid, COLOR_WHITE, "Da dat lai thanh toan Shop Tech");
	        DeletePVar(playerid, "resetstpay");
		}
		else
		{
		    SendClientMessage(playerid, COLOR_WHITE, "CANH BAO: Lenh nay dat lai bo dem thanh toan Shop Tech");
		    SendClientMessage(playerid, COLOR_WHITE, "Khong the hoan tac, BAN CHAC MUON TIEP TUC?");
		    SendClientMessage(playerid, COLOR_WHITE, "Nhap lai lenh nay de tiep tuc");
		    SetPVarInt(playerid, "resetstpay", 1);
		}
	}
	return 1;
}

CMD:changeuserpin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337 && PlayerInfo[playerid][pShopTech] < 2)
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	new name[MAX_PLAYER_NAME], pin[64];
	if(sscanf(params, "s[24]s[64]", name, pin)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /changeuserpin [player name] [new pin]");
	if(isnull(pin) || strlen(pin) > 4 || !IsNumericString(pin)) return SendClientMessageEx(playerid, COLOR_GREY, "PIN phai la so va co 4 chu so.");
	new request = Password_Begin(playerid);
	if(!request) return 0;
	SetPVarString(playerid, "OnChangeUserPassword", name);
	if(!bcrypt_hash(playerid, "OnAdminCredentialHashed", pin, BCRYPT_COST, "iiii", g_arrQueryHandle[playerid], request, GetPlayerSQLId(playerid), 1)) {
		gPasswordPending[playerid] = false;
		return SendClientMessageEx(playerid, COLOR_RED, "Khong the dat lai PIN cua ban."), 0;
	}
	return SendClientMessageEx(playerid, COLOR_YELLOW, "Dang dat lai PIN...");
}

CMD:changeuserpassword(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	new name[MAX_PLAYER_NAME], password[65];
	if(sscanf(params, "s[24]s[65]", name, password)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /changeuserpassword [player name] [new password]");
	new request = Password_Begin(playerid);
	if(!request) return 0;
	SetPVarString(playerid, "OnChangeUserPassword", name);
	if(!bcrypt_hash(playerid, "OnAdminCredentialHashed", password, BCRYPT_COST, "iiii", g_arrQueryHandle[playerid], request, GetPlayerSQLId(playerid), 0)) {
		gPasswordPending[playerid] = false;
		return SendClientMessageEx(playerid, COLOR_RED, "Khong the dat lai mat khau cua ban."), 0;
	}
	return SendClientMessageEx(playerid, COLOR_YELLOW, "Dang dat lai mat khau...");
}

CMD:orders(playerid, params[])
{
	if(PlayerInfo[playerid][pShopTech] > 0 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
 		new string[128];
        SendClientMessageEx(playerid, COLOR_GREEN, "____________________ DON HANG SHOP _____________________");
		foreach(new i: Player)
		{
			if(PlayerInfo[i][pOrder] > 0 && OrderAssignedTo[i] == INVALID_PLAYER_ID)
			{
				new playerip[32];
				GetPlayerIp(i, playerip, sizeof(playerip));

				new orderid = PlayerInfo[i][pOrder];

				if(PlayerInfo[i][pOrderConfirmed]) {
					format(string, sizeof(string), "%s(%d) | Order ID: %d (Hop le) | IP: %s | Giao: Chua co", GetPlayerNameEx(i), i, orderid, playerip);
				} else {
					format(string, sizeof(string), "%s(%d) | Order ID: %d (Loi) | IP: %s | Giao: Chua co", GetPlayerNameEx(i), i, orderid, playerip);
				}
				SendClientMessageEx(playerid, COLOR_SHOP, string);
			}
			else if(PlayerInfo[i][pOrder] > 0 && OrderAssignedTo[i] != INVALID_PLAYER_ID)
			{
				new playerip[32];
				GetPlayerIp(i, playerip, sizeof(playerip));

				new orderid = PlayerInfo[i][pOrder];

				if(PlayerInfo[i][pOrderConfirmed]) {
					format(string, sizeof(string), "%s(%d) | Order ID: %d (Da xac nhan) | IP: %s | Phan cong: %s", GetPlayerNameEx(i), i, orderid, playerip, GetPlayerNameEx(OrderAssignedTo[i]));
				} else {
					format(string, sizeof(string), "%s(%d) | Order ID: %d (Loi) | IP: %s | Giao: %s", GetPlayerNameEx(i), i, orderid, playerip, GetPlayerNameEx(OrderAssignedTo[i]));
				}
				SendClientMessageEx(playerid, COLOR_SHOP, string);
			}
		}	
  		SendClientMessageEx(playerid, COLOR_WHITE, "Dung /givemeorder /processorder /denyorder");
        SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________________");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:givemeorder(playerid, params[])
{
	if(PlayerInfo[playerid][pShopTech] > 0 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givemeorder [player]");
			return 1;
		}

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pOrder] > 0)
			{
			    if(IsPlayerConnected(OrderAssignedTo[giveplayerid]))
			    {
			        if(GetPVarInt(playerid, "OrderAssignedTo") == giveplayerid)
			        {
			            DeletePVar(playerid, "OrderAssignedTo");
			        }
			        else
			        {
					    SendClientMessageEx(playerid, COLOR_WHITE, "Don do da duoc phan cho admin khac!");
					    SendClientMessageEx(playerid, COLOR_WHITE, "Neu van muon nhan don, hay nhap lai lenh nay.");
					    SetPVarInt(playerid, "OrderAssignedTo", giveplayerid);
				        return 1;
					}
			    }
		    	new string[128];
		    	new orderid = PlayerInfo[giveplayerid][pOrder];
				format(string, sizeof(string), "AdmCmd: %s tu nhan don shop ID %d cua %s (ID: %d).", GetPlayerNameEx(playerid), orderid, GetPlayerNameEx(giveplayerid), giveplayerid);
				ShopTechBroadCast(COLOR_ORANGE, string);

				SendClientMessageEx(giveplayerid, COLOR_WHITE, "%s dang xem xet don shop ID %d cua ban.", GetPlayerNameEx(playerid), orderid);

				OrderAssignedTo[giveplayerid] = playerid;
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co don shop cho xu ly!");
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

/*CMD:adjustoid(playerid, params[])
{
	if(PlayerInfo[playerid][pShopTech] > 0 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
	    new giveplayerid, orderid, string[128];
		if(sscanf(params, "ui", giveplayerid, orderid)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /adjustoid [player] [new orderid]");
		SendClientMessageEx(playerid, COLOR_WHITE, "Processing..");
  		PlayerInfo[giveplayerid][pOrder] = orderid;
		format(string, sizeof(string), "shop.ng-gaming.net/idcheck.php?id=%d", orderid);
		HTTP(giveplayerid, HTTP_GET, string, "", "HttpCallback_ShopIDCheck");
		format(string, sizeof(string), "%s has edited %s's Order ID to %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), orderid);
		Log("logs/shoporders.log", string);
	}
	return 1;
}*/

CMD:processorder(playerid, params[])
{
	if(PlayerInfo[playerid][pShopTech] > 0 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /processorder [player]");
			return 1;
		}

		if(IsPlayerConnected(giveplayerid))
		{
			if(OrderAssignedTo[giveplayerid] != playerid)
		    {
		        SendClientMessageEx(playerid, COLOR_WHITE, "Phai duoc phan don de xu ly, dung /givemeorder");
		        return 1;
		    }
			if(PlayerInfo[giveplayerid][pOrder] > 0)
			{
		    	new string[128];
		    	new orderid = PlayerInfo[giveplayerid][pOrder];
				format(string, sizeof(string), "AdmCmd: %s da xu ly don shop ID %d cua %s (ID: %d).", GetPlayerNameEx(playerid), orderid, GetPlayerNameEx(giveplayerid), giveplayerid);
				ShopTechBroadCast(COLOR_ORANGE, string);

				format(string, sizeof(string), "%s da xu ly don shop ID %d cua ban.", GetPlayerNameEx(playerid), orderid);
				SendClientMessageEx(giveplayerid, COLOR_WHITE, string);

				new playerip[32], giveplayerip[32];
				GetPlayerIp(playerid, playerip, sizeof(playerip));
				GetPlayerIp(giveplayerid, giveplayerip, sizeof(giveplayerip));

				if(PlayerInfo[giveplayerid][pOrderConfirmed])
				{
				    mysql_format(MainPipeline, string, sizeof(string), "SELECT `id` FROM `orders` WHERE `id` = '%d'", PlayerInfo[giveplayerid][pOrder]);
					mysql_tquery(MainPipeline, string, "OnProcessOrderCheck", "ii", playerid, giveplayerid);
					SetPVarInt(playerid, "processorder", orderid);
				}
				else
				{
					format(string, sizeof(string), "%s(IP: %s) has processed shop order ID %d from %s(%d) (IP: %s).", GetPlayerNameEx(playerid), playerip, orderid, GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), giveplayerip);
					Log("logs/shoporders.log", string);
				}

				PlayerInfo[giveplayerid][pOrder] = 0;
				PlayerInfo[giveplayerid][pOrderConfirmed] = 0;
				OrderAssignedTo[giveplayerid] = INVALID_PLAYER_ID;
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co don shop cho xu ly!");
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:denyorder(playerid, params[])
{
	if(PlayerInfo[playerid][pShopTech] > 0 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /denyorder [player] [reason]");
			return 1;
		}

		if(IsPlayerConnected(giveplayerid))
		{
			if(OrderAssignedTo[giveplayerid] != playerid)
		    {
		        SendClientMessageEx(playerid, COLOR_WHITE, "Phai duoc phan don de tu choi, dung /givemeorder");
		        return 1;
		    }
			if(PlayerInfo[giveplayerid][pOrder] > 0)
			{
		    	new string[128];
		    	new orderid = PlayerInfo[giveplayerid][pOrder];
				format(string, sizeof(string), "AdmCmd: %s da tu choi don shop ID %d cua %s (ID: %d), ly do: %s", GetPlayerNameEx(playerid), orderid, GetPlayerNameEx(giveplayerid), giveplayerid, reason);
				ShopTechBroadCast(COLOR_ORANGE, string);

				SendClientMessageEx(giveplayerid, COLOR_WHITE, "%s da tu choi don shop ID %d cua ban, ly do: %s", GetPlayerNameEx(playerid), orderid, reason);

				new playerip[32], giveplayerip[32];
				GetPlayerIp(playerid, playerip, sizeof(playerip));
				GetPlayerIp(giveplayerid, giveplayerip, sizeof(giveplayerip));

				format(string, sizeof(string), "%s(IP: %s) has denied shop order ID %d from %s(%d) (IP: %s), reason: %s", GetPlayerNameEx(playerid), playerip, orderid, GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), giveplayerip, reason);
				Log("logs/shoporders.log", string);

				PlayerInfo[giveplayerid][pOrder] = 0;
				OrderAssignedTo[giveplayerid] = INVALID_PLAYER_ID;
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co don shop cho xu ly!");
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:shoporder(playerid, params[])
{
	if(PlayerInfo[playerid][pOrder] != 0)
	{
	    new orderid = PlayerInfo[playerid][pOrder];
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang cho don shop ID %d, dung /cancelorder neu muon huy", orderid);
	    return 1;
	}
	if (GetPVarInt(playerid, "ShopOrderTimer") > 0)
	{
		SendClientMessageEx(playerid,COLOR_GREY, "Hay cho %d giay de gui don shop tiep.", GetPVarInt(playerid, "ShopOrderTimer"));
		return 1;
	}
	ShowPlayerDialogEx(playerid, DIALOG_SHOPORDER, DIALOG_STYLE_INPUT, "Don hang cua hang", "Danh cho don hang tu http://shop.ng-gaming.net\n\nNeu khong co don hang, hay huy hop thoai nay.\n\nCanh bao: Lam dung co the bi cam dung lenh vo thoi han.\n\nNhap ID don shop (neu khong biet, nhap 1):", "Gui", "Huy" );
	return 1;
}

CMD:cancelorder(playerid, params[])
{
	if(PlayerInfo[playerid][pOrder] != 0)
	{
	    new string[128];
	    new orderid = PlayerInfo[playerid][pOrder];
		new playerip[32];
		GetPlayerIp(playerid, playerip, sizeof(playerip));
		format(string, sizeof(string), "%s(%d) (IP: %s) canceled their shop order (ID %i).", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerip, orderid);
		Log("logs/shoporders.log", string);

		SendClientMessageEx(playerid, COLOR_WHITE, "Da huy don shop (ID %i). Dung /shoporder de gui don moi.", orderid);
		PlayerInfo[playerid][pOrder] = 0;
		OrderAssignedTo[playerid] = INVALID_PLAYER_ID;
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co don shop cho xu ly!");
	}
	return 1;
}

CMD:useexp(playerid, params[])
{
    if (PlayerInfo[playerid][pEXPToken] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co Double EXP tokens!");
		return 1;
	}
    PlayerInfo[playerid][pDoubleEXP] += 8;
    PlayerInfo[playerid][pEXPToken]--;
	SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da dung Double EXP Token! Hien co tong %d gio Double EXP!", PlayerInfo[playerid][pDoubleEXP]);
    return 1;
}

CMD:shopexp(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new string[128], giveplayerid, amount, invoice[32];
	if(sscanf(params, "uds[32]", giveplayerid, amount, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopexp [player] [tokens] [invoice #]");

	PlayerInfo[giveplayerid][pEXPToken] += amount;

	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban nhan %d Double EXP Token(s) tu Shop Tech %s.", amount, GetPlayerNameEx(playerid));
	format(string, sizeof(string), "[SHOPEXP] %s given %s(%d), %d Double EXP Token(s) - Invoice %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount, invoice);
	SendClientMessageEx(playerid, COLOR_GRAD1, string);
	Log("logs/shoplog.log", string);
	return 1;
}

CMD:shoptokens(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new string[128], giveplayerid, amount, invoice[32];
	if(sscanf(params, "uds[32]", giveplayerid, amount, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shoptokens [player] [amount] [invoice #]");

	PlayerInfo[giveplayerid][pPaintTokens] += amount;

	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban nhan %d Paintball Tokens tu Shop Tech %s.", amount, GetPlayerNameEx(playerid));
	format(string, sizeof(string), "[SHOPTOKENS] %s given %s(%d), %d Paintball Tokens - Invoice %s for %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount, invoice, GetPlayerNameEx(giveplayerid));
	SendClientMessageEx(playerid, COLOR_GRAD1, string);
	Log("logs/shoplog.log", string);
	return 1;
}

CMD:shopviptokens(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new string[128], giveplayerid, amount, invoice[32];
	if(sscanf(params, "uds[32]", giveplayerid, amount, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopviptokens [player] [amount] [invoice #]");

	PlayerInfo[giveplayerid][pTokens] += amount;

	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban nhan %d VIP Tokens tu Shop Tech %s.", amount, GetPlayerNameEx(playerid));
	format(string, sizeof(string), "[SHOPTOKENS] %s given %s(%d), %d VIP Tokens - Invoice %s for %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount, invoice, GetPlayerNameEx(giveplayerid));
	SendClientMessageEx(playerid, COLOR_GRAD1, string);
	Log("logs/shoplog.log", string);
	return 1;
}

CMD:shopfirework(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new string[128], giveplayerid, amount, invoice[32];
	if(sscanf(params, "uds[32]", giveplayerid, amount, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopfirework [player] [amount] [invoice #]");

	PlayerInfo[giveplayerid][pFirework] += amount;

	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban nhan %d Fireworks tu Shop Tech %s. ", amount, GetPlayerNameEx(playerid));
	format(string, sizeof(string), "[SHOPFIREWORK] %s given %s(%d) %d Firework(s) - Invoice %s for %s. ", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount, invoice, GetPlayerNameEx(giveplayerid));
	SendClientMessageEx(playerid, COLOR_GRAD1, string);
	Log("logs/shoplog.log", string);
	return 1;
}

CMD:miscshop(playerid, params[])
{
    if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if (IsAt247(playerid) || IsPlayerInRangeOfPoint(playerid, 4.0, 2939.8442, -1411.2906, 11.0000) && GetPlayerVirtualWorld(playerid) == 1)
	{
 		if(GetPVarInt(playerid, "PinConfirmed"))
   		{
			new szDialog[1024];
			format(szDialog, sizeof(szDialog), "Poker Table (Credits: {FFD700}%s{A9C4E4})\nBoombox (Credits: {FFD700}%s{A9C4E4})\n100 Paintball Tokens (Credits: {FFD700}%s{A9C4E4})\nEXP Token (Credits: {FFD700}%s{A9C4E4})\nFireworks x5 (Credits: {FFD700}%s{A9C4E4})\nCustom License Plate (Credits: {FFD700}%s{A9C4E4})",
			number_format(ShopItems[6][sItemPrice]), number_format(ShopItems[7][sItemPrice]), number_format(ShopItems[8][sItemPrice]), number_format(ShopItems[9][sItemPrice]), 
			number_format(ShopItems[10][sItemPrice]), number_format(ShopItems[22][sItemPrice]));
			format(szDialog, sizeof(szDialog), "%s\nRestricted Last Name (MOI) (Credits: {FFD700}%s{A9C4E4})\nRestricted Last Name (DOI) (Credits: {FFD700}%s{A9C4E4})\nCustom User Title (MOI) (Credits: {FFD700}%s{A9C4E4})\nCustom User Title (DOI) (Credits: {FFD700}%s{A9C4E4})\nTeamspeak User Channel (Credits: {FFD700}%s{A9C4E4})\nBackpacks\nDeluxe Car Alarm (Credits: {FFD700}%s{A9C4E4})", 
			szDialog, number_format(ShopItems[31][sItemPrice]), number_format(ShopItems[32][sItemPrice]), number_format(ShopItems[33][sItemPrice]), number_format(ShopItems[34][sItemPrice]), number_format(ShopItems[35][sItemPrice]), number_format(ShopItems[39][sItemPrice]));
			ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP, DIALOG_STYLE_LIST, "Misc Shop", szDialog, "Chon", "Huy");
		}
		else
		{
		    SetPVarInt(playerid, "OpenShop", 1);
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai 24/7.");
	}
	return 1;
}

CMD:credits(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
	{
		SendClientMessageEx(playerid, COLOR_CYAN, "Credits: {FFD700}%s", number_format(PlayerInfo[playerid][pCredits]));
	}
	else
	{
	    new Player;
	    if(sscanf(params, "u", Player))
			return SendClientMessageEx(playerid, COLOR_GREY, "Cach dung: /credits [Player]");


		SendClientMessageEx(playerid, COLOR_CYAN, "%s - Credits: {FFD700}%s",GetPlayerNameEx(Player), number_format(PlayerInfo[Player][pCredits]));
	}
	return 1;
}

CMD:shopstats(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1338 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

	mysql_tquery(MainPipeline, "SELECT `id`, `Month` FROM `sales`", "CheckSales", "i", playerid);
	return 1;
}
 
CMD:shophelp(playerid, params[]) {
    return ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU, DIALOG_STYLE_LIST, "Ban muon tim hieu shop nao?","VIP Shop\nHouse Shop\nBusiness Shop\nToy Shop\nMiscellaneous Shop\nCar Shop\nPlane Shop\nBoat Shop", "Chon", "Thoat");
}

CMD:nggshop(playerid, params[]) {
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] || PlayerInfo[playerid][pJailTime] > 0 || GetPVarInt(playerid, "EventToken") == 1 || GetPVarInt(playerid, "IsInArena"))
		return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam vay!");
	if(PlayerInfo[playerid][pWantedLevel] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang bi truy na, khong the dung lenh nay.");
	if(gettime() - LastShot[playerid] < 60) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban bi ban trong 60 giay qua, khong the dung lenh nay.");
	if(IsPlayerInDynamicArea(playerid, NGGShop)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da o NGG's Shop");
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the lam vay khi dang trong xe.");
	if(GetPVarInt(playerid, "ShopTP") == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da yeu cau dich chuyen den NGG Shop.");
	
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da yeu cau dich chuyen den NGG Shop, hay cho 30 giay..");
	SetTimerEx("TeleportToShop", 30000, false, "i", playerid);
	TogglePlayerControllable(playerid, false);
	SetPVarInt(playerid, "ShopTP", 1);
	
	new Float:tmp[3];
	GetPlayerPos(playerid, tmp[0], tmp[1], tmp[2]);
	SetPVarFloat(playerid, "tmpX", tmp[0]);
	SetPVarFloat(playerid, "tmpY", tmp[1]);
	SetPVarFloat(playerid, "tmpZ", tmp[2]);
	SetPVarInt(playerid, "tmpInt", GetPlayerInterior(playerid));
	SetPVarInt(playerid, "tmpVW", GetPlayerVirtualWorld(playerid));
	return 1;
}

CMD:leaveshop(playerid, params[]) {
	if(GetPVarInt(playerid, "ShopTP") == 1)
	{
		DeletePVar(playerid, "ShopTP");
		if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] || PlayerInfo[playerid][pJailTime] > 0 || IsPlayerInAnyVehicle(playerid))
			return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam vay!.");
		if(gettime() - LastShot[playerid] < 60) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban bi thuong trong 60 giay qua, khong the quay ve vi tri cu.");
		Player_StreamPrep(playerid, GetPVarFloat(playerid, "tmpX"), GetPVarFloat(playerid, "tmpY"), GetPVarFloat(playerid, "tmpZ"), 2500);
		PlayerInfo[playerid][pVW] = GetPVarInt(playerid, "tmpVW");
		SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pVW]);
		PlayerInfo[playerid][pInt] = GetPVarInt(playerid, "tmpInt");
		SetPlayerInterior(playerid, PlayerInfo[playerid][pInt]);
	}
	return 1;
}

CMD:buygiftreset(playerid, params[]) {
	if(IsPlayerInRangeOfPoint(playerid, 4.0, 2937.2878, -1357.2294, 10.8503))
	{
		new string[128];
		format(string, sizeof(string),"Vat pham: Reset Gift Timer\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[17][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[17][sItemPrice]));
		return ShowPlayerDialogEx( playerid, DIALOG_SHOPGIFTRESET, DIALOG_STYLE_MSGBOX, "Dat lai thoi gian qua", string, "Mua", "Thoat" );
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o diem mua dat lai thoi gian qua.");
}

CMD:buyhealthcare(playerid, params[]) {
	if(IsPlayerInRangeOfPoint(playerid, 4.0, 2946.8672, -1484.9561, 11.0000))
	{
		return ShowPlayerDialogEx(playerid, DIALOG_HEALTHCARE, DIALOG_STYLE_LIST, "Mua Health Care", "Advanced Health Care\nSuper Advanced Health Care", "Chon", "Thoat");
	}
	return 1;
}

CMD:togshopnotices(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		if(ShopReminder == 0)
		{
			ShopReminder = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da bat thong bao Shop.");
		}
		else
		{
			ShopReminder = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tat thong bao Shop.");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:stoprentacar(playerid, params[])
{
    if(GetPVarType(playerid, "RentedVehicle"))
	{
	    new string[128];
        SendClientMessageEx(playerid, COLOR_CYAN, "Ban da dung thue xe.");
		DestroyVehicle(GetPVarInt(playerid, "RentedVehicle"));

		mysql_format(MainPipeline, string, sizeof(string), "DELETE FROM `rentedcars` WHERE `sqlid`= '%d'", GetPlayerSQLId(playerid));
		mysql_tquery(MainPipeline, string, "OnQueryFinish", "i", SENDDATA_THREAD);

		DeletePVar(playerid, "RentedHours");
		DeletePVar(playerid, "RentedVehicle");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban hien khong thue xe.");
	return 1;
}

CMD:rentacar(playerid, params[])
{
    if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

    if(IsPlayerInRangeOfPoint(playerid, 4, 1102.8999, -1440.1669, 15.7969) || IsPlayerInRangeOfPoint(playerid, 4, 1796.0620, -1588.5571, 13.4951))
	{
		if(GetPVarInt(playerid, "PinConfirmed"))
		{
		    if(!GetPVarType(playerid, "RentedVehicle"))
			{
		    	SetPVarInt(playerid, "RentaCar", 1);
				ShowModelSelectionMenu(playerid, CarList2, "Thue xe!");
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Ban dang thue mot xe.");
		}
		else
		{
		    SetPVarInt(playerid, "OpenShop", 2);
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o diem thue xe.");
	}
	return 1;
}

CMD:boatshop(playerid, params[])
{
    if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if(IsPlayerInRangeOfPoint(playerid, 4, -2214.1636, 2422.4763, 2.4961) || IsPlayerInRangeOfPoint(playerid, 4,-2975.8950, 505.1325, 2.4297) || IsPlayerInRangeOfPoint(playerid, 4, 723.1553, -1494.4547, 1.9343) || IsPlayerInRangeOfPoint(playerid, 4, 2974.7520, -1462.9265, 2.8184))
	{
		if(GetPVarInt(playerid, "PinConfirmed"))
		{
			ShowModelSelectionMenu(playerid, BoatList, "Boat Shop");
		}
		else
		{
		    SetPVarInt(playerid, "OpenShop", 8);
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai Boat Shop.");
	}
	return 1;
}

CMD:planeshop(playerid, params[])
{
    if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if(IsPlayerInRangeOfPoint(playerid, 5, 1891.9105, -2279.6174, 13.5469) || IsPlayerInRangeOfPoint(playerid, 5, 1632.0836, 1551.7365, 10.8061) || IsPlayerInRangeOfPoint(playerid, 5, 2950.4014,-1283.0776,4.6875))
	{
		if(GetPVarInt(playerid, "PinConfirmed"))
		{
			ShowModelSelectionMenu(playerid, PlaneList, "Plane Shop");
		}
		else
		{
		    SetPVarInt(playerid, "OpenShop", 7);
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai Plane Shop.");
	}
	return 1;
}

CMD:carshop(playerid, params[])
{
    if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if(IsPlayerInRangeOfPoint(playerid, 4, 2280.5720, -2325.2490, 13.5469) || IsPlayerInRangeOfPoint(playerid, 4,-1731.1923, 127.4794, 3.2976) || IsPlayerInRangeOfPoint(playerid, 4, 1663.9569, 1628.5106, 10.8203) ||
	IsPlayerInRangeOfPoint(playerid, 4, 2958.2200, -1339.2900, 5.2100))
	{
		if(GetPVarInt(playerid, "PinConfirmed"))
		{
			ShowModelSelectionMenu(playerid, CarList2, "Car Shop");
		}
		else
		{
		    SetPVarInt(playerid, "OpenShop", 3);
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai Car Shop.");
	}
	return 1;
}

CMD:changepin(playerid, params[])
{
    if(GetPVarInt(playerid, "PinConfirmed"))
	{
	    SetPVarInt(playerid, "ChangePin", 1);
	    ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN, DIALOG_STYLE_INPUT, "Doi ma PIN", "Nhap PIN moi de thay PIN hien tai.", "Doi", "Huy");
	}
	else
	{
	    PinLogin(playerid);
	}
	return 1;
}

CMD:houseshop(playerid, params[])
{
	if(ShopClosed == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");
	if(IsPlayerInRangeOfPoint(playerid, 4.0, 2938.2734, -1391.0596, 11.0000) && GetPlayerVirtualWorld(playerid) == 1)
	{
		if(GetPVarInt(playerid, "PinConfirmed"))
		{
			ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP, DIALOG_STYLE_LIST, "House Shop", "Mua nha\nDoi noi that nha\nChuyen nha\nGarage - Small\nGarage - Medium\nGarage - Large\nGarage - Extra Large","Chon", "Thoat" );
		}
		else
		{
			SetPVarInt(playerid, "OpenShop", 4);
			PinLogin(playerid);
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai House Shop.");
	return 1;
}

CMD:sellcredits(playerid, params[])
{
	if(restarting) return SendClientMessageEx(playerid, COLOR_GRAD2, "Giao dich da tam dung de khoi dong lai may chu bao tri.");
	new
		Player,
		Credits,
		Amount;

	if(SellClosed == 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "Hien da tat ban credits.");

	if(PlayerInfo[playerid][pDonateRank] < 2 && !nonvipcredits)
		return SendClientMessageEx(playerid, COLOR_GREY, "Can SVIP+ de bat dau giao dich!");

	if(sscanf(params, "udd", Player, Credits, Amount))
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sellcredits [Player] [Credits] [Amount]");

	else if(!IsPlayerConnected(Player))
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

	else if(Credits < 0 || Amount < 0)
		return SendClientMessageEx(playerid, COLOR_GREY, "So luong/Gia khong duoc duoi zero.");

	else if(Player == playerid)
		return SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu ban credits cho minh.");

	else if(Credits > PlayerInfo[playerid][pCredits])
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co du credits.");

	else if(Credits < 51)
		return SendClientMessageEx(playerid, COLOR_GREY, "Phai giao dich it nhat 51 credits.");

	else if (!ProxDetectorS(10.0, playerid, Player))
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");

	else if(GetPVarType(Player, "CreditsAmount"))
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da nhan de nghi khac.");

	else if(!GetPVarInt(playerid, "PinConfirmed"))
		PinLogin(playerid);

	else
	{
		new szMessage[200], CreditsTaxed;
		new year, month, day;
		new TransactionFee;
		
		getdate(year, month, day);
		SetPVarInt(Player, "CreditsFirstAmount", Credits);
		
		if(!freeweekend)
		{
			switch(PlayerInfo[playerid][pDonateRank]) {
				case 0 .. 2: {
					CreditsTaxed = 2*Credits/100;
					Credits = Credits-10;
					Credits = Credits-CreditsTaxed;
					TransactionFee = (10+CreditsTaxed);
				}
				case 3: {
					CreditsTaxed = 2*Credits/100;
					Credits = Credits-5;
					Credits = Credits-CreditsTaxed;
					TransactionFee = (5+CreditsTaxed);
				}
				case 4 .. 5: {
					Credits = Credits-5;
					TransactionFee = 5;
				}
			}
		}
		
		SetPVarInt(Player, "CreditsOffer", Amount);
		SetPVarInt(Player, "CreditsAmount", Credits);
		SetPVarInt(Player, "CreditsSeller", playerid);
		SetPVarInt(playerid, "CreditsSeller", Player);

		SendClientMessageEx(playerid, COLOR_WHITE, "Ban chao %s {FFD700}%s{FFFFFF} credits gia $%s. (Phi giao dich: %s)", GetPlayerNameEx(Player), number_format(Credits+TransactionFee), number_format(Amount), number_format(TransactionFee));

		format(szMessage, 200, "Nguoi ban: %s(%d)\nGia: $%s\nCredits: {FFD700}%s{A9C4E4}\nPhi giao dich: {FFD700}%s{A9C4E4}\nCredits se nhan: {FFD700}%s{A9C4E4}", GetPlayerNameEx(playerid), playerid, number_format(Amount), number_format(Credits+TransactionFee), number_format(TransactionFee), number_format(Credits));
		ShowPlayerDialogEx(Player, DIALOG_SELLCREDITS, DIALOG_STYLE_MSGBOX, "Mua Credits", szMessage, "Mua", "Tu choi");
	}
	return 1;
}

CMD:togglehealthcare(playerid, params[])
{
	if(PlayerInfo[playerid][pHealthCare] == 0)
	{
		ShowPlayerDialogEx(playerid, DIALOG_HEALTHCARE, DIALOG_STYLE_LIST, "Health Care", "Advanced Health Care\nSuper Advanced Health Care", "Chon", "Thoat");
	}
	else
	{
	    PlayerInfo[playerid][pHealthCare] = 0;
	    SendClientMessageEx(playerid, COLOR_CYAN, "Ban da tat Health Care.");
	}
	return 1;
}

CMD:vipshop(playerid, params[])
{
	if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if(IsPlayerInRangeOfPoint(playerid, 4, -2443.6013, 499.7480, 30.0906) || IsPlayerInRangeOfPoint(playerid, 4, 1934.1083, 1364.5004, 9.2578) || IsPlayerInRangeOfPoint(playerid, 4, 1811.3344, -1569.4244, 13.4811)
		|| IsPlayerInRangeOfPoint(playerid, 4, 2939.0134, -1401.2946, 11.0000))
	{
 		if(GetPVarInt(playerid, "PinConfirmed"))
   		{
			ShowPlayerDialogEx( playerid, DIALOG_VIPSHOP, DIALOG_STYLE_LIST, "VIP Shop", "Mua VIP\nGia han Gold VIP","Tiep tuc", "Thoat" );
		}
		else
		{
		    SetPVarInt(playerid, "OpenShop", 5);
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai VIP Shop.");
	}
	return 1;
}

CMD:reloadstats(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1338 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

    mysql_tquery(MainPipeline, "SELECT * FROM `sales` WHERE `Month` > NOW() - INTERVAL 1 MONTH", "OnQueryFinish", "iii", LOADSALEDATA_THREAD, INVALID_PLAYER_ID, -1);
    SendClientMessageEx(playerid, COLOR_WHITE, "Dang tai lai thong ke ban hang.");
	return 1;
}

CMD:closesellcredits(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1338 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

	if(SellClosed == 0)
	{
	    SellClosed = 1;
	    SendClientMessageEx(playerid, COLOR_WHITE, "Shop da dong cua.");
	}
	else
	{
	    SellClosed = 0;
	    SendClientMessageEx(playerid, COLOR_WHITE, "Shop da mo cua.");
	}
	return 1;
}

CMD:closeshop(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1338 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

	if(ShopClosed == 0)
	{
	    ShopClosed = 1;
	    SendClientMessageEx(playerid, COLOR_WHITE, "Shop da dong cua.");
	}
	else
	{
	    ShopClosed = 0;
	    SendClientMessageEx(playerid, COLOR_WHITE, "Shop da mo cua.");
	}
	g_mysql_SaveMOTD();
	return 1;
}

CMD:editshop(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1338 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

    if (isnull(params)) {
		SendClientMessageEx(playerid, COLOR_WHITE, "Cach dung: /editshop <code>");
		return 1;
	}

	if (strcmp(params, SecurityCode) == 0)
	{
		ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPMENU, DIALOG_STYLE_LIST, "Sua Shop", "Sua gia Shop\nSua Business Shop\nSua Micro Shop", "Chon", "Thoat");
	    if(GetPVarType(playerid, "CodeAttempts")) DeletePVar(playerid, "CodeAttempts");
	}
	else
	{
	    if(GetPVarInt(playerid, "CodeAttempts") != 3) {
	        SendClientMessageEx(playerid, COLOR_GREY, "Mat khau khong hop le.");
			SetPVarInt(playerid, "CodeAttempts", GetPVarInt(playerid, "CodeAttempts")+1);
	    }
	    else
	    {
	        new string[128];
	        format(string, sizeof(string), "AdmCmd: %s bi cam tu dong, ly do: Sai qua nhieu lan.", GetPlayerNameEx(playerid)), ABroadCast(COLOR_YELLOW,string,2);
			PlayerInfo[playerid][pBanned] = 1;
			SystemBan(playerid, "[System] (Sai qua nhieu lan)");
			Kick(playerid);
	    }
	}
	return 1;
}

CMD:businessshop(playerid, params[])
{
    if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if(GetPVarInt(playerid, "PinConfirmed"))
	{
		ShowPlayerDialogEx(playerid, DIALOG_SHOPBUSINESS, DIALOG_STYLE_LIST, "Businesses Shop", "Mua Business\nGia han Business", "Chon", "Thoat");
	}
	else
	{
	    SetPVarInt(playerid, "OpenShop", 6);
		PinLogin(playerid);
	}
	return 1;
}

CMD:toyshop(playerid, params[])
{
    if(ShopClosed == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if (IsAtClothingStore(playerid) || IsPlayerInRangeOfPoint(playerid, 4.0, 2927.5244, -1549.1826, 11.0469))
	{
 		if(GetPVarInt(playerid, "PinConfirmed"))
   		{
   			ShowModelSelectionMenu(playerid, ToyList2, "Toy Shop");
		}
		else
		{
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai cua hang quan ao.");
	}
	return 1;
}

CMD:thanksgivingshop(playerid, params[])
{
    if(HalloweenShop == 1)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Cua hang hien da dong.");

	if (IsAtClothingStore(playerid))
	{
 		if(GetPVarInt(playerid, "PinConfirmed"))
   		{
			new string[150];
			format(string, sizeof(string), "Straw Hat (Gia: 150 Credits | Ton: %d)\nCluckin Bell Hat (Gia: 150 Credits | Ton: %d)", PumpkinStock, PumpkinStock);//\nSpiked Club Toy (Cost: 60 Credits)", PumpkinStock);
			ShowPlayerDialogEx(playerid, DIALOG_HALLOWEENSHOP, DIALOG_STYLE_LIST, "Halloween Shop", string, "Chon", "Thoat");
			return 1;
		}
		else
		{
  			PinLogin(playerid);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o tai cua hang quan ao.");
	}
	return 1;
}

CMD:chargeplayer(playerid, params[])
{
	new string[128], giveplayerid, amount, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, amount, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /chargeplayer [player] [amount] [reason]");

	if (PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pShopTech] == 2)
	{
		if(IsPlayerConnected(giveplayerid))
		{
			if (amount < 1)
				return SendClientMessageEx(playerid, COLOR_GREY, "So luong phai lon hon 0");

			if(PlayerInfo[giveplayerid][pCredits] < amount)
			    return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co du credits.");

			SendClientMessageEx(playerid, COLOR_CYAN, "Ban de nghi thu cua %s so tien %s credits cho %s.",  GetPlayerNameEx(giveplayerid), number_format(amount), reason);

			SetPVarInt(giveplayerid, "FineAmount", amount), SetPVarInt(giveplayerid, "FineBy", playerid), SetPVarString(giveplayerid, "FineReason", reason);
			format(string, sizeof(string), "Admin: %s\nLy do: %s\nCredits hien co: %s\nTien phat: %s", GetPlayerNameEx(playerid), reason, number_format(PlayerInfo[giveplayerid][pCredits]), number_format(amount));
			ShowPlayerDialogEx(giveplayerid, DIALOG_CHARGEPLAYER, DIALOG_STYLE_MSGBOX, "Phat Credit", string, "Dong y", "Tu choi");
			return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong phai Admin cap ba.");
	}
	return 1;
}

CMD:givecredits(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 99999 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

	new szMessage[128], Player, Amount;

	if(sscanf(params, "ud", Player, Amount))
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givecredits [Player] [Amount]");

	if(!IsPlayerConnected(Player))
	    return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

	PlayerInfo[Player][pCredits] += Amount;

	mysql_format(MainPipeline, szMessage, sizeof(szMessage), "UPDATE `accounts` SET `Credits`=%d WHERE `id` = %d", PlayerInfo[Player][pCredits], GetPlayerSQLId(Player));
	mysql_tquery(MainPipeline, szMessage, "OnQueryFinish", "ii", SENDDATA_THREAD, Player);
	print(szMessage);

	format(szMessage, sizeof(szMessage), "[SETCREDITS] [Amount: %d] [User: %s(%i)] [IP: %s] [Credits: %s] [Admin: %s] [IP: %s]",Amount,GetPlayerNameEx(Player), GetPlayerSQLId(Player), GetPlayerIpEx(Player), number_format(PlayerInfo[Player][pCredits]), GetPlayerNameEx(playerid), GetPlayerIpEx(playerid));
	Log("logs/credits.log", szMessage), print(szMessage);

	SendClientMessageEx(playerid, COLOR_CYAN, "Ban da cap %s %s credits.", GetPlayerNameEx(Player), number_format(Amount));
	return 1;
}

CMD:setcredits(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 99999 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

	new szMessage[128], Player, Amount;

	if(sscanf(params, "ud", Player, Amount))
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setcredits [Player] [Amount]");

	if(!IsPlayerConnected(Player))
	    return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

	PlayerInfo[Player][pCredits] = Amount;

	mysql_format(MainPipeline, szMessage, sizeof(szMessage), "UPDATE `accounts` SET `Credits`=%d WHERE `id` = %d", PlayerInfo[Player][pCredits], GetPlayerSQLId(Player));
	mysql_tquery(MainPipeline, szMessage, "OnQueryFinish", "ii", SENDDATA_THREAD, Player);
	print(szMessage);

	format(szMessage, sizeof(szMessage), "[SETCREDITS] [Amount: %d] [User: %s(%i)] [IP: %s] [Credits: %s] [Admin: %s] [IP: %s]",Amount,GetPlayerNameEx(Player), GetPlayerSQLId(Player), GetPlayerIpEx(Player), number_format(PlayerInfo[Player][pCredits]), GetPlayerNameEx(playerid), GetPlayerIpEx(playerid));
	Log("logs/credits.log", szMessage), print(szMessage);

	SendClientMessageEx(playerid, COLOR_CYAN, "Ban da dat credits cua %s thanh %s.", GetPlayerNameEx(Player), number_format(PlayerInfo[Player][pCredits]));
	return 1;
}

CMD:settotalcredits(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 99999 && PlayerInfo[playerid][pShopTech] != 3)
	    return 0;

	new szMessage[128], Player, Amount;

	if(sscanf(params, "ud", Player, Amount))
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /settotalcredits [Player] [Amount]");

	if(!IsPlayerConnected(Player))
	    return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

	PlayerInfo[Player][pTotalCredits] = Amount;

    mysql_format(MainPipeline, szMessage, sizeof(szMessage), "UPDATE `accounts` SET `TotalCredits`=%d WHERE `id` = %d", PlayerInfo[Player][pTotalCredits], GetPlayerSQLId(Player));
	mysql_tquery(MainPipeline, szMessage, "OnQueryFinish", "ii", SENDDATA_THREAD, Player);

	format(szMessage, sizeof(szMessage), "[SETTOTALCREDITS][Amount: %d] [User: %s(%i)] [IP: %s] [Admin: %s] [IP: %s]",Amount, GetPlayerNameEx(Player), GetPlayerSQLId(Player), GetPlayerIpEx(Player), GetPlayerNameEx(playerid), GetPlayerIpEx(playerid));
	Log("logs/credits.log", szMessage), print(szMessage);

	SendClientMessageEx(playerid, COLOR_CYAN, "Ban da dat tong credits cua %s thanh %s.", GetPlayerNameEx(Player), number_format(PlayerInfo[Player][pTotalCredits]));
	return 1;
}

CMD:toghalloweenshop(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 1337 || PlayerInfo[playerid][pPR] == 2 || PlayerInfo[playerid][pShopTech] == 3)
	{
		new string[128];
		if(HalloweenShop)
		{
			HalloweenShop = 0;
			SendClientMessageEx(playerid, COLOR_RED, "Da bat Halloween Shop, nguoi choi co the su dung.");
			g_mysql_SaveMOTD();
			format(string, sizeof(string), "Admin %s(%i) has toggled the halloween toy shop on.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid) );
			Log("logs/zombiecure.log", string);
		}
		else{
			HalloweenShop = 1;
			SendClientMessageEx(playerid, COLOR_RED, "Da tat Halloween Shop, nguoi choi khong the su dung.");
			g_mysql_SaveMOTD();
			format(string, sizeof(string), "Admin %s(%i) has toggled the halloween toy shop off.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid) );
			Log("logs/zombiecure.log", string);
		}
	}
	return 1;
}

CMD:setpumpkinstock(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] > 1337 || PlayerInfo[playerid][pPR] == 2 || PlayerInfo[playerid][pShopTech] == 3)
	{
		new string[128], pumpkins;
		if(sscanf(params, "d", pumpkins)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setpumpkinstock [stock]");
		SendClientMessageEx(playerid, COLOR_GRAD1, "Da dat ton kho pumpkin thanh %d.", pumpkins);
		format(string, sizeof(string), "Admin %s(%i) has set the pumpkin stock to %d from %d.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), pumpkins, PumpkinStock );
		Log("logs/zombiecure.log", string);
		PumpkinStock = pumpkins;
		g_mysql_SaveMOTD();
	}
	return 1;
}

stock Microshop_ChangePhoneNumber(playerid, number, price, oldnumber)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid} || !GetPVarInt(playerid, "PinConfirmed")) return 0;
	if(!(100000 <= number <= 999999) || number == oldnumber || oldnumber == 0 || oldnumber != PlayerInfo[playerid][pPnumber])
		return SendClientMessageEx(playerid, COLOR_GREY, "So cu hoac so yeu cau khong hop le. Hay chon lai."), 0;
	
	if(TempNumber[playerid] || GetPVarType(playerid, "WantedPh") || GetPVarType(playerid, "tempnum"))
		return SendClientMessageEx(playerid, COLOR_GREY, "Hay xong hoac huy lan doi so dien thoai khac truoc."), 0;
	
	if(Mobile[playerid] != INVALID_PLAYER_ID || GetPVarType(playerid, "PayPhone") || GetPVarType(playerid, "CallingPayPhone"))
		return SendClientMessageEx(playerid, COLOR_GREY, "Hay ket thuc cuoc goi truoc khi doi so."), 0;
	
	if(price <= 0 || price != MicroItems[11] || PlayerInfo[playerid][pCredits] < price || PlayerInfo[playerid][pTotalCredits] < 0 || PlayerInfo[playerid][pTotalCredits] > cellmax - price)
		return SendClientMessageEx(playerid, COLOR_GREY, "Gia da doi hoac ban khong du tien. Hay chon lai."), 0;
	
	if(restarting || gPayPhonesLoading || !gAccountsInnoDB || GetPlayerSQLId(playerid) <= 0 || mysql_unprocessed_queries(MainPipeline) != 0)
		return SendClientMessageEx(playerid, COLOR_GREY, "Shop dang ban. Hay thu lai sau."), 0;
	
	foreach(new other : Player)
	{
		if(other == playerid || !gPlayerLogged{other}) continue;
		if(PlayerInfo[other][pPnumber] == number || GetPVarInt(other, "WantedPh") == number || GetPVarInt(other, "tempnum") == number ||
			(TempNumber[other] && GetPVarInt(other, "oldnum") == number))
			return SendClientMessageEx(playerid, COLOR_GREY, "So dien thoai da duoc dung hoac nguoi khac giu cho."), 0;
	}
	
	for(new phone; phone < MAX_PAYPHONES; phone++)
	{
		if(arrPayPhoneData[phone][pp_iNumber] == number)
			return SendClientMessageEx(playerid, COLOR_GREY, "So dien thoai thuoc dien thoai cong cong."), 0;
	}
	
	new query[512], credits = PlayerInfo[playerid][pCredits] - price, spent = PlayerInfo[playerid][pTotalCredits] + price;
	mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` a LEFT JOIN `accounts` used ON used.`PhoneNr`=%d AND used.`id`<>a.`id` SET a.`PhoneNr`=%d,a.`Credits`=%d,a.`TotalCredits`=%d WHERE a.`id`=%d AND a.`PhoneNr`=%d AND a.`Credits`=%d AND a.`TotalCredits`=%d AND used.`id` IS NULL",
		number, number, credits, spent, GetPlayerSQLId(playerid), oldnumber, PlayerInfo[playerid][pCredits], PlayerInfo[playerid][pTotalCredits]);
	new Cache:result = mysql_query(MainPipeline, query);
	new affected;
	if(cache_is_valid(result))
	{
		affected = cache_affected_rows();
		cache_delete(result);
	}
	if(affected != 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "Khong xac nhan duoc doi so. Hay thu lai sau."), 0;
	PlayerInfo[playerid][pPnumber] = number;
	PlayerInfo[playerid][pCredits] = credits;
	PlayerInfo[playerid][pTotalCredits] = spent;
	SendClientMessageEx(playerid, COLOR_CYAN, "So dien thoai da doi tu %d thanh %d.", oldnumber, number);
	return 1;
}

CMD:microshop(playerid, const params[])
{
	DeletePVar(playerid, "m_listitem");
	DeletePVar(playerid, "m_Item");
	DeletePVar(playerid, "m_Response");
	DeletePVar(playerid, "m_PhoneNumber");
	DeletePVar(playerid, "m_PhonePrice");
	DeletePVar(playerid, "m_PhoneOld");
	if(GetPVarInt(playerid, "PinConfirmed")) ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP, DIALOG_STYLE_LIST, "Microtransaction Shop", "Cong viec va kinh nghiem\nVIP\nThuc an\nNha\nXe\nKhac\nSu kien", "Chon", "Thoat");
	else SetPVarInt(playerid, "OpenShop", 11), PinLogin(playerid);
	return 1;
}

CMD:placesign(playerid, params[])
{
	if(!PlayerInfo[playerid][mInventory][6]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co House Sale Sign, dung /microshop de mua");
	new h = InRangeOfWhichHouse(playerid, 10);
	if(h == INVALID_HOUSE_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Phai cach nha khong qua 10 meter de dat bien.");
	if(HouseInfo[h][hSignExpire]) return SendClientMessageEx(playerid, COLOR_GREY, "Nha da co bien rao ban, dung /editsign de doi vi tri hoac noi dung.");
	if(GetPVarType(playerid, "signID")) return SendClientMessageEx(playerid, COLOR_GREY, "Hay dat xong bien rao ban hien tai truoc khi dat bien khac.");
	ClearCheckpoint(playerid);
	new Float:pos[4];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	GetPlayerFacingAngle(playerid, pos[3]);
	SetPVarInt(playerid, "house", h);
	SetPVarInt(playerid, "editingsign", 1);
	SetPVarInt(playerid, "signID", CreateDynamicObject(19471, pos[0]+1, pos[1], pos[2], 0, 0, pos[3], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid)));
	EditDynamicObject(playerid, GetPVarInt(playerid, "signID"));
	SendClientMessageEx(playerid, 0xFFFFAAAA, "GOI Y: Giu {8000FF}~k~~PED_SPRINT~ {FFFFAA}de doi camera, nhan escape de huy");
	SetPlayerCheckpoint(playerid, HouseInfo[h][hExteriorX], HouseInfo[h][hExteriorY], HouseInfo[h][hExteriorZ], 20);
	SendClientMessageEx(playerid, COLOR_GREY, "Giu object trong checkpoint de dat thanh cong.");
	return 1;
}

CMD:editsign(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new h, option[10], desc[64];
		if(sscanf(params, "ds[10]S()[64]", h, option, desc)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editsign [houseid] [option]"), SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: text, position");
		if(HouseInfo[h][hSignExpire] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha chua co House Sale Sign, dung /placesign de dat.");
		if(!strcmp(option, "text", true))
		{
			if(!(1 <= strlen(desc) <= 64)) return SendClientMessageEx(playerid, COLOR_GREY, "Noi dung khong duoc trong hoac dai hon 64 ky tu.");
			new string[128], escapeDesc[64];
			mysql_escape_string(desc, escapeDesc);
			format(HouseInfo[h][hSignDesc], sizeof(escapeDesc), "%s", escapeDesc);
			format(string, sizeof(string), "%s has edited house ID: %d sale sign text to %s", GetPlayerNameEx(playerid), h, HouseInfo[h][hSignDesc]);
			Log("logs/hedit.log", string);
			SendClientMessageEx(playerid, -1, string);
		}
		if(!strcmp(option, "position", true))
		{
			ClearCheckpoint(playerid);
			SetPVarInt(playerid, "house", h);
			SetPVarInt(playerid, "editingsign", 3);
			SetPVarInt(playerid, "signID", HouseInfo[h][hSignObj]);
			EditDynamicObject(playerid, GetPVarInt(playerid, "signID"));
			SendClientMessageEx(playerid, 0xFFFFAAAA, "GOI Y: Giu {8000FF}~k~~PED_SPRINT~ {FFFFAA}de doi camera, nhan escape de huy");
			SetPlayerCheckpoint(playerid, HouseInfo[h][hExteriorX], HouseInfo[h][hExteriorY], HouseInfo[h][hExteriorZ], 20);
			SendClientMessageEx(playerid, COLOR_GREY, "Giu object trong checkpoint de dat thanh cong.");
		}
		return 1;
	}
	if(GetPVarType(playerid, "editingsign")) return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang sua bien rao ban nha.");
	new h = InRangeOfWhichHouse(playerid, 10);
	if(h == INVALID_HOUSE_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Phai cach nha khong qua 10 meter de sua bien.");
	if(HouseInfo[h][hSignExpire] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nha chua co House Sale Sign, dung /placesign de dat.");
	new option[10], desc[64];
	if(sscanf(params, "s[10]S()[64]", option, desc)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editsign [option]"), SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: text, position");
	if(!strcmp(option, "text", true))
	{
		if(GetPVarType(playerid, "HasReport")) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co 1 bao cao dang mo. (/cancelreport)");
		if(isnull(desc)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /editsign text [decription]");
		if(!(1 <= strlen(desc) <= 64)) return SendClientMessageEx(playerid, COLOR_GREY, "Noi dung khong duoc trong hoac dai hon 64 ky tu.");
		new string[128];
		SetPVarInt(playerid, "hSignRequest", h);
		SetPVarString(playerid, "hSignRequestText", desc);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Da yeu cau doi noi dung House Sale Sign cho nha ID: %d, hay cho General Admin duyet.", h);
		format(string, sizeof(string), "Doi noi dung House Sale Sign (HID: %d)", h);
		SendReportToQue(playerid, string, 2, 4);
	}
	if(!strcmp(option, "position", true))
	{
		ClearCheckpoint(playerid);
		SetPVarInt(playerid, "house", h);
		SetPVarInt(playerid, "editingsign", 2);
		SetPVarInt(playerid, "signID", HouseInfo[h][hSignObj]);
		EditDynamicObject(playerid, GetPVarInt(playerid, "signID"));
		SendClientMessageEx(playerid, 0xFFFFAAAA, "GOI Y: Giu {8000FF}~k~~PED_SPRINT~ {FFFFAA}de doi camera, nhan escape de huy");
		SetPlayerCheckpoint(playerid, HouseInfo[h][hExteriorX], HouseInfo[h][hExteriorY], HouseInfo[h][hExteriorZ], 20);
		SendClientMessageEx(playerid, COLOR_GREY, "Giu object trong checkpoint de dat thanh cong.");
	}
	return 1;
}

CMD:readsign(playerid, params[])
{
	for(new i; i < MAX_HOUSES; i++)
	{
		if(!HouseInfo[i][hSignExpire]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 5, HouseInfo[i][hSign][0], HouseInfo[i][hSign][1], HouseInfo[i][hSign][2]))
		{
			if(isnull(HouseInfo[i][hSignDesc])) format(HouseInfo[i][hSignDesc], 64, "None");
			return ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "House Sale Sign", HouseInfo[i][hSignDesc], "Dong", "");
		}
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan bien rao ban nha nao.");
	return 1;
}

CMD:fuelcan(playerid, params[])
{
	if(!PlayerInfo[playerid][mInventory][7]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Fuel Cans, dung /microshop de mua.");
	if(GetPVarInt(playerid, "fuelcan") == 1) return 1;
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung Fuel Can khi dang trong xe.");
	if(GetPVarInt(playerid, "EventToken")) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung trong su kien.");
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen")) return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam vay!");
	new closestcar = GetClosestCar(playerid);
	if(!IsPlayerInRangeOfVehicle(playerid, closestcar, 10.0)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o du gan xe nao.");
	new string[72];
	format(string, sizeof(string), "%s bat dau do xang cho xe bang Fuel Can.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	ApplyAnimation(playerid, "SCRATCHING", "scdldlp", 4.0, true, false, false, false, 0, 1);
	SetTimerEx("FuelCan", 10000, false, "iii", playerid, closestcar, 100);
	SetPVarInt(playerid, "fuelcan", 1);
	GameTextForPlayer(playerid, "~w~Dang bom xang...", 10000, 3);
	return 1;
}

CMD:jumpstart(playerid, params[])
{
	if(!PlayerInfo[playerid][mInventory][8]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Jump Start, dung /microshop de mua.");
	if(GetPVarInt(playerid, "jumpstarting") == 1) return 1;
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the kich no khi dang trong xe.");
	if(GetPVarInt(playerid, "EventToken")) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung trong su kien.");
	if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen")) return SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam vay!");
	new closestcar = GetClosestCar(playerid);
	if(!IsPlayerInRangeOfVehicle(playerid, closestcar, 10.0)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o du gan xe nao.");
	if(!IsABike(closestcar) && !IsAPlane(closestcar))
	{
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(closestcar,engine,lights,alarm,doors,bonnet,boot,objective);
		if(bonnet == VEHICLE_PARAMS_OFF || bonnet == VEHICLE_PARAMS_UNSET) return SendClientMessageEx(playerid, COLOR_GRAD1, "Phai mo nap capo de kich no xe.");
	}
	new string[61];
	format(string, sizeof(string), "%s bat dau kich no xe.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	ApplyAnimation(playerid, "MISC", "Plunger_01", 4.1, true, true, true, true, 1, 1);
	SetTimerEx("JumpStart", 10000, false, "ii", playerid, closestcar);
	SetPVarInt(playerid, "jumpstarting", 1);
	GameTextForPlayer(playerid, "~w~Dang kich no...", 10000, 3);
	return 1;
}

CMD:rcarcolor(playerid, params[])
{
	if(!PlayerInfo[playerid][mInventory][9]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Restricted Car Colors, dung /microshop de mua.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o trong xe.");
	new iColors[2];
	if(sscanf(params, "dd", iColors[0], iColors[1])) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rcarcolor [color1] [color2]. Mau phai la ID.");
	if(!(128 <= iColors[0] <= 255 && 0 <= iColors[1] <= 255)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Mau sai (Restricted color IDs tu 128 den 255).");
	new szMessage[128];
	for(new i = 0; i < MAX_PLAYERVEHICLES; i++)
	{
		if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][i][pvId]))
		{
			PlayerVehicleInfo[playerid][i][pvColor1] = iColors[0], PlayerVehicleInfo[playerid][i][pvColor2] = iColors[1];
			ChangeVehicleColor(PlayerVehicleInfo[playerid][i][pvId], PlayerVehicleInfo[playerid][i][pvColor1], PlayerVehicleInfo[playerid][i][pvColor2]);
			PlayerInfo[playerid][mInventory][9]--;
			g_mysql_SaveVehicle(playerid, i);
			format(szMessage, sizeof(szMessage), "[RCARCOLOR] %s(%d) used a restricted car color. Left: %d", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), PlayerInfo[playerid][mInventory][9]);
			Log("logs/micro.log", szMessage);
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Da doi mau xe thanh ID %d, %d.", iColors[0], iColors[1]);
		}
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Ban can o trong xe cua minh.");
	return 1;
}

CMD:eatbar(playerid, params[])
{
	if(!PlayerInfo[playerid][mInventory][4]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Energy Bars, dung /microshop de mua.");
	if(GetPVarInt(playerid, "eatingbar") == 1) return 1;
	new string[128];
	if(PlayerInfo[playerid][mCooldown][4]) 
	{
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Energy Bar dang hoat dong, hay cho het han sau %d phut de dung tiep.", PlayerInfo[playerid][mCooldown][4]);
	}
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, true, false, false, false, 0, 1);
	format(string, sizeof(string), "%s nhai Energy Bar", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	SetPVarInt(playerid, "eatingbar", 1);
	SetTimerEx("EatBar", 2000, false, "i", playerid);
	return 1;
}

CMD:activeitems(playerid, params[])
{
	new string[128];
	if(PlayerInfo[playerid][mPurchaseCount][1] && PlayerInfo[playerid][mCooldown][1]) format(string, sizeof(string), "Job Boost cho cong viec %s con hieu luc %d phut.", GetJobName(PlayerInfo[playerid][mBoost][0]), PlayerInfo[playerid][mCooldown][1]), SendClientMessageEx(playerid, -1, string);
	if(PlayerInfo[playerid][mCooldown][4]) format(string, sizeof(string), "Energy Bar con hieu luc %d phut.", PlayerInfo[playerid][mCooldown][4]), SendClientMessageEx(playerid, -1, string);
	if(PlayerInfo[playerid][mPurchaseCount][12] && PlayerInfo[playerid][mCooldown][12]) format(string, sizeof(string), "Quick Bank Access con hieu luc %d phut.", PlayerInfo[playerid][mCooldown][12]), SendClientMessageEx(playerid, -1, string);
	if(zombieevent) format(string, sizeof(string), "Khang sinh trong mau bao ve ban khoi %d lan Zombie can.", PlayerInfo[playerid][mInventory][18]), SendClientMessageEx(playerid, -1, string);
	return 1;
}

CMD:cooldowns(playerid, params[])
{
	for(new item; item < MAX_MICROITEMS; item++)
	{
		if(gettime() < PlayerInfo[playerid][mCooldown][item])
		{
			new microItemName[36];
			strunpack(microItemName, mItemName[item], sizeof(microItemName));
			SendClientMessageEx(playerid, -1, "Ban co the mua lai \"%s\" sau %s.", microItemName, ConvertTimeS(PlayerInfo[playerid][mCooldown][item]-gettime()));
		}
	}
	return 1;
}

CMD:managecredits(playerid, params[]) 
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pShopTech] >= 3)
		return ShowPlayerDialogEx(playerid, DIALOG_MANAGECREDITS, DIALOG_STYLE_LIST, "Quan ly Credits",  "Ban Credits\nFree Weekend\nBan Credit cho Non-VIP", "Dong y", "Huy");
	return 0;
}

forward OnShopOrder(index);
public OnShopOrder(index)
{
	if(IsPlayerConnected(index))
	{
	    HideNoticeGUIFrame(index);
		new rows;
		cache_get_row_count(rows);
		if(rows > 0)
		{
		    new string[512];
		    new ipsql[16], ip[16];
	    	GetPlayerIp(index, ip, sizeof(ip));
		    cache_get_value_name(0, "ip", ipsql);
		    if(!isnull(ipsql) && strcmp(ipsql, ip, true) == 0)
			{
			    new status, name[64], quantity, delivered, product_id;
			    for(new i;i<rows;i++)
			    {
	   				cache_get_value_name_int(i, "order_status_id", status);
			    	if(status == 2)
				    {
	    			 	cache_get_value_name(i, "name", name);
			  			cache_get_value_name_int(i, "quantity", quantity);
			  		    cache_get_value_name_int(i, "delivered", delivered);
			  			cache_get_value_name_int(i, "order_product_id", product_id);
				    	if(quantity-delivered <= 0)
					    {
	        				if(i<rows) format(string, sizeof(string), "%s%s (Da giao)\n", string, name);
					        else format(string, sizeof(string), "%s%s (Da giao)", string, name);
						}
						else
						{
		    				if(i<rows) format(string, sizeof(string), "%s%s (%d)\n", string, name, quantity-delivered);
					    	else format(string, sizeof(string), "%s%s (%d)", string, name, quantity-delivered);
						}
					}
					else
					{
					    new reason[27];
						switch(status)
						{
						    case 0: format(reason, sizeof(reason), "{FF0000}Chua tra");
						    case 1: format(reason, sizeof(reason), "{FF0000}Dang cho");
						    case 3: format(reason, sizeof(reason), "{00FF00}Da gui");
						    case 5:
							{
								ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", "Don nay da giao xong", "Dong y", "");
								return 1;
							}
			    			case 7: format(reason, sizeof(reason), "{FF0000}Da huy");
					    	case 8: format(reason, sizeof(reason), "{FF0000}Tu choi");
				   			case 9: format(reason, sizeof(reason), "{FF0000}Da huy dao nguoc");
					    	case 10: format(reason, sizeof(reason), "{FF0000}That bai");
						    case 11: format(reason, sizeof(reason), "{00FF00}Da hoan tien");
						    case 12: format(reason, sizeof(reason), "{FF0000}Da dao nguoc");
						    case 13: format(reason, sizeof(reason), "{FF0000}Chargeback");
				   			default: format(reason, sizeof(reason), "{FF0000}Khong ro");
						}
						format(string, sizeof(string), "Chua the xu ly don nay,\nvi thanh toan dang duoc danh dau: %s", reason);
						ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", string, "Dong y", "");
	  					return 1;
					}
				}
			}
			else
			{
			    new email[256];
			    cache_get_value_name(0, "email", email);
			    SetPVarString(index, "ShopEmailVerify", email);
			    ShowPlayerDialogEx(index, DIALOG_SHOPORDEREMAIL, DIALOG_STYLE_INPUT, "Loi don hang cua hang", "Khong ghep duoc don hang voi IP cua ban,\nnhap e-mail shop de xac minh danh tinh:", "Gui", "Huy");
			    return 1;
			}
			ShowPlayerDialogEx(index, DIALOG_SHOPORDER2, DIALOG_STYLE_LIST, "Danh sach don Shop", string, "Chon", "Huy");
		}
		else
		{
		    ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", "Loi: Khong co don nao voi Order ID nay\nNeu chac Order ID dung, hay thu lai hoac nhap '1' lam order ID.", "Dong y", "");
		}
	}
	return 1;
}

forward OnShopOrderEmailVer(index);
public OnShopOrderEmailVer(index)
{
	if(IsPlayerConnected(index))
	{
	    HideNoticeGUIFrame(index);
		new rows;
		cache_get_row_count(rows);
		if(rows > 0)
		{
		    new string[512];
		   	new status, name[64], quantity, delivered, product_id;
		    for(new i; i < rows; i++)
		    {
			    cache_get_value_name_int(i, "order_status_id", status);
				if(status == 2)
	   			{
					cache_get_value_name(i, "name", name);
	 				cache_get_value_name_int(i, "quantity", quantity);
		    		cache_get_value_name_int(i, "delivered", delivered);
	  				cache_get_value_name_int(i, "order_product_id", product_id);
		   			if(quantity-delivered <= 0)
				    {
	   					if(i<rows) format(string, sizeof(string), "%s%s (Da giao)\n", string, name);
	       				else format(string, sizeof(string), "%s%s (Da giao)", string, name);
					}
					else
					{
					    if(i<rows) format(string, sizeof(string), "%s%s (%d)\n", string, name, quantity-delivered);
					    else format(string, sizeof(string), "%s%s (%d)", string, name, quantity-delivered);
					}
				}
				else
				{
	    			new reason[27];
					switch(status)
					{
	    				case 0: format(reason, sizeof(reason), "{FF0000}Chua tra");
		   				case 1: format(reason, sizeof(reason), "{FF0000}Dang cho");
					    case 3: format(reason, sizeof(reason), "{00FF00}Da gui");
					    case 5:
						{
							ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", "Don nay da giao xong", "Dong y", "");
							return 1;
						}
			   			case 7: format(reason, sizeof(reason), "{FF0000}Da huy");
					    case 8: format(reason, sizeof(reason), "{FF0000}Tu choi");
					    case 9: format(reason, sizeof(reason), "{FF0000}Da huy dao nguoc");
					    case 10: format(reason, sizeof(reason), "{FF0000}That bai");
			   			case 11: format(reason, sizeof(reason), "{00FF00}Da hoan tien");
					    case 12: format(reason, sizeof(reason), "{FF0000}Da dao nguoc");
					    case 13: format(reason, sizeof(reason), "{FF0000}Chargeback");
					    default: format(reason, sizeof(reason), "{FF0000}Khong ro");
					}
					format(string, sizeof(string), "Chua the xu ly don nay,\nvi thanh toan dang duoc danh dau: %s", reason);
					ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", string, "Dong y", "");
	 				return 1;
				}
			}
			ShowPlayerDialogEx(index, DIALOG_SHOPORDER2, DIALOG_STYLE_LIST, "Danh sach don Shop", string, "Chon", "Huy");
		}
		else
		{
		    ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", "Loi: Khong co don nao voi Order ID nay\nNeu chac Order ID dung, hay thu lai hoac nhap '1' lam order ID.", "Dong y", "");
		}
	}
	return 1;
}

forward OnShopOrder2(index, extraid);
public OnShopOrder2(index, extraid)
{
	if(IsPlayerConnected(index))
	{
	    HideNoticeGUIFrame(index);
		new string[256];
		new rows;
		cache_get_row_count(rows);
		if(rows > 0)
		{
		    for(new i; i < rows; i++)
		    {
	  			if(i == extraid)
		    	{
	      			new status;
		        	cache_get_value_name_int(i, "status", status);
			        if(status == 2)
		        	{
			    		new order_id, order_product_id, product_id, name[64], price, user[32], quantity, delivered;
				    	cache_get_value_name_int(i, "order_id", order_id);
						cache_get_value_name_int(i, "order_product_id", order_product_id);
						cache_get_value_name_int(i, "product_id", product_id);
						cache_get_value_name(i, "name", name);
		  				cache_get_value_name_int(i, "price", price);
			  			cache_get_value_name(i, "deliveruser", user);
			  			cache_get_value_name_int(i, "quantity", quantity);
			  			cache_get_value_name_int(i, "delivered", delivered);

						format(string, sizeof(string), "Order ID: %d\nProduct ID: %d\nSan pham: %s\nGia: %s\nTen: %s\nSo luong: %d", \
						order_id, order_product_id, name, price, user, quantity-delivered);

						SetPVarInt(index, "DShop_order_id", order_id);
						SetPVarInt(index, "DShop_product_id", product_id);
						SetPVarString(index, "DShop_name", name);
						SetPVarInt(index, "DShop_quantity", quantity-delivered);

						ShowPlayerDialogEx(index, DIALOG_SHOPDELIVER, DIALOG_STYLE_LIST, "Thong tin don Shop", string, "Giao hang", "Huy");
						return 1;
					}
					else
					{
						new reason[27];
						switch(status)
						{
						    case 0: format(reason, sizeof(reason), "{FF0000}Chua tra");
						    case 1: format(reason, sizeof(reason), "{FF0000}Dang cho");
						    case 3: format(reason, sizeof(reason), "{00FF00}Da gui");
						    case 5:
							{
								ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", "Don nay da giao xong", "Dong y", "");
								return 1;
							}
				   			case 7: format(reason, sizeof(reason), "{FF0000}Da huy");
						    case 8: format(reason, sizeof(reason), "{FF0000}Tu choi");
						    case 9: format(reason, sizeof(reason), "{FF0000}Da huy dao nguoc");
						    case 10: format(reason, sizeof(reason), "{FF0000}That bai");
						    case 11: format(reason, sizeof(reason), "{00FF00}Da hoan tien");
						    case 12: format(reason, sizeof(reason), "{FF0000}Da dao nguoc");
						    case 13: format(reason, sizeof(reason), "{FF0000}Chargeback");
						    default: format(reason, sizeof(reason), "{FF0000}Khong ro");
						}
						format(string, sizeof(string), "Chua the xu ly don nay,\nvi thanh toan dang duoc danh dau: %s", reason);
						ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", string, "Dong y", "");
	  					return 1;
					}
				}
			}
		}
		else
		{
		    ShowPlayerDialogEx(index, 0, DIALOG_STYLE_MSGBOX, "Loi don hang cua hang", "Loi: Khong co don nao voi Order ID nay\nNeu chac Order ID dung, hay thu lai hoac nhap '1' lam order ID.", "Dong y", "");
		}
	}
	return 1;
}

forward OnProcessOrderCheck(index, extraid);
public OnProcessOrderCheck(index, extraid)
{
	if(IsPlayerConnected(index))
	{
		new string[256],playerip[32], giveplayerip[32];
		GetPlayerIp(index, playerip, sizeof(playerip));
		GetPlayerIp(extraid, giveplayerip, sizeof(giveplayerip));

		new rows;
		cache_get_row_count(rows);
		if(rows)
		{
			SendClientMessageEx(index, COLOR_WHITE, "Don nay da duoc xu ly, khong duoc tinh vao luong cua ban.");
			format(string, sizeof(string), "%s(IP: %s) has processed shop order ID %d from %s(IP: %s).", GetPlayerNameEx(index), playerip, GetPVarInt(index, "processorder"), GetPlayerNameEx(extraid), giveplayerip);
			Log("logs/shoporders.log", string);
		}
		else
		{
			format(string, sizeof(string), "%s(IP: %s) has processed shop order ID %d from %s(IP: %s).", GetPlayerNameEx(index), playerip, GetPVarInt(index, "processorder"), GetPlayerNameEx(extraid), giveplayerip);
			Log("logs/shopconfirmedorders.log", string);
			PlayerInfo[index][pShopTechOrders]++;

			mysql_format(MainPipeline, string, sizeof(string), "INSERT INTO shoptech (id,total,dtotal) VALUES (%d,1,%f) ON DUPLICATE KEY UPDATE total = total + 1, dtotal = dtotal + %f", GetPlayerSQLId(index), ShopTechPay, ShopTechPay);
			mysql_tquery(MainPipeline, string, "OnQueryFinish", "ii", SENDDATA_THREAD, index);

			mysql_format(MainPipeline, string, sizeof(string), "INSERT INTO `orders` (`id`) VALUES ('%d')", GetPVarInt(index, "processorder"));
			mysql_tquery(MainPipeline, string, "OnQueryFinish", "ii", SENDDATA_THREAD, index);
			
			/*format(string, sizeof(string), "INSERT INTO betazorder_history (`order_id`, `order_status_id`, `comment`, `date_added`, `notify`) \
			VALUES ('%d', '5', 'Order Processed (%s) (Status: Complete)', NOW(), '1')", GetPVarInt(index, "processorder"), GetPlayerNameEx(index));
			mysql_tquery(ShopPipeline, string, false, "OnQueryFinish", "ii", SENDDATA_THREAD, index);
			
			format(string, sizeof(string), "UPDATE betazorder SET `order_status_id` = '5' WHERE `order_id` = '%d'", GetPVarInt(index, "processorder"));
			mysql_tquery(ShopPipeline, string, false, "OnQueryFinish", "ii", SENDDATA_THREAD, index);*/
		}
		DeletePVar(index, "processorder");
	}
	return 1;
}