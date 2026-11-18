/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Arms Dealer Revision
								Winterfield

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

enum eArmsRecipe
{
	armsName[16],
	armsWeapon,
	armsMaterials,
	armsSkill,
	armsVIP,
	armsExperience
}

new const ArmsRecipes[][eArmsRecipe] = {
	{"flowers", 	WEAPON_FLOWER, 			100, 0, 0, 0},
	{"knuckles", 	WEAPON_BRASSKNUCKLE, 	100, 0, 0, 0},
	{"bat", 		WEAPON_BAT, 			100, 0, 0, 0},
	{"cane",	 	WEAPON_CANE, 			100, 0, 0, 0},
	{"shovel", 		WEAPON_SHOVEL, 			100, 0, 0, 0},
	{"club", 		WEAPON_GOLFCLUB, 		100, 0, 0, 0},
	{"pool", 		WEAPON_POOLSTICK, 		100, 0, 0, 0},
	{"katana", 		WEAPON_KATANA, 			100, 0, 0, 0},
	{"dildo", 		WEAPON_DILDO, 			100, 0, 0, 0},
	{"9mm", 		WEAPON_COLT45, 			500, 0, 0, 1},
	{"sdpistol", 	WEAPON_SILENCED, 		1000, 0, 0, 1},
	{"shotgun", 	WEAPON_SHOTGUN, 		4000, 50, 0, 1},
	{"mp5", 		WEAPON_MP5, 			2500, 200, 0, 1},
	{"rifle", 		WEAPON_RIFLE, 			3000, 200, 0, 1},
	{"tec9", 		WEAPON_TEC9, 			3000, 700, 0, 1},
	{"uzi", 		WEAPON_UZI, 			2500, 700, 0, 1},
	{"deagle", 		WEAPON_DEAGLE, 			5000, 1200, 0, 1},
	{"ak47", 		WEAPON_AK47, 			10000, 1200, 3, 1}
};

ArmsDealer_ClearOffer(playerid)
{
	DeletePVar(playerid, "pSellGun");
	DeletePVar(playerid, "pSellGunID");
	DeletePVar(playerid, "pSellGunSession");
	DeletePVar(playerid, "pSellGunMats");
	DeletePVar(playerid, "pSellGunXP");
	return 1;
}

ArmsDealer_CanTrade(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid}) return 0;
	#if defined zombiemode
	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return 0;
	#endif
	return GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !PlayerIsDead[playerid]
		&& !PlayerTied[playerid] && !PlayerCuffed[playerid] && PlayerInfo[playerid][pJailTime] <= 0 && !PlayerInfo[playerid][pHospital]
		&& !GetPVarInt(playerid, "Injured") && !GetPVarType(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged")
		&& !GetPVarType(playerid, "IsFrozen") && !GetPVarType(playerid, "WatchingTV") && !GetPVarType(playerid, "PreviewingTV")
		&& !GetPVarType(playerid, "AttemptingLockPick") && !GetPVarType(playerid, "IsInArena") && !GetPVarType(playerid, "EventToken")
		&& HungerPlayerInfo[playerid][hgInEvent] == 0 && !PlayerBoxing[playerid] && !GetPVarInt(playerid, "_BoxingFight");
}

ArmsDealer_Check(dealer, recipient, recipe, viewer)
{
	if(!ArmsDealer_CanTrade(dealer) || (recipient != dealer && !ArmsDealer_CanTrade(recipient)))
		return SendClientMessageEx(viewer, COLOR_GREY, "Both players must be available on foot to craft or receive a weapon."), 0;
	
	if(!Job_HasJob(dealer, JOB_ARMS_DEALER))
		return SendClientMessageEx(viewer, COLOR_GREY, "The seller is no longer an Arms Dealer."), 0;
	
	if(PlayerInfo[recipient][pConnectHours] < 2 || PlayerInfo[recipient][pWRestricted] > 0)
		return SendClientMessageEx(viewer, COLOR_GREY, "The recipient is currently weapon restricted."), 0;
	
	if(recipient != dealer)
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(dealer, x, y, z);
		if(GetPlayerVirtualWorld(dealer) != GetPlayerVirtualWorld(recipient) || GetPlayerInterior(dealer) != GetPlayerInterior(recipient)
			|| !IsPlayerInRangeOfPoint(recipient, 8.0, x, y, z))
			return SendClientMessageEx(viewer, COLOR_GREY, "You must be near each other in the same interior and world."), 0;
	}
	if(PlayerInfo[dealer][pArmsSkill] < ArmsRecipes[recipe][armsSkill])
		return SendClientMessageEx(viewer, COLOR_GREY, "The dealer does not have the required skill to craft this weapon."), 0;
	
	if(PlayerInfo[dealer][pDonateRank] < ArmsRecipes[recipe][armsVIP])
		return SendClientMessageEx(viewer, COLOR_GREY, "Gold VIP is required to craft this weapon."), 0;
	
	if(PlayerInfo[dealer][pMats] < ArmsRecipes[recipe][armsMaterials])
		return SendClientMessageEx(viewer, COLOR_GREY, "The dealer does not have enough materials to craft this weapon."), 0;
	
	return 1;
}

