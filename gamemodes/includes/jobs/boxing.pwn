/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Boxing System

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

/*CMD:setchamp(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /setchamp [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			new giveplayer[MAX_PLAYER_NAME];
			GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
			new nstring[MAX_PLAYER_NAME];
			format(nstring, sizeof(nstring), "%s", giveplayer);
			strmid(Titel[TitelName], nstring, 0, strlen(nstring), 255);
			Titel[TitelWins] = PlayerInfo[giveplayerid][pWins];
			Titel[TitelLoses] = PlayerInfo[giveplayerid][pLoses];
			Misc_Save();
			format(string, sizeof(string), "* You have made %s the new Boxing Champion.", giveplayer);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);

		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Invalid player specified.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
	}
	return 1;
}*/

stock Boxing_IsBoxer(playerid)
{
	return Job_HasJob(playerid, JOB_BOXER);
}

stock Boxing_GetGym(playerid, Float:range = 20.0)
{
	if(GetPlayerInterior(playerid) == 5 && IsPlayerInRangeOfPoint(playerid, range, 765.9343, 0.2761, 1000.7173)) return 5;
	if(GetPlayerInterior(playerid) == 7 && IsPlayerInRangeOfPoint(playerid, range, 768.48, -73.66, 1000.57)) return 7;
	return 0;
}

stock Boxing_CanFight(playerid)
{
	return 0 <= playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && gPlayerLogged{playerid}
		&& GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !PlayerIsDead[playerid]
		&& !GetPVarInt(playerid, "Injured") && !GetPVarInt(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged")
		&& !GetPVarInt(playerid, "IsFrozen") && !GetPVarInt(playerid, "IsTackled")
		&& !GetPVarInt(playerid, "_BoxingQueue") && !GetPVarInt(playerid, "_BoxingFight");
}

stock Boxing_FightHealth(playerid)
{
	if(!Boxing_IsBoxer(playerid)) return 30;
	return 30 + GetJobLevel(playerid, JOB_BOXER) * 10;
}

stock Boxing_IsCurrent(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || !PlayerBoxing[playerid]) return 0;
	if(playerid == Boxer1) return g_arrQueryHandle[playerid] == BoxerSession[0];
	if(playerid == Boxer2) return g_arrQueryHandle[playerid] == BoxerSession[1];
	return 0;
}

stock Boxing_Accept(playerid)
{
	new challenger = BoxOffer[playerid];
	if(!Offer_IsCurrent(playerid, challenger, "BoxOfferSession"))
	{
		BoxOffer[playerid] = INVALID_PLAYER_ID;
		DeletePVar(playerid, "BoxOfferSession");
		return SendClientMessageEx(playerid, COLOR_GREY, "This boxing offer is no longer valid.");
	}

	if(InRing || PlayerBoxing[playerid] || PlayerBoxing[challenger])
		return SendClientMessageEx(playerid, COLOR_GREY, "A boxing match is already in progress.");
	
	if(challenger == playerid || !Boxing_IsBoxer(challenger) || !Boxing_CanFight(playerid) || !Boxing_CanFight(challenger))
		return SendClientMessageEx(playerid, COLOR_GREY, "Both players must be available to fight.");
	
	new gym = Boxing_GetGym(playerid), Float:x, Float:y, Float:z;
	GetPlayerPos(challenger, x, y, z);
	if(!gym || Boxing_GetGym(challenger) != gym || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(challenger)
		|| !IsPlayerInRangeOfPoint(playerid, 8.0, x, y, z))
		return SendClientMessageEx(playerid, COLOR_GREY, "Both fighters must be near each other in the same gym.");

	Boxer1 = challenger;
	Boxer2 = playerid;
	BoxerSession[0] = g_arrQueryHandle[challenger];
	BoxerSession[1] = g_arrQueryHandle[playerid];
	BoxingInterior = gym;
	BoxingWorld = GetPlayerVirtualWorld(playerid);
	TBoxer = INVALID_PLAYER_ID;
	if(!strcmp(Titel[TitelName], GetPlayerNameEx(challenger), true)) TBoxer = challenger;
	else if(!strcmp(Titel[TitelName], GetPlayerNameEx(playerid), true)) TBoxer = playerid;
	BoxStartTime = gettime() + (TBoxer == INVALID_PLAYER_ID ? 20 : 60);
	RoundStarted = 0;
	InRing = 1;
	PlayerBoxing[challenger] = PlayerBoxing[playerid] = 1;
	BoxOffer[playerid] = INVALID_PLAYER_ID;
	DeletePVar(playerid, "BoxOfferSession");

	new fighters[2];
	fighters[0] = challenger;
	fighters[1] = playerid;
	for(new i; i < sizeof(fighters); ++i)
	{
		new fighter = fighters[i], health = Boxing_FightHealth(fighter);
		ResetPlayerWeapons(fighter);
		SetHealth(fighter, float(health));
		if(gym == 7) SetPlayerPos(fighter, i == 0 ? 764.35 : 768.94, i == 0 ? -66.48 : -70.87, 1001.56);
		else SetPlayerPos(fighter, i == 0 ? 758.7064 : 762.9852, i == 0 ? -1.8038 : 2.4439, 1001.5942);
		SetPlayerFacingAngle(fighter, i == 0 ? 313.1165 : 131.8632);
		TogglePlayerControllable(fighter, false);
		GameTextForPlayer(fighter, "~r~Waiting", 3000, 1);
		SendClientMessageEx(fighter, COLOR_LIGHTBLUE, "* The Boxing Challenge is accepted. You will fight with %d Health.", health);
	}
	if(TBoxer != INVALID_PLAYER_ID)
	{
		new message[128];
		format(message, sizeof(message), "Boxing News: Champion %s will fight %s in 60 seconds.", GetPlayerNameEx(TBoxer), GetPlayerNameEx(TBoxer == challenger ? playerid : challenger));
		ProxDetector(30.0, playerid, message, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE);
	}
	return 1;
}

