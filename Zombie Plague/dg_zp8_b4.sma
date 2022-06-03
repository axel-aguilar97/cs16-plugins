#include <dg>
#include <dg_accounts>

#include <hamsandwich>
#include <sqlx>

#pragma semicolon 1;

/*
	TODO:
	Tabla "zp8_accounts":
		Convertir columna "since_ip" y "last_ip" en tipo INT
		Convertir los valores de los registros de "since_ip" y "last_ip" en IP de tipo INT
		daily_visit > login_daily
		daily_visit_consecutive > login_daily_consecutive
		connected_today > login_today
	Tabla "zp8_bans"
		Convertir columna "ip" en tipo INT
		Convertir los valores de los registros de "ip" en IP de tipo INT
	Tabla "zp8_general"
		Reestablecer la columna "modes"
		Eliminar las columnas "round_*" menos "round_gg_last_winner"
*/

new const __PLUGIN_NAME[] = "Zombie Plague Annihilation";
new const __PLUGIN_NAME_SHORT[] = "ZPA";
new const __PLUGIN_VERSION[] = "v8.4 BETA";
new const __PLUGIN_AUTHOR[] = "Atsel.";

const Float:DIV_DAMAGE = 100.0;

const HEGRENADE_PER_RESET = 10; // Cada 'x' reset, te dan +1 HE
const MAX_HEGRENADE_AMOUNT = 3; // Máximo de HE en mano
const HEGRENADE_CHANGE_RESET = 20; // Reset que cambia de Fuego a Droga
const FLASHBANG_PER_RESET = 25; // Cada 'x' reset, te dan +1 FB
const MAX_FLASHBANG_AMOUNT = 2; // Máximo de FB en mano
const FLASHBANG_CHANGE_RESET = 40; // Reset que cambia de Hielo a Supernova
const SMOKEGRENADE_PER_RESET = 50; // Cada 'x' reset, te dan +1 SG
const MAX_SMOKEGRENADE_AMOUNT = 2; // Máximo de SG en mano
const SMOKEGRENADE_CHANGE_RESET = 60; // Reset que cambia de Luz a Bubble

enum _:structIdTasks (+= 236877) {
	TASK_SPAWN = 54276,

	TASK_VIRUST,
	TASK_START_MODE
};

enum _:structIdModes {
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE,
	MODE_SYNAPSIS,
	MODE_MEGA_SYNAPSIS,
	MODE_ARMAGEDDON,
	MODE_MEGA_ARMAGEDDON,
	MODE_GUNGAME,
	MODE_MEGA_GUNGAME,
	MODE_DRUNK,
	MODE_DUEL_FINAL,
	MODE_SURVIVOR,
	MODE_WESKER,
	MODE_TRIBAL,
	MODE_SNIPER,
	MODE_NEMESIS,
	MODE_ANNIHILATOR,
	MODE_FLESHPOUND,
	MODE_GRUNT
};

enum _:structIdWeaponsData {
	WEAPON_DATA_KILL_DONE,
	Float:WEAPON_DATA_DAMAGE_DONE,
	WEAPON_DATA_LEVEL,
	WEAPON_DATA_POINTS
};

enum _:structIdWeaponsSkills {
	WEAPON_SKILL_DAMAGE = 0,
	WEAPON_SKILL_SPEED,
	WEAPON_SKILL_RECOIL,
	WEAPON_SKILL_BULLETS
};

enum _:structModes {
	modeName[32],
	modeChance,
	modeUsersNeed,
	modeSpecial // 0 = Modo normal | 1 = Modo especial | 2 = Modo especial único
};

enum _:structWeapons {
	WeaponIdType:weaponId,
	weaponIsPrimary,
	weaponEnt[24],
	weaponName[32],
	Float:weaponDamageBase
};

enum _:structWeaponsModels {
	weaponModelLevel,
	weaponModelPath[128]
};

new const __MODES[structIdModes][structModes] = {
	{"", 0, 0, 0},
	{"PRIMER ZOMBIE", 0, 0, 0},
	{"SWARM", 30, 2, 1},
	{"INFECCIÓN MÚLTIPLE", 15, 16, 1},
	{"PLAGUE", 25, 12, 1},
	{"SYNAPSIS", 75, 12, 1},
	{"MEGA SYNAPSIS", 0, 0, 2}, // COMPLETAR
	{"ARMAGEDDON", 75, 16, 1},
	{"MEGA ARMAGEDDON", 0, 0, 2},
	{"GUNGAME", 0, 0, 2},
	{"MEGA GUNGAME", 0, 0, 2},
	{"DRUNK", 75, 16, 1},
	{"DUELO FINAL", 75, 10, 1},
	{"SURVIVOR", 20, 8, 1},
	{"WESKER", 40, 12, 1},
	{"TRIBAL", 40, 12, 1},
	{"SNIPER", 40, 12, 1},
	{"NEMESIS", 20, 8, 1},
	{"ANIQUILADOR", 40, 12, 1},
	{"FLESHPOUND", 40, 12, 1},
	{"GRUNT", 40, 12, 1}
};

new const __WEAPONS[][structWeapons] = {
	{WEAPON_NONE, -1, "", "", -1.0},
	{WEAPON_P228, 0, "weapon_p228", "P228 Compact", 16.0},
	{WEAPON_GLOCK, -1, "", "", -1.0},
	{WEAPON_SCOUT, -1, "", "", -1.0},
	{WEAPON_HEGRENADE, -1, "", "", -1.0},
	{WEAPON_XM1014, 1, "weapon_xm1014", "XM1014 M4", 64.0},
	{WEAPON_C4, -1, "", "", -1.0},
	{WEAPON_MAC10, 1, "weapon_mac10", "Ingram MAC-10", 32.0},
	{WEAPON_AUG, 1, "weapon_aug", "Steyr AUG A1", 48.0},
	{WEAPON_SMOKEGRENADE, -1, "", "", -1.0},
	{WEAPON_ELITE, 0, "weapon_elite", "Dual Elite Berettas", 16.0},
	{WEAPON_FIVESEVEN, 0, "weapon_fiveseven", "FiveseveN", 16.0},
	{WEAPON_UMP45, 1, "weapon_ump45", "UMP 45", 32.0},
	{WEAPON_SG550, -1, "", "", -1.0},
	{WEAPON_GALIL, 1, "weapon_galil", "IMI Galil", 48.0},
	{WEAPON_FAMAS, 1, "weapon_famas", "Famas", 48.0},
	{WEAPON_USP, 0, "weapon_usp", "USP .45 ACP Tactical", 16.0},
	{WEAPON_GLOCK18, 0, "weapon_glock18", "Glock 18C", 16.0},
	{WEAPON_AWP, -1, "", "", -1.0},
	{WEAPON_MP5N, 1, "weapon_mp5navy", "MP5 Navy", 32.0},
	{WEAPON_M249, 1, "weapon_m249", "M249 Para Machinegun", 64.0},
	{WEAPON_M3, 1, "weapon_m3", "M3 Super 90", 64.0},
	{WEAPON_M4A1, 1, "weapon_m4a1", "M4A1 Carbine", 48.0},
	{WEAPON_TMP, 1, "weapon_tmp", "Schmidt TMP", 32.0},
	{WEAPON_G3SG1, -1, "", "", -1.0},
	{WEAPON_FLASHBANG, -1, "", "", -1.0},
	{WEAPON_DEAGLE, 0, "weapon_deagle", "Desert Eagle .50 AE", 16.0},
	{WEAPON_SG552, 1, "weapon_sg552", "SG-552 Commando", 48.0},
	{WEAPON_AK47, 1, "weapon_ak47", "AK-47 Kalashnikov", 48.0},
	{WEAPON_KNIFE, -1, "weapon_knife", "Cuchillo", 50.0},
	{WEAPON_P90, 1, "weapon_p90", "ES P90", 16.0}
};

