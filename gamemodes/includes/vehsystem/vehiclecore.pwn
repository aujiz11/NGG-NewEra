/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Vehicle Functions

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

stock vehicle_lock_doors(vehicle) {

	new
		vParamArr[7];

	GetVehicleParamsEx(vehicle, vParamArr[0], vParamArr[1], vParamArr[2], vParamArr[3], vParamArr[4], vParamArr[5], vParamArr[6]);
	// if(IsABike(vehicle)) return SetVehicleParamsEx(vehicle, vParamArr[0], vParamArr[1], vParamArr[2], VEHICLE_PARAMS_OFF, vParamArr[4], vParamArr[5], vParamArr[6]);
	return SetVehicleParamsEx(vehicle, vParamArr[0], vParamArr[1], vParamArr[2], VEHICLE_PARAMS_ON, vParamArr[4], vParamArr[5], vParamArr[6]);
}

stock vehicle_unlock_doors(vehicle) {

	new
		vParamArr[7];

	GetVehicleParamsEx(vehicle, vParamArr[0], vParamArr[1], vParamArr[2], vParamArr[3], vParamArr[4], vParamArr[5], vParamArr[6]);
	return SetVehicleParamsEx(vehicle, vParamArr[0], vParamArr[1], vParamArr[2], VEHICLE_PARAMS_OFF, vParamArr[4], vParamArr[5], vParamArr[6]);
}

stock IsSeatAvailable(vehicleid, seat)
{
	switch(GetVehicleModel(vehicleid)) {
		case 425, 430, 432, 441, 446, 448, 452, 453, 454, 464, 465, 472, 473, 476, 481, 484, 485, 486, 493, 501, 509, 510, 519, 520, 530, 531, 532, 539, 553, 564, 568, 571, 572, 574, 583, 592, 594, 595: return 0;
		default: if(IsVehicleSeatOccupied(vehicleid, seat)) return 0;
	}
	return 1;
}

stock IsPlayerInInvalidNosVehicle(playerid)
{
	switch(GetVehicleModel(GetPlayerVehicleID(playerid))) {
		case 430, 446, 448, 449, 452, 453, 454, 461, 462, 463, 468, 472, 473, 481, 484, 493, 509, 510, 521, 522, 523, 537, 538, 569, 570, 581, 586, 590, 595: return 1;
	}
	return 0;
}


stock IsARC(carid)
{
	switch(GetVehicleModel(carid)) {
		case 441, 464, 465, 501, 564: return 1;
	}
	return 0;
}

stock IsABoat(carid) {
	switch(GetVehicleModel(carid)) {
		case 472, 473, 493, 484, 430, 454, 453, 452, 446, 595: return 1;
	}
	return 0;
}

stock IsABike(carid) {
	switch(GetVehicleModel(carid)) {
		case 509, 481, 510, 462, 448, 581, 522, 461, 521, 523, 463, 586, 468, 471: return 1;
	}
	return 0;
}

stock IsATrain(modelid) {
	switch(modelid) {
		case 538, 537, 590, 569, 570: return 1;
	}
	return 0;
}

stock NoWindows(modelid) {
	switch(GetVehicleModel(modelid)) {
		case 509, 481, 510, 462, 448, 581, 522, 461, 521, 523, 463, 586, 468, 471, 431, 437, 472, 473, 493, 484, 430, 454, 453, 452, 446, 595: return 1;
	}
	return 0;
}

stock IsASpawnedTrain(carid) {
	switch(GetVehicleModel(carid)) {
		case 538, 537, 590, 569, 570: return 1;
	}
	return 0;
}

stock IsAPlane(carid, type = 0)
{
	if(type == 0)
	{
		switch(GetVehicleModel(carid)) {
			case 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 548, 425, 417, 487, 488, 497, 563, 447, 469: return 1;
		}
	}
	else
	{
		switch(carid) {
			case 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 548, 425, 417, 487, 488, 497, 563, 447, 469: return 1;
		}
	}
	return 0;
}

stock IsRestrictedVehicle(modelid)
{
	switch(modelid) {
		case 406, 407, 408, 416, 425, 430, 432, 433, 447, 464, 465, 476, 486, 488, 490, 497, 501, 520, 523, 524, 525, 528, 532, 544, 548, 552, 563, 564, 577, 582, 592, 594, 596, 597, 598, 599, 601, 610, 611: return 1;
	}
	return 0;
}

stock IsWeaponizedVehicle(modelid)
{
	switch(modelid) {
		case 425, 432, 447, 476, 520: return 1;
	}
	return 0;
}	

stock IsATruckerCar(carid)
{
	for(new v = 0; v < sizeof(TruckerVehicles); v++) {
	    if(carid == TruckerVehicles[v]) return 1;
	}
	return 0;
}

stock IsInGarbageTruck(id)
{
	for(new i = 0; i < sizeof(GarbageVehicles); i++)
	{
		if(id == GarbageVehicles[i]) return 1;
	}
	return 0;
}

stock IsAPizzaCar(carid)
{
	for (new v = 0; v < sizeof(PizzaVehicles); v++) {
	    if(carid == PizzaVehicles[v]) return 1;
	}
	return 0;
}

stock IsATowTruck(carid)
{
	if(GetVehicleModel(carid) == 525) {
		return 1;
	}
	return 0;
}

stock IsAAircraftTowTruck(carid)
{
	if(GetVehicleModel(carid) == 485 || GetVehicleModel(carid) == 583) {
		return 1;
	}
	return 0;
}
stock IsAHelicopter(carid)
{
	if(GetVehicleModel(carid) == 548 || GetVehicleModel(carid) == 425 || GetVehicleModel(carid) == 417 || GetVehicleModel(carid) == 487 || GetVehicleModel(carid) == 488 || GetVehicleModel(carid) == 497 || GetVehicleModel(carid) == 563 || GetVehicleModel(carid) == 447 || GetVehicleModel(carid) == 469 || GetVehicleModel(carid) == 593) {
		return 1;
	}
	return 0;
}


stock IsAnBus(carid)
{
	if(GetVehicleModel(carid) == 431 || GetVehicleModel(carid) == 437) {
		return 1;
	}
	return 0;
}

stock IsAnTaxi(carid)
{
	if(GetVehicleModel(carid) == 420 || GetVehicleModel(carid) == 438) {
		return 1;
	}
	return 0;
}

stock partType(type)
{
	new name[32];
	switch(type)
	{
	    case 0:
		{
			name = "Spoiler";
        }
        case 1:
		{
			name = "Hood";
        }
        case 2:
		{
			name = "Roof";
        }
        case 3:
		{
			name = "Sideskirt";
        }
        case 4:
		{
			name = "Lamps";
        }
        case 5:
		{
			name = "Nitro";
        }
        case 6:
		{
			name = "Exhaust";
        }
        case 7:
		{
			name = "Wheels";
        }
        case 8:
		{
			name = "Stereo";
        }
        case 9:
		{
			name = "Hydraulics";
        }
        case 10:
		{
			name = "Front Bumper";
        }
        case 11:
		{
			name = "Rear Bumper";
        }
        case 12:
		{
			name = "Left Vent";
        }
        case 13:
		{
			name = "Right Vent";
        }
        default:
        {
            name = "Unknown";
		}
	}
	return name;
}

stock partName(part)
{
	new name[32];
	switch(part - 1000)
	{
		case 0:
		{
			name = "Pro";
        }
		case 1:
        {
			name = "Win";
        }
		case 2:
        {
			name = "Drag";
        }
		case 3:
        {
			name = "Alpha";
        }
		case 4:
        {
			name = "Champ Scoop";
        }
		case 5:
        {
			name = "Fury Scoop";
        }
		case 6:
        {
			name = "Roof Scoop";
        }
		case 7:
        {
			name = "Sideskirt";
        }
        case 8:
        {
            name = "2x";
        }
        case 9:
        {
            name = "5x";
        }
        case 10:
        {
            name = "10x";
        }
		case 11:
        {
			name = "Race Scoop";
        }
		case 12:
        {
			name = "Worx Scoop";
        }
		case 13:
        {
			name = "Round Fog";
        }
		case 14:
        {
			name = "Champ";
        }
		case 15:
        {
			name = "Race";
        }
		case 16:
        {
			name = "Worx";
        }
		case 17:
        {
			name = "Sideskirt";
        }
		case 18:
        {
			name = "Upswept";
        }
		case 19:
        {
			name = "Twin";
        }
		case 20:
		{
			name = "Large";
        }
		case 21:
        {
			name = "Medium";
        }
		case 22:
        {
			name = "Small";
        }
		case 23:
        {
			name = "Fury";
        }
		case 24:
        {
			name = "Square Fog";
        }
        case 25:
        {
            name = "Offroad";
        }
		case 26:
        {
			name = "Alien";
        }
		case 27:
        {
			name = "Alien";
        }
		case 28:
        {
			name = "Alien";
        }
		case 29:
        {
			name = "X-Flow";
        }
		case 30:
        {
			name = "X-Flow";
        }
		case 31:
        {
			name = "X-Flow";
        }
		case 32:
        {
			name = "Alien Roof Vent";
        }
		case 33:
        {
			name = "X-Flow Roof Vent";
        }
		case 34:
        {
			name = "Alien";
        }
		case 35:
        {
			name = "X-Flow Roof Vent";
        }
		case 36:
        {
			name = "Alien";
        }
		case 37:
        {
			name = "X-Flow";
        }
		case 38:
        {
			name = "Alien Roof Vent";
        }
		case 39:
        {
			name = "X-Flow";
        }
		case 40:
        {
			name = "Alien";
        }
		case 41:
        {
			name = "X-Flow";
        }
		case 42:
        {
			name = "Chrome";
        }
		case 43:
        {
			name = "Slamin";
        }
		case 44:
        {
			name = "Chrome";
        }
		case 45:
        {
			name = "X-Flow";
        }
		case 46:
        {
			name = "Alien";
        }
		case 47:
        {
			name = "Alien";
        }
		case 48:
        {
			name = "X-Flow";
        }
		case 49:
        {
			name = "Alien";
        }
		case 50:
        {
			name = "X-Flow";
        }
		case 51:
        {
			name = "Alien";
        }
		case 52:
        {
			name = "X-Flow";
        }
		case 53:
        {
			name = "X-Flow";
        }
		case 54:
        {
			name = "Alien";
        }
		case 55:
        {
			name = "Alien";
        }
		case 56:
        {
			name = "Alien";
        }
		case 57:
        {
			name = "X-Flow";
        }
		case 58:
        {
			name = "Alien";
        }
		case 59:
        {
			name = "X-Flow";
        }
		case 60:
        {
			name = "X-Flow";
        }
		case 61:
        {
			name = "X-Flow";
        }
		case 62:
        {
			name = "Alien";
        }
		case 63:
        {
			name = "X-Flow";
        }
		case 64:
        {
			name = "Alien";
        }
		case 65:
        {
			name = "Alien";
        }
		case 66:
        {
			name = "X-Flow";
        }
		case 67:
        {
			name = "Alien";
        }
		case 68:
        {
			name = "X-Flow";
        }
		case 69:
        {
			name = "Alien";
        }
		case 70:
        {
			name = "X-Flow";
        }
		case 71:
        {
			name = "Alien";
        }
		case 72:
        {
			name = "X-Flow";
        }
        case 73:
        {
            name = "Shadow";
        }
        case 74:
        {
            name = "Mega";
        }
        case 75:
        {
            name = "Rimshine";
        }
        case 76:
        {
            name = "Wires";
        }
        case 77:
        {
            name = "Classic";
        }
        case 78:
        {
            name = "Twist";
        }
        case 79:
        {
            name = "Cutter";
        }
        case 80:
        {
            name = "Switch";
        }
        case 81:
        {
            name = "Grove";
        }
        case 82:
        {
            name = "Import";
        }
        case 83:
        {
            name = "Dollar";
        }
        case 84:
        {
            name = "Trance";
        }
        case 85:
        {
            name = "Atomic";
        }
		case 88:
        {
			name = "Alien";
        }
		case 89:
        {
			name = "X-Flow";
        }
		case 90:
        {
			name = "Alien";
        }
		case 91:
        {
			name = "X-Flow";
        }
		case 92:
        {
			name = "Alien";
        }
		case 93:
        {
			name = "X-Flow";
        }
		case 94:
        {
			name = "Alien";
        }
		case 95:
        {
			name = "X-Flow";
        }
        case 96:
        {
            name = "Ahab";
        }
        case 97:
        {
            name = "Virtual";
        }
        case 98:
        {
            name = "Access";
        }
		case 99:
        {
			name = "Chrome";
        }
		case 100:
        {
			name = "Chrome Grill";
        }
 		case 101:
        {
			name = "Chrome Flames";
        }
		case 102:
        {
			name = "Chrome Strip";
        }
		case 103:
        {
			name = "Covertible";
        }
		case 104:
        {
			name = "Chrome";
        }
		case 105:
        {
			name = "Slamin";
        }
		case 106:
        {
			name = "Chrome Arches";
        }
		case 107:
        {
			name = "Chrome Strip";
        }
		case 108:
        {
			name = "Chrome Strip";
        }
		case 109:
        {
			name = "Chrome";
        }
		case 110:
        {
			name = "Slamin";
        }
		case 113:
        {
			name = "Chrome";
        }
		case 114:
        {
			name = "Slamin";
        }
		case 115:
        {
			name = "Chrome";
        }
		case 116:
        {
			name = "Slamin";
        }
		case 117:
        {
			name = "Chrome";
        }
		case 118:
        {
			name = "Chrome Trim";
        }
		case 119:
        {
			name = "Wheelcovers";
        }
		case 120:
        {
			name = "Chrome Trim";
        }
		case 121:
        {
			name = "Wheelcovers";
        }
		case 122:
        {
			name = "Chrome Flames";
        }
		case 123:
        {
			name = "Bullbar Chrome Bars";
        }
		case 124:
        {
			name = "Chrome Arches";
        }
		case 125:
        {
			name = "Bullbar Chrome Lights";
        }
		case 126:
        {
			name = "Chrome";
        }
		case 127:
        {
			name = "Slamin";
        }
		case 128:
        {
			name = "Vinyl Hardtop";
        }
		case 129:
        {
			name = "Chrome";
        }
		case 130:
        {
			name = "Hardtop";
        }
		case 131:
        {
			name = "Softtop";
        }
		case 132:
        {
			name = "Slamin";
        }
		case 133:
        {
			name = "Chrome Strip";
        }
		case 134:
        {
			name = "Chrome Strip";
        }
		case 135:
        {
			name = "Slamin";
        }
		case 136:
        {
			name = "Chrome";
        }
		case 137:
        {
			name = "Chrome Strip";
        }
		case 138:
        {
			name = "Alien";
        }
		case 139:
        {
			name = "X-Flow";
        }
		case 140:
        {
			name = "X-Flow";
        }
		case 141:
        {
			name = "Alien";
        }
		case 142:
        {
			name = "Left Oval Vents";
        }
		case 143:
        {
			name = "Right Oval Vents";
        }
		case 144:
        {
			name = "Left Square Vents";
        }
		case 145:
        {
			name = "Right Square Vents";
        }
		case 146:
        {
			name = "X-Flow";
        }
		case 147:
        {
			name = "Alien";
        }
		case 148:
        {
			name = "X-Flow";
        }
		case 149:
        {
			name = "Alien";
        }
		case 150:
        {
			name = "Alien";
        }
		case 151:
        {
			name = "X-Flow";
        }
		case 152:
        {
			name = "X-Flow";
        }
		case 153:
        {
			name = "Alien";
        }
		case 154:
        {
			name = "Alien";
        }
		case 155:
        {
			name = "Alien";
        }
		case 156:
        {
			name = "X-Flow";
        }
		case 157:
        {
			name = "X-Flow";
        }
		case 158:
        {
			name = "X-Flow";
        }
		case 159:
        {
			name = "Alien";
        }
		case 160:
        {
			name = "Alien";
        }
		case 161:
        {
			name = "X-Flow";
        }
		case 162:
        {
			name = "Alien";
        }
		case 163:
        {
			name = "X-Flow";
        }
		case 164:
        {
			name = "Alien";
        }
		case 165:
        {
			name = "X-Flow";
        }
		case 166:
        {
			name = "Alien";
        }
		case 167:
        {
			name = "X-Flow";
        }
		case 168:
        {
			name = "Alien";
        }
		case 169:
        {
			name = "Alien";
        }
		case 170:
        {
			name = "X-Flow";
        }
		case 171:
        {
			name = "Alien";
        }
		case 172:
        {
			name = "X-Flow";
        }
		case 173:
        {
			name = "X-Flow";
        }
		case 174:
        {
			name = "Chrome";
        }
		case 175:
        {
			name = "Slamin";
        }
		case 176:
        {
			name = "Chrome";
        }
		case 177:
        {
			name = "Slamin";
        }
		case 178:
        {
			name = "Slamin";
        }
		case 179:
        {
			name = "Chrome";
        }
		case 180:
        {
			name = "Chrome";
        }
		case 181:
        {
			name = "Slamin";
        }
		case 182:
        {
			name = "Chrome";
        }
		case 183:
        {
			name = "Slamin";
        }
		case 184:
        {
			name = "Chrome";
        }
		case 185:
        {
			name = "Slamin";
        }
		case 186:
        {
			name = "Slamin";
        }
		case 187:
        {
			name = "Chrome";
        }
		case 188:
        {
			name = "Slamin";
        }
		case 189:
        {
			name = "Chrome";
        }
		case 190:
        {
			name = "Slamin";
        }
		case 191:
        {
			name = "Chrome";
        }
		case 192:
        {
			name = "Chrome";
        }
		case 193:
        {
			name = "Slamin";
        }
   	}
	return name;
}

