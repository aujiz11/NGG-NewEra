/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Shipment System

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

#include <YSI_Coding\y_hooks>

stock Shipment_IsDriver(playerid, vehicleid)
{
	return 0 < vehicleid < MAX_VEHICLES && IsValidVehicle(vehicleid) && IsATruckerCar(vehicleid)
		&& GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == vehicleid
		&& GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0
		&& GetVehicleVirtualWorld(vehicleid) == 0 && GetVehicleInterior(vehicleid) == 0
		&& !PlayerIsDead[playerid] && !GetPVarType(playerid, "Injured") && !GetPVarType(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged")
		&& (PlayerInfo[playerid][pJob] == 20 || PlayerInfo[playerid][pJob2] == 20 || PlayerInfo[playerid][pJob3] == 20);
}

stock Shipment_OrderFits(model, type)
{
	if(type == BUSINESS_TYPE_NEWCARDEALERSHIP) return model == 443;
	if(type == BUSINESS_TYPE_GASSTATION) return model == 514;
	return model != 443 && model != 514;
}

stock Shipment_CanLoad(playerid)
{
	new vehicleid = GetPVarInt(playerid, "ShipmentVehicle");
	if(!Shipment_IsDriver(playerid, vehicleid) || TruckUsed[playerid] != vehicleid || GetPVarType(playerid, "ShipmentTimer")) 
		return 0;
	
	if(TruckContents{vehicleid} != 0 || TruckDeliveringTo[vehicleid] != INVALID_BUSINESS_ID) 
		return 0;
	
	if(IsABoat(vehicleid)) return IsPlayerInRangeOfPoint(playerid, 6.0, 2098.6543, -104.3568, -0.4820);
	
	return IsPlayerInRangeOfPoint(playerid, 6.0, -1572.767822, 81.137527, 3.554687);
}

stock Shipment_StopLoading(playerid, bool:restore = true)
{
	new bool:loading = GetPVarType(playerid, "ShipmentVehicle") != 0;
	KillTimer(GetPVarInt(playerid, "ShipmentTimer"));
	DeletePVar(playerid, "ShipmentTimer");
	DeletePVar(playerid, "ShipmentVehicle");
	DeletePVar(playerid, "ShipmentOrderCount");
	DeletePVar(playerid, "ShipmentOrderNext");
	DeletePVar(playerid, "LoadTruckTime");
	if(loading && restore && !PlayerIsDead[playerid] && !GetPVarType(playerid, "PlayerCuffed")
		&& !GetPVarInt(playerid, "pBagged") && !GetPVarType(playerid, "Injured") && !GetPVarType(playerid, "IsTackled"))
	{
		DeletePVar(playerid, "IsFrozen");
		TogglePlayerControllable(playerid, true);
	}
	return 1;
}

stock Shipment_BeginLoading(playerid, vehicleid, const callback[])
{
	SetPVarInt(playerid, "ShipmentVehicle", vehicleid);
	SetPVarInt(playerid, "LoadTruckTime", 10);
	SetPVarInt(playerid, "ShipmentTimer", SetTimerEx(callback, 1000, true, "iii", playerid, vehicleid, g_arrQueryHandle[playerid]));
	TogglePlayerControllable(playerid, false);
	SetPVarInt(playerid, "IsFrozen", 1);
	return 1;
}

stock Shipment_LoadTick(playerid, vehicleid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session) return 0;
	if(!GetPVarType(playerid, "ShipmentTimer") || GetPVarInt(playerid, "ShipmentVehicle") != vehicleid) return 0;
	if(!Shipment_IsDriver(playerid, vehicleid))
	{
		if(TruckUsed[playerid] == vehicleid) CancelTruckDelivery(playerid, false);
		else Shipment_StopLoading(playerid);
		SendClientMessageEx(playerid, COLOR_WHITE, "Shipment loading was cancelled because you are no longer driving the original vehicle.");
		return 0;
	}
	new remaining = GetPVarInt(playerid, "LoadTruckTime") - 1, string[96];
	SetPVarInt(playerid, "LoadTruckTime", remaining);
	format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~%d seconds left", remaining);
	GameTextForPlayer(playerid, string, 1100, 3);
	return remaining <= 0;
}

