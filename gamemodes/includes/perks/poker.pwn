/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Poker System

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

hook OnPlayerDisconnect(playerid, reason) {
	if(GetPVarType(playerid, "pkrTableID")) LeavePokerTable(playerid, true);
}

PokerCanAct(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
	new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot");
	if(tableid < 0 || tableid >= MAX_POKERTABLES || slot < 0 || slot >= 6) return 0;
	return PokerTable[tableid][pkrSlot][slot] == playerid && PokerTable[tableid][pkrRound] == 1
		&& PokerTable[tableid][pkrActive] == 3 && PokerTable[tableid][pkrActivePlayerID] == playerid
		&& GetPVarInt(playerid, "pkrActiveHand") && GetPVarInt(playerid, "pkrChips") > 0;
}

PokerOptions(playerid, option)
{
	switch(option)
	{
		case 0:
		{
			DeletePVar(playerid, "pkrActionOptions");
			PlayerTextDrawHide(playerid, PlayerPokerUI[playerid][38]);
			PlayerTextDrawHide(playerid, PlayerPokerUI[playerid][39]);
			PlayerTextDrawHide(playerid, PlayerPokerUI[playerid][40]);
		}
		case 1: // if(CurrentBet >= ActiveBet)
		{
			SetPVarInt(playerid, "pkrActionOptions", 1);
			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][38], "RAISE");
			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][39], "CHECK");
			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][40], "FOLD");

			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][38]);
			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][39]);
			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][40]);
		}
		case 2: // if(CurrentBet < ActiveBet)
		{
			SetPVarInt(playerid, "pkrActionOptions", 2);
			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][38], "CALL");
			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][39], "RAISE");
			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][40], "FOLD");

			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][38]);
			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][39]);
			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][40]);
		}
		case 3: // if(pkrChips < 1)
		{
			SetPVarInt(playerid, "pkrActionOptions", 3);

			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][38], "CHECK");
			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][39], "FOLD");

			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][38]);
			PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][39]);
		}
	}
}

PokerCallHand(playerid)
{
	if(!PokerCanAct(playerid)) return 0;
	return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESCALLPOKER);
}

PokerRaiseHand(playerid)
{
	if(!PokerCanAct(playerid)) return 0;
	return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESRAISEPOKER);
}

PokerCheckHand(playerid)
{
	if(!PokerCanAct(playerid)) return 0;
	new tableid = GetPVarInt(playerid, "pkrTableID")-1;
	if(GetPVarInt(playerid, "pkrCurrentBet") < PokerTable[tableid][pkrActiveBet]) return 0;
	PokerTable[tableid][pkrActedBet][GetPVarInt(playerid, "pkrSlot")] = PokerTable[tableid][pkrActiveBet];
	SetPVarString(playerid, "pkrStatusString", "Check");
	ApplyAnimation(playerid, "CASINO", "cards_raise", 4.1, false, true, true, true, 1, 1);
	return 1;
}

PokerFoldHand(playerid)
{
	new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot");
	if(tableid < 0 || tableid >= MAX_POKERTABLES || slot < 0 || slot >= 6) return 0;
	if(PokerTable[tableid][pkrSlot][slot] != playerid || !GetPVarInt(playerid, "pkrActiveHand")) return 0;
	DeletePVar(playerid, "pkrCard1");
	DeletePVar(playerid, "pkrCard2");
	DeletePVar(playerid, "pkrActiveHand");
	DeletePVar(playerid, "pkrStatus");
	PokerTable[tableid][pkrActiveHands]--;
	SetPVarString(playerid, "pkrStatusString", "Fold");
	GlobalPlaySound(5602, PokerTable[tableid][pkrX], PokerTable[tableid][pkrY], PokerTable[tableid][pkrZ]);
	ApplyAnimation(playerid, "CASINO", "cards_out", 4.1, false, true, true, true, 1, 1);
	return 1;
}

PokerDealHands(tableid)
{
	new tmp = 0;

	// Loop through active players.
	for(new i = 0; i < 6; i++) {
		new playerid = PokerTable[tableid][pkrSlot][i];

		if(playerid != -1) {

			if(GetPVarInt(playerid, "pkrStatus")) {
				SetPVarInt(playerid, "pkrCard1", PokerTable[tableid][pkrDeck][tmp]);
				SetPVarInt(playerid, "pkrCard2", PokerTable[tableid][pkrDeck][tmp+1]);

				SetPVarInt(playerid, "pkrActiveHand", 1);

				PokerTable[tableid][pkrActiveHands]++;

				// SFX
				PlayerPlaySound(playerid, 5602, 0.0, 0.0, 0.0);

				// Animation
				ApplyAnimation(playerid, "CASINO", "cards_in", 4.1, false, true, true, true, 1, 1);

				tmp += 2;
			}
		}
	}

	// Loop through community cards.
	for(new i = 0; i < 5; i++) {

		PokerTable[tableid][pkrCCards][i] = PokerTable[tableid][pkrDeck][tmp];
		tmp++;
	}
}

PokerShuffleDeck(tableid)
{
	// SFX
	GlobalPlaySound(5600, PokerTable[tableid][pkrX], PokerTable[tableid][pkrY], PokerTable[tableid][pkrZ]);

	// Order the deck
	for(new i = 0; i < 52; i++) {
		PokerTable[tableid][pkrDeck][i] = i;
	}

	// Randomize the array (AKA Shuffle Algorithm)
	new rand, tmp, i;
	for(i = 52; i > 1; i--) {
		rand = random(52) % i;
		tmp = PokerTable[tableid][pkrDeck][rand];
		PokerTable[tableid][pkrDeck][rand] = PokerTable[tableid][pkrDeck][i-1];
		PokerTable[tableid][pkrDeck][i-1] = tmp;
	}
}

PokerFindPlayerOrder(tableid, index)
{
	if(tableid < 0 || tableid >= MAX_POKERTABLES || index < 0 || index >= 6) return -1;
	new playerid = PokerTable[tableid][pkrSlot][index];
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return -1;
	if(GetPVarInt(playerid, "pkrTableID") != tableid+1 || GetPVarInt(playerid, "pkrSlot") != index) return -1;
	return playerid;
}

PokerAssignBlinds(tableid)
{
	new seats[6], count;
	for(new i; i < 6; ++i) {
		new slot = (PokerTable[tableid][pkrPos]+i)%6, playerid = PokerFindPlayerOrder(tableid, slot);
		if(playerid != -1 && GetPVarInt(playerid, "pkrChips") > 0) seats[count++] = slot;
	}
	if(count < 2 || PokerTable[tableid][pkrBlind] < 2) return 0;
	new dealer = seats[0], small = count == 2 ? seats[0] : seats[1], big = count == 2 ? seats[1] : seats[2];
	if(count == 2 && big == PokerTable[tableid][pkrBigBlindSlot]) {
		dealer = small = seats[1];
		big = seats[0];
	}
	PokerTable[tableid][pkrDealerSlot] = dealer;
	PokerTable[tableid][pkrBigBlindSlot] = big;
	PokerTable[tableid][pkrPos] = (dealer+1)%6;
	PokerTable[tableid][pkrActivePlayerID] = -1;
	PokerTable[tableid][pkrActivePlayerSlot] = big;
	PokerTable[tableid][pkrActiveBet] = PokerTable[tableid][pkrBlind];
	PokerTable[tableid][pkrMinRaise] = PokerTable[tableid][pkrBlind];
	PokerTable[tableid][pkrActiveHands] = 0;
	for(new i; i < 6; ++i) {
		PokerTable[tableid][pkrCommitted][i] = 0;
		PokerTable[tableid][pkrActedBet][i] = -1;
		PokerTable[tableid][pkrPayout][i] = 0;
		new playerid = PokerFindPlayerOrder(tableid, i);
		if(playerid == -1) continue;
		DeletePVar(playerid, "pkrStatus");
		DeletePVar(playerid, "pkrWinner");
		DeletePVar(playerid, "pkrCurrentBet");
		DeletePVar(playerid, "pkrRoomDealer");
		DeletePVar(playerid, "pkrRoomSmallBlind");
		DeletePVar(playerid, "pkrRoomBigBlind");
		SetPVarString(playerid, "pkrStatusString", " ");
		if(GetPVarInt(playerid, "pkrChips") <= 0) continue;
		SetPVarInt(playerid, "pkrStatus", 1);
		if(i == dealer) SetPVarInt(playerid, "pkrRoomDealer", 1);
		if(i != small && i != big) continue;
		new blind = i == big ? PokerTable[tableid][pkrBlind] : PokerTable[tableid][pkrBlind]/2;
		new paid = min(blind, GetPVarInt(playerid, "pkrChips")), status[32];
		SetPVarInt(playerid, i == big ? "pkrRoomBigBlind" : "pkrRoomSmallBlind", 1);
		SetPVarInt(playerid, "pkrChips", GetPVarInt(playerid, "pkrChips")-paid);
		SetPVarInt(playerid, "pkrCurrentBet", paid);
		PokerTable[tableid][pkrCommitted][i] = paid;
		PokerTable[tableid][pkrPot] += paid;
		format(status, sizeof(status), "%s -$%d", i == big ? "BB" : "SB", paid);
		SetPVarString(playerid, "pkrStatusString", status);
	}
	return 1;
}

