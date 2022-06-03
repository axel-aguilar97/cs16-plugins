#if defined _dg_stocks_included
	#endinput
#endif
#define _dg_stocks_included

#if !defined _dg_included
	#include <dg>
#endif

#define isDigitDefine(%0) (48 <= %0 <= 57)
#define isLetterDefine(%0) (65 <= %0 <= 90 || 97 <= %0 <= 122)

stock getServerName(const with_numeral) {
	new sHostName[128];
	new sServerName[64];
	new sNone[64];

	get_cvar_string("hostname", sHostName, charsmax(sHostName));
	split(sHostName, sServerName, charsmax(sServerName), sNone, charsmax(sNone), " |");
	sNone[0] = EOS;

	if(!with_numeral) {
		replace_all(sServerName, charsmax(sServerName), "#", "");
		replace_all(sServerName, charsmax(sServerName), " ", "_");
	}

	return sServerName;
}

stock clientPrint(id, const type, const message[], any:...) {
	if(id > 0 && !is_user_connected(id)) {
		return;
	}

	static iTextMsg;

	if(iTextMsg || (iTextMsg = get_user_msgid("TextMsg"))) {
		new sRealMessage[MAX_CHARACTER_SAY];
		new sMessage[MAX_CHARACTER_SAY];
		new iLen;
		new iPlayers[MAX_PLAYERS];
		new iPlayersCount;
		new iUserId;

		if(numargs() < 4) {
			iLen = copy(sRealMessage, charsmax(sRealMessage), message);
		} else {
			iLen = vformat(sRealMessage, charsmax(sRealMessage), message, 4);
		}

		iLen = copy(sMessage, charsmax(sMessage), sRealMessage);
		sMessage[iLen++] = '^n';
		sMessage[iLen] = 0;

		if(id > 0) {
			iPlayers[0] = id;
			iPlayersCount = 1;
		} else {
			get_players_ex(iPlayers, iPlayersCount, (GetPlayers_ExcludeBots | GetPlayers_ExcludeHLTV));
		}

		for(id = 0; id < iPlayersCount; ++id) {
			iUserId = iPlayers[id];

			if(REU_GetProtocol(iUserId) != 47) {
				client_print(iUserId, type, sRealMessage);
			} else {
				message_begin(MSG_ONE, iTextMsg, _, iUserId);
				write_byte(type);
				write_string(sMessage);
				message_end();
			}
		}
	}
}

stock clientPrintColor(const id, const sender=print_team_default, const message[], any:...) {
	if(id > 0 && !is_user_connected(id)) {
		return;
	}

	new sMessage[MAX_CHARACTER_SAY];
	new iLen;

	if(numargs() < 4) {
		iLen = copy(sMessage, charsmax(sMessage), message);
	} else {
		iLen = vformat(sMessage, charsmax(sMessage), message, 4);
	}

	sMessage[iLen] = 0;

	replace_all(sMessage, charsmax(sMessage), "!g", "^4");
	replace_all(sMessage, charsmax(sMessage), "!t", "^3");
	replace_all(sMessage, charsmax(sMessage), "!y", "^1");

	if(sender == print_team_grey) {
		client_print_color(id, sender, "^4*^1 %s", sMessage);
	} else {
		client_print_color(id, sender, "^4[%s]^1 %s", __PLUGIN_COMMUNITY_PREFIX, sMessage);
	}
}

stock consolePrint(const id, const message[], any:...) {
	new sMessage[MAX_CHARACTER_SAY];
	new iLen;

	if(numargs() < 3) {
		iLen = copy(sMessage, charsmax(sMessage), message);
	} else {
		iLen = vformat(sMessage, charsmax(sMessage), message, 3);
	}

	sMessage[iLen] = 0;

	console_print(id, "[%s] %s", __PLUGIN_COMMUNITY_PREFIX, sMessage);
}

stock clearDHUD() {
	new i;
	for(i = 0; i < 8; ++i) {
		set_dhudmessage(0, 0, 0, -1.0, 0.2, 0, 0.0, 0.1, 0.1, 0.1);
		show_dhudmessage(0, "");
	}
}

stock showDHUDMessage(const id, const color_r=255, const color_g=255, const color_b=255, const Float:pos_x=-1.0, const Float:pos_y=-1.0, const effect=0, const Float:time=0.1, const message[], any:...) {
	new sMessage[MAX_CHARACTER_SAY];
	new iLen;
	new i;

	if(numargs() < 10) {
		iLen = copy(sMessage, charsmax(sMessage), message);
	} else {
		iLen = vformat(sMessage, charsmax(sMessage), message, 10);
	}

	sMessage[iLen] = 0;

	for(i = 0; i < 8; ++i) {
		set_dhudmessage(000, 000, 000, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0);
		show_dhudmessage(id, "");
	}

	set_dhudmessage(color_r, color_g, color_b, pos_x, pos_y, effect, 0.0, time, 1.0, 1.0);
	show_dhudmessage(id, sMessage);
}

stock bool:isLetter(const string[]) {
	new i;
	new iLen = strlen(string);

	for(i = 0; i < iLen; ++i) {
		if(!isLetterDefine(string[i])) {
			return false;
		}
	}

	return true;
}

