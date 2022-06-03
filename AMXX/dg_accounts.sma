#include <dg>

#include <sqlx>
#include <grip>

#pragma semicolon 1;

/*
	TO DO:
	Agregar comandos para banear por cuenta
*/

new const __PLUGIN_NAME[] = "Sistema de Cuentas";
new const __PLUGIN_VERSION[] = "1.0";
new const __PLUGIN_AUTHOR[] = "Atsu:)";

new const __SQL_LOG_FILE[] = "mysql.log";

new const __SOUND_REGISTER[] = "fvox/bell.wav";
new const __SOUND_LOGIN[] = "buttons/bell1.wav";

const MAX_STRING_PASSWORD_LIMIT = 20;
const MAX_STRING_CODE = 12;
const MAX_BAN_ACCOUNT = 3;
const IDLE_LOGIN = 45;
const MAX_JUST_REGISTERED = 2592000; // 2.592.000s = 1mes | Tiempo en el que el jugador deja de ser "Recién registrado"

enum _:structIdTasks (+= 1234) {
	TASK_CHECK_AFK = 10000,
	TASK_MESSAGE_VIP,
	TASK_MESSAGE_VINC
};

enum _:structIdStatus {
	STATUS_CHECK_ACCOUNT = 0,
	STATUS_BANNED,
	STATUS_UNREGISTERED,
	STATUS_CONFIRM,
	STATUS_REGISTERED,
	STATUS_LOADING,
	
	STATUS_LOGGED,
	STATUS_PLAYING
};

enum _:structIdQuerys {
	QUERY_CHECK_ACCOUNT = 0,
	QUERY_CREATE_ACCOUNT,
	QUERY_CHECK_ANOTHER_BAN,
	QUERY_LOAD_ACCOUNT,
	QUERY_CHECK_BAN,
	QUERY_CHECK_AMOUNT_BANS,
	QUERY_CHECK_BAN_IN_COMMAND
};

