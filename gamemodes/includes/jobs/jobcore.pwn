/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Job System Core

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

stock bool:Job_IsKnownType(job)
{
	return 0 < job < MAX_JOBTYPES;
}

stock bool:Job_IsAvailable(job)
{
	return 0 < job < MAX_JOBTYPES && JobDefinitions[job][jobStatus] == JOB_STATUS_ACTIVE;
}

stock bool:Job_HasJob(playerid, job)
{
	return 0 <= playerid < MAX_PLAYERS && job != JOB_NONE && (PlayerInfo[playerid][pJob] == job || PlayerInfo[playerid][pJob2] == job || PlayerInfo[playerid][pJob3] == job);
}

stock Job_GetSlot(playerid, slot)
{
	switch(slot)
	{
		case 1: return PlayerInfo[playerid][pJob];
		case 2: return PlayerInfo[playerid][pJob2];
		case 3: return PlayerInfo[playerid][pJob3];
	}
	return JOB_NONE;
}

stock bool:Job_CanUseSlot(playerid, slot)
{
	switch(slot)
	{
		case 1: {
			return true;
		}
		case 2: {
			return PlayerInfo[playerid][pDonateRank] > 0 || PlayerInfo[playerid][pFamed] > 0;
		}
		case 3: {
			return PlayerInfo[playerid][pDonateRank] >= 3 || PlayerInfo[playerid][pFamed] > 0;
		}
	}
	return false;
}

stock bool:Job_CanSetSlot(playerid, slot, job)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !(1 <= slot <= 3)) return false;
	if(job != JOB_NONE && (!Job_IsAvailable(job) || !Job_CanUseSlot(playerid, slot))) return false;
	
	for(new other = 1; job != JOB_NONE && other <= 3; ++other) {
		if(other != slot && Job_GetSlot(playerid, other) == job) {
			return false;
		}	
	}
	
	if(Job_GetSlot(playerid, slot) == JOB_TAXI && job != JOB_TAXI && TransportDuty[playerid] > 0
		&& GetPlayerCash(playerid) > cellmax - (TransportMoney[playerid] / 100 * 50)) return false;
	
	return true;
}

stock Job_ClearPointDelivery(playerid)
{
	new point = MatDeliver[playerid];
	if(!(0 <= point < MAX_POINTS)) return 1;
	if(DynPoints[point][poType] == 0)
	{
		if(Job_HasJob(playerid, JOB_ARMS_DEALER) || Job_HasJob(playerid, JOB_CRAFTSMAN)) return 1;
	}
	else if(Job_HasJob(playerid, JOB_DRUG_SMUGGLER) || IsACriminal(playerid)) return 1;
	new Float:x, Float:y, Float:z, Float:radius;
	if(GetPlayerCheckpoint(playerid, x, y, z, radius) && x == DynPoints[point][poPos2][0] && y == DynPoints[point][poPos2][1] && z == DynPoints[point][poPos2][2] && radius == 5.0)
	{
		DisablePlayerCheckpoint(playerid);
	}

	MatDeliver[playerid] = -1;
	MatsAmount[playerid] = 0;
	DeletePVar(playerid, "tpMatRunTimer");
	return 1;
}

stock Job_ClearActivity(playerid, job)
{
	switch(job)
	{
		case JOB_DETECTIVE:
		{
			DeletePVar(playerid, "TRC_STP");
			DeletePVar(playerid, "TRC_STR");
			if(Bit_State(arrPlayerBits[playerid], phone_bitTraceState))
			{
				GangZoneDestroy(GetPVarInt(playerid, "PTR_GZ"));
				DeletePVar(playerid, "PTR_GZ");
				Bit_Off(arrPlayerBits[playerid], phone_bitTraceState);
			}
			FindingPlayer[playerid] = INVALID_PLAYER_ID;
			FindTime[playerid] = 0;
		}
		case JOB_LAWYER:
		{
			if(IsALawyer(playerid)) return 1;
			Lawyer_StopDuty(playerid);
			ApprovedLawyer[playerid] = 0;
		}
		case JOB_MECHANIC:
		{
			if(GetPVarInt(playerid, "MechanicDuty") == 1 && Mechanics > 0) --Mechanics;
			DeletePVar(playerid, "MechanicDuty");
			if(!Mechanic_CanFix(playerid)) Mechanic_CancelFix(playerid);
		}
		case JOB_ARMS_DEALER, JOB_CRAFTSMAN, JOB_DRUG_SMUGGLER: Job_ClearPointDelivery(playerid);
		case JOB_STREET_SWEEPER:
		{
			if(gGangTagTimer[playerid] && !GetPVarType(playerid, PVAR_GANGTAGTEXT) && !IsAStreetSweeper(playerid)
				&& strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) == -1) GangTag_Cancel(playerid);
		}
		case JOB_TAXI:
		{
			if(!IsATaxiDriver(playerid)) Taxi_StopDuty(playerid);
		}
		case JOB_SHIPMENT: CancelTruckDelivery(playerid);
		case JOB_PIZZA: Pizza_StopDelivery(playerid);
		case JOB_GARBAGE: Garbage_CancelRun(playerid);
	}
	foreach(new target: Player)
	{
		switch(job)
		{
			case JOB_LAWYER:
			{
				if(DefendOffer[target] == playerid)
				{
					DefendOffer[target] = INVALID_PLAYER_ID;
					DefendPrice[target] = 0;
					DeletePVar(target, "DefendOfferSession");
				}
				if(AppealOffer[target] == playerid) Lawyer_ClearAppeal(target);
			}
			case JOB_MECHANIC:
			{
				if(RepairOffer[target] == playerid)
				{
					RepairOffer[target] = INVALID_PLAYER_ID;
					RepairPrice[target] = RepairCar[target] = 0;
					DeletePVar(target, "RepairOfferSession");
				}
				if(RefillOffer[target] == playerid)
				{
					RefillOffer[target] = INVALID_PLAYER_ID;
					RefillPrice[target] = 0;
					DeletePVar(target, "RefillVehicle");
					DeletePVar(target, "RefillOfferSession");
				}
			}
			case JOB_PROSTITUTE:
			{
				if(SexOffer[target] == playerid)
				{
					SexOffer[target] = INVALID_PLAYER_ID;
					SexPrice[target] = 0;
					DeletePVar(target, "SexOfferSession");
				}
			}
			case JOB_BARTENDER:
			{
				if(DrinkOffer[target] == playerid)
				{
					DrinkOffer[target] = INVALID_PLAYER_ID;
					DeletePVar(target, "DrinkOfferSession");
				}
			}
			case JOB_BODYGUARD: if(GuardOffer[target] == playerid) Bodyguard_ClearOffer(target);
			case JOB_ARMS_DEALER: if(GetPVarType(target, "pSellGunID") && GetPVarInt(target, "pSellGunID") == playerid) ArmsDealer_ClearOffer(target);
		}
	}
	return 1;
}

