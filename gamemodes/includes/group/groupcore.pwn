/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Dynamic Group Core

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

Group_DisbandGroup(iGroupID) {

	new
		i = 0,
		szQuery[128];

	for(new spikeid; spikeid < MAX_SPIKES; spikeid++) DeleteSpikeStrip(iGroupID, spikeid);

	arrGroupData[iGroupID][g_iAllegiance] = 0;
	arrGroupData[iGroupID][g_iBugAccess] = INVALID_RANK;
	arrGroupData[iGroupID][g_iFindAccess] = INVALID_RANK;
	arrGroupData[iGroupID][g_iRadioAccess] = INVALID_RANK;
	arrGroupData[iGroupID][g_iDeptRadioAccess] = INVALID_RANK;
	arrGroupData[iGroupID][g_iIntRadioAccess] = INVALID_RANK;
	arrGroupData[iGroupID][g_iGovAccess] = INVALID_RANK;
	arrGroupData[iGroupID][g_iTreasuryAccess] = INVALID_RANK;
	arrGroupData[iGroupID][g_iFreeNameChange] = INVALID_RANK;
	arrGroupData[iGroupID][g_iFreeNameChangeDiv] = INVALID_DIVISION;
	arrGroupData[iGroupID][g_iSpikeStrips] = INVALID_RANK;
	arrGroupData[iGroupID][g_iBarricades] = INVALID_RANK;
	arrGroupData[iGroupID][g_iCones] = INVALID_RANK;
	arrGroupData[iGroupID][g_iFlares] = INVALID_RANK;
	arrGroupData[iGroupID][g_iBarrels] = INVALID_RANK;
	arrGroupData[iGroupID][g_iLadders] = INVALID_RANK;
	arrGroupData[iGroupID][g_iTapes] = INVALID_RANK;
	arrGroupData[iGroupID][g_iBudget] = 0;
	arrGroupData[iGroupID][g_iBudgetPayment] = 0;
	arrGroupData[iGroupID][g_fCratePos][0] = 0;
	arrGroupData[iGroupID][g_fCratePos][1] = 0;
	arrGroupData[iGroupID][g_fCratePos][2] = 0;
	arrGroupData[iGroupID][g_szGroupName][0] = 0;

	arrGroupData[iGroupID][g_hDutyColour] = 0xFFFFFF;
	arrGroupData[iGroupID][g_hRadioColour] = 0xFFFFFF;
	arrGroupData[iGroupID][g_iMemberCount] = 0;
	arrGroupData[iGroupID][g_iGroupToyID] = 0;
	arrGroupData[iGroupID][g_iMaterials] = 0;

	arrGroupData[iGroupID][g_iDrugs][0] = 0;
	arrGroupData[iGroupID][g_iDrugs][1] = 0;
	arrGroupData[iGroupID][g_iDrugs][2] = 0;
	arrGroupData[iGroupID][g_iDrugs][3] = 0;
	arrGroupData[iGroupID][g_iDrugs][4] = 0;

	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "UPDATE `gWeaponsNew` SET `1` = '0'");
	for(new x = 2; x < 47; x++) format(szMiscArray, sizeof(szMiscArray), "%s, `%d` = '0'", szMiscArray, x);
	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "%s WHERE `id` = '%d'", szMiscArray, iGroupID + 1);
	mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "ii", SENDDATA_THREAD, iGroupID);


	DestroyDynamic3DTextLabel(arrGroupData[iGroupID][g_tCrate3DLabel]);

	while(i < MAX_GROUP_DIVS) {
		arrGroupDivisions[iGroupID][i++][0] = 0;
	}
	i = 0;

	while(i < MAX_GROUP_RANKS) {
		arrGroupRanks[iGroupID][i][0] = 0;
		arrGroupData[iGroupID][g_iPaycheck][i++] = 0;
	}
	i = 0;

	while(i < MAX_GROUP_WEAPONS) {
		arrGroupData[iGroupID][g_iLockerGuns][i] = 0;
		arrGroupData[iGroupID][g_iLockerCost][i++] = 0;
	}

	i = 0;
	while(i < MAX_GROUP_LOCKERS) {
		DestroyDynamic3DTextLabel(arrGroupLockers[iGroupID][i][g_tLocker3DLabel]);
		arrGroupLockers[iGroupID][i][g_fLockerPos][0] = 0.0;
		arrGroupLockers[iGroupID][i][g_fLockerPos][1] = 0.0;
		arrGroupLockers[iGroupID][i][g_fLockerPos][2] = 0.0;
		arrGroupData[iGroupID][g_iLockerGuns][i] = 0;
		arrGroupData[iGroupID][g_iLockerCost][i++] = 0;
	}
	SaveGroup(iGroupID);

	for(new x; x < MAX_DYNAMIC_VEHICLES; x++)
	{
		if(DynVehicleInfo[x][gv_igID] != INVALID_GROUP_ID && DynVehicleInfo[x][gv_igID] == iGroupID)
		{
			DynVehicleInfo[x][gv_iModel] = 0;
			DynVehicleObjInfo[x][0][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
			DynVehicleObjInfo[x][1][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
			DynVehicleObjInfo[x][2][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
			DynVehicleObjInfo[x][3][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
			DynVehicleInfo[x][gv_igID] = INVALID_GROUP_ID;
			DynVehicleInfo[x][gv_igDivID] = 0;
			DynVehicleInfo[x][gv_fMaxHealth] = 1000;
			DynVehicleInfo[x][gv_iUpkeep] = 0;
			DynVehicleInfo[x][gv_iSiren] = 0;
			DynVeh_Save(x);
			DynVeh_Spawn(x);
		}
	}

	foreach(new x: Player)
	{
		if(PlayerInfo[x][pMember] == iGroupID || PlayerInfo[x][pLeader] == iGroupID) {
			SendClientMessageEx(x, COLOR_WHITE, "To chuc da bi quan tri vien giai tan. Tat ca thanh vien da bi loai tu dong.");
			PlayerInfo[x][pLeader] = INVALID_GROUP_ID;
			PlayerInfo[x][pMember] = INVALID_GROUP_ID;
			PlayerInfo[x][pRank] = INVALID_RANK;
			PlayerInfo[x][pDivision] = INVALID_DIVISION;
			strcpy(PlayerInfo[x][pBadge], "None", 9);
		}
		if (PlayerInfo[x][pBugged] == iGroupID) PlayerInfo[x][pBugged] = INVALID_GROUP_ID;
	}


	mysql_format(MainPipeline, szQuery, sizeof szQuery, "DELETE FROM `groupbans` WHERE `GroupBan` = %i", iGroupID);
	mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "ii", SENDDATA_THREAD, iGroupID+1);

	mysql_format(MainPipeline, szQuery, sizeof szQuery, "UPDATE `accounts` SET `Member` = "#INVALID_GROUP_ID", `Leader` = "#INVALID_GROUP_ID", `Division` = "#INVALID_DIVISION", `Rank` = "#INVALID_RANK" WHERE `Member` = %i OR `Leader` = %i", iGroupID, iGroupID);
	return mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "ii", SENDDATA_THREAD, iGroupID);
}

forward SaveGroup(iGroupID);
public SaveGroup(iGroupID) {
	if(!(0 <= iGroupID < MAX_GROUPS)) return 1;
	szMiscArray[0] = 0;
	new query[2048], i;
	format(query, 2048, "UPDATE `groups` SET ");

	//SaveString(query, "groups", iGroupID+1, "CLICKME", CLICKME);
	//SaveInteger(query, "groups", iGroupID+1, "CLICKME", CLICKME);
	//SaveFloat(query, "groups", iGroupID+1, "CLICKME", CLICKME);

	SaveInteger(query, "groups", iGroupID+1, "Type", arrGroupData[iGroupID][g_iGroupType]);
	SaveString(query, "groups", iGroupID+1, "Name", arrGroupData[iGroupID][g_szGroupName]);
	SaveString(query, "groups", iGroupID+1, "MOTD", gMOTD[iGroupID][0]);
	SaveString(query, "groups", iGroupID+1, "MOTD2", gMOTD[iGroupID][1]);
	SaveString(query, "groups", iGroupID+1, "MOTD3", gMOTD[iGroupID][2]);
	SaveInteger(query, "groups", iGroupID+1, "Allegiance", arrGroupData[iGroupID][g_iAllegiance]);
	SaveInteger(query, "groups", iGroupID+1, "Bug", arrGroupData[iGroupID][g_iBugAccess]);
	SaveInteger(query, "groups", iGroupID+1, "Find", arrGroupData[iGroupID][g_iFindAccess]);
	SaveInteger(query, "groups", iGroupID+1, "Radio", arrGroupData[iGroupID][g_iRadioAccess]);
	SaveInteger(query, "groups", iGroupID+1, "DeptRadio", arrGroupData[iGroupID][g_iDeptRadioAccess]);
	SaveInteger(query, "groups", iGroupID+1, "IntRadio", arrGroupData[iGroupID][g_iIntRadioAccess]);
	SaveInteger(query, "groups", iGroupID+1, "GovAnnouncement", arrGroupData[iGroupID][g_iGovAccess]);
	SaveInteger(query, "groups", iGroupID+1, "TreasuryAccess", arrGroupData[iGroupID][g_iTreasuryAccess]);
	SaveInteger(query, "groups", iGroupID+1, "FreeNameChange", arrGroupData[iGroupID][g_iFreeNameChange]);
	SaveInteger(query, "groups", iGroupID+1, "FreeNameChangeDiv", arrGroupData[iGroupID][g_iFreeNameChangeDiv]);
	SaveInteger(query, "groups", iGroupID+1, "DutyColour", arrGroupData[iGroupID][g_hDutyColour]);
	SaveInteger(query, "groups", iGroupID+1, "RadioColour", arrGroupData[iGroupID][g_hRadioColour]);
	SaveInteger(query, "groups", iGroupID+1, "Stock", arrGroupData[iGroupID][g_iLockerStock]);
	SaveFloat(query, "groups", iGroupID+1, "CrateX", arrGroupData[iGroupID][g_fCratePos][0]);
	SaveFloat(query, "groups", iGroupID+1, "CrateY", arrGroupData[iGroupID][g_fCratePos][1]);
	SaveFloat(query, "groups", iGroupID+1, "CrateZ", arrGroupData[iGroupID][g_fCratePos][2]);
	SaveInteger(query, "groups", iGroupID+1, "SpikeStrips", arrGroupData[iGroupID][g_iSpikeStrips]);
	SaveInteger(query, "groups", iGroupID+1, "Barricades", arrGroupData[iGroupID][g_iBarricades]);
	SaveInteger(query, "groups", iGroupID+1, "Cones", arrGroupData[iGroupID][g_iCones]);
	SaveInteger(query, "groups", iGroupID+1, "Flares", arrGroupData[iGroupID][g_iFlares]);
	SaveInteger(query, "groups", iGroupID+1, "Barrels", arrGroupData[iGroupID][g_iBarrels]);
	SaveInteger(query, "groups", iGroupID+1, "Ladders", arrGroupData[iGroupID][g_iLadders]);
	SaveInteger(query, "groups", iGroupID+1, "Tapes", arrGroupData[iGroupID][g_iTapes]);
	SaveInteger(query, "groups", iGroupID+1, "Budget", arrGroupData[iGroupID][g_iBudget]);
	SaveInteger(query, "groups", iGroupID+1, "BudgetPayment", arrGroupData[iGroupID][g_iBudgetPayment]);
	SaveInteger(query, "groups", iGroupID+1, "LockerCostType", arrGroupData[iGroupID][g_iLockerCostType]);
	SaveInteger(query, "groups", iGroupID+1, "CratesOrder", arrGroupData[iGroupID][g_iCratesOrder]);
	SaveInteger(query, "groups", iGroupID+1, "CrateIsland", arrGroupData[iGroupID][g_iCrateIsland]);
	SaveFloat(query, "groups", iGroupID+1, "GarageX", arrGroupData[iGroupID][g_fGaragePos][0]);
	SaveFloat(query, "groups", iGroupID+1, "GarageY", arrGroupData[iGroupID][g_fGaragePos][1]);
	SaveFloat(query, "groups", iGroupID+1, "GarageZ", arrGroupData[iGroupID][g_fGaragePos][2]);
	SaveInteger(query, "groups", iGroupID+1, "TackleAccess", arrGroupData[iGroupID][g_iTackleAccess]);
	SaveInteger(query, "groups", iGroupID+1, "WheelClamps", arrGroupData[iGroupID][g_iWheelClamps]);
	SaveInteger(query, "groups", iGroupID+1, "DoCAccess", arrGroupData[iGroupID][g_iDoCAccess]);
	SaveInteger(query, "groups", iGroupID+1, "MedicAccess", arrGroupData[iGroupID][g_iMedicAccess]);
	SaveInteger(query, "groups", iGroupID+1, "DMVAccess", arrGroupData[iGroupID][g_iDMVAccess]);
	SaveInteger(query, "groups", iGroupID+1, "TempNum", arrGroupData[iGroupID][gTempNum]);
	SaveInteger(query, "groups", iGroupID+1, "LEOArrest", arrGroupData[iGroupID][gLEOArrest]);
	SaveInteger(query, "groups", iGroupID+1, "OOCChat", arrGroupData[iGroupID][g_iOOCChat]);
	SaveInteger(query, "groups", iGroupID+1, "OOCColor", arrGroupData[iGroupID][g_hOOCColor]);
	SaveInteger(query, "groups", iGroupID+1, "Pot", arrGroupData[iGroupID][g_iDrugs][0]);
	SaveInteger(query, "groups", iGroupID+1, "Crack", arrGroupData[iGroupID][g_iDrugs][1]);
	SaveInteger(query, "groups", iGroupID+1, "Heroin", arrGroupData[iGroupID][g_iDrugs][4]);
	SaveInteger(query, "groups", iGroupID+1, "Syringes", arrGroupData[iGroupID][g_iSyringes]);
	SaveInteger(query, "groups", iGroupID+1, "Ecstasy", arrGroupData[iGroupID][g_iDrugs][3]);
	SaveInteger(query, "groups", iGroupID+1, "Meth", arrGroupData[iGroupID][g_iDrugs][2]);
	SaveInteger(query, "groups", iGroupID+1, "Mats", arrGroupData[iGroupID][g_iMaterials]);
	SaveInteger(query, "groups", iGroupID+1, "TurfCapRank", arrGroupData[iGroupID][g_iTurfCapRank]);
	SaveInteger(query, "groups", iGroupID+1, "PointCapRank", arrGroupData[iGroupID][g_iPointCapRank]);
	SaveInteger(query, "groups", iGroupID+1, "WithdrawRank", arrGroupData[iGroupID][g_iWithdrawRank][0]);
	SaveInteger(query, "groups", iGroupID+1, "WithdrawRank2", arrGroupData[iGroupID][g_iWithdrawRank][1]);
	SaveInteger(query, "groups", iGroupID+1, "WithdrawRank3", arrGroupData[iGroupID][g_iWithdrawRank][2]);
	SaveInteger(query, "groups", iGroupID+1, "WithdrawRank4", arrGroupData[iGroupID][g_iWithdrawRank][3]);
	SaveInteger(query, "groups", iGroupID+1, "WithdrawRank5", arrGroupData[iGroupID][g_iWithdrawRank][4]);
	SaveInteger(query, "groups", iGroupID+1, "Tokens", arrGroupData[iGroupID][g_iTurfTokens]);
	SaveInteger(query, "groups", iGroupID+1, "CrimeType", arrGroupData[iGroupID][g_iCrimeType]);
	SaveInteger(query, "groups", iGroupID+1, "GroupToyID", arrGroupData[iGroupID][g_iGroupToyID]);
	SaveInteger(query, "groups", iGroupID+1, "TurfTax", arrGroupData[iGroupID][g_iTurfTax]);

	for(i = 0; i != MAX_GROUP_RIVALS; ++i) {
		format(szMiscArray, sizeof(szMiscArray), "gRival%i", i);
		SaveString(query, "groups", iGroupID+1, szMiscArray, arrGroupData[iGroupID][g_iRivals][i]);
	}
	for(i = 0; i != MAX_GROUP_RANKS; ++i) {
		format(szMiscArray, sizeof(szMiscArray), "GClothes%i", i);
		SaveInteger(query, "groups", iGroupID+1, szMiscArray, arrGroupData[iGroupID][g_iClothes][i]);
		format(szMiscArray, sizeof(szMiscArray), "Rank%i", i);
		SaveString(query, "groups", iGroupID+1, szMiscArray, arrGroupRanks[iGroupID][i]);
		format(szMiscArray, sizeof(szMiscArray), "Rank%iPay", i);
		SaveInteger(query, "groups", iGroupID+1, szMiscArray, arrGroupData[iGroupID][g_iPaycheck][i]);
	}
	for(i = 0; i != MAX_GROUP_DIVS; ++i) {
		format(szMiscArray, sizeof(szMiscArray), "Div%i", i+1);
		SaveString(query, "groups", iGroupID+1, szMiscArray, arrGroupDivisions[iGroupID][i]);
	}
	for(i = 0; i != MAX_GROUP_WEAPONS; ++i) {
		format(szMiscArray, sizeof(szMiscArray), "Gun%i", i+1);
		SaveInteger(query, "groups", iGroupID+1, szMiscArray, arrGroupData[iGroupID][g_iLockerGuns][i]);
		format(szMiscArray, sizeof(szMiscArray), "Cost%i", i+1);
		SaveInteger(query, "groups", iGroupID+1, szMiscArray, arrGroupData[iGroupID][g_iLockerCost][i]);
	}
	SQLUpdateFinish(query, "groups", iGroupID+1);
	for (i = 0; i < MAX_GROUP_LOCKERS; i++)	{
		format(query, 2048, "UPDATE `lockers` SET ");
		SaveFloat(query, "lockers", arrGroupLockers[iGroupID][i][g_iLockerSQLId], "LockerX", arrGroupLockers[iGroupID][i][g_fLockerPos][0]);
		SaveFloat(query, "lockers", arrGroupLockers[iGroupID][i][g_iLockerSQLId], "LockerY", arrGroupLockers[iGroupID][i][g_fLockerPos][1]);
		SaveFloat(query, "lockers", arrGroupLockers[iGroupID][i][g_iLockerSQLId], "LockerZ", arrGroupLockers[iGroupID][i][g_fLockerPos][2]);
		SaveInteger(query, "lockers", arrGroupLockers[iGroupID][i][g_iLockerSQLId], "LockerVW", arrGroupLockers[iGroupID][i][g_iLockerVW]);
		SaveInteger(query, "lockers", arrGroupLockers[iGroupID][i][g_iLockerSQLId], "LockerShare", arrGroupLockers[iGroupID][i][g_iLockerShare]);
		SQLUpdateFinish(query, "lockers", arrGroupLockers[iGroupID][i][g_iLockerSQLId]);
	}
	return 1;
}

stock SendGroupMessage(iGroupType, color, const string[], allegiance = 0)
{
	new iGroupID;
	foreach(new i: Player)
	{
		iGroupID = PlayerInfo[i][pMember];
		if( iGroupType == -1 || ((0 <= iGroupID < MAX_GROUPS) && arrGroupData[iGroupID][g_iGroupType] == iGroupType) )
		{
			if(allegiance == 0 || allegiance == arrGroupData[iGroupID][g_iAllegiance])
			{
				SendClientMessageEx(i, color, string);
			}
		}
	}
}

stock SendMedicMessage(color, const string[])
{
	foreach(new i: Player)
	{
		if(IsFirstAid(i) || IsAMedic(i))
		{
			SendClientMessageEx(i, color, string);
		}
	}
}

stock SendDivisionMessage(member, division, color, const string[])
{
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pMember] == member && PlayerInfo[i][pDivision] == division) {
			SendClientMessageEx(i, color, string);
		}
	}
}


stock IsACop(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_LEA)) return 1;
	return 0;
}

stock IsAMedic(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_MEDIC)) return 1;
	return 0;
}

stock IsAReporter(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_NEWS)) return 1;
	return 0;
}

stock IsAGovernment(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_GOV)) return 1;
	return 0;
}

stock IsAJudge(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_JUDICIAL)) return 1;
	return 0;
}

stock IsALawyer(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_JUDICIAL) && PlayerInfo[playerid][pRank] > 1) return 1;
	if(Job_HasJob(playerid, JOB_LAWYER)) return 1;
	return 0;
}

stock IsATaxiDriver(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_TAXI) && TransportDuty[playerid] > 0) return 1;
	if(Job_HasJob(playerid, JOB_TAXI) || PlayerInfo[playerid][pTaxiLicense] == 1 && TransportDuty[playerid] > 0) return 1;
	return 0;
}


stock IsAnFTSDriver(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_TAXI))	return 1;
	return 0;
}

stock IsATowman(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_TOWING)) return 1;
	return 0;
}

stock IsARacer(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iCrimeType] == GROUP_CRIMINAL_TYPE_RACE)) return 1;
	return 0;
}

stock IsACriminal(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_CRIMINAL)) return 1;
	return 0;
}

stock IsADocGuard(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iDoCAccess])) return 1;
	return 0;
}

stock IsFirstAid(playerid)
{
	if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && arrGroupData[PlayerInfo[playerid][pMember]][g_iMedicAccess] != INVALID_DIVISION && PlayerInfo[playerid][pDivision] == arrGroupData[PlayerInfo[playerid][pMember]][g_iMedicAccess]) return 1;
	return 0;
}

stock IsMDCPermitted(playerid)
{
	if(IsACop(playerid) || IsAJudge(playerid))
	{
		return 1;
	}
	return 0;
}

stock GetPlayerGroupInfo(targetid, rank[], division[], employer[])
{
	new
		iGroupID = PlayerInfo[targetid][pMember],
	 	iRankID = PlayerInfo[targetid][pRank];

	if (0 <= iGroupID < MAX_GROUPS)
	{
	    if(0 <= iRankID < MAX_GROUP_RANKS)
	    {
		    if(arrGroupRanks[iGroupID][iRankID][0]) {
				format(rank, (GROUP_MAX_RANK_LEN), "%s", arrGroupRanks[iGroupID][iRankID]);
			}
			else format(rank, (GROUP_MAX_RANK_LEN), "undefined");
		}
	    if(0 <= PlayerInfo[targetid][pDivision] < MAX_GROUP_DIVS)
		{
			if(arrGroupDivisions[iGroupID][PlayerInfo[targetid][pDivision]][0]) { format(division, (GROUP_MAX_DIV_LEN), "%s", arrGroupDivisions[iGroupID][PlayerInfo[targetid][pDivision]]); }
			else format(division, (GROUP_MAX_DIV_LEN), "undefined");
		}
		else
		{
			if(arrGroupData[iGroupID][g_iGroupType] != GROUP_TYPE_CRIMINAL)
				format(division, (GROUP_MAX_DIV_LEN), "G.D.");
			else
				format(division, (GROUP_MAX_DIV_LEN), "None");
		}
	    if(arrGroupData[iGroupID][g_szGroupName][0]) {
			format(employer, (GROUP_MAX_NAME_LEN), "%s", arrGroupData[iGroupID][g_szGroupName]);
		}
		else
		{
		    format(employer, (GROUP_MAX_NAME_LEN), "undefined");
		}
	}
	else
	{
	    format(rank, (GROUP_MAX_RANK_LEN), "N/A");
	    format(division, (GROUP_MAX_DIV_LEN), "None");
	    format(employer, (GROUP_MAX_NAME_LEN), "None");
	}
	return 1;
}

stock ToggleDVSiren(iDvSlotID, iSlot, iTogState = 0)
{
	switch(DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectModel])
	{
		case 1899:
		{
			if(!iTogState) return 0;
			DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectModel] = 19294;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], E_STREAMER_MODEL_ID, 19294);
			AttachDynamicObjectToVehicle(DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], DynVehicleInfo[iDvSlotID][gv_iSpawnedID], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectZ], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRZ]);
		}
		case 18646:
		{
			if(iTogState) return 0;
			DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectModel] = 19300;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], E_STREAMER_MODEL_ID, 19300);
			AttachDynamicObjectToVehicle(DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], DynVehicleInfo[iDvSlotID][gv_iSpawnedID], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectZ], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRZ]);
		}
		case 19294:
		{
			if(iTogState) return 0;
			DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectModel] = 1899;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], E_STREAMER_MODEL_ID, 1899);
			AttachDynamicObjectToVehicle(DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], DynVehicleInfo[iDvSlotID][gv_iSpawnedID], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectZ], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRZ]);
		}
		case 19300:
		{
			if(!iTogState) return 0;
			DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectModel] = 18646;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], E_STREAMER_MODEL_ID, 18646);
			AttachDynamicObjectToVehicle(DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], DynVehicleInfo[iDvSlotID][gv_iSpawnedID], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectZ], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRZ]);
		}
		case 19419:
		{
			if(iTogState) return 0;
			DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectModel] = 19420;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], E_STREAMER_MODEL_ID, 19420);
			AttachDynamicObjectToVehicle(DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], DynVehicleInfo[iDvSlotID][gv_iSpawnedID], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectZ], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRZ]);
		}
		case 19420:
		{
			if(!iTogState) return 0;
			DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectModel] = 19419;
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], E_STREAMER_MODEL_ID, 19419);
			AttachDynamicObjectToVehicle(DynVehicleObjInfo[iDvSlotID][iSlot][gv_iAttachedObjectID], DynVehicleInfo[iDvSlotID][gv_iSpawnedID], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectZ], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRX], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRY], DynVehicleObjInfo[iDvSlotID][iSlot][gv_fObjectRZ]);
		}
	}
	return 1;
}

stock ToggleSiren(vehid, iTogState)
{
	if(iTogState == 1)
	{
		if(GetGVarInt("VehSiren", vehid) != INVALID_OBJECT_ID)
		{
			DestroyDynamicObject(GetGVarInt("VehSiren", vehid));
			DeleteGVar("VehSiren", vehid);
		}
		if(GetGVarInt("VehSiren2", vehid) != INVALID_OBJECT_ID)
		{
			DestroyDynamicObject(GetGVarInt("VehSiren2", vehid));
			DeleteGVar("VehSiren2", vehid);
		}
	}
	else
	{
		switch(GetVehicleModel(vehid))
		{
			case 402:
			{
				new iTempObj = CreateDynamicObject(18646, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 200.0);
				AttachDynamicObjectToVehicle(iTempObj, vehid, -0.20, 0.5, 0.4, 0.0, 0.0, 0.0);
				SetGVarInt("VehSiren", iTempObj, vehid);
			}
			case 411, 541:
			{
				new iTempObj = CreateDynamicObject(18646, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 200.0);
				AttachDynamicObjectToVehicle(iTempObj, vehid, 0.0, 0.2, 0.4, 0.0, 0.0, 0.0);
				SetGVarInt("VehSiren", iTempObj, vehid);
			}
			case 415:
			{
				new iTempObj = CreateDynamicObject(18646, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 200.0);
				AttachDynamicObjectToVehicle(iTempObj, vehid, -0.20, 0.30, 0.3, 0.0, 0.0, 0.0);
				SetGVarInt("VehSiren", iTempObj, vehid);
			}
			case 451:
			{
				new iTempObj = CreateDynamicObject(18646, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 200.0);
				AttachDynamicObjectToVehicle(iTempObj, vehid, -0.30, 0.4, 0.6, 0.0, 0.0, 0.0);
				SetGVarInt("VehSiren", iTempObj, vehid);
			}
			case 525:
			{
				new iTempObj2 = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 200.0);
				new iTempObj3 = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 200.0);
				AttachDynamicObjectToVehicle(iTempObj2, vehid, 0.55, -0.5, 1.5, 0.0, 0.0, 0.0);
				AttachDynamicObjectToVehicle(iTempObj3, vehid, -0.55, -0.5, 1.5, 0.0, 0.0, 0.0);
				SetGVarInt("VehSiren", iTempObj2, vehid);
				SetGVarInt("VehSiren2", iTempObj3, vehid);
			}
			default:
			{
				new iTempObj = CreateDynamicObject(18646, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 200.0);
				AttachDynamicObjectToVehicle(iTempObj, vehid, -0.30, 0.4, 0.4, 0.0, 0.0, 0.0);
				SetGVarInt("VehSiren", iTempObj, vehid);
			}
		}
	}
	return 1;
}

Group_GetMaxRank(iGroupID) {

	new
		iCount = MAX_GROUP_RANKS;

	while(iCount--) if(arrGroupRanks[iGroupID][iCount][0]) return iCount;
	return MAX_GROUP_RANKS-1;
}

Group_GetMaxDiv(iGroupID) {

	new
		iCount = MAX_GROUP_DIVS;

	while(iCount--) if(arrGroupDivisions[iGroupID][iCount][0]) return iCount;
	return MAX_GROUP_DIVS;
}

Group_ListGroups(iPlayerID, iDialogID = DIALOG_LISTGROUPS) {

	new
		szDialogStr[MAX_GROUPS * (GROUP_MAX_NAME_LEN + 16)],
		iCount;

	while(iCount < MAX_GROUPS) {
		if(arrGroupData[iCount][g_szGroupName][0])
			format(szDialogStr, sizeof szDialogStr, "%s\n(%i) {%s}%s{FFFFFF}", szDialogStr, iCount+1, Group_NumToDialogHex(arrGroupData[iCount][g_hDutyColour]), arrGroupData[iCount][g_szGroupName]);

		else
			format(szDialogStr, sizeof szDialogStr, "%s\n(%i) (trong)", szDialogStr, iCount+1);

		++iCount;
	}
	if(iDialogID == DIALOG_MAKELEADER)
	{
		new diagTitle[64];
		format(diagTitle, sizeof(diagTitle), "To chuc - Gan lanh dao cho %s", GetPlayerNameEx(GetPVarInt(iPlayerID, "MakingLeader")));
		return ShowPlayerDialogEx(iPlayerID, iDialogID, DIALOG_STYLE_LIST, diagTitle, szDialogStr, "Chon", "Huy");
	}
	else return ShowPlayerDialogEx(iPlayerID, iDialogID, DIALOG_STYLE_LIST, "Danh sach to chuc", szDialogStr, "Chon", "Huy");
}

Group_ReturnAllegiance(iAllegianceID) {

	new
		szResult[16] = "None";

	switch(iAllegianceID) {
		case 1: szResult = "San Andreas";
		case 2: szResult = "New Robada";
	}
	return szResult;
}

Group_ReturnType(iGroupType) {

	new
		szResult[32] = "None";

	switch(iGroupType) {
		case 1: szResult = "Law Enforcement";
		case 2: szResult = "Contract Agency";
		case 3: szResult = "Fire/Medic";
		case 4: szResult = "News Agency";
		case 5: szResult = "Government";
		case 6: szResult = "Judicial";
		case 7: szResult = "Transport";
		case 8: szResult = "Towing";
		case 9: szResult = "Criminal";
	}
	return szResult;
}

