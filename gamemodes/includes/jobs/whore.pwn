/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Whore System

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

CMD:sex(playerid, params[])
{
	if(Job_HasJob(playerid, JOB_PROSTITUTE))
	{
		if(!IsPlayerInAnyVehicle(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "   Chi duoc quan he trong xe!");
			return 1;
		}
		new Car = GetPlayerVehicleID(playerid);

		new giveplayerid, money;
		if(sscanf(params, "ud", giveplayerid, money)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sex [player] [price]");

		if(money < 1 || money > 10000) { SendClientMessageEx(playerid, COLOR_GREY, "   Gia phai tu $1 den $10,000!"); return 1; }
		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
					if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu quan he voi minh!"); return 1; }
					if(IsPlayerInAnyVehicle(playerid) && IsPlayerInVehicle(giveplayerid, Car))
					{
						if(gettime() >= PlayerInfo[playerid][pSexTime])
						{
							SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban moi %s quan he voi gia $%s.", GetPlayerNameEx(giveplayerid), number_format(money));
							SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* Whore %s moi ban quan he voi gia $%s (dung /accept sex) de dong y.", GetPlayerNameEx(playerid), number_format(money));
							SetPVarInt(playerid, "SexOfferTo", giveplayerid);
							SexOffer[giveplayerid] = playerid;
							SetPVarInt(giveplayerid, "SexOfferSession", g_arrQueryHandle[playerid]);
							SexPrice[giveplayerid] = money;
							PlayerInfo[playerid][pSexTime] = gettime()+60;
						}
						else
						{
							SendClientMessageEx(playerid, COLOR_GRAD2, " Ban da quan he, hay cho het thoi gian hoi!");
							return 1;
						}
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_GREY, "   Hai nguoi phai o trong cung xe!");
						return 1;
					}
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
					return 1;
				}
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong phai Whore!");
	}
	return 1;
}
