/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

				  Accept / Cancel Commands

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

Offer_IsCurrent(playerid, senderid, const sessionKey[]) {
	return 0 <= senderid < MAX_PLAYERS && IsPlayerConnected(senderid) && gPlayerLogged{senderid}
		&& !GetPVarInt(senderid, "PropertySaleUncertain") && !GetPVarInt(senderid, "FurniturePurchaseUncertain")
		&& GetPVarInt(playerid, sessionKey) == g_arrQueryHandle[senderid];
}

PropertySale_Commit(playerid, sellerid, const query[], const verification[], houseid = INVALID_HOUSE_ID) {
	new Cache:result = mysql_query(MainPipeline, query);
	new error = mysql_errno(MainPipeline), affected;
	new bool:cached = cache_is_valid(result);
	if(cached) {
		affected = cache_affected_rows();
		cache_delete(result);
	}
	if(!error && cached) return affected > 0;
	if(error > 0 && error < 2000) return 0;

	result = mysql_query(MainPipeline, verification);
	new rows, owner, committed;
	if(cache_is_valid(result)) {
		cache_get_row_count(rows);
		if(rows == 1) {
			cache_get_value_name_int(0, "owner", owner);
			cache_get_value_name_int(0, "committed", committed);
		}
		cache_delete(result);
	}
	if(rows == 1) {
		if(committed) return 1;
		if(owner == GetPlayerSQLId(sellerid)) return 0;
	}
	gPropertySaleUncertain[0] = GetPlayerSQLId(playerid);
	gPropertySaleUncertain[1] = GetPlayerSQLId(sellerid);
	if(0 <= houseid < MAX_HOUSES) gHouseSaleUncertain[houseid] = true;
	SetPVarInt(playerid, "PropertySaleUncertain", 1);
	SetPVarInt(sellerid, "PropertySaleUncertain", 1);
	print("[Property sale] Result unresolved. Affected accounts and property saves are blocked until restart.");
	SendClientMessageEx(playerid, COLOR_RED, "Khong the xac minh giao dich. Lien he Admin truoc khi ket noi lai.");
	SendClientMessageEx(sellerid, COLOR_RED, "Khong the xac minh giao dich. Lien he Admin truoc khi ket noi lai.");
	Kick(playerid);
	Kick(sellerid);
	return -1;
}

