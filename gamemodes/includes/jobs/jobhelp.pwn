#include <YSI_Coding\y_hooks>

static const JobSkillMenu[] =
{
	JOB_SKILL_DETECTIVE, 
	JOB_SKILL_LAWYER, 
	JOB_SKILL_SEX, 
	JOB_SKILL_SMUGGLING,
	JOB_SKILL_ARMS, 
	JOB_SKILL_MECHANIC, 
	JOB_SKILL_BOXING, 
	JOB_SKILL_FISHING,
	JOB_SKILL_SHIPMENT, 
	JOB_SKILL_TREASURE, 
	JOB_SKILL_LOCKPICK, 
	JOB_SKILL_DRUGS, 
	JOB_SKILL_GARBAGE
};

CMD:jobhelp(playerid, const params[])
{
	Job_BuildMenu(szMiscArray, sizeof(szMiscArray));
	strcat(szMiscArray, "\nFishing (no job slot required)", sizeof(szMiscArray));
	return Dialog_Show(playerid, job_help, DIALOG_STYLE_LIST, "Job Information", szMiscArray, "Select", "Close");
}

Dialog:job_help(playerid, response, listitem, inputtext[])
{
	if(!response || listitem < 0) return 1;
	new job = Job_GetMenuType(listitem);
	if(job == JOB_NONE)
	{
		new count;
		for(new type = 1; type < MAX_JOBTYPES; ++type) if(Job_IsAvailable(type)) ++count;
		if(listitem != count) return 1;
		return Dialog_Show(playerid, job_information, DIALOG_STYLE_MSGBOX, "Fishing", "Fishing is available without taking a job slot.\nCommands: /fish, /myfish, /sellfish, /fishhelp.\nUse /skill 8 to view your Fishing progress.", "Back", "Close");
	}
	szMiscArray[0] = EOS;
	switch(job)
	{
		case JOB_DETECTIVE: strcat(szMiscArray, "Trace active phones using /trace [phone number].\nYour skill controls the tracking duration and cooldown.", sizeof(szMiscArray));
		case JOB_LAWYER: strcat(szMiscArray, "Provide legal services and appeals.\nCommands: /lawyerduty, /defend, /defendtime, /free, /offerappeal, /finishappeal.\nQualified Judicial members can also practice law.", sizeof(szMiscArray));
		case JOB_PROSTITUTE: strcat(szMiscArray, "Offer services while sharing a vehicle with a customer.\nCommand: /sex [player] [price].\nPrices range from $1 to $10,000.", sizeof(szMiscArray));
		case JOB_MECHANIC: strcat(szMiscArray, "Repair and service vehicles.\nCommands: /mechduty, /fix, /repair, /refill, /nos, /hyd.\nSome repairs are also available to mechanics working at a Mechanic business.", sizeof(szMiscArray));
		case JOB_BODYGUARD: strcat(szMiscArray, "Offer protective vests and frisk players.\nCommands: /guard [player] [price], /frisk [player].\nPolice retain their own frisk permissions.", sizeof(szMiscArray));
		case JOB_ARMS_DEALER: strcat(szMiscArray, "Craft weapons using materials.\nUse /sellgun to view unlocked recipes and material costs.\nCommand: /sellgun [player] [weapon].", sizeof(szMiscArray));
		case JOB_BOXER: strcat(szMiscArray, "Arrange boxing matches at a gym.\nCommands: /fight, /train, /boxstats.\nThe five skill levels control fight health. Boxing titles are separate ranks.", sizeof(szMiscArray));
		case JOB_DRUG_SMUGGLER: strcat(szMiscArray, "Collect drug packages at configured points.\nCommands: /getdrugs, /buypot, /buyopium.\nUse /skill 4 to view your Drug Smuggling progress.", sizeof(szMiscArray));
		case JOB_STREET_SWEEPER: strcat(szMiscArray, "Clean sprayed gang tags around the city.\nCommands: /cleantag, /gangtaghelp.\nCleaning factions retain their own permissions.", sizeof(szMiscArray));
		case JOB_TAXI: strcat(szMiscArray, "Transport passengers in taxis and buses.\nUse /fare [price] to start or end duty.\nTaxi faction members and licensed drivers retain their own access.", sizeof(szMiscArray));
		case JOB_CRAFTSMAN: strcat(szMiscArray, "Craft useful equipment from materials.\nUse /craft to view recipes.\nPlayers can use purchased equipment without becoming a Craftsman.", sizeof(szMiscArray));
		case JOB_BARTENDER: strcat(szMiscArray, "Offer drinks while working at a bar.\nCommand: /selldrink [player].", sizeof(szMiscArray));
		case JOB_SHIPMENT: strcat(szMiscArray, "Transport cargo and business supplies.\nCommands: /loadshipment, /checkcargo, /hijackcargo.\nUse /cancel shipment to abandon a delivery.", sizeof(szMiscArray));
		case JOB_PIZZA: strcat(szMiscArray, "Collect and deliver pizzas using a Pizzaboy.\nCommand: /getpizza.\nWear the Pizza Stack uniform and deliver before the pizza gets cold.", sizeof(szMiscArray));
		case JOB_TREASURE: strcat(szMiscArray, "Search beaches using a charged metal detector from a Craftsman.\nCommands: /search, /selltreasure.\nUse /skill 10 to view your progress.", sizeof(szMiscArray));
		case JOB_GARBAGE: strcat(szMiscArray, "Drive a garbage truck through five collection stops, then return to the depot.\nCommands: /garbagerun, /cancel garbage.", sizeof(szMiscArray));
	}
	strcat(szMiscArray, "\n\nApply at a configured job point using Y or /join. Use /quitjob [slot] to leave a job.", sizeof(szMiscArray));
	return Dialog_Show(playerid, job_information, DIALOG_STYLE_MSGBOX, GetJobName(job), szMiscArray, "Back", "Close");
}

Dialog:job_information(playerid, response, listitem, inputtext[])
{
	if(response) return pc_cmd_jobhelp(playerid, "");
	return 1;
}

CMD:skill(playerid, params[])
{
	if(isnull(params))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /skill [number]");
		for(new item; item < sizeof(JobSkillMenu); ++item) {
			SendClientMessageEx(playerid, COLOR_GREY, "%d. %s", item + 1, JobSkills[JobSkillMenu[item]][jobSkillName]);
		}
		return 1;
	}

	new item;
	if(sscanf(params, "d", item) || !(1 <= item <= sizeof(JobSkillMenu)))
		return SendClientMessageEx(playerid, COLOR_GREY, "Invalid skill number. Use /skill to view the list.");
	
	new 
		skill = JobSkillMenu[item - 1], 
		points = PlayerInfo[playerid][JobSkills[skill][jobSkillField]], 
		level = Job_SkillLevel(skill, points);
	
	SendClientMessageEx(playerid, COLOR_YELLOW, "%s skill level: %d. Skill points: %d.", JobSkills[skill][jobSkillName], level, points);
	if(1 <= level < 5) 
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "You need %d more skill points to reach level %d.", JobSkills[skill][jobSkillThreshold][level - 1] - points, level + 1);
	}
	return 1;
}