stock Shipment_SetDestination(playerid, vehicleid, bool:hijacked = false)
{
	new business = TruckDeliveringTo[vehicleid], cargo = TruckContents{vehicleid};
	if(cargo == 0)
	{
		if(!(0 <= business < MAX_BUSINESSES) || Businesses[business][bOrderState] != 2) return 0;
		gPlayerCheckpointStatus[playerid] = CHECKPOINT_DELIVERY;
		SetPlayerCheckpoint(playerid, Businesses[business][bSupplyPos][0], Businesses[business][bSupplyPos][1], Businesses[business][bSupplyPos][2], 10.0);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "%s %s.", hijacked ? ("You hijacked a shipment of") : ("Your truck was filled with"), GetInventoryType(business));
		SetPVarInt(playerid, "TruckRunDeadline", gettime() + floatround(GetPlayerDistanceFromPoint(playerid, Businesses[business][bSupplyPos][0], Businesses[business][bSupplyPos][1], Businesses[business][bSupplyPos][2]) / 100));
	}
	else
	{
		if(!(1 <= cargo <= 7)) return 0;
		new route = TruckRoute[vehicleid];
		if(IsABoat(vehicleid))
		{
			if(!(0 <= route < sizeof(BoatDropoffs))) return 0;
			SetPlayerCheckpoint(playerid, BoatDropoffs[route][PosX], BoatDropoffs[route][PosY], BoatDropoffs[route][PosZ], 5.0);
		}
		else
		{
			if(!(0 <= route < sizeof(TruckerDropoffs))) return 0;
			SetPlayerCheckpoint(playerid, TruckerDropoffs[route][PosX], TruckerDropoffs[route][PosY], TruckerDropoffs[route][PosZ], 5.0);
		}
		static const names[][] = {"food & beverages", "clothing", "materials", "24/7 items", "weapons", "drugs", "illegal materials"};
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "%s %s.", hijacked ? ("You hijacked a shipment of") : ("Your vehicle was filled with"), names[cargo - 1]);
		SetPVarInt(playerid, "TruckDeliver", cargo);
		SetPVarInt(playerid, "TruckRunDeadline", gettime() + 30);
	}
	SendClientMessageEx(playerid, COLOR_WHITE, "HINT: Deliver the goods to the specified location (see checkpoint on radar).");
	SendClientMessageEx(playerid, COLOR_REALRED, "WARNING: Watch out for shipment hijackers, they can get away with the goods.");
	if(cargo >= 5 || (cargo == 0 && Businesses[business][bType] == BUSINESS_TYPE_GUNSHOP))
		SendClientMessageEx(playerid, COLOR_REALRED, "WARNING #2: You are transporting illegal goods so watch out for law enforcement.");
	return 1;
}

forward HijackTruck(playerid, vehicleid, session);
public HijackTruck(playerid, vehicleid, session)
{
	if(!Shipment_LoadTick(playerid, vehicleid, session)) return 1;
	Shipment_StopLoading(playerid);
	new trailerid;
	foreach(new i: Player)
	{
		if(i == playerid || TruckUsed[i] != vehicleid) continue;
		trailerid = GetPVarInt(i, "Gas_TrailerID");
		DeletePVar(i, "Gas_TrailerID");
		KillTimer(GetPVarInt(i, "ShipmentTrailerTimer"));
		DeletePVar(i, "ShipmentTrailerTimer");
		Shipment_StopLoading(i);
		TruckUsed[i] = INVALID_VEHICLE_ID;
		DeletePVar(i, "TruckDeliver");
		DeletePVar(i, "TruckRunDeadline");
		gPlayerCheckpointStatus[i] = CHECKPOINT_NONE;
		DisablePlayerCheckpoint(i);
		SendClientMessageEx(i, COLOR_WHITE, "Your shipment delivery has failed. Your shipment was hijacked.");
	}
	TruckUsed[playerid] = vehicleid;
	if(trailerid && IsValidVehicle(trailerid)) SetPVarInt(playerid, "Gas_TrailerID", trailerid);
	if(!Shipment_SetDestination(playerid, vehicleid, true))
	{
		CancelTruckDelivery(playerid, false);
		SendClientMessageEx(playerid, COLOR_WHITE, "This shipment is no longer available.");
	}
	return 1;
}