new const __WEAPON_MODELS[][][structWeaponsModels] = {
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}},
	{{5, "models/dg/zp7/v_p228_02.mdl"}, {10, "models/dg/zp7/v_p228_00.mdl"}, {15, "models/dg/zp7/v_p228_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // P228
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SHIELD
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SCOUT
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // HEGRENADE
	{{4, "models/dg/zp7/v_xm1014_02.mdl"}, {8, "models/dg/zp7/v_xm1014_01.mdl"}, {12, "models/dg/zp7/v_xm1014_03.mdl"}, {16, "models/dg/zp7/v_xm1014_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // XM1014
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // C4
	{{5, "models/dg/zp7/v_mac10_00.mdl"}, {10, "models/dg/zp7/v_mac10_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // MAC10
	{{2, "models/dg/zp7/v_aug_04.mdl"}, {4, "models/dg/zp7/v_aug_01.mdl"}, {6, "models/dg/zp7/v_aug_03.mdl"}, {8, "models/dg/zp7/v_aug_02.mdl"}, {12, "models/dg/zp7/v_aug_05.mdl"}, {14, "models/dg/zp7/v_aug_00.mdl"}, {99, ""}, {99, ""}, {99, ""}}, // AUG
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SMOKEGRENADE
	{{4, "models/dg/zp7/v_elite_01.mdl"}, {8, "models/dg/zp7/v_elite_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // ELITE
	{{4, "models/dg/zp7/v_fiveseven_02.mdl"}, {8, "models/dg/zp7/v_fiveseven_01.mdl"}, {12, "models/dg/zp7/v_fiveseven_03.mdl"}, {16, "models/dg/zp7/v_fiveseven_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // FIVESEVEN
	{{5, "models/dg/zp7/v_ump45_01.mdl"}, {10, "models/dg/zp7/v_ump45_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // UMP45
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, //  SG550
	{{4, "models/dg/zp7/v_galil_00.mdl"}, {6, "models/dg/zp7/v_galil_02.mdl"}, {12, "models/dg/zp7/v_galil_03.mdl"}, {16, "models/dg/zp7/v_galil_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // GALIL
	{{4, "models/dg/zp7/v_famas_02.mdl"}, {6, "models/dg/zp7/v_famas_01.mdl"}, {12, "models/dg/zp7/v_famas_00.mdl"}, {16, "models/dg/zp7/v_famas_03.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // FAMAS
	{{5, "models/dg/zp7/v_usp_01.mdl"}, {10, "models/dg/zp7/v_usp_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // USP
	{{4, "models/dg/zp7/v_glock18_00.mdl"}, {8, "models/dg/zp7/v_glock18_03.mdl"}, {12, "models/dg/zp7/v_glock18_01.mdl"}, {16, "models/dg/zp7/v_glock18_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // GLOCK18
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}},  // AWP
	{{5, "models/dg/zp7/v_mp5_01.mdl"}, {5, "models/dg/zp7/v_mp5_00.mdl"}, {10, "models/dg/zp7/v_mp5_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // MP5NAVY
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // M249
	{{5, "models/dg/zp7/v_m3_01.mdl"}, {10, "models/dg/zp7/v_m3_00.mdl"}, {15, "models/dg/zp7/v_m3_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // M3
	{{3, "models/dg/zp7/v_m4a1_00.mdl"}, {6, "models/dg/zp7/v_m4a1_03.mdl"}, {9, "models/dg/zp7/v_m4a1_01.mdl"}, {12, "models/dg/zp7/v_m4a1_04.mdl"}, {15, "models/dg/zp7/v_m4a1_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // M4A1
	{{5, "models/dg/zp7/v_tmp_01.mdl"}, {10, "models/dg/zp7/v_tmp_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // TMP
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // G3SG1
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // FLASHBANG
	{{4, "models/dg/zp7/v_deagle_01.mdl"}, {8, "models/dg/zp7/v_deagle_02.mdl"}, {12, "models/dg/zp7/v_deagle_00.mdl"}, {16, "models/dg/zp7/v_deagle_03.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // DEAGLE
	{{5, "models/dg/zp7/v_sg552_00.mdl"}, {10, "models/dg/zp7/v_sg552_02.mdl"}, {15, "models/dg/zp7/v_sg552_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SG552
	{{3, "models/dg/zp7/v_ak47_00.mdl"}, {6, "models/dg/zp7/v_ak47_03.mdl"}, {9, "models/dg/zp7/v_ak47_01.mdl"}, {12, "models/dg/zp7/v_ak47_02.mdl"}, {15, "models/dg/zp7/v_ak47_04.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // AK47
	{{2, "models/dg/zp7/v_knife_00.mdl"}, {4, "models/dg/zp7/v_knife_02.mdl"}, {6, "models/dg/zp7/v_knife_03.mdl"}, {8, "models/dg/zp7/v_knife_04.mdl"}, {10, "models/dg/zp7/v_knife_05.mdl"}, {12, "models/dg/zp7/v_knife_06.mdl"}, {14, "models/dg/zp7/v_knife_07.mdl"}, {16, "models/dg/zp7/v_knife_08.mdl"}, {18, "models/dg/zp7/v_knife_08.mdl"}}, // CUCHILLO
	{{5, "models/dg/zp7/v_p90_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}} // P90
};

new const Float:__WEAPON_DAMAGE_NEED[][] = {
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{500.0, 1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // P228
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{750.0, 1500.0, 3000.0, 4500.0, 9000.0, 18000.0, 36000.0, 72000.0, 144000.0, 288000.0, 576000.0, 1152000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 6000000.0, 7000000.0, 8000000.0, 9000000.0, 10000000.0, 2100000000.0}, // XM1014
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // MAC10
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 75000.0, 100000.0, 150000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 100000000.0, 250000000.0, 2100000000.0}, // AUG
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{500.0, 1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // ELITE
	{500.0, 1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // FIVESEVEN
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // UMP45
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}, // SG550
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 75000.0, 100000.0, 150000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 100000000.0, 250000000.0, 2100000000.0}, // GALIL
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 75000.0, 100000.0, 150000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 100000000.0, 250000000.0, 2100000000.0}, // FAMAS
	{500.0, 1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // USP
	{500.0, 1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // GLOCK18
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // MP5NAVY
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}, // M249
	{750.0, 1500.0, 3000.0, 4500.0, 9000.0, 18000.0, 36000.0, 72000.0, 144000.0, 288000.0, 576000.0, 1152000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 6000000.0, 7000000.0, 8000000.0, 9000000.0, 10000000.0, 2100000000.0}, // M3
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 75000.0, 100000.0, 150000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 100000000.0, 250000000.0, 2100000000.0}, // M4A1
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // TMP
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{500.0, 1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 4000000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0}, // DEAGLE
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 75000.0, 100000.0, 150000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 100000000.0, 250000000.0, 2100000000.0}, // SG552
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 75000.0, 100000.0, 150000.0, 250000.0, 500000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 100000000.0, 250000000.0, 2100000000.0}, // AK47
	{100.0, 250.0, 500.0, 1000.0, 2500.0, 5000.0, 7500.0, 10000.0, 25000.0, 50000.0, 75000.0, 100000.0, 150000.0, 200000.0, 250000.0, 300000.0, 350000.0, 450000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2500000.0, 3500000.0, 5000000.0, 2100000000.0}, // CUCHILLO
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3000000.0, 3500000.0, 5000000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 35000000.0, 50000000.0, 2100000000.0} // P90
};

new const __WEAPONS_DIAMMONDS_NEED[][] = {
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // P228
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // XM1014
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // MAC10
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // AUG
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // ELITE
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // FIVESEVEN
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // UMP45
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // GALIL
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // FAMAS
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // USP
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // GLOCK18
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // MP5NAVY
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, // M249
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // M3
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // M4A1
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // TMP
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // DEAGLE
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // SG552
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // AK47
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // CUCHILLO
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999} // P90
};

new const __MAX_BPAMMO[] = {
	-1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100
};

new g_PlayerName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_IsConnected[MAX_PLAYERS + 1];
new g_IsAlive[MAX_PLAYERS + 1];
new g_Zombie[MAX_PLAYERS + 1];
new g_SpecialMode[MAX_PLAYERS + 1];
new g_WeaponAutoBuy[MAX_PLAYERS + 1];
new g_WeaponPrimary_Selection[MAX_PLAYERS + 1];
new g_WeaponPrimary_Current[MAX_PLAYERS + 1];
new g_WeaponSecondary_Selection[MAX_PLAYERS + 1];
new g_WeaponSecondary_Current[MAX_PLAYERS + 1];
new g_WeaponData[MAX_PLAYERS + 1][WeaponIdType][structIdWeaponsData];
new g_WeaponSkills[MAX_PLAYERS + 1][WeaponIdType][structIdWeaponsSkills];
new g_WeaponModel[MAX_PLAYERS + 1][WeaponIdType];
new g_CanBuy[MAX_PLAYERS + 1];
new g_Level[MAX_PLAYERS + 1];
new g_Reset[MAX_PLAYERS + 1];
new g_BuyStuff[MAX_PLAYERS + 1];
new g_MenuPage_Game[MAX_PLAYERS + 1];
new g_MenuPage_BuyWeapons[MAX_PLAYERS + 1];
new g_MenuPage_StatsWeapons[MAX_PLAYERS + 1];
new g_MenuData_WeaponIsPrimary[MAX_PLAYERS + 1];
new WeaponIdType:g_MenuData_StatsWeaponId[MAX_PLAYERS + 1];

new g_pCvar_Delay;
new g_Lights[2];
new g_NewRound;
new g_EndRound;
new g_Mode;
new g_LastMode;
new g_CurrentMode;
new g_NextMode;
new g_EventModes;

#define isPlayerValid(%1) (1 <= %1 <= MaxClients)

public plugin_init() {
	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	register_event("HideWeapon", "event__HideWeapon", "b");

	RegisterHookChain(RG_CGib_Spawn, "onGib__SpawnPost", true);

	RegisterHookChain(RG_CSGameRules_RestartRound, "onGameRules__RestartRoundPre", false);

	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "onBasePlayer__GiveDefaultItemsPre", false);

	RegisterHookChain(RG_ShowMenu, "onClient__ShowMenuPre", false);
	RegisterHookChain(RG_ShowVGUIMenu, "onClient__ShowVGUIMenuPre", false);
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "onClient__HandleMenuChooseTeamPre", false);

	RegisterHam(Ham_Spawn, "player", "ham__PlayerSpawnPost", true);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPre", false);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPost", true);

	register_clcmd("zp_reset", "clcmd__Reset");
	register_clcmd("zp_lighting", "clcmd__Lighting");

	oldmenu_register();

	g_pCvar_Delay = register_cvar("zp_delay", "5");

	setStuffAndVars();
}

public plugin_cfg() {
	set_cvar_num("sv_restart", 1);
}

public client_connectex(id, const name[], const ip[], reason[128]) {
	copy(g_PlayerName[id], charsmax(g_PlayerName[]), name);
}

public client_putinserver(id) {
	g_IsConnected[id] = 1;
	g_IsAlive[id] = 0;

	resetVars(id, 1);

	set_task(1.0, "task__Join", id); // BORRAR
}

public task__Join(const id) { // BORRAR
	rg_join_team(id, TEAM_CT);
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	remove_task(id + TASK_SPAWN);

	g_IsAlive[id] = 0;
	g_IsConnected[id] = 0;
}

public event__HideWeapon(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	set_member(id, m_iClientHideHUD, 0);
	set_member(id, m_iHideHUD, (HIDEHUD_HEALTH | HIDEHUD_MONEY));
}

public onGib__SpawnPost(const id) {
	set_member(id, m_Gib_lifeTime, 0.0);
}

public onGameRules__RestartRoundPre() {
	switch(g_Mode) {
		case MODE_MEGA_ARMAGEDDON: {
			set_cvar_num("mp_round_infinite", 0);
		} case MODE_GUNGAME, MODE_MEGA_GUNGAME, MODE_DUEL_FINAL: {
			set_cvar_num("mp_round_infinite", 0);
			set_cvar_num("mp_freeforall", 0);
		} case MODE_GRUNT: {
			set_cvar_num("sv_alltalk", 1);
		}
	}

	g_Lights[0] = 'i';
	g_NewRound = 1;
	g_EndRound = 0;
	g_Mode = MODE_NONE;

	remove_task(TASK_VIRUST);
	set_task(2.0, "task__VirusT", TASK_VIRUST);

	remove_task(TASK_START_MODE);
	set_task((2.0 + get_pcvar_float(g_pCvar_Delay)), "task__StartMode", TASK_START_MODE);

	if(g_NextMode != -1) {
		g_CurrentMode = g_NextMode;
		g_NextMode = -1;
	}

	checkEvents();
}

public onBasePlayer__GiveDefaultItemsPre(const id) {
	rg_remove_all_items(id);

	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;

	rg_give_item(id, "weapon_knife");

	return HC_SUPERCEDE;
}

public onClient__ShowMenuPre(const id, const slot, const display_time, const need_mode, const text[]) {
	if(containi(text, "Team_Select") == -1) {
		return HC_CONTINUE;
	}

	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

public onClient__ShowVGUIMenuPre(const id, const VGUIMenu:menu_type, const slot, const old_menu[]) {
	if((menu_type != VGUI_Menu_Team) && (menu_type != VGUI_Menu_Class_CT) && (menu_type != VGUI_Menu_Class_T)) {
		return HC_CONTINUE;
	}

	// if(dg_get_user_acc_status(id) != STATUS_CHECK_ACCOUNT && dg_get_user_acc_status(id) != STATUS_LOADING) {
		// if(dg_get_user_acc_status(id) == STATUS_BANNED) {
			// dg_get_user_menu_banned(id);
		// } else if(dg_get_user_acc_status(id) == STATUS_LOGGED) {
			// dg_get_user_menu_join(id);
		// } else if(dg_get_user_acc_status(id) == STATUS_PLAYING) {
			// showMenu__Game(id);
		// } else {
			// dg_get_user_menu_login(id);
		// }

		// SetHookChainReturn(ATYPE_INTEGER, 0);
	// }

	showMenu__Game(id);

	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

public onClient__HandleMenuChooseTeamPre(const id, const MenuChooseTeam:slot) {
	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

public ham__PlayerSpawnPost(const id) {
	if(!is_user_alive(id)) {
		return;
	}

	g_IsAlive[id] = _:is_user_alive(id);

	remove_task(id + TASK_SPAWN);

	// if(g_RespawnAsZombie[id] && !g_NewRound) {
		// resetVars(id, 0);

		// zombieMe(id, .silent_mode=1);
		// return;
	// }

	resetVars(id, 0);

	set_task(0.2, "task__SetWeapons", id + TASK_SPAWN);
}

public ham__PlayerKilledPre(const victim, const killer, const should_gib) {
	g_IsAlive[victim] = 0;
}

public ham__PlayerKilledPost(const victim, const killer, const should_gib) {
	
}

public clcmd__Reset(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	iUserId = cmd_target(id, sArg1, 0);

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_reset <nombre> <factor, + o nada (setear)> <cantidad> - Setea o aumenta los Reset a un jugador.");
		return PLUGIN_HANDLED;
	}

	new iReset = str_to_num(sArg2);

	if(iUserId) {
		new iLastReset = g_Reset[iUserId];

		switch(sArg2[0]) {
			case '+': {
				g_Reset[iUserId] += iReset;

				clientPrintColor(iUserId, id, "!t%s!y te ha dado !g%d reset%s!y.", g_PlayerName[id], iReset, ((iReset != 1) ? "s" : ""));
			} default: {
				g_Reset[iUserId] = iReset;

				clientPrintColor(iUserId, id, "!t%s!y te ha editado tus !gresets!y, ahora tenés !g%d reset%s!y.", g_PlayerName[id], iReset, ((iReset != 1) ? "s" : ""));
			}
		}
		
		consolePrint(id, "%s tenía %d reset%s y ahora tiene %d", g_PlayerName[iUserId], iLastReset, ((iLastReset != 1) ? "s" : ""), g_Reset[iUserId]);
	} else {
		
	}

	return PLUGIN_HANDLED;
}

public clcmd__Lighting(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[2];
	read_argv(1, sArg1, charsmax(sArg1));

	if(read_argc() < 2) {
		consolePrint(id, "Uso: zp_lighting <letra de iluminación> - Ejemplo: zp_lighting ^"i^"");
		return PLUGIN_HANDLED;
	}

	copy(g_Lights, charsmax(g_Lights), sArg1);
	changeLights();

	clientPrintColor(0, _, "!t%s!y ha cambiado la luz del mapa al grado de iluminación !g%c!y", g_PlayerName[id], g_Lights[0]);
	return PLUGIN_HANDLED;
}

public showMenu__Game(const id) {
	if(g_BuyStuff[id]) {
		clientPrintColor(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite.");
		return;
	}

	oldmenu_create("\y%s \r-\y %s \r(by %s)^n\d%s", "menu__Game", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME_SHORT, __PLUGIN_AUTHOR, __PLUGIN_COMMUNITY_FORUM);

	switch(g_MenuPage_Game[id]) {
		case 0: {
			oldmenu_additem(1, 1, "\r1.\w ARMAS");
			oldmenu_additem(2, 2, "\r2.\w ITEMS EXTRAS^n");

			oldmenu_additem(3, 3, "\r3.\w CLASES / DIFICULTADES");
			oldmenu_additem(4, 4, "\r4.\w HABILIDADES");
			oldmenu_additem(5, 5, "\r5.\w LOGROS");
			oldmenu_additem(6, 6, "\r6.\w GRUPO^n");

			if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
				oldmenu_additem(7, 7, "\r7.\w BENEFICIO GRATUITO");
			} else {
				oldmenu_additem(-1, -1, "\d7. BENEFICIO GRATUITO");
			}

			oldmenu_additem(8, 8, "\r8.\y REGLAS^n");
		} case 1: {
			oldmenu_additem(1, 1, "\r1.\w GORROS");
			oldmenu_additem(2, 2, "\r2.\w AMULETOS^n");

			oldmenu_additem(3, 3, "\r3.\w CABEZAS ZOMBIES");
			oldmenu_additem(4, 4, "\r4.\w VISITAS DIARIAS");
			oldmenu_additem(5, 5, "\r5.\w ARTEFACTOS");
			oldmenu_additem(6, 6, "\r6.\w MAESTRÍA^n");

			oldmenu_additem(7, 8, "\r7.\w OPCIONES DE USUARIO");
			oldmenu_additem(8, 8, "\r8.\w ESTADÍSTICAS^n");
		}
	}

	oldmenu_additem(9, 9, "\r9.\w Siguiente/Atrás");

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

public menu__Game(const id, const item) {
	if(g_BuyStuff[id]) {
		clientPrintColor(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite.");
	} else {
		switch(g_MenuPage_Game[id]) {
			case 0: {
				switch(item) {
					case 1: {
						showMenu__Weapons(id);
					} case 9: {
						g_MenuPage_Game[id] = 1;
						showMenu__Game(id);
					}
				}
			} case 1: {
				switch(item) {
					case 1: {
						
					} case 9: {
						g_MenuPage_Game[id] = 0;
						showMenu__Game(id);
					}
				}
			}
		}
	}
}

public showMenu__Weapons(const id) {
	oldmenu_create("\yARMAS", "menu__Weapons");

	if(g_Zombie[id] || g_SpecialMode[id] || !g_CanBuy[id]) {
		oldmenu_additem(-1, -1, "\rPuedes seleccionar tus armas y recordar tu compra para^nobtenerlos cuando respawnees como humano^n");
	}

	if(__WEAPONS[g_WeaponPrimary_Selection[id]][weaponName][0]) {
		oldmenu_additem(1, 1, "\r1.\w Armas primarias \y[%s]", __WEAPONS[g_WeaponPrimary_Selection[id]][weaponName]);
	} else {
		oldmenu_additem(1, 1, "\r1.\w Armas primarias \y[ninguno]");
	}

	if(__WEAPONS[g_WeaponSecondary_Selection[id]][weaponName][0]) {
		oldmenu_additem(2, 2, "\r2.\w Armas secundarias \y[%s]^n", __WEAPONS[g_WeaponSecondary_Selection[id]][weaponName]);
	} else {
		oldmenu_additem(2, 2, "\r2.\w Armas secundarias \y[ninguno]^n");
	}

	oldmenu_additem(-1, -1, "\yGRANADAS\r:");
	oldmenu_additem(-1, -1, "\r - \y +%d\w %s \r-\y +%d\w %s \r-\y +%d\w %s^n", getGrenadeAmount(id, WEAPON_HEGRENADE), getGrenadeType(id, WEAPON_HEGRENADE), getGrenadeAmount(id, WEAPON_FLASHBANG), getGrenadeType(id, WEAPON_FLASHBANG), getGrenadeAmount(id, WEAPON_SMOKEGRENADE), getGrenadeType(id, WEAPON_SMOKEGRENADE));

	if(g_CanBuy[id]) {
		oldmenu_additem(5, 5, "\r5.\w Comprar armas");
	} else {
		oldmenu_additem(-1, -1, "\d5. Comprar armas");
	}

	oldmenu_additem(6, 6, "\r6.\w Recordar compra\r:\y %s^n", ((g_WeaponAutoBuy[id]) ? "Si" : "No"));

	oldmenu_additem(9, 9, "\r9.\w Ver estadísticas de mis armas^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Weapons(const id, const item) {
	if(!item) {
		showMenu__Game(id);
	} else {
		switch(item) {
			case 1: {
				showMenu__BuyWeapons(id, 1);
			} case 2: {
				showMenu__BuyWeapons(id, 0);
			} case 5: {
				if(g_CanBuy[id]) {
					buyWeapons(id);
				} else {
					clientPrintColor(id, _, "No puedes comprar armas en este momento.");
					showMenu__Weapons(id);
				}
			} case 6: {
				g_WeaponAutoBuy[id] = !g_WeaponAutoBuy[id];
				showMenu__Weapons(id);
			} case 9: {
				showMenu__StatsWeapons(id);
			}
		}
	}
}

public showMenu__BuyWeapons(const id, const is_primary) {
	g_MenuData_WeaponIsPrimary[id] = is_primary;

	new iMenuId;
	new i;
	new sPosition[2];

	menu_create(fmt("ARMAS %s\R", ((is_primary) ? "PRIMARIAS" : "SECUNDARIAS")), "menu__BuyWeapons");

	for(i = 0; i < sizeof(__WEAPONS); ++i) {
		if(__WEAPONS[i][weaponIsPrimary] == -1 || (is_primary && !__WEAPONS[i][weaponIsPrimary]) || (!is_primary && __WEAPONS[i][weaponIsPrimary])) {
			continue;
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, fmt("\w%s \y(DMG: %0.2f)", __WEAPONS[i][weaponName], __WEAPONS[i][weaponDamageBase]), sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_BuyWeapons[id] = min(g_MenuPage_BuyWeapons[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_BuyWeapons[id]);
}

public menu__BuyWeapons(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_BuyWeapons[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Weapons(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	if(g_MenuData_WeaponIsPrimary[id]) {
		g_WeaponPrimary_Selection[id] = sPosition[0];
	} else {
		g_WeaponSecondary_Selection[id] = sPosition[0];
	}

	showMenu__Weapons(id);
	return PLUGIN_HANDLED;
}

public showMenu__StatsWeapons(const id) {
	new iMenuId;
	new i;
	new WeaponIdType:iWeaponId;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("ESTADÍSTICAS DE MIS ARMAS\R", "menu__StatsWeapons");

	for(i = 0; i < sizeof(__WEAPONS); ++i) {
		if(__WEAPONS[i][weaponIsPrimary] == -1) {
			continue;
		}

		iWeaponId = __WEAPONS[i][weaponId];

		formatex(sItem, charsmax(sItem), "%s \y(N: %d)", __WEAPONS[i][weaponName], g_WeaponData[id][iWeaponId][WEAPON_DATA_LEVEL]);

		sPosition[0] = _:iWeaponId;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_StatsWeapons[id] = min(g_MenuPage_StatsWeapons[id], (menu_pages(iMenuId) - 1));
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_StatsWeapons[id]);
}

public menu__StatsWeapons(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_StatsWeapons[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Weapons(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	g_MenuData_StatsWeaponId[id] = WeaponIdType:sPosition[0];

	showMenu__StatsWeaponsIn(id);
	return PLUGIN_HANDLED;
}

public showMenu__StatsWeaponsIn(const id) {
	new sTitle[32];
	copy(sTitle, charsmax(sTitle), __WEAPONS[_:g_MenuData_StatsWeaponId[id]][weaponName]);
	strtoupper(sTitle);

	oldmenu_create("\y%s^n\wPuntos disponibles\r:\y %d", "menu__StatsWeaponsIn", sTitle, g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_POINTS]);

	new sKills[8];
	addDot(g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_KILL_DONE], sKills, charsmax(sKills));
	oldmenu_additem(-1, -1, "\wZombies matados\r:\y %s", sKills);

	if(g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_LEVEL] != 20) {
		new sDmgLvl[32];
		new sDmgLvlOutPut[32];
		new sDmgLvlNeed[32];
		new sDmgLvlNeedOutPut[32];
		new Float:flLevelPercent = ((g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_DAMAGE_DONE] * 100.0) / __WEAPON_DAMAGE_NEED[_:g_MenuData_StatsWeaponId[id]][g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_LEVEL]]);

		formatex(sDmgLvl, charsmax(sDmgLvl), "%0.0f", (g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_DAMAGE_DONE] * DIV_DAMAGE));
		addDotSpecial(sDmgLvl, sDmgLvlOutPut, charsmax(sDmgLvlOutPut));

		formatex(sDmgLvlNeed, charsmax(sDmgLvlNeed), "%0.0f", (__WEAPON_DAMAGE_NEED[_:g_MenuData_StatsWeaponId[id]][g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_LEVEL]] * DIV_DAMAGE));
		addDotSpecial(sDmgLvlNeed, sDmgLvlNeedOutPut, charsmax(sDmgLvlNeedOutPut));

		oldmenu_additem(-1, -1, "\wDaño hecho\r:\y %s / %s", sDmgLvlOutPut, sDmgLvlNeedOutPut);
		oldmenu_additem(-1, -1, "\wNivel del arma\r:\y %d (%0.2f%%)^n", g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_LEVEL], flLevelPercent);
	} else {
		oldmenu_additem(-1, -1, "\wNivel del arma\r:\y Máximo^n");
	}

	oldmenu_additem(1, WEAPON_SKILL_DAMAGE, "\r1.\w Daño \y(N: %d)", g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_DAMAGE]);
	oldmenu_additem(2, WEAPON_SKILL_SPEED, "\r2.\w Velocidad de Disparo \y(N: %d)", g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_SPEED]);

	if(g_MenuData_StatsWeaponId[id] != WEAPON_KNIFE) {
		oldmenu_additem(3, WEAPON_SKILL_RECOIL, "\r3.\w Precisión \y(N: %d)", g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_RECOIL]);
		oldmenu_additem(4, WEAPON_SKILL_BULLETS, "\r4.\w Balas \y(N: %d)", g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_BULLETS]);
	}

	if(getTotalSkins(g_MenuData_StatsWeaponId[id])) {
		oldmenu_additem(7, 7, "^n\r7.\w Cambiar skin");
	} else {
		oldmenu_additem(-1, -1, "");
	}

	// if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] != 20) {
		// if(g_Points[id][P_DIAMONDS] >= __WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]) {
			// oldmenu_additem(8, 8, "^n\r8.\w Subir a nivel %d \y(%d DIAMANTES)", (g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] + 1), __WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);
		// } else {
			// oldmenu_additem(-1, -1, "^n\d8. Subir a nivel %d \r(%d DIAMANTES)", (g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] + 1), __WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);
		// }
	// } else {
		// oldmenu_additem(-1, -1, "");
	// }

	oldmenu_additem(9, 9, "^n\r9.\w Reiniciar puntos");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__StatsWeaponsIn(const id, const item, const value) {
	if(!item) {
		showMenu__StatsWeapons(id);
		return;
	}

	switch(item) {
		case 7: {
			showMenu__StatsWeaponsInSkins(id);
		} case 8: {

		} case 9: {
			new iReturn = (g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_DAMAGE] + g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_SPEED] + g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_RECOIL] + g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_BULLETS]);

			if(iReturn <= 0) {
				clientPrintColor(id, _, "No tienes habilidades para reiniciar.");

				showMenu__StatsWeaponsIn(id);
				return;
			}

			g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_DAMAGE] = 0;
			g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_SPEED] = 0;
			g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_RECOIL] = 0;
			g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_BULLETS] = 0;

			g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_POINTS] += iReturn;

			showMenu__StatsWeaponsIn(id);
		} default: {
			if(g_MenuData_StatsWeaponId[id] == WEAPON_KNIFE && (value == WEAPON_SKILL_RECOIL || value == WEAPON_SKILL_BULLETS)) {
				showMenu__StatsWeaponsIn(id);
				return;
			}

			if(g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_POINTS] <= 0) {
				clientPrintColor(id, _, "No tienes puntos suficientes.");

				showMenu__StatsWeaponsIn(id);
				return;
			}

			if((value == WEAPON_SKILL_SPEED && g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][WEAPON_SKILL_SPEED] >= 5) || g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][value] >= 10) {
				clientPrintColor(id, _, "Has alcanzado el límite máximo de la habilidad seleccionada.");
				
				showMenu__StatsWeaponsIn(id);
				return;
			}

			--g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_POINTS];
			++g_WeaponSkills[id][g_MenuData_StatsWeaponId[id]][value];

			// new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_weapons SET level='%d', points='%d', skill_damage='%d', skill_speed='%d', skill_recoil='%d', skill_bullets='%d', skill_reload_speed='%d', skill_critical_probability='%d' WHERE acc_id='%d' AND weapon_id='%d';", g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL], g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_DAMAGE], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RECOIL], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_BULLETS], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RELOAD_SPEED], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_CRITICAL_PROBABILITY], g_AccountId[id], iMyWeaponId);

			// if(!SQL_Execute(sqlQuery)) {
				// executeQuery(id, sqlQuery, 10);
			// } else {
				// SQL_FreeHandle(sqlQuery);
			// }

			showMenu__StatsWeaponsIn(id);
		}
	}
}

public showMenu__StatsWeaponsInSkins(const id) {
	oldmenu_create("\ySKINS^n\wNA\r:\y Nivel del Arma", "menu__StatsWeaponsInSkins");

	for(new j = 0, k = 1; j < 9; ++j, ++k) {
		if(__WEAPON_MODELS[_:g_MenuData_StatsWeaponId[id]][j][weaponModelLevel] != 99 && __WEAPON_MODELS[_:g_MenuData_StatsWeaponId[id]][j][weaponModelPath][0]) {
			if(g_WeaponData[id][g_MenuData_StatsWeaponId[id]][WEAPON_DATA_LEVEL] < __WEAPON_MODELS[_:g_MenuData_StatsWeaponId[id]][j][weaponModelLevel]) {
				oldmenu_additem(-1, -1, "\d%d. Skin #%d \r(NA: %d)", k, (j + 1), __WEAPON_MODELS[_:g_MenuData_StatsWeaponId[id]][j][weaponModelLevel]);
			} else {
				if(g_WeaponModel[id][g_MenuData_StatsWeaponId[id]] == (j + 1)) {
					oldmenu_additem(-1, -1, "\d%d. Skin #%d \y(ACTUAL)", k, (j + 1));
				} else {
					oldmenu_additem(k, j, "\r%d.\w Skin #%d", k, (j + 1));
				}
			}
		}
	}

	oldmenu_additem(-1, -1, "^n\yNOTA\r:\w Recuerda que siempre tienes la 'obligación' de cambiar^ntu skin del arma siempre que te acuerdes. Ya no se cambiará^nautomáticamente como anteriores versiones^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__StatsWeaponsInSkins(const id, const item, const value) {
	if(!item) {
		showMenu__StatsWeaponsIn(id);
		return;
	}

	g_WeaponModel[id][g_MenuData_StatsWeaponId[id]] = (value + 1);

	// if(g_CurrentWeapon[id] == g_MenuData_StatsWeaponId[id]) {
		// engclient_cmd(id, __WEAPON_ENT_NAMES[_:g_MenuData_StatsWeaponId[id]]);
		// replaceWeaponModels(id, g_MenuData_StatsWeaponId[id]);
	// }

	showMenu__StatsWeaponsInSkins(id);
}

public setStuffAndVars() {
	set_cvar_string("sv_skyname", "space");

	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	g_Lights[0] = 'b';
	g_CurrentMode = MODE_INFECTION;
	g_NextMode = -1;
}

public checkEvents() {

}

public changeLights() {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			setLight(i, 0, g_Lights[0]);
		}
	}
}

public resetVars(const id, const reset_all) {
	g_Zombie[id] = 0;
	g_SpecialMode[id] = MODE_NONE;
	g_CanBuy[id] = 1;
	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;

	if(reset_all) {
		g_WeaponAutoBuy[id] = 0;
		g_WeaponPrimary_Selection[id] = 0;
		g_WeaponSecondary_Selection[id] = 0;
		for(new WeaponIdType:i = WEAPON_NONE; i < WeaponIdType; ++i) {
			g_WeaponData[id][i][WEAPON_DATA_KILL_DONE] = 0;
			g_WeaponData[id][i][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
			g_WeaponData[id][i][WEAPON_DATA_LEVEL] = 0;
			g_WeaponData[id][i][WEAPON_DATA_POINTS] = 0;

			for(new j = 0; j < structIdWeaponsSkills; ++j) {
				g_WeaponSkills[id][i][j] = 0;
			}

			g_WeaponModel[id][i] = 0;
		}
		g_Level[id] = 1;
		g_Reset[id] = 0;
		g_BuyStuff[id] = 0;
		g_MenuPage_Game[id] = 0;
		g_MenuPage_BuyWeapons[id] = 0;
		g_MenuPage_StatsWeapons[id] = 0;
		g_MenuData_WeaponIsPrimary[id] = 0;
		g_MenuData_StatsWeaponId[id] = WEAPON_NONE;
	}
}

public isHullVacant(const Float:vecOrigin[3], const hull) {
	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, hull, 0, 0);

	if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen)) {
		return 1;
	}

	return 0;
}

startModePre(const mode, id=0) {
	new iUsersAlive = getUsersAlive();

	if(mode == MODE_NONE) {
		if(iUsersAlive < 4 && !id) {
			clientPrint(0, print_center, "Deben haber un mínimo de 4 jugadores para que inicie la ronda.");
			
			set_task(10.0, "task__StartMode", TASK_START_MODE);
			return;
		}
	}

	g_NewRound = 0;

	if(mode != MODE_NONE) {
		if(g_CurrentMode != MODE_INFECTION && g_CurrentMode != MODE_PLAGUE) {
			g_NextMode = g_CurrentMode;
		}

		g_CurrentMode = mode;

		startModePost(g_CurrentMode, id);
		chooseMode();

		return;
	}

	startModePost(g_CurrentMode, id);
	chooseMode();
}

startModePost(const mode, id=0) {
	remove_task(TASK_VIRUST);
	remove_task(TASK_START_MODE);

	g_Lights[0] = 'b';

	if(mode == MODE_GUNGAME || mode == MODE_MEGA_GUNGAME || mode == MODE_DUEL_FINAL) {
		g_Lights[0] = 'i';
	} else if(mode == MODE_GRUNT) {
		g_Lights[0] = 'a';
	}

	g_Mode = mode;
	g_LastMode = mode;

	changeLights();

	new iUsersAlive = getUsersAlive();
	new iMaxUsers = 0;
	new iUsers = 0;
	new iAlreadyChoosen[MAX_PLAYERS + 1];
	new i;

	switch(mode) {
		case MODE_INFECTION: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || id == i) {
					continue;
				}

				setUserTeam(i, TEAM_CT);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡INFECCIÓN!");
		} case MODE_SWARM: {
			iMaxUsers = (iUsersAlive / 2);
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(iAlreadyChoosen[id]) {
					continue;
				}

				iAlreadyChoosen[id] = 1;
				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(iAlreadyChoosen[i]) {
					setUserTeam(i, TEAM_CT);
				} else {
					zombieMe(i);
				}
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡SWARM!");
		} case MODE_MULTI: {
			iMaxUsers = (iUsersAlive / 3);
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(iAlreadyChoosen[id]) {
					continue;
				}

				iAlreadyChoosen[id] = 1;
				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(iAlreadyChoosen[i]) {
					zombieMe(i);
				} else {
					setUserTeam(i, TEAM_CT);
				}
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡INFECCIÓN MÚLTIPLE!");
		} case MODE_PLAGUE: {
			iMaxUsers = (iUsersAlive / 2);
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(iAlreadyChoosen[id]) {
					continue;
				}

				iAlreadyChoosen[id] = 1;
				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(iAlreadyChoosen[i]) {
					setUserTeam(i, TEAM_CT);
				} else {
					zombieMe(i);
				}
			}

			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id]) {
					continue;
				}

				if(iUsers == 0) {
					humanMe(id, .survivor=1);
				} else if(iUsers == 1) {
					humanMe(id, .survivor=1);
				} else if(iUsers == 2) {
					zombieMe(id, .nemesis=1);
				} else {
					zombieMe(id, .nemesis=1);
				}

				++iUsers;
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡PLAGUE!");
		} case MODE_SYNAPSIS: {
			iMaxUsers = 3;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id]) {
					continue;
				}

				zombieMe(id, .nemesis=1);
				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || g_SpecialMode[i]) {
					continue;
				}

				setUserTeam(i, TEAM_CT);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡SYNAPSIS!");
		} case MODE_MEGA_SYNAPSIS: {

		} case MODE_ARMAGEDDON: {

		} case MODE_MEGA_ARMAGEDDON: {

		} case MODE_GUNGAME: {

		} case MODE_MEGA_GUNGAME: {

		} case MODE_DRUNK: {

		} case MODE_DUEL_FINAL: {

		} case MODE_SURVIVOR: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			humanMe(id, .survivor=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || id == i) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 0, 0, 255, -1.0, 0.25, 0, 15.0, "¡%s ES SURVIVOR!", g_PlayerName[id]);
		} case MODE_WESKER: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			humanMe(id, .wesker=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || id == i) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 0, 255, 255, -1.0, 0.25, 0, 15.0, "¡%s ES WESKER!", g_PlayerName[id]);
		} case MODE_TRIBAL: {
			iMaxUsers = 2;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id]) {
					continue;
				}

				humanMe(id, .tribal=1);
				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || g_SpecialMode[i]) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 255, 165, 0, -1.0, 0.25, 0, 15.0, "¡TRIBAL!");
		} case MODE_SNIPER: {
			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id]) {
					continue;
				}

				humanMe(id, .sniper=1);
				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || g_SpecialMode[i]) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡SNIPER!");
		} case MODE_NEMESIS: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			zombieMe(id, .nemesis=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || id == i) {
					continue;
				}

				setUserTeam(i, TEAM_CT);
			}

			showDHUDMessage(0, 255, 0, 0, -1.0, 0.25, 0, 15.0, "¡%s ES NEMESIS!", g_PlayerName[id]);
		} case MODE_ANNIHILATOR: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			zombieMe(id, .annihilator=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || id == i) {
					continue;
				}

				setUserTeam(i, TEAM_CT);
			}

			showDHUDMessage(0, 255, 255, 0, -1.0, 0.25, 0, 15.0, "¡%s ES ANIQUILADOR!", g_PlayerName[id]);
		} case MODE_FLESHPOUND: {

		} case MODE_GRUNT: {

		}
	}
}