CMD:accept(playerid, params[])
{
	if(GetPVarInt(playerid, "PropertySaleUncertain") || GetPVarInt(playerid, "FurniturePurchaseUncertain")) return 1;
	if(restarting) return SendClientMessageEx(playerid, COLOR_GRAD2, "Giao dich da tam dung de khoi dong lai may chu bao tri.");
	new szMessage[256];
	new string[128];
	new sendername[MAX_PLAYER_NAME];
	new giveplayer[MAX_PLAYER_NAME];
	new giveplayerid;
	if(HungerPlayerInfo[playerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   Khong the lam vay trong Hunger Games Event!");
    if(IsPlayerConnected(playerid)) {
        if(isnull(params)) {
            SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /accept [name]");
            SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Sex, Mats, Crack, Cannabis, Weapon, Craft, Repair, Lawyer, Bodyguard, Job, Live, Refill");
            SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Firework, Group, Boxing, Medic, Mechanic, Ticket, Car, Death, Backpack");
            SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Business, Item, Offer, Heroin, Rawopium, Syringes, Rimkit, Voucher, Kiss, RenderAid, Frisk");
            return 1;
        }
		if(strcmp(params, "door", true) == 0)
		{
			new target, fine, count;
			target = INVALID_PLAYER_ID;
			foreach(new i: Player)
			{
				if(gPlayerLogged{i} == 1 && DDSalePendingAdmin[i] == false && DDSalePendingPlayer[i] == true && DDSaleTarget[i] == playerid)
				{
					target = i;
					count ++;
					if(count > 1) break;
				}
			}
			if(target == INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co de nghi mua Dynamic Door hien tai.");
			if(count > 1)
			{
				foreach(new i : Player) if(gPlayerLogged{i} == 1 && DDSaleTarget[i] == playerid) ClearDoorSaleVariables(i);
				SendClientMessageEx(playerid, COLOR_GREY, "Co loi, hay thuc hien lai giao dich.");
				return 1;
			}
			if(GetPlayerCash(playerid) < DDSalePrice[target])
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien giao dich ($%s).", number_format(DDSalePrice[target]));
				return 1;
			}
			fine = CalculatePercentage(DDSalePrice[target], 10, 1000000);
			if(GetPlayerCash(target) < fine)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "%s khong du tien tra phi chuyen nhuong ($%s).", GetPlayerNameEx(target), number_format(fine));
				return 1;
			}
			stop DDSaleTimer[target];
			DDSalePendingAdmin[target] = true;
			DDSalePendingPlayer[target] = false;
			SendClientMessageEx(playerid, COLOR_GREEN, "Ban nhan de nghi ban Dynamic Door cua %s voi gia $%s.", GetPlayerNameEx(target), number_format(DDSalePrice[target]));
			SendClientMessageEx(playerid, COLOR_GREEN, "Admin se xem xet yeu cau truoc khi xu ly.");
			SendClientMessageEx(target, COLOR_GREEN, "%s nhan de nghi ban Dynamic Door gia $%s cua ban.", GetPlayerNameEx(playerid), number_format(DDSalePrice[target]));
			SendClientMessageEx(target, COLOR_GREEN, "Admin se xem xet yeu cau truoc khi xu ly.");
			format(string, sizeof(string), "[New Dynamic Door Sale Request]: (ID: %d) %s.", target, GetPlayerNameEx(target));
			ABroadCast(COLOR_LIGHTRED, string, 4);
			return 1;
		}
		else if(strcmp(params, "renderaid", true) == 0)
		{
			if(!GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o trang thai bi thuong.");
			if(!GetPVarType(playerid, "renderaid")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chua ai de nghi so cuu cho ban!");
			new target = GetPVarInt(playerid, "renderaid");
			if(!Offer_IsCurrent(playerid, target, "RenderAidSession")) return SendClientMessageEx(playerid, COLOR_GREY, "De nghi so cuu da het han.");
			if(!IsPlayerConnected(target)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi de nghi so cuu da offline.");
			new Float:pos[3];
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			if(!IsPlayerInRangeOfPoint(target, 5.0, pos[0], pos[1], pos[2])) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan nguoi de nghi so cuu.");
			if(GetPVarInt(target, "MedVestKit") != 1)
				return SendClientMessageEx(target, COLOR_GRAD2, "Ban khong mang tui cuu thuong."), SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do khong con tui cuu thuong de giup ban.");
			ApplyAnimation(target, "BOMBER", "BOM_Plant", 4.0, false, false, false, false, 0, 1);
			SetHealth(playerid, 100);
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s so cuu cho %s.", GetPlayerNameEx(target), GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			DeletePVar(playerid, "renderaid");
			DeletePVar(target, "MedVestKit");
		}
		else if(strcmp(params, "weapon", true) == 0)
		{
			return ArmsDealer_Accept(playerid);
		}
        else if(strcmp(params, "valentine", true) == 0)
		{
	        if (!GetPVarType(playerid, "kissvaloffer")) {
       	 		return SendClientMessageEx(playerid, COLOR_GREY, "Chua ai de nghi valentine cho ban!");
			}
			if(!Offer_IsCurrent(playerid, GetPVarInt(playerid, "kissvaloffer"), "ValentineOfferSession")) {
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay da het han.");
			}
			if (GetPVarInt(playerid,"kissvalsqlid") != GetPlayerSQLId(GetPVarInt(playerid, "kissvaloffer"))) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi moi da ngat ket noi.");
			}
			new Float: ppFloats[3], targetid;
			targetid = GetPVarInt(playerid, "kissvaloffer");
			GetPlayerPos(targetid, ppFloats[0], ppFloats[1], ppFloats[2]);

			if(!IsPlayerInRangeOfPoint(playerid, 2, ppFloats[0], ppFloats[1], ppFloats[2]) || Spectating[targetid] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban o qua xa!");
				DeletePVar(playerid, "kissvaloffer");
	      		DeletePVar(playerid, "kissvalsqlid");
				DeletePVar(targetid, "kissvalstyle");
				return 1;
			}
			if(PlayerInfo[playerid][pGiftTime] > 0)
			{
				format(string, sizeof(string),"Vat pham: Reset Gift Timer\nCredits cua ban: %s\nGia: {FFD700}%s{A9C4E4}\nCredits con lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[17][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[17][sItemPrice]));
				ShowPlayerDialogEx( playerid, DIALOG_SHOPGIFTRESET, DIALOG_STYLE_MSGBOX, "Dat lai thoi gian qua", string, "Mua", "Thoat" );
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da nhan qua trong 5 gio qua!");
				SendClientMessageEx(targetid, COLOR_GRAD2, "Nguoi ban moi valentine khong the chap nhan.");
				DeletePVar(playerid, "kissvaloffer");
	      		DeletePVar(playerid, "kissvalsqlid");
				DeletePVar(targetid, "kissvalstyle");
				return 1;
			}
			else if(PlayerInfo[targetid][pGiftTime] > 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do da nhan qua trong 5 gio qua!");
				DeletePVar(playerid, "kissvaloffer");
	      		DeletePVar(playerid, "kissvalsqlid");
				DeletePVar(targetid, "kissvalstyle");
				return 1;
			}
			ClearAnimationsEx(playerid);
			ClearAnimationsEx(targetid);
			PlayerFacePlayer( playerid, targetid );
			switch(GetPVarInt(targetid,"kissvalstyle")) {
				case 1:
				{
					ApplyAnimation( playerid, "KISSING", "Playa_Kiss_01", 4.1, false, false, false, false, 0, 1);
					ApplyAnimation( targetid, "KISSING", "Playa_Kiss_01", 4.1, false, false, false, false, 0, 1);
				}
				case 2:
				{
					ApplyAnimation( playerid, "KISSING", "Playa_Kiss_02", 4.1, false, false, false, false, 0, 1);
					ApplyAnimation( targetid, "KISSING", "Playa_Kiss_02", 4.1, false, false, false, false, 0, 1);
				}
				case 3:
				{
					ApplyAnimation( playerid, "KISSING", "Playa_Kiss_03", 4.1, false, false, false, false, 0, 1);
					ApplyAnimation( targetid, "KISSING", "Playa_Kiss_03", 4.1, false, false, false, false, 0, 1);
				}
				case 4:
				{
					ApplyAnimation( playerid, "KISSING", "Grlfrd_Kiss_01", 4.1, false, false, false, false, 0, 1);
					ApplyAnimation( targetid, "KISSING", "Grlfrd_Kiss_01", 4.1, false, false, false, false, 0, 1);
				}
				case 5:
				{
					ApplyAnimation( playerid, "KISSING", "Grlfrd_Kiss_02", 4.1, false, false, false, false, 0, 1);
					ApplyAnimation( targetid, "KISSING", "Grlfrd_Kiss_02", 4.1, false, false, false, false, 0, 1);
				}
				case 6:
				{
					ApplyAnimation( playerid, "KISSING", "Grlfrd_Kiss_03", 4.1, false, false, false, false, 0, 1);
					ApplyAnimation( targetid, "KISSING", "Grlfrd_Kiss_03", 4.1, false, false, false, false, 0, 1);
				}
			}
			format(string, sizeof(string), "* %s hon %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			GiftPlayer(MAX_PLAYERS, playerid);
			GiftPlayer(MAX_PLAYERS, targetid);
   			DeletePVar(playerid, "kissvaloffer");
      		DeletePVar(playerid, "kissvalsqlid");
			DeletePVar(targetid, "kissvalstyle");
   		}
		else if(strcmp(params, "business", true) == 0)
		{
	        if (!GetPVarType(playerid, "Business_Inviter")) {
       	 		return SendClientMessageEx(playerid, COLOR_GREY, "Chua ai moi ban gia nhap doanh nghiep!");
			}
			if(!Offer_IsCurrent(playerid, GetPVarInt(playerid, "Business_Inviter"), "BusinessInviteSession")) {
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay da het han.");
			}
            if (PlayerInfo[playerid][pBusiness] != INVALID_BUSINESS_ID) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban da thuoc doanh nghiep khac. Can nghi viec truoc khi nhan loi moi.");
			}
			if (GetPVarInt(playerid,"Business_InviterSQLId") != GetPlayerSQLId(GetPVarInt(playerid, "Business_Inviter"))) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi moi da ngat ket noi.");
			}
			PlayerInfo[playerid][pBusiness] = GetPVarInt(playerid, "Business_Invited");
			PlayerInfo[playerid][pBusinessRank] = 0;
            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan loi moi vao %s tu %s.", Businesses[GetPVarInt(playerid, "Business_Invited")][bName], GetPlayerNameEx(GetPVarInt(playerid, "Business_Inviter")));
            SendClientMessageEx(GetPVarInt(playerid, "Business_Inviter"), COLOR_LIGHTBLUE, "* %s da nhan loi moi va gia nhap %s", GetPlayerNameEx(playerid),Businesses[GetPVarInt(playerid, "Business_Invited")][bName]);
			format(string, sizeof(string), "%s(%d) has accepted %s's(%d) invite to join %s", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(GetPVarInt(playerid, "Business_Inviter")), GetPlayerSQLId(GetPVarInt(playerid, "Business_Inviter")), Businesses[GetPVarInt(playerid, "Business_Invited")][bName]);
			Log("logs/business.log", string);
   			DeletePVar(playerid, "Business_Inviter");
      		DeletePVar(playerid, "Business_Invited");
   		}
        else if(strcmp(params, "gun", true) == 0)
		{
			if (!GetPVarType(playerid, "Business_WeapOfferer"))	{
		        return SendClientMessageEx(playerid, COLOR_GREY, "Chua ai chao ban vu khi cho ban!");
			}
		    if(!Offer_IsCurrent(playerid, GetPVarInt(playerid, "Business_WeapOfferer"), "BusinessGunSession")) return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay da het han.");
			new offerer = GetPVarInt(playerid, "Business_WeapOfferer"), business = PlayerInfo[offerer][pBusiness];
			if (GetPlayerSQLId(offerer) != GetPVarInt(playerid, "Business_WeapOffererSQLId")) {
   				return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi chao ban da ngat ket noi!");
			}
            if(!ProxDetectorS(5.0, playerid, offerer)) {
       	        SendClientMessageEx(playerid, COLOR_GREY, "Nguoi ban khong o gan ban!");
       	        return 1;
            }
		    if(GetPVarType(playerid, "IsInArena")) {
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay khi dang o dau truong!");
				return 1;
			}
		    if (GetPlayerCash(playerid) < GetPVarInt(playerid, "Business_WeapPrice")) {
			    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua vu khi");
			    return 1;
		    }
		    if (Businesses[business][bInventory] < GetWeaponParam(GetPVarInt(playerid, "Business_WeapType"), WeaponMats)) {
				SendClientMessage(playerid, COLOR_GRAD2, "Cua hang da het vat lieu");
				return 1;
		    }
			if(GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen")) {
   				SendClientMessage(playerid, COLOR_GRAD2, "Ban chua the lam viec nay!");
   				return 1;
			}

		    Businesses[business][bTotalSales]++;
		    Businesses[business][bLevelProgress]++;
		    Businesses[business][bSafeBalance] += TaxSale(GetPVarInt(playerid, "Business_WeapPrice"));
  			GivePlayerCash(playerid, -GetPVarInt(playerid, "Business_WeapPrice"));
		    Businesses[business][bInventory] -= GetWeaponParam(GetPVarInt(playerid, "Business_WeapType"), WeaponMats);
		    SaveBusiness(business);

            SendClientMessageEx(offerer, COLOR_GRAD1, "Ban da ban cho %s mot %s.", GetPlayerNameEx(playerid),Weapon_ReturnName(GetPVarInt(playerid, "Business_WeapType")));
            SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da nhan %s tu %s.", Weapon_ReturnName(GetPVarInt(playerid, "Business_WeapType")), GetPlayerNameEx(offerer));
            PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
            PlayerPlaySound(offerer, 1052, 0.0, 0.0, 0.0);
            format(string, sizeof(string), "* %s che tao sung tu vat lieu va ban cho %s.", GetPlayerNameEx(offerer), GetPlayerNameEx(playerid));
            ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            GivePlayerValidWeapon(playerid,GetPVarInt(playerid, "Business_WeapType"));

			format(string, sizeof(string), "%s %s(%d) (IP: %s) has sold a %s to %s(%d) (IP: %s) for $%d in %s (%d)", GetBusinessRankName(PlayerInfo[offerer][pBusinessRank]), GetPlayerNameEx(offerer), GetPlayerSQLId(offerer), GetPlayerIpEx(offerer), Weapon_ReturnName(GetPVarInt(playerid, "Business_WeapType")), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPVarInt(playerid, "Business_WeapPrice"), Businesses[business][bName], business);
			Log("logs/business.log", string);

  		    DeletePVar(playerid, "Business_WeapPrice");
		    DeletePVar(playerid, "Business_WeapType");
		    DeletePVar(playerid, "Business_WeapOfferer");
		    DeletePVar(playerid, "Business_WeapOffererSQLId");
		}

        else if(strcmp(params, "item", true) == 0) {

			if (!GetPVarType(playerid, "Business_ItemOfferer")) {
		        SendClientMessageEx(playerid, COLOR_GREY, "Chua ai chao ban vat pham cho ban!");
		        return 1;
			}

		    if(!Offer_IsCurrent(playerid, GetPVarInt(playerid, "Business_ItemOfferer"), "BusinessItemSession")) {
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay da het han.");
			}

			new offerer = GetPVarInt(playerid, "Business_ItemOfferer");
		    new item = GetPVarInt(playerid, "Business_ItemType");
		    new price = GetPVarInt(playerid, "Business_ItemPrice");
			new business = InBusiness(playerid);

			if (business == INVALID_BUSINESS_ID)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "Ban khong o noi that doanh nghiep");
   				return 1;
			}
			if (GetPlayerSQLId(offerer) != GetPVarInt(playerid, "Business_ItemOffererSQLId")) {
   				SendClientMessage(playerid, COLOR_GRAD2, "Nguoi chao ban da ngat ket noi!");
   				return 1;
			}
		    if (GetPlayerCash(playerid) < price) {
			    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua vat pham!");
			    return 1;
		    }
			if (!Businesses[business][bItemPrices][item]) {
			    SendClientMessageEx(playerid, COLOR_GRAD4, "Vat pham khong con duoc ban.");
			    return 1;
			}
		 	if (Businesses[business][bInventory] < 1) {
	   	 		SendClientMessageEx(playerid, COLOR_GRAD2, "Cua hang da het vat pham!");
	   	 		return 1;
			}
			if (GetPVarInt(playerid, "Business_ItemPrice") != Businesses[business][bItemPrices][item]) {
			    SendClientMessageEx(playerid, COLOR_GRAD4, "Khong the mua vi gia vat pham da doi.");
			    return 1;
			}

			if(item == ITEM_ILOCK || item == ITEM_SCALARM || item == ITEM_ELOCK)
   			{
      			if(Businesses[business][bInventory] >= StoreItemCost[item][ItemValue])
	        	{

					SetPVarInt(playerid, "lockcost", price);
     				SetPVarInt(playerid, "businessid", business);
	        		SetPVarInt(playerid, "item", item);
		        	SetPVarInt(playerid, "playersold", item);
			        GivePlayerStoreItem(playerid, 1, business, item+1, price);
				}
				else return SendClientMessageEx(playerid, COLOR_GRAD2, "Cua hang khong du hang ton de ban vat pham nay!");
    		}
  			else GivePlayerStoreItem(playerid, 1, business, item+1, price);
		}


        else if(strcmp(params, "vehicle", true) == 0) {

		    new offerer = GetPVarInt(playerid, "Business_VehicleOfferer");
		    new price = GetPVarInt(playerid, "Business_VehiclePrice");
		    new slot = GetPVarInt(playerid, "Business_VehicleSlot");
		    new businessid = PlayerInfo[offerer][pBusiness];

			if (!GetPVarType(playerid, "Business_VehicleOfferer")) {
		        SendClientMessageEx(playerid, COLOR_GREY, "Chua ai chao ban xe cho ban!");
		        return 1;
			}

			if (GetPlayerSQLId(offerer) != GetPVarInt(playerid, "Business_VehicleOffererSQLId")) {
   				SendClientMessage(playerid, COLOR_GRAD2, "Nguoi chao ban da ngat ket noi!");
   				return 1;
			}
		    if (GetPlayerCash(playerid) < price) {
			    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua xe!");
			    return 1;
		    }

            new playervehicleid = GetPlayerFreeVehicleId(playerid);

			if(!vehicleCountCheck(playerid)) {
				return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong the so huu them xe.");
			}
			if(!vehicleSpawnCountCheck(playerid)) {
				return SendClientMessage(playerid, COLOR_GRAD2, "Qua nhieu xe dang duoc lay ra, hay cat bot truoc.");
			}
            PlayerVehicleInfo[playerid][playervehicleid][pvId] = Businesses[businessid][bVehID][slot];
            PlayerVehicleInfo[playerid][playervehicleid][pvModelId] = Businesses[businessid][bModel][slot];
            PlayerVehicleInfo[playerid][playervehicleid][pvPosX] = Businesses[businessid][bParkPosX][slot];
            PlayerVehicleInfo[playerid][playervehicleid][pvPosY] = Businesses[businessid][bParkPosY][slot];
            PlayerVehicleInfo[playerid][playervehicleid][pvPosZ] = Businesses[businessid][bParkPosZ][slot];
            PlayerVehicleInfo[playerid][playervehicleid][pvPosAngle] = Businesses[businessid][bParkAngle][slot];
            PlayerVehicleInfo[playerid][playervehicleid][pvSpawned] = 1;
            Businesses[businessid][DealershipVehStock][slot] = 0;
            VehicleSpawned[playerid]++;

		    g_mysql_SaveVehicle(playerid, playervehicleid);

    		Businesses[businessid][bSafeBalance] += TaxSale(GetPVarInt(playerid, "Business_ItemPrice"));
			GivePlayerCash(playerid, -GetPVarInt(playerid, "Business_VehiclePrice"));
			if (PlayerInfo[playerid][pBusiness] != PlayerInfo[offerer][pBusiness]) Businesses[businessid][bLevelProgress]++;
			SaveBusiness(businessid);
			OnPlayerStatsUpdate(playerid);
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

			DeletePVar(playerid, "Business_VehiclePrice");
			DeletePVar(playerid, "Business_VehicleOfferer");
			DeletePVar(playerid, "Business_VehicleOffererSQLId");
			DeletePVar(playerid, "Business_VehicleSlot");
        }
        else if(strcmp(params, "death", true) == 0) {
            if(GetPVarInt(playerid, "Injured") == 1) {

            	if(GetPVarInt(playerid, "InjuredWait") > gettime())
            		return SendClientMessageEx(playerid, COLOR_GRAD2, "Hay cho 5 giay truoc khi chap nhan cai chet.");

                SendClientMessageEx(playerid, COLOR_WHITE, "Ban bo cuoc va bat tinh, duoc dua ngay den benh vien.");
                KillEMSQueue(playerid);
                ResetPlayerWeaponsEx(playerid);
                SpawnPlayer(playerid);
            }
            else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong bi thuong, chua the lam vay!");
        }
        else if(strcmp(params, "car", true) == 0) {
			new sellerid = VehicleOffer[playerid], slot = VehicleId[playerid], price = VehiclePrice[playerid];
			if(!Offer_IsCurrent(playerid, sellerid, "VehicleOfferSession"))
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co de nghi mua xe hien tai.");
			
			if(!(0 <= slot < MAX_PLAYERVEHICLES)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Xe duoc chao ban khong con kha dung.");
			
			new sqlid = GetPVarInt(playerid, "VehicleOfferSQLId");
			if(sqlid <= 0 || PlayerVehicleInfo[sellerid][slot][pvSlotId] != sqlid)
				return SendClientMessageEx(playerid, COLOR_GREY, "Xe duoc chao ban da thay doi.");
			
			new vehicleid = PlayerVehicleInfo[sellerid][slot][pvId];
			if(!IsValidVehicle(vehicleid) || !IsPlayerInVehicle(sellerid, vehicleid))
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi ban phai o trong xe duoc chao ban.");
			
			if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(sellerid) || GetPlayerInterior(playerid) != GetPlayerInterior(sellerid)) return 1;
			new Float:x, Float:y, Float:z;
			GetPlayerPos(sellerid, x, y, z);
			if(!IsPlayerInRangeOfPoint(playerid, 8.0, x, y, z)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nguoi ban.");
			
			if(PlayerInfo[playerid][pLevel] < 2 || PlayerInfo[sellerid][pLevel] < 2) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Ca hai phai dat cap 2 de mua ban xe.");
			
			new Float:health;
			GetVehicleHealth(vehicleid, health);
			if(health < 500.0) return SendClientMessageEx(playerid, COLOR_GREY, "Xe qua hong de ban.");
			if(PlayerInfo[playerid][pFreezeCar] || PlayerInfo[sellerid][pFreezeCar]) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Tai san xe dang bi dong bang.");
			
			if(PlayerVehicleInfo[sellerid][slot][pvBeingPickLocked] || PlayerVehicleInfo[sellerid][slot][pvTicket] > 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Luc nay khong the ban xe nay.");
			
			if(!vehicleCountCheck(playerid) || !vehicleSpawnCountCheck(playerid)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Khong the so huu hoac lay them xe ra.");
			
			new targetslot = GetPlayerFreeVehicleId(playerid);
			if(!(0 <= targetslot < MAX_PLAYERVEHICLES)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong con o chua xe trong.");
			
			if(price <= 0 || GetPlayerCash(playerid) < price) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua xe nay.");
			
			new fine;
			if(IsWeaponizedVehicle(PlayerVehicleInfo[sellerid][slot][pvModelId])) fine = (price / 100) * 15;
			if(GetPlayerCash(sellerid) > cellmax - (price - fine)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi ban khong the nhan so tien nay.");
			
			if(!gAccountsInnoDB || !gVehiclesInnoDB || gPropertySaleUncertain[0] || mysql_unprocessed_queries(MainPipeline))
				return SendClientMessageEx(playerid, COLOR_GREY, "Du lieu xe chua san sang hoac dang ban. Hay thu lai.");
			
			new buyer = GetPlayerSQLId(playerid), seller = GetPlayerSQLId(sellerid);
			if(buyer <= 0 || seller <= 0 || buyer == seller) return 1;
			new cash = GetPlayerCash(playerid) - price, proceeds = GetPlayerCash(sellerid) + (price - fine);
			new query[2048], verification[512];
			new backpack[160];
			if(PlayerInfo[sellerid][pBackpack] > 0 && PlayerInfo[sellerid][pBStoredV] == sqlid) format(backpack, sizeof(backpack), ",s.`Backpack`=0,s.`BEquipped`=0,s.`BStoredH`=%d,s.`BStoredV`=%d", INVALID_HOUSE_ID, INVALID_PLAYER_VEHICLE_ID);
			mysql_format(MainPipeline, query, sizeof(query), "UPDATE `vehicles` v JOIN `accounts` b ON b.`id`=%d JOIN `accounts` s ON s.`id`=%d SET v.`sqlID`=%d,b.`Money`=%d,s.`Money`=%d%s,v.`pvWeapon0`=0,v.`pvWeapon1`=0,v.`pvWeapon2`=0,v.`pvPlate`='',v.`pvTicket`=0 WHERE v.`id`=%d AND v.`sqlID`=%d", buyer, seller, buyer, cash, proceeds, backpack, sqlid, seller);
			mysql_format(MainPipeline, verification, sizeof(verification), "SELECT v.`sqlID` AS owner,(v.`sqlID`=%d AND b.`Money`=%d AND s.`Money`=%d) AS committed FROM `vehicles` v JOIN `accounts` b ON b.`id`=%d JOIN `accounts` s ON s.`id`=%d WHERE v.`id`=%d", buyer, cash, proceeds, buyer, seller, sqlid);
			if(PropertySale_Commit(playerid, sellerid, query, verification) != 1)
				return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich xe chua duoc xac nhan.");

			format(szMessage, sizeof(szMessage), "[CARSALE] %s(%d) bought vehicle %d from %s(%d) for $%d.", GetPlayerNameEx(playerid), buyer, sqlid, GetPlayerNameEx(sellerid), seller, price);
			Log("logs/pay.log", szMessage);
			if(PlayerInfo[sellerid][pBackpack] > 0 && PlayerInfo[sellerid][pBStoredV] == sqlid) {
				PlayerInfo[sellerid][pBackpack] = 0;
				PlayerInfo[sellerid][pBEquipped] = 0;
				PlayerInfo[sellerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
				PlayerInfo[sellerid][pBStoredH] = INVALID_HOUSE_ID;
				SendClientMessageEx(sellerid, COLOR_WHITE, "Ban mat ba lo vi khong lay no ra.");
			}
			new keyholder = PlayerVehicleInfo[sellerid][slot][pvAllowedPlayerId];
			if(0 <= keyholder < MAX_PLAYERS && PlayerInfo[keyholder][pVehicleKeysFrom] == sellerid && PlayerInfo[keyholder][pVehicleKeys] == slot) {
				PlayerInfo[keyholder][pVehicleKeysFrom] = INVALID_PLAYER_ID;
				PlayerInfo[keyholder][pVehicleKeys] = INVALID_PLAYER_VEHICLE_ID;
			}
			PlayerVehicleInfo[playerid][targetslot] = PlayerVehicleInfo[sellerid][slot];
			PlayerVehicleInfo[playerid][targetslot][pvAllowedPlayerId] = INVALID_PLAYER_ID;
			PlayerVehicleInfo[playerid][targetslot][pvWeapons][0] = 0;
			PlayerVehicleInfo[playerid][targetslot][pvWeapons][1] = 0;
			PlayerVehicleInfo[playerid][targetslot][pvWeapons][2] = 0;
			PlayerVehicleInfo[playerid][targetslot][pvPlate][0] = EOS;
			PlayerVehicleInfo[playerid][targetslot][pvTicket] = 0;
			PlayerVehicleInfo[playerid][targetslot][pvAlarmTriggered] = 0;
			PlayerVehicleInfo[playerid][targetslot][pvBeingPickLockedBy] = INVALID_PLAYER_ID;
			PlayerVehicleInfo[playerid][targetslot][pvLastLockPickedBy][0] = EOS;
			new empty[pvInfo];
			PlayerVehicleInfo[sellerid][slot] = empty;
			PlayerVehicleInfo[sellerid][slot][pvAllowedPlayerId] = INVALID_PLAYER_ID;
			PlayerVehicleInfo[sellerid][slot][pvPaintJob] = -1;
			VehicleSpawned[playerid]++;
			VehicleSpawned[sellerid]--;
			PlayerInfo[playerid][pCash] = cash;
			PlayerInfo[sellerid][pCash] = proceeds;
			RemovePlayerFromVehicle(sellerid);
			SetPlayerPos(sellerid, x, y, z + 2.0);
			foreach(new i: Player) {
				if(VehicleOffer[i] == sellerid && GetPVarInt(i, "VehicleOfferSQLId") == sqlid) {
					VehicleOffer[i] = INVALID_PLAYER_ID;
					VehiclePrice[i] = 0;
					VehicleId[i] = -1;
					DeletePVar(i, "VehicleOfferSession");
					DeletePVar(i, "VehicleOfferSQLId");
				}
			}
			DeletePVar(sellerid, "WepVehSalePlayer");
			DeletePVar(sellerid, "WepVehSaleVehicle");
			DeletePVar(sellerid, "WepVehSalePrice");
			DeletePVar(sellerid, "WepVehSaleFine");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban mua xe voi gia $%s.", number_format(price));
			SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "Ban xe voi gia $%s. Phi ban: $%s.", number_format(price), number_format(fine));
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			return 1;
        }
        else if(strcmp(params, "house", true) == 0) {
			new sellerid = HouseOffer[playerid], houseid = House[playerid], price = HousePrice[playerid];
			if(!Offer_IsCurrent(playerid, sellerid, "HouseOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co de nghi mua nha hien tai.");
			
			if(!(0 <= houseid < MAX_HOUSES)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Nha duoc chao ban khong hop le.");
			
			new buyer = GetPlayerSQLId(playerid), seller = GetPlayerSQLId(sellerid);
			if(buyer <= 0 || seller <= 0 || buyer == seller || HouseInfo[houseid][hOwnerID] != seller || !HouseInfo[houseid][hOwned])
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi ban khong con so huu nha nay.");
			
			if(PlayerInfo[playerid][pFreezeHouse] || PlayerInfo[sellerid][pFreezeHouse]) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Tai san nha dang bi dong bang.");
			
			if((Homes[playerid] >= MAX_OWNABLE_HOUSES && PlayerInfo[playerid][pDonateRank] < 4) || Homes[playerid] >= 3)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the so huu them nha.");
			
			if(PlayerInfo[playerid][pLevel] < HouseInfo[houseid][hLevel]) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Cap cua ban chua du de mua nha nay.");
			
			new Float:x, Float:y, Float:z;
			GetPlayerPos(sellerid, x, y, z);
			if(GetPlayerVirtualWorld(playerid) != HouseInfo[houseid][hExtVW] || GetPlayerInterior(playerid) != HouseInfo[houseid][hExtIW]
				|| GetPlayerVirtualWorld(sellerid) != HouseInfo[houseid][hExtVW] || GetPlayerInterior(sellerid) != HouseInfo[houseid][hExtIW]
				|| !IsPlayerInRangeOfPoint(sellerid, 3.0, HouseInfo[houseid][hExteriorX], HouseInfo[houseid][hExteriorY], HouseInfo[houseid][hExteriorZ])
				|| !IsPlayerInRangeOfPoint(playerid, 8.0, x, y, z)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban va nguoi ban phai o gan cua nha.");
			if(price <= 0 || GetPlayerCash(playerid) < price) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua nha nay.");
			if(GetPlayerCash(sellerid) > cellmax - price) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi ban khong the nhan so tien nay.");
			new pInfo:keys[] = {pPhousekey, pPhousekey2, pPhousekey3};
			new source = -1, destination = -1;
			static const columns[][] = {"Apartment", "Apartment2", "Apartment3"};
			for(new i; i < sizeof(keys); ++i) {
				if(PlayerInfo[sellerid][keys[i]] == houseid) source = i;
				if(destination == -1 && PlayerInfo[playerid][keys[i]] == INVALID_HOUSE_ID && (i < 2 || PlayerInfo[playerid][pDonateRank] >= 4)) destination = i;
			}
			if(source == -1 || destination == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Khong con o nha hop le cho giao dich nay.");
			if(!gAccountsInnoDB || !gHousesInnoDB || gPropertySaleUncertain[0] || gHouseSaleUncertain[houseid] || mysql_unprocessed_queries(MainPipeline))
				return SendClientMessageEx(playerid, COLOR_GREY, "Du lieu nha chua san sang hoac dang ban. Hay thu lai.");
			new cash = GetPlayerCash(playerid) - price, proceeds = GetPlayerCash(sellerid) + price;
			new query[2048], verification[768];
			new backpack[160];
			if(PlayerInfo[sellerid][pBackpack] > 0 && PlayerInfo[sellerid][pBStoredH] == HouseInfo[houseid][hSQLId]) format(backpack, sizeof(backpack), ",s.`Backpack`=0,s.`BEquipped`=0,s.`BStoredH`=%d,s.`BStoredV`=%d", INVALID_HOUSE_ID, INVALID_PLAYER_VEHICLE_ID);
			mysql_format(MainPipeline, query, sizeof(query), "UPDATE `houses` h JOIN `accounts` b ON b.`id`=%d JOIN `accounts` s ON s.`id`=%d SET h.`OwnerID`=%d,h.`OwnerName`='%e',h.`Owned`=1,h.`Lock`=1,h.`SafeMoney`=0,h.`Pot`=0,h.`Crack`=0,h.`Materials`=0,h.`Heroin`=0,h.`Weapons0`=0,h.`Weapons1`=0,h.`Weapons2`=0,h.`Weapons3`=0,h.`Weapons4`=0,h.`GLUpgrade`=1,h.`ClosetX`=0,h.`ClosetY`=0,h.`ClosetZ`=0,h.`SignDesc`='None',h.`SignX`=0,h.`SignY`=0,h.`SignZ`=0,h.`SignA`=0,h.`SignExpire`=0,b.`Money`=%d,s.`Money`=%d,b.`%s`=%d,s.`%s`=-1%s WHERE h.`id`=%d AND h.`OwnerID`=%d", buyer, seller, buyer, GetPlayerNameEx(playerid), cash, proceeds, columns[destination], houseid, columns[source], backpack, houseid + 1, seller);
			mysql_format(MainPipeline, verification, sizeof(verification), "SELECT h.`OwnerID` AS owner,(h.`OwnerID`=%d AND b.`Money`=%d AND s.`Money`=%d AND b.`%s`=%d AND s.`%s`=-1) AS committed FROM `houses` h JOIN `accounts` b ON b.`id`=%d JOIN `accounts` s ON s.`id`=%d WHERE h.`id`=%d", buyer, cash, proceeds, columns[destination], houseid, columns[source], buyer, seller, houseid + 1);
			if(PropertySale_Commit(playerid, sellerid, query, verification, houseid) != 1)
				return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich nha chua duoc xac nhan.");
			if(PlayerInfo[sellerid][pBackpack] > 0 && PlayerInfo[sellerid][pBStoredH] == HouseInfo[houseid][hSQLId]) {
				PlayerInfo[sellerid][pBackpack] = 0;
				PlayerInfo[sellerid][pBEquipped] = 0;
				PlayerInfo[sellerid][pBStoredH] = INVALID_HOUSE_ID;
				PlayerInfo[sellerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
				SendClientMessageEx(sellerid, COLOR_WHITE, "Ban mat ba lo vi khong lay no ra.");
			}
			ClearHouse(houseid);
			HouseInfo[houseid][hLock] = 1;
			HouseInfo[houseid][hOwnerID] = buyer;
			HouseInfo[houseid][hOwned] = 1;
			GetPlayerName(playerid, HouseInfo[houseid][hOwnerName], MAX_PLAYER_NAME);
			PlayerInfo[sellerid][keys[source]] = INVALID_HOUSE_ID;
			PlayerInfo[playerid][keys[destination]] = houseid;
			Homes[sellerid]--;
			Homes[playerid]++;
			PlayerInfo[playerid][pCash] = cash;
			PlayerInfo[sellerid][pCash] = proceeds;
			ReloadHouseText(houseid);
			foreach(new i: Player) {
				if(HouseOffer[i] == sellerid && House[i] == houseid) {
					HouseOffer[i] = INVALID_PLAYER_ID;
					HousePrice[i] = 0;
					House[i] = INVALID_HOUSE_ID;
					DeletePVar(i, "HouseOfferSession");
				}
			}
			format(szMessage, sizeof(szMessage), "%s(%d) sold house %d to %s(%d) for $%d.", GetPlayerNameEx(sellerid), seller, houseid, GetPlayerNameEx(playerid), buyer, price);
			Log("logs/house.log", szMessage);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Chuc mung ban co nha moi.");
			SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "Ban da ban nha voi gia $%s.", number_format(price));
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			return 1;
        }
        else if(strcmp(params, "handshake", true) == 0) {
            new
                Count;

            foreach(new i: Player)
			{
				if(GetPVarType(i, "shrequest") && GetPVarInt(i, "shrequest") == playerid && GetPVarInt(i, "HandshakeTargetSession") == g_arrQueryHandle[playerid]) {
					new
						Float: ppFloats[3];

					GetPlayerPos(i, ppFloats[0], ppFloats[1], ppFloats[2]);

					if(!IsPlayerInRangeOfPoint(playerid, 5, ppFloats[0], ppFloats[1], ppFloats[2]) || Spectating[i] > 0) {
						Count++;
						SendClientMessageEx(playerid, COLOR_WHITE, "Ban o qua xa, chua the chap nhan bat tay.");
					}
					else {
						switch(GetPVarInt(i, "shstyle")) {
							case 1:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS", "hndshkaa", 4.0, true, true, true, false, 1000 );
								ApplyAnimation( i, "GANGS", "hndshkaa", 4.0, true, true, true, false, 1000 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
							case 2:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS", "hndshkba", 4.0, true, true, true, false, 1000 );
								ApplyAnimation( i, "GANGS", "hndshkba", 4.0, true, true, true, false, 1000 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
							case 3:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS", "hndshkca", 4.0, true, true, true, false, 1000 );
								ApplyAnimation( i, "GANGS", "hndshkca", 4.0, true, true, true, false, 1000 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
							case 4:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS", "hndshkcb", 4.0, true, true, true, false, 1000 );
								ApplyAnimation( i, "GANGS", "hndshkca", 4.0, true, true, true, false, 1000 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
							case 5:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS", "hndshkda", 4.0, true, true, true, false, 1000 );
								ApplyAnimation( i, "GANGS", "hndshkca", 4.0, true, true, true, false, 1000 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
							case 6:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS","hndshkfa_swt", 4.0, true, true, true, false, 2600 );
								ApplyAnimation( i, "GANGS","hndshkfa_swt", 4.0, true, true, true, false, 2600 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
							case 7:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS", "prtial_hndshk_01", 4.0, true, true, true, false, 1250 );
								ApplyAnimation( i, "GANGS", "prtial_hndshk_01", 4.0, true, true, true, false, 1250 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
							case 8:
							{
								Count++;
								PlayerFacePlayer( playerid, i );
								ApplyAnimation( playerid, "GANGS", "prtial_hndshk_biz_01", 3.7, true, true, true, false, 2200 );
								ApplyAnimation( i, "GANGS", "prtial_hndshk_biz_01", 3.5, true, true, true, false, 2200 );
								DeletePVar(i, "shrequest");
								format(szMessage, sizeof(szMessage), "* %s bat tay voi %s.", GetPlayerNameEx(i), GetPlayerNameEx(playerid));
								ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								DeletePVar(i, "shstyle");
							}
						}
					}
				}
            }
            if(Count == 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co yeu cau bat tay dang cho.");
            return 1;
        }
		else if(strcmp(params, "rflteam",true) == 0) {
			if(!GetPVarType(playerid, "RFLTeam_Invite")) return SendClientMessageEx(playerid, COLOR_GREY, "Chua ai moi ban vao doi.");
			new team = GetPVarInt(playerid, "RFLTeam_Team");
			giveplayerid = GetPVarInt(playerid, "RFLTeam_Inviter");
			if(!Offer_IsCurrent(playerid, giveplayerid, "RFLInviteSession") || !(0 <= team < MAX_RFLTEAMS)) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Loi moi vao doi da het han.");
			
			DeletePVar(playerid, "RFLTeam_Invite");
			DeletePVar(playerid, "RFLTeam_Team");
			DeletePVar(playerid, "RFLTeam_Inviter");
			PlayerInfo[playerid][pRFLTeam] = team;
			RFLInfo[team][RFLmembers] +=1;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da vao doi cua %s. Co the dung /rflhelp.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s da nhan loi moi cua ban.", GetPlayerNameEx(playerid));
			if( GetPVarInt( playerid, "EventToken" ) == 1 ) {
				if( EventKernel[ EventStatus ] == 1 || EventKernel[ EventStatus ] == 2 ) {
					if(EventKernel[EventType] == 3) {
						new Float:X, Float:Y, Float:Z;
						GetPlayerPos( playerid, X, Y, Z );
						format(szMessage, sizeof(szMessage), "Doi: %s", RFLInfo[team][RFLname]);
						RFLTeamN3D[playerid] = CreateDynamic3DTextLabel(szMessage,0x008080FF,X,Y,Z,10.0,.attachedplayer = playerid, .worldid = GetPlayerVirtualWorld(playerid));
					}
				}
			}
			OnPlayerStatsUpdate(playerid);
			SaveRelayForLifeTeam(team);
		}
        else if(strcmp(params, "invite", true) == 0)
		{
			if(!Offer_IsCurrent(playerid, hInviteOffer[playerid], "hInviteOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
            
			if(hInviteOffer[playerid] != INVALID_PLAYER_ID)
			{
                if(IsPlayerConnected(hInviteOffer[playerid]))
				{
	                if(!(0 <= hInviteHouse[playerid] < MAX_HOUSES)) 
						return SendClientMessageEx(playerid, COLOR_GREY, "Loi moi den nha khong hop le.");
                    
					if(HouseInfo[hInviteHouse[playerid]][hOwnerID] != GetPlayerSQLId(hInviteOffer[playerid])) 
						return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi moi khong con so huu nha nay.");
	                
					if(CheckPointCheck(playerid)) 
						return SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
                    
                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan loi moi den nha cua %s, checkpoint da duoc dat tai nha ho.", GetPlayerNameEx(hInviteOffer[playerid]));
                    SendClientMessageEx(hInviteOffer[playerid], COLOR_LIGHTBLUE, "* %s nhan loi moi den nha cua ban.", GetPlayerNameEx(playerid));
					DisablePlayerCheckpoint(playerid);
                    SetPlayerCheckpoint(playerid, HouseInfo[hInviteHouse[playerid]][hExteriorX], HouseInfo[hInviteHouse[playerid]][hExteriorY], HouseInfo[hInviteHouse[playerid]][hExteriorZ], 4.0);
                    gPlayerCheckpointStatus[playerid] = CHECKPOINT_HOME;
					SetPVarInt(playerid, "hInviteHouse", hInviteHouse[playerid]);
                    hInviteOffer[playerid] = INVALID_PLAYER_ID;
					hInviteHouse[playerid] = INVALID_HOUSE_ID;
                    return 1;
                }
                else
				{
                    hInviteOffer[playerid] = INVALID_PLAYER_ID;
                    hInviteHouse[playerid] = INVALID_HOUSE_ID;
                    SendClientMessageEx(playerid, COLOR_GREY, "Nguoi moi ban den nha da ngat ket noi.");
                }
            }
            else return SendClientMessageEx(playerid, COLOR_GREY, "Chua ai moi ban den nha.");
            return 1;
        }
        /*else if(strcmp(params, "divorce", true) == 0) {
            if(DivorceOffer[playerid] != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(DivorceOffer[playerid])) {
                    if(ProxDetectorS(10.0, playerid, DivorceOffer[playerid])) {
                        GetPlayerName(DivorceOffer[playerid], giveplayer, sizeof(giveplayer));
                        GetPlayerName(playerid, sendername, sizeof(sendername));
                        format(szMessage, sizeof(szMessage), "* You have signed the divorce papers from %s, you are now single again.", giveplayer);
                        SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMessage);
                        format(szMessage, sizeof(szMessage), "* %s has signed the divorce papers, you are now single again.", sendername);
                        SendClientMessageEx(DivorceOffer[playerid], COLOR_LIGHTBLUE, szMessage);
                        ClearMarriage(playerid);
                        ClearMarriage(DivorceOffer[playerid]);
                        PlayerInfo[playerid][pPhousekey] = INVALID_HOUSE_ID;
                        return 1;
                    }
                    else {
                        SendClientMessageEx(playerid, COLOR_GREY, "   The person that sent you the Divorce Papers is not near you!");
                        return 1;
                    }
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Nobody sent you any divorce papers.");
                return 1;
            }
        }*/
        else if(strcmp(params, "group", true) == 0) {
            if(!GetPVarType(playerid, "Group_Inviter")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "Chua ai moi ban vao to chuc.");
            
			new inviter = GetPVarInt(playerid, "Group_Inviter");
            if(!Offer_IsCurrent(playerid, inviter, "GroupInviteSession") || !GetPVarType(inviter, "Group_Invited") || GetPVarInt(inviter, "Group_Invited") != playerid
                || GetPVarInt(inviter, "GroupTargetSession") != g_arrQueryHandle[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Loi moi vao to chuc da het han.");
            
			new group = PlayerInfo[inviter][pLeader], rank = PlayerInfo[inviter][pRank];
            if(!(0 <= group < MAX_GROUPS) || !(0 <= rank < MAX_GROUP_RANKS) || group != GetPVarInt(playerid, "GroupInviteID"))
                return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi moi khong con lanh dao to chuc nay.");
            
			if(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS || 0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS)
                return SendClientMessageEx(playerid, COLOR_GREY, "Ban da thuoc mot to chuc.");
            
			if(PlayerInfo[playerid][pCSFBanned] && (arrGroupData[group][g_iGroupType] == GROUP_TYPE_LEA || arrGroupData[group][g_iGroupType] == GROUP_TYPE_MEDIC))
                return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang bi cam vao to chuc cong vu.");
            
			PlayerInfo[playerid][pMember] = group;
            PlayerInfo[playerid][pRank] = 0;
            PlayerInfo[playerid][pDivision] = INVALID_DIVISION;
            strcpy(PlayerInfo[playerid][pBadge], "None", 9);
            arrGroupData[group][g_iMemberCount]++;
            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban nhan loi moi cua %s %s vao %s.", arrGroupRanks[group][rank], GetPlayerNameEx(inviter), arrGroupData[group][g_szGroupName]);
            SendClientMessageEx(inviter, COLOR_LIGHTBLUE, "%s nhan loi moi vao to chuc.", GetPlayerNameEx(playerid));
            format(szMessage, sizeof(szMessage), "%s (%d) accepted %s's (%d) invitation to group %d.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(inviter), GetPlayerSQLId(inviter), group + 1);
            GroupLog(group, szMessage);
            DeletePVar(playerid, "Group_Inviter");
            DeletePVar(playerid, "GroupInviteSession");
            DeletePVar(playerid, "GroupInviteID");
            DeletePVar(inviter, "Group_Invited");
            DeletePVar(inviter, "GroupTargetSession");
        }
        else if(strcmp(params, "witness", true) == 0) {
			if(!Offer_IsCurrent(playerid, MarryWitnessOffer[playerid], "MarryWitnessOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
            
			if(MarryWitnessOffer[playerid] != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(MarryWitnessOffer[playerid])) {
                    if(ProxDetectorS(10.0, playerid, MarryWitnessOffer[playerid])) {
                        GetPlayerName(MarryWitnessOffer[playerid], giveplayer, sizeof(giveplayer));
                        GetPlayerName(playerid, sendername, sizeof(sendername));
                        SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan yeu cau cua %s de lam chung le cuoi.", giveplayer);
                        SendClientMessageEx(MarryWitnessOffer[playerid], COLOR_LIGHTBLUE, "* %s nhan yeu cau lam chung le cuoi cua ban.", sendername);
                        MarryWitness[MarryWitnessOffer[playerid]] = playerid;
						SetPVarInt(MarryWitnessOffer[playerid], "MarriageWitnessSession", g_arrQueryHandle[playerid]);
                        MarryWitnessOffer[playerid] = INVALID_PLAYER_ID;
                        return 1;
                    }
                    else {
                        SendClientMessageEx(playerid, COLOR_GREY, "Nguoi moi lam chung le cuoi khong o gan ban!");
                        return 1;
                    }
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Chua ai moi ban lam chung le cuoi!");
                return 1;
            }
        }
        else if(strcmp(params, "marriage", true) == 0) {
			if(!Offer_IsCurrent(playerid, ProposeOffer[playerid], "ProposeOfferSession")) return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
            if(ProposeOffer[playerid] != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(ProposeOffer[playerid])) {
                    if(ProxDetectorS(10.0, playerid, ProposeOffer[playerid])) {
                        if(!Offer_IsCurrent(ProposeOffer[playerid], MarryWitness[ProposeOffer[playerid]], "MarriageWitnessSession")) {
                            SendClientMessageEx(playerid, COLOR_GREY, "Nguoi cau hon chua co nguoi lam chung!");
                            return 1;
                        }
                        if(IsPlayerConnected(MarryWitness[ProposeOffer[playerid]])) {
                            if(ProxDetectorS(12.0, ProposeOffer[playerid], MarryWitness[ProposeOffer[playerid]])) {
                                if(IsPlayerInRangeOfPoint(playerid, 10.0, 1963.9612, -369.1851, 1093.7289)) {
                                    GetPlayerName(ProposeOffer[playerid], giveplayer, sizeof(giveplayer));
                                    GetPlayerName(playerid, sendername, sizeof(sendername));
                                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan loi cau hon cua %s de thanh chong ban.", giveplayer);
                                    SendClientMessageEx(ProposeOffer[playerid], COLOR_LIGHTBLUE, "* %s chap nhan loi cau hon de tro thanh vo ban.", sendername);
                                    SendClientMessageEx(playerid, COLOR_WHITE, "Priest: %s, ban dong y lay %s lam chong khong? (Nhap 'yes', noi dung khac se huy le cuoi.)", sendername, giveplayer);
                                    MarriageCeremoney[playerid] = 1;
									if(GetPVarInt(ProposeOffer[playerid], "marriagelastname") == 1)
									{
										ShowPlayerDialogEx(playerid, DIALOG_MARRIAGE, DIALOG_STYLE_MSGBOX, "Ho sau khi ket hon",
										"Ban doi da chon giu ho. Ban co the giu ho hoac lay ho ban doi.\n\
										Dung cac nut ben duoi de chon.", "Giu", "Dung cua ho");
									}
									if(GetPVarInt(ProposeOffer[playerid], "marriagelastname") == 2)
									{
										SendClientMessageEx(playerid, -1, "Ban doi da chon lay ho cua ban.");
									}
                                    ProposedTo[ProposeOffer[playerid]] = playerid;
                                    GotProposedBy[playerid] = ProposeOffer[playerid];
                                    MarryWitness[ProposeOffer[playerid]] = INVALID_PLAYER_ID;
                                    ProposeOffer[playerid] = INVALID_PLAYER_ID;
                                    return 1;
                                }
                                else {
                                    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o nha tho!");
                                    return 1;
                                }
                            }
                            else {
                                SendClientMessageEx(playerid, COLOR_GREY, "Nguoi lam chung khong o gan nguoi cau hon!");
                                return 1;
                            }
                        }
                        return 1;
                    }
                    else {
                        SendClientMessageEx(playerid, COLOR_GREY, "Nguoi cau hon khong o gan ban!");
                        return 1;
                    }
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Chua ai cau hon ban!");
                return 1;
            }
        }
        else if(strcmp(params, "ticket", true) == 0) {
			if(!Offer_IsCurrent(playerid, TicketOffer[playerid], "TicketOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
            
			if(TicketOffer[playerid] != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(TicketOffer[playerid])) {
                    if (ProxDetectorS(5.0, playerid, TicketOffer[playerid])) {
                        if(GetPlayerCash(playerid) >= TicketMoney[playerid]) {
                            //new ip[32], ipex[32];
                            //GetPlayerIp(playerid, ip, sizeof(ip));
                            //GetPlayerIp(TicketOffer[playerid], ipex, sizeof(ipex));
                            //format(szMessage, sizeof(szMessage), "[FACTION TICKET] %s (IP: %s) has paid $%d to %s (IP: %s)", GetPlayerNameEx(playerid), ip, TicketMoney[playerid], GetPlayerNameEx(TicketOffer[playerid]), ipex);
                            // Log("logs/pay.log", szMessage);
                            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban tra ve phat $%d cho %s.", TicketMoney[playerid], GetPlayerNameEx(TicketOffer[playerid]));
                            SendClientMessageEx(TicketOffer[playerid], COLOR_LIGHTBLUE, "* %s tra ve phat cua ban, $%d.", GetPlayerNameEx(playerid), TicketMoney[playerid]);
                            format(szMessage, sizeof(szMessage), "* %s da tra ve phat.", GetPlayerNameEx(playerid));
                            ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                            GivePlayerCash(playerid, - TicketMoney[playerid]);
                            new money = floatround(TicketMoney[playerid] / 3), iGroupID = PlayerInfo[TicketOffer[playerid]][pMember];
                            Tax += money;
                            arrGroupData[iGroupID][g_iBudget] += money;
                            GetPVarString(playerid, "ticketreason", szMiscArray, sizeof(szMiscArray));
                            new str[128];
			                format(str, sizeof(str), "%s has paid %s's ticket of $%d [Reason: %s] and $%d has been sent to %s's budget fund.", GetPlayerNameEx(playerid), GetPlayerNameEx(TicketOffer[playerid]), TicketMoney[playerid], szMiscArray, money, arrGroupData[iGroupID][g_szGroupName]);
							GroupPayLog(iGroupID, str);
                            TicketOffer[playerid] = INVALID_PLAYER_ID;
                            TicketMoney[playerid] = 0;
                            DeletePVar(playerid, "ticketreason");
                            if(GetPlayerCash(playerid) < 1) GivePlayerCash(playerid, 0);
                            return 1;
                        }
                    }
                    else {
                        SendClientMessageEx(playerid, COLOR_GREY, "Canh sat khong o gan ban!");
                        return 1;
                    }
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co ve phat nao!");
                return 1;
            }
        }
		else if(strcmp(params, "boxing", true) == 0) {
			return Boxing_Accept(playerid);
		}
                                                  // accept taxi
   /*     else if(strcmp(params,"taxi",true) == 0) {
            if(TransportDuty[playerid] != 1) {
                SendClientMessageEx(playerid, COLOR_GREY, "   You are not a Taxi Driver!");
                return 1;
            }
            if(TaxiCallTime[playerid] > 0) {
                SendClientMessageEx(playerid, COLOR_GREY, "   You have already accepted a taxi call!");
                return 1;
            }
            if(TaxiCall != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(TaxiCall)) {
                	if(taxitime[TaxiCall] == 1 && PlayerInfo[playerid][pMember] != 10 && PlayerInfo[playerid][pLeader] != 10)
					{
					    return SendClientMessageEx(playerid, COLOR_GREY, "You must wait 20 seconds before accepting this call! To recieve priority, join the Taxi Company!");
					}
                    GetPlayerName(playerid, sendername, sizeof(sendername));
                    GetPlayerName(TaxiCall, giveplayer, sizeof(giveplayer));
                    format(szMessage, sizeof(szMessage), "* You have accepted the taxi call from %s, you will see the marker until you have reached it.",giveplayer);
                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMessage);
                    new zone[MAX_ZONE_NAME];
					GetPlayer3DZone(TaxiCall, zone, sizeof(zone));
					format(szMessage, sizeof(szMessage), "* %s can be found at %s.", GetPlayerNameEx(TaxiCall), zone);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMessage);
                    format(szMessage, sizeof(szMessage), "* Taxi Driver %s has accepted your Taxi Call; please wait at your current position.",sendername);
                    SendClientMessageEx(TaxiCall, COLOR_LIGHTBLUE, szMessage);
                    GameTextForPlayer(playerid, "~w~Taxi Caller~n~~r~Go to the red marker.", 5000, 1);
                    TaxiCallTime[playerid] = 1;
                    TaxiAccepted[playerid] = TaxiCall;
                    TaxiCall = INVALID_PLAYER_ID;
                    return 1;
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "   Nobody called for a taxi yet!");
                return 1;
            }
        }
        else if(strcmp(params, "bus", true) == 0) {
            if(TransportDuty[playerid] != 2) {
                SendClientMessageEx(playerid, COLOR_GREY, "   You are not a bus driver!");
                return 1;
            }
            if(BusCallTime[playerid] > 0) {
                SendClientMessageEx(playerid, COLOR_GREY, "   You have already accepted a bus call!");
                return 1;
            }
            if(BusCall != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(BusCall)) {
                    if(CheckPointCheck(playerid)) {
                        SendClientMessageEx(playerid, COLOR_WHITE, "Please ensure that your current checkpoint is destroyed first (you either have material packages, or another existing checkpoint).");
                        return 1;
                    }
                    GetPlayerName(playerid, sendername, sizeof(sendername));
                    GetPlayerName(BusCall, giveplayer, sizeof(giveplayer));
                    format(szMessage, sizeof(szMessage), "* You have accepted the Bus Call from %s, you will see the marker untill you have reached it.",giveplayer);
                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMessage);
                    new zone[MAX_ZONE_NAME];
					GetPlayer3DZone(BusCall, zone, sizeof(zone));
					format(szMessage, sizeof(szMessage), "* %s can be found at %s.", GetPlayerNameEx(BusCall), zone);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMessage);
                    format(szMessage, sizeof(szMessage), "* Bus Driver %s has accepted your bus call; please wait at your current position.",sendername);
                    SendClientMessageEx(BusCall, COLOR_LIGHTBLUE, szMessage);
                    new Float:X,Float:Y,Float:Z;
                    GetPlayerPos(BusCall, X, Y, Z);
                    SetPlayerCheckpoint(playerid, X, Y, Z, 5);
                    GameTextForPlayer(playerid, "~w~Bus Caller~n~~r~Goto redmarker", 5000, 1);
                    BusCallTime[playerid] = 1;
                    BusAccepted[playerid] = BusCall;
                    BusCall = INVALID_PLAYER_ID;
                    return 1;
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "   No-one called for a Bus yet!");
                return 1;
            }
        }*/
        else if(strcmp(params, "medic", true) == 0) {
            if(IsAMedic(playerid)) {
                if(MedicCallTime[playerid] > 0) {
                    SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhan cuoc goi Medic!");
                    return 1;
                }
                if(CheckPointCheck(playerid)) {
                    SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
                    return 1;
                }
                if(MedicCall != INVALID_PLAYER_ID) {
                    if(IsPlayerConnected(MedicCall)) {
                        GetPlayerName(playerid, sendername, sizeof(sendername));
                        GetPlayerName(MedicCall, giveplayer, sizeof(giveplayer));
                        SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan cuoc goi Medic tu %s.",giveplayer);
                        // SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* After the 45 Seconds the red marker will dissapear.");
                        SendClientMessageEx(MedicCall, COLOR_LIGHTBLUE, "* Medic %s nhan cuoc goi Medic, hay doi tai vi tri hien tai.",sendername);
                        new Float:X,Float:Y,Float:Z;
                        GetPlayerPos(MedicCall, X, Y, Z);
                        SetPlayerCheckpoint(playerid, X, Y, Z, 5);
                        new zone[MAX_ZONE_NAME];
                        GetPlayer3DZone(MedicCall, zone, sizeof(zone));
                        SendClientMessageEx(playerid, COLOR_WHITE, "GOI Y: %s dang o %s", GetPlayerNameEx(MedicCall), zone);
                        MedicCallTime[playerid] = 1;
                        MedicAccepted[playerid] = MedicCall;
                        MedicCall = INVALID_PLAYER_ID;
                        return 1;
                    }
                }
                else {
                    SendClientMessageEx(playerid, COLOR_GREY, "Chua ai goi Medic!");
                    return 1;
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Medic!");
                return 1;
            }
        }
        else if(strcmp(params, "mechanic", true) == 0) {
            if(!Job_HasJob(playerid, JOB_MECHANIC)) {
                SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Car Mechanic!");
                return 1;
            }
            if(MechanicCallTime[playerid] > 0) {
                SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhan cuoc goi Mechanic!");
                return 1;
            }
            if(CheckPointCheck(playerid)) {
                SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
                return 1;
            }
            if(MechanicCall != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(MechanicCall)) {
                    if(playerid == MechanicCall) return 1;
                    GetPlayerName(playerid, sendername, sizeof(sendername));
                    GetPlayerName(MechanicCall, giveplayer, sizeof(giveplayer));
                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan cuoc goi Mechanic tu %s, co 30 giay de den.",giveplayer);
                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Dau do se bien mat sau 30 giay.");
                    SendClientMessageEx(MechanicCall, COLOR_LIGHTBLUE, "* Car Mechanic %s nhan cuoc goi Mechanic, hay doi tai vi tri hien tai.",sendername);
                    new Float:X,Float:Y,Float:Z;
                    GetPlayerPos(MechanicCall, X, Y, Z);
                    SetPlayerCheckpoint(playerid, X, Y, Z, 5);
                    GameTextForPlayer(playerid, "~w~Nguoi goi Mechanic~n~~r~Den diem do", 5000, 1);
                    MechanicCallTime[playerid] = 1;
                    MechanicCall = INVALID_PLAYER_ID;
                    return 1;
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Chua ai goi Car Mechanic!");
                return 1;
            }
        }
        else if(strcmp(params, "live", true) == 0) {
			if(!Offer_IsCurrent(playerid, LiveOffer[playerid], "LiveOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
            
			if(LiveOffer[playerid] != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(LiveOffer[playerid])) {
                    if (ProxDetectorS(5.0, playerid, LiveOffer[playerid])) {
                        SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban bi khoa di chuyen den khi cuoc tro chuyen truc tiep ket thuc.");
                        SendClientMessageEx(LiveOffer[playerid], COLOR_LIGHTBLUE, "* Ban bi khoa di chuyen den khi cuoc tro chuyen ket thuc (dung /live lan nua).");
                        TogglePlayerControllable(playerid, false);
                        TogglePlayerControllable(LiveOffer[playerid], false);
						SetPVarInt(playerid, "IsLive", 1);
						SetPVarInt(LiveOffer[playerid], "IsLive", 1);
                        TalkingLive[playerid] = LiveOffer[playerid];
                        TalkingLive[LiveOffer[playerid]] = playerid;
                        LiveOffer[playerid] = INVALID_PLAYER_ID;
                        return 1;
                    }
                    else {
                        SendClientMessageEx(playerid, COLOR_GREY, "Ban o qua xa News Reporter!");
                        return 1;
                    }
                }
                return 1;
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Chua ai moi ban tro chuyen truc tiep!");
                return 1;
            }
        }
        else if(!strcmp(params, "lawyer", true, 6) && (params[6] == ' ' || params[6] == EOS)) {
			return Lawyer_Approve(playerid, params[6]);
        }
        else if(strcmp(params, "bodyguard", true) == 0) {
			new guardid = GuardOffer[playerid], price = GuardPrice[playerid];
			if(!Offer_IsCurrent(playerid, guardid, "GuardOfferSession")) {
				Bodyguard_ClearOffer(playerid);
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi bao ve khong con hop le.");
			}
			if(!Job_HasJob(guardid, JOB_BODYGUARD)) {
				Bodyguard_ClearOffer(playerid);
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong con la Bodyguard.");
			}
			if(price < 2000 || price > 10000) {
				Bodyguard_ClearOffer(playerid);
				return SendClientMessageEx(playerid, COLOR_GREY, "Gia bao ve khong con hop le.");
			}
			if(!Bodyguard_CanTrade(playerid) || !Bodyguard_CanTrade(guardid))
				return SendClientMessageEx(playerid, COLOR_GREY, "Ca hai phai san sang de hoan tat de nghi bao ve.");
			if(!Bodyguard_IsNear(playerid, guardid, 6.0))
				return SendClientMessageEx(playerid, COLOR_GREY, "Bodyguard phai o gan ban trong cung interior va world.");

			new Float:armour;
			GetArmour(playerid, armour);
			if(armour >= 50.0) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da co ao giap!");
			if(GetPlayerCash(playerid) < price) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua bao ve!");
			if(GetPlayerCash(guardid) > cellmax - price) return SendClientMessageEx(playerid, COLOR_GREY, "Bodyguard khong the nhan so tien nay.");

			Bodyguard_ClearOffer(playerid);
			SetArmour(playerid, 50.0);
			GivePlayerCash(guardid, price);
			GivePlayerCash(playerid, -price);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan bao ve gia $%d tu %s.", price, GetPlayerNameEx(guardid));
			SendClientMessageEx(guardid, COLOR_LIGHTBLUE, "* %s nhan bao ve, ban nhan them $%d.", GetPlayerNameEx(playerid), price);
			ExtortionTurfsWarsZone(guardid, 2, price);
			return 1;
        }
        else if(strcmp(params, "defense", true) == 0) {
			return Lawyer_AcceptDefense(playerid);
        }
        else if(strcmp(params, "appeal", true) == 0) {
			return Lawyer_AcceptAppeal(playerid);
        }
 	    else if(strcmp(params, "rimkit", true) == 0) {
        	if (GetPVarType(playerid, "RimOffer")) {
	            if(!Offer_IsCurrent(playerid, GetPVarInt(playerid, "RimOffer"), "RimOfferSession")) 
					return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay da het han.");
	            
				if(GetPlayerCash(playerid) > GetPVarInt(playerid, "RimPrice")) {
	            	if(IsPlayerConnected(GetPVarInt(playerid, "RimOffer"))) {
	            		if (GetPVarInt(playerid, "RimSeller_SQLId") != GetPlayerSQLId(GetPVarInt(playerid, "RimOffer")))
						{
			                return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi kia da ngat ket noi.");
						}
						if(PlayerInfo[GetPVarInt(playerid, "RimOffer")][pRimMod] < GetPVarInt(playerid, "RimCount"))	{
							SendClientMessageEx(playerid,COLOR_GREY, "Nguoi do khong con du rim kits!");
							return 1;
						}
	                    GivePlayerCash(playerid, -GetPVarInt(playerid, "RimPrice"));
	                    GivePlayerCash(GetPVarInt(playerid, "RimOffer"), GetPVarInt(playerid, "RimPrice"));
						GetPlayerName(GetPVarInt(playerid, "RimOffer"), giveplayer, sizeof(giveplayer));
	                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d rim kits voi gia $%d tu %s.",GetPVarInt(playerid, "RimCount"),GetPVarInt(playerid, "RimPrice"),giveplayer);
	                    GetPlayerName(playerid, sendername, sizeof(sendername));
	                    SendClientMessageEx(GetPVarInt(playerid, "RimOffer"), COLOR_LIGHTBLUE, "* %s mua %d rim kits, ban nhan them $%d.",sendername,GetPVarInt(playerid, "RimCount"),GetPVarInt(playerid, "RimPrice"));
	                    PlayerInfo[GetPVarInt(playerid, "RimOffer")][pRimMod] -= GetPVarInt(playerid, "RimCount");
	                    PlayerInfo[playerid][pRimMod] += GetPVarInt(playerid, "RimCount");

                        format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) rim kits for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPVarInt(playerid, "RimCount"), number_format(GetPVarInt(playerid, "RimPrice")),  GetPlayerNameEx(GetPVarInt(playerid, "RimOffer")), GetPlayerSQLId(GetPVarInt(playerid, "RimOffer")), GetPlayerIpEx(GetPVarInt(playerid, "RimOffer")));
						Log("logs/pay.log", szMessage);

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(GetPVarInt(playerid, "RimOffer"));

	                    DeletePVar(playerid, "RimOffer");
	                    DeletePVar(playerid, "RimPrice");
	                    DeletePVar(playerid, "RimCount");
                    	DeletePVar(playerid, "RimSeller_SQLId");
	                    return 1;
	  				}
	     		}
	      		else
				{
	            	SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua so rim kits nay!");
	                return 1;
	        	}
       		}
			else
			{
        		SendClientMessageEx(playerid, COLOR_GREY, "Chua ai chao ban rim kits cho ban!");
			}
 	    }
		else if(strcmp(params, "voucher", true) == 0)
		{
			if(!GetPVarType(playerid, "buyingVoucher")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chua ai chao ban voucher cho ban.");
			if(!Offer_IsCurrent(playerid, GetPVarInt(playerid, "sellerVoucher"), "VoucherOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay da het han.");

			new sellerid = GetPVarInt(playerid, "sellerVoucher"),
				price = GetPVarInt(playerid, "priceVoucher"),
				amount = GetPVarInt(playerid, "amountVoucher");

			DeletePVar(playerid, "sellVoucher");
			DeletePVar(playerid, "priceVoucher");
			DeletePVar(playerid, "amountVoucher");
			if(GetPlayerCash(playerid) > price)
			{
				if(IsPlayerConnected(sellerid))
				{
					if(GetPVarInt(playerid, "SQLID_Voucher") != GetPlayerSQLId(sellerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban da ngat ket noi.");
					if(GetPVarInt(playerid, "buyingVoucher") == 1) // Car Voucher
					{
						if(PlayerInfo[sellerid][pVehVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d Car Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d Car Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) Car Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pVehVoucher] += amount;
						PlayerInfo[sellerid][pVehVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
					if(GetPVarInt(playerid, "buyingVoucher") == 2) // Silver VIP Voucher
					{
						if(PlayerInfo[sellerid][pSVIPVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d Silver VIP Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d Silver VIP Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) Silver VIP Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pSVIPVoucher] += amount;
						PlayerInfo[sellerid][pSVIPVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
					if(GetPVarInt(playerid, "buyingVoucher") == 3) // Gold VIP Voucher
					{
						if(PlayerInfo[sellerid][pGVIPVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d Gold VIP Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d Gold VIP Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) Gold VIP Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pGVIPVoucher] += amount;
						PlayerInfo[sellerid][pGVIPVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
					if(GetPVarInt(playerid, "buyingVoucher") == 4) // 1 month PVIP Voucher
					{
						if(PlayerInfo[sellerid][pPVIPVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d 1 month PVIP Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d 1 month PVIP Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) 1 month PVIP Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pPVIPVoucher] += amount;
						PlayerInfo[sellerid][pPVIPVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
					if(GetPVarInt(playerid, "buyingVoucher") == 5) // Restricted Car Voucher
					{
						if(PlayerInfo[sellerid][pCarVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d Restricted Car Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d Restricted Car Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) Restricted Car Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pCarVoucher] += amount;
						PlayerInfo[sellerid][pCarVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
					if(GetPVarInt(playerid, "buyingVoucher") == 6) // Priority Advertisement Voucher
					{
						if(PlayerInfo[sellerid][pAdvertVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d Priority Advertisement Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d Priority Advertisement Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) Priority Advertisement Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pAdvertVoucher] += amount;
						PlayerInfo[sellerid][pAdvertVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
					if(GetPVarInt(playerid, "buyingVoucher") == 7) // 7 Days Silver VIP
					{
						if(PlayerInfo[sellerid][pSVIPExVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d 7 Days Silver VIP Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d 7 Days Silver VIP Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) 7 Day Silver VIP Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pSVIPExVoucher] += amount;
						PlayerInfo[sellerid][pSVIPExVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
					if(GetPVarInt(playerid, "buyingVoucher") == 8) // 7 Days Gold VIP
					{
						if(PlayerInfo[sellerid][pGVIPExVoucher] < amount) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi ban khong con du so luong.");

						GivePlayerCash(playerid, -price);
						GivePlayerCash(sellerid, price);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua %d 7 Days Gold VIP Voucher(s) gia $%s tu %s.", amount, number_format(price), GetPlayerNameEx(sellerid));
						SendClientMessageEx(sellerid, COLOR_LIGHTBLUE, "* %s mua %d 7 Days Gold VIP Voucher(s) tu ban, ban nhan $%s.", GetPlayerNameEx(playerid), amount, number_format(price));
						format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought (%d) 7 Days Gold VIP Voucher(s) for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, number_format(price),  GetPlayerNameEx(sellerid), GetPlayerSQLId(sellerid), GetPlayerIpEx(sellerid));
						Log("logs/pay.log", szMessage);
						PlayerInfo[playerid][pGVIPExVoucher] += amount;
						PlayerInfo[sellerid][pGVIPExVoucher] -= amount;

						OnPlayerStatsUpdate(playerid);
						OnPlayerStatsUpdate(sellerid);

						DeletePVar(playerid, "buyingVoucher");
						return 1;
					}
				}
				else return SendClientMessageEx(playerid, COLOR_GRAD2, "Chua ai chao ban voucher cho ban.");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong du tien.");
		}
        else if(strcmp(params,"craft",true) == 0) {
			if(!Offer_IsCurrent(playerid, CraftOffer[playerid], "CraftOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
            
			if(CraftOffer[playerid] != INVALID_PLAYER_ID) {
                if(IsPlayerConnected(CraftOffer[playerid])) {
                    new Float:X, Float:Y, Float:Z;
                    GetPlayerPos(CraftOffer[playerid], X, Y, Z);
                    if((Spectating[CraftOffer[playerid]] == 0 || PlayerInfo[playerid][pAdmin] >= 2)
                        && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(CraftOffer[playerid])
                        && GetPlayerInterior(playerid) == GetPlayerInterior(CraftOffer[playerid])
                        && IsPlayerInRangeOfPoint(playerid, 5.0, X, Y, Z)) {
                        if(PlayerInfo[playerid][pHospital] > 0) {
                            SendClientMessageEx(playerid, COLOR_GREY, "Khong the lay vu khi khi o benh vien.");
                            return 1;
                        }

                        if(PlayerInfo[CraftOffer[playerid]][pMats] < CraftMats[playerid]) {

                        	CraftOffer[playerid] = INVALID_PLAYER_ID;
                       		CraftId[playerid] = 0;
                        	CraftMats[playerid] = 0;
                        	return SendClientMessageEx(playerid, COLOR_GREY, "Craftsman khong du vat lieu.");
                        }

                        if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Hay ra khoi xe truoc khi dung lenh.");
                        new closet = INVALID_HOUSE_ID;
                        if(CraftId[playerid] == 17) {
                            new pInfo:keys[] = {pPhousekey, pPhousekey2, pPhousekey3};
                            for(new i; i < sizeof(keys); ++i) {
                                new houseid = PlayerInfo[playerid][keys[i]];
                                if(!(0 <= houseid < MAX_HOUSES)) continue;
                                if(HouseInfo[houseid][hOwnerID] != GetPlayerSQLId(playerid) || gHouseSaleUncertain[houseid]) continue;
                                if(GetPlayerVirtualWorld(playerid) != HouseInfo[houseid][hIntVW] || GetPlayerInterior(playerid) != HouseInfo[houseid][hIntIW]
                                    || GetPlayerVirtualWorld(CraftOffer[playerid]) != HouseInfo[houseid][hIntVW] || GetPlayerInterior(CraftOffer[playerid]) != HouseInfo[houseid][hIntIW]) continue;
                                if(!IsPlayerInRangeOfPoint(playerid, 50.0, HouseInfo[houseid][hInteriorX], HouseInfo[houseid][hInteriorY], HouseInfo[houseid][hInteriorZ])
                                    || !IsPlayerInRangeOfPoint(CraftOffer[playerid], 50.0, HouseInfo[houseid][hInteriorX], HouseInfo[houseid][hInteriorY], HouseInfo[houseid][hInteriorZ])) continue;
                                closet = houseid;
                                break;
                            }
                            if(closet == INVALID_HOUSE_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Ban va Craftsman phai o trong nha ban.");
                        }
                        new weaponname[50];
                        format(weaponname, 50, "%s", CraftName[playerid]);
                        switch(CraftId[playerid]) {
                            case 1:
                            {
                                PlayerInfo[playerid][pScrewdriver]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/sellgun");
                            }
                            case 2:
                            {
                                PlayerInfo[playerid][pSmslog]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/smslog");
                            }
                            case 3:
                            {
                                PlayerInfo[playerid][pWristwatch]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/wristwatch");
                            }
                            case 4:
                            {
                                PlayerInfo[playerid][pSurveillance]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/(p)lace(c)amera /(s)ee(c)amera /(d)estroy(c)amera");
                            }
                            case 5:
                            {
                                PlayerInfo[playerid][pTire]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/repair");
                            }
                            case 6:
                            {
                                PlayerInfo[playerid][pLock]=1;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/lock");
                            }
                            case 7:
                            {
                                PlayerInfo[playerid][pFirstaid]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/firstaid");
                            }
                            case 8:
                            {
                                GivePlayerValidWeapon(playerid, 43);
                            }
                            case 9:
                            {
                                PlayerInfo[playerid][pRccam]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/rccam");
                            }
                            case 10:
                            {
                                PlayerInfo[playerid][pReceiver]++;
                                SetPVarInt(playerid, "pReceiverMLeft", 4);
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban se nhan bon tin radio lien nganh tiep theo.");
                            }
                            case 11:
                            {
                                PlayerInfo[playerid][pGPS] = 1;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/gps");
                            }
                            case 12:
                            {
                                PlayerInfo[playerid][pSweep]++;
                                PlayerInfo[playerid][pSweepLeft] = 3;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/sweep");
                            }
                            case 13:
                            {
                                GivePlayerValidWeapon(playerid, 46);
                            }
							case 14:
							{

								if(PlayerInfo[playerid][pTreasureSkill] >=0 && PlayerInfo[playerid][pTreasureSkill] <= 24) PlayerInfo[playerid][pMetalDetector] += 25;
								else if(PlayerInfo[playerid][pTreasureSkill] >=25 && PlayerInfo[playerid][pTreasureSkill] <= 149) PlayerInfo[playerid][pMetalDetector] += 50;
								else if(PlayerInfo[playerid][pTreasureSkill] >=150 && PlayerInfo[playerid][pTreasureSkill] <= 299) PlayerInfo[playerid][pMetalDetector] += 75;
								else if(PlayerInfo[playerid][pTreasureSkill] >=300 && PlayerInfo[playerid][pTreasureSkill] <= 599) PlayerInfo[playerid][pMetalDetector] += 100;
								else if(PlayerInfo[playerid][pTreasureSkill] >=600) PlayerInfo[playerid][pMetalDetector] += 125;
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/search");
							}
                            case 15:
                            {
                                PlayerInfo[playerid][pMailbox]++;
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Dung /placemailbox tai vi tri muon dat hop thu.");
                            }
							case 16:
							{
								if(PlayerInfo[playerid][pSyringes] < 3) {
									PlayerInfo[playerid][pSyringes]++;
									SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/usedrug heroin");
								}
								else
								{
						    		SendClientMessageEx(playerid, COLOR_GREY, "Khong the mang them ong tiem.");
						    		return 1;
								}
							}
                            case 17: {
                                GetPlayerPos(playerid, HouseInfo[closet][hClosetX], HouseInfo[closet][hClosetY], HouseInfo[closet][hClosetZ]);
                                if(IsValidDynamic3DTextLabel(HouseInfo[closet][hClosetTextID])) DestroyDynamic3DTextLabel(HouseInfo[closet][hClosetTextID]);
                                HouseInfo[closet][hClosetTextID] = CreateDynamic3DTextLabel("Tu quan ao\n/closet de dung", 0xFFFFFF88, HouseInfo[closet][hClosetX], HouseInfo[closet][hClosetY], HouseInfo[closet][hClosetZ] + 0.5, 10.0, .testlos = 1, .worldid = HouseInfo[closet][hIntVW], .interiorid = HouseInfo[closet][hIntIW], .streamdistance = 10.0);
                                SaveHouse(closet);
                                SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "/closet(add/remove)");
                            }
							case 18:
							{
								PlayerInfo[playerid][pToolBox] += 15;
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Dung /pickveh(icle) trong xe de thu mo khoa xe.");
							}
							case 19:
							{
								PlayerInfo[playerid][pCrowBar] += 25;
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Dung /cracktrunk trong xe da mo khoa de thu pha cop.");
							}
							case 20: GivePlayerValidWeapon(playerid, WEAPON_FLOWER);
							case 21: GivePlayerValidWeapon(playerid, WEAPON_BRASSKNUCKLE);
							case 22: GivePlayerValidWeapon(playerid, WEAPON_BAT);
							case 23: GivePlayerValidWeapon(playerid, WEAPON_CANE);
							case 24: GivePlayerValidWeapon(playerid, WEAPON_SHOVEL);
							case 25: GivePlayerValidWeapon(playerid, WEAPON_POOLSTICK);
							case 26: GivePlayerValidWeapon(playerid, WEAPON_KATANA);
							case 27: GivePlayerValidWeapon(playerid, WEAPON_DILDO);
							case 28: GivePlayerValidWeapon(playerid, WEAPON_SPRAYCAN);
							case 29: {
								PlayerInfo[playerid][pRimMod]++;
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Dung /userimkit khi la Mechanic trong xe de thay mam.");
							}
                        }
                        format(szMessage, sizeof(szMessage), "Ban da dua cho %s mot %s.", GetPlayerNameEx(playerid),weaponname);
                        SendClientMessageEx(CraftOffer[playerid], COLOR_GRAD1, szMessage);
                        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban nhan %s tu %s.", weaponname, GetPlayerNameEx(CraftOffer[playerid]));
                        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
                        format(szMessage, sizeof(szMessage), "* %s che tao tu vat lieu va dua cho %s.", GetPlayerNameEx(CraftOffer[playerid]), GetPlayerNameEx(playerid));
                        ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                        new ip[32], ipex[32];
                        GetPlayerIp(playerid, ip, sizeof(ip));
                        GetPlayerIp(CraftOffer[playerid], ipex, sizeof(ipex));
                        format(szMessage, sizeof(szMessage), "[CRAFTSMAN DEAL] %s(%d) (IP: %s) has bought a %s from %s(%d) (IP: %s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, weaponname, GetPlayerNameEx(CraftOffer[playerid]), GetPlayerSQLId(CraftOffer[playerid]), ipex);
                        Log("logs/sell.log", szMessage);
                        PlayerInfo[CraftOffer[playerid]][pMats] -= CraftMats[playerid];
                        PlayerInfo[CraftOffer[playerid]][pArmsSkill]++;
                        CraftOffer[playerid] = INVALID_PLAYER_ID;
                        CraftId[playerid] = 0;
                        CraftMats[playerid] = 0;
                        return 1;
                    }
                    else {
                        SendClientMessageEx(playerid, COLOR_GRAD2, "Can o gan nguoi chao ban vu khi!");
                        return 1;
                    }
                }
                return 1;
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Chua ai de nghi che tao cho ban!");
                return 1;
            }
        }
		else if(strcmp(params,"contract",true) == 0) {
            if(!Offer_IsCurrent(playerid, HitOffer[playerid], "HitOfferSession") || !Offer_IsCurrent(playerid, HitToGet[playerid], "HitTargetSession"))
                return SendClientMessageEx(playerid, COLOR_GREY, "De nghi hop dong da het han.");
            
			if(GoChase[playerid] != INVALID_PLAYER_ID || GotHit[HitToGet[playerid]] || PlayerInfo[HitToGet[playerid]][pHeadValue] <= 0)
                return SendClientMessageEx(playerid, COLOR_GREY, "Hop dong khong con kha dung.");
			
			if(HitOffer[playerid] != INVALID_PLAYER_ID) {
				if(HitToGet[playerid] != INVALID_PLAYER_ID) {
					if(IsPlayerConnected(HitToGet[playerid])) {
						SendClientMessageEx(HitOffer[playerid], COLOR_LIGHTBLUE, "* %s nhan hop dong giet %s.", GetPlayerNameEx(playerid),GetPlayerNameEx(HitToGet[playerid]));
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan hop dong giet %s, se nhan $%d khi hoan thanh.", GetPlayerNameEx(HitToGet[playerid]), PlayerInfo[HitToGet[playerid]][pHeadValue]);
						format(szMessage, sizeof(szMessage), "%s duoc giao hop dong tren %s, gia $%d.", GetPlayerNameEx(playerid), GetPlayerNameEx(HitToGet[playerid]),  PlayerInfo[HitToGet[playerid]][pHeadValue]);
						foreach(new i: Player) if(IsAHitman(i)) SendClientMessage(i, COLOR_YELLOW, szMessage);
						//SendClientMessage(playerid, COLOR_LIGHTBLUE, "Hit accepted.  Wait 15 seconds for the final go ahead from the Agency.");
						//SetPVarInt(playerid, "HitCooldown", 15);
						GoChase[playerid] = HitToGet[playerid];
						GetChased[HitToGet[playerid]] = playerid;
						GotHit[HitToGet[playerid]] = 1;
						HitToGet[playerid] = INVALID_PLAYER_ID;
						HitOffer[playerid] = INVALID_PLAYER_ID;
						return 1;
					}
					else {
						HitToGet[playerid] = INVALID_PLAYER_ID;
						HitOffer[playerid] = INVALID_PLAYER_ID;
						return 1;
					}
				}
			}
			else {
				SendClientMessageEx(playerid, COLOR_GREY, "Chua ai de nghi hop dong cho ban!");
				return 1;
			}
		}
        else if(strcmp(params,"sex",true) == 0) {
			if(!Offer_IsCurrent(playerid, SexOffer[playerid], "SexOfferSession") || !Job_HasJob(SexOffer[playerid], JOB_PROSTITUTE))
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
            
			if(SexOffer[playerid] != INVALID_PLAYER_ID) {
                if(GetPlayerCash(playerid) > SexPrice[playerid]) {
                    if (IsPlayerConnected(SexOffer[playerid])) {
                        new Car = GetPlayerVehicleID(playerid);
                        if(IsPlayerInAnyVehicle(playerid) && IsPlayerInVehicle(SexOffer[playerid], Car)) {
                            GetPlayerName(SexOffer[playerid], giveplayer, sizeof(giveplayer));
                            GetPlayerName(playerid, sendername, sizeof(sendername));
                            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban quan he voi Whore %s, gia $%s.", giveplayer, number_format(SexPrice[playerid]));
                            SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* %s quan he voi ban. Ban kiem $%d.", sendername, SexPrice[playerid]);

                            new ip[32], ipex[32];
                            GetPlayerIp(playerid, ip, sizeof(ip));
                            GetPlayerIp(SexOffer[playerid], ipex, sizeof(ipex));
                            format(szMessage, sizeof(szMessage), "[SEX] %s(%d) (IP:%s) had sex with %s(%d) (IP:%s) for %d.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, GetPlayerNameEx(SexOffer[playerid]), GetPlayerSQLId(SexOffer[playerid]), ipex, SexPrice[playerid]);
                            Log("logs/sell.log", szMessage);

                            if(SexPrice[playerid] >= 25000 && (PlayerInfo[SexOffer[playerid]][pLevel] <= 3 || PlayerInfo[playerid][pLevel] <= 3)) {
                                format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) had sex with %s(%d) (IP:%s) for $%s in this session.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, GetPlayerNameEx(SexOffer[playerid]), GetPlayerSQLId(SexOffer[playerid]), ipex, number_format(SexPrice[playerid]));
                                Log("logs/sell.log", szMessage);
                                format(szMessage, sizeof(szMessage), "%s (IP:%s) had sex with %s (IP:%s) for $%s in this session.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(SexOffer[playerid]), ipex, number_format(SexPrice[playerid]));
                                ABroadCast(COLOR_YELLOW, szMessage, 2);
                            }

                            ExtortionTurfsWarsZone(SexOffer[playerid], 6, SexPrice[playerid]);
                            GivePlayerCash(SexOffer[playerid], SexPrice[playerid]);
                            GivePlayerCash(playerid, -SexPrice[playerid]);

  							if(PlayerInfo[SexOffer[playerid]][pDoubleEXP] > 0)
							{
								SendClientMessageEx(SexOffer[playerid], COLOR_YELLOW, "Ban nhan 2 diem Whore thay vi 1. Double EXP token con %d gio.", PlayerInfo[SexOffer[playerid]][pDoubleEXP]);
   								PlayerInfo[SexOffer[playerid]][pSexSkill] += 2;
							}
							else
							{
  								PlayerInfo[SexOffer[playerid]][pSexSkill] += 1;
							}

                            if(PlayerInfo[SexOffer[playerid]][pSexSkill] == 50) {
                                SendClientMessageEx(SexOffer[playerid], COLOR_YELLOW, "* Ky nang quan he dat cap 2, tang nhieu mau hon va giam nguy co STI.");
                            }
                            else if(PlayerInfo[SexOffer[playerid]][pSexSkill] == 100) {
                                SendClientMessageEx(SexOffer[playerid], COLOR_YELLOW, "* Ky nang quan he dat cap 3, tang nhieu mau hon va giam nguy co STI.");
                            }
                            else if(PlayerInfo[SexOffer[playerid]][pSexSkill] == 200) {
                                SendClientMessageEx(SexOffer[playerid], COLOR_YELLOW, "* Ky nang quan he dat cap 4, tang nhieu mau hon va giam nguy co STI.");
                            }
                            else if(PlayerInfo[SexOffer[playerid]][pSexSkill] == 400) {
                                SendClientMessageEx(SexOffer[playerid], COLOR_YELLOW, "* Ky nang quan he dat cap 5, tang nhieu mau hon va giam nguy co STI.");
                            }

                            if(!GetPVarType(playerid, "STD")) {
                                if(Condom[playerid] == 0) {
                                    new Float:health;
                                    new level = GetJobLevel(SexOffer[playerid], JOB_PROSTITUTE);
                                    if(level == 1) {
                                        GetHealth(playerid, health);
                                        if(health < 100) {
                                            if(health > 90) {
                                                SetHealth(playerid, 100);
                                            }
                                            else {
                                                SetHealth(playerid, health + 10.0);
                                            }
                                        }
                                        new rand = random(sizeof(STD1));
                                        SetPVarInt(playerid, "STD", STD1[rand]);
                                        SetPVarInt(SexOffer[playerid], "STD", STD1[rand]);
                                        if(STD1[rand] == 0) {
                                            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 10 mau va khong nhiem STI khi quan he."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban khong nhiem STI khi quan he.");
                                        }
                                        else if(STD1[rand] == 1) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 10 mau va nhiem Chlamydia do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Chlamydia do quan he khong an toan."); }
                                        else if(STD1[rand] == 2) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 10 mau va nhiem Gonorrhea do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Gonorrhea do quan he khong an toan."); }
                                        else if(STD1[rand] == 3) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 10 mau va nhiem Syphilis do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Syphilis do quan he khong an toan."); }
                                    }
                                    else if(level == 2) {
                                        GetHealth(playerid, health);
                                        if(health < 100) {
                                            if(health > 80) {
                                                SetHealth(playerid, 100);
                                            }
                                            else {
                                                SetHealth(playerid, health + 20.0);
                                            }
                                        }
                                        new rand = random(sizeof(STD2));
                                        SetPVarInt(playerid, "STD", STD2[rand]);
                                        SetPVarInt(SexOffer[playerid], "STD", STD2[rand]);
                                        if(STD2[rand] == 0) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 20 mau va khong nhiem STD khi quan he."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban khong nhiem STI khi quan he."); }
                                        else if(STD2[rand] == 1) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 20 mau va nhiem Chlamydia do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Chlamydia do quan he khong an toan."); }
                                        else if(STD2[rand] == 2) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 20 mau va nhiem Gonorrhea do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Gonorrhea do quan he khong an toan."); }
                                        else if(STD2[rand] == 3) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 20 mau va nhiem Syphilis do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Syphilis do quan he khong an toan."); }
                                    }
                                    else if(level == 3) {
                                        GetHealth(playerid, health);
                                        if(health < 100) {
                                            if(health > 70) {
                                                SetHealth(playerid, 100);
                                            }
                                            else {
                                                SetHealth(playerid, health + 30.0);
                                            }
                                        }
                                        new rand = random(sizeof(STD3));
                                        SetPVarInt(playerid, "STD", STD3[rand]);
                                        SetPVarInt(SexOffer[playerid], "STD", STD3[rand]);
                                        if(STD3[rand] == 0) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 30 mau va khong nhiem STI khi quan he."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban khong nhiem STI khi quan he."); }
                                        else if(STD3[rand] == 1) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 30 mau va nhiem Chlamydia do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Chlamydia do quan he khong an toan."); }
                                        else if(STD3[rand] == 2) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 30 mau va nhiem Gonorrhea do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Gonorrhea do quan he khong an toan."); }
                                        else if(STD3[rand] == 3) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 30 mau va nhiem Syphilis do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Syphilis do quan he khong an toan."); }
                                    }
                                    else if(level == 4) {
                                        GetHealth(playerid, health);
                                        if(health < 100) {
                                            if(health > 60) {
                                                SetHealth(playerid, 100);
                                            }
                                            else {
                                                SetHealth(playerid, health + 40.0);
                                            }
                                        }
                                        new rand = random(sizeof(STD4));
                                        SetPVarInt(playerid, "STD", STD4[rand]);
                                        SetPVarInt(SexOffer[playerid], "STD", STD4[rand]);
                                        if(STD4[rand] == 0) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 40 mau va khong nhiem STI khi quan he."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban khong nhiem STI khi quan he."); }
                                        else if(STD4[rand] == 1) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 40 mau va nhiem Chlamydia do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Chlamydia do quan he khong an toan."); }
                                        else if(STD4[rand] == 2) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 40 mau va nhiem Gonorrhea do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Gonorrhea do quan he khong an toan."); }
                                        else if(STD4[rand] == 3) { SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan 40 mau va nhiem Syphilis do quan he khong an toan."); SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ban nhiem Syphilis do quan he khong an toan."); }
                                    }
                                    else if(level == 5) {
                                        GetHealth(playerid, health);
                                        if(health > 50) {
                                            SetHealth(playerid, 100);
                                        }
                                        else {
                                            SetHealth(playerid, health + 50.0);
                                        }
                                        SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ky nang quan he cua ban du cao de tang nhieu mau va khong lay STD.");
                                        SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Ky nang cua Whore du cao de tang nhieu mau va khong lay STD cho ban.");
                                    }
                                }
                                else {
                                    SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Nguoi do da dung bao cao su.");
                                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da dung bao cao su.");
                                    Condom[playerid] --;
                                }
                            }
                            else {
                                SendClientMessageEx(SexOffer[playerid], COLOR_LIGHTBLUE, "* Nguoi do da nhiem STD, khong the nhiem them.");
								SexOffer[playerid] = INVALID_PLAYER_ID;
                                return 1;
                            }
                            SexOffer[playerid] = INVALID_PLAYER_ID;
                            return 1;
                        }
                        else {
                            SendClientMessageEx(playerid, COLOR_GREY, "Ban va Whore phai cung o trong xe!");
                            return 1;
                        }
                    }                             //Connected or not
                    return 1;
                }
                else {
                    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien tra dich vu tinh duc!");
                    return 1;
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GREY, "Chua co de nghi quan he nao!");
                return 1;
            }
        }
        else if(strcmp(params,"repair",true) == 0) {
			if(!Offer_IsCurrent(playerid, RepairOffer[playerid], "RepairOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");

			new mechanicid = RepairOffer[playerid], vehicleid = RepairCar[playerid];
			if(GetPlayerCash(mechanicid) > cellmax - RepairPrice[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Mechanic khong the nhan so tien nay.");
			if(!Job_HasJob(mechanicid, JOB_MECHANIC))
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong con la Mechanic.");
			if(!IsPlayerInVehicle(playerid, vehicleid) || !Mechanic_NearVehicle(playerid, vehicleid, 8.0) || !Mechanic_NearVehicle(mechanicid, vehicleid, 8.0))
				return SendClientMessageEx(playerid, COLOR_GREY, "Can o trong xe duoc de nghi va gan Mechanic.");
			if(GetPlayerState(mechanicid) != PLAYER_STATE_ONFOOT || PlayerIsDead[mechanicid] || GetPVarType(mechanicid, "Injured") || GetPVarType(mechanicid, "FixVehicleTimer") || GetPVarInt(mechanicid, "EventToken")
				|| GetPVarType(mechanicid, "IsInArena") || GetPVarType(mechanicid, "PlayerCuffed") || GetPVarInt(mechanicid, "pBagged") || GetPVarType(mechanicid, "IsFrozen") || PlayerInfo[mechanicid][pHospital] > 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Mechanic chua the sua xe cho ban.");
			if(PlayerInfo[mechanicid][pTire] <= 0) return SendClientMessageEx(playerid, COLOR_GREY, "Mechanic da het lop xe.");
			if(!IsABike(vehicleid) && !IsAPlane(vehicleid))
			{
				new engine, lights, alarm, doors, bonnet, boot, objective;
				GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
				if(bonnet != VEHICLE_PARAMS_ON) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can mo nap capo de sua xe.");
			}
			if(GetPlayerCash(playerid) < RepairPrice[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien sua xe.");
			if(!RepairVehicle(vehicleid)) return SendClientMessageEx(playerid, COLOR_GREY, "Luc nay khong the sua xe nay.");
			Vehicle_Armor(RepairCar[playerid]);
			PlayerInfo[RepairOffer[playerid]][pTire]--;

			GivePlayerCash(RepairOffer[playerid], RepairPrice[playerid]);
			GivePlayerCash(playerid, -RepairPrice[playerid]);
			new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(RepairOffer[playerid], ipex, sizeof(ipex));
			format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has repaired the vehicle from %s(%d) (IP:%s) for $%d", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, GetPlayerNameEx(RepairOffer[playerid]), GetPlayerSQLId(RepairOffer[playerid]), ipex, RepairPrice[playerid]);
			Log("logs/sell.log", szMessage);
			format(szMessage, sizeof(szMessage), "* %s sua xe cua %s.", GetPlayerNameEx(RepairOffer[playerid]), GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban tra $%d de Car Mechanic %s sua xe.",RepairPrice[playerid],GetPlayerNameEx(RepairOffer[playerid]));

			if(RepairPrice[playerid] >= 25000 && (PlayerInfo[playerid][pLevel] <= 3 || PlayerInfo[RepairOffer[playerid]][pLevel] <= 3)) {
			    format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has repaired %s(%d) (IP:%s) $%d in this session.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, GetPlayerNameEx(RepairOffer[playerid]), GetPlayerSQLId(RepairOffer[playerid]), ipex, RepairPrice[playerid]);
			    Log("logs/sell.log", szMessage);
			    format(szMessage, sizeof(szMessage), "%s (IP:%s) has repaired %s (IP:%s) $%d in this session.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(RepairOffer[playerid]), ipex, RepairPrice[playerid]);
			    ABroadCast(COLOR_YELLOW, szMessage, 2);
			}

			SendClientMessageEx(RepairOffer[playerid], COLOR_LIGHTBLUE, "* Ban sua xe cua %s, nhan them $%d tien mat!",GetPlayerNameEx(playerid),RepairPrice[playerid]);

			if(PlayerInfo[RepairOffer[playerid]][pDoubleEXP] > 0)
			{
			    SendClientMessageEx(RepairOffer[playerid], COLOR_YELLOW, "Ban nhan 2 diem Mechanic thay vi 1. Double EXP token con %d gio.", PlayerInfo[RepairOffer[playerid]][pDoubleEXP]);
			    PlayerInfo[RepairOffer[playerid]][pMechSkill] += 2;
			}
			else
			{
			    PlayerInfo[RepairOffer[playerid]][pMechSkill] += 1;
			}

			if(GetPVarInt(mechanicid, "RepairOfferTo") == playerid) DeletePVar(mechanicid, "RepairOfferTo");
			RepairCar[playerid] = 0;
			DeletePVar(playerid, "RepairOfferSession");
			RepairOffer[playerid] = INVALID_PLAYER_ID;
			RepairPrice[playerid] = 0;
			return 1;
        }
        else if(strcmp(params,"refill",true) == 0) {
			if(!Offer_IsCurrent(playerid, RefillOffer[playerid], "RefillOfferSession")) return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay khong con hop le.");
			new mechanicid = RefillOffer[playerid], vehicleid = GetPVarInt(playerid, "RefillVehicle");
			if(GetPlayerCash(mechanicid) > cellmax - RefillPrice[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Mechanic khong the nhan so tien nay.");
			if(!Job_HasJob(mechanicid, JOB_MECHANIC))
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong con la Mechanic.");
			if(!IsPlayerInVehicle(playerid, vehicleid) || !Mechanic_NearVehicle(playerid, vehicleid, 8.0) || !Mechanic_NearVehicle(mechanicid, vehicleid, 8.0))
				return SendClientMessageEx(playerid, COLOR_GREY, "Can o trong xe duoc de nghi va gan Mechanic.");
			if(PlayerIsDead[mechanicid] || GetPVarType(mechanicid, "Injured") || GetPVarType(mechanicid, "FixVehicleTimer") || GetPVarInt(mechanicid, "EventToken")
				|| GetPVarType(mechanicid, "IsInArena") || GetPVarType(mechanicid, "PlayerCuffed") || GetPVarInt(mechanicid, "pBagged") || GetPVarType(mechanicid, "IsFrozen") || PlayerInfo[mechanicid][pHospital] > 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Mechanic chua the do xang cho xe ban.");
			if(VehicleFuel[vehicleid] >= 100.0) return SendClientMessageEx(playerid, COLOR_GREY, "Binh xang xe da day.");
			if(GetPlayerCash(playerid) < RefillPrice[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien do xang.");
			new Float:fueltogive = Mechanic_RefillAmount(PlayerInfo[mechanicid][pMechSkill]);
			if(VehicleFuel[vehicleid] + fueltogive > 100.0) fueltogive = 100.0 - VehicleFuel[vehicleid];
			VehicleFuel[vehicleid] += fueltogive;
			new vehicleslot = GetPlayerVehicle(playerid, vehicleid);
			if(vehicleslot != -1) {
			    mysql_format(MainPipeline, szMessage, sizeof(szMessage), "UPDATE `vehicles` SET `pvFuel` = %0.5f WHERE `id` = '%d'", VehicleFuel[vehicleid], PlayerVehicleInfo[playerid][vehicleslot][pvSlotId]);
			    mysql_tquery(MainPipeline, szMessage, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
			}
			GivePlayerCash(RefillOffer[playerid], RefillPrice[playerid]);
			GivePlayerCash(playerid, -RefillPrice[playerid]);
			new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(RefillOffer[playerid], ipex, sizeof(ipex));
			format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has refilled the vehicle from %s(%d) (IP:%s) for $%d", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, GetPlayerNameEx(RefillOffer[playerid]), GetPlayerSQLId(RefillOffer[playerid]), ipex, RefillPrice[playerid]);
			Log("logs/sell.log", szMessage);
			format(szMessage, sizeof(szMessage), "* %s do xang cho xe cua %s.", GetPlayerNameEx(RefillOffer[playerid]), GetPlayerNameEx(playerid));
			ProxChatBubble(playerid, szMessage);
			// ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da them %.2f nhien lieu gia $%d boi Car Mechanic %s.",fueltogive,RefillPrice[playerid],GetPlayerNameEx(RefillOffer[playerid]));
			SendClientMessageEx(RefillOffer[playerid], COLOR_LIGHTBLUE, "* Ban them %.2f nhien lieu vao xe cua %s, nhan them $%d!",fueltogive,GetPlayerNameEx(playerid),RefillPrice[playerid]);

			if(PlayerInfo[RefillOffer[playerid]][pDoubleEXP] > 0)
			{
			    SendClientMessageEx(RefillOffer[playerid], COLOR_YELLOW, "Ban nhan 2 diem Mechanic thay vi 1. Double EXP token con %d gio.", PlayerInfo[RefillOffer[playerid]][pDoubleEXP]);
			    PlayerInfo[RefillOffer[playerid]][pMechSkill] += 2;
			}
			else
			{
			    PlayerInfo[RefillOffer[playerid]][pMechSkill] += 1;
			}

			if(RefillPrice[playerid] >= 30000 && (PlayerInfo[playerid][pLevel] <= 3 || PlayerInfo[RefillOffer[playerid]][pLevel] <= 3)) {
			    format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has refueled %s(%d) (IP:%s) $%d in this session.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, GetPlayerNameEx(RefillOffer[playerid]), GetPlayerSQLId(RefillOffer[playerid]), ipex, RefillPrice[playerid]);
			    Log("logs/sell.log", szMessage);
			    format(szMessage, sizeof(szMessage), "%s (IP:%s) has refueled %s (IP:%s) $%d in this session.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(RefillOffer[playerid]), ipex, RefillPrice[playerid]);
			    ABroadCast(COLOR_YELLOW, szMessage, 2);
			}

			DeletePVar(playerid, "RefillVehicle");
			DeletePVar(playerid, "RefillOfferSession");
			RefillOffer[playerid] = INVALID_PLAYER_ID;
			RefillPrice[playerid] = 0;
			return 1;
        }
		else if(strcmp(params, "backpack", true) == 0) {
			if(!Offer_IsCurrent(playerid, GetPVarInt(playerid, "sellbackpack"), "BackpackOfferSession")) 
				return SendClientMessageEx(playerid, COLOR_GREY, "De nghi nay da het han.");
			
			if(GetPVarType(playerid, "sellbackpack") && IsPlayerConnected(GetPVarInt(playerid, "sellbackpack")))
			{
				if(GetPlayerCash(playerid) > GetPVarInt(playerid, "sellbackpackprice"))
				{
					if(PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBackpack] < 1)	{
						SendClientMessageEx(playerid,COLOR_GREY, "Nguoi do khong con ba lo!");
						return 1;
					}
					new btype[8];
					if(PlayerHoldingObject[playerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 9))
						RemovePlayerAttachedObject(playerid, 9), PlayerHoldingObject[playerid][9] = 0;
					switch(PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBackpack])
					{
						case 1:
						{
							btype = "Small";
							SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
						}
						case 2:
						{
							btype = "Medium";
							SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);
						}
						case 3:
						{
							btype = "Large";
							SetPlayerAttachedObject(playerid, 9, 3026, 1, -0.254999, -0.109, -0.022999, 10.6, -1.20002, 3.4, 1.265, 1.242, 1.062);
						}
					}
					GivePlayerCash(playerid, -GetPVarInt(playerid, "sellbackpackprice"));
					GivePlayerCash(GetPVarInt(playerid, "sellbackpack"), GetPVarInt(playerid, "sellbackpackprice"));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban mua ba lo %s gia $%s tu %s.",btype,number_format(GetPVarInt(playerid, "sellbackpackprice")),GetPlayerNameEx(GetPVarInt(playerid, "sellbackpack")));
					SendClientMessageEx(GetPVarInt(playerid, "sellbackpack"), COLOR_LIGHTBLUE, "* %s mua ba lo %s cua ban, ban nhan $%s.",GetPlayerNameEx(playerid),btype, number_format(GetPVarInt(playerid, "sellbackpackprice")));


					PlayerInfo[playerid][pBackpack] = PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBackpack];
					PlayerInfo[playerid][pBEquipped] = 1;
					PlayerInfo[playerid][pBStoredH] = INVALID_HOUSE_ID;
					PlayerInfo[playerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
					RemovePlayerAttachedObject(GetPVarInt(playerid, "sellbackpack"), 9);

					PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBackpack] = 0;
					PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBEquipped] = 0;
					PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBStoredH] = INVALID_HOUSE_ID;
					PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
					for(new i = 0; i < 10; i++)
					{
						PlayerInfo[GetPVarInt(playerid, "sellbackpack")][pBItems][i] = 0;
					}

					format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has bought %s Backpack for $%s from %s(%d) (IP:%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), btype, number_format(GetPVarInt(playerid, "sellbackpackprice")),  GetPlayerNameEx(GetPVarInt(playerid, "sellbackpack")), GetPlayerSQLId(GetPVarInt(playerid, "sellbackpack")), GetPlayerIpEx(GetPVarInt(playerid, "sellbackpack")));
					Log("logs/pay.log", szMessage);
					Log("logs/backpack.log", szMessage);

					OnPlayerStatsUpdate(playerid);
					OnPlayerStatsUpdate(GetPVarInt(playerid, "sellbackpack"));
					DeletePVar(GetPVarInt(playerid, "sellbackpack"), "sellingbackpack");
					DeletePVar(playerid, "sellbackpack");
					DeletePVar(playerid, "sellbackpackprice");
					return 1;
	     		}
	      		else
				{
	            	SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua ba lo!");
					DeletePVar(playerid, "sellbackpack");
	                DeletePVar(playerid, "sellbackpackprice");
	                return 1;
	        	}
			}
		}
        return 1;
    }                                             //not connected
    return 1;
}

CMD:cancel(playerid, params[])
{
	new choice[32];
	if(sscanf(params, "s[32]", choice))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "|__________________ Huy __________________|");
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cancel [name]");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Sex, Mats, Cannabis, Crack, Weapon, Craft, Repair, Lawyer, Defense, Appeal, Bodyguard, Live, Refill, Car, Boxing");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Taxi, Bus, Medic, Mechanic, Ticket, Witness, Marriage, Drink, House, Shipment, Help, Firstaid, Garbage");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: FoodOffer, RenderAid, DrugRun");
		if(PlayerInfo[playerid][pTut] != -1) SendClientMessageEx(playerid, COLOR_GREY, "Dac biet: objectives");
		if(IsAHitman(playerid)) { SendClientMessageEx(playerid, COLOR_GREY, "Dac biet: contract"); }
		SendClientMessageEx(playerid, COLOR_WHITE, "|____________________________________________|");
		return 1;
	}

	if(strcmp(choice, "objectives", true) == 0 && PlayerInfo[playerid][pTut] >= 15)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy huong dan muc tieu. Chao mung den Next Generation Gaming!");
		SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
		PlayerInfo[playerid][pTut] = -1;
		DisablePlayerCheckpoint(playerid);
	}

	if(strcmp(choice, "door", true) == 0)
	{
		if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap tai khoan.");
		if(DDSalePendingAdmin[playerid] == false && DDSalePendingPlayer[playerid] == false) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co de nghi ban Dynamic Door dang cho.");
		ClearDoorSaleVariables(playerid);
	}
	else if(strcmp(choice,"renderaid",true) == 0) DeletePVar(playerid, "renderaid");
	else if(strcmp(choice,"weapon",true) == 0) { ArmsDealer_ClearOffer(playerid); }
	else if(strcmp(choice,"sex",true) == 0) {
        new target = GetPVarInt(playerid, "SexOfferTo");
        if(GetPVarType(playerid, "SexOfferTo") && 0 <= target < MAX_PLAYERS && SexOffer[target] == playerid
            && Offer_IsCurrent(target, playerid, "SexOfferSession")) {
            SexOffer[target] = INVALID_PLAYER_ID;
            SexPrice[target] = 0;
            DeletePVar(target, "SexOfferSession");
        }
        else {
            SexOffer[playerid] = INVALID_PLAYER_ID;
            SexPrice[playerid] = 0;
            DeletePVar(playerid, "SexOfferSession");
        }
        DeletePVar(playerid, "SexOfferTo");
    }
	else if(strcmp(choice,"craft",true) == 0) { CraftOffer[playerid] = INVALID_PLAYER_ID; CraftId[playerid] = 0; }
	else if(strcmp(choice,"repair",true) == 0) {
        new target = GetPVarInt(playerid, "RepairOfferTo");
        if(GetPVarType(playerid, "RepairOfferTo") && 0 <= target < MAX_PLAYERS && RepairOffer[target] == playerid
            && Offer_IsCurrent(target, playerid, "RepairOfferSession")) {
            RepairOffer[target] = INVALID_PLAYER_ID;
            RepairPrice[target] = 0;
            RepairCar[target] = 0;
            DeletePVar(target, "RepairOfferSession");
        }
        else {
            RepairOffer[playerid] = INVALID_PLAYER_ID;
            RepairPrice[playerid] = 0;
            RepairCar[playerid] = 0;
            DeletePVar(playerid, "RepairOfferSession");
        }
        DeletePVar(playerid, "RepairOfferTo");
    }
	else if(strcmp(choice,"lawyer",true) == 0) { WantLawyer[playerid] = 0; CallLawyer[playerid] = 0; }
	else if(strcmp(choice,"defense",true) == 0) { DefendOffer[playerid] = INVALID_PLAYER_ID; DefendPrice[playerid] = 0; DeletePVar(playerid, "DefendOfferSession"); }
	else if(strcmp(choice,"appeal",true) == 0) { Lawyer_ClearAppeal(playerid); }
	else if(strcmp(choice,"bodyguard",true) == 0) { Bodyguard_ClearOffer(playerid); }
	else if(strcmp(choice,"live",true) == 0) { LiveOffer[playerid] = INVALID_PLAYER_ID; }
	else if(strcmp(choice,"refill",true) == 0) { RefillOffer[playerid] = INVALID_PLAYER_ID; RefillPrice[playerid] = 0; DeletePVar(playerid, "RefillOfferSession"); DeletePVar(playerid, "RefillVehicle"); }
	else if(strcmp(choice,"car",true) == 0) { VehicleOffer[playerid] = INVALID_PLAYER_ID; VehiclePrice[playerid] = 0; VehicleId[playerid] = -1; DeletePVar(playerid, "VehicleOfferSession"); DeletePVar(playerid, "VehicleOfferSQLId"); }
	else if(strcmp(choice,"house",true) == 0) { HouseOffer[playerid] = INVALID_PLAYER_ID; HousePrice[playerid] = 0; House[playerid] = INVALID_HOUSE_ID; DeletePVar(playerid, "HouseOfferSession"); }
	else if(strcmp(choice,"boxing",true) == 0) { BoxOffer[playerid] = INVALID_PLAYER_ID; DeletePVar(playerid, "BoxOfferSession"); }
	else if(strcmp(choice,"witness",true) == 0) { MarryWitnessOffer[playerid] = INVALID_PLAYER_ID; }
	else if(strcmp(choice,"marriage",true) == 0) {
        if(Offer_IsCurrent(playerid, ProposeOffer[playerid], "ProposeOfferSession")) DeletePVar(ProposeOffer[playerid], "marriagelastname");
        ProposeOffer[playerid] = INVALID_PLAYER_ID;
        DeletePVar(playerid, "ProposeOfferSession");
        DeletePVar(playerid, "marriagelastname");
    }
	//else if(strcmp(choice,"divorce",true) == 0) { DivorceOffer[playerid] = INVALID_PLAYER_ID; }
	else if(strcmp(choice,"drink",true) == 0) { DrinkOffer[playerid] = INVALID_PLAYER_ID; }
	else if(strcmp(choice,"firstaid",true) == 0)
	{
		Craftsman_StopFirstAid(playerid);
	}
	else if(strcmp(choice,"drugrun",true) == 0)
	{
		if(GetPVarInt(playerid, "pDrugRun"))
		{
			Player_KillCheckPoint(playerid);
			DeletePVar(playerid, "pDrugRun");
			DeletePVar(playerid, "pDrugBoat");
			DeletePVar(playerid, "pPotPackages");
			DeletePVar(playerid, "pCrackPackages");
			DeletePVar(playerid, "pMethPackages");
			DeletePVar(playerid, "pEcstasyPackages");
		}
	}
	else if(strcmp(choice,"shipment",true) == 0)
	{
		CancelTruckDelivery(playerid);
	}
	else if(strcmp(choice,"garbage",true) == 0)
	{
		Garbage_CancelRun(playerid);
	}
	else if(strcmp(choice,"help", true) == 0)
	{
	    if(GetPVarInt(playerid, "COMMUNITY_ADVISOR_REQUEST") == 1)
	    {
		    DeletePVar(playerid, "COMMUNITY_ADVISOR_REQUEST");
			DeletePVar(playerid, "HelpTime");
			DeletePVar(playerid, "HelpReason");
		}
		else {
		    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua yeu cau ho tro.");
		    return 1;
		}
	}
	else if(strcmp(choice,"contract",true) == 0)
	{
		if(GoChase[playerid] != INVALID_PLAYER_ID || HitToGet[playerid] != INVALID_PLAYER_ID) {
			new Float:health;
			GetHealth(playerid, health);
			new hpint = floatround( health, floatround_round );
			if (hpint >=  80)
			{
				HitToGet[playerid] = INVALID_PLAYER_ID;
				HitOffer[playerid] = INVALID_PLAYER_ID;
				if(0 <= GoChase[playerid] < MAX_PLAYERS && GetChased[GoChase[playerid]] == playerid) {
					GetChased[GoChase[playerid]] = INVALID_PLAYER_ID;
					GotHit[GoChase[playerid]] = 0;
				}
				GoChase[playerid] = INVALID_PLAYER_ID;
				DeletePVar(playerid, "HitCooldown");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the huy hop dong khi mau duoi 80 phan tram!");

		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co hop dong dang hoat dong!");
	}
	else if(strcmp(choice,"ticket",true) == 0) { TicketOffer[playerid] = INVALID_PLAYER_ID; TicketMoney[playerid] = 0; }
	else if(strcmp(choice,"medic",true) == 0) { if(IsPlayerConnected(MedicCall)) { if(MedicCall == playerid) { MedicCall = INVALID_PLAYER_ID; } else { SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nguoi goi hien tai!"); return 1; } } }
	else if(strcmp(choice,"mechanic",true) == 0) { if(IsPlayerConnected(MechanicCall)) { if(MechanicCall == playerid) { MechanicCall = INVALID_PLAYER_ID; } else { SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nguoi goi hien tai!"); return 1; } } }
	else if(strcmp(choice,"help",true) == 0) { if(GetPVarInt(playerid, "COMMUNITY_ADVISOR_REQUEST")) { DeletePVar(playerid, "COMMUNITY_ADVISOR_REQUEST"); } else { SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai nguoi goi hien tai!"); return 1; } }
	else if(strcmp(choice,"taxi",true) == 0)
	{
		if(TransportDuty[playerid] == 1 && TaxiCallTime[playerid] > 0)
		{
			GameTextForPlayer(TaxiAccepted[playerid], "~w~Taxi Driver~n~~r~Da huy cuoc goi", 5000, 1);
			DeletePVar(TaxiAccepted[playerid], "TaxiCall");
			TaxiAccepted[playerid] = INVALID_PLAYER_ID;
			GameTextForPlayer(playerid, "~w~Ban da~n~~r~Huy cuoc goi", 5000, 1);
			TaxiCallTime[playerid] = 0;
			DisablePlayerCheckpoint(playerid);
		}
		else
		{
			if(GetPVarInt(playerid, "TaxiCall")) DeletePVar(playerid, "TaxiCall");
			else {
				foreach(new i: Player)
				{
					if(TaxiAccepted[i] != INVALID_PLAYER_ID && TaxiAccepted[i] == playerid)
					{
							GameTextForPlayer(i, "~w~Nguoi goi Taxi~n~~r~Da huy cuoc goi", 5000, 1);
							TaxiCallTime[i] = 0;
							DeletePVar(TaxiAccepted[i], "TaxiCall");
							TaxiAccepted[i] = INVALID_PLAYER_ID;
							DisablePlayerCheckpoint(i);
					}
				}
			}
		}
	}
	else if(strcmp(choice,"bus",true) == 0)
	{
		if(TransportDuty[playerid] == 2 && BusCallTime[playerid] > 0)
		{
			GameTextForPlayer(BusAccepted[playerid], "~w~Bus Driver~n~~r~Da huy cuoc goi", 5000, 1);
			DeletePVar(BusAccepted[playerid], "BusCall");
			BusAccepted[playerid] = INVALID_PLAYER_ID;
			GameTextForPlayer(playerid, "~w~Ban da~n~~r~Huy cuoc goi", 5000, 1);
			BusCallTime[playerid] = 0;
			DisablePlayerCheckpoint(playerid);
		}
		else
		{
			foreach(new i: Player)
			{
				if(BusAccepted[i] != INVALID_PLAYER_ID && BusAccepted[i] == playerid)
				{
					GameTextForPlayer(i, "~w~Nguoi goi Bus~n~~r~Da huy cuoc goi", 5000, 1);
					BusCallTime[i] = 0;
					DeletePVar(BusAccepted[i], "BusCall");
					BusAccepted[i] = INVALID_PLAYER_ID;
					DisablePlayerCheckpoint(i);
				}
			}
		}
	}
	else if(strcmp(choice,"foodoffer",true) == 0) {
		new offeredTo = GetPVarInt(playerid, "OfferedMealTo");
		DeletePVar(offeredTo, "OfferedMeal");
		DeletePVar(offeredTo, "OfferedMealBy");
		DeletePVar(playerid, "OfferingMeal");
		DeletePVar(playerid, "OfferedMealTo");
	}
	else { return 1; }
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da huy: %s.", choice);
	return 1;
}

CMD:refill(playerid, params[])
{
	if(!Job_HasJob(playerid, JOB_MECHANIC))
	{
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Mechanic.");
	}

	if(PlayerIsDead[playerid] || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") || GetPVarType(playerid, "IsFrozen") || GetPVarType(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") || PlayerInfo[playerid][pHospital] > 0)
		return SendClientMessageEx(playerid, COLOR_GREY, "Luc nay khong the lam Mechanic.");
	if(GetPVarType(playerid, "FixVehicleTimer")) return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang sua xe.");
	new string[128];
	if(gettime() < PlayerInfo[playerid][pMechTime])
	{
		return SendClientMessageEx(playerid, COLOR_GRAD1,"Ban phai cho %d giay!", PlayerInfo[playerid][pMechTime]-gettime());
	}
	new giveplayerid, money;
	if(sscanf(params, "ud", giveplayerid, money)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /refill [player] [price]");

	if(!(money >= 1 && money < 100000))
	{
		return SendClientMessageEx(playerid, COLOR_GREY, "Gia phai tu 1 den $99,999.");
	}
	if(IsPlayerConnected(giveplayerid))
	{
		new vehicleid = GetPlayerVehicleID(giveplayerid);
		if(IsPlayerInAnyVehicle(giveplayerid) && Mechanic_NearVehicle(playerid, vehicleid, 8.0) && Mechanic_NearVehicle(giveplayerid, vehicleid, 8.0))
		{

			if(VehicleFuel[vehicleid] >= 100.0) return SendClientMessageEx(playerid, COLOR_GREY, "Binh xang xe da day.");
			new Float:fueltogive = Mechanic_RefillAmount(PlayerInfo[playerid][pMechSkill]);
			if(VehicleFuel[vehicleid] + fueltogive > 100.0) fueltogive = 100.0 - VehicleFuel[vehicleid];
			if(giveplayerid == playerid)
			{
				if(PlayerInfo[playerid][pMechSkill] >= 400)
				{
					if(GetPVarInt(playerid, "MCH_CLDWN") > gettime()) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the do xang nhanh nhu vay!");

					SetPVarInt(playerid, "MCH_CLDWN", gettime()+10);

					VehicleFuel[vehicleid] += fueltogive;
					format(string, sizeof(string), "* %s do xang cho xe cua minh.", GetPlayerNameEx(playerid));
					ProxChatBubble(playerid, string);
					// ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban them %.2f nhien lieu vao xe.", fueltogive);
					new vehicleslot = GetPlayerVehicle(playerid, vehicleid);
					if(vehicleslot != -1)
					{
						mysql_format(MainPipeline, string, sizeof(string), "UPDATE `vehicles` SET `pvFuel` = %0.5f WHERE `id` = '%d'", VehicleFuel[vehicleid], PlayerVehicleInfo[playerid][vehicleslot][pvSlotId]);
						mysql_tquery(MainPipeline, string, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
					}
					return 1;
				}
				SendClientMessageEx(playerid, COLOR_GREY, "Khong the de nghi do xang cho chinh minh."); return 1;
			}
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban de nghi %s them %.2f nhien lieu gia $%d.",GetPlayerNameEx(giveplayerid),fueltogive,money);
			SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Car Mechanic %s muon them %.2f nhien lieu gia $%d, dung /accept refill de nhan.",GetPlayerNameEx(playerid),fueltogive,money);
			PlayerInfo[playerid][pMechTime] = gettime()+60;
			SetPVarInt(giveplayerid, "RefillVehicle", vehicleid);
			RefillOffer[giveplayerid] = playerid;
			SetPVarInt(giveplayerid, "RefillOfferSession", g_arrQueryHandle[playerid]);
			RefillPrice[giveplayerid] = money;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan hoac khong o trong xe.");
		}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	return 1;
}

CMD:repair(playerid, params[])
{
	if(!Job_HasJob(playerid, JOB_MECHANIC))
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Car Mechanic!");
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the sua xe khi o trong xe.");
	if(PlayerIsDead[playerid] || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") || GetPVarType(playerid, "IsFrozen") || GetPVarType(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") || PlayerInfo[playerid][pHospital] > 0)
		return SendClientMessageEx(playerid, COLOR_GREY, "Luc nay khong the lam Mechanic.");
	if(GetPVarType(playerid, "FixVehicleTimer")) return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang sua xe.");
	if(gettime() < PlayerInfo[playerid][pMechTime]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban phai cho %d giay!", PlayerInfo[playerid][pMechTime]-gettime());
	new giveplayerid, money;
	if(sscanf(params, "ud", giveplayerid, money)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /repair [player] [price]");
	if(PlayerInfo[playerid][pTire] <= 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co lop xe, hay mua tu Craftsman.");
	if(money < 1 || money > 10000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia phai tu $1 den $10,000!");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang offline.");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay!");
	new vehicleid = GetPlayerVehicleID(giveplayerid);
	if(!IsPlayerInAnyVehicle(giveplayerid) || !Mechanic_NearVehicle(playerid, vehicleid, 8.0) || !Mechanic_NearVehicle(giveplayerid, vehicleid, 8.0))
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan hoac khong o trong xe.");
	if(!IsABike(vehicleid) && !IsAPlane(vehicleid))
	{
		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		if(bonnet != VEHICLE_PARAMS_ON) return SendClientMessageEx(playerid, COLOR_GRAD1, "Can mo nap capo de sua xe.");
	}
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban de nghi %s sua xe voi gia $%d.", GetPlayerNameEx(giveplayerid), money);
	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Car Mechanic %s muon sua xe gia $%d, (dung /accept repair) de nhan.", GetPlayerNameEx(playerid), money);
	PlayerInfo[playerid][pMechTime] = gettime()+60;
	SetPVarInt(playerid, "RepairOfferTo", giveplayerid);
	RepairOffer[giveplayerid] = playerid;
	RepairCar[giveplayerid] = vehicleid;
	SetPVarInt(giveplayerid, "RepairOfferSession", g_arrQueryHandle[playerid]);
	RepairPrice[giveplayerid] = money;
	return 1;
}