stock GetXYBehindVehicle(vehicleid, &Float:x, &Float:y, Float:distance)
{
    new
        Float:a;
    GetVehiclePos( vehicleid, x, y, a );
    GetVehicleZAngle( vehicleid, a );
    x += ( distance * floatsin( -a+180, degrees ));
    y += ( distance * floatcos( -a+180, degrees ));
}

stock GetPosBehindVehicle(vehicleid, &Float:x, &Float:y, &Float:z, Float:offset=1.0)
{
	new Float:vehicleSize[3], Float:vehiclePos[3];
	GetVehiclePos(vehicleid, vehiclePos[0], vehiclePos[1], vehiclePos[2]);
	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, vehicleSize[0], vehicleSize[1], vehicleSize[2]);
	GetXYBehindVehicle(vehicleid, vehiclePos[0], vehiclePos[1], (vehicleSize[1]/2)+offset);
	x = vehiclePos[0];
	y = vehiclePos[1];
	z = vehiclePos[2];
	return 1;
}

TriggerVehicleAlarm(triggerid, ownerid, vehicleid)
{
	new szCarLocation[MAX_ZONE_NAME], slot = GetPlayerVehicle(ownerid, vehicleid), Float: CarPos[3], engine, lights, alarm, doors, bonnet, boot, objective;
	if(PlayerVehicleInfo[ownerid][slot][pvAlarm] > 0) {
		ProxDetector(30.0, triggerid, "(( Bao dong xe da duoc kich hoat. ))", COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		GetVehiclePos(vehicleid, CarPos[0], CarPos[1], CarPos[2]);
		Get3DZone(CarPos[0], CarPos[1], CarPos[2], szCarLocation, sizeof(szCarLocation));
		SendClientMessageEx(ownerid, COLOR_YELLOW, "SMS: Bao dong %s(%d) tai %s da kich hoat, goi 911, Nguoi gui: Vehicle Security Company", GetVehicleName(vehicleid), vehicleid, szCarLocation);
		PlayerVehicleInfo[ownerid][slot][pvAlarmTriggered] = 1;
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(vehicleid,engine,lights,VEHICLE_PARAMS_ON,doors,bonnet,boot,objective);
	}
}

stock GetVehicleRelativePos(vehicleid, &Float:x, &Float:y, &Float:z, Float:xoff=0.0, Float:yoff=0.0, Float:zoff=0.0)
{
    new Float:rot;
    GetVehicleZAngle(vehicleid, rot);
    rot = 360 - rot;    // Making the vehicle rotation compatible with pawns sin/cos
	GetVehiclePos(vehicleid, x, y, z);
    
    x = floatsin(rot,degrees) * yoff + floatcos(rot,degrees) * xoff + x;
    y = floatcos(rot,degrees) * yoff - floatsin(rot,degrees) * xoff + y;
    z = zoff + z;

    /*
       where xoff/yoff/zoff are the offsets relative to the vehicle
       x/y/z then are the coordinates of the point with the given offset to the vehicle
       xoff = 1.0 would e.g. point to the right side of the vehicle, -1.0 to the left, etc.
    */
}

stock RegisterVehicleNumberPlate(vehicleid, sz_NumPlate[]) {
	new
	    Float: a_CarPos[4], Float: fuel; // X, Y, Z, Z Angle, Fuel

	GetVehiclePos(vehicleid, a_CarPos[0], a_CarPos[1], a_CarPos[2]);
	GetVehicleZAngle(vehicleid, a_CarPos[3]);
	fuel = VehicleFuel[vehicleid];
	SetVehicleNumberPlate(vehicleid, sz_NumPlate);
	SetVehicleToRespawn(vehicleid);
	SetVehiclePos(vehicleid, a_CarPos[0], a_CarPos[1], a_CarPos[2]);
	SetVehicleZAngle(vehicleid, a_CarPos[3]);
	VehicleFuel[vehicleid] = fuel;
	return 1;
}


stock legalRims(playerid, compenent, vehicleid)
{
	if(IsPlayerInRangeOfPoint(playerid, 20, 617.5360,-1.9900,1000.6592)) // Transfender
	{
		switch(compenent)
		{
		    case 1098, 1096, 1085, 1081, 1082, 1074, 1025, 1078, 1097, 1076:
		    {
		        switch(GetVehicleModel(vehicleid))
		        {
		            case  579, 400, 500, 418, 404, 489, 479, 442, 458, 602, 496, 401, 518, 527, 589, 419, 533, 526, 474, 545,
		            517, 410, 600, 436, 439, 549, 491, 555, 445, 507, 585, 604, 466, 492, 546, 551, 516, 467, 426, 405, 580, 409, 550,
		            540, 421, 529, 402, 542, 603, 475, 429, 541, 415, 480, 587, 411, 506, 451, 477, 422, 478, 438, 420, 547: return 1;
		            default: return 0;
		        }
			}
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 20,615.2861,-124.2390,997.6703)) //Wheel Arch
	{
	    switch(compenent)
		{
		    case 1085, 1077, 1079, 1083, 1081, 1082, 1074, 1075, 1073, 1080:
		    {
		        switch(GetVehicleModel(vehicleid))
		        {
		            case  562, 565, 559, 561, 560, 558: return 1;
		            default: return 0;
		        }
			}
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 20, 616.7914,-74.8150,997.8929)) // Loco
	{
	    switch(compenent)
		{
		    case 1098, 1077, 1079, 1083, 1075, 1084, 1078, 1097, 1076:
		    {
		        switch(GetVehicleModel(vehicleid))
		        {
		            case  536, 575, 534, 567, 535, 566, 576, 412: return 1;
		            default: return 0;
		        }
			}
		}
	}
	return 0;
}

vehicleSpawnCountCheck(playerid) {
	switch(PlayerInfo[playerid][pDonateRank]) {
		case 0, 1, 2: if(VehicleSpawned[playerid] >= 2) return 0;
		case 3: if(VehicleSpawned[playerid] >= 3) return 0;
		case 4, 5: if(VehicleSpawned[playerid] >= 5) return 0;
		default: return 0;
	}
	return 1;
}

vehicleCountCheck(playerid) {

	new
		iCount = GetPlayerVehicleCount(playerid);

	switch(PlayerInfo[playerid][pDonateRank]) {
		case 0: if(iCount >= 5 + PlayerInfo[playerid][pVehicleSlot]) return 0;
		case 1: if((iCount >= 6 + PlayerInfo[playerid][pVehicleSlot]) || (PlayerInfo[playerid][pTempVIP] > 0 && iCount >= 5 + PlayerInfo[playerid][pVehicleSlot])) return 0;
		case 2: if(iCount >= 7 + PlayerInfo[playerid][pVehicleSlot]) return 0;
		case 3: if(iCount >= 8 + PlayerInfo[playerid][pVehicleSlot]) return 0;
		case 4, 5: if(iCount >= 10 + PlayerInfo[playerid][pVehicleSlot]) return 0;
		default: return 0;
	}
	return 1;
}

GetPlayerVehicleCount(playerid)
{
	new cars = 0;
	for(new i = 0; i < MAX_PLAYERVEHICLES; i++) if(PlayerVehicleInfo[playerid][i][pvModelId]) ++cars;
	return cars;
}

GetPlayerVehicleSlots(playerid)
{
	switch(PlayerInfo[playerid][pDonateRank]) {
		case 0: return 5 + PlayerInfo[playerid][pVehicleSlot];
		case 1:
		{
			if(PlayerInfo[playerid][pTempVIP] > 0)
			{
				return 5 +  PlayerInfo[playerid][pVehicleSlot];
			}
			else
			{
				return 6 + PlayerInfo[playerid][pVehicleSlot];
			}
		}
		case 2: return 7 + PlayerInfo[playerid][pVehicleSlot];
		case 3: return 8 + PlayerInfo[playerid][pVehicleSlot];
		case 4, 5: return 10 + PlayerInfo[playerid][pVehicleSlot];
		default: return 0;
	}
	return 0;
}

CheckPlayerVehiclesForDesync(playerid) {
	for(new i = 0; i != MAX_PLAYERVEHICLES; ++i) {
		if(PlayerVehicleInfo[playerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID && GetVehicleModel(PlayerVehicleInfo[playerid][i][pvId]) != PlayerVehicleInfo[playerid][i][pvModelId]) {
			UnloadPlayerVehicles(playerid);
			LoadPlayerVehicles(playerid);
			return SendClientMessageEx(playerid, COLOR_YELLOW, "Xe cua ban bi mat dong bo, da duoc tao lai de tranh xung dot.");
	    }
	}
	return 1;
}

Vehicle_ResetData(iVehicleID) {
	if(GetVehicleModel(iVehicleID)) {
		Vehicle_Armor(iVehicleID);
		LockStatus{iVehicleID} = 0;
		VehicleStatus{iVehicleID} = 0;
		WheelClamp{iVehicleID} = 0;
		arr_Engine{iVehicleID} = 0;
		stationidv[iVehicleID][0] = 0;
		VehicleFuel[iVehicleID] = 100.0;
		
		foreach(new i: Player)
		{
			Shipment_ClearVehicleWork(i, iVehicleID);
			if(LockStatus{iVehicleID}) {
				if(PlayerInfo[i][pLockCar] == iVehicleID) {
					PlayerInfo[i][pLockCar] = INVALID_VEHICLE_ID;
				}
			}
			if(VehicleBomb{iVehicleID} == 1) {
				if(PlacedVehicleBomb[i] == iVehicleID) {
					VehicleBomb{iVehicleID} = 0;
					PlacedVehicleBomb[i] = INVALID_VEHICLE_ID;
					PickUpC4(i);
					PlayerInfo[i][pC4Used] = 0;
					PlayerInfo[i][pC4Get] = 1;
				}
			}
		}
		TruckContents{iVehicleID} = 0;
		TruckDeliveringTo[iVehicleID] = INVALID_BUSINESS_ID;
	}
}

Vehicle_Armor(iVehicleID) {
	if(DynVeh[iVehicleID] != -1 && iVehicleID == DynVehicleInfo[DynVeh[iVehicleID]][gv_iSpawnedID])
	{
	    SetVehicleHealth(iVehicleID, DynVehicleInfo[DynVeh[iVehicleID]][gv_fMaxHealth]);
	}
	else if(IsDynamicCrateVehicle(iVehicleID) != -1) 
	{
		SetVehicleHealth(iVehicleID, CrateVehicle[IsDynamicCrateVehicle(iVehicleID)][cvMaxHealth]);
	}
	else
	{
		switch(GetVehicleModel(iVehicleID)) {
			case 520, 476:SetVehicleHealth(iVehicleID, 5000.0);
			case 596, 597, 598: SetVehicleHealth(iVehicleID, 2000.0);
			case 490: SetVehicleHealth(iVehicleID, 2500.0);
			case 407, 470: SetVehicleHealth(iVehicleID, 3000.0);
			case 428, 433, 447, 427: SetVehicleHealth(iVehicleID, 4000.0);
			case 601, 528: SetVehicleHealth(iVehicleID, 5000.0);
			case 432, 425: SetVehicleHealth(iVehicleID, 7500.0);
		}
	}
}

LockPlayerVehicle(ownerid, carid, type)
{
	new v = GetPlayerVehicle(ownerid, carid);
	if(PlayerVehicleInfo[ownerid][v][pvId] == carid && type == 3)
	{
	    LockStatus{carid} = 1;
	    vehicle_lock_doors(carid);
	}
}

UnLockPlayerVehicle(ownerid, carid, type)
{
	new v = GetPlayerVehicle(ownerid, carid);
	if(PlayerVehicleInfo[ownerid][v][pvId] == carid && type == 3)
	{
	    LockStatus{carid} = 0;
		vehicle_unlock_doors(carid);
	}
}

stock encode_tires(tire1, tire2, tire3, tire4)
{
	return tire1 | (tire2 << 1) | (tire3 << 2) | (tire4 << 3);
}

stock SurfingCheck(vehicleid)
{
	foreach(new p: Player)
	{
		if(GetPlayerSurfingVehicleID(p) == vehicleid)
		{
			new Float:x, Float:y, Float:z;
			GetPlayerPos(p, x, y, z);
			SetTimerEx("SurfingFix", 2000, false, "ifff", p, x, y, z);
		}
	}	
}

stock InvalidModCheck(model, partid) {
    switch(model) {
		case 427, 430, 446, 452, 453, 454, 472, 473, 484, 493, 595, 573, 556, 557, 539, 471, 432, 406, 444,
		448, 461, 462, 463, 468, 481, 509, 510, 521, 522, 581, 586, 417, 425, 447, 460, 469, 476, 487,
		488, 511, 512, 513, 519, 520, 548, 553, 563, 577, 592, 593: return 0;
		default: switch(GetVehicleComponentType(partid)) {
			case 5: switch(partid) {
				case 1008, 1009, 1010: return 1;
				default: return 0;
			}
			case 7: switch(partid) {
				case 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1096, 1097, 1098, 1025: return 1;
				default: return 0;
			}
			case 8: switch(partid) {
				case 1086: return 1;
				default: return 0;
			}
			case 9: switch(partid) {
				case 1087: return 1;
				default: return 0;
			}
			case 12, 13: switch(partid) {
				case 1142, 1144, 1143, 1145: return 1;
				default: return 0;
			}
		}
	}
	return 1;
}


stock SetVehicleLights(vehicleid, playerid)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
    GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
    if(lights == VEHICLE_PARAMS_ON)
	{
		SetVehicleParamsEx(vehicleid,engine,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da tat den xe.");
	}
    else if(lights == VEHICLE_PARAMS_OFF || lights == VEHICLE_PARAMS_UNSET)
	{
		SetVehicleParamsEx(vehicleid,engine,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da bat den xe.");
	}
	return 1;
}

stock SetVehicleHood(vehicleid, playerid)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
    GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
    if(bonnet == VEHICLE_PARAMS_ON)
	{
		SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,VEHICLE_PARAMS_OFF,boot,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da dong nap capo.");
	}
    else if(bonnet == VEHICLE_PARAMS_OFF || bonnet == VEHICLE_PARAMS_UNSET)
	{
		SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,VEHICLE_PARAMS_ON,boot,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da mo nap capo.");
	}
	return 1;
}

stock SetVehicleTrunk(vehicleid, playerid)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
    GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
    if(boot == VEHICLE_PARAMS_ON)
	{
		SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_OFF,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da dong cop xe.");
	}
    else if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)
	{
		SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_ON,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da mo cop xe.");
	}
	return 1;
}