forward LoadTruckOld(playerid, vehicleid, session);
public LoadTruckOld(playerid, vehicleid, session)
{
	if(!Shipment_LoadTick(playerid, vehicleid, session)) return 1;
	new cargo = GetPVarInt(playerid, "TruckDeliver");
	Shipment_StopLoading(playerid);
	if(!(1 <= cargo <= 7) || TruckContents{vehicleid} != 0 || TruckDeliveringTo[vehicleid] != INVALID_BUSINESS_ID)
	{
		CancelTruckDelivery(playerid, false);
		return 1;
	}
	TruckContents{vehicleid} = cargo;
	TruckRoute[vehicleid] = IsABoat(vehicleid) ? random(sizeof(BoatDropoffs)) : random(sizeof(TruckerDropoffs));
	Shipment_SetDestination(playerid, vehicleid);
	return 1;
}

forward LoadTruck(playerid, vehicleid, session);
public LoadTruck(playerid, vehicleid, session)
{
	if(!Shipment_LoadTick(playerid, vehicleid, session)) return 1;
	Shipment_StopLoading(playerid);
	if(!Shipment_SetDestination(playerid, vehicleid))
	{
		CancelTruckDelivery(playerid, false);
		return 1;
	}
	new business = TruckDeliveringTo[vehicleid];
	if(Businesses[business][bType] == BUSINESS_TYPE_GASSTATION)
	{
		SetVehiclePos(vehicleid, -1570.9833, 96.7547, 4.1442);
		SetVehicleZAngle(vehicleid, 136.18);
		new trailerid = CreateVehicle(584, -1570.9833, 96.7547, 5.1442, 136.18, -1, -1, -1);
		if(trailerid == INVALID_VEHICLE_ID)
		{
			CancelTruckDelivery(playerid, false);
			return SendClientMessageEx(playerid, COLOR_WHITE, "Unable to create the shipment trailer. Please try again.");
		}
		SetPVarInt(playerid, "Gas_TrailerID", trailerid);
		SetPVarInt(playerid, "ShipmentTrailerTimer", SetTimerEx("AttachGasTrailer", 500, false, "iiii", playerid, vehicleid, trailerid, session));
	}
	return 1;
}

forward AttachGasTrailer(playerid, vehicleid, trailerid, session);
public AttachGasTrailer(playerid, vehicleid, trailerid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session) return 1;
	if(TruckUsed[playerid] != vehicleid || GetPVarInt(playerid, "Gas_TrailerID") != trailerid) return 1;
	DeletePVar(playerid, "ShipmentTrailerTimer");
	if(!IsValidVehicle(vehicleid) || !IsValidVehicle(trailerid) || !AttachTrailerToVehicle(trailerid, vehicleid)) CancelTruckDelivery(playerid, false);
	return 1;
}