PokerSettlePot(tableid)
{
	if(PokerTable[tableid][pkrPot] <= 0) return 1;
	new live, survivor = -1, scores[6], levels[6], previous, lastEligible;
	for(new i; i < 6; ++i) {
		levels[i] = PokerTable[tableid][pkrCommitted][i];
		new playerid = PokerFindPlayerOrder(tableid, i);
		if(playerid == -1 || !GetPVarInt(playerid, "pkrActiveHand")) continue;
		live++;
		lastEligible |= 1<<i;
		survivor = i;
		new cards[7];
		cards[0] = GetPVarInt(playerid, "pkrCard1");
		cards[1] = GetPVarInt(playerid, "pkrCard2");
		for(new c; c < 5; ++c) cards[c+2] = PokerTable[tableid][pkrCCards][c];
		scores[i] = AnaylzePokerHand(playerid, cards);
	}
	if(!live) return 0;
	if(live == 1) {
		PokerTable[tableid][pkrPayout][survivor] += PokerTable[tableid][pkrPot];
		PokerTable[tableid][pkrPot] = 0;
	}
	else for(new tier; tier < 6; ++tier) {
		new level;
		for(new i; i < 6; ++i) if(levels[i] > previous && (!level || levels[i] < level)) level = levels[i];
		if(!level) break;
		new amount, eligible;
		for(new i; i < 6; ++i) {
			amount += max(0, min(levels[i], level)-previous);
			new playerid = PokerFindPlayerOrder(tableid, i);
			if(levels[i] >= level && playerid != -1 && GetPVarInt(playerid, "pkrActiveHand")) eligible |= 1<<i;
		}
		if(!eligible) eligible = lastEligible;
		else lastEligible = eligible;
		new best = -1, winners, count;
		for(new i; i < 6; ++i) if(eligible & (1<<i)) {
			if(scores[i] > best) { best = scores[i]; winners = 1<<i; count = 1; }
			else if(scores[i] == best) { winners |= 1<<i; count++; }
		}
		if(!count) return 0;
		new share = amount/count, remainder = amount%count;
		for(new n = 1; n <= 6; ++n) {
			new i = (PokerTable[tableid][pkrDealerSlot]+n)%6;
			if(!(winners & (1<<i))) continue;
			PokerTable[tableid][pkrPayout][i] += share + (remainder > 0 ? 1 : 0);
			if(remainder > 0) remainder--;
		}
		PokerTable[tableid][pkrPot] -= amount;
		previous = level;
	}
	PokerTable[tableid][pkrWinners] = 0;
	PokerTable[tableid][pkrWinnerID] = -1;
	for(new i; i < 6; ++i) {
		new playerid = PokerFindPlayerOrder(tableid, i);
		if(playerid == -1 || !PokerTable[tableid][pkrPayout][i]) continue;
		SetPVarInt(playerid, "pkrChips", GetPVarInt(playerid, "pkrChips")+PokerTable[tableid][pkrPayout][i]);
		SetPVarInt(playerid, "pkrWinner", 1);
		PokerTable[tableid][pkrWinners]++;
		PokerTable[tableid][pkrWinnerID] = playerid;
	}
	return 1;
}

PokerRotateActivePlayer(tableid)
{
	if(tableid < 0 || tableid >= MAX_POKERTABLES || !PokerTable[tableid][pkrRound] || PokerTable[tableid][pkrActive] != 3) return 0;
	new last = PokerTable[tableid][pkrActivePlayerID];
	if(last != -1 && IsPlayerConnected(last)) {
		DeletePVar(last, "pkrActivePlayer");
		DeletePVar(last, "pkrTime");
		DeletePVar(last, "pkrActionChoice");
		PokerOptions(last, 0);
	}
	PokerTable[tableid][pkrActivePlayerID] = -1;
	for(new street; street < 4; ++street) {
		new live, actors, pending;
		for(new i; i < 6; ++i) {
			new playerid = PokerFindPlayerOrder(tableid, i);
			if(playerid == -1 || !GetPVarInt(playerid, "pkrActiveHand")) continue;
			live++;
			if(GetPVarInt(playerid, "pkrChips") > 0) {
				actors++;
				if(PokerTable[tableid][pkrActedBet][i] < 0 || GetPVarInt(playerid, "pkrCurrentBet") < PokerTable[tableid][pkrActiveBet]) pending++;
			}
		}
		if(live <= 1) {
			PokerSettlePot(tableid);
			PokerTable[tableid][pkrActive] = 4;
			PokerTable[tableid][pkrDelay] = 21;
			return 1;
		}
		if(actors == 1) {
			PokerTable[tableid][pkrActiveBet] = 0;
			for(new i; i < 6; ++i) {
				new playerid = PokerFindPlayerOrder(tableid, i);
				if(playerid != -1 && GetPVarInt(playerid, "pkrActiveHand")) PokerTable[tableid][pkrActiveBet] = max(PokerTable[tableid][pkrActiveBet], GetPVarInt(playerid, "pkrCurrentBet"));
			}
			pending = 0;
			for(new i; i < 6; ++i) {
				new playerid = PokerFindPlayerOrder(tableid, i);
				if(playerid != -1 && GetPVarInt(playerid, "pkrActiveHand") && GetPVarInt(playerid, "pkrChips") > 0
					&& GetPVarInt(playerid, "pkrCurrentBet") < PokerTable[tableid][pkrActiveBet]) pending++;
			}
		}
		if(pending > 0) {
			for(new n = 1; n <= 6; ++n) {
				new slot = (PokerTable[tableid][pkrActivePlayerSlot]+n)%6, playerid = PokerFindPlayerOrder(tableid, slot);
				if(playerid == -1 || !GetPVarInt(playerid, "pkrActiveHand") || GetPVarInt(playerid, "pkrChips") <= 0) continue;
				if(PokerTable[tableid][pkrActedBet][slot] >= 0 && GetPVarInt(playerid, "pkrCurrentBet") >= PokerTable[tableid][pkrActiveBet]) continue;
				PokerTable[tableid][pkrActivePlayerID] = playerid;
				PokerTable[tableid][pkrActivePlayerSlot] = slot;
				SetPVarInt(playerid, "pkrActivePlayer", 1);
				SetPVarInt(playerid, "pkrTime", 60);
				new sounds[] = {5809, 5810};
				PlayerPlaySound(playerid, sounds[random(sizeof(sounds))], 0.0, 0.0, 0.0);
				PokerOptions(playerid, GetPVarInt(playerid, "pkrCurrentBet") >= PokerTable[tableid][pkrActiveBet] ? 1 : 2);
				return 1;
			}
		}
		if(PokerTable[tableid][pkrStage] >= 3 || actors <= 1) {
			PokerTable[tableid][pkrStage] = 3;
			PokerTable[tableid][pkrActive] = 4;
			PokerTable[tableid][pkrDelay] = 21;
			return 1;
		}
		PokerTable[tableid][pkrStage]++;
		PokerTable[tableid][pkrActiveBet] = 0;
		PokerTable[tableid][pkrMinRaise] = PokerTable[tableid][pkrBlind];
		PokerTable[tableid][pkrActivePlayerSlot] = PokerTable[tableid][pkrDealerSlot];
		for(new i; i < 6; ++i) {
			PokerTable[tableid][pkrActedBet][i] = -1;
			new playerid = PokerFindPlayerOrder(tableid, i);
			if(playerid != -1) SetPVarInt(playerid, "pkrCurrentBet", 0);
		}
	}
	return 1;
}

