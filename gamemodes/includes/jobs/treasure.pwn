/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Treasure System

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

enum eTreasureItem
{
	treasureKey[16],
	treasureName[20],
	treasurePrice
}

new const TreasureItems[][eTreasureItem] = {
	{"junkmetal", "junk metal", 150},
	{"newcoin", "new coin", 50},
	{"oldcoin", "old coin", 100},
	{"brokenwatch", "broken watch", 5},
	{"oldkey", "old key", 20},
	{"goldwatch", "gold watch", 50000},
	{"silvernugget", "silver nugget", 25000},
	{"goldnugget", "gold nugget", 100000},
	{"treasure", "treasure chest", 1000000}
};

stock FoundTreasure(playerid)
{
	new skill = PlayerInfo[playerid][pTreasureSkill], message[128];
	if(Random(1, skill < 300 ? 101 : 126) > (skill < 150 ? 50 : 75))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You did not discover anything.");
		format(message, sizeof(message), "%s's metal detector seems to have malfunctioned.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, message, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
		return 1;
	}

	new roll = Random(1, 11), item;
	if(skill < 150) item = (roll - 1) / 2;
	else if(roll < (skill >= 600 ? 9 : 10))
	{
		switch(roll)
		{
			case 1, 2: item = 0;
			case 3, 4: item = 1;
			case 5, 6: item = 2;
			case 7: item = 3;
			case 8, 9: item = 4;
		}
	}
	else if(skill < 600) item = 5 + random(3);
	else
	{
		switch(Random(1, 101))
		{
			case 1..35: item = 5;
			case 36..65: item = 6;
			case 66..99: item = 7;
			case 100: item = 8;
		}
	}

	new count = GetPVarInt(playerid, TreasureItems[item][treasureKey]);
	if(count < 0 || count == cellmax) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot carry any more of this item.");
	SetPVarInt(playerid, TreasureItems[item][treasureKey], count + 1);
	SaveTreasureInventory(playerid);
	format(message, sizeof(message), "%s sweeps the ground with a metal detector and finds %s.", GetPlayerNameEx(playerid), TreasureItems[item][treasureName]);
	ProxDetector(30.0, playerid, message, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
	if(item == 8)
	{
		format(message, sizeof(message), "{AA3333}AdmWarning{FFFF00}: %s has just found hidden treasure ($1,000,000)", GetPlayerNameEx(playerid));
		ABroadCast(COLOR_YELLOW, message, 2);
	}
	return 1;
}

forward HideTreasureCheckpoint(playerid, session, target);
public HideTreasureCheckpoint(playerid, session, target)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || CheckPointCheck(playerid)) return 1;
	new Float:x, Float:y, Float:z, Float:radius;
	if(GetPlayerCheckpoint(playerid, x, y, z, radius) && x == HiddenTreasure[target][0]
		&& y == HiddenTreasure[target][1] && z == HiddenTreasure[target][2] && radius == 3.0)
		DisablePlayerCheckpoint(playerid);
	return 1;
}