stock SetVehicleDoors(vehicleid, playerid)
{
	new engine,lights,alarm,doors,bonnet,boot,objective;
    GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
    if(doors == VEHICLE_PARAMS_ON)
	{
		SetVehicleParamsEx(vehicleid,engine,lights,alarm,VEHICLE_PARAMS_OFF,bonnet,boot,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Cua xe {AA3333}da {FFFFFF}duoc {33AA33}dong{FFFFFF}.");
	}
    else if(doors == VEHICLE_PARAMS_OFF || doors == VEHICLE_PARAMS_UNSET)
	{
		SetVehicleParamsEx(vehicleid,engine,lights,alarm,VEHICLE_PARAMS_ON,bonnet,boot,objective);
		SendClientMessageEx(playerid, COLOR_WHITE, "Cua xe {AA3333}da {FFFFFF}duoc {33AA33}mo{FFFFFF}.");
	}
	return 1;
}

stock IsValidVehicleID(vehicleid)
{
   if(GetVehicleModel(vehicleid)) return 1;
   return 0;
}

stock GetClosestCar(iPlayer, iException = INVALID_VEHICLE_ID, Float: fRange = Float: 0x7F800000) {

	new
		iReturnID = INVALID_VEHICLE_ID,
		Float: fVehiclePos[4];

	for(new i = 1; i < MAX_VEHICLES; ++i) if(i != iException && GetVehicleModel(i) && GetVehicleVirtualWorld(i) == GetPlayerVirtualWorld(iPlayer) && GetVehicleInterior(i) == GetPlayerInterior(iPlayer)) {
		GetVehiclePos(i, fVehiclePos[0], fVehiclePos[1], fVehiclePos[2]);
		if((fVehiclePos[3] = GetPlayerDistanceFromPoint(iPlayer, fVehiclePos[0], fVehiclePos[1], fVehiclePos[2])) < fRange) {
			fRange = fVehiclePos[3];
			iReturnID = i;
		}
	}
	return iReturnID;
}

stock Float: GetVehicleFuelCapacity(vehicleid)
{
	new Float: capacity;
	if (IsABike(vehicleid)) {
		capacity = 5.0;
	}
 	else {
	 	capacity = 20.00;
	}
	return capacity;
	//TODO optimise more
}

stock RespawnNearbyVehicles(iPlayerID, Float: fRadius) {

	new
		Float: fPlayerPos[3];

    GetPlayerPos(iPlayerID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
    for(new i = 1; i < MAX_VEHICLES; i++)
	{
		if(GetVehicleModel(i) && GetVehicleDistanceFromPoint(i, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]) <= fRadius && !IsVehicleSeatOccupied(i))
		{
			if(DynVeh[i] != -1)
			{
			    DynVeh_Spawn(DynVeh[i]);
			    TruckDeliveringTo[i] = INVALID_BUSINESS_ID;
			}
			SetVehicleToRespawn(i);
		}
	}
	return 1;
}

stock IsRefuelableVehicle(vehicleid)
{
	new modelid = GetVehicleModel(vehicleid);
	switch (modelid)
	{
		case 481, 509, 510: return 0; // Bikes
	}
	return 1;
}

stock SetVehicleTireState(vehicleid, tire1, tire2, tire3, tire4)
{
    new panels, doors, Lights, tires;
   	GetVehicleDamageStatus(vehicleid, panels, doors, Lights, tires);
    tires = encode_tires(!tire1, !tire2, !tire3, !tire4);
    UpdateVehicleDamageStatus(vehicleid, panels, doors, Lights, tires);
}

stock GetVehicleTireState(vehicleid, &tire1, &tire2, &tire3, &tire4)
{
    new panels, doors, Lights, tires;
   	GetVehicleDamageStatus(vehicleid, panels, doors, Lights, tires);
    tire1 = !(tires >> 0 & 0x1);
	tire2 = !(tires >> 1 & 0x1);
	tire3 = !(tires >> 2 & 0x1);
	tire4 = !(tires >> 3 & 0x1);
}

stock IsVehicleSeatOccupied(iVehicleID, iSeatID = 0) {
	foreach(new x : Player)
	{
		if(GetPlayerVehicleID(x) == iVehicleID && GetPlayerVehicleSeat(x) == iSeatID) {
			return 1;
		}
	}	
	return 0;
}

stock IsVehicleInTow(iVehicleID) {
	foreach(new x : Player)
	{
		if(arr_Towing[x] == iVehicleID) {
			return 1;
		}
	}	
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	szMiscArray[0] = 0;
	IsPlayerEntering{playerid} = true;
	Seatbelt[playerid] = 0;
	if(GetPVarType(playerid, "HelmetOn"))
	{
		for(new i; i < 10; i++) {
			if(PlayerHoldingObject[playerid][i] == GetPVarInt(playerid, "HelmetOn")) {
				PlayerHoldingObject[playerid][i] = 0;
				RemovePlayerAttachedObject(playerid, i);
				DeletePVar(playerid, "HelmetOn");
				break;
			}
		}
	}

	if(PlayerCuffed[playerid] != 0) SetPVarInt( playerid, "ToBeEjected", 1 );
	if(GetPVarInt(playerid, "BackpackMedKit") == 1)
		DeletePVar(playerid, "BackpackMedKit");
	if(GetPVarInt(playerid, "BackpackMeal") == 1)
		DeletePVar(playerid, "BackpackMeal");
	if(GetPVarType(playerid, "BackpackOpen"))
		DeletePVar(playerid, "BackpackOpen");
	if(ispassenger) {
		if(GetPVarType(playerid, "Injured")) {
			SetPlayerPos(playerid, GetPVarFloat(playerid,"MedicX"), GetPVarFloat(playerid,"MedicY"), GetPVarFloat(playerid,"MedicZ"));
			ClearAnimationsEx(playerid);
			PlayDeathAnimation(playerid);
		}
		else if(PlayerCuffed[playerid] != 0) {
			ClearAnimationsEx(playerid);
			ApplyAnimation(playerid,"ped","cower",1,true,false,false,false,0,1);
			TogglePlayerControllable(playerid, false);
		}
	}
	SetPVarInt(playerid, "LastWeapon", GetPlayerWeapon(playerid));

	new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(engine == VEHICLE_PARAMS_UNSET) switch(GetVehicleModel(vehicleid)) {
		case 509, 481, 510: VehicleFuel[vehicleid] = GetVehicleFuelCapacity(vehicleid), arr_Engine{vehicleid} = 1, SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
		default: SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective), arr_Engine{vehicleid} = 0;
	}

	if(GetPVarInt(playerid, "UsingSprunk") == 1)
	{
		SetPVarInt(playerid, "UsingSprunk", 0);
		SetPVarInt(playerid, "DrinkCooledDown", 0);
	}

    if(GetPVarType(playerid, "Pizza") && !(IsAPizzaCar(vehicleid)))
	{
	    new Float:slx, Float:sly, Float:slz;
		GetPlayerPos(playerid, slx, sly, slz);
		SetPlayerPos(playerid, slx, sly, slz+1.3);
		PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
		RemovePlayerFromVehicle(playerid);
		defer NOPCheck(playerid);
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai ngoi tren Pizzaboy khi giao pizza!");
		return 1;
	}
	if(!ispassenger)
	{
	    SetPlayerArmedWeapon(playerid, 0);
		if(PlayerInfo[playerid][pAccountRestricted] == 1)
		{
			new Float:slx, Float:sly, Float:slz;
			GetPlayerPos(playerid, slx, sly, slz);
			SetPlayerPos(playerid, slx, sly, slz+1.3);
			RemovePlayerFromVehicle(playerid);
			defer NOPCheck(playerid);
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the lai xe khi tai khoan dang bi han che!");
		}
		if(IsVIPcar(vehicleid))
		{
		    if(PlayerInfo[playerid][pDonateRank] == 0)
			{
			    new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
			    RemovePlayerFromVehicle(playerid);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai VIP, day la xe cua VIP Garage!");
			}
		}
		else if(IsWeaponizedVehicle(GetVehicleModel(vehicleid)))
	    {
	        if(PlayerInfo[playerid][pLevel] < 6)
	        {
				if(gettime() > GetPVarInt(playerid, "timeWepVeh"))
				{
					new szString[128];
					format(szString, sizeof(szString), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) da len xe vu trang (Vehicle ID: %d) (Cap: %d)", GetPlayerNameEx(playerid), playerid, vehicleid, PlayerInfo[playerid][pLevel]);
					ABroadCast(COLOR_YELLOW, szString, 2);
					SetPVarInt(playerid, "timeWepVeh", gettime()+5);
				}
			}
		}
		else if(IsFamedVeh(vehicleid))
		{
		    if(PlayerInfo[playerid][pFamed] > 0 || PlayerInfo[playerid][pFamed] < 8)
		    {
				if(IsOSModel(vehicleid))
				{
				    if(PlayerInfo[playerid][pFamed] < 1)
				    {
                        new Float:slx, Float:sly, Float:slz;
						GetPlayerPos(playerid, slx, sly, slz);
						SetPlayerPos(playerid, slx, sly, slz+1.3);
						PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
					    RemovePlayerFromVehicle(playerid);
					    defer NOPCheck(playerid);
					    SendClientMessageEx(playerid, COLOR_GRAD2, "Day la xe Old-School+, ban khong duoc phep lai.");
					}
				}
				else if(IsCOSModel(vehicleid))
				{
					if(PlayerInfo[playerid][pFamed] < 1)
					{
					    new Float:slx, Float:sly, Float:slz;
						GetPlayerPos(playerid, slx, sly, slz);
						SetPlayerPos(playerid, slx, sly, slz+1.3);
						PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
					    RemovePlayerFromVehicle(playerid);
					    defer NOPCheck(playerid);
					    SendClientMessageEx(playerid, COLOR_GRAD2, "Day la xe Chartered Old-School+, ban khong duoc phep lai.");
					}
				}
				else if(IsFamedModel(vehicleid))
				{
				    if(PlayerInfo[playerid][pFamed] < 1)
				    {
				        new Float:slx, Float:sly, Float:slz;
						GetPlayerPos(playerid, slx, sly, slz);
						SetPlayerPos(playerid, slx, sly, slz+1.3);
						PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
					    RemovePlayerFromVehicle(playerid);
					    defer NOPCheck(playerid);
					    SendClientMessageEx(playerid, COLOR_GRAD2, "Day la xe Famed+, ban khong duoc phep lai.");
					}
				}
			}
		}
		else if(IsAPizzaCar(vehicleid))
		{
		    if(!Job_HasJob(playerid, JOB_PIZZA))
		    {
			    new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
			    RemovePlayerFromVehicle(playerid);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai Pizza Boy!");
			}
		}

		else if(IsATruckerCar(vehicleid))
		{
		    if((Job_HasJob(playerid, JOB_SHIPMENT)))
			{
				new iTruckContents = TruckContents{vehicleid};
				new truckcontentname[50];
				if(iTruckContents == 1)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Thuc an & do uong");}
				else if(iTruckContents == 2)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Clothing"); }
				else if(iTruckContents == 3)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Vat lieu hop phap"); }
				else if(iTruckContents == 4)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Hang 24/7"); }
				else if(iTruckContents == 5)
				{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Vu khi bat hop phap"); }
				else if(iTruckContents == 6)
				{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Ma tuy bat hop phap"); }
				else if(iTruckContents == 7)
				{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Vat lieu bat hop phap"); }
				if(iTruckContents == 0)
				{ format(truckcontentname, sizeof(truckcontentname), "%s",  GetInventoryType(TruckDeliveringTo[vehicleid])); }
				SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR: (Dang ky xe: %s %d) - (Hang hoa: %s{FFFF00})", GetVehicleName(vehicleid), vehicleid, truckcontentname);

				if(IsACop(playerid))
				{
					SendClientMessageEx(playerid, COLOR_DBLUE, "LAW ENFORCEMENT: Dung /clearcargo gan xe de tich thu hang cam.");
				}
				if(TruckDeliveringTo[vehicleid] != INVALID_BUSINESS_ID && TruckUsed[playerid] == INVALID_VEHICLE_ID)
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Ngoi ghe lai va dung /hijackcargo de giao hang.");
				}
				else if(TruckUsed[playerid] == INVALID_VEHICLE_ID)
				{
    				SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Ngoi ghe lai va dung /loadshipment de lay hang.");
				}
				else if(TruckUsed[playerid] == vehicleid && gPlayerCheckpointStatus[playerid] == CHECKPOINT_RETURNTRUCK)
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Day la lo hang cua ban, hay ve ben cang de nhan tien cong.");
				}
				else if(TruckUsed[playerid] == vehicleid)
   				{
      				SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Day la lo hang cua ban, ban chua giao hang xong.");
     			}
				else if(TruckUsed[playerid] != INVALID_VEHICLE_ID)
   				{
      				SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Ban dang giao lo hang khac, dung /cancel shipment de huy chuyen do.");
     			}
			}
		    else if(!IsABoat(vehicleid))
			{
			    RemovePlayerFromVehicle(playerid);
			    new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai Shipment Contractor!");
			}
		}
		else if(IsInGarbageTruck(vehicleid))
		{
			if(Job_HasJob(playerid, JOB_GARBAGE))
			{
			}
		    else
			{
		        SendClientMessageEx(playerid,COLOR_GREY,"   Ban khong phai Garbage Man!");
		        RemovePlayerFromVehicle(playerid);
		        new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
		    }
		}
	   	else if(IsAPlane(vehicleid))
		{
	  		if(PlayerInfo[playerid][pFlyLic] != 1)
	  		{
				if(GetPVarInt(playerid, "SprunkGuardLic") == 0)
				{
					RemovePlayerFromVehicle(playerid);
					new Float:slx, Float:sly, Float:slz;
					GetPlayerPos(playerid, slx, sly, slz);
					SetPlayerPos(playerid, slx, sly, slz);
					defer NOPCheck(playerid);
					SendClientMessageEx(playerid,COLOR_GREY,"Ban khong co bang lai may bay!");
				}
	  		}
		}
		else if(IsAHelicopter(vehicleid))
		{
		    PlayerInfo[playerid][pAGuns][GetLoadoutWeaponSlot(46)] = 46;
			GivePlayerValidWeapon(playerid, 46);
		}
		else if(IsAnTaxi(vehicleid) || IsAnBus(vehicleid))
		{
	        if(Job_HasJob(playerid, JOB_TAXI) || IsATaxiDriver(playerid) || PlayerInfo[playerid][pTaxiLicense] == 1)
			{
			}
		    else
			{
		        SendClientMessageEx(playerid,COLOR_GREY,"   Ban khong phai Taxi/Bus Driver!");
		        RemovePlayerFromVehicle(playerid);
		        new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
		    }
		}
		else if(IsASpawnedTrain(vehicleid))
		{
			if(!IsATaxiDriver(playerid))
			{
				SendClientMessageEx(playerid,COLOR_GREY,"   Ban khong thuoc don vi van tai!");
				RemovePlayerFromVehicle(playerid);
				new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
		    }
		}
	}
	else if(!IsPlayerInRangeOfVehicle(playerid, vehicleid, 7.5) || (LockStatus{vehicleid} >= 1)) { // G-bugging fix
		ClearAnimationsEx(playerid);
	}
	return 1;
}

CMD:carhelp(playerid, params[])
{
	SetPVarInt(playerid, "HelpResultCat0", 3);
	Help_ListCat(playerid, DIALOG_HELPCATOTHER1);
	return 1;
}

CMD:ocarhelp(playerid, params[])
{
    SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
    SendClientMessageEx(playerid, COLOR_WHITE,"*** HUONG DAN SO HUU XE *** - go lenh de xem chi tiet.");
    SendClientMessageEx(playerid, COLOR_GRAD3,"*** SO HUU XE *** /lock /pvlock /park /parktrailer /unmodcar /deletecar /sellmycar /trackcar");
    SendClientMessageEx(playerid, COLOR_GRAD3,"*** SO HUU XE *** /dmvmenu /givekeys /carkeys /trunkput /trunktake /car /refuel");
    return 1;
}

CMD:car(playerid, params[])
{
	new string[128], choice[8], id;
	if(sscanf(params, "s[8]D(0)", choice, id))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /car [name]");
		SendClientMessageEx(playerid, COLOR_GREY, "Cac tuy chon: Status, Engine, Lights, Trunk, Hood, Fuel, Window [0-3], Windows");
		return 1;
	}
	if(strcmp(choice, "engine", true) == 0 && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new engine,lights,alarm,doors,bonnet,boot,objective,vehicleid;
		vehicleid = GetPlayerVehicleID(playerid);
		if(GetVehicleModel(vehicleid) == 481 || GetVehicleModel(vehicleid) == 509 || GetVehicleModel(vehicleid) == 510 || DynVeh[vehicleid] != -1 && DynVehicleInfo[DynVeh[vehicleid]][gv_iType] == 1 && GetVehicleModel(vehicleid) == 592) return SendClientMessageEx(playerid,COLOR_WHITE,"Khong the dung lenh nay trong xe nay.");
		if(WheelClamp{vehicleid}) return SendClientMessageEx(playerid,COLOR_WHITE,"(( Lop truoc cua xe nay dang bi khoa banh, ban khong the lai xe di. ))");

		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(engine == VEHICLE_PARAMS_ON)
		{
			SetVehicleEngine(vehicleid, playerid);
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s van chia khoa va tat dong co.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else if((engine == VEHICLE_PARAMS_OFF || engine == VEHICLE_PARAMS_UNSET))
		{
			if (GetPVarInt(playerid, "Refueling")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong the lam vay khi dang do xang.");
			// if(!Vehicle_LockCheck(playerid, vehicleid)) return 1;
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s van chia khoa va khoi dong co.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SendClientMessageEx(playerid, COLOR_WHITE, "Dong co dang khoi dong, vui long cho...");
			SetTimerEx("SetVehicleEngine", 1000, false, "dd",  vehicleid, playerid);
			RemoveVehicleFromMeter(vehicleid);
		}
	}
	else if(strcmp(choice, "lights", true) == 0 && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(GetVehicleModel(vehicleid) == 481 || GetVehicleModel(vehicleid) == 509 || GetVehicleModel(vehicleid) == 510) return SendClientMessageEx(playerid,COLOR_WHITE,"Khong the dung lenh nay trong xe nay.");
		SetVehicleLights(vehicleid, playerid);
	}
	else if(strcmp(choice, "hood", true) == 0)
	{
		if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			if(GetVehicleModel(vehicleid) == 481 || GetVehicleModel(vehicleid) == 509 || GetVehicleModel(vehicleid) == 510 || IsAPlane(vehicleid) || IsABike(vehicleid))
			{
				return SendClientMessageEx(playerid,COLOR_WHITE,"Khong the dung lenh nay trong xe nay.");
			}
			SetVehicleHood(vehicleid, playerid);
		}
		else if(!IsPlayerInAnyVehicle(playerid))
		{
			new closestcar = GetClosestCar(playerid);
			if(IsPlayerInRangeOfVehicle(playerid, closestcar, 5.0))
			{
				if(GetVehicleModel(closestcar) == 481 || GetVehicleModel(closestcar) == 509 || GetVehicleModel(closestcar) == 510 || IsAPlane(closestcar) || IsABike(closestcar))
				{
					return SendClientMessageEx(playerid,COLOR_WHITE,"Lenh nay khong dung duoc voi xe nay.");
				}
				SetVehicleHood(closestcar, playerid);
			}
		}
	}
	else if(strcmp(choice, "trunk", true) == 0)
  	{
		if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			if(GetVehicleModel(vehicleid) == 481 || GetVehicleModel(vehicleid) == 509 || GetVehicleModel(vehicleid) == 510)
			{
				return SendClientMessageEx(playerid,COLOR_WHITE,"Khong the dung lenh nay trong xe nay.");
			}
			if(CarryCrate[playerid] != -1) return SendClientMessageEx(playerid,COLOR_WHITE,"Ban can ca hai tay de mo cop xe!"); 
			SetVehicleTrunk(vehicleid, playerid);
		}
		else if(!IsPlayerInAnyVehicle(playerid))
		{
			new closestcar = GetClosestCar(playerid);
			if(IsPlayerInRangeOfVehicle(playerid, closestcar, 5.0))
			{
				if(GetVehicleModel(closestcar) == 481 || GetVehicleModel(closestcar) == 509 || GetVehicleModel(closestcar) == 510)
				{
					return SendClientMessageEx(playerid,COLOR_WHITE,"Lenh nay khong dung duoc voi xe nay.");
				}
				if(CarryCrate[playerid] != -1) return SendClientMessageEx(playerid,COLOR_WHITE,"Ban can ca hai tay de mo cop xe!"); 
				SetVehicleTrunk(closestcar, playerid);
			}
		}
	}
	else if(strcmp(choice, "fuel", true) == 0 && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		new engine,lights,alarm,doors,bonnet,boot,objective,enginestatus[4],lightstatus[4];
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(!IsRefuelableVehicle(vehicleid)) return SendClientMessageEx(playerid,COLOR_RED,"Xe nay khong can nhien lieu.");
		if(engine != VEHICLE_PARAMS_ON) strcpy(enginestatus, "TAT", 4);
		else strcpy(enginestatus, "BAT", 3);
		if(lights != VEHICLE_PARAMS_ON) strcpy(lightstatus, "TAT", 4);
		else strcpy(lightstatus, "BAT", 3);

		if(IsVIPcar(vehicleid) || IsAdminSpawnedVehicle(vehicleid) || IsFamedVeh(vehicleid)) format(string, sizeof(string), "Dong co: %s | Den: %s | Xang: Vo han",enginestatus,lightstatus);
		else format(string, sizeof(string), "Dong co: %s | Den: %s | Xang: %.1f%s",enginestatus,lightstatus, VehicleFuel[vehicleid], "%");
		SendClientMessageEx(playerid, COLOR_WHITE, string);
	}
	else if(strcmp(choice, "status", true) == 0 && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid), slot = GetPlayerVehicle(playerid, vehicleid);
		new engine,lights,alarm,doors,bonnet,boot,objective,enginestatus[4],lightstatus[4];
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(!IsRefuelableVehicle(vehicleid)) return SendClientMessageEx(playerid,COLOR_RED,"Xe nay khong can nhien lieu.");
		if(engine != VEHICLE_PARAMS_ON) strcpy(enginestatus, "TAT", 4);
		else strcpy(enginestatus, "BAT", 3);
		if(lights != VEHICLE_PARAMS_ON) strcpy(lightstatus, "TAT", 4);
		else strcpy(lightstatus, "BAT", 3);
		if (IsVIPcar(vehicleid) || IsAdminSpawnedVehicle(vehicleid) || IsFamedVeh(vehicleid)) format(string, sizeof(string), "Dong co: %s | Den: %s | Xang: Vo han | Kinh: %s",enginestatus,lightstatus,(VehInfo[GetPlayerVehicleID(playerid)][vCarWindows] == 0) ? ("Len") : ("Xuong"));
		else if(slot != -1) format(string, sizeof(string), "Dong co: %s | Den: %s | Xang: %.1f percent | Kinh: %s | Do ben khoa: %d/5",enginestatus,lightstatus, VehicleFuel[vehicleid], (VehInfo[GetPlayerVehicleID(playerid)][vCarWindows] == 0) ? ("Len") : ("Xuong"), PlayerVehicleInfo[playerid][slot][pvLocksLeft]);
		else format(string, sizeof(string), "Dong co: %s | Den: %s | Xang: %.1f percent | Kinh: %s",enginestatus,lightstatus, VehicleFuel[vehicleid], (VehInfo[GetPlayerVehicleID(playerid)][vCarWindows] == 0) ? ("Len") : ("Xuong"));
		SendClientMessageEx(playerid, COLOR_WHITE, string);
	}
	else if(strcmp(choice, "window", true) == 0 && IsPlayerInAnyVehicle(playerid) && !IsABike(GetPlayerVehicleID(playerid)) && !IsABoat(GetPlayerVehicleID(playerid)))
	{
		if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the lam viec nay luc nay.");
		if(NoWindows(GetPlayerVehicleID(playerid))) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung tinh nang nay voi loai xe nay.");
		new driver, passenger, backleft, backright;
		GetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), driver, passenger, backleft, backright);
		if((GetPlayerState(playerid) == PLAYER_STATE_DRIVER && id == 0) || (GetPlayerState(playerid) == PLAYER_STATE_PASSENGER && GetPlayerVehicleSeat(playerid) == 0))
		{
			if(VehInfo[GetPlayerVehicleID(playerid)][vCarWindow0]) VehInfo[GetPlayerVehicleID(playerid)][vCarWindow0] = 0;
			else VehInfo[GetPlayerVehicleID(playerid)][vCarWindow0] = 1;
			SetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), !driver, passenger, backleft, backright);
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s quay kinh cua ghe lai %s.", GetPlayerNameEx(playerid), (VehInfo[GetPlayerVehicleID(playerid)][vCarWindow0] == 0) ? ("len") : ("xuong"));
		}
		else if((GetPlayerState(playerid) == PLAYER_STATE_DRIVER && id == 1) || (GetPlayerState(playerid) == PLAYER_STATE_PASSENGER && GetPlayerVehicleSeat(playerid) == 1))
		{
			if(VehInfo[GetPlayerVehicleID(playerid)][vCarWindow1]) VehInfo[GetPlayerVehicleID(playerid)][vCarWindow1] = 0;
			else VehInfo[GetPlayerVehicleID(playerid)][vCarWindow1] = 1;
			SetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), driver, !passenger, backleft, backright);
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s quay kinh cua ghe phu %s.", GetPlayerNameEx(playerid), (VehInfo[GetPlayerVehicleID(playerid)][vCarWindow1] == 0) ? ("len") : ("xuong"));
		}
		else if((GetPlayerState(playerid) == PLAYER_STATE_DRIVER && id == 2) || (GetPlayerState(playerid) == PLAYER_STATE_PASSENGER && GetPlayerVehicleSeat(playerid) == 2))
		{
			if(VehInfo[GetPlayerVehicleID(playerid)][vCarWindow2]) VehInfo[GetPlayerVehicleID(playerid)][vCarWindow2] = 0;
			else VehInfo[GetPlayerVehicleID(playerid)][vCarWindow2] = 1;
			SetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), driver, passenger, !backleft, backright);
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s quay kinh cua sau ben lai %s.", GetPlayerNameEx(playerid), (VehInfo[GetPlayerVehicleID(playerid)][vCarWindow2] == 0) ? ("len") : ("xuong"));
		}
		else if((GetPlayerState(playerid) == PLAYER_STATE_DRIVER && id == 3) || (GetPlayerState(playerid) == PLAYER_STATE_PASSENGER && GetPlayerVehicleSeat(playerid) == 3))
		{
			if(VehInfo[GetPlayerVehicleID(playerid)][vCarWindow3]) VehInfo[GetPlayerVehicleID(playerid)][vCarWindow3] = 0;
			else VehInfo[GetPlayerVehicleID(playerid)][vCarWindow3] = 1;
			SetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), driver, passenger, backleft, !backright);
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s quay kinh cua sau ben phu %s.", GetPlayerNameEx(playerid), (VehInfo[GetPlayerVehicleID(playerid)][vCarWindow3] == 0) ? ("len") : ("xuong"));
		}
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	}
	else if(strcmp(choice, "windows", true) == 0 && IsPlayerInAnyVehicle(playerid) && !IsABike(GetPlayerVehicleID(playerid)) && !IsABoat(GetPlayerVehicleID(playerid)))
	{
		if(NoWindows(GetPlayerVehicleID(playerid))) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung tinh nang nay voi loai xe nay.");
		new driver, passenger, backleft, backright;
		GetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), driver, passenger, backleft, backright);
		SetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), !driver, !passenger, !backleft, !backright);
	    if(VehInfo[GetPlayerVehicleID(playerid)][vCarWindows])
	    {
	    	VehInfo[GetPlayerVehicleID(playerid)][vCarWindows] = 0;
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s keo kinh xe len.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	    }
	    else {
            VehInfo[GetPlayerVehicleID(playerid)][vCarWindows] = 1;
			format(string, sizeof(string), "{FF8000}** {C2A2DA}%s ha kinh xe xuong.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	    }
	}
	return 1;
}