InitPokerTables()
{
	for(new i = 0; i < MAX_POKERTABLES; i++) {
		PokerTable[i][pkrActive] = 0;
		PokerTable[i][pkrPlaced] = 0;
		PokerTable[i][pkrObjectID] = 0;

		for(new c = 0; c < MAX_POKERTABLEMISCOBJS; c++) {
			PokerTable[i][pkrMiscObjectID][c] = 0;
		}

		for(new s = 0; s < 6; s++) {
			PokerTable[i][pkrSlot][s] = -1;
			PokerTable[i][pkrCommitted][s] = 0;
			PokerTable[i][pkrActedBet][s] = -1;
			PokerTable[i][pkrPayout][s] = 0;
		}

		PokerTable[i][pkrX] = 0.0;
		PokerTable[i][pkrY] = 0.0;
		PokerTable[i][pkrZ] = 0.0;
		PokerTable[i][pkrRX] = 0.0;
		PokerTable[i][pkrRY] = 0.0;
		PokerTable[i][pkrRZ] = 0.0;
		PokerTable[i][pkrVW] = 0;
		PokerTable[i][pkrInt] = 0;
		PokerTable[i][pkrPlayers] = 0;
		PokerTable[i][pkrLimit] = 6;
		PokerTable[i][pkrBuyInMax] = 1000;
		PokerTable[i][pkrBuyInMin] = 500;
		PokerTable[i][pkrBlind] = 100;
		PokerTable[i][pkrPos] = 0;
		PokerTable[i][pkrDealerSlot] = -1;
		PokerTable[i][pkrBigBlindSlot] = -1;
		PokerTable[i][pkrRound] = 0;
		PokerTable[i][pkrStage] = 0;
		PokerTable[i][pkrActiveBet] = 0;
		PokerTable[i][pkrSetDelay] = 15;
		PokerTable[i][pkrActivePlayerID] = -1;
		PokerTable[i][pkrActivePlayerSlot] = -1;
		PokerTable[i][pkrRotations] = 0;
		PokerTable[i][pkrSlotRotations] = 0;
		PokerTable[i][pkrWinnerID] = -1;
		PokerTable[i][pkrWinners] = 0;
	}
}

ResetPokerRound(tableid)
{
	PokerTable[tableid][pkrRound] = 0;
	PokerTable[tableid][pkrStage] = 0;
	PokerTable[tableid][pkrActiveBet] = 0;
	PokerTable[tableid][pkrActive] = 2;
	PokerTable[tableid][pkrDelay] = PokerTable[tableid][pkrSetDelay];
	PokerTable[tableid][pkrPot] = 0;
	PokerTable[tableid][pkrRotations] = 0;
	PokerTable[tableid][pkrSlotRotations] = 0;
	PokerTable[tableid][pkrActivePlayerID] = -1;
	PokerTable[tableid][pkrActivePlayerSlot] = -1;
	PokerTable[tableid][pkrActiveHands] = 0;
	PokerTable[tableid][pkrActivePlayers] = 0;
	PokerTable[tableid][pkrWinnerID] = -1;
	PokerTable[tableid][pkrWinners] = 0;

	// Reset Player Variables
	for(new i = 0; i < 6; i++) {
		PokerTable[tableid][pkrCommitted][i] = 0;
		PokerTable[tableid][pkrActedBet][i] = -1;
		PokerTable[tableid][pkrPayout][i] = 0;
		new playerid = PokerTable[tableid][pkrSlot][i];

		if(playerid != -1) {
			DeletePVar(playerid, "pkrWinner");
			DeletePVar(playerid, "pkrRoomBigBlind");
			DeletePVar(playerid, "pkrRoomSmallBlind");
			DeletePVar(playerid, "pkrRoomDealer");
			DeletePVar(playerid, "pkrCard1");
			DeletePVar(playerid, "pkrCard2");
			DeletePVar(playerid, "pkrActivePlayer");
			DeletePVar(playerid, "pkrTime");

			if(GetPVarInt(playerid, "pkrActiveHand")) {

				// Animation
				ApplyAnimation(playerid, "CASINO", "cards_out", 4.1, false, true, true, true, 1, 1);
			}

			DeletePVar(playerid, "pkrActionChoice");
			PokerOptions(playerid, 0);
			SetPVarInt(playerid, "pkrStatus", GetPVarInt(playerid, "pkrChips") > 0);
			if(GetPVarInt(playerid, "pkrChips") > 0) PokerTable[tableid][pkrActivePlayers]++;
			DeletePVar(playerid, "pkrActiveHand");
			DeletePVar(playerid, "pkrCurrentBet");
			DeletePVar(playerid, "pkrResultString");
			DeletePVar(playerid, "pkrHide");
		}
	}

	return 1;
}

ResetPokerTable(tableid)
{
	new szString[32];
	format(szString, sizeof(szString), "");
	strmid(PokerTable[tableid][pkrPass], szString, 0, strlen(szString), 64);

	PokerTable[tableid][pkrActive] = 0;
	PokerTable[tableid][pkrPlayers] = 0;
	PokerTable[tableid][pkrLimit] = 6;
	PokerTable[tableid][pkrBuyInMax] = 1000;
	PokerTable[tableid][pkrBuyInMin] = 500;
	PokerTable[tableid][pkrBlind] = 100;
	PokerTable[tableid][pkrPos] = 0;
	PokerTable[tableid][pkrDealerSlot] = -1;
	PokerTable[tableid][pkrBigBlindSlot] = -1;
	PokerTable[tableid][pkrActivePlayerID] = -1;
	PokerTable[tableid][pkrActivePlayerSlot] = -1;
	PokerTable[tableid][pkrActiveHands] = 0;
	PokerTable[tableid][pkrActivePlayers] = 0;
	for(new i; i < 6; ++i) {
		PokerTable[tableid][pkrSlot][i] = -1;
		PokerTable[tableid][pkrCommitted][i] = 0;
		PokerTable[tableid][pkrActedBet][i] = -1;
		PokerTable[tableid][pkrPayout][i] = 0;
	}
	PokerTable[tableid][pkrRound] = 0;
	PokerTable[tableid][pkrStage] = 0;
	PokerTable[tableid][pkrActiveBet] = 0;
	PokerTable[tableid][pkrDelay] = 0;
	PokerTable[tableid][pkrPot] = 0;
	PokerTable[tableid][pkrSetDelay] = 15;
	PokerTable[tableid][pkrRotations] = 0;
	PokerTable[tableid][pkrSlotRotations] = 0;
	PokerTable[tableid][pkrWinnerID] = -1;
	PokerTable[tableid][pkrWinners] = 0;
}

ShowPokerGUI(playerid, guitype)
{
	switch(guitype)
	{
		case GUI_POKER_TABLE:
		{
			SetPVarInt(playerid, "pkrTableGUI", 1);
			for(new i = 0; i < MAX_PLAYERPOKERUI; i++) {
				PlayerTextDrawShow(playerid, PlayerPokerUI[playerid][i]);
			}
		}
	}
}

DestroyPokerGUI(playerid)
{
	for(new i = 0; i < MAX_PLAYERPOKERUI; i++) {
		PlayerTextDrawDestroy(playerid, PlayerPokerUI[playerid][i]);
	}
}

PlacePokerTable(tableid, skipmisc, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, virtualworld, interior)
{
	PokerTable[tableid][pkrPlaced] = 1;
	PokerTable[tableid][pkrX] = x;
	PokerTable[tableid][pkrY] = y;
	PokerTable[tableid][pkrZ] = z;
	PokerTable[tableid][pkrRX] = rx;
	PokerTable[tableid][pkrRY] = ry;
	PokerTable[tableid][pkrRZ] = rz;
	PokerTable[tableid][pkrVW] = virtualworld;
	PokerTable[tableid][pkrInt] = interior;

	// Create Table
	PokerTable[tableid][pkrObjectID] = CreateDynamicObject(OBJ_POKER_TABLE, x, y, z, rx, ry, rz, virtualworld, interior, -1, DRAWDISTANCE_POKER_TABLE);

	if(skipmisc != 0) {
	}

	// Create 3D Text Label
	new szString[64];
	format(szString, sizeof(szString), "Ban Poker %d", tableid);
	PokerTable[tableid][pkrText3DID] = Create3DTextLabel(szString, COLOR_YELLOW, x, y, z+1.3, DRAWDISTANCE_POKER_MISC, virtualworld, false);

	return tableid;
}