stock Boxing_End(winner = INVALID_PLAYER_ID, leaving = INVALID_PLAYER_ID)
{
	if(!InRing) return 0;
	new fighters[2], current[2], champion = TBoxer;
	fighters[0] = Boxer1;
	fighters[1] = Boxer2;
	current[0] = Boxing_IsCurrent(Boxer1);
	current[1] = Boxing_IsCurrent(Boxer2);
	new bool:finished = RoundStarted && current[0] && current[1] && (winner == Boxer1 || winner == Boxer2);
	InRing = RoundStarted = BoxStartTime = 0;
	Boxer1 = Boxer2 = TBoxer = INVALID_PLAYER_ID;
	if(finished)
	{
		new loser = fighters[0] == winner ? fighters[1] : fighters[0];
		if(Boxing_IsBoxer(loser) && PlayerInfo[loser][pLoses] < cellmax) ++PlayerInfo[loser][pLoses];
		if(Boxing_IsBoxer(winner))
		{
			if(PlayerInfo[winner][pWins] < cellmax) ++PlayerInfo[winner][pWins];
			if(PlayerInfo[winner][pBoxSkill] < cellmax) ++PlayerInfo[winner][pBoxSkill];
		}
		if(champion != INVALID_PLAYER_ID)
		{
			new message[128];
			if(winner != champion && Boxing_IsBoxer(winner))
			{
				format(message, sizeof(message), "Boxing News: %s defeated champion %s and is the new Boxing Champion.", GetPlayerNameEx(winner), GetPlayerNameEx(champion));
				champion = winner;
			}
			else if(winner == champion)
				format(message, sizeof(message), "Boxing News: Champion %s won the fight against %s.", GetPlayerNameEx(winner), GetPlayerNameEx(loser));
			else SendClientMessageEx(winner, COLOR_LIGHTBLUE, "* You would have been the Champion if you had the Boxer Job!");
			if(message[0]) ProxDetector(30.0, winner, message, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE);
			format(Titel[TitelName], sizeof(Titel[TitelName]), "%s", GetPlayerNameEx(champion));
			Titel[TitelWins] = PlayerInfo[champion][pWins];
			Titel[TitelLoses] = PlayerInfo[champion][pLoses];
			Misc_Save();
		}
		SendClientMessageEx(winner, COLOR_LIGHTBLUE, "* You have won the fight against %s.", GetPlayerNameEx(loser));
		SendClientMessageEx(loser, COLOR_LIGHTBLUE, "* You have lost the fight against %s.", GetPlayerNameEx(winner));
	}
	for(new i; i < sizeof(fighters); ++i)
	{
		if(!current[i]) continue;
		new fighter = fighters[i];
		PlayerBoxing[fighter] = 0;
		if(fighter == leaving || PlayerIsDead[fighter] || GetPVarInt(fighter, "Injured")) continue;
		SetPlayerWeapons(fighter);
		if(GetPVarInt(fighter, "IsFrozen") || GetPVarInt(fighter, "PlayerCuffed") || GetPVarInt(fighter, "pBagged") || GetPVarInt(fighter, "IsTackled")) continue;
		TogglePlayerControllable(fighter, true);
		if(GetPlayerState(fighter) == PLAYER_STATE_ONFOOT && GetPlayerInterior(fighter) == BoxingInterior && GetPlayerVirtualWorld(fighter) == BoxingWorld)
		{
			if(BoxingInterior == 7) SetPlayerPos(fighter, 768.48, -73.66, 1000.57);
			else SetPlayerPos(fighter, 765.8433, 3.2924, 1000.7186);
			new Float:health;
			GetHealth(fighter, health);
			SetHealth(fighter, health < 20.0 ? 30.0 : 50.0);
		}
		GameTextForPlayer(fighter, finished ? ("~g~Match Over") : ("~r~Match interrupted"), 5000, 1);
	}
	return 1;
}