CMD:window(playerid, params[]) {
	
    if(InsidePlane[playerid] != INVALID_VEHICLE_ID && GetPVarType(playerid, "InsideCar")) {

        if(GetPlayerInterior(playerid) != 0) {

            new
                Float: fSpecPos[6];

            GetPlayerPos(playerid, fSpecPos[0], fSpecPos[1], fSpecPos[2]);
            GetPlayerFacingAngle(playerid, fSpecPos[3]);
            GetHealth(playerid, fSpecPos[4]);
            GetArmour(playerid, fSpecPos[5]);

            SetPVarFloat(playerid, "air_Xpos", fSpecPos[0]);
            SetPVarFloat(playerid, "air_Ypos", fSpecPos[1]);
            SetPVarFloat(playerid, "air_Zpos", fSpecPos[2]);
            SetPVarFloat(playerid, "air_Rpos", fSpecPos[3]);
            SetPVarFloat(playerid, "air_HP", fSpecPos[4]);
            SetPVarFloat(playerid, "air_Arm", fSpecPos[5]);
            SetPVarInt(playerid, "air_Int", GetPlayerInterior(playerid));
            SetPVarInt(playerid, "air_Mode", 1);

            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            TogglePlayerSpectating(playerid, true);
            PlayerSpectateVehicle(playerid, InsidePlane[playerid]);

            format(szMiscArray, sizeof(szMiscArray), "* %s nhin ra ngoai cua kinh.", GetPlayerNameEx(playerid));
            ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
        }
        else 
        {
        	TogglePlayerSpectating(playerid, 0);
        	SetPlayerPos(playerid, GetPVarFloat(playerid, "air_Xpos"), GetPVarFloat(playerid, "air_Ypos"), GetPVarFloat(playerid, "air_Zpos"));
   		}
    }
    return 1;
}