DestroyPokerTable(tableid)
{
	if(tableid < 0 || tableid >= MAX_POKERTABLES) return -1;
	if(PokerTable[tableid][pkrPot] > 0) PokerSettlePot(tableid);
	if(PokerTable[tableid][pkrRound]) PokerTable[tableid][pkrActive] = 4;
	for(new slot; slot < 6; ++slot) {
		new playerid = PokerFindPlayerOrder(tableid, slot);
		if(playerid == -1) continue;
		LeavePokerTable(playerid);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Chu ban Poker da huy ban.");
	}
	if(PokerTable[tableid][pkrPlaced] == 1) {
		// Delete Table
		if(IsValidDynamicObject(PokerTable[tableid][pkrObjectID])) DestroyDynamicObject(PokerTable[tableid][pkrObjectID]);

		// Delete 3D Text Label
		Delete3DTextLabel(PokerTable[tableid][pkrText3DID]);

		// Delete Misc Obj
		for(new c = 0; c < MAX_POKERTABLEMISCOBJS; c++) {
			if(IsValidObject(PokerTable[tableid][pkrMiscObjectID][c])) DestroyObject(PokerTable[tableid][pkrMiscObjectID][c]);
		}
	}
	PokerTable[tableid][pkrX] = 0.0;
	PokerTable[tableid][pkrY] = 0.0;
	PokerTable[tableid][pkrZ] = 0.0;
	PokerTable[tableid][pkrRX] = 0.0;
	PokerTable[tableid][pkrRY] = 0.0;
	PokerTable[tableid][pkrRZ] = 0.0;
	PokerTable[tableid][pkrVW] = 0;
	PokerTable[tableid][pkrInt] = 0;
	PokerTable[tableid][pkrPlayers] = 0;
	PokerTable[tableid][pkrLimit] = 6;
	PokerTable[tableid][pkrPlaced] = 0;
	KillTimer(PokerTable[tableid][pkrPulseTimer]);
	PokerTable[tableid][pkrPulseTimer] = 0;
	ResetPokerTable(tableid);
	return tableid;
}

// Note: 0, 1 should be the hand, the rest are community cards.
AnaylzePokerHand(playerid, const Hand[])
{
	new ranks[15], suits[4], suitRanks[4], rankMask;
	for(new i; i < 7; ++i) {
		if(Hand[i] < 0 || Hand[i] >= 52) return 0;
		new rank = Hand[i]%13, suit = Hand[i]/13;
		rank = rank == 0 ? 14 : rank+1;
		ranks[rank]++;
		suits[suit]++;
		rankMask |= 1<<rank;
		suitRanks[suit] |= 1<<rank;
	}

	new flushSuit = -1, straight, straightFlush, four, three, pair, secondPair;
	for(new suit; suit < 4; ++suit) if(suits[suit] >= 5) flushSuit = suit;
	if(ranks[14]) rankMask |= 1<<1;
	if(flushSuit != -1 && (suitRanks[flushSuit] & (1<<14))) suitRanks[flushSuit] |= 1<<1;
	for(new rank = 14; rank >= 2; --rank) {
		if(rank >= 5) {
			new sequence = 31<<(rank-4);
			if(!straight && (rankMask & sequence) == sequence) straight = rank;
			if(flushSuit != -1 && !straightFlush && (suitRanks[flushSuit] & sequence) == sequence) straightFlush = rank;
		}
		switch(ranks[rank]) {
			case 4: four = rank;
			case 3: {
				if(!three) three = rank;
				else if(!pair) pair = rank;
			}
			case 2: {
				if(!pair) pair = rank;
				else if(!secondPair) secondPair = rank;
			}
		}
	}

	new category, tie[5], used, needed = 5, exclude, exclude2;
	if(straightFlush) {
		category = 8;
		tie[0] = straightFlush;
		used = needed = 1;
	}
	else if(four) {
		category = 7;
		tie[0] = exclude = four;
		used = 1;
		needed = 2;
	}
	else if(three && pair) {
		category = 6;
		tie[0] = three;
		tie[1] = pair;
		used = needed = 2;
	}
	else if(flushSuit != -1) {
		category = 5;
	}
	else if(straight) {
		category = 4;
		tie[0] = straight;
		used = needed = 1;
	}
	else if(three) {
		category = 3;
		tie[0] = exclude = three;
		used = 1;
		needed = 3;
	}
	else if(secondPair) {
		category = 2;
		tie[0] = exclude = pair;
		tie[1] = exclude2 = secondPair;
		used = 2;
		needed = 3;
	}
	else if(pair) {
		category = 1;
		tie[0] = exclude = pair;
		used = 1;
		needed = 4;
	}
	for(new rank = 14; rank >= 2 && used < needed; --rank) {
		if(!ranks[rank] || rank == exclude || rank == exclude2) continue;
		if(category == 5 && !(suitRanks[flushSuit] & (1<<rank))) continue;
		tie[used++] = rank;
	}

	new score = category;
	for(new i; i < 5; ++i) score = (score<<4) | tie[i];
	static const names[][] = {
		"High Card", "Pair", "Two Pair", "Three of a Kind", "Straight",
		"Flush", "Full House", "Four of a Kind", "Straight Flush"
	};
	if(straightFlush == 14) SetPVarString(playerid, "pkrResultString", "Royal Flush");
	else SetPVarString(playerid, "pkrResultString", names[category]);
	return score;
}

forward PokerExit(playerid, session);
public PokerExit(playerid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || GetPVarType(playerid, "pkrTableID")) return 1;
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	ClearAnimationsEx(playerid);
	CancelSelectTextDraw(playerid);
	return 1;
}

