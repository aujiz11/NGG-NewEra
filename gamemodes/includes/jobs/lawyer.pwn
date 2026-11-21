/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Lawyer System

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

stock Lawyer_CanAct(playerid)
{
	return 0 <= playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && gPlayerLogged{playerid}
		&& !PlayerIsDead[playerid] && PlayerInfo[playerid][pJailTime] <= 0 && PlayerInfo[playerid][pBeingSentenced] <= 0
		&& !GetPVarInt(playerid, "Injured") && !GetPVarInt(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged");
}

stock Lawyer_IsNear(playerid, target)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !(0 <= target < MAX_PLAYERS) || !IsPlayerConnected(playerid) || !IsPlayerConnected(target)
		|| !gPlayerLogged{playerid} || !gPlayerLogged{target} || playerid == target) return 0;
	if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target) || GetPlayerInterior(playerid) != GetPlayerInterior(target)) return 0;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(target, x, y, z);
	return IsPlayerInRangeOfPoint(playerid, 8.0, x, y, z);
}

stock Lawyer_StopDuty(playerid)
{
	if(GetPVarInt(playerid, "LawyerDuty") == 1 && Lawyers > 0) --Lawyers;
	DeletePVar(playerid, "LawyerDuty");
	return 1;
}

stock Lawyer_ClearAppeal(playerid)
{
	AppealOffer[playerid] = INVALID_PLAYER_ID;
	AppealOfferAccepted[playerid] = 0;
	DeletePVar(playerid, "AppealOfferSession");
	return 1;
}

