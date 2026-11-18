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
		SendClientMessageEx(playerid, COLOR_YELLOW, "You gained %d fishing skill points with Double EXP. You have %d hours left on the token.", gained, PlayerInfo[playerid][pDoubleEXP]);
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
	SendClientMessageEx(playerid, COLOR_WHITE, "You have reached your destination. Type /sellfish [amount] to sell your fish.");
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
	SendClientMessageEx(playerid, COLOR_WHITE, "FISH HELP: Fish from a boat in the normal world. Carry up to 1,000 lbs.");
	SendClientMessageEx(playerid, COLOR_GRAD3, "/fish, /myfish, /sellfish");
	return 1;
}

CMD:fish(playerid, params[])
{
	if(!Fishing_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot fish right now. You must be outside in the normal world.");
	
	if(!IsABoat(GetPlayerVehicleID(playerid))) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not in a boat!");
	
	new weight = PlayerInfo[playerid][pFishWeight], skill = PlayerInfo[playerid][pFishingSkill];
	if(weight < 0 || skill < 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Your fishing data is invalid. Please contact an administrator.");
	
	if(weight >= 1000) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You have reached your maximum weight. Type /sellfish to profit.");
	
	new now = gettime(), remaining = GetPVarInt(playerid, "pFishTime") - now;
	if(remaining > 0) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Wait %d seconds before casting again.", remaining);
	
	static const outcomesByLevel[] = {3, 5, 9, 12, sizeof(FishingCatches)};
	new outcomes = outcomesByLevel[Job_SkillLevel(JOB_SKILL_FISHING, skill) - 1];
	new caught = random(outcomes), message[128];
	
	SetPVarInt(playerid, "pFishTime", now + 10);
	IncreaseFishingLevel(playerid);
	format(message, sizeof(message), "{FF8000}* {C2A2DA}%s casts their rod out, reeling it back in.", GetPlayerNameEx(playerid));
	SetPlayerChatBubble(playerid, message, COLOR_PURPLE, 30.0, 4000);
	SendClientMessageEx(playerid, COLOR_PURPLE, "%s", message);
	if(caught == 0) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have caught nothing!");
	if(FishingCatches[caught][fishWeight] > 1000 - weight)
		return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "The %s was too heavy for your remaining capacity and was released.", FishingCatches[caught][fishName]);
	PlayerInfo[playerid][pFishWeight] += FishingCatches[caught][fishWeight];
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have caught a %s!", FishingCatches[caught][fishName]);
	return 1;
}

CMD:myfish(playerid, params[])
{
	return SendClientMessageEx(playerid, COLOR_YELLOW, "Fish: %d lbs.", PlayerInfo[playerid][pFishWeight]);
}

CMD:sellfish(playerid, params[])
{
	if(!Fishing_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot sell fish right now. You must be outside in the normal world.");
	
	new now = gettime(), remaining = GetPVarInt(playerid, "pFishSellTime") - now;
	if(remaining > 0) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Wait %d seconds before selling your fish again.", remaining);
	
	if(PlayerInfo[playerid][pFishWeight] < 50) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You must have at least 50 lbs of fish to sell.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 30.0, 2161.0513, -98.5897, 2.7893))
	{
		if(GetPVarType(playerid, "pSellingFish") && Fishing_HasSaleCheckpoint(playerid))
			return SendClientMessageEx(playerid, COLOR_YELLOW, "Follow your existing checkpoint to sell your fish.");
		
		Fishing_ClearSaleCheckpoint(playerid);
		if(CheckPointCheck(playerid) || IsPlayerCheckpointActive(playerid))
			return SendClientMessageEx(playerid, COLOR_GREY, "Finish or cancel your current checkpoint before locating the fish market.");
		
		SetPVarInt(playerid, "pSellingFish", 1);
		SetPlayerCheckpoint(playerid, 2161.0513, -98.5897, 2.7893, 10.0);
		GameTextForPlayer(playerid, "~g~CHECKPOINT ~r~SET", 5000, 4);
		return SendClientMessageEx(playerid, COLOR_YELLOW, "Make your way to the checkpoint to sell your fish.");
	}
	
	new amount;
	if(sscanf(params, "d", amount)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /sellfish [amount]");
	
	if(amount < 50) return SendClientMessageEx(playerid, COLOR_GREY, "Sell at least 50 lbs of fish at a time.");
	if(amount > PlayerInfo[playerid][pFishWeight]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You don't have that many pounds!");
	
	new bonus = Random(100, 200);
	if(amount > (cellmax - bonus) / 40) return SendClientMessageEx(playerid, COLOR_GREY, "That sale is too large. Sell fewer fish at a time.");
	
	new payment = amount * 40 + bonus;
	if(GetPlayerCash(playerid) > cellmax - payment) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot carry this fish sale payment.");
	PlayerInfo[playerid][pFishWeight] -= amount;
	GivePlayerCash(playerid, payment);
	SetPVarInt(playerid, "pFishSellTime", now + 120);
	Fishing_ClearSaleCheckpoint(playerid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "You have sold %d lbs for $%s.", amount, number_format(payment));
	return 1;
}