forward PokerPulse(tableid);
public PokerPulse(tableid)
{
	if(tableid < 0 || tableid >= MAX_POKERTABLES) return 0;
	// Idle Animation Loop & Re-seater
	for(new i = 0; i < 6; i++) {
		new playerid = PokerTable[tableid][pkrSlot][i];

		if(playerid != -1) {
			// Disable Weapons
			SetPlayerArmedWeapon(playerid,0);

			new idleRandom = random(100);
			if(idleRandom >= 90) {
			    SetPlayerPosObjectOffset(PokerTable[tableid][pkrObjectID], playerid, PokerTableMiscObjOffsets[i][0], PokerTableMiscObjOffsets[i][1], PokerTableMiscObjOffsets[i][2]);
				SetPlayerFacingAngle(playerid, PokerTableMiscObjOffsets[i][5]+90.0);
				SetPlayerInterior(playerid, PokerTable[tableid][pkrInt]);
				SetPlayerVirtualWorld(playerid, PokerTable[tableid][pkrVW]);

				// Animation
				if(GetPVarInt(playerid, "pkrActiveHand")) {
					ApplyAnimation(playerid, "CASINO", "cards_loop", 4.1, false, true, true, true, 1, 1);
				}
			}
		}
	}

	// 3D Text Label
	Update3DTextLabelText(PokerTable[tableid][pkrText3DID], COLOR_YELLOW, " ");

	if(PokerTable[tableid][pkrActive] == 2) {
		new count;
		for(new i; i < 6; ++i) {
			new playerid = PokerFindPlayerOrder(tableid, i);
			if(playerid != -1 && GetPVarInt(playerid, "pkrChips") > 0) count++;
		}
		PokerTable[tableid][pkrActivePlayers] = count;
		if(count >= 2) {
			PokerTable[tableid][pkrActive] = 3;
			PokerTable[tableid][pkrDelay] = PokerTable[tableid][pkrSetDelay];
		}
	}
	if(PokerTable[tableid][pkrActive] == 4) {
		if(PokerTable[tableid][pkrDelay] > 0) PokerTable[tableid][pkrDelay]--;
		if(PokerTable[tableid][pkrDelay] == 19) PokerSettlePot(tableid);
		if(PokerTable[tableid][pkrDelay] == 0) return ResetPokerRound(tableid);
	}
	if(PokerTable[tableid][pkrActive] == 3) {
		if(!PokerTable[tableid][pkrRound]) {
			if(PokerTable[tableid][pkrDelay] > 0) PokerTable[tableid][pkrDelay]--;
			if(PokerTable[tableid][pkrDelay] == 0) {
				if(!PokerAssignBlinds(tableid)) return ResetPokerRound(tableid);
				PokerTable[tableid][pkrRound] = 1;
				PokerShuffleDeck(tableid);
				PokerDealHands(tableid);
				PokerRotateActivePlayer(tableid);
			}
		}
		else {
			new playerid = PokerTable[tableid][pkrActivePlayerID];
			if(playerid != -1 && PokerCanAct(playerid)) {
				SetPVarInt(playerid, "pkrTime", GetPVarInt(playerid, "pkrTime")-1);
				if(GetPVarInt(playerid, "pkrTime") <= 0) {
					if(GetPVarType(playerid, "pkrActionChoice")) ShowPlayerDialogEx(playerid, -1, DIALOG_STYLE_MSGBOX, "Close", "Close", "Close", "Close");
					PokerFoldHand(playerid);
					PokerRotateActivePlayer(tableid);
				}
			}
		}
	}

	// Update GUI
	for(new i = 0; i < 6; i++) {
		new playerid = PokerTable[tableid][pkrSlot][i];
		new tmp, tmpString[128];
		// Set Textdraw Offset
		switch(i)
		{
			case 0: { tmp = 0; }
			case 1: { tmp = 5; }
			case 2: { tmp = 10; }
			case 3: { tmp = 15; }
			case 4: { tmp = 20; }
			case 5: { tmp = 25; }
		}

		if(playerid != -1) {
			new cardTexture[15];
			// Debug
		/*	new string[512];
			format(string, sizeof(string), "Debug:~n~pkrActive: %d~n~pkrPlayers: %d~n~pkrActivePlayers: %d~n~pkrActiveHands: %d~n~pkrPos: %d~n~pkrDelay: %d~n~pkrRound: %d~n~pkrStage: %d~n~pkrActiveBet: %d~n~pkrRotations: %d",
				PokerTable[tableid][pkrActive],
				PokerTable[tableid][pkrPlayers],
				PokerTable[tableid][pkrActivePlayers],
				PokerTable[tableid][pkrActiveHands],
				PokerTable[tableid][pkrPos],
				PokerTable[tableid][pkrDelay],
				PokerTable[tableid][pkrRound],
				PokerTable[tableid][pkrStage],
				PokerTable[tableid][pkrActiveBet],
				PokerTable[tableid][pkrRotations]
			);
			format(string, sizeof(string), "%s~n~----------~n~", string);

			new sstring[128];
			GetPVarString(playerid, "pkrStatusString", sstring, 128);
			format(string, sizeof(string), "%spkrTableID: %d~n~pkrCurrentBet: %d~n~pkrStatus: %d~n~pkrRoomLeader: %d~n~pkrRoomBigBlind: %d~n~pkrRoomSmallBlind: %d~n~pkrRoomDealer: %d~n~pkrActivePlayer: %d~n~pkrActiveHand: %d~n~pkrStatusString: %s",
				string,
				GetPVarInt(playerid, "pkrTableID")-1,
				GetPVarInt(playerid, "pkrCurrentBet"),
				GetPVarInt(playerid, "pkrStatus"),
				GetPVarInt(playerid, "pkrRoomLeader"),
				GetPVarInt(playerid, "pkrRoomBigBlind"),
				GetPVarInt(playerid, "pkrRoomSmallBlind"),
				GetPVarInt(playerid, "pkrRoomDealer"),
				GetPVarInt(playerid, "pkrActivePlayer"),
				GetPVarInt(playerid, "pkrActiveHand"),
				sstring
			);

			PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][45], string); */

			// Name
			new name[MAX_PLAYER_NAME+1];
			GetPlayerName(playerid, name, sizeof(name));
			for(new td = 0; td < 6; td++) {
				new pid = PokerTable[tableid][pkrSlot][td];

				if(pid != -1) PlayerTextDrawSetString(pid, PlayerPokerUI[pid][0+tmp], name);
			}

			// Chips
			if(GetPVarInt(playerid, "pkrChips") > 0) {
				format(tmpString, sizeof(tmpString), "$%d", GetPVarInt(playerid, "pkrChips"));
			} else {
				format(tmpString, sizeof(tmpString), "~r~$%d", GetPVarInt(playerid, "pkrChips"));
			}
			for(new td = 0; td < 6; td++) {
				new pid = PokerTable[tableid][pkrSlot][td];
				if(pid != -1) PlayerTextDrawSetString(pid, PlayerPokerUI[pid][1+tmp], tmpString);
			}

			// Cards
			for(new td = 0; td < 6; td++) {
				new pid = PokerTable[tableid][pkrSlot][td];
				if(pid != -1) {
					if(GetPVarInt(playerid, "pkrActiveHand")) {
						if(playerid != pid) {
							if(PokerTable[tableid][pkrActive] == 4 && PokerTable[tableid][pkrDelay] <= 19 && GetPVarInt(playerid, "pkrHide") != 1) {
								strunpack(tmpString, DeckTextdrw[GetPVarInt(playerid, "pkrCard1")+1], sizeof(tmpString));
								PlayerTextDrawSetString(pid, PlayerPokerUI[pid][2+tmp], tmpString);
								strunpack(tmpString, DeckTextdrw[GetPVarInt(playerid, "pkrCard2")+1], sizeof(tmpString));
								PlayerTextDrawSetString(pid, PlayerPokerUI[pid][3+tmp], tmpString);
							} else {
								strunpack(cardTexture, DeckTextdrw[0], sizeof(cardTexture));
								PlayerTextDrawSetString(pid, PlayerPokerUI[pid][2+tmp], cardTexture);
								PlayerTextDrawSetString(pid, PlayerPokerUI[pid][3+tmp], cardTexture);
							}
						} else {
							strunpack(tmpString, DeckTextdrw[GetPVarInt(playerid, "pkrCard1")+1], sizeof(tmpString));
							PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][2+tmp], tmpString);

							strunpack(tmpString, DeckTextdrw[GetPVarInt(playerid, "pkrCard2")+1], sizeof(tmpString));
							PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][3+tmp], tmpString);
						}
					} else {
						PlayerTextDrawSetString(pid, PlayerPokerUI[pid][2+tmp], " ");
						PlayerTextDrawSetString(pid, PlayerPokerUI[pid][3+tmp], " ");
					}
				}
			}

			// Status
			if(PokerTable[tableid][pkrActive] < 3) {
				format(tmpString, sizeof(tmpString), " ");
			} else if(GetPVarInt(playerid, "pkrActivePlayer") && PokerTable[tableid][pkrActive] == 3) {
				format(tmpString, sizeof(tmpString), "0:%d", GetPVarInt(playerid, "pkrTime"));
			} else {
				if(PokerTable[tableid][pkrActive] == 3 && PokerTable[tableid][pkrDelay] > 5) {
					SetPVarString(playerid, "pkrStatusString", " ");
				}

				if(PokerTable[tableid][pkrActive] == 4 && PokerTable[tableid][pkrDelay] <= 19) {
					if(PokerTable[tableid][pkrPayout][i] > 0) format(tmpString, sizeof(tmpString), "+$%d", PokerTable[tableid][pkrPayout][i]);
					else format(tmpString, sizeof(tmpString), "-$%d", PokerTable[tableid][pkrCommitted][i]);
					SetPVarString(playerid, "pkrStatusString", tmpString);
				}

				GetPVarString(playerid, "pkrStatusString", tmpString, 128);
			}

			for(new td = 0; td < 6; td++) {
				new pid = PokerTable[tableid][pkrSlot][td];
				if(pid != -1) PlayerTextDrawSetString(pid, PlayerPokerUI[pid][4+tmp], tmpString);
			}

			// Pot
			if(PokerTable[tableid][pkrDelay] > 0 && PokerTable[tableid][pkrActive] == 3) {
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][37], "Texas Holdem Poker");
			} else if(PokerTable[tableid][pkrActive] == 2) {
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][37], "Texas Holdem Poker");
			} else if(PokerTable[tableid][pkrActive] == 3) {
				format(tmpString, sizeof(tmpString), "Pot: $%d", PokerTable[tableid][pkrPot]);
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][37], tmpString);
			} else if(PokerTable[tableid][pkrActive] == 4 && PokerTable[tableid][pkrDelay] <= 19) {
				new paid;
				for(new slot; slot < 6; ++slot) paid += PokerTable[tableid][pkrPayout][slot];
				format(tmpString, sizeof(tmpString), "Het van: Da tra $%d", paid);
				PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][37], tmpString);
			} else {
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][37], "Texas Holdem Poker");
			}
			// Bet
			if(PokerTable[tableid][pkrDelay] > 0 && PokerTable[tableid][pkrActive] == 3) {
				format(tmpString, sizeof(tmpString), "Van moi sau ~r~%d~w~...", PokerTable[tableid][pkrDelay]);
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][46], tmpString);
			} else if(PokerTable[tableid][pkrActive] == 2) {
				format(tmpString, sizeof(tmpString), "Dang cho nguoi choi...", PokerTable[tableid][pkrPot]);
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][46], tmpString);
			} else if(PokerTable[tableid][pkrActive] == 3) {
				format(tmpString, sizeof(tmpString), "Cuoc: $%d", PokerTable[tableid][pkrActiveBet]);
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][46], tmpString);
			} else if(PokerTable[tableid][pkrActive] == 4) {
				PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][46], "Het van");
			} else {
				if(playerid != -1) PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][46], "Texas Holdem Poker");
			}
			// Community Cards
			switch(PokerTable[tableid][pkrStage]) {
				case 0: // Opening
				{
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][31], "LD_CARD:cdback");
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][32], "LD_CARD:cdback");
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][33], "LD_CARD:cdback");
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][34], "LD_CARD:cdback");
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][35], "LD_CARD:cdback");
				}
				case 1: // Flop
				{
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][0]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][31], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][1]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][32], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][2]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][33], cardTexture);
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][34], "LD_CARD:cdback");
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][35], "LD_CARD:cdback");
				}
				case 2: // Turn
				{
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][0]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][31], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][1]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][32], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][2]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][33], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][3]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][34], cardTexture);
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][35], "LD_CARD:cdback");
				}
				case 3: // River
				{
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][0]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][31], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][1]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][32], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][2]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][33], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][3]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][34], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][4]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][35], cardTexture);
				}
				case 4: // Win
				{
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][0]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][31], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][1]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][32], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][2]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][33], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][3]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][34], cardTexture);
					strunpack(cardTexture, DeckTextdrw[PokerTable[tableid][pkrCCards][4]+1], sizeof(cardTexture));
					PlayerTextDrawSetString(playerid, PlayerPokerUI[playerid][35], cardTexture);
				}
			}
		} else {
			for(new td = 0; td < 6; td++) {
				new pid = PokerTable[tableid][pkrSlot][td];

				if(pid != -1) {
					PlayerTextDrawSetString(pid, PlayerPokerUI[pid][0+tmp], " ");
					PlayerTextDrawSetString(pid, PlayerPokerUI[pid][1+tmp], " ");
					PlayerTextDrawSetString(pid, PlayerPokerUI[pid][2+tmp], " ");
					PlayerTextDrawSetString(pid, PlayerPokerUI[pid][3+tmp], " ");
					PlayerTextDrawSetString(pid, PlayerPokerUI[pid][4+tmp], " ");
				}
			}
		}
	}
	return 1;
}