CMD:search(playerid, params[])
{
	if(PlayerInfo[playerid][pJob] != 22 && PlayerInfo[playerid][pJob2] != 22 && PlayerInfo[playerid][pJob3] != 22)
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not a treasure hunter.");
	if(!GetPVarInt(playerid, "TreasureLoaded"))
		return SendClientMessageEx(playerid, COLOR_GREY, "Your treasure inventory is still loading. Please try again shortly.");
	if(PlayerInfo[playerid][pMetalDetector] <= 0)
		return SendClientMessageEx(playerid, COLOR_GREY, "You don't have a charged metal detector. You can receive one from a craftsman.");
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || PlayerIsDead[playerid] || GetPVarInt(playerid, "Injured")
		|| GetPVarInt(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged"))
		return SendClientMessageEx(playerid, COLOR_GREY, "You cannot use your metal detector right now.");
	if(GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0
		|| !IsPlayerInArea(playerid, 402.2964, 737.5547, -1923.9410, -1752.8732))
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not at a beach.");
	if(gettime() - GetPVarInt(playerid, "LastScan") < GetPVarInt(playerid, "ScanReload"))
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Your metal detector is still charging.");
	if(CheckPointCheck(playerid) || IsPlayerCheckpointActive(playerid))
		return SendClientMessageEx(playerid, COLOR_GREY, "Finish or cancel your current checkpoint before searching for treasure.");

	new target = GetPVarInt(playerid, "HiddenTreasure");
	if(!GetPVarType(playerid, "HiddenTreasure") || !(0 <= target < sizeof(HiddenTreasure)))
	{
		target = random(sizeof(HiddenTreasure));
		SetPVarInt(playerid, "HiddenTreasure", target);
	}
	new skill = PlayerInfo[playerid][pTreasureSkill];
	SetPVarInt(playerid, "ScanReload", skill < 25 ? 20 : (skill < 300 ? 15 : (skill < 600 ? 10 : 5)));
	SetPVarInt(playerid, "LastScan", gettime());
	--PlayerInfo[playerid][pMetalDetector];
	if(PlayerInfo[playerid][pMetalDetector] == 1)
		SendClientMessageEx(playerid, COLOR_WHITE, "INFO: You only have 1 metal detector charge left.");

	new Float:distance = GetPlayerDistanceFromPoint(playerid, HiddenTreasure[target][0], HiddenTreasure[target][1], HiddenTreasure[target][2]);
	if(distance > 3.0)
	{
		new message[128];
		SetPlayerCheckpoint(playerid, HiddenTreasure[target][0], HiddenTreasure[target][1], HiddenTreasure[target][2], 3.0);
		SetTimerEx("HideTreasureCheckpoint", 2000, false, "iii", playerid, g_arrQueryHandle[playerid], target);
		SendClientMessageEx(playerid, COLOR_WHITE, "You are %.1f meters away from the treasure.", distance);
		format(message, sizeof(message), "%s sweeps the ground with a metal detector.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, message, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
		return 1;
	}

	DeletePVar(playerid, "HiddenTreasure");
	FoundTreasure(playerid);
	if(skill < cellmax) ++PlayerInfo[playerid][pTreasureSkill];
	switch(PlayerInfo[playerid][pTreasureSkill])
	{
		case 25: SendClientMessageEx(playerid, COLOR_WHITE, "* Your Treasure Hunting Skill is now Level 2, your metal detector now charges in 15 seconds!");
		case 150: SendClientMessageEx(playerid, COLOR_WHITE, "* Your Treasure Hunting Skill is now Level 3, found items now have a 10% chance of being rare!");
		case 300: SendClientMessageEx(playerid, COLOR_WHITE, "* Your Treasure Hunting Skill is now Level 4, your metal detector now charges in 10 seconds!");
		case 600: SendClientMessageEx(playerid, COLOR_WHITE, "* Your Treasure Hunting Skill is now Level 5, found items now have a 20% chance of being rare!");
	}
	return 1;
}

CMD:selltreasure(playerid, params[])
{
	new choice[32], amount;
	if(sscanf(params, "s[32]d", choice, amount))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /selltreasure [name] [amount]");
		SendClientMessageEx(playerid, COLOR_GREY, "Available names: junkmetal ($150), newcoin ($50), oldcoin ($100), brokenwatch ($5), oldkey ($20), goldwatch ($50000)");
		SendClientMessageEx(playerid, COLOR_GREY, "Available names: goldnugget ($100000), silvernugget ($25000), treasurechest ($1000000)");
		return 1;
	}
	if(!GetPVarInt(playerid, "TreasureLoaded"))
		return SendClientMessageEx(playerid, COLOR_GREY, "Your treasure inventory is still loading. Please try again shortly.");
	if(GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 3.0, 164.9517, -1779.5931, 4.3000))
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not at a treasure sell point.");
	if(amount <= 0) return SendClientMessageEx(playerid, COLOR_GREY, "Enter a positive amount to sell.");

	new item = -1;
	for(new i; i < sizeof(TreasureItems); ++i)
	{
		if(i == 8)
		{
			if(strcmp(choice, "treasurechest", true)) continue;
		}
		else if(strcmp(choice, TreasureItems[i][treasureKey], true)) continue;
		item = i;
		break;
	}
	if(item == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Unknown treasure item. Use /selltreasure to see the available names.");
	new count = GetPVarInt(playerid, TreasureItems[item][treasureKey]), price = TreasureItems[item][treasurePrice];
	if(amount > count) return SendClientMessageEx(playerid, COLOR_GREY, "You don't have enough of that item to sell.");
	if(amount > cellmax / price) return SendClientMessageEx(playerid, COLOR_GREY, "That sale is too large. Sell fewer items at a time.");
	new payment = amount * price;
	if(GetPlayerCash(playerid) > cellmax - payment) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot carry that much cash.");

	SetPVarInt(playerid, TreasureItems[item][treasureKey], count - amount);
	GivePlayerCash(playerid, payment);
	SaveTreasureInventory(playerid);
	SendClientMessageEx(playerid, COLOR_WHITE, "You have sold %d x %s for $%d.", amount, TreasureItems[item][treasureName], payment);
	return 1;
}