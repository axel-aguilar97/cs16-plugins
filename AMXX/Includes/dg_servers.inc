#if defined _dg_servers_included
	#endinput
#endif
#define _dg_servers_included

#if !defined _dg_included
	#include <dg>
#endif

enum _:structIdServers {
	SV_NONE = 0,
	SV_ZE, // Zombie Escape
	SV_ZR, // Zombie Rise
	SV_OD2I, // Only Dust2 & Inferno
	SV_DR, // Deathrun
	SV_JBE, // Jailbreak Empire
	SV_CSGO_ARENA, // CS:GO Arena 1v1
	SV_TTT, // Atrapa al Traidor (TTT)
	SV_ZP, // Zombie Plague
	SV_SURF, // Surf + Kills
	SV_CSGO_PUB, // CS:GO Público
	SV_CLASSIC_PUB, // Classic Público
	SV_MF, // Mapas Frutas
	SV_KZ, // KZ + Bhop
	SV_AMIX1, // Pug - Automix 5v5
	SV_AMIX2, // Pug - Scrim 5v5
	SV_GG, // Gungame
	SV_DM, // Deathmatch + FFA
	SV_TD // Tower Defense
};

enum _:structServers {
	serverName[48],
	serverAutokickTimeout,
	serverIp[16],
	serverPort[8],
	serverSqlUsername[32],
	serverSqlPassword[64],
	serverSqlDatabase[24],
	serverSqlPrefixTable[8]
};

stock const __SERVERS[structIdServers][structServers] = {
	{"", 						0, 	"103.195.103.241", "", 			"", "", "", ""},
	{"Zombie Escape", 			45, "103.195.103.241", "27050", 	"", "", "", ""},
	{"Zombie Rise", 			45, "103.195.103.241", "27051", 	"", "", "", ""},
	{"Only Dust2 & Inferno", 	45, "103.195.103.241", "27052", 	"", "", "", ""},
	{"Deathrun", 				45,	"103.195.103.241", "27053", 	"", "", "", ""},
	{"Jailbreak Empire", 		45,	"103.195.103.241", "27054", 	"", "", "", ""},
	{"CS:GO Arena 1v1", 		60,	"103.195.103.241", "27055", 	"", "", "", ""},
	{"Atrapa al Traidor [TTT]", 60,	"103.195.103.241", "27056", 	"", "", "", ""},
	{"Zombie Plague", 			45,	"103.195.103.241", "27057", 	"", "", "", "zp9_"},
	{"Surf + Kills", 			60,	"103.195.103.241", "27058", 	"", "", "", ""},
	{"CS:GO Público", 			60,	"103.195.103.241", "27059", 	"", "", "", ""},
	{"Classic Público", 		45,	"103.195.103.241", "27060", 	"", "", "", ""},
	{"Mapas Frutas", 			60,	"103.195.103.241", "27061", 	"", "", "", ""},
	{"KZ + Bhop", 				60,	"103.195.103.241", "27062", 	"", "", "", ""},
	{"Pug - Automix 5v5", 		60,	"103.195.103.241", "27063", 	"", "", "", ""},
	{"Pug - Scrim 5v5", 		60,	"103.195.103.241", "27064", 	"", "", "", ""},
	{"Gungame", 				60,	"103.195.103.241", "27065", 	"", "", "", ""},
	{"Deathmatch + FFA", 		45,	"103.195.103.241", "27066", 	"", "", "", ""},
	{"Tower Defense", 			0,	"103.195.103.241", "27067", 	"", "", "", "td4_"}
};