public chooseMode() {
	// if(g_ModeMGG_Played == 2) {
		// g_NextMode = MODE_MEGA_GUNGAME;
		// return;
	// }

	new iUsersAlive = getUsersAlive();

	if(g_CurrentMode == MODE_NONE && g_NextMode == MODE_NONE) {
		if(g_EventModes) {
			g_CurrentMode = ((iUsersAlive >= __MODES[MODE_ARMAGEDDON][modeUsersNeed]) ? MODE_ARMAGEDDON : MODE_PLAGUE);
		} else {
			g_CurrentMode = MODE_INFECTION;
		}
	}

	new iModeSelected = MODE_INFECTION;
	new i;

	for(i = 0; i < structIdModes; ++i) {
		if((!g_EventModes || g_EventModes && __MODES[i][modeSpecial] == 1) && __MODES[i][modeChance] && random_num(1, __MODES[i][modeChance]) == 1 && iUsersAlive >= __MODES[i][modeUsersNeed] && g_LastMode != i) {
			iModeSelected = i;
			break;
		}
	}

	g_NextMode = iModeSelected;
}

getRandomAlive(const random) {
	new iCount = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			++iCount;
		}

		if(iCount == random) {
			return i;
		}
	}

	return -1;
}

zombieMe(const id, attacker=0, silent_mode=0, nemesis=0, annihilator=0, fleshpound=0, grunt=0) {
	g_CanBuy[id] = 0;
	g_Zombie[id] = 1;
	g_SpecialMode[id] = MODE_NONE;

	if(attacker) {

	} else {
		if(nemesis) {

		} else if(annihilator) {

		} else if(fleshpound) {

		} else if(grunt) {

		} else {

		}
	}

	setUserTeam(id, TEAM_TERRORIST);
}