new g_PlayerName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_PlayerIp[MAX_PLAYERS + 1][MAX_IP_LENGTH];
new g_PlayerSteamId[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new g_PlayerSteamIdCache[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new g_AccountStatus[MAX_PLAYERS + 1];
new g_AccountId[MAX_PLAYERS + 1];
new g_AccountLastIp[MAX_PLAYERS + 1][MAX_IP_LENGTH];
new g_AccountPassword[MAX_PLAYERS + 1][MAX_CHARACTER_MD5];
new g_AccountRecoveryCode[MAX_PLAYERS + 1][MAX_STRING_CODE];
new g_AccountSinceConnection[MAX_PLAYERS + 1];
new g_AccountLastConnection[MAX_PLAYERS + 1];
new g_AccountAutologin[MAX_PLAYERS + 1];
new g_AccountJustRegistered[MAX_PLAYERS + 1];
new g_AccountVinc[MAX_PLAYERS + 1];
new g_AccountVincMail[MAX_PLAYERS + 1][128];
new g_AccountVincPassword[MAX_PLAYERS + 1][128];
new g_AccountVincAppMobile[MAX_PLAYERS + 1];
new g_AccountLoginDaily[MAX_PLAYERS + 1];
new g_AccountLoginDailyConsecutive[MAX_PLAYERS + 1];
new g_AccountLoginToday[MAX_PLAYERS + 1];
new g_AccountAttempts[MAX_PLAYERS + 1];
new g_AccountBanned_StaffName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_AccountBanned_Start[MAX_PLAYERS + 1];
new g_AccountBanned_Finish[MAX_PLAYERS + 1];
new g_AccountBanned_Reason[MAX_PLAYERS + 1][64];
new g_AccountBanned_Count[MAX_PLAYERS + 1];

new Handle:g_SqlTuple;
new g_SqlQuery[1024];
new g_ServerId;
new g_GlobalRank;
new g_fwdRegisterPlayerData;
new g_fwdLoadPlayerData;
new g_fwdJoinPlayer;
new g_fwdVincPlayerSuccess;
new g_fwdSaveOtherData;

public plugin_natives() {
	register_library("dg_accounts");

	register_native("dg_get_user_acc_status", "native__GetUserAccStatus");
	register_native("dg_set_user_acc_status", "native__SetUserAccStatus", 1);
	register_native("dg_get_user_acc_id", "native__GetUserAccId");
	register_native("dg_get_user_acc_ld", "native__GetUserAccLD"); // Login Daily
	register_native("dg_get_user_acc_ldc", "native__GetUserAccLDC"); // Login Daily Consecutive
	register_native("dg_get_user_acc_vinc", "native__GetUserAccVinc"); // Vinc Forum
	register_native("dg_get_user_acc_vinc_am", "native__GetUserAccVincAM"); // Vinc App Mobile

	register_native("dg_get_global_rank", "native__GetGlobalRank", 1);

	register_native("dg_get_user_menu_banned", "native__GetUserMenuBanned");
	register_native("dg_get_user_menu_login", "native__GetUserMenuLogin");
	register_native("dg_get_user_menu_join", "native__GetUserMenuJoin");
	register_native("dg_get_user_menu_vinc", "native__GetUserMenuVinc");
}

public plugin_precache() {
	precache_sound(__SOUND_REGISTER);
	precache_sound(__SOUND_LOGIN);
}

public plugin_init() {
	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	register_clcmd("INGRESAR_CLAVE", "clcmd__EnterPassword");
	register_clcmd("V_INGRESAR_MAIL", "clcmd__VEnterMail");
	register_clcmd("V_INGRESAR_CLAVE", "clcmd__VEnterPassword");

	register_clcmd("acc_ban", "clcmd__Ban");
	register_clcmd("acc_unban", "clcmd__Unban");

	oldmenu_register();

	loadStuff();
}

public plugin_cfg() {
	loadSql();
}

public plugin_end() {
	SQL_FreeHandle(g_SqlTuple);
}

public client_connectex(id, const name[], const ip[], reason[128]) {
	copy(g_PlayerName[id], charsmax(g_PlayerName[]), name);

	new sIp[MAX_IP_WITH_PORT_LENGTH];
	new sPort[8];

	copy(sIp, charsmax(sIp), ip);
	strtok(sIp, g_PlayerIp[id], charsmax(g_PlayerIp[]), sPort, charsmax(sPort), ':');
}

public client_authorized(id, const authid[]) {
	copy(g_PlayerSteamId[id], charsmax(g_PlayerSteamId[]), authid);
	g_PlayerSteamIdCache[id][0] = EOS;
}

public client_putinserver(id) {
	g_AccountStatus[id] = STATUS_CHECK_ACCOUNT;
	g_AccountId[id] = 0;
	g_AccountLastIp[id][0] = EOS;
	g_AccountPassword[id][0] = EOS;
	g_AccountRecoveryCode[id][0] = EOS;
	g_AccountSinceConnection[id] = 0;
	g_AccountLastConnection[id] = 0;
	g_AccountAutologin[id] = 0;
	g_AccountJustRegistered[id] = 0;
	g_AccountVinc[id] = 0;
	g_AccountVincMail[id][0] = EOS;
	g_AccountVincPassword[id][0] = EOS;
	g_AccountVincAppMobile[id] = 0;
	g_AccountLoginDaily[id] = 0;
	g_AccountLoginDailyConsecutive[id] = 0;
	g_AccountLoginToday[id] = 0;
	g_AccountAttempts[id] = 0;
	g_AccountBanned_StaffName[id][0] = EOS;
	g_AccountBanned_Start[id] = 0;
	g_AccountBanned_Finish[id] = 0;
	g_AccountBanned_Reason[id][0] = EOS;
	g_AccountBanned_Count[id] = 0;

	remove_task(id + TASK_CHECK_AFK);
	set_task(45.0, "task__CheckAfk", id + TASK_CHECK_AFK);

	if(!is_user_bot(id) && !is_user_hltv(id)) {
		loadAccountData(id);
	}
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	remove_task(id + TASK_CHECK_AFK);
	remove_task(id + TASK_MESSAGE_VIP);
	remove_task(id + TASK_MESSAGE_VINC);

	if((STATUS_LOGGED <= g_AccountStatus[id] <= STATUS_PLAYING)) {
		saveAccountData(id);

		new iReturn;

		ExecuteForward(g_fwdSaveOtherData, iReturn, id, g_AccountId[id]);
	}
}

public clcmd__EnterPassword(const id) {
	new sBuffer[MAX_CHARACTER_MD5];
	read_argv(1, sBuffer, charsmax(sBuffer));

	if(g_AccountStatus[id] == STATUS_REGISTERED) {
		hash_string(sBuffer, Hash_Md5, sBuffer, charsmax(sBuffer));

		if(equal(sBuffer, g_AccountPassword[id])) {
			g_AccountStatus[id] = STATUS_LOADING;

			loadPlayerData(id);

			playSound(id, __SOUND_LOGIN);

			clientPrintColor(id, _, "Bienvenido !t%s!y nuevamente al servidor !g%s!y.", g_PlayerName[id], __SERVERS[g_ServerId][serverName]);
			
			if(!g_AccountLoginToday[id]) {
				g_AccountLoginToday[id] = 1;

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `%saccounts` SET `login_today`='1' WHERE (`name`=^"%s^");", __SERVERS[g_ServerId][serverSqlPrefixTable], g_PlayerName[id]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
			}
		} else {
			++g_AccountAttempts[id];

			if(g_AccountAttempts[id] == 3) {
				rh_drop_client(id, fmt("Te hemos expulsado porque has realizado demasiados intentos para ingresar a la cuenta.", get_user_userid(id)));
			} else {
				clientPrintColor(id, _, "La contraseña que has ingresado es incorrecta. Inténtalo nuevamente.");
				showMenu__LogIn(id);
			}
		}
	} else {
		if(g_AccountStatus[id] == STATUS_UNREGISTERED) {
			if((4 <= strlen(sBuffer) <= MAX_STRING_PASSWORD_LIMIT)) {
				if(isAlphaNumeric(sBuffer)) {
					g_AccountStatus[id] = STATUS_CONFIRM;
					copy(g_AccountPassword[id], charsmax(g_AccountPassword[]), sBuffer);

					client_cmd(id, "messagemode INGRESAR_CLAVE");
					clientPrintColor(id, _, "Confirma tu contraseña ingresándola nuevamente.");
				} else {
					clientPrintColor(id, _, "La contraseña solo permite números y letras.");
					showMenu__LogIn(id);
				}
			} else {
				clientPrintColor(id, _, "La contraseña admite entre 4 a %d caracteres.", MAX_STRING_PASSWORD_LIMIT);
				showMenu__LogIn(id);
			}
		} else if(g_AccountStatus[id] == STATUS_CONFIRM) {
			if(!equal(sBuffer, g_AccountPassword[id])) {
				g_AccountStatus[id] = STATUS_UNREGISTERED;
				g_AccountPassword[id][0] = EOS;

				clientPrintColor(id, _, "Las contraseñas no han coincidido. Inténtalo nuevamente.");
				showMenu__LogIn(id);
			} else {
				g_AccountStatus[id] = STATUS_LOADING;
				hash_string(g_AccountPassword[id], Hash_Md5, g_AccountPassword[id], charsmax(g_AccountPassword[]));
				generateCode(id);

				clientPrintColor(id, _, "Codigo de recuperación generado (!g%s!y). Guárdalo en algun lado, te servira en el futuro.", g_AccountRecoveryCode[id]);

				new sNameSafe[MAX_NAME_LENGTH];
				new iArgs[2];

				SQL_QuoteString(Empty_Handle, sNameSafe, charsmax(sNameSafe), g_PlayerName[id]);
				formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM `%saccounts` WHERE (`name`=^"%s^");", __SERVERS[g_ServerId][serverSqlPrefixTable], sNameSafe);

				iArgs[0] = QUERY_CHECK_ACCOUNT;
				iArgs[1] = id;

				SQL_ThreadQuery(g_SqlTuple, "sqlThread__DataHandler", g_SqlQuery, iArgs, sizeof(iArgs));
			}
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__VEnterMail(const id) {
	if(g_AccountVinc[id]) {
		return PLUGIN_HANDLED;
	}

	new sMail[128];
	read_args(sMail, charsmax(sMail));
	remove_quotes(sMail);
	trim(sMail);

	copy(g_AccountVincMail[id], charsmax(g_AccountVincMail[]), sMail);

	client_cmd(id, "messagemode V_INGRESAR_CLAVE");
	clientPrintColor(id, _, "Ingresa tu contraseña con el que ingresas en el foro !t%s!y.", __PLUGIN_COMMUNITY_FORUM);

	return PLUGIN_HANDLED;
}

public clcmd__VEnterPassword(const id) {
	if(g_AccountVinc[id]) {
		return PLUGIN_HANDLED;
	}

	new sPassword[128];
	new sUrl[256];

	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	copy(g_AccountVincPassword[id], charsmax(g_AccountVincPassword[]), sPassword);
	formatex(sUrl, charsmax(sUrl), "https://www.DrunkGaming.net/vinc2.php?id=%d&email=%s&password=%s", id, g_AccountVincMail[id], g_AccountVincPassword[id]);

	grip_request(sUrl, Empty_GripBody, GripRequestTypeGet, "checkAccountVinc", Empty_GripRequestOptions, id);
	return PLUGIN_HANDLED;
}

public clcmd__Ban(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "El comando debe ser introducido de la siguiente manera: acc_unban <NOMBRE COMPLETO>");
		return PLUGIN_HANDLED;
	}

	new iArgs[2];

	iArgs[0] = QUERY_CHECK_BAN_IN_COMMAND;
	iArgs[1] = id;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT `id`, `name` FROM `%saccounts` WHERE (`name`=^"%s^");", sArg1);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__DataHandler", g_SqlQuery, iArgs, sizeof(iArgs));

	return PLUGIN_HANDLED;
}

public clcmd__Unban(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public showMenu__Banned(const id) {
	oldmenu_create("\y%s \r-\y %s \r(by %s)^n\d%s", "menu__Banned", __PLUGIN_COMMUNITY_NAME, __SERVERS[g_ServerId][serverName], __PLUGIN_AUTHOR, __PLUGIN_COMMUNITY_FORUM);

	oldmenu_additem(-1, -1, "\yTU CUENTA HA SIDO BANEADA\r:");
	oldmenu_additem(-1, -1, "\r - \wAdministrador\r:\y %s", g_AccountBanned_StaffName[id]);
	oldmenu_additem(-1, -1, "\r - \wFecha de Inicio\r:\y %s",  getUnixToTime(g_AccountBanned_Start[id]));
	oldmenu_additem(-1, -1, "\r - \wFecha de Finalización\r:\y %s", getUnixToTime(g_AccountBanned_Finish[id]));
	oldmenu_additem(-1, -1, "\r - \wRazón\r:\y %s^n", g_AccountBanned_Reason[id]);

	oldmenu_additem(0, 0, "\r0.\w Salir del servidor");
	oldmenu_display(id);
}

public menu__Banned(const id, const item) {
	if(!item) {
		rh_drop_client(id, fmt("Tu cuenta ha sido baneada. Para consultar sobre la misma, realiza la denuncia en el sitio web %s/denuncias-y-quejas.", __PLUGIN_COMMUNITY_FORUM));
	}
}

public showMenu__LogIn(const id) {
	if(g_AccountStatus[id] > STATUS_REGISTERED) {
		return;
	}

	oldmenu_create("\y%s \r-\y %s \r(by %s)^n\d%s", "menu__LogIn", __PLUGIN_COMMUNITY_NAME, __SERVERS[g_ServerId][serverName], __PLUGIN_AUTHOR, __PLUGIN_COMMUNITY_FORUM);

	oldmenu_additem(1, 1, "\r1. %s", ((g_AccountStatus[id] != STATUS_REGISTERED) ? "\wRegistrarse" : "\dRegistrarse \r(cuenta registrada)"));
	oldmenu_additem(2, 2, "\r2. %s^n", ((g_AccountStatus[id] != STATUS_REGISTERED) ? "\dIniciar sesión \r(no registrado)" : "\wIniciar sesión"));

	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		oldmenu_additem(-1, -1, "\wSerás expulsado en \y%d segundos\w si no te \yREGISTRAS\w o", IDLE_LOGIN);
		oldmenu_additem(-1, -1, "\yINICIAS SESIÓN\w en el servidor^n");
	}

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", __PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__LogIn(const id, const item) {
	switch(item) {
		case 1: {
			if(g_AccountStatus[id] == STATUS_UNREGISTERED || g_AccountStatus[id] == STATUS_CONFIRM) {
				g_AccountPassword[id][0] = EOS;

				client_cmd(id, "messagemode INGRESAR_CLAVE");
				clientPrintColor(id, _, "Ingresa la contraseña que va a proteger tu cuenta.");
			} else {
				clientPrintColor(id, _, "Esta cuenta ya está registrada en este servidor.");
				showMenu__LogIn(id);
			}
		} case 2: {
			if(g_AccountStatus[id] == STATUS_REGISTERED) {
				client_cmd(id, "messagemode INGRESAR_CLAVE");
				clientPrintColor(id, _, "Ingresa la contraseña que protege a tu cuenta.");
			} else {
				clientPrintColor(id, _, "Esta cuenta no está registrada en este servidor.");
				showMenu__LogIn(id);
			}
		}
	}
}

public showMenu__Join(const id) {
	if(g_AccountStatus[id] > STATUS_LOGGED) {
		return;
	}

	oldmenu_create("\y%s \r-\y %s \r(by %s)^n\d%s", "menu__Join", __PLUGIN_COMMUNITY_NAME, __SERVERS[g_ServerId][serverName], __PLUGIN_AUTHOR, __PLUGIN_COMMUNITY_FORUM);

	new sAccount[8];
	new sForum[8];

	addDot(g_AccountId[id], sAccount, charsmax(sAccount));
	addDot(g_AccountVinc[id], sForum, charsmax(sForum));

	oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccount);
	oldmenu_additem(-1, -1, "\wVINCULADO AL FORO\r:\y %s \d(#%s)", ((g_AccountVinc[id]) ? "Si" : "No"), sForum);
	oldmenu_additem(-1, -1, "\wVINCULADO A LA APP MOBILE\r:\y %s^n", ((g_AccountVincAppMobile[id]) ? "Si" : "No"));

	oldmenu_additem(1, 1, "\r1.\w Entrar a jugar");
	oldmenu_additem(2, 2, "\r2.\w Vincular cuenta^n");

	if((get_user_flags(id) & ADMIN_LEVEL_H)) {
		oldmenu_additem(5, 5, "\r5.\w Entrar como espectador^n");
	}

	if(!g_AccountVinc[id]) {
		oldmenu_additem(-1, -1, "\wTu cuenta actualmente \rNO ESTÁ VINCULADA\w");
		oldmenu_additem(-1, -1, "\wTe recomendamos hacerlo para en caso de pérdida de");
		oldmenu_additem(-1, -1, "\wtu nombre o contraseña, podrás \yRECUPERARLA\w^n");
	}

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", __PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__Join(const id, const item) {
	switch(item) {
		case 1: {
			new iReturn;

			ExecuteForward(g_fwdJoinPlayer, iReturn, id);
		} case 2: {
			showMenu__Vinc(id);
		} case 5: {
			if(getUserTeam(id) != TEAM_SPECTATOR) {
				rgSetUserTeam(id, TEAM_SPECTATOR, MODEL_AUTO);
			}
		}
	}
}

public showMenu__Vinc(const id) {
	oldmenu_create("\yVINCULAR CUENTA", "menu__Vinc");

	oldmenu_additem(-1, -1, "\wPara vincular tu cuenta del \y%s\w", __SERVERS[g_ServerId][serverName]);
	oldmenu_additem(-1, -1, "\wcon tu cuenta del foro, debes ingresar");
	oldmenu_additem(-1, -1, "\wtu \ye-mail\w y tu \ycontraseña\w con la que");
	oldmenu_additem(-1, -1, "\wentras en el foro \d(%s).^n", __PLUGIN_COMMUNITY_FORUM);

	oldmenu_additem(-1, -1, "\wVincula tu cuenta del servidor con tu");
	oldmenu_additem(-1, -1, "\wcuenta del foro, así podrías desbloquear");
	oldmenu_additem(-1, -1, "\yopciones adicionales\w, así como también");
	oldmenu_additem(-1, -1, "\wcambiar tus \yconfiguraciones\w y demas beneficios.^n");

	if(g_AccountVinc[id]) {
		oldmenu_additem(-1, -1, "\d1. Vincular ahora \r(CUENTA VINCULADA)");
	} else {
		oldmenu_additem(1, 1, "\r1.\w Vincular ahora");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Vinc(const id, const item) {
	if(!item) {
		if(g_AccountStatus[id] != STATUS_PLAYING) {
			showMenu__Join(id);
		}

		return;
	}

	switch(item) {
		case 1: {
			if(g_AccountVinc[id]) {
				clientPrintColor(id, _, "Tu cuenta ya ha sido vinculada. Visita nuestro foro para ver tus datos en el Panel de Vinculación !g%s!y.", __PLUGIN_COMMUNITY_FORUM);

				showMenu__Vinc(id);
				return;
			}

			clientPrintColor(id, _, "Ingresa tu E-Mail con el que te registraste en el foro !t%s!y.", __PLUGIN_COMMUNITY_FORUM);
			client_cmd(id, "messagemode V_INGRESAR_MAIL");
		}
	}
}

public loadStuff() {
	g_ServerId = dg_get_server_id();
	
	g_fwdRegisterPlayerData = CreateMultiForward("fw_create_player_data", ET_IGNORE, FP_CELL, FP_CELL);
	g_fwdLoadPlayerData = CreateMultiForward("fw_load_player_data", ET_IGNORE, FP_CELL, FP_CELL);
	g_fwdJoinPlayer = CreateMultiForward("fw_join_player", ET_IGNORE, FP_CELL);
	g_fwdVincPlayerSuccess = CreateMultiForward("fw_vinc_player_success", ET_IGNORE, FP_CELL);
	g_fwdSaveOtherData = CreateMultiForward("fw_save_other_data", ET_IGNORE, FP_CELL, FP_CELL);
}

public loadSql() {
	new sData[128];
	SQL_SetAffinity("mysql");
	SQL_GetAffinity(sData, charsmax(sData));

	if(!equal(sData, "mysql")) {
		set_fail_state("loadSql() - No se pudo establecer la afinidad del driver SQL a MySQL.");
		return;
	}

	new iErrorNum;
	new Handle:sqlConnection;

	g_SqlTuple = SQL_MakeDbTuple("127.0.0.1", __SERVERS[g_ServerId][serverSqlUsername], __SERVERS[g_ServerId][serverSqlPassword], __SERVERS[g_ServerId][serverSqlDatabase]);
	sqlConnection = SQL_Connect(g_SqlTuple, iErrorNum, sData, charsmax(sData));
	g_SqlQuery[0] = EOS;

	if(sqlConnection == Empty_Handle) {
		set_fail_state("loadSql() - Error en la conexión a la base de datos - [%d] %s.", iErrorNum, sData);
		return;
	}

	SQL_SetCharset(g_SqlTuple, "utf8mb4");

	loadGlobalRank(sqlConnection);

	SQL_FreeHandle(sqlConnection);
}

public loadGlobalRank(const Handle:connection) {
	new Handle:sqlQuery = SQL_PrepareQuery(connection, "SELECT COUNT(*) FROM `%saccounts`;", __SERVERS[g_ServerId][serverSqlPrefixTable]);

	if(SQL_Execute(sqlQuery)) {
		if(SQL_NumResults(sqlQuery)) {
			g_GlobalRank = SQL_ReadResult(sqlQuery, 0);
		} else {
			g_GlobalRank = 0;
		}
	}

	SQL_FreeHandle(sqlQuery);
}

public loadAccountData(const id) {
	if(g_AccountStatus[id] != STATUS_CHECK_ACCOUNT) {
		return;
	}

	new sNameSafe[MAX_NAME_LENGTH];
	new iArgs[2];

	SQL_QuoteString(Empty_Handle, sNameSafe, charsmax(sNameSafe), g_PlayerName[id]);
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT `id`, INET_NTOA(`last_ip`), `password`, `recovery_code`, `since_connection`, `last_connection`, `autologin`, `just_registered`, `vinc`, `vinc_app_mobile`, `login_daily`, `login_daily_consecutive`, `login_today` FROM `%saccounts` WHERE (`name`=^"%s^");", __SERVERS[g_ServerId][serverSqlPrefixTable], sNameSafe);

	iArgs[0] = QUERY_LOAD_ACCOUNT;
	iArgs[1] = id;

	SQL_ThreadQuery(g_SqlTuple, "sqlThread__DataHandler", g_SqlQuery, iArgs, sizeof(iArgs));
}

public saveAccountData(const id) {
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `%saccounts` SET `last_ip`=INET_ATON(^"%s^"), `last_steam`=^"%s^", `last_connection`='%d' WHERE (`id`='%d');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_PlayerIp[id], g_PlayerSteamId[id], get_arg_systime(), g_AccountId[id]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
}

public loadPlayerData(const id) {
	remove_task(id + TASK_CHECK_AFK);

	new iReturn;

	ExecuteForward(g_fwdLoadPlayerData, iReturn, id, g_AccountId[id]);
}

public generateCode(const id) {
	g_AccountRecoveryCode[id][0] = EOS;

	new i;
	new iMaxRest = (MAX_STRING_CODE - 1);
	
	for(i = 0; i < MAX_STRING_CODE; ++i) {
		if(random_num(0, 1)) {
			g_AccountRecoveryCode[id][i] = random_num(48, 57);
		} else {
			g_AccountRecoveryCode[id][i] = random_num(65, 90);
		}
	}

	g_AccountRecoveryCode[id][iMaxRest] = EOS;
}

public checkConnectedAnotherAccount(const id) {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(id != i && is_user_connected(i)) {
			if(g_AccountId[id] == g_AccountId[i]) {
				return 1;
			}
		}
	}

	return 0;
}

public checkAccountVinc(const id) {
	new GripResponseState:gState = grip_get_response_state();

	if(gState == GripResponseStateError) {
		g_AccountVinc[id] = 0;
		g_AccountVincMail[id][0] = EOS;
		g_AccountVincPassword[id][0] = EOS;

		clientPrintColor(id, _, "Tus datos han sido rechazados [0x0]. Verifica tus datos si son correctos y vuelve a intentarlo más tarde.");

		showMenu__Vinc(id);
		return;
	}

	new sResponse[512];
	new GripJSONValue:gData;

	grip_get_response_body_string(sResponse, charsmax(sResponse));
	gData = grip_json_parse_response_body(sResponse, charsmax(sResponse));

	if(gData == Invalid_GripJSONValue) {
		g_AccountVinc[id] = 0;
		g_AccountVincMail[id][0] = EOS;
		g_AccountVincPassword[id][0] = EOS;

		clientPrintColor(id, _, "Tus datos han sido rechazados [0x1]. Verifica tus datos si son correctos y vuelve a intentarlo más tarde.");

		showMenu__Vinc(id);
		return;
	}

	grip_json_get_string(grip_json_object_get_value(gData, "member_id"), sResponse, charsmax(sResponse));
	grip_destroy_json_value(gData);

	g_AccountVinc[id] = str_to_num(sResponse);

	clientPrintColor(id, _, "Tus datos han sido aceptados y tu cuenta ha sido vinculada correctamente.");

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `%saccounts` SET `vinc`='%d' WHERE (`id`='%d');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountVinc[id], g_AccountId[id]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	new iReturn;

	ExecuteForward(g_fwdVincPlayerSuccess, iReturn, id);

	showMenu__Vinc(id);
}

public task__CheckAfk(const task_id) {
	new iId = (task_id - TASK_CHECK_AFK);

	if(!is_user_connected(iId)) {
		return;
	}

	if((get_user_flags(iId) & ADMIN_LEVEL_H)) {
		return;
	}

	rh_drop_client(iId, fmt("Fuiste expulsado por no ingresar al servidor en mas de %d segundos.", IDLE_LOGIN));
}

public task__MessageVip(const task_id) {
	new iId = (task_id - TASK_MESSAGE_VIP);

	if(!is_user_connected(iId)) {
		return;
	}

	if((get_user_flags(iId) & ADMIN_RESERVATION)) {
		return;
	}

	clientPrintColor(iId, _, "Duplica tus ganancias en el !g%s!y siendo VIP. Visita !g%s!y para más información de los beneficios.", __SERVERS[g_ServerId][serverName], __PLUGIN_COMMUNITY_FORUM_SHOP);

	set_task(210.0, "task__MessageVip", iId + TASK_MESSAGE_VIP);
}

public task__MessageVinc(const task_id) {
	new iId = (task_id - TASK_MESSAGE_VINC);

	if(!is_user_connected(iId)) {
		return;
	}

	if(g_AccountVinc[iId]) {
		return;
	}

	clientPrintColor(iId, _, "Tu cuenta no está vinculada a !g%s!y, recordá vincularla lo más pronto posible en el menú de !gOPCIONES DE USUARIO!y.", __PLUGIN_COMMUNITY_NAME);
	clientPrintColor(iId, _, "Vincular tu cuenta ofrece varias opciones/funciones, alguna de ellas muy importantes, además de un logro.");

	set_task(300.0, "task__MessageVinc", iId + TASK_MESSAGE_VINC);
}

public sqlThread__DataHandler(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[1];

	if(!is_user_connected(iId)) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_LOG_FILE, "sqlThread__DataHandler() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al realizar una consulta. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	switch(data[0]) {
		case QUERY_CHECK_ACCOUNT: {
			if(SQL_NumResults(query)) {
				clientPrintColor(iId, _, "Esta cuenta ya está registrada en este servidor.");
				showMenu__LogIn(iId);
			} else {
				if(getUserIsSteamId(g_PlayerSteamId[iId])) {
					copy(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), g_PlayerSteamId[iId]);
				} else {
					formatex(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), "STEAM_ID_LAN");
				}

				new iArgs[2];

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `%saccounts` (`name`, `since_ip`, `since_steam`, `password`, `recovery_code`, `since_connection`, `last_connection`) VALUES (^"%s^", INET_ATON(^"%s^"), ^"%s^", ^"%s^", ^"%s^", '%d', '%d');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_PlayerName[iId], g_PlayerIp[iId], g_PlayerSteamIdCache[iId], g_AccountPassword[iId], g_AccountRecoveryCode[iId], get_arg_systime(), get_arg_systime());

				iArgs[0] = QUERY_CREATE_ACCOUNT;
				iArgs[1] = iId;

				SQL_ThreadQuery(g_SqlTuple, "sqlThread__DataHandler", g_SqlQuery, iArgs, sizeof(iArgs));
			}
		} case QUERY_CREATE_ACCOUNT: {
			g_AccountId[iId] = SQL_GetInsertId(query);

			new iReturn;
			new sAccount[8];
			new iArgs[2];

			ExecuteForward(g_fwdRegisterPlayerData, iReturn, iId, g_AccountId[iId]);

			addDot(++g_GlobalRank, sAccount, charsmax(sAccount));
			clientPrintColor(0, iId, "Bienvenido !t%s!y, eres la cuenta registrada !g#%s!y.", g_PlayerName[iId], sAccount);

			if(getUserIsSteamId(g_PlayerSteamId[iId])) {
				copy(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), g_PlayerSteamId[iId]);
			} else {
				formatex(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), "STEAM_ID_LAN");
			}

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT `staff_name`, `start`, `finish`, `reason` FROM `%sbans` WHERE ((`ip`=INET_ATON(^"%s^") OR (`steam`=^"%s^" AND `steam`<>'STEAM_ID_LAN')) AND `active`='1');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_PlayerIp[iId], g_PlayerSteamIdCache[iId]);

			iArgs[0] = QUERY_CHECK_ANOTHER_BAN;
			iArgs[1] = iId;

			SQL_ThreadQuery(g_SqlTuple, "sqlThread__DataHandler", g_SqlQuery, iArgs, sizeof(iArgs));
		} case QUERY_CHECK_ANOTHER_BAN: {
			if(SQL_NumResults(query)) {
				SQL_ReadResult(query, 0, g_AccountBanned_StaffName[iId], charsmax(g_AccountBanned_StaffName[]));
				g_AccountBanned_Start[iId] = SQL_ReadResult(query, 1);
				g_AccountBanned_Finish[iId] = SQL_ReadResult(query, 2);
				SQL_ReadResult(query, 3, g_AccountBanned_Reason[iId], charsmax(g_AccountBanned_Reason[]));

				g_AccountStatus[iId] = STATUS_BANNED;

				clientPrintColor(0, iId, "!t%s!y ha sido baneado porque se ha encontrado coincidencias con otro usuario baneado por cuenta.", g_PlayerName[iId]);

				showMenu__Banned(iId);

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `%sbans` (`acc_id`, `ip`, `steam`, `staff_name`, `start`, `finish`, `reason`) VALUES ('%d', INET_ATON(^"%s^"), ^"%s^", ^"%s^", '%d', '%d', ^"%s^");", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountId[iId], g_PlayerIp[iId], g_PlayerSteamIdCache[iId], g_AccountBanned_StaffName[iId], g_AccountBanned_Start[iId], g_AccountBanned_Finish[iId], g_AccountBanned_Reason[iId]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
			} else {
				g_AccountStatus[iId] = STATUS_REGISTERED;

				playSound(iId, __SOUND_REGISTER);

				clientPrintColor(iId, _, "Por motivos de seguridad, inicia sesión con tu cuenta recién creada.");

				showMenu__LogIn(iId);
			}
		} case QUERY_LOAD_ACCOUNT: {
			if(SQL_NumResults(query)) {
				g_AccountStatus[iId] = STATUS_REGISTERED;
				
				g_AccountId[iId] = SQL_ReadResult(query, 0);
				SQL_ReadResult(query, 1, g_AccountLastIp[iId], charsmax(g_AccountLastIp[]));
				SQL_ReadResult(query, 2, g_AccountPassword[iId], charsmax(g_AccountPassword[]));

				if(SQL_IsNull(query, 3)) {
					generateCode(iId);

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `%saccounts` SET `recovery_code`=^"%s^" WHERE (`id`='%d');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountRecoveryCode[iId], g_AccountId[iId]);
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
				} else {
					SQL_ReadResult(query, 3, g_AccountRecoveryCode[iId], charsmax(g_AccountRecoveryCode[]));
				}

				g_AccountSinceConnection[iId] = SQL_ReadResult(query, 4);
				g_AccountLastConnection[iId] = SQL_ReadResult(query, 5);
				g_AccountAutologin[iId] = SQL_ReadResult(query, 6);
				g_AccountJustRegistered[iId] = SQL_ReadResult(query, 7);

				if(g_AccountJustRegistered[iId] && (get_arg_systime() - g_AccountSinceConnection[iId]) > MAX_JUST_REGISTERED) {
					g_AccountJustRegistered[iId] = 0;

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `%saccounts` SET `just_registered`='0' WHERE (`id`='%d');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountId[iId]);
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
				}

				g_AccountVinc[iId] = SQL_ReadResult(query, 8);

				if(!g_AccountVinc[iId]) {
					set_task(180.0, "task__MessageVinc", iId + TASK_MESSAGE_VINC);
				}

				g_AccountVincAppMobile[iId] = SQL_ReadResult(query, 9);
				g_AccountLoginDaily[iId] = SQL_ReadResult(query, 10);
				g_AccountLoginDailyConsecutive[iId] = SQL_ReadResult(query, 11);
				g_AccountLoginToday[iId] = SQL_ReadResult(query, 12);

				if(!(get_user_flags(iId) & ADMIN_RESERVATION)) {
					set_task(160.0, "task__MessageVip", iId + TASK_MESSAGE_VIP);
				}

				if(checkConnectedAnotherAccount(iId)) {
					rh_drop_client(iId, "La cuenta está en uso, ingresa más tarde.");
				} else {
					new iArgs[2];

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT `staff_name`, `start`, `finish`, `reason` FROM `%sbans` WHERE (acc_id='%d' AND `active`='1');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountId[iId]);

					iArgs[0] = QUERY_CHECK_BAN;
					iArgs[1] = iId;

					SQL_ThreadQuery(g_SqlTuple, "sqlThread__DataHandler", g_SqlQuery, iArgs, sizeof(iArgs));
				}
			} else {
				g_AccountStatus[iId] = STATUS_UNREGISTERED;
			}
		} case QUERY_CHECK_BAN: {
			if(SQL_NumResults(query)) {
				SQL_ReadResult(query, 0, g_AccountBanned_StaffName[iId], charsmax(g_AccountBanned_StaffName[]));
				g_AccountBanned_Start[iId] = SQL_ReadResult(query, 1);
				g_AccountBanned_Finish[iId] = SQL_ReadResult(query, 2);
				SQL_ReadResult(query, 3, g_AccountBanned_Reason[iId], charsmax(g_AccountBanned_Reason[]));

				if(get_arg_systime() < g_AccountBanned_Finish[iId]) {
					g_AccountStatus[iId] = STATUS_BANNED;
				} else {
					clientPrintColor(0, iId, "!t%s!y estaba baneado por cuenta y ahora podrá volver a jugar.", g_PlayerName[iId]);
		
					formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `%sbans` SET `active`='0' WHERE (`acc_id`='%d' AND `active`='1');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountId[iId]);
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

					if(equali(g_AccountLastIp[iId], g_PlayerIp[iId]) && g_AccountAutologin[iId] && g_AccountVinc[iId]) {
						g_AccountStatus[iId] = STATUS_LOADING;

						loadPlayerData(iId);
					}
				}
			} else {
				if(equali(g_AccountLastIp[iId], g_PlayerIp[iId]) && g_AccountAutologin[iId] && g_AccountVinc[iId]) {
					g_AccountStatus[iId] = STATUS_LOADING;

					loadPlayerData(iId);
				}
			}

			if(g_AccountStatus[iId] != STATUS_BANNED) {
				new iArgs[2];

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT COUNT(*) FROM `%sbans` WHERE (`acc_id`='%d');", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountId[iId]);

				iArgs[0] = QUERY_CHECK_AMOUNT_BANS;
				iArgs[1] = iId;

				SQL_ThreadQuery(g_SqlTuple, "sqlThread__DataHandler", g_SqlQuery, iArgs, sizeof(iArgs));
			}
		} case QUERY_CHECK_AMOUNT_BANS: {
			if(SQL_NumResults(query)) {
				g_AccountBanned_Count[iId] = SQL_ReadResult(query, 0);

				if(g_AccountBanned_Count[iId] >= MAX_BAN_ACCOUNT) {
					g_AccountStatus[iId] = STATUS_BANNED;

					formatex(g_AccountBanned_StaffName[iId], charsmax(g_AccountBanned_StaffName[]), __PLUGIN_COMMUNITY_NAME);
					g_AccountBanned_Start[iId] = get_arg_systime();
					g_AccountBanned_Finish[iId] = 2000000000;
					formatex(g_AccountBanned_Reason[iId], charsmax(g_AccountBanned_Reason[]), "Reiterados baneos de cuenta");

					clientPrintColor(0, iId, "!t%s!y ha sido baneado permanentemente porque se han encontrado más de !g%d baneos!y en su cuenta.", g_PlayerName[iId], MAX_BAN_ACCOUNT);

					if(getUserIsSteamId(g_PlayerSteamId[iId])) {
						copy(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), g_PlayerSteamId[iId]);
					} else {
						formatex(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), "STEAM_ID_LAN");
					}

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `%sbans` (`acc_id`, `ip`, `steam`, `staff_name`, `start`, `finish`, `reason`) VALUES ('%d', INET_ATON(^"%s^"), ^"%s^", ^"%s^", '%d', '%d', ^"%s^");", __SERVERS[g_ServerId][serverSqlPrefixTable], g_AccountId[iId], g_PlayerIp[iId], g_PlayerSteamIdCache[iId], g_AccountBanned_StaffName[iId], g_AccountBanned_Start[iId], g_AccountBanned_Finish[iId], g_AccountBanned_Reason[iId]);
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
				}
			} else {
				g_AccountBanned_Count[iId] = 0;
			}
		} case QUERY_CHECK_BAN_IN_COMMAND: {
			
		}
	}
}