ArmsDealer_Complete(dealer, recipient, recipe)
{
	PlayerInfo[dealer][pMats] -= ArmsRecipes[recipe][armsMaterials];
	GivePlayerValidWeapon(recipient, ArmsRecipes[recipe][armsWeapon]);
	new gained = ArmsRecipes[recipe][armsExperience];
	if(dealer != recipient && PlayerInfo[dealer][pDoubleEXP] > 0) gained *= 2;
	if(PlayerInfo[dealer][pArmsSkill] > cellmax - gained) gained = cellmax - PlayerInfo[dealer][pArmsSkill];
	PlayerInfo[dealer][pArmsSkill] += gained;
	if(gained > 1) SendClientMessageEx(dealer, COLOR_YELLOW, "You gained %d arms dealer skill points with your Double EXP token. It has %d hours left.", gained, PlayerInfo[dealer][pDoubleEXP]);
	new weapon[32], message[144];
	GetWeaponName(ArmsRecipes[recipe][armsWeapon], weapon, sizeof(weapon));
	format(message, sizeof(message), "%s crafts a %s from their materials, handing it to %s.", GetPlayerNameEx(dealer), weapon, GetPlayerNameEx(recipient));
	ProxDetector(30.0, dealer, message, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
	PlayerPlaySound(dealer, 1052, 0.0, 0.0, 0.0);
	if(recipient != dealer) PlayerPlaySound(recipient, 1052, 0.0, 0.0, 0.0);
	return 1;
}

ArmsDealer_Accept(playerid)
{
	if(!GetPVarType(playerid, "pSellGunID")) return SendClientMessageEx(playerid, COLOR_GREY, "No one has offered you a weapon.");
	new dealer = GetPVarInt(playerid, "pSellGunID");
	if(!Offer_IsCurrent(playerid, dealer, "pSellGunSession"))
	{
		ArmsDealer_ClearOffer(playerid);
		return SendClientMessageEx(playerid, COLOR_GREY, "The weapon offer has expired.");
	}
	new weapon = GetPVarInt(playerid, "pSellGun"), recipe = -1;
	for(new i; i < sizeof(ArmsRecipes); ++i)
	{
		if(ArmsRecipes[i][armsWeapon] == weapon)
		{
			recipe = i;
			break;
		}
	}
	if(recipe == -1 || dealer == playerid)
	{
		ArmsDealer_ClearOffer(playerid);
		return SendClientMessageEx(playerid, COLOR_GREY, "This weapon offer is no longer valid.");
	}
	if(!ArmsDealer_Check(dealer, playerid, recipe, playerid)) return 1;
	ArmsDealer_ClearOffer(playerid);
	return ArmsDealer_Complete(dealer, playerid, recipe);
}

CMD:sellgun(playerid, params[])
{
	if(!Job_HasJob(playerid, JOB_ARMS_DEALER))
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not an Arms Dealer!");
	
	if(!ArmsDealer_CanTrade(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You cannot craft or offer weapons right now.");
	
	new now = gettime();
	if(GetPVarInt(playerid, "pSellGunTime") > now) return SendClientMessageEx(playerid, COLOR_GRAD1, "You must wait %d seconds before offering another weapon.", GetPVarInt(playerid, "pSellGunTime") - now);
	new target, name[16];
	if(sscanf(params, "us[16]", target, name))
	{
		new line[128], entry[48];
		SendClientMessageEx(playerid, COLOR_WHITE, "Available weapons and material costs:");
		for(new i; i < sizeof(ArmsRecipes); ++i)
		{
			if(PlayerInfo[playerid][pArmsSkill] < ArmsRecipes[i][armsSkill]) continue;
			format(entry, sizeof(entry), "%s(%d)%s", ArmsRecipes[i][armsName], ArmsRecipes[i][armsMaterials], ArmsRecipes[i][armsVIP] ? (" [Gold VIP]") : (""));
			if(strlen(line) + strlen(entry) + 2 >= sizeof(line))
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "%s", line);
				line[0] = EOS;
			}
			if(line[0]) strcat(line, "  ", sizeof(line));
			strcat(line, entry, sizeof(line));
		}
		if(line[0]) SendClientMessageEx(playerid, COLOR_WHITE, "%s", line);
		return SendClientMessageEx(playerid, COLOR_WHITE, "USAGE: /sellgun [playerid] [weapon]");
	}
	new recipe = -1;
	for(new i; i < sizeof(ArmsRecipes); ++i)
	{
		if(!strcmp(name, ArmsRecipes[i][armsName], true))
		{
			recipe = i;
			break;
		}
	}
	if(recipe == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid weapon name. Use /sellgun to see available recipes.");
	if(!ArmsDealer_Check(playerid, target, recipe, playerid)) return 1;
	if(target == playerid) ArmsDealer_Complete(playerid, playerid, recipe);
	else
	{
		ArmsDealer_ClearOffer(target);
		SetPVarInt(target, "pSellGun", ArmsRecipes[recipe][armsWeapon]);
		SetPVarInt(target, "pSellGunID", playerid);
		SetPVarInt(target, "pSellGunSession", g_arrQueryHandle[playerid]);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You offered %s a %s.", GetPlayerNameEx(target), ArmsRecipes[recipe][armsName]);
		SendClientMessageEx(target, COLOR_LIGHTBLUE, "%s offered to craft you a %s. Use /accept weapon to accept.", GetPlayerNameEx(playerid), ArmsRecipes[recipe][armsName]);
	}
	SetPVarInt(playerid, "pSellGunTime", now + 10);
	return 1;
}