Group_DisplayDialog(iPlayerID, iGroupID) {
	new lockerCostName[13];

	new
		szTitle[22 + GROUP_MAX_NAME_LEN],
		szDialog[2048];

	format(szDialog, sizeof(szDialog),
		"{BBBBBB}Ten:{FFFFFF} %s\n\
		{BBBBBB}Loai:{FFFFFF} %s\n\
		{BBBBBB}Quoc gia:{FFFFFF} %s\n\
		{BBBBBB}Tham quyen\n\
		{BBBBBB}Mau truc: {%s}(sua)\n\
		{BBBBBB}Mau radio: {%s}(sua)\n\
		{BBBBBB}Quyen radio:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Radio lien nganh:{FFFFFF} %s (rank %i)\n",
		arrGroupData[iGroupID][g_szGroupName],
		Group_ReturnType(arrGroupData[iGroupID][g_iGroupType]),
		Group_ReturnAllegiance(arrGroupData[iGroupID][g_iAllegiance]),
		Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]),
		Group_NumToDialogHex(arrGroupData[iGroupID][g_hRadioColour]),
		(arrGroupData[iGroupID][g_iRadioAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iRadioAccess],
		(arrGroupData[iGroupID][g_iDeptRadioAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iDeptRadioAccess]
	);

	format(szDialog, sizeof(szDialog), "%s\
		{BBBBBB}Radio quoc te:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Nghe len:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Truy tim:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Thong bao chinh phu:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Quyen ngan quy:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Doi ten mien phi:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Division doi ten:{FFFFFF} %s (division %i)\n\
		{BBBBBB}Dai dinh:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Rao chan:{FFFFFF} %s (rank %i)\n",
		szDialog,
		(arrGroupData[iGroupID][g_iIntRadioAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iIntRadioAccess],
		(arrGroupData[iGroupID][g_iBugAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iBugAccess],
		(arrGroupData[iGroupID][g_iFindAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iFindAccess],
		(arrGroupData[iGroupID][g_iGovAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iGovAccess],
		(arrGroupData[iGroupID][g_iTreasuryAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iTreasuryAccess],
		(arrGroupData[iGroupID][g_iFreeNameChange] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iFreeNameChange],
		(arrGroupData[iGroupID][g_iFreeNameChangeDiv] != INVALID_DIVISION) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iFreeNameChangeDiv],
		(arrGroupData[iGroupID][g_iSpikeStrips] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iSpikeStrips],
		(arrGroupData[iGroupID][g_iBarricades] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iBarricades]
	);

	format(szDialog, sizeof(szDialog), "%s\
		{BBBBBB}Coc tieu:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Phao sang:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Thung phuy:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Thang:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Day chan:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Quyen Crate Island:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Sua ton kho tu:{FFFFFF} (%i)\n\
		{BBBBBB}Sua vu khi tu (%i da dat)\n",
		szDialog,
		(arrGroupData[iGroupID][g_iCones] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iCones],
		(arrGroupData[iGroupID][g_iFlares] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iFlares],
		(arrGroupData[iGroupID][g_iBarrels] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iBarrels],
		(arrGroupData[iGroupID][g_iLadders] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iLadders],
		(arrGroupData[iGroupID][g_iTapes] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iTapes],
		(arrGroupData[iGroupID][g_iCrateIsland] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iCrateIsland],
		arrGroupData[iGroupID][g_iLockerStock],
		Array_Count(arrGroupData[iGroupID][g_iLockerGuns], MAX_GROUP_WEAPONS)
	);

	strunpack(lockerCostName, lockercosttype[arrGroupData[iGroupID][g_iLockerCostType]], sizeof(lockerCostName));
	format(szDialog, sizeof(szDialog),
		"%s\
		{BBBBBB}Sua luong\n\
		{BBBBBB}Sua Division (%i da dat)\n\
		{BBBBBB}Sua rank (%i da dat)\n\
		{BBBBBB}Sua tu do\n\
		{BBBBBB}Sua diem giao thung (cach: %.0f)\n\
		{BBBBBB}Nguon tra phi tu: %s\n\
		{BBBBBB}Sua vi tri garage (cach: %.0f)\n\
		{BBBBBB}Quyen vat nga:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Quyen khoa banh:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Quyen DoC:{FFFFFF} %s (rank %i)\n",
		szDialog,
		String_Count(arrGroupDivisions[iGroupID], MAX_GROUP_DIVS),
		String_Count(arrGroupRanks[iGroupID], MAX_GROUP_RANKS),
		GetPlayerDistanceFromPoint(iPlayerID, arrGroupData[iGroupID][g_fCratePos][0], arrGroupData[iGroupID][g_fCratePos][1], arrGroupData[iGroupID][g_fCratePos][2]),
		lockerCostName,
		GetPlayerDistanceFromPoint(iPlayerID, arrGroupData[iGroupID][g_fGaragePos][0], arrGroupData[iGroupID][g_fGaragePos][1], arrGroupData[iGroupID][g_fGaragePos][2]),
		(arrGroupData[iGroupID][g_iTackleAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iTackleAccess],
		(arrGroupData[iGroupID][g_iWheelClamps] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iWheelClamps],
		(arrGroupData[iGroupID][g_iDoCAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iDoCAccess]
	);

	format(szDialog, sizeof(szDialog),
		"%s\
		{BBBBBB}Quyen Medic:{FFFFFF} %s (Div %i)\n\
		{BBBBBB}Quyen DMV:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Quyen so tam:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Quyen bat giu LEO:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Quyen chat OOC:{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Mau chat OOC: {%s}(sua)\n\
		{BBBBBB}Sua quan ao\n\
		{BBBBBB}Rank chiem turf{FFFFFF} %s (rank %i)\n\
		{BBBBBB}Rank chiem point {FFFFFF} %s (rank %i)\n\
		{BBBBBB}Loai to chuc toi pham {FFFFFF} %s",
		szDialog,
		(arrGroupData[iGroupID][g_iMedicAccess] != INVALID_DIVISION) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iMedicAccess],
		(arrGroupData[iGroupID][g_iDMVAccess] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iDMVAccess],
		(arrGroupData[iGroupID][gTempNum] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][gTempNum],
		(arrGroupData[iGroupID][gLEOArrest] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][gLEOArrest],
		(arrGroupData[iGroupID][g_iOOCChat] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iOOCChat],
		Group_NumToDialogHex(arrGroupData[iGroupID][g_hOOCColor]),
		(arrGroupData[iGroupID][g_iTurfCapRank] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iTurfCapRank],
		(arrGroupData[iGroupID][g_iPointCapRank] != INVALID_RANK) ? ("Co") : ("Khong"), arrGroupData[iGroupID][g_iPointCapRank],
		ReturnCrimeGroupType(arrGroupData[iGroupID][g_iCrimeType])
	);

	if(PlayerInfo[iPlayerID][pAdmin] >= 1337) strcat(szDialog, "\nGiai tan to chuc");
	format(szTitle, sizeof szTitle, "{FFFFFF}Sua {%s}%s", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
	return ShowPlayerDialogEx(iPlayerID, DIALOG_EDITGROUP, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
}

stock CrateLog(groupid, const string[])
{
	new month, day, year, file[32];
	getdate(year, month, day);
	format(file, sizeof(file), "cratelogs/%d/%d-%02d-%02d.log", groupid, year, month, day);
	return Log(file, string);
}

stock GroupLog(groupid, const string[])
{
	new month, day, year, file[32];
	getdate(year, month, day);
	format(file, sizeof(file), "grouplogs/%d/%d-%02d-%02d.log", groupid, year, month, day);
	return Log(file, string);
}

stock GroupPayLog(groupid, const string[])
{
	new month, day, year, file[32];
	getdate(year, month, day);
	format(file, sizeof(file), "grouppay/%d/%d-%02d-%02d.log", groupid, year, month, day);
	return Log(file, string);
}

stock GroupLogEx(groupid, const string[], type = 0) {

	new month, day, year, file[32];
	getdate(year, month, day);
	switch(type) {

		case 0: format(file, sizeof(file), "grouplogs/%d/warrents/%d-%02d-%02d.log", groupid, year, month, day);
		default: format(file, sizeof(file), "grouplogs/%d/assests/%d-%02d-%02d.log", groupid, year, month, day);
	}

    return Log(file, string);
}

ReturnCrimeGroupType(iType)
{
	new szReturn[10];

	switch(iType)
	{
		case 0: szReturn = "None";
		case 1: szReturn = "Racer";
	}

	return szReturn;
}

hook OnPlayerConnect(playerid)
{
	SpikeVehicle[playerid] = 0;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	SpikeVehicle[playerid] = 0;
    if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
    {
    	GetPlayerName(playerid, VehInfo[GetPlayerVehicleID(playerid)][vLastDriver], MAX_PLAYER_NAME);
    }
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if((newkeys & KEY_YES) && IsPlayerInAnyDynamicArea(playerid)) {

		if(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) {

			new areaid[1];
			GetPlayerDynamicAreas(playerid, areaid);
			// new i = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid[0], E_STREAMER_EXTRA_ID);

			if(areaid[0] != INVALID_STREAMER_ID) {
				for(new i; i < MAX_GROUP_LOCKERS; ++i) {
					if(areaid[0] == arrGroupLockers[PlayerInfo[playerid][pMember]][i][g_iLockerAreaID]) pc_cmd_locker(playerid, "");
				}
			}
		}
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	new areaName[27];

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	new sendername[MAX_PLAYER_NAME];
	new string[128], Float:parmor;
	szMiscArray[0] = 0;

	switch(dialogid)
	{
		// BEGIN DYNAMIC GROUP CODE
		case G_LOCKER_MAIN: {

			if(!response) return 1;

			new iGroupID = PlayerInfo[playerid][pMember];
			if(!ValidGroup(iGroupID)) return 1;

			if (strcmp("Quan ao", inputtext) == 0) {
				if(IsACriminal(playerid) || IsARacer(playerid)) {

					format(szMiscArray, sizeof(szMiscArray), "%s lay quan ao tu tu do", GetPlayerNameEx(playerid));
					ShowModelSelectionMenuEx(playerid, arrGroupData[PlayerInfo[playerid][pMember]][g_iClothes], MAX_GROUP_RANKS, "Doi quan ao.", DYNAMIC_FAMILY_CLOTHES, 0.0, 0.0, -55.0);
					return 1;
				}
			}

			if (strcmp("Ca truc", inputtext) == 0) {
				if(PlayerInfo[playerid][pDuty]==0) {

					if (IsAReporter(playerid) || IsATaxiDriver(playerid))
						format(string, sizeof(string), "* %s %s lay phu hieu tu tu do.", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid));
					else
						format(string, sizeof(string), "* %s %s lay phu hieu va sung tu tu do.", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid));

					ProxChatBubble(playerid, string);
					// ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					SetHealth(playerid, 100.0);
					if(IsAMedic(playerid)) Medics += 1;

					if(arrGroupData[iGroupID][g_iLockerStock] > 1 && arrGroupData[iGroupID][g_iLockerCostType] == 0) {

						SetArmour(playerid, 150);
						arrGroupData[iGroupID][g_iLockerStock] -= 1;
						new str[128];
						format(str, sizeof(str), "%s took a vest out of the %s locker at a cost of 1 HG Material.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
						GroupPayLog(iGroupID, str);
					}
					else if(arrGroupData[iGroupID][g_iLockerCostType] != 0) SetArmour(playerid, 150.0);
					else {
						SendClientMessageEx(playerid, COLOR_RED, "Tu khong du hang de cap ao giap.");
						SendClientMessageEx(playerid, COLOR_GRAD2, "Hay lien he cap tren hoac STAG de to chuc giao thung hang.");
					}
					PlayerInfo[playerid][pDuty] = 1;
					SetPlayerToTeamColor(playerid);
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban co the chon vu khi tu tu trang bi");
				}
				else if(PlayerInfo[playerid][pDuty]==1) {
					format(string, sizeof(string), "* %s %s cat phu hieu va sung vao tu do.", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid));
					ProxChatBubble(playerid, string);
					if(IsAMedic(playerid)) Medics -= 1;
					SetHealth(playerid, 100.0);
					RemoveArmor(playerid);
					PlayerInfo[playerid][pDuty] = 0;
					SetPlayerToTeamColor(playerid);
				}
			}

			if (strcmp("Trang bi", inputtext) == 0) {

				if((PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pUndercover] >= 1) && PlayerInfo[playerid][pTogReports] == 0)
					return SendClientMessageEx(playerid, COLOR_GRAD2, "Admin bi han che vu khi tu, dung /togreports de truy cap.");
				if(PlayerInfo[playerid][pTogReports] == 1 || PlayerInfo[playerid][pAdmin] < 2) {
					new
						szDialog[(32 + 8) * (MAX_GROUP_WEAPONS+1)];

					for(new i = 0; i != MAX_GROUP_WEAPONS; ++i) {
						if(arrGroupData[iGroupID][g_iLockerGuns][i]) {
							format(szDialog, sizeof szDialog, "%s%s(%i) %s", szDialog, szDialog[0] ? ("\n") : (""), arrGroupData[iGroupID][g_iLockerGuns][i], Weapon_ReturnName(arrGroupData[iGroupID][g_iLockerGuns][i]));
							if (arrGroupData[iGroupID][g_iLockerCostType] == 2) format(szDialog, sizeof szDialog, "%s    $%d", szDialog, arrGroupData[iGroupID][g_iLockerCost][i]);
						}
						else strcat(szDialog, szDialog[0] ? ("\n(trong)") : ("(trong)"));
					}
					strcat(szDialog, "\nPhu kien");
					format(string, sizeof(string), "%s Tu vu khi", arrGroupData[iGroupID][g_szGroupName]);
					SetPVarInt(playerid, "WeaponLockerGroup", iGroupID);
					ShowPlayerDialogEx(playerid, G_LOCKER_EQUIPMENT, DIALOG_STYLE_LIST, string, szDialog, "Mua", "Huy");
				}
			}

			if (strcmp("Vu khi", inputtext) == 0) {
				//if(IsACriminal(playerid) || IsARacer(playerid)) return ShowGroupWeapons(playerid, iGroupID);
				return ShowGroupWeapons(playerid, iGroupID);
			}
			if (strcmp("Chuyen thung", inputtext) == 0) {
				//if(IsACriminal(playerid) || IsARacer(playerid)) return ShowGroupWeapons(playerid, iGroupID);
				return CrateTransferOption(playerid, iGroupID);
			}

			if (strcmp("Ma tuy", inputtext) == 0) {

				szMiscArray[0] = 0;
				szMiscArray = "Ma tuy\tSo luong\n";
				for(new i; i < sizeof(Drugs); ++i) {

					format(szMiscArray, sizeof(szMiscArray), "%s%s\t%s\n", szMiscArray, Drugs[i], number_format(arrGroupData[iGroupID][g_iDrugs][i]));
				}

				format(string, sizeof(string), "%s Tu ma tuy", arrGroupData[iGroupID][g_szGroupName]);
				SetPVarInt(playerid, "GSafe_Opt", 2);
				return ShowPlayerDialogEx(playerid, G_LOCKER_DRUGS, DIALOG_STYLE_TABLIST_HEADERS, string, szMiscArray, "Chon", "<<");

				//\nCannabis (%i)\nCrack (%i)\nHeroin (%i)\nSyringes (%i)\nOpium (%i)
				//return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_LIST, "Gang Safe: Cannabis Safe", "Deposit\nWithdraw", "Select", "Back");
			}

			if (strcmp("Dong phuc", inputtext) == 0) {
				ShowPlayerDialogEx(playerid, G_LOCKER_UNIFORM, DIALOG_STYLE_INPUT, "Dong phuc","Chon skin (theo ID).", "Chon", "Huy");
			}

			/*if (strcmp("Ingredients", inputtext) == 0) {
				if(IsACriminal(playerid) || IsARacer(playerid)) {

					szMiscArray[0] = 0;
					szMiscArray = "Ingredients\tAmount\n";
					for(new i; i < sizeof(szIngredients); ++i) {

						format(szMiscArray, sizeof(szMiscArray), "%s%s\t%s\n", szMiscArray, szIngredients[i], number_format(arrGroupData[iGroupID][g_iIngredients][i]));
					}
					format(string, sizeof(string), "%s Ingredient Locker", arrGroupData[iGroupID][g_szGroupName]);
					SetPVarInt(playerid, "GSafe_Opt", 3);
					return ShowPlayerDialogEx(playerid, G_LOCKER_INGREDIENTS, DIALOG_STYLE_TABLIST_HEADERS, string, szMiscArray, "Select", "<<");
				}
			}*/

			if (strcmp("Portable Medkit & Vest Kit", inputtext) == 0) {

				if(GetPVarInt(playerid, "MedVestKit") == 1) {
					return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da mang Med Kit.");
				}
				if(arrGroupData[iGroupID][g_iLockerStock] > 1 && arrGroupData[iGroupID][g_iLockerCostType] == 0) {
					SendClientMessageEx(playerid, COLOR_GRAD1, "Ban dang mang Med Kit. Dung /placekit de cat vao ba lo/xe.");
					SetPVarInt(playerid, "MedVestKit", 1);
					arrGroupData[iGroupID][g_iLockerStock] -= 1;
					new str[128];
					format(str, sizeof(str), "%s took a med kit & vest out of the %s locker at a cost of 1 HG Material.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
					GroupPayLog(iGroupID, str);
				}
				else if(arrGroupData[iGroupID][g_iLockerCostType] == 1) {
					if(arrGroupData[iGroupID][g_iBudget] > 3000) {
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban dang mang Med Kit. Dung /placekit de cat vao ba lo/xe.");
						SetPVarInt(playerid, "MedVestKit", 1);
						arrGroupData[iGroupID][g_iBudget] -= 3000;
						new str[128];
						format(str, sizeof(str), "%s took a med kit & vest out of the %s locker at a cost of $3,000 to the budget fund.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
						GroupPayLog(iGroupID, str);
					}
					else return SendClientMessageEx(playerid, COLOR_GRAD2, " Co quan khong du tien mua ao giap. ($3,000)");
				}

				else if(arrGroupData[iGroupID][g_iLockerCostType] == 2) {
					if(GetPlayerCash(playerid) > 3000) {
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban dang mang Med Kit. Dung /placekit de cat vao ba lo/xe.");
						SetPVarInt(playerid, "MedVestKit", 1);
						GivePlayerCash(playerid, -3000);
						new str[128];
						format(str, sizeof(str), "%s took a med kit & vest out of the %s locker at a personal cost of $3,000.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
						GroupPayLog(iGroupID, str);
					}
					else return SendClientMessageEx(playerid, COLOR_GRAD2, " Ban khong du tien mua ao giap. ($3,000)");
				}
				else {
					SendClientMessageEx(playerid, COLOR_RED, "Tu khong du hang de cap bo dung cu cop xe.");
					SendClientMessageEx(playerid, COLOR_GRAD2, "Hay lien he cap tren de to chuc giao thung hang.");
				}
			}

			if (strcmp("Xoa truy na", inputtext) == 0) {
				ShowPlayerDialogEx(playerid, G_LOCKER_CLEARSUSPECT,DIALOG_STYLE_INPUT, arrGroupData[iGroupID][g_szGroupName]," Ban muon xoa truy na cho ai?","Xoa","Quay lai");
			}

			if (strcmp("First Aid & Kevlar", inputtext) == 0) {
				if(arrGroupData[iGroupID][g_iLockerStock] > 1 && arrGroupData[iGroupID][g_iLockerCostType] == 0) {
					GetArmour(playerid, parmor);
					if(parmor < 150) SetArmour(playerid, 150);
					SetHealth(playerid, 100.0);
					arrGroupData[iGroupID][g_iLockerStock] -= 1;
					new str[128];
					format(str, sizeof(str), "%s took a vest out of the %s locker at a cost of 1 HG Material.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
					GroupPayLog(iGroupID, str);
				}
				else if(arrGroupData[iGroupID][g_iLockerCostType] == 1) {
					if(arrGroupData[iGroupID][g_iBudget] > 2500) {
						GetArmour(playerid, parmor);
						if(parmor < 150) SetArmour(playerid, 150);
						SetHealth(playerid, 100.0);
						arrGroupData[iGroupID][g_iBudget] -= 2500;
						new str[128];
						format(str, sizeof(str), "%s took a vest out of the %s locker at a cost of $2,500.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
						GroupPayLog(iGroupID, str);
					}
					else return SendClientMessageEx(playerid, COLOR_GRAD2, " Co quan khong du tien mua ao giap. ($2,500)");
				}
				else if(arrGroupData[iGroupID][g_iLockerCostType] == 2) {
					if(GetPlayerCash(playerid) > 2500) {
						GetArmour(playerid, parmor);
						if(parmor < 150) SetArmour(playerid, 150);
						SetHealth(playerid, 100.0);
						GivePlayerCash(playerid, -2500);
						new str[128];
						format(str, sizeof(str), "%s took a vest out of the %s locker at a personal cost of $2,500.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
						GroupPayLog(iGroupID, str);
					}
					else return SendClientMessageEx(playerid, COLOR_GRAD2, " Ban khong du tien mua ao giap. ($2,500)");
				}

				else {
					SendClientMessageEx(playerid, COLOR_RED, "Tu khong du hang de cap ao giap.");
					SendClientMessageEx(playerid, COLOR_GRAD2, "Hay lien he cap tren hoac SAAS de to chuc giao thung hang.");
					return 1;
				}
			}

/*			if(strcmp("High Grade Armour", inputtext) == 0) {
				if(arrGroupData[iGroupID][g_iLockerStock] > 5) {
					GetArmour(playerid, parmor);
					if(parmor > 149) return SendClientMessageEx(playerid, COLOR_RED, "You already have high grade armour equipped!");
					arrGroupData[iGroupID][g_iLockerStock] -= 5;
					SetArmour(playerid, 150);
					new str[128];
					format(str, sizeof(str), "%s took a high grade vest out of the %s locker at a cost of 5 HG Material.", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
					GroupPayLog(iGroupID, str);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Your armor has been boosted to 150 as it's high grade.");
				} else {
					SendClientMessageEx(playerid, COLOR_RED, "The locker doesn't have the stock for your armor vest.");
					SendClientMessageEx(playerid, COLOR_GRAD2, "Contact your supervisor or the SAAS and organize a crate delivery.");
				}
			}
*/
			if (strcmp("Vat lieu", inputtext, true, 7) == 0) { // we need to specify the cellmax as else it'll pick up the formatting
				SetPVarInt(playerid, "GSafe_Opt", 1);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_LIST, "Gang Safe: Ket vat lieu", "Gui vao\nRut ra", "Chon", "Quay lai");
			}

			if (strcmp("Ket tien", inputtext, true, 8) == 0) { // we need to specify the cellmax as else it'll pick up the formatting
				SetPVarInt(playerid, "GSafe_Opt", 0);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_LIST, "Gang Safe: Ket tien", "Gui vao\nRut ra", "Chon", "Quay lai");
			}

			if (strcmp("Tazer & Cuffs", inputtext) == 0) {
				if(PlayerInfo[playerid][pHasTazer] == 0) {
					new szMessage[128];
					format(szMessage, sizeof(szMessage), "%s lay tazer va cong tay tu tu do.", GetPlayerNameEx(playerid));
					ProxChatBubble(playerid, szMessage);
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang mang tazer va cong tay.");
					PlayerInfo[playerid][pHasTazer] = 1;
					PlayerInfo[playerid][pHasCuff] = 1;
				}
				else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mang tazer va cong tay");
			}

			if (strcmp("Doi ten", inputtext) == 0) {
				if(PlayerInfo[playerid][pRank] >= arrGroupData[iGroupID][g_iFreeNameChange] && (PlayerInfo[playerid][pDivision] == arrGroupData[iGroupID][g_iFreeNameChangeDiv] || arrGroupData[iGroupID][g_iFreeNameChangeDiv] == INVALID_DIVISION))  {
					return ShowPlayerDialogEx( playerid, DIALOG_NAMECHANGE, DIALOG_STYLE_INPUT, "Doi ten","Nhap ten moi ban muon!\n\nChu y: To chuc cua ban duoc doi ten mien phi.", "Doi", "Huy" );
				}
			}
			
			if (strcmp("Phu kien", inputtext) == 0) {
					return ShowPlayerDialogEx(playerid, BUYTOYSCOP, DIALOG_STYLE_MSGBOX, "Phu kien", "Chao mung den tu phu kien hanh phap!\n\n(Nhu toy thuong, VIP mo them o.)","Tiep tuc", "Huy");
			}
		}
		case G_LOCKER_EQUIPMENT: if(response)
		{
			new	iGroupID = PlayerInfo[playerid][pMember];
			if(!CanUseGroupWeaponLocker(playerid) || !(0 <= listitem <= MAX_GROUP_WEAPONS)) return 1;

			if (listitem == 16)
			{
				ShowPlayerDialogEx(playerid, BUYTOYSCOP, DIALOG_STYLE_MSGBOX, "Phu kien", "Chao mung den tu phu kien hanh phap!\n\n(Nhu toy thuong, VIP mo them o.)","Tiep tuc", "Huy");
			}
			else
			{
				if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan cua ban bi han che!");
				new iGunID = arrGroupData[iGroupID][g_iLockerGuns][listitem];
				if(!iGunID || GetLoadoutWeaponSlot(iGunID) < 0 || arrGroupData[iGroupID][g_iLockerCost][listitem] < 0
					|| PlayerInfo[playerid][pRank] < LockerWep[iGroupID][lwRank][listitem]) return 1;
				if(arrGroupData[iGroupID][g_iLockerCostType] == 0)
				{
					if(arrGroupData[iGroupID][g_iLockerStock] >= arrGroupData[iGroupID][g_iLockerCost][listitem])
					{
						arrGroupData[iGroupID][g_iLockerStock] -= arrGroupData[iGroupID][g_iLockerCost][listitem];
						new str[128];
						format(str, sizeof(str), "%s took a %s out of the %s locker at a cost of %d HG Materials.", GetPlayerNameEx(playerid), GetWeaponNameEx(iGunID), arrGroupData[iGroupID][g_szGroupName], arrGroupData[iGroupID][g_iLockerCost][listitem]);
						GroupPayLog(iGroupID, str);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_RED, "Tu khong du hang de cap vu khi do.");
						SendClientMessageEx(playerid, COLOR_GRAD2, "Hay lien he cap tren hoac SAAS de to chuc giao thung hang.");
						return 1;
					}
				}
				else if(arrGroupData[iGroupID][g_iLockerCostType] == 1)
				{
					if (arrGroupData[iGroupID][g_iBudget] < arrGroupData[iGroupID][g_iLockerCost][listitem])
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "To chuc khong du tien mua vu khi do!");
						return 1;
					}
					else
					{
						arrGroupData[iGroupID][g_iBudget] -= arrGroupData[iGroupID][g_iLockerCost][listitem];
						new str[128];
						format(str, sizeof(str), "%s took a %s out of the %s locker at a cost of $%d.", GetPlayerNameEx(playerid), GetWeaponNameEx(iGunID), arrGroupData[iGroupID][g_szGroupName], arrGroupData[iGroupID][g_iLockerCost][listitem]);
						GroupPayLog(iGroupID, str);
					}
				}
				else if(arrGroupData[iGroupID][g_iLockerCostType] == 2)
				{
					if (GetPlayerCash(playerid) < arrGroupData[iGroupID][g_iLockerCost][listitem])
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du tien mua vu khi do!");
						return 1;
					}
					else
					{
						GivePlayerCash(playerid, -arrGroupData[iGroupID][g_iLockerCost][listitem]);
					}
				}
				GivePlayerValidWeapon(playerid, iGunID);
			}
		}
		case G_LOCKER_UNIFORM: if(response)	{
			new skin = strval(inputtext), iGroupID = PlayerInfo[playerid][pMember];
			if(IsInvalidSkin(skin)) {
				return ShowPlayerDialogEx(playerid, G_LOCKER_UNIFORM, DIALOG_STYLE_INPUT, arrGroupData[iGroupID][g_szGroupName],"Skin khong hop le. Hay chon lai.", "Chon", "Huy");
			}
			PlayerInfo[playerid][pModel] = skin;
			SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
		}
		case G_LOCKER_CLEARSUSPECT: if(response)
		{
			if(IsMDCPermitted(playerid))
			{
				new giveplayerid;
				new giveplayer[MAX_PLAYER_NAME];
				new iGroupID = PlayerInfo[playerid][pMember];
				giveplayerid = ReturnUser(inputtext);
				if(IsPlayerConnected(giveplayerid))
				{
					if(giveplayerid != INVALID_PLAYER_ID)
					{
						GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da xoa ho so va diem truy na cua %s.", GetPlayerNameEx(giveplayerid));
						SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s %s da xoa ho so va diem truy na cua ban.", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid));
						format(string, sizeof(string), "* %s %s da xoa ho so va diem truy na cua %s.", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						SendGroupMessage(GROUP_TYPE_LEA, RADIO, string);

						PlayerInfo[giveplayerid][pWantedLevel] = 0;
						SetPlayerToTeamColor(giveplayerid);
						SetPlayerWantedLevel(giveplayerid, 0);
						ClearCrimes(giveplayerid, playerid);

						PlayerInfo[giveplayerid][pWantedJailFine] = 0;
						PlayerInfo[giveplayerid][pWantedJailTime] = 0;
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
					}
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong du tham quyen de lam vay");
		}
		case DIALOG_LISTGROUPS: if(response) {
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pFactionModerator] < 2) return 1;
			SetPVarInt(playerid, "Group_EditID", listitem);
			return Group_DisplayDialog(playerid, listitem);
		}
		case DIALOG_EDITGROUP: {
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pFactionModerator] < 2) return 1;
			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				szTitle[64 + GROUP_MAX_NAME_LEN];

			if(response) switch(listitem) {
				case 0: {
					format(szTitle, sizeof szTitle, "Sua ten to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_NAME, DIALOG_STYLE_INPUT, szTitle, "Nhap ten cho to chuc.", "Xac nhan", "Huy");
				}
				case 1: {

					new
						szDialog[(32 + 2) * MAX_GROUP_TYPES];

					for(new i = 0; i != MAX_GROUP_TYPES; ++i)
						strcat(szDialog, "\n"), strcat(szDialog, Group_ReturnType(i));

					format(szTitle, sizeof szTitle, "Sua loai {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_TYPE, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 2: {

					new
						szDialog[(32 + 2) * MAX_GROUP_TYPES];

					for(new i = 0; i < MAX_GROUP_ALLEGIANCES; ++i)
						strcat(szDialog, "\n"), strcat(szDialog, Group_ReturnAllegiance(i));

					format(szTitle, sizeof szTitle, "Sua quoc gia to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_ALLEGIANCE, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 3:
				{
					if(arrGroupData[iGroupID][g_iJCount] == 0)
					{
						format(string, sizeof(string), "%s chua co tham quyen. Them bang /groupaddjurisdiction", arrGroupData[iGroupID][g_szGroupName]);
						SendClientMessage(playerid, COLOR_GRAD2, string);
						return Group_DisplayDialog(playerid, iGroupID);
					}
					else
					{
						new szDialog[2500];

						for(new i; i < arrGroupData[iGroupID][g_iJCount]; ++i)
						{
							strcat(szDialog, "\n"), strcat(szDialog, arrGroupJurisdictions[iGroupID][i][g_iAreaName]);
						}

						format(szTitle, sizeof szTitle, "Sua tham quyen {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
						ShowPlayerDialogEx(playerid, DIALOG_GROUP_JURISDICTION_LIST, DIALOG_STYLE_LIST, szTitle, szDialog, "Bo", "Quay lai");
					}
				}
				case 4: {
					format(szTitle, sizeof szTitle, "Sua mau truc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_DUTYCOL, DIALOG_STYLE_INPUT, szTitle, "Nhap mau dang hex (vi du, BCA3FF). Mau nay dung nhan dien to chuc (vi du mau ten).", "Xac nhan", "Huy");
				}
				case 5: {
					format(szTitle, sizeof szTitle, "Sua mau radio {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_RADIOCOL, DIALOG_STYLE_INPUT, szTitle, "Nhap mau dang hex (vi du, BCA3FF). Mau nay dung cho radio IC cua to chuc.", "Xac nhan", "Huy");
				}
				case 6 .. 9, 11, 13, 15 .. 22: {

					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					strmid(szTitle, inputtext, 0, strfind(inputtext, ":", true));
					format(szTitle, sizeof szTitle, "Sua %s", szTitle);
					if(listitem < 10) ShowPlayerDialogEx(playerid, DIALOG_GROUP_RADIOACC + (listitem - 6), DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
					if(listitem > 10) ShowPlayerDialogEx(playerid, DIALOG_GROUP_RADIOACC + (listitem - 8), DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 10: {

					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					strmid(szTitle, inputtext, 0, strfind(inputtext, ":", true));
					format(szTitle, sizeof szTitle, "Sua %s", szTitle);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_FINDACC, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 12: {
					
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					strmid(szTitle, inputtext, 0, strfind(inputtext, ":", true));
					format(szTitle, sizeof szTitle, "Sua %s", szTitle);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_TRESACC, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 14: {

					new
						szDialog[((32 + 5) * MAX_GROUP_DIVS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupDivisions[iGroupID][i][0]) ? (arrGroupDivisions[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					strmid(szTitle, inputtext, 0, strfind(inputtext, ":", true));
					format(szTitle, sizeof szTitle, "Sua %s", szTitle);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_RADIOACC + (listitem - 8), DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 23: {
					format(szTitle, sizeof szTitle, "Sua ton kho tu {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITSTOCK, DIALOG_STYLE_INPUT, szTitle, "Nhap so luong. Ton kho tu dung cap vu khi, co the bo sung bang thung hang.", "Xac nhan", "Huy");
				}
				case 24: {

					new
						szDialog[(32 + 8) * MAX_GROUP_WEAPONS];

					for(new i = 0; i != MAX_GROUP_WEAPONS; ++i) {
						if(arrGroupData[iGroupID][g_iLockerGuns][i]) format(szDialog, sizeof szDialog, "%s\n(%i) %s (gia: %i)", szDialog, arrGroupData[iGroupID][g_iLockerGuns][i], Weapon_ReturnName(arrGroupData[iGroupID][g_iLockerGuns][i]), arrGroupData[iGroupID][g_iLockerCost][i]);
						else strcat(szDialog, "\n(trong)");
					}

					format(szTitle, sizeof szTitle, "Sua vu khi to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITWEPS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 25: {

					new
						szDialog[(GROUP_MAX_RANK_LEN + 8) * MAX_GROUP_RANKS];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i) {
						format(szDialog, sizeof szDialog, "%s\nRank %i (%s):    $%s", szDialog, i, arrGroupRanks[iGroupID][i], number_format(arrGroupData[iGroupID][g_iPaycheck][i]));
					}

					format(szTitle, sizeof szTitle, "Sua luong to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_LISTPAY, DIALOG_STYLE_LIST, szTitle, szDialog, "Sua", "Huy");
				}
				case 26: {

					new
						szDialog[(GROUP_MAX_DIV_LEN + 8) * MAX_GROUP_DIVS];

					for(new i = 0; i != MAX_GROUP_DIVS; ++i) {
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i + 1, ((arrGroupDivisions[iGroupID][i][0]) ? (arrGroupDivisions[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));
					}

					format(szTitle, sizeof szTitle, "Sua Division {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITDIVS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 27: {

					new
						szDialog[(GROUP_MAX_RANK_LEN + 8) * MAX_GROUP_RANKS];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i) {
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));
					}

					format(szTitle, sizeof szTitle, "Sua rank {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITRANKS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 28: {

					new
						szDialog[MAX_GROUP_LOCKERS * 32];

					for(new i = 0; i < MAX_GROUP_LOCKERS; ++i) {
						format(szDialog, sizeof szDialog, "%s%Locker %d %s ID:%d\n", szDialog, i+1, ( arrGroupLockers[iGroupID][i][g_fLockerPos][0] != 0.0 ) ? ("(sua)") : ("(chua dat)"), arrGroupLockers[iGroupID][i]);
					}
					strcat(szDialog, "Xoa tat ca tu do");
					format(szTitle, sizeof szTitle, "Sua tu do to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_LOCKERS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 29: {
					format(szTitle, sizeof szTitle, "Sua diem giao thung {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_CRATEPOS, DIALOG_STYLE_MSGBOX, szTitle, "Ban chac muon chuyen diem giao thung den cho ban?\n\nNeu khong, hay huy va den vi tri mong muon.", "Huy", "Xac nhan");
				}
				case 30: {
					format(szTitle, sizeof szTitle, "Sua nguon tra phi tu {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_COSTTYPE, DIALOG_STYLE_LIST, szTitle, "Ton kho tu\nQuy to chuc\nTien nguoi choi", "Dong y", "Huy");
				}
				case 31: {
					format(szTitle, sizeof szTitle, "Sua vi tri garage {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_GARAGEPOS, DIALOG_STYLE_MSGBOX, szTitle, "Nhan 'Xac nhan' de chuyen garage den cho ban.\n\nNeu khong muon doi vi tri, nhan 'Huy'.", "Huy", "Xac nhan");
				}
				case 32: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen vat nga to chuc");
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_TACKLEACCESS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 33: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen khoa banh {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_WHEELCLAMPS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 34: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen DoC {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_DOCACCESS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 35: {
					new
						szDialog[((32 + 5) * MAX_GROUP_DIVS) + 24];

					for(new i = 0; i != MAX_GROUP_DIVS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupDivisions[iGroupID][i][0]) ? (arrGroupDivisions[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen Medic {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_MEDICACCESS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 36: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen DMV {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_DMVACCESS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 37: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen so tam {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_TEMPNUMACCESS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 38: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen bat giu LEO {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_LEOARRESTACCESS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 39: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua quyen chat OOC {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_OOCCHAT, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 40: {
					format(szTitle, sizeof szTitle, "Sua mau chat OOC {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_OOCCOLOR, DIALOG_STYLE_INPUT, szTitle, "Nhap mau dang hex (vi du, BCA3FF). Mau nay dung cho chat OOC.", "Xac nhan", "Huy");
				}
				case 41: {
					new
						szDialog[(GROUP_MAX_RANK_LEN + 8) * MAX_GROUP_RANKS];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i) {
						format(szDialog, sizeof szDialog, "%s\nRank %i (%s): Skin ID:%i", szDialog, i, arrGroupRanks[iGroupID][i], arrGroupData[iGroupID][g_iClothes][i]);
					}

					format(szTitle, sizeof szTitle, "Sua quan ao {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_LISTCLOTHES, DIALOG_STYLE_LIST, szTitle, szDialog, "Sua", "Huy");
				}
				case 42: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua rank chiem turf {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);

					ShowPlayerDialogEx(playerid, DIALOG_GROUP_TURFCAP, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 43: {
					new
						szDialog[((32 + 5) * MAX_GROUP_RANKS) + 24];

					for(new i = 0; i != MAX_GROUP_RANKS; ++i)
						format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));

					strcat(szDialog, "\nThu hoi quyen to chuc");

					format(szTitle, sizeof szTitle, "Sua rank chiem point {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_POINTCAP, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
				}
				case 44: {
					format(szTitle, sizeof szTitle, "Sua loai toi pham {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_CRIMETYPE, DIALOG_STYLE_LIST, szTitle, "None\nRacer", "Chon", "Huy");
				}
				default: {
					format(szTitle, sizeof szTitle, "{FF0000}Giai tan{FFFFFF} {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_DISBAND, DIALOG_STYLE_MSGBOX, szTitle, "{FFFFFF}Ban chac chan muon {FF0000}giai tan to chuc?{FFFFFF}\n\n\
					Thao tac nay se {FF0000}xoa toan bo du lieu va loai moi thanh vien, lanh dao{FFFFFF} khoi to chuc, ke ca ngoai tuyen.", "Huy", "Xac nhan");
				}
			}
			else if(GetPVarType(playerid, "Group_EditID")) { // They've made changes to a group setting - save it on exit!
				SaveGroup(GetPVarInt(playerid, "Group_EditID"));
				DeletePVar(playerid, "Group_EditID");
				return Group_ListGroups(playerid);
			}
		}
		case DIALOG_GROUP_NAME: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN];

				if(!(2 < strlen(inputtext) < GROUP_MAX_NAME_LEN)) {
					format(szTitle, sizeof szTitle, "Sua {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_NAME, DIALOG_STYLE_INPUT, szTitle, "Ten phai dai tu 2 den "#GROUP_MAX_NAME_LEN" ky tu.\n\nNhap ten cho to chuc.", "Xac nhan", "Huy");
				}
				format(string, sizeof(string), "%s has changed group %d's name from %s to %s", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName], inputtext);
				Log("logs/editgroup.log", string);
				strcpy(arrGroupData[iGroupID][g_szGroupName], inputtext, GROUP_MAX_NAME_LEN);
			}
			return Group_DisplayDialog(playerid, GetPVarInt(playerid, "Group_EditID"));
		}
		case DIALOG_GROUP_TYPE: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				arrGroupData[iGroupID][g_iGroupType] = listitem;

				format(string, sizeof(string), "%s has changed group %d's type to %s", GetPlayerNameEx(playerid), iGroupID+1, Group_ReturnType(arrGroupData[iGroupID][g_iGroupType]));
				Log("logs/editgroup.log", string);

			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_ALLEGIANCE: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) arrGroupData[iGroupID][g_iAllegiance] = listitem;

			format(string, sizeof(string), "%s has changed group %d's allegiance to %s", GetPlayerNameEx(playerid), iGroupID+1, Group_ReturnAllegiance(arrGroupData[iGroupID][g_iAllegiance]));
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_JURISDICTION_LIST: {
			new iGroupID = GetPVarInt(playerid, "Group_EditID");
			if(response)
			{
				new szTitle[128], szDialog[128];
				format(szTitle, sizeof(szTitle), "Tham quyen cua %s", arrGroupData[iGroupID][g_szGroupName]);
				format(szDialog, sizeof(szDialog), "Ban chac muon go %s khoi %s?", arrGroupJurisdictions[iGroupID][listitem][g_iAreaName], arrGroupData[iGroupID][g_szGroupName]);
				SetPVarInt(playerid, "JurisdictionRemoval", listitem);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_JURISDICTION_REMOVE, DIALOG_STYLE_MSGBOX, szTitle, szDialog, "Xac nhan", "Huy");
			}
			else return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_JURISDICTION_REMOVE: {
			new iGroupID = GetPVarInt(playerid, "Group_EditID");
			if(response)
			{
				new jurisdictionid = GetPVarInt(playerid, "JurisdictionRemoval");
				mysql_format(MainPipeline, string, sizeof(string), "DELETE FROM `jurisdictions` WHERE `id` = %i", arrGroupJurisdictions[iGroupID][jurisdictionid][g_iJurisdictionSQLId]);
				mysql_tquery(MainPipeline, string, "OnQueryFinish", "i", SENDDATA_THREAD);
				mysql_tquery(MainPipeline, "SELECT * FROM `jurisdictions`", "Group_QueryFinish", "ii", GROUP_QUERY_JURISDICTIONS, 0);
				format(string, sizeof(string), "Da go %s khoi %s.", arrGroupJurisdictions[iGroupID][jurisdictionid][g_iAreaName], arrGroupData[iGroupID][g_szGroupName]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				format(string, sizeof(string), "%s has removed %s from group %d's jurisdictions.", GetPlayerNameEx(playerid), arrGroupJurisdictions[iGroupID][jurisdictionid][g_iAreaName], iGroupID+1);
				Log("logs/editgroup.log", string);
			}
			DeletePVar(playerid, "JurisdictionRemoval");
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_RADIOACC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iRadioAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked the radio (/r) access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iRadioAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for radio (/r) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iRadioAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iRadioAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_DEPTRADIOACC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iDeptRadioAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked the dept radio (/dept) access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default:{
					arrGroupData[iGroupID][g_iDeptRadioAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for dept radio (/dept) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iDeptRadioAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iDeptRadioAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_INTRADIOACC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iIntRadioAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked the int radio (/int) access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iIntRadioAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for int radio (/int) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iIntRadioAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iIntRadioAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_BUGACC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iBugAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked the bug (/bug) access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iBugAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for bug access (/bug) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iBugAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iBugAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_FINDACC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iFindAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked find (/hfind) access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iFindAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for find access (/hfind) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iFindAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iFindAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_GOVACC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iGovAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked government announcement (/gov) access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iGovAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for government announcement (/gov) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iGovAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iGovAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_TRESACC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iTreasuryAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked treasury Access (/setbudget) access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iTreasuryAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for treasury Access (/setbudget) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iTreasuryAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iTreasuryAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_FREENC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iFreeNameChange] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked free name changes access from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iFreeNameChange] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for free name changes to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iFreeNameChange], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iFreeNameChange]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_FREEDIVNC: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_DIVS: {
					arrGroupData[iGroupID][g_iFreeNameChangeDiv] = INVALID_DIVISION;
					format(string, sizeof(string), "%s has revoked the division for free name changes from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iFreeNameChangeDiv] = listitem;
					format(string, sizeof(string), "%s has set the division for free name changes to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iFreeNameChange], arrGroupDivisions[iGroupID][arrGroupData[iGroupID][g_iFreeNameChange]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}

		case DIALOG_GROUP_SPIKES: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iSpikeStrips] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked spikes (/deploy spikes) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iSpikeStrips] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for spikes (/deploy spikes) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iSpikeStrips], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iSpikeStrips]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}

		case DIALOG_GROUP_CADES: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iBarricades] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked cades (/deploy cades) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iBarricades] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for cades (/deploy cades) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iBarricades], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iBarricades]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}

		case DIALOG_GROUP_CONES: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iCones] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked cones (/deploy cone) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iCones] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for cones (/deploy cone) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iCones], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iCones]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}

		case DIALOG_GROUP_FLARES: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iFlares] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked flares (/deploy flares) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iFlares] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for flares (/deploy flares) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iFlares], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iFlares]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}

		case DIALOG_GROUP_BARRELS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iBarrels] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked barrels (/deploy barrel) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iBarrels] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for barrels (/deploy barrel) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iBarrels], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iBarrels]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}

		case DIALOG_GROUP_LADDERS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iLadders] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked ladders (/deploy ladder) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iLadders] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for ladders (/deploy ladder) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iLadders], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iLadders]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_TAPES: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iTapes] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked tapes (/deploy tape) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iTapes] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for tapes (/deploy tape) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iTapes], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iTapes]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_CRATE: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iCrateIsland] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked Crate Island Control from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iCrateIsland] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for Crate Island Control to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iCrateIsland], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iCrateIsland]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_DUTYCOL: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN],
					hColour;

				if(strlen(inputtext) > 6 || !IsHex(inputtext)) {
					format(szTitle, sizeof szTitle, "Sua mau truc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_DUTYCOL, DIALOG_STYLE_INPUT, szTitle, "Gia tri sai.\n\nNhap mau hex (vi du, BCA3FF). Mau nay dung nhan dien to chuc.", "Xac nhan", "Huy");
				}
				sscanf(inputtext, "h", hColour);
				if (hColour == 0xFFFFFF) {
					format(szTitle, sizeof szTitle, "Sua mau truc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_DUTYCOL, DIALOG_STYLE_INPUT, szTitle, "Khong duoc dung mau trang.\n\nNhap mau hex (vi du, BCA3FF). Mau nay dung nhan dien to chuc.", "Xac nhan", "Huy");
				}
				arrGroupData[iGroupID][g_hDutyColour] = hColour;
				foreach(new i: Player)
				{
					if (PlayerInfo[i][pMember] == iGroupID) SetPlayerToTeamColor(i);
				}

				format(string, sizeof(string), "%s has set the duty color to %x in %s (%d)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_hDutyColour], arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);

			}

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_RADIOCOL: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN],
					hColour;

				if(strlen(inputtext) > 6 || !IsHex(inputtext)) {
					format(szTitle, sizeof szTitle, "Sua mau radio {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_RADIOCOL, DIALOG_STYLE_INPUT, szTitle, "Gia tri sai.\n\nNhap mau hex (vi du, BCA3FF). Mau nay dung cho radio IC cua to chuc.", "Xac nhan", "Huy");
				}
				sscanf(inputtext, "h", hColour);
				arrGroupData[iGroupID][g_hRadioColour] = hColour;

				format(string, sizeof(string), "%s has set the radio color to %x in %s (%d)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_hRadioColour], arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);

			}

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITSTOCK: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN],
					iValue = strval(inputtext);

				if(isnull(inputtext) || iValue <= -1) {
					format(szTitle, sizeof szTitle, "Sua ton kho tu {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITSTOCK, DIALOG_STYLE_INPUT, szTitle, "Gia tri sai.\n\nNhap so luong. Ton kho tu dung cap vu khi, co the bo sung bang thung hang.", "Xac nhan", "Huy");
				}
				arrGroupData[iGroupID][g_iLockerStock] = iValue;

				format(string, sizeof(string), "%s has set the locker stock to %d in %s (%d)", GetPlayerNameEx(playerid), strval(inputtext), arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);

			}

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITWEPS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				szTitle[32 + GROUP_MAX_NAME_LEN];

			if(response) {
				SetPVarInt(playerid, "Group_EditWep", listitem);
				format(szTitle, sizeof szTitle, "Sua vu khi (%i) {%s}(%s)", listitem + 1, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITWEPID, DIALOG_STYLE_INPUT, szTitle, "Nhap ID vu khi (zero de xoa vu khi).", "Chon", "Huy");
			}
			else return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITWEPID: {

			new
				szTitle[32 + GROUP_MAX_NAME_LEN],
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				iWepID = GetPVarInt(playerid, "Group_EditWep");

			format(szTitle, sizeof szTitle, "Sua vu khi (%i) {%s}(%s)", iWepID + 1, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
			if(response) {

				new
					iValue = strval(inputtext);

				if(isnull(inputtext) || !(0 <= iValue <= 46)) {
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITWEPID, DIALOG_STYLE_INPUT, szTitle, "Vu khi sai.\n\nNhap ID vu khi (zero de xoa vu khi).", "Chon", "Huy");
				}

				for (new i; i < MAX_GROUP_WEAPONS; i++) {
					if (arrGroupData[iGroupID][g_iLockerGuns][i] == iValue && iValue != 0)
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITWEPID, DIALOG_STYLE_INPUT, szTitle, "Vu khi da co trong tu.\n\nNhap ID vu khi (zero de xoa vu khi).", "Chon", "Huy");
				}

				arrGroupData[iGroupID][g_iLockerGuns][iWepID] = iValue;

				format(string, sizeof(string), "%s has changed the locker weapon (slot %d) to %d (%s) in %s (%d)", GetPlayerNameEx(playerid), iWepID, iValue, Weapon_ReturnName(iValue), arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);

				if(iValue >= 1) {
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITCOST, DIALOG_STYLE_INPUT, szTitle, "Nhap gia (tuy chon) cua vu khi. Tru vao ton kho tu (hoac tien mat neu da dat).", "Chon", "Quay lai");
				}
			}

			new
				szDialog[(32 + 8) * MAX_GROUP_WEAPONS];

			arrGroupData[iGroupID][g_iLockerCost][iWepID] = 0;
			for(new i = 0; i != MAX_GROUP_WEAPONS; ++i) {
				if(arrGroupData[iGroupID][g_iLockerGuns][i]) format(szDialog, sizeof szDialog, "%s\n(%i) %s (gia: %i)", szDialog, arrGroupData[iGroupID][g_iLockerGuns][i], Weapon_ReturnName(arrGroupData[iGroupID][g_iLockerGuns][i]), arrGroupData[iGroupID][g_iLockerCost][i]);
				else strcat(szDialog, "\n(trong)");
			}
			DeletePVar(playerid, "Group_EditWep");
			format(szTitle, sizeof szTitle, "Sua vu khi to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
			return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITWEPS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
		}
		case DIALOG_GROUP_EDITCOST: {

			new
				szTitle[32 + GROUP_MAX_NAME_LEN],
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				iWepID = GetPVarInt(playerid, "Group_EditWep");

			DeletePVar(playerid, "Group_EditWep");

			if(response) {

				new
					iValue = strval(inputtext);

				if(isnull(inputtext) || iValue <= -1) {
					format(szTitle, sizeof szTitle, "Sua vu khi (%i) {%s}(%s)", iWepID + 1, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITCOST, DIALOG_STYLE_INPUT, szTitle, "Gia tri sai.\n\nNhap gia (tuy chon) cua vu khi. Tru vao ton kho tu (hoac tien mat neu da dat).", "Chon", "Quay lai");
				}
				arrGroupData[iGroupID][g_iLockerCost][iWepID] = iValue;

				format(string, sizeof(string), "%s has changed the weapon cost to %d in %s (%d)", GetPlayerNameEx(playerid), strval(inputtext));
				Log("logs/editgroup.log", string);

			}

			new
				szDialog[(32 + 8) * MAX_GROUP_WEAPONS];

			for(new i = 0; i != MAX_GROUP_WEAPONS; ++i) {
				if(arrGroupData[iGroupID][g_iLockerGuns][i]) format(szDialog, sizeof szDialog, "%s\n(%i) %s (gia: %i)", szDialog, arrGroupData[iGroupID][g_iLockerGuns][i], Weapon_ReturnName(arrGroupData[iGroupID][g_iLockerGuns][i]), arrGroupData[iGroupID][g_iLockerCost][i]);
				else strcat(szDialog, "\n(trong)");
			}
			format(szTitle, sizeof szTitle, "Sua vu khi to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
			return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITWEPS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
		}
		case DIALOG_GROUP_EDITDIVS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN];

				SetPVarInt(playerid, "Group_EditDiv", listitem);
				format(szTitle, sizeof szTitle, "Sua Division (%i) {%s}(%s)", listitem + 1, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITDIV, DIALOG_STYLE_INPUT, szTitle, "Nhap ten Division (hoac none de tat).", "Xac nhan", "Huy");
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITDIV: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				iDivID = GetPVarInt(playerid, "Group_EditDiv"),
				szTitle[32 + GROUP_MAX_NAME_LEN];

			if(response) {
				if(strlen(inputtext) >= GROUP_MAX_DIV_LEN) {
					format(szTitle, sizeof szTitle, "Sua Division (%i) {%s}(%s)", iDivID + 1, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITDIV, DIALOG_STYLE_INPUT, szTitle, "Ten phai ngan hon "#GROUP_MAX_DIV_LEN" ky tu.\n\nNhap ten Division (hoac none de tat).", "Xac nhan", "Huy");
				}
				arrGroupDivisions[iGroupID][iDivID][0] = 0;
				if(!isnull(inputtext)) mysql_escape_string(inputtext, arrGroupDivisions[iGroupID][iDivID]);
			}

			new
				szDialog[(GROUP_MAX_DIV_LEN + 8) * MAX_GROUP_DIVS];

			for(new i = 0; i != MAX_GROUP_DIVS; ++i) {
				format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i + 1, ((arrGroupDivisions[iGroupID][i][0]) ? (arrGroupDivisions[iGroupID][i]) : ("{AAAAAA}(chua dat){FFFFFF}")));
			}

			format(szTitle, sizeof szTitle, "Sua Division {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
			ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITDIVS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
			DeletePVar(playerid, "Group_EditDiv");
		}
		case DIALOG_GROUP_LOCKERS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				szTitle[32 + GROUP_MAX_NAME_LEN];

			if(response)
			{
				format(szTitle, sizeof szTitle, "Sua vi tri tu do {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				if (listitem == MAX_GROUP_LOCKERS)
				{
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_LOCKERDELETECONF, DIALOG_STYLE_MSGBOX, szTitle, "{FFFFFF}Ban chac muon xoa TAT CA tu do cua to chuc?", "Huy", "Xac nhan");
					return 1;
				}
				else
				{
					SetPVarInt(playerid, "Group_EditLocker", listitem);
					ShowPlayerDialogEx(playerid, DIALOG_GROUP_LOCKERACTION, DIALOG_STYLE_LIST, szTitle, "Den tu do\nChuyen tu den cho ban\nXoa tu do", "Chon", "Huy");
					return 1;
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_LOCKERACTION: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				iLocker = GetPVarInt(playerid, "Group_EditLocker");

			if(response)
			{
				if (listitem == 0)
				{
					Player_StreamPrep(playerid, arrGroupLockers[iGroupID][iLocker][g_fLockerPos][0], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][1], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][2], FREEZE_TIME);
					SetPlayerVirtualWorld(playerid, arrGroupLockers[iGroupID][iLocker][g_iLockerVW]);
				}
				if (listitem == 1)
				{
					GetPlayerPos(playerid, arrGroupLockers[iGroupID][iLocker][g_fLockerPos][0], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][1], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][2]);
					arrGroupLockers[iGroupID][iLocker][g_iLockerVW] = GetPlayerVirtualWorld(playerid);
					DestroyDynamic3DTextLabel(arrGroupLockers[iGroupID][iLocker][g_tLocker3DLabel]);
					DestroyDynamicArea(arrGroupLockers[iGroupID][iLocker][g_iLockerAreaID]);

					format(szMiscArray, sizeof szMiscArray, "%s Tu do\n{1FBDFF}Nhan ~k~~CONVERSATION_YES~ {FFFF00} de dung\n ID: %i", arrGroupData[iGroupID][g_szGroupName], arrGroupLockers[iGroupID][iLocker]);
					arrGroupLockers[iGroupID][iLocker][g_tLocker3DLabel] = CreateDynamic3DTextLabel(szMiscArray, arrGroupData[iGroupID][g_hDutyColour] * 256 + 0xFF, arrGroupLockers[iGroupID][iLocker][g_fLockerPos][0], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][1], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][2], 15.0, .testlos = 1, .worldid = arrGroupLockers[iGroupID][iLocker][g_iLockerVW]);
					arrGroupLockers[iGroupID][iLocker][g_iLockerAreaID] = CreateDynamicSphere(arrGroupLockers[iGroupID][iLocker][g_fLockerPos][0], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][1], arrGroupLockers[iGroupID][iLocker][g_fLockerPos][2], 3.0, .worldid = arrGroupLockers[iGroupID][iLocker][g_iLockerVW]);

					// Streamer_SetIntData(STREAMER_TYPE_AREA, arrGroupLockers[iGroupID][iLocker][g_iLockerAreaID], E_STREAMER_EXTRA_ID, iLocker);
				}
				else if (listitem == 2)
				{
					arrGroupLockers[iGroupID][iLocker][g_fLockerPos][0] = 0;
					arrGroupLockers[iGroupID][iLocker][g_fLockerPos][1] = 0;
					arrGroupLockers[iGroupID][iLocker][g_fLockerPos][2] = 0;
					arrGroupLockers[iGroupID][iLocker][g_iLockerVW] = 0;
					DestroyDynamic3DTextLabel(arrGroupLockers[iGroupID][iLocker][g_tLocker3DLabel]);
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa tu %d cua %s", iLocker, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_LISTPAY: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN];

				SetPVarInt(playerid, "Group_EditRank", listitem);
				format(szTitle, sizeof szTitle, "Sua rank (%i) {%s}(%s)", listitem, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITPAY, DIALOG_STYLE_INPUT, szTitle, "Nhap so tien luong cho rank nay.", "Dong y", "Huy");
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITPAY: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				iRankID = GetPVarInt(playerid, "Group_EditRank");

			if(response) {
				new szTitle[128];
				arrGroupData[iGroupID][g_iPaycheck][iRankID] = strval(inputtext);
				new
						szDialog[(GROUP_MAX_RANK_LEN + 8) * MAX_GROUP_RANKS];

				for(new i = 0; i != MAX_GROUP_RANKS; ++i) {
					format(szDialog, sizeof szDialog, "%s\nRank %i (%s):    $%s", szDialog, i, arrGroupRanks[iGroupID][i], number_format(arrGroupData[iGroupID][g_iPaycheck][i]));
				}

				format(szTitle, sizeof szTitle, "Sua luong to chuc {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				ShowPlayerDialogEx(playerid, DIALOG_GROUP_LISTPAY, DIALOG_STYLE_LIST, szTitle, szDialog, "Sua", "Huy");
				format(string, sizeof(string), "%s has changed the paycheck for rank %d (%s) to $%d in %s (%d)", GetPlayerNameEx(playerid), iRankID, arrGroupRanks[iGroupID][iRankID], strval(inputtext), iGroupID + 1);
				Log("logs/editgroup.log", string);
				return 1;
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITRANKS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN];

				SetPVarInt(playerid, "Group_EditRank", listitem);
				format(szTitle, sizeof szTitle, "Sua rank (%i) {%s}(%s)", listitem + 1, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITRANK, DIALOG_STYLE_INPUT, szTitle, "Nhap ten rank (hoac none de tat).", "Xac nhan", "Huy");
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITRANK: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				iRankID = GetPVarInt(playerid, "Group_EditRank"),
				szTitle[32 + GROUP_MAX_NAME_LEN];

			if(response) {
				if(strlen(inputtext) >= GROUP_MAX_RANK_LEN) {
					format(szTitle, sizeof szTitle, "Sua rank (%i) {%s}(%s)", iRankID + 1, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITRANK, DIALOG_STYLE_INPUT, szTitle, "Ten phai ngan hon "#GROUP_MAX_RANK_LEN" ky tu.\n\nNhap ten rank (hoac none de tat).", "Xac nhan", "Huy");
				}
				arrGroupRanks[iGroupID][iRankID][0] = 0;
				if(!isnull(inputtext)) mysql_escape_string(inputtext, arrGroupRanks[iGroupID][iRankID]);
			}

			new
				szDialog[(GROUP_MAX_RANK_LEN + 8) * MAX_GROUP_RANKS];

			for(new i = 0; i != MAX_GROUP_RANKS; ++i) {
				format(szDialog, sizeof szDialog, "%s\n(%i) %s", szDialog, i + 1, ((arrGroupRanks[iGroupID][i][0]) ? (arrGroupRanks[iGroupID][i]) : ("{BBBBBB}(chua dat){FFFFFF}")));
			}

			format(szTitle, sizeof szTitle, "Sua rank {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
			ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITRANKS, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
			DeletePVar(playerid, "Group_EditRank");
		}

		case DIALOG_GROUP_CRATEPOS: {
			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(!response) {

				new
					szText[84];

				GetPlayerPos(playerid, arrGroupData[iGroupID][g_fCratePos][0], arrGroupData[iGroupID][g_fCratePos][1], arrGroupData[iGroupID][g_fCratePos][2]);
				DestroyDynamic3DTextLabel(arrGroupData[iGroupID][g_tCrate3DLabel]);

				if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_CRIMINAL)
				{
					format(szText, sizeof(szText), "%s Diem giao Shipment\n{1FBDFF}/gdelivercrate", arrGroupData[iGroupID][g_szGroupName]);
				}
				else
				{
					format(szText, sizeof szText, "%s Diem giao thung\n{1FBDFF}/delivercrate", arrGroupData[iGroupID][g_szGroupName]);
				}
				arrGroupData[iGroupID][g_tCrate3DLabel] = CreateDynamic3DTextLabel(szText, arrGroupData[iGroupID][g_hDutyColour] * 256 + 0xFF, arrGroupData[iGroupID][g_fCratePos][0], arrGroupData[iGroupID][g_fCratePos][1], arrGroupData[iGroupID][g_fCratePos][2], 10.0, .testlos = 1, .streamdistance = 20.0);

				format(string, sizeof(string), "%s has changed the crate/shipment position to X:%f, Y:%f, Z:%f in %s (%d)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_fCratePos][0], arrGroupData[iGroupID][g_fCratePos][1], arrGroupData[iGroupID][g_fCratePos][2], arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_COSTTYPE: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {
				format(string, sizeof(string), "%s has changed the locker cost type to %s in %s (%d)", GetPlayerNameEx(playerid), inputtext, arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);
				arrGroupData[iGroupID][g_iLockerCostType] = listitem;
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_DISBAND: {

			if(!response && PlayerInfo[playerid][pAdmin] >= 1337) {

				new
					iGroupID = GetPVarInt(playerid, "Group_EditID");
				format(string, sizeof(string), "%s has disbanded %s (%d)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);
				Group_DisbandGroup(iGroupID);

			}
			return Group_ListGroups(playerid);
		}
		case DIALOG_GROUP_LOCKERDELETECONF: {

			if(!response) {

				new
					iGroupID = GetPVarInt(playerid, "Group_EditID");

				for (new i; i < MAX_GROUP_LOCKERS; i++)
				{
					arrGroupLockers[iGroupID][i][g_fLockerPos][0] = 0;
					arrGroupLockers[iGroupID][i][g_fLockerPos][1] = 0;
					arrGroupLockers[iGroupID][i][g_fLockerPos][2] = 0;
					DestroyDynamic3DTextLabel(arrGroupLockers[iGroupID][i][g_tLocker3DLabel]);
				}

				SendClientMessage(playerid, COLOR_WHITE, "Da xoa tat ca tu do cua to chuc.");
				format(string, sizeof(string), "%s has deleted all lockers of %s", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
				Log("logs/editgroup.log", string);

			}
			return Group_ListGroups(playerid);
		}
		case DIALOG_GROUP_JURISDICTION_ADD: {
			SetPVarInt(playerid, "Group_EditID", listitem);
			new iGroupID = GetPVarInt(playerid, "Group_EditID");
			if(response)
			{
				if(arrGroupData[iGroupID][g_iJCount] >= MAX_GROUP_JURISDICTIONS) return SendClientMessage(playerid, COLOR_GRAD2, "Loi: Khong the them tham quyen nua.");
				new szTitle[128], szDialog[2500];

				for(new i = 0; i < 161; ++i)
				{
					strunpack(areaName, AreaName[i], sizeof(areaName));
					strcat(szDialog, "\n"), strcat(szDialog, areaName);
				}

				format(szTitle, sizeof szTitle, "Them tham quyen {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				ShowPlayerDialogEx(playerid, DIALOG_GROUP_JURISDICTION_ADD2, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Quay lai");
			}
			else return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_JURISDICTION_ADD2: {
			new iGroupID = GetPVarInt(playerid, "Group_EditID");
			if(response)
			{
				new query[256];
				strunpack(areaName, AreaName[listitem], sizeof(areaName));
				mysql_format(MainPipeline, query, sizeof(query), "INSERT INTO `jurisdictions` (`id`, `GroupID`, `JurisdictionID`, `AreaName`) VALUES (NULL, %d, %d, '%s')", iGroupID, listitem,areaName);
				mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
				mysql_tquery(MainPipeline, "SELECT * FROM `jurisdictions`", "Group_QueryFinish", "ii", GROUP_QUERY_JURISDICTIONS, 0);
				strunpack(areaName, AreaName[listitem], sizeof(areaName));
				format(string, sizeof(string), "Da gan %s cho %s.", areaName, arrGroupData[iGroupID][g_szGroupName]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				format(string, sizeof(string), "%s has assigned %s to %s", GetPlayerNameEx(playerid), areaName, arrGroupData[iGroupID][g_szGroupName]);
				Log("logs/editgroup.log", string);
			}
			else return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_GARAGEPOS: {
			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(!response) {
				GetPlayerPos(playerid, arrGroupData[iGroupID][g_fGaragePos][0], arrGroupData[iGroupID][g_fGaragePos][1], arrGroupData[iGroupID][g_fGaragePos][2]);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vi tri garage den cho ban.");
				format(string, sizeof(string), "%s has changed the garage position to X:%f, Y:%f, Z:%f in %s (%d)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_fGaragePos][0], arrGroupData[iGroupID][g_fGaragePos][1], arrGroupData[iGroupID][g_fGaragePos][2], arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_TACKLEACCESS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iTackleAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has revoked tackle (/tackle) from group %d (%s)", GetPlayerNameEx(playerid), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
				default: {
					arrGroupData[iGroupID][g_iTackleAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for tackle (/tackle) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iTackleAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iTackleAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				}
			}
			Log("logs/editgroup.log", string);

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_WHEELCLAMPS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iWheelClamps] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for wheel clamps (/wheelclamp) to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iWheelClamps], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][g_iWheelClamps] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for wheel clamps (/wheelclamp) to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iWheelClamps], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iWheelClamps]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_DOCACCESS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iDoCAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for DoC Access to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iDoCAccess], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][g_iDoCAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for DoC Access to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iDoCAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iDoCAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_MEDICACCESS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_DIVS: {
					if(arrGroupData[iGroupID][g_iMedicAccess] == INVALID_DIVISION) return 1;
					format(string, sizeof(string), "%s has revoked Medic Access from division %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iMedicAccess], arrGroupDivisions[iGroupID][arrGroupData[iGroupID][g_iMedicAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
					arrGroupData[iGroupID][g_iMedicAccess] = INVALID_DIVISION;
				}
				default: {
					arrGroupData[iGroupID][g_iMedicAccess] = listitem;
					format(string, sizeof(string), "%s has set the division for Medic Access to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iMedicAccess], arrGroupDivisions[iGroupID][arrGroupData[iGroupID][g_iMedicAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_DMVACCESS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iDMVAccess] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for DMV Access to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iDMVAccess], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][g_iDMVAccess] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for DMV Access to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iDMVAccess], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iDMVAccess]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_TEMPNUMACCESS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][gTempNum] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for Temporary Number Access to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][gTempNum], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][gTempNum] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for Temporary Number Access to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][gTempNum], arrGroupRanks[iGroupID][arrGroupData[iGroupID][gTempNum]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_LEOARRESTACCESS: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][gLEOArrest] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for LEO Arrest Access to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][gLEOArrest], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][gLEOArrest] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for LEO Arrest Access to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][gLEOArrest], arrGroupRanks[iGroupID][arrGroupData[iGroupID][gLEOArrest]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_OOCCHAT: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iOOCChat] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for OOC Chat Access to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iOOCChat], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][g_iOOCChat] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for OOC Chat Access to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iOOCChat], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iOOCChat]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_OOCCOLOR: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN],
					hColour;

				if(strlen(inputtext) > 6 || !IsHex(inputtext)) {
					format(szTitle, sizeof szTitle, "Sua mau chat OOC {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
					return ShowPlayerDialogEx(playerid, DIALOG_GROUP_RADIOCOL, DIALOG_STYLE_INPUT, szTitle, "Gia tri sai.\n\nNhap mau hex (vi du, BCA3FF). Mau nay dung cho chat OOC.", "Xac nhan", "Huy");
				}
				sscanf(inputtext, "h", hColour);
				arrGroupData[iGroupID][g_hOOCColor] = hColour;

				format(string, sizeof(string), "%s has set the OOC Chat color to %x in %s (%d)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_hOOCColor], arrGroupData[iGroupID][g_szGroupName], iGroupID+1);
				Log("logs/editgroup.log", string);
			}

			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_LISTCLOTHES: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {

				new
					szTitle[32 + GROUP_MAX_NAME_LEN];

				SetPVarInt(playerid, "Group_EditRank", listitem);
				format(szTitle, sizeof szTitle, "Sua rank (%i) {%s}(%s)", listitem, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_EDITCLOTHES, DIALOG_STYLE_INPUT, szTitle, "Nhap skin ID cho rank nay.", "Dong y", "Huy");
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_EDITCLOTHES: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID"),
				iRankID = GetPVarInt(playerid, "Group_EditRank");

			if(response) {
				new szTitle[128];
				arrGroupData[iGroupID][g_iClothes][iRankID] = strval(inputtext);
				new
						szDialog[(GROUP_MAX_RANK_LEN + 8) * MAX_GROUP_RANKS];

				for(new i = 0; i != MAX_GROUP_RANKS; ++i) {
						format(szDialog, sizeof szDialog, "%s\nRank %i (%s): Skin ID:%i", szDialog, i, arrGroupRanks[iGroupID][i], arrGroupData[iGroupID][g_iClothes][i]);
				}

				format(szTitle, sizeof szTitle, "Sua quan ao {%s}(%s)", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				ShowPlayerDialogEx(playerid, DIALOG_GROUP_LISTCLOTHES, DIALOG_STYLE_LIST, szTitle, szDialog, "Sua", "Huy");
				format(string, sizeof(string), "%s has changed the skin ID for rank %d (%s) to $%d in %s (%d)", GetPlayerNameEx(playerid), iRankID, arrGroupRanks[iGroupID][iRankID], strval(inputtext), iGroupID + 1);
				Log("logs/editgroup.log", string);

				return 1;
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_TURFCAP: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iTurfCapRank] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for turf capping to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iTurfCapRank], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][g_iTurfCapRank] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for turf capping to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iTurfCapRank], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iTurfCapRank]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_POINTCAP: {

			new
				iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) switch(listitem) {
				case MAX_GROUP_RANKS: {
					arrGroupData[iGroupID][g_iPointCapRank] = INVALID_RANK;
					format(string, sizeof(string), "%s has set the minimum rank for point capping to %d (Disabled) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iPointCapRank], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
				default: {
					arrGroupData[iGroupID][g_iPointCapRank] = listitem;
					format(string, sizeof(string), "%s has set the minimum rank for point capping to %d (%s) in group %d (%s)", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_iPointCapRank], arrGroupRanks[iGroupID][arrGroupData[iGroupID][g_iPointCapRank]], iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
					Log("logs/editgroup.log", string);
				}
			}
			return Group_DisplayDialog(playerid, iGroupID);
		}
		case DIALOG_GROUP_CRIMETYPE:
		{
			new iGroupID = GetPVarInt(playerid, "Group_EditID");

			if(response) {
				arrGroupData[iGroupID][g_iCrimeType] = listitem;

				format(string, sizeof(string), "%s has set the crime group type to %s in group %d (%s)", GetPlayerNameEx(playerid), ReturnCrimeGroupType(listitem), iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
				Log("logs/editgroup.log", string);
			}
		}
		case G_LOCKER_DRUGS: {
			if(!response) return DeletePVar(playerid, "GSafe_Opt"), pc_cmd_locker(playerid, "");
			else {

				SetPVarInt(playerid, "GLocker_SID", listitem);
				format(szMiscArray, sizeof(szMiscArray), "Gang Safe | Sua: {FFFF00}%s", Drugs[listitem]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_LIST, szMiscArray, "Gui vao\nRut ra", "Chon", "Quay lai");
			}
		}
		/*case G_LOCKER_INGREDIENTS: {
			if(!response) return DeletePVar(playerid, "GSafe_Opt"), pc_cmd_locker(playerid, "");
			else {

				SetPVarInt(playerid, "GLocker_SID", listitem);
				format(szMiscArray, sizeof(szMiscArray), "Gang Safe | Editing: {FFFF00}%s", szIngredients[listitem]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_LIST, szMiscArray, "Deposit\nWithdraw", "Select", "Back");
			}
		}*/

		case DIALOG_GROUP_SACTIONTYPE:
		{
			if(!response)
			{
				return pc_cmd_locker(playerid, "");
			}
			switch(listitem)
			{
				case 0:
				{
					SetPVarInt(playerid, "GSafe_Action", 1);
					format(szMiscArray, sizeof(szMiscArray), "Nhap so luong can gui.");
				}
				case 1:
				{
					new iTemp = GetPVarInt(playerid, "GSafe_Opt");
					if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iWithdrawRank][GetSafeTakePerm(iTemp)])
					{
						SetPVarInt(playerid, "GSafe_Action", 2);
						format(szMiscArray, sizeof(szMiscArray), "Nhap so luong can rut.");
					}
					else
					{
						DeletePVar(playerid, "GSafe_Opt");
						return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen rut do khoi tu.");
					}

				}
			}
			return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONEXEC, DIALOG_STYLE_INPUT, "Ket bang nhom", szMiscArray, "Nhap", "Huy");
		}
		case DIALOG_GROUP_SACTIONEXEC:
		{
			new iGroupID = PlayerInfo[playerid][pMember];
			if(!response)
			{
				DeletePVar(playerid, "GSafe_Action");
				DeletePVar(playerid, "GSafe_Opt");
				return pc_cmd_locker(playerid, "");
			}
			if(response)
			{
				if(strval(inputtext) <= 0) return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONEXEC, DIALOG_STYLE_INPUT, "Ket bang nhom", "So luong phai lon hon 0.", "Nhap", "Huy");

				switch(GetPVarInt(playerid, "GSafe_Opt")) {

					case 0:
					{
						new amount = strval(inputtext);
						switch(GetPVarInt(playerid, "GSafe_Action"))
						{
							case 1:
							{
								if(strval(inputtext) <= GetPlayerCash(playerid))
								{
									arrGroupData[iGroupID][g_iBudget] += strval(inputtext);
									GivePlayerCash( playerid, -amount);
									format(szMiscArray, sizeof(szMiscArray), "%s has deposited $%i into the safe.", GetPlayerNameEx(playerid), strval(inputtext));
									GroupLog(iGroupID, szMiscArray);
									SendClientMessageEx(playerid, COLOR_WHITE, "Ban da gui $%i vao ket.", strval(inputtext));
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");
									OnPlayerStatsUpdate(playerid);
								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONEXEC, DIALOG_STYLE_INPUT, "Ket bang nhom", "So luong vuot qua so ban mang.\nHay nhap lai.", "Nhap", "Huy");
							}
							case 2:
							{
								if(strval(inputtext) <= arrGroupData[iGroupID][g_iBudget])
								{
									new iMoney = strval(inputtext);
									arrGroupData[iGroupID][g_iBudget] -= iMoney;
									GivePlayerCash(playerid, amount);
									format(szMiscArray, sizeof(szMiscArray), "%s has withdrawn $%s from the safe.", GetPlayerNameEx(playerid), number_format(iMoney));
									GroupLog(iGroupID, szMiscArray);
									format(szMiscArray, sizeof(szMiscArray), "Ban da rut $%s tu ket.", number_format(iMoney));
									format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s da rut $%s tien to chuc tu ket bang nhom", GetPlayerNameEx(playerid), number_format(iMoney));
									ABroadCast(COLOR_YELLOW, string, 2);
									SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");
								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_INPUT, "Ket bang nhom", "So luong vuot qua so trong ket.\nHay nhap lai.", "Nhap", "Huy");
							}
						}
					}
					case 1:
					{
						switch(GetPVarInt(playerid, "GSafe_Action"))
						{
							case 1:
							{
								if(strval(inputtext) <= PlayerInfo[playerid][pMats])
								{
									arrGroupData[iGroupID][g_iMaterials] += strval(inputtext);
									PlayerInfo[playerid][pMats] -= strval(inputtext);
									format(szMiscArray, sizeof(szMiscArray), "%s has deposited %i materials into the safe.", GetPlayerNameEx(playerid), strval(inputtext));
									GroupLog(iGroupID, szMiscArray);
									SendClientMessageEx(playerid, COLOR_WHITE, "Ban da gui %i vat lieu vao ket.", strval(inputtext));
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");
								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONEXEC, DIALOG_STYLE_INPUT, "Ket bang nhom", "So luong vuot qua so ban mang.\nHay nhap lai.", "Nhap", "Huy");
							}
							case 2:
							{
								if(strval(inputtext) <= arrGroupData[iGroupID][g_iMaterials])
								{
									arrGroupData[iGroupID][g_iMaterials] -= strval(inputtext);
									PlayerInfo[playerid][pMats] += strval(inputtext);
									format(szMiscArray, sizeof(szMiscArray), "%s has withdrawn %i materials from the safe.", GetPlayerNameEx(playerid), strval(inputtext));
									GroupLog(iGroupID, szMiscArray);
									SendClientMessageEx(playerid, COLOR_WHITE, "Ban da rut %i vat lieu tu ket.", strval(inputtext));
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");
								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_INPUT, "Ket bang nhom", "So luong vuot qua so trong ket.\nHay nhap lai.", "Nhap", "Huy");
							}
						}
					}
					case 2: {

						new iDrugID = GetPVarInt(playerid, "GLocker_SID");

						switch(GetPVarInt(playerid, "GSafe_Action")) {

							case 1: {

								if(strval(inputtext) <= PlayerInfo[playerid][pDrugs][iDrugID])	{

									arrGroupData[iGroupID][g_iDrugs][iDrugID] += strval(inputtext);
									PlayerInfo[playerid][pDrugs][iDrugID] -= strval(inputtext);
									format(szMiscArray, sizeof(szMiscArray), "%s has deposited %i grams of %s into the safe.", GetPlayerNameEx(playerid), strval(inputtext), Drugs[iDrugID]);
									GroupLog(iGroupID, szMiscArray);
									SendClientMessageEx(playerid, COLOR_WHITE, "Ban da gui %i gram %s vao ket.", strval(inputtext), Drugs[iDrugID]);
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");
									SaveGroup(iGroupID);

									pc_cmd_locker(playerid, "");

								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONEXEC, DIALOG_STYLE_INPUT, "Ket bang nhom", "So luong vuot qua so ban mang.\nHay nhap lai.", "Nhap", "Huy");
							}
							case 2:
							{
								if(strval(inputtext) <= arrGroupData[iGroupID][g_iDrugs][iDrugID])
								{
									arrGroupData[iGroupID][g_iDrugs][iDrugID] -= strval(inputtext);
									PlayerInfo[playerid][pDrugs][iDrugID] += strval(inputtext);
									format(szMiscArray, sizeof(szMiscArray), "%s has withdrawn %i grams of %s from the safe.", GetPlayerNameEx(playerid), strval(inputtext), Drugs[iDrugID]);
									GroupLog(iGroupID, szMiscArray);
									SendClientMessageEx(playerid, COLOR_WHITE, "Ban da rut %i gram %s tu ket.", strval(inputtext), Drugs[iDrugID]);
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");
									SaveGroup(iGroupID);

									pc_cmd_locker(playerid, "");
								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_INPUT, "Ket bang nhom", "So luong vuot qua so trong ket.\nHay nhap lai.", "Nhap", "Huy");
							}
						}
					}
					/*case 3: {
						new iIngredientID = GetPVarInt(playerid, "GLocker_SID");
						switch(GetPVarInt(playerid, "GSafe_Action")) {
							case 1: {
								if(strval(inputtext) <= PlayerInfo[playerid][p_iIngredient][iIngredientID]) {

									arrGroupData[iGroupID][g_iIngredients][iIngredientID] += strval(inputtext);
									PlayerInfo[playerid][p_iIngredient][iIngredientID] -= strval(inputtext);
									format(szMiscArray, sizeof(szMiscArray), "%s has deposited %i grams of %s into the safe.", GetPlayerNameEx(playerid), strval(inputtext), szIngredients[iIngredientID]);
									GroupLog(iGroupID, szMiscArray);
									format(szMiscArray, sizeof(szMiscArray), "You have deposited %i grams of %s into the safe.", strval(inputtext), szIngredients[iIngredientID]);
									SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");

									format(szMiscArray, sizeof(szMiscArray), "UPDATE `groups` SET `%s` = '%d' WHERE `id` = '%d'", DS_Ingredients_GetSQLName(iIngredientID), arrGroupData[iGroupID][g_iIngredients][iIngredientID], iGroupID + 1);
									mysql_tquery(MainPipeline, szMiscArray, false, "OnQueryFinish", "i", SENDDATA_THREAD);

									pc_cmd_locker(playerid, "");
								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONEXEC, DIALOG_STYLE_INPUT, "Gang Safe", "The amount specified exceeds that that you have on you.\nPlease input another amount.", "Input", "Cancel");
							}
							case 2:
							{
								if(strval(inputtext) <= arrGroupData[iGroupID][g_iIngredients][iIngredientID]) {

									arrGroupData[iGroupID][g_iIngredients][iIngredientID] -= strval(inputtext);
									PlayerInfo[playerid][p_iIngredient][iIngredientID] += strval(inputtext);
									format(szMiscArray, sizeof(szMiscArray), "%s has withdrawn %i grams of %s from the safe.", GetPlayerNameEx(playerid), strval(inputtext), szIngredients[iIngredientID]);
									GroupLog(iGroupID, szMiscArray);
									format(szMiscArray, sizeof(szMiscArray), "You have withdrawn %i grams of %s from the safe.", strval(inputtext), szIngredients[iIngredientID]);
									SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
									DeletePVar(playerid, "GSafe_Action");
									DeletePVar(playerid, "GSafe_Opt");

									format(szMiscArray, sizeof(szMiscArray), "UPDATE `groups` SET `%s` = '%d' WHERE `id` = '%d'", DS_Ingredients_GetSQLName(iIngredientID), arrGroupData[iGroupID][g_iIngredients][iIngredientID], iGroupID + 1);
									mysql_tquery(MainPipeline, szMiscArray, false, "OnQueryFinish", "i", SENDDATA_THREAD);

									pc_cmd_locker(playerid, "");
								}
								else return ShowPlayerDialogEx(playerid, DIALOG_GROUP_SACTIONTYPE, DIALOG_STYLE_INPUT, "Gang Safe", "The amount specified exceeds that in the safe.\nPlease input another amount.", "Input", "Cancel");
							}
						}
					}*/
				}
				SaveGroup(iGroupID);
			}
		}
		case DIALOG_GROUP_WEAPONSAFE, DIALOG_GROUP_WEAPONSAFE_DEPOSIT,
			DIALOG_WEAPONSAFE_WITHDRAW, DIALOG_WEAPONSAFE_WITHDRAW_T: return 1;

		case DIALOG_GROUP_TURNOUT:
		{
			if(!response) return 1;
			new closestCar = GetClosestCar(playerid, .fRange = 8.0);
			if(closestCar == INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe nao!");
			ClearAnimationsEx(playerid);
			if(listitem == 0)
			{
				if(IsACop(playerid) && IsACopCar(closestCar)) SetPlayerSkin(playerid, 285); // SWAT
				else if(IsAMedic(playerid) && IsAnAmbulance(closestCar)) SetPlayerSkin(playerid, 277); // LS Fire
				else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe to chuc!");
			}
			if(listitem == 1 || listitem == 3)
			{
				if(IsACop(playerid) || listitem == 3) // Original Clothes
				{
					if(!GetPVarType(playerid, "turnoutVeh")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua mac do Turnout!");
					if(!IsPlayerInRangeOfVehicle(playerid, GetPVarInt(playerid, "turnoutVeh"), 8.0)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe da lay quan ao.");
					DeletePVar(playerid, "turnoutVeh");
					SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					SendClientMessageEx(playerid, -1, "Ban da mac lai quan ao cu.");
					return 1;
				}
				if(IsAnAmbulance(closestCar)) SetPlayerSkin(playerid, 279); // SF Fire
				else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe to chuc!");
			}
			if(listitem == 2)
			{
				if(IsAnAmbulance(closestCar)) SetPlayerSkin(playerid, 278); // LV Fire
				else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe to chuc!");
			}
			SetPVarInt(playerid, "turnoutVeh", closestCar);
			return 1;
		}
		// END DYNAMIC GROUP CODE
	}
	return 0;
}

hook OnVehicleSpawn(vehicleid)
{
	foreach(new playerid : Player)
	{
		if(SpikeVehicle[playerid] == vehicleid) SpikeVehicle[playerid] = 0;
	}

	if(GetGVarType("VehSiren", vehicleid)) ToggleSiren(vehicleid, 1);
}

public OnVehicleSirenStateChange(playerid, vehicleid, newstate)
{
	if(DynVeh[vehicleid] != -1)
	{
		for(new i = 0; i != MAX_DV_OBJECTS; i++)
		{
			ToggleDVSiren(DynVeh[vehicleid], i, newstate);
		}
	}
	switch(newstate)
	{
		case 0: ToggleSiren(vehicleid, 1);
		case 1:
		{
			if(!GetGVarType("VehSiren", vehicleid)) ToggleSiren(vehicleid, 0);
		}
	}
    return 1;
}

stock EditDV(playerid, iDvSlotID, params[], const name[], Float:value, &slot)
{
	new string[128];
	format(string, sizeof(string), "%s has edited DV Slot %d - %s.", GetPlayerNameEx(playerid), iDvSlotID, params);
	Log("logs/dv.log", string);
	if(strcmp(name, "siren", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_iSiren] = !DynVehicleInfo[iDvSlotID][gv_iSiren];
		DynVeh_Save(iDvSlotID);
		DynVeh_Spawn(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, DynVehicleInfo[iDvSlotID][gv_iSiren] ? ("Da bat coi hut cho xe dong."):("Da tat coi hut cho xe dong."));
		return 1;
	}
	if(strcmp(name, "delete", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_iModel] = 0;
		DynVehicleObjInfo[iDvSlotID][0][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
		DynVehicleObjInfo[iDvSlotID][1][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
		DynVehicleObjInfo[iDvSlotID][2][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
		DynVehicleObjInfo[iDvSlotID][3][gv_iAttachedObjectModel] = INVALID_OBJECT_ID;
		DynVehicleInfo[iDvSlotID][gv_igID] = INVALID_GROUP_ID;
		DynVehicleInfo[iDvSlotID][gv_igDivID] = 0;
		DynVehicleInfo[iDvSlotID][gv_fMaxHealth] = 1000;
		DynVehicleInfo[iDvSlotID][gv_iUpkeep] = 0;
		DynVehicleInfo[iDvSlotID][gv_iSiren] = 0;
		DynVeh_Save(iDvSlotID);
		DynVeh_Spawn(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa xe dong");
		return 1;
	}
	if(strcmp(name, "vw", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_iVW] = floatround(value);
		DynVeh_Save(iDvSlotID);
		DynVeh_Spawn(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi virtual world xe dong");
		return 1;
	}
	if(strcmp(name, "disabled", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_iDisabled] = floatround(value);
		DynVeh_Save(iDvSlotID);
		DynVeh_Spawn(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da vo hieu hoa xe dong");
		return 1;
	}
	if(strcmp(name, "vmodel", true) == 0)
	{
		if(!(400 < value < 612)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Model ID khong hop le");
		DynVehicleInfo[iDvSlotID][gv_iModel] = floatround(value);
		DynVeh_Save(iDvSlotID);
		DynVeh_Spawn(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi model xe dong");
		return 1;
	}
	if(strcmp(name, "vcol1", true) == 0)
	{
		if(!(0 <= value <= 255)) {
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
		}
		DynVehicleInfo[iDvSlotID][gv_iCol1] = floatround(value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau (1) xe dong");
		return 1;
	}
	if(strcmp(name, "vcol2", true) == 0)
	{
		if(!(0 <= value <= 255)) {
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
		}
		DynVehicleInfo[iDvSlotID][gv_iCol2] = floatround(value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau (2) xe dong");
		return 1;
	}
	if(strcmp(name, "groupid", true) == 0)
	{
		if(value == 0)
		{
			DynVehicleInfo[iDvSlotID][gv_igID] = INVALID_GROUP_ID;
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da go co group id cua xe dong");
			return 1;
		}
		if(!(0 <= value < MAX_GROUPS)) return SendClientMessageEx(playerid, COLOR_GRAD2, "To chuc sai (tu 1 den "#MAX_GROUPS")");
		DynVehicleInfo[iDvSlotID][gv_igID] = floatround(value-1);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi co group id xe dong");
		return 1;
	}
	if(strcmp(name, "divid", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_igDivID] = floatround(value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi division id xe dong");
		return 1;
	}
	if(strcmp(name, "rank", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_irID] = floatround(value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi rank id xe dong");
		return 1;
	}
	if(strcmp(name, "loadmax", true) == 0)
	{
		if(!(0 < value < 6)) return SendClientMessageEx(playerid, COLOR_GRAD2, "To chuc sai (tu 1 den 6)");
		DynVehicleInfo[iDvSlotID][gv_iLoadMax] = floatround(value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi gioi han tai xe dong");
		return 1;
	}
	if(strcmp(name, "maxhealth", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_fMaxHealth] = (value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau toi da xe dong");
		return 1;
	}
	if(strcmp(name, "upkeep", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_iUpkeep] = floatround(value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi phi duy tri xe dong");
		return 1;
	}
	if(strcmp(name, "vtype", true) == 0)
	{
		DynVehicleInfo[iDvSlotID][gv_iType] = floatround(value);
		DynVeh_Save(iDvSlotID);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai xe dong");
		return 1;
	}
	if(1 <= slot <= MAX_DV_OBJECTS)
	{
		if(strcmp(name, "objmodel", true) == 0)
		{
			if(slot == 3 || slot == 4)
			{
				if(floatround(value) != 0 && !IsABlankTexture(floatround(value))) return SendClientMessageEx(playerid, COLOR_GREY, "O object DV 3 va 4 chi nhan model 19475-19483");
			}
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_iAttachedObjectModel] = floatround(value);
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi model object xe dong");
			return 1;
		}
		if(strcmp(name, "objx", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectX] = value;
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vi tri object (X) xe dong");
			return 1;
		}
		if(strcmp(name, "objy", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectY] = value;
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vi tri object (Y) xe dong");
			return 1;
		}
		if(strcmp(name, "objz", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectZ] = value;
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vi tri object (Z) xe dong");
			return 1;
		}
		if(strcmp(name, "objrx", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectRX] = value;
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi goc object (X) xe dong");
			return 1;
		}
		if(strcmp(name, "objry", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectRY] = value;
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi goc object (Y) xe dong");
			return 1;
		}
		if(strcmp(name, "objrz", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectRZ] = value;
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi goc object (Z) xe dong");
			return 1;
		}
		if(strcmp(name, "objmatsize", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectMatSize] = floatround(value);
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi kich thuoc material xe dong");
			return 1;
		}
		if(strcmp(name, "objsize", true) == 0)
		{
			DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectSize] = floatround(value);
			DynVeh_Spawn(iDvSlotID);
			DynVeh_Save(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi co chu object xe dong");
			return 1;
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Slot ID phai tu 1 den "#MAX_DV_OBJECTS"!");
	return 1;
}

stock IsABlankTexture(modelid)
{
	switch(modelid)
	{
		case 19475, 19476, 19477, 19478, 19479, 19480, 19481, 19482, 19483: return 1;
	}
	return 0;
}

CMD:clearbugs(playerid, params[])
{
	if(IsACop(playerid))
	{
		if(PlayerInfo[playerid][pLeader] == PlayerInfo[playerid][pMember] && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBugAccess]) // has leader flag
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, "Da huy het may nghe len cua co quan.");
			foreach(new i : Player)
			{
				if(PlayerInfo[i][pBugged] == PlayerInfo[playerid][pMember]){
					PlayerInfo[i][pBugged] = INVALID_GROUP_ID;
				}
			}
			new query[256];
			mysql_format(MainPipeline, query, sizeof(query), "UPDATE accounts SET `Bugged` = %d WHERE `Bugged` > %d AND `Online` = 0", INVALID_GROUP_ID, INVALID_GROUP_ID);
			mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
			return 1;
		}
	}
	return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
}

CMD:listbugs(playerid, params[])
{
	if(IsACop(playerid))
	{
		if(PlayerInfo[playerid][pLeader] == PlayerInfo[playerid][pMember] && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBugAccess]) // has leader flag
		{
			SendClientMessageEx(playerid, COLOR_GREEN, "Danh sach may nghe len da dat:");
			foreach(new i : Player)
			{
				if(PlayerInfo[i][pBugged] == PlayerInfo[playerid][pMember]){
					SendClientMessageEx(playerid, COLOR_GREEN, GetPlayerNameEx(i));
				}
			}
			new query[256];
			mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username`, `Bugged` FROM `accounts`  WHERE `Bugged` = %d AND `Online` = 0", PlayerInfo[playerid][pMember]);
			mysql_tquery(MainPipeline, query, "OnQueryFinish", "iii", BUG_LIST_THREAD, playerid, g_arrQueryHandle[playerid]);
			return 1;
		}
	}
	return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
}

CMD:online(playerid, params[]) {
	if(PlayerInfo[playerid][pLeader] >= 0 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 1 || IsACriminal(playerid))
	{
		if(PlayerInfo[playerid][pMember] == INVALID_GROUP_ID) return SendClientMessageEx(playerid, -1, "Ban khong thuoc to chuc nao!");
		szMiscArray[0] = 0;
		new badge[11];
		foreach(new i: Player)
		{
			if(PlayerInfo[i][pAdmin] >= 2 && PlayerInfo[i][pTogReports] == 0) goto end;
			if(strcmp(PlayerInfo[i][pBadge], "None", true) != 0) format(badge, sizeof(badge), "[%s] ", PlayerInfo[i][pBadge]);
			else format(badge, sizeof(badge), "");
			if(IsAnFTSDriver(playerid) && IsAnFTSDriver(i)) switch(TransportDuty[i]) {
				case 1: format(szMiscArray, sizeof(szMiscArray), "%s\n* %s%s (truc), %i cuoc da nhan", szMiscArray, badge, GetPlayerNameEx(i), PlayerInfo[i][pCallsAccepted]);
				default: format(szMiscArray, sizeof(szMiscArray), "%s\n* %s%s (nghi), %i cuoc da nhan", szMiscArray, badge, GetPlayerNameEx(i), PlayerInfo[i][pCallsAccepted]);
			}
			else if(IsAMedic(playerid) && IsAMedic(i) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == arrGroupData[PlayerInfo[i][pMember]][g_iAllegiance])) switch(PlayerInfo[i][pDuty]) {
				case 1: format(szMiscArray, sizeof(szMiscArray), "%s\n* %s%s (truc), %i cuoc da nhan, %i ca da giao.", szMiscArray, badge, GetPlayerNameEx(i), PlayerInfo[i][pCallsAccepted], PlayerInfo[i][pPatientsDelivered]);
				default: format(szMiscArray, sizeof(szMiscArray), "%s\n* %s%s (nghi), %i cuoc da nhan, %i ca da giao.", szMiscArray, badge, GetPlayerNameEx(i), PlayerInfo[i][pCallsAccepted], PlayerInfo[i][pPatientsDelivered]);
			}
			else if(IsACriminal(playerid) && PlayerInfo[i][pMember] == PlayerInfo[playerid][pMember]) {
				format(szMiscArray, sizeof(szMiscArray), "* %s | Rank: %s (%d) | Division: %s", GetPlayerNameEx(i), arrGroupRanks[PlayerInfo[i][pMember]][PlayerInfo[i][pRank]], PlayerInfo[i][pRank], PlayerInfo[i][pDivision] != INVALID_DIVISION ? arrGroupDivisions[PlayerInfo[i][pMember]][PlayerInfo[i][pDivision]] : ("N/A"));
				SendClientMessageEx(playerid, -1, szMiscArray);
			}
			else if(PlayerInfo[i][pMember] == PlayerInfo[playerid][pMember]) switch(PlayerInfo[i][pDuty]) {
				case 1: format(szMiscArray, sizeof(szMiscArray), "%s\n* %s%s (truc)", szMiscArray, badge, GetPlayerNameEx(i));
				default: format(szMiscArray, sizeof(szMiscArray), "%s\n* %s%s (het truc)", szMiscArray, badge, GetPlayerNameEx(i));
			}
			end:
		}
		if(!isnull(szMiscArray)) {
			if(!IsACriminal(playerid)) strdel(szMiscArray, 0, 1), ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_LIST, "Thanh vien online", szMiscArray, "Chon", "Huy");
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Chua co thanh vien online.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Chi lanh dao to chuc duoc dung lenh nay.");
	return 1;
}

CMD:badge(playerid, params[]) {
    if(PlayerInfo[playerid][pMember] >= 0 && arrGroupData[PlayerInfo[playerid][pMember]][g_hDutyColour] != 0xFFFFFF && arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] != GROUP_TYPE_CRIMINAL)
	{
		if(GetPVarType(playerid, "IsInArena") || PlayerInfo[playerid][pJailTime] > 0 || GetPVarInt(playerid, "EventToken") != 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung phu hieu.");
			return 1;
		}
		#if defined zombiemode
		if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the dung.");
		#endif
		if(PlayerInfo[playerid][pDuty]) {
			PlayerInfo[playerid][pDuty] = 0;
			SetPlayerToTeamColor(playerid);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da an phu hieu, ban duoc xem la het truc.");
			if(IsAMedic(playerid) || IsFirstAid(playerid))
			{
				Medics -= 1;
			}
		}
		else {
			PlayerInfo[playerid][pDuty] = 1;
			SetPlayerToTeamColor(playerid);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da hien phu hieu, ban duoc xem la dang truc.");
			if(IsAMedic(playerid) || IsFirstAid(playerid))
			{
				Medics += 1;
			}
		}
	}
	return 1;
}

CMD:viewbudget(playerid, params[])
{
	new i = PlayerInfo[playerid][pMember];
	new string[128];
	if(arrGroupData[i][g_iGroupType] == GROUP_TYPE_GOV ||arrGroupData[i][g_iGroupType] == GROUP_TYPE_LEA || arrGroupData[i][g_iGroupType] == GROUP_TYPE_MEDIC || arrGroupData[i][g_iGroupType] == GROUP_TYPE_JUDICIAL || arrGroupData[i][g_iGroupType] == GROUP_TYPE_TAXI || arrGroupData[i][g_iGroupType] == GROUP_TYPE_NEWS || arrGroupData[i][g_iGroupType] == GROUP_TYPE_CONTRACT || arrGroupData[i][g_iGroupType] == GROUP_TYPE_TOWING)
	{
	    SendClientMessage(playerid, 0x008EFC00, "            BANG CAN DOI            ");
		if(arrGroupData[i][g_szGroupName][0] && arrGroupData[i][g_hDutyColour] != 0) format(string, sizeof(string), "{%6x}%s {AFAFAF} [So du: $%s] [Tra moi gio: $%s]| ", arrGroupData[i][g_hDutyColour], arrGroupData[i][g_szGroupName], number_format(arrGroupData[i][g_iBudget]), number_format(arrGroupData[i][g_iBudgetPayment]));
		else if(arrGroupData[i][g_szGroupName][0]) format(string, sizeof(string), "%s [So du: $%s] [Tra moi gio: $%s]| ", arrGroupData[i][g_szGroupName], number_format(arrGroupData[i][g_iBudget]), number_format(arrGroupData[i][g_iBudgetPayment]));
		SendClientMessage(playerid, COLOR_YELLOW, string);
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "Co quan khong nhan ngan sach chinh phu.");
	return 1;
}

CMD:setbudget(playerid, params[])
{
	szMiscArray[0] = 0;
	new iGroupID;
	if(arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_GOV)
	{
	    if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iTreasuryAccess] && IsGroupLeader(playerid))
	    {
		    new
				iBudgetAmt,
				string[128];

			if(sscanf(params, "iii", iGroupID, iBudgetAmt))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setbudget [Group ID] [$ Per Budget Payment (Hourly)]");
				for(new i = 0; i < MAX_GROUPS; i++)
				{
				    if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == arrGroupData[i][g_iAllegiance])
				    {
					    if(arrGroupData[i][g_iGroupType] == GROUP_TYPE_LEA || arrGroupData[i][g_iGroupType] == GROUP_TYPE_MEDIC || arrGroupData[i][g_iGroupType] == GROUP_TYPE_JUDICIAL || arrGroupData[i][g_iGroupType] == GROUP_TYPE_TAXI || arrGroupData[i][g_iGroupType] == GROUP_TYPE_TOWING)
					    {
						    if(arrGroupData[i][g_szGroupName][0] && arrGroupData[i][g_hDutyColour] != 0) format(string, sizeof(string), "%d - {%6x}%s {AFAFAF} [So du: $%s] [Ngan sach: $%s]| ", i, arrGroupData[i][g_hDutyColour], arrGroupData[i][g_szGroupName], number_format(arrGroupData[i][g_iBudget]), number_format(arrGroupData[i][g_iBudgetPayment]));
							else if(arrGroupData[i][g_szGroupName][0]) format(string, sizeof(string), "%d - %s [So du: $%s] [Ngan sach: $%s]| ", i, arrGroupData[i][g_szGroupName], number_format(arrGroupData[i][g_iBudget]), number_format(arrGroupData[i][g_iBudgetPayment]));
							SendClientMessageEx(playerid, COLOR_GRAD2, string);
						}
					}
				}
				return 1;
			}
			if(0 <= iGroupID < MAX_GROUPS && (arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_LEA || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_MEDIC || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_JUDICIAL || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_TAXI || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_TOWING))
			{
			    if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == arrGroupData[iGroupID][g_iAllegiance])
			    {
					arrGroupData[iGroupID][g_iBudgetPayment] = iBudgetAmt;
					format(string, sizeof(string), "Da dat ngan sach %s thanh $%s moi gio, dung tra phi xe, vu khi va nhan su", arrGroupData[iGroupID][g_szGroupName], number_format(iBudgetAmt));
					SendClientMessage(playerid, COLOR_GRAD1, string);
					format(szMiscArray, sizeof(szMiscArray), "%s has changed %s's hourly pay to $%s", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName], number_format(iBudgetAmt));
					GroupPayLog(PlayerInfo[playerid][pMember], szMiscArray);
				}
				else return SendClientMessage(playerid, COLOR_GRAD2, "Co quan nay khong thuoc chinh phu cua ban.");
			}
			else return SendClientMessage(playerid, COLOR_GRAD2, "ID to chuc khong hop le");
	    }
	    else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai la lanh dao va du rank de truy cap ngan quy.");
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong phai Government Official!");
	return 1;
}

CMD:gwithdraw(playerid, params[])
{
	new iGroupID;
	new string[128], amount, reason[64];
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		if(sscanf(params, "dds[64]", iGroupID, amount, reason))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gwithdraw [groupid] [amount] [reason]");
			return 1;
		}
		if(!(-1 < iGroupID <= MAX_GROUPS))
		{
			SendClientMessageEx(playerid, COLOR_RED, "* ID to chuc khong hop le");
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gwithdraw [groupid] [amount] [reason]");
			return 1;
		}
	}
	else if(-1 < PlayerInfo[playerid][pLeader] <= MAX_GROUPS)
	{
		iGroupID = PlayerInfo[playerid][pLeader];
		if(sscanf(params, "ds[64]", amount, reason))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gwithdraw [amount] [reason]");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET: $%s.", number_format(arrGroupData[iGroupID][g_iBudget]));
			return 1;
		}
	}
	else return SendClientMessage(playerid, COLOR_GRAD3, " Ban khong phai lanh dao hoac admin co quyen. ");


	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pLeader] != iGroupID) iGroupID--;
	if(amount < 0)
	{
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "So luong khong hop le.");
		return 1;
	}
	if( arrGroupData[iGroupID][g_iBudget] > amount )
	{
		arrGroupData[iGroupID][g_iBudget] -= amount;
    	new str[128];
        format(str, sizeof(str), "%s has withdrawn $%d from %s's Budget Fund - reason: %s", GetPlayerNameEx(playerid), amount, arrGroupData[iGroupID][g_szGroupName], reason);
		GroupPayLog(iGroupID, str);
        Misc_Save();
        SaveGroup(iGroupID);
		GivePlayerCash( playerid, amount );
		SendClientMessageEx( playerid, COLOR_WHITE, "Ban da rut $%d tu quy to chuc.", amount );
		format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s da rut $%s tien to chuc tu quy, ly do: %s.", GetPlayerNameEx(playerid), number_format(amount), reason);
		ABroadCast( COLOR_YELLOW, string, 2);
 		format(string,sizeof(string),"%s(%d) has withdrawn $%s of the group money from %s's vault, reason: %s.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), number_format(amount),arrGroupData[iGroupID][g_szGroupName],reason);
		Log("logs/rpspecial.log", string);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Khong du so du.");
	}
	return 1;
}

CMD:gdonate(playerid, params[])
{
	new iGroupID = PlayerInfo[playerid][pMember];
	if((0 <= iGroupID <= MAX_GROUPS))
	{
		if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_LEA || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_MEDIC || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_JUDICIAL || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_TAXI || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_NEWS || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_TOWING || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_CONTRACT || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_GOV)
		{
			new string[128], moneys;
			if(sscanf(params, "d", moneys)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gdonate [amount]");

			if(moneys < 1)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "So luong qua it.");
				return 1;
			}
			if(GetPlayerCash(playerid) < moneys)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du tien.");
				return 1;
			}
			GivePlayerCash(playerid, -moneys);
			arrGroupData[iGroupID][g_iBudget] += moneys;
			new str[128];
            format(str, sizeof(str), "%s has donated $%s to %s budget fund.", GetPlayerNameEx(playerid), number_format(moneys), arrGroupData[iGroupID][g_szGroupName]);
			GroupPayLog(iGroupID, str);
			SaveGroup(iGroupID);
			OnPlayerStatsUpdate(playerid);
			format(string, sizeof(string), "%s, ban da ung ho $%s vao ngan sach co quan.",GetPlayerNameEx(playerid), number_format(moneys));
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessageEx(playerid, COLOR_GRAD1, string);
			format(string, sizeof(string), "%s(%d) has donated $%s to %s's budget vault.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), number_format(moneys), arrGroupData[iGroupID][g_szGroupName]);
			Log("logs/pay.log", string);
			return 1;
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GRAD2,  "Ban khong thuoc co quan chinh phu!");
		}
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong thuoc to chuc.");
	}
	return 1;
}

CMD:dvtrackcar(playerid, params[])
{
    new iGroupID = PlayerInfo[playerid][pMember];

	if((0 <= iGroupID <= MAX_GROUPS))
	{
		new vstring[2500];
		for(new i; i < MAX_DYNAMIC_VEHICLES; i++) {
			new iModelID = DynVehicleInfo[i][gv_iModel];
			if(400 <= iModelID < 612 && DynVehicleInfo[i][gv_igID] == iGroupID) {
				new vehicleName[18];
				if(DynVehicleInfo[i][gv_iDisabled] == 1) {
					strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
					format(vstring, sizeof(vstring), "%s\n(%d)%s (Phi: $%s) (tich thu)", vstring, i, vehicleName, number_format(DynVehicleInfo[i][gv_iUpkeep]));
				}
				else if(DynVehicleInfo[i][gv_iDisabled] == 2) {
					strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
					format(vstring, sizeof(vstring), "%s\n(%d)%s (Phi: $%s) (luu kho)", vstring, i, vehicleName, number_format(DynVehicleInfo[i][gv_iUpkeep]));
				}
				else if(DynVehicleInfo[i][gv_iSpawnedID] != INVALID_VEHICLE_ID) {
					strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
					format(vstring, sizeof(vstring), "%s\n(%d) %s (Phi: $%s) (VID: %d)", vstring, i, vehicleName, number_format(DynVehicleInfo[i][gv_iUpkeep]), DynVehicleInfo[i][gv_iSpawnedID]);
				}
			}
		}
		ShowPlayerDialogEx(playerid, DV_TRACKCAR, DIALOG_STYLE_LIST, "Theo doi GPS xe", vstring, "Theo doi", "Huy");
	}
	return 1;
}

CMD:grepocars(playerid, params[])
{
	new iGroupID = PlayerInfo[playerid][pMember];
	if((0 <= iGroupID <= MAX_GROUPS) && PlayerInfo[playerid][pRank] == Group_GetMaxRank(iGroupID))
	{
	    SendClientMessageEx(playerid, COLOR_GREEN, "Xe co quan bi tich thu:");
	    SendClientMessageEx(playerid, COLOR_GRAD4, "CHU Y: Dung /gvbuyback de chuoc xe khi co quan du tien.");
	    for(new iDvSlotID = 0; iDvSlotID < MAX_DYNAMIC_VEHICLES; iDvSlotID++)
		{
		    if(DynVehicleInfo[iDvSlotID][gv_igID] != INVALID_GROUP_ID && DynVehicleInfo[iDvSlotID][gv_igID] == iGroupID)
		    {
			    if(DynVehicleInfo[iDvSlotID][gv_iModel] != 0 && (400 < DynVehicleInfo[iDvSlotID][gv_iModel] < 612))
			    {
			        if(DynVehicleInfo[iDvSlotID][gv_iDisabled] == 1)
			        {
			            new vehicleName[18];
			            strunpack(vehicleName, VehicleName[DynVehicleInfo[iDvSlotID][gv_iModel] - 400], sizeof(vehicleName));
			            SendClientMessageEx(playerid, COLOR_GRAD1, "ID xe: %d - %s - Gia chuoc $%d.", iDvSlotID, vehicleName, floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2), floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] / 2));
					}
			    }
			}
		}
	}
	else SendClientMessage(playerid, COLOR_GRAD2, " Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:gvbuyback(playerid, params[])
{
	new iVehicle[6];
	new iGroupID = PlayerInfo[playerid][pLeader];
	if((0 <= iGroupID <= MAX_GROUPS) && PlayerInfo[playerid][pRank] == Group_GetMaxRank(iGroupID))
	{
		new vehicleName[18];
		if(sscanf(params, "s[6]", iVehicle)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gvbuyback [ID/all] *Chuoc mot xe hoac tat ca xe bi tich thu.");
			return SendClientMessageEx(playerid, COLOR_GREY, "Chu y: Xem ID tai /grepocars");
		}
		if(strcmp(iVehicle, "all", true) == 0)
		{
			for(new iDvSlotID = 0; iDvSlotID < MAX_DYNAMIC_VEHICLES; iDvSlotID++)
			{
				if(DynVehicleInfo[iDvSlotID][gv_igID] != INVALID_GROUP_ID && DynVehicleInfo[iDvSlotID][gv_igID] == iGroupID)
				{
					if(DynVehicleInfo[iDvSlotID][gv_iModel] != 0 && (400 < DynVehicleInfo[iDvSlotID][gv_iModel] < 612))
					{
						if(DynVehicleInfo[iDvSlotID][gv_iDisabled] == 1)
						{
							if(arrGroupData[iGroupID][g_iBudget] > floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2))
							{
								arrGroupData[iGroupID][g_iBudget] -= floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2);
								SaveGroup(iGroupID);
								DynVehicleInfo[iDvSlotID][gv_iDisabled] = 0;
								DynVeh_Save(iDvSlotID);
								DynVeh_Spawn(iDvSlotID);
								strunpack(vehicleName, VehicleName[DynVehicleInfo[iDvSlotID][gv_iModel]-400], sizeof(vehicleName));
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da chuoc %s ID %d voi gia $%d", vehicleName, iDvSlotID, floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2));
								new str[128];
								format(str, sizeof(str), "Vehicle Slot ID %d buyback fee cost $%d to %s's budget fund.",iDvSlotID, floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2), arrGroupData[iGroupID][g_szGroupName]);
								GroupPayLog(iGroupID, str);
							}
							else
							{
								strunpack(vehicleName, VehicleName[DynVehicleInfo[iDvSlotID][gv_iModel]-400], sizeof(vehicleName));
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Co quan khong du tien chuoc %s ID %d voi gia $%d", vehicleName, iDvSlotID, floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2));
								return 1;
							}
						}
				    }
				}
			}
			return 1;
		}
		else if((0 <= strval(iVehicle) <= MAX_DYNAMIC_VEHICLES))
		{
			new iDvSlotID = strval(iVehicle);
			if(DynVehicleInfo[iDvSlotID][gv_iDisabled] == 1 && DynVehicleInfo[iDvSlotID][gv_igID] == iGroupID)
			{
				if(arrGroupData[iGroupID][g_iBudget] > floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2))
				{
					arrGroupData[iGroupID][g_iBudget] -= floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2);
					SaveGroup(iGroupID);
					DynVehicleInfo[iDvSlotID][gv_iDisabled] = 0;
					DynVeh_Save(iDvSlotID);
					DynVeh_Spawn(iDvSlotID);
					strunpack(vehicleName, VehicleName[DynVehicleInfo[iDvSlotID][gv_iModel]-400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da chuoc %s ID %d voi gia $%d", vehicleName, iDvSlotID, floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2));
					new str[128];
					format(str, sizeof(str), "Vehicle Slot ID %d buyback fee cost $%d to %s's budget fund.",iDvSlotID, floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2), arrGroupData[iGroupID][g_szGroupName]);
					GroupPayLog(iGroupID, str);
					return 1;
				}
				else
				{
					strunpack(vehicleName, VehicleName[DynVehicleInfo[iDvSlotID][gv_iModel]-400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Co quan khong du tien chuoc %s ID %d voi gia $%d", vehicleName, iDvSlotID, floatround(DynVehicleInfo[iDvSlotID][gv_iUpkeep] * 2));
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Xe chua bi tich thu hoac khong thuoc co quan cua ban.");
		}
		else SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "ID khong hop le");
	}
	else SendClientMessage(playerid, COLOR_GRAD2, " Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:dvadjust(playerid, params[])
{
	if(PlayerInfo[playerid][pMember] == INVALID_GROUP_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc to chuc!");
	if(PlayerInfo[playerid][pMember] != PlayerInfo[playerid][pLeader]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen lanh dao!");
	new vehicleid, opt[5], rank;
	if(sscanf(params, "ds[5]d", vehicleid, opt, rank))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /dvadjust [vehicle id] [rank/div] [value]");
		SendClientMessageEx(playerid, COLOR_GREY, "CHU Y: Dung /dl de lay ID xe");
		SendClientMessageEx(playerid, COLOR_GREY, "CHU Y: Gia tri 0 = Tat");
		return 1;
	}
	new iDvSlotID = DynVeh[vehicleid];
	if(iDvSlotID == -1 || iDvSlotID > MAX_DYNAMIC_VEHICLES || DynVehicleInfo[iDvSlotID][gv_iSpawnedID] != vehicleid) return SendClientMessageEx(playerid, COLOR_GRAD1, "ID xe dong khong hop le!");
	if(DynVehicleInfo[iDvSlotID][gv_igID] != PlayerInfo[playerid][pMember]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Xe khong thuoc to chuc cua ban!");
	//if(DynVehicleInfo[iDvSlotID][gv_igID] != INVALID_GROUP_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "This Vehicle is owned by a faction!");
	if(strcmp(opt, "rank", true) == 0)
	{
		if(rank > 9 || rank < 0) return SendClientMessageEx(playerid, COLOR_GREY, "Rank phai tu 0 den 9!");
		DynVehicleInfo[iDvSlotID][gv_irID] = rank;
		new string[128];
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi rank xe thanh %s (%d).", arrGroupRanks[DynVehicleInfo[iDvSlotID][gv_igID]][DynVehicleInfo[iDvSlotID][gv_irID]], rank);
		format(string, sizeof(string), "%s has adjusted the rank to %s (%d) on DV Slot %d.", GetPlayerNameEx(playerid), arrGroupRanks[DynVehicleInfo[iDvSlotID][gv_igID]][DynVehicleInfo[iDvSlotID][gv_irID]], rank, iDvSlotID);
		Log("logs/dv.log", string);
	}
	else if(strcmp(opt, "div", true) == 0)
	{
		if(rank > 9 || rank < 0) return SendClientMessageEx(playerid, COLOR_GREY, "Division phai tu 0 den 9!");
		DynVehicleInfo[iDvSlotID][gv_igDivID] = rank;
		new string[128];
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi division xe thanh %s (%d).", arrGroupDivisions[DynVehicleInfo[iDvSlotID][gv_igID]][rank - 1], rank);
		format(string, sizeof(string), "%s has adjusted the division to %s (%d) on DV Slot %d.", GetPlayerNameEx(playerid), arrGroupDivisions[DynVehicleInfo[iDvSlotID][gv_igID]][rank - 1], rank, iDvSlotID);
		Log("logs/dv.log", string);
	}
	DynVeh_Save(iDvSlotID);
	return 1;
}

CMD:dvpark(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid), iDvSlotID = DynVeh[vehicleid];
 		if(iDvSlotID == -1 || iDvSlotID > MAX_DYNAMIC_VEHICLES || DynVehicleInfo[iDvSlotID][gv_iSpawnedID] != vehicleid)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, " ID xe dong khong hop le!" );
		}
		if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || (PlayerInfo[playerid][pLeader] == DynVehicleInfo[iDvSlotID][gv_igID]) && DynVehicleInfo[iDvSlotID][gv_igID] != INVALID_GROUP_ID) {
			GetVehiclePos(vehicleid, DynVehicleInfo[iDvSlotID][gv_fX], DynVehicleInfo[iDvSlotID][gv_fY], DynVehicleInfo[iDvSlotID][gv_fZ]);
			GetVehicleZAngle(vehicleid, DynVehicleInfo[iDvSlotID][gv_fRotZ]);
			DynVehicleInfo[iDvSlotID][gv_iVW] = GetPlayerVirtualWorld(playerid);
			DynVehicleInfo[iDvSlotID][gv_iInt] = GetPlayerInterior(playerid);
			DynVeh_Save(iDvSlotID);
			DynVeh_Spawn(iDvSlotID);
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the do xe nay.");
	}
	return 1;
}

CMD:gotodv(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new moneys;
		if(sscanf(params, "i", moneys)) {
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotodv [slot ID]");
		}
		if(DynVeh[DynVehicleInfo[moneys][gv_iSpawnedID]] != -1 && (0 <= moneys < MAX_DYNAMIC_VEHICLES))
		{

			new Float:cwx2,Float:cwy2,Float:cwz2;
			GetVehiclePos(DynVehicleInfo[moneys][gv_iSpawnedID], cwx2, cwy2, cwz2);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, cwx2, cwy2+1, cwz2);
				SetPlayerVirtualWorld(playerid,GetVehicleVirtualWorld(DynVehicleInfo[moneys][gv_iSpawnedID]));
				SetPlayerInterior(playerid, DynVehicleInfo[moneys][gv_iInt]);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, cwx2, cwy2+1, cwz2);
				SetPlayerVirtualWorld(playerid,GetVehicleVirtualWorld(DynVehicleInfo[moneys][gv_iSpawnedID]));
				SetPlayerInterior(playerid, DynVehicleInfo[moneys][gv_iInt]);
			}
			SendClientMessageEx(playerid, COLOR_GRAD1, "   Ban da duoc dich chuyen!");
			SetPlayerInterior(playerid, 0);
			return 1;
		}
		else return SendClientMessage(playerid, COLOR_GRAD2, "Xe dong khong ton tai hoac chua duoc tao.");
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
}

CMD:dvstatus(playerid, params[])
{
	new iDvSlotID, vehicleid;
	if(sscanf(params, "i", vehicleid))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dvstatus [vehicleid]");
		return 1;
	}
	iDvSlotID = DynVeh[vehicleid];
	if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2)
	{
	    if(iDvSlotID != -1)
	    {
			SendClientMessageEx(playerid, COLOR_GREEN, "|___________ Xe dong (ID: %d | Slot ID: %d) ___________|", vehicleid, iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "X: %f | Y: %f | Z: %f | Model: %d | Phi: $%d | Mau max: %f", DynVehicleInfo[iDvSlotID][gv_fX], DynVehicleInfo[iDvSlotID][gv_fY], DynVehicleInfo[iDvSlotID][gv_fZ], DynVehicleInfo[iDvSlotID][gv_iModel], DynVehicleInfo[iDvSlotID][gv_iUpkeep], DynVehicleInfo[iDvSlotID][gv_fMaxHealth]);
			SendClientMessageEx(playerid, COLOR_WHITE, "To chuc: %d | Division: %d | Rank: %d | Loai: %d | VW: %d | Int: %d | Tat: %d", DynVehicleInfo[iDvSlotID][gv_igID], DynVehicleInfo[iDvSlotID][gv_igDivID], DynVehicleInfo[iDvSlotID][gv_irID], DynVehicleInfo[iDvSlotID][gv_iType], DynVehicleInfo[iDvSlotID][gv_iVW], DynVehicleInfo[iDvSlotID][gv_iInt], DynVehicleInfo[iDvSlotID][gv_iDisabled]);
			SendClientMessageEx(playerid, COLOR_WHITE, "Model 1: %d | Model 2: %d | Model 3: %d | Model 4: %d | Tai max: %d | Coi: %d", DynVehicleObjInfo[iDvSlotID][0][gv_iAttachedObjectModel], DynVehicleObjInfo[iDvSlotID][1][gv_iAttachedObjectModel], DynVehicleObjInfo[iDvSlotID][2][gv_iAttachedObjectModel], DynVehicleObjInfo[iDvSlotID][3][gv_iAttachedObjectModel], DynVehicleInfo[iDvSlotID][gv_iLoadMax], DynVehicleInfo[iDvSlotID][gv_iSiren]);
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Slot ID xe dong khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:dvcreate(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2 || PlayerInfo[playerid][pGangModerator] >= 2)
	{
		new
				iVehicle,
				iColors[2],
				string[128];

		if(sscanf(params, "iii", iVehicle, iColors[0], iColors[1])) {
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dvcreate [model ID] [color 1] [color 2]");
		}
		if(!(400 < iVehicle < 612)) return SendClientMessage(playerid, COLOR_GRAD2, "Model ID khong hop le");
		else if(IsATrain(iVehicle)) {
				SendClientMessageEx(playerid, COLOR_GREY, "Khong the tao tau khi may chu dang chay.");
			}
		else if(!(0 <= iColors[0] <= 255 && 0 <= iColors[1] <= 255)) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
		}
		mysql_tquery(MainPipeline, "SELECT id from `groupvehs` WHERE vModel = 0 LIMIT 1;", "DynVeh_CreateDVQuery", "iiii", playerid, iVehicle, iColors[0], iColors[1]);
		format(string, sizeof(string), "%s has created a dynamic vehicle.", GetPlayerNameEx(playerid));
		Log("logs/dv.log", string);
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:dvrespawnall(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		if(GetPVarInt(playerid, "dvRespawnAll") == 0)
		{
			new
				szString[128];

			SendClientMessageEx(playerid, COLOR_WHITE, "Dang tao lai tat ca xe dong...");

			for(new i = 0; i < MAX_DYNAMIC_VEHICLES; i++)
			{
				SetPVarInt(playerid, "dvRespawnAll", 1);
				DynVeh_Spawn(i);
			}

			format(szString, sizeof(szString), "{AA3333}AdmWarning{FFFF00}: %s da tao lai toan bo xe dong tren may chu.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW, szString, 2);
			format(szString, sizeof(szString), "Administrator %s has respawned all dynamic vehicles loaded on the server.", GetPlayerNameEx(playerid));
			Log("logs/admin.log", szString);
			SetPVarInt(playerid, "dvRespawnAll", 0);
		}
		else
			return SendClientMessageEx(playerid, COLOR_GREY, "Dang co yeu cau tao lai xe dong.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:freedvrespawn(playerid, params[]) return pc_cmd_dvrespawn(playerid, "1");
CMD:dvrespawn(playerid, const params[])
{
	new szString[128],
		iGroupID = PlayerInfo[playerid][pMember];

    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 1 || PlayerInfo[playerid][pGangModerator] >= 1)
    {
		if((0 <= iGroupID <= MAX_GROUPS))
		{
			for(new i; i < MAX_DYNAMIC_VEHICLES; i++)
			{
			    new iModelID = DynVehicleInfo[i][gv_iModel];
			    if(400 <= iModelID < 612 && DynVehicleInfo[i][gv_igID] == iGroupID)
			    {
					if(!IsVehicleSeatOccupied(DynVehicleInfo[i][gv_iSpawnedID]))
					{
						if(strval(params) == 1) DynVeh_Spawn(i, 1); else DynVeh_Spawn(i);
					}
			    }
			}
			format(szString, sizeof(szString), "** Dang tao lai xe dong to chuc%s...",(strval(params) == 1)?(" mien phi"):(""));
			foreach(new i: Player)
			{
				if(PlayerInfo[i][pMember] == iGroupID)
				{
					SendClientMessageEx(i, arrGroupData[iGroupID][g_hRadioColour] * 256 + 255, szString);
				}
			}
            format(szString, sizeof(szString), "%s has respawned group ID %d dynamic group vehicles.", GetPlayerNameEx(playerid), iGroupID+1);
   			Log("logs/group.log", szString);
		}
	}
	return 1;
}

CMD:dvedit(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2 || PlayerInfo[playerid][pGangModerator] >= 2)
	{
		new vehicleid, name[24], Float:value, slot;
		if(sscanf(params, "is[24]F(0)D(0)", vehicleid, name, value, slot))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dvedit [vehicleid] [v parameter] [value] [slot] (neu can - danh dau *)");
			SendClientMessageEx(playerid, COLOR_GREY, "Tham so: vmodel vcol1 vcol2 groupid divid loadmax maxhealth upkeep vtype vw delete");
			SendClientMessageEx(playerid, COLOR_GREY, "Tham so: disabled rank siren objmodel* objx* objy* objz* objrx* objry* objrz*");
			SendClientMessageEx(playerid, COLOR_GREY, "Tham so: objmatsize* objsize* (Do lech object)");
			return 1;
		}
		new iDvSlotID = DynVeh[vehicleid];
		if(iDvSlotID == -1 || iDvSlotID > MAX_DYNAMIC_VEHICLES || DynVehicleInfo[iDvSlotID][gv_iSpawnedID] != vehicleid) return SendClientMessageEx(playerid, COLOR_GRAD1, "ID xe dong khong hop le!" );
		EditDV(playerid, iDvSlotID, params, name, value, slot);
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:dveditslot(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2 || PlayerInfo[playerid][pGangModerator] >= 2)
	{
		new iDvSlotID, name[24], Float:value, slot;
		if(sscanf(params, "is[24]F(0)D(0)", iDvSlotID, name, value, slot)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dveditslot [dv slot id] [v parameter] [value] [slot] (neu can - danh dau *)");
			SendClientMessageEx(playerid, COLOR_GREY, "Tham so: vmodel vcol1 vcol2 groupid divid loadmax maxhealth upkeep vtype vw delete");
			SendClientMessageEx(playerid, COLOR_GREY, "Tham so: disabled rank siren objmodel* objx* objy* objz* objrx* objry* objrz*");
			SendClientMessageEx(playerid, COLOR_GREY, "Tham so: objmatsize* objsize* (Do lech object)");
			return 1;
		}
		if(iDvSlotID > MAX_DYNAMIC_VEHICLES || DynVehicleInfo[iDvSlotID][gv_iModel] == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "ID xe dong khong hop le!" );
		EditDV(playerid, iDvSlotID, params, name, value, slot);
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:dvtextobj(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2 || PlayerInfo[playerid][pGangModerator] >= 2)
	{
		new vehicleid, name[24], value[32], slot, string[128];
		if(sscanf(params, "ids[8]s[32]", vehicleid, slot, name, value)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dvtextobj [vehicleid] [object slot] [text/font/color/bgcolor] [value]");

		new iDvSlotID = DynVeh[vehicleid];
		if(iDvSlotID == -1 || iDvSlotID > MAX_DYNAMIC_VEHICLES || DynVehicleInfo[iDvSlotID][gv_iSpawnedID] != vehicleid) return SendClientMessageEx(playerid, COLOR_GRAD1, " ID xe dong khong hop le " );
		format(string, sizeof(string), "%s has edited DV Slot %d - %s.", GetPlayerNameEx(playerid), iDvSlotID, params);
		Log("logs/dv.log", string);

		if(1 <= slot <= MAX_DV_OBJECTS)
		{
			if(DynVehicleObjInfo[iDvSlotID][slot-1][gv_iAttachedObjectModel] == INVALID_OBJECT_ID || !IsABlankTexture(DynVehicleObjInfo[iDvSlotID][slot-1][gv_iAttachedObjectModel])) return SendClientMessageEx(playerid, COLOR_GREY, "O object khong hop le voi lenh nay!");
			if(strcmp(name, "text", true) == 0)
			{
				format(DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectText], 32, "%s", value);
				DynVeh_Spawn(iDvSlotID);
				DynVeh_Save(iDvSlotID);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi noi dung object xe dong");
				return 1;
			}
			if(strcmp(name, "font", true) == 0)
			{
				format(DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectFont], 32, "%s", value);
				DynVeh_Spawn(iDvSlotID);
				DynVeh_Save(iDvSlotID);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi font object xe dong");
				return 1;
			}
			if(strcmp(name, "color", true) == 0)
			{
				sscanf(value, "h", DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectColor]);
				DynVeh_Spawn(iDvSlotID);
				DynVeh_Save(iDvSlotID);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau chu object xe dong");
				return 1;
			}
			if(strcmp(name, "bgcolor", true) == 0)
			{
				sscanf(value, "h", DynVehicleObjInfo[iDvSlotID][slot-1][gv_fObjectBGColor]);
				DynVeh_Spawn(iDvSlotID);
				DynVeh_Save(iDvSlotID);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau nen object xe dong");
				return 1;
			}
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD2, "Slot ID phai tu 1 den "#MAX_DV_OBJECTS"!");
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:dvplate(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2 || PlayerInfo[playerid][pGangModerator] >= 2)
	{
		new vehicleid, plate[32];
        if(sscanf(params, "ds[32]", vehicleid, plate))
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dvplate [vehicleid] [plate/remove]");
		    SendClientMessageEx(playerid, COLOR_GREY, "MAU: (black/white/blue/red/green/purple/yellow/lightblue/navy/beige/darkgreen/darkblue/darkgrey/gold/brown/darkbrown/darkred");
			SendClientMessageEx(playerid, COLOR_GREY, "/pink) CACH DUNG: (red)Chao(white)ban! CHU Y: Moi mau chiem 8 ky tu");
			return 1;
		}
		new iDvSlotID = DynVeh[vehicleid];
		if(iDvSlotID == -1 || iDvSlotID > MAX_DYNAMIC_VEHICLES || DynVehicleInfo[iDvSlotID][gv_iSpawnedID] != vehicleid) return SendClientMessageEx(playerid, COLOR_GRAD1, "ID xe dong khong hop le!");

		format(plate, sizeof(plate), "%s", str_replace("(black)", "{000000}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(white)", "{FFFFFF}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(blue)", "{0000FF}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(red)", "{FF0000}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(green)", "{008000}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(purple)", "{800080}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(yellow)", "{FFFF00}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(lightblue)", "{ADD8E6}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(navy)", "{000080}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(beige)", "{F5F5DC}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(darkgreen)", "{006400}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(darkblue)", "{00008B}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(darkgrey)", "{A9A9A9}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(gold)", "{FFD700}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(brown)", "{A52A2A}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(darkbrown)", "{5C4033}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(darkred)", "{8B0000}", plate));
		format(plate, sizeof(plate), "%s", str_replace("(pink)", "{FF5B77}", plate));

		if(strcmp(plate, "remove", true) == 0)
		{
			DynVehicleInfo[iDvSlotID][gv_iPlate] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da go bien so tuy chinh xe dong");
		}
		else
		{
			format(DynVehicleInfo[iDvSlotID][gv_iPlate], 32, "%s", plate);
			DynVeh_Spawn(iDvSlotID);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi bien so tuy chinh xe dong");
		}

		DynVeh_Save(iDvSlotID);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:siren(playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if(IsACop(playerid) || IsAHitman(playerid) || IsAGovernment(playerid) || IsAMedic(playerid))
		{
			if(GetGVarType("VehSiren", GetPlayerVehicleID(playerid))) ToggleSiren(GetPlayerVehicleID(playerid), 1);
			else ToggleSiren(GetPlayerVehicleID(playerid), 0);
		}
		if(DynVeh[GetPlayerVehicleID(playerid)] != -1)
		{
			for(new i = 0; i != MAX_DV_OBJECTS; i++)
			{
				switch(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][i][gv_iAttachedObjectModel])
				{
					case 1899, 19300, 19420: ToggleDVSiren(DynVeh[GetPlayerVehicleID(playerid)], i, 1);
					case 18646, 19294, 19419: ToggleDVSiren(DynVeh[GetPlayerVehicleID(playerid)], i, 0);
				}
			}
		}
	}
	return 1;
}

CMD:deploy(playerid, params[])
{
	if(ValidGroup(PlayerInfo[playerid][pMember]))
	{
		if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban chua the lam viec nay.");
		if(GetPVarType(playerid, "IsInArena")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang o dau truong, chua the lam vay!");
		new type, object[12];
		if(sscanf(params, "s[12]D(0)", object, type))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /deploy [object] [type (option for barricades/signs)]");
			SendClientMessageEx(playerid, COLOR_GRAD1, "Vat the: Cade, Spikes, Flare, Cone, Barrel, Ladder, Sign, Tape");
			return 1;
		}
		else if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai di bo de dung lenh nay.");

		new iGroup = PlayerInfo[playerid][pMember];

		if(strcmp(object, "cade", true) == 0) {

			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarricades]) {

				new aCades[12] = {981, 4504, 4505, 4514, 4526, 978, 979, 3091, 1459, 1423, 1424, 981};
				ShowModelSelectionMenuEx(playerid, aCades, sizeof(aCades), "Cades", 1500, -16.0, 0.0, -55.0);
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "spikes", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iSpikeStrips])
			{
				for(new i; i < MAX_SPIKES; i++)
				{
					if(!IsValidDynamicObject(SpikeStrips[iGroup][i][sObjectID]))
					{
						new Float: f_TempAngle;

						DeleteSpikeStrip(iGroup, i);
						GetPlayerPos(playerid, SpikeStrips[iGroup][i][sX], SpikeStrips[iGroup][i][sY], SpikeStrips[iGroup][i][sZ]);
						GetPlayerFacingAngle(playerid, f_TempAngle);
						SpikeStrips[iGroup][i][sWorldID] = GetPlayerVirtualWorld(playerid);
						SpikeStrips[iGroup][i][sInteriorID] = GetPlayerInterior(playerid);
						SpikeStrips[iGroup][i][sObjectID] = CreateDynamicObject(2899, SpikeStrips[iGroup][i][sX], SpikeStrips[iGroup][i][sY], SpikeStrips[iGroup][i][sZ]-0.8, 0.0, 0.0, f_TempAngle, SpikeStrips[iGroup][i][sWorldID], SpikeStrips[iGroup][i][sInteriorID]);
						if(!IsValidDynamicObject(SpikeStrips[iGroup][i][sObjectID]))
						{
							DeleteSpikeStrip(iGroup, i);
							return SendClientMessageEx(playerid, COLOR_GREY, "Khong tao duoc dai dinh. Hay thu lai.");
						}
						SpikeStrips[iGroup][i][sCosAngle] = floatcos(f_TempAngle, degrees);
						SpikeStrips[iGroup][i][sSinAngle] = floatsin(f_TempAngle, degrees);
						Iter_Add(DeployedSpikes, iGroup * MAX_SPIKES + i);
						GetPlayer3DZone(playerid, SpikeStrips[iGroup][i][sDeployedAt], MAX_ZONE_NAME);
						SpikeStrips[iGroup][i][sDeployedBy] = GetPlayerNameEx(playerid);
						if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pTogReports] != 1) SpikeStrips[iGroup][i][sDeployedByStatus] = 1;
						else SpikeStrips[iGroup][i][sDeployedByStatus] = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tao dai dinh ID: %d.", i);
						/*format(string, sizeof(string), "** HQ: A spike has been deployed by %s at %s **", GetPlayerNameEx(playerid), SpikeStrips[iGroup][i][sDeployedAt]);
						foreach(new x: Player)
						{
							if(PlayerInfo[x][pToggledChats][CHAT_GROUP_RADIO] == 0)
							{
								if(PlayerInfo[x][pMember] == iGroup) SendClientMessageEx(x, arrGroupData[iGroup][g_hRadioColour] * 256 + 255, string);
								if(GetPVarInt(x, "BigEar") == 4 && GetPVarInt(x, "BigEarGroup") == iGroup)
								{
									new szBigEar[128];
									format(szBigEar, sizeof(szBigEar), "(BE) %s", string);
									SendClientMessageEx(x, arrGroupData[iGroup][g_hRadioColour] * 256 + 255, szBigEar);
								}
							}
						}*/
						return 1;
					}
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong tao duoc them dai dinh, gioi han la " #MAX_SPIKES# ".");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "flare", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iFlares])
			{
				for(new i; i < MAX_FLARES; i++)
				{
					if(Flares[iGroup][i][sX] == 0 && Flares[iGroup][i][sY] == 0 && Flares[iGroup][i][sZ] == 0)
					{
						new Float: f_TempAngle;

						GetPlayerPos(playerid, Flares[iGroup][i][sX], Flares[iGroup][i][sY], Flares[iGroup][i][sZ]);
						GetPlayerFacingAngle(playerid, f_TempAngle);
						Flares[iGroup][i][sObjectID] = CreateDynamicObject(18728, Flares[iGroup][i][sX], Flares[iGroup][i][sY], Flares[iGroup][i][sZ]-2.4, 0.0, 0.0, f_TempAngle);
						GetPlayer3DZone(playerid, Flares[iGroup][i][sDeployedAt], MAX_ZONE_NAME);
						Flares[iGroup][i][sDeployedBy] = GetPlayerNameEx(playerid);
						if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pTogReports] != 1) Flares[iGroup][i][sDeployedByStatus] = 1;
						else Flares[iGroup][i][sDeployedByStatus] = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tao phao sang ID: %d.", i);
						return 1;
					}
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong tao duoc them phao sang, gioi han la " #MAX_FLARES# ".");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "cone", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iCones])
			{
				for(new i; i < MAX_CONES; i++)
				{
					if(Cones[iGroup][i][sX] == 0 && Cones[iGroup][i][sY] == 0 && Cones[iGroup][i][sZ] == 0)
					{
						new Float: f_TempAngle;

						GetPlayerPos(playerid, Cones[iGroup][i][sX], Cones[iGroup][i][sY], Cones[iGroup][i][sZ]);
						GetPlayerFacingAngle(playerid, f_TempAngle);
						Cones[iGroup][i][sObjectID] = CreateDynamicObject(1238, Cones[iGroup][i][sX], Cones[iGroup][i][sY], Cones[iGroup][i][sZ]-0.7, 0.0, 0.0, f_TempAngle);
						GetPlayer3DZone(playerid, Cones[iGroup][i][sDeployedAt], MAX_ZONE_NAME);
						Cones[iGroup][i][sDeployedBy] = GetPlayerNameEx(playerid);
						if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pTogReports] != 1) Cones[iGroup][i][sDeployedByStatus] = 1;
						else Cones[iGroup][i][sDeployedByStatus] = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tao coc tieu ID: %d.", i);
						return 1;
					}
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong tao duoc them coc tieu, gioi han la " #MAX_CONES# ".");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "barrel", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarrels])
			{
				for(new i; i < MAX_BARRELS; i++)
				{
					if(Barrels[iGroup][i][sX] == 0 && Barrels[iGroup][i][sY] == 0 && Barrels[iGroup][i][sZ] == 0)
					{
						new Float: f_TempAngle;

						GetPlayerPos(playerid, Barrels[iGroup][i][sX], Barrels[iGroup][i][sY], Barrels[iGroup][i][sZ]);
						GetPlayerFacingAngle(playerid, f_TempAngle);
						Barrels[iGroup][i][sObjectID] = CreateDynamicObject(1237, Barrels[iGroup][i][sX], Barrels[iGroup][i][sY], Barrels[iGroup][i][sZ]-1, 0.0, 0.0, f_TempAngle);
						GetPlayer3DZone(playerid, Barrels[iGroup][i][sDeployedAt], MAX_ZONE_NAME);
						Barrels[iGroup][i][sDeployedBy] = GetPlayerNameEx(playerid);
						if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pTogReports] != 1) Barrels[iGroup][i][sDeployedByStatus] = 1;
						else Barrels[iGroup][i][sDeployedByStatus] = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tao thung phuy ID: %d.", i);
						return 1;
					}
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong tao duoc them thung phuy, gioi han la " #MAX_BARRELS# ".");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "ladder", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iLadders])
			{
				for(new i; i < MAX_LADDERS; i++)
				{
					if(Ladders[iGroup][i][sX] == 0 && Ladders[iGroup][i][sY] == 0 && Ladders[iGroup][i][sZ] == 0)
					{
						new Float: f_TempAngle;

						GetPlayerPos(playerid, Ladders[iGroup][i][sX], Ladders[iGroup][i][sY], Ladders[iGroup][i][sZ]);
						GetPlayerFacingAngle(playerid, f_TempAngle);
						Ladders[iGroup][i][sObjectID] = CreateDynamicObject(1437, Ladders[iGroup][i][sX], Ladders[iGroup][i][sY], Ladders[iGroup][i][sZ] + 0.20, 340.0, 0.0, f_TempAngle);
						GetPlayer3DZone(playerid, Ladders[iGroup][i][sDeployedAt], MAX_ZONE_NAME);
						SetPlayerPos(playerid, Ladders[iGroup][i][sX], Ladders[iGroup][i][sY], Ladders[iGroup][i][sZ] + 0.50);
						Ladders[iGroup][i][sDeployedBy] = GetPlayerNameEx(playerid);
						if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pTogReports] != 1) Ladders[iGroup][i][sDeployedByStatus] = 1;
						else Ladders[iGroup][i][sDeployedByStatus] = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tao thang ID: %d.", i);
						return 1;
					}
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong tao duoc them thang, gioi han la " #MAX_LADDERS# ".");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "sign", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iCones])
			{
				for(new i; i < MAX_SIGNS; i++)
				{
					if(Signs[iGroup][i][sX] == 0 && Signs[iGroup][i][sY] == 0 && Signs[iGroup][i][sZ] == 0)
					{
						new Float: f_TempAngle;

						GetPlayerPos(playerid, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ]);
						GetPlayerFacingAngle(playerid, f_TempAngle);
						switch(type)
						{
							case 0:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19966, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 1:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19976, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 2:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19967, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 3:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19972, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 4:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19975, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 5:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19973, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 6:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19974, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 7:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(1425, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 0.40, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 2, Signs[iGroup][i][sY] + 2, Signs[iGroup][i][sZ]);
							}
							case 8:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19960, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 9:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19961, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 10:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19951, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 11:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19952, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 12:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19953, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 13:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19954, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							case 14:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(1233, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
							default:
							{
								Signs[iGroup][i][sObjectID] = CreateDynamicObject(19966, Signs[iGroup][i][sX], Signs[iGroup][i][sY], Signs[iGroup][i][sZ] - 1.0, 0.0, 0.0, f_TempAngle);
								SetPlayerPos(playerid, Signs[iGroup][i][sX] + 1, Signs[iGroup][i][sY] + 1, Signs[iGroup][i][sZ]);
							}
						}
						GetPlayer3DZone(playerid, Signs[iGroup][i][sDeployedAt], MAX_ZONE_NAME);
						Signs[iGroup][i][sDeployedBy] = GetPlayerNameEx(playerid);
						if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pTogReports] != 1) Signs[iGroup][i][sDeployedByStatus] = 1;
						else Signs[iGroup][i][sDeployedByStatus] = 0;
						SendClientMessageEx(playerid, COLOR_WHITE, "Da tao bien bao ID: %d.", i);
						return 1;
					}
				}
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong tao duoc them bien bao, gioi han la " #MAX_SIGNS# ".");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "tape", true) == 0) {
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iTapes]) {
			    if(GetPVarType(playerid, "DeployingTapeID")) {
					for(new i; i < sizeof(Tapes); i++) {
						if(Tapes[i][sX] == 0 && Tapes[i][sY] == 0 && Tapes[i][sZ] == 0)	{

							new Float: f_TempAngle;

							GetPlayerPos(playerid, Tapes[i][sX], Tapes[i][sY], Tapes[i][sZ]);
							GetPlayerFacingAngle(playerid, f_TempAngle);
							Tapes[i][sObjectID] = CreateDynamicObject(19834, Tapes[i][sX], Tapes[i][sY], Tapes[i][sZ], 0.0, 0.0, f_TempAngle);
							GetPlayer3DZone(playerid, Tapes[i][sDeployedAt], MAX_ZONE_NAME);
							Tapes[i][sDeployedBy] = GetPlayerNameEx(playerid);
							if(PlayerInfo[playerid][pAdmin] > 1 && PlayerInfo[playerid][pTogReports] != 1) Tapes[i][sDeployedByStatus] = 1;
							else Tapes[i][sDeployedByStatus] = 0;
							SendClientMessageEx(playerid, COLOR_WHITE, "Da tao day chan ID: %d. Dung dieu khien tren man hinh de doi vi tri.", i);
							SendClientMessage(playerid, COLOR_WHITE, "Nhan bieu tuong dia de luu vi tri day chan. Nhan ESC de huy.");
							SetPlayerPos(playerid, Tapes[i][sX], Tapes[i][sY]-0.4, Tapes[i][sZ]); // Force streamer.
							SetPVarInt(playerid, "DeployingTapeID", i);
							EditDynamicObject(playerid, Tapes[i][sObjectID]);
							return 1;
						}
					}
					SendClientMessageEx(playerid, COLOR_WHITE, "Khong tao duoc them day chan, gioi han la " #MAX_TAPES# ".");
				}
				else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang sua mot day chan.");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:destroy(playerid, params[])
{
	if(ValidGroup(PlayerInfo[playerid][pMember]))
	{
		new type, object[12];
		if(sscanf(params, "s[12]d", object, type))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /destroy [object] [ID]");
			SendClientMessageEx(playerid, COLOR_GRAD1, "Vat the: Cade, Spikes, Flare, Cone, Barrel, Ladder, Sign, Tape");
			return 1;
		}
		else if(IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai di bo de dung lenh nay.");

		new iGroup = PlayerInfo[playerid][pMember];

		if(strcmp(object, "cade", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarricades])
			{
				if(!(0 <= type < MAX_BARRICADES) || (Barricades[iGroup][type][sX] == 0 && Barricades[iGroup][type][sY] == 0 && Barricades[iGroup][type][sZ] == 0)) return SendClientMessageEx(playerid, COLOR_WHITE, "ID rao chan khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && Barricades[iGroup][type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy rao chan do Administrator dat.");
				else
				{
					new string[43 + MAX_PLAYER_NAME + MAX_ZONE_NAME];
					if(IsValidDynamicObject(Barricades[iGroup][type][sObjectID])) DestroyDynamicObject(Barricades[iGroup][type][sObjectID]);
					Barricades[iGroup][type][sX] = 0;
					Barricades[iGroup][type][sY] = 0;
					Barricades[iGroup][type][sZ] = 0;
					Barricades[iGroup][type][sObjectID] = -1;
					Barricades[iGroup][type][sDeployedBy] = INVALID_PLAYER_ID;
					Barricades[iGroup][type][sDeployedByStatus] = 0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa rao chan ID: %d.", type);
					format(string, sizeof(string), "** HQ: %s da huy rao chan tai %s **", GetPlayerNameEx(playerid), Barricades[iGroup][type][sDeployedAt]);
					foreach(new i: Player)
					{
						if(PlayerInfo[i][pToggledChats][CHAT_GROUP_RADIO] == 0)
						{
							if(PlayerInfo[i][pMember] == iGroup) SendClientMessageEx(i, arrGroupData[iGroup][g_hRadioColour] * 256 + 255, string);
							if(GetPVarInt(i, "BigEar") == 4 && GetPVarInt(i, "BigEarGroup") == iGroup)
							{
								SendClientMessageEx(i, arrGroupData[iGroup][g_hRadioColour] * 256 + 255, "(BE) %s", string);
							}
						}
					}
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "spikes", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iSpikeStrips])
			{
				if(!(0 <= type < MAX_SPIKES) || !IsValidDynamicObject(SpikeStrips[iGroup][type][sObjectID])) return SendClientMessageEx(playerid, COLOR_WHITE, "ID dai dinh khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && SpikeStrips[iGroup][type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy dai dinh do Administrator dat.");
				else
				{
					DeleteSpikeStrip(iGroup, type);
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa dai dinh %d.", type);
					/*format(string, sizeof(string), "** HQ: A spike has been destroyed by %s at %s **", GetPlayerNameEx(playerid), SpikeStrips[iGroup][type][sDeployedAt]);
					foreach(new i: Player)
					{
						if(PlayerInfo[i][pToggledChats][CHAT_GROUP_RADIO] == 0)
						{
							if(PlayerInfo[i][pMember] == iGroup) SendClientMessageEx(i, arrGroupData[iGroup][g_hRadioColour] * 256 + 255, string);
							if(GetPVarInt(i, "BigEar") == 4 && GetPVarInt(i, "BigEarGroup") == iGroup)
							{
								new szBigEar[128];
								format(szBigEar, sizeof(szBigEar), "(BE) %s", string);
								SendClientMessageEx(i, arrGroupData[iGroup][g_hRadioColour] * 256 + 255, szBigEar);
							}
						}
					}*/
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "flare", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iFlares])
			{
				if(!(0 <= type < MAX_FLARES) || (Flares[iGroup][type][sX] == 0 && Flares[iGroup][type][sY] == 0 && Flares[iGroup][type][sZ] == 0)) return SendClientMessageEx(playerid, COLOR_WHITE, "ID phao sang khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && Flares[iGroup][type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy phao sang do Administrator dat.");
				else
				{
					if(IsValidDynamicObject(Flares[iGroup][type][sObjectID])) DestroyDynamicObject(Flares[iGroup][type][sObjectID]);
					Flares[iGroup][type][sX] = 0;
					Flares[iGroup][type][sY] = 0;
					Flares[iGroup][type][sZ] = 0;
					Flares[iGroup][type][sObjectID] = -1;
					Flares[iGroup][type][sDeployedBy] = INVALID_PLAYER_ID;
					Flares[iGroup][type][sDeployedByStatus] = 0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa phao sang ID: %d.", type);
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "cone", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iCones])
			{
				if(!(0 <= type < MAX_CONES) || (Cones[iGroup][type][sX] == 0 && Cones[iGroup][type][sY] == 0 && Cones[iGroup][type][sZ] == 0)) return SendClientMessageEx(playerid, COLOR_WHITE, "ID coc tieu khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && Cones[iGroup][type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy coc tieu do Administrator dat.");
				else
				{
					if(IsValidDynamicObject(Cones[iGroup][type][sObjectID])) DestroyDynamicObject(Cones[iGroup][type][sObjectID]);
					Cones[iGroup][type][sX] = 0;
					Cones[iGroup][type][sY] = 0;
					Cones[iGroup][type][sZ] = 0;
					Cones[iGroup][type][sObjectID] = -1;
					Cones[iGroup][type][sDeployedBy] = INVALID_PLAYER_ID;
					Cones[iGroup][type][sDeployedByStatus] = 0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa coc tieu ID: %d.", type);
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "barrel", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarrels])
			{
				if(!(0 <= type < MAX_BARRELS) || (Barrels[iGroup][type][sX] == 0 && Barrels[iGroup][type][sY] == 0 && Barrels[iGroup][type][sZ] == 0)) return SendClientMessageEx(playerid, COLOR_WHITE, "ID thung phuy khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && Barrels[iGroup][type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy thung phuy do Administrator dat.");
				else
				{
					if(IsValidDynamicObject(Barrels[iGroup][type][sObjectID])) DestroyDynamicObject(Barrels[iGroup][type][sObjectID]);
					Barrels[iGroup][type][sX] = 0;
					Barrels[iGroup][type][sY] = 0;
					Barrels[iGroup][type][sZ] = 0;
					Barrels[iGroup][type][sObjectID] = -1;
					Barrels[iGroup][type][sDeployedBy] = INVALID_PLAYER_ID;
					Barrels[iGroup][type][sDeployedByStatus] = 0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa thung phuy ID: %d.", type);
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "ladder", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iLadders])
			{
				if(!(0 <= type < MAX_LADDERS) || (Ladders[iGroup][type][sX] == 0 && Ladders[iGroup][type][sY] == 0 && Ladders[iGroup][type][sZ] == 0)) return SendClientMessageEx(playerid, COLOR_WHITE, "ID thang khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && Barrels[iGroup][type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy thang do Administrator dat.");
				else
				{
					if(IsValidDynamicObject(Ladders[iGroup][type][sObjectID])) DestroyDynamicObject(Ladders[iGroup][type][sObjectID]);
					Ladders[iGroup][type][sX] = 0;
					Ladders[iGroup][type][sY] = 0;
					Ladders[iGroup][type][sZ] = 0;
					Ladders[iGroup][type][sObjectID] = -1;
					Ladders[iGroup][type][sDeployedBy] = INVALID_PLAYER_ID;
					Ladders[iGroup][type][sDeployedByStatus] = 0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa thang ID: %d.", type);
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "sign", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarrels])
			{
				if(!(0 <= type < MAX_SIGNS) || (Signs[iGroup][type][sX] == 0 && Signs[iGroup][type][sY] == 0 && Signs[iGroup][type][sZ] == 0)) return SendClientMessageEx(playerid, COLOR_WHITE, "ID bien bao khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && Signs[iGroup][type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy bien bao do Administrator dat.");
				else
				{
					if(IsValidDynamicObject(Signs[iGroup][type][sObjectID])) DestroyDynamicObject(Signs[iGroup][type][sObjectID]);
					Signs[iGroup][type][sX] = 0;
					Signs[iGroup][type][sY] = 0;
					Signs[iGroup][type][sZ] = 0;
					Signs[iGroup][type][sObjectID] = -1;
					Signs[iGroup][type][sDeployedBy] = INVALID_PLAYER_ID;
					Signs[iGroup][type][sDeployedByStatus] = 0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa bien bao ID: %d.", type);
					return 1;
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
		else if(strcmp(object, "tape", true) == 0)
		{
			if(PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iTapes])
			{
				if(!(0 <= type < sizeof(Tapes)) || (Tapes[type][sX] == 0 && Tapes[type][sY] == 0 && Tapes[type][sZ] == 0)) return SendClientMessageEx(playerid, COLOR_WHITE, "ID day chan khong hop le.");
				else if(PlayerInfo[playerid][pAdmin] < 2 && Tapes[type][sDeployedByStatus] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy day chan do Administrator dat.");
				else
				{
					if(PlayerInfo[playerid][pMember] == Tapes[type][iDeployedByGroup])
					{
							DestroyDynamicObject(Tapes[type][sObjectID]);
							Tapes[type][sX] = 0;
							Tapes[type][sY] = 0;
							Tapes[type][sZ] = 0;
							Tapes[type][sObjectID] = INVALID_OBJECT_ID;
							Tapes[type][sDeployedBy] = INVALID_PLAYER_ID;
							Tapes[type][sDeployedByStatus] = 0;
							SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa day chan ID: %d.", type);
							return 1;
					}
					else
					{
							SendClientMessageEx(playerid, COLOR_GRAD2, "* Khong the xoa day chan to chuc khac *");

					}
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:acades(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	szMiscArray[0] = 0;
	szMiscArray = "To chuc\tID\tVi tri\tNguoi dat";

	for(new iGroupID = 0; iGroupID < MAX_GROUPS; iGroupID++) {
		for(new iCade; iCade < MAX_BARRICADES; iCade++) {
			if(Barricades[iGroupID][iCade][sX] != 0 && Barricades[iGroupID][iCade][sY] != 0 && Barricades[iGroupID][iCade][sZ] != 0) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s(%d)\t%d\t%s\t%s", szMiscArray, arrGroupData[iGroupID][g_szGroupName], iGroupID, iCade, Barricades[iGroupID][iCade][sDeployedAt], Barricades[iGroupID][iCade][sDeployedBy]);
			}
		}
	}

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Rao chan may chu", szMiscArray, "Dong", "");

	return 1;
}

CMD:cades(playerid, params[])
{
	if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && arrGroupData[PlayerInfo[playerid][pMember]][g_iBarricades] != -1 && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarricades])
	{
		new iGroup = PlayerInfo[playerid][pMember];
		SendClientMessageEx(playerid, COLOR_WHITE, "Rao chan dang dat:");
		for(new i, string[56 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < MAX_BARRICADES; i++)
		{
			if(Barricades[iGroup][i][sX] != 0 && Barricades[iGroup][i][sY] != 0 && Barricades[iGroup][i][sZ] != 0) // Checking for next available ID.
			{
				format(string, sizeof(string), "HQ: Rao chan #%d | Vi tri: %s | Nguoi dat: %s", i, Barricades[iGroup][i][sDeployedAt], Barricades[iGroup][i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen.");
	}
	return 1;
}

CMD:aspikes(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	szMiscArray[0] = 0;
	szMiscArray = "To chuc\tID\tVi tri\tNguoi dat";

	for(new iGroupID = 0; iGroupID < MAX_GROUPS; iGroupID++) {
		for(new iSpike; iSpike < MAX_SPIKES; iSpike++) {
			if(IsValidDynamicObject(SpikeStrips[iGroupID][iSpike][sObjectID])) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s(%d)\t%d\t%s\t%s", szMiscArray, arrGroupData[iGroupID][g_szGroupName], iGroupID, iSpike, SpikeStrips[iGroupID][iSpike][sDeployedAt], SpikeStrips[iGroupID][iSpike][sDeployedBy]);
			}
		}
	}

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Dai dinh may chu", szMiscArray, "Dong", "");

	return 1;
}

CMD:spikes(playerid, params[])
{
	if (ValidGroup(PlayerInfo[playerid][pMember]) && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iSpikeStrips])
	{
		new iGroup = PlayerInfo[playerid][pMember];
		SendClientMessageEx(playerid, COLOR_WHITE, "Dai dinh dang dat:");
		for(new i, string[56 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < MAX_SPIKES; i++)
		{
			if(IsValidDynamicObject(SpikeStrips[iGroup][i][sObjectID]))
			{
				format(string, sizeof(string), "HQ: Dai dinh ID: %d | Vi tri: %s | Nguoi dat: %s", i, SpikeStrips[iGroup][i][sDeployedAt], SpikeStrips[iGroup][i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	} else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:aflares(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	szMiscArray[0] = 0;
	szMiscArray = "To chuc\tID\tVi tri\tNguoi dat";

	for(new iGroupID = 0; iGroupID < MAX_GROUPS; iGroupID++) {
		for(new iFlare; iFlare < MAX_FLARES; iFlare++) {
			if(Flares[iGroupID][iFlare][sX] != 0 && Flares[iGroupID][iFlare][sY] != 0 && Flares[iGroupID][iFlare][sZ] != 0) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s(%d)\t%d\t%s\t%s", szMiscArray, arrGroupData[iGroupID][g_szGroupName], iGroupID, iFlare, Flares[iGroupID][iFlare][sDeployedAt], Flares[iGroupID][iFlare][sDeployedBy]);
			}
		}
	}

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Phao sang may chu", szMiscArray, "Dong", "");

	return 1;
}

CMD:flares(playerid, params[])
{
	if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iFlares])
	{
		new iGroup = PlayerInfo[playerid][pMember];
		SendClientMessageEx(playerid, COLOR_WHITE, "Phao sang dang dat:");
		for(new i, string[58 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < MAX_FLARES; i++)
		{
			if(Flares[iGroup][i][sX] != 0 && Flares[iGroup][i][sY] != 0 && Flares[iGroup][i][sZ] != 0) // Checking for next available ID.
			{
				format(string, sizeof(string), "HQ: Phao sang ID: %d | Vi tri: %s | Nguoi dat: %s", i, Flares[iGroup][i][sDeployedAt], Flares[iGroup][i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen.");
	}
	return 1;
}

CMD:acones(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	szMiscArray[0] = 0;
	szMiscArray = "To chuc\tID\tVi tri\tNguoi dat";

	for(new iGroupID = 0; iGroupID < MAX_GROUPS; iGroupID++) {
		for(new iCone; iCone < MAX_CONES; iCone++) {
			if(Cones[iGroupID][iCone][sX] != 0 && Cones[iGroupID][iCone][sY] != 0 && Cones[iGroupID][iCone][sZ] != 0) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s(%d)\t%d\t%s\t%s", szMiscArray, arrGroupData[iGroupID][g_szGroupName], iGroupID, iCone, Cones[iGroupID][iCone][sDeployedAt], Cones[iGroupID][iCone][sDeployedBy]);
			}
		}
	}

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Coc tieu may chu", szMiscArray, "Dong", "");

	return 1;
}

CMD:cones(playerid, params[])
{
	if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iCones])
	{
		new iGroup = PlayerInfo[playerid][pMember];
		SendClientMessageEx(playerid, COLOR_WHITE, "Coc tieu dang dat:");
		for(new i, string[56 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < MAX_CONES; i++)
		{
			if(Cones[iGroup][i][sX] != 0 && Cones[iGroup][i][sY] != 0 && Cones[iGroup][i][sZ] != 0) // Checking for next available ID.
			{
				format(string, sizeof(string), "HQ: Coc tieu ID: %d | Vi tri: %s | Nguoi dat: %s", i, Cones[iGroup][i][sDeployedAt], Cones[iGroup][i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen.");
	}
	return 1;
}

CMD:abarrels(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	szMiscArray[0] = 0;
	szMiscArray = "To chuc\tID\tVi tri\tNguoi dat";

	for(new iGroupID = 0; iGroupID < MAX_GROUPS; iGroupID++) {
		for(new iBarrel; iBarrel < MAX_BARRELS; iBarrel++) {
			if(Barrels[iGroupID][iBarrel][sX] != 0 && Barrels[iGroupID][iBarrel][sY] != 0 && Barrels[iGroupID][iBarrel][sZ] != 0) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s(%d)\t%d\t%s\t%s", szMiscArray, arrGroupData[iGroupID][g_szGroupName], iGroupID, iBarrel, Barrels[iGroupID][iBarrel][sDeployedAt], Barrels[iGroupID][iBarrel][sDeployedBy]);
			}
		}
	}

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Thung phuy may chu", szMiscArray, "Dong", "");

	return 1;
}

CMD:barrels(playerid, params[])
{
	if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarrels])
	{
		new iGroup = PlayerInfo[playerid][pMember];
		SendClientMessageEx(playerid, COLOR_WHITE, "Thung phuy dang dat:");
		for(new i, string[56 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < MAX_BARRELS; i++)
		{
			if(Barrels[iGroup][i][sX] != 0 && Barrels[iGroup][i][sY] != 0 && Barrels[iGroup][i][sZ] != 0) // Checking for next available ID.
			{
				format(string, sizeof(string), "HQ: Thung phuy ID: %d | Vi tri: %s | Nguoi dat: %s", i, Barrels[iGroup][i][sDeployedAt], Barrels[iGroup][i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen.");
	}
	return 1;
}

CMD:aladders(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	szMiscArray[0] = 0;
	szMiscArray = "To chuc\tID\tVi tri\tNguoi dat";

	for(new iGroupID = 0; iGroupID < MAX_GROUPS; iGroupID++) {
		for(new iLadder; iLadder < MAX_LADDERS; iLadder++) {
			if(Ladders[iGroupID][iLadder][sX] != 0 && Ladders[iGroupID][iLadder][sY] != 0 && Ladders[iGroupID][iLadder][sZ] != 0) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s(%d)\t%d\t%s\t%s", szMiscArray, arrGroupData[iGroupID][g_szGroupName], iGroupID, iLadder, Ladders[iGroupID][iLadder][sDeployedAt], Ladders[iGroupID][iLadder][sDeployedBy]);
			}
		}
	}

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Thang may chu", szMiscArray, "Dong", "");

	return 1;
}

CMD:ladders(playerid, params[])
{
	if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iLadders])
	{
		new iGroup = PlayerInfo[playerid][pMember];
		SendClientMessageEx(playerid, COLOR_WHITE, "Thang dang dat:");
		for(new i, string[56 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < MAX_LADDERS; i++)
		{
			if(Ladders[iGroup][i][sX] != 0 && Ladders[iGroup][i][sY] != 0 && Ladders[iGroup][i][sZ] != 0) // Checking for next available ID.
			{
				format(string, sizeof(string), "HQ: Thang ID: %d | Vi tri: %s | Nguoi dat: %s", i, Ladders[iGroup][i][sDeployedAt], Ladders[iGroup][i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen.");
	}
	return 1;
}

CMD:asigns(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	szMiscArray[0] = 0;
	szMiscArray = "To chuc\tID\tVi tri\tNguoi dat";

	for(new iGroupID = 0; iGroupID < MAX_GROUPS; iGroupID++) {
		for(new iSign; iSign < MAX_SIGNS; iSign++) {
			if(Signs[iGroupID][iSign][sX] != 0 && Signs[iGroupID][iSign][sY] != 0 && Signs[iGroupID][iSign][sZ] != 0) {
				format(szMiscArray, sizeof(szMiscArray), "%s\n%s(%d)\t%d\t%s\t%s", szMiscArray, arrGroupData[iGroupID][g_szGroupName], iGroupID, iSign, Signs[iGroupID][iSign][sDeployedAt], Signs[iGroupID][iSign][sDeployedBy]);
			}
		}
	}

	ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_TABLIST_HEADERS, "Bien bao may chu", szMiscArray, "Dong", "");

	return 1;
}

CMD:signs(playerid, params[])
{
	if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBarrels])
	{
		new iGroup = PlayerInfo[playerid][pMember];
		SendClientMessageEx(playerid, COLOR_WHITE, "Bien bao dang dat:");
		for(new i, string[56 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < MAX_BARRELS; i++)
		{
			if(Signs[iGroup][i][sX] != 0 && Signs[iGroup][i][sY] != 0 && Signs[iGroup][i][sZ] != 0) // Checking for next available ID.
			{
				format(string, sizeof(string), "HQ: Bien bao ID: %d | Vi tri: %s | Nguoi dat: %s", i, Signs[iGroup][i][sDeployedAt], Signs[iGroup][i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen.");
	}
	return 1;
}

CMD:tapes(playerid, params[]) {

    if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && arrGroupData[PlayerInfo[playerid][pMember]][g_iTapes] != -1 && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iTapes])
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Day chan dang dat:");
		for(new i, string[56 + MAX_ZONE_NAME + MAX_PLAYER_NAME]; i < sizeof(Tapes); i++)
		{
			if(Tapes[i][sX] != 0 && Tapes[i][sY] != 0 && Tapes[i][sZ] != 0) // Checking for next available ID.
			{
				format(string, sizeof(string), "HQ: Day chan #%d | Vi tri: %s | Nguoi dat: %s", i, Tapes[i][sDeployedAt], Tapes[i][sDeployedBy]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen.");
	}
	return 1;
}

CMD:quitgroup(playerid, params[])
{
    if(PlayerInfo[playerid][pMember] >= 0 || PlayerInfo[playerid][pLeader] >= 0)
	{
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* Ban da roi to chuc va tro lai lam cong dan.");
		new string[128];
		format(string, sizeof(string), "%s (%d) has quit the %s as a rank %i", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName], PlayerInfo[playerid][pRank]);
		GroupLog(PlayerInfo[playerid][pMember], string);
		if(arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] != GROUP_TYPE_CRIMINAL) ResetPlayerWeaponsEx(playerid);
		PlayerInfo[playerid][pMember] = INVALID_GROUP_ID;
		PlayerInfo[playerid][pRank] = INVALID_RANK;
		PlayerInfo[playerid][pDuty] = 0;
		PlayerInfo[playerid][pLeader] = INVALID_GROUP_ID;
		PlayerInfo[playerid][pDivision] = INVALID_DIVISION;
		strcpy(PlayerInfo[playerid][pBadge], "None", 9);
		if(!IsValidSkin(GetPlayerSkin(playerid)))
		{
  			new rand = random(sizeof(CIV));
			SetPlayerSkin(playerid,CIV[rand]);
			PlayerInfo[playerid][pModel] = CIV[rand];
		}
		SetPlayerToTeamColor(playerid);
		player_remove_vip_toys(playerid);
   		pTazer{playerid} = 0;
		DeletePVar(playerid, "HidingKnife");
		if(GetPVarType(playerid, "RepFam_TL")) Rivalry_Toggle(playerid, false);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc to chuc.");
	}
	return 1;
}

CMD:dvstorage(playerid, params[])
{
	new iGroupID = PlayerInfo[playerid][pMember];
	if((0 <= iGroupID <= MAX_GROUPS))
	{
		if(PlayerInfo[playerid][pLeader] == iGroupID)
		{
			if(IsPlayerInRangeOfPoint(playerid, 100.0, arrGroupData[iGroupID][g_fGaragePos][0], arrGroupData[iGroupID][g_fGaragePos][1], arrGroupData[iGroupID][g_fGaragePos][2]))
			{
				new vstring[3000];
				for(new i; i < MAX_DYNAMIC_VEHICLES; i++)
				{
					new iModelID = DynVehicleInfo[i][gv_iModel];
					if(400 <= iModelID < 612 && DynVehicleInfo[i][gv_igID] == iGroupID)
					{
						new vehicleName[18];
						strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
						if(DynVehicleInfo[i][gv_iDisabled] == 1) {
							format(vstring, sizeof(vstring), "%s\n(%d)%s (Da tat)", vstring, i, vehicleName);
						}
						else if(DynVehicleInfo[i][gv_iDisabled] == 2) {
							format(vstring, sizeof(vstring), "%s\n(%d) %s (Cat)", vstring, i, vehicleName, DynVehicleInfo[i][gv_iSpawnedID]);
						}
						else if(DynVehicleInfo[i][gv_iSpawnedID] != INVALID_VEHICLE_ID) {
							format(vstring, sizeof(vstring), "%s\n(%d) %s (Da tao) [VehicleID : %d]", vstring, i, vehicleName, DynVehicleInfo[i][gv_iSpawnedID]);
						}
					}
				}
				ShowPlayerDialogEx(playerid, DV_STORAGE, DIALOG_STYLE_LIST, "Kho xe dong to chuc", vstring, "Theo doi", "Huy");
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o gan garage cua to chuc!");
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong phai lanh dao to chuc!");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc to chuc!");
	return 1;
}

CMD:bug(playerid, params[])
{
	if (PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iBugAccess])
	{
        new
			iTargetID;

        if(sscanf(params, "u", iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /bug [player]");
		}
        else if(PlayerInfo[iTargetID][pAdmin] >= 2) {
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the dat may nghe len len nguoi nay.");
		}
		else if(GetPVarInt(iTargetID, "AdvisorDuty") == 1 && (GetPVarType(iTargetID, "HelpingSomeone") || GetPVarType(iTargetID, "pGodMode"))) {
    		SendClientMessageEx(playerid, COLOR_GREY, "Khong the dat may nghe len len Advisor dang truc.");
		}

  		else if(PlayerInfo[iTargetID][pBugged] != INVALID_GROUP_ID) {


    		PlayerInfo[iTargetID][pBugged] = INVALID_GROUP_ID;
			SendClientMessageEx(playerid, COLOR_GRAD1, "May nghe len tren %s da bi tat.", GetPlayerNameEx(iTargetID));
		}
		else if(ProxDetectorS(4.0, playerid, iTargetID)) {


			PlayerInfo[iTargetID][pBugged] = PlayerInfo[playerid][pMember];
		    SendClientMessageEx(playerid, COLOR_GRAD1, "Da gan may nghe len cho %s.",GetPlayerNameEx(iTargetID));
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban can o gan nguoi do.");
	} else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen truy cap tan so nay.");
	return 1;
}

CMD:gov(playerid, params[])
{
	new
		iGroupID = PlayerInfo[playerid][pLeader],
	 	iRank = PlayerInfo[playerid][pRank];

	if ((0 <= iGroupID < MAX_GROUPS) && iRank >= arrGroupData[iGroupID][g_iGovAccess]) {
		if(!isnull(params)) {
			new string[128];
			format(string, sizeof(string), "** %s %s %s: %s **", arrGroupData[iGroupID][g_szGroupName], arrGroupRanks[iGroupID][iRank], GetPlayerNameEx(playerid), params);
   			SendClientMessageToAllEx(COLOR_WHITE, "|___________ Thong bao chinh phu ___________|");
			SendClientMessageToAllEx(arrGroupData[iGroupID][g_hDutyColour] * 256 + 255, string);
			format(string, sizeof(string), "** %s %s %s(%d): %s **", arrGroupData[iGroupID][g_szGroupName], arrGroupRanks[iGroupID][iRank], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), params);
			Log("logs/gov.log", string);
		} else SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/gov)ernment [text]");
	} else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:switchgroup(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] || PlayerInfo[playerid][pFactionModerator] >= 4) {
		Group_ListGroups(playerid, DIALOG_SWITCHGROUP);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen.");
	return 1;
}

CMD:groupcsfban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 1)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /groupcsfban [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if( PlayerInfo[giveplayerid][pMember] >= 0 || PlayerInfo[giveplayerid][pLeader] >= 0 )
			{
				PlayerInfo[giveplayerid][pCSFBanned] = 1;
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban bi %s cam gia nhap TAT CA Civil Service Groups.", GetPlayerNameEx( playerid ));
				PlayerInfo[giveplayerid][pMember] = INVALID_GROUP_ID;
				PlayerInfo[giveplayerid][pLeader] = INVALID_GROUP_ID;
				PlayerInfo[giveplayerid][pDivision] = INVALID_DIVISION;
				strcpy(PlayerInfo[giveplayerid][pBadge], "None", 9);
				PlayerInfo[giveplayerid][pRank] = INVALID_RANK;
				PlayerInfo[giveplayerid][pDuty] = 0;
				PlayerInfo[giveplayerid][pModel] = NOOB_SKIN;
				SetPlayerToTeamColor(giveplayerid);
				SetPlayerSkin(giveplayerid, NOOB_SKIN);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da cam %s gia nhap moi to chuc CSF.", GetPlayerNameEx(giveplayerid));
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong the loai nguoi khong phai lanh dao / thanh vien.");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi chua ket noi.");
		}
	}
	return 1;
}

CMD:groupunban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new giveplayerid, group;
		if(sscanf(params, "ud", giveplayerid, group)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /groupunban [player] [groupid]");

		if(IsPlayerConnected(giveplayerid))
		{
			new string[256];
			SetPVarInt(playerid, "GroupUnBanningPlayer", giveplayerid);
			SetPVarInt(playerid, "GroupUnBanningGroup", group);
			mysql_format(MainPipeline, string,sizeof(string),"DELETE FROM `groupbans` WHERE  `PlayerID` = %d AND `GroupBan` = %d", GetPlayerSQLId(giveplayerid), group);
			mysql_tquery(MainPipeline, string, "Group_QueryFinish", "ii", GROUP_QUERY_UNBAN, playerid);
			SendClientMessageEx(playerid, COLOR_WHITE, "Dang go cam %s khoi to chuc %d...", GetPlayerNameEx(giveplayerid), group);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi chua ket noi.");
		}
	}
	return 1;
}


CMD:groupcsfunban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /faccsfunban [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if( PlayerInfo[giveplayerid][pCSFBanned] == 0 ) return SendClientMessageEx( playerid, COLOR_WHITE, "Nguoi do khong bi cam Civil Service Groups." );
			PlayerInfo[giveplayerid][pCSFBanned] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "Da go cam %s khoi tat ca Civil Service Groups.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban da duoc %s go cam Civil Service Groups.", GetPlayerNameEx(playerid));
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi chua ket noi.");
		}
	}
	return 1;
}

CMD:groupban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 1)
	{
		new giveplayerid, group , reason[64];
		if(sscanf(params, "uds[64]", giveplayerid, group, reason))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /groupban [player] [group id] [reason]");
			return 1;
		}

		if(IsPlayerConnected(giveplayerid))
		{
			if( group >= 0 && group < MAX_GROUPS )
			{
				SetPVarInt(playerid, "GroupBanningPlayer", giveplayerid);
				SetPVarInt(playerid, "GroupBanningGroup", group);
				new string[256];
				mysql_format(MainPipeline, string,sizeof(string),"INSERT INTO `groupbans` (`PlayerID`, `GroupBan`, `BanReason`, `BanDate`) VALUES (%d, %d, '%e', NOW())", GetPlayerSQLId(giveplayerid), group, reason);
				mysql_tquery(MainPipeline, string, "Group_QueryFinish", "ii", GROUP_QUERY_ADDBAN, playerid);
			    SendClientMessageEx(playerid, COLOR_WHITE, "Dang cam %s khoi to chuc %d...", GetPlayerNameEx(giveplayerid), group);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "ID to chuc khong hop le.");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi chua ket noi.");
		}
	}
	return 1;
}

CMD:showbadge(playerid, params[])
{
	if(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] != GROUP_TYPE_CRIMINAL && arrGroupData[PlayerInfo[playerid][pMember]][g_iCrimeType] != GROUP_CRIMINAL_TYPE_RACE))
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /showbadge [player]");

		if(giveplayerid != INVALID_PLAYER_ID) {
			if(ProxDetectorS(5.0, playerid, giveplayerid)) {

				new	infoArrays[3][GROUP_MAX_NAME_LEN], badge[11];

				GetPlayerGroupInfo(playerid, infoArrays[0], infoArrays[1], infoArrays[2]);
				if(strcmp(PlayerInfo[playerid][pBadge], "None", true) != 0) format(badge, sizeof(badge), "[%s] ", PlayerInfo[playerid][pBadge]);

				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "----------------------------------------------------------------------------------------------------");
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "%s%s %s la thanh vien tuyen the cua %s.", badge, infoArrays[0], GetPlayerNameEx(playerid), infoArrays[2]);
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "Nhiem vu hien tai: %s.", infoArrays[1]);
				switch(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance]) {
					case 1: SendClientMessageEx(giveplayerid, COLOR_WHITE, "Duoi tham quyen cua San Andreas Government.");
					case 2: SendClientMessageEx(giveplayerid, COLOR_WHITE, "Duoi tham quyen cua Nation of New Robada.");
				}
				if(IsACop(playerid)) SendClientMessageEx(giveplayerid, COLOR_WHITE, "Nhan vien co quyen bat giu.");
				else if(arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] != 2) SendClientMessageEx(giveplayerid, COLOR_WHITE, "Nhan vien co quyen ho tro bat giu.");
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "----------------------------------------------------------------------------------------------------");
				format(string, sizeof(string), "* %s cho %s xem phu hieu.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxChatBubble(playerid, string);
				// ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

			} else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
		} else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	} else SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong thuoc Civil Service Group.");
	return 1;
}

CMD:groupkick(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 1)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /groupkick [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pMember] >= 0 || PlayerInfo[giveplayerid][pLeader] >= 0)
			{
				format(string, sizeof(string), "Administrator %s has group-kicked %s (%d) from %s (%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), arrGroupData[PlayerInfo[giveplayerid][pMember]][g_szGroupName], PlayerInfo[giveplayerid][pMember]+1);
				GroupLog(PlayerInfo[giveplayerid][pMember], string);
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban da bi %s loai khoi to chuc.", GetPlayerNameEx( playerid ));
				arrGroupData[PlayerInfo[giveplayerid][pMember]][g_iMemberCount]--;
				PlayerInfo[giveplayerid][pDuty] = 0;
				PlayerInfo[giveplayerid][pMember] = INVALID_GROUP_ID;
				PlayerInfo[giveplayerid][pRank] = INVALID_RANK;
				PlayerInfo[giveplayerid][pLeader] = INVALID_GROUP_ID;
				PlayerInfo[giveplayerid][pDivision] = INVALID_DIVISION;
				strcpy(PlayerInfo[giveplayerid][pBadge], "None", 9);
				if(!IsValidSkin(GetPlayerSkin(giveplayerid)))
				{
					new rand = random(sizeof(CIV));
					SetPlayerSkin(giveplayerid,CIV[rand]);
					PlayerInfo[giveplayerid][pModel] = CIV[rand];
				}
				player_remove_vip_toys(giveplayerid);
				pTazer{giveplayerid} = 0;
				DeletePVar(giveplayerid, "HidingKnife");
				SetPlayerToTeamColor(giveplayerid);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da loai %s khoi to chuc.", GetPlayerNameEx(giveplayerid));
				if(GetPVarType(giveplayerid, "RepFam_TL")) Rivalry_Toggle(giveplayerid, false);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong the loai nguoi khong phai thanh vien to chuc.");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		}
	}
	return 1;
}

CMD:m(playerid, params[]) {
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	if(!isnull(params)) {
		if(IsACop(playerid) || IsAMedic(playerid) || IsAHitman(playerid) || IsAGovernment(playerid) || IsAJudge(playerid) || (IsATowman(playerid) && PlayerInfo[playerid][pRank] > 1)) {
			new
				szMessage[128];

			format(szMessage, sizeof(szMessage), "(megaphone) %s: %s", GetPlayerNameEx(playerid), params);
			ProxDetector(60.0, playerid, szMessage, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW,1);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "   Ban khong co quyen dung loa.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/m)egaphone [megaphone chat]");
	return 1;
}



alias:r("radio")
CMD:r(playerid, params[]) {
	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	new
		iGroupID = PlayerInfo[playerid][pMember],
		iRank = PlayerInfo[playerid][pRank];

	if (0 <= iGroupID < MAX_GROUPS) {
 		if (iRank >= arrGroupData[iGroupID][g_iRadioAccess]) {
			if(PlayerInfo[playerid][pToggledChats][CHAT_GROUP_RADIO] == 0) {
				if(!isnull(params))
				{
					new string[128], employer[GROUP_MAX_NAME_LEN], rank[GROUP_MAX_RANK_LEN], division[GROUP_MAX_DIV_LEN];
					format(string, sizeof(string), "(radio) %s", params);
					SetPlayerChatBubble(playerid, string, COLOR_WHITE, 15.0, 5000);
					GetPlayerGroupInfo(playerid, rank, division, employer);
					if(strcmp(PlayerInfo[playerid][pBadge], "None", true) != 0) format(string, sizeof(string), "** [%s] %s %s: %s **", PlayerInfo[playerid][pBadge], rank, GetPlayerNameEx(playerid), params);
					else format(string, sizeof(string), "** %s (%s) %s: %s **", rank, division, GetPlayerNameEx(playerid), params);

					foreach(new i: Player)
					{
						if(PlayerInfo[playerid][pToggledChats][CHAT_GROUP_RADIO] == 0)
						{
							if(PlayerInfo[i][pMember] == iGroupID && iRank >= arrGroupData[iGroupID][g_iRadioAccess]) {
								ChatTrafficProcess(i, arrGroupData[iGroupID][g_hRadioColour] * 256 + 255, string, CHAT_GROUP_RADIO);
							}
							if(GetPVarInt(i, "BigEar") == 4 && GetPVarInt(i, "BigEarGroup") == iGroupID) {
								new szBigEar[128];
								format(szBigEar, sizeof(szBigEar), "(BE) %s", string);
								ChatTrafficProcess(i, arrGroupData[iGroupID][g_hRadioColour] * 256 + 255, szBigEar, CHAT_GROUP_RADIO);
							}
						}
					}
				}
				else return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/r)adio [radio chat]");
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "Radio dang tat, dung /tog radio de bat lai.");
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen truy cap tan so nay.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc to chuc.");
	return 1;
}



CMD:togint(playerid, params[]) {
	return ToggleAccountSetting(playerid, CHAT_INTERNATIONAL);
}

alias:international("int")
CMD:international(playerid, params[])
{

	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	new iGroupID = PlayerInfo[playerid][pMember],
	    iRank = PlayerInfo[playerid][pRank];

	if(PlayerInfo[playerid][pToggledChats][CHAT_INTERNATIONAL]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da tat chat quoc te.");
	if(0 <= iGroupID < MAX_GROUPS)
	{
	    if(iRank >= arrGroupData[iGroupID][g_iIntRadioAccess])
	    {
	        if(!isnull(params))
	        {
	            new szRadio[128], szEmployer[GROUP_MAX_NAME_LEN], szRank[GROUP_MAX_RANK_LEN], szDivision[GROUP_MAX_DIV_LEN];
	            GetPlayerGroupInfo(playerid, szRank, szDivision, szEmployer);
	            format(szRadio, sizeof(szRadio), "** %s %s (%s) %s: %s **", szEmployer, szRank, szDivision, GetPlayerNameEx(playerid), params);
	            foreach(new i: Player)
				{
					if((0 <= PlayerInfo[i][pMember] < MAX_GROUPS) && PlayerInfo[i][pRank] >= arrGroupData[PlayerInfo[i][pMember]][g_iIntRadioAccess]) {
						ChatTrafficProcess(i, 0x869688FF, szRadio, CHAT_INTERNATIONAL);
					}
				}
	            format(szRadio, sizeof(szRadio), "(radio) %s", params);
             	SetPlayerChatBubble(playerid, szRadio, COLOR_WHITE, 15.0, 5000);
             }
             else return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/int(ernational) [text]");
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen truy cap tan so nay!");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc to chuc!");
	return 1;
}

CMD:togdept(playerid, params[])
{
	return ToggleAccountSetting(playerid, CHAT_DEPARTMENT);
}

CMD:dept(playerid, params[])
{

	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	new
		iGroupID = PlayerInfo[playerid][pMember],
		iRank = PlayerInfo[playerid][pRank];

	if(0 <= iGroupID < MAX_GROUPS)
	{
		if(iRank >= arrGroupData[iGroupID][g_iDeptRadioAccess])
		{
			if(PlayerInfo[playerid][pToggledChats][CHAT_DEPARTMENT] == 0)
			{
				if(!isnull(params))
				{
					new szRadio[128], RadioBubble[128], szEmployer[GROUP_MAX_NAME_LEN], szRank[GROUP_MAX_RANK_LEN], szDivision[GROUP_MAX_DIV_LEN];
					GetPlayerGroupInfo(playerid, szRank, szDivision, szEmployer);
					if(strcmp(PlayerInfo[playerid][pBadge], "None", true) != 0) format(szRadio, sizeof(szRadio), "** [%s] %s %s %s: %s **", PlayerInfo[playerid][pBadge], szEmployer, szRank, GetPlayerNameEx(playerid), params);
					else format(szRadio, sizeof(szRadio), "** %s %s (%s) %s: %s **", szEmployer, szRank, szDivision, GetPlayerNameEx(playerid), params);
					format(RadioBubble, sizeof(RadioBubble), "(radio) %s",params);
					SetPlayerChatBubble(playerid, RadioBubble, COLOR_WHITE, 15.0, 5000);
					foreach(new i: Player)
					{
						if(PlayerInfo[playerid][pToggledChats][CHAT_DEPARTMENT] == 0)
						{
							if((0 <= PlayerInfo[i][pMember] < MAX_GROUPS) && PlayerInfo[i][pRank] >= arrGroupData[PlayerInfo[i][pMember]][g_iDeptRadioAccess] && arrGroupData[iGroupID][g_iAllegiance] == arrGroupData[PlayerInfo[i][pMember]][g_iAllegiance])
							{
								ChatTrafficProcess(i, DEPTRADIO, szRadio, CHAT_DEPARTMENT);
							}
							else if(GetPVarInt(i, "BigEar") == 4 && GetPVarInt(i, "BigEarGroup") == iGroupID)
							{
								new szBigEar[128];
								format(szBigEar, sizeof(szBigEar), "(BE) %s", szRadio);
								ChatTrafficProcess(i, iGroupID, szBigEar, CHAT_DEPARTMENT);
							}
							else if((PlayerInfo[i][pMember] == INVALID_GROUP_ID || (0 <= PlayerInfo[i][pMember] < MAX_GROUPS) && PlayerInfo[i][pRank] < arrGroupData[PlayerInfo[i][pMember]][g_iDeptRadioAccess]) && PlayerInfo[i][pReceiver] > 0)
							{
								if(GetPVarType(i, "pReceiverOn"))
								{
									if(GetPVarInt(i, "pReceiverMLeft") > 0)
									{
										format(szRadio, sizeof(szRadio), "** (receiver) %s: %s", GetPlayerNameEx(playerid), params);
										ChatTrafficProcess(i, DEPTRADIO, szRadio, CHAT_DEPARTMENT);
										SetPVarInt(i, "pReceiverMLeft", GetPVarInt(i, "pReceiverMLeft") - 1);
									}
									else
									{
										PlayerInfo[i][pReceiver]--;
										SetPVarInt(i, "pReceiverMLeft", 4);
										return SendClientMessageEx(i, DEPTRADIO, "May thu cua ban da het pin!");
									}
								}
							}
						}
					}
				}
				else return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/dept) [department chat]");
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "Radio lien nganh dang tat, dung /togdept de bat.");
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen truy cap tan so nay.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc to chuc.");
	return 1;
}

CMD:togradio(playerid, params[])
{
	return ToggleAccountSetting(playerid, CHAT_GROUP_RADIO);
}

CMD:makeleader(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /makeleader [player]");
		}
		else {
			if(IsPlayerConnected(giveplayerid))	{
   				SetPVarInt(playerid, "MakingLeader", giveplayerid);
   				SetPVarInt(playerid, "MakingLeaderSQL", GetPlayerSQLId(giveplayerid));
				Group_ListGroups(playerid, DIALOG_MAKELEADER);
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");

	return 1;
}

CMD:leaders(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3 || PlayerInfo[playerid][pFactionModerator] >= 1) {
		SendClientMessageEx(playerid, COLOR_WHITE, "Lanh dao to chuc online:");

		new	sz_FacInfo[3][64];

		foreach(new i: Player)
		{
			if(PlayerInfo[i][pLeader] >= 0) {
				GetPlayerGroupInfo(i, sz_FacInfo[0], sz_FacInfo[1], sz_FacInfo[2]);
				SendClientMessageEx(playerid, COLOR_GRAD2, "(%s) %s %s", sz_FacInfo[2], sz_FacInfo[0], GetPlayerNameEx(i));
			}
		}
	} else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:hfind(playerid, params[])
{
	if (IsAHitman(playerid) || (PlayerInfo[playerid][pMember] != INVALID_GROUP_ID && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iFindAccess]) || (PlayerInfo[playerid][pAdmin] >= 2 && PlayerInfo[playerid][pTogReports] != 1))
	{
	    if(GetPVarType(playerid, "HfindCount")) {
	    	SendClientMessageEx(playerid, COLOR_GRAD2, "Truy tim bi gian doan.");
	    	DeletePVar(playerid, "HfindCount");
	    	return 1;
	    }

	    if(GetPVarType(playerid, "hFind")) {
	   		SendClientMessageEx(playerid, COLOR_GRAD2, "Da dung cap nhat");
	        DeletePVar(playerid, "hFind");
	        DisablePlayerCheckpoint(playerid);
		}
		else
		{
			new	iTargetID;

			if(CheckPointCheck(playerid)) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung lenh nay!");
			}
			if(sscanf(params, "u", iTargetID)) {
				return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /hfind [player]");
			}
			else if(iTargetID == playerid) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh nay voi chinh minh.");
			}

			else if(!IsPlayerConnected(iTargetID)) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
			}
			else if(GetPlayerInterior(iTargetID) != 0) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang trong noi that.");
			}
			else if((PlayerInfo[iTargetID][pAdmin] >= 2 || PlayerInfo[iTargetID][pWatchdog] >= 2) && PlayerInfo[iTargetID][pTogReports] != 1) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Khong the tim nguoi nay.");
			}
			else if (GetPVarInt(playerid, "_SwimmingActivity") >= 1) {
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the tim nguoi khi dang boi.");
			}
			if (GetPVarInt(playerid, "_SwimmingActivity") >= 1)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "  Ban phai ngung boi truoc! (/stopswimming)");
				return 1;
			}
			if(PhoneOnline[iTargetID] == 0 && PlayerInfo[iTargetID][pPnumber] != 0 || (PlayerInfo[iTargetID][pBugged] == PlayerInfo[playerid][pMember] || (PlayerInfo[playerid][pAdmin] >= 2 && PlayerInfo[playerid][pTogReports] != 1)))
			{
				SetPVarInt(playerid, "HfindCount", 15);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bat dau truy tim, dung /hfind lan nua de dung.");
				SetTimerEx("HitmanTrace", 1000, false, "ii", playerid, iTargetID);
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the truy tim nguoi nay.");
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

forward HitmanTrace(playerid, iTargetID);
public HitmanTrace(playerid, iTargetID) {

	new iTraceCount = GetPVarInt(playerid, "HfindCount");
	if(PlayerInfo[iTargetID][pBugged] == PlayerInfo[playerid][pMember]) iTraceCount = 0;

	if(CheckPointCheck(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung lenh nay!");
	if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	if(GetPlayerInterior(iTargetID) != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang trong noi that.");
	if((PlayerInfo[iTargetID][pAdmin] >= 2 || PlayerInfo[iTargetID][pWatchdog] >= 2) && PlayerInfo[iTargetID][pTogReports] != 1) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the tim nguoi nay.");
	if(GetPVarInt(playerid, "_SwimmingActivity") >= 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the tim nguoi khi dang boi.");
	if (GetPVarInt(playerid, "_SwimmingActivity") >= 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "  Ban phai ngung boi truoc! (/stopswimming)");
	if((PhoneOnline[iTargetID] > 0 || PlayerInfo[iTargetID][pPnumber] == 0 ) && PlayerInfo[iTargetID][pBugged] != PlayerInfo[playerid][pMember]) return SendClientMessageEx(playerid, COLOR_GREY, "Truy tim da bi gian doan.");
	if(!GetPVarType(playerid, "HfindCount")) return SendClientMessageEx(playerid, COLOR_WHITE,  "Da xay ra loi!");


	if(iTraceCount >= 1) {
		SetPVarInt(playerid, "HfindCount", --iTraceCount);
		format(szMiscArray, sizeof(szMiscArray), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~Do tin hieu: con %d giay", iTraceCount);
		GameTextForPlayer(playerid, szMiscArray, 1100, 3);
		SetTimerEx("HitmanTrace", 1000, false, "ii", playerid, iTargetID);
	}
	else if(iTraceCount == 0) {
		GameTextForPlayer(playerid, "Da ket noi theo doi", 1100, 3);

		new
			szZone[MAX_ZONE_NAME];

		new Float:X, Float:Y, Float:Z;
	    GetPlayerPos(iTargetID, X, Y, Z);
	    DisablePlayerCheckpoint(playerid);
	    SetPlayerCheckpoint(playerid, X, Y, Z, 4.0);
		GetPlayer3DZone(iTargetID, szZone, sizeof(szZone));
		SendClientMessageEx(playerid, COLOR_GRAD2, "Dang theo doi %s, lan cuoi o %s.", GetPlayerNameEx(iTargetID), szZone);
		SendClientMessageEx(playerid, COLOR_GRAD2, "Dung /hfind lan nua de dung theo doi.");
		SetPVarInt(playerid, "hFind", iTargetID);
		DeletePVar(playerid, "HfindCount");
	}

	return 1;
}


alias:g("f")
CMD:g(playerid, params[])
{

	if(PlayerTied[playerid] != 0 || PlayerCuffed[playerid] != 0 || PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam viec nay.");
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	new iGroupID = PlayerInfo[playerid][pMember],
		iRank = PlayerInfo[playerid][pRank];
	if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/g)roup [group chat]");
	if(iGroupID == INVALID_GROUP_ID) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong thuoc to chuc nao!");
	if(iRank >= arrGroupData[iGroupID][g_iOOCChat])
	{
		new string[128];
		format(string, sizeof(string), "** (%d) %s (%s) %s: %s **", iRank, arrGroupRanks[iGroupID][iRank], (0 <= PlayerInfo[playerid][pDivision] < MAX_GROUP_DIVS && arrGroupDivisions[iGroupID][PlayerInfo[playerid][pDivision]][0] ? arrGroupDivisions[iGroupID][PlayerInfo[playerid][pDivision]]:("None")), GetPlayerNameEx(playerid), params);
		foreach(new i: Player) {
			if(PlayerInfo[i][pMember] == iGroupID) {

				ChatTrafficProcess(i, arrGroupData[iGroupID][g_hOOCColor] * 256 + 255, string, CHAT_GROUP_OOC);
			}
		}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the dung lenh nay.");
	return 1;
}

CMD:togfam(playerid, params[])
{
	return ToggleAccountSetting(playerid, CHAT_GROUP_OOC);
}

CMD:locker(playerid, const params[]) {

	new
		iGroupID = PlayerInfo[playerid][pMember],
		szTitle[18 + GROUP_MAX_NAME_LEN],
		szDialog[172];

	if(PlayerInfo[playerid][pWRestricted] != 0 || PlayerInfo[playerid][pConnectHours] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay khi bi han che vu khi.");
	if(HungerPlayerInfo[playerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   Khong the lam vay trong Hunger Games Event!");
	if(zombieevent && GetPVarType(playerid, "pIsZombie")) return SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the dung.");
	if(0 <= iGroupID < MAX_GROUPS)
	{
		for(new i; i < MAX_GROUPS; i++)
		{
			for(new j; j < MAX_GROUP_LOCKERS; j++)
			{
				if(IsPlayerInRangeOfPoint(playerid, 3.0, arrGroupLockers[i][j][g_fLockerPos][0], arrGroupLockers[i][j][g_fLockerPos][1], arrGroupLockers[i][j][g_fLockerPos][2]) && arrGroupLockers[i][j][g_iLockerVW] == GetPlayerVirtualWorld(playerid))
				{
					if(i == iGroupID || (arrGroupData[i][g_iGroupType] == arrGroupData[iGroupID][g_iGroupType] && arrGroupLockers[i][j][g_iLockerShare]))
					{
					    format(szTitle, sizeof(szTitle), "%s Menu tu do", arrGroupData[iGroupID][g_szGroupName]);
					    if(arrGroupData[iGroupID][g_iLockerCostType] == 0) {
					        if(arrGroupData[iGroupID][g_iLockerStock] > 100)
					        {
					        	format(szTitle, sizeof(szTitle), "%s - Ton kho tu: %d", szTitle, arrGroupData[iGroupID][g_iLockerStock]);
							}
							else
							{
							    format(szTitle, sizeof(szTitle), "%s - {AA3333}Ton kho tu: %d", szTitle, arrGroupData[iGroupID][g_iLockerStock]);
							}
					    }
					    if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_CRIMINAL /*|| arrGroupData[iGroupID][g_iGroupType] == GROUP_CRIMINAL_TYPE_RACE*/)
					    {
					    	format(szDialog, sizeof(szDialog), "Quan ao\nVu khi\nChuyen thung\nMa tuy\nVat lieu (%i)\nKet tien ($%s)",
					    		arrGroupData[iGroupID][g_iMaterials],
					    		number_format(arrGroupData[iGroupID][g_iBudget])
					    	);
					    	return ShowPlayerDialogEx(playerid, G_LOCKER_MAIN, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
					    }
					    /* if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_CRIMINAL || arrGroupData[iGroupID][g_iGroupType] == GROUP_CRIMINAL_TYPE_RACE)
					    {
					    	format(szDialog, sizeof(szDialog), "Clothes\nWeapons\nCannabis (%i)\nCrack (%i)\nHeroin (%i)\nSyringes (%i)\nOpium (%i)\nMaterials (%i)\nVault ($%s)\nAmmo",
					    		arrGroupData[iGroupID][g_iPot],
					    		arrGroupData[iGroupID][g_iCrack],
					    		arrGroupData[iGroupID][g_iHeroin],
					    		arrGroupData[iGroupID][g_iSyringes],
					    		arrGroupData[iGroupID][g_iOpium],
					    		arrGroupData[iGroupID][g_iMaterials],
					    		number_format(arrGroupData[iGroupID][g_iBudget])
					    	);
					    	return ShowPlayerDialogEx(playerid, G_LOCKER_MAIN, DIALOG_STYLE_LIST, szTitle, szDialog, "Select", "Cancel");
					    }*/

					    if(PlayerInfo[playerid][pRank] >= arrGroupData[iGroupID][g_iFreeNameChange] && (PlayerInfo[playerid][pDivision] == arrGroupData[iGroupID][g_iFreeNameChangeDiv] || arrGroupData[iGroupID][g_iFreeNameChangeDiv] == INVALID_DIVISION)) // name-change point in faction lockers for free namechange factions
						{
							format(szDialog, sizeof(szDialog), "Ca truc\nVu khi\nChuyen thung\nDong phuc%s", (arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_LEA) ? ("\nXoa truy na\nFirst Aid & Kevlar\nPortable Medkit & Vest Kit\nTazer & Cuffs\nDoi ten\nPhu kien") : ((arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_MEDIC || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_GOV) ? ("\nPortable Medkit & Vest Kit\nFirst Aid & Kevlar\nDoi ten") : ("")));
						}
						else if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_GOV) {
							format(szDialog, sizeof(szDialog), "Ca truc\nVu khi\nChuyen thung\nDong phuc\nPortable Medkit & Vest Kit\nFirst Aid & Kevlar");
						}
						else
						{
							format(szDialog, sizeof(szDialog), "Ca truc\nVu khi\nChuyen thung\nDong phuc%s", (arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_LEA) ? ("\nXoa truy na\nFirst Aid & Kevlar\nPortable Medkit & Vest Kit\nTazer & Cuffs\nPhu kien") : ((arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_MEDIC || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_NEWS || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_GOV || arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_TOWING) ? ("\nPortable Medkit & Vest Kit\nFirst Aid & Kevlar") : ("")));
						}
						ShowPlayerDialogEx(playerid, G_LOCKER_MAIN, DIALOG_STYLE_LIST, szTitle, szDialog, "Chon", "Huy");
						return 1;
					}
					else
					{
					    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the dung tu nay.");
						return 1;
					}
				}
			}
		}
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan tu do!");
	return 1;
}

CMD:editgroup(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2)
	{
		Group_ListGroups(playerid);
	}
	return 1;
}

CMD:groupaddjurisdiction(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pFactionModerator] >= 2) Group_ListGroups(playerid, DIALOG_GROUP_JURISDICTION_ADD);
	return 1;
}

CMD:uninvite(playerid, params[]) {
	if(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS) {

		new
			iTargetID,
			iGroupID = PlayerInfo[playerid][pLeader];

		if(sscanf(params, "u", iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /uninvite [player]");
		}
		else if(IsPlayerConnected(iTargetID)) {
			if(iGroupID == PlayerInfo[iTargetID][pMember]) {
				if(playerid == iTargetID) {
					SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu loai minh.");
				}
				else if(PlayerInfo[playerid][pRank] > PlayerInfo[iTargetID][pRank] || PlayerInfo[playerid][pRank] >= Group_GetMaxRank(iGroupID)) {

					new
						szMessage[128],
						iRank = PlayerInfo[playerid][pRank];

					SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "%s %s da loai ban khoi %s.", arrGroupRanks[iGroupID][iRank], GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
					SendClientMessageEx(iTargetID, COLOR_WHITE, "Ban da tro lai lam cong dan.");

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da loai %s khoi to chuc.", GetPlayerNameEx(iTargetID));

					format(szMessage, sizeof szMessage, "%s %s (%d) (rank %i) has uninvited %s (%d) (rank %i) from %s (%i).", arrGroupRanks[iGroupID][iRank], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), iRank, GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), PlayerInfo[iTargetID][pRank], arrGroupData[iGroupID][g_szGroupName], iGroupID + 1);
					GroupLog(iGroupID, szMessage);

					arrGroupData[iGroupID][g_iMemberCount]--;
					PlayerInfo[iTargetID][pMember] = INVALID_GROUP_ID;
					PlayerInfo[iTargetID][pDivision] = -1;
					strcpy(PlayerInfo[iTargetID][pBadge], "None", 9);
					PlayerInfo[iTargetID][pLeader] = INVALID_GROUP_ID;
					PlayerInfo[iTargetID][pDuty] = 0;
					PlayerInfo[iTargetID][pRank] = INVALID_RANK;
					PlayerInfo[iTargetID][pModel] = NOOB_SKIN;
					SetPlayerSkin(iTargetID, NOOB_SKIN);

					SetPlayerToTeamColor(iTargetID);
					pTazer{iTargetID} = 0;
					if(GetPVarType(iTargetID, "RepFam_TL")) Rivalry_Toggle(iTargetID, false);

				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay voi nguoi ngang hoac cao cap hon.");
			}
			else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong thuoc to chuc cua ban.");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Chi lanh dao to chuc duoc dung lenh nay.");
	return 1;
}

CMD:ouninvite(playerid, params[]) {
	if(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS) {
		if(!isnull(params)) {

			if (IsPlayerConnected(ReturnUser(params)))
			{
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do dang online, dung /uninvite.");
			}
			new
				szQuery[96],
				szName[MAX_PLAYER_NAME],
				iPos;

			mysql_escape_string(params, szName);
			mysql_format(MainPipeline, szQuery, sizeof szQuery, "SELECT `Member`, `Rank`, `id` FROM `accounts` WHERE `Username` = '%s'", szName);
			mysql_tquery(MainPipeline, szQuery, "Group_QueryFinish", "ii", GROUP_QUERY_UNCHECK, playerid);

			while((iPos = strfind(szName, "_", false, iPos)) != -1) szName[iPos] = ' ';
			SetPVarString(playerid, "Group_Uninv", szName);

			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Dang loai %s khoi to chuc, vui long cho...", szName);
		}
		else SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /ouninvite [account name]");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Chi lanh dao to chuc duoc dung lenh nay.");
	return 1;
}

CMD:giverank(playerid, params[]) {
	if(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS) {

		new
			iTargetID,
			iRank,
			iGroupID = PlayerInfo[playerid][pLeader],
            szMessage[128];

		if(sscanf(params, "ui", iTargetID, iRank)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /giverank [player] [rank]");
		}
		else if(!(0 <= iRank <= Group_GetMaxRank(iGroupID))) {
			SendClientMessageEx(playerid, COLOR_GREY, "Rank sai (phai tu 0 den %d)", Group_GetMaxRank(iGroupID));
		}
		else if(IsPlayerConnected(iTargetID)) {
			if(iGroupID == PlayerInfo[iTargetID][pMember]) {
				if(iRank == PlayerInfo[iTargetID][pRank]) {
					SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da co rank nay.");
				}
				else if(playerid == iTargetID) {
					SendClientMessageEx(playerid, COLOR_GREY, "Khong the tu doi rank!");
				}
				if(PlayerInfo[iTargetID][pRank] > PlayerInfo[playerid][pRank])
		    	{
			        SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh voi nguoi rank cao hon!");
			        return 1;
		    	}
				else if(PlayerInfo[playerid][pRank] > PlayerInfo[iTargetID][pRank] || PlayerInfo[playerid][pRank] >= Group_GetMaxRank(iGroupID) || PlayerInfo[playerid][pAdmin] >= 4) {

					SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "%s %s da %s ban len rank %s.", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), ((iRank > PlayerInfo[iTargetID][pRank]) ? ("thang cap") : ("ha cap")), arrGroupRanks[iGroupID][iRank]);

					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da %s %s len rank %s.", ((iRank > PlayerInfo[iTargetID][pRank]) ? ("thang cap") : ("ha cap")), GetPlayerNameEx(iTargetID), arrGroupRanks[iGroupID][iRank]);

					format(szMessage, sizeof szMessage, "%s %s (%d) (rank %i) has given %s (%d) rank %i (%s) in %s (%i).", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), PlayerInfo[playerid][pRank], GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), iRank, arrGroupRanks[iGroupID][iRank], arrGroupData[iGroupID][g_szGroupName], iGroupID + 1);
					GroupLog(iGroupID, szMessage);

					PlayerInfo[iTargetID][pRank] = iRank;
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Khong the lam vay voi nguoi ngang hoac cao cap hon.");
			}
			else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong thuoc to chuc cua ban.");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Chi lanh dao to chuc duoc dung lenh nay.");
	return 1;
}

CMD:setdivname(playerid, params[])
{
	if(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS)
	{
		new
			iDiv,
			iName[GROUP_MAX_DIV_LEN],
			iGroupID = PlayerInfo[playerid][pLeader],
			szMessage[128];

		if(sscanf(params, "is[16]", iDiv, iName))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setdivname [division] [name] -- Dung 'none' lam ten de xoa division");
			format(szMessage, sizeof(szMessage), "%s", "0 (None), ");
			for(new i; i < MAX_GROUP_DIVS; i++)
			{
			    if(arrGroupDivisions[iGroupID][i][0]) format(szMessage, sizeof(szMessage), "%s%d (%s), ", szMessage, i+1, arrGroupDivisions[iGroupID][i]);
				if(strlen(szMessage) > 64 || i == (MAX_GROUP_DIVS -1) && strlen(szMessage)) { SendClientMessageEx(playerid, COLOR_GRAD2, szMessage); szMessage[0] = 0; }

			}
		}
		else if(!(1 <= iDiv <= Group_GetMaxDiv(iGroupID)+1))
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "Division sai! Phai tu 1 den %d.", Group_GetMaxDiv(iGroupID) + 1);
		}
		else if(strlen(iName) > sizeof(iName))
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "Ten Division phai ngan hon %d ky tu!", sizeof(iName));
		}
		else
		{
			iDiv = iDiv - 1;
			if(strcmp(iName, "none", true) == 0)
			{
				format(szMessage, sizeof(szMessage), "** %s da xoa Division %s (#%i) **", GetPlayerNameEx(playerid), arrGroupDivisions[iGroupID][iDiv], iDiv + 1);
				foreach(new i: Player)
				{
					if(PlayerInfo[i][pToggledChats][CHAT_GROUP_RADIO] == 0)
					{
						if(PlayerInfo[i][pMember] == iGroupID) SendClientMessageEx(i, arrGroupData[iGroupID][g_hRadioColour] * 256 + 255, szMessage);
						if(GetPVarInt(i, "BigEar") == 4 && GetPVarInt(i, "BigEarGroup") == iGroupID)
						{
							SendClientMessageEx(i, arrGroupData[iGroupID][g_hRadioColour] * 256 + 255, "(BE) %s", szMessage);
						}
					}
				}
				format(szMessage, sizeof szMessage, "%s (%d) has removed the %s division (#%i)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), arrGroupDivisions[iGroupID][iDiv], iDiv + 1);
				GroupLog(iGroupID, szMessage);
			}
			else
			{
				format(szMessage, sizeof(szMessage), "** %s doi ten Division %s (#%i) thanh %s **", GetPlayerNameEx(playerid), arrGroupDivisions[iGroupID][iDiv], iDiv + 1, iName);
				foreach(new i: Player)
				{
					if(PlayerInfo[i][pToggledChats][CHAT_GROUP_RADIO] == 0)
					{
						if(PlayerInfo[i][pMember] == iGroupID) SendClientMessageEx(i, arrGroupData[iGroupID][g_hRadioColour] * 256 + 255, szMessage);
						if(GetPVarInt(i, "BigEar") == 4 && GetPVarInt(i, "BigEarGroup") == iGroupID)
						{
							SendClientMessageEx(i, arrGroupData[iGroupID][g_hRadioColour] * 256 + 255, "(BE) %s", szMessage);
						}
					}
				}
				format(szMessage, sizeof szMessage, "%s (%d) has renamed the %s division (#%i) to %s", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), arrGroupDivisions[iGroupID][iDiv], iDiv + 1, iName);
				GroupLog(iGroupID, szMessage);
			}
			mysql_escape_string(iName, arrGroupDivisions[iGroupID][iDiv]);
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:setdiv(playerid, params[]) {
	if(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS) {

		new
			iTargetID,
			iDiv,
			iGroupID = PlayerInfo[playerid][pLeader],
			szMessage[128];

		if(sscanf(params, "ui", iTargetID, iDiv)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setdiv [player] [div]");
			format(szMessage, sizeof(szMessage), "%s", "0 (None), ");
			for(new i; i < MAX_GROUP_DIVS; i++)
			{
			    if(arrGroupDivisions[iGroupID][i][0]) format(szMessage, sizeof(szMessage), "%s%d (%s), ", szMessage, i+1, arrGroupDivisions[iGroupID][i]);
				if(strlen(szMessage) > 64 || i == (MAX_GROUP_DIVS -1) && strlen(szMessage)) { SendClientMessageEx(playerid, COLOR_GRAD2, szMessage); szMessage[0] = 0; }

			}
		}
		else if(!(0 <= iDiv <= Group_GetMaxDiv(iGroupID)+1)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Division sai (phai tu 0 den %d)", Group_GetMaxDiv(iGroupID) + 1);
		}
		else if(IsPlayerConnected(iTargetID)) {
			if(iGroupID == PlayerInfo[iTargetID][pMember]) {
				if(iDiv - 1 == PlayerInfo[iTargetID][pDivision]) {
					if (iDiv == 0) SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua co Division.");
					else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da thuoc Division nay.");
				}
				else if(PlayerInfo[playerid][pLeader] == iGroupID || PlayerInfo[playerid][pDivision] == PlayerInfo[iTargetID][pDivision] || PlayerInfo[playerid][pRank] >= (Group_GetMaxRank(iGroupID) - 3)) {

					if(iDiv == 0)
					{
						SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "Ban da bi %s loai khoi Division hien tai.", GetPlayerNameEx(playerid));
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da loai %s khoi Division cua ho.", GetPlayerNameEx(iTargetID));
						format(szMessage, sizeof szMessage, "%s %s (%d) has kicked %s (%d) out of their division in %s (%d).", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), arrGroupData[iGroupID][g_szGroupName], iGroupID + 1);
						GroupLog(iGroupID, szMessage);
					}
					else
					{
						SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "%s %s da gan ban vao Division %s.", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), arrGroupDivisions[iGroupID][iDiv-1]);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da gan %s vao Division %s.", GetPlayerNameEx(iTargetID), arrGroupDivisions[iGroupID][iDiv-1]);
						format(szMessage, sizeof szMessage, "%s %s (%d) has set %s's (%d) division to %s in %s (%d).", arrGroupRanks[iGroupID][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), arrGroupDivisions[iGroupID][iDiv-1], arrGroupData[iGroupID][g_szGroupName], iGroupID + 1);
						GroupLog(iGroupID, szMessage);
					}
					PlayerInfo[iTargetID][pDivision] = iDiv-1;
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen doi Division nhu vay.");
			}
			else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong thuoc to chuc cua ban.");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	    return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:setbadge(playerid, params[])
{
	if(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS && arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] != GROUP_TYPE_CRIMINAL)
	{
		new
			iTargetID,
			iBadge[9],
			iGroupID = PlayerInfo[playerid][pLeader],
			szMessage[128],
			tmp[9];

		if(sscanf(params, "us[8]", iTargetID, iBadge)) SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setbadge [player] [number] -- Dung 'none' lam so de go phu hieu");
		else if(IsPlayerConnected(iTargetID))
		{
			if(iGroupID == PlayerInfo[iTargetID][pMember])
			{
				if(strcmp(iBadge, "none", true) == 0)
				{
					SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "Phu hieu cua ban da bi %s go.", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da go phu hieu cua %s.", GetPlayerNameEx(iTargetID));
					format(szMessage, sizeof(szMessage), "%s (%d) has removed %s's (%d) badge.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
					GroupLog(iGroupID, szMessage);
				}
				else
				{
					SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "Phu hieu la %s, do %s dat.", iBadge, GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da doi phu hieu %s thanh %s.", GetPlayerNameEx(iTargetID), iBadge);
					format(szMessage, sizeof(szMessage), "%s (%d) has set %s's (%d) badge to %s.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), iBadge);
					GroupLog(iGroupID, szMessage);
				}
				mysql_escape_string(iBadge, tmp);
				strcat((PlayerInfo[iTargetID][pBadge][0] = 0, PlayerInfo[iTargetID][pBadge]), tmp, 9);
			}
			else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong thuoc to chuc cua ban.");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:invite(playerid, params[]) {
	if(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS) {

		new
			iTargetID;

		if(sscanf(params, "u", iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /invite [player]");
		}
		else if(IsPlayerConnected(iTargetID)) {
		    if (iTargetID != playerid) {
				if(!(0 <= PlayerInfo[iTargetID][pLeader] < MAX_GROUPS) && !(0 <= PlayerInfo[iTargetID][pMember] < MAX_GROUPS)) {

					new
						szQuery[128],
						iGroupID = PlayerInfo[playerid][pLeader];

					mysql_format(MainPipeline, szQuery, sizeof szQuery, "SELECT `TypeBan` FROM `groupbans` WHERE `PlayerID` = %i AND (`TypeBan` = %i OR `GroupBan` = %i)", GetPlayerSQLId(iTargetID), arrGroupData[iGroupID][g_iGroupType], iGroupID);
					mysql_tquery(MainPipeline, szQuery, "OnGroupInviteChecked", "iiiii", playerid, g_arrQueryHandle[playerid], iTargetID, g_arrQueryHandle[iTargetID], iGroupID);

					SendClientMessage(playerid, COLOR_WHITE, "Dang kiem tra danh sach cam to chuc, vui long cho...");
					SetPVarInt(playerid, "Group_Invited", iTargetID);
					SetPVarInt(playerid, "GroupTargetSession", g_arrQueryHandle[iTargetID]);
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi ban moi da thuoc to chuc khac.");
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh nay voi chinh minh.");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Chi lanh dao to chuc duoc dung lenh nay.");
	return 1;
}


CMD:lastdriver(playerid, params[])
{
	new vehid, string[128];
	if(sscanf(params, "d", vehid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "CACH DUNG: /lastdriver [vehicle id]");
	if(isnull(VehInfo[vehid][vLastDriver])) format(VehInfo[vehid][vLastDriver], MAX_PLAYER_NAME, "nobody");
	if(GetVehicleModel(vehid) != 0)
	{
		if(PlayerInfo[playerid][pAdmin] > 1)
		{
			format(string, sizeof(string), "Nguoi lai xe %d lan cuoi: {AA3333}%s", vehid, VehInfo[vehid][vLastDriver]);
			SendClientMessage(playerid, COLOR_YELLOW, string);
		}
		else if(PlayerInfo[playerid][pLeader] != INVALID_GROUP_ID)
		{
			if(DynVeh[vehid] != -1)
			{
				if(DynVehicleInfo[DynVeh[vehid]][gv_igID] == PlayerInfo[playerid][pLeader])
				{
					format(string, sizeof(string), "Nguoi lai xe %d lan cuoi: {AA3333}%s", vehid, VehInfo[vehid][vLastDriver]);
					SendClientMessage(playerid, COLOR_YELLOW, string);
				}
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe khong thuoc to chuc cua ban");

		}
		else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay!");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "ID xe khong hop le");
	return 1;
}


CMD:togbr(playerid, params[])
{
	return ToggleAccountSetting(playerid, CHAT_BUG);
}


CMD:sanrank(playerid, params[])
{

	new
		iGroupID = PlayerInfo[playerid][pMember];

	szMiscArray[0] = 0;

	/*
		Camera (1)
		Show Host (2)
		Broadcast Editor/Director(2)
		Executive Commands
	*/

	if(arrGroupData[iGroupID][g_iGroupType] != GROUP_TYPE_NEWS) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	if(PlayerInfo[playerid][pLeader] == iGroupID)
	{
		new iRank,
			iChoice;
		if(sscanf(params, "dd", iChoice, iRank)) {

			SendClientMessageEx(playerid, COLOR_GREY, "HIEN TAI: Cameraman (Rank: %d) | Show Host (Rank: %d) | Broadcast Editor/Director (Rank: %d) | Moi quyen (Rank: %d)",
				arrGroupData[iGroupID][g_iWithdrawRank][0], arrGroupData[iGroupID][g_iWithdrawRank][1], arrGroupData[iGroupID][g_iWithdrawRank][2],
				arrGroupData[iGroupID][g_iWithdrawRank][3]);
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sanrank [choice] [rank]");
			return SendClientMessageEx(playerid, COLOR_GREY, "LUA CHON: Cameraman(0) Show Host(1) Broadcast Editor/Director(2) All(3)");
		}
		if(!(0 <= iChoice <= 3)) {
			return SendClientMessageEx(playerid, COLOR_GREY, "Hay chon gia tri hop le!");
		}
		else
		{
			if(0 <= iRank <= MAX_GROUP_RANKS-1 || iRank == INVALID_RANK)
			{
				arrGroupData[iGroupID][g_iWithdrawRank][iChoice] = iRank;
				SendClientMessageEx(playerid, COLOR_GREY, "Da doi rank duoc phep thanh %i.", iRank);
				format(szMiscArray, sizeof(szMiscArray), "%s has adjusted the rank permission for choice %d to %i.", GetPlayerNameEx(playerid), iChoice, iRank);
				GroupLog(iGroupID, szMiscArray);
				SaveGroup(iGroupID);
			}
			else SendClientMessage(playerid, COLOR_GREY, "Hay nhap rank hop le");
		}
	}
	else SendClientMessage(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:adjustwithdrawrank(playerid, params[])
{
	new
		iGroupID = PlayerInfo[playerid][pMember];

	szMiscArray[0] = 0;
	/*
		Money(1)
		Materials(2)
		Drugs(3)
		Weapons(4)
		Ammo(5)
	*/
	if(arrGroupData[iGroupID][g_iGroupType] != GROUP_TYPE_CRIMINAL && arrGroupData[iGroupID][g_iCrimeType] != GROUP_CRIMINAL_TYPE_RACE) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	if(PlayerInfo[playerid][pLeader] == iGroupID)
	{
		new iRank,
			iChoice;
		if(sscanf(params, "dd", iChoice, iRank)) {
			SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /adjustwithdrawrank [choice] [rank]");
			SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: Money - 0 | Materials - 1 | Drugs - 2");
			return SendClientMessageEx(playerid, COLOR_GREY, "HIEN TAI: Tien (Rank: %d) | Vat lieu (Rank: %d) | Ma tuy (Rank: %d)",
				arrGroupData[iGroupID][g_iWithdrawRank][0], arrGroupData[iGroupID][g_iWithdrawRank][1], arrGroupData[iGroupID][g_iWithdrawRank][2]);
		}
		if(!(0 <= iChoice <= 2)) {
			return SendClientMessageEx(playerid, COLOR_GREY, "Hay chon gia tri hop le!");
		}
		else
		{
			if(0 <= iRank <= MAX_GROUP_RANKS-1 || iRank == INVALID_RANK)
			{
				arrGroupData[iGroupID][g_iWithdrawRank][iChoice] = iRank;
				SendClientMessageEx(playerid, COLOR_GREY, "Da doi rank duoc rut thanh %i.", iRank);
				format(szMiscArray, sizeof(szMiscArray), "%s has adjusted the withdraw rank for item %d to %i.", GetPlayerNameEx(playerid), iChoice, iRank);
				GroupLog(iGroupID, szMiscArray);
			}
			else SendClientMessage(playerid, COLOR_GREY, "Hay nhap rank hop le");
		}
	}
	else SendClientMessage(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:families(playerid, params[])
{
	if(!IsACriminal(playerid) && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_GRAD2, "Ban phai thuoc family / gang de dung lenh nay.");

	if(isnull(params))
	{
		szMiscArray[0] = 0;
		SendClientMessage(playerid, COLOR_GRAD2, "CACH DUNG: /families [id]");
		for(new i = 0; i < MAX_GROUPS; i++)
		{
			if(arrGroupData[i][g_iGroupType] == GROUP_TYPE_CRIMINAL && strlen(arrGroupData[i][g_szGroupName]) > 0)
			{
				new iMemberCount = 0;
				foreach(new x: Player)
				{
					if(PlayerInfo[x][pMember] == i) iMemberCount++;
				}

				format(szMiscArray, sizeof szMiscArray, "** %s (%d) | Tong thanh vien: %d | Dang online: %d", arrGroupData[i][g_szGroupName], i, arrGroupData[i][g_iMemberCount], iMemberCount);
				SendClientMessage(playerid, COLOR_GRAD1, szMiscArray);
			}
		}
	}
	else
	{
		new grp = strval(params);
		if(grp < 0 || grp > MAX_GROUPS || strlen(arrGroupData[grp][g_szGroupName]) == 0) return SendClientMessage(playerid, COLOR_GRAD2, "ID to chuc da chon khong hop le.");

		if(arrGroupData[grp][g_iGroupType] != GROUP_TYPE_CRIMINAL) return SendClientMessage(playerid, COLOR_GRAD2, "To chuc khong phai family / gang.");

		new iCount = 0;

		foreach(new i: Player)
		{
			if(PlayerInfo[i][pMember] == grp)
			{
				format(szMiscArray, sizeof szMiscArray, "** %s (ID: %d) - %s (%d)", GetPlayerNameEx(i), i, arrGroupRanks[grp][PlayerInfo[i][pRank]], PlayerInfo[i][pRank]);
				SendClientMessage(playerid, COLOR_GRAD1, szMiscArray);
				iCount++;
			}
		}

		if(iCount == 0) SendClientMessage(playerid, COLOR_GRAD3, "Chua co nguoi online trong bang nhom nay.");
	}
	return 1;
}

//CMD:families(playerid, params[]) return pc_cmd_orgs(playerid, params);
CMD:orgs(playerid, params[])
{
	szMiscArray[0] = 0;
	for(new i = 0; i < MAX_GROUPS; i++)
	{
		if(arrGroupData[i][g_iGroupType] == GROUP_TYPE_CRIMINAL && strlen(arrGroupData[i][g_szGroupName]) > 0)
		{
			new iMemberCount = 0;
			foreach(new x: Player)
			{
				if(PlayerInfo[x][pMember] == i) iMemberCount++;
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "** %s | Tong thanh vien: %d | Dang online: %i", arrGroupData[i][g_szGroupName], arrGroupData[i][g_iMemberCount], iMemberCount);
		}
	}
	return 1;
}

CMD:clothes(playerid, params[])
{
	new biz = InBusiness(playerid);
	if(!IsACriminal(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Family/Gang!");
	if (biz != INVALID_BUSINESS_ID && Businesses[biz][bType] == BUSINESS_TYPE_CLOTHING)
	{
		new fSkin[MAX_GROUP_RANKS];
		for(new i = 0; i < MAX_GROUP_RANKS; i++)
		{
			fSkin[i] = arrGroupData[PlayerInfo[playerid][pMember]][g_iClothes][i];
		}
		ShowModelSelectionMenuEx(playerid, fSkin, MAX_GROUP_RANKS, "Doi quan ao.", DYNAMIC_FAMILY_CLOTHES, 0.0, 0.0, -55.0);
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o trong cua hang quan ao.");
	return true;
}

stock ShowPlayerCrimeDialog(playerid)
{
	new crimeName[41];
	new szCrime[1200];
	format(szCrime, sizeof(szCrime), "----Khinh toi----\n");
	for(new i = 0; i < sizeof(SuspectCrimes); i++)
	{
		if(SuspectCrimeInfo[i][0] == 0)
		{
		    strcat(szCrime, "{FFFF00}");
		    strunpack(crimeName, SuspectCrimes[i], sizeof(crimeName));
		    strcat(szCrime, crimeName);
		    strcat(szCrime, "\n");
		}
	}
	strcat(szCrime, "----Trong toi----\n");
	for(new i = 0; i < sizeof(SuspectCrimes); i++)
	{
		if(SuspectCrimeInfo[i][0] == 1)
		{
		    strcat(szCrime, "{AA3333}");
		    strunpack(crimeName, SuspectCrimes[i], sizeof(crimeName));
		    strcat(szCrime, crimeName);
			strcat(szCrime, "\n");
		}
	}
	//strcat(szCrime, "Other (Not Listed)");
	return ShowPlayerDialogEx(playerid, DIALOG_SUSPECTMENU, DIALOG_STYLE_LIST, "Chon toi da pham", szCrime, "Chon", "Thoat");
}

CMD:lockerbalance(playerid, params[])
{
	if(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == GROUP_TYPE_CRIMINAL || arrGroupData[PlayerInfo[playerid][pMember]][g_iCrimeType] == GROUP_CRIMINAL_TYPE_RACE))
	{
		new weps, GroupID = PlayerInfo[playerid][pMember];
		for(new s = 0; s != 50; s++)
		{
			if(arrGroupData[GroupID][g_iWeapons][s] != 0) weps++;
		}
		szMiscArray[0] = 0;
		SendClientMessageEx(playerid, COLOR_WHITE, "Tu: Vu khi: %d/50 | Tien: $%s | Pot: %d | Crack: %d | Meth: %d | Ecstasy: %d | Heroin: %d | Syringes: %d | Vat lieu: %d ", weps, number_format(arrGroupData[GroupID][g_iBudget]), arrGroupData[GroupID][g_iPot], arrGroupData[GroupID][g_iCrack],
			arrGroupData[GroupID][g_iMeth], arrGroupData[GroupID][g_iEcstasy], arrGroupData[GroupID][g_iHeroin], arrGroupData[GroupID][g_iSyringes], arrGroupData[GroupID][g_iMaterials]);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc to chuc toi pham.");
	return 1;
}

CMD:turnout(playerid, params[])
{
	if(!IsACop(playerid) && !IsAMedic(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai Law Enforcement Officer/Medic.");
	new closestCar = GetClosestCar(playerid, .fRange = 8.0);
	if(closestCar == INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe nao!");
	if(!IsACopCar(closestCar) && !IsAnAmbulance(closestCar)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe to chuc!");
    return ShowPlayerDialogEx(playerid, DIALOG_GROUP_TURNOUT, DIALOG_STYLE_LIST, "Turnout", IsFirstAid(playerid) ? ("SWAT\nLS Fire\nSF Fire\nLV Fire\nQuan ao cu"):("SWAT\nQuan ao cu"), "Chon", "Huy");
}

MemberCount(groupID)
{
	szMiscArray[0] = 0;
	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT NULL FROM `accounts` WHERE `Member` = %d", groupID);
	mysql_tquery(MainPipeline, szMiscArray, "OnMemberCount", "i", groupID);
}

forward OnMemberCount(groupID);
public OnMemberCount(groupID)
{
	new rows;
	cache_get_row_count(rows);
	arrGroupData[groupID][g_iMemberCount] = rows;
}

/*
ShowGroupWeapons(playerid, iGroupID) {

	format(szMiscArray, sizeof(szMiscArray), "SELECT * FROM `gWeaponsNew` WHERE `Group_ID` = '%d'", iGroupID+1);
	mysql_tquery(MainPipeline, szMiscArray, true, "OnShowGroupWeapons", "ii", playerid, iGroupID+1);
	return 1;
}*/

forward OnShowGroupWeapons(playerid, iGroupID);
public OnShowGroupWeapons(playerid, iGroupID) {

	szMiscArray[0] = 0;

	new
		tempWep[3],
		iCount;

	for(new i = 1; i <= 18; i++) {
		valstr(tempWep, i);
		cache_get_value_name_int(0, tempWep, iCount);
		format(szMiscArray, sizeof(szMiscArray), "%s\n[%d]%s (%d)", szMiscArray, i, Weapon_ReturnName(i), iCount);
	}

	for(new i = 22; i <= 46; i++) {
		valstr(tempWep, i);
		cache_get_value_name_int(0, tempWep, iCount);
		format(szMiscArray, sizeof(szMiscArray), "%s\n[%d]%s (%d)",szMiscArray, i, Weapon_ReturnName(i), iCount);
	}

	strcat(szMiscArray, "\nGui vu khi");
	ShowPlayerDialogEx(playerid, DIALOG_GROUP_WEAPONSAFE, DIALOG_STYLE_LIST, "Ket vu khi bang nhom", szMiscArray, "Chon", "Huy");

	return 1;
}

stock WithdrawGroupSafeWeapon(playerid, iGroupID, iWeaponID, iAmount = 1) {

	szMiscArray[0] = 0;

	if(PlayerInfo[playerid][pRank] < arrGroupData[iGroupID][g_iWithdrawRank][3] && playerid != INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co quyen rut vu khi tu tu!");

	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `gWeaponsNew` SET `%d` = `%d` - %d WHERE `id` = '%d'", iWeaponID, iWeaponID, iAmount, iGroupID+1);

	//format(szMiscArray, sizeof(szMiscArray), "DELETE FROM `gWeapons` WHERE `Group_ID` = '%d' AND `Weapon_ID` = '%d' LIMIT 1", iGroupID, iWeaponID);
	mysql_tquery(MainPipeline, szMiscArray, "OnWithdrawGroupWeapons", "iiii", playerid, iGroupID+1, iWeaponID, iAmount);
	return 1;
}

forward OnWithdrawGroupWeapons(playerid, iGroupID, iWeaponID, iAmount);
public OnWithdrawGroupWeapons(playerid, iGroupID, iWeaponID, iAmount) {

	szMiscArray[0]  = 0;

	if(playerid != INVALID_PLAYER_ID) {
		GivePlayerValidWeapon(playerid, iWeaponID);

		format(szMiscArray, sizeof(szMiscArray), "%s has withdrawn a %s from the locker.", GetPlayerNameEx(playerid), Weapon_ReturnName(iWeaponID));
		GroupLog(iGroupID-1, szMiscArray);
		if(iWeaponID != 22 && iWeaponID != 19){
			format(szMiscArray, sizeof(szMiscArray), "Ban da rut %s tu tu do.", Weapon_ReturnName(iWeaponID));
		}
		else {
			format(szMiscArray, sizeof(szMiscArray), "Ban da rut Colt tu tu do.");
		}
		SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
	}
	else {
		format(szMiscArray, sizeof(szMiscArray), "A %s has been transfered from the locker (x%d).", Weapon_ReturnName(iWeaponID), iAmount);
		GroupLog(iGroupID-1, szMiscArray);
	}

	return 1;
}

stock AddGroupSafeWeapon(playerid, iGroupID, iWeaponID, iAmount = 1) {

	szMiscArray[0] = 0;

	if(playerid != INVALID_PLAYER_ID && PlayerInfo[playerid][pGuns][GetLoadoutWeaponSlot(iWeaponID)] == 0) return 1;

	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `gWeaponsNew` SET `%d` = `%d` + %d WHERE `id` = '%d'", iWeaponID, iWeaponID, iAmount, iGroupID+1);
	//mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "INSERT INTO `gWeapons` (`Group_ID`, `Weapon_ID`) VALUES ('%d', '%d') ", iGroupID, iWeaponID);
	mysql_tquery(MainPipeline, szMiscArray, "OnAddGroupSafeWeapon", "iiii", playerid, iGroupID+1, iWeaponID, iAmount);
	return 1;
}

forward OnAddGroupSafeWeapon(playerid, iGroupID, iWeaponID, iAmount);
public OnAddGroupSafeWeapon(playerid, iGroupID, iWeaponID, iAmount) {

	szMiscArray[0] = 0;

	if(playerid != INVALID_PLAYER_ID) {
		PlayerInfo[playerid][pGuns][GetLoadoutWeaponSlot(iWeaponID)] = 0;
		SetPlayerWeaponsEx(playerid);

		format(szMiscArray, sizeof(szMiscArray), "%s has deposited a %s into the locker.", GetPlayerNameEx(playerid), Weapon_ReturnName(iWeaponID));
		GroupLog(iGroupID-1, szMiscArray);

		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat %s vao tu do.", Weapon_ReturnName(iWeaponID));
	}
	else {
		format(szMiscArray, sizeof(szMiscArray), "A %s has been deposited into the locker (x%d).", Weapon_ReturnName(iWeaponID), iAmount);
		GroupLog(iGroupID-1, szMiscArray);
	}

	return 1;
}


GetSafeTakePerm(iOpt) {
	new iSlot;
	switch(iOpt) {
		case 0: iSlot = 0;
		case 1: iSlot = 1;
		case 2 .. 3: iSlot = 2;
		case 4: iSlot = 3;
		case 5: iSlot = 4;
	}
	return iSlot;
}
/*
Money(1)
Materials(2)
Drugs(3)
Weapons(4)
Ammo(5)
*/

forward ValidGroup(groupid);
public ValidGroup(groupid) {
	if((0 <= groupid < MAX_GROUPS)) return 1;
	else return 0;
}

forward IsGroupLeader(playerid);
public IsGroupLeader(playerid) {
	if(ValidGroup(PlayerInfo[playerid][pMember]) && PlayerInfo[playerid][pMember] == PlayerInfo[playerid][pLeader]) return 1;
	else return 0;
}

// Remove Money: SetGroupBudget(groupid, -amount).
forward SetGroupBudget(groupid, amount);
public SetGroupBudget(groupid, amount) {
	if(ValidGroup(groupid)) {
		arrGroupData[groupid][g_iBudget] += amount;
	}
	return 1;
}

forward GetGroupBudget(groupid);
public GetGroupBudget(groupid) {
	if(ValidGroup(groupid)) {
		return arrGroupData[groupid][g_iBudget];
	}
	return 0;
}

stock DeleteSpikeStrip(groupid, spikeid)
{
	if(!ValidGroup(groupid) || !(0 <= spikeid < MAX_SPIKES)) return 0;
	if(IsValidDynamicObject(SpikeStrips[groupid][spikeid][sObjectID]))
		DestroyDynamicObject(SpikeStrips[groupid][spikeid][sObjectID]);

	Iter_Remove(DeployedSpikes, groupid * MAX_SPIKES + spikeid);

	new empty[Spikes];
	SpikeStrips[groupid][spikeid] = empty;
	return 1;
}

stock SpikeStripIntersectsWheel(groupid, slot, const Float:from[3], const Float:to[3])
{
	new 
		Float:c = SpikeStrips[groupid][slot][sCosAngle], 
		Float:s = SpikeStrips[groupid][slot][sSinAngle];

	new 
		Float:dx = from[0] - SpikeStrips[groupid][slot][sX], 
		Float:dy = from[1] - SpikeStrips[groupid][slot][sY];
	
	new Float:start[3], Float:delta[3];
	
	start[0] = dx * c + dy * s;
	start[1] = -dx * s + dy * c;
	start[2] = from[2] - (SpikeStrips[groupid][slot][sZ] - 0.8);
	dx = to[0] - from[0];
	dy = to[1] - from[1];
	delta[0] = dx * c + dy * s;
	delta[1] = -dx * s + dy * c;
	delta[2] = to[2] - from[2];

	// Model 2899 footprint, wheel-center height includes tire/suspension clearance.
	new const Float:lower[3] = {-0.575711, -2.49439, -0.2}, Float:upper[3] = {0.575711, 2.49439, 0.8};
	new Float:enter = 0.0, Float:leave = 1.0;
	for(new axis; axis < 3; axis++)
	{
		if(floatabs(delta[axis]) < 0.00001)
		{
			if(start[axis] < lower[axis] || start[axis] > upper[axis]) return 0;
			continue;
		}
		new Float:a = (lower[axis] - start[axis]) / delta[axis], Float:b = (upper[axis] - start[axis]) / delta[axis];
		if(a > b)
		{
			new Float:swap = a;
			a = b;
			b = swap;
		}
		if(a > enter) enter = a;
		if(b < leave) leave = b;
		if(enter > leave) return 0;
	}
	return 1;
}