stock Boxing_Update()
{
	if(!InRing) return 1;
	if(!Boxing_IsCurrent(Boxer1) || !Boxing_IsCurrent(Boxer2)) return Boxing_End();
	new fighters[2], Float:health[2];
	fighters[0] = Boxer1;
	fighters[1] = Boxer2;
	for(new i; i < sizeof(fighters); ++i)
	{
		new fighter = fighters[i];
		if(!Boxing_CanFight(fighter) || Boxing_GetGym(fighter, 25.0) != BoxingInterior || GetPlayerVirtualWorld(fighter) != BoxingWorld)
			return Boxing_End();
		GetHealth(fighter, health[i]);
	}
	if(!RoundStarted)
	{
		if(health[0] < 12.0 || health[1] < 12.0) return Boxing_End();
		new remaining = BoxStartTime - gettime(), message[12];
		for(new i; i < sizeof(fighters); ++i)
		{
			if(remaining > 0)
			{
				format(message, sizeof(message), "%d", remaining);
				GameTextForPlayer(fighters[i], message, 1500, 6);
			}
			else
			{
				PlayerPlaySound(fighters[i], 1057, 0.0, 0.0, 0.0);
				GameTextForPlayer(fighters[i], "~g~Match Started", 5000, 1);
				TogglePlayerControllable(fighters[i], true);
			}
		}
		if(remaining > 0) return 1;
		BoxStartTime = 0;
		RoundStarted = 1;
	}
	if(health[0] < 12.0 && health[1] < 12.0) return Boxing_End();
	if(health[0] < 12.0) return Boxing_End(Boxer2);
	if(health[1] < 12.0) return Boxing_End(Boxer1);
	for(new i; i < sizeof(fighters); ++i)
	{
		if(health[i] >= 28.0) continue;
		new Float:angle;
		GetPlayerFacingAngle(fighters[i], angle);
		SetPlayerFacingAngle(fighters[i], angle + 85.0);
	}
	return 1;
}

stock Boxing_IsTrainingArea(playerid)
{
	return (GetPlayerInterior(playerid) == 5 && IsPlayerInRangeOfPoint(playerid, 3.0, 757.3734, 5.7227, 1000.7012))
		|| (GetPlayerInterior(playerid) == 7 && IsPlayerInRangeOfPoint(playerid, 3.0, 758.43, -78.0, 1000.65))
		|| (GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && IsPlayerInRangeOfPoint(playerid, 3.0, 2903.371826, -2254.517333, 7.244657));
}

stock Boxing_LearnStyle(playerid, listitem)
{
	if(!(0 <= listitem < 6)) return 1;
	if(!Boxing_CanFight(playerid) || PlayerBoxing[playerid] || !Boxing_IsTrainingArea(playerid))
		return SendClientMessageEx(playerid, COLOR_GREY, "You must be available at the learning area to change your fighting style.");
	
	new price = listitem == 5 ? 0 : (PlayerInfo[playerid][pDonateRank] >= 1 ? 40000 : 50000);
	if(price && GetPlayerCash(playerid) < price) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You do not have the cash for that!");
	
	static const styles[] = {FIGHT_STYLE_BOXING, FIGHT_STYLE_ELBOW, FIGHT_STYLE_KNEEHEAD, FIGHT_STYLE_KUNGFU, FIGHT_STYLE_GRABKICK, FIGHT_STYLE_NORMAL};
	static const names[][] = {"boxing", "elbow", "kneehead", "kungfu", "grabkick", "normal"};
	if(price) GivePlayerCash(playerid, -price);
	PlayerInfo[playerid][pFightStyle] = styles[listitem];
	SetPlayerFightingStyle(playerid, styles[listitem]);
	SendClientMessageEx(playerid, COLOR_WHITE, "You are now using the %s fighting style!", names[listitem]);
	if(price == 40000) SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: You paid $40000 instead of $50000 with your 20 percent discount.");
	return 1;
}