CMD:lock(playerid, params[])
{
   	if(PlayerInfo[playerid][pLock] == 1)
	{
 		if(IsPlayerInAnyVehicle(playerid))
   		{
			if(PlayerInfo[playerid][pLockCar] != GetPlayerVehicleID(playerid) && PlayerInfo[playerid][pLockCar] != INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua lap khoa cho xe nay!");
   			if(GetPlayerVehicleSeat(playerid) != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the khoa xe khi ngoi ghe hanh khach!");
   			new v = -1;
   			foreach(new i: Player)
			{
				v = GetPlayerVehicle(i, GetPlayerVehicleID(playerid));
				if(v != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the khoa xe thuoc so huu nguoi choi!");
			}	
   			if(PlayerInfo[playerid][pLockCar] == INVALID_VEHICLE_ID) PlayerInfo[playerid][pLockCar] = GetPlayerVehicleID(playerid);
      		if(LockStatus{GetPlayerVehicleID(playerid)} == 0)
        	{
				LockStatus{GetPlayerVehicleID(playerid)} = 1;
    			GameTextForPlayer(playerid, "~r~da khoa", 1000, 6);
       			PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
          		vehicle_lock_doors(PlayerInfo[playerid][pLockCar]);
      		}
        	else
	        {
				LockStatus{GetPlayerVehicleID(playerid)} = 0;
   				vehicle_unlock_doors(PlayerInfo[playerid][pLockCar]);
      			GameTextForPlayer(playerid, "~g~da mo khoa", 1000, 6);
        		PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
 	        }
   		}
	    else
	    {
     		new Float: x, Float: y, Float: z;
       		GetVehiclePos(PlayerInfo[playerid][pLockCar], x, y, z);
        	if(IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z))
        	{
         		if(LockStatus{PlayerInfo[playerid][pLockCar]} == 0)
           		{
            		vehicle_lock_doors(PlayerInfo[playerid][pLockCar]);
            		GameTextForPlayer(playerid, "~r~da khoa", 1000, 6);
	            	PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
 	            }
 	            else
 	            {
	            	vehicle_unlock_doors(PlayerInfo[playerid][pLockCar]);
	            	GameTextForPlayer(playerid, "~g~da mo khoa", 1000, 6);
	            	PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
          		}
   	        }
   	        else
   	        {
            	SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe cua minh!");
	            return 1;
   	        }
       	}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, " Ban khong co khoa!");
		return 1;
 	}
	return 1;
}

CMD:vstorage(playerid, params[])
{
	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0 || GetPVarInt(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the lam viec nay luc nay.");
	if(PlayerInfo[playerid][pFreezeCar] == 0 || PlayerInfo[playerid][pAdmin] >= 2)
	{
		new vstring[4096], icount = GetPlayerVehicleSlots(playerid);
		new szCarLocation[MAX_ZONE_NAME];
		format(vstring, sizeof(vstring), "Xe\tTrang thai\tVi tri\tTien phat\n");
		for(new i, iModelID; i < icount; i++) {
			if((iModelID = PlayerVehicleInfo[playerid][i][pvModelId] - 400) >= 0) {
				new vehicleName[18];
				Get3DZone(PlayerVehicleInfo[playerid][i][pvPosX], PlayerVehicleInfo[playerid][i][pvPosY], PlayerVehicleInfo[playerid][i][pvPosZ], szCarLocation, sizeof(szCarLocation));
				if(PlayerVehicleInfo[playerid][i][pvImpounded]) {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(vstring, sizeof(vstring), "%s%s\tTam giu\tDillimore DMV\t$%s\n", vstring, vehicleName, number_format(PlayerVehicleInfo[playerid][i][pvTicket]));
				}
				else if(PlayerVehicleInfo[playerid][i][pvDisabled]) {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(vstring, sizeof(vstring), "%s%s\tBi tat\t--\t$%s\n", vstring, vehicleName, number_format(PlayerVehicleInfo[playerid][i][pvTicket]));
				}
				else if(!PlayerVehicleInfo[playerid][i][pvSpawned]) {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(vstring, sizeof(vstring), "%s%s\tDa cat\t--\t$%s\n", vstring, vehicleName, number_format(PlayerVehicleInfo[playerid][i][pvTicket]));
				}
				else {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(vstring, sizeof(vstring), "%s%s\tDa lay\t%s\t$%s\n", vstring, vehicleName, szCarLocation, number_format(PlayerVehicleInfo[playerid][i][pvTicket]));
				}
			}
			else strcat(vstring, "Trong\t--\t--\t--\t--\n");
		}
		format(vstring, sizeof(vstring), "%s{40FFFF}Additional Vehicle Slot\t{FFD700}(Credits: %s){A9C4E4}\t\t\n", vstring, number_format(ShopItems[23][sItemPrice]));

		ShowPlayerDialogEx(playerid, VEHICLESTORAGE, DIALOG_STYLE_TABLIST_HEADERS, "Kho xe", vstring, "(De)spawn", "Huy");
	}
	else { return SendClientMessageEx(playerid, COLOR_GRAD2, "Tai san xe cua ban bi Judiciary dong bang. Hay lien he toa an dia phuong de giai quyet"); }
	return 1;
}
/*
CMD:vstorage(playerid, params[])
{
	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0 || GetPVarInt(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot do this at this time.");
	if(PlayerInfo[playerid][pFreezeCar] == 0 || PlayerInfo[playerid][pAdmin] >= 2)
	{
		szMiscArray[0] = 0;
		new icount = GetPlayerVehicleSlots(playerid);
		new szCarLocation[MAX_ZONE_NAME];
		for(new i, iModelID; i < icount; i++)
		{
			if((iModelID = PlayerVehicleInfo[playerid][i][pvModelId] - 400) >= 0) 
			{
				Get3DZone(PlayerVehicleInfo[playerid][i][pvPosX], PlayerVehicleInfo[playerid][i][pvPosY], PlayerVehicleInfo[playerid][i][pvPosZ], szCarLocation, sizeof(szCarLocation));
				if(PlayerVehicleInfo[playerid][i][pvImpounded]) {
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (impounded) | Location: DMV", szMiscArray, VehicleName[iModelID]);
				}
				else if(PlayerVehicleInfo[playerid][i][pvDisabled]) {
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (disabled) | Location: Unknown", szMiscArray, VehicleName[iModelID]);
				}
				else if(!PlayerVehicleInfo[playerid][i][pvSpawned]) {
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (stored)", szMiscArray, VehicleName[iModelID]);
				}
				else format(szMiscArray, sizeof(szMiscArray), "%s\n%s (spawned) | Location: %s", szMiscArray, VehicleName[iModelID], szCarLocation);
			}
			else strcat(szMiscArray, "\nEmpty");
		}
		format(szMiscArray, sizeof(szMiscArray), "%s\n{40FFFF}Additional Vehicle Slot {FFD700}(Credits: %s){A9C4E4}", szMiscArray, number_format(ShopItems[23][sItemPrice]));
		ShowPlayerDialogEx(playerid, VEHICLESTORAGE, DIALOG_STYLE_LIST, "Vehicle storage", szMiscArray, "(De)spawn", "Cancel");
	}
	else { return SendClientMessageEx(playerid, COLOR_GRAD2, "Your vehicle assets have been frozen by the Judiciary.  Consult your local courthouse to have this cleared"); }
	return 1;
}*/

CMD:trackcar(playerid, params[])
{
    if(GetPVarType(playerid, "RentedVehicle")) {
        ShowPlayerDialogEx(playerid, TRACKCAR2, DIALOG_STYLE_LIST, "Theo doi GPS xe", "Xe thue\nXe so huu", "Theo doi", "Huy");
	}
	else
	{
		szMiscArray[0] = 0;
		new icount = GetPlayerVehicleSlots(playerid);
		new szCarLocation[MAX_ZONE_NAME];
		for(new i, iModelID; i < icount; i++) 
		{
			if((iModelID = PlayerVehicleInfo[playerid][i][pvModelId] - 400) >= 0)
			{
				new vehicleName[18];
				Get3DZone(PlayerVehicleInfo[playerid][i][pvPosX], PlayerVehicleInfo[playerid][i][pvPosY], PlayerVehicleInfo[playerid][i][pvPosZ], szCarLocation, sizeof(szCarLocation));
				if(PlayerVehicleInfo[playerid][i][pvImpounded]) {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (tam giu) | Vi tri: DMV", szMiscArray, vehicleName);
				}
				else if(PlayerVehicleInfo[playerid][i][pvDisabled]) {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (bi tat) | Vi tri: Chua ro", szMiscArray, vehicleName);
				}
				else if(!PlayerVehicleInfo[playerid][i][pvSpawned]) {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (da cat)", szMiscArray, vehicleName);
				}
				else {
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s | Vi tri: %s", szMiscArray, vehicleName, szCarLocation);
				}
			}
		}
		ShowPlayerDialogEx(playerid, TRACKCAR, DIALOG_STYLE_LIST, "Theo doi GPS xe", szMiscArray, "Theo doi", "Huy");
	}
	return 1;
}

CMD:unmodcar(playerid, params[]) {
	for(new d = 0; d < MAX_PLAYERVEHICLES; d++) if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId])) {
		new modList[512], string[16];
		new count = 0;
		for(new f = 0; f < MAX_MODS; f++) if(GetVehicleComponentInSlot(PlayerVehicleInfo[playerid][d][pvId], f) != 0) {
			if(f != 9 && f != 7 && f != 8) {
				format(modList, sizeof(modList), "%s\n%s - %s", modList, partType(f), partName(GetVehicleComponentInSlot(PlayerVehicleInfo[playerid][d][pvId], f)));
			}
			else format(modList, sizeof(modList), "%s\n%s", modList, partType(f));

			format(string, sizeof(string), "partList%d", count);
			SetPVarInt(playerid, string, GetVehicleComponentInSlot(PlayerVehicleInfo[playerid][d][pvId], f));
			count++;
		}
		if (count == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, " Xe nay khong co phu tung do.");
			return 1;
		}
		format(modList, sizeof(modList), "%s\nHet", modList);
		format(string, sizeof(string), "partList%d", count);
		SetPVarInt(playerid, string, 999);
		count++;
		SetPVarInt(playerid, "modCount", count);
		return ShowPlayerDialogEx(playerid, UNMODCARMENU, DIALOG_STYLE_LIST, "Thao phu tung do", modList, "Chon", "Huy");
	}
	SendClientMessageEx(playerid, COLOR_GREY, " Ban can ngoi trong xe cua minh.");
 	return 1;
}

