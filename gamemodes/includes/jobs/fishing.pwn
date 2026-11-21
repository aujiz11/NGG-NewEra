/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Fishing Job System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

	* Copyright (c) 2014, Next Generation Gaming, LLC
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

enum eFishingCatch
{
	fishName[16],
	fishWeight
}
new const FishingCatches[][eFishingCatch] = {
	{"nothing", 0},
	{"bluegill", 5},
	{"bass", 7},
	{"cod", 14},
	{"catfish", 17},
	{"pike", 24},
	{"zander", 30},
	{"mackerel", 35},
	{"molly", 40},
	{"swordfish", 70},
	{"tench", 71},
	{"seabass", 80},
	{"kraken", 200}
};

stock Fishing_CanAct(playerid)
{
	new PLAYER_STATE:playerState = GetPlayerState(playerid);
	return !PlayerIsDead[playerid] && !GetPVarInt(playerid, "Injured") && !PlayerInfo[playerid][pHospital]
		&& (playerState == PLAYER_STATE_ONFOOT || playerState == PLAYER_STATE_DRIVER || playerState == PLAYER_STATE_PASSENGER)
		&& GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0
		&& !GetPVarType(playerid, "WatchingTV") && !GetPVarType(playerid, "PreviewingTV")
		&& !GetPVarType(playerid, "IsInArena") && !GetPVarType(playerid, "EventToken")
		&& HungerPlayerInfo[playerid][hgInEvent] == 0;
}

stock Fishing_HasSaleCheckpoint(playerid)
{
	new Float:x, Float:y, Float:z, Float:radius;
	return GetPlayerCheckpoint(playerid, x, y, z, radius) && x == 2161.0513 && y == -98.5897 && z == 2.7893 && radius == 10.0;
}

stock Fishing_ClearSaleCheckpoint(playerid)
{
	if(!GetPVarType(playerid, "pSellingFish")) return 1;
	if(Fishing_HasSaleCheckpoint(playerid)) {
		DisablePlayerCheckpoint(playerid);
	}
	DeletePVar(playerid, "pSellingFish");
	return 1;
}

stock IncreaseFishingLevel(playerid)
{
	new gained = PlayerInfo[playerid][pDoubleEXP] > 0 ? 2 : 1;
	if(PlayerInfo[playerid][pFishingSkill] > cellmax - gained) 
	{
		gained = cellmax - PlayerInfo[playerid][pFishingSkill];
	}

	PlayerInfo[playerid][pFishingSkill] += gained;
	if(PlayerInfo[playerid][pDoubleEXP] > 0 && gained > 0) 
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban nhan %d diem fishing nho Double EXP. Token con %d gio.", gained, PlayerInfo[playerid][pDoubleEXP]);
	}
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(!GetPVarType(playerid, "pSellingFish")) return 1;
	if(!Fishing_HasSaleCheckpoint(playerid))
	{
		DeletePVar(playerid, "pSellingFish");
		return 1;
	}
	if(GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 10.0, 2161.0513, -98.5897, 2.7893)) 
	{
		return 1;
	}

	Fishing_ClearSaleCheckpoint(playerid);
	SendClientMessageEx(playerid, COLOR_WHITE, "Da den noi. Dung /sellfish [amount] de ban ca.");
	return ~1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	Fishing_ClearSaleCheckpoint(playerid);
	return 1;
}

CMD:fishhelp(playerid, params[])
{
	SetPVarInt(playerid, "HelpResultCat0", 5);
	Help_ListCat(playerid, DIALOG_HELPCATOTHER1);
	return 1;
}

CMD:ofishhelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________");
	SendClientMessageEx(playerid, COLOR_WHITE, "CAU CA: Cau tren thuyen o world thuong. Giu toi da 1,000 lbs.");
	SendClientMessageEx(playerid, COLOR_GRAD3, "/fish, /myfish, /sellfish");
	return 1;
}

