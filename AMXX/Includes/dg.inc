#if defined _dg_included
	#endinput
#endif
#define _dg_included

#include <amxmodx>
#include <amxmisc>
#include <reapi>

#if !defined _safemenu_included
	#include <safemenu>
#endif

#if !defined _oldmenu_included
	#include <oldmenu>
#endif

#if !defined _unixtime_included
	#include <unixtime>
#endif

/*
	Reservation 	= VIP 				- b
	Immunity 		= Admin 			- abcdeijuvy
	Level D 		= Capitán 			- abcdefghijkpuvy
	Level E 		= Manager 			- abcdefghijkpquvy
	Level F 		= Desarrollador 	- abcdefghijkpqruvy
	Level G 		= Mod 				- abcdefghijkpqrsuvy
	Level H 		= Super mod 		- abcdefghijkpqrstuvy
	Rcon 			= Director 			- abcdefghijklpqrstuvy
*/

const MAX_INT = 2147483647;
const MAX_CHARACTER_MD5 = 33;
const MAX_CHARACTER_MAPNAME = 32;
const MAX_CHARACTER_SAY = 191;

const DEFAULT_PORT = 27050;

stock const __PLUGIN_COMMUNITY_PREFIX[] = "DG";
stock const __PLUGIN_COMMUNITY_NAME[] = "Drunk-Gaming";
stock const __PLUGIN_COMMUNITY_FORUM[] = "www.DrunkGaming.net";
stock const __PLUGIN_COMMUNITY_FORUM_SHOP[] = "www.DrunkGaming.net/ventas";
stock const __PLUGIN_COMMUNITY_FORUM_VIP[] = "www.DrunkGaming.net/foro/6-zona-vip";
stock const __PLUGIN_COMMUNITY_FORUM_ADMIN[] = "www.DrunkGaming.net/foro/7-zona-admin";

stock const __REGEX_IP_PATTERN[] = "(?:[0-9]{1,3}[-.x:_ ]?[-.x:_ ][-.x:_ ]?){3}[0-9]{1,3}";
stock const __REGEX_STEAMID_PATTERN[] = "^^STEAM_0:(0|1):\d+$";
stock const __AS2_INFO[] = "^xFF^xFF^xFF^xFFTSource Engine Query^x00";

#include <dg_servers>
#include <dg_stocks>

native dg_get_user_adminid(const id);
native dg_get_user_forumid(const id);
native dg_get_user_mute(const id, const user);

native dg_get_server_id();