stock Job_SetPlayerSlot(playerid, slot, job)
{
	if(!Job_CanSetSlot(playerid, slot, job)) return 0;
	new oldjob = Job_GetSlot(playerid, slot);
	if(oldjob == job) return 1;
	switch(slot)
	{
		case 1: PlayerInfo[playerid][pJob] = job;
		case 2: PlayerInfo[playerid][pJob2] = job;
		case 3: PlayerInfo[playerid][pJob3] = job;
	}
	if(oldjob != JOB_NONE && !Job_HasJob(playerid, oldjob)) Job_ClearActivity(playerid, oldjob);
	return 1;
}

stock Job_GetMenuType(listitem, bool:boost = false)
{
	if(listitem < 0) return JOB_NONE;
	for(new job = 1; job < MAX_JOBTYPES; ++job)
	{
		if(!Job_IsAvailable(job) || (boost && !JobDefinitions[job][jobBoostable])) continue;
		if(listitem-- == 0) return job;
	}
	return JOB_NONE;
}

stock Job_BuildMenu(output[], size, bool:boost = false)
{
	output[0] = EOS;
	new count, line[MAX_JOBNAME_LEN + 12];
	for(new job = 1; job < MAX_JOBTYPES; ++job)
	{
		if(!Job_IsAvailable(job) || (boost && !JobDefinitions[job][jobBoostable])) continue;
		format(line, sizeof(line), "%s%d. %s", count ? "\n" : "", count + 1, GetJobName(job));
		strcat(output, line, size);
		++count;
	}
	return count;
}

stock Job_ShowMenu(playerid, bool:shop = false, bool:boost = false)
{
	DeletePVar(playerid, "jobSelection");
	DeletePVar(playerid, "m_Response");
	if(shop) SetPVarInt(playerid, "m_Item", boost ? 1 : 0);
	else DeletePVar(playerid, "m_Item");
	Job_BuildMenu(szMiscArray, sizeof(szMiscArray), boost);
	return ShowPlayerDialogEx(playerid, 7484, DIALOG_STYLE_LIST, boost ? "Micro Shop: Job Boost" : "Job Center", szMiscArray, "Proceed", "Cancel");
}

stock Job_GetSkill(job)
{
	return Job_IsKnownType(job) ? JobDefinitions[job][jobSkill] : JOB_SKILL_NONE;
}

stock Job_SkillLevel(skill, points)
{
	if(!(0 <= skill < sizeof(JobSkills)) || points < 0) return 0;
	for(new level; level < 4; ++level)
		if(points < JobSkills[skill][jobSkillThreshold][level]) return level + 1;
	return 5;
}

stock GetJobLevel(playerid, job)
{
	new skill = Job_GetSkill(job);
	if(skill == JOB_SKILL_NONE) return 0;
	return Job_SkillLevel(skill, PlayerInfo[playerid][JobSkills[skill][jobSkillField]]);
}

stock Job_IsOnDuty(playerid, job)
{
	switch(job)
	{
		case JOB_LAWYER: return IsALawyer(playerid) && GetPVarInt(playerid, "LawyerDuty") == 1;
		case JOB_MECHANIC: return Job_HasJob(playerid, job) && GetPVarInt(playerid, "MechanicDuty") == 1;
		case JOB_TAXI: return IsATaxiDriver(playerid) && TransportDuty[playerid] > 0;
	}
	return 0;
}

stock SendJobMessage(job, color, const string[])
{
	foreach(new i: Player) {
		if(Job_IsOnDuty(i, job)) {
			SendClientMessageEx(i, color, string);
		}
	}
}

CMD:join(playerid, params[])
{
	new point = Job_FindPoint(playerid);
	if(point == -1) {
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You must be near a job point. Press Y there or use /join to apply.");
	}
	return Job_GetJob(playerid, point);
}

CMD:quitjob(playerid, params[])
{
	new slot = 1;
	if(!isnull(params) || PlayerInfo[playerid][pDonateRank] > 0 || PlayerInfo[playerid][pFamed] > 0)
	{
		if(sscanf(params, "d", slot) || !(1 <= slot <= 3))
			return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /quitjob [slot 1, 2 or 3]");
	}
	
	new job = Job_GetSlot(playerid, slot);
	if(job == JOB_NONE) return SendClientMessageEx(playerid, COLOR_GREY, "You do not have a job in that slot.");
	if(!Job_SetPlayerSlot(playerid, slot, JOB_NONE)) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot leave this job until you can receive the outstanding fare payment.");
	return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have left %s in job slot %d.", GetJobName(job), slot);
}