ShowCasinoGamesMenu(playerid, dialogid)
{
	switch(dialogid)
	{
		case DIALOG_CGAMESCALLPOKER: {
			if(!PokerCanAct(playerid)) return 0;

			if(GetPVarInt(playerid, "pkrChips") > 0) {
				SetPVarInt(playerid, "pkrActionChoice", 1);

				new tableid = GetPVarInt(playerid, "pkrTableID")-1;
				new actualBet = PokerTable[tableid][pkrActiveBet]-GetPVarInt(playerid, "pkrCurrentBet");

				if(actualBet > GetPVarInt(playerid, "pkrChips")) {
					format(szMiscArray, sizeof(szMiscArray), "{FFFFFF}Ban chac muon Call $%s (All-In)?:", number_format(GetPVarInt(playerid, "pkrChips")));
					return ShowPlayerDialogEx(playerid, DIALOG_CGAMESCALLPOKER, DIALOG_STYLE_MSGBOX, "{FFFFFF}Texas Holdem Poker - (Call)", szMiscArray, "All-In", "Huy");
				}
				format(szMiscArray, sizeof(szMiscArray), "{FFFFFF}Ban chac muon Call $%s?:", number_format(actualBet));
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESCALLPOKER, DIALOG_STYLE_MSGBOX, "{FFFFFF}Texas Holdem Poker - (Call)", szMiscArray, "Goi", "Huy");
			} else {
				SendClientMessage(playerid, COLOR_WHITE, "DEALER: Ban khong du tien de Call.");
				new noFundsSoundID[] = {5823, 5824, 5825};
				new randomNoFundsSoundID = random(sizeof(noFundsSoundID));
				PlayerPlaySound(playerid, noFundsSoundID[randomNoFundsSoundID], 0.0, 0.0, 0.0);
			}
		}
		case DIALOG_CGAMESRAISEPOKER: {
			if(!PokerCanAct(playerid)) return 0;
			new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot");
			new acted = PokerTable[tableid][pkrActedBet][slot], active = PokerTable[tableid][pkrActiveBet];
			if(acted >= 0 && active-acted < PokerTable[tableid][pkrMinRaise] && !(acted == 0 && active > 0)) return SendClientMessageEx(playerid, COLOR_GREY, "All-in nho nay chua mo lai quyen Raise cho ban.");
			new maximum = GetPVarInt(playerid, "pkrCurrentBet")+GetPVarInt(playerid, "pkrChips");
			if(maximum <= active) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du chips de Raise.");
			new minimum = active > maximum-PokerTable[tableid][pkrMinRaise] ? maximum : active+PokerTable[tableid][pkrMinRaise];
			SetPVarInt(playerid, "pkrActionChoice", 1);
			format(szMiscArray, sizeof(szMiscArray), "{FFFFFF}Ban muon Raise bao nhieu? ($%d-$%d):", minimum, maximum);
			return ShowPlayerDialogEx(playerid, DIALOG_CGAMESRAISEPOKER, DIALOG_STYLE_INPUT, "{FFFFFF}Texas Holdem Poker - (Raise)", szMiscArray, "Raise", "Huy");
		}
		case DIALOG_CGAMESBUYINPOKER: {

			format(szMiscArray, sizeof(szMiscArray), "{FFFFFF}Nhap so tien Buy-In cho ban:\n\nCasino Chips: {00FF00}$%d{FFFFFF}\nPoker Chips: {00FF00}$%d{FFFFFF}\nBuy-In Toi da/Toi thieu: {00FF00}$%d{FFFFFF}/{00FF00}$%d{FFFFFF}", GetPlayerCash(playerid), GetPVarInt(playerid, "pkrChips"), PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrBuyInMax], PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrBuyInMin]);
			return ShowPlayerDialogEx(playerid, DIALOG_CGAMESBUYINPOKER, DIALOG_STYLE_INPUT, "{FFFFFF}Casino Games - (Menu BuyIn)", szMiscArray, "Buy In", "Roi di");
		}
		case DIALOG_CGAMESADMINMENU: {

			return ShowPlayerDialogEx(playerid, DIALOG_CGAMESADMINMENU, DIALOG_STYLE_LIST, "{FFFFFF}Casino Games - (Menu Admin)", "{FFFFFF}Thiet lap Poker Minigame...\nDong2\nTac gia", "Chon", "Dong");
		}
		case DIALOG_CGAMESSELECTPOKER: {

			szMiscArray[0] = 0;
			new szPlaced[64];

			for(new i = 0; i < MAX_POKERTABLES; i++) {
				if(PokerTable[i][pkrPlaced] == 1) { format(szPlaced, sizeof(szPlaced), "{00FF00}Bat{FFFFFF}"); }
				if(PokerTable[i][pkrPlaced] == 0) { format(szPlaced, sizeof(szPlaced), "{FF0000}Tat{FFFFFF}"); }
				format(szMiscArray, sizeof(szMiscArray), "%sBan Poker %d (%s)\n", szMiscArray, i, szPlaced, PokerTable[i][pkrPlayers]);
			}
			return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSELECTPOKER, DIALOG_STYLE_LIST, "Casino Games - (Chon ban Poker)", szMiscArray, "Chon", "Quay lai");
		}
		case DIALOG_CGAMESSETUPPOKER: {

			new tableid = GetPVarInt(playerid, "tmpEditPokerTableID")-1;

			if(PokerTable[tableid][pkrPlaced] == 0) {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPOKER, DIALOG_STYLE_LIST, "{FFFFFF}Casino Games - (Thiet lap Poker Minigame)", "{FFFFFF}Dat ban...", "Chon", "Quay lai");
			} else {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPOKER, DIALOG_STYLE_LIST, "{FFFFFF}Casino Games - (Thiet lap Poker Minigame)", "{FFFFFF}Sua ban...\nXoa ban...", "Chon", "Quay lai");
			}
		}
		case DIALOG_CGAMESCREDITS: {

			return ShowPlayerDialogEx(playerid, DIALOG_CGAMESCREDITS, DIALOG_STYLE_MSGBOX, "{FFFFFF}Casino Games - (Tac gia)", "{FFFFFF}Phat trien boi: Dan 'GhoulSlayeR' Reed", "Quay lai", "");
		}
		case DIALOG_CGAMESSETUPPGAME: {

			new tableid = GetPVarInt(playerid, "pkrTableID")-1;

			if(GetPVarType(playerid, "pkrTableID")) {
				new szString[512];

				if(PokerTable[tableid][pkrPass][0] == EOS) {
					format(szString, sizeof(szString), "{FFFFFF}Buy-In Max\t({00FF00}$%d{FFFFFF})\nBuy-In Min\t({00FF00}$%d{FFFFFF})\nBlind\t\t({00FF00}$%d{FFFFFF} / {00FF00}$%d{FFFFFF})\nGioi han\t\t(%d)\nMat khau\t(%s)\nCho giua van\t(%d)\nBat dau",
						PokerTable[tableid][pkrBuyInMax],
						PokerTable[tableid][pkrBuyInMin],
						PokerTable[tableid][pkrBlind],
						PokerTable[tableid][pkrBlind]/2,
						PokerTable[tableid][pkrLimit],
						"None",
						PokerTable[tableid][pkrSetDelay]
					);
				} else {
					format(szString, sizeof(szString), "{FFFFFF}Buy-In Max\t({00FF00}$%d{FFFFFF})\nBuy-In Min\t({00FF00}$%d{FFFFFF})\nBlind\t\t({00FF00}$%d{FFFFFF} / {00FF00}$%d{FFFFFF})\nGioi han\t\t(%d)\nMat khau\t(%s)\nCho giua van\t(%d)\nBat dau",
						PokerTable[tableid][pkrBuyInMax],
						PokerTable[tableid][pkrBuyInMin],
						PokerTable[tableid][pkrBlind],
						PokerTable[tableid][pkrBlind]/2,
						PokerTable[tableid][pkrLimit],
						PokerTable[tableid][pkrPass],
						PokerTable[tableid][pkrSetDelay]
					);
				}
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPGAME, DIALOG_STYLE_LIST, "{FFFFFF}Casino Games - (Thiet lap phong Poker)", szString, "Chon", "Thoat");
			}
		}
		case DIALOG_CGAMESSETUPPGAME2:
		{
			if(GetPVarType(playerid, "pkrTableID")) {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPGAME2, DIALOG_STYLE_INPUT, "{FFFFFF}Casino Games - (Buy-In Max)", "{FFFFFF}Nhap Buy-In Max:", "Doi", "Quay lai");
			}
		}
		case DIALOG_CGAMESSETUPPGAME3:
		{
			if(GetPVarType(playerid, "pkrTableID")) {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPGAME3, DIALOG_STYLE_INPUT, "{FFFFFF}Casino Games - (Buy-In Min)", "{FFFFFF}Nhap Buy-In Min:", "Doi", "Quay lai");
			}
		}
		case DIALOG_CGAMESSETUPPGAME4:
		{
			if(GetPVarType(playerid, "pkrTableID")) {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPGAME4, DIALOG_STYLE_INPUT, "{FFFFFF}Casino Games - (Blinds)", "{FFFFFF}Nhap Blinds:\n\nChu y: Small blinds tu dong bang nua big blind.", "Doi", "Quay lai");
			}
		}
		case DIALOG_CGAMESSETUPPGAME5:
		{
			if(GetPVarType(playerid, "pkrTableID")) {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPGAME5, DIALOG_STYLE_INPUT, "{FFFFFF}Casino Games - (Gioi han)", "{FFFFFF}Nhap gioi han nguoi choi (2-6):", "Doi", "Quay lai");
			}
		}
		case DIALOG_CGAMESSETUPPGAME6:
		{
			if(GetPVarType(playerid, "pkrTableID")) {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPGAME6, DIALOG_STYLE_INPUT, "{FFFFFF}Casino Games - (Mat khau)", "{FFFFFF}Nhap mat khau:\n\nChu y: De trong de mo phong cong khai", "Doi", "Quay lai");
			}
		}
		case DIALOG_CGAMESSETUPPGAME7:
		{
			if(GetPVarType(playerid, "pkrTableID")) {
				return ShowPlayerDialogEx(playerid, DIALOG_CGAMESSETUPPGAME7, DIALOG_STYLE_INPUT, "{FFFFFF}Casino Games - (Cho giua van)", "{FFFFFF}Nhap thoi gian cho giua van (15-120sec):", "Doi", "Quay lai");
			}
		}
	}
	return 1;
}

