#include <dg>
#include <dg_accounts>

#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <sqlx>

#include <zp9>

#include <util_messages>

#pragma semicolon 1;

/*
	OFICIAL
	Agregar los logros para que se puedan conseguir

	===============================

	Loteria

	Talentos:
		Son como habilidades rotativas
		Se compran con pF
		Duran una cierta cantidad de rondas o todo el mapa
		Si aún no se cumplieron algunas rondas, se guarda para el próximo mapa
*/

new const __PLUGIN_NAME[] = "Zombie Plague";
new const __PLUGIN_VERSION[] = "9.0.0";
new const __PLUGIN_AUTHOR[] = "Atsul.P";

const WARMUP_TIME = 45;
const PREPARE_TIME = 10;
const ROUND_TIME = 300;
const GAMEMODE_LAUNCH_MINALIVES = 4;

const MAX_LEVELS = 300;
const MAX_RESETS = 50;
const MAX_PRESTIGE = 27;
const MAX_HUMAN_CLASS = 3;
const MAX_ZOMBIE_CLASS = 3;
const MAX_CLAN_MEMBERS = 8;

const COST_HAB_RESET_POINTS = 10;

enum _:structIdTasks (+= 236877) {
	TASK_CHECK_BUYS = 54276,
	TASK_CHECK_ACHIEVEMENTS,
	TASK_CHECK_HATS,
	TASK_SAVE,
	TASK_TIME_PLAYED,
	TASK_FINISHCOMBO,

	TASK_WARMUP,
	TASK_VIRUST
};

enum _:structIdGrenades {
	GRENADE_INFECTION = 0,

	GRENADE_FIRE,
	GRENADE_FROST,
	GRENADE_FLARE,

	GRENADE_DRUG,
	GRENADE_SUPERNOVA,
	GRENADE_BUBBLE,

	GRENADE_KILL,
	GRENADE_PIPE,
	GRENADE_ANTIDOTE
};

enum _:structIdClasses {
	CLASS_HUMAN = 0,
	CLASS_ZOMBIE,
	CLASS_SURVIVOR,
	CLASS_WESKER,
	CLASS_SNIPER,
	CLASS_NEMESIS,
	CLASS_ASSASSIN,
	CLASS_GRUNT
}

enum _:structIdModes {
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE,
	MODE_SYNAPSIS,
	MODE_ARMAGEDDON,
	MODE_MEGA_ARMAGEDDON,
	MODE_GUNGAME,
	MODE_MEGA_GUNGAME,
	MODE_DUEL_FINAL,
	MODE_SURVIVOR,
	MODE_WESKER,
	MODE_SNIPER,
	MODE_NEMESIS,
	MODE_ASSASSIN,
	MODE_GRUNT
};

enum _:structIdExtraItems {
	EXTRA_ITEM_NVISION = 0,
	EXTRA_ITEM_UNLIMITED_CLIP,
	EXTRA_ITEM_PRESICION_PERFECT,
	EXTRA_ITEM_KILL_BOMB,
	EXTRA_ITEM_PIPE_BOMB,
	EXTRA_ITEM_ANTIDOTE_BOMB,

	EXTRA_ITEM_ANTIDOTE,
	EXTRA_ITEM_ZOMBIE_MADNESS,
	EXTRA_ITEM_INFECTION_BOMB,
	EXTRA_ITEM_REDUCE_DAMAGE
};

enum _:structIdZombieClasses {
	ZOMBIE_MOOLY = 0,

	ZOMBIE_HAT,
	ZOMBIE_MIIAK,
	ZOMBIE_PALOORD,

	ZOMBIE_OC3,
	ZOMBIE_KARKO,
	ZOMBIE_SEFFEL,

	ZOMBIE_BOORM,
	ZOMBIE_VYLK,
	ZOMBIE_REWTTEM,

	ZOMBIE_LACCO,
	ZOMBIE_JOFFE,
	ZOMBIE_SHUG_IM,

	ZOMBIE_NEIV,
	ZOMBIE_KANKIS,
	ZOMBIE_RAXOI,

	ZOMBIE_REV
};

enum _:structIdDiffsClasses {
	DIFF_CLASS_SURVIVOR = 0,
	DIFF_CLASS_NEMESIS
};

enum _:structIdDiffs {
	DIFF_NORMAL = 0,
	DIFF_NIGHTMARE,
	DIFF_SUICIDAL,
	DIFF_HELL
};

enum _:structIdPoints {
	P_MONEY = 0,
	P_HUMAN,
	P_ZOMBIE,
	P_LEGACY,
	P_FRAGMENT,
	P_DIAMOND
};

enum _:structIdHabsClasses {
	HAB_CLASS_HUMAN = 0,
	HAB_CLASS_ZOMBIE,
	HAB_CLASS_SURVIVOR,
	HAB_CLASS_NEMESIS,
	HAB_CLASS_EXTRAS,
	HAB_CLASS_LEGENDARY
};

enum _:structIdHabs {
	HAB_H_HEALTH = 0,
	HAB_H_SPEED,
	HAB_H_GRAVITY,
	HAB_H_DAMAGE,
	HAB_H_ARMOR,
	HAB_H_TCOMBO,

	HAB_Z_HEALTH,
	HAB_Z_SPEED,
	HAB_Z_GRAVITY,
	HAB_Z_DAMAGE,
	HAB_Z_RESISTANCE_FIRE, // COMPLETAR
	HAB_Z_RESISTANCE_FROST, // COMPLETAR

	HAB_S_STATS_BASE,
	HAB_S_DAMAGE,
	HAB_S_SPEED_WEAPON, // COMPLETAR
	HAB_S_EXTRA_BOMB, // COMPLETAR
	HAB_S_EXTRA_IMMUNITY, // COMPLETAR

	HAB_N_STATS_BASE,
	HAB_N_DAMAGE,
	HAB_N_BAZOOKA, // COMPLETAR

	HAB_E_DURATION_FLARE_BUBBLE,
	HAB_E_DURATION_MADNESS, // COMPLETAR
	HAB_E_DURATION_COMBO,
	HAB_E_COMBO_WESKER,
	HAB_E_COMBO_SNIPER,

	HAB_L_MULT_AMMOPACKS,
	HAB_L_MULT_COMBO,
	HAB_L_VIGOR,
	HAB_L_RESPAWN
};

enum _:structIdAchievementClasses {
	ACHIEVEMENT_CLASS_HUMAN = 0,
	ACHIEVEMENT_CLASS_ZOMBIE,
	ACHIEVEMENT_CLASS_MODES,
	ACHIEVEMENT_CLASS_OTHERS,
	ACHIEVEMENT_CLASS_BETA,
	ACHIEVEMENT_CLASS_FIRST,
	ACHIEVEMENT_CLASS_WEAPONS,
	ACHIEVEMENT_CLASS_EI,
	ACHIEVEMENT_CLASS_NAVIDAD
};

enum _:structIdAchievements {
	BETA_TESTER = 0, SUPER_BETA_TESTER, CUENTA_PAR, CUENTA_IMPAR,
	LA_MEJOR_OPCION, UNA_DE_LAS_MEJORES, MI_PREFERIDA, LA_MEJOR,
	PRIMERO_LA_MEJOR_OPCION, PRIMERO_UNA_DE_LAS_MEJORES, PRIMERO_MI_PREFERIDA, PRIMERO_LA_MEJOR,
	LA_MEJOR_OPCION_x5, UNA_DE_LAS_MEJORES_x5, MI_PREFERIDA_x5, LA_MEJOR_x5,
	LA_MEJOR_OPCION_x10, UNA_DE_LAS_MEJORES_x10, MI_PREFERIDA_x10, LA_MEJOR_x10,
	LA_MEJOR_OPCION_x15, UNA_DE_LAS_MEJORES_x15, MI_PREFERIDA_x15, LA_MEJOR_x15,
	LA_MEJOR_OPCION_x20, UNA_DE_LAS_MEJORES_x20, MI_PREFERIDA_x20, LA_MEJOR_x20,
	BOMBA_FALLIDA, VIRUS,
	ENTRENANDO, ESTOY_MUY_SOLO, FOREVER_ALONE, CREO_QUE_TENGO_UN_PROBLEMA, SOLO_EL_ZP_ME_ENTIENDE,
	LOS_PRIMEROS, VAMOS_POR_MAS, EXPERTO_EN_LOGROS, THIS_IS_SPARTA,
	SOY_DORADO, QUE_SUERTE, PRIMERO_QUE_SUERTE,
	LIDER_EN_CABEZAS, AGUJEREANDO_CABEZAS, MORTIFICANDO_ZOMBIES, CABEZAS_ZOMBIES,
	ZOMBIES_x100, ZOMBIES_x500, ZOMBIES_x1000, ZOMBIES_x2500, ZOMBIES_x5000, ZOMBIES_x10K, ZOMBIES_x25K, ZOMBIES_x50K, ZOMBIES_x100K, ZOMBIES_x250K, ZOMBIES_x500K, ZOMBIES_x1M, ZOMBIES_x5M,
	MIRA_MI_DANIO, MAS_Y_MAS_DANIO, LLEGUE_AL_MILLON, MI_DANIO_CRECE, MI_DANIO_CRECE_Y_CRECE, VAMOS_POR_LOS_50_MILLONES, CONTADOR_DE_DANIOS, YA_PERDI_LA_CUENTA, MI_DANIO_ES_CATASTROFICO, MI_DANIO_ES_NUCLEAR, MUCHOS_NUMEROS, SE_ME_BUGUEO_EL_DANIO, ME_ABURRO, NO_SE_LEER_ESTE_NUMERO,
	MI_CUCHILLO_ES_ROJO, AFILANDO_MI_CUCHILLO, ACUCHILLANDO, ME_ENCANTAN_LAS_TRIPAS, HUMMILACION, CLAVO_QUE_TE_CLAVO_LA_SOMBRILLA, ENTRA_CUCHILLO_SALEN_LAS_TRIPAS, HUMILIATION_DEFEAT, CUCHILLO_DE_COCINA, CUCHILLO_PARA_PIZZA, YOCUCHI,
	CABEZITA, A_PLENO, ROMPIENDO_CABEZAS, ABRIENDO_CEREBROS, PERFORANDO, DESCOCANDO, ROMPECRANEOS, DUCK_HUNT, AIMBOT,
	VINCULADO, HUMANOS_x100, HUMANOS_x500, HUMANOS_x1000, HUMANOS_x2500, HUMANOS_x5000, HUMANOS_x10K, HUMANOS_x25K, HUMANOS_x50K, HUMANOS_x100K, HUMANOS_x250K, HUMANOS_x500K, HUMANOS_x1M, HUMANOS_x5M,
	SACANDO_PROTECCION, ESO_NO_TE_SIRVE_DE_NADA, NO_ES_UN_PROBLEMA_PARA_MI, SIN_DEFENSAS, DESGARRANDO_CHALECO, TOTALMENTE_INDEFENSO,
	Y_LA_LIMPIEZA, YO_USO_CLEAR_ZOMBIE, ANTIDOTO_PARA_TODOS,
	PENSANDOLO_BIEN, YO_NO_FUI, YO_FUI,
	CRATER_SANGRIENTO, LA_EXPLOSION_NO_MATA, LA_EXPLOSION_SI_MATA,
	MA_KILL_Z_x5, MA_KILL_H_x5, MA_KILL_N_x2, MA_KILL_S_x2, MA_KILL_AGAIN_H, MA_KILL_AGAIN_Z, MA_WIN_H, MA_WIN_Z, MA_KILL_ALL_ZOMBIES, MA_KILL_ALL_HUMANS,
	GG_WIN_x1, GG_WIN_x10, GG_ALMOST_WIN, GG_HEADSHOTS_x20, GG_HEADSHOTS_x30, GG_HEADSHOTS_x40, GG_WIN_UNIQUE, GG_WIN_BY_FAR, GG_FAST_WIN, GG_WIN_CONSECUTIVE,
	COMBO_PERFECT, COMBO_HOLY_SHIT, COMBO_GODLIKE, COMBO_LUDICROUS_KILL, COMBO_MONSTER_KILL,
	COMBO_PERFECT_ZOMBIE, COMBO_HOLY_SHIT_ZOMBIE, COMBO_GODLIKE_ZOMBIE, COMBO_LUDICROUS_KILL_ZOMBIE, COMBO_MONSTER_KILL_ZOMBIE,
	VISION_NOCTURNA_x10, BALAS_INFINITAS_x10, PRESICION_PERFECTA_x10, BOMBA_DE_ANIQUILACION_x10, BOMBA_PIPE_x10, BOMBA_ANTIDOTO_x10, ANTIDOTO_x10, FURIA_x10, BOMBA_DE_INFECCION_x10, REDUCCION_x10,
	VISION_NOCTURNA_x50, BALAS_INFINITAS_x50, PRESICION_PERFECTA_x50, BOMBA_DE_ANIQUILACION_x50, BOMBA_PIPE_x50, BOMBA_ANTIDOTO_x50, ANTIDOTO_x50, FURIA_x50, BOMBA_DE_INFECCION_x50, REDUCCION_x50,
	VISION_NOCTURNA_x100, BALAS_INFINITAS_x100, PRESICION_PERFECTA_x100, BOMBA_DE_ANIQUILACION_x100, BOMBA_PIPE_x100, BOMBA_ANTIDOTO_x100, ANTIDOTO_x100, FURIA_x100, BOMBA_DE_INFECCION_x100, REDUCCION_x100,
	ITEMS_EXTRAS_x10, ITEMS_EXTRAS_x50, ITEMS_EXTRAS_x100, ITEMS_EXTRAS_x500, ITEMS_EXTRAS_x1000, ITEMS_EXTRAS_x5000,
	RESIDENT_EVIL, VOS_NO_PASAS, MI_DEAGLE_Y_YO, L_INTACTO, NO_ME_HACE_FALTA, DK_BUGUEADA,
	HEAD_100_RED, HEAD_75_GREEN, HEAD_50_BLUE, HEAD_25_YELLOW, CINCO_DE_LAS_BLANCAS, COLORIDO, BAD_LUCKY_BRIAN,
	ARE_YOU_FUCKING_KIDDING_ME, YA_DE_ZOMBIE,
	ANIQUILA_ANIQUILADOR, NO_LA_NECESITO, EL_VERDULERO, BAN_LOCAL,
	GIFT_1, GIFT_25, GIFT_50, GIFT_100, GIFT_200, GIFT_500, GIFT_1000, PRIMERO_GIFT_10, PRIMERO_GIFT_100,
	SURVIVOR_NORMAL, SURVIVOR_NIGHTMARE, SURVIVOR_SUICIDAL, SURVIVOR_HELL,
	NEMESIS_NORMAL, NEMESIS_NIGHTMARE, NEMESIS_SUICIDAL, NEMESIS_HELL
};

enum _:structIdHats {
	HAT_NONE = 0,
	HAT_ANGEL,
	HAT_AWESOME,
	HAT_DEVIL,
	HAT_EARTH,
	HAT_GOLD_HEAD,
	HAT_HALLOWEEN, // COMPLETAR
	HAT_NAVID, // COMPLETAR
	HAT_HOOD,
	HAT_JACKOLANTERN,
	HAT_JAMACA,
	HAT_PSYCHO,
	HAT_SASHA,
	HAT_SCREAM,
	HAT_SPARTAN,
	HAT_SUPER_MAN,
	HAT_TYNO,
	HAT_VIKING,
	HAT_ZIPPY
};

enum _:structIdAmuletCustoms {
	acHealth = 0,
	acSpeed,
	acGravity,
	acDamage,
	Float:acMultAmmoPacks
};

enum _:structIdArtifactsClasses {
	ARTIFACT_CLASS_RING = 0,
	ARTIFACT_CLASS_NECKLASE,
	ARTIFACT_CLASS_BRACELET
};

enum _:structIdArtifacts {
	ARTIFACT_RING_EXTRA_ITEM_COST = 0,
	ARTIFACT_RING_AMMOPACKS,
	ARTIFACT_RING_COMBO,
	ARTIFACT_NECKLASE_FIRE,
	ARTIFACT_NECKLASE_FROST,
	ARTIFACT_NECKLASE_DAMAGE,
	ARTIFACT_BRACELET_AMMOPACKS,
	ARTIFACT_BRACELET_COMBO,
	ARTIFACT_BRACELET_POINTS
};

enum _:structIdMasterys {
	MASTERY_NONE = 0,
	MASTERY_MORNING,
	MASTERY_NIGHT
};

enum _:structIdHeadZombies {
	HEADZOMBIE_RED = 0, // Ammo Packs
	HEADZOMBIE_GREEN, // Levels
	HEADZOMBIE_BLUE, // Items Extras
	HEADZOMBIE_YELLOW, // pH - pZ - pF
	HEADZOMBIE_WHITE // Modes
};

enum _:structIdClanPerks {
	CLAN_PERK_COMBO = 0,
	CLAN_PERK_MULTIPLE_COMBO
};

enum _:structIdColorTypes {
	COLOR_TYPE_HUD = 0,
	COLOR_TYPE_NVISION,
	COLOR_TYPE_FLARE,
	COLOR_TYPE_CLAN_GLOW
};

enum _:structIdHudTypes {
	HUD_TYPE_GENERAL = 0,
	HUD_TYPE_COMBO,
	HUD_TYPE_CLAN_COMBO
};

enum _:structIdTimePlayed {
	TIME_MIN = 0,
	TIME_HOUR,
	TIME_DAY
};

enum _:structLongJump {
	bool:longJump__Enabled,
	Float:longJump__Force,
	Float:longJump__Height,
	Float:longJump__Cooldown,
	Float:longJump__NextTime,
	Float:longJump__KillBeamTime,	
};

enum _:structClasses {
	TeamName:class__Team,
	class__Name[24],
	class__PlayerModel[32],
	class__PlayerModelDefaultHitZones,
	Float:class__HealthBase,
	Float:class__Speed,
	Float:class__Gravity,
	bool:class__Footsteps,
	Float:class__VelModFlinch,
	Float:class__VelModLargeFlinch
};

enum _:structPlayerSounds {
	Array:playerSound__Sounds[MAX_PL_PAIN_SOUNDS]
};

enum _:structModes {
	modeEnabled,
	modeName[24],
	modeChance,
	modeMinAlives,
	modeRoundTime,
	bool:modeChangeClass,
	bool:modeRespawn
};

enum _:structWeapons {
	WeaponIdType:weaponId,
	weaponEnt[54],
	weaponName[32]
};

enum _:structGrenadeWeapons {
	grenadeWeaponName[64],
	grenadeWeaponHeAmount,
	grenadeWeaponFbAmount,
	grenadeWeaponSgAmount,
	grenadeWeaponDrug,
	grenadeWeaponSupernova,
	grenadeWeaponBubble,
	grenadeWeaponevelTotal
};

enum _:structExtraItems {
	extraItemName[32],
	extraItemCost,
	extraItemLevelTotal,
	extraItemLimitUser,
	extraItemClass
};

enum _:structHumanClasses {
	humanClassName[32],
	humanClassPlayerModel[32],
	humanClassHealthBase,
	Float:humanClassSpeed,
	Float:humanClassGravity,
	humanClassArmor,
	humanClassLevelTotal
};

enum _:structZombieClasses {
	zombieClassName[32],
	zombieClassInfo[64],
	zombieClassPlayerModel[32],
	zombieClassMelee[128],
	zombieClassHealthBase,
	Float:zombieClassSpeed,
	Float:zombieClassGravity,
	zombieClassLevelTotal
};

enum _:structDiffs {
	diffNameMay[24],
	diffNameMin[24],
	diffInfo[128],
	Float:diffHealth,
	Float:diffSpeed
};

enum _:structPoints {
	pointNameMin[24],
	pointNameMay[24],
	pointNameShort[24],
	pointCost
}

enum _:structHabsClasses {
	habClassName[32],
	habClassPointName[32],
	habClassPointNameShort[16],
	habClassPointId
};

enum _:structHabs {
	habEnabled,
	habName[32],
	habValue,
	habCost,
	habMaxLevel,
	habClass
};

enum _:structAchievements {
	achievementEnabled,
	achievementName[64],
	achievementInfo[191],
	achievementReward,
	achievementUsersNeedP,
	achievementUsersNeedA,
	achievementClass
};

enum _:structHats {
	hatName[32],
	hatModel[128],
	hatDesc[192],
	hatDescExtra[192],
	hatUpgrade1, // Vida
	hatUpgrade2, // Velocidad
	hatUpgrade3, // Gravedad
	hatUpgrade4, // Daño
	Float:hatUpgrade5, // Mult APs
	hatUpgrade6, // Respawn Humano
	hatUpgrade7 // Descuento de Items
};

enum _:structArtifacts {
	artifactName[32],
	artifactCost,
	artifactClass
};

enum _:structClans {
	clanId,
	clanName[16],
	clanSince,
	clanDeposit,
	clanKillHmDone,
	clanKillZmDone,
	clanInfectDone,
	clanVictory,
	clanVictoryConsec,
	clanVictoryConsecHistory,
	clanChampion,
	clanRank,
	clanCountMembers,
	clanCountOnlineMembers,
	clanHumans
};

enum _:structClansMembers {
	clanMemberId,
	clanMemberName[33],
	clanMemberOwner,
	clanMemberSinceDay,
	clanMemberSinceHour,
	clanMemberSinceMinute,
	clanMemberLastTimeDay,
	clanMemberLastTimeHour,
	clanMemberLastTimeMinute,
	clanMemberTimePlayed[32],
	clanMemberLevelTotal
};

enum _:structClanPerks {
	clanPerkName[32],
	clanPerkDesc[128],
	clanPerkCost
};

enum _:structColors {
	colorName[16],
	colorRed,
	colorGreen,
	colorBlue
};

enum _:structCombos {
	comboNeed,
	comboColorRed,
	comboColorGreen,
	comboColorBlue,
	comboMessage[32]
};

new const __IMMUTABLE_CVARS[][][] = {
	{"mp_limitteams", "0"},
	{"mp_autoteambalance", "0"},
	{"mp_round_infinite", "b"},
	{"mp_roundover", "1"},
	{"mp_refill_bpammo_weapons", "3"},
	{"mp_falldamage", "0"}
};

new const __PRESTIGE_LETTERS[MAX_PRESTIGE][] = {"Z", "Y", "X", "W", "V", "U", "T", "S", "R", "Q", "P", "O", "Ñ", "N", "M", "L", "K", "J", "I", "H", "G", "F", "E", "D", "C", "B", "A"};

new const __CLASSES[structIdClasses][structClasses] = {
	{TEAM_CT, "Humana", "sas", true, 0.0, 0.0, 1.0, true, 0.5, 0.65},
	{TEAM_TERRORIST, "Zombie", "zombie_source", false, 0.0, 0.0, 1.0, false, 0.5, 0.65},

	{TEAM_CT, "Survivor", "dg-zp_survivor_02b", true, 100.0, 250.0, 1.0, true, 0.5, 0.65},
	{TEAM_CT, "Wesker", "dg-zp_wesker_00", true, 80.0, 280.0, 0.8, true, 0.5, 0.65},
	{TEAM_CT, "Sniper", "dg-zp_sniper_00_f", true, 275.0, 300.0, 0.75, true, 0.5, 0.65},

	{TEAM_TERRORIST, "Nemesis", "dg-zp_nemesis_03b", false, 50000.0, 300.0, 0.5, false, 0.5, 0.65},
	{TEAM_TERRORIST, "Assassin", "dg-zp_assassin_00", false, 5000.0, 500.0, 0.5, false, 0.5, 0.65},
	{TEAM_TERRORIST, "Grunt", "dg-zp_grunt_00", false, 1.0, 500.0, 0.5, false, 0.5, 0.65}
};

new const __MODES[structIdModes][structModes] = { // Enabled - Name - Chance - MinAlives - RoundTime - ChangeClass - modeRespawn
	{0, "", 0, 0, 0, false, false},
	{1, "PRIMER ZOMBIE", 1, 4, 0, true, true},
	{1, "SWARM", 10, 4, 0, false, false},
	{1, "INFECCIÓN MÚLTIPLE", 5, 12, 0, true, true},
	{1, "PLAGUE", 14, 18, 0, false, false},
	{1, "SYNAPSIS", 16, 18, 0, false, false},
	{1, "ARMAGEDDON", 40, 24, 0, false, false},
	{1, "MEGA ARMAGEDDON", 999, 24, 0, false, false},
	{1, "GUNGAME", 999, 24, 0, false, true},
	{1, "MEGA GUNGAME", 999, 24, 0, false, true},
	{1, "DUELO FINAL", 45, 24, 0, false, false},
	{1, "SURVIVOR", 20, 8, 0, false, false},
	{1, "WESKER", 21, 8, 0, false, false},
	{1, "SNIPER", 22, 24, 0, false, false},
	{1, "NEMESIS", 23, 8, 0, false, false},
	{1, "ASSASSIN", 24, 8, 0, false, false},
	{1, "GRUNT", 25, 24, 0, false, false}
};

new const __PRIMARY_WEAPONS[][structWeapons] = {
	{WEAPON_MAC10, "weapon_mac10", "Ingram MAC-10"},
	{WEAPON_TMP, "weapon_tmp", "Schmidt TMP"},
	{WEAPON_M3, "weapon_m3", "M3 Super 90"},
	{WEAPON_UMP45, "weapon_ump45", "UMP 45"},
	{WEAPON_XM1014, "weapon_xm1014", "XM1014 M4"},
	{WEAPON_P90, "weapon_p90", "ES P90"},
	{WEAPON_MP5N, "weapon_mp5navy", "MP5 Navy"},
	{WEAPON_FAMAS, "weapon_famas", "Famas"},
	{WEAPON_GALIL, "weapon_galil", "IMI Galil"},
	{WEAPON_AUG, "weapon_aug", "Steyr AUG A1"},
	{WEAPON_SG552, "weapon_sg552", "SG-552 Commando"},
	{WEAPON_AK47, "weapon_ak47", "AK-47 Kalashnikov"},
	{WEAPON_M4A1, "weapon_m4a1", "M4A1 Carbine"}
};

new const __SECONDARY_WEAPONS[][structWeapons] = {
	{WEAPON_GLOCK18, "weapon_glock18", "Glock 18C"},
	{WEAPON_FIVESEVEN, "weapon_fiveseven", "FiveseveN"},
	{WEAPON_P228, "weapon_p228", "P228 Compact"},
	{WEAPON_USP, "weapon_usp", "USP .45 ACP Tactical"},
	{WEAPON_ELITE, "weapon_elite", "Dual Elite Berettas"},
	{WEAPON_DEAGLE, "weapon_deagle", "Desert Eagle .50 AE"}
};

new const __CUATERNARY_WEAPONS[][structGrenadeWeapons] = {
	{"Fuego - Hielo - Luz", 1, 1, 1, 0, 0, 0, 1},
	{"Fuego x2 - Hielo - Luz", 2, 1, 1, 0, 0, 0, 301},
	{"Hielo x2 - Luz", 0, 2, 1, 0, 0, 0, 901},
	{"Fuego x3", 3, 0, 0, 0, 0, 0, 1501},
	
	{"Droga - Hielo - Luz", 1, 1, 1, 1, 0, 0, 3500},
	{"Droga x2 - Luz", 2, 0, 1, 1, 0, 0, 6500},
	{"Droga x2 - Hielo x2", 2, 2, 0, 1, 0, 0, 10000},
	{"Droga x2 - Hielo x2 - Luz x2", 2, 2, 2, 1, 0, 0, 15301},

	{"Droga x2 - Supernova - Luz x2", 2, 1, 2, 1, 1, 0, 22501},
	{"Supernova x2 - Luz", 0, 2, 1, 1, 1, 0, 24501},
	{"Droga - Supernova x2 - Luz", 1, 2, 1, 1, 1, 0, 30601},
	{"Droga x2 - Supernova x3 - Luz", 2, 3, 1, 1, 1, 0, 40000},
	
	{"Droga - Supernova - Bubble", 1, 1, 1, 1, 1, 1, 50000},
	{"Bubble x2", 0, 0, 2, 1, 1, 1, 75000},
	{"Droga x2 - Supernova x2 - Bubble", 2, 2, 1, 1, 1, 1, 100000},
	{"Droga x3 - Supernova x2 - Bubble x2", 3, 2, 2, 1, 1, 1, 250000}
};

new const __EXTRA_ITEMS[structIdExtraItems][structExtraItems] = {
	{"Visión nocturna", 25, 1, 0, CLASS_HUMAN},
	{"Balas Infinitas", 100, 1, 0, CLASS_HUMAN},
	{"Precisión Perfecta", 100, 1, 0, CLASS_HUMAN},
	{"Bomba Aniquiladora", 250, 1, 1, CLASS_HUMAN},
	{"Bomba Pipe", 250, 1, 1, CLASS_HUMAN},
	{"Bomba Antídoto", 250, 1, 1, CLASS_HUMAN},

	{"Antídoto", 30, 1, 2, CLASS_ZOMBIE},
	{"Furia Zombie", 40, 1, 3, CLASS_ZOMBIE},
	{"Bomba de Infección", 50, 1, 1, CLASS_ZOMBIE},
	{"Reducción de daño", 75, 1, 1, CLASS_ZOMBIE}
};

new const __HUMAN_CLASSES[][structHumanClasses] = {
	{"Soldado E1", "sas", 100, 240.0, 1.0, 0, 1},
	{"Soldado E2", "sas", 114, 241.0, 0.95, 2, 301},
	{"Soldado de Primera", "sas", 122, 242.0, 0.93, 4, 601},
	{"Especialista", "sas", 127, 243.0, 0.9, 6, 901},
	{"Cabo", "sas", 141, 245.0, 0.88, 8, 1201},
	{"Sargento", "sas", 145, 246.0, 0.87, 10, 1501},
	{"Sargento de Segunda Clase", "sas", 147, 247.0, 0.86, 13, 1801},
	{"Sargento de Primera Clase", "sas", 155, 248.0, 0.85, 16, 2401},
	{"Sargento Maestro", "sas", 162, 249.0, 0.84, 19, 3001},
	{"Sargento Primero", "sas", 170, 250.0, 0.83, 22, 3601},
	{"Sargento Mayor", "sas", 179, 251.0, 0.82, 25, 4201},
	{"Sargento Mayor de Comando", "sas", 191, 252.0, 0.81, 30, 5101},
	{"Sargento Mayor del Ejército", "sas", 205, 253.0, 0.79, 35, 6001},
	{"Oficial Técnico", "sas", 212, 254.0, 0.78, 40, 6901},
	{"Cadete", "sas", 225, 255.0, 0.77, 45, 7801},
	{"Subteniente", "sas", 231, 255.0, 0.76, 50, 8701},
	{"Suboficial Mayor", "sas", 236, 256.0, 0.75, 60, 9901},
	{"Teniente", "sas", 242, 256.0, 0.74, 70, 11101},
	{"Capitán", "sas", 248, 257.0, 0.73, 80, 12301},
	{"Mayor", "sas", 253, 257.0, 0.72, 90, 13501},
	{"Comandante", "sas", 259, 258.0, 0.71, 100, 14701},
	{"Comandante Mayor", "sas", 264, 258.0, 0.69, 120, 16201},
	{"Teniente Coronel", "sas", 270, 259.0, 0.68, 140, 17701},
	{"Coronel", "sas", 277, 260.0, 0.67, 160, 19201},
	{"General de Brigada", "sas", 284, 262.0, 0.66, 180, 20701},
	{"General de División", "sas", 296, 264.0, 0.65, 210, 22501},
	{"Teniente General", "sas", 302, 266.0, 0.64, 240, 24301},
	{"General", "sas", 308, 268.0, 0.63, 270, 26101},
	{"General del Ejército", "sas", 315, 270.0, 0.6, 300, 27901}
};

new const __ZOMBIE_CLASSES[structIdZombieClasses][structZombieClasses] = {
	{"Mooly", "Estadísticas normales", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 50000, 250.0, 1.0, 1},

	{"Hat", "\y+\wVida", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 250000, 250.0, 1.0, 15301},
	{"Miiak", "\y+\wVelocidad", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 50000, 275.0, 1.0, 15301},
	{"Paloord", "\y+\wGravedad", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 50000, 250.0, 0.75, 15301},

	{"OC-3", "Infecta al contacto con los Humanos", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 100000, 255.0, 0.9, 30601}, // COMPLETAR - [Touch + No tiene manos]
	{"Karko", "Doble salto", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 100000, 255.0, 0.9, 30601},
	{"Seffel", "Anti Bomba de Fuego", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 100000, 255.0, 0.9, 30601}, // COMPLETAR

	{"Boorm", "Se cura un \y+\w40% de su Vida Máxima \y[G]\w", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 200000, 260.0, 0.8, 45901}, // COMPLETAR
	{"Vylk", "Tiene una Furia Zombie gratis", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 200000, 260.0, 0.8, 45901}, // COMPLETAR
	{"Rewttem", "Anti Bomba de Hielo / Supernova", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 200000, 260.0, 0.8, 45901}, // COMPLETAR

	{"Lacco", "Al morir, genera una explosión que infecta a su alrededor", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 325000, 265.0, 0.7, 61201}, // COMPLETAR
	{"Joffe", "Tiene una Bomba de Infección gratis", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 325000, 265.0, 0.7, 61201}, // COMPLETAR
	{"Shug-im", "Anti Campo de Fuerza", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 325000, 265.0, 0.7, 61201}, // COMPLETAR

	{"Neiv", "-", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 500000, 270.0, 0.6, 76501}, // COMPLETAR
	{"Kankis", "Tiene una Reducción de Daño gratis", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 500000, 270.0, 0.6, 76501}, // COMPLETAR
	{"Raxoi", "Anti Bomba de Droga", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 500000, 270.0, 0.6, 76501}, // COMPLETAR

	{"Rev", "-", "zombie_source", "models/zombie_plague/v_knife_zombie.mdl", 1000000, 275.0, 0.5, 91801} // COMPLETAR
};

new const __DIFFS_CLASSES[structIdDiffsClasses][] = {
	"Survivor",
	"Nemesis"
};

new const __DIFFS[structIdDiffsClasses][structIdDiffs][structDiffs] = {
	{ // Survivor
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"NIGHTMARE", "Nightmare", "Vida: \r-20%\w | Velocidad: \r-10%\w", 0.8, 0.9},
		{"SUICIDAL", "Suicidal", "Vida: \r-40%\w | Velocidad: \r-20%\w", 0.6, 0.8},
		{"HELL", "Hell", "Vida: \r-60%\w | Velocidad: \r-30%\w | Sin Inmunidad", 0.4, 0.7}
	}, { // Nemesis
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"NIGHTMARE", "Nightmare", "Vida: \r-20%\w | Velocidad: \r-10%\w", 0.8, 0.9},
		{"SUICIDAL", "Suicidal", "Vida: \r-40%\w | Velocidad: \r-20%\w", 0.6, 0.8},
		{"HELL", "Hell", "Vida: \r-60%\w | Velocidad: \r-30%\w | Sin Bazooka", 0.4, 0.7}
	}
};

new const __POINTS[structIdPoints][structPoints] = {
	{"", "", "", 0},
	{"puntos humanos", "Puntos Humanos", "pH", 2},
	{"puntos zombies", "Puntos Zombies", "pZ", 2},
	{"puntos de legado", "Puntos de Legado", "pL", 3},
	{"puntos de fragmento", "Puntos de Fragmento", "pF", 1},
	{"diamantes", "Diamantes", " DIAMANTES", 5}
};

new const __HABS_CLASSES[structIdHabsClasses][structHabsClasses] = {
	{"Humanas", "Puntos humanos", "pH", P_HUMAN},
	{"Zombies", "Puntos zombies", "pZ", P_ZOMBIE},
	{"Survivor", "Puntos de Legado", "pL", P_LEGACY},
	{"Nemesis", "Puntos de Legado", "pL", P_LEGACY},
	{"Extras", "Puntos de Fragmento", "pF", P_FRAGMENT},
	{"Legendarias", "Diamantes", "DIAMANTES", P_DIAMOND}
};

new const __HABS[structIdHabs][structHabs] = { // Enabled - Name - Value - Cost - MaxLevel - Class
	{1, "Vida", 5, 6, 20, HAB_CLASS_HUMAN},
	{1, "Velocidad", 1, 6, 50, HAB_CLASS_HUMAN}, // (0.5 x Hab)
	{1, "Gravedad", 1, 6, 50, HAB_CLASS_HUMAN}, // (0.01 x Hab)
	{1, "Daño", 10, 6, 100, HAB_CLASS_HUMAN},
	{1, "Chaleco", 4, 6, 200, HAB_CLASS_HUMAN},
	{1, "T-Combo", 1, 150, 5, HAB_CLASS_HUMAN},

	{1, "Vida", 25000, 6, 100, HAB_CLASS_ZOMBIE},
	{1, "Velocidad", 1, 6, 50, HAB_CLASS_ZOMBIE}, // (0.5 x Hab)
	{1, "Gravedad", 1, 6, 50, HAB_CLASS_ZOMBIE}, // (0.01 x Hab)
	{1, "Daño", 5, 6, 20, HAB_CLASS_ZOMBIE},
	{1, "Resistencia al fuego", 0, 24, 3, HAB_CLASS_ZOMBIE},
	{1, "Resistencia al hielo", 0, 24, 3, HAB_CLASS_ZOMBIE},

	{1, "Estadística base", 10, 12, 10, HAB_CLASS_SURVIVOR},
	{1, "Daño", 200, 24, 10, HAB_CLASS_SURVIVOR},
	{1, "Velocidad de disparo", 0, 18, 5, HAB_CLASS_SURVIVOR},
	{1, "Bomba extra", 0, 75, 1, HAB_CLASS_SURVIVOR},
	{1, "Duración de Inmunidad", 0, 50, 1, HAB_CLASS_SURVIVOR},

	{1, "Estadística base", 10, 12, 10, HAB_CLASS_NEMESIS},
	{1, "Daño", 10, 24, 10, HAB_CLASS_NEMESIS},
	{1, "Bazooka mejorada", 0, 150, 1, HAB_CLASS_NEMESIS},

	{1, "Duración de Bubble", 10, 100, 6, HAB_CLASS_EXTRAS},
	{1, "Duración de Furia Zombie", 1, 150, 4, HAB_CLASS_EXTRAS}, // (0.5 x Hab)
	{1, "Duración de Combo", 1, 200, 5, HAB_CLASS_EXTRAS}, // (0.5 x Hab)
	{1, "Combo: Wesker", 1, 250, 1, HAB_CLASS_EXTRAS},
	{1, "Combo: Sniper", 1, 250, 1, HAB_CLASS_EXTRAS},

	{1, "Multiplicador de Ammo Packs", 1, 25, 10, HAB_CLASS_LEGENDARY}, // (0.2 x Hab)
	{1, "Multiplicador de Combo", 1, 75, 5, HAB_CLASS_LEGENDARY},
	{1, "Vigor", 10, 50, 10, HAB_CLASS_LEGENDARY},
	{1, "Respawn humano", 4, 15, 5, HAB_CLASS_LEGENDARY}
};

new const __ACHIEVEMENTS_CLASSES[structIdAchievementClasses][] =  {
	"Humanos", "Zombies", "Modos", "Otros", "Beta", "Primeros", "Armas", "Items Extras", "Navidad"
};

new const __ACHIEVEMENTS[structIdAchievements][structAchievements] = {
	{1, "CUENTA PAR", "Tu numero de cuenta es par", 2, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "CUENTA IMPAR", "Tu numero de cuenta es impar", 2, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "LA MEJOR OPCIÓN", "Sube un arma al nivel 5", 5, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "UNA DE LAS MEJORES", "Sube un arma al nivel 10", 10, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "MI PREFERIDA", "Sube un arma al nivel 15", 15, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR", "Sube un arma al nivel 20", 20, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "PRIMERO: LA MEJOR OPCIÓN", "Primero del servidor en subir un arma al nivel 5", 5, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "PRIMERO: UNA DE LAS MEJORES", "Primero del servidor en subir un arma al nivel 10", 10, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "PRIMERO: MI PREFERIDA", "Primero del servidor en subir un arma al nivel 15", 15, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "PRIMERO: LA MEJOR", "Primero del servidor en subir un arma al nivel 20", 20, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "LA MEJOR OPCIÓN x5", "Sube cinco armas al nivel 5", 10, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "UNA DE LAS MEJORES x5", "Sube cinco armas al nivel 10", 20, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "MI PREFERIDA x5", "Sube cinco armas al nivel 15", 30, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR x5", "Sube cinco armas al nivel 20", 40, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR OPCIÓN x10", "Sube diez armas al nivel 5", 20, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "UNA DE LAS MEJORES x10", "Sube diez armas al nivel 10", 40, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "MI PREFERIDA x10", "Sube diez armas al nivel 15", 60, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR x10", "Sube diez armas al nivel 20", 80, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR OPCIÓN x15", "Sube quince armas al nivel 5", 40, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "UNA DE LAS MEJORES x15", "Sube quince armas al nivel 10", 80, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "MI PREFERIDA x15", "Sube quince armas al nivel 15", 120, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR x15", "Sube quince armas al nivel 20", 160, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR OPCIÓN x20", "Sube veinte armas al nivel 5", 80, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "UNA DE LAS MEJORES x20", "Sube veinte armas al nivel 10", 160, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "MI PREFERIDA x20", "Sube veinte armas al nivel 15", 240, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "LA MEJOR x20", "Sube veinte armas al nivel 20", 320, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{1, "BOMBA FALLIDA", "Has explotar una bomba de infección sin infectar a nadie", 5, 0, 20, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "VIRUS", "Infecta a 20 humanos en una misma ronda de INFECCIÓN sin morir, sin^nutilizar Furia Zombie ni Bomba de Infección", 10, 0, 20, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "ENTRENANDO", "Juega 1 día", 1, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "ESTOY MUY SOLO", "Juega 7 días", 7, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "FOREVER ALONE", "Juega 15 días", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "CREO QUE TENGO UN PROBLEMA", "Juega 30 días", 30, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "SOLO EL ZP ME ENTIENDE", "Juega 50 días", 50, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "LOS PRIMEROS", "Completa 25 logros", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "VAMOS POR MÁS", "Completa 75 logros", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "EXPERTO EN LOGROS", "Completa 150 logros", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "THIS IS SPARTA", "Completa 300 logros", 25, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "SOY DORADO", "Ser usuario VIP", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "QUE SUERTE", "Mata a un modo de cada tipo", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "PRIMERO: QUE SUERTE", "Primero del servidor en matar a un modo de cada tipo", 10, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "LÍDER EN CABEZAS", "Mata a 1.000 zombies con disparos en la cabeza", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "AGUJEREANDO CABEZAS", "Mata a 10.000 zombies con disparos en la cabeza", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MORTIFICANDO ZOMBIES", "Mata a 50.000 zombies con disparos en la cabeza", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "CABEZAS ZOMBIES", "Mata a 100.000 zombies con disparos en la cabeza", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "100 ZOMBIES", "Mata a 100 zombies", 1, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "500 ZOMBIES", "Mata a 500 zombies", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "1.000 ZOMBIES", "Mata a 1.000 zombies", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "2.500 ZOMBIES", "Mata a 2.500 zombies", 7, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "5.000 ZOMBIES", "Mata a 5.000 zombies", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "10.000 ZOMBIES", "Mata a 10.000 zombies", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "25.000 ZOMBIES", "Mata a 25.000 zombies", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "50.000 ZOMBIES", "Mata a 50.000 zombies", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "100.000 ZOMBIES", "Mata a 100.000 zombies", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "250.000 ZOMBIES", "Mata a 250.000 zombies", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "500.000 ZOMBIES", "Mata a 500.000 zombies", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "1.000.000 DE ZOMBIES", "Mata a 1.000.000 de zombies", 75, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "5.000.000 DE ZOMBIES", "Mata a 5.000.000 de zombies", 100, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MIRA MI DAÑO", "Realiza 100.000 de daño", 1, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MÁS Y MÁS DAÑO", "Realiza 500.000 de daño", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "LLEGUÉ AL MILLÓN", "Realiza 1.000.000 de daño", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MI DAÑO CRECE", "Realiza 5.000.000 de daño", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MI DAÑO CRECE Y CRECE", "Realiza 25.000.000 de daño", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "VAMOS POR LOS 50 MILLONES", "Realiza 50.000.000 de daño", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "CONTADOR DE DAÑOS", "Realiza 100.000.000 de daño", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "YA PERDÍ LA CUENTA", "Realiza 500.000.000 de daño", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MI DAÑO ES CATASTRÓFICO", "Realiza 1.000.000.000 de daño", 35, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MI DAÑO ES NUCLEAR", "Realiza 5.000.000.000 de daño", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MUCHOS NÚMEROS", "Realiza 20.000.000.000 de daño", 45, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "¿SE ME BUGUEO EL DAÑO? ... BAZINGA", "Realiza 50.000.000.000 de daño", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "ME ABURROOOOO", "Realiza 100.000.000.000 de daño", 75, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "NO SÉ LEER ESTE NÚMERO", "Realiza 214.748.364.800 de daño", 100, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "MI CUCHILLO ES ROJO", "Mata a un NEMESIS con cuchillo", 10, 10, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "AFILANDO MI CUCHILLO", "Mata a un zombie con cuchillo", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "ACUCHILLANDO", "Mata a 30 zombies con cuchillo", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "ME ENCANTAN LAS TRIPAS", "Mata a 50 zombies con cuchillo", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "HUMILLACIÓN", "Mata a 100 zombies con cuchillo", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "CLAVO QUE TE CLAVO LA SOMBRILLA", "Mata a 150 zombies con cuchillo", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "ENTRA CUCHILLO, SALEN LAS TRIPAS", "Mata a 200 zombies con cuchillo", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "HUMILIATION DEFEAT", "Mata a 250 zombies con cuchillo", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "CUCHILLO DE COCINA", "Mata a 500 zombies con cuchillo", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "CUCHILLO PARA PIZZA", "Mata a 1.000 zombies con cuchillo", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "YOCUCHI", "Mata a 5.000 zombies con cuchillo", 75, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "CABEZITA", "Realiza 5.000 disparos en la cabeza", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "A PLENO", "Realiza 15.000 disparos en la cabeza", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "ROMPIENDO CABEZAS", "Realiza 50.000 disparos en la cabeza", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "ABRIENDO CEREBROS", "Realiza 150.000 disparos en la cabeza", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "PERFORANDO", "Realiza 300.000 disparos en la cabeza", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "DESCOCANDO", "Realiza 500.000 disparos en la cabeza", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "ROMPECRANEOS", "Realiza 1.000.000 disparos en la cabeza", 35, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "DUCK HUNT", "Realiza 5.000.000 disparos en la cabeza", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "AIMBOT", "Realiza 10.000.000 disparos en la cabeza", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "VINCULADO", "Vincula tu cuenta del Zombie Plague con la del foro", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "100 HUMANOS", "Infecta a 100 humanos", 1, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "500 HUMANOS", "Infecta a 500 humanos", 2, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "1.000 HUMANOS", "Infecta a 1.000 humanos", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "2.500 HUMANOS", "Infecta a 2.500 humanos", 7, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "5.000 HUMANOS", "Infecta a 5.000 humanos", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "10.000 HUMANOS", "Infecta a 10.000 humanos", 15, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "25.000 HUMANOS", "Infecta a 25.000 humanos", 20, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "50.000 HUMANOS", "Infecta a 50.000 humanos", 25, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "100.000 HUMANOS", "Infecta a 100.000 humanos", 30, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "250.000 HUMANOS", "Infecta a 250.000 humanos", 40, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "500.000 HUMANOS", "Infecta a 500.000 humanos", 50, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "1.000.000 DE HUMANOS", "Infecta a 1.000.000 de humanos", 75, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "5.000.000 DE HUMANOS", "Infecta a 5.000.000 de humanos", 100, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "SACANDO PROTECCIÓN", "Desgarra 500 de chaleco humano", 2, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "ESO NO TE SIRVE DE NADA", "Desgarra 2.000 de chaleco humano", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "NO ES UN PROBLEMA PARA MI", "Desgarra 5.000 de chaleco humano", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "SIN DEFENSAS", "Desgarra 30.000 de chaleco humano", 15, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "DESGARRANDO CHALECO", "Desgarra 60.000 de chaleco humano", 20, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "TOTALMENTE INDEFENSO", "Desgarra 100.000 de chaleco humano", 25, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "¿Y LA LIMPIEZA?", "Has explotar una bomba de antidoto sin desinfectar a nadie", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "YO USO CLEAR ZOMBIE", "Has explotar una bomba antidoto y desinfecta a 12+ zombies", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "ANTIDOTO PARA TODOS", "Has explotar una bomba antidoto y desinfecta a 18+ zombies", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "PENSANDOLO BIEN...", "Utiliza dos furia zombie en un mismo mapa sin infectar a nadie", 5, 0, 10, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "YO NO FUI", "Infecta a 5 humanos sin morir con tu vida al máximo^nsin tener furia zombie activa y sin bomba", 10, 0, 15, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "YO FUI", "Utiliza dos furia zombie en una misma ronda e infecta a 15 humanos mientras duren sin bomba", 10, 0, 15, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "CRATER SANGRIENTO", "Gana el modo NEMESIS sin utilizar la bazooka", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "LA EXPLOSIÓN NO MATA", "Lanza la bazooka sin matar a nadie", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "LA EXPLOSIÓN SI MATA", "Mata +20 humanos con tu bazooka", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - ZOMBIES x5", "Mata a cinco zombies en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - HUMANOS x5", "Mata a cinco humanos en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - NEMESIS x2", "Mata a dos nemesis en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - SURVIVOR x2", "Mata a dos survivor en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - AL MISMO HUMANO", "Mata a un humano y luego vuelve a matar^nal mismo usuario cuando es survivor", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - AL MISMO ZOMBIE", "Mata a un zombie y luego vuelve a matar^nal mismo usuario cuando es nemesis", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - HUMANO GANADOR", "Sobrevive el modo Mega Armageddón siendo humano/survivor", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - ZOMBIE GANADOR", "Sobrevive el modo Mega Armageddón siendo zombie/nemesis", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - TODOS LOS ZOMBIES", "Consigue matar a todos los zombies sin que ningún humano muera", 20, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MA - TODOS LOS HUMANOS", "Consigue matar a todos los humanos sin que ningún zombie muera", 20, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - GANADOR x1", "Gana el modo GunGame", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - GANADOR x10", "Gana diez veces el modo GunGame", 50, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - CASI TE GANO", "Finaliza el GunGame en nivel 25 o 26", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - HEADSHOTS x20", "Mata a 20 usuarios con disparos en la cabeza en un mismo GunGame", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - HEADSHOTS x30", "Mata a 30 usuarios con disparos en la cabeza en un mismo GunGame", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - HEADSHOTS x40", "Mata a 40 usuarios con disparos en la cabeza en un mismo GunGame", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - ÚNICO", "Gana el modo GunGame siendo el único en nivel 26", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - GANADOR POR LEJOS", "Gana el modo GunGame sin que nadie esté en el nivel 25 o 26", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - GANADOR VELOZ", "Gana el modo GunGame en menos de dos minutos", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "GG - GANADOR CONSECUTIVO", "Gana el modo GunGame dos veces seguidas", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "COMBO: Perfect", "Realiza un combo: Perfect", 5, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO: Holy Shit", "Realiza un combo: Holy Shit", 10, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO: GodLike", "Realiza un combo: GodLike", 15, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO: Ludicrous Kill", "Realiza un combo: Ludicrous Kill", 20, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO: Monster Kill", "Realiza un combo: Monster Kill", 25, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO ZOMBIE: Perfect", "Realiza un combo zombie: Perfect", 10, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO ZOMBIE: Holy Shit", "Realiza un combo zombie: Holy Shit", 15, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO ZOMBIE: GodLike", "Realiza un combo zombie: GodLike", 20, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO ZOMBIE: Ludicrous Kill", "Realiza un combo zombie: Ludicrous Kill", 30, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO ZOMBIE: Monster Kill", "Realiza un combo zombie: Monster Kill", 50, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "VISIÓN NOCTURNA x10", "Compra 10 veces el item extra Visión Nocturna", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BALAS INFINITAS x10", "Compra 10 veces el item extra Balas Infinitas", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PRECISIÓN PERFECTA x10", "Compra 10 veces el item extra Precisión perfecta", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE ANIQUILACIÓN x10", "Compra 10 veces el item extra Bomba de Aniquilación", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA PIPE x10", "Compra 10 veces el item extra Bomba Molotov", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA ANTIDOTO x10", "Compra 10 veces el item extra Bomba Antidoto", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ANTIDOTO x10", "Compra 10 veces el item extra Antidoto", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "FURIA ZOMBIE x10", "Compra 10 veces el item extra Furia Zombie", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE INFECCIÓN x10", "Compra 10 veces el item extra Bomba de Infección", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "REDUCCIÓN DE DAÑO x10", "Compra 10 veces el item extra Reducción de daño", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "VISIÓN NOCTURNA x50", "Compra 50 veces el item extra Visión Nocturna", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BALAS INFINITAS x50", "Compra 50 veces el item extra Balas Infinitas", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PRECISIÓN PERFECTA x50", "Compra 50 veces el item extra Precisión perfecta", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE ANIQUILACIÓN x50", "Compra 50 veces el item extra Bomba de Aniquilación", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA PIPE x50", "Compra 50 veces el item extra Bomba Molotov", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA ANTIDOTO x50", "Compra 50 veces el item extra Bomba Antidoto", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ANTIDOTO x50", "Compra 50 veces el item extra Antidoto", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "FURIA ZOMBIE x50", "Compra 50 veces el item extra Furia Zombie", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE INFECCIÓN x50", "Compra 50 veces el item extra Bomba de Infección", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "REDUCCIÓN DE DAÑO x50", "Compra 50 veces el item extra Reducción de daño", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "VISIÓN NOCTURNA x100", "Compra 100 veces el item extra Visión Nocturna", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BALAS INFINITAS x100", "Compra 100 veces el item extra Balas Infinitas", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PRECISIÓN PERFECTA x100", "Compra 100 veces el item extra Precisión perfecta", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE ANIQUILACIÓN x100", "Compra 100 veces el item extra Bomba de Aniquilación", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA PIPE x100", "Compra 100 veces el item extra Bomba Molotov", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA ANTIDOTO x100", "Compra 100 veces el item extra Bomba Antidoto", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ANTIDOTO x100", "Compra 100 veces el item extra Antidoto", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "FURIA ZOMBIE x100", "Compra 100 veces el item extra Furia Zombie", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE INFECCIÓN x100", "Compra 100 veces el item extra Bomba de Infección", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "REDUCCIÓN DE DAÑO x100", "Compra 100 veces el item extra Reducción de daño", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ITEMS EXTRAS x10", "Compra 10 veces todos los items extras", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ITEMS EXTRAS x50", "Compra 50 veces todos los items extras", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ITEMS EXTRAS x100", "Compra 100 veces todos los items extras", 15, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ITEMS EXTRAS x500", "Compra 500 veces todos los items extras", 20, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ITEMS EXTRAS x1.000", "Compra 1.000 veces todos los items extras", 25, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ITEMS EXTRAS x5.000", "Compra 5.000 veces todos los items extras", 50, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "¡PUM, HEADSHOT!", "Mata a 10 zombies con disparos en la cabeza siendo WESKER", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "VOS NO PASAS", "Mata a un zombie con tu LASER", 5, 0, 15, ACHIEVEMENT_CLASS_MODES},
	{1, "MI DEAGLE Y YO", "Gana el modo WESKER", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "INTACTO", "Gana el modo WESKER sin recibir daño", 10, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NO ME HACE FALTA", "Utiliza los 3 LASER sin matar a nadie", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "DK BUGUEADA", "Finaliza el modo WEKSER sin haber realizado daño", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "100 AL ROJO", "Acumula 100 cabezas zombie rojas", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "¿75 AL VERDE?", "Acumula 75 cabezas zombie verdes", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "50 PITUFOS", "Acumula 50 cabezas zombie azules", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "25 Y SIGO", "Acumula 25 cabezas zombie amarillas", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "5 DE LAS BLANCAS", "Acumula 5 cabezas zombie blancas", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "COLORIDO", "Agarra cabezas zombies de todos los colores", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "BAD LUCK BRIAN", "Abre 10 cabezas zombies seguidas sin conseguir nada", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "¿ARE YOU FUCKING KIDDING ME?", "Consigue ser el PRIMER ZOMBIE", 5, 0, 15, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "¿YA DE ZOMBIE?", "Consigue ser el PRIMER ZOMBIE dos veces seguidas", 10, 0, 15, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "ANIQUILA ANIQUILADOR", "Lanza la bomba aniquilación sin matar a nadie", 5, 0, 15, ACHIEVEMENT_CLASS_MODES},
	{1, "NO LA NECESITO", "Has explotar la bomba de aniquilación sin matar a nadie", 5, 0, 15, ACHIEVEMENT_CLASS_HUMAN},
	{1, "EL VERDULERO", "Roba un tomate de la Verdulería en el mapa^n\yzm_kontrax_b5_buffed\w", 5, 0, 15, ACHIEVEMENT_CLASS_OTHERS},
	{1, "BAN LOCAL", "Mata a un miembro del Staff siendo zombie con cuchillo", 10, 0, 15, ACHIEVEMENT_CLASS_OTHERS},
	{1, "MI PRIMER REGALO", "Recoge un regalo", 1, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "ACUMULANDO", "Acumula 25 regalos", 5, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "MÁS REGALOS", "Acumula 50 regalos", 10, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "SANTAZOM", "Acumula 100 regalos", 15, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "YO SOY SANTA", "Acumula 200 regalos", 20, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "ME HE PORTADO MUY BIEN", "Acumula 500 regalos", 30, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "SABRÁS SI HAS SIDO BUENO", "Acumula 1000 regalos", 40, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "PRIMERO: DIEZ REGALOS", "Primero en acumular 10 regalos", 15, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "PRIMERO: SANTAZOM", "Primero en acumular 100 regalos", 30, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "SURVIVOR: NORMAL", "Gana el modo SURVIVOR en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SURVIVOR: NIGHTMARE", "Gana el modo SURVIVOR en dificultad NIGHTMARE", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SURVIVOR: SUICIDAL", "Gana el modo SURVIVOR en dificultad SUICIDAL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SURVIVOR: HELL", "Gana el modo SURVIVOR en dificultad HELL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS: PRINCIPIANTE", "Gana el modo NEMESIS en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS: NIGHTMARE", "Gana el modo NEMESIS en dificultad NIGHTMARE", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS: SUICIDAL", "Gana el modo NEMESIS en dificultad SUICIDAL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS: HELL", "Gana el modo NEMESIS en dificultad HELL", 20, 12, 0, ACHIEVEMENT_CLASS_MODES}
};

new const __HATS[structIdHats][structHats] = { // Vida - Velocidad - Gravedad - Daño - APs - Respawn - Items
	{"Ninguno", "models/v_usp.mdl", "", "", 0, 0, 0, 0, 0.0, 0, 0},
	{"Angel", "models/dg/zp6/hats/angel2.mdl", "Mata a 2.500 zombies", "", 2, 1, 1, 0, 0.5, 0, 10},
	{"Awesome", "models/dg/zp6/hats/awesome.mdl", "Infecta a 2.500 humanos", "", 2, 1, 1, 0, 0.0, 0, 10},
	{"Devil", "models/dg/zp6/hats/devil2.mdl", "Consigue ser último humano en el modo Infección", "Sin comprar armas ni items extras, y al menos 15 jugadores conectados", 2, 1, 1, 2, 0.0, 0, 10},
	{"Earth", "models/dg/zp6/hats/earth.mdl", "Infecta a 5 humanos usando una furia zombie", "", 1, 0, 0, 3, 0.4, 0, 10},
	{"Gold Head", "models/dg/zp6/hats/gold_head.mdl", "Se un usuario VIP", "", 1, 1, 1, 1, 0.25, 0, 0},
	{"Pumpkin", "models/dg/zp6/hats/halloween.mdl", "Asusta a 500 humanos en el evento HALLOWEEN", "", 2, 2, 2, 2, 0.5, 0, 5},
	{"Navid", "models/dg/zp6/hats/hat_navid2.mdl", "Acumula 250 regalos en el evento NAVIDAD", "", 2, 2, 2, 2, 0.5, 0, 5},
	{"Hood", "models/dg/zp6/hats/hood.mdl", "Siendo WESKER gana la ronda sin utilizar los lasers", "Al menos 15 jugadores conectados", 0, 2, 0, 2, 0.3, 2, 10},
	{"Jack", "models/dg/zp6/hats/jackolantern.mdl", "Mata a 100 survivors", "", 2, 2, 0, 1, 0.0, 0, 10},
	{"Jamaca", "models/dg/zp6/hats/jamacahat2.mdl", "Mata a 100 nemesis", "", 2, 0, 2, 1, 0.0, 0, 10},
	{"Psycho", "models/dg/zp6/hats/psycho.mdl", "Consigue los logros \yBOMBA FALLIDA\w y \yVIRUS\w", "¡Cuidado!... Puede convertirse en zombie", 1, 3, 1, 3, 0.5, 5, 15},
	{"Sasha", "models/dg/zp6/hats/sasha.mdl", "Mata 500 zombies con cuchillo", "", 0, 5, 5, 0, 0.25, 10, 10},
	{"Scream", "models/dg/zp6/hats/scream.mdl", "Se campeón en algún torneo hecho por el servidor", "", 1, 2, 2, 1, 0.5, 5, 5},
	{"Spartan", "models/dg/zp6/hats/spartan.mdl", "Sube al nivel 15 tu Cuchillo", "", 3, 1, 1, 3, 0.0, 5, 15},
	{"Super Man", "models/dg/zp6/hats/supermancape.mdl", "Sube VELOCIDAD H/Z y GRAVEDAD H/Z al máximo", "", 2, 1, 1, 2, 0.75, 5, 10},
	{"Tyno", "models/dg/zp6/hats/tyno.mdl", "Alcanza el reset 50", "", 2, 2, 2, 2, 0.25, 10, 5},
	{"Viking", "models/dg/zp6/hats/viking.mdl", "Juega 15 días", "", 3, 1, 1, 3, 0.5, 5, 10},
	{"Zippy", "models/dg/zp6/hats/zippy.mdl", "Sube todas las armas al nivel 20", "", 3, 2, 2, 3, 0.5, 10, 10}
};

new const __ARTIFACTS[structIdArtifacts][structArtifacts] = {
	{"Anillo de las Rebajas", 100, ARTIFACT_CLASS_RING},
	{"Anillo de los Ammo Packs", 150, ARTIFACT_CLASS_RING},
	{"Anillo del Combo", 200, ARTIFACT_CLASS_RING},

	{"Collar del fuego", 75, ARTIFACT_CLASS_NECKLASE},
	{"Collar del hielo", 75, ARTIFACT_CLASS_NECKLASE},
	{"Collar del Daño", 100, ARTIFACT_CLASS_NECKLASE},

	{"Pulsera de los Ammo Packs", 250, ARTIFACT_CLASS_BRACELET},
	{"Pulsera del Combo", 750, ARTIFACT_CLASS_BRACELET},
	{"Pulsera de Puntos", 1250, ARTIFACT_CLASS_BRACELET}
};

new const __ARTIFACTS_RANGES[6][] = {
	'D', 'C', 'B', 'A', 'S', '-'
};

new const __MASTERYS[structIdMasterys][] = {
	"", "Mañana", "Noche"
};

new const __HEADZOMBIE_COLORS_MIN[structIdHeadZombies][] = {
	"roja", "verde", "azul", "amarilla", "blanca"
};

new const __HEADZOMBIES_MESSAGES[][] = {
	"La cabeza zombie tenía basura",
	"Ouuch! Solo tenia mugre",
	"La cabeza zombie estaba repleta de hongos",
	"Mala suerte! La cabeza zombie estaba vencida",
	"El demonio del quinto subsuelo se quedo con el premio",
	"Nada por aquí.. nada por allá",
	"Buena suerte tenemos todos, a pesar de que no te tocó nada"
};

new const __CLAN_PERKS[structIdClanPerks][structClanPerks] = {
	{"HABILITAR COMBO", "Habilita el combo del Clan", 250},
	{"MULTIPLICADOR DE COMBO", "Multiplica la recompensa del combo cuanto más alto sea^n^n\yREQUIERE\r:^n\r - \wHABILITAR COMBO", 175},
};

new const __COLORS[][structColors] = {
	{"Blanco", 255, 255, 255},
	{"Rojo", 255, 0, 0},
	{"Verde", 0, 255, 0},
	{"Azul", 0, 0, 255},
	{"Amarillo", 255, 255, 0},
	{"Violeta", 255, 0, 255},
	{"Celeste", 0, 255, 255},
	{"Naranja", 255, 165, 0},
	{"Grisáceo", 100, 100, 100},
	{"Rosa", 255, 50, 179},
	{"Verde amarillo", 153, 204, 50},
	{"Sienna", 139, 71, 38},
	{"Naranja oscuro", 139, 30, 0},
	{"Verde panda", 0, 255, 127},
	{"Chartreus", 127, 255, 0},
	{"Azul marino", 0, 127, 255},
	{"Chocolate dulce", 107, 66, 38},
	{"Rojo violeta", 199, 21, 133},
	{"Gris pizarra", 198, 226, 255}
};

new const __COLORS_TYPE[structIdColorTypes][] = {
	"HUD General", "Visión nocturna", "Luz / Bubble", "Brillo del Clan"
};

new const __HUD_TYPES[structIdHudTypes][] = {
	"GENERAL", "COMBO", "CLAN COMBO"
};

new const __HUD_STYLES[][] = {
	"Normal", "Normal con corchetes", "Minimizado", "Minimizado con corchetes", "Minimizado con guiones"
};

new const __COMBO_HUMAN[][structCombos] = {
	{0, 255, 255, 255, ""},
	{5000, 0, 255, 0, "¡Perfect!"},
	{25000, 0, 0, 255, "¡Holy shit!"},
	{100000, 255, 255, 0, "¡Godlike!"},
	{500000, 255, 0, 255, "¡Ludicrous Kill!"},
	{1000000, 255, 0, 0, "¡Monster Kill!"},

	{2100000000, 255, 0, 0, "¡Monster Kill!"}
};

new const __CLAN_COMBO_HUMAN[] = {0, 50000, 100000, 200000, 350000, 650000, 1000000, 2100000000};

new const __ENT_CLASSNAME_FLAME[] = "entFlame";
new const __ENT_CLASSNAME_ICECUBE[] = "entIceCube";
new const __ENT_CLASSNAME_BAZOOKA[] = "entBazooka";
new const __ENT_CLASSNAME_HAT[] = "entHat";
new const __ENT_CLASSNAME_HEADZOMBIE[] = "entHeadZombie";

new const __BLOCK_COMMANDS[][] = {
	"buy", "buyequip", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47", "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
	"sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "fiveseven", "12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum",
	"d3au1", "krieg550", "smg", "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown"
};

new const __BLOCKED_TEXTMSG[][] = {
	"#Cstrike_Tutor_Round_Over", "#Game_Commencing", "#Round_Draw", "#Terrorists_Win", "#CTs_Win"
};

new const __BLOCKED_SENDAUDIO[][] = {
	"%!MRAD_ROUNDDRAW", "%!MRAD_TERWIN", "%!MRAD_CTWIN", "%!MRAD_LETSGO", "%!MRAD_LOCKNLOAD", "%!MRAD_MOVEOUT", "%!MRAD_GO", "%!MRAD_FIREINHOLE"
};

new const __MODEL_GRENADE_INFECTION_VIEW[] = "models/dg/zp6/v_grenade_infection_00.mdl";
new const __MODEL_GRENADE_INFECTION_PLAYER[] = "models/dg/zp6/p_grenade_infection_00.mdl";
new const __MODEL_GRENADE_INFECTION_WORLD[] = "models/dg/zp6/w_grenade_infection_00.mdl";
new const __MODEL_GRENADE_FIRE_VIEW[] = "models/dg/zp6/v_grenade_fire_00.mdl";
new const __MODEL_GRENADE_FROST_VIEW[] = "models/dg/zp6/v_grenade_frost_00.mdl";
new const __MODEL_GRENADE_FLARE_VIEW[] = "models/dg/zp6/v_grenade_flare_00.mdl";
new const __MODEL_GRENADE_DRUG_VIEW[] = "models/dg/zp6/v_grenade_drug_00.mdl";
new const __MODEL_GRENADE_DRUG_PLAYER[] = "models/dg/zp6/p_grenade_drug_00.mdl";
new const __MODEL_GRENADE_DRUG_WORLD[] = "models/dg/zp6/w_grenade_drug_00.mdl";
new const __MODEL_GRENADE_SUPERNOVA_VIEW[] = "models/dg/zp6/v_grenade_supernova_00.mdl";
new const __MODEL_GRENADE_SUPERNOVA_PLAYER[] = "models/dg/zp6/p_grenade_supernova_00.mdl";
new const __MODEL_GRENADE_SUPERNOVA_WORLD[] = "models/dg/zp6/w_grenade_supernova_00.mdl";
new const __MODEL_GRENADE_BUBBLE_VIEW[] = "models/dg/zp6/v_grenade_bubble_00.mdl";
new const __MODEL_GRENADE_BUBBLE_PLAYER[] = "models/dg/zp6/p_grenade_bubble_00.mdl";
new const __MODEL_GRENADE_BUBBLE_WORLD[] = "models/dg/zp6/w_grenade_bubble_00.mdl";
new const __MODEL_GRENADE_KILL_VIEW[] = "models/dg/zp6/v_grenade_kill_00.mdl";
new const __MODEL_GRENADE_PIPE_VIEW[] = "models/zp_tcs/v_pipe.mdl";
new const __MODEL_GRENADE_PIPE_WORLD[] = "models/zp_tcs/w_pipe.mdl";
new const __MODEL_GRENADE_ANTIDOTE_VIEW[] = "models/dg/zp6/v_grenade_antidote_00.mdl";
new const __MODEL_ICECUBE[] = "models/w_hegrenade.mdl";
new const __MODEL_BUBBLE[] = "models/zp_tcs/bubble_aura.mdl";
new const __MODEL_HEADZOMBIE[] = "models/dg/zp6/headzombie_00.mdl";

new const __SOUND_HUMAN_ANTIDOTE[] = "items/smallmedkit1.wav";
new const __SOUND_HUMAN_ARMOR_HIT[] = "player/bhit_helmet-1.wav";
new const __SOUND_HUMAN_HEADZOMBIE_PICKUP[] = "items/ammopickup1.wav";
new const __SOUND_WIN_ZOMBIES[] = "dg/zp6/win_zombies_00.wav";
new const __SOUND_WIN_HUMANS[] = "dg/zp6/win_humans_00.wav";
new const __SOUND_WIN_NO_ONE[] = "ambience/3dmstart.wav";
new const __SOUND_NIGHTVISION[] = "items/equip_nvg.wav";
new const __SOUND_GRENADE_INFECTION_EXPLODE[] = "dg/zp6/grenade_infection_explode_00.wav";
new const __SOUND_GRENADE_FIRE_EXPLODE[] = "dg/zp6/grenade_fire_explode_00.wav";
new const __SOUND_GRENADE_FIRE_ZOMBIE_BURNING[][] = {"dg/zp6/zombie_burn_00.wav", "dg/zp6/zombie_burn_01.wav", "dg/zp6/zombie_burn_02.wav"};
new const __SOUND_GRENADE_FROST_EXPLODE[] = "dg/zp6/grenade_nova_explode_00.wav";
new const __SOUND_GRENADE_FROST_FREEZE[] = "dg/zp6/grenade_nova_player_00.wav";
new const __SOUND_GRENADE_FROST_BREAK[] = "dg/zp6/grenade_nova_break_00.wav";
new const __SOUND_GRENADE_FLARE_EXPLODE[] = "items/nvg_on.wav";
new const __SOUND_GRENADE_BUBBLE_EXPLODE[] = "buttons/button1.wav";
new const __SOUND_LEVEL_UP[] = "dg/zp6/levelup_00.wav";

new const __SPRITE_FLAME[] = "sprites/dg/zp6/flame_00.spr";

new g_LongJump[MAX_PLAYERS + 1][structLongJump];
new g_NightVision[MAX_PLAYERS + 1];
new g_LastNightVision[MAX_PLAYERS + 1];
new bool:g_NightVisionEnabled[MAX_PLAYERS + 1];
new g_Weapon_AutoBuy[MAX_PLAYERS + 1];
new g_Weapon_PrimarySelection[MAX_PLAYERS + 1];
new g_Weapon_SecondarySelection[MAX_PLAYERS + 1];
new g_Weapon_CuaternarySelection[MAX_PLAYERS + 1];
new g_CanBuy[MAX_PLAYERS + 1];
new g_EntFlame[MAX_PLAYERS + 1];
new g_EntIceCube[MAX_PLAYERS + 1];
new g_DrugBomb[MAX_PLAYERS + 1];
new g_SupernovaBomb[MAX_PLAYERS + 1];
new g_BubbleBomb[MAX_PLAYERS + 1];
new g_KillBomb[MAX_PLAYERS + 1];
new g_PipeBomb[MAX_PLAYERS + 1];
new g_AntidoteBomb[MAX_PLAYERS + 1];
new g_ExtraItem_Cost[MAX_PLAYERS + 1][structIdExtraItems];
new g_ExtraItem_Count[MAX_PLAYERS + 1][structIdExtraItems];
new g_ExtraItem_AlreadyBuy[MAX_PLAYERS + 1][structIdExtraItems];
new g_HumanClass[MAX_PLAYERS + 1];
new g_HumanClassNext[MAX_PLAYERS + 1];
new g_ZombieClass[MAX_PLAYERS + 1];
new g_ZombieClassNext[MAX_PLAYERS + 1];
new g_Diff[MAX_PLAYERS + 1][structIdDiffsClasses];
new g_Point[MAX_PLAYERS + 1][structIdPoints];
new g_PointInDiamond[MAX_PLAYERS + 1];
new g_PointInDiamondUsed[MAX_PLAYERS + 1];
new g_Hab[MAX_PLAYERS + 1][structIdHabs];
new g_AchievementPage[MAX_PLAYERS + 1][structIdAchievementClasses];
new g_Achievement[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementName[MAX_PLAYERS + 1][structIdAchievements][33];
new g_AchievementUnlocked[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementInt[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementTotal[MAX_PLAYERS + 1];
new Float:g_AchievementTimeLink[MAX_PLAYERS + 1];
new g_HatId[MAX_PLAYERS + 1];
new g_HatNext[MAX_PLAYERS + 1];
new g_Hat[MAX_PLAYERS + 1][structIdHats];
new g_HatUnlocked[MAX_PLAYERS + 1][structIdHats];
new g_HatTotal[MAX_PLAYERS + 1];
new Float:g_HatTimeLink[MAX_PLAYERS + 1];
new g_Hat_Devil[MAX_PLAYERS + 1];
new g_Hat_Earth[MAX_PLAYERS + 1];
new g_Artifact[MAX_PLAYERS + 1][structIdArtifacts];
new g_ArtifactsEquiped[MAX_PLAYERS + 1][structIdArtifacts];
new g_Mastery[MAX_PLAYERS + 1];
new g_ClanSlot[MAX_PLAYERS + 1];
new g_Clan[MAX_PLAYERS + 1][structClans];
new g_ClanMembers[MAX_PLAYERS + 1][MAX_CLAN_MEMBERS][structClansMembers];
new g_ClanPerks[MAX_PLAYERS + 1][structIdClanPerks];
new g_ClanCombo[MAX_PLAYERS + 1];
new g_ClanComboDamage[MAX_PLAYERS + 1];
new g_ClanComboDamageNeed[MAX_PLAYERS + 1];
new g_ClanComboReward[MAX_PLAYERS + 1];
new Float:g_ClanComboTime[MAX_PLAYERS + 1];
new g_ClanInvitations[MAX_PLAYERS + 1];
new g_ClanInvitationsId[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_TempClanName[MAX_PLAYERS + 1][15];
new g_TempClanDeposit[MAX_PLAYERS + 1];
new Float:g_ClanQueryFlood[MAX_PLAYERS + 1];
new g_UserOption_Color[MAX_PLAYERS + 1][structIdColorTypes][3];
new Float:g_UserOption_HudPosition[MAX_PLAYERS + 1][structIdHudTypes][3];
new g_UserOption_HudEffect[MAX_PLAYERS + 1][structIdHudTypes];
new g_UserOption_HudStyle[MAX_PLAYERS + 1][structIdHudTypes];
new g_UserOption_Invis[MAX_PLAYERS + 1];
new g_UserOption_NVision[MAX_PLAYERS + 1];
new g_UserOption_ClanGlow[MAX_PLAYERS + 1];
new g_UserOption_LevelTotal[MAX_PLAYERS + 1];
new g_TimePlayed[MAX_PLAYERS + 1][structIdTimePlayed];
new g_Class[MAX_PLAYERS + 1];
new Float:g_OldVelocity[MAX_PLAYERS + 1][3];
new Float:g_OldVelocityModifier[MAX_PLAYERS + 1];
new g_AmmoPacks[MAX_PLAYERS + 1];
new g_AmmoPacks_Rest[MAX_PLAYERS + 1];
new Float:g_AmmoPacks_Mult[MAX_PLAYERS + 1];
new g_AmmoPacks_Damage[MAX_PLAYERS + 1];
new g_AmmoPacks_DamageNeed[MAX_PLAYERS + 1];
new g_Level[MAX_PLAYERS + 1];
new Float:g_Level_Percent[MAX_PLAYERS + 1];
new g_Reset[MAX_PLAYERS + 1];
new Float:g_Reset_Percent[MAX_PLAYERS + 1];
new g_Prestige[MAX_PLAYERS + 1];
new g_Combo[MAX_PLAYERS + 1];
new g_ComboDamage[MAX_PLAYERS + 1];
new g_ComboDamageNeed[MAX_PLAYERS + 1];
new g_ComboReward[MAX_PLAYERS + 1];
new Float:g_NextHudInfoTime[MAX_PLAYERS + 1];
new g_StatusBarState[MAX_PLAYERS + 1][SBAR_END];
new Float:g_NextSBarUpdateTime[MAX_PLAYERS + 1];
new Float:g_StatusBarDisappearDelay[MAX_PLAYERS + 1];
new g_AmuletCustomCreated[MAX_PLAYERS + 1];
new g_AmuletCustomCost[MAX_PLAYERS + 1];
new g_AmuletCustomName[MAX_PLAYERS + 1][64];
new g_AmuletCustomNameFake[MAX_PLAYERS + 1][64];
new g_AmuletCustom[MAX_PLAYERS + 1][structIdAmuletCustoms];
new g_Benefit_Timestamp[MAX_PLAYERS + 1];
new g_HeadZombie[MAX_PLAYERS + 1][structIdHeadZombies];
new g_HeadZombie_BadLuckBrian[MAX_PLAYERS + 1];
new Float:g_HeadZombie_LastTouch[MAX_PLAYERS + 1];

new g_MenuPage_Character[MAX_PLAYERS + 1];
new g_MenuPage_HumanClasses[MAX_PLAYERS + 1];
new g_MenuPage_ZombieClasses[MAX_PLAYERS + 1];
new g_MenuPage_AchievementClasses[MAX_PLAYERS + 1];
new g_MenuPage_HabsClasses[MAX_PLAYERS + 1];
new g_MenuPage_Hats[MAX_PLAYERS + 1];
new g_MenuPage_Artifacts[MAX_PLAYERS + 1];
new g_MenuPage_ClanInvite[MAX_PLAYERS + 1];
new g_MenuPage_ClanPerks[MAX_PLAYERS + 1];
new g_MenuPage_ColorChoosen[MAX_PLAYERS + 1];
new g_MenuPage_AdminStaffRespawn[MAX_PLAYERS + 1];
new g_MenuPage_AdminStaffGameModes[MAX_PLAYERS + 1];
new g_MenuData_ZombieClassId[MAX_PLAYERS + 1];
new g_MenuData_DiffClass[MAX_PLAYERS + 1];
new g_MenuData_AchievementClass[MAX_PLAYERS + 1];
new g_MenuData_AchievementIn[MAX_PLAYERS + 1];
new g_MenuData_Point[MAX_PLAYERS + 1];
new g_MenuData_PointIn_Add[MAX_PLAYERS + 1];
new g_MenuData_PointIn_CostMoney[MAX_PLAYERS + 1];
new g_MenuData_HabClass[MAX_PLAYERS + 1];
new g_MenuData_HatId[MAX_PLAYERS + 1];
new g_MenuData_ArtifactId[MAX_PLAYERS + 1];
new g_MenuData_MasteryId[MAX_PLAYERS + 1];
new g_MenuData_ClanMemberId[MAX_PLAYERS + 1];
new g_MenuData_ClanPerkId[MAX_PLAYERS + 1];
new g_MenuData_ColorChoosen[MAX_PLAYERS + 1];

new g_ImmutableCVars[sizeof(__IMMUTABLE_CVARS)];
new g_pCVar_FreezeTime;
new g_pCVar_RoundTime;
new Float:g_pCVar_RoundRestartDelay;
new g_pCVar_PlayerId;
new Array:g_aSpawnPoints;
new bool:g_IsWarmUp;
new g_LastSpawnId;
new g_FwdSpawnPre;
new g_Message_ClCorpse;
new g_Message_Money;
new g_Message_RoundTime;
new g_Message_ScreenFade;
new g_Message_ScreenShake;
new g_Message_TextMsg;
new g_Message_SendAudio;
new g_IntoGameNightVision;
new g_SpectatorNightVision;
new Trie:g_tBlockedTextMsg;
new Trie:g_tBlockedSendAudio;
new g_HudSync_Warmup;
new g_HudSync_Info;
new g_HudSync_StatusBar;
new g_HudSync_Combo;
new g_HudSync_ClanCombo;
new g_ServerId;
new Handle:g_SqlTuple;
new Handle:g_SqlConnection;
new g_SqlQuery[1024];
new g_CurrentGameMode;
new g_LastGameMode;
new g_ForceGameMode;
new g_DrunkAtDay;
new g_DrunkAtNite;
new g_EventModes;
new g_MasteryType = -1;
new g_DefaultClass[TeamName];
new g_DefaultClassOverride[TeamName];
new g_Class_PlayerModelIndex[structIdClasses];
new g_ModelIndex_LaserBeam;
new g_ModelIndex_ShockWave;
new g_ModelIndex_BlackSmoke3;
new g_ModelIndex_Flame;
new g_ModelIndex_GlassGibs;
new g_ModelIndex_HeadZombie;
new Float:g_HeadZombie_GameTime;
new g_AmuletCustomConfirm[32];

#define __ammoPacksThisLevel(%0,%1) (%1 * (maxAmmoPacksPerReset(g_Reset[%0]) / 299))
#define __ammoPacksThisLevelRest(%0,%1) ((%1 - 1) * (maxAmmoPacksPerReset(g_Reset[%0]) / 299))

public plugin_precache() {
	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);
	register_cvar("zp_version", __PLUGIN_VERSION, (FCVAR_SERVER | FCVAR_SPONLY));

	loadGameRules();
	precacheAll();
	
	g_FwdSpawnPre = register_forward(FM_Spawn, "@FM_Spawn_Pre", false);
}

@FM_Spawn_Pre(const ent) {
	new const __REMOVE_MAP_ENTS[][] = {"func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity", "monster_scientist", "func_hostage_rescue", "info_hostage_rescue", "env_rain", "env_snow", "env_fog", "func_vehicle", "info_map_parameters", "func_buyzone", "armoury_entity"};
	new sClassName[32];
	new i;

	get_entvar(ent, var_classname, sClassName, charsmax(sClassName));

	for(i = 0; i < sizeof(__REMOVE_MAP_ENTS); ++i) {
		if(equal(sClassName, __REMOVE_MAP_ENTS[i])) {
			set_entvar(ent, var_flags, FL_KILLME);
			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public plugin_init() {
	new i;

	if(g_FwdSpawnPre) {
		unregister_forward(FM_Spawn, g_FwdSpawnPre, false);
	}

	register_event("HLTV", "@event__HLTV", "a", "1=0", "2=0");

	g_Message_ClCorpse = get_user_msgid("ClCorpse");
	g_Message_Money = get_user_msgid("Money");
	g_Message_RoundTime = get_user_msgid("RoundTime");
	g_Message_ScreenFade = get_user_msgid("ScreenFade");
	g_Message_ScreenShake = get_user_msgid("ScreenShake");
	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SendAudio = get_user_msgid("SendAudio");

	set_msg_block(g_Message_ClCorpse, BLOCK_SET);

	register_message(g_Message_Money, "@message__Money");
	register_message(g_Message_RoundTime, "@message__RoundTime");
	register_message(g_Message_ScreenFade, "@message__ScreenFade");
	register_message(g_Message_TextMsg, "@message__TextMsg");
	register_message(g_Message_SendAudio, "@message__SendAudio");

	RegisterHookChain(RG_CGib_Spawn, "@CGib_Spawn_Post", true);

	RegisterHookChain(RG_RoundEnd, "@RoundEnd_Pre", false);
	RegisterHookChain(RG_RoundEnd, "@RoundEnd_Post", true);
	RegisterHookChain(RG_ShowMenu, "@ShowMenu_Pre", false);
	RegisterHookChain(RG_ShowVGUIMenu, "@ShowVGUIMenu_Pre", false);
	RegisterHookChain(RG_ShowVGUIMenu, "@ShowVGUIMenu_Post", true);
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "@HandleMenu_ChooseTeam_Pre", false);
	RegisterHookChain(RG_ThrowHeGrenade, "@ThrowHeGrenade_Post", true);
	RegisterHookChain(RG_ThrowFlashbang, "@ThrowFlashbang_Post", true);
	RegisterHookChain(RG_ThrowSmokeGrenade, "@ThrowSmokeGrenade_Post", true);
	RegisterHookChain(RG_GetForceCamera, "@GetForceCamera_Post", true);

	RegisterHookChain(RG_CSGameRules_RestartRound, "@CSGameRules_RestartRound_Pre", false);
	RegisterHookChain(RG_CSGameRules_RestartRound, "@CSGameRules_RestartRound_Post", true);
	RegisterHookChain(RG_CSGameRules_OnRoundFreezeEnd, "@CSGameRules_OnRoundFreezeEnd_Pre", false);
	RegisterHookChain(RG_CSGameRules_OnRoundFreezeEnd, "@CSGameRules_OnRoundFreezeEnd_Post", true);
	RegisterHookChain(RG_CSGameRules_CheckWinConditions, "@CSGameRules_CheckWinConditions_Pre", false);
	RegisterHookChain(RG_CSGameRules_CheckWinConditions, "@CSGameRules_CheckWinConditions_Post", true);
	RegisterHookChain(RG_CSGameRules_FPlayerCanTakeDamage, "@CSGameRules_FPlayerCanTakeDamage_Pre", false);
	RegisterHookChain(RG_CSGameRules_FPlayerCanRespawn, "@CSGameRules_FPlayerCanRespawn_Pre", false);
	RegisterHookChain(RG_CSGameRules_GetPlayerSpawnSpot, "@CSGameRules_GetPlayerSpawnSpot_Pre", false);
	RegisterHookChain(RG_CSGameRules_DeadPlayerWeapons, "@CSGameRules_DeadPlayerWeapons_Pre", false);

	RegisterHookChain(RG_CBasePlayer_Spawn, "@CBasePlayer_Spawn_Pre", false);
	RegisterHookChain(RG_CBasePlayer_Spawn, "@CBasePlayer_Spawn_Post", true);
	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Pre", false);
	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Post", true);
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Pre", false);
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Post", true);
	RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "@CBasePlayer_ResetMaxSpeed_Pre", false);
	RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "@CBasePlayer_ResetMaxSpeed_Post", true);
	RegisterHookChain(RG_CBasePlayer_PreThink, "@CBasePlayer_PreThink_Post", true);
	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "@CBasePlayer_GiveDefaultItems_Pre", false);
	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "@CBasePlayer_GiveDefaultItems_Post", true);
	RegisterHookChain(RG_CBasePlayer_StartObserver, "@CBasePlayer_StartObserver_Post", true);
	RegisterHookChain(RG_CBasePlayer_Observer_IsValidTarget, "@CBasePlayer_Observer_IsValidTarget_Post", true);
	RegisterHookChain(RG_CBasePlayer_HintMessageEx, "@CBasePlayer_HintMessageEx_Pre", false);
	RegisterHookChain(RG_CBasePlayer_HasRestrictItem, "@CBasePlayer_HasRestrictItem_Pre", false);
	RegisterHookChain(RG_CBasePlayer_OnSpawnEquip, "@CBasePlayer_OnSpawnEquip_Pre", false);
	RegisterHookChain(RG_CBasePlayer_Radio, "@CBasePlayer_Radio_Pre", false);
	RegisterHookChain(RG_CBasePlayer_UpdateClientData, "@CBasePlayer_UpdateClientData_Post", true);

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "@CBasePlayerWeapon_DefaultDeploy_Pre", false);

	RegisterHookChain(RG_CGrenade_ExplodeHeGrenade, "@CGrenade_ExplodeHeGrenade_Pre", false);
	RegisterHookChain(RG_CGrenade_ExplodeFlashbang, "@CGrenade_ExplodeFlashbang_Pre", false);
	RegisterHookChain(RG_CGrenade_ExplodeSmokeGrenade, "@CGrenade_ExplodeSmokeGrenade_Pre", false);

	RegisterHookChain(RG_CWeaponBox_SetModel, "@CWeaponBox_SetModel_Pre", false);

	register_impulse(100, "@impulse__FlashLight");
	register_impulse(201, "@impulse__Spray");
	
	formatex(g_AmuletCustomConfirm, charsmax(g_AmuletCustomConfirm), "zp_ac_confirm %c%c%c", random_num('a', 'z'), random_num('a', 'z'), random_num('a', 'z'));

	register_clcmd("CANTIDAD_DE_PUNTOS", "@clcmd__AmountOfPoints");
	register_clcmd("CREAR_CLAN", "@clcmd__CreateClan");
	register_clcmd("INGRESAR_NOMBRE_AMULETO", "@clcmd__EnterAmuletCustomName");

	register_clcmd("zp_modes", "@clcmd__Modes");
	register_clcmd("zp_ammopacks", "@clcmd__AmmoPacks");
	register_clcmd("zp_level", "@clcmd__Level");
	register_clcmd("zp_reset", "@clcmd__Reset");
	register_clcmd("zp_prestige", "@clcmd__Prestige");
	register_clcmd("zp_points", "@clcmd__Points");
	register_clcmd("zp_clans", "@clcmd__Clans");
	register_clcmd("zp_ac_create", "@clcmd__AmuletCustomCreate");
	register_clcmd(g_AmuletCustomConfirm, "@clcmd__AmuletCustomConfirm");

	register_clcmd("say /spect", "@clcmd__Spect");
	register_clcmd("say /modo", "@clcmd__NextMode");
	register_clcmd("say /nextmode", "@clcmd__NextMode");
	register_clcmd("say /mult", "@clcmd__Mult");

	for(i = 0; i < sizeof(__BLOCK_COMMANDS); ++i) {
		register_clcmd(__BLOCK_COMMANDS[i], "@clcmd__BlockCommands");
	}
	register_clcmd("radio1", "@clcmd__Radio1");
	register_clcmd("radio2", "@clcmd__Radio2");
	register_clcmd("radio3", "@clcmd__Radio3");
	register_clcmd("drop", "@clcmd__Drop");
	register_clcmd("buyammo1", "@clcmd__BuyAmmo1", any:PRIMARY_WEAPON_SLOT);
	register_clcmd("buyammo2", "@clcmd__BuyAmmo2", any:PISTOL_SLOT);
	register_clcmd("nightvision", "@clcmd__NightVision");
	register_clcmd("say", "@clcmd__Say");
	register_clcmd("say_team", "@clcmd__SayTeam");

	oldmenu_register();

	loadStuff();
}

public plugin_cfg() {
	loadSql();
}

public client_putinserver(id) {
	resetVars(id, 1);
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	remove_task(id + TASK_CHECK_BUYS);
	remove_task(id + TASK_CHECK_ACHIEVEMENTS);
	remove_task(id + TASK_CHECK_HATS);
	remove_task(id + TASK_SAVE);
	remove_task(id + TASK_TIME_PLAYED);
	remove_task(id + TASK_FINISHCOMBO);

	// checkDisconnect();

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_ClanInvitationsId[i][id]) {
			--g_ClanInvitations[i];
		}

		g_ClanInvitationsId[i][id] = 0;
	}

	if(g_ClanSlot[id]) {
		if(g_Class[id] == CLASS_HUMAN && g_ClanCombo[g_ClanSlot[id]]) {
			sendClanMessage(id, "Un miembro humano del Clan se desconectó y el combo ha finalizado");
			// clanFinishCombo(id);
		}

		clanUpdateHumans(id);

		--g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

		if(!g_Clan[g_ClanSlot[id]][clanCountOnlineMembers]) {
			g_Clan[g_ClanSlot[id]][clanId] = 0;
		}
	}
}

public client_kill(id) {
	return PLUGIN_HANDLED;
}

public fw_create_player_data(const id, const acc_id) {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `zp9_pjs` WHERE (`acc_id`='%d');", acc_id);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 1);
	} else if(SQL_NumResults(sqlQuery)) {
		rh_drop_client(id, "Hubo un error al intentar chequear el id de tu cuenta.");
		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_pjs` (`acc_id`) VALUES ('%d');", acc_id);
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 2);
		} else {
			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_pjs_stats` (`acc_id`) VALUES ('%d');", acc_id);
			
			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 3);
			} else {
				SQL_FreeHandle(sqlQuery);

				if(dg_get_global_rank() && ((dg_get_global_rank() % 250) == 0)) {
					new i;
					for(i = 1; i <= MaxClients; ++i) {
						if(!is_user_connected(i)) {
							continue;
						}

						if(dg_get_user_acc_status(i) < STATUS_LOGGED) {
							continue;
						}

						g_Point[i][P_HUMAN] += 10;
						g_Point[i][P_ZOMBIE] += 10;
					}

					new sGlobalRank[16];
					addDot(dg_get_global_rank(), sGlobalRank, charsmax(sGlobalRank));

					clientPrintColor(0, _, "Todos los jugadores conectados ganaron !g10 pHZ!y por alcanzar las !g%s cuentas registradas!y.", sGlobalRank);
				}
			}
		}
	}
}

public fw_load_player_data(const id, const acc_id) {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `zp9_pjs` LEFT JOIN `zp9_pjs_stats` ON `zp9_pjs_stats`.`acc_id`=`zp9_pjs`.`acc_id` WHERE (`zp9_pjs`.`acc_id`='%d');", acc_id);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 4);
	} else if(SQL_NumResults(sqlQuery)) {
		new iSysTime = get_arg_systime();
		new sInfo[32];
		new sHudPosition[structIdHudTypes][3][11];
		new iClanId;
		new iHour = 0;
		new iDay = 0;

		// g_Tutorial[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "tutorial"));
		g_AmmoPacks[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ammopacks"));
		g_Level[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "level"));
		g_Reset[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "reset"));
		g_Prestige[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "prestige"));
		g_Weapon_AutoBuy[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "weapon_autobuy"));
		g_Weapon_PrimarySelection[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "weapon_primary"));
		g_Weapon_SecondarySelection[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "weapon_secondary"));
		g_Weapon_CuaternarySelection[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "weapon_cuaternary"));
		g_HumanClassNext[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hclass"));
		g_ZombieClassNext[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "zclass"));
		g_Diff[id][DIFF_CLASS_SURVIVOR] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "diffsurv"));
		g_Diff[id][DIFF_CLASS_NEMESIS] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "diffnem"));
		g_Point[id][P_MONEY] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "money"));
		g_Point[id][P_HUMAN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_humans"));
		g_Point[id][P_ZOMBIE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_zombies"));
		g_Point[id][P_LEGACY] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_legacy"));
		g_Point[id][P_FRAGMENT] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_fragments"));
		g_Point[id][P_DIAMOND] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_diamonds"));
		g_HatId[id] = g_HatNext[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hat_id"));
		// g_Amulet[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "amulet_id"));
		g_Mastery[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "mastery_id"));
		g_HeadZombie[id][HEADZOMBIE_RED] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "headzombie_r"));
		g_HeadZombie[id][HEADZOMBIE_GREEN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "headzombie_g"));
		g_HeadZombie[id][HEADZOMBIE_BLUE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "headzombie_b"));
		g_HeadZombie[id][HEADZOMBIE_YELLOW] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "headzombie_y"));
		g_HeadZombie[id][HEADZOMBIE_WHITE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "headzombie_w"));

		g_Benefit_Timestamp[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "benefit_timestamp"));

		if(g_Benefit_Timestamp[id] && iSysTime > g_Benefit_Timestamp[id]) {
			g_Benefit_Timestamp[id] = 1;
		}
		
		iClanId = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_id"));
		loadClan(id, iClanId);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_color_hud"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_HUD], 3);
		
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_color_nvision"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_NVISION], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_color_flare"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_FLARE], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_color_clan_glow"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_general_position"), sInfo, charsmax(sInfo));
		parse(sInfo, sHudPosition[HUD_TYPE_GENERAL][0], charsmax(sHudPosition[][]), sHudPosition[HUD_TYPE_GENERAL][1], charsmax(sHudPosition[][]), sHudPosition[HUD_TYPE_GENERAL][2], charsmax(sHudPosition[][]));

		g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][0] = str_to_float(sHudPosition[HUD_TYPE_GENERAL][0]);
		g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][1] = str_to_float(sHudPosition[HUD_TYPE_GENERAL][1]);
		g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][2] = str_to_float(sHudPosition[HUD_TYPE_GENERAL][2]);

		g_UserOption_HudEffect[id][HUD_TYPE_GENERAL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_general_effect"));
		g_UserOption_HudStyle[id][HUD_TYPE_GENERAL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_general_style"));

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_combo_position"), sInfo, charsmax(sInfo));
		parse(sInfo, sHudPosition[HUD_TYPE_COMBO][0], charsmax(sHudPosition[][]), sHudPosition[HUD_TYPE_COMBO][1], charsmax(sHudPosition[][]), sHudPosition[HUD_TYPE_COMBO][2], charsmax(sHudPosition[][]));

		g_UserOption_HudPosition[id][HUD_TYPE_COMBO][0] = str_to_float(sHudPosition[HUD_TYPE_COMBO][0]);
		g_UserOption_HudPosition[id][HUD_TYPE_COMBO][1] = str_to_float(sHudPosition[HUD_TYPE_COMBO][1]);
		g_UserOption_HudPosition[id][HUD_TYPE_COMBO][2] = str_to_float(sHudPosition[HUD_TYPE_COMBO][2]);

		g_UserOption_HudEffect[id][HUD_TYPE_COMBO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_combo_effect"));
		g_UserOption_HudStyle[id][HUD_TYPE_COMBO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_combo_style"));

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_clan_combo_position"), sInfo, charsmax(sInfo));
		parse(sInfo, sHudPosition[HUD_TYPE_CLAN_COMBO][0], charsmax(sHudPosition[][]), sHudPosition[HUD_TYPE_CLAN_COMBO][1], charsmax(sHudPosition[][]), sHudPosition[HUD_TYPE_CLAN_COMBO][2], charsmax(sHudPosition[][]));

		g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][0] = str_to_float(sHudPosition[HUD_TYPE_CLAN_COMBO][0]);
		g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][1] = str_to_float(sHudPosition[HUD_TYPE_CLAN_COMBO][1]);
		g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][2] = str_to_float(sHudPosition[HUD_TYPE_CLAN_COMBO][2]);

		g_UserOption_HudEffect[id][HUD_TYPE_CLAN_COMBO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_clan_combo_effect"));
		g_UserOption_HudStyle[id][HUD_TYPE_CLAN_COMBO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_clan_combo_style"));

		g_UserOption_Invis[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_invis"));
		g_UserOption_NVision[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_nvision"));
		g_UserOption_ClanGlow[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_clan_glow"));
		g_UserOption_LevelTotal[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_leveltotal"));

		// g_BuyStuff[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "bought_ok"));

		g_TimePlayed[id][TIME_MIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "time_played"));
		
		iHour = (g_TimePlayed[id][TIME_MIN] / 60);
		iDay = 0;
		
		while(iHour >= 24) {
			++iDay;
			iHour -= 24;
		}
		
		g_TimePlayed[id][TIME_HOUR] = iHour;
		g_TimePlayed[id][TIME_DAY] = iDay;

		// iPlayedTimePerDaySec > ((g_AccountSinceConnection[id] - get_arg_systime()) / (g_TimePlayed[id][TIME_MIN] / 60));
		// g_PlayedTime_PerDay[iId] = ((iPlayedTimePerDaySec / 60.0) / 60.0);

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `zp9_achievements` WHERE (`acc_id`='%d');", acc_id);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 1233);
		} else if(SQL_NumResults(sqlQuery)) {
			new iAchievement;

			while(SQL_MoreResults(sqlQuery)) {
				iAchievement = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "achievement_id"));

				g_Achievement[id][iAchievement] = 1;
				g_AchievementUnlocked[id][iAchievement] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "achievement_timestamp"));
				++g_AchievementTotal[id];

				SQL_NextRow(sqlQuery);
			}

			SQL_FreeHandle(sqlQuery);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `zp9_amulets_custom` WHERE (`acc_id`='%d' AND `active`='1');", acc_id);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 12433);
		} else if(SQL_NumResults(sqlQuery)) {
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "name"), g_AmuletCustomName[id], charsmax(g_AmuletCustomName[]));
			g_AmuletCustom[id][acHealth] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_health"));
			g_AmuletCustom[id][acSpeed] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_speed"));
			g_AmuletCustom[id][acGravity] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_gravity"));
			g_AmuletCustom[id][acDamage] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_damage"));
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_aps"), Float:g_AmuletCustom[id][acMultAmmoPacks]);

			g_AmuletCustomCreated[id] = 1;

			SQL_FreeHandle(sqlQuery);
		} else {
			g_AmuletCustomCreated[id] = 0;

			SQL_FreeHandle(sqlQuery);
		}

		remove_task(id + TASK_CHECK_ACHIEVEMENTS);
		remove_task(id + TASK_SAVE);
		remove_task(id + TASK_TIME_PLAYED);

		set_task(random_float(15.0, 20.0), "task__CheckAchievements", id + TASK_CHECK_ACHIEVEMENTS);
		set_task(random_float(180.0, 360.0), "task__Save", id + TASK_SAVE, .flags="b");
		set_task(360.0, "task__TimePlayed", id + TASK_TIME_PLAYED, .flags="b");

		checkAmmoPacksEquation(id);

		dg_set_user_acc_status(id, STATUS_LOGGED);
		dg_get_user_menu_join(id);
	} else {
		rh_drop_client(id, "Hubo un error al detectar los datos de tu personaje al ingresar con tu cuenta. Contáctate con el desarrollador general para más información.");
		SQL_FreeHandle(sqlQuery);
	}
}

public fw_join_player(const id) {
	dg_set_user_acc_status(id, STATUS_PLAYING);
	rg_join_team(id, rg_get_join_team_priority());

	set_member(id, m_bTeamChanged, true);
}

public fw_vinc_player_success(const id) {
	setAchievement(id, VINCULADO);
}

public fw_save_other_data(const id, const acc_id) {
	savePlayerData(id, acc_id);
}

@CGib_Spawn_Post(const ent) {
	set_member(ent, m_Gib_lifeTime, 0.0);
}

@RoundEnd_Pre(WinStatus:status, const ScenarioEventEndRound:event, const Float:delay) {
	if(g_IsWarmUp) {
		if((get_member_game(m_iNumSpawnableTerrorist) + get_member_game(m_iNumSpawnableCT)) >= 2) {
			SetHookChainArg(2, ATYPE_INTEGER, ROUND_GAME_COMMENCE);
			SetHookChainArg(3, ATYPE_FLOAT, 5.0);
		}
		
		return;
	}

	if(!get_member_game(m_bGameStarted)) {
		return;
	}

	if(status == WINSTATUS_NONE) {
		status = WINSTATUS_DRAW;
	}

	SetHookChainArg(1, ATYPE_INTEGER, status);
}

@RoundEnd_Post(const WinStatus:status, const ScenarioEventEndRound:event, const Float:delay) {
	if(event == ROUND_GAME_COMMENCE) {
		engfunc(EngFunc_AlertMessage, at_logged, "World triggered ^"Game_Commencing^"^n");

		set_member_game(m_bFreezePeriod, false);
		set_member_game(m_bCompleteReset, true);
		set_member_game(m_bGameStarted, true);
	}

	remove_task(TASK_VIRUST);

	switch(status) {
		case WINSTATUS_CTS: {
			clearDirectorHud();

			set_dhudmessage(0, 0, 200, -1.0, 0.25, 0, 0.0, 3.0, 2.0, 1.0);
			show_dhudmessage(0, "¡GANARON LOS HUMANOS!");

			playSound(0, __SOUND_WIN_HUMANS);
		} case WINSTATUS_TERRORISTS: {
			clearDirectorHud();

			set_dhudmessage(200, 0, 0, -1.0, 0.25, 0, 0.0, 3.0, 2.0, 1.0);
			show_dhudmessage(0, "¡GANARON LOS ZOMBIES!");

			playSound(0, __SOUND_WIN_ZOMBIES);
		} case WINSTATUS_DRAW: {
			clearDirectorHud();

			set_dhudmessage(0, 200, 0, -1.0, 0.25, 0, 0.0, 3.0, 2.0, 1.0);
			show_dhudmessage(0, "¡NO GANÓ NADIE!");

			playSound(0, __SOUND_WIN_NO_ONE);
		}
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		if(!is_user_alive(i)) {
			continue;
		}

		if(task_exists(i + TASK_FINISHCOMBO)) {
			change_task(i + TASK_FINISHCOMBO, 0.1);
		}
	}
}

@ShowMenu_Pre(const id, const slot, const display_time, const need_mode, const text[]) {
	if(containi(text, "Team_Select") == -1) {
		return HC_CONTINUE;
	}

	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

@ShowVGUIMenu_Pre(const id, const VGUIMenu:menu_type, const slot, const old_menu[]) {
	if((menu_type != VGUI_Menu_Team) && (menu_type != VGUI_Menu_Class_CT) && (menu_type != VGUI_Menu_Class_T)) {
		return HC_CONTINUE;
	}

	if(dg_get_user_acc_status(id) != STATUS_CHECK_ACCOUNT && dg_get_user_acc_status(id) != STATUS_LOADING) {
		if(dg_get_user_acc_status(id) == STATUS_BANNED) {
			dg_get_user_menu_banned(id);
		} else if(dg_get_user_acc_status(id) == STATUS_LOGGED) {
			dg_get_user_menu_join(id);
		} else if(dg_get_user_acc_status(id) == STATUS_PLAYING) {
			showMenu__Game(id);
		} else {
			dg_get_user_menu_login(id);
		}

		SetHookChainReturn(ATYPE_INTEGER, 0);
	}

	return HC_BREAK;
}

@ShowVGUIMenu_Post(const id, const VGUIMenu:menu_type, const slot, const old_menu[]) {
	if(menu_type != VGUI_Menu_Team) {
		return;
	}

	if(get_member(id, m_iJoiningState) == JOINED) {
		return;
	}

	g_NightVision[id] = g_IntoGameNightVision;

	set_member(id, m_bHasNightVision, true);
	setNightVision(id, true);
}

@HandleMenu_ChooseTeam_Pre(const id, const MenuChooseTeam:slot) {
	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

@GetForceCamera_Post(const id) {
	if(!g_NightVisionEnabled[id]) {
		return;
	}

	RequestFrame("@RequestFrame_UpdateNightVision", id);
}

@CSGameRules_RestartRound_Pre() {
	g_IsWarmUp = false;
	SetRoundCvars(PREPARE_TIME, ROUND_TIME);

	updateNightVision(0);

	g_CurrentGameMode = 0;
	g_ForceGameMode = 0;

	classOverrideDefault(TEAM_TERRORIST, 0);
	classOverrideDefault(TEAM_CT, 0);
}

@CSGameRules_RestartRound_Post() {
	forceLevelInitialize();

	new i;
	new j;

	for(i = 1; i <= MaxClients; ++i) {
		flameDestroy(i);
		iceCubeDestroy(i);
		
		for(j = 0; j < structIdExtraItems; ++j) {
			g_ExtraItem_AlreadyBuy[i][j] = 0;
		}
	}
}

@CSGameRules_OnRoundFreezeEnd_Pre() {
	if(!get_member_game(m_bGameStarted)) {
		return;
	}

	new i;
	new iAlivesCount = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		++iAlivesCount;
	}

	if(iAlivesCount < GAMEMODE_LAUNCH_MINALIVES) {
		return;
	}
	
	new iMode = MODE_NONE;

	if(g_ForceGameMode) {
		if(getGameModeStatus(g_ForceGameMode, true)) {
			iMode = g_ForceGameMode;
		}
	}

	if(iMode == MODE_NONE) {
		new i;
		for(i = 0; i < structIdModes; ++i) {
			if(!getGameModeStatus(i, false)) {
				continue;
			}

			iMode = i;
			break;
		}
	}

	if(iMode == MODE_NONE) {
		iMode = MODE_INFECTION;
	}

	changeGameMode(iMode, 0);
}

public bool:getGameModeStatus(const mode, const bool:force) {
	new iAlivesNum = getUsersAlive();

	if(iAlivesNum < __MODES[mode][modeMinAlives]) {
		return false;
	}

	if(!force) {
		if(g_LastGameMode == mode) {
			return false;
		}

		new iChance = __MODES[mode][modeChance];

		if(iChance) {
			if(random_num(1, iChance) != 1) {
				return false;
			}
		}
	}

	return true;
}

public bool:changeGameMode(const mode, const id) {
	new i;
	new Array:aAlives = ArrayCreate(1, 0);

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		ArrayPushCell(aAlives, i);
	}

	g_CurrentGameMode = mode;
	g_LastGameMode = mode;

	clearDirectorHud();

	set_dhudmessage(0, 255, 0, -1.0, 0.25, 0, 0.0, 5.0, 1.0, 1.0);
	show_dhudmessage(0, "~ %s ~", __MODES[mode][modeName]);

	if(__MODES[mode][modeRoundTime]) {
		set_member_game(m_iRoundTime, __MODES[mode][modeRoundTime]);
	}

	new iAlivesNum = ArraySize(aAlives);
	new iItem;
	new iPlayerId;
	new iMaxZombies = 0;

	switch(mode) {
		case MODE_INFECTION: {
			iItem = random_num(0, (iAlivesNum - 1));
			iPlayerId = ArrayGetCell(aAlives, iItem);

			changeClass(iPlayerId, 0, CLASS_ZOMBIE, false);
		} case MODE_SWARM: {
			iMaxZombies = (iAlivesNum / 2);

			for(i = 0; i < iMaxZombies; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_ZOMBIE, false);
				ArrayDeleteItem(aAlives, iItem);
			}
		} case MODE_MULTI: {
			if(iAlivesNum > 30) {
				iMaxZombies = 6;
			} else if(iAlivesNum > 20) {
				iMaxZombies = 4;
			} else if(iAlivesNum > 10) {
				iMaxZombies = 2;
			} else {
				iMaxZombies = 1;
			}

			iMaxZombies = min(iMaxZombies, iAlivesNum);

			for(i = 0; i < iMaxZombies; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_ZOMBIE, false);
				ArrayDeleteItem(aAlives, iItem);
			}
		} case MODE_PLAGUE: {
			new iMaxNemesis = 2;
			new iMaxSurvivors = 2;
			new Float:flHealth = 0.0;

			iMaxZombies = floatround(((iAlivesNum - (iMaxNemesis + iMaxSurvivors)) * 0.5), floatround_ceil);

			for(i = 0; i < iMaxNemesis; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_NEMESIS, false);

				flHealth = (Float:get_entvar(iPlayerId, var_health) * 0.5);

				set_entvar(iPlayerId, var_health, flHealth);
				set_entvar(iPlayerId, var_max_health, flHealth);

				ArrayDeleteItem(aAlives, iItem);
			}

			for(i = 0; i < iMaxSurvivors; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_SURVIVOR, false);

				flHealth = (Float:get_entvar(iPlayerId, var_health) * 0.5);

				set_entvar(iPlayerId, var_health, flHealth);
				set_entvar(iPlayerId, var_max_health, flHealth);

				ArrayDeleteItem(aAlives, iItem);
			}

			for(i = 0; i < iMaxZombies; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_ZOMBIE, false);
				ArrayDeleteItem(aAlives, iItem);
			}
		} case MODE_SYNAPSIS: {
			new Float:flHealth = 0.0;

			iMaxZombies = 3; // Nemesis

			for(i = 0; i < iMaxZombies; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_NEMESIS, false);

				flHealth = (Float:get_entvar(iPlayerId, var_health) * 2.0);

				set_entvar(iPlayerId, var_health, flHealth);
				set_entvar(iPlayerId, var_max_health, flHealth);

				ArrayDeleteItem(aAlives, iItem);
			}
		} case MODE_ARMAGEDDON: {
			new Float:flHealth = 0.0;

			iMaxZombies = floatround((iAlivesNum * 0.5), floatround_ceil);

			for(i = 0; i < iMaxZombies; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_NEMESIS, false);

				flHealth = (Float:get_entvar(iPlayerId, var_health) * 0.25);

				set_entvar(iPlayerId, var_health, flHealth);
				set_entvar(iPlayerId, var_max_health, flHealth);

				ArrayDeleteItem(aAlives, iItem);
			}

			for(i = 0; i < iAlivesNum; ++i) {
				iPlayerId = ArrayGetCell(aAlives, i);

				changeClass(iPlayerId, 0, CLASS_SURVIVOR, false);

				flHealth = (Float:get_entvar(iPlayerId, var_health) * 0.25);

				set_entvar(iPlayerId, var_health, flHealth);
				set_entvar(iPlayerId, var_max_health, flHealth);
			}
			
			classOverrideDefault(TEAM_TERRORIST, CLASS_NEMESIS);
			classOverrideDefault(TEAM_CT, CLASS_SURVIVOR);
		} case MODE_MEGA_ARMAGEDDON: {
			new Float:flHealth = 0.0;

			iMaxZombies = floatround((iAlivesNum * 0.5), floatround_ceil);

			for(i = 0; i < iMaxZombies; ++i) {
				iItem = random_num(0, (iAlivesNum - 1));
				iPlayerId = ArrayGetCell(aAlives, iItem);

				changeClass(iPlayerId, 0, CLASS_NEMESIS, false);

				flHealth = (Float:get_entvar(iPlayerId, var_health) * 1.25);

				set_entvar(iPlayerId, var_health, flHealth);
				set_entvar(iPlayerId, var_max_health, flHealth);

				ArrayDeleteItem(aAlives, iItem);
			}

			for(i = 0; i < iAlivesNum; ++i) {
				iPlayerId = ArrayGetCell(aAlives, i);

				changeClass(iPlayerId, 0, CLASS_SURVIVOR, false);

				flHealth = (Float:get_entvar(iPlayerId, var_health) * 1.25);

				set_entvar(iPlayerId, var_health, flHealth);
				set_entvar(iPlayerId, var_max_health, flHealth);
			}
			
			classOverrideDefault(TEAM_TERRORIST, CLASS_NEMESIS);
			classOverrideDefault(TEAM_CT, CLASS_SURVIVOR);
		} case MODE_GUNGAME: {

		} case MODE_MEGA_GUNGAME: {

		} case MODE_DUEL_FINAL: {

		} case MODE_SURVIVOR: {
			iItem = random_num(0, (iAlivesNum - 1));
			iPlayerId = ArrayGetCell(aAlives, iItem);

			changeClass(iPlayerId, 0, CLASS_SURVIVOR, false);
			ArrayDeleteItem(aAlives, iItem);

			for(i = 0; i < iAlivesNum; ++i) {
				iPlayerId = ArrayGetCell(aAlives, i);

				changeClass(iPlayerId, 0, getClassDefault(TEAM_TERRORIST, false), false);
				ArrayDeleteItem(aAlives, i);
			}
		} case MODE_WESKER: {
			iItem = random_num(0, (iAlivesNum - 1));
			iPlayerId = ArrayGetCell(aAlives, iItem);

			changeClass(iPlayerId, 0, CLASS_WESKER, false);
			ArrayDeleteItem(aAlives, iItem);

			for(i = 0; i < iAlivesNum; ++i) {
				iPlayerId = ArrayGetCell(aAlives, i);

				changeClass(iPlayerId, 0, getClassDefault(TEAM_TERRORIST, false), false);
				ArrayDeleteItem(aAlives, i);
			}
		} case MODE_SNIPER: {
			iItem = random_num(0, (iAlivesNum - 1));
			iPlayerId = ArrayGetCell(aAlives, iItem);

			changeClass(iPlayerId, 0, CLASS_SNIPER, false);
			ArrayDeleteItem(aAlives, iItem);

			for(i = 0; i < iAlivesNum; ++i) {
				iPlayerId = ArrayGetCell(aAlives, i);

				changeClass(iPlayerId, 0, getClassDefault(TEAM_TERRORIST, false), false);
				ArrayDeleteItem(aAlives, i);
			}
		} case MODE_NEMESIS: {
			iItem = random_num(0, (iAlivesNum - 1));
			iPlayerId = ArrayGetCell(aAlives, iItem);

			changeClass(iPlayerId, 0, CLASS_NEMESIS, false);
		} case MODE_ASSASSIN: {
			iItem = random_num(0, (iAlivesNum - 1));
			iPlayerId = ArrayGetCell(aAlives, iItem);

			changeClass(iPlayerId, 0, CLASS_ASSASSIN, false);
		} case MODE_GRUNT: {
			iItem = random_num(0, (iAlivesNum - 1));
			iPlayerId = ArrayGetCell(aAlives, iItem);

			changeClass(iPlayerId, 0, CLASS_GRUNT, false);
		}
	}

	ArrayDestroy(aAlives);
	return true;
}

@CSGameRules_OnRoundFreezeEnd_Post() {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		set_member(i, m_bCanShootOverride, false);
	}
}

@CSGameRules_CheckWinConditions_Pre() {
	if(g_IsWarmUp) {
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

@CSGameRules_CheckWinConditions_Post() {
	rg_initialize_player_counts();

	set_member_game(m_bNeededPlayers, false);

	if((get_member_game(m_iNumSpawnableTerrorist) + get_member_game(m_iNumSpawnableCT)) < 2) {
		message_begin(MSG_ALL, g_Message_TextMsg);
		write_byte(print_console);
		write_string("#Game_scoring");
		message_end();

		set_member_game(m_bNeededPlayers, true);
		set_member_game(m_bGameStarted, false);

		return;
	} else {
		if(g_IsWarmUp) {
			if(get_member_game(m_bRoundTerminating)) {
				set_member_game(m_bGameStarted, true);
			}

			return;
		}
	}

	if(get_member_game(m_bGameStarted)) {
		return;
	}

	rg_round_end(3.0, WINSTATUS_DRAW, ROUND_GAME_COMMENCE, .trigger=true);
}

@CSGameRules_FPlayerCanTakeDamage_Pre(const victim, const attacker) {
	if(get_member_game(m_bRoundTerminating)) {
		SetHookChainReturn(ATYPE_INTEGER, false);
		return HC_SUPERCEDE;
	}

	if(g_IsWarmUp) {
		SetHookChainReturn(ATYPE_INTEGER, false);
		return HC_SUPERCEDE;
	}

	// if(!is_nullent(g_EntIceCube[victim])) {
		// SetHookChainReturn(ATYPE_INTEGER, false);
		// return HC_SUPERCEDE;
	// }

	return HC_CONTINUE;
}

@CSGameRules_FPlayerCanRespawn_Pre(const id) {
	if(get_member_game(m_bRoundTerminating)) {
		SetHookChainReturn(ATYPE_INTEGER, false);
		return HC_SUPERCEDE;
	}

	if(get_member(id, m_iMenu) == Menu_ChooseAppearance) {
		SetHookChainReturn(ATYPE_INTEGER, false);
		return HC_SUPERCEDE;
	}

	if(g_IsWarmUp) {
		if(get_member(id, m_iJoiningState) != JOINED) {
			SetHookChainReturn(ATYPE_INTEGER, false);
			return HC_SUPERCEDE;
		}

		SetHookChainReturn(ATYPE_INTEGER, true);
		return HC_SUPERCEDE;
	}
	
	SetHookChainReturn(ATYPE_INTEGER, true);
	return HC_SUPERCEDE;
}

@CSGameRules_GetPlayerSpawnSpot_Pre(const id) {
	new TeamName:iTeam = getUserTeam(id);

	if(!(TEAM_TERRORIST <= iTeam <= TEAM_CT)) {
		return HC_CONTINUE;
	}

	new iSpot = entSelectSpawnPoint(id);

	if(is_nullent(iSpot)) {
		return HC_CONTINUE;
	}

	new Float:vecOrigin[3];
	new Float:vecAngles[3];

	get_entvar(iSpot, var_origin, vecOrigin);
	get_entvar(iSpot, var_angles, vecAngles);

	vecOrigin[2] += 1.0;

	set_entvar(id, var_origin, vecOrigin);
	set_entvar(id, var_v_angle, NULL_VECTOR);
	set_entvar(id, var_velocity, NULL_VECTOR);
	set_entvar(id, var_angles, vecAngles);
	set_entvar(id, var_punchangle, NULL_VECTOR);
	set_entvar(id, var_fixangle, 1);

	SetHookChainReturn(ATYPE_INTEGER, iSpot);
	return HC_SUPERCEDE;
}

@CSGameRules_DeadPlayerWeapons_Pre(const id) {
	SetHookChainReturn(ATYPE_INTEGER, GR_PLR_DROP_GUN_NO);
	return HC_SUPERCEDE;
}

@CBasePlayer_Spawn_Pre(const id) {
	if(get_member(id, m_bJustConnected)) {
		return;
	}

	new TeamName:iTeam = getUserTeam(id);

	if(!(TEAM_TERRORIST <= iTeam <= TEAM_CT)) {
		return;
	}

	new iNewClass = getClassDefault(TEAM_CT, false);

	if(!g_IsWarmUp && get_member_game(m_bGameStarted) && !get_member_game(m_bFreezePeriod)) {
		if(__MODES[g_CurrentGameMode][modeRespawn]) {
			switch(g_CurrentGameMode) {
				case MODE_INFECTION, MODE_MULTI: {
					updatePlayerHat(id);

					new iRandom = random_num(1, 100);
					new iRandomChance = ((__HABS[HAB_L_RESPAWN][habValue] * g_Hab[id][HAB_L_RESPAWN]) + __HATS[g_HatId[id]][hatUpgrade6]);

					if(iRandomChance < 1) {
						iRandomChance = 1;
					}

					new iUsersAlive = getUsersAlive();

					if(getUsersPlaying(TEAM_TERRORIST) < (iUsersAlive / 2) || (iRandom - iRandomChance) > 0) {
						iNewClass = getClassDefault(TEAM_TERRORIST, false);
					}
				}
			}
		}
	}

	if(g_Class[id] == iNewClass) {
		return;
	}

	set_member(id, m_bNotKilled, false);

	changeClass(id, id, iNewClass, true);
}

@CBasePlayer_Spawn_Post(const id) {
	if(get_member(id, m_bJustConnected)) {
		set_member(id, m_flNextSBarUpdateTime, 99999999.0);
		return;
	}

	if(!is_user_alive(id)) {
		return;
	}

	new TeamName:iTeam = getUserTeam(id);

	if(!(TEAM_TERRORIST <= iTeam <= TEAM_CT)) {
		return;
	}

	g_Hat_Devil[id] = 0;
	g_Hat_Earth[id] = -999;

	resetVars(id, 0);

	changeProps(id, g_Class[id], true);
	setNightVision(id, false);

	if(get_member_game(m_bFreezePeriod)) {
		set_member(id, m_bCanShootOverride, true);
	}

	set_member(id, m_iHideHUD, (get_member(id, m_iHideHUD) | (HIDEHUD_HEALTH | HIDEHUD_MONEY)));

	cs_set_user_money(id, 0, 0);

	if(get_member(id, m_iNumSpawns) == 1) {
		// . . .
	}

	// switch(g_CurrentGameMode) {
		// case MODE_ARMAGEDDON: {
			// if(!g_ModeArmageddon_Init) {
				// clientPrintColor(id, _, "No puedes revivir en la mitad de un Armageddon.");

				// user_silentkill(id);
				// return;
			// }
		// } case MODE_MEGA_ARMAGEDDON: {
			// if(!g_ModeMA_Reward[id]) {
				// clientPrintColor(id, _, "No puedes revivir en la mitad de un Mega Armageddon.");

				// user_silentkill(id);
				// return;
			// }
		// } default: {
			// if(g_CurrentGameMode == MODE_GRUNT) {
				// remove_task(id + TASK_GRUNT_AIMING);
				// set_task(0.1, "task__ModeGruntAiming", id + TASK_GRUNT_AIMING);
			// }
		// }
	// }

	// switch(g_CurrentGameMode) {
		// case MODE_ARMAGEDDON: {
			// zombieMe(id, .nemesis=1);
			// return;
		// } case MODE_MEGA_ARMAGEDDON: {
			// if(g_ModeMA_Reward[id] == 2) {
				// zombieMe(id, .nemesis=1);
			// } else {
				// g_ModeMA_Reward[id] = 1;

				// if(!g_Zombie[id]) {
					// humanMe(id, .survivor=1);
				// } else {
					// zombieMe(id, .nemesis=1);
				// }
			// }

			// return;
		// }
	// }

	// if(g_CurrentGameMode == MODE_GUNGAME || g_CurrentGameMode == MODE_MEGA_GUNGAME || g_CurrentGameMode == MODE_DUEL_FINAL) {
		// switch(g_CurrentGameMode) {
			// case MODE_MEGA_GUNGAME: {
				// new iHealthExtra = (100 + g_ModeMGG_Health[id]);

				// if(iHealthExtra >= 200) {
					// set_user_health(id, 200);
				// } else {
					// set_user_health(id, iHealthExtra);
				// }
			// } default: {
				// set_user_health(id, 100);
			// }
		// }

		// g_Speed[id] = 240.0;
		// set_user_gravity(id, 1.0);
		// set_user_armor(id, 0);

		// if(g_CurrentGameMode == MODE_GUNGAME || g_CurrentGameMode == MODE_MEGA_GUNGAME) {
			// set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 4);

			// g_ModeGG_Immunity[id] = 1;

			// remove_task(id + TASK_IMMUNITY_GG);
			// set_task(1.5, "task__RemoveImmunityGunGame", id + TASK_IMMUNITY_GG);
		// }
	// } else {
		// set_user_health(id, humanHealth(id));
		// g_Speed[id] = Float:humanSpeed(id);
		// set_user_gravity(id, humanGravity(id));
		// set_user_armor(id, humanArmor(id));
	// }

	// g_Health[id] = get_user_health(id);
	// g_MaxHealth[id] = g_Health[id];

	// copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Humano");

	// if(g_CurrentGameMode != MODE_GUNGAME && g_CurrentGameMode != MODE_MEGA_GUNGAME && g_CurrentGameMode != MODE_DUEL_FINAL) {
		// if(!g_NewRound && getUserTeam(id) != TEAM_CT) {
			// setUserTeam(id, TEAM_CT);
		// }

		// set_user_rendering(id);
	// }

	// setUserAllModels(id);
	// turnOffFlashlight(id);

	g_NextHudInfoTime[id] = (get_gametime() + 0.2);
}

@CBasePlayer_Killed_Pre(const victim, const killer, const should_gib) {
	utilSetRendering(victim);

	changeLongJump(victim, false);

	flameDestroy(victim);
	iceCubeDestroy(victim);

	if(task_exists(victim + TASK_FINISHCOMBO)) {
		change_task(victim + TASK_FINISHCOMBO, 0.1);
	}

	if(g_Class[victim] == CLASS_ZOMBIE || g_Class[victim] == CLASS_NEMESIS) {
		if(g_Class[victim] == CLASS_NEMESIS) {
			SetHookChainArg(3, ATYPE_INTEGER, GIB_ALWAYS);
		}

		// ++g_DeadTimes[victim];
		// ++g_DeadTimes_Reward[victim];
	}

	switch(g_CurrentGameMode) {
		case MODE_MEGA_ARMAGEDDON: {

		} case MODE_GUNGAME: {
			return;
		} case MODE_MEGA_GUNGAME: {
			return;
		} case MODE_DUEL_FINAL: {
			return;
		} case MODE_GRUNT: {
			return;
		}
	}

	if(victim == killer || !is_user_connected(killer)) {
		return;
	}

	new iReward = 0;

	switch(g_Class[killer]) {
		case CLASS_HUMAN: {
			if(should_gib == 1) { // Nos aseguramos de que no lo haya matado con una bomba de aniquilación (o muerte por explosión)
				iReward = getConversion(killer, 5);
			}

			new iRandomNum = random_num(1, 10);

			if(iRandomNum == 1 || iRandomNum == 4 || (g_DrunkAtNite == 2 && (iRandomNum == 5 || iRandomNum == 10)) || get_member(victim, m_LastHitGroup) == HITGROUP_HEAD) {
				new Float:vecOrigin[3];
				new Float:vecEndOrigin[3];
				new Float:flFraction;

				get_entvar(victim, var_origin, vecOrigin);
				getDropOrigin(victim, vecEndOrigin, 20);

				engfunc(EngFunc_TraceLine, vecOrigin, vecEndOrigin, IGNORE_MONSTERS, victim, 0);
				get_tr2(0, TR_flFraction, flFraction);

				if(flFraction == 1.0) {
					dropHeadZombie(victim);
				}
			}
		} case CLASS_ZOMBIE: {
			iReward = getConversion(killer, 10);
		}
	}

	addAmmoPacks(killer, iReward);

	if(g_Class[victim]) {

	}
}

@CBasePlayer_Killed_Post(const victim, const killer, const should_gib) {
	ClearSyncHud(victim, g_HudSync_Info);

	if(rg_is_player_can_respawn(victim)) {
		if(__MODES[g_CurrentGameMode][modeRespawn]) {
			new Float:flRespawnTime = 1.0;

			if(g_CurrentGameMode == MODE_GUNGAME || g_CurrentGameMode == MODE_MEGA_GUNGAME) {
				flRespawnTime = random_float(0.7, 2.3);
			}

			set_member(victim, m_flRespawnPending, (get_gametime() + flRespawnTime));
		}
	}
}

@CBasePlayer_TakeDamage_Pre(const victim, const inflictor, const attacker, Float:damage, const bits_damage_type) {
	if(!(bits_damage_type & (DMG_NEVERGIB | DMG_BULLET))) {
		return;
	}

	if(victim == attacker || !is_user_connected(attacker)) {
		return;
	}

	if(!rg_is_player_can_takedamage(victim, attacker)) {
		return;
	}

	g_OldVelocityModifier[victim] = get_member(victim, m_flVelocityModifier);
	get_entvar(victim, var_velocity, g_OldVelocity[victim]);

	switch(g_Class[attacker]) {
		case CLASS_HUMAN: {
			new Float:flHab = (float(g_Hab[attacker][HAB_H_DAMAGE]) + float(__HATS[g_HatId[attacker]][hatUpgrade4]) + ((g_AmuletCustomCreated[attacker]) ? g_AmuletCustom[attacker][acDamage] : 0));
			new Float:flPercent = 0.0;
			new Float:flDamage = 0.0;

			if(flHab) {
				flPercent = (float(__HABS[HAB_H_DAMAGE][habValue]) * flHab);
				
				if(flPercent > 0.0) {
					flDamage = ((flPercent * damage) / 100.0);

					if(g_Hab[attacker][HAB_L_VIGOR]) {
						flPercent = (float(__HABS[HAB_L_VIGOR][habValue]) * float(g_Hab[attacker][HAB_L_VIGOR]));

						if(flPercent > 0.0) {
							flDamage += ((flPercent * flDamage) / 100.0);
						}
					}
				}
			}

			damage += flDamage;
		} case CLASS_ZOMBIE: {
			if(g_CurrentGameMode == MODE_NONE) {
				return;
			}

			if(!__MODES[g_CurrentGameMode][modeChangeClass]) {
				return;
			}

			new iActiveItem = get_member(attacker, m_pActiveItem);

			if(is_nullent(iActiveItem)) {
				return;
			}

			if(get_member(iActiveItem, m_iId) != WEAPON_KNIFE) {
				return;
			}

			new Float:flArmorValue = get_entvar(victim, var_armorvalue);
			new Float:flHab = (float(g_Hab[attacker][HAB_Z_DAMAGE]) + float(__HATS[g_HatId[attacker]][hatUpgrade4]) + ((g_AmuletCustomCreated[attacker]) ? g_AmuletCustom[attacker][acDamage] : 0));
			new Float:flPercent = 0.0;
			new Float:flDamage = 0.0;

			if(flHab) {
				flPercent = (float(__HABS[HAB_Z_DAMAGE][habValue]) * flHab);

				if(flPercent > 0.0) {
					flDamage += ((flPercent * damage) / 100.0);
				}
			}

			damage += flDamage;

			if(flArmorValue > 0.0) {
				flArmorValue = floatmax((flArmorValue - damage), 0.0);

				set_entvar(victim, var_armorvalue, flArmorValue);
				SetHookChainArg(4, ATYPE_FLOAT, 0.0);

				rh_emit_sound2(victim, 0, CHAN_BODY, __SOUND_HUMAN_ARMOR_HIT);
			}

			if(flArmorValue > 0.0 || (get_member(victim, m_iKevlar) == ARMOR_VESTHELM && get_member(victim, m_LastHitGroup) == HITGROUP_HEAD)) {
				return;
			}

			new iNumAliveCT;
			rg_initialize_player_counts(_, iNumAliveCT);

			if(iNumAliveCT == 1) {
				return;
			}

			if(!changeClass(victim, attacker, CLASS_ZOMBIE, false)) {
				return;
			}
		} case CLASS_SURVIVOR: {
			damage += (((float(getZombiesAlive()) * 10.0) * damage) / 100.0);

			new Float:flHab = float(g_Hab[attacker][HAB_S_DAMAGE]);
			new Float:flPercent = 0.0;
			new Float:flDamage = 0.0;

			if(flHab) {
				flPercent = (float(__HABS[HAB_S_DAMAGE][habValue]) * flHab);
				
				if(flPercent > 0.0) {
					flDamage = ((flPercent * damage) / 100.0);
				}
			}

			damage += flDamage;
		} case CLASS_WESKER: {
			new Float:flHealth = get_entvar(victim, var_health);

			flHealth *= 15.0;
			flHealth /= 100.0;

			if(flHealth < 200.0) {
				damage = 200.0;
			} else {
				damage = flHealth;
			}
		} case CLASS_SNIPER: {

		} case CLASS_NEMESIS: {
			new iActiveItem = get_member(attacker, m_pActiveItem);

			if(is_nullent(iActiveItem)) {
				return;
			}

			if(get_member(iActiveItem, m_iId) != WEAPON_KNIFE) {
				return;
			}

			new Float:flHab = float(g_Hab[attacker][HAB_N_DAMAGE]);
			new Float:flPercent = 0.0;
			new Float:flDamage = 0.0;

			if(flHab) {
				flPercent = (float(__HABS[HAB_N_DAMAGE][habValue]) * flHab);

				if(flPercent > 0.0) {
					flDamage += ((flPercent * damage) / 100.0);
				}
			}

			damage += flDamage;
		} case CLASS_ASSASSIN: {

		} case CLASS_GRUNT: {

		}
	}

	SetHookChainArg(4, ATYPE_FLOAT, damage);
}

@CBasePlayer_TakeDamage_Post(const victim, const inflictor, const attacker, const Float:damage, const bits_damage_type) {
	if(!(bits_damage_type & (DMG_NEVERGIB | DMG_BULLET))) {
		return;
	}

	if(victim == attacker || !is_user_connected(attacker)) {
		return;
	}
	
	if(!rg_is_player_can_takedamage(victim, attacker)) {
		return;
	}

	if(!is_user_alive(victim)) {
		return;
	}

	switch(get_member(victim, m_flVelocityModifier)) {
		case 0.5: {
			if(g_OldVelocityModifier[victim] != 0.5) {
				set_member(victim, m_flVelocityModifier, __CLASSES[g_Class[victim]][class__VelModFlinch]);
			}
		} case 0.65: {
			if(g_OldVelocityModifier[victim] != 0.65) {
				set_member(victim, m_flVelocityModifier, __CLASSES[g_Class[victim]][class__VelModLargeFlinch]);
			}

			new i;
			new Float:vecOrigin[3];
			new Float:vecOrigin2[3];
			new Float:vecTemp[3];
			new Float:vecAttackVelocity[3];
			new Float:vecVelocity[3];

			get_entvar(victim, var_origin, vecOrigin);
			get_entvar(attacker, var_origin, vecOrigin2);

			for(i = 0; i < 3; ++i) {
				vecTemp[i] = vecOrigin[i] - vecOrigin2[i];
			}

			new Float:flLength = floatsqroot(vecTemp[0] * vecTemp[0] + vecTemp[1] * vecTemp[1] + vecTemp[2] * vecTemp[2]);

			if(flLength != 0.0) {
				flLength = (1.0 / flLength);

				for(i = 0; i < 3; ++i) {
					vecAttackVelocity[i] *= flLength;
				}
			} else {
				vecAttackVelocity = Float:{0.0, 0.0, 1.0};
			}

			for(i = 0; i < 3; ++i) {
				vecVelocity[i] = (g_OldVelocity[victim][i] + (vecAttackVelocity[i] * 1000.0));
			}

			set_entvar(victim, var_velocity, vecVelocity);
		} default: {
			
		}
	}

	new iDataAmmoPacks = 1;
	new iDataCombo = 1;

	switch(g_Class[attacker]) {
		case CLASS_HUMAN: {
			
		} case CLASS_SURVIVOR: {

		} case CLASS_WESKER: {
			if(!g_Hab[attacker][HAB_E_COMBO_WESKER]) {
				iDataCombo = 0;
			}
		} case CLASS_SNIPER: {
			if(!g_Hab[attacker][HAB_E_COMBO_SNIPER]) {
				iDataAmmoPacks = 0;
				iDataCombo = 0;
			}
		}
	}

	if(iDataAmmoPacks) {
		g_AmmoPacks_Damage[attacker] += floatround(damage);

		while(g_AmmoPacks_Damage[attacker] > g_AmmoPacks_DamageNeed[attacker]) {
			g_AmmoPacks_Damage[attacker] -= g_AmmoPacks_DamageNeed[attacker];
			addAmmoPacks(attacker, 1);
		}
	}

	if(iDataCombo && g_ComboDamageNeed[attacker]) {
		g_ComboDamage[attacker] += floatround(damage);
		g_Combo[attacker] = (g_ComboDamage[attacker] / g_ComboDamageNeed[attacker]);

		showCurrentComboHuman(attacker, damage);

		remove_task(attacker + TASK_FINISHCOMBO);

		new Float:flDuration = 5.5;

		if(g_Hab[attacker][HAB_E_DURATION_COMBO]) {
			flDuration += ((float(__HABS[HAB_E_DURATION_COMBO][habValue]) / 2.0) * float(g_Hab[attacker][HAB_E_DURATION_COMBO]));
		}

		set_task(flDuration, "task__FinishCombo", attacker + TASK_FINISHCOMBO);
	}

	g_NextHudInfoTime[victim] = (get_gametime() + 0.1);
}

@CBasePlayer_ResetMaxSpeed_Pre(const id) {
	if(!is_user_alive(id)) {
		return HC_CONTINUE;
	}

	new Float:flSpeed;
	new Float:flHab;

	switch(g_Class[id]) {
		case CLASS_HUMAN: {
			flSpeed = __HUMAN_CLASSES[g_HumanClass[id]][humanClassSpeed];
			flHab = (float(g_Hab[id][HAB_H_SPEED]) + float(__HATS[g_HatId[id]][hatUpgrade2]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acSpeed]) : 0.0));

			if(flHab) {
				flSpeed += ((float(__HABS[HAB_H_SPEED][habValue]) / 2.0) * flHab);
			}
		} case CLASS_ZOMBIE: {
			flSpeed = __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassSpeed];
			flHab = (float(g_Hab[id][HAB_Z_SPEED]) + float(__HATS[g_HatId[id]][hatUpgrade2]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acSpeed]) : 0.0));

			if(flHab) {
				flSpeed += ((float(__HABS[HAB_Z_SPEED][habValue]) / 2.0) * flHab);
			}
		} case CLASS_SURVIVOR: {
			flSpeed = __CLASSES[g_Class[id]][class__Speed];
			flHab = float(g_Hab[id][HAB_S_STATS_BASE]);

			if(flHab) {
				flSpeed += (((float(__HABS[HAB_S_STATS_BASE][habValue]) * flHab) * flSpeed) / 400.0);
			}

			if(g_Diff[id][DIFF_CLASS_SURVIVOR]) {
				flSpeed *= __DIFFS[DIFF_CLASS_SURVIVOR][g_Diff[id][DIFF_CLASS_SURVIVOR]][diffSpeed];
			}
		} case CLASS_NEMESIS: {
			flSpeed = __CLASSES[g_Class[id]][class__Speed];
			flHab = float(g_Hab[id][HAB_N_STATS_BASE]);

			if(flHab) {
				flSpeed += (((float(__HABS[HAB_N_STATS_BASE][habValue]) * flHab) * flSpeed) / 400.0);
			}

			if(g_Diff[id][DIFF_CLASS_NEMESIS]) {
				flSpeed *= __DIFFS[DIFF_CLASS_NEMESIS][g_Diff[id][DIFF_CLASS_NEMESIS]][diffSpeed];
			}
		} default: {
			flSpeed = __CLASSES[g_Class[id]][class__Speed];
		}
	}

	if(!flSpeed) {
		new iActiveItem = get_member(id, m_pActiveItem);
		
		if(!is_nullent(iActiveItem)) {
			ExecuteHamB(Ham_CS_Item_GetMaxSpeed, iActiveItem, flSpeed);
		} else {
			flSpeed = 240.0;
		}
	}

	set_entvar(id, var_maxspeed, flSpeed);
	return HC_SUPERCEDE;
}

@CBasePlayer_ResetMaxSpeed_Post(const id) {
	if(!is_nullent(g_EntFlame[id])) {
		set_entvar(id, var_maxspeed, (Float:get_entvar(id, var_maxspeed) * 0.5));
	}

	if(!is_nullent(g_EntIceCube[id])) {
		set_entvar(id, var_maxspeed, 1.0);
	}
}

@CBasePlayer_PreThink_Post(const id) {
	if(!is_user_alive(id)) {
		return;
	}

	if(!g_LongJump[id][longJump__Enabled]) {
		return;
	}

	new Float:flGameTime = get_gametime();

	if(g_LongJump[id][longJump__NextTime] && g_LongJump[id][longJump__NextTime] <= flGameTime) {
		g_LongJump[id][longJump__NextTime] = 0.0;

		longJumpUpdateIcon(id, ICONSTATE_AVAILABLE);
	}

	if(g_LongJump[id][longJump__KillBeamTime] && g_LongJump[id][longJump__KillBeamTime] <= flGameTime) {
		g_LongJump[id][longJump__KillBeamTime] = 0.0;

		message_begin_f(MSG_ALL, SVC_TEMPENTITY);
		write_byte(TE_KILLBEAM);
		write_short(id);
		message_end();
	}

	if(g_LongJump[id][longJump__NextTime]) {
		return;
	}

	if(get_entvar(id, var_waterlevel) >= 2) {
		return;
	}

	new iFlags = get_entvar(id, var_flags);

	if(iFlags & FL_WATERJUMP) {
		return;
	}

	if(!(iFlags & FL_ONGROUND)) {
		return;
	}

	if(!(get_entvar(id, var_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK))) {
		return;
	}

	new Float:vecVelocity[3];
	get_entvar(id, var_velocity, vecVelocity);

	if(vector_length(vecVelocity) < 50.0) {
		return;
	}

	new Float:vecPunchAngle[3];
	new Float:vecViewForward[3];
	new i;

	get_entvar(id, var_punchangle, vecPunchAngle);
	global_get(glb_v_forward, vecViewForward);

	vecPunchAngle[0] = -5.0;

	for(i  = 0; i < 2; ++i) {
		vecVelocity[i] = vecViewForward[i] * g_LongJump[id][longJump__Force];
	}

	vecVelocity[2] = g_LongJump[id][longJump__Height];

	set_entvar(id, var_velocity, vecVelocity);
	set_entvar(id, var_punchangle, vecPunchAngle);

	if(g_LongJump[id][longJump__Cooldown]) {
		g_LongJump[id][longJump__NextTime] = (flGameTime + g_LongJump[id][longJump__Cooldown]);

		longJumpUpdateIcon(id, ICONSTATE_COOLDOWN);
	}

	g_LongJump[id][longJump__KillBeamTime] = (flGameTime + 1.0);

	// rh_emit_sound2(id, 0, CHAN_ITEM, LONGJUMP_ACTIVATE_SOUND, VOL_NORM, ATTN_NORM);
	
	message_begin_f(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(id);
	write_short(g_ModelIndex_LaserBeam);
	write_byte(10);
	write_byte(10);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	write_byte(255);
	message_end();
}

@CBasePlayer_GiveDefaultItems_Pre(const id) {
	rg_remove_all_items(id);

	if(g_CurrentGameMode != MODE_ARMAGEDDON && g_CurrentGameMode != MODE_MEGA_ARMAGEDDON && g_CurrentGameMode != MODE_DUEL_FINAL && g_CurrentGameMode != MODE_GRUNT) {
		rg_give_item(id, "weapon_knife", GT_APPEND);
	}

	return HC_SUPERCEDE;
}

@CBasePlayer_GiveDefaultItems_Post(const id) {
	changeNightVision(id);

	switch(g_CurrentGameMode) {
		case MODE_GUNGAME: {
			// gunGameGiveWeapons(id);
		} case MODE_MEGA_GUNGAME: {
			// if(!g_ModeMGG_Block) {
				// rg_give_item(id, __MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[id]]);

				// if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != 0) {
					// if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != CSW_HEGRENADE) {
						// ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]], __AMMO_TYPE[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]], __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]]);
					// } else {
						// cs_set_user_bpammo(id, CSW_HEGRENADE, 200);
					// }
				// }
			// }
		} case MODE_DUEL_FINAL: {
			
		} case MODE_GRUNT: {
			
		} default: {
			switch(g_Class[id]) {
				case CLASS_HUMAN: {
					if(g_Weapon_AutoBuy[id]) {
						if(!is_user_alive(id) || !g_CanBuy[id]) {
							return;
						}

						buyPrimaryWeapon(id, g_Weapon_PrimarySelection[id], true);
						buySecondaryWeapon(id, g_Weapon_SecondarySelection[id]);
						buyCuaternaryWeapon(id, g_Weapon_CuaternarySelection[id]);

						g_CanBuy[id] = 0;
						g_Hat_Devil[id] = 1;

						return;
					}

					showMenu__BuyPrimaryWeapons(id);
				} case CLASS_SURVIVOR: {
					rg_give_item(id, "weapon_mp5navy", GT_APPEND);
					setUnlimitedClip(id, true);
				}
			}
		}
	}
}

@CBasePlayer_StartObserver_Post(const id, const Float:vecPosition[3], const Float:vecViewAngle[3]) {
	g_NightVisionEnabled[id] = true;
	set_member(id, m_bHasNightVision, true);
}

@CBasePlayer_Observer_IsValidTarget_Post(const id, const player, const bool:same_team) {
	if(GetHookChainReturn(ATYPE_INTEGER) != player) {
		return;
	}

	g_LastNightVision[id] = g_NightVision[player];
}

@CBasePlayer_HintMessageEx_Pre(const id, const message[], Float:duration, bool:bDisplayIfPlayerDead, bool:bOverride) {
	SetHookChainReturn(ATYPE_BOOL, false);
	return HC_SUPERCEDE;
}

@CBasePlayer_HasRestrictItem_Pre(const id, const ItemID:item, const ItemRestType:type) {
	if(getUserTeam(id) != TEAM_TERRORIST) {
		return HC_CONTINUE;
	}

	SetHookChainReturn(ATYPE_BOOL, true);
	return HC_SUPERCEDE;
}

@CBasePlayer_OnSpawnEquip_Pre(const id, const bool:add_default, const bool:equip_game) {
	SetHookChainArg(3, ATYPE_BOOL, false);
}

@CBasePlayer_Radio_Pre(const id, const msg_id[], const msg_verbose[], const pitch, const bool:show_icon) {
	return HC_SUPERCEDE;
}

@CBasePlayer_UpdateClientData_Post(const id) {
	static Float:flGameTime;
	flGameTime = get_gametime();

	if(is_user_alive(id)) {
		if(!g_NextHudInfoTime[id]) {
			return;
		}

		if(g_NextHudInfoTime[id] > flGameTime) {
			return;
		}

		g_NextHudInfoTime[id] = (flGameTime + 1.0);

		playerInfoHud(id);
	} else {
		if(g_NextSBarUpdateTime[id] > flGameTime) {
			return;
		}

		updateStatusBar(id);

		g_NextSBarUpdateTime[id] = (flGameTime + 0.2);
	}
}

playerInfoHud(const id) {
	SetGlobalTransTarget(id);

	new iLen = 0;
	new sText[512];
	new sAmmoPacks[16];
	new sLevelTotal[16];

	addDot(g_AmmoPacks[id], sAmmoPacks, charsmax(sAmmoPacks));

	switch(g_UserOption_HudStyle[id][HUD_TYPE_GENERAL]) {
		case 0: {
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Vida: %d^n", floatround(get_entvar(id, var_health)));
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Chaleco: %d^n", rg_get_user_armor(id));
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Clase: -^n");
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Ammo Packs: %s^n", sAmmoPacks);

			if(g_UserOption_LevelTotal[id]) {
				addDot(getUserLevelTotal(id), sLevelTotal, charsmax(sLevelTotal));
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Nivel: %s (%0.2f%%)^n", sLevelTotal, g_Level_Percent[id]);
			} else {
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Nivel: %d (%0.2f%%)^n", g_Level[id], g_Level_Percent[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Reset: %d^n", g_Reset[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Prestigio: %s", __PRESTIGE_LETTERS[g_Prestige[id]]);
			}
		} case 1: {
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Vida: %d]^n", floatround(get_entvar(id, var_health)));
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Chaleco: %d]^n", rg_get_user_armor(id));
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Clase: -]^n");
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Ammo Packs: %s]^n", sAmmoPacks);
			
			if(g_UserOption_LevelTotal[id]) {
				addDot(getUserLevelTotal(id), sLevelTotal, charsmax(sLevelTotal));
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Nivel: %s (%0.2f%%)]^n", sLevelTotal, g_Level_Percent[id]);
			} else {
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Nivel: %d (%0.2f%%)]^n", g_Level[id], g_Level_Percent[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Reset: %d]^n", g_Reset[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Prestigio: %s]", __PRESTIGE_LETTERS[g_Prestige[id]]);
			}
		} case 2: {
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Vida: %d - ", floatround(get_entvar(id, var_health)));
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Chaleco: %d - ", rg_get_user_armor(id));
			
			if(g_UserOption_LevelTotal[id]) {
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Clase: -^n");
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Ammo Packs: %s - ", sAmmoPacks);

				addDot(getUserLevelTotal(id), sLevelTotal, charsmax(sLevelTotal));
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Nivel: %s (%0.2f%%)", sLevelTotal, g_Level_Percent[id]);
			} else {
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Clase: - - ");
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Ammo Packs: %s^n", sAmmoPacks);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Nivel: %d (%0.2f%%) - ", g_Level[id], g_Level_Percent[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Reset: %d - ", g_Reset[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Prestigio: %s", __PRESTIGE_LETTERS[g_Prestige[id]]);
			}
		} case 3: {
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Vida: %d] - ", floatround(get_entvar(id, var_health)));
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Chaleco: %d] - ", rg_get_user_armor(id));
			
			if(g_UserOption_LevelTotal[id]) {
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Clase: -]^n");
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Ammo Packs: %s] - ", sAmmoPacks);

				addDot(getUserLevelTotal(id), sLevelTotal, charsmax(sLevelTotal));
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Nivel: %s (%0.2f%%)]", sLevelTotal, g_Level_Percent[id]);
			} else {
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Clase: -] - ");
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Ammo Packs: %s]^n", sAmmoPacks);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Nivel: %d (%0.2f%%)] - ", g_Level[id], g_Level_Percent[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Reset: %d] - ", g_Reset[id]);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "[Prestigio: %s]", __PRESTIGE_LETTERS[g_Prestige[id]]);
			}
		} case 4: {
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), " - Vida: %d - ", floatround(get_entvar(id, var_health)));
			iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Chaleco: %d - ", rg_get_user_armor(id));
			
			if(g_UserOption_LevelTotal[id]) {
				addDot(getUserLevelTotal(id), sLevelTotal, charsmax(sLevelTotal));

				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Clase: - ^n");
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), " - Ammo Packs: %s - Nivel: %s (%0.2f%%) - ", sAmmoPacks, sLevelTotal, g_Level_Percent[id]);
			} else {
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Clase: - - Ammo Packs: %s - ^n", sAmmoPacks);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), " - Nivel: %d (%0.2f%%) - Reset: %d - Prestigio: %s - ", g_Level[id], g_Level_Percent[id], g_Reset[id], __PRESTIGE_LETTERS[g_Prestige[id]]);
			}
		}
	}

	set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD][0], g_UserOption_Color[id][COLOR_TYPE_HUD][1], g_UserOption_Color[id][COLOR_TYPE_HUD][2], g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][0], g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][1], g_UserOption_HudEffect[id][HUD_TYPE_GENERAL], 0.1, 256.0, 0.1, 0.0);
	ShowSyncHudMsg(id, g_HudSync_Info, sText);
}

updateStatusBar(const id) {
	new iNewSBarState[SBAR_END];
	new Float:flGameTime = get_gametime();
	new Float:vecSrc[3];
	new Float:vecEnd[3];
	new Float:vecViewAngle[3];
	new Float:vecPunchAngle[3];
	new Float:vecViewForward[3];
	new Float:flFraction;
	new i;
	new iColor[3];
	new Float:flPosition[2];
	new iEffect = 0;
	new iLen = 0;
	new sText[512];
	new sHealth[16];
	new sAmmoPacks[16];
	new sLevelTotal[16];

	ExecuteHam(Ham_Player_GetGunPosition, id, vecSrc);
	get_entvar(id, var_v_angle, vecViewAngle);
	get_entvar(id, var_punchangle, vecPunchAngle);
	
	for(i = 0; i < 3; ++i) {
		vecViewAngle[i] += vecPunchAngle[i];
	}

	angle_vector(vecViewAngle, ANGLEVECTOR_FORWARD, vecViewForward);

	for(i = 0; i < 3; ++i) {
		vecEnd[i] = (vecSrc[i] + (vecViewForward[i] * 2048.0));
	}

	engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, 0);
	get_tr2(0, TR_flFraction, flFraction);

	if(flFraction < 1.0) {
		new iHit = get_tr2(0, TR_pHit);

		if(is_user_connected(iHit)) {
			new iObserverMode = get_entvar(id, var_iuser1);
			new bool:bSameTeam = (getUserTeam(iHit) == getUserTeam(id));

			iNewSBarState[SBAR_TARGET_TYPE] = ((bSameTeam) ? SBAR_TARGETTYPE_TEAMMATE : SBAR_TARGETTYPE_ENEMY);
			iNewSBarState[SBAR_TARGET_ID] = iHit;

			if(is_user_alive(id)) {
				flPosition[0] = -1.0;
				flPosition[1] = -1.0;

				if(bSameTeam) {
					iColor[0] = 0;
					iColor[1] = 0;
					iColor[2] = 255;

					SetGlobalTransTarget(id);

					iLen = 0;
					iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Aliado: %n", iHit);
				} else if(g_pCVar_PlayerId != PLAYERID_MODE_TEAMONLY) {
					iColor[0] = 255;
					iColor[1] = 0;
					iColor[2] = 0;

					SetGlobalTransTarget(id);

					iLen = 0;
					iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Enemigo: %n", iHit);
				} else {
					ClearSyncHud(id, g_HudSync_StatusBar);
					return;
				}

				iNewSBarState[SBAR_TARGET_HEALTH] = floatround(get_entvar(iHit, var_health));
				iNewSBarState[SBAR_TARGET_ARMOR] = rg_get_user_armor(iHit);

				if(g_Class[iHit] == CLASS_HUMAN) {
					iNewSBarState[SBAR_TARGET_CLASS] = g_HumanClass[iHit];
				} else if(g_Class[iHit] == CLASS_ZOMBIE) {
					iNewSBarState[SBAR_TARGET_CLASS] = g_ZombieClass[iHit];
				} else {
					iNewSBarState[SBAR_TARGET_CLASS] = g_Class[iHit];
				}

				iNewSBarState[SBAR_TARGET_AMMOPACKS] = g_AmmoPacks[iHit];

				if(g_UserOption_LevelTotal[iHit]) {
					iNewSBarState[SBAR_TARGET_LEVEL] = getUserLevelTotal(iHit);
				} else {
					iNewSBarState[SBAR_TARGET_LEVEL] = g_Level[iHit];
					iNewSBarState[SBAR_TARGET_RESET] = g_Reset[iHit];
					iNewSBarState[SBAR_TARGET_PRESTIGE] = g_Prestige[iHit];
				}
			} else if(iObserverMode != OBS_NONE) {
				iColor[0] = g_UserOption_Color[iHit][COLOR_TYPE_HUD][0];
				iColor[1] = g_UserOption_Color[iHit][COLOR_TYPE_HUD][1];
				iColor[2] = g_UserOption_Color[iHit][COLOR_TYPE_HUD][2];
				
				flPosition[0] = 1.5;
				flPosition[1] = 0.6;

				iEffect = g_UserOption_HudEffect[iHit][HUD_TYPE_GENERAL];

				SetGlobalTransTarget(id);

				addDot(floatround(get_entvar(iHit, var_health)), sHealth, charsmax(sHealth));
				addDot(g_AmmoPacks[iHit], sAmmoPacks, charsmax(sAmmoPacks));

				iLen = 0;
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Siguiendo: %n^n", iHit);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Vida: %s^n", sHealth);
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Chaleco: %d^n", rg_get_user_armor(iHit));
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Clase: -^n");
				iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Ammo Packs: %s^n", sAmmoPacks);

				if(g_UserOption_LevelTotal[iHit]) {
					addDot(getUserLevelTotal(iHit), sLevelTotal, charsmax(sLevelTotal));
					iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Nivel: %s (%0.2f%%)", sLevelTotal, g_Level_Percent[iHit]);
				} else {
					iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Nivel: %d (%0.2f%%)^n", g_Level[iHit], g_Level_Percent[iHit]);
					iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Reset: %d^n", g_Reset[iHit]);
					iLen += formatex(sText[iLen], (charsmax(sText) - iLen), "Prestige: %s", __PRESTIGE_LETTERS[g_Prestige[iHit]]);
				}
			} else {
				ClearSyncHud(id, g_HudSync_StatusBar);
				return;
			}
		}
	}

	new bool:bForceResend;

	if(g_StatusBarDisappearDelay[id] > flGameTime) {
		for(i = 0; i < SBAR_END; ++i) {
			if(iNewSBarState[i] == g_StatusBarState[id][i]) {
				continue;
			}

			g_StatusBarState[id][i] = iNewSBarState[i];
			bForceResend = true;
		}
	} else {
		bForceResend = true;
	}

	if(!bForceResend) {
		return;
	}

	g_StatusBarDisappearDelay[id] = (flGameTime + 5.0);

	set_hudmessage(iColor[0], iColor[1], iColor[2], flPosition[0], flPosition[1], iEffect, 0.1, 5.1, 0.1, 0.0);
	ShowSyncHudMsg(id, g_HudSync_StatusBar, sText);
}

@clcmd__AmountOfPoints(const id) {
	new sAmount[8];
	read_args(sAmount, charsmax(sAmount));
	remove_quotes(sAmount);
	trim(sAmount);

	g_MenuData_PointIn_Add[id] = str_to_num(sAmount);
	g_MenuData_PointIn_CostMoney[id] = (g_MenuData_PointIn_Add[id] * __POINTS[g_MenuData_Point[id]][pointCost]);

	showMenu__ShopPointsIn(id);
	return PLUGIN_HANDLED;
}

@clcmd__CreateClan(const id) {
	if(g_ClanSlot[id]) {
		return PLUGIN_HANDLED;
	}

	new sClan[14];
	read_args(sClan, charsmax(sClan));
	remove_quotes(sClan);
	trim(sClan);
	
	if(getUserClanBadString(sClan)) {
		clientPrintColor(id, _, "Solo letras y algunos símbolos: !g( ) [ ] { } - = . , : !!y, se permiten espacios.");

		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	new iLenClan;
	iLenClan = strlen(sClan);
	
	if(iLenClan < 2) {
		clientPrintColor(id, _, "El nombre del clan debe tener al menos 2 caracteres.");
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	} else if(iLenClan > 14) {
		clientPrintColor(id, _, "El nombre del clan debe tener menos de 14 caracteres.");
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	copy(g_TempClanName[id], charsmax(g_TempClanName[]), sClan);
	
	new iArgs[1];
	iArgs[0] = id;
	
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT `id` FROM `zp9_clans` WHERE (`clan_name`=^"%s^") LIMIT 1;", sClan);
	SQL_ThreadQuery(g_SqlTuple, "@sqlThread__CheckClanName", g_SqlQuery, iArgs, sizeof(iArgs));
	
	return PLUGIN_HANDLED;
}

public bool:getUserClanBadString(const clan_name[]) {
	new const __LETTERS_AND_SIMBOLS_ALLOWED[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '(', ')', '[', ']', '{', '}', '-', '=', '.', ',', ':', '!', ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
	new iLen = strlen(clan_name);
	new i;
	new j = 0;
	new k;

	for(i = 0; i < iLen; ++i) {
		for(k = 0; k < sizeof(__LETTERS_AND_SIMBOLS_ALLOWED); ++k) {
			if(clan_name[i] == __LETTERS_AND_SIMBOLS_ALLOWED[k]) {
				++j;
			}
		}
	}

	if(iLen != j) {
		return true;
	}

	return false;
}

@sqlThread__CheckClanName(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];
	
	if(!is_user_connected(iId)) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_LOG_FILE, "sqlThread__CheckClanName() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al realizar una consulta. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	if(!SQL_NumResults(query)) {
		new iClanSlot = clanFindSlot();

		if(!iClanSlot) {
			showMenu__Clan(iId);
			return;
		}

		new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_clans` (`clan_name`, `clan_timestamp`) VALUES (^"%s^", '%d');", g_TempClanName[iId], get_arg_systime());
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(iId, sqlQuery, 5);
		} else {
			new iClanId = SQL_GetInsertId(sqlQuery);

			SQL_FreeHandle(sqlQuery);
			
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_clans_members` (`acc_id`, `clan_id`, `owner`, `since_connection`, `last_connection`) VALUES ('%d', '%d', '1', '%d', '%d');", dg_get_user_acc_id(iId), iClanId, get_arg_systime(), get_arg_systime());
			
			if(!SQL_Execute(sqlQuery)) {
				executeQuery(iId, sqlQuery, 6);
			} else {
				SQL_FreeHandle(sqlQuery);

				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_pjs` SET `clan_id`='%d' WHERE (`acc_id`='%d');", iClanId, dg_get_user_acc_id(iId));

				if(!SQL_Execute(sqlQuery)) {
					executeQuery(iId, sqlQuery, 7);
				} else {
					SQL_FreeHandle(sqlQuery);
				}

				g_ClanSlot[iId] = iClanSlot;

				g_Clan[g_ClanSlot[iId]][clanId] = iClanId;
				copy(g_Clan[g_ClanSlot[iId]][clanName], 31, g_TempClanName[iId]);
				g_Clan[g_ClanSlot[iId]][clanSince] = get_arg_systime();
				g_Clan[g_ClanSlot[iId]][clanDeposit] = 0;
				g_Clan[g_ClanSlot[iId]][clanKillHmDone] = 0;
				g_Clan[g_ClanSlot[iId]][clanKillZmDone] = 0;
				g_Clan[g_ClanSlot[iId]][clanInfectDone] = 0;
				g_Clan[g_ClanSlot[iId]][clanVictory] = 0;
				g_Clan[g_ClanSlot[iId]][clanVictoryConsec] = 0;
				g_Clan[g_ClanSlot[iId]][clanVictoryConsecHistory] = 0;
				g_Clan[g_ClanSlot[iId]][clanChampion] = 0;
				g_Clan[g_ClanSlot[iId]][clanRank] = 0;
				g_Clan[g_ClanSlot[iId]][clanCountMembers] = 1;
				g_Clan[g_ClanSlot[iId]][clanCountOnlineMembers] = 1;
				
				resetDataClanMembers(g_ClanSlot[iId]);

				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberId] = dg_get_user_acc_id(iId);
				formatex(g_ClanMembers[g_ClanSlot[iId]][0][clanMemberName], 31, "%n", iId);
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberOwner] = 1;
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberSinceDay] = 0;
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberSinceHour] = 0;
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberSinceMinute] = 0;
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLastTimeDay] = 0;
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLastTimeHour] = 0;
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLastTimeMinute] = 0;
				g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLevelTotal] = getUserLevelTotal(iId);
				
				clientPrintColor(0, _, "!t%n!y creo el clan !g%s!y.", iId, g_Clan[g_ClanSlot[iId]][clanName]);
				showMenu__Clan(iId);
			}
		}
	} else {
		clientPrintColor(iId, _, "Ese nombre de clan ya existe, elija otro por favor.");
		showMenu__Clan(iId);
	}
}

clanFindSlot() {
	new i;
	for(i = 1; i < (MAX_PLAYERS + 1); ++i) {
		if(!g_Clan[i][clanId]) {
			return i;
		}
	}

	return 0;
}

getClanPerks(const id) {
	new i;
	new iCount = 0;

	for(i = 0; i < structIdClanPerks; ++i) {
		if(g_ClanPerks[g_ClanSlot[id]][i]) {
			++iCount;
		}
	}

	return iCount;
}

getClanMemberEmptySlot(const id) {
	new i;
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
			continue;
		}

		return i;
	}

	return -1;
}

getClanMemberSlotId(const id) {
	new i;
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] == dg_get_user_acc_id(id)) {
			return i;
		}
	}

	return -1;
}

resetDataClanMembers(const clan_slot) {
	new i;
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		g_ClanMembers[clan_slot][i][clanMemberId] = 0;
		g_ClanMembers[clan_slot][i][clanMemberName][0] = EOS;
		g_ClanMembers[clan_slot][i][clanMemberOwner] = 0;
		g_ClanMembers[clan_slot][i][clanMemberSinceDay] = 0;
		g_ClanMembers[clan_slot][i][clanMemberSinceHour] = 0;
		g_ClanMembers[clan_slot][i][clanMemberSinceMinute] = 0;
		g_ClanMembers[clan_slot][i][clanMemberLastTimeDay] = 0;
		g_ClanMembers[clan_slot][i][clanMemberLastTimeHour] = 0;
		g_ClanMembers[clan_slot][i][clanMemberLastTimeMinute] = 0;
		g_ClanMembers[clan_slot][i][clanMemberTimePlayed][0] = EOS;
		g_ClanMembers[clan_slot][i][clanMemberLevelTotal] = 0;
	}

	for(i = 0; i < structIdClanPerks; ++i) {
		g_ClanPerks[clan_slot][i] = 0;
	}
}

getClanMemberRange(const id) {
	new i;
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] == dg_get_user_acc_id(id)) {
			return g_ClanMembers[g_ClanSlot[id]][i][clanMemberOwner];
		}
	}

	return 0;
}

sendClanMessage(const id, const input[], any:...) {
	new sMessage[191];
	new i;

	vformat(sMessage, charsmax(sMessage), input, 3);

	for(i = 1; i <= MaxClients; ++i) {
		if(g_ClanSlot[id] == g_ClanSlot[i]) {
			clientPrintColor(i, _, sMessage);
		}
	}
}

clanCheckRequiredCombo(const id) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new i;
	new iRequiredCombo = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		if(g_ClanSlot[id] != g_ClanSlot[i]) {
			continue;
		}

		if(g_Class[i] != CLASS_HUMAN) {
			continue;
		}

		iRequiredCombo += g_ComboDamageNeed[i];
	}

	if(iRequiredCombo < 2) {
		iRequiredCombo = 2;
	}

	g_ClanComboDamageNeed[g_ClanSlot[id]] = iRequiredCombo;
}

/*public clanShowCombo(const id)
{
	if(g_Mode == MODE_ANNIHILATOR)
		return;

	if(!g_ClanSlot[id])
		return;

	if(!g_ClanPerks[g_ClanSlot[id]][CP_COMBO])
		return;

	if(g_Clan[g_ClanSlot[id]][clanHumans] <= 1)
		return;

	g_ClanComboTime[g_ClanSlot[id]] = (halflife_time() + 5.0);

	while(g_ClanComboReward[g_ClanSlot[id]] < sizeof(CLAN_COMBO_HUMAN))
	{
		if(g_ClanCombo[g_ClanSlot[id]] >= CLAN_COMBO_HUMAN[g_ClanComboReward[g_ClanSlot[id]]] && g_ClanCombo[g_ClanSlot[id]] < CLAN_COMBO_HUMAN[g_ClanComboReward[g_ClanSlot[id]] + 1])
			break;

		++g_ClanComboReward[g_ClanSlot[id]];
	}

	static sCombo[16];
	static sReward[16];
	static sDamageTotal[16];

	addDot(g_ClanCombo[g_ClanSlot[id]], sCombo, charsmax(sCombo));
	addDot(((g_ClanCombo[g_ClanSlot[id]] * (g_ClanComboReward[g_ClanSlot[id]] + 1)) * (g_ClanPerks[g_ClanSlot[id]][CP_MULTIPLE_COMBO] + 1)), sReward, charsmax(sReward));
	addDot(floatround(g_ClanComboDamage[g_ClanSlot[id]]), sDamageTotal, charsmax(sDamageTotal));

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i])
			continue;

		if(g_ClanSlot[id] != g_ClanSlot[i])
			continue;

		if(g_Class[i] != CLASS_HUMAN)
			continue;

		set_hudmessage(255, 255, 255, g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][0], g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][1], g_UserOption_EffectHud[i][HUD_TYPE_CLAN_COMBO], 0.0, 8.0, 0.0, 0.0, -1);

		if(!g_UserOption_AbreviateHud[i][HUD_TYPE_CLAN_COMBO])
			ShowSyncHudMsg(i, g_HudSync_ClanCombo, "%s [%d]^nCombo x%s | +%s XP^nDaño total: %s", g_Clan[g_ClanSlot[id]][clanName], g_Clan[g_ClanSlot[id]][clanHumans], sCombo, sReward, sDamageTotal);
		else
			ShowSyncHudMsg(i, g_HudSync_ClanCombo, "%s [%d]^nCombo x%s | +%s XP^n%s", g_Clan[g_ClanSlot[id]][clanName], g_Clan[g_ClanSlot[id]][clanHumans], sCombo, sReward, sDamageTotal);
	}
}

public clanFinishCombo(const id)
{
	if(g_Mode == MODE_ANNIHILATOR)
		return;

	if(!g_ClanSlot[id])
		return;

	static iCombo;
	iCombo = g_ClanCombo[g_ClanSlot[id]];

	g_ClanCombo[g_ClanSlot[id]] = 0;
	g_ClanComboTime[g_ClanSlot[id]] = (halflife_time() + 9999999.9);

	if(iCombo > 0)
	{
		static iReward;
		static sReward[16];
		static sDamageTotal[16];

		iReward = ((iCombo * (g_ClanComboReward[g_ClanSlot[id]] + 1)) * (g_ClanPerks[g_ClanSlot[id]][CP_MULTIPLE_COMBO] + 1));
		addDot(iReward, sReward, charsmax(sReward));
		addDot(floatround(g_ClanComboDamage[g_ClanSlot[id]]), sDamageTotal, charsmax(sDamageTotal));

		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;

			if(g_ClanSlot[id] != g_ClanSlot[i])
				continue;

			if(g_Class[i] != CLASS_HUMAN)
				continue;

			set_hudmessage(255, 255, 255, g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][0], g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][1], g_UserOption_EffectHud[i][HUD_TYPE_CLAN_COMBO], 0.0, 8.0, 0.0, 0.0, -1);
			ShowSyncHudMsg(i, g_HudSync_ClanCombo, "%s^nGanaste %s de XP^nDaño total: %s", g_Clan[g_ClanSlot[id]][clanName], sReward, sDamageTotal);

			addXP(i, iReward);
		}
	}

	g_ClanComboReward[g_ClanSlot[id]] = 0;
	g_ClanComboDamage[g_ClanSlot[id]] = 0.0;
}*/

clanUpdateHumans(const id) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new i;
	new iHumans = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		if(g_ClanSlot[id] != g_ClanSlot[i]) {
			continue;
		}

		if(g_Class[i] != CLASS_HUMAN) {
			continue;
		}

		++iHumans;
	}

	g_Clan[g_ClanSlot[id]][clanHumans] = iHumans;
	clanCheckRequiredCombo(id);
}

@clcmd__Modes(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[8];
	new iMode;

	read_argv(1, sArg1, charsmax(sArg1));
	iMode = str_to_num(sArg1);

	if(read_argc() < 2) {
		console_print(id, "");

		new i;
		for(i = MODE_INFECTION; i < structIdModes; ++i) {
			consolePrint(id, "%d = %s", i, __MODES[i][modeName]);
		}

		console_print(id, "");
		return PLUGIN_HANDLED;
	}

	if(!get_member_game(m_bGameStarted)) {
		consolePrint(id, "!m_bGameStarted");
		return PLUGIN_HANDLED;
	}

	if(!get_member_game(m_bFreezePeriod)) {
		consolePrint(id, "!m_bFreezePeriod");
		return PLUGIN_HANDLED;
	}

	g_ForceGameMode = iMode;

	set_member_game(m_iRoundTimeSecs, 0);
	return PLUGIN_HANDLED;
}

@clcmd__AmmoPacks(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new iPlayer;
	new iAmmoPacks;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_ammopacks <nombre> <cantidad>.");
		return PLUGIN_HANDLED;
	}

	iPlayer = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	iAmmoPacks = str_to_num(sArg2);

	if(!iPlayer || !allowedGaveRewards(iPlayer, 1, 0, 0)) {
		return PLUGIN_HANDLED;
	}

	new sAmmoPacks[16];
	addDot(iAmmoPacks, sAmmoPacks, charsmax(sAmmoPacks));
	
	if(sArg2[0] == '+') {
		clientPrintColor(iPlayer, id, "!t%n!y te ha sumado !g%s!y Ammo Packs.", id, sArg2);
		consolePrint(id, "Le has sumado %s Ammo Packs a %n.", sArg2, iPlayer);

		addAmmoPacks(iPlayer, iAmmoPacks);
	} else {
		clientPrintColor(iPlayer, id, "!t%n!y te ha seteado !g%s!y Ammo Packs.", id, sArg2);
		consolePrint(id, "Le has seteado %s Ammo Packs a %n.", sArg2, iPlayer);

		addAmmoPacks(iPlayer, iAmmoPacks, 1);
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__Level(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new iPlayer;
	new iLevel;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_level <nombre> <cantidad>.");
		return PLUGIN_HANDLED;
	}

	iLevel = str_to_num(sArg2);

	if(equal(sArg1, "@connected")) {
		for(new i = 1; i <= MaxClients; i++) {
			if(!is_user_connected(i)) {
				continue;
			}

			if((g_Level[i] + iLevel) < 0 || (g_Level[i] + iLevel) > MAX_LEVELS) {
				consolePrint(id, "El usuario <%n> no lo pudo recibir.", i);
				continue;
			}
			
			g_Level[i] += iLevel;
			g_AmmoPacks[i] = __ammoPacksThisLevelRest(i, g_Level[i]);
		}
		
		clientPrint(0, id, "!t%n!y le ha dado a todos los jugadores conectados !g%d nivel%s!y.", id, iLevel, ((iLevel == 1) ? "" : "es"));
		return PLUGIN_HANDLED;
	} else if(equal(sArg1, "@alived")) {
		for(new i = 1; i <= MaxClients; i++) {
			if(!is_user_alive(i)) {
				continue;
			}

			if((g_Level[i] + iLevel) < 0 || (g_Level[i] + iLevel) > MAX_LEVELS) {
				consolePrint(id, "El usuario <%n> no lo pudo recibir.", i);
				continue;
			}
			
			g_Level[i] += iLevel;
			g_AmmoPacks[i] = __ammoPacksThisLevelRest(i, g_Level[i]);
		}
		
		clientPrint(0, id, "!t%n!y le ha dado a todos los jugadores vivos !g%d nivel%s!y.", id, iLevel, ((iLevel == 1) ? "" : "es"));
		return PLUGIN_HANDLED;
	}

	iPlayer = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iPlayer) {
		return PLUGIN_HANDLED;
	}
	
	if(sArg2[0] == '+') {
		if((g_Level[iPlayer] + iLevel) < 0 || (g_Level[iPlayer] + iLevel) > MAX_LEVELS) {
			return PLUGIN_HANDLED;
		}

		g_Level[iPlayer] += iLevel;
		g_AmmoPacks[iPlayer] = __ammoPacksThisLevelRest(iPlayer, g_Level[iPlayer]);

		clientPrintColor(iPlayer, id, "!t%n!y te ha sumado !g%d!y nivel%s.", id, iLevel, ((iLevel == 1) ? "" : "es"));
		consolePrint(id, "Le has sumado %d nivel%s a %n.", iLevel, ((iLevel == 1) ? "" : "es"), iPlayer);
	} else {
		if(!allowedGaveRewards(iPlayer, iLevel, 0, 0)) {
			return PLUGIN_HANDLED;
		}

		g_Level[iPlayer] = iLevel;
		g_AmmoPacks[iPlayer] = __ammoPacksThisLevelRest(iPlayer, iLevel);

		clientPrintColor(iPlayer, id, "!t%n!y te ha seteado !g%d!y nivel%s.", id, iLevel, ((iLevel == 1) ? "" : "es"));
		consolePrint(id, "Le has seteado %d nivel%s a %n.", iLevel, ((iLevel == 1) ? "" : "es"), iPlayer);
	}

	return PLUGIN_HANDLED;
}

@clcmd__Reset(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new iPlayer;
	new iReset;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_reset <nombre> <cantidad>.");
		return PLUGIN_HANDLED;
	}

	iPlayer = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	iReset = str_to_num(sArg2);
	
	if(!iPlayer || !allowedGaveRewards(iPlayer, 1, iReset, 0)) {
		return PLUGIN_HANDLED;
	}
	
	g_Reset[iPlayer] = iReset;
	g_AmmoPacks[iPlayer] = __ammoPacksThisLevelRest(iPlayer, g_Level[iPlayer]);
	
	consolePrint(id, "Le has seteado a %n el reset %d.", iPlayer, g_Reset[iPlayer]);
	return PLUGIN_HANDLED;
}

@clcmd__Prestige(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new iPlayer;
	new iPrestige;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_prestige <nombre> <rango>.");
		return PLUGIN_HANDLED;
	}

	iPlayer = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	iPrestige = str_to_num(sArg2);

	if(!iPlayer || !allowedGaveRewards(iPlayer, 1, 0, iPrestige)) {
		return PLUGIN_HANDLED;
	}

	g_Prestige[iPlayer] = iPrestige;

	consolePrint(id, "Le has seteado el prestigio %s a %n.", __PRESTIGE_LETTERS[g_Prestige[iPlayer]], iPlayer);
	return PLUGIN_HANDLED;
}

@clcmd__Points(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[2];
	new sArg3[8];
	new iPlayer;
	new iPoint;
	new sPoint[16];
	new iAmount;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(2, sArg3, charsmax(sArg3));

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_points <nombre> <tipo de puntos> <cantidad>.");
		return PLUGIN_HANDLED;
	}

	iPlayer = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	switch(sArg2[0]) {
		case 'M': {
			iPoint = P_MONEY;
			formatex(sPoint, charsmax(sPoint), " monedas");
		} case 'H': {
			iPoint = P_HUMAN;
			formatex(sPoint, charsmax(sPoint), "pH");
		} case 'Z': {
			iPoint = P_ZOMBIE;
			formatex(sPoint, charsmax(sPoint), "pZ");
		} case 'S': {
			iPoint = P_LEGACY;
			formatex(sPoint, charsmax(sPoint), "pL");
		} case 'N': {
			iPoint = P_LEGACY;
			formatex(sPoint, charsmax(sPoint), "pL");
		} case 'F': {
			iPoint = P_FRAGMENT;
			formatex(sPoint, charsmax(sPoint), "pF");
		} case 'D': {
			iPoint = P_DIAMOND;
			formatex(sPoint, charsmax(sPoint), " DIAMANTES");
		}
	}

	iAmount = str_to_num(sArg3);

	if(!iPlayer) {
		return PLUGIN_HANDLED;
	}

	new sAmount[8];
	addDot(iAmount, sAmount, charsmax(sAmount));

	if(sArg3[0] == '+') {
		clientPrintColor(iPlayer, id, "!t%n!y te ha sumado !g%s%s!y.", id, sAmount, sPoint);
		consolePrint(id, "Le has sumado %s Ammo Packs a %n.", sArg2, iPlayer);

		g_Point[iPlayer][iPoint] += iAmount;
	} else {
		clientPrintColor(iPlayer, id, "!t%n!y te ha seteado !g%s%s!y.", id, sAmount, sPoint);
		consolePrint(id, "Le has seteado %s Ammo Packs a %n.", sArg2, iPlayer);

		g_Point[iPlayer][iPoint] = iAmount;
	}

	return PLUGIN_HANDLED;
}

@clcmd__Spect(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(getUserTeam(id) == TEAM_SPECTATOR) {
		rgSetUserTeam(id, TEAM_CT, MODEL_UNASSIGNED);
	} else {
		if(is_user_alive(id)) {
			ExecuteHamB(Ham_Killed, id, id, GIB_NEVER);
			set_entvar(id, var_frags, get_entvar(id, var_frags));
		}

		rgSetUserTeam(id, TEAM_SPECTATOR, MODEL_AUTO);
	}

	return PLUGIN_HANDLED;
}

@clcmd__BlockCommands(const id) {
	return PLUGIN_HANDLED;
}

@clcmd__Radio1(const id) {
	return PLUGIN_HANDLED;
}

@clcmd__Radio2(const id) {
	return PLUGIN_HANDLED;
}

@clcmd__Radio3(const id) {
	return PLUGIN_HANDLED;
}

@clcmd__Drop(const id) {
	if(dg_get_user_acc_id(id) == 1) {
		new Float:vecOrigin[3];
		new Float:vecEndOrigin[3];
		new Float:flFraction;

		get_entvar(id, var_origin, vecOrigin);
		getDropOrigin(id, vecEndOrigin, 20);

		engfunc(EngFunc_TraceLine, vecOrigin, vecEndOrigin, IGNORE_MONSTERS, id, 0);
		get_tr2(0, TR_flFraction, flFraction);

		if(flFraction == 1.0) {
			dropHeadZombie(id);
		}
	}

	return PLUGIN_HANDLED;
}

@clcmd__BuyAmmo1(const id, const InventorySlotType:slot_type) {
	return PLUGIN_HANDLED;
}

@clcmd__BuyAmmo2(const id, const InventorySlotType:slot_type) {
	return PLUGIN_HANDLED;
}

@clcmd__NightVision(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(!get_member(id, m_bHasNightVision)) {
		return PLUGIN_HANDLED;
	}

	new Float:flGameTime = get_gametime();

	if(get_member(id, m_flLastCommandTime, CMD_NIGHTVISION) <= flGameTime) {
		set_member(id, m_flLastCommandTime, (flGameTime + 0.3), CMD_NIGHTVISION);

		if(g_NightVisionEnabled[id]) {
			rh_emit_sound2(id, 0, CHAN_ITEM, "items/nvg_off.wav", random_float(0.92, 1.0), ATTN_NORM);
			setNightVision(id, false);
		} else {
			rh_emit_sound2(id, 0, CHAN_ITEM, "items/nvg_on.wav", random_float(0.92, 1.0), ATTN_NORM);
			setNightVision(id, true);
		}
	}

	return PLUGIN_HANDLED;
}

showMenu__Game(const id) {
	SetGlobalTransTarget(id);

	new sAmmoPacksRest[16];
	addDot(g_AmmoPacks_Rest[id], sAmmoPacksRest, charsmax(sAmmoPacksRest));

	oldmenu_create("\y%s - %s \r(v%s)^n\wAmmo Packs restantes\r:\y %s", "@menu__Game", __PLUGIN_COMMUNITY_NAME, __SERVERS[g_ServerId][serverName], __PLUGIN_VERSION, sAmmoPacksRest);

	oldmenu_additem(1, 1, "\r1.\w ARMAS");

	if(!get_member_game(m_bRoundTerminating) && is_user_alive(id)) {
		oldmenu_additem(2, 2, "\r2.\w ITEMS EXTRAS");
	} else {
		oldmenu_additem(-1, -1, "\d2. ITEMS EXTRAS");
	}

	oldmenu_additem(3, 3, "\r3.\w MI PERSONAJE^n");

	oldmenu_additem(4, 4, "\r4.\w CLAN");
	oldmenu_additem(5, 5, "\r5.\w OPCIONES DE USUARIO");
	oldmenu_additem(6, 6, "\r6.\w ESTADÍSTICAS^n");

	oldmenu_additem(7, 7, "\r7.\y REGLAS");
	oldmenu_additem(8, 8, "\r8.\w TIENDA DE PUNTOS^n");

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

@menu__Game(const id, const item) {
	if(!item) {
		return;
	}

	switch(item) {
		case 1: {
			showMenu__Weapons(id);
		} case 2: {
			showMenu__Items(id);
		} case 3: {
			showMenu__Character(id);
		} case 4: {
			showMenu__Clan(id);
		} case 5: {
			showMenu__UserOptions(id);
		} case 6: {
			showMenu__Stats(id);
		} case 7: {
			clientPrintColor(id, _, "!gEs obligatorio que lean las reglas del servidor!y.");
			clientPrintColor(id, _, "Para poder leer las mismas y no tener inconvenientes, visita el siguiente enlace:");
			clientPrintColor(id, _, "!thttps://www.drunkgaming.net/servidores/8-zombie-plague/!y.");

			showMenu__Game(id);
		} case 8: {
			showMenu__ShopPoints(id);
		}
	}
}

showMenu__Items(const id) {
	SetGlobalTransTarget(id);

	if(get_member_game(m_bRoundTerminating) || !is_user_alive(id)) {
		return;
	}

	new iMenuId;
	new i;
	new iLevelTotal;
	new iCost;
	new sCost[16];
	new sLevelTotal[16];
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("ITEMS EXTRAS", "@menu__Items");

	for(i = 0; i < structIdExtraItems; ++i) {
		if(g_Class[id] != __EXTRA_ITEMS[i][extraItemClass]) {
			continue;
		}

		iLevelTotal = __EXTRA_ITEMS[i][extraItemLevelTotal];
		iCost = getExtraItemCost(id, i);

		if(getUserLevelTotal(id) >= iLevelTotal) {
			addDot(iCost, sCost, charsmax(sCost));

			if(g_AmmoPacks[id] >= iCost) {
				formatex(sItem, charsmax(sItem), "\w%s \y(%s Ammo Packs)", __EXTRA_ITEMS[i][extraItemName], sCost);
			} else {
				formatex(sItem, charsmax(sItem), "\d%s \r(%s Ammo Packs)", __EXTRA_ITEMS[i][extraItemName], sCost);
			}
		} else {
			if(g_UserOption_LevelTotal[id]) {
				addDot(iLevelTotal, sLevelTotal, charsmax(sLevelTotal));
				formatex(sItem, charsmax(sItem), "\d%s \r(N: %s)", __EXTRA_ITEMS[i][extraItemName], sLevelTotal);
			} else {
				formatex(sItem, charsmax(sItem), "\d%s \r(%s)", __EXTRA_ITEMS[i][extraItemName], getLevelTotalRequired(iLevelTotal));
			}
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId);
}

getLevelTotalRequired(const level_total) {
	new Float:flDivPrestige = ((float(level_total) / float(MAX_LEVELS)) / float(MAX_RESETS));

	if(flDivPrestige >= float(MAX_PRESTIGE)) {
		flDivPrestige = float(MAX_PRESTIGE);
	}

	new iLevel = (level_total % MAX_LEVELS);
	new iPrestige = (((floatround((flDivPrestige * float(MAX_RESETS) * float(MAX_LEVELS))) - iLevel) / MAX_LEVELS) / MAX_RESETS);
	
	if(iPrestige >= MAX_PRESTIGE) {
		iPrestige = MAX_PRESTIGE;
	}

	new Float:flDivReset = (float(level_total) / float(MAX_LEVELS));
	new iReset = (((floatround((flDivReset * float(MAX_LEVELS))) - iLevel) / MAX_LEVELS) - (iPrestige * (MAX_RESETS + 1)));
	new sBuffer[32];

	if(iPrestige) {
		formatex(sBuffer, charsmax(sBuffer), "%s ~ %d.%d", __PRESTIGE_LETTERS[iPrestige], iReset, iLevel);
	} else {
		formatex(sBuffer, charsmax(sBuffer), "%d.%d", iReset, iLevel);
	}
	
	return sBuffer;
}

getExtraItemCost(const id, const extra_item) {
	new iCost = g_ExtraItem_Cost[id][extra_item];

	// if(__HATS[g_HatId[id]][hatUpgrade8]) {
		// iCost = (iCost - ((iCost * __HATS[g_HatId[id]][hatUpgrade8]) / 100));
	// }

	// if(g_ArtifactsEquiped[id][ARTIFACT_RING_EXTRA_ITEM_COST]) {
		// new iPercent = 0;
		// new iTotal = 0;

		// switch(g_Artifact[id][ARTIFACT_RING_EXTRA_ITEM_COST]) {
			// case 1: {
				// iPercent = 5;
			// } case 2: {
				// iPercent = 10;
			// } case 3: {
				// iPercent = 15;
			// } case 4: {
				// iPercent = 20;
			// }
		// }

		// iTotal = (iPercent * iCost) / 100;
		// iCost -= iTotal;
	// }

	return iCost;
}

@menu__Items(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(get_member_game(m_bRoundTerminating) || !is_user_alive(id) || item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	new iItemId;
	new iLevelTotal;
	new iCost;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	iLevelTotal = __EXTRA_ITEMS[iItemId][extraItemLevelTotal];
	iCost = getExtraItemCost(id, iItemId);

	if(getUserLevelTotal(id) < iLevelTotal) {
		clientPrintColor(id, _, "No tienes el nivel suficiente para comprar este Item.");

		showMenu__Items(id);
		return PLUGIN_HANDLED;
	} else if(!iCost) {
		clientPrintColor(id, _, "Hubo un error al querer comprar un Item (!g%s!y).", __EXTRA_ITEMS[iItemId][extraItemName]);

		showMenu__Items(id);
		return PLUGIN_HANDLED;
	}

	buyExtraItem(id, iItemId, 0);
	return PLUGIN_HANDLED;
}

public bool:getUnlimitedClip(const id) {
	return get_member(id, m_iWeaponInfiniteAmmo);
}

setUnlimitedClip(const id, const bool:enabled) {
	if(enabled) {
		set_member(id, m_iWeaponInfiniteAmmo, 1);
	} else {
		set_member(id, m_iWeaponInfiniteAmmo, 0);
	}
}

buyExtraItem(const id, const extra_item, const ignore_cost) {
	new iCost = getExtraItemCost(id, extra_item);

	if(!ignore_cost) {
		if(g_Class[id] != __EXTRA_ITEMS[extra_item][extraItemClass]) {
			showMenu__Items(id);
			return;
		}

		if((g_AmmoPacks[id] - iCost) < 0) {
			clientPrintColor(id, _, "No tienes suficientes Ammo Packs.");

			showMenu__Items(id);
			return;
		}
	}

	switch(extra_item) {
		case EXTRA_ITEM_NVISION: {
			if(!ignore_cost) {
				if(g_NightVisionEnabled[id]) {
					clientPrintColor(id, _, "Ya compraste Visión nocturna.");

					showMenu__Items(id);
					return;
				}
			}

			changeNightVision(id);

			rh_emit_sound2(id, 0, CHAN_ITEM, __SOUND_NIGHTVISION, VOL_NORM, ATTN_NORM);
		} case EXTRA_ITEM_UNLIMITED_CLIP: {
			if(!ignore_cost) {
				if(getUnlimitedClip(id)) {
					clientPrintColor(id, _, "Ya compraste Balas Infinitas.");

					showMenu__Items(id);
					return;
				}
			}

			setUnlimitedClip(id, true);
		} case EXTRA_ITEM_PRESICION_PERFECT: {
			if(!ignore_cost) {
				// if(g_PrecisionPerfect[id]) {
					// clientPrintColor(id, _, "Ya compraste Precisión Perfecta.");

					// showMenu__ExtraItems(id);
					// return;
				// }
			}

			// g_PrecisionPerfect[id] = 1;
		} case EXTRA_ITEM_KILL_BOMB: {
			if(!ignore_cost) {
				
			}
		} case EXTRA_ITEM_PIPE_BOMB: {
			if(!ignore_cost) {
				
			}
		} case EXTRA_ITEM_ANTIDOTE_BOMB: {
			if(!ignore_cost) {
				
			}
		} case EXTRA_ITEM_ANTIDOTE: {
			if(!ignore_cost) {
				
			}
		} case EXTRA_ITEM_ZOMBIE_MADNESS: {
			if(!ignore_cost) {
				
			}
		} case EXTRA_ITEM_INFECTION_BOMB: {
			if(!ignore_cost) {
				
			}
		} case EXTRA_ITEM_REDUCE_DAMAGE: {
			if(!ignore_cost) {
				
			}
		}
	}

	if(!ignore_cost) {
		addAmmoPacks(id, (iCost * -1));

		g_ExtraItem_Cost[id][extra_item] += (__EXTRA_ITEMS[extra_item][extraItemCost] + getUserLevelTotal(id));
		++g_ExtraItem_Count[id][extra_item];
		++g_ExtraItem_AlreadyBuy[id][extra_item];
	}
}

showMenu__Character(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yMI PERSONAJE", "@menu__Character");

	switch(g_MenuPage_Character[id]) {
		case 0: {
			oldmenu_additem(1, 1, "\r1.\w Clases Humanas");
			oldmenu_additem(2, 2, "\r2.\w Clases Zombies^n");

			oldmenu_additem(3, 3, "\r3.\w Dificultad Survivor");
			oldmenu_additem(4, 4, "\r4.\w Dificultad Nemesis^n");

			oldmenu_additem(5, 5, "\r5.\w Logros");
			oldmenu_additem(6, 6, "\r6.\w Habilidades");
			oldmenu_additem(7, 7, "\r7.\w Gorros^n");

			oldmenu_additem(-1, -1, "\d8. Atrás");
			oldmenu_additem(9, 9, "\r9.\w Siguiente");
		} case 1: {
			oldmenu_additem(1, 1, "\r1.\w Amuletos");
			oldmenu_additem(2, 2, "\r2.\w Amuletos personalizados^n");

			oldmenu_additem(3, 3, "\r3.\w Artefactos");
			oldmenu_additem(4, 4, "\r4.\w Maestría^n");

			oldmenu_additem(5, 5, "\r5.\w Cabezas Zombies");
			oldmenu_additem(6, 6, "\r6.\w Beneficio gratuito^n");

			oldmenu_additem(8, 8, "\r8.\w Atrás");
			oldmenu_additem(-1, -1, "\d9. Siguiente");
		}
	}

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

@menu__Character(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(g_MenuPage_Character[id]) {
		case 0: {
			switch(item) {
				case 1: {
					if(g_MenuPage_HumanClasses[id] < 1) {
						g_MenuPage_HumanClasses[id] = 1;
					}

					showMenu__ChooseHumanClasses(id, g_MenuPage_HumanClasses[id]);
				} case 2: {
					if(g_MenuPage_ZombieClasses[id] < 1) {
						g_MenuPage_ZombieClasses[id] = 1;
					}

					showMenu__ChooseZombieClasses(id, g_MenuPage_ZombieClasses[id]);
				} case 3: {
					showMenu__Diffs(id, DIFF_CLASS_SURVIVOR);
				} case 4: {
					showMenu__Diffs(id, DIFF_CLASS_NEMESIS);
				} case 5: {
					showMenu__AchievementsClasses(id);
				} case 6: {
					if(g_MenuPage_HabsClasses[id] < 1) {
						g_MenuPage_HabsClasses[id] = 1;
					}

					showMenu__HabsClasses(id, g_MenuPage_HabsClasses[id]);
				} case 7: {
					showMenu__Hats(id);
				} case 9: {
					g_MenuPage_Character[id] = 1;
					showMenu__Character(id);
				}
			}
		} case 1: {
			switch(item) {
				case 1: {
					showMenu__Amulets(id);
				} case 2: {
					if(g_AmuletCustomCreated[id]) {
						showMenu__AmuletCustom(id);
					} else {
						showMenu__AmuletCustom(id, 1);
					}
				} case 3: {
					if(g_MenuPage_Artifacts[id] < 1) {
						g_MenuPage_Artifacts[id] = 1;
					}

					showMenu__Artifacts(id, g_MenuPage_Artifacts[id]);
				} case 4: {
					showMenu__Mastery(id, 0);
				} case 5: {
					showMenu__HeadZombies(id);
				} case 6: {
					
				} case 8: {
					g_MenuPage_Character[id] = 0;
					showMenu__Character(id);
				}
			}
		}
	}
}

showMenu__ChooseHumanClasses(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;
	new iLevelTotal;
	new sLevelTotal[16];

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__HUMAN_CLASSES));
	oldmenu_create("\yCLASES HUMANAS \r[%d - %d]\y\R%d / %d", "@menu__ChooseHumanClasses", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		iLevelTotal = __HUMAN_CLASSES[i][humanClassLevelTotal];

		if(i == g_HumanClass[id]) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, __HUMAN_CLASSES[i][humanClassName]);
		} else if(i == g_HumanClassNext[id]) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ELEGIDO)", j, __HUMAN_CLASSES[i][humanClassName]);
		} else if(getUserLevelTotal(id) < iLevelTotal) {
			if(g_UserOption_LevelTotal[id]) {
				addDot(iLevelTotal, sLevelTotal, charsmax(sLevelTotal));
				oldmenu_additem(-1, -1, "\d%d. %s \r(N: %s)", j, __HUMAN_CLASSES[i][humanClassName], sLevelTotal);
			} else {
				oldmenu_additem(-1, -1, "\d%d. %s \r(%s)", j, __HUMAN_CLASSES[i][humanClassName], getLevelTotalRequired(iLevelTotal));
			}
		} else {
			oldmenu_additem(j, i, "\r%d.\w %s", j, __HUMAN_CLASSES[i][humanClassName]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

@menu__ChooseHumanClasses(const id, const item, const value, const page) {
	if(!item || value > sizeof(__HUMAN_CLASSES)) {
		showMenu__Character(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage_HumanClasses[id] = iNewPage;

		showMenu__ChooseHumanClasses(id, iNewPage);
		return;
	}

	g_HumanClassNext[id] = value;

	clientPrintColor(id, _, "Cuando vuelvas a ser humano tu clase será !g%s!y.", __HUMAN_CLASSES[value][humanClassName]);
	clientPrintColor(id, _, "Vida: !g%d!y - Velocidad: !g%0.2f!y - Gravedad: !g%0.2f!y - Chaleco: !g%d!y.", __HUMAN_CLASSES[value][humanClassHealthBase], __HUMAN_CLASSES[value][humanClassSpeed], (__HUMAN_CLASSES[value][humanClassGravity] * 800.0), __HUMAN_CLASSES[value][humanClassArmor]);

	showMenu__ChooseHumanClasses(id, g_MenuPage_HumanClasses[id]);
}

showMenu__ChooseZombieClasses(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;
	new iLevelTotal;
	new sLevelTotal[16];

	oldmenu_pages(iMaxPages, iStart, iEnd, page, structIdZombieClasses);
	oldmenu_create("\yCLASES ZOMBIES \r[%d - %d]\y\R%d / %d", "@menu__ChooseZombieClasses", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		iLevelTotal = __ZOMBIE_CLASSES[i][zombieClassLevelTotal];

		if(i == g_ZombieClass[id]) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, __ZOMBIE_CLASSES[i][zombieClassName]);
		} else if(i == g_ZombieClassNext[id]) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ELEGIDO)", j, __ZOMBIE_CLASSES[i][zombieClassName]);
		} else if(getUserLevelTotal(id) < iLevelTotal) {
			if(g_UserOption_LevelTotal[id]) {
				addDot(iLevelTotal, sLevelTotal, charsmax(sLevelTotal));
				oldmenu_additem(-1, -1, "\d%d. %s \r(N: %s)", j, __ZOMBIE_CLASSES[i][zombieClassName], sLevelTotal);
			} else {
				oldmenu_additem(-1, -1, "\d%d. %s \r(%s)", j, __ZOMBIE_CLASSES[i][zombieClassName], getLevelTotalRequired(iLevelTotal));
			}
		} else {
			oldmenu_additem(j, i, "\r%d.\w %s", j, __ZOMBIE_CLASSES[i][zombieClassName]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

@menu__ChooseZombieClasses(const id, const item, const value, const page) {
	if(!item || value > structIdZombieClasses) {
		showMenu__Character(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage_ZombieClasses[id] = iNewPage;

		showMenu__ChooseZombieClasses(id, iNewPage);
		return;
	}

	g_MenuData_ZombieClassId[id] = value;
	showMenu__ChooseZombieClassInfo(id);
}

showMenu__ChooseZombieClassInfo(const id) {
	new iZombieClassId = g_MenuData_ZombieClassId[id];

	oldmenu_create("\yCLASE ZOMBIE\r:\w %s", "@menu__ChooseZombieClassInfo", __ZOMBIE_CLASSES[iZombieClassId][zombieClassName]);

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __ZOMBIE_CLASSES[iZombieClassId][zombieClassInfo]);

	oldmenu_additem(-1, -1, "\yESTADÍSTICAS BASE\r:");
	oldmenu_additem(-1, -1, "\r - \wVida\r:\y %d", __ZOMBIE_CLASSES[iZombieClassId][zombieClassHealthBase]);
	oldmenu_additem(-1, -1, "\r - \wVelocidad\r:\y %0.2f", __ZOMBIE_CLASSES[iZombieClassId][zombieClassSpeed]);
	oldmenu_additem(-1, -1, "\r - \wGravedad\r:\y %0.2f^n", (__ZOMBIE_CLASSES[iZombieClassId][zombieClassGravity] * 800.0));

	oldmenu_additem(1, 1, "\r1.\w Elegir esta Clase");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

@menu__ChooseZombieClassInfo(const id, const item) {
	if(!item) {
		showMenu__ChooseZombieClasses(id, g_MenuPage_ZombieClasses[id]);
		return;
	}

	new iZombieClassId = g_MenuData_ZombieClassId[id];

	switch(item) {
		case 1: {
			g_ZombieClassNext[id] = iZombieClassId;

			clientPrintColor(id, _, "Cuando vuelvas a ser zombie tu clase será !g%s!y.", __ZOMBIE_CLASSES[iZombieClassId][zombieClassName]);

			showMenu__ChooseZombieClasses(id, g_MenuPage_ZombieClasses[id]);
		}
	}
}

showMenu__ShopPoints(const id) {
	SetGlobalTransTarget(id);

	new sMoney[16];
	new i;
	new j;

	addDot(g_Point[id][P_MONEY], sMoney, charsmax(sMoney));
	oldmenu_create("\yTIENDA DE PUNTOS^n\wMonedas\r:\y %s", "@menu__ShopPoints", sMoney);

	for(i = P_HUMAN, j = 1; i < structIdPoints; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w Comprar %s", j, __POINTS[i][pointNameMin]);
	}

	oldmenu_additem(-1, -1, "^n\wPara comprar monedas, visita:");
	oldmenu_additem(-1, -1, "\y%s^n", __PLUGIN_COMMUNITY_FORUM_SHOP);

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ShopPoints(const id, const item, const value) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	g_MenuData_Point[id] = value;
	showMenu__ShopPointsIn(id, 1);
}

showMenu__ShopPointsIn(const id, const reset=0) {
	if(reset) {
		g_MenuData_PointIn_Add[id] = 0;
		g_MenuData_PointIn_CostMoney[id] = 0;
	}

	SetGlobalTransTarget(id);

	new iPoint = g_MenuData_Point[id];
	new sPointInAdd[16];
	new sPointInCostMoney[16];

	oldmenu_create("\yCOMPRAR\r:\w %s^n\wMonedas\r:\y %d", "@menu__ShopPointsIn", __POINTS[iPoint][pointNameMay], g_Point[id][P_MONEY]);

	addDot(g_MenuData_PointIn_Add[id], sPointInAdd, charsmax(sPointInAdd));
	addDot(g_MenuData_PointIn_CostMoney[id], sPointInCostMoney, charsmax(sPointInCostMoney));

	oldmenu_additem(-1, -1, "\wPuntos añadidos a comprar\r:\y %s%s", sPointInAdd, __POINTS[iPoint][pointNameShort]);
	oldmenu_additem(-1, -1, "\wCosto total por puntos a adquirir\r:\y %s monedas^n", sPointInCostMoney);

	oldmenu_additem(1, 1, "\r1.\w Agregar cantidad a comprar");

	if(g_MenuData_PointIn_CostMoney[id] && g_Point[id][P_MONEY] >= g_MenuData_PointIn_CostMoney[id]) {
		oldmenu_additem(9, 9, "\r9.\w Comprar puntos^n");
	} else {
		oldmenu_additem(-1, -1, "\d9. Comprar puntos^n");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ShopPointsIn(const id, const item) {
	if(!item) {
		showMenu__ShopPoints(id);
		return;
	}

	switch(item) {
		case 1: {
			clientPrintColor(id, _, "Ingrese la cantidad de puntos que desea comprar.");
			client_cmd(id, "messagemode CANTIDAD_DE_PUNTOS");
		} case 9: {
			if(g_MenuData_PointIn_CostMoney[id] && g_Point[id][P_MONEY] >= g_MenuData_PointIn_CostMoney[id]) {
				new iPoint = g_MenuData_Point[id];
				new sPointInAdd[16];

				g_Point[id][P_MONEY] -= g_MenuData_PointIn_CostMoney[id];
				g_Point[id][iPoint] += g_MenuData_PointIn_Add[id];

				addDot(g_MenuData_PointIn_Add[id], sPointInAdd, charsmax(sPointInAdd));
				clientPrintColor(id, _, "Has añadido !g%s%s!y a tu cuenta.", sPointInAdd, __POINTS[iPoint][pointNameShort]);
			}

			showMenu__ShopPointsIn(id, 1);
		}
	}
}

showMenu__HabsClasses(const id, page) {
	SetGlobalTransTarget(id);
	
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__HABS_CLASSES));
	oldmenu_create("\yHABILIDADES \r[%d - %d]\y\R%d / %d^n\d%s", "@menu__HabsClasses", (iStart + 1), iEnd, page, iMaxPages, __PLUGIN_COMMUNITY_FORUM_SHOP);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s%s", j, __HABS_CLASSES[i][habClassName], ((i == HAB_CLASS_ZOMBIE || i == HAB_CLASS_NEMESIS) ? "^n" : ""));
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

@menu__HabsClasses(const id, const item, const value, const page) {
	if(!item || value > sizeof(__HABS_CLASSES)) {
		showMenu__Character(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage_HabsClasses[id] = iNewPage;

		showMenu__HabsClasses(id, iNewPage);
		return;
	}

	g_MenuData_HabClass[id] = value;
	showMenu__Habs(id);
}

showMenu__Habs(const id) {
	SetGlobalTransTarget(id);

	new i;
	new iHabClassId = g_MenuData_HabClass[id];
	new j = 0;
	new iHabPoints = 0;
	new iCost = 0;

	oldmenu_create("\yHABILIDAD\r:\w %s^n\w%s\r:\y %d", "@menu__Habs", __HABS_CLASSES[iHabClassId][habClassName], __HABS_CLASSES[iHabClassId][habClassPointName], g_Point[id][__HABS_CLASSES[iHabClassId][habClassPointId]]);

	for(i = 0; i < structIdHabs; ++i) {
		if(iHabClassId != __HABS[i][habClass]) {
			continue;
		}

		++j;
		iHabPoints = g_Hab[id][i];
		iCost = ((iHabPoints + 1) * __HABS[i][habCost]);
		
		if(iHabPoints > __HABS[i][habMaxLevel]) {
			oldmenu_additem(-1, -1, "\d%d. %s \r(Full)", j, __HABS[i][habName]);
		} else {
			if(g_Point[id][__HABS_CLASSES[iHabClassId][habClassPointId]] >= iCost) {
				oldmenu_additem(j, i, "\r%d.\w %s \y[Niv: %d] \w(Costo: %d)", j, __HABS[i][habName], iHabPoints, iCost);
			} else {
				oldmenu_additem(-1, -1, "\d%d. %s \y[Niv: %d] \d(Costo: %d)", j, __HABS[i][habName], iHabPoints, iCost);
			}
		}
	}

	if(iHabClassId == HAB_CLASS_HUMAN || iHabClassId == HAB_CLASS_ZOMBIE) {
		if(g_Point[id][P_MONEY] >= COST_HAB_RESET_POINTS) {
			oldmenu_additem(9, 9, "^n\r9.\w Reiniciar puntos");
		} else {
			oldmenu_additem(-1, -1, "^n\d9. Reiniciar puntos \r(10 monedas)");
		}
	} else {
		oldmenu_additem(-1, -1, "");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__Habs(const id, const item, const value) {
	if(!item) {
		showMenu__HabsClasses(id, g_MenuPage_HabsClasses[id]);
		return;
	}

	new iHabClassId = g_MenuData_HabClass[id];

	switch(item) {
		case 9: {
			showMenu__HabsResetPoints(id, iHabClassId);
		} default: {
			if(value == HAB_L_VIGOR) {
				if(!g_Hab[id][HAB_H_DAMAGE]) {
					clientPrintColor(id, _, "Debes tener al menos habilidades puestas en el !gDAÑO HUMANO!y para aumentar tu !gVIGOR!y.");

					showMenu__Habs(id);
					return;
				}
			}

			new iHabPoints = g_Hab[id][value];
			new iCost = ((iHabPoints + 1) * __HABS[value][habCost]);

			if(g_Point[id][__HABS_CLASSES[iHabClassId][habClassPointId]] >= iCost && iHabPoints < __HABS[value][habMaxLevel]) {
				g_Point[id][__HABS_CLASSES[iHabClassId][habClassPointId]] -= iCost;
				++g_Hab[id][value];
			}

			showMenu__Habs(id);
		}
	}
}

showMenu__HabsResetPoints(const id, const hab_class) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yREINICIAR PUNTOS\r\w %s", "@menu__HabsResetPoints", ((hab_class == HAB_CLASS_HUMAN) ? "Humanos" : (hab_class == HAB_CLASS_ZOMBIE) ? "Zombies" : "-"));

	oldmenu_additem(-1, -1, "\w¿Estás seguro que quieres resetear tus %s?^n", __HABS_CLASSES[hab_class][habClassPointName]);
	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(0, 0, "\r0.\w No^n");

	oldmenu_additem(-1, -1, "\wCOSTO\r:\y %d monedas", COST_HAB_RESET_POINTS);
	oldmenu_display(id);
}

@menu__HabsResetPoints(const id, const item) {
	if(item) {
		g_Point[id][P_MONEY] -= COST_HAB_RESET_POINTS;
		
		new i;
		new iHabClassId = g_MenuData_HabClass[id];
		new iReturnPoints = 0;
		
		for(i = 0; i < structIdHabs; ++i) {
			if(iHabClassId == HAB_CLASS_HUMAN || iHabClassId == HAB_CLASS_ZOMBIE) {
				while(g_Hab[id][i]) {
					iReturnPoints += (g_Hab[id][i] * __HABS[i][habCost]);
					--g_Hab[id][i];
				}
			}
		}
		
		g_Point[id][__HABS_CLASSES[iHabClassId][habClassPointId]] += iReturnPoints;

		clientPrintColor(id, _, "Tus habilidades han sido reiniciadas, se te han devuelto %d%s.", iReturnPoints, __HABS_CLASSES[iHabClassId][habClassPointNameShort]);
	}

	showMenu__Habs(id);
}

public task__WarmUp() {
	if(g_IsWarmUp) {
		if(!get_member_game(m_bRoundTerminating)) {
			new iTimeLeft = floatround(getRoundRemainingTimeReal());

			set_hudmessage(255, 255, 255, -1.0, 0.17, 0, 0.0, 5.0, 2.0, 0.0);

			if(iTimeLeft > 5) {
				ShowSyncHudMsg(0, g_HudSync_Warmup, "Calentamiento: %d:%02d", (iTimeLeft / 60), (iTimeLeft % 60));
			} else {
				ShowSyncHudMsg(0, g_HudSync_Warmup, "El calentamiento finaliza en: %d:%02d", (iTimeLeft / 60), (iTimeLeft % 60));
			}
		} else {
			set_hudmessage(255, 0, 0, -1.0, 0.17, 0, 0.0, 5.0, 2.0, 0.0);
			ShowSyncHudMsg(0, g_HudSync_Warmup, "La partida comienza en %d...", floatround(Float:get_member_game(m_flRestartRoundTime) - get_gametime()));
		}
	} else {
		if(!get_member_game(m_bGameStarted) || get_member_game(m_bRoundTerminating)) {
			return;
		}

		new iTimeLeft = floatround(getRoundRemainingTimeReal());

		if(iTimeLeft <= 0) {
			ClearSyncHud(0, g_HudSync_Warmup);
			return;
		}

		if(get_member_game(m_bFreezePeriod)) {
			// if(iTimeLeft <= 10) {
				// playTimeLeftSound(iTimeLeft);
			// }

			set_hudmessage(255, 255, 0, -1.0, 0.17, 0, 0.0, 1.1, 0.0, 0.0);
			ShowSyncHudMsg(0, g_HudSync_Warmup, "La ronda comienza en %d", iTimeLeft);
		} else {
			if(iTimeLeft <= 30) {
				// if(iTimeLeft <= 10) {
					// playTimeLeftSound(iTimeLeft);
				// }

				set_hudmessage(255, 0, 0, -1.0, 0.17, 0, 0.0, 1.1, 0.0, 0.0);
				ShowSyncHudMsg(0, g_HudSync_Warmup, "La ronda finaliza en %d", iTimeLeft);
			}
		}
	}
}

public Float:getRoundRemainingTimeReal() {
	return (float(get_member_game(m_iRoundTimeSecs)) - get_gametime() + Float:get_member_game(m_fRoundStartTimeReal));
}

// playTimeLeftSound(const number) {
	// new sNumberToWord[64];
	// num_to_word(number, sNumberToWord, charsmax(sNumberToWord));

	// client_cmd(0, "spk fvox/%s", sNumberToWord);
// }

public humanComboReward(const id) {
	new iComboReward = g_ComboReward[id];

	if(g_Hab[id][HAB_H_TCOMBO]) {
		iComboReward += (__HABS[HAB_H_TCOMBO][habValue] * g_Hab[id][HAB_H_TCOMBO]);
	}

	if(g_Hab[id][HAB_L_MULT_COMBO]) {
		iComboReward += (__HABS[HAB_L_MULT_COMBO][habValue] * g_Hab[id][HAB_L_MULT_COMBO]);
	}

	return (iComboReward + 1);
}

public task__FinishCombo(const task_id) {
	new iId = (task_id - TASK_FINISHCOMBO);

	if(!is_user_connected(iId)) {
		remove_task(task_id);
		return;
	}

	new iReward = (g_Combo[iId] * humanComboReward(iId));

	if(iReward > 0) {
		if(iReward > MAX_AMMOPACKS) {
			iReward = MAX_AMMOPACKS;
		}

		addAmmoPacks(iId, iReward);

		new sReward[16];
		new sDamageTotal[16];

		addDot(iReward, sReward, charsmax(sReward));
		addDot(g_ComboDamage[iId], sDamageTotal, charsmax(sDamageTotal));

		set_hudmessage(__COMBO_HUMAN[g_ComboReward[iId]][comboColorRed], __COMBO_HUMAN[g_ComboReward[iId]][comboColorGreen], __COMBO_HUMAN[g_ComboReward[iId]][comboColorBlue], g_UserOption_HudPosition[iId][HUD_TYPE_COMBO][0], g_UserOption_HudPosition[iId][HUD_TYPE_COMBO][1], g_UserOption_HudEffect[iId][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
		ShowSyncHudMsg(iId, g_HudSync_Combo, "%s^nGanaste %s de Ammo Packs^nDaño hecho: %s", __COMBO_HUMAN[g_ComboReward[iId]][comboMessage], sReward, sDamageTotal);
	}

	g_Combo[iId] = 0;
	g_ComboDamage[iId] = 0;
	g_ComboReward[iId] = 0;
}

resetVars(const id, const reset_all) {
	g_CanBuy[id] = 1;

	g_EntFlame[id] = 0;
	g_EntIceCube[id] = 0;

	g_DrugBomb[id] = 0;
	g_SupernovaBomb[id] = 0;
	g_BubbleBomb[id] = 0;
	g_KillBomb[id] = 0;
	g_PipeBomb[id] = 0;
	g_AntidoteBomb[id] = 0;

	if(reset_all) {
		new i;

		g_Weapon_AutoBuy[id] = 0;
		g_Weapon_PrimarySelection[id] = 0;
		g_Weapon_SecondarySelection[id] = 0;
		g_Weapon_CuaternarySelection[id] = 0;

		for(i = 0; i < structIdExtraItems; ++i) {
			g_ExtraItem_Cost[id][i] = __EXTRA_ITEMS[i][extraItemCost];
			g_ExtraItem_Count[id][i] = 0;
			g_ExtraItem_AlreadyBuy[id][i] = 0;
		}

		g_HumanClass[id] = 0;
		g_HumanClassNext[id] = 0;
		g_ZombieClass[id] = 0;
		g_ZombieClassNext[id] = 0;

		for(i = 0; i < structIdDiffsClasses; ++i) {
			g_Diff[id][i] = DIFF_NORMAL;
		}

		for(i = 0; i < structIdPoints; ++i) {
			g_Point[id][i] = 0;
		}

		g_PointInDiamond[id] = 0;
		g_PointInDiamondUsed[id] = 0;

		for(i = 0; i < structIdHabs; ++i) {
			g_Hab[id][i] = 0;
		}

		for(i = 0; i < structIdAchievementClasses; ++i) {
			g_AchievementPage[id][i] = 0;
		}

		for(i = 0; i < structIdAchievements; ++i) {
			g_Achievement[id][i] = 0;
			g_AchievementName[id][i][0] = EOS;
			g_AchievementUnlocked[id][i] = 0;
			g_AchievementInt[id][i] = 0;
		}

		g_AchievementTotal[id] = 0;
		g_AchievementTimeLink[id] = 0.0;

		g_HatId[id] = HAT_NONE;
		g_HatNext[id] = HAT_NONE;

		for(i = 0; i < structIdHats; ++i) {
			g_Hat[id][i] = 0;
			g_HatUnlocked[id][i] = 0;
		}

		g_HatTotal[id] = 0;
		g_Hat_Devil[id] = 0;
		g_Hat_Earth[id] = 0;

		for(i = 0; i < structIdArtifacts; ++i) {
			g_Artifact[id][i] = 0;
			g_ArtifactsEquiped[id][i] = 0;
		}

		g_Mastery[id] = MASTERY_NONE;

		g_ClanSlot[id] = 0;
		g_ClanInvitations[id] = 0;
		
		for(i = 0; i <= MaxClients; ++i) {
			g_ClanInvitationsId[id][i] = 0;
		}
		
		g_ClanQueryFlood[id] = 0.0;
		g_TempClanDeposit[id] = 0;

		g_UserOption_Color[id][COLOR_TYPE_HUD] = {0, 255, 0};
		g_UserOption_Color[id][COLOR_TYPE_NVISION] = {0, 255, 0};
		g_UserOption_Color[id][COLOR_TYPE_FLARE] = {255, 255, 255};
		g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW] = {255, 0, 255};
		g_UserOption_HudPosition[id][HUD_TYPE_GENERAL] = Float:{0.02, 0.1, 0.0};
		g_UserOption_HudPosition[id][HUD_TYPE_COMBO] = Float:{-1.0, 0.6, 1.0};
		g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO] = Float:{-1.0, 0.8, 1.0};
		g_UserOption_HudEffect[id][HUD_TYPE_GENERAL] = 0;
		g_UserOption_HudEffect[id][HUD_TYPE_COMBO] = 0;
		g_UserOption_HudEffect[id][HUD_TYPE_CLAN_COMBO] = 0;
		g_UserOption_HudStyle[id][HUD_TYPE_GENERAL] = 1;
		g_UserOption_HudStyle[id][HUD_TYPE_COMBO] = 1;
		g_UserOption_HudStyle[id][HUD_TYPE_CLAN_COMBO] = 1;
		g_UserOption_Invis[id] = 0;
		g_UserOption_NVision[id] = 1;
		g_UserOption_ClanGlow[id] = 0;
		g_UserOption_LevelTotal[id] = 0;

		for(i = 0; i < structIdTimePlayed; ++i) {
			g_TimePlayed[id][i] = 0;
		}

		g_AmmoPacks[id] = 0;
		g_AmmoPacks_Rest[id] = 0;
		g_AmmoPacks_Mult[id] = 1.0;
		g_AmmoPacks_Damage[id] = 0;
		g_AmmoPacks_DamageNeed[id] = 500;
		g_Level[id] = 1;
		g_Level_Percent[id] = 0.0;
		g_Reset[id] = 0;
		g_Reset_Percent[id] = 0.0;
		g_Prestige[id] = 0;
		g_Combo[id] = 0;
		g_ComboDamage[id] = 0;
		g_ComboDamageNeed[id] = 500;
		g_ComboReward[id] = 0;

		g_NextHudInfoTime[id] = 0.0;

		g_AmuletCustomCreated[id] = 0;
		g_AmuletCustomCost[id] = 0;
		g_AmuletCustomName[id][0] = EOS;
		g_AmuletCustomNameFake[id][0] = EOS;
		g_AmuletCustom[id][acHealth] = 0;
		g_AmuletCustom[id][acSpeed] = 0;
		g_AmuletCustom[id][acGravity] = 0;
		g_AmuletCustom[id][acDamage] = 0;
		g_AmuletCustom[id][acMultAmmoPacks] = _:0.0;

		for(i = 0; i < structIdHeadZombies; ++i) {
			g_HeadZombie[id][i] = 0;
		}
		g_HeadZombie_BadLuckBrian[id] = 0;
		g_HeadZombie_LastTouch[id] = 0.0;

		g_Benefit_Timestamp[id] = 0;

		g_MenuPage_Character[id] = 0;
		g_MenuPage_HumanClasses[id] = 1;
		g_MenuPage_ZombieClasses[id] = 1;
		g_MenuPage_AchievementClasses[id] = 0;
		g_MenuPage_HabsClasses[id] = 1;
		g_MenuPage_Hats[id] = 0;
		g_MenuPage_Artifacts[id] = 1;
		g_MenuPage_ClanInvite[id] = 0;
		g_MenuPage_ClanPerks[id] = 0;
		g_MenuPage_ColorChoosen[id] = 1;
		g_MenuPage_AdminStaffRespawn[id] = 0;
		g_MenuPage_AdminStaffGameModes[id] = 0;
		g_MenuData_ZombieClassId[id] = 0;
		g_MenuData_DiffClass[id] = DIFF_CLASS_SURVIVOR;
		g_MenuData_AchievementClass[id] = ACHIEVEMENT_CLASS_HUMAN;
		g_MenuData_AchievementIn[id] = 0;
		g_MenuData_Point[id] = P_HUMAN;
		g_MenuData_PointIn_Add[id] = 0;
		g_MenuData_PointIn_CostMoney[id] = 0;
		g_MenuData_HabClass[id] = HAB_CLASS_HUMAN;
		g_MenuData_HatId[id] = HAT_NONE;
		g_MenuData_ArtifactId[id] = ARTIFACT_RING_AMMOPACKS;
		g_MenuData_MasteryId[id] = MASTERY_NONE;
		g_MenuData_ClanMemberId[id] = 0;
		g_MenuData_ClanPerkId[id] = 0;
		g_MenuData_ColorChoosen[id] = 0;
	}

	updateAmmoPacksMult(id);
	updateAmmoPacksDamageNeed(id);
	updateComboDamageNeed(id);
}

entSelectSpawnPoint(const id) {
	new iSpotId = g_LastSpawnId;
	new iSpawnPontsNum = ArraySize(g_aSpawnPoints);
	new iSpot;
	new Float:vecOrigin[3];

	do {
		if(++iSpotId >= iSpawnPontsNum) {
			iSpotId = 0;
		}

		iSpot = ArrayGetCell(g_aSpawnPoints, iSpotId);

		if(is_nullent(iSpot)) {
			continue;
		}

		get_entvar(iSpot, var_origin, vecOrigin);

		if(!isHullVacant(id, vecOrigin, HULL_HUMAN)) {
			continue;
		}

		break;
	} while(iSpotId != g_LastSpawnId);

	if(is_nullent(iSpot)){
		return 0;
	}

	g_LastSpawnId = iSpotId;
	return iSpot;
}

setNightVision(const id, const bool:enable) {
	if(enable) {
		g_NightVisionEnabled[id] = true;

		utilLightStyle(id, 0, "i");
		utilScreenFade(id, 0.001, 0.0, (FFADE_OUT | FFADE_STAYOUT), {255, 255, 255}, 60);
	} else {
		g_NightVisionEnabled[id] = false;

		utilLightStyle(id, 0, "b");
		utilScreenFade(id, 0.001);
	}
}

changeNightVision(const id) {
	new iNightVision = g_NightVision[id];

	if(iNightVision) {
		set_member(id, m_bHasNightVision, true);
		setNightVision(id, true);
	} else {
		set_member(id, m_bHasNightVision, false);
		setNightVision(id, false);
	}
}

updateNightVision(const id) {
	if(id) {
		setNightVision(id, g_NightVisionEnabled[id]);
	} else {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			setNightVision(i, g_NightVisionEnabled[i]);
		}
	}
}

maxAmmoPacksPerReset(const reset) {
	switch(reset) {
		case 0..4: {
			return ((reset + 1) * 10000000);
		} case 5..6: {
			return (reset * 13000000);
		} case 7..8: {
			return (reset * 16000000);
		} case 9..10: {
			return (reset * 19000000);
		} case 11..12: {
			return (reset * 22000000);
		} case 13..14: {
			return (reset * 25000000);
		} case 15..16: {
			return (reset * 28000000);
		} case 17..18: {
			return (reset * 31000000);
		} default: {
			return (reset * 40000000);
		}
	}

	return 0;
}

getConversion(const id, const percent) {
	new iConversion = (__ammoPacksThisLevel(id, g_Level[id]) - __ammoPacksThisLevelRest(id, g_Level[id]));

	if(iConversion < 0) {
		iConversion = 0;
	}

	new iReward = ((iConversion * percent) / 100);
	return iReward;
}

addAmmoPacks(const id, const ammopacks, const set=0) {
	if(set) {
		g_AmmoPacks[id] = ammopacks;
	} else {
		g_AmmoPacks[id] += ammopacks;
	}

	checkAmmoPacksEquation(id);

	g_NextHudInfoTime[id] = (get_gametime() + 0.1);
}

checkAmmoPacksEquation(const id) {
	if(g_Level[id] >= MAX_LEVELS) {
		g_AmmoPacks[id] = maxAmmoPacksPerReset(g_Reset[id]);
		g_AmmoPacks_Rest[id] = 0;
	} else {
		g_AmmoPacks_Rest[id] = (__ammoPacksThisLevel(id, g_Level[id]) - g_AmmoPacks[id]);

		if(g_AmmoPacks_Rest[id] <= 0) {
			new iLevel = 0;

			while(g_AmmoPacks_Rest[id] <= 0) {
				++g_Level[id];
				++iLevel;

				if(g_Level[id] >= MAX_LEVELS) {
					g_Level[id] = MAX_LEVELS;

					checkAmmoPacksEquation(id);
					break;
				}

				g_AmmoPacks_Rest[id] = (__ammoPacksThisLevel(id, g_Level[id]) - g_AmmoPacks[id]);
			}

			if(iLevel) {
				clientPrint(id, print_center, "Subiste %d nivel%s.", iLevel, ((iLevel != 1) ? "es" : ""));
				rh_emit_sound2(id, 0, CHAN_BODY, __SOUND_LEVEL_UP);
			}
		}
	}

	g_Level_Percent[id] = floatclamp(((float(g_AmmoPacks[id]) - float(__ammoPacksThisLevelRest(id, g_Level[id]))) * 100.0) / (float(__ammoPacksThisLevel(id, g_Level[id])) - float(__ammoPacksThisLevelRest(id, g_Level[id]))), 0.0, 100.0);
	g_Reset_Percent[id] = (((float(g_Level[id])) * 100.0) / float(MAX_LEVELS));

	g_NextHudInfoTime[id] = (get_gametime() + 0.1);
}

checkUpReset(const id) {
	if(g_AmmoPacks[id] == maxAmmoPacksPerReset(g_Reset[id]) && g_Level[id] == MAX_LEVELS) {
		return true;
	}

	return false;
}

checkUpPrestige(const id) {
	if(g_AmmoPacks[id] == maxAmmoPacksPerReset(g_Reset[id]) && g_Level[id] == MAX_LEVELS && g_Reset[id] == MAX_RESETS) {
		return true;
	}

	return false;
}

getUserLevelTotal(const id) {
	if(!is_user_connected(id) || dg_get_user_acc_status(id) < STATUS_LOGGED) {
		return 1;
	}

	return ((g_Prestige[id] * (MAX_RESETS + 1) * MAX_LEVELS) + (g_Reset[id] * MAX_LEVELS) + g_Level[id]);
}

allowedGaveRewards(const id, const level, const reset, const prestige) {
	if(!is_user_connected(id) || dg_get_user_acc_status(id) < STATUS_LOGGED) {
		return 0;
	}

	if(level == 1 && reset == 0 && prestige == 0) {
		return 1;
	}

	if(level < 1 || level > MAX_LEVELS || reset < 0 || reset > MAX_RESETS || prestige < 0 || prestige > (MAX_PRESTIGE - 1)) {
		return 0;
	}

	return 1;
}

updateAmmoPacksMult(const id) {
	new Float:flMult = 1.0;

	if(g_DrunkAtNite == 2) {
		flMult += 2.0;
	} else if(g_DrunkAtDay == 1 || g_DrunkAtNite == 1) {
		flMult += 1.0;
	}

	if(dg_get_user_acc_ldc(id)) {
		flMult += (float(dg_get_user_acc_ldc(id)) * 0.0066);
	}

	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit_Timestamp[id] > 1) {
		flMult += 1.0;
	}

	if(g_Hab[id][HAB_L_MULT_AMMOPACKS]) {
		flMult += ((float(__HABS[HAB_L_MULT_AMMOPACKS][habValue]) / 5.0) * float(g_Hab[id][HAB_L_MULT_AMMOPACKS]));
	}

	if(g_HatId[id] != HAT_NONE && __HATS[g_HatId[id]][hatUpgrade5]) {
		flMult += __HATS[g_HatId[id]][hatUpgrade5];
	}

	// Amuleto normal

	if(g_AmuletCustomCreated[id]) {
		flMult += g_AmuletCustom[id][acMultAmmoPacks];
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_RING_AMMOPACKS]) {
		flMult += (float(g_Artifact[id][ARTIFACT_RING_AMMOPACKS]) * 0.5);
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_BRACELET_AMMOPACKS]) {
		flMult += 1.0;
	}

	if(g_Mastery[id] == g_MasteryType) {
		flMult += 1.0;
	}

	new iSysTime = get_arg_systime();

	if(iSysTime < MAX_TIME_TO_BONUS) {
		flMult += 0.5;

		if(g_Achievement[id][BETA_TESTER] && g_Achievement[id][SUPER_BETA_TESTER]) {
			flMult += 0.5;
		}
	}

	g_AmmoPacks_Mult[id] = flMult;
}

updateAmmoPacksDamageNeed(const id) {
	new Float:flNeed = (float(getUserLevelTotal(id)) / g_AmmoPacks_Mult[id]);

	if(flNeed < 1.0) {
		flNeed = 1.0;
	}

	g_AmmoPacks_DamageNeed[id] = floatround(flNeed);
}

updateComboDamageNeed(const id) {
	new Float:flNeed = (float(getUserLevelTotal(id)) / g_AmmoPacks_Mult[id]);

	if(flNeed < 1.0) {
		flNeed = 1.0;
	}

	g_ComboDamageNeed[id] = floatround(flNeed);
}

showCurrentComboHuman(const id, const Float:damage) {
	static sCombo[16];
	static sDamage[8];
	static sDamageTotal[16];

	while(id > 0) {
		if(g_Combo[id] >= __COMBO_HUMAN[g_ComboReward[id]][comboNeed] && g_Combo[id] < __COMBO_HUMAN[(g_ComboReward[id] + 1)][comboNeed]) {
			break;
		}

		++g_ComboReward[id];
	}

	addDot(g_Combo[id], sCombo, charsmax(sCombo));
	addDot(floatround(damage), sDamage, charsmax(sDamage));
	addDot(g_ComboDamage[id], sDamageTotal, charsmax(sDamageTotal));

	set_hudmessage(__COMBO_HUMAN[g_ComboReward[id]][comboColorRed], __COMBO_HUMAN[g_ComboReward[id]][comboColorGreen], __COMBO_HUMAN[g_ComboReward[id]][comboColorBlue], g_UserOption_HudPosition[id][HUD_TYPE_COMBO][0], g_UserOption_HudPosition[id][HUD_TYPE_COMBO][1], g_UserOption_HudEffect[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
	ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nCombo de x%s Ammo Packs^nDaño: %s | Daño total: %s", __COMBO_HUMAN[g_ComboReward[id]][comboMessage], sCombo, sDamage, sDamageTotal);
}

loadGameRules() {
	new i;
	for(i = 0; i < sizeof(__IMMUTABLE_CVARS); ++i) {
		g_ImmutableCVars[i] = get_cvar_pointer(__IMMUTABLE_CVARS[i][0]);

		set_pcvar_string(g_ImmutableCVars[i], __IMMUTABLE_CVARS[i][1]);
		hook_cvar_change(g_ImmutableCVars[i], "@HandleForcingCvarChange");
	}

	g_pCVar_FreezeTime = get_cvar_pointer("mp_freezetime");
	g_pCVar_RoundTime = get_cvar_pointer("mp_roundtime");

	set_pcvar_flags(g_pCVar_FreezeTime, (get_pcvar_flags(g_pCVar_FreezeTime) | FCVAR_UNLOGGED));
	set_pcvar_flags(g_pCVar_RoundTime, (get_pcvar_flags(g_pCVar_RoundTime) | FCVAR_UNLOGGED));

	bind_pcvar_float(get_cvar_pointer("mp_round_restart_delay"), g_pCVar_RoundRestartDelay);
	bind_pcvar_num(get_cvar_pointer("mp_playerid"), g_pCVar_PlayerId);

	g_aSpawnPoints = ArrayCreate(1, 0);

#if defined WARMUP_ENABLED
	g_IsWarmUp = true;
	SetRoundCvars(0, WARMUP_TIME);
#else
	SetRoundCvars(PREPARE_TIME, ROUND_TIME);
#endif
}

SetRoundCvars(const freeze_time, const round_time) {
	set_pcvar_num(g_pCVar_FreezeTime, freeze_time);
	set_pcvar_float(g_pCVar_RoundTime, (float(round_time) / 60.0));
}

precacheAll() {
	new i;

	for(i = 0; i < structIdClasses; ++i) {
		if(__CLASSES[i][class__PlayerModelDefaultHitZones]) {
			g_Class_PlayerModelIndex[i] = precache_model("models/player.mdl");
		} else {
			g_Class_PlayerModelIndex[i] = precache_model(fmt("models/player/%s/%s.mdl", __CLASSES[i][class__PlayerModel], __CLASSES[i][class__PlayerModel]));
		}
	}

	for(i = 0; i < structIdHats; ++i) {
		if(__HATS[i][hatModel][0]) {
			precache_model(__HATS[i][hatModel]);
		}
	}

	precache_model(__MODEL_GRENADE_INFECTION_VIEW);
	precache_model(__MODEL_GRENADE_INFECTION_PLAYER);
	precache_model(__MODEL_GRENADE_INFECTION_WORLD);
	precache_model(__MODEL_GRENADE_FIRE_VIEW);
	precache_model(__MODEL_GRENADE_FROST_VIEW);
	precache_model(__MODEL_GRENADE_FLARE_VIEW);
	precache_model(__MODEL_GRENADE_DRUG_VIEW);
	precache_model(__MODEL_GRENADE_DRUG_PLAYER);
	precache_model(__MODEL_GRENADE_DRUG_WORLD);
	precache_model(__MODEL_GRENADE_SUPERNOVA_VIEW);
	precache_model(__MODEL_GRENADE_SUPERNOVA_PLAYER);
	precache_model(__MODEL_GRENADE_SUPERNOVA_WORLD);
	precache_model(__MODEL_GRENADE_BUBBLE_VIEW);
	precache_model(__MODEL_GRENADE_BUBBLE_PLAYER);
	precache_model(__MODEL_GRENADE_BUBBLE_WORLD);
	precache_model(__MODEL_GRENADE_KILL_VIEW);
	precache_model(__MODEL_GRENADE_PIPE_VIEW);
	precache_model(__MODEL_GRENADE_PIPE_WORLD);
	precache_model(__MODEL_GRENADE_ANTIDOTE_VIEW);
	precache_model(__MODEL_ICECUBE);
	precache_model(__MODEL_BUBBLE);
	g_ModelIndex_HeadZombie = precache_model(__MODEL_HEADZOMBIE);

	precache_sound(__SOUND_HUMAN_ANTIDOTE);
	precache_sound(__SOUND_HUMAN_ARMOR_HIT);
	precache_sound(__SOUND_HUMAN_HEADZOMBIE_PICKUP);
	precache_sound(__SOUND_WIN_ZOMBIES);
	precache_sound(__SOUND_WIN_HUMANS);
	precache_sound(__SOUND_WIN_NO_ONE);
	precache_sound(__SOUND_NIGHTVISION);
	precache_sound(__SOUND_GRENADE_INFECTION_EXPLODE);
	precache_sound(__SOUND_GRENADE_FIRE_EXPLODE);

	for(i = 0; i < sizeof(__SOUND_GRENADE_FIRE_ZOMBIE_BURNING); ++i) {
		precache_sound(__SOUND_GRENADE_FIRE_ZOMBIE_BURNING[i]);
	}

	precache_sound(__SOUND_GRENADE_FROST_EXPLODE);
	precache_sound(__SOUND_GRENADE_FROST_FREEZE);
	precache_sound(__SOUND_GRENADE_FROST_BREAK);
	precache_sound(__SOUND_GRENADE_FLARE_EXPLODE);
	precache_sound(__SOUND_GRENADE_BUBBLE_EXPLODE);

	precache_sound(__SOUND_LEVEL_UP);

	g_ModelIndex_LaserBeam = precache_model("sprites/dg/zp6/trail_00.spr");
	g_ModelIndex_ShockWave = precache_model("sprites/shockwave.spr");
	g_ModelIndex_BlackSmoke3 = precache_model("sprites/black_smoke3.spr");
	g_ModelIndex_Flame = precache_model(__SPRITE_FLAME);
	g_ModelIndex_GlassGibs = precache_model("models/glassgibs.mdl");

	precacheAndLoadSkies();
}

precacheAndLoadSkies() {
	new const __PRECACHE_SKIES_TYPES[][] = {"bk.tga", "dn.tga", "ft.tga", "lf.tga", "rt.tga", "up.tga"};
	new const __PRECACHE_SKIES[][] = {"lostworld", "vlcno"};
	new const __SKIES[][] = {"space", "lostworld", "vlcno"};
	new sSkySidesFile[64];
	new i;
	new j;

	for(i = 0; i < sizeof(__PRECACHE_SKIES_TYPES); ++i) {
		for(j = 0; j < sizeof(__PRECACHE_SKIES); ++j) {
			formatex(sSkySidesFile, charsmax(sSkySidesFile), "gfx/env/%s%s", __PRECACHE_SKIES[j], __PRECACHE_SKIES_TYPES[i]);

			if(file_exists(sSkySidesFile)) {
				precache_generic(sSkySidesFile);
			}
		}
	}

	set_cvar_string("sv_skyname", __SKIES[random_num(0, 2)]);
}

loadStuff() {
	blockTextAndAudiosDefault();

	g_ServerId = dg_get_server_id();

	setClassDefault(TEAM_TERRORIST, CLASS_ZOMBIE);
	setClassDefault(TEAM_CT, CLASS_HUMAN);

	set_member_game(m_bTCantBuy, true);
	set_member_game(m_bCTCantBuy, true);

	forceLevelInitialize();
	createHats();

	set_task(1.0, "task__WarmUp", TASK_WARMUP, .flags="b");
	
	g_HudSync_Warmup = CreateHudSyncObj();
	g_HudSync_Info = CreateHudSyncObj();
	g_HudSync_StatusBar = CreateHudSyncObj();
	g_HudSync_Combo = CreateHudSyncObj();
	g_HudSync_ClanCombo = CreateHudSyncObj();

	g_HeadZombie_GameTime = get_gametime();
	
	set_cvar_string("sv_skycolor_r", "0");
	set_cvar_string("sv_skycolor_g", "0");
	set_cvar_string("sv_skycolor_b", "0");
}

blockTextAndAudiosDefault() {
	new i;

	g_tBlockedTextMsg = TrieCreate();
	g_tBlockedSendAudio = TrieCreate();

	for(i = 0; i < sizeof(__BLOCKED_TEXTMSG); ++i) {
		TrieSetCell(g_tBlockedTextMsg, __BLOCKED_TEXTMSG[i], 0);
	}

	for(i = 0; i < sizeof(__BLOCKED_SENDAUDIO); ++i) {
		TrieSetCell(g_tBlockedSendAudio, __BLOCKED_SENDAUDIO[i], 0);
	}
}

forceLevelInitialize() {
	if(!ArraySize(g_aSpawnPoints)) {
		new iEnt = NULLENT;

		while((iEnt = rg_find_ent_by_class(iEnt, "info_player_start", true))) {
			ArrayPushCell(g_aSpawnPoints, iEnt);
		}

		while((iEnt = rg_find_ent_by_class(iEnt, "info_player_deathmatch", true))) {
			ArrayPushCell(g_aSpawnPoints, iEnt);
		}
	}

	new iSpawnPontsNum = ArraySize(g_aSpawnPoints);

	set_member_game(m_iSpawnPointCount_Terrorist, iSpawnPontsNum);
	set_member_game(m_iSpawnPointCount_CT, iSpawnPontsNum);

	set_member_game(m_bLevelInitialized, true);
}

createHats() {
	new i;
	new iEnt;

	for(i = 1; i <= MaxClients; ++i) {
		iEnt = create_entity("info_target");
		
		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_HAT);
		entity_set_model(iEnt, __HATS[0][hatModel]);
		
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW);
		
		entity_set_edict(iEnt, EV_ENT_aiment, i);
		entity_set_edict(iEnt, EV_ENT_owner, i);
	}
}

@RequestFrame_UpdateNightVision(const id) {
	if(!is_user_connected(id)) {
		return;
	}

	if(!g_NightVision[id]) {
		g_NightVision[id] = g_SpectatorNightVision;
	}

	if(get_entvar(id, var_iuser1) == OBS_IN_EYE) {
		g_NightVision[id] = g_LastNightVision[id];
	} else {
		g_NightVision[id] = g_SpectatorNightVision;
	}

	setNightVision(id, true);
}

savePlayerData(const id, const acc_id) {
	if(!acc_id) {
		return;
	}

	new iLen = 0;
	new Handle:sqlQuery;

	if(g_ClanSlot[id]) {
		iLen = 0;
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE `zp9_clans` SET ");
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`kills_h_done`='%d', `kills_z_done`='%d', `infections_done`='%d' ", g_Clan[g_ClanSlot[id]][clanKillHmDone], g_Clan[g_ClanSlot[id]][clanKillZmDone], g_Clan[g_ClanSlot[id]][clanInfectDone]);
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE (`id`='%d');", g_Clan[g_ClanSlot[id]][clanId]);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 8);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		iLen = 0;
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE `zp9_clans_members` SET ");
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`last_connection`='%d' ", get_arg_systime());
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE (`acc_id`='%d' AND `clan_id`='%d');", acc_id, g_Clan[g_ClanSlot[id]][clanId]);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 9);
		} else {
			SQL_FreeHandle(sqlQuery);
		}
	}

	iLen = 0;
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE `zp9_pjs` SET ");
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`ammopacks`='%d', `level`='%d', `reset`='%d', `prestige`='%d', ", g_AmmoPacks[id], g_Level[id], g_Reset[id], g_Prestige[id]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`weapon_autobuy`='%d', `weapon_primary`='%d', `weapon_secondary`='%d', `weapon_cuaternary`='%d', ", g_Weapon_AutoBuy[id], g_Weapon_PrimarySelection[id], g_Weapon_SecondarySelection[id], g_Weapon_CuaternarySelection[id]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`hclass`='%d', `zclass`='%d', `diffsurv`='%d', `diffnem`='%d', ", g_HumanClassNext[id], g_ZombieClassNext[id], g_Diff[id][DIFF_CLASS_SURVIVOR], g_Diff[id][DIFF_CLASS_NEMESIS]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`money`='%d', `p_humans`='%d', `p_zombies`='%d', `p_legacy`='%d', `p_fragments`='%d', `p_diamonds`='%d', ", g_Point[id][P_MONEY], g_Point[id][P_HUMAN], g_Point[id][P_ZOMBIE], g_Point[id][P_LEGACY], g_Point[id][P_FRAGMENT], g_Point[id][P_DIAMOND]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`hat_id`='%d', `amulet_id`='0', `mastery_id`='%d', ", g_HatId[id], g_Mastery[id]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`headzombie_r`='%d', `headzombie_g`='%d', `headzombie_b`='%d', `headzombie_y`='%d', `headzombie_w`='%d', ", g_HeadZombie[id][HEADZOMBIE_RED], g_HeadZombie[id][HEADZOMBIE_GREEN], g_HeadZombie[id][HEADZOMBIE_BLUE], g_HeadZombie[id][HEADZOMBIE_YELLOW], g_HeadZombie[id][HEADZOMBIE_WHITE]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`uo_color_hud`='%d %d %d', `uo_color_nvision`='%d %d %d', `uo_color_flare`='%d %d %d', `uo_color_clan_glow`='%d %d %d', ", g_UserOption_Color[id][COLOR_TYPE_HUD][0], g_UserOption_Color[id][COLOR_TYPE_HUD][1], g_UserOption_Color[id][COLOR_TYPE_HUD][2], g_UserOption_Color[id][COLOR_TYPE_NVISION][0], g_UserOption_Color[id][COLOR_TYPE_NVISION][1], g_UserOption_Color[id][COLOR_TYPE_NVISION][2], g_UserOption_Color[id][COLOR_TYPE_FLARE][0], g_UserOption_Color[id][COLOR_TYPE_FLARE][1], g_UserOption_Color[id][COLOR_TYPE_FLARE][2], g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW][0], g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW][1], g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW][2]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`uo_hud_general_position`='%f %f %f', `uo_hud_general_effect`='%d', `uo_hud_general_style`='%d', ", g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][0], g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][1], g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][2], g_UserOption_HudEffect[id][HUD_TYPE_GENERAL], g_UserOption_HudStyle[id][HUD_TYPE_GENERAL]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`uo_hud_combo_position`='%f %f %f', `uo_hud_combo_effect`='%d', `uo_hud_combo_style`='%d', ", g_UserOption_HudPosition[id][HUD_TYPE_COMBO][0], g_UserOption_HudPosition[id][HUD_TYPE_GENERAL][1], g_UserOption_HudPosition[id][HUD_TYPE_COMBO][2], g_UserOption_HudEffect[id][HUD_TYPE_COMBO], g_UserOption_HudStyle[id][HUD_TYPE_COMBO]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`uo_hud_clan_combo_position`='%f %f %f', `uo_hud_clan_combo_effect`='%d', `uo_hud_clan_combo_style`='%d', ", g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][0], g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][1], g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][2], g_UserOption_HudEffect[id][HUD_TYPE_CLAN_COMBO], g_UserOption_HudStyle[id][HUD_TYPE_CLAN_COMBO]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`uo_invis`='%d', `uo_nvision`='%d', `uo_clan_glow`='%d', `uo_leveltotal`='%d', ", g_UserOption_Invis[id], g_UserOption_NVision[id], g_UserOption_ClanGlow[id], g_UserOption_LevelTotal[id]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`bought_ok`='0' ");
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE (`acc_id`='%d');", acc_id);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 10);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	iLen = 0;
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE `zp9_pjs_stats` SET ");
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`time_played`='%d' ", g_TimePlayed[id][TIME_MIN]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE (`acc_id`='%d');", acc_id);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 11);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

loadSql() {
	new sData[128];
	SQL_SetAffinity("mysql");
	SQL_GetAffinity(sData, charsmax(sData));

	if(!equal(sData, "mysql")) {
		set_fail_state("loadSql() - No se pudo establecer la afinidad del driver SQL a MySQL.");
		return;
	}

	new iErrorNum;

	g_SqlTuple = SQL_MakeDbTuple("127.0.0.1", __SERVERS[g_ServerId][serverSqlUsername], __SERVERS[g_ServerId][serverSqlPassword], __SERVERS[g_ServerId][serverSqlDatabase]);
	g_SqlConnection = SQL_Connect(g_SqlTuple, iErrorNum, sData, charsmax(sData));
	g_SqlQuery[0] = EOS;

	if(g_SqlConnection == Empty_Handle) {
		set_fail_state("loadSql() - Error en la conexión a la base de datos - [%d] %s.", iErrorNum, sData);
		return;
	}

	loadQueries();
	set_task(0.5, "task__SetConfigs");
}

loadQueries() {

}

public task__SetConfigs() {
	set_cvar_string("hostname", fmt("#08 ZOMBIE PLAGUE [%s] | www.DrunkGaming.net", __PLUGIN_VERSION));
	set_cvar_num("sv_restart", 1);
}

showMenu__Diffs(const id, const diff_class) {
	SetGlobalTransTarget(id);
	
	g_MenuData_DiffClass[id] = diff_class;

	oldmenu_create("\yDIFICULTAD\r:\w %s", "@menu__Diffs", __DIFFS_CLASSES[diff_class]);

	new i;
	new j;

	for(i = DIFF_NORMAL, j = 1; i < structIdDiffs; ++i, ++j) {
		if(g_Diff[id][diff_class] == i) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ELEGIDO)", j, __DIFFS[diff_class][i][diffNameMin]);
			oldmenu_additem(-1, -1, "\r - \w%s^n", __DIFFS[diff_class][i][diffInfo]);
		} else {
			oldmenu_additem(j, _:i, "\r%d.\w %s", j, __DIFFS[diff_class][i][diffNameMin]);
			oldmenu_additem(-1, -1, "\r - \w%s^n", __DIFFS[diff_class][i][diffInfo]);
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

@menu__Diffs(const id, const item, const value) {
	if(!item) {
		showMenu__Character(id);
		return;
	}

	new iDiffClass = g_MenuData_DiffClass[id];

	if(g_IsWarmUp || get_member_game(m_bRoundTerminating) || g_CurrentGameMode == MODE_SURVIVOR || g_CurrentGameMode == MODE_NEMESIS) {
		clientPrintColor(id, _, "No puedes cambiar la dificultad mientras esté en calentamiento, ronda en curso o un modo especial.");

		showMenu__Diffs(id, iDiffClass);
		return;
	} else if(dg_get_user_acc_id(id) != 1 && value == DIFF_NIGHTMARE && ((iDiffClass == DIFF_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_NORMAL]) || (iDiffClass == DIFF_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_NORMAL]))) {
		clientPrintColor(id, _, "Debes tener el logro !g%s: NORMAL!y para elegir esta dificultad.", __DIFFS_CLASSES[iDiffClass]);

		showMenu__Diffs(id, iDiffClass);
		return;
	} else if(dg_get_user_acc_id(id) != 1 && value == DIFF_SUICIDAL && ((iDiffClass == DIFF_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_NIGHTMARE]) || (iDiffClass == DIFF_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_NIGHTMARE]))) {
		clientPrintColor(id, _, "Debes tener el logro !g%s: NIGHTMARE!y para elegir esta dificultad.", __DIFFS_CLASSES[iDiffClass]);

		showMenu__Diffs(id, iDiffClass);
		return;
	} else if(dg_get_user_acc_id(id) != 1 && value == DIFF_HELL && ((iDiffClass == DIFF_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_SUICIDAL]) || (iDiffClass == DIFF_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_SUICIDAL]))) {
		clientPrintColor(id, _, "Debes tener el logro !g%s: SUICIDAL!y para elegir esta dificultad.", __DIFFS_CLASSES[iDiffClass]);

		showMenu__Diffs(id, iDiffClass);
		return;
	}

	g_Diff[id][iDiffClass] = value;

	clientPrintColor(id, _, "La dificultad del !g%s!y ahora es !g%s!y.", __DIFFS_CLASSES[iDiffClass], __DIFFS[iDiffClass][value][diffNameMay]);
	showMenu__Diffs(id, iDiffClass);
}

showMenu__AchievementsClasses(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	formatex(sItem, charsmax(sItem), "LOGROS^n\wLogros completados en total\r:\y %d\R", g_AchievementTotal[id]);
	iMenuId = menu_create(sItem, "@menu__AchievementsClasses");

	for(i = ACHIEVEMENT_CLASS_HUMAN; i < structIdAchievementClasses; ++i) {
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, __ACHIEVEMENTS_CLASSES[i], sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_AchievementClasses[id] = min(g_MenuPage_AchievementClasses[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_AchievementClasses[id]);
}

@menu__AchievementsClasses(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_AchievementClasses[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData_AchievementClass[id] = iItemId;

	showMenu__Achievements(id);
	return PLUGIN_HANDLED;
}

showMenu__Achievements(const id) {
	new iAchievementClass = g_MenuData_AchievementClass[id];
	new sItem[64];
	new iMenuId;
	new i;
	new j = 0;
	new k = 0;
	new sPosition[4];

	formatex(sItem, charsmax(sItem), "LOGROS\r:\w %s^n\wLogros completados\r:\y %d\R", __ACHIEVEMENTS_CLASSES[iAchievementClass], checkAchievementTotal(id, iAchievementClass));
	iMenuId = menu_create(sItem, "@menu__Achievements");

	for(i = 0; i < structIdAchievements; ++i) {
		if(__ACHIEVEMENTS[i][achievementClass] != -1 && iAchievementClass != __ACHIEVEMENTS[i][achievementClass]) {
			++k;
			continue;
		}

		if(__ACHIEVEMENTS[i][achievementEnabled]) {
			formatex(sItem, charsmax(sItem), "%s%s%s", ((!g_Achievement[id][i]) ? "\d" : "\w"), __ACHIEVEMENTS[i][achievementName], ((!g_Achievement[id][i]) ? " \r(NO COMPLETADO)" : " \y(COMPLETADO)"));
		} else {
			formatex(sItem, charsmax(sItem), "\d%s", __ACHIEVEMENTS[i][achievementName]);
		}

		++j;
		g_AchievementInt[id][(i - k)] = i;

		num_to_str(j, sPosition, charsmax(sPosition));
		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_AchievementPage[id][iAchievementClass] = min(g_AchievementPage[id][iAchievementClass], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_AchievementPage[id][iAchievementClass]);
}

checkAchievementTotal(const id, const class) {
	new i;
	new iCount = 0;

	for(i = 0; i < structIdAchievements; ++i) {
		if(class == __ACHIEVEMENTS[i][achievementClass] && g_Achievement[id][i]) {
			++iCount;
		}
	}

	return iCount;
}

@menu__Achievements(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iAchievementClass = g_MenuData_AchievementClass[id];
	new iItemId;

	player_menu_info(id, iItemId, iItemId, g_AchievementPage[id][iAchievementClass]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__AchievementsClasses(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[5];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = (str_to_num(sPosition) - 1);

	if(!__ACHIEVEMENTS[g_AchievementInt[id][iItemId]][achievementEnabled]) {
		clientPrintColor(id, _, "Este logro está deshabilitado.");

		showMenu__Achievements(id);
		return PLUGIN_HANDLED;
	}

	g_MenuData_AchievementIn[id] = iItemId;

	showMenu__AchievementInfo(id, g_AchievementInt[id][g_MenuData_AchievementIn[id]]);
	return PLUGIN_HANDLED;
}

showMenu__AchievementInfo(const id, const achievement) {
	oldmenu_create("\y%s - %s", "@menu__AchievementInfo", __ACHIEVEMENTS[achievement][achievementName], ((!g_Achievement[id][achievement]) ? "\r(NO COMPLETADO)" : "\y(COMPLETADO)"));

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s", __ACHIEVEMENTS[achievement][achievementInfo]);

	if(__ACHIEVEMENTS[achievement][achievementUsersNeedP]) {
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d usuarios conectados", __ACHIEVEMENTS[achievement][achievementUsersNeedP]);
	} else if(__ACHIEVEMENTS[achievement][achievementUsersNeedA]) {
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d usuarios vivos", __ACHIEVEMENTS[achievement][achievementUsersNeedA]);
	}

	oldmenu_additem(-1, -1, "^n\yRECOMPENSA\r:");
	oldmenu_additem(-1, -1, "\r - \y+%d\w pF", __ACHIEVEMENTS[achievement][achievementReward]);

	if(g_Achievement[0][achievement]) {
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_AchievementUnlocked[0][achievement]));
		oldmenu_additem(-1, -1, "\r - \wPor el usuario\r:\y %s^n", g_AchievementName[0][achievement]);
	} else if(g_Achievement[id][achievement]) {
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_AchievementUnlocked[id][achievement]));

		oldmenu_additem(1, 1, "^n\r1.\w Mostrar logro en el Chat");
	} else {
		oldmenu_additem(-1, -1, "^n\d1. Mostrar logro en el Chat");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__AchievementInfo(const id, const item) {
	if(!item) {
		showMenu__Achievements(id);
		return;
	}

	new iAchievement = g_MenuData_AchievementIn[id];

	switch(item) {
		case 1: {
			if(g_Achievement[id][g_AchievementInt[id][iAchievement]]) {
				if(dg_get_user_acc_id(id) == 1 || g_AchievementTimeLink[id] < get_gametime()) {
					g_AchievementTimeLink[id] = (get_gametime() + 15.0);

					clientPrintColor(0, _, "!t%n!y muestra su logro !g%s!y conseguido el !g%s!y.", id, __ACHIEVEMENTS[g_AchievementInt[id][iAchievement]][achievementName], getUnixToTime(g_AchievementUnlocked[id][g_AchievementInt[id][iAchievement]]));
				}
			}

			showMenu__AchievementInfo(id, g_AchievementInt[id][iAchievement]);
		}
	}
}


giveHat(const id, const hat) {
	if(!is_user_connected(id)) {
		return;
	}

	if(dg_get_user_acc_status(id) < STATUS_LOGGED) {
		return;
	}

	if(g_Hat[id][hat]) {
		return;
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp8_hats` (`acc_id`, `hat_id`, `hat_timestamp`) VALUES ('%d', '%d', '%d');", dg_get_user_acc_id(id), hat, iSysTime);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 12);
	} else {
		SQL_FreeHandle(sqlQuery);

		new iSysTime = get_arg_systime();

		g_Hat[id][hat] = 1;
		g_HatUnlocked[id][hat] = iSysTime;
		++g_HatTotal[id];

		clientPrintColor(0, id, "!t%n!y ha conseguido el gorro !g%s!y.", id, __HATS[hat][hatName]);
	}
}

getHatByOwner(const ent) {
	return find_ent_by_owner(-1, __ENT_CLASSNAME_HAT, ent);
}

updatePlayerHat(const id) {
	if(!is_user_connected(id)) {
		return;
	}

	if(dg_get_user_acc_status(id) < STATUS_PLAYING) {
		return;
	}

	new iEnt = getHatByOwner(id);

	if(!is_valid_ent(iEnt)) {
		return;
	}

	if(g_HatNext[id]) {
		g_HatId[id] = g_HatNext[id];
		g_HatNext[id] = 0;
	}

	if(!g_HatId[id] || g_Class[id] != CLASS_HUMAN || g_CurrentGameMode == MODE_GUNGAME || g_CurrentGameMode == MODE_MEGA_GUNGAME || g_CurrentGameMode == MODE_DUEL_FINAL || g_CurrentGameMode == MODE_GRUNT) {
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
		return;
	}

	entity_set_model(iEnt, __HATS[g_HatId[id]][hatModel]);

	if(g_HatId[id] == HAT_PSYCHO) {
		// remove_task(id + TASK_CONVERT_ZOMBIE);
		// set_task(120.0, "task__ConvertZombie", id + TASK_CONVERT_ZOMBIE, .flags="b");
	}

	entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) & ~EF_NODRAW));
}

hidePlayerHat(const id) {
	if(!is_user_connected(id)) {
		return;
	}

	if(dg_get_user_acc_status(id) < STATUS_PLAYING) {
		return;
	}

	new iEnt = getHatByOwner(id);

	if(!is_valid_ent(iEnt)) {
		return;
	}

	entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
}

showMenu__Hats(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("GORROS\R", "@menu__Hats");

	for(i = HAT_NONE; i < structIdHats; ++i) {
		if(i == HAT_NONE) {
			formatex(sItem, charsmax(sItem), "\w%s^n", __HATS[i][hatName]);
		} else if(g_HatId[id] == i) {
			formatex(sItem, charsmax(sItem), "\w%s \y(EQUIPADO)", __HATS[i][hatName]);
		} else if(g_HatNext[id] == i && i) {
			formatex(sItem, charsmax(sItem), "\w%s \y(ELEGIDO)", __HATS[i][hatName]);
		} else if(g_Hat[id][i]) {
			formatex(sItem, charsmax(sItem), "\w%s", __HATS[i][hatName]);
		} else {
			formatex(sItem, charsmax(sItem), "\d%s", __HATS[i][hatName]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_Hats[id] = min(g_MenuPage_Hats[id], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_Hats[id]);
}

@menu__Hats(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Hats[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(iItemId == HAT_NONE) {
		g_HatNext[id] = HAT_NONE;
		
		if(g_HatId[id]) {
			g_HatId[id] = HAT_NONE;

			clientPrintColor(id, _, "Tu gorro ha sido removido.");
		}

		showMenu__Hats(id);
	} else {
		g_MenuData_HatId[id] = iItemId;
		showMenu__HatInfo(id);
	}

	return PLUGIN_HANDLED;
}

showMenu__HatInfo(const id) {
	new iHatId = g_MenuData_HatId[id];

	if(!iHatId) {
		showMenu__Hats(id);
		return;
	}

	new sHatName[32];
	copy(sHatName, charsmax(sHatName), __HATS[iHatId][hatName]);
	strtoupper(sHatName);

	oldmenu_create("\y%s - %s", "@menu__HatInfo", sHatName, ((!g_Hat[id][iHatId]) ? " \r(NO OBTENIDO)" : " \y(OBTENIDO)"));

	oldmenu_additem(-1, -1, "\yREQUERIMIENTOS\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __HATS[iHatId][hatDesc]);

	if(__HATS[iHatId][hatDescExtra][0]) {
		oldmenu_additem(-1, -1, "\yNOTA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", __HATS[iHatId][hatDescExtra]);
	}

	oldmenu_additem(-1, -1, "\yBENEFICIOS\r:"); {
		if(__HATS[iHatId][hatUpgrade1]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Vida", __HATS[iHatId][hatUpgrade1]);
		}

		if(__HATS[iHatId][hatUpgrade2]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Velocidad", __HATS[iHatId][hatUpgrade2]);
		}

		if(__HATS[iHatId][hatUpgrade3]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Gravedad", __HATS[iHatId][hatUpgrade3]);
		}

		if(__HATS[iHatId][hatUpgrade4]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Daño", __HATS[iHatId][hatUpgrade4]);
		}

		if(__HATS[iHatId][hatUpgrade5]) {
			oldmenu_additem(-1, -1, "\r - \y+x%0.2f\w Ammo Packs", __HATS[iHatId][hatUpgrade5]);
		}

		if(__HATS[iHatId][hatUpgrade6]) {
			oldmenu_additem(-1, -1, "\r - \y+%d%%\w Respawn Humano", __HATS[iHatId][hatUpgrade6]);
		}

		if(__HATS[iHatId][hatUpgrade7]) {
			oldmenu_additem(-1, -1, "\r - \y+%d%%\w Descuento en Items", __HATS[iHatId][hatUpgrade7]);
		}
	}

	if(g_Hat[id][iHatId]) {
		oldmenu_additem(-1, -1, "^n\yGORRO OBTENIDO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", getUnixToTime(g_HatUnlocked[id][iHatId]));

		oldmenu_additem(1, 1, "\r1.\w %s gorro", ((g_HatId[id] == iHatId) ? "Desequipar" : "Equipar"));
		oldmenu_additem(2, 2, "\r2.\w Mostrar gorro en el Chat^n");
	} else {
		oldmenu_additem(-1, -1, "^n\d1. %s gorro", ((g_HatId[id] == iHatId) ? "Desequipar" : "Equipar"));
		oldmenu_additem(-1, -1, "\d2. Mostrar gorro en el Chat^n");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__HatInfo(const id, const item) {
	if(!item) {
		showMenu__Hats(id);
		return;
	}

	new iHatId = g_MenuData_HatId[id];
	
	switch(item) {
		case 1: {
			if(g_Hat[id][iHatId]) {
				g_HatNext[id] = iHatId;

				if(get_member_game(m_bRoundTerminating)) {
					updatePlayerHat(id);
				} else {
					clientPrintColor(id, _, "Cuando vuelvas a ser humano tendrás el gorro !g%s!y.", __HATS[iHatId][hatName]);
				}
			}

			showMenu__Hats(id);
		} case 2: {
			if(g_Hat[id][iHatId]) {
				if(dg_get_user_acc_id(id) == 1 || g_HatTimeLink[id] < get_gametime()) {
					g_HatTimeLink[id] = (get_gametime() + 15.0);

					clientPrintColor(0, _, "!t%n!y muestra su gorro !g%s!y conseguido el !g%s!y.", id, __HATS[iHatId][hatName], getUnixToTime(g_HatUnlocked[id][iHatId]));
				}
			}

			showMenu__HatInfo(id);
		}
	}
}

showMenu__Artifacts(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, structIdArtifacts);
	oldmenu_create("\yARTEFACTOS \r[%d - %d]\y\R%d / %d^n\wPuedes equiparte hasta dos anillos y un collar", "@menu__Artifacts", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s%s%s", j, __ARTIFACTS[i][artifactName], ((g_ArtifactsEquiped[id][i]) ? " \y(EQUIPADO)" : ""), ((i == 3 || i == 7) ? "^n" : ""));
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

@menu__Artifacts(const id, const item, const value, page) {
	if(!item || value > structIdArtifacts) {
		showMenu__Character(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage_Artifacts[id] = iNewPage;

		showMenu__Artifacts(id, iNewPage);
		return;
	}

	g_MenuData_ArtifactId[id] = value;

	showMenu__ArtifactInfo(id);
}

showMenu__ArtifactInfo(const id) {
	new iArtifact = g_MenuData_ArtifactId[id];
	new sPointsOutput[64];

	sPointsOutput[0] = EOS;

	if(__ARTIFACTS[iArtifact][artifactClass] == ARTIFACT_CLASS_BRACELET) {
		new sDiamonds[16];
		new sDiamondsUsed[16];

		addDot(g_PointInDiamond[id], sDiamonds, charsmax(sDiamonds));
		addDot(g_PointInDiamondUsed[id], sDiamondsUsed, charsmax(sDiamondsUsed));

		formatex(sPointsOutput, charsmax(sPointsOutput), "\wDiamantes en total\r:\y %s \d(Usado: %d)", sDiamonds, sDiamondsUsed);
	} else {
		new sPointsFragment[16];

		addDot(g_Point[id][P_FRAGMENT], sPointsFragment, charsmax(sPointsFragment));
		formatex(sPointsOutput, charsmax(sPointsOutput), "\wPuntos de Fragmento\r:\y %s", sPointsFragment);
	}

	oldmenu_create("\yARTEFACTO\r:\w %s^n%s", "@menu__ArtifactInfo", __ARTIFACTS[iArtifact][artifactName], sPointsOutput);

	switch(__ARTIFACTS[iArtifact][artifactClass]) {
		case ARTIFACT_CLASS_RING: {
			if(g_Artifact[id][iArtifact] == (charsmax(__ARTIFACTS_RANGES) - 1)) {
				oldmenu_additem(-1, -1, "\yAL EQUIPAR TU ANILLO\r:");

				switch(iArtifact) {
					case ARTIFACT_RING_EXTRA_ITEM_COST: {
						oldmenu_additem(-1, -1, "\r - \wEl costo de tus items reduce en un %d%%^n", (g_Artifact[id][iArtifact] * 5));
					} case ARTIFACT_RING_AMMOPACKS: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador de AmmoPacks aumenta en un x%0.2f^n", (float(g_Artifact[id][iArtifact]) * 0.25));
					} case ARTIFACT_RING_COMBO: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador al ganar combo aumenta en un x%d^n", ((g_Artifact[id][iArtifact] + 1) * 1));
					}
				}

				oldmenu_additem(-1, -1, "\d1. El anillo está en su máximo poder");
			} else {
				new iCost = ((g_Artifact[id][iArtifact] + 1) * __ARTIFACTS[iArtifact][artifactCost]);

				oldmenu_additem(-1, -1, "\yAL EQUIPAR TU ANILLO\r:");

				switch(iArtifact) {
					case ARTIFACT_RING_EXTRA_ITEM_COST: {
						oldmenu_additem(-1, -1, "\r - \wEl costo de tus items reduce en un %d%%", (g_Artifact[id][iArtifact] * 5));
						oldmenu_additem(-1, -1, "\r - \wPróximo nivel\r:\y +%d%%^n", ((g_Artifact[id][iArtifact] + 1) * 5));
					} case ARTIFACT_RING_AMMOPACKS: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador de AmmoPacks aumenta en un x%0.2f", (float(g_Artifact[id][iArtifact]) * 0.25));
						oldmenu_additem(-1, -1, "\r - \wPróximo nivel\r:\y +x%0.2f^n", ((float(g_Artifact[id][iArtifact]) + 1.0) * 0.25));
					} case ARTIFACT_RING_COMBO: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador al ganar combo aumenta en un x%d", ((g_Artifact[id][iArtifact] + 1) * 1));
						oldmenu_additem(-1, -1, "\r - \wPróximo nivel\r:\y +x%d^n", ((g_Artifact[id][iArtifact] + 1) * 1));
					}
				}

				oldmenu_additem(-1, -1, "\yCOSTO DEL ANILLO\r:");
				oldmenu_additem(-1, -1, "\r - \y+%d\w SALDO^n", iCost);

				if(g_Point[id][P_FRAGMENT] >= iCost) {
					oldmenu_additem(1, 1, "\r1.\w Subir al grado %c", __ARTIFACTS_RANGES[g_Artifact[id][iArtifact] + 1]);
				} else {
					oldmenu_additem(-1, -1, "\d1. Subir al grado %c", __ARTIFACTS_RANGES[g_Artifact[id][iArtifact] + 1]);
				}
			}

			if(g_Artifact[id][iArtifact]) {
				oldmenu_additem(2, 2, "\r2.\w %s", ((g_ArtifactsEquiped[id][iArtifact]) ? "Desequipar" : "Equipar"));
			} else {
				oldmenu_additem(-1, -1, "\d2. %s", ((g_ArtifactsEquiped[id][iArtifact]) ? "Desequipar" : "Equipar"));
			}
		} case ARTIFACT_CLASS_NECKLASE: {
			if(g_Artifact[id][iArtifact] == (charsmax(__ARTIFACTS_RANGES) - 1)) {
				oldmenu_additem(-1, -1, "\yAL EQUIPAR TU COLLAR\r:");
				
				switch(iArtifact) {
					case ARTIFACT_NECKLASE_FIRE: {
						oldmenu_additem(-1, -1, "\r - \wEl fuego que te afecta solo te reduce velocidad^n");
					} case ARTIFACT_NECKLASE_FROST: {
						oldmenu_additem(-1, -1, "\r - \wTienes 35% de probabilidades de que el hielo/supernova no te afecte^n");
					} case ARTIFACT_NECKLASE_DAMAGE: {
						oldmenu_additem(-1, -1, "\r - \wEl daño recibido siendo zombie se reduce en un %d%%^n", ((g_Artifact[id][iArtifact] + 1) * 2));
					}
				}

				oldmenu_additem(-1, -1, "\d1. El collar está en su máximo poder");
			} else {
				new iCost;
				new iOk;

				if(iArtifact == ARTIFACT_NECKLASE_DAMAGE) {
					iCost = ((g_Artifact[id][iArtifact] + 1) * __ARTIFACTS[iArtifact][artifactCost]);
					iOk = 1;
				} else {
					iCost = __ARTIFACTS[iArtifact][artifactCost];
					iOk = 0;
				}

				oldmenu_additem(-1, -1, "\yAL EQUIPAR TU COLLAR\r:");
				
				switch(iArtifact) {
					case ARTIFACT_NECKLASE_FIRE: {
						oldmenu_additem(-1, -1, "\r - \wEl fuego que te afecta solo te reduce velocidad^n");
					} case ARTIFACT_NECKLASE_FROST: {
						oldmenu_additem(-1, -1, "\r - \wTienes 35% de probabilidades de que el hielo/supernova no te afecte^n");
					} case ARTIFACT_NECKLASE_DAMAGE: {
						oldmenu_additem(-1, -1, "\r - \wEl daño recibido siendo zombie se reduce en un %d%%", ((g_Artifact[id][iArtifact] + 1) * 2));
						oldmenu_additem(-1, -1, "\r - \wPróximo nivel\r:\y +%d%%^n", ((g_Artifact[id][iArtifact] + 1) * 5));
					}
				}

				oldmenu_additem(-1, -1, "\yCOSTO DEL COLLAR\r:");
				oldmenu_additem(-1, -1, "\r - \y+%d\w SALDO\w^n", iCost);

				if(iOk) {
					if(g_Point[id][P_FRAGMENT] >= iCost) {
						oldmenu_additem(1, 1, "\r1.\w Subir al grado %c", __ARTIFACTS_RANGES[(g_Artifact[id][iArtifact] + 1)]);
					} else {
						oldmenu_additem(-1, -1, "\d1. Subir al grado %c", __ARTIFACTS_RANGES[(g_Artifact[id][iArtifact] + 1)]);
					}
				} else {
					if(g_Point[id][P_FRAGMENT] >= iCost) {
						oldmenu_additem(1, 1, "\r1.\w Comprar collar");
					} else {
						oldmenu_additem(-1, -1, "\d1. Comprar collar");
					}
				}
			}

			if(g_Artifact[id][iArtifact]) {
				oldmenu_additem(2, 2, "\r2.\w %s", ((g_ArtifactsEquiped[id][iArtifact]) ? "Desequipar" : "Equipar"));
			} else {
				oldmenu_additem(-1, -1, "\d2. %s", ((g_ArtifactsEquiped[id][iArtifact]) ? "Desequipar" : "Equipar"));
			}
		} case ARTIFACT_CLASS_BRACELET: {
			oldmenu_additem(-1, -1, "\yAL ACTIVAR TU PULSERA\r:");

			switch(iArtifact) {
				case ARTIFACT_BRACELET_AMMOPACKS: {
					oldmenu_additem(-1, -1, "\r - \wTu multiplicador de AmmoPacks aumentará un +x1.0^n");
				} case ARTIFACT_BRACELET_COMBO: {
					oldmenu_additem(-1, -1, "\r - \wTu multiplicador al ganar combo aumentará un +x1^n");
				} case ARTIFACT_BRACELET_POINTS: {
					oldmenu_additem(-1, -1, "\r - \wTu multiplicador de puntos aumentará un +x1^n");
				}
			}

			oldmenu_additem(-1, -1, "\yCOSTO DE LA PULSERA\r:");
			oldmenu_additem(-1, -1, "\r -\w \y+%d\w DIAMANTES EN TOTAL^n", __ARTIFACTS[iArtifact][artifactCost]);

			oldmenu_additem(-1, -1, "\yNOTA #1\r:^n\r - \wLas pulseras sólo se activan si realizaste compras de DIAMANTES^n");
			
			oldmenu_additem(2, 2, "\r2.\w %s^n", ((g_ArtifactsEquiped[id][iArtifact]) ? "Desequipar" : "Equipar"));
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ArtifactInfo(const id, const item) {
	if(!item) {
		showMenu__Artifacts(id, g_MenuPage_Artifacts[id]);
		return;
	}

	new iArtifact = g_MenuData_ArtifactId[id];

	switch(item) {
		case 1: {
			if(__ARTIFACTS[iArtifact][artifactClass] != ARTIFACT_CLASS_BRACELET) {
				new iCost;
				new iOk;

				if(__ARTIFACTS[iArtifact][artifactClass] == ARTIFACT_CLASS_NECKLASE) {
					if(iArtifact == ARTIFACT_NECKLASE_DAMAGE) {
						if(g_Artifact[id][iArtifact] == (charsmax(__ARTIFACTS_RANGES) - 1)) {
							clientPrintColor(id, _, "El collar está en su máximo poder.");

							showMenu__ArtifactInfo(id);
							return;
						}

						iCost = ((g_Artifact[id][iArtifact] + 1) * __ARTIFACTS[iArtifact][artifactCost]);
						iOk = 1;
					} else {
						if(g_Artifact[id][iArtifact]) {
							clientPrintColor(id, _, "Ya has comprado este collar.");

							showMenu__ArtifactInfo(id);
							return;
						}

						iCost = __ARTIFACTS[iArtifact][artifactCost];
						iOk = 0;
					}
				} else {
					if(g_Artifact[id][iArtifact] == (charsmax(__ARTIFACTS_RANGES) - 1)) {
						clientPrintColor(id, _, "El anillo está en su máximo poder.");

						showMenu__ArtifactInfo(id);
						return;
					}

					iCost = ((g_Artifact[id][iArtifact] + 1) * __ARTIFACTS[iArtifact][artifactCost]);
					iOk = 1;
				}

				if(g_Point[id][P_FRAGMENT] < iCost) {
					clientPrintColor(id, _, "No tienes dinero suficientes.");

					showMenu__ArtifactInfo(id);
					return;
				}

				g_Point[id][P_FRAGMENT] -= iCost;

				if(iOk) {
					++g_Artifact[id][iArtifact];

					clientPrintColor(0, id, "!t%n!y compró el !g%s [!t%c!g]!y por !g%d pF!y.", id, __ARTIFACTS[iArtifact][artifactName], __ARTIFACTS_RANGES[g_Artifact[id][iArtifact]], iCost);
				} else {
					g_Artifact[id][iArtifact] = 1;

					clientPrintColor(0, id, "!t%n!y compró el !g%s!y por !g%d pF!y.", id, __ARTIFACTS[iArtifact][artifactName], iCost);
				}

				showMenu__ArtifactInfo(id);
			} else {
				showMenu__ArtifactInfo(id);
			}
		} case 2: {
			switch(__ARTIFACTS[iArtifact][artifactClass]) {
				case ARTIFACT_CLASS_RING: {
					new iCount = 0;

					if(g_ArtifactsEquiped[id][ARTIFACT_RING_EXTRA_ITEM_COST]) {
						++iCount;
					}

					if(g_ArtifactsEquiped[id][ARTIFACT_RING_AMMOPACKS]) {
						++iCount;
					}

					if(g_ArtifactsEquiped[id][ARTIFACT_RING_COMBO]) {
						++iCount;
					}

					if(iCount >= 2 && !g_ArtifactsEquiped[id][iArtifact]) {
						clientPrintColor(id, _, "Sólo puedes tener dos anillos equipados a la vez.");

						showMenu__ArtifactInfo(id);
						return;
					}

					g_ArtifactsEquiped[id][iArtifact] = !g_ArtifactsEquiped[id][iArtifact];
					
					clientPrintColor(id, _, "Has %sequipado el !g%s!y.", ((g_ArtifactsEquiped[id][iArtifact]) ? "" : "des"), __ARTIFACTS[iArtifact][artifactName]);
				} case ARTIFACT_CLASS_NECKLASE: {
					new iCount = 0;

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_FIRE]) {
						++iCount;
					}

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_FROST]) {
						++iCount;
					}

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_DAMAGE]) {
						++iCount;
					}

					if(iCount >= 2 && !g_ArtifactsEquiped[id][iArtifact]) {
						clientPrintColor(id, _, "Sólo puedes tener un collar equipado a la vez.");

						showMenu__ArtifactInfo(id);
						return;
					}

					g_ArtifactsEquiped[id][iArtifact] = !g_ArtifactsEquiped[id][iArtifact];

					clientPrintColor(id, _, "Has %sequipado el !g%s!y.", ((g_ArtifactsEquiped[id][iArtifact]) ? "" : "des"), __ARTIFACTS[iArtifact][artifactName]);
				} case ARTIFACT_CLASS_BRACELET: {
					new iCost = __ARTIFACTS[iArtifact][artifactCost];
					new iNot = 0;

					if((g_PointInDiamondUsed[id] - iCost) < 0 && !g_ArtifactsEquiped[id][iArtifact]) {
						iNot = __ARTIFACTS[iArtifact][artifactCost];
					}

					if(iNot > 0) {
						clientPrintColor(id, _, "Debes comprar diamantes para poder activar la pulsera deseada.");

						showMenu__ArtifactInfo(id);
						return;
					}

					g_ArtifactsEquiped[id][iArtifact] = !g_ArtifactsEquiped[id][iArtifact];

					clientPrintColor(id, _, "Has %sactivado el !g%s!y.", ((g_ArtifactsEquiped[id][iArtifact]) ? "" : "des"), __ARTIFACTS[iArtifact][artifactName]);

					if(g_ArtifactsEquiped[id][iArtifact]) {
						g_PointInDiamondUsed[id] -= iCost;
					} else {
						g_PointInDiamondUsed[id] += iCost;
					}
				}
			}
		}
	}
}

showMenu__Mastery(const id, const mastery) {
	if(mastery) {
		new iOk;
		new iCost;
		
		if(g_Mastery[id]) {
			iOk = ((g_Point[id][P_DIAMOND] < 10) ? 0 : 1);
			iCost = 10;
		} else {
			iOk = 1;
			iCost = 0;
		}

		g_MenuData_MasteryId[id] = mastery;

		oldmenu_create("\yMAESTRÍA^n\wLas maestrías proporcionan un \y+x1.0 XP\w", "@menu__MasteryIn");

		oldmenu_additem(-1, -1, "\wMaestría elegida\r:\y %s", __MASTERYS[mastery]);
		oldmenu_additem(-1, -1, "\wHorario de efecto\r:\y %s", ((mastery == MASTERY_MORNING) ? "11:00 - 22:59" : "23:00 - 10:59"));

		if(!iCost) {
			oldmenu_additem(-1, -1, "^n\yNOTA\r:^n\r - \wUna vez elegida la maestría, necesitarás \yDIAMANTES\w^npara volver a cambiar");
		}

		oldmenu_additem(1, 1, "^n\r1.%s Elegir esta maestría %s(%d DIAMANTES)", ((!iOk) ? "\d" : "\w"), ((!iOk) ? "\r" : "\y"), iCost);
		oldmenu_additem(0, 0, "\r0.\w Volver");

		oldmenu_display(id);
	} else {
		oldmenu_create("\yELEGIR MAESTRÍA^n\wSelecciona una para más información", "@menu__Mastery");

		oldmenu_additem(1, 1, "\r1.%s %s", ((!g_Mastery[id]) ? "\w" : "\d"), ((g_Mastery[id] == MASTERY_MORNING) ? "Elegido" : "Día \y[11:00 a 22:59]"));
		oldmenu_additem(2, 2, "\r2.%s %s", ((!g_Mastery[id]) ? "\w" : "\d"), ((g_Mastery[id] == MASTERY_NIGHT) ? "Elegido" : "Noche \y[23:00 a 10:59]"));

		oldmenu_additem(0, 0, "^n\r0.\w Volver");
		oldmenu_display(id);
	}
}

@menu__Mastery(const id, const item) {
	if(!item) {
		showMenu__Character(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Mastery[id] != MASTERY_MORNING) {
				showMenu__Mastery(id, MASTERY_MORNING);
			} else {
				clientPrintColor(id, _, "Ya has seleccionado esta maestría.");
				showMenu__Mastery(id, 0);
			}
		} case 2: {
			if(g_Mastery[id] != MASTERY_NIGHT) {
				showMenu__Mastery(id, MASTERY_NIGHT);
			} else {
				clientPrintColor(id, _, "Ya has seleccionado esta maestría.");
				showMenu__Mastery(id, 0);
			}
		}
	}
}

@menu__MasteryIn(const id, const item) {
	if(!item) {
		showMenu__Mastery(id, 0);
		return;
	}

	new iMastery = g_MenuData_MasteryId[id];

	switch(item) {
		case 1: {
			if(g_Mastery[id]) {
				if(g_Point[id][P_DIAMOND] < 10) {
					clientPrintColor(id, _, "No tienes diamantes suficientes para cambiar tu maestria.");

					showMenu__Mastery(id, iMastery);
					return;
				}

				g_Point[id][P_DIAMOND] -= 10;
				g_Mastery[id] = iMastery;

				clientPrintColor(id, _, "Has cambiado tu maestría al turno !g%s!y.", __MASTERYS[g_Mastery[id]]);
				showMenu__Mastery(id, iMastery);
			} else {
				g_Mastery[id] = iMastery;

				clientPrintColor(id, _, "Has elegido la maestria para el turno !g%s!y.", __MASTERYS[g_Mastery[id]]);
				clientPrintColor(id, _, "Ahora para cambiar tu maestría, requerirá !g10 DIAMANTES!y.");

				showMenu__Mastery(id, 0);
			}
		}
	}
}

@impulse__FlashLight(const id) {
	if(g_Class[id] != CLASS_HUMAN) {
		return PLUGIN_HANDLED;
	}

	if(g_CurrentGameMode == MODE_GRUNT) {
		// g_ModeGrunt_Flash[id] = !g_ModeGrunt_Flash[id];
	}

	return PLUGIN_CONTINUE;
}

@impulse__Spray(const id) {
	return PLUGIN_HANDLED;
}

@event__HLTV() {
	if(!get_member_game(m_bGameStarted)) {
		return;
	}

	g_DrunkAtDay = 0;
	g_DrunkAtNite = 0;
	g_EventModes = 0;

	remove_task(TASK_VIRUST);
	set_task(1.5, "task__VirusT", TASK_VIRUST);

	checkEvents();
	checkMasteryHour();
}

checkEvents() {
	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new iTimeToUnix[3];

	unix_to_time(iSysTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);

	iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 13, 00, 00);
	iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 16, 59, 00);

	if(iSysTime >= iTimeToUnix[0] && iSysTime <= iTimeToUnix[1]) {
		g_DrunkAtDay = 1;
	}

	iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 22, 00, 00);
	iTimeToUnix[2] = time_to_unix(iYear, iMonth, iDay, 00, 00, 00);
	iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 06, 00, 00);

	if((iSysTime >= iTimeToUnix[0]) || (iSysTime >= iTimeToUnix[2] && iSysTime <= iTimeToUnix[1])) {
		g_DrunkAtNite = 1;

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 02, 00, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 04, 00, 00);

		if(iSysTime >= iTimeToUnix[0] && iSysTime <= iTimeToUnix[1]) {
			g_DrunkAtNite = 2;

			// if(!g_ModeMGG_Played) {
				// g_ModeMGG_Played = 2;
			// }
		}

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 00, 15, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 01, 45, 00);

		if(iSysTime >= iTimeToUnix[0] && iSysTime < iTimeToUnix[1]) {
			g_EventModes = 1;
		}
	}
}

public task__VirusT() {
	clearDHUD();

	set_dhudmessage(0, 125, 200, -1.0, 0.25, 0, 0.0, 3.0, 2.0, 1.0);
	show_dhudmessage(0, "¡EL VIRUS-T SE HA LIBERADO!");

	new i;
	new iSysTime = get_arg_systime();

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i)) {
			if(g_DrunkAtDay) {
				clientPrintColor(i, _, "!tDRUNK AT DAY!y: Tu multiplicador de Ammo Packs aumenta un !g+x1.0!y.");
			}

			if(g_DrunkAtNite == 2) {
				clientPrintColor(i, _, "!tSUPER DRUNK AT NITE!y: Tu multiplicador de Ammo Packs aumenta un !g+x2.0!y.");
			} else if(g_DrunkAtNite == 1) {
				clientPrintColor(i, _, "!tDRUNK AT NITE!y: Tu multiplicador de Ammo Packs aumenta un !g+x1.0!y.");
			}

			if(iSysTime < MAX_TIME_TO_BONUS) {
				if(g_Achievement[i][BETA_TESTER] && g_Achievement[i][SUPER_BETA_TESTER]) {
					clientPrintColor(i, _, "!tBONUS DE APERTURA!!y Tu ganancia de Ammo Packs aumenta un !g+x1.0!y.");
				} else {
					clientPrintColor(i, _, "!tBONUS DE APERTURA!!y Tu ganancia de Ammo Packs aumenta un !g+x0.5!y.");
				}
			}
		}
	}
}

checkMasteryHour() {
	new sHour[3];
	new iHour;

	get_time("%H", sHour, charsmax(sHour));
	iHour = str_to_num(sHour);

	if(iHour >= 11 && iHour < 23) {
		g_MasteryType = MASTERY_MORNING;
	} else {
		g_MasteryType = MASTERY_NIGHT;
	}
}

getClassDefault(const TeamName:team, const bool:overrided) {
	if(overrided) {
		if(g_DefaultClassOverride[team]) {
			return g_DefaultClassOverride[team];
		}
	}

	return g_DefaultClass[team];
}

public setClassDefault(const TeamName:team, const class) {
	if(!(TEAM_TERRORIST <= team <= TEAM_CT)) {
		return;
	}

	g_DefaultClass[team] = class;
}

public classOverrideDefault(const TeamName:team, const class) {
	if(!(TEAM_TERRORIST <= team <= TEAM_CT)) {
		return;
	}

	if(!class) {
		g_DefaultClassOverride[team] = 0;
		return;
	}

	g_DefaultClassOverride[team] = class;
}

getHumansAlive() {
	new i;
	new iCount = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i) && (g_Class[i] == CLASS_HUMAN || g_Class[i] == CLASS_SURVIVOR || g_Class[i] == CLASS_WESKER || g_Class[i] == CLASS_SNIPER)) {
			++iCount;
		}
	}

	return iCount;
}

getZombiesAlive() {
	new i;
	new iCount = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i) && (g_Class[i] == CLASS_ZOMBIE || g_Class[i] == CLASS_NEMESIS || g_Class[i] == CLASS_ASSASSIN || g_Class[i] == CLASS_GRUNT)) {
			++iCount;
		}
	}

	return iCount;
}

getClassCountAlive(const class) {
	new i;
	new iCount = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i) && g_Class[i] == class) {
			++iCount;
		}
	}

	return iCount;
}

public bool:changeClass(const id, const attacker, const class, const bool:pre_spawn) {
	utilSetRendering(id);

	setUnlimitedClip(id, false);
	changeLongJump(id, false);

	g_Class[id] = class;
	g_HumanClass[id] = g_HumanClassNext[id];
	g_ZombieClass[id] = g_ZombieClassNext[id];

	if(pre_spawn) {
		setUserTeam(id, __CLASSES[class][class__Team]);

		changePlayerModel(id, class, true);
	} else {
		rg_give_default_items(id);

		changeProps(id, class, false);
		changePlayerModel(id, class, false);

		if(attacker) {
			if(task_exists(id + TASK_FINISHCOMBO)) {
				change_task(id + TASK_FINISHCOMBO, 0.1);
			}

			if(g_ClanCombo[g_ClanSlot[id]]) {
				sendClanMessage(id, "Un miembro humano del clan fue infectado y el combo ha finalizado.");
				// clanFinishCombo(id);
			}

			SendDeathMsg(attacker, id, 0, "teammate");
			SendScoreAttrib(id, 0);

			rgSetUserTeam(id, __CLASSES[class][class__Team], MODEL_UNASSIGNED);

			ExecuteHamB(Ham_AddPoints, id, 0, true);
			ExecuteHamB(Ham_AddPoints, attacker, 1, true);

			set_member(id, m_iDeaths, (get_member(id, m_iDeaths) + 1));

			if(g_ClanSlot[attacker] && g_Clan[g_ClanSlot[attacker]][clanCountOnlineMembers] > 1) {
				++g_Clan[g_ClanSlot[attacker]][clanInfectDone];
			}
		} else {
			rgSetUserTeam(id, __CLASSES[class][class__Team], MODEL_UNASSIGNED);

			SendDeathMsg(id, id, 0, "teammate");
			SendScoreAttrib(id, 0);
		}

		if(__CLASSES[class][class__Team] == TEAM_TERRORIST) {
			message_begin(MSG_ONE, g_Message_ScreenShake, _, id);
			write_short(UNIT_SECOND * 4);
			write_short(UNIT_SECOND * 2);
			write_short(UNIT_SECOND * 10);
			message_end();

			new Float:vecOrigin[3];
			get_entvar(id, var_origin, vecOrigin);
			
			message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
			write_byte(TE_IMPLOSION);
			write_coord_f(vecOrigin[0]);
			write_coord_f(vecOrigin[1]);
			write_coord_f(vecOrigin[2]);
			write_byte(128);
			write_byte(20);
			write_byte(3);
			message_end();

			message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
			write_byte(TE_PARTICLEBURST);
			write_coord_f(vecOrigin[0]);
			write_coord_f(vecOrigin[1]);
			write_coord_f(vecOrigin[2]);
			write_short(50);
			write_byte(70);
			write_byte(3);
			message_end();

			message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
			write_byte(TE_DLIGHT);
			write_coord_f(vecOrigin[0]);
			write_coord_f(vecOrigin[1]);
			write_coord_f(vecOrigin[2]);
			write_byte(20);
			write_byte(g_UserOption_Color[id][COLOR_TYPE_NVISION][0]);
			write_byte(g_UserOption_Color[id][COLOR_TYPE_NVISION][1]);
			write_byte(g_UserOption_Color[id][COLOR_TYPE_NVISION][2]);
			write_byte(2);
			write_byte(0);
			message_end();
		}

		if(get_member_game(m_bGameStarted) && !get_member_game(m_bFreezePeriod)) {
			RequestFrame("@RequestFrame_CheckChangeClassWinConditions");
		}
	}

	clanUpdateHumans(id);
	return true;
}

changeProps(const id, const class, const bool:pre_spawn) {
	new Float:flHab;
	new Float:flHealth;
	new Float:flGravity;
	new iArmor = 0;

	switch(class) {
		case CLASS_HUMAN: {
			flHealth = float(__HUMAN_CLASSES[g_HumanClass[id]][humanClassHealthBase]);
			flHab = (float(g_Hab[id][HAB_H_HEALTH]) + float(__HATS[g_HatId[id]][hatUpgrade1]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acHealth]) : 0.0));

			if(flHab) {
				flHealth += (float(__HABS[HAB_H_HEALTH][habValue]) * flHab);
			}

			flGravity = __HUMAN_CLASSES[g_HumanClass[id]][humanClassGravity];
			flHab = (float(g_Hab[id][HAB_H_GRAVITY]) + float(__HATS[g_HatId[id]][hatUpgrade3]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acGravity]) : 0.0));

			if(flHab) {
				flGravity -= ((float(__HABS[HAB_H_GRAVITY][habValue]) / 100.0) * flHab);
			}

			iArmor = __HUMAN_CLASSES[g_HumanClass[id]][humanClassArmor];
			flHab = float(g_Hab[id][HAB_H_ARMOR]);

			if(flHab) {
				iArmor += floatround((__HABS[HAB_H_ARMOR][habValue] * flHab));
			}
		} case CLASS_ZOMBIE: {
			flHealth = float(__ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassHealthBase]);
			flHab = (float(g_Hab[id][HAB_Z_HEALTH]) + float(__HATS[g_HatId[id]][hatUpgrade1]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acHealth]) : 0.0));

			if(flHab) {
				flHealth += (float(__HABS[HAB_Z_HEALTH][habValue]) * flHab);
			}

			flGravity = __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassGravity];
			flHab = (float(g_Hab[id][HAB_Z_GRAVITY]) + float(__HATS[g_HatId[id]][hatUpgrade3]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acGravity]) : 0.0));

			if(flHab) {
				flGravity -= ((float(__HABS[HAB_Z_GRAVITY][habValue]) / 100.0) * flHab);
			}
		} case CLASS_SURVIVOR: {
			flHealth = (__CLASSES[g_Class[id]][class__HealthBase] * float(getUsersAlive()));
			flHab = float(g_Hab[id][HAB_S_STATS_BASE]);

			if(flHab) {
				flHealth += (((float(__HABS[HAB_S_STATS_BASE][habValue]) * flHab) * flHealth) / 100.0);
			}

			if(g_Diff[id][DIFF_CLASS_SURVIVOR] > DIFF_NORMAL) {
				flHealth *= __DIFFS[DIFF_CLASS_SURVIVOR][g_Diff[id][DIFF_CLASS_SURVIVOR]][diffHealth];
			}

			flGravity = __CLASSES[g_Class[id]][class__Gravity];

			if(flHab) {
				flGravity -= (((float(__HABS[HAB_S_STATS_BASE][habValue]) * flHab) * flGravity) / 400.0);
			}
		} case CLASS_WESKER: {
			flHealth = (__CLASSES[g_Class[id]][class__HealthBase] * float(getUsersAlive()));
			flGravity = __CLASSES[g_Class[id]][class__Gravity];
			iArmor = 80;
		} case CLASS_SNIPER: {
			flHealth = (__CLASSES[g_Class[id]][class__HealthBase] * float(getUsersAlive()));
			flGravity = __CLASSES[g_Class[id]][class__Gravity];
			iArmor = 75;
		} case CLASS_NEMESIS: {
			changeLongJump(id, true, 500.0, 300.0, 2.0);

			flHealth = (__CLASSES[g_Class[id]][class__HealthBase] * float(getUsersAlive()));
			flHab = float(g_Hab[id][HAB_N_STATS_BASE]);

			if(flHab) {
				flHealth += (((float(__HABS[HAB_N_STATS_BASE][habValue]) * flHab) * flHealth) / 100.0);
			}

			if(g_Diff[id][DIFF_CLASS_NEMESIS] > DIFF_NORMAL) {
				flHealth *= __DIFFS[DIFF_CLASS_NEMESIS][g_Diff[id][DIFF_CLASS_NEMESIS]][diffHealth];
			}

			flGravity = __CLASSES[g_Class[id]][class__Gravity];

			if(flHab) {
				flGravity -= (((float(__HABS[HAB_N_STATS_BASE][habValue]) * flHab) * flGravity) / 200.0);
			}
		} case CLASS_ASSASSIN: {
			changeLongJump(id, true, 500.0, 300.0, 4.0);

			flHealth = (__CLASSES[g_Class[id]][class__HealthBase] * float(getUsersAlive()));
			flGravity = __CLASSES[g_Class[id]][class__Gravity];
		} case CLASS_GRUNT: {
			flHealth = (__CLASSES[g_Class[id]][class__HealthBase] * float(getUsersAlive()));
			flGravity = __CLASSES[g_Class[id]][class__Gravity];
		}
	}

	set_entvar(id, var_health, flHealth);
	set_entvar(id, var_max_health, flHealth);
	set_entvar(id, var_gravity, flGravity);

	rg_set_user_footsteps(id, !__CLASSES[g_Class[id]][class__Footsteps]);

	if(pre_spawn) {
		new ArmorType:aArmorType;
		new iDefaultArmor = rg_get_user_armor(id, aArmorType);

		if(iArmor) {
			aArmorType = ARMOR_KEVLAR;
		}

		if(iDefaultArmor < iArmor || get_member(id, m_iKevlar) < aArmorType) {
			rg_set_user_armor(id, max(iArmor, iDefaultArmor), aArmorType);
		}
	} else {
		if(iArmor) {
			rg_set_user_armor(id, iArmor, ARMOR_KEVLAR);
		} else {
			rg_set_user_armor(id, 0, ARMOR_NONE);
		}
	}
}

changePlayerModel(const id, const class, const bool:pre_spawn) {
	new sPlayerModel[128];

	switch(class) {
		case CLASS_HUMAN: {
			copy(sPlayerModel, charsmax(sPlayerModel), __HUMAN_CLASSES[g_HumanClass[id]][humanClassPlayerModel]);
		} case CLASS_ZOMBIE: {
			copy(sPlayerModel, charsmax(sPlayerModel), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassPlayerModel]);
		} default: {
			copy(sPlayerModel, charsmax(sPlayerModel), __CLASSES[class][class__PlayerModel]);
		}
	}

	if(pre_spawn) {
		set_member(id, m_szModel, sPlayerModel);
		set_member(id, m_modelIndexPlayer, g_Class_PlayerModelIndex[class]);
		set_entvar(id, var_modelindex, g_Class_PlayerModelIndex[class]);
	} else {
		rg_set_user_model(id, sPlayerModel);
		set_member(id, m_modelIndexPlayer, g_Class_PlayerModelIndex[class]);
	}
}

@RequestFrame_CheckChangeClassWinConditions() {
	if(get_member_game(m_iRoundWinStatus) != WINSTATUS_NONE) {
		return;
	}

	new iNumAliveTR, iNumAliveCT, iNumDeadTR, iNumDeadCT;
	rg_initialize_player_counts(iNumAliveTR, iNumAliveCT, iNumDeadTR, iNumDeadCT);

	if((iNumAliveTR + iNumAliveCT + iNumDeadTR + iNumDeadCT) >= 2) {
		if(!iNumAliveTR) {
			rg_round_end(g_pCVar_RoundRestartDelay, WINSTATUS_CTS, ROUND_CTS_WIN, .trigger=true);
		} else if(!iNumAliveCT) {
			rg_round_end(g_pCVar_RoundRestartDelay, WINSTATUS_TERRORISTS, ROUND_TERRORISTS_WIN, .trigger=true);
		}
	}
}

@ThrowHeGrenade_Post(const id, const Float:vecStart[3], const Float:vecVelocity[3]) {
	new iEnt = GetHookChainReturn(ATYPE_INTEGER);

	if(is_nullent(iEnt)) {
		return;
	}

	if(g_CurrentGameMode == MODE_GUNGAME || g_CurrentGameMode == MODE_MEGA_GUNGAME || g_CurrentGameMode == MODE_DUEL_FINAL) {
		return;
	}

	new Float:vecColor[3];

	switch(g_Class[id]) {
		case CLASS_HUMAN: {
			if(g_KillBomb[id]) {
				vecColor[0] = 255.0;
				vecColor[1] = 0.0;
				vecColor[2] = 0.0;

				--g_KillBomb[id];
			} else if(g_DrugBomb[id]) {
				vecColor[0] = 255.0;
				vecColor[1] = 0.0;
				vecColor[2] = 0.0;

				--g_DrugBomb[id];
			} else {
				vecColor[0] = 255.0;
				vecColor[1] = 0.0;
				vecColor[2] = 0.0;
			}
		} case CLASS_ZOMBIE: {
			vecColor[0] = 0.0;
			vecColor[1] = 255.0;
			vecColor[2] = 0.0;
		}
	}

	utilSetRendering(iEnt, kRenderFxGlowShell, vecColor, kRenderNormal, 16.0);

	message_begin_f(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iEnt);
	write_short(g_ModelIndex_LaserBeam);
	write_byte(10);
	write_byte(10);
	write_byte(floatround(vecColor[0]));
	write_byte(floatround(vecColor[1]));
	write_byte(floatround(vecColor[2]));
	write_byte(255);
	message_end();
}

@ThrowFlashbang_Post(const id, const Float:vecStart[3], const Float:vecVelocity[3]) {
	new iEnt = GetHookChainReturn(ATYPE_INTEGER);

	if(is_nullent(iEnt)) {
		return;
	}

	new Float:vecColor[3];

	switch(g_Class[id]) {
		case CLASS_HUMAN: {
			if(g_PipeBomb[id]) {
				vecColor[0] = 255.0;
				vecColor[1] = 0.0;
				vecColor[2] = 255.0;

				--g_PipeBomb[id];
			} else if(g_SupernovaBomb[id]) {
				vecColor[0] = 0.0;
				vecColor[1] = 255.0;
				vecColor[2] = 255.0;

				--g_SupernovaBomb[id];
			} else {
				vecColor[0] = 0.0;
				vecColor[1] = 0.0;
				vecColor[2] = 255.0;
			}
		}
	}

	utilSetRendering(iEnt, kRenderFxGlowShell, vecColor, kRenderNormal, 16.0);

	message_begin_f(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iEnt);
	write_short(g_ModelIndex_LaserBeam);
	write_byte(10);
	write_byte(10);
	write_byte(floatround(vecColor[0]));
	write_byte(floatround(vecColor[1]));
	write_byte(floatround(vecColor[2]));
	write_byte(255);
	message_end();
}

@ThrowSmokeGrenade_Post(const id, const Float:vecStart[3], const Float:vecVelocity[3]) {
	new iEnt = GetHookChainReturn(ATYPE_INTEGER);

	if(is_nullent(iEnt)) {
		return;
	}

	new Float:vecColor[3];

	switch(g_Class[id]) {
		case CLASS_HUMAN: {
			if(g_AntidoteBomb[id]) {
				vecColor[0] = 255.0;
				vecColor[1] = 255.0;
				vecColor[2] = 0.0;

				--g_AntidoteBomb[id];
			} else {
				vecColor[0] = float(g_UserOption_Color[id][COLOR_TYPE_FLARE][0]);
				vecColor[1] = float(g_UserOption_Color[id][COLOR_TYPE_FLARE][1]);
				vecColor[2] = float(g_UserOption_Color[id][COLOR_TYPE_FLARE][2]);

				if(g_BubbleBomb[id]) {
					--g_BubbleBomb[id];
				}

				set_entvar(iEnt, var_punchangle, vecColor);
			}
		}
	}

	utilSetRendering(iEnt, kRenderFxGlowShell, vecColor, kRenderNormal, 16.0);

	message_begin_f(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iEnt);
	write_short(g_ModelIndex_LaserBeam);
	write_byte(10);
	write_byte(10);
	write_byte(floatround(vecColor[0]));
	write_byte(floatround(vecColor[1]));
	write_byte(floatround(vecColor[2]));
	write_byte(255);
	message_end();
}

@CBasePlayerWeapon_DefaultDeploy_Pre(const ent, const view_odel[], const weapon_model[], const anim, const anim_ext[], const skip_local) {
	new WeaponIdType:iWeaponId = get_member(ent, m_iId);
	new iId = get_member(ent, m_pPlayer);

	switch(iWeaponId) {
		case WEAPON_KNIFE: {

		} case WEAPON_HEGRENADE: {
			switch(g_Class[iId]) {
				case CLASS_HUMAN: {
					if(g_KillBomb[iId]) {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_KILL_VIEW);
					} else if(g_DrugBomb[iId]) {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_DRUG_VIEW);
						SetHookChainArg(3, ATYPE_STRING, __MODEL_GRENADE_DRUG_PLAYER);
					} else {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_FIRE_VIEW);
					}
				} case CLASS_ZOMBIE: {
					SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_INFECTION_VIEW);
					SetHookChainArg(3, ATYPE_STRING, __MODEL_GRENADE_INFECTION_PLAYER);
				}
			}
		} case WEAPON_FLASHBANG: {
			switch(g_Class[iId]) {
				case CLASS_HUMAN: {
					if(g_PipeBomb[iId]) {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_PIPE_VIEW);
					} else if(g_SupernovaBomb[iId]) {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_SUPERNOVA_VIEW);
						SetHookChainArg(3, ATYPE_STRING, __MODEL_GRENADE_SUPERNOVA_PLAYER);
					} else {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_FROST_VIEW);
					}
				}
			}
		} case WEAPON_SMOKEGRENADE: {
			switch(g_Class[iId]) {
				case CLASS_HUMAN: {
					if(g_AntidoteBomb[iId]) {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_ANTIDOTE_VIEW);
					} else if(g_BubbleBomb[iId]) {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_BUBBLE_VIEW);
						SetHookChainArg(3, ATYPE_STRING, __MODEL_GRENADE_BUBBLE_PLAYER);
					} else {
						SetHookChainArg(2, ATYPE_STRING, __MODEL_GRENADE_FLARE_VIEW);
					}
				}
			}
		}
	}
}

@CGrenade_ExplodeHeGrenade_Pre(const ent, const trace_handle, const bits_damage_type) {
	new iOwner = get_entvar(ent, var_owner);
	new Float:vecOrigin[3];
	new i;
	new Float:vecOrigin2[3];

	switch(g_Class[iOwner]) {
		case CLASS_HUMAN: {
			if(is_nullent(iOwner)) {
				return HC_CONTINUE;
			}

			get_entvar(ent, var_origin, vecOrigin);

			if(g_KillBomb[iOwner]) {
				message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
				write_byte(TE_BEAMCYLINDER);
				write_coord_f(vecOrigin[0]);
				write_coord_f(vecOrigin[1]);
				write_coord_f(vecOrigin[2]);
				write_coord_f(vecOrigin[0]);
				write_coord_f(vecOrigin[1]);
				write_coord_f((vecOrigin[2] + 555.0));
				write_short(g_ModelIndex_ShockWave);
				write_byte(0);
				write_byte(0);
				write_byte(4);
				write_byte(60);
				write_byte(0);
				write_byte(200);
				write_byte(100);
				write_byte(0);
				write_byte(255);
				write_byte(0);
				message_end();

				rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_GRENADE_FIRE_EXPLODE, VOL_NORM, ATTN_NORM);

				for(i = 1; i <= MaxClients; ++i) {
					if(!is_user_alive(i)) {
						continue;
					}

					get_entvar(i, var_origin, vecOrigin2);

					if(vector_distance(vecOrigin, vecOrigin2) > 240.0) {
						continue;
					}

					if(!ExecuteHamB(Ham_FVisible, i, ent)) {
						continue;
					}

					if(getUserTeam(i) != TEAM_TERRORIST) {
						continue;
					}


				}
			} else if(g_DrugBomb[iOwner]) {
				message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
				write_byte(TE_BEAMCYLINDER);
				write_coord_f(vecOrigin[0]);
				write_coord_f(vecOrigin[1]);
				write_coord_f(vecOrigin[2]);
				write_coord_f(vecOrigin[0]);
				write_coord_f(vecOrigin[1]);
				write_coord_f((vecOrigin[2] + 555.0));
				write_short(g_ModelIndex_ShockWave);
				write_byte(0);
				write_byte(0);
				write_byte(4);
				write_byte(60);
				write_byte(0);
				write_byte(255);
				write_byte(255);
				write_byte(0);
				write_byte(255);
				write_byte(0);
				message_end();

				rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_GRENADE_FIRE_EXPLODE, VOL_NORM, ATTN_NORM);

				for(i = 1; i <= MaxClients; ++i) {
					if(!is_user_alive(i)) {
						continue;
					}

					get_entvar(i, var_origin, vecOrigin2);

					if(vector_distance(vecOrigin, vecOrigin2) > 240.0) {
						continue;
					}

					if(!ExecuteHamB(Ham_FVisible, i, ent)) {
						continue;
					}

					if(getUserTeam(i) != TEAM_TERRORIST) {
						continue;
					}


				}
			} else {
				message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
				write_byte(TE_BEAMCYLINDER);
				write_coord_f(vecOrigin[0]);
				write_coord_f(vecOrigin[1]);
				write_coord_f(vecOrigin[2]);
				write_coord_f(vecOrigin[0]);
				write_coord_f(vecOrigin[1]);
				write_coord_f((vecOrigin[2] + 555.0));
				write_short(g_ModelIndex_ShockWave);
				write_byte(0);
				write_byte(0);
				write_byte(4);
				write_byte(60);
				write_byte(0);
				write_byte(255);
				write_byte(0);
				write_byte(0);
				write_byte(255);
				write_byte(0);
				message_end();

				rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_GRENADE_FIRE_EXPLODE, VOL_NORM, ATTN_NORM);

				for(i = 1; i <= MaxClients; ++i) {
					if(!is_user_alive(i)) {
						continue;
					}

					get_entvar(i, var_origin, vecOrigin2);

					if(vector_distance(vecOrigin, vecOrigin2) > 240.0) {
						continue;
					}

					if(!ExecuteHamB(Ham_FVisible, i, ent)) {
						continue;
					}

					if(getUserTeam(i) != TEAM_TERRORIST) {
						continue;
					}

					ignitePlayer(i, iOwner);
				}
			}
		} case CLASS_ZOMBIE: {
			get_entvar(ent, var_origin, vecOrigin);

			message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
			write_byte(TE_BEAMCYLINDER);
			write_coord_f(vecOrigin[0]);
			write_coord_f(vecOrigin[1]);
			write_coord_f(vecOrigin[2]);
			write_coord_f(vecOrigin[0]);
			write_coord_f(vecOrigin[1]);
			write_coord_f((vecOrigin[2] + 555.0));
			write_short(g_ModelIndex_ShockWave);
			write_byte(0);
			write_byte(0);
			write_byte(4);
			write_byte(60);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			write_byte(0);
			write_byte(255);
			write_byte(0);
			message_end();

			rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_GRENADE_INFECTION_EXPLODE, VOL_NORM, ATTN_NORM);

			if(!is_user_connected(iOwner) && g_Class[iOwner] != CLASS_ZOMBIE) {
				iOwner = 0;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!is_user_alive(i)) {
					continue;
				}

				get_entvar(i, var_origin, vecOrigin2);

				if(vector_distance(vecOrigin, vecOrigin2) > 240.0) {
					continue;
				}

				if(!ExecuteHamB(Ham_FVisible, i, ent)) {
					continue;
				}

				if(g_Class[i] != CLASS_HUMAN) {
					continue;
				}

				changeClass(i, iOwner, CLASS_ZOMBIE, false);
			}
		}
	}
	
	set_entvar(ent, var_flags, FL_KILLME);
	return HC_SUPERCEDE;
}

ignitePlayer(const victim, const attacker) {
	new iEntFlame = g_EntFlame[victim];

	if(is_nullent(iEntFlame)) {
		iEntFlame = flameCreate(victim, attacker);
	} else {
		flameDestroy(victim);

		iEntFlame = flameCreate(victim, attacker);
	}

	g_EntFlame[victim] = iEntFlame;

	rg_reset_maxspeed(victim);
}

flameCreate(const owner, const attacker) {
	new iEntSprite = rg_create_entity("env_sprite");

	if(is_nullent(iEntSprite)) {
		return 0;
	}

	new Float:flGameTime = get_gametime();

	set_entvar(iEntSprite, var_classname, __ENT_CLASSNAME_FLAME);
	set_entvar(iEntSprite, var_owner, owner);
	set_entvar(iEntSprite, var_aiment, owner);
	set_entvar(iEntSprite, var_enemy, attacker);
	set_entvar(iEntSprite, var_movetype, MOVETYPE_FOLLOW);
	set_entvar(iEntSprite, var_nextthink, (flGameTime + 0.1));
	set_entvar(iEntSprite, var_dmgtime, (flGameTime + 5.0));

	set_entvar(iEntSprite, var_framerate, 1.0);
	set_entvar(iEntSprite, var_scale, 0.5);
	set_entvar(iEntSprite, var_rendermode, kRenderTransAdd);
	set_entvar(iEntSprite, var_renderamt, 255.0);

	engfunc(EngFunc_SetModel, iEntSprite, __SPRITE_FLAME);

	set_ent_data_float(iEntSprite, "CSprite", "m_lastTime", flGameTime);
	set_ent_data_float(iEntSprite, "CSprite", "m_maxFrame", float(engfunc(EngFunc_ModelFrames, g_ModelIndex_Flame) - 1));

	SetThink(iEntSprite, "@think__Flame");
	return iEntSprite;
}

flameDestroy(const owner) {
	new iEntFlame = g_EntFlame[owner];

	g_EntFlame[owner] = 0;

	if(is_nullent(iEntFlame)) {
		return;
	}

	new Float:vecOrigin[3];
	get_entvar(owner, var_origin, vecOrigin);

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_SMOKE);
	write_coord_f(vecOrigin[0]);
	write_coord_f(vecOrigin[1]);
	write_coord_f((vecOrigin[2] - 50.0));
	write_short(g_ModelIndex_BlackSmoke3);
	write_byte(random_num(15, 20));
	write_byte(random_num(10, 20));
	message_end();

	set_entvar(iEntFlame, var_flags, FL_KILLME);
}

@think__Flame(const ent) {
	new iOwner = get_entvar(ent, var_owner);
	new Float:flGameTime = get_gametime();

	if((!is_nullent(iOwner) && get_entvar(iOwner, var_flags) & FL_INWATER) || Float:get_entvar(ent, var_dmgtime) <= flGameTime) {
		flameDestroy(iOwner);

		if(is_user_alive(iOwner)) {
			rg_reset_maxspeed(iOwner);
		}

		return;
	}

	if(Float:get_entvar(ent, var_pain_finished) <= flGameTime) {
		set_entvar(ent, var_pain_finished, (flGameTime + 0.2));

		if(random_num(1, 20) == 1) {
			rh_emit_sound2(iOwner, 0, CHAN_VOICE, __SOUND_GRENADE_FIRE_ZOMBIE_BURNING[random_num(0, sizeof(__SOUND_GRENADE_FIRE_ZOMBIE_BURNING) - 1)], VOL_NORM, ATTN_NORM);
		}

		new Float:flHealth = get_entvar(iOwner, var_health);
		new Float:flDamage = ((get_entvar(iOwner, var_max_health) * 0.24) / 100);

		set_entvar(ent, var_health, floatmax((flHealth - flDamage), 1.0));
	}

	new Float:flFrame = Float:get_entvar(ent, var_frame);

	++flFrame;

	if(flFrame > get_ent_data_float(ent, "CSprite", "m_maxFrame")) {
		flFrame = 0.0;
	}

	set_entvar(ent, var_frame, flFrame);
	set_entvar(ent, var_nextthink, (flGameTime + 0.1));

	set_ent_data_float(ent, "CSprite", "m_lastTime", flGameTime);
}

@CGrenade_ExplodeFlashbang_Pre(const ent, const trace_handle, const bits_damage_type) {
	new iOwner = get_entvar(ent, var_owner);

	if(is_nullent(iOwner)) {
		set_entvar(ent, var_flags, FL_KILLME);
		return HC_SUPERCEDE;
	}

	if(g_Class[iOwner] != CLASS_HUMAN) {
		set_entvar(ent, var_flags, FL_KILLME);
		return HC_SUPERCEDE;
	}

	new Float:vecOrigin[3];
	new i;
	new Float:vecOrigin2[3];

	get_entvar(ent, var_origin, vecOrigin);

	if(g_PipeBomb[iOwner]) {

	} else if(g_SupernovaBomb[iOwner]) {

	} else {
		message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_BEAMCYLINDER);
		write_coord_f(vecOrigin[0]);
		write_coord_f(vecOrigin[1]);
		write_coord_f(vecOrigin[2]);
		write_coord_f(vecOrigin[0]);
		write_coord_f(vecOrigin[1]);
		write_coord_f((vecOrigin[2] + 555.0));
		write_short(g_ModelIndex_ShockWave);
		write_byte(0);
		write_byte(0);
		write_byte(4);
		write_byte(60);
		write_byte(9);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		write_byte(255);
		write_byte(0);
		message_end();

		rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_GRENADE_FROST_EXPLODE, VOL_NORM, ATTN_NORM);

		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			get_entvar(i, var_origin, vecOrigin2);

			if(vector_distance(vecOrigin, vecOrigin2) > 240.0) {
				continue;
			}

			if(!ExecuteHamB(Ham_FVisible, i, ent)) {
				continue;
			}

			if(getUserTeam(i) != TEAM_TERRORIST) {
				continue;
			}

			freezePlayer(i);
		}
	}

	set_entvar(ent, var_flags, FL_KILLME);
	return HC_SUPERCEDE;
}

freezePlayer(const id) {
	new iEnt = g_EntIceCube[id];

	if(is_nullent(iEnt)) {
		iEnt = iceCubeCreate(id);
	} else {
		iceCubeDestroy(id);

		iEnt = iceCubeCreate(id);
	}

	g_EntIceCube[id] = iEnt;

	set_member(id, m_bCanShoot, false);

	rg_reset_maxspeed(id);

	rh_emit_sound2(id, 0, CHAN_BODY, __SOUND_GRENADE_FROST_FREEZE, VOL_NORM, ATTN_NORM);
}

iceCubeCreate(const owner) {
	new iEnt = rg_create_entity("info_target");

	if(is_nullent(iEnt)) {
		return 0;
	}

	new Float:flGameTime = get_gametime();

	set_entvar(iEnt, var_classname, __ENT_CLASSNAME_ICECUBE);
	set_entvar(iEnt, var_owner, owner);
	// set_entvar(iEnt, var_aiment, owner);
	// set_entvar(iEnt, var_movetype, MOVETYPE_FOLLOW);
	set_entvar(iEnt, var_nextthink, (flGameTime + 5.0));
	set_entvar(iEnt, var_effects, EF_NODRAW);

	engfunc(EngFunc_SetModel, iEnt, __MODEL_ICECUBE);

	utilSetRendering(owner, kRenderFxGlowShell, Float:{0.0, 0.0, 255.0}, kRenderNormal, 16.0);

	SetThink(iEnt, "@think__IceCube");
	return iEnt;
}

iceCubeDestroy(const owner) {
	new iId = g_EntIceCube[owner];

	g_EntIceCube[owner] = 0;

	if(is_nullent(iId)) {
		return;
	}

	new Float:vecOrigin[3];
	get_entvar(owner, var_origin, vecOrigin);

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_BREAKMODEL);
	write_coord_f(vecOrigin[0]);
	write_coord_f(vecOrigin[1]);
	write_coord_f((vecOrigin[2] + 24.0));
	write_coord_f(16.0);
	write_coord_f(16.0);
	write_coord_f(16.0);
	write_coord_f(random_float(-50.0, 50.0));
	write_coord_f(random_float(-50.0, 50.0));
	write_coord_f(25.0);
	write_byte(10);
	write_short(g_ModelIndex_GlassGibs);
	write_byte(10);
	write_byte(25);
	write_byte(BREAK_GLASS);
	message_end();

	rh_emit_sound2(iId, 0, CHAN_BODY, __SOUND_GRENADE_FROST_BREAK, VOL_NORM, ATTN_NORM);

	set_entvar(iId, var_flags, FL_KILLME);
}

@think__IceCube(const id) {
	new iOwner = get_entvar(id, var_owner);

	iceCubeDestroy(iOwner);

	if(is_user_alive(iOwner)) {
		set_member(iOwner, m_bCanShoot, true);

		rg_reset_maxspeed(iOwner);

		utilSetRendering(iOwner);
	}
}

@CGrenade_ExplodeSmokeGrenade_Pre(const ent) {
	new iOwner = get_entvar(ent, var_owner);

	if(g_Class[iOwner] != CLASS_HUMAN) {
		set_entvar(ent, var_flags, FL_KILLME);
		return HC_SUPERCEDE;
	}

	if(g_AntidoteBomb[iOwner]) {
		if(!is_user_connected(iOwner)) {
			iOwner = 0;
		}

		new Float:vecOriginEnt[3];
		new i;
		new Float:vecOriginI[3];

		get_entvar(ent, var_origin, vecOriginEnt);

		message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOriginEnt);
		write_byte(TE_BEAMCYLINDER);
		write_coord_f(vecOriginEnt[0]);
		write_coord_f(vecOriginEnt[1]);
		write_coord_f(vecOriginEnt[2]);
		write_coord_f(vecOriginEnt[0]);
		write_coord_f(vecOriginEnt[1]);
		write_coord_f((vecOriginEnt[2] + 555.0));
		write_short(g_ModelIndex_ShockWave);
		write_byte(0);
		write_byte(0);
		write_byte(4);
		write_byte(60);
		write_byte(0);
		write_byte(255);
		write_byte(255);
		write_byte(0);
		write_byte(255);
		write_byte(0);
		message_end();

		rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_HUMAN_ANTIDOTE, VOL_NORM, ATTN_NORM);

		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			get_entvar(i, var_origin, vecOriginI);

			if(vector_distance(vecOriginEnt, vecOriginI) > 240.0) {
				continue;
			}

			if(!ExecuteHamB(Ham_FVisible, i, ent)) {
				continue;
			}

			if(g_Class[i] != CLASS_ZOMBIE) {
				continue;
			}

			changeClass(i, iOwner, CLASS_HUMAN, false);
		}
	} else if(g_BubbleBomb[iOwner]) { // COMPLETAR
		if(is_nullent(iOwner)) {
			set_entvar(ent, var_flags, FL_KILLME);
			return HC_SUPERCEDE;
		}

		new iDuration = 60;

		if(g_Hab[iOwner][HAB_E_DURATION_FLARE_BUBBLE]) {
			iDuration += (__HABS[HAB_E_DURATION_FLARE_BUBBLE][habValue] * g_Hab[iOwner][HAB_E_DURATION_FLARE_BUBBLE]);
		}

		rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_GRENADE_BUBBLE_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);

		set_entvar(ent, var_nextthink, (get_gametime() + 0.1));
		set_member(ent, m_Grenade_SGSmoke, (iDuration / 4));
		

		return HC_SUPERCEDE;
	} else {
		if(is_nullent(iOwner)) {
			set_entvar(ent, var_flags, FL_KILLME);
			return HC_SUPERCEDE;
		}

		new iDuration = 60;

		if(g_Hab[iOwner][HAB_E_DURATION_FLARE_BUBBLE]) {
			iDuration += (__HABS[HAB_E_DURATION_FLARE_BUBBLE][habValue] * g_Hab[iOwner][HAB_E_DURATION_FLARE_BUBBLE]);
		}

		rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_GRENADE_FLARE_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);

		set_entvar(ent, var_nextthink, (get_gametime() + 0.1));
		set_member(ent, m_Grenade_SGSmoke, (iDuration / 2));

		SetThink(ent, "@think__Flare");
		return HC_SUPERCEDE;
	}

	set_entvar(ent, var_flags, FL_KILLME);
	return HC_SUPERCEDE;
}

@think__Flare(const ent) {
	new iDuration = get_member(ent, m_Grenade_SGSmoke);

	if(iDuration < 0) {
		set_entvar(ent, var_flags, FL_KILLME);
		return;
	}

	new Float:vecOrigin[3];
	new Float:vecColor[3];
	new iColor[3];

	get_entvar(ent, var_origin, vecOrigin);
	get_entvar(ent, var_punchangle, vecColor);

	FVecIVec(vecColor, iColor);

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_DLIGHT);
	write_coord_f(vecOrigin[0]);
	write_coord_f(vecOrigin[1]);
	write_coord_f(vecOrigin[2]);
	write_byte(25);
	write_byte(iColor[0]);
	write_byte(iColor[1]);
	write_byte(iColor[2]);
	write_byte(21);
	write_byte(((iDuration < 1) ? 3 : 0));
	message_end();

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_SPARKS);
	write_coord_f(vecOrigin[0]);
	write_coord_f(vecOrigin[1]);
	write_coord_f(vecOrigin[2]);
	message_end();

	set_member(ent, m_Grenade_SGSmoke, --iDuration);
	set_entvar(ent, var_nextthink, (get_gametime() + 2.0));
}

@CWeaponBox_SetModel_Pre(const id, const model[]) {
	// new iItem;
	// new iImpulse;
	// new iIndex;

	// for(new InventorySlotType:i = PRIMARY_WEAPON_SLOT; i <= C4_SLOT; i++) {
		// iItem = get_member(id, m_WeaponBox_rgpPlayerItems, i);

		// if(is_nullent(iItem)) {
			// continue;
		// }

		// iImpulse = get_entvar(iItem, var_impulse);

		// if(!iImpulse) {
			// continue;
		// }

		// iIndex = zp_module_get_valid_index(g_Module, iImpulse);

		// if(iIndex == -1) {
			// break;
		// }

		// new aData[structWeaponData];
		// ArrayGetArray(g_aWeapons, iIndex, aData);

		// if(aData[weapon__WorldModel][0]) {
			// SetHookChainArg(2, ATYPE_STRING, aData[weapon__WorldModel]);
		// }

		// break;
	// }
}

@clcmd__Say(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(g_CurrentGameMode == MODE_GRUNT) {
		if(!is_user_alive(id)) {
			clientPrintColor(id, _, "No puedes utilizar el chat estando muerto en modo !tGRUNT!y.");
			return PLUGIN_HANDLED;
		}
	}

	static sMessage[192];
	read_args(sMessage, charsmax(sMessage));

	replace_all(sMessage, charsmax(sMessage), "#", "");
	replace_all(sMessage, charsmax(sMessage), "%", "");
	replace_all(sMessage, charsmax(sMessage), "!y", ""); 
	replace_all(sMessage, charsmax(sMessage), "!t", "");
	replace_all(sMessage, charsmax(sMessage), "!g", "");

	remove_quotes(sMessage);
	trim(sMessage);

	sMessage[191] = EOS;

	if(equal(sMessage, " ") || equal(sMessage, "") || sMessage[0] == '/' || sMessage[0] == '@' || sMessage[0] == '!') {
		return PLUGIN_HANDLED;
	}

	static iGreen;
	static i;
	static iLevelTotal;
	static sLevelTotal[16];

	iGreen = ((get_user_flags(id) & ADMIN_RESERVATION) ? 1 : 0);

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_connected(i) && !dg_get_user_mute(i, id)) {
			if(dg_get_user_acc_status(id) == STATUS_PLAYING) {
				iLevelTotal = getUserLevelTotal(id);
				addDot(iLevelTotal, sLevelTotal, charsmax(sLevelTotal));

				if(g_UserOption_LevelTotal[id]) {
					client_print_color(i, id, "%s%s^3%n ^4(N: %s)^1 :%s %s", ((is_user_alive(id)) ? "" : "^1(MUERTO) "), getUserTypeMod(id), id, sLevelTotal, ((iGreen) ? "^4" : "^1"), sMessage);
				} else {
					client_print_color(i, id, "%s%s^3%n ^4(%s)^1 :%s %s", ((is_user_alive(id)) ? "" : "^1(MUERTO) "), getUserTypeMod(id), id, getLevelTotalRequired(iLevelTotal), ((iGreen) ? "^4" : "^1"), sMessage);
				}
			} else {
				client_print_color(i, id, "^1(%s)^3 %n^1 :%s %s", getAccountStatus(id), id, ((iGreen) ? "^4" : "^1"), sMessage);
			}
		}
	}

	// if(g_LogSay) {
		// dg_log_to_file(LOG_SERVER, 1, 1, "clcmd__Say() ~~ %s [%c](%d) : %s ~~ [HP=%d][XP=%d]", g_PlayerName[id], getUserRange(g_Reset[id]), g_Level[id], sMessage, g_Health[id], g_Exp[id]);
	// }

	return PLUGIN_HANDLED;
}

getUserTypeMod(const id) {
	new sBuffer[32];
	sBuffer[0] = EOS;

	if((get_user_flags(id) & ADMIN_RCON)) {
		formatex(sBuffer, charsmax(sBuffer), "^4<DIRECTOR> ");
	} else if((get_user_flags(id) & ADMIN_LEVEL_E)) {
		formatex(sBuffer, charsmax(sBuffer), "^4<STAFF> ");
	} else if((get_user_flags(id) & ADMIN_LEVEL_D)) {
		formatex(sBuffer, charsmax(sBuffer), "^4<CAPITÁN> ");
	} else if((get_user_flags(id) & ADMIN_IMMUNITY)) {
		formatex(sBuffer, charsmax(sBuffer), "^4<ADMIN CS> ");
	} else if((get_user_flags(id) & ADMIN_RESERVATION)) {
		formatex(sBuffer, charsmax(sBuffer), "^4<VIP> ");
	}

	return sBuffer;
}

getAccountStatus(const id) {
	new sStatus[16];
	sStatus[0] = EOS;

	if(dg_get_user_acc_status(id) == STATUS_BANNED) {
		formatex(sStatus, charsmax(sStatus), "BANEADO");
	} else if(dg_get_user_acc_status(id) == STATUS_CHECK_ACCOUNT || dg_get_user_acc_status(id) == STATUS_UNREGISTERED) {
		formatex(sStatus, charsmax(sStatus), "SIN REGISTRARSE");
	} else if(dg_get_user_acc_status(id) == STATUS_CONFIRM || dg_get_user_acc_status(id) == STATUS_LOADING) {
		formatex(sStatus, charsmax(sStatus), "CARGANDO . . .");
	} else if(dg_get_user_acc_status(id) == STATUS_REGISTERED) {
		formatex(sStatus, charsmax(sStatus), "SIN IDENTIFICARSE");
	} else if(dg_get_user_acc_status(id) == STATUS_LOGGED) {
		formatex(sStatus, charsmax(sStatus), "ESPECTADOR");
	}

	return sStatus;
}

@clcmd__SayTeam(const id) {
	if(g_CurrentGameMode == MODE_GRUNT) {
		clientPrintColor(id, _, "Este chat está bloqueado en modo !tGRUNT!y.");
		return PLUGIN_HANDLED;
	}

	if(!g_ClanSlot[id]) {
		return PLUGIN_HANDLED;
	}

	/*static sMessage[191];
	read_args(sMessage, charsmax(sMessage));

	replace_all(sMessage, charsmax(sMessage), "#", "");
	replace_all(sMessage, charsmax(sMessage), "%", "");
	replace_all(sMessage, charsmax(sMessage), "!y", ""); 
	replace_all(sMessage, charsmax(sMessage), "!t", "");
	replace_all(sMessage, charsmax(sMessage), "!g", "");

	if(equal(sMessage, "") || sMessage[0] == '/' || sMessage[0] == '@' || sMessage[0] == '!')
		return PLUGIN_HANDLED;

	remove_quotes(sMessage);
	trim(sMessage);

	static iGreen;
	static iTeam;
	static i;

	iGreen = ((get_user_flags(id) & ADMIN_LEVEL_A) ? 1 : 0);
	iTeam = getUserTeam(id);

	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i] && !dg_get_user_mute(i, id))
		{
			if((get_user_flags(i) & ADMIN_LEVEL_C) && g_UserOption_ClanChat[i])
			{
				if(g_ClanSlot[id] == g_ClanSlot[i])
					colorChat(i, ((iTeam == F_TEAM_T) ? TERRORIST : CT), "%s!g[%s] !t%s!y :%s %s", ((g_IsAlive[id]) ? "" : "!y(MUERTO) "), g_Clan[g_ClanSlot[id]][clanName], g_PlayerName[id], ((iGreen) ? "!g" : "!y"), sMessage);
				else
					colorChat(i, ((iTeam == F_TEAM_T) ? TERRORIST : CT), "!y[%d] - %s!g[%s] !t%s!y :%s %s", g_ClanSlot[id], ((g_IsAlive[id]) ? "" : "(MUERTO) "), g_Clan[g_ClanSlot[id]][clanName], g_PlayerName[id], ((iGreen) ? "!g" : "!y"), sMessage);
			}

			if(g_ClanSlot[id] == g_ClanSlot[i] && !(get_user_flags(i) & ADMIN_LEVEL_C))
				colorChat(i, ((iTeam == F_TEAM_T) ? TERRORIST : CT), "%s!g[%s] !t%s!y :%s %s", ((g_IsAlive[id]) ? "" : "!y(MUERTO) "), g_Clan[g_ClanSlot[id]][clanName], g_PlayerName[id], ((iGreen) ? "!g" : "!y"), sMessage);
		}
	}

	if(g_LogSay)
		dg_log_to_file(LOG_SERVER, 1, 1, "clcmd__SayTeam() ~~ %s [%c](%d) : %s ~~ [HP=%d][XP=%d]", g_PlayerName[id], getUserRange(g_Reset[id]), g_Level[id], sMessage, g_Health[id], g_Exp[id]);*/

	return PLUGIN_HANDLED;
}

showMenu__Clan(const id) {
	oldmenu_create("\yCLAN", "@menu__Clan");

	if(g_ClanSlot[id]) {
		oldmenu_additem(-1, -1, "\wNombre del clan\r:\y %s", g_Clan[g_ClanSlot[id]][clanName]);
		oldmenu_additem(-1, -1, "\wRanking del clan\r:\y %d", g_Clan[g_ClanSlot[id]][clanRank]);
		oldmenu_additem(-1, -1, "\wDepósito\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanDeposit]);

		if(g_Clan[g_ClanSlot[id]][clanChampion]) {
			oldmenu_additem(-1, -1, "\wTu clan es el \yACTUAL\w campeón semanal^n");
		}

		oldmenu_additem(1, 1, "\r1.\w Ver miembros conectados \y(%d / %d)", g_Clan[g_ClanSlot[id]][clanCountOnlineMembers], g_Clan[g_ClanSlot[id]][clanCountMembers]);
		
		if(getClanMemberRange(id)) {
			oldmenu_additem(2, 2, "\r2.\w Invitar usuarios^n");
		} else {
			oldmenu_additem(2, 2, "\d2. Invitar usuarios^n");
		}

		oldmenu_additem(3, 3, "\r3.\w Ventajas del Clan^n");

		oldmenu_additem(4, 4, "\r4.\w Información del Clan^n");
	} else {
		oldmenu_additem(1, 1, "\r1.\w Crear Clan");
		oldmenu_additem(2, 2, "\r2.\w Invitaciones a Clanes\r:\y %d^n", g_ClanInvitations[id]);
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__Clan(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_ClanSlot[id]) {
				showMenu__ClanOnlineMembers(id);
			} else {
				clientPrintColor(id, _, "Escribe el nombre de tu clan, se aceptan hasta 14 caracteres.");
				client_cmd(id, "messagemode CREAR_CLAN");
			}
		} case 2: {
			if(g_ClanSlot[id]) {
				if(getClanMemberRange(id)) {
					showMenu__ClanInviteUsers(id);
				} else {
					clientPrintColor(id, _, "Solo los miembros con rango !gDUEÑO!y del Clan pueden invitar usuarios.");
					showMenu__Clan(id);
				}
			} else if(g_ClanInvitations[id]) {
				showMenu__ClanInvitations(id);
			} else {
				showMenu__Clan(id);
			}
		} case 3: {
			if(g_ClanSlot[id]) {
				showMenu__ClanPerks(id);
			} else {
				showMenu__Clan(id);
			}
		} case 4: {
			if(g_ClanSlot[id]) {
				showMenu__ClanInfo(id);
			} else {
				showMenu__Clan(id);
			}
		}
	}
}

showMenu__ClanInviteUsers(const id) {
	new iMenuId;
	new i;
	new iLevelTotal;
	new sLevelTotal[16];
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("INVITAR USUARIOS AL CLAN\R", "@menu__ClanInviteUsers");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		if(id == i) {
			continue;
		}

		if(g_ClanSlot[i]) {
			continue;
		}

		if(g_ClanInvitationsId[i][id]) {
			continue;
		}

		iLevelTotal = getUserLevelTotal(i);

		if(g_UserOption_LevelTotal[id]) {
			addDot(iLevelTotal, sLevelTotal, charsmax(sLevelTotal));
			formatex(sItem, charsmax(sItem), "%n \y(N: %s)", i, sLevelTotal);
		} else {
			formatex(sItem, charsmax(sItem), "%n \y(%s)", i, getLevelTotalRequired(iLevelTotal));
		}

		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1) {
		DestroyLocalMenu(id, iMenuId);
		
		clientPrintColor(id, _, "No hay usuarios disponibles para mostrar en el menú.");
		
		showMenu__Clan(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	g_MenuPage_ClanInvite[id] = min(g_MenuPage_ClanInvite[id], (menu_pages(iMenuId) - 1));
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

@menu__ClanInviteUsers(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_ClanInvite[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);
	
	iItemId = sPosition[0];
	
	if(is_user_connected(iItemId)) {
		if(!g_ClanSlot[iItemId]) {
			clientPrintColor(id, _, "Enviaste una invitación a !t%n!y para que se una a tu clan.", iItemId);
			clientPrintColor(iItemId, _, "El jugador !t%n!y te invitó al clan !g%s!y.", id, g_Clan[g_ClanSlot[id]][clanName]);
			
			++g_ClanInvitations[iItemId];
			g_ClanInvitationsId[iItemId][id] = 1;
		} else {
			clientPrintColor(id, _, "El jugador seleccionado acaba de entrar en un clan.");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
	}

	showMenu__ClanInviteUsers(id);
	return PLUGIN_HANDLED;
}

showMenu__ClanInfo(const id) {
	oldmenu_create("\yINFORMACIÓN DEL CLAN\r:\w %s", "@menu__ClanInfo", g_Clan[g_ClanSlot[id]][clanName]);

	oldmenu_additem(-1, -1, "\wCreado el\r:\y %s", getUnixToTime(g_Clan[g_ClanSlot[id]][clanSince]));
	oldmenu_additem(-1, -1, "\wHumanos matados\r:\y %d", g_Clan[g_ClanSlot[id]][clanKillHmDone]);
	oldmenu_additem(-1, -1, "\wZombies matados\r:\y %d", g_Clan[g_ClanSlot[id]][clanKillZmDone]);
	oldmenu_additem(-1, -1, "\wInfecciones realizadas\r:\y %d", g_Clan[g_ClanSlot[id]][clanInfectDone]);
	oldmenu_additem(-1, -1, "\wVictorias\r:\y %d", g_Clan[g_ClanSlot[id]][clanVictory]);
	oldmenu_additem(-1, -1, "\wVictorias consecutivas\r:\y %d", g_Clan[g_ClanSlot[id]][clanVictoryConsec]);
	oldmenu_additem(-1, -1, "\wVictorias consecutivas en la historia\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanVictoryConsecHistory]);

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ClanInfo(const id, const item) {
	if(!item) {
		showMenu__Clan(id);
		return;
	}

	showMenu__ClanInfo(id);
}

showMenu__ClanOnlineMembers(const id) {
	new sItem[128];
	new iMenuId;
	new i;
	new j;
	new k;
	new sPosition[2];
	
	formatex(sItem, charsmax(sItem), "VER MIEMBROS CONECTADOS (%d / %d)^n\wAl seleccionar uno, verás la información del jugador\y\R", g_Clan[g_ClanSlot[id]][clanCountMembers], MAX_CLAN_MEMBERS);
	iMenuId = menu_create(sItem, "@menu__ClanOnlineMembers");
	
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(!g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
			continue;
		}

		sPosition[0] = i;
		sPosition[1] = 0;
		k = 0;
		
		for(j = 1; j <= MaxClients; ++j) {
			if(is_user_connected(j)) {
				if(dg_get_user_acc_id(j) == g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
					menu_additem(iMenuId, g_ClanMembers[g_ClanSlot[id]][i][clanMemberName], sPosition);
					
					k = 1;
					break;
				}
			}
		}
		
		if(!k) {
			formatex(sItem, charsmax(sItem), "\d%s", g_ClanMembers[g_ClanSlot[id]][i][clanMemberName]);
			menu_additem(iMenuId, sItem, sPosition);
		}
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

@menu__ClanOnlineMembers(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	new iItemId;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	
	if(g_ClanMembers[g_ClanSlot[id]][iItemId][clanMemberId]) {
		showMenu__ClanMemberInfo(id, iItemId);
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se acaba de ir del clan.");
		showMenu__ClanOnlineMembers(id);
	}
	
	return PLUGIN_HANDLED;
}

showMenu__ClanMemberInfo(const id, const member) {
	if(!g_ClanSlot[id]) {
		return;
	}

	g_MenuData_ClanMemberId[id] = member;

	new sLevelTotal[16];
	new iOk;
	new iMemberRange;

	oldmenu_create("\y%s - %s", "@menu__ClanMemberInfo", g_ClanMembers[g_ClanSlot[id]][member][clanMemberName], ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberOwner]) ? "Dueño" : "Miembro"));

	if(g_UserOption_LevelTotal[id]) {
		addDot(g_ClanMembers[g_ClanSlot[id]][member][clanMemberLevelTotal], sLevelTotal, charsmax(sLevelTotal));
		oldmenu_additem(-1, -1, "\wNivel\r:\y %s", sLevelTotal);
	} else {
		oldmenu_additem(-1, -1, "\wNivel\r:\y %s", getLevelTotalRequired(g_ClanMembers[g_ClanSlot[id]][member][clanMemberLevelTotal]));
	}

	if(g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay] || g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour] || g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeMinute]) {
		oldmenu_additem(-1, -1, "\wÚltima vez visto hace\r:\y %d %s", ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay] : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour] : g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeMinute])), ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? "días" : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? "horas" : "minutos")));
	} else {
		oldmenu_additem(-1, -1, "\wÚltima vez visto hace\r:\y Conectado");
	}

	oldmenu_additem(-1, -1, "\wMiembro desde hace\r:\y %d %s^n", ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay] : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour] : g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceMinute])), ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay]) ? "días" : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour]) ? "horas" : "minutos")));

	iOk = 0;
	iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][member][clanMemberName]);

	if(dg_get_user_acc_id(id) == g_ClanMembers[g_ClanSlot[id]][member][clanMemberId]) {
		iOk = 0;
	} else {
		if(getClanMemberRange(id)) {
			iOk = 1;
		}
	}

	if(iOk && getClanMemberRange(iMemberRange)) {
		oldmenu_additem(3, 3, "\r3.\w Degradar a \yMiembro");
	} else {
		oldmenu_additem(-1, -1, "\d3. Degradar a \rMiembro");
	}

	if(iOk && !getClanMemberRange(iMemberRange)) {
		oldmenu_additem(4, 4, "\r4.\w Promover a \yDueño^n");
	} else {
		oldmenu_additem(-1, -1, "\d4. Promover a \rDueño^n");
	}

	if(iOk) {
		oldmenu_additem(7, 7, "\r7.\w Expulsar miembro");
	} else {
		oldmenu_additem(-1, -1, "\d7. Expulsar miembro");
	}

	if(dg_get_user_acc_id(id) == g_ClanMembers[g_ClanSlot[id]][member][clanMemberId]) {
		oldmenu_additem(8, 8, "\r8.\w Abandonar Clan");
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ClanMemberInfo(const id, const item) {
	if(!item) {
		showMenu__ClanOnlineMembers(id);
		return;
	} else if(!g_ClanSlot[id]) {
		return;
	}

	new iMemberId = g_MenuData_ClanMemberId[id];

	switch(item) {
		case 3: {
			new iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);

			if(getClanMemberRange(id) && getClanMemberRange(iMemberRange) && dg_get_user_acc_id(id) != g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				new Float:flGameTime = get_gametime();

				if(g_ClanQueryFlood[id] > flGameTime) {
					clientPrintColor(id, _, "Espera unos segundos antes de volver a modificar los rangos.");

					showMenu__ClanMemberInfo(id, iMemberId);
					return;
				}

				g_ClanQueryFlood[id] = (flGameTime + 5.0);

				new iArgs[3];
				
				iArgs[0] = id;
				iArgs[1] = 0;
				iArgs[2] = iMemberId;
				
				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `zp9_clans_members` SET `owner`='0' WHERE (`acc_id`='%d' AND `clan_id`='%d' AND `active`='1');", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);
				SQL_ThreadQuery(g_SqlTuple, "@sqlThread__Updates", g_SqlQuery, iArgs, sizeof(iArgs));
			} else {
				showMenu__ClanMemberInfo(id, iMemberId);
			}
		} case 4: {
			new iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);

			if(getClanMemberRange(id) && !getClanMemberRange(iMemberRange) && dg_get_user_acc_id(id) != g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				new Float:flGameTime = get_gametime();

				if(g_ClanQueryFlood[id] > flGameTime) {
					clientPrintColor(id, _, "Espera unos segundos antes de volver a modificar los rangos.");

					showMenu__ClanMemberInfo(id, iMemberId);
					return;
				}

				g_ClanQueryFlood[id] = (flGameTime + 5.0);
				
				new iArgs[3];
				
				iArgs[0] = id;
				iArgs[1] = 1;
				iArgs[2] = iMemberId;
				
				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE `zp9_clans_members` SET `owner`='1' WHERE (`acc_id`='%d' AND `clan_id`='%d' AND `active`='1');", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);
				SQL_ThreadQuery(g_SqlTuple, "@sqlThread__Updates", g_SqlQuery, iArgs, sizeof(iArgs));
			} else {
				showMenu__ClanMemberInfo(id, iMemberId);
			}
		} case 7: {
			if(dg_get_user_acc_id(id) == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				clientPrintColor(id, _, "No puedes expulsarte a ti mismo del clan.");
				showMenu__ClanMemberInfo(id, iMemberId);
			} else if(!getClanMemberRange(id)) {
				clientPrintColor(id, _, "No tienes el rango suficiente como para expulsar miembros del clan.");
				showMenu__ClanMemberInfo(id, iMemberId);
			} else {
				showMenu__ClanRemoveMember(id, iMemberId);
			}
		} case 8: {
			if(dg_get_user_acc_id(id) == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				showMenu__ClanQuit(id);
			} else {
				showMenu__ClanMemberInfo(id, iMemberId);
			}
		}
	}
}

showMenu__ClanRemoveMember(const id, const member) {
	oldmenu_create("\yEXPULSAR MIEMBRO^n\w¿Estás seguro de expulsar a \y%s\w del clan?", "@menu__ClanRemoveMember", g_ClanMembers[g_ClanSlot[id]][member][clanMemberName]);

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

@menu__ClanRemoveMember(const id, const item) {
	if(!g_ClanSlot[id]) {
		return PLUGIN_HANDLED;
	}

	new iMemberId = g_MenuData_ClanMemberId[id];

	switch(item) {
		case 1: {
			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_clans_members` SET `active`='0' WHERE (`acc_id`='%d' AND `clan_id`='%d' AND `active`='1');", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);
			
			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 13);
			} else {
				SQL_FreeHandle(sqlQuery);
				
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_pjs` SET `clan_id`='0' WHERE (`acc_id`='%d');", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);
				
				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 14);
				} else {
					SQL_FreeHandle(sqlQuery);

					--g_Clan[g_ClanSlot[id]][clanCountMembers];

					new i;
					new j = 0;
					
					for(i = 1; i <= MaxClients; ++i) {
						if(!is_user_connected(i)) {
							continue;
						}

						if(g_ClanSlot[id] != g_ClanSlot[i]) {
							continue;
						}

						clientPrintColor(i, _, "!t%s!y ha sido expulsado del clan.", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);
						
						if(id == i) {
							continue;
						}

						if(!j) {
							if(dg_get_user_acc_id(i) == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
								// if(g_Class[i] == CLASS_HUMAN && g_ClanCombo[g_ClanSlot[id]]) {
									// sendClanMessage(id, "Un miembro humano fue expulsado del Clan y el combo ha finalizado.");
									// clanFinishCombo(id);
								// }

								--g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

								g_ClanSlot[i] = 0;
								j = 1;
							}
						}
					}
					
					g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId] = 0;
				}
			}
			
			showMenu__ClanOnlineMembers(id);
		} case 2: {
			showMenu__ClanMemberInfo(id, iMemberId);
		}
	}

	return PLUGIN_HANDLED;
}

showMenu__ClanQuit(const id) {
	oldmenu_create("\yABANDONAR CLAN^n\w¿Estás seguro de abandonar el clan?", "@menu__CLanQuit");

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

@menu__CLanQuit(const id, const item) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new iMemberId = g_MenuData_ClanMemberId[id];

	switch(item) {
		case 1: {
			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_clans_members` SET `active`='0' WHERE (`acc_id`='%d' AND `clan_id`='%d' AND `active`='1');", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 15);
			} else {
				SQL_FreeHandle(sqlQuery);

				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_pjs` SET `clan_id`='0' WHERE (`acc_id`='%d');", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);

				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 16);
				} else {
					SQL_FreeHandle(sqlQuery);

					--g_Clan[g_ClanSlot[id]][clanCountMembers];

					new i;
					for(i = 1; i <= MaxClients; ++i) {
						if(!is_user_connected(i)) {
							continue;
						}

						if(g_ClanSlot[id] != g_ClanSlot[i]) {
							continue;
						}

						if(id == i) {
							clientPrintColor(i, _, "Has abandonado el clan.");
							continue;
						}

						sendClanMessage(id, "!t%s!y ha abandonado el clan.", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);
						break;
					}

					// if(g_Class[id] == CLASS_HUMAN && g_ClanCombo[g_ClanSlot[id]]) {
						// sendClanMessage(id, "Un miembro humano abandonó el clan y el combo ha finalizado.");
						// clanFinishCombo(id);
					// }

					g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId] = 0;

					--g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

					g_ClanSlot[id] = 0;
				}
			}

			showMenu__ClanOnlineMembers(id);
		} case 2: {
			showMenu__ClanMemberInfo(id, iMemberId);
		}
	}
}

showMenu__ClanInvitations(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("INVITACIONES A CLANES^n\wTe enviaron solicitud\r:\R", "@menu__ClanInvitations");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		if(!g_ClanInvitationsId[id][i]) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%n \r-\y %s", i, g_Clan[g_ClanSlot[i]][clanName]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1) {
		DestroyLocalMenu(id, iMenuId);

		clientPrintColor(id, _, "No tenés solicitudes a clanes.");
		
		showMenu__Clan(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

@menu__ClanInvitations(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	new iItemId;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);
	
	iItemId = sPosition[0];
	
	if(is_user_connected(iItemId)) {
		if(g_ClanSlot[iItemId]) {
			if(g_Clan[g_ClanSlot[iItemId]][clanCountMembers] < MAX_CLAN_MEMBERS) {
				if(g_ClanInvitationsId[id][iItemId]) {
					new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_clans_members` (`acc_id`, `clan_id`, `owner`, `since_connection`, `last_connection`) VALUES ('%d', '%d', '0', '%d', '%d');", dg_get_user_acc_id(id), g_Clan[g_ClanSlot[iItemId]][clanId], get_arg_systime(), get_arg_systime());
					
					if(!SQL_Execute(sqlQuery)) {
						executeQuery(id, sqlQuery, 17);
					} else {
						SQL_FreeHandle(sqlQuery);
						
						sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_pjs` SET `clan_id`='%d' WHERE (`acc_id`='%d');", g_Clan[g_ClanSlot[iItemId]][clanId], dg_get_user_acc_id(id));
						
						if(!SQL_Execute(sqlQuery)) {
							executeQuery(id, sqlQuery, 18);
						} else {
							SQL_FreeHandle(sqlQuery);
							
							g_ClanSlot[id] = g_ClanSlot[iItemId];
							
							++g_Clan[g_ClanSlot[id]][clanCountMembers];
							++g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

							new iClanSlotId = getClanMemberEmptySlot(id);
							
							if(iClanSlotId >= 0) {
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberId] = dg_get_user_acc_id(id);
								formatex(g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberName], 31, "%n", id);
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberOwner] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceDay] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceHour] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceMinute] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeDay] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeHour] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeMinute] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLevelTotal] = getUserLevelTotal(id);
							}

							--g_ClanInvitations[iItemId];
							g_ClanInvitations[id] = 0;
							g_ClanInvitationsId[id][iItemId] = 0;
							
							new i;
							for(i = 1; i <= MaxClients; ++i) {
								if(g_ClanSlot[id] == g_ClanSlot[i]) {
									if(id == i) {
										clientPrintColor(i, _, "Te uniste al clan !g%s!y.", g_Clan[g_ClanSlot[id]][clanName]);
									} else {
										clientPrintColor(i, _, "!t%n!y se unió al Clan.", id);
									}
								}
							}

							// if(g_Class[id] == CLASS_HUMAN && g_ClanCombo[g_ClanSlot[id]]) {
								// sendClanMessage(id, "Un miembro humano ingresó al Clan y el combo ha finalizado");
								// clanFinishCombo(id);
							// }
							
							showMenu__Clan(id);
						}
					}
				} else {
					clientPrintColor(id, _, "La invitación al clan ha expirado.");
					
					--g_ClanInvitations[id];
					g_ClanInvitationsId[id][iItemId] = 0;
				}
			} else {
				clientPrintColor(id, _, "El clan está lleno.");
				
				--g_ClanInvitations[id];
				g_ClanInvitationsId[id][iItemId] = 0;
			}
		} else {
			clientPrintColor(id, _, "El jugador no está en un clan.");
			
			--g_ClanInvitations[id];
			g_ClanInvitationsId[id][iItemId] = 0;
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado.");
		
		--g_ClanInvitations[id];
		g_ClanInvitationsId[id][iItemId] = 0;
	}
	
	if(g_ClanInvitations[id] && !g_ClanSlot[id]) {
		showMenu__ClanInvitations(id);
	}

	return PLUGIN_HANDLED;
}

showMenu__ClanPerks(const id) {
	if(!g_ClanSlot[id]) {
		return;
	}

	oldmenu_create("\yVENTAJAS DEL CLAN^n\wDepósito\r:\y %d", "@menu__ClanPerks", g_Clan[g_ClanSlot[id]][clanDeposit]);

	oldmenu_additem(1, 1, "\r1.\w Depositar puntos");
	oldmenu_additem(2, 2, "\r2.\w Ventajas \y(%d / %d)^n", getClanPerks(id), structIdClanPerks);

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ClanPerks(const id, const item) {
	if(!item) {
		showMenu__Clan(id);
		return;
	} else if(!g_ClanSlot[id]) {
		return;
	}

	switch(item) {
		case 1: {
			showMenu__ClanDeposit(id);
		} case 2: {
			showMenu__ClanShowPerks(id);
		}
	}
}

showMenu__ClanDeposit(const id) {
	if(!g_ClanSlot[id]) {
		return;
	}

	oldmenu_create("\yDEPOSITAR PUNTOS", "@menu__ClanDeposit");

	oldmenu_additem(-1, -1, "\wDepósito\r:\y %d", g_Clan[g_ClanSlot[id]][clanDeposit]);
	oldmenu_additem(-1, -1, "\wTus pF\r:\y %d^n", g_Point[id][P_FRAGMENT]);

	oldmenu_additem(1, 1, "\r1.\w Reducir cantidad a depositar");
	oldmenu_additem(2, 2, "\r2.\w Aumentar cantidad a depositar^n");

	oldmenu_additem(9, 9, "\r9.\w Depositar \y%d pF\w", g_TempClanDeposit[id]);
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

@menu__ClanDeposit(const id, const item) {
	if(!item) {
		showMenu__ClanPerks(id);
		return;
	} else if(!g_ClanSlot[id]) {
		return;
	}

	switch(item) {
		case 1: {
			g_TempClanDeposit[id] -= 5;

			if(g_TempClanDeposit[id] < 0) {
				g_TempClanDeposit[id] = 0;
			}
			
			showMenu__ClanDeposit(id);
		} case 2: {
			g_TempClanDeposit[id] += 5;

			if(g_TempClanDeposit[id] > 2000) {
				g_TempClanDeposit[id] = 2000;
			}

			showMenu__ClanDeposit(id);
		} case 9: {
			if(!g_TempClanDeposit[id]) {
				clientPrintColor(id, _, "No puedes depositar 0 pF.");

				showMenu__ClanDeposit(id);
				return;
			}

			if(getClanPerks(id) == structIdClanPerks) {
				clientPrintColor(id, _, "No puedes depositar porque han comprado todas las ventajas del Clan.");

				showMenu__ClanDeposit(id);
				return;
			}

			if(g_Point[id][P_FRAGMENT] >= g_TempClanDeposit[id]) {
				sendClanMessage(id, "!t%n!y depositó !g%d pF!y al Clan.", id, g_TempClanDeposit[id]);

				g_Point[id][P_FRAGMENT] -= g_TempClanDeposit[id];
				g_Clan[g_ClanSlot[id]][clanDeposit] += g_TempClanDeposit[id];
				g_TempClanDeposit[id] = 0;

				new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_clans` SET `deposit`='%d' WHERE (`id`='%d');", g_Clan[g_ClanSlot[id]][clanDeposit], g_Clan[g_ClanSlot[id]][clanId]);
				
				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 19);
				} else {
					SQL_FreeHandle(sqlQuery);
				}
			} else {
				clientPrintColor(id, _, "No tienes los pF indicados para depositar.");
			}

			showMenu__ClanDeposit(id);
		}
	}
}

showMenu__ClanShowPerks(const id) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new sItem[128];
	new iMenuId;
	new i;
	new sPosition[2];

	formatex(sItem, charsmax(sItem), "VENTAJAS (%d / %d)^n\wAl seleccionar una, verás la información de la misma\y\R", getClanPerks(id), structIdClanPerks);
	iMenuId = menu_create(sItem, "@menu__ClanShowPerks");

	for(i = 0; i < structIdClanPerks; ++i) {
		formatex(sItem, charsmax(sItem), "%s%s", ((g_ClanPerks[g_ClanSlot[id]][i]) ? "\w" : "\d"), __CLAN_PERKS[i][clanPerkName]);
		
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_ClanPerks[id] = min(g_MenuPage_ClanPerks[id], menu_pages(iMenuId) - 1);

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_ClanPerks[id]);
}

@menu__ClanShowPerks(const id, const menu, const item) {
	if(!is_user_connected(id) || !g_ClanSlot[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_ClanPerks[id]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__ClanPerks(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	g_MenuData_ClanPerkId[id] = sPosition[0];

	showMenu__ClanShowPerkInfo(id);
	return PLUGIN_HANDLED;
}

showMenu__ClanShowPerkInfo(const id) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new iPerkId = g_MenuData_ClanPerkId[id];

	oldmenu_create("\y%s - %s^n\wDepósito\r:\y %d", "@menu__ClanShowPerkInfo", __CLAN_PERKS[iPerkId][clanPerkName], ((g_ClanPerks[g_ClanSlot[id]][iPerkId]) ? "\y(ADQUIRIDO)" : "\r(NO ADQUIRIDO)"), g_Clan[g_ClanSlot[id]][clanDeposit]);

	if(!g_ClanPerks[g_ClanSlot[id]][iPerkId]) {
		oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", __CLAN_PERKS[iPerkId][clanPerkDesc]);

		oldmenu_additem(-1, -1, "\yCOSTO\r:");
		oldmenu_additem(-1, -1, "\r - \w+%d^n", __CLAN_PERKS[iPerkId][clanPerkCost]);

		if(g_Clan[g_ClanSlot[id]][clanDeposit] >= __CLAN_PERKS[iPerkId][clanPerkCost]) {
			oldmenu_additem(1, 1, "\r1.\w Comprar ventaja");
		} else {
			oldmenu_additem(-1, -1, "\d1. Comprar ventaja");
		}
	} else {
		oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", __CLAN_PERKS[iPerkId][clanPerkDesc]);
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ClanShowPerkInfo(const id, const item) {
	if(!item) {
		showMenu__ClanShowPerks(id);
		return;
	} else if(!g_ClanSlot[id]) {
		return;
	}

	new iPerkId = g_MenuData_ClanPerkId[id];

	switch(item) {
		case 1: {
			if(g_ClanPerks[g_ClanSlot[id]][iPerkId]) {
				showMenu__ClanShowPerkInfo(id);
				return;
			}

			if(iPerkId == CLAN_PERK_MULTIPLE_COMBO) {
				if(!g_ClanPerks[g_ClanSlot[id]][CLAN_PERK_COMBO]) {
					clientPrintColor(id, _, "No puedes comprar esta mejora porque requiere tener otra mejora previa.");

					showMenu__ClanShowPerkInfo(id);
					return;
				}
			}

			if(g_Clan[g_ClanSlot[id]][clanDeposit] >= __CLAN_PERKS[iPerkId][clanPerkCost]) {
				if(getClanMemberRange(id)) {
					clanCheckRequiredCombo(id);

					g_ClanPerks[g_ClanSlot[id]][iPerkId] = 1;
					g_Clan[g_ClanSlot[id]][clanDeposit] -= __CLAN_PERKS[iPerkId][clanPerkCost];

					sendClanMessage(id, "!tFELICITACIONES!y: El clan compró la ventaja !g%s!y.", __CLAN_PERKS[iPerkId][clanPerkName]);

					new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_clans` SET `deposit`='%d' WHERE (`id`='%d');", g_Clan[g_ClanSlot[id]][clanDeposit], g_Clan[g_ClanSlot[id]][clanId]);
					
					if(!SQL_Execute(sqlQuery)) {
						executeQuery(id, sqlQuery, 20);
					} else {
						SQL_FreeHandle(sqlQuery);
					}

					sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_clans_perks` (`clan_id`, `perk_id`, `perk_timestamp`) VALUES ('%d', '%d', '%d');", g_Clan[g_ClanSlot[id]][clanId], iPerkId, get_arg_systime());
					
					if(!SQL_Execute(sqlQuery)) {
						executeQuery(id, sqlQuery, 21);
					} else {
						SQL_FreeHandle(sqlQuery);
					}
				} else {
					clientPrintColor(id, _, "Solo los miembros con rango de !gDUEÑO!y del Clan pueden comprar las ventajas.");
				}
			}

			showMenu__ClanShowPerkInfo(id);
		}
	}
}

@sqlThread__Updates(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];
	
	if(!is_user_connected(iId)) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_LOG_FILE, "sqlThread__Updates() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al realizar una consulta. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	new iMemberId = data[2];

	switch(data[1]) {
		case 0: {
			clientPrintColor(iId, _, "!t%s!y ha sido degradado a !tMiembro!y.", g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberName]);
			g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberOwner] = 0;
		} case 1: {
			clientPrintColor(iId, _, "!t%s!y ha sido promovido a !tDueño!y.", g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberName]);
			g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberOwner] = 1;
		}
	}

	showMenu__ClanMemberInfo(iId, iMemberId);
}

loadClan(const id, const clan_id) {
	if(clan_id) {
		new iOk = 0;
		new i;
		new j;

		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			if(g_Clan[g_ClanSlot[i]][clanId] != clan_id) {
				continue;
			}

			iOk = 1;

			g_ClanSlot[id] = g_ClanSlot[i];

			++g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

			j = getClanMemberSlotId(id);

			if(j != -1) {
				g_ClanMembers[g_ClanSlot[id]][j][clanMemberLastTimeDay] = 0;
				g_ClanMembers[g_ClanSlot[id]][j][clanMemberLastTimeHour] = 0;
				g_ClanMembers[g_ClanSlot[id]][j][clanMemberLastTimeMinute] = 0;
			}
			
			break;
		}
		
		if(!iOk) {
			new iClanSlot = clanFindSlot();

			if(!iClanSlot) {
				return;
			}

			resetDataClanMembers(iClanSlot);

			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `zp9_clans` WHERE (`id`='%d') LIMIT 1;", clan_id);
			
			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 22);
			} else if(SQL_NumResults(sqlQuery)) {
				g_ClanSlot[id] = iClanSlot;
				
				g_Clan[g_ClanSlot[id]][clanId] = clan_id;
				SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_name"), g_Clan[g_ClanSlot[id]][clanName], 31);
				g_Clan[g_ClanSlot[id]][clanSince] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_timestamp"));
				g_Clan[g_ClanSlot[id]][clanDeposit] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "deposit"));
				g_Clan[g_ClanSlot[id]][clanKillHmDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kills_h_done"));
				g_Clan[g_ClanSlot[id]][clanKillZmDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kills_z_done"));
				g_Clan[g_ClanSlot[id]][clanInfectDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "infections_done"));
				g_Clan[g_ClanSlot[id]][clanVictory] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "vic"));
				g_Clan[g_ClanSlot[id]][clanVictoryConsec] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "vic_con"));
				g_Clan[g_ClanSlot[id]][clanVictoryConsecHistory] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "vic_con_his"));
				g_Clan[g_ClanSlot[id]][clanChampion] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "is_champion"));
				g_Clan[g_ClanSlot[id]][clanRank] = 0;
				g_Clan[g_ClanSlot[id]][clanCountOnlineMembers] = 1;
				g_Clan[g_ClanSlot[id]][clanCountMembers] = 0;
				g_Clan[g_ClanSlot[id]][clanHumans] = 0;
				
				SQL_FreeHandle(sqlQuery);
			} else {
				SQL_FreeHandle(sqlQuery);
			}

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT \
														zp9_clans_members.acc_id, zp9_accounts.name, zp9_clans_members.owner, zp9_clans_members.since_connection, zp9_clans_members.last_connection, zp9_pjs.level, zp9_pjs.reset, zp9_pjs.prestige \
														FROM zp9_clans_members \
														LEFT JOIN zp9_accounts ON zp9_clans_members.acc_id=zp9_accounts.id \
														LEFT JOIN zp9_pjs ON zp9_clans_members.acc_id=zp9_pjs.acc_id \
														WHERE zp9_clans_members.clan_id='%d' AND zp9_clans_members.active='1' LIMIT %d;", clan_id, MAX_CLAN_MEMBERS);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 23);
			} else if(SQL_NumResults(sqlQuery)) {
				new i = 0;
				new iSince;
				new iLastSee;
				new iSysTime = get_arg_systime();
				new iMinutes;
				
				while(SQL_MoreResults(sqlQuery)) {
					++g_Clan[g_ClanSlot[id]][clanCountMembers];

					g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] = SQL_ReadResult(sqlQuery, 0);
					SQL_ReadResult(sqlQuery, 1, g_ClanMembers[g_ClanSlot[id]][i][clanMemberName], 32);
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberOwner] = SQL_ReadResult(sqlQuery, 2);
					iSince = (iSysTime - SQL_ReadResult(sqlQuery, 3));
					iLastSee = (iSysTime - SQL_ReadResult(sqlQuery, 4));
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberLevelTotal] = ((SQL_ReadResult(sqlQuery, 7) * (MAX_RESETS + 1) * MAX_LEVELS) + (SQL_ReadResult(sqlQuery, 6) * MAX_LEVELS) + SQL_ReadResult(sqlQuery, 5));
					
					// START - Miembro desde
					iMinutes = (iSince / 60);
					
					if(iMinutes >= 60) {
						while(iMinutes >= 60) {
							++g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour];
							
							if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour] >= 24) {
								++g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceDay];
								g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour] -= 24;
							}
							
							iMinutes -= 60;
						}
					} else {
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceDay] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceMinute] = iMinutes;
					}
					
					if(dg_get_user_acc_id(id) == g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeDay] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeMinute] = 0;
					}
					// END
					
					// START - Última vez visto
					iMinutes = (iLastSee / 60);
					
					if(iMinutes >= 60) {
						while(iMinutes >= 60) {
							++g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour];
							
							if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] >= 24) {
								++g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeDay];
								g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] -= 24;
							}
							
							iMinutes -= 60;
						}
					} else {
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeDay] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeMinute] = iMinutes;
					}
					// END
					
					++i;
					
					SQL_NextRow(sqlQuery);
				}

				SQL_FreeHandle(sqlQuery);
			} else {
				SQL_FreeHandle(sqlQuery);
			}

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `perk_id` FROM `zp9_clans_perks` WHERE (`clan_id`='%d') LIMIT %d;", clan_id, structIdClanPerks);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 24);
			} else if(SQL_NumResults(sqlQuery)) {
				while(SQL_MoreResults(sqlQuery)) {
					g_ClanPerks[g_ClanSlot[id]][SQL_ReadResult(sqlQuery, 0)] = 1;
					SQL_NextRow(sqlQuery);
				}

				SQL_FreeHandle(sqlQuery);
			} else {
				SQL_FreeHandle(sqlQuery);
			}

			clanUpdateHumans(id);
		}
	}
}

@clcmd__Clans(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	consolePrint(id, "");

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_connected(i) && dg_get_user_acc_status(i) >= STATUS_LOGGED && g_ClanSlot[i]) {
			consolePrint(id, "g_ClanSlot[%d] - %n", g_ClanSlot[i], i);
		}
	}

	consolePrint(id, "");
	return PLUGIN_HANDLED;
}

showMenu__UserOptions(const id) {
	oldmenu_create("\yOPCIONES DE USUARIO", "@menu__UserOptions");

	oldmenu_additem(1, 1, "\r1.\w Elegir color^n");

	oldmenu_additem(2, 2, "\r2.\w Opciones de HUD General");
	oldmenu_additem(3, 3, "\r3.\w Opciones de HUD Combo");
	oldmenu_additem(4, 4, "\r4.\w Opciones de HUD Clan Combo^n");

	oldmenu_additem(5, 5, "\r5.\w Activadores");
	oldmenu_additem(6, 6, "\r6.\w Vincular cuenta^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__UserOptions(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_MenuPage_ColorChoosen[id] < 1) {
				g_MenuPage_ColorChoosen[id] = 1;
			}

			showMenu__UserOptions_ColorChoosen(id, g_MenuPage_ColorChoosen[id]);
		} case 2: {
			showMenu__UserOptions_Hud(id, HUD_TYPE_GENERAL);
		} case 3: {
			showMenu__UserOptions_Hud(id, HUD_TYPE_COMBO);
		} case 4: {
			showMenu__UserOptions_Hud(id, HUD_TYPE_CLAN_COMBO);
		} case 5: {
			showMenu__UserOptions_Active(id);
		} case 6: {
			dg_get_user_menu_vinc(id);
		}
	}
}

showMenu__UserOptions_ColorChoosen(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;
	new iColorType = g_MenuData_ColorChoosen[id];

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__COLORS), 6);
	oldmenu_create("\yELEGIR COLORES \r[%d - %d]\y\R%d / %d", "@menu__UserOptions_ColorChoosen", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_UserOption_Color[id][iColorType][0] == __COLORS[i][colorRed] &&
		g_UserOption_Color[id][iColorType][1] == __COLORS[i][colorGreen] &&
		g_UserOption_Color[id][iColorType][2] == __COLORS[i][colorBlue]) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, __COLORS[i][colorName]);
		} else {
			oldmenu_additem(j, i, "\r%d.\w %s", j, __COLORS[i][colorName]);
		}
	}

	oldmenu_additem(7, 7, "^n\r7.\w Tipo de color \y(%s)", __COLORS_TYPE[iColorType]);

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

@menu__UserOptions_ColorChoosen(const id, const item, const value, page) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage_ColorChoosen[id] = iNewPage;

		showMenu__UserOptions_ColorChoosen(id, iNewPage);
		return;
	} else if(item == 7) {
		++g_MenuData_ColorChoosen[id];

		if(g_MenuData_ColorChoosen[id] == sizeof(__COLORS_TYPE)) {
			g_MenuData_ColorChoosen[id] = 0;
		}

		showMenu__UserOptions_ColorChoosen(id, g_MenuPage_ColorChoosen[id]);
		return;
	}

	g_UserOption_Color[id][g_MenuData_ColorChoosen[id]][0] = __COLORS[value][colorRed];
	g_UserOption_Color[id][g_MenuData_ColorChoosen[id]][1] = __COLORS[value][colorGreen];
	g_UserOption_Color[id][g_MenuData_ColorChoosen[id]][2] = __COLORS[value][colorBlue];

	if(g_MenuData_ColorChoosen[id] == COLOR_TYPE_HUD) {
		g_NextHudInfoTime[id] = (get_gametime() + 0.1);
	} else if(g_MenuData_ColorChoosen[id] == COLOR_TYPE_NVISION/* && g_NVision[id] && task_exists(id + TASK_NVISION)*/) {
		// remove_task(id + TASK_NVISION);
		// set_task(0.1, "task__SetUserNVision", id + TASK_NVISION, .flags="b");
	}

	showMenu__UserOptions_ColorChoosen(id, g_MenuPage_ColorChoosen[id]);
}

showMenu__UserOptions_Hud(const id, const type_hud) {
	oldmenu_create("\yOPCIONES DE HUD %s", "@menu__UserOptions_Hud", __HUD_TYPES[type_hud]);

	oldmenu_additem(1, type_hud, "\r1.\w Mover hacia arriba");
	oldmenu_additem(2, type_hud, "\r2.\w Mover hacia abajo^n");

	if(g_UserOption_HudPosition[id][type_hud][2] != 1.0) {
		oldmenu_additem(3, type_hud, "\r3.\w Mover hacia la izquierda");
		oldmenu_additem(4, type_hud, "\r4.\w Mover hacia la derecha^n");
	}

	oldmenu_additem(5, type_hud, "\r5.\w HUD alineado %s^n", ((g_UserOption_HudPosition[id][type_hud][2] == 0.0) ? "a la izquierda" : ((g_UserOption_HudPosition[id][type_hud][2] == 1.0) ? "al centro" : "a la derecha")));
	
	oldmenu_additem(6, type_hud, "\r6.\w Efecto del HUD \y(%s)", ((g_UserOption_HudEffect[id][type_hud]) ? "Activado" : "Desactivado"));

	if(type_hud == HUD_TYPE_GENERAL) {
		oldmenu_additem(7, type_hud, "\r7.\w Estilos del HUD \y(%s)", __HUD_STYLES[g_UserOption_HudStyle[id][type_hud]]);
	}

	oldmenu_additem(9, type_hud, "^n\r9.\w Reiniciar valores^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__UserOptions_Hud(const id, const item, const value) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	switch(item) {
		case 1: {
			g_UserOption_HudPosition[id][value][1] -= 0.01;
		} case 2: {
			g_UserOption_HudPosition[id][value][1] += 0.01;
		} case 3: {
			g_UserOption_HudPosition[id][value][0] -= 0.01;
		} case 4: {
			g_UserOption_HudPosition[id][value][0] += 0.01;
		} case 5: {
			switch(g_UserOption_HudPosition[id][value][2]) {
				case 0.0: {
					g_UserOption_HudPosition[id][value][0] = -1.0;
					g_UserOption_HudPosition[id][value][2] = 1.0;
				} case 1.0: {
					g_UserOption_HudPosition[id][value][0] = 1.5;
					g_UserOption_HudPosition[id][value][2] = 2.0;
				} case 2.0: {
					g_UserOption_HudPosition[id][value][0] = 0.0;
					g_UserOption_HudPosition[id][value][2] = 0.0;
				}
			}
		} case 6: {
			g_UserOption_HudEffect[id][value] = !g_UserOption_HudEffect[id][value];
		} case 7: {
			if(value == HUD_TYPE_GENERAL) {
				++g_UserOption_HudStyle[id][value];

				if(g_UserOption_HudStyle[id][value] == sizeof(__HUD_STYLES)) {
					g_UserOption_HudStyle[id][value] = 0;
				}
			}
		} case 9: {
			switch(value) {
				case HUD_TYPE_GENERAL: {
					g_UserOption_HudPosition[id][HUD_TYPE_GENERAL] = Float:{0.02, 0.1, 0.0};
					g_UserOption_HudEffect[id][HUD_TYPE_GENERAL] = 0;
					g_UserOption_HudStyle[id][HUD_TYPE_GENERAL] = 1;
				} case HUD_TYPE_COMBO: {
					g_UserOption_HudPosition[id][HUD_TYPE_COMBO] = Float:{-1.0, 0.6, 1.0};
					g_UserOption_HudEffect[id][HUD_TYPE_COMBO] = 0;
					g_UserOption_HudStyle[id][HUD_TYPE_COMBO] = 1;
				} case HUD_TYPE_CLAN_COMBO: {
					g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO] = Float:{-1.0, 0.8, 1.0};
					g_UserOption_HudEffect[id][HUD_TYPE_CLAN_COMBO] = 0;
					g_UserOption_HudStyle[id][HUD_TYPE_CLAN_COMBO] = 1;
				}
			}
		}
	}

	switch(value) {
		case HUD_TYPE_GENERAL: {
			g_NextHudInfoTime[id] = (get_gametime() + 0.1);
		} case HUD_TYPE_COMBO: {
			set_hudmessage(random(256), random(256), random(256), g_UserOption_HudPosition[id][HUD_TYPE_COMBO][0], g_UserOption_HudPosition[id][HUD_TYPE_COMBO][1], g_UserOption_HudEffect[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
			ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nCombo de x1.337 Ammo Packs^nDaño: 1.337 | Daño total: 1.337", __COMBO_HUMAN[random_num(1, charsmax(__COMBO_HUMAN))][comboMessage]);
		} case HUD_TYPE_CLAN_COMBO: {
			set_hudmessage(random(256), random(256), random(256), g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][0], g_UserOption_HudPosition[id][HUD_TYPE_CLAN_COMBO][1], g_UserOption_HudEffect[id][HUD_TYPE_CLAN_COMBO], 1.0, 8.0, 0.01, 0.01);
			ShowSyncHudMsg(id, g_HudSync_ClanCombo, "%s [%d]^nCombo de x1.337 Ammo Packs^nDaño total: 1.337", __PLUGIN_COMMUNITY_NAME, random(MAX_CLAN_MEMBERS));
		}
	}

	showMenu__UserOptions_Hud(id, value);
}

showMenu__UserOptions_Active(const id) {
	oldmenu_create("\yACTIVADORES", "@menu__UserOptions_Active");

	switch(g_UserOption_Invis[id]) {
		case 0: {
			oldmenu_additem(1, 1, "\r1.\w Humanos invisibles\r:\y No");
		} case 1: {
			oldmenu_additem(1, 1, "\r1.\w Humanos invisibles\r:\y Si");
		} case 2: {
			oldmenu_additem(1, 1, "\r1.\w Humanos invisibles\r:\y Si \d[Clan]");
		}
	}

	oldmenu_additem(2, 2, "\r2.\w Visión nocturna\r:\y %s", ((g_UserOption_NVision[id]) ? "Si" : "No"));
	oldmenu_additem(3, 3, "\r3.\w Glow del clan\r:\y %s", ((g_UserOption_ClanGlow[id]) ? "Si" : "No"));
	oldmenu_additem(4, 4, "\r4.\w Mostrar nivel total\r:\y %s^n", ((g_UserOption_LevelTotal[id]) ? "Si" : "No"));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__UserOptions_Active(const id, const item) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	switch(item) {
		case 1: {
			++g_UserOption_Invis[id];

			if(g_UserOption_Invis[id] == 3) {
				g_UserOption_Invis[id] = 0;
			}

			showMenu__UserOptions_Active(id);
		} case 2: {
			g_UserOption_NVision[id] = !g_UserOption_NVision[id];
			showMenu__UserOptions_Active(id);
		} case 3: {
			g_UserOption_ClanGlow[id] = !g_UserOption_ClanGlow[id];
			showMenu__UserOptions_Active(id);
		} case 4: {
			g_UserOption_LevelTotal[id] = !g_UserOption_LevelTotal[id];
			
			g_NextHudInfoTime[id] = (get_gametime() + 0.1);

			showMenu__UserOptions_Active(id);
		}
	}
}

showMenu__Stats(const id) {
	new sAccount[8];
	new sForum[8];
	new sBuffer[2][32];

	oldmenu_create("\yESTADÍSTICAS", "@menu__Stats");

	oldmenu_additem(1, 1, "\r1.\w Subir de Reset");
	oldmenu_additem(2, 2, "\r2.\w Top 15^n");

	oldmenu_additem(3, 3, "\r3.\w Estadísticas Generales");
	oldmenu_additem(4, 4, "\r4.\w Estadísticas de mis Items Extras^n");

	addDot(dg_get_user_acc_id(id), sAccount, charsmax(sAccount));
	addDot(dg_get_user_acc_vinc(id), sForum, charsmax(sForum));

	oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccount);
	oldmenu_additem(-1, -1, "\wVINCULADO AL FORO\r:\y %s \d(#%s)", ((dg_get_user_acc_vinc(id)) ? "Si" : "No"), sForum);
	oldmenu_additem(-1, -1, "\wVINCULADO A LA APP MOBILE\r:\y %s", ((dg_get_user_acc_vinc_am(id)) ? "Si" : "No"));
	
	if(g_TimePlayed[id][TIME_DAY] >= 1) {
		formatex(sBuffer[0], charsmax(sBuffer[]), "\y%d\w día%s", g_TimePlayed[id][TIME_DAY], ((g_TimePlayed[id][TIME_DAY] != 1) ? "s" : ""));
	}

	if(g_TimePlayed[id][TIME_HOUR] >= 1) {
		formatex(sBuffer[1], charsmax(sBuffer[]), "\y%d\w hora%s", g_TimePlayed[id][TIME_HOUR], ((g_TimePlayed[id][TIME_HOUR] != 1) ? "s" : ""));
	}

	if(g_TimePlayed[id][TIME_MIN] >= 6) {
		oldmenu_additem(-1, -1, "\wTIEMPO JUGADO\r:\y %s%s%s^n", sBuffer[0], ((sBuffer[0][0] && sBuffer[1][0]) ? " con " : ""), sBuffer[1]);
	} else {
		oldmenu_additem(-1, -1, "\wTIEMPO JUGADO\r:\y Nada^n");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__Stats(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			showMenu__Stats_ResetUp(id);
		} case 2: {
			clientPrintColor(id, _, "Para ver los top15 del servidor, ingresa a !thttps://www.drunkgaming.net/servidores/8-zombie-plague/!y.");
			showMenu__Stats(id);
		} case 3: {
			showMenu__Stats_General(id);
		} case 4: {
			showMenu__Stats_ExtraItems(id);
		}
	}
}

showMenu__Stats_ResetUp(const id) {
	oldmenu_create("\ySUBIR DE RESET", "@menu__Stats_ResetUp");

	if(checkUpPrestige(id)) {
		oldmenu_additem(1, 1, "\r1.\w Subir al prestigio \y[%s]^n", __PRESTIGE_LETTERS[(g_Prestige[id] + 1)]);
	} else {
		if(checkUpReset(id)) {
			oldmenu_additem(1, 1, "\r1.\w Subir al reset \y[%d]^n", (g_Reset[id] + 1));
		} else {
			oldmenu_additem(-1, -1, "\dEstás a \r%0.2f%%\d de Subir de Reset^n", g_Reset_Percent[id]);
		}
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__Stats_ResetUp(const id, const item) {
	if(!item) {
		showMenu__Stats(id);
		return;
	}

	switch(item) {
		case 1: {
			if(checkUpPrestige(id)) {
				g_AmmoPacks[id] = 0;
				g_Level[id] = 1;
				g_Reset[id] = 0;
				++g_Prestige[id];

				checkAmmoPacksEquation(id);

				clientPrintColor(0, id, "Felicidades a !t%n!y, subió al prestigio !g[%s]!y.", id, __PRESTIGE_LETTERS[g_Prestige[id]]);
				showMenu__Stats_ResetUp(id);
			} else {
				if(checkUpReset(id)) {
					g_AmmoPacks[id] = 0;
					g_Level[id] = 1;
					++g_Reset[id];

					checkAmmoPacksEquation(id);

					clientPrintColor(0, id, "Felicidades a !t%n!y, subió al reset !g[%d]!y.", id, g_Reset[id]);
					showMenu__Stats_ResetUp(id);
				}
			}
		}
	}
}

showMenu__Stats_General(const id) {

}

showMenu__Stats_ExtraItems(const id) {

}

showMenu__Weapons(const id) {
	oldmenu_create("\yARMAS", "@menu__Weapons");

	oldmenu_additem(1, 1, "\r1.\w Comprar armas");
	oldmenu_additem(2, 2, "\r2.\w Mejorar mis armas^n");

	oldmenu_additem(9, 9, "\r9.\w Recordar compra\r:\y %s^n", ((g_Weapon_AutoBuy[id]) ? "Si" : "No"));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__Weapons(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			showMenu__BuyPrimaryWeapons(id);
		} case 2: {

		} case 9: {
			g_Weapon_AutoBuy[id] = !g_Weapon_AutoBuy[id];
			showMenu__Weapons(id);
		}
	}
}

showMenu__BuyPrimaryWeapons(const id) {
	new iMenuId;
	new i;
	new sPosition[2];

	iMenuId = menu_create("ARMAS PRIMARIAS\R", "@menu__BuyPrimaryWeapons");

	for(i = 0; i < sizeof(__PRIMARY_WEAPONS); ++i) {
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, __PRIMARY_WEAPONS[i][weaponName], sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId);
}

@menu__BuyPrimaryWeapons(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	new iItemId; 

	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	g_Weapon_PrimarySelection[id] = sPosition[0];

	showMenu__BuySecondaryWeapons(id);
	return PLUGIN_HANDLED;
}

showMenu__BuySecondaryWeapons(const id) {
	new iMenuId;
	new i;
	new sPosition[2];

	iMenuId = menu_create("ARMAS SECUNDARIAS\R", "@menu__BuySecondaryWeapons");

	for(i = 0; i < sizeof(__SECONDARY_WEAPONS); ++i) {
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, __SECONDARY_WEAPONS[i][weaponName], sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId);
}

@menu__BuySecondaryWeapons(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	new iItemId;

	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	g_Weapon_SecondarySelection[id] = sPosition[0];

	showMenu__BuyCuaternaryWeapons(id);
	return PLUGIN_HANDLED;
}

showMenu__BuyCuaternaryWeapons(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new iLevelTotal;
	new sLevelTotal[16];
	new sPosition[2];

	iMenuId = menu_create("ARMAS CUATERNARIAS\R", "@menu__BuyCuaternaryWeapons");

	for(i = 0; i < sizeof(__CUATERNARY_WEAPONS); ++i) {
		iLevelTotal = __CUATERNARY_WEAPONS[i][grenadeWeaponevelTotal];

		if(getUserLevelTotal(id) >= iLevelTotal) {
			if(g_UserOption_LevelTotal[id]) {
				addDot(iLevelTotal, sLevelTotal, charsmax(sLevelTotal));
				formatex(sItem, charsmax(sItem), "\w%s \y(N: %s)", __CUATERNARY_WEAPONS[i][grenadeWeaponName], sLevelTotal);
			} else {
				formatex(sItem, charsmax(sItem), "\w%s \y(%s)", __CUATERNARY_WEAPONS[i][grenadeWeaponName], getLevelTotalRequired(iLevelTotal));
			}
		} else {
			if(g_UserOption_LevelTotal[id]) {
				addDot(iLevelTotal, sLevelTotal, charsmax(sLevelTotal));
				formatex(sItem, charsmax(sItem), "\d%s \r(N: %s)", __CUATERNARY_WEAPONS[i][grenadeWeaponName], sLevelTotal);
			} else {
				formatex(sItem, charsmax(sItem), "\d%s \r(%s)", __CUATERNARY_WEAPONS[i][grenadeWeaponName], getLevelTotalRequired(iLevelTotal));
			}
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId);
}

@menu__BuyCuaternaryWeapons(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	new iItemId;
	new iLevelTotal;

	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	iLevelTotal = __CUATERNARY_WEAPONS[iItemId][grenadeWeaponevelTotal];

	if(getUserLevelTotal(id) >= iLevelTotal) {
		g_Weapon_CuaternarySelection[id] = iItemId;

		if(is_user_alive(id)) {
			if(g_Class[id] == CLASS_HUMAN) {
				if(g_CanBuy[id]) {
					buyPrimaryWeapon(id, g_Weapon_PrimarySelection[id], true);
					buySecondaryWeapon(id, g_Weapon_SecondarySelection[id]);
					buyCuaternaryWeapon(id, g_Weapon_CuaternarySelection[id]);

					g_CanBuy[id] = 0;
					g_Hat_Devil[id] = 1;
				} else {
					clientPrintColor(id, _, "Ya has comprado armas esta ronda. Espera a la próxima ronda o a tu próximo respawn.");
					showMenu__BuyCuaternaryWeapons(id);
				}
			} else {
				clientPrintColor(id, _, "Debes ser humano para comprar armas.");
				showMenu__BuyCuaternaryWeapons(id);
			}
		} else {
			clientPrintColor(id, _, "Debes estar vivo para poder comprar armas.");
			showMenu__BuyCuaternaryWeapons(id);
		}
	} else {
		clientPrintColor(id, _, "No tienes el nivel suficiente para comprar este pack de granadas.");
		showMenu__BuyCuaternaryWeapons(id);
	}

	return PLUGIN_HANDLED;
}

buyPrimaryWeapon(const id, const primary_selection, const bool:remove_all=true) {
	if(remove_all) {
		rg_remove_all_items(id);
		rg_give_item(id, "weapon_knife");
	}

	rg_give_item(id, __PRIMARY_WEAPONS[primary_selection][weaponEnt]);

	new iAmmo = rg_get_user_ammo(id, __PRIMARY_WEAPONS[primary_selection][weaponId]);

	rg_set_user_bpammo(id, __PRIMARY_WEAPONS[primary_selection][weaponId], iAmmo);
}

buySecondaryWeapon(const id, const secondary_selection) {
	rg_give_item(id, __SECONDARY_WEAPONS[secondary_selection][weaponEnt]);

	new iAmmo = rg_get_user_ammo(id, __SECONDARY_WEAPONS[secondary_selection][weaponId]);

	rg_set_user_bpammo(id, __SECONDARY_WEAPONS[secondary_selection][weaponId], iAmmo);
}

buyCuaternaryWeapon(const id, const cuaternary_selection) {
	if(__CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponHeAmount]) {
		rg_give_item(id, "weapon_hegrenade");
		rg_set_user_bpammo(id, WEAPON_HEGRENADE, __CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponHeAmount]);

		if(__CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponDrug]) {

		}
	}
	
	if(__CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponFbAmount]) {
		rg_give_item(id, "weapon_flashbang");
		rg_set_user_bpammo(id, WEAPON_FLASHBANG, __CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponFbAmount]);

		if(__CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponSupernova]) {
			
		}
	}

	if(__CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponSgAmount]) {
		rg_give_item(id, "weapon_smokegrenade");
		rg_set_user_bpammo(id, WEAPON_SMOKEGRENADE, __CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponSgAmount]);

		if(__CUATERNARY_WEAPONS[cuaternary_selection][grenadeWeaponBubble]) {
			
		}
	}
}

public task__Save(const task_id) {
	new iId = (task_id - TASK_SAVE);

	if(!is_user_connected(iId) || dg_get_user_acc_status(iId) < STATUS_LOGGED) {
		return;
	}

	savePlayerData(iId, dg_get_user_acc_id(iId));
}

public task__TimePlayed(const task_id) {
	new iId = (task_id - TASK_TIME_PLAYED);

	if(!is_user_connected(iId)) {
		return;
	}

	new TeamName:iTeam = getUserTeam(iId);

	if(!(TEAM_TERRORIST <= iTeam <= TEAM_CT)) {
		return;
	}

	g_TimePlayed[iId][TIME_MIN] += 6;

	if(g_TimePlayed[iId][TIME_MIN] >= 1440) {
		setAchievement(iId, ENTRENANDO);

		if(g_TimePlayed[iId][TIME_MIN] >= 10080) {
			setAchievement(iId, ESTOY_MUY_SOLO);

			if(g_TimePlayed[iId][TIME_MIN] >= 21600) {
				setAchievement(iId, FOREVER_ALONE);

				if(g_TimePlayed[iId][TIME_MIN] >= 43200) {
					setAchievement(iId, CREO_QUE_TENGO_UN_PROBLEMA);

					if(g_TimePlayed[iId][TIME_MIN] >= 72000) {
						setAchievement(iId, SOLO_EL_ZP_ME_ENTIENDE);
					}
				}
			}
		}
	}
}

setAchievement(const id, const achievement, achievement_fake=0) {
	if(g_Achievement[id][achievement]) {
		return;
	}

	if(!achievement_fake) {
		new iUsersPlaying = (getUsersPlaying(TEAM_TERRORIST) + getUsersPlaying(TEAM_CT));
		new iUsersAlive = getUsersAlive();

		if(__ACHIEVEMENTS[achievement][achievementUsersNeedP] && iUsersPlaying < __ACHIEVEMENTS[achievement][achievementUsersNeedP]) {
			return;
		} else if(__ACHIEVEMENTS[achievement][achievementUsersNeedA] && iUsersAlive < __ACHIEVEMENTS[achievement][achievementUsersNeedA]) {
			return;
		}
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_achievements` (acc_id, achievement_id, achievement_timestamp) VALUES ('%d', '%d', '%d');", dg_get_user_acc_id(id), achievement, get_arg_systime());

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 123);
	} else {
		SQL_FreeHandle(sqlQuery);

		g_Achievement[id][achievement] = 1;
		g_AchievementUnlocked[id][achievement] = get_arg_systime();
		++g_AchievementTotal[id];

		clientPrintColor(0, _, "!t%n!y ganó el logro !g%s !t(%d pF)!y", id, __ACHIEVEMENTS[achievement][achievementName], __ACHIEVEMENTS[achievement][achievementReward]);

		g_Point[id][P_FRAGMENT] += __ACHIEVEMENTS[achievement][achievementReward];
	}
}

public task__CheckAchievements(const task_id) {
	new iId = (task_id - TASK_CHECK_ACHIEVEMENTS);

	if(!is_user_connected(iId)) {
		return;
	}

	if(dg_get_user_acc_status(iId) < STATUS_LOGGED) {
		return;
	}

	new iSysTime = get_arg_systime();

	if(iSysTime < MAX_TIME_TO_ACHIEVEMENT_BETA) {
		setAchievement(iId, BETA_TESTER);

		if(getUserLevelTotal(iId) >= 25) {
			setAchievement(iId, SUPER_BETA_TESTER);
		}
	}
}

changeLongJump(const id, const bool:enabled, const Float:force=0.0, const Float:height=0.0, const Float:cooldown=0.0) {
	g_LongJump[id][longJump__Force] = force;
	g_LongJump[id][longJump__Height] = height;
	g_LongJump[id][longJump__Cooldown] = cooldown;
	g_LongJump[id][longJump__NextTime] = 0.0;

	if(enabled) {
		longJumpUpdateIcon(id, ICONSTATE_AVAILABLE);
	} else {
		if(g_LongJump[id][longJump__Enabled]) {
			longJumpUpdateIcon(id, ICONSTATE_HIDE);
		}
	}

	g_LongJump[id][longJump__Enabled] = enabled;
	return true;
}

longJumpUpdateIcon(const id, const IconState:status) {
	message_begin(MSG_ONE, get_user_msgid("StatusIcon"), _, id);

	switch(status) {
		case ICONSTATE_HIDE: {
			write_byte(0);
			write_string("item_longjump");
		} case ICONSTATE_AVAILABLE: {
			write_byte(1);
			write_string("item_longjump");
			write_byte(255);
			write_byte(160);
			write_byte(0);
		} case ICONSTATE_COOLDOWN: {
			write_byte(1);
			write_string("item_longjump");
			write_byte(128);
			write_byte(128);
			write_byte(128);
		}
	}

	message_end();
}

@clcmd__NextMode(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(g_LastGameMode != MODE_NONE) {
		clientPrintColor(id, _, "El último modo jugado fue !g%s!y.", __MODES[g_LastGameMode][modeName]);
	}

	if(g_CurrentGameMode != MODE_NONE) {
		clientPrintColor(id, _, "El modo actual es !g%s!y.", __MODES[g_CurrentGameMode][modeName]);
	}

	return PLUGIN_HANDLED;
}

@clcmd__Mult(const id) {
	if(!is_user_alive(id)) {
		clientPrintColor(id, _, "Debes estar vivo para ver tus multiplicadores actualizados.");
		return PLUGIN_HANDLED;
	}

	clientPrintColor(id, _, "Tu multiplicador de Ammo Packs es !gx%0.2f!y.", g_AmmoPacks_Mult[id]);
	clientPrintColor(id, _, "Tu daño para hacer combo es de !g%d!y.", g_ComboDamageNeed[id]);

	return PLUGIN_HANDLED;
}

@clcmd__EnterAmuletCustomName(const id) {
	if(g_AmuletCustomCreated[id]) {
		clientPrintColor(id, _, "Ya creaste un amuleto personalizado.");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	new sAmuletCustomName[64];
	read_args(sAmuletCustomName, charsmax(sAmuletCustomName));
	remove_quotes(sAmuletCustomName);
	trim(sAmuletCustomName);

	if(getUserClanBadString(sAmuletCustomName)) {
		clientPrintColor(id, _, "Solo letras y algunos símbolos: !g( ) [ ] { } - = . , : !!y, se permiten espacios.");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	new iLenAmuletCustomName = strlen(sAmuletCustomName);
	
	if(iLenAmuletCustomName < 3) {
		clientPrintColor(id, _, "El nombre del amuleto debe tener al menos 3 caracteres.");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	} else if(iLenAmuletCustomName > 32) {
		clientPrintColor(id, _, "El nombre del amuleto debe tener menos de 32 caracteres.");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	copy(g_AmuletCustomNameFake[id], charsmax(g_AmuletCustomNameFake[]), sAmuletCustomName);

	showMenu__AmuletCustom(id);
	return PLUGIN_HANDLED;
}

@clcmd__AmuletCustomCreate(const id) {
	if(g_AmuletCustomCreated[id]) {
		clientPrintColor(id, _, "Ya creaste un amuleto personalizado.");
		return PLUGIN_HANDLED;
	} else if(!is_user_alive(id)) {
		clientPrintColor(id, _, "Es recomendable que crees tu amuleto estando vivo, hay veces que el menú principal no funciona en algunos modos.");
		return PLUGIN_HANDLED;
	} else if(g_Point[id][P_DIAMOND] < g_AmuletCustomCost[id]) {
		clientPrintColor(id, _, "No tienes diamantes suficientes para crear el amuleto.");
		return PLUGIN_HANDLED;
	}

	console_print(id, "");
	console_print(id, "********* ^"%s^" *********", __PLUGIN_COMMUNITY_NAME);
	console_print(id, "Nombre del amuleto: %s", g_AmuletCustomNameFake[id]);
	console_print(id, "");
	console_print(id, "Vida: +%d", g_AmuletCustom[id][acHealth]);
	console_print(id, "Velocidad: +%d", g_AmuletCustom[id][acSpeed]);
	console_print(id, "Gravedad: +%d", g_AmuletCustom[id][acGravity]);
	console_print(id, "Daño: +%d", g_AmuletCustom[id][acDamage]);
	console_print(id, "");
	console_print(id, "Multiplicador de AmmoPacks: +%0.2f", g_AmuletCustom[id][acMultAmmoPacks]);
	console_print(id, "");
	console_print(id, " >>>>> ");
	console_print(id, "Para confirmar la operacion escriba en consola: %s", g_AmuletCustomConfirm);
	console_print(id, " >>>>> ");
	console_print(id, "");
	console_print(id, "DIAMANTES DISPONIBLES: %d", g_Point[id][P_DIAMOND]);
	console_print(id, "COSTO DEL AMULETO: %d DIAMANTES", g_AmuletCustomCost[id]);
	console_print(id, "********* ^"%s^" *********", __PLUGIN_COMMUNITY_NAME);
	console_print(id, "");

	return PLUGIN_HANDLED;
}

@clcmd__AmuletCustomConfirm(const id) {
	if(g_AmuletCustomCreated[id]) {
		clientPrintColor(id, _, "Ya creaste un amuleto personalizado.");
		return PLUGIN_HANDLED;
	} else if(!is_user_alive(id)) {
		clientPrintColor(id, _, "Es recomendable que crees tu amuleto estando vivo, hay veces que el menú principal no funciona en algunos modos.");
		return PLUGIN_HANDLED;
	} else if(g_Point[id][P_DIAMOND] < g_AmuletCustomCost[id]) {
		clientPrintColor(id, _, "No tienes diamantes suficientes para crear el amuleto.");
		return PLUGIN_HANDLED;
	} else if(g_AmuletCustomCost[id] < 10) {
		clientPrintColor(id, _, "El amuleto no contiene nada, aumenta las estadísticas que desee para poder confirmarlo.");
		return PLUGIN_HANDLED;
	} else if(!g_AmuletCustomNameFake[id][0]) {
		clientPrintColor(id, _, "Por favor, póngale un nombre a su amuleto.");
		return PLUGIN_HANDLED;
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `zp9_amulets_custom` (`acc_id`, `name`, `a_health`, `a_speed`, `a_gravity`, `a_damage`, `a_aps`) VALUES ('%d', ^"%s^", '%d', '%d', '%d', '%d', '%f');", dg_get_user_acc_id(id), g_AmuletCustomName[id], g_AmuletCustom[id][acHealth], g_AmuletCustom[id][acSpeed], g_AmuletCustom[id][acGravity], g_AmuletCustom[id][acDamage], g_AmuletCustom[id][acMultAmmoPacks]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 5412);
	} else {
		SQL_FreeHandle(sqlQuery);

		g_Point[id][P_DIAMOND] -= g_AmuletCustomCost[id];

		g_AmuletCustomCreated[id] = 1;
		copy(g_AmuletCustomName[id], charsmax(g_AmuletCustomName[]), g_AmuletCustomNameFake[id]);

		clientPrintColor(0, _, "!t%n!y ha creado su amuleto personalizado !g%s!y.", id, g_AmuletCustomName[id]);
	}

	return PLUGIN_HANDLED;
}

showMenu__AmuletCustom(const id, const reset=0) {
	if(g_AmuletCustomCreated[id]) {
		oldmenu_create("\yAMULETO PERSONALIZADO^n\wNombre del amuleto\r:\y %s", "menu__AmuletCustom", g_AmuletCustomName[id]);

		if(g_AmuletCustom[id][acHealth]) {
			oldmenu_additem(1, 1, "\r1.\w Vida\r:\y +%d", g_AmuletCustom[id][acHealth]);
		}

		if(g_AmuletCustom[id][acSpeed]) {
			oldmenu_additem(2, 2, "\r2.\w Velocidad\r:\y +%d", g_AmuletCustom[id][acSpeed]);
		}

		if(g_AmuletCustom[id][acGravity]) {
			oldmenu_additem(3, 3, "\r3.\w Gravedad\r:\y +%d", g_AmuletCustom[id][acGravity]);
		}

		if(g_AmuletCustom[id][acDamage]) {
			oldmenu_additem(4, 4, "\r4.\w Daño\r:\y +%d", g_AmuletCustom[id][acDamage]);
		}

		oldmenu_additem(-1, -1, "");

		if(g_AmuletCustom[id][acMultAmmoPacks]) {
			oldmenu_additem(5, 5, "\r5.\w Multiplicador de AmmoPacks\r:\y +%0.2f", g_AmuletCustom[id][acMultAmmoPacks]);
		}

		oldmenu_additem(9, 9, "^n\r9.\w Eliminar amuleto");
		oldmenu_additem(0, 0, "\r0.\w Volver");

		oldmenu_display(id);
	} else {
		if(reset) {
			g_AmuletCustomCost[id] = 10;
			g_AmuletCustomNameFake[id][0] = EOS;
			g_AmuletCustom[id][acHealth] = 1;
			g_AmuletCustom[id][acSpeed] = 1;
			g_AmuletCustom[id][acGravity] = 1;
			g_AmuletCustom[id][acDamage] = 1;
			g_AmuletCustom[id][acMultAmmoPacks] = 0.0;

			clientPrintColor(id, _, "Cuando estés decidido a crear el amuleto personalizado, escribe en consola !gzp_ac_create!y.");
			clientPrintColor(id, _, "Pedirá confirmación, no te preocupes.");
		}

		oldmenu_create("\yAMULETO PERSONALIZADO^n\wCosto\r:\y %d DIAMANTES", "menu__AmuletCustom", g_AmuletCustomCost[id]);

		oldmenu_additem(1, 1, "\r1.\w Nombre del amuleto\r:\y %s", ((g_AmuletCustomNameFake[id][0]) ? g_AmuletCustomNameFake[id] : "no-especificado"));

		oldmenu_additem(2, 2, "\r2.\w Vida\r:\y +%d", g_AmuletCustom[id][acHealth]);
		oldmenu_additem(3, 3, "\r3.\w Velocidad\r:\y +%d", g_AmuletCustom[id][acSpeed]);
		oldmenu_additem(4, 4, "\r4.\w Gravedad\r:\y +%d", g_AmuletCustom[id][acGravity]);
		oldmenu_additem(5, 5, "\r5.\w Daño\r:\y +%d^n", g_AmuletCustom[id][acDamage]);

		oldmenu_additem(6, 6, "\r6.\w Multiplicador de AmmoPacks\r:\y +%0.2f^n", g_AmuletCustom[id][acMultAmmoPacks]);

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__AmuletCustom(const id, const item) {
	if(!item) {
		showMenu__Character(id);
		return;
	}

	if(g_AmuletCustomCreated[id]) {
		switch(item) {
			case 1..7: {
				clientPrintColor(id, _, "Por ahora solo puedes visualizar tu amuleto, en las próximas actualizaciones podrás modificar los valores del mismo.");
				showMenu__AmuletCustom(id);
			} case 9: {
				showMenu__AmuletCustomDelete(id);
			}
		}
	} else {
		switch(item) {
			case 1: {
				client_cmd(id, "messagemode INGRESAR_NOMBRE_AMULETO");
				return;
			} case 2: {
				if(g_AmuletCustom[id][acHealth] < 5) {
					++g_AmuletCustom[id][acHealth];
					g_AmuletCustomCost[id] += 2;
				} else {
					g_AmuletCustom[id][acHealth] = 1;
					g_AmuletCustomCost[id] -= 8;
				}
			} case 3: {
				if(g_AmuletCustom[id][acSpeed] < 5) {
					++g_AmuletCustom[id][acSpeed];
					g_AmuletCustomCost[id] += 3;
				} else {
					g_AmuletCustom[id][acSpeed] = 1;
					g_AmuletCustomCost[id] -= 12;
				}
			} case 4: {
				if(g_AmuletCustom[id][acGravity] < 5) {
					++g_AmuletCustom[id][acGravity];
					g_AmuletCustomCost[id] += 3;
				} else {
					g_AmuletCustom[id][acGravity] = 1;
					g_AmuletCustomCost[id] -= 12;
				}
			} case 5: {
				if(g_AmuletCustom[id][acDamage] < 5) {
					++g_AmuletCustom[id][acDamage];
					g_AmuletCustomCost[id] += 5;
				} else {
					g_AmuletCustom[id][acDamage] = 1;
					g_AmuletCustomCost[id] -= 20;
				}
			} case 6: {
				if(g_AmuletCustom[id][acMultAmmoPacks] < 1.4) {
					g_AmuletCustom[id][acMultAmmoPacks] += 0.2;
					g_AmuletCustomCost[id] += 4;
				} else {
					g_AmuletCustom[id][acMultAmmoPacks] = 0.0;
					g_AmuletCustomCost[id] -= 28;
				}
			}
		}

		showMenu__AmuletCustom(id);
	}
}

public showMenu__AmuletCustomDelete(const id) {
	if(!g_AmuletCustomCreated[id]) {
		return;
	}

	oldmenu_create("\yELIMINAR AMULETO^n\wNombre del amuleto\r:\y %s", "menu__AmuletCustomDelete", g_AmuletCustomName[id]);

	oldmenu_additem(-1, -1, "\w¿Estás seguro que quieres eliminar tu amuleto?");
	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No^n");

	oldmenu_additem(-1, -1, "\yNOTA IMPORTANTE\r:\w Queda bajo tu responsabilidad eliminar^nel amuleto, si por alguna razón te arrepientes^nvisita tu panel de control y consulta la devolusión del mismo^nte costarà \yDIAMANTES\w para poder devolver tu amuleto");
	oldmenu_display(id);
}

public menu__AmuletCustomDelete(const id, const item) {
	if(!g_AmuletCustomCreated[id]) {
		return;
	}

	switch(item) {
		case 1: {
			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_amulets_custom` SET `active`='0' WHERE (`acc_id`='%d');", dg_get_user_acc_id(id));

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 34511);
			} else {
				SQL_FreeHandle(sqlQuery);

				g_AmuletCustomCreated[id] = 0;

				clientPrintColor(id, _, "Has eliminado tu amuleto personalizado con éxito.");
				showMenu__AmuletCustom(id, 1);
			}
		} case 2: {
			showMenu__AmuletCustom(id);
		}
	}
}

showMenu__Amulets(const id, const amulet=-1, const amulet_name[]="") {
	if(amulet == -1 && !amulet_name[0]) {
		new sPF[16];
		addDot(g_Point[id][P_FRAGMENT], sPF, charsmax(sPF));

		oldmenu_create("\yAMULETOS^n\wpF\r:\y %s", "@menu__Amulets", sPF);

		if(g_Point[id][P_FRAGMENT] >= 30) {
			oldmenu_additem(1, 1, "\r1.\w Crear amuleto");
		} else {
			oldmenu_additem(-1, -1, "\d1. Crear amuleto");
		}

		if(g_Point[id][P_FRAGMENT] >= 75) {
			oldmenu_additem(2, 2, "\r2.\w Crear amuleto \y[PRO]\w");
		} else {
			oldmenu_additem(-1, -1, "\d2. Crear amuleto \r[PRO]\d");
		}

		new i;
		for(i = 0; i < 5; ++i) {
			if(g_AmuletName[id][i][0]) {
				oldmenu_additem((i + 3), (i + 3), "\w%s%s", g_AmuletName[id][i], ((g_AmuletEquip[id] == i) ? " \y(EQUIPADO)" : (g_AmuletNextEquip[id] == i) ? " \y(ELEGIDO)" : ""));
			}
		}

		oldmenu_additem(0, 0, "^n\r0.\w Volver");
		oldmenu_display(id);
	} else {
		oldmenu_create("\yAMULETOS^n\w%s", "@menu__AmuletsIn", amulet_name);

		if(g_AmuletEquip[id] == amuleto) {
			oldmenu_additem(1, 1, "\r1.\w Desequipar amuleto^n");
		} else {
			oldmenu_additem(1, 1, "\r1.\w Equipar amuleto^n");
		}
	}
}

@menu__Amulets(const id, const item) {
	if(!item) {
		showMenu__Character(id);
		return;
	}

	switch(item) {
		case 1: {

		} case 2: {

		} case 3: {

		}
	}
}

@menu__AmuletsIn(const id, const item) {
	
}

showMenu__Benefit(const id) {
	if((get_user_flags(id) & ADMIN_RESERVATION)) {
		clientPrintColor(id, _, "Ya eres !gVIP!y. No es necesario que utilices esta función.");

		showMenu__Game(id);
		return;
	} else if(g_Benefit_Timestamp[id] == 1) {
		clientPrintColor(id, _, "Tu beneficio gratuito se ha vencido.");
		clientPrintColor(id, _, "Si quieres disfrutar de beneficios en el servidor, visita !t%s!y.", __PLUGIN_COMMUNITY_FORUM_SHOP);

		showMenu__Game(id);
		return;
	}

	oldmenu_create("\yBENEFICIO GRATUITO", "menu__Benefit");

	new iSysTime = get_arg_systime();

	if(g_Benefit_Timestamp[id] > iSysTime) {
		oldmenu_additem(-1, -1, "\wTu beneficio está activado");
		oldmenu_additem(-1, -1, "\wSe vencerá el día \y%s\w^n", getUnixToTime(g_Benefit_Timestamp[id]));
		
		oldmenu_additem(-1, -1, "\wUna vez que acabe tu beneficio, no");
		oldmenu_additem(-1, -1, "\wpodrás volver a utilizarlo en tu personaje.");
		oldmenu_additem(-1, -1, "\wSi quieres volver a tener los beneficios, visita");
		oldmenu_additem(-1, -1, "\wla sección de ventas de la comunidad en\r:");
		oldmenu_additem(-1, -1, "\y%s\w^n", __PLUGIN_COMMUNITY_FORUM_SHOP);
	} else {
		oldmenu_additem(-1, -1, "\wEste beneficio gratuito se le otorgará al jugador");
		oldmenu_additem(-1, -1, "\wpor \y7 DÍAS\w los multiplicadores de un VIP.");
		oldmenu_additem(-1, -1, "\wsolamente tiene que seguir los pasos para poder");
		oldmenu_additem(-1, -1, "\wacreditar dichos beneficios por ese plazo de tiempo.^n");

		oldmenu_additem(-1, -1, "\wUna vez activado el beneficio gratuito, podrás tener");
		oldmenu_additem(-1, -1, "\wlas siguientes mejoras:");
		oldmenu_additem(-1, -1, "\r - \wMultiplicador de APs \y+x1.0\w");
		oldmenu_additem(-1, -1, "\r - \wMultiplicador de Puntos \y+x1\w");
		oldmenu_additem(-1, -1, "\wEstos son los beneficios básicos y los que otorga un");
		oldmenu_additem(-1, -1, "\wjugador \yVIP\w o superior normalmente; no otorga \rSLOT RESERVADO\w.^n");

		oldmenu_additem(1, 1, "\r1.\w Activar ahora");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Benefit(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	} else if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit_Timestamp[id] == 1) {
		return;
	}

	switch(item) {
		case 1: {
			new iSysTime = get_arg_systime();

			if(g_Benefit_Timestamp[id] <= iSysTime) {
				g_Benefit_Timestamp[id] = (iSysTime + 604800);

				new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE `zp9_pjs` SET `benefit_timestamp`='%d' WHERE (`acc_id`='%d');", g_Benefit_Timestamp[id], dg_get_user_acc_id(id));

				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 123122);
				} else {
					SQL_FreeHandle(sqlQuery);

					clientPrintColor(id, _, "Has activado tu beneficio gratuito por !g7 DÍAS!y. Disfrutalo :).");
					showMenu__Benefit(id);
				}
			} else {
				clientPrintColor(id, _, "Ya has acreditado tu beneficio gratuito.");
				showMenu__Benefit(id);
			}
		}
	}
}

dropHeadZombie(const id) {
	new iEnt = rg_create_entity("info_target");

	if(is_nullent(iEnt)) {
		return;
	}

	set_entvar(iEnt, var_classname, __ENT_CLASSNAME_HEADZOMBIE);
	set_entvar(iEnt, var_model, __MODEL_HEADZOMBIE);
	set_entvar(iEnt, var_modelindex, g_ModelIndex_HeadZombie);
	set_entvar(iEnt, var_solid, SOLID_TRIGGER);
	set_entvar(iEnt, var_movetype, MOVETYPE_TOSS);

	new Float:vecOrigin[3];
	new Float:vecVelocity[3];

	getDropOrigin(id, vecOrigin, 0);
	set_entvar(iEnt, var_origin, vecOrigin);

	velocity_by_aim(id, 300, vecVelocity);
	set_entvar(iEnt, var_velocity, vecVelocity);

	set_entvar(iEnt, var_mins, Float:{-6.0, -6.0, -6.0});
	set_entvar(iEnt, var_maxs, Float:{6.0, 6.0, 6.0});

	set_entvar(iEnt, var_euser2, id);

	new Float:vecColor[3];
	new iWhite = random_num(1, 25);
	new iYellow = random_num(1, 10);
	new iRed = random_num(0, 1);
	new iGreen = random_num(0, 1);
	new iHeadColor;

	if(iWhite == 1) {
		vecColor = Float:{255.0, 255.0, 255.0};
		iHeadColor = HEADZOMBIE_WHITE;
	} else if(iYellow == 1 || iYellow == 10) {
		vecColor = Float:{255.0, 255.0, 0.0};
		iHeadColor = HEADZOMBIE_YELLOW;
	} else if(iRed) {
		vecColor = Float:{255.0, 0.0, 0.0};
		iHeadColor = HEADZOMBIE_RED;
	} else if(!iGreen) {
		vecColor = Float:{0.0, 255.0, 0.0};
		iHeadColor = HEADZOMBIE_GREEN;
	} else {
		vecColor = Float:{0.0, 0.0, 255.0};
		iHeadColor = HEADZOMBIE_BLUE;
	}

	utilSetRendering(iEnt, kRenderFxGlowShell, vecColor, kRenderNormal, 16.0);
	set_entvar(iEnt, var_euser4, iHeadColor);

	SetTouch(iEnt, "@touch__HeadZombie");
}

@touch__HeadZombie(const ent, const id) {
	if(is_nullent(ent)) {
		return;
	}

	if(!is_user_alive(id)) {
		return;
	}

	if(g_Class[id] == CLASS_ZOMBIE || g_Class[id] == CLASS_NEMESIS || g_Class[id] == CLASS_ASSASSIN || g_Class[id] == CLASS_GRUNT) {
		return;
	}

	new Float:flHalfLifeTime = halflife_time();

	if((flHalfLifeTime - g_HeadZombie_LastTouch[id]) < 2.5) {
		return;
	}

	g_HeadZombie_LastTouch[id] = flHalfLifeTime;

	new iHeadColor = get_entvar(ent, var_euser4);

	++g_HeadZombie[id][iHeadColor];
	clientPrintColor(id, _, "Agarraste una cabeza zombie %s.", __HEADZOMBIE_COLORS_MIN[iHeadColor]);

	g_HeadZombie_LastTouch[id] = 0.0;

	if(g_HeadZombie[id][HEADZOMBIE_RED] == 100) {
		setAchievement(id, HEAD_100_RED);
	}

	if(g_HeadZombie[id][HEADZOMBIE_GREEN] == 75) {
		setAchievement(id, HEAD_75_GREEN);
	}

	if(g_HeadZombie[id][HEADZOMBIE_BLUE] == 50) {
		setAchievement(id, HEAD_50_BLUE);
	}

	if(g_HeadZombie[id][HEADZOMBIE_YELLOW] == 25) {
		setAchievement(id, HEAD_25_YELLOW);
	}

	if(g_HeadZombie[id][HEADZOMBIE_WHITE] == 5) {
		setAchievement(id, CINCO_DE_LAS_BLANCAS);
	}

	if(g_HeadZombie[id][HEADZOMBIE_RED] && g_HeadZombie[id][HEADZOMBIE_GREEN] && g_HeadZombie[id][HEADZOMBIE_BLUE] && g_HeadZombie[id][HEADZOMBIE_YELLOW] && g_HeadZombie[id][HEADZOMBIE_WHITE]) {
		setAchievement(id, COLORIDO);
	}

	rh_emit_sound2(ent, 0, CHAN_VOICE, __SOUND_HUMAN_HEADZOMBIE_PICKUP);
	remove_entity(ent);
}

showMenu__HeadZombies(const id) {
	oldmenu_create("\yCABEZAS ZOMBIES", "menu__HeadZombies");

	new i;
	new j;

	for(i = 0, j = 1; i < structIdHeadZombies; ++i, ++j) {
		if(g_HeadZombie[id][i]) {
			oldmenu_additem(j, i, "\r%d.\w Abrir cabeza zombie %s\r:\y %d", j, __HEADZOMBIE_COLORS_MIN[i], g_HeadZombie[id][i]);
		} else {
			oldmenu_additem(-1, -1, "\d%d. No tienes cabezas %s%s para abrir", j, __HEADZOMBIE_COLORS_MIN[i], ((i == HEADZOMBIE_BLUE) ? "es" : "s"));
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HeadZombies(const id, const item, const value) {
	if(!item) {
		showMenu__Game(id);
		return;
	} else if(g_HeadZombie[id][value] <= 0) {
		clientPrintColor(id, _, "No tienes cabezas zombies para abrir.");

		showMenu__HeadZombies(id);
		return;
	}

	new iPercent = random_num(1, 100);
	new sMessage[64];

	sMessage[0] = EOS;

	switch(value) {
		case HEADZOMBIE_RED: {
			if(iPercent <= 80) {
				new iReward = getConversion(id, random_num(5, 20));
				new sReward[16];

				addDot(iReward, sReward, charsmax(sReward));
				formatex(sMessage, charsmax(sMessage), "La cabeza zombie roja tenía !g%s Ammo Packs!y.", sReward);

				addAmmoPacks(id, iReward);

				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_GREEN: {
			if(iPercent <= 40) {
				new iLevel = random_num(1, 3);
				new iOk;

				if((g_Level[id] + iLevel) > MAX_LEVELS) {
					g_Level[id] = MAX_LEVELS;
					iOk = 1;
				} else {
					g_Level[id] += iLevel;
					iOk = 0;
				}

				checkAmmoPacksEquation(id);

				if(iOk) {
					clientPrintColor(id, _, "La cabeza zombie verde te ha dado la cantidad faltante de niveles para subir de reset.");
				} else {
					clientPrintColor(id, _, "La cabeza zombie verde tenía !g%d nivel%s!y.", iLevel, ((iLevel != 1) ? "es" : ""));
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_BLUE: {
			if(g_EventModes) {
				clientPrintColor(id, _, "No puedes abrir cabezas azules mientras haya un mini evento activado.");

				showMenu__HeadZombies(id);
				return;
			} else if(!get_member_game(m_bGameStarted) || get_member_game(m_bRoundTerminating)) {
				clientPrintColor(id, _, "Las cabezas zombie azules solo se pueden romper antes de que comience un modo.");

				showMenu__HeadZombies(id);
				return;
			}

			if(iPercent <= 60) {
				new iItemRandom = random_num(1, 4);

				switch(iItemRandom) {
					case 1: {
						buyExtraItem(id, EXTRA_ITEM_NVISION, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gVisión nocturna!y.");
					} case 2: {
						buyExtraItem(id, EXTRA_ITEM_UNLIMITED_CLIP, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gBalas infinitas!y.");
					} case 3: {
						buyExtraItem(id, EXTRA_ITEM_PRESICION_PERFECT, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gPrecisión perfecta!y.");
					} case 4: {
						rg_set_user_armor(id, 100, ARMOR_KEVLAR);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !g+100 de Chaleco!y.");
					}
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_YELLOW: {
			if(iPercent <= 20) {
				new iRewardPoint = random_num(1, 3);
				new iReward = random_num(1, 5);

				switch(iRewardPoint) {
					case 1: {
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pH!y.", iReward);
						g_Point[id][P_HUMAN] += iReward;
					} case 2: {
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pZ!y.", iReward);
						g_Point[id][P_ZOMBIE] += iReward;
					} case 3: {
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pF!y.", iReward);
						g_Point[id][P_FRAGMENT] += iReward;
					}
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_WHITE: {
			if(g_EventModes) {
				clientPrintColor(id, _, "No puedes abrir cabezas blancas mientras haya un mini evento activado.");

				showMenu__HeadZombies(id);
				return;
			} else if(!get_member_game(m_bGameStarted) || get_member_game(m_bRoundTerminating)) {
				clientPrintColor(id, _, "Las cabezas zombies blancas solo se pueden romper antes de que comience un modo.");

				showMenu__HeadZombies(id);
				return;
			}

			new Float:flGameTime = get_gametime();

			if(g_HeadZombie_GameTime > flGameTime) {
				new Float:flRest = (g_HeadZombie_GameTime - flGameTime);

				clientPrintColor(id, _, "Debes esperar !g%0.2f segundo%s!y para volver a abrir una cabeza zombie blanca.", flRest, ((flRest != 1.0) ? "s" : ""));
				
				showMenu__HeadZombies(id);
				return;
			}

			if(getUsersAlive() < 20) {
				clientPrintColor(id, _, "Tiene que haber !g20 o más!y jugadores vivos para romper estas cabezas.");
				
				showMenu__HeadZombies(id);
				return;
			}

			if(iPercent <= 5) {
				iPercent = random_num(1, 5);

				switch(iPercent) {
					case 1: {
						clientPrintColor(0, _, "!t%n!y abrió una cabeza zombie Violeta grande y le salió !gSURVIVOR!y", id);
						changeGameMode(MODE_SURVIVOR, id);
					} case 2: {
						clientPrintColor(0, _, "!t%n!y abrió una cabeza zombie Violeta grande y le salió !gWESKER!y", id);
						changeGameMode(MODE_WESKER, id);
					} case 3: {
						clientPrintColor(0, _, "!t%n!y abrió una cabeza zombie Violeta grande y le salió !gSNIPER!y", id);
						changeGameMode(MODE_SNIPER, id);
					} case 4: {
						clientPrintColor(0, _, "!t%n!y abrió una cabeza zombie Violeta grande y le salió !gNEMESIS!y", id);
						changeGameMode(MODE_NEMESIS, id);
					} case 5: {
						clientPrintColor(0, _, "!t%n!y abrió una cabeza zombie Violeta grande y le salió !gASSASSIN!y", id);
						changeGameMode(MODE_ASSASSIN, id);
					}
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
				g_HeadZombie_GameTime = (get_gametime() + 600.0);
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		}
	}

	--g_HeadZombie[id][value];

	if(sMessage[0]) {
		clientPrintColor(id, _, sMessage);

		if(g_HeadZombie_BadLuckBrian[id] == 10) {
			setAchievement(id, BAD_LUCKY_BRIAN);
		}
	}

	showMenu__HeadZombies(id);
}

@HandleForcingCvarChange(const cvar, const old_value[], const new_value[]) {
	new i;
	for(i = 0; i < sizeof(__IMMUTABLE_CVARS); ++i) {
		if(g_ImmutableCVars[i] != cvar) {
			continue;
		}

		if(equal(new_value, __IMMUTABLE_CVARS[i][1])) {
			continue;
		}

		set_pcvar_string(cvar, __IMMUTABLE_CVARS[i][1]);
		break;
	}
}

@message__Money(const msg_id, const msg_dest, const msg_player) {
	if(get_msg_arg_int(2) == 0) {
		return PLUGIN_CONTINUE;
	}

	return PLUGIN_HANDLED;
}

@message__RoundTime(const msg_id, const msg_dest, const msg_player) {
	if(!g_IsWarmUp && !(get_member_game(m_bGameStarted) && get_member_game(m_bFreezePeriod))) {
		return PLUGIN_CONTINUE;
	}

	if(!is_entity(msg_player)) {
		return PLUGIN_CONTINUE;
	}

	set_member(msg_player, m_iHideHUD, (get_member(msg_player, m_iHideHUD) | HIDEHUD_TIMER));
	return PLUGIN_HANDLED;
}

@message__ScreenFade(const msg_id, const msg_dest, const msg_player) {
	return PLUGIN_HANDLED;
}

@message__TextMsg(const msg_id, const msg_dest, const msg_player) {
	new sTextMsg[32];
	new iValue;

	if(get_msg_args() == 5 && (get_msg_argtype(5) == ARG_STRING)) {
		get_msg_arg_string(5, sTextMsg, charsmax(sTextMsg));
		
		if(equal(sTextMsg, "#Fire_in_the_hole")) {
			return PLUGIN_HANDLED;
		}
	} else if(get_msg_args() == 6 && (get_msg_argtype(6) == ARG_STRING)) {
		get_msg_arg_string(6, sTextMsg, charsmax(sTextMsg));
		
		if(equal(sTextMsg, "#Fire_in_the_hole")) {
			return PLUGIN_HANDLED;
		}
	}

	get_msg_arg_string(2, sTextMsg, charsmax(sTextMsg));

	if(TrieGetCell(g_tBlockedTextMsg, sTextMsg, iValue)) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

@message__SendAudio(const msg_id, const msg_dest, const msg_player) {
	new sSendAudio[32];
	new iValue;

	get_msg_arg_string(2, sSendAudio, charsmax(sSendAudio));

	if(TrieGetCell(g_tBlockedSendAudio, sSendAudio, iValue)) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}