stock DisplayOrders(playerid, offset = 0)
{
	if(!Shipment_CanLoad(playerid)) return CancelTruckDelivery(playerid, false);
	new vehicleid = TruckUsed[playerid], model = GetVehicleModel(vehicleid);
	new szDialog[2048], row[96], shown, skipped;
	DeletePVar(playerid, "ShipmentOrderNext");
	for(new i; i < MAX_BUSINESSES; ++i)
	{
		if(IsABoat(vehicleid) || Businesses[i][bOrderState] != 1 || Businesses[i][bType] <= 0 || !Shipment_OrderFits(model, Businesses[i][bType])) continue;
		if(skipped++ < offset) continue;
		if(shown == sizeof(ListItemTrackId[]) || strlen(szDialog) + 96 >= sizeof(szDialog))
		{
			strcat(szDialog, "More orders...\n", sizeof(szDialog));
			SetPVarInt(playerid, "ShipmentOrderNext", offset + shown);
			break;
		}
		format(row, sizeof(row), "%s\t%s\n", Businesses[i][bName], GetInventoryType(i));
		strcat(szDialog, row, sizeof(szDialog));
		ListItemTrackId[playerid][shown++] = i;
	}
	SetPVarInt(playerid, "ShipmentOrderCount", shown);
	if(shown) ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCK, DIALOG_STYLE_LIST, "Available Orders", szDialog, "Take", "Close");
	else if(model == 456 || model == 414 || model == 413 || model == 440 || model == 482 || IsABoat(vehicleid))
		ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCKOLD, DIALOG_STYLE_LIST, "What do you want to transport?", "{00F70C}Legal goods {FFFFFF}(no risk but also no bonuses)\n{FF0606}Illegal goods {FFFFFF}(risk of getting caught but a bonus)", "Select", "Cancel");
	else
	{
		CancelTruckDelivery(playerid, false);
		ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Error", "No jobs available for this type of truck right now. Try again later.", "OK", "");
	}
	return 1;
}

stock IsAtTruckDeliveryPoint(playerid)
{
	new vehicleid = TruckUsed[playerid];
	if(!Shipment_IsDriver(playerid, vehicleid)) return 0;
	new route = TruckRoute[vehicleid];
	if(IsABoat(vehicleid))
	{
		if(!(0 <= route < sizeof(BoatDropoffs))) return 0;
		return IsPlayerInRangeOfPoint(playerid, 6.0, BoatDropoffs[route][PosX], BoatDropoffs[route][PosY], BoatDropoffs[route][PosZ]);
	}
	if(!(0 <= route < sizeof(TruckerDropoffs))) return 0;
	return IsPlayerInRangeOfPoint(playerid, 6.0, TruckerDropoffs[route][PosX], TruckerDropoffs[route][PosY], TruckerDropoffs[route][PosZ]);
}

stock CancelTruckDelivery(playerid, bool:respawn = true, bool:restore = true)
{
	new vehicleid = TruckUsed[playerid], trailerid = GetPVarInt(playerid, "Gas_TrailerID");
	TruckUsed[playerid] = INVALID_VEHICLE_ID;
	Shipment_StopLoading(playerid, restore);
	KillTimer(GetPVarInt(playerid, "ShipmentTrailerTimer"));
	DeletePVar(playerid, "ShipmentTrailerTimer");
	DeletePVar(playerid, "Gas_TrailerID");
	DeletePVar(playerid, "GasWarnings");
	DeletePVar(playerid, "TruckDeliver");
	DeletePVar(playerid, "TruckRunDeadline");
	DeletePVar(playerid, "LoadType");
	if(gPlayerCheckpointStatus[playerid] == CHECKPOINT_LOADTRUCK || gPlayerCheckpointStatus[playerid] == CHECKPOINT_DELIVERY
		|| gPlayerCheckpointStatus[playerid] == CHECKPOINT_RETURNTRUCK || 0 < vehicleid < MAX_VEHICLES)
	{
		gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
		DisablePlayerCheckpoint(playerid);
	}
	if(0 < vehicleid < MAX_VEHICLES)
	{
		new business = TruckDeliveringTo[vehicleid];
		TruckDeliveringTo[vehicleid] = INVALID_BUSINESS_ID;
		TruckContents{vehicleid} = 0;
		TruckRoute[vehicleid] = 0;
		if(0 <= business < MAX_BUSINESSES && Businesses[business][bOrderState] == 2)
		{
			Businesses[business][bOrderState] = 1;
			SaveBusiness(business);
		}
	}
	if(trailerid && IsValidVehicle(trailerid)) DestroyVehicle(trailerid);
	if(respawn && 0 < vehicleid < MAX_VEHICLES && IsValidVehicle(vehicleid) && IsATruckerCar(vehicleid)) SetVehicleToRespawn(vehicleid);
	return 1;
}