CMD:boxstats(playerid, params[])
{
	if(!Job_HasJob(playerid, JOB_BOXER))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "   You are not a Boxer!");
		return 1;
	}

	new ttext[20];//Title
	new clevel = PlayerInfo[playerid][pBoxSkill];
	if(clevel >= 0 && clevel <= 50) { ttext = "Beginner"; }
	else if(clevel >= 51 && clevel <= 200) { ttext = "Amateur"; }
	else if(clevel >= 201) { ttext = "Professional"; }
	new ntext[20];//NickName
	new level = PlayerInfo[playerid][pWins];
	if(level > 0 && PlayerInfo[playerid][pLoses] == 0)
	{
		ntext = "Undefeated";
	}
	else
	{
		if(level >= 0 && level <= 10) { ntext = "Newcomer"; }
		else if(level >= 11 && level <= 20) { ntext = "Touchy Fist"; }
		else if(level >= 21 && level <= 30) { ntext = "Nut Cracker"; }
		else if(level >= 31 && level <= 40) { ntext = "Tommygun"; }
		else if(level >= 41 && level <= 50) { ntext = "Skull Breaker"; }
		else if(level >= 51 && level <= 60) { ntext = "Light Speed"; }
		else if(level >= 61 && level <= 70) { ntext = "Unbroken Warrior"; }
		else if(level >= 71) { ntext = "Itallion Stallion"; }
	}
	SendClientMessageEx(playerid, COLOR_WHITE, "|__________________ Boxing Records __________________|");
	SendClientMessageEx(playerid, COLOR_GREY, "| Current Champion: %s, with [%d] Winnings and [%d] Losses.", Titel[TitelName],Titel[TitelWins],Titel[TitelLoses]);
	SendClientMessageEx(playerid, COLOR_GREY, "| Current Title: %s.", ttext);
	SendClientMessageEx(playerid, COLOR_GREY, "| Current NickName: %s.", ntext);
	SendClientMessageEx(playerid, COLOR_GREY, "| Total Wins: %d.", PlayerInfo[playerid][pWins]);
	SendClientMessageEx(playerid, COLOR_GREY, "| Total Losses: %d.", PlayerInfo[playerid][pLoses]);
	SendClientMessageEx(playerid, COLOR_WHITE, "|____________________________________________________|");
	return 1;
}

CMD:train(playerid, params[])
{
	if(!Boxing_CanFight(playerid) || PlayerBoxing[playerid] || !Boxing_IsTrainingArea(playerid))
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You must be available at the learning area inside a gym.");
	if(PlayerInfo[playerid][pDonateRank] >= 1)
		ShowPlayerDialogEx(playerid, FIGHTMENU, DIALOG_STYLE_LIST, "Fighting Moves", "Boxing\t\t$40000\nElbow\t\t$40000\nKneehead\t$40000\nKung-Fu\t$40000\nGrabKick\t$40000\nNormal", "Learn", "Cancel");
	else
		ShowPlayerDialogEx(playerid, FIGHTMENU, DIALOG_STYLE_LIST, "Fighting Moves", "Boxing\t\t$50000\nElbow\t\t$50000\nKneehead\t$50000\nKung-Fu\t$50000\nGrabKick\t$50000\nNormal", "Learn", "Cancel");
	return 1;
}

CMD:fight(playerid, params[])
{
	if(!Boxing_IsBoxer(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "You are not a Boxer!");
	if(InRing || PlayerBoxing[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "A boxing match is already in progress.");
	if(!Boxing_CanFight(playerid) || !Boxing_GetGym(playerid))
		return SendClientMessageEx(playerid, COLOR_GREY, "You must be available inside a boxing gym.");
	new target;
	if(sscanf(params, "u", target)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /fight [player]");
	if(!(0 <= target < MAX_PLAYERS) || !IsPlayerConnected(target))
		return SendClientMessageEx(playerid, COLOR_GREY, "Invalid player specified.");
	if(target == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot box with yourself!");
	if(!Boxing_CanFight(target) || PlayerBoxing[target])
		return SendClientMessageEx(playerid, COLOR_GREY, "That player is not available to fight.");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(target, x, y, z);
	if(Boxing_GetGym(target) != Boxing_GetGym(playerid) || GetPlayerVirtualWorld(target) != GetPlayerVirtualWorld(playerid)
		|| !IsPlayerInRangeOfPoint(playerid, 8.0, x, y, z))
		return SendClientMessageEx(playerid, COLOR_GREY, "That player must be near you in the same boxing gym.");
	BoxOffer[target] = playerid;
	SetPVarInt(target, "BoxOfferSession", g_arrQueryHandle[playerid]);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* You offered a Boxing Challenge to %s.", GetPlayerNameEx(target));
	SendClientMessageEx(target, COLOR_LIGHTBLUE, "* Boxer %s wants to fight with you. Use /accept boxing to accept.", GetPlayerNameEx(playerid));
	return 1;
}