humanMe(const id, silent_mode=0, survivor=0, wesker=0, tribal=0, sniper=0) {
	g_CanBuy[id] = 1;
	g_Zombie[id] = 0;
	g_SpecialMode[id] = MODE_NONE;

	if(survivor) {

	} else if(wesker) {

	} else if(tribal) {

	} else if(sniper) {

	} else {
		if(silent_mode) {

		}
	}

	setUserTeam(id, TEAM_CT);
}

public buyWeapons(const id) {
	rg_remove_all_items(id);
	rg_give_item(id, "weapon_knife");

	g_WeaponPrimary_Current[id] = g_WeaponPrimary_Selection[id];
	g_WeaponSecondary_Current[id] = g_WeaponSecondary_Selection[id];

	rg_give_item(id, __WEAPONS[g_WeaponPrimary_Selection[id]][weaponEnt]);
	rg_set_user_bpammo(id, __WEAPONS[g_WeaponPrimary_Selection[id]][weaponId], __MAX_BPAMMO[_:__WEAPONS[g_WeaponPrimary_Selection[id]][weaponId]]);

	rg_give_item(id, __WEAPONS[g_WeaponSecondary_Selection[id]][weaponEnt]);
	rg_set_user_bpammo(id, __WEAPONS[g_WeaponSecondary_Selection[id]][weaponId], __MAX_BPAMMO[_:__WEAPONS[g_WeaponSecondary_Selection[id]][weaponId]]);

	g_CanBuy[id] = 0;
}