stock Shipment_ClearVehicleWork(playerid, vehicleid)
{
	if(!(0 < vehicleid < MAX_VEHICLES)) return 0;
	if(TruckUsed[playerid] == vehicleid || GetPVarInt(playerid, "Gas_TrailerID") == vehicleid)
	{
		if(GetPVarInt(playerid, "Gas_TrailerID") == vehicleid) DeletePVar(playerid, "Gas_TrailerID");
		CancelTruckDelivery(playerid, false);
	}
	else if(GetPVarInt(playerid, "ShipmentVehicle") == vehicleid) Shipment_StopLoading(playerid);
	return 1;
}

stock Shipment_ShowWeaponReward(playerid, count)
{
	new menu[64] = "9mm\nShotgun";
	if(count >= 3) strcat(menu, "\nMP5", sizeof(menu));
	if(count >= 4) strcat(menu, "\nDeagle", sizeof(menu));
	if(count >= 5) strcat(menu, "\nAK-47", sizeof(menu));
	SetPVarInt(playerid, "ShipmentWeaponReward", count);
	return ShowPlayerDialogEx(playerid, D_TRUCKDELIVER_WEPCHOICE, DIALOG_STYLE_LIST, "Select your reward", menu, "Select", "");
}

CMD:checkcargo(playerid, params[])
{
	if(PlayerInfo[playerid][pJob] != 20 && PlayerInfo[playerid][pJob2] != 20 && PlayerInfo[playerid][pJob3] != 20 && !IsACop(playerid))
	{
        SendClientMessageEx(playerid, COLOR_GRAD2, "You are not a Shipment Contractor or a Cop!");
        return 1;
	}

	new carid = GetPlayerVehicleID(playerid);
 	new closestcar = GetClosestCar(playerid, carid);
	if(0 < closestcar < MAX_VEHICLES && IsValidVehicle(closestcar) && GetVehicleVirtualWorld(closestcar) == GetPlayerVirtualWorld(playerid)
		&& GetVehicleInterior(closestcar) == GetPlayerInterior(playerid) && IsPlayerInRangeOfVehicle(playerid, closestcar, 6.0) && IsATruckerCar(closestcar))
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot search the contents of this vehicle while inside a vehicle.");
			return 1;
		}
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(closestcar,engine,lights,alarm,doors,bonnet,boot,objective);
		if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "The vehicle's trunk must be opened in order to search it.");
			return 1;
		}


     	SendClientMessageEx(playerid, COLOR_GREEN,"_______________ SHIPMENT CONTRACTOR LOAD SHEET _______________");
		if(GetVehicleDriver(closestcar) != INVALID_PLAYER_ID)
  		{
    		SendClientMessageEx(playerid, COLOR_WHITE, "There is a person in that truck. In order to check the content of the truck, the driver must be removed.");
      		return 1;
		}
		new iTruckContents = TruckContents{closestcar};
		new truckcontentname[50];
		if(iTruckContents == 1)
		{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Food & beverages");}
		else if(iTruckContents == 2)
		{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Clothing"); }
		else if(iTruckContents == 3)
		{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Legal materials"); }
		else if(iTruckContents == 4)
		{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}24/7 items"); }
		else if(iTruckContents == 5)
		{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Illegal weapons"); }
		else if(iTruckContents == 6)
		{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Illegal drugs"); }
		else if(iTruckContents == 7)
		{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Illegal materials"); }
		SendClientMessageEx(playerid, COLOR_WHITE, "Vehicle registration: %s (%d)", GetVehicleName(closestcar), closestcar);
		if(iTruckContents == 0)
		{
			new business = TruckDeliveringTo[closestcar];
			if(0 <= business < MAX_BUSINESSES) format(truckcontentname, sizeof(truckcontentname), "%s", GetInventoryType(business));
			else truckcontentname = "Empty";
		}
		SendClientMessageEx(playerid, COLOR_WHITE, "Content: %s", truckcontentname);

		if(IsACop(playerid))
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "To remove the illegal goods, type /clearcargo near the truck.");
		}

		if(PlayerInfo[playerid][pJob] == 20 || PlayerInfo[playerid][pJob2] == 20 || PlayerInfo[playerid][pJob3] == 20)
		{
			if((TruckContents{closestcar} > 0 || (0 <= TruckDeliveringTo[closestcar] < MAX_BUSINESSES && Businesses[TruckDeliveringTo[closestcar]][bOrderState] == 2)) && TruckUsed[playerid] == INVALID_VEHICLE_ID)
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "To deliver the goods, type /hijackcargo as the driver.");
			}
			else if(TruckUsed[playerid] == INVALID_VEHICLE_ID)
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "To get goods, type /loadshipment as the driver.");
			}
			else if(TruckUsed[playerid] == closestcar && gPlayerCheckpointStatus[playerid] == CHECKPOINT_RETURNTRUCK)
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "This is your Shipment Transport Vehicle. You have not returned it to the docks yet for your pay.");
			}
			else if(TruckUsed[playerid] == closestcar)
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "This is your Shipment Transport Vehicle. You have not delivered your goods yet.");
			}
			else if(TruckUsed[playerid] != INVALID_VEHICLE_ID)
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "You are already on another delivery. Type /cancel shipment to cancel that delivery.");
			}
		}
     	SendClientMessageEx(playerid, COLOR_GREEN,"_________________________________________________________");
    }
	else
	{
 		SendClientMessageEx(playerid, COLOR_GRAD1, "You are not near a Shipment Transport Vehicle.");
 	}
    return 1;
}