stock bool:isDigital(const string[]) {
	new i;
	new iLen = strlen(string);

	for(i = 0; i < iLen; ++i) {
		if(!isDigitDefine(string[i])) {
			return false;
		}
	}

	return true;
}

stock bool:isAlphaNumeric(const string[]) {
	new i;
	new iLen = strlen(string);

	for(i = 0; i < iLen; ++i) {
		if(!isLetterDefine(string[i]) && !isDigitDefine(string[i])) {
			return false;
		}
	}

	return true;
}

stock addDot(const number, output[], const output_len) {
	static sTemp[16];
	static iOutputPos;
	static iNumPos;
	static iNumLen;

	iOutputPos = 0;
	iNumPos = 0;
	iNumLen = num_to_str(number, sTemp, charsmax(sTemp));

	while((iNumPos < iNumLen) && (iOutputPos < output_len)) {
		output[iOutputPos++] = sTemp[iNumPos++];

		if((iNumLen - iNumPos) && ((iNumLen - iNumPos) % 3) == 0) {
			output[iOutputPos++] = '.';
		}
	}

	output[iOutputPos] = EOS;
	return iOutputPos;
}

stock addDotSpecial(const number[], output[], const output_len) {
	static iOutputPos;
	static iNumPos;
	static iNumLen;

	iOutputPos = 0;
	iNumPos = 0;
	iNumLen = contain(number, ".");

	if(iNumLen == -1) {
		iNumLen = strlen(number);
	}

	while((iNumPos < iNumLen) && (iOutputPos < output_len)) {
		output[iOutputPos++] = number[iNumPos++];

		if((iOutputPos < output_len) && (iNumPos < iNumLen) && (((iNumLen - iNumPos) % 3) == 0)) {
			output[iOutputPos++] = '.';
		}
	}

	if(iOutputPos < output_len) {
		iOutputPos += copy(output[iOutputPos], (output_len - iOutputPos), number[iNumLen]);
	}

	return iOutputPos;
}

stock getUnixToTime(const unix) {
	new sBuffer[32];
	sBuffer[0] = EOS;

	if(unix <= 0) {
		return sBuffer;
	}

	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;

	unix_to_time(unix, iYear, iMonth, iDay, iHour, iMinute, iSecond);

	formatex(sBuffer, charsmax(sBuffer), "%d-%02d-%02d a las %02d:%02d:%02d", iYear, iMonth, iDay, iHour, iMinute, iSecond);
	return sBuffer;
}

stock getCooldDownTime(const seconds) {
	new sTime[32];
	sTime[0] = EOS;

	if(seconds <= 0) {
		return sTime;
	}

	formatex(sTime, charsmax(sTime), "%02d:%02d %s%s", (seconds / 60), (seconds % 60), ((seconds < 60) ? "segundo" : "minuto"), (((seconds < 60 && seconds == 1) || (seconds >= 60 && seconds < 120)) ? "" : "s"));
	return sTime;
}

stock bool:getUserIsSteamId(const authid[]) {
	new iLen = strlen(authid);

	if(equali(authid, "STEAM_ID_PENDING") || equali(authid, "STEAM_ID_LAN") || iLen <= 16 || (authid[0] == 'V' && authid[1] == 'A' && authid[2] == 'L')) {
		return false;
	}

	return true;
}

stock TeamName:getUserTeam(const id) {
	return get_member(id, m_iTeam);
}

stock setUserTeam(const id, const TeamName:team) {
	set_member(id, m_iTeam, team);
}

stock rgSetUserTeam(const id, const TeamName:team, const ModelName:model) {
	rg_set_user_team(id, team, model);
}

stock getUsersPlaying(const TeamName:team) {
	new i;
	new TeamName:iTeam;
	new iPlayingCount = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		iTeam = getUserTeam(i);

		if(iTeam != team) {
			continue;
		}

		++iPlayingCount;
	}

	return iPlayingCount;
}

stock getUsersAlive() {
	new i;
	new iPlayingAlive = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		++iPlayingAlive;
	}

	return iPlayingAlive;
}

stock getUsersAliveTeam(const TeamName:team) {
	new i;
	new TeamName:iTeam;
	new iPlayingAlive = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		iTeam = getUserTeam(i);

		if(iTeam != team) {
			continue;
		}

		++iPlayingAlive;
	}

	return iPlayingAlive;
}

stock getUserRandomAlive() {
	new i;
	new iUserId[MAX_PLAYERS + 1];
	new j = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		iUserId[j] = i;
		++j;
	}

	return iUserId[random_num(0, (j - 1))];
}

stock playSound(const id, const sound[], const stopsound=0) {
	new iLenMp3 = (strlen(sound) - 4);

	if(containi(sound[iLenMp3], ".mp3") != -1) {
		client_cmd(id, "mp3 play ^"%s^"", sound);
	} else {
		if(stopsound) {
			client_cmd(id, "stopsound");
		}

		client_cmd(id, "spk ^"%s^"", sound);
	}
}