public sqlThread__IgnoreQuery(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_LOG_FILE, "sqlThread__IgnoreQuery() - [%d] - <%s>", error_num, error);
	}
}

public native__GetUserAccStatus(const plugin, const params) {
	new iId = get_param(1);
	
	if(!is_user_connected(iId)) {
		return 0;
	}

	return g_AccountStatus[iId];
}

public native__SetUserAccStatus(const id, const status) {
	g_AccountStatus[id] = status;
}

public native__GetUserAccId(const plugin, const params) {
	new iId = get_param(1);

	if(!is_user_connected(iId)) {
		return 0;
	}

	return g_AccountId[iId];
}

public native__GetUserAccLD(const plugin, const params) {
	new iId = get_param(1);

	if(!is_user_connected(iId)) {
		return 0;
	}

	return g_AccountLoginDaily[iId];
}

public native__GetUserAccLDC(const plugin, const params) {
	new iId = get_param(1);

	if(!is_user_connected(iId)) {
		return 0;
	}

	return g_AccountLoginDailyConsecutive[iId];
}

public native__GetUserAccVinc(const plugin, const params) {
	new iId = get_param(1);

	if(!is_user_connected(iId)) {
		return 0;
	}

	return g_AccountVinc[iId];
}

public native__GetUserAccVincAM(const plugin, const params) {
	new iId = get_param(1);

	if(!is_user_connected(iId)) {
		return 0;
	}

	return g_AccountVincAppMobile[iId];
}

public native__GetGlobalRank() {
	return g_GlobalRank;
}

public native__GetUserMenuBanned(const plugin, const params) {
	if(params != 1) {
		return;
	}

	new iId = get_param(1);
	
	if(!is_user_connected(iId)) {
		return;
	}

	showMenu__Banned(iId);
}

public native__GetUserMenuLogin(const plugin, const params) {
	if(params != 1) {
		return;
	}

	new iId = get_param(1);
	
	if(!is_user_connected(iId)) {
		return;
	}

	showMenu__LogIn(iId);
}

public native__GetUserMenuJoin(const plugin, const params) {
	if(params != 1) {
		return;
	}

	new iId = get_param(1);
	
	if(!is_user_connected(iId)) {
		return;
	}

	showMenu__Join(iId);
}

public native__GetUserMenuVinc(const plugin, const params) {
	if(params != 1) {
		return;
	}

	new iId = get_param(1);

	if(!is_user_connected(iId)) {
		return;
	}

	showMenu__Vinc(iId);
}