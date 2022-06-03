#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <sqlx>
#include <fun>
#include <xs>
#include <curl>
#include <reapi>

#include <dg>

#pragma semicolon 1

/*
	Cambiar funcionalidades en el guardado y cargado de datos
	Hacer un sistema para que balancee siempre los equipos en todos los modos.
	Agregar una recompensa global en armageddon y mega armageddon. Si gana el equipo que gana, gana puntos segun la cantidad de vivos todos.

	Item Extra: Bomba humana
	 - Dentro de los próximos 5 segundos, una vez cumplidos, el humano cuando muere explota en un radio de 250.0 y mata a todos los zombies que están alrededor y revive.

	Mejorar el reinicio de habilidades
*/

new const __PLUGIN_NAME[] = "Zombie Plague";
new const __PLUGIN_VERSION[] = "v8.2.4a";
new const __PLUGIN_UPDATE[] = "";
new const __PLUGIN_UPDATE_VERSION[] = "";
new const __PLUGIN_AUTHOR[] = "Atsel. & Martina.";

const MAX_SERVER_MAP = 50;
const MAX_FMT_VOTEMAP_MENU = 512;
const MAX_VOTEMAP = 8;
const MAX_STRING_PASSWORD = 34;
const MAX_STRING_PASSWORD_LIMIT = 20;
const MAX_STRING_CODE = 12;
const MAX_BAN_ACCOUNT = 3; // Máximo de baneos que puede recibir un usuario por cuenta, al superar el máximo, será baneado permanentemente de forma automática
const MAX_XP = 2000000000;
const MAX_LEVEL = 300;
const Float:DIV_DAMAGE = 100.0;
const REWARD_XP_IN_DUEL_FINAL = 10000000; // Cantidad de XP que otorga por cada humano matado en el modo DUELO FINAL
const REWARD_XP_IN_INFECTION = 1000000; // Cantidad de XP que otorga por cada vez que mueres siendo Zombie

const HUMAN_HEALTH_BASE = 100;
const HUMAN_HEALTH_BASE_MAX = 400;
const Float:HUMAN_SPEED_BASE = 240.0;
const Float:HUMAN_SPEED_BASE_MULT = 0.3;
const Float:HUMAN_SPEED_BASE_MAX = 330.0;
const Float:HUMAN_GRAVITY_BASE = 1.0;
const Float:HUMAN_GRAVITY_BASE_MULT = 0.002;
const Float:HUMAN_GRAVITY_BASE_MAX = 0.4;
const Float:HUMAN_GRAVITY_MAX = 0.1;
const Float:HUMAN_DAMAGE_PERCENT_BASE = 0.0;
const Float:HUMAN_DAMAGE_PERCENT_BASE_MULT = 10.0;
const HUMAN_PER_LEVEL = 100;

const ZOMBIE_HEALTH_BASE = 4000000;
const ZOMBIE_HEALTH_BASE_MAX = 12000000;
const Float:ZOMBIE_SPEED_BASE = 250.0;
const Float:ZOMBIE_SPEED_BASE_MULT = 0.3;
const Float:ZOMBIE_SPEED_BASE_MAX = 340.0;
const Float:ZOMBIE_GRAVITY_BASE = 1.0;
const Float:ZOMBIE_GRAVITY_BASE_MULT = 0.002;
const Float:ZOMBIE_GRAVITY_BASE_MAX = 0.4;
const Float:ZOMBIE_GRAVITY_MAX = 0.1;
const ZOMBIE_PER_LEVEL = 100;

const PDATA_SAFE = 2;
const OFFSET_LINUX_WEAPONS = 4;
const OFFSET_LINUX = 5;
const OFFSET_LEAP = 8;
const OFFSET_WEAPONOWNER = 41;
const OFFSET_ID	= 43;
const OFFSET_KNOWN = 44;
const OFFSET_NEXT_PRIMARY_ATTACK = 46;
const OFFSET_NEXT_SECONDARY_ATTACK = 47;
const OFFSET_TIME_WEAPON_IDLE = 48;
const OFFSET_PRIMARY_AMMO_TYPE = 49;
const OFFSET_CLIPAMMO = 51;
const OFFSET_IN_RELOAD = 54;
const OFFSET_IN_SPECIAL_RELOAD = 55;
const OFFSET_ACTIVITY = 73;
const OFFSET_SILENT	= 74;
const OFFSET_NEXT_ATTACK = 83;
const OFFSET_PAINSHOCK = 108;
const OFFSET_JOINSTATE = 121;
const OFFSET_CSMENUCODE = 205;
const OFFSET_BUYZONE = 235;
const OFFSET_FLASHLIGHT_BATTERY = 244;
const OFFSET_BUTTON_PRESSED = 246;
const OFFSET_LONG_JUMP = 356;
const OFFSET_ACTIVE_ITEM = 373;
const OFFSET_AMMO_PLAYER_SLOT0 = 376;
const OFFSET_AWM_AMMO = 377;
const OFFSET_SCOUT_AMMO = 378;
const OFFSET_PARA_AMMO = 379;
const OFFSET_FAMAS_AMMO = 380;
const OFFSET_M3_AMMO = 381;
const OFFSET_USP_AMMO = 382;
const OFFSET_FIVESEVEN_AMMO = 383;
const OFFSET_DEAGLE_AMMO = 384;
const OFFSET_P228_AMMO = 385;
const OFFSET_GLOCK_AMMO = 386;
const OFFSET_FLASH_AMMO = 387;
const OFFSET_HE_AMMO = 388;
const OFFSET_SMOKE_AMMO = 389;
const OFFSET_C4_AMMO = 390;
const OFFSET_CSDEATHS = 444;

const HIDE_HUDS = (1<<5)|(1<<3);
const UNIT_SECOND = (1<<12);
const UNIT_SECOND_FLESHPOUND = (1<<14);
const DMG_HEGRENADE = (1<<24);
const OFF_IMPULSE_FLASHLIGHT = 100;
const OFF_IMPULSE_SPRAY = 201;
const STEPTIME_SILENT = 999;
const FFADE_IN = 0x0000;
const FFADE_OUT = 0x0001;
const FFADE_STAYOUT = 0x0004;

const EV_ID_SPEC = EV_INT_iuser2;
const EV_ENT_FLARE = EV_ENT_euser3;
const EV_NADE_TYPE = EV_INT_flTimeStepSound;
const EV_FLARE_COLOR = EV_VEC_punchangle;
const EV_FLARE_DURATION = EV_INT_flSwimTime;

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE);
const WEAPONS_SILENT_BIT_SUM = (1<<CSW_USP)|(1<<CSW_M4A1);
const WEAPONS_HEAVY_BIT_SUM = (1<<CSW_M3)|(1<<CSW_XM1014)|(1<<CSW_M249);
const ZOMBIE_ALLOWED_WEAPONS_BIT_SUM = (1<<CSW_KNIFE)|(1<<CSW_MAC10)|(1<<CSW_AK47)|(1<<CSW_HEGRENADE);

enum _:structIdTasks (+= 236877) {
	TASK_CHECK_BUY = 54276,
	TASK_CHECK_ACHIEVEMENTS,
	TASK_CHECK_HATS,
	TASK_MESSAGE_VIP,
	TASK_MESSAGE_VINC,
	TASK_PLAYED_TIME,
	TASK_SAVE,
	TASK_SPAWN,
	TASK_BURNING_FLAME,
	TASK_FREEZE,
	TASK_MADNESS,
	TASK_HEALTH_REGENERATION,
	TASK_HEALTH_IMMUNITY,
	TASK_POWER_MODE,
	TASK_IMMUNITY,
	TASK_HEALTH_REGENERATION_ROTATE,
	TASK_GRUNT_AIMING,
	TASK_GRUNT_GLOW,
	TASK_IMMUNITY_GG,
	TASK_CONVERT_ZOMBIE,
	TASK_NVISION,
	TASK_TUTOR_TEXT,
	TASK_DRUG,
	TASK_GRAB,
	TASK_GRAB_PRETHINK,

	TASK_VOTEMAP,
	TASK_VOTEMAP_END,
	TASK_CHANGEMAP_PRE,
	TASK_CHANGEMAP,
	TASK_VIRUST,
	TASK_START_MODE,
	TASK_ZOMBIE_BACK,
	TASK_MODE_INFECTION,
	TASK_MODE_ARMAGEDDON,
	TASK_MODE_MEGA_ARMAGEDDON,
	TASK_MODE_MEGA_GUNGAME,
	TASK_MODE_DUEL_FINAL,
	TASK_MODE_CABEZON,
	TASK_MODE_FLESHPOUND,
	TASK_SAVE_ALL
};

enum _:structIdNades (+= 1111) {
	NADE_TYPE_INFECTION = 1111,
	NADE_TYPE_FIRE,
	NADE_TYPE_FROST,
	NADE_TYPE_FLARE,
	NADE_TYPE_DRUG,
	NADE_TYPE_SUPERNOVA,
	NADE_TYPE_BUBBLE,
	NADE_TYPE_KILL,
	NADE_TYPE_PIPE,
	NADE_TYPE_ANTIDOTE
};

enum _:structIdModes {
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_PLAGUE,
	MODE_SYNAPSIS,
	MODE_MEGA_SYNAPSIS,
	MODE_ARMAGEDDON,
	MODE_MEGA_ARMAGEDDON,
	MODE_GUNGAME,
	MODE_MEGA_GUNGAME,
	MODE_DRUNK,
	MODE_MEGA_DRUNK,
	MODE_L4D2,
	MODE_DUEL_FINAL,
	MODE_SURVIVOR,
	MODE_WESKER,
	MODE_LEATHERFACE,
	MODE_TRIBAL,
	MODE_SNIPER,
	MODE_NEMESIS,
	MODE_CABEZON,
	MODE_ANNIHILATOR,
	MODE_FLESHPOUND,
	MODE_GRUNT
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

enum _:structIdDuelFinal {
	DF_ALL = 0,
	DF_QUARTER,
	DF_SEMIFINAL,
	DF_FINAL,
	DF_FINISH
};

enum _:structIdDuelFinalType {
	DF_TYPE_NONE = 0,
	DF_TYPE_KNIFE,
	DF_TYPE_AWP,
	DF_TYPE_HE,
	DF_TYPE_ONLY_HEAD
};

enum _:structIdExtraItemsTeam {
	EXTRA_ITEM_TEAM_HUMAN = 0,
	EXTRA_ITEM_TEAM_ZOMBIE
};

enum _:structIdExtraItems {
	EXTRA_ITEM_NVISION = 0,
	EXTRA_ITEM_LJ_H,
	EXTRA_ITEM_INVISIBILITY,
	EXTRA_ITEM_UNLIMITED_CLIP,
	EXTRA_ITEM_PRESICION_PERFECT,
	EXTRA_ITEM_KILL_BOMB,
	EXTRA_ITEM_PIPE_BOMB,
	EXTRA_ITEM_ANTIDOTE_BOMB,

	EXTRA_ITEM_ANTIDOTE,
	EXTRA_ITEM_ZOMBIE_MADNESS,
	EXTRA_ITEM_INFECTION_BOMB,
	EXTRA_ITEM_LJ_Z,
	EXTRA_ITEM_REDUCE_DAMAGE,
	EXTRA_ITEM_PETRIFICATION
};

enum _:structIdDifficultsClasses {
	DIFFICULT_CLASS_SURVIVOR = 0,
	DIFFICULT_CLASS_WESKER,
	DIFFICULT_CLASS_LEATHERFACE,
	DIFFICULT_CLASS_NEMESIS,
	DIFFICULT_CLASS_CABEZON,
	DIFFICULT_CLASS_ANNIHILATOR
};

enum _:structIdDifficults {
	DIFFICULT_NORMAL = 0,
	DIFFICULT_HARD,
	DIFFICULT_VERY_HARD,
	DIFFICULT_EXPERT
};

enum _:structIdPoints {
	P_HUMAN = 0,
	P_ZOMBIE,
	P_LEGACY,
	P_MONEY,
	P_DIAMONDS,
	P_RESET
};

enum _:structIdHabsClasses {
	HAB_CLASS_HUMAN = 0,
	HAB_CLASS_ZOMBIE,
	HAB_CLASS_S_SURVIVOR,
	HAB_CLASS_S_WESKER,
	HAB_CLASS_S_LEATHERFACE,
	HAB_CLASS_S_NEMESIS,
	HAB_CLASS_S_FLESHPOUND,
	HAB_CLASS_EXTRAS,
	HAB_CLASS_LEGENDARY,
	HAB_CLASS_ROTATTE,
	HAB_CLASS_TRADE,
	HAB_CLASS_RESET
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
	HAB_Z_RESISTANCE_FIRE,
	HAB_Z_RESISTANCE_FROST,
	HAB_Z_COMBO_ZOMBIE,

	HAB_S_S_HEALTH,
	HAB_S_S_DAMAGE,
	HAB_S_S_SPEED_WEAPON,
	HAB_S_S_EXTRA_BOMB,
	HAB_S_S_EXTRA_IMMUNITY,

	HAB_S_W_ULTRA_LASER,
	HAB_S_W_COMBO,

	HAB_S_L_TELEPORT,
	HAB_S_L_COMBO,
	HAB_S_L_DAMAGE,

	HAB_S_NEM_HEALTH,
	HAB_S_NEM_DAMAGE,
	HAB_S_NEM_BAZOOKA_FOLLOW,
	HAB_S_NEM_BAZOOKA_RADIUS,
	HAB_S_NEM_BAZOOKA_EXTRA,

	HAB_S_FLESHPOUND_SLOWER_RADIUS,
	HAB_S_FLESHPOUND_SLOWER_BACK,

	HAB_E_DURATION_BUBBLE,
	HAB_E_DURATION_MADNESS,
	HAB_E_DURATION_COMBO,
	HAB_E_CHANGE_BOMBS,

	HAB_L_UPGRADE_HUMAN_DAMAGE,
	HAB_L_UPGRADE_ZOMBIE_HEALTH,
	HAB_L_MULT_AMMOPACKS,
	HAB_L_MULT_XP,
	HAB_L_RESET_EXTRA_ITEMS_COST,
	HAB_L_WEAPON_LEVEL,
	HAB_L_VIGOR,
	HAB_L_RESPAWN,

	HAB_S_S_WEAPON,
	HAB_L_XP_MULT_IN_COMBO
};

enum _:structIdHabsRotate {
	HAB_ROTATE_ULTIMAS_PALABRAS = 0,
	HAB_ROTATE_SURVIVOR_DAMEGOUS,
	HAB_ROTATE_NEMESIS_VIDEIGOUS,
	HAB_ROTATE_INFINITAMENTE_INFINITO,
	HAB_ROTATE_PRECISAMENTE_PERFECTO,
	HAB_ROTATE_SPARTAN,
	HAB_ROTATE_REGENERATION,
	HAB_ROTATE_PORTA_CUCHILLOS,
	HAB_ROTATE_SECUNDARIAS_UTILES,
	HAB_ROTATE_SOPA_DE_CEREBROS,
	HAB_ROTATE_VAMPIRISMO,
	HAB_ROTATE_CABEZA_DURA,
	HAB_ROTATE_MULTIPLICANDO,
	HAB_ROTATE_PRECIOS_CUIDADOS,
	HAB_ROTATE_BLINDAJE_ASESINO
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
	BETA_TESTER_DIA_1 = 0,
	CUENTA_PAR,
	CUENTA_IMPAR,
	LA_MEJOR_OPCION,
	UNA_DE_LAS_MEJORES,
	MI_PREFERIDA,
	LA_MEJOR,
	PRIMERO_LA_MEJOR_OPCION,
	PRIMERO_UNA_DE_LAS_MEJORES,
	PRIMERO_MI_PREFERIDA,
	PRIMERO_LA_MEJOR,
	LA_MEJOR_OPCION_x5,
	UNA_DE_LAS_MEJORES_x5,
	MI_PREFERIDA_x5, LA_MEJOR_x5,
	LA_MEJOR_OPCION_x10,
	UNA_DE_LAS_MEJORES_x10,
	MI_PREFERIDA_x10,
	LA_MEJOR_x10,
	LA_MEJOR_OPCION_x15,
	UNA_DE_LAS_MEJORES_x15,
	MI_PREFERIDA_x15,
	LA_MEJOR_x15,
	LA_MEJOR_OPCION_x20,
	UNA_DE_LAS_MEJORES_x20,
	MI_PREFERIDA_x20,
	LA_MEJOR_x20,
	BOMBA_FALLIDA,
	VIRUS,
	ENTRENANDO,
	ESTOY_MUY_SOLO,
	FOREVER_ALONE,
	CREO_QUE_TENGO_UN_PROBLEMA,
	SOLO_EL_ZP_ME_ENTIENDE,
	LOS_PRIMEROS,
	VAMOS_POR_MAS,
	EXPERTO_EN_LOGROS,
	THIS_IS_SPARTA,
	SOY_DORADO,
	QUE_SUERTE,
	PRIMERO_QUE_SUERTE,
	LIDER_EN_CABEZAS,
	AGUJEREANDO_CABEZAS,
	MORTIFICANDO_ZOMBIES,
	CABEZAS_ZOMBIES,
	ZOMBIES_x100,
	ZOMBIES_x500,
	ZOMBIES_x1000,
	ZOMBIES_x2500,
	ZOMBIES_x5000,
	ZOMBIES_x10K,
	ZOMBIES_x25K,
	ZOMBIES_x50K,
	ZOMBIES_x100K,
	ZOMBIES_x250K,
	ZOMBIES_x500K,
	ZOMBIES_x1M,
	ZOMBIES_x5M,
	MIRA_MI_DANIO,
	MAS_Y_MAS_DANIO,
	LLEGUE_AL_MILLON,
	MI_DANIO_CRECE,
	MI_DANIO_CRECE_Y_CRECE,
	VAMOS_POR_LOS_50_MILLONES,
	CONTADOR_DE_DANIOS,
	YA_PERDI_LA_CUENTA,
	MI_DANIO_ES_CATASTROFICO,
	MI_DANIO_ES_NUCLEAR,
	MUCHOS_NUMEROS,
	SE_ME_BUGUEO_EL_DANIO,
	ME_ABURRO,
	NO_SE_LEER_ESTE_NUMERO,
	MI_CUCHILLO_ES_ROJO,
	AFILANDO_MI_CUCHILLO,
	ACUCHILLANDO,
	ME_ENCANTAN_LAS_TRIPAS,
	HUMMILACION,
	CLAVO_QUE_TE_CLAVO_LA_SOMBRILLA,
	ENTRA_CUCHILLO_SALEN_LAS_TRIPAS,
	HUMILIATION_DEFEAT,
	CUCHILLO_DE_COCINA,
	CUCHILLO_PARA_PIZZA,
	YOCUCHI,
	CABEZITA,
	A_PLENO,
	ROMPIENDO_CABEZAS,
	ABRIENDO_CEREBROS,
	PERFORANDO,
	DESCOCANDO,
	ROMPECRANEOS,
	DUCK_HUNT,
	AIMBOT,
	VINCULADO,
	HUMANOS_x100,
	HUMANOS_x500,
	HUMANOS_x1000,
	HUMANOS_x2500,
	HUMANOS_x5000,
	HUMANOS_x10K,
	HUMANOS_x25K,
	HUMANOS_x50K,
	HUMANOS_x100K,
	HUMANOS_x250K,
	HUMANOS_x500K,
	HUMANOS_x1M,
	HUMANOS_x5M,
	SACANDO_PROTECCION,
	ESO_NO_TE_SIRVE_DE_NADA,
	NO_ES_UN_PROBLEMA_PARA_MI,
	SIN_DEFENSAS,
	DESGARRANDO_CHALECO,
	TOTALMENTE_INDEFENSO,
	Y_LA_LIMPIEZA,
	YO_USO_CLEAR_ZOMBIE,
	ANTIDOTO_PARA_TODOS,
	PENSANDOLO_BIEN,
	YO_NO_FUI,
	YO_FUI,
	MI_CUCHILLA_Y_YO,
	ANIQUILOSO,
	CIENFUEGOS,
	CARNE,
	MUCHA_CARNE,
	DEMASIADA_CARNE,
	CARNE_PARA_TODOS,
	EL_PEOR_DEL_SERVER,
	OOPS_MATE_A_TODOS,
	MI_MAC10_ESTA_LLENA,
	SOY_UN_MANCO,
	CINCUENTA_SON_CINCUENTA,
	YO_SI_PEGO_CON_ESTO,
	MUCHA_PRECISION,
	CRATER_SANGRIENTO,
	LA_EXPLOSION_NO_MATA,
	LA_EXPLOSION_SI_MATA,
	MA_KILL_Z_x5,
	MA_KILL_H_x5,
	MA_KILL_N_x2,
	MA_KILL_S_x2,
	MA_KILL_AGAIN_H,
	MA_KILL_AGAIN_Z,
	MA_WIN_H,
	MA_WIN_Z,
	MA_KILL_ALL_ZOMBIES,
	MA_KILL_ALL_HUMANS,
	GG_WIN_x1,
	GG_WIN_x10,
	GG_ALMOST_WIN,
	GG_HEADSHOTS_x20,
	GG_HEADSHOTS_x30,
	GG_HEADSHOTS_x40,
	GG_WIN_UNIQUE,
	GG_WIN_BY_FAR,
	GG_FAST_WIN,
	GG_WIN_CONSECUTIVE,
	SOY_MUY_NOOB,
	ACUCHILLADOS,
	AFISIONADO_EN_CUCHI,
	ENTRA_CUCHI_SALEN_TRIPAS,
	TODO_UN_AWPER,
	EXPERTO_EN_AWP,
	PRO_AWP,
	DETONADOS,
	BOMBAZO_PARA_TODOS,
	BOOM_EN_TODA_LA_CARA,
	MI_PRIMER_DUELO,
	VAMOS_BIEN,
	DEMASIADO_FACIL,
	COMBO_x1000,
	COMBO_x5000,
	COMBO_x25000,
	COMBO_x75000,
	COMBO_x150000,
	COMBO_x500000,
	COMBO_x2500000,
	COMBO_x10000000,
	COMBO_x2_ZOMBIE,
	COMBO_x5_ZOMBIE,
	COMBO_x8_ZOMBIE,
	COMBO_x11_ZOMBIE,
	COMBO_x14_ZOMBIE,
	COMBO_x17_ZOMBIE,
	COMBO_x20_ZOMBIE,
	COMBO_x24_ZOMBIE,
	VISION_NOCTURNA_x10,
	INVISIBILIDAD_x10,
	BALAS_INFINITAS_x10,
	PRESICION_PERFECTA_x10,
	BOMBA_DE_ANIQUILACION_x10,
	BOMBA_PIPE_x10,
	BOMBA_ANTIDOTO_x10,
	ANTIDOTO_x10,
	FURIA_x10,
	BOMBA_DE_INFECCION_x10,
	REDUCCION_x10,
	PETRIFICACION_x10,
	VISION_NOCTURNA_x50,
	INVISIBILIDAD_x50,
	BALAS_INFINITAS_x50,
	PRESICION_PERFECTA_x50,
	BOMBA_DE_ANIQUILACION_x50,
	BOMBA_PIPE_x50,
	BOMBA_ANTIDOTO_x50,
	ANTIDOTO_x50,
	FURIA_x50,
	BOMBA_DE_INFECCION_x50,
	REDUCCION_x50,
	PETRIFICACION_x50,
	VISION_NOCTURNA_x100,
	INVISIBILIDAD_x100,
	BALAS_INFINITAS_x100,
	PRESICION_PERFECTA_x100,
	BOMBA_DE_ANIQUILACION_x100,
	BOMBA_PIPE_x100,
	BOMBA_ANTIDOTO_x100,
	ANTIDOTO_x100,
	FURIA_x100,
	BOMBA_DE_INFECCION_x100,
	REDUCCION_x100,
	PETRIFICACION_x100,
	ITEMS_EXTRAS_x10,
	ITEMS_EXTRAS_x50,
	ITEMS_EXTRAS_x100,
	ITEMS_EXTRAS_x500,
	ITEMS_EXTRAS_x1000,
	ITEMS_EXTRAS_x5000,
	RESIDENT_EVIL,
	VOS_NO_PASAS,
	MI_DEAGLE_Y_YO,
	L_INTACTO,
	NO_ME_HACE_FALTA,
	DK_BUGUEADA,
	ME_GUSTAN_LOS_RETOS,
	A_ESO_LE_LLAMAS_DESAFIOS,
	CHALLENGE_ACEPTED,
	BETA_TESTER_DIA_2,
	SUPER_BETA_TESTER_DIA_2,
	HEAD_100_RED,
	HEAD_75_GREEN,
	HEAD_50_BLUE,
	HEAD_25_YELLOW,
	COLORIDO,
	ARE_YOU_FUCKING_KIDDING_ME,
	YA_DE_ZOMBIE,
	ANIQUILA_ANIQUILADOR,
	NO_LA_NECESITO,
	EL_VERDULERO,
	BAN_LOCAL,
	SENTADO,
	PUM_BALAZO,
	THE_KILLER_OF_DK,
	GIFT_1,
	GIFT_25,
	GIFT_50,
	GIFT_100,
	GIFT_200,
	GIFT_500,
	GIFT_1000,
	PRIMERO_GIFT_10,
	PRIMERO_GIFT_100,
	LONG_JUMP_x10,
	LONG_JUMP_x50,
	LONG_JUMP_x100,
	AMMOPACKS_x1000,
	AMMOPACKS_x5000,
	AMMOPACKS_x10000,
	AMMOPACKS_x50000,
	AMMOPACKS_x100000,
	AMMOPACKS_x500000,
	AMMOPACKS_x1000000,
	AMMOPACKS_x5000000,
	AMMOPACKS_x10000000,
	AMMOPACKS_x50000000,
	AMMOPACKS_x100000000,
	AMMOPACKS_x250000000,
	AMMOPACKS_x500000000,
	AMMOPACKS_ROUND_x100,
	AMMOPACKS_ROUND_x500,
	AMMOPACKS_ROUND_x1000,
	AMMOPACKS_ROUND_x5000,
	AMMOPACKS_ROUND_x10000,
	AMMOPACKS_MAP_x5000,
	AMMOPACKS_MAP_x10000,
	AMMOPACKS_MAP_x25000,
	AMMOPACKS_MAP_x50000,
	AMMOPACKS_MAP_x100000,
	EL_CABEZA,
	SUBE_Y_BAJA,
	SUBE_Y_BOOM,
	CABEZON_Y_CIEGO,
	MEJOREN_LA_PUNTERIA,
	A_ESO_LE_LLAMAN_DISPARAR,
	COMO_USABA_EL_PODER,
	L_FRANCOTIRADOR,
	EL_MEJOR_EQUIPO,
	EN_MEMORIA_A_ELLOS,
	MI_AWP_ES_MEJOR,
	MI_SCOUT_ES_MEJOR,
	SOBREVIVEN_LOS_DUROS,
	NO_SOLO_LA_GANAN_LOS_DUROS,
	ZAS_EN_TODA_LA_BOCA,
	NO_TENGO_BALAS,
	L_ALIENIGENA,
	ALIEN_ENTRENADO,
	SUPER_ALIEN_86,
	RAPIDO_Y_ALIENOSO,
	L_FURIA,
	ROJO_BAH,
	NO_TE_VEO_PERO_TE_HUELO,
	ESTOY_RE_LOCO,
	L_DEPREDADOR,
	SARGENTO_DEPRE,
	DEPREDADOR_007,
	AHORA_ME_VES_AHORA_NO_ME_VES,
	MI_HABILIDAD_ES_MEJOR,
	CINCO_DE_LAS_GRANDES,
	BAD_LUCKY_BRIAN,
	SURVIVOR_PRINCIPIANTE,
	SURVIVOR_AVANZADO,
	SURVIVOR_EXPERTO,
	SURVIVOR_PRO,
	WESKER_PRINCIPIANTE,
	WESKER_AVANZADO,
	WESKER_EXPERTO,
	WESKER_PRO,
	LEATHERFACE_PRINCIPIANTE,
	LEATHERFACE_AVANZADO,
	LEATHERFACE_EXPERTO,
	LEATHERFACE_PRO,
	NEMESIS_PRINCIPIANTE,
	NEMESIS_AVANZADO,
	NEMESIS_EXPERTO,
	NEMESIS_PRO,
	CABEZON_PRINCIPIANTE,
	CABEZON_AVANZADO,
	CABEZON_EXPERTO,
	CABEZON_PRO,
	ANNIHILATOR_PRINCIPIANTE,
	ANNIHILATOR_AVANZADO,
	ANNIHILATOR_EXPERTO,
	ANNIHILATOR_PRO
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

enum _:structIdArtifactsClasses {
	ARTIFACT_CLASS_RING = 0,
	ARTIFACT_CLASS_NECKLASE,
	ARTIFACT_CLASS_BRACELET
};

enum _:structIdArtifacts {
	ARTIFACT_RING_EXTRA_ITEM_COST = 0,
	ARTIFACT_RING_AMMOPACKS,
	ARTIFACT_RING_XP,
	ARTIFACT_RING_COMBO,
	ARTIFACT_NECKLASE_FIRE,
	ARTIFACT_NECKLASE_FROST,
	ARTIFACT_NECKLASE_DAMAGE,
	ARTIFACT_NECKLASE_HZ_REWARD,
	ARTIFACT_BRACELET_AMMOPACKS,
	ARTIFACT_BRACELET_XP,
	ARTIFACT_BRACELET_COMBO,
	ARTIFACT_BRACELET_POINTS,
	ARTIFACT_BRACELET_DAMAGE
};

enum _:structIdMasterys {
	MASTERY_NONE = 0,
	MASTERY_MORNING,
	MASTERY_NIGHT
};

enum _:structIdAmuletCustoms {
	acHealth = 0,
	acSpeed,
	acGravity,
	acDamage,
	Float:acMultAmmoPacks,
	Float:acMultXP,
	acMultCombo
};

enum _:structIdColorTypes {
	COLOR_TYPE_HUD_GENERAL = 0,
	COLOR_TYPE_HUD_COMBO,
	COLOR_TYPE_NVISION,
	COLOR_TYPE_FLARE,
	COLOR_TYPE_GROUP_GLOW
};

enum _:structIdHudTypes {
	HUD_TYPE_GENERAL = 0,
	HUD_TYPE_COMBO
};

enum _:structIdChatMode {
	CHAT_MODE_NORMAL = 0,
	CHAT_MODE_BCK,
	CHAT_MODE_BCK_PTH,
	CHAT_MODE_KY,
	CHAT_MODE_KY_PTH,
	CHAT_MODE_KY_BCK,
	CHAT_MODE_KY_BCK_PTH
};

enum _:structIdPlayedTime {
	TIME_SEC = 0,
	TIME_HOUR,
	TIME_DAY
};

enum _:structIdStats {
	STAT_HS_D = 0,
	STAT_HS_T,
	STAT_HM_D,
	STAT_HM_T,
	STAT_ZM_D,
	STAT_ZM_T,
	STAT_INF_D,
	STAT_INF_T,
	STAT_ZMHS_D,
	STAT_ZMHS_T,
	STAT_ZMK_D,
	STAT_ZMK_T,
	STAT_AP_D,
	STAT_AP_T,
	STAT_COMBO_MAX,
	STAT_S_M_KILL,
	STAT_W_M_KILL,
	STAT_L_M_KILL,
	STAT_T_M_KILL,
	STAT_SN_M_KILL,
	STAT_NEM_M_KILL,
	STAT_CAB_M_KILL,
	STAT_ANN_M_KILL,
	STAT_FLESH_M_KILL,
	STAT_MA_WINS,
	STAT_GG_WINS,
	STAT_DF_WINS
};

enum _:structIdWeaponDatas {
	WEAPON_DATA_KILL_DONE,
	Float:WEAPON_DATA_DAMAGE_DONE,
	WEAPON_DATA_LEVEL,
	WEAPON_DATA_POINTS,
	WEAPON_DATA_TIME_PLAYED_DONE,
	WEAPON_DATA_TPD_MINUTES,
	WEAPON_DATA_TPD_HOURS,
	WEAPON_DATA_TPD_DAYS
};

enum _:structIdWeaponSkills {
	WEAPON_SKILL_DAMAGE = 0,
	WEAPON_SKILL_SPEED,
	WEAPON_SKILL_RECOIL,
	WEAPON_SKILL_BULLETS,
	WEAPON_SKILL_RELOAD_SPEED,
	WEAPON_SKILL_CRITICAL_PROBABILITY
};

enum _:structIdMenuPages {
	MENU_PAGE_GAME = 0,
	MENU_PAGE_BPW,
	MENU_PAGE_BSW,
	MENU_PAGE_BCW,
	MENU_PAGE_MY_WEAPONS,
	MENU_PAGE_SKINS_MY_WEAPONS,
	MENU_PAGE_HAB_CLASSES,
	MENU_PAGE_HAB_ROTATE,
	MENU_PAGE_HAB_ROTATE_INFO,
	MENU_PAGE_HAB_TRADE,
	MENU_PAGE_ACHIEVEMENT_CLASSES,
	MENU_PAGE_HAT_CLASS,
	MENU_PAGE_ARTIFACTS,
	MENU_PAGE_COLOR_CHOOSEN,
	MENU_PAGE_STATS_LEVELS,
	MENU_PAGE_STATS_GENERAL,
	MENU_PAGE_GROUP_INVITE,
	MENU_PAGE_MAPS
};

enum _:structIdMenuDatas {
	MENU_DATA_MY_WEAPON_ID = 0,
	MENU_DATA_MY_WEAPON_DATA_ID,
	MENU_DATA_DIFFICULT_CLASS_ID,
	MENU_DATA_HAB_CLASS_ID,
	MENU_DATA_HAB_ID,
	MENU_DATA_HAB_ROTATE_ID,
	MENU_DATA_ACHIEVEMENT_CLASS_ID,
	MENU_DATA_ACHIEVEMENT_IN,
	MENU_DATA_HAT_ID,
	MENU_DATA_ARTIFACTS,
	MENU_DATA_MASTERY,
	MENU_DATA_COLOR_CHOOSEN,
	MENU_DATA_GROUP_INFO
};

enum _:structIdGunGameTypes {
	GUNGAME_NORMAL = 0,
	GUNGAME_ONLY_HEAD,
	GUNGAME_SLOW,
	GUNGAME_FAST,
	GUNGAME_CRAZY,
	GUNGAME_CLASSIC
};

enum _:structIdHeadZombies {
	HEADZOMBIE_RED = 0,
	HEADZOMBIE_GREEN,
	HEADZOMBIE_BLUE,
	HEADZOMBIE_YELLOW,
	HEADZOMBIE_VIOLET_SMALL,
	HEADZOMBIE_VIOLET_BIG
};

enum _:structIdTutorTextColor {
	TT_COLOR_RED = 1,
	TT_COLOR_BLUE,
	TT_COLOR_YELLOW,
	TT_COLOR_GREEN,
	TT_COLOR_WHITE = 8
};

enum _:structModes {
	modeName[32],
	modeChance,
	modeUsersNeed
};

enum _:structWeapons {
	weaponCSW,
	weaponEnt[54],
	weaponName[32],
	weaponLevelReq,
	weaponReset,
	Float:weaponDamageMult
};

enum _:structGrenades {
	grenadeAmountHe,
	grenadeAmountFb,
	grenadeAmountSg,
	grenadeName[64],
	grenadeIsDrug,
	grenadeIsSupernova,
	grenadeIsBubble,
	grenadeLevelReq,
	grenadeReset
};

enum _:structWeaponDatas {
	weaponDataName[32],
	weaponDataId
};

enum _:structWeaponModels {
	weaponModelLevel,
	weaponModelPath[128]
};

enum _:structExtraItems {
	extraItemName[32],
	extraItemCost,
	extraItemLimitUser,
	extraItemMult,
	extraItemMultCount,
	extraItemTeam
};

enum _:structDifficults {
	difficultName[24],
	difficultNameMin[24],
	difficultInfo[128],
	Float:difficultHealth,
	Float:difficultSpeed
};

enum _:structHabsClasses {
	habClassName[32],
	habClassPointName[32],
	habClassPointNameShort[16],
	habClassPointId
};

enum _:structHabs {
	habEnabled,
	habName[32],
	habInfo[256],
	habValue,
	habCost,
	habMaxLevel,
	habClass
};

enum _:structHabsRotate {
	habRotateName[32],
	habRotateInfo[256],
	habRotateCost
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
	Float:hatUpgrade6, // Mult XP
	hatUpgrade7, // Respawn Humano
	hatUpgrade8 // Descuento de Items
};

enum _:structArtifacts {
	artifactName[32],
	artifactCost,
	artifactClass
};

enum _:structColors {
	colorName[16],
	colorRed,
	colorGreen,
	colorBlue
};

enum _:structCombo {
	comboNeed,
	comboMessage[48],
	comboSound[64]
};

new const __SERVER_FILE[] = "server.log";
new const __SQL_FILE[] = "mysql.log";
new const __BANS_FILE[] = "bans.log";
new const __MAP_ERRORS_FILE[] = "map_errors.log";

new const __MODES[structIdModes][structModes] = {
	{"", 0, 0},
	{"INFECCIÓN", 0, 0},
	{"PLAGUE", 30, 6},
	{"SYNAPSIS", 75, 10},
	{"MEGA SYNAPSIS", 0, 0}, // COMPLETAR
	{"ARMAGEDDON", 75, 16},
	{"MEGA ARMAGEDDON", 0, 0},
	{"GUNGAME", 0, 0},
	{"MEGA GUNGAME", 0, 0},
	{"DRUNK", 75, 16},
	{"MEGA DRUNK", 75, 16},
	{"LEFT 4 DEAD", 75, 16},
	{"DUELO FINAL", 75, 10},
	{"SURVIVOR", 20, 8},
	{"WESKER", 40, 12},
	{"LEATHERFACE", 40, 12},
	{"TRIBAL", 40, 12},
	{"SNIPER", 40, 12},
	{"NEMESIS", 20, 8},
	{"CABEZÓN", 40, 12},
	{"ANIQUILADOR", 40, 12},
	{"FLESHPOUND", 40, 12},
	{"GRUNT", 40, 12}
};

new const __PRIMARY_WEAPONS[][structWeapons] = {
	{CSW_MAC10, "weapon_mac10", "Ingram MAC-10", 1, 0, 1.0},			// 28
	{CSW_TMP, "weapon_tmp", "Schmidt TMP", 25, 0, 1.0},				// 19
	{CSW_M3, "weapon_m3", "M3 Super 90", 50, 0, 1.0},					// 176
	{CSW_UMP45, "weapon_ump45", "UMP 45", 75, 0, 1.0},				// 29
	{CSW_XM1014, "weapon_xm1014", "XM1014 M4", 100, 0, 1.0},			// 114
	{CSW_P90, "weapon_p90", "ES P90", 125, 0, 1.0},						// 20
	{CSW_MP5NAVY, "weapon_mp5navy", "MP5 Navy", 150, 0, 1.0},			// 25
	{CSW_FAMAS, "weapon_famas", "Famas", 175, 0, 1.0},					// 29
	{CSW_GALIL, "weapon_galil", "IMI Galil", 200, 0, 1.0},					// 29
	{CSW_AUG, "weapon_aug", "Steyr AUG A1", 225, 0, 1.0},				// 31
	{CSW_SG552, "weapon_sg552", "SG-552 Commando", 250, 0, 1.0},		// 32
	{CSW_AK47, "weapon_ak47", "AK-47 Kalashnikov", 275, 0, 1.0},			// 35
	{CSW_M4A1, "weapon_m4a1", "M4A1 Carbine", 1, 1, 1.0},				// 31
	
	{CSW_MAC10, "weapon_mac10", "FARA 83", 25, 1, 2.29},			 	// 120
	{CSW_TMP, "weapon_tmp", "Tavor TAR-21", 50, 1, 4.58},			 	// 125
	{CSW_M3, "weapon_m3", "HK G3", 75, 1, 1.23},			 			// 218
	{CSW_UMP45, "weapon_ump45", "IMBEL MD-2", 100, 1, 2.49},			// 130
	{CSW_XM1014, "weapon_xm1014", "EF88 / F90", 125, 1, 1.36},		// 155
	{CSW_P90, "weapon_p90", "Khaybar KH2002", 150, 1, 4.76},			// 135
	{CSW_MP5NAVY, "weapon_mp5navy", "MKb.42(H)", 175, 1, 3.61},		// 140
	{CSW_FAMAS, "weapon_famas", "Enfield EM-2", 200, 1, 3.01},			// 145
	{CSW_GALIL, "weapon_galil", "LAPA FA 03", 225, 1, 3.18},			// 150
	{CSW_AUG, "weapon_aug", "Steyr ACR", 250, 1, 3.01},			 	// 155
	{CSW_SG552, "weapon_sg552", "IWI X95", 275, 1, 3.01},			 	// 160
	{CSW_AK47, "weapon_ak47", "Pindad SS2", 1, 2, 2.72},			 	// 165
	{CSW_M4A1, "weapon_m4a1", "Madsen LAR", 25, 2, 3.49},			 	// 170
	
	{CSW_MAC10, "weapon_mac10", "IMBEL IA2 5.56", 50, 2, 4.26},		// 175
	{CSW_TMP, "weapon_tmp", "CQ M311", 75, 2, 7.48},			 		// 180
	{CSW_M3, "weapon_m3", "Diemaco C7A1", 100, 2, 1.35},			 	// 238
	{CSW_UMP45, "weapon_ump45", "HK G41", 125, 2, 4.38},			 	// 185
	{CSW_XM1014, "weapon_xm1014", "FN FAL", 150, 2, 1.53},			// 175
	{CSW_P90, "weapon_p90", "FX-05 Xiuhcoatl", 175, 2, 7.51},			// 190
	{CSW_MP5NAVY, "weapon_mp5navy", "CETME mod.T", 200, 2, 5.81},	// 195
	{CSW_FAMAS, "weapon_famas", "Gilboa Snake", 225, 2, 4.90},			// 200
	{CSW_GALIL, "weapon_galil", "Cristobal M2", 250, 2, 5.07},			// 205
	{CSW_AUG, "weapon_aug", "SA80 / L85", 275, 2, 4.78},			 	// 210
	{CSW_SG552, "weapon_sg552", "QBS-06", 1, 3, 4.72},				// 215
	{CSW_AK47, "weapon_ak47", "NAR-10", 25, 3, 4.29},			 		// 220
	{CSW_M4A1, "weapon_m4a1", "Type 86s", 50, 3, 5.26},			 	// 225
	
	{CSW_MAC10, "weapon_mac10", "OTs-12 Tiss", 75, 3, 6.22},			// 230
	{CSW_TMP, "weapon_tmp", "CIS SAR-80", 100, 3, 10.37},			 	// 235
	{CSW_M3, "weapon_m3", "Korobov TKB-408", 125, 3, 1.46},			// 258
	{CSW_UMP45, "weapon_ump45", "AS Val", 150, 3, 6.28},			 	// 240
	{CSW_XM1014, "weapon_xm1014", "Fedorov avtomat", 175, 3, 1.71},	// 195
	{CSW_P90, "weapon_p90", "TRW LMR", 200, 3, 10.26},			 	// 245
	{CSW_MP5NAVY, "weapon_mp5navy", "ADS dual medium", 225, 3, 8.01},// 250
	{CSW_FAMAS, "weapon_famas", "APS underwater", 250, 3, 6.80},		// 255
	{CSW_GALIL, "weapon_galil", "A-91M", 275, 3, 6.97},			 	// 260
	{CSW_AUG, "weapon_aug", "SA80 / L85", 1, 4, 6.55},			 	// 265
	{CSW_SG552, "weapon_sg552", "Armalite AR-10", 25, 4, 6.44},			// 270
	{CSW_AK47, "weapon_ak47", "AN-94 Abakan", 50, 4, 5.86},			// 275
	{CSW_M4A1, "weapon_m4a1", "ASh-12.7", 75, 4, 7.04},			 	// 280
	
	{CSW_MAC10, "weapon_mac10", "Ruger AC-556", 100, 4, 8.18},		// 285
	{CSW_TMP, "weapon_tmp", "SA Vz.58", 125, 4, 13.27},			 	// 290
	{CSW_M3, "weapon_m3", "T65", 150, 4, 1.57},			 			// 278
	{CSW_UMP45, "weapon_ump45", "XM29 OICW", 175, 4, 8.18},			// 295
	{CSW_XM1014, "weapon_xm1014", "Bushmaster M17s", 200, 4, 1.88},	// 215
	{CSW_P90, "weapon_p90", "Daewoo K11", 225, 4, 13.01},			 	// 300
	{CSW_MP5NAVY, "weapon_mp5navy", "M27 IAR", 250, 4, 10.21},		// 305
	{CSW_FAMAS, "weapon_famas", "RobArm M96 XCR", 275, 4, 8.69},		// 310
	{CSW_GALIL, "weapon_galil", "FN Mk.16", 1, 5, 8.87},			 	// 315
	{CSW_AUG, "weapon_aug", "SA80 / L85", 50, 5, 8.33},			 	// 320
	{CSW_SG552, "weapon_sg552", "CZ 805", 100, 5, 8.16},			 	// 325
	{CSW_AK47, "weapon_ak47", "APS-95", 150, 5, 7.43},			 		// 330
	{CSW_M4A1, "weapon_m4a1", "Valmet Sako Rk.62", 200, 5, 8.81},		// 335
	
	{CSW_MAC10, "weapon_mac10", "MKEK MPT-76", 250, 5, 10.15},		// 340
	{CSW_TMP, "weapon_tmp", "Mk.17 SCAR", 1, 6, 16.16},			 	// 345
	{CSW_M3, "weapon_m3", "HK 33", 50, 6, 1.69},			 		// 298
	{CSW_UMP45, "weapon_ump45", "FN CAL", 100, 6, 10.07},			// 350
	{CSW_XM1014, "weapon_xm1014", "MSBS Radon", 150, 6, 2.06},		// 235
	{CSW_P90, "weapon_p90", "T65", 200, 6, 15.76},			 		// 355
	{CSW_MP5NAVY, "weapon_mp5navy", "CS/LR-14", 250, 6, 12.40},		// 360
	{CSW_FAMAS, "weapon_famas", "Mp-43", 1, 7, 10.59},			 	// 365
	{CSW_GALIL, "weapon_galil", "MKb.42(W)", 50, 7, 10.76},			// 370
	{CSW_AUG, "weapon_aug", "SA80 / L85", 100, 7, 10.10},			 	// 375
	{CSW_SG552, "weapon_sg552", "SIG-Sauer 716", 150, 7, 9.88},		// 380
	{CSW_AK47, "weapon_ak47", "Z-M LR-300", 200, 7, 9.01},			// 385
	{CSW_M4A1, "weapon_m4a1", "Colt CAR-15", 250, 7, 10.59},			// 390
	
	{CSW_MAC10, "weapon_mac10", "Valmet M82", 1, 8, 12.11},			// 395
	{CSW_TMP, "weapon_tmp", "Beretta BM 59", 50, 8, 19.06},			// 400
	{CSW_M3, "weapon_m3", "Type 89", 100, 8, 1.80},			 		// 318
	{CSW_UMP45, "weapon_ump45", "Interdynamics MKS", 150, 8, 11.97},	// 405
	{CSW_XM1014, "weapon_xm1014", "Vepr", 200, 8, 2.23},			 	// 255
	{CSW_P90, "weapon_p90", "OTs-14 Groza", 250, 8, 18.51},			// 410
	{CSW_MP5NAVY, "weapon_mp5navy", "Daewoo K11", 1, 9, 14.61},	// 415
	{CSW_FAMAS, "weapon_famas", "Vektor CR-21", 50, 9, 12.49},			// 420
	{CSW_GALIL, "weapon_galil", "VHS", 100, 9, 12.66},			 		// 425
	{CSW_AUG, "weapon_aug", "BT APC-556", 150, 9, 11.88},			 	// 430
	{CSW_SG552, "weapon_sg552", "Type 95 QBZ-95", 200, 9, 11.60},		// 435
	{CSW_AK47, "weapon_ak47", "Bofors AK5", 250, 9, 10.58},			// 440
	{CSW_M4A1, "weapon_m4a1", "Colt XM-177", 1, 10, 12.36},			// 445
	
	{CSW_MAC10, "weapon_mac10", "Leader SAR", 100, 10, 14.08},			// 450
	{CSW_TMP, "weapon_tmp", "Remington 7600", 200, 10, 21.95},			// 455
	{CSW_M3, "weapon_m3", "Kel-tec SUB 2000", 1, 11, 1.91},			// 338
	{CSW_UMP45, "weapon_ump45", "BCM CM4 Storm", 100, 11, 13.87},		// 460
	{CSW_XM1014, "weapon_xm1014", "AIA M10", 200, 11, 2.41},			// 275
	{CSW_P90, "weapon_p90", "Rossi 92", 1, 12, 21.26},			 	// 465
	{CSW_MP5NAVY, "weapon_mp5navy", "Hi-Point Model 995", 100, 12, 16.80},// 470
	{CSW_FAMAS, "weapon_famas", "Vepr MA-9", 200, 12, 14.38},			// 475
	{CSW_GALIL, "weapon_galil", "KSO-9 Krechet", 1, 13, 14.56},			// 480
	{CSW_AUG, "weapon_aug", "Armalon PC", 100, 13, 13.65},			 	// 485
	{CSW_SG552, "weapon_sg552", "Ruger PC-4", 200, 13, 13.32},			// 490
	{CSW_AK47, "weapon_ak47", "Kel-tec RDB", 1, 14, 12.15},			// 495
	{CSW_M4A1, "weapon_m4a1", "Heckler-Koch SL-6", 100, 14, 14.13},		// 500
	
	{CSW_MAC10, "weapon_mac10", "Cobra", 200, 14, 16.04},			 	// 505
	{CSW_TMP, "weapon_tmp", "Ar-15", 1, 15, 24.85},			 		// 510
	{CSW_M3, "weapon_m3", "JR carbine", 100, 15, 2.03},			 		// 358
	{CSW_UMP45, "weapon_ump45", "Safir T15", 200, 15, 15.76},			// 515
	{CSW_XM1014, "weapon_xm1014", "Kommando LDP", 1, 16, 2.58},	// 295
	{CSW_P90, "weapon_p90", "Magpul MASADA", 100, 16, 14.01},			// 520
	{CSW_MP5NAVY, "weapon_mp5navy", "DRD Paratus", 200, 16, 19.01},		// 525
	{CSW_FAMAS, "weapon_famas", "MPAR-556", 1, 17, 16.28},			// 530
	{CSW_GALIL, "weapon_galil", "K&M M17S-556", 100, 17, 16.45},		// 535
	{CSW_AUG, "weapon_aug", "Taurus CT G2", 200, 17, 15.42},			// 540
	{CSW_SG552, "weapon_sg552", "TPD AXR", 1, 18, 15.04},			// 545
	{CSW_AK47, "weapon_ak47", "MSAR STG-556", 100, 18, 13.72},			// 550
	{CSW_M4A1, "weapon_m4a1", "Colt LE-901", 200, 18, 15.91},			// 555
	
	{CSW_MAC10, "weapon_mac10", "SMLE Lee-Enfield", 1, 19, 18.01},		// 560
	{CSW_TMP, "weapon_tmp", "Krag–Jorgensen", 100, 19, 27.74},			// 565
	{CSW_M3, "weapon_m3", "Winchester M1895", 200, 19, 2.14},			// 378
	{CSW_UMP45, "weapon_ump45", "Mauser 98", 1, 20, 17.66},			// 570
	{CSW_XM1014, "weapon_xm1014", "35M", 100, 20, 2.76},			 	// 315
	{CSW_P90, "weapon_p90", "Lebel M1886", 200, 20, 26.76},			 	// 575
	{CSW_MP5NAVY, "weapon_mp5navy", "Lee Navy M1895", 1, 21, 21.21},	// 580
	{CSW_FAMAS, "weapon_famas", "Madsen M1947", 100, 21, 18.18},		// 585
	{CSW_GALIL, "weapon_galil", "Gew.88", 200, 21, 18.35},			 	// 590
	{CSW_AUG, "weapon_aug", "De Lisle Commando", 1, 22, 17.20},		// 595
	{CSW_SG552, "weapon_sg552", "Carcano M91", 100, 22, 16.76},		// 600
	{CSW_AK47, "weapon_ak47", "SKS Simonov", 200, 22, 15.29},			// 605
	{CSW_M4A1, "weapon_m4a1", "M1903 Springfield", 1, 23, 17.68},		// 610
	
	{CSW_MAC10, "weapon_mac10", "Berthier 1890", 100, 23, 19.97},		// 615
	{CSW_TMP, "weapon_tmp", "VG.1-5", 200, 23, 30.64},			 		// 620
	{CSW_M3, "weapon_m3", "FG-42", 1, 24, 2.25},			 		// 398
	{CSW_UMP45, "weapon_ump45", "K31", 100, 24, 19.56},			 	// 625
	{CSW_XM1014, "weapon_xm1014", "MAS-36", 200, 24, 2.93},			// 335
	{CSW_P90, "weapon_p90", "AVS-36 Simonov", 1, 25, 29.51},		// 630
	{CSW_MP5NAVY, "weapon_mp5navy", "G.41(M)", 150, 25, 23.40},		// 635
	{CSW_FAMAS, "weapon_famas", "FN SAFN-49", 1, 26, 20.07},		// 640
	{CSW_GALIL, "weapon_galil", "Mauser M1889", 150, 26, 20.25},		// 645
	{CSW_AUG, "weapon_aug", "Arisaka 38", 1, 27, 18.97},			 	// 650
	{CSW_SG552, "weapon_sg552", "Hakim", 150, 27, 18.47},			 	// 655
	{CSW_AK47, "weapon_ak47", "Mondragon", 1, 28, 16.86},			// 660
	{CSW_M4A1, "weapon_m4a1", "AG-42 Ljungman", 150, 28, 19.46},		// 665
	
	{CSW_MAC10, "weapon_mac10", "M1 Garand", 1, 29, 21.93},			// 670
	{CSW_TMP, "weapon_tmp", "ZH-29", 150, 29, 33.53},			 	// 675
	{CSW_M3, "weapon_m3", "Meunier M1916", 1, 30, 2.37},			 	// 418
	{CSW_UMP45, "weapon_ump45", "Pedersen T1", 150, 30, 21.45},		// 680
	{CSW_XM1014, "weapon_xm1014", "SVT-38", 1, 31, 3.11},			// 355
	{CSW_P90, "weapon_p90", "Rasheed", 150, 31, 32.25},			 	// 685
	{CSW_MP5NAVY, "weapon_mp5navy", "MAS-1949", 1, 32, 25.61},		// 690
	{CSW_FAMAS, "weapon_famas", "RSC M1917", 150, 32, 21.97},			// 695
	{CSW_GALIL, "weapon_galil", "S&W Light 1940", 1, 33, 22.14},		// 700
	{CSW_AUG, "weapon_aug", "M1941 Johnson", 150, 33, 20.75},			// 705
	{CSW_SG552, "weapon_sg552", "Farquhar-Hill", 1, 34, 20.19},		// 710
	{CSW_AK47, "weapon_ak47", "SVT-40 Tokarev", 150, 34, 18.43},		// 715
	{CSW_M4A1, "weapon_m4a1", "Madsen M1896", 1, 35, 21.23},		// 720
	
	{CSW_MAC10, "weapon_mac10", "M1917 US Enfield", 150, 36, 23.90},	// 725
	{CSW_TMP, "weapon_tmp", "Korobov TKB-517", 1, 37, 36.43},		// 730
	{CSW_M3, "weapon_m3", "9A-91", 150, 37, 2.48},			 		// 438
	{CSW_UMP45, "weapon_ump45", "Vz.52/57", 1, 38, 23.35},			// 735
	{CSW_XM1014, "weapon_xm1014", "Mosin", 150, 38, 3.29},			// 375
	{CSW_P90, "weapon_p90", "ASh-12.7", 1, 39, 35.00},			 	// 740
	{CSW_MP5NAVY, "weapon_mp5navy", "ADS DualM", 150, 39, 27.80},		// 745
	{CSW_FAMAS, "weapon_famas", "G.41(W)", 1, 40, 23.87},			// 750
	{CSW_GALIL, "weapon_galil", "Breda", 150, 40, 24.04},			 	// 755
	{CSW_AUG, "weapon_aug", "Steyr Mannlicher M95", 1, 41, 23.52},		// 760
	{CSW_SG552, "weapon_sg552", "Baryshev AB-7", 150, 41, 21.91},		// 765
	{CSW_AK47, "weapon_ak47", "AKS-74U", 1, 42, 20.01},			 	// 770
	{CSW_M4A1, "weapon_m4a1", "OTs-14 Groza", 150, 42, 23.01},		// 775
	
	{CSW_MAC10, "weapon_mac10", "Armalite AR-18", 1, 43, 25.86},		// 780
	{CSW_TMP, "weapon_tmp", "FMK-3", 150, 43, 39.32},			 	// 785
	{CSW_M3, "weapon_m3", "APC-300", 1, 44, 2.60},			 		// 458
	{CSW_UMP45, "weapon_ump45", "Desert Tech MDR", 150, 44, 25.25},	// 790
	{CSW_XM1014, "weapon_xm1014", "ST Kinetics SAR-21", 1, 45, 3.46},	// 395
	{CSW_P90, "weapon_p90", "K6-92", 150, 45, 37.75},					// 795
	{CSW_MP5NAVY, "weapon_mp5navy", "Daewoo K1/K2", 1, 46, 30.00},	// 800
	{CSW_FAMAS, "weapon_famas", "Interdynamics MKR", 150, 46, 25.76},	// 805
	{CSW_GALIL, "weapon_galil", "SR-3M Vikhr", 1, 47, 25.94},			// 810
	{CSW_AUG, "weapon_aug", "SIG-Sauer 516", 150, 47, 24.30},			// 815
	{CSW_SG552, "weapon_sg552", "Halcon M/943", 1, 48, 23.63},		// 820
	{CSW_AK47, "weapon_ak47", "Bofors AK5", 150, 48, 22.58},			// 825
	{CSW_M4A1, "weapon_m4a1", "Korobov TKB-022", 1, 49, 24.78},		// 830
	
	{CSW_MAC10, "weapon_mac10", "Mekanika URU", 150, 49, 27.83},		// 835
	{CSW_TMP, "weapon_tmp", "K-50M", 1, 50, 42.22},			 	// 840
	{CSW_M3, "weapon_m3", "Sterling L2", 1, 51, 2.71},			 	// 478
	{CSW_UMP45, "weapon_ump45", "Shipka", 1, 52, 27.14},			// 845
	{CSW_XM1014, "weapon_xm1014", " Vigneron M2", 53, 53, 3.64},		// 415
	{CSW_P90, "weapon_p90", "Walther MPL", 1, 54, 40.50},			 	// 850
	{CSW_MP5NAVY, "weapon_mp5navy", "MCEM-2", 1, 55, 32.20},		// 855
	{CSW_FAMAS, "weapon_famas", "Lanchester Mk.1", 1, 56, 27.66},		// 860
	{CSW_GALIL, "weapon_galil", "Gevarm D4", 1, 57, 27.83},			// 865
	{CSW_AUG, "weapon_aug", "Steyr-Solothurn MP.34", 1, 58, 26.07},	// 870
	{CSW_SG552, "weapon_sg552", "EMP.35 Erma", 1, 59, 25.35},		// 875
	{CSW_AK47, "weapon_ak47", "Dux M53", 1, 60, 23.15},			 	// 880
	{CSW_M4A1, "weapon_m4a1", "Colt SCAMP", 1, 61, 26.55},			// 885
	
	{CSW_MAC10, "weapon_mac10", "Erma MP-56", 1, 62, 29.79},		// 890
	{CSW_TMP, "weapon_tmp", "FNA-B 43", 1, 63, 45.11},			 	// 895
	{CSW_M3, "weapon_m3", "Benelli CB-M2", 1, 64, 2.82},			 	// 498
	{CSW_UMP45, "weapon_ump45", "Hovea m/49", 1, 65, 29.04},		// 900
	{CSW_XM1014, "weapon_xm1014", "MK.36 Schmeisser", 1, 66, 3.81},	// 435
	{CSW_P90, "weapon_p90", "Star Z-84", 1, 67, 43.25},			 	// 905
	{CSW_MP5NAVY, "weapon_mp5navy", "CETME C2", 1, 68, 34.40},		// 910
	{CSW_FAMAS, "weapon_famas", "MSMC", 1, 69, 29.56},			 	// 915
	{CSW_GALIL, "weapon_galil", "Micro UZI", 1, 70, 29.73},			// 920
	{CSW_AUG, "weapon_aug", "Madsen m/45", 1, 71, 27.84},			// 925
	{CSW_SG552, "weapon_sg552", "SOCIMI 821", 1, 72, 27.07},			// 930
	{CSW_AK47, "weapon_ak47", "Zk-383", 1, 73, 24.72},			 	// 935
	{CSW_M4A1, "weapon_m4a1", "Spectre M4", 1, 74, 28.33},			// 940
	
	{CSW_MAC10, "weapon_mac10", "Armaguerra OG-43", 1, 75, 31.75},	// 945
	{CSW_TMP, "weapon_tmp", "Smith&Wesson M76", 1, 76, 48.00},		// 950
	{CSW_M3, "weapon_m3", "Mors wz.39", 1, 77, 2.94},			 	// 518
	{CSW_UMP45, "weapon_ump45", "Madsen m/46", 1, 78, 30.94},		// 955
	{CSW_XM1014, "weapon_xm1014", "TZ-45", 1, 79, 3.99},			// 455
	{CSW_P90, "weapon_p90", "Ruger MP9", 1, 80, 46.00},			 	// 960
	{CSW_MP5NAVY, "weapon_mp5navy", "Chang Feng", 1, 81, 36.60},	// 965
	{CSW_FAMAS, "weapon_famas", "Beretta MX4", 1, 82, 31.45},		// 970
	{CSW_GALIL, "weapon_galil", "Franchi LF-57", 1, 83, 31.63},		// 975
	{CSW_AUG, "weapon_aug", "Steyr MPi 69", 1, 84, 29.62},			 	// 980
	{CSW_SG552, "weapon_sg552", "Ares FMG", 1, 85, 28.79},			// 985
	{CSW_AK47, "weapon_ak47", "Kriss Super V", 1, 86, 26.29},			// 990
	{CSW_M4A1, "weapon_m4a1", "Colt mod.635", 1, 87, 30.10},		// 995
	
	{CSW_MAC10, "weapon_mac10", "Demro TAC-1", 1, 88, 33.72},		// 1000
	{CSW_TMP, "weapon_tmp", "Degtyarov PDM", 1, 89, 50.90},			// 1005
	{CSW_M3, "weapon_m3", "OTs-02 Kiparis", 1, 90, 3.05},			 	// 538
	{CSW_UMP45, "weapon_ump45", "CS/LS-5", 1, 91, 32.83},			// 1010
	{CSW_XM1014, "weapon_xm1014", "IMP-221", 1, 92, 4.16},			// 475
	{CSW_P90, "weapon_p90", "PPSh-2", 1, 93, 48.75},			 	// 1015
	{CSW_MP5NAVY, "weapon_mp5navy", "STK CPW", 1, 94, 38.80},		// 1020
	{CSW_FAMAS, "weapon_famas", "Korovin 1941", 1, 95, 33.35},		// 1025
	{CSW_GALIL, "weapon_galil", "PPSh-41", 1, 96, 33.52},			 	// 1030
	{CSW_AUG, "weapon_aug", "Steyr TMP", 1, 97, 31.39},			 	// 1035
	{CSW_SG552, "weapon_sg552", "Orita M1941", 1, 98, 30.50},		// 1040
	{CSW_AK47, "weapon_ak47", "AEK-919K Kashtan", 1, 99, 27.86},		// 1045
	{CSW_M4A1, "weapon_m4a1", "Reising M50", 1, 100, 31.88},			// 1050
	
	{CSW_MAC10, "weapon_mac10", "Tikkakoski M/44", 1, 102, 35.68},		// 1055
	{CSW_TMP, "weapon_tmp", "MGV-176", 1, 104, 53.79},			 	// 1060
	{CSW_M3, "weapon_m3", "MGV-176", 1, 106, 3.16},			 	// 558
	{CSW_UMP45, "weapon_ump45", "B&T APC", 1, 108, 34.73},			// 1065
	{CSW_XM1014, "weapon_xm1014", "Suomi M/31", 1, 110, 4.34},		// 495
	{CSW_P90, "weapon_p90", "SAR 109", 1, 112, 51.50},			 	// 1070
	{CSW_MP5NAVY, "weapon_mp5navy", "Carl Gustaf M/45", 1, 116, 41.00},// 1075
	{CSW_FAMAS, "weapon_famas", "CBJ-MS PDW", 1, 118, 35.25},			// 1080
	{CSW_GALIL, "weapon_galil", "Agram2000", 1, 120, 35.42},			// 1085
	{CSW_AUG, "weapon_aug", "Rexim Favor", 1, 122, 33.17},			// 1090
	{CSW_SG552, "weapon_sg552", "Skorpion vz.61", 1, 124, 32.22},		// 1095
	{CSW_AK47, "weapon_ak47", "Minebea M-9", 1, 126, 29.43},			// 1100
	{CSW_M4A1, "weapon_m4a1", "WF Lmg 41/44", 1, 128, 33.65},		// 1105
	
	{CSW_MAC10, "weapon_mac10", "FN P90", 1, 130, 37.65},			// 1110
	{CSW_TMP, "weapon_tmp", "Ingram M6", 1, 132, 56.69},			 	// 1115
	{CSW_M3, "weapon_m3", "SR-3 Veresk", 1, 134, 3.28},			 	// 578
	{CSW_UMP45, "weapon_ump45", "MP.18,I Schmeisser", 1, 136, 36.63},	// 1120
	{CSW_XM1014, "weapon_xm1014", "Halcon ML-63", 1, 138, 4.51},		// 515
	{CSW_P90, "weapon_p90", "SI-35", 1, 140, 54.25},			 		// 1125
	{CSW_MP5NAVY, "weapon_mp5navy", "Beretta M1918", 1, 142, 43.20},	// 1130
	{CSW_FAMAS, "weapon_famas", "Star RU-35", 1, 144, 37.14},			// 1135
	{CSW_GALIL, "weapon_galil", "HK MP7 PDW", 1, 146, 37.32},			// 1140
	{CSW_AUG, "weapon_aug", "Taurus MT-9", 1, 148, 34.94},			// 1145
	{CSW_SG552, "weapon_sg552", "American-180", 1, 150, 33.94},		// 1150
	{CSW_AK47, "weapon_ak47", "PP19 Vityaz", 150, 152, 31.00},			// 1155
	{CSW_M4A1, "weapon_m4a1", "UD M42", 1, 155, 35.42},			 	// 1160
	
	{CSW_MAC10, "weapon_mac10", "Ingram MAC M10", 150, 157, 39.61},	// 1165
	{CSW_TMP, "weapon_tmp", "Star Z-62", 1, 160, 59.58},			 	// 1170
	{CSW_M3, "weapon_m3", " SCK-65", 150, 162, 3.39},			 		// 598
	{CSW_UMP45, "weapon_ump45", "STA M 1922", 1, 165, 39.52},		// 1175
	{CSW_XM1014, "weapon_xm1014", "Thompson", 150, 167, 4.69},		// 535
	{CSW_P90, "weapon_p90", "K6-92 / Borz", 1, 170, 57.00},			// 1180
	{CSW_MP5NAVY, "weapon_mp5navy", "Nambu 1966", 150, 172, 45.40},	// 1185
	{CSW_FAMAS, "weapon_famas", "CZ Vz. 38", 1, 175, 39.04},			// 1190
	{CSW_GALIL, "weapon_galil", "Skorpion EVO III", 150, 177, 39.21},		// 1195
	{CSW_AUG, "weapon_aug", "SIG-Sauer MPX", 1, 180, 36.71},			// 1200
	{CSW_SG552, "weapon_sg552", "FBP m/948", 1, 185, 35.66},			// 1205
	{CSW_AK47, "weapon_ak47", "PP-19 Bizon", 1, 190, 32.58},			// 1210
	{CSW_M4A1, "weapon_m4a1", "MP.41 Schmeisser", 1, 200, 37.20}		// 1215
};

new const __SECONDARY_WEAPONS[][structWeapons] = {
	{CSW_GLOCK18, "weapon_glock18", "Glock 18C", 1, 0, 1.0},				// 24
	{CSW_FIVESEVEN, "weapon_fiveseven", "FiveseveN", 50, 0, 1.5},			// 28 (19 default)
	{CSW_USP, "weapon_usp", "USP .45 ACP Tactical", 100, 0, 1.0},			// 33
	{CSW_P228, "weapon_p228", "P228 Compact", 150, 0, 1.2},				// 37 (31 default)
	{CSW_ELITE, "weapon_elite", "Dual Elite Berettas", 200, 0, 1.2},				// 42 (35 default)
	{CSW_DEAGLE, "weapon_deagle", "Desert Eagle .50 AE", 250, 0, 1.0},		// 52
	
	{CSW_GLOCK18, "weapon_glock18", "FN Browning M1900", 1, 1, 2.42},	// 58
	{CSW_FIVESEVEN, "weapon_fiveseven", "Steyr GB", 50, 1, 3.37},			// 64
	{CSW_USP, "weapon_usp", "Bergmann Bayard M1910", 100, 1, 2.13},			// 70
	{CSW_P228, "weapon_p228", "Bersa Thunder", 150, 1, 2.46},				// 76
	{CSW_ELITE, "weapon_elite", "Roth Steyr M1907", 200, 1, 2.35},			// 82
	{CSW_DEAGLE, "weapon_deagle", "Arcus 94 & 98DA", 250, 1, 1.70},			// 89
	
	{CSW_GLOCK18, "weapon_glock18", "FEG AP-63 PA-63", 1, 2, 3.92},		// 94
	{CSW_FIVESEVEN, "weapon_fiveseven", "Webley Scott", 50, 2, 5.27},		// 100
	{CSW_USP, "weapon_usp", "Frommer Stop", 100, 2, 3.22},			 	// 106
	{CSW_P228, "weapon_p228", "Taurus PT92", 150, 2, 3.62},			 	// 112
	{CSW_ELITE, "weapon_elite", "Arsenal P-M02", 200, 2, 3.38},			 	// 118
	{CSW_DEAGLE, "weapon_deagle", "Bergmann Mars", 250, 2, 2.39},			// 125
	
	{CSW_GLOCK18, "weapon_glock18", "FN Forty-Nine", 1, 3, 5.42},			// 130
	{CSW_FIVESEVEN, "weapon_fiveseven", "Steyr Hahn M1912", 50, 3, 7.16},	// 136
	{CSW_USP, "weapon_usp", "FN Browning HP", 100, 3, 4.31},			 	// 142
	{CSW_P228, "weapon_p228", "Ballester-Molina", 150, 3, 4.78},			 	// 148
	{CSW_ELITE, "weapon_elite", "Bersa Thunder 380", 205, 3, 4.41},			// 154
	{CSW_DEAGLE, "weapon_deagle", "FN FNP-45", 250, 3, 3.08},			 	// 161
	
	{CSW_GLOCK18, "weapon_glock18", "Luger 'Parabellum'", 1, 4, 6.92},		// 166
	{CSW_FIVESEVEN, "weapon_fiveseven", "FEMARU 29M", 50, 4, 9.06},		// 172
	{CSW_USP, "weapon_usp", "FEG P9M", 100, 4, 5.40},			 			// 178
	{CSW_P228, "weapon_p228", "Taurus 24/7", 150, 4, 5.94},			 	// 184
	{CSW_ELITE, "weapon_elite", "Welrod silent", 200, 4, 5.43},			 	// 190
	{CSW_DEAGLE, "weapon_deagle", "Mauser C-96", 250, 4, 3.77},			 	// 197
	
	{CSW_GLOCK18, "weapon_glock18", "HK VP9", 1, 5, 8.42},			 	// 202
	{CSW_FIVESEVEN, "weapon_fiveseven", "Walther P38", 100, 5, 10.95},		// 208
	{CSW_USP, "weapon_usp", "Korth", 200, 5, 6.49},			 			// 214
	{CSW_P228, "weapon_p228", "HK VP 70", 1, 6, 7.10},			 		// 220
	{CSW_ELITE, "weapon_elite", "Sauer 38H", 100, 6, 6.46},			 		// 226
	{CSW_DEAGLE, "weapon_deagle", "Jericho 941", 200, 6, 4.47},			 	// 233
	
	{CSW_GLOCK18, "weapon_glock18", "Astra A-80", 1, 7, 9.92},			 	// 238
	{CSW_FIVESEVEN, "weapon_fiveseven", "Viper JAWS", 100, 7, 12.85},		// 244
	{CSW_USP, "weapon_usp", "UZI pistol", 200, 7, 7.58},			 		// 250
	{CSW_P228, "weapon_p228", "Barak SP-21", 1, 8, 8.26},			 	// 256
	{CSW_ELITE, "weapon_elite", "Bul M5", 100, 8, 7.49},					// 262
	{CSW_DEAGLE, "weapon_deagle", "Llama M-82", 200, 8, 5.16},			// 269
	
	{CSW_GLOCK18, "weapon_glock18", "Tanfoglio T95", 1, 9, 11.42},		// 274
	{CSW_FIVESEVEN, "weapon_fiveseven", "Benelli B76", 100, 9, 14.74},		// 280
	{CSW_USP, "weapon_usp", "Bernardelli P-018", 200, 9, 8.67},			 	// 286
	{CSW_P228, "weapon_p228", "Bul Cherokee", 1, 10, 9.42},			 	// 292
	{CSW_ELITE, "weapon_elite", "Star 30M", 100, 10, 8.52},			 		// 298
	{CSW_DEAGLE, "weapon_deagle", "Para-Ordnance P14-45", 200, 10, 5.85},	// 305
	
	{CSW_GLOCK18, "weapon_glock18", "VIS wz.35", 1, 11, 12.92},			// 310
	{CSW_FIVESEVEN, "weapon_fiveseven", "QSZ-92", 100, 11, 16.64},			// 316
	{CSW_USP, "weapon_usp", "Obregon", 200, 11, 9.76},			 		// 322
	{CSW_P228, "weapon_p228", "Type 77", 1, 12, 10.59},			 		// 328
	{CSW_ELITE, "weapon_elite", "Model 77B", 100, 12, 9.55},			 		// 334
	{CSW_DEAGLE, "weapon_deagle", "P-64", 200, 12, 6.54},			 		// 341
	
	{CSW_GLOCK18, "weapon_glock18", "Stechkin APS", 1, 13, 14.42},		// 346
	{CSW_FIVESEVEN, "weapon_fiveseven", "Tokarev TT", 100, 13, 18.53},		// 352
	{CSW_USP, "weapon_usp", "Makarov PM", 200, 13, 10.85},			 		// 358
	{CSW_P228, "weapon_p228", "Wist-94", 1, 14, 11.75},			 		// 364
	{CSW_ELITE, "weapon_elite", "Korovin TK", 100, 14, 10.58},			 	// 370
	{CSW_DEAGLE, "weapon_deagle", "PSM", 200, 14, 7.24},			 		// 377
	
	{CSW_GLOCK18, "weapon_glock18", "MP-446", 1, 15, 15.92},			 	// 382
	{CSW_FIVESEVEN, "weapon_fiveseven", "OTs-23", 100, 15, 20.43},			// 388
	{CSW_USP, "weapon_usp", "SPP-1 underwater", 200, 15, 11.94},			// 394
	{CSW_P228, "weapon_p228", "APB silenced", 1, 16, 12.91},			 	// 400
	{CSW_ELITE, "weapon_elite", "GSh-18", 100, 16, 11.61},			 		// 406
	{CSW_DEAGLE, "weapon_deagle", "OTs-21", 200, 16, 7.93},			 	// 413
	
	{CSW_GLOCK18, "weapon_glock18", "K-100", 1, 17, 17.42},			 	// 418
	{CSW_FIVESEVEN, "weapon_fiveseven", "CZ-999", 100, 17, 22.32},			// 424
	{CSW_USP, "weapon_usp", "ASP", 200, 17, 13.04},			 			// 430
	{CSW_P228, "weapon_p228", "Strike One", 1, 18, 14.07},			 	// 436
	{CSW_ELITE, "weapon_elite", "M57", 100, 18, 12.63},			 		// 442
	{CSW_DEAGLE, "weapon_deagle", "FN Browning BDM", 200, 18, 8.62},		// 449
	
	{CSW_GLOCK18, "weapon_glock18", "Kahr K9", 1, 19, 18.92},			 	// 454
	{CSW_FIVESEVEN, "weapon_fiveseven", "S&W Sigma", 100, 19, 24.22},		// 460
	{CSW_USP, "weapon_usp", "Ruger SR9", 200, 19, 14.13},			 		// 466
	{CSW_P228, "weapon_p228", "Gyrojet", 1, 20, 15.23},			 		// 472
	{CSW_ELITE, "weapon_elite", "Colt Gov't / M1911", 100, 20, 13.66},			// 478
	{CSW_DEAGLE, "weapon_deagle", "Bren Ten", 200, 20, 9.31},			 	// 485
	
	{CSW_GLOCK18, "weapon_glock18", "LAR Grizzly", 1, 21, 20.42},			// 490
	{CSW_FIVESEVEN, "weapon_fiveseven", "AMP Auto Mag", 100, 21, 26.11},	// 496
	{CSW_USP, "weapon_usp", "Coonan", 200, 21, 15.22},			 			// 502
	{CSW_P228, "weapon_p228", "Goncz GA-9", 1, 22, 16.39},			 	// 508
	{CSW_ELITE, "weapon_elite", "Intratec DC-9", 100, 22, 14.69},			 	// 514
	{CSW_DEAGLE, "weapon_deagle", "Kel-tec P-11", 200, 22, 10.01},			// 521
	
	{CSW_GLOCK18, "weapon_glock18", "Yavuz 16", 1, 23, 21.92},			// 526
	{CSW_FIVESEVEN, "weapon_fiveseven", "MPA Defender", 100, 23, 28.01},	// 532
	{CSW_USP, "weapon_usp", "Ruger SR9", 200, 23, 16.31},			 		// 538
	{CSW_P228, "weapon_p228", "Boberg XR-9", 1, 24, 17.55},			 	// 544
	{CSW_ELITE, "weapon_elite", "FN FNP-45", 100, 24, 15.72},			 	// 550
	{CSW_DEAGLE, "weapon_deagle", "Akdal Ghost", 200, 24, 10.70},			// 557
	
	{CSW_GLOCK18, "weapon_glock18", "Mle. 1950", 1, 25, 23.42},			// 562
	{CSW_FIVESEVEN, "weapon_fiveseven", "Shevchenko PSh", 150, 25, 29.90},	// 568
	{CSW_USP, "weapon_usp", "Lahti L-35", 1, 26, 17.40},			 		// 574
	{CSW_P228, "weapon_p228", "Sarsilmaz K2-45", 150, 26, 18.71},			// 580
	{CSW_ELITE, "weapon_elite", "Fort 12", 1, 27, 16.75},			 		// 586
	{CSW_DEAGLE, "weapon_deagle", "MAB PA-15", 150, 27, 11.39},			// 593
	
	{CSW_GLOCK18, "weapon_glock18", "B+T VP-9", 1, 28, 24.92},			// 598
	{CSW_FIVESEVEN, "weapon_fiveseven", "SIG-Sauer P220", 150, 28, 31.79},	// 604
	{CSW_USP, "weapon_usp", "Sphinx 2000", 1, 29, 18.49},			 	// 610
	{CSW_P228, "weapon_p228", "IM Metal HS 2000", 150, 29, 19.88},			// 616
	{CSW_ELITE, "weapon_elite", "CZ-G 2000", 1, 30, 17.78},			 	// 622
	{CSW_DEAGLE, "weapon_deagle", "Husqvarna M/40", 150, 30, 12.08},		// 629
	
	{CSW_GLOCK18, "weapon_glock18", "Caracal", 1, 31, 26.42},			 	// 634
	{CSW_FIVESEVEN, "weapon_fiveseven", "Daewoo DP-51", 150, 31, 33.69},	// 640
	{CSW_USP, "weapon_usp", "Nambu Type 14", 1, 32, 19.58},			 	// 646
	{CSW_P228, "weapon_p228", "Vektor CP1", 150, 32, 21.04},			 	// 652
	{CSW_ELITE, "weapon_elite", "ADP", 1, 33, 18.80},			 		// 658
	{CSW_DEAGLE, "weapon_deagle", "Tara TM9", 150, 33, 12.77},			 	// 665
	
	{CSW_GLOCK18, "weapon_glock18", "Webley-Fosbery", 1, 34, 27.92},		// 670
	{CSW_FIVESEVEN, "weapon_fiveseven", "Webley", 150, 34, 35.58},			// 676
	{CSW_USP, "weapon_usp", "Enfield Mk 1", 1, 35, 20.67},			 	// 682
	{CSW_P228, "weapon_p228", "Nagant mle.1895", 150, 35, 22.20},			// 688
	{CSW_ELITE, "weapon_elite", "FN Barracuda", 1, 36, 19.83},			 	// 694
	{CSW_DEAGLE, "weapon_deagle", "FN Browning BDM", 150, 36, 13.47},		// 701
	
	{CSW_GLOCK18, "weapon_glock18", "Mauser HSc", 1, 37, 29.42},			// 706
	{CSW_FIVESEVEN, "weapon_fiveseven", "FEMARU 29M", 150, 37, 37.48},		// 712
	{CSW_USP, "weapon_usp", "FEG P9R", 1, 38, 21.76},			 		// 718
	{CSW_P228, "weapon_p228", "FN FNP-9 / PRO-9", 150, 38, 23.36},			// 724
	{CSW_ELITE, "weapon_elite", "Taurus PT111", 1, 39, 20.86},			// 730
	{CSW_DEAGLE, "weapon_deagle", "HK-4", 150, 39, 14.16},			 	// 737
	
	{CSW_GLOCK18, "weapon_glock18", "Walther P88", 1, 40, 30.92},			// 742
	{CSW_FIVESEVEN, "weapon_fiveseven", "Astra mod. 400 & 600", 150, 40, 39.37},	// 748
	{CSW_USP, "weapon_usp", "Star Ultrastar", 1, 41, 22.85},			 	// 754
	{CSW_P228, "weapon_p228", "HK P11 underwater", 150, 41, 24.52},		// 760
	{CSW_ELITE, "weapon_elite", "Beretta 93R", 1, 42, 21.89},			 	// 766
	{CSW_DEAGLE, "weapon_deagle", "Tanfoglio Force", 150, 42, 14.85},		// 773
	
	{CSW_GLOCK18, "weapon_glock18", "OTs-27", 1, 43, 32.42},			 	// 778
	{CSW_FIVESEVEN, "weapon_fiveseven", "PB silenced", 150, 43, 41.27},		// 784
	{CSW_USP, "weapon_usp", "PSS silent", 1, 44, 23.94},			 		// 790
	{CSW_P228, "weapon_p228", "Type 80", 150, 44, 25.68},			 		// 796
	{CSW_ELITE, "weapon_elite", "P-83", 1, 45, 22.92},			 		// 802
	{CSW_DEAGLE, "weapon_deagle", "MP-448", 150, 45, 15.54},			 	// 809
	
	{CSW_GLOCK18, "weapon_glock18", "Ruger P-series", 1, 46, 33.92},		// 814
	{CSW_FIVESEVEN, "weapon_fiveseven", "Colt SSP", 150, 46, 43.16},			// 820
	{CSW_USP, "weapon_usp", "S&W 39", 1, 47, 25.04},			 		// 826
	{CSW_P228, "weapon_p228", "M70", 150, 47, 26.84},			 		// 832
	{CSW_ELITE, "weapon_elite", "CZ-99", 1, 48, 23.95},			 		// 838
	{CSW_DEAGLE, "weapon_deagle", "Wildey", 150, 48, 16.24},			 	// 845
	
	{CSW_GLOCK18, "weapon_glock18", "Mle. 1935A", 1, 49, 35.42},			// 850
	{CSW_FIVESEVEN, "weapon_fiveseven", "Sarsilmaz Kilinc 2000", 150, 49, 45.06},	// 856
	{CSW_USP, "weapon_usp", "Fort 14", 1, 50, 26.13},			 			// 862
	{CSW_P228, "weapon_p228", "AMT Automag II-V", 1, 51, 28.01},			// 868
	{CSW_ELITE, "weapon_elite", "Kel-tec PF-9", 1, 52, 24.98},			 	// 874
	{CSW_DEAGLE, "weapon_deagle", "Colt Double Eagle", 1, 53, 16.93},		// 881
	
	{CSW_GLOCK18, "weapon_glock18", "Nambu Type 94", 1, 54, 36.92},		// 886
	{CSW_FIVESEVEN, "weapon_fiveseven", "Vektor SP1 & SP2", 1, 55, 46.95},	// 892
	{CSW_USP, "weapon_usp", "Colt 1873 SAA", 1, 56, 27.22},			 	// 898
	{CSW_P228, "weapon_p228", "CZ 110", 1, 57, 29.17},			 		// 904
	{CSW_ELITE, "weapon_elite", "Sphinx 3000", 1, 58, 26.01},			 	// 910
	{CSW_DEAGLE, "weapon_deagle", "Mle. 1935A", 1, 59, 17.62}			 	// 916
};

new const __GRENADES[][structGrenades] = {
	{1, 1, 1, "Fuego - Hielo - Luz", 0, 0, 0, 1, 0},
	{1, 2, 1, "Fuego - Hielo x2 - Luz", 0, 0, 0, 1, 1},
	{1, 2, 2, "Fuego - Hielo x2 - Luz x2", 0, 0, 0, 1, 2},
	{2, 2, 2, "Fuego x2 - Hielo x2 - Luz x2", 0, 0, 0, 1, 3},

	{1, 1, 1, "Fuego - Supernova - Luz", 0, 1, 0, 1, 4},
	{1, 1, 2, "Fuego - Supernova - Luz x2", 0, 1, 0, 1, 5},
	{2, 1, 2, "Fuego x2 - Supernova - Luz x2", 0, 1, 0, 1, 6},
	{2, 2, 2, "Fuego x2 - Supernova x2 - Luz x2", 0, 1, 0, 1, 7},

	{1, 1, 1, "Droga - Hielo - Luz", 1, 0, 0, 1, 8},
	{1, 1, 2, "Droga - Hielo - Luz x2", 1, 0, 0, 1, 9},
	{1, 2, 2, "Droga - Hielo x2 - Luz x2", 1, 0, 0, 1, 10},
	{2, 2, 2, "Droga x2 - Hielo x2 - Luz x2", 1, 0, 0, 1, 12},

	{1, 1, 1, "Fuego - Hielo - Bubble", 0, 0, 1, 1, 14},
	{1, 2, 1, "Fuego - Hielo x2 - Bubble", 0, 0, 1, 1, 16},
	{2, 2, 1, "Fuego x2 - Hielo x2 - Bubble", 0, 0, 1, 1, 18},
	{2, 2, 2, "Fuego x2 - Hielo x2 - Bubble x2", 0, 0, 1, 1, 20},

	{1, 1, 1, "Droga - Supernova - Luz", 1, 1, 0, 1, 22},
	{1, 1, 2, "Droga - Supernova - Luz x2", 1, 1, 0, 1, 24},
	{1, 2, 2, "Droga - Supernova x2 - Luz x2", 1, 1, 0, 1, 26},
	{2, 2, 2, "Droga x2 - Supernova x2 - Luz x2", 1, 1, 0, 1, 28},

	{1, 1, 1, "Fuego - Supernova - Bubble", 0, 1, 1, 1, 30},
	{2, 1, 1, "Fuego x2 - Supernova - Bubble", 0, 1, 1, 1, 35},
	{2, 2, 1, "Fuego x2 - Supernova x2 - Bubble", 0, 1, 1, 1, 40},
	{2, 2, 2, "Fuego x2 - Supernova x2 - Bubble x2", 0, 1, 1, 1, 45},

	{1, 1, 1, "Droga - Hielo - Bubble", 1, 0, 1, 1, 50},
	{1, 2, 1, "Droga - Hielo x2 - Bubble", 1, 0, 1, 1, 60},
	{2, 2, 1, "Droga x2 - Hielo x2 - Bubble", 1, 0, 1, 1, 70},
	{2, 2, 2, "Droga x2 - Hielo x2 - Bubble x2", 1, 0, 1, 1, 80},

	{3, 2, 2, "Droga x3 - Supernova x2 - Bubble x2", 1, 1, 1, 1, 100}
};

new const __WEAPON_DATA[][structWeaponDatas] = {
	{"P228 Compact", CSW_P228},
	{"XM1014 M4", CSW_XM1014},
	{"Ingram MAC-10", CSW_MAC10},
	{"Steyr AUG A1", CSW_AUG},
	{"Dual Elite Berettas", CSW_ELITE},
	{"FiveseveN", CSW_FIVESEVEN},
	{"UMP 45", CSW_UMP45},
	{"IMI Galil", CSW_GALIL},
	{"Famas", CSW_FAMAS},
	{"USP .45 ACP Tactical", CSW_USP},
	{"Glock 18C", CSW_GLOCK18},
	{"MP5 Navy", CSW_MP5NAVY},
	// {"M249 Para Machinegun", CSW_M249},
	{"M3 Super 90", CSW_M3},
	{"M4A1 Carbine", CSW_M4A1},
	{"Schmidt TMP", CSW_TMP},
	{"Desert Eagle .50 AE", CSW_DEAGLE},
	{"SG-552 Commando", CSW_SG552},
	{"AK-47 Kalashnikov", CSW_AK47},
	{"ES P90", CSW_P90},
	{"Cuchillo", CSW_KNIFE}
};

new const Float:__WEAPON_DAMAGE_DEFAULT[31] = {
	-1.0,
	16.0, // P228
	-1.0,
	-1.0,
	-1.0,
	64.0, // XM1014
	-1.0,
	32.0, // MAC10
	48.0, // AUG
	-1.0,
	16.0, // ELITE
	16.0, // FIVESEVEN
	32.0, // UMP45
	-1.0,
	48.0, // GALIL
	48.0, // FAMAS
	16.0, // USP
	16.0, // GLOCK18
	-1.0,
	32.0, // MP5NAVY
	64.0, // M249
	64.0, // M3
	48.0, // M4A1
	32.0, // TMP
	-1.0,
	-1.0,
	16.0, // DEAGLE
	48.0, // SG552
	48.0, // AK47
	50.0, // CUCHILLO
	16.0 // P90
};

new const __WEAPON_MODELS[][][structWeaponModels] = {
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

new const Float:__WEAPON_DAMAGE_NEED[31][] = {
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

new const __WEAPONS_DIAMMONDS_NEED[31][] = {
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

new const __EXTRA_ITEMS[structIdExtraItems][structExtraItems] = {
	{"Visión nocturna", 20, 0, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Long Jump", 30, 0, 3, 5, EXTRA_ITEM_TEAM_HUMAN},
	{"Invisibilidad", 45, 5, 3, 5, EXTRA_ITEM_TEAM_HUMAN},
	{"Balas Infinitas", 75, 0, 7, 6, EXTRA_ITEM_TEAM_HUMAN},
	{"Precisión Perfecta", 75, 0, 7, 6, EXTRA_ITEM_TEAM_HUMAN},
	{"Bomba Aniquiladora", 175, 1, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Bomba Pipe", 150, 1, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Bomba Antídoto", 125, 1, 0, 0, EXTRA_ITEM_TEAM_HUMAN},

	{"Antídoto", 30, 5, 0, 0, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Furia Zombie", 40, 3, 0, 0, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Bomba de Infección", 100, 1, 0, 0, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Long Jump", 20, 0, 3, 5, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Reducción de daño", 50, 1, 7, 6, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Petrificación", 50, 1, 7, 6, EXTRA_ITEM_TEAM_ZOMBIE}
};

new const __DIFFICULTS_CLASSES[structIdDifficultsClasses][] = {
	"SURVIVOR", "WESKER", "LEATHERFACE", "NEMESIS", "CABEZÓN", "ANIQUILADOR"
};

new const __DIFFICULTS[structIdDifficultsClasses][structIdDifficults][structDifficults] = {
	{ // Survivor
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"DIFÍCIL", "Difícil", "Vida: \r-20%\w | Velocidad: \r-10%\w", 0.8, 0.9},
		{"MUY DIFÍCIL", "Muy Difícil", "Vida: \r-40%\w | Velocidad: \r-20%\w | Sin inmunidad y niebla mínima", 0.6, 0.8},
		{"EXPERTO", "Experto", "Vida: \r-60%\w | Velocidad: \r-30%\w | Sin bomba, ni inmunidad y niebla máxima", 0.4, 0.7}
	}, { // Wesker
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"DIFÍCIL", "Difícil", "Vida: \r-15%\w | Velocidad: \r-15%\w", 0.85, 0.85},
		{"MUY DIFÍCIL", "Muy Difícil", "Vida: \r-30%\w | Velocidad: \r-30%\w | Sin lasers", 0.7, 0.7},
		{"EXPERTO", "Experto", "Vida: \r-30%\w | Velocidad: \r-45%\w | Sin lasers y niebla mínima", 0.65, 0.65}
	}, { // Leatherface
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"DIFÍCIL", "Difícil", "Vida: \r-20%\w | Velocidad: \r-20%\w", 0.8, 0.8},
		{"MUY DIFÍCIL", "Muy Difícil", "Vida: \r-40%\w | Velocidad: \r-30%\w | Sin poder", 0.6, 0.7},
		{"EXPERTO", "Experto", "Vida: \r-60%\w | Velocidad: \r-40%\w | Sin poder y niebla mínima", 0.4, 0.6}
	}, { // Nemesis
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"DIFÍCIL", "Difícil", "Vida: \r-20%\w | Velocidad: \r-10%\w", 0.8, 0.9},
		{"MUY DIFÍCIL", "Muy Difícil", "Vida: \r-40%\w | Velocidad: \r-20%\w | Sin LJ y niebla mínima", 0.6, 0.8},
		{"EXPERTO", "Experto", "Vida: \r-60%\w | Velocidad: \r-30%\w | Sin LJ y niebla máxima", 0.4, 0.7}
	}, { // Cabezón
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"DIFÍCIL", "Difícil", "Vida: \r-15%\w | Velocidad: \r-15%\w", 0.85, 0.85},
		{"MUY DIFÍCIL", "Muy Difícil", "Vida: \r-30%\w | Velocidad: \r-30%\w | Solo tiene 1 intento", 0.7, 0.7},
		{"EXPERTO", "Experto", "Vida: \r-45%\w | Velocidad: \r-45%\w | Sin poder y niebla mínima", 0.65, 0.65}
	}, { // Aniquilador
		{"NORMAL", "Normal", "Estadísticas normales", 1.0, 1.0},
		{"DIFÍCIL", "Difícil", "Vida: \r-20%\w | Velocidad: \r-20%\w", 0.8, 0.8},
		{"MUY DIFÍCIL", "Muy Difícil", "Vida: \r-40%\w | Velocidad: \r-30%\w | Solo tiene 3 bazookas", 0.6, 0.7},
		{"EXPERTO", "Experto", "Vida: \r-60%\w | Velocidad: \r-40%\w | Solo tiene 2 bazookas y niebla mínima", 0.4, 0.6}
	}
};

new const __HABS_CLASSES[structIdHabsClasses][structHabsClasses] = {
	{"Humanas", "Puntos humanos", "pH", P_HUMAN},
	{"Zombies", "Puntos zombies", "pZ", P_ZOMBIE},
	{"Survivor", "Puntos de Legado", "pL", P_LEGACY},
	{"Wesker", "Puntos de Legado", "pL", P_LEGACY},
	{"Leatherface", "Puntos de Legado", "pL", P_LEGACY},
	{"Nemesis", "Puntos de Legado", "pL", P_LEGACY},
	{"Fleshpound", "Puntos de Legado", "pL", P_LEGACY},
	{"Extras", "Dinero", "SALDO", P_MONEY},
	{"Legendarias", "Diamantes", "DIAMANTES", P_DIAMONDS},
	{"Habilidades rotativas", "", "", -1},
	{"Cambiar puntos", "", "", -1},
	{"Reset", "", "", -1},
};

new const __HABS[structIdHabs][structHabs] = {
	{1, "Vida", "", 4, 6, 100, HAB_CLASS_HUMAN},
	{1, "Velocidad", "", 1, 6, 140, HAB_CLASS_HUMAN},
	{1, "Gravedad", "", 1, 6, 50, HAB_CLASS_HUMAN},
	{1, "Daño", "", 10, 6, 200, HAB_CLASS_HUMAN},
	{1, "Chaleco", "", 5, 6, 50, HAB_CLASS_HUMAN},
	{1, "T-Combo", "Aumentas la recompensa al finalizar el combo", 0, 100, 5, HAB_CLASS_HUMAN},

	{1, "Vida", "", 50000, 6, 200, HAB_CLASS_ZOMBIE},
	{1, "Velocidad", "", 1, 6, 120, HAB_CLASS_ZOMBIE},
	{1, "Gravedad", "", 1, 6, 50, HAB_CLASS_ZOMBIE},
	{1, "Daño", "", 3, 6, 50, HAB_CLASS_ZOMBIE},
	{1, "Resistencia al fuego", "\r - \yNivel 1\r:\w Las bombas incendiarias te quita menos vida^n\r - \yNivel 2\r:\w La reducción de velocidad de movimiento se reduce^n\r - \yNivel 3\r:\w No te incendias al tocar un Zombie que esté en llamas", 0, 24, 3, HAB_CLASS_ZOMBIE},
	{1, "Resistencia al hielo", "\r - \yNivel 1\r:\w La reducción de velocidad de movimiento se reduce^n\r - \yNivel 2\r:\w Menos tiempo de congelación^n\r - \yNivel 3\r:\w Las bombas incendiarias no te afectan cuando estés congelado", 0, 24, 3, HAB_CLASS_ZOMBIE},
	{1, "Combo Zombie", "Habilita el combo zombie", 0, 100, 1, HAB_CLASS_ZOMBIE},

	{1, "Vida", "", 500, 12, 10, HAB_CLASS_S_SURVIVOR},
	{1, "Daño", "", 2500, 24, 10, HAB_CLASS_S_SURVIVOR},
	{1, "Velocidad de disparo", "Aumenta la velocidad con la que disparas", 0, 18, 5, HAB_CLASS_S_SURVIVOR},
	{1, "Bomba extra", "Te otorga una bomba de aniquilación extra", 0, 75, 1, HAB_CLASS_S_SURVIVOR},
	{1, "Inmunidad extra (10 seg.)", "Hace que tu inmunidad dure 10 segundos más", 0, 50, 1, HAB_CLASS_S_SURVIVOR},

	{1, "Ultra Laser", "El laser puede matar a más de un zombie", 0, 100, 1, HAB_CLASS_S_WESKER},
	{1, "Combo", "Habilita el combo wesker", 0, 100, 1, HAB_CLASS_S_WESKER},

	{1, "Teletransportación", "Puedes teletransportarte hacia un Spawn del mapa", 0, 100, 1, HAB_CLASS_S_LEATHERFACE},
	{1, "Combo", "Habilita el combo Leatherface", 0, 100, 1, HAB_CLASS_S_LEATHERFACE},
	{1, "Daño extra", "Aumenta el doble de daño en la motocierra", 0, 175, 1, HAB_CLASS_S_LEATHERFACE},

	{1, "Vida", "", 1000000, 12, 10, HAB_CLASS_S_NEMESIS},
	{1, "Daño", "", 25, 24, 10, HAB_CLASS_S_NEMESIS},
	{1, "Seguimiento de Bazooka", "Hace que tu bazooka tenga un nuevo modo de seguimiento^nPuedes alternar el modo a través del clic derecho", 0, 100, 1, HAB_CLASS_S_NEMESIS},
	{1, "Radio de Bazooka", "Hace que tu bazooka alcanze 250 unidades más", 0, 75, 1, HAB_CLASS_S_NEMESIS},
	{1, "Bazooka extra", "Puedes lanzar una bazooka una vez más", 0, 150, 1, HAB_CLASS_S_NEMESIS},

	{0, "Radio de poder", "Hace que tu poder alcanze 350 unidades más", 0, 75, 1, HAB_CLASS_S_FLESHPOUND},
	{0, "Poder de vuelta", "Cada 30 segundos, puedes volver a tirar tu poder", 0, 150, 1, HAB_CLASS_S_FLESHPOUND},

	{1, "Duración de Bubble (2 seg.)", "Aumenta la duración de la granada Bubble", 10, 100, 5, HAB_CLASS_EXTRAS},
	{1, "Furia Prolongada (0.5 seg.)", "Aumenta la duración de tu furia zombie", 1, 75, 4, HAB_CLASS_EXTRAS},
	{1, "Duración de Combo (0.5 seg.)", "Aumenta la duración de tu combo humano/zombie", 1, 125, 5, HAB_CLASS_EXTRAS},
	{1, "Alternar bombas", "Puedes alternar el modo de las granadas en caso^nde ser necesario", 1, 50, 1, HAB_CLASS_EXTRAS},

	{1, "Daño Legendario", "Aumentas el valor del daño humano al aumentar su habilidad", 5, 25, 10, HAB_CLASS_LEGENDARY},
	{1, "Vida Legendaria", "Aumentas el valor de la vida zombie al aumentar su habilidad", 5000, 25, 10, HAB_CLASS_LEGENDARY},
	{1, "Multiplicador de AmmoPacks", "Aumentas minimamente tu multiplicador de AmmoPacks", 0, 15, 25, HAB_CLASS_LEGENDARY},
	{1, "Multiplicador de XP", "Aumentas minimamente tu multiplicador de XP", 0, 20, 10, HAB_CLASS_LEGENDARY},
	{1, "Reiniciar costo de Items Extras", "El costo de tus Items extras vuelven a su valor por defecto", 0, 0, 0, HAB_CLASS_LEGENDARY},
	{1, "Subir de nivel todas las armas", "Subes de a 1 nivel todas las armas", 0, 12, 10, HAB_CLASS_LEGENDARY},
	{1, "Vigor", "Aumentas el daño en porcentaje del daño total", 10, 10, 10, HAB_CLASS_LEGENDARY},
	{1, "Respawn humano", "Aumentas la probablidad de respawnear como humano", 4, 30, 5, HAB_CLASS_LEGENDARY},

	{1, "Arma mejorada", "\r - \wNivel 0\r:\y MP5 Navy^n\r - \wNivel 1\r:\y M249 Para Machinegun^n\r - \wNivel 2\r:\y M4A1 Carbine", 0, 48, 2, HAB_CLASS_S_SURVIVOR},
	{1, "Doble ganancia", "Una vez finalizado el combo, se otorgará un \y[N]%\w de XP^nextra. La ganancia afecta cuando estás en grupo pero solo un \y50%\w", 5, 30, 10, HAB_CLASS_LEGENDARY}
};

new const __HABS_ROTATE[structIdHabsRotate][structHabsRotate] = {
	{"Ultimas palabras", "Tienes 5 segundos de inmunidad siendo último humano al tener menos^nde 50 de Vida", 20},
	{"Survivor Damegous", "Aumenta un 30% de daño siendo Survivor (sólo en modo Survivor)", 40},
	{"Nemesis Videigous", "Aumenta un 30% de vida siendo Nemesis (sólo en modo Nemesis)", 40},
	{"Infinitamente infinito", "Reduce el costo de las Balas infinitas en un 50%", 25},
	{"Precisamente perfecto", "Reduce el costo de la Presición perfecta en un 50%", 25},
	{"Spartan, no el gorro", "Aumenta un 150% de daño con cuchillo", 75},
	{"Regeneration", "Cada 2.5s aumentas 500 de vida zombie acumulable", 60},
	{"Porta cuchillos", "Aumenta un 25% de velocidad de movimiento al tener cuchillo en mano", 40},
	{"Secundarias útiles", "Aumenta un 75% de daño a las pistolas", 50},
	{"Sopa de cerebros", "Aumenta un 30% de ganancias a infectar", 20},
	{"Vampirismo", "Aumenta un 20% de tu vida máxima al infectar", 20},
	{"Cabeza dura", "Diminuye un 30% de daño en la cabeza a los zombies", 35},
	{"Multiplicando", "Aumenta un +x1 al multiplicador de combo", 75},
	{"Precios cuidados", "Disminuye un 15% el costo de todos los Items Extras", 45},
	{"Blindaje asesino", "Aumenta un 10% en la resistencia siendo zombie", 30}
};

new const __ACHIEVEMENTS_CLASSES[structIdAchievementClasses][] =  {
	"Humanos", "Zombies", "Modos", "Otros", "Beta", "Primeros", "Armas", "Items Extras", "Navidad"
};

new const __ACHIEVEMENTS[structIdAchievements][structAchievements] = {
	{0, "BETA TESTER DIA #1", "Participa en el día #1 de la BETA del Zombie Plague v7 \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_BETA},
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
	{1, "SOY DORADO", "Ser usuario PREMIUM", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
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
	{1, "MI CUCHILLA Y YO", "Mata a todos los jugadores siendo ANIQUILADOR", 10, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ANIQUILOSO", "Mata a 300 humanos con la cuchilla", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "CIENFUEGOS", "Mata a 100 humanos con la bazooka", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "CARNE", "Mata a 300 humanos", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "¡MUCHA CARNE!", "Mata a 400 humanos", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "¡DEMASIADA CARNE!", "Mata a 500 humanos", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "¡CARNE PARA TODOS!", "Mata a 625 humanos", 20, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "EL PEOR DEL SERVER", "Utiliza tus 5 bazookas sin matar a nadie", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "OOPS! MATÉ A TODOS", "Mata a todos los humanos con una bazooka", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MI MAC-10 ESTÁ LLENA", "Termina la ronda sin utilizar tu MAC-10", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SOY UN MANCO", "Terminar la ronda sin matar a nadie con tu MAC-10^n gastando todas las balas", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "50 SON 50", "Mata 50 humanos con tu MAC-10", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "YO SI PEGO CON ESTO", "Mata 100 humanos con tu MAC-10", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MUCHA PRECISIÓN", "Mata 130 humanos con tu MAC-10", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
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
	{1, "SOY MUY NOOB", "Se el primero en morir en un DUELO FINAL", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ACUCHILLADOS", "Mata a 5 humanos en Duelo final de Cuchillos", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "AFICIONADO EN CUCHI", "Mata a 10 humanos en Duelo final de Cuchillos", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ENTRAN CUCHILLO SALEN LAS TRIPAS", "Mata a 15 humanos en Duelo final de Cuchillos", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "TODO UN AWPER", "Mata a 5 humanos en Duelo final de AWP", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "EXPERTO EN AWP", "Mata a 10 humanos en Duelo final de AWP", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "PRO AWP", "Mata a 15 humanos en Duelo final de AWP", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "DETONADOS", "Mata a 5 humanos en Duelo final de HE", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "BOMBAZO PARA TODOS", "Mata a 10 humanos en Duelo final de HE", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "BOOM.. EN TODA LA CARA", "Mata a 15 humanos en Duelo final de HE", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MI PRIMER DUELO", "Gana un DUELO FINAL", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "VAMOS BIEN", "Gana cinco DUELOS FINALES", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "DEMASIADO FÁCIL", "Gana diez DUELOS FINALES", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "COMBO x1.000", "Realiza un combo de 1.000", 2, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x5.000", "Realiza un combo de 5.000", 5, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x25.000", "Realiza un combo de 25.000", 10, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x75.000", "Realiza un combo de 75.000", 15, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x150.000", "Realiza un combo de 150.000", 20, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x500.000", "Realiza un combo de 500.000", 25, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x2.500.000", "Realiza un combo de 2.500.000", 35, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x10.000.000", "Realiza un combo de 10.000.000", 50, 8, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "COMBO x2 ZOMBIE", "Realiza un combo zombie de 2 infecciones", 2, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO x5 ZOMBIE", "Realiza un combo zombie de 5 infecciones", 5, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO x8 ZOMBIE", "Realiza un combo zombie de 8 infecciones", 10, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO x11 ZOMBIE", "Realiza un combo zombie de 11 infecciones", 15, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO x14 ZOMBIE", "Realiza un combo zombie de 14 infecciones", 20, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO x17 ZOMBIE", "Realiza un combo zombie de 17 infecciones", 25, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO x20 ZOMBIE", "Realiza un combo zombie de 20 infecciones", 35, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "COMBO x24 ZOMBIE", "Realiza un combo zombie de 24 infecciones", 50, 8, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "VISIÓN NOCTURNA x10", "Compra 10 veces el item extra Visión Nocturna", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "INVISIBILIDAD x10", "Compra 10 veces el item extra Invisibilidad", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BALAS INFINITAS x10", "Compra 10 veces el item extra Balas Infinitas", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PRECISIÓN PERFECTA x10", "Compra 10 veces el item extra Precisión perfecta", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE ANIQUILACIÓN x10", "Compra 10 veces el item extra Bomba de Aniquilación", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA PIPE x10", "Compra 10 veces el item extra Bomba Molotov", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA ANTIDOTO x10", "Compra 10 veces el item extra Bomba Antidoto", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ANTIDOTO x10", "Compra 10 veces el item extra Antidoto", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "FURIA ZOMBIE x10", "Compra 10 veces el item extra Furia Zombie", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE INFECCIÓN x10", "Compra 10 veces el item extra Bomba de Infección", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "REDUCCIÓN DE DAÑO x10", "Compra 10 veces el item extra Reducción de daño", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PETRIFICACIÓN x10", "Compra 10 veces el item extra Petrificación", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "VISIÓN NOCTURNA x50", "Compra 50 veces el item extra Visión Nocturna", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "INVISIBILIDAD x50", "Compra 50 veces el item extra Invisibilidad", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BALAS INFINITAS x50", "Compra 50 veces el item extra Balas Infinitas", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PRECISIÓN PERFECTA x50", "Compra 50 veces el item extra Precisión perfecta", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE ANIQUILACIÓN x50", "Compra 50 veces el item extra Bomba de Aniquilación", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA PIPE x50", "Compra 50 veces el item extra Bomba Molotov", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA ANTIDOTO x50", "Compra 50 veces el item extra Bomba Antidoto", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ANTIDOTO x50", "Compra 50 veces el item extra Antidoto", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "FURIA ZOMBIE x50", "Compra 50 veces el item extra Furia Zombie", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE INFECCIÓN x50", "Compra 50 veces el item extra Bomba de Infección", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "REDUCCIÓN DE DAÑO x50", "Compra 50 veces el item extra Reducción de daño", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PETRIFICACIÓN x50", "Compra 50 veces el item extra Petrificación", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "VISIÓN NOCTURNA x100", "Compra 100 veces el item extra Visión Nocturna", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "INVISIBILIDAD x100", "Compra 100 veces el item extra Invisibilidad", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BALAS INFINITAS x100", "Compra 100 veces el item extra Balas Infinitas", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PRECISIÓN PERFECTA x100", "Compra 100 veces el item extra Precisión perfecta", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE ANIQUILACIÓN x100", "Compra 100 veces el item extra Bomba de Aniquilación", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA PIPE x100", "Compra 100 veces el item extra Bomba Molotov", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA ANTIDOTO x100", "Compra 100 veces el item extra Bomba Antidoto", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "ANTIDOTO x100", "Compra 100 veces el item extra Antidoto", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "FURIA ZOMBIE x100", "Compra 100 veces el item extra Furia Zombie", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "BOMBA DE INFECCIÓN x100", "Compra 100 veces el item extra Bomba de Infección", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "REDUCCIÓN DE DAÑO x100", "Compra 100 veces el item extra Reducción de daño", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "PETRIFICACIÓN x100", "Compra 100 veces el item extra Petrificación", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
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
	{0, "ME GUSTAN LOS RETOS", "Gana diez desafíos \r(LOGRO DESHABILITADO)", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{0, "¿A ESTO LE LLAMÁS DESAFÍOS?", "Completa 20 desafíos \r(LOGRO DESHABILITADO)", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{0, "CHALLENGE ACEPTED", "Completa 25 desafíos \r(LOGRO DESHABILITADO)", 25, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{0, "BETA TESTER DIA #2", "Participa en el día #2 de la BETA del Zombie Plague v7 \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_BETA},
	{0, "SUPER BETA TESTER DIA #2", "Acumula 2 horas jugadas en el día #2 de la BETA del Zombie Plague v7 \r(LOGRO DESHABILITADO)", 10, 0, 0, ACHIEVEMENT_CLASS_BETA},
	{1, "100 AL ROJO", "Acumula 100 cabezas zombie rojas", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "¿75 AL VERDE?", "Acumula 75 cabezas zombie verdes", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "50 PITUFOS", "Acumula 50 cabezas zombie azules", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "25 Y SIGO", "Acumula 25 cabezas zombie amarillas", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "COLORIDO", "Agarra cabezas zombies de todos los colores", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{0, "¿ARE YOU FUCKING KIDDING ME?", "Consigue ser el PRIMER ZOMBIE \r(LOGRO DESHABILITADO)", 5, 0, 15, ACHIEVEMENT_CLASS_ZOMBIE},
	{0, "¿YA DE ZOMBIE?", "Consigue ser el PRIMER ZOMBIE dos veces seguidas \r(LOGRO DESHABILITADO)", 10, 0, 15, ACHIEVEMENT_CLASS_ZOMBIE},
	{1, "ANIQUILA ANIQUILADOR", "Lanza la bomba aniquilación sin matar a nadie", 5, 0, 15, ACHIEVEMENT_CLASS_MODES},
	{1, "NO LA NECESITO", "Has explotar la bomba de aniquilación sin matar a nadie", 5, 0, 15, ACHIEVEMENT_CLASS_HUMAN},
	{1, "EL VERDULERO", "Roba un tomate de la Verdulería en el mapa^n\yzm_kontrax_b5_buffed\w", 5, 0, 15, ACHIEVEMENT_CLASS_OTHERS},
	{1, "BAN LOCAL", "Mata a un miembro del Staff siendo zombie con cuchillo", 10, 0, 15, ACHIEVEMENT_CLASS_OTHERS},
	{1, "SENTA2", "Mata a 5 humanos en Duelo final de Only Head", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "¡PUM! BALAAAAAAZO", "Mata a 10 humanos en Duelo final de Only Head", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "THE KILLER OF DK", "Mata a 15 humanos en Duelo final de Only Head", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MI PRIMER REGALO", "Recoge un regalo", 1, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "ACUMULANDO", "Acumula 25 regalos", 5, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "MÁS REGALOS", "Acumula 50 regalos", 10, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "SANTAZOM", "Acumula 100 regalos", 15, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "YO SOY SANTA", "Acumula 200 regalos", 20, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "ME HE PORTADO MUY BIEN", "Acumula 500 regalos", 30, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "SABRÁS SI HAS SIDO BUENO", "Acumula 1000 regalos", 40, 0, 0, ACHIEVEMENT_CLASS_NAVIDAD},
	{1, "PRIMERO: DIEZ REGALOS", "Primero en acumular 10 regalos", 15, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "PRIMERO: SANTAZOM", "Primero en acumular 100 regalos", 30, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{1, "LONG JUMP x10", "Compra 10 veces el item extra Long Jump", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "LONG JUMP x10", "Compra 50 veces el item extra Long Jump", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "LONG JUMP x10", "Compra 100 veces el item extra Long Jump", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{1, "AMMOPACKS x1.000", "Junta 1.000 de AmmoPacks", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x5.000", "Junta 5.000 de AmmoPacks", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x10.000", "Junta 10.000 de AmmoPacks", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x50.000", "Junta 50.000 de AmmoPacks", 20, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x100.000", "Junta 100.000 de AmmoPacks", 25, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x500.000", "Junta 500.000 de AmmoPacks", 30, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x1.000.000", "Junta 1.000.000 de AmmoPacks", 35, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x5.000.000", "Junta 5.000.000 de AmmoPacks", 40, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x10.000.000", "Junta 10.000.000 de AmmoPacks", 45, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x50.000.000", "Junta 50.000.000 de AmmoPacks", 50, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x100.000.000", "Junta 100.000.000 de AmmoPacks", 55, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x250.000.000", "Junta 250.000.000 de AmmoPacks", 60, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS x500.000.000", "Junta 500.000.000 de AmmoPacks", 65, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [RONDA] x100", "Junta 100 de AmmoPacks en una ronda", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [RONDA] x500", "Junta 500 de AmmoPacks en una ronda", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [RONDA] x1.000", "Junta 1.000 de AmmoPacks en una ronda", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [RONDA] x5.000", "Junta 5.000 de AmmoPacks en una ronda", 20, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [RONDA] x10.000", "Junta 10.000 de AmmoPacks en una ronda", 25, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [MAPA] x5.000", "Junta 5.000 de AmmoPacks en un mapa", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [MAPA] x10.000", "Junta 10.000 de AmmoPacks en un mapa", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [MAPA] x25.000", "Junta 25.000 de AmmoPacks en un mapa", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [MAPA] x50.000", "Junta 50.000 de AmmoPacks en un mapa", 20, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "AMMOPACKS [MAPA] x100.000", "Junta 100.000 de AmmoPacks en un mapa", 25, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{1, "¡EL CABEZA!", "Gana el modo CABEZÓN", 10, 20, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SUBE... Y BAJA", "Mata a 40 jugadores en una misma ronda", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SUBE... Y ¡BOOOOOOOM!", "Mata a 50 jugadores en una misma ronda", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "CABEZÓN, Y CIEGO", "Has que el poder del CABEZÓN no mate a nadie", 10, 20, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MEJOREN LA PUNTERÍA", "Recibe menos de 20 disparos en la cabeza", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "¿A ESO LE LLAMAN DISPARAR?", "Recibe menos de 10 disparos en la cabeza", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "¿CÓMO USABA EL PODER?", "Gana el modo CABEZON sin utilizar el poder", 5, 20, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "FRANCOTIRADOR", "Gana el modo SNIPER estando vivo", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "EL MEJOR EQUIPO", "Gana el modo SNIPER sin que ningún compañero muera", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "EN MEMORIA A ELLOS", "Gana el modo SNIPER siendo el último SNIPER vivo", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MI AWP ES MEJOR", "Mata 8 zombies con AWP", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "MI SCOUT ES MEJOR", "Mata a 8 zombies con SCOUT", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SOBREVIVEN LOS DUROS", "Teniendo AWP, gana el modo con tu compañero de AWP", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NO SOLO LA GANAN LOS DUROS", "Teniendo SCOUT, gana el modo con tu compañero de SCOUT", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ZAS, EN TODA LA BOCA", "Mata 8 zombies con disparos en la cabeza", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NO TENGO BALAS", "Gana el modo SNIPER sin realizar daño", 10, 1, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "ALIENÍGENA", "Mata al DEPREDADOR siendo ALIEN \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "ALIEN ENTRENADO", "Mata a 8 humanos siendo ALIEN \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "SUPER ALIEN 86", "Mata a 12 humanos siendo ALIEN \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "RÁPIDO Y ALIENOSO", "Mata al DEPREDADOR y sobrevive con 70%+ de vida \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "¡¡FURIAAAA!!", "Desata el LA FURIA ZOMBIE y mata a 3 humanos antes que se acabe \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "ROJO? BAH!", "Desata el LA FURIA ZOMBIE y no mates a nadie hasta que se acabe \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "¡NO TE VEO, PERO TE HUELO!", "Mata al DEPREDADOR mientras está invisible \r(LOGRO DESHABILITADO)", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "¡ESTOY RE LOCO!", "Mata al DEPREDADOR mientras estás bajo los efectos^nde LA FURIA ZOMBIE \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "DEPREDADOR", "Mata al ALIEN siendo DEPREDADOR \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "SARGENTO DEPRE", "Mata a 8 zombies siendo DEPREDADOR \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "DEPREDADOR 007", "Mata a 12 zombies siendo DEPREDADOR \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "AHORA ME VES.. AHORA NO ME VES", "Utiliza la invisibilidad y no recibas daño mientras dure \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{0, "MI HABILIDAD ES MEJOR", "Mata a un ALIEN mientras estás invisible \r(LOGRO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "5 DE LAS GRANDES", "Crea 5 cabezas zombie Violetas Grandes", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "BAD LUCK BRIAN", "Abre 10 cabezas zombies seguidas sin conseguir nada", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{1, "SURVIVOR PRINCIPIANTE", "Gana el modo SURVIVOR en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SURVIVOR AVANZADO", "Gana el modo SURVIVOR en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SURVIVOR EXPERTO", "Gana el modo SURVIVOR en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "SURVIVOR PRO", "Gana el modo SURVIVOR en dificultad EXPERTO", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "WESKER PRINCIPIANTE", "Gana el modo WESKER en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "WESKER AVANZADO", "Gana el modo WESKER en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "WESKER EXPERTO", "Gana el modo WESKER en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "WESKER PRO", "Gana el modo WESKER en dificultad EXPERTO", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "LEATHERFACE PRINCIPIANTE", "Gana el modo LEATHERFACE en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "LEATHERFACE AVANZADO", "Gana el modo LEATHERFACE en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "LEATHERFACE EXPERTO", "Gana el modo LEATHERFACE en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "LEATHERFACE PRO", "Gana el modo LEATHERFACE en dificultad EXPERTO", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS PRINCIPIANTE", "Gana el modo NEMESIS en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS AVANZADO", "Gana el modo NEMESIS en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS EXPERTO", "Gana el modo NEMESIS en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "NEMESIS PRO", "Gana el modo NEMESIS en dificultad EXPERTO", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "CABEZÓN PRINCIPIANTE", "Gana el modo CABEZÓN en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "CABEZÓN AVANZADO", "Gana el modo CABEZÓN en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "CABEZÓN EXPERTO", "Gana el modo CABEZÓN en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "CABEZÓN PRO", "Gana el modo CABEZÓN en dificultad EXPERTO", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ANIQUILADOR PRINCIPIANTE", "Gana el modo ANIQUILADOR en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ANIQUILADOR AVANZADO", "Gana el modo ANIQUILADOR en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ANIQUILADOR EXPERTO", "Gana el modo ANIQUILADOR en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{1, "ANIQUILADOR PRO", "Gana el modo ANIQUILADOR en dificultad EXPERTO", 20, 12, 0, ACHIEVEMENT_CLASS_MODES}
};

new const __HATS[structIdHats][structHats] = { // Vida - Velocidad - Gravedad - Daño - APs - XP - Respawn - Items
	{"Ninguno", "models/v_usp.mdl", "", "", 0, 0, 0, 0, 0.0, 0.0, 0, 0},
	{"Angel", "models/dg/zp6/hats/angel2.mdl", "Mata a 2.500 zombies", "", 2, 1, 1, 0, 0.5, 0.0, 0, 10},
	{"Awesome", "models/dg/zp6/hats/awesome.mdl", "Infecta a 2.500 humanos", "", 2, 1, 1, 0, 0.0, 0.5, 0, 10},
	{"Devil", "models/dg/zp6/hats/devil2.mdl", "Consigue ser último humano en el modo Infección", "Sin comprar armas ni items extras, y al menos 15 jugadores conectados", 2, 1, 1, 2, 0.0, 0.5, 0, 10},
	{"Earth", "models/dg/zp6/hats/earth.mdl", "Infecta a 5 humanos usando una furia zombie", "", 1, 0, 0, 3, 0.4, 0.4, 0, 10},
	{"Gold Head", "models/dg/zp6/hats/gold_head.mdl", "Se un usuario VIP", "", 1, 1, 1, 1, 0.25, 0.25, 0, 0},
	{"Pumpkin", "models/dg/zp6/hats/halloween.mdl", "Asusta a 500 humanos en el evento HALLOWEEN", "", 2, 2, 2, 2, 0.5, 0.5, 0, 5},
	{"Navid", "models/dg/zp6/hats/hat_navid2.mdl", "Acumula 250 regalos en el evento NAVIDAD", "", 2, 2, 2, 2, 0.5, 0.5, 0, 5},
	{"Hood", "models/dg/zp6/hats/hood.mdl", "Siendo WESKER gana la ronda sin utilizar los lasers", "Al menos 15 jugadores conectados", 0, 2, 0, 2, 0.3, 0.3, 2, 10},
	{"Jack", "models/dg/zp6/hats/jackolantern.mdl", "Mata a 100 survivors", "", 2, 2, 0, 1, 0.0, 0.4, 0, 10},
	{"Jamaca", "models/dg/zp6/hats/jamacahat2.mdl", "Mata a 100 nemesis", "", 2, 0, 2, 1, 0.0, 0.4, 0, 10},
	{"Psycho", "models/dg/zp6/hats/psycho.mdl", "Consigue los logros \yBOMBA FALLIDA\w y \yVIRUS\w", "¡Cuidado!... Puede convertirse en zombie", 1, 3, 1, 3, 0.5, 0.25, 5, 15},
	{"Sasha", "models/dg/zp6/hats/sasha.mdl", "Mata 500 zombies con cuchillo", "", 0, 5, 5, 0, 0.25, 0.5, 10, 10},
	{"Scream", "models/dg/zp6/hats/scream.mdl", "Se campeón en algún torneo hecho por el servidor", "", 1, 2, 2, 1, 0.5, 0.5, 5, 5},
	{"Spartan", "models/dg/zp6/hats/spartan.mdl", "Sube al nivel 15 tu Cuchillo", "", 3, 1, 1, 3, 0.0, 0.0, 5, 15},
	{"Super Man", "models/dg/zp6/hats/supermancape.mdl", "Sube VELOCIDAD H/Z y GRAVEDAD H/Z al máximo", "", 2, 1, 1, 2, 0.75, 0.0, 5, 10},
	{"Tyno", "models/dg/zp6/hats/tyno.mdl", "Alcanza el reset 50", "", 2, 2, 2, 2, 0.25, 0.5, 10, 5},
	{"Viking", "models/dg/zp6/hats/viking.mdl", "Juega 15 días", "", 3, 1, 1, 3, 0.5, 0.25, 5, 10},
	{"Zippy", "models/dg/zp6/hats/zippy.mdl", "Sube todas las armas al nivel 20", "", 3, 2, 2, 3, 0.5, 0.75, 10, 10}
};

new const __ARTIFACTS[structIdArtifacts][structArtifacts] = {
	{"Anillo de las rebajas", 100, ARTIFACT_CLASS_RING},
	{"Anillo de los AmmoPacks", 125, ARTIFACT_CLASS_RING},
	{"Anillo de la XP", 150, ARTIFACT_CLASS_RING},
	{"Anillo del Combo", 175, ARTIFACT_CLASS_RING},
	{"Collar del fuego", 50, ARTIFACT_CLASS_NECKLASE},
	{"Collar del hielo", 50, ARTIFACT_CLASS_NECKLASE},
	{"Collar del daño", 75, ARTIFACT_CLASS_NECKLASE},
	{"Collar de las cabezas zombies", 100, ARTIFACT_CLASS_NECKLASE},
	{"Pulsera de los AmmoPacks", 200, ARTIFACT_CLASS_BRACELET},
	{"Pulsera de la XP", 400, ARTIFACT_CLASS_BRACELET},
	{"Pulsera del combo", 600, ARTIFACT_CLASS_BRACELET},
	{"Pulsera de puntos", 800, ARTIFACT_CLASS_BRACELET},
	{"Pulsera del daño", 1000, ARTIFACT_CLASS_BRACELET}
};

new const __ARTIFACTS_RANGES[6][] = {
	'D', 'C', 'B', 'A', 'S', '-'
};

new const __MASTERYS[structIdMasterys][] = {
	"", "Mañana", "Noche"
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
	"HUD General", "Combo", "Visión nocturna", "Luz / Bubble", "Grupo"
};

new const __HUD_TYPES[structIdHudTypes][] = {
	"GENERAL", "COMBO"
};

new const __HUD_STYLES[][] = {
	"Normal", "Normal con corchetes", "Minimizado", "Minimizado con corchetes", "Minimizado con guiones"
};

new const __CHAT_MODE[structIdChatMode][] = {
	"[Reset](Nivel)", "[Reset][Nivel]", "[Reset][(Nivel)]", "[Reset]{Nivel}", "[Reset]{(Nivel)}", "[Reset]{[Nivel]}", "[Reset]{[(Nivel)]}"
};

new const __COMBO_HUMAN[][structCombo] = {
	{0, "¡Perfect!", "dg/zp8/c_perfect.wav"},
	{500, "¡First Blood!", "dg/zp8/c_first_blood.wav"},
	{1000, "¡Double Kill!", "dg/zp8/c_double_kill.wav"},
	{2500, "¡Multi Kill!", "dg/zp8/c_multi_kill.wav"},
	{5000, "¡¡Blood Bath!!", "dg/zp8/c_blood_bath.wav"},
	{7500, "¡¡Ultra Kill!!", "dg/zp8/c_ultra_kill.wav"},
	{10000, "¡¡Mega Kill!!", "dg/zp8/c_mega_kill.wav"},
	{20000, "¡¡Dominating!!", "dg/zp8/c_dominating.wav"},
	{30000, "¡¡IMPRESSIVE!!", "dg/zp8/c_impressive.wav"},
	{50000, "¡¡RAMPAGE!!", "dg/zp8/c_rampage.wav"},
	{75000, "¡¡KILLING SPREE!!", "dg/zp8/c_killing_spree.wav"},
	{100000, "¡¡GODLIKE!!", "dg/zp8/c_godlike.wav"},
	{150000, "¡¡¡UNSTOPPABLE!!!", "dg/zp8/c_unstoppable.wav"},
	{200000, "¡¡¡HOLY SHIT!!!", "dg/zp8/c_holy_shit.wav"},
	{250000, "¡¡¡WICKED SICK!!!", "dg/zp8/c_wicked_sick.wav"},
	{350000, "¡¡¡MONSTER KILL!!!", "dg/zp8/c_monster_kill.wav"},
	{450000, "¡¡¡LUDICROUSS KILL!!!", "dg/zp8/c_ludicrouss_kill.wav"},
	{550000, "¡¡¡¡IT'S A NIGHTMARE!!!!", "dg/zp8/c_ludicrouss_kill.wav"},
	{650000, "¡¡¡¡WHAT THE FUUUUUUUU!!!!", "dg/zp8/c_ludicrouss_kill.wav"},
	{750000, "I N F E R N O", "dg/zp8/c_ludicrouss_kill.wav"},
	{1000000, "A A A A A A A A A A A A A", "dg/zp8/c_ludicrouss_kill.wav"},
	{1500000, "L O O O O O O O O O O O L", "dg/zp8/c_ludicrouss_kill.wav"},
	{2500000, "O O O O H   MY   G O O O O O O O O D", "dg/zp8/c_ludicrouss_kill.wav"},
	{5000000, "G O R G E O U S S S S", "dg/zp8/c_ludicrouss_kill.wav"},
	{10000000, ". . .", "dg/zp8/c_ludicrouss_kill.wav"},

	{2100000000, ". . .", "dg/zp8/c_ludicrouss_kill.wav"}
};

new const __COMBO_ZOMBIE[][structCombo] = {
	{1, "¡Perfect!", "dg/zp8/c_perfect.wav"},
	{2, "¡First Blood!", "dg/zp8/c_first_blood.wav"},
	{3, "¡Double Kill!", "dg/zp8/c_double_kill.wav"},
	{4, "¡Multi Kill!", "dg/zp8/c_multi_kill.wav"},
	{5, "¡¡Blood Bath!!", "dg/zp8/c_blood_bath.wav"},
	{6, "¡¡Ultra Kill!!", "dg/zp8/c_ultra_kill.wav"},
	{7, "¡¡Mega Kill!!", "dg/zp8/c_mega_kill.wav"},
	{8, "¡¡Dominating!!", "dg/zp8/c_dominating.wav"},
	{9, "¡¡IMPRESSIVE!!", "dg/zp8/c_impressive.wav"},
	{10, "¡¡RAMPAGE!!", "dg/zp8/c_rampage.wav"},
	{11, "¡¡KILLING SPREE!!", "dg/zp8/c_killing_spree.wav"},
	{12, "¡¡GODLIKE!!", "dg/zp8/c_godlike.wav"},
	{13, "¡¡¡UNSTOPPABLE!!!", "dg/zp8/c_unstoppable.wav"},
	{14, "¡¡¡HOLY SHIT!!!", "dg/zp8/c_holy_shit.wav"},
	{15, "¡¡¡WICKED SICK!!!", "dg/zp8/c_wicked_sick.wav"},
	{16, "¡¡¡MONSTER KILL!!!", "dg/zp8/c_monster_kill.wav"},
	{17, "¡¡¡MONSTER KILL!!!", "dg/zp8/c_monster_kill.wav"},
	{18, "¡¡¡LUDICROUSS KILL!!!", "dg/zp8/c_ludicrouss_kill.wav"},
	{19, "¡¡¡¡IT'S A NIGHTMARE!!!!", "dg/zp8/ludicrouss_kill.wav"},
	{20, "¡¡¡¡WHAT THE FUUUUUUUU!!!!", "dg/zp8/ludicrouss_kill.wav"},
	{21, "I N F E R N O", "dg/zp8/ludicrouss_kill.wav"},
	{22, "A A A A A A A A A A A A A", "dg/zp8/ludicrouss_kill.wav"},
	{23, "L O O O O O O O O O O O L", "dg/zp8/ludicrouss_kill.wav"},
	{24, "O O O O H   MY   G O O O O O O O O D", "dg/zp8/ludicrouss_kill.wav"},
	{25, "G O R G E O U S S S S", "dg/zp8/ludicrouss_kill.wav"},
	{26, ". . .", "dg/zp8/ludicrouss_kill.wav"},

	{2100000000, ". . .", "dg/zp8/c_ludicrouss_kill.wav"}
};

new const __ENTTHINK_CLASSNAME_GENERAL[] = "entThinkGeneral";
new const __ENTTHINK_CLASSNAME_TOP_LEADER[] = "entThinkTopLeader";
new const __ENT_CLASSNAME_HEADZOMBIE[] = "entHeadZombie";
new const __ENT_CLASSNAME_HEADZOMBIE_SMALL[] = "entHeadZombieSmall";
new const __ENT_CLASSNAME_BAZOOKA[] = "entBazooka";
new const __ENT_CLASSNAME_HAT[] = "entHat";

new const __BLOCK_COMMANDS[][] = {
	"buy", "buyequip", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47", "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
	"sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "fiveseven", "12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum",
	"d3au1", "krieg550", "smg", "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown",
	"buyammo1", "buyammo2"
};

new const __WEAPON_NAMES[][] = {
	"", "P228 Compact", "", "Schmidt Scout", "", "XM1014 M4", "", "Ingram MAC-10", "Steyr AUG A1", "", "Dual Elite Berettas", "FiveseveN", "UMP 45", "SG-550 Auto-Sniper", "IMI Galil", "Famas", "USP .45 ACP Tactical", "Glock 18C",
	"AWP Magnum Sniper", "MP5 Navy", "M249 Para Machinegun", "M3 Super 90", "M4A1 Carbine", "Schmidt TMP", "G3SG1 Auto-Sniper", "", "Desert Eagle .50 AE", "SG-552 Commando", "AK-47 Kalashnikov", "Cuchillo", "ES P90"
};

new const __WEAPON_ENT_NAMES[][] = {
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil",
	"weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90"
};

new const __MAX_CLIP[] = {
	-1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 50
};

new const __MAX_BPAMMO[] = {
	-1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100
};

new const __DEFAULT_MAX_CLIP[] = {
	-1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50
};

new const Float:__DEFAULT_DELAY[] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55, 0.00, 3.15, 3.30, 0.00, 4.50, 2.70, 3.50, 3.35, 2.45, 3.30, 2.70, 2.20, 2.50, 2.63, 4.70, 0.55, 3.05, 2.12, 3.50, 0.00, 2.20, 3.00, 2.45, 0.00, 3.40
};

new const __DEFAULT_ANIMS[] = {
	-1, 5, -1, 3, -1, 6, -1, 1, 1, -1, 14, 4, 2, 3, 1, 1, 13, 7, 4, 1, 3, 6, 11, 1, 3, -1, 4, 1, 1, -1, 1
};

new const __AMMO_WEAPON[] = {
	0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4
};

new const __AMMO_TYPE[][] = {
	"", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm"
};

new const __AMMO_OFFSET[] = {
	-1, OFFSET_P228_AMMO, -1, OFFSET_SCOUT_AMMO, OFFSET_HE_AMMO, OFFSET_M3_AMMO, OFFSET_C4_AMMO, OFFSET_USP_AMMO, OFFSET_FAMAS_AMMO,
	OFFSET_SMOKE_AMMO, OFFSET_GLOCK_AMMO, OFFSET_FIVESEVEN_AMMO, OFFSET_USP_AMMO, OFFSET_FAMAS_AMMO, OFFSET_FAMAS_AMMO, OFFSET_FAMAS_AMMO, OFFSET_USP_AMMO,
	OFFSET_GLOCK_AMMO, OFFSET_AWM_AMMO, OFFSET_GLOCK_AMMO, OFFSET_PARA_AMMO, OFFSET_M3_AMMO, OFFSET_FAMAS_AMMO, OFFSET_GLOCK_AMMO, OFFSET_SCOUT_AMMO, OFFSET_FLASH_AMMO,
	OFFSET_DEAGLE_AMMO, OFFSET_FAMAS_AMMO, OFFSET_SCOUT_AMMO, -1, OFFSET_FIVESEVEN_AMMO
};

new const __PLAYER_MODEL_HUMAN[] = "dg-zp_human_26b";
new const __PLAYER_MODEL_HUMAN_VIP[] = "dg-zp_human_vip";
new const __PLAYER_MODEL_SURVIVOR[] = "dg-zp_survivor_02b";
new const __PLAYER_MODEL_WESKER[] = "dg-zp_wesker_00";
new const __PLAYER_MODEL_LEATHERFACE[] = "dg-zp_leatherff_00";
new const __PLAYER_MODEL_TRIBAL[] = "tcs_tribal_1";
new const __PLAYER_MODEL_SNIPER[] = "dg-zp_sniper_00_f";
new const __PLAYER_MODEL_L4D2[][] = {+
	"dg-l4d_bill_00", "dg-l4d_francis_00", "dg-l4d_louis_00", "dg-l4d_zoei_00"
};
new const __PLAYER_MODEL_ZOMBIE[] = "dg-zp_zombie_25b";
new const __PLAYER_MODEL_ZOMBIE_VIP[] = "dg-zp_zombie_vip";
new const __PLAYER_MODEL_NEMESIS[] = "dg-zp_nemesis_03b";
new const __PLAYER_MODEL_GRUNT[] = "dg-zp_grunt_00";
new const __PLAYER_MODEL_CABEZON[] = "dg-zp_cabezon_00";
new const __PLAYER_MODEL_ANNIHILATOR[] = "dg-zp_annihilator_00";
new const __PLAYER_MODEL_FLESHPOUND[] = "tcs_zombie_18";
new const __PLAYER_MODEL_L4D2_ZOMBIES[][] = {
	"dg-l4d2_boomer_00"
};

new const __KNIFE_vMODEL_LEATHERFACE[][] = {"models/dg/zp6/v_chainsaw_00.mdl", "models/dg/zp6/p_chainsaw_00.mdl"};
new const __KNIFE_vMODEL_ZOMBIE[] = "models/player/dg-zp_zombie_25/v_dg-zp_zombie_25.mdl";
new const __KNIFE_vMODEL_ZOMBIE_VIP[] = "models/player/dg-zp_zombie_vip/v_dg-zp_zombie_vip.mdl";
new const __KNIFE_vMODEL_NEMESIS[] = "models/dg/zp6/v_knife_nemesis_00.mdl";
new const __KNIFE_vMODEL_ANNIHILATOR[] = "models/dg/zp6/v_knife_annihilator_00.mdl";
new const __KNIFE_vMODEL_FLESHPOUND[] = "models/zombie_plague/tcs_garras_fp.mdl";
new const __KNIFE_vMODEL_L4D2_ZOMBIES[][] = {
	"models/dg/torneo_l4d2/v_knife_boomer_00.mdl"
};

new const __GRENADE_MODEL_INFECTION[][] = {"models/dg/zp6/v_grenade_infection_00.mdl", "models/dg/zp6/p_grenade_infection_00.mdl", "models/dg/zp6/w_grenade_infection_00.mdl"};
new const __GRENADE_vMODEL_FIRE[] = "models/dg/zp6/v_grenade_fire_00.mdl";
new const __GRENADE_vMODEL_FROST[] = "models/dg/zp6/v_grenade_frost_00.mdl";
new const __GRENADE_vMODEL_FLARE[] = "models/dg/zp6/v_grenade_flare_00.mdl";
new const __GRENADE_vMODEL_KILL[] = "models/dg/zp6/v_grenade_kill_00.mdl";
new const __GRENADE_MODEL_PIPE[][] = {"models/zp_tcs/v_pipe.mdl", "models/zp_tcs/w_pipe.mdl"};
new const __GRENADE_vMODEL_ANTIDOTE[] = "models/dg/zp6/v_grenade_antidote_00.mdl";
new const __GRENADE_MODEL_DRUG[][] = {"models/dg/zp6/v_grenade_drug_00.mdl", "models/dg/zp6/p_grenade_drug_00.mdl", "models/dg/zp6/w_grenade_drug_00.mdl"};
new const __GRENADE_MODEL_SUPERNOVA[][] = {"models/dg/zp6/v_grenade_hypernova_00.mdl", "models/dg/zp6/p_grenade_hypernova_00.mdl", "models/dg/zp6/w_grenade_hypernova_00.mdl"};
new const __GRENADE_MODEL_BUBBLE[][] = {"models/dg/zp6/v_grenade_bubble_00.mdl", "models/dg/zp6/p_grenade_bubble_00.mdl", "models/dg/zp6/w_grenade_bubble_00.mdl"};

new const __MODEL_BAZOOKA[][] = {"models/dg/zp6/v_bazooka_00.mdl", "models/dg/zp6/p_bazooka_00.mdl"};
new const __MODEL_BUBBLE[] = "models/zp_tcs/bubble_aura.mdl";
new const __MODEL_HEADZOMBIE[] = "models/dg/zp6/headzombie_00.mdl";
new const __MODEL_HEADZOMBIE_SMALL[] = "models/zp_tcs/head_z_small.mdl";
new const __MODEL_ROCKET[] = "models/dg/zp6/rocket_00.mdl";
new const __MODEL_SKULL[] = "models/gib_skull.mdl";

new const __SOUND_ARMOR_HIT[] = "player/bhit_helmet-1.wav";
new const __SOUND_AMMO_PICKUP[] = "items/ammopickup1.wav";
new const __SOUND_WIN_HUMANS[] = "dg/zp6/win_humans_00.wav";
new const __SOUND_WIN_ZOMBIES[] = "dg/zp6/win_zombies_00.wav";
new const __SOUND_WIN_NO_ONE[] = "ambience/3dmstart.wav";
new const __SOUND_ROUND_GENERAL[][] = {
	"dg/zp6/round_general_00.wav", "dg/zp6/round_general_01.wav", "dg/zp6/round_general_02.wav", "dg/zp6/round_general_03.wav"
};
new const __SOUND_ROUND_SURVIVOR[][] = {
	"dg/zp6/round_survivor_00.wav", "dg/zp6/round_survivor_01.wav"
};
new const __SOUND_ROUND_NEMESIS[][] = {
	"dg/zp6/round_nemesis_00.wav", "dg/zp6/round_nemesis_01.wav"
};
new const __SOUND_ROUND_GRUNT[] = "dg/zp6/round_assassin_00.wav";
new const __SOUND_ROUND_ARMAGEDDON[] = "zombie_plague/tcs_sirena_2.wav";
new const __SOUND_ROUND_MEGA_ARMAGEDDON[] = "sound/dg/zp6/round_mega_armageddon_00.mp3";
new const __SOUND_ROUND_GUNGAME[] = "dg/zp6/round_gungame_00.wav";
new const __SOUND_ROUND_SPECIAL[] = "dg/zp6/round_special_00.wav";
new const __SOUND_ROUND_L4D2[] = "dg/zp6/round_l4d2.wav";
new const __SOUND_HUMAN_ANTIDOTE[] = "items/smallmedkit1.wav";
new const __SOUND_HUMAN_KNIFE_DEFAULT[][] = { // NOT-PRECACHE
	"weapons/knife_deploy1.wav", "weapons/knife_hit1.wav", "weapons/knife_hit2.wav", "weapons/knife_hit3.wav", "weapons/knife_hit4.wav", "weapons/knife_hitwall1.wav", "weapons/knife_slash1.wav", "weapons/knife_slash2.wav", "weapons/knife_stab.wav"
};
new const __SOUND_WESKER_LASER[] = "weapons/electro5.wav";
new const __SOUND_LEATHERFACE_CHAINSAW[][] = {
	"dg/zp6/jason_chainsaw_deploy.wav", "dg/zp6/jason_chainsaw_hit1.wav", "dg/zp6/jason_chainsaw_hit2.wav", "dg/zp6/jason_chainsaw_hit1.wav", "dg/zp6/jason_chainsaw_hit2.wav", "dg/zp6/jason_chainsaw_hitwall.wav", "dg/zp6/jason_chainsaw_miss.wav", "dg/zp6/jason_chainsaw_miss.wav", "dg/zp6/jason_chainsaw_stab.wav"
};
new const __SOUND_ZOMBIE_PAIN[][] = {
	"dg/zp6/zombie_pain_00.wav", "dg/zp6/zombie_pain_01.wav", "dg/zp6/zombie_pain_02.wav"
};
new const __SOUND_SPECIALMODE_PAIN[][] = {
	"dg/zp6/specialmode_pain_00.wav", "dg/zp6/specialmode_pain_01.wav", "dg/zp6/specialmode_pain_02.wav"
};
new const __SOUND_ZOMBIE_KNIFE[][] = {
	"dg/zp6/zombie_knife_00.wav", "dg/zp6/zombie_knife_01.wav", "dg/zp6/zombie_knife_02.wav"
};
new const __SOUND_ZOMBIE_INFECT[][] = {
	"dg/zp6/zombie_infect_00.wav", "dg/zp6/zombie_infect_01.wav", "dg/zp6/zombie_infect_02.wav", "dg/zp6/zombie_infect_03.wav", "dg/zp6/zombie_infect_04.wav", "dg/zp6/zombie_infect_05.wav", "dg/zp6/zombie_infect_06.wav", "dg/zp6/zombie_infect_07.wav"
};
new const __SOUND_ZOMBIE_ALERT[][] = {
	"dg/zp6/zombie_alert_00.wav", "dg/zp6/zombie_alert_01.wav", "dg/zp6/zombie_alert_02.wav"
};
new const __SOUND_ZOMBIE_MADNESS[] = "dg/zp6/zombie_madness_00.wav";
new const __SOUND_ZOMBIE_DIE[][] = {
	"dg/zp6/zombie_die_00.wav", "dg/zp6/zombie_die_01.wav", "dg/zp6/zombie_die_02.wav", "dg/zp6/zombie_die_03.wav", "dg/zp6/zombie_die_04.wav"
};
new const __SOUND_ZOMBIE_BURN[][] = {
	"dg/zp6/zombie_burn_00.wav", "dg/zp6/zombie_burn_01.wav", "dg/zp6/zombie_burn_02.wav"
};
new const __SOUND_NEMESIS_BAZOOKA[][] = {
	"weapons/rocketfire1.wav", "weapons/mortarhit.wav", "dg/zp6/bazooka_01.wav", "weapons/explode4.wav"
};
new const __SOUND_CABEZON_POWER[] = "weapons/mortar.wav";
new const __SOUND_CABEZON_POWER_FINISH[] = "weapons/c4_explode1.wav";
new const __SOUND_NADE_INFECT_EXPLO[] = "dg/zp6/grenade_infection_explode_00.wav";
new const __SOUND_NADE_INFECT_EXPLO_PLAYER[][] = {
	"scientist/scream20.wav", "scientist/scream22.wav", "scientist/scream05.wav"
};
new const __SOUND_NADE_FIRE_EXPLO[] = "dg/zp6/grenade_fire_explode_00.wav";
new const __SOUND_NADE_FROST_EXPLO[] = "dg/zp6/grenade_nova_explode_00.wav";
new const __SOUND_NADE_FROST_PLAYER[] = "dg/zp6/grenade_nova_player_00.wav";
new const __SOUND_NADE_FROST_BREAK[] = "dg/zp6/grenade_nova_break_00.wav";
new const __SOUND_NADE_FLARE_EXPLO[] = "dg/zp6/grenade_flare_explode_00.wav";
// new const __SOUND_NADE_THUNDER_EXPLO[] = "dg/zp7/grenade_thunder_explode_00.wav";
new const __SOUND_NADE_PIPE_BEEP[][] = {
	"dg/zp7/grenade_pipe_beep_00.wav", "dg/zp7/grenade_pipe_beep_01.wav"
};
new const __SOUND_NADE_BUBBLE_EXPLO[] = "buttons/button1.wav";
new const __SOUND_LEVEL_UP[] = "dg/zp6/levelup_00.wav";
new const __SOUND_WOOD[][] = {
	"debris/wood1.wav", "debris/wood2.wav", "debris/wood3.wav"
};

new const __SPRITE_COLORS_BALLS[][] = {
	"sprites/glow04.spr",
	"sprites/dg/zp7/fireworks/red_flare_00.spr",
	"sprites/dg/zp7/fireworks/green_flare_00.spr",
	"sprites/dg/zp7/fireworks/blue_flare_00.spr",
	"sprites/dg/zp7/fireworks/yellow_flare_00.spr",
	"sprites/dg/zp7/fireworks/purple_flare_00.spr",
	"sprites/dg/zp7/fireworks/lightblue_flare_00.spr",
	"sprites/hotglow.spr"
};

new const __GFX_TUTORS[][] = {
	"gfx/career/icon_!.tga",
	"gfx/career/icon_!-bigger.tga",
	"gfx/career/icon_i.tga",
	"gfx/career/icon_i-bigger.tga",
	"gfx/career/icon_skulls.tga",
	"gfx/career/round_corner_ne.tga",
	"gfx/career/round_corner_nw.tga",
	"gfx/career/round_corner_se.tga",
	"gfx/career/round_corner_sw.tga",
	"resource/TutorScheme.res",
	"resource/UI/TutorTextWindow.res"
};

new const __GUNGAME_TYPE_NAME[structIdGunGameTypes][] = {
	"Normal", "Only Head", "Slow", "Fast", "Crazy", "Clásico"
};
new const __GUNGAME_TYPE_INFO[structIdGunGameTypes][] = {
	"Modo normal sin alteraciones",
	"Solo puede matarse con disparos en la cabeza !g(!tx75 de Ganancias!g)!y",
	"Cada nivel requiere tres matados !g(!tx50 de Ganancias!g)!y",
	"Cada nivel requiere un matado !g(!tx25 de Ganancias!g)!y",
	"Cada nivel toca un arma al azar !g(!tx50 de Ganancias!g)!y",
	"Modo normal y clásico !g(!tx100 de Ganancias!g)!y"
};
new const __GUNGAME_WEAPONS[][] = {
	"", "weapon_g3sg1", "weapon_sg550", "weapon_awp", "weapon_scout", "weapon_m249", "weapon_aug", "weapon_sg552", "weapon_m4a1", "weapon_ak47", "weapon_galil", "weapon_famas", "weapon_mp5navy", "weapon_p90", "weapon_ump45", "weapon_mac10",
	"weapon_tmp", "weapon_xm1014", "weapon_m3", "weapon_deagle", "weapon_elite", "weapon_p228", "weapon_usp", "weapon_glock18", "weapon_fiveseven", "weapon_hegrenade", "weapon_knife"
};
new const __GUNGAME_WEAPONS_CSW[] = {
	0, CSW_G3SG1, CSW_SG550, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_SG552, CSW_M4A1, CSW_AK47, CSW_GALIL, CSW_FAMAS, CSW_MP5NAVY, CSW_P90, CSW_UMP45, CSW_MAC10, CSW_TMP, CSW_XM1014, CSW_M3, CSW_DEAGLE, CSW_ELITE, CSW_P228, CSW_USP,
	CSW_GLOCK18, CSW_FIVESEVEN, CSW_HEGRENADE, 0
};
new const __GUNGAME_WEAPONS_CLASSIC[][] = {
	"", "weapon_glock18", "weapon_usp",	"weapon_p228", "weapon_deagle", "weapon_fiveseven", "weapon_elite", "weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_mp5navy", "weapon_ump45", "weapon_p90", "weapon_galil", "weapon_famas",
	"weapon_ak47", "weapon_scout", "weapon_m4a1", "weapon_sg552", "weapon_aug", "weapon_m249", "weapon_awp", "weapon_sg550", "weapon_g3sg1", "weapon_hegrenade", "weapon_knife"
};
new const __GUNGAME_WEAPONS_CLASSIC_CSW[] = {
	0, CSW_GLOCK18, CSW_USP, CSW_P228, CSW_DEAGLE, CSW_FIVESEVEN, CSW_ELITE, CSW_M3, CSW_XM1014, CSW_TMP, CSW_MAC10, CSW_MP5NAVY, CSW_UMP45, CSW_P90, CSW_GALIL, CSW_FAMAS,
	CSW_AK47, CSW_SCOUT, CSW_M4A1, CSW_SG552, CSW_AUG, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1, CSW_HEGRENADE, 0
};
new const __MEGA_GUNGAME_WEAPONS[][] = {
	"", "weapon_g3sg1", "weapon_sg550", "weapon_awp", "weapon_scout", "weapon_m249", "weapon_aug", "weapon_sg552", "weapon_m4a1", "weapon_ak47", "weapon_galil", "weapon_famas", "weapon_mp5navy", "weapon_p90", "weapon_ump45", "weapon_mac10",
	"weapon_tmp", "weapon_xm1014", "weapon_m3", "weapon_deagle", "weapon_elite", "weapon_p228", "weapon_usp", "weapon_glock18", "weapon_fiveseven", "weapon_hegrenade", "weapon_knife",
	"weapon_fiveseven", "weapon_glock18", "weapon_usp",	"weapon_p228", "weapon_elite", "weapon_deagle", "weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_ump45", "weapon_p90", "weapon_mp5navy", "weapon_famas", "weapon_galil",
	"weapon_ak47", "weapon_m4a1", "weapon_sg552", "weapon_aug", "weapon_m249", "weapon_scout", "weapon_awp", "weapon_sg550", "weapon_g3sg1", "weapon_hegrenade", "weapon_knife"
};
new const __MEGA_GUNGAME_WEAPONS_CSW[] = {
	0, CSW_G3SG1, CSW_SG550, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_SG552, CSW_M4A1, CSW_AK47, CSW_GALIL, CSW_FAMAS, CSW_MP5NAVY, CSW_P90, CSW_UMP45, CSW_MAC10, CSW_TMP, CSW_XM1014, CSW_M3, CSW_DEAGLE, CSW_ELITE, CSW_P228, CSW_USP,
	CSW_GLOCK18, CSW_FIVESEVEN, CSW_HEGRENADE, 0,
	CSW_FIVESEVEN, CSW_GLOCK18, CSW_USP, CSW_P228, CSW_ELITE, CSW_DEAGLE, CSW_M3, CSW_XM1014, CSW_TMP, CSW_MAC10, CSW_UMP45, CSW_P90, CSW_MP5NAVY, CSW_FAMAS, CSW_GALIL, CSW_AK47, CSW_M4A1, CSW_SG552, CSW_AUG, CSW_M249, CSW_SCOUT, CSW_AWP,
	CSW_SG550, CSW_G3SG1, CSW_HEGRENADE, 0
};
new const __MEGA_GUNGAME_LIGHTS[11] = {
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'i', 'i'
};

new const __HEADZOMBIE_COLORS_MIN[structIdHeadZombies][] = {
	"roja", "verde", "azul", "amarilla", "Violeta chica", "Violeta grande"
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

new const __REMOVE_ENTS[][] = {
	"func_bomb_target",
	"info_bomb_target",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"env_rain",
	"env_snow",
	"env_fog",
	"func_vehicle",
	"info_map_parameters",
	"func_buyzone",
	"armoury_entity"
};

new const __LETTERS_AND_SIMBOLS_ALLOWED[] = {
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '(', ')', '[', ']', '{', '}', '-', '=', '.', ',', ':', '!', ' ',
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
};

new g_PlayerSteamId[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new g_PlayerSteamIdCache[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new g_PlayerName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_PlayerIp[MAX_PLAYERS + 1][MAX_IP_LENGTH];
new g_PlayerClassName[MAX_PLAYERS + 1][32];
new g_PlayerSolid[MAX_PLAYERS + 1];
new g_PlayerRestore[MAX_PLAYERS + 1];
new TeamName:g_PlayerTeam[MAX_PLAYERS + 1];
new g_IsConnected[MAX_PLAYERS + 1];
new g_IsAlive[MAX_PLAYERS + 1];
new g_AccountLoading[MAX_PLAYERS + 1];
new g_AccountLoading_Steps[MAX_PLAYERS + 1];
new g_AccountStatus[MAX_PLAYERS + 1];
new g_AccountId[MAX_PLAYERS + 1];
new g_AccountLastIp[MAX_PLAYERS + 1][MAX_IP_LENGTH];
new g_AccountPassword[MAX_PLAYERS + 1][MAX_STRING_PASSWORD];
new g_AccountCode[MAX_PLAYERS + 1][MAX_STRING_CODE];
new g_AccountSinceConnection[MAX_PLAYERS + 1];
new g_AccountLastConnection[MAX_PLAYERS + 1];
new g_AccountAutologin[MAX_PLAYERS + 1];
new g_AccountVinc[MAX_PLAYERS + 1];
new g_AccountVincMail[MAX_PLAYERS + 1][128];
new g_AccountVincPassword[MAX_PLAYERS + 1][128];
new g_AccountVincAppMobile[MAX_PLAYERS + 1];
new g_AccountBannedCount[MAX_PLAYERS + 1];
new g_AccountBanned_StaffName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_AccountBanned_Start[MAX_PLAYERS + 1];
new g_AccountBanned_Finish[MAX_PLAYERS + 1];
new g_AccountBanned_Reason[MAX_PLAYERS + 1][64];
new g_AccountAttempts[MAX_PLAYERS + 1];
new g_Immunity[MAX_PLAYERS + 1];
new g_ImmunityBombs[MAX_PLAYERS + 1];
new g_BurningDuration[MAX_PLAYERS + 1];
new g_BurningDurationOwner[MAX_PLAYERS + 1];
new g_Frozen[MAX_PLAYERS + 1];
new g_Health[MAX_PLAYERS + 1];
new g_MaxHealth[MAX_PLAYERS + 1];
new Float:g_Speed[MAX_PLAYERS + 1];
new g_ZombieBack[MAX_PLAYERS + 1];
new g_Zombie[MAX_PLAYERS + 1];
new g_FirstSpawn[MAX_PLAYERS + 1];
new g_RespawnAsZombie[MAX_PLAYERS + 1];
new g_SpecialMode[MAX_PLAYERS + 1];
new g_SurvImmunity[MAX_PLAYERS + 1];
new g_WeskLaser[MAX_PLAYERS + 1];
new Float:g_WeskLaser_LastUse[MAX_PLAYERS + 1];
new g_Leatherface_Teleport[MAX_PLAYERS + 1];
new g_Bazooka[MAX_PLAYERS + 1];
new g_Bazooka_LastUse[MAX_PLAYERS + 1];
new g_BazookaMode[MAX_PLAYERS + 1];
new g_ModeFleshpound_Power[MAX_PLAYERS + 1];
new g_ModeAnnihilator_Kills[MAX_PLAYERS + 1];
new g_ModeAnnihilator_Acerts[MAX_PLAYERS + 1];
new g_ModeAnnihilator_AcertsHS[MAX_PLAYERS + 1];
new g_ModeAnnihilator_Knife[MAX_PLAYERS + 1];
new Trie:g_tModeAnnihilator_Acerts;
new g_ModeGrunt_Reward[MAX_PLAYERS + 1];
new g_ModeGrunt_Flash[MAX_PLAYERS + 1];
new g_ModeMegaDrunk_ZombieHits[MAX_PLAYERS + 1];
new g_LastHuman[MAX_PLAYERS + 1];
new g_LastHumanOk[MAX_PLAYERS + 1];
new g_LastZombie[MAX_PLAYERS + 1];
new g_TypeWeapon[MAX_PLAYERS + 1];
new g_CurrentWeapon[MAX_PLAYERS + 1];
new g_LastWeapon[MAX_PLAYERS + 1];
new g_CanBuy[MAX_PLAYERS + 1];
new g_WeaponAutoBuy[MAX_PLAYERS + 1];
new g_WeaponPrimary_Selection[MAX_PLAYERS + 1];
new g_WeaponSecondary_Selection[MAX_PLAYERS + 1];
new g_WeaponCuaternary_Selection[MAX_PLAYERS + 1];
new g_WeaponPrimary_Current[MAX_PLAYERS + 1];
new g_WeaponSecondary_Current[MAX_PLAYERS + 1];
new g_WeaponData[MAX_PLAYERS + 1][31][structIdWeaponDatas];
new g_WeaponSkills[MAX_PLAYERS + 1][31][structIdWeaponSkills];
new g_WeaponModel[MAX_PLAYERS + 1][31];
new g_WeaponSave[MAX_PLAYERS + 1][31];
new g_WeaponTime[MAX_PLAYERS + 1];
new g_WeaponSecondaryAutofire[MAX_PLAYERS + 1];
new g_DrugBomb[MAX_PLAYERS + 1];
new g_DrugBombMode[MAX_PLAYERS + 1];
new g_DrugBombCount[MAX_PLAYERS + 1];
new g_DrugBombMove[MAX_PLAYERS + 1];
new g_SupernovaBomb[MAX_PLAYERS + 1];
new g_SupernovaBombMode[MAX_PLAYERS + 1];
new g_BubbleBomb[MAX_PLAYERS + 1];
new g_BubbleBombMode[MAX_PLAYERS + 1];
new g_InBubble[MAX_PLAYERS + 1];
new g_KillBomb[MAX_PLAYERS + 1];
new g_PipeBomb[MAX_PLAYERS + 1];
new g_AntidoteBomb[MAX_PLAYERS + 1];
new g_ExtraItem_Count[MAX_PLAYERS + 1][structIdExtraItems];
new g_ExtraItem_AlreadyBuy[MAX_PLAYERS + 1][structIdExtraItems];
new g_ExtraItem_Mult[MAX_PLAYERS + 1][structIdExtraItems];
new Trie:g_tExtraItem_Invisibility;
new Trie:g_tExtraItem_KillBomb;
new Trie:g_tExtraItem_PipeBomb;
new Trie:g_tExtraItem_AntidoteBomb;
new Trie:g_tExtraItem_Antidote;
new Trie:g_tExtraItem_ZombieMadness;
new Trie:g_tExtraItem_InfectionBomb;
new Trie:g_tExtraItem_ReduceDamage;
new Trie:g_tExtraItem_Petrification;
new g_NVision[MAX_PLAYERS + 1];
new g_UnlimitedClip[MAX_PLAYERS + 1];
new g_PrecisionPerfect[MAX_PLAYERS + 1];
new g_Madness_LastUse[MAX_PLAYERS + 1];
new g_ReduceDamage[MAX_PLAYERS + 1];
new g_Petrification[MAX_PLAYERS + 1];
new g_Difficult[MAX_PLAYERS + 1][structIdDifficultsClasses];
new g_Points[MAX_PLAYERS + 1][structIdPoints];
new g_PointsLost[MAX_PLAYERS + 1][structIdPoints];
new g_PointsMult[MAX_PLAYERS + 1];
new g_PointsInDiamond[MAX_PLAYERS + 1];
new g_PointsInDiamondShow[MAX_PLAYERS + 1];
new g_Hab[MAX_PLAYERS + 1][structIdHabs];
new g_HabRotate[MAX_PLAYERS + 1][structIdHabsRotate];
new g_HabRotate_Regeneration[MAX_PLAYERS + 1];
new g_AchievementPage[MAX_PLAYERS + 1][structIdAchievementClasses];
new g_Achievement[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementName[MAX_PLAYERS + 1][structIdAchievements][33];
new g_AchievementUnlocked[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementInt[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementTotal[MAX_PLAYERS + 1];
new Float:g_AchievementTimeLink[MAX_PLAYERS + 1];
new g_Achievement_SniperAwp[MAX_PLAYERS + 1];
new g_Achievement_SniperScout[MAX_PLAYERS + 1];
new g_Achievement_InfectsRound[MAX_PLAYERS + 1];
new g_Achievement_InfectsRoundId[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_Achievement_FuryConsecutive[MAX_PLAYERS + 1];
new g_Achievement_InfectsWithFury[MAX_PLAYERS + 1];
new g_Achievement_InfectsWithMaxHP[MAX_PLAYERS + 1];
new g_Achievement_AnnKnife[MAX_PLAYERS + 1];
new g_Achievement_AnniMac10[MAX_PLAYERS + 1];
new g_Achievement_AnnBazooka[MAX_PLAYERS + 1];
new g_Achievement_WeskerHead[MAX_PLAYERS + 1];
new g_Achievement_SniperHead[MAX_PLAYERS + 1];
new g_Achievement_WeskerNoDamage[MAX_PLAYERS + 1];
new g_Achievement_CabezonKills[MAX_PLAYERS + 1];
new g_Achievement_SniperNoDamage[MAX_PLAYERS + 1];
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
new g_HeadZombie[MAX_PLAYERS + 1][structIdHeadZombies];
new g_HeadZombie_BadLuckBrian[MAX_PLAYERS + 1];
new Float:g_HeadZombie_LastTouch[MAX_PLAYERS + 1];
new g_UserOptions_Color[MAX_PLAYERS + 1][structIdColorTypes][3];
new Float:g_UserOptions_Hud[MAX_PLAYERS + 1][structIdHudTypes][3];
new g_UserOptions_HudEffect[MAX_PLAYERS + 1][structIdHudTypes];
new g_UserOptions_HudStyle[MAX_PLAYERS + 1][structIdHudTypes];
new g_UserOptions_NVision[MAX_PLAYERS + 1];
new g_UserOptions_ChatMode[MAX_PLAYERS + 1];
new g_UserOptions_Invis[MAX_PLAYERS + 1];
new g_UserOptions_GroupGlow[MAX_PLAYERS + 1];
new g_UserOptions_CurrentMode[MAX_PLAYERS + 1];
new g_Stats[MAX_PLAYERS + 1][structIdStats];
new Float:g_StatsDamage[MAX_PLAYERS + 1][2];
new g_AmmoPacks[MAX_PLAYERS + 1];
new Float:g_AmmoPacksMult[MAX_PLAYERS + 1];
new Float:g_AmmoPacksMult_Legendary[MAX_PLAYERS + 1];
new Float:g_AmmoPacksMult_Achievements[MAX_PLAYERS + 1];
new Float:g_AmmoPacksDamage[MAX_PLAYERS + 1];
new Float:g_AmmoPacksDamageNeed[MAX_PLAYERS + 1];
new g_AmmoPacksTotal[MAX_PLAYERS + 1];
new g_AmmoPacks_BestRound[MAX_PLAYERS + 1];
new g_AmmoPacks_BestRoundHistory[MAX_PLAYERS + 1];
new g_AmmoPacks_BestMap[MAX_PLAYERS + 1];
new g_AmmoPacks_BestMapHistory[MAX_PLAYERS + 1];
new g_XP[MAX_PLAYERS + 1];
new g_XPHud[MAX_PLAYERS + 1][16];
new g_XPRest[MAX_PLAYERS + 1];
new g_XPRestHud[MAX_PLAYERS + 1][16];
new Float:g_XPMult[MAX_PLAYERS + 1];
new Float:g_XPMult_Legendary[MAX_PLAYERS + 1];
new Float:g_XPMult_Achievements[MAX_PLAYERS + 1];
new Float:g_XPDamageNeed[MAX_PLAYERS + 1];
new g_Level[MAX_PLAYERS + 1];
new Float:g_LevelPercent[MAX_PLAYERS + 1];
new g_Reset[MAX_PLAYERS + 1];
new Float:g_ResetPercent[MAX_PLAYERS + 1];
new g_Combo[MAX_PLAYERS + 1];
new Float:g_ComboDamage[MAX_PLAYERS + 1];
new Float:g_ComboDamageBullet[MAX_PLAYERS + 1];
new Float:g_ComboDamageNeed[MAX_PLAYERS + 1];
new g_ComboReward[MAX_PLAYERS + 1];
new g_ComboDamageNeedFake[MAX_PLAYERS + 1];
new Float:g_ComboTime[MAX_PLAYERS + 1];
new g_ComboZombieReward[MAX_PLAYERS + 1];
new g_MenuPage[MAX_PLAYERS + 1][structIdMenuPages];
new g_MenuData[MAX_PLAYERS + 1][structIdMenuDatas];
new g_BuyStuff[MAX_PLAYERS + 1];
new g_LongJump[MAX_PLAYERS + 1];
new g_InJump[MAX_PLAYERS + 1];
new g_DailyVisits[MAX_PLAYERS + 1];
new g_Consecutive_DailyVisits[MAX_PLAYERS + 1];
new g_ConnectedToday[MAX_PLAYERS + 1];
new g_ConvertZombie[MAX_PLAYERS + 1];
new g_PlagueHumanKill[MAX_PLAYERS + 1];
new g_PlagueZombieKill[MAX_PLAYERS + 1];
new g_SynapsisNemesisKill[MAX_PLAYERS + 1];
new g_SynapsisDamage[MAX_PLAYERS + 1];
new g_SynapsisHead[MAX_PLAYERS + 1];
new g_ModeMA_Reward[MAX_PLAYERS + 1];
new g_ModeMA_Kills[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_ModeMA_ZombieKills[MAX_PLAYERS + 1];
new g_ModeMA_HumanKills[MAX_PLAYERS + 1];
new g_ModeMA_NemesisKills[MAX_PLAYERS + 1];
new g_ModeMA_SurvivorKills[MAX_PLAYERS + 1];
new g_ModeGG_Immunity[MAX_PLAYERS + 1];
new g_ModeGG_Level[MAX_PLAYERS + 1];
new g_ModeGG_Kills[MAX_PLAYERS + 1];
new g_ModeGG_Headshots[MAX_PLAYERS + 1];
new g_ModeGGCrazy_Level[MAX_PLAYERS + 1];
new g_ModeGGCrazy_ListLevel[MAX_PLAYERS + 1][26];
new g_ModeGGCrazy_HeLevel[MAX_PLAYERS + 1];
new g_ModeMGG_Health[MAX_PLAYERS + 1];
new g_ModeDuelFinal_KillsTotal[MAX_PLAYERS + 1];
new g_ModeDuelFinal_Kills[MAX_PLAYERS + 1];
new g_ModeDuelFinal_KillsKnife[MAX_PLAYERS + 1];
new g_ModeDuelFinal_KillsAwp[MAX_PLAYERS + 1];
new g_ModeDuelFinal_KillsHE[MAX_PLAYERS + 1];
new g_ModeDuelFinal_KillsOnlyHead[MAX_PLAYERS + 1];
new g_Aura[MAX_PLAYERS + 1][4];
new g_BlockSound[MAX_PLAYERS + 1];
new g_ComboZombieEnabled[MAX_PLAYERS + 1];
new g_ComboZombie[MAX_PLAYERS + 1];
new g_CriticalChance[MAX_PLAYERS + 1];
new g_DeadTimes[MAX_PLAYERS + 1];
new g_DeadTimes_Reward[MAX_PLAYERS + 1];
new g_AmuletCustomCreated[MAX_PLAYERS + 1];
new g_AmuletCustomCost[MAX_PLAYERS + 1];
new g_AmuletCustomName[MAX_PLAYERS + 1][64];
new g_AmuletCustomNameFake[MAX_PLAYERS + 1][64];
new g_AmuletCustom[MAX_PLAYERS + 1][structIdAmuletCustoms];
new Float:g_SaveConfig_SysTime[MAX_PLAYERS + 1];
new Float:g_Rank_SysTime[MAX_PLAYERS + 1];
new g_UltimasPalabras[MAX_PLAYERS + 1];
new g_Gift[MAX_PLAYERS + 1];
new g_InGroup[MAX_PLAYERS + 1];
new g_GroupInvitations[MAX_PLAYERS + 1];
new g_GroupInvitationsId[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_MyGroup[MAX_PLAYERS + 1];
new g_GroupId[14][4];
new Float:g_HLTime_GroupCombo[14];
new g_Camera[MAX_PLAYERS + 1];
new g_ModeTribal_Damage[MAX_PLAYERS + 1];
new g_Benefit[MAX_PLAYERS + 1];
new g_SniperPower[MAX_PLAYERS + 1];
new g_ModeCabezon_Head[MAX_PLAYERS + 1];
new g_InfectionBomb[MAX_PLAYERS + 1];
new g_ModeCabezon_Power[MAX_PLAYERS + 1];
new Float:g_ModeCabezon_PowerLastUse[MAX_PLAYERS + 1];
new g_ModeL4D2_ZombieAcerts[MAX_PLAYERS + 1];
new g_ModeL4D2_Human[MAX_PLAYERS + 1];
new g_MiniGames_Number[MAX_PLAYERS + 1];
new g_Grab[MAX_PLAYERS + 1];
new Float:g_GrabDistance[MAX_PLAYERS + 1];
new Float:g_GrabGravity[MAX_PLAYERS + 1];
new g_PlayedTime[MAX_PLAYERS + 1][structIdPlayedTime];
new Float:g_PlayedTime_PerDay[MAX_PLAYERS + 1];
new g_Invisibility[MAX_PLAYERS + 1];

new g_CurrentMap[32];
new g_VoteMap_i = 0;
new g_VoteMap_Force;
new g_VoteMap_SelectMaps = MAX_VOTEMAP;
new g_VoteMap_Init;
new g_VoteMap_MapId;
new g_VoteMap_Extend;
new g_VoteMap_NextRound;
new g_VoteMap_MapName[MAX_SERVER_MAP][32];
new g_VoteMap_MorePlaying[MAX_SERVER_MAP];
new g_VoteMap_Recent[MAX_SERVER_MAP];
new Float:g_VoteMap_Bonus[MAX_SERVER_MAP];
new g_VoteMap_Next[MAX_VOTEMAP];
new g_VoteMap_VoteCount[MAX_VOTEMAP + 2];
new g_VoteMap_Count;
new g_fwdSpawn;
new g_fwdPrecacheSound;
new g_Sprite_Trail;
new g_Sprite_ShockWave;
new g_Sprite_Flame;
new g_Sprite_Smoke;
new g_Sprite_Glass;
new g_Sprite_SuperNova;
new g_Sprite_FExplo;
new g_Sprite_ColorsBalls[sizeof(__SPRITE_COLORS_BALLS)];
new g_Sprite_Regeneration;
new Float:g_Spawns[64][9];
new g_SpawnCount;
new Handle:g_SqlTuple;
new Handle:g_SqlConnection;
new g_SqlQuery[2048];
new g_GlobalRank;
new Float:g_UserExtraXP;
new g_Message_Money;
new g_Message_CurWeapon;
new g_Message_FlashBat;
new g_Message_Flashlight;
new g_Message_NVGToggle;
new g_Message_WeapPickup;
new g_Message_AmmoPickup;
new g_Message_TextMsg;
new g_Message_SendAudio;
new g_Message_StatusIcon;
new g_Message_DeathMsg;
new g_Message_ScoreInfo;
new g_Message_ScoreAttrib;
new g_Message_ScreenFade;
new g_Message_ScreenShake;
new g_Message_Fov;
new g_Message_TutorText;
new g_Message_TutorClose;
new g_Message_Fog;
new g_pCvar_Delay;
new g_pCvar_CanUseMinigames;
new g_HudSync_General;
new g_HudSync_Combo;
new g_HudSync_CurrentMode;
new g_Lights[2];
new g_NewRound;
new g_EndRound;
new g_EndRound_Forced;
new g_Mode;
new g_CurrentMode;
new g_NextMode;
new g_LastMode;
new g_DrunkAtDay = 0;
new g_HappyHour = 0;
new g_EventModes;
new g_EventMode_Count = 0;
new g_EventMode_MegaArmageddon;
new g_EventMode_GunGame;
new g_ModeCount[structIdModes];
new g_ModeCountAdmin[structIdModes];
new g_ModeCountAdmin_Total = 0;
new g_MasteryType = -1;
new g_DataSaved = 0;
new g_LastAchUnlocked = -1;
new g_LastAchUnlockedPage = 0;
new g_LastAchUnlockedClass = 0;
new g_LastHatUnlocked = -1;
new g_HabRotate_Week[3];
new g_ModeGrunt_NoDamage = 0;
new g_ModeGrunt_RewardGlobal = 0;
new g_ModeGrunt_Power = 0;
new g_ModeArmageddon_Init = 0;
new g_ModeArmageddon_Notice = 0;
new g_ModeMA_AllZombies = 1;
new g_ModeMA_AllHumans = 1;
new g_ModeGG_Stats[256];
new g_ModeGG_End = 0;
new g_ModeGG_Type = 0;
new g_ModeGG_SysTime;
new g_ModeGG_LastWinner;
new g_ModeMGG_Played;
new g_ModeMGG_Phase = 0;
new g_ModeMGG_Block = 0;
new g_ModeMGG_CountDown = 0;
new g_ModeDuelFinal = 0;
new g_ModeDuelFinal_Type = 0;
new g_ModeDuelFinal_TypeOnlyHead = 0;
new g_ModeDuelFinal_TypeName[32];
new g_ModeDuelFinal_First = 0;
new g_ModeSynapsis_Id[3];
new g_ModeTribal_Power = 0;
new g_ModeTribal_Id[2];
new g_ModeFleshpound_Minute = 0;
new g_ModeSniper_Id[4];
new g_ModeCabezon_HeadTotal = 0;
new g_ModeCabezon_PowerGlobal = 0;
new g_ModeL4D2_ZombiesTotal = 0;
new g_ModeL4D2_Zombies = 0;
new g_ScoreHumans = 0;
new g_ScoreZombies = 0;
new g_TopLeader = 0;
new g_TopLevel_Name[32];
new g_TopLevel_Exp[16];
new g_TopLevel_Level = 0;
new g_TopLevel_Reset = 0;
new g_TopCombo_Name[32];
new g_TopCombo_ComboMax[16];
new g_TopTime_Name[16];
new g_TopTime_Time[3] = {0, 0, 0};
new g_TopComboHPerMap_Name[32];
new g_TopComboHPerMap_ComboMax[16];
new g_TopComboHPerMap_MapName[32];
new g_TopComboZPerMap_Name[32];
new g_TopComboZPerMap_ComboMax[16];
new g_TopComboZPerMap_MapName[32];
new g_AmuletCustomConfirm[32];
new g_MaxComboHumanMap;
new g_MaxComboZombieMap;
new g_FirstRound;
new g_ModeInfection_Systime;
new g_ExtraItem_InfectionBombUsed = 0;
new g_ExtraItem_InfectionBombRounds = 0;
new g_ExtraItem_HumanBombs = 0;
new g_ModeInfection_Res = 0;
new g_MiniGames_NumberFake = 0;
new g_LastHumanOk_NoRespawn = 0;
new Float:g_HeadZombie_SysTime;

#define isDigit(%0) (48 <= %0 <= 57)
#define isLetter(%0) (65 <= %0 <= 90 || 97 <= %0 <= 122)

#define isPlayerValid(%1) (1 <= %1 <= MaxClients)
#define isPlayerValidConnected(%1) (isPlayerValid(%1) && g_IsConnected[%1])
#define isPlayerValidAlive(%1) (isPlayerValid(%1) && g_IsAlive[%1])

#define xpThisLevel(%1,%2) (%2 * (maxXPPerReset(g_Reset[%1]) / 299))
#define xpThisLevelRest1(%1,%2) ((%2 - 1) * (maxXPPerReset(g_Reset[%1]) / 299))

public plugin_precache() {
	new iEnt;
	new i;
	new j;

	get_mapname(g_CurrentMap, charsmax(g_CurrentMap));
	strtolower(g_CurrentMap);

	register_forward(FM_Sys_Error, "fwd__SysErrorPre", 0);
	register_forward(FM_GameShutdown, "fwd__GameShutdownPre", 0);

	iEnt = create_entity("hostage_entity");
	if(is_valid_ent(iEnt)) {
		entity_set_origin(iEnt, Float:{8192.0, 8192.0, 8192.0});
		DispatchSpawn(iEnt);
	}

	iEnt = create_entity("func_buyzone");
	if(is_valid_ent(iEnt)) {
		entity_set_origin(iEnt, Float:{8192.0, 8192.0, 8192.0});
		DispatchSpawn(iEnt);
	}

	precachePlayerModel(__PLAYER_MODEL_HUMAN);
	precachePlayerModel(__PLAYER_MODEL_HUMAN_VIP);
	precachePlayerModel(__PLAYER_MODEL_SURVIVOR);
	precachePlayerModel(__PLAYER_MODEL_WESKER);
	precachePlayerModel(__PLAYER_MODEL_LEATHERFACE);
	precachePlayerModel(__PLAYER_MODEL_TRIBAL);
	precachePlayerModel(__PLAYER_MODEL_SNIPER);
	for(i = 0; i < sizeof(__PLAYER_MODEL_L4D2); ++i) {
		precachePlayerModel(__PLAYER_MODEL_L4D2[i]);
	}
	precachePlayerModel(__PLAYER_MODEL_ZOMBIE);
	precachePlayerModel(__PLAYER_MODEL_ZOMBIE_VIP);
	precachePlayerModel(__PLAYER_MODEL_NEMESIS);
	precachePlayerModel(__PLAYER_MODEL_GRUNT);
	precachePlayerModel(__PLAYER_MODEL_CABEZON);
	precachePlayerModel(__PLAYER_MODEL_ANNIHILATOR);
	precachePlayerModel(__PLAYER_MODEL_FLESHPOUND);
	for(i = 0; i < sizeof(__PLAYER_MODEL_L4D2_ZOMBIES); ++i) {
		precachePlayerModel(__PLAYER_MODEL_L4D2_ZOMBIES[i]);
	}

	precache_model(__KNIFE_vMODEL_LEATHERFACE[0]);
	precache_model(__KNIFE_vMODEL_LEATHERFACE[1]);
	precache_model(__KNIFE_vMODEL_ZOMBIE);
	precache_model(__KNIFE_vMODEL_ZOMBIE_VIP);
	precache_model(__KNIFE_vMODEL_NEMESIS);
	precache_model(__KNIFE_vMODEL_ANNIHILATOR);
	precache_model(__KNIFE_vMODEL_FLESHPOUND);
	for(i = 0; i < sizeof(__KNIFE_vMODEL_L4D2_ZOMBIES); ++i) {
		precache_model(__KNIFE_vMODEL_L4D2_ZOMBIES[i]);
	}

	precache_model("models/rpgrocket.mdl");
	for(i = 0; i < sizeof(__GRENADE_MODEL_INFECTION); ++i) {
		precache_model(__GRENADE_MODEL_INFECTION[i]);
	}
	precache_model(__GRENADE_vMODEL_FIRE);
	precache_model(__GRENADE_vMODEL_FROST);
	precache_model(__GRENADE_vMODEL_FLARE);
	precache_model(__GRENADE_vMODEL_KILL);
	for(i = 0; i < sizeof(__GRENADE_MODEL_PIPE); ++i) {
		precache_model(__GRENADE_MODEL_PIPE[i]);
	}
	precache_model(__GRENADE_vMODEL_ANTIDOTE);
	for(i = 0; i < sizeof(__GRENADE_MODEL_DRUG); ++i) {
		precache_model(__GRENADE_MODEL_DRUG[i]);
	}
	for(i = 0; i < sizeof(__GRENADE_MODEL_SUPERNOVA); ++i) {
		precache_model(__GRENADE_MODEL_SUPERNOVA[i]);
	}
	for(i = 0; i < sizeof(__GRENADE_MODEL_BUBBLE); ++i) {
		precache_model(__GRENADE_MODEL_BUBBLE[i]);
	}

	precache_model(__MODEL_BAZOOKA[0]);
	precache_model(__MODEL_BAZOOKA[1]);
	precache_model(__MODEL_BUBBLE);
	precache_model(__MODEL_HEADZOMBIE);
	precache_model(__MODEL_HEADZOMBIE_SMALL);
	precache_model(__MODEL_ROCKET);
	precache_model(__MODEL_SKULL);

	precache_sound(__SOUND_ARMOR_HIT);
	precache_sound(__SOUND_AMMO_PICKUP);
	precache_sound(__SOUND_WIN_HUMANS);
	precache_sound(__SOUND_WIN_ZOMBIES);
	precache_sound(__SOUND_WIN_NO_ONE);
	for(i = 0; i < sizeof(__SOUND_ROUND_GENERAL); ++i) {
		precache_sound(__SOUND_ROUND_GENERAL[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ROUND_SURVIVOR); ++i) {
		precache_sound(__SOUND_ROUND_SURVIVOR[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ROUND_NEMESIS); ++i) {
		precache_sound(__SOUND_ROUND_NEMESIS[i]);
	}
	precache_sound(__SOUND_ROUND_GRUNT);
	precache_sound(__SOUND_ROUND_ARMAGEDDON);
	precache_generic(__SOUND_ROUND_MEGA_ARMAGEDDON);
	precache_sound(__SOUND_ROUND_GUNGAME);
	precache_sound(__SOUND_ROUND_SPECIAL);
	precache_sound(__SOUND_ROUND_L4D2);
	precache_sound(__SOUND_HUMAN_ANTIDOTE);
	precache_sound(__SOUND_WESKER_LASER);
	for(i = 0; i < sizeof(__SOUND_LEATHERFACE_CHAINSAW); ++i) {
		precache_sound(__SOUND_LEATHERFACE_CHAINSAW[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_PAIN); ++i) {
		precache_sound(__SOUND_ZOMBIE_PAIN[i]);
	}
	for(i = 0; i < sizeof(__SOUND_SPECIALMODE_PAIN); ++i) {
		precache_sound(__SOUND_SPECIALMODE_PAIN[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_KNIFE); ++i) {
		precache_sound(__SOUND_ZOMBIE_KNIFE[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_INFECT); ++i) {
		precache_sound(__SOUND_ZOMBIE_INFECT[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_ALERT); ++i) {
		precache_sound(__SOUND_ZOMBIE_ALERT[i]);
	}
	precache_sound(__SOUND_ZOMBIE_MADNESS);
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_DIE); ++i) {
		precache_sound(__SOUND_ZOMBIE_DIE[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_BURN); ++i) {
		precache_sound(__SOUND_ZOMBIE_BURN[i]);
	}
	for(i = 0; i < sizeof(__SOUND_NEMESIS_BAZOOKA); ++i) {
		precache_sound(__SOUND_NEMESIS_BAZOOKA[i]);
	}
	precache_sound(__SOUND_CABEZON_POWER);
	precache_sound(__SOUND_CABEZON_POWER_FINISH);
	precache_sound(__SOUND_NADE_INFECT_EXPLO);
	for(i = 0; i < sizeof(__SOUND_NADE_INFECT_EXPLO_PLAYER); ++i) {
		precache_sound(__SOUND_NADE_INFECT_EXPLO_PLAYER[i]);
	}
	precache_sound(__SOUND_NADE_FIRE_EXPLO);
	precache_sound(__SOUND_NADE_FROST_EXPLO);
	precache_sound(__SOUND_NADE_FROST_PLAYER);
	precache_sound(__SOUND_NADE_FROST_BREAK);
	precache_sound(__SOUND_NADE_FLARE_EXPLO);
	// precache_sound(__SOUND_NADE_THUNDER_EXPLO);
	for(i = 0; i < sizeof(__SOUND_NADE_PIPE_BEEP); ++i) {
		precache_sound(__SOUND_NADE_PIPE_BEEP[i]);
	}
	precache_sound(__SOUND_NADE_BUBBLE_EXPLO);
	precache_sound(__SOUND_LEVEL_UP);
	for(i = 0; i < sizeof(__SOUND_WOOD); ++i) {
		precache_sound(__SOUND_WOOD[i]);
	}
	for(i = 0; i < sizeof(__COMBO_HUMAN); ++i) {
		precache_sound(__COMBO_HUMAN[i][comboSound]);
	}

	for(i = 0; i < 31; ++i) {
		for(j = 0; j < 9; ++j) {
			if(__WEAPON_MODELS[i][j][weaponModelPath][0]) {
				precache_model(__WEAPON_MODELS[i][j][weaponModelPath]);
				continue;
			}

			break;
		}
	}

	for(i = 0; i < structIdHats; ++i) {
		if(__HATS[i][hatModel][0]) {
			precache_model(__HATS[i][hatModel]);
		}
	}

	g_Sprite_Trail = precache_model("sprites/dg/zp6/trail_00.spr");
	g_Sprite_ShockWave = precache_model("sprites/shockwave.spr");
	g_Sprite_Flame = precache_model("sprites/dg/zp6/flame_00.spr");
	g_Sprite_Smoke = precache_model("sprites/black_smoke3.spr");
	g_Sprite_Glass = precache_model("models/glassgibs.mdl");
	g_Sprite_SuperNova = precache_model("sprites/dg/zp6/nova_00.spr");
	g_Sprite_FExplo = precache_model("sprites/fexplo.spr");
	for(i = 0; i < sizeof(__SPRITE_COLORS_BALLS); ++i) {
		g_Sprite_ColorsBalls[i] = precache_model(__SPRITE_COLORS_BALLS[i]);
	}
	g_Sprite_Regeneration = precache_model("sprites/dg/zp6/regeneration_00.spr");
	precache_model("sprites/animglow01.spr");

	for(i = 0; i < sizeof(__GFX_TUTORS); ++i) {
		precache_generic(__GFX_TUTORS[i]);
	}

	g_fwdSpawn = register_forward(FM_Spawn, "fwd__SpawnPre", 0);
	g_fwdPrecacheSound = register_forward(FM_PrecacheSound, "fwd__PrecacheSoundPre", 0);
}

public plugin_init() {
	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	RegisterHookChain(RG_ShowMenu, "onClient__ShowMenuPre", false);
	RegisterHookChain(RG_ShowVGUIMenu, "onClient__ShowVGUIMenuPre", false);
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "onClient__HandleMenuChooseTeamPre", false);
	RegisterHookChain(RG_CBasePlayer_HintMessageEx, "basePlayer__HintMessageExPre", false);
	RegisterHookChain(RG_CSGameRules_DeadPlayerWeapons, "gameRules__DeadPlayerWeaponsPre", false);

	register_event("HLTV", "event__HLTV", "a", "1=0", "2=0");
	register_event("30", "event__Intermission", "a");
	register_event("Health", "event__Health", "be");
	register_event("AmmoX", "event__AmmoX", "be");

	register_logevent("logevent__RoundEnd", 2, "1=Round_End");

	unregister_forward(FM_Spawn, g_fwdSpawn);
	unregister_forward(FM_PrecacheSound, g_fwdPrecacheSound);
	register_forward(FM_SetClientKeyValue, "fwd__SetClientKeyValuePre", 0);
	register_forward(FM_ClientUserInfoChanged, "fwd__ClientUserInfoChangedPre", 0);
	register_forward(FM_ClientDisconnect, "fwd__ClientDisconnectPost", 1);
	register_forward(FM_ClientKill, "fwd__ClientKillPre", 0);
	register_forward(FM_EmitSound, "fwd__EmitSoundPre", 0);
	register_forward(FM_SetModel, "fwd__SetModelPre", 0);
	register_forward(FM_AddToFullPack, "fwd__AddToFullPackPost", 1);
	register_forward(FM_CmdStart, "fwd__CmdStartPre", 0);
	// register_forward(FM_UpdateClientData, "fwd__UpdateClientDataPost", 1);

	RegisterHam(Ham_Spawn, "player", "ham__PlayerSpawnPost", 1);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPre", 0);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPost", 1);
	RegisterHam(Ham_TakeDamage, "player", "ham__PlayerTakeDamagePre", 0);
	RegisterHam(Ham_TakeDamage, "player", "ham__PlayerTakeDamagePost", 1);
	RegisterHam(Ham_TraceAttack, "player", "ham__PlayerTraceAttackPre", 0);
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "ham__PlayerResetMaxSpeedPost", 1);

	if(equali(g_CurrentMap, "zm_kontrax_b5_buffed") || equali(g_CurrentMap, "zm_kontrax_b6_fix")) {
		RegisterHam(Ham_Use, "func_button", "ham__UseButtonPre", 0);
	}

	RegisterHam(Ham_Touch, "weaponbox", "ham__TouchWeaponPre", 0);
	RegisterHam(Ham_Touch, "armoury_entity", "ham__TouchWeaponPre", 0);
	RegisterHam(Ham_Touch, "weapon_shield", "ham__TouchWeaponPre", 0);
	RegisterHam(Ham_Touch, "player", "ham__TouchPlayerPost", 1);
	RegisterHam(Ham_Think, "grenade", "ham__ThinkGrenadePre", 0);
	RegisterHam(Ham_Player_PreThink, "player", "ham__PlayerPreThinkPre", 0);
	RegisterHam(Ham_Player_PostThink, "player", "ham__PlayerPostThinkPre", 0);
	RegisterHam(Ham_Player_Jump, "player", "ham__PlayerJumpPre", 0);
	RegisterHam(Ham_Player_Duck, "player", "ham__PlayerDuckPre", 0);

	for(new i = 1; i < sizeof(__WEAPON_ENT_NAMES); ++i) {
		if(__WEAPON_ENT_NAMES[i][0]) {
			if(i != CSW_C4 && i != CSW_HEGRENADE && i != CSW_FLASHBANG && i != CSW_SMOKEGRENADE && i != CSW_SG550 && i != CSW_G3SG1) {
				RegisterHam(Ham_Weapon_PrimaryAttack, __WEAPON_ENT_NAMES[i], "ham__WeaponPrimaryAttackPost", 1);

				if(i == CSW_KNIFE) {
					RegisterHam(Ham_Weapon_SecondaryAttack, __WEAPON_ENT_NAMES[i], "ham__WeaponSecondaryAttackPost", 1);
				} else {
					RegisterHam(Ham_Item_AttachToPlayer, __WEAPON_ENT_NAMES[i], "ham__ItemAttachToPlayerPre", 0);

					if(i != CSW_M3 && i != CSW_XM1014) {
						RegisterHam(Ham_Item_PostFrame, __WEAPON_ENT_NAMES[i], "ham__ItemPostFramePre", 0);
						RegisterHam(Ham_Weapon_Reload, __WEAPON_ENT_NAMES[i], "ham__WeaponReloadPost", 1);
					} else {
						RegisterHam(Ham_Item_PostFrame, __WEAPON_ENT_NAMES[i], "ham__ShotgunPostFramePre", 0);
						RegisterHam(Ham_Weapon_WeaponIdle, __WEAPON_ENT_NAMES[i], "ham__ShotgunWeaponIdlePre", 0);
					}
				}
			}

			RegisterHam(Ham_Item_Deploy, __WEAPON_ENT_NAMES[i], "ham__ItemDeployPost", 1);
		}
	}

	register_touch("grenade", "*", "touch__AllGrenade");
	register_touch(__ENT_CLASSNAME_BAZOOKA, "*", "touch__RocketBazooka");
	register_touch(__ENT_CLASSNAME_HEADZOMBIE, "player", "touch__PlayerHeadZombie");
	register_touch(__ENT_CLASSNAME_HEADZOMBIE_SMALL, "player", "touch__PlayerHeadZombieSmall");

	formatex(g_AmuletCustomConfirm, charsmax(g_AmuletCustomConfirm), "zp_ac_confirm %c%c%c", random_num('a', 'z'), random_num('a', 'z'), random_num('a', 'z'));

	register_clcmd("INGRESAR_CLAVE", "clcmd__EnterPassword");
	register_clcmd("V_INGRESAR_MAIL", "clcmd__VEnterMail");
	register_clcmd("V_INGRESAR_CLAVE", "clcmd__VEnterPassword");
	register_clcmd("INGRESAR_NOMBRE_AMULETO", "clcmd__EnterAmuletCustomName");
	register_clcmd("INGRESAR_NUMERO_AL_AZAR", "clcmd__EnterRandomNum");

	register_clcmd("say currentmap", "clcmd__CurrentMap");
	register_clcmd("say nextmap", "clcmd__NextMap");
	register_clcmd("say /rank", "clcmd__Rank");
	register_clcmd("say /nextmode", "clcmd__NextModeSay");
	register_clcmd("say /modo", "clcmd__NextModeSay");
	register_clcmd("say /mult", "clcmd__Mult");
	register_clcmd("say /update", "clcmd__Update");
	register_clcmd("say /invis", "clcmd__Invis");
	register_clcmd("say /discord", "clcmd__Discord");
	register_clcmd("say /spec", "clcmd__Spec");
	register_clcmd("say /cam", "clcmd__Cam");
	register_clcmd("say /mg", "clcmd__MiniGames");
	register_clcmd("say /mapas", "clcmd__Mapas");
	register_clcmd("say /bonusmapa", "clcmd__BonusMapa");

	for(new i = 0; i < sizeof(__BLOCK_COMMANDS); ++i) {
		register_clcmd(__BLOCK_COMMANDS[i], "clcmd__BlockCommands");
	}
	register_clcmd("radio1", "clcmd__Radio1");
	register_clcmd("radio2", "clcmd__Radio2");
	register_clcmd("radio3", "clcmd__Radio3");
	register_clcmd("drop", "clcmd__Drop");
	register_clcmd("nightvision", "clcmd__NVision");
	register_clcmd("say", "clcmd__Say");
	register_clcmd("say_team", "clcmd__SayTeam");

	register_clcmd("+grab", "clcmd__GrabOn");
	register_clcmd("-grab", "clcmd__GrabOff");

	register_clcmd("zp_save_all", "clcmd__SaveAll");
	register_clcmd("zp_ammopacks", "clcmd__AmmoPacks");
	register_clcmd("zp_xp", "clcmd__XP");
	register_clcmd("zp_level", "clcmd__Level");
	register_clcmd("zp_reset", "clcmd__Reset");
	register_clcmd("zp_points", "clcmd__Points");
	register_clcmd("zp_health", "clcmd__Health");
	register_clcmd("zp_hats", "clcmd__Hats");
	register_clcmd("zp_respawn", "clcmd__Respawn");
	register_clcmd("zp_zombie", "clcmd__Zombie");
	register_clcmd("zp_survivor", "clcmd__Survivor");
	register_clcmd("zp_wesker", "clcmd__Wesker");
	register_clcmd("zp_leatherface", "clcmd__Leatherface");
	register_clcmd("zp_nemesis", "clcmd__Nemesis");
	register_clcmd("zp_cabezon", "clcmd__Cabezon");
	register_clcmd("zp_annihilator", "clcmd__Annihilator");
	register_clcmd("zp_fleshpound", "clcmd__Fleshpound");
	register_clcmd("zp_grunt", "clcmd__Grunt");
	register_clcmd("zp_infection", "clcmd__Modes");
	register_clcmd("zp_plague", "clcmd__Modes");
	register_clcmd("zp_synapsis", "clcmd__Modes");
	register_clcmd("zp_mega_synapsis", "clcmd__Modes");
	register_clcmd("zp_armageddon", "clcmd__Modes");
	register_clcmd("zp_mega_armageddon", "clcmd__Modes");
	register_clcmd("zp_gungame", "clcmd__Modes");
	register_clcmd("zp_mega_gungame", "clcmd__Modes");
	register_clcmd("zp_drunk", "clcmd__Modes");
	register_clcmd("zp_mega_drunk", "clcmd__Modes");
	register_clcmd("zp_l4d2", "clcmd__Modes");
	register_clcmd("zp_duel_final", "clcmd__Modes");
	register_clcmd("zp_tribal", "clcmd__Modes");
	register_clcmd("zp_next_mode", "clcmd__NextMode");
	register_clcmd("zp_lighting", "clcmd__Lighting");
	register_clcmd("zp_ac_create", "clcmd__AmuletCustomCreate");
	register_clcmd(g_AmuletCustomConfirm, "clcmd__AmuletCustomConfirm");
	register_clcmd("zp_tutor", "clcmd__Tutor");
	// register_clcmd("zp_abrir", "clcmd__Abrir");
	register_clcmd("zp_mg_number", "clcmd__MgNumber");
	register_clcmd("zp_test", "clcmd__Test");
	register_clcmd("zp_ban", "clcmd__BanAccount");
	register_clcmd("zp_unban", "clcmd__UnBanAccount");
	register_clcmd("zp_start_votemap", "clcmd__StartVoteMap");

	register_impulse(OFF_IMPULSE_FLASHLIGHT, "impulse__FlashLight");
	register_impulse(OFF_IMPULSE_SPRAY, "impulse__Spray");

	register_menucmd(register_menuid("VoteMap Menu"), (-1 ^ (-1<<(g_VoteMap_SelectMaps + 2))), "menu__VoteMap");
	oldmenu_register();

	g_Message_Money = get_user_msgid("Money");
	g_Message_CurWeapon = get_user_msgid("CurWeapon");
	g_Message_FlashBat = get_user_msgid("FlashBat");
	g_Message_Flashlight = get_user_msgid("Flashlight");
	g_Message_NVGToggle = get_user_msgid("NVGToggle");
	g_Message_WeapPickup = get_user_msgid("WeapPickup");
	g_Message_AmmoPickup = get_user_msgid("AmmoPickup");
	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SendAudio = get_user_msgid("SendAudio");
	g_Message_StatusIcon = get_user_msgid("StatusIcon");
	g_Message_DeathMsg = get_user_msgid("DeathMsg");
	g_Message_ScoreInfo = get_user_msgid("ScoreInfo");
	g_Message_ScoreAttrib = get_user_msgid("ScoreAttrib");
	g_Message_ScreenFade = get_user_msgid("ScreenFade");
	g_Message_ScreenShake = get_user_msgid("ScreenShake");
	g_Message_Fov = get_user_msgid("SetFOV");
	g_Message_TutorText = get_user_msgid("TutorText");
	g_Message_TutorClose = get_user_msgid("TutorClose");
	g_Message_Fog = get_user_msgid("Fog");

	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET);

	register_message(g_Message_Money, "message__Money");
	register_message(g_Message_CurWeapon, "message__CurWeapon");
	register_message(g_Message_FlashBat, "message__FlashBat");
	register_message(g_Message_Flashlight, "message__Flashlight");
	register_message(g_Message_NVGToggle, "message__NVGToggle");
	register_message(g_Message_WeapPickup, "message__WeapPickup");
	register_message(g_Message_AmmoPickup, "message__AmmoPickup");
	register_message(g_Message_TextMsg, "message__TextMsg");
	register_message(g_Message_SendAudio, "message__SendAudio");
	register_message(g_Message_StatusIcon, "message__StatusIcon");

	g_HudSync_General = CreateHudSyncObj();
	g_HudSync_Combo = CreateHudSyncObj();
	g_HudSync_CurrentMode = CreateHudSyncObj();

	register_cvar("amx_nextmap", "", (FCVAR_SERVER | FCVAR_EXTDLL | FCVAR_SPONLY));
	g_pCvar_Delay = register_cvar("zp_delay", "5");
	g_pCvar_CanUseMinigames = register_cvar("zp_can_use_minigames", "1 2");

	g_Lights[0] = 'b';

	g_CurrentMode = MODE_INFECTION;
	g_NextMode = -1;
	g_HeadZombie_SysTime = get_gametime();

	set_cvar_string("sv_skyname", "space");

	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	createHats();
	loadSpawns();
	loadSql();
}

public plugin_cfg() {
	arrayset(g_ModeCountAdmin, 0, structIdModes);
	g_ModeCountAdmin_Total = 0;

	new iEnt = create_entity("info_target");

	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, __ENTTHINK_CLASSNAME_GENERAL);
		entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 0.1));

		register_think(__ENTTHINK_CLASSNAME_GENERAL, "think__General");
	}
}

public plugin_end() {
	TrieDestroy(g_tModeAnnihilator_Acerts);
	TrieDestroy(g_tExtraItem_Invisibility);
	TrieDestroy(g_tExtraItem_KillBomb);
	TrieDestroy(g_tExtraItem_PipeBomb);
	TrieDestroy(g_tExtraItem_AntidoteBomb);
	TrieDestroy(g_tExtraItem_Antidote);
	TrieDestroy(g_tExtraItem_ZombieMadness);
	TrieDestroy(g_tExtraItem_InfectionBomb);
	TrieDestroy(g_tExtraItem_ReduceDamage);
	TrieDestroy(g_tExtraItem_Petrification);

	if(get_cvar_num("mp_round_infinite") == 1) {
		set_cvar_num("mp_round_infinite", 0);
	}

	if(get_cvar_num("mp_freeforall") == 1) {
		set_cvar_num("mp_freeforall", 0);
	}

	if(g_VoteMap_Init) {
		new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_maps SET recent='0';");

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(0, sqlQuery, 69);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_maps SET recent='1' WHERE mapname=^"%s^" AND enable='1';", g_CurrentMap);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(0, sqlQuery, 60);
		} else {
			SQL_FreeHandle(sqlQuery);
		}
	}

	SQL_FreeHandle(g_SqlConnection);
	SQL_FreeHandle(g_SqlTuple);
}

public client_authorized(id, const authid[]) {
	copy(g_PlayerSteamId[id], charsmax(g_PlayerSteamId[]), authid);
	g_PlayerSteamIdCache[id][0] = EOS;
}

public client_connectex(id, const name[], const ip[], reason[128]) {
	copy(g_PlayerName[id], charsmax(g_PlayerName[]), name);

	if(containi(g_PlayerName[id], "DROP TABLE") != -1 || containi(g_PlayerName[id], "TRUNCATE") != -1 || containi(g_PlayerName[id], "INSERT") != -1 || containi(g_PlayerName[id], "UPDATE") != -1 || containi(g_PlayerName[id], "DELETE") != -1 || containi(g_PlayerName[id], "\\") != -1) {
		server_cmd("kick #%d ^"[#ZP] Tu nombre contiene caracteres inválidos. Para más información, contáctate con un staff en nuestro foro: %s^"", get_user_userid(id), __PLUGIN_COMMUNITY_FORUM);
		return;
	}

	new sIp[MAX_IP_WITH_PORT_LENGTH];
	new sPort[8];

	copy(sIp, charsmax(sIp), ip);
	strtok(sIp, g_PlayerIp[id], charsmax(g_PlayerIp[]), sPort, charsmax(sPort), ':');
}

public client_putinserver(id) {
	g_IsConnected[id] = 1;
	g_IsAlive[id] = 0;

	resetVars(id, 1);

	if(!is_user_bot(id) && !is_user_hltv(id)) {
		checkAccount(id);
	}
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	remove_task(id + TASK_CHECK_BUY);
	remove_task(id + TASK_CHECK_ACHIEVEMENTS);
	remove_task(id + TASK_CHECK_HATS);
	remove_task(id + TASK_MESSAGE_VIP);
	remove_task(id + TASK_MESSAGE_VINC);
	remove_task(id + TASK_PLAYED_TIME);
	remove_task(id + TASK_SAVE);
	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_FREEZE);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_HEALTH_REGENERATION);
	remove_task(id + TASK_HEALTH_IMMUNITY);
	remove_task(id + TASK_POWER_MODE);
	remove_task(id + TASK_IMMUNITY);
	remove_task(id + TASK_HEALTH_REGENERATION_ROTATE);
	remove_task(id + TASK_GRUNT_AIMING);
	remove_task(id + TASK_GRUNT_GLOW);
	remove_task(id + TASK_IMMUNITY_GG);
	remove_task(id + TASK_CONVERT_ZOMBIE);
	remove_task(id + TASK_NVISION);
	remove_task(id + TASK_TUTOR_TEXT);
	remove_task(id + TASK_DRUG);
	remove_task(id + TASK_GRAB);
	remove_task(id + TASK_GRAB_PRETHINK);

	if(g_IsAlive[id]) {
		if(!g_Zombie[id]) {
			finishComboHuman(id);
		} else {
			finishComboZombie(id);
		}

		checkRound(id);
	}

	if(g_Mode == MODE_ANNIHILATOR) {
		if(g_ModeAnnihilator_Acerts[id]) {
			TrieSetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], g_ModeAnnihilator_Acerts[id]);
		} else {
			TrieSetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], 0);
		}
	}

	new i;
	for(i = 0; i <= MaxClients; ++i) {
		if(g_GroupInvitationsId[i][id]) {
			--g_GroupInvitations[i];
		}

		g_GroupInvitationsId[i][id] = 0;
	}

	if(g_InGroup[id]) {
		new j;
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[g_InGroup[id]][j] == id) {
				break;
			}
		}

		checkGroup(id, j, id);
	}

	if(g_AccountStatus[id] != STATUS_CHECK_ACCOUNT && g_AccountStatus[id] != STATUS_LOADING) {
		saveInfo(id, 1);
	}

	checkPlayerOnDisconnect(id);

	g_ComboDamageNeedFake[id] = 0;
	g_IsAlive[id] = 0;
	g_IsConnected[id] = 0;
}

public checkPlayerOnDisconnect(const id) {
	if(g_IsAlive[id] && !g_NewRound) {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsConnected[i] || !(get_user_flags(i) & ADMIN_LEVEL_D)) {
				continue;
			}

			clientPrintColor(i, _, "!t%s!y - Desconectado [Modo: %s - %s (HP: %d) - R: %d - N: %d]", g_PlayerName[id], __MODES[g_CurrentMode][modeName], g_PlayerClassName[id], g_Health[id], g_Reset[id], g_Level[id]);
		}
	}
}

public event__HLTV() {
	if(g_VoteMap_NextRound) {
		clientPrintColor(0, _, "El siguiente mapa será !g%s!y", getNextMap());

		task__ChangeMapPre();
		return;
	}

	set_task(0.1, "task__RemoveStuff");

	if(g_Mode == MODE_GRUNT) {
		set_cvar_num("sv_alltalk", 1);
	} else if(g_Mode == MODE_MEGA_ARMAGEDDON || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		set_cvar_num("mp_round_infinite", 0);

		if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
			set_cvar_num("mp_freeforall", 0);
		}
	}

	g_Lights[0] = 'i';
	g_NewRound = 1;
	g_EndRound = 0;
	g_Mode = MODE_NONE;
	g_DrunkAtDay = 0;
	g_HappyHour = 0;
	g_EventModes = 0;
	g_ModeArmageddon_Init = 0;
	g_ModeArmageddon_Notice = 0;
	g_ModeMGG_Block = 0;
	g_ModeDuelFinal = 0;
	g_LastHumanOk_NoRespawn = 0;

	remove_task(TASK_VIRUST);
	set_task(2.0, "task__VirusT", TASK_VIRUST);

	remove_task(TASK_START_MODE);
	set_task((2.0 + get_pcvar_float(g_pCvar_Delay)), "task__StartMode", TASK_START_MODE);

	remove_task(TASK_ZOMBIE_BACK);
	set_task(30.0, "task__ZombieBack", TASK_ZOMBIE_BACK);

	if(g_NextMode != -1) {
		g_CurrentMode = g_NextMode;
		g_NextMode = -1;
	}

	checkEvents();

	new i;
	new j;

	for(i = 1; i <= MaxClients; ++i) {
		g_ModeMA_Reward[i] = 0;

		for(j = 0; j < structIdExtraItems; ++j) {
			g_ExtraItem_AlreadyBuy[i][j] = 0;

			if(__EXTRA_ITEMS[j][extraItemMultCount] && g_ExtraItem_Mult[i][j] >= __EXTRA_ITEMS[j][extraItemMultCount]) {
				--g_ExtraItem_Mult[i][j];
			}
		}

		sendFog(i);
	}

	g_UserExtraXP = (float(getUsersPlaying()) * 0.16);
}

public task__RemoveStuff() {
	new iEnt = -1;

	while((iEnt = find_ent_by_class(iEnt, "func_door_rotating")) != 0) {
		entity_set_origin(iEnt, Float:{8192.0, 8192.0, 8192.0});
	}
}

public event__Intermission() {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			if(g_Combo[i]) {
				if(!g_Zombie[i]) {
					clientPrintColor(i, _, "Tu combo humano ha finalizado porque el mapa ha terminado");
					finishComboHuman(i);
				} else {
					clientPrintColor(i, _, "Tu combo zombie ha finalizado porque el mapa ha terminado");
					finishComboZombie(i);
				}
			}

			if(g_AmmoPacks_BestMap[i] > g_AmmoPacks_BestMapHistory[i]) {
				g_AmmoPacks_BestMapHistory[i] = g_AmmoPacks_BestMap[i];

				if(g_AmmoPacks_BestMap[i] > 5000) {
					setAchievement(i, AMMOPACKS_MAP_x5000);

					if(g_AmmoPacks_BestMap[i] > 10000) {
						setAchievement(i, AMMOPACKS_MAP_x10000);

						if(g_AmmoPacks_BestMap[i] > 25000) {
							setAchievement(i, AMMOPACKS_MAP_x25000);

							if(g_AmmoPacks_BestMap[i] > 50000) {
								setAchievement(i, AMMOPACKS_MAP_x50000);

								if(g_AmmoPacks_BestMap[i] > 100000) {
									setAchievement(i, AMMOPACKS_MAP_x100000);
								}
							}
						}
					}
				}

				g_AmmoPacks_BestMap[i] = 0;
			}
		}
	}
}

public event__AmmoX(const id) {
	if(g_Zombie[id]) {
		return;
	}

	static iType;
	iType = read_data(1);

	if(iType >= sizeof(__AMMO_WEAPON)) {
		return;
	}

	static iWeaponId;
	iWeaponId = __AMMO_WEAPON[iType];

	if(__MAX_BPAMMO[iWeaponId] <= 2) {
		return;
	}

	static iAmount;
	iAmount = read_data(2);

	if(iAmount < __MAX_BPAMMO[iWeaponId]) {
		static iArgs[1];
		iArgs[0] = iWeaponId;

		set_task(0.1, "task__RefillBPAmmo", id, iArgs, sizeof(iArgs));
	}
}

public task__RefillBPAmmo(const args[1], const id) {
	if(!g_IsAlive[id] || g_Zombie[id] || g_Mode == MODE_ANNIHILATOR) {
		return;
	}

	set_msg_block(g_Message_AmmoPickup, BLOCK_ONCE);
	ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[args[0]], __AMMO_TYPE[args[0]], __MAX_BPAMMO[args[0]]);
}

public event__Health(const id) {
	g_Health[id] = get_user_health(id);
}

public logevent__RoundEnd() {
	static Float:flGameTime;
	static Float:flLastEndTime;
	
	flGameTime = get_gametime();
	
	if((flGameTime - flLastEndTime) < 0.5) {
		return;
	}
	
	flLastEndTime = flGameTime;

	g_EndRound = 1;

	remove_task(TASK_VIRUST);
	remove_task(TASK_START_MODE);
	remove_task(TASK_ZOMBIE_BACK);
	remove_task(TASK_MODE_INFECTION);
	remove_task(TASK_MODE_ARMAGEDDON);
	remove_task(TASK_MODE_MEGA_ARMAGEDDON);
	remove_task(TASK_MODE_MEGA_GUNGAME);
	remove_task(TASK_MODE_DUEL_FINAL);
	remove_task(TASK_MODE_CABEZON);
	remove_task(TASK_MODE_FLESHPOUND);

	if(!getZombies()) {
		showDHUDMessage(0, 0, 0, 255, -1.0, 0.25, 0, 5.0, "¡GANARON LOS HUMANOS!");
		playSound(0, __SOUND_WIN_HUMANS);

		++g_ScoreHumans;
	} else if(!getHumans()) {
		showDHUDMessage(0, 255, 0, 0, -1.0, 0.25, 0, 5.0, "¡GANARON LOS ZOMBIES!");
		playSound(0, __SOUND_WIN_ZOMBIES);

		++g_ScoreZombies;
	} else {
		showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 5.0, "¡NO GANÓ NADIE!");
		playSound(0, __SOUND_WIN_NO_ONE);
	}

	stuffModes();
	rewardModes();
	rewardModesBySort();

	new iUsersPlaying = getUsersPlaying();
	new i;

	if(iUsersPlaying < 1) {
		return;
	}

	if(g_EndRound_Forced) {
		g_EndRound_Forced = 0;

		new iClass = -1;
		new iDifficultClass = -1;
		new iReward = 0;

		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}

			if(!g_SpecialMode[i] && !g_LastZombie[i] && !g_LastHuman[i]) {
				continue;
			}

			if(g_SpecialMode[i]) {
				switch(g_SpecialMode[i]) {
					case MODE_SURVIVOR: {
						switch(g_Difficult[i][DIFFICULT_CLASS_SURVIVOR]) {
							case DIFFICULT_NORMAL: {
								setAchievement(i, SURVIVOR_PRINCIPIANTE);
							} case DIFFICULT_HARD: {
								setAchievement(i, SURVIVOR_AVANZADO);
							} case DIFFICULT_VERY_HARD: {
								setAchievement(i, SURVIVOR_EXPERTO);
							} case DIFFICULT_EXPERT: {
								setAchievement(i, SURVIVOR_PRO);
							}
						}

						iClass = P_HUMAN;
						iDifficultClass = DIFFICULT_CLASS_SURVIVOR;
					} case MODE_WESKER: {
						switch(g_Difficult[i][DIFFICULT_CLASS_WESKER]) {
							case DIFFICULT_NORMAL: {
								setAchievement(i, WESKER_PRINCIPIANTE);
							} case DIFFICULT_HARD: {
								setAchievement(i, WESKER_AVANZADO);
							} case DIFFICULT_VERY_HARD: {
								setAchievement(i, WESKER_EXPERTO);
							} case DIFFICULT_EXPERT: {
								setAchievement(i, WESKER_PRO);
							}
						}

						iClass = P_HUMAN;
						iDifficultClass = DIFFICULT_CLASS_WESKER;

						if(iUsersPlaying >= 15) {
							setAchievement(i, MI_DEAGLE_Y_YO);

							if(g_Health[i] == g_MaxHealth[i]) {
								setAchievement(i, L_INTACTO);
							}

							if(g_WeskLaser[i] >= 3) {
								setAchievement(i, NO_ME_HACE_FALTA);
								giveHat(i, HAT_HOOD);
							}
						}
					} case MODE_LEATHERFACE: {
						switch(g_Difficult[i][DIFFICULT_CLASS_LEATHERFACE]) {
							case DIFFICULT_NORMAL: {
								setAchievement(i, LEATHERFACE_PRINCIPIANTE);
							} case DIFFICULT_HARD: {
								setAchievement(i, LEATHERFACE_AVANZADO);
							} case DIFFICULT_VERY_HARD: {
								setAchievement(i, LEATHERFACE_EXPERTO);
							} case DIFFICULT_EXPERT: {
								setAchievement(i, LEATHERFACE_PRO);
							}
						}

						iClass = P_HUMAN;
						iDifficultClass = DIFFICULT_CLASS_LEATHERFACE;
					} case MODE_NEMESIS: {
						switch(g_Difficult[i][DIFFICULT_CLASS_NEMESIS]) {
							case DIFFICULT_NORMAL: {
								setAchievement(i, NEMESIS_PRINCIPIANTE);
							} case DIFFICULT_HARD: {
								setAchievement(i, NEMESIS_AVANZADO);
							} case DIFFICULT_VERY_HARD: {
								setAchievement(i, NEMESIS_EXPERTO);
							} case DIFFICULT_EXPERT: {
								setAchievement(i, NEMESIS_PRO);
							}
						}

						iClass = P_ZOMBIE;
						iDifficultClass = DIFFICULT_CLASS_NEMESIS;

						if(g_Bazooka[i]) {
							 setAchievement(i, CRATER_SANGRIENTO);
						}
					} case MODE_CABEZON: {
						switch(g_Difficult[i][DIFFICULT_CLASS_CABEZON]) {
							case DIFFICULT_NORMAL: {
								setAchievement(i, CABEZON_PRINCIPIANTE);
							} case DIFFICULT_HARD: {
								setAchievement(i, CABEZON_AVANZADO);
							} case DIFFICULT_VERY_HARD: {
								setAchievement(i, CABEZON_EXPERTO);
							} case DIFFICULT_EXPERT: {
								setAchievement(i, CABEZON_PRO);
							}
						}

						iClass = P_ZOMBIE;
						iDifficultClass = DIFFICULT_CLASS_CABEZON;
					} case MODE_ANNIHILATOR: {
						switch(g_Difficult[i][DIFFICULT_CLASS_ANNIHILATOR]) {
							case DIFFICULT_NORMAL: {
								setAchievement(i, ANNIHILATOR_PRINCIPIANTE);
							} case DIFFICULT_HARD: {
								setAchievement(i, ANNIHILATOR_AVANZADO);
							} case DIFFICULT_VERY_HARD: {
								setAchievement(i, ANNIHILATOR_EXPERTO);
							} case DIFFICULT_EXPERT: {
								setAchievement(i, ANNIHILATOR_PRO);
							}
						}

						iClass = P_ZOMBIE;
						iDifficultClass = DIFFICULT_CLASS_ANNIHILATOR;

						setAchievement(i, MI_CUCHILLA_Y_YO);
					}
				}

				iReward = g_PointsMult[i];

				if(iDifficultClass != -1) {
					if(g_Difficult[i][iDifficultClass] != DIFFICULT_NORMAL) {
						iReward += g_Difficult[i][iDifficultClass];
					}

					g_Points[i][iClass] += iReward;
					++g_Points[i][P_LEGACY];

					clientPrintColor(0, i, "!t%s!y ganó !g%d p%c!y y !g1 pL!y por ganar el modo !g%s!y", g_PlayerName[i], iReward, ((iClass == P_HUMAN) ? 'H' : 'Z'), g_PlayerClassName[i]);
				} else {
					g_Points[i][iClass] += iReward;
					clientPrintColor(0, i, "!t%s!y ganó !g%d p%c!y por ganar el modo !g%s!y", g_PlayerName[i], iReward, ((iClass == P_HUMAN) ? 'H' : 'Z'), g_PlayerClassName[i]);
				}
			} else if(g_LastZombie[i]) {
				g_Points[i][P_ZOMBIE] += g_PointsMult[i];
				clientPrintColor(0, i, "!t%s!y ganó !t%d pZ!y porque el !gmodo especial!y se desconectó", g_PlayerName[i], g_PointsMult[i]);
			} else if(g_LastHuman[i]) {
				g_Points[i][P_HUMAN] += g_PointsMult[i];
				clientPrintColor(0, i, "!t%s!y ganó !t%d pH!y porque el !gmodo especial!y se desconectó", g_PlayerName[i], g_PointsMult[i]);
			}

			break;
		}
	}

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			if(!g_Zombie[i]) {
				finishComboHuman(i);
			} else {
				finishComboZombie(i);
			}

			if(g_AmmoPacks_BestRound[i] > g_AmmoPacks_BestRoundHistory[i]) {
				g_AmmoPacks_BestRoundHistory[i] = g_AmmoPacks_BestRound[i];

				if(g_AmmoPacks_BestRound[i] > 100) {
					setAchievement(i, AMMOPACKS_ROUND_x100);

					if(g_AmmoPacks_BestRound[i] > 500) {
						setAchievement(i, AMMOPACKS_ROUND_x500);

						if(g_AmmoPacks_BestRound[i] > 1000) {
							setAchievement(i, AMMOPACKS_ROUND_x1000);

							if(g_AmmoPacks_BestRound[i] > 5000) {
								setAchievement(i, AMMOPACKS_ROUND_x5000);

								if(g_AmmoPacks_BestRound[i] > 10000) {
									setAchievement(i, AMMOPACKS_ROUND_x10000);
								}
							}
						}
					}
				}

				g_AmmoPacks_BestRound[i] = 0;
			}
		}
	}

	set_task(0.1, "task__BalanceTeams");
}

public task__BalanceTeams() {
	static iUsersPlaying;
	iUsersPlaying = getUsersPlaying();

	if(iUsersPlaying < 2) {
		return;
	}

	static iMaxTerrors;
	static iTerrors;
	static i;
	static TeamName:iTeam[MAX_PLAYERS + 1];

	iMaxTerrors = (iUsersPlaying / 2);
	iTerrors = 0;
	i = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i]) {
			continue;
		}

		iTeam[i] = getUserTeam(i);

		if((iTeam[i] == TEAM_UNASSIGNED) || (iTeam[i] == TEAM_SPECTATOR)) {
			continue;
		}

		setUserTeam(i, TEAM_CT);
		iTeam[i] = TEAM_CT;
	}

	i = 0;

	while(iTerrors < iMaxTerrors) {
		if(++i > MaxClients) {
			i = 1;
		}
		
		if(!g_IsConnected[i]) {
			continue;
		}
		
		if(iTeam[i] != TEAM_CT) {
			continue;
		}
		
		if(random_num(0, 1)) {
			setUserTeam(i, TEAM_TERRORIST);
			iTeam[i] = TEAM_TERRORIST;

			++iTerrors;
		}
	}
}

public ham__PlayerJumpPre(const id) {
	if(!g_IsAlive[id] || !g_LongJump[id]) {
		return HAM_IGNORED;
	}

	static iFlags;
	iFlags = entity_get_int(id, EV_INT_flags);

	if(iFlags & FL_WATERJUMP || entity_get_int(id, EV_INT_waterlevel) >= 2) {
		return HAM_IGNORED;
	}

	static iButtonPressed;
	iButtonPressed = get_pdata_int(id, OFFSET_BUTTON_PRESSED, OFFSET_LINUX);

	if(!(iButtonPressed & IN_JUMP) || !(iFlags & FL_ONGROUND)) {
		return HAM_IGNORED;
	}

	if((entity_get_int(id, EV_INT_bInDuck) || iFlags & FL_DUCKING) && get_pdata_int(id, OFFSET_LONG_JUMP, OFFSET_LINUX) && entity_get_int(id, EV_INT_button) & IN_DUCK && entity_get_int(id, EV_INT_flDuckTime)) {
		static Float:vecVelocity[3];
		static iVelocity;

		entity_get_vector(id, EV_VEC_velocity, vecVelocity);
		iVelocity = ((g_AccountId[id] != 1) ? 20 : 1);

		if(vector_length(vecVelocity) > iVelocity) {
			entity_get_vector(id, EV_FLARE_COLOR, vecVelocity);
			vecVelocity[0] = -5.0;
			entity_set_vector(id, EV_FLARE_COLOR, vecVelocity);

			get_global_vector(GL_v_forward, vecVelocity);

			vecVelocity[0] *= 576.0;
			vecVelocity[1] *= 576.0;
			vecVelocity[2] = 310.0;

			entity_set_vector(id, EV_VEC_velocity, vecVelocity);

			set_pdata_int(id, OFFSET_ACTIVITY, OFFSET_LEAP, OFFSET_LINUX);
			set_pdata_int(id, OFFSET_SILENT, OFFSET_LEAP, OFFSET_LINUX);
			
			g_InJump[id] = 1;

			entity_set_int(id, EV_INT_oldbuttons, entity_get_int(id, EV_INT_oldbuttons) | IN_JUMP);

			entity_set_int(id, EV_INT_gaitsequence, 7);
			entity_set_float(id, EV_FL_frame, 0.0);

			set_pdata_int(id, OFFSET_BUTTON_PRESSED, (iButtonPressed & ~IN_JUMP), OFFSET_LINUX);
			return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}

public ham__PlayerDuckPre(const id) {
	if(g_InJump[id]) {
		g_InJump[id] = 0;
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public fwd__SysErrorPre(const error[]) {
	log_to_file(__SERVER_FILE, "FORWARD: FM_Sys_Error | Error: %s | Mapa: %s", ((error[0]) ? error : "Ninguno"), g_CurrentMap);
}

public fwd__GameShutdownPre(const error[]) {
	log_to_file(__SERVER_FILE, "FORWARD: FM_GameShutdown | Error: %s | Mapa: %s", ((error[0]) ? error : "Ninguno"), g_CurrentMap);
}

public fwd__SpawnPre(const ent) {
	if(!pev_valid(ent)) {
		return FMRES_IGNORED;
	}

	static sClassName[32];
	static i;

	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	for(i = 0; i < sizeof(__REMOVE_ENTS); ++i) {
		if(equal(sClassName, __REMOVE_ENTS[i])) {
			remove_entity(ent);
			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public fwd__PrecacheSoundPre(const sound[]) {
	if(equal(sound, "hostage", 7)) {
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fwd__ClientDisconnectPost() {
	checkLastZombie();
}

public fwd__ClientKillPre() {
	return FMRES_SUPERCEDE;
}

public fwd__EmitSoundPre(const id, const channel, const sample[], const Float:volume, const Float:attn, const flags, const pitch) {
	if(sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') {
		return FMRES_SUPERCEDE;
	}

	if(sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l') {
		return FMRES_SUPERCEDE;
	}

	if(!isPlayerValidConnected(id)) {
		return FMRES_IGNORED;
	}

	if(!g_Zombie[id]) {
		if(g_SpecialMode[id] == MODE_LEATHERFACE) {
			new i;
			for(i = 0; i < sizeof(__SOUND_LEATHERFACE_CHAINSAW); ++i) {
				if(equal(sample, __SOUND_HUMAN_KNIFE_DEFAULT[i])) {
					emit_sound(id, channel, __SOUND_LEATHERFACE_CHAINSAW[i], volume, attn, flags, pitch);
					return FMRES_SUPERCEDE;
				}
			}
		}

		return FMRES_IGNORED;
	}

	if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') { // BHIT
		if(g_SpecialMode[id]) {
			emit_sound(id, channel, __SOUND_SPECIALMODE_PAIN[random_num(0, charsmax(__SOUND_SPECIALMODE_PAIN))], volume, attn, flags, pitch);
		} else {
			emit_sound(id, channel, __SOUND_ZOMBIE_PAIN[random_num(0, charsmax(__SOUND_ZOMBIE_PAIN))], volume, attn, flags, pitch);
		}

		return FMRES_SUPERCEDE;
	}

	if(g_CurrentWeapon[id] == CSW_KNIFE) {
		if(!g_BlockSound[id]) {
			if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i') { // KNI (FE)
				if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') { // SLA (SH)
					emit_sound(id, channel, __SOUND_ZOMBIE_KNIFE[2], volume, attn, flags, pitch);
					return FMRES_SUPERCEDE;
				}

				if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') { // HIT
					if(sample[17] == 'w') {
						emit_sound(id, channel, __SOUND_ZOMBIE_KNIFE[1], volume, attn, flags, pitch);
					} else {
						emit_sound(id, channel, __SOUND_ZOMBIE_KNIFE[0], volume, attn, flags, pitch);
					}

					return FMRES_SUPERCEDE;
				}

				if(sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') { // STA (B)
					emit_sound(id, channel, __SOUND_ZOMBIE_KNIFE[1], volume, attn, flags, pitch);
					return FMRES_SUPERCEDE;
				}
			}
		} else {
			g_BlockSound[id] = 0;
		}
	}

	if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) { // DIE / DEA (D)
		emit_sound(id, channel, __SOUND_ZOMBIE_DIE[random_num(0, charsmax(__SOUND_ZOMBIE_DIE))], volume, attn, flags, pitch);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fwd__SetModelPre(const ent, const model[]) {
	if(strlen(model) < 8) {
		return FMRES_IGNORED;
	}

	if(model[7] != 'w' || model[8] != '_') {
		return FMRES_IGNORED;
	}

	static Float:flDmgTime;
	flDmgTime = entity_get_float(ent, EV_FL_dmgtime);

	if(flDmgTime == 0.0) {
		return FMRES_IGNORED;
	}

	static iId;
	iId = entity_get_edict(ent, EV_ENT_owner);

	switch(model[9]) {
		case 'h': {
			if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
				return FMRES_IGNORED;
			}

			replaceWeaponModels(iId, CSW_HEGRENADE);

			if(g_Zombie[iId]) {
				effectGrenade(ent, 0, 255, 0, NADE_TYPE_INFECTION);

				entity_set_model(ent, __GRENADE_MODEL_INFECTION[2]);
				return FMRES_SUPERCEDE;
			} else {
				if(g_DrugBomb[iId]) {
					effectGrenade(ent, 255, 255, 0, ((!g_DrugBombMode[iId]) ? NADE_TYPE_DRUG : NADE_TYPE_FIRE));

					--g_DrugBomb[iId];

					entity_set_model(ent, __GRENADE_MODEL_DRUG[2]);
					return FMRES_SUPERCEDE;
				} else if(g_KillBomb[iId]) {
					effectGrenade(ent, 107, 66, 38, NADE_TYPE_KILL);

					--g_KillBomb[iId];
				} else {
					effectGrenade(ent, 255, 0, 0, NADE_TYPE_FIRE);
				}
			}
		} case 'f': {
			replaceWeaponModels(iId, CSW_FLASHBANG);

			if(g_SupernovaBomb[iId]) {
				effectGrenade(ent, 0, 255, 255, ((!g_SupernovaBombMode[iId]) ? NADE_TYPE_SUPERNOVA : NADE_TYPE_FROST));

				--g_SupernovaBomb[iId];

				entity_set_model(ent, __GRENADE_MODEL_SUPERNOVA[2]);
				return FMRES_SUPERCEDE;
			} else if(g_PipeBomb[iId]) {
				effectGrenade(ent, 255, 0, 255, NADE_TYPE_PIPE);

				--g_PipeBomb[iId];

				entity_set_model(ent, __GRENADE_MODEL_PIPE[1]);
				return FMRES_SUPERCEDE;
			} else {
				effectGrenade(ent, 0, 0, 255, NADE_TYPE_FROST);
			}
		} case 's': {
			replaceWeaponModels(iId, CSW_SMOKEGRENADE);

			if(g_BubbleBomb[iId]) {
				effectGrenade(ent, g_UserOptions_Color[iId][COLOR_TYPE_FLARE][0], g_UserOptions_Color[iId][COLOR_TYPE_FLARE][1], g_UserOptions_Color[iId][COLOR_TYPE_FLARE][2], ((!g_BubbleBombMode[iId]) ? NADE_TYPE_BUBBLE : NADE_TYPE_FLARE));

				--g_BubbleBomb[iId];

				entity_set_model(ent, __GRENADE_MODEL_BUBBLE[2]);
				return FMRES_SUPERCEDE;
			} else if(g_AntidoteBomb[iId]) {
				effectGrenade(ent, 198, 226, 255, NADE_TYPE_ANTIDOTE);

				--g_AntidoteBomb[iId];
			} else {
				effectGrenade(ent, g_UserOptions_Color[iId][COLOR_TYPE_FLARE][0], g_UserOptions_Color[iId][COLOR_TYPE_FLARE][1], g_UserOptions_Color[iId][COLOR_TYPE_FLARE][2], NADE_TYPE_FLARE);
			}
		}
	}

	return FMRES_IGNORED;
}

public fwd__AddToFullPackPost(const es, const e, const ent, const host, const host_flags, const player, const player_set) {
	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT) {
		return FMRES_IGNORED;
	}

	if(player && g_IsAlive[host] && g_IsAlive[ent] && ((g_PlayerTeam[host] == TEAM_CT && g_PlayerTeam[ent] == TEAM_CT) || (g_NewRound || g_EndRound))) {
		set_es(es, ES_Solid, SOLID_NOT);

		if(g_UserOptions_GroupGlow[host]) {
			if(g_InGroup[host] && (g_InGroup[host] == g_InGroup[ent])) {
				static vecColor[3];

				vecColor[0] = g_UserOptions_Color[host][COLOR_TYPE_GROUP_GLOW][0];
				vecColor[1] = g_UserOptions_Color[host][COLOR_TYPE_GROUP_GLOW][1];
				vecColor[2] = g_UserOptions_Color[host][COLOR_TYPE_GROUP_GLOW][2];

				set_es(es, ES_RenderFx, kRenderFxGlowShell);
				set_es(es, ES_RenderColor, vecColor);
			} else if(!g_InGroup[host]) {
				set_es(es, ES_RenderFx, kRenderFxNone);
				set_es(es, ES_RenderColor, {0, 0, 0});
			}
		}

		switch(g_UserOptions_Invis[host]) {
			case 0: {
				set_es(es, ES_RenderMode, kRenderTransAlpha);
				set_es(es, ES_RenderAmt, 50);
			} case 1: {
				if(g_ConvertZombie[host]) {
					set_es(es, ES_RenderMode, kRenderTransAlpha);
					set_es(es, ES_RenderAmt, 50);
				} else {
					set_es(es, ES_RenderMode, kRenderTransTexture);
					set_es(es, ES_RenderAmt, 0);
				}
			} case 2: {
				if(g_InGroup[host] && (g_InGroup[host] == g_InGroup[ent])) {
					set_es(es, ES_RenderMode, kRenderTransAlpha);
					set_es(es, ES_RenderAmt, 50);
				} else {
					set_es(es, ES_RenderMode, kRenderTransTexture);
					set_es(es, ES_RenderAmt, 0);
				}
			}
		}
	}

	// if(player) {
		// if(g_IsAlive[host]) {
			// if(g_IsAlive[ent] && (g_PlayerSolid[host] && g_PlayerSolid[ent]) && ((g_PlayerTeam[host] == TEAM_CT && g_PlayerTeam[ent] == TEAM_CT) || (g_NewRound || g_EndRound))) {
				// set_es(es, ES_Solid, SOLID_NOT);

				// if(g_UserOptions_GroupGlow[host]) {
					// if(g_InGroup[host] && (g_InGroup[host] == g_InGroup[ent])) {
						// static vecColor[3];

						// vecColor[0] = g_UserOptions_Color[host][COLOR_TYPE_GROUP_GLOW][0];
						// vecColor[1] = g_UserOptions_Color[host][COLOR_TYPE_GROUP_GLOW][1];
						// vecColor[2] = g_UserOptions_Color[host][COLOR_TYPE_GROUP_GLOW][2];

						// set_es(es, ES_RenderFx, kRenderFxGlowShell);
						// set_es(es, ES_RenderColor, vecColor);
					// } else if(!g_InGroup[host]) {
						// set_es(es, ES_RenderFx, kRenderFxNone);
						// set_es(es, ES_RenderColor, {0, 0, 0});
					// }
				// }

				// static Float:flDistance;
				// flDistance = entity_range(host, ent);

				// if(flDistance < 256.0 && (!g_UserOptions_Invis[host] || (g_UserOptions_Invis[host] == 2 && g_InGroup[host] && (g_InGroup[host] == g_InGroup[ent])) || g_ConvertZombie[host])) {
					// set_es(es, ES_RenderMode, kRenderTransAlpha);
					// set_es(es, ES_RenderAmt, (((floatround(flDistance) / 2) < 40) ? 40 : (floatround(flDistance) / 2)));
				// }
			// }

			// if(!g_Zombie[host] && !g_Zombie[ent] && g_UserOptions_Invis[host] && !g_ConvertZombie[host]) {
				// if(g_UserOptions_Invis[host] == 2 && !(g_InGroup[host] && (g_InGroup[host] == g_InGroup[ent]))) {
					// set_es(es, ES_RenderMode, kRenderTransTexture);
					// set_es(es, ES_RenderAmt, 0);
				//  else {
					// set_es(es, ES_RenderMode, kRenderTransTexture);
					// set_es(es, ES_RenderAmt, 0);
				// }
			// }
		// }
	// }

	return FMRES_IGNORED;
}

public fwd__CmdStartPre(const id, const uc_handle) {
	if(!g_IsAlive[id]) {
		return FMRES_IGNORED;
	}

	static iButton;
	iButton = get_uc(uc_handle, UC_Buttons);

	if(g_ModeMGG_Block) {
		if(iButton & IN_ATTACK) {
			iButton &= ~IN_ATTACK;
		}

		if(iButton & IN_ATTACK2) {
			iButton &= ~IN_ATTACK2;
		}

		set_uc(uc_handle, UC_Buttons, iButton);
		return FMRES_SUPERCEDE;
	}

	static iOldButton;
	iOldButton = entity_get_int(id, EV_INT_oldbuttons);

	switch(g_SpecialMode[id]) {
		case MODE_SURVIVOR: {
			if(g_Mode == MODE_SURVIVOR && !g_Immunity[id] && !g_SurvImmunity[id] && g_Difficult[id][DIFFICULT_CLASS_SURVIVOR] < DIFFICULT_VERY_HARD && (iButton & IN_ATTACK2) && !(iOldButton & IN_ATTACK2) && !g_EndRound) {
				survivorImmunity(id);
			}
		} case MODE_WESKER: {
			if(g_WeskLaser[id] && get_gametime() >= g_WeskLaser_LastUse[id] && g_CurrentWeapon[id] == CSW_DEAGLE && (iButton & IN_ATTACK2) && !(iOldButton & IN_ATTACK2) && !g_EndRound) {
				weskerLaserFire(id);
			}
		} case MODE_NEMESIS, MODE_ANNIHILATOR: {
			if(g_Bazooka[id] && g_CurrentWeapon[id] == CSW_AK47 && !g_EndRound) {
				if((iButton & IN_ATTACK) && !(iOldButton & IN_ATTACK)) {
					bazookaFire(id);
				} else if(g_Hab[id][HAB_S_NEM_BAZOOKA_FOLLOW] && g_SpecialMode[id] != MODE_ANNIHILATOR && (iButton & IN_ATTACK2) && !(iOldButton & IN_ATTACK2)) {
					g_BazookaMode[id] = !g_BazookaMode[id];
					clientPrint(id, print_center, "Modo de disparo: %s", ((g_BazookaMode[id]) ? "Seguimiento" : "Normal"));
				}
			}
		}
	}

	if(g_WeaponData[id][g_CurrentWeapon[id]][WEAPON_DATA_LEVEL] >= 15 && (iButton & IN_ATTACK) && g_WeaponSecondaryAutofire[id] && ((1<<g_CurrentWeapon[id]) & SECONDARY_WEAPONS_BIT_SUM)) {
		set_uc(uc_handle, UC_Buttons, (iButton & ~IN_ATTACK));
		g_WeaponSecondaryAutofire[id] = 0;
	}

	return FMRES_IGNORED;
}

public survivorImmunity(const id) {
	if(!g_IsAlive[id] || g_SpecialMode[id] != MODE_SURVIVOR) {
		return;
	}

	clientPrint(0, print_center, "¡El survivor ha activado su inmunidad!");

	g_Immunity[id] = 1;
	g_SurvImmunity[id] = 1;

	setUserAura(id, 100, 100, 100, 15);
	set_user_rendering(id, kRenderFxGlowShell, 100, 100, 100, kRenderNormal, 4);

	remove_task(id + TASK_POWER_MODE);
	set_task(((g_Hab[id][HAB_S_S_EXTRA_IMMUNITY]) ? 25.0 : 15.0), "task__RemoveSurvImmunity", id + TASK_POWER_MODE);
}

public task__RemoveSurvImmunity(const task_id) {
	static iId;
	iId = (task_id - TASK_POWER_MODE);

	if(!g_IsAlive[iId]) {
		return;
	}

	if(g_SpecialMode[iId] == MODE_SURVIVOR) {
		clientPrint(0, print_center, "¡El survivor ha perdido su inmunidad!");
	}

	g_Immunity[iId] = 0;

	setUserAura(iId, 0, 0, 255, 15);
	set_user_rendering(iId, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 4);
}

public weskerLaserFire(const id) {
	if(!g_IsAlive[id] || g_SpecialMode[id] != MODE_WESKER) {
		return;
	}

	--g_WeskLaser[id];
	g_WeskLaser_LastUse[id] = (get_gametime() + 0.75);

	emitSound(id, CHAN_VOICE, __SOUND_WESKER_LASER, .pitch=PITCH_HIGH);
	emitSound(id, CHAN_WEAPON, __SOUND_WESKER_LASER, .pitch=PITCH_HIGH);

	entity_set_vector(id, EV_FLARE_COLOR, Float:{-1.0, 0.0, 0.0});

	setAnimation(id, 1);

	if(g_Hab[id][HAB_S_W_ULTRA_LASER]) {
		new Float:vecOrigin[3];
		new Float:vecPoint[3];
		new Float:vecAim[3];
		new const iTrace = 0;
		new iTraceHit;
		new iEnt;
		new j = 0;

		entity_get_vector(id, EV_VEC_origin, vecOrigin);
		entity_get_vector(id, EV_VEC_view_ofs, vecAim);
		xs_vec_add(vecOrigin, vecAim, vecOrigin);

		fm_get_aim_origin(id, vecAim);

		xs_vec_sub(vecAim, vecOrigin, vecAim);
		xs_vec_mul_scalar(vecAim, 10.0, vecAim);
		xs_vec_add(vecOrigin, vecAim, vecAim);

		iEnt = id;
		
		while(engfunc(EngFunc_TraceLine, vecOrigin, vecAim, 0, iEnt, iTrace)) {
			++j;
			
			iTraceHit = get_tr2(iTrace, TR_pHit);
			
			if(j == 50) {
				break;
			}
			
			if(isPlayerValidAlive(iTraceHit)) {
				if(g_Zombie[iTraceHit]) {
					if(!g_SpecialMode[iTraceHit]) {
						ExecuteHamB(Ham_Killed, iTraceHit, id, 2);
						setAchievement(id, VOS_NO_PASAS);
					}
				}
			}
			
			iEnt = iTraceHit;
			get_tr2(iTrace, TR_vecEndPos, vecOrigin);
		}
		
		get_tr2(iTrace, TR_vecEndPos, vecPoint);
		
		free_tr2(iTrace);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMENTPOINT);
		write_short(id | 0x1000);
		engfunc(EngFunc_WriteCoord, vecPoint[0]);
		engfunc(EngFunc_WriteCoord, vecPoint[1]);
		engfunc(EngFunc_WriteCoord, vecPoint[2]);
		write_short(g_Sprite_Trail);
		write_byte(1);
		write_byte((1 / 100));
		write_byte(5);
		write_byte(10);
		write_byte(0);
		write_byte(255);
		write_byte(255);
		write_byte(0);
		write_byte(255);
		write_byte(25);
		message_end();
		
		engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecPoint, 0);
		write_byte(TE_DLIGHT);
		engfunc(EngFunc_WriteCoord, vecPoint[0]);
		engfunc(EngFunc_WriteCoord, vecPoint[1]);
		engfunc(EngFunc_WriteCoord, vecPoint[2]);
		write_byte(30);
		write_byte(255);
		write_byte(255);
		write_byte(0);
		write_byte(15);
		write_byte(50);
		message_end();
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_SPRITETRAIL);
		engfunc(EngFunc_WriteCoord, vecPoint[0]);
		engfunc(EngFunc_WriteCoord, vecPoint[1]);
		engfunc(EngFunc_WriteCoord, (vecPoint[2] - 20.0));
		engfunc(EngFunc_WriteCoord, vecPoint[0]);
		engfunc(EngFunc_WriteCoord, vecPoint[1]);
		engfunc(EngFunc_WriteCoord, (vecPoint[2] + 20.0));
		write_short(g_Sprite_ColorsBalls[4]);
		write_byte(200);
		write_byte(2);
		write_byte(5);
		write_byte(150);
		write_byte(255);
		message_end();

		return;
	}
	
	static iTarget;
	static iBody;
	static iAimOrigin[3];
	
	get_user_origin(id, iAimOrigin, 3);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT);
	write_short(id | 0x1000);
	write_coord(iAimOrigin[0]);
	write_coord(iAimOrigin[1]);
	write_coord(iAimOrigin[2]);
	write_short(g_Sprite_Trail);
	write_byte(1);
	write_byte((1 / 100));
	write_byte(5);
	write_byte(3);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(25);
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iAimOrigin);
	write_byte(TE_DLIGHT);
	write_coord(iAimOrigin[0]);
	write_coord(iAimOrigin[1]);
	write_coord(iAimOrigin[2]);
	write_byte(30);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(15);
	write_byte(50);
	message_end();
	
	get_user_aiming(id, iTarget, iBody);

	if(isPlayerValidAlive(iTarget) && g_Zombie[iTarget]) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_SPRITETRAIL);
		write_coord(iAimOrigin[0]);
		write_coord(iAimOrigin[1]);
		write_coord((iAimOrigin[2] - 20));
		write_coord(iAimOrigin[0]);
		write_coord(iAimOrigin[1]);
		write_coord((iAimOrigin[2] + 20));
		write_short(g_Sprite_ColorsBalls[6]);
		write_byte(200);
		write_byte(2);
		write_byte(5);
		write_byte(150);
		write_byte(255);
		message_end();
		
		if(g_SpecialMode[iTarget]) {
			clientPrint(id, print_center, "¡ES INMUNE!");
		} else {
			ExecuteHamB(Ham_Killed, iTarget, id, 2);
			setAchievement(id, VOS_NO_PASAS);
		}
	}
}

public setAnimation(const id, const animation) {
	entity_set_int(id, EV_INT_weaponanim, animation);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
	write_byte(animation);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

public bazookaFire(const id) {
	new iSysTime = get_arg_systime();
	new iRest = (g_Bazooka_LastUse[id] - iSysTime);

	if(iRest > 0) {
		clientPrintColor(id, _, "Debes esperar !g%s!y para volver a tirar la bazooka", getCooldDownTime(iRest));
		return;
	}

	--g_Bazooka[id];
	g_Bazooka_LastUse[id] = (iSysTime + 15);
	
	if(!g_Bazooka[id]) {
		rg_drop_item(id, "weapon_ak47");
	}

	entity_set_vector(id, EV_FLARE_COLOR, Float:{-10.5, 0.0, 0.0});
	
	setAnimation(id, 8);

	new Float:vecOrigin[3];
	new Float:vecAngles[3];
	new Float:vecVelocity[3];
	new Float:vecViewOffset[3];
	
	entity_get_vector(id, EV_VEC_view_ofs, vecViewOffset);
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	vecOrigin[0] += vecViewOffset[0];
	vecOrigin[1] += vecViewOffset[1];
	vecOrigin[2] += vecViewOffset[2];

	new iEnt = create_entity("info_target");
	
	if(!is_valid_ent(iEnt)) {
		return;
	}

	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_BAZOOKA);
	entity_set_model(iEnt, __MODEL_ROCKET);

	entity_set_size(iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
	entity_set_vector(iEnt, EV_VEC_mins, Float:{-1.0, -1.0, -1.0});
	entity_set_vector(iEnt, EV_VEC_maxs, Float:{1.0, 1.0, 1.0});

	entity_set_origin(iEnt, vecOrigin);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(iEnt, EV_ENT_owner, id);

	emitSound(iEnt, CHAN_WEAPON, __SOUND_NEMESIS_BAZOOKA[0]);

	velocity_by_aim(id, 1750, vecVelocity);
	entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

	vector_to_angle(vecVelocity, vecAngles);
	
	entity_set_vector(iEnt, EV_VEC_angles, vecAngles);

	entity_set_int(iEnt, EV_INT_renderfx, kRenderFxGlowShell);
	entity_set_vector(iEnt, EV_VEC_rendercolor, Float:{255.0, 0.0, 0.0});
	entity_set_int(iEnt, EV_INT_rendermode, kRenderNormal);
	entity_set_float(iEnt, EV_FL_renderamt, 4.0);

	entity_set_edict(iEnt, EV_ENT_FLARE, nemesisBazookaFlare(iEnt));
	entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_BRIGHTLIGHT));

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iEnt);
	write_short(g_Sprite_Trail);
	write_byte(50);
	write_byte(3);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(200);
	message_end();

	if(g_BazookaMode[id]) {
		new iArgs[1];
		iArgs[0] = iEnt;

		set_task(0.1, "task__FindAndFollow", 0, iArgs, sizeof(iArgs));
	}

	set_task(0.1, "task__SpriteBallRocket", iEnt);
}

public nemesisBazookaFlare(const rocket) {
	new iEnt = create_entity("env_sprite");

	if(!is_valid_ent(iEnt)) {
		return 0;
	}

	entity_set_model(iEnt, "sprites/animglow01.spr");
	entity_set_float(iEnt, EV_FL_scale, 0.4);
	entity_set_int(iEnt, EV_INT_spawnflags, SF_SPRITE_STARTON);
	entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW);
	entity_set_edict(iEnt, EV_ENT_aiment, rocket);
	entity_set_edict(iEnt, EV_ENT_owner, rocket);
	entity_set_float(iEnt, EV_FL_framerate, 25.0);

	entity_set_int(iEnt, EV_INT_renderfx, kRenderFxNone);
	entity_set_vector(iEnt, EV_VEC_rendercolor, Float:{255.0, 0.0, 0.0});
	entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAdd);
	entity_set_float(iEnt, EV_FL_renderamt, 255.0);

	DispatchSpawn(iEnt);
	return iEnt;
}

public task__FindAndFollow(const args[]) {
	static iEnt;
	static Float:flDistanceShort;
	static iFindPlayer;

	iEnt = args[0];
	flDistanceShort = 9999.0;
	iFindPlayer = 0;
	
	if(is_valid_ent(iEnt)) {
		static iPlayers[32];
		static iNum;
		static i;
		static iTarget;
		static iOwner;

		get_players(iPlayers, iNum);
		iOwner = entity_get_edict(iEnt, EV_ENT_owner);

		for(i = 0; i < iNum; ++i) {
			iTarget = iPlayers[i];

			if(g_IsAlive[iTarget] && (iTarget != iOwner) && (getUserTeam(iTarget) != getUserTeam(iOwner))) {
				static Float:vecOriginTarget[3];
				static Float:vecOriginEnt[3];
				static Float:flDistance;

				entity_get_vector(iTarget, EV_VEC_origin, vecOriginTarget);
				entity_get_vector(iEnt, EV_VEC_origin, vecOriginEnt);
				flDistance = vector_distance(vecOriginTarget, vecOriginEnt);
				
				if(flDistance <= flDistanceShort) {
					flDistanceShort = flDistance;
					iFindPlayer = iTarget;
				}
			}
		}
	}
	
	if(iFindPlayer > 0) {
		static iArgs[2];
		
		iArgs[0] = iEnt;
		iArgs[1] = iFindPlayer;
		
		set_task(0.1, "task__FollowAndCatch", iEnt, iArgs, sizeof(iArgs), "b");
	}
}

public task__FollowAndCatch(const args[], const ent) {
	static iEnt;
	static iTarget;

	iEnt = args[0];
	iTarget = args[1];
	
	if(g_IsAlive[iTarget] && is_valid_ent(iEnt)) {
		entitySetFollow(iEnt, iTarget, 1200.0);
		
		static Float:vecVelocity[3];
		static Float:vecAngles[3];
		
		entity_get_vector(iEnt, EV_VEC_velocity, vecVelocity);
		vector_to_angle(vecVelocity, vecAngles);
		entity_set_vector(iEnt, EV_VEC_angles, vecAngles);
	} else {
		remove_task(iEnt);

		static iArgs[1];
		iArgs[0] = iEnt;

		set_task(0.1, "task__FindAndFollow", 0, iArgs, sizeof(iArgs));
	}
}

public entitySetFollow(const ent, const target, const Float:speed) {
	if(!is_valid_ent(ent) || !is_valid_ent(target)) {
		return;
	}

	static Float:vecOriginEnt[3];
	static Float:vecOriginTarget[3];
	static Float:flDiff[3];
	static Float:flLength;
	static Float:vecVelocity[3];

	entity_get_vector(ent, EV_VEC_origin, vecOriginEnt);
	entity_get_vector(target, EV_VEC_origin, vecOriginTarget);

	flDiff[0] = (vecOriginTarget[0] - vecOriginEnt[0]);
	flDiff[1] = (vecOriginTarget[1] - vecOriginEnt[1]);
	flDiff[2] = (vecOriginTarget[2] - vecOriginEnt[2]);

	flLength = floatsqroot(floatpower(flDiff[0], 2.0) + floatpower(flDiff[1], 2.0) + floatpower(flDiff[2], 2.0));

	vecVelocity[0] = (flDiff[0] * (speed / flLength));
	vecVelocity[1] = (flDiff[1] * (speed / flLength));
	vecVelocity[2] = (flDiff[2] * (speed / flLength));

	entity_set_vector(ent, EV_VEC_velocity, vecVelocity);
}

public task__SpriteBallRocket(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}
	
	static Float:vecOriginFloat[3];
	static vecOriginInt[3];
	
	entity_get_vector(ent, EV_VEC_origin, vecOriginFloat);

	vecOriginInt[0] = floatround(vecOriginFloat[0]);
	vecOriginInt[1] = floatround(vecOriginFloat[1]);
	vecOriginInt[2] = floatround(vecOriginFloat[2]);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITETRAIL);
	write_coord(vecOriginInt[0]);
	write_coord(vecOriginInt[1]);
	write_coord((vecOriginInt[2] - 20));
	write_coord(vecOriginInt[0]);
	write_coord(vecOriginInt[1]);
	write_coord((vecOriginInt[2] + 20));
	write_short(g_Sprite_ColorsBalls[1]);
	write_byte(30);
	write_byte(2);
	write_byte(5);
	write_byte(random_num(5, 50));
	write_byte(40);
	message_end();
	
	set_task(0.2, "task__SpriteBallRocket", ent);
}

public ham__PlayerSpawnPost(const id) {
	if(!is_user_alive(id) || getUserTeam(id) == TEAM_UNASSIGNED) {
		return;
	}

	g_IsAlive[id] = _:is_user_alive(id);

	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_FREEZE);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_HEALTH_REGENERATION);
	remove_task(id + TASK_HEALTH_IMMUNITY);
	remove_task(id + TASK_HEALTH_REGENERATION_ROTATE);
	remove_task(id + TASK_GRUNT_GLOW);
	remove_task(id + TASK_CONVERT_ZOMBIE);
	remove_task(id + TASK_NVISION);
	remove_task(id + TASK_DRUG);
	remove_task(id + TASK_GRAB);
	remove_task(id + TASK_GRAB_PRETHINK);

	if(getUserAura(id)) {
		setUserAura(id);
	}

	randomSpawn(id);

	set_member(id, m_iHideHUD, HIDE_HUDS);

	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;

	if(g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_MEGA_ARMAGEDDON) {
		set_task(2.0, "task__RespawnCheckPlayer", id + TASK_SPAWN);

		if(g_Mode == MODE_GRUNT) {
			remove_task(id + TASK_GRUNT_AIMING);
			set_task(0.1, "task__ModeGruntAiming", id + TASK_GRUNT_AIMING);
		}
	} else {
		if(g_Mode == MODE_ARMAGEDDON && !g_ModeArmageddon_Init) {
			clientPrintColor(id, _, "No puedes revivir en la mitad de un Armageddon");

			user_silentkill(id);
			return;
		} else if(g_Mode == MODE_MEGA_ARMAGEDDON && !g_ModeMA_Reward[id]) {
			clientPrintColor(id, _, "No puedes revivir en la mitad de un Mega Armageddon");

			user_silentkill(id);
			return;
		}
	}

	if(g_Mode == MODE_ANNIHILATOR && g_ModeAnnihilator_Knife[id] == 0) {
		g_ModeAnnihilator_Knife[id] = -1000;
	}

	if(!g_NewRound && !g_EndRound) {
		if(g_Mode == MODE_SURVIVOR || g_Mode == MODE_WESKER || g_Mode == MODE_LEATHERFACE || g_Mode == MODE_TRIBAL || g_Mode == MODE_SNIPER) {
			g_RespawnAsZombie[id] = 1;
		} else if(g_Mode == MODE_MEGA_ARMAGEDDON || g_Mode == MODE_NEMESIS || g_Mode == MODE_CABEZON || g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_FLESHPOUND || g_Mode == MODE_GRUNT) {
			g_RespawnAsZombie[id] = 0;
		}
	}

	g_FirstSpawn[id] = 0;

	updatePlayerHat(id);

	if(g_RespawnAsZombie[id] && !g_NewRound) {
		resetVars(id, 0);

		zombieMe(id, .silent_mode=1);
		return;
	}

	g_AmmoPacks_BestRound[id] = 0;
	g_DeadTimes[id] = 0;
	g_DeadTimes_Reward[id] = 0;

	resetVars(id, 0);

	if(g_Mode == MODE_ANNIHILATOR && !g_ModeAnnihilator_Acerts[id]) {
		new iValue;
		TrieGetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], iValue);

		if(iValue) {
			g_ModeAnnihilator_Acerts[id] = iValue;
		} else {
			iValue = 0;
		}

		TrieSetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], (iValue + 1));
	} else if(g_Mode == MODE_ARMAGEDDON) {
		zombieMe(id, .nemesis=1);
		return;
	} else if(g_Mode == MODE_MEGA_ARMAGEDDON) {
		if(g_ModeMA_Reward[id] == 2) {
			zombieMe(id, .nemesis=1);
		} else {
			g_ModeMA_Reward[id] = 1;

			if(!g_Zombie[id]) {
				humanMe(id, .survivor=1);
			} else {
				zombieMe(id, .nemesis=1);
			}
		}

		return;
	}

	g_Achievement_SniperAwp[id] = 0;
	g_Achievement_SniperScout[id] = 0;
	g_Achievement_WeskerHead[id] = 0;
	g_Achievement_SniperHead[id] = 0;
	g_Achievement_WeskerNoDamage[id] = 0;
	g_Achievement_CabezonKills[id] = 0;
	g_Hat_Devil[id] = 0;
	g_Hat_Earth[id] = -999;

	set_task(0.19, "task__ClearWeapons", id + TASK_SPAWN);
	set_task(0.2, "task__SetWeapons", id + TASK_SPAWN);

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_FLESHPOUND) {
		switch(g_Mode) {
			case MODE_MEGA_GUNGAME: {
				new iHealthExtra = (100 + g_ModeMGG_Health[id]);

				if(iHealthExtra >= 200) {
					set_user_health(id, 200);
				} else {
					set_user_health(id, iHealthExtra);
				}
			} case MODE_FLESHPOUND: {
				set_user_health(id, 2500);
			} default: {
				set_user_health(id, 100);
			}
		}

		g_Speed[id] = 240.0;
		set_user_gravity(id, 1.0);
		set_user_armor(id, 0);

		if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME) {
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 4);

			g_ModeGG_Immunity[id] = 1;

			remove_task(id + TASK_IMMUNITY_GG);
			set_task(1.5, "task__RemoveImmunityGunGame", id + TASK_IMMUNITY_GG);
		}
	} else {
		set_user_health(id, humanHealth(id));
		g_Speed[id] = Float:humanSpeed(id);
		set_user_gravity(id, humanGravity(id));
		set_user_armor(id, humanArmor(id));
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

	copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Humano");

	if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
		if(!g_NewRound && getUserTeam(id) != TEAM_CT) {
			setUserTeam(id, TEAM_CT);
		}

		set_user_rendering(id);
	}

	setUserAllModels(id);
	turnOffFlashlight(id);

	new iWeaponEnt = getCurrentWeaponEnt(id);

	if(pev_valid(iWeaponEnt)) {
		replaceWeaponModels(id, cs_get_weapon_id(iWeaponEnt));
	}

	checkLastZombie();

	if(!g_NewRound && !g_EndRound && g_InGroup[id]) {
		finishComboHuman(id);
	}
}

public ham__PlayerKilledPre(const victim, const killer, const should_gib) {
	setUserAura(victim);

	remove_task(victim + TASK_HEALTH_REGENERATION);
	remove_task(victim + TASK_HEALTH_IMMUNITY);
	remove_task(victim + TASK_IMMUNITY);
	remove_task(victim + TASK_HEALTH_REGENERATION_ROTATE);
	remove_task(victim + TASK_GRUNT_AIMING);
	remove_task(victim + TASK_GRUNT_GLOW);
	remove_task(victim + TASK_IMMUNITY_GG);
	remove_task(victim + TASK_CONVERT_ZOMBIE);
	remove_task(victim + TASK_GRAB);
	remove_task(victim + TASK_GRAB_PRETHINK);

	if(g_Zombie[victim]) {
		finishComboZombie(victim);
	} else {
		finishComboHuman(victim);
	}

	g_IsAlive[victim] = 0;
	g_PlayerSolid[victim] = 0;
	g_PlayerRestore[victim] = 0;
	g_Immunity[victim] = 0;
	g_BurningDuration[victim] = 0;
	g_Frozen[victim] = 0;
	g_DrugBombCount[victim] = 0;
	g_DrugBombMove[victim] = 0;
	g_Invisibility[victim] = 0;

	if(g_Zombie[victim]) {
		remove_task(victim + TASK_MADNESS);
		remove_task(victim + TASK_BURNING_FLAME);
		remove_task(victim + TASK_FREEZE);
		remove_task(victim + TASK_DRUG);

		if(g_SpecialMode[victim]) {
			SetHamParamInteger(3, 2);
		}

		++g_DeadTimes[victim];
		++g_DeadTimes_Reward[victim];

		g_Achievement_InfectsWithMaxHP[victim] = 100;
	} else {
		if(g_Mode == MODE_TRIBAL && g_SpecialMode[victim] == MODE_TRIBAL) {
			new i;
			for(i = 1; i <= MaxClients; ++i) {
				if(g_SpecialMode[i] == MODE_TRIBAL) {
					remove_task(i + TASK_POWER_MODE);
				}
			}
		}
	}

	if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
		set_task(0.1, "task__SpectNVision", victim);
	}

	switch(g_Mode) {
		case MODE_MEGA_ARMAGEDDON: {
			if(g_Zombie[victim]) {
				g_ModeMA_AllZombies = 0;
			} else if(!g_Zombie[victim]) {
				g_ModeMA_AllHumans = 0;
			}
			
			if(victim != killer && isPlayerValidConnected(killer)) {
				++g_ModeMA_Kills[killer][victim];

				if(g_ModeMA_Kills[killer][victim] == 2) {
					if(g_Zombie[killer]) {
						setAchievement(killer, MA_KILL_AGAIN_H);
					} else {
						setAchievement(killer, MA_KILL_AGAIN_Z);
					}
				}

				if(g_Zombie[killer] && !g_Zombie[victim]) {
					if(g_SpecialMode[victim] == MODE_SURVIVOR) {
						++g_ModeMA_SurvivorKills[killer];

						if(g_ModeMA_SurvivorKills[killer] == 2) {
							setAchievement(killer, MA_KILL_S_x2);
						}
					} else {
						++g_ModeMA_HumanKills[killer];

						if(g_ModeMA_HumanKills[killer] == 5) {
							setAchievement(killer, MA_KILL_H_x5);
						}
					}
				} else if(!g_Zombie[killer] && g_Zombie[victim]) {
					if(g_SpecialMode[victim] == MODE_NEMESIS) {
						++g_ModeMA_NemesisKills[killer];

						if(g_ModeMA_NemesisKills[killer] == 2) {
							setAchievement(killer, MA_KILL_N_x2);
						}
					} else {
						++g_ModeMA_ZombieKills[killer];

						if(g_ModeMA_ZombieKills[killer] == 5) {
							setAchievement(killer, MA_KILL_Z_x5);
						}
					}
				}
			}

			if(g_SpecialMode[victim] == MODE_NEMESIS && !getZombies()) {
				endModeMegaArmageddon(1);
			} else if(g_SpecialMode[victim] == MODE_SURVIVOR && !getHumans()) {
				endModeMegaArmageddon(0);
			} else if(g_LastHuman[victim]) {
				checkModeMegaArmageddonTwo(1);
			} else if(g_LastZombie[victim]) {
				checkModeMegaArmageddonTwo(0);
			}
		} case MODE_GUNGAME: {
			if(victim != killer && isPlayerValidConnected(killer)) {
				++g_ModeGG_Kills[killer];

				if(get_pdata_int(victim, 75) == HIT_HEAD) {
					++g_ModeGG_Headshots[killer];

					if(g_ModeGG_Headshots[killer] >= 20) {
						setAchievement(killer, GG_HEADSHOTS_x20);

						if(g_ModeGG_Headshots[killer] >= 30) {
							setAchievement(killer, GG_HEADSHOTS_x30);

							if(g_ModeGG_Headshots[killer] >= 40) {
								setAchievement(killer, GG_HEADSHOTS_x40);
							}
						}
					}
				}

				if((g_ModeGG_Type == GUNGAME_CLASSIC && g_CurrentWeapon[killer] == CSW_KNIFE) || g_ModeGG_Kills[killer] >= ((g_ModeGG_Type == GUNGAME_SLOW) ? 3 : (g_ModeGG_Type == GUNGAME_FAST) ? 1 : 2)) {
					if(g_ModeGG_Type == GUNGAME_CLASSIC && g_CurrentWeapon[killer] == CSW_KNIFE) {
						g_ModeGG_Kills[victim] = 0;
						--g_ModeGG_Level[victim];

						if(g_ModeGG_Level[victim] <= 0) {
							g_ModeGG_Level[victim] = 1;
						}
					}

					g_ModeGG_Kills[killer] = 0;
					++g_ModeGG_Level[killer];

					if(g_ModeGG_Level[killer] != 27) {
						playSound(killer, __SOUND_ROUND_GUNGAME);

						strip_user_weapons(killer);

						if(g_ModeGG_Type == GUNGAME_CRAZY) {
							if(g_ModeGG_Level[killer] != 26) {
								g_ModeGGCrazy_ListLevel[killer][g_ModeGGCrazy_Level[killer]] = 1;

								new i;
								new iListLevels[26];
								new j = 0;

								for(i = 0; i < 26; ++i) {
									if(!g_ModeGGCrazy_ListLevel[killer][i]) {
										iListLevels[j] = i;
										++j;
									}
								}
								
								g_ModeGGCrazy_Level[killer] = iListLevels[random_num(0, (j - 1))];
							} else {
								g_ModeGGCrazy_Level[killer] = 26;
							}
						}

						gunGameGiveWeapons(killer);
						gunGameBestUsers();
					} else {
						g_ModeGG_End = 1;

						set_cvar_num("mp_round_infinite", 0);
						set_cvar_num("mp_freeforall", 0);

						clientPrintColor(0, _, "El ganador del !tGUNGAME!y es !g%s!y", g_PlayerName[killer]);

						++g_Stats[killer][STAT_GG_WINS];

						if(g_Stats[killer][STAT_GG_WINS] >= 1) {
							setAchievement(killer, GG_WIN_x1);

							if(g_Stats[killer][STAT_GG_WINS] >= 10) {
								setAchievement(killer, GG_WIN_x10);
							}
						}

						new iUnique = 1;
						new iByFar = 1;
						new i;

						for(i = 1; i <= MaxClients; ++i) {
							if(g_IsConnected[i] && g_AccountStatus[i] == STATUS_PLAYING) {
								if(g_ModeGG_Level[i] == 25 || g_ModeGG_Level[i] == 26) {
									setAchievement(i, GG_ALMOST_WIN);

									if(g_ModeGG_Level[i] == 26) {
										iUnique = 0;
									}

									iByFar = 0;
								}

								g_Points[i][P_HUMAN] += g_ModeGG_Level[i];
								g_Points[i][P_ZOMBIE] += g_ModeGG_Level[i];
								g_Points[i][P_MONEY] += g_ModeGG_Level[i];

								clientPrintColor(i, _, "Ganaste !g%d pH!y, !g%d pZ!y y !g%d SALDO!y", g_ModeGG_Level[i], g_ModeGG_Level[i], g_ModeGG_Level[i]);

								if(g_IsAlive[i]) {
									user_kill(i, 1);
								}
							}
						}

						if(iUnique) {
							setAchievement(killer, GG_WIN_UNIQUE);
						}

						if(iByFar) {
							setAchievement(killer, GG_WIN_BY_FAR);
						}

						if((get_arg_systime() - g_ModeGG_SysTime) < 120) {
							setAchievement(killer, GG_FAST_WIN);
						}

						if(g_AccountId[killer] == g_ModeGG_LastWinner) {
							setAchievement(killer, GG_WIN_CONSECUTIVE);
						}

						g_ModeGG_LastWinner = g_AccountId[killer];
					}
				}
			}

			return;
		} case MODE_MEGA_GUNGAME: {
			if(victim != killer && isPlayerValidConnected(killer)) {
				megaGunGameAddKill(killer);

				if(g_ModeMGG_Health[victim] < 200) {
					++g_ModeMGG_Health[victim];
				}
			}

			return;
		} case MODE_DRUNK: {
			if(getZombies() < 1) {
				new i;
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || g_Zombie[i]) {
						continue;
					}

					g_Points[i][P_HUMAN] += g_PointsMult[i];
					++g_Points[i][P_LEGACY];

					if(g_SpecialMode[i] != MODE_SNIPER) {
						clientPrintColor(i, _, "Ganaste !g%d pH!y y !g1 pL!y por ganar el modo !tDRUNK!y", g_PointsMult[i]);
					} else {
						++g_Points[i][P_LEGACY];
						clientPrintColor(i, _, "Ganaste !g%d pH!y y !g2 pL!y por ganar el modo !tDRUNK!y siendo !tSNIPER!y", g_PointsMult[i]);
					}
				}
			} else if(getHumans() < 1) {
				new i;
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || !g_Zombie[i]) {
						continue;
					}

					g_Points[i][P_ZOMBIE] += g_PointsMult[i];
					++g_Points[i][P_LEGACY];

					clientPrintColor(i, _, "Ganaste !g%d pZ!y y !g1 pL!y por ganar el modo !tDRUNK!y", g_PointsMult[i]);
				}
			}
		} case MODE_MEGA_DRUNK: {
			if(getZombies() < 1) {
				new i;
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || g_Zombie[i]) {
						continue;
					}

					g_Points[i][P_HUMAN] += g_PointsMult[i];
					g_Points[i][P_LEGACY] += g_PointsMult[i];
					g_Points[i][P_MONEY] += (g_PointsMult[i] * 2);

					clientPrintColor(i, _, "Ganaste !g%d pHL!y y !g%d SALDO!y por ganar el modo !tDRUNK!y", g_PointsMult[i], (g_PointsMult[i] * 2));
				}
			} else if(getHumans() < 1) {
				new i;
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || !g_Zombie[i]) {
						continue;
					}

					g_Points[i][P_HUMAN] += g_PointsMult[i];
					g_Points[i][P_LEGACY] += g_PointsMult[i];
					g_Points[i][P_MONEY] += (g_PointsMult[i] * 2);

					clientPrintColor(i, _, "Ganaste !g%d pZL!y y !g%d SALDO!y por ganar el modo !tDRUNK!y", g_PointsMult[i], (g_PointsMult[i] * 2));
				}
			}
		} case MODE_TRIBAL: {
			tribalModeKill(killer, victim);
		} case MODE_DUEL_FINAL: {
			if(victim != killer && isPlayerValidConnected(killer)) {
				++g_ModeDuelFinal_KillsTotal[killer];
				++g_ModeDuelFinal_Kills[killer];

				switch(g_ModeDuelFinal_Type) {
					case DF_TYPE_KNIFE: {
						++g_ModeDuelFinal_KillsKnife[killer];

						if(g_ModeDuelFinal_KillsKnife[killer] >= 5) {
							setAchievement(killer, ACUCHILLADOS);

							if(g_ModeDuelFinal_KillsKnife[killer] >= 10) {
								setAchievement(killer, AFISIONADO_EN_CUCHI);

								if(g_ModeDuelFinal_KillsKnife[killer] >= 15) {
									setAchievement(killer, ENTRA_CUCHI_SALEN_TRIPAS);
								}
							}
						}
					} case DF_TYPE_AWP: {
						++g_ModeDuelFinal_KillsAwp[killer];

						if(g_ModeDuelFinal_KillsAwp[killer] >= 5) {
							setAchievement(killer, TODO_UN_AWPER);

							if(g_ModeDuelFinal_KillsAwp[killer] >= 10) {
								setAchievement(killer, EXPERTO_EN_AWP);

								if(g_ModeDuelFinal_KillsAwp[killer] >= 15) {
									setAchievement(killer, PRO_AWP);
								}
							}
						}
					} case DF_TYPE_HE: {
						++g_ModeDuelFinal_KillsHE[killer];

						if(g_ModeDuelFinal_KillsHE[killer] >= 5) {
							setAchievement(killer, DETONADOS);

							if(g_ModeDuelFinal_KillsHE[killer] >= 10) {
								setAchievement(killer, BOMBAZO_PARA_TODOS);

								if(g_ModeDuelFinal_KillsHE[killer] >= 15) {
									setAchievement(killer, BOOM_EN_TODA_LA_CARA);
								}
							}
						}
					} case DF_TYPE_ONLY_HEAD: {
						++g_ModeDuelFinal_KillsOnlyHead[killer];

						if(g_ModeDuelFinal_KillsOnlyHead[killer] >= 5) {
							setAchievement(killer, SENTADO);

							if(g_ModeDuelFinal_KillsOnlyHead[killer] >= 10) {
								setAchievement(killer, PUM_BALAZO);

								if(g_ModeDuelFinal_KillsOnlyHead[killer] >= 15) {
									setAchievement(killer, THE_KILLER_OF_DK);
								}
							}
						}
					}
				}

				if(!g_ModeDuelFinal_First) {
					g_ModeDuelFinal_First = 1;
					setAchievement(victim, SOY_MUY_NOOB);
				}
			}

			if(getHumans() == 1) {
				++g_ModeDuelFinal;

				if(g_ModeDuelFinal == DF_QUARTER || g_ModeDuelFinal == DF_SEMIFINAL || g_ModeDuelFinal == DF_FINAL) {
					user_kill(killer, 1);
				} else if(g_ModeDuelFinal == DF_FINISH) {
					set_user_godmode(killer, 1);
				}

				remove_task(TASK_MODE_DUEL_FINAL);
				set_task(2.0, "task__ModeDuelFinal", TASK_MODE_DUEL_FINAL);
			}

			return;
		} case MODE_GRUNT: {
			if(getHumans() == 1) {
				new i;
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || g_SpecialMode[i]) {
						continue;
					}

					clientPrintColor(0, _, "!t%s!y ganó !g%d pH!y por ser el último humano vivo en el modo !tGRUNT!y", g_PlayerName[i], g_PointsMult[i]);

					g_Points[i][P_HUMAN] += g_PointsMult[i];
					break;
				}
			}
			
			return;
		}
	}

	if(victim == killer || !isPlayerValidConnected(killer)) {
		return;
	}

	new iReward = 0;

	if(!g_Zombie[killer]) {
		++g_Stats[killer][STAT_ZM_D];
		++g_Stats[victim][STAT_ZM_T];

		if(g_Stats[killer][STAT_ZM_D] >= 100) {
			setAchievement(killer, ZOMBIES_x100);

			if(g_Stats[killer][STAT_ZM_D] >= 500) {
				setAchievement(killer, ZOMBIES_x500);

				if(g_Stats[killer][STAT_ZM_D] >= 1000) {
					setAchievement(killer, ZOMBIES_x1000);

					if(g_Stats[killer][STAT_ZM_D] >= 2500) {
						setAchievement(killer, ZOMBIES_x2500);
						giveHat(killer, HAT_ANGEL);

						if(g_Stats[killer][STAT_ZM_D] >= 5000) {
							setAchievement(killer, ZOMBIES_x5000);

							if(g_Stats[killer][STAT_ZM_D] >= 10000) {
								setAchievement(killer, ZOMBIES_x10K);

								if(g_Stats[killer][STAT_ZM_D] >= 25000) {
									setAchievement(killer, ZOMBIES_x25K);

									if(g_Stats[killer][STAT_ZM_D] >= 50000) {
										setAchievement(killer, ZOMBIES_x50K);

										if(g_Stats[killer][STAT_ZM_D] >= 100000) {
											setAchievement(killer, ZOMBIES_x100K);

											if(g_Stats[killer][STAT_ZM_D] >= 500000) {
												setAchievement(killer, ZOMBIES_x500K);

												if(g_Stats[killer][STAT_ZM_D] >= 1000000) {
													setAchievement(killer, ZOMBIES_x1M);

													if(g_Stats[killer][STAT_ZM_D] >= 5000000) {
														setAchievement(killer, ZOMBIES_x5M);
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		if(should_gib == 1) { // Nos aseguramos de que no lo haya matado con una bomba de aniquilación (o muerte por explosión)
			iReward = getRewardInConversion(killer, 5);

			if(g_SpecialMode[killer]) {
				switch(g_SpecialMode[killer]) {
					case MODE_SNIPER: {
						if(g_Mode == MODE_SNIPER) {
							if(g_CurrentWeapon[killer] == CSW_AWP) {
								++g_Achievement_SniperAwp[killer];

								if(g_Achievement_SniperAwp[killer] >= 8) {
									setAchievement(killer, MI_AWP_ES_MEJOR);
								}
							} else {
								++g_Achievement_SniperScout[killer];

								if(g_Achievement_SniperScout[killer] >= 8) {
									setAchievement(killer, MI_SCOUT_ES_MEJOR);
								}
							}
						}
					}
				}
			} else {
				if(g_Mode == MODE_PLAGUE) {
					++g_PlagueZombieKill[killer];
				}

				++g_WeaponData[killer][g_CurrentWeapon[killer]][WEAPON_DATA_KILL_DONE];

				if(!g_NewRound) {
					saveInfoWeapons(killer, .stats=1);
				}
			}

			if(get_pdata_int(victim, 75) == HIT_HEAD) {
				iReward = getRewardInConversion(killer, 10);
				
				++g_Stats[killer][STAT_ZMHS_D];
				++g_Stats[victim][STAT_ZMHS_T];

				if(g_Stats[killer][STAT_ZMHS_D] >= 1000) {
					setAchievement(killer, LIDER_EN_CABEZAS);

					if(g_Stats[killer][STAT_ZMHS_D] >= 10000) {
						setAchievement(killer, AGUJEREANDO_CABEZAS);

						if(g_Stats[killer][STAT_ZMHS_D] >= 50000) {
							setAchievement(killer, MORTIFICANDO_ZOMBIES);

							if(g_Stats[killer][STAT_ZMHS_D] >= 100000) {
								setAchievement(killer, CABEZAS_ZOMBIES);
							}
						}
					}
				}

				if(g_Mode == MODE_WESKER && g_SpecialMode[killer] == MODE_WESKER) {
					++g_Achievement_WeskerHead[killer];

					if(g_Achievement_WeskerHead[killer] >= 10) {
						setAchievement(killer, RESIDENT_EVIL);
					}
				} else if(g_Mode == MODE_SNIPER && g_SpecialMode[killer] == MODE_SNIPER) {
					++g_Achievement_SniperHead[killer];

					if(g_Achievement_SniperHead[killer] >= 8) {
						setAchievement(killer, ZAS_EN_TODA_LA_BOCA);
					}
				}
			}

			if(!g_SpecialMode[killer] && g_CurrentWeapon[killer] == CSW_KNIFE) {
				if(get_pdata_int(victim, 75) == HIT_HEAD) {
					iReward = getRewardInConversion(killer, 25);
				} else {
					iReward = getRewardInConversion(killer, 10);
				}
				
				++g_Stats[killer][STAT_ZMK_D];
				++g_Stats[victim][STAT_ZMK_T];

				if((get_user_flags(victim) & ADMIN_LEVEL_E)) {
					setAchievement(killer, BAN_LOCAL);
				}

				setAchievement(killer, AFILANDO_MI_CUCHILLO);

				if(g_SpecialMode[victim] == MODE_NEMESIS) {
					setAchievement(killer, MI_CUCHILLO_ES_ROJO);
				}

				if(g_Stats[killer][STAT_ZMK_D] >= 30) {
					setAchievement(killer, ACUCHILLANDO);

					if(g_Stats[killer][STAT_ZMK_D] >= 50) {
						setAchievement(killer, ME_ENCANTAN_LAS_TRIPAS);

						if(g_Stats[killer][STAT_ZMK_D] >= 100) {
							setAchievement(killer, HUMMILACION);

							if(g_Stats[killer][STAT_ZMK_D] >= 150) {
								setAchievement(killer, CLAVO_QUE_TE_CLAVO_LA_SOMBRILLA);

								if(g_Stats[killer][STAT_ZMK_D] >= 200) {
									setAchievement(killer, ENTRA_CUCHILLO_SALEN_LAS_TRIPAS);

									if(g_Stats[killer][STAT_ZMK_D] >= 250) {
										setAchievement(killer, HUMILIATION_DEFEAT);

										if(g_Stats[killer][STAT_ZMK_D] >= 500) {
											setAchievement(killer, CUCHILLO_DE_COCINA);
											giveHat(killer, HAT_SASHA);	

											if(g_Stats[killer][STAT_ZMK_D] >= 1000) {
												setAchievement(killer, CUCHILLO_PARA_PIZZA);

												if(g_Stats[killer][STAT_ZMK_D] >= 5000) {
													setAchievement(killer, YOCUCHI);
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		new iRandomNum = random_num(1, 10);

		if(iRandomNum == 1 || iRandomNum == 4 || (g_HappyHour == 2 && (iRandomNum == 5 || iRandomNum == 10)) || get_pdata_int(victim, 75) == HIT_HEAD) {
			new Float:vecOrigin[3];
			new Float:vecEndOrigin[3];
			new Float:flFraction;

			entity_get_vector(victim, EV_VEC_origin, vecOrigin);
			getDropOrigin(victim, vecEndOrigin, 20);

			engfunc(EngFunc_TraceLine, vecOrigin, vecEndOrigin, IGNORE_MONSTERS, victim, 0);
			get_tr2(0, TR_flFraction, flFraction);

			if(flFraction == 1.0) {
				if(get_pdata_int(victim, 75) == HIT_HEAD) {
					dropHeadZombie(victim, 1);
				} else {
					dropHeadZombie(victim, 0);
				}
			}
		}
	} else {
		iReward = getRewardInConversion(killer, 50);

		++g_Stats[killer][STAT_HM_D];
		++g_Stats[victim][STAT_HM_T];

		if(g_SpecialMode[killer]) {
			switch(g_SpecialMode[killer]) {
				case MODE_NEMESIS: {
					if(g_Mode == MODE_SYNAPSIS) {
						++g_SynapsisNemesisKill[killer];
					}
				} case MODE_ANNIHILATOR: {
					if(g_Mode == MODE_ANNIHILATOR) {
						++g_ModeAnnihilator_Kills[killer];
						checkAnnihilatorReward(killer, g_ModeAnnihilator_Kills[killer], 0);

						if(g_CurrentWeapon[killer] == CSW_KNIFE) {
							++g_Achievement_AnnKnife[killer];
						} else if(g_CurrentWeapon[killer] == CSW_MAC10) {
							++g_Achievement_AnniMac10[killer];
						}

						if(g_ModeAnnihilator_Knife[victim] >= 0) {
							g_ModeAnnihilator_Knife[victim] -= 1000;
						}
					}
				} case MODE_FLESHPOUND: {
					if(g_Mode == MODE_FLESHPOUND) {
						if(g_LastHuman[victim] || !getTribals()) {
							if(!getTribals()) {
								new i;
								for(i = 1; i <= MaxClients; ++i) {
									if(g_IsAlive[i] && g_SpecialMode[i] != MODE_FLESHPOUND) {
										user_silentkill(i);
									}
								}
							}

							new iRewardXP = getRewardInConversion(killer, 75);
							new sRewardXP[16];

							g_Points[killer][P_HUMAN] += g_PointsMult[killer];
							g_Points[killer][P_ZOMBIE] += g_PointsMult[killer];

							addDot(iRewardXP, sRewardXP, charsmax(sRewardXP));
							clientPrintColor(0, _, "!t%s!y ganó !g%d pHZ!y y !g%s XP!y por ganar el modo !tFLESHPOUND!y", g_PlayerName[killer], g_PointsMult[killer], sRewardXP);
							
							addXP(killer, iRewardXP);

							if(!g_ModeFleshpound_Minute) {
								rewardModeFleshpound(killer);
							}
						}
					}
				}
			}
		} else {
			if(g_Mode == MODE_PLAGUE) {
				++g_PlagueHumanKill[killer];
			}
		}
	}

	++g_AmmoPacks[killer];

	if(g_Mode == MODE_INFECTION) {
		g_AmmoPacks[victim] += 5;
	}

	++g_AmmoPacksTotal[killer];
	++g_AmmoPacks_BestRound[killer];
	++g_AmmoPacks_BestMap[killer];
	addXP(killer, iReward);

	if(g_SpecialMode[victim]) {
		if(g_Mode != MODE_MEGA_SYNAPSIS && g_Mode != MODE_ANNIHILATOR && g_SpecialMode[victim] != MODE_ANNIHILATOR) {
			addPoints(victim, killer);
		}

		switch(g_SpecialMode[victim]) {
			case MODE_SURVIVOR: {
				++g_Stats[killer][STAT_S_M_KILL];

				if(g_Stats[killer][STAT_S_M_KILL] >= 100) {
					giveHat(killer, HAT_JACKOLANTERN);
				}
			} case MODE_WESKER: {
				++g_Stats[killer][STAT_W_M_KILL];

				if(!g_Achievement_WeskerNoDamage[victim]) {
					setAchievement(victim, DK_BUGUEADA);
				}

				g_Achievement_WeskerNoDamage[victim] = 0;
			} case MODE_LEATHERFACE: {
				++g_Stats[killer][STAT_L_M_KILL];
			} case MODE_TRIBAL: {
				++g_Stats[killer][STAT_T_M_KILL];
			} case MODE_SNIPER: {
				++g_Stats[killer][STAT_SN_M_KILL];
			} case MODE_NEMESIS: {
				++g_Stats[killer][STAT_NEM_M_KILL];

				if(g_Stats[killer][STAT_NEM_M_KILL] >= 100) {
					giveHat(killer, HAT_JAMACA);
				}
			} case MODE_CABEZON: {
				++g_Stats[killer][STAT_CAB_M_KILL];
			} case MODE_ANNIHILATOR: {
				++g_Stats[killer][STAT_ANN_M_KILL];

				g_Points[killer][P_HUMAN] += g_PointsMult[killer];
				g_Points[killer][P_LEGACY] += (g_PointsMult[killer] + 1);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pH!y y !g%d pL!y por matar un !tANIQUILADOR!y", g_PlayerName[killer], g_PointsMult[killer], (g_PointsMult[killer] + 1));
			} case MODE_FLESHPOUND: {
				++g_Stats[killer][STAT_FLESH_M_KILL];

				new iRewardXP = getRewardInConversion(killer, 75);
				new sRewardXP[16];

				g_Points[killer][P_HUMAN] += g_PointsMult[killer];
				g_Points[killer][P_ZOMBIE] += g_PointsMult[killer];

				addDot(iRewardXP, sRewardXP, charsmax(sRewardXP));
				clientPrintColor(0, _, "!t%s!y ganó !g%d pHZ!y y !g%s XP!y por matar al !tFLESHPOUND!y", g_PlayerName[killer], g_PointsMult[killer], sRewardXP);

				addXP(killer, iRewardXP);
			}
		}

		if(g_Stats[killer][STAT_S_M_KILL] && g_Stats[killer][STAT_W_M_KILL] && g_Stats[killer][STAT_L_M_KILL] && g_Stats[killer][STAT_T_M_KILL] && g_Stats[killer][STAT_SN_M_KILL] &&
		g_Stats[killer][STAT_NEM_M_KILL] && g_Stats[killer][STAT_CAB_M_KILL] && g_Stats[killer][STAT_ANN_M_KILL] && g_Stats[killer][STAT_FLESH_M_KILL]) {
			setAchievement(killer, QUE_SUERTE);
			setAchievementFirst(killer, PRIMERO_QUE_SUERTE);
		}
	}

	if(g_Mode != MODE_PLAGUE && g_Mode != MODE_SYNAPSIS && g_Mode != MODE_MEGA_SYNAPSIS && g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_MEGA_ARMAGEDDON && g_Mode != MODE_MEGA_DRUNK && g_Mode != MODE_TRIBAL && g_Mode != MODE_FLESHPOUND && g_SpecialMode[killer] && (g_LastHuman[victim] || g_LastZombie[victim])) {
		switch(g_Mode) {
			case MODE_L4D2: {
				new iHumans[MAX_PLAYERS + 1];
				new i;
				new j;

				j = 0;

				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i]) {
						continue;
					}

					if(g_SpecialMode[i] != MODE_L4D2) {
						continue;
					}

					iHumans[j] = i;
					++j;

					clientPrintColor(i, _, "Ganaste !g%d pH!y por ganar el modo !gL4D2!y", g_PointsMult[i]);
					g_Points[i][P_HUMAN] += g_PointsMult[i];
				}

				if(j == 4) {
					new iRewardPH = 2;
					new iRewardPL = 1;

					for(i = 0; i < j; ++i) {
						if(g_HappyHour == 2) {
							iRewardPH += 3;
							iRewardPL += 2;
						}

						clientPrintColor(iHumans[i], _, "Ganaste !g%d pH!y y !g%d pL!y extra porque todos los humanos sobrevivieron", iRewardPH, iRewardPL);

						g_Points[iHumans[i]][P_HUMAN] += iRewardPH;
						g_Points[iHumans[i]][P_LEGACY] += iRewardPL;
					}
				}
			} case MODE_SNIPER: {
				new i;
				new j = 0;
				new k = 0;
				new iSnipers[4] = {0, 0, 0, 0};

				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || g_SpecialMode[i] != MODE_SNIPER) {
						continue;
					}

					iSnipers[j] = i;

					g_Points[i][P_HUMAN] += g_PointsMult[i];
					clientPrintColor(i, _, "Ganaste !g%d pH!y por ganar el modo !tSNIPER!y", g_PointsMult[i]);

					++j;
				}

				g_PointsMult[0] = 0;
				clientPrintColor(0, _, "Los !tSNIPER!y ganaron !g%d !y/!g %d !y/!g %d !y/!g %d pH!y por sobrevivir la ronda", g_PointsMult[iSnipers[0]], g_PointsMult[iSnipers[1]], g_PointsMult[iSnipers[2]], g_PointsMult[iSnipers[3]]);

				k = 0;
				for(i = 0; i < j; ++i) {
					if(g_IsAlive[iSnipers[i]]) {
						setAchievement(iSnipers[i], L_FRANCOTIRADOR);
						++k;

						if(!g_Achievement_SniperNoDamage[iSnipers[i]]) {
							setAchievement(iSnipers[i], NO_TENGO_BALAS);
						}
					}

					g_Achievement_SniperNoDamage[iSnipers[i]] = 0;
				}

				switch(k) {
					case 1: {
						for(i = 0; i < j; ++i) {
							if(g_IsAlive[iSnipers[i]]) {
								setAchievement(iSnipers[i], EN_MEMORIA_A_ELLOS);
								break;
							}
						}
					} case 2: {
						new iAwp = 0;
						new iScout = 0;
						
						for(i = 0; i < j; ++i) {
							if(user_has_weapon(iSnipers[i], CSW_AWP)) {
								++iAwp;
							}
							
							if(user_has_weapon(iSnipers[i], CSW_SCOUT)) {
								++iScout;
							}
						}
						
						if(iAwp == 2) {
							setAchievement(iSnipers[0], SOBREVIVEN_LOS_DUROS);
							setAchievement(iSnipers[1], SOBREVIVEN_LOS_DUROS);
						} else if(iScout == 2) {
							setAchievement(iSnipers[0], NO_SOLO_LA_GANAN_LOS_DUROS);
							setAchievement(iSnipers[1], NO_SOLO_LA_GANAN_LOS_DUROS);
						}
					} case 4: {
						setAchievement(iSnipers[0], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[1], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[2], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[3], EL_MEJOR_EQUIPO);
					}
				}
			} case MODE_GRUNT: {
				new i;
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i]) {
						continue;
					}

					if(g_SpecialMode[i] == MODE_GRUNT) {
						clientPrintColor(0, _, "!t%s!y ganó !g%d pZ!y y !g1 pL!y por ganar el modo !tGRUNT!y", g_PlayerName[i], g_PointsMult[i]);

						g_Points[i][P_ZOMBIE] += g_PointsMult[i];
						++g_Points[i][P_LEGACY];
					}
				}
			} default: {
				new iUsersPlaying = getUsersPlaying();
				new iClass = -1;
				new iDifficultClass = -1;
				new iReward = g_PointsMult[killer];

				if(g_Mode == MODE_SURVIVOR) {
					switch(g_Difficult[killer][DIFFICULT_CLASS_SURVIVOR]) {
						case DIFFICULT_NORMAL: {
							setAchievement(killer, SURVIVOR_PRINCIPIANTE);
						} case DIFFICULT_HARD: {
							setAchievement(killer, SURVIVOR_AVANZADO);
						} case DIFFICULT_VERY_HARD: {
							setAchievement(killer, SURVIVOR_EXPERTO);
						} case DIFFICULT_EXPERT: {
							setAchievement(killer, SURVIVOR_PRO);
						}
					}

					iClass = P_HUMAN;
					iDifficultClass = DIFFICULT_CLASS_SURVIVOR;
				} else if(g_Mode == MODE_WESKER) {
					switch(g_Difficult[killer][DIFFICULT_CLASS_WESKER]) {
						case DIFFICULT_NORMAL: {
							setAchievement(killer, WESKER_PRINCIPIANTE);
						} case DIFFICULT_HARD: {
							setAchievement(killer, WESKER_AVANZADO);
						} case DIFFICULT_VERY_HARD: {
							setAchievement(killer, WESKER_EXPERTO);
						} case DIFFICULT_EXPERT: {
							setAchievement(killer, WESKER_PRO);
						}
					}

					iClass = P_HUMAN;
					iDifficultClass = DIFFICULT_CLASS_WESKER;

					if(iUsersPlaying >= 15) {
						setAchievement(killer, MI_DEAGLE_Y_YO);

						if(g_Health[killer] == g_MaxHealth[killer]) {
							setAchievement(killer, L_INTACTO);
						}

						if(g_WeskLaser[killer] >= 3) {
							setAchievement(killer, NO_ME_HACE_FALTA);
							giveHat(killer, HAT_HOOD);
						}
					}
				} else if(g_Mode == MODE_LEATHERFACE) {
					switch(g_Difficult[killer][DIFFICULT_CLASS_LEATHERFACE]) {
						case DIFFICULT_NORMAL: {
							setAchievement(killer, LEATHERFACE_PRINCIPIANTE);
						} case DIFFICULT_HARD: {
							setAchievement(killer, LEATHERFACE_AVANZADO);
						} case DIFFICULT_VERY_HARD: {
							setAchievement(killer, LEATHERFACE_EXPERTO);
						} case DIFFICULT_EXPERT: {
							setAchievement(killer, LEATHERFACE_PRO);
						}
					}

					iClass = P_HUMAN;
					iDifficultClass = DIFFICULT_CLASS_LEATHERFACE;
				} else if(g_Mode == MODE_NEMESIS) {
					switch(g_Difficult[killer][DIFFICULT_CLASS_NEMESIS]) {
						case DIFFICULT_NORMAL: {
							setAchievement(killer, NEMESIS_PRINCIPIANTE);
						} case DIFFICULT_HARD: {
							setAchievement(killer, NEMESIS_AVANZADO);
						} case DIFFICULT_VERY_HARD: {
							setAchievement(killer, NEMESIS_EXPERTO);
						} case DIFFICULT_EXPERT: {
							setAchievement(killer, NEMESIS_PRO);
						}
					}

					iClass = P_ZOMBIE;
					iDifficultClass = DIFFICULT_CLASS_NEMESIS;

					if(g_Bazooka[killer]) {
						setAchievement(killer, CRATER_SANGRIENTO);
					}
				} else if(g_Mode == MODE_CABEZON) {
					switch(g_Difficult[killer][DIFFICULT_CLASS_CABEZON]) {
						case DIFFICULT_NORMAL: {
							setAchievement(killer, CABEZON_PRINCIPIANTE);
						} case DIFFICULT_HARD: {
							setAchievement(killer, CABEZON_AVANZADO);
						} case DIFFICULT_VERY_HARD: {
							setAchievement(killer, CABEZON_EXPERTO);
						} case DIFFICULT_EXPERT: {
							setAchievement(killer, CABEZON_PRO);
						}
					}

					iClass = P_ZOMBIE;
					iDifficultClass = DIFFICULT_CLASS_CABEZON;
				} else if(g_Mode == MODE_ANNIHILATOR) {
					switch(g_Difficult[killer][DIFFICULT_CLASS_ANNIHILATOR]) {
						case DIFFICULT_NORMAL: {
							setAchievement(killer, ANNIHILATOR_PRINCIPIANTE);
						} case DIFFICULT_HARD: {
							setAchievement(killer, ANNIHILATOR_AVANZADO);
						} case DIFFICULT_VERY_HARD: {
							setAchievement(killer, ANNIHILATOR_EXPERTO);
						} case DIFFICULT_EXPERT: {
							setAchievement(killer, ANNIHILATOR_PRO);
						}
					}

					iClass = P_ZOMBIE;
					iDifficultClass = DIFFICULT_CLASS_ANNIHILATOR;

					setAchievement(killer, MI_CUCHILLA_Y_YO);
				}

				if(iDifficultClass != -1 && iClass != -1) {
					if(g_Difficult[killer][iDifficultClass] != DIFFICULT_NORMAL) {
						iReward += g_Difficult[killer][iDifficultClass];
					}

					g_Points[killer][iClass] += iReward;
					++g_Points[killer][P_LEGACY];

					clientPrintColor(0, killer, "!t%s!y ganó !g%d p%c!y y !g1 pL!y por ganar el modo !g%s!y en dificultad !t%s!y", g_PlayerName[killer], iReward, ((iClass == P_ZOMBIE) ? 'Z' : 'H'), g_PlayerClassName[killer], __DIFFICULTS[iDifficultClass][g_Difficult[killer][iDifficultClass]][difficultName]);
				} else if(iClass != -1) {
					g_Points[killer][iClass] += iReward;
					clientPrintColor(0, killer, "!t%s!y ganó !g%d p%c!y!y por ganar el modo !g%s!y", g_PlayerName[killer], iReward, ((iClass == P_ZOMBIE) ? 'Z' : 'H'), g_PlayerClassName[killer]);
				}
			}
		}
	}
}

public ham__PlayerKilledPost(const victim) {
	checkLastZombie();

	if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME) {
		set_task(random_float(0.7, 2.3), "task__RespawnPlayer", victim + TASK_SPAWN);
	} else {
		if(!g_ModeGG_End) {
			set_task(1.0, "task__RespawnPlayer", victim + TASK_SPAWN);
		}
	}
}

public ham__PlayerTakeDamagePre(const victim, const inflictor, const attacker, Float:damage, const bits_damage_type) {
	if(bits_damage_type & DMG_FALL) {
		return HAM_SUPERCEDE;
	}

	if(victim == attacker || !isPlayerValidConnected(attacker)) {
		return HAM_IGNORED;
	}

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		if(g_Mode == MODE_DUEL_FINAL) {
			if(g_ModeDuelFinal_Type == DF_TYPE_ONLY_HEAD && get_pdata_int(victim, 75) != HIT_HEAD) {
				return HAM_SUPERCEDE;
			}
		} else if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME) {
			if(g_ModeGG_Immunity[victim]) {
				return HAM_SUPERCEDE;
			}

			if(g_Mode == MODE_GUNGAME) {
				if((bits_damage_type & DMG_HEGRENADE) && !g_ModeGGCrazy_HeLevel[attacker]) {
					return HAM_SUPERCEDE;
				}

				if(g_ModeGG_Type == GUNGAME_ONLY_HEAD && get_pdata_int(victim, 75) != HIT_HEAD && __GUNGAME_WEAPONS_CSW[g_ModeGG_Level[attacker]] != CSW_HEGRENADE && __GUNGAME_WEAPONS_CSW[g_ModeGG_Level[attacker]] != 0) {
					return HAM_SUPERCEDE;
				}
			}

			g_ModeGG_Immunity[attacker] = 0;

			set_user_rendering(attacker);

			remove_task(attacker + TASK_IMMUNITY_GG);
		}

		return HAM_IGNORED;
	}

	if(g_NewRound || g_EndRound || g_ModeArmageddon_Init) {
		return HAM_SUPERCEDE;
	}

	if(g_Immunity[victim] || g_Frozen[attacker] || ((g_InBubble[victim] && !g_Immunity[attacker]) && (g_InBubble[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker])) || g_ConvertZombie[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_Zombie[attacker] == g_Zombie[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_SpecialMode[victim] == MODE_CABEZON) {
		if(get_pdata_int(victim, 75) != HIT_HEAD) {
			return HAM_SUPERCEDE;
		}

		++g_ModeCabezon_Head[attacker];
		++g_ModeCabezon_HeadTotal;
	}

	if(!g_Zombie[attacker]) {
		if(g_SpecialMode[victim] == MODE_ANNIHILATOR) {
			++g_ModeAnnihilator_Acerts[attacker];
			
			if(get_pdata_int(victim, 75) == HIT_HEAD) {
				++g_ModeAnnihilator_AcertsHS[attacker];
			}

			if(g_CurrentWeapon[attacker] == CSW_KNIFE) {
				++g_ModeAnnihilator_Acerts[attacker];

				if(g_ModeAnnihilator_Knife[attacker] >= 0) {
					++g_ModeAnnihilator_Knife[attacker];
				}
			}
		}

		if(get_pdata_int(victim, 75) == HIT_HEAD) {
			++g_Stats[attacker][STAT_HS_D];
			++g_Stats[victim][STAT_HS_T];

			if(g_Mode == MODE_SYNAPSIS) {
				++g_SynapsisHead[attacker];
			}
		}

		if(g_TypeWeapon[attacker] == 1 && !g_SpecialMode[attacker] && !g_SpecialMode[victim]) {
			if(g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL] >= 21) {
				if(random_num(1, 100) <= 1 && !g_BurningDuration[victim]) {
					burningPlayer(victim, attacker, 10);
				}
			}
		}

		if(__WEAPON_DAMAGE_DEFAULT[g_CurrentWeapon[attacker]] != -1.0) {
			damage = __WEAPON_DAMAGE_DEFAULT[g_CurrentWeapon[attacker]];

			if(get_pdata_int(victim, 75) == HIT_HEAD) {
				damage *= 2.5;
			}
		}

		if(g_TypeWeapon[attacker] == 1) {
			damage *= __PRIMARY_WEAPONS[g_WeaponPrimary_Current[attacker]][weaponDamageMult];
		} else if(g_TypeWeapon[attacker] == 0) {
			damage *= __SECONDARY_WEAPONS[g_WeaponSecondary_Current[attacker]][weaponDamageMult];
		} else {
			damage *= 1.0;
		}

		static iData;
		iData = 1;

		switch(g_SpecialMode[attacker]) {
			case MODE_SURVIVOR, MODE_L4D2: {
				damage *= 25.0;
				damage += (float(__HABS[HAB_S_S_DAMAGE][habValue]) * float(g_Hab[attacker][HAB_S_S_DAMAGE]));

				if(g_Mode == MODE_SURVIVOR && g_SpecialMode[attacker] == MODE_SURVIVOR && g_HabRotate[attacker][HAB_ROTATE_SURVIVOR_DAMEGOUS]) {
					damage += ((30.0 * damage) / 100.0);
				} else if(g_Mode == MODE_L4D2) {
					damage *= 2.0;
				}
			} case MODE_WESKER: {
				iData = ((g_Hab[attacker][HAB_S_W_COMBO]) ? 1 : 0);

				if(g_CurrentWeapon[attacker] == CSW_DEAGLE) {
					static iHealth;
					iHealth = g_Health[victim];

					iHealth *= 15;
					iHealth /= 100;

					damage = ((iHealth < 200) ? 200.0 : float(iHealth));
				}

				g_Achievement_WeskerNoDamage[attacker] = 1;
			} case MODE_LEATHERFACE: {
				iData = ((g_Hab[attacker][HAB_S_L_COMBO]) ? 1 : 0);

				if(g_CurrentWeapon[attacker] == CSW_KNIFE) {
					if(g_Hab[attacker][HAB_S_L_DAMAGE]) {
						damage *= ((entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 2000.0 : 2500.0);
					} else {
						damage *= ((entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 1000.0 : 1250.0);
					}
				}
			} case MODE_TRIBAL: {
				if(g_CurrentWeapon[attacker] != CSW_KNIFE) {
					damage *= 75.0;
				}

				damage = damage + ((damage * g_ModeTribal_Damage[attacker]) / 100);

				if(g_Mode == MODE_MEGA_DRUNK) {
					damage *= 5.0;
				}
			} case MODE_SNIPER: {
				if(g_CurrentWeapon[attacker] == CSW_SCOUT) {
					damage *= 150.0;
				} else if(g_CurrentWeapon[attacker] == CSW_AWP) {
					damage *= 1500.0;
				}

				if(g_Mode == MODE_MEGA_DRUNK) {
					damage *= 10.0;
				} else if(g_Mode == MODE_MEGA_DRUNK) {
					damage *= 20.0;
				}

				g_Achievement_SniperNoDamage[attacker] = 1;
			} default: {
				damage += humanDamage(attacker);

				if(g_Hab[attacker][HAB_L_VIGOR]) {
					damage += (((float(__HABS[HAB_L_VIGOR][habValue]) * float(g_Hab[attacker][HAB_L_VIGOR])) * damage) / 100.0);
				}

				if(g_ArtifactsEquiped[attacker][ARTIFACT_BRACELET_DAMAGE]) {
					damage += ((10.0 * damage) / 100.0);
				}

				if(g_CurrentWeapon[attacker] == CSW_KNIFE && g_HabRotate[attacker][HAB_ROTATE_SPARTAN]) {
					damage += ((150.0 * damage) / 100.0);
				}

				if(g_TypeWeapon[attacker] == 0 && g_HabRotate[attacker][HAB_ROTATE_SECUNDARIAS_UTILES]) {
					damage += ((75.0 * damage) / 100.0);
				}

				if(random_num(1, 100) <= g_CriticalChance[attacker]) {
					damage += (((float(g_WeaponSkills[attacker][g_CurrentWeapon[attacker]][WEAPON_SKILL_CRITICAL_PROBABILITY]) * 2) * damage) / 100.0);
				}

				if(g_ArtifactsEquiped[victim][ARTIFACT_NECKLASE_DAMAGE]) {
					damage -= ((damage * (2.0 * float(g_Artifact[victim][ARTIFACT_NECKLASE_DAMAGE]))) / 100.0);
				}

				if(get_pdata_int(victim, 75) == HIT_HEAD && g_HabRotate[victim][HAB_ROTATE_CABEZA_DURA]) {
					damage -= ((damage * 30.0) / 100.0);
				}

				if(g_Mode == MODE_INFECTION && g_Zombie[victim] && !g_SpecialMode[victim] && g_HabRotate[victim][HAB_ROTATE_BLINDAJE_ASESINO]) {
					damage -= ((damage * 10.0) / 100.0);
				}

				if(g_Mode == MODE_INFECTION && g_ModeInfection_Res) {
					damage -= ((damage * 10.0) / 100.0);
				}

				if(g_ReduceDamage[victim]) {
					damage /= 2.0;
				}

				if(g_Frozen[victim]) {
					if(g_Frozen[victim] == 2) {
						damage /= 2.0;
					} else {
						damage = 0.1;
					}
				}

				g_StatsDamage[attacker][0] += (damage / DIV_DAMAGE);
				g_StatsDamage[victim][1] += (damage / DIV_DAMAGE);

				if(g_Mode == MODE_SYNAPSIS) {
					g_SynapsisDamage[attacker] += floatround(damage);
				}
			}
		}

		SetHamParamFloat(4, damage);

		if(!g_SpecialMode[attacker]) {
			if(g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL] != 25) {
				g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_DAMAGE_DONE] += (damage / DIV_DAMAGE);

				if(__WEAPON_DAMAGE_NEED[g_CurrentWeapon[attacker]][g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL]] && g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_DAMAGE_DONE] >= __WEAPON_DAMAGE_NEED[g_CurrentWeapon[attacker]][g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL]]) {
					g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
					++g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL];
					++g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_POINTS];

					clientPrintColor(attacker, _, "Tu !g%s!y subió al !gnivel %d!y", __WEAPON_NAMES[g_CurrentWeapon[attacker]], g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL]);
					
					if(g_CurrentWeapon[attacker] == CSW_KNIFE && g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL] >= 15) {
						giveHat(attacker, HAT_SPARTAN);
					}

					checkAchievementsWeapons(attacker, g_CurrentWeapon[attacker]);
				}
			}
		}

		g_AmmoPacksDamage[attacker] += damage;
		while(g_AmmoPacksDamage[attacker] >= g_AmmoPacksDamageNeed[attacker]) {
			++g_AmmoPacks[attacker];
			++g_AmmoPacksTotal[attacker];
			++g_AmmoPacks_BestRound[attacker];
			++g_AmmoPacks_BestMap[attacker];

			g_AmmoPacksDamage[attacker] -= g_AmmoPacksDamageNeed[attacker];
		}

		addXP(attacker, floatround(damage / g_XPDamageNeed[attacker]));

		if(iData) {
			g_ComboDamage[attacker] += damage;
			g_Combo[attacker] = floatround((g_ComboDamage[attacker] / g_ComboDamageNeed[attacker]));

			showCurrentComboHuman(attacker, damage);
		}

		return HAM_IGNORED;
	}

	if(bits_damage_type & DMG_HEGRENADE) {
		return HAM_SUPERCEDE;
	}

	if(g_CurrentWeapon[attacker] == CSW_MAC10 && g_SpecialMode[attacker] == MODE_ANNIHILATOR) {
		ExecuteHamB(Ham_Killed, victim, attacker, 1);
		return HAM_IGNORED;
	} else if(g_CurrentWeapon[attacker] == CSW_KNIFE) {
		if(entity_get_int(attacker, EV_INT_bInDuck) || entity_get_int(attacker, EV_INT_flags) & FL_DUCKING) {
			static Float:vecAttackerOrigin[3];
			static Float:vecVictimOrigin[3];
			static Float:flDistance;

			entity_get_vector(attacker, EV_VEC_origin, vecAttackerOrigin);
			entity_get_vector(victim, EV_VEC_origin, vecVictimOrigin);
			flDistance = vector_distance(vecAttackerOrigin, vecVictimOrigin);

			if(flDistance < 0.0) {
				flDistance *= -1.0;
			}

			if(flDistance >= 55.0) {
				return HAM_SUPERCEDE;
			}
		}

		damage += zombieDamage(attacker);

		if(g_SpecialMode[attacker]) {
			switch(g_SpecialMode[attacker]) {
				case MODE_NEMESIS, MODE_FLESHPOUND: {
					damage += ((entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 100.0 : 325.0);

					if(g_Hab[attacker][HAB_S_NEM_DAMAGE]) {
						damage += (float(__HABS[HAB_S_NEM_DAMAGE][habValue]) * float(g_Hab[attacker][HAB_S_NEM_DAMAGE]));
					}
					
					SetHamParamFloat(4, damage);
				} case MODE_ANNIHILATOR: {
					ExecuteHamB(Ham_Killed, victim, attacker, 1);
				}
			}

			return HAM_IGNORED;
		}

		static iArmor;
		iArmor = get_user_armor(victim);

		if(iArmor > 0) {
			static iRealDamage;
			iRealDamage = (iArmor - floatround(damage));

			emitSound(victim, CHAN_BODY, __SOUND_ARMOR_HIT);

			if(iRealDamage > 0) {
				set_user_armor(victim, iRealDamage);

				g_Stats[attacker][STAT_AP_D] += iRealDamage;
				g_Stats[victim][STAT_AP_T] += iRealDamage;
			} else {
				cs_set_user_armor(victim, 0, CS_ARMOR_NONE);

				g_Stats[attacker][STAT_AP_D] += iArmor;
				g_Stats[victim][STAT_AP_T] += iArmor;
			}

			return HAM_SUPERCEDE;
		}

		if(g_Mode == MODE_PLAGUE || g_Mode == MODE_MEGA_ARMAGEDDON || g_Mode == MODE_DRUNK || g_Mode == MODE_MEGA_DRUNK || g_Mode == MODE_L4D2 || g_Mode == MODE_TRIBAL || g_Mode == MODE_SNIPER || g_Mode == MODE_FLESHPOUND || g_SpecialMode[attacker] || getHumans() == 1) {
			if(g_Mode == MODE_MEGA_DRUNK) {
				++g_ModeMegaDrunk_ZombieHits[attacker];
			} else if(g_Mode == MODE_L4D2) {
				++g_ModeL4D2_ZombieAcerts[attacker];
			}

			addXP(attacker, (random_num(25, 100) * getUserLevelTotal(victim)));

			if(getHumans() == 1) {
				static Float:flDamageRest;
				flDamageRest = (float(g_Health[victim]) - damage);

				if((g_Mode == MODE_INFECTION || g_Mode == MODE_PLAGUE) && g_HabRotate[victim][HAB_ROTATE_ULTIMAS_PALABRAS] && g_LastHuman[victim] && !g_UltimasPalabras[victim] && !g_Immunity[victim] && flDamageRest < 50.0) {
					g_Immunity[victim] = 1;
					g_UltimasPalabras[victim] = 1;

					remove_task(victim + TASK_IMMUNITY);
					set_task(5.1, "task__RemoveImmunity", victim + TASK_IMMUNITY);

					if(flDamageRest < 0.0) {
						damage = ((flDamageRest * -1.0) + 1.0);
					}
				}
			}

			SetHamParamFloat(4, damage);
			return HAM_IGNORED;
		}

		zombieMe(victim, attacker, .reward=1);
	}

	return HAM_SUPERCEDE;
}

public ham__PlayerTakeDamagePost(const victim) {
	if((g_Zombie[victim] && g_LastZombie[victim]) ||
	(g_Zombie[victim] && g_SpecialMode[victim] == MODE_FLESHPOUND && g_ModeFleshpound_Power[victim] == 2) ||
	(!g_Zombie[victim] && g_SpecialMode[victim])) {
		if(pev_valid(victim) != PDATA_SAFE) {
			return;
		}

		set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX);
	}
}

public ham__PlayerTraceAttackPre(const victim, const attacker, const Float:damage, const Float:direction[3], const trace_handle, const bits_damage_type) {
	if(victim == attacker || !isPlayerValidConnected(attacker)) {
		return HAM_IGNORED;
	}

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		if((g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME) && g_ModeGG_Immunity[victim]) {
			return HAM_SUPERCEDE;
		}

		return HAM_IGNORED;
	}

	if(g_NewRound || g_EndRound || g_ModeArmageddon_Init) {
		return HAM_SUPERCEDE;
	}

	if(g_Immunity[victim] || g_Frozen[attacker] || ((g_InBubble[victim] && !g_Immunity[attacker]) && (g_InBubble[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker])) || g_ConvertZombie[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_Zombie[attacker] == g_Zombie[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_Zombie[attacker] && g_CurrentWeapon[attacker] == CSW_KNIFE) {
		if(entity_get_int(attacker, EV_INT_bInDuck) || entity_get_int(attacker, EV_INT_flags) & FL_DUCKING) {
			static Float:vecAttackerOrigin[3];
			static Float:vecVictimOrigin[3];
			static Float:flDistance;

			entity_get_vector(attacker, EV_VEC_origin, vecAttackerOrigin);
			entity_get_vector(victim, EV_VEC_origin, vecVictimOrigin);

			flDistance = vector_distance(vecAttackerOrigin, vecVictimOrigin);

			if(flDistance < 0.0) {
				flDistance *= -1.0;
			}

			if(flDistance >= 55.0) {
				g_BlockSound[attacker] = 1;
				return HAM_SUPERCEDE;
			}
		}
	}

	return HAM_IGNORED;
}

public ham__PlayerResetMaxSpeedPost(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	new Float:flSpeed = 1.0;

	if(g_Frozen[id] || g_ModeMGG_Block) {
		flSpeed = 1.0;
	} else if(g_BurningDuration[id]) {
		if(g_Hab[id][HAB_Z_RESISTANCE_FIRE] >= 2) {
			flSpeed = 200.0;
		} else {
			flSpeed = 175.0;
		}
	} else {
		flSpeed = floatclamp(g_Speed[id], 1.0, 9999.9);
	}

	set_user_maxspeed(id, flSpeed);
}

public ham__TouchPlayerPost(const touched, const toucher) {
	if(!isPlayerValidAlive(touched) || !isPlayerValidAlive(toucher)) {
		return HAM_IGNORED;
	}

	if(!g_Zombie[touched] || !g_Zombie[toucher]) {
		return HAM_IGNORED;
	}

	if(g_SpecialMode[touched] || g_SpecialMode[toucher]) {
		return HAM_IGNORED;
	}

	if(g_Hab[touched][HAB_Z_RESISTANCE_FIRE] >= 3 || g_Hab[toucher][HAB_Z_RESISTANCE_FIRE] >= 3) {
		return HAM_IGNORED;
	}

	if((g_BurningDuration[touched] && g_BurningDuration[toucher]) || (!g_BurningDuration[touched] && !g_BurningDuration[toucher])) {
		return HAM_IGNORED;
	}

	static iInFire;
	static iNotFire;

	if(g_BurningDuration[touched] && !g_BurningDuration[toucher]) {
		iInFire = touched;
		iNotFire = toucher;
	} else if(!g_BurningDuration[touched] && g_BurningDuration[toucher]) {
		iInFire = toucher;
		iNotFire = touched;
	}

	g_BurningDuration[iNotFire] = g_BurningDuration[iInFire];

	static iArgs[1];
	iArgs[0] = g_BurningDurationOwner[iInFire];

	if(!task_exists(iNotFire + TASK_BURNING_FLAME)) {
		set_task(0.2, "task__BurningFlame", iNotFire + TASK_BURNING_FLAME, iArgs, sizeof(iArgs), "b");
	}

	return HAM_IGNORED;
}

public ham__ThinkGrenadePre(const ent) {
	if(!pev_valid(ent)) {
		return HAM_IGNORED;
	}

	static Float:flDmgTime;
	static Float:flGameTime;

	flDmgTime = entity_get_float(ent, EV_FL_dmgtime);
	flGameTime = get_gametime();

	if(flDmgTime > flGameTime) {
		return HAM_IGNORED;
	}

	switch(entity_get_int(ent, EV_NADE_TYPE)) {
		case NADE_TYPE_INFECTION: {
			infectionExplode(ent);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_FIRE: {
			fireExplode(ent);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_FROST: {
			frostExplode(ent, 1);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_FLARE: {
			static iDuration;
			iDuration = entity_get_int(ent, EV_FLARE_DURATION);

			if(iDuration > 0) {
				if(iDuration == 1) {
					remove_entity(ent);
					return HAM_SUPERCEDE;
				}

				flareLighting(ent, iDuration, 0);

				entity_set_int(ent, EV_FLARE_DURATION, --iDuration);
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 2.0));
			} else if((entity_get_int(ent, EV_INT_flags) & FL_ONGROUND) && get_speed(ent) < 10) {
				if(g_EndRound) {
					return HAM_SUPERCEDE;
				}

				emitSound(ent, CHAN_WEAPON, __SOUND_NADE_FLARE_EXPLO);

				entity_set_int(ent, EV_FLARE_DURATION, 30);
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 0.1));
			} else {
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 1.0));
			}
		} case NADE_TYPE_DRUG: {
			drugExplode(ent);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_SUPERNOVA: {
			frostExplode(ent, 2);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_BUBBLE: {
			static iDuration;
			iDuration = entity_get_int(ent, EV_FLARE_DURATION);

			if(iDuration > 0) {
				if(iDuration == 1) {
					static Float:vecOrigin[3];
					static iVictim;
					static j;
					static iPlayers[MAX_PLAYERS + 1];
					static i;

					entity_get_vector(ent, EV_VEC_origin, vecOrigin);
					iVictim = -1;
					j = 0;

					while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 125.0)) != 0) {
						if(isPlayerValidAlive(iVictim) && !g_Zombie[iVictim]) {
							iPlayers[j++] = iVictim;
						}
					}

					remove_entity(ent);

					for(i = 0; i < j; ++i) {
						g_InBubble[iPlayers[i]] = 0;
					}

					return HAM_SUPERCEDE;
				}
				
				if(!(iDuration % 20)) {
					flareLighting(ent, iDuration, 0);
				}

				bubbleExplode(ent);

				entity_set_int(ent, EV_FLARE_DURATION, --iDuration);
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 0.1));
			} else if((entity_get_int(ent, EV_INT_flags) & FL_ONGROUND) && get_speed(ent) < 10) {
				if(g_EndRound) {
					return FMRES_SUPERCEDE;
				}

				emitSound(ent, CHAN_WEAPON, __SOUND_NADE_BUBBLE_EXPLO);

				entity_set_model(ent, __MODEL_BUBBLE);

				entity_set_vector(ent, EV_VEC_angles, Float:{0.0, 0.0, 0.0});

				static Float:vecColor[3];
				entity_get_vector(ent, EV_FLARE_COLOR, vecColor);

				entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell);
				entity_set_vector(ent, EV_VEC_rendercolor, vecColor);
				entity_set_int(ent, EV_INT_rendermode, kRenderTransTexture);
				entity_set_float(ent, EV_FL_renderamt, 5.0);

				static iId;
				iId = entity_get_edict(ent, EV_ENT_owner);

				if(isPlayerValidConnected(iId)) {
					entity_set_int(ent, EV_FLARE_DURATION, (120 + (__HABS[HAB_E_DURATION_BUBBLE][habValue] * g_Hab[iId][HAB_E_DURATION_BUBBLE])));
				} else {
					entity_set_int(ent, EV_FLARE_DURATION, 120);
				}

				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 0.01));
			} else {
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 0.5));
			}
		} case NADE_TYPE_KILL: {
			killExplode(ent);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_PIPE: {
			if(get_entity_flags(ent) & FL_ONGROUND) {
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
			}

			static iDuration;
			iDuration = entity_get_int(ent, EV_FLARE_DURATION);

			if(iDuration > 0) {
				static Float:vecEntOrigin[3];
				static Float:vecOrigin[3];
				static Float:flDistance;
				static i;
				static Float:vecDirection[3];

				entity_get_vector(ent, EV_VEC_origin, vecEntOrigin);

				if(iDuration == 1) {
					static iId;
					iId = entity_get_edict(ent, EV_ENT_owner);

					if(!g_IsConnected[iId]) {
						iId = 0;
					}

					emitSound(ent, CHAN_WEAPON, __SOUND_NEMESIS_BAZOOKA[3]);

					engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
					write_byte(TE_DLIGHT);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
					write_byte(25);
					write_byte(255);
					write_byte(0);
					write_byte(255);
					write_byte(5);
					write_byte(5);
					message_end();

					engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
					write_byte(TE_EXPLOSION);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
					engfunc(EngFunc_WriteCoord, (vecEntOrigin[2] + 5.0));
					write_short(g_Sprite_FExplo);
					write_byte(50);
					write_byte(35);
					write_byte(0);
					message_end();
					
					for(i = 1; i <= MaxClients; ++i) {
						if(!g_IsAlive[i] || !g_Zombie[i] || g_SpecialMode[i] || g_Immunity[i]) {
							continue;
						}

						entity_get_vector(i, EV_VEC_origin, vecOrigin);
						flDistance = get_distance_f(vecEntOrigin, vecOrigin);
						
						if(flDistance >= 260.0) {
							continue;
						}

						if(!iId) {
							iId = i;
						}

						burningPlayer(i, iId, 50);

						xs_vec_sub(vecOrigin, vecEntOrigin, vecOrigin);
						xs_vec_normalize(vecOrigin, vecOrigin);
						xs_vec_mul_scalar(vecOrigin, ((flDistance - 260.0) * -60), vecOrigin);

						entity_set_vector(i, EV_VEC_velocity, vecOrigin);
					}

					remove_entity(ent);
					return HAM_SUPERCEDE;
				}

				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
				write_byte(TE_DLIGHT);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
				write_byte(25);
				write_byte(255);
				write_byte(0);
				write_byte(255);
				write_byte(2);
				write_byte(0);
				message_end();

				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || !g_Zombie[i] || g_SpecialMode[i] || g_Immunity[i]) {
						continue;
					}

					entity_get_vector(i, EV_VEC_origin, vecOrigin);
					flDistance = get_distance_f(vecEntOrigin, vecOrigin);

					if(flDistance >= 260.0) {
						continue;
					}

					xs_vec_sub(vecOrigin, vecEntOrigin, vecDirection);
					xs_vec_mul_scalar(vecDirection, -5.0, vecDirection);

					entity_set_vector(i, EV_VEC_velocity, vecDirection);
				}

				entity_set_int(ent, EV_FLARE_DURATION, --iDuration);
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 0.1);
			} else {
				emitSound(ent, CHAN_WEAPON, __SOUND_NADE_PIPE_BEEP[random_num(0, charsmax(__SOUND_NADE_PIPE_BEEP))]);

				entity_set_int(ent, EV_FLARE_DURATION, 72);
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 0.1);
			}
		} case NADE_TYPE_ANTIDOTE: {
			antidoteExplode(ent);
			return HAM_SUPERCEDE;
		}
	}

	return HAM_IGNORED;
}

public ham__PlayerPreThinkPre(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	if(g_Frozen[id]) {
		set_user_velocity(id, Float:{0.0, 0.0, 0.0});
		return;
	}

	if(g_Zombie[id]) {
		entity_set_int(id, EV_NADE_TYPE, STEPTIME_SILENT);
	}

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT) {
		return;
	}

	static iLastThink;
	static i;

	if(iLastThink > id) {
		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				g_PlayerSolid[i] = 0;
				continue;
			}

			g_PlayerTeam[i] = getUserTeam(i);
			g_PlayerSolid[i] = ((entity_get_int(i, EV_INT_solid) == SOLID_SLIDEBOX) ? 1 : 0);
		}
	}

	iLastThink = id;

	if(g_PlayerSolid[id]) {
		for(i = 1; i <= MaxClients; ++i) {
			if(!g_PlayerSolid[i] || id == i) {
				continue;
			}

			if((g_NewRound || g_EndRound) || (g_PlayerTeam[i] == TEAM_CT && g_PlayerTeam[id] == TEAM_CT)) {
				entity_set_int(i, EV_INT_solid, SOLID_NOT);
				g_PlayerRestore[i] = 1;
			}
		}
	}
}

public ham__PlayerPostThinkPre(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT) {
		return;
	}

	static i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_PlayerRestore[i]) {
			entity_set_int(i, EV_INT_solid, SOLID_SLIDEBOX);
			g_PlayerRestore[i] = 0;
		}
	}
}

public ham__WeaponPrimaryAttackPost(const weapon_ent) {
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		return HAM_IGNORED;
	}

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isPlayerValidAlive(iId) || (g_Zombie[iId] && g_SpecialMode[iId] != MODE_FLESHPOUND)) {
		return HAM_IGNORED;
	}

	switch(g_SpecialMode[iId]) {
		case MODE_SURVIVOR: {
			if(g_CurrentWeapon[iId] == CSW_KNIFE || !g_Hab[iId][HAB_S_S_SPEED_WEAPON]) {
				return HAM_IGNORED;
			}

			// MP5 = 0.07
			// M249 = 0.06
			// M4A1 = 0.05

			static Float:flWeaponSpeedBase;
			static Float:flWeaponSpeedMult;
			static Float:flSpeed;

			switch(g_Hab[iId][HAB_S_S_WEAPON]) {
				case 0: {
					flWeaponSpeedBase = 0.075;
					flWeaponSpeedMult = 0.0075;
				} case 1: {
					flWeaponSpeedBase = 0.0625;
					flWeaponSpeedMult = 0.00625;
				} case 2: {
					flWeaponSpeedBase = 0.045;
					flWeaponSpeedMult = 0.0045;
				}
			}

			flSpeed = (flWeaponSpeedBase - (g_Hab[iId][HAB_S_S_SPEED_WEAPON] * flWeaponSpeedMult));
			
			set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, flSpeed);
			set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, flSpeed);
			set_member(weapon_ent, m_Weapon_flTimeWeaponIdle, flSpeed);
		} case MODE_LEATHERFACE: {
			if(g_CurrentWeapon[iId] != CSW_KNIFE) {
				return HAM_IGNORED;
			}

			static Float:flSpeed;
			static Float:vecPunchangle[3];

			flSpeed = 0.05;
			vecPunchangle[0] = -4.0;

			set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, flSpeed);
			set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, flSpeed);
			set_member(weapon_ent, m_Weapon_flTimeWeaponIdle, flSpeed);

			entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
		} case MODE_SNIPER: {
			if(g_SniperPower[iId] == 1) {
				static Float:flSpeed;
				static Float:vecPunchangle[3];

				flSpeed = ((g_CurrentWeapon[iId] == CSW_SCOUT) ? 0.05 : 0.4);
				vecPunchangle[0] = ((g_CurrentWeapon[iId] == CSW_SCOUT) ? -5.5 : 0.0);

				set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, flSpeed);
				set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, flSpeed);
				set_member(weapon_ent, m_Weapon_flTimeWeaponIdle, flSpeed);

				entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
			} else if(g_CurrentWeapon[iId] == CSW_SCOUT) {
				static Float:flSpeed;
				static Float:vecPunchangle[3];

				flSpeed = 0.1;
				vecPunchangle[0] = -5.5;

				set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, flSpeed);
				set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, flSpeed);
				set_member(weapon_ent, m_Weapon_flTimeWeaponIdle, flSpeed);

				entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
			}
		} case MODE_FLESHPOUND: {
			if(g_CurrentWeapon[iId] != CSW_KNIFE) {
				return HAM_IGNORED;
			}

			static Float:flSpeed;
			flSpeed = 0.08;

			set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, flSpeed);
			set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, flSpeed);
			set_member(weapon_ent, m_Weapon_flTimeWeaponIdle, flSpeed);
		} default: {
			static iWeaponId;
			iWeaponId = g_CurrentWeapon[iId];

			if(iWeaponId == CSW_KNIFE && g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) {
				static Float:vecSpeed[3];

				vecSpeed[0] = get_member(weapon_ent, m_Weapon_flNextPrimaryAttack);
				vecSpeed[1] = get_member(weapon_ent, m_Weapon_flNextSecondaryAttack);
				vecSpeed[2] = get_member(weapon_ent, m_Weapon_flTimeWeaponIdle);

				vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 7.5))) / 100.0);
				vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 7.5))) / 100.0);
				vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 7.5))) / 100.0);

				set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, vecSpeed[0]);
				set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, vecSpeed[1]);
				set_member(weapon_ent, m_Weapon_flTimeWeaponIdle, vecSpeed[2]);
			} else if(cs_get_weapon_ammo(weapon_ent)) {
				static iNoRecoil;
				iNoRecoil = 0;

				if(g_PrecisionPerfect[iId]) {
					iNoRecoil = 1;

					static Float:vecPunchangle[3];
					vecPunchangle[0] = 0.0;

					entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
				}

				if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED] || (!iNoRecoil && g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL])) {
					static Float:vecSpeed[3];
					static Float:vecRecoil[3];

					if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) {
						vecSpeed[0] = get_member(weapon_ent, m_Weapon_flNextPrimaryAttack);
						vecSpeed[1] = get_member(weapon_ent, m_Weapon_flNextSecondaryAttack);
						vecSpeed[2] = get_member(weapon_ent, m_Weapon_flTimeWeaponIdle);

						if((1<<iWeaponId) & WEAPONS_HEAVY_BIT_SUM) {
							vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 15.0))) / 100.0);
							vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 15.0))) / 100.0);
							vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 15.0))) / 100.0);
						} else {
							if((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM) {
								vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 5.0))) / 100.0);
								vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 5.0))) / 100.0);
								vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 5.0))) / 100.0);
							} else {
								vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 10.0))) / 100.0);
								vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 10.0))) / 100.0);
								vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 10.0))) / 100.0);
							}
						}

						set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, vecSpeed[0]);
						set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, vecSpeed[1]);
						set_member(weapon_ent, m_Weapon_flTimeWeaponIdle, vecSpeed[2]);
					}

					if(((1<<iWeaponId) & WEAPONS_HEAVY_BIT_SUM && g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED] > 3) || (!iNoRecoil && g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL])) {
						if((1<<iWeaponId) & WEAPONS_HEAVY_BIT_SUM && g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED] > 3) {
							vecRecoil[0] = 0.0;
							entity_set_vector(iId, EV_VEC_punchangle, vecRecoil);
						} else {
							entity_get_vector(iId, EV_VEC_punchangle, vecRecoil);

							vecRecoil[0] = vecRecoil[0] - (((vecRecoil[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL]) * 6.0))) / 100.0);
							vecRecoil[1] = vecRecoil[1] - (((vecRecoil[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL]) * 6.0))) / 100.0);
							vecRecoil[2] = vecRecoil[2] - (((vecRecoil[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL]) * 6.0))) / 100.0);

							entity_set_vector(iId, EV_VEC_punchangle, vecRecoil);
						}
					}

					if(g_WeaponData[iId][iWeaponId][WEAPON_DATA_LEVEL] >= 15 && ((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM)) {
						g_WeaponSecondaryAutofire[iId] = 1;
					}
				}
			}
		}
	}

	return HAM_IGNORED;
}

public ham__WeaponSecondaryAttackPost(const weapon_ent) {
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		return HAM_IGNORED;
	}

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isPlayerValidAlive(iId) || g_Zombie[iId]) {
		return HAM_IGNORED;
	}

	if(g_SpecialMode[iId]) {
		switch(g_SpecialMode[iId]) {
			case MODE_LEATHERFACE: {
				if(g_CurrentWeapon[iId] != CSW_KNIFE) {
					return HAM_IGNORED;
				}

				static Float:flSpeed;
				static Float:vecPunchangle[3];

				flSpeed = 0.3;
				vecPunchangle[0] = -8.5;

				set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, flSpeed, OFFSET_LINUX_WEAPONS);

				entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
			}
		}
	}

	return HAM_IGNORED;
}

public ham__ItemAttachToPlayerPre(const weapon_ent, const id) {
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		return;
	}

	static iWeaponId;
	iWeaponId = getWeaponId(weapon_ent);

	if(g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_BULLETS]) {
		if(get_pdata_int(weapon_ent, OFFSET_KNOWN, OFFSET_LINUX_WEAPONS)) {
			return;
		}

		static iExtraClip;
		iExtraClip = (2 * g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_BULLETS]);

		set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (__DEFAULT_MAX_CLIP[iWeaponId] + iExtraClip), OFFSET_LINUX_WEAPONS);
	}
}

public ham__WeaponReloadPost(const weapon_ent) {
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		return;
	}

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isPlayerValidAlive(iId) || g_Zombie[iId] || g_SpecialMode[iId]) {
		return;
	}

	static iWeaponId;
	iWeaponId = getWeaponId(weapon_ent);

	if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RELOAD_SPEED]) {
		static iReload;
		iReload = get_pdata_int(weapon_ent, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS);

		if(iReload) {
			static Float:flNextAttack;
			flNextAttack = get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX);

			if(flNextAttack <= 0.0) {
				return;
			}

			static Float:flSpeed;
			flSpeed = (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RELOAD_SPEED]) * 0.1);

			set_pdata_float(iId, OFFSET_NEXT_ATTACK, (flNextAttack - (flNextAttack * flSpeed)), OFFSET_LINUX);
		}
	}
}

public ham__ItemPostFramePre(const weapon_ent) {
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		return;
	}

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isPlayerValidAlive(iId) || g_Zombie[iId] || g_SpecialMode[iId]) {
		return;
	}

	static iWeaponId;
	iWeaponId = getWeaponId(weapon_ent);

	if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_BULLETS]) {
		static iMaxClip;
		static iReload;
		static Float:fNextAttack;
		static iAmmoType;
		static iBPAmmo;
		static iClip;
		static iButton;

		iMaxClip = (__DEFAULT_MAX_CLIP[iWeaponId] + (g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_BULLETS] * 2));
		iReload = get_pdata_int(weapon_ent, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS);
		fNextAttack = get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX);
		iAmmoType = (OFFSET_AMMO_PLAYER_SLOT0 + get_pdata_int(weapon_ent, OFFSET_PRIMARY_AMMO_TYPE, OFFSET_LINUX_WEAPONS));
		iBPAmmo = get_pdata_int(iId, iAmmoType, OFFSET_LINUX);
		iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
		iButton = entity_get_int(iId, EV_INT_button);

		if(iReload && fNextAttack <= 0.0) {
			static i;
			i = min((iMaxClip - iClip), iBPAmmo);

			set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (iClip + i), OFFSET_LINUX_WEAPONS);
			set_pdata_int(iId, iAmmoType, (iBPAmmo - i), OFFSET_LINUX);
			set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);

			iReload = 0;
		}

		if((iButton & IN_ATTACK && get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0) || (iButton & IN_ATTACK2 && get_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0)) {
			return;
		}

		if((iButton & IN_RELOAD) && !iReload) {
			if(iClip >= iMaxClip) {
				entity_set_int(iId, EV_INT_button, (iButton & ~IN_RELOAD));

				if(((1<<iWeaponId) & WEAPONS_SILENT_BIT_SUM) && !get_pdata_int(weapon_ent, OFFSET_SILENT, OFFSET_LINUX_WEAPONS)) {
					setAnimation(iId, ((iWeaponId == CSW_USP) ? 8 : 7));
				} else {
					setAnimation(iId, 0);
				}
			} else if(iClip == __DEFAULT_MAX_CLIP[iWeaponId]) {
				if(iBPAmmo) {
					set_pdata_float(iId, OFFSET_NEXT_ATTACK, __DEFAULT_DELAY[iWeaponId], OFFSET_LINUX);

					if(((1<<iWeaponId) & WEAPONS_SILENT_BIT_SUM) && get_pdata_int(weapon_ent, OFFSET_SILENT, OFFSET_LINUX_WEAPONS)) {
						setAnimation(iId, ((iWeaponId == CSW_USP) ? 5 : 4));
					} else {
						setAnimation(iId, __DEFAULT_ANIMS[iWeaponId]);
					}

					set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 1, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, (__DEFAULT_DELAY[iWeaponId] + 0.5), OFFSET_LINUX_WEAPONS);
				}
			}
		}
	}
}

public ham__ShotgunPostFramePre(const weapon_ent) {
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		return;
	}
	
	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isPlayerValidAlive(iId) || g_Zombie[iId] || g_SpecialMode[iId]) {
		return;
	}

	static iWeaponId;
	iWeaponId = getWeaponId(weapon_ent);

	if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_BULLETS]) {
		static iBPAmmo;
		static iClip;
		static iMaxClip;
		static iButton;

		iBPAmmo = get_pdata_int(iId, OFFSET_M3_AMMO, OFFSET_LINUX);
		iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
		iMaxClip = (__DEFAULT_MAX_CLIP[iWeaponId] + (g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_BULLETS] * 2));
		iButton = entity_get_int(iId, EV_INT_button);

		if(get_pdata_int(weapon_ent, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS) && get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX) <= 0.0) {
			static i;
			i = min((iMaxClip - iClip), iBPAmmo);

			set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (iClip + i), OFFSET_LINUX_WEAPONS);
			set_pdata_int(iId, OFFSET_M3_AMMO, (iBPAmmo - i), OFFSET_LINUX);
			set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);

			return;
		}

		if(iButton & IN_ATTACK && get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0) {
			return;
		}

		if(iButton & IN_RELOAD) {
			if(iClip >= iMaxClip) {
				entity_set_int(iId, EV_INT_button, (iButton & ~IN_RELOAD));
				set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, 0.5, OFFSET_LINUX_WEAPONS);
			} else if(iClip == __DEFAULT_MAX_CLIP[iWeaponId] && iBPAmmo) {
				shotgunReload(weapon_ent, iWeaponId, iMaxClip, iClip, iBPAmmo, iId);
			}
		}
	}
}

public ham__ShotgunWeaponIdlePre(const weapon_ent) {
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL) {
		return;
	}
	
	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isPlayerValidAlive(iId) || g_Zombie[iId] || g_SpecialMode[iId]) {
		return;
	}

	static iWeaponId;
	iWeaponId = getWeaponId(weapon_ent);

	if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_BULLETS]) {
		if(get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS) > 0.0) {
			return;
		}

		static iMaxClip;
		static iClip;
		static iSpecialReload;

		iMaxClip = (__DEFAULT_MAX_CLIP[iWeaponId] + (g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_BULLETS] * 2));
		iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
		iSpecialReload = get_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS);

		if(!iClip && !iSpecialReload) {
			return;
		}

		if(iSpecialReload) {
			static iBPAmmo;
			static iDefaultMaxClip;

			iBPAmmo = get_pdata_int(iId, OFFSET_M3_AMMO, OFFSET_LINUX);
			iDefaultMaxClip = __DEFAULT_MAX_CLIP[iWeaponId];

			if(iClip < iMaxClip && iClip == iDefaultMaxClip && iBPAmmo) {
				shotgunReload(weapon_ent, iWeaponId, iMaxClip, iClip, iBPAmmo, iId);
				return;
			} else if(iClip == iMaxClip && iClip != iDefaultMaxClip) {
				setAnimation(iId, 4);

				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 0, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 1.5, OFFSET_LINUX_WEAPONS);
			}
		}
	}
}

public shotgunReload(const weapon_ent, const weapon, const max_clip, const clip, const bp_ammo, const id) {
	if(g_WeaponSkills[id][weapon][WEAPON_SKILL_BULLETS]) {
		if(bp_ammo <= 0 || clip == max_clip) {
			return;
		}

		if(get_pdata_int(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) > 0.0) {
			return;
		}

		switch(get_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS)) {
			case 0: {
				setAnimation(id, 5);

				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
				set_pdata_float(id, OFFSET_NEXT_ATTACK, 0.55, OFFSET_LINUX);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 0.55, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);

				return;
			} case 1: {
				if(get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS) > 0.0) {
					return;
				}

				setAnimation(id, 3);

				emitSound(id, CHAN_ITEM, (random_num(0, 1)) ? "weapons/reload1.wav" : "weapons/reload3.wav", .pitch=(85 + random_num(0, 0x1f)));

				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 2, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, (weapon == CSW_XM1014) ? 0.3 : 0.45, OFFSET_LINUX_WEAPONS);
			} default: {
				set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (clip + 1), OFFSET_LINUX_WEAPONS);
				set_pdata_int(id, OFFSET_M3_AMMO, (bp_ammo - 1), OFFSET_LINUX);
				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
			}
		}
	}
}

public ham__ItemDeployPost(const weapon_ent) {
	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!pev_valid(iId)) {
		return;
	}

	static iWeaponId;
	iWeaponId = cs_get_weapon_id(weapon_ent);

	if(g_Mode != MODE_DUEL_FINAL && g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME) {
		if(!g_Zombie[iId] && !g_SpecialMode[iId] && g_ModeFleshpound_Power[iId] != 3 && g_HabRotate[iId][HAB_ROTATE_PORTA_CUCHILLOS]) {
			if(iWeaponId == CSW_KNIFE) {
				static Float:flSpeedExtra;
				flSpeedExtra = ((25.0 * g_Speed[iId]) / 100.0);

				if(flSpeedExtra > get_cvar_float("sv_maxspeed")) {
					flSpeedExtra = get_cvar_float("sv_maxspeed");
				}

				g_Speed[iId] += flSpeedExtra;
			} else {
				g_Speed[iId] = Float:humanSpeed(iId);
			}

			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);
		}
	}

	g_CurrentWeapon[iId] = iWeaponId;
	g_TypeWeapon[iId] = (((1<<iWeaponId) & PRIMARY_WEAPONS_BIT_SUM) ? 1 : ((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM) ? 0 : -1);

	if(g_Zombie[iId] && !((1<<iWeaponId) & ZOMBIE_ALLOWED_WEAPONS_BIT_SUM)) {
		g_CurrentWeapon[iId] = CSW_KNIFE;
		engclient_cmd(iId, "weapon_knife");
	}

	checkWeaponDeployTime(iId);

	replaceWeaponModels(iId, iWeaponId);
}

public checkWeaponDeployTime(const id) {
	if(g_LastWeapon[id] != CSW_HEGRENADE && g_LastWeapon[id] != CSW_FLASHBANG && g_LastWeapon[id] != CSW_SMOKEGRENADE && g_LastWeapon[id]) {
		g_WeaponSave[id][g_LastWeapon[id]] = 1;

		if(!g_WeaponData[id][g_LastWeapon[id]][WEAPON_DATA_TIME_PLAYED_DONE]) {
			g_WeaponData[id][g_LastWeapon[id]][WEAPON_DATA_TIME_PLAYED_DONE] = 1;

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_weapons (acc_id, weapon_id) VALUES ('%d', '%d');", g_AccountId[id], g_LastWeapon[id]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		}

		g_WeaponData[id][g_LastWeapon[id]][WEAPON_DATA_TIME_PLAYED_DONE] += (get_arg_systime() - g_WeaponTime[id]);
	}

	g_WeaponTime[id] = get_arg_systime();

	g_LastWeapon[id] = g_CurrentWeapon[id];
}

public touch__PlayerHeadZombie(const head, const id) {
	if(!is_valid_ent(head) || !g_IsAlive[id]) {
		return PLUGIN_CONTINUE;
	}

	if(g_Zombie[id]) {
		return PLUGIN_CONTINUE;
	}

	new Float:flHalfLifeTime = halflife_time();

	if((flHalfLifeTime - g_HeadZombie_LastTouch[id]) < 2.5) {
		return PLUGIN_CONTINUE;
	}

	g_HeadZombie_LastTouch[id] = flHalfLifeTime;

	new iHeadColor = entity_get_edict(head, EV_ENT_euser4);

	++g_HeadZombie[id][iHeadColor];
	clientPrintColor(id, _, "Agarraste una cabeza zombie %s", __HEADZOMBIE_COLORS_MIN[iHeadColor]);

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

	if(g_HeadZombie[id][HEADZOMBIE_RED] && g_HeadZombie[id][HEADZOMBIE_GREEN] && g_HeadZombie[id][HEADZOMBIE_BLUE] && g_HeadZombie[id][HEADZOMBIE_YELLOW]) {
		setAchievement(id, COLORIDO);
	}

	emitSound(head, CHAN_VOICE, "items/ammopickup1.wav");

	remove_entity(head);
	return PLUGIN_CONTINUE;
}

public touch__PlayerHeadZombieSmall(const head, const id) {
	if(!is_valid_ent(head) || !g_IsAlive[id]) {
		return PLUGIN_CONTINUE;
	}

	if(g_Zombie[id]) {
		return PLUGIN_CONTINUE;
	}

	new Float:flHalfLifeTime = halflife_time();

	if((flHalfLifeTime - g_HeadZombie_LastTouch[id]) < 2.5) {
		return PLUGIN_CONTINUE;
	}

	g_HeadZombie_LastTouch[id] = flHalfLifeTime;

	++g_HeadZombie[id][HEADZOMBIE_VIOLET_SMALL];
	clientPrintColor(id, _, "Agarraste una cabeza zombie %s", __HEADZOMBIE_COLORS_MIN[HEADZOMBIE_VIOLET_SMALL]);
	
	g_HeadZombie_LastTouch[id] = 0.0;
	
	emitSound(head, CHAN_VOICE, "items/ammopickup1.wav");

	remove_entity(head);
	return PLUGIN_CONTINUE;
}

public think__General(const ent) {
	static i;
	static iSpectId;
	static sHealth[16];
	static sArmor[16];
	static sAmmoPacks[16];
	static Float:flHalfTime;
	static Float:vecOrigin[3];

	iSpectId = 0;
	sHealth[0] = EOS;
	sArmor[0] = EOS;
	sAmmoPacks[0] = EOS;
	flHalfTime = halflife_time();

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			if(getUserAura(i)) {
				if(g_Mode == MODE_TRIBAL && g_SpecialMode[i] == MODE_TRIBAL) {
					tribalAura(i);
				} else {
					entity_get_vector(i, EV_VEC_origin, vecOrigin);

					engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
					write_byte(TE_DLIGHT);
					engfunc(EngFunc_WriteCoord, vecOrigin[0]);
					engfunc(EngFunc_WriteCoord, vecOrigin[1]);
					engfunc(EngFunc_WriteCoord, vecOrigin[2]);
					write_byte(g_Aura[i][3]);
					write_byte(g_Aura[i][0]);
					write_byte(g_Aura[i][1]);
					write_byte(g_Aura[i][2]);
					write_byte(2);
					write_byte(0);
					message_end();
				}
			}

			if(g_IsAlive[i]) {
				if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME) {
					addDot(g_Health[i], sHealth, charsmax(sHealth));

					set_hudmessage(g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][2], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][1], g_UserOptions_HudEffect[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
					ShowSyncHudMsg(i, g_HudSync_General, "%s^n^nVida: %s^nNivel: %d", g_ModeGG_Stats, sHealth, g_ModeGG_Level[i]);
				} else if(g_Mode == MODE_L4D2) {
					addDot(g_Health[i], sHealth, charsmax(sHealth));
					
					set_hudmessage(g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][2], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][1], g_UserOptions_HudEffect[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
					ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^nZombies restantes: %d", sHealth, g_ModeL4D2_Zombies);
				} else {
					if(g_InGroup[i]) {
						if(flHalfTime >= g_HLTime_GroupCombo[g_InGroup[i]]) {
							finishComboHuman(i);
						} else if(flHalfTime >= g_ComboTime[i] && g_Zombie[i]) {
							finishComboZombie(i);
						}
					} else {
						if(flHalfTime >= g_ComboTime[i]) {
							if(!g_Zombie[i]) {
								finishComboHuman(i);
							} else {
								finishComboZombie(i);
							}
						} else if(!g_Zombie[i] && g_Combo[i]) {
							updateComboHuman(i);
						}
					}
					
					addDot(g_Health[i], sHealth, charsmax(sHealth));

					if(!g_Zombie[i]) {
						switch(g_UserOptions_HudStyle[i][HUD_TYPE_GENERAL]) {
							case 0: {
								formatex(sArmor, charsmax(sArmor), "Chaleco: %d^n", get_user_armor(i));
							} case 1: {
								formatex(sArmor, charsmax(sArmor), "[Chaleco: %d]^n", get_user_armor(i));
							} case 2: {
								formatex(sArmor, charsmax(sArmor), "Chaleco: %d - ", get_user_armor(i));
							} case 3: {
								formatex(sArmor, charsmax(sArmor), "[Chaleco: %d] - ", get_user_armor(i));
							} case 4: {
								formatex(sArmor, charsmax(sArmor), "Chaleco: %d - ", get_user_armor(i));
							}
						}
					} else {
						sArmor[0] = EOS;
					}

					addDot(g_AmmoPacks[i], sAmmoPacks, charsmax(sAmmoPacks));

					set_hudmessage(g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][2], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][1], g_UserOptions_HudEffect[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);

					switch(g_UserOptions_HudStyle[i][HUD_TYPE_GENERAL]) {
						case 0: {
							ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^n%sClase: %s^nAmmoPacks: %s^nExperiencia: %s^nNivel: %d (%0.2f%%)^nReset: %d", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, g_XPHud[i], g_Level[i], g_LevelPercent[i], g_Reset[i]);
						} case 1: {
							ShowSyncHudMsg(i, g_HudSync_General, "[Vida: %s]^n%s[Clase: %s]^n[AmmoPacks: %s]^n[Experiencia: %s]^n[Nivel: %d (%0.2f%%)]^n[Reset: %d]", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, g_XPHud[i], g_Level[i], g_LevelPercent[i], g_Reset[i]);
						} case 2: {
							ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s - %sClase: %s - AmmoPacks: %s^nExperiencia: %s - Nivel: %d (%0.2f%%) - Reset: %d", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, g_XPHud[i], g_Level[i], g_LevelPercent[i], g_Reset[i]);
						} case 3: {
							ShowSyncHudMsg(i, g_HudSync_General, "[Vida: %s] - %s[Clase: %s] - [AmmoPacks: %s]^n[Experiencia: %s] - [Nivel: %d (%0.2f%%)] - [Reset: %d]", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, g_XPHud[i], g_Level[i], g_LevelPercent[i], g_Reset[i]);
						} case 4: {
							ShowSyncHudMsg(i, g_HudSync_General, " - Vida: %s - %sClase: %s - AmmoPacks: %s - ^n - Experiencia: %s - Nivel: %d (%0.2f%%) - Reset: %d - ", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, g_XPHud[i], g_Level[i], g_LevelPercent[i], g_Reset[i]);
						}
					}
				}

				if(g_UserOptions_CurrentMode[i]) {
					set_hudmessage(200, 200, 200, -1.0, 0.9175, 0, 6.0, 1.1, 0.0, 0.0, 2);

					if(g_NewRound || g_EndRound) {
						ShowSyncHudMsg(i, g_HudSync_CurrentMode, "Modo actual: -");
					} else {
						ShowSyncHudMsg(i, g_HudSync_CurrentMode, "Modo actual: %s", __MODES[g_CurrentMode][modeName]);
					}
				}
			} else {
				iSpectId = entity_get_int(i, EV_ID_SPEC);

				if(g_IsAlive[iSpectId]) {
					if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME) {
						addDot(g_Health[iSpectId], sHealth, charsmax(sHealth));

						set_hudmessage(g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][2], g_UserOptions_Hud[iSpectId][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[iSpectId][HUD_TYPE_GENERAL][1], g_UserOptions_HudEffect[iSpectId][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
						ShowSyncHudMsg(i, g_HudSync_General, "%s^n^nVida: %s^nNivel: %d", g_ModeGG_Stats, sHealth, g_ModeGG_Level[iSpectId]);
					} else if(g_Mode == MODE_L4D2) {
						addDot(g_Health[iSpectId], sHealth, charsmax(sHealth));
						
						set_hudmessage(g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][2], g_UserOptions_Hud[iSpectId][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[iSpectId][HUD_TYPE_GENERAL][1], g_UserOptions_HudEffect[iSpectId][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
						ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^nZombies restantes: %d", sHealth, g_ModeL4D2_Zombies);
					} else {
						addDot(g_Health[iSpectId], sHealth, charsmax(sHealth));

						if(!g_Zombie[iSpectId]) {
							switch(g_UserOptions_HudStyle[iSpectId][HUD_TYPE_GENERAL]) {
								case 0: {
									formatex(sArmor, charsmax(sArmor), "Chaleco: %d^n", get_user_armor(iSpectId));
								} case 1: {
									formatex(sArmor, charsmax(sArmor), "[Chaleco: %d]^n", get_user_armor(iSpectId));
								} case 2: {
									formatex(sArmor, charsmax(sArmor), "Chaleco: %d - ", get_user_armor(iSpectId));
								} case 3: {
									formatex(sArmor, charsmax(sArmor), "[Chaleco: %d] - ", get_user_armor(iSpectId));
								} case 4: {
									formatex(sArmor, charsmax(sArmor), "Chaleco: %d - ", get_user_armor(iSpectId));
								}
							}
						} else {
							sArmor[0] = EOS;
						}

						addDot(g_AmmoPacks[iSpectId], sAmmoPacks, charsmax(sAmmoPacks));

						set_hudmessage(g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[iSpectId][COLOR_TYPE_HUD_GENERAL][2], 1.5, 0.6, g_UserOptions_HudEffect[iSpectId][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);

						switch(g_UserOptions_HudStyle[iSpectId][HUD_TYPE_GENERAL]) {
							case 0: {
								ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^n%sClase: %s^nAmmoPacks: %s^nExperiencia: %s^nNivel: %d (%0.2f%%)^nReset: %d", sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, g_XPHud[iSpectId], g_Level[iSpectId], g_LevelPercent[iSpectId], g_Reset[iSpectId]);
							} case 1: {
								ShowSyncHudMsg(i, g_HudSync_General, "[Vida: %s]^n%s[Clase: %s]^n[AmmoPacks: %s]^n[Experiencia: %s]^n[Nivel: %d (%0.2f%%)]^n[Reset: %d]", sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, g_XPHud[iSpectId], g_Level[iSpectId], g_LevelPercent[iSpectId], g_Reset[iSpectId]);
							} case 2: {
								ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s - %sClase: %s - AmmoPacks: %s^nExperiencia: %s - Nivel: %d (%0.2f%%) - Reset: %d", sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, g_XPHud[iSpectId], g_Level[iSpectId], g_LevelPercent[iSpectId], g_Reset[iSpectId]);
							} case 3: {
								ShowSyncHudMsg(i, g_HudSync_General, "[Vida: %s] - %s[Clase: %s] - [AmmoPacks: %s]^n[Experiencia: %s] - [Nivel: %d (%0.2f%%)] - [Reset: %d]", sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, g_XPHud[iSpectId], g_Level[iSpectId], g_LevelPercent[iSpectId], g_Reset[iSpectId]);
							} case 4: {
								ShowSyncHudMsg(i, g_HudSync_General, " - Vida: %s - %sClase: %s - AmmoPacks: %s - ^n - Experiencia: %s - Nivel: %d (%0.2f%%) - Reset: %d - ", sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, g_XPHud[iSpectId], g_Level[iSpectId], g_LevelPercent[iSpectId], g_Reset[iSpectId]);
							}
						}
					}
				}

				if(g_UserOptions_CurrentMode[i]) {
					set_hudmessage(200, 200, 200, -1.0, 0.825, 0, 6.0, 1.1, 0.0, 0.0, 2);

					if(g_NewRound || g_EndRound) {
						ShowSyncHudMsg(i, g_HudSync_CurrentMode, "Modo actual: -");
					} else {
						ShowSyncHudMsg(i, g_HudSync_CurrentMode, "Modo actual: %s", __MODES[g_CurrentMode][modeName]);
					}
				}
			}
		}
	}

	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
}

public clcmd__EnterPassword(const id) {
	static sBuffer[MAX_STRING_PASSWORD];
	read_argv(1, sBuffer, charsmax(sBuffer));

	if(g_AccountStatus[id] == STATUS_REGISTERED) {
		hash_string(sBuffer, Hash_Md5, sBuffer, charsmax(sBuffer));

		if(equal(sBuffer, g_AccountPassword[id])) {
			g_AccountStatus[id] = STATUS_LOADING;

			loadInfo(id);

			clientPrintColor(id, _, "Bienvenido !t%s!y nuevamente al !g%s!y.", g_PlayerName[id], __PLUGIN_NAME);
		} else {
			++g_AccountAttempts[id];

			if(g_AccountAttempts[id] == 3) {
				rh_drop_client(id, fmt("Te hemos expulsado porque has realizado demasiados intentos para ingresar a la cuenta.", get_user_userid(id)));
			} else {
				clientPrintColor(id, _, "La contraseña que has ingresado es incorrecta. Inténtalo nuevamente");
				showMenu__LogIn(id);
			}
		}
	} else {
		if(g_AccountStatus[id] == STATUS_UNREGISTERED) {
			if((4 <= strlen(sBuffer) <= MAX_STRING_PASSWORD_LIMIT)) {
				if(isAlphanumeric(sBuffer)) {
					copy(g_AccountPassword[id], charsmax(g_AccountPassword[]), sBuffer);
					g_AccountStatus[id] = STATUS_CONFIRM;

					client_cmd(id, "messagemode INGRESAR_CLAVE");
					clientPrintColor(id, _, "Confirma tu contraseña ingresándola nuevamente.");
				} else {
					clientPrintColor(id, _, "La contraseña solo permite números y letras.");
					showMenu__LogIn(id);
				}
			} else {
				clientPrintColor(id, _, "La contraseña admite entre 4 a %d caracteres", MAX_STRING_PASSWORD_LIMIT);
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

				clientPrintColor(id, _, "Codigo de recuperación generado (!g%s!y). Guardalo en algun lado, te servira en el futuro.", g_AccountCode[id]);

				static Handle:sqlQuery;
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_accounts WHERE name=^"%s^";", g_PlayerName[id]);

				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 1);
				} else if(SQL_NumResults(sqlQuery)) {
					SQL_FreeHandle(sqlQuery);

					clientPrintColor(id, _, "Esta cuenta ya está registrada en este servidor.");
					showMenu__LogIn(id);
				} else {
					SQL_FreeHandle(sqlQuery);

					static iArgs[1];
					iArgs[0] = id;

					if(getUserIsSteamId(id)) {
						copy(g_PlayerSteamIdCache[id], charsmax(g_PlayerSteamIdCache[]), g_PlayerSteamId[id]);
					} else {
						formatex(g_PlayerSteamIdCache[id], charsmax(g_PlayerSteamIdCache[]), "STEAM_ID_LAN");
					}

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_accounts (name, since_ip, last_ip, since_steam, last_steam, password, recovery_code, since_connection, last_connection) VALUES (^"%s^", ^"%s^", ^"%s^", ^"%s^", ^"%s^", ^"%s^", ^"%s^", '%d', '%d');", g_PlayerName[id], g_PlayerIp[id], g_PlayerIp[id], g_PlayerSteamIdCache[id], g_PlayerSteamId[id], g_AccountPassword[id], g_AccountCode[id], get_arg_systime(), get_arg_systime());
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__RegisterAccount", g_SqlQuery, iArgs, sizeof(iArgs));

					clientPrintColor(id, _, "Tu cuenta fue creada exitosamente en la base de datos.");
				}
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public getUserIsSteamId(const id) {
	new iLen = strlen(g_PlayerSteamId[id]);

	if(equali(g_PlayerSteamId[id], "STEAM_ID_PENDING") ||
	equali(g_PlayerSteamId[id], "STEAM_ID_LAN") ||
	iLen <= 16 ||
	(g_PlayerSteamId[id][0] == 'V' && g_PlayerSteamId[id][1] == 'A' && g_PlayerSteamId[id][2] == 'L')) {
		return 0;
	}

	return 1;
}

public clcmd__Rank(const id) {
	if(!g_IsConnected[id]) {
		return PLUGIN_HANDLED;
	} else if(g_AccountStatus[id] < STATUS_LOGGED) {
		clientPrintColor(id, _, "Debes estar logueado para utilizar este comando");
		return PLUGIN_HANDLED;
	}

	new Float:flGameTime = get_gametime();

	if(g_Rank_SysTime[id] > flGameTime) {
		new Float:flRest = (g_Rank_SysTime[id] - flGameTime);

		clientPrintColor(id, _, "Debes esperar !g%0.2f segundo%s!y para volver a ver tu Rank", flRest, ((flRest != 1.0) ? "s" : ""));
		return PLUGIN_HANDLED;
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT COUNT(acc_id) AS rank FROM zp8_pjs u WHERE ((u.level + (u.reset * 300)) > (SELECT (level + (reset * 300)) FROM zp8_pjs u2 WHERE u2.acc_id='%d') OR ((u.level + (u.reset * 300)) = (SELECT (level + (reset * 300)) FROM zp8_pjs u2 WHERE u2.acc_id='%d') AND u.acc_id<='%d'));", g_AccountId[id], g_AccountId[id], g_AccountId[id]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 2);
	} else if(SQL_NumResults(sqlQuery)) {
		clientPrintColor(id, _, "Tu ranking es: !g%d!y / !g%d!y", SQL_ReadResult(sqlQuery, 0), g_GlobalRank);
		SQL_FreeHandle(sqlQuery);
	} else {
		clientPrintColor(id, _, "No se ha podido detectar tu ranking actual");
		SQL_FreeHandle(sqlQuery);
	}

	g_Rank_SysTime[id] = (flGameTime + 15.0);
	return PLUGIN_HANDLED;
}

public clcmd__NextModeSay(const id) {
	if(!g_IsConnected[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_CurrentMode == MODE_NONE) {
		clientPrintColor(id, _, "El modo actual es: !gNINGUNO!y");
	} else {
		clientPrintColor(id, _, "El modo actual es: !g%s!y", __MODES[g_CurrentMode][modeName]);
	}

	if(g_NextMode == -1) {
		clientPrintColor(id, _, "El siguiente modo será: !gEsperando que inicie el modo actual!y");
	} else if(g_NextMode == MODE_NONE) {
		clientPrintColor(id, _, "El siguiente modo será: !gNINGUNO!y");
	} else {
		clientPrintColor(id, _, "El siguiente modo será: !g%s!y", __MODES[g_NextMode][modeName]);
	}
	
	if(g_EventModes && (g_EventMode_MegaArmageddon > 0 || g_EventMode_GunGame > 0)) {
		if(g_EventMode_GunGame > 0) {
			clientPrintColor(id, _, "GunGame %s en !g%d ronda%s!y - Mega Armageddon en !g%d ronda%s!y.", __GUNGAME_TYPE_NAME[g_ModeGG_Type], g_EventMode_GunGame, ((g_EventMode_GunGame != 1) ? "s" : ""), g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
		} else {
			clientPrintColor(id, _, "Mega Armageddon en !g%d ronda%s!y", g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__Mult(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING) {
		return PLUGIN_HANDLED;
	}

	clientPrintColor(id, _, "Daño que necesitas para relizar un combo es: !g%0.2f!y", g_ComboDamageNeed[id]);
	clientPrintColor(id, _, "Multiplicador de AmmoPacks: !gx%0.2f!y ~ Multiplicador de XP: !gx%0.2f!y ~ Multiplicador de puntos: !gx%d!y", g_AmmoPacksMult[id], g_XPMult[id], g_PointsMult[id]);

	return PLUGIN_HANDLED;
}

public clcmd__Update(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING) {
		return PLUGIN_HANDLED;
	}

	clientPrintColor(id, _, "Has actualizado tus multiplicadores correctamente");

	updateMultipliersVars(id);
	return PLUGIN_HANDLED;
}

public clcmd__BlockCommands(const id) {
	return PLUGIN_HANDLED;
}

public clcmd__NVision(const id) {
	if(!g_IsConnected[id] || !g_UserOptions_NVision[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_NVision[id]) {
		if(task_exists(id + TASK_NVISION)) {
			remove_task(id + TASK_NVISION);
		} else {
			set_task(0.3, "task__SetUserNVision", id + TASK_NVISION, .flags="b");
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__Drop(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING) {
		return PLUGIN_HANDLED;
	}

	switch(g_SpecialMode[id]) {
		case MODE_LEATHERFACE: {
			if(g_Mode == MODE_LEATHERFACE && !g_Leatherface_Teleport[id] && g_Hab[id][HAB_S_L_TELEPORT]) {
				leatherfaceTeleport(id);
			}
		} case MODE_TRIBAL: {
			if(g_Mode == MODE_TRIBAL && g_SpecialMode[id] == MODE_TRIBAL) {
				if(g_ModeTribal_Power && task_exists(id + TASK_POWER_MODE)) {
					tribalPower(id);
				}
			}
		} case MODE_SNIPER: {
			if(g_Mode == MODE_SNIPER && !g_SniperPower[id]) {
				g_SniperPower[id] = 1;

				clientPrint(0, print_center, "¡El SNIPER activó su DISPARO VELOZ!");

				remove_task(id + TASK_POWER_MODE);
				set_task(10.0, "task__FinishSniperPower", id + TASK_POWER_MODE);
			}
		} case MODE_CABEZON: {
			if(g_ModeCabezon_Power[id] && get_gametime() >= g_ModeCabezon_PowerLastUse[id]) {
				if((entity_get_int(id, EV_INT_flags) & FL_ONGROUND)) {
					--g_ModeCabezon_Power[id];
					g_ModeCabezon_PowerLastUse[id] = (get_gametime() + 45.0);

					emitSound(id, CHAN_VOICE, __SOUND_CABEZON_POWER);

					set_user_gravity(id, 0.000001);
					client_cmd(id, "+jump;wait;-jump");

					set_task(1.55, "task__PowerCabezonOne", id);
					set_task(1.7, "task__PowerCabezonTwo", id);

					g_ModeCabezon_PowerGlobal = 1;
				} else {
					clientPrintColor(id, _, "Tenés que estar sobre el suelo para lanzar el poder");
				}
			} else {
				clientPrintColor(id, _, "Debes esperar unos segundos para volver a tirar el poder");
			}
		} case MODE_GRUNT: {
			if(g_ModeGrunt_Power == 0) {
				g_ModeGrunt_Power = 1;
				set_task(0.1, "task__PowerGrunt");
			}
		} case MODE_FLESHPOUND: {
			if(g_Mode == MODE_FLESHPOUND && g_ModeFleshpound_Power[id] == 1 && !g_EndRound) {
				new Float:vecOrigin[3];
				new Float:vecOriginVictim[3];
				new i;

				entity_get_vector(id, EV_VEC_origin, vecOrigin);

				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i]) {
						continue;
					}

					entity_get_vector(i, EV_VEC_origin, vecOriginVictim);

					if(get_distance_f(vecOrigin, vecOriginVictim) <= 350.0) {
						message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, i);
						write_short(UNIT_SECOND_FLESHPOUND);
						write_short(UNIT_SECOND_FLESHPOUND);
						write_short(UNIT_SECOND_FLESHPOUND);
						message_end();

						if(g_SpecialMode[i] != MODE_FLESHPOUND) {
							g_ModeFleshpound_Power[i] = 3;

							g_Speed[i] = 75.0;
							ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);
						}
					}
				}

				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
				write_byte(TE_BEAMCYLINDER);
				engfunc(EngFunc_WriteCoord, vecOrigin[0]);
				engfunc(EngFunc_WriteCoord, (vecOrigin[1] + 25.0));
				engfunc(EngFunc_WriteCoord, (vecOrigin[2] + 55.0));
				engfunc(EngFunc_WriteCoord, vecOrigin[0]);
				engfunc(EngFunc_WriteCoord, (vecOrigin[1] + 50.0));
				engfunc(EngFunc_WriteCoord, (vecOrigin[2] + 999.0));
				write_short(g_Sprite_ShockWave);
				write_byte(0);
				write_byte(0);
				write_byte(4);
				write_byte(60);
				write_byte(0);
				write_byte(255);
				write_byte(165);
				write_byte(50);
				write_byte(255);
				write_byte(0);
				message_end();

				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
				write_byte(TE_DLIGHT);
				engfunc(EngFunc_WriteCoord, vecOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecOrigin[2]);
				write_byte(99);
				write_byte(255);
				write_byte(165);
				write_byte(50);
				write_byte(50);
				write_byte(60);
				message_end();

				g_ModeFleshpound_Power[id] = 2;

				g_Speed[id] = 350.0;
				set_user_gravity(id, 0.7);

				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

				set_user_rendering(id, kRenderFxGlowShell, 255, 165, 50, kRenderNormal, 16);

				remove_task(id + TASK_POWER_MODE);
				set_task(15.0, "task__PowerFleshpound", id + TASK_POWER_MODE);
			}
		} default: {
			if(!g_Zombie[id] && g_Hab[id][HAB_E_CHANGE_BOMBS] && g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
				if(g_CurrentWeapon[id] == CSW_HEGRENADE && g_DrugBomb[id]) {
					g_DrugBombMode[id] = !g_DrugBombMode[id];
					clientPrint(id, print_center, "Modo: %s", ((g_DrugBombMode[id]) ? "Fuego" : "Droga"));
				} else if(g_CurrentWeapon[id] == CSW_FLASHBANG && g_SupernovaBomb[id]) {
					g_SupernovaBombMode[id] = !g_SupernovaBombMode[id];
					clientPrint(id, print_center, "Modo: %s", ((g_SupernovaBombMode[id]) ? "Hielo" : "Supernova"));
				} else if(g_CurrentWeapon[id] == CSW_SMOKEGRENADE && g_BubbleBomb[id]) {
					g_BubbleBombMode[id] = !g_BubbleBombMode[id];
					clientPrint(id, print_center, "Modo: %s", ((g_BubbleBombMode[id]) ? "Luz" : "Bubble"));
				}
			}
		}
	}

	if(g_AccountId[id] == 1) {
		new Float:vecOrigin[3];
		new Float:vecEndOrigin[3];
		new Float:flFraction;

		entity_get_vector(id, EV_VEC_origin, vecOrigin);
		getDropOrigin(id, vecEndOrigin, 20);

		engfunc(EngFunc_TraceLine, vecOrigin, vecEndOrigin, IGNORE_MONSTERS, id, 0);
		get_tr2(0, TR_flFraction, flFraction);

		if(flFraction == 1.0) {
			dropHeadZombie(id, 1);
		}
	}

	return PLUGIN_HANDLED;
}

public task__PowerFleshpound(const task_id) {
	new iId = (task_id - TASK_POWER_MODE);

	if(!g_IsAlive[iId] || g_SpecialMode[iId] != MODE_FLESHPOUND) {
		return;
	}

	g_ModeFleshpound_Power[iId] = 0;

	g_Speed[iId] = 255.0;
	set_user_gravity(iId, 1.0);

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);

	set_user_rendering(iId);
}

public leatherfaceTeleport(const id) {
	if(!g_IsAlive[id] || g_SpecialMode[id] != MODE_LEATHERFACE || !g_Hab[id][HAB_S_L_TELEPORT]) {
		return;
	}

	clientPrintColor(id, _, "¡El LeatherFace ha utilizado su teletransportación!");

	g_Leatherface_Teleport[id] = 1;

	randomSpawn(id);
}

public clcmd__Say(const id) {
	if(!g_IsConnected[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_Mode == MODE_GRUNT) {
		if(!g_IsAlive[id]) {
			clientPrintColor(id, _, "No puedes utilizar el chat estando muerto en modo !tGRUNT!y");
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

	iGreen = ((get_user_flags(id) & ADMIN_RESERVATION) ? 1 : 0);

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i] && !dg_get_user_mute(i, id)) {
			if(g_AccountStatus[id] == STATUS_PLAYING) {
				client_print_color(i, id, "%s%s^3%s%s^1 :%s %s", ((g_IsAlive[id]) ? "" : "^1(MUERTO) "), getUserTypeMod(id), g_PlayerName[id], getUserChatMode(id), ((iGreen) ? "^4" : "^1"), sMessage);
			} else {
				client_print_color(i, id, "^1(%s)^3 %s^1 :%s %s", getAccountStatus(id), g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
			}
		}
	}

	return PLUGIN_HANDLED;
}

public getAccountStatus(const id) {
	new sStatus[16];
	sStatus[0] = EOS;

	if(g_AccountStatus[id] == STATUS_BANNED) {
		formatex(sStatus, charsmax(sStatus), "BANEADO");
	} else if(g_AccountStatus[id] == STATUS_CHECK_ACCOUNT || g_AccountStatus[id] == STATUS_UNREGISTERED) {
		formatex(sStatus, charsmax(sStatus), "SIN REGISTRARSE");
	} else if(g_AccountStatus[id] == STATUS_CONFIRM || g_AccountStatus[id] == STATUS_LOADING) {
		formatex(sStatus, charsmax(sStatus), "CARGANDO . . .");
	} else if(g_AccountStatus[id] == STATUS_REGISTERED) {
		formatex(sStatus, charsmax(sStatus), "SIN IDENTIFICARSE");
	} else if(g_AccountStatus[id] == STATUS_LOGGED) {
		formatex(sStatus, charsmax(sStatus), "ESPECTADOR");
	}

	return sStatus;
}

public clcmd__SayTeam(const id) {
	if(g_Mode == MODE_GRUNT) {
		clientPrintColor(id, _, "Este chat está bloqueado en modo !tGRUNT!y");
		return PLUGIN_HANDLED;
	}

	if(!g_InGroup[id]) {
		return PLUGIN_HANDLED;
	}

	static sMessage[191];
	read_args(sMessage, charsmax(sMessage));

	replace_all(sMessage, charsmax(sMessage), "#", "");
	replace_all(sMessage, charsmax(sMessage), "%", "");
	replace_all(sMessage, charsmax(sMessage), "!y", ""); 
	replace_all(sMessage, charsmax(sMessage), "!t", "");
	replace_all(sMessage, charsmax(sMessage), "!g", "");

	if(equal(sMessage, "") || sMessage[0] == '/' || sMessage[0] == '@' || sMessage[0] == '!') {
		return PLUGIN_HANDLED;
	}

	remove_quotes(sMessage);
	trim(sMessage);

	static iGreen;
	static i;

	iGreen = ((get_user_flags(id) & ADMIN_RESERVATION) ? 1 : 0);

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i] && !dg_get_user_mute(i, id)) {
			if((get_user_flags(i) & ADMIN_LEVEL_C)) {
				client_print_color(i, id, "^1[%d] - %s^4[GRUPO]^3 %s^1 :%s %s", g_InGroup[id], ((g_IsAlive[id]) ? "" : "(MUERTO) "), g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
			}

			if(g_InGroup[id] == g_InGroup[i] && !(get_user_flags(i) & ADMIN_LEVEL_C)) {
				client_print_color(i, id, "%s^4[GRUPO]^3 %s^1 :%s %s", ((g_IsAlive[id]) ? "" : "^1(MUERTO) "), g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
			}
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__SaveAll(const id) {
	if(!g_IsConnected[id] || g_DataSaved) {
		return PLUGIN_HANDLED;
	} else if(g_AccountId[id] != 1) {
		consolePrint(id, "No tienes acceso a este comando");
		return PLUGIN_HANDLED;
	}

	new iUsersPlaying = getUsersPlaying();

	if(iUsersPlaying < 2) {
		consolePrint(id, "Debe haber al menos 2 jugadores conectados para utilizar este comando");
		return PLUGIN_HANDLED;
	}

	clientPrintColor(0, _, "En los próximos !g10 SEGUNDOS!y se congelará el servidor a causa del guardado completo de los jugadores coenctados");
	clientPrintColor(0, _, "En los próximos !g10 SEGUNDOS!y se congelará el servidor a causa del guardado completo de los jugadores coenctados");
	clientPrintColor(0, _, "En los próximos !g10 SEGUNDOS!y se congelará el servidor a causa del guardado completo de los jugadores coenctados");
	clientPrintColor(0, _, "En los próximos !g10 SEGUNDOS!y se congelará el servidor a causa del guardado completo de los jugadores coenctados");

	remove_task(TASK_SAVE_ALL);
	set_task(10.1, "task__SaveAll", TASK_SAVE_ALL);

	return PLUGIN_HANDLED;
}

public task__SaveAll() {
	new iUsersPlaying = getUsersPlaying();

	if(iUsersPlaying < 2) {
		return;
	}

	clientPrintColor(0, _, "Guardando datos de !g%d jugador%s!y", iUsersPlaying, ((iUsersPlaying != 1) ? "es" : ""));
	clientPrintColor(0, _, "A partir de aquí el guardado está deshabilitado, no es recomendable que utilices ningún medio de guardado");
	clientPrintColor(0, _, "Ante la duda, tampoco te desconectes y vuelvas a conectar del servidor para evitar superposición de datos");

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_LOGGED) {
			continue;
		}

		remove_task(i + TASK_SAVE);
		saveInfo(i, .disconnect=1, .prepare_query=1);
	}

	g_DataSaved = 1;
}

public clcmd__AmmoPacks(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, 0);
	
	if(iTarget) {
		new sAmmoPacks[16];
		read_argv(2, sAmmoPacks, charsmax(sAmmoPacks));
		
		if(read_argc() < 3) {
			consolePrint(id, "Uso: zp_ammopacks <nombre> <factor, + o nada (setear)> <cantidad>");
			return PLUGIN_HANDLED;
		}
		
		new iiAmmoPacks;
		iiAmmoPacks = str_to_num(sAmmoPacks);
		
		switch(sAmmoPacks[0]) {
			case '+': {
				g_AmmoPacks[iTarget] += iiAmmoPacks;

				clientPrintColor(iTarget, _, "!t%s!y te ha dado !g%d AmmoPacks!y", g_PlayerName[id], iiAmmoPacks);
			} default: {
				g_AmmoPacks[iTarget] = iiAmmoPacks;
				
				clientPrintColor(iTarget, _, "!t%s!y te ha editado tus !gAmmoPacks!y, ahora tenés !g%0d AmmoPacks!y", g_PlayerName[id], iiAmmoPacks);
			}
		}
		
		consolePrint(id, "Los AmmoPacks de %s han sido modificados", g_PlayerName[iTarget]);
	}
	
	return PLUGIN_HANDLED;
}

public clcmd__XP(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sArg2[16];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	iTarget = cmd_target(id, sArg1, 0);

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_xp <nombre> <factor, + o nada (setear)> <cantidad>");
		return PLUGIN_HANDLED;
	}

	new iXP;
	iXP = str_to_num(sArg2);

	if(iTarget) {
		switch(sArg2[0]) {
			case '+': {
				addXP(iTarget, iXP);

				clientPrintColor(iTarget, _, "!t%s!y te ha dado !g%d XP!y", g_PlayerName[id], iXP);
			} default: {
				g_XP[iTarget] = 0;

				addXP(iTarget, iXP);
				
				clientPrintColor(iTarget, _, "!t%s!y te ha editado tus !gXP!y, ahora tenés !g%0d XP!y", g_PlayerName[id], iXP);
			}
		}
		
		consolePrint(id, "Los XP de %s han sido modificados", g_PlayerName[iTarget]);
	} else {
		new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp8_pjs.acc_id, zp8_pjs.xp FROM zp8_pjs LEFT JOIN zp8_accounts ON zp8_pjs.acc_id=zp8_accounts.id WHERE zp8_accounts.name=^"%s^";", sArg1);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 3);
		} else if(SQL_NumResults(sqlQuery)) {
			new iId = SQL_ReadResult(sqlQuery, 0);
			new iDataBaseXP = SQL_ReadResult(sqlQuery, 1);
			new iTotal;

			iTotal = (iXP + iDataBaseXP);

			if(iTotal < 0 || iTotal > MAX_XP) {
				iTotal = MAX_XP;
			}

			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_pjs SET xp='%d' WHERE acc_id='%d';", iTotal, iId);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 4);
			} else {
				SQL_FreeHandle(sqlQuery);
			}
		} else {
			consolePrint(id, "No se ha encontrado al jugador especificado en la base de datos");
			SQL_FreeHandle(sqlQuery);
		}
	}
	
	return PLUGIN_HANDLED;
}

public clcmd__Level(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_level <nombre> <factor, + o nada (setear)> <cantidad>");
		return PLUGIN_HANDLED;
	}

	if((sArg1[0] == '@' && sArg1[1] == 'P') || (sArg1[0] == '@' && sArg1[1] == 'A')) {
		new iLevel;
		new i;
		new iMaxLevel;

		iLevel = str_to_num(sArg2);
		iMaxLevel = 0;

		for(i = 1; i <= MaxClients; ++i) {
			if(sArg1[0] == '@' && sArg1[1] == 'P') {
				if(!g_IsConnected[i]) {
					continue;
				}
			} else if(sArg1[0] == '@' && sArg1[1] == 'A') {
				if(!g_IsAlive[i]) {
					continue;
				}
			}

			if((g_Level[i] + iLevel) >= MAX_LEVEL) {
				iMaxLevel = 1;

				g_Level[i] = MAX_LEVEL;

				checkXPEquation(i);
				continue;
			}

			g_Level[i] += iLevel;
			checkXPEquation(i);
		}

		if(iMaxLevel) {
			clientPrintColor(0, _, "!t%s!y le ha dado a todos los usuarios %s !g%d nivel%s!y. Exceptuando a algunos que han superado el máximo de nivel permitido", g_PlayerName[id], ((sArg1[0] == '@' && sArg1[1] == 'P') ? "conectados" : "vivos"), iLevel, ((iLevel != 1) ? "es" : ""));
		} else {
			clientPrintColor(0, _, "!t%s!y le ha dado a todos los usuarios %s !g%d nivel%s!y", g_PlayerName[id], ((sArg1[0] == '@' && sArg1[1] == 'P') ? "conectados" : "vivos"), iLevel, ((iLevel != 1) ? "es" : ""));
		}
	} else {
		new iTarget;
		new iLevel;

		iTarget = cmd_target(id, sArg1, 0);
		iLevel = str_to_num(sArg2);

		if(iTarget) {
			new iLastLevel;
			iLastLevel = g_Level[iTarget];
			
			switch(sArg2[0]) {
				case '+': {
					g_Level[iTarget] += iLevel;
					
					clientPrintColor(iTarget, _, "!t%s!y te ha dado !g%d nivel%s!y", g_PlayerName[id], iLevel, ((iLevel != 1) ? "es" : ""));
					
					checkXPEquation(iTarget);
				} default: {
					g_Level[iTarget] = iLevel;
					
					clientPrintColor(iTarget, _, "!t%s!y te ha editado tus !gniveles!y, ahora tenés !g%d nivel%s!y", g_PlayerName[id], iLevel, ((iLevel != 1) ? "es" : ""));
					
					checkXPEquation(iTarget);
				}
			}
			
			consolePrint(id, "%s tenía %d nivel%s y ahora tiene %d", g_PlayerName[iTarget], iLastLevel, ((iLastLevel != 1) ? "es" : ""), g_Level[iTarget]);
		} else {
			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp8_pjs.acc_id, zp8_pjs.level FROM zp8_pjs LEFT JOIN zp8_accounts ON zp8_pjs.acc_id=zp8_accounts.id WHERE zp8_accounts.name=^"%s^";", sArg1);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 5);
			} else if(SQL_NumResults(sqlQuery)) {
				new iId = SQL_ReadResult(sqlQuery, 0);
				new iDataBaseLevel = SQL_ReadResult(sqlQuery, 1);
				new iTotal;

				iTotal = (iLevel + iDataBaseLevel);

				if(iTotal >= MAX_LEVEL) {
					iTotal = MAX_LEVEL;
				}

				SQL_FreeHandle(sqlQuery);

				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_pjs SET level='%d' WHERE acc_id='%d';", iTotal, iId);

				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 6);
				} else {
					SQL_FreeHandle(sqlQuery);
				}
			} else {
				consolePrint(id, "No se ha encontrado al jugador especificado en la base de datos");
				SQL_FreeHandle(sqlQuery);
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public clcmd__Reset(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new sArg2[8];
	new iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sArg2, charsmax(sArg2));
	iTarget = cmd_target(id, sArg1, 0);
	
	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_reset <nombre> <factor, + o nada (setear)> <cantidad>");
		return PLUGIN_HANDLED;
	}

	new iReset;
	iReset = str_to_num(sArg2);

	if(iTarget) {
		new iLastReset;
		iLastReset = g_Reset[iTarget];
		
		switch(sArg2[0]) {
			case '+': {
				g_Reset[iTarget] += iReset;
				
				clientPrintColor(iTarget, _, "!t%s!y te ha dado !g%d reset%s!y", g_PlayerName[id], iReset, ((iReset != 1) ? "s" : ""));
				
				checkXPEquation(iTarget);
			} default: {
				g_Reset[iTarget] = iReset;
				
				clientPrintColor(iTarget, _, "!t%s!y te ha editado tus !gresets!y, ahora tenés !g%d reset%s!y", g_PlayerName[id], iReset, ((iReset != 1) ? "s" : ""));
				
				checkXPEquation(iTarget);
			}
		}
		
		consolePrint(id, "%s tenía %d reset%s y ahora tiene %d", g_PlayerName[iTarget], iLastReset, ((iLastReset != 1) ? "s" : ""), g_Reset[iTarget]);
	} else {
		new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp8_pjs.acc_id, zp8_pjs.reset FROM zp8_pjs LEFT JOIN zp8_accounts ON zp8_pjs.acc_id=zp8_accounts.id WHERE zp8_accounts.name=^"%s^";", sArg1);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 7);
		} else if(SQL_NumResults(sqlQuery)) {
			new iId = SQL_ReadResult(sqlQuery, 0);
			new iDataBaseReset = SQL_ReadResult(sqlQuery, 1);
			new iTotal;

			iTotal = (iReset + iDataBaseReset);

			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_pjs SET reset='%d' WHERE acc_id='%d';", iTotal, iId);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 8);
			} else {
				SQL_FreeHandle(sqlQuery);
			}
		} else {
			consolePrint(id, "No se ha encontrado al jugador especificado en la base de datos");
			SQL_FreeHandle(sqlQuery);
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__Points(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId) {
		return PLUGIN_HANDLED;
	}

	new sArg2[16];
	new sArg3[2];

	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));

	if(read_argc() < 3) {
		consolePrint(id, "Uso: zp_points <nombre> <factor (+ , -)> <cantidad> <clase (H, Z, E, L, D)>");
		return PLUGIN_HANDLED;
	}

	new iPoints;
	new iClass;

	iPoints = str_to_num(sArg2);
	iClass = -1;

	switch(sArg3[0]) {
		case 'H': {
			iClass = P_HUMAN;
		} case 'Z': {
			iClass = P_ZOMBIE;
		} case 'L': {
			iClass = P_LEGACY;
		} case 'M': {
			iClass = P_MONEY;
		} case 'D': {
			iClass = P_DIAMONDS;
		} case 'R': {
			iClass = P_RESET;
		}
	}

	switch(sArg2[0]) {
		case '+', '-': {
			if(iClass >= 0) {
				g_Points[iUserId][iClass] += iPoints;

				clientPrintColor(iUserId, _, "!t%s!y te ha %s !g%d p%c!y", g_PlayerName[id], ((sArg2[0] == '+') ? "dado" : "sacado"), iPoints, sArg3[0]);
				return PLUGIN_HANDLED;
			} else {
				for(new i = 0; i < structIdPoints; ++i) {
					g_Points[iUserId][i] += iPoints;
				}

				clientPrintColor(iUserId, _, "!t%s!y te ha %s !g%d pHZLMDR!y", g_PlayerName[id], ((sArg2[0] == '+') ? "dado" : "sacado"), iPoints);
			}
		} default: {
			if(iClass >= 0) {
				g_Points[iUserId][iClass] = iPoints;
				
				clientPrintColor(iUserId, _, "!t%s!y te ha editado tus !gp%c!y, ahora tenés !g%d p%c!y", g_PlayerName[id], sArg3[0], iPoints, sArg3[0]);
				return PLUGIN_HANDLED;
			} else {
				for(new i = 0; i < structIdPoints; ++i) {
					g_Points[iUserId][i] = iPoints;
				}

				clientPrintColor(iUserId, _, "!t%s!y te ha editado tus !gpHZLMDR!y, ahora tenés !g%d pHZLMDR!y", g_PlayerName[id], iPoints);
			}
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__Hats(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new sHat[8];
	new iUserId;
	new iHat;

	read_argv(1, sArg1, charsmax(sArg1));
	read_argv(2, sHat, charsmax(sHat));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId) {
		return PLUGIN_HANDLED;
	}

	if(read_argc() < 3) {
		new i;
		for(i = 0; i < structIdHats; ++i) {
			consolePrint(id, "%d = %s", i, __HATS[i][hatName]);
		}

		return PLUGIN_HANDLED;
	}

	iHat = str_to_num(sHat);

	if(iHat < 0 || iHat > (structIdHats - 1)) {
		consolePrint(id, "El gorro que intentas dar es invalido");
		return PLUGIN_HANDLED;
	}

	giveHat(iUserId, iHat);
	return PLUGIN_HANDLED;
}

public clcmd__Respawn(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	if(task_exists(TASK_VIRUST) || g_EndRound) {
		consolePrint(id, "No puedes lanzar modo o convertir a un usuario en este momento");
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId) {
		return PLUGIN_HANDLED;
	}

	respawnUserManually(iUserId);

	clientPrintColor(0, _, "!t%s!y revivió a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
	return PLUGIN_HANDLED;
}

public clcmd__Zombie(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		return PLUGIN_HANDLED;
	}

	new iUserId;
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId) {
		return PLUGIN_HANDLED;
	}

	if(g_Zombie[iUserId]) {
		clientPrintColor(0, iUserId, "!t%s!y convirtió a !g%s!y en !gHUMANO!y", g_PlayerName[id], g_PlayerName[iUserId]);
		humanMe(iUserId);
	} else {
		clientPrintColor(0, iUserId, "!t%s!y convirtió a !g%s!y en !gZOMBIE!y", g_PlayerName[id], g_PlayerName[iUserId]);
		zombieMe(iUserId);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Survivor(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_SURVIVOR][modeUsersNeed] && iUsersAlive < __MODES[MODE_SURVIVOR][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tSURVIVOR!y", __MODES[MODE_SURVIVOR][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_SURVIVOR] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		
		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gSURVIVOR!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_SURVIVOR, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_SURVIVOR];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gSURVIVOR!y", g_PlayerName[id], g_PlayerName[iUserId]);
			humanMe(iUserId, .survivor=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gSURVIVOR!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_SURVIVOR, iUserId);
		}
	}

	logToFileModes(id, MODE_SURVIVOR, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Wesker(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_WESKER][modeUsersNeed] && iUsersAlive < __MODES[MODE_WESKER][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tWESKER!y", __MODES[MODE_WESKER][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_WESKER] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gWESKER!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_WESKER, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_WESKER];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gWESKER!y", g_PlayerName[id], g_PlayerName[iUserId]);
			humanMe(iUserId, .wesker=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gWESKER!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_WESKER, iUserId);
		}
	}

	logToFileModes(id, MODE_WESKER, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Leatherface(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_LEATHERFACE][modeUsersNeed] && iUsersAlive < __MODES[MODE_LEATHERFACE][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tLEATHERFACE!y", __MODES[MODE_LEATHERFACE][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_LEATHERFACE] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gLEATHERFACE!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_LEATHERFACE, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_LEATHERFACE];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gLEATHERFACE!y", g_PlayerName[id], g_PlayerName[iUserId]);
			humanMe(iUserId, .leatherface=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gLEATHERFACE!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_LEATHERFACE, iUserId);
		}
	}

	logToFileModes(id, MODE_LEATHERFACE, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Nemesis(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_NEMESIS][modeUsersNeed] && iUsersAlive < __MODES[MODE_NEMESIS][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tNEMESIS!y", __MODES[MODE_NEMESIS][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_NEMESIS] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gNEMESIS!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_NEMESIS, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_NEMESIS];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			g_NextMode = g_CurrentMode;

			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gNEMESIS!y", g_PlayerName[id], g_PlayerName[iUserId]);
			zombieMe(iUserId, .nemesis=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gNEMESIS!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_NEMESIS, iUserId);
		}
	}

	logToFileModes(id, MODE_NEMESIS, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Cabezon(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_CABEZON][modeUsersNeed] && iUsersAlive < __MODES[MODE_CABEZON][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tCABEZON!y", __MODES[MODE_CABEZON][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_CABEZON] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gCABEZÓN!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_CABEZON, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_CABEZON];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			g_NextMode = g_CurrentMode;

			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gCABEZÓN!y", g_PlayerName[id], g_PlayerName[iUserId]);
			zombieMe(iUserId, .cabezon=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gCABEZÓN!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_CABEZON, iUserId);
		}
	}

	logToFileModes(id, MODE_CABEZON, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Grunt(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_GRUNT][modeUsersNeed] && iUsersAlive < __MODES[MODE_GRUNT][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tGRUNT!y", __MODES[MODE_GRUNT][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_GRUNT] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gGRUNT!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_GRUNT, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_GRUNT];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			g_NextMode = g_CurrentMode;

			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gGRUNT!y", g_PlayerName[id], g_PlayerName[iUserId]);
			zombieMe(iUserId, .grunt=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gGRUNT!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_GRUNT, iUserId);
		}
	}

	logToFileModes(id, MODE_GRUNT, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Annihilator(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_ANNIHILATOR][modeUsersNeed] && iUsersAlive < __MODES[MODE_ANNIHILATOR][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tANIQUILADOR!y", __MODES[MODE_ANNIHILATOR][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_ANNIHILATOR] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gANIQUILADOR!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_ANNIHILATOR, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_ANNIHILATOR];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			g_NextMode = g_CurrentMode;
			
			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gANIQUILADOR!y", g_PlayerName[id], g_PlayerName[iUserId]);
			zombieMe(iUserId, .annihilator=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gANIQUILADOR!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_ANNIHILATOR, iUserId);
		}
	}

	logToFileModes(id, MODE_ANNIHILATOR, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Fleshpound(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[MODE_FLESHPOUND][modeUsersNeed] && iUsersAlive < __MODES[MODE_FLESHPOUND][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !tFLESHPOUND!y", __MODES[MODE_FLESHPOUND][modeUsersNeed]);
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0]) {
		if(!g_NewRound || g_EndRound) {
			return PLUGIN_HANDLED;
		} else if(g_EventModes) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "No puedes lanzar modos en horarios de eventos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin[MODE_FLESHPOUND] == 2) {
			if(g_AccountId[id] != 1) {
				consolePrint(id, "Llegaste al límite de modos máximos");
				return PLUGIN_HANDLED;
			}
		} else if(g_ModeCountAdmin_Total == 7) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}

		new iId;
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(!isPlayerValid(iId)) {
			iId = 0;
		}

		clientPrintColor(0, _, "!t%s!y lanzó el modo !gFLESHPOUND!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);
		startModePre(MODE_FLESHPOUND, iId);

		if(g_AccountId[id] != 1) {
			++g_ModeCountAdmin[MODE_FLESHPOUND];
			++g_ModeCountAdmin_Total;
		}
	} else {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			return PLUGIN_HANDLED;
		}

		new iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId) {
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound) {
			g_NextMode = g_CurrentMode;
			
			clientPrintColor(0, _, "!t%s!y convirtió a !g%s!y en !gFLESHPOUND!y", g_PlayerName[id], g_PlayerName[iUserId]);
			zombieMe(iUserId, .fleshpound=1);
		} else {
			clientPrintColor(0, _, "!t%s!y lanzó el modo !gFLESHPOUND!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
			startModePre(MODE_FLESHPOUND, iUserId);
		}
	}

	logToFileModes(id, MODE_FLESHPOUND, 0);
	return PLUGIN_HANDLED;
}

public clcmd__Modes(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new sArg0[32];
	new iMode;

	read_argv(0, sArg0, charsmax(sArg0));
	iMode = MODE_NONE;

	if(equal(sArg0, "zp_infection")) {
		iMode = MODE_INFECTION;
	} else if(equal(sArg0, "zp_plague")) {
		iMode = MODE_PLAGUE;
	} else if(equal(sArg0, "zp_synapsis")) {
		iMode = MODE_SYNAPSIS;
	} else if(equal(sArg0, "zp_mega_synapsis")) {
		iMode = MODE_MEGA_SYNAPSIS;
	} else if(equal(sArg0, "zp_armageddon")) {
		iMode = MODE_ARMAGEDDON;
	} else if(equal(sArg0, "zp_mega_armageddon")) {
		iMode = MODE_MEGA_ARMAGEDDON;
	} else if(equal(sArg0, "zp_gungame")) {
		iMode = MODE_GUNGAME;
	} else if(equal(sArg0, "zp_mega_gungame")) {
		iMode = MODE_MEGA_GUNGAME;
	} else if(equal(sArg0, "zp_drunk")) {
		iMode = MODE_DRUNK;
	} else if(equal(sArg0, "zp_mega_drunk")) {
		iMode = MODE_MEGA_DRUNK;
	} else if(equal(sArg0, "zp_l4d2")) {
		iMode = MODE_L4D2;
	} else if(equal(sArg0, "zp_duel_final")) {
		iMode = MODE_DUEL_FINAL;
	} else if(equal(sArg0, "zp_tribal")) {
		iMode = MODE_TRIBAL;
	}

	if(iMode == MODE_NONE) {
		consolePrint(id, "Hubo un error al lanzar el modo seleccionado");
		return PLUGIN_HANDLED;
	} else if(iMode == MODE_MEGA_ARMAGEDDON || iMode == MODE_GUNGAME || iMode == MODE_MEGA_GUNGAME) {
		if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
			consolePrint(id, "No tienes permisos para lanzar este modo");
			return PLUGIN_HANDLED;
		}
	} else if(g_EventModes) {
		if(g_AccountId[id] != 1) {
			consolePrint(id, "No puedes lanzar modos en horarios de eventos");
			return PLUGIN_HANDLED;
		}
	} else if(g_ModeCountAdmin[iMode] == 2) {
		if(g_AccountId[id] != 1) {
			consolePrint(id, "Llegaste al límite de modos máximos");
			return PLUGIN_HANDLED;
		}
	} else if(g_ModeCountAdmin_Total == 7) {
		if(g_AccountId[id] != 1) {
			consolePrint(id, "Se ha alcanzado la cantidad máxima de modos por mapa");
			return PLUGIN_HANDLED;
		}
	} else if(!g_NewRound || g_EndRound) {
		consolePrint(id, "Debes esperar a que comience una nueva ronda para lanzar un modo");
		return PLUGIN_HANDLED;
	}

	new iUsersAlive;
	iUsersAlive = getUsersAlive();

	if(__MODES[iMode][modeUsersNeed] && iUsersAlive < __MODES[iMode][modeUsersNeed]) {
		consolePrint(id, "No hay jugadores suficientes para lanzar (!g%s!y) el modo !t%s!y", __MODES[iMode][modeUsersNeed], __MODES[iMode][modeName]);
		return PLUGIN_HANDLED;
	}

	if(iMode == MODE_DUEL_FINAL) {
		new sArg1[8];
		new iDuelFinal;

		read_argv(1, sArg1, charsmax(sArg1));
		iDuelFinal = str_to_num(sArg1);

		if(iDuelFinal < 1 || iDuelFinal > 4) {
			consolePrint(id, "");
			consolePrint(id, "El <Id> del duelo final es incorrecto");
			consolePrint(id, "<Id> = DUELO FINAL");
			consolePrint(id, "1 = CUCHILLO");
			consolePrint(id, "2 = AWP");
			consolePrint(id, "3 = HE");
			consolePrint(id, "4 = ONLY HEAD");
			consolePrint(id, "Ejemplo: zp_duel_final 2");
			consolePrint(id, "");

			return PLUGIN_HANDLED;
		}

		g_ModeDuelFinal_Type = iDuelFinal;

		if(g_ModeDuelFinal_Type == 4) {
			g_ModeDuelFinal_TypeOnlyHead = random_num(1, 3);
		}
	} else if(iMode == MODE_GUNGAME) {
		new sArg1[8];
		new iGunGame;

		read_argv(1, sArg1, charsmax(sArg1));
		iGunGame = str_to_num(sArg1);

		if(iGunGame < 0 || iGunGame > 5) {
			consolePrint(id, "");
			consolePrint(id, "El <Id> del gungame es incorrecto");
			consolePrint(id, "<Id> = GUNGAME");
			consolePrint(id, "0 = NORMAL");
			consolePrint(id, "1 = ONLY HEAD");
			consolePrint(id, "2 = SLOW");
			consolePrint(id, "3 = FAST");
			consolePrint(id, "4 = CRAZY");
			consolePrint(id, "5 = CLÁSICO");
			consolePrint(id, "Ejemplo: zp_gungame 3");
			consolePrint(id, "");

			return PLUGIN_HANDLED;
		}

		g_ModeGG_Type = iGunGame;
	}

	g_NextMode = g_CurrentMode;

	clientPrintColor(0, _, "!t%s!y lanzó el modo !g%s!y", g_PlayerName[id], __MODES[iMode][modeName]);
	startModePre(iMode);

	if(g_AccountId[id] != 1) {
		++g_ModeCountAdmin[iMode];
		++g_ModeCountAdmin_Total;
	}

	logToFileModes(id, iMode, 0);
	return PLUGIN_HANDLED;
}

public clcmd__NextMode(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	if(get_pcvar_num(g_pCvar_Delay) == 9999) {
		consolePrint(id, "No puedes utilizar este comando cuando el tiempo de retraso está limitado por el Desarrollador");
		return PLUGIN_HANDLED;
	}

	new sArg1[8];
	new iMode;

	read_argv(1, sArg1, charsmax(sArg1));
	iMode = str_to_num(sArg1);

	if(read_argc() < 2) {
		for(new i = 0; i < structIdModes; ++i) {
			consolePrint(id, "%d = %s", i, __MODES[i][modeName]);
		}

		return PLUGIN_HANDLED;
	}

	if(!(MODE_INFECTION <= iMode <= (structIdModes - 1))) {
		consolePrint(id, "Hubo un error al elegir el próximo modo");
		return PLUGIN_HANDLED;
	}

	g_NextMode = iMode;
	clientPrintColor(0, _, "!t%s!y cambió el próximo modo a !g%s!y", g_PlayerName[id], __MODES[iMode][modeName]);
	
	logToFileModes(id, iMode, 1);
	return PLUGIN_HANDLED;
}

public clcmd__Lighting(const id) {
	if(g_AccountId[id] != 1) {
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

public impulse__FlashLight(const id) {
	if(g_Zombie[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_Mode == MODE_GRUNT) {
		g_ModeGrunt_Flash[id] = !g_ModeGrunt_Flash[id];
	}

	if(g_SpecialMode[id]) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public impulse__Spray(const id) {
	return PLUGIN_HANDLED;
}

public showMenu__Banned(const id) {
	oldmenu_create("\y%s \r-\y %s \r(%s)^n\dby %s", "menu__Banned", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(-1, -1, "\yTU CUENTA HA SIDO BANEADA\r:");
	oldmenu_additem(-1, -1, "\r - \wAdministrador\r:\y %s", g_AccountBanned_StaffName[id]);
	oldmenu_additem(-1, -1, "\r - \wFecha de Inicio\r:\y %s",  getUnixToTime(g_AccountBanned_Start[id], 1));
	oldmenu_additem(-1, -1, "\r - \wFecha de Finalización\r:\y %s", getUnixToTime(g_AccountBanned_Finish[id], 1));
	oldmenu_additem(-1, -1, "\r - \wRazón\r:\y %s^n", g_AccountBanned_Reason[id]);

	oldmenu_additem(0, 0, "\r0.\w Salir del servidor");
	oldmenu_display(id);
}

public menu__Banned(const id, const item) {
	if(item == 0) {
		server_cmd("kick #%d ^"Tu cuenta ha sido baneada. Para consultar sobre la misma, haz la queja en el foro %s^"", get_user_userid(id), __PLUGIN_COMMUNITY_FORUM);
	}
}

public showMenu__LogIn(const id) {
	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__LogIn", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(1, 1, "\r1.\w Registrarse");
	oldmenu_additem(2, 2, "\r2.\w Iniciar sesión^n");

	if(__PLUGIN_UPDATE[0] && __PLUGIN_UPDATE_VERSION[0]) {
		oldmenu_additem(-1, -1, "\wEl día \y%s\w se llevará acabo la actualización a la versión \y%s\w.", __PLUGIN_UPDATE, __PLUGIN_UPDATE_VERSION);
		oldmenu_additem(-1, -1, "\wToda la información de la misma estará en nuestro foro.^n");
	}

	if(g_AccountStatus[id] != STATUS_CHECK_ACCOUNT) {
		if(g_AccountStatus[id] == STATUS_UNREGISTERED) {
			oldmenu_additem(-1, -1, "\wEstado\r:\y Sin registrarse");
		} else if(g_AccountStatus[id] == STATUS_REGISTERED) {
			oldmenu_additem(-1, -1, "\wEstado\r:\y Registrado");
		}
	}

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", __PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__LogIn(const id, const item) {
	if(item == 1) {
		if(g_AccountStatus[id] == STATUS_UNREGISTERED || g_AccountStatus[id] == STATUS_CONFIRM) {
			client_cmd(id, "messagemode INGRESAR_CLAVE");
			clientPrintColor(id, _, "Ingresa la contraseña que va a proteger tu cuenta.");
		} else {
			clientPrintColor(id, _, "Esta cuenta ya está registrada en este servidor.");
			showMenu__LogIn(id);
		}
	} else if(item == 2) {
		if(g_AccountStatus[id] == STATUS_REGISTERED) {
			client_cmd(id, "messagemode INGRESAR_CLAVE");
			clientPrintColor(id, _, "Ingresa la contraseña que protege a tu cuenta.");
		} else {
			clientPrintColor(id, _, "Esta cuenta no está registrada en este servidor.");
			showMenu__LogIn(id);
		}
	}
}

public showMenu__Join(const id) {
	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__Join", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	new sAccount[8];
	new sForum[8];

	addDot(g_AccountId[id], sAccount, charsmax(sAccount));
	addDot(g_AccountVinc[id], sForum, charsmax(sForum));

	if(g_AccountBannedCount[id]) {
		oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s \d(%d ve%s baneado por cuenta)", sAccount, g_AccountBannedCount[id], ((g_AccountBannedCount[id] != 1) ? "ces" : "z"));
	} else {
		oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccount);
	}

	oldmenu_additem(-1, -1, "\wVINCULADO AL FORO\r:\y %s \d(#%s)", ((g_AccountVinc[id]) ? "Si" : "No"), sForum);
	oldmenu_additem(-1, -1, "\wVINCULADO A LA APP\r:\y %s^n", ((g_AccountVincAppMobile[id]) ? "Si" : "No"));

	oldmenu_additem(1, 1, "\r1.\w Entrar a jugar");
	oldmenu_additem(2, 2, "\r2.\w Vincular cuenta^n");

	if(g_AccountId[id] == 1) {
		oldmenu_additem(5, 5, "\r5.\w Ir a espectador^n");
	}

	if(__PLUGIN_UPDATE[0] && __PLUGIN_UPDATE_VERSION[0]) {
		oldmenu_additem(-1, -1, "\wEl día \y%s\w se llevará acabo la actualización a la versión \y%s\w.", __PLUGIN_UPDATE, __PLUGIN_UPDATE_VERSION);
		oldmenu_additem(-1, -1, "\wToda la información de la misma estará en nuestro foro.^n");
	}

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", __PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__Join(const id, const item) {
	if(item == 1) {
		g_AccountStatus[id] = STATUS_PLAYING;
		
		new iTs = getTs();
		new iCTs = getCTs();

		if(iTs > iCTs) {
			rg_join_team(id, TEAM_CT);
		} else {
			rg_join_team(id, TEAM_TERRORIST);
		}

		if(g_Mode == MODE_MEGA_ARMAGEDDON) {
			g_ModeMA_Reward[id] = 2;
			clientPrintColor(id, _, "Cuando comience la segunda fase, renacerás como nemesis. No recibirás recompensa al finalizar el modo");
		} else {
			if(g_Mode == MODE_INFECTION) {
				g_FirstSpawn[id] = 1;
			}

			set_task(1.0, "task__RespawnPlayer", id + TASK_SPAWN);
		}
	} else if(item == 2) {
		showMenu__UserOptions_Vinc(id);
	} else if(item == 5 && g_AccountId[id] == 1) {
		rg_join_team(id, TEAM_SPECTATOR);
	}
}

public showMenu__Game(const id) {
	if(g_BuyStuff[id]) {
		clientPrintColor(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite");
		return;
	}

	oldmenu_create("\y%s - %s \r(%s)^n\wTe falta \y%s XP\w para el nivel %d", "menu__Game", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, g_XPRestHud[id], (g_Level[id] + 1));

	if(!g_MenuPage[id][MENU_PAGE_GAME]) {
		oldmenu_additem(1, 1, "\r1.\w ARMAS");
		oldmenu_additem(2, 2, "\r2.\w ITEMS EXTRAS^n");

		oldmenu_additem(3, 3, "\r3.\w MODELS / DIFICULTADES");
		oldmenu_additem(4, 4, "\r4.\w HABILIDADES");
		oldmenu_additem(5, 5, "\r5.\w LOGROS");
		oldmenu_additem(6, 6, "\r6.\w GRUPO^n");

		oldmenu_additem(7, 8, "\r7.\w OPCIONES DE USUARIO");
		oldmenu_additem(8, 8, "\r8.\w ESTADÍSTICAS");
	} else {
		oldmenu_additem(1, 1, "\r1.\w GORROS");
		oldmenu_additem(2, 2, "\r2.\w AMULETOS^n");

		oldmenu_additem(3, 3, "\r3.\w CABEZAS ZOMBIES");
		oldmenu_additem(4, 4, "\r4.\w VISITAS DIARIAS");
		oldmenu_additem(5, 5, "\r5.\w ARTEFACTOS");
		oldmenu_additem(6, 6, "\r6.\w MAESTRÍA^n");

		if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
			oldmenu_additem(7, 7, "\r7.\w BENEFICIO GRATUITO");
		}

		oldmenu_additem(8, 8, "\r8.\y REGLAS^n");

	}

	oldmenu_additem(9, 9, "^n\r9.\w Siguiente/Atrás");
	oldmenu_additem(0, 0, "\r0.\w Salir");

	oldmenu_display(id);
}

public menu__Game(const id, const item) {
	if(g_BuyStuff[id]) {
		clientPrintColor(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite");
	} else {
		if(!g_MenuPage[id][MENU_PAGE_GAME]) {
			if(item == 1) {
				showMenu__Weapons(id);
			} else if(item == 2) {
				showMenu__ExtraItems(id);
			} else if(item == 3) {
				showMenu__ModelsDifficults(id);
			} else if(item == 4) {
				if(g_MenuPage[id][MENU_PAGE_HAB_CLASSES] < 1) {
					g_MenuPage[id][MENU_PAGE_HAB_CLASSES] = 1;
				}

				showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
			} else if(item == 5) {
				showMenu__AchievementsClasses(id);
			} else if(item == 6) {
				showMenu__Group(id);
			} else if(item == 7) {
				showMenu__UserOptions(id);
			} else if(item == 8) {
				showMenu__Stats(id);
			} else if(item == 9) {
				g_MenuPage[id][MENU_PAGE_GAME] = 1;
				showMenu__Game(id);
			}
		} else {
			if(item == 1) {
				showMenu__Hats(id);
			} else if(item == 2) {
				if(g_AmuletCustomCreated[id]) {
					showMenu__AmuletCustom(id);
				} else {
					showMenu__AmuletCustom(id, 1);
				}
			} else if(item == 3) {
				showMenu__HeadZombies(id);
			} else if(item == 4) {
				showMenu__DailyVisits(id);
			} else if(item == 5) {
				if(g_MenuPage[id][MENU_PAGE_ARTIFACTS] < 1) {
					g_MenuPage[id][MENU_PAGE_ARTIFACTS] = 1;
				}

				showMenu__Artifacts(id, g_MenuPage[id][MENU_PAGE_ARTIFACTS]);
			} else if(item == 6) {
				showMenu__Mastery(id, 0);
			} else if(item == 7) {
				if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
					showMenu__Benefit(id);
				}
			} else if(item == 8) {
				new sTitle[64];
				new sFile[32];
				new sUrl[256];

				formatex(sTitle, charsmax(sTitle), "%s - Reglas", __PLUGIN_NAME);
				formatex(sFile, charsmax(sFile), "rules.html");
				formatex(sUrl, charsmax(sUrl), "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=https://%s/tops/08_zombie_plague/%s^"></head><body><p>Cargando...</p></body></html>", __PLUGIN_COMMUNITY_FORUM, sFile);
				
				show_motd(id, sUrl, sTitle);
			} else if(item == 9) {
				g_MenuPage[id][MENU_PAGE_GAME] = 0;
				showMenu__Game(id);
			}
		}
	}
}

public showMenu__Weapons(const id) {
	oldmenu_create("\yARMAS", "menu__Weapons");

	if(!g_WeaponPrimary_Selection[id] && !g_WeaponSecondary_Selection[id] && !g_WeaponCuaternary_Selection[id] && g_CanBuy[id]) {
		oldmenu_additem(1, 1, "\r1.\w Armas primarias");
	} else if(g_WeaponPrimary_Selection[id] && !g_WeaponSecondary_Selection[id] && !g_WeaponCuaternary_Selection[id] && g_CanBuy[id]) {
		oldmenu_additem(1, 1, "\r1.\w Armas secundarias");
	} else if(g_WeaponPrimary_Selection[id] && g_WeaponSecondary_Selection[id] && !g_WeaponCuaternary_Selection[id] && g_CanBuy[id]) {
		oldmenu_additem(1, 1, "\r1.\w Granadas");
	} else if(!g_CanBuy[id]) {
		oldmenu_additem(1, 1, "\r1.\w Volver a comprar");

		oldmenu_additem(-1, -1, "^n\yNOTA\r:\w Puedes seleccionar tus armas nuevamente para obtenerlos^ncuando renaces como humano^n");
	} else {
		oldmenu_additem(-1, -1, "\d1. Volver a comprar");
	}

	oldmenu_additem(2, 2, "\r2.\w Mis armas^n");

	oldmenu_additem(9, 9, "\r9.\w Recordar compra\r:\y %s", ((g_WeaponAutoBuy[id]) ? "Si" : "No"));
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__Weapons(const id, const item) {
	if(!item) {
		showMenu__Game(id);
	} else if(item == 1) {
		if(!g_WeaponPrimary_Selection[id] && !g_WeaponSecondary_Selection[id] && !g_WeaponCuaternary_Selection[id] && g_CanBuy[id]) {
			showMenu__BuyPrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_BPW]);
		} else if(g_WeaponPrimary_Selection[id] && !g_WeaponSecondary_Selection[id] && !g_WeaponCuaternary_Selection[id] && g_CanBuy[id]) {
			showMenu__BuySecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_BSW]);
		} else if(g_WeaponPrimary_Selection[id] && g_WeaponSecondary_Selection[id] && !g_WeaponCuaternary_Selection[id] && g_CanBuy[id]) {
			showMenu__BuyCuaternaryWeapons(id, g_MenuPage[id][MENU_PAGE_BCW]);
		} else if(!g_CanBuy[id]) {
			g_WeaponAutoBuy[id] = 0;
			g_WeaponPrimary_Selection[id] = 0;
			g_WeaponSecondary_Selection[id] = 0;
			g_WeaponCuaternary_Selection[id] = 0;

			showMenu__BuyPrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_BPW]);
		} else {
			clientPrintColor(id, _, "No puedes comprar armas en este momento");
			showMenu__Weapons(id);
		}
	} else if(item == 2) {
		showMenu__MyWeapons(id, 0, 0);
	} else if(item == 9) {
		g_WeaponAutoBuy[id] = !g_WeaponAutoBuy[id];
		showMenu__Weapons(id);
	}
}

public showMenu__BuyPrimaryWeapons(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__PRIMARY_WEAPONS));
	oldmenu_create("\yARMAS PRIMARIAS \r[%d - %d]\y\R%d / %d", "menu__BuyPrimaryWeapons", (iStart + 1), iEnd, page, iMaxPages);

	if(g_Zombie[id] || g_SpecialMode[id] || !g_CanBuy[id]) {
		oldmenu_additem(-1, -1, "\rPuedes seleccionar tus armas y recordar tu compra para^nobtenerlos cuando respawnees como humano^n");
	}

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_Reset[id] > __PRIMARY_WEAPONS[i][weaponReset] || (g_Reset[id] == __PRIMARY_WEAPONS[i][weaponReset] && g_Level[id] >= __PRIMARY_WEAPONS[i][weaponLevelReq])) {
			oldmenu_additem(j, i, "\r%d.\w %s \y(N: %d - R: %d)", j, __PRIMARY_WEAPONS[i][weaponName], __PRIMARY_WEAPONS[i][weaponLevelReq], __PRIMARY_WEAPONS[i][weaponReset]);
		} else {
			oldmenu_additem(-1, -1, "\d%d. %s \r(N: %d - R: %d)", j, __PRIMARY_WEAPONS[i][weaponName], __PRIMARY_WEAPONS[i][weaponLevelReq], __PRIMARY_WEAPONS[i][weaponReset]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__BuyPrimaryWeapons(const id, const item, const value, page) {
	if(!item || value > sizeof(__PRIMARY_WEAPONS)) {
		showMenu__Weapons(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_BPW] = iNewPage;

		showMenu__BuyPrimaryWeapons(id, iNewPage);
		return;
	}

	if((entity_get_int(id, EV_INT_button) & IN_ATTACK2) && !equal(__PRIMARY_WEAPONS[value][weaponName], __WEAPON_NAMES[__PRIMARY_WEAPONS[value][weaponCSW]])) {
		clientPrintColor(id, _, "El arma !g%s!y ^"reemplaza^" a una !g%s!y", __PRIMARY_WEAPONS[value][weaponName], __WEAPON_NAMES[__PRIMARY_WEAPONS[value][weaponCSW]]);

		showMenu__BuyPrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_BPW]);
		return;
	}

	g_WeaponPrimary_Selection[id] = value;

	showMenu__BuySecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_BSW]);
}

public showMenu__BuySecondaryWeapons(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__SECONDARY_WEAPONS));
	oldmenu_create("\yARMAS SECUNDARIAS \r[%d - %d]\y\R%d / %d", "menu__BuySecondaryWeapons", (iStart + 1), iEnd, page, iMaxPages);

	if(g_Zombie[id] || g_SpecialMode[id] || !g_CanBuy[id]) {
		oldmenu_additem(-1, -1, "\rPuedes seleccionar tus armas y recordar tu compra para^nobtenerlos cuando respawnees como humano^n");
	}

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_Reset[id] > __SECONDARY_WEAPONS[i][weaponReset] || (g_Reset[id] == __SECONDARY_WEAPONS[i][weaponReset] && g_Level[id] >= __SECONDARY_WEAPONS[i][weaponLevelReq])) {
			oldmenu_additem(j, i, "\r%d.\w %s \y(N: %d - R: %d)", j, __SECONDARY_WEAPONS[i][weaponName], __SECONDARY_WEAPONS[i][weaponLevelReq], __SECONDARY_WEAPONS[i][weaponReset]);
		} else {
			oldmenu_additem(-1, -1, "\d%d. %s \r(N: %d - R: %d)", j, __SECONDARY_WEAPONS[i][weaponName], __SECONDARY_WEAPONS[i][weaponLevelReq], __SECONDARY_WEAPONS[i][weaponReset]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__BuySecondaryWeapons(const id, const item, const value, page) {
	if(!item || value > sizeof(__SECONDARY_WEAPONS)) {
		showMenu__Weapons(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_BSW] = iNewPage;

		showMenu__BuySecondaryWeapons(id, iNewPage);
		return;
	}

	if((entity_get_int(id, EV_INT_button) & IN_ATTACK2) && !equal(__SECONDARY_WEAPONS[value][weaponName], __WEAPON_NAMES[__SECONDARY_WEAPONS[value][weaponCSW]])) {
		clientPrintColor(id, _, "El arma !g%s!y ^"reemplaza^" a una !g%s!y", __SECONDARY_WEAPONS[value][weaponName], __WEAPON_NAMES[__SECONDARY_WEAPONS[value][weaponCSW]]);

		showMenu__BuySecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_BSW]);
		return;
	}

	g_WeaponSecondary_Selection[id] = value;
	g_WeaponAutoBuy[id] = 1;

	showMenu__BuyCuaternaryWeapons(id, g_MenuPage[id][MENU_PAGE_BCW]);
}

public showMenu__BuyCuaternaryWeapons(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__GRENADES));
	oldmenu_create("\yGRANADAS \r[%d - %d]\y\R%d / %d", "menu__BuyCuaternaryWeapons", (iStart + 1), iEnd, page, iMaxPages);

	if(g_Zombie[id] || g_SpecialMode[id] || !g_CanBuy[id]) {
		oldmenu_additem(-1, -1, "\rPuedes seleccionar tus armas y recordar tu compra para^nobtenerlos cuando respawnees como humano^n");
	}

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_Reset[id] > __GRENADES[i][grenadeReset] || (g_Reset[id] == __GRENADES[i][grenadeReset] && g_Level[id] >= __GRENADES[i][grenadeLevelReq])) {
			oldmenu_additem(j, i, "\r%d.\w %s \y(N: %d - R: %d)", j, __GRENADES[i][grenadeName], __GRENADES[i][grenadeLevelReq], __GRENADES[i][grenadeReset]);
		} else {
			oldmenu_additem(-1, -1, "\d%d. %s \r(N: %d - R: %d)", j, __GRENADES[i][grenadeName], __GRENADES[i][grenadeLevelReq], __GRENADES[i][grenadeReset]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__BuyCuaternaryWeapons(const id, const item, const value, page) {
	if(!item || value > sizeof(__GRENADES)) {
		showMenu__Weapons(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_BCW] = iNewPage;

		showMenu__BuyCuaternaryWeapons(id, iNewPage);
		return;
	}

	g_WeaponCuaternary_Selection[id] = value;

	if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] || !g_CanBuy[id]) {
		return;
	}

	buyPrimaryWeapon(id, g_WeaponPrimary_Selection[id]);
	buySecondaryWeapon(id, g_WeaponSecondary_Selection[id]);

	if(!task_exists(TASK_START_MODE)) {
		buyCuaternaryWeapon(id, g_WeaponCuaternary_Selection[id]);
	}

	g_CanBuy[id] = 0;
	g_Hat_Devil[id] = 1;
}

public showMenu__MyWeapons(const id, const weapon_id, const weapon_data_id) {
	if(!weapon_id) {
		new iMenuId;
		new i;
		new sItem[64];
		new sPosition[3];

		iMenuId = menu_create("MIS ARMAS\R", "menu__MyWeapons");

		for(i = 0; i < sizeof(__WEAPON_DATA); ++i) {
			sPosition[0] = __WEAPON_DATA[i][weaponDataId];

			formatex(sItem, charsmax(sItem), "%s \y(N: %d)", __WEAPON_DATA[i][weaponDataName], g_WeaponData[id][sPosition[0]][WEAPON_DATA_LEVEL]);

			sPosition[1] = i;
			sPosition[2] = 0;

			menu_additem(iMenuId, sItem, sPosition);
		}

		menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
		menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
		menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

		g_MenuPage[id][MENU_PAGE_MY_WEAPONS] = min(g_MenuPage[id][MENU_PAGE_MY_WEAPONS], (menu_pages(iMenuId) - 1));

		fix_pdata_menu(id);
		ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_MY_WEAPONS]);
	} else {
		new sTitle[32];
		copy(sTitle, charsmax(sTitle), __WEAPON_DATA[weapon_data_id][weaponDataName]);
		strtoupper(sTitle);

		oldmenu_create("\y%s^n\wPuntos disponibles\r:\y %d", "menu__MyWeaponsIn", sTitle, g_WeaponData[id][weapon_id][WEAPON_DATA_POINTS]);

		new sKills[8];
		addDot(g_WeaponData[id][weapon_id][WEAPON_DATA_KILL_DONE], sKills, charsmax(sKills));
		
		if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] != 25) {
			new sDmgLvl[32];
			new sDmgLvlOutPut[32];
			new sDmgLvlNeed[32];
			new sDmgLvlNeedOutPut[32];

			formatex(sDmgLvl, charsmax(sDmgLvl), "%0.0f", (g_WeaponData[id][weapon_id][WEAPON_DATA_DAMAGE_DONE] * DIV_DAMAGE));
			addDotSpecial(sDmgLvl, sDmgLvlOutPut, charsmax(sDmgLvlOutPut));

			formatex(sDmgLvlNeed, charsmax(sDmgLvlNeed), "%0.0f", (__WEAPON_DAMAGE_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]] * DIV_DAMAGE));
			addDotSpecial(sDmgLvlNeed, sDmgLvlNeedOutPut, charsmax(sDmgLvlNeedOutPut));

			oldmenu_additem(-1, -1, "\wDaño hecho\r:\y %s / %s", sDmgLvlOutPut, sDmgLvlNeedOutPut);
		}

		oldmenu_additem(-1, -1, "\wZombies matados\r:\y %s", sKills);
		
		if(g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_DAYS]) {
			oldmenu_additem(-1, -1, "\wTiempo jugado con esta arma\r:\y %d día%s y %d hora%s", g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_DAYS], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_DAYS] != 1) ? "s" : ""), g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS] != 1) ? "s" : ""));
		} else if(g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS]) {
			oldmenu_additem(-1, -1, "\wTiempo jugado con esta arma\r:\y %d hora%s y %d minuto%s", g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS] != 1) ? "s" : ""), g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES] != 1) ? "s" : ""));
		} else {
			oldmenu_additem(-1, -1, "\wTiempo jugado con esta arma\r:\y %d minuto%s", g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES] != 1) ? "s" : ""));
		}

		if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] != 25) {
			new Float:flLevelPercent = ((g_WeaponData[id][weapon_id][WEAPON_DATA_DAMAGE_DONE] * 100.0) / __WEAPON_DAMAGE_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);
			oldmenu_additem(-1, -1, "\wNivel del arma\r:\y %d (%0.2f%%)^n", g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL], flLevelPercent);
		} else {
			oldmenu_additem(-1, -1, "\wNivel del arma\r:\y Máximo^n");
		}

		oldmenu_additem(1, WEAPON_SKILL_DAMAGE, "\r1.\w Daño \y(N: %d)", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_DAMAGE]);
		oldmenu_additem(2, WEAPON_SKILL_SPEED, "\r2.\w Velocidad de Disparo \y(N: %d)", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_SPEED]);
		
		if(weapon_id != CSW_KNIFE) {
			oldmenu_additem(3, WEAPON_SKILL_RECOIL, "\r3.\w Precisión \y(N: %d)", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_RECOIL]);
			oldmenu_additem(4, WEAPON_SKILL_BULLETS, "\r4.\w Balas \y(N: %d)", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_BULLETS]);
			oldmenu_additem(5, WEAPON_SKILL_RELOAD_SPEED, "\r5.\w Velocidad de Recarga \y(N: %d)", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_RELOAD_SPEED]);
		}

		oldmenu_additem(6, WEAPON_SKILL_CRITICAL_PROBABILITY, "\r6.\w Probadilidade de crítico \y(N: %d)", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_CRITICAL_PROBABILITY]);
		
		if(getTotalSkins(weapon_id)) {
			oldmenu_additem(7, 7, "^n\r7.\w Skins \y(%d)", getTotalSkins(weapon_id));
		} else {
			oldmenu_additem(-1, -1, "");
		}

		if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] != 25) {
			if(g_Points[id][P_DIAMONDS] >= __WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]) {
				oldmenu_additem(8, 8, "^n\r8.\w Subir a nivel %d \y(%d Diamantes)", (g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] + 1), __WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);
			} else {
				oldmenu_additem(-1, -1, "^n\d8. Subir a nivel %d \r(%d Diamantes)", (g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] + 1), __WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);
			}
		} else {
			oldmenu_additem(-1, -1, "");
		}

		g_MenuData[id][MENU_DATA_MY_WEAPON_ID] = weapon_id;
		g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID] = weapon_data_id;

		oldmenu_additem(9, 9, "^n\r9.\w Reiniciar puntos");

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__MyWeapons(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_MY_WEAPONS]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Weapons(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[3];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	showMenu__MyWeapons(id, sPosition[0], sPosition[1]);
	return PLUGIN_HANDLED;
}

public menu__MyWeaponsIn(const id, const item, const value) {
	if(!item) {
		showMenu__MyWeapons(id, 0, 0);
	} else {
		new iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
		new iMyWeaponDataId = g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID];
		
		if(item == 7) {
			showMenu__MyWeaponsSkins(id);
		} else if(item == 8) {
			showMenu__StatsWeaponLevelConfirm(id);
		} else if(item == 9) {
			new iReturn = (g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_DAMAGE] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RECOIL] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_BULLETS] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RELOAD_SPEED] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_CRITICAL_PROBABILITY]);

			if(iReturn <= 0) {
				clientPrintColor(id, _, "No tienes habilidades para reiniciar");

				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return;
			}

			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_DAMAGE] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RECOIL] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_BULLETS] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RELOAD_SPEED] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_CRITICAL_PROBABILITY] = 0;

			g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS] += iReturn;

			showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
		} else {
			if(iMyWeaponId == CSW_KNIFE && (value == WEAPON_SKILL_RECOIL || value == WEAPON_SKILL_BULLETS || value == WEAPON_SKILL_RELOAD_SPEED)) {
				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return;
			}

			if(g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS] <= 0) {
				clientPrintColor(id, _, "No tienes puntos suficientes");

				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return;
			}

			if((value == WEAPON_SKILL_SPEED && g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED] >= 5) || (value == WEAPON_SKILL_RELOAD_SPEED && g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RELOAD_SPEED] >= 5) || g_WeaponSkills[id][iMyWeaponId][value] >= 10) {
				clientPrintColor(id, _, "Has alcanzado el límite máximo de la habilidad seleccionada");
				
				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return;
			}

			--g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS];
			++g_WeaponSkills[id][iMyWeaponId][value];

			if(value == WEAPON_SKILL_CRITICAL_PROBABILITY) {
				g_CriticalChance[id] = (g_WeaponSkills[id][iMyWeaponId][value] * 2);
			}

			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_weapons SET level='%d', points='%d', skill_damage='%d', skill_speed='%d', skill_recoil='%d', skill_bullets='%d', skill_reload_speed='%d', skill_critical_probability='%d' WHERE acc_id='%d' AND weapon_id='%d';", g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL], g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_DAMAGE], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RECOIL], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_BULLETS], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RELOAD_SPEED], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_CRITICAL_PROBABILITY], g_AccountId[id], iMyWeaponId);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 10);
			} else {
				SQL_FreeHandle(sqlQuery);
			}

			showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
		}
	}
}

public showMenu__StatsWeaponLevelConfirm(const id) {
	new iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];

	oldmenu_create("\yCONFIRMACIÓN^n\w¿Estás seguro de que quieras gastar %d Diamantes?", "menu__StatsWeaponLevelConfirm",  __WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]]);

	oldmenu_additem(-1, -1, "\wDiamantes\r:\y %d^n", g_Points[id][P_DIAMONDS]);

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

public menu__StatsWeaponLevelConfirm(const id, const item) {
	new iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
	new iMyWeaponDataId = g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID];

	switch(item) {
		case 1: {
			if(g_Points[id][P_DIAMONDS] < __WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]]) {
				clientPrintColor(id, _, "No tienes diamantes suficientes");
				
				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return;
			}

			g_Points[id][P_DIAMONDS] -= __WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]];
			g_PointsLost[id][P_DIAMONDS] += __WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]];
			
			g_WeaponData[id][iMyWeaponId][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
			++g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS];
			++g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL];
			g_WeaponSave[id][iMyWeaponId] = 1;

			if(iMyWeaponId == CSW_KNIFE && g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL] >= 15) {
				giveHat(id, HAT_SPARTAN);
			}

			checkAchievementsWeapons(id, iMyWeaponId);

			clientPrintColor(id, _, "Tu !g%s!y ha subido al !gnivel %d!y", __WEAPON_NAMES[iMyWeaponId], g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]);
			showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
		} case 2: {
			showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
		}
	}
}

public showMenu__MyWeaponsSkins(const id) {
	new iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
	new j;
	new k;

	oldmenu_create("\ySKINS^n\wNA\r:\y Nivel del Arma", "menu__MyWeaponsSkins");

	for(j = 0, k = 1; j < 9; ++j, ++k) {
		if(__WEAPON_MODELS[iMyWeaponId][j][weaponModelLevel] != 99 && __WEAPON_MODELS[iMyWeaponId][j][weaponModelPath][0]) {
			if(g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL] < __WEAPON_MODELS[iMyWeaponId][j][weaponModelLevel]) {
				oldmenu_additem(-1, -1, "\d%d. Skin #%d \r(NA: %d)", k, (j + 1), __WEAPON_MODELS[iMyWeaponId][j][weaponModelLevel]);
			} else {
				if(g_WeaponModel[id][iMyWeaponId] == (j + 1)) {
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

public menu__MyWeaponsSkins(const id, const item, const value) {
	new iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
	new iMyWeaponDataId = g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID];

	if(!item) {
		showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
	} else {
		g_WeaponModel[id][iMyWeaponId] = (value + 1);

		if(g_CurrentWeapon[id] == iMyWeaponId) {
			engclient_cmd(id, __WEAPON_ENT_NAMES[iMyWeaponId]);
			replaceWeaponModels(id, iMyWeaponId);
		}

		showMenu__MyWeaponsSkins(id);
	}
}

public getTotalSkins(const weapon_id) {
	new i;
	new j;
	new iCount = 0;

	for(i = 1; i < 31; ++i) {
		for(j = 0; j < 9; ++j) {
			if(i == weapon_id && __WEAPON_MODELS[i][j][weaponModelLevel] != 99 && __WEAPON_MODELS[i][j][weaponModelPath][0]) {
				++iCount;
			}
		}
	}

	return iCount;
}

public showMenu__ExtraItems(const id) {
	if(!g_IsAlive[id] || g_SpecialMode[id] || g_NewRound || g_EndRound || (g_Mode != MODE_INFECTION && g_Mode != MODE_PLAGUE && g_Mode != MODE_DRUNK)) {
		clientPrintColor(id, _, "No puedes comprar items extras en estas condiciones");

		showMenu__Game(id);
		return;
	}

	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	new iCost;
	new sCost[16];
	new sItemPerUser[24];
	new iValue;
	new sCostMoney[24];

	iMenuId = menu_create("ITEMS EXTRAS\R", "menu__ExtraItems");

	for(i = 0; i < structIdExtraItems; ++i) {
		if(g_Zombie[id] != __EXTRA_ITEMS[i][extraItemTeam]) {
			continue;
		}

		iCost = getExtraItemCost(id, i);
		addDot(iCost, sCost, charsmax(sCost));

		sItemPerUser[0] = EOS;

		if(__EXTRA_ITEMS[i][extraItemLimitUser]) {
			iValue = 0;

			switch(i) {
				case EXTRA_ITEM_INVISIBILITY: {
					TrieGetCell(g_tExtraItem_Invisibility, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_KILL_BOMB: {
					TrieGetCell(g_tExtraItem_KillBomb, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_PIPE_BOMB: {
					TrieGetCell(g_tExtraItem_PipeBomb, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_ANTIDOTE_BOMB: {
					TrieGetCell(g_tExtraItem_AntidoteBomb, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_ANTIDOTE: {
					TrieGetCell(g_tExtraItem_Antidote, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_ZOMBIE_MADNESS: {
					TrieGetCell(g_tExtraItem_ZombieMadness, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_INFECTION_BOMB: {
					TrieGetCell(g_tExtraItem_InfectionBomb, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_REDUCE_DAMAGE: {
					TrieGetCell(g_tExtraItem_ReduceDamage, g_PlayerName[id], iValue);
				} case EXTRA_ITEM_PETRIFICATION: {
					TrieGetCell(g_tExtraItem_Petrification, g_PlayerName[id], iValue);
				}
			}

			if(iValue < 0) {
				iValue = 0;
			}

			formatex(sItemPerUser, charsmax(sItemPerUser), "\w[%d / %d]", iValue, __EXTRA_ITEMS[i][extraItemLimitUser]);
		}

		sCostMoney[0] = EOS;

		if(__EXTRA_ITEMS[i][extraItemMultCount] && g_ExtraItem_Mult[id][i] >= __EXTRA_ITEMS[i][extraItemMultCount]) {
			formatex(sCostMoney, charsmax(sCostMoney), " \r[%d SALDO]", __EXTRA_ITEMS[i][extraItemMult]);
		}

		formatex(sItem, charsmax(sItem), "%s%s %s(%s AmmoPacks)%s %s", ((g_AmmoPacks[id] >= iCost) ? "\w" : "\d"), __EXTRA_ITEMS[i][extraItemName], ((g_AmmoPacks[id] >= iCost) ? "\y" : "\r"), sCost, sCostMoney, sItemPerUser);

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

public menu__ExtraItems(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(!g_IsAlive[id] || g_SpecialMode[id] || g_NewRound || g_EndRound || (g_Mode != MODE_INFECTION && g_Mode != MODE_PLAGUE && g_Mode != MODE_DRUNK) || item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	new iItemId;
	new iCost;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	iCost = getExtraItemCost(id, iItemId);

	if(!iCost) {
		clientPrintColor(id, _, "Hubo un error al querer comprar un Item Extra (!g%s!y)", __EXTRA_ITEMS[iItemId][extraItemName]);

		showMenu__ExtraItems(id);
		return PLUGIN_HANDLED;
	}

	buyExtraItem(id, iItemId, 0);
	return PLUGIN_HANDLED;
}

public showMenu__HabClasses(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, structIdHabsClasses);
	oldmenu_create("\yHABILIDADES \r[%d - %d]\y\R%d / %d^n\d%s", "menu__HabClasses", (iStart + 1), iEnd, page, iMaxPages, __PLUGIN_COMMUNITY_FORUM_SHOP);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s%s", j, __HABS_CLASSES[i][habClassName], ((i == HAB_CLASS_ZOMBIE || i == HAB_CLASS_LEGENDARY || i == HAB_CLASS_ROTATTE) ? "^n" : ""));
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__HabClasses(const id, const item, const value, page) {
	if(!item || value > structIdHabsClasses) {
		showMenu__Game(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_HAB_CLASSES] = iNewPage;

		showMenu__HabClasses(id, iNewPage);
		return;
	}

	if(value == HAB_CLASS_ROTATTE) {
		if(g_MenuPage[id][MENU_PAGE_HAB_ROTATE] < 1) {
			g_MenuPage[id][MENU_PAGE_HAB_ROTATE] = 1;
		}

		showMenu__HabRotate(id, g_MenuPage[id][MENU_PAGE_HAB_ROTATE]);
		return;
	} else if(value == HAB_CLASS_TRADE) {
		showMenu__HabTrade(id);
		return;
	} else if(value == HAB_CLASS_RESET) {
		showMenu__HabReset(id);
		return;
	}

	g_MenuData[id][MENU_DATA_HAB_CLASS_ID] = value;
	showMenu__Habs(id);
}

public showMenu__HabRotate(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, structIdHabsRotate, 6);
	oldmenu_create("\yHABILIDADES ROTATIVAS \r[%d - %d]\y\R%d / %d^n\wSaldo\r:\y %d", "menu__HabRotate", (iStart + 1), iEnd, page, iMaxPages, g_Points[id][P_MONEY]);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(i == g_HabRotate_Week[0] || i == g_HabRotate_Week[1] || i == g_HabRotate_Week[2]) {
			if(g_HabRotate[id][i]) {
				oldmenu_additem(j, i, "\r%d.\d %s \y(ADQUIRIDA)", j, __HABS_ROTATE[i][habRotateName]);
			} else {
				oldmenu_additem(j, i, "\r%d.\w %s", j, __HABS_ROTATE[i][habRotateName]);
			}
		} else {
			oldmenu_additem(-1, -1, "\d%d. %s", j, __HABS_ROTATE[i][habRotateName]);
		}
	}

	oldmenu_additem(7, 7, "^n\r7.\w ¿Qué es esto?");

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__HabRotate(const id, const item, const value, page) {
	if(!item || value > structIdHabsRotate) {
		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_HAB_ROTATE] = iNewPage;

		showMenu__HabRotate(id, iNewPage);
		return;
	} else if(item == 7) {
		g_MenuPage[id][MENU_PAGE_HAB_ROTATE_INFO] = 0;

		showMenu__HabRotate_AboutThis(id);
		return;
	}

	g_MenuData[id][MENU_DATA_HAB_ROTATE_ID] = value;

	showMenu__HabRotate_Info(id);
}

public showMenu__HabRotate_AboutThis(const id) {
	oldmenu_create("\yHABILIDADES ROTATIVAS\r:\w ¿Qué es esto?\y\R%d / 3", "menu__HabRotate_AboutThis", (g_MenuPage[id][MENU_PAGE_HAB_ROTATE_INFO] + 1));

	switch(g_MenuPage[id][MENU_PAGE_HAB_ROTATE_INFO]) {
		case 0: {
			oldmenu_additem(-1, -1, "\wLas habilidades rotativas son elegidas");
			oldmenu_additem(-1, -1, "\wsemanalmente, es decir, cada semana se");
			oldmenu_additem(-1, -1, "\weligirán 3 habilidades y serán");
			oldmenu_additem(-1, -1, "\wcolocadas en el menú para que los");
			oldmenu_additem(-1, -1, "\wjugadores puedan comprarlas mediante");
			oldmenu_additem(-1, -1, "\yPuntos de Legado\w.^n");
		} case 1: {
			oldmenu_additem(-1, -1, "\wEl objetivo es la variación y jugabilidad");
			oldmenu_additem(-1, -1, "\wen cada semana; habrá habilidades tanto para");
			oldmenu_additem(-1, -1, "\whumanos como para zombies. Una vez terminada");
			oldmenu_additem(-1, -1, "\wla semana, las habilidades cambiarán");
			oldmenu_additem(-1, -1, "\wa otras distintas a las anteriores");
			oldmenu_additem(-1, -1, "\wpara la nueva semana.^n");
		} case 2: {
			oldmenu_additem(-1, -1, "\wDichas habilidades, se tendrán que volver");
			oldmenu_additem(-1, -1, "\wa comprar una vez pasada la semana");
			oldmenu_additem(-1, -1, "\wde rotación; solamente se guardarán");
			oldmenu_additem(-1, -1, "\wpara la semana que se obtuvo dicha");
			oldmenu_additem(-1, -1, "\whabilidad. Las habilidades se actualizarán");
			oldmenu_additem(-1, -1, "\wtodos los Martes.^n");
		}
	}

	oldmenu_additem(9, 9, "\r9.\w Siguiente/Atrás");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__HabRotate_AboutThis(const id, const item) {
	if(!item) {
		showMenu__HabRotate(id, g_MenuPage[id][MENU_PAGE_HAB_ROTATE]);
		return;
	} else if(item == 9) {
		++g_MenuPage[id][MENU_PAGE_HAB_ROTATE_INFO];

		if(g_MenuPage[id][MENU_PAGE_HAB_ROTATE_INFO] == 3) {
			g_MenuPage[id][MENU_PAGE_HAB_ROTATE_INFO] = 0;
		}

		showMenu__HabRotate_AboutThis(id);
		return;
	}

	showMenu__HabRotate_AboutThis(id);
}

public showMenu__HabRotate_Info(const id) {
	new iHabRotateId = g_MenuData[id][MENU_DATA_HAB_ROTATE_ID];

	if(!(0 <= iHabRotateId <= (structIdHabsRotate))) {
		showMenu__HabRotate(id, g_MenuPage[id][MENU_PAGE_HAB_ROTATE]);
		return;
	}

	oldmenu_create("\yHABILIDAD ROTATIVA\r:\w %s^n\wSaldo\r:\y %d", "menu__HabRotate_Info", __HABS_ROTATE[iHabRotateId][habRotateName], g_Points[id][P_MONEY]);

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __HABS_ROTATE[iHabRotateId][habRotateInfo]);

	new iCost = __HABS_ROTATE[iHabRotateId][habRotateCost];

	oldmenu_additem(-1, -1, "\yCOSTO\r:");
	oldmenu_additem(-1, -1, "\r - \y+%d SALDO\w^n", iCost);

	if(g_HabRotate[id][iHabRotateId]) {
		oldmenu_additem(-1, -1, "\d1. Habilidad adquirida");
	} else {
		if(g_Points[id][P_MONEY] >= iCost) {
			oldmenu_additem(1, 1, "\r1.\w Comprar habilidad");
		} else {
			oldmenu_additem(-1, -1, "\d1. Comprar habilidad");
		}
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HabRotate_Info(const id, const item) {
	new iHabRotateId = g_MenuData[id][MENU_DATA_HAB_ROTATE_ID];

	if(!item || !(0 <= iHabRotateId <= (structIdHabsRotate))) {
		showMenu__HabRotate(id, g_MenuPage[id][MENU_PAGE_HAB_ROTATE]);
		return;
	}

	switch(item) {
		case 1: {
			if(g_HabRotate[id][iHabRotateId]) {
				clientPrintColor(id, _, "Ya has adquirido esta habilidad");

				showMenu__HabRotate_Info(id);
				return;
			}

			new iCost = __HABS_ROTATE[iHabRotateId][habRotateCost];

			if(g_Points[id][P_MONEY] < iCost) {
				clientPrintColor(id, _, "No tienes dinero suficientes");

				showMenu__HabRotate_Info(id);
				return;
			}

			g_Points[id][P_MONEY] -= iCost;
			g_PointsLost[id][P_MONEY] += iCost;

			g_HabRotate[id][iHabRotateId] = 1;

			clientPrintColor(0, _, "!t%s!y ha desbloqueado la habilidad rotativa !g%s !t[%d SALDO]!y", g_PlayerName[id], __HABS_ROTATE[iHabRotateId][habRotateName], iCost);
			showMenu__HabRotate_Info(id);
		}
	}
}

public showMenu__HabTrade(const id) {
	oldmenu_create("\yCAMBIAR PUNTOS^n\wPodrás canjear puntos a cambio de otro recurso", "menu__HabTrade");

	oldmenu_additem(-1, -1, "\wpH\r:\y %d \r~\w pZ\r:\y %d", g_Points[id][P_HUMAN], g_Points[id][P_ZOMBIE]);
	oldmenu_additem(-1, -1, "\wpL\r:\y %d \r~\w Saldo\r:\y %d^n", g_Points[id][P_LEGACY], g_Points[id][P_MONEY]);

	if(!g_MenuPage[id][MENU_PAGE_HAB_TRADE]) {
		oldmenu_additem(1, 1, "\r1.\w Cambiar \y4 SALDO\w por \y2 pH\w");
		oldmenu_additem(2, 2, "\r2.\w Cambiar \y4 SALDO\w por \y2 pZ\w^n");

		oldmenu_additem(3, 3, "\r3.\w Cambiar \y12 SALDO\w por \y6 pH\w");
		oldmenu_additem(4, 4, "\r4.\w Cambiar \y12 SALDO\w por \y6 pZ\w^n");

		oldmenu_additem(5, 5, "\r5.\w Cambiar \y10 SALDO\w por \y3 pL\w");
		oldmenu_additem(6, 6, "\r6.\w Cambiar \y25 SALDO\w por \y12 pL\w^n");

		oldmenu_additem(9, 9, "\r9.\w Cambiar Puntos de Legado");
	} else {
		oldmenu_additem(1, 1, "\r1.\w Cambiar \y5 pL\w por \y10 pH\w");
		oldmenu_additem(2, 2, "\r2.\w Cambiar \y5 pL\w por \y10 pZ\w^n");

		oldmenu_additem(3, 3, "\r3.\w Cambiar \y15 pL\w por \y30 pH\w");
		oldmenu_additem(4, 4, "\r4.\w Cambiar \y15 pL\w por \y30 pZ\w^n");

		oldmenu_additem(5, 5, "\r5.\w Cambiar \y30 pL\w por \y50 SALDO\w");
		oldmenu_additem(6, 6, "\r6.\w Cambiar \y50 pL\w por \y75 SALDO\w^n");

		oldmenu_additem(9, 9, "\r9.\w Cambiar Saldo");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HabTrade(const id, const item) {
	if(!item) {
		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
	} else {
		if(!g_MenuPage[id][MENU_PAGE_HAB_TRADE]) {
			if(item == 1) {
				if(g_Points[id][P_MONEY] >= 4) {
					g_Points[id][P_HUMAN] += 2;
					g_Points[id][P_MONEY] -= 4;
				}
			} else if(item == 2) {
				if(g_Points[id][P_MONEY] >= 4) {
					g_Points[id][P_ZOMBIE] += 2;
					g_Points[id][P_MONEY] -= 4;
				}
			} else if(item == 3) {
				if(g_Points[id][P_MONEY] >= 12) {
					g_Points[id][P_HUMAN] += 6;
					g_Points[id][P_MONEY] -= 12;
				}
			} else if(item == 4) {
				if(g_Points[id][P_MONEY] >= 12) {
					g_Points[id][P_ZOMBIE] += 6;
					g_Points[id][P_MONEY] -= 12;
				}
			} else if(item == 5) {
				if(g_Points[id][P_MONEY] >= 10) {
					g_Points[id][P_LEGACY] += 3;
					g_Points[id][P_MONEY] -= 10;
				}
			} else if(item == 6) {
				if(g_Points[id][P_MONEY] >= 25) {
					g_Points[id][P_LEGACY] += 12;
					g_Points[id][P_MONEY] -= 25;
				}
			} else if(item == 9) {
				g_MenuPage[id][MENU_PAGE_HAB_TRADE] = 1;
			}
		} else {
			if(item == 1) {
				if(g_Points[id][P_LEGACY] >= 5) {
					g_Points[id][P_HUMAN] += 10;
					g_Points[id][P_LEGACY] -= 5;
				}
			} else if(item == 2) {
				if(g_Points[id][P_LEGACY] >= 5) {
					g_Points[id][P_ZOMBIE] += 10;
					g_Points[id][P_LEGACY] -= 5;
				}
			} else if(item == 3) {
				if(g_Points[id][P_LEGACY] >= 15) {
					g_Points[id][P_HUMAN] += 30;
					g_Points[id][P_LEGACY] -= 15;
				}
			} else if(item == 4) {
				if(g_Points[id][P_LEGACY] >= 15) {
					g_Points[id][P_ZOMBIE] += 30;
					g_Points[id][P_LEGACY] -= 15;
				}
			} else if(item == 5) {
				if(g_Points[id][P_LEGACY] >= 30) {
					g_Points[id][P_MONEY] += 50;
					g_Points[id][P_LEGACY] -= 30;
				}
			} else if(item == 6) {
				if(g_Points[id][P_LEGACY] >= 50) {
					g_Points[id][P_MONEY] += 75;
					g_Points[id][P_LEGACY] -= 50;
				}
			} else if(item == 9) {
				g_MenuPage[id][MENU_PAGE_HAB_TRADE] = 0;
			}
		}

		showMenu__HabTrade(id);
	}
}

public showMenu__Habs(const id) {
	new iHabClassId = g_MenuData[id][MENU_DATA_HAB_CLASS_ID];

	if(!(0 <= iHabClassId <= (structIdHabsClasses - 1))) {
		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
		return;
	}

	oldmenu_create("\yHABILIDAD\r:\w %s^n\w%s\r:\y %d", "menu__Habs", __HABS_CLASSES[iHabClassId][habClassName], __HABS_CLASSES[iHabClassId][habClassPointName], g_Points[id][__HABS_CLASSES[iHabClassId][habClassPointId]]);

	new i;
	new j = 0;
	new iHab = 0;

	for(i = 0; i < structIdHabs; ++i) {
		if(!__HABS[i][habEnabled] || iHabClassId != __HABS[i][habClass]) {
			continue;
		}

		++j;

		if(!__HABS[i][habMaxLevel]) {
			oldmenu_additem(-1, -1, "\d%d. %s \r(Inhabilitado)", j, __HABS[i][habName]);
		} else {
			iHab = getHabLevel(id, iHabClassId, i);
			
			if(iHab >= __HABS[i][habMaxLevel]) {
				oldmenu_additem(j, i, "\r%d.\d %s \r(Full)", j, __HABS[i][habName]);
			} else {
				oldmenu_additem(j, i, "\r%d.\w %s \y(Niv: %d)", j, __HABS[i][habName], iHab);
			}
		}
	}

	if(!j) {
		clientPrintColor(id, _, "No se encontraron habilidades en este menú");

		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
		return;
	}

	if(iHabClassId == HAB_CLASS_HUMAN || iHabClassId == HAB_CLASS_ZOMBIE) {
		oldmenu_additem(-1, -1, "^n\d9. Reiniciar puntos \r(INHABILITADO TEMP.)");
	} else {
		oldmenu_additem(-1, -1, "");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Habs(const id, const item, const value) {
	if(!item) {
		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
		return;
	}

	new iHabClassId = g_MenuData[id][MENU_DATA_HAB_CLASS_ID];

	if((iHabClassId == HAB_CLASS_HUMAN || iHabClassId == HAB_CLASS_ZOMBIE) && item == 9) {
		showMenu__HabsToReset(id, iHabClassId);
		return;
	}

	g_MenuData[id][MENU_DATA_HAB_ID] = value;
	showMenu__HabInfo(id);
}

public showMenu__HabsToReset(const id, const hab_class) {
	oldmenu_create("\yRESETEAR PUNTOS", "menu__HabsToReset");

	oldmenu_additem(-1, -1, "\w¿Estás seguro que quieres resetear tus %s?^n", __HABS_CLASSES[hab_class][habClassPointName]);
	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(0, 0, "\r0.\w No^n");

	oldmenu_additem(-1, -1, "\wCOSTO\r:\y 25 SALDO");
	oldmenu_display(id);
}

public menu__HabsToReset(const id, const item) {
	new iHabClassId = g_MenuData[id][MENU_DATA_HAB_CLASS_ID];

	switch(item) {
		case 1: {
			if(iHabClassId == HAB_CLASS_HUMAN || iHabClassId == HAB_CLASS_ZOMBIE) {
				if(g_Points[id][P_MONEY] >= 25) {
					new iHabs = 0;
					new i;

					for(i = 0; i < structIdHabs; ++i) {
						if(__HABS[i][habClass] == iHabClassId && g_Hab[id][i]) {
							g_Hab[id][i] = 0;
							iHabs = 1;
						}
					}

					if(!iHabs) {
						clientPrintColor(id, _, "No tienes habilidades %s para resetear", __HABS_CLASSES[iHabClassId][habClassName]);

						showMenu__Habs(id);
						return;
					}

					g_Points[id][P_MONEY] -= 25;

					new iTotal = (g_Points[id][__HABS_CLASSES[iHabClassId][habClassPointId]] + g_PointsLost[id][__HABS_CLASSES[iHabClassId][habClassPointId]]);
					new sTotal[16];

					addDot(iTotal, sTotal, charsmax(sTotal));

					g_Points[id][__HABS_CLASSES[iHabClassId][habClassPointId]] = iTotal;
					g_PointsLost[id][__HABS_CLASSES[iHabClassId][habClassPointId]] = 0;

					clientPrintColor(id, _, "Tus habilidades %s fueron reiniciadas. Obtuviste !g%s p%c!y", __HABS_CLASSES[iHabClassId][habClassName], sTotal, ((iHabClassId == HAB_CLASS_HUMAN) ? 'H' : 'Z'));
					showMenu__Habs(id);
				} else {
					clientPrintColor(id, _, "No tienes saldo suficiente para resetear las habilidades %s", __HABS_CLASSES[iHabClassId][habClassName]);
					showMenu__Habs(id);
				}
			} else {
				showMenu__Habs(id);
			}
		} case 0: {
			showMenu__Habs(id);
		}
	}
}

public showMenu__HabInfo(const id) {
	new iHabClassId = g_MenuData[id][MENU_DATA_HAB_CLASS_ID];

	if(!(0 <= iHabClassId <= (structIdHabsClasses - 1))) {
		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
		return;
	}

	new iHabId = g_MenuData[id][MENU_DATA_HAB_ID];

	if(!(0 <= iHabId <= (structIdHabs - 1))) {
		showMenu__Habs(id);
		return;
	}

	new sTitle[32];
	copy(sTitle, charsmax(sTitle), __HABS[iHabId][habName]);
	strtoupper(sTitle);

	oldmenu_create("\y%s (N: %d)^n\w%s\r:\y %d", "menu__HabInfo", sTitle, g_Hab[id][iHabId], __HABS_CLASSES[iHabClassId][habClassPointName], g_Points[id][__HABS_CLASSES[iHabClassId][habClassPointId]]);

	if(g_Hab[id][iHabId] >= __HABS[iHabId][habMaxLevel]) {
		oldmenu_additem(-1, -1, "\d1. Nivel máximo^n");
	} else {
		new iCost = getHabCost(id, iHabId);

		if(g_Points[id][__HABS_CLASSES[iHabClassId][habClassPointId]] >= iCost) {
			oldmenu_additem(1, 1, "\r1.\w Subir habilidad al nivel %d \y[Costo: %d]^n", (g_Hab[id][iHabId] + 1), iCost);
		} else {
			oldmenu_additem(-1, -1, "\d1. Subir habilidad al nivel %d \r[Costo: %d]^n", (g_Hab[id][iHabId] + 1), iCost);
		}
	}

	if(__HABS[iHabId][habInfo][0]) {
		if(iHabId == HAB_L_XP_MULT_IN_COMBO) {
			new sHabInfo[256];
			new sInfo[64];

			copy(sHabInfo, charsmax(sHabInfo), __HABS[iHabId][habInfo]);
			formatex(sInfo, charsmax(sInfo), "%d", (g_Hab[id][iHabId] * __HABS[iHabId][habValue]));

			replace_all(sHabInfo, charsmax(sHabInfo), "[N]", sInfo);
			oldmenu_additem(-1, -1, "\w%s^n", sHabInfo);
		} else {
			oldmenu_additem(-1, -1, "\w%s^n", __HABS[iHabId][habInfo]);
		}
	}

	if((iHabClassId == HAB_CLASS_HUMAN && (HAB_H_HEALTH <= iHabId <= HAB_H_DAMAGE)) || (iHabClassId == HAB_CLASS_ZOMBIE && (HAB_Z_HEALTH <= iHabId <= HAB_Z_DAMAGE))) {
		new iHatId;
		new iAmuletId;

		getHabLevel(id, iHabClassId, iHabId, iHatId, iAmuletId);

		if(iHatId && iAmuletId) {
			if(g_HatId[id] != HAT_NONE) {
				oldmenu_additem(-1, -1, "\r - \wEXTRA POR GORRO\r:\y +%d", iHatId);
			}

			if(g_AmuletCustomCreated[id]) {
				oldmenu_additem(-1, -1, "\r - \wEXTRA POR AMULETO\r:\y +%d", iAmuletId);
			}

			oldmenu_additem(-1, -1, "^n\yNOTA #1\r:^n\r - \wLos puntos de habilidades extras no afectan al costo por nivel de habilidad^n");
		}
		
		if(iHabClassId == HAB_CLASS_HUMAN && (HAB_H_HEALTH <= iHabId <= HAB_H_DAMAGE)) {
			switch(iHabId) {
				case HAB_H_HEALTH: {
					new sInfo[16];

					addDot(humanHealthBase(id), sInfo, charsmax(sInfo));
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %s", sInfo);

					addDot(humanHealthExtra(id), sInfo, charsmax(sInfo));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%s", sInfo);

					addDot(humanHealth(id), sInfo, charsmax(sInfo));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %s^n", sInfo);
				} case HAB_H_SPEED: {
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f", humanSpeedBase(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%0.2f", humanSpeedExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f^n", humanSpeed(id));
				} case HAB_H_GRAVITY: {
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f \d(%d)", humanGravityBase(id), floatround(humanGravityBase(id) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y %0.2f \d(%d)", humanGravityExtra(id), floatround((humanGravityExtra(id)) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f \d(%d)^n", humanGravity(id), floatround(humanGravity(id) * 800.0));
				} case HAB_H_DAMAGE: {
					new sInfo[32];
					new sInfoSpecial[32];

					formatex(sInfo, charsmax(sInfo), "%0.0f", humanDamageBase(id));
					addDotSpecial(sInfo, sInfoSpecial, charsmax(sInfoSpecial));
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %s%%", sInfoSpecial);

					formatex(sInfo, charsmax(sInfo), "%0.0f", humanDamageExtra(id));
					addDotSpecial(sInfo, sInfoSpecial, charsmax(sInfoSpecial));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%s%%", sInfoSpecial);

					formatex(sInfo, charsmax(sInfo), "%0.0f", humanDamage(id));
					addDotSpecial(sInfo, sInfoSpecial, charsmax(sInfoSpecial));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %s%%", sInfoSpecial);
				}
			}

			if(iHabId == HAB_H_DAMAGE) {
				oldmenu_additem(-1, -1, "^n\yNOTA #2\r:^n\r - \wEl daño total se suma al daño normal del arma^n");
			}
		} else if(iHabClassId == HAB_CLASS_ZOMBIE && (HAB_Z_HEALTH <= iHabId <= HAB_Z_DAMAGE)) {
			switch(iHabId) {
				case HAB_Z_HEALTH: {
					new sInfo[16];

					addDot(zombieHealthBase(id), sInfo, charsmax(sInfo));
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %s", sInfo);

					addDot(zombieHealthExtra(id), sInfo, charsmax(sInfo));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%s", sInfo);

					addDot(zombieHealth(id), sInfo, charsmax(sInfo));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %s^n", sInfo);
				} case HAB_Z_SPEED: {
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f", zombieSpeedBase(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%0.2f", zombieSpeedExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f^n", zombieSpeed(id));
				} case HAB_Z_GRAVITY: {
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f \d(%d)", zombieGravityBase(id), floatround(zombieGravityBase(id) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y %0.2f \d(%d)", zombieGravityExtra(id), floatround((zombieGravityExtra(id)) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f \d(%d)^n", zombieGravity(id), floatround(zombieGravity(id) * 800.0));
				} case HAB_Z_DAMAGE: {
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y No tiene");
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%d%%", zombieDamageExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %d%%^n", zombieDamage(id));
				}
			}
		}
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HabInfo(const id, const item) {
	new iHabClassId = g_MenuData[id][MENU_DATA_HAB_CLASS_ID];

	if(!(0 <= iHabClassId <= (structIdHabsClasses - 1))) {
		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
		return;
	}

	new iHabId = g_MenuData[id][MENU_DATA_HAB_ID];

	if(!item || !(0 <= iHabId <= (structIdHabs - 1))) {
		showMenu__Habs(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Hab[id][iHabId] >= __HABS[iHabId][habMaxLevel]) {
				clientPrintColor(id, _, "Alcanzaste al nivel máximo de la habilidad %s", __HABS[iHabId][habName]);

				showMenu__HabInfo(id);
				return;
			}

			new iCost = getHabCost(id, iHabId);

			if(g_Points[id][__HABS_CLASSES[iHabClassId][habClassPointId]] < iCost) {
				clientPrintColor(id, _, "No tienes puntos suficientes");

				showMenu__HabInfo(id);
				return;
			}

			g_Points[id][__HABS_CLASSES[iHabClassId][habClassPointId]] -= iCost;
			g_PointsLost[id][__HABS_CLASSES[iHabClassId][habClassPointId]] += iCost;

			++g_Hab[id][iHabId];

			if(iHabClassId == HAB_CLASS_HUMAN && iHabClassId == HAB_CLASS_ZOMBIE) {
				if(g_Hab[id][HAB_H_SPEED] == __HABS[HAB_H_SPEED][habMaxLevel] && g_Hab[id][HAB_H_GRAVITY] == __HABS[HAB_H_GRAVITY][habMaxLevel] && g_Hab[id][HAB_Z_SPEED] == __HABS[HAB_Z_SPEED][habMaxLevel] && g_Hab[id][HAB_Z_GRAVITY] == __HABS[HAB_Z_GRAVITY][habMaxLevel]) {
					giveHat(id, HAT_SUPER_MAN);
				}
			} else if(iHabClassId == HAB_CLASS_LEGENDARY) {
				if(iHabId == HAB_L_MULT_AMMOPACKS) {
					g_AmmoPacksMult_Legendary[id] = (0.1 * float(g_Hab[id][HAB_L_MULT_AMMOPACKS]));
				} else if(iHabId == HAB_L_MULT_XP) {
					g_XPMult_Legendary[id] = (0.2 * float(g_Hab[id][HAB_L_MULT_XP]));
				} else if(iHabId == HAB_L_WEAPON_LEVEL) {
					new i;
					for(i = 0; i < sizeof(__WEAPON_DATA); ++i) {
						if(g_WeaponData[id][__WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_LEVEL] >= 25) {
							continue;
						}

						g_WeaponData[id][__WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
						++g_WeaponData[id][__WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_LEVEL];
						++g_WeaponData[id][__WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_POINTS];
						g_WeaponSave[id][__WEAPON_DATA[i][weaponDataId]] = 1;

						checkAchievementsWeapons(id, __WEAPON_DATA[i][weaponDataId]);
					}

					clientPrintColor(id, _, "Has aumentado un nivel a todas tus armas");
				}
			}

			clientPrintColor(id, _, "Aumentaste la habilidad !g%s!y al !gnivel %d!y", __HABS[iHabId][habName], g_Hab[id][iHabId]);
			showMenu__HabInfo(id);
		}
	}
}

public showMenu__Artifacts(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, structIdArtifacts);
	oldmenu_create("\yARTEFACTOS \r[%d - %d]\y\R%d / %d^n\wPuedes equiparte hasta dos anillos y dos collares", "menu__Artifacts", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s%s%s", j, __ARTIFACTS[i][artifactName], ((g_ArtifactsEquiped[id][i]) ? " \y(EQUIPADO)" : ""), ((i == 3 || i == 7) ? "^n" : ""));
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__Artifacts(const id, const item, const value, page) {
	if(!item || value > structIdArtifacts) {
		showMenu__Game(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_ARTIFACTS] = iNewPage;

		showMenu__Artifacts(id, iNewPage);
		return;
	}

	g_MenuData[id][MENU_DATA_ARTIFACTS] = value;

	showMenu__ArtifactInfo(id);
}

public showMenu__ArtifactInfo(const id) {
	new iArtifact = g_MenuData[id][MENU_DATA_ARTIFACTS];
	new sPointsOutput[64];

	sPointsOutput[0] = EOS;

	if(__ARTIFACTS[iArtifact][artifactClass] == ARTIFACT_CLASS_BRACELET) {
		new sDiamonds[16];
		new sDiamondsUsed[16];

		addDot(g_PointsInDiamondShow[id], sDiamonds, charsmax(sDiamonds));
		addDot(g_PointsInDiamond[id], sDiamondsUsed, charsmax(sDiamondsUsed));

		formatex(sPointsOutput, charsmax(sPointsOutput), "\wDiamantes en total\r:\y %s \d(Usado: %d)", sDiamonds, sDiamondsUsed);
	} else {
		new sPointsLegacy[16];

		addDot(g_Points[id][P_MONEY], sPointsLegacy, charsmax(sPointsLegacy));
		formatex(sPointsOutput, charsmax(sPointsOutput), "\wSaldo\r:\y %s", sPointsLegacy);
	}

	oldmenu_create("\yARTEFACTO\r:\w %s^n%s", "menu__ArtifactInfo", __ARTIFACTS[iArtifact][artifactName], sPointsOutput);

	switch(__ARTIFACTS[iArtifact][artifactClass]) {
		case ARTIFACT_CLASS_RING: {
			if(g_Artifact[id][iArtifact] == (charsmax(__ARTIFACTS_RANGES) - 1)) {
				oldmenu_additem(-1, -1, "\yAL EQUIPAR TU ANILLO\r:");

				switch(iArtifact) {
					case ARTIFACT_RING_EXTRA_ITEM_COST: {
						oldmenu_additem(-1, -1, "\r - \wEl costo de tus items reduce en un %d%%^n", (g_Artifact[id][iArtifact] * 5));
					} case ARTIFACT_RING_AMMOPACKS: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador de AmmoPacks aumenta en un x%0.2f^n", (float(g_Artifact[id][iArtifact]) * 0.25));
					} case ARTIFACT_RING_XP: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador de XP aumenta en un x%0.2f^n", (float(g_Artifact[id][iArtifact]) * 0.5));
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
					} case ARTIFACT_RING_XP: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador de XP aumenta en un x%0.2f", (float(g_Artifact[id][iArtifact]) * 0.5));
						oldmenu_additem(-1, -1, "\r - \wPróximo nivel\r:\y +x%0.2f^n", ((float(g_Artifact[id][iArtifact]) + 1.0) * 0.5));
					} case ARTIFACT_RING_COMBO: {
						oldmenu_additem(-1, -1, "\r - \wTu multiplicador al ganar combo aumenta en un x%d", ((g_Artifact[id][iArtifact] + 1) * 1));
						oldmenu_additem(-1, -1, "\r - \wPróximo nivel\r:\y +x%d^n", ((g_Artifact[id][iArtifact] + 1) * 1));
					}
				}

				oldmenu_additem(-1, -1, "\yCOSTO DEL ANILLO\r:");
				oldmenu_additem(-1, -1, "\r - \y+%d\w SALDO^n", iCost);

				if(g_Points[id][P_MONEY] >= iCost) {
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
					} case ARTIFACT_NECKLASE_HZ_REWARD: {
						oldmenu_additem(-1, -1, "\r - \wLa recompensa de las cabezas zombies aumenta en un %d%%^n", ((g_Artifact[id][iArtifact] + 1) * 20));
					}
				}

				oldmenu_additem(-1, -1, "\d1. El collar está en su máximo poder");
			} else {
				new iCost;
				new iOk;

				if(iArtifact == ARTIFACT_NECKLASE_DAMAGE || iArtifact == ARTIFACT_NECKLASE_HZ_REWARD) {
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
					} case ARTIFACT_NECKLASE_HZ_REWARD: {
						oldmenu_additem(-1, -1, "\r - \wLa recompensa de las cabezas zombies aumenta en un %d%%", ((g_Artifact[id][iArtifact] + 1) * 20));
						oldmenu_additem(-1, -1, "\r - \wPróximo nivel\r:\y +%d%%^n", ((g_Artifact[id][iArtifact] + 1) * 20));
					}
				}

				oldmenu_additem(-1, -1, "\yCOSTO DEL COLLAR\r:");
				oldmenu_additem(-1, -1, "\r - \y+%d\w SALDO\w^n", iCost);

				if(iOk) {
					if(g_Points[id][P_MONEY] >= iCost) {
						oldmenu_additem(1, 1, "\r1.\w Subir al grado %c", __ARTIFACTS_RANGES[(g_Artifact[id][iArtifact] + 1)]);
					} else {
						oldmenu_additem(-1, -1, "\d1. Subir al grado %c", __ARTIFACTS_RANGES[(g_Artifact[id][iArtifact] + 1)]);
					}
				} else {
					if(g_Points[id][P_MONEY] >= iCost) {
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
				} case ARTIFACT_BRACELET_XP: {
					oldmenu_additem(-1, -1, "\r - \wTu multiplicador de XP aumentará un +x1.0^n");
				} case ARTIFACT_BRACELET_COMBO: {
					oldmenu_additem(-1, -1, "\r - \wTu multiplicador al ganar combo aumentará un +x1^n");
				} case ARTIFACT_BRACELET_POINTS: {
					oldmenu_additem(-1, -1, "\r - \wTu multiplicador de puntos aumentará un +x1^n");
				} case ARTIFACT_BRACELET_DAMAGE: {
					oldmenu_additem(-1, -1, "\r - \wTu daño humano general aumenta un +10%^n");
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

public menu__ArtifactInfo(const id, const item) {
	if(!item) {
		showMenu__Artifacts(id, g_MenuPage[id][MENU_PAGE_ARTIFACTS]);
		return;
	}

	new iArtifact = g_MenuData[id][MENU_DATA_ARTIFACTS];

	switch(item) {
		case 1: {
			if(__ARTIFACTS[iArtifact][artifactClass] != ARTIFACT_CLASS_BRACELET) {
				new iCost;
				new iOk;

				if(__ARTIFACTS[iArtifact][artifactClass] == ARTIFACT_CLASS_NECKLASE) {
					if(iArtifact == ARTIFACT_NECKLASE_DAMAGE || iArtifact == ARTIFACT_NECKLASE_HZ_REWARD) {
						if(g_Artifact[id][iArtifact] == (charsmax(__ARTIFACTS_RANGES) - 1)) {
							clientPrintColor(id, _, "El collar está en su máximo poder");

							showMenu__ArtifactInfo(id);
							return;
						}

						iCost = ((g_Artifact[id][iArtifact] + 1) * __ARTIFACTS[iArtifact][artifactCost]);
						iOk = 1;
					} else {
						if(g_Artifact[id][iArtifact]) {
							clientPrintColor(id, _, "Ya has comprado este collar");

							showMenu__ArtifactInfo(id);
							return;
						}

						iCost = __ARTIFACTS[iArtifact][artifactCost];
						iOk = 0;
					}
				} else {
					if(g_Artifact[id][iArtifact] == (charsmax(__ARTIFACTS_RANGES) - 1)) {
						clientPrintColor(id, _, "El anillo está en su máximo poder");

						showMenu__ArtifactInfo(id);
						return;
					}

					iCost = ((g_Artifact[id][iArtifact] + 1) * __ARTIFACTS[iArtifact][artifactCost]);
					iOk = 1;
				}

				if(g_Points[id][P_MONEY] < iCost) {
					clientPrintColor(id, _, "No tienes dinero suficientes");

					showMenu__ArtifactInfo(id);
					return;
				}

				g_Points[id][P_MONEY] -= iCost;
				g_PointsLost[id][P_MONEY] += iCost;

				if(iOk) {
					++g_Artifact[id][iArtifact];

					clientPrintColor(0, id, "!t%s!y compró el !g%s [!t%c!g]!y por !g%d SALDO!y", g_PlayerName[id], __ARTIFACTS[iArtifact][artifactName], __ARTIFACTS_RANGES[g_Artifact[id][iArtifact]], iCost);
				} else {
					g_Artifact[id][iArtifact] = 1;

					clientPrintColor(0, id, "!t%s!y compró el !g%s!y por !g%d SALDO!y", g_PlayerName[id], __ARTIFACTS[iArtifact][artifactName], iCost);
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

					if(g_ArtifactsEquiped[id][ARTIFACT_RING_XP]) {
						++iCount;
					}

					if(g_ArtifactsEquiped[id][ARTIFACT_RING_COMBO]) {
						++iCount;
					}

					if(iCount >= 2 && !g_ArtifactsEquiped[id][iArtifact]) {
						clientPrintColor(id, _, "Sólo puedes tener dos anillos equipados a la vez");

						showMenu__ArtifactInfo(id);
						return;
					}

					g_ArtifactsEquiped[id][iArtifact] = !g_ArtifactsEquiped[id][iArtifact];
					
					clientPrintColor(id, _, "Has %sequipado el !g%s!y", ((g_ArtifactsEquiped[id][iArtifact]) ? "" : "des"), __ARTIFACTS[iArtifact][artifactName]);
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

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_HZ_REWARD]) {
						++iCount;
					}

					if(iCount >= 2 && !g_ArtifactsEquiped[id][iArtifact]) {
						clientPrintColor(id, _, "Sólo puedes tener dos collares equipados a la vez");

						showMenu__ArtifactInfo(id);
						return;
					}

					g_ArtifactsEquiped[id][iArtifact] = !g_ArtifactsEquiped[id][iArtifact];

					clientPrintColor(id, _, "Has %sequipado el !g%s!y", ((g_ArtifactsEquiped[id][iArtifact]) ? "" : "des"), __ARTIFACTS[iArtifact][artifactName]);
				} case ARTIFACT_CLASS_BRACELET: {
					new iCost = __ARTIFACTS[iArtifact][artifactCost];
					new iNot = 0;

					if((g_PointsInDiamond[id] - iCost) < 0 && !g_ArtifactsEquiped[id][iArtifact]) {
						iNot = __ARTIFACTS[iArtifact][artifactCost];
					}

					if(iNot > 0) {
						clientPrintColor(id, _, "Debes comprar diamantes para poder activar la pulsera deseada");

						showMenu__ArtifactInfo(id);
						return;
					}

					g_ArtifactsEquiped[id][iArtifact] = !g_ArtifactsEquiped[id][iArtifact];

					clientPrintColor(id, _, "Has %sactivado el !g%s!y", ((g_ArtifactsEquiped[id][iArtifact]) ? "" : "des"), __ARTIFACTS[iArtifact][artifactName]);

					if(g_ArtifactsEquiped[id][iArtifact]) {
						g_PointsInDiamond[id] -= iCost;
					} else {
						g_PointsInDiamond[id] += iCost;
					}
				}
			}
		}
	}
}

public showMenu__Mastery(const id, const mastery) {
	if(mastery) {
		static iOk;
		static iCost;
		
		if(g_Mastery[id]) {
			iOk = ((g_Points[id][P_DIAMONDS] < 10) ? 0 : 1);
			iCost = 10;
		} else {
			iOk = 1;
			iCost = 0;
		}

		g_MenuData[id][MENU_DATA_MASTERY] = mastery;

		oldmenu_create("\yMAESTRÍA^n\wLas maestrías proporcionan un \y+x1.0 XP\w", "menu__MasteryIn");

		oldmenu_additem(-1, -1, "\wMaestría elegida\r:\y %s", __MASTERYS[mastery]);
		oldmenu_additem(-1, -1, "\wHorario de efecto\r:\y %s", ((mastery == MASTERY_MORNING) ? "11:00 - 22:59" : "23:00 - 10:59"));

		if(!iCost) {
			oldmenu_additem(-1, -1, "^n\yNOTA\r:^n\r - \wUna vez elegida la maestría, necesitarás \yDIAMANTES\w^npara volver a cambiar");
		}

		oldmenu_additem(1, 1, "^n\r1.%s Elegir esta maestría %s(%d DIAMANTES)", ((!iOk) ? "\d" : "\w"), ((!iOk) ? "\r" : "\y"), iCost);
		oldmenu_additem(0, 0, "\r0.\w Volver");

		oldmenu_display(id);
	} else {
		oldmenu_create("\yELEGIR MAESTRÍA^n\wSelecciona una para más información", "menu__Mastery");

		oldmenu_additem(1, 1, "\r1.%s %s", ((!g_Mastery[id]) ? "\w" : "\d"), ((g_Mastery[id] == MASTERY_MORNING) ? "Elegido" : "Día \y[11:00 a 22:59]"));
		oldmenu_additem(2, 2, "\r2.%s %s", ((!g_Mastery[id]) ? "\w" : "\d"), ((g_Mastery[id] == MASTERY_NIGHT) ? "Elegido" : "Noche \y[23:00 a 10:59]"));

		oldmenu_additem(0, 0, "^n\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__Mastery(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Mastery[id] != MASTERY_MORNING) {
				showMenu__Mastery(id, MASTERY_MORNING);
			} else {
				clientPrintColor(id, _, "Ya has seleccionado esta maestría");
				showMenu__Mastery(id, 0);
			}
		} case 2: {
			if(g_Mastery[id] != MASTERY_NIGHT) {
				showMenu__Mastery(id, MASTERY_NIGHT);
			} else {
				clientPrintColor(id, _, "Ya has seleccionado esta maestría");
				showMenu__Mastery(id, 0);
			}
		}
	}
}

public menu__MasteryIn(const id, const item) {
	if(!item) {
		showMenu__Mastery(id, 0);
		return;
	}

	new iMastery = g_MenuData[id][MENU_DATA_MASTERY];

	switch(item) {
		case 1: {
			if(g_Mastery[id]) {
				if(g_Points[id][P_DIAMONDS] < 10) {
					clientPrintColor(id, _, "No tienes diamantes suficientes para cambiar tu maestria");

					showMenu__Mastery(id, iMastery);
					return;
				}

				g_Points[id][P_DIAMONDS] -= 10;
				g_PointsLost[id][P_DIAMONDS] += 10;

				g_Mastery[id] = iMastery;

				clientPrintColor(id, _, "Has cambiado tu maestría al turno !g%s!y", __MASTERYS[g_Mastery[id]]);
				showMenu__Mastery(id, iMastery);
			} else {
				g_Mastery[id] = iMastery;

				clientPrintColor(id, _, "Has elegido la maestria para el turno !g%s!y", __MASTERYS[g_Mastery[id]]);
				clientPrintColor(id, _, "Ahora para cambiar tu maestría, requerirá !g10 DIAMANTES!y");

				showMenu__Mastery(id, 0);
			}
		}
	}
}

public showMenu__HeadZombies(const id) {
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
		clientPrintColor(id, _, "No tienes cabezas zombies para abrir");

		showMenu__HeadZombies(id);
		return;
	}

	new iPercent = random_num(1, 100);
	new sMessage[64];

	sMessage[0] = EOS;

	switch(value) {
		case HEADZOMBIE_RED: {
			if(iPercent <= 80) {
				new iReward = random_num(5, 20);
				new sReward[16];

				if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_HZ_REWARD]) {
					new iPercent = 0;
					new iTotal = 0;

					switch(g_Artifact[id][ARTIFACT_NECKLASE_HZ_REWARD]) {
						case 1: {
							iPercent = 20;
						} case 2: {
							iPercent = 40;
						} case 3: {
							iPercent = 60;
						} case 4: {
							iPercent = 80;
						}
 					}

 					iTotal = (iPercent * iReward) / 100;
					iReward += iTotal;
				}

				addDot(iReward, sReward, charsmax(sReward));
				formatex(sMessage, charsmax(sMessage), "La cabeza zombie roja tenía !g%s AmmoPack%s!y", sReward, ((iReward != 1) ? "s" : ""));

				g_AmmoPacks[id] += iReward;
				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_GREEN: {
			if(iPercent <= 60) {
				if(iPercent == 20 || iPercent == 30 || iPercent == 40 || iPercent == 50 || iPercent == 60) {
					new iReward = random_num(1, 3);

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_HZ_REWARD]) {
						iReward += g_Artifact[id][ARTIFACT_NECKLASE_HZ_REWARD];
					}

					formatex(sMessage, charsmax(sMessage), "La cabeza zombie verde tenía !g%d nivel%s!y", iReward, ((iReward != 1) ? "es" : ""));
					
					g_Level[id] += iReward;
					checkXPEquation(id);
				} else {
					new iReward = (((xpThisLevel(id, g_Level[id]) - xpThisLevelRest1(id, g_Level[id])) * random_num(30, 90)) / 100);
					new sReward[16];

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_HZ_REWARD]) {
						iReward = (iReward + ((iReward * g_Artifact[id][ARTIFACT_NECKLASE_HZ_REWARD]) / 100));
					}

					addDot(iReward, sReward, charsmax(sReward));
					formatex(sMessage, charsmax(sMessage), "La cabeza zombie verde tenía !g%s XP!y", sReward);
					
					addXP(id, iReward);
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_BLUE: {
			if(g_EventModes) {
				clientPrintColor(id, _, "No podes abrir cabezas azules mientras haya un mini evento activado");

				showMenu__HeadZombies(id);
				return;
			} else if(!g_NewRound || g_EndRound) {
				clientPrintColor(id, _, "Las cabezas zombie azules solo se pueden romper antes de que comience un modo");

				showMenu__HeadZombies(id);
				return;
			}

			if(iPercent <= 40) {
				new iEIRandom = random_num(1, 5);

				switch(iEIRandom) {
					case 1: {
						buyExtraItem(id, EXTRA_ITEM_NVISION, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gVisión nocturna!y");
					} case 2: {
						buyExtraItem(id, EXTRA_ITEM_LJ_H, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gLong Jump!y");
					} case 3: {
						buyExtraItem(id, EXTRA_ITEM_INVISIBILITY, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gInvisibilidad!y");
					} case 4: {
						buyExtraItem(id, EXTRA_ITEM_UNLIMITED_CLIP, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gBalas infinitas!y");
					} case 5: {
						buyExtraItem(id, EXTRA_ITEM_PRESICION_PERFECT, 1);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gPrecisión perfecta!y");
					} case 6: {
						set_user_armor(id, 100);
						formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !g+100 de Chaleco!y");
					}
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_YELLOW: {
			if(iPercent <= 20) {
				if(iPercent == 10 || iPercent == 20) {
					new iReward = random_num(1, 5);

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_HZ_REWARD]) {
						iReward += g_Artifact[id][ARTIFACT_NECKLASE_HZ_REWARD];
					}

					formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pL!y", iReward);

					g_Points[id][P_LEGACY] += iReward;
				} else {
					new iRewardPoint = random_num(1, 3);
					new iReward = random_num(1, 5);

					if(g_ArtifactsEquiped[id][ARTIFACT_NECKLASE_HZ_REWARD]) {
						iReward += g_Artifact[id][ARTIFACT_NECKLASE_HZ_REWARD];
					}

					switch(iRewardPoint) {
						case 1: {
							formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pH!y", iReward);
							g_Points[id][P_HUMAN] += iReward;
						} case 2: {
							formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pZ!y", iReward);
							g_Points[id][P_ZOMBIE] += iReward;
						} case 3: {
							formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d SALDO!y", iReward);
							g_Points[id][P_MONEY] += iReward;
						}
					}
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
			} else {
				formatex(sMessage, charsmax(sMessage), "%s", __HEADZOMBIES_MESSAGES[random_num(0, charsmax(__HEADZOMBIES_MESSAGES))]);
				++g_HeadZombie_BadLuckBrian[id];
			}
		} case HEADZOMBIE_VIOLET_SMALL: {
			if(g_HeadZombie[id][HEADZOMBIE_VIOLET_SMALL] < 10) {
				clientPrintColor(id, _, "Necesitas diez cabezas zombie violetas chicas para poder crear una grande");

				showMenu__HeadZombies(id);
				return;
			}

			g_HeadZombie[id][HEADZOMBIE_VIOLET_SMALL] -= 10;
			++g_HeadZombie[id][HEADZOMBIE_VIOLET_BIG];

			if(g_HeadZombie[id][HEADZOMBIE_VIOLET_BIG] >= 5) {
				setAchievement(id, CINCO_DE_LAS_GRANDES);
			}

			clientPrintColor(id, _, "Has creado una cabeza zombie grande violeta");
			return;
		} case HEADZOMBIE_VIOLET_BIG: {
			if(g_EventModes) {
				clientPrintColor(id, _, "No podes abrir cabezas violetas grandes mientras haya un mini evento activado");

				showMenu__HeadZombies(id);
				return;
			} else if(!g_NewRound || g_EndRound) {
				clientPrintColor(id, _, "Las cabezas zombie violetas grandes solo se pueden romper antes de que comience un modo");

				showMenu__HeadZombies(id);
				return;
			}

			new Float:flGameTime = get_gametime();

			if(g_HeadZombie_SysTime > flGameTime) {
				new Float:flRest = (g_HeadZombie_SysTime - flGameTime);

				clientPrintColor(id, _, "Debes esperar !g%0.2f segundo%s!y para volver a abrir una cabeza zombie violeta grande", flRest, ((flRest != 1.0) ? "s" : ""));
				
				showMenu__HeadZombies(id);
				return;
			}

			if(getUsersAlive() < 20) {
				clientPrintColor(id, _, "Tiene que haber !g20 o más!y jugadores vivos para romper estas cabezas");
				
				showMenu__HeadZombies(id);
				return;
			}

			if(iPercent <= 75) {
				iPercent = random_num(1, 6);

				switch(iPercent) {
					case 1: {
						clientPrintColor(0, _, "!t%s!y abrió una cabeza zombie Violeta grande y le salió !gCABEZÓN!y", g_PlayerName[id]);
						startModePre(MODE_CABEZON, id);
					} case 2: {
						clientPrintColor(0, _, "!t%s!y abrió una cabeza zombie Violeta grande y le salió !gSURVIVOR!y", g_PlayerName[id]);
						startModePre(MODE_SURVIVOR, id);
					} case 3: {
						clientPrintColor(0, _, "!t%s!y abrió una cabeza zombie Violeta grande y le salió !gNEMESIS!y", g_PlayerName[id]);
						startModePre(MODE_NEMESIS, id);
					} case 4: {
						clientPrintColor(0, _, "!t%s!y abrió una cabeza zombie Violeta grande y le salió !gANIQUILADOR!y", g_PlayerName[id]);
						startModePre(MODE_ANNIHILATOR, id);
					} case 5: {
						clientPrintColor(0, _, "!t%s!y abrió una cabeza zombie Violeta grande y le salió !gLEATHERFACE!y", g_PlayerName[id]);
						startModePre(MODE_LEATHERFACE, id);
					} case 6: {
						clientPrintColor(0, _, "!t%s!y abrió una cabeza zombie Violeta grande y le salió !gWESKER!y", g_PlayerName[id]);
						startModePre(MODE_WESKER, id);
					}
				}

				g_HeadZombie_BadLuckBrian[id] = 0;
				g_HeadZombie_SysTime = (get_gametime() + 600.0);
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

public showMenu__UserOptions(const id) {
	oldmenu_create("\yOPCIONES DE USUARIO", "menu__UserOptions");

	oldmenu_additem(1, 1, "\r1.\w Elegir color^n");

	oldmenu_additem(2, 2, "\r2.\w Opciones de HUD General");
	oldmenu_additem(3, 3, "\r3.\w Opciones de HUD Combo");
	oldmenu_additem(4, 4, "\r4.\w Opciones de Chat^n");

	oldmenu_additem(5, 5, "\r5.\w Activadores");
	oldmenu_additem(6, 6, "\r6.\w Vincular cuenta^n");

	oldmenu_additem(9, 9, "\r9.\w Guardar configuración");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__UserOptions(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_MenuPage[id][MENU_PAGE_COLOR_CHOOSEN] < 1) {
				g_MenuPage[id][MENU_PAGE_COLOR_CHOOSEN] = 1;
			}

			showMenu__UserOptions_ColorChoosen(id, g_MenuPage[id][MENU_PAGE_COLOR_CHOOSEN]);
		} case 2: {
			showMenu__UserOptions_Hud(id, HUD_TYPE_GENERAL);
		} case 3: {
			showMenu__UserOptions_Hud(id, HUD_TYPE_COMBO);
		} case 4: {
			showMenu__UserOptions_Chat(id);
		} case 5: {
			showMenu__UserOptions_Active(id);
		} case 6: {
			showMenu__UserOptions_Vinc(id);
		} case 9: {
			new Float:flGameTime = get_gametime();

			if(g_SaveConfig_SysTime[id] > flGameTime) {
				new Float:flRest = (g_SaveConfig_SysTime[id] - flGameTime);

				clientPrintColor(id, _, "Debes esperar !g%0.2f segundo%s!y para volver a guardar tu configuración", flRest, ((flRest != 1.0) ? "s" : ""));
				
				showMenu__UserOptions(id);
				return;
			}

			new sColorHudGeneral[16];
			new sColorHudCombo[16];
			new sColorNVision[16];
			new sColorFlare[16];
			new sColorGroupGlow[16];
			new sHudGeneralPosition[64];
			new sHudComboPosition[64];
			new Handle:sqlQuery;

			arrayToString(g_UserOptions_Color[id][COLOR_TYPE_HUD_GENERAL], 3, sColorHudGeneral, charsmax(sColorHudGeneral), 1);
			arrayToString(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO], 3, sColorHudCombo, charsmax(sColorHudCombo), 1);
			arrayToString(g_UserOptions_Color[id][COLOR_TYPE_NVISION], 3, sColorNVision, charsmax(sColorNVision), 1);
			arrayToString(g_UserOptions_Color[id][COLOR_TYPE_FLARE], 3, sColorFlare, charsmax(sColorFlare), 1);
			arrayToString(g_UserOptions_Color[id][COLOR_TYPE_GROUP_GLOW], 3, sColorGroupGlow, charsmax(sColorGroupGlow), 1);
			formatex(sHudGeneralPosition, charsmax(sHudGeneralPosition), "%0.2f %0.2f %0.2f", g_UserOptions_Hud[id][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[id][HUD_TYPE_GENERAL][1], g_UserOptions_Hud[id][HUD_TYPE_GENERAL][2]);
			formatex(sHudComboPosition, charsmax(sHudComboPosition), "%0.2f %0.2f %0.2f", g_UserOptions_Hud[id][HUD_TYPE_COMBO][0], g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_Hud[id][HUD_TYPE_COMBO][2]);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_pjs SET color_hud_general=^"%s^", color_hud_combo=^"%s^", color_nvision=^"%s^", color_flare=^"%s^", color_crew_glow=^"%s^", hud_general_position=^"%s^", hud_general_effect='%d', hud_general_style='%d', hud_combo_position=^"%s^", hud_combo_effect='%d', hud_combo_style='%d', uo_nvision='%d', uo_chatmode='%d', uo_invis='%d', uo_crew_glow='%d', uo_current_mode='%d' WHERE acc_id='%d';", sColorHudGeneral, sColorHudCombo, sColorNVision, sColorFlare, sColorGroupGlow, sHudGeneralPosition, g_UserOptions_HudEffect[id][HUD_TYPE_GENERAL], g_UserOptions_HudStyle[id][HUD_TYPE_GENERAL], sHudComboPosition, g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], g_UserOptions_HudStyle[id][HUD_TYPE_COMBO], g_UserOptions_NVision[id], g_UserOptions_ChatMode[id], g_UserOptions_Invis[id], g_UserOptions_GroupGlow[id], g_UserOptions_CurrentMode[id], g_AccountId[id]);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 9);
			} else {
				SQL_FreeHandle(sqlQuery);
			}

			g_SaveConfig_SysTime[id] = (flGameTime + 45.0);

			clientPrintColor(id, _, "Has guardado tu configuración con éxito");
			showMenu__UserOptions(id);
		}
	}
}

public showMenu__UserOptions_Active(const id) {
	oldmenu_create("\yACTIVADORES", "menu__UserOptions_Active");

	oldmenu_additem(1, 1, "\r1.\w Visión nocturna\r:\y %s", ((g_UserOptions_NVision[id]) ? "Si" : "No"));

	switch(g_UserOptions_Invis[id]) {
		case 0: {
			oldmenu_additem(2, 2, "\r2.\w Humanos invisibles\r:\y No");
		} case 1: {
			oldmenu_additem(2, 2, "\r2.\w Humanos invisibles\r:\y Si");
		} case 2: {
			oldmenu_additem(2, 2, "\r2.\w Humanos invisibles\r:\y Si \d[Grupo]");
		}
	}

	oldmenu_additem(3, 3, "\r3.\w Glow del grupo\r:\y %s", ((g_UserOptions_GroupGlow[id]) ? "Si" : "No"));
	oldmenu_additem(4, 4, "\r4.\w Mostrar modo actual como HUD\r:\y %s^n", ((g_UserOptions_CurrentMode[id]) ? "Si" : "No"));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__UserOptions_Active(const id, const item) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	switch(item) {
		case 1: {
			g_UserOptions_NVision[id] = !g_UserOptions_NVision[id];
			showMenu__UserOptions_Active(id);
		} case 2: {
			++g_UserOptions_Invis[id];

			if(g_UserOptions_Invis[id] == 3) {
				g_UserOptions_Invis[id] = 0;
			}

			showMenu__UserOptions_Active(id);
		} case 3: {
			g_UserOptions_GroupGlow[id] = !g_UserOptions_GroupGlow[id];
			showMenu__UserOptions_Active(id);
		} case 4: {
			g_UserOptions_CurrentMode[id] = !g_UserOptions_CurrentMode[id];
			showMenu__UserOptions_Active(id);
		}
	}
}

public showMenu__UserOptions_ColorChoosen(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;
	new iColorType = g_MenuData[id][MENU_DATA_COLOR_CHOOSEN];

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__COLORS), 6);
	oldmenu_create("\yELEGIR COLORES \r[%d - %d]\y\R%d / %d", "menu__UserOptions_ColorChoosen", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_UserOptions_Color[id][iColorType][0] == __COLORS[i][colorRed] && g_UserOptions_Color[id][iColorType][1] == __COLORS[i][colorGreen] && g_UserOptions_Color[id][iColorType][2] == __COLORS[i][colorBlue]) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, __COLORS[i][colorName]);
		} else {
			oldmenu_additem(j, i, "\r%d.\w %s", j, __COLORS[i][colorName]);
		}
	}

	oldmenu_additem(7, 7, "^n\r7.\w Tipo de color \y(%s)", __COLORS_TYPE[iColorType]);

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__UserOptions_ColorChoosen(const id, const item, const value, page) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_COLOR_CHOOSEN] = iNewPage;

		showMenu__UserOptions_ColorChoosen(id, iNewPage);
		return;
	} else if(item == 7) {
		++g_MenuData[id][MENU_DATA_COLOR_CHOOSEN];

		if(g_MenuData[id][MENU_DATA_COLOR_CHOOSEN] == sizeof(__COLORS_TYPE)) {
			g_MenuData[id][MENU_DATA_COLOR_CHOOSEN] = 0;
		}

		showMenu__UserOptions_ColorChoosen(id, g_MenuPage[id][MENU_PAGE_COLOR_CHOOSEN]);
		return;
	}

	g_UserOptions_Color[id][g_MenuData[id][MENU_DATA_COLOR_CHOOSEN]][0] = __COLORS[value][colorRed];
	g_UserOptions_Color[id][g_MenuData[id][MENU_DATA_COLOR_CHOOSEN]][1] = __COLORS[value][colorGreen];
	g_UserOptions_Color[id][g_MenuData[id][MENU_DATA_COLOR_CHOOSEN]][2] = __COLORS[value][colorBlue];

	if(g_MenuData[id][MENU_DATA_COLOR_CHOOSEN] == COLOR_TYPE_NVISION && g_NVision[id] && task_exists(id + TASK_NVISION)) {
		remove_task(id + TASK_NVISION);
		set_task(0.1, "task__SetUserNVision", id + TASK_NVISION, .flags="b");
	}

	showMenu__UserOptions_ColorChoosen(id, g_MenuPage[id][MENU_PAGE_COLOR_CHOOSEN]);
}

public showMenu__UserOptions_Hud(const id, const type_hud) {
	oldmenu_create("\yOPCIONES DE HUD %s", "menu__UserOptions_Hud", __HUD_TYPES[type_hud]);

	oldmenu_additem(1, type_hud, "\r1.\w Mover hacia arriba");
	oldmenu_additem(2, type_hud, "\r2.\w Mover hacia abajo^n");

	if(g_UserOptions_Hud[id][type_hud][2] != 1.0) {
		oldmenu_additem(3, type_hud, "\r3.\w Mover hacia la izquierda");
		oldmenu_additem(4, type_hud, "\r4.\w Mover hacia la derecha^n");
	}

	oldmenu_additem(5, type_hud, "\r5.\w HUD alineado %s^n", ((g_UserOptions_Hud[id][type_hud][2] == 0.0) ? "a la izquierda" : ((g_UserOptions_Hud[id][type_hud][2] == 1.0) ? "al centro" : "a la derecha")));
	
	oldmenu_additem(6, type_hud, "\r6.\w Efecto del HUD \y(%s)", ((g_UserOptions_HudEffect[id][type_hud]) ? "Activado" : "Desactivado"));

	if(type_hud == HUD_TYPE_GENERAL) {
		oldmenu_additem(7, type_hud, "\r7.\w Estilos del HUD \y(%s)", __HUD_STYLES[g_UserOptions_HudStyle[id][type_hud]]);
	}

	oldmenu_additem(9, type_hud, "^n\r9.\w Reiniciar valores^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__UserOptions_Hud(const id, const item, const value) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	switch(item) {
		case 1: {
			g_UserOptions_Hud[id][value][1] -= 0.01;
		} case 2: {
			g_UserOptions_Hud[id][value][1] += 0.01;
		} case 3: {
			g_UserOptions_Hud[id][value][0] -= 0.01;
		} case 4: {
			g_UserOptions_Hud[id][value][0] += 0.01;
		} case 5: {
			switch(g_UserOptions_Hud[id][value][2]) {
				case 0.0: {
					g_UserOptions_Hud[id][value][0] = -1.0;
					g_UserOptions_Hud[id][value][2] = 1.0;
				} case 1.0: {
					g_UserOptions_Hud[id][value][0] = 1.5;
					g_UserOptions_Hud[id][value][2] = 2.0;
				} case 2.0: {
					g_UserOptions_Hud[id][value][0] = 0.0;
					g_UserOptions_Hud[id][value][2] = 0.0;
				}
			}
		} case 6: {
			g_UserOptions_HudEffect[id][value] = !g_UserOptions_HudEffect[id][value];
		} case 7: {
			if(value == HUD_TYPE_GENERAL) {
				++g_UserOptions_HudStyle[id][value];

				if(g_UserOptions_HudStyle[id][value] == sizeof(__HUD_STYLES)) {
					g_UserOptions_HudStyle[id][value] = 0;
				}
			}
		} case 9: {
			switch(value) {
				case HUD_TYPE_GENERAL: {
					g_UserOptions_Hud[id][HUD_TYPE_GENERAL] = Float:{0.02, 0.1, 0.0};
					g_UserOptions_HudEffect[id][HUD_TYPE_GENERAL] = 0;
					g_UserOptions_HudStyle[id][HUD_TYPE_GENERAL] = 1;
				} case HUD_TYPE_COMBO: {
					g_UserOptions_Hud[id][HUD_TYPE_COMBO] = Float:{-1.0, 0.6, 1.0};
					g_UserOptions_HudEffect[id][HUD_TYPE_COMBO] = 0;
					g_UserOptions_HudStyle[id][HUD_TYPE_COMBO] = 0;
				}
			}
		}
	}

	if(value == HUD_TYPE_COMBO) {
		set_hudmessage(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][2], g_UserOptions_Hud[id][HUD_TYPE_COMBO][0], g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
		ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nCombo x1.337 | +1.337 XP^nDaño total: 1.337 | Daño: 1.337", __COMBO_HUMAN[random_num(0, charsmax(__COMBO_HUMAN))][comboMessage]);
	}

	showMenu__UserOptions_Hud(id, value);
}

public showMenu__UserOptions_Chat(const id) {
	oldmenu_create("\yOPCIONES DE CHAT", "menu__UserOptions_Chat");

	new i;
	new j;

	for(i = 0, j = 1; i < structIdChatMode; ++i, ++j) {
		if(g_UserOptions_ChatMode[id] == i) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, __CHAT_MODE[i]);
		} else {
			oldmenu_additem(j, i, "\r%d.\w %s", j, __CHAT_MODE[i]);
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__UserOptions_Chat(const id, const item, const value) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	if(g_UserOptions_ChatMode[id] == value) {
		clientPrintColor(id, _, "Ya has elegido esta opción");

		showMenu__UserOptions_Chat(id);
		return;
	}

	g_UserOptions_ChatMode[id] = value;

	clientPrintColor(id, _, "Has elegido la opción !g%s!y", __CHAT_MODE[value]);
	showMenu__UserOptions_Chat(id);
}

public showMenu__Stats(const id) {
	oldmenu_create("\yESTADÍSTICAS", "menu__Stats");

	oldmenu_additem(1, 1, "\r1.\w Lista de Niveles");
	oldmenu_additem(2, 2, "\r2.\w Subir de Reset^n");

	oldmenu_additem(3, 3, "\r3.\w Estadísticas Generales");
	oldmenu_additem(4, 4, "\r4.\w Estadísticas de mis Items Extras");
	oldmenu_additem(5, 5, "\r5.\w Top 15^n");

	new sAccount[8];
	new sForum[8];

	addDot(g_AccountId[id], sAccount, charsmax(sAccount));
	addDot(g_AccountVinc[id], sForum, charsmax(sForum));

	oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccount);
	oldmenu_additem(-1, -1, "\wVINCULADO AL FORO\r:\y %s \d(#%s)", ((g_AccountVinc[id]) ? "Si" : "No"), sForum);
	oldmenu_additem(-1, -1, "\wVINCULADO A LA APP\r:\y %s", ((g_AccountVincAppMobile[id]) ? "Si" : "No"));
	oldmenu_additem(-1, -1, "\wTIEMPO JUGADO\r:\y %s \d(POR DÍA: %0.4f hora%s)^n", getUserTimePlaying(id), g_PlayedTime_PerDay[id], ((g_PlayedTime_PerDay[id] != 1.0) ? "s" : ""));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Stats(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			new iFix = calculatePageIn(id, g_Level[id]);

			if(iFix) {
				g_MenuPage[id][MENU_PAGE_STATS_LEVELS] = iFix;
			}

			showMenu__StatsLevels(id, g_MenuPage[id][MENU_PAGE_STATS_LEVELS]);
		} case 2: {
			showMenu__StatsResetUp(id);
		} case 3: {
			showMenu__StatsGeneral(id);
		} case 4: {
			showMenu__StatsExtraItems(id);
		} case 5: {
			clientPrintColor(id, _, "Para ver los top15 del servidor, ingresa a !t%s/top15/zpa!y", __PLUGIN_COMMUNITY_FORUM);
			showMenu__Stats(id);
		}
	}
}

public showMenu__StatsLevels(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;
	new sLevel[8];
	new sXP[16];

	oldmenu_pages(iMaxPages, iStart, iEnd, page, MAX_LEVEL);
	oldmenu_create("\yLISTA DE NIVELES \r[%d - %d]\y\R%d / %d", "menu__StatsLevels", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		addDot((i + 1), sLevel, charsmax(sLevel));
		addDot(xpThisLevel(id, (i + 1)), sXP, charsmax(sXP));

		oldmenu_additem(j, i, "\r%d.%s Nivel\r:%s %s \r-%s XP\r:%s %s", j, ((g_Level[id] > i) ? "\w" : "\d"), ((g_Level[id] > i) ? "\y" : "\r"), sLevel, ((g_Level[id] > i) ? "\w" : "\d"), ((g_Level[id] > i) ? "\y" : "\r"), sXP);
	}

	oldmenu_additem(-1, -1, "^n\yNOTA\r:\w Cada vez que subas de nivel tus XP volverán a 0^n");

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__StatsLevels(const id, const item, const value, page) {
	if(!item || value > MAX_LEVEL) {
		showMenu__Stats(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_STATS_LEVELS] = iNewPage;

		showMenu__StatsLevels(id, iNewPage);
		return;
	}

	new iXP = xpThisLevel(id, (value + 1));
	new sXP[16];

	addDot(iXP, sXP, charsmax(sXP));

	clientPrintColor(id, _, "Te faltan !g%s XP!y para avanzar al !gnivel %d!y", sXP, (value + 1));
	showMenu__StatsLevels(id, g_MenuPage[id][MENU_PAGE_STATS_LEVELS]);
}

public showMenu__StatsResetUp(const id) {
	oldmenu_create("\ySUBIR DE RESET^n\wAl resetear, tu XP y tu nivel se reiniciarán", "menu__StatsResetUp");

	oldmenu_additem(-1, -1, "\yBENEFICIOS AL RESETEAR\r:");
	oldmenu_additem(-1, -1, "\r - \w+\y%d SALDO\w", giveResetMoney(id, (g_Reset[id] + 1)));
	oldmenu_additem(-1, -1, "\r - \w+\y%d\w Daño Humano", giveResetHumanDamage(id, (g_Reset[id] + 1)));
	oldmenu_additem(-1, -1, "\r - \w+\y%d\w Vida Zombie", giveResetZombieHealth(id, (g_Reset[id] + 1)));
	oldmenu_additem(-1, -1, "\r - \w+\y1 pR\r:\w Ve al menú de Habilidades del Reset para utilizarlo^n");

	if(g_XP[id] >= maxXPPerReset(g_Reset[id]) && g_Level[id] >= MAX_LEVEL) {
		oldmenu_additem(1, 1, "\r1.\w Resetear ahora \y(%0.2f%%)", g_ResetPercent[id]);
	} else {
		oldmenu_additem(-1, -1, "\d1. Resetear ahora \r(%0.2f%%)", g_ResetPercent[id]);
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__StatsResetUp(const id, const item) {
	if(!item) {
		showMenu__Stats(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Level[id] >= MAX_LEVEL) {
				if(g_XP[id] >= maxXPPerReset(g_Reset[id])) {
					g_XP[id] = 0;
					g_Level[id] = 1;
					g_LevelPercent[id] = 0.0;
					++g_Reset[id];
					g_Points[id][P_MONEY] += giveResetMoney(id, g_Reset[id]);
					++g_Points[id][P_RESET];

					checkXPEquation(id);

					if(g_Reset[id] >= 50) {
						giveHat(id, HAT_TYNO);
					}

					clientPrintColor(0, id, "Felicitaciones a !t%s!y, subió al !greset %d!y", g_PlayerName[id], g_Reset[id]);
					saveInfo(id);
				} else {
					clientPrintColor(id, _, "Te falta XP para poder resetear");
				}
			} else {
				clientPrintColor(id, _, "Te faltan niveles para poder resetear");
			}
		}
	}
}

public showMenu__StatsGeneral(const id) {
	oldmenu_create("\yESTADÍSTICAS GENERALES\R%d / 5", "menu__StatsGeneral", (g_MenuPage[id][MENU_PAGE_STATS_GENERAL] + 1));

	new sInfo[32];
	sInfo[0] = EOS;

	switch(g_MenuPage[id][MENU_PAGE_STATS_GENERAL]) {
		case 0: {
			addDot(g_AmmoPacksTotal[id], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wAmmoPacks en total\r:\y %s", sInfo);

			addDot(g_AmmoPacks_BestRoundHistory[id], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wAmmoPacks hechos en una ronda\r:\y %s", sInfo);

			addDot(g_AmmoPacks_BestMapHistory[id], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wAmmoPacks hechos en un mapa\r:\y %s", sInfo);

			new sInfoSpecial[32];
			sInfoSpecial[0] = EOS;

			formatex(sInfo, charsmax(sInfo), "%0.0f", (g_StatsDamage[id][0] * DIV_DAMAGE));
			addDotSpecial(sInfo, sInfoSpecial, charsmax(sInfoSpecial));
			oldmenu_additem(-1, -1, "\wDaño hecho\r:\y %s", sInfoSpecial);

			formatex(sInfo, charsmax(sInfo), "%0.0f", (g_StatsDamage[id][1] * DIV_DAMAGE));
			addDotSpecial(sInfo, sInfoSpecial, charsmax(sInfoSpecial));
			oldmenu_additem(-1, -1, "\wDaño recibido\r:\y %s", sInfoSpecial);

			addDot(g_Stats[id][STAT_HS_D], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wDisparos a la cabeza hechos\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_HS_T], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wDisparos a la cabeza recibidos\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_HM_D], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wHumanos matados\r:\y %s", sInfo);
		} case 1: {
			addDot(g_Stats[id][STAT_HM_T], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wVeces muerto como humano\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_ZM_D], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wZombies matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_ZM_T], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wVeces muerto como zombie\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_INF_D], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wInfecciones hechas\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_INF_T], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wInfecciones recibidas\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_ZMHS_D], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wZombies matados en la cabeza\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_ZMHS_T], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wVeces muerto como zombie en la cabeza\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_ZMK_D], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wZombies matados con cuchillo\r:\y %s", sInfo);
		} case 2: {
			addDot(g_Stats[id][STAT_ZMK_T], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wVeces muerto como zombie con cuchillo\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_AP_D], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wCantidad de chaleco desgarrado\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_AP_T], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wCantidad de chaleco que te desgarraron\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_COMBO_MAX], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wCombo máximo humano\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_S_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wSurvivors matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_W_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wWeskers matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_L_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wLeatherFaces matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_T_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wTribales matados\r:\y %s", sInfo);
		} case 3: {
			addDot(g_Stats[id][STAT_SN_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wSnipers matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_NEM_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wNemesis matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_CAB_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wCabezones matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_ANN_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wAniquiladores matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_FLESH_M_KILL], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wFleshpound matados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_MA_WINS], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wMega armageddones ganados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_GG_WINS], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wGungames ganados\r:\y %s", sInfo);

			addDot(g_Stats[id][STAT_DF_WINS], sInfo, charsmax(sInfo));
			oldmenu_additem(-1, -1, "\wDuelos finales ganados\r:\y %s", sInfo);
		}
	}

	oldmenu_additem(9, 9, "^n\r9.\w Siguiente/Atrás");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__StatsGeneral(const id, const item) {
	if(!item) {
		showMenu__Stats(id);
		return;
	}

	switch(item) {
		case 9: {
			++g_MenuPage[id][MENU_PAGE_STATS_GENERAL];

			if(g_MenuPage[id][MENU_PAGE_STATS_GENERAL] == 4) {
				g_MenuPage[id][MENU_PAGE_STATS_GENERAL] = 0;
			}

			showMenu__StatsGeneral(id);
		}
	}
}

public showMenu__StatsExtraItems(const id) {
	oldmenu_create("\yESTADÍSTICAS DE ITEMS EXTRAS", "menu__StatsExtraItems");

	new sExtraItemCount[16];
	sExtraItemCount[0] = EOS;

	for(new i = 0; i < structIdExtraItems; ++i) {
		if(g_Zombie[id] != __EXTRA_ITEMS[i][extraItemTeam]) {
			continue;
		}

		addDot(g_ExtraItem_Count[id][i], sExtraItemCount, charsmax(sExtraItemCount));
		oldmenu_additem(-1, -1, "\w%s\r:\y %s", __EXTRA_ITEMS[i][extraItemName], sExtraItemCount);
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__StatsExtraItems(const id, const item) {
	if(!item) {
		showMenu__Stats(id);
		return;
	}

	showMenu__StatsExtraItems(id);
}

public updateMultipliersVars(const id) {
	updateAmmoPacksMult(id);
	updateExpMult(id);
	updatePointsMult(id);
	updateDamageNeed(id);
}

public updateAmmoPacksMult(const id) {
	if(g_AccountStatus[id] < STATUS_LOGGED) {
		return;
	}

	new Float:flMult = 1.0;

	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1) {
		flMult += 1.0;
	}

	flMult += g_AmmoPacksMult_Legendary[id];

	flMult += g_AmmoPacksMult_Achievements[id];

	if(g_HatId[id] != HAT_NONE && __HATS[g_HatId[id]][hatUpgrade5]) {
		flMult += __HATS[g_HatId[id]][hatUpgrade5];
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_RING_AMMOPACKS]) {
		flMult += (float(g_Artifact[id][ARTIFACT_RING_AMMOPACKS]) * 0.25);
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_BRACELET_AMMOPACKS]) {
		flMult += 1.0;
	}

	if(g_AmuletCustomCreated[id]) {
		flMult += g_AmuletCustom[id][acMultAmmoPacks];
	}

	g_AmmoPacksMult[id] = flMult;
}

public updateExpMult(const id) {
	if(g_AccountStatus[id] < STATUS_LOGGED) {
		return;
	}

	new Float:flMult = 1.0;

	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1) {
		flMult += 1.0;
	}

	if(g_HappyHour == 2) {
		flMult += 2.0;
	} else if(g_DrunkAtDay == 1 || g_HappyHour == 1) {
		flMult += 1.0;
	}

	flMult += g_XPMult_Legendary[id];

	flMult += g_XPMult_Achievements[id];

	if(g_HatId[id] != HAT_NONE && __HATS[g_HatId[id]][hatUpgrade6]) {
		flMult += __HATS[g_HatId[id]][hatUpgrade6];
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_RING_XP]) {
		flMult += (float(g_Artifact[id][ARTIFACT_RING_XP]) * 0.5);
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_BRACELET_XP]) {
		flMult += 1.0;
	}

	if(g_AmuletCustomCreated[id]) {
		flMult += g_AmuletCustom[id][acMultXP];
	}

	if(g_Mastery[id] == g_MasteryType) {
		flMult += 1.0;
	}

	flMult += g_UserExtraXP;

	if(g_VoteMap_MapId != -1) {
		flMult += g_VoteMap_Bonus[g_VoteMap_MapId];
	}

	if(g_Consecutive_DailyVisits[id]) {
		flMult += (float(g_Consecutive_DailyVisits[id]) * 0.0066);
	}

	if(g_InGroup[id]) {
		new i;
		new iCount = 0;

		for(i = 1; i < 4; ++i) {
			if(g_GroupId[g_InGroup[id]][i] && !g_Zombie[g_GroupId[g_InGroup[id]][i]]) {
				++iCount;
			}
		}

		flMult += ((iCount == 3) ? 1.5 : (iCount == 2) ? 1.0 : 0.0);
	}

	g_XPMult[id] = flMult;
}

public updatePointsMult(const id) {
	if(g_AccountStatus[id] < STATUS_LOGGED) {
		return;
	}

	new iMult = 1;

	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1) {
		++iMult;
	}

	if(g_HappyHour == 2) {
		++iMult;
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_BRACELET_POINTS]) {
		++iMult;
	}

	g_PointsMult[id] = clamp(iMult, 1, 5);
}

public updateDamageNeed(const id) {
	g_AmmoPacksDamageNeed[id] = ((3250.0 * (float(g_Reset[id]) + 1.0)) / g_AmmoPacksMult[id]);
	g_XPDamageNeed[id] = (100.0 / g_XPMult[id]);

	if(!g_ComboDamageNeedFake[id]) {
		g_ComboDamageNeed[id] = (10.0 / g_XPMult[id]);

		if(g_ComboDamageNeed[id] < 1.0) {
			g_ComboDamageNeed[id] = 1.0;
		}
	}
}

public message__Money(const msg_id, const msg_dest, const msg_entity) {
	if(g_IsConnected[msg_entity]) {
		cs_set_user_money(msg_entity, 0);
	}

	return PLUGIN_HANDLED;
}

public message__CurWeapon(const msg_id, const msg_dest, const msg_entity) {
	if(get_msg_arg_int(1) != 1) {
		return;
	}

	if(!g_IsAlive[msg_entity] || g_Zombie[msg_entity] || !g_UnlimitedClip[msg_entity]) {
		return;
	}

	static iWeaponId;
	iWeaponId = get_msg_arg_int(2);

	if(__MAX_BPAMMO[iWeaponId] > 2) {
		static iWeaponEnt;
		iWeaponEnt = getCurrentWeaponEnt(msg_entity);

		if(pev_valid(iWeaponEnt)) {
			set_pdata_int(iWeaponEnt, OFFSET_CLIPAMMO, __MAX_CLIP[iWeaponId], OFFSET_LINUX_WEAPONS);
		}

		set_msg_arg_int(3, get_msg_argtype(3), __MAX_CLIP[iWeaponId]);
	}
}

public message__FlashBat(const msg_id, const msg_dest, const msg_entity) {
	if(get_msg_arg_int(1) < OFF_IMPULSE_FLASHLIGHT) {
		set_msg_arg_int(1, ARG_BYTE, OFF_IMPULSE_FLASHLIGHT);
		setUserBatteries(msg_entity, OFF_IMPULSE_FLASHLIGHT);
	}
}

public message__Flashlight() {
	set_msg_arg_int(2, ARG_BYTE, OFF_IMPULSE_FLASHLIGHT);
}

public message__NVGToggle() {	
	return PLUGIN_HANDLED;
}

public message__WeapPickup(const msg_id, const msg_dest, const msg_entity) {
	if(g_Zombie[msg_entity]) {
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public message__AmmoPickup(const msg_id, const msg_dest, const msg_entity) {
	if(g_Zombie[msg_entity]) {
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public message__TextMsg() {
	static sTextMsg[32];
	get_msg_arg_string(2, sTextMsg, charsmax(sTextMsg));

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

	if(equal(sTextMsg, "#Game_teammate_attack")) {
		return PLUGIN_HANDLED;
	}

	if(equal(sTextMsg, "#Game_Commencing")) {
		g_FirstRound = 1;
		return PLUGIN_HANDLED;
	}

	if(equal(sTextMsg, "#Game_will_restart_in")) {
		g_ScoreHumans = 0;
		g_ScoreZombies = 0;
		g_FirstRound = 1;

		logevent__RoundEnd();
	} else if(equal(sTextMsg, "#Hostages_Not_Rescued") || equal(sTextMsg, "#Round_Draw") || equal(sTextMsg, "#Terrorists_Win") || equal(sTextMsg, "#CTs_Win")) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message__SendAudio() {
	static sSendAudio[32];
	get_msg_arg_string(2, sSendAudio, charsmax(sSendAudio));

	if(equali(sSendAudio, "%!MRAD_ctwin") || equali(sSendAudio, "%!MRAD_terwin") || equali(sSendAudio, "%!MRAD_rounddraw") || equali(sSendAudio, "%!MRAD_LETSGO") || equali(sSendAudio, "%!MRAD_LOCKNLOAD") || equali(sSendAudio, "%!MRAD_MOVEOUT") || equali(sSendAudio, "%!MRAD_GO") || equali(sSendAudio, "%!MRAD_FIREINHOLE")) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message__StatusIcon(const msg_id, const msg_dest, const msg_entity) {
	static sIcon[8];
	get_msg_arg_string(2, sIcon, charsmax(sIcon));
	
	if(equal(sIcon, "buyzone") && get_msg_arg_int(1)) {
		set_pdata_int(msg_entity, OFFSET_BUYZONE, get_pdata_int(msg_entity, OFFSET_BUYZONE) & ~(1<<0));
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public task__SpectNVision(const id) {
	if(!g_IsConnected[id] || g_IsAlive[id]) {
		return;
	}

	setUserNVision(id, 1);
}

public checkAccount(const id) {
	if(g_AccountStatus[id] != STATUS_CHECK_ACCOUNT) {
		return;
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id, last_ip, password, recovery_code, since_connection, last_connection, autologin, vinc, vinc_app_mobile, daily_visit, daily_visit_consecutive, connected_today FROM zp8_accounts WHERE name=^"%s^";", g_PlayerName[id]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 11);
	} else if(SQL_NumResults(sqlQuery)) {
		g_AccountStatus[id] = STATUS_REGISTERED;

		g_AccountId[id] = SQL_ReadResult(sqlQuery, 0);
		SQL_ReadResult(sqlQuery, 1, g_AccountLastIp[id], charsmax(g_AccountLastIp[]));
		SQL_ReadResult(sqlQuery, 2, g_AccountPassword[id], charsmax(g_AccountPassword[]));

		if(SQL_IsNull(sqlQuery, 3)) {
			generateCode(id);

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_accounts SET recovery_code=^"%s^" WHERE id='%d';", g_AccountCode[id], g_AccountId[id]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		} else {
			SQL_ReadResult(sqlQuery, 3, g_AccountCode[id], charsmax(g_AccountCode[]));
		}

		g_AccountSinceConnection[id] = SQL_ReadResult(sqlQuery, 4);
		g_AccountLastConnection[id] = SQL_ReadResult(sqlQuery, 5);
		g_AccountAutologin[id] = SQL_ReadResult(sqlQuery, 6);
		g_AccountVinc[id] = SQL_ReadResult(sqlQuery, 7);
		g_AccountVincAppMobile[id] = SQL_ReadResult(sqlQuery, 8);
		g_DailyVisits[id] = SQL_ReadResult(sqlQuery, 9);
		g_Consecutive_DailyVisits[id] = SQL_ReadResult(sqlQuery, 10);
		g_ConnectedToday[id] = SQL_ReadResult(sqlQuery, 11);

		SQL_FreeHandle(sqlQuery);

		if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
			set_task(160.0, "task__MessageVip", id + TASK_MESSAGE_VIP);
		}

		if(!g_AccountVinc[id]) {
			set_task(180.0, "task__MessageVinc", id + TASK_MESSAGE_VINC);
		}

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_bans WHERE acc_id='%d' AND active='1';", g_AccountId[id]);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 12);
		} else if(SQL_NumResults(sqlQuery)) {
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "staff_name"), g_AccountBanned_StaffName[id], charsmax(g_AccountBanned_StaffName[]));
			g_AccountBanned_Start[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "start"));
			g_AccountBanned_Finish[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "finish"));
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "reason"), g_AccountBanned_Reason[id], charsmax(g_AccountBanned_Reason[]));

			SQL_FreeHandle(sqlQuery);

			if(get_arg_systime() < g_AccountBanned_Finish[id]) {
				g_AccountStatus[id] = STATUS_BANNED;
			} else {
				clientPrintColor(0, id, "!t%s!y estaba baneado por cuenta y ahora podrá volver a jugar.", g_PlayerName[id]);

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_bans SET active='0' WHERE acc_id='%d' AND active='1';", g_AccountId[id]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

				if(equali(g_AccountLastIp[id], g_PlayerIp[id]) && g_AccountAutologin[id] && g_AccountVinc[id]) {
					g_AccountStatus[id] = STATUS_LOADING;
					loadInfo(id);
				}
			}
		} else {
			SQL_FreeHandle(sqlQuery);

			if(equali(g_AccountLastIp[id], g_PlayerIp[id]) && g_AccountAutologin[id] && g_AccountVinc[id]) {
				g_AccountStatus[id] = STATUS_LOADING;
				loadInfo(id);
			}
		}

		if(g_AccountStatus[id] != STATUS_BANNED) {
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT COUNT(*) FROM zp8_bans WHERE acc_id='%d';", g_AccountId[id]);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 39);
			} else if(SQL_NumResults(sqlQuery)) {
				g_AccountBannedCount[id] = SQL_ReadResult(sqlQuery, 0);
				SQL_FreeHandle(sqlQuery);

				if(g_AccountBannedCount[id] >= MAX_BAN_ACCOUNT) {
					g_AccountStatus[id] = STATUS_BANNED;

					formatex(g_AccountBanned_StaffName[id], charsmax(g_AccountBanned_StaffName[]), "Drunk-Gaming");
					g_AccountBanned_Start[id] = get_arg_systime();
					g_AccountBanned_Finish[id] = 2000000000;
					formatex(g_AccountBanned_Reason[id], charsmax(g_AccountBanned_Reason[]), "Reiterados baneos de cuenta");

					clientPrintColor(0, id, "!t%s!y ha sido baneado permanentemente porque se han encontrado más de !g%d baneos!y en su cuenta.", g_PlayerName[id], MAX_BAN_ACCOUNT);

					if(getUserIsSteamId(id)) {
						copy(g_PlayerSteamIdCache[id], charsmax(g_PlayerSteamIdCache[]), g_PlayerSteamId[id]);
					} else {
						formatex(g_PlayerSteamIdCache[id], charsmax(g_PlayerSteamIdCache[]), "STEAM_ID_LAN");
					}

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_bans (acc_id, ip, steam, staff_name, start, finish, reason) VALUES ('%d', ^"%s^", ^"%s^", ^"%s^", '%d', '%d', ^"%s^");", g_AccountId[id], g_PlayerIp[id], g_PlayerSteamIdCache[id], g_AccountBanned_StaffName[id], g_AccountBanned_Start[id], g_AccountBanned_Finish[id], g_AccountBanned_Reason[id]);
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
				}
			} else {
				g_AccountBannedCount[id] = 0;
				SQL_FreeHandle(sqlQuery);
			}
		}
	} else {
		g_AccountStatus[id] = STATUS_UNREGISTERED;
		SQL_FreeHandle(sqlQuery);
	}
}

public task__CheckBuy(const task_id) {
	new iId = (task_id - TASK_CHECK_BUY);

	if(!g_IsConnected[iId] || g_AccountStatus[iId] < STATUS_LOGGED || !g_BuyStuff[iId]) {
		return;
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_buys WHERE acc_id='%d' AND bought_ok='0';", g_AccountId[iId]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(iId, sqlQuery, 13);
	} else if(SQL_NumResults(sqlQuery)) {
		new iPH;
		new iPZ;
		new iPL;
		new iMoney;
		new iDiamond;

		while(SQL_MoreResults(sqlQuery)) {
			iPH = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_humans"));
			iPZ = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_zombies"));
			iPL = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "p_legacy"));
			iMoney = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "money"));
			iDiamond = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "diamonds"));

			g_Points[iId][P_HUMAN] += iPH;
			g_Points[iId][P_ZOMBIE] += iPZ;
			g_Points[iId][P_LEGACY] += iPL;
			g_Points[iId][P_MONEY] += iMoney;
			g_Points[iId][P_DIAMONDS] += iDiamond;

			clientPrintColor(iId, _, "Tu compra de !g%d pH!y, !g%d pZ!y, !g%d pL!y, !g%d SALDO!y y !g%d DIAMANTES!y se ha acreditado con éxito", iPH, iPZ, iPL, iMoney, iDiamond);
			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_pjs SET bought_ok='0' WHERE acc_id='%d' AND bought_ok='1';", g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_buys SET bought_timestamp='%d', bought_ok='1' WHERE acc_id='%d' AND bought_ok='0';", get_arg_systime(), g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_payments SET ok='1' WHERE member_id='%d' AND ok='0';", g_AccountVinc[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	g_BuyStuff[iId] = 0;
}

public task__ClearWeapons(const task_id) {
	static iId;
	iId = ((task_id > MaxClients) ? (task_id - TASK_SPAWN) : task_id);

	if(!g_IsAlive[iId]) {
		return;
	}

	strip_user_weapons(iId);

	g_WeaponPrimary_Current[iId] = 0;
	g_WeaponSecondary_Current[iId] = 0;

	if(g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_MEGA_ARMAGEDDON && g_Mode != MODE_DUEL_FINAL && g_Mode != MODE_GRUNT) {
		give_item(iId, "weapon_knife");
	}
}

public task__SetWeapons(const task_id) {
	new iId = ((task_id > MaxClients) ? (task_id - TASK_SPAWN) : task_id);

	if(!g_IsAlive[iId]) {
		return;
	}

	if(g_Mode == MODE_GUNGAME) {
		strip_user_weapons(iId);

		gunGameGiveWeapons(iId);
		return;
	} else if(g_Mode == MODE_MEGA_GUNGAME) {
		strip_user_weapons(iId);

		if(!g_ModeMGG_Block) {
			give_item(iId, __MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[iId]]);

			if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]] != 0) {
				if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]] != CSW_HEGRENADE) {
					ExecuteHamB(Ham_GiveAmmo, iId, __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]], __AMMO_TYPE[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]], __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]]);
				} else {
					cs_set_user_bpammo(iId, CSW_HEGRENADE, 200);
				}
			}
		}

		return;
	} else if(g_Mode == MODE_DUEL_FINAL) {
		strip_user_weapons(iId);

		switch(g_ModeDuelFinal_Type) {
			case DF_TYPE_KNIFE: {
				give_item(iId, "weapon_knife");
			} case DF_TYPE_AWP: {
				give_item(iId, "weapon_awp");
				cs_set_user_bpammo(iId, CSW_AWP, 200);
			} case DF_TYPE_HE: {
				give_item(iId, "weapon_hegrenade");
				cs_set_user_bpammo(iId, CSW_HEGRENADE, 200);
			} case DF_TYPE_ONLY_HEAD: {
				switch(g_ModeDuelFinal_TypeOnlyHead) {
					case 1: {
						give_item(iId, "weapon_deagle");
						cs_set_user_bpammo(iId, CSW_DEAGLE, 200);
					} case 2: {
						give_item(iId, "weapon_ak47");
						cs_set_user_bpammo(iId, CSW_AK47, 200);
					} case 3: {
						give_item(iId, "weapon_m4a1");
						cs_set_user_bpammo(iId, CSW_M4A1, 200);
					}
				}
			}
		}

		return;
	} else if(g_Mode == MODE_GRUNT) {
		strip_user_weapons(iId);
		return;
	} else if(g_Mode == MODE_ANNIHILATOR) {
		strip_user_weapons(iId);
		give_item(iId, "weapon_knife");

		cs_set_weapon_ammo(give_item(iId, "weapon_m249"), 100);
		cs_set_user_bpammo(iId, CSW_M249, 0);

		if(!g_ModeAnnihilator_Acerts[iId]) {
			clientPrintColor(iId, _, "Tienes una !gM249 Para Machinegun!y para acumular aciertos. Suerte con tu Precisión");
		}

		return;
	}

	if(g_WeaponAutoBuy[iId] && task_id > MaxClients) {
		if(!g_IsAlive[iId] || g_Zombie[iId] || g_SpecialMode[iId] || !g_CanBuy[iId]) {
			return;
		}
		
		buyPrimaryWeapon(iId, g_WeaponPrimary_Selection[iId]);
		buySecondaryWeapon(iId, g_WeaponSecondary_Selection[iId]);
		
		if(!task_exists(TASK_START_MODE)) {
			buyCuaternaryWeapon(iId, g_WeaponCuaternary_Selection[iId]);
		}
		
		g_CanBuy[iId] = 0;
		g_Hat_Devil[iId] = 1;

		return;
	}

	showMenu__BuyPrimaryWeapons(iId, g_MenuPage[iId][MENU_PAGE_BPW]);
}

public task__RespawnCheckPlayer(const task_id) {
	new iId = ((task_id > MaxClients) ? (task_id - TASK_SPAWN) : task_id);
	
	if(g_IsAlive[iId] || g_EndRound) {
		return;
	}
	
	new TeamName:iTeam = getUserTeam(iId);
	
	if((iTeam == TEAM_UNASSIGNED) || (iTeam == TEAM_SPECTATOR)) {
		return;
	}
	
	if(g_Zombie[iId]) {
		g_RespawnAsZombie[iId] = 1;
	} else {
		g_RespawnAsZombie[iId] = 0;
	}
	
	respawnUserManually(iId);
}

public task__RespawnPlayer(const task_id) {
	new iId = ((task_id > MaxClients) ? (task_id - TASK_SPAWN) : task_id);

	if(g_IsAlive[iId] || g_EndRound || g_LastHumanOk_NoRespawn) {
		return;
	}

	new TeamName:iTeam = getUserTeam(iId);

	if((iTeam == TEAM_UNASSIGNED) || (iTeam == TEAM_SPECTATOR)) {
		return;
	}

	if(g_NewRound || g_Mode == MODE_INFECTION || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_L4D2 || g_Mode == MODE_CABEZON || g_Mode == MODE_ANNIHILATOR) {
		switch(g_Mode) {
			case MODE_INFECTION: {
				if(!g_FirstSpawn[iId]) {
					new iRandom = random_num(1, 100);
					new iRandomChance = ((__HABS[HAB_L_RESPAWN][habValue] * g_Hab[iId][HAB_L_RESPAWN]) + __HATS[g_HatId[iId]][hatUpgrade7]);

					if(getUsersPlaying() >= 16 && getZombies() > getHumans() && iRandomChance && iRandom <= iRandomChance) {
						g_RespawnAsZombie[iId] = 0;
					} else {
						g_RespawnAsZombie[iId] = 1;
					}
				} else {
					g_RespawnAsZombie[iId] = 1;
				}
			} case MODE_GUNGAME, MODE_MEGA_GUNGAME, MODE_CABEZON, MODE_ANNIHILATOR: {
				g_RespawnAsZombie[iId] = 0;
			} case MODE_L4D2: {
				g_RespawnAsZombie[iId] = 1;

				if(g_SpecialMode[iId] != MODE_L4D2) {
					if(!g_ModeL4D2_Zombies) {
						return;
					}

					--g_ModeL4D2_Zombies;

					if(g_ModeL4D2_Zombies <= getZombies()) {
						return;
					}
				}
			}
		}

		respawnUserManually(iId);
	}
}

public task__BurningFlame(const args[], const task_id) {
	static iId;
	iId = (task_id - TASK_BURNING_FLAME);

	if(!g_IsConnected[iId]) {
		remove_task(task_id);
		return;
	}

	static vecOrigin[3];
	static iFlags;

	get_user_origin(iId, vecOrigin);
	iFlags = entity_get_int(iId, EV_INT_flags);

	if(!g_IsAlive[iId] || g_Immunity[iId] || (iFlags & FL_INWATER) || g_BurningDuration[iId] < 1 || g_EndRound || (g_Hab[iId][HAB_Z_RESISTANCE_FROST] >= 3 && g_Frozen[iId])) {
		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_SMOKE);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord((vecOrigin[2] - 50));
		write_short(g_Sprite_Smoke);
		write_byte(random_num(15, 20));
		write_byte(random_num(10, 20));
		message_end();

		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);

		remove_task(task_id);
		return;
	}

	if((iFlags & FL_ONGROUND)) {
		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);
	}

	if(!g_SpecialMode[iId] && !random_num(0, 15)) {
		emitSound(iId, CHAN_VOICE, __SOUND_ZOMBIE_BURN[random_num(0, charsmax(__SOUND_ZOMBIE_BURN))]);
	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_SPRITE);
	write_coord(vecOrigin[0] + random_num(-5, 5));
	write_coord(vecOrigin[1] + random_num(-5, 5));
	write_coord(vecOrigin[2] + random_num(-10, 10));
	write_short(g_Sprite_Flame);
	write_byte(random_num(2, 5));
	write_byte(200);
	message_end();

	--g_BurningDuration[iId];

	if(g_ArtifactsEquiped[iId][ARTIFACT_NECKLASE_FIRE]) {
		return;
	}

	static Float:flDamage;
	static iDamage;

	flDamage = ((float(g_MaxHealth[iId]) * 0.24) / 100);

	if(g_Hab[iId][HAB_Z_RESISTANCE_FIRE] >= 1) {
		flDamage /= 2.0;
	}

	iDamage = floatround(flDamage);

	if((g_Health[iId] - iDamage) > 0) {
		set_user_health(iId, (g_Health[iId] - iDamage));
		g_Health[iId] = get_user_health(iId);
	}

	static iAttacker;
	iAttacker = args[0];

	if(g_IsAlive[iAttacker] && !g_Zombie[iAttacker] && !g_SpecialMode[iAttacker]) {
		g_ComboDamage[iAttacker] += flDamage;
		g_Combo[iAttacker] = floatround((g_ComboDamage[iAttacker] / g_ComboDamageNeed[iAttacker]));

		showCurrentComboHuman(iAttacker, flDamage);
	}
}

public task__RemoveFreeze(const task_id) {
	new iId = (task_id - TASK_FREEZE);

	if(!g_IsAlive[iId] || !g_Frozen[iId]) {
		return;
	}

	new iFrozen = g_Frozen[iId];
	g_Frozen[iId] = 0;

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);
	set_user_gravity(iId, zombieGravity(iId));

	if(g_ReduceDamage[iId]) {
		set_user_rendering(iId, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 100);
	} else {
		set_user_rendering(iId);
	}

	if(!g_DrugBombMove[iId]) {
		message_begin(MSG_ONE, g_Message_ScreenFade, _, iId);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_IN);
		write_byte(0);
		write_byte(((iFrozen == 2) ? 255 : 0));
		write_byte(255);
		write_byte(100);
		message_end();
	}

	emitSound(iId, CHAN_BODY, __SOUND_NADE_FROST_BREAK);

	new Float:vecOrigin[3];
	entity_get_vector(iId, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BREAKMODEL);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 24.0);
	write_coord(16);
	write_coord(16);
	write_coord(16);
	write_coord(random_num(-50, 50));
	write_coord(random_num(-50, 50));
	write_coord(25);
	write_byte(10);
	write_short(g_Sprite_Glass);
	write_byte(10);
	write_byte(25);
	write_byte(BREAK_GLASS);
	message_end();
}

public task__RemoveMadness(const task_id) {
	new iId = (task_id - TASK_MADNESS);

	if(!g_IsAlive[iId]) {
		return;
	}

	g_Immunity[iId] = 0;
	g_Speed[iId] -= 30.0;

	if(g_ReduceDamage[iId]) {
		set_user_rendering(iId, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 100);
	} else {
		set_user_rendering(iId);
	}

	if(!g_Achievement_InfectsWithFury[iId]) {
		if(g_Achievement_FuryConsecutive[iId] == 2) {
			setAchievement(iId, PENSANDOLO_BIEN);
		}
	}

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);
}

public task__HealthRegeneration(const task_id) {
	new iId = (task_id - TASK_HEALTH_REGENERATION);

	if(!g_IsAlive[iId]) {
		return;
	}

	new iPercent = ((g_MaxHealth[iId] * 35) / 1000);
	new iTotal = (g_Health[iId] + iPercent);

	if(iTotal >= g_MaxHealth[iId]) {
		return;
	}

	new vecOrigin[3];
	get_user_origin(iId, vecOrigin);

	message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_PROJECTILE);
	write_coord(vecOrigin[0] + random_num(-10, 10));
	write_coord(vecOrigin[1] + random_num(-10, 10));
	write_coord(vecOrigin[2] + random_num(0, 30));
	write_coord(0);
	write_coord(0);
	write_coord(15);
	write_short(g_Sprite_Regeneration);
	write_byte(1);
	write_byte(iId);
	message_end();

	set_user_health(iId, iTotal);
	g_Health[iId] = iTotal;
}

public task__RemoveHealthImmunity(const task_id) {
	new iId = (task_id - TASK_HEALTH_IMMUNITY);

	if(!g_IsAlive[iId]) {
		return;
	}

	if(g_ReduceDamage[iId]) {
		set_user_rendering(iId, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 100);
	} else {
		set_user_rendering(iId);
	}

	g_Immunity[iId] = 0;
	g_Frozen[iId] = 0;
	g_Petrification[iId] = 0;

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);
}

public task__VirusT() {
	if(g_LastMode == MODE_GRUNT) {
		set_cvar_num("mp_autokick", 1);
		set_cvar_num("mp_autokick_timeout", 45);
	}

	showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, 0, 7.5, "¡EL VIRUS-T SE HA LIBERADO!");

	new Float:flExtraXP = 0.0;

	if(g_HappyHour == 2) {
		if(g_VoteMap_MapId != -1) {
			flExtraXP = (2.0 + g_UserExtraXP + g_VoteMap_Bonus[g_VoteMap_MapId]);
		} else {
			flExtraXP = (2.0 + g_UserExtraXP);
		}
		
		clientPrintColor(0, _, "!tSUPER DRUNK AT NITE!y: Tu multiplicador de XP aumenta un !g+x%0.2f!y y de puntos !g+x1!y", flExtraXP);
	} else if(g_DrunkAtDay == 1 || g_HappyHour == 1) {
		if(g_VoteMap_MapId != -1) {
			flExtraXP = (1.0 + g_UserExtraXP + g_VoteMap_Bonus[g_VoteMap_MapId]);
		} else {
			flExtraXP = (1.0 + g_UserExtraXP);
		}

		if(g_DrunkAtDay == 1) {
			clientPrintColor(0, _, "!tDRUNK AT DAY!y: Tu multiplicador de XP aumenta un !g+x%0.2f!y", flExtraXP);
		} else {
			clientPrintColor(0, _, "!tDRUNK AT NITE!y: Tu multiplicador de XP aumenta un !g+x%0.2f!y", flExtraXP);
		}

		if(g_EventModes) {
			clientPrintColor(0, _, "!tEVENTO DE MODOS!y: Solo saldrán modos especiales");

			if(g_EventMode_MegaArmageddon > 0 || g_EventMode_GunGame > 0) {
				if(g_EventMode_GunGame > 0) {
					clientPrintColor(0, _, "GunGame %s en !g%d ronda%s!y - Mega Armageddon en !g%d ronda%s!y.", __GUNGAME_TYPE_NAME[g_ModeGG_Type], g_EventMode_GunGame, ((g_EventMode_GunGame != 1) ? "s" : ""), g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
				} else {
					clientPrintColor(0, _, "Mega Armageddon en !g%d ronda%s!y", g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
				}
			}
		}
	}

	changeLights();

	if(g_EventModes && !g_EventMode_GunGame && !g_FirstRound) {
		clientPrintColor(0, _, "Modificador de hoy: !tGUNGAME:!g %s!y", __GUNGAME_TYPE_NAME[g_ModeGG_Type]);
		clientPrintColor(0, _, "%s", __GUNGAME_TYPE_INFO[g_ModeGG_Type]);
	}
}

public task__StartMode() {
	startModePre(MODE_NONE);
}

public loadSpawns() {
	new const __SPAWNS_ENTS[][] = {"info_player_start", "info_player_deathmatch"};
	new Float:vecData[3];
	new iEnt;
	new i;

	for(i = 0; i < 2; ++i) {
		iEnt = -1;

		while((iEnt = find_ent_by_class(iEnt, __SPAWNS_ENTS[i])) != 0) {
			entity_get_vector(iEnt, EV_VEC_origin, vecData);

			g_Spawns[g_SpawnCount][0] = vecData[0];
			g_Spawns[g_SpawnCount][1] = vecData[1];
			g_Spawns[g_SpawnCount][2] = vecData[2];

			entity_get_vector(iEnt, EV_VEC_angles, vecData);

			g_Spawns[g_SpawnCount][3] = vecData[0];
			g_Spawns[g_SpawnCount][4] = vecData[1];
			g_Spawns[g_SpawnCount][5] = vecData[2];

			entity_get_vector(iEnt, EV_VEC_v_angle, vecData);

			g_Spawns[g_SpawnCount][6] = vecData[0];
			g_Spawns[g_SpawnCount][7] = vecData[1];
			g_Spawns[g_SpawnCount][8] = vecData[2];

			++g_SpawnCount;

			if(g_SpawnCount >= sizeof(g_Spawns)) {
				break;
			}
		}
	}
}

public loadSql() {
	arrayset(g_ModeCount, 0, structIdModes);
	arrayset(g_ModeCountAdmin, 0, structIdModes);

	new iErrorNum;
	new sErrors[MAX_FMT_LENGTH];

	g_SqlTuple = SQL_MakeDbTuple(__SERVERS[SV_ZPA][serverSqlHost], __SERVERS[SV_ZPA][serverSqlUsername], __SERVERS[SV_ZPA][serverSqlPassword], __SERVERS[SV_ZPA][serverSqlDatabase]);
	g_SqlConnection = SQL_Connect(g_SqlTuple, iErrorNum, sErrors, charsmax(sErrors));
	g_SqlQuery[0] = EOS;

	if(g_SqlConnection == Empty_Handle) {
		format(sErrors, charsmax(sErrors), "loadSql() - Error al conectarse a la base de datos [%d] - <%s>", iErrorNum, sErrors);

		log_to_file(__SQL_FILE, sErrors);
		set_fail_state(sErrors);

		return;
	}

	loadQueries();
	set_task(0.5, "task__SetConfigs");

	g_tModeAnnihilator_Acerts = TrieCreate();
	g_tExtraItem_Invisibility = TrieCreate();
	g_tExtraItem_KillBomb = TrieCreate();
	g_tExtraItem_PipeBomb = TrieCreate();
	g_tExtraItem_AntidoteBomb = TrieCreate();
	g_tExtraItem_Antidote = TrieCreate();
	g_tExtraItem_ZombieMadness = TrieCreate();
	g_tExtraItem_InfectionBomb = TrieCreate();
	g_tExtraItem_ReduceDamage = TrieCreate();
	g_tExtraItem_Petrification = TrieCreate();
}

public loadQueries() {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_maps WHERE enable='1';");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 55);
	} else if(SQL_NumResults(sqlQuery)) {
		set_cvar_string("amx_nextmap", "[ninguno]");

		g_VoteMap_Init = 0;
		g_VoteMap_MapId = -1;
		g_VoteMap_Count = 0;
		g_VoteMap_Extend = 0;
		g_VoteMap_NextRound = 0;

		while(SQL_MoreResults(sqlQuery)) {
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "mapname"), g_VoteMap_MapName[g_VoteMap_Count], charsmax(g_VoteMap_MapName[]));

			if(equali(g_VoteMap_MapName[g_VoteMap_Count], g_CurrentMap)) {
				g_VoteMap_MapId = g_VoteMap_Count;
			}

			g_VoteMap_MorePlaying[g_VoteMap_Count] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "more_playing"));
			g_VoteMap_Recent[g_VoteMap_Count] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "recent"));

			if(!g_VoteMap_Recent[g_VoteMap_Count]) {
				SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "bonus"), Float:g_VoteMap_Bonus[g_VoteMap_Count]);
			}

			++g_VoteMap_Count;

			if(g_VoteMap_Count == MAX_SERVER_MAP) {
				break;
			}

			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_maps SET more_playing=more_playing+1 WHERE mapname=^"%s^";", g_CurrentMap);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(0, sqlQuery, 56);
		} else {
			SQL_FreeHandle(sqlQuery);
		}
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	if(g_VoteMap_Count) {
		remove_task(TASK_VOTEMAP);
		set_task(180.0, "task__VoteMap", TASK_VOTEMAP, .flags="d");
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT COUNT(id) FROM zp8_accounts;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 14);
	} else if(SQL_NumResults(sqlQuery)) {
		g_GlobalRank = SQL_ReadResult(sqlQuery, 0);
		SQL_FreeHandle(sqlQuery);
	} else {
		g_GlobalRank = 0;
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_general;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 15);
	} else if(SQL_NumResults(sqlQuery)) {
		new sInfo[256];
		new sCurrentDay[4];
		new iHasChanged = 0;

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "modes"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_ModeCount, structIdModes);

		g_EventMode_MegaArmageddon = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_ma"));
		g_EventMode_GunGame = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_gg"));
		
		if(g_EventMode_MegaArmageddon == g_EventMode_GunGame) {
			++g_EventMode_MegaArmageddon;
		}

		g_ModeGG_Type = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_gg_type"));
		g_ModeGG_LastWinner = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_gg_last_winner"));
		g_ModeMGG_Played = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_mega_gg"));

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "habs_rotate"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_HabRotate_Week, 3);

		iHasChanged = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "habs_rotate_changed"));

		SQL_FreeHandle(sqlQuery);

		get_time("%A", sCurrentDay, charsmax(sCurrentDay));

		if(equal(sCurrentDay, "Tue") && !iHasChanged) {
			new i = 0;
			new j;
			new k[3];

			while(i < 3) {
				j = random_num(0, (structIdHabsRotate - 1));

				if(i > 0) {
					if(k[i - 1] == j) {
						continue;
					}
				}

				k[i] = j;
				++i;
			}

			g_HabRotate_Week = k;

			new sHabsRotate[12];
			arrayToString(g_HabRotate_Week, 3, sHabsRotate, charsmax(sHabsRotate), 1);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_general SET habs_rotate=^"%s^", habs_rotate_changed='1' WHERE id='1';", sHabsRotate);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(0, sqlQuery, 16);
			} else {
				SQL_FreeHandle(sqlQuery);
			}

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_pjs SET habs_rotate=NULL;");
			
			if(!SQL_Execute(sqlQuery)) {
				executeQuery(0, sqlQuery, 17);
			} else {
				SQL_FreeHandle(sqlQuery);
			}
		} else if(!equal(sCurrentDay, "Tue") && iHasChanged) {
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp8_general SET habs_rotate_changed='0' WHERE id='1';");

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(0, sqlQuery, 18);
			} else {
				SQL_FreeHandle(sqlQuery);
			}
		}
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection,  "SELECT zp8_achievements.achievement_id, zp8_accounts.name, zp8_achievements.achievement_timestamp FROM zp8_achievements LEFT JOIN zp8_accounts ON zp8_accounts.id=zp8_achievements.acc_id WHERE zp8_achievements.achievement_is_first='1';");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 19);
	} else if(SQL_NumResults(sqlQuery)) {
		new iAchievement;

		while(SQL_MoreResults(sqlQuery)) {
			iAchievement = SQL_ReadResult(sqlQuery, 0);

			g_Achievement[0][iAchievement] = 1;
			SQL_ReadResult(sqlQuery, 1, g_AchievementName[0][iAchievement], charsmax(g_AchievementName[][]));
			g_AchievementUnlocked[0][iAchievement] = SQL_ReadResult(sqlQuery, 2);

			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp8_accounts.name, xp, level, reset FROM zp8_pjs LEFT JOIN zp8_accounts ON zp8_accounts.id=zp8_pjs.acc_id ORDER BY reset DESC, level DESC, xp DESC LIMIT 1;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 20);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_ReadResult(sqlQuery, 0, g_TopLevel_Name, charsmax(g_TopLevel_Name));
		addDot(SQL_ReadResult(sqlQuery, 1), g_TopLevel_Exp, charsmax(g_TopLevel_Exp));
		g_TopLevel_Level = SQL_ReadResult(sqlQuery, 2);
		g_TopLevel_Reset = SQL_ReadResult(sqlQuery, 3);

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp8_accounts.name, combo_max FROM zp8_pjs_stats LEFT JOIN zp8_accounts ON zp8_accounts.id=zp8_pjs_stats.acc_id ORDER BY combo_max DESC LIMIT 1;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 21);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_ReadResult(sqlQuery, 0, g_TopCombo_Name, charsmax(g_TopCombo_Name));
		addDot(SQL_ReadResult(sqlQuery, 1), g_TopCombo_ComboMax, charsmax(g_TopCombo_ComboMax));

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp8_accounts.name, tp_d FROM zp8_pjs_stats LEFT JOIN zp8_accounts ON zp8_accounts.id=zp8_pjs_stats.acc_id ORDER BY tp_d DESC LIMIT 1;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 22);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_ReadResult(sqlQuery, 0, g_TopTime_Name, charsmax(g_TopTime_Name));
		g_TopTime_Time[0] = SQL_ReadResult(sqlQuery, 1);

		g_TopTime_Time[2] = 0;
		g_TopTime_Time[1] = (g_TopTime_Time[0] / 60);

		while(g_TopTime_Time[1] >= 24) {
			++g_TopTime_Time[2];
			g_TopTime_Time[1] -= 24;
		}

		g_TopTime_Time[0] -= ((g_TopTime_Time[1] * 60) + (g_TopTime_Time[2] * 24 * 60));

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "(SELECT name, combo_max, mapname FROM zp8_combos WHERE combo_type='0' AND mapname=^"%s^" ORDER BY combo_max DESC LIMIT 1) UNION ALL (SELECT name, combo_max, mapname FROM zp8_combos WHERE combo_type='1' AND mapname=^"%s^" ORDER BY combo_max DESC LIMIT 1);", g_CurrentMap, g_CurrentMap);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 23);
	} else if(SQL_NumResults(sqlQuery)) {
		new iRepeat = 0;

		while(SQL_MoreResults(sqlQuery)) {
			if(!iRepeat) {
				SQL_ReadResult(sqlQuery, 0, g_TopComboHPerMap_Name, charsmax(g_TopComboHPerMap_Name));
				
				g_MaxComboHumanMap = SQL_ReadResult(sqlQuery, 1);
				addDot(g_MaxComboHumanMap, g_TopComboHPerMap_ComboMax, charsmax(g_TopComboHPerMap_ComboMax));
				
				SQL_ReadResult(sqlQuery, 2, g_TopComboHPerMap_MapName, charsmax(g_TopComboHPerMap_MapName));
			} else {
				SQL_ReadResult(sqlQuery, 0, g_TopComboZPerMap_Name, charsmax(g_TopComboZPerMap_Name));
				
				g_MaxComboZombieMap = SQL_ReadResult(sqlQuery, 1);
				addDot(g_MaxComboZombieMap, g_TopComboZPerMap_ComboMax, charsmax(g_TopComboZPerMap_ComboMax));
				
				SQL_ReadResult(sqlQuery, 2, g_TopComboZPerMap_MapName, charsmax(g_TopComboZPerMap_MapName));
			}

			++iRepeat;

			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	new iEnt = create_entity("info_target");

	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, __ENTTHINK_CLASSNAME_TOP_LEADER);
		entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 600.0));

		register_think(__ENTTHINK_CLASSNAME_TOP_LEADER, "think__TopLeader");
	}
}

public think__TopLeader(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}

	switch(g_TopLeader) {
		case 0: {
			clientPrintColor(0, _, "!t%s!y está liderando en !gniveles!y siendo !greset %d!y con !g%d nivel%s!y y !g%s XP!y", g_TopLevel_Name, g_TopLevel_Reset, g_TopLevel_Level, ((g_TopLevel_Level != 1) ? "es" : ""), g_TopLevel_Exp);
		} case 1: {
			if(g_TopCombo_Name[0]) {
				clientPrintColor(0, _, "!t%s!y está liderando en !gcombo máximo general!y con un combo de !gx%s!y", g_TopCombo_Name, g_TopCombo_ComboMax);
			}
		} case 2: {
			if(g_TopComboHPerMap_Name[0]) {
				clientPrintColor(0, _, "!t%s!y está liderando en !gcombo máximo humano!y en el mapa !g%s!y con un combo de !gx%s!y", g_TopComboHPerMap_Name, g_TopComboHPerMap_MapName, g_TopComboHPerMap_ComboMax);
			}
		} case 3: {
			if(g_TopComboZPerMap_Name[0]) {
				clientPrintColor(0, _, "!t%s!y está liderando en !gcombo máximo zombie!y en el mapa !g%s!y con un combo de !gx%s!y", g_TopComboZPerMap_Name, g_TopComboZPerMap_MapName, g_TopComboZPerMap_ComboMax);
			}
		} case 4: {
			clientPrintColor(0, _, "!t%s!y es el más viciado del servidor con !g%d día%s!y, !g%d hora%s!y y !g%d minuto%s!y jugados", g_TopTime_Name, g_TopTime_Time[2], ((g_TopTime_Time[2] != 1) ? "s" : ""), g_TopTime_Time[1], ((g_TopTime_Time[1] != 1) ? "s" : ""), g_TopTime_Time[0], ((g_TopTime_Time[0] != 1) ? "s" : ""));
		}
	}

	if(++g_TopLeader == 5) {
		g_TopLeader = 0;
	}

	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 600.0));
}

public task__SetConfigs() {
	server_cmd("hostname ^"#08 ZOMBIE PLAGUE ANNIHILATION [%s] | www.DrunkGaming.net^"", __PLUGIN_VERSION);

	set_cvar_num("allow_spectators", 1);

	set_cvar_num("sv_alltalk", 1);
	set_cvar_num("sv_voicequality", 5);
	set_cvar_num("sv_airaccelerate", 100);
	set_cvar_num("sv_maxspeed", 9999);
	set_cvar_num("mp_flashlight", 1);
	set_cvar_num("mp_footsteps", 1);
	set_cvar_num("mp_freezetime", 0);
	set_cvar_num("mp_friendlyfire", 0);
	set_cvar_num("mp_timelimit", 30);
	set_cvar_num("mp_limitteams", 0);
	set_cvar_num("mp_autoteambalance", 0);
	set_cvar_num("mp_round_infinite", 0);
	set_cvar_num("mp_freeforall", 0);
	set_cvar_num("sv_voiceenable", 1);	

	set_cvar_float("mp_roundtime", 6.0);

	set_cvar_string("sv_voicecodec", "voice_speex");

	server_cmd("sv_restart 1");
}

public executeQuery(const id, const Handle:query, const query_id) {
	new sErrors[MAX_FMT_LENGTH];
	SQL_QueryError(query, sErrors, charsmax(sErrors));
	log_to_file(__SQL_FILE, "executeQuery - [%d] - <%s>", query_id, sErrors);

	if(isPlayerValidConnected(id)) {
		rh_drop_client(id, fmt("Hubo un error al guardar/cargar tus datos. Por seguridad has sido expulsado, inténtalo más tarde.", get_user_userid(id)));
	}

	SQL_FreeHandle(query);
}

public executePrepareQuery(const id, const query[], const query_id) {
	static sQuery[2048];
	static Handle:sqlQuery;

	vformat(sQuery, charsmax(sQuery), query, 3);
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, sQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, query_id);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

saveInfo(const id, const disconnect=0, const prepare_query=0) {
	if(g_AccountStatus[id] < STATUS_LOGGED || !g_AccountId[id] || g_DataSaved) {
		return;
	}

	if(disconnect) {
		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_accounts SET last_ip=^"%s^", last_steam=^"%s^", last_connection='%d' WHERE id='%d';", g_PlayerIp[id], g_PlayerSteamId[id], get_arg_systime(), g_AccountId[id]);

		if(prepare_query) {
			executePrepareQuery(id, g_SqlQuery, 001);
		} else {
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		}
	}

	static sWeapons[16];
	static sEICount[256];
	static sDifficults[16];
	static sPoints[64];
	static sPointsLost[64];
	static sHabs[128];
	static sHabsRotate[64];
	static sArtifacts[32];
	static sArtifactsEquiped[32];
	static sHeadZombies[64];
	static iLen;

	formatex(sWeapons, charsmax(sWeapons), "%d %d %d %d", g_WeaponAutoBuy[id], g_WeaponPrimary_Selection[id], g_WeaponSecondary_Selection[id], g_WeaponCuaternary_Selection[id]);
	arrayToString(g_ExtraItem_Count[id], structIdExtraItems, sEICount, charsmax(sEICount), 1);
	arrayToString(g_Difficult[id], structIdDifficultsClasses, sDifficults, charsmax(sDifficults), 1);
	arrayToString(g_Points[id], structIdPoints, sPoints, charsmax(sPoints), 1);
	arrayToString(g_PointsLost[id], structIdPoints, sPointsLost, charsmax(sPointsLost), 1);
	arrayToString(g_Hab[id], structIdHabs, sHabs, charsmax(sHabs), 1);
	arrayToString(g_HabRotate[id], structIdHabsRotate, sHabsRotate, charsmax(sHabsRotate), 1);
	arrayToString(g_Artifact[id], structIdArtifacts, sArtifacts, charsmax(sArtifacts), 1);
	arrayToString(g_ArtifactsEquiped[id], structIdArtifacts, sArtifactsEquiped, charsmax(sArtifactsEquiped), 1);
	arrayToString(g_HeadZombie[id], structIdHeadZombies, sHeadZombies, charsmax(sHeadZombies), 1);

	iLen = 0;
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE zp8_pjs ");
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "SET aps_total='%d', best_aps_in_round='%d', best_aps_in_map='%d', xp='%d', level='%d', reset='%d', weapons=^"%s^", ei_count=^"%s^", difficults=^"%s^", points=^"%s^", points_lost=^"%s^", ", g_AmmoPacksTotal[id], g_AmmoPacks_BestRoundHistory[id], g_AmmoPacks_BestMapHistory[id], g_XP[id], g_Level[id], g_Reset[id], sWeapons, sEICount, sDifficults, sPoints, sPointsLost);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "habs=^"%s^", habs_rotate=^"%s^", artifacts=^"%s^", artifacts_equiped=^"%s^", hat_id='%d', mastery='%d', headzombies=^"%s^", gifts='%d' ", sHabs, sHabsRotate, sArtifacts, sArtifactsEquiped, g_HatId[id], g_Mastery[id], sHeadZombies, g_Gift[id]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE acc_id='%d';", g_AccountId[id]);

	if(prepare_query) {
		executePrepareQuery(id, g_SqlQuery, 002);
	} else {
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
	}

	iLen = 0;
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE zp8_pjs_stats ");
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "SET tp_d=`tp_d`+%d, dmg_d='%f', dmg_t='%f', hs_d='%d', hs_t='%d', hm_d='%d', hm_t='%d', ", g_PlayedTime[id][TIME_SEC], g_StatsDamage[id][0], g_StatsDamage[id][1], g_Stats[id][STAT_HS_D], g_Stats[id][STAT_HS_T], g_Stats[id][STAT_HM_D], g_Stats[id][STAT_HM_T], g_Stats[id][STAT_HM_T]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "zm_d='%d', zm_t='%d', inf_d='%d', inf_t='%d', zmhs_d='%d', zmhs_t='%d', zmk_d='%d', zmk_t='%d', ", g_Stats[id][STAT_ZM_D], g_Stats[id][STAT_ZM_T], g_Stats[id][STAT_INF_D], g_Stats[id][STAT_INF_T], g_Stats[id][STAT_ZMHS_D], g_Stats[id][STAT_ZMHS_T], g_Stats[id][STAT_ZMK_D], g_Stats[id][STAT_ZMK_T]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "ap_d='%d', ap_t='%d', combo_max='%d', s_m_kill='%d', w_m_kill='%d', l_m_kill='%d', t_m_kill='%d', sn_m_kill='%d', ", g_Stats[id][STAT_AP_D], g_Stats[id][STAT_AP_T], g_Stats[id][STAT_COMBO_MAX], g_Stats[id][STAT_S_M_KILL], g_Stats[id][STAT_W_M_KILL], g_Stats[id][STAT_L_M_KILL], g_Stats[id][STAT_T_M_KILL], g_Stats[id][STAT_SN_M_KILL]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "nem_m_kill='%d', cab_m_kill='%d', ann_m_kill='%d', flesh_m_kill='%d', ma_wins='%d', gg_wins='%d', df_wins='%d' ", g_Stats[id][STAT_NEM_M_KILL], g_Stats[id][STAT_CAB_M_KILL], g_Stats[id][STAT_ANN_M_KILL], g_Stats[id][STAT_FLESH_M_KILL], g_Stats[id][STAT_MA_WINS], g_Stats[id][STAT_GG_WINS], g_Stats[id][STAT_DF_WINS]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE acc_id='%d';", g_AccountId[id]);

	if(prepare_query) {
		executePrepareQuery(id, g_SqlQuery, 003);
	} else {
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
	}

	saveInfoWeapons(id, .stats=0, .prepare_query=1);
}

saveInfoWeapons(const id, const stats=0, const prepare_query=0) {
	new i;
	for(i = 1; i < 31; ++i) {
		if(!g_WeaponSave[id][i]) {
			continue;
		}

		if(stats) {
			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_weapons SET kills='%d', damage='%f' WHERE acc_id='%d' AND weapon_id='%d';", g_WeaponData[id][i][WEAPON_DATA_KILL_DONE], g_WeaponData[id][i][WEAPON_DATA_DAMAGE_DONE], g_AccountId[id], i);
		} else {
			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_weapons SET kills='%d', damage='%f', level='%d', points='%d', skin='%d', time='%d', skill_damage='%d', skill_speed='%d', skill_recoil='%d', skill_bullets='%d', skill_reload_speed='%d', skill_critical_probability='%d' WHERE acc_id='%d' AND weapon_id='%d';", g_WeaponData[id][i][WEAPON_DATA_KILL_DONE], g_WeaponData[id][i][WEAPON_DATA_DAMAGE_DONE], g_WeaponData[id][i][WEAPON_DATA_LEVEL], g_WeaponData[id][i][WEAPON_DATA_POINTS], g_WeaponModel[id][i], g_WeaponData[id][i][WEAPON_DATA_TIME_PLAYED_DONE], g_WeaponSkills[id][i][WEAPON_SKILL_DAMAGE], g_WeaponSkills[id][i][WEAPON_SKILL_SPEED], g_WeaponSkills[id][i][WEAPON_SKILL_RECOIL], g_WeaponSkills[id][i][WEAPON_SKILL_BULLETS], g_WeaponSkills[id][i][WEAPON_SKILL_RELOAD_SPEED], g_WeaponSkills[id][i][WEAPON_SKILL_CRITICAL_PROBABILITY], g_AccountId[id], i);
		}

		if(prepare_query) {
			executePrepareQuery(id, g_SqlQuery, 004);
		} else {
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		}

		g_WeaponSave[id][i] = 0;
	}
}

public loadInfo(const id) {
	if(g_AccountStatus[id] != STATUS_LOADING) {
		return;
	}

	new iArgs[1];
	iArgs[0] = id;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM zp8_pjs LEFT JOIN zp8_pjs_stats ON zp8_pjs_stats.acc_id=zp8_pjs.acc_id WHERE zp8_pjs.acc_id='%d';", g_AccountId[id]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadInfo", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__LoadInfo(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadInfo() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al cargar los datos de tu personaje. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	if(!SQL_NumResults(query)) {
		rh_drop_client(iId, fmt("Hubo un error al cargar los datos de tu personaje [SQLR]. Contáctese con el desarrollador para más información e inténtalo más tarde", get_user_userid(iId)));
		return;
	}

	remove_task(iId + TASK_SAVE);
	remove_task(iId + TASK_PLAYED_TIME);

	set_task(random_float(300.0, 600.0), "task__Save", iId + TASK_SAVE, .flags="b");
	set_task(360.0, "task__PlayedTime", iId + TASK_PLAYED_TIME, .flags="b");

	static sInfo[256];
	static sWeapons[4][6];
	static sHudPosition[3][64];
	static iTimePlayed;
	static Float:iPlayedTimePerDaySec;
	static i;

	g_Benefit[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "benefit_timestamp"));

	if(g_Benefit[iId] != 0 && get_arg_systime() > g_Benefit[iId]) {
		g_Benefit[iId] = 1;
	}

	g_AmmoPacksTotal[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "aps_total"));
	g_AmmoPacks_BestRoundHistory[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "best_aps_in_round"));
	g_AmmoPacks_BestMapHistory[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "best_aps_in_map"));

	g_XP[iId] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "xp")), 0, MAX_XP);
	addDot(g_XP[iId], g_XPHud[iId], charsmax(g_XPHud[]));

	g_Level[iId] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "level")), 1, MAX_LEVEL);
	g_Reset[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "reset"));

	checkXPEquation(iId);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "weapons"), sInfo, charsmax(sInfo));
	parse(sInfo, sWeapons[0], charsmax(sWeapons[]), sWeapons[1], charsmax(sWeapons[]), sWeapons[2], charsmax(sWeapons[]), sWeapons[3], charsmax(sWeapons[]));

	g_WeaponAutoBuy[iId] = str_to_num(sWeapons[0]);
	g_WeaponPrimary_Selection[iId] = str_to_num(sWeapons[1]);
	g_WeaponSecondary_Selection[iId] = str_to_num(sWeapons[2]);
	g_WeaponCuaternary_Selection[iId] = str_to_num(sWeapons[3]);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "ei_count"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_ExtraItem_Count[iId], structIdExtraItems);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "difficults"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_Difficult[iId], structIdDifficultsClasses);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "points"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_Points[iId], structIdPoints);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "points_lost"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_PointsLost[iId], structIdPoints);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "habs"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_Hab[iId], structIdHabs);

	for(i = 0; i < structIdHabs; ++i) {
		if(!__HABS[i][habEnabled] && g_Hab[iId][i]) {
			g_Hab[iId][i] = 0;

			g_Points[iId][__HABS_CLASSES[__HABS[i][habClass]][habClassPointId]] += __HABS[i][habCost];
			g_PointsLost[iId][__HABS_CLASSES[__HABS[i][habClass]][habClassPointId]] -= __HABS[i][habCost];
		}

		if(g_Hab[iId][i] > __HABS[i][habMaxLevel]) {
			g_Hab[iId][i] = __HABS[i][habMaxLevel];
		}
	}

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "habs_rotate"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_HabRotate[iId], structIdHabsRotate);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "artifacts"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_Artifact[iId], structIdArtifacts);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "artifacts_equiped"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_ArtifactsEquiped[iId], structIdArtifacts);

	g_HatId[iId] = g_HatNext[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hat_id"));
	g_Mastery[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "mastery"));
		
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "headzombies"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_HeadZombie[iId], structIdHeadZombies);

	g_Gift[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "gifts"));

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "color_hud_general"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_UserOptions_Color[iId][COLOR_TYPE_HUD_GENERAL], 3);
		
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "color_hud_combo"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_UserOptions_Color[iId][COLOR_TYPE_HUD_COMBO], 3);
		
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "color_nvision"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_UserOptions_Color[iId][COLOR_TYPE_NVISION], 3);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "color_flare"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_UserOptions_Color[iId][COLOR_TYPE_FLARE], 3);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "color_crew_glow"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_UserOptions_Color[iId][COLOR_TYPE_GROUP_GLOW], 3);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_general_position"), sInfo, charsmax(sInfo));
	parse(sInfo, sHudPosition[0], charsmax(sHudPosition[]), sHudPosition[1], charsmax(sHudPosition[]), sHudPosition[2], charsmax(sHudPosition[]));

	g_UserOptions_Hud[iId][HUD_TYPE_GENERAL][0] = str_to_float(sHudPosition[0]);
	g_UserOptions_Hud[iId][HUD_TYPE_GENERAL][1] = str_to_float(sHudPosition[1]);
	g_UserOptions_Hud[iId][HUD_TYPE_GENERAL][2] = str_to_float(sHudPosition[2]);

	g_UserOptions_HudEffect[iId][HUD_TYPE_GENERAL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_general_effect"));
	g_UserOptions_HudStyle[iId][HUD_TYPE_GENERAL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_general_style"));

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_combo_position"), sInfo, charsmax(sInfo));
	parse(sInfo, sHudPosition[0], charsmax(sHudPosition[]), sHudPosition[1], charsmax(sHudPosition[]), sHudPosition[2], charsmax(sHudPosition[]));

	g_UserOptions_Hud[iId][HUD_TYPE_COMBO][0] = str_to_float(sHudPosition[0]);
	g_UserOptions_Hud[iId][HUD_TYPE_COMBO][1] = str_to_float(sHudPosition[1]);
	g_UserOptions_Hud[iId][HUD_TYPE_COMBO][2] = str_to_float(sHudPosition[2]);

	g_UserOptions_HudEffect[iId][HUD_TYPE_COMBO] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_combo_effect"));
	g_UserOptions_HudStyle[iId][HUD_TYPE_COMBO] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_combo_style"));
		
	g_UserOptions_NVision[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_nvision"));
	g_UserOptions_ChatMode[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_chatmode"));
	g_UserOptions_Invis[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_invis"));
	g_UserOptions_GroupGlow[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_crew_glow"));
	g_UserOptions_CurrentMode[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_current_mode"));
	g_BuyStuff[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "bought_ok"));

	iTimePlayed = SQL_ReadResult(query, SQL_FieldNameToNum(query, "tp_d"));
	iPlayedTimePerDaySec = float((g_AccountSinceConnection[iId] - get_arg_systime())) / float(iTimePlayed);

	while(iTimePlayed >= 86400) {
		iTimePlayed -= 86400;
		++g_PlayedTime[iId][TIME_DAY];
	}

	while(iTimePlayed >= 3600) {
		iTimePlayed -= 3600;
		++g_PlayedTime[iId][TIME_HOUR];
	}

	g_PlayedTime_PerDay[iId] = (iPlayedTimePerDaySec / 60.0) / 60.0;

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "dmg_d"), Float:g_StatsDamage[iId][0]);
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "dmg_t"), Float:g_StatsDamage[iId][1]);
	g_Stats[iId][STAT_HS_D] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hs_d"));
	g_Stats[iId][STAT_HS_T] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hs_t"));
	g_Stats[iId][STAT_HM_D] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hm_d"));
	g_Stats[iId][STAT_HM_T] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hm_t"));
	g_Stats[iId][STAT_ZM_D] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zm_d"));
	g_Stats[iId][STAT_ZM_T] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zm_t"));
	g_Stats[iId][STAT_INF_D] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "inf_d"));
	g_Stats[iId][STAT_INF_T] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "inf_t"));
	g_Stats[iId][STAT_ZMHS_D] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zmhs_d"));
	g_Stats[iId][STAT_ZMHS_T] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zmhs_t"));
	g_Stats[iId][STAT_ZMK_D] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zmk_d"));
	g_Stats[iId][STAT_ZMK_T] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zmk_t"));
	g_Stats[iId][STAT_AP_D] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "ap_d"));
	g_Stats[iId][STAT_AP_T] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "ap_t"));
	g_Stats[iId][STAT_COMBO_MAX] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "combo_max"));
	g_Stats[iId][STAT_S_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "s_m_kill"));
	g_Stats[iId][STAT_W_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "w_m_kill"));
	g_Stats[iId][STAT_L_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "l_m_kill"));
	g_Stats[iId][STAT_T_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "t_m_kill"));
	g_Stats[iId][STAT_SN_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "sn_m_kill"));
	g_Stats[iId][STAT_NEM_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "nem_m_kill"));
	g_Stats[iId][STAT_CAB_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "cab_m_kill"));
	g_Stats[iId][STAT_ANN_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "ann_m_kill"));
	g_Stats[iId][STAT_FLESH_M_KILL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "flesh_m_kill"));
	g_Stats[iId][STAT_MA_WINS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "ma_wins"));
	g_Stats[iId][STAT_GG_WINS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "gg_wins"));
	g_Stats[iId][STAT_DF_WINS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "df_wins"));

	g_AccountLoading_Steps[iId] = 4;

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM zp8_weapons WHERE acc_id='%d' ORDER BY level DESC;", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadWeapons", g_SqlQuery, iArgs, sizeof(iArgs));

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM zp8_achievements WHERE acc_id='%d';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadAchievements", g_SqlQuery, iArgs, sizeof(iArgs));

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM zp8_hats WHERE acc_id='%d';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadHats", g_SqlQuery, iArgs, sizeof(iArgs));

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM zp8_amulets_custom WHERE acc_id='%d' AND active='1';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadAmulets", g_SqlQuery, iArgs, sizeof(iArgs));

	g_PointsInDiamond[iId] = g_PointsInDiamondShow[iId] = (g_Points[iId][P_DIAMONDS] + g_PointsLost[iId][P_DIAMONDS]);

	if(g_PointsInDiamond[iId] >= __ARTIFACTS[ARTIFACT_BRACELET_AMMOPACKS][artifactCost] && g_ArtifactsEquiped[iId][ARTIFACT_BRACELET_AMMOPACKS]) {
		g_PointsInDiamond[iId] -= __ARTIFACTS[ARTIFACT_BRACELET_AMMOPACKS][artifactCost];
	}

	if(g_PointsInDiamond[iId] >= __ARTIFACTS[ARTIFACT_BRACELET_XP][artifactCost] && g_ArtifactsEquiped[iId][ARTIFACT_BRACELET_XP]) {
		g_PointsInDiamond[iId] -= __ARTIFACTS[ARTIFACT_BRACELET_XP][artifactCost];
	}

	if(g_PointsInDiamond[iId] >= __ARTIFACTS[ARTIFACT_BRACELET_COMBO][artifactCost] && g_ArtifactsEquiped[iId][ARTIFACT_BRACELET_COMBO]) {
		g_PointsInDiamond[iId] -= __ARTIFACTS[ARTIFACT_BRACELET_COMBO][artifactCost];
	}

	if(g_PointsInDiamond[iId] >= __ARTIFACTS[ARTIFACT_BRACELET_POINTS][artifactCost] && g_ArtifactsEquiped[iId][ARTIFACT_BRACELET_POINTS]) {
		g_PointsInDiamond[iId] -= __ARTIFACTS[ARTIFACT_BRACELET_POINTS][artifactCost];
	}

	if(g_PointsInDiamond[iId] >= __ARTIFACTS[ARTIFACT_BRACELET_DAMAGE][artifactCost] && g_ArtifactsEquiped[iId][ARTIFACT_BRACELET_DAMAGE]) {
		g_PointsInDiamond[iId] -= __ARTIFACTS[ARTIFACT_BRACELET_DAMAGE][artifactCost];
	}

	if(g_Hab[iId][HAB_L_MULT_AMMOPACKS]) {
		g_AmmoPacksMult_Legendary[iId] = (0.1 * float(g_Hab[iId][HAB_L_MULT_AMMOPACKS]));
	}

	if(g_Hab[iId][HAB_L_MULT_XP]) {
		g_XPMult_Legendary[iId] = (0.2 * float(g_Hab[iId][HAB_L_MULT_XP]));
	}

	remove_task(iId + TASK_CHECK_BUY);
	set_task(random_float(5.0, 10.0), "task__CheckBuy", iId + TASK_CHECK_BUY);

	if(!g_ConnectedToday[iId]) {
		g_ConnectedToday[iId] = 1;

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_accounts SET connected_today='1' WHERE id='%d';", g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
	}

	updateMultipliersVars(iId);
}

public sqlThread__LoadWeapons(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadWeapons() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al cargar los datos de tus armas. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	g_WeaponModel[iId][CSW_KNIFE] = 1;

	if(SQL_NumResults(query)) {
		new iWeaponId;
		new iNot;
		new iSeconds;

		while(SQL_MoreResults(query)) {
			iWeaponId = SQL_ReadResult(query, SQL_FieldNameToNum(query, "weapon_id"));

			g_WeaponData[iId][iWeaponId][WEAPON_DATA_KILL_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "kills"));
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "damage"), Float:g_WeaponData[iId][iWeaponId][WEAPON_DATA_DAMAGE_DONE]);
			g_WeaponData[iId][iWeaponId][WEAPON_DATA_LEVEL] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "level")), 0, 25);

			g_WeaponData[iId][iWeaponId][WEAPON_DATA_POINTS] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "points")), 0, 25);
			g_WeaponModel[iId][iWeaponId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "skin"));
			g_WeaponData[iId][iWeaponId][WEAPON_DATA_TIME_PLAYED_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "time"));
			g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_DAMAGE] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "skill_damage")), 0, 10);
			g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "skill_speed")), 0, 5);
			g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "skill_recoil")), 0, 10);
			g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_BULLETS] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "skill_bullets")), 0, 10);
			g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RELOAD_SPEED] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "skill_reload_speed")), 0, 5);
			g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_CRITICAL_PROBABILITY] = clamp(SQL_ReadResult(query, SQL_FieldNameToNum(query, "skill_critical_probability")), 0, 10);

			if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_CRITICAL_PROBABILITY]) {
				g_CriticalChance[iId] = (g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_CRITICAL_PROBABILITY] * 2);
			}

			iNot = 0;
			iSeconds = g_WeaponData[iId][iWeaponId][WEAPON_DATA_TIME_PLAYED_DONE];

			while(iSeconds >= 86400) {
				iNot = 1;

				iSeconds -= 86400;
				++g_WeaponData[iId][iWeaponId][WEAPON_DATA_TPD_DAYS];
			}

			while(iSeconds >= 3600) {
				iSeconds -= 3600;
				++g_WeaponData[iId][iWeaponId][WEAPON_DATA_TPD_HOURS];
			}

			if(!iNot) {
				while(iSeconds >= 60) {
					iSeconds -= 60;
					++g_WeaponData[iId][iWeaponId][WEAPON_DATA_TPD_MINUTES];
				}
			}

			SQL_NextRow(query);
		}
	}

	loadInfoEnd(iId);
}

public sqlThread__LoadAchievements(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadAchievements() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al cargar los datos de tus logros. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	if(SQL_NumResults(query)) {
		new iAchievement;

		while(SQL_MoreResults(query)) {
			iAchievement = SQL_ReadResult(query, SQL_FieldNameToNum(query, "achievement_id"));

			g_Achievement[iId][iAchievement] = 1;
			g_AchievementUnlocked[iId][iAchievement] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "achievement_timestamp"));
			++g_AchievementTotal[iId];

			SQL_NextRow(query);
		}
	}

	remove_task(iId + TASK_CHECK_ACHIEVEMENTS);
	set_task(10.0, "task__CheckAchievements", iId + TASK_CHECK_ACHIEVEMENTS);
	
	if(g_AchievementTotal[iId]) {
		g_AmmoPacksMult_Achievements[iId] = (0.0022 * float(g_AchievementTotal[iId]));
		g_XPMult_Achievements[iId] = (0.0066 * float(g_AchievementTotal[iId]));
	}

	loadInfoEnd(iId);
}

public sqlThread__LoadHats(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadHats() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al cargar los datos de tus gorros. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	if(SQL_NumResults(query)) {
		new iHatId;

		while(SQL_MoreResults(query)) {
			iHatId = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hat_id"));

			g_Hat[iId][iHatId] = 1;
			g_HatUnlocked[iId][iHatId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hat_timestamp"));
			++g_HatTotal[iId];

			SQL_NextRow(query);
		}
	}

	remove_task(iId + TASK_CHECK_HATS);
	set_task(10.0, "task__CheckHats", iId + TASK_CHECK_HATS);

	loadInfoEnd(iId);
}

public sqlThread__LoadAmulets(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadAmulets() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al cargar los datos de tus amuletos. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	g_AmuletCustomCreated[iId] = 0;

	if(SQL_NumResults(query)) {
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "name"), g_AmuletCustomName[iId], charsmax(g_AmuletCustomName[]));
		g_AmuletCustom[iId][acHealth] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "a_health"));
		g_AmuletCustom[iId][acSpeed] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "a_speed"));
		g_AmuletCustom[iId][acGravity] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "a_gravity"));
		g_AmuletCustom[iId][acDamage] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "a_damage"));
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "a_aps"), Float:g_AmuletCustom[iId][acMultAmmoPacks]);
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "a_xp"), Float:g_AmuletCustom[iId][acMultXP]);
		g_AmuletCustom[iId][acMultCombo] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "a_combo"));

		g_AmuletCustomCreated[iId] = 1;
	}

	loadInfoEnd(iId);
}

public loadInfoEnd(const id) {
	++g_AccountLoading[id];

	if(g_AccountLoading[id] != g_AccountLoading_Steps[id]) {
		return;
	}

	g_AccountStatus[id] = STATUS_LOGGED;
	showMenu__Join(id);
}

// public getPointsInDiamond(const id) {
	// new i;
	// new j = 0;
	// new k = 0;
	// new iTotal = 0;

	// for(i = 0; i < structIdHabs; ++i) {
		// if(__HABS[i][habClass] == HAB_CLASS_LEGENDARY) {
			// j = 0;
			// k = g_Hab[id][i];

			// while(k && j < k) {
				// iTotal += getHabCost(id, j);
				// ++j;
			// }
		// }
	// }

	// return iTotal;
// }

public task__CheckHats(const task_id) {
	new iId = (task_id - TASK_CHECK_HATS);

	if(!g_IsConnected[iId] || g_AccountStatus[iId] < STATUS_LOGGED) {
		return;
	}

	if(g_Stats[iId][STAT_ZM_D] >= 2500) {
		giveHat(iId, HAT_ANGEL);
	}

	if(g_Stats[iId][STAT_INF_D] >= 2500) {
		giveHat(iId, HAT_AWESOME);
	}

	if(g_Stats[iId][STAT_S_M_KILL] >= 100) {
		giveHat(iId, HAT_JACKOLANTERN);
	}

	if(g_Stats[iId][STAT_NEM_M_KILL] >= 100) {
		giveHat(iId, HAT_JAMACA);
	}

	if(g_Achievement[iId][BOMBA_FALLIDA] && g_Achievement[iId][VIRUS]) {
		giveHat(iId, HAT_PSYCHO);
	}

	if(g_Stats[iId][STAT_ZMK_D] >= 500) {
		giveHat(iId, HAT_SASHA);
	}

	if(g_WeaponData[iId][CSW_KNIFE][WEAPON_DATA_LEVEL] >= 15) {
		giveHat(iId, HAT_SPARTAN);
	}

	if(g_Hab[iId][HAB_H_SPEED] == __HABS[HAB_H_SPEED][habMaxLevel] &&
	g_Hab[iId][HAB_H_GRAVITY] == __HABS[HAB_H_GRAVITY][habMaxLevel] &&
	g_Hab[iId][HAB_Z_SPEED] == __HABS[HAB_Z_SPEED][habMaxLevel] &&
	g_Hab[iId][HAB_Z_GRAVITY] == __HABS[HAB_Z_GRAVITY][habMaxLevel]) {
		giveHat(iId, HAT_SUPER_MAN);
	}

	if(g_Reset[iId] >= 50) {
		giveHat(iId, HAT_TYNO);
	}

	if(g_PlayedTime[iId][TIME_DAY] >= 15) {
		giveHat(iId, HAT_VIKING);
	}
}

public task__CheckAchievements(const task_id) {
	new iId = (task_id - TASK_CHECK_ACHIEVEMENTS);

	if(!g_IsConnected[iId] || g_AccountStatus[iId] < STATUS_LOGGED) {
		return;
	}

	if(!g_Achievement[iId][CUENTA_PAR] && !g_Achievement[iId][CUENTA_IMPAR]) {
		if((g_AccountId[iId] % 2) == 0) {
			setAchievement(iId, CUENTA_PAR);
		} else {
			setAchievement(iId, CUENTA_IMPAR);
		}
	}

	if(get_user_flags(iId) & ADMIN_RESERVATION) {
		setAchievement(iId, SOY_DORADO);
		giveHat(iId, HAT_GOLD_HEAD);
	}

	if(g_AmmoPacksTotal[iId] >= 1000) {
		setAchievement(iId, AMMOPACKS_x1000);

		if(g_AmmoPacksTotal[iId] >= 5000) {
			setAchievement(iId, AMMOPACKS_x5000);

			if(g_AmmoPacksTotal[iId] >= 10000) {
				setAchievement(iId, AMMOPACKS_x10000);

				if(g_AmmoPacksTotal[iId] >= 50000) {
					setAchievement(iId, AMMOPACKS_x50000);

					if(g_AmmoPacksTotal[iId] >= 100000) {
						setAchievement(iId, AMMOPACKS_x100000);

						if(g_AmmoPacksTotal[iId] >= 500000) {
							setAchievement(iId, AMMOPACKS_x500000);

							if(g_AmmoPacksTotal[iId] >= 1000000) {
								setAchievement(iId, AMMOPACKS_x1000000);

								if(g_AmmoPacksTotal[iId] >= 5000000) {
									setAchievement(iId, AMMOPACKS_x5000000);

									if(g_AmmoPacksTotal[iId] >= 10000000) {
										setAchievement(iId, AMMOPACKS_x10000000);

										if(g_AmmoPacksTotal[iId] >= 50000000) {
											setAchievement(iId, AMMOPACKS_x50000000);

											if(g_AmmoPacksTotal[iId] >= 100000000) {
												setAchievement(iId, AMMOPACKS_x100000000);

												if(g_AmmoPacksTotal[iId] >= 250000000) {
													setAchievement(iId, AMMOPACKS_x250000000);

													if(g_AmmoPacksTotal[iId] >= 500000000) {
														setAchievement(iId, AMMOPACKS_x500000000);
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	if(g_StatsDamage[iId][0] >= 1000.0) {
		setAchievement(iId, MIRA_MI_DANIO);

		if(g_StatsDamage[iId][0] >= 5000.0) {
			setAchievement(iId, MAS_Y_MAS_DANIO);

			if(g_StatsDamage[iId][0] >= 10000.0) {
				setAchievement(iId, LLEGUE_AL_MILLON);

				if(g_StatsDamage[iId][0] >= 50000.0) {
					if(g_StatsDamage[iId][0] >= 250000.0) {
						if(g_StatsDamage[iId][0] >= 500000.0) {
							if(g_StatsDamage[iId][0] >= 1000000.0) {
								if(g_StatsDamage[iId][0] >= 5000000.0) {
									if(g_StatsDamage[iId][0] >= 10000000.0) {
										if(g_StatsDamage[iId][0] >= 50000000.0) {
											if(g_StatsDamage[iId][0] >= 200000000.0) {
												if(g_StatsDamage[iId][0] >= 500000000.0) {
													if(g_StatsDamage[iId][0] >= 1000000000.0) {
														if(g_StatsDamage[iId][0] >= 2100000000.0) {
															setAchievement(iId, NO_SE_LEER_ESTE_NUMERO);
														} else {
															setAchievement(iId, ME_ABURRO);
														}
													} else {
														setAchievement(iId, SE_ME_BUGUEO_EL_DANIO);
													}
												} else {
													setAchievement(iId, MUCHOS_NUMEROS);
												}
											} else {
												setAchievement(iId, MI_DANIO_ES_NUCLEAR);
											}
										} else {
											setAchievement(iId, MI_DANIO_ES_CATASTROFICO);
										}
									} else {
										setAchievement(iId, YA_PERDI_LA_CUENTA);
									}
								} else {
									setAchievement(iId, CONTADOR_DE_DANIOS);
								}
							} else {
								setAchievement(iId, VAMOS_POR_LOS_50_MILLONES);
							}
						} else {
							setAchievement(iId, MI_DANIO_CRECE_Y_CRECE);
						}
					} else {
						setAchievement(iId, MI_DANIO_CRECE);
					}
				}
			}
		}
	}

	if(g_Stats[iId][STAT_HS_D] < 10000000) {
		if(g_Stats[iId][STAT_HS_D] < 5000000) {
			if(g_Stats[iId][STAT_HS_D] < 1000000) {
				if(g_Stats[iId][STAT_HS_D] < 500000) {
					if(g_Stats[iId][STAT_HS_D] < 300000) {
						if(g_Stats[iId][STAT_HS_D] < 150000) {
							if(g_Stats[iId][STAT_HS_D] < 50000) {
								if(g_Stats[iId][STAT_HS_D] < 15000) {
									if(g_Stats[iId][STAT_HS_D] >= 5000) {
										setAchievement(iId, CABEZITA);
									}
								} else {
									setAchievement(iId, A_PLENO);
								}
							} else {
								setAchievement(iId, ROMPIENDO_CABEZAS);
							}
						} else {
							setAchievement(iId, ABRIENDO_CEREBROS);
						}
					} else {
						setAchievement(iId, PERFORANDO);
					}
				} else {
					setAchievement(iId, DESCOCANDO);
				}
			} else {
				setAchievement(iId, ROMPECRANEOS);
			}
		} else {
			setAchievement(iId, DUCK_HUNT);
		}
	} else {
		setAchievement(iId, AIMBOT);
	}

	if(g_AccountVinc[iId]) {
		setAchievement(iId, VINCULADO);
	}

	if(g_Stats[iId][STAT_AP_D] < 100000) {
		if(g_Stats[iId][STAT_AP_D] < 60000) {
			if(g_Stats[iId][STAT_AP_D] < 30000) {
				if(g_Stats[iId][STAT_AP_D] < 5000) {
					if(g_Stats[iId][STAT_AP_D] < 2000) {
						if(g_Stats[iId][STAT_AP_D] >= 500) {
							setAchievement(iId, SACANDO_PROTECCION);
						}
					} else {
						setAchievement(iId, ESO_NO_TE_SIRVE_DE_NADA);
					}
				} else {
					setAchievement(iId, NO_ES_UN_PROBLEMA_PARA_MI);
				}
			} else {
				setAchievement(iId, SIN_DEFENSAS);
			}
		} else {
			setAchievement(iId, DESGARRANDO_CHALECO);
		}
	} else {
		setAchievement(iId, TOTALMENTE_INDEFENSO);
	}

	switch(g_PlayedTime[iId][TIME_DAY]) {
		case 1: {
			setAchievement(iId, ENTRENANDO);
		} case 7: {
			setAchievement(iId, ESTOY_MUY_SOLO);
		} case 15: {
			setAchievement(iId, FOREVER_ALONE);
			giveHat(iId, HAT_VIKING);
		} case 30: {
			setAchievement(iId, CREO_QUE_TENGO_UN_PROBLEMA);
		} case 50: {
			setAchievement(iId, SOLO_EL_ZP_ME_ENTIENDE);
		}
	}
}

public addDot(const number, output[], const output_len) {
	static sTemp[16];
	static iOutputPos;
	static iNumPos;
	static iNumLen;
	
	iOutputPos = 0;
	iNumPos = 0;
	iNumLen = num_to_str(number, sTemp, charsmax(sTemp));
	
	while((iNumPos < iNumLen) && (iOutputPos < output_len)) {
		output[iOutputPos++] = sTemp[iNumPos++];
		
		if((iNumLen - iNumPos) && !((iNumLen - iNumPos) % 3)) {
			output[iOutputPos++] = '.';
		}
	}
	
	output[iOutputPos] = EOS;
	return iOutputPos;
}

public addDotSpecial(const number[], output[], const output_len) {
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

public resetVars(const id, const reset_all) {
	set_pdata_int(id, OFFSET_LONG_JUMP, 0, OFFSET_LINUX);

	g_Invisibility[id] = 0;
	g_InfectionBomb[id] = 0;
	g_ModeCabezon_Power[id] = 0;
	g_DrugBombMove[id] = 0;
	g_UltimasPalabras[id] = 0;
	g_ComboReward[id] = 0;
	g_ComboZombieReward[id] = 0;
	g_ComboZombieEnabled[id] = 0;
	g_ComboZombie[id] = 0;
	g_Immunity[id] = 0;
	g_ImmunityBombs[id] = 0;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_Frozen[id] = 0;
	if(g_Mode != MODE_MEGA_ARMAGEDDON) {
		g_Zombie[id] = 0;
	}
	g_RespawnAsZombie[id] = 0;
	g_SpecialMode[id] = MODE_NONE;
	g_SurvImmunity[id] = 0;
	g_WeskLaser[id] = 0;
	g_WeskLaser_LastUse[id] = 0.0;
	g_Leatherface_Teleport[id] = 0;
	g_Bazooka[id] = 0;
	g_Bazooka_LastUse[id] = 0;
	g_BazookaMode[id] = 0;
	g_ModeFleshpound_Power[id] = 0;
	g_ModeAnnihilator_Kills[id] = 0;
	g_ModeGrunt_Flash[id] = 0;
	g_ModeGrunt_Reward[id] = 0;
	g_LastHuman[id] = 0;
	g_LastHumanOk[id] = 0;
	g_LastZombie[id] = 0;
	g_CanBuy[id] = 1;
	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;
	g_DrugBomb[id] = 0;
	g_DrugBombMode[id] = 0;
	g_SupernovaBomb[id] = 0;
	g_SupernovaBombMode[id] = 0;
	g_BubbleBomb[id] = 0;
	g_BubbleBombMode[id] = 0;
	g_InBubble[id] = 0;
	g_KillBomb[id] = 0;
	g_PipeBomb[id] = 0;
	g_AntidoteBomb[id] = 0;
	g_NVision[id] = 0;
	g_UnlimitedClip[id] = 0;
	g_PrecisionPerfect[id] = 0;
	g_Madness_LastUse[id] = 0;
	g_ReduceDamage[id] = 0;
	g_Petrification[id] = 0;
	g_HabRotate_Regeneration[id] = 0;
	g_Achievement_InfectsRound[id] = 0;
	for(new i = 0; i <= MaxClients; ++i) {
		g_Achievement_InfectsRoundId[id][i] = 0;
	}
	g_Achievement_InfectsWithMaxHP[id] = 0;
	g_LongJump[id] = 0;
	g_InJump[id] = 0;
	g_ConvertZombie[id] = 0;
	g_PlagueHumanKill[id] = 0;
	g_PlagueZombieKill[id] = 0;
	g_SynapsisNemesisKill[id] = 0;
	g_SynapsisDamage[id] = 0;
	g_SynapsisHead[id] = 0;
	g_ModeGG_Immunity[id] = 0;
	g_ModeDuelFinal_Kills[id] = 0;
	g_Combo[id] = 0;
	g_ComboDamage[id] = 0.0;
	g_ComboDamageBullet[id] = 0.0;
	g_ModeMegaDrunk_ZombieHits[id] = 0;
	g_Camera[id] = 0;
	g_ModeTribal_Damage[id] = 0;
	
	if(reset_all) {
		g_MiniGames_Number[id] = 2000;
		g_ModeL4D2_ZombieAcerts[id] = 0;
		g_ModeL4D2_Human[id] = 0;
		g_Achievement_SniperNoDamage[id] = 0;
		g_Achievement_CabezonKills[id] = 0;
		g_ModeCabezon_Head[id] = 0;
		g_ModeCabezon_PowerLastUse[id] = get_gametime();
		g_SniperPower[id] = 0;
		g_Benefit[id] = 0;
		g_ZombieBack[id] = 0;
		g_DrugBombCount[id] = 0;
		g_BlockSound[id] = 0;
		g_AccountLoading[id] = 0;
		g_AccountLoading_Steps[id] = 0;
		g_AccountStatus[id] = STATUS_CHECK_ACCOUNT;
		g_AccountId[id] = 0;
		g_AccountLastIp[id][0] = EOS;
		g_AccountPassword[id][0] = EOS;
		g_AccountCode[id][0] = EOS;
		g_AccountAutologin[id] = 0;
		g_AccountVinc[id] = 0;
		g_AccountVincMail[id][0] = EOS;
		g_AccountVincPassword[id][0] = EOS;
		g_AccountVincAppMobile[id] = 0;
		g_AccountBannedCount[id] = 0;
		g_AccountBanned_StaffName[id][0] = EOS;
		g_AccountBanned_Start[id] = 0;
		g_AccountBanned_Finish[id] = 0;
		g_AccountBanned_Reason[id][0] = EOS;
		g_AccountAttempts[id] = 0;
		g_ModeAnnihilator_Acerts[id] = 0;
		g_ModeAnnihilator_AcertsHS[id] = 0;
		g_ModeAnnihilator_Knife[id] = 0;
		g_Health[id] = 0;
		g_MaxHealth[id] = 0;
		g_Speed[id] = 1.0;
		g_FirstSpawn[id] = 0;
		g_TypeWeapon[id] = 0;
		g_CurrentWeapon[id] = 0;
		g_LastWeapon[id] = 0;
		g_WeaponAutoBuy[id] = 0;
		g_WeaponPrimary_Selection[id] = 0;
		g_WeaponSecondary_Selection[id] = 0;
		g_WeaponCuaternary_Selection[id] = 0;
		for(new i = 0; i < 31; ++i) {
			g_WeaponData[id][i][WEAPON_DATA_KILL_DONE] = 0;
			g_WeaponData[id][i][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
			g_WeaponData[id][i][WEAPON_DATA_LEVEL] = 0;
			g_WeaponData[id][i][WEAPON_DATA_POINTS] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TIME_PLAYED_DONE] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TPD_DAYS] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TPD_HOURS] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TPD_MINUTES] = 0;

			for(new j = 0; j < structIdWeaponSkills; ++j) {
				g_WeaponSkills[id][i][j] = 0;
			}

			g_WeaponModel[id][i] = 0;
			g_WeaponSave[id][i] = 0;
		}
		g_WeaponTime[id] = 0;
		g_WeaponSecondaryAutofire[id] = 0;
		for(new i = 0; i < structIdExtraItems; ++i) {
			g_ExtraItem_Count[id][i] = 0;
			g_ExtraItem_AlreadyBuy[id][i] = 0;
			g_ExtraItem_Mult[id][i] = 0;
		}
		for(new i = 0; i < structIdDifficultsClasses; ++i) {
			g_Difficult[id][i] = 0;
		}
		for(new i = 0; i < structIdPoints; ++i) {
			g_Points[id][i] = 0;
			g_PointsLost[id][i] = 0;
		}
		g_PointsMult[id] = 1;
		g_PointsInDiamond[id] = 0;
		g_PointsInDiamondShow[id] = 0;
		for(new i = 0; i < structIdHabs; ++i) {
			g_Hab[id][i] = 0;
		}
		for(new i = 0; i < structIdHabsRotate; ++i) {
			g_HabRotate[id][i] = 0;
		}
		for(new i = 0; i < structIdAchievementClasses; ++i) {
			g_AchievementPage[id][i] = 0;
		}
		for(new i = 0; i < structIdAchievements; ++i) {
			g_Achievement[id][i] = 0;
			g_AchievementName[id][i][0] = EOS;
			g_AchievementUnlocked[id][i] = 0;
			g_AchievementInt[id][i] = 0;
		}
		g_AchievementTotal[id] = 0;
		g_AchievementTimeLink[id] = 0.0;
		g_Achievement_FuryConsecutive[id] = 0;
		g_Achievement_InfectsWithFury[id] = 0;
		g_Achievement_AnnKnife[id] = 0;
		g_Achievement_AnniMac10[id] = 0;
		g_Achievement_AnnBazooka[id] = 0;
		g_Achievement_WeskerHead[id] = 0;
		g_Achievement_SniperHead[id] = 0;
		g_HatId[id] = HAT_NONE;
		g_HatNext[id] = HAT_NONE;
		for(new i = 0; i < structIdHats; ++i) {
			g_Hat[id][i] = 0;
			g_HatUnlocked[id][i] = 0;
		}
		g_HatTotal[id] = 0;
		g_Hat_Devil[id] = 0;
		g_Hat_Earth[id] = 0;
		for(new i = 0; i < structIdArtifacts; ++i) {
			g_Artifact[id][i] = 0;
			g_ArtifactsEquiped[id][i] = 0;
		}
		g_Mastery[id] = MASTERY_NONE;
		for(new i = 0; i < structIdHeadZombies; ++i) {
			g_HeadZombie[id][i] = 0;
		}
		g_HeadZombie_BadLuckBrian[id] = 0;
		g_HeadZombie_LastTouch[id] = 0.0;
		g_UserOptions_Color[id][COLOR_TYPE_HUD_GENERAL] = {0, 255, 0};
		g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO] = {255, 255, 255};
		g_UserOptions_Color[id][COLOR_TYPE_NVISION] = {0, 255, 0};
		g_UserOptions_Color[id][COLOR_TYPE_FLARE] = {255, 255, 255};
		g_UserOptions_Color[id][COLOR_TYPE_GROUP_GLOW] = {255, 0, 255};
		g_UserOptions_Hud[id][HUD_TYPE_GENERAL] = Float:{0.02, 0.1, 0.0};
		g_UserOptions_Hud[id][HUD_TYPE_COMBO] = Float:{-1.0, 0.6, 1.0};
		g_UserOptions_HudEffect[id][HUD_TYPE_GENERAL] = 0;
		g_UserOptions_HudEffect[id][HUD_TYPE_COMBO] = 0;
		g_UserOptions_HudStyle[id][HUD_TYPE_GENERAL] = 1;
		g_UserOptions_HudStyle[id][HUD_TYPE_COMBO] = 0;
		g_UserOptions_NVision[id] = 1;
		g_UserOptions_ChatMode[id] = 1;
		g_UserOptions_Invis[id] = 0;
		g_UserOptions_GroupGlow[id] = 0;
		g_UserOptions_CurrentMode[id] = 0;
		for(new i = 0; i < structIdStats; ++i) {
			g_Stats[id][i] = 0;
		}
		g_StatsDamage[id][0] = 0.0;
		g_StatsDamage[id][1] = 0.0;
		g_AmmoPacks[id] = 0;
		g_AmmoPacksMult[id] = 1.0;
		g_AmmoPacksMult_Legendary[id] = 0.0;
		g_AmmoPacksMult_Achievements[id] = 0.0;
		g_AmmoPacksDamage[id] = 0.0;
		g_AmmoPacksDamageNeed[id] = 5000.0;
		g_AmmoPacksTotal[id] = 0;
		g_AmmoPacks_BestRound[id] = 0;
		g_AmmoPacks_BestRoundHistory[id] = 0;
		g_AmmoPacks_BestMap[id] = 0;
		g_AmmoPacks_BestMapHistory[id] = 0;
		g_XP[id] = 0;
		addDot(g_XP[id], g_XPHud[id], charsmax(g_XPHud[]));
		g_XPRest[id] = 0;
		addDot(g_XPRest[id], g_XPRestHud[id], charsmax(g_XPRestHud[]));
		g_XPMult[id] = 1.0;
		g_XPMult_Legendary[id] = 0.0;
		g_XPMult_Achievements[id] = 0.0;
		g_XPDamageNeed[id] = 1.0;
		g_Level[id] = 1;
		g_LevelPercent[id] = 0.00;
		g_Reset[id] = 0;
		g_ResetPercent[id] = 0.00;
		g_ComboDamageNeed[id] = 1.0;
		g_ComboDamageNeedFake[id] = 0;
		g_ComboTime[id] = halflife_time() + 9999999.9;
		for(new i = 0; i < structIdMenuPages; ++i) {
			g_MenuPage[id][i] = 0;
		}
		for(new i = 0; i < structIdMenuDatas; ++i) {
			g_MenuData[id][i] = 0;
		}
		g_BuyStuff[id] = 0;
		g_DailyVisits[id] = 0;
		g_Consecutive_DailyVisits[id] = 0;
		g_ConnectedToday[id] = 0;
		g_ModeMA_Reward[id] = 0;
		for(new i = 1; i <= MaxClients; ++i) {
			g_ModeMA_Kills[id][i] = 0;
		}
		g_ModeMA_ZombieKills[id] = 0;
		g_ModeMA_HumanKills[id] = 0;
		g_ModeMA_NemesisKills[id] = 0;
		g_ModeMA_SurvivorKills[id] = 0;
		g_ModeGG_Level[id] = 1;
		g_ModeGG_Kills[id] = 0;
		g_ModeGG_Headshots[id] = 0;
		g_ModeGGCrazy_Level[id] = random_num(1, 25);
		g_ModeGGCrazy_ListLevel[id][0] = 1;
		for(new i = 1; i < 26; ++i) {
			g_ModeGGCrazy_ListLevel[id][i] = 0;
		}
		g_ModeGGCrazy_HeLevel[id] = 0;
		g_ModeMGG_Health[id] = 0;
		g_ModeDuelFinal_KillsTotal[id] = 0;
		g_ModeDuelFinal_KillsKnife[id] = 0;
		g_ModeDuelFinal_KillsAwp[id] = 0;
		g_ModeDuelFinal_KillsHE[id] = 0;
		g_ModeDuelFinal_KillsOnlyHead[id] = 0;
		g_Aura[id] = {0, 0, 0, 0};
		g_CriticalChance[id] = 0;
		g_DeadTimes[id] = 0;
		g_DeadTimes_Reward[id] = 0;
		g_AmuletCustomCreated[id] = 0;
		g_AmuletCustomCost[id] = 0;
		g_AmuletCustomName[id][0] = EOS;
		g_AmuletCustomNameFake[id][0] = EOS;
		g_AmuletCustom[id][acHealth] = 0;
		g_AmuletCustom[id][acSpeed] = 0;
		g_AmuletCustom[id][acGravity] = 0;
		g_AmuletCustom[id][acDamage] = 0;
		g_AmuletCustom[id][acMultAmmoPacks] = _:0.0;
		g_AmuletCustom[id][acMultXP] = _:0.0;
		g_AmuletCustom[id][acMultCombo] = 0;
		g_SaveConfig_SysTime[id] = get_gametime();
		g_Rank_SysTime[id] = get_gametime();
		g_Gift[id] = 0;
		g_InGroup[id] = 0;
		g_GroupInvitations[id] = 0;
		g_MyGroup[id] = 0;
		for(new i = 0; i <= MaxClients; ++i) {
			g_GroupInvitationsId[id][i] = 0;
		}
		for(new i = 0; i < structIdPlayedTime; ++i) {
			g_PlayedTime[id][i] = 0;
		}
	}

	updateMultipliersVars(id);
}

startModePre(const mode, id=0) {
	new iUsersAlive = getUsersAlive();

	if(mode == MODE_NONE) {
		if(iUsersAlive < 4 && !id) {
			clientPrint(0, print_center, "Se necesitan 4 o más jugadores para que comiencen los modos");
			
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

	if(g_EventModes) {
		--g_EventMode_MegaArmageddon;
		--g_EventMode_GunGame;

		if(g_EventMode_GunGame == 0) {
			g_NextMode = MODE_GUNGAME;
		} else if(g_EventMode_MegaArmageddon == 0) {
			g_NextMode = MODE_MEGA_ARMAGEDDON;
		}
	}
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

	g_FirstRound = 0;
	g_Mode = mode;
	g_LastMode = mode;

	changeLights();

	new iUsersAlive = getUsersAlive();
	new iMaxUsers = 0;
	new iUsers = 0;
	new i;

	switch(mode) {
		case MODE_INFECTION: {
			new iHalf = random_num(0, 1);

			if(iUsersAlive < 26) {
				iHalf = 0;
			}

			if(iHalf) {
				iMaxUsers = (iUsersAlive / 2);
			} else {
				if(iUsersAlive >= 7) {
					iMaxUsers = floatround((iUsersAlive * 0.16), floatround_ceil);
				} else {
					iMaxUsers = 1;
				}
			}

			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(!g_IsAlive[id] || g_Zombie[id] || (!iHalf && g_ZombieBack[id])) {
					continue;
				}

				zombieMe(id);

				if(!iHalf) {
					g_ZombieBack[id] = 1;
				}

				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(g_Zombie[i]) {
					randomSpawn(i);
					continue;
				}

				if(g_WeaponAutoBuy[i]) {
					buyCuaternaryWeapon(i, g_WeaponCuaternary_Selection[i]);
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			g_ModeInfection_Systime = (get_arg_systime() + 90);

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡INFECCIÓN!");
			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);

			if(iUsersAlive > 13) {
				remove_task(TASK_MODE_INFECTION);
				set_task(150.0, "task__ModeInfection", TASK_MODE_INFECTION);
			}

			if(g_ExtraItem_InfectionBombUsed) {
				++g_ExtraItem_InfectionBombRounds;

				if(g_ExtraItem_InfectionBombRounds == 3) {
					g_ExtraItem_InfectionBombUsed = 0;
					g_ExtraItem_InfectionBombRounds = 0;
				}
			}
		} case MODE_PLAGUE: {
			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(getUserTeam(i) != TEAM_TERRORIST) {
					if(g_WeaponAutoBuy[i]) {
						buyCuaternaryWeapon(i, g_WeaponCuaternary_Selection[i]);
					}

					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			iMaxUsers = 2;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id]) {
					continue;
				}

				if(!iUsers) {
					humanMe(id, .survivor=1);
				} else {
					zombieMe(id, .nemesis=1);
				}

				++iUsers;
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡PLAGUE!");
			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);
		} case MODE_SYNAPSIS: {
			iMaxUsers = 3;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				if(isPlayerValid(g_ModeSynapsis_Id[iUsers])) {
					id = g_ModeSynapsis_Id[iUsers];
				} else {
					id = getRandomAlive(random_num(1, iUsersAlive));
				}

				if(g_SpecialMode[id] == MODE_NEMESIS) {
					continue;
				}

				zombieMe(id, .nemesis=1);
				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(g_Zombie[i] || g_SpecialMode[i]) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}

				g_UnlimitedClip[i] = 1;
				g_PrecisionPerfect[i] = 1;
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡SYNAPSIS!");
			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);

			new k;
			for(k = 0; k < 3; ++k) {
				if(g_ModeSynapsis_Id[k]) {
					g_ModeSynapsis_Id[k] = 0;
				}
			}
		} case MODE_MEGA_SYNAPSIS: {

		} case MODE_ARMAGEDDON: {
			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				g_Speed[i] = 250.0;
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);
			}

			g_ModeArmageddon_Init = 1;
			g_ModeArmageddon_Notice = 0;

			message_begin(MSG_BROADCAST, g_Message_ScreenFade, _, id);
			write_short(UNIT_SECOND * 4);
			write_short(floatround((UNIT_SECOND * 15.0) + 2.2));
			write_short(FFADE_OUT);
			write_byte(0);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			message_end();

			playSound(0, __SOUND_ROUND_ARMAGEDDON);

			remove_task(TASK_MODE_ARMAGEDDON);
			set_task(0.5, "task__StartModeArmageddon", TASK_MODE_ARMAGEDDON);
		} case MODE_MEGA_ARMAGEDDON: {
			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}
			
			set_cvar_num("mp_round_infinite", 1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				g_ModeMA_Reward[i] = 1;

				message_begin(MSG_BROADCAST, g_Message_ScreenFade, _, 0);
				write_short(UNIT_SECOND * 4);
				write_short(UNIT_SECOND * 3);
				write_short(FFADE_STAYOUT);
				write_byte(0);
				write_byte(0);
				write_byte(0);
				write_byte(255);
				message_end();

				if(!getUserIsSteamId(i)) {
					set_task(3.4, "task__MegaArmageddonEffect", i); // TUM
					set_task(4.1, "task__MegaArmageddonEffect", i); // TUMM
					set_task(4.8, "task__MegaArmageddonEffect", i); // TUMMM

					set_task(7.0, "task__MegaArmageddonBlackFade", i);

					set_task(10.5, "task__MegaArmageddonEffect", i); // TUM
					set_task(11.2, "task__MegaArmageddonEffect", i); // TUMM
					set_task(11.9, "task__MegaArmageddonEffect", i); // TUMMM
				} else {
					set_task(4.4, "task__MegaArmageddonEffect", i); // TUM
					set_task(5.1, "task__MegaArmageddonEffect", i); // TUMM
					set_task(5.8, "task__MegaArmageddonEffect", i); // TUMMM

					set_task(8.0, "task__MegaArmageddonBlackFade", i);

					set_task(11.5, "task__MegaArmageddonEffect", i); // TUM
					set_task(12.2, "task__MegaArmageddonEffect", i); // TUMM
				}
			}

			playSound(0, __SOUND_ROUND_MEGA_ARMAGEDDON);

			remove_task(TASK_MODE_MEGA_ARMAGEDDON);
			set_task(12.8, "task__StartModeMegaArmageddon", TASK_MODE_MEGA_ARMAGEDDON);
		} case MODE_GUNGAME: {
			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}
			
			set_cvar_num("mp_round_infinite", 1);
			set_cvar_num("mp_freeforall", 1);

			g_ModeGG_End = 0;
			g_ModeGG_SysTime = get_arg_systime();

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				hidePlayerHat(i);

				entity_set_int(i, EV_INT_rendermode, kRenderNormal);
				entity_set_float(i, EV_FL_renderamt, 255.0);

				g_ModeGG_Level[i] = 1;
				g_ModeGG_Kills[i] = 0;
				g_ModeGG_Headshots[i] = 0;
				g_ModeGGCrazy_Level[i] = random_num(1, 25);
				g_ModeGGCrazy_ListLevel[i][0] = 1;
				for(new j = 1; j < 26; ++j) {
					g_ModeGGCrazy_ListLevel[i][j] = 0;
				}

				set_user_health(i, 100);
				g_Speed[i] = 255.0;
				set_user_gravity(i, 1.0);
				set_user_armor(i, 0);

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);

				randomSpawn(i);
			}

			showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, random_num(0, 1), 15.0, "¡GUNGAME: %s!", __GUNGAME_TYPE_NAME[g_ModeGG_Type]);
			playSound(0, __SOUND_ROUND_GUNGAME);
		} case MODE_MEGA_GUNGAME: {
			g_ModeMGG_Played = 1;

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_general SET round_mega_gg='1';");
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			set_cvar_num("mp_round_infinite", 1);
			set_cvar_num("mp_freeforall", 1);

			g_ModeGG_End = 0;
			g_ModeMGG_Phase = 0;
			g_ModeMGG_Block = 0;

			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				hidePlayerHat(i);

				entity_set_int(i, EV_INT_rendermode, kRenderNormal);
				entity_set_float(i, EV_FL_renderamt, 255.0);

				g_ModeGG_Level[i] = 1;
				g_ModeGG_Kills[i] = 0;
				g_ModeGG_Headshots[i] = 0;
				g_ModeMGG_Health[i] = 0;

				set_user_health(i, 100);
				g_Speed[i] = 255.0;
				set_user_gravity(i, 1.0);
				set_user_armor(i, 0);

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);

				randomSpawn(i);
			}

			showDHUDMessage(0, random(256), random(256), random(256), -1.0, -1.0, random_num(0, 1), 15.0, "¡MEGA GUNGAME!");
			playSound(0, __SOUND_ROUND_GUNGAME);
		} case MODE_DRUNK: {
			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}
			
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

			iMaxUsers = 3;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id]) {
					continue;
				}

				if(iUsers == 0) {
					humanMe(id, .survivor=1);
				} else if(iUsers == 1) {
					humanMe(id, .sniper=1);
				} else if(iUsers == 2) {
					humanMe(id, .sniper=2);
				}

				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(getUserTeam(i) != TEAM_TERRORIST) {
					if(!g_SpecialMode[i]) {
						if(g_WeaponAutoBuy[i]) {
							buyCuaternaryWeapon(i, g_WeaponCuaternary_Selection[i]);
						}
					}

					set_user_health(i, 5000);
					g_Health[i] = get_user_health(i);

					continue;
				}

				if(g_SpecialMode[i] == MODE_NEMESIS) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡DRUNK!");
			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);
		} case MODE_MEGA_DRUNK: {
			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}

			iMaxUsers = 10;
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
					humanMe(id, .survivor=1);
				} else if(iUsers == 3) {
					humanMe(id, .survivor=1);
				} else if(iUsers == 4) {
					humanMe(id, .sniper=1);
				} else if(iUsers == 5) {
					humanMe(id, .sniper=1);
				} else if(iUsers == 6) {
					humanMe(id, .sniper=2);
				} else if(iUsers == 7) {
					humanMe(id, .sniper=2);
				} else if(iUsers == 8) {
					humanMe(id, .tribal=1);
				} else if(iUsers == 9) {
					humanMe(id, .tribal=1);
				}

				++iUsers;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || g_SpecialMode[i]) {
					continue;
				}

				zombieMe(i, .nemesis=1);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡MEGA DRUNK!");
			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);
		} case MODE_L4D2: {
			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				
				if(g_SpecialMode[id] == MODE_L4D2) {
					continue;
				}

				++iUsers;
				humanMe(id, .l4d2=iUsers);
			}

			new j = 0;

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(g_SpecialMode[i] == MODE_L4D2 || g_Zombie[i]) {
					continue;
				}

				zombieMe(i, .silent_mode=1);

				++j;
			}

			showDHUDMessage(0, 199, 21, 133, -1.0, 0.25, 0, 15.0, "¡L4D2!");
			playSound(0, __SOUND_ROUND_L4D2);

			g_ModeL4D2_ZombiesTotal = (j * 3);
			g_ModeL4D2_Zombies = g_ModeL4D2_ZombiesTotal;
		} case MODE_DUEL_FINAL: {
			if(!getAlivesT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getAlivesCT()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}

			set_cvar_num("mp_round_infinite", 1);
			set_cvar_num("mp_freeforall", 1);

			g_ModeDuelFinal = DF_ALL;
			g_ModeDuelFinal_First = 0;

			if(!g_ModeDuelFinal_Type) {
				static iRandom;
				iRandom = random_num(DF_TYPE_KNIFE, DF_TYPE_ONLY_HEAD);

				switch(iRandom) {
					case DF_TYPE_KNIFE: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), "");
					} case DF_TYPE_AWP: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de AWP");
					} case DF_TYPE_HE: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de HE");
					} case DF_TYPE_ONLY_HEAD: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de SOLO HEADSHOT");
					}
				}

				g_ModeDuelFinal_Type = iRandom;
			} else {
				switch(g_ModeDuelFinal_Type) {
					case DF_TYPE_KNIFE: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), "");
					} case DF_TYPE_AWP: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de AWP");
					} case DF_TYPE_HE: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de HE");
					} case DF_TYPE_ONLY_HEAD: {
						formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de SOLO HEADSHOT");
					}
				}
			}

			if(g_ModeDuelFinal_Type == 4) {
				g_ModeDuelFinal_TypeOnlyHead = random_num(1, 3);
			}

			for(i = 1; i <= MaxClients; ++i) {
				g_ModeDuelFinal_KillsTotal[i] = 0;

				if(!g_IsAlive[i]) {
					continue;
				}

				set_user_health(i, 100);
				g_Speed[i] = 255.0;
				set_user_gravity(i, 1.0);
				set_user_armor(i, 0);

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);

				randomSpawn(i);

				hidePlayerHat(i);

				entity_set_int(i, EV_INT_rendermode, kRenderNormal);
				entity_set_float(i, EV_FL_renderamt, 255.0);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡DUELO FINAL%s!", g_ModeDuelFinal_TypeName);
			playSound(0, __SOUND_ROUND_SPECIAL);
		} case MODE_SURVIVOR: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			humanMe(id, .survivor=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(id == i || g_Zombie[i]) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 0, 0, 255, -1.0, 0.25, 0, 15.0, "¡%s ES SURVIVOR!", g_PlayerName[id]);
			playSound(0, __SOUND_ROUND_SURVIVOR[random_num(0, charsmax(__SOUND_ROUND_SURVIVOR))]);
		} case MODE_WESKER: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			humanMe(id, .wesker=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(id == i || g_Zombie[i]) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 0, 255, 255, -1.0, 0.25, 0, 15.0, "¡%s ES WESKER!", g_PlayerName[id]);
			playSound(0, __SOUND_ROUND_SURVIVOR[random_num(0, charsmax(__SOUND_ROUND_SURVIVOR))]);
		} case MODE_LEATHERFACE: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			humanMe(id, .leatherface=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(id == i || g_Zombie[i]) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 255, 0, 255, -1.0, 0.25, 0, 15.0, "¡%s ES LEATHERFACE!", g_PlayerName[id]);
			playSound(0, __SOUND_ROUND_SURVIVOR[random_num(0, charsmax(__SOUND_ROUND_SURVIVOR))]);
		} case MODE_TRIBAL: {
			g_ModeTribal_Power = 1;

			iMaxUsers = 2;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				if(isPlayerValid(g_ModeTribal_Id[iUsers])) {
					id = g_ModeTribal_Id[iUsers];
				} else {
					id = getRandomAlive(random_num(1, iUsersAlive));
				}

				if(g_SpecialMode[id] == MODE_TRIBAL) {
					continue;
				}

				++iUsers;
				humanMe(id, .tribal=iUsers);
			}
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(g_SpecialMode[i] == MODE_TRIBAL) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 255, 165, 0, -1.0, 0.25, 0, 15.0, "¡TRIBAL!");
			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);

			new k;
			for(k = 0; k < 2; ++k) {
				if(g_ModeTribal_Id[k]) {
					g_ModeTribal_Id[k] = 0;
				}
			}
		} case MODE_SNIPER: {
			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				if(isPlayerValid(g_ModeSniper_Id[iUsers])) {
					id = g_ModeSniper_Id[iUsers];
				} else {
					id = getRandomAlive(random_num(1, iUsersAlive));
				}

				if(g_SpecialMode[id] == MODE_SNIPER) {
					continue;
				}

				++iUsers;
				humanMe(id, .sniper=iUsers);
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);
				
				if(g_SpecialMode[i] == MODE_SNIPER || g_Zombie[i]) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡SNIPER!");
			playSound(0, __SOUND_ROUND_SURVIVOR[random_num(0, charsmax(__SOUND_ROUND_SURVIVOR))]);

			new k;
			for(k = 0; k < 2; ++k) {
				if(g_ModeSniper_Id[k]) {
					g_ModeSniper_Id[k] = 0;
				}
			}
		} case MODE_NEMESIS: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			zombieMe(id, .nemesis=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(id == i) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			showDHUDMessage(0, 255, 0, 0, -1.0, 0.25, 0, 15.0, "¡%s ES NEMESIS!", g_PlayerName[id]);
			playSound(0, __SOUND_ROUND_NEMESIS[random_num(0, charsmax(__SOUND_ROUND_NEMESIS))]);
		} case MODE_CABEZON: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			zombieMe(id, .cabezon=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(id == i) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			showDHUDMessage(0, 255, 255, 255, -1.0, 0.25, 0, 15.0, "¡%s ES CABEZÓN!", g_PlayerName[id]);
			playSound(0, __SOUND_ROUND_NEMESIS[random_num(0, charsmax(__SOUND_ROUND_NEMESIS))]);

			remove_task(TASK_MODE_CABEZON);
			set_task(120.0, "task__ModeCabezon", TASK_MODE_CABEZON);
		} case MODE_ANNIHILATOR: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			zombieMe(id, .annihilator=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(id == i) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);
			}

			showDHUDMessage(0, 255, 255, 0, -1.0, 0.25, 0, 15.0, "¡%s ES ANIQUILADOR!", g_PlayerName[id]);
			playSound(0, __SOUND_ROUND_NEMESIS[random_num(0, charsmax(__SOUND_ROUND_NEMESIS))]);
		} case MODE_FLESHPOUND: {
			iMaxUsers = 2;
			iUsers = 0;

			while(iUsers < iMaxUsers) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				
				if(g_SpecialMode[id] == MODE_TRIBAL) {
					continue;
				}

				++iUsers;
				humanMe(id, .tribal=iUsers);
			}

			new iIdFlesh = getRandomAlive(random_num(1, iUsersAlive));
			zombieMe(iIdFlesh, .fleshpound=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(g_Zombie[i] || g_SpecialMode[i]) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			showDHUDMessage(0, 127, 255, 0, -1.0, 0.25, 0, 15.0, "¡%s ES FLESHPOUND!", g_PlayerName[iIdFlesh]);
			playSound(0, __SOUND_ZOMBIE_INFECT[3]);

			g_ModeFleshpound_Minute = 0;

			remove_task(TASK_MODE_FLESHPOUND);
			set_task(60.0, "task__ModeFleshpound", TASK_MODE_FLESHPOUND);
		} case MODE_GRUNT: {
			g_ModeGrunt_RewardGlobal = 1111;
			g_ModeGrunt_NoDamage = 1;
			
			set_cvar_num("sv_alltalk", 0);
			set_cvar_num("mp_autokick", 0);
			set_cvar_num("mp_autokick_timeout", -1);

			new iDouble = random_num(0, 1);

			if(iUsersAlive < 20) {
				iDouble = 0;
			}

			new iIds[2] = {0, 0};

			if(id) {
				iDouble = 0;
			} else {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			if(iDouble) {
				iMaxUsers = 2;
				iUsers = 0;

				while(iUsers < iMaxUsers) {
					id = getRandomAlive(random_num(1, iUsersAlive));

					if(g_SpecialMode[id] == MODE_GRUNT) {
						continue;
					}

					iIds[iUsers] = id;
					zombieMe(id, .grunt=1);

					++iUsers;
				}
			} else {
				zombieMe(id, .grunt=1);
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				strip_user_weapons(i);

				remove_task(i + TASK_GRUNT_AIMING);
				set_task(0.1, "task__ModeGruntAiming", i + TASK_GRUNT_AIMING);

				if(g_SpecialMode[i] == MODE_GRUNT) {
					g_ModeGrunt_Reward[i] = clamp((7500000 * (g_Reset[i] + 1)), 7500000, MAX_XP);

					clientPrintColor(i, _, "Dentro de !g30 segundos!y tendrás visión para buscar a los humanos");
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}

				clientPrintColor(i, _, "Luego de los !g30 segundos!y no podrás moverte y recibirás la ganancia");
				randomSpawn(i);

				hidePlayerHat(i);

				turnOffFlashlight(i);
			}

			if(iDouble) {
				showDHUDMessage(0, 198, 226, 255, -1.0, 0.25, 0, 15.0, "¡GRUNT!^nLos grunts son^n^n%s^n%s^n^nNo hagas contacto visual con los Grunts y escóndete", g_PlayerName[iIds[0]], g_PlayerName[iIds[1]]);
			} else {
				showDHUDMessage(0, 198, 226, 255, -1.0, 0.25, 0, 15.0, "¡%s ES GRUNT!^nNo hagas contacto visual con el Grunt y escóndete", g_PlayerName[id]);
			}

			playSound(0, __SOUND_ROUND_GRUNT);
		}
	}

	alertMode(mode);
}

public alertMode(const mode) {
	++g_ModeCount[mode];

	new sModeCount[8];
	addDot(g_ModeCount[mode], sModeCount, charsmax(sModeCount));

	if(((g_ModeCount[mode] % 2500) == 0) || (((g_ModeCount[mode] % 500) == 0) && mode != MODE_INFECTION) || g_ModeCount[mode] == 100) {
		new i;
		new iPointsReward;

		if ((g_ModeCount[mode] % 2500) == 0) {
			iPointsReward = 25;
		} else if(((g_ModeCount[mode] % 500) == 0) && mode != MODE_INFECTION) {
			iPointsReward = 20;
		} else {
			iPointsReward = 10;
		}

		for(i = 1; i <= MaxClients; ++i) {
			if(g_IsConnected[i] && g_AccountStatus[i] == STATUS_PLAYING) {
				g_Points[i][P_HUMAN] += iPointsReward;
				g_Points[i][P_ZOMBIE] += iPointsReward;
			}
		}

		clientPrintColor(0, _, "Todos los jugadores conectados ganaron !g%d pHZ!y", iPointsReward);
		clientPrintColor(0, _, "Felicidades, el modo !g%s!y se jugó !g%s ve%s!y", __MODES[mode][modeName], sModeCount, ((g_ModeCount[mode] != 1) ? "ces" : "z"));
	} else {
		clientPrintColor(0, _, "El modo !g%s!y se jugó !g%s ve%s!y", __MODES[mode][modeName], sModeCount, ((g_ModeCount[mode] != 1) ? "ces" : "z"));
	}

	new sModeCountSave[256];
	arrayToString(g_ModeCount, structIdModes, sModeCountSave, charsmax(sModeCountSave), 1);

	if(g_EventMode_MegaArmageddon >= 0 || g_EventMode_GunGame >= 0) {
		if(g_EventMode_MegaArmageddon <= 0) {
			g_EventMode_MegaArmageddon = -1;
		}

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_general SET modes=^"%s^", round_ma='%d', round_gg='%d', round_gg_last_winner='%d' WHERE id='1';", sModeCountSave, g_EventMode_MegaArmageddon, g_EventMode_GunGame, g_ModeGG_LastWinner);
	} else {
		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_general SET modes=^"%s^" WHERE id='1';", sModeCountSave);
	}

	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
}

public chooseMode() {
	if(g_ModeMGG_Played == 2) {
		g_NextMode = MODE_MEGA_GUNGAME;
		return;
	}

	new iUsersAlive = getUsersAlive();

	if(g_CurrentMode == MODE_NONE && g_NextMode == MODE_NONE) {
		if(g_EventModes) {
			g_CurrentMode = ((iUsersAlive >= 12) ? MODE_ARMAGEDDON : MODE_PLAGUE);
		} else {
			g_CurrentMode = MODE_INFECTION;
		}
	}

	if(g_EventModes) {
		new const __MODES_EVENT[] = {
			MODE_PLAGUE, MODE_SYNAPSIS/*, MODE_MEGA_SYNAPSIS*/, MODE_ARMAGEDDON, MODE_DRUNK, MODE_MEGA_DRUNK, MODE_DUEL_FINAL, MODE_SURVIVOR, MODE_WESKER, MODE_TRIBAL, MODE_SNIPER, MODE_NEMESIS, MODE_CABEZON, MODE_ANNIHILATOR, MODE_GRUNT
		};

		g_NextMode = __MODES_EVENT[g_EventMode_Count];

		++g_EventMode_Count;

		if(g_EventMode_Count == sizeof(__MODES_EVENT)) {
			g_EventMode_Count = 0;
		}
	} else {
		new iModeSelected = MODE_INFECTION;
		new i;

		for(i = 0; i < structIdModes; ++i) {
			if(__MODES[i][modeChance] && random_num(1, __MODES[i][modeChance]) == 1 && iUsersAlive >= __MODES[i][modeUsersNeed] && g_LastMode != i) {
				iModeSelected = i;
				break;
			}
		}

		g_NextMode = iModeSelected;
	}
}

public getUsersPlaying() {
	new iCount = 0;
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			iTeam = getUserTeam(i);

			if((iTeam == TEAM_TERRORIST) || (iTeam == TEAM_CT)) {
				++iCount;
			}
		}
	}

	return iCount;
}

public getUsersAlive() {
	new iCount = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			++iCount;
		}
	}

	return iCount;
}

getRandomAlive(const n) {
	new iCount = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			++iCount;
		}

		if(iCount == n) {
			return i;
		}
	}

	return -1;
}

public getZombies() {
	new iCount = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i] && g_Zombie[i]) {
			++iCount;
		}
	}

	return iCount;
}

public getHumans() {
	new iCount = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i] && !g_Zombie[i]) {
			++iCount;
		}
	}

	return iCount;
}

public getTs() {
	new iCount = 0;
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			iTeam = getUserTeam(i);

			if((iTeam == TEAM_TERRORIST)) {
				++iCount;
			}
		}
	}

	return iCount;
}

public getCTs() {
	new iCount = 0;
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			iTeam = getUserTeam(i);

			if((iTeam == TEAM_CT)) {
				++iCount;
			}
		}
	}

	return iCount;
}

public respawnUserManually(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME) {
		if(g_ModeGG_End) {
			return;
		}

		if(random_num(0, 1)) {
			setUserTeam(id, TEAM_TERRORIST);
		} else {
			setUserTeam(id, TEAM_CT);
		}
	} else {
		if(g_RespawnAsZombie[id]) {
			setUserTeam(id, TEAM_TERRORIST);
		} else {
			setUserTeam(id, TEAM_CT);
		}
	}

	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public getUserChatMode(const id) {
	static sChatMode[32];
	static sLevel[16];
	static sReset[16];

	formatex(sChatMode, charsmax(sChatMode), " ^4%s", __CHAT_MODE[g_UserOptions_ChatMode[id]]);

	if(g_Reset[id]) {
		formatex(sReset, charsmax(sReset), "%d", g_Reset[id]);
		replace_all(sChatMode, charsmax(sChatMode), "Reset", sReset);
	} else {
		sReset[0] = EOS;
		replace_all(sChatMode, charsmax(sChatMode), "[Reset]", "");
	}

	formatex(sLevel, charsmax(sLevel), "%d", g_Level[id]);
	replace_all(sChatMode, charsmax(sChatMode), "Nivel", sLevel);

	return sChatMode;
}

zombieMe(const id, attacker=0, reward=0, silent_mode=0, bomb=0, nemesis=0, cabezon=0, annihilator=0, fleshpound=0, grunt=0) {
	if(!g_IsAlive[id]) {
		return;
	}

	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_DRUG);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_HEALTH_REGENERATION);
	remove_task(id + TASK_HEALTH_IMMUNITY);
	remove_task(id + TASK_HEALTH_REGENERATION_ROTATE);
	remove_task(id + TASK_CONVERT_ZOMBIE);

	if(isPlayerStuck(id)) {
		clientPrintColor(id, _, "Has sido teletransportado debido a que te habías trabado con un humano");
		randomSpawn(id);
	}

	if(attacker || reward) {
		finishComboHuman(id);
	}

	g_CanBuy[id] = 0;
	g_Zombie[id] = 1;
	g_SpecialMode[id] = MODE_NONE;
	g_Immunity[id] = 0;
	g_ImmunityBombs[id] = 0;
	g_KillBomb[id] = 0;
	g_PipeBomb[id] = 0;
	g_AntidoteBomb[id] = 0;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;
	g_ComboZombieEnabled[id] = 1;

	set_user_rendering(id);

	updatePlayerHat(id);

	new iHealth;
	new Float:flHealth;
	new Float:flSpeed;
	new Float:flGravity;

	if(attacker) {
		g_ImmunityBombs[attacker] = 0;

		randomSpawn(id);
		
		++g_Stats[attacker][STAT_INF_D];
		++g_Stats[id][STAT_INF_T];

		if(g_Stats[attacker][STAT_INF_D] >= 100) {
			setAchievement(attacker, HUMANOS_x100);

			if(g_Stats[attacker][STAT_INF_D] >= 500) {
				setAchievement(attacker, HUMANOS_x500);

				if(g_Stats[attacker][STAT_INF_D] >= 1000) {
					setAchievement(attacker, HUMANOS_x1000);

					if(g_Stats[attacker][STAT_INF_D] >= 2500) {
						setAchievement(attacker, HUMANOS_x2500);
						giveHat(attacker, HAT_AWESOME);

						if(g_Stats[attacker][STAT_INF_D] >= 5000) {
							setAchievement(attacker, HUMANOS_x5000);

							if(g_Stats[attacker][STAT_INF_D] >= 10000) {
								setAchievement(attacker, HUMANOS_x10K);

								if(g_Stats[attacker][STAT_INF_D] >= 25000) {
									setAchievement(attacker, HUMANOS_x25K);

									if(g_Stats[attacker][STAT_INF_D] >= 50000) {
										setAchievement(attacker, HUMANOS_x50K);

										if(g_Stats[attacker][STAT_INF_D] >= 100000) {
											setAchievement(attacker, HUMANOS_x100K);

											if(g_Stats[attacker][STAT_INF_D] >= 250000) {
												setAchievement(attacker, HUMANOS_x250K);

												if(g_Stats[attacker][STAT_INF_D] >= 500000) {
													setAchievement(attacker, HUMANOS_x500K);

													if(g_Stats[attacker][STAT_INF_D] >= 1000000) {
														setAchievement(attacker, HUMANOS_x1M);

														if(g_Stats[attacker][STAT_INF_D] >= 5000000) {
															setAchievement(attacker, HUMANOS_x5M);
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		if(!silent_mode) {
			if(g_Hab[attacker][HAB_Z_COMBO_ZOMBIE] && g_ComboZombieEnabled[attacker]) {
				++g_ComboZombie[attacker];
				showCurrentComboZombie(attacker);
			}

			if(g_Immunity[attacker]) {
				++g_Hat_Earth[attacker];

				switch(g_Hat_Earth[attacker]) {
					case 1: {
						clientPrint(attacker, print_center, "GORRO EARTH - 1 Infección");
					} case 2: {
						clientPrint(attacker, print_center, "GORRO EARTH - 2 Infecciones");
					} case 3: {
						clientPrint(attacker, print_center, "GORRO EARTH - 3 Infecciones");
					} case 4: {
						clientPrint(attacker, print_center, "GORRO EARTH - 4 Infecciones");
					} case 5: {
						giveHat(attacker, HAT_EARTH);
					}
				}

				++g_Achievement_InfectsWithFury[attacker];
				
				if(g_Achievement_FuryConsecutive[attacker] == 2) {
					if(g_Achievement_InfectsWithFury[attacker] >= 15) {
						setAchievement(attacker, YO_FUI);
					}
				}
			} else {
				if(g_Health[attacker] >= g_MaxHealth[attacker]) {
					++g_Achievement_InfectsWithMaxHP[attacker];

					if(g_Achievement_InfectsWithMaxHP[attacker] == 5) {
						setAchievement(attacker, YO_NO_FUI);
					}
				}
			}

			emitSound(id, CHAN_VOICE, __SOUND_ZOMBIE_INFECT[random_num(0, charsmax(__SOUND_ZOMBIE_INFECT))]);
		}

		switch(g_Mode) {
			case MODE_INFECTION: {
				if(!g_Achievement_InfectsRoundId[attacker][id]) {
					++g_Achievement_InfectsRound[attacker];
				}

				g_Achievement_InfectsRoundId[attacker][id] = 1;

				if(!bomb) {
					switch(g_Achievement_InfectsRound[attacker]) {
						case 5: {
							clientPrint(attacker, print_center, "LOGRO VIRUS - 5 Infecciones");
						} case 10: {
							clientPrint(attacker, print_center, "LOGRO VIRUS - 10 Infecciones");
						} case 15: {
							clientPrint(attacker, print_center, "LOGRO VIRUS - 15 Infecciones");
						} case 20: {
							setAchievement(attacker, VIRUS);
						}
					}
				}
			}
		}

		g_AmmoPacks[attacker] += 2;

		new iRewardXP = (random_num(250, 500) * getUserLevelTotal(id));

		if(g_HabRotate[attacker][HAB_ROTATE_SOPA_DE_CEREBROS]) {
			iRewardXP += ((iRewardXP * 30) / 100);
		}

		addXP(attacker, iRewardXP);

		if(g_HabRotate[attacker][HAB_ROTATE_VAMPIRISMO]) {
			iHealth = g_Health[attacker];
			iHealth += ((20 * g_MaxHealth[attacker]) / 100);

			if(iHealth > g_MaxHealth[attacker]) {
				iHealth = g_MaxHealth[attacker];
			}

			set_user_health(attacker, iHealth);
			g_Health[attacker] = get_user_health(attacker);
		}

		sendDeathMsg(attacker, id);
		fixDeadAttrib(id);
	}

	copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Zombie");

	cs_set_user_zoom(id, CS_RESET_ZOOM, 1);
	set_user_armor(id, 0);

	strip_user_weapons(id);

	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;

	give_item(id, "weapon_knife");

	if(!silent_mode) {
		if(nemesis) {
			g_SpecialMode[id] = MODE_NEMESIS;

			new iIsLongJump = 1;

			if(g_Mode == MODE_PLAGUE) {
				iHealth = 25000000;
				flSpeed = 350.0;
				flGravity = 0.35;
			} else if(g_Mode == MODE_SYNAPSIS) {
				iHealth = 100000000;
				flSpeed = 350.0;
				flGravity = 0.35;
			} else if(g_Mode == MODE_ARMAGEDDON) {
				iHealth = 62500000;
				flSpeed = 350.0;
				flGravity = 0.35;
			} else if(g_Mode == MODE_MEGA_ARMAGEDDON) {
				iHealth = 75000000;
				flSpeed = 350.0;
				flGravity = 0.4;
			} else if(g_Mode == MODE_DRUNK) {
				iHealth = 50000000;
				flSpeed = 350.0;
				flGravity = 0.35;
			} else if(g_Mode == MODE_MEGA_DRUNK) {
				iHealth = 100000000;
				flSpeed = 350.0;
				flGravity = 0.35;
			} else {
				setUserAura(id, 255, 0, 0, 15);

				if(g_Difficult[id][DIFFICULT_CLASS_NEMESIS] == DIFFICULT_VERY_HARD || g_Difficult[id][DIFFICULT_CLASS_NEMESIS] == DIFFICULT_EXPERT) {
					iIsLongJump = 0;

					if(g_Difficult[id][DIFFICULT_CLASS_NEMESIS] == DIFFICULT_VERY_HARD) {
						sendFog(id, 255, 0, 0, 1);
					} else {
						sendFog(id, 255, 0, 0, 2);
					}
				}

				if(getUsersPlaying() >= 8) {
					clientPrintColor(id, _, "Recuerda que tienes bazooka. Para equiparla, presiona la !gTecla 1!y");
					
					if(g_Hab[id][HAB_S_NEM_BAZOOKA_EXTRA]) {
						g_Bazooka[id] = 2;
					} else {
						g_Bazooka[id] = 1;
					}

					g_Bazooka_LastUse[id] = 0;

					give_item(id, "weapon_ak47");
					cs_set_user_bpammo(id, CSW_AK47, 0);
					set_pdata_int(findEntByOwner(id, "weapon_ak47"), OFFSET_CLIPAMMO, 0, OFFSET_LINUX_WEAPONS);
				} else {
					clientPrintColor(id, _, "No recibiste la bazooka a falta de jugadores");

					g_Bazooka[id] = 0;
					g_Bazooka_LastUse[id] = 0;
				}

				iHealth = ((250000 * getUsersAlive()) + (__HABS[HAB_S_NEM_HEALTH][habValue] * g_Hab[id][HAB_S_NEM_HEALTH]));

				if(g_HabRotate[id][HAB_ROTATE_NEMESIS_VIDEIGOUS]) {
					iHealth += ((iHealth * 30) / 100);
				}

				flHealth = float(iHealth);
				flHealth *= __DIFFICULTS[DIFFICULT_CLASS_NEMESIS][g_Difficult[id][DIFFICULT_CLASS_NEMESIS]][difficultHealth];
				iHealth = floatround(flHealth);

				flSpeed = 350.0;
				flSpeed *= __DIFFICULTS[DIFFICULT_CLASS_NEMESIS][g_Difficult[id][DIFFICULT_CLASS_NEMESIS]][difficultSpeed];

				flGravity = 0.35;
			}

			if(iIsLongJump) {
				set_pdata_int(id, OFFSET_LONG_JUMP, 1, OFFSET_LINUX);

				g_LongJump[id] = 1;
				g_InJump[id] = 0;
			}

			g_CurrentWeapon[id] = CSW_KNIFE;
			engclient_cmd(id, "weapon_knife");

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Nemesis");

			replaceWeaponModels(id, CSW_KNIFE);
		} else if(cabezon) {
			g_SpecialMode[id] = MODE_CABEZON;

			iHealth = (200000 * getUsersAlive());
			flSpeed = 350.0;
			flGravity = 0.5;

			new iPowerCabezon = 0;

			if(g_Mode == MODE_CABEZON) {
				iPowerCabezon = 3;

				if(g_Difficult[id][DIFFICULT_CLASS_CABEZON] == DIFFICULT_VERY_HARD || g_Difficult[id][DIFFICULT_CLASS_CABEZON] == DIFFICULT_EXPERT) {
					if(g_Difficult[id][DIFFICULT_CLASS_CABEZON] == DIFFICULT_VERY_HARD) {
						iPowerCabezon = 1;
					} else {
						iPowerCabezon = 0;
						sendFog(id, 255, 255, 255, 1);
					}
				}

				flHealth = float(iHealth);
				flHealth *= __DIFFICULTS[DIFFICULT_CLASS_CABEZON][g_Difficult[id][DIFFICULT_CLASS_CABEZON]][difficultHealth];
				iHealth = floatround(flHealth);

				flSpeed *= __DIFFICULTS[DIFFICULT_CLASS_CABEZON][g_Difficult[id][DIFFICULT_CLASS_CABEZON]][difficultSpeed];
			}

			if(iPowerCabezon) {
				g_ModeCabezon_Power[id] = iPowerCabezon;
				g_ModeCabezon_PowerLastUse[id] = 0.0;

				clientPrintColor(id, _, "Recuerda que con la !gLetra G!y tienes poder");
			}

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			strip_user_weapons(id);

			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Cabezón");
		} else if(annihilator) {
			g_SpecialMode[id] = MODE_ANNIHILATOR;
			g_ModeAnnihilator_Kills[id] = 0;

			iHealth = (10000000 * getUsersAlive());
			flSpeed = 300.0;
			flGravity = 0.5;

			new iPowerBazocas = 0;

			if(g_Mode == MODE_ANNIHILATOR) {
				setUserAura(id, 255, 255, 0, 15);

				iPowerBazocas = 5;

				if(g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR] == DIFFICULT_VERY_HARD || g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR] == DIFFICULT_EXPERT) {
					if(g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR] == DIFFICULT_VERY_HARD) {
						iPowerBazocas = 3;
					} else {
						iPowerBazocas = 2;
						sendFog(id, 255, 255, 0, 1);
					}
				}

				flHealth = float(iHealth);
				flHealth *= __DIFFICULTS[DIFFICULT_CLASS_ANNIHILATOR][g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR]][difficultHealth];
				iHealth = floatround(flHealth);

				flSpeed *= __DIFFICULTS[DIFFICULT_CLASS_ANNIHILATOR][g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR]][difficultSpeed];
			}

			set_pdata_int(id, OFFSET_LONG_JUMP, 1, OFFSET_LINUX);

			g_LongJump[id] = 1;
			g_InJump[id] = 0;

			if(iPowerBazocas) {
				clientPrintColor(id, _, "Recuerda que tienes %d bazookas. Para equiparla, presiona la tecla !gTecla 1!y", iPowerBazocas);
				
				g_Bazooka[id] = iPowerBazocas;
				g_Bazooka_LastUse[id] = 0;

				give_item(id, "weapon_mac10");
				cs_set_user_bpammo(id, CSW_MAC10, 100);

				give_item(id, "weapon_ak47");
				cs_set_user_bpammo(id, CSW_AK47, 0);
				set_pdata_int(findEntByOwner(id, "weapon_ak47"), OFFSET_CLIPAMMO, 0, OFFSET_LINUX_WEAPONS);
			}

			g_CurrentWeapon[id] = CSW_KNIFE;
			engclient_cmd(id, "weapon_knife");

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);
			
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Aniquilador");

			replaceWeaponModels(id, CSW_KNIFE);
		} else if(fleshpound) {
			g_SpecialMode[id] = MODE_FLESHPOUND;
			g_ModeFleshpound_Power[id] = 1;

			iHealth = (750000 * getUsersAlive());
			flSpeed = 275.0;
			flGravity = 0.5;

			if(g_Mode == MODE_FLESHPOUND) {
				clientPrintColor(id, _, "Recuerda que tienes un poder especial. Para usarlo, presiona la !gTecla G!y");
			}

			g_CurrentWeapon[id] = CSW_KNIFE;
			engclient_cmd(id, "weapon_knife");

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			set_user_rendering(id, kRenderFxGlowShell, 127, 255, 0, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Fleshpound");

			replaceWeaponModels(id, CSW_KNIFE);
		} else if(grunt) {
			g_SpecialMode[id] = MODE_GRUNT;
			g_ModeGrunt_Power = 0;

			iHealth = 1;
			flSpeed = 400.0;
			flGravity = 0.15;

			strip_user_weapons(id);

			if(g_ModeGrunt_NoDamage) {
				message_begin(MSG_ONE, g_Message_ScreenFade, _, id);
				write_short(0);
				write_short(0);
				write_short(FFADE_STAYOUT);
				write_byte(0);
				write_byte(0);
				write_byte(0);
				write_byte(255);
				message_end();

				set_task(30.0, "task__RemoveGruntScreenFade", id);
			}

			if(g_Mode == MODE_GRUNT) {
				clientPrintColor(id, _, "Recuerda que con la !gTecla G!y lanzas tu poder");
				setUserAura(id, 64, 64, 64, 15);
			}

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			set_user_rendering(id, kRenderFxGlowShell, 198, 226, 255, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Grunt");
		} else {
			iHealth = zombieHealth(id);
			flSpeed = Float:zombieSpeed(id);
			flGravity = Float:zombieGravity(id);

			if(g_DeadTimes[id] > 0) {
				new iExtraHealth = 0;
				new sExtraHealth[16];

				if(g_ModeInfection_Res) {
					iExtraHealth = ((iHealth * (g_DeadTimes[id] * 10)) / 100);
				} else {
					iExtraHealth = ((iHealth * (g_DeadTimes[id] * 5)) / 100);
				}

				addDot(iExtraHealth, sExtraHealth, charsmax(sExtraHealth));

				clientPrintColor(id, _, "Ahora tenés !g+%s!y más de vida hasta que finalice la ronda", sExtraHealth);

				iHealth += iExtraHealth;
			}
			
			if(g_Mode == MODE_DRUNK) {
				iHealth *= 2;
			} else if(g_Mode == MODE_MEGA_DRUNK) {
				iHealth *= 4;
			}

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			emitSound(id, CHAN_VOICE, __SOUND_ZOMBIE_ALERT[random_num(0, charsmax(__SOUND_ZOMBIE_ALERT))]);
		}
	} else {
		iHealth = zombieHealth(id);
		
		if(g_DeadTimes[id] > 0) {
			new iExtraHealth;
			new sExtraHealth[16];

			if(g_ModeInfection_Res) {
				iExtraHealth = ((iHealth * (g_DeadTimes[id] * 10)) / 100);
			} else {
				iExtraHealth = ((iHealth * (g_DeadTimes[id] * 5)) / 100);
			}

			addDot(iExtraHealth, sExtraHealth, charsmax(sExtraHealth));
			clientPrintColor(id, _, "Ahora tenés !g+%s!y más de vida hasta que finalice la ronda", sExtraHealth);

			iHealth += iExtraHealth;
		}

		if(g_Mode == MODE_DRUNK) {
			iHealth *= 2;
		} else if(g_Mode == MODE_MEGA_DRUNK) {
			iHealth *= 4;
		}

		flSpeed = Float:zombieSpeed(id);
		flGravity = Float:zombieGravity(id);

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != TEAM_TERRORIST) {
		setUserTeam(id, TEAM_TERRORIST);
	}

	setUserAllModels(id);
	updateDamageNeed(id);

	if(g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_GRUNT) {
		if(!g_Frozen[id]) {
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
			write_short(UNIT_SECOND);
			write_short(0);
			write_short(FFADE_IN);
			write_byte(g_UserOptions_Color[id][COLOR_TYPE_NVISION][0]);
			write_byte(g_UserOptions_Color[id][COLOR_TYPE_NVISION][1]);
			write_byte(g_UserOptions_Color[id][COLOR_TYPE_NVISION][2]);
			write_byte(255);
			message_end();
		}

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, id);
		write_short(UNIT_SECOND * 4);
		write_short(UNIT_SECOND * 2);
		write_short(UNIT_SECOND * 10);
		message_end();

		new vecOrigin[3];
		get_user_origin(id, vecOrigin);

		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_IMPLOSION);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord(vecOrigin[2]);
		write_byte(128);
		write_byte(20);
		write_byte(3);
		message_end();

		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_PARTICLEBURST);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord(vecOrigin[2]);
		write_short(50);
		write_byte(70);
		write_byte(3);
		message_end();

		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_DLIGHT);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord(vecOrigin[2]);
		write_byte(20);
		write_byte(g_UserOptions_Color[id][COLOR_TYPE_NVISION][0]);
		write_byte(g_UserOptions_Color[id][COLOR_TYPE_NVISION][1]);
		write_byte(g_UserOptions_Color[id][COLOR_TYPE_NVISION][2]);
		write_byte(2);
		write_byte(0);
		message_end();
	}

	message_begin(MSG_ONE, g_Message_Fov, _, id);
	write_byte(110);
	message_end();

	if(g_Mode != MODE_L4D2) {
		setUserNVision(id, 1);
	}

	turnOffFlashlight(id);

	if(g_Mode == MODE_INFECTION && g_Zombie[id] && !g_SpecialMode[id] && g_HabRotate[id][HAB_ROTATE_REGENERATION]) {
		g_HabRotate_Regeneration[id] = 0;

		remove_task(id + TASK_HEALTH_REGENERATION_ROTATE);
		set_task(2.5, "task__HealthRegenerationRotate", id + TASK_HEALTH_REGENERATION_ROTATE, .flags="b");
	}

	checkLastZombie();
}

public setUserAllModels(const id) {
	rg_reset_user_model(id);

	switch(g_SpecialMode[id]) {
		case MODE_SURVIVOR: {
			rg_set_user_model(id, __PLAYER_MODEL_SURVIVOR);
		} case MODE_WESKER: {
			rg_set_user_model(id, __PLAYER_MODEL_WESKER);
		} case MODE_LEATHERFACE: {
			rg_set_user_model(id, __PLAYER_MODEL_LEATHERFACE);
		} case MODE_NEMESIS: {
			rg_set_user_model(id, __PLAYER_MODEL_NEMESIS);
		} case MODE_CABEZON: {
			rg_set_user_model(id, __PLAYER_MODEL_CABEZON);
		} case MODE_ANNIHILATOR: {
			rg_set_user_model(id, __PLAYER_MODEL_ANNIHILATOR);
		} case MODE_FLESHPOUND: {
			rg_set_user_model(id, __PLAYER_MODEL_FLESHPOUND);
		} case MODE_GRUNT: {
			rg_set_user_model(id, __PLAYER_MODEL_GRUNT);
		} case MODE_TRIBAL: {
			rg_set_user_model(id, __PLAYER_MODEL_TRIBAL);
		} case MODE_SNIPER: {
			rg_set_user_model(id, __PLAYER_MODEL_SNIPER);
		} case MODE_L4D2: {
			rg_set_user_model(id, __PLAYER_MODEL_L4D2[g_ModeL4D2_Human[id]]);
		} default: {
			if(g_Zombie[id]) {
				if((get_user_flags(id) & ADMIN_RESERVATION)) {
					rg_set_user_model(id, __PLAYER_MODEL_ZOMBIE_VIP);
				} else {
					rg_set_user_model(id, __PLAYER_MODEL_ZOMBIE);
				}
			} else {
				if((get_user_flags(id) & ADMIN_RESERVATION)) {
					rg_set_user_model(id, __PLAYER_MODEL_HUMAN_VIP);
				} else {
					rg_set_user_model(id, __PLAYER_MODEL_HUMAN);
				}
			}
		}
	}
}

public task__HealthRegenerationRotate(const task_id) {
	new iId = (task_id - TASK_HEALTH_REGENERATION_ROTATE);

	if(!g_IsAlive[iId] || !g_Zombie[iId] || g_SpecialMode[iId] || !g_HabRotate[iId][HAB_ROTATE_REGENERATION]) {
		return;
	}

	new iTotal = (g_Health[iId] + (500 * (g_HabRotate_Regeneration[iId] + 1)));

	if(iTotal < 0) {
		iTotal = 0;
	} else if(iTotal > g_MaxHealth[iId]) {
		return;
	}

	set_user_health(iId, iTotal);
	g_Health[iId] = get_user_health(iId);

	++g_HabRotate_Regeneration[iId];
}

public zombieClassLevel(const id) {
	new iLevelTotal = getUserLevelTotal(id);
	new iTotal = 0;

	while(iLevelTotal >= ZOMBIE_PER_LEVEL) {
		iLevelTotal -= ZOMBIE_PER_LEVEL;
		++iTotal;
	}

	return iTotal;
}

public zombieHealthBase(const id) {
	new iHealth = ZOMBIE_HEALTH_BASE;

	if(getUserLevelTotal(id) >= ZOMBIE_PER_LEVEL) {
		iHealth += ((zombieClassLevel(id) * iHealth) / 100);
	}

	return ((iHealth > ZOMBIE_HEALTH_BASE_MAX) ? ZOMBIE_HEALTH_BASE_MAX : iHealth);
}

public zombieHealthExtra(const id) {
	new iExtra = 0;
	new iHab = (g_Hab[id][HAB_Z_HEALTH] + __HATS[g_HatId[id]][hatUpgrade1] + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acHealth] : 0));

	if(iHab) {
		if(g_Hab[id][HAB_L_UPGRADE_ZOMBIE_HEALTH]) {
			iExtra += ((__HABS[HAB_Z_HEALTH][habValue] + (__HABS[HAB_L_UPGRADE_ZOMBIE_HEALTH][habValue] * g_Hab[id][HAB_L_UPGRADE_ZOMBIE_HEALTH])) * iHab);
		} else {
			iExtra += (__HABS[HAB_Z_HEALTH][habValue] * iHab);
		}
	}

	iExtra += giveResetZombieHealth(id, g_Reset[id]);

	return iExtra;
}

public zombieHealth(const id) {
	return (zombieHealthBase(id) + zombieHealthExtra(id));
}

public Float:zombieSpeedBase(const id) {
	new Float:flSpeed = ZOMBIE_SPEED_BASE;

	if(getUserLevelTotal(id) >= ZOMBIE_PER_LEVEL) {
		flSpeed += (ZOMBIE_SPEED_BASE_MULT * float(zombieClassLevel(id)));
	}

	return ((flSpeed > ZOMBIE_SPEED_BASE_MAX) ? ZOMBIE_SPEED_BASE_MAX : flSpeed);
}

public Float:zombieSpeedExtra(const id) {
	new Float:flExtra = 0.0;
	new Float:flHab = (float(g_Hab[id][HAB_Z_SPEED]) + float(__HATS[g_HatId[id]][hatUpgrade2]) + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acSpeed] : 0));

	if(flHab) {
		flExtra += ((float(__HABS[HAB_Z_SPEED][habValue]) / 2.0) * flHab);
	}

	return flExtra;
}

public Float:zombieSpeed(const id) {
	return (zombieSpeedBase(id) + zombieSpeedExtra(id));
}

public Float:zombieGravityBase(const id) {
	new Float:flGravity = ZOMBIE_GRAVITY_BASE;

	if(getUserLevelTotal(id) >= ZOMBIE_PER_LEVEL) {
		flGravity -= (ZOMBIE_GRAVITY_BASE_MULT * float(zombieClassLevel(id)));
	}

	return ((flGravity < ZOMBIE_GRAVITY_BASE_MAX) ? ZOMBIE_GRAVITY_BASE_MAX : flGravity);
}

public Float:zombieGravityExtra(const id) {
	new Float:flExtra = 0.0;
	new Float:flHab = (float(g_Hab[id][HAB_Z_GRAVITY]) + float(__HATS[g_HatId[id]][hatUpgrade3]) + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acGravity] : 0));

	if(flHab) {
		flExtra -= ((float(__HABS[HAB_Z_GRAVITY][habValue]) / 166.666666) * flHab);
	}

	return flExtra;
}

public Float:zombieGravity(const id) {
	new Float:flTotal = (zombieGravityBase(id) + zombieGravityExtra(id));
	return ((flTotal < ZOMBIE_GRAVITY_MAX) ? ZOMBIE_GRAVITY_MAX : flTotal);
}

public zombieDamageExtra(const id) {
	new iDamage = 0;
	new iHab = (g_Hab[id][HAB_Z_DAMAGE] + __HATS[g_HatId[id]][hatUpgrade4] + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acDamage] : 0));

	if(iHab) {
		iDamage += (__HABS[HAB_Z_DAMAGE][habValue] * iHab);
	}

	return iDamage;
}

public zombieDamage(const id) {
	return (zombieDamageExtra(id));
}

humanMe(const id, silent_mode=0, survivor=0, wesker=0, leatherface=0, tribal=0, sniper=0, l4d2=0) {
	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_DRUG);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_HEALTH_REGENERATION);
	remove_task(id + TASK_HEALTH_IMMUNITY);
	remove_task(id + TASK_HEALTH_REGENERATION_ROTATE);
	remove_task(id + TASK_CONVERT_ZOMBIE);

	if(isPlayerStuck(id)) {
		clientPrintColor(id, _, "Has sido teletransportado porque te habías trabado con un humano");
		randomSpawn(id);
	}

	if(g_InGroup[id] && g_Zombie[id]) {
		finishComboHuman(id);
	}

	g_CanBuy[id] = 1;
	g_Zombie[id] = 0;
	g_SpecialMode[id] = MODE_NONE;
	g_Immunity[id] = 0;
	g_ImmunityBombs[id] = 0;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_ComboZombieEnabled[id] = 0;
	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;

	cs_set_user_zoom(id, CS_RESET_ZOOM, 1);
	set_user_rendering(id);

	if(g_Frozen[id]) {
		remove_task(id + TASK_FREEZE);
		task__RemoveFreeze(id + TASK_FREEZE);
	}

	strip_user_weapons(id);

	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;

	give_item(id, "weapon_knife");

	updatePlayerHat(id);

	new iHealth;
	new Float:flHealth;
	new Float:flSpeed;
	new Float:flGravity;
	new iArmor;

	if(survivor) {
		g_SpecialMode[id] = MODE_SURVIVOR;

		new iPowerBomb = 0;

		if(g_Mode == MODE_PLAGUE) {
			iHealth = 2500;
			flSpeed = 250.0;
			flGravity = 1.0;
			iArmor = 0;
		} else if(g_Mode == MODE_ARMAGEDDON) {
			iHealth = 5000;
			flSpeed = 250.0;
			flGravity = 1.0;
			iArmor = 0;
		} else if(g_Mode == MODE_MEGA_ARMAGEDDON) {
			iHealth = (100 * getUsersPlaying());
			flSpeed = 275.0;
			flGravity = 1.0;
			iArmor = 0;
		} else if(g_Mode == MODE_MEGA_DRUNK) {
			iHealth = 8250;
			flSpeed = 280.0;
			flGravity = 0.8;
			iArmor = 0;
		} else {
			setUserAura(id, 0, 0, 255, 15);

			iPowerBomb = 1;

			if(g_Difficult[id][DIFFICULT_CLASS_SURVIVOR] == DIFFICULT_VERY_HARD || g_Difficult[id][DIFFICULT_CLASS_SURVIVOR] == DIFFICULT_EXPERT) {
				if(g_Difficult[id][DIFFICULT_CLASS_SURVIVOR] == DIFFICULT_VERY_HARD) {
					iPowerBomb = 2;
					sendFog(id, 0, 0, 255, 1);
				} else {
					iPowerBomb = 0;
					sendFog(id, 0, 0, 255, 2);
				}
			}

			iHealth = ((100 * getUsersAlive()) + (__HABS[HAB_S_S_HEALTH][habValue] * g_Hab[id][HAB_S_S_HEALTH]));
			flHealth = float(iHealth);
			flHealth *= __DIFFICULTS[DIFFICULT_CLASS_SURVIVOR][g_Difficult[id][DIFFICULT_CLASS_SURVIVOR]][difficultHealth];
			iHealth = floatround(flHealth);

			flSpeed = 250.0;
			flSpeed *= __DIFFICULTS[DIFFICULT_CLASS_SURVIVOR][g_Difficult[id][DIFFICULT_CLASS_SURVIVOR]][difficultSpeed];

			flGravity = 1.0;
			iArmor = 0;
		}

		if(iPowerBomb) {
			if(iPowerBomb == 2) {
				clientPrintColor(id, _, "Recordá que tenes una !gbomba de aniquilación!y");
			} else {
				clientPrintColor(id, _, "Recordá que tenes una !gbomba de aniquilación e inmunidad!y que podes activar presionando el clic derecho");
			}

			if(g_Hab[id][HAB_S_S_EXTRA_BOMB]) {
				give_item(id, "weapon_hegrenade");
				cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
				g_KillBomb[id] = 2;
			} else {
				give_item(id, "weapon_hegrenade");
				g_KillBomb[id] = 1;
			}
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);
		set_user_armor(id, iArmor);

		switch(g_Hab[id][HAB_S_S_WEAPON]) {
			case 0: {
				give_item(id, "weapon_mp5navy");
			} case 1: {
				give_item(id, "weapon_m249");
			} case 2: {
				give_item(id, "weapon_m4a1");
			}
		}

		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 4);

		turnOffFlashlight(id);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Survivor");
	} else if(wesker) {
		g_SpecialMode[id] = MODE_WESKER;

		iHealth = (60 * getUsersAlive());
		flSpeed = 275.0;
		flGravity = 0.75;
		iArmor = 150;

		new iPowerLaser = 3;

		if(g_Mode == MODE_WESKER) {
			setUserAura(id, 0, 255, 255, 15);

			if(g_Difficult[id][DIFFICULT_CLASS_WESKER] == DIFFICULT_VERY_HARD || g_Difficult[id][DIFFICULT_CLASS_WESKER] == DIFFICULT_EXPERT) {
				iPowerLaser = 0;

				if(g_Difficult[id][DIFFICULT_CLASS_WESKER] == DIFFICULT_EXPERT) {
					sendFog(id, 0, 255, 255, 1);
				}
			}

			give_item(id, "weapon_smokegrenade");
			g_BubbleBomb[id] = 1;

			flHealth = float(iHealth);
			flHealth *= __DIFFICULTS[DIFFICULT_CLASS_WESKER][g_Difficult[id][DIFFICULT_CLASS_WESKER]][difficultHealth];
			iHealth = floatround(flHealth);

			flSpeed *= __DIFFICULTS[DIFFICULT_CLASS_WESKER][g_Difficult[id][DIFFICULT_CLASS_WESKER]][difficultSpeed];
		}

		if(iPowerLaser) {
			g_WeskLaser[id] = iPowerLaser;
			g_WeskLaser_LastUse[id] = 0.0;

			clientPrintColor(id, _, "Recordá que tenes !g3 laser!y que podes disparar presionando el clic derecho");
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);
		set_user_armor(id, iArmor);

		give_item(id, "weapon_deagle");
		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 0, 255, 255, kRenderNormal, 4);

		turnOffFlashlight(id);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Wesker");
	} else if(leatherface) {
		g_SpecialMode[id] = MODE_LEATHERFACE;

		iHealth = (300 * getUsersAlive());
		flSpeed = 275.0;
		flGravity = 0.75;
		iArmor = 100;

		new iPowerTP = 0;

		if(g_Mode == MODE_LEATHERFACE) {
			setUserAura(id, 255, 0, 255, 15);

			iPowerTP = 1;

			if(g_Difficult[id][DIFFICULT_CLASS_WESKER] == DIFFICULT_VERY_HARD || g_Difficult[id][DIFFICULT_CLASS_WESKER] == DIFFICULT_EXPERT) {
				iPowerTP = 0;

				if(g_Difficult[id][DIFFICULT_CLASS_WESKER] == DIFFICULT_EXPERT) {
					sendFog(id, 255, 0, 255, 1);
				}
			}

			flHealth = float(iHealth);
			flHealth *= __DIFFICULTS[DIFFICULT_CLASS_LEATHERFACE][g_Difficult[id][DIFFICULT_CLASS_LEATHERFACE]][difficultHealth];
			iHealth = floatround(flHealth);

			flSpeed *= __DIFFICULTS[DIFFICULT_CLASS_LEATHERFACE][g_Difficult[id][DIFFICULT_CLASS_LEATHERFACE]][difficultSpeed];
		} else if(g_Mode == MODE_MEGA_DRUNK) {
			iHealth *= 3;
		}

		if(iPowerTP) {
			if(g_Hab[id][HAB_S_L_TELEPORT]) {
				g_Leatherface_Teleport[id] = 0;
				clientPrintColor(id, _, "Recorda que tienes !gTELETRANSPORTACIÓN!y que puedes utilizarlo presionando la Tecla G");
			}
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);
		set_user_armor(id, iArmor);

		set_user_rendering(id, kRenderFxGlowShell, 255, 0, 255, kRenderNormal, 4);

		turnOffFlashlight(id);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "LeatherFace");

		replaceWeaponModels(id, CSW_KNIFE);
	} else if(tribal) {
		g_SpecialMode[id] = MODE_TRIBAL;
		g_ModeTribal_Damage[id] = 0;

		iHealth = (250 * getUsersAlive());
		flSpeed = 300.0;
		flGravity = 0.75;

		if(g_Mode == MODE_MEGA_DRUNK) {
			iHealth *= 2;
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		if(g_Mode == MODE_TRIBAL) {
			clientPrintColor(id, _, "Recuerda que estando cerca de tu compañero puedes lanzar tu poder. Lánzalo con la !gTecla G!y");
			setUserAura(id, 255, 165, 0, 20);
		}

		if((tribal % 2) == 0) {
			give_item(id, "weapon_ak47");
		} else {
			give_item(id, "weapon_m4a1");
		}

		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 255, 165, 0, kRenderNormal, 4);

		turnOffFlashlight(id);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Tribal");
	} else if(sniper) {
		g_SpecialMode[id] = MODE_SNIPER;
		g_SniperPower[id] = 0;

		if((sniper % 2) == 0) {
			iHealth = (200 * getUsersAlive());

			if(g_Mode == MODE_MEGA_DRUNK) {
				iHealth *= 2;
			}
		} else {
			iHealth = (100 * getUsersAlive());

			if(g_Mode == MODE_MEGA_DRUNK) {
				iHealth *= 3;
			}
		}

		flSpeed = 300.0;
		flGravity = 0.6;

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		if(g_Mode == MODE_SNIPER) {
			clientPrintColor(id, _, "Recuerda que con la !gLetra G!y lanzas tu poder");
			setUserAura(id, 0, 255, 0, 20);
		}

		if((sniper % 2) == 0) {
			rg_give_item(id, "weapon_awp");
		} else {
			rg_give_item(id, "weapon_scout");
		}

		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 4);

		turnOffFlashlight(id);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Sniper");
	} else if(l4d2) {
		g_SpecialMode[id] = MODE_L4D2;

		iHealth = (150 * getUsersAlive());
		flSpeed = 275.0;
		flGravity = 1.25;

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		switch(l4d2) {
			case 1: {
				give_item(id, "weapon_ak47");
				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Bill");
			} case 2: {
				give_item(id, "weapon_mp5navy");
				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Francis");
			} case 3: {
				give_item(id, "weapon_aug");
				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Louis");
			} case 4: {
				give_item(id, "weapon_sg552");
				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Zoey");
			}
		}

		set_user_rendering(id, kRenderFxGlowShell, 199, 21, 133, kRenderNormal, 4);

		g_UnlimitedClip[id] = 1;
		g_PrecisionPerfect[id] = 1;
		g_ModeL4D2_Human[id] = (l4d2 - 1);
	} else {
		if(!silent_mode) {
			emitSound(id, CHAN_ITEM, __SOUND_HUMAN_ANTIDOTE);
		}

		set_task(0.19, "task__ClearWeapons", id + TASK_SPAWN);
		set_task(0.2, "task__SetWeapons", id + TASK_SPAWN);

		iHealth = humanHealth(id);
		flSpeed = Float:humanSpeed(id);
		flGravity = Float:humanGravity(id);
		iArmor = humanArmor(id);

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);
		set_user_armor(id, iArmor);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Humano");
	}

	if(g_Mode == MODE_DUEL_FINAL) {
		set_user_health(id, 100);
		g_Speed[id] = 255.0;
		set_user_gravity(id, 1.0);
		set_user_armor(id, 0);

		strip_user_weapons(id);
		give_item(id, "weapon_knife");
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != TEAM_CT) {
		setUserTeam(id, TEAM_CT);
	}

	setUserAllModels(id);
	updateDamageNeed(id);

	message_begin(MSG_ONE, g_Message_Fov, _, id);
	write_byte(90);
	message_end();

	if(g_NVision[id]) {
		setUserNVision(id, 0);
	}

	checkLastZombie();
}

public humanClassLevel(const id) {
	new iLevelTotal = getUserLevelTotal(id);
	new iTotal = 0;

	while(iLevelTotal >= HUMAN_PER_LEVEL) {
		iLevelTotal -= HUMAN_PER_LEVEL;
		++iTotal;
	}

	return iTotal;
}

public humanHealthBase(const id) {
	new iHealth = HUMAN_HEALTH_BASE;

	if(getUserLevelTotal(id) >= HUMAN_PER_LEVEL) {
		iHealth += ((humanClassLevel(id) * iHealth) / 100);
	}

	return ((iHealth > HUMAN_HEALTH_BASE_MAX) ? HUMAN_HEALTH_BASE_MAX : iHealth);
}

public humanHealthExtra(const id) {
	new iExtra = 0;
	new iHab = (g_Hab[id][HAB_H_HEALTH] + __HATS[g_HatId[id]][hatUpgrade1] + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acHealth] : 0));

	if(iHab) {
		iExtra += (__HABS[HAB_H_HEALTH][habValue] * iHab);
	}

	return iExtra;
}

public humanHealth(const id) {
	return (humanHealthBase(id) + humanHealthExtra(id));
}

public Float:humanSpeedBase(const id) {
	new Float:flSpeed = HUMAN_SPEED_BASE;

	if(getUserLevelTotal(id) >= HUMAN_PER_LEVEL) {
		flSpeed += (HUMAN_SPEED_BASE_MULT * float(humanClassLevel(id)));
	}

	return ((flSpeed > HUMAN_SPEED_BASE_MAX) ? HUMAN_SPEED_BASE_MAX : flSpeed);
}

public Float:humanSpeedExtra(const id) {
	new Float:flExtra = 0.0;
	new Float:flHab = (float(g_Hab[id][HAB_H_SPEED]) + float(__HATS[g_HatId[id]][hatUpgrade2]) + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acSpeed] : 0));

	if(flHab) {
		flExtra += ((float(__HABS[HAB_H_SPEED][habValue]) / 2.0) * flHab);
	}

	return flExtra;
}

public Float:humanSpeed(const id) {
	return (humanSpeedBase(id) + humanSpeedExtra(id));
}

public Float:humanGravityBase(const id) {
	new Float:flGravity = HUMAN_GRAVITY_BASE;

	if(getUserLevelTotal(id) >= HUMAN_PER_LEVEL) {
		flGravity -= (HUMAN_GRAVITY_BASE_MULT * float(humanClassLevel(id)));
	}

	return ((flGravity < HUMAN_GRAVITY_BASE_MAX) ? HUMAN_GRAVITY_BASE_MAX : flGravity);
}

public Float:humanGravityExtra(const id) {
	new Float:flExtra = 0.0;
	new Float:flHab = (float(g_Hab[id][HAB_H_GRAVITY]) + float(__HATS[g_HatId[id]][hatUpgrade3]) + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acGravity] : 0));

	if(flHab) {
		flExtra -= ((float(__HABS[HAB_H_GRAVITY][habValue]) / 166.666666) * flHab);
	}

	return flExtra;
}

public Float:humanGravity(const id) {
	new Float:flTotal = (humanGravityBase(id) + humanGravityExtra(id));
	return ((flTotal < HUMAN_GRAVITY_MAX) ? HUMAN_GRAVITY_MAX : flTotal);
}

public Float:humanDamageBase(const id) {
	new Float:flDamage = HUMAN_DAMAGE_PERCENT_BASE;

	if(getUserLevelTotal(id) >= HUMAN_PER_LEVEL) {
		flDamage += (HUMAN_DAMAGE_PERCENT_BASE_MULT * float(humanClassLevel(id)));
	}

	return flDamage;
}

public Float:humanDamageExtra(const id) {
	new Float:flExtra = 0.0;
	new Float:flHab = (float(g_Hab[id][HAB_H_DAMAGE]) + float(__HATS[g_HatId[id]][hatUpgrade4]) + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acDamage] : 0));

	if(flHab) {
		if(g_Hab[id][HAB_L_UPGRADE_HUMAN_DAMAGE]) {
			flExtra += ((float(__HABS[HAB_H_DAMAGE][habValue]) + (float(__HABS[HAB_L_UPGRADE_HUMAN_DAMAGE][habValue]) * float(g_Hab[id][HAB_L_UPGRADE_HUMAN_DAMAGE]))) * flHab);
		} else {
			flExtra += (float(__HABS[HAB_H_DAMAGE][habValue]) * flHab);
		}
	}

	if(g_WeaponSkills[id][g_CurrentWeapon[id]][WEAPON_SKILL_DAMAGE]) {
		flExtra += (50.0 * float(g_WeaponSkills[id][g_CurrentWeapon[id]][WEAPON_SKILL_DAMAGE]));
	}

	if(g_Reset[id]) {
		flExtra += giveResetHumanDamage(id, g_Reset[id]);
	}

	return flExtra;
}

public Float:humanDamage(const id) {
	return (humanDamageBase(id) + humanDamageExtra(id));
}

public humanArmor(const id) {
	new iArmor = 0;
	new iHab = (g_Hab[id][HAB_H_ARMOR]);

	if(iHab) {
		iArmor += (__HABS[HAB_H_ARMOR][habValue] * iHab);
	}

	return iArmor;
}

public checkLastZombie() {
	new iUsersPlaying = getUsersPlaying();
	new iZombies = getZombies();
	new iHumans = getHumans();
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i] && g_Zombie[i] && !g_SpecialMode[i] && iZombies == 1) {
			g_LastZombie[i] = 1;
		} else {
			g_LastZombie[i] = 0;
		}

		if(g_IsAlive[i] && !g_Zombie[i] && !g_SpecialMode[i] && iHumans == 1) {
			if(!g_Hat_Devil[i] && g_Mode == MODE_INFECTION && iUsersPlaying >= 15) {
				giveHat(i, HAT_DEVIL);
			}

			g_LastHuman[i] = 1;

			if(!g_LastHumanOk[i] && g_Mode == MODE_INFECTION) {
				g_LastHumanOk[i] = 1;
				g_LastHumanOk_NoRespawn = 1;

				set_user_health(i, 1000);
				g_Health[i] = get_user_health(i);
			}
		} else {
			g_LastHuman[i] = 0;
		}
	}
}

public checkEvents() {
	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new iTimeToUnix[3];

	unix_to_time(iSysTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);

	iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 12, 00, 00);
	iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 16, 59, 00);

	if(iSysTime >= iTimeToUnix[0] && iSysTime <= iTimeToUnix[1]) {
		g_DrunkAtDay = 1;
	}

	iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 22, 00, 00);
	iTimeToUnix[2] = time_to_unix(iYear, iMonth, iDay, 00, 00, 00);
	iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 06, 00, 00);

	if((iSysTime >= iTimeToUnix[0]) || (iSysTime >= iTimeToUnix[2] && iSysTime <= iTimeToUnix[1])) {
		g_HappyHour = 1;

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 02, 00, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 04, 00, 00);

		if(iSysTime >= iTimeToUnix[0] && iSysTime <= iTimeToUnix[1]) {
			g_HappyHour = 2;

			if(!g_ModeMGG_Played) {
				g_ModeMGG_Played = 2;
			}
		}

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 00, 15, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 01, 45, 00);

		if(iSysTime >= iTimeToUnix[0] && iSysTime < iTimeToUnix[1]) {
			g_EventModes = 1;
		}
	}

	checkMasteryHour();
}

public checkMasteryHour() {
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

public changeLights() {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			setLight(i, 0, g_Lights[0]);
		}
	}
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

public maxXPPerReset(const reset) {
	switch(reset) {
		case 0..4: {
			return ((reset + 1) * 1000000);
		} case 5..9: {
			return (reset * 1500000);
		} case 10..14: {
			return (reset * 2000000);
		} case 15..19: {
			return (reset * 2500000);
		} case 20..24: {
			return (reset * 3000000);
		} case 25..29: {
			return (reset * 3500000);
		} case 30..34: {
			return (reset * 4000000);
		} case 35..39: {
			return (reset * 4500000);
		} case 40..44: {
			return (reset * 5000000);
		} case 45..49: {
			return (reset * 5500000);
		} case 50..54: {
			return (reset * 6000000);
		} case 55..59: {
			return (reset * 6500000);
		} case 60..64: {
			return (reset * 7000000);
		} case 65..69: {
			return (reset * 7500000);
		} case 70..74: {
			return (reset * 8000000);
		} case 75..79: {
			return (reset * 8500000);
		} case 80..84: {
			return (reset * 9000000);
		} case 85..89: {
			return (reset * 9500000);
		} case 90..94: {
			return (reset * 10000000);
		} case 95..100: {
			return (reset * 10500000);
		} case 101..110: {
			return (reset * 11000000);
		} case 111..120: {
			return (reset * 11500000);
		} case 121..130: {
			return (reset * 12000000);
		} case 131..140: {
			return (reset * 12500000);
		} case 141..150: {
			return (reset * 13000000);
		} case 151..160: {
			return (reset * 13500000);
		} case 161..170: {
			return (reset * 14000000);
		} case 171..180: {
			return (reset * 14500000);
		} case 181..190: {
			return (reset * 15000000);
		} case 191..200: {
			return (reset * 15500000);
		} case 201..210: {
			return (reset * 16000000);
		} case 211..220: {
			return (reset * 16500000);
		} case 221..230: {
			return (reset * 17000000);
		} case 231..240: {
			return (reset * 17500000);
		} case 241..250: {
			return (reset * 18000000);
		} case 251..260: {
			return (reset * 18500000);
		} case 261..275: {
			return (reset * 19000000);
		} case 276..300: {
			return (reset * 19500000);
		} default: {
			new iMax = (reset * 20000000);

			if(iMax >= MAX_XP) {
				return MAX_XP;
			}

			return iMax;
		}
	}
	
	return 0;
}

public checkXPEquation(const id) {
	if(g_Level[id] >= MAX_LEVEL) {
		g_XP[id] = maxXPPerReset(g_Reset[id]);
		g_XPRest[id] = 0;
	} else {
		g_XPRest[id] = (xpThisLevel(id, g_Level[id]) - g_XP[id]);

		if(g_XPRest[id] <= 0) {
			new iLevel = 0;

			while(g_XPRest[id] <= 0) {
				g_XP[id] -= xpThisLevel(id, g_Level[id]);

				++g_Level[id];
				++iLevel;

				if(g_Level[id] >= MAX_LEVEL) {
					checkXPEquation(id);
					break;
				}

				g_XPRest[id] = (xpThisLevel(id, g_Level[id]) - g_XP[id]);
			}

			if(iLevel) {
				clientPrint(id, print_center, "Subiste %d nivel%s", iLevel, ((iLevel != 1) ? "es" : ""));
				emitSound(id, CHAN_BODY, __SOUND_LEVEL_UP);

				if((g_Level[id] % 100) == 0) {
					clientPrintColor(id, _, "Has aumentado tus estadísticas humanas y zombies. Revisa el menú de estadísticas y verás el aumento de los mismos");
				}
			}
		}
	}

	addDot(g_XPRest[id], g_XPRestHud[id], charsmax(g_XPRestHud[]));

	g_LevelPercent[id] = ((float(g_XP[id]) * 100.0) / float(xpThisLevelRest1(id, g_Level[id])));
	g_ResetPercent[id] = (((float(g_Level[id])) * 100.0) / float(MAX_LEVEL));
}

public addXP(const id, const value) {
	if(g_XP[id] >= maxXPPerReset(g_Reset[id])) {
		return;
	}

	g_XP[id] += value;
	addDot(g_XP[id], g_XPHud[id], charsmax(g_XPHud[]));

	checkXPEquation(id);
}

public giveResetMoney(const id, const reset) {
	return (reset * 5);
}

public giveResetHumanDamage(const id, const reset) {
	return (50 * reset);
}

public giveResetZombieHealth(const id, const reset) {
	return (50000 * reset);
}

public showCurrentComboHuman(const id, const Float:damage) {
	if(g_Mode == MODE_CABEZON) {
		static sBullets[8];
		static iReward;
		static sReward[16];

		iReward = (((g_ModeCabezon_Head[id] * (10 + g_Reset[id])) * getUserLevelTotal(id) * 5) * floatround(g_XPMult[id]));

		if(iReward < 0 || iReward > MAX_XP) {
			if(iReward < 0) {
				iReward = MAX_XP;
			}

			addXP(id, iReward);

			g_ModeCabezon_Head[id] = 0;
			return;
		}

		addDot(g_ModeCabezon_Head[id], sBullets, charsmax(sBullets));
		addDot(iReward, sReward, charsmax(sReward));

		set_hudmessage(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][2], -1.0, g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], 0.0, 8.0, 0.0, 0.0, -1);
		ShowSyncHudMsg(id, g_HudSync_Combo, "Disparos a la cabeza: %s | +%s XP", sBullets, sReward);

		return;
	} else if(g_Mode == MODE_ANNIHILATOR) {
		static sBullets[8];
		static iReward;
		static sReward[16];

		iReward = (g_ModeAnnihilator_Acerts[id] * (floatround(g_XPMult[id]) * 12) * getUserLevelTotal(id));

		if(iReward < 0 || iReward > MAX_XP) {
			if(iReward < 0) {
				iReward = MAX_XP;
			}

			addXP(id, iReward);

			g_ModeAnnihilator_Acerts[id] = 0;
			return;
		}

		addDot(g_ModeAnnihilator_Acerts[id], sBullets, charsmax(sBullets));
		addDot(iReward, sReward, charsmax(sReward));

		set_hudmessage(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][2], -1.0, g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], 0.0, 8.0, 0.0, 0.0, -1);
		ShowSyncHudMsg(id, g_HudSync_Combo, "Disparos acertados: %s | +%s XP", sBullets, sReward);

		return;
	}

	if((g_SpecialMode[id] == MODE_WESKER && !g_Hab[id][HAB_S_W_COMBO]) || (g_SpecialMode[id] == MODE_LEATHERFACE && !g_Hab[id][HAB_S_L_COMBO])) {
		return;
	}

	if(g_InGroup[id]) {
		g_HLTime_GroupCombo[g_InGroup[id]] = (halflife_time() + 5.75);

		static iCombo;
		static Float:flDamageTotal;
		static sComboIndividual[16];
		static sCombo[16];
		static sDamageTotal[32];
		static sDamageTotalOutPut[32];
		static sDamage[32];
		static sDamageOutPut[32];
		static sReward[16];
		static i;
		static iReward;
		static iCountAlive;

		iCombo = 0;
		flDamageTotal = 0.0;
		iCountAlive = 0;

		for(i = 1; i < 4; ++i) {
			if(g_GroupId[g_InGroup[id]][i] && !g_Zombie[g_GroupId[g_InGroup[id]][i]] && g_IsAlive[g_GroupId[g_InGroup[id]][i]]) {
				iCombo += g_Combo[g_GroupId[g_InGroup[id]][i]];
				flDamageTotal += g_ComboDamage[g_GroupId[g_InGroup[id]][i]];

				++iCountAlive;
			}
		}

		addDot(iCombo, sCombo, charsmax(sCombo));

		formatex(sDamageTotal, charsmax(sDamageTotal), "%0.0f", flDamageTotal);
		addDotSpecial(sDamageTotal, sDamageTotalOutPut, charsmax(sDamageTotalOutPut));

		formatex(sDamage, charsmax(sDamage), "%0.0f", damage);
		addDotSpecial(sDamage, sDamageOutPut, charsmax(sDamageOutPut));

		if(iCountAlive == 1) {
			iReward = (iCombo * ((iCountAlive - 1) + 3));
		} else {
			iReward = (iCombo * (iCountAlive + 3));
		}

		if(iReward < 0 || iReward > MAX_XP) {
			if(iReward < 0) {
				iReward = MAX_XP;
			}

			finishComboHuman(id, iReward);
			return;
		}

		addDot(iReward, sReward, charsmax(sReward));

		for(i = 1; i < 4; ++i) {
			if(g_GroupId[g_InGroup[id]][i] && !g_Zombie[g_GroupId[g_InGroup[id]][i]] && g_IsAlive[g_GroupId[g_InGroup[id]][i]]) {
				addDot(g_Combo[g_GroupId[g_InGroup[id]][i]], sComboIndividual, charsmax(sComboIndividual));
				
				set_hudmessage(g_UserOptions_Color[g_GroupId[g_InGroup[id]][i]][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[g_GroupId[g_InGroup[id]][i]][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[g_GroupId[g_InGroup[id]][i]][COLOR_TYPE_HUD_COMBO][2], g_UserOptions_Hud[g_GroupId[g_InGroup[id]][i]][HUD_TYPE_COMBO][0], g_UserOptions_Hud[g_GroupId[g_InGroup[id]][i]][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[g_GroupId[g_InGroup[id]][i]][HUD_TYPE_COMBO], 0.0, 5.0, 0.0, 0.0, -1);
				ShowSyncHudMsg(g_GroupId[g_InGroup[id]][i], g_HudSync_Combo, "Combo GRUPAL x%s (%s) | +%s XP^nDaño total: %s | Daño: %s", sCombo, sComboIndividual, sReward, sDamageTotalOutPut, sDamageOutPut);
			}
		}
	} else {
		static Float:flComboTime;
		flComboTime = 5.0;

		if(g_Hab[id][HAB_E_DURATION_COMBO]) {
			flComboTime += ((float(__HABS[HAB_E_DURATION_COMBO][habValue]) / 2.0) * float(g_Hab[id][HAB_E_DURATION_COMBO]));
		}

		g_ComboTime[id] = (halflife_time() + flComboTime);

		while(g_ComboReward[id] < charsmax(__COMBO_HUMAN)) {
			if(g_Combo[id] >= __COMBO_HUMAN[g_ComboReward[id]][comboNeed] && g_Combo[id] < __COMBO_HUMAN[g_ComboReward[id] + 1][comboNeed]) {
				break;
			}

			++g_ComboReward[id];
		}

		g_ComboReward[id] = clamp(g_ComboReward[id], 0, charsmax(__COMBO_HUMAN));
		g_ComboDamageBullet[id] = damage;

		updateComboHuman(id);
	}
}

public updateComboHuman(const id) {
	if(g_Mode == MODE_ANNIHILATOR) {
		return;
	}

	if((g_SpecialMode[id] == MODE_WESKER && !g_Hab[id][HAB_S_W_COMBO]) || (g_SpecialMode[id] == MODE_LEATHERFACE && !g_Hab[id][HAB_S_L_COMBO])) {
		return;
	}

	static sCombo[16];
	static iReward;
	static sReward[16];
	static sDamageTotal[32];
	static sDamageTotalOutPut[32];
	static sDamage[32];
	static sDamageOutPut[32];

	addDot(g_Combo[id], sCombo, charsmax(sCombo));

	iReward = (g_Combo[id] * humanComboReward(id));

	if(iReward < 0 || iReward > MAX_XP) {
		if(iReward < 0) {
			iReward = MAX_XP;
		}

		finishComboHuman(id, iReward);
		return;
	}

	addDot(iReward, sReward, charsmax(sReward));
	
	formatex(sDamageTotal, charsmax(sDamageTotal), "%0.0f", g_ComboDamage[id]);
	addDotSpecial(sDamageTotal, sDamageTotalOutPut, charsmax(sDamageTotalOutPut));

	formatex(sDamage, charsmax(sDamage), "%0.0f", g_ComboDamageBullet[id]);
	addDotSpecial(sDamage, sDamageOutPut, charsmax(sDamageOutPut));

	set_hudmessage(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][2], -1.0, g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], 0.0, 8.0, 0.0, 0.0, -1);
	ShowSyncHudMsg(id, g_HudSync_Combo, "%s^n%sCombo x%s | +%s XP^nDaño total: %s | Daño: %s", __COMBO_HUMAN[g_ComboReward[id]][comboMessage], ((g_Hab[id][HAB_H_TCOMBO]) ? "T-" : ""), sCombo, sReward, sDamageTotalOutPut, sDamageOutPut);
}

public humanComboReward(const id) {
	new iComboReward = (g_ComboReward[id] + 1);

	if(g_Hab[id][HAB_H_TCOMBO]) {
		iComboReward += g_Hab[id][HAB_H_TCOMBO];
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_RING_COMBO]) {
		iComboReward += (1 + (g_Artifact[id][ARTIFACT_RING_COMBO] * 1));
	}

	if(g_ArtifactsEquiped[id][ARTIFACT_BRACELET_COMBO]) {
		++iComboReward;
	}

	if(g_HabRotate[id][HAB_ROTATE_MULTIPLICANDO]) {
		++iComboReward;
	}

	if(g_AmuletCustomCreated[id]) {
		iComboReward += g_AmuletCustom[id][acMultCombo];
	}

	return iComboReward;
}

finishComboHuman(const id, const reward=0) {
	if(g_Mode != MODE_ANNIHILATOR) {
		if(g_InGroup[id]) {
			static iCombo;
			static Float:flDamageTotal;
			static iCountAlive;
			static i;
			static j;

			iCombo = 0;
			flDamageTotal = 0.0;
			iCountAlive = 0;

			for(i = 1; i < 4; ++i) {
				if(g_GroupId[g_InGroup[id]][i] && !g_Zombie[g_GroupId[g_InGroup[id]][i]] && g_IsAlive[g_GroupId[g_InGroup[id]][i]]) {
					iCombo += g_Combo[g_GroupId[g_InGroup[id]][i]];
					flDamageTotal += g_ComboDamage[g_GroupId[g_InGroup[id]][i]];

					g_ComboDamage[g_GroupId[g_InGroup[id]][i]] = 0.0;

					++iCountAlive;
					j = humanComboReward(g_GroupId[g_InGroup[id]][i]);
				}
			}

			if(iCombo) {
				static iReward;
				static sReward[16];
				static sDamageTotal[32];
				static sDamageTotalOutPut[32];

				if(reward) {
					iReward = reward;
				} else {
					iReward = (iCombo * j);

					if(iCountAlive > 1) {
						if(iCountAlive == 2) {
							iReward += ((30 * iReward) / 100);
						} else {
							iReward += ((60 * iReward) / 100);
						}
					}

					if(iReward < 0 || iReward > MAX_XP) {
						iReward = MAX_XP;
					}
				}

				addDot(iReward, sReward, charsmax(sReward));

				formatex(sDamageTotal, charsmax(sDamageTotal), "%0.0f", flDamageTotal);
				addDotSpecial(sDamageTotal, sDamageTotalOutPut, charsmax(sDamageTotalOutPut));

				for(i = 1; i < 4; ++i) {
					if(g_GroupId[g_InGroup[id]][i] && !g_Zombie[g_GroupId[g_InGroup[id]][i]] && g_IsAlive[g_GroupId[g_InGroup[id]][i]]) {
						addXP(g_GroupId[g_InGroup[id]][i], iReward);

						set_hudmessage(g_UserOptions_Color[g_GroupId[g_InGroup[id]][i]][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[g_GroupId[g_InGroup[id]][i]][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[g_GroupId[g_InGroup[id]][i]][COLOR_TYPE_HUD_COMBO][2], -1.0, g_UserOptions_Hud[g_GroupId[g_InGroup[id]][i]][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[g_GroupId[g_InGroup[id]][i]][HUD_TYPE_COMBO], 1.0, 5.0, 0.1, 3.0, -1);
						ShowSyncHudMsg(g_GroupId[g_InGroup[id]][i], g_HudSync_Combo, "Ganaron +%s de XP^nDaño total grupal: %s", sReward, sDamageTotalOutPut);

						clientPrintColor(g_GroupId[g_InGroup[id]][i], _, "Tu combo grupal ha finalizado y han ganado !g%s XP!y", sReward);

						if(g_Hab[g_GroupId[g_InGroup[id]][i]][HAB_L_XP_MULT_IN_COMBO]) {
							giveExtraForHab(g_GroupId[g_InGroup[id]][i], iReward, 1);
						}

						if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 1000) {
							setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x1000);

							if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 5000) {
								setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x5000);

								if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 25000) {
									setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x25000);

									if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 75000) {
										setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x75000);

										if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 150000) {
											setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x150000);

											if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 500000) {
												setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x500000);

												if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 2500000) {
													setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x2500000);

													if(g_Combo[g_GroupId[g_InGroup[id]][i]] >= 10000000) {
														setAchievement(g_GroupId[g_InGroup[id]][i], COMBO_x10000000);
													}
												}
											}
										}
									}
								}
							}
						}

						if(g_Combo[g_GroupId[g_InGroup[id]][i]] > g_MaxComboHumanMap && !g_SpecialMode[g_GroupId[g_InGroup[id]][i]]) {
							g_MaxComboHumanMap = g_Combo[g_GroupId[g_InGroup[id]][i]];

							clientPrintColor(g_GroupId[g_InGroup[id]][i], _, "Conseguiste el combo máximo humano (!gx%d!y) del mapa actual (!g%s!y)", g_Combo[g_GroupId[g_InGroup[id]][i]], g_CurrentMap);

							formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_combos (acc_id, name, combo_max, combo_timestamp, combo_type, mapname) VALUES ('%d', ^"%s^", '%d', '%d', '0', ^"%s^");", g_AccountId[g_GroupId[g_InGroup[id]][i]], g_PlayerName[g_GroupId[g_InGroup[id]][i]], g_MaxComboHumanMap, get_arg_systime(), g_CurrentMap);
							SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
						}

						if(g_Combo[g_GroupId[g_InGroup[id]][i]] > g_Stats[g_GroupId[g_InGroup[id]][i]][STAT_COMBO_MAX] && !g_SpecialMode[g_GroupId[g_InGroup[id]][i]]) {
							clientPrintColor(g_GroupId[g_InGroup[id]][i], _, "Has superado tu viejo mayor combo de !gx%d!y por el recién hecho de !gx%d!y", g_Stats[g_GroupId[g_InGroup[id]][i]][STAT_COMBO_MAX], g_Combo[g_GroupId[g_InGroup[id]][i]]);
							g_Stats[g_GroupId[g_InGroup[id]][i]][STAT_COMBO_MAX] = g_Combo[g_GroupId[g_InGroup[id]][i]];
						}

						g_Combo[g_GroupId[g_InGroup[id]][i]] = 0;
					}
				}
			}

			g_HLTime_GroupCombo[g_InGroup[id]] = (halflife_time() + 999999.9);
		} else {
			g_ComboTime[id] = (halflife_time() + 9999999.0);

			if(g_Combo[id]) {
				static iReward;

				if(reward) {
					iReward = reward;
				} else {
					iReward = (g_Combo[id] * humanComboReward(id));
				}
				
				if(iReward > 0) {
					addXP(id, iReward);

					static sCombo[16];
					static sReward[16];
					static sDamageTotal[32];
					static sDamageTotalOutPut[32];

					addDot(g_Combo[id], sCombo, charsmax(sCombo));
					addDot(iReward, sReward, charsmax(sReward));

					formatex(sDamageTotal, charsmax(sDamageTotal), "%0.0f", g_ComboDamage[id]);
					addDotSpecial(sDamageTotal, sDamageTotalOutPut, charsmax(sDamageTotalOutPut));

					set_hudmessage(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][2], -1.0, g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], 1.0, 5.0, 0.1, 3.0, -1);
					ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nGanaste %s de XP^nDaño hecho: %s", __COMBO_HUMAN[g_ComboReward[id]][comboMessage], sReward, sDamageTotalOutPut);

					clientPrintColor(id, _, "Tu combo humano ha finalizado y has ganado !g%s XP!y", sReward);

					if(g_Hab[id][HAB_L_XP_MULT_IN_COMBO]) {
						giveExtraForHab(id, iReward, 0);
					}

					playSound(id, __COMBO_HUMAN[g_ComboReward[id]][comboSound]);

					if(g_Combo[id] >= 1000) {
						setAchievement(id, COMBO_x1000);

						if(g_Combo[id] >= 5000) {
							setAchievement(id, COMBO_x5000);

							if(g_Combo[id] >= 25000) {
								setAchievement(id, COMBO_x25000);

								if(g_Combo[id] >= 75000) {
									setAchievement(id, COMBO_x75000);

									if(g_Combo[id] >= 150000) {
										setAchievement(id, COMBO_x150000);

										if(g_Combo[id] >= 500000) {
											setAchievement(id, COMBO_x500000);

											if(g_Combo[id] >= 2500000) {
												setAchievement(id, COMBO_x2500000);

												if(g_Combo[id] >= 10000000) {
													setAchievement(id, COMBO_x10000000);
												}
											}
										}
									}
								}
							}
						}
					}
				}

				if(g_Combo[id] > g_MaxComboHumanMap && !g_SpecialMode[id]) {
					g_MaxComboHumanMap = g_Combo[id];

					clientPrintColor(id, _, "Conseguiste el combo máximo humano (!gx%d!y) del mapa actual (!g%s!y)", g_Combo[id], g_CurrentMap);

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_combos (acc_id, name, combo_max, combo_timestamp, combo_type, mapname) VALUES ('%d', ^"%s^", '%d', '%d', '0', ^"%s^");", g_AccountId[id], g_PlayerName[id], g_MaxComboHumanMap, get_arg_systime(), g_CurrentMap);
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
				}

				if(g_Combo[id] > g_Stats[id][STAT_COMBO_MAX] && !g_SpecialMode[id]) {
					clientPrintColor(id, _, "Has superado tu viejo mayor combo de !gx%d!y por el recién hecho de !gx%d!y", g_Stats[id][STAT_COMBO_MAX], g_Combo[id]);
					g_Stats[id][STAT_COMBO_MAX] = g_Combo[id];
				}
			}

			g_Combo[id] = 0;
			g_ComboDamage[id] = 0.0;
			g_ComboDamageBullet[id] = 0.0;
			g_ComboReward[id] = 0;
		}
	}
}

public giveExtraForHab(const id, const reward, const is_group) {
	if(!g_Hab[id][HAB_L_XP_MULT_IN_COMBO]) {
		return;
	}

	new Float:flReward = (float(reward) / DIV_DAMAGE);
	new Float:flRewardTotal = 0.0;
	new iReward = 0;
	new sReward[32];

	if(is_group) {
		new Float:flRewardGroup = ((50.0 * flReward) / 100.0);

		if(flRewardGroup > 0.0) {
			flRewardTotal = (((float(g_Hab[id][HAB_L_XP_MULT_IN_COMBO]) * float(__HABS[HAB_L_XP_MULT_IN_COMBO][habValue])) * flRewardGroup) / 100.0);
		} else {
			flRewardTotal = 0.0;
		}
	} else {
		flRewardTotal = (((float(g_Hab[id][HAB_L_XP_MULT_IN_COMBO]) * float(__HABS[HAB_L_XP_MULT_IN_COMBO][habValue])) * flReward) / 100.0);
	}

	iReward = (floatround(flRewardTotal * DIV_DAMAGE));

	if(iReward < 0 || iReward > MAX_XP) {
		iReward = MAX_XP;
	}

	addXP(id, iReward);

	addDot(iReward, sReward, charsmax(sReward));
	clientPrintColor(id, _, "Has recibido !g%s de XP!y extra por la habilidad !tDOBLE GANANCIA!y", sReward);
}

public showCurrentComboZombie(const id) {
	static Float:flComboTime;
	flComboTime = 10.0;

	if(g_Hab[id][HAB_E_DURATION_COMBO]) {
		flComboTime += ((float(__HABS[HAB_E_DURATION_COMBO][habValue]) / 2.0) * float(g_Hab[id][HAB_E_DURATION_COMBO]));
	}

	g_ComboTime[id] = (halflife_time() + flComboTime);

	while(g_ComboZombieReward[id] < charsmax(__COMBO_ZOMBIE)) {
		if(g_ComboZombie[id] >= __COMBO_ZOMBIE[g_ComboZombieReward[id]][comboNeed] && g_ComboZombie[id] < __COMBO_ZOMBIE[(g_ComboZombieReward[id] + 1)][comboNeed]) {
			break;
		}

		++g_ComboZombieReward[id];
	}

	g_ComboZombieReward[id] = clamp(g_ComboZombieReward[id], 0, charsmax(__COMBO_ZOMBIE));

	static sReward[16];
	addDot(rewardComboZombie(id), sReward, charsmax(sReward));

	set_hudmessage(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][2], -1.0, g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], 0.0, 8.0, 0.0, 0.0, -1);
	ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nInfecciones x%d | +%s XP", __COMBO_ZOMBIE[g_ComboZombieReward[id]][comboMessage], g_ComboZombie[id], sReward);
}

public rewardComboZombie(const id) {
	new Float:flCombo = (float(g_ComboZombie[id]) * 50.0);
	new Float:flConversion = float(xpThisLevel(id, g_Level[id])) - float(xpThisLevelRest1(id, g_Level[id]));
	new Float:flReward = ((flConversion * flCombo) / 100.0);

	return (floatround(flReward) * g_ComboZombie[id]);
}

public finishComboZombie(const id) {
	if(!g_ComboZombieEnabled[id]) {
		return;
	}

	g_ComboTime[id] = halflife_time() + 9999999.0;

	if(g_ComboZombie[id]) {
		new iReward = rewardComboZombie(id);
		
		if(iReward) {
			addXP(id, iReward);
			
			new sReward[16];
			addDot(iReward, sReward, charsmax(sReward));
			
			set_hudmessage(g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][0], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][1], g_UserOptions_Color[id][COLOR_TYPE_HUD_COMBO][2], -1.0, g_UserOptions_Hud[id][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[id][HUD_TYPE_COMBO], 1.0, 5.0, 0.1, 3.0, -1);
			ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nGanaste %s de XP^nInfecciones hechas: %d", __COMBO_ZOMBIE[g_ComboZombieReward[id]][comboMessage], sReward, g_ComboZombie[id]);

			clientPrintColor(id, _, "Tu combo zombie ha finalizado y has ganado !g%s XP!y", sReward);

			if(g_Hab[id][HAB_L_XP_MULT_IN_COMBO]) {
				giveExtraForHab(id, iReward, 0);
			}

			playSound(id, __COMBO_ZOMBIE[g_ComboZombieReward[id]][comboSound]);

			switch(g_ComboZombie[id]) {
				case 2: {
					setAchievement(id, COMBO_x2_ZOMBIE);
				} case 5: {
					setAchievement(id, COMBO_x5_ZOMBIE);
				} case 8: {
					setAchievement(id, COMBO_x8_ZOMBIE);
				} case 11: {
					setAchievement(id, COMBO_x11_ZOMBIE);
				} case 14: {
					setAchievement(id, COMBO_x14_ZOMBIE);
				} case 17: {
					setAchievement(id, COMBO_x17_ZOMBIE);
				} case 20: {
					setAchievement(id, COMBO_x20_ZOMBIE);
				} case 24: {
					setAchievement(id, COMBO_x24_ZOMBIE);
				}
			}

			if(g_ComboZombie[id] > g_MaxComboZombieMap && !g_SpecialMode[id]) {
				g_MaxComboZombieMap = g_ComboZombie[id];

				clientPrintColor(id, _, "Conseguiste el combo máximo zombie (!gx%d!y) del mapa actual (!g%s!y)", g_ComboZombie[id], g_CurrentMap);

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_combos (acc_id, name, combo_max, combo_timestamp, combo_type, mapname) VALUES ('%d', ^"%s^", '%d', '%d', '1', ^"%s^");", g_AccountId[id], g_PlayerName[id], g_MaxComboZombieMap, get_arg_systime(), g_CurrentMap);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
			}
		}
	}
	
	g_ComboZombie[id] = 0;
	g_ComboZombieReward[id] = 0;
}

public playSound(const id, const sound[]) {
	if(containi(sound[strlen(sound) - 4], ".mp3") != -1) {
		client_cmd(id, "mp3 play ^"%s^"", sound);
	} else {
		client_cmd(id, "spk ^"%s^"", sound);
	}
}

emitSound(const id, const channel, const sample[], const Float:vol=1.0, const Float:attn=ATTN_NORM, const flags=0, const pitch=PITCH_NORM) {
	emit_sound(id, channel, sample, vol, attn, flags, pitch);
}

public getUserTypeMod(const id) {
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

public calculatePageIn(const id, const value) {
	new iValue = value;
	new iTotal = 1;

	while(iValue >= 7) {
		++iTotal;
		iValue -= 7;
	}

	return iTotal;
}

public precachePlayerModel(const model[]) {
	new sBuffer[128];
	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", model, model);
	precache_model(sBuffer);

	copy(sBuffer[(strlen(sBuffer) - 4)], (charsmax(sBuffer) - (strlen(sBuffer) - 4)), "T.mdl");

	if(file_exists(sBuffer)) {
		precache_model(sBuffer);
	}
}

public checkRound(const leaving_id) {
	if(g_EndRound || task_exists(TASK_START_MODE)) {
		return;
	}

	new iUsersAlive = getUsersAlive();
	new iId;

	switch(g_Mode) {
		case MODE_SYNAPSIS: {
			if(g_SpecialMode[leaving_id] == MODE_NEMESIS && getHumans() > 1) {
				while((iId = getRandomAlive(random_num(1, iUsersAlive))) == leaving_id || g_Zombie[iId]) {}

				clientPrintColor(0, _, "El nemesis se ha ido, !g%s!y es el nuevo nemesis", g_PlayerName[iId]);
				zombieMe(iId, .nemesis=1);

				if(!g_Bazooka[leaving_id]) {
					g_Bazooka[iId] = 0;

					strip_user_weapons(iId);
					give_item(iId, "weapon_knife");
				}
				
				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			} else if(!g_Zombie[leaving_id] && getHumans() == 1) {
				return;
			}
		} case MODE_MEGA_ARMAGEDDON: {
			if(getZombies() == 1) {
				if(g_SpecialMode[leaving_id] == MODE_NEMESIS) {
					endModeMegaArmageddon(1);
				} else if(g_LastZombie[leaving_id]) {
					checkModeMegaArmageddonTwo(0);
				}
			} else if(getHumans() == 1) {
				if(g_SpecialMode[leaving_id] == MODE_SURVIVOR) {
					endModeMegaArmageddon(0);
				} else if(g_LastHuman[leaving_id]) {
					checkModeMegaArmageddonTwo(1);
				}
			}

			return;
		} case MODE_DUEL_FINAL: {
			if(getHumans() == 2) {
				if(g_ModeDuelFinal == DF_QUARTER || g_ModeDuelFinal == DF_SEMIFINAL || g_ModeDuelFinal == DF_FINAL) {
					new i;
					for(i = 1; i <= MaxClients; ++i) {
						if(!g_IsAlive[i]) {
							continue;
						}

						user_kill(i, 1);
						break;
					}
				}

				remove_task(TASK_MODE_DUEL_FINAL);
				set_task(2.0, "task__ModeDuelFinal", TASK_MODE_DUEL_FINAL);
			}

			return;
		} case MODE_TRIBAL: {
			if(getZombies() == 1) {
				tribalModeWin();
			}
		} case MODE_SNIPER: {
			if(g_SpecialMode[leaving_id] == MODE_SNIPER && getHumans() == 1) {
				return;
			} else if(g_Zombie[leaving_id] && getZombies() == 1) {
				new i;
				new j = 0;
				new k = 0;
				new iSnipers[4] = {0, 0, 0, 0};

				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsAlive[i] || g_SpecialMode[i] != MODE_SNIPER) {
						continue;
					}

					iSnipers[j] = i;

					g_Points[i][P_HUMAN] += g_PointsMult[i];
					clientPrintColor(i, _, "Ganaste !g%d pH!y por ganar el modo !tSNIPER!y", g_PointsMult[i]);

					++j;
				}

				g_PointsMult[0] = 0;
				clientPrintColor(0, _, "Los !tSNIPER!y ganaron !g%d !y/!g %d !y/!g %d !y/!g %d pH!y por sobrevivir la ronda", g_PointsMult[iSnipers[0]], g_PointsMult[iSnipers[1]], g_PointsMult[iSnipers[2]], g_PointsMult[iSnipers[3]]);

				k = 0;
				for(i = 0; i < j; ++i) {
					if(g_IsAlive[iSnipers[i]]) {
						setAchievement(iSnipers[i], L_FRANCOTIRADOR);
						++k;
						
						if(!g_Achievement_SniperNoDamage[iSnipers[i]]) {
							setAchievement(iSnipers[i], NO_TENGO_BALAS);
						}
					}

					g_Achievement_SniperNoDamage[iSnipers[i]] = 0;
				}
			
				switch(k) {
					case 1: {
						for(i = 0; i < j; ++i) {
							if(g_IsAlive[iSnipers[i]]) {
								setAchievement(iSnipers[i], EN_MEMORIA_A_ELLOS);
								break;
							}
						}
					} case 2: {
						new iAwp = 0;
						new iScout = 0;
						
						for(i = 0; i < j; ++i) {
							if(user_has_weapon(iSnipers[i], CSW_AWP)) {
								++iAwp;
							}
							
							if(user_has_weapon(iSnipers[i], CSW_SCOUT)) {
								++iScout;
							}
						}
						
						if(iAwp == 2) {
							setAchievement(iSnipers[0], SOBREVIVEN_LOS_DUROS);
							setAchievement(iSnipers[1], SOBREVIVEN_LOS_DUROS);
						} else if(iScout == 2) {
							setAchievement(iSnipers[0], NO_SOLO_LA_GANAN_LOS_DUROS);
							setAchievement(iSnipers[1], NO_SOLO_LA_GANAN_LOS_DUROS);
						}
					} case 4: {
						setAchievement(iSnipers[0], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[1], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[2], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[3], EL_MEJOR_EQUIPO);
					}
				}

				return;
			}
		}
	}

	if(iUsersAlive < 3) {
		if(g_Mode == MODE_INFECTION || g_Mode == MODE_PLAGUE || g_Mode == MODE_ARMAGEDDON) {
			return;
		}

		g_EndRound_Forced = 1;
		return;
	}

	if(g_Zombie[leaving_id] && getZombies() == 1) {
		if(getHumans() == 1 && getCTs() == 1) {
			return;
		}

		while((iId = getRandomAlive(random_num(1, iUsersAlive))) == leaving_id) {}

		switch(g_SpecialMode[leaving_id]) {
			case MODE_NEMESIS: {
				clientPrintColor(0, iId, "El nemesis se ha desconectado, !t%s!y es el nuevo nemesis", g_PlayerName[iId]);
				zombieMe(iId, .nemesis=1);

				if(!g_Bazooka[leaving_id]) {
					g_Bazooka[iId] = 0;

					strip_user_weapons(iId);
					give_item(iId, "weapon_knife");
				}

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} case MODE_CABEZON: {
				clientPrintColor(0, _, "El cabezón se ha desconectado, !t%s!y es el nuevo cabezón", g_PlayerName[iId]);
				zombieMe(iId, .cabezon=1);

				if(g_ModeCabezon_Power[leaving_id]) {
					g_ModeCabezon_Power[iId] = g_ModeCabezon_Power[leaving_id];
				}

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} case MODE_ANNIHILATOR: {
				clientPrintColor(0, iId, "El aniquilador se ha desconectado, !t%s!y es el nuevo aniquilador", g_PlayerName[iId]);
				zombieMe(iId, .annihilator=1);

				if(g_Bazooka[leaving_id]) {
					g_Bazooka[iId] = g_Bazooka[leaving_id];
					g_Bazooka_LastUse[iId] = 0;

					give_item(iId, "weapon_ak47");
					cs_set_user_bpammo(iId, CSW_AK47, 0);
					set_pdata_int(findEntByOwner(iId, "weapon_ak47"), OFFSET_CLIPAMMO, 0, OFFSET_LINUX_WEAPONS);
				}

				static iWeaponEntLeavingId;
				static iAmmo;
				static iClip;
				
				iWeaponEntLeavingId = find_ent_by_owner(-1, "weapon_mac10", leaving_id);
				iAmmo = get_pdata_int(leaving_id, __AMMO_OFFSET[CSW_MAC10], OFFSET_LINUX);
				iClip = get_pdata_int(iWeaponEntLeavingId, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
				
				if(iAmmo || iClip) {
					give_item(iId, "weapon_mac10");
					
					static iWeaponEntId;
					iWeaponEntId = find_ent_by_owner(-1, "weapon_mac10", iId);
					
					set_pdata_int(iId, __AMMO_OFFSET[CSW_MAC10], iAmmo, OFFSET_LINUX);
					set_pdata_int(iWeaponEntId, OFFSET_CLIPAMMO, iClip, OFFSET_LINUX_WEAPONS);
				}

				g_CurrentWeapon[iId] = CSW_KNIFE;
				engclient_cmd(iId, "weapon_knife");

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} case MODE_FLESHPOUND: {
				clientPrintColor(0, iId, "El fleshpound se ha desconectado, !t%s!y es el nuevo fleshpound", g_PlayerName[iId]);
				zombieMe(iId, .fleshpound=1);

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} case MODE_GRUNT: {
				clientPrintColor(0, iId, "El grunt se ha desconectado, !t%s!y es el nuevo grunt", g_PlayerName[iId]);
				zombieMe(iId, .grunt=1);

				g_ModeGrunt_Reward[iId] = g_ModeGrunt_Reward[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} default: {
				clientPrintColor(0, iId, "El último zombie se ha desconectado, !t%s!y es el nuevo zombie", g_PlayerName[iId]);
				zombieMe(iId);
			}
		}
	} else if(!g_Zombie[leaving_id] && getHumans() == 1) {
		if(getZombies() == 1 && getTs() == 1) {
			return;
		}

		while((iId = getRandomAlive(random_num(1, iUsersAlive))) == leaving_id) {}

		switch(g_SpecialMode[leaving_id]) {
			case MODE_SURVIVOR: {
				clientPrintColor(0, iId, "El survivor se ha desconectado, !t%s!y es el nuevo survivor", g_PlayerName[iId]);
				humanMe(iId, .survivor=1);

				if(!g_Hab[iId][HAB_S_S_EXTRA_BOMB] && g_KillBomb[leaving_id]) {
					give_item(iId, "weapon_hegrenade");
					g_KillBomb[iId] = 1;
				} else if(g_KillBomb[leaving_id]) {
					give_item(iId, "weapon_hegrenade");
					cs_set_user_bpammo(iId, CSW_HEGRENADE, 2);
					g_KillBomb[iId] = 2;
				} else {
					g_KillBomb[iId] = 0;
				}

				g_SurvImmunity[iId] = g_SurvImmunity[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} case MODE_WESKER: {
				clientPrintColor(0, iId, "El wesker se ha desconectado, !t%s!y es el nuevo wesker", g_PlayerName[iId]);
				humanMe(iId, .wesker=1);

				g_WeskLaser[iId] = g_WeskLaser[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} case MODE_LEATHERFACE: {
				clientPrintColor(0, iId, "El LeatherFace se ha desconectado, !t%s!y es el nuevo LeatherFace", g_PlayerName[iId]);
				humanMe(iId, .leatherface=1);

				g_Leatherface_Teleport[iId] = g_Leatherface_Teleport[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} default: {
				clientPrintColor(0, iId, "El último humano se ha desconectado, !t%s!y es el nuevo humano", g_PlayerName[iId]);
				humanMe(iId);
			}
		}
	}
}

public arrayToString(const array[], const size, output[], const output_len, const end) {
	new iLen;
	new i;

	do {
		iLen += formatex(output[iLen], (output_len - iLen), "%d ", array[i]);
	} while((++i < size) && (iLen < output_len));

	if(i < size) {
		return 0;
	}

	if(end) {
		output[(iLen - 1)] = '^0';
	}

	return iLen;
}

public stringToArray(const string[], array_out[], const array_size) {
	new sTemp[12];
	new iLen;
	new j;
	new k;
	new c;

	while(string[iLen]) {
		if(string[iLen] == ' ') {
			array_out[j++] = str_to_num(sTemp);

			for(c = 0; c < k; c++) {
				sTemp[c] = 0;
			}

			k = 0;
        }

		if(j >= array_size) {
			return iLen;
		}

		sTemp[k++] = string[iLen++];
	}

	array_out[j++] = str_to_num(sTemp);

	while(j < array_size) {
		array_out[j++] = 0;
	}

	return iLen;
}

public buyPrimaryWeapon(const id, const selection) {
	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_GRUNT) {
		return;
	}

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	g_WeaponPrimary_Current[id] = selection;

	give_item(id, __PRIMARY_WEAPONS[selection][weaponEnt]);
	cs_set_user_bpammo(id, __PRIMARY_WEAPONS[selection][weaponCSW], __MAX_BPAMMO[__PRIMARY_WEAPONS[selection][weaponCSW]]);
}

public buySecondaryWeapon(const id, const selection) {
	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_GRUNT) {
		return;
	}

	g_WeaponSecondary_Current[id] = selection;

	give_item(id, __SECONDARY_WEAPONS[selection][weaponEnt]);
	cs_set_user_bpammo(id, __SECONDARY_WEAPONS[selection][weaponCSW], __MAX_BPAMMO[__SECONDARY_WEAPONS[selection][weaponCSW]]);
}

public buyCuaternaryWeapon(const id, const selection) {
	if(g_Mode == MODE_SYNAPSIS || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_CABEZON || g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_GRUNT) {
		return;
	}

	if(__GRENADES[selection][grenadeAmountHe]) {
		give_item(id, "weapon_hegrenade");
		cs_set_user_bpammo(id, CSW_HEGRENADE, __GRENADES[selection][grenadeAmountHe]);

		if(__GRENADES[selection][grenadeIsDrug]) {
			g_DrugBomb[id] = __GRENADES[selection][grenadeAmountHe];
		}
	}

	if(__GRENADES[selection][grenadeAmountFb]) {
		give_item(id, "weapon_flashbang");
		cs_set_user_bpammo(id, CSW_FLASHBANG, __GRENADES[selection][grenadeAmountFb]);

		if(__GRENADES[selection][grenadeIsSupernova]) {
			g_SupernovaBomb[id] = __GRENADES[selection][grenadeAmountFb];
		}
	}

	if(__GRENADES[selection][grenadeAmountSg]) {
		give_item(id, "weapon_smokegrenade");
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, __GRENADES[selection][grenadeAmountSg]);

		if(__GRENADES[selection][grenadeIsBubble]) {
			g_BubbleBomb[id] = __GRENADES[selection][grenadeAmountSg];
		}
	}
}

public getExtraItemCost(const id, const extra_item) {
	new iCost = __EXTRA_ITEMS[extra_item][extraItemCost];

	if(g_ArtifactsEquiped[id][ARTIFACT_RING_EXTRA_ITEM_COST]) {
		new iPercent = 0;
		new iTotal = 0;

		switch(g_Artifact[id][ARTIFACT_RING_EXTRA_ITEM_COST]) {
			case 1: {
				iPercent = 5;
			} case 2: {
				iPercent = 10;
			} case 3: {
				iPercent = 15;
			} case 4: {
				iPercent = 20;
			}
		}

		iTotal = (iPercent * iCost) / 100;
		iCost -= iTotal;
	}

	if(extra_item == EXTRA_ITEM_UNLIMITED_CLIP) {
		if(g_HabRotate[id][HAB_ROTATE_INFINITAMENTE_INFINITO]) {
			iCost = (iCost - ((iCost * 50) / 100));
		}
	}

	if(extra_item == EXTRA_ITEM_PRESICION_PERFECT) {
		if(g_HabRotate[id][HAB_ROTATE_PRECISAMENTE_PERFECTO]) {
			iCost = (iCost - ((iCost * 50) / 100));
		}
	}

	if(g_HabRotate[id][HAB_ROTATE_PRECIOS_CUIDADOS]) {
		iCost = (iCost - ((iCost * 15) / 100));
	}

	if(__HATS[g_HatId[id]][hatUpgrade8]) {
		iCost = (iCost - ((iCost * __HATS[g_HatId[id]][hatUpgrade8]) / 100));
	}

	if(g_LastHuman[id] && g_LastHumanOk[id] && g_LastHumanOk_NoRespawn) {
		iCost = (iCost - ((iCost * 10) / 100));
	}

	return iCost;
}

public buyExtraItem(const id, const extra_item, const ignore_cost) {
	new iCost = getExtraItemCost(id, extra_item);
	new iValue;

	if(!ignore_cost) {
		if(g_Zombie[id] != __EXTRA_ITEMS[extra_item][extraItemTeam]) {
			showMenu__ExtraItems(id);
			return;
		}

		if(g_Mode == MODE_INFECTION && getHumans() == 1) {
			clientPrintColor(id, _, "No puedes utilizar Items Extras cuando hay un último humano en modo !tINFECCIÓN!y");

			showMenu__ExtraItems(id);
			return;
		}

		if((g_AmmoPacks[id] - iCost) < 0) {
			clientPrintColor(id, _, "No tienes suficientes AmmoPacks");

			showMenu__ExtraItems(id);
			return;
		}

		if(__EXTRA_ITEMS[extra_item][extraItemMultCount] && g_ExtraItem_Mult[id][extra_item] >= __EXTRA_ITEMS[extra_item][extraItemMultCount]) {
			if((g_Points[id][P_MONEY] - __EXTRA_ITEMS[extra_item][extraItemMult]) < 0) {
				clientPrintColor(id, _, "No tienes suficiente plata");

				showMenu__ExtraItems(id);
				return;
			}
		}
	}

	switch(extra_item) {
		case EXTRA_ITEM_NVISION: {
			if(!ignore_cost) {
				if(g_NVision[id]) {
					clientPrintColor(id, _, "Ya compraste Visión nocturna");

					showMenu__ExtraItems(id);
					return;
				}
			}

			setUserNVision(id, 1);
		} case EXTRA_ITEM_LJ_H, EXTRA_ITEM_LJ_Z: {
			if(!ignore_cost) {
				if(g_LongJump[id]) {
					clientPrintColor(id, _, "Ya compraste Long Jump");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Long Jump");

					showMenu__ExtraItems(id);
					return;
				}
			}

			set_pdata_int(id, OFFSET_LONG_JUMP, 1, OFFSET_LINUX);
			
			g_LongJump[id] = 1;
			g_InJump[id] = 0;
		} case EXTRA_ITEM_INVISIBILITY: {
			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_Invisibility, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_Invisibility[id]) {
					clientPrintColor(id, _, "Ya compraste Invisibilidad");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Invisibilidad");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_Invisibility, g_PlayerName[id], (iValue + 1));
			}

			g_Invisibility[id] = 1;

			set_user_rendering(id);

			entity_set_int(id, EV_INT_rendermode, kRenderTransAlpha);
			entity_set_float(id, EV_FL_renderamt, 25.0);

			hidePlayerHat(id);
		} case EXTRA_ITEM_UNLIMITED_CLIP: {
			if(!ignore_cost) {
				if(g_UnlimitedClip[id]) {
					clientPrintColor(id, _, "Ya compraste Balas Infinitas");

					showMenu__ExtraItems(id);
					return;
				}
			}

			g_UnlimitedClip[id] = 1;
		} case EXTRA_ITEM_PRESICION_PERFECT: {
			if(!ignore_cost) {
				if(g_PrecisionPerfect[id]) {
					clientPrintColor(id, _, "Ya compraste Precisión Perfecta");

					showMenu__ExtraItems(id);
					return;
				}
			}

			g_PrecisionPerfect[id] = 1;
		} case EXTRA_ITEM_KILL_BOMB: {
			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_KillBomb, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Bomba Aniquiladora");

					showMenu__ExtraItems(id);
					return;
				} else if(g_ExtraItem_HumanBombs == 5) {
					clientPrintColor(id, _, "Ya superaron el límite de bombas humanas en este mapa");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_KillBomb, g_PlayerName[id], (iValue + 1));
			}

			++g_KillBomb[id];
			++g_ExtraItem_HumanBombs;

			if(user_has_weapon(id, CSW_HEGRENADE)) {
				cs_set_user_bpammo(id, CSW_HEGRENADE, (cs_get_user_bpammo(id, CSW_HEGRENADE) + 1));
			} else {
				give_item(id, "weapon_hegrenade");
			}
		} case EXTRA_ITEM_PIPE_BOMB: {
			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_PipeBomb, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Bomba Pipe");

					showMenu__ExtraItems(id);
					return;
				} else if(g_ExtraItem_HumanBombs == 5) {
					clientPrintColor(id, _, "Ya superaron el límite de bombas humanas en este mapa");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_PipeBomb, g_PlayerName[id], (iValue + 1));
			}

			++g_PipeBomb[id];
			++g_ExtraItem_HumanBombs;

			if(user_has_weapon(id, CSW_FLASHBANG)) {
				cs_set_user_bpammo(id, CSW_FLASHBANG, (cs_get_user_bpammo(id, CSW_FLASHBANG) + 1));
			} else {
				give_item(id, "weapon_flashbang");
			}
		} case EXTRA_ITEM_ANTIDOTE_BOMB: {
			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_AntidoteBomb, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Bomba Antídoto");

					showMenu__ExtraItems(id);
					return;
				} else if(g_ExtraItem_HumanBombs == 5) {
					clientPrintColor(id, _, "Ya superaron el límite de bombas humanas en este mapa");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_AntidoteBomb, g_PlayerName[id], (iValue + 1));
			}

			++g_AntidoteBomb[id];
			++g_ExtraItem_HumanBombs;

			if(user_has_weapon(id, CSW_SMOKEGRENADE)) {
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, (cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1));
			} else {
				give_item(id, "weapon_smokegrenade");
			}
		} case EXTRA_ITEM_ANTIDOTE: {
			new iSysTime = get_arg_systime();

			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_Antidote, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_ExtraItem_AlreadyBuy[id][EXTRA_ITEM_ANTIDOTE] == 1) {
					clientPrintColor(id, _, "Debes esperar a la próxima ronda para comprar Antídoto");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Antídoto");

					showMenu__ExtraItems(id);
					return;
				} else if(getHumans() > getZombies()) {
					clientPrintColor(id, _, "Deben haber más de la mitad de zombies para poder comprar Antídoto");

					showMenu__ExtraItems(id);
					return;
				} else if(g_ModeInfection_Systime > iSysTime) {
					new iRest = (g_ModeInfection_Systime - iSysTime);

					clientPrintColor(id, _, "Debes esperar !g%s!y para poder comprar Antídoto", getCooldDownTime(iRest));

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_Antidote, g_PlayerName[id], (iValue + 1));
			}

			humanMe(id);
		} case EXTRA_ITEM_ZOMBIE_MADNESS: {
			new iSysTime = get_arg_systime();

			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_ZombieMadness, g_PlayerName[id], iValue);
				
				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_ExtraItem_AlreadyBuy[id][EXTRA_ITEM_ZOMBIE_MADNESS] == 2) {
					clientPrintColor(id, _, "Debes esperar a la próxima ronda para comprar Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Frozen[id]) {
					clientPrintColor(id, _, "No puedes comprar Furia Zombie mientras estés congelado");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Antídoto");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Immunity[id]) {
					clientPrintColor(id, _, "Ya compraste Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Madness_LastUse[id] > iSysTime) {
					new iRest = (g_Madness_LastUse[id] - iSysTime);

					clientPrintColor(id, _, "Debes esperar !g%s!y para volver a comprar Furia Zombie", getCooldDownTime(iRest));

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_ZombieMadness, g_PlayerName[id], (iValue + 1));

				++g_Achievement_FuryConsecutive[id];

				if(g_Achievement_FuryConsecutive[id] == 3) {
					g_Achievement_FuryConsecutive[id] = 1;
				}
			}

			new Float:flDuration = 4.0;

			if(g_Hab[id][HAB_E_DURATION_MADNESS]) {
				flDuration += ((float(__HABS[HAB_E_DURATION_MADNESS][habValue]) / 2.0) * float(g_Hab[id][HAB_E_DURATION_MADNESS]));
			}

			startZombieMadness(id, flDuration, 0, random_num(0, 1));
		} case EXTRA_ITEM_INFECTION_BOMB: {
			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_InfectionBomb, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_ExtraItem_AlreadyBuy[id][EXTRA_ITEM_INFECTION_BOMB] == 1) {
					clientPrintColor(id, _, "Debes esperar a la próxima ronda para comprar Bomba de Infección");

					showMenu__ExtraItems(id);
					return;
				} else if(g_ExtraItem_InfectionBombUsed) {
					clientPrintColor(id, _, "Debes esperar al menos 3 rondas para volver a comprar Bomba de Infección");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Bomba de Infección");

					showMenu__ExtraItems(id);
					return;
				} else if(getZombies() > getHumans()) {
					clientPrintColor(id, _, "Deben haber más de la mitad de humanos para poder comprar Bomba de Infección");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_InfectionBomb, g_PlayerName[id], (iValue + 1));
			}

			g_ExtraItem_InfectionBombUsed = 1;
			g_InfectionBomb[id] = 1;

			if(user_has_weapon(id, CSW_HEGRENADE)) {
				cs_set_user_bpammo(id, CSW_HEGRENADE, (cs_get_user_bpammo(id, CSW_HEGRENADE) + 1));
			} else {
				give_item(id, "weapon_hegrenade");
			}
		} case EXTRA_ITEM_REDUCE_DAMAGE: {
			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_ReduceDamage, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_ReduceDamage[id]) {
					clientPrintColor(id, _, "Ya compraste Reducción de Daño");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Immunity[id]) {
					clientPrintColor(id, _, "No puedes usar !gREDUCCIÓN DE DAÑO!y mientras estás bajo los efectos de la !gFURIA ZOMBIE!y");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Reducción de Daño");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_ReduceDamage, g_PlayerName[id], (iValue + 1));
			}

			g_ReduceDamage[id] = 1;

			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 100);
		} case EXTRA_ITEM_PETRIFICATION: {
			if(!ignore_cost) {
				TrieGetCell(g_tExtraItem_Petrification, g_PlayerName[id], iValue);

				if(iValue < 0) {
					iValue = 0;
				}

				if(iValue == __EXTRA_ITEMS[extra_item][extraItemLimitUser]) {
					clientPrintColor(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", __EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				} else if(g_Petrification[id]) {
					clientPrintColor(id, _, "Estás en modo petrificado, espera a que termine de tomar efecto");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Mode != MODE_INFECTION) {
					clientPrintColor(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Petrificación");

					showMenu__ExtraItems(id);
					return;
				} else if(g_Frozen[id]) {
					clientPrintColor(id, _, "No puedes comprar Petrificación estando congelado");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_Petrification, g_PlayerName[id], (iValue + 1));
			}

			g_Immunity[id] = 1;
			g_Frozen[id] = 1;
			g_BurningDuration[id] = 0;
			g_Petrification[id] = 1;
			g_DrugBombCount[id] = 0;
			g_DrugBombMove[id] = 0;

			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

			rg_give_item(id, "weapon_knife");

			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 100);

			remove_task(id + TASK_BURNING_FLAME);
			remove_task(id + TASK_DRUG);
			remove_task(id + TASK_HEALTH_REGENERATION);
			remove_task(id + TASK_HEALTH_IMMUNITY);

			set_task(0.5, "task__HealthRegeneration", id + TASK_HEALTH_REGENERATION, .flags="a", .repeat=10);
			set_task(5.0, "task__RemoveHealthImmunity", id + TASK_HEALTH_IMMUNITY);
		}
	}

	if(!ignore_cost) {
		g_AmmoPacks[id] -= iCost;

		if(__EXTRA_ITEMS[extra_item][extraItemMultCount] && g_ExtraItem_Mult[id][extra_item] >= __EXTRA_ITEMS[extra_item][extraItemMultCount]) {
			g_Points[id][P_MONEY] -= __EXTRA_ITEMS[extra_item][extraItemMult];
		}

		++g_ExtraItem_Count[id][extra_item];
		++g_ExtraItem_AlreadyBuy[id][extra_item];
		++g_ExtraItem_Mult[id][extra_item];

		switch(extra_item) {
			case EXTRA_ITEM_NVISION: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, VISION_NOCTURNA_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, VISION_NOCTURNA_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, VISION_NOCTURNA_x100);
						}
					}
				}
			} case EXTRA_ITEM_LJ_H, EXTRA_ITEM_LJ_Z: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, LONG_JUMP_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, LONG_JUMP_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, LONG_JUMP_x100);
						}
					}
				}
			} case EXTRA_ITEM_INVISIBILITY: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, INVISIBILIDAD_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, INVISIBILIDAD_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, INVISIBILIDAD_x100);
						}
					}
				}
			} case EXTRA_ITEM_UNLIMITED_CLIP: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, BALAS_INFINITAS_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, BALAS_INFINITAS_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, BALAS_INFINITAS_x100);
						}
					}
				}
			} case EXTRA_ITEM_PRESICION_PERFECT: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, PRESICION_PERFECTA_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, PRESICION_PERFECTA_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, PRESICION_PERFECTA_x100);
						}
					}
				}
			} case EXTRA_ITEM_KILL_BOMB: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, BOMBA_DE_ANIQUILACION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, BOMBA_DE_ANIQUILACION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, BOMBA_DE_ANIQUILACION_x100);
						}
					}
				}
			} case EXTRA_ITEM_PIPE_BOMB: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, BOMBA_PIPE_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, BOMBA_PIPE_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, BOMBA_PIPE_x100);
						}
					}
				}
			} case EXTRA_ITEM_ANTIDOTE_BOMB: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, BOMBA_ANTIDOTO_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, BOMBA_ANTIDOTO_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, BOMBA_ANTIDOTO_x100);
						}
					}
				}
			} case EXTRA_ITEM_ANTIDOTE: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, ANTIDOTO_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, ANTIDOTO_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, ANTIDOTO_x100);
						}
					}
				}
			} case EXTRA_ITEM_ZOMBIE_MADNESS: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, FURIA_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, FURIA_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, FURIA_x100);
						}
					}
				}
			} case EXTRA_ITEM_INFECTION_BOMB: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, BOMBA_DE_INFECCION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, BOMBA_DE_INFECCION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, BOMBA_DE_INFECCION_x100);
						}
					}
				}
			} case EXTRA_ITEM_REDUCE_DAMAGE: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, REDUCCION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, REDUCCION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, REDUCCION_x100);
						}
					}
				}
			} case EXTRA_ITEM_PETRIFICATION: {
				if(g_ExtraItem_Count[id][extra_item] >= 10) {
					setAchievement(id, PETRIFICACION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50) {
						setAchievement(id, PETRIFICACION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100) {
							setAchievement(id, PETRIFICACION_x100);
						}
					}
				}
			}
		}

		new iMenor = g_ExtraItem_Count[id][0];
		new i;

		for(i = 1; i < structIdExtraItems; ++i) {
			if(g_ExtraItem_Count[id][i] < iMenor) {
				iMenor = g_ExtraItem_Count[id][i];
			}
		}

		switch(iMenor) {
			case 10: {
				setAchievement(id, ITEMS_EXTRAS_x10);
			} case 50: {
				setAchievement(id, ITEMS_EXTRAS_x50);
			} case 100: {
				setAchievement(id, ITEMS_EXTRAS_x100);
			} case 500: {
				setAchievement(id, ITEMS_EXTRAS_x500);
			} case 1000: {
				setAchievement(id, ITEMS_EXTRAS_x1000);
			} case 5000: {
				setAchievement(id, ITEMS_EXTRAS_x5000);
			}
		}

		g_Hat_Devil[id] = 1;
	}
}

public startZombieMadness(const id, const Float:duration, const ignore_last_use, const sound_agude) {
	if(!g_IsAlive[id]) {
		return;
	}

	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_DRUG);

	if(g_Frozen[id]) {
		remove_task(id + TASK_FREEZE);
		task__RemoveFreeze(id + TASK_FREEZE);
	}

	g_Immunity[id] = 1;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;
	g_Hat_Earth[id] = 0;
	if(!ignore_last_use) {
		g_Madness_LastUse[id] = (get_arg_systime() + 10);
	}
	g_Speed[id] += 30.0;

	rg_give_item(id, "weapon_knife");

	set_user_rendering(id, kRenderFxGlowShell, 150, 0, 0, kRenderNormal, 100);

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

	remove_task(id + TASK_MADNESS);
	set_task(duration, "task__RemoveMadness", id + TASK_MADNESS);

	if(sound_agude) {
		emitSound(id, CHAN_BODY, __SOUND_ZOMBIE_MADNESS, .pitch=200);
	} else {
		emitSound(id, CHAN_BODY, __SOUND_ZOMBIE_MADNESS);
	}
}

public setUserNVision(const id, const value) {
	g_NVision[id] = value;

	remove_task(id + TASK_NVISION);

	if(!g_NVision[id]) {
		return;
	}

	set_task(0.3, "task__SetUserNVision", id + TASK_NVISION, .flags="b");
}

public task__SetUserNVision(const task_id) {
	new iId = (task_id - TASK_NVISION);

	if(!g_IsConnected[iId] || !g_NVision[iId] || !g_UserOptions_NVision[iId]) {
		remove_task(task_id);
		return;
	}

	new vecOrigin[3];
	get_user_origin(iId, vecOrigin);

	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, iId);
	write_byte(TE_DLIGHT);
	write_coord(vecOrigin[0]);
	write_coord(vecOrigin[1]);
	write_coord(vecOrigin[2]);
	if(g_SpecialMode[iId] == MODE_GRUNT) {
		write_byte(10);
	} else {
		write_byte(60);
	}
	if(g_Immunity[iId] && g_Petrification[iId]) {
		write_byte(255);
		write_byte(255);
		write_byte(255);
	} else if(g_Immunity[iId] || (g_Mode == MODE_NEMESIS && !g_SpecialMode[iId]) || g_SpecialMode[iId] == MODE_NEMESIS) {
		write_byte(255);
		write_byte(0);
		write_byte(0);
	} else if(g_SpecialMode[iId] == MODE_GRUNT) {
		write_byte(64);
		write_byte(64);
		write_byte(64);
	} else if(g_SpecialMode[iId] == MODE_ANNIHILATOR) {
		write_byte(255);
		write_byte(255);
		write_byte(0);
	} else {
		write_byte(g_UserOptions_Color[iId][COLOR_TYPE_NVISION][0]);
		write_byte(g_UserOptions_Color[iId][COLOR_TYPE_NVISION][1]);
		write_byte(g_UserOptions_Color[iId][COLOR_TYPE_NVISION][2]);
	}
	write_byte(7);
	write_byte(7);
	message_end();
}

public replaceWeaponModels(const id, const weapon_id) {
	switch(weapon_id) {
		case CSW_KNIFE: {
			if(g_Zombie[id]) {
				switch(g_SpecialMode[id]) {
					case MODE_NEMESIS: {
						entity_set_string(id, EV_SZ_viewmodel, __KNIFE_vMODEL_NEMESIS);
					} case MODE_ANNIHILATOR: {
						entity_set_string(id, EV_SZ_viewmodel, __KNIFE_vMODEL_ANNIHILATOR);
					} case MODE_FLESHPOUND: {
						entity_set_string(id, EV_SZ_viewmodel, __KNIFE_vMODEL_FLESHPOUND);
					} default: {
						if((get_user_flags(id) & ADMIN_RESERVATION)) {
							entity_set_string(id, EV_SZ_viewmodel, __KNIFE_vMODEL_ZOMBIE_VIP);
						} else {
							entity_set_string(id, EV_SZ_viewmodel, __KNIFE_vMODEL_ZOMBIE);
						}
					}
				}

				entity_set_string(id, EV_SZ_weaponmodel, "");
			} else {
				if(g_SpecialMode[id] == MODE_LEATHERFACE) {
					entity_set_string(id, EV_SZ_viewmodel, __KNIFE_vMODEL_LEATHERFACE[0]);
					entity_set_string(id, EV_SZ_weaponmodel, __KNIFE_vMODEL_LEATHERFACE[1]);
				} else {
					if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
						if(g_WeaponModel[id][weapon_id]) {
							entity_set_string(id, EV_SZ_viewmodel, __WEAPON_MODELS[weapon_id][(g_WeaponModel[id][weapon_id] - 1)][weaponModelPath]);
						}
					} else {
						entity_set_string(id, EV_SZ_viewmodel, "models/v_knife.mdl");
						entity_set_string(id, EV_SZ_weaponmodel, "models/p_knife.mdl");
					}
				}
			}
		} case CSW_HEGRENADE: {
			if(g_Zombie[id]) {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_INFECTION[0]);
				entity_set_string(id, EV_SZ_weaponmodel, __GRENADE_MODEL_INFECTION[1]);
			} else {
				if(g_DrugBomb[id]) {
					entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_DRUG[0]);
					entity_set_string(id, EV_SZ_weaponmodel, __GRENADE_MODEL_DRUG[1]);
				} else if(g_KillBomb[id]) {
					entity_set_string(id, EV_SZ_viewmodel, __GRENADE_vMODEL_KILL);
				} else {
					if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
						entity_set_string(id, EV_SZ_viewmodel, __GRENADE_vMODEL_FIRE);
					} else {
						entity_set_string(id, EV_SZ_viewmodel, "models/v_hegrenade.mdl");
					}
				}
			}
		} case CSW_FLASHBANG: {
			if(g_SupernovaBomb[id]) {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_SUPERNOVA[0]);
				entity_set_string(id, EV_SZ_weaponmodel, __GRENADE_MODEL_SUPERNOVA[1]);
			} else if(g_PipeBomb[id]) {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_PIPE[0]);
			} else {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_vMODEL_FROST);
			}
		} case CSW_SMOKEGRENADE: {
			if(g_BubbleBomb[id]) {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_BUBBLE[0]);
				entity_set_string(id, EV_SZ_weaponmodel, __GRENADE_MODEL_BUBBLE[1]);
			} else if(g_AntidoteBomb[id]) {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_vMODEL_ANTIDOTE);
			} else {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_vMODEL_FLARE);
			}
		} case CSW_AK47: {
			if((g_SpecialMode[id] == MODE_NEMESIS || g_SpecialMode[id] == MODE_ANNIHILATOR) && g_Bazooka[id]) {
				entity_set_string(id, EV_SZ_viewmodel, __MODEL_BAZOOKA[0]);
				entity_set_string(id, EV_SZ_weaponmodel, __MODEL_BAZOOKA[1]);
				
				if(g_SpecialMode[id] != MODE_ANNIHILATOR) {
					clientPrint(id, print_center, "Modo de disparo: %s", ((g_BazookaMode[id]) ? "Seguimiento" : "Normal"));
				}

				setAnimation(id, 3);
			} else {
				if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
					if(!g_Zombie[id] && g_WeaponModel[id][weapon_id]) {
						entity_set_string(id, EV_SZ_viewmodel, __WEAPON_MODELS[weapon_id][(g_WeaponModel[id][weapon_id] - 1)][weaponModelPath]);
					}
				}
			}
		} default: {
			if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
				if(!g_Zombie[id] && g_WeaponModel[id][weapon_id]) {
					entity_set_string(id, EV_SZ_viewmodel, __WEAPON_MODELS[weapon_id][(g_WeaponModel[id][weapon_id] - 1)][weaponModelPath]);
				}
			}
		}
	}
}

public effectGrenade(const ent, const red, const green, const blue, const nade_type) {
	new Float:vecColor[3];

	vecColor[0] = float(red);
	vecColor[1] = float(green);
	vecColor[2] = float(blue);

	entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell);
	entity_set_vector(ent, EV_VEC_rendercolor, vecColor);
	entity_set_int(ent, EV_INT_rendermode, kRenderNormal);
	entity_set_float(ent, EV_FL_renderamt, 16.0);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent);
	write_short(g_Sprite_Trail);
	write_byte(10);
	write_byte(3);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(200);
	message_end();

	entity_set_int(ent, EV_NADE_TYPE, nade_type);

	if(nade_type == NADE_TYPE_FLARE || nade_type == NADE_TYPE_BUBBLE) {
		entity_set_vector(ent, EV_FLARE_COLOR, vecColor);
	} else {
		entity_set_float(ent, EV_FL_dmgtime, (get_gametime() + 999.9));
	}
}

public infectionExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isPlayerValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	g_InfectionBomb[iAttacker] = 0;

	new Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 0, 255, 0, 500.0);

	emitSound(ent, CHAN_WEAPON, __SOUND_NADE_INFECT_EXPLO);

	new iVictim = -1;
	new iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) != 0) {
		if(!isPlayerValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_InBubble[iVictim]) {
			continue;
		}

		if(getHumans() == 1) {
			ExecuteHamB(Ham_Killed, iVictim, iAttacker, 0);
			continue;
		}

		zombieMe(iVictim, iAttacker, .silent_mode=1, .bomb=1);
		++iCountVictims;

		emitSound(iVictim, CHAN_VOICE, __SOUND_NADE_INFECT_EXPLO_PLAYER[random_num(0, charsmax(__SOUND_NADE_INFECT_EXPLO_PLAYER))]);
	}

	if(!iCountVictims) {
		setAchievement(iAttacker, BOMBA_FALLIDA);
	}

	remove_entity(ent);
}

public fireExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isPlayerValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 255, 0, 0, 500.0);

	emitSound(ent, CHAN_WEAPON, __SOUND_NADE_FIRE_EXPLO);

	new iVictim = -1;
	new iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) != 0) {
		if(!isPlayerValidAlive(iVictim) || !g_Zombie[iVictim] || g_Immunity[iVictim] || g_ImmunityBombs[iVictim] || g_BurningDuration[iVictim]) {
			continue;
		}

		burningPlayer(iVictim, iAttacker, 10);
		++iCountVictims;
	}

	if(iCountVictims) {

	} else {

	}

	remove_entity(ent);
}

public burningPlayer(const victim, const attacker, const time) {
	if(!g_BurningDuration[victim]) {
		if(g_SpecialMode[victim]) {
			g_BurningDuration[victim] = ((time + 1) / 2);
		} else {
			g_BurningDuration[victim] = ((time + 1) * 2);
		}

		g_BurningDurationOwner[victim] = attacker;

		static iArgs[1];
		iArgs[0] = attacker;

		if(!task_exists(victim + TASK_BURNING_FLAME)) {
			set_task(0.2, "task__BurningFlame", victim + TASK_BURNING_FLAME, iArgs, sizeof(iArgs), "b");
		}
	}
}

public frostExplode(const ent, const supernova) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isPlayerValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	if(supernova) {
		effectGrenadeExplode(vecOrigin, 0, 255, 255, 500.0);

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, (vecOrigin[2] + 5.0));
		write_short(g_Sprite_SuperNova);
		write_byte(20);
		write_byte(24);
		write_byte(TE_EXPLFLAG_NOSOUND);
		message_end();

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_SPRITETRAIL);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, (vecOrigin[2] - 20.0));
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, (vecOrigin[2] + 20.0));
		write_short(g_Sprite_ColorsBalls[3]);
		write_byte(random_num(20, 40));
		write_byte(4);
		write_byte(random_num(5, 8));
		write_byte(random_num(100, 200));
		write_byte(40);
		message_end();
	} else {
		effectGrenadeExplode(vecOrigin, 0, 0, 255, 500.0);
	}

	emitSound(ent, CHAN_WEAPON, __SOUND_NADE_FROST_EXPLO);

	new iVictim = -1;
	new iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) != 0) {
		if(!isPlayerValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_ImmunityBombs[iVictim] || g_Frozen[iVictim] || (random_num(1, 100) <= 35 && g_ArtifactsEquiped[iVictim][ARTIFACT_NECKLASE_FROST])) {
			continue;
		}

		freezePlayer(iVictim, iAttacker, supernova, 4.0);
		++iCountVictims;
	}

	if(iCountVictims) {

	} else {

	}

	remove_entity(ent);
}

public freezePlayer(const victim, const attacker, const supernova, const Float:time) {
	if(g_Frozen[victim]) {
		return;
	}

	set_user_rendering(victim, kRenderFxGlowShell, 0, ((supernova == 2) ? 255 : 0), 255, kRenderNormal, 100);

	if(!g_DrugBombMove[victim]) {
		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, victim);
		write_short(0);
		write_short(0);
		write_short(FFADE_STAYOUT);
		write_byte(0);
		write_byte(((supernova == 2) ? 255 : 0));
		write_byte(255);
		write_byte(100);
		message_end();
	}

	g_Frozen[victim] = supernova;
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, victim);

	if(entity_get_int(victim, EV_INT_flags) & FL_ONGROUND) {
		set_user_gravity(victim, 999999.9);
	} else {
		set_user_gravity(victim, 0.000001);
	}

	new iVictimFrozen = g_Hab[victim][HAB_Z_RESISTANCE_FROST];

	remove_task(victim + TASK_FREEZE);
	set_task(((iVictimFrozen >= 2) ? 2.0 : 4.0), "task__RemoveFreeze", victim + TASK_FREEZE);

	emitSound(victim, CHAN_BODY, __SOUND_NADE_FROST_PLAYER);

	if(g_Hab[victim][HAB_Z_RESISTANCE_FROST] >= 3) {
		g_BurningDuration[victim] = 0;
	}
}

public flareLighting(const ent, const duration, const flare_size) {
	static Float:vecOrigin[3];
	static Float:vecColor[3];

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	entity_get_vector(ent, EV_FLARE_COLOR, vecColor);

	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_byte(25 + flare_size);
	write_byte(floatround(vecColor[0]));
	write_byte(floatround(vecColor[1]));
	write_byte(floatround(vecColor[2]));
	write_byte(21);
	write_byte(((duration < 3) ? 10 : 0));
	message_end();
}

public bubbleExplode(const ent) {
	static Float:vecEntityOrigin[3];
	static iVictim;
	static j;
	static iUsers[MAX_PLAYERS + 1];
	static Float:vecOrigin[3];
	static Float:fScalar;
	static Float:fInvSqrt;
	static i;
	
	entity_get_vector(ent, EV_VEC_origin, vecEntityOrigin);
	iVictim = -1;
	j = 0;
	
	while((iVictim = find_ent_in_sphere(iVictim, vecEntityOrigin, 120.0)) != 0) {
		if(isPlayerValidAlive(iVictim)) {
			iUsers[j++] = iVictim;
		}
	}

	for(i = 0; i < j; ++i) {
		if(!g_Zombie[iUsers[i]]) {
			entity_get_vector(iUsers[i], EV_VEC_origin, vecOrigin);
			
			if(get_distance_f(vecEntityOrigin, vecOrigin) <= 100) {
				g_InBubble[iUsers[i]] = 1;
			} else {
				g_InBubble[iUsers[i]] = 0;
			}
		} else if(g_Zombie[iUsers[i]] && !g_SpecialMode[iUsers[i]] && !g_Immunity[iUsers[i]] && !g_ImmunityBombs[iUsers[i]]) {
			entity_get_vector(iUsers[i], EV_VEC_origin, vecOrigin);

			if(get_distance_f(vecEntityOrigin, vecOrigin) > 100) {
				fScalar = 255.0;
			} else {
				fScalar = 2000.0;
			}

			vecOrigin[0] -= vecEntityOrigin[0];
			vecOrigin[1] -= vecEntityOrigin[1];
			vecOrigin[2] -= vecEntityOrigin[2];

			fInvSqrt = 1.0 / floatsqroot(((vecOrigin[0] * vecOrigin[0]) + (vecOrigin[1] * vecOrigin[1]) + (vecOrigin[2] * vecOrigin[2])));

			vecOrigin[0] *= fInvSqrt;
			vecOrigin[1] *= fInvSqrt;
			vecOrigin[2] *= fInvSqrt;

			vecOrigin[0] *= fScalar;
			vecOrigin[1] *= fScalar;
			vecOrigin[2] *= fScalar;

			entity_set_vector(iUsers[i], EV_VEC_velocity, vecOrigin);
		}
	}
}

public drugExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isPlayerValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 255, 255, 0, 500.0);
	emitSound(ent, CHAN_WEAPON, __SOUND_NADE_FIRE_EXPLO);

	new iVictim = -1;
	new iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) != 0) {
		if(!isPlayerValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_ImmunityBombs[iVictim] || g_DrugBombMove[iVictim] || g_Petrification[iVictim]) {
			continue;
		}

		g_DrugBombCount[iVictim] = 0;

		remove_task(iVictim + TASK_DRUG);
		set_task(0.5, "task__DrugEffect", iVictim + TASK_DRUG, _, _, "a", 20);

		++iCountVictims;
	}

	remove_entity(ent);
}

public task__DrugEffect(const task_id) {
	new iId = (task_id - TASK_DRUG);

	if(!g_IsConnected[iId]) {
		return;
	}

	if(random_num(0, 1) == 1) {
		g_DrugBombMove[iId] = 1;

		rg_remove_all_items(iId);

		clientPrint(iId, print_center, "¡ESTÁS RE DURO!");

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iId);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_IN);
		write_byte(255);
		write_byte(0);
		write_byte(0);
		write_byte(random_num(100, 175));
		message_end();

		new Float:vecVelocity[3];

		vecVelocity[0] = random_float(100.0, 250.0);
		vecVelocity[1] = random_float(100.0, 250.0);
		vecVelocity[2] = random_float(100.0, 250.0);

		entity_set_vector(iId, EV_VEC_punchangle, vecVelocity);
		entity_get_vector(iId, EV_VEC_velocity, vecVelocity);

		vecVelocity[0] /= 3.0;
		vecVelocity[1] /= 2.0;

		entity_set_vector(iId, EV_VEC_velocity, vecVelocity);
	}

	++g_DrugBombCount[iId];

	if(g_DrugBombCount[iId] == 20) {
		g_DrugBombCount[iId] = 0;
		g_DrugBombMove[iId] = 0;

		rg_give_item(iId, "weapon_knife");

		if(g_InfectionBomb[iId]) {
			rg_give_item(iId, "weapon_hegrenade");
		}
	}
}

public killExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isPlayerValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 107, 66, 38, 500.0);

	emitSound(ent, CHAN_WEAPON, __SOUND_ROUND_SURVIVOR[0]);

	new iVictim = -1;
	new iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) != 0) {
		if(!isPlayerValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim]) {
			continue;
		}

		ExecuteHamB(Ham_Killed, iVictim, iAttacker, 2);
		++iCountVictims;
	}

	if(iCountVictims) {
		addXP(iAttacker, (iCountVictims * (getUserLevelTotal(iAttacker) * floatround(g_XPMult[iAttacker]))));
	} else {
		if(g_SpecialMode[iAttacker] == MODE_SURVIVOR) {
			setAchievement(iAttacker, ANIQUILA_ANIQUILADOR);
		} else {
			setAchievement(iAttacker, NO_LA_NECESITO);
		}
	}

	remove_entity(ent);
}

public antidoteExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isPlayerValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 198, 226, 255, 500.0);

	emitSound(ent, CHAN_WEAPON, __SOUND_HUMAN_ANTIDOTE);

	new iVictim = -1;
	new iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) != 0) {
		if(!isPlayerValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim]) {
			continue;
		}

		++iCountVictims;

		if(getZombies() == 1) {
			continue;
		}

		sendDeathMsg(iAttacker, iVictim);
		fixDeadAttrib(iVictim);

		humanMe(iVictim, .silent_mode=1);
	}

	if(iCountVictims) {
		if(iCountVictims >= 12) {
			setAchievement(iAttacker, YO_USO_CLEAR_ZOMBIE);

			if(iCountVictims >= 18) {
				setAchievement(iAttacker, ANTIDOTO_PARA_TODOS);
			}
		}
	} else {
		setAchievement(iAttacker, Y_LA_LIMPIEZA);
	}

	remove_entity(ent);
}

public effectGrenadeExplode(const Float:vecOrigin[3], const red, const green, const blue, const Float:radius) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, (vecOrigin[2] + radius));
	write_short(g_Sprite_ShockWave);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(255);
	write_byte(0);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_byte(30);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(15);
	write_byte(50);
	message_end();
}

public isPlayerStuck(const id) {
	new Float:vecOrigin[3];
	new iHull = ((get_entvar(id, var_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN);

	get_entvar(id, var_origin, vecOrigin);

	return (trace_hull(vecOrigin, iHull, id, DONT_IGNORE_MONSTERS) != 0);
}

public dropHeadZombie(const id, const violet) {
	if(!g_IsConnected[id]) {
		return;
	}

	new iEnt = create_entity("info_target");
	new Float:vecVelocity[3];
	new Float:vecOrigin[3];

	velocity_by_aim(id, 300, vecVelocity);
	getDropOrigin(id, vecOrigin);

	if(is_valid_ent(iEnt)) {
		if(random_num(1, 25) != 1) {
			entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_HEADZOMBIE);
			entity_set_model(iEnt, __MODEL_HEADZOMBIE);
			entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
			entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

			entity_set_origin(iEnt, vecOrigin);
			entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

			entity_set_edict(iEnt, EV_ENT_euser2, id);

			set_size(iEnt, Float:{-6.0, -6.0, -6.0}, Float:{6.0, 6.0, 6.0});
			entity_set_vector(iEnt, EV_VEC_mins, Float:{-6.0, -6.0, -6.0});
			entity_set_vector(iEnt, EV_VEC_maxs, Float:{6.0, 6.0, 6.0});

			new Float:vecColor[3];
			new iRed = random_num(0, 1);
			new iGreen = random_num(0, 1);
			new iYellow = random_num(1, 10);
			new iHeadColor;

			if(iYellow == 1 || iYellow == 10) {
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

			set_rendering(iEnt, kRenderFxGlowShell, floatround(vecColor[0]), floatround(vecColor[1]), floatround(vecColor[2]), kRenderNormal, 16);
			entity_set_edict(iEnt, EV_ENT_euser4, iHeadColor);
		} else {
			entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_HEADZOMBIE_SMALL);
			entity_set_model(iEnt, __MODEL_HEADZOMBIE_SMALL);
			entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
			entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

			entity_set_origin(iEnt, vecOrigin);
			entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

			entity_set_edict(iEnt, EV_ENT_euser2, id);

			set_size(iEnt, Float:{-3.0, -3.0, -3.0}, Float:{3.0, 3.0, 3.0});
			entity_set_vector(iEnt, EV_VEC_mins, Float:{-3.0, -3.0, -3.0});
			entity_set_vector(iEnt, EV_VEC_maxs, Float:{3.0, 3.0, 3.0});

			set_rendering(iEnt, kRenderFxGlowShell, 255, 0, 255, kRenderNormal, 16);
			entity_set_edict(iEnt, EV_ENT_euser4, HEADZOMBIE_VIOLET_SMALL);
		}
	}
}

getDropOrigin(const id, Float:vecOrigin[3], const vel_add=0) {
	if(!g_IsConnected[id]) {
		return;
	}

	new Float:vecViewOfs[3];
	new Float:vecAim[3];

	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	entity_get_vector(id, EV_VEC_view_ofs, vecViewOfs);
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin);

	velocity_by_aim(id, (50 + vel_add), vecAim);

	vecOrigin[0] += vecAim[0];
	vecOrigin[1] += vecAim[1];
}

public turnOffFlashlight(const id) {
	entity_set_int(id, EV_INT_effects, (entity_get_int(id, EV_INT_effects) & ~EF_DIMLIGHT));
	
	message_begin(MSG_ONE_UNRELIABLE, g_Message_Flashlight, _, id);
	write_byte(0);
	write_byte(OFF_IMPULSE_FLASHLIGHT);
	message_end();
	
	entity_set_int(id, EV_INT_impulse, 0);
}

public getWeaponEntId(const weapon_ent) {
	if(pev_valid(weapon_ent) != PDATA_SAFE) {
		return -1;
	}

	return get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

public getWeaponId(const weapon_ent) {
	if(pev_valid(weapon_ent) != PDATA_SAFE) {
		return -1;
	}

	return get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
}

public getCurrentWeaponEnt(const id) {
	if(pev_valid(id) != PDATA_SAFE) {
		return -1;
	}
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

public setUserBatteries(const id, const battery) {
	if(pev_valid(id) != PDATA_SAFE) {
		return;
	}

	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, battery, OFFSET_LINUX);
}

public getHabCost(const id, const hab) {
	return ((g_Hab[id][hab] + 1) * __HABS[hab][habCost]);
}

getHabLevel(const id, const hab_class, const hab, &hat=0, &amulet=0) {
	new iHabs = g_Hab[id][hab];
	new iExtras = 0;

	if(hab_class == HAB_CLASS_HUMAN) {
		switch(hab) {
			case HAB_H_HEALTH: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade1];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acHealth];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			} case HAB_H_SPEED: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade2];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acSpeed];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			} case HAB_H_GRAVITY: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade3];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acGravity];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			} case HAB_H_DAMAGE: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade4];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acDamage];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			}
		}
	} else if(hab_class == HAB_CLASS_ZOMBIE) {
		switch(hab) {
			case HAB_Z_HEALTH: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade1];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acHealth];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			} case HAB_Z_SPEED: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade2];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acSpeed];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			} case HAB_Z_GRAVITY: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade3];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acGravity];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			} case HAB_Z_DAMAGE: {
				if(g_HatId[id] != HAT_NONE) {
					hat = iExtras = __HATS[g_HatId[id]][hatUpgrade4];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}

				if(g_AmuletCustomCreated[id]) {
					amulet = iExtras = g_AmuletCustom[id][acDamage];
					iHabs += iExtras;
				} else {
					iExtras = 0;
				}
			}
		}
	}

	return iHabs;
}

public task__MessageVip(const task_id) {
	new iId = (task_id - TASK_MESSAGE_VIP);
	
	if(!g_IsConnected[iId] || (get_user_flags(iId) & ADMIN_RESERVATION)) {
		return;
	}

	clientPrintColor(iId, _, "Duplica tus ganancias en el Zombie Plague siendo VIP. Visita !g%s!y para más información", __PLUGIN_COMMUNITY_FORUM_SHOP);
	set_task(210.0, "task__MessageVip", iId + TASK_MESSAGE_VIP);
}

public task__MessageVinc(const task_id) {
	new iId = (task_id - TASK_MESSAGE_VINC);
	
	if(!g_IsConnected[iId] || g_AccountVinc[iId]) {
		return;
	}

	clientPrintColor(iId, _, "Tu cuenta no está vinculada a !g%s!y, recordá vincularla lo más pronto posible en el menú de !gOPCIONES DE USUARIO!y", __PLUGIN_COMMUNITY_NAME);
	clientPrintColor(iId, _, "Vincular tu cuenta ofrece varias opciones/funciones, alguna de ellas muy importantes, además de un logro. Para verlas, visita !tzp.DrunkGaming.net!y");

	set_task(300.0, "task__MessageVinc", iId + TASK_MESSAGE_VINC);
}

public sqlThread__IgnoreQuery(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__IgnoreQuery() - [%d] - <%s>", error_num, error);
	}
}

public sqlThread__SaveUserOptions(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__SaveUserOptions() - [%d] - <%s>", error_num, error);
		return;
	}

	server_print("sqlThread__SaveUserOptions() - queue_time[%0.2f]", queue_time);
}

public sqlThread__RegisterAccount(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__RegisterAccount() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al registrar tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	g_AccountId[iId] = SQL_GetInsertId(query);

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_pjs (acc_id) VALUES ('%d');", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__RegisterPj", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__RegisterPj(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__RegisterPj() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al registrar tu personaje. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_pjs_stats (acc_id) VALUES ('%d');", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__RegisterPjStats", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__RegisterPjStats(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__RegisterPjStats() - [%d] - <%s>", error_num, error);

		rh_drop_client(iId, fmt("Hubo un error al registrar las estadísticas de tu personaje. Contáctese con el desarrollador para más información e inténtalo más tarde.", get_user_userid(iId)));
		return;
	}

	++g_GlobalRank;

	if(g_GlobalRank && ((g_GlobalRank % 250) == 0)) {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_LOGGED) {
				continue;
			}

			g_Points[i][P_HUMAN] += 25;
			g_Points[i][P_ZOMBIE] += 25;
		}

		clientPrintColor(0, _, "Todos los jugadores conectados ganaron !g25 pH!y y !g25 pZ!y por alcanzar las !g%d cuentas registradas!y", g_GlobalRank);
	}

	new sAccount[8];
	addDot(g_GlobalRank, sAccount, charsmax(sAccount));
	clientPrintColor(0, iId, "Bienvenido !t%s!y, eres la cuenta registrada !g#%s!y", g_PlayerName[iId], sAccount);

	if(getUserIsSteamId(iId)) {
		copy(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), g_PlayerSteamId[iId]);
	} else {
		formatex(g_PlayerSteamIdCache[iId], charsmax(g_PlayerSteamIdCache[]), "STEAM_ID_LAN");
	}

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_bans WHERE (ip=^"%s^" OR (steam=^"%s^" AND steam<>'STEAM_ID_LAN')) AND active='1';", g_PlayerIp[iId], g_PlayerSteamIdCache[iId]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(iId, sqlQuery, 29);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "staff_name"), g_AccountBanned_StaffName[iId], charsmax(g_AccountBanned_StaffName[]));
		g_AccountBanned_Start[iId] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "start"));
		g_AccountBanned_Finish[iId] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "finish"));
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "reason"), g_AccountBanned_Reason[iId], charsmax(g_AccountBanned_Reason[]));

		SQL_FreeHandle(sqlQuery);

		g_AccountStatus[iId] = STATUS_BANNED;
		showMenu__Banned(iId);

		clientPrintColor(0, iId, "!t%s!y ha sido baneado porque se ha encontrado coincidencias con otro usuario baneado por cuenta", g_PlayerName[iId]);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_bans (acc_id, ip, steam, staff_name, start, finish, reason) VALUES ('%d', ^"%s^", ^"%s^", ^"%s^", '%d', '%d', ^"%s^");", g_AccountId[iId], g_PlayerIp[iId], g_PlayerSteamIdCache[iId], g_AccountBanned_StaffName[iId], g_AccountBanned_Start[iId], g_AccountBanned_Finish[iId], g_AccountBanned_Reason[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);

		g_AccountStatus[iId] = STATUS_REGISTERED;
		showMenu__LogIn(iId);

		clientPrintColor(iId, _, "Por motivos de seguridad, inicia sesión con tu cuenta recién creada");
	}
}

public randomSpawn(const id) {
	new iSpawnId;
	new iHull;
	new i;
	new Float:vecData[3];

	iSpawnId = random_num(0, (g_SpawnCount - 1));
	iHull = ((entity_get_int(id, EV_INT_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN);

	for(i = (iSpawnId + 1);/* no condition */; ++i) {
		if(i >= g_SpawnCount) {
			i = 0;
		}

		vecData[0] = g_Spawns[i][0];
		vecData[1] = g_Spawns[i][1];
		vecData[2] = g_Spawns[i][2];

		if(isHullVacant(vecData, iHull)) {
			entity_set_vector(id, EV_VEC_origin, vecData);

			vecData[0] = g_Spawns[i][3];
			vecData[1] = g_Spawns[i][4];
			vecData[2] = g_Spawns[i][5];

			entity_set_vector(id, EV_VEC_angles, vecData);

			vecData[0] = g_Spawns[i][6];
			vecData[1] = g_Spawns[i][7];
			vecData[2] = g_Spawns[i][8];

			entity_set_vector(id, EV_VEC_v_angle, vecData);

			break;
		}

		if(i == iSpawnId) {
			break;
		}
	}

	set_task(0.5, "task__CheckStuck", id);
}

public task__CheckStuck(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	if(isPlayerStuck(id)) {
		randomSpawn(id);
	}
}

public touch__AllGrenade(const grenade, const ent) {
	if(is_valid_ent(grenade) && isSolid(ent) && g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL) {
		new iNadeType = entity_get_int(grenade, EV_NADE_TYPE);

		if(iNadeType != NADE_TYPE_FLARE && iNadeType != NADE_TYPE_BUBBLE) {
			entity_set_float(grenade, EV_FL_dmgtime, (get_gametime() + 0.001));
		}
	}
}

public isSolid(const ent) {
	return (ent ? ((entity_get_int(ent, EV_INT_solid) > SOLID_TRIGGER) ? 1 : 0) : 1);
}

public touch__RocketBazooka(const rocket, const ent) {
	if(is_valid_ent(rocket)) {
		new iAttacker = entity_get_edict(rocket, EV_ENT_owner);
		
		if(!g_IsConnected[iAttacker]) {
			nemesisBazookaRemoveEnt(rocket);
			return;
		}

		new Float:vecOrigin[3];
		new Float:flRadius = ((g_Hab[iAttacker][HAB_S_NEM_BAZOOKA_RADIUS]) ? 750.0 : 500.0);
		new iCountVictims = 0;
		new iVictim = -1;
		new i;

		entity_get_vector(rocket, EV_VEC_origin, vecOrigin);

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		write_short(g_Sprite_FExplo);
		write_byte(90);
		write_byte(10);
		write_byte(TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NODLIGHTS);
		message_end();
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_WORLDDECAL);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		write_byte(random_num(46, 48));
		message_end();
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_WORLDDECAL);
		engfunc(EngFunc_WriteCoord, vecOrigin[0] + 90.0);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		write_byte(random_num(46, 48));
		message_end();

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_DLIGHT);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		write_byte(150);
		write_byte(175);
		write_byte(30);
		write_byte(30);
		write_byte(150);
		write_byte(15);
		message_end();

		client_cmd(0, "stopsound");
		playSound(0, __SOUND_NEMESIS_BAZOOKA[random_num(2, 3)]);

		if(g_SpecialMode[iAttacker] == MODE_NEMESIS) {
			while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, flRadius)) != 0) {
				if(!isPlayerValidConnected(iVictim) || !g_IsAlive[iVictim] || g_Zombie[iVictim]) {
					continue;
				}

				ExecuteHamB(Ham_Killed, iVictim, iAttacker, 2);
				++iCountVictims;
			}
		} else {
			while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, flRadius)) != 0) {
				if(!isPlayerValidAlive(iVictim) || g_Zombie[iVictim]) {
					continue;
				}

				ExecuteHamB(Ham_Killed, iVictim, iAttacker, 1);
				++iCountVictims;
			}
		}
		
		if(g_SpecialMode[iAttacker] == MODE_NEMESIS) {
			if(!iCountVictims) {
				setAchievement(iAttacker, LA_EXPLOSION_NO_MATA);
			} else if(iCountVictims >= 20) {
				setAchievement(iAttacker, LA_EXPLOSION_SI_MATA);
			}
		} else if(g_SpecialMode[iAttacker] == MODE_ANNIHILATOR) {
			g_Achievement_AnnBazooka[iAttacker] += iCountVictims;

			if(!getHumans()) {
				setAchievement(iAttacker, OOPS_MATE_A_TODOS);
			}
		}
		
		nemesisBazookaRemoveEnt(rocket);

		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsConnected[i]) {
				continue;
			}

			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, i);
			write_short(UNIT_SECOND * 5);
			write_short(UNIT_SECOND * 5);
			write_short(FFADE_IN);
			write_byte(175);
			write_byte(30);
			write_byte(30);
			write_byte(200);
			message_end();

			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, i);
			write_short(UNIT_SECOND * 28);
			write_short(UNIT_SECOND * 28);
			write_short(UNIT_SECOND * 28);
			message_end();
		}
	}
}

public nemesisBazookaRemoveEnt(const rocket) {
	if(is_valid_ent(rocket)) {
		new iEntFlare = entity_get_edict(rocket, EV_ENT_FLARE);

		if(is_valid_ent(iEntFlare)) {
			remove_entity(iEntFlare);
		}

		remove_entity(rocket);
	}
}

public isHullVacant(const Float:vecOrigin[3], const hull) {
	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, hull, 0, 0);

	if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen)) {
		return 1;
	}

	return 0;
}

public fixDeadAttrib(const id) {
	message_begin(MSG_BROADCAST, g_Message_ScoreAttrib);
	write_byte(id);
	write_byte(0);
	message_end();
}

public sendDeathMsg(const attacker, const victim) {
	message_begin(MSG_BROADCAST, g_Message_DeathMsg);
	write_byte(attacker);
	write_byte(victim);
	write_byte(1);
	write_string("infection");
	message_end();
	
	set_user_frags(attacker, (get_user_frags(attacker) + 1));
	set_pdata_int(victim, OFFSET_CSDEATHS, (cs_get_user_deaths(victim) + 1), OFFSET_LINUX);
	
	message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
	write_byte(attacker);
	write_short(get_user_frags(attacker));
	write_short(cs_get_user_deaths(attacker));
	write_short(0);
	write_short(_:getUserTeam(attacker));
	message_end();
	
	message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
	write_byte(victim);
	write_short(get_user_frags(victim));
	write_short(cs_get_user_deaths(victim));
	write_short(0);
	write_short(_:getUserTeam(victim));
	message_end();
}

public task__Save(const task_id) {
	new iId = (task_id - TASK_SAVE);

	if(!g_IsConnected[iId]) {
		return;
	}

	saveInfo(iId);
}

public task__PlayedTime(const task_id) {
	new iId = (task_id - TASK_PLAYED_TIME);

	if(!g_IsConnected[iId] || g_AccountStatus[iId] < STATUS_LOGGED) {
		return;
	}

	g_PlayedTime[iId][TIME_SEC] += 6;
}

public showMenu__UserOptions_Vinc(const id) {
	oldmenu_create("\yVINCULAR CUENTA", "menu__UserOptions_Vinc");

	oldmenu_additem(-1, -1, "\wPara vincular tu cuenta del Zombie Plague");
	oldmenu_additem(-1, -1, "\wcon tu cuenta del foro, debes ingresar");
	oldmenu_additem(-1, -1, "\wtu \ye-mail\w y tu \yclave\w con la que");
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

public menu__UserOptions_Vinc(const id, const item) {
	if(!item) {
		if(g_AccountStatus[id] == STATUS_PLAYING) {
			showMenu__UserOptions(id);
		} else {
			showMenu__Join(id);
		}
	} else if(item == 1) {
		if(g_AccountVinc[id]) {
			clientPrintColor(id, _, "Tu cuenta ya ha sido vinculada. Visita nuestro foro para ver tus datos en el Panel de Vinculación !g%s/vinculacion/zpa!y", __PLUGIN_COMMUNITY_FORUM);

			showMenu__UserOptions_Vinc(id);
			return;
		}

		client_cmd(id, "messagemode V_INGRESAR_MAIL");
		clientPrintColor(id, _, "Ingresa tu E-Mail con el que te registraste en el foro !t%s!y", __PLUGIN_COMMUNITY_FORUM);
	}
}

public clcmd__VEnterMail(const id) {
	if(g_AccountStatus[id] < STATUS_LOGGED || g_AccountVinc[id]) {
		return PLUGIN_HANDLED;
	}

	static sBuffer[128];
	read_argv(1, sBuffer, charsmax(sBuffer));

	copy(g_AccountVincMail[id], charsmax(g_AccountVincMail[]), sBuffer);

	clientPrintColor(id, _, "Ingresa tu clave con el que ingresas en el foro !t%s!y", __PLUGIN_COMMUNITY_FORUM);

	client_cmd(id, "messagemode V_INGRESAR_CLAVE");
	return PLUGIN_HANDLED;
}

public clcmd__VEnterPassword(const id) {
	if(g_AccountStatus[id] < STATUS_LOGGED || g_AccountVinc[id]) {
		return PLUGIN_HANDLED;
	}

	static sBuffer[128];
	read_argv(1, sBuffer, charsmax(sBuffer));

	copy(g_AccountVincPassword[id], charsmax(g_AccountVincPassword[]), sBuffer);

	checkAccountVinc(id);
	return PLUGIN_HANDLED;
}

public checkAccountVinc(const id) {
	static CURL:cSesion;
	cSesion = curl_easy_init();

	if(!cSesion) {
		g_AccountVinc[id] = 0;
		g_AccountVincMail[id][0] = EOS;
		g_AccountVincPassword[id][0] = EOS;

		clientPrintColor(id, _, "Ocurrió un error interno al vincular tu cuenta. Inténtalo más tarde");

		showMenu__UserOptions_Vinc(id);
		return;
	}

	curl_easy_setopt(cSesion, CURLOPT_CAINFO, "/etc/ssl/certs/ca-certificates.crt");

	static sMail[128];
	static sPassword[128];

	curl_easy_escape(cSesion, g_AccountVincMail[id], sMail, charsmax(sMail));
	curl_easy_escape(cSesion, g_AccountVincPassword[id], sPassword, charsmax(sPassword));

	curl_easy_setopt(cSesion, CURLOPT_BUFFERSIZE, 512);
	curl_easy_setopt(cSesion, CURLOPT_URL, "https://www.DrunkGaming.net/vinc.php");
	curl_easy_setopt(cSesion, CURLOPT_POST, 1);

	static sBuffer[256];
	formatex(sBuffer, charsmax(sBuffer), "id=%d&email=%s&password=%s", id, sMail, sPassword);
	curl_easy_setopt(cSesion, CURLOPT_COPYPOSTFIELDS, sBuffer);

	static iArgs[1];
	iArgs[0] = id;

	curl_easy_setopt(cSesion, CURLOPT_WRITEFUNCTION, "checkAccountVinc_WriteFunction");
	curl_easy_perform(cSesion, "checkAccountVinc_Perform", iArgs, sizeof(iArgs));
}

public checkAccountVinc_WriteFunction(const data[], const size, const m, const file) {
	server_print("%s", data);

	if(data[0] == 'e' && data[1] == 'r' && data[2] == 'r' && data[3] == 'o' && data[4] == 'r') {
		return 0;
	}

	static sId[8];
	static iId;

	formatex(sId, charsmax(sId), "%s", checkAccountVinc_Data(data, 0));
	iId = str_to_num(sId);

	if(!isPlayerValidConnected(iId)) {
		return 0;
	}

	static sMemberId[8];
	static iMemberId;

	formatex(sMemberId, charsmax(sMemberId), "%s", checkAccountVinc_Data(data, 1));
	iMemberId = str_to_num(sMemberId);

	g_AccountVinc[iId] = iMemberId;
	return (size * m);
}

public checkAccountVinc_Perform(const CURL:curl, const CURLcode:code, const data[]) {
	curl_easy_cleanup(curl);

	new iId = data[0];

	if(!isPlayerValidConnected(iId)) {
		return;
	}

	if(code == CURLE_WRITE_ERROR) {
		g_AccountVinc[iId] = 0;
		g_AccountVincMail[iId][0] = EOS;
		g_AccountVincPassword[iId][0] = EOS;

		clientPrintColor(iId, _, "Tus datos han sido rechazados. Verifica tus datos si son correctos y vuelve a intentarlo más tarde");

		showMenu__UserOptions_Vinc(iId);
		return;
	}

	clientPrintColor(iId, _, "Tus datos han sido aceptados y tu cuenta ha sido vinculada correctamente");

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_accounts SET vinc='%d' WHERE id='%d';", g_AccountVinc[iId], g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	if(!g_Achievement[iId][VINCULADO]) {
		setAchievement(iId, VINCULADO);
	}

	showMenu__UserOptions_Vinc(iId);
}

public checkAccountVinc_Data(const data[], const data_id) {
	static sData[256];
	formatex(sData, charsmax(sData), "%s", data);

	if(sData[0] == 'e' && sData[1] == 'r' && sData[2] == 'r' && sData[3] == 'o' && sData[4] == 'r') {
		sData[0] = EOS;
		return sData;
	}

	replace_all(sData, charsmax(sData), "{", "");
	replace_all(sData, charsmax(sData), ":", "");
	replace_all(sData, charsmax(sData), "^"id^"", "");
	replace_all(sData, charsmax(sData), "^"member_id^"", "");
	replace_all(sData, charsmax(sData), ",", " ");

	static i;
	static sId[8];
	static sForumMemberId[8];

	for(i = 0; i < strlen(sData); ++i) {
		if(sData[i] == '}') {
			sData[i] = EOS;
			break;
		}
	}

	parse(sData, sId, charsmax(sId), sForumMemberId, charsmax(sForumMemberId));

	switch(data_id) {
	 	case 0: {
			formatex(sData, charsmax(sData), "%s", sId);
		} case 1: {
			formatex(sData, charsmax(sData), "%s", sForumMemberId);
		}
	}

	return sData;
}

public clcmd__Radio2(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	if(g_LastHatUnlocked != -1) {
		g_MenuData[id][MENU_DATA_HAT_ID] = g_LastHatUnlocked;
		showMenu__HatInfo(id, g_MenuData[id][MENU_DATA_HAT_ID]);
	}

	return PLUGIN_HANDLED;
}

public checkAchievementsWeapons(const id, const weapon_id) {
	if(weapon_id == CSW_M249 || weapon_id == CSW_AWP || weapon_id == CSW_SCOUT || weapon_id == CSW_G3SG1 || weapon_id == CSW_SG550) {
		return;
	}

	switch(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]) {
		case 5..9: {
			setAchievement(id, LA_MEJOR_OPCION);
			setAchievementFirst(id, PRIMERO_LA_MEJOR_OPCION);
		} case 10..14: {
			setAchievement(id, UNA_DE_LAS_MEJORES);
			setAchievementFirst(id, PRIMERO_UNA_DE_LAS_MEJORES);
		} case 15..19: {
			setAchievement(id, MI_PREFERIDA);
			setAchievementFirst(id, PRIMERO_MI_PREFERIDA);
		} case 20: {
			setAchievement(id, LA_MEJOR);
			setAchievementFirst(id, PRIMERO_LA_MEJOR);
		}
	}

	static iTotal;
	iTotal = getWeaponsTotal(id, 5);

	switch(iTotal) {
		case 5..9: {
			setAchievement(id, LA_MEJOR_OPCION_x5);
		} case 10..14: {
			setAchievement(id, LA_MEJOR_OPCION_x10);
		} case 15..19: {
			setAchievement(id, LA_MEJOR_OPCION_x15);
		} case 20: {
			setAchievement(id, LA_MEJOR_OPCION_x20);
		}
	}

	iTotal = getWeaponsTotal(id, 10);

	switch(iTotal) {
		case 5..9: {
			setAchievement(id, UNA_DE_LAS_MEJORES_x5);
		} case 10..14: {
			setAchievement(id, UNA_DE_LAS_MEJORES_x10);
		} case 15..19: {
			setAchievement(id, UNA_DE_LAS_MEJORES_x15);
		} case 20: {
			setAchievement(id, UNA_DE_LAS_MEJORES_x20);
		}
	}

	iTotal = getWeaponsTotal(id, 15);

	switch(iTotal) {
		case 5..9: {
			setAchievement(id, MI_PREFERIDA_x5);
		} case 10..14: {
			setAchievement(id, MI_PREFERIDA_x10);
		} case 15..19: {
			setAchievement(id, MI_PREFERIDA_x15);
		} case 20: {
			setAchievement(id, MI_PREFERIDA_x20);
		}
	}

	iTotal = getWeaponsTotal(id, 20);

	switch(iTotal) {
		case 5..9: {
			setAchievement(id, LA_MEJOR_x5);
		} case 10..14: {
			setAchievement(id, LA_MEJOR_x10);
		} case 15..19: {
			setAchievement(id, LA_MEJOR_x15);
		} case 20: {
			setAchievement(id, LA_MEJOR_x20);
			giveHat(id, HAT_ZIPPY);
		}
	}
}

public getWeaponsTotal(const id, const level) {
	new iCount = 0;
	new i;

	for(i = 1; i < 31; ++i) {
		if(__WEAPON_NAMES[i][0] && g_WeaponData[id][i][WEAPON_DATA_LEVEL] >= level) {
			++iCount;
		}
	}

	return iCount;
}

public checkAchievementTotal(const id, const class) {
	new iCount = 0;
	new i;

	for(i = 0; i < structIdAchievements; ++i) {
		if(class == __ACHIEVEMENTS[i][achievementClass] && g_Achievement[id][i]) {
			++iCount;
		}
	}

	return iCount;
}

setAchievement(const id, const achievement, achievement_fake=0) {
	if(g_Achievement[id][achievement]) {
		return;
	}

	if(!achievement_fake) {
		if(__ACHIEVEMENTS[achievement][achievementUsersNeedP] && getUsersPlaying() < __ACHIEVEMENTS[achievement][achievementUsersNeedP]) {
			return;
		} else if(__ACHIEVEMENTS[achievement][achievementUsersNeedA] && getUsersAlive() < __ACHIEVEMENTS[achievement][achievementUsersNeedA]) {
			return;
		}
	}

	g_Achievement[id][achievement] = 1;
	g_AchievementUnlocked[id][achievement] = get_arg_systime();
	++g_AchievementTotal[id];

	g_LastAchUnlocked = achievement;
	g_LastAchUnlockedPage = __ACHIEVEMENTS[achievement][achievementClass];
	g_LastAchUnlockedClass = __ACHIEVEMENTS[achievement][achievementClass];

	clientPrintColor(0, _, "!t%s!y ganó el logro !g%s !t(%d SALDO)!y [Z]", g_PlayerName[id], __ACHIEVEMENTS[achievement][achievementName], __ACHIEVEMENTS[achievement][achievementReward]);

	new sBuffer[256];
	formatex(sBuffer, charsmax(sBuffer), "LOGRO DESBLOQUEADO - %s^nGanaste %d SALDO", __ACHIEVEMENTS[achievement][achievementName], __ACHIEVEMENTS[achievement][achievementReward]);
	tutorMake(id, sBuffer, TT_COLOR_WHITE, 5.0);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_achievements (acc_id, achievement_id, achievement_timestamp) VALUES ('%d', '%d', '%d');", g_AccountId[id], achievement, get_arg_systime());
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	g_Points[id][P_MONEY] += __ACHIEVEMENTS[achievement][achievementReward];

	rewardAchievement(id);
}

setAchievementFirst(const id, const achievement, achievement_fake=0) {
	if(g_AccountId[id] == 1 || g_Achievement[0][achievement]) {
		return;
	}

	if(!achievement_fake) {
		if(__ACHIEVEMENTS[achievement][achievementUsersNeedP] && getUsersPlaying() < __ACHIEVEMENTS[achievement][achievementUsersNeedP]) {
			return;
		} else if(__ACHIEVEMENTS[achievement][achievementUsersNeedA] && getUsersAlive() < __ACHIEVEMENTS[achievement][achievementUsersNeedA]) {
			return;
		}
	}

	g_Achievement[0][achievement] = 1;
	g_Achievement[id][achievement] = 1;
	g_AchievementUnlocked[0][achievement] = get_arg_systime();
	g_AchievementUnlocked[id][achievement] = get_arg_systime();
	++g_AchievementTotal[id];

	g_LastAchUnlocked = achievement;
	g_LastAchUnlockedPage = __ACHIEVEMENTS[achievement][achievementClass];
	g_LastAchUnlockedClass = __ACHIEVEMENTS[achievement][achievementClass];

	clientPrintColor(0, _, "!t%s!y ganó el logro !g%s !t(%d SALDO)!y [Z]", g_PlayerName[id], __ACHIEVEMENTS[achievement][achievementName], __ACHIEVEMENTS[achievement][achievementReward]);
	
	new sBuffer[256];
	formatex(sBuffer, charsmax(sBuffer), "LOGRO DESBLOQUEADO - %s^nGanaste %d SALDO", __ACHIEVEMENTS[achievement][achievementName], __ACHIEVEMENTS[achievement][achievementReward]);
	tutorMake(id, sBuffer, TT_COLOR_WHITE, 5.0);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_achievements (acc_id, achievement_id, achievement_timestamp, achievement_is_first) VALUES ('%d', '%d', '%d', '1');", g_AccountId[id], achievement, get_arg_systime());
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	g_Points[id][P_MONEY] += __ACHIEVEMENTS[achievement][achievementReward];

	rewardAchievement(id);
}

public rewardAchievement(const id) {
	if((g_AchievementTotal[id] % 25) == 0) {
		switch(g_AchievementTotal[id]) {
			case 25: {
				setAchievement(id, LOS_PRIMEROS);
			} case 75: {
				setAchievement(id, VAMOS_POR_MAS);
			} case 150: {
				setAchievement(id, EXPERTO_EN_LOGROS);
			} case 300: {
				setAchievement(id, THIS_IS_SPARTA);
			} default: {
				saveInfo(id);
			}
		}
	}

	if(!g_Hat[id][HAT_PSYCHO] && g_Achievement[id][BOMBA_FALLIDA] && g_Achievement[id][VIRUS]) {
		giveHat(id, HAT_PSYCHO);
	}

	if(g_AchievementTotal[id]) {
		g_AmmoPacksMult_Achievements[id] = (0.0022 * float(g_AchievementTotal[id]));
		g_XPMult_Achievements[id] = (0.0066 * float(g_AchievementTotal[id]));
	}
}

public showMenu__AchievementsClasses(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	formatex(sItem, charsmax(sItem), "LOGROS^n\wLogros completados en total\r:\y %d\R", g_AchievementTotal[id]);
	iMenuId = menu_create(sItem, "menu__AchievementsClasses");

	for(i = 0; i < structIdAchievementClasses; ++i) {
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, __ACHIEVEMENTS_CLASSES[i], sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASSES] = min(g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASSES], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASSES]);
}

public menu__AchievementsClasses(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS_ID] = iItemId;

	showMenu__Achievements(id);
	return PLUGIN_HANDLED;
}

public showMenu__Achievements(const id) {
	new iAchievementClassId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS_ID];
	new sItem[64];
	new iMenuId;
	new i;
	new j;
	new k;
	new sPosition[4];

	formatex(sItem, charsmax(sItem), "LOGROS\r:\w %s^n\wLogros completados\r:\y %d\R", __ACHIEVEMENTS_CLASSES[iAchievementClassId], checkAchievementTotal(id, iAchievementClassId));
	iMenuId = menu_create(sItem, "menu__Achievements");

	j = 0;
	k = 0;

	for(i = 0; i < structIdAchievements; ++i) {
		if(__ACHIEVEMENTS[i][achievementClass] != -1 && iAchievementClassId != __ACHIEVEMENTS[i][achievementClass]) {
			++k;
			continue;
		}

		if(__ACHIEVEMENTS[i][achievementEnabled]) {
			formatex(sItem, charsmax(sItem), "%s%s%s", ((!g_Achievement[id][i]) ? "\d" : "\w"), __ACHIEVEMENTS[i][achievementName], ((!g_Achievement[id][i]) ? " \r(NO COMPLETADO)" : " \y(COMPLETADO)"));
		} else {
			formatex(sItem, charsmax(sItem), "\d%s", __ACHIEVEMENTS[i][achievementName]);
		}

		++j;
		g_AchievementInt[id][i - k] = i;

		num_to_str(j, sPosition, charsmax(sPosition));
		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_AchievementPage[id][iAchievementClassId] = min(g_AchievementPage[id][iAchievementClassId], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_AchievementPage[id][iAchievementClassId]);
}

public menu__Achievements(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iAchievementClassId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS_ID];
	new iItemId;

	player_menu_info(id, iItemId, iItemId, g_AchievementPage[id][iAchievementClassId]);

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
		clientPrintColor(id, _, "Este logro está deshabilitado");

		showMenu__Achievements(id);
		return PLUGIN_HANDLED;
	}

	g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN] = iItemId;
	g_LastAchUnlockedPage = g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN];
	g_LastAchUnlockedClass = iAchievementClassId;

	showMenu__AchievementInfo(id, g_AchievementInt[id][g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN]]);
	return PLUGIN_HANDLED;
}

public showMenu__AchievementInfo(const id, const achievement) {
	oldmenu_create("\y%s - %s", "menu__AchievementInfo", __ACHIEVEMENTS[achievement][achievementName], ((!g_Achievement[id][achievement]) ? "\r(NO COMPLETADO)" : "\y(COMPLETADO)"));

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
	oldmenu_additem(-1, -1, "\r - \y+%d\w SALDO", __ACHIEVEMENTS[achievement][achievementReward]);

	if(g_Achievement[0][achievement]) {
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_AchievementUnlocked[0][achievement], 1));
		oldmenu_additem(-1, -1, "\r - \wPor el usuario\r:\y %s^n", g_AchievementName[0][achievement]);
	} else if(g_Achievement[id][achievement]) {
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_AchievementUnlocked[id][achievement], 1));

		oldmenu_additem(1, 1, "^n\r1.\w Mostrar logro en el Chat");
	} else {
		oldmenu_additem(-1, -1, "^n\d1. Mostrar logro en el Chat");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__AchievementInfo(const id, const item) {
	if(!item) {
		showMenu__Achievements(id);
		return;
	}

	new iAchievementClassId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS_ID];
	new iAchievementId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN];

	switch(item) {
		case 1: {
			if(g_Achievement[id][g_AchievementInt[id][iAchievementId]]) {
				if(g_AccountId[id] == 1 || g_AchievementTimeLink[id] < get_gametime()) {
					clientPrintColor(0, _, "!t%s!y muestra su logro !g%s !t[Z]!y conseguido el !g%s!y", g_PlayerName[id], __ACHIEVEMENTS[g_AchievementInt[id][iAchievementId]][achievementName], getUnixToTime(g_AchievementUnlocked[id][g_AchievementInt[id][iAchievementId]], 1));

					g_AchievementTimeLink[id] = get_gametime() + 15.0;
					g_LastAchUnlockedPage = iAchievementId;
					g_LastAchUnlockedClass = iAchievementClassId;
					g_LastAchUnlocked = g_AchievementInt[id][iAchievementId];
				}
			}

			showMenu__AchievementInfo(id, g_AchievementInt[id][iAchievementId]);
		}
	}
}

public clcmd__Health(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	new sArg1[32];
	read_argv(1, sArg1, charsmax(sArg1));
	
	if(sArg1[0] != '@') {
		if(equal(sArg1, "-100")) { // Apuntas a alguien y le das 'x' cantidad de vida
			new iTarget;
			new iBody;
			
			get_user_aiming(id, iTarget, iBody);
			
			if(!g_IsAlive[iTarget]) {
				return PLUGIN_HANDLED;
			}
			
			new sArg2[8];
			new iHealth;
			
			read_argv(2, sArg2, charsmax(sArg2));
			iHealth = str_to_num(sArg2);
			
			set_user_health(iTarget, iHealth);
			g_Health[iTarget] = iHealth;
		} else { // Comando normal, ingresas el nombre y le seteas la vida que queres
			new iTarget;
			iTarget = cmd_target(id, sArg1, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));
			
			if(!iTarget) {
				return PLUGIN_HANDLED;
			}
			
			if(read_argc() < 3) {
				consolePrint(id, "Uso: zp_health <nombre> <cantidad>");
				return PLUGIN_HANDLED;
			}
			
			new sArg2[8];
			new iHealth;
			
			read_argv(2, sArg2, charsmax(sArg2));
			iHealth = str_to_num(sArg2);
			
			set_user_health(iTarget, iHealth);
			g_Health[iTarget] = iHealth;
		}
	} else { // Le das vida a todos los jugadores vivos
		if(read_argc() < 3) {
			consolePrint(id, "Uso: zp_health <nombre> <cantidad>");
			return PLUGIN_HANDLED;
		}

		new sArg2[8];
		new iHealth;
		new i;
		
		read_argv(2, sArg2, charsmax(sArg2));
		iHealth = str_to_num(sArg2);
		
		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}
			
			clientPrintColor(i, _, "%s te editó la vida y ahora tenés !g%d!y de vida", g_PlayerName[id], iHealth);
			
			set_user_health(i, iHealth);
			g_Health[i] = iHealth;
		}
	}
	
	return PLUGIN_HANDLED;
}

public clcmd__Radio1(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	if(g_LastAchUnlocked != -1) {
		g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN] = g_LastAchUnlockedPage;
		g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS_ID] = g_LastAchUnlockedClass;
		g_AchievementInt[id][g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN]] = g_LastAchUnlocked;

		showMenu__AchievementInfo(id, g_AchievementInt[id][g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN]]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Radio3(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public task__RemoveImmunity(const task_id) {
	new iId = (task_id - TASK_IMMUNITY);

	if(!g_IsAlive[iId]) {
		return;
	}

	g_Immunity[iId] = 0;
}

public getUserLevelTotal(const id) {
	new iLevelTotal = (g_Reset[id] * MAX_LEVEL) + g_Level[id];

	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING) {
		return 1;
	}

	return iLevelTotal;
}

public task__ModeGruntAiming(const task_id) {
	new iId = (task_id - TASK_GRUNT_AIMING);

	if(!g_IsAlive[iId] || !g_ModeGrunt_RewardGlobal) {
		return;
	}

	new sExp[16];
	addDot(g_ModeGrunt_Reward[iId], sExp, charsmax(sExp));

	set_hudmessage(64, 64, 64, g_UserOptions_Hud[iId][HUD_TYPE_COMBO][0], g_UserOptions_Hud[iId][HUD_TYPE_COMBO][1], g_UserOptions_HudEffect[iId][HUD_TYPE_COMBO], 0.0, 5.0, 0.0, 0.0, -1);
	ShowSyncHudMsg(iId, g_HudSync_Combo, "Estás ganando +%s XP", sExp);

	if(g_Mode == MODE_GRUNT && !g_ModeGrunt_NoDamage) {
		if(g_SpecialMode[iId] != MODE_GRUNT) {
			new iReward;
			new iTotalReward;

			if(getZombies() == 2) {
				iReward += ((!g_ModeGrunt_Flash[iId]) ? 30000 : 60000) * (g_Reset[iId] + 1);
			} else {
				iReward += ((!g_ModeGrunt_Flash[iId]) ? 15000 : 22500) * (g_Reset[iId] + 1);
			}

			iTotalReward = (g_ModeGrunt_Reward[iId] + iReward);

			if(iTotalReward < 0 || iTotalReward > MAX_XP) {
				if(iTotalReward < 0) {
					g_ModeGrunt_Reward[iId] = MAX_XP;
				}

				addXP(iId, g_ModeGrunt_Reward[iId]);
				g_ModeGrunt_Reward[iId] = 0;
			} else {
				g_ModeGrunt_Reward[iId] += iReward;
			}
		} else {
			g_ModeGrunt_Reward[iId] -= g_ModeGrunt_RewardGlobal;

			if(g_ModeGrunt_Reward[iId] < 0) {
				g_ModeGrunt_Reward[iId] = 0;
			}
		}

		new iTarget;
		new iBody;
		
		get_user_aiming(iId, iTarget, iBody, 999);
		
		if(!isPlayerValidAlive(iTarget)) {
			set_task(0.2, "task__ModeGruntAiming", iId + TASK_GRUNT_AIMING);
			return;
		}
		
		if(g_SpecialMode[iId] != MODE_GRUNT) {
			if(g_SpecialMode[iTarget] == MODE_GRUNT) {
				set_user_rendering(iId, kRenderFxGlowShell, 64, 64, 64, kRenderNormal, 4);
				
				if((g_Health[iId] - 40) >= 1) {
					set_user_health(iId, (g_Health[iId] - 40));
					--g_Health[iId];

					emitSound(iId, CHAN_VOICE, __SOUND_ARMOR_HIT);
				} else {
					ExecuteHam(Ham_TakeDamage, iId, iTarget, iTarget, 40.0, DMG_CRUSH);
				}

				remove_task(iId + TASK_GRUNT_GLOW);
				set_task(0.25, "task__RemoveGruntGlow", iId + TASK_GRUNT_GLOW);
			}
		} else {
			set_user_rendering(iTarget, kRenderFxGlowShell, 64, 64, 64, kRenderNormal, 4);

			if((g_Health[iTarget] - 40) >= 1) {
				set_user_health(iTarget, (g_Health[iTarget] - 40));
				--g_Health[iTarget];

				emitSound(iTarget, CHAN_VOICE, __SOUND_ARMOR_HIT);
			} else {
				ExecuteHam(Ham_TakeDamage, iTarget, iId, iId, 40.0, DMG_CRUSH);
			}

			remove_task(iTarget + TASK_GRUNT_GLOW);
			set_task(0.25, "task__RemoveGruntGlow", iTarget + TASK_GRUNT_GLOW);
		}
	}

	remove_task(iId + TASK_GRUNT_AIMING);
	set_task(0.2, "task__ModeGruntAiming", iId + TASK_GRUNT_AIMING);
}

public task__RemoveGruntScreenFade(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsAlive[i]) {
			continue;
		}

		turnOffFlashlight(i);
		g_ModeGrunt_Flash[i] = 0;

		if(g_SpecialMode[i] == MODE_GRUNT) {
			continue;
		}

		g_Speed[i] = 1.0;
		set_user_gravity(i, 1.25);

		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);
	}

	g_ModeGrunt_NoDamage = 0;

	message_begin(MSG_ONE, g_Message_ScreenFade, _, id);
	write_short(UNIT_SECOND);
	write_short(0);
	write_short(FFADE_IN);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
}

public task__RemoveGruntGlow(const task_id) {
	new iId = (task_id - TASK_GRUNT_GLOW);

	if(!g_IsAlive[iId]) {
		return;
	}

	set_user_rendering(iId);
}

public task__PowerGrunt() {
	new const __LETTERS_LIGHT[] = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 'q', 'p', 'o', 'n', 'm', 'l', 'k', 'j', 'i', 'h', 'g', 'f', 'e', 'd', 'c', 'b', 'a'
	};

	g_Lights[0] = __LETTERS_LIGHT[g_ModeGrunt_Power];
	changeLights();

	++g_ModeGrunt_Power;

	if(g_ModeGrunt_Power == 35) {
		g_Lights[0] = 'a';

		changeLights();
		return;
	}

	set_task(0.2, "task__PowerGrunt");
}

public findEntByOwner(const owner, const class_name[]) {
	new iEnt = -1;
	while((iEnt = find_ent_by_class(iEnt, class_name)) && entity_get_edict(iEnt, EV_ENT_owner) != owner) {}

	return iEnt;
}

// public fwd__UpdateClientDataPost(const id, const sendweapons, const handle) {
	// if(!g_IsAlive[id]) {
		// return FMRES_IGNORED;
	// }

	// if((g_SpecialMode[id] == MODE_NEMESIS || g_SpecialMode[id] == MODE_ANNIHILATOR) && g_CurrentWeapon[id] == CSW_AK47) {
		// set_cd(handle, CD_flNextAttack, (get_gametime() + 0.001));
	// }

	// return FMRES_IGNORED;
// }

public task__StartModeArmageddon() {
	if(g_ModeArmageddon_Notice > 3) {
		remove_task(TASK_MODE_ARMAGEDDON);
		return;
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsAlive[i]) {
			continue;
		}

		g_Speed[i] -= 25.0;
		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);
	}

	switch(g_ModeArmageddon_Notice) {
		case 0: {
			showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, random_num(0, 1), 4.9, "Durante décadas..");
		} case 1: {
			showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, random_num(0, 1), 4.9, ".. se enfrentaron..");
		} case 2: {
			showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, random_num(0, 1), 4.9, ".. y hoy llegó el final...");
		} case 3: {
			g_ModeArmageddon_Init = 0;

			showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, random_num(0, 1), 10.0, "¡ARMAGEDDON!");

			new j = random_num(0, 1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				randomSpawn(i);

				if(j) {
					if(getUserTeam(i) == TEAM_TERRORIST) {
						humanMe(i, .survivor=1);
					} else {
						zombieMe(i, .nemesis=1);
					}
				} else {
					if(getUserTeam(i) == TEAM_TERRORIST) {
						zombieMe(i, .nemesis=1);
					} else {
						humanMe(i, .survivor=1);
					}
				}

				message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, i);
				write_short(UNIT_SECOND);
				write_short(0);
				write_short(FFADE_IN);
				write_byte(g_UserOptions_Color[i][COLOR_TYPE_NVISION][0]);
				write_byte(g_UserOptions_Color[i][COLOR_TYPE_NVISION][1]);
				write_byte(g_UserOptions_Color[i][COLOR_TYPE_NVISION][2]);
				write_byte(0);
				message_end();
			}
		}
	}

	++g_ModeArmageddon_Notice;

	remove_task(TASK_MODE_ARMAGEDDON);
	set_task(4.9, "task__StartModeArmageddon", TASK_MODE_ARMAGEDDON);
}

showDHUDMessage(const id, const color_r=255, const color_g=255, const color_b=255, const Float:pos_x=-1.0, const Float:pos_y=-1.0, const effect=0, const Float:time=0.1, const message[], any:...) {
	static sMessage[MAX_FMT_LENGTH];
	vformat(sMessage, charsmax(sMessage), message, 10);

	if(id) {
		clearDHUD(id);

		set_dhudmessage(color_r, color_g, color_b, pos_x, pos_y, effect, 0.0, time, 1.0, 1.0);
		show_dhudmessage(id, sMessage);
	} else {
		static sPlayers[32];
		static iNum;

		get_players(sPlayers, iNum, "ch");

		if(iNum) {
			static i;
			static iUserId;

			iUserId = 0;

			for(i = 0; i < iNum; ++i) {
				iUserId = sPlayers[i];

				clearDHUD(iUserId);

				set_dhudmessage(color_r, color_g, color_b, pos_x, pos_y, effect, 0.0, time, 1.0, 1.0);
				show_dhudmessage(iUserId, sMessage);
			}
		}
	}
}

clearDHUD(const id, const all_channel=1) {
	new i;
	for(i = 0; i < ((all_channel) ? 8 : 7); ++i) {
		set_dhudmessage(000, 000, 000, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0);
		show_dhudmessage(id, "");
	}
}

public checkModeMegaArmageddonTwo(const survivor) {
	if(g_ModeMA_AllZombies || g_ModeMA_AllHumans)  {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}

			if(g_ModeMA_Reward[i] == 0 || g_ModeMA_Reward[i] == 2) {
				continue;
			}

			if(g_ModeMA_AllZombies && g_Zombie[i]) {
				setAchievement(i, MA_KILL_ALL_HUMANS);
			} else if(g_ModeMA_AllHumans && !g_Zombie[i]) {
				setAchievement(i, MA_KILL_ALL_ZOMBIES);
			}
		}
	}

	new iArgs[1];
	iArgs[0] = survivor;

	set_task(2.0, "task__ModeMegaArmageddonFix", _, iArgs, sizeof(iArgs));
}

public endModeMegaArmageddon(const humans) {
	new iRandom = random_num(10, 25);
	new iRandomLose = 0;
	new i;

	if(!((iRandom % 2) == 0)) {
		++iRandom;
	}

	iRandomLose = (iRandom / 2);

	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_PLAYING) {
			continue;
		}

		if(g_ModeMA_Reward[i] == 0) {
			clientPrintColor(i, _, "No recibiste recompensa porque no participaste del Mega Armageddon");
			continue;
		} else if(g_ModeMA_Reward[i] == 2) {
			clientPrintColor(i, _, "No recibiste recompensa porque entraste en la segunda fase del Mega Armageddon");
			continue;
		}

		if(humans && !g_Zombie[i]) {
			g_Points[i][P_HUMAN] += iRandom;
			g_Points[i][P_ZOMBIE] += iRandom;

			clientPrintColor(i, _, "Ganaste !g%d pH!y y !g%d pZ!y por haber sobrevivido en el !tMEGA ARMAGEDDON!y", iRandom, iRandom);

			++g_Stats[i][STAT_MA_WINS];

			setAchievement(i, MA_WIN_H);

			continue;
		}

		if(humans && g_Zombie[i]) {
			g_Points[i][P_HUMAN] += iRandomLose;
			g_Points[i][P_ZOMBIE] += iRandomLose;
			
			clientPrintColor(i, _, "Ganaste !g%d pH!y y !g%d pZ!y por haber participado en el !tMEGA ARMAGEDDON!y", iRandomLose, iRandomLose);
		}

		if(!humans && g_Zombie[i]) {
			g_Points[i][P_HUMAN] += iRandom;
			g_Points[i][P_ZOMBIE] += iRandom;

			clientPrintColor(i, _, "Ganaste !g%d ph!y y !g%d pZ!y por haber sobrevivido en el !tMEGA ARMAGEDDON!y", iRandom, iRandom);

			++g_Stats[i][STAT_MA_WINS];

			setAchievement(i, MA_WIN_Z);

			continue;
		}

		if(!humans && !g_Zombie[i]) {
			g_Points[i][P_HUMAN] += iRandomLose;
			g_Points[i][P_ZOMBIE] += iRandomLose;

			clientPrintColor(i, _, "Ganaste !g%d pH!y y !g%d pZ!y por haber participado en el !tMEGA ARMAGEDDON!y", iRandomLose, iRandomLose);
			continue;
		}
	}

	set_cvar_num("mp_round_infinite", 0);
}

public task__ModeMegaArmageddonFix(const args[]) {
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			continue;
		}

		if(g_ModeMA_Reward[i] == 0 || (args[0] && g_ModeMA_Reward[i] == 2)) {
			clientPrintColor(i, _, "No reviviste porque no participaste de la fase inicial del Mega Armageddon");
			continue;
		}

		iTeam = getUserTeam(i);

		if(iTeam == TEAM_UNASSIGNED || iTeam == TEAM_SPECTATOR) {
			continue;
		}

		if(args[0] && !g_Zombie[i]) {
			ExecuteHamB(Ham_CS_RoundRespawn, i);
		} else if(!args[0] && g_Zombie[i]) {
			ExecuteHamB(Ham_CS_RoundRespawn, i);
		}
	}
}

public gunGameBestUsers() {
	new iMax = 0;
	new iMaxId[3] = {0, 0, 0};
	new iTemp;
	new i;
	new j;

	for(j = 0; j < 3; ++j) {
		iMax = 0;

		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_PLAYING) {
				continue;
			}

			if(g_ModeGG_Level[i] > iMax && i != iMaxId[0] && i != iMaxId[1] && i != iMaxId[2]) {
				iMax = g_ModeGG_Level[i];
				iMaxId[j] = i;
			}
		}
	}

	if(g_ModeGG_Level[iMaxId[1]] > g_ModeGG_Level[iMaxId[0]]) {
		iTemp = iMaxId[0];
		iMaxId[0] = iMaxId[1];
		iMaxId[1] = iTemp;
	}

	if(g_ModeGG_Level[iMaxId[2]] > g_ModeGG_Level[iMaxId[0]]) {
		iTemp = iMaxId[0];
		iMaxId[0] = iMaxId[2];
		iMaxId[2] = iTemp;
	}

	if(g_ModeGG_Level[iMaxId[2]] > g_ModeGG_Level[iMaxId[1]]) {
		iTemp = iMaxId[1];
		iMaxId[1] = iMaxId[2];
		iMaxId[2] = iTemp;
	}

	formatex(g_ModeGG_Stats, charsmax(g_ModeGG_Stats), "%s - %d^n%s - %d^n%s - %d", g_PlayerName[iMaxId[0]], g_ModeGG_Level[iMaxId[0]], g_PlayerName[iMaxId[1]], g_ModeGG_Level[iMaxId[1]], g_PlayerName[iMaxId[2]], g_ModeGG_Level[iMaxId[2]]);
}

public gunGameGiveWeapons(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	new iLevel = g_ModeGG_Level[id];

	if(g_ModeGG_Type == GUNGAME_CLASSIC) {
		give_item(id, "weapon_knife");
		give_item(id, __GUNGAME_WEAPONS_CLASSIC[iLevel]);

		if(__GUNGAME_WEAPONS_CLASSIC_CSW[iLevel] != 0) {
			if(__GUNGAME_WEAPONS_CLASSIC_CSW[iLevel] != CSW_HEGRENADE) {
				ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[__GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]], __AMMO_TYPE[__GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]], __MAX_BPAMMO[__GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]]);
				replaceWeaponModels(id, __GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]);

				g_ModeGGCrazy_HeLevel[id] = 0;
			} else {
				cs_set_user_bpammo(id, CSW_HEGRENADE, 200);
				
				g_ModeGGCrazy_HeLevel[id] = 1;
			}
		}
	} else {
		if(g_ModeGG_Type == GUNGAME_CRAZY) {
			iLevel = g_ModeGGCrazy_Level[id];
		}

		give_item(id, __GUNGAME_WEAPONS[iLevel]);

		if(__GUNGAME_WEAPONS_CSW[iLevel] != 0) {
			if(__GUNGAME_WEAPONS_CSW[iLevel] != CSW_HEGRENADE) {
				ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[__GUNGAME_WEAPONS_CSW[iLevel]], __AMMO_TYPE[__GUNGAME_WEAPONS_CSW[iLevel]], __MAX_BPAMMO[__GUNGAME_WEAPONS_CSW[iLevel]]);
				replaceWeaponModels(id, __GUNGAME_WEAPONS_CSW[iLevel]);

				g_ModeGGCrazy_HeLevel[id] = 0;
			} else {
				cs_set_user_bpammo(id, CSW_HEGRENADE, 200);

				g_ModeGGCrazy_HeLevel[id] = 1;
			}
		}
	}
}

public megaGunGameAddKill(const id) {
	++g_ModeGG_Kills[id];

	if(g_ModeGG_Kills[id] == 2) {
		g_ModeGG_Kills[id] = 0;
		++g_ModeGG_Level[id];

		if(g_ModeGG_Level[id] != 27) {
			if(g_ModeGG_Level[id] == 53) {
				g_ModeGG_End = 1;

				set_cvar_num("mp_round_infinite", 0);
				set_cvar_num("mp_freeforall", 0);

				megaGunGameGiveRewards(id, 1);
				return;
			}

			playSound(id, __SOUND_ROUND_GUNGAME);

			strip_user_weapons(id);
			give_item(id, __MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[id]]);

			if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != 0) {
				if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != CSW_HEGRENADE) {
					ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], __AMMO_TYPE[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]]);
					replaceWeaponModels(id, __MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]);
				} else {
					cs_set_user_bpammo(id, CSW_HEGRENADE, 200);
				}
			}

			gunGameBestUsers();
		} else {
			if(g_ModeMGG_Block) {
				return;
			} else if(g_ModeMGG_Phase) {
				playSound(id, __SOUND_ROUND_GUNGAME);

				strip_user_weapons(id);
				give_item(id, __MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[id]]);

				if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != 0) {
					if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != CSW_HEGRENADE) {
						ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], __AMMO_TYPE[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]]);
						replaceWeaponModels(id, __MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]);
					} else {
						cs_set_user_bpammo(id, CSW_HEGRENADE, 200);
					}
				}

				gunGameBestUsers();
				return;
			}

			g_ModeMGG_Block = 1;
			g_ModeMGG_CountDown = 10;

			megaGunGameGiveRewards(id, 0);

			remove_task(TASK_MODE_MEGA_GUNGAME);
			set_task(5.0, "task__ModeMegaGunGameCountDown", TASK_MODE_MEGA_GUNGAME);
		}
	}
}

public megaGunGameGiveRewards(const winner_id, const phase_id) {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_PLAYING) {
			continue;
		}

		clientPrintColor(i, _, "Ganaste !g%d pH!y, !g%d pZ!y, !g%d pL!y y !g%d SALDO!y", g_ModeGG_Level[i], g_ModeGG_Level[i], g_ModeGG_Level[i], g_ModeGG_Level[i]);

		g_Points[i][P_HUMAN] += g_ModeGG_Level[i];
		g_Points[i][P_ZOMBIE] += g_ModeGG_Level[i];
		g_Points[i][P_LEGACY] += g_ModeGG_Level[i];
		g_Points[i][P_MONEY] += g_ModeGG_Level[i];

		if(g_IsAlive[i]) {
			user_kill(i, 1);
		}
	}

	if(!phase_id) {
		clientPrintColor(0, _, "El usuario !t%s!y ganó !g1 DIAMANTE!y por ganar la primer mitad del Mega GunGame", g_PlayerName[winner_id]);
		++g_Points[winner_id][P_DIAMONDS];
	} else {
		clientPrintColor(0, _, "El usuario !t%s!y ganó !g2 DIAMANTES!y por ganar el Mega GunGame", g_PlayerName[winner_id]);
		g_Points[winner_id][P_DIAMONDS] += 2;
	}
}

public task__RemoveImmunityGunGame(const task_id) {
	new iId = (task_id - TASK_IMMUNITY_GG);

	if(!g_IsAlive[iId]) {
		return;
	}

	g_ModeGG_Immunity[iId] = 0;
	set_user_rendering(iId);
}

public task__ModeMegaGunGameCountDown() {
	if(!g_ModeMGG_CountDown) {
		remove_task(TASK_MODE_MEGA_GUNGAME);

		g_ModeMGG_Phase = 1;
		g_ModeMGG_Block = 0;

		g_Lights[0] = __MEGA_GUNGAME_LIGHTS[g_ModeMGG_CountDown];
		changeLights();

		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}

			give_item(i, __MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[i]]);

			if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]] != 0) {
				if(__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]] != CSW_HEGRENADE) {
					ExecuteHamB(Ham_GiveAmmo, i, __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]], __AMMO_TYPE[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]], __MAX_BPAMMO[__MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]]);
				} else {
					cs_set_user_bpammo(i, CSW_HEGRENADE, 200);
				}
			}

			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);
		}

		clientPrint(0, print_center, "¡GO!");
		return;
	}

	g_Lights[0] = __MEGA_GUNGAME_LIGHTS[g_ModeMGG_CountDown];
	changeLights();

	clientPrint(0, print_center, "¡FASE FINAL EN %d SEGUNDO%s!", g_ModeMGG_CountDown, ((g_ModeMGG_CountDown != 1) ? "S" : ""));

	--g_ModeMGG_CountDown;

	set_task(1.0, "task__ModeMegaGunGameCountDown", TASK_MODE_MEGA_GUNGAME);
}

public task__MegaArmageddonEffect(const id) {
	if(g_IsAlive[id]) {
		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
		write_short(UNIT_SECOND * 3);
		write_short(UNIT_SECOND * 3);
		write_short(FFADE_IN);
		write_byte(random_num(0, 255));
		write_byte(random_num(0, 255));
		write_byte(random_num(0, 255));
		write_byte(255);
		message_end();
	}
}

public task__MegaArmageddonBlackFade(const id) {
	if(g_IsAlive[id]) {
		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
		write_short(UNIT_SECOND * 10);
		write_short(UNIT_SECOND * 10);
		write_short(FFADE_IN);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
}

public task__StartModeMegaArmageddon() {
	showDHUDMessage(0, random(256), random(256), random(256), -1.0, -1.0, random_num(0, 1), 10.0, "¡MEGA ARMAGEDDON!");

	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND);
	write_short(UNIT_SECOND);
	write_short(FFADE_IN);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(150);
	message_end();

	new iUsersAlive = getUsersAlive();
	new iMaxHumans;
	new iHumans;
	new iId;
	new iAlreadyChoosen[MAX_PLAYERS + 1];
	new i;

	iMaxHumans = (iUsersAlive / 2);
	iHumans = 0;

	while(iHumans < iMaxHumans) {
		iId = getRandomAlive(random_num(1, iUsersAlive));

		if(iAlreadyChoosen[iId]) {
			continue;
		}

		iAlreadyChoosen[iId] = 1;
		++iHumans;
	}

	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsAlive[i]) {
			continue;
		}

		randomSpawn(i);

		if(iAlreadyChoosen[i]) {
			if(getUserTeam(i) != TEAM_CT) {
				setUserTeam(i, TEAM_CT);
			}

			buyCuaternaryWeapon(i, g_WeaponCuaternary_Selection[i]);
		} else {
			zombieMe(i);
		}
	}
}

public task__ModeDuelFinal() {
	new iPosition[MAX_PLAYERS + 1];
	new iHumans = 0;
	new i;
	new j;

	if(g_ModeDuelFinal == DF_QUARTER || g_ModeDuelFinal == DF_SEMIFINAL || g_ModeDuelFinal == DF_FINAL) {
		new iTemp = 0;

		for(i = 1; i <= MaxClients; ++i) {
			iPosition[i] = i;
		}

		for(i = 1; i < MAX_PLAYERS; ++i) {
			for(j = (i + 1); j < (MAX_PLAYERS + 1); ++j) {
				if(g_ModeDuelFinal_Kills[j] > g_ModeDuelFinal_Kills[i]) {
					iTemp = g_ModeDuelFinal_Kills[j];
					g_ModeDuelFinal_Kills[j] = g_ModeDuelFinal_Kills[i];
					g_ModeDuelFinal_Kills[i] = iTemp;

					iTemp = iPosition[j];
					iPosition[j] = iPosition[i];
					iPosition[i] = iTemp;
				}
			}
		}
	}

	switch(g_ModeDuelFinal) {
		case DF_QUARTER: {
			g_Lights[0] = 'f';

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡DUELO FINAL%s!^nCUARTOS DE FINAL", g_ModeDuelFinal_TypeName);
			playSound(0, __SOUND_ROUND_SPECIAL);

			for(i = 1; i <= MaxClients; ++i) {
				if(iHumans == 8) {
					break;
				}

				if(g_IsConnected[iPosition[i]] && g_AccountStatus[iPosition[i]] == STATUS_PLAYING && !g_IsAlive[iPosition[i]]) {
					ExecuteHamB(Ham_CS_RoundRespawn, iPosition[i]);
					++iHumans;
				}
			}
		} case DF_SEMIFINAL: {
			g_Lights[0] = 'd';

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡DUELO FINAL%s!^nSEMIFINAL", g_ModeDuelFinal_TypeName);
			playSound(0, __SOUND_ROUND_SPECIAL);

			for(i = 1; i <= MaxClients; ++i) {
				if(iHumans == 4) {
					break;
				}

				if(g_IsConnected[iPosition[i]] && g_AccountStatus[iPosition[i]] == STATUS_PLAYING && !g_IsAlive[iPosition[i]]) {
					ExecuteHamB(Ham_CS_RoundRespawn, iPosition[i]);
					++iHumans;
				}
			}
		} case DF_FINAL: {
			g_Lights[0] = 'b';

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡DUELO FINAL%s!^nFINAL", g_ModeDuelFinal_TypeName);
			playSound(0, __SOUND_ROUND_SPECIAL);

			for(i = 1; i <= MaxClients; ++i) {
				if(iHumans == 2) {
					break;
				}

				if(g_IsConnected[iPosition[i]] && g_AccountStatus[iPosition[i]] == STATUS_PLAYING && !g_IsAlive[iPosition[i]]) {
					ExecuteHamB(Ham_CS_RoundRespawn, iPosition[i]);
					++iHumans;
				}
			}
		} case DF_FINISH: {
			g_ModeDuelFinal_Type = 0;
			g_ModeDuelFinal_TypeOnlyHead = 0;
			g_ModeDuelFinal_TypeName[0] = EOS;

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsConnected[i]) {
					continue;
				}

				g_ModeDuelFinal_KillsKnife[i] = 0;
				g_ModeDuelFinal_KillsAwp[i] = 0;
				g_ModeDuelFinal_KillsHE[i] = 0;
				g_ModeDuelFinal_KillsOnlyHead[i] = 0;

				if(g_AccountStatus[i] < STATUS_PLAYING) {
					continue;
				}

				giveRewardInDuelFinal(i, g_ModeDuelFinal_KillsTotal[i]);
			}

			set_cvar_num("mp_round_infinite", 0);
			set_cvar_num("mp_freeforall", 0);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				++g_Stats[i][STAT_DF_WINS];

				if(g_Stats[i][STAT_DF_WINS] == 1) {
					setAchievement(i, MI_PRIMER_DUELO);
				} else if(g_Stats[i][STAT_DF_WINS] == 5) {
					setAchievement(i, VAMOS_BIEN);
				} else if(g_Stats[i][STAT_DF_WINS] == 10) {
					setAchievement(i, DEMASIADO_FACIL);
				}

				user_kill(i, 1);
				break;
			}
		}
	}

	changeLights();

	for(i = 1; i <= MaxClients; ++i) {
		g_ModeDuelFinal_Kills[i] = 0;
	}
}

public giveRewardInDuelFinal(const id, const duel_kills) {
	if(!duel_kills) {
		clientPrintColor(id, _, "No recibiste ganancias porque no has matado a ningún humano");
		return;
	}

	new iReward = (duel_kills * REWARD_XP_IN_DUEL_FINAL);
	new sReward[16];

	if(iReward < 0 || iReward > MAX_XP) {
		iReward = MAX_XP;
	}

	addXP(id, iReward);

	addDot(iReward, sReward, charsmax(sReward));
	clientPrintColor(id, _, "Ganaste !g%s XP!y por matar a !g%d humano%s!y", sReward, g_ModeDuelFinal_KillsTotal[id], ((g_ModeDuelFinal_KillsTotal[id] != 1) ? "s" : ""));

	new iRandom = random_num(2, 6);

	if(duel_kills > iRandom) {
		if((g_Level[id] + duel_kills) >= MAX_LEVEL) {
			g_Level[id] = MAX_LEVEL;

			clientPrintColor(id, _, "Has superado el nivel máximo a base del bonus del modo !tDUELO FINAL!y. Se te otorgó el nivel máximo para realizar el !gsiguiente Reset!y");

			checkXPEquation(id);
		} else {
			g_Level[id] += duel_kills;

			clientPrintColor(id, _, "Ganaste un bonus de !g%d nivel%s!y por haber matado !g%d humano%s!y", duel_kills, ((duel_kills != 1) ? "es" : ""), g_ModeDuelFinal_KillsTotal[id], ((g_ModeDuelFinal_KillsTotal[id] != 1) ? "s" : ""));

			checkXPEquation(id);
		}
	}
}

public getRewardInConversion(const id, const percent) {
	new iConversion = (xpThisLevel(id, g_Level[id]) - xpThisLevelRest1(id, g_Level[id]));
	new iReward = ((iConversion * percent) / 100);

	if(iReward < 0 || iReward > MAX_XP) {
		iReward = MAX_XP;
	}

	return iReward;
}

public clcmd__Invis(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING) {
		return PLUGIN_HANDLED;
	}

	switch(g_UserOptions_Invis[id]) {
		case 0: {
			g_UserOptions_Invis[id] = 1;
			clientPrintColor(id, _, "Ahora tus compañeros se volvieron !gInvisibles!y");
		} case 1: {
			g_UserOptions_Invis[id] = 2;
			clientPrintColor(id, _, "Ahora tus compañeros se volvieron !gInvisibles!y a excepción de tus compañeros de !gGrupo!y");
		} case 2: {
			g_UserOptions_Invis[id] = 0;
			clientPrintColor(id, _, "Ahora tus compañeros se volvieron !gVisibles!y");
		}
	}

	return PLUGIN_HANDLED;
}

public logToFileModes(const id, const mode, const next_mode) {
	new const __LOGFILE_DIR[] = "addons/amxmodx/logs/zombie_plague";
	new sDate[16];
	new sTime[16];
	new sLogDir[64];
	new sLogBuffer[256];

	get_time("%Y-%m-%d", sDate, charsmax(sDate));
	get_time("%H:%M:%S", sTime, charsmax(sTime));
	formatex(sLogDir, charsmax(sLogDir), "%s/%s_modes.log", __LOGFILE_DIR, sDate);
	
	if(next_mode) {
		formatex(sLogBuffer, charsmax(sLogBuffer), "Hora <%s> ::: Próximo modo <%s> - Admin <%s>", sTime, __MODES[mode][modeName], g_PlayerName[id]);
	} else {
		formatex(sLogBuffer, charsmax(sLogBuffer), "Hora <%s> ::: Modo <%s> - Admin <%s>", sTime, __MODES[mode][modeName], g_PlayerName[id]);
	}

	if(!dir_exists(__LOGFILE_DIR)) {
		mkdir(__LOGFILE_DIR);
	}

	if(!file_exists(sLogDir)) {
		new iFile = fopen(sLogDir, "wt");
		fclose(iFile);
	}

	write_file(sLogDir, sLogBuffer);
}

public getUserAura(const id) {
	return ((g_Aura[id][3]) ? 1 : 0);
}

setUserAura(const id, const r=0, const g=0, const b=0, const radius=0) {
	if(!r && !g && !b && !radius) {
		g_Aura[id][0] = 0;
		g_Aura[id][1] = 0;
		g_Aura[id][2] = 0;
		g_Aura[id][3] = 0;

		return;
	}

	g_Aura[id][0] = r;
	g_Aura[id][1] = g;
	g_Aura[id][2] = b;
	g_Aura[id][3] = radius;
}

public task__ConvertZombie(const task_id) {
	new iId = (task_id - TASK_CONVERT_ZOMBIE);

	if(!g_IsAlive[iId] || g_Zombie[iId] || g_LastHuman[iId] || g_Mode != MODE_INFECTION) {
		return;
	}

	if(random_num(1, 10) == 5 || random_num(1, 10) == 7) {
		g_ConvertZombie[iId] = 1;

		clientPrint(iId, print_center, "¡TE ESTAS CONVIRTIENDO EN ZOMBIE!");
		emitSound(iId, CHAN_VOICE, __SOUND_ZOMBIE_MADNESS);

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iId);
		write_short(UNIT_SECOND * 2);
		write_short(UNIT_SECOND * 2);
		write_short(FFADE_IN);
		write_byte(0);
		write_byte(255);
		write_byte(0);
		write_byte(175);
		message_end();

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, iId);
		write_short(UNIT_SECOND * 7);
		write_short(UNIT_SECOND * 3);
		write_short(UNIT_SECOND * 7);
		message_end();

		set_task(3.0, "task__ConvertZombieStart", iId);
		set_task(6.0, "task__ConvertZombieEnd", iId);
	}
}

public task__ConvertZombieStart(const id) {
	if(!g_IsAlive[id] || g_Zombie[id] || g_LastHuman[id] || g_Mode != MODE_INFECTION) {
		return;
	}

	new vecOrigin[3];
	get_user_origin(id, vecOrigin);

	message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_DLIGHT);
	write_coord(vecOrigin[0]);
	write_coord(vecOrigin[1]);
	write_coord(vecOrigin[2]);
	write_byte(17);
	write_byte(0);
	write_byte(255);
	write_byte(0);
	write_byte(2);
	write_byte(0);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
	write_short(UNIT_SECOND * 2);
	write_short(UNIT_SECOND * 2);
	write_short(FFADE_IN);
	write_byte(0);
	write_byte(255);
	write_byte(0);
	write_byte(235);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, id);
	write_short(UNIT_SECOND * 14);
	write_short(UNIT_SECOND * 5);
	write_short(UNIT_SECOND * 14);
	message_end();

	set_user_rendering(id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 100);
}

public task__ConvertZombieEnd(const id) {
	if(!g_IsAlive[id] || g_Zombie[id] || g_LastHuman[id] || g_Mode != MODE_INFECTION) {
		return;
	}

	g_ConvertZombie[id] = 0;
	zombieMe(id, .reward=1);
}

public clcmd__Discord(const id) {
	if(!g_IsConnected[id]) {
		return PLUGIN_HANDLED;
	}

	clientPrintColor(id, _, "Hay un discord creado específicamente para el !gZOMBIE PLAGUE!y. Invitación:!t https://discord.gg/eKaBarK!y");
	return PLUGIN_HANDLED;
}

public getAlivesT() {
	new iCount = 0;
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			iTeam = getUserTeam(i);

			if(iTeam == TEAM_TERRORIST) {
				++iCount;
			}
		}
	}

	return iCount;
}

public getAlivesCT() {
	new iCount = 0;
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			iTeam = getUserTeam(i);

			if(iTeam == TEAM_CT) {
				++iCount;
			}
		}
	}

	return iCount;
}

public ham__TouchWeaponPre(const weapon, const id) {
	if(!isPlayerValidConnected(id)) {
		return HAM_IGNORED;
	}

	return HAM_SUPERCEDE;
}

public clcmd__Spec(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING) {
		return PLUGIN_HANDLED;
	} else if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		clientPrintColor(id, _, "No tienes acceso a ir a espectador");
		return PLUGIN_HANDLED;
	}

	new TeamName:iTeam = getUserTeam(id);

	if((iTeam == TEAM_SPECTATOR)) {
		clientPrintColor(id, _, "Ya estás de espectador");
		return PLUGIN_HANDLED;
	}

	g_AccountStatus[id] = STATUS_LOGGED;
	g_DeadTimes[id] = 0;
	g_DeadTimes_Reward[id] = 0;

	if(g_IsAlive[id]) {
		new Float:vecOrigin[3];
		get_entvar(id, var_origin, vecOrigin);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_TELEPORT);
		write_coord_f(vecOrigin[0]);
		write_coord_f(vecOrigin[1]);
		write_coord_f(vecOrigin[2]);
		message_end();
	}

	user_silentkill(id, 0);

	setUserTeam(id, TEAM_SPECTATOR);
	return PLUGIN_HANDLED;
}

public ham__UseButtonPre(const button, const id) {
	if(!button || id > MaxClients || !g_IsAlive[id]) {
		return HAM_IGNORED;
	}

	static sTargetName[8];
	entity_get_string(button, EV_SZ_target, sTargetName, charsmax(sTargetName));

	if(equali(sTargetName, "polla")) {
		setAchievement(id, EL_VERDULERO);
	}

	return HAM_IGNORED;
}

public showMenu__Group(const id) {
	oldmenu_create("\yGRUPOS", "menu__Group");

	for(new i = 1; i < 4; ++i) {
		if(g_InGroup[id] && g_GroupId[g_InGroup[id]][i]) {
			oldmenu_additem(i, i, "\r%d.\w %s \y(N: %d)(R: %d)", i, g_PlayerName[g_GroupId[g_InGroup[id]][i]], g_Level[g_GroupId[g_InGroup[id]][i]], g_Reset[g_GroupId[g_InGroup[id]][i]]);
		} else {
			oldmenu_additem(-1, -1, "\dHueco libre . . .");
		}
	}

	oldmenu_additem(8, 8, "^n\r8.\w Invitar usuarios");
	oldmenu_additem(9, 9, "\r9.\w Invitaciones recibidas\r:\y %d^n", g_GroupInvitations[id]);

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Group(const id, const item, const value) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1..3: {
			if(g_MyGroup[id]) {
				if(g_GroupId[g_InGroup[id]][value]) {
					showMenu__GroupInfo(id, value);
				} else {
					showMenu__Group(id);
				}
			} else {
				if(g_GroupId[g_InGroup[id]][value] == id) {
					showMenu__GroupInfo(id, value);
				} else {
					showMenu__Group(id);
				}
			}
		} case 8: {
			if((g_MyGroup[id] && groupFindSlot(g_InGroup[id])) || !g_InGroup[id]) {
				showMenu__GroupInvite(id);
			} else {
				showMenu__Group(id);
			}
		} case 9: {
			if(!g_GroupInvitations[id] || g_InGroup[id]) {
				showMenu__Group(id);
			} else {
				showMenu__GroupInvitations(id);
			}
		}
	}
}

public showMenu__GroupInfo(const id, const user) {
	g_MenuData[id][MENU_DATA_GROUP_INFO] = user;

	if(g_GroupId[g_InGroup[id]][user] != id) {
		oldmenu_create("\yGRUPO", "menu__GroupInfo");

		oldmenu_additem(-1, -1, "\w¿Deseas expulsar a \y%s\w de tu grupo?", g_PlayerName[g_GroupId[g_InGroup[id]][user]]);
		oldmenu_additem(1, 1, "\r1.\w Si");
		oldmenu_additem(2, 2, "\r2.\w No");

		oldmenu_display(id);
	} else {
		oldmenu_create("\yGRUPO", "menu__GroupInfo");

		oldmenu_additem(-1, -1, "\w¿Deseas salir de este grupo?");
		oldmenu_additem(1, 1, "\r1.\w Si");
		oldmenu_additem(2, 2, "\r2.\w No");

		oldmenu_display(id);
	}
}

public menu__GroupInfo(const id, const item) {
	new iGroupInfo = g_MenuData[id][MENU_DATA_GROUP_INFO];

	switch(item) {
		case 1: {
			if(g_AccountId[g_GroupId[g_InGroup[id]][iGroupInfo]] == 1 && id != g_GroupId[g_InGroup[id]][iGroupInfo]) {
				clientPrintColor(id, _, "No puedes expulsar al !tSCRIPTER!y de tu grupo. Eso equivale a un Ban Local :)");
				
				showMenu__Group(id);
				return;
			}

			if(g_InGroup[id]) {
				checkGroup(id, iGroupInfo, g_GroupId[g_InGroup[id]][iGroupInfo]);
			}

			showMenu__Group(id);
		} case 2: {
			showMenu__Group(id);
		}
	}
}

public showMenu__GroupInvite(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPotision[2];

	iMenuId = menu_create("INVITAR USUARIOS AL GRUPO\R", "menu__GroupInvite");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_PLAYING || id == i || g_InGroup[i] || g_GroupInvitationsId[i][id]) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s \y(N: %d)(R: %d)", g_PlayerName[i], g_Level[i], g_Reset[i]);

		sPotision[0] = i;
		sPotision[1] = 0;

		menu_additem(iMenuId, sItem, sPotision);
	}
	
	if(menu_items(iMenuId) < 1) {
		clientPrintColor(id, _, "No hay usuarios disponibles para mostrar en el menú");
		
		DestroyLocalMenu(id, iMenuId);
		
		showMenu__Group(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	g_MenuPage[id][MENU_PAGE_GROUP_INVITE] = min(g_MenuPage[id][MENU_PAGE_GROUP_INVITE], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__GroupInvite(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	new iUser;
	player_menu_info(id, iUser, iUser, g_MenuPage[id][MENU_PAGE_GROUP_INVITE]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Group(id);
		return PLUGIN_HANDLED;
	}
	
	new sItem[2];
	menu_item_getinfo(menu, item, iUser, sItem, charsmax(sItem), _, _, iUser);
	DestroyLocalMenu(id, menu);

	iUser = sItem[0];
	
	if(g_IsConnected[iUser]) {
		if(!g_InGroup[iUser]) {
			clientPrintColor(id, _, "Enviaste una invitación a !t%s!y para que se una a tu grupo", g_PlayerName[iUser]);
			clientPrintColor(iUser, _, "El usuario !t%s!y te invitó a su grupo", g_PlayerName[id]);
			
			++g_GroupInvitations[iUser];
			g_GroupInvitationsId[iUser][id] = 1;
		} else {
			clientPrintColor(id, _, "El usuario seleccionado acaba de entrar en un grupo");
		}
	} else {
		clientPrintColor(id, _, "El usuario seleccionado se ha desconectado");
	}

	showMenu__GroupInvite(id);
	return PLUGIN_HANDLED;
}

public showMenu__GroupInvitations(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("INVITACIONES RECIBIDAS^n\wTe enviaron solicitud\R\y", "menu__GroupInvitations");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || !g_GroupInvitationsId[id][i]) {
			continue;
		}
		
		formatex(sItem, charsmax(sItem), "%s \y(N: %d)(R: %d)", g_PlayerName[i], g_Level[i], g_Reset[i]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1) {
		clientPrintColor(id, _, "No tienes solicitudes a grupos");
		
		DestroyLocalMenu(id, iMenuId);

		showMenu__Group(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__GroupInvitations(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Group(id);
		return PLUGIN_HANDLED;
	}
	
	new sItem[2];
	new iUser;
	
	menu_item_getinfo(menu, item, iUser, sItem, charsmax(sItem), _, _, iUser);
	DestroyLocalMenu(id, menu);

	iUser = sItem[0];
	
	if(g_IsConnected[iUser]) {
		if(g_GroupInvitationsId[id][iUser]) {
			new iSlot;
			new i;

			if(!g_InGroup[iUser]) {
				iSlot = groupFindId();
				
				g_MyGroup[iUser] = 1;
				g_InGroup[iUser] = iSlot;
				
				iSlot = groupFindSlot(g_InGroup[iUser]);
				
				g_GroupId[g_InGroup[iUser]][iSlot] = iUser;
				g_GroupId[g_InGroup[iUser]][0] = 1;
				
				g_GroupInvitations[iUser] = 0;

				for(i = 0; i <= MaxClients; ++i) {
					g_GroupInvitationsId[iUser][i] = 0;
				}
			}
			
			iSlot = groupFindSlot(g_InGroup[iUser]);
			
			if(iSlot) {
				g_InGroup[id] = g_InGroup[iUser];
				g_GroupId[g_InGroup[iUser]][iSlot] = id;
				
				g_HLTime_GroupCombo[g_InGroup[id]] = halflife_time() + 999999.9;
				
				for(i = 1; i < 4; ++i) {
					if(g_GroupId[g_InGroup[iUser]][i]) {
						if(g_GroupId[g_InGroup[iUser]][i] != id) {
							clientPrintColor(g_GroupId[g_InGroup[iUser]][i], _, "!t%s!y se unió a tu grupo", g_PlayerName[id]);
						} else {
							clientPrintColor(g_GroupId[g_InGroup[iUser]][i], _, "Te uniste al grupo");
						}

						if(!g_Zombie[g_GroupId[g_InGroup[iUser]][i]]) {
							finishComboHuman(g_GroupId[g_InGroup[iUser]][i]);
						}
					}
				}
				
				g_GroupInvitations[id] = 0;
				
				for(i = 0; i <= MaxClients; ++i) {
					g_GroupInvitationsId[id][i] = 0;
				}
			} else {
				clientPrintColor(id, _, "El grupo al que intentaste entrar está lleno");
			}
		} else {
			clientPrintColor(id, _, "La invitación al grupo ha expirado");
		}
	} else {
		clientPrintColor(id, _, "El usuario seleccionado se ha desconectado");
	}
	
	if(g_GroupInvitations[id] && !g_InGroup[id]) {
		showMenu__GroupInvitations(id);
	}
	
	return PLUGIN_HANDLED;
}

public checkGroup(const id, const user, const leave_id) {
	new i = g_InGroup[id];
	new j;
	new k = 0;

	if(id == leave_id) { // La persona salió del grupo por su cuenta
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[i][j]) {
				clientPrintColor(g_GroupId[i][j], _, "!t%s!y se ha ido del grupo", g_PlayerName[leave_id]);
				++k;
			}
		}
	} else { // Lo expulsaron
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[i][j]) {
				clientPrintColor(g_GroupId[i][j], _, "!t%s!y ha sido expulsado del grupo", g_PlayerName[leave_id]);
				++k;
			}
		}
	}

	if(!g_Zombie[leave_id]) {
		finishComboHuman(leave_id);
	}
	
	g_InGroup[leave_id] = 0;
	g_GroupId[i][user] = 0;
	
	if(k < 3) { // Si el grupo solo tenía 2 personas en total, disolver grupo
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[i][j]) {
				clientPrintColor(g_GroupId[i][j], _, "Tu grupo se ha disuelto");
				
				g_InGroup[g_GroupId[i][j]] = 0;
				g_MyGroup[g_GroupId[i][j]] = 0;
				g_GroupId[i][j] = 0;
			}
		}
		
		g_GroupId[i][0] = 0; // Liberar id del grupo
	} else if(g_MyGroup[leave_id]) { // El que se fue era el dueño del grupo, darselo a otro
		g_MyGroup[leave_id] = 0;
		
		k = 0;
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[i][j]) {
				if(!k) {
					k = g_GroupId[i][j];
					g_MyGroup[k] = 1;
				}
				
				clientPrintColor(g_GroupId[i][j], _, "El nuevo dueño del grupo es !t%s!y", g_PlayerName[k]);
			}
		}
	}
}

public groupFindId() {
	new i;
	for(i = 1; i < 14; ++i) {
		if(!g_GroupId[i][0]) {
			return i;
		}
	}
	
	return 0;
}

public groupFindSlot(const group) {
	new i;
	for(i = 1; i < 4; ++i) {
		if(!g_GroupId[group][i]) {
			return i;
		}
	}
	
	return 0;
}

public removeBazookaEnt() {
	new iEnt = find_ent_by_class(-1, __ENT_CLASSNAME_BAZOOKA);
	while(iEnt > 0) {
		nemesisBazookaRemoveEnt(iEnt);
		iEnt = find_ent_by_class(-1, __ENT_CLASSNAME_BAZOOKA);
	}
}

public clcmd__EnterAmuletCustomName(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	if(g_AmuletCustomCreated[id]) {
		clientPrintColor(id, _, "Ya creaste un amuleto personalizado, puedes chequearlo y modificarlo en el menú");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	new sAmuletCustomName[64];
	read_args(sAmuletCustomName, charsmax(sAmuletCustomName));
	remove_quotes(sAmuletCustomName);
	trim(sAmuletCustomName);

	new iAmuletCustom = strlen(sAmuletCustomName);
	new i;
	new k;
	new j = 0;

	for(i = 0; i < iAmuletCustom; ++i) {
		for(k = 0; k < sizeof(__LETTERS_AND_SIMBOLS_ALLOWED); ++k) {
			if(sAmuletCustomName[i] == __LETTERS_AND_SIMBOLS_ALLOWED[k]) {
				++j;
			}
		}
	}

	if(iAmuletCustom != j) {
		clientPrintColor(id, _, "Solo letras y algunos símbolos: !g( ) [ ] { } - = . , : !!y, se permiten espacios");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	new iLenAmuletCustomName = strlen(sAmuletCustomName);
	
	if(iLenAmuletCustomName < 3) {
		clientPrintColor(id, _, "El nombre del amuleto debe tener al menos 3 caracteres");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	} else if(iLenAmuletCustomName > 32) {
		clientPrintColor(id, _, "El nombre del amuleto debe tener menos de 32 caracteres");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	copy(g_AmuletCustomNameFake[id], charsmax(g_AmuletCustomNameFake[]), sAmuletCustomName);

	showMenu__AmuletCustom(id);
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

		if(g_AmuletCustom[id][acMultXP]) {
			oldmenu_additem(6, 6, "\r6.\w Multiplicador de XP\r:\y +%0.2f", g_AmuletCustom[id][acMultXP]);
		}

		if(g_AmuletCustom[id][acMultCombo]) {
			oldmenu_additem(7, 7, "\r7.\w Multiplicador de Combo\r:\y +%d", g_AmuletCustom[id][acMultCombo]);
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
			g_AmuletCustom[id][acMultXP] = 0.0;
			g_AmuletCustom[id][acMultCombo] = 0;

			clientPrintColor(id, _, "Cuando estés decidido a crear el amuleto personalizado, escribe en consola !gzp_ac_create!y");
			clientPrintColor(id, _, "Pedirá confirmación, no te preocupes");
		}

		oldmenu_create("\yAMULETO PERSONALIZADO^n\wCosto\r:\y %d DIAMANTES", "menu__AmuletCustom", g_AmuletCustomCost[id]);

		oldmenu_additem(1, 1, "\r1.\w Nombre del amuleto\r:\y %s", ((g_AmuletCustomNameFake[id][0]) ? g_AmuletCustomNameFake[id] : "no-especificado"));

		oldmenu_additem(2, 2, "\r2.\w Vida\r:\y +%d", g_AmuletCustom[id][acHealth]);
		oldmenu_additem(3, 3, "\r3.\w Velocidad\r:\y +%d", g_AmuletCustom[id][acSpeed]);
		oldmenu_additem(4, 4, "\r4.\w Gravedad\r:\y +%d", g_AmuletCustom[id][acGravity]);
		oldmenu_additem(5, 5, "\r5.\w Daño\r:\y +%d^n", g_AmuletCustom[id][acDamage]);

		oldmenu_additem(6, 6, "\r6.\w Multiplicador de AmmoPacks\r:\y +%0.2f", g_AmuletCustom[id][acMultAmmoPacks]);
		oldmenu_additem(7, 7, "\r7.\w Multiplicador de XP\r:\y +%0.2f", g_AmuletCustom[id][acMultXP]);
		oldmenu_additem(8, 8, "\r8.\w Multiplicador de Combo\r:\y +%d", g_AmuletCustom[id][acMultCombo]);

		oldmenu_additem(0, 0, "^n\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__AmuletCustom(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	if(g_AmuletCustomCreated[id]) {
		switch(item) {
			case 1..7: {
				clientPrintColor(id, _, "Por ahora solo puedes visualizar tu amuleto, en las próximas actualizaciones podrás modificar los valores del mismo");
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
			} case 7: {
				if(g_AmuletCustom[id][acMultXP] < 1.4) {
					g_AmuletCustom[id][acMultXP] += 0.2;
					g_AmuletCustomCost[id] += 4;
				} else {
					g_AmuletCustom[id][acMultXP] = 0.0;
					g_AmuletCustomCost[id] -= 28;
				}
			} case 8: {
				if(g_AmuletCustom[id][acMultCombo] < 3) {
					++g_AmuletCustom[id][acMultCombo];
					g_AmuletCustomCost[id] += 6;
				} else {
					g_AmuletCustom[id][acMultCombo] = 0;
					g_AmuletCustomCost[id] -= 18;
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
			g_AmuletCustomCreated[id] = 0;

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_amulets_custom SET active='0' WHERE acc_id='%d';", g_AccountId[id]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			clientPrintColor(id, _, "Has eliminado tu amuleto personalizado con éxito");
			showMenu__AmuletCustom(id, 1);
		} case 2: {
			showMenu__AmuletCustom(id);
		}
	}
}

public clcmd__AmuletCustomCreate(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	if(g_AmuletCustomCreated[id]) {
		clientPrintColor(id, _, "Ya creaste un amuleto personalizado, puedes chequearlo y modificarlo en el menú");
		return PLUGIN_HANDLED;
	} else if(!g_IsAlive[id]) {
		clientPrintColor(id, _, "Es recomendable que crees tu amuleto estando vivo, hay veces que el menú principal no funciona en algunos modos");
		return PLUGIN_HANDLED;
	} else if(g_Points[id][P_DIAMONDS] < g_AmuletCustomCost[id]) {
		clientPrintColor(id, _, "No tienes diamantes suficientes para crear el amuleto");
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
	console_print(id, "Multiplicador de XP: +%0.2f", g_AmuletCustom[id][acMultXP]);
	console_print(id, "Multiplicador de Combo: +%d", g_AmuletCustom[id][acMultCombo]);
	console_print(id, "");
	console_print(id, " >>>>> ");
	console_print(id, "Para confirmar la operacion escriba en consola: %s", g_AmuletCustomConfirm);
	console_print(id, " >>>>> ");
	console_print(id, "");
	console_print(id, "DIAMANTES DISPONIBLES: %d", g_Points[id][P_DIAMONDS]);
	console_print(id, "COSTO DEL AMULETO: %d DIAMANTES", g_AmuletCustomCost[id]);
	console_print(id, "********* ^"%s^" *********", __PLUGIN_COMMUNITY_NAME);
	console_print(id, "");

	return PLUGIN_HANDLED;
}

public clcmd__AmuletCustomConfirm(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	if(g_AmuletCustomCreated[id]) {
		clientPrintColor(id, _, "Ya creaste un amuleto personalizado, puedes chequearlo y modificarlo en el menú");
		return PLUGIN_HANDLED;
	} else if(!g_IsAlive[id]) {
		clientPrintColor(id, _, "Es recomendable que crees tu amuleto estando vivo, hay veces que el menú principal no funciona en algunos modos");
		return PLUGIN_HANDLED;
	} else if(g_Points[id][P_DIAMONDS] < g_AmuletCustomCost[id]) {
		clientPrintColor(id, _, "No tienes diamantes suficientes para crear el amuleto");
		return PLUGIN_HANDLED;
	} else if(g_AmuletCustomCost[id] < 10) {
		clientPrintColor(id, _, "El amuleto no contiene nada, aumenta las estadísticas que desee para poder confirmarlo");
		return PLUGIN_HANDLED;
	} else if(!g_AmuletCustomNameFake[id][0]) {
		clientPrintColor(id, _, "Por favor, póngale un nombre a su amuleto");
		return PLUGIN_HANDLED;
	}

	g_Points[id][P_DIAMONDS] -= g_AmuletCustomCost[id];
	g_PointsLost[id][P_DIAMONDS] += g_AmuletCustomCost[id];

	g_AmuletCustomCreated[id] = 1;
	copy(g_AmuletCustomName[id], charsmax(g_AmuletCustomName[]), g_AmuletCustomNameFake[id]);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_amulets_custom (acc_id, name, a_health, a_speed, a_gravity, a_damage, a_aps, a_xp, a_combo) VALUES ('%d', ^"%s^", '%d', '%d', '%d', '%d', '%f', '%f', '%d');", g_AccountId[id], g_AmuletCustomName[id], g_AmuletCustom[id][acHealth], g_AmuletCustom[id][acSpeed], g_AmuletCustom[id][acGravity], g_AmuletCustom[id][acDamage], g_AmuletCustom[id][acMultAmmoPacks], g_AmuletCustom[id][acMultXP], g_AmuletCustom[id][acMultCombo]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	clientPrintColor(0, _, "!t%s!y ha creado su amuleto personalizado !g%s!y", g_PlayerName[id], g_AmuletCustomName[id]);
	return PLUGIN_HANDLED;
}

public fwd__SetClientKeyValuePre(const id, const infobuffer[], const key[]) {
	if(key[0] == 'n' && key[1] == 'a' && key[2] == 'm' && key[3] == 'e') {
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fwd__ClientUserInfoChangedPre(const id, const buffer) {
	if(!g_IsConnected[id]) {
		return FMRES_IGNORED;
	}

	static sName[MAX_NAME_LENGTH];
	get_user_info(id, "name", sName, charsmax(sName));

	if(!equal(sName, g_PlayerName[id])) {
		client_cmd(id, ";name ^"%s^"", g_PlayerName[id]);
		set_user_info(id, "name", g_PlayerName[id]);

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

tutorMake(const id, const input[], const color, const Float:duration=0.0) {
	if(!g_IsConnected[id]) {
		return;
	}

	message_begin(MSG_ONE_UNRELIABLE, g_Message_TutorText, _, id);
	write_string(input);
	write_byte(0);
	write_short(0);
	write_short(0);
	write_short((1<<color));
	message_end();

	if(duration != 0.0) {
		remove_task(id + TASK_TUTOR_TEXT);
		set_task(duration, "task__RemoveTutor", id + TASK_TUTOR_TEXT);
	}
}

public task__RemoveTutor(const task_id) {
	new iId = (task_id - TASK_TUTOR_TEXT);

	if(!g_IsConnected[iId]) {
		return;
	}

	message_begin(MSG_ONE_UNRELIABLE, g_Message_TutorClose, _, iId);
	message_end();
}

public clcmd__Tutor(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[128];
	read_argv(1, sArg1, charsmax(sArg1));

	if(sArg1[0]) {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(g_IsConnected[i]) {
				tutorMake(i, sArg1, 8, 10.0);
			}
		}
	}

	return PLUGIN_HANDLED;
}

// public clcmd__Abrir(const id) {
	// if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING) {
		// return PLUGIN_HANDLED;
	// }

	// new iGift = g_Gift[id];

	// if(!iGift) {
		// clientPrintColor(id, _, "No tienes regalos para abrir");
		// return PLUGIN_HANDLED;
	// }

	// g_Gift[id] = 0;
	
	// new iAmmoPacks = (iGift * 1500);
	// new iExp = (((iGift * 250) / 100) * 170000);
	// new iLvl = (random_num(10, 25) * 5000000);
	// new iPH;
	// new iPZ;
	// new iPL = random_num(14, 145);
	// new iPM = random_num(23, 283);
	// new iDiamonds = ((iGift / 100) / 2);

	// iExp += iLvl;
	
	// if(iGift > 100) {
		// iPH = random_num(50, 75);
		
		// if(iGift > 150) {
			// iPH = random_num(75, 100);
			
			// if(iGift > 200) {
				// iPH = random_num(100, 150);
				
				// if(iGift > 300) {
					// iPH = random_num(150, 200);
				// }
			// }
		// }
	// } else {
		// iPH = random_num(25, 50);
	// }

	// if(iGift > 100) {
		// iPZ = random_num(50, 75);

		// if(iGift > 150) {
			// iPZ = random_num(75, 100);

			// if(iGift > 200) {
				// iPZ = random_num(100, 150);

				// if(iGift > 300) {
					// iPZ = random_num(150, 200);
				// }
			// }
		// }
	// } else {
		// iPZ = random_num(25, 50);
	// }
	
	// g_AmmoPacks[id] += iAmmoPacks;
	// addXP(id, iExp);
	// g_Points[id][P_HUMAN] += iPH;
	// g_Points[id][P_ZOMBIE] += iPZ;
	// g_Points[id][P_LEGACY] += iPL;
	// g_Points[id][P_MONEY] += iPM;
	// g_Points[id][P_DIAMONDS] += iDiamonds;
	
	// saveInfo(id);
	
	// new sAmmoPacks[16];
	// new sExp[16];
	
	// addDot(iAmmoPacks, sAmmoPacks, charsmax(sAmmoPacks));
	// addDot(iExp, sExp, charsmax(sExp));
	
	// console_print(id, "");
	// console_print(id, "");
	// console_print(id, "*** DRUNK-GAMING ***");
	// console_print(id, "");
	// console_print(id, "Abriendo %d regalos...", iGift);
	// console_print(id, "");
	// console_print(id, "Ganaste %s AmmoPacks", sAmmoPacks);
	// console_print(id, "Ganaste %s EXP (LOS NIVELES GANADOS ESTAN INCLUIDOS ACA)", sExp);
	// console_print(id, "Ganaste %d PH", iPH);
	// console_print(id, "Ganaste %d PZ", iPZ);
	// console_print(id, "Ganaste %d PL", iPL);
	// console_print(id, "Ganaste %d SALDO", iPM);
	// console_print(id, "Ganaste %d DIAMANTES", iDiamonds);
	// console_print(id, "");
	// console_print(id, "");
	// console_print(id, "*** DRUNK-GAMING ***");

	// return PLUGIN_HANDLED;
// }

public addPoints(const victim, const killer) {
	if(g_Mode != MODE_MEGA_SYNAPSIS && g_Mode != MODE_ANNIHILATOR && g_SpecialMode[killer] != MODE_ANNIHILATOR) {
		new iPointClass = ((g_Zombie[killer]) ? P_ZOMBIE : P_HUMAN);
		new iReward;

		if(g_Mode == MODE_MEGA_ARMAGEDDON) {
			iReward = g_PointsMult[killer];

			new i;
			for(i = 1; i <= MaxClients; ++i) {
				if(g_IsAlive[i] && g_Zombie[killer] == g_Zombie[i]) {
					g_Points[i][iPointClass] += iReward;
				}
			}

			clientPrintColor(0, killer, "!t%s!y ganaron !g%d p%c!y por matar a un !g%s!y", ((g_Zombie[killer]) ? "ZOMBIES" : "HUMANOS"), iReward, ((iPointClass == P_ZOMBIE) ? 'Z' : 'H'), g_PlayerClassName[victim]);
		} else if(g_Mode == MODE_MEGA_DRUNK) {
			iReward = ((g_HappyHour == 2) ? 2 : 1);

			g_Points[killer][iPointClass] += iReward;
			clientPrintColor(0, killer, "!t%s!y ganó !g%d p%c!y por matar a un !g%s!y", g_PlayerName[killer], iReward, ((iPointClass == P_ZOMBIE) ? 'Z': 'H'), g_PlayerClassName[victim]);
		} else {
			iReward = g_PointsMult[killer];

			new iRewardPL = 1;
			new iKillWithKnife = 0;

			if(g_CurrentWeapon[killer] == CSW_KNIFE && (g_SpecialMode[victim] == MODE_NEMESIS || g_SpecialMode[victim] == MODE_ANNIHILATOR || g_SpecialMode[victim] == MODE_FLESHPOUND) && !g_SpecialMode[killer]) {
				iReward *= 2;
				++iRewardPL;

				iKillWithKnife = 1;
			}

			if(g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_DRUNK && g_SpecialMode[victim] == MODE_SNIPER) {
				++iReward;
			}

			g_Points[killer][iPointClass] += iReward;
			g_Points[killer][P_LEGACY] += iRewardPL;

			clientPrintColor(0, killer, "!t%s!y ganó !g%d p%c!y y !g%d pL!y por matar a un !g%s!y%s", g_PlayerName[killer], iReward, ((iPointClass == P_ZOMBIE) ? 'Z': 'H'), iRewardPL, g_PlayerClassName[victim], ((iKillWithKnife) ? " con cuchillo" : ""));
		}
	}
}

public stuffModes() {
	switch(g_Mode) {
		case MODE_NEMESIS, MODE_ANNIHILATOR: {
			removeBazookaEnt();
		}
	}
}

public rewardModes() {
	switch(g_Mode) {
		case MODE_INFECTION: {
			new iUsersPlaying = getUsersPlaying();
			new iReward = 0;
			new sReward[16];
			new i;

			for(i = 1; i <= MaxClients; ++i) {
				if(g_IsConnected[i] && g_AccountStatus[i] == STATUS_PLAYING) {
					if(g_DeadTimes_Reward[i]) {
						iReward = (g_DeadTimes_Reward[i] * (iUsersPlaying * REWARD_XP_IN_INFECTION));

						if(iReward < 0 || iReward > MAX_XP) {
							iReward = MAX_XP;
						}

						addDot(iReward, sReward, charsmax(sReward));
						clientPrintColor(i, _, "Ganaste !g%s XP!y por haber muerto !g%d ve%s siendo Zombie!y en el modo !tINFECCIÓN!y", sReward, g_DeadTimes_Reward[i], ((g_DeadTimes_Reward[i] != 1) ? "ces" : "z"));

						addXP(i, iReward);
					} else {
						clientPrintColor(i, _, "No recibiste recompensas porque no has muerto en la ronda siendo Zombie");
					}
				}
			}
		} case MODE_L4D2: {
			new iReward = 0;
			new sReward[16];
			new i;

			for(i = 1; i <= MaxClients; ++i) {
				if(g_IsConnected[i] && g_AccountStatus[i] == STATUS_PLAYING) {
					if(g_SpecialMode[i] == MODE_L4D2) {
						iReward = ((getUserLevelTotal(i) * ((g_ModeL4D2_ZombiesTotal - g_ModeL4D2_Zombies) * 25)) * floatround(g_XPMult[i]));
						addDot(iReward, sReward, charsmax(sReward));

						clientPrintColor(i, _, "Ganaste !g%s XP!y por sobrevivir al modo !tL4D2!y", sReward);
						addXP(i, iReward);
					} else {
						if(g_ModeL4D2_ZombieAcerts[i]) {
							iReward = ((getUserLevelTotal(i) * (g_ModeL4D2_ZombieAcerts[i] * 50)) * floatround(g_XPMult[i]));
							addDot(iReward, sReward, charsmax(sReward)); 

							clientPrintColor(i, _, "Ganaste !g%s XP!y por haber pegado !g%d ve%s a los humanos!y", sReward, g_ModeL4D2_ZombieAcerts[i], ((g_ModeL4D2_ZombieAcerts[i] != 1) ? "ces" : "z"));
							addXP(i, iReward);

							g_ModeL4D2_ZombieAcerts[i] = 0;
						} else {
							clientPrintColor(i, _, "No recibiste recompensas porque no le has hecho daño a los humanos");
						}
					}
				}
			}
		} case MODE_CABEZON: {
			new iUsersPlaying = getUsersPlaying();
			new iReward;
			new sReward[16];
			new i;

			for(i = 1; i <= MaxClients; ++i) {
				if(g_IsConnected[i]) {
					if(g_SpecialMode[i] == MODE_CABEZON) {
						if(g_ModeCabezon_HeadTotal) {
							new iRandom = (random_num(1, 3) * g_Reset[i]);

							iReward = ((iUsersPlaying * 50) - g_ModeCabezon_HeadTotal);

							if(iReward <= 0) {
								iReward = (iReward * 5000);
								iRandom = 0;

								if(iReward <= -20000000) {
									iReward = -20000000;
								}

								addDot(iReward, sReward, charsmax(sReward));

								clientPrintColor(0, _, "El !tCABEZÓN!y recibió !g%d disparos en la cabeza!y y por eso perdió !g%s XP!y", g_ModeCabezon_HeadTotal, sReward);
							} else {
								iReward = (iReward * 15000);

								if(g_XPMult[i]) {
									iReward *= floatround(g_XPMult[i]);
								}

								addDot(iReward, sReward, charsmax(sReward));
								clientPrintColor(0, _, "El !tCABEZÓN!y recibió !g%d disparos en la cabeza!y y por eso ganó !g%s XP!y y !g%d SALDO!y", g_ModeCabezon_HeadTotal, sReward, iRandom);
							}

							if(iReward > 0) {
								addXP(i, iReward);
							} else {
								g_XP[i] = clamp((g_XP[i] + iReward), 0, MAX_XP);
								g_XPRest[i] = (xpThisLevel(i, g_Level[i]) - g_XP[i]);
							}

							g_Points[i][P_MONEY] += iRandom;
						} else {
							clientPrintColor(0, _, "El !tCABEZÓN!y no recibió recompensas porque no ha recibido disparos en la cabeza");
						}

						if(iUsersPlaying >= 20) {
							setAchievement(i, EL_CABEZA);
							
							if(!g_ModeCabezon_PowerGlobal) {
								setAchievement(i, COMO_USABA_EL_PODER);
							}
							
							if(g_ModeCabezon_HeadTotal < 20) {
								setAchievement(i, MEJOREN_LA_PUNTERIA);
							}
							
							if(g_ModeCabezon_HeadTotal < 10) {
								setAchievement(i, A_ESO_LE_LLAMAN_DISPARAR);
							}
						}
					} else {
						if(g_ModeCabezon_Head[i]) {
							iReward = (((g_ModeCabezon_Head[i] * (10 + g_Reset[i])) * getUserLevelTotal(i) * 5) * floatround(g_XPMult[i]));

							if(iReward < 0 || iReward > MAX_XP) {
								iReward = MAX_XP;
							}

							addDot(iReward, sReward, charsmax(sReward));

							clientPrintColor(i, _, "Recibiste !g%s XP!y por realizar !g%d disparos en la cabeza!y", sReward, g_ModeCabezon_Head[i]);
							addXP(i, iReward);

							g_ModeCabezon_Head[i] = 0;
						} else {
							clientPrintColor(i, _, "No recibiste recompensas porque no realizaste disparos a la cabeza");
						}
					}
				}
			}

			g_ModeCabezon_HeadTotal = 0;
			g_ModeCabezon_PowerGlobal = 0;
		} case MODE_ANNIHILATOR: {
			new iReward = 0;
			new sReward[16];
			new i;

			sReward[0] = EOS;

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsConnected[i]) {
					continue;
				}

				if(g_SpecialMode[i] != MODE_ANNIHILATOR) {
					if(g_ModeAnnihilator_Acerts[i]) {
						iReward = (g_ModeAnnihilator_Acerts[i] * (floatround(g_XPMult[i]) * 12) * getUserLevelTotal(i));
						
						if(iReward < 0 || iReward > MAX_XP) {
							iReward = MAX_XP;
						}

						addDot(iReward, sReward, charsmax(sReward));

						clientPrintColor(i, _, "Ganaste !g%s XP!y por haber realizado !g%d aciertos de disparos!y", sReward, g_ModeAnnihilator_Acerts[i]);
						addXP(i, iReward);

						g_ModeAnnihilator_Acerts[i] = 0;
					} else {
						clientPrintColor(i, _, "No recibiste recompensas porque no realizaste aciertos de disparos");
					}

					if(g_ModeAnnihilator_Knife[i] < 0) {
						g_ModeAnnihilator_Knife[i] += 1000;
					}
				} else {
					if(g_ModeAnnihilator_Kills[i]) {
						checkAnnihilatorReward(i, g_ModeAnnihilator_Kills[i], 1);

						if((g_Achievement_AnnKnife[i] - g_Achievement_AnnBazooka[i]) >= 200) {
							setAchievement(i, ANIQUILOSO);
						}

						if(g_Achievement_AnnBazooka[i] >= 100) {
							setAchievement(i, CIENFUEGOS);
						} else if(!g_Achievement_AnnBazooka[i] && !g_Bazooka[i]) {
							setAchievement(i, EL_PEOR_DEL_SERVER);
						}

						new sWeaponName[32];
						new iWeaponEntId;

						get_weaponname(CSW_MAC10, sWeaponName, charsmax(sWeaponName));
						iWeaponEntId = find_ent_by_owner(-1, sWeaponName, i);

						if(pev_valid(iWeaponEntId) == PDATA_SAFE && get_pdata_int(iWeaponEntId, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS) == 30 && get_pdata_int(i, __AMMO_OFFSET[CSW_MAC10], OFFSET_LINUX) == 100) {
							setAchievement(i, MI_MAC10_ESTA_LLENA);
						} else if(!g_Achievement_AnniMac10[i] && pev_valid(iWeaponEntId) == PDATA_SAFE && get_pdata_int(iWeaponEntId, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS) == 0 && get_pdata_int(i, __AMMO_OFFSET[CSW_MAC10], OFFSET_LINUX) == 0) {
							setAchievement(i, SOY_UN_MANCO);
						} else if(g_Achievement_AnniMac10[i] >= 50) {
							setAchievement(i, CINCUENTA_SON_CINCUENTA);

							if(g_Achievement_AnniMac10[i] >= 100) {
								setAchievement(i, YO_SI_PEGO_CON_ESTO);
								
								if(g_Achievement_AnniMac10[i] == 130) {
									setAchievement(i, MUCHA_PRECISION);
								}
							}
						}

						if(g_ModeAnnihilator_Kills[i] >= 300) {
							setAchievement(i, CARNE);

							if(g_ModeAnnihilator_Kills[i] >= 400) {
								setAchievement(i, MUCHA_CARNE);

								if(g_ModeAnnihilator_Kills[i] >= 450) {
									setAchievement(i, DEMASIADA_CARNE);

									if(g_ModeAnnihilator_Kills[i] >= 500) {
										setAchievement(i, CARNE_PARA_TODOS);
									}
								}
							}
						}

						g_ModeAnnihilator_Kills[i] = 0;
					} else {
						clientPrintColor(0, _, "El !tANIQUILADOR!y no recibió recompensas por no ha asesinado a humanos");
					}
				}

				g_Achievement_AnnKnife[i] = 0;
				g_Achievement_AnniMac10[i] = 0;
				g_Achievement_AnnBazooka[i] = 0;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsConnected[i]) {
					continue;
				}

				g_ModeAnnihilator_AcertsHS[i] = 0;
				g_ModeAnnihilator_Knife[i] = 0;
			}
		} case MODE_GRUNT: {
			new sReward[16];
			new i;

			sReward[0] = EOS;

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsConnected[i]) {
					continue;
				}

				if(g_ModeGrunt_Reward[i] < 0) {
					g_ModeGrunt_Reward[i] = 0;
				}

				addDot(g_ModeGrunt_Reward[i], sReward, charsmax(sReward));
				clientPrintColor(i, _, "Ganaste !g%s XP!y por sobrevivir al modo !tGRUNT!y", sReward);

				addXP(i, g_ModeGrunt_Reward[i]);
				g_ModeGrunt_Reward[i] = 0;
			}

			g_ModeGrunt_RewardGlobal = 0;
		}
	}
}

public rewardModesBySort() {
	new iBest;
	new iBestId;
	new iReward[structIdPoints] = {0, 0, 0, 0, 0, 0}; // Los últimos dos arrays son inutilizables pero weño

	switch(g_Mode) {
		case MODE_PLAGUE: {
			iBestId = systemSort(g_PlagueHumanKill, iBest);

			if(iBest && iBestId) {
				iReward[P_ZOMBIE] = random_num(1, 3);
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pZ!y y !g%d SALDO!y por matar a !g%d humano%s!y", g_PlayerName[iBestId], iReward[P_ZOMBIE], iReward[P_MONEY], iBest, ((iBest != 1) ? "s" : ""));

				g_Points[iBestId][P_ZOMBIE] += iReward[P_ZOMBIE];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}

			iBestId = systemSort(g_PlagueZombieKill, iBest);

			if(iBest && iBestId) {
				iReward[P_HUMAN] = random_num(1, 3);
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pH!y y !g%d SALDO!y por matar a !g%d zombie%s!y", g_PlayerName[iBestId], iReward[P_HUMAN], iReward[P_MONEY], iBest, ((iBest != 1) ? "s" : ""));

				g_Points[iBestId][P_HUMAN] += iReward[P_HUMAN];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}
		} case MODE_SYNAPSIS: {
			iBestId = systemSort(g_SynapsisNemesisKill, iBest);

			if(iBest && iBestId) {
				iReward[P_ZOMBIE] = random_num(1, 3);
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pZ!y y !g%d SALDO!y por matar a !g%d humano%s!y", g_PlayerName[iBestId], iReward[P_ZOMBIE], iReward[P_MONEY], iBest, ((iBest != 1) ? "s" : ""));
				
				g_Points[iBestId][P_ZOMBIE] += iReward[P_ZOMBIE];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}

			iBestId = systemSort(g_SynapsisDamage, iBest);

			if(iBest && iBestId) {
				iReward[P_LEGACY] = 1;
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pL!y y !g%d SALDO!y por realizar !g%d de daño!y", g_PlayerName[iBestId], iReward[P_LEGACY], iReward[P_MONEY], iBest);

				g_Points[iBestId][P_LEGACY] += iReward[P_LEGACY];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}

			iBestId = systemSort(g_SynapsisHead, iBest);

			if(iBest && iBestId) {
				iReward[P_LEGACY] = 1;
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pL!y y !g%d SALDO!y por realizar a !g%d disparo%s a la cabeza!y", g_PlayerName[iBestId], iReward[P_LEGACY], iReward[P_MONEY], iBest, ((iBest != 1) ? "s" : ""));

				g_Points[iBestId][P_LEGACY] += iReward[P_LEGACY];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}
		} case MODE_MEGA_DRUNK: {
			iBestId = systemSort(g_ModeMegaDrunk_ZombieHits, iBest);

			if(iBest && iBestId) {
				iReward[P_ZOMBIE] = random_num(1, 3);
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pZ!y y !g%d SALDO!y por golpear !g%d ve%s!y a los humanos", g_PlayerName[iBestId], iReward[P_ZOMBIE], iReward[P_MONEY], iBest, ((iBest != 1) ? "ces" : "z"));

				g_Points[iBestId][P_ZOMBIE] += iReward[P_ZOMBIE];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}
		} case MODE_CABEZON: {
			iBestId = systemSort(g_ModeCabezon_Head, iBest);

			if(iBest && iBestId) {
				iReward[P_HUMAN] = random_num(1, 5);
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pH!y y !g%d SALDO!y por realizar !g%d disparos a la cabeza en total!y", g_PlayerName[iBestId], iReward[P_HUMAN], iReward[P_MONEY], iBest);

				g_Points[iBestId][P_HUMAN] += iReward[P_HUMAN];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}
		} case MODE_ANNIHILATOR: {
			iBestId = systemSort(g_ModeAnnihilator_AcertsHS, iBest);

			if(iBest && iBestId) {
				iReward[P_HUMAN] = random_num(1, 3);
				iReward[P_ZOMBIE] = random_num(1, 3);
				iReward[P_MONEY] = random_num(1, 5);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pH!y, !g%d pZ!y y !g%d SALDO!y por realizar !g%d disparo%s a la cabeza!y", g_PlayerName[iBestId], iReward[P_HUMAN], iReward[P_ZOMBIE], iReward[P_MONEY], iBest, ((iBest != 1) ? "s" : ""));

				g_Points[iBestId][P_HUMAN] += iReward[P_HUMAN];
				g_Points[iBestId][P_ZOMBIE] += iReward[P_ZOMBIE];
				g_Points[iBestId][P_MONEY] += iReward[P_MONEY];
			}

			iBestId = systemSort(g_ModeAnnihilator_Knife, iBest);

			if(iBest && iBestId) {
				iReward[P_HUMAN] = random_num(1, 5);
				iReward[P_ZOMBIE] = random_num(1, 5);
				iReward[P_LEGACY] = random_num(1, 3);

				clientPrintColor(0, _, "!t%s!y ganó !g%d pH!y, !g%d pZ!y y !g%d pL!y por acuchillar !g%d ve%s!y antes de su primera muerte", g_PlayerName[iBestId], iReward[P_HUMAN], iReward[P_ZOMBIE], iReward[P_LEGACY], iBest, ((iBest != 1) ? "ces" : "z"));

				g_Points[iBestId][P_HUMAN] += iReward[P_HUMAN];
				g_Points[iBestId][P_ZOMBIE] += iReward[P_ZOMBIE];
				g_Points[iBestId][P_LEGACY] += iReward[P_MONEY];
			}
		}
	}
}

systemSort(const num[], &num_sort) {
	new iMaxSort = 0;
	new iMaxSortId = -1;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			if(num[i] > iMaxSort) {
				iMaxSort = num[i];
				iMaxSortId = i;
			}
		}
	}

	if(iMaxSortId == -1) {
		return 0;
	}

	num_sort = iMaxSort;
	return iMaxSortId;
}

public clcmd__Cam(const id) {
	if(!g_IsAlive[id]) {
		return PLUGIN_HANDLED;
	}

	g_Camera[id] = !g_Camera[id];

	if(g_Camera[id]) {
		set_view(id, CAMERA_3RDPERSON);
	} else {
		set_view(id, CAMERA_NONE);
	}

	return PLUGIN_HANDLED;
}

public tribalModeKill(const killer, const victim) {
	if(!getZombies()) {
		tribalModeWin();
	}
}

public tribalModeWin() {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsAlive[i] || g_SpecialMode[i] != MODE_TRIBAL) {
			continue;
		}

		clientPrintColor(0, _, "!t%s!y ganó !g%d pH!y y !g1 pL!y por ganar el modo !tTRIBAL!y", g_PlayerName[i], (g_PointsMult[i] + 1));
		
		g_Points[i][P_HUMAN] += (g_PointsMult[i] + 1);
		++g_Points[i][P_LEGACY];
	}
}

public tribalPower(const id) {
	if(!g_IsConnected[id] || !g_ModeTribal_Power) {
		return;
	}

	g_ModeTribal_Power = 0;

	new Float:vecOriginId[3];
	new Float:vecOriginVictim[3];
	new Float:flDistance;
	new i;
	new iHealthDamage;

	entity_get_vector(id, EV_VEC_origin, vecOriginId);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOriginId, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vecOriginId[0]);
	engfunc(EngFunc_WriteCoord, vecOriginId[1]);
	engfunc(EngFunc_WriteCoord, (vecOriginId[2] + 100.0));
	engfunc(EngFunc_WriteCoord, vecOriginId[0]);
	engfunc(EngFunc_WriteCoord, vecOriginId[1]);
	engfunc(EngFunc_WriteCoord, (vecOriginId[2] + 450.0));
	write_short(g_Sprite_ShockWave);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(400);
	write_byte(0);
	write_byte(255);
	write_byte(165);
	write_byte(0);
	write_byte(200);
	write_byte(0);
	message_end();

	iHealthDamage = (ZOMBIE_HEALTH_BASE / 2);

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			entity_get_vector(i, EV_VEC_origin, vecOriginVictim);
			flDistance = get_distance_f(vecOriginId, vecOriginVictim);

			if(flDistance > 625.0) {
				continue;
			}

			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, i);
			write_short(UNIT_SECOND * 2);
			write_short(UNIT_SECOND * 2);
			write_short(FFADE_IN);
			write_byte(255);
			write_byte(165);
			write_byte(0);
			write_byte(125);
			message_end();

			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, i);
			write_short(UNIT_SECOND * 14);
			write_short(UNIT_SECOND * 8);
			write_short(UNIT_SECOND * 14);
			message_end();

			if(g_Zombie[i]) {
				if((g_Health[i] - iHealthDamage) < 1) {
					ExecuteHamB(Ham_Killed, i, id, 2);
				} else {
					set_user_health(i, (g_Health[i] - iHealthDamage));
					g_Health[i] = get_user_health(i);

					burningPlayer(i, id, 20);
					// randomSpawn(i);

					xs_vec_sub(vecOriginVictim, vecOriginId, vecOriginVictim);
					xs_vec_normalize(vecOriginVictim, vecOriginVictim);
					xs_vec_mul_scalar(vecOriginVictim, ((flDistance - 625.0) * -50), vecOriginVictim);

					entity_set_vector(i, EV_VEC_velocity, vecOriginVictim);
				}
			}
		}
	}
}

public tribalAura(const id) {
	if(!g_IsAlive[id] || g_SpecialMode[id] != MODE_TRIBAL) {
		return;
	}

	new Float:vecPositionId[3];
	new Float:vecPositionI[3];
	new Float:flDistance;
	new iOk = 0;
	new i;
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsAlive[i] || id == i || g_SpecialMode[i] != MODE_TRIBAL) {
			continue;
		}

		iOk = 1;

		entity_get_vector(i, EV_VEC_origin, vecPositionI);
		entity_get_vector(id, EV_VEC_origin, vecPositionId);

		flDistance = get_distance_f(vecPositionI, vecPositionId);

		if(flDistance <= 350) {
			if(!task_exists(id + TASK_POWER_MODE)) {
				set_task(0.1, "task__PowerTribal", id + TASK_POWER_MODE, .flags="b");
			}

			if(!task_exists(i + TASK_POWER_MODE)) {
				set_task(0.1, "task__PowerTribal", i + TASK_POWER_MODE, .flags="b");
			}
		} else {
			if(task_exists(id + TASK_POWER_MODE)) {
				remove_task(id + TASK_POWER_MODE);
			}

			if(task_exists(i + TASK_POWER_MODE)) {
				remove_task(i + TASK_POWER_MODE);
			}
		}

		break;
	}

	if(!iOk) {
		if(task_exists(id + TASK_POWER_MODE)) {
			remove_task(id + TASK_POWER_MODE);
		}
	}
}

public task__PowerTribal(const task_id) {
	new iId = (task_id - TASK_POWER_MODE);

	if(g_SpecialMode[iId] != MODE_TRIBAL) {
		remove_task(task_id);
		return;
	}

	new vecOrigin[3];
	get_user_origin(iId, vecOrigin);

	message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_DLIGHT);
	write_coord(vecOrigin[0]);
	write_coord(vecOrigin[1]);
	write_coord(vecOrigin[2]);
	write_byte(g_Aura[iId][3]);
	write_byte(g_Aura[iId][0]);
	write_byte(g_Aura[iId][1]);
	write_byte(g_Aura[iId][2]);
	write_byte(2);
	write_byte(0);
	message_end();

	if(g_Health[iId] < g_MaxHealth[iId]) {
		set_user_health(iId, (g_Health[iId] + 1));
	}

	++g_ModeTribal_Damage[iId];
}

public task__ZombieBack() {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i] && !g_Zombie[i] && g_ZombieBack[i]) {
			g_ZombieBack[i] = 0;
		}
	}
}

public showMenu__HabReset(const id) {
	oldmenu_create("\yHABILIDADES DEL RESET^n\wPuntos de Reset\r:\y %d", "menu__HabReset", g_Points[id][P_RESET]);

	oldmenu_additem(1, 1, "\r1.\w Subir habilidad humana \yVIDA\w");
	oldmenu_additem(2, 2, "\r2.\w Subir habilidad humana \yDAÑO\w^n");

	oldmenu_additem(3, 3, "\r3.\w Subir habilidad zombie \yVIDA\w");
	oldmenu_additem(4, 4, "\r4.\w Subir habilidad zombie \yDAÑO\w^n");

	oldmenu_additem(5, 5, "\r5.\w Subir un arma aleatoria de nivel^n");

	oldmenu_additem(6, 6, "\r6.\w Obtener \y75 pHZ\w, \y45 pL\w y \y90 SALDO\w^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HabReset(const id, const item) {
	if(!item) {
		showMenu__HabClasses(id, g_MenuPage[id][MENU_PAGE_HAB_CLASSES]);
		return;
	}

	if(!g_Points[id][P_RESET]) {
		clientPrintColor(id, _, "No tienes puntos suficientes");

		showMenu__HabReset(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Hab[id][HAB_H_HEALTH] == __HABS[HAB_H_HEALTH][habMaxLevel]) {
				clientPrintColor(id, _, "Has superado el nivel máximo de habilidad humana !gVIDA!y");

				showMenu__HabReset(id);
				return;
			}

			clientPrintColor(id, _, "Subiste la habilidad humana !gVIDA!y");
			++g_Hab[id][HAB_H_HEALTH];
		} case 2: {
			if(g_Hab[id][HAB_H_DAMAGE] == __HABS[HAB_H_DAMAGE][habMaxLevel]) {
				clientPrintColor(id, _, "Has superado el nivel máximo de habilidad humana !gDAÑO!y");

				showMenu__HabReset(id);
				return;
			}

			clientPrintColor(id, _, "Subiste la habilidad humana !gDAÑO!y");
			++g_Hab[id][HAB_H_DAMAGE];
		} case 3: {
			if(g_Hab[id][HAB_Z_HEALTH] == __HABS[HAB_Z_HEALTH][habMaxLevel]) {
				clientPrintColor(id, _, "Has superado el nivel máximo de habilidad zombie !gVIDA!y");

				showMenu__HabReset(id);
				return;
			}

			clientPrintColor(id, _, "Subiste la habilidad zombie !gVIDA!y");
			++g_Hab[id][HAB_Z_HEALTH];
		} case 4: {
			if(g_Hab[id][HAB_Z_DAMAGE] == __HABS[HAB_Z_DAMAGE][habMaxLevel]) {
				clientPrintColor(id, _, "Has superado el nivel máximo de habilidad zombie !gDAÑO!y");

				showMenu__HabReset(id);
				return;
			}

			clientPrintColor(id, _, "Subiste la habilidad zombie !gDAÑO!y");
			++g_Hab[id][HAB_Z_DAMAGE];
		} case 5: {
			new iRandomWeapon = random_num(0, charsmax(__WEAPON_DATA));

			if(g_WeaponData[id][__WEAPON_DATA[iRandomWeapon][weaponDataId]][WEAPON_DATA_LEVEL] == 25) {
				clientPrintColor(id, _, "Justamente el arma seleccionada al azar está en su nivel máximo. Inténtalo nuevamente");

				showMenu__HabReset(id);
				return;
			}

			clientPrintColor(id, _, "Subiste de nivel tu arma !g%s!y", __WEAPON_DATA[iRandomWeapon][weaponDataName]);

			g_WeaponData[id][__WEAPON_DATA[iRandomWeapon][weaponDataId]][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
			++g_WeaponData[id][__WEAPON_DATA[iRandomWeapon][weaponDataId]][WEAPON_DATA_LEVEL];
			++g_WeaponData[id][__WEAPON_DATA[iRandomWeapon][weaponDataId]][WEAPON_DATA_POINTS];
			g_WeaponSave[id][__WEAPON_DATA[iRandomWeapon][weaponDataId]] = 1;

			checkAchievementsWeapons(id, __WEAPON_DATA[iRandomWeapon][weaponDataId]);
		} case 6: {
			clientPrintColor(id, _, "Obtuviste !g75 pHZ!y, !g45 pL!y y !g90 SALDO!y");

			g_Points[id][P_HUMAN] += 75;
			g_Points[id][P_ZOMBIE] += 75;
			g_Points[id][P_LEGACY] += 45;
			g_Points[id][P_MONEY] += 90;
		}
	}

	--g_Points[id][P_RESET];

	showMenu__HabReset(id);
}

public getUserTimePlaying(const id) {
	new sBuffer[32];
	sBuffer[0] = EOS;

	if(g_PlayedTime[id][TIME_DAY]) {
		formatex(sBuffer, charsmax(sBuffer), "%d día%s y %d hora%s", g_PlayedTime[id][TIME_DAY], ((g_PlayedTime[id][TIME_DAY] != 1) ? "s" : ""), g_PlayedTime[id][TIME_HOUR], ((g_PlayedTime[id][TIME_HOUR]) ? "s" : ""));
	} else if(g_PlayedTime[id][TIME_HOUR]) {
		formatex(sBuffer, charsmax(sBuffer), "%d hora%s", g_PlayedTime[id][TIME_HOUR], ((g_PlayedTime[id][TIME_HOUR] != 1) ? "s" : ""));
	} else {
		formatex(sBuffer, charsmax(sBuffer), "Nada");
	}

	return sBuffer;
}

public task__ModeInfection() {
	if(random_num(1, 5) == 3) {
		set_task(30.0, "task__ModeInfection", TASK_MODE_INFECTION);
		return;
	}

	g_Lights[0] = 'a';
	changeLights();

	g_ModeInfection_Res = 1;
}

public showMenu__Benefit(const id) {
	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] == 1) {
		showMenu__Game(id);
		return;
	}

	oldmenu_create("\yBENEFICIO GRATUITO", "menu__Benefit");

	new iSysTime = get_arg_systime();

	if(g_Benefit[id] > iSysTime) {
		oldmenu_additem(-1, -1, "\wTu beneficio está activado");
		oldmenu_additem(-1, -1, "\wSe vencerá el día \y%s\w^n", getUnixToTime(g_Benefit[id], 1));
		
		oldmenu_additem(-1, -1, "\wUna vez que acabe tu beneficio, no");
		oldmenu_additem(-1, -1, "podrás volver a utilizarlo en tu personaje.");
		oldmenu_additem(-1, -1, "\wSi quieres volver a tener los beneficios, visita");
		oldmenu_additem(-1, -1, "la sección de compras de la comunidad en\r:");
		oldmenu_additem(-1, -1, "\y%s\w^n", __PLUGIN_COMMUNITY_FORUM_SHOP);
	} else {
		oldmenu_additem(-1, -1, "\wEste beneficio gratuito se le otorgará al usuario");
		oldmenu_additem(-1, -1, "por \y7 DÍAS\w los multiplicadores de un VIP.");
		oldmenu_additem(-1, -1, "solamente tiene que seguir los pasos para poder");
		oldmenu_additem(-1, -1, "acreditar dichos beneficios por ese plazo de tiempo.^n");

		oldmenu_additem(-1, -1, "\wUna vez activado el beneficio gratuito, podrás tener");
		oldmenu_additem(-1, -1, "las siguientes mejoras:");
		oldmenu_additem(-1, -1, "\r - \wMultiplicador de APs \y+x1");
		oldmenu_additem(-1, -1, "\r - \wMultiplicador de XP \y+x1");
		oldmenu_additem(-1, -1, "\r - \wMultiplicador de Puntos \y+x1");
		oldmenu_additem(-1, -1, "\r - \wMenor daño para realizar combo");
		oldmenu_additem(-1, -1, "\wEstos son los beneficios básicos y los que otorga un");
		oldmenu_additem(-1, -1, "jugador \yVIP\w o superior normalmente; no otorga \rSLOT RESERVADO\w.^n");

		oldmenu_additem(1, 1, "\r1.\w Activar ahora");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Benefit(const id, const item) {
	if(!item || (get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] == 1) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			new iSysTime = get_arg_systime();

			if(g_Benefit[id] > iSysTime) {
				showMenu__Benefit(id);
				return;
			}

			g_Benefit[id] = (iSysTime + 604800);

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_pjs SET benefit_timestamp='%d' WHERE acc_id='%d';", g_Benefit[id], g_AccountId[id]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			clientPrintColor(id, _, "Has activado tu beneficio gratuito por !g7 DÍAS!y. Disfrutalo :)");
			showMenu__Benefit(id);
		}
	}
}

public task__FinishSniperPower(const task_id) {
	new iId = (task_id - TASK_POWER_MODE);

	if(!g_IsConnected[iId] || g_SpecialMode[iId] != MODE_SNIPER || !g_SniperPower[iId]) {
		return;
	}

	clientPrint(iId, print_center, "¡Se te acabó el DISPARO VELOZ!");

	if(g_CurrentWeapon[iId] == CSW_AWP) {
		rg_remove_all_items(iId);
		rg_give_item(iId, "weapon_knife");
		rg_give_item(iId, "weapon_awp");
	} else {
		rg_remove_all_items(iId);
		rg_give_item(iId, "weapon_knife");
		rg_give_item(iId, "weapon_scout");
	}

	g_SniperPower[iId] = 2;
}

public task__PowerCabezonOne(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	set_user_gravity(id, 999999.9);
}

public task__PowerCabezonTwo(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	emitSound(id, CHAN_VOICE, __SOUND_CABEZON_POWER_FINISH);

	new Float:vecOrigin[3];
	new iVictim = -1;

	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 1);
	write_short(UNIT_SECOND * 1);
	write_short(FFADE_IN);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(200);
	message_end();

	message_begin(MSG_BROADCAST, g_Message_ScreenShake);
	write_short(UNIT_SECOND * 14);
	write_short(UNIT_SECOND * 3);
	write_short(UNIT_SECOND * 14);
	message_end();

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 500.0)) != 0) {
		if(!isPlayerValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim]) {
			continue;
		}

		ExecuteHamB(Ham_Killed, iVictim, id, 2);
		++g_Achievement_CabezonKills[id];
	}

	set_user_gravity(id, 0.5);

	if(!g_Achievement_CabezonKills[id]) {
		setAchievement(id, CABEZON_Y_CIEGO);
	} else if(g_Achievement_CabezonKills[id] >= 40) {
		setAchievement(id, SUBE_Y_BAJA);

		if(g_Achievement_CabezonKills[id] >= 50) {
			setAchievement(id, SUBE_Y_BOOM);
		}
	}
}

public task__ModeCabezon() {
	playSound(0, __SOUND_CABEZON_POWER_FINISH);

	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 2);
	write_short(UNIT_SECOND * 2);
	write_short(FFADE_IN);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(175);
	message_end();

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsAlive[i]) {
			continue;
		}

		user_silentkill(i);
	}
}

public clcmd__MiniGames(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	showMenu__MiniGames(id);
	return PLUGIN_HANDLED;
}

public canUseMiniGames(const id) {
	new sCvar[32];
	new iCvarLen;

	get_pcvar_string(g_pCvar_CanUseMinigames, sCvar, charsmax(sCvar));
	iCvarLen = strlen(sCvar);

	if(iCvarLen <= 0) {
		return 0;
	}

	new iAccountId = 0;
	new iOk = 0;
	new i;

	for(i = 0; i < iCvarLen; ++i) {
		if(sCvar[i] != ' ') {
			iAccountId = str_to_num(sCvar[i]);

			if(g_AccountId[id] == iAccountId) {
				iOk = 1;
				break;
			}
		}
	}

	if(!iOk) {
		return 0;
	}

	return 1;
}

public showMenu__MiniGames(const id) {
	oldmenu_create("\yMINI-JUEGOS", "menu__MiniGames");

	if(!canUseMiniGames(id)) {
		if(g_MiniGames_Number[id] == 2000) {
			oldmenu_additem(1, 1, "\r1.\w Jugar a un número");
			oldmenu_additem(-1, -1, "\r - \wJuega un número del \y1 al 999\w y estarás participando");
			oldmenu_additem(-1, -1, "\r - \wpor algún premio específico por el administrador^n");
		} else {
			oldmenu_additem(-1, -1, "\wYa jugaste a un número");
			oldmenu_additem(-1, -1, "\wEspera a que se realice el sorteo y luego podrás volver a jugar");
		}
	} else {
		oldmenu_additem(1, 1, "\r1.\w Sortear un número al azar");
		oldmenu_additem(-1, -1, "\r - \wLos usuarios apuestan un número del \y1 al 999\w y al ganador");
		oldmenu_additem(-1, -1, "\r - \wse le otorga un premio en específico por el administrador^n");
		
		oldmenu_additem(2, 2, "\r3.\w Sortear Synapsis");
		oldmenu_additem(3, 3, "\r4.\w Sortear Tribal");
		oldmenu_additem(4, 4, "\r5.\w Sortear Sniper");
	}

	oldmenu_additem(0, 0, "^n\r0.\w Salir");
	oldmenu_display(id);
}

public menu__MiniGames(const id, const item) {
	if(item == 0) {
		return;
	}

	if(!canUseMiniGames(id)) {
		switch(item) {
			case 1: {
				if(g_MiniGames_Number[id] == 2000) {
					clientPrintColor(id, _, "Ingresa un número del !g1 al 999!y para jugar a los mini-juegos");
					client_cmd(id, "messagemode INGRESAR_NUMERO_AL_AZAR");
				} else {
					clientPrintColor(id, _, "Ya jugaste un número, espera a que se sortee y recién ahí podrás volver a jugar");
				}
			}
		}
	} else {
		if((1 <= item <= 5)) {
			g_MiniGames_NumberFake = 0;
		}

		switch(item) {
			case 1: {
				sortMiniGame(.number_fake=g_MiniGames_NumberFake);
			} case 2: {
				sortMiniGame(.mode=MODE_SYNAPSIS);
			} case 3: {
				sortMiniGame(.mode=MODE_TRIBAL);
			} case 4: {
				sortMiniGame(.mode=MODE_SNIPER);
			}
		}
	}
}

public clcmd__EnterRandomNum(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	new sNum[8];
	read_args(sNum, charsmax(sNum));
	remove_quotes(sNum);
	trim(sNum);

	if(containLetters(sNum) || !countNumbers(sNum) || equali(sNum, "") || containi(sNum, " ") != -1) {
		clientPrintColor(id, _, "Sólo números y sin espacios");
		return PLUGIN_HANDLED;
	}

	new iNum = str_to_num(sNum);

	if(!(1 <= iNum <= 999)) {
		clientPrintColor(id, _, "El número a apostar tiene que estar entre !g1 al 999!y");
		return PLUGIN_HANDLED;
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i] && g_MiniGames_Number[i]) {
			if(g_MiniGames_Number[i] == iNum) {
				clientPrintColor(id, _, "El usuario !t%s!y ya eligió este número, elige otro", g_PlayerName[i]);
				return PLUGIN_HANDLED;
			}
		}
	}

	g_MiniGames_Number[id] = iNum;

	clientPrintColor(id, _, "Jugaste al número !g%d!y", g_MiniGames_Number[id]);
	return PLUGIN_HANDLED;
}

public containLetters(const string[]) {
	new iLen = strlen(string);
	new i;
	
	for(i = 0; i < iLen; ++i) {
		if(!isalpha(string[i])) {
			return 0;
		}
	}
	
	return 1;
}

public countNumbers(const string[]) {
	new iLen = strlen(string);
	new i;

	for(i = 0; i < iLen; ++i) {
		if(isdigit(string[i])) {
			return 1;
		}
	}
	
	return 0;
}

sortMiniGame(const number_fake=0, const mode=0) {
	new i;
	new iRandomNumber[4] = {0, 0, 0, 0};

	switch(mode) {
		case 0: {
			if(!number_fake) {
				iRandomNumber[0] = random_num(1, 999);
			} else {
				iRandomNumber[0] = number_fake;
			}

			clientPrintColor(0, _, "Números ganadores: !g%d!y", iRandomNumber[0]);
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!(1 <= g_MiniGames_Number[i] <= 999)) {
					g_MiniGames_Number[i] = 2000;
				}
			}

			new iLocalNumber[MAX_PLAYERS + 1];
			new iWinner;
			new iMin;

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_LOGGED || g_MiniGames_Number[i] == 2000) {
					continue;
				}

				if(g_MiniGames_Number[i] == iRandomNumber[0]) {
					clientPrintColor(0, _, "El usuario !t%s!y ganó por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber[0]);

					g_MiniGames_Number[i] = 2000;

					setRewardWinner(i);
					return;
				}

				iLocalNumber[i] = g_MiniGames_Number[i];
				g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[0]);
			}
			
			iWinner = 0;
			iMin = 2000;

			for(i = 1; i <= MaxClients; ++i) {
				if(g_MiniGames_Number[i] < iMin) {
					iMin = g_MiniGames_Number[i];
					iWinner = i;
				}
			}

			if(iWinner) {
				clientPrintColor(0, _, "El usuario !t%s!y ganó por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);
				g_MiniGames_Number[iWinner] = 2000;
			}

			for(i = 1; i <= MaxClients; ++i) {
				g_MiniGames_Number[i] = 2000;
			}
		} case MODE_SYNAPSIS: {
			iRandomNumber[0] = random_num(1, 999);
			iRandomNumber[1] = iRandomNumber[0];
			iRandomNumber[2] = iRandomNumber[0];

			while(iRandomNumber[0] == iRandomNumber[1] || iRandomNumber[0] == iRandomNumber[2] || iRandomNumber[1] == iRandomNumber[2]) {
				iRandomNumber[1] = random_num(1, 999);
				iRandomNumber[2] = random_num(1, 999);
			}

			clientPrintColor(0, _, "Números ganadores: !g%d!y, !g%d!y y !g%d!y", iRandomNumber[0], iRandomNumber[1], iRandomNumber[2]);
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!(1 <= g_MiniGames_Number[i] <= 999)) {
					g_MiniGames_Number[i] = 2000;
				}
			}

			new iLocalNumber[MAX_PLAYERS + 1];
			new iWinner;
			new iMin;
			new k;

			for(k = 0; k < 3; ++k) {
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_LOGGED || g_MiniGames_Number[i] == 2000) {
						continue;
					}

					if(g_MiniGames_Number[i] == iRandomNumber[k]) {
						g_ModeSynapsis_Id[k] = i;

						clientPrintColor(0, _, "El usuario !t%s!y ganó el !tNEMESIS!y por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber[k]);
						
						g_MiniGames_Number[i] = 2000;

						setRewardWinner(i);
						return;
					}

					iLocalNumber[i] = g_MiniGames_Number[i];
					g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[k]);
				}

				iWinner = 0;
				iMin = 2000;

				for(i = 1; i <= MaxClients; ++i) {
					if(g_MiniGames_Number[i] < iMin) {
						iMin = g_MiniGames_Number[i];
						iWinner = i;
					}
				}

				if(iWinner) {
					g_ModeSynapsis_Id[k] = iWinner;

					clientPrintColor(0, _, "El usuario !t%s!y ganó el !tNEMESIS!y por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);

					g_MiniGames_Number[iWinner] = 2000;
				}
			}

			for(i = 1; i <= MaxClients; ++i) {
				g_MiniGames_Number[i] = 2000;
			}

			g_NextMode = MODE_SYNAPSIS;
		} case MODE_TRIBAL: {
			iRandomNumber[0] = random_num(1, 999);
			iRandomNumber[1] = iRandomNumber[0];

			while(iRandomNumber[0] == iRandomNumber[1]) {
				iRandomNumber[1] = random_num(1, 999);
			}

			clientPrintColor(0, _, "Números ganadores: !g%d!y y !g%d!y", iRandomNumber[0], iRandomNumber[1]);
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!(1 <= g_MiniGames_Number[i] <= 999)) {
					g_MiniGames_Number[i] = 2000;
				}
			}

			new iLocalNumber[MAX_PLAYERS + 1];
			new iWinner;
			new iMin;
			new k;

			for(k = 0; k < 2; ++k) {
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_LOGGED || g_MiniGames_Number[i] == 2000) {
						continue;
					}

					if(g_MiniGames_Number[i] == iRandomNumber[k]) {
						g_ModeTribal_Id[k] = i;

						clientPrintColor(0, _, "El usuario !t%s!y ganó el !tTRIBAL!y por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber[k]);
						
						g_MiniGames_Number[i] = 2000;

						setRewardWinner(i);
						return;
					}

					iLocalNumber[i] = g_MiniGames_Number[i];
					g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[k]);
				}

				iWinner = 0;
				iMin = 2000;

				for(i = 1; i <= MaxClients; ++i) {
					if(g_MiniGames_Number[i] < iMin) {
						iMin = g_MiniGames_Number[i];
						iWinner = i;
					}
				}

				if(iWinner) {
					g_ModeTribal_Id[k] = iWinner;
					
					clientPrintColor(0, _, "El usuario !t%s!y ganó el !tTRIBAL!y por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);

					g_MiniGames_Number[iWinner] = 2000;
				}
			}

			for(i = 1; i <= MaxClients; ++i) {
				g_MiniGames_Number[i] = 2000;
			}

			g_NextMode = MODE_TRIBAL;
		} case MODE_SNIPER: {
			iRandomNumber[0] = random_num(1, 999);
			iRandomNumber[1] = iRandomNumber[0];
			iRandomNumber[2] = iRandomNumber[0];
			iRandomNumber[3] = iRandomNumber[0];

			while(iRandomNumber[0] == iRandomNumber[1] || iRandomNumber[0] == iRandomNumber[2] || iRandomNumber[0] == iRandomNumber[3] || iRandomNumber[1] == iRandomNumber[2] || iRandomNumber[1] == iRandomNumber[3] || iRandomNumber[2] == iRandomNumber[3]) {
				iRandomNumber[1] = random_num(1, 999);
				iRandomNumber[2] = random_num(1, 999);
				iRandomNumber[3] = random_num(1, 999);
			}

			clientPrintColor(0, _, "Números ganadores: !g%d!y, !g%d!y, !g%d!y y !g%d!y", iRandomNumber[0], iRandomNumber[1], iRandomNumber[2], iRandomNumber[3]);
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!(1 <= g_MiniGames_Number[i] <= 999)) {
					g_MiniGames_Number[i] = 2000;
				}
			}

			new iLocalNumber[MAX_PLAYERS + 1];
			new iWinner;
			new iMin;
			new k;

			for(k = 0; k < 4; ++k) {
				for(i = 1; i <= MaxClients; ++i) {
					if(!g_IsConnected[i] || g_AccountStatus[i] < STATUS_LOGGED || g_MiniGames_Number[i] == 2000) {
						continue;
					}

					if(g_MiniGames_Number[i] == iRandomNumber[k])
					{
						g_ModeSniper_Id[k] = i;

						clientPrintColor(0, _, "El usuario !t%s!y ganó el !tSNIPER!y por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber[k]);
						
						g_MiniGames_Number[i] = 2000;

						setRewardWinner(i);
						return;
					}

					iLocalNumber[i] = g_MiniGames_Number[i];
					g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[k]);
				}

				iWinner = 0;
				iMin = 2000;

				for(i = 1; i <= MaxClients; ++i) {
					if(g_MiniGames_Number[i] < iMin) {
						iMin = g_MiniGames_Number[i];
						iWinner = i;
					}
				}

				if(iWinner) {
					g_ModeSniper_Id[k] = iWinner;
					
					clientPrintColor(0, _, "El usuario !t%s!y ganó el !tSNIPER!y por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);

					g_MiniGames_Number[iWinner] = 2000;
				}
			}

			for(i = 1; i <= MaxClients; ++i) {
				g_MiniGames_Number[i] = 2000;
			}

			g_NextMode = MODE_SNIPER;
		}
	}
}

public setRewardWinner(const id) {
	new iRandom = random_num(1, 100);

	switch(iRandom) {
		case 1..25: {
			new iRandomLevel = random_num(5, 25);

			if((g_Level[id] + iRandomLevel) > MAX_LEVEL) {
				g_Level[id] = MAX_LEVEL;
			} else {
				g_Level[id] += iRandomLevel;
			}

			g_XP[id] = 0;

			clientPrintColor(0, _, "El usuario !t%s!y ganó !g%d nivel%s!y por acertar al número exacto", g_PlayerName[id], iRandomLevel, ((iRandomLevel != 1) ? "es" : ""));
			checkXPEquation(id);
		} case 26..50: {
			g_Points[id][P_HUMAN] += 25;
			g_Points[id][P_ZOMBIE] += 25;
			g_Points[id][P_MONEY] += 25;
			g_Points[id][P_LEGACY] += 25;

			clientPrintColor(0, _, "El usuario !t%s!y ganó !g25 pHZLE!y por acertar al número exacto", g_PlayerName[id]);
		} case 51..75: {
			++g_Hab[id][HAB_H_DAMAGE];
			clientPrintColor(0, _, "El usuario !t%s!y ganó !g+1 DAÑO HUMANO!y por acertar al número exacto", g_PlayerName[id]);
		} case 76..99: {
			++g_Hab[id][HAB_Z_HEALTH];
			clientPrintColor(0, _, "El usuario !t%s!y ganó !g+1 VIDA ZOMBIE!y por acertar al número exacto", g_PlayerName[id]);
		} case 100: {
			++g_Points[id][P_DIAMONDS];
			clientPrintColor(0, _, "El usuario !t%s!y ganó !g1 DIAMANTE!y por acertar al número exacto", g_PlayerName[id]);
		}
	}
}

public clcmd__MgNumber(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	new sArg1[8];
	read_argv(1, sArg1, charsmax(sArg1));

	g_MiniGames_NumberFake = str_to_num(sArg1);
	return PLUGIN_HANDLED;
}

new const __CAN_USE_GRAB[] = {1, 2};

public clcmd__GrabOn(const id) {
	if(!g_IsConnected[id]) {
		return PLUGIN_HANDLED;
	}

	new iOk = 0;
	new i;

	for(i = 0; i < sizeof(__CAN_USE_GRAB); ++i) {
		if(g_AccountId[id] == __CAN_USE_GRAB[i]) {
			iOk = 1;
			break;
		}
	}

	if(!iOk || g_Grab[id]) {
		return PLUGIN_HANDLED;
	}

	g_Grab[id] = -1;

	new iTarget;
	new iBody;

	get_user_aiming(id, iTarget, iBody);

	if(isPlayerValidAlive(iTarget) && iTarget != id) {
		if(iTarget <= MaxClients) {
			if(isPlayerValidAlive(iTarget)) {
				grabUser(id, iTarget);
			}
		} else if(entity_get_int(iTarget, EV_INT_solid) != SOLID_BSP) {
			grabUser(id, iTarget);
		}
	} else {
		remove_task(id + TASK_GRAB);
		set_task(0.1, "task__GrabOn", id + TASK_GRAB);
	}

	return PLUGIN_HANDLED;
}

public clcmd__GrabOff(const id) {
	if(!g_IsConnected[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_Grab[id] == -1) {
		g_Grab[id] = 0;
		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	} else if(g_Grab[id]) {
		if(g_Grab[id] <= MaxClients && isPlayerValidAlive(g_Grab[id])) {
			set_user_gravity(g_Grab[id], g_GrabGravity[g_Grab[id]]);
		}

		g_Grab[id] = 0;
	}

	return PLUGIN_HANDLED;
}

public grabUser(const id, const target) {
	g_Grab[id] = target;

	if(target <= MaxClients) {
		g_GrabGravity[target] = get_user_gravity(target);
		set_user_gravity(target, 0.0);
	}

	g_GrabDistance[id] = 0.0;

	remove_task(id + TASK_GRAB_PRETHINK);
	set_task(0.1, "task__GrabPrethink", id + TASK_GRAB_PRETHINK, .flags="b");

	// task__GrabPrethink(id + TASK_GRAB_PRETHINK);
}

public task__GrabOn(const task_id) {
	new iId = (task_id - TASK_GRAB_PRETHINK);

	if(!g_IsConnected[iId]) {
		return;
	}

	new  iTarget;
	new iBody;

	get_user_aiming(iId, iTarget, iBody);

	if(isPlayerValidAlive(iTarget) && iTarget != iId) {
		if(iTarget <= MaxClients) {
			if(isPlayerValidAlive(iTarget)) {
				grabUser(iId, iTarget);
			}
		}
		else if(entity_get_int(iTarget, EV_INT_solid) != SOLID_BSP) {
			grabUser(iId, iTarget);
		}
	} else {
		remove_task(iId + TASK_GRAB);
		set_task(0.1, "task__GrabOn", iId + TASK_GRAB);
	}
}

public task__GrabPrethink(const task_id) {
	new iId = (task_id - TASK_GRAB_PRETHINK);

	if(!g_IsConnected[iId] && g_Grab[iId] > 0) {
		if(g_Grab[iId] <= MaxClients && isPlayerValidAlive(g_Grab[iId])) {
			set_user_gravity(g_Grab[iId], g_GrabGravity[g_Grab[iId]]);
		}

		g_Grab[iId] = 0;
	}

	if(g_Grab[iId] <= 0) {
		remove_task(iId + TASK_GRAB_PRETHINK);
		return;
	}

	static vecOrigin[3];
	static Float:vecOriginFloat[3];
	static vecOriginBeam[3];
	static vecOriginType3[3];

	get_user_origin(iId, vecOrigin);
	entity_get_vector(g_Grab[iId], EV_VEC_origin, vecOriginFloat);

	vecOriginBeam[0] = floatround(vecOriginFloat[0]);
	vecOriginBeam[1] = floatround(vecOriginFloat[1]);
	vecOriginBeam[2] = floatround(vecOriginFloat[2]);

	get_user_origin(iId, vecOriginType3, 3);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT);
	write_short(iId);
	write_coord(vecOriginBeam[0]);
	write_coord(vecOriginBeam[1]);
	write_coord(vecOriginBeam[2]);
	write_short(g_Sprite_Trail);
	write_byte(1);
	write_byte(1);
	write_byte(1);
	write_byte(5);
	write_byte(0);
	write_byte(random(256));
	write_byte(random(256));
	write_byte(random(256));
	write_byte(175);
	write_byte(0);
	message_end();

	static Float:origin1_F[3];
	static Float:origin3_F[3];

	origin1_F[0] = float(vecOrigin[0]);
	origin1_F[1] = float(vecOrigin[1]);
	origin1_F[2] = float(vecOrigin[2]);
	origin3_F[0] = float(vecOriginType3[0]);
	origin3_F[1] = float(vecOriginType3[1]);
	origin3_F[2] = float(vecOriginType3[2]);

	static Float:flDistance[3];

	if(!g_GrabDistance[iId]) {
		flDistance[0] = floatabs(origin1_F[0] - vecOriginFloat[0]);
		flDistance[1] = floatabs(origin1_F[1] - vecOriginFloat[1]);
		flDistance[2] = floatabs(origin1_F[2] - vecOriginFloat[2]);

		g_GrabDistance[iId] = floatsqroot((flDistance[0] * flDistance[0]) + (flDistance[1] * flDistance[1]) + (flDistance[2] * flDistance[2]));
	}

	flDistance[0] = origin3_F[0] - origin1_F[0];
	flDistance[1] = origin3_F[1] - origin1_F[1];
	flDistance[2] = origin3_F[2] - origin1_F[2];

	static Float:flGrabDistance;
	static Float:flDivideDistance;
	static Float:origin4[3];
	static Float:velocity[3];

	flGrabDistance = floatsqroot((flDistance[0] * flDistance[0]) + (flDistance[1] * flDistance[1]) + (flDistance[2] * flDistance[2]));
	flDivideDistance = g_GrabDistance[iId] / flGrabDistance;

	origin4[0] = (flDistance[0] * flDivideDistance) + origin1_F[0];
	origin4[1] = (flDistance[1] * flDivideDistance) + origin1_F[1];
	origin4[2] = (flDistance[2] * flDivideDistance) + origin1_F[2];

	velocity[0] = (origin4[0] - vecOriginFloat[0]) * 15.0;
	velocity[1] = (origin4[1] - vecOriginFloat[1]) * 15.0;
	velocity[2] = (origin4[2] - vecOriginFloat[2]) * 15.0;

	set_user_velocity(g_Grab[iId], velocity);
}

public basePlayer__HintMessageExPre(const id, const message[], Float:duration, bool:bDisplayIfPlayerDead, bool:bOverride) {
	SetHookChainReturn(ATYPE_BOOL, false);
	return HC_SUPERCEDE;
}

public gameRules__DeadPlayerWeaponsPre(const id) {
	SetHookChainReturn(ATYPE_INTEGER, GR_PLR_DROP_GUN_NO);
	return HC_SUPERCEDE;
}

public clcmd__Test(const id) {
	if(!g_IsConnected[id] || g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

sendFog(const id, const color_r=0, const color_g=0, const color_b=0, const pure_density=0) {
	if(!id) {
		message_begin(MSG_ALL, g_Message_Fog);
	} else {
		message_begin(MSG_ONE, g_Message_Fog, _, id);
	}

	write_byte(color_r);
	write_byte(color_g);
	write_byte(color_b);
	switch(pure_density) {
		case 0: {
			write_byte(0);
			write_byte(0);
			write_byte(0);
			write_byte(0);
		} case 1: { // 111, 18, 3, 58 | 111, 18, 125, 58
			write_byte(111);
			write_byte(18);
			write_byte(125);
			write_byte(58);
		} case 2: { // 111, 18, 125, 59 | 111, 18, 3, 60
			write_byte(111);
			write_byte(18);
			write_byte(125);
			write_byte(59);
		}
	}

	message_end();
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

	if(g_AccountStatus[id] != STATUS_CHECK_ACCOUNT && g_AccountStatus[id] != STATUS_LOADING) {
		if(g_AccountStatus[id] == STATUS_BANNED) {
			showMenu__Banned(id);
		} else if(g_AccountStatus[id] == STATUS_LOGGED) {
			showMenu__Join(id);
		} else if(g_AccountStatus[id] == STATUS_PLAYING) {
			showMenu__Game(id);
		}else {
			showMenu__LogIn(id);
		}

		SetHookChainReturn(ATYPE_INTEGER, 0);
	}

	return HC_BREAK;
}

public onClient__HandleMenuChooseTeamPre(const id, const MenuChooseTeam:slot) {
	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

public TeamName:getUserTeam(const id) {
	return get_member(id, m_iTeam);
}

public setUserTeam(const id, const TeamName:team) {
	rg_set_user_team(id, team);
}

getUnixToTime(const unix, const prefix=0) {
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

	formatex(sBuffer, charsmax(sBuffer), "%d-%02d-%02d%s%02d:%02d:%02d", iYear, iMonth, iDay, ((prefix) ? " a las " : " "), iHour, iMinute, iSecond);
	return sBuffer;
}

public getCooldDownTime(const seconds) {
	new sTime[32];
	sTime[0] = EOS;

	if(seconds <= 0) {
		return sTime;
	}

	formatex(sTime, charsmax(sTime), "%02d:%02d %s%s", (seconds / 60), (seconds % 60), ((seconds < 60) ? "segundo" : "minuto"), (((seconds < 60 && seconds == 1) || (seconds >= 60 && seconds < 120)) ? "" : "s"));
	return sTime;
}

public isAlphanumeric(const string[]) {
	new iLen = strlen(string);
	new i;

	for(i = 0; i < iLen; ++i) {
		if(!isLetter(string[i]) && !isDigit(string[i])) {
			return 0;
		}
	}

	return 1;
}

public generateCode(const id) {
	g_AccountCode[id][0] = EOS;

	new i;
	for(i = 0; i < MAX_STRING_CODE; ++i) {
		g_AccountCode[id][i] = ((random(2) > 0) ? random_num(48, 57) : random_num(65, 90));
	}
}

public clcmd__BanAccount(const id) {
	if(!g_IsConnected[id] || !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new sName[MAX_NAME_LENGTH];
	new sDays[8];
	new sReason[128];

	read_argv(1, sName, charsmax(sName));
	read_argv(2, sDays, charsmax(sDays));
	read_argv(3, sReason, charsmax(sReason));

	remove_quotes(sDays);
	remove_quotes(sReason);

	replace_all(sName, charsmax(sName), "\0\", "~");
	replace_all(sName, charsmax(sName), "\", "");
	replace_all(sName, charsmax(sName), "/", "");
	replace_all(sName, charsmax(sName), "DROP TABLE", "");
	replace_all(sName, charsmax(sName), "TRUNCATE", "");
	replace_all(sName, charsmax(sName), "INSERT INTO", "");
	replace_all(sName, charsmax(sName), "INSERT UPDATE", "");
	replace_all(sName, charsmax(sName), "UPDATE", "");

	replace_all(sReason, charsmax(sReason), "'", "");
	replace_all(sReason, charsmax(sReason), "\", "");
	replace_all(sReason, charsmax(sReason), "DROP TABLE", "");
	replace_all(sReason, charsmax(sReason), "TRUNCATE", "");
	replace_all(sReason, charsmax(sReason), "INSERT INTO", "");
	replace_all(sReason, charsmax(sReason), "INSERT UPDATE", "");
	replace_all(sReason, charsmax(sReason), "UPDATE", "");

	if(read_argc() < 4) {
		consolePrint(id, "El comando debe ser introducido de la siguiente manera: zp_ban <NOMBRE COMPLETO> <DIAS> <RAZON OBLIGATORIA>");
		consolePrint(id, "Ingrese 0 dias para banearlo permanentemente");

		return PLUGIN_HANDLED;
	} else if(containLetters(sDays) || !countNumbers(sDays) || equali(sDays, "") || containi(sDays, " ") != -1) {
		consolePrint(id, "El campo de DÍAS tiene que contener sólo números");
		return PLUGIN_HANDLED;
	} else if(equali(sReason, "")) {
		consolePrint(id, "El campo RAZÓN no puede estar vacio");
		return PLUGIN_HANDLED;
	}

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id, name, last_ip, last_steam FROM zp8_accounts WHERE name=^"%s^";", sName);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 30);
	} else if(SQL_NumResults(sqlQuery)) {
		new iAccountId;
		new sNameDB[MAX_NAME_LENGTH];
		new sLastIpDB[MAX_IP_LENGTH];
		new sLastSteamDB[MAX_AUTHID_LENGTH];

		iAccountId = SQL_ReadResult(sqlQuery, 0);
		SQL_ReadResult(sqlQuery, 1, sNameDB, charsmax(sNameDB));
		SQL_ReadResult(sqlQuery, 2, sLastIpDB, charsmax(sLastIpDB));
		SQL_ReadResult(sqlQuery, 3, sLastSteamDB, charsmax(sLastSteamDB));

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_bans WHERE acc_id='%d' AND active='1';", iAccountId);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 31);
		} else if(SQL_NumResults(sqlQuery)) {
			consolePrint(id, "El jugador indicado ya está baneado");
			SQL_FreeHandle(sqlQuery);
		} else {
			SQL_FreeHandle(sqlQuery);

			new iDays = str_to_num(sDays);
			new iFinishBan;

			if(iDays <= 0) {
				clientPrintColor(0, _, "!t%s!y baneo la cuenta de !g%s!y permanentemente - Razón !t[!g%s!t]!y", g_PlayerName[id], sNameDB, sReason);
				iFinishBan = 2000000000;

				log_to_file(__BANS_FILE, "Administrador <%s> - Baneó la cuenta de <%s> - Tiempo <permanentemente> - Razón <%s>", g_PlayerName[id], sNameDB, sReason);
			} else {
				clientPrintColor(0, _, "!t%s!y baneo la cuenta de !g%s!y durante !g%d día%s!y - Razón !t[!g%s!t]!y", g_PlayerName[id], sNameDB, iDays, ((iDays != 1) ? "s" : ""), sReason);
				iFinishBan = (get_arg_systime() + (((iDays * 24) * 60) * 60));

				log_to_file(__BANS_FILE, "Administrador <%s> - Baneó la cuenta de <%s> - Tiempo <%d día%s> - Razón <%s>", g_PlayerName[id], sNameDB, iDays, ((iDays != 1) ? "s" : ""), sReason);
			}

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_bans (acc_id, ip, steam, staff_name, start, finish, reason) VALUES ('%d', ^"%s^", ^"%s^", ^"%s^", '%d', '%d', ^"%s^");", iAccountId, sLastIpDB, sLastSteamDB, g_PlayerName[id], get_arg_systime(), iFinishBan, sReason);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			new iTargetId;
			iTargetId = get_user_index(sNameDB);

			if(isPlayerValidConnected(iTargetId)) {
				console_print(iTargetId, "");
				console_print(iTargetId, "********** %s [%s] **********", __PLUGIN_NAME, __PLUGIN_COMMUNITY_FORUM);
				console_print(iTargetId, "");
				console_print(iTargetId, "TU CUENTA ESTA BANEADA");
				console_print(iTargetId, "");
				console_print(iTargetId, "Administrador que te baneo: %s", g_PlayerName[id]);
				console_print(iTargetId, "El ban fue realizado en la fecha: %s", getUnixToTime(get_arg_systime(), 1));
				console_print(iTargetId, "El ban expira en la fecha: %s", getUnixToTime(iFinishBan, 1));
				console_print(iTargetId, "Razón: %s", sReason);
				console_print(iTargetId, "");
				console_print(iTargetId, "Cuenta #%d", g_AccountId[iTargetId]);
				if(g_AccountVinc[iTargetId]) {
					console_print(iTargetId, "Cuenta del Foro #%d", g_AccountVinc[iTargetId]);
				} else {
					console_print(iTargetId, "Este jugador no tiene la cuenta vinculada al foro");
				}
				console_print(iTargetId, "");
				console_print(iTargetId, "********** %s [%s] **********", __PLUGIN_NAME, __PLUGIN_COMMUNITY_FORUM);
				console_print(iTargetId, "");
				console_print(iTargetId, "");

				rh_drop_client(iTargetId, fmt("Tu cuenta ha sido baneada, mira tu consola. Para consultar sobre la misma, haz la denuncia en el foro %s", __PLUGIN_COMMUNITY_FORUM));
			}
		}
	} else {
		consolePrint(id, "El jugador indicado no existe. Recorda escribir su nombre completamente respetando mayusculas y minusculas");
		SQL_FreeHandle(sqlQuery);
	}

	return PLUGIN_HANDLED;
}

public clcmd__UnBanAccount(const id) {
	if(!g_IsConnected[id] || !(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}
	
	new sName[32];
	read_argv(1, sName, charsmax(sName));

	replace_all(sName, charsmax(sName), "\0\", "~");
	replace_all(sName, charsmax(sName), "\", "");
	replace_all(sName, charsmax(sName), "/", "");
	replace_all(sName, charsmax(sName), "DROP TABLE", "");
	replace_all(sName, charsmax(sName), "TRUNCATE", "");
	replace_all(sName, charsmax(sName), "INSERT INTO", "");
	replace_all(sName, charsmax(sName), "INSERT UPDATE", "");
	replace_all(sName, charsmax(sName), "UPDATE", "");

	if(read_argc() < 2) {
		consolePrint(id, "El comando debe ser introducido de la siguiente manera: zp_unban <NOMBRE COMPLETO>");
		return PLUGIN_HANDLED;
	}

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id, name FROM zp8_accounts WHERE name=^"%s^";", sName);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 35);
	} else if(SQL_NumResults(sqlQuery)) {
		new iAccountId;
		new sNameDB[MAX_NAME_LENGTH];

		iAccountId = SQL_ReadResult(sqlQuery, 0);
		SQL_ReadResult(sqlQuery, 1, sNameDB, charsmax(sNameDB));

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp8_bans WHERE acc_id='%d' AND active='1';", iAccountId);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 36);
		} else if(SQL_NumResults(sqlQuery)) {
			SQL_FreeHandle(sqlQuery);

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp8_bans SET active='0' WHERE acc_id='%d';", iAccountId);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			clientPrintColor(0, _, "!t%s!y desbaneo la cuenta de !g%s!y", g_PlayerName[id], sName);
			consolePrint(id, "El jugador indicado fue desbaneado");

			log_to_file(__BANS_FILE, "Administrador <%s> - Desbaneó la cuenta de <%s>", g_PlayerName[id], sName);
		} else {
			consolePrint(id, "El jugador indicado no esta baneado");
			SQL_FreeHandle(sqlQuery);
		}
	} else {
		consolePrint(id, "El jugador indicado no existe. Recorda escribir su nombre completamente respetando mayusculas y minusculas");
		SQL_FreeHandle(sqlQuery);
	}

	return PLUGIN_HANDLED;
}

public showMenu__DailyVisits(const id) {
	oldmenu_create("\yVISITAS DIARIAS", "menu__DailyVisits");

	oldmenu_additem(-1, -1, "\wVisitas diarias totales\r:\y %d", g_DailyVisits[id]);
	oldmenu_additem(-1, -1, "\wVisitas diarias consecutivas\r:\y %d^n", g_Consecutive_DailyVisits[id]);

	oldmenu_additem(-1, -1, "\wBonus de Combo\r:\y +%0.2f^n", (float(g_Consecutive_DailyVisits[id]) * 0.0066));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__DailyVisits(const id, const item) {
	if(!item) {
		showMenu__Game(id);
	}
}

public task__VoteMap() {
	g_VoteMap_Init = 1;

	set_cvar_string("amx_nextmap", "[en progreso]");

	new sMenu[MAX_FMT_VOTEMAP_MENU];
	new iLen = (MAX_FMT_VOTEMAP_MENU - 1);
	new iPosition = formatex(sMenu, iLen, "\yELIGE EL PRÓXIUMO MAPA^n\wLo marcado en \yamarillo\w es el bonus de XP otorgado^n^n");
	new iRandom;
	new iKeys = (1<<(g_VoteMap_SelectMaps + 1));
	new iMax = (g_VoteMap_Count > g_VoteMap_SelectMaps) ? g_VoteMap_SelectMaps : g_VoteMap_Count;

	for(g_VoteMap_i = 0; g_VoteMap_i < iMax; ++g_VoteMap_i) {
		iRandom = random_num(0, (g_VoteMap_Count - 1));

		while(getMapRandomIn(iRandom)) {
			++iRandom;

			if(iRandom >= g_VoteMap_Count) {
				iRandom = 0;
			}
		}

		g_VoteMap_Next[g_VoteMap_i] = iRandom;

		if(g_VoteMap_Recent[iRandom]) {
			iPosition += formatex(sMenu[iPosition], iLen, "\r%d.\w %s \r(sin bonus)^n", (g_VoteMap_i + 1), g_VoteMap_MapName[iRandom]);
		} else {
			iPosition += formatex(sMenu[iPosition], iLen, "\r%d.\w %s \y(+x%0.2f de XP)^n", (g_VoteMap_i + 1), g_VoteMap_MapName[iRandom], g_VoteMap_Bonus[iRandom]);
		}

		iKeys |= (1<<g_VoteMap_i);

		g_VoteMap_VoteCount[g_VoteMap_i] = 0;
	}

	sMenu[iPosition++] = '^n';

	g_VoteMap_VoteCount[g_VoteMap_SelectMaps] = 0;
	g_VoteMap_VoteCount[(g_VoteMap_SelectMaps + 1)] = 0;

	if(!g_VoteMap_Force && g_VoteMap_Extend < 3) {
		iPosition += formatex(sMenu[iPosition], iLen, "\r%d.\w Extender el mapa 15 minutos más^n", (g_VoteMap_SelectMaps + 1));
		iKeys |= (1<<g_VoteMap_SelectMaps);
	}

	formatex(sMenu[iPosition], iLen, "\r0.\w No Votar");

	show_menu(0, iKeys, sMenu, 20, "VoteMap Menu");

	remove_task(TASK_VOTEMAP_END);
	set_task(20.1, "task__VoteMapEnd", TASK_VOTEMAP_END);

	clientPrintColor(0, _, "Es momento de elegir el próximo mapa");

	client_cmd(0, "spk gman/gman_choose1");
}

public getMapRandomIn(const random) {
	new i;
	for(i = 0; i < g_VoteMap_i; ++i) {
		if(random == g_VoteMap_Next[i]) {
			return 1;
		}
	}
	
	return 0;
}

public menu__VoteMap(const id, const key) {
	if(!g_IsConnected[id] || key == 9) {
		return PLUGIN_HANDLED;
	}

	++g_VoteMap_VoteCount[key];

	if(key == 7 && g_VoteMap_Extend < 3) {
		clientPrintColor(id, _, "Votaste por extender el mapa");
	} else {
		clientPrintColor(id, _, "Votaste por el mapa !g%s!y.", g_VoteMap_MapName[g_VoteMap_Next[key]]);
	}

	if((get_user_flags(id) & ADMIN_RESERVATION)) {
		++g_VoteMap_VoteCount[key];
		clientPrintColor(id, _, "Tu voto vale !gx2!y ya que eres !tVIP!y o superior.");
	}

	return PLUGIN_HANDLED;
}

public task__VoteMapEnd() {
	g_VoteMap_Init = 2;

	new i;
	new j = 0;
	new iMaxVotes;

	for(i = 0; i < g_VoteMap_i; ++i) {
		if(g_VoteMap_VoteCount[j] < g_VoteMap_VoteCount[i]) {
			j = i;
		}
	}

	for(i = 0; i <= g_VoteMap_SelectMaps; ++i) {
		iMaxVotes += g_VoteMap_VoteCount[i];
	}

	if(g_VoteMap_VoteCount[g_VoteMap_SelectMaps] > g_VoteMap_VoteCount[j] && g_VoteMap_VoteCount[g_VoteMap_SelectMaps] > g_VoteMap_VoteCount[(g_VoteMap_SelectMaps + 1)]) {
		g_VoteMap_Init = 0;
		++g_VoteMap_Extend;

		set_cvar_string("amx_nextmap", "[ninguno]");

		set_cvar_float("mp_timelimit", (get_cvar_float("mp_timelimit") + 15.0));
		clientPrintColor(0, _, "El mapa actual se extenderá !g15 minutos más!y con !g%d!y / !g%d!y voto%s", g_VoteMap_VoteCount[g_VoteMap_SelectMaps], iMaxVotes, ((g_VoteMap_VoteCount[g_VoteMap_SelectMaps] != 1) ? "s" : ""));

		remove_task(TASK_VOTEMAP);
		remove_task(TASK_VOTEMAP_END);
		remove_task(TASK_CHANGEMAP_PRE);
		remove_task(TASK_CHANGEMAP);

		set_task(900.0, "task__VoteMap", TASK_VOTEMAP);

		for(i = 0; i < MAX_VOTEMAP; ++i) {
			g_VoteMap_Next[i] = 0;
			g_VoteMap_VoteCount[i] = 0;
		}

		return;
	}

	new sMap[32];
	sMap[0] = EOS;

	if(g_VoteMap_VoteCount[j] && g_VoteMap_VoteCount[(g_VoteMap_SelectMaps + 1)] <= g_VoteMap_VoteCount[j]) {
		copy(sMap, charsmax(sMap), g_VoteMap_MapName[g_VoteMap_Next[j]]);
		set_cvar_string("amx_nextmap", sMap);

		clientPrintColor(0, _, "El mapa ganador es !g%s!y con !g%d!y / !g%d!y voto%s", sMap, g_VoteMap_VoteCount[j], iMaxVotes, ((g_VoteMap_VoteCount[j] != 1) ? "s" : ""));

		remove_task(TASK_CHANGEMAP_PRE);

		if(g_VoteMap_Force) {
			task__ChangeMapPre__NextRound();
		} else {
			set_task(float((get_timeleft() - 5)), "task__ChangeMapPre__NextRound", TASK_CHANGEMAP_PRE);
		}
	}
	
	if(!sMap[0]) {
		if(iMaxVotes != 0) {
			log_to_file(__MAP_ERRORS_FILE, "El mapa ganador es %s con %d / %d voto%s", sMap, g_VoteMap_VoteCount[j], iMaxVotes, (g_VoteMap_VoteCount[j] != 1) ? "s" : "");
			log_to_file(__MAP_ERRORS_FILE, "j=%d^ng_VoteMap_VoteCount[j]=%d^ng_VoteMap_VoteCount[(g_VoteMap_SelectMaps + 1)]=%d<=g_VoteMap_VoteCount[j]=%d^nsMap=%s", j, g_VoteMap_VoteCount[j], g_VoteMap_VoteCount[(g_VoteMap_SelectMaps + 1)], g_VoteMap_VoteCount[j], sMap);
		}

		set_cvar_string("amx_nextmap", "zpl_pibes_cabezita_v2");

		remove_task(TASK_CHANGEMAP_PRE);
		set_task(float((get_timeleft() - 5)), "task__ChangeMapPre", TASK_CHANGEMAP_PRE);

		if(iMaxVotes != 0) {
			log_to_file(__MAP_ERRORS_FILE, "Cambiando a sMap = %s^n^n", sMap);
		}
	}
}

public task__ChangeMapPre() {
	message_begin(MSG_ALL, SVC_INTERMISSION);
	message_end();

	remove_task(TASK_CHANGEMAP);
	set_task(4.0, "task__ChangeMap", TASK_CHANGEMAP);
}

public task__ChangeMapPre__NextRound() {
	g_VoteMap_NextRound = 1;

	set_cvar_num("mp_timelimit", 0);

	clientPrintColor(0, _, "El mapa cambiará a !g%s!y una vez finalizada la ronda", getNextMap());
}

public task__ChangeMap() {
	server_cmd("changelevel %s", getNextMap());
}

public clcmd__CurrentMap(const id) {
	if(g_AccountId[id] == 1) {
		clientPrintColor(id, _, "El mapa actual es !g%s!y (%d)", g_CurrentMap, g_VoteMap_MapId);
	} else {
		clientPrintColor(id, _, "El mapa actual es !g%s!y", g_CurrentMap);
	}

	return PLUGIN_HANDLED;
}

public clcmd__NextMap(const id) {
	new sNextMap[32];
	formatex(sNextMap, charsmax(sNextMap), "%s", getNextMap());

	clientPrintColor(id, _, "El siguiente mapa es !g%s!y", sNextMap);
	return PLUGIN_HANDLED;
}

public showMenu__ModelsDifficults(const id) {
	oldmenu_create("\yMODELS / DIFICULTADES", "menu__ModelsDifficults");

	oldmenu_additem(1, 1, "\r1.\w Models Humanos");
	oldmenu_additem(2, 2, "\r2.\w Models Zombies^n");

	oldmenu_additem(3, 3, "\r3.\w Dificultad Survivor");
	oldmenu_additem(4, 4, "\r4.\w Dificultad Wesker");
	oldmenu_additem(5, 5, "\r5.\w Dificultad Leatherface");
	oldmenu_additem(6, 6, "\r6.\w Dificultad Nemesis");
	oldmenu_additem(7, 7, "\r7.\w Dificultad Cabezón");
	oldmenu_additem(8, 8, "\r8.\w Dificultad Aniquilador^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ModelsDifficults(const id, const item, const value) {
	if(!item) {
		showMenu__Game(id);
	} else if(item == 1 || item == 2) {
		clientPrintColor(id, _, "En construcción");
		showMenu__ModelsDifficults(id);
	} else {
		showMenu__Difficults(id, (value - 3));
	}
}

public showMenu__Difficults(const id, const class) {
	g_MenuData[id][MENU_DATA_DIFFICULT_CLASS_ID] = class;

	oldmenu_create("\yDIFICULTAD %s", "menu__Difficults", __DIFFICULTS_CLASSES[class]);

	new i;
	new j;

	for(i = 0, j = 1; i < structIdDifficults; ++i, ++j) {
		if(g_Difficult[id][class] == i) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ELEGIDO)", j, __DIFFICULTS[class][i][difficultName]);
			oldmenu_additem(-1, -1, "\r - \w%s^n", __DIFFICULTS[class][i][difficultInfo]);
		} else {
			oldmenu_additem(j, i, "\r%d.\w %s", j, __DIFFICULTS[class][i][difficultName]);
			oldmenu_additem(-1, -1, "\r - \w%s^n", __DIFFICULTS[class][i][difficultInfo]);
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Difficults(const id, const item, const value) {
	if(!item) {
		showMenu__ModelsDifficults(id);
	} else {
		new iDifficultClass = g_MenuData[id][MENU_DATA_DIFFICULT_CLASS_ID];

		if(!g_NewRound && !g_EndRound &&
		(g_Mode == MODE_SURVIVOR || g_Mode == MODE_WESKER || g_Mode == MODE_LEATHERFACE ||
		g_Mode == MODE_NEMESIS || g_Mode == MODE_CABEZON || g_Mode == MODE_ANNIHILATOR)) {
			clientPrintColor(id, _, "No puedes cambiar la dificultad en un modo especial");

			showMenu__Difficults(id, iDifficultClass);
			return;
		} else if(g_AccountId[id] != 1 && value == DIFFICULT_HARD &&
		((iDifficultClass == DIFFICULT_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_PRINCIPIANTE]) ||
		(iDifficultClass == DIFFICULT_CLASS_WESKER && !g_Achievement[id][WESKER_PRINCIPIANTE]) || 
		(iDifficultClass == DIFFICULT_CLASS_LEATHERFACE && !g_Achievement[id][LEATHERFACE_PRINCIPIANTE]) || 
		(iDifficultClass == DIFFICULT_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_PRINCIPIANTE]) || 
		(iDifficultClass == DIFFICULT_CLASS_CABEZON && !g_Achievement[id][CABEZON_PRINCIPIANTE]) || 
		(iDifficultClass == DIFFICULT_CLASS_ANNIHILATOR && !g_Achievement[id][ANNIHILATOR_PRINCIPIANTE]))) {
			clientPrintColor(id, _, "Debes tener el logro !g%s PRINCIPIANTE!y para elegir esta dificultad", __DIFFICULTS_CLASSES[iDifficultClass]);

			showMenu__Difficults(id, iDifficultClass);
			return;
		} else if(g_AccountId[id] != 1 && value == DIFFICULT_VERY_HARD &&
		((iDifficultClass == DIFFICULT_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_AVANZADO]) ||
		(iDifficultClass == DIFFICULT_CLASS_WESKER && !g_Achievement[id][WESKER_AVANZADO]) || 
		(iDifficultClass == DIFFICULT_CLASS_LEATHERFACE && !g_Achievement[id][LEATHERFACE_AVANZADO]) || 
		(iDifficultClass == DIFFICULT_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_AVANZADO]) || 
		(iDifficultClass == DIFFICULT_CLASS_CABEZON && !g_Achievement[id][CABEZON_AVANZADO]) || 
		(iDifficultClass == DIFFICULT_CLASS_ANNIHILATOR && !g_Achievement[id][ANNIHILATOR_AVANZADO]))) {
			clientPrintColor(id, _, "Debes tener el logro !g%s AVANZADO!y para elegir esta dificultad", __DIFFICULTS_CLASSES[iDifficultClass]);

			showMenu__Difficults(id, iDifficultClass);
			return;
		} else if(g_AccountId[id] != 1 && value == DIFFICULT_EXPERT &&
		((iDifficultClass == DIFFICULT_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_EXPERTO]) ||
		(iDifficultClass == DIFFICULT_CLASS_WESKER && !g_Achievement[id][WESKER_EXPERTO]) || 
		(iDifficultClass == DIFFICULT_CLASS_LEATHERFACE && !g_Achievement[id][LEATHERFACE_EXPERTO]) || 
		(iDifficultClass == DIFFICULT_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_EXPERTO]) || 
		(iDifficultClass == DIFFICULT_CLASS_CABEZON && !g_Achievement[id][CABEZON_EXPERTO]) || 
		(iDifficultClass == DIFFICULT_CLASS_ANNIHILATOR && !g_Achievement[id][ANNIHILATOR_EXPERTO]))) {
			clientPrintColor(id, _, "Debes tener el logro !g%s EXPERTO!y para elegir esta dificultad", __DIFFICULTS_CLASSES[iDifficultClass]);

			showMenu__Difficults(id, iDifficultClass);
			return;
		}

		g_Difficult[id][iDifficultClass] = value;

		clientPrintColor(id, _, "La dificultad del !g%s!y ahora es !g%s!y", __DIFFICULTS_CLASSES[iDifficultClass], __DIFFICULTS[iDifficultClass][value][difficultName]);
		showMenu__Difficults(id, iDifficultClass);
	}
}

public showMenu__Hats(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("GORROS\R", "menu__Hats");

	for(i = 0; i < structIdHats; ++i) {
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

	g_MenuPage[id][MENU_PAGE_HAT_CLASS] = min(g_MenuPage[id][MENU_PAGE_HAT_CLASS], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_HAT_CLASS]);
}

public menu__Hats(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_HAT_CLASS]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(iItemId == HAT_NONE) {
		g_HatNext[id] = HAT_NONE;
		
		if(g_HatId[id]) {
			clientPrintColor(id, _, "Tu gorro ha sido removido");

			g_HatId[id] = HAT_NONE;
		}

		showMenu__Hats(id);
	} else {
		showMenu__HatInfo(id, iItemId);
	}

	return PLUGIN_HANDLED;
}

public showMenu__HatInfo(const id, const hat) {
	if(!hat) {
		showMenu__Hats(id);
		return;
	}

	g_MenuData[id][MENU_DATA_HAT_ID] = hat;

	new sHatName[32];
	copy(sHatName, charsmax(sHatName), __HATS[hat][hatName]);
	strtoupper(sHatName);

	oldmenu_create("\y%s - %s", "menu__HatInfo", sHatName, ((!g_Hat[id][hat]) ? " \r(NO OBTENIDO)" : " \y(OBTENIDO)"));

	oldmenu_additem(-1, -1, "\yREQUERIMIENTOS\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __HATS[hat][hatDesc]);

	if(__HATS[hat][hatDescExtra][0]) {
		oldmenu_additem(-1, -1, "\yNOTA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", __HATS[hat][hatDescExtra]);
	}

	oldmenu_additem(-1, -1, "\yBENEFICIOS\r:"); {
		if(__HATS[hat][hatUpgrade1]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Vida", __HATS[hat][hatUpgrade1]);
		}

		if(__HATS[hat][hatUpgrade2]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Velocidad", __HATS[hat][hatUpgrade2]);
		}

		if(__HATS[hat][hatUpgrade3]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Gravedad", __HATS[hat][hatUpgrade3]);
		}

		if(__HATS[hat][hatUpgrade4]) {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Daño", __HATS[hat][hatUpgrade4]);
		}

		if(__HATS[hat][hatUpgrade5]) {
			oldmenu_additem(-1, -1, "\r - \y+x%0.2f\w Ammo Packs", __HATS[hat][hatUpgrade5]);
		}

		if(__HATS[hat][hatUpgrade6]) {
			oldmenu_additem(-1, -1, "\r - \y+x%0.2f\w XP", __HATS[hat][hatUpgrade6]);
		}

		if(__HATS[hat][hatUpgrade7]) {
			oldmenu_additem(-1, -1, "\r - \y+%d%%\w Respawn Humano", __HATS[hat][hatUpgrade7]);
		}

		if(__HATS[hat][hatUpgrade8]) {
			oldmenu_additem(-1, -1, "\r - \y+%d%%\w Descuento en Items", __HATS[hat][hatUpgrade8]);
		}
	}

	if(g_Hat[id][hat]) {
		oldmenu_additem(-1, -1, "^n\yGORRO OBTENIDO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", getUnixToTime(g_HatUnlocked[id][hat], 1));

		oldmenu_additem(1, 1, "\r1.\w %s gorro", ((g_HatId[id] == hat) ? "Desequipar" : "Equipar"));
		oldmenu_additem(2, 2, "\r2.\w Mostrar gorro en el Chat^n");
	} else {
		oldmenu_additem(-1, -1, "^n\d1. %s gorro", ((g_HatId[id] == hat) ? "Desequipar" : "Equipar"));
		oldmenu_additem(-1, -1, "\d2. Mostrar gorro en el Chat^n");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HatInfo(const id, const item) {
	if(!item) {
		showMenu__Hats(id);
	} else {
		new iHatId = g_MenuData[id][MENU_DATA_HAT_ID];

		if(item == 1) {
			if(g_Hat[id][iHatId]) {
				g_HatNext[id] = iHatId;

				if(!g_NewRound) {
					clientPrintColor(id, _, "Cuando vuelvas a ser humano tendrás el gorro !g%s!y", __HATS[iHatId][hatName]);
				} else {
					updatePlayerHat(id);
				}
			}

			showMenu__Hats(id);
		} else if(item == 2) {
			if(g_Hat[id][iHatId]) {
				if(g_AccountId[id] == 1 || g_HatTimeLink[id] < get_gametime()) {
					clientPrintColor(0, _, "!t%s!y muestra su gorro !g%s !t[X]!y conseguido el !g%s!y", g_PlayerName[id], __HATS[iHatId][hatName], getUnixToTime(g_HatUnlocked[id][iHatId], 1));

					g_LastHatUnlocked = iHatId;
					g_HatTimeLink[id] = (get_gametime() + 15.0);
				}
			}

			showMenu__HatInfo(id, iHatId);
		}
	}
}

public createHats() {
	new iEnt;
	new i;

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

public getHatByOwner(const ent) {
	return find_ent_by_owner(-1, __ENT_CLASSNAME_HAT, ent);
}

public giveHat(const id, const hat) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED || g_Hat[id][hat]) {
		return;
	}

	new iSysTime = get_arg_systime();

	g_Hat[id][hat] = 1;
	g_HatUnlocked[id][hat] = iSysTime;
	++g_HatTotal[id];
	g_LastHatUnlocked = hat;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO zp8_hats (acc_id, hat_id, hat_timestamp) VALUES ('%d', '%d', '%d');", g_AccountId[id], hat, iSysTime);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	clientPrintColor(0, id, "!t%s!y ha conseguido el gorro !g%s!y [X]", g_PlayerName[id], __HATS[hat][hatName]);
}

public updatePlayerHat(const id) {
	new iEnt = getHatByOwner(id);

	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING || !is_valid_ent(iEnt)) {
		return;
	}

	if(g_HatNext[id]) {
		g_HatId[id] = g_HatNext[id];
		g_HatNext[id] = 0;
	}

	if(!g_HatId[id] || g_Zombie[id] || (g_Zombie[id] && g_SpecialMode[id]) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT) {
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
		return;
	}

	entity_set_model(iEnt, __HATS[g_HatId[id]][hatModel]);

	if(g_HatId[id] == HAT_PSYCHO) {
		remove_task(id + TASK_CONVERT_ZOMBIE);
		set_task(120.0, "task__ConvertZombie", id + TASK_CONVERT_ZOMBIE, .flags="b");
	}

	entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) & ~EF_NODRAW));
}

public hidePlayerHat(const id) {
	new iEnt = getHatByOwner(id);

	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_PLAYING || !is_valid_ent(iEnt)) {
		return;
	}

	entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
}

public getTribals() {
	new iCount = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i] && g_SpecialMode[i] == MODE_TRIBAL) {
			++iCount;
		}
	}

	return iCount;
}

public rewardModeFleshpound(const killer) {
	if(g_Mode != MODE_FLESHPOUND || g_ModeFleshpound_Minute) {
		return;
	}

	new iRandom = random_num(1, 6);
	new sMessage[32];

	switch(iRandom) {
		case 1: {
			++g_Hab[killer][HAB_H_DAMAGE];
			formatex(sMessage, charsmax(sMessage), "+1 DAÑO HUMANO");
		} case 2: {
			++g_Hab[killer][HAB_Z_HEALTH];
			formatex(sMessage, charsmax(sMessage), "+1 VIDA ZOMBIE");
		} case 3: {
			++g_Hab[killer][HAB_H_SPEED];
			++g_Hab[killer][HAB_H_GRAVITY];

			formatex(sMessage, charsmax(sMessage), "+1 VELOCIDAD/GRAVEDAD HUMANA");
		} case 4: {
			++g_Hab[killer][HAB_Z_SPEED];
			++g_Hab[killer][HAB_Z_GRAVITY];

			formatex(sMessage, charsmax(sMessage), "+1 VELOCIDAD/GRAVEDAD ZOMBIE");
		} case 5: {
			if((g_Level[killer] + 7) < MAX_LEVEL) {
				g_Level[killer] += 7;
				g_XP[killer] = 0;
				g_Points[killer][P_MONEY] += 25;

				checkXPEquation(killer);
			}

			formatex(sMessage, charsmax(sMessage), "7 niveles y 25 SALDO");
		} case 6: {
			g_Points[killer][P_HUMAN] += 50;
			g_Points[killer][P_ZOMBIE] += 50;

			formatex(sMessage, charsmax(sMessage), "50 pHZ");
		}
	}

	clientPrintColor(0, _, "Además, ganó !g%s!y por ganar el modo en !yMENOS DE 1 MINUTO!y", sMessage);
}

public task__ModeFleshpound() {
	g_ModeFleshpound_Minute = 1;
}

public checkAnnihilatorReward(const id, const kills,  const end_round) {
	new iReward = (kills * (floatround(g_XPMult[id]) * 36) * getUserLevelTotal(id));
	
	if(end_round) {
		new sReward[16];
		sReward[0] = EOS;
		
		addDot(iReward, sReward, charsmax(sReward));

		clientPrintColor(0, _, "El !tANIQUILADOR!y mató a !g%d humanos!y y por eso ganó !g%s XP!y", kills, sReward);
		addXP(id, iReward);
	} else {
		if(iReward < 0 || iReward > MAX_XP) {
			if(iReward < 0) {
				iReward = MAX_XP;
			}

			addXP(id, iReward);

			g_ModeAnnihilator_Kills[id] = 0;
		}
	}
}

public clcmd__Mapas(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	if(g_MenuPage[id][MENU_PAGE_MAPS] < 1) {
		g_MenuPage[id][MENU_PAGE_MAPS] = 1;
	}

	showMenu__Maps(id, g_MenuPage[id][MENU_PAGE_MAPS]);
	return PLUGIN_HANDLED;
}

public showMenu__Maps(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, g_VoteMap_Count);
	oldmenu_create("\yMAPAS \r[%d - %d]\y\R%d / %d", "menu__Mapas", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(is_map_valid(g_VoteMap_MapName[i])) {
			if(g_VoteMap_Bonus[i]) {
				oldmenu_additem(j, i, "\r%d.\w %s \y(%0.2f de XP)", j, g_VoteMap_MapName[i], g_VoteMap_Bonus[i]);
			} else {
				oldmenu_additem(j, i, "\r%d.\d %s \r(sin bonus%s)", j, g_VoteMap_MapName[i], ((g_VoteMap_Recent[i]) ? " - reciente" : ""));
			}
		} else {
			oldmenu_additem(-1, -1, "\d%d. %s", j, g_VoteMap_MapName[i]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__Mapas(const id, const item, const value, page) {
	if(!item || value > g_VoteMap_Count) {
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_MAPS] = iNewPage;

		showMenu__Maps(id, iNewPage);
		return;
	}

	if(g_VoteMap_MorePlaying[value]) {
		clientPrintColor(id, _, "Este mapa (!g%s!y) se ha jugado !g%d ve%s!y en lo que va del mes.", g_VoteMap_MapName[value], g_VoteMap_MorePlaying[value], ((g_VoteMap_MorePlaying[value] != 1) ? "ces" : "z"));
	} else {
		clientPrintColor(id, _, "Este mapa (!g%s!y) no se ha jugado ni una vez en lo que va del mes. Cuanto menos jugado es, más bonus tendrá a futuro.", g_VoteMap_MapName[value]);
	}

	showMenu__Maps(id, g_MenuPage[id][MENU_PAGE_MAPS]);
}

public clcmd__BonusMapa(const id) {
	if(!g_IsConnected[id] || g_AccountStatus[id] < STATUS_LOGGED) {
		return PLUGIN_HANDLED;
	}

	if(g_VoteMap_MapId != -1) {
		clientPrintColor(id, _, "El bonus que otorga este mapa es de !g+x%0.2f!y.", g_VoteMap_Bonus[g_VoteMap_MapId]);
	} else {
		clientPrintColor(id, _, "Este mapa no otorga bonus. Ya sea porque es reciente o porque surgió un error inesperado.");
	}

	return PLUGIN_HANDLED;
}

public clcmd__StartVoteMap(const id) {
	if(!g_IsConnected[id] || !(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	g_VoteMap_Force = 1;

	remove_task(TASK_VOTEMAP);
	remove_task(TASK_VOTEMAP_END);
	remove_task(TASK_CHANGEMAP_PRE);
	remove_task(TASK_CHANGEMAP);

	set_task(10.0, "task__VoteMap", TASK_VOTEMAP);

	clientPrintColor(0, _, "!t%s!y lanzó una votación para cambiar el próximo mapa. Comenzará en !g10 segundos!y aproximadamente...", g_PlayerName[id]);
	return PLUGIN_HANDLED;
}

public getNextMap() {
	new sNextMap[32];
	get_cvar_string("amx_nextmap", sNextMap, charsmax(sNextMap));

	if(!is_map_valid(sNextMap)) {
		new iRandom = random_num(0, (g_VoteMap_Count - 1));

		if(is_map_valid(g_VoteMap_MapName[iRandom])) {
			formatex(sNextMap, charsmax(sNextMap), "%s", g_VoteMap_MapName[iRandom]);
		} else {
			formatex(sNextMap, charsmax(sNextMap), "zpl_pibes_cabezita_v2");
		}

		set_cvar_string("amx_nextmap", sNextMap);
	}

	strtolower(sNextMap);
	return sNextMap;
}
