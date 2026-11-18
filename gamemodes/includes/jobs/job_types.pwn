/*

	The Job System has been rewritten to simplify the management of job constants, 
	job skills, and other related components.

	All functionalities have been consolidated into a unified workflow, with improved 
	code organization and cleanup.

	Author: Le Tuan Kiet (aujiz11)

*/

enum
{
	JOB_NONE = 0,
	JOB_DETECTIVE,
	JOB_LAWYER,
	JOB_PROSTITUTE,
	JOB_DRUG_DEALER,
	JOB_PIMP,
	JOB_MECHANIC,
	JOB_BODYGUARD,
	JOB_ARMS_DEALER,
	JOB_MEDIC,
	JOB_BOXER,
	JOB_DRUG_SMUGGLER,
	JOB_STREET_SWEEPER,
	JOB_ICE_CREAM,
	JOB_TAXI,
	JOB_CRAFTSMAN,
	JOB_BARTENDER,
	JOB_SHIPMENT,
	JOB_PIZZA,
	JOB_TREASURE,
	JOB_PILOT,
	JOB_LEGACY_TRASHMAN,
	JOB_GARBAGE,
	JOB_PLUMBER,
	JOB_TYPE_COUNT
};

enum
{
	JOB_STATUS_NONE,
	JOB_STATUS_ACTIVE,
	JOB_STATUS_LEGACY
};

enum
{
	JOB_SKILL_NONE = -1,
	JOB_SKILL_DETECTIVE,
	JOB_SKILL_LAWYER,
	JOB_SKILL_SEX,
	JOB_SKILL_MECHANIC,
	JOB_SKILL_ARMS,
	JOB_SKILL_BOXING,
	JOB_SKILL_SMUGGLING,
	JOB_SKILL_SHIPMENT,
	JOB_SKILL_TREASURE,
	JOB_SKILL_GARBAGE,
	JOB_SKILL_FISHING,
	JOB_SKILL_LOCKPICK
};

enum eJobDefinition
{
	jobDefaultName[MAX_JOBNAME_LEN],
	jobStatus,
	jobSkill,
	bool:jobBoostable
}

new const JobDefinitions[MAX_JOBTYPES][eJobDefinition] =
{
	{"None", 				JOB_STATUS_NONE, 	JOB_SKILL_NONE, false},
	{"Detective", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_DETECTIVE, true},
	{"Lawyer",	 			JOB_STATUS_ACTIVE, 	JOB_SKILL_LAWYER, true},
	{"Prostitute", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_SEX, true},
	{"Drug Dealer", 		JOB_STATUS_LEGACY, 	JOB_SKILL_NONE, false},
	{"Pimp", 				JOB_STATUS_LEGACY, 	JOB_SKILL_NONE, false},
	{"Mechanic", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_MECHANIC, true},
	{"Bodyguard", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_NONE, false},
	{"Arms Dealer", 		JOB_STATUS_ACTIVE, 	JOB_SKILL_ARMS, true},
	{"Medic", 				JOB_STATUS_LEGACY, 	JOB_SKILL_NONE, false},
	{"Boxer", 				JOB_STATUS_ACTIVE, 	JOB_SKILL_BOXING, true},
	{"Drug Smuggler", 		JOB_STATUS_ACTIVE, 	JOB_SKILL_SMUGGLING, false},
	{"Street Sweeper", 		JOB_STATUS_ACTIVE, 	JOB_SKILL_NONE, false},
	{"Ice Cream Man", 		JOB_STATUS_LEGACY, 	JOB_SKILL_NONE, false},
	{"Taxi Driver", 		JOB_STATUS_ACTIVE, 	JOB_SKILL_NONE, false},
	{"Craftsman", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_NONE, false},
	{"Bartender", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_NONE, false},
	{"Shipment Contractor", JOB_STATUS_ACTIVE, 	JOB_SKILL_SHIPMENT, true},
	{"Pizza Boy", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_NONE, false},
	{"Treasure Hunter", 	JOB_STATUS_ACTIVE, 	JOB_SKILL_TREASURE, false},
	{"Pilot", 				JOB_STATUS_LEGACY, 	JOB_SKILL_NONE, false},
	{"Legacy Trashman", 	JOB_STATUS_LEGACY, 	JOB_SKILL_NONE, false},
	{"Garbageman", 			JOB_STATUS_ACTIVE, 	JOB_SKILL_GARBAGE, false},
	{"Plumber", 			JOB_STATUS_LEGACY, 	JOB_SKILL_NONE, false}
};

enum eJobSkillDefinition
{
	jobSkillName[32],
	pInfo:jobSkillField,
	jobSkillThreshold[4]
}

new const JobSkills[][eJobSkillDefinition] =
{
	{"Detective",	 			pDetSkill, 			{50, 100, 200, 400}},
	{"Lawyer", 					pLawSkill, 			{50, 100, 200, 400}},
	{"Prostitute", 				pSexSkill, 			{50, 100, 200, 400}},
	{"Mechanic", 				pMechSkill, 		{50, 100, 200, 400}},
	{"Arms Dealer", 			pArmsSkill, 		{50, 200, 700, 1200}},
	{"Boxing", 					pBoxSkill, 			{50, 100, 200, 400}},
	{"Drug Smuggling", 			pDrugSmuggler, 		{50, 100, 200, 400}},
	{"Shipment Contractor", 	pTruckSkill, 		{50, 100, 200, 400}},
	{"Treasure Hunting", 		pTreasureSkill, 	{25, 150, 300, 600}},
	{"Garbage Collection", 		pGarbageSkill, 		{50, 100, 200, 400}},
	{"Fishing", 				pFishingSkill, 		{50, 100, 200, 400}},
	{"Lock Picking", 			pCarLockPickSkill, 	{50, 125, 225, 350}}
};

forward bool:Job_IsKnownType(job);
forward bool:Job_IsAvailable(job);
forward bool:Job_HasJob(playerid, job);
forward bool:Job_CanUseSlot(playerid, slot);
forward bool:Job_CanSetSlot(playerid, slot, job);