CMD:deletecar(playerid, params[])
{
	szMiscArray[0] = 0;
	new icount = GetPlayerVehicleSlots(playerid);
	for(new i, iModelID; i < icount; i++) {
		if((iModelID = PlayerVehicleInfo[playerid][i][pvModelId] - 400) >= 0)
		{
			new vehicleName[18];
			strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
			if(PlayerVehicleInfo[playerid][i][pvImpounded]) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s (tam giu)", szMiscArray, vehicleName);
			}
			else if(PlayerVehicleInfo[playerid][i][pvDisabled]) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s (bi tat)", szMiscArray, vehicleName);
			}
			else if(!PlayerVehicleInfo[playerid][i][pvSpawned]) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s (da cat)", szMiscArray, vehicleName);
			}
			else {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s", szMiscArray, vehicleName);
			}
		}
		else strcat(szMiscArray, "\nTrong");
	}
	return ShowPlayerDialogEx(playerid, DIALOG_DELETECAR, DIALOG_STYLE_LIST, "Xoa xe", szMiscArray, "Xoa", "Huy");
}

CMD:parktrailer(playerid, params[]) {
	for(new i = 0, Float: fVehiclePos[4], iVehicleID; i != MAX_PLAYERVEHICLES; ++i) switch(GetVehicleModel((iVehicleID = PlayerVehicleInfo[playerid][i][pvId]))) {
		case 435, 450, 584, 591, 606, 607, 608, 610, 611: {
			GetVehiclePos(iVehicleID, fVehiclePos[0], fVehiclePos[1], fVehiclePos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 10.0, fVehiclePos[0], fVehiclePos[1], fVehiclePos[2])) {

				new
					szMessage[64];

				GetVehicleZAngle(iVehicleID, fVehiclePos[3]);
				UpdatePlayerVehicleParkPosition(playerid, i, fVehiclePos[0], fVehiclePos[1], fVehiclePos[2], fVehiclePos[3], 1000.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

				format(szMessage, sizeof szMessage, "* %s da do ro-mooc cua minh.", GetPlayerNameEx(playerid));
				return ProxDetector(30.0, playerid, szMessage, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
			}
		}
	}
	return 1;
}

CMD:park(playerid, params[])
{
	new
		iVehicle = GetPlayerVehicleID(playerid),
		iBusiness = GetCarBusiness(iVehicle),
		Float: XYZ[4];

    if(iVehicle == GetPVarInt(playerid, "RentedVehicle"))
	{
	    new Float:x, Float:y, Float:z, Float:health;
		GetVehicleHealth(iVehicle, health);
  		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai ngoi ghe lai.");
		if(health < 800) return SendClientMessageEx(playerid, COLOR_GREY, " Xe hong qua nang, khong the do.");
		if(PlayerInfo[playerid][pLockCar] == GetPlayerVehicleID(playerid)) PlayerInfo[playerid][pLockCar] = INVALID_VEHICLE_ID;
		GetPlayerPos(playerid, x, y, z);

		SetTimerEx("ParkRentedVehicle", 1000, false, "iiifff", playerid, iVehicle, GetVehicleModel(iVehicle), x, y, z);
		SendClientMessageEx (playerid, COLOR_YELLOW, "Dung di chuyen de do xe!");
		return 1;
	}
	if (iVehicle != 0 && iBusiness != INVALID_BUSINESS_ID)
	{
	 	if (iBusiness != PlayerInfo[playerid][pBusiness]) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co quyen do xe nay.");
		new
			iSlot = GetBusinessCarSlot(iVehicle);

		GetVehiclePos(iVehicle, XYZ[0], XYZ[1], XYZ[2]);
		GetVehicleZAngle(iVehicle, XYZ[3]);

		Businesses[iBusiness][bParkPosX][iSlot] = XYZ[0];
		Businesses[iBusiness][bParkPosY][iSlot] = XYZ[1];
		Businesses[iBusiness][bParkPosZ][iSlot] = XYZ[2];
		Businesses[iBusiness][bParkAngle][iSlot] = XYZ[3];

		DestroyVehicle(Businesses[iBusiness][bVehID][iSlot]);
		Businesses[iBusiness][bVehID][iSlot] = CreateVehicle(Businesses[iBusiness][bModel][iSlot], Businesses[iBusiness][bParkPosX][iSlot], Businesses[iBusiness][bParkPosY][iSlot], Businesses[iBusiness][bParkPosZ][iSlot],
		Businesses[iBusiness][bParkAngle][iSlot], 0, 0, 10);

		if(IsValidDynamic3DTextLabel(Businesses[iBusiness][bVehicleLabel][iSlot])) DestroyDynamic3DTextLabel(Businesses[iBusiness][bVehicleLabel][iSlot]), Businesses[iBusiness][bVehicleLabel][iSlot] = Text3D:-1;
		szMiscArray[0] = 0;
		format(szMiscArray, sizeof(szMiscArray), "%s Dang ban | Gia: $%s", GetVehicleName(Businesses[iBusiness][bVehID][iSlot]), number_format(Businesses[iBusiness][bPrice][iSlot]));
		Businesses[iBusiness][bVehicleLabel][iSlot] = CreateDynamic3DTextLabel(szMiscArray, COLOR_LIGHTBLUE, Businesses[iBusiness][bParkPosX][iSlot]+1.0, Businesses[iBusiness][bParkPosY][iSlot]+1.0, Businesses[iBusiness][bParkPosZ][iSlot]+1.0, 8.0, INVALID_PLAYER_ID, Businesses[iBusiness][bVehID][iSlot]);
		
        SaveDealershipVehicle(iBusiness, iSlot);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da do xe nay.");
		return 1;
	}

	if(PlayerInfo[playerid][pVehicleKeysFrom] != INVALID_PLAYER_ID)
	{
		new ownerid = PlayerInfo[playerid][pVehicleKeysFrom];
		if(IsPlayerConnected(ownerid))
		{
			new d = PlayerInfo[playerid][pVehicleKeys];
			if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[ownerid][d][pvId]))
			{
				if(PlayerVehicleInfo[ownerid][d][pvBeingPickLocked] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Hien ban khong the do xe nay.");
			    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai ngoi ghe lai.");
				new Float:x, Float:y, Float:z, Float:health;
				GetVehicleHealth(PlayerVehicleInfo[ownerid][d][pvId], health);
				if(health < 800) return SendClientMessageEx(playerid, COLOR_GREY, " Xe hong qua nang, khong the do.");
				if(PlayerInfo[playerid][pLockCar] == GetPlayerVehicleID(playerid)) PlayerInfo[playerid][pLockCar] = INVALID_VEHICLE_ID;

                GetPlayerPos(playerid, x, y, z);
                SetTimerEx("ParkVehicle", 1000, false, "iiiifff", playerid, ownerid, PlayerVehicleInfo[ownerid][d][pvId], d, x, y, z);
                SendClientMessageEx (playerid, COLOR_YELLOW, "Dung di chuyen de do xe!");
				return 1;
			}
		}
	}
	for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
	{
		if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId]))
		{
			if(PlayerVehicleInfo[playerid][d][pvBeingPickLocked] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Hien ban khong the do xe nay.");
			if(WheelClamp{PlayerVehicleInfo[playerid][d][pvId]}) return SendClientMessageEx(playerid, COLOR_GREY, "Hien ban khong the do xe nay.");
			new Float:x, Float:y, Float:z, Float:health;
			GetVehicleHealth(PlayerVehicleInfo[playerid][d][pvId], health);
            if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai ngoi ghe lai.");
			if(health < 800) return SendClientMessageEx(playerid, COLOR_GREY, " Xe hong qua nang, khong the do.");
			if(PlayerInfo[playerid][pLockCar] == GetPlayerVehicleID(playerid)) PlayerInfo[playerid][pLockCar] = INVALID_VEHICLE_ID;
			GetPlayerPos(playerid, x, y, z);

   			SetTimerEx("ParkVehicle", 1000, false, "iiiifff", playerid, INVALID_PLAYER_ID, PlayerVehicleInfo[playerid][d][pvId], d, x, y, z);
      		SendClientMessageEx (playerid, COLOR_YELLOW, "Dung di chuyen de do xe!");
			return 1;
		}
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Ban can ngoi trong xe cua minh.");
	return 1;
}