CMD:fish(playerid, params[])
{
	if(!Fishing_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Chua the cau ca. Ban phai o ngoai troi, world thuong.");
	
	if(!IsABoat(GetPlayerVehicleID(playerid))) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o tren thuyen!");
	
	new weight = PlayerInfo[playerid][pFishWeight], skill = PlayerInfo[playerid][pFishingSkill];
	if(weight < 0 || skill < 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Du lieu fishing sai. Hay lien he Admin.");
	
	if(weight >= 1000) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Da dat trong luong toi da. Dung /sellfish de ban.");
	
	new now = gettime(), remaining = GetPVarInt(playerid, "pFishTime") - now;
	if(remaining > 0) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Cho %d giay de tha cau tiep.", remaining);
	
	static const outcomesByLevel[] = {3, 5, 9, 12, sizeof(FishingCatches)};
	new outcomes = outcomesByLevel[Job_SkillLevel(JOB_SKILL_FISHING, skill) - 1];
	new caught = random(outcomes), message[128];
	
	SetPVarInt(playerid, "pFishTime", now + 10);
	IncreaseFishingLevel(playerid);
	format(message, sizeof(message), "{FF8000}* {C2A2DA}%s tha can cau roi cuon day vao.", GetPlayerNameEx(playerid));
	SetPlayerChatBubble(playerid, message, COLOR_PURPLE, 30.0, 4000);
	SendClientMessageEx(playerid, COLOR_PURPLE, "%s", message);
	if(caught == 0) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban khong cau duoc gi!");
	if(FishingCatches[caught][fishWeight] > 1000 - weight)
		return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "%s qua nang so voi suc chua con lai, da tha di.", FishingCatches[caught][fishName]);
	PlayerInfo[playerid][pFishWeight] += FishingCatches[caught][fishWeight];
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da cau duoc %s!", FishingCatches[caught][fishName]);
	return 1;
}

CMD:myfish(playerid, params[])
{
	return SendClientMessageEx(playerid, COLOR_YELLOW, "Ca: %d lbs.", PlayerInfo[playerid][pFishWeight]);
}

CMD:sellfish(playerid, params[])
{
	if(!Fishing_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Chua the ban ca. Ban phai o ngoai troi, world thuong.");
	
	new now = gettime(), remaining = GetPVarInt(playerid, "pFishSellTime") - now;
	if(remaining > 0) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Cho %d giay de ban ca tiep.", remaining);
	
	if(PlayerInfo[playerid][pFishWeight] < 50) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Can it nhat 50 lbs ca de ban.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 30.0, 2161.0513, -98.5897, 2.7893))
	{
		if(GetPVarType(playerid, "pSellingFish") && Fishing_HasSaleCheckpoint(playerid))
			return SendClientMessageEx(playerid, COLOR_YELLOW, "Theo checkpoint hien tai de ban ca.");
		
		Fishing_ClearSaleCheckpoint(playerid);
		if(CheckPointCheck(playerid) || IsPlayerCheckpointActive(playerid))
			return SendClientMessageEx(playerid, COLOR_GREY, "Xong hoac huy checkpoint hien tai truoc khi tim cho ca.");
		
		SetPVarInt(playerid, "pSellingFish", 1);
		SetPlayerCheckpoint(playerid, 2161.0513, -98.5897, 2.7893, 10.0);
		GameTextForPlayer(playerid, "~g~CHECKPOINT ~r~DA DAT", 5000, 4);
		return SendClientMessageEx(playerid, COLOR_YELLOW, "Den checkpoint de ban ca.");
	}
	
	new amount;
	if(sscanf(params, "d", amount)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sellfish [amount]");
	
	if(amount < 50) return SendClientMessageEx(playerid, COLOR_GREY, "Ban it nhat 50 lbs ca moi lan.");
	if(amount > PlayerInfo[playerid][pFishWeight]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co du khoi luong do!");
	
	new bonus = Random(100, 200);
	if(amount > (cellmax - bonus) / 40) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich qua lon. Hay ban it ca hon moi lan.");
	
	new payment = amount * 40 + bonus;
	if(GetPlayerCash(playerid) > cellmax - payment) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the nhan so tien ban ca nay.");
	PlayerInfo[playerid][pFishWeight] -= amount;
	GivePlayerCash(playerid, payment);
	SetPVarInt(playerid, "pFishSellTime", now + 120);
	Fishing_ClearSaleCheckpoint(playerid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Ban %d lbs, nhan $%s.", amount, number_format(payment));
	return 1;
}