public getGrenadeAmount(const id, const WeaponIdType:weapon_id) {
	new iReset = g_Reset[id];
	new iAmount = 0;

	if(weapon_id == WEAPON_HEGRENADE) {
		iAmount = ((iReset >= HEGRENADE_PER_RESET) ? ((iReset / HEGRENADE_PER_RESET) + 1) : 1);

		if(iAmount >= MAX_HEGRENADE_AMOUNT) {
			iAmount = MAX_HEGRENADE_AMOUNT;
		}

		return iAmount;
	} else if(weapon_id == WEAPON_FLASHBANG) {
		iAmount = ((iReset >= FLASHBANG_PER_RESET) ? ((iReset / FLASHBANG_PER_RESET) + 1) : 1);

		if(iAmount >= MAX_FLASHBANG_AMOUNT) {
			iAmount = MAX_FLASHBANG_AMOUNT;
		}

		return iAmount;
	} else if(weapon_id == WEAPON_SMOKEGRENADE) {
		iAmount = ((iReset >= SMOKEGRENADE_PER_RESET) ? ((iReset / SMOKEGRENADE_PER_RESET) + 1) : 1);

		if(iAmount >= MAX_SMOKEGRENADE_AMOUNT) {
			iAmount = MAX_SMOKEGRENADE_AMOUNT;
		}

		return iAmount;
	}

	return 0;
}