CMD:hijackcargo(playerid, params[])
{
	if(PlayerInfo[playerid][pJob] == 20 || PlayerInfo[playerid][pJob2] == 20 || PlayerInfo[playerid][pJob3] == 20)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(Shipment_IsDriver(playerid, vehicleid))
	    {
     		if(!CheckPointCheck(playerid))
	        {
         		if(GetPVarInt(playerid, "LoadTruckTime") > 0)
	            {
	                SendClientMessageEx(playerid, COLOR_WHITE, "You are currently loading your Truck!");
					return 1;
	            }
	            if(TruckUsed[playerid] != INVALID_VEHICLE_ID)
	            {
	                SendClientMessageEx(playerid, COLOR_WHITE, "You are already on another delivery, type /cancel shipment to cancel that delivery.");
					return 1;
	            }
				new business = TruckDeliveringTo[vehicleid];
				if(TruckContents{vehicleid} == 0 && (!(0 <= business < MAX_BUSINESSES) || Businesses[business][bOrderState] != 2))
				{
				    SendClientMessageEx(playerid, COLOR_WHITE, "This Truck is empty, it does not contain any goods!");
				    return 1;
				}
				if(IsPlayerInRangeOfPoint(playerid, 65, -1572.767822, 81.137527, 3.554687))
				{
				    SendClientMessageEx(playerid, COLOR_WHITE, "You can not hijack when that close to the San Fierro Docks!");
					return 1;
				}
				if(!IsABoat(vehicleid))
				{
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* You are now attempting to hijack the truck, please wait....");
				} 
				else 
				{
					if(PlayerInfo[playerid][pTruckSkill] >= 200)
					{
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* You are now attempting to hijack the boat, please wait....");
					}
					else return SendClientMessageEx(playerid, COLOR_WHITE, "Water shipments are restricted to Level 4+ Shipment Contracter.");
				}

				Shipment_BeginLoading(playerid, vehicleid, "HijackTruck");
	        }
	        else return SendClientMessageEx(playerid, COLOR_WHITE, "Please ensure that your current checkpoint is destroyed first (you either have material packages, or another existing checkpoint).");
	    }
	    else return SendClientMessageEx(playerid, COLOR_GREY, "You are not driving a Shipment Transport Vehicle!");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "You are not a Shipment Contractor!");
	return 1;
}

