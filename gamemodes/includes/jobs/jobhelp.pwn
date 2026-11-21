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
	JOB_SKILL_GARBAGE
};

CMD:jobhelp(playerid, const params[])
{
	Job_BuildMenu(szMiscArray, sizeof(szMiscArray));
	strcat(szMiscArray, "\nFishing (khong can o cong viec)", sizeof(szMiscArray));
	return Dialog_Show(playerid, job_help, DIALOG_STYLE_LIST, "Thong tin cong viec", szMiscArray, "Chon", "Dong");
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
		return Dialog_Show(playerid, job_information, DIALOG_STYLE_MSGBOX, "Fishing", "Fishing khong chiem o cong viec.\nLenh: /fish, /myfish, /sellfish, /fishhelp.\nDung /skill 8 de xem tien do Fishing.", "Quay lai", "Dong");
	}
	szMiscArray[0] = EOS;
	switch(job)
	{
		case JOB_DETECTIVE: strcat(szMiscArray, "Theo doi dien thoai dang hoat dong bang /trace [phone number].\nKy nang quyet dinh thoi gian theo doi va thoi gian cho.", sizeof(szMiscArray));
		case JOB_LAWYER: strcat(szMiscArray, "Cung cap dich vu phap ly va khang cao.\nLenh: /lawyerduty, /defend, /defendtime, /free, /offerappeal, /finishappeal.\nThanh vien Judicial du dieu kien cung co the lam viec.", sizeof(szMiscArray));
		case JOB_PROSTITUTE: strcat(szMiscArray, "Cung cap dich vu khi ngoi cung xe voi khach.\nLenh: /sex [player] [price].\nGia tu $1 den $10,000.", sizeof(szMiscArray));
		case JOB_MECHANIC: strcat(szMiscArray, "Sua chua va bao duong xe.\nLenh: /mechduty, /fix, /repair, /refill, /nos, /hyd.\nTho lam viec tai doanh nghiep Mechanic cung duoc sua mot so hang muc.", sizeof(szMiscArray));
		case JOB_BODYGUARD: strcat(szMiscArray, "Ban ao giap va kham nguoi choi.\nLenh: /guard [player] [price], /frisk [player].\nPolice van giu quyen kham nguoi rieng.", sizeof(szMiscArray));
		case JOB_ARMS_DEALER: strcat(szMiscArray, "Che tao vu khi bang vat lieu.\nDung /sellgun de xem cong thuc da mo va chi phi vat lieu.\nLenh: /sellgun [player] [weapon].", sizeof(szMiscArray));
		case JOB_BOXER: strcat(szMiscArray, "To chuc dau quyen anh tai phong tap.\nLenh: /fight, /train, /boxstats.\nNam cap ky nang quyet dinh mau thi dau. Danh hieu quyen anh la thu hang rieng.", sizeof(szMiscArray));
		case JOB_DRUG_SMUGGLER: strcat(szMiscArray, "Nhan cac goi ma tuy tai diem da cau hinh.\nLenh: /getdrugs, /buypot, /buyopium.\nDung /skill 4 de xem tien do Drug Smuggling.", sizeof(szMiscArray));
		case JOB_STREET_SWEEPER: strcat(szMiscArray, "Xoa hinh ve bang nhom trong thanh pho.\nLenh: /cleantag, /gangtaghelp.\nCac to chuc don dep van giu quyen rieng.", sizeof(szMiscArray));
		case JOB_TAXI: strcat(szMiscArray, "Cho khach bang taxi va xe buyt.\nDung /fare [price] de bat dau hoac ket thuc ca lam.\nThanh vien Taxi va tai xe co giay phep van giu quyen rieng.", sizeof(szMiscArray));
		case JOB_CRAFTSMAN: strcat(szMiscArray, "Che tao thiet bi huu ich tu vat lieu.\nDung /craft de xem cong thuc.\nNguoi choi co the dung thiet bi da mua ma khong can lam Craftsman.", sizeof(szMiscArray));
		case JOB_BARTENDER: strcat(szMiscArray, "Ban do uong khi lam viec tai quan bar.\nLenh: /selldrink [player].", sizeof(szMiscArray));
		case JOB_SHIPMENT: strcat(szMiscArray, "Van chuyen hang hoa va vat tu doanh nghiep.\nLenh: /loadshipment, /checkcargo, /hijackcargo.\nDung /cancel shipment de huy chuyen giao hang.", sizeof(szMiscArray));
		case JOB_PIZZA: strcat(szMiscArray, "Nhan va giao pizza bang Pizzaboy.\nLenh: /getpizza.\nMac dong phuc Pizza Stack va giao truoc khi pizza nguoi.", sizeof(szMiscArray));
		case JOB_TREASURE: strcat(szMiscArray, "Tim tren bai bien bang may do kim loai con pin tu Craftsman.\nLenh: /search, /selltreasure.\nDung /skill 10 de xem tien do.", sizeof(szMiscArray));
		case JOB_GARBAGE: strcat(szMiscArray, "Lai xe rac qua nam diem thu gom roi quay ve bai rac.\nLenh: /garbagerun, /cancel garbage.", sizeof(szMiscArray));
	}
	strcat(szMiscArray, "\n\nXin viec tai diem da cau hinh bang Y hoac /join. Dung /quitjob [slot] de nghi viec.", sizeof(szMiscArray));
	return Dialog_Show(playerid, job_information, DIALOG_STYLE_MSGBOX, GetJobName(job), szMiscArray, "Quay lai", "Dong");
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
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /skill [number]");
		for(new item; item < sizeof(JobSkillMenu); ++item) {
			SendClientMessageEx(playerid, COLOR_GREY, "%d. %s", item + 1, JobSkills[JobSkillMenu[item]][jobSkillName]);
		}
		return 1;
	}

	new item;
	if(sscanf(params, "d", item) || !(1 <= item <= sizeof(JobSkillMenu)))
		return SendClientMessageEx(playerid, COLOR_GREY, "So ky nang khong hop le. Dung /skill de xem danh sach.");
	
	new 
		skill = JobSkillMenu[item - 1], 
		points = PlayerInfo[playerid][JobSkills[skill][jobSkillField]], 
		level = Job_SkillLevel(skill, points);
	
	SendClientMessageEx(playerid, COLOR_YELLOW, "Cap ky nang %s: %d. Diem ky nang: %d.", JobSkills[skill][jobSkillName], level, points);
	if(1 <= level < 5) 
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban can them %d diem ky nang de dat cap %d.", JobSkills[skill][jobSkillThreshold][level - 1] - points, level + 1);
	}
	return 1;
}