public getGrenadeType(const id, const WeaponIdType:weapon_id) {
	new sType[16];

	if(weapon_id == WEAPON_HEGRENADE) {
		if(g_Reset[id] >= HEGRENADE_CHANGE_RESET) {
			formatex(sType, charsmax(sType), "Droga");
		} else {
			formatex(sType, charsmax(sType), "Fuego");
		}
	} else if(weapon_id == WEAPON_FLASHBANG) {
		if(g_Reset[id] >= FLASHBANG_CHANGE_RESET) {
			formatex(sType, charsmax(sType), "Supernova");
		} else {
			formatex(sType, charsmax(sType), "Hielo");
		}
	} else if(weapon_id == WEAPON_SMOKEGRENADE) {
		if(g_Reset[id] >= SMOKEGRENADE_CHANGE_RESET) {
			formatex(sType, charsmax(sType), "Bubble");
		} else {
			formatex(sType, charsmax(sType), "Luz");
		}
	}

	return sType;
}

public getTotalSkins(const WeaponIdType:weapon_id) {
	new iCount = 0;

	for(new WeaponIdType:i = WEAPON_NONE; i < WeaponIdType; ++i) {
		for(new j = 0; j < 9; ++j) {
			if(i == weapon_id && __WEAPON_MODELS[_:i][j][weaponModelLevel] != 99 && __WEAPON_MODELS[_:i][j][weaponModelPath][0]) {
				++iCount;
			}
		}
	}

	return iCount;
}

