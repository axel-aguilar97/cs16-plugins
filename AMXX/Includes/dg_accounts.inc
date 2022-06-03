#if defined _dg_accounts_included
	#endinput
#endif
#define _dg_accounts_included

#if !defined _sqlx_included
	#include <sqlx>
#endif

#if !defined _grip_included
	#include <grip>
#endif

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

stock const __SQL_LOG_FILE[] = "mysql.log";

native dg_get_user_acc_status(const id);
native dg_set_user_acc_status(const id, const status);
native dg_get_user_acc_id(const id);
native dg_get_user_acc_ld(const id); // Login Daily
native dg_get_user_acc_ldc(const id); // Login Daily Consecutive
native dg_get_user_acc_vinc(const id); // Vinc Forum
native dg_get_user_acc_vinc_am(const id); // Vinc App Mobile

native dg_get_global_rank();

native dg_get_user_menu_banned(const id);
native dg_get_user_menu_login(const id);
native dg_get_user_menu_join(const id);
native dg_get_user_menu_vinc(const id);

forward fw_create_player_data(const id, const acc_id);
forward fw_load_player_data(const id, const acc_id);
forward fw_join_player(const id);
forward fw_vinc_player_success(const id);
forward fw_save_other_data(const id, const acc_id);

stock executeQuery(const id, const Handle:query, const query_id) {
	new sErrors[256];
	SQL_QueryError(query, sErrors, charsmax(sErrors));
	log_to_file(__SQL_LOG_FILE, "#%d - executeQuery() - [%d] - <%s>", id, query_id, sErrors);

	if(is_user_connected(id)) {
		rh_drop_client(id, "Hubo un error al realizar una consulta y por seguridad has sido expulsado.");
	}

	SQL_FreeHandle(query);
}