JoinPokerTable(playerid, tableid) {
	if(tableid < 0 || tableid >= MAX_POKERTABLES || GetPVarType(playerid, "pkrTableID")) return 0;
	if(PokerTable[tableid][pkrRound] || PokerTable[tableid][pkrActive] == 4) return SendClientMessageEx(playerid, COLOR_GREY, "Hay cho het van de vao ban.");

	// Check if there is room for the player
	if(PokerTable[tableid][pkrPlayers] < PokerTable[tableid][pkrLimit]) {
		// Check if table is not joinable.
		if(PokerTable[tableid][pkrActive] == 1) {
			SendClientMessage(playerid, COLOR_WHITE, "Co nguoi dang thiet lap ban, hay thu lai sau.");
			return 1;
		}

		// Find an open seat
		for(new s; s < 6; s++) {
			if(PokerTable[tableid][pkrSlot][s] == -1) {

				SetPVarInt(playerid, "pkrTableID", tableid+1);
				SetPVarInt(playerid, "pkrSlot", s);

				// Occuply Slot
				PokerTable[tableid][pkrPlayers] += 1;
				PokerTable[tableid][pkrSlot][s] = playerid;

				// Check & Start Game Loop if Not Active
				if(PokerTable[tableid][pkrPlayers] == 1) {

					// Player is Room Creator
					SetPVarInt(playerid, "pkrRoomLeader", 1);
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);

					PokerTable[tableid][pkrActive] = 1; // Warmup Phase
					PokerTable[tableid][pkrPulseTimer] = SetTimerEx("PokerPulse", 1000, true, "i", tableid);

					//PokerPulse(tableid);
				} else { // Execute code for Non-Room Creators
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESBUYINPOKER);
					SelectTextDraw(playerid, COLOR_YELLOW);
				}

				CameraRadiusSetPos(playerid, PokerTable[tableid][pkrX], PokerTable[tableid][pkrY], PokerTable[tableid][pkrZ], 90.0, 4.7, 0.1);

				new Float:tmpPos[3];
				GetPlayerPos(playerid, tmpPos[0], tmpPos[1], tmpPos[2]);

                SetPlayerInterior(playerid, PokerTable[tableid][pkrInt]);
				SetPlayerVirtualWorld(playerid, PokerTable[tableid][pkrVW]);
				SetPVarFloat(playerid, "pkrTableJoinX", tmpPos[0]);
				SetPVarFloat(playerid, "pkrTableJoinY", tmpPos[1]);
				SetPVarFloat(playerid, "pkrTableJoinZ", tmpPos[2]);

				new string[128];
				format(string, sizeof(string), "%s(%d) (IP:%s) has joined poker table (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), tableid);
				Log("logs/poker.log", string);

				ApplyAnimation(playerid, "CASINO", "cards_out", 4.1, false, true, true, true, 1, 1);
				TogglePlayerControllable(playerid, false);
				SetPlayerPosObjectOffset(PokerTable[tableid][pkrObjectID], playerid, PokerTableMiscObjOffsets[s][0], PokerTableMiscObjOffsets[s][1], PokerTableMiscObjOffsets[s][2]);
				SetPlayerFacingAngle(playerid, PokerTableMiscObjOffsets[s][5]+90.0);
				ApplyAnimation(playerid, "CASINO", "cards_out", 4.1, false, true, true, true, 1, 1);

				// Create GUI
				CreatePokerGUI(playerid);
				ShowPokerGUI(playerid, GUI_POKER_TABLE);

				// Hide Action Bar
				PokerOptions(playerid, 0);

				return 1;
			}
		}
	}
	return 1;
}