CMD:carkeys(playerid, params[])
{
	szMiscArray[0] = 0;
	new iValidVehicles;
	for(new i=0; i<MAX_PLAYERVEHICLES; i++)
	{
	    new vehicleName[18];
	    if(PlayerVehicleInfo[playerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID) {
	        if(PlayerVehicleInfo[playerid][i][pvAllowedPlayerId] != INVALID_PLAYER_ID) {
				strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s | Khoa: %s", szMiscArray, vehicleName, GetPlayerNameEx(PlayerVehicleInfo[playerid][i][pvAllowedPlayerId])), ++iValidVehicles;
			}
			else {
                strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
                format(szMiscArray, sizeof(szMiscArray), "%s\n%s | Khoa: Chua", szMiscArray, vehicleName);
			}
		}
        else if((PlayerVehicleInfo[playerid][i][pvImpounded] == 1 || PlayerVehicleInfo[playerid][i][pvSpawned] == 0) && PlayerVehicleInfo[playerid][i][pvModelId] != 0) {
            strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
            format(szMiscArray, sizeof(szMiscArray), "%s\n%s | Khoa: Chua co", szMiscArray, vehicleName);
		}
        else {
			strcat(szMiscArray, "\nTrong");
		}
	}
	if(iValidVehicles != 0)
	{
		ShowPlayerDialogEx(playerid, REMOVEKEYS, DIALOG_STYLE_LIST, "Vui long chon xe.", szMiscArray, "Thu hoi chia khoa", "Huy");
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua giao chia khoa cho ai.");
	}
	return 1;
}



alias:seatbelt("sb")
CMD:seatbelt(playerid, const params[])
{
    if(IsPlayerInAnyVehicle(playerid) == false)
	{
        SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong ngoi trong xe!");
        return 1;
    }

    if(IsPlayerInAnyVehicle(playerid) == true && Seatbelt[playerid] == 0)
	{
        if(IsABike(GetPlayerVehicleID(playerid)))
            return SendClientMessageEx(playerid, COLOR_WHITE, "Da co tinh nang mu bao hiem, mua tai bat ky 24/7 nao va dung /helmet(/hm).");
        else
		{
            format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s dua tay lay day an toan va cai lai.", GetPlayerNameEx(playerid));
            SendClientMessageEx(playerid, COLOR_WHITE, "Ban da that day an toan.");
			Seatbelt[playerid] = 1;
        }

    }
    else if(IsPlayerInAnyVehicle(playerid) == true && Seatbelt[playerid] == 1)
	{
        if(IsABike(GetPlayerVehicleID(playerid)))
		{
            return SendClientMessageEx(playerid, COLOR_WHITE, "Da co tinh nang mu bao hiem, mua tai bat ky 24/7 nao va dung /helmet(/hm).");
        }
        else
		{
            format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s dua tay thao day an toan.", GetPlayerNameEx(playerid));
            SendClientMessageEx(playerid, COLOR_WHITE, "Ban da thao day an toan.");
			Seatbelt[playerid] = 0;
        }
    }
	else return 1;
	ProxChatBubble(playerid, szMiscArray);
    // ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    return 1;
}



alias:checkbelt("cb")
CMD:checkbelt(playerid, params[])
{
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /checkbelt [player]");

    if(GetPlayerState(giveplayerid) == PLAYER_STATE_ONFOOT)
	{
        SendClientMessageEx(playerid,COLOR_GREY,"Nguoi do khong o trong xe!");
        return 1;
    }
    if (ProxDetectorS(9.0, playerid, giveplayerid))
	{
		new string[128];
        new stext[4];
        if(Seatbelt[giveplayerid] == 0) { stext = "tat"; }
        else { stext = "bat"; }
        if(IsABike(GetPlayerVehicleID(playerid)))
		{
            SendClientMessageEx(playerid, COLOR_WHITE, "Da co tinh nang mu bao hiem, hay dung /checkhelmet(/chm).");
        }
        else
		{
            SendClientMessageEx(playerid,COLOR_WHITE,"Day an toan cua %s hien dang %s." , GetPlayerNameEx(giveplayerid) , stext);

            format(string, sizeof(string), "* %s nhin qua kinh xe vao %s, kiem tra xem ho co that day an toan khong.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid));
            // ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            ProxChatBubble(playerid, string);
        }
    }
    else { SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan nguoi choi do!"); }
    return 1;
}

CMD:givekeys(playerid, params[])
{
	new
		giveplayerid;

    if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givekeys [player]");
    if(IsPlayerConnected(giveplayerid))
	{
        if(playerid == giveplayerid) return 1;
        if (ProxDetectorS(4.0, playerid, giveplayerid))
		{
			szMiscArray[0] = 0;
			new iValidVehicles;

			for(new i; i < MAX_PLAYERVEHICLES; i++) if(PlayerVehicleInfo[playerid][i][pvModelId] >= 400)
			{
				new vehicleName[18];
				if(PlayerVehicleInfo[playerid][i][pvImpounded] == 1)
					{
						strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s\n%s (tam giu)", szMiscArray, vehicleName);
					}

				else if(PlayerVehicleInfo[playerid][i][pvDisabled] == 1)
					{
						strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s\n%s (bi tat)", szMiscArray, vehicleName);
					}

				else if(PlayerVehicleInfo[playerid][i][pvSpawned] == 0)
					{
						strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s\n%s (da cat)", szMiscArray, vehicleName);
					}

				else
					{
						strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s\n%s", szMiscArray, vehicleName), ++iValidVehicles;
					}
			}
			else strcat(szMiscArray, "\nTrong");
            if(iValidVehicles != 0)
			{
                GiveKeysTo[playerid] = giveplayerid;
                ShowPlayerDialogEx(playerid, GIVEKEYS, DIALOG_STYLE_LIST, "Vui long chon xe.", szMiscArray, "Giao chia khoa", "Huy");
            }
            else
			{
                SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co xe de giao chia khoa.");
            }
        }
        else
		{
            SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o du gan nguoi choi do.");
        }
    }
    return 1;
}

CMD:sellmycar(playerid, params[])
{
	if(restarting) return SendClientMessageEx(playerid, COLOR_GRAD2, "Giao dich da tam dung de khoi dong lai may chu bao tri.");
    if(PlayerInfo[playerid][pFreezeCar] == 1)
    {
   		return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Tai san xe cua ban bi dong bang, ban khong the ban xe!");
	}
    for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
	{
        if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId]))
 		{
			if(PlayerInfo[playerid][pBackpack] > 0 && PlayerInfo[playerid][pBStoredV] == PlayerVehicleInfo[playerid][d][pvSlotId] && !GetPVarInt(playerid, "confirmvehsell")) 
			{
				SetPVarInt(playerid, "confirmvehsell", 1);
				return SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Ban co ba lo trong xe nay, hay lay ra truoc de tranh mat do, vui long xac nhan!");
			}
            new Float:health;
            GetVehicleHealth(PlayerVehicleInfo[playerid][d][pvId], health);
            if(PlayerInfo[playerid][pLevel] == 1)
			{
                SendClientMessageEx(playerid, COLOR_GREY, "Ban phai dat cap 2 tro len de ban xe.");
                return 1;
            }
            if(health < 500) return SendClientMessageEx(playerid, COLOR_GREY, " Xe cua ban hong qua nang de ban.");

            new giveplayerid, price, alarmstring[9], lockstring[11], worklockstring[10];
			if(sscanf(params, "ud", giveplayerid, price)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sellmycar [player] [price]");

            if(price < 1 || price > 1000000000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia phai lon hon 0 va nho hon 1,000,000,000.");
            if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
            if(PlayerInfo[giveplayerid][pLevel] == 1)
			{
                SendClientMessageEx(playerid, COLOR_GREY, "Nguoi mua xe phai dat cap 2 tro len.");
                return 1;
            }
            if(playerid == giveplayerid)
			{
                SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the dung lenh nay voi chinh minh.");
                return 1;
            }
            /*if(IsWeaponizedVehicle(PlayerVehicleInfo[playerid][d][pvModelId]))
            {
                SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to sell this restricted vehicle.");
                return 1;
            }*/ // Uncomment to disallow the sale of weaponized vehicles. 
			if(gettime()-GetPVarInt(playerid, "LastTransaction") < 60)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chi co the ban xe moi 60 giay, vui long cho!");
				return 1;
			}
			if(PlayerVehicleInfo[playerid][d][pvTicket] > 0)
			{
			    SendClientMessageEx(playerid, COLOR_GREY, "Xe cua ban con tien phat chua nop, hay nop phat truoc khi ban.");
			    return 1;
			}
            if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi hien khong ket noi voi may chu.");
            if (ProxDetectorS(8.0, playerid, giveplayerid))
		 	{
		 	    if(PlayerInfo[giveplayerid][pFreezeCar] == 1)
	 		    {
	            	SendClientMessageEx(giveplayerid, COLOR_WHITE, "LOI: Tai san xe cua ban bi dong bang, ban khong the mua xe!");
	            	SendClientMessageEx(playerid, COLOR_WHITE, "LOI: Tai san xe cua ho bi dong bang, ho khong the mua xe!");
	            	return 1;
				}
				if(IsWeaponizedVehicle(PlayerVehicleInfo[playerid][d][pvModelId]))
				{
					new dialogstring[255], fine = (price / 100) * 15;
					format(dialogstring, sizeof(dialogstring), "Ban xe vu trang se bi phat 15 percent gia tri moi xe.\n\n{FF0000}Ban chi nhan %s(tien phat: %s) tu giao dich nay, tiep tuc?", number_format(price-fine), number_format(fine));
					ShowPlayerDialogEx(playerid, DIALOG_WEPVEHSALE, DIALOG_STYLE_MSGBOX, "{FF0000}Notice", dialogstring, "Tiep tuc", "Thoat");

					SetPVarInt(playerid, "WepVehSalePlayer", giveplayerid);
					SetPVarInt(playerid, "WepVehSaleSession", g_arrQueryHandle[giveplayerid]);
					SetPVarInt(playerid, "WepVehSaleSQLId", PlayerVehicleInfo[playerid][d][pvSlotId]);
					SetPVarInt(playerid, "WepVehSaleVehicle", d);
					SetPVarInt(playerid, "WepVehSalePrice", price);
					SetPVarInt(playerid, "WepVehSaleFine", fine);
					return 1;
				}
				SetPVarInt(playerid, "LastTransaction", gettime());
                VehicleOffer[giveplayerid] = playerid;
                SetPVarInt(giveplayerid, "VehicleOfferSession", g_arrQueryHandle[playerid]);
                SetPVarInt(giveplayerid, "VehicleOfferSQLId", PlayerVehicleInfo[playerid][d][pvSlotId]);
                VehicleId[giveplayerid] = d;
                VehiclePrice[giveplayerid] = price;
				switch(PlayerVehicleInfo[playerid][d][pvAlarm]) {
					case 1: alarmstring = "Standard";
					case 2: alarmstring = "Deluxe";
					default: alarmstring = "khong";
				}
				switch(PlayerVehicleInfo[playerid][d][pvLock]) {
					case 2: lockstring = "Electronic";
					case 3: lockstring = "Industrial";
					default: lockstring = "khong";
				}
				if(PlayerVehicleInfo[playerid][d][pvLocksLeft] < 1) worklockstring = "(Hong)";
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban chao ban cho %s xe %s nay voi bao dong %s & khoa %s%s gia $%s.", GetPlayerNameEx(giveplayerid), GetVehicleName(PlayerVehicleInfo[playerid][d][pvId]), alarmstring, worklockstring, lockstring, number_format(price));
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s chao ban xe %s (VID: %d) voi bao dong %s & khoa %s%s gia $%s, (go /accept car) de mua.", GetPlayerNameEx(playerid), GetVehicleName(PlayerVehicleInfo[playerid][d][pvId]), PlayerVehicleInfo[playerid][d][pvId], alarmstring, worklockstring, lockstring, number_format(price));
				DeletePVar(playerid, "confirmvehsell");
                return 1;
            }
            else
			{
                SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
                return 1;
            }
        }
    }
    SendClientMessageEx(playerid, COLOR_GREY, " Ban can ngoi trong xe cua minh.");
    return 1;
}

CMD:pvlock(playerid, params[])
{
    new Float: x, Float: y, Float: z;
    if(PlayerInfo[playerid][pVehicleKeysFrom] != INVALID_PLAYER_ID)
	{
        new ownerid = PlayerInfo[playerid][pVehicleKeysFrom];
        if(IsPlayerConnected(ownerid))
		{
            new d = PlayerInfo[playerid][pVehicleKeys];
            if(PlayerVehicleInfo[ownerid][d][pvId] != INVALID_PLAYER_VEHICLE_ID) GetVehiclePos(PlayerVehicleInfo[ownerid][d][pvId], x, y, z);
            if(IsPlayerInRangeOfPoint(playerid, 3.0, x, y, z))
			{
                if(PlayerVehicleInfo[ownerid][d][pvLock] > 0)
				{
					if(PlayerVehicleInfo[ownerid][d][pvLocksLeft] <= 0) {
						SendClientMessageEx(playerid, COLOR_GREY, "Khoa da bi hong do bi pha!");
						return 1;
					}
					if(PlayerVehicleInfo[ownerid][d][pvBeingPickLocked]) {
						SendClientMessageEx(playerid, COLOR_GREY, "Hien khong the khoa/mo khoa xe nay.");
						return 1;
					}
                    if(PlayerVehicleInfo[ownerid][d][pvLocked] == 0)
					{
                        GameTextForPlayer(playerid,"~r~Da khoa xe!",5000,6);
                        PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                        PlayerVehicleInfo[ownerid][d][pvLocked] = 1;
                        LockPlayerVehicle(ownerid, PlayerVehicleInfo[ownerid][d][pvId], PlayerVehicleInfo[ownerid][d][pvLock]);
                        return 1;
                    }
                    else
					{
                        GameTextForPlayer(playerid,"~g~Da mo khoa xe!",5000,6);
                        PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                        PlayerVehicleInfo[ownerid][d][pvLocked] = 0;
                        UnLockPlayerVehicle(ownerid, PlayerVehicleInfo[ownerid][d][pvId], PlayerVehicleInfo[ownerid][d][pvLock]);
                        return 1;
                    }
                }
                else
				{
                    SendClientMessageEx(playerid, COLOR_GREY, " Ban chua lap he thong khoa tren xe nay.");
					return 1;
                }
            }
        }
    }
    for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
    {
        if(PlayerVehicleInfo[playerid][d][pvId] != INVALID_PLAYER_VEHICLE_ID) GetVehiclePos(PlayerVehicleInfo[playerid][d][pvId], x, y, z);
        if(IsPlayerInRangeOfPoint(playerid, 3.0, x, y, z))
		{
			if(PlayerVehicleInfo[playerid][d][pvLocksLeft] <= 0) {
				SendClientMessageEx(playerid, COLOR_GREY, "Khoa da bi hong do bi pha, hay mua khoa moi!");
				return 1;
			}
			if(PlayerVehicleInfo[playerid][d][pvBeingPickLocked]) {
				SendClientMessageEx(playerid, COLOR_GREY, "Hien khong the khoa/mo khoa xe nay.");
				return 1;
			}
            if(PlayerVehicleInfo[playerid][d][pvLock] > 0 && PlayerVehicleInfo[playerid][d][pvLocked] == 0)
			{
                GameTextForPlayer(playerid,"~r~Da khoa xe!",5000,6);
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                PlayerVehicleInfo[playerid][d][pvLocked] = 1;
                LockPlayerVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId], PlayerVehicleInfo[playerid][d][pvLock]);
                return 1;
            }
            else if(PlayerVehicleInfo[playerid][d][pvLock] > 0 && PlayerVehicleInfo[playerid][d][pvLocked] == 1)
			{
                GameTextForPlayer(playerid,"~g~Da mo khoa xe!",5000,6);
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                PlayerVehicleInfo[playerid][d][pvLocked] = 0;
                UnLockPlayerVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId], PlayerVehicleInfo[playerid][d][pvLock]);
                return 1;

            }
            SendClientMessageEx(playerid, COLOR_GREY, " Ban chua lap he thong khoa tren xe nay.");
            return 1;
        }
    }
    SendClientMessageEx(playerid, COLOR_GREY, " Ban khong o gan xe cua minh.");
    return 1;
}