stock Lawyer_Approve(playerid, const params[])
{
	if(!IsACop(playerid) || !Lawyer_CanAct(playerid))
		return SendClientMessageEx(playerid, COLOR_GREY, "Chi si quan san sang moi duoc duyet luat su.");
	
	new lawyer;
	if(sscanf(params, "u", lawyer)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /accept lawyer [player]");
	
	if(!(0 <= lawyer < MAX_PLAYERS) || !IsPlayerConnected(lawyer) || !gPlayerLogged{lawyer})
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	
	if(!IsALawyer(lawyer) || !Lawyer_CanAct(lawyer)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong phai luat su san sang.");
	if(!Lawyer_IsNear(playerid, lawyer)) return SendClientMessageEx(playerid, COLOR_GREY, "Luat su phai o gan, cung interior va world.");
	
	ApprovedLawyer[lawyer] = 1;
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cho phep %s tha mot tu nhan.", GetPlayerNameEx(lawyer));
	SendClientMessageEx(lawyer, COLOR_LIGHTBLUE, "* Officer %s duyet cho ban tha mot tu nhan. Dung /free [player].", GetPlayerNameEx(playerid));
	return 1;
}

stock Lawyer_AcceptDefense(playerid)
{
	new lawyer = DefendOffer[playerid], price = DefendPrice[playerid];
	if(!Offer_IsCurrent(playerid, lawyer, "DefendOfferSession"))
	{
		DefendOffer[playerid] = INVALID_PLAYER_ID;
		DefendPrice[playerid] = 0;
		DeletePVar(playerid, "DefendOfferSession");
		return SendClientMessageEx(playerid, COLOR_GREY, "De nghi bao chua da het hieu luc.");
	}
	if(!IsALawyer(lawyer) || !Lawyer_CanAct(lawyer)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Luat su khong con san sang bao chua cho ban.");
	
	if(!Lawyer_IsNear(playerid, lawyer)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Luat su phai o gan, cung interior va world.");
	
	if(PlayerIsDead[playerid] || GetPVarInt(playerid, "Injured") || PlayerInfo[playerid][pJailTime] > 0 || PlayerInfo[playerid][pBeingSentenced] > 0)
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the nhan bao chua nay.");
	
	if(PlayerInfo[playerid][pWantedLevel] <= 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong con bi truy na.");
	
	if(PlayerInfo[playerid][pDefendTime] > 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Cho %d phut truoc khi nhan bao chua.", PlayerInfo[playerid][pDefendTime]);
	
	if(!(20000 <= price <= 1000000)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Gia bao chua khong con hop le.");
	
	if(GetPlayerCash(playerid) < price) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien bao chua.");
	
	if(GetPlayerCash(lawyer) > cellmax - price) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Luat su khong the nhan so tien nay.");

	DefendOffer[playerid] = INVALID_PLAYER_ID;
	DefendPrice[playerid] = 0;
	DeletePVar(playerid, "DefendOfferSession");
	--PlayerInfo[playerid][pWantedLevel];
	GivePlayerCash(playerid, -price);
	GivePlayerCash(lawyer, price);
	SetPlayerWantedLevel(playerid, PlayerInfo[playerid][pWantedLevel]);
	SetPlayerToTeamColor(playerid);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan bao chua gia $%d tu Lawyer %s.", price, GetPlayerNameEx(lawyer));
	SendClientMessageEx(lawyer, COLOR_LIGHTBLUE, "* %s nhan bao chua va tra ban $%d.", GetPlayerNameEx(playerid), price);
	return 1;
}

stock Lawyer_AcceptAppeal(playerid)
{
	new lawyer = AppealOffer[playerid];
	if(!Offer_IsCurrent(playerid, lawyer, "AppealOfferSession"))
	{
		Lawyer_ClearAppeal(playerid);
		return SendClientMessageEx(playerid, COLOR_GREY, "De nghi khang cao da het hieu luc.");
	}

	if(AppealOfferAccepted[playerid]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban da dong y voi luat su nay.");
	
	if(PlayerInfo[playerid][pBeingSentenced] <= 0 || PlayerIsDead[playerid]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong dang cho tuyen an.");
	
	if(!IsALawyer(lawyer) || !Lawyer_CanAct(lawyer)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Luat su do khong con san sang.");
	
	if(!Lawyer_IsNear(playerid, lawyer)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Luat su phai o gan, cung interior va world.");
	
	AppealOfferAccepted[playerid] = 1;
	new message[128];
	format(message, sizeof(message), "<< Lawyer %s dai dien %s trong vu khang cao dang cho xu ly >>", GetPlayerNameEx(lawyer), GetPlayerNameEx(playerid));
	SendGroupMessage(GROUP_TYPE_JUDICIAL, DEPTRADIO, message);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan khang cao tu Lawyer %s.", GetPlayerNameEx(lawyer));
	SendClientMessageEx(lawyer, COLOR_LIGHTBLUE, "* %s nhan khang cao. Da bao cho Judicial System.", GetPlayerNameEx(playerid));
	return 1;
}

CMD:lawyerduty(playerid, params[])
{
	if(GetPVarInt(playerid, "LawyerDuty") == 1)
	{
		Lawyer_StopDuty(playerid);
		return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da het ca va khong nhan cuoc goi luat su.");
	}

	if(!IsALawyer(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Lawyer!");
	
	if(!Lawyer_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the vao ca luat su.");
	
	SetPVarInt(playerid, "LawyerDuty", 1);
	++Lawyers;
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da vao ca luat su va se nhan cuoc goi can giup do.");
	return 1;
}

CMD:defendtime(playerid, params[])
{
	if(PlayerInfo[playerid][pDefendTime] < 1) {
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban co the nhan bao chua luc nay.");
	}
	else {
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban co the nhan bao chua sau %d phut.", PlayerInfo[playerid][pDefendTime]);
	}
	return 1;
}

CMD:offerappeal(playerid, params[])
{
	if(!IsALawyer(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Lawyer!");
	
	if(!Lawyer_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the de nghi khang cao.");
	
	new target;
	if(sscanf(params, "u", target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /offerappeal [player]");
	
	if(!Lawyer_IsNear(playerid, target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Khach phai o gan, cung interior va world.");
	
	if(PlayerInfo[target][pBeingSentenced] <= 0 || PlayerIsDead[target]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong dang cho tuyen an.");
	
	if(AppealOfferAccepted[target])
	{
		if(Offer_IsCurrent(target, AppealOffer[target], "AppealOfferSession") && IsALawyer(AppealOffer[target]))
			return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da co luat su khang cao nay.");
		
		Lawyer_ClearAppeal(target);
	}

	AppealOffer[target] = playerid;
	SetPVarInt(target, "AppealOfferSession", g_arrQueryHandle[playerid]);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban de nghi dich vu luat su cho %s.", GetPlayerNameEx(target));
	SendClientMessageEx(target, COLOR_WHITE, "%s de nghi dich vu luat su. Dung /accept appeal de dong y.", GetPlayerNameEx(playerid));
	return 1;
}

CMD:free(playerid, params[])
{
	if(!IsALawyer(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Lawyer!");
	
	if(!Lawyer_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the tha khach hang.");
	
	new target;
	if(sscanf(params, "u", target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /free [player]");
	
	if(!Lawyer_IsNear(playerid, target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan phai o gan, cung interior va world.");
	
	if(GetJobLevel(playerid, JOB_LAWYER) < 5 && !ApprovedLawyer[playerid])
		return SendClientMessageEx(playerid, COLOR_GREY, "Can si quan chap thuan de tha tu nhan.");
	
	if(PlayerInfo[target][pJailTime] <= 1 || WantLawyer[target] < 1 || PlayerIsDead[target]
		|| PlayerInfo[target][pBeingSentenced] > 0 || strfind(PlayerInfo[target][pPrisonReason], "[OOC]", true) != -1)
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua du dieu kien duoc luat su tha.");

	ApprovedLawyer[playerid] = 0;
	WantLawyer[target] = CallLawyer[target] = 0;
	PlayerInfo[target][pBailPrice] = 0;
	PlayerInfo[target][pJailTime] = 1;
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da tha %s ra tu.", GetPlayerNameEx(target));
	SendClientMessageEx(target, COLOR_LIGHTBLUE, "* Lawyer %s da giup ban ra tu.", GetPlayerNameEx(playerid));
	new oldSkill = PlayerInfo[playerid][pLawSkill], gained = PlayerInfo[playerid][pDoubleEXP] > 0 ? 2 : 1;
	if(oldSkill > cellmax - gained) gained = cellmax - oldSkill;
	PlayerInfo[playerid][pLawSkill] += gained;
	if(gained > 1) SendClientMessageEx(playerid, COLOR_YELLOW, "Ban nhan %d diem lawyer nho Double EXP. Token con %d gio.", gained, PlayerInfo[playerid][pDoubleEXP]);
	for(new i; i < 4; ++i)
	{
		if(oldSkill < JobSkills[JOB_SKILL_LAWYER][jobSkillThreshold][i] && PlayerInfo[playerid][pLawSkill] >= JobSkills[JOB_SKILL_LAWYER][jobSkillThreshold][i])
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "* Ky nang lawyer dat cap %d.", i + 2);
			break;
		}
	}
	return 1;
}

CMD:finishappeal(playerid, params[])
{
	if(!IsALawyer(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Lawyer!");
	
	new target;
	if(sscanf(params, "u", target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /finishappeal [player]");
	
	if(!(0 <= target < MAX_PLAYERS) || !IsPlayerConnected(target) || !gPlayerLogged{target}) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	
	if(AppealOffer[target] != playerid || !Offer_IsCurrent(target, playerid, "AppealOfferSession"))
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong de nghi dich vu cho nguoi do.");
	
	Lawyer_ClearAppeal(target);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da xong dich vu luat su cho %s.", GetPlayerNameEx(target));
	SendClientMessageEx(target, COLOR_WHITE, "%s da xong dich vu luat su.", GetPlayerNameEx(playerid));
	return 1;
}

CMD:defend(playerid, params[])
{
	if(!IsALawyer(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Lawyer!");
	
	if(!Lawyer_CanAct(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the de nghi bao chua.");
	
	new now = gettime();
	if(now < PlayerInfo[playerid][pLawyerTime]) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban phai cho %d giay!", PlayerInfo[playerid][pLawyerTime] - now);
	
	new target, price;
	if(sscanf(params, "ud", target, price)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /defend [player] [price]");
	
	if(!(20000 <= price <= 1000000)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Gia bao chua phai tu $20,000 den $1,000,000.");
	
	if(!Lawyer_IsNear(playerid, target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Khach phai o gan, cung interior va world.");
	
	if(PlayerInfo[target][pWantedLevel] <= 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong bi truy na.");
	
	if(PlayerInfo[target][pDefendTime] > 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do phai cho %d phut de nhan bao chua.", PlayerInfo[target][pDefendTime]);
	
	if(PlayerIsDead[target] || GetPVarInt(target, "Injured") || PlayerInfo[target][pJailTime] > 0 || PlayerInfo[target][pBeingSentenced] > 0)
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do chua the nhan bao chua.");
	
	PlayerInfo[playerid][pLawyerTime] = now + 60;
	DefendOffer[target] = playerid;
	DefendPrice[target] = price;
	SetPVarInt(target, "DefendOfferSession", g_arrQueryHandle[playerid]);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Moi bao chua %s: $%d.", GetPlayerNameEx(target), price);
	SendClientMessageEx(target, COLOR_LIGHTBLUE, "* Lawyer %s bao chua gia $%d. /accept defense de dong y.", GetPlayerNameEx(playerid), price);
	return 1;
}