LeavePokerTable(playerid, bool:disconnecting = false) {
	new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot");
	if(tableid < 0 || tableid >= MAX_POKERTABLES || slot < 0 || slot >= 6 || PokerTable[tableid][pkrSlot][slot] != playerid) return 0;
	if(PokerTable[tableid][pkrPot] > 0 && (PokerTable[tableid][pkrActive] == 4 || PokerTable[tableid][pkrActiveHands] == 1)) PokerSettlePot(tableid);
	if(PokerTable[tableid][pkrActive] == 3 && PokerTable[tableid][pkrRound]) PokerFoldHand(playerid);
	new chips = GetPVarInt(playerid, "pkrChips"), string[128];
	GivePlayerCashEx(playerid, TYPE_ONHAND, chips);
	format(string, sizeof(string), "%s(%d) (IP:%s) has left the table with $%s (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(chips), tableid);
	Log("logs/poker.log", string);
	PokerTable[tableid][pkrPlayers]--;
	PokerTable[tableid][pkrSlot][slot] = -1;
	if(!disconnecting) {
		SetPlayerInterior(playerid, PokerTable[tableid][pkrInt]);
		SetPlayerVirtualWorld(playerid, PokerTable[tableid][pkrVW]);
		SetPlayerPos(playerid, GetPVarFloat(playerid, "pkrTableJoinX"), GetPVarFloat(playerid, "pkrTableJoinY"), GetPVarFloat(playerid, "pkrTableJoinZ")+0.1);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		ApplyAnimation(playerid, "CARRY", "crry_prtial", 2.0, false, false, false, false, 0);
		CancelSelectTextDraw(playerid);
		ShowPlayerDialogEx(playerid, -1, DIALOG_STYLE_MSGBOX, "Dong", "Close", "Dong", "Dong");
		SetTimerEx("PokerExit", 250, false, "ii", playerid, g_arrQueryHandle[playerid]);
	}
	DeletePVar(playerid, "pkrWinner");
	DeletePVar(playerid, "pkrCurrentBet");
	DeletePVar(playerid, "pkrChips");
	DeletePVar(playerid, "pkrTableJoinX");
	DeletePVar(playerid, "pkrTableJoinY");
	DeletePVar(playerid, "pkrTableJoinZ");
	DeletePVar(playerid, "pkrTableID");
	DeletePVar(playerid, "pkrSlot");
	DeletePVar(playerid, "pkrStatus");
	DeletePVar(playerid, "pkrRoomLeader");
	DeletePVar(playerid, "pkrRoomBigBlind");
	DeletePVar(playerid, "pkrRoomSmallBlind");
	DeletePVar(playerid, "pkrRoomDealer");
	DeletePVar(playerid, "pkrCard1");
	DeletePVar(playerid, "pkrCard2");
	DeletePVar(playerid, "pkrActivePlayer");
	DeletePVar(playerid, "pkrActiveHand");
	DeletePVar(playerid, "pkrHide");
	DeletePVar(playerid, "pkrTime");
	DeletePVar(playerid, "pkrActionChoice");
	DeletePVar(playerid, "pkrActionOptions");
	DestroyPokerGUI(playerid);
	if(PokerTable[tableid][pkrPlayers] == 0) {
		KillTimer(PokerTable[tableid][pkrPulseTimer]);
		PokerTable[tableid][pkrPulseTimer] = 0;
		ResetPokerTable(tableid);
	}
	else if(PokerTable[tableid][pkrActive] == 3 && PokerTable[tableid][pkrRound]
		&& (PokerTable[tableid][pkrActivePlayerID] == playerid || PokerTable[tableid][pkrActiveHands] <= 1)) PokerRotateActivePlayer(tableid);
	return 1;
}

CMD:jointable(playerid, params[])
{
	if(PlayerInfo[playerid][pConnectHours] < 5) {
	    SendClientMessageEx(playerid, COLOR_GREY, "Can choi 5 gio de vao ban Poker.");
	    return 1;
	}
	if(GetPVarType(playerid, "pkrTableID") == 0) {
		for(new t = 0; t < MAX_POKERTABLES; t++) {
			if(IsPlayerInRangeOfPoint(playerid, 5.0, PokerTable[t][pkrX], PokerTable[t][pkrY], PokerTable[t][pkrZ])) {
				if(PokerTable[t][pkrPass][0] != EOS) {
					if(!strcmp(params, PokerTable[t][pkrPass], false, 32)) {
						JoinPokerTable(playerid, t);
					} else {
						return SendClientMessage(playerid, COLOR_WHITE, "Cach dung: /jointable (password)");
					}
				} else {
					JoinPokerTable(playerid, t);
				}
				return 1;
			}
		}
	} else {
		SendClientMessage(playerid, COLOR_WHITE, "Ban dang o ban Poker! Dung /leavetable truoc khi vao ban khac!");
	}
	return 1;
}

CMD:leavetable(playerid, params[])
{
	if(GetPVarType(playerid, "pkrTableID")) {
		LeavePokerTable(playerid);
	}
	return 1;
}

CMD:placetable(playerid, params[])
{
	if(PlayerInfo[playerid][pTable] == 1 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {

	    if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay trong dau truong!");
		if(GetPVarInt(playerid, "WatchingTV")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay khi dang xem TV!");
		if(GetPVarInt(playerid, "Injured") == 1 || PlayerInfo[playerid][pHospital] > 0 || IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam vay.");
		if(PlayerInfo[playerid][pVW] == 0 || PlayerInfo[playerid][pInt] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc dat ban Poker trong noi that.");
		if(GetPVarType(playerid, "pTable")) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da dat ban Poker, dung /destroytable.");

		foreach(new i: Player)
		{
			if(GetPVarType(i, "pTable"))
			{
				if(IsPlayerInRangeOfPoint(playerid, 7.0, PokerTable[GetPVarInt(i, "pTable")][pkrX], PokerTable[GetPVarInt(i, "pTable")][pkrY], PokerTable[GetPVarInt(i, "pTable")][pkrZ]))
				{
					SendClientMessage(playerid, COLOR_GREY, "Co ban Poker khac o gan, khong the dat tai day!");
					return 1;
				}
			}
		}	

		format(szMiscArray, sizeof(szMiscArray), "%s da dat ban Poker!", GetPlayerNameEx(playerid));
	    ProxDetector(30.0, playerid, szMiscArray, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);

	    new Float:fPos[4];
	    GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);
	    GetPlayerFacingAngle(playerid, fPos[3]);
	    ApplyAnimation(playerid,"BOMBER","BOM_Plant_Crouch_In", 4.0, false, false, false, false, 0, 1);
	    fPos[0] += (2 * floatsin(-fPos[3], degrees));
    	fPos[1] += (2 * floatcos(-fPos[3], degrees));
		fPos[2] -= 0.5;

        for(new i = 0; i < MAX_POKERTABLES; i++) {
		    if(PokerTable[i][pkrPlaced] == 0) {
				PlacePokerTable(i, 1, fPos[0], fPos[1], fPos[2], 0, 0, 0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
				SetPVarInt(playerid, "pTable", i);
				break;
			}
		}
	}
	else {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong the dat ban Poker.");
	}
	return 1;
}

CMD:destroytable(playerid, params[])
{
	if(GetPVarType(playerid, "pTable"))
	{
	    if(PokerTable[GetPVarInt(playerid, "pTable")][pkrPlayers] != 0)
			return SendClientMessageEx(playerid, COLOR_GREY, "Khong the huy ban khi dang choi.");

	    DestroyPokerTable(GetPVarInt(playerid, "pTable"));
		DeletePVar(playerid, "pTable");
		SendClientMessage(playerid, COLOR_GREY, "Ban da huy ban Poker!");
	}
	return 1;
}

CMD:shoptable(playerid, params[])
{
	if (PlayerInfo[playerid][pShopTech] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new giveplayerid, invoice;
	if(sscanf(params, "ui", giveplayerid, invoice)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /shoptable [player] [invoice #]");
	new string[128];

	if(PlayerInfo[giveplayerid][pTable] == 1)
	{
	    PlayerInfo[giveplayerid][pTable] = 0;
		SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban Poker cua ban da bi Shop Tech %s thu hoi. ", GetPlayerNameEx(playerid));
		format(string, sizeof(string), "[SHOPPOKERTABLE] %s has taken %s(%d) poker table - Invoice %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
		SendClientMessageEx(playerid, COLOR_GRAD1, string);
		Log("logs/shoplog.log", string);
	}
	else
	{
		PlayerInfo[giveplayerid][pTable] = 1;
		SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc Shop Tech %s cap ban Poker.", GetPlayerNameEx(playerid));
		format(string, sizeof(string), "[SHOPPOKERTABLE] %s has given %s(%d) a poker table - Invoice %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), invoice);
		SendClientMessageEx(playerid, COLOR_GRAD1, string);
		Log("logs/shoplog.log", string);
	}
	return 1;
}