CMD:loadshipment(playerid, params[])
{
	if(PlayerInfo[playerid][pJob] == 20 || PlayerInfo[playerid][pJob2] == 20 || PlayerInfo[playerid][pJob3] == 20)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(Shipment_IsDriver(playerid, vehicleid))
	    {
	        if(!CheckPointCheck(playerid))
	        {
	            if(GetPVarInt(playerid, "LoadTruckTime") > 0)
	            {
	                SendClientMessageEx(playerid, COLOR_WHITE, "You are currently loading the Shipment!");
					return 1;
	            }
	            if(TruckUsed[playerid] != INVALID_VEHICLE_ID)
	            {
	                SendClientMessageEx(playerid, COLOR_WHITE, "You are already on another delivery, type /cancel shipment to cancel that delivery.");
					return 1;
	            }
				if(TruckContents{vehicleid} != 0)
				{
				    return SendClientMessageEx(playerid, COLOR_GRAD2, "That vehicle is already loaded.");
				}
				if(TruckDeliveringTo[vehicleid] != INVALID_BUSINESS_ID && TruckContents{vehicleid} == 0)
				{
				    return SendClientMessageEx(playerid, COLOR_GRAD2, "That vehicle is already loaded.");
				}
				if(GetVehicleModel(vehicleid) == 440 || GetVehicleModel(vehicleid) == 413) // Level Three Vehicle Check
				{
					if(PlayerInfo[playerid][pTruckSkill] < 100) 
					{
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Only level 3 Shipment Contractors may use this vehicle.");
					}
				}
				if(GetVehicleModel(vehicleid) == 482) // Level Five Vehicle Check
				{
					if(PlayerInfo[playerid][pTruckSkill] < 400)  
					{
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Only level 5 Shipment Contractors may use this vehicle.");
					}
				}
	            if(!IsABoat(vehicleid))
	            {
		            SetPlayerCheckpoint(playerid,-1572.767822, 81.137527, 3.554687, 4);
		            GameTextForPlayer(playerid, "~w~Waypoint set ~r~San Fierro Docks", 5000, 1);
		            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Pick up some goods to transport with your Truck at San Fierro Docks (see checkpoint on radar).");
				}
				else
				{
					if(PlayerInfo[playerid][pTruckSkill] >= 200)
					{
						SetPlayerCheckpoint(playerid,2098.6543,-104.3568,-0.4820, 4);
						GameTextForPlayer(playerid, "~w~Waypoint set ~r~Palamino Docks", 5000, 1);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Pick up some goods to transport with your Boat at Palamino Docks (see checkpoint on radar).");
					}
					else return SendClientMessageEx(playerid, COLOR_WHITE, "Water shipments are restricted to Level 4+ Shipment Contracter.");
				}
				TruckUsed[playerid] = vehicleid;
				gPlayerCheckpointStatus[playerid] = CHECKPOINT_LOADTRUCK;
	        }
	        else return SendClientMessageEx(playerid, COLOR_WHITE, "Please ensure that your current checkpoint is destroyed first (you either have material packages, or another existing checkpoint).");
	    }
	    else return SendClientMessageEx(playerid, COLOR_GREY, "You are not driving a Shipment Transport Vehicle!");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "You are not a Shipment Contractor!");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid != D_TRUCKDELIVER_WEPCHOICE) return 0;
	new count = GetPVarInt(playerid, "ShipmentWeaponReward");
	if(!gPlayerLogged{playerid} || !(2 <= count <= 5)) return 1;
	if(PlayerInfo[playerid][pConnectHours] < 2 || PlayerInfo[playerid][pWRestricted] > 0)
	{
		DeletePVar(playerid, "ShipmentWeaponReward");
		return 1;
	}
	if(!response) return Shipment_ShowWeaponReward(playerid, count);
	if(!(0 <= listitem < count)) return 1;
	DeletePVar(playerid, "ShipmentWeaponReward");
	switch(listitem)
	{
		case 0: GivePlayerValidWeapon(playerid, WEAPON_COLT45);
		case 1: GivePlayerValidWeapon(playerid, WEAPON_SHOTGUN);
		case 2: GivePlayerValidWeapon(playerid, WEAPON_MP5);
		case 3: GivePlayerValidWeapon(playerid, WEAPON_DEAGLE);
		case 4: GivePlayerValidWeapon(playerid, WEAPON_AK47);
	}
	return 1;
}