public setLight(const id, const style, const light[]) {
	if(id == 0) {
		message_begin(MSG_ALL, SVC_LIGHTSTYLE);
	} else {
		message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id);
	}

	write_byte(style);
	write_string(light);
	message_end();
}

public task__SetWeapons(const task_id) {
	new iId = ((task_id > MaxClients) ? (task_id - TASK_SPAWN) : task_id);

	if(!g_IsAlive[iId]) {
		return;
	}

	if(g_WeaponAutoBuy[iId] && task_id > MaxClients) {
		if(!g_IsAlive[iId] || g_Zombie[iId] || g_SpecialMode[iId] || !g_CanBuy[iId]) {
			return;
		}

		buyWeapons(iId);
	}

	showMenu__Weapons(iId);
}

public task__VirusT() {
	showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, 0, 7.5, "¡EL VIRUS-T SE HA LIBERADO!");

	// new Float:flExtraMult = 0.0;

	// if(g_HappyHour == 2) {
		// flExtraXP = (2.0 + g_UserExtraXP);
		
		// clientPrintColor(0, _, "!tSUPER DRUNK AT NITE!y: Tu multiplicador de XP aumenta un !g+x%0.2f!y y de puntos !g+x1!y", flExtraXP);
	// } else if(g_DrunkAtDay == 1 || g_HappyHour == 1) {
		// flExtraXP = (1.0 + g_UserExtraXP);

		// if(g_DrunkAtDay == 1) {
			// clientPrintColor(0, _, "!tDRUNK AT DAY!y: Tu multiplicador de XP aumenta un !g+x%0.2f!y", flExtraXP);
		// } else {
			// clientPrintColor(0, _, "!tDRUNK AT NITE!y: Tu multiplicador de XP aumenta un !g+x%0.2f!y", flExtraXP);
		// }

		// if(g_EventModes) {
			// clientPrintColor(0, _, "!tEVENTO DE MODOS!y: Solo saldrán modos especiales");

			// if(g_EventMode_MegaArmageddon > 0 || g_EventMode_GunGame > 0) {
				// if(g_EventMode_GunGame > 0) {
					// clientPrintColor(0, _, "GunGame %s en !g%d ronda%s!y - Mega Armageddon en !g%d ronda%s!y.", __GUNGAME_TYPE_NAME[g_ModeGG_Type], g_EventMode_GunGame, ((g_EventMode_GunGame != 1) ? "s" : ""), g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
				// } else {
					// clientPrintColor(0, _, "Mega Armageddon en !g%d ronda%s!y", g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
				// }
			// }
		// }
	// }

	changeLights();

	// if(g_EventModes && !g_EventMode_GunGame) {
		// clientPrintColor(0, _, "Modificador de hoy: !tGUNGAME:!g %s!y", __GUNGAME_TYPE_NAME[g_ModeGG_Type]);
		// clientPrintColor(0, _, "%s", __GUNGAME_TYPE_INFO[g_ModeGG_Type]);
	// }
}

public task__StartMode() {
	startModePre(MODE_NONE);
}