CMD:vehid(playerid, params[])
{
    if(IsPlayerInAnyVehicle(playerid))
    {
    	new idcar = GetPlayerVehicleID(playerid);
		SendClientMessageEx(playerid, COLOR_GREY, "* Ten xe: %s | Model xe:%d | ID xe: %d.",GetVehicleName(idcar), GetVehicleModel(idcar), idcar);
	}
	return 1;
}

CMD:rc(playerid, params[])
{
	#if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombies khong the dung tinh nang nay.");
	#endif
	new ccar = GetClosestCar(playerid);
	if(IsARC(ccar) && IsPlayerInRangeOfVehicle(playerid, ccar, 5.0))
	{
		if(IsPlayerInVehicle(playerid,ccar))
		{
			new Float:vehPos[3];
			GetVehiclePos(ccar,vehPos[0], vehPos[1], vehPos[2]);
			SetPlayerPos(playerid,vehPos[0], vehPos[1]+0.5, vehPos[2]+0.5);
		}
		else if(!IsPlayerInAnyVehicle(playerid))
		{
			foreach(new i: Player)
			{
				new v = GetPlayerVehicle(i, ccar);
				if(v != -1 && PlayerVehicleInfo[i][v][pvLocked] == 0)
				{
					new Float:playerPos[3];
					GetPlayerPos(playerid,playerPos[0],playerPos[1],playerPos[2]);
					SetPlayerPos(playerid,playerPos[0],playerPos[1],playerPos[2]-500);
					IsPlayerEntering{playerid} = true;
					PutPlayerInVehicle(playerid, ccar, 0);
				}
			}	
		}
	}
	return 1;
}



alias:oldcar("lastcar")
CMD:oldcar(playerid, params[])
{
	if(!gLastCar[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua tung lai xe.");
	SendClientMessageEx(playerid, COLOR_GREY, "Xe ban lai gan nhat la %s (Model: %d -- ID: %d)", GetVehicleName(gLastCar[playerid]), GetVehicleModel(gLastCar[playerid]), gLastCar[playerid]);
	return 1;
}

CMD:userimkit(playerid, params[])
{
	if(PlayerInfo[playerid][pRimMod] == 0)
	    return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Rim Modification Kit.");

    if(!IsPlayerInAnyVehicle(playerid))
 		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong ngoi trong xe.");

	if(!Job_HasJob(playerid, JOB_MECHANIC))
 		return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai la mechanic de dung lenh nay.");
	
	new iVeh = GetPlayerVehicleID(playerid);
	new iModel  = GetVehicleModel(iVeh);

	if(IsRestrictedVehicle(iModel)) return SendClientMessageEx(playerid, COLOR_GREY, "Xe nay khong the lap mam xe");

    if(InvalidModCheck(iModel, 1025))
	{
 		for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
		{
			if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId]))
			{
				ShowPlayerDialogEx(playerid, DIALOG_RIMMOD, DIALOG_STYLE_LIST, "Rim Modification Kit", "Offroad\nShadow\nMega\nRimshine\nWires\nClassic\nTwist\nCutter\nSwitch\nGrove\nImport\nDollar\nTrance\nAtomic\nAhab\nVirtual\nAccess", "Chon", "Thoat");
				return 1;
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Ban can ngoi trong xe cua minh.");
		return 1;
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "Xe nay khong the do.");
	}

	return 1;
}

CMD:eject(playerid, params[])
{
	new State;
	if(IsPlayerInAnyVehicle(playerid))
	{
		State=GetPlayerState(playerid);
		if(State!=PLAYER_STATE_DRIVER)
		{
			SendClientMessageEx(playerid,COLOR_GREY,"   Chi nguoi lai moi duoc duoi hanh khach!");
			return 1;
		}

		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /eject [player]");

		new test;
		test = GetPlayerVehicleID(playerid);
		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
				if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the tu duoi minh!"); return 1; }
				if(IsPlayerInVehicle(giveplayerid,test))
				{
					if(GetPVarInt(giveplayerid, "EMSAttempt") != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the duoi benh nhan!");
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da duoi %s ra khoi xe.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Ban bi %s duoi ra khoi xe.", GetPlayerNameEx(playerid));
					RemovePlayerFromVehicle(giveplayerid);
					new Float:slx, Float:sly, Float:slz;
					GetPlayerPos(giveplayerid, slx, sly, slz);
					SetPlayerPos(giveplayerid, slx, sly+3, slz+1);
					format(string, sizeof(string), "* %s da duoi %s ra khoi xe.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi do khong o trong xe cua ban!");
					return 1;
				}
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, " ID/Ten khong hop le!");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban can ngoi trong xe de dung tinh nang nay!");
	}
	return 1;
}

RentVehicleTimer(i)
{
	szMiscArray[0] = 0;
	if(GetPVarType(i, "RentedVehicle"))
	{
		if(GetPVarInt(i, "RentedHours") > 0)
		{
			SetPVarInt(i, "RentedHours", GetPVarInt(i, "RentedHours")-1);
			if(GetPVarInt(i, "RentedHours") == 0)
			{
				SendClientMessageEx(i, COLOR_CYAN, "Xe thue cua ban da het han.");
				DestroyVehicle(GetPVarInt(i, "RentedVehicle"));

				mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "DELETE FROM `rentedcars` WHERE `sqlid`= '%d'", GetPlayerSQLId(i));
				mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);

				DeletePVar(i, "RentedHours");
				DeletePVar(i, "RentedVehicle");
			}
			else if(GetPVarInt(i, "RentedHours") == 120 || GetPVarInt(i, "RentedHours") == 60)
			{
				format(szMiscArray, sizeof(szMiscArray), "Xe thue cua ban con %d phut.", GetPVarInt(i, "RentedHours"));
				SendClientMessageEx(i, COLOR_CYAN, szMiscArray);
			}
			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `rentedcars` SET `hours` = '%d' WHERE `sqlid` = '%d'",GetPVarInt(i, "RentedHours"), GetPlayerSQLId(i));
			mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
		}
	}
}