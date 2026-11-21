/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Boombox System

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

CMD:setboombox(playerid, params[])
{
	if(GetPVarType(playerid, "pBoomBox"))
	{
		ShowSetStation(playerid);
    }
	else
	{
	    SendClientMessage(playerid, COLOR_GRAD2, "Ban chua dat boombox!");
	}
	return 1;
}

CMD:shopboombox(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new giveplayerid, invoice;
	if(sscanf(params, "ui", giveplayerid, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shopboombox [player] [invoice #]");
	new string[128];

	if(PlayerInfo[giveplayerid][pBoombox] == 1)
	{
	    PlayerInfo[giveplayerid][pBoombox] = 0;
		SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Boombox cua ban da bi Shop Tech %s thu hoi. ", GetPlayerNameEx(playerid));
		format(string, sizeof(string), "[SHOPBOOMBOX] %s da thu boombox cua %s(%d) - Invoice %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
		SendClientMessageEx(playerid, COLOR_GRAD1, string);
		format(string, sizeof(string), "[SHOPBOOMBOX] %s has taken %s(%d) boombox - Invoice %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
		Log("logs/shoplog.log", string);
	}
	else
	{
		PlayerInfo[giveplayerid][pBoombox] = 1;
		SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc Shop Tech %s cap boombox. ", GetPlayerNameEx(playerid));
		format(string, sizeof(string), "[SHOPBOOMBOX] %s da cap boombox cho %s(%d) - Invoice %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
		SendClientMessageEx(playerid, COLOR_GRAD1, string);
		format(string, sizeof(string), "[SHOPBOOMBOX] %s has given %s(%d) a boombox - Invoice %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
		Log("logs/shoplog.log", string);
	}
	return 1;
}

CMD:placeboombox(playerid, params[])
{
	if(PlayerInfo[playerid][pBoombox] == 1 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
	    if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay trong dau truong!");
		if(GetPVarInt(playerid, "WatchingTV")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay khi dang xem TV!");
		if(GetPVarInt(playerid, "Injured") == 1 || PlayerInfo[playerid][pJailTime] > 0 || PlayerInfo[playerid][pHospital] > 0 || IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban chua the lam vay.");
		//if(PlayerInfo[playerid][pVW] == 0 || PlayerInfo[playerid][pInt] == 0) return SendClientMessageEx(playerid, COLOR_WHITE, "You can only place boomboxes inside interiors.");
		if(GetPVarType(playerid, "pBoomBox")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban da dat boombox, dung /destroyboombox.");

		foreach(new i: Player)
		{
			if(GetPVarType(i, "pBoomBox"))
			{
				if(IsPlayerInRangeOfPoint(playerid, 30.0, GetPVarFloat(i, "pBoomBoxX"), GetPVarFloat(i, "pBoomBoxY"), GetPVarFloat(i, "pBoomBoxZ")) && GetPVarInt(i, "pBoomBoxVW") == GetPlayerVirtualWorld(playerid))
				{
					SendClientMessage(playerid, COLOR_WHITE, "Co boombox khac o gan, khong the dat tai day!");
					return 1;
				}
			}
		}	

		new string[128];
		format(string, sizeof(string), "%s da dat boombox!", GetPlayerNameEx(playerid));
	    ProxDetector(30.0, playerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);

	    new Float:x, Float:y, Float:z, Float:a;
	    GetPlayerPos(playerid, x, y, z);
	    GetPlayerFacingAngle(playerid, a);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant_Crouch_In", 4.0, false, false, false, false, 0, 1);
	    x += (2 * floatsin(-a, degrees));
    	y += (2 * floatcos(-a, degrees));
    	z -= 1.0;

	    SetPVarInt(playerid, "pBoomBox", CreateDynamicObject(2103, x, y, z, 0.0, 0.0, a, .worldid = GetPlayerVirtualWorld(playerid), .interiorid = GetPlayerInterior(playerid)));
	    SetPVarFloat(playerid, "pBoomBoxX", x); SetPVarFloat(playerid, "pBoomBoxY", y); SetPVarFloat(playerid, "pBoomBoxZ", z);
		format(string, sizeof(string), "Boombox cua %s\n{FF0000}/setboombox {FFFF00}hoac\n{FF0000}/destroyboombox", GetPlayerNameEx(playerid));
	    SetPVarInt(playerid, "pBoomBoxLabel", _:CreateDynamic3DTextLabel(string, COLOR_YELLOW, x, y, z+0.6, 5.0, .worldid = GetPlayerVirtualWorld(playerid), .interiorid = GetPlayerInterior(playerid)));
		SetPVarInt(playerid, "pBoomBoxArea", CreateDynamicSphere(x, y, z, 30.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid)));
		SetPVarInt(playerid, "pBoomBoxInt", GetPlayerInterior(playerid));
		SetPVarInt(playerid, "pBoomBoxVW", GetPlayerVirtualWorld(playerid));
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co boombox! Mua tai shop.ng-gaming.net");
	}
	return 1;
}

CMD:destroyboombox(playerid, params[])
{
	if(GetPVarType(playerid, "pBoomBox"))
	{
	    DestroyDynamicObject(GetPVarInt(playerid, "pBoomBox"));
	    DestroyDynamic3DTextLabel(Text3D:GetPVarInt(playerid, "pBoomBoxLabel"));
	    DeletePVar(playerid, "pBoomBox"); DeletePVar(playerid, "pBoomBoxStation"); DeletePVar(playerid, "pBoomBoxLabel");
	    DeletePVar(playerid, "pBoomBoxX"); DeletePVar(playerid, "pBoomBoxY"); DeletePVar(playerid, "pBoomBoxZ");
	    if(GetPVarType(playerid, "pBoomBoxArea"))
	    {
	        new string[128];
			format(string, sizeof(string), "* %s da huy boombox.", GetPlayerNameEx(playerid));
	        foreach(new i: Player)
			{
				if(IsPlayerInDynamicArea(i, GetPVarInt(playerid, "pBoomBoxArea")))
				{
					StopAudioStreamForPlayerEx(i);
					SendClientMessage(i, COLOR_PURPLE, string);
				}
			}	
	        DeletePVar(playerid, "pBoomBoxArea");
		}
		SendClientMessage(playerid, COLOR_WHITE, "Ban da huy boombox!");
	}
	else
	{
	    foreach(new i: Player)
		{
			if(GetPVarType(i, "pBoomBox"))
			{
				if(GetPVarInt(i, "pBoomBoxVW") == GetPlayerVirtualWorld(playerid) && GetPVarInt(i, "pBoomBoxInt") == GetPlayerInterior(playerid) && IsPlayerInRangeOfPoint(playerid, 5.0, GetPVarFloat(i, "pBoomBoxX"), GetPVarFloat(i, "pBoomBoxY"), GetPVarFloat(i, "pBoomBoxZ")))
				{
					DestroyDynamicObject(GetPVarInt(i, "pBoomBox"));
					DestroyDynamic3DTextLabel(Text3D:GetPVarInt(i, "pBoomBoxLabel"));

					DeletePVar(i, "pBoomBox");
					DeletePVar(i, "pBoomBoxStation");
					DeletePVar(i, "pBoomBoxLabel");
					DeletePVar(i, "pBoomBoxX");
					DeletePVar(i, "pBoomBoxY");
					DeletePVar(i, "pBoomBoxZ");
					DeletePVar(i, "pBoomBoxInt");
					DeletePVar(i, "pBoomBoxVW");

					new string[128];
					if(GetPVarType(i, "pBoomBoxArea"))
					{
						format(string, sizeof(string), "* %s da huy boombox.", GetPlayerNameEx(playerid));
						foreach(new pi:Player)
						{
							if(IsPlayerInDynamicArea(pi, GetPVarInt(i, "pBoomBoxArea")))
							{
								StopAudioStreamForPlayerEx(pi);
								SendClientMessage(pi, COLOR_PURPLE, string);
							}
						}	
						DeletePVar(i, "pBoomBoxArea");
					}
					format(string, sizeof(string), "%s da huy boombox cua ban!", GetPlayerNameEx(playerid));
					SendClientMessage(i, COLOR_WHITE, string);
					return 1;
				}
			}
		}	
	    SendClientMessage(playerid, COLOR_WHITE, "Ban khong co boombox hoac khong o gan boombox de huy.");
	}
	return 1;
}