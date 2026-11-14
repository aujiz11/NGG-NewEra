// by Le Tuan Kiet (aujiz11)

#include <YSI_Coding\y_hooks>

static DB:GeoIPDatabase;

hook OnGameModeExit() {
	if(GeoIPDatabase) DB_Close(GeoIPDatabase);
	GeoIPDatabase = DB:0;
	return 1;
}

stock bool:GetIPLocation(const ip[], country[], province[], city[], countrySize = sizeof(country), provinceSize = sizeof(province), citySize = sizeof(city)) {
	format(country, countrySize, "Unknown");
	format(province, provinceSize, "Unknown");
	format(city, citySize, "Unknown");
	new address;
	if(!DottedToIntIP(ip, address)) return false;
	if((address >>> 24) == 127) {
		format(country, countrySize, "Localhost");
		return true;
	}

	if(!GeoIPDatabase) GeoIPDatabase = DB_Open("IPList.db", SQLITE_OPEN_READONLY);
	if(!GeoIPDatabase) return print("[GeoIP] Unable to open IPList.db, location lookup is unavailable."), false;

	new DBResult:result = DB_ExecuteQuery(GeoIPDatabase, "SELECT `isofull`.`fullname`,`locations`.`province`,`locations`.`city` FROM `IPTable` JOIN `isofull` ON `IPTable`.`country`=`isofull`.`alpha_two` JOIN `locations` ON `IPTable`.`location`=`locations`.`id` WHERE `IPTable`.`start`=(SELECT max(`start`) FROM `IPTable` WHERE `start`<=%u) AND `IPTable`.`end`>=%u", address, address);
	new bool:found;
	if(result) {
		if(DB_GetRowCount(result)) {
			DB_GetFieldString(result, 0, country, countrySize);
			DB_GetFieldString(result, 1, province, provinceSize);
			DB_GetFieldString(result, 2, city, citySize);
			if(!province[0]) format(province, provinceSize, "Unknown");
			if(!city[0]) format(city, citySize, "Unknown");
			found = true;
		}
		DB_FreeResultSet(result);
	}
	else print("[GeoIP] Unable to query IPList.db, location lookup is unavailable.");
	return found;
}

stock bool:GetIPCountry(const ip[], country[], size = sizeof(country)) {
	new province[256], city[256];
	return GetIPLocation(ip, country, province, city, size, sizeof(province), sizeof(city));
}

stock bool:GetPlayerLocation(playerid, country[], province[], city[], countrySize = sizeof(country), provinceSize = sizeof(province), citySize = sizeof(city)) {
	new ip[16];
	if(IsPlayerConnected(playerid)) GetPlayerIp(playerid, ip, sizeof(ip));
	return GetIPLocation(ip, country, province, city, countrySize, provinceSize, citySize);
}

stock GetPlayerCountry(playerid) {
	new country[128], province[256], city[256];
	GetPlayerLocation(playerid, country, province, city);
	return country;
}

stock GetPlayerProvince(playerid) {
	new country[128], province[256], city[256];
	GetPlayerLocation(playerid, country, province, city);
	return province;
}

stock GetPlayerCity(playerid) {
	new country[128], province[256], city[256];
	GetPlayerLocation(playerid, country, province, city);
	return city;
}
