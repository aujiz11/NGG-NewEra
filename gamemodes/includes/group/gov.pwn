/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Government Group Type

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

CMD:settax(playerid, params[])
{
	if(!(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS && arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] == GROUP_TYPE_GOV)) {
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Government Leader.");
		return 1;
	}

	new tax;
	if(sscanf(params, "d", tax)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /settax [percentage]");

	if (tax < 1 || tax > 29)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ty le phai lon hon 0 va duoi 30.");
		return 1;
	}
	if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 1)
	{
		TaxValue = tax;
		Misc_Save();
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Thue thu nhap SA da dat la %d phan tram (moi ky luong).", TaxValue);
	}
	if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 2)
	{
		TRTaxValue = tax;
		Misc_Save();
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Thue thu nhap NE da dat la %d phan tram (moi ky luong).", TRTaxValue);
	}
	return 1;
}

CMD:taxwithdraw(playerid, params[])
{
	if(!(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS && arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] == GROUP_TYPE_GOV))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Government Leader.");
		return 1;
	}

	new string[128], amount, reason[64], str[128];
	if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 1)
	{
		if(sscanf(params, "ds[64]", amount, reason))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /taxwithdraw [amount] [reason]");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET: $%s.", number_format(Tax));
			return 1;
		}

		if(amount < 0)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "So luong khong hop le.");
			return 1;
		}
		if( Tax > amount )
		{
			Tax -= amount;
			Misc_Save();
			GivePlayerCash( playerid, amount );
			SendClientMessageEx( playerid, COLOR_WHITE, "Ban da rut $%s tu ket.", number_format(amount) );
			format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s da rut $%s tien thue SA tu ket, ly do: %s.",GetPlayerNameEx(playerid),number_format(amount),reason);
			ABroadCast( COLOR_YELLOW, string, 2);
			format(string,sizeof(string),"AdmWarning: %s(%d) has withdrawn $%s of the SA tax money from the vault, reason: %s.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), number_format(amount),reason);
			Log("logs/rpspecial.log", string);
			format(string,sizeof(string),"%s has withdrawn $%s of the SA tax money from the vault, reason: %s.",GetPlayerNameEx(playerid), number_format(amount),reason);
			GroupPayLog(PlayerInfo[playerid][pLeader], str);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong du ngan sach.");
		}
	}
	if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 2)
	{
		if(sscanf(params, "ds[64]", amount, reason))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /taxwithdraw [amount] [reason]");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET: $%s.", number_format(TRTax));
			return 1;
		}

		if(amount < 0)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "So luong khong hop le.");
			return 1;
		}
		if( TRTax > amount )
		{
			TRTax -= amount;
			Misc_Save();
			GivePlayerCash( playerid, amount );
			SendClientMessageEx( playerid, COLOR_WHITE, "Ban da rut $%s tu ket.", number_format(amount) );
			format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s da rut $%s tien thue NE tu ket, ly do: %s.",GetPlayerNameEx(playerid),number_format(amount),reason);
			ABroadCast( COLOR_YELLOW, string, 2);
			format(string,sizeof(string),"AdmWarning: %s(%d) has withdrawn $%s of the NE tax money from the vault, reason: %s.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), number_format(amount),reason);
			Log("logs/rpspecial.log", string);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong du ngan sach.");
		}
	}

	return 1;
}

CMD:taxdeposit(playerid, params[])
{
	if(!(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS && arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] == GROUP_TYPE_GOV))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Government Leader.");
		return 1;
	}

	new string[128], amount;
	if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 1)
	{
		if(sscanf(params, "d", amount))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /taxdeposit [amount]");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET: $%s.", number_format(Tax));
			return 1;
		}

		if(amount < 0)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "So luong khong hop le.");
			return 1;
		}

		if (GetPlayerCash(playerid) < amount)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co du tien mat.");
			return 1;
		}
		Tax += amount;
		Misc_Save();
		GivePlayerCash(playerid, -amount);
		SendClientMessageEx( playerid, COLOR_WHITE, "Ban da gui $%s vao ket SA.", number_format(amount) );
		format(string,sizeof(string),"%s has deposited $%s into the SA tax vault.",GetPlayerNameEx(playerid), number_format(amount));
		GroupPayLog(PlayerInfo[playerid][pLeader], string);
	}
	if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 2)
	{
		if(sscanf(params, "d", amount))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /taxdeposit [amount]");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET: $%s.", number_format(TRTax));
			return 1;
		}

		if(amount < 0)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "So luong khong hop le.");
			return 1;
		}

		if (GetPlayerCash(playerid) < amount)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co du tien mat.");
			return 1;
		}
		TRTax += amount;
		Misc_Save();
		GivePlayerCash(playerid, -amount);
		SendClientMessageEx( playerid, COLOR_WHITE, "Ban da gui $%s vao ket NE.", number_format(amount) );
		format(string,sizeof(string),"%s has deposited $%s into the NE tax vault.",GetPlayerNameEx(playerid), number_format(amount));
		GroupPayLog(PlayerInfo[playerid][pLeader], string);
	}
	return 1;
}

CMD:settaxmoney(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new country, amount;
	if(sscanf(params, "dd", country, amount))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /settaxmoney [SA(1)/NE(2)] [amount]");
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET SA: $%s.", number_format(Tax));
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET NE: $%s.", number_format(TRTax));
		return 1;
	}
	switch(country)
	{
	    case 1:
	    {
			Tax = amount;
			SendClientMessageEx( playerid, COLOR_WHITE, "Da dat tien thue la $%s.", number_format(amount) );
	    }
	    case 2:
	    {
			TRTax = amount;
			SendClientMessageEx( playerid, COLOR_WHITE, "Da dat tien thue la $%s.", number_format(amount) );
	    }
	}
	return 1;
}

CMD:checktax(playerid, params[])
{
	if(!(0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS && arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] == GROUP_TYPE_GOV))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai quan chuc chinh phu.");
		return 1;
	}
	if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 1)
	{
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET SA: $%s.", number_format(Tax));
	}
	else if(arrGroupData[PlayerInfo[playerid][pLeader]][g_iAllegiance] == 2)
	{
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* SO DU KET NE: $%s.", number_format(TRTax));
	}
	return 1;
}