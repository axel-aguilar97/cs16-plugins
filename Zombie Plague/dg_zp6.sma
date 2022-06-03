#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <xs>
#include <sqlx>
#include <reapi>

#include <dg>

/*
	http://drunk-gaming.com/tema/2507-08-zombie-plague-levels-v62/
	http://drunk-gaming.com/tema/2759-08-zombie-plague-levels-v62/
	http://drunk-gaming.com/tema/2523-08-zombie-plague-levels-logros-para-la-v62/
	http://drunk-gaming.com/tema/2492-08-zombie-plague-levels-logros-para-la-v62/
	* Modos a completar
		Mega Duelo Final
			Se juega 2 tipos de duelos diferentes
			Los dos ganadores de los dos duelos, combaten en una super final por la recompensa de 1 DIAMANTE
		Mega Drunk
	* Minijuegos a agregar
		Laberinto (v5 - Nemesis)
	* Quitar register_menu()
	* Cada 2 semanas se reinician los clanes (empieza a partir de marzo)
		El clan que salió primero en zm matados e infecciones, ganan x3 de APs, el segundo x2 y el tercero x1
	* Revisar el tiempo de miembro desde y la ultima visita del miembro del clan
	* Que las armas den un plus por uso (aps)
	* Item humano que sea gratis y que te transforme en zombie, dandote como recompensa grandes niveles de XP yhy APS
	* Eliminar o modificar aumleto y que se le devuelvan 'x' diamantes
	* Lo de la ganancia mensual era:. Que cada cierta cantidad de tiempo jugado en el servidor recibirias recompensas tales como Daño Adicional Velocidad HM O ZM
		Y el proceso se aceleraria con Diamantes ya sea Acortando el tiempo (Opcion 1) o simplemente comprando las recompensas sin esperar por el tiempo jugado (Opcion 2)
	* Revisar el daño de las armas del menu de armas ahre
	* Limitar maximo de APs al hacer daño, etc.
	* Intercambio entre todos los puntos
	* Intercambio de puntos por diamantes
	* Poner clases humanas y zombies  pero que a la vez se suban solas
	* Revisar al llegar al tope máximo de XP en el combo
	* Poner para subir de la A a la Z una vez subido los 25 rangos y que sea "EXTRA DIFICIL SUBIR" y que diga "A-Pro"
	* Poner que en modo infección, infecte a usuarios que no han sido infectados en la anterior ronda de infeccion
	+ En el menu de habilidades, cuando lo subis a nivel 14 (cualquier habilidad) te dice "subirla a nivel 15"
	+ Poner un % para que ganen lso zombies con el clan, asi se motivan
	+ Poner un mini-hud de cuanto va sacando el zombie
	+ Maestrías
	+ Poner el /showkey solo para staff
	+ REGISTRO
	+ Poner "dar modo"
	+ Agregar /cam
	+ Arreglar la velocidad de cuchillo
	+ Cambiar sistema de daño por combo
	+ Revisar APs al otorgar
	+ [17:25]
		Deadpool:
			dice que tiene +5 en aps
			pero no me da xd
			en multiplicadores
			o es asi
	+ Ianhoy a las 17:01
		normalmente al minuto que empieza la ronda o a veces antes
		cuando se cae el sv
		y si no cuando en grunt o duelo que terminan todos muertos y no termina nunca la ronda
		pero eso ya lo sabe creo
	+ thetime no sale nada
	+ timeleft no sale nada
	+ /vencimiento tampoco muestra nada
	+ Da picos de lag, no es un lag constante
	+ Recien empezaba la ronda y se cayó y se levanto
	Pasaron 10 seg de la ronda y se cayó, o sea fue super al toque
	Pero los chicos me dicen que se cae a la mitad de la ronda a veces
	+ Se volvió a caer en el minuto 3:20
	Siento que realmente lo estan tirando, porque no encuentro un momento ESPECÍFICO que se caiga
	No es solo en infección, no es solo al comenzar la ronda
	Y no se cae de la nada, lo laguea al punto de que en el score de 30 se pasan a 200
	Y eso que tiene el plugin ese que me contaste que en el score no ponen realmente el ping
	+ El wesker kiteo y se bugueo la ronda >> Quedo solo el último zombie y no terminó la ronda
	+ Creo que lo mejor va a ser unificar los personajes, al punto de que solo tengan uno y se manejen con ese. Convengamos que mucho sentido no tiene tener 3 personajes, creo que nadie los usa
	Y bueno, es optimizar el ZP un poco
	+ Con /invis tampoco aparece ene l say
	+ En aniquilador eramos casi 30, empezó a subir el lag sarpadisimo. Se calmó cuando empezó infeccion y se cayó al minuto 1:20
	+ El say del gag no aparece
	+ El rtv no funciona
	+ El MA tiene bombas de humano, no deberían tener
	+ De la pantalla de habilidades dice "Daño (Niv.19)" pero cuando entras, esta en nivel 18
	+ El color del hud de combo funciona bien por <X cantidad de tiempo<X>. Y después se buguea y se pone un color simple
	+ Bajar la probabilidad al FvsJ
	+ Que en say aparezca :
		>> Quien kiteo de modo
		>> Quien le toca modo
		>> Si alguien tira retry
	+ Buscar algún movimiento de manos que se pueda poner cuando los HUMANOS ganan algun modo (le robé la idea al jb jeje)
	+ http://drunk-gaming.com/tema/1925-08-zombie-plague-v62/
*/

#pragma dynamic	131072
#pragma semicolon 1

new const __PLUGIN_NAME[] = "Zombie Plague";
new const __PLUGIN_VERSION[] = "v6.2";
new const __PLUGIN_UPDATE[] = "";
new const __PLUGIN_UPDATE_VERSION[] = "";
new const __PLUGIN_AUTHOR[] = "Martina. & Atsel.";

const MAX_USERS = 33;
const MIN_USERS_FOR_GAME = 4;
const MIN_USERS_FOR_EVENTMODES = 12;
const MIN_USERS_FOR_CLASS_IN_MODE = 12;
const MIN_USERS_FOR_HEAD_IN_MODE = 12;
const MAX_APS = 2100000000;
const MAX_XP = 2100000000;
const MAX_XP_PER_RESET = 40000000;
const MAX_APS_DAMAGE_NEED = 500;
const MAX_XP_DAMAGE_NEED = 1000;
const MAX_LEVEL = 1000;
const MAX_RESET = 25;
const MAX_COST_HABS_RESET = 25; // Costo de pE para resetear habilidades
const MAX_CLAN_MEMBERS = 8;
const MAX_XP_ASSASSIN_REWARD = 10000000;
const EXTRA_ITEMS_COST_PERCENT = 25;
const MAX_POINT_RESET_REWARD = 10;
const TIME_MADNESS_TO_DELAY = 10;
const TIME_PAINSHOCK_TO_DELAY = 7;
const MIN_USER_FOR_GAMES = 12;
const REWARD_ANNIHILATOR_BASE = 5000;
const MAX_AMULETS = 5;

const Float:MODELS_CHANGE_DELAY = 0.5;
const Float:NADE_EXPLODE_RADIUS = 240.0;
const Float:DIV_NUM_TO_FLOAT = 100.0;
const Float:ZOMBIE_MADNESS_SPEED_EXTRA = 25.0;

const PDATA_SAFE = 2;
const OFFSET_LINUX = 5;
const OFFSET_LINUX_WEAPONS = 4;
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
const OFFSET_HITZONE = 75;
const OFFSET_NEXT_ATTACK = 83;
const OFFSET_PAINSHOCK = 108;
const OFFSET_CSTEAMS = 114;
const OFFSET_JOINSTATE = 121;
const OFFSET_BLOCKTEAM = 125;
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
const OFFSET_VGUI = 510;

const HIDE_HUDS = (1<<3)|(1<<5);
const UNIT_SECOND = (1<<12);
const DMG_HEGRENADE = (1<<24);
const OFF_IMPULSE_FLASHLIGHT = 100;
const OFF_IMPULSE_SPRAY = 201;
const STEPTIME_SILENT = 999;
const FFADE_IN = 0x0000;
const FFADE_STAYOUT = 0x0004;

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE);
const WEAPONS_SILENT_BIT_SUM = (1<<CSW_USP)|(1<<CSW_M4A1);
const ZOMBIE_ALLOWED_WEAPONS_BIT_SUM = (1<<CSW_KNIFE)|(1<<CSW_MAC10)|(1<<CSW_AK47)|(1<<CSW_HEGRENADE);

const EV_ID_SPEC = EV_INT_iuser2;
const EV_ENT_FLARE = EV_ENT_euser3;
const EV_NADE_TYPE = EV_INT_flTimeStepSound;
const EV_FLARE_COLOR = EV_VEC_punchangle;
const EV_FLARE_DURATION = EV_INT_flSwimTime;

const HUMAN_CLASS_LEVEL = 100;
const HUMAN_BASE_HEALTH_MIN = 100;
const HUMAN_BASE_HEALTH_MAX = 1000;
const Float:HUMAN_BASE_SPEED_MIN = 240.0;
const Float:HUMAN_BASE_SPEED_MULT = 0.6;
const Float:HUMAN_BASE_SPEED_MAX = 400.0;
const Float:HUMAN_BASE_GRAVITY_MIN = 1.0;
const Float:HUMAN_BASE_GRAVITY_MULT = 0.0016;
const Float:HUMAN_BASE_GRAVITY_MAX = 0.4;
const Float:HUMAN_BASE_DAMAGE_MULT = 25.0;
const HUMAN_MAX_ARMOR = 200;

const ZOMBIE_CLASS_LEVEL = 100;
const ZOMBIE_BASE_HEALTH_MIN = 3250000;
const ZOMBIE_BASE_HEALTH_MAX = 32500000;
const Float:ZOMBIE_BASE_SPEED_MIN = 240.0;
const Float:ZOMBIE_BASE_SPEED_MULT = 0.6;
const Float:ZOMBIE_BASE_SPEED_MAX = 400.0;
const Float:ZOMBIE_BASE_GRAVITY_MIN = 1.0;
const Float:ZOMBIE_BASE_GRAVITY_MULT = 0.0016;
const Float:ZOMBIE_BASE_GRAVITY_MAX = 0.4;

const KEYSMENU = (MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9 | MENU_KEY_0);

enum _:structIdTasks (+= 12345)
{
	TASK_SET_CONFIGS = 100000,
	TASK_SQL_QUERIES,
	TASK_CHECK_ACCOUNT,
	TASK_REMEMBER_VINC,
	TASK_SAVE,
	TASK_BANNED,
	TASK_AUTO_JOIN,
	TASK_REFILL_BP_AMMO,
	TASK_REMOVE_STUFF,
	TASK_VIRUST,
	TASK_START_MODE,
	TASK_CHECK_STUCK,
	TASK_MODEL,
	TASK_TEAM,
	TASK_SPAWN,
	TASK_BURNING_FLAME,
	TASK_FREEZE,
	TASK_SLOWDOWN,
	TASK_MADNESS,
	TASK_PAINSHOCK,
	TASK_POWER_SNIPER_ELITE,
	TASK_POWER_FVSJ_JASON,
	TASK_POWER_PREDATOR,
	TASK_POWER_ASSASSIN,
	TASK_POWER_SNIPER,
	TASK_POWER_TRIBAL,
	TASK_MODE_ARMAGEDDON,
	TASK_MODE_MEGA_ARMAGEDDON,
	TASK_MODE_MEGA_GUNGAME,
	TASK_MODE_FVSJ,
	TASK_MODE_DUEL_FINAL,
	TASK_IMMUNITY_BOMB,
	TASK_IMMUNITY_GG,
	TASK_REGENERATION,
	TASK_IMMUNITY_P,
	TASK_NIGHTVISION,
	TASK_MOLOTOV_EFFECT,
	TASK_DRUG,
	TASK_GRAB,
	TASK_GRAB_PRETHINK,
	TASK_GRUNT_AIMING,
	TASK_GRUNT_GLOW
};

#define ID_REMEMBER_VINC (task_id - TASK_REMEMBER_VINC)
#define ID_SAVE (task_id - TASK_SAVE)
#define ID_BANNED (task_id - TASK_BANNED)
#define ID_AUTO_JOIN (task_id - TASK_AUTO_JOIN)
#define ID_REFILL_BP_AMMO (task_id - TASK_REFILL_BP_AMMO)
#define ID_CHECK_STUCK (task_id - TASK_CHECK_STUCK)
#define ID_MODEL (task_id - TASK_MODEL)
#define ID_TEAM (task_id - TASK_TEAM)
#define ID_SPAWN (task_id - TASK_SPAWN)
#define ID_BURNING_FLAME (task_id - TASK_BURNING_FLAME)
#define ID_FREEZE (task_id - TASK_FREEZE)
#define ID_SLOWDOWN (task_id - TASK_SLOWDOWN)
#define ID_MADNESS (task_id - TASK_MADNESS)
#define ID_PAINSHOCK (task_id - TASK_PAINSHOCK)
#define ID_POWER_SNIPER_ELITE (task_id - TASK_POWER_SNIPER_ELITE)
#define ID_POWER_FVSJ_JASON (task_id - TASK_POWER_FVSJ_JASON)
#define ID_POWER_PREDATOR (task_id - TASK_POWER_PREDATOR)
#define ID_POWER_ASSASSIN (task_id - TASK_POWER_ASSASSIN)
#define ID_POWER_SNIPER (task_id - TASK_POWER_SNIPER)
#define ID_POWER_TRIBAL (task_id - TASK_POWER_TRIBAL)
#define ID_IMMUNITY_BOMB (task_id - TASK_IMMUNITY_BOMB)
#define ID_IMMUNITY_GG (task_id - TASK_IMMUNITY_GG)
#define ID_REGENERATION (task_id - TASK_REGENERATION)
#define ID_IMMUNITY_P (task_id - TASK_IMMUNITY_P)
#define ID_NIGHTVISION (task_id - TASK_NIGHTVISION)
#define ID_MOLOTOV_EFFECT (task_id - TASK_MOLOTOV_EFFECT)
#define ID_DRUG (task_id - TASK_DRUG)
#define ID_GRAB (task_id - TASK_GRAB)
#define ID_GRAB_PRETHINK (task_id - TASK_GRAB_PRETHINK)
#define ID_GRUNT_AIMING (task_id - TASK_GRUNT_AIMING)
#define ID_GRUNT_GLOW (task_id - TASK_GRUNT_GLOW)

enum _:structIdNades (+= 1111)
{
	NADE_TYPE_INFECTION = 1111,
	NADE_TYPE_FIRE,
	NADE_TYPE_NOVA,
	NADE_TYPE_FLARE,
	NADE_TYPE_NITRO,
	NADE_TYPE_SUPERNOVA,
	NADE_TYPE_IMMUNITY,
	NADE_TYPE_DRUG,
	NADE_TYPE_HYPERNOVA,
	NADE_TYPE_BUBBLE,
	NADE_TYPE_KILL,
	NADE_TYPE_MOLOTOV,
	NADE_TYPE_ANTIDOTE
};

enum _:structIdTeams
{
	F_TEAM_NONE = 0,
	F_TEAM_T,
	F_TEAM_CT,
	F_TEAM_SPECTATOR
};

enum _:structIdModes
{
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_PLAGUE,
	MODE_ARMAGEDDON,
	MODE_MEGA_ARMAGEDDON,
	MODE_GUNGAME,
	MODE_MEGA_GUNGAME,
	MODE_FVSJ,
	MODE_SYNAPSIS,
	MODE_AVSP,
	MODE_DUEL_FINAL,
	MODE_DRUNK,
	MODE_SURVIVOR,
	MODE_WESKER,
	MODE_SNIPER_ELITE,
	MODE_JASON,
	MODE_NEMESIS,
	MODE_ASSASSIN,
	MODE_ANNIHILATOR,
	MODE_SNIPER,
	MODE_GRUNT,
	MODE_TRIBAL,
	MODE_L4D2
};

enum _:structIdDuelFinal
{
	DF_ALL = 0,
	DF_QUARTER,
	DF_SEMIFINAL,
	DF_FINAL,
	DF_FINISH
};

enum _:structIdDuelFinalType
{
	DF_TYPE_NONE = 0,
	DF_TYPE_KNIFE,
	DF_TYPE_AWP,
	DF_TYPE_HE,
	DF_TYPE_OH,
	DF_TYPE_M3,
	DF_TYPE_SCOUTS
};

enum _:structIdWeapons
{
	WEAPON_AUTO_BUY = 0,
	WEAPON_PRIMARY_SELECT,
	WEAPON_SECONDARY_SELECT
};

enum _:structIdWeaponDatas
{
	Float:WEAPON_DATA_DAMAGE_DONE,
	WEAPON_DATA_KILL_DONE,
	WEAPON_DATA_TIME_PLAYED_DONE,
	WEAPON_DATA_TPD_DAYS,
	WEAPON_DATA_TPD_HOURS,
	WEAPON_DATA_TPD_MINUTES,
	WEAPON_DATA_POINTS,
	WEAPON_DATA_LEVEL,
	Float:WEAPON_DATA_DAMAGE_S_DONE,
	WEAPON_DATA_KILL_S_DONE
};

enum _:structIdWeaponSkills
{
	WEAPON_SKILL_DAMAGE = 0,
	WEAPON_SKILL_SPEED,
	WEAPON_SKILL_RECOIL,
	WEAPON_SKILL_MAXCLIP
};

enum _:structIdExtraItemsTeam
{
	EXTRA_ITEM_TEAM_HUMAN = 0,
	EXTRA_ITEM_TEAM_ZOMBIE
};

enum _:structIdExtraItems
{
	EXTRA_ITEM_NIGHTVISION = 0,
	EXTRA_ITEM_INVISIBILITY,
	EXTRA_ITEM_UNLIMITED_CLIP,
	EXTRA_ITEM_PP,
	EXTRA_ITEM_KILL_BOMB,
	EXTRA_ITEM_MOLOTOV_BOMB,
	EXTRA_ITEM_ANTIDOTE_BOMB,

	EXTRA_ITEM_ANTIDOTE,
	EXTRA_ITEM_ZOMBIE_MADNESS,
	EXTRA_ITEM_INFECTION_BOMB,
	EXTRA_ITEM_REDUCE_DAMAGE,
	EXTRA_ITEM_PAINSHOCK,
	EXTRA_ITEM_PETRIFICATION
};

enum _:structIdModelClasses
{
	MODEL_HUMAN = 0,
	MODEL_ZOMBIE
};

enum _:structIdDifficultsClasses
{
	DIFFICULT_CLASS_SURVIVOR = 0,
	DIFFICULT_CLASS_WESKER,
	DIFFICULT_CLASS_SNIPER_ELITE,
	DIFFICULT_CLASS_NEMESIS,
	DIFFICULT_CLASS_ASSASSIN,
	DIFFICULT_CLASS_ANNIHILATOR
};

enum _:structIdDifficults
{
	DIFFICULT_NORMAL = 0,
	DIFFICULT_HARD,
	DIFFICULT_VERY_HARD
};

enum _:structIdPoints
{
	POINT_HUMAN = 0,
	POINT_ZOMBIE,
	POINT_LEGACY,
	POINT_SPECIAL,
	POINT_DIAMMONDS
};

enum _:structIdHabsClasses
{
	HAB_CLASS_HUMAN = 0,
	HAB_CLASS_ZOMBIE,
	HAB_CLASS_L_SURVIVOR,
	HAB_CLASS_L_WESKER,
	HAB_CLASS_L_SNIPER_ELITE,
	HAB_CLASS_L_JASON,
	HAB_CLASS_L_NEMESIS,
	HAB_CLASS_SPECIAL,
	HAB_CLASS_DIAMMONDS
};

enum _:structIdHabs
{
	HAB_H_HEALTH = 0,
	HAB_H_SPEED,
	HAB_H_GRAVITY,
	HAB_H_DAMAGE,
	HAB_H_ARMOR,

	HAB_Z_HEALTH,
	HAB_Z_SPEED,
	HAB_Z_GRAVITY,
	HAB_Z_DAMAGE,
	HAB_Z_INDUCTION,
	HAB_Z_COMBO_ZOMBIE,

	HAB_L_S_BASE_STATS,
	HAB_L_S_DAMAGE,
	HAB_L_S_WEAPON,

	HAB_L_W_ULTRA_LASER,
	HAB_L_W_COMBO,

	HAB_L_SN_DURATION_POWER,

	HAB_L_J_TELEPORT,
	HAB_L_J_DAMAGE,
	HAB_L_J_COMBO,

	HAB_L_N_BASE_STATS,
	HAB_L_N_DAMAGE,
	HAB_L_N_BAZOOKA_RADIUS,
	HAB_L_N_BAZOOKA_EXTRA,

	HAB_S_UPDATE_GRENADE_HE,
	HAB_S_UPDATE_GRENADE_FB,
	HAB_S_UPDATE_GRENADE_SG,
	HAB_S_DURATION_BUBBLE,
	HAB_S_MADNESS,

	HAB_D_DURATION_COMBO,
	HAB_D_MORE_PL,
	HAB_D_RESET_EI,
	HAB_D_VIGOR,
	HAB_D_WEAPONS_LVL10,

	HAB_Z_RESISTANCE_BURN,
	HAB_Z_RESISTANCE_FROST,
};

enum _:structIdAchievements
{
	CUENTA_PAR = 0,
	CUENTA_IMPAR,
	SURVIVOR_PRINCIPIANTE,
	SURVIVOR_AVANZADO,
	SURVIVOR_EXPERTO,
	SURVIVOR_PRO,
	WESKER_PRINCIPIANTE,
	WESKER_AVANZADO,
	WESKER_EXPERTO,
	WESKER_PRO,
	SNIPER_ELITE_PRINCIPIANTE,
	SNIPER_ELITE_AVANZADO,
	SNIPER_ELITE_EXPERTO,
	SNIPER_ELITE_PRO,
	NEMESIS_PRINCIPIANTE,
	NEMESIS_AVANZADO,
	NEMESIS_EXPERTO,
	NEMESIS_PRO,
	ASSASSIN_PRINCIPIANTE,
	ASSASSIN_AVANZADO,
	ASSASSIN_EXPERTO,
	ASSASSIN_PRO,
	ANNIHILATOR_PRINCIPIANTE,
	ANNIHILATOR_AVANZADO,
	ANNIHILATOR_EXPERTO,
	ANNIHILATOR_PRO,
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
	R_CICLO_C,
	R_CICLO_B,
	R_CICLO_A,
	CICLO_MAXIMO,
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
	BUEN_COMIENZO,
	PRO_DUELO,
	TRANQUI_120,
	AL_MAXIMO,
	OTRA_FORMA_DE_JUGAR,
	PRIMERO_BUEN_COMIENZO,
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
	SENTADO,
	PUM_BALAZO,
	THE_KILLER_OF_DK,
	PUM_CHSCHS,
	LA_RECORTADA_DEL_PUNTO_6,
	PA_TODO_EL_SV,
	HEAD_100_RED,
	HEAD_75_GREEN,
	HEAD_50_BLUE,
	HEAD_25_YELLOW,
	COLORIDO,
	MI_PRIMER_DUELO,
	VAMOS_BIEN,
	DEMASIADO_FACIL,
	DICE_x5,
	DICE_x20,
	DICE_x50,
	DICE_x100,
	DICE_x500,
	DICE_x1000,
	DICE_1,
	DICE_2,
	DICE_3,
	DICE_4,
	DICE_5,
	DICE_6,
	DICE_UNIQUE,
	DICE_WIN_BY_10,
	DICE_WIN_BY_20,
	DICE_WIN_BY_30,
	DICE_PAIR,
	DICE_ODDS,
	DICE_THE_PAIRS,
	DICE_THE_ODDS,
	DICE_BALANCE,
	DICE_DRAW,
	DICE_DRAW_EXACTLY,
	DICE_DOUBLE_UNIQUE,
	PPT_PIEDRA,
	PPT_PAPEL,
	PPT_TIJERA,
	PPT_WIN,
	PPT_WIN_5,
	PPT_WIN_15,
	PPT_WIN_30,
	PPT_WIN_50,
	PPT_WIN_100,
	PPT_WIN_300,
	PPT_WIN_500,
	PPT_WIN_1000,
	PPT_DRAW_3,
	PPT_DRAW_5,
	PPT_DRAW_7,
	PPT_WIN_CON_3,
	PPT_WIN_CON_5,
	DICE_DIFF_25,
	DICE_DIFF_50,
	DICE_DIFF_250,
	DICE_DIFF_500,
	DICE_DIFF_1000,
	DICE_x5000,
	DICE_x10000,
	DICE_x25000,
	DICE_x50000,
	DICE_x100000,
	DICE_x500000,
	DICE_x1000000,
	COMBO_FIRST_BLOOD,
	COMBO_DOUBLE_KILL,
	COMBO_MULTI_KILL,
	COMBO_BLOOD_BATH,
	COMBO_ULTRA_KILL,
	COMBO_MEGA_KILL,
	COMBO_DOMINATING,
	COMBO_IMPRESSIVE,
	COMBO_RAMPAGE,
	COMBO_KILLING_SPREE,
	COMBO_GODLIKE,
	COMBO_UNSTOPPABLE,
	COMBO_HOLY_SHIT,
	COMBO_WICKED_SICK,
	COMBO_MONSTER_KILL,
	COMBO_LUDICROUSS_KILL,
	COMBO_ITS_A_NIGHTMARE,
	COMBO_WHAT_THE_FUCK,
	COMBO_INFERNO,
	COMBO_AAA,
	COMBO_LOL,
	COMBO_OMG,
	COMBO_GORGEOUS,
	COMBO_PUNTO,
	COMBO_FIRST_BLOOD_ZOMBIE,
	COMBO_DOUBLE_KILL_ZOMBIE,
	COMBO_MULTI_KILL_ZOMBIE,
	COMBO_BLOOD_BATH_ZOMBIE,
	COMBO_ULTRA_KILL_ZOMBIE,
	COMBO_MEGA_KILL_ZOMBIE,
	COMBO_DOMINATING_ZOMBIE,
	COMBO_IMPRESSIVE_ZOMBIE,
	COMBO_RAMPAGE_ZOMBIE,
	COMBO_KILLING_SPREE_ZOMBIE,
	COMBO_GODLIKE_ZOMBIE,
	COMBO_UNSTOPPABLE_ZOMBIE,
	COMBO_HOLY_SHIT_ZOMBIE,
	COMBO_WICKED_SICK_ZOMBIE,
	COMBO_MONSTER_KILL_ZOMBIE,
	COMBO_LUDICROUSS_KILL_ZOMBIE,
	COMBO_ITS_A_NIGHTMARE_ZOMBIE,
	COMBO_WHAT_THE_FUCK_ZOMBIE,
	COMBO_INFERNO_ZOMBIE,
	COMBO_AAA_ZOMBIE,
	COMBO_LOL_ZOMBIE,
	COMBO_OMG_ZOMBIE,
	COMBO_GORGEOUS_ZOMBIE,
	COMBO_PUNTO_ZOMBIE,
	HEAD_10_WHITE,
	L_FRANCOTIRADOR,
	EL_MEJOR_EQUIPO,
	EN_MEMORIA_A_ELLOS,
	MI_AWP_ES_MEJOR,
	MI_SCOUT_ES_MEJOR,
	SOBREVIVEN_LOS_DUROS,
	NO_SOLO_LA_GANAN_LOS_DUROS,
	ZAS_EN_TODA_LA_BOCA,
	NO_TENGO_BALAS,
	EVL_TODOS_LOS_DULCES,
	EVL_DULCE_BOOM,
	EVL_EL_INTENSO_DEL_SV,
	EVL_FLOWER_x5,
	EVL_FLOWER_x10,
	EVL_FLOWER_x25,
	EVL_FLOWER_x50,
	EVL_FLORES_ZOMBIE,
	EVL_DULCE_ZOMBIE,
	EVL_AMOR_ADMIN,
	EVL_AMOR_STAFF,
	EVL_AMOR_ODIO,
	EVL_SON_AMORES,
	EVL_AMORES_x100,
	EVL_AMORES_x500,
	EVL_AMORES_x2500,
	EVL_AMADO_x10,
	EVL_AMADO_x100,
	EVL_AMADO_x500,
	TERRORISTA_1, 			// Mata 150 zombies con AK-47
	BALAS_1500, 			// Dispara 1500 balas sin morir y sin convertirte en zombie en una misma ronda, 500 balas tienen que haber sacado daño a los zombies
	RAPIDO_Y_FURIOSO, 		// Infecta a 5 humanos y utiliza 3 furias zombies en una misma ronda
	MI_MAMA_DISPARO,		// Hacerle mas daño al nemesis y sumar mas de 500k de daño
	CORTAMAMBO,				// Hacer que un combo dure 5 minutos sin cortarse
	CHUCK_NORRIS,			// Matar al aniquilador con cuchillo.
	T_VIRUS,				// Infectar a 24 en una sola ronda
	HITMAN,					// Realiza 500.000 headshots
	MAS_ZOMBIES,			// Mata a 35 zombies en una ronda
	LETS_ROCK,				// Gana el modo survivor en 1 minuto o menos
	MAXIMO_COMPRADOR,		// Compra todos los objetos disponibles tanto para zombie como para humano, en una sola ronda.
	JUGADOR_COMPULSIVO,		// DESHABILITADO
	MILLONARIO,				// Consigue 100m de XP
	EL_TERROR_EXISTE,		// Matar a un total de 2500 humanos siendo nemesis.
	RESISTENCIA,			// Matar a un total de 2500 zombies siendo survivor.
	ALBERT_WESKER,			// Matar a 2500 zombies siendo wesker.
	ASESINO_DE_TURNO,		// Matar a 8 humanos en modo plague
	APLASTA_ZOMBIES,		// Mata a 7 zombies en modo plague
	ZANGANO_REAL,			// Matar a 10 humanos siendo alien en una ronda.
	DEPREDADOR_FINAL,		// Mata a 8 zombies siendo depredador en una ronda.
	DEPREDALIEN,			// Completa los logros secretos ZANGANO_REAL y DEPREDADOR_FINAL
	VISION_NOCTURNA_x10,
	INVISIBILIDAD_x10,
	BALAS_INFINITAS_x10,
	PRESICION_PERFECTA_x10,
	BOMBA_DE_ANIQUILACION_x10,
	BOMBA_MOLOTOV_x10,
	BOMBA_ANTIDOTO_x10,
	ANTIDOTO_x10,
	FURIA_x10,
	BOMBA_DE_INFECCION_x10,
	REDUCCION_x10,
	PAINSHOCK_x10,
	PETRIFICACION_x10,
	VISION_NOCTURNA_x50,
	INVISIBILIDAD_x50,
	BALAS_INFINITAS_x50,
	PRESICION_PERFECTA_x50,
	BOMBA_DE_ANIQUILACION_x50,
	BOMBA_MOLOTOV_x50,
	BOMBA_ANTIDOTO_x50,
	ANTIDOTO_x50,
	FURIA_x50,
	BOMBA_DE_INFECCION_x50,
	REDUCCION_x50,
	PAINSHOCK_x50,
	PETRIFICACION_x50,
	VISION_NOCTURNA_x100,
	INVISIBILIDAD_x100,
	BALAS_INFINITAS_x100,
	PRESICION_PERFECTA_x100,
	BOMBA_DE_ANIQUILACION_x100,
	BOMBA_MOLOTOV_x100,
	BOMBA_ANTIDOTO_x100,
	ANTIDOTO_x100,
	FURIA_x100,
	BOMBA_DE_INFECCION_x100,
	REDUCCION_x100,
	PAINSHOCK_x100,
	PETRIFICACION_x100,
	ITEMS_EXTRAS_x10,
	ITEMS_EXTRAS_x50,
	ITEMS_EXTRAS_x100,
	ITEMS_EXTRAS_x500,
	ITEMS_EXTRAS_x1000,
	ITEMS_EXTRAS_x5000
};

enum _:structIdAchievementClasses
{
	ACHIEVEMENT_CLASS_HUMAN = 0,
	ACHIEVEMENT_CLASS_ZOMBIE,
	ACHIEVEMENT_CLASS_MODES,
	ACHIEVEMENT_CLASS_OTHERS,
	ACHIEVEMENT_CLASS_FIRST,
	ACHIEVEMENT_CLASS_WEAPONS,
	ACHIEVEMENT_CLASS_SECRETS,
	ACHIEVEMENT_CLASS_EI,
	ACHIEVEMENT_CLASS_EVL
};

enum _:structClans
{
	clanId,
	clanName[16],
	clanSince,
	clanDeposit,
	clanKillDone,
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

enum _:structClansMembers
{
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
	clanMemberLevel,
	clanMemberReset
};

enum _:structIdClanPerks
{
	CP_COMBO = 0,
	CP_MULTIPLE_COMBO,
	CP_EXTENDED_FURY
};

enum _:structIdHats
{
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
	HAT_ZIPPY,
	HAT_1ER_PUESTO,
	HAT_2DO_PUESTO,
	HAT_3ER_PUESTO
};

enum _:structIdAmuletCustoms
{
	acHealth = 0,
	acSpeed,
	acGravity,
	acDamage,
	acMultAPs,
	acMultXP,
	acRespawnHuman,
	acReduceExtraItems
};

enum _:structIdColorsType
{
	COLOR_TYPE_HUD_G = 0,
	COLOR_TYPE_HUD_C,
	COLOR_TYPE_HUD_CC,
	COLOR_TYPE_NVISION,
	COLOR_TYPE_FLARE,
	COLOR_TYPE_CLAN_GLOW
};

enum _:structIdHudsType
{
	HUD_TYPE_GENERAL = 0,
	HUD_TYPE_COMBO,
	HUD_TYPE_CLAN_COMBO
};

enum _:structIdChatMode
{
	CHAT_MODE_NORMAL = 0,
	CHAT_MODE_BCK,
	CHAT_MODE_BCK_PTH,
	CHAT_MODE_KY,
	CHAT_MODE_KY_PTH,
	CHAT_MODE_KY_BCK,
	CHAT_MODE_KY_BCK_PTH
};

enum _:structIdStats
{
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
	STAT_S_M_C, // Fuiste survivor
	STAT_S_M_WIN, // Survivors ganados
	STAT_S_M_LOSE, // Survivors perdidos
	STAT_S_M_KILL, // Survivors matados
	STAT_W_M_C, // Fuiste Wesker
	STAT_W_M_WIN, // Wesker ganados
	STAT_W_M_LOSE, // Wesker perdidos
	STAT_W_M_KILL, // Wesker matados
	STAT_SN_M_C, // Fuiste Sniper Elite
	STAT_SN_M_WIN, // Sniper Elite ganados
	STAT_SN_M_LOSE, // Sniper Elite perdidos
	STAT_SN_M_KILL, // Sniper Elite matados
	STAT_J_M_C, // Fuiste Jason
	STAT_J_M_WIN, // Jasons ganados
	STAT_J_M_LOSE, // Jasons perdidos
	STAT_J_M_KILL, // Jasons matados
	STAT_N_M_C, // Fuiste Nemesis
	STAT_N_M_WIN, // Nemesis ganados
	STAT_N_M_LOSE, // Nemesis perdidos
	STAT_N_M_KILL, // Nemesis matados
	STAT_A_M_C, // Fuiste Assassin
	STAT_A_M_WIN, // Assassin ganados
	STAT_A_M_LOSE, // Assassin perdidos
	STAT_A_M_KILL, // Assassin matados
	STAT_AN_M_C, // Fuiste Aniquilador
	STAT_AN_M_WIN, // Aniquilador ganados
	STAT_AN_M_LOSE, // Aniquilador perdidos
	STAT_AN_M_KILL, // Aniquilador matados
	STAT_F_M_C, // Fuiste Freddy
	STAT_F_M_WIN, // Freddys ganados
	STAT_F_M_LOSE, // Freddys perdidos
	STAT_F_M_KILL, // Freddys matados
	STAT_T_M_C, // Fuiste Tribal
	STAT_T_M_WIN, // Tribales ganados
	STAT_T_M_LOSE, // Tribales perdidos
	STAT_T_M_KILL, // Tribales matados
	STAT_DUEL_WIN,
	STAT_DUEL_LOSE,
	STAT_DUEL_FINAL_WINS,
	STAT_GG_WINS,
	STAT_WIN_PPT,
	STAT_LOSE_PPT,
	STAT_WIN_DICE,
	STAT_LOSE_DICE
};

enum _:structIdTimePlayed
{
	TIME_SEC = 0,
	TIME_HOUR,
	TIME_DAY
};

enum _:structIdHeadZombies
{
	HEADZOMBIE_RED = 0, // APs
	HEADZOMBIE_GREEN, // XP
	HEADZOMBIE_BLUE, // Items Extras
	HEADZOMBIE_YELLOW, // pH-pZ-pE
	HEADZOMBIE_WHITE // Modos (Si tienen alguna clase, se le da [APs y pH-pZ-pE])
};

enum _:structIdPages
{
	MENU_PAGE_BPW = 0,
	MENU_PAGE_BSW,
	MENU_PAGE_MY_WEAPONS,
	MENU_PAGE_MODELS,
	MENU_PAGE_HAB_CLASS,
	MENU_PAGE_ACHIEVEMENT_CLASS,
	MENU_PAGE_CLAN_INVITE,
	MENU_PAGE_CLAN_PERKS,
	MENU_PAGE_COLOR,
	MENU_PAGE_STATS_LEVELS,
	MENU_PAGE_STATS_GENERAL,
	MENU_PAGE_STATS_MODE,
	MENU_PAGE_HAT_CLASS,
	MENU_PAGE_MODES,
	MENU_PAGE_RULES
};

enum _:structIdDatas
{
	MENU_DATA_GAME = 0,
	MENU_DATA_MY_WEAPON_ID,
	MENU_DATA_MY_WEAPON_DATA_ID,
	MENU_DATA_MODEL_CLASS,
	MENU_DATA_MODEL_ID,
	MENU_DATA_DIFFICULT_CLASS,
	MENU_DATA_HAB_CLASS,
	MENU_DATA_HAB_ID,
	MENU_DATA_ACHIEVEMENT_CLASS,
	MENU_DATA_ACHIEVEMENT_IN,
	MENU_DATA_CLAN_MEMBER_ID,
	MENU_DATA_CLAN_PERK_ID,
	MENU_DATA_COLOR_TYPE,
	MENU_DATA_HUD_TYPE,
	MENU_DATA_HAT_ID,
	MENU_DATA_DUEL,
	MENU_DATA_MULTIPLIER
};

enum _:structIdGunGameTypes
{
	GUNGAME_NORMAL = 0,
	GUNGAME_ONLY_HEAD,
	GUNGAME_SLOW,
	GUNGAME_FAST,
	GUNGAME_CRAZY,
	GUNGAME_CLASSIC
};

enum _:structModes
{
	modeName[32],
	modeUsersNeed,
	modeOn
};

enum _:structClasses
{
	className[32],
	classMultAPs,
	classMultXP,
	Float:classMultCombo,
	classHealth,
	classSpeed,
	classGravity,
	classDamage,
	classRespawn,
	classReduceExtraItems,
	classPetitionMode
};

enum _:structWeapons
{
	weaponCSW,
	weaponEntName[32],
	weaponName[32],
	weaponLevel,
	weaponReset,
	Float:weaponDamageMult
};

enum _:structWeaponDatas
{
	weaponDataName[32],
	weaponDataId
};

enum _:structWeaponModels
{
	weaponModelLevel,
	weaponModelPath[128]
};

enum _:structExtraItems
{
	extraItemName[32],
	extraItemInfo[64],
	extraItemCost,
	extraItemLimitUser,
	extraItemLimitMap,
	extraItemTeam
};

enum _:structModels
{
	modelName[32],
	modelPrecache[128],
	modelClass,
	modelCycle
};

enum _:structDifficults
{
	difficultName[24],
	difficultInfo[128],
	Float:difficultHealth,
	Float:difficultSpeed
};

enum _:structHabsClasses
{
	habClassName[32],
	habClassPointName[32],
	habClassPointNameShort[16],
	habClassPointId
};

enum _:structHabs
{
	habName[32],
	habDesc[256],
	habValue,
	habCost,
	habMaxLevel,
	habClass
};

enum _:structAchievements
{
	achievementName[64],
	achievementInfo[128],
	achievementReward,
	achievementUsersNeedP,
	achievementUsersNeedA,
	achievementClass
};

enum _:structClanPerks
{
	clanPerkName[32],
	clanPerkDesc[128],
	clanPerkCost
};

enum _:structColors
{
	colorName[32],
	colorRed,
	colorGreen,
	colorBlue
};

enum _:structHats
{
	hatName[32],
	hatModel[128],
	hatDesc[192],
	hatDescExtra[192],
	hatUpgrade1, // Vida
	hatUpgrade2, // Velocidad
	hatUpgrade3, // Gravedad
	hatUpgrade4, // Daño
	hatUpgrade5, // Mult APs
	hatUpgrade6, // Mult XP
	hatUpgrade7, // Respawn Humano
	hatUpgrade8 // Descuento de Items
};

enum _:structCombo
{
	comboNeed,
	comboMessage[48],
	comboSound[64]
};

enum _:structDuels
{
	duelTypeName[32],
	duelTypePrefixName[16],
	duelTypeCommand[32],
	duelTypeCommandFunc[64]
};

new const SQL_HOST[] = "127.0.0.1";
new const SQL_USER[] = "dg_zpuser";
new const SQL_PASSWORD[] = "C17ftWMafhoFbR59";
new const SQL_DATABASE[] = "dg_zp";

new const PLAYER_MODEL_HUMAN[] = "sas";
new const PLAYER_MODEL_SURVIVOR[][] = {"dg-zp_survivor_00", "dg-zp_survivor_01", "dg-zp_survivor_02_f"};
new const PLAYER_MODEL_WESKER[] = "dg-zp_wesker_00";
new const PLAYER_MODEL_SNIPER[] = "dg-zp_sniper_00_f";
new const PLAYER_MODEL_JASON[] = "dg-zp_jason_00";
new const PLAYER_MODEL_PREDATOR[] = "dg-zp_predator_00";
new const PLAYER_MODEL_NEMESIS[][] = {"dg-zp_nemesis_00", "dg-zp_nemesis_01", "dg-zp_nemesis_02"};
new const PLAYER_MODEL_ASSASSIN[] = "dg-zp_assassin_00";
new const PLAYER_MODEL_ANNIHILATOR[] = "dg-zp_annihilator_00";
new const PLAYER_MODEL_FREDDY[] = "dg-zp_freddy_00";
new const PLAYER_MODEL_ALIEN[] = "dg-zp_alien_03";
new const PLAYER_MODEL_GRUNT[] = "dg-zp_grunt_00";
new const PLAYER_MODEL_TRIBAL[] = "dg-zp_tribal_00";
new const PLAYER_MODEL_L4D2[][] = {"dg-l4d_bill_00", "dg-l4d_francis_00", "dg-l4d_louis_00", "dg-l4d_zoei_00"};
new const PLAYER_MODEL_L4D2_HMS[] = "dg-zp_hms_00";
new const PLAYER_MODEL_L4D2_ZMS[] = "dg-zp_zms_00";

new const KNIFE_vMODEL_JASON[][] = {"models/dg/zp6/v_chainsaw_00.mdl", "models/dg/zp6/p_chainsaw_00.mdl"};
new const KNIFE_vMODEL_NEMESIS[] = "models/dg/zp6/v_knife_nemesis_00.mdl";
new const KNIFE_vMODEL_ASSASSIN[] = "models/dg/zp6/v_knife_assassin_00.mdl";
new const KNIFE_vMODEL_ANNIHILATOR[] = "models/dg/zp6/v_knife_annihilator_00.mdl";
new const KNIFE_vMODEL_FREDDY[] = "models/dg/zp6/v_knife_freddy_00.mdl";
new const KNIFE_vMODEL_ALIEN[] = "models/dg/zp6/v_knife_alien_00.mdl";
new const GRENADE_MODEL_INFECTION[][] = {"models/dg/zp6/v_grenade_infection_00.mdl", "models/dg/zp6/p_grenade_infection_00.mdl", "models/dg/zp6/w_grenade_infection_00.mdl"};
new const GRENADE_vMODEL_FIRE[] = "models/dg/zp6/v_grenade_fire_00.mdl";
new const GRENADE_vMODEL_NOVA[] = "models/dg/zp6/v_grenade_frost_00.mdl";
new const GRENADE_vMODEL_FLARE[] = "models/dg/zp6/v_grenade_flare_00.mdl";
new const GRENADE_vMODEL_NITRO[] = "models/dg/zp6/v_grenade_fire_00.mdl"; // COMPLETAR
new const GRENADE_vMODEL_SUPERNOVA[] = "models/dg/zp6/v_grenade_frost_00.mdl"; // COMPLETAR
new const GRENADE_vMODEL_IMMUNITY[] = "models/dg/zp6/v_grenade_flare_00.mdl"; // COMPLETAR
new const GRENADE_MODEL_DRUG[][] = {"models/dg/zp6/v_grenade_drug_00.mdl", "models/dg/zp6/p_grenade_drug_00.mdl", "models/dg/zp6/w_grenade_drug_00.mdl"};
new const GRENADE_MODEL_HYPERNOVA[][] = {"models/dg/zp6/v_grenade_hypernova_00.mdl", "models/dg/zp6/p_grenade_hypernova_00.mdl", "models/dg/zp6/w_grenade_hypernova_00.mdl"};
new const GRENADE_MODEL_BUBBLE[][] = {"models/dg/zp6/v_grenade_bubble_00.mdl", "models/dg/zp6/p_grenade_bubble_00.mdl", "models/dg/zp6/w_grenade_bubble_00.mdl"};
new const GRENADE_vMODEL_KILL[] = "models/dg/zp6/v_grenade_kill_00.mdl";
new const GRENADE_vMODEL_MOLOTOV[] = "models/dg/zp6/v_grenade_molotov_00.mdl";
new const GRENADE_vMODEL_ANTIDOTE[] = "models/dg/zp6/v_grenade_antidote_00.mdl";
new const BAZOOKA_vMODEL[] = "models/dg/zp6/v_bazooka_00.mdl";
new const BAZOOKA_pMODEL[] = "models/dg/zp6/p_bazooka_00.mdl";

new const MODEL_BUBBLE[] = "models/dg/zp6/grenade_bubble_aura_00.mdl";
new const MODEL_HEADZOMBIE[] = "models/dg/zp6/headzombie_00.mdl";
new const MODEL_ROCKET[] = "models/dg/zp6/rocket_00.mdl";
new const MODEL_SKULL[] = "models/gib_skull.mdl";

new const SOUND_ARMOR_HIT[] = "player/bhit_helmet-1.wav";
new const SOUND_AMMO_PICKUP[] = "items/ammopickup1.wav";
new const SOUND_WIN_HUMANS[] = "dg/zp6/win_zombies_00.wav";
new const SOUND_WIN_ZOMBIES[] = "dg/zp6/win_humans_00.wav";
new const SOUND_WIN_NO_ONE[] = "ambience/3dmstart.wav";
new const SOUND_ROUND_GENERAL[][] = {"dg/zp6/round_general_00.wav", "dg/zp6/round_general_01.wav", "dg/zp6/round_general_02.wav", "dg/zp6/round_general_03.wav"};
new const SOUND_ROUND_SURVIVOR[][] = {"dg/zp6/round_survivor_00.wav", "dg/zp6/round_survivor_01.wav"};
new const SOUND_ROUND_NEMESIS[][] = {"dg/zp6/round_nemesis_00.wav", "dg/zp6/round_nemesis_01.wav"};
new const SOUND_ROUND_ASSASSIN[] = "dg/zp6/round_assassin_00.wav";
new const SOUND_ROUND_ARMAGEDDON[] = "dg/zp6/round_armageddon_00.wav";
new const SOUND_ROUND_MEGA_ARMAGEDDON[] = "sound/dg/zp6/round_mega_armageddon_00.mp3";
new const SOUND_ROUND_FVSJ[] = "sound/dg/zp6/round_fvsj_00.mp3";
new const SOUND_ROUND_GUNGAME[] = "dg/zp6/round_gungame.wav";
new const SOUND_ROUND_SPECIAL[] = "dg/zp6/round_special_00.wav";
new const SOUND_ROUND_L4D2[] = "dg/zp6/round_l4d2.wav";
new const SOUND_HUMAN_ANTIDOTE[] = "items/smallmedkit1.wav";
new const SOUND_HUMAN_KNIFE_DEFAULT[][] = {"weapons/knife_deploy1.wav", "weapons/knife_hit1.wav", "weapons/knife_hit2.wav", "weapons/knife_hit3.wav", "weapons/knife_hit4.wav", "weapons/knife_hitwall1.wav", "weapons/knife_slash1.wav", "weapons/knife_slash2.wav", "weapons/knife_stab.wav"};
new const SOUND_WESKER_LASER[] = "weapons/electro5.wav";
new const SOUND_JASON_CHAINSAW[][] = {"dg/zp6/jason_chainsaw_deploy.wav", "dg/zp6/jason_chainsaw_hit1.wav", "dg/zp6/jason_chainsaw_hit2.wav", "dg/zp6/jason_chainsaw_hit1.wav", "dg/zp6/jason_chainsaw_hit2.wav", "dg/zp6/jason_chainsaw_hitwall.wav", "dg/zp6/jason_chainsaw_miss.wav", "dg/zp6/jason_chainsaw_miss.wav", "dg/zp6/jason_chainsaw_stab.wav"};
new const SOUND_ZOMBIE_PAIN[][] = {"dg/zp6/zombie_pain_00.wav", "dg/zp6/zombie_pain_01.wav", "dg/zp6/zombie_pain_02.wav"};
new const SOUND_SPECIALMODE_PAIN[][] = {"dg/zp6/specialmode_pain_00.wav", "dg/zp6/specialmode_pain_01.wav", "dg/zp6/specialmode_pain_02.wav"};
new const SOUND_ZOMBIE_KNIFE[][] = {"dg/zp6/zombie_knife_00.wav", "dg/zp6/zombie_knife_01.wav", "dg/zp6/zombie_knife_02.wav"};
new const SOUND_ZOMBIE_INFECT[][] = {"dg/zp6/zombie_infect_00.wav", "dg/zp6/zombie_infect_01.wav", "dg/zp6/zombie_infect_02.wav", "dg/zp6/zombie_infect_03.wav", "dg/zp6/zombie_infect_04.wav", "dg/zp6/zombie_infect_05.wav", "dg/zp6/zombie_infect_06.wav", "dg/zp6/zombie_infect_07.wav"};
new const SOUND_ZOMBIE_ALERT[][] = {"dg/zp6/zombie_alert_00.wav", "dg/zp6/zombie_alert_01.wav", "dg/zp6/zombie_alert_02.wav"};
new const SOUND_ZOMBIE_MADNESS[] = "dg/zp6/zombie_madness_00.wav";
new const SOUND_ZOMBIE_DIE[][] = {"dg/zp6/zombie_die_00.wav", "dg/zp6/zombie_die_01.wav", "dg/zp6/zombie_die_02.wav", "dg/zp6/zombie_die_03.wav", "dg/zp6/zombie_die_04.wav"};
new const SOUND_ZOMBIE_BURN[][] = {"dg/zp6/zombie_burn_00.wav", "dg/zp6/zombie_burn_01.wav", "dg/zp6/zombie_burn_02.wav"};
new const SOUND_NADE_INFECT_EXPLO[] = "dg/zp6/grenade_infection_explode_00.wav";
new const SOUND_NADE_INFECT_EXPLO_PLAYER[][] = {"scientist/scream20.wav", "scientist/scream22.wav", "scientist/scream05.wav"};
new const SOUND_NADE_FIRE_EXPLO[] = "dg/zp6/grenade_fire_explode_00.wav";
new const SOUND_NADE_NOVA_EXPLO[] = "dg/zp6/grenade_nova_explode_00.wav";
new const SOUND_NADE_NOVA_PLAYER[] = "dg/zp6/grenade_nova_player_00.wav";
new const SOUND_NADE_NOVA_BREAK[] = "dg/zp6/grenade_nova_break_00.wav";
new const SOUND_NADE_NOVA_SLOWDOWN[] = "player/pl_duct2.wav";
new const SOUND_NADE_FLARE_EXPLO[] = "dg/zp6/grenade_flare_explode_00.wav";
new const SOUND_NADE_MOLOTOV_EXPLO[] = "dg/zp6/molotov_explode_00.wav";
new const SOUND_NADE_BUBBLE_EXPLO[] = "buttons/button1.wav";
new const SOUND_BAZOOKA[][] = {"weapons/rocketfire1.wav", "dg/zp6/bazooka_01.wav"};
new const SOUND_LEVEL_UP[] = "dg/zp6/levelup_00.wav";

new const SPRITE_COLORS_BALLS[][] =
{
	"sprites/glow04.spr",
	"sprites/dg/zp6/fireworks/red_flare_00.spr",
	"sprites/dg/zp6/fireworks/green_flare_00.spr",
	"sprites/dg/zp6/fireworks/blue_flare_00.spr",
	"sprites/dg/zp6/fireworks/yellow_flare_00.spr",
	"sprites/dg/zp6/fireworks/purple_flare_00.spr",
	"sprites/dg/zp6/fireworks/lightblue_flare_00.spr",
	"sprites/hotglow.spr"
};

new const REMOVE_ENTS[][] =
{
	"func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity", "monster_scientist", "info_hostage_rescue",
	"func_hostage_rescue", "env_rain", "env_snow", "env_fog", "func_vehicle", "info_map_parameters", "func_buyzone", "armoury_entity", "game_text", "func_tank", "func_tankcontrols"
};

new const BLOCK_COMMANDS[][] =
{
	"buy", "buyequip", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47", "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
	"sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "fiveseven", "12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum",
	"d3au1", "krieg550", "smg", "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown",
	"radio3", "buyammo1", "buyammo2"
};

new const WEAPON_NAMES[][] =
{
	"", "P228 Compact", "", "Schmidt Scout", "", "XM1014 M4", "", "Ingram MAC-10", "Steyr AUG A1", "", "Dual Elite Berettas", "FiveseveN", "UMP 45", "SG-550 Auto-Sniper", "IMI Galil", "Famas", "USP .45 ACP Tactical", "Glock 18C",
	"AWP Magnum Sniper", "MP5 Navy", "M249 Para Machinegun", "M3 Super 90", "M4A1 Carbine", "Schmidt TMP", "G3SG1 Auto-Sniper", "", "Desert Eagle .50 AE", "SG-552 Commando", "AK-47 Kalashnikov", "Cuchillo", "ES P90"
};

new const WEAPON_ENT_NAMES[][] =
{
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil",
	"weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90"
};

new const CS_TEAM_NAMES[][] = {"", "TERRORIST", "CT", "SPECTATOR"};

new const ENT_CLASSNAME_ROCKET[] = "entRocket";
new const ENT_CLASSNAME_HAT[] = "entHat";
new const ENT_CLASSNAME_HEADZOMBIE[] = "entHeadZombie";
new const ENT_CLASSNAME_WGM[] = "entWalkGuardMenu";
new const ENTTHINK_CLASSNAME_GENERAL[] = "entThinkGeneral";
new const ENTTHINK_CLASSNAME_MEGA_GUNGAME[] = "entThinkMegaGunGame";

new const FIRST_JOIN_MSG[] = "#Team_Select";
new const FIRST_JOIN_MSG_SPEC[] = "#Team_Select_Spect";

new const Float:DEFAULT_DELAY[] = {0.00, 2.70, 0.00, 2.00, 0.00, 0.55, 0.00, 3.15, 3.30, 0.00, 4.50, 2.70, 3.50, 3.35, 2.45, 3.30, 2.70, 2.20, 2.50, 2.63, 4.70, 0.55, 3.05, 2.12, 3.50, 0.00, 2.20, 3.00, 2.45, 0.00, 3.40};
new const DEFAULT_MAX_CLIP[] = {-1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50};
new const DEFAULT_ANIMS[] = {-1, 5, -1, 3, -1, 6, -1, 1, 1, -1, 14, 4, 2, 3, 1, 1, 13, 7, 4, 1, 3, 6, 11, 1, 3, -1, 4, 1, 1, -1, 1};
new const AMMO_WEAPON[] = {0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4};
new const MAX_BPAMMO[] = {-1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100};
new const MAX_CLIP[] = {-1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 50};
new const AMMO_TYPE[][] =
{
	"", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato",
	"556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm"
};
new const AMMO_OFFSET[] =
{
	-1, OFFSET_P228_AMMO, -1, OFFSET_SCOUT_AMMO, OFFSET_HE_AMMO, OFFSET_M3_AMMO, OFFSET_C4_AMMO, OFFSET_USP_AMMO, OFFSET_FAMAS_AMMO, OFFSET_SMOKE_AMMO, OFFSET_GLOCK_AMMO, OFFSET_FIVESEVEN_AMMO, OFFSET_USP_AMMO, OFFSET_FAMAS_AMMO, OFFSET_FAMAS_AMMO,
	OFFSET_FAMAS_AMMO, OFFSET_USP_AMMO, OFFSET_GLOCK_AMMO, OFFSET_AWM_AMMO, OFFSET_GLOCK_AMMO, OFFSET_PARA_AMMO, OFFSET_M3_AMMO, OFFSET_FAMAS_AMMO, OFFSET_GLOCK_AMMO, OFFSET_SCOUT_AMMO, OFFSET_FLASH_AMMO, OFFSET_DEAGLE_AMMO, OFFSET_FAMAS_AMMO, OFFSET_SCOUT_AMMO, -1, OFFSET_FIVESEVEN_AMMO
};

new const __MODES[structIdModes][structModes] =
{
	{"", 0, 0},
	{"INFECCIÓN", 1, 1},
	{"PLAGUE", 10, 1},
	{"ARMAGEDDON", 16, 1},
	{"MEGA ARMAGEDDON", 24, 2},
	{"GUNGAME", 24, 2},
	{"MEGA GUNGAME", 24, 2},
	{"FREDDY vs JASON", 16, 1},
	{"SYNAPSIS", 16, 1},
	{"ALIEN VS DEPREDADOR", 16, 1},
	{"DUELO FINAL", 16, 1},
	{"DRUNK", 16, 1},
	{"SURVIVOR", 8, 1},
	{"WESKER", 12, 1},
	{"SNIPER ELITE", 12, 1},
	{"JASON", 12, 1},
	{"NEMESIS", 8, 1},
	{"ASSASSIN", 12, 1},
	{"ANIQUILADOR", 12, 1},
	{"SNIPER", 16, 1},
	{"GRUNT", 12, 1},
	{"TRIBAL", 16, 1},
	{"L4D2", 24, 1}
};

new const __CLASSES[][structClasses] =
{
	{"Básica",			0, 0, 5.0, 0, 0, 0, 0, 0, 	0, 	0},
	{"Principiante", 	1, 1, 4.5, 1, 1, 1, 1, 0, 	5, 	55},
	{"Intermedia", 		2, 2, 4.0, 2, 2, 2, 2, 0, 	10, 45},
	{"Avanzada", 		3, 3, 3.5, 3, 3, 3, 3, 0, 	15, 35},
	{"Pro", 			4, 4, 3.0, 4, 4, 4, 4, 15, 	20, 25},
	{"Experto", 		5, 5, 2.5, 5, 5, 5, 5, 30, 	25, 15}
};

new const PRIMARY_WEAPONS[][structWeapons] =
{
	{CSW_MAC10, "weapon_mac10", "Ingram MAC-10", 1, 0, 1.0},				// 28
	{CSW_TMP, "weapon_tmp", "Schmidt TMP", 1, 0, 1.0},						// 19
	{CSW_M3, "weapon_m3", "M3 Super 90", 1, 0, 1.0},						// 174
	{CSW_UMP45, "weapon_ump45", "UMP 45", 1, 0, 1.0},						// 29
	{CSW_XM1014, "weapon_xm1014", "XM1014 M4", 1, 0, 1.0},					// 115
	{CSW_P90, "weapon_p90", "ES P90", 1, 0, 1.0},							// 20
	{CSW_MP5NAVY, "weapon_mp5navy", "MP5 Navy", 1, 0, 1.0},					// 25
	{CSW_FAMAS, "weapon_famas", "Famas", 1, 0, 1.0},						// 29
	{CSW_GALIL, "weapon_galil", "IMI Galil", 1, 0, 1.0},					// 29
	{CSW_AUG, "weapon_aug", "Steyr AUG A1", 1, 0, 1.0},						// 31
	{CSW_SG552, "weapon_sg552", "SG-552 Commando", 1, 0, 1.0},				// 32
	{CSW_AK47, "weapon_ak47", "AK-47 Kalashnikov", 1, 0, 1.0},				// 35
	{CSW_M4A1, "weapon_m4a1", "M4A1 Carbine", 1, 0, 1.0},					// 31

	{CSW_MAC10, "weapon_mac10", "FARA 83", 250, 0, 3.29},			 		// 120
	{CSW_TMP, "weapon_tmp", "Tavor TAR-21", 250, 0, 5.58},			 		// 125
	{CSW_M3, "weapon_m3", "HK G3", 250, 0, 1.23},			 				// 218
	{CSW_UMP45, "weapon_ump45", "IMBEL MD-2", 250, 0, 3.49},				// 130
	{CSW_XM1014, "weapon_xm1014", "EF88 / F90", 250, 0, 1.36},				// 155
	{CSW_P90, "weapon_p90", "Khaybar KH2002", 250, 0,  5.76},				// 135
	{CSW_MP5NAVY, "weapon_mp5navy", "MKb.42(H)", 250, 0, 4.61},				// 140
	{CSW_FAMAS, "weapon_famas", "Enfield EM-2", 250, 0, 4.01},				// 145
	{CSW_GALIL, "weapon_galil", "LAPA FA 03", 250, 0, 4.18},				// 150
	{CSW_AUG, "weapon_aug", "Steyr ACR", 250, 0, 4.01},			 			// 155
	{CSW_SG552, "weapon_sg552", "IWI X95", 250, 0, 4.01},			 		// 160
	{CSW_AK47, "weapon_ak47", "Pindad SS2", 250, 0, 3.72},			 		// 165
	{CSW_M4A1, "weapon_m4a1", "Madsen LAR", 250, 0, 4.49},			 		// 170
	
	{CSW_MAC10, "weapon_mac10", "IMBEL IA2 5.56", 500, 0, 5.26},			// 175
	{CSW_TMP, "weapon_tmp", "CQ M311", 500, 0, 8.48},			 			// 180
	{CSW_M3, "weapon_m3", "Diemaco C7A1", 500, 0, 1.35},			 		// 238
	{CSW_UMP45, "weapon_ump45", "HK G41",  500, 0, 5.38},			 		// 185
	{CSW_XM1014, "weapon_xm1014", "FN FAL", 500, 0, 1.53},					// 175
	{CSW_P90, "weapon_p90", "FX-05 Xiuhcoatl", 500, 0, 8.51},				// 190
	{CSW_MP5NAVY, "weapon_mp5navy", "CETME mod.T", 500, 0, 6.81},			// 195
	{CSW_FAMAS, "weapon_famas", "Gilboa Snake", 500, 0, 5.90},				// 200
	{CSW_GALIL, "weapon_galil", "Cristobal M2", 500, 0, 6.07},				// 205
	{CSW_AUG, "weapon_aug", "SA80 / L85", 500, 0, 5.78},			 		// 210
	{CSW_SG552, "weapon_sg552", "QBS-06", 500, 0, 5.72},					// 215
	{CSW_AK47, "weapon_ak47", "NAR-10", 500, 0, 5.29},			 			// 220
	{CSW_M4A1, "weapon_m4a1", "Type 86s", 500, 0, 6.26},				 	// 225
	
	{CSW_MAC10, "weapon_mac10", "OTs-12 Tiss", 1, 1, 7.22},					// 230
	{CSW_TMP, "weapon_tmp", "CIS SAR-80", 11, 1, 2.37},			 			// 235
	{CSW_M3, "weapon_m3", "Korobov TKB-408", 1, 1, 1.46},					// 258
	{CSW_UMP45, "weapon_ump45", "AS Val",  1, 1, 7.28},			 			// 240
	{CSW_XM1014, "weapon_xm1014", "Fedorov avtomat", 1, 1, 1.71},			// 195
	{CSW_P90, "weapon_p90", "TRW LMR", 1, 1, 11.26},			 			// 245
	{CSW_MP5NAVY, "weapon_mp5navy", "ADS dual medium", 1, 1, 9.01},			// 250
	{CSW_FAMAS, "weapon_famas", "APS underwater", 1, 1, 7.80},				// 255
	{CSW_GALIL, "weapon_galil", "A-91M", 1, 1, 7.97},			 			// 260
	{CSW_AUG, "weapon_aug", "SA80 / L85", 1, 1, 7.55},			 			// 265
	{CSW_SG552, "weapon_sg552", "Armalite AR-10", 1, 1, 7.44},				// 270
	{CSW_AK47, "weapon_ak47", "AN-94 Abakan", 1, 1, 6.86},					// 275
	{CSW_M4A1, "weapon_m4a1", "ASh-12.7", 1, 1, 8.04},			 			// 280
	
	{CSW_MAC10, "weapon_mac10", "Ruger AC-556", 500, 1, 9.18},				// 285
	{CSW_TMP, "weapon_tmp", "SA Vz.58", 500, 1, 14.27},			 			// 290
	{CSW_M3, "weapon_m3", "T65", 500, 1, 1.57},			 					// 278
	{CSW_UMP45, "weapon_ump45", "XM29 OICW", 500, 1, 9.18},					// 295
	{CSW_XM1014, "weapon_xm1014", "Bushmaster M17s", 500, 1, 1.88},			// 215
	{CSW_P90, "weapon_p90", "Daewoo K11", 500, 1, 14.01},			 		// 300
	{CSW_MP5NAVY, "weapon_mp5navy", "M27 IAR", 500, 1, 11.21},				// 305
	{CSW_FAMAS, "weapon_famas", "RobArm M96 XCR", 500, 1, 9.69},			// 310
	{CSW_GALIL, "weapon_galil", "FN Mk.16", 500, 1, 9.87},			 		// 315
	{CSW_AUG, "weapon_aug", "SA80 / L85", 500, 1, 9.33},			 		// 320
	{CSW_SG552, "weapon_sg552", "CZ 805", 500, 1, 9.16},			 		// 325
	{CSW_AK47, "weapon_ak47", "APS-95", 500, 1, 8.43},			 			// 330
	{CSW_M4A1, "weapon_m4a1", "Valmet Sako Rk.62", 500, 1, 9.81},			// 335
	
	{CSW_MAC10, "weapon_mac10", "MKEK MPT-76", 1, 2, 11.15},				// 340
	{CSW_TMP, "weapon_tmp", "Mk.17 SCAR", 1, 2, 17.16},			 			// 345
	{CSW_M3, "weapon_m3", "HK 33", 1, 2, 1.69},			 					// 298
	{CSW_UMP45, "weapon_ump45", "FN CAL", 1, 2, 11.07},						// 350
	{CSW_XM1014, "weapon_xm1014", "MSBS Radon", 1, 2, 2.06},				// 235
	{CSW_P90, "weapon_p90", "T65", 1, 2, 16.76},			 				// 355
	{CSW_MP5NAVY, "weapon_mp5navy", "CS/LR-14", 1, 2, 13.40},				// 360
	{CSW_FAMAS, "weapon_famas", "Mp-43", 1, 2, 11.59},			 			// 365
	{CSW_GALIL, "weapon_galil", "MKb.42(W)", 1, 2, 11.76},					// 370
	{CSW_AUG, "weapon_aug", "SA80 / L85", 1, 2, 11.10},				 		// 375
	{CSW_SG552, "weapon_sg552", "SIG-Sauer 716", 1, 2, 10.88},				// 380
	{CSW_AK47, "weapon_ak47", "Z-M LR-300", 1, 2, 10.01},					// 385
	{CSW_M4A1, "weapon_m4a1", "Colt CAR-15", 1, 2, 11.59},					// 390
	
	{CSW_MAC10, "weapon_mac10", "Valmet M82", 500, 2, 13.11},				// 395
	{CSW_TMP, "weapon_tmp", "Beretta BM 59", 500, 2, 20.06},				// 400
	{CSW_M3, "weapon_m3", "Type 89", 500, 2, 1.80},			 				// 318
	{CSW_UMP45, "weapon_ump45", "Interdynamics MKS", 500, 2, 12.97},		// 405
	{CSW_XM1014, "weapon_xm1014", "Vepr", 500, 2, 2.23},			 		// 255
	{CSW_P90, "weapon_p90", "OTs-14 Groza", 500, 2, 19.51},					// 410
	{CSW_MP5NAVY, "weapon_mp5navy", "Daewoo K11", 500, 2, 15.61},			// 415
	{CSW_FAMAS, "weapon_famas", "Vektor CR-21", 500, 2, 13.49},				// 420
	{CSW_GALIL, "weapon_galil", "VHS", 500, 2, 13.66},			 			// 425
	{CSW_AUG, "weapon_aug", "BT APC-556", 500, 2, 12.88},			 		// 430
	{CSW_SG552, "weapon_sg552", "Type 95 QBZ-95", 500, 2, 12.60},			// 435
	{CSW_AK47, "weapon_ak47", "Bofors AK5", 500, 2, 11.58},					// 440
	{CSW_M4A1, "weapon_m4a1", "Colt XM-177", 500, 2, 13.36},				// 445
	
	{CSW_MAC10, "weapon_mac10", "Leader SAR", 1, 3, 15.08},					// 450
	{CSW_TMP, "weapon_tmp", "Remington 7600", 1, 3, 22.95},					// 455
	{CSW_M3, "weapon_m3", "Kel-tec SUB 2000", 1, 3, 1.91},					// 338
	{CSW_UMP45, "weapon_ump45", "BCM CM4 Storm", 1, 3, 14.87},				// 460
	{CSW_XM1014, "weapon_xm1014", "AIA M10", 1, 3, 2.41},					// 275
	{CSW_P90, "weapon_p90", "Rossi 92", 1, 3, 22.26},			 			// 465
	{CSW_MP5NAVY, "weapon_mp5navy", "Hi-Point Model 995", 1, 3, 17.80},		// 470
	{CSW_FAMAS, "weapon_famas", "Vepr MA-9", 1, 3, 15.38},					// 475
	{CSW_GALIL, "weapon_galil", "KSO-9 Krechet", 1, 3, 15.56},				// 480
	{CSW_AUG, "weapon_aug", "Armalon PC", 1, 3, 14.65},			 			// 485
	{CSW_SG552, "weapon_sg552", "Ruger PC-4", 1, 3, 14.32},					// 490
	{CSW_AK47, "weapon_ak47", "Kel-tec RDB", 1, 3, 13.15},					// 495
	{CSW_M4A1, "weapon_m4a1", "Heckler-Koch SL-6", 1, 3, 15.13},			// 500
	
	{CSW_MAC10, "weapon_mac10", "Cobra", 1, 4, 17.04},			 			// 505
	{CSW_TMP, "weapon_tmp", "Ar-15", 1, 4, 25.85},			 				// 510
	{CSW_M3, "weapon_m3", "JR carbine", 1, 4, 2.03},			 			// 358
	{CSW_UMP45, "weapon_ump45", "Safir T15", 1, 4, 16.76},					// 515
	{CSW_XM1014, "weapon_xm1014", "Kommando LDP", 1, 4, 2.58},				// 295
	{CSW_P90, "weapon_p90", "Magpul MASADA", 1, 4, 25.01},					// 520
	{CSW_MP5NAVY, "weapon_mp5navy", "DRD Paratus", 1, 4, 20.01},			// 525
	{CSW_FAMAS, "weapon_famas", "MPAR-556", 1, 4, 17.28},					// 530
	{CSW_GALIL, "weapon_galil", "K&M M17S-556", 1, 4, 17.45},				// 535
	{CSW_AUG, "weapon_aug", "Taurus CT G2", 1, 4, 16.42},					// 540
	{CSW_SG552, "weapon_sg552", "TPD AXR", 1, 4, 16.04},					// 545
	{CSW_AK47, "weapon_ak47", "MSAR STG-556", 1, 4, 14.72},					// 550
	{CSW_M4A1, "weapon_m4a1", "Colt LE-901", 1, 4, 16.91},					// 555
	
	{CSW_MAC10, "weapon_mac10", "SMLE Lee-Enfield", 1, 5, 19.01},			// 560
	{CSW_TMP, "weapon_tmp", "Krag–Jorgensen", 1, 5, 28.74},					// 565
	{CSW_M3, "weapon_m3", "Winchester M1895", 1, 5, 2.14},					// 378
	{CSW_UMP45, "weapon_ump45", "Mauser 98", 1, 5, 18.66},					// 570
	{CSW_XM1014, "weapon_xm1014", "35M", 1, 5, 2.76},			 			// 315
	{CSW_P90, "weapon_p90", "Lebel M1886", 1, 5, 27.76},				 	// 575
	{CSW_MP5NAVY, "weapon_mp5navy", "Lee Navy M1895", 1, 5, 22.21},			// 580
	{CSW_FAMAS, "weapon_famas", "Madsen M1947", 1, 5, 19.18},				// 585
	{CSW_GALIL, "weapon_galil", "Gew.88", 1, 5, 19.35},			 			// 590
	{CSW_AUG, "weapon_aug", "De Lisle Commando", 1, 5, 18.20},				// 595
	{CSW_SG552, "weapon_sg552", "Carcano M91", 1, 5, 17.76},				// 600
	{CSW_AK47, "weapon_ak47", "SKS Simonov", 1, 5, 16.29},					// 605
	{CSW_M4A1, "weapon_m4a1", "M1903 Springfield", 1, 5, 18.68},			// 610
	
	{CSW_MAC10, "weapon_mac10", "Berthier 1890", 1, 6, 20.97},				// 615
	{CSW_TMP, "weapon_tmp", "VG.1-5", 1, 6, 21.64},			 				// 620
	{CSW_M3, "weapon_m3", "FG-42", 1, 6, 2.25},			 					// 398
	{CSW_UMP45, "weapon_ump45", "K31", 1, 6, 20.56},			 			// 625
	{CSW_XM1014, "weapon_xm1014", "MAS-36", 1, 6, 2.93},					// 335
	{CSW_P90, "weapon_p90", "AVS-36 Simonov", 1, 6, 30.51},					// 630
	{CSW_MP5NAVY, "weapon_mp5navy", "G.41(M)", 1, 6, 24.40},				// 635
	{CSW_FAMAS, "weapon_famas", "FN SAFN-49", 500, 6, 21.07},				// 640
	{CSW_GALIL, "weapon_galil", "Mauser M1889", 500, 6, 21.25},				// 645
	{CSW_AUG, "weapon_aug", "Arisaka 38", 500, 6, 19.97},				 	// 650
	{CSW_SG552, "weapon_sg552", "Hakim", 500, 6, 19.47},			 		// 655
	{CSW_AK47, "weapon_ak47", "Mondragon", 500, 6, 17.86},					// 660
	{CSW_M4A1, "weapon_m4a1", "AG-42 Ljungman", 500, 6, 20.46},				// 665
	
	{CSW_MAC10, "weapon_mac10", "M1 Garand", 1, 7, 22.93},					// 670
	{CSW_TMP, "weapon_tmp", "ZH-29", 1, 7, 34.53},			 				// 675
	{CSW_M3, "weapon_m3", "Meunier M1916", 1, 7, 2.37},			 			// 418
	{CSW_UMP45, "weapon_ump45", "Pedersen T1", 1, 7, 22.45},				// 680
	{CSW_XM1014, "weapon_xm1014", "SVT-38", 1, 7, 3.11},					// 355
	{CSW_P90, "weapon_p90", "Rasheed", 1, 7, 33.25},			 			// 685
	{CSW_MP5NAVY, "weapon_mp5navy", "MAS-1949", 1, 7, 28.61},				// 690
	{CSW_FAMAS, "weapon_famas", "RSC M1917", 500, 7, 22.97},				// 695
	{CSW_GALIL, "weapon_galil", "S&W Light 1940", 500, 7, 23.14},			// 700
	{CSW_AUG, "weapon_aug", "M1941 Johnson", 500, 7, 21.75},				// 705
	{CSW_SG552, "weapon_sg552", "Farquhar-Hill", 500, 7, 21.19},			// 710
	{CSW_AK47, "weapon_ak47", "SVT-40 Tokarev", 500, 7, 19.43},				// 715
	{CSW_M4A1, "weapon_m4a1", "Madsen M1896", 500, 7, 22.23},				// 720
	
	{CSW_MAC10, "weapon_mac10", "M1917 US Enfield", 1, 8, 24.90},			// 725
	{CSW_TMP, "weapon_tmp", "Korobov TKB-517", 1, 8, 37.43},				// 730
	{CSW_M3, "weapon_m3", "9A-91", 1, 8, 2.48},			 					// 438
	{CSW_UMP45, "weapon_ump45", "Vz.52/57", 1, 8, 24.35},					// 735
	{CSW_XM1014, "weapon_xm1014", "Mosin", 1, 8, 3.29},						// 375
	{CSW_P90, "weapon_p90", "ASh-12.7", 1, 8, 36.00},			 			// 740
	{CSW_MP5NAVY, "weapon_mp5navy", "ADS DualM", 1, 8, 28.80},				// 745
	{CSW_FAMAS, "weapon_famas", "G.41(W)", 500, 8, 24.87},					// 750
	{CSW_GALIL, "weapon_galil", "Breda", 500, 8, 25.04},			 		// 755
	{CSW_AUG, "weapon_aug", "Steyr Mannlicher M95", 500, 8, 23.52},			// 760
	{CSW_SG552, "weapon_sg552", "Baryshev AB-7", 500, 8, 22.91},			// 765
	{CSW_AK47, "weapon_ak47", "AKS-74U", 500, 8, 21.01},			 		// 770
	{CSW_M4A1, "weapon_m4a1", "OTs-14 Groza", 500, 8, 24.01},				// 775
	
	{CSW_MAC10, "weapon_mac10", "Armalite AR-18", 1, 9, 26.86},				// 780
	{CSW_TMP, "weapon_tmp", "FMK-3", 1, 9, 40.32},			 				// 785
	{CSW_M3, "weapon_m3", "APC-300", 1, 9, 2.60},			 				// 458
	{CSW_UMP45, "weapon_ump45", "Desert Tech MDR", 1, 9, 26.25},			// 790
	{CSW_XM1014, "weapon_xm1014", "ST Kinetics SAR-21", 1, 9, 3.46},		// 395
	{CSW_P90, "weapon_p90", "K6-92", 1, 9, 38.75},							// 795
	{CSW_MP5NAVY, "weapon_mp5navy", "Daewoo K1/K2", 1, 9, 31.00},			// 800
	{CSW_FAMAS, "weapon_famas", "Interdynamics MKR", 1, 9, 26.76},			// 805
	{CSW_GALIL, "weapon_galil", "SR-3M Vikhr", 500, 9, 26.94},				// 810
	{CSW_AUG, "weapon_aug", "SIG-Sauer 516", 500, 9, 25.30},				// 815
	{CSW_SG552, "weapon_sg552", "Halcon M/943", 500, 9, 24.63},				// 820
	{CSW_AK47, "weapon_ak47", "Bofors AK5", 500, 9, 22.58},					// 825
	{CSW_M4A1, "weapon_m4a1", "Korobov TKB-022", 500, 9, 25.78},			// 830
	
	{CSW_MAC10, "weapon_mac10", "Mekanika URU", 1, 10, 28.83},				// 835
	{CSW_TMP, "weapon_tmp", "K-50M", 1, 10, 43.22},			 				// 840
	{CSW_M3, "weapon_m3", "Sterling L2", 1, 10, 2.71},			 			// 478
	{CSW_UMP45, "weapon_ump45", "Shipka", 1, 10, 28.14},					// 845
	{CSW_XM1014, "weapon_xm1014", " Vigneron M2", 1, 10, 3.64},				// 415
	{CSW_P90, "weapon_p90", "Walther MPL", 1, 10, 41.50},					// 850
	{CSW_MP5NAVY, "weapon_mp5navy", "MCEM-2", 1, 10, 33.20},				// 855
	{CSW_FAMAS, "weapon_famas", "Lanchester Mk.1", 500, 10, 28.66},			// 860
	{CSW_GALIL, "weapon_galil", "Gevarm D4", 500, 10, 28.83},				// 865
	{CSW_AUG, "weapon_aug", "Steyr-Solothurn MP.34", 500, 10, 27.07},		// 870
	{CSW_SG552, "weapon_sg552", "EMP.35 Erma", 500, 10, 26.35},				// 875
	{CSW_AK47, "weapon_ak47", "Dux M53", 500, 10, 25.15},			 		// 880
	{CSW_M4A1, "weapon_m4a1", "Colt SCAMP", 500, 10, 27.55},				// 885
	
	{CSW_MAC10, "weapon_mac10", "Erma MP-56", 1, 12, 30.79},				// 890
	{CSW_TMP, "weapon_tmp", "FNA-B 43", 1, 12, 46.11},			 			// 895
	{CSW_M3, "weapon_m3", "Benelli CB-M2", 1, 12, 2.82},				 	// 498
	{CSW_UMP45, "weapon_ump45", "Hovea m/49", 1, 12, 30.04},				// 900
	{CSW_XM1014, "weapon_xm1014", "MK.36 Schmeisser", 1, 12, 3.81},			// 435
	{CSW_P90, "weapon_p90", "Star Z-84", 1, 12, 44.25},			 			// 905
	{CSW_MP5NAVY, "weapon_mp5navy", "CETME C2", 1, 12, 35.40},				// 910
	{CSW_FAMAS, "weapon_famas", "MSMC", 500, 12, 30.56},			 		// 915
	{CSW_GALIL, "weapon_galil", "Micro UZI", 500, 12, 30.73},				// 920
	{CSW_AUG, "weapon_aug", "Madsen m/45", 500, 12, 28.84},					// 925
	{CSW_SG552, "weapon_sg552", "SOCIMI 821", 500, 12, 28.07},				// 930
	{CSW_AK47, "weapon_ak47", "Zk-383", 500, 12, 25.72},			 		// 935
	{CSW_M4A1, "weapon_m4a1", "Spectre M4", 500, 12, 29.33},				// 940
	
	{CSW_MAC10, "weapon_mac10", "Armaguerra OG-43", 1, 14, 32.75},			// 945
	{CSW_TMP, "weapon_tmp", "Smith&Wesson M76", 1, 14, 49.00},				// 950
	{CSW_M3, "weapon_m3", "Mors wz.39", 1, 14, 2.94},			 			// 518
	{CSW_UMP45, "weapon_ump45", "Madsen m/46", 1, 14, 31.94},				// 955
	{CSW_XM1014, "weapon_xm1014", "TZ-45", 1, 14, 3.99},					// 455
	{CSW_P90, "weapon_p90", "Ruger MP9", 1, 14, 47.00},			 			// 960
	{CSW_MP5NAVY, "weapon_mp5navy", "Chang Feng", 1, 14, 37.60},			// 965
	{CSW_FAMAS, "weapon_famas", "Beretta MX4", 500, 14, 32.45},				// 970
	{CSW_GALIL, "weapon_galil", "Franchi LF-57", 500, 14, 32.63},			// 975
	{CSW_AUG, "weapon_aug", "Steyr MPi 69", 500, 14, 30.62},			 	// 980
	{CSW_SG552, "weapon_sg552", "Ares FMG", 500, 14, 29.79},				// 985
	{CSW_AK47, "weapon_ak47", "Kriss Super V", 500, 14, 27.29},				// 990
	{CSW_M4A1, "weapon_m4a1", "Colt mod.635", 500, 14, 31.10},				// 995
	
	{CSW_MAC10, "weapon_mac10", "Demro TAC-1", 1, 16, 34.72},				// 1000
	{CSW_TMP, "weapon_tmp", "Degtyarov PDM", 1, 16, 51.90},					// 1005
	{CSW_M3, "weapon_m3", "OTs-02 Kiparis", 1, 16, 3.05},			 		// 538
	{CSW_UMP45, "weapon_ump45", "CS/LS-5", 1, 16, 33.83},					// 1010
	{CSW_XM1014, "weapon_xm1014", "IMP-221", 1, 16, 4.16},					// 475
	{CSW_P90, "weapon_p90", "PPSh-2", 1, 16, 49.75},			 			// 1015
	{CSW_MP5NAVY, "weapon_mp5navy", "STK CPW", 1, 16, 39.80},				// 1020
	{CSW_FAMAS, "weapon_famas", "Korovin 1941", 500, 16, 34.35},			// 1025
	{CSW_GALIL, "weapon_galil", "PPSh-41", 500, 16, 34.52},			 		// 1030
	{CSW_AUG, "weapon_aug", "Steyr TMP", 500, 16, 32.39},			 		// 1035
	{CSW_SG552, "weapon_sg552", "Orita M1941", 500, 16, 31.50},				// 1040
	{CSW_AK47, "weapon_ak47", "AEK-919K Kashtan", 500, 16, 28.86},			// 1045
	{CSW_M4A1, "weapon_m4a1", "Reising M50", 500, 16, 32.88},				// 1050
	
	{CSW_MAC10, "weapon_mac10", "Tikkakoski M/44", 1, 18, 36.68},			// 1055
	{CSW_TMP, "weapon_tmp", "MGV-176", 1, 18, 54.79},					 	// 1060
	{CSW_M3, "weapon_m3", "MGV-176", 1, 18, 3.16},			 				// 558
	{CSW_UMP45, "weapon_ump45", "B&T APC", 1, 18, 35.73},					// 1065
	{CSW_XM1014, "weapon_xm1014", "Suomi M/31", 1, 18, 4.34},				// 495
	{CSW_P90, "weapon_p90", "SAR 109", 1, 18, 52.50},			 			// 1070
	{CSW_MP5NAVY, "weapon_mp5navy", "Carl Gustaf M/45", 1, 18, 51.00},		// 1075
	{CSW_FAMAS, "weapon_famas", "CBJ-MS PDW", 500, 18, 36.25},				// 1080
	{CSW_GALIL, "weapon_galil", "Agram2000", 500, 18, 36.42},				// 1085
	{CSW_AUG, "weapon_aug", "Rexim Favor", 500, 18, 34.17},					// 1090
	{CSW_SG552, "weapon_sg552", "Skorpion vz.61", 500, 18, 33.22},			// 1095
	{CSW_AK47, "weapon_ak47", "Minebea M-9", 500, 18, 30.43},				// 1100
	{CSW_M4A1, "weapon_m4a1", "WF Lmg 41/44", 500, 18, 34.65},				// 1105
	
	{CSW_MAC10, "weapon_mac10", "FN P90", 1, 20, 38.65},					// 1110
	{CSW_TMP, "weapon_tmp", "Ingram M6", 1, 20, 57.69},			 			// 1115
	{CSW_M3, "weapon_m3", "SR-3 Veresk", 1, 20, 3.28},			 			// 578
	{CSW_UMP45, "weapon_ump45", "MP.18,I Schmeisser", 1, 20, 37.63},		// 1120
	{CSW_XM1014, "weapon_xm1014", "Halcon ML-63", 1, 20, 4.51},				// 515
	{CSW_P90, "weapon_p90", "SI-35", 1, 20, 55.25},			 				// 1125
	{CSW_MP5NAVY, "weapon_mp5navy", "Beretta M1918", 1, 20, 44.20},			// 1130
	{CSW_FAMAS, "weapon_famas", "Star RU-35", 500, 20, 38.14},				// 1135
	{CSW_GALIL, "weapon_galil", "HK MP7 PDW", 500, 20, 38.32},				// 1140
	{CSW_AUG, "weapon_aug", "Taurus MT-9", 500, 20, 36.94},					// 1145
	{CSW_SG552, "weapon_sg552", "American-180", 500, 20, 34.94},			// 1150
	{CSW_AK47, "weapon_ak47", "PP19 Vityaz", 500, 20, 32.00},				// 1155
	{CSW_M4A1, "weapon_m4a1", "UD M42", 500, 20, 36.42},			 		// 1160
	
	{CSW_MAC10, "weapon_mac10", "Ingram MAC M10", 1, 22, 40.61},			// 1165
	{CSW_TMP, "weapon_tmp", "Star Z-62", 1, 22, 60.58},			 			// 1170
	{CSW_M3, "weapon_m3", " SCK-65", 1, 22, 3.39},			 				// 598
	{CSW_UMP45, "weapon_ump45", "STA M 1922", 1, 22, 39.52},				// 1175
	{CSW_XM1014, "weapon_xm1014", "Thompson", 1, 22, 4.69},					// 535
	{CSW_P90, "weapon_p90", "K6-92 / Borz", 1, 22, 58.00},					// 1180
	{CSW_MP5NAVY, "weapon_mp5navy", "Nambu 1966", 1, 22, 46.40},			// 1185
	{CSW_FAMAS, "weapon_famas", "CZ Vz. 38", 500, 22, 40.04},				// 1190
	{CSW_GALIL, "weapon_galil", "Skorpion EVO III", 500, 22, 40.21},		// 1195
	{CSW_AUG, "weapon_aug", "SIG-Sauer MPX", 500, 22, 37.71},				// 1200
	{CSW_SG552, "weapon_sg552", "FBP m/948", 500, 22, 36.66},				// 1205
	{CSW_AK47, "weapon_ak47", "PP-19 Bizon", 500, 22, 33.58},				// 1210
	{CSW_M4A1, "weapon_m4a1", "MP.41 Schmeisser", 500, 22, 38.20}			// 1215
};

new const SECONDARY_WEAPONS[][structWeapons] =
{
	{CSW_GLOCK18, "weapon_glock18", "Glock 18C", 1, 0, 1.0},
	{CSW_FIVESEVEN, "weapon_fiveseven", "FiveseveN", 1, 0, 1.5},
	{CSW_USP, "weapon_usp", "USP .45 ACP Tactical", 1, 0, 1.0},
	{CSW_P228, "weapon_p228", "P228 Compact", 1, 0, 1.2},
	{CSW_ELITE, "weapon_elite", "Dual Elite Berettas", 1, 0, 1.2},
	{CSW_DEAGLE, "weapon_deagle", "Desert Eagle .50 AE", 1, 0, 1.0},

	{CSW_GLOCK18, "weapon_glock18", "FN Browning M1900", 1, 1, 2.96},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Steyr GB", 1, 1, 3.64},
	{CSW_USP, "weapon_usp", "Bergmann Bayard M1910", 1, 1, 2.75},
	{CSW_P228, "weapon_p228", "Bersa Thunder", 1, 1, 2.99},
	{CSW_ELITE, "weapon_elite", "Roth Steyr M1907", 1, 1, 2.75},
	{CSW_DEAGLE, "weapon_deagle", "Arcus 94 & 98DA", 1, 1, 2.32},

	{CSW_GLOCK18, "weapon_glock18", "FN Browning M1900", 1, 2, 3.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Steyr GB", 1, 2, 4.37},
	{CSW_USP, "weapon_usp", "Bergmann Bayard M1910", 1, 2, 3.13},
	{CSW_P228, "weapon_p228", "Bersa Thunder", 1, 2, 3.46},
	{CSW_ELITE, "weapon_elite", "Roth Steyr M1907", 1, 2, 3.35},
	{CSW_DEAGLE, "weapon_deagle", "Arcus 94 & 98DA", 1, 2, 2.70},
	
	{CSW_GLOCK18, "weapon_glock18", "FEG AP-63 PA-63", 1, 3, 4.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Webley Scott", 1, 3, 6.27},
	{CSW_USP, "weapon_usp", "Frommer Stop", 1, 3, 4.22},
	{CSW_P228, "weapon_p228", "Taurus PT92", 1, 3, 4.62},
	{CSW_ELITE, "weapon_elite", "Arsenal P-M02", 1, 3, 4.38},
	{CSW_DEAGLE, "weapon_deagle", "Bergmann Mars", 1, 3, 4.39},
	
	{CSW_GLOCK18, "weapon_glock18", "FN Forty-Nine", 1, 4, 6.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Steyr Hahn M1912", 1, 4, 8.16},
	{CSW_USP, "weapon_usp", "FN Browning HP", 1, 4, 5.31},
	{CSW_P228, "weapon_p228", "Ballester-Molina", 1, 4, 5.78},
	{CSW_ELITE, "weapon_elite", "Bersa Thunder 380", 1, 4, 5.41},
	{CSW_DEAGLE, "weapon_deagle", "FN FNP-45", 1, 4, 4.08},
	
	{CSW_GLOCK18, "weapon_glock18", "Luger 'Parabellum'", 1, 5, 7.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "FEMARU 29M", 1, 5, 10.06},
	{CSW_USP, "weapon_usp", "FEG P9M", 1, 5, 6.40},
	{CSW_P228, "weapon_p228", "Taurus 24/7", 1, 5, 6.94},
	{CSW_ELITE, "weapon_elite", "Welrod silent", 1, 5, 6.43},
	{CSW_DEAGLE, "weapon_deagle", "Mauser C-96", 1, 5, 4.77},
	
	{CSW_GLOCK18, "weapon_glock18", "HK VP9", 1, 6, 9.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Walther P38", 1, 6, 11.95},
	{CSW_USP, "weapon_usp", "Korth", 1, 6, 7.49},
	{CSW_P228, "weapon_p228", "HK VP 70", 1, 6, 8.10},
	{CSW_ELITE, "weapon_elite", "Sauer 38H", 1, 6, 7.46},
	{CSW_DEAGLE, "weapon_deagle", "Jericho 941", 1, 6, 5.47},
	
	{CSW_GLOCK18, "weapon_glock18", "Astra A-80", 1, 7, 10.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Viper JAWS", 1, 7, 13.85},
	{CSW_USP, "weapon_usp", "UZI pistol", 1, 7, 8.58},
	{CSW_P228, "weapon_p228", "Barak SP-21", 1, 7, 9.26},
	{CSW_ELITE, "weapon_elite", "Bul M5", 1, 7, 8.49},
	{CSW_DEAGLE, "weapon_deagle", "Llama M-82", 1, 7, 6.16},
	
	{CSW_GLOCK18, "weapon_glock18", "Tanfoglio T95", 1, 8, 12.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Benelli B76", 1, 8, 15.74},
	{CSW_USP, "weapon_usp", "Bernardelli P-018", 1, 8, 9.67},
	{CSW_P228, "weapon_p228", "Bul Cherokee", 1, 8, 10.42},
	{CSW_ELITE, "weapon_elite", "Star 30M", 1, 8, 9.52},
	{CSW_DEAGLE, "weapon_deagle", "Para-Ordnance P14-45", 1, 8, 6.85},
	
	{CSW_GLOCK18, "weapon_glock18", "VIS wz.35", 1, 9, 13.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "QSZ-92", 1, 9, 17.64},
	{CSW_USP, "weapon_usp", "Obregon", 1, 9, 10.76},
	{CSW_P228, "weapon_p228", "Type 77", 1, 9, 11.59},
	{CSW_ELITE, "weapon_elite", "Model 77B", 1, 9, 10.55},
	{CSW_DEAGLE, "weapon_deagle", "P-64", 1, 9, 7.54},
	
	{CSW_GLOCK18, "weapon_glock18", "Stechkin APS", 1, 10, 15.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Tokarev TT", 1, 10, 19.53},
	{CSW_USP, "weapon_usp", "Makarov PM", 1, 10, 11.85},
	{CSW_P228, "weapon_p228", "Wist-94", 1, 10, 12.75},
	{CSW_ELITE, "weapon_elite", "Korovin TK", 1, 10, 11.58},
	{CSW_DEAGLE, "weapon_deagle", "PSM", 1, 10, 8.24},
	
	{CSW_GLOCK18, "weapon_glock18", "MP-446", 1, 11, 16.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "OTs-23", 1, 11, 21.43},
	{CSW_USP, "weapon_usp", "SPP-1 underwater", 1, 11, 12.94},
	{CSW_P228, "weapon_p228", "APB silenced", 1, 11, 13.91},
	{CSW_ELITE, "weapon_elite", "GSh-18", 1, 11, 12.61},
	{CSW_DEAGLE, "weapon_deagle", "OTs-21", 1, 11, 8.93},
	
	{CSW_GLOCK18, "weapon_glock18", "K-100", 1, 12, 18.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "CZ-999", 1, 12, 23.32},
	{CSW_USP, "weapon_usp", "ASP", 1, 12, 14.04},
	{CSW_P228, "weapon_p228", "Strike One", 1, 12, 15.07},
	{CSW_ELITE, "weapon_elite", "M57", 1, 12, 13.63},
	{CSW_DEAGLE, "weapon_deagle", "FN Browning BDM", 1, 12, 9.62},
	
	{CSW_GLOCK18, "weapon_glock18", "Kahr K9", 1, 13, 19.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "S&W Sigma", 1, 13, 25.22},
	{CSW_USP, "weapon_usp", "Ruger SR9", 1, 13, 15.13},
	{CSW_P228, "weapon_p228", "Gyrojet", 1, 13, 16.23},
	{CSW_ELITE, "weapon_elite", "Colt Gov't / M1911", 1, 13, 14.66},
	{CSW_DEAGLE, "weapon_deagle", "Bren Ten", 1, 13, 10.31},
	
	{CSW_GLOCK18, "weapon_glock18", "LAR Grizzly", 1, 14, 21.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "AMP Auto Mag", 1, 14, 27.11},
	{CSW_USP, "weapon_usp", "Coonan", 1, 14, 16.22},
	{CSW_P228, "weapon_p228", "Goncz GA-9", 1, 14, 17.39},
	{CSW_ELITE, "weapon_elite", "Intratec DC-9", 1, 14, 15.69},
	{CSW_DEAGLE, "weapon_deagle", "Kel-tec P-11", 1, 14, 11.01},
	
	{CSW_GLOCK18, "weapon_glock18", "Yavuz 16", 1, 15, 22.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "MPA Defender", 1, 15, 29.01},
	{CSW_USP, "weapon_usp", "Ruger SR9", 1, 15, 17.31},
	{CSW_P228, "weapon_p228", "Boberg XR-9", 1, 15, 18.55},
	{CSW_ELITE, "weapon_elite", "FN FNP-45", 1, 15, 16.72},
	{CSW_DEAGLE, "weapon_deagle", "Akdal Ghost", 1, 15, 11.70},
	
	{CSW_GLOCK18, "weapon_glock18", "Mle. 1950", 1, 16, 24.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Shevchenko PSh", 1, 16, 30.90},
	{CSW_USP, "weapon_usp", "Lahti L-35", 1, 16, 18.40},
	{CSW_P228, "weapon_p228", "Sarsilmaz K2-45", 1, 16, 19.71},
	{CSW_ELITE, "weapon_elite", "Fort 12", 1, 16, 17.75},
	{CSW_DEAGLE, "weapon_deagle", "MAB PA-15", 1, 16, 12.39},
	
	{CSW_GLOCK18, "weapon_glock18", "B+T VP-9", 1, 17, 25.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "SIG-Sauer P220", 1, 17, 32.79},
	{CSW_USP, "weapon_usp", "Sphinx 2000", 1, 17, 19.49},
	{CSW_P228, "weapon_p228", "IM Metal HS 2000", 1, 17, 20.88},
	{CSW_ELITE, "weapon_elite", "CZ-G 2000", 1, 17, 18.78},
	{CSW_DEAGLE, "weapon_deagle", "Husqvarna M/40", 1, 17, 13.08},
	
	{CSW_GLOCK18, "weapon_glock18", "Caracal", 1, 18, 27.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Daewoo DP-51", 1, 18, 34.69},
	{CSW_USP, "weapon_usp", "Nambu Type 14", 1, 18, 20.58},
	{CSW_P228, "weapon_p228", "Vektor CP1", 1, 18, 22.04},
	{CSW_ELITE, "weapon_elite", "ADP", 1, 18, 19.80},
	{CSW_DEAGLE, "weapon_deagle", "Tara TM9", 1, 18, 13.77},
	
	{CSW_GLOCK18, "weapon_glock18", "Webley-Fosbery", 1, 19, 28.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Webley", 1, 19, 36.58},
	{CSW_USP, "weapon_usp", "Enfield Mk 1", 1, 19, 21.67},
	{CSW_P228, "weapon_p228", "Nagant mle.1895", 1, 19, 23.20},
	{CSW_ELITE, "weapon_elite", "FN Barracuda", 1, 19, 20.83},
	{CSW_DEAGLE, "weapon_deagle", "FN Browning BDM", 1, 19, 14.47},
	
	{CSW_GLOCK18, "weapon_glock18", "Mauser HSc", 1, 20, 30.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "FEMARU 29M", 1, 20, 38.48},
	{CSW_USP, "weapon_usp", "FEG P9R", 1, 20, 22.76},
	{CSW_P228, "weapon_p228", "FN FNP-9 / PRO-9", 1, 20, 24.36},
	{CSW_ELITE, "weapon_elite", "Taurus PT111", 1, 20, 21.86},
	{CSW_DEAGLE, "weapon_deagle", "HK-4", 1, 20, 15.16},
	
	{CSW_GLOCK18, "weapon_glock18", "Walther P88", 1, 21, 31.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Astra mod. 400 & 600", 1, 21, 40.37},
	{CSW_USP, "weapon_usp", "Star Ultrastar", 1, 21, 23.85},
	{CSW_P228, "weapon_p228", "HK P11 underwater", 1, 21, 25.52},
	{CSW_ELITE, "weapon_elite", "Beretta 93R", 1, 21, 22.89},
	{CSW_DEAGLE, "weapon_deagle", "Tanfoglio Force", 1, 21, 15.85},
	
	{CSW_GLOCK18, "weapon_glock18", "OTs-27", 1, 22, 33.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "PB silenced", 1, 22, 42.27},
	{CSW_USP, "weapon_usp", "PSS silent", 1, 22, 24.94},
	{CSW_P228, "weapon_p228", "Type 80", 1, 22, 26.68},
	{CSW_ELITE, "weapon_elite", "P-83", 1, 22, 23.92},
	{CSW_DEAGLE, "weapon_deagle", "MP-448", 1, 22, 16.54},
	
	{CSW_GLOCK18, "weapon_glock18", "Ruger P-series", 1, 23, 34.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Colt SSP", 1, 23, 44.16},
	{CSW_USP, "weapon_usp", "S&W 39", 1, 23, 26.04},
	{CSW_P228, "weapon_p228", "M70", 1, 23, 27.84},
	{CSW_ELITE, "weapon_elite", "CZ-99", 1, 23, 24.95},
	{CSW_DEAGLE, "weapon_deagle", "Wildey", 1, 23, 17.24},
	
	{CSW_GLOCK18, "weapon_glock18", "Mle. 1935A", 1, 24, 36.42},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Sarsilmaz Kilinc 2000", 1, 24, 46.06},
	{CSW_USP, "weapon_usp", "Fort 14", 1, 24, 27.13},
	{CSW_P228, "weapon_p228", "AMT Automag II-V", 1, 24, 29.01},
	{CSW_ELITE, "weapon_elite", "Kel-tec PF-9", 1, 24, 25.98},
	{CSW_DEAGLE, "weapon_deagle", "Colt Double Eagle", 1, 24, 17.93},
	
	{CSW_GLOCK18, "weapon_glock18", "Nambu Type 94", 1, 25, 37.92},
	{CSW_FIVESEVEN, "weapon_fiveseven", "Vektor SP1 & SP2", 1, 25, 47.95},
	{CSW_USP, "weapon_usp", "Colt 1873 SAA", 1, 25, 28.22},
	{CSW_P228, "weapon_p228", "CZ 110", 1, 25, 30.17},
	{CSW_ELITE, "weapon_elite", "Sphinx 3000", 1, 25, 27.01},
	{CSW_DEAGLE, "weapon_deagle", "Mle. 1935A", 1, 25, 18.62}
};

new const WEAPON_DATA[][structWeaponDatas] =
{
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

new const Float:WEAPON_DAMAGE_NEED[31][] =
{
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 2100000000.0}, // P228
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 2100000000.0}, // XM1014
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 2100000000.0}, // MAC10
	{5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 2100000000.0}, // AUG
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 2100000000.0}, // ELITE
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 2100000000.0}, // FIVESEVEN
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 2100000000.0}, // UMP45
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}, // SG550
	{5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 2100000000.0}, // GALIL
	{5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 2100000000.0}, // FAMAS
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 2100000000.0}, // USP
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 2100000000.0}, // GLOCK18
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 2100000000.0}, // MP5NAVY
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}, // M249
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 2100000000.0}, // M3
	{5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 2100000000.0}, // M4A1
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 2100000000.0}, // TMP
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 2100000000.0}, // DEAGLE
	{5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 2100000000.0}, // SG552
	{5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 25000000.0, 2100000000.0}, // AK47
	{500.0, 1000.0, 2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 2100000000.0}, // CUCHILLO
	{2500.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0, 250000.0, 500000.0, 750000.0, 1000000.0, 1500000.0, 2000000.0, 2500000.0, 3500000.0, 4500000.0, 5000000.0, 7500000.0, 10000000.0, 15000000.0, 20000000.0, 2100000000.0} // P90
};

new const WEAPON_MODELS[][][structWeaponModels] =
{
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}},
	{{5, "models/dg/zp6/v_p228_02.mdl"}, {10, "models/dg/zp6/v_p228_00.mdl"}, {15, "models/dg/zp6/v_p228_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // P228
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SHIELD
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SCOUT
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // HEGRENADE
	{{4, "models/dg/zp6/v_xm1014_02.mdl"}, {8, "models/dg/zp6/v_xm1014_01.mdl"}, {12, "models/dg/zp6/v_xm1014_03.mdl"}, {16, "models/dg/zp6/v_xm1014_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // XM1014
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // C4
	{{5, "models/dg/zp6/v_mac10_00.mdl"}, {10, "models/dg/zp6/v_mac10_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // MAC10
	{{2, "models/dg/zp6/v_aug_04.mdl"}, {4, "models/dg/zp6/v_aug_01.mdl"}, {6, "models/dg/zp6/v_aug_03.mdl"}, {8, "models/dg/zp6/v_aug_02.mdl"}, {12, "models/dg/zp6/v_aug_05.mdl"}, {14, "models/dg/zp6/v_aug_00.mdl"}, {99, ""}, {99, ""}, {99, ""}}, // AUG
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SMOKEGRENADE
	{{4, "models/dg/zp6/v_elite_01.mdl"}, {8, "models/dg/zp6/v_elite_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // ELITE
	{{4, "models/dg/zp6/v_fiveseven_02.mdl"}, {8, "models/dg/zp6/v_fiveseven_01.mdl"}, {12, "models/dg/zp6/v_fiveseven_03.mdl"}, {16, "models/dg/zp6/v_fiveseven_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // FIVESEVEN
	{{5, "models/dg/zp6/v_ump45_01.mdl"}, {10, "models/dg/zp6/v_ump45_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // UMP45
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, //  SG550
	{{4, "models/dg/zp6/v_galil_00.mdl"}, {6, "models/dg/zp6/v_galil_02.mdl"}, {12, "models/dg/zp6/v_galil_03.mdl"}, {16, "models/dg/zp6/v_galil_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // GALIL
	{{4, "models/dg/zp6/v_famas_02.mdl"}, {6, "models/dg/zp6/v_famas_01.mdl"}, {12, "models/dg/zp6/v_famas_00.mdl"}, {16, "models/dg/zp6/v_famas_03.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // FAMAS
	{{5, "models/dg/zp6/v_usp_01.mdl"}, {10, "models/dg/zp6/v_usp_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // USP
	{{4, "models/dg/zp6/v_glock18_00.mdl"}, {8, "models/dg/zp6/v_glock18_03.mdl"}, {12, "models/dg/zp6/v_glock18_01.mdl"}, {16, "models/dg/zp6/v_glock18_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // GLOCK18
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}},  // AWP
	{{5, "models/dg/zp6/v_mp5_01.mdl"}, {5, "models/dg/zp6/v_mp5_00.mdl"}, {10, "models/dg/zp6/v_mp5_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // MP5NAVY
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // M249
	{{5, "models/dg/zp6/v_m3_01.mdl"}, {10, "models/dg/zp6/v_m3_00.mdl"}, {15, "models/dg/zp6/v_m3_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // M3
	{{3, "models/dg/zp6/v_m4a1_00.mdl"}, {6, "models/dg/zp6/v_m4a1_03.mdl"}, {9, "models/dg/zp6/v_m4a1_01.mdl"}, {12, "models/dg/zp6/v_m4a1_04.mdl"}, {15, "models/dg/zp6/v_m4a1_02.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // M4A1
	{{5, "models/dg/zp6/v_tmp_01.mdl"}, {10, "models/dg/zp6/v_tmp_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // TMP
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // G3SG1
	{{99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // FLASHBANG
	{{4, "models/dg/zp6/v_deagle_01.mdl"}, {8, "models/dg/zp6/v_deagle_02.mdl"}, {12, "models/dg/zp6/v_deagle_00.mdl"}, {16, "models/dg/zp6/v_deagle_03.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // DEAGLE
	{{5, "models/dg/zp6/v_sg552_00.mdl"}, {10, "models/dg/zp6/v_sg552_02.mdl"}, {15, "models/dg/zp6/v_sg552_01.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // SG552
	{{3, "models/dg/zp6/v_ak47_00.mdl"}, {6, "models/dg/zp6/v_ak47_03.mdl"}, {9, "models/dg/zp6/v_ak47_01.mdl"}, {12, "models/dg/zp6/v_ak47_02.mdl"}, {15, "models/dg/zp6/v_ak47_04.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}}, // AK47
	{{2, "models/dg/zp6/v_knife_00.mdl"}, {4, "models/dg/zp6/v_knife_02.mdl"}, {6, "models/dg/zp6/v_knife_03.mdl"}, {8, "models/dg/zp6/v_knife_04.mdl"}, {10, "models/dg/zp6/v_knife_05.mdl"}, {12, "models/dg/zp6/v_knife_06.mdl"}, {14, "models/dg/zp6/v_knife_07.mdl"}, {16, "models/dg/zp6/v_knife_08.mdl"}, {18, "models/dg/zp6/v_knife_08.mdl"}}, // CUCHILLO
	{{5, "models/dg/zp6/v_p90_00.mdl"}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}, {99, ""}} // P90
};

new const WEAPONS_DIAMMONDS_NEED[31][] =
{
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // P228
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // XM1014
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // MAC10
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // AUG
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // ELITE
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // FIVESEVEN
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // UMP45
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // GALIL
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // FAMAS
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // USP
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // GLOCK18
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // MP5NAVY
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, // M249
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // M3
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // M4A1
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // TMP
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // DEAGLE
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // SG552
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // AK47
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999}, // CUCHILLO
	{1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 999999} // P90
};

new const EXTRA_ITEMS[structIdExtraItems][structExtraItems] =
{
	{"Visión nocturna", "", 15, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Invisibilidad", "", 50, 5, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Balas Infinitas", "", 75, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Precisión Perfecta", "", 75, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Bomba Aniquiladora", "", 100, 1, 3, EXTRA_ITEM_TEAM_HUMAN},
	{"Bomba Molotov", "", 100, 1, 3, EXTRA_ITEM_TEAM_HUMAN},
	{"Bomba Antídoto", "", 100, 1, 3, EXTRA_ITEM_TEAM_HUMAN},

	{"Antídoto", "", 30, 3, 0, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Furia Zombie", "", 40, 3, 12, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Bomba de Infección", "", 50, 1, 3, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Reducción de daño", "", 75, 3, 12, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Painshock", "(5 segundos)", 100, 3, 12, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Petrificación", "", 75, 3, 12, EXTRA_ITEM_TEAM_ZOMBIE}
};

new const MODEL_CLASSES_CYCLES[][] = {'D', 'C', 'B', 'A'};

/*
	SEGUNDO CICLO:
		>>> CICLO D (0): Z ; Y ; X ; W ; V ; U
		>>> CICLO C (1): T ; S ; R ; Q ; P ; O ; N

	PRIMER CICLO
		>>> CICLO B (2): M ; L ; K ; J ; I ; H
		>>> CICLO A (3): G ; F ; E ; D ; C ; B ; A
*/

new const MODELS[][structModels] =
{
	{"Civil", "dg-zp_human_24", MODEL_HUMAN, 0},
	{"Soldier", "dg-zp_human_11a", MODEL_HUMAN, 0},
	{"Cabo", "dg-zp_human_19", MODEL_HUMAN, 0},
	{"Major General", "dg-zp_human_20", MODEL_HUMAN, 0},
	{"Mercenary", "dg-zp_human_03", MODEL_HUMAN, 0},
	{"Back-packer", "dg-zp_human_04", MODEL_HUMAN, 0},
	{"[FEM] Lexie", "dg-zp_human_08", MODEL_HUMAN, 1},
	{"Arantir", "dg-zp_human_00", MODEL_HUMAN, 1},
	{"[FEM] Maid", "dg-zp_human_05", MODEL_HUMAN, 1},
	{"Gentleman", "dg-zp_human_14", MODEL_HUMAN, 1},
	{"[FEM] Cat Girl", "dg-zp_human_16", MODEL_HUMAN, 1},
	{"Sherman", "dg-zp_human_18", MODEL_HUMAN, 1},
	{"[FEM] Lien", "dg-zp_human_09", MODEL_HUMAN, 1},
	{"Resident", "dg-zp_human_25", MODEL_HUMAN, 2},
	{"[FEM] Miscellaneous", "dg-zp_human_07", MODEL_HUMAN, 2},
	{"Not Krauser", "dg-zp_human_13", MODEL_HUMAN, 2},
	{"[FEM] Babygirl", "dg-zp_human_02", MODEL_HUMAN, 2},
	{"Demons Leon", "dg-zp_human_06", MODEL_HUMAN, 2},
	{"[FEM] Dyana", "dg-zp_human_01", MODEL_HUMAN, 2},
	{"[FEM] Lee", "dg-zp_human_23", MODEL_HUMAN, 3},
	{"Tabby Guy", "dg-zp_human_21", MODEL_HUMAN, 3},
	{"[FEM] Dorothy", "dg-zp_human_10", MODEL_HUMAN, 3},
	{"Zodiac Knight", "dg-zp_human_15", MODEL_HUMAN, 3},
	{"[FEM] Flora", "dg-zp_human_17", MODEL_HUMAN, 3},
	{"Demons Masc", "dg-zp_human_22", MODEL_HUMAN, 3},
	{"[FEM] Lisa", "dg-zp_human_12", MODEL_HUMAN, 3},

	{"Raptor", "dg-zp_zombie_25", MODEL_ZOMBIE, 0},
	{"Shug-im", "dg-zp_zombie_01", MODEL_ZOMBIE, 0},
	{"Rawtol", "dg-zp_zombie_14", MODEL_ZOMBIE, 0},
	{"Starving", "dg-zp_zombie_16", MODEL_ZOMBIE, 0},
	{"Rotten", "dg-zp_zombie_05", MODEL_ZOMBIE, 0},
	{"[FEM] Jessica", "dg-zp_zombie_04", MODEL_ZOMBIE, 0},
	{"Black Majini", "dg-zp_zombie_03", MODEL_ZOMBIE, 1},
	{"[FEM] Naked", "dg-zp_zombie_02", MODEL_ZOMBIE, 1},
	{"Heal", "dg-zp_zombie_09", MODEL_ZOMBIE, 1},
	{"[FEM] Scratcher", "dg-zp_zombie_08", MODEL_ZOMBIE, 1},
	{"Bubonero", "dg-zp_zombie_20", MODEL_ZOMBIE, 1},
	{"[FEM] Toxic Zombie", "dg-zp_zombie_12", MODEL_ZOMBIE, 1},
	{"Umbrella's zombie", "dg-zp_zombie_15", MODEL_ZOMBIE, 1},
	{"[FEM] Girly", "dg-zp_zombie_07", MODEL_ZOMBIE, 2},
	{"White mask", "dg-zp_zombie_06", MODEL_ZOMBIE, 2},
	{"[FEM] Maiden", "dg-zp_zombie_10", MODEL_ZOMBIE, 2},
	{"Scarecrow", "dg-zp_zombie_13", MODEL_ZOMBIE, 2},
	{"Arctic", "dg-zp_zombie_21", MODEL_ZOMBIE, 2},
	{"Handyman", "dg-zp_zombie_17", MODEL_ZOMBIE, 2},
	{"Scrake zombie", "dg-zp_zombie_00", MODEL_ZOMBIE, 3},
	{"Zystud", "dg-zp_zombie_23", MODEL_ZOMBIE, 3},
	{"Tirant", "dg-zp_zombie_11", MODEL_ZOMBIE, 3},
	{"Ogre", "dg-zp_zombie_19", MODEL_ZOMBIE, 3},
	{"Screamer", "dg-zp_zombie_22", MODEL_ZOMBIE, 3},
	{"Scratcher", "dg-zp_zombie_18", MODEL_ZOMBIE, 3},
	{"Fitsum", "dg-zp_zombie_24", MODEL_ZOMBIE, 3}
};

new const DIFFICULTS_CLASSES[structIdDifficultsClasses][] = {"SURVIVOR", "WESKER", "SNIPER ELITE", "NEMESIS", "ASSASSIN", "ANIQUILADOR"};

new const DIFFICULTS[structIdDifficultsClasses][structIdDifficults][structDifficults] =
{
	// Survivor
	{
		{"Normal", "Estadísticas normales", 1.0, 1.0},
		{"Difícil", "Vida: \r-25%\w | Velocidad: \r-10%\w", 0.75, 0.9},
		{"Muy Difícil", "Vida: \r-50%\w | Velocidad: \r-25%\w | Sin bomba de aniquilación", 0.5, 0.75}
	},
	// Wesker
	{
		{"Normal", "Estadísticas normales", 1.0, 1.0},
		{"Difícil", "Vida: \r-15%\w | Velocidad: \r-20%\w", 0.85, 0.8},
		{"Muy Difícil", "Vida: \r-30%\w | Velocidad: \r-40%\w | Sin lasers", 0.7, 0.6}
	},
	// Sniper Elite
	{
		{"Normal", "Estadísticas normales", 1.0, 1.0},
		{"Difícil", "Vida: \r-20%\w | Velocidad: \r-15%\w", 0.8, 0.85},
		{"Muy Difícil", "Vida: \r-40%\w | Velocidad: \r-30%\w | Sin velocidad de disparo", 0.6, 0.7}
	},
	// Nemesis
	{
		{"Normal", "Estadísticas normales", 1.0, 1.0},
		{"Difícil", "Vida: \r-25%\w | Velocidad: \r-10%\w", 0.75, 0.9},
		{"Muy Difícil", "Vida: \r-50%\w | Velocidad: \r-25%\w | Sin Long Jump", 0.5, 0.75}
	},
	// Assassin
	{
		{"Normal", "Estadísticas normales", 1.0, 1.0},
		{"Difícil", "Vida: \r-15%\w | Velocidad: \r-20%\w", 0.85, 0.8},
		{"Muy Difícil", "Vida: \r-30%\w | Velocidad: \r-40%\w | Sin visión especial", 0.7, 0.6}
	},
	// Aniquilador
	{
		{"Normal", "Estadísticas normales", 1.0, 1.0},
		{"Difícil", "Vida: \r-20%\w | Velocidad: \r-15%\w", 0.8, 0.85},
		{"Muy Difícil", "Vida: \r-40%\w | Velocidad: \r-30%\w | Solo tiene 2 bazookas", 0.6, 0.7}
	}
};

new const HABS_CLASSES[structIdHabsClasses][structHabsClasses] =
{
	{"Humanas", "Puntos humanos", "pH", POINT_HUMAN},
	{"Zombies", "Puntos zombies", "pZ", POINT_ZOMBIE},
	{"Survivor", "Puntos de Legado", "pL", POINT_LEGACY},
	{"Wesker", "Puntos de Legado", "pL", POINT_LEGACY},
	{"Sniper Elite", "Puntos de Legado", "pL", POINT_LEGACY},
	{"Jason", "Puntos de Legado", "pL", POINT_LEGACY},
	{"Nemesis", "Puntos de Legado", "pL", POINT_LEGACY},
	{"Especiales", "Puntos especiales", "pE", POINT_SPECIAL},
	{"Legendarias", "Diamantes", "DIAMANTES", POINT_DIAMMONDS}
};

new const HABS[structIdHabs][structHabs] =
{
	{"Vida", "", 10, 6, 50, HAB_CLASS_HUMAN},
	{"Velocidad", "", 1, 6, 30, HAB_CLASS_HUMAN},
	{"Gravedad", "", 1, 6, 30, HAB_CLASS_HUMAN},
	{"Daño", "", 150, 6, 100, HAB_CLASS_HUMAN},
	{"Chaleco", "", 10, 6, 20, HAB_CLASS_HUMAN},

	{"Vida", "", 100000, 6, 100, HAB_CLASS_ZOMBIE},
	{"Velocidad", "", 1, 6, 30, HAB_CLASS_ZOMBIE},
	{"Gravedad", "", 1, 6, 30, HAB_CLASS_ZOMBIE},
	{"Daño", "", 10, 6, 50, HAB_CLASS_ZOMBIE},
	{"Inducción", "Cada infección da una probabilidad de que el zombie^nobtenga una furia gratis", 1, 12, 10, HAB_CLASS_ZOMBIE},
	{"Combo Zombie", "Habilita el combo zombie", 0, 150, 1, HAB_CLASS_ZOMBIE},

	{"Estadísticas base", "Aumenta tu vida, velocidad y gravedad del survivor", 0, 12, 10, HAB_CLASS_L_SURVIVOR},
	{"Daño ", "Aumenta el daño general del Survivor", 4000, 18, 10, HAB_CLASS_L_SURVIVOR},
	{"Arma", "\r - \wNivel 0\r:\y MP5 Navy^n\r - \wNivel 1\r:\y XM1014 M4^n\r - \wNivel 2\r:\y M4A1 Carbine", 0, 24, 2, HAB_CLASS_L_SURVIVOR},

	{"Ultra Laser", "Tener el ultra laser activado hará que al utilizarlo^nmate todo aquel que lo toque", 0, 75, 1, HAB_CLASS_L_WESKER},
	{"Combo", "", 0, 75, 1, HAB_CLASS_L_WESKER},

	{"Duración de poder (+5 Seg)", "Aumenta la duración del poder del Sniper Elite", 5, 50, 1, HAB_CLASS_L_SNIPER_ELITE},

	{"Teletransportación", "Otorgas un poder para teletransportarte a un respawn", 0, 50, 1, HAB_CLASS_L_JASON},
	{"Daño", "Duplica tu daño con la motosierra", 0, 75, 1, HAB_CLASS_L_JASON},
	{"Combo", "", 0, 75, 1, HAB_CLASS_L_JASON},

	{"Estadísticas base", "Aumenta tu vida, velocidad y gravedad del nemesis", 0, 12, 10, HAB_CLASS_L_NEMESIS},
	{"Daño", "", 50, 18, 10, HAB_CLASS_L_NEMESIS},
	{"Radio de bazooka", "Aumenta la magnitud de explosión al lanzar tu bazooka^nprovocando mayores muertes en alrededores", 250, 75, 1, HAB_CLASS_L_NEMESIS},
	{"Bazooka extra", "", 1, 75, 1, HAB_CLASS_L_NEMESIS},

	{"Granada [HE]", "\r - \wNivel 1\r:\y Nitrógeno^n\r - \wNivel 2\r:\y Droga", 0, 150, 2, HAB_CLASS_SPECIAL},
	{"Granada [FB]", "\r - \wNivel 1\r:\y Supernova^n\r - \wNivel 2\r:\y Hypernova", 0, 150, 2, HAB_CLASS_SPECIAL},
	{"Granada [SG]", "\r - \wNivel 1\r:\y Inmunidad^n\r - \wNivel 2\r:\y Bubble", 0, 150, 2, HAB_CLASS_SPECIAL},
	{"Duración de Bubble (+2 Seg)", "Aumenta la duración de tu granada Bubble", 10, 100, 5, HAB_CLASS_SPECIAL},
	{"Furia Prolongada", "Aumenta la duración de tu furia zombie", 1, 75, 4, HAB_CLASS_SPECIAL},

	{"Duración de Combo (+0.5 Seg)", "Aumenta la duración entre comenzar y terminar el combo^nTanto humana como zombie", 1, 5, 5, HAB_CLASS_DIAMMONDS},
	{"+1 punto de legado", "Aumenta el multiplicador de puntos de legado \d(pL)\w^nCada vez que ganes pL, será el doble del común", 1, 10, 5, HAB_CLASS_DIAMMONDS},
	
	{"Reiniciar costo de Items Extras", "El costo de tus Items extras vuelven a su valor default^nAl volver a gastar, \yno dependerá de tu nivel\w.", 0, 2, 999, HAB_CLASS_DIAMMONDS},
	{"Vigor", "Por cada nivel de habilidad aumenta un 1% los primeros 5 niveles^ny 2% los últimos niveles", 2, 5, 10, HAB_CLASS_DIAMMONDS},
	{"Todas las armas al nivel 10", "Sube todas tus armas al nivel 10", 0, 200, 1, HAB_CLASS_DIAMMONDS},
	
	{"Resistencia al fuego", "\r - \yNivel 1\r:\w Las bombas incendiarias te quita menos vida^n\r - \yNivel 2\r:\w La reducción de velocidad de movimiento se reduce^n\r - \yNivel 3\r:\w No te incendias al tocar un Zombie que esté en llamas", 0, 24, 3, HAB_CLASS_ZOMBIE},
	{"Resistencia al hielo", "\r - \yNivel 1\r:\w La reducción de velocidad de movimiento se reduce^n\r - \yNivel 2\r:\w Menos tiempo de congelación^n\r - \yNivel 3\r:\w Las bombas incendiarias no te afectan cuando estés congelado", 0, 24, 3, HAB_CLASS_ZOMBIE}
};

new const ACHIEVEMENTS_CLASSES[structIdAchievementClasses][] =  {
	"Humanos", "Zombies", "Modos", "Otros", "Primeros", "Armas", "Secretos", "Items Extras", "EVENTO: Amor en el aire"
};

new const ACHIEVEMENTS[structIdAchievements][structAchievements] = {
	{"PERSONAJE PAR", "Tu numero de personaje es par", 2, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"PERSONAJE IMPAR", "Tu numero de personaje es impar", 2, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"SURVIVOR PRINCIPIANTE", "Gana el modo SURVIVOR en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"SURVIVOR AVANZADO", "Gana el modo SURVIVOR en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"SURVIVOR EXPERTO", "Gana el modo SURVIVOR en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"SURVIVOR PRO", "Gana el modo SURVIVOR en dificultad MUY DIFÍCIL con +75% de Vida intacta", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"WESKER PRINCIPIANTE", "Gana el modo WESKER en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"WESKER AVANZADO", "Gana el modo WESKER en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"WESKER EXPERTO", "Gana el modo WESKER en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"WESKER PRO", "Gana el modo WESKER en dificultad MUY DIFÍCIL con +75% de Vida intacta", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"SNIPER ELITE PRINCIPIANTE", "Gana el modo SNIPER ELITE en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"SNIPER ELITE AVANZADO", "Gana el modo SNIPER ELITE en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"SNIPER ELITE EXPERTO", "Gana el modo SNIPER ELITE en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"SNIPER ELITE PRO", "Gana el modo SNIPER ELITE en dificultad MUY DIFÍCIL con +75% de Vida intacta", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"NEMESIS PRINCIPIANTE", "Gana el modo NEMESIS en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"NEMESIS AVANZADO", "Gana el modo NEMESIS en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"NEMESIS EXPERTO", "Gana el modo NEMESIS en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"NEMESIS PRO", "Gana el modo NEMESIS en dificultad MUY DIFÍCIL con +75% de Vida intacta", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ASSASSIN PRINCIPIANTE", "Gana el modo ASSASSIN en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ASSASSIN AVANZADO", "Gana el modo ASSASSIN en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ASSASSIN EXPERTO", "Gana el modo ASSASSIN en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ASSASSIN PRO", "Gana el modo ASSASSIN en dificultad MUY DIFÍCIL con +75% de Vida intacta", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ANIQUILADOR PRINCIPIANTE", "Gana el modo ANIQUILADOR en dificultad NORMAL", 5, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ANIQUILADOR AVANZADO", "Gana el modo ANIQUILADOR en dificultad DIFÍCIL", 10, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ANIQUILADOR EXPERTO", "Gana el modo ANIQUILADOR en dificultad MUY DIFÍCIL", 15, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"ANIQUILADOR PRO", "Gana el modo ANIQUILADOR en dificultad MUY DIFÍCIL con +75% de Vida intacta", 20, 12, 0, ACHIEVEMENT_CLASS_MODES},
	{"LA MEJOR OPCIÓN", "Sube un arma al nivel 5", 5, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"UNA DE LAS MEJORES", "Sube un arma al nivel 10", 10, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"MI PREFERIDA", "Sube un arma al nivel 15", 15, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR", "Sube un arma al nivel 20", 20, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"PRIMERO: LA MEJOR OPCIÓN", "Primero del servidor en subir un arma al nivel 5", 5, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"PRIMERO: UNA DE LAS MEJORES", "Primero del servidor en subir un arma al nivel 10", 10, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"PRIMERO: MI PREFERIDA", "Primero del servidor en subir un arma al nivel 15", 15, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"PRIMERO: LA MEJOR", "Primero del servidor en subir un arma al nivel 20", 20, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"LA MEJOR OPCIÓN x5", "Sube cinco armas al nivel 5", 10, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"UNA DE LAS MEJORES x5", "Sube cinco armas al nivel 10", 20, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"MI PREFERIDA x5", "Sube cinco armas al nivel 15", 30, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR x5", "Sube cinco armas al nivel 20", 40, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR OPCIÓN x10", "Sube diez armas al nivel 5", 20, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"UNA DE LAS MEJORES x10", "Sube diez armas al nivel 10", 40, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"MI PREFERIDA x10", "Sube diez armas al nivel 15", 60, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR x10", "Sube diez armas al nivel 20", 80, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR OPCIÓN x15", "Sube quince armas al nivel 5", 40, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"UNA DE LAS MEJORES x15", "Sube quince armas al nivel 10", 80, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"MI PREFERIDA x15", "Sube quince armas al nivel 15", 120, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR x15", "Sube quince armas al nivel 20", 160, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR OPCIÓN x20", "Sube veinte armas al nivel 5", 80, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"UNA DE LAS MEJORES x20", "Sube veinte armas al nivel 10", 160, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"MI PREFERIDA x20", "Sube veinte armas al nivel 15", 240, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"LA MEJOR x20", "Sube veinte armas al nivel 20", 320, 0, 0, ACHIEVEMENT_CLASS_WEAPONS},
	{"BOMBA FALLIDA", "Has explotar una bomba de infección sin infectar a nadie", 5, 0, 10, ACHIEVEMENT_CLASS_ZOMBIE},
	{"VIRUS", "Infecta a 20 humanos en una misma ronda INFECCIÓN^nsin morir, sin utilizar furia zombie ni bomba de infección", 10, 0, 10, ACHIEVEMENT_CLASS_ZOMBIE},
	{"ENTRENANDO", "Juega 1 día", 1, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"ESTOY MUY SOLO", "Juega 7 días", 7, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"FOREVER ALONE", "Juega 15 días", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"CREO QUE TENGO UN PROBLEMA", "Juega 30 días", 30, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"SOLO EL ZP ME ENTIENDE", "Juega 50 días", 50, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"LOS PRIMEROS", "Completa 25 logros", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"VAMOS POR MÁS", "Completa 75 logros", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"EXPERTO EN LOGROS", "Completa 150 logros", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"THIS IS SPARTA", "Completa 300 logros", 25, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"SOY DORADO", "Ser usuario PREMIUM", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"QUE SUERTE", "Mata a un modo de cada tipo", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"PRIMERO: QUE SUERTE", "Primero del servidor en matar a un modo de cada tipo", 10, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"LÍDER EN CABEZAS", "Mata a 1.000 zombies con disparos en la cabeza", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"AGUJEREANDO CABEZAS", "Mata a 10.000 zombies con disparos en la cabeza", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MORTIFICANDO ZOMBIES", "Mata a 50.000 zombies con disparos en la cabeza", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CABEZAS ZOMBIES", "Mata a 100.000 zombies con disparos en la cabeza", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"100 ZOMBIES", "Mata a 100 zombies", 1, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"500 ZOMBIES", "Mata a 500 zombies", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"1.000 ZOMBIES", "Mata a 1.000 zombies", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"2.500 ZOMBIES", "Mata a 2.500 zombies", 7, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"5.000 ZOMBIES", "Mata a 5.000 zombies", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"10.000 ZOMBIES", "Mata a 10.000 zombies", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"25.000 ZOMBIES", "Mata a 25.000 zombies", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"50.000 ZOMBIES", "Mata a 50.000 zombies", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"100.000 ZOMBIES", "Mata a 100.000 zombies", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"250.000 ZOMBIES", "Mata a 250.000 zombies", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"500.000 ZOMBIES", "Mata a 500.000 zombies", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"1.000.000 DE ZOMBIES", "Mata a 1.000.000 de zombies", 75, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"5.000.000 DE ZOMBIES", "Mata a 5.000.000 de zombies", 100, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MIRA MI DAÑO", "Realiza 100.000 de daño", 1, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MÁS Y MÁS DAÑO", "Realiza 500.000 de daño", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"LLEGUÉ AL MILLÓN", "Realiza 1.000.000 de daño", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MI DAÑO CRECE", "Realiza 5.000.000 de daño", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MI DAÑO CRECE Y CRECE", "Realiza 25.000.000 de daño", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"VAMOS POR LOS 50 MILLONES", "Realiza 50.000.000 de daño", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CONTADOR DE DAÑOS", "Realiza 100.000.000 de daño", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"YA PERDÍ LA CUENTA", "Realiza 500.000.000 de daño", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MI DAÑO ES CATASTRÓFICO", "Realiza 1.000.000.000 de daño", 35, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MI DAÑO ES NUCLEAR", "Realiza 5.000.000.000 de daño", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MUCHOS NÚMEROS", "Realiza 20.000.000.000 de daño", 45, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"¿SE ME BUGUEO EL DAÑO? ... BAZINGA", "Realiza 50.000.000.000 de daño", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ME ABURROOOOO", "Realiza 100.000.000.000 de daño", 75, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"NO SÉ LEER ESTE NÚMERO", "Realiza 214.748.364.800 de daño", 100, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"MI CUCHILLO ES ROJO", "Mata a un NEMESIS con cuchillo", 10, 10, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"AFILANDO MI CUCHILLO", "Mata a un zombie con cuchillo", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ACUCHILLANDO", "Mata a 30 zombies con cuchillo", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ME ENCANTAN LAS TRIPAS", "Mata a 50 zombies con cuchillo", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"HUMILLACIÓN", "Mata a 100 zombies con cuchillo", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CLAVO QUE TE CLAVO LA SOMBRILLA", "Mata a 150 zombies con cuchillo", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ENTRA CUCHILLO, SALEN LAS TRIPAS", "Mata a 200 zombies con cuchillo", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"HUMILIATION DEFEAT", "Mata a 250 zombies con cuchillo", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CUCHILLO DE COCINA", "Mata a 500 zombies con cuchillo", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CUCHILLO PARA PIZZA", "Mata a 1.000 zombies con cuchillo", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"YOCUCHI", "Mata a 5.000 zombies con cuchillo", 75, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CABEZITA", "Realiza 5.000 disparos en la cabeza", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"A PLENO", "Realiza 15.000 disparos en la cabeza", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ROMPIENDO CABEZAS", "Realiza 50.000 disparos en la cabeza", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ABRIENDO CEREBROS", "Realiza 150.000 disparos en la cabeza", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"PERFORANDO", "Realiza 300.000 disparos en la cabeza", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"DESCOCANDO", "Realiza 500.000 disparos en la cabeza", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ROMPECRANEOS", "Realiza 1.000.000 disparos en la cabeza", 35, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"DUCK HUNT", "Realiza 5.000.000 disparos en la cabeza", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"AIMBOT", "Realiza 10.000.000 disparos en la cabeza", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"VINCULADO", "Vincula tu cuenta del Zombie Plague a la web Drunk Gaming | \ypanelzpl.drunk-gaming.com", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"CICLO C", "Alcanza el rango T", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"CICLO B", "Alcanza el rango M", 25, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"CICLO A", "Alcanza el rango G", 50, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"CICLO MÁXIMO", "Alcanza el rango A", 100, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"100 HUMANOS", "Infecta a 100 humanos", 1, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"500 HUMANOS", "Infecta a 500 humanos", 2, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"1.000 HUMANOS", "Infecta a 1.000 humanos", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"2.500 HUMANOS", "Infecta a 2.500 humanos", 7, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"5.000 HUMANOS", "Infecta a 5.000 humanos", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"10.000 HUMANOS", "Infecta a 10.000 humanos", 15, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"25.000 HUMANOS", "Infecta a 25.000 humanos", 20, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"50.000 HUMANOS", "Infecta a 50.000 humanos", 25, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"100.000 HUMANOS", "Infecta a 100.000 humanos", 30, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"250.000 HUMANOS", "Infecta a 250.000 humanos", 40, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"500.000 HUMANOS", "Infecta a 500.000 humanos", 50, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"1.000.000 DE HUMANOS", "Infecta a 1.000.000 de humanos", 75, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"5.000.000 DE HUMANOS", "Infecta a 5.000.000 de humanos", 100, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"SACANDO PROTECCIÓN", "Desgarra 500 de chaleco humano", 2, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"ESO NO TE SIRVE DE NADA", "Desgarra 2.000 de chaleco humano", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"NO ES UN PROBLEMA PARA MI", "Desgarra 5.000 de chaleco humano", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"SIN DEFENSAS", "Desgarra 30.000 de chaleco humano", 15, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"DESGARRANDO CHALECO", "Desgarra 60.000 de chaleco humano", 20, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"TOTALMENTE INDEFENSO", "Desgarra 100.000 de chaleco humano", 25, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"¿Y LA LIMPIEZA?", "Has explotar una bomba de antidoto sin desinfectar a nadie", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"YO USO CLEAR ZOMBIE", "Has explotar una bomba antidoto y desinfecta a 12+ zombies", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"ANTIDOTO PARA TODOS", "Has explotar una bomba antidoto y desinfecta a 18+ zombies", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"PENSANDOLO BIEN...", "Utiliza dos furia zombie en un mismo mapa sin infectar a nadie", 5, 0, 10, ACHIEVEMENT_CLASS_ZOMBIE},
	{"YO NO FUI", "Infecta a 5 humanos sin morir con tu vida al máximo^nsin tener furia zombie activa y sin bomba", 10, 0, 10, ACHIEVEMENT_CLASS_ZOMBIE},
	{"YO FUI", "Utiliza dos furia zombie en una misma ronda e infecta a 15 humanos mientras duren sin bomba", 10, 0, 10, ACHIEVEMENT_CLASS_ZOMBIE},
	{"BUEN COMIENZO", "Gana un duelo \r(ESTE LOGRO HA SIDO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"PRO DUELO", "Gana 50 duelos \r(ESTE LOGRO HA SIDO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"TRANQUI... 120", "Gana 120 duelos \r(ESTE LOGRO HA SIDO DESHABILITADO)", 10, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"AL MÁXIMO", "Gana 200 duelos \r(ESTE LOGRO HA SIDO DESHABILITADO)", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"OTRA FORMA DE JUGAR", "Gana un duelo con la apuesta máxima \r(ESTE LOGRO HA SIDO DESHABILITADO)", 15, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"PRIMERO: BUEN COMIENZO", "Se el primero en ganar un duelo \r(ESTE LOGRO HA SIDO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"MI CUCHILLA Y YO", "Mata a todos los jugadores siendo ANIQUILADOR", 10, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{"ANIQUILOSO", "Mata a 300 humanos con la cuchilla", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"CIENFUEGOS", "Mata a 125 humanos con la bazooka", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"CARNE", "Mata a 300 humanos", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"¡MUCHA CARNE!", "Mata a 400 humanos", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"¡DEMASIADA CARNE!", "Mata a 500 humanos", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"¡CARNE PARA TODOS!", "Mata a 625 humanos", 20, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"EL PEOR DEL SERVER", "Utiliza tus 5 bazookas sin matar a nadie", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"OOPS! MATÉ A TODOS", "Mata a todos los humanos con una bazooka", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{"MI MAC-10 ESTÁ LLENA", "Termina la ronda sin utilizar tu MAC-10", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"SOY UN MANCO", "Terminar la ronda sin matar a nadie con tu MAC-10^n gastando todas las balas", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"50 SON 50", "Mata 50 humanos con tu MAC-10", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"YO SI PEGO CON ESTO", "Mata 100 humanos con tu MAC-10", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MUCHA PRECISIÓN", "Mata 130 humanos con tu MAC-10", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"CRATER SANGRIENTO", "Gana el modo NEMESIS sin utilizar la bazooka", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{"LA EXPLOSIÓN NO MATA", "Lanza la bazooka sin matar a nadie", 5, 15, 0, ACHIEVEMENT_CLASS_MODES},
	{"LA EXPLOSIÓN SI MATA", "Mata +20 humanos con tu bazooka", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - ZOMBIES x5", "Mata a cinco zombies en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - HUMANOS x5", "Mata a cinco humanos en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - NEMESIS x2", "Mata a dos nemesis en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - SURVIVOR x2", "Mata a dos survivor en un mismo Mega Armageddón", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - AL MISMO HUMANO", "Mata a un humano y luego vuelve a matar^nal mismo usuario cuando es survivor", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - AL MISMO ZOMBIE", "Mata a un zombie y luego vuelve a matar^nal mismo usuario cuando es nemesis", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - HUMANO GANADOR", "Sobrevive el modo Mega Armageddón siendo humano/survivor", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - ZOMBIE GANADOR", "Sobrevive el modo Mega Armageddón siendo zombie/nemesis", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - TODOS LOS ZOMBIES", "Consigue matar a todos los zombies sin que ningún humano muera", 20, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MA - TODOS LOS HUMANOS", "Consigue matar a todos los humanos sin que ningún zombie muera", 20, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - GANADOR x1", "Gana el modo GunGame", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - GANADOR x10", "Gana diez veces el modo GunGame", 50, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - CASI TE GANO", "Finaliza el GunGame en nivel 25 o 26", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - HEADSHOTS x20", "Mata a 20 usuarios con disparos en la cabeza en un mismo GunGame", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - HEADSHOTS x30", "Mata a 30 usuarios con disparos en la cabeza en un mismo GunGame", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - HEADSHOTS x40", "Mata a 40 usuarios con disparos en la cabeza en un mismo GunGame", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - ÚNICO", "Gana el modo GunGame siendo el único en nivel 26", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - GANADOR POR LEJOS", "Gana el modo GunGame sin que nadie esté en el nivel 25 o 26", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - GANADOR VELOZ", "Gana el modo GunGame en menos de dos minutos", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"GG - GANADOR CONSECUTIVO", "Gana el modo GunGame dos veces seguidas", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"SOY MUY NOOB", "Se el primero en morir en un DUELO FINAL", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"ACUCHILLANDO", "Mata a 5 humanos en Duelo final de Cuchillos", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"AFICIONADO EN CUCHI", "Mata a 10 humanos en Duelo final de Cuchillos", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"ENTRAN CUCHILLO SALEN LAS TRIPAS", "Mata a 15 humanos en Duelo final de Cuchillos", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"TODO UN AWPER", "Mata a 5 humanos en Duelo final de AWP", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"EXPERTO EN AWP", "Mata a 10 humanos en Duelo final de AWP", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"PRO AWP", "Mata a 15 humanos en Duelo final de AWP", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"DETONADOS", "Mata a 5 humanos en Duelo final de HE", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"BOMBAZO PARA TODOS", "Mata a 10 humanos en Duelo final de HE", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"BOOM.. EN TODA LA CARA", "Mata a 15 humanos en Duelo final de HE", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"SENTA2", "Mata a 5 humanos en Duelo final de Only Head", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"¡PUM! BALAAAAAAZO", "Mata a 10 humanos en Duelo final de Only Head", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"THE KILLER OF DK", "Mata a 15 humanos en Duelo final de Only Head", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"¡PUM! CHSS CHSSSS", "Mata a 5 humanos en Duelo final de Escopetas", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"ESCOPETOIDE", "Mata a 10 humanos en Duelo final de Escopetas", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"LA RECORTADA DEL .6", "Mata a 15 humanos en Duelo final de Escopetas", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"100 AL ROJO", "Acumula 100 cabezas zombie rojas", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"¿75 AL VERDE?", "Acumula 75 cabezas zombie verdes", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"50 PITUFOS", "Acumula 50 cabezas zombie azules", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"25 Y SIGO", "Acumula 25 cabezas zombie amarillas", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"COLORIDO", "Agarra cabezas zombies de todos los colores", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"MI PRIMER DUELO", "Gana un DUELO FINAL", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"VAMOS BIEN", "Gana cinco DUELOS FINALES", 10, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"DEMASIADO FÁCIL", "Gana diez DUELOS FINALES", 15, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"5 DADOS", "Gana a los dados 5 veces", 1, 0, 0, -1},
	{"20 DADOS", "Gana a los dados 20 veces", 2, 0, 0, -1},
	{"50 DADOS", "Gana a los dados 50 veces", 5, 0, 0, -1},
	{"100 DADOS", "Gana a los dados 100 veces", 7, 0, 0, -1},
	{"500 DADOS", "Gana a los dados 500 veces", 10, 0, 0, -1},
	{"1.000 DADOS", "Gana a los dados 1.000 veces", 15, 0, 0, -1},
	{"UNO", "En una sola tirada, consigue que tus seis dados sean 1", 5, 0, 0, -1},
	{"DOS", "En una sola tirada, consigue que tus seis dados sean 2", 5, 0, 0, -1},
	{"TRES", "En una sola tirada, consigue que tus seis dados sean 3", 5, 0, 0, -1},
	{"CUATRO", "En una sola tirada, consigue que tus seis dados sean 4", 5, 0, 0, -1},
	{"CINCO", "En una sola tirada, consigue que tus seis dados sean 5", 5, 0, 0, -1},
	{"SEIS", "En una sola tirada, consigue que tus seis dados sean 6", 5, 0, 0, -1},
	{"ESCALERA", "En una sola tirada, consigue que^ntus seis dados sean diferentes", 10, 0, 0, -1},
	{"POR 10", "Gana a los dados por una diferencia de 10 o más", 5, 0, 0, -1},
	{"POR 20", "Gana a los dados por una diferencia de 20 o más", 10, 0, 0, -1},
	{"POR 30", "Gana a los dados por una diferencia de 30", 15, 0, 0, -1},
	{"PAR", "En una sola tirada, consigue que^ntus seis dados sean números pares", 10, 0, 0, -1},
	{"IMPAR", "En una sola tirada, consigue que^ntus seis dados sean números impares", 10, 0, 0, -1},
	{"LOS PARES", "En una sola tirada, consigue que^ntus dados sean: 2, 2, 4, 4, 6, 6", 20, 0, 0, -1},
	{"LOS IMPARES", "En una sola tirada, consigue que^ntus dados sean: 1, 1, 3, 3, 5, 5", 20, 0, 0, -1},
	{"EQUILIBRIO", "En una sola tirada, consigue tres dados pares y tres dados impares", 10, 0, 0, -1},
	{"EMPATE", "Empata en el juego de los dados", 10, 0, 0, -1},
	{"EMPATE EXACTO", "Empata en el juego de los dados^ncon los mismos dados que tu oponente", 5, 0, 0, -1},
	{"DOBLE ESCALERA", "Empata en el juego de los dados^ncon una escalera", 5, 0, 0, -1},
	{"LA BUENA PIEDRA, NADA LE GANA", "Consigue sa4car PIEDRA tres veces en una misma partida", 5, 0, 0, -1},
	{"POBRE BART, SIEMPRE ESCOJE PIEDRA", "Consigue sacar PAPEL tres veces en una misma partida", 5, 0, 0, -1},
	{"RUBIO PUTO, METETE LA TIJERA EN EL ORTO", "Consigue sacar TIJERA tres veces en una misma partida", 5, 0, 0, -1},
	{"ESTE ES MI JUEGO", "Gana una partida al PPT", 1, 0, 0, -1},
	{"¿5 PIEDRAS?", "Gana 5 partidas al PPT", 2, 0, 0, -1},
	{"¿15 PAPELES?", "Gana 15 partidas al PPT", 3, 0, 0, -1},
	{"¿30 TIJERAS?", "Gana 30 partidas al PPT", 4, 0, 0, -1},
	{"SUMADO ME DA 50", "Gana 50 partidas al PPT", 5, 0, 0, -1},
	{"Y POR 2 SON 100", "Gana 100 partidas al PPT", 6, 0, 0, -1},
	{"MÁS 200 ME DA 300", "Gana 300 partidas al PPT", 10, 0, 0, -1},
	{"Y POR 1.67 ME DA 500", "Gana 500 partidas al PPT", 15, 0, 0, -1},
	{"A LA MIERDA LA LOTERÍA, YO QUIERO SER PPTERO", "Gana 1.000 partidas al PPT", 20, 0, 0, -1},
	{"¿EMPATE?", "Consigue empatar tres rondas en una misma partida", 3, 0, 0, -1},
	{"DEJÁ DE ELEGIR LO MISMO QUE YO", "Consigue empatar cinco rondas en una misma partida", 5, 0, 0, -1},
	{"DRAW DRAW DRAW", "Consigue empatar siete rondas en una misma partida", 7, 0, 0, -1},
	{"ESTO ME TIENE LOCO", "Consigue ganar tres partidas consecutivas^nen el mismo mapa y sin desconectarte", 5, 0, 0, -1},
	{"SOY INVENCIBLE", "Consigue ganar cinco partidas consecutivas^nen el mismo mapa y sin desconectarte", 10, 0, 0, -1},
	{"DIFERENCIA DE 25 DADOS", "Consigue tener una diferencia de 25^nentre rondas ganadas y perdidas jugando DADOS", 10, 0, 0, -1},
	{"DIFERENCIA DE 50 DADOS", "Consigue tener una diferencia de 50^nentre rondas ganadas y perdidas jugando DADOS", 25, 0, 0, -1},
	{"DIFERENCIA DE 250 DADOS", "Consigue tener una diferencia de 250^nentre rondas ganadas y perdidas jugando DADOS", 50, 0, 0, -1},
	{"DIFERENCIA DE 500 DADOS", "Consigue tener una diferencia de 500^nentre rondas ganadas y perdidas jugando DADOS", 100, 0, 0, -1},
	{"DIFERENCIA DE 1.000 DADOS", "Consigue tener una diferencia de 1.000^nentre rondas ganadas y perdidas jugando DADOS", 500, 0, 0, -1},
	{"5.000 DADOS", "Gana a los dados 5.000 veces", 20, 0, 0, -1},
	{"10.000 DADOS", "Gana a los dados 10.000 veces", 25, 0, 0, -1},
	{"25.000 DADOS", "Gana a los dados 25.000 veces", 30, 0, 0, -1},
	{"50.000 DADOS", "Gana a los dados 50.000 veces", 35, 0, 0, -1},
	{"100.000 DADOS", "Gana a los dados 100.000 veces", 50, 0, 0, -1},
	{"500.000 DADOS", "Gana a los dados 500.000 veces", 75, 0, 0, -1},
	{"1.000.000 DADOS", "Gana a los dados 1.000.000 veces", 100, 0, 0, -1},
	{"COMBO: FIRST BLOOD", "Realiza el Combo First Blood", 1, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: DOUBLE KILL", "Realiza el Combo Double Kill", 2, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: MULTI KILL", "Realiza el Combo Multi Kill", 3, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: BLOOD BATH", "Realiza el Combo Blood Bath", 4, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: ULTRA KILL", "Realiza el Combo Ultra Kill", 5, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: MEGA KILL", "Realiza el Combo Mega Kill", 6, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: DOMINATING", "Realiza el Combo Dominating", 7, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: IMPRESSIVE", "Realiza el Combo Impressive", 8, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: RAMPAGE", "Realiza el Combo Rampage", 9, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: KILLING SPREE", "Realiza el Combo Killing Spree", 10, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: GODLIKE", "Realiza el Combo Godlike", 11, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: UNSTOPPABLE", "Realiza el Combo Unstoppable", 12, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: HOLY SHIT", "Realiza el Combo Holy Shit", 13, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: WICKED SICK", "Realiza el Combo Wicked Sick", 14, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: MONSTER KILL", "Realiza el Combo Monster Kill", 15, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: LUDICROUSS KILL", "Realiza el Combo Ludicrouss Kill", 20, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: IT'S A NIGHTMARE", "Realiza el Combo IT'S A NIGHTMARE", 25, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: WHAT THE FUUUUUUUU", "Realiza el Combo WHAT THE FUUUUUUUU", 30, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: I N F E R N O", "Realiza el Combo I N F E R N O", 40, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: A A A A A A A A A A A A A", "A A A A A A A A A A A A A", 50, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: L O O O O O O O O O O O L", "L O O O O O O O O O O O L", 60, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: O O O O H   MY   G O O O O O O O O D", "O O O O H   MY   G O O O O O O O O D", 75, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: G O R G E O U S S S S", "G O R G E O U S S S S", 100, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO: . . .", ". . .", 125, 1, 1, ACHIEVEMENT_CLASS_HUMAN},
	{"COMBO ZOMBIE: FIRST BLOOD", "Realiza el Combo Zombie First Blood", 1, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: DOUBLE KILL", "Realiza el Combo Zombie Double Kill", 2, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: MULTI KILL", "Realiza el Combo Zombie Multi Kill", 3, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: BLOOD BATH", "Realiza el Combo Zombie Blood Bath", 4, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: ULTRA KILL", "Realiza el Combo Zombie Ultra Kill", 5, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: MEGA KILL", "Realiza el Combo Zombie Mega Kill", 6, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: DOMINATING", "Realiza el Combo Zombie Dominating", 7, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: IMPRESSIVE", "Realiza el Combo Zombie Impressive", 8, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: RAMPAGE", "Realiza el Combo Zombie Rampage", 9, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: KILLING SPREE", "Realiza el Combo Zombie Killing Spree", 10, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: GODLIKE", "Realiza el Combo Zombie Godlike", 11, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: UNSTOPPABLE", "Realiza el Combo Zombie Unstoppable", 12, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: HOLY SHIT", "Realiza el Combo Zombie Holy Shit", 13, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: WICKED SICK", "Realiza el Combo Zombie Wicked Sick", 14, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: MONSTER KILL", "Realiza el Combo Zombie Monster Kill", 15, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: LUDICROUSS KILL", "Realiza el Combo Zombie Ludicrouss Kill", 20, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: IT'S A NIGHTMARE", "Realiza el Combo Zombie IT'S A NIGHTMARE", 25, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: WHAT THE FUUUUUUUU", "Realiza el Combo Zombie WHAT THE FUUUUUUUU", 30, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: I N F E R N O", "Realiza el Combo Zombie I N F E R N O", 40, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: A A A A A A A A A A A A A", "A A A A A A A A A A A A A", 50, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: L O O O O O O O O O O O L", "L O O O O O O O O O O O L", 60, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: O O O O H   MY   G O O O O O O O O D", "O O O O H   MY   G O O O O O O O O D", 75, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: G O R G E O U S S S S", "G O R G E O U S S S S", 100, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"COMBO ZOMBIE: . . .", ". . .", 125, 1, 1, ACHIEVEMENT_CLASS_ZOMBIE},
	{"10 BLANCAS", "Acumula 10 cabezas zombie blancas", 5, 0, 0, ACHIEVEMENT_CLASS_OTHERS},
	{"FRANCOTIRADOR", "Gana el modo SNIPER estando vivo", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"EL MEJOR EQUIPO", "Gana el modo SNIPER sin que ningún compañero muera", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"EN MEMORIA A ELLOS", "Gana el modo SNIPER siendo el último SNIPER vivo", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MI AWP ES MEJOR", "Mata 8 zombies con AWP", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"MI SCOUT ES MEJOR", "Mata a 8 zombies con SCOUT", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"SOBREVIVEN LOS DUROS", "Teniendo AWP, gana el modo con tu compañero de AWP", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"NO SOLO LA GANAN LOS DUROS", "Teniendo SCOUT, gana el modo con tu compañero de SCOUT", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"ZAS, EN TODA LA BOCA", "Mata 8 zombies con disparos en la cabeza", 5, 0, 0, ACHIEVEMENT_CLASS_MODES},
	{"NO TENGO BALAS", "Gana el modo SNIPER sin realizar daño", 10, 1, 0, ACHIEVEMENT_CLASS_MODES},
	{"EVL: TOOS LOS DULCES", "Come todos los dulces de la tienda en una ronda", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: DULCE BOOM", "Come más de 10 dulces de la tienda en el mapa", 10, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: EL INTENSO DEL SERVIDOR", "Regalale una flor 3 veces al mismo jugador de forma consecutiva", 15, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: FLORES x5", "Regalale 5 flores", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: FLORES x10", "Regalale 10 flores", 10, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: FLORES x25", "Regalale 25 flores", 15, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: FLORES x50", "Regalale 50 flores", 20, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: FLOR ZOMBIE", "Prueba regalarle una flor a un zombie a ver si siente amor", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: DULCE ZOMBIE", "Come el dulce zombie", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMANDO ADMINES", "Ama a más de 5 administradores", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: SER DEPURADO EN EL INTENTO", "Intenta amar a un staff, si te atreves", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMORODIO", "Ama al Rank #1 del servidor", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: SON AMORES", "Ama a 10 jugadores", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMORES x100", "Ama a 100 jugadores", 10, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMORES x500", "Ama a 500 jugadores", 15, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMORES x2500", "Ama a 2500 jugadores", 20, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMADO x10", "Se amado 10 veces", 5, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMADO x100", "Se amado 100 veces", 10, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"EVL: AMADO x500", "Se amado 500 veces", 15, 0, 0, ACHIEVEMENT_CLASS_EVL},
	{"TERRORISTA Nº1", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"AL INFINITO", "Logro secreto", 10, 1, 1, ACHIEVEMENT_CLASS_SECRETS},
	{"RÁPIDO Y FURIOSO", "Logro secreto", 10, 1, 1, ACHIEVEMENT_CLASS_SECRETS},
	{"MI MAMÁ ME DIJO QUE TE DISPARE", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"CORTAMAMBO", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"CHUCK NORRIS", "Logro secreto", 15, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"VIRUS-T", "Logro secreto", 20, 1, 1, ACHIEVEMENT_CLASS_SECRETS},
	{"HITMAN", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"MÁS ZOMBIES", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"LET'S ROCK", "Logro secreto", 5, 1, 1, ACHIEVEMENT_CLASS_SECRETS},
	{"MÁXIMO COMPRADOR", "Logro secreto", 10, 1, 1, ACHIEVEMENT_CLASS_SECRETS},
	{"JUGADOR COMPULSIVO", "Logro secreto \r(ESTE LOGRO HA SIDO DESHABILITADO)", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"MILLONARIO", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"EL TERROR EXISTE", "Logro secreto", 10, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"RESISTENCIA", "Logro secreto", 10, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"ALBERT WESKER", "Logro secreto", 10, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"ASESINO DE TURNO", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"APLASTA ZOMBIES", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"ZÁNGANO REAL", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"DEPREDADOR FINAL", "Logro secreto", 5, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"DEPREDALIEN", "Logro secreto", 10, 0, 0, ACHIEVEMENT_CLASS_SECRETS},
	{"VISIÓN NOCTURNA x10", "Compra 10 veces el item extra Visión Nocturna", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"INVISIBILIDAD x10", "Compra 10 veces el item extra Invisibilidad", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BALAS INFINITAS x10", "Compra 10 veces el item extra Balas Infinitas", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PRECISIÓN PERFECTA x10", "Compra 10 veces el item extra Precisión perfecta", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA DE ANIQUILACIÓN x10", "Compra 10 veces el item extra Bomba de Aniquilación", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA MOLOTOV x10", "Compra 10 veces el item extra Bomba Molotov", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA ANTIDOTO x10", "Compra 10 veces el item extra Bomba Antidoto", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ANTIDOTO x10", "Compra 10 veces el item extra Antidoto", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"FURIA ZOMBIE x10", "Compra 10 veces el item extra Furia Zombie", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA DE INFECCIÓN x10", "Compra 10 veces el item extra Bomba de Infección", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"REDUCCIÓN DE DAÑO x10", "Compra 10 veces el item extra Reducción de daño", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PAINSHOCK x10", "Compra 10 veces el item extra Painshock", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PETRIFICACIÓN x10", "Compra 10 veces el item extra Petrificación", 1, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"VISIÓN NOCTURNA x50", "Compra 50 veces el item extra Visión Nocturna", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"INVISIBILIDAD x50", "Compra 50 veces el item extra Invisibilidad", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BALAS INFINITAS x50", "Compra 50 veces el item extra Balas Infinitas", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PRECISIÓN PERFECTA x50", "Compra 50 veces el item extra Precisión perfecta", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA DE ANIQUILACIÓN x50", "Compra 50 veces el item extra Bomba de Aniquilación", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA MOLOTOV x50", "Compra 50 veces el item extra Bomba Molotov", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA ANTIDOTO x50", "Compra 50 veces el item extra Bomba Antidoto", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ANTIDOTO x50", "Compra 50 veces el item extra Antidoto", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"FURIA ZOMBIE x50", "Compra 50 veces el item extra Furia Zombie", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA DE INFECCIÓN x50", "Compra 50 veces el item extra Bomba de Infección", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PAINSHOCK x50", "Compra 50 veces el item extra Painshock", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"REDUCCIÓN DE DAÑO x50", "Compra 50 veces el item extra Reducción de daño", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PETRIFICACIÓN x50", "Compra 50 veces el item extra Petrificación", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"VISIÓN NOCTURNA x100", "Compra 100 veces el item extra Visión Nocturna", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"INVISIBILIDAD x100", "Compra 100 veces el item extra Invisibilidad", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BALAS INFINITAS x100", "Compra 100 veces el item extra Balas Infinitas", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PRECISIÓN PERFECTA x100", "Compra 100 veces el item extra Precisión perfecta", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA DE ANIQUILACIÓN x100", "Compra 100 veces el item extra Bomba de Aniquilación", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA MOLOTOV x100", "Compra 100 veces el item extra Bomba Molotov", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA ANTIDOTO x100", "Compra 100 veces el item extra Bomba Antidoto", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ANTIDOTO x100", "Compra 100 veces el item extra Antidoto", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"FURIA ZOMBIE x100", "Compra 100 veces el item extra Furia Zombie", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"BOMBA DE INFECCIÓN x100", "Compra 100 veces el item extra Bomba de Infección", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"REDUCCIÓN DE DAÑO x100", "Compra 100 veces el item extra Reducción de daño", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PAINSHOCK x100", "Compra 100 veces el item extra Painshock", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"PETRIFICACIÓN x100", "Compra 100 veces el item extra Petrificación", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ITEMS EXTRAS x10", "Compra 10 veces todos los items extras", 5, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ITEMS EXTRAS x50", "Compra 50 veces todos los items extras", 10, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ITEMS EXTRAS x100", "Compra 100 veces todos los items extras", 15, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ITEMS EXTRAS x500", "Compra 500 veces todos los items extras", 20, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ITEMS EXTRAS x1.000", "Compra 1.000 veces todos los items extras", 25, 0, 0, ACHIEVEMENT_CLASS_EI},
	{"ITEMS EXTRAS x5.000", "Compra 5.000 veces todos los items extras", 50, 0, 0, ACHIEVEMENT_CLASS_EI}
};

new const CLAN_PERKS[structIdClanPerks][structClanPerks] =
{
	{"HABILITAR COMBO", "Habilita el combo del Clan", 250},
	{"MULTIPLICADOR DE COMBO", "Multiplica la recompensa del combo cuanto más alto sea^n^n\yREQUIERE\r:^n\r - \wHABILITAR COMBO", 175},
	{"FURIA EXTENDIDA", "Aumenta en dos segundos la furia zombie a los miembros del clan", 100}
};

new const COLORS_TYPE_NAMES_MIN[structIdColorsType][] = {"HUD General", "HUD Combo", "HUD Clan Combo", "Visión nocturna", "Luz/Bubble", "Clan Glow"};

new const COLORS[][structColors] =
{
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

new const HUDS_TYPE_NAMES_MAY[structIdHudsType][] = {"GENERAL", "COMBO", "CLAN COMBO"};

new const CHAT_MODE[structIdChatMode][] = {"[Rango](Nivel)", "[Rango][Nivel]", "[Rango][(Nivel)]", "[Rango]{Nivel}", "[Rango]{(Nivel)}", "[Rango]{[Nivel]}", "[Rango]{[(Nivel)]}"};

new const CLAN_COMBO_HUMAN[] = {0, 50000, 100000, 200000, 350000, 650000, 1000000, 2100000000};

new const HATS[structIdHats][structHats] = // Vida - Velocidad - Gravedad - Daño - APs - XP - Respawn - Items
{
	{"Ninguno", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0},
	{"Angel", "models/dg/zp6/hats/angel2.mdl", "Mata a 2.500 zombies", "", 2, 1, 1, 0, 1, 0, 0, 10},
	{"Awesome", "models/dg/zp6/hats/awesome.mdl", "Infecta a 2.500 humanos", "", 2, 1, 1, 0, 0, 1, 0, 10},
	{"Devil", "models/dg/zp6/hats/devil2.mdl", "Consigue ser último humano en el modo Infección", "Sin comprar armas ni items extras, y al menos 10 jugadores conectados", 2, 1, 1, 2, 0, 1, 0, 10},
	{"Earth", "models/dg/zp6/hats/earth.mdl", "Infecta a 5 humanos usando una furia zombie", "", 1, 0, 0, 3, 1, 1, 0, 10},
	{"Gold Head", "models/dg/zp6/hats/gold_head.mdl", "Se un usuario VIP", "", 1, 1, 1, 1, 1, 1, 0, 0},
	{"Pumpkin", "models/dg/zp6/hats/halloween.mdl", "Asusta a 500 humanos en el evento HALLOWEEN", "", 2, 2, 2, 2, 1, 1, 0, 5},
	{"Navid", "models/dg/zp6/hats/hat_navid2.mdl", "Acumula 250 regalos en el evento NAVIDAD", "", 2, 2, 2, 2, 1, 1, 0, 5},
	{"Hood", "models/dg/zp6/hats/hood.mdl", "Siendo WESKER gana la ronda sin utilizar los lasers", "Al menos 10 jugadores conectados", 0, 2, 0, 2, 1, 1, 2, 10},
	{"Jack", "models/dg/zp6/hats/jackolantern.mdl", "Mata a 100 survivors", "", 2, 2, 0, 1, 0, 2, 0, 10},
	{"Jamaca", "models/dg/zp6/hats/jamacahat2.mdl", "Mata a 100 nemesis", "", 2, 0, 2, 1, 0, 2, 0, 10},
	{"Psycho", "models/dg/zp6/hats/psycho.mdl", "Consigue los logros \yBOMBA FALLIDA\w y \yVIRUS\w", "", 1, 3, 1, 3, 1, 0, 5, 15},
	{"Sasha", "models/dg/zp6/hats/sasha.mdl", "Mata 500 zombies con cuchillo", "", 0, 5, 5, 0, 1, 1, 10, 10},
	{"Scream", "models/dg/zp6/hats/scream.mdl", "Consigue ser campeón con tu Clan", "", 1, 2, 2, 1, 1, 1, 5, 5},
	{"Spartan", "models/dg/zp6/hats/spartan.mdl", "Sube al nivel 10 tu Cuchillo", "", 3, 1, 1, 3, 0, 0, 5, 15},
	{"Super Man", "models/dg/zp6/hats/supermancape.mdl", "Sube VELOCIDAD H/Z y GRAVEDAD H/Z al máximo", "", 2, 1, 1, 2, 1, 1, 5, 10},
	{"Tyno", "models/dg/zp6/hats/tyno.mdl", "Alcanza el rango U", "", 2, 2, 2, 2, 1, 1, 10, 5},
	{"Viking", "models/dg/zp6/hats/viking.mdl", "Juega 15 días", "", 3, 1, 1, 3, 2, 1, 5, 10},
	{"Zippy", "models/dg/zp6/hats/zippy.mdl", "Sube todas las armas al nivel 10", "", 3, 2, 2, 3, 2, 2, 10, 10},
	{"1er puesto", "models/dg/zp6/hats/Tyno-1er_puesto.mdl", "No puedes obtener este gorro", "", 4, 3, 3, 4, 1, 1, 15, 15},
	{"2do puesto", "models/dg/zp6/hats/Tyno-2do_puesto.mdl", "No puedes obtener este gorro", "", 3, 2, 2, 3, 1, 1, 10, 10},
	{"3er puesto", "models/dg/zp6/hats/Tyno-3er_puesto.mdl", "No puedes obtener este gorro", "", 2, 1, 1, 2, 1, 1, 5, 5}
};
new const HAT_MANAGER_MODEL[] = "models/dg/zp6/hats/Martinuchis.mdl";
const HAT_MANAGER_ID = 2;

new const COMBO_HUMAN[][structCombo] =
{
	{0, "¡Perfect!", "dg/zp6/c_perfect.wav"},
	{250, "¡First Blood!", "dg/zp6/c_first_blood.wav"},
	{500, "¡Double Kill!", "dg/zp6/c_double_kill.wav"},
	{1000, "¡Multi Kill!", "dg/zp6/c_multi_kill.wav"},
	{2500, "¡¡Blood Bath!!", "dg/zp6/c_blood_bath.wav"},
	{5000, "¡¡Ultra Kill!!", "dg/zp6/c_ultra_kill.wav"},
	{7500, "¡¡Mega Kill!!", "dg/zp6/c_mega_kill.wav"},
	{10000, "¡¡Dominating!!", "dg/zp6/c_dominating.wav"},
	{15000, "¡¡IMPRESSIVE!!", "dg/zp6/c_impressive.wav"},
	{20000, "¡¡RAMPAGE!!", "dg/zp6/c_rampage.wav"},
	{25000, "¡¡KILLING SPREE!!", "dg/zp6/c_killing_spree.wav"},
	{35000, "¡¡GODLIKE!!", "dg/zp6/c_godlike.wav"},
	{50000, "¡¡¡UNSTOPPABLE!!!", "dg/zp6/c_unstoppable.wav"},
	{75000, "¡¡¡HOLY SHIT!!!", "dg/zp6/c_holy_shit.wav"},
	{100000, "¡¡¡WICKED SICK!!!", "dg/zp6/c_wicked_sick.wav"},
	{150000, "¡¡¡MONSTER KILL!!!", "dg/zp6/c_monster_kill.wav"},
	{250000, "¡¡¡MONSTER KILL!!!", "dg/zp6/c_monster_kill.wav"},
	{350000, "¡¡¡LUDICROUSS KILL!!!", "dg/zp6/c_ludicrouss_kill.wav"},
	{450000, "¡¡¡¡IT'S A NIGHTMARE!!!!", "dg/zp6/c_ludicrouss_kill.wav"},
	{550000, "¡¡¡¡IT'S A NIGHTMARE!!!!", "dg/zp6/c_ludicrouss_kill.wav"},
	{650000, "¡¡¡¡WHAT THE FUUUUUUUU!!!!", "dg/zp6/c_ludicrouss_kill.wav"},
	{750000, "I N F E R N O", "dg/zp6/c_ludicrouss_kill.wav"},
	{1000000, "I N F E R N O", "dg/zp6/c_ludicrouss_kill.wav"},
	{1500000, "A A A A A A A A A A A A A", "dg/zp6/c_ludicrouss_kill.wav"},
	{2000000, "L O O O O O O O O O O O L", "dg/zp6/c_ludicrouss_kill.wav"},
	{2500000, "L O O O O O O O O O O O L", "dg/zp6/c_ludicrouss_kill.wav"},
	{3750000, "O O O O H   MY   G O O O O O O O O D", "dg/zp6/c_ludicrouss_kill.wav"},
	{5000000, "G O R G E O U S S S S", "dg/zp6/c_ludicrouss_kill.wav"},
	{7500000, "G O R G E O U S S S S", "dg/zp6/c_ludicrouss_kill.wav"},
	{10000000, ". . .", "dg/zp6/c_ludicrouss_kill.wav"},
	{25000000, ". . .", "dg/zp6/c_ludicrouss_kill.wav"},
	{50000000, ". . .", "dg/zp6/c_ludicrouss_kill.wav"},

	{2100000000, ". . .", "dg/zp6/c_ludicrouss_kill.wav"}
};

new const COMBO_ZOMBIE[][structCombo] =
{
	{1, "¡Perfect!", "dg/zp6/c_perfect.wav"},
	{2, "¡First Blood!", "dg/zp6/c_first_blood.wav"},
	{3, "¡Double Kill!", "dg/zp6/c_double_kill.wav"},
	{4, "¡Multi Kill!", "dg/zp6/c_multi_kill.wav"},
	{5, "¡¡Blood Bath!!", "dg/zp6/c_blood_bath.wav"},
	{6, "¡¡Ultra Kill!!", "dg/zp6/c_ultra_kill.wav"},
	{7, "¡¡Mega Kill!!", "dg/zp6/c_mega_kill.wav"},
	{8, "¡¡Dominating!!", "dg/zp6/c_dominating.wav"},
	{9, "¡¡IMPRESSIVE!!", "dg/zp6/c_impressive.wav"},
	{10, "¡¡RAMPAGE!!", "dg/zp6/c_rampage.wav"},
	{11, "¡¡KILLING SPREE!!", "dg/zp6/c_killing_spree.wav"},
	{12, "¡¡GODLIKE!!", "dg/zp6/c_godlike.wav"},
	{13, "¡¡¡UNSTOPPABLE!!!", "dg/zp6/c_unstoppable.wav"},
	{14, "¡¡¡HOLY SHIT!!!", "dg/zp6/c_holy_shit.wav"},
	{15, "¡¡¡WICKED SICK!!!", "dg/zp6/c_wicked_sick.wav"},
	{16, "¡¡¡MONSTER KILL!!!", "dg/zp6/c_monster_kill.wav"},
	{17, "¡¡¡MONSTER KILL!!!", "dg/zp6/c_monster_kill.wav"},
	{18, "¡¡¡LUDICROUSS KILL!!!", "dg/zp6/c_ludicrouss_kill.wav"},
	{19, "¡¡¡¡IT'S A NIGHTMARE!!!!", "dg/zp6/ludicrouss_kill.wav"},
	{20, "¡¡¡¡IT'S A NIGHTMARE!!!!", "dg/zp6/ludicrouss_kill.wav"},
	{21, "¡¡¡¡WHAT THE FUUUUUUUU!!!!", "dg/zp6/ludicrouss_kill.wav"},
	{22, "I N F E R N O", "dg/zp6/ludicrouss_kill.wav"},
	{23, "I N F E R N O", "dg/zp6/ludicrouss_kill.wav"},
	{24, "A A A A A A A A A A A A A", "dg/zp6/ludicrouss_kill.wav"},
	{25, "L O O O O O O O O O O O L", "dg/zp6/ludicrouss_kill.wav"},
	{26, "L O O O O O O O O O O O L", "dg/zp6/ludicrouss_kill.wav"},
	{27, "O O O O H   MY   G O O O O O O O O D", "dg/zp6/ludicrouss_kill.wav"},
	{28, "G O R G E O U S S S S", "dg/zp6/ludicrouss_kill.wav"},
	{29, "G O R G E O U S S S S", "dg/zp6/ludicrouss_kill.wav"},
	{30, ". . .", "dg/zp6/ludicrouss_kill.wav"},
	{31, ". . .", "dg/zp6/ludicrouss_kill.wav"},
	{32, ". . .", "dg/zp6/ludicrouss_kill.wav"},

	{2100000000, ". . .", "dg/zp6/c_ludicrouss_kill.wav"}
};

new const HEADZOMBIES_NAMES[structIdHeadZombies][] =
{
	"roja",
	"verde",
	"azul",
	"amarilla",
	"blanca"
};

new const HEADZOMBIES_INFO[structIdHeadZombies][] =
{
	"Otorgan APs",
	"Otorgan XP",
	"Otorgan Items extras \y(Sólo inicio de ronda)\w",
	"Otorgan pHZE",
	"Otorgan Modos individuales \y(Sólo inicio de ronda)\w^n\r - \wO pueden otorgar APs + XP + pHZE"
};

new const HEADZOMBIES_MESSAGES[][] =
{
	"La cabeza zombie tenía basura",
	"Ouuch! Solo tenia mugre",
	"La cabeza zombie estaba repleta de hongos",
	"Mala suerte! La cabeza zombie estaba vencida",
	"El demonio del quinto subsuelo se quedo con el premio",
	"Nada por aquí.. nada por allá",
	"Buena suerte tenemos todos, a pesar de que no te tocó nada"
};

new const GUNGAME_TYPE_NAME[structIdGunGameTypes][] = {"Normal", "Only Head", "Slow", "Fast", "Crazy", "Clásico"};
new const GUNGAME_TYPE_INFO[structIdGunGameTypes][] =
{
	"Modo normal sin alteraciones",
	"Solo puede matarse con disparos en la cabeza !g(!tx75 de Ganancias!g)!y",
	"Cada nivel requiere tres matados !g(!tx50 de Ganancias!g)!y",
	"Cada nivel requiere un matado !g(!tx25 de Ganancias!g)!y",
	"Cada nivel toca un arma al azar !g(!tx50 de Ganancias!g)!y",
	"Modo normal y clásico !g(!tx100 de Ganancias!g)!y"
};
new const GUNGAME_REWARD[structIdGunGameTypes] = {0, 75, 50, 25, 50, 100};
new const GUNGAME_WEAPONS[][] =
{
	"", "weapon_g3sg1", "weapon_sg550", "weapon_awp", "weapon_scout", "weapon_m249", "weapon_aug", "weapon_sg552", "weapon_m4a1", "weapon_ak47", "weapon_galil", "weapon_famas", "weapon_mp5navy", "weapon_p90", "weapon_ump45", "weapon_mac10",
	"weapon_tmp", "weapon_xm1014", "weapon_m3", "weapon_deagle", "weapon_elite", "weapon_p228", "weapon_usp", "weapon_glock18", "weapon_fiveseven", "weapon_hegrenade", "weapon_knife"
};
new const GUNGAME_WEAPONS_CSW[] =
{
	0, CSW_G3SG1, CSW_SG550, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_SG552, CSW_M4A1, CSW_AK47, CSW_GALIL, CSW_FAMAS, CSW_MP5NAVY, CSW_P90, CSW_UMP45, CSW_MAC10, CSW_TMP, CSW_XM1014, CSW_M3, CSW_DEAGLE, CSW_ELITE, CSW_P228, CSW_USP,
	CSW_GLOCK18, CSW_FIVESEVEN, CSW_HEGRENADE, 0
};
new const GUNGAME_WEAPONS_CLASSIC[][] =
{
	"", "weapon_glock18", "weapon_usp",	"weapon_p228", "weapon_deagle", "weapon_fiveseven", "weapon_elite", "weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_mp5navy", "weapon_ump45", "weapon_p90", "weapon_galil", "weapon_famas",
	"weapon_ak47", "weapon_scout", "weapon_m4a1", "weapon_sg552", "weapon_aug", "weapon_m249", "weapon_awp", "weapon_sg550", "weapon_g3sg1", "weapon_hegrenade", "weapon_knife"
};
new const GUNGAME_WEAPONS_CLASSIC_CSW[] =
{
	0, CSW_GLOCK18, CSW_USP, CSW_P228, CSW_DEAGLE, CSW_FIVESEVEN, CSW_ELITE, CSW_M3, CSW_XM1014, CSW_TMP, CSW_MAC10, CSW_MP5NAVY, CSW_UMP45, CSW_P90, CSW_GALIL, CSW_FAMAS,
	CSW_AK47, CSW_SCOUT, CSW_M4A1, CSW_SG552, CSW_AUG, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1, CSW_HEGRENADE, 0
};
new const MEGA_GUNGAME_WEAPONS[][] =
{
	"", "weapon_g3sg1", "weapon_sg550", "weapon_awp", "weapon_scout", "weapon_m249", "weapon_aug", "weapon_sg552", "weapon_m4a1", "weapon_ak47", "weapon_galil", "weapon_famas", "weapon_mp5navy", "weapon_p90", "weapon_ump45", "weapon_mac10",
	"weapon_tmp", "weapon_xm1014", "weapon_m3", "weapon_deagle", "weapon_elite", "weapon_p228", "weapon_usp", "weapon_glock18", "weapon_fiveseven", "weapon_hegrenade", "weapon_knife",

	"weapon_fiveseven", "weapon_glock18", "weapon_usp",	"weapon_p228", "weapon_elite", "weapon_deagle", "weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_ump45", "weapon_p90", "weapon_mp5navy", "weapon_famas", "weapon_galil",
	"weapon_ak47", "weapon_m4a1", "weapon_sg552", "weapon_aug", "weapon_m249", "weapon_scout", "weapon_awp", "weapon_sg550", "weapon_g3sg1", "weapon_hegrenade", "weapon_knife"
};
new const MEGA_GUNGAME_WEAPONS_CSW[] =
{
	0, CSW_G3SG1, CSW_SG550, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_SG552, CSW_M4A1, CSW_AK47, CSW_GALIL, CSW_FAMAS, CSW_MP5NAVY, CSW_P90, CSW_UMP45, CSW_MAC10, CSW_TMP, CSW_XM1014, CSW_M3, CSW_DEAGLE, CSW_ELITE, CSW_P228, CSW_USP,
	CSW_GLOCK18, CSW_FIVESEVEN, CSW_HEGRENADE, 0,

	CSW_FIVESEVEN, CSW_GLOCK18, CSW_USP, CSW_P228, CSW_ELITE, CSW_DEAGLE, CSW_M3, CSW_XM1014, CSW_TMP, CSW_MAC10, CSW_UMP45, CSW_P90, CSW_MP5NAVY, CSW_FAMAS, CSW_GALIL, CSW_AK47, CSW_M4A1, CSW_SG552, CSW_AUG, CSW_M249, CSW_SCOUT, CSW_AWP,
	CSW_SG550, CSW_G3SG1, CSW_HEGRENADE, 0
};
new const MEGA_GUNGAME_LIGHTS[11] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'i', 'i'};

new g_IsConnected[MAX_USERS];
new g_IsAlive[MAX_USERS];
new g_PlayerName[MAX_USERS][33];
new g_PlayerIp[MAX_USERS][16];
new g_PlayerSteamId[MAX_USERS][35];
new g_PlayerModel[MAX_USERS][32];
new g_PlayerClassName[MAX_USERS][32];
new g_PlayerSolid[MAX_USERS];
new g_PlayerRestore[MAX_USERS];
new g_PlayerTeam[MAX_USERS];
new g_AccountId[MAX_USERS];
new g_AccountName[MAX_USERS][16];
new g_AccountPassword[MAX_USERS][34];
new g_AccountSince[MAX_USERS];
new g_AccountLastConnection[MAX_USERS];
new g_AccountAutoLogin[MAX_USERS];
new g_AccountVinc[MAX_USERS];
new g_AccountRegister[MAX_USERS];
new g_AccountLogged[MAX_USERS];
new g_AccountBanned[MAX_USERS];
new g_AccountBan_Admin[MAX_USERS][33];
new g_AccountBan_Start[MAX_USERS];
new g_AccountBan_Finish[MAX_USERS];
new g_AccountBan_Reason[MAX_USERS][128];
new g_LoadingData[MAX_USERS];
new g_LoadingData_Percent[MAX_USERS];
new g_AccountRank[MAX_USERS];
new g_DailyVisits[MAX_USERS];
new g_Consecutive_DailyVisits[MAX_USERS];
new g_ConnectedToday[MAX_USERS];
new g_Benefit[MAX_USERS];
new g_Class[MAX_USERS];
new g_ClassPetitionMode[MAX_USERS];
new g_ClassPetitionMode_Selected[MAX_USERS][7];
new g_Aura[MAX_USERS][4];
new g_Health[MAX_USERS];
new g_MaxHealth[MAX_USERS];
new Float:g_Speed[MAX_USERS];
new g_TypeWeapon[MAX_USERS];
new g_CurrentWeapon[MAX_USERS];
new g_LastWeapon[MAX_USERS];
new g_BlockSound[MAX_USERS];
new g_AmmoPacks[MAX_USERS];
new g_AmmoPacksDamage[MAX_USERS];
new g_AmmoPacksDamageNeed[MAX_USERS];
new g_AmmoPacksMult[MAX_USERS];
new g_Exp[MAX_USERS];
new g_ExpRest[MAX_USERS];
new g_ExpRestHud[MAX_USERS][16];
new g_ExpDamage[MAX_USERS];
new g_ExpDamageNeed[MAX_USERS];
new g_ExpMult[MAX_USERS];
new g_Level[MAX_USERS];
new Float:g_LevelPercent[MAX_USERS];
new g_Reset[MAX_USERS];
new Float:g_ResetPercent[MAX_USERS];
new g_Combo[MAX_USERS];
new Float:g_ComboDamageBullet[MAX_USERS];
new Float:g_ComboDamage[MAX_USERS];
new Float:g_ComboDamageNeed[MAX_USERS];
new g_ComboReward[MAX_USERS];
new Float:g_ComboTime[MAX_USERS];
new g_ComboZombieEnabled[MAX_USERS];
new g_ComboZombie[MAX_USERS];
new g_ComboZombieReward[MAX_USERS];
new g_Zombie[MAX_USERS];
new g_SpecialMode[MAX_USERS];
new g_SpecialMode_Alien[MAX_USERS];
new Float:g_SpecialMode_AlienOrigin[MAX_USERS][3];
new g_SpecialMode_Predator[MAX_USERS];
new g_ModeMA_Reward[MAX_USERS];
new g_ModeMA_Kills[MAX_USERS][MAX_USERS];
new g_ModeMA_ZombieKills[MAX_USERS];
new g_ModeMA_HumanKills[MAX_USERS];
new g_ModeMA_NemesisKills[MAX_USERS];
new g_ModeMA_SurvivorKills[MAX_USERS];
new g_ModeGG_Immunity[MAX_USERS];
new g_ModeGG_Level[MAX_USERS];
new g_ModeGG_Kills[MAX_USERS];
new g_ModeGG_Headshots[MAX_USERS];
new g_ModeGGCrazy_Level[MAX_USERS];
new g_ModeGGCrazy_ListLevel[MAX_USERS][26];
new g_ModeGGCrazy_HeLevel[MAX_USERS];
new g_ModeMGG_Health[MAX_USERS];
new g_ModeFvsJ_FreddyPower[MAX_USERS];
new g_ModeFvsJ_FreddyPowerType[MAX_USERS];
new g_ModeFvsJ_Jason[MAX_USERS];
new g_ModeFvsJ_JasonPower[MAX_USERS];
new g_ModeSynapsis_NemesisKill[MAX_USERS];
new g_ModeAvsp_AlienPower[MAX_USERS];
new g_ModeAvsp_PredatorPower[MAX_USERS];
new g_ModeDuelFinal_KillsTotal[MAX_USERS];
new g_ModeDuelFinal_Kills[MAX_USERS];
new g_ModeDuelFinal_KillsKnife[MAX_USERS];
new g_ModeDuelFinal_KillsAwp[MAX_USERS];
new g_ModeDuelFinal_KillsHE[MAX_USERS];
new g_ModeDuelFinal_KillsDeagle[MAX_USERS];
new g_ModeDuelFinal_KillsM3[MAX_USERS];
new g_ModeWesker_Laser[MAX_USERS];
new Float:g_ModeWesker_LaserLast[MAX_USERS];
new g_ModeSniperElite_Speed[MAX_USERS];
new g_ModeJason_Teleport[MAX_USERS];
new g_ModeNemesis_Bazooka[MAX_USERS];
new Float:g_ModeNemesis_BazookaLast[MAX_USERS];
new g_ModeAssassin_PowerGlow[MAX_USERS];
new g_ModeAnnihilator_Kills[MAX_USERS];
new g_ModeAnnihilator_Acerts[MAX_USERS];
new Trie:g_tModeAnnihilator_Acerts;
new g_ModeSniper_Power[MAX_USERS];
new g_ModeGrunt_Reward[MAX_USERS];
new g_ModeGrunt_Flash[MAX_USERS];
new g_ModeTribal_Damage[MAX_USERS];
new g_LastHuman[MAX_USERS];
new g_LastZombie[MAX_USERS];
new g_FirstRespawn[MAX_USERS];
new g_RespawnAsZombie[MAX_USERS];
new g_DeadTimes[MAX_USERS];
new g_Weapons[MAX_USERS][structIdWeapons];
new g_WeaponPrimary_Current[MAX_USERS];
new g_WeaponSecondary_Current[MAX_USERS];
new g_WeaponData[MAX_USERS][31][structIdWeaponDatas];
new g_WeaponSkills[MAX_USERS][31][structIdWeaponSkills];
new g_WeaponModel[MAX_USERS][31];
new g_WeaponSave[MAX_USERS][31];
new g_WeaponTime[MAX_USERS];
new g_WeaponSecondaryAutofire[MAX_USERS];
new g_NitroBomb[MAX_USERS];
new g_SuperNovaBomb[MAX_USERS];
new g_ImmunityBomb[MAX_USERS];
new g_DrugBomb[MAX_USERS];
new g_DrugBombCount[MAX_USERS];
new g_DrugBombMove[MAX_USERS];
new g_HyperNovaBomb[MAX_USERS];
new g_BubbleBomb[MAX_USERS];
new g_InBubble[MAX_USERS];
new g_CanBuy[MAX_USERS];
new g_ExtraItem_Cost[MAX_USERS][structIdExtraItems];
new g_ExtraItem_Count[MAX_USERS][structIdExtraItems];
new Trie:g_tExtraItem_Invisibility;
new Trie:g_tExtraItem_KillBomb;
new Trie:g_tExtraItem_MolotovBomb;
new Trie:g_tExtraItem_AntidoteBomb;
new Trie:g_tExtraItem_Antidote;
new Trie:g_tExtraItem_ZombieMadness;
new Trie:g_tExtraItem_InfectionBomb;
new Trie:g_tExtraItem_ReduceDamage;
new Trie:g_tExtraItem_PainShock;
new Trie:g_tExtraItem_Petrification;
new g_LongJump[MAX_USERS];
new g_InJump[MAX_USERS];
new g_UnlimitedClip[MAX_USERS];
new g_PrecisionPerfect[MAX_USERS];
new g_KillBomb[MAX_USERS];
new g_MolotovBomb[MAX_USERS];
new g_AntidoteBomb[MAX_USERS];
new g_NightVision[MAX_USERS];
new g_ReduceDamage[MAX_USERS];
new g_Madness_LastUse[MAX_USERS];
new g_Painshock[MAX_USERS];
new g_Painshock_Chite[MAX_USERS];
new g_Painshock_LastUse[MAX_USERS];
new g_Invisibility_Vrg[MAX_USERS];
new g_Petrification[MAX_USERS];
new g_Petrification_Round[MAX_USERS];
new g_Models[MAX_USERS][sizeof(MODELS)];
new g_ModelSelected[MAX_USERS][structIdModelClasses];
new g_Difficult[MAX_USERS][structIdDifficultsClasses];
new g_Points[MAX_USERS][structIdPoints];
new g_PointsLose[MAX_USERS][structIdPoints];
new g_PointsMult[MAX_USERS];
new g_Habs[MAX_USERS][structIdHabs];
new g_InductionChance[MAX_USERS];
new g_AchievementPage[MAX_USERS][structIdAchievementClasses];
new g_Achievement[MAX_USERS][structIdAchievements];
new g_AchievementName[MAX_USERS][structIdAchievements][33];
new g_AchievementUnlocked[MAX_USERS][structIdAchievements];
new g_AchievementInt[MAX_USERS][structIdAchievements];
new g_AchievementTotal[MAX_USERS];
new Float:g_AchievementTimeLink[MAX_USERS];
new g_Achievement_InfectsRound[MAX_USERS];
new g_Achievement_InfectsRoundId[MAX_USERS][MAX_USERS];
new g_Achievement_FuryConsecutive[MAX_USERS];
new g_Achievement_InfectsWithFury[MAX_USERS];
new g_Achievement_InfectsWithMaxHP[MAX_USERS];
new g_Achievement_MaxBet[MAX_USERS];
new g_Achievement_WeskerHead[MAX_USERS];
new g_Achievement_SniperAwp[MAX_USERS];
new g_Achievement_SniperScout[MAX_USERS];
new g_Achievement_SniperHead[MAX_USERS];
new g_Achievement_SniperNoDmg[MAX_USERS];
new g_Achievement_AnnKnife[MAX_USERS];
new g_Achievement_AnniMac10[MAX_USERS];
new g_Achievement_AnnBazooka[MAX_USERS];
new g_AchievementSecret_Terrorist[MAX_USERS];
new g_AchievementSecret_Bullets[MAX_USERS];
new g_AchievementSecret_BulletsOk[MAX_USERS];
new g_AchievementSecret_FuryInRound[MAX_USERS];
new g_AchievementSecret_DmgNem[MAX_USERS];
new g_AchievementSecret_DmgNemOrd[MAX_USERS];
new Float:g_AchievementSecret_Cortamambo[MAX_USERS];
new g_AchievementSecret_Hitman[MAX_USERS];
new g_AchievementSecret_MasZombies[MAX_USERS];
new g_AchievementSecret_AllItems[MAX_USERS][structIdExtraItems];
new g_AchievementSecret_Nemesis[MAX_USERS];
new g_AchievementSecret_Resistencia[MAX_USERS];
new g_AchievementSecret_Albert[MAX_USERS];
new g_AchievementSecret_AplZombie[MAX_USERS];
new g_AchievementSecret_AsesinoTurn[MAX_USERS];
new g_AchievementSecret_Predator[MAX_USERS];
new g_AchievementSecret_Alien[MAX_USERS];
new Float:g_AchievementSecret_Progress[MAX_USERS][6];
new g_ClanSlot[MAX_USERS];
new g_Clan[MAX_USERS][structClans]; // 33
new g_ClanMembers[MAX_USERS][MAX_CLAN_MEMBERS][structClansMembers]; // 33
new g_ClanPerks[MAX_USERS][structIdClanPerks]; // 33
new g_ClanCombo[MAX_USERS]; // 33
new Float:g_ClanComboDamage[MAX_USERS]; // 33
new Float:g_ClanComboDamageNeed[MAX_USERS]; // 33
new g_ClanComboReward[MAX_USERS]; // 33
new Float:g_ClanComboTime[MAX_USERS]; // 33
new g_ClanInvitations[MAX_USERS];
new g_ClanInvitationsId[MAX_USERS][MAX_USERS];
new g_TempClanName[MAX_USERS][15];
new g_TempClanDeposit[MAX_USERS];
new Float:g_Clan_QueryFlood[MAX_USERS];
new g_HatEnt[MAX_USERS];
new g_HatId[MAX_USERS];
new g_HatNext[MAX_USERS];
new g_Hat[MAX_USERS][structIdHats];
new g_HatUnlocked[MAX_USERS][structIdHats];
new g_HatTotal[MAX_USERS];
new Float:g_HatTimeLink[MAX_USERS];
new g_Hat_Devil[MAX_USERS];
new g_Hat_Earth[MAX_USERS];
new g_AmuletsInt[MAX_USERS][MAX_AMULETS][6];
new g_AmuletsName[MAX_USERS][MAX_AMULETS][64];
new g_AmuletsNameMenu[MAX_USERS][64];
new g_AmuletEquip[MAX_USERS];
new g_AmuletNextEquip[MAX_USERS];
new g_AmuletCustomCreated[MAX_USERS];
new g_AmuletCustomCost[MAX_USERS];
new g_AmuletCustomName[MAX_USERS][64];
new g_AmuletCustomNameFake[MAX_USERS][64];
new g_AmuletCustom[MAX_USERS][structIdAmuletCustoms];
new g_UserOption_Color[MAX_USERS][structIdColorsType][3];
new Float:g_UserOption_PositionHud[MAX_USERS][structIdHudsType][3];
new g_UserOption_EffectHud[MAX_USERS][structIdHudsType];
new g_UserOption_MinimizeHud[MAX_USERS][structIdHudsType];
new g_UserOption_AbreviateHud[MAX_USERS][structIdHudsType];
new g_UserOption_ChatMode[MAX_USERS];
new g_UserOption_Invis[MAX_USERS];
new g_UserOption_ClanChat[MAX_USERS];
new Float:g_StatsDamage[MAX_USERS][2];
new g_Stats[MAX_USERS][structIdStats];
new g_PlayedTime[MAX_USERS][structIdTimePlayed];
new g_SysTime_Connect[MAX_USERS];
new g_BurningDuration[MAX_USERS];
new g_BurningDurationOwner[MAX_USERS];
new g_Frozen[MAX_USERS];
new Float:g_FrozenGravity[MAX_USERS];
new g_SlowDown[MAX_USERS];
new g_Immunity[MAX_USERS];
new g_HeadZombie[MAX_USERS][structIdHeadZombies];
new Float:g_HeadZombieLastTouch[MAX_USERS];
new g_BuyStuff[MAX_USERS];
new g_Grab[MAX_USERS];
new Float:g_GrabDistance[MAX_USERS];
new Float:g_GrabGravity[MAX_USERS];
new g_MiniGames_Number[MAX_USERS];
new g_MiniGames_NumberFake = 0;
new g_MenuPage[MAX_USERS][structIdPages];
new g_MenuData[MAX_USERS][structIdDatas];
new g_ConvertZombie[MAX_USERS];
new g_ModeL4D2_ZobieHealth[MAX_USERS];
new g_ModeL4D2_ZombieAcerts[MAX_USERS];
new g_ModeL4D2_Human[MAX_USERS];
new g_MayorMuerte[MAX_USERS];
new Float:g_KnockbackVelocity[MAX_USERS][3];

new g_MapName[32];
new g_fwdSpawn;
new g_fwdPrecacheSound;
new g_fwdUpdateClientDataPost;
new g_Sprite_Trail;
new g_Sprite_ShockWave;
new g_Sprite_Flame;
new g_Sprite_Smoke;
new g_Sprite_Glass;
new g_Sprite_Nitro;
new g_Sprite_SuperNova;
new g_Sprite_Explosion;
new g_Sprite_Molotov;
new g_Sprite_Regeneration;
new g_Sprite_ColorsBalls[sizeof(SPRITE_COLORS_BALLS)];
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;
new HamHook:g_HamPlayerPreThink;
new HamHook:g_HamTouchWall;
new HamHook:g_HamTouchBreakeable;
new HamHook:g_HamTouchWorldspawn;
new g_Message_Money;
new g_Message_CurWeapon;
new g_Message_FlashBat;
new g_Message_Flashlight;
new g_Message_NVGToggle;
new g_Message_WeapPickup;
new g_Message_AmmoPickup;
new g_Message_TextMsg;
new g_Message_SendAudio;
new g_Message_TeamInfo;
new g_Message_StatusIcon;
new g_Message_ShowMenu;
new g_Message_VGUIMenu;
new g_Message_DeathMsg;
new g_Message_ScoreInfo;
new g_Message_ScoreAttrib;
new g_Message_SetFOV;
new g_Message_ScreenFade;
new g_Message_ScreenShake;
new g_Message_HideWeapon;
new g_Message_Crosshair;
new g_MaxPlayers;
new g_HudSync_General;
new g_HudSync_Combo;
new g_HudSync_ClanCombo;
new g_pCvar_Delay;
new g_pCvar_CanUseMinigames;
new g_pCvar_DropHeadZombie;
new g_Lights[2];
new Float:g_Spawns[64][3];
new g_SpawnsCount;
new Handle:g_SqlTuple;
new Handle:g_SqlConnection;
new g_SqlErrors[MAX_FMT_LENGTH];
new g_SqlQuery[2048];
new g_GlobalRank = 0;
new Float:g_ModelsTargetTime;
new Float:g_TeamsTargetTime;
new g_SwitchingTeams;
new g_ScoreHumans = 0;
new g_ScoreZombies = 0;
new g_LogSay;
new g_NewRound;
new g_VirusT;
new g_EndRound;
new g_EndRound_Forced;
new g_Mode;
new g_LastMode;
new g_StartMode[2];
new g_StartMode_Force = 0;
new g_ModeCount[structIdModes];
new g_ModeCountAdmin[structIdModes];
new g_ModeInfection_Systime;
new g_ModeArmageddon_Notice;
new g_ModeArmageddon_Bubbles;
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
new g_ModeSynapsis_Id[3];
new g_ModeTribal_Id[2];
new g_ModeFvsJ_Humans = 0;
new g_ModeFvsJ_Id[4];
new g_ModeDuelFinal = 0;
new g_ModeDuelFinal_Type = 0;
new g_ModeDuelFinal_TypeName[32];
new g_ModeDuelFinal_First = 0;
new g_ModeSniperElite_ZombieLeft = 0;
new g_ModeSniper_Id[4];
new g_ModeAssassin_RewardAssassin = 0;
new g_ModeAssassin_RewardHumans = 0;
new Float:g_ModeSniper_Damage;
new g_ModeGrunt_NoDamage = 0;
new g_ModeGrunt_RewardGlobal = 0;
new g_ModeGrunt_Power = 0;
new g_ModeTribal_Power = 0;
new g_ModeL4D2_ZombiesTotal = 0;
new g_ModeL4D2_Zombies = 0;
new g_ExtraItem_LimitMap[structIdExtraItems];
new g_LastAchUnlocked = -1;
new g_LastAchUnlockedPage = 0;
new g_LastAchUnlockedClass = 0;
new g_AchievementTempIds;
new g_LastHatUnlocked = -1;
new g_AmuletCustomConfirm[32];
new g_HappyTime;
new g_EventModes;
new g_EventMode_MegaArmageddon;
new g_EventMode_GunGame;
new g_MaxComboHumanMap;
new g_MaxComboZombieMap;
new g_HeadZombieSys;
new g_PetitionModeSys;
new g_PlayerBonus = 0;
new g_DataSaved = 0;
new g_MiniGame_Semiclip = 0;
new g_MiniGame_Weapons = 0;
new g_MiniGame_NoMove = 0;
new g_MiniGame_Habs = 0;
new g_MiniGame_Respawn = 0;
new g_MiniGameTejo_On = 0;
new g_MiniGameTejo_Pos = 0;
new Float:g_MiniGameTejo_HeadZombie[3];
new Float:g_MiniGameTejo_Distance[33];
new Float:g_MiniGameTejo_DistanceId[33];
new g_MiniGameBomba_On = 0;
new g_MiniGameBomba_Level = 0;
new g_MiniGameBomba_Drop = 0;
new g_MiniGameLaser_On = 0;
new g_MiniGameLaser_UserId = 0;
new g_MiniGameLaser_Level = 0;
new g_MiniGameLaser_Laps = 0;
new g_MiniGameLaser_Line = 0;
new Float:g_MiniGameLaser_360 = 0.0;

#define isUserValid(%0) (1 <= %0 <= g_MaxPlayers)
#define isUserValidConnected(%0) (isUserValid(%0) && g_IsConnected[%0])
#define isUserValidAlive(%0) (isUserValid(%0) && g_IsAlive[%0])

// **************************************************
//		[Init Functions]
// **************************************************
public plugin_precache()
{
	new sBuffer[128];
	new iEnt;

	get_mapname(g_MapName, charsmax(g_MapName));
	strtolower(g_MapName);

	g_fwdSpawn = register_forward(FM_Spawn, "fwd__SpawnPre", 0);
	g_fwdPrecacheSound = register_forward(FM_PrecacheSound, "fwd__PrecacheSoundPre", 0);
	register_forward(FM_Sys_Error, "fwd__SysErrorPre", 0);
	register_forward(FM_GameShutdown, "fwd__GameShutdownPre", 0);

	iEnt = create_entity("hostage_entity");
	if(is_valid_ent(iEnt))
	{
		entity_set_origin(iEnt, Float:{8192.0, 8192.0, 8192.0});
		DispatchSpawn(iEnt);
	}

	iEnt = create_entity("func_buyzone");
	if(is_valid_ent(iEnt))
	{
		entity_set_origin(iEnt, Float:{8192.0, 8192.0, 8192.0});
		DispatchSpawn(iEnt);
	}

	for(new i = 0; i < sizeof(PLAYER_MODEL_SURVIVOR); ++i)
	{
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_SURVIVOR[i], PLAYER_MODEL_SURVIVOR[i]);
		precache_model(sBuffer);

		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%sT.mdl", PLAYER_MODEL_SURVIVOR[i], PLAYER_MODEL_SURVIVOR[i]);
		if(file_exists(sBuffer)) precache_model(sBuffer);
	}

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_WESKER, PLAYER_MODEL_WESKER);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_SNIPER, PLAYER_MODEL_SNIPER);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_JASON, PLAYER_MODEL_JASON);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_PREDATOR, PLAYER_MODEL_PREDATOR);
	precache_model(sBuffer);

	for(new i = 0; i < sizeof(PLAYER_MODEL_NEMESIS); ++i)
	{
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_NEMESIS[i], PLAYER_MODEL_NEMESIS[i]);
		precache_model(sBuffer);

		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%sT.mdl", PLAYER_MODEL_NEMESIS[i], PLAYER_MODEL_NEMESIS[i]);
		if(file_exists(sBuffer)) precache_model(sBuffer);
	}

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_ASSASSIN, PLAYER_MODEL_ASSASSIN);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_ANNIHILATOR, PLAYER_MODEL_ANNIHILATOR);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_FREDDY, PLAYER_MODEL_FREDDY);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_ALIEN, PLAYER_MODEL_ALIEN);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_GRUNT, PLAYER_MODEL_GRUNT);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_TRIBAL, PLAYER_MODEL_TRIBAL);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%sT.mdl", PLAYER_MODEL_TRIBAL, PLAYER_MODEL_TRIBAL);
	if(file_exists(sBuffer)) precache_model(sBuffer);

	for(new i = 0; i < sizeof(PLAYER_MODEL_L4D2); ++i)
	{
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_L4D2[i], PLAYER_MODEL_L4D2[i]);
		precache_model(sBuffer);

		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%sT.mdl", PLAYER_MODEL_L4D2[i], PLAYER_MODEL_L4D2[i]);
		if(file_exists(sBuffer)) precache_model(sBuffer);
	}

	for(new i = 0; i < sizeof(KNIFE_vMODEL_JASON); ++i)
		precache_model(KNIFE_vMODEL_JASON[i]);
	precache_model(KNIFE_vMODEL_NEMESIS);
	precache_model(KNIFE_vMODEL_ASSASSIN);
	precache_model(KNIFE_vMODEL_ANNIHILATOR);
	precache_model(KNIFE_vMODEL_FREDDY);
	precache_model(KNIFE_vMODEL_ALIEN);
	for(new i = 0; i < sizeof(GRENADE_MODEL_INFECTION); ++i)
		precache_model(GRENADE_MODEL_INFECTION[i]);
	precache_model(GRENADE_vMODEL_FIRE);
	precache_model(GRENADE_vMODEL_NOVA);
	precache_model(GRENADE_vMODEL_FLARE);
	precache_model(GRENADE_vMODEL_NITRO);
	precache_model(GRENADE_vMODEL_SUPERNOVA);
	precache_model(GRENADE_vMODEL_IMMUNITY);
	for(new i = 0; i < sizeof(GRENADE_MODEL_DRUG); ++i)
		precache_model(GRENADE_MODEL_DRUG[i]);
	for(new i = 0; i < sizeof(GRENADE_MODEL_HYPERNOVA); ++i)
		precache_model(GRENADE_MODEL_HYPERNOVA[i]);
	for(new i = 0; i < sizeof(GRENADE_MODEL_BUBBLE); ++i)
		precache_model(GRENADE_MODEL_BUBBLE[i]);
	precache_model(GRENADE_vMODEL_KILL);
	precache_model(GRENADE_vMODEL_MOLOTOV);
	precache_model(GRENADE_vMODEL_ANTIDOTE);
	precache_model(BAZOOKA_vMODEL);
	precache_model(BAZOOKA_pMODEL);

	precache_model(MODEL_BUBBLE);
	precache_model(MODEL_HEADZOMBIE);
	precache_model(MODEL_ROCKET);
	precache_model(MODEL_SKULL);

	precache_sound(SOUND_ARMOR_HIT);
	precache_sound(SOUND_AMMO_PICKUP);
	precache_sound(SOUND_WIN_HUMANS);
	precache_sound(SOUND_WIN_ZOMBIES);
	precache_sound(SOUND_WIN_NO_ONE);
	for(new i = 0; i < sizeof(SOUND_ROUND_GENERAL); ++i)
		precache_sound(SOUND_ROUND_GENERAL[i]);
	for(new i = 0; i < sizeof(SOUND_ROUND_SURVIVOR); ++i)
		precache_sound(SOUND_ROUND_SURVIVOR[i]);
	for(new i = 0; i < sizeof(SOUND_ROUND_NEMESIS); ++i)
		precache_sound(SOUND_ROUND_NEMESIS[i]);
	precache_sound(SOUND_ROUND_ASSASSIN);
	precache_sound(SOUND_ROUND_ARMAGEDDON);
	precache_generic(SOUND_ROUND_MEGA_ARMAGEDDON);
	precache_generic(SOUND_ROUND_FVSJ);
	precache_sound(SOUND_ROUND_GUNGAME);
	precache_sound(SOUND_ROUND_SPECIAL);
	precache_sound(SOUND_ROUND_L4D2);
	precache_sound(SOUND_HUMAN_ANTIDOTE);
	precache_sound(SOUND_WESKER_LASER);
	for(new i = 0; i < sizeof(SOUND_JASON_CHAINSAW); ++i)
		precache_sound(SOUND_JASON_CHAINSAW[i]);
	for(new i = 0; i < sizeof(SOUND_ZOMBIE_PAIN); ++i)
		precache_sound(SOUND_ZOMBIE_PAIN[i]);
	for(new i = 0; i < sizeof(SOUND_SPECIALMODE_PAIN); ++i)
		precache_sound(SOUND_SPECIALMODE_PAIN[i]);
	for(new i = 0; i < sizeof(SOUND_ZOMBIE_KNIFE); ++i)
		precache_sound(SOUND_ZOMBIE_KNIFE[i]);
	for(new i = 0; i < sizeof(SOUND_ZOMBIE_INFECT); ++i)
		precache_sound(SOUND_ZOMBIE_INFECT[i]);
	for(new i = 0; i < sizeof(SOUND_ZOMBIE_ALERT); ++i)
		precache_sound(SOUND_ZOMBIE_ALERT[i]);
	precache_sound(SOUND_ZOMBIE_MADNESS);
	for(new i = 0; i < sizeof(SOUND_ZOMBIE_DIE); ++i)
		precache_sound(SOUND_ZOMBIE_DIE[i]);
	for(new i = 0; i < sizeof(SOUND_ZOMBIE_BURN); ++i)
		precache_sound(SOUND_ZOMBIE_BURN[i]);
	precache_sound(SOUND_NADE_INFECT_EXPLO);
	for(new i = 0; i < sizeof(SOUND_NADE_INFECT_EXPLO_PLAYER); ++i)
		precache_sound(SOUND_NADE_INFECT_EXPLO_PLAYER[i]);
	precache_sound(SOUND_NADE_FIRE_EXPLO);
	precache_sound(SOUND_NADE_NOVA_EXPLO);
	precache_sound(SOUND_NADE_NOVA_PLAYER);
	precache_sound(SOUND_NADE_NOVA_BREAK);
	precache_sound(SOUND_NADE_NOVA_SLOWDOWN);
	precache_sound(SOUND_NADE_FLARE_EXPLO);
	precache_sound(SOUND_NADE_MOLOTOV_EXPLO);
	precache_sound(SOUND_NADE_BUBBLE_EXPLO);
	for(new i = 0; i < sizeof(SOUND_BAZOOKA); ++i)
		precache_sound(SOUND_BAZOOKA[i]);
	precache_sound(SOUND_LEVEL_UP);

	for(new i = 0; i < 31; ++i)
	{
		for(new j = 0; j < 9; ++j)
		{
			if(WEAPON_MODELS[i][j][weaponModelPath][0])
			{
				precache_model(WEAPON_MODELS[i][j][weaponModelPath]);
				continue;
			}

			break;
		}
	}

	for(new i = 0; i < sizeof(MODELS); ++i)
	{
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", MODELS[i][modelPrecache], MODELS[i][modelPrecache]);
		precache_model(sBuffer);

		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%sT.mdl", MODELS[i][modelPrecache], MODELS[i][modelPrecache]);
		if(file_exists(sBuffer)) precache_model(sBuffer);

		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", MODELS[i][modelPrecache], MODELS[i][modelPrecache]);
		if(file_exists(sBuffer)) precache_model(sBuffer);
	}

	// START - MODELS L4D2
	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_L4D2_HMS, PLAYER_MODEL_L4D2_HMS);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_L4D2_ZMS, PLAYER_MODEL_L4D2_ZMS);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", PLAYER_MODEL_L4D2_ZMS, PLAYER_MODEL_L4D2_ZMS);
	if(file_exists(sBuffer)) precache_model(sBuffer);
	// END

	for(new i = 0; i < sizeof(COMBO_HUMAN); ++i)
		precache_sound(COMBO_HUMAN[i][comboSound]);

	for(new i = 0; i < structIdHats; ++i)
	{
		if(HATS[i][hatModel][0])
			precache_model(HATS[i][hatModel]);
	}
	precache_model(HAT_MANAGER_MODEL);

	g_Sprite_Trail = precache_model("sprites/dg/zp6/trail_00.spr");
	g_Sprite_ShockWave = precache_model("sprites/shockwave.spr");
	g_Sprite_Flame = precache_model("sprites/dg/zp6/flame_00.spr");
	g_Sprite_Smoke = precache_model("sprites/black_smoke3.spr");
	g_Sprite_Glass = precache_model("models/glassgibs.mdl");
	g_Sprite_Nitro = precache_model("sprites/dg/zp6/nitrogeno_00.spr");
	g_Sprite_SuperNova = precache_model("sprites/dg/zp6/nova_00.spr");
	g_Sprite_Explosion = precache_model("sprites/fexplo.spr");
	g_Sprite_Molotov = precache_model("sprites/dg/zp6/molotov_00.spr");
	g_Sprite_Regeneration = precache_model("sprites/dg/zp6/regeneration_00.spr");
	for(new i = 0; i < sizeof(SPRITE_COLORS_BALLS); ++i)
		g_Sprite_ColorsBalls[i] = precache_model(SPRITE_COLORS_BALLS[i]);
	precache_model("sprites/animglow01.spr");
}

public plugin_init()
{
	if(!dg_check_community())
		return;

	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	register_event("HLTV", "event__HLTV", "a", "1=0", "2=0");
	register_event("30", "event__Intermission", "a");
	register_event("AmmoX", "event__AmmoX", "be");
	register_event("Health", "event__Health", "be");

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

	RegisterHam(Ham_Spawn, "player", "ham__PlayerSpawnPost", 1);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPre", 0);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPost", 1);
	RegisterHam(Ham_TakeDamage, "player", "ham__PlayerTakeDamagePre", 0);
	RegisterHam(Ham_TakeDamage, "player", "ham__PlayerTakeDamagePost", 1);
	RegisterHam(Ham_TraceAttack, "player", "ham__PlayerTraceAttackPre", 0);
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "ham__PlayerResetMaxSpeedPost", 1);
	RegisterHam(Ham_Use, "func_tank", "ham__UseStationaryPre", 0);
	RegisterHam(Ham_Use, "func_tankmortar", "ham__UseStationaryPre", 0);
	RegisterHam(Ham_Use, "func_tankrocket", "ham__UseStationaryPre", 0);
	RegisterHam(Ham_Use, "func_tanklaser", "ham__UseStationaryPre", 0);
	RegisterHam(Ham_Use, "func_tank", "ham__UseStationaryPost", 1);
	RegisterHam(Ham_Use, "func_tankmortar", "ham__UseStationaryPost", 1);
	RegisterHam(Ham_Use, "func_tankrocket", "ham__UseStationaryPost", 1);
	RegisterHam(Ham_Use, "func_tanklaser", "ham__UseStationaryPost", 1);
	RegisterHam(Ham_Use, "func_pushable", "ham__UsePushablePre", 0);
	RegisterHam(Ham_Touch, "weaponbox", "ham__TouchWeaponPre", 0);
	RegisterHam(Ham_Touch, "armoury_entity", "ham__TouchWeaponPre", 0);
	RegisterHam(Ham_Touch, "weapon_shield", "ham__TouchWeaponPre", 0);
	RegisterHam(Ham_Touch, "player", "ham__TouchPlayerPost", 1);
	RegisterHam(Ham_Think, "grenade", "ham__ThinkGrenadePre", 0);
	RegisterHam(Ham_Player_PreThink, "player", "ham__PlayerPreThinkPre", 0);
	DisableHamForward(g_HamPlayerPreThink = RegisterHam(Ham_Player_PreThink, "player", "ham__PlayerPreThinkPost", 1));
	RegisterHam(Ham_Player_PostThink, "player", "ham__PlayerPostThinkPre", 0);
	DisableHamForward(g_HamTouchWall = RegisterHam(Ham_Touch, "func_wall", "ham__TouchWallPre", 0));
	DisableHamForward(g_HamTouchBreakeable = RegisterHam(Ham_Touch, "func_breakable", "ham__TouchWallPre", 0));
	DisableHamForward(g_HamTouchWorldspawn = RegisterHam(Ham_Touch, "worldspawn", "ham__TouchWallPre", 0));
	RegisterHam(Ham_Player_Jump, "player", "ham__PlayerJumpPre", 0);
	RegisterHam(Ham_Player_Duck, "player", "ham__PlayerDuckPre", 0);

	for(new i = 1; i < sizeof(WEAPON_ENT_NAMES); ++i)
	{
		if(WEAPON_ENT_NAMES[i][0])
		{
			if(i != CSW_C4 && i != CSW_HEGRENADE && i != CSW_FLASHBANG && i != CSW_SMOKEGRENADE && i != CSW_SG550 && i != CSW_G3SG1)
			{
				RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_ENT_NAMES[i], "ham__WeaponPrimaryAttackPost", 1);

				if(i == CSW_KNIFE)
					RegisterHam(Ham_Weapon_SecondaryAttack, WEAPON_ENT_NAMES[i], "ham__WeaponSecondaryAttackPost", 1);
				else
				{
					RegisterHam(Ham_Item_AttachToPlayer, WEAPON_ENT_NAMES[i], "ham__ItemAttachToPlayerPre", 0);
					
					if(i != CSW_M3 && i != CSW_XM1014)
						RegisterHam(Ham_Item_PostFrame, WEAPON_ENT_NAMES[i], "ham__ItemPostFramePre", 0);
					else
					{
						RegisterHam(Ham_Item_PostFrame, WEAPON_ENT_NAMES[i], "ham__ShotgunPostFramePre", 0);
						RegisterHam(Ham_Weapon_WeaponIdle, WEAPON_ENT_NAMES[i], "ham__ShotgunWeaponIdlePre", 0);
					}
				}
			}

			RegisterHam(Ham_Item_Deploy, WEAPON_ENT_NAMES[i], "ham__ItemDeployPost", 1);
		}
	}

	register_touch("grenade", "*", "touch__AllGrenade");
	register_touch(ENT_CLASSNAME_ROCKET, "*", "touch__AllRocket");
	register_touch(ENT_CLASSNAME_HEADZOMBIE, "player", "touch__PlayerHeadZombie");

	formatex(g_AmuletCustomConfirm, charsmax(g_AmuletCustomConfirm), "zp_ac_confirm %c%c%c", random_num('a', 'z'), random_num('a', 'z'), random_num('a', 'z'));

	register_clcmd("CREAR_CUENTA", "clcmd__CreateAccount");
	register_clcmd("CREAR_CLAVE", "clcmd__CreatePassword");
	register_clcmd("CONFIRMAR_CLAVE", "clcmd__ConfirmPassword");
	register_clcmd("IDENTIFICAR_CUENTA", "clcmd__LoginAccount");
	register_clcmd("IDENTIFICAR_CLAVE", "clcmd__LoginPassword");
	register_clcmd("CREAR_CLAN", "clcmd__CreateClan");
	register_clcmd("INGRESAR_NOMBRE_AMULETO", "clcmd__EnterAmuletCustomName");
	register_clcmd("INGRESAR_NUMERO_AL_AZAR", "clcmd__EnterRandomNum");

	register_clcmd("say /modo", "clcmd__NextModeSay");
	register_clcmd("say /nextmode", "clcmd__NextModeSay");
	register_clcmd("say /rank", "clcmd__Rank");
	register_clcmd("say /mult", "clcmd__Mult");
	register_clcmd("say /invis", "clcmd__Invis");
	register_clcmd("say /spec", "clcmd__Spectator");
	register_clcmd("say /mg", "clcmd__MiniGames");

	register_clcmd("+grab", "clcmd__GrabOn");
	register_clcmd("-grab", "clcmd__GrabOff");

	for(new i = 0; i < sizeof(BLOCK_COMMANDS); ++i)
		register_clcmd(BLOCK_COMMANDS[i], "clcmd__BlockCommands");
	register_clcmd("nightvision", "clcmd__Nightvision");
	register_clcmd("chooseteam", "clcmd__ChangeTeam");
	register_clcmd("jointeam", "clcmd__ChangeTeam");
	register_clcmd("menuselect", "clcmd__MenuSelect");
	register_clcmd("joinclass", "clcmd__MenuSelect");
	register_clcmd("radio1", "clcmd__Radio1");
	register_clcmd("radio2", "clcmd__Radio2");
	register_clcmd("drop", "clcmd__Drop");
	register_clcmd("say", "clcmd__Say");
	register_clcmd("say_team", "clcmd__SayTeam");

	register_clcmd("zp_save_all", "clcmd__SaveAll");
	register_clcmd("zp_health", "clcmd__Health");
	register_clcmd("zp_aps", "clcmd__APs");
	register_clcmd("zp_exp", "clcmd__Exp");
	register_clcmd("zp_level", "clcmd__Level");
	register_clcmd("zp_reset", "clcmd__Reset");
	register_clcmd("zp_points", "clcmd__Points");
	register_clcmd("zp_achievements", "clcmd__Achievements");
	register_clcmd("zp_hats", "clcmd__Hats");
	register_clcmd("zp_ban", "clcmd__Ban");
	register_clcmd("zp_unban", "clcmd__UnBan");
	register_clcmd("zp_infection", "clcmd__Modes");
	register_clcmd("zp_plague", "clcmd__Modes");
	register_clcmd("zp_armageddon", "clcmd__Modes");
	register_clcmd("zp_mega_armageddon", "clcmd__Modes");
	register_clcmd("zp_gungame", "clcmd__Modes");
	register_clcmd("zp_mega_gungame", "clcmd__Modes");
	register_clcmd("zp_fvsj", "clcmd__Modes");
	register_clcmd("zp_synapsis", "clcmd__Modes");
	register_clcmd("zp_avsp", "clcmd__Modes");
	register_clcmd("zp_duel_final", "clcmd__Modes");
	register_clcmd("zp_drunk", "clcmd__Modes");
	register_clcmd("zp_sniper", "clcmd__Modes");
	register_clcmd("zp_tribal", "clcmd__Modes");
	register_clcmd("zp_l4d2", "clcmd__Modes");
	register_clcmd("zp_respawn", "clcmd__Respawn");
	register_clcmd("zp_zombie", "clcmd__Zombie");
	register_clcmd("zp_human", "clcmd__Human");
	register_clcmd("zp_survivor", "clcmd__Survivor");
	register_clcmd("zp_wesker", "clcmd__Wesker");
	register_clcmd("zp_sniper_elite", "clcmd__SniperElite");
	register_clcmd("zp_jason", "clcmd__Jason");
	register_clcmd("zp_nemesis", "clcmd__Nemesis");
	register_clcmd("zp_assassin", "clcmd__Assassin");
	register_clcmd("zp_annihilator", "clcmd__Annihilator");
	register_clcmd("zp_grunt", "clcmd__Grunt");
	register_clcmd("zp_next_mode", "clcmd__NextModeConsole");
	register_clcmd("zp_ac_create", "clcmd__AmuletCustomCreate");
	register_clcmd(g_AmuletCustomConfirm, "clcmd__AmuletCustomConfirm");
	register_clcmd("zp_clans", "clcmd__Clans");
	register_clcmd("zp_mg_number", "clcmd__GkNumber");

	register_impulse(OFF_IMPULSE_FLASHLIGHT, "impulse__FlashLight");
	register_impulse(OFF_IMPULSE_SPRAY, "impulse__Spray");

	oldmenu_register();

	register_menu("Hab Trade Menu", KEYSMENU, "menu__HabTrade");
	register_menu("Hab Info Reset EI Menu", KEYSMENU, "menu__HabInfoResetEI");
	register_menu("1 Clan Menu", KEYSMENU, "menu__Clan");
	register_menu("2 Clan Menu", KEYSMENU, "menu__ClanMemberInfo");
	register_menu("3 Clan Menu", KEYSMENU, "menu__ClanInfo");
	register_menu("4 Clan Menu", KEYSMENU, "menu__ClanPerks");
	register_menu("5 Clan Menu", KEYSMENU, "menu__ClanDeposit");
	register_menu("6 Clan Menu", KEYSMENU, "menu__ClanShowPerkInfo");

	g_Message_Money = get_user_msgid("Money");
	g_Message_CurWeapon = get_user_msgid("CurWeapon");
	g_Message_FlashBat = get_user_msgid("FlashBat");
	g_Message_Flashlight = get_user_msgid("Flashlight");
	g_Message_NVGToggle = get_user_msgid("NVGToggle");
	g_Message_WeapPickup = get_user_msgid("WeapPickup");
	g_Message_AmmoPickup = get_user_msgid("AmmoPickup");
	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SendAudio = get_user_msgid("SendAudio");
	g_Message_TeamInfo = get_user_msgid("TeamInfo");
	g_Message_StatusIcon = get_user_msgid("StatusIcon");
	g_Message_ShowMenu = get_user_msgid("ShowMenu");
	g_Message_VGUIMenu = get_user_msgid("VGUIMenu");
	g_Message_DeathMsg = get_user_msgid("DeathMsg");
	g_Message_ScoreInfo = get_user_msgid("ScoreInfo");
	g_Message_ScoreAttrib = get_user_msgid("ScoreAttrib");
	g_Message_SetFOV = get_user_msgid("SetFOV");
	g_Message_ScreenFade = get_user_msgid("ScreenFade");
	g_Message_ScreenShake = get_user_msgid("ScreenShake");
	g_Message_HideWeapon = get_user_msgid("HideWeapon");
	g_Message_Crosshair = get_user_msgid("Crosshair");

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
	register_message(g_Message_TeamInfo, "message__TeamInfo");
	register_message(g_Message_StatusIcon, "message__StatusIcon");
	register_message(g_Message_ShowMenu, "message__ShowMenu");
	register_message(g_Message_VGUIMenu, "message__VGUIMenu");

	g_MaxPlayers = get_maxplayers();
	g_HudSync_General = CreateHudSyncObj();
	g_HudSync_Combo = CreateHudSyncObj();
	g_HudSync_ClanCombo = CreateHudSyncObj();

	g_pCvar_Delay = register_cvar("zp_delay", "5.0");
	g_pCvar_CanUseMinigames = register_cvar("zp_can_use_minigames", "1 2");
	g_pCvar_DropHeadZombie = register_cvar("zp_drop_head_zombie", "0");

	g_Lights[0] = 'a';

	g_StartMode[0] = MODE_INFECTION;
	g_StartMode[1] = -1;

	loadSql();
	loadSpawns();
}

public plugin_cfg()
{
	arrayset(g_ModeCountAdmin, 0, structIdModes);
	arrayset(g_ExtraItem_LimitMap, 0, structIdExtraItems);

	new iEnt = create_entity("info_target");
	if(is_valid_ent(iEnt))
	{
		entity_set_string(iEnt, EV_SZ_classname, ENTTHINK_CLASSNAME_GENERAL);
		entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 0.1));

		register_think(ENTTHINK_CLASSNAME_GENERAL, "think__General");
	}

	g_HeadZombieSys = get_systime();
	g_PetitionModeSys = get_systime();

	set_task(0.5, "event__HLTV");
}

public plugin_end() {
	TrieDestroy(g_tModeAnnihilator_Acerts);
	TrieDestroy(g_tExtraItem_Invisibility);
	TrieDestroy(g_tExtraItem_KillBomb);
	TrieDestroy(g_tExtraItem_MolotovBomb);
	TrieDestroy(g_tExtraItem_AntidoteBomb);
	TrieDestroy(g_tExtraItem_Antidote);
	TrieDestroy(g_tExtraItem_ZombieMadness);
	TrieDestroy(g_tExtraItem_InfectionBomb);
	TrieDestroy(g_tExtraItem_ReduceDamage);
	TrieDestroy(g_tExtraItem_PainShock);
	TrieDestroy(g_tExtraItem_Petrification);

	if(get_cvar_num("mp_round_infinite") == 1) {
		set_cvar_num("mp_round_infinite", 0);
	}

	SQL_FreeHandle(g_SqlConnection);
	SQL_FreeHandle(g_SqlTuple);
}

public client_authorized(id, const authid[]) {
	copy(g_PlayerSteamId[id], charsmax(g_PlayerSteamId[]), authid);
}

public client_connectex(id, const name[], const ip[], reason[128]) {
	copy(g_PlayerName[id], charsmax(g_PlayerName[]), name);

	if(containi(g_PlayerName[id], "DROP TABLE") != -1 || containi(g_PlayerName[id], "TRUNCATE") != -1 || containi(g_PlayerName[id], "INSERT") != -1 || containi(g_PlayerName[id], "UPDATE") != -1 || containi(g_PlayerName[id], "DELETE") != -1 || containi(g_PlayerName[id], "\\") != -1) {
		server_cmd("kick #%d ^"Tu nombre tiene un caracter o conjunto de caracteres invalido(s)^"", get_user_userid(id));
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

	resetVars(id, .reset_all=1);

	if(!is_user_bot(id) && !is_user_hltv(id)) {
		if(!task_exists(id + TASK_CHECK_ACCOUNT)) {
			set_task(0.2, "task__CheckAccount", id + TASK_CHECK_ACCOUNT);
		}
	}
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	remove_task(id + TASK_CHECK_ACCOUNT);
	remove_task(id + TASK_REMEMBER_VINC);
	remove_task(id + TASK_SAVE);
	remove_task(id + TASK_BANNED);
	remove_task(id + TASK_AUTO_JOIN);
	remove_task(id + TASK_REFILL_BP_AMMO);
	remove_task(id + TASK_CHECK_STUCK);
	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_TEAM);
	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_FREEZE);
	remove_task(id + TASK_SLOWDOWN);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_PAINSHOCK);
	remove_task(id + TASK_POWER_SNIPER_ELITE);
	remove_task(id + TASK_POWER_FVSJ_JASON);
	remove_task(id + TASK_POWER_PREDATOR);
	remove_task(id + TASK_POWER_ASSASSIN);
	remove_task(id + TASK_POWER_SNIPER);
	remove_task(id + TASK_POWER_TRIBAL);
	remove_task(id + TASK_IMMUNITY_BOMB);
	remove_task(id + TASK_IMMUNITY_GG);
	remove_task(id + TASK_REGENERATION);
	remove_task(id + TASK_IMMUNITY_P);
	remove_task(id + TASK_NIGHTVISION);
	remove_task(id + TASK_MOLOTOV_EFFECT);
	remove_task(id + TASK_DRUG);
	remove_task(id + TASK_GRAB);
	remove_task(id + TASK_GRAB_PRETHINK);
	remove_task(id + TASK_GRUNT_AIMING);
	remove_task(id + TASK_GRUNT_GLOW);

	if(is_valid_ent(g_HatEnt[id])) {
		remove_entity(g_HatEnt[id]);
	}

	if(g_IsAlive[id]) {
		if(!g_Zombie[id]) {
			finishComboHuman(id);
		} else {
			finishComboZombie(id);
		}

		checkRound(id);
	}

	checkStuffOnDisconnected(id);

	if(g_AccountLogged[id]) {
		g_SysTime_Connect[id] = (get_systime() - g_SysTime_Connect[id]);
		g_PlayedTime[id][TIME_SEC] += (g_SysTime_Connect[id] / 60);

		saveInfo(id);
	}

	g_IsAlive[id] = 0;
	g_IsConnected[id] = 0;

	if(getPlaying() <= 6) {
		g_LogSay = 1;
		set_cvar_num("sv_voiceenable", 0);
	}
}

public event__HLTV()
{
	remove_task(TASK_REMOVE_STUFF);
	set_task(0.1, "task__RemoveStuff", TASK_REMOVE_STUFF);

	if(g_Mode == MODE_ASSASSIN || g_Mode == MODE_GRUNT)
		set_cvar_num("sv_alltalk", 1);
	else if(g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_MEGA_ARMAGEDDON || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME)
		set_cvar_num("mp_round_infinite", 0);

	g_Lights[0] = 'i';
	g_NewRound = 1;
	g_VirusT = 0;
	g_EndRound = 0;
	g_Mode = MODE_NONE;
	if(g_MiniGameTejo_On) g_MiniGameTejo_On = 0;
	if(g_MiniGameBomba_On) g_MiniGameBomba_On = 0;
	g_MiniGameLaser_On = 0;
	g_MiniGameLaser_UserId = 0;
	g_MiniGameLaser_Line = 0;
	g_MiniGameLaser_Laps = 0;
	g_MiniGameLaser_360 = 0.0;

	remove_task(TASK_VIRUST);
	set_task(2.5, "task__VirusT", TASK_VIRUST);

	remove_task(TASK_START_MODE);
	set_task((2.5 + get_pcvar_float(g_pCvar_Delay)), "task__StartMode", TASK_START_MODE);

	if(g_StartMode[1] != -1)
	{
		g_StartMode[0] = g_StartMode[1];
		g_StartMode[1] = -1;
	}

	arrayset(g_Petrification_Round, 0, MAX_USERS);
	arrayset(g_ModeMA_Reward, 0, MAX_USERS);
}

public event__Intermission()
{
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i])
			continue;

		if(!g_Zombie[i])
			finishComboHuman(i);
		else
			finishComboZombie(i);
	}
}

public event__AmmoX(const id)
{
	if(g_Zombie[id])
		return;
	
	static iType;
	iType = read_data(1);
	
	if(iType >= sizeof(AMMO_WEAPON))
		return;
	
	static iWeaponId;
	iWeaponId = AMMO_WEAPON[iType];
	
	if(MAX_BPAMMO[iWeaponId] <= 2)
		return;
	
	static iAmount;
	iAmount = read_data(2);
	
	if(iAmount < MAX_BPAMMO[iWeaponId])
	{
		static iArgs[1];
		iArgs[0] = iWeaponId;
		
		set_task(0.1, "task__RefillBPAmmo", id + TASK_REFILL_BP_AMMO, iArgs, sizeof(iArgs));
	}
}

public event__Health(const id)
	g_Health[id] = get_user_health(id);

public getLevelTotal(const id)
{
	static iLevelTotal;
	iLevelTotal = (g_Level[id] + (g_Reset[id] + MAX_LEVEL));

	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return 1;

	return iLevelTotal;
}

public logevent__RoundEnd()
{
	static Float:flGameTime;
	static Float:flLastEndTime;
	
	flGameTime = get_gametime();
	
	if((flGameTime - flLastEndTime) < 0.5)
		return;
	
	flLastEndTime = flGameTime;
	
	remove_task(TASK_VIRUST);
	remove_task(TASK_START_MODE);
	remove_task(TASK_MODE_ARMAGEDDON);
	remove_task(TASK_MODE_MEGA_ARMAGEDDON);
	remove_task(TASK_MODE_MEGA_GUNGAME);
	remove_task(TASK_MODE_FVSJ);
	remove_task(TASK_MODE_DUEL_FINAL);
	
	g_EndRound = 1;

	if(!getZombies())
	{
		showDHUDMessage(0, 0, 0, 255, -1.0, 0.25, 0, 10.0, "¡GANARON LOS HUMANOS!");
		playSound(0, SOUND_WIN_HUMANS);

		++g_ScoreHumans;
	}
	else if(!getHumans())
	{
		showDHUDMessage(0, 255, 0, 0, -1.0, 0.25, 0, 10.0, "¡GANARON LOS ZOMBIES!");
		playSound(0, SOUND_WIN_ZOMBIES);

		++g_ScoreZombies;
	}
	else
	{
		showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 10.0, "¡NO GANÓ NADIE!");
		playSound(0, SOUND_WIN_NO_ONE);
	}

	static iUsersNum;
	static i;

	iUsersNum = getPlaying();

	switch(g_Mode)
	{
		case MODE_INFECTION:
		{
			new iBestVictim;
			new iBestVictimId;

			iBestVictimId = systemSort(g_MayorMuerte, iBestVictim);

			if(iBestVictim && iBestVictimId)
			{
				dg_color_chat(0, _, "!t%s!y ganó !g1 pHZL!y por haber muerto !t%d ve%s!y en la ronda", g_PlayerName[iBestVictimId], iBestVictim, ((iBestVictim != 1) ? "ces" : "z"));

				++g_Points[iBestVictimId][POINT_HUMAN];
				++g_Points[iBestVictimId][POINT_ZOMBIE];
				++g_Points[iBestVictimId][POINT_LEGACY];
			}
		}
		case MODE_L4D2:
		{
			new iReward;
			new sReward[16];

			iReward = 0;
			sReward[0] = EOS;

			for(i = 1; i <= MaxClients; ++i)
			{
				if(g_IsConnected[i] && g_AccountLogged[i])
				{
					if(g_SpecialMode[i] == MODE_L4D2)
					{
						iReward = (getLevelTotal(i) * ((g_ModeL4D2_ZombiesTotal - g_ModeL4D2_Zombies) * 25)) * g_ExpMult[i];
						addDot(iReward, sReward, charsmax(sReward));

						dg_color_chat(i, _, "Ganaste !g%s XP!y por sobrevivir al modo !tL4D2!y", sReward);
						addXP(i, iReward);
					}
					else
					{
						if(g_ModeL4D2_ZombieAcerts[i])
						{
							iReward = (getLevelTotal(i) * (g_ModeL4D2_ZombieAcerts[i] * 50)) * g_ExpMult[i];
							addDot(iReward, sReward, charsmax(sReward));

							dg_color_chat(i, _, "Ganaste !g%s XP!y por haber pegado !g%d ve%s a los humanos!y", sReward, g_ModeL4D2_ZombieAcerts[i], ((g_ModeL4D2_ZombieAcerts[i] != 1) ? "ces" : "z"));
							addXP(i, iReward);

							g_ModeL4D2_ZombieAcerts[i] = 0;
						}
						else
							dg_color_chat(i, _, "No recibiste recompensas porque no le has hecho daño a los humanos");
					}
				}
			}
		}
		case MODE_PLAGUE:
		{
			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_IsConnected[i] && g_AccountLogged[i])
				{
					if(g_IsAlive[i])
					{
						g_Points[i][POINT_HUMAN] += 3;
						g_Points[i][POINT_ZOMBIE] += 3;
						g_Points[i][POINT_SPECIAL] += 5;

						dg_color_chat(i, _, "Ganaste !g3 pHZ!y y !g5 pE!y por sobrevivir en el modo !tPLAGUE!y");
					}
					else
					{
						g_Points[i][POINT_HUMAN] += 2;
						g_Points[i][POINT_ZOMBIE] += 2;

						dg_color_chat(i, _, "Ganaste !g2 pHZ!y por participar en el modo !tPLAGUE!y");
					}
				}
			}

			if(g_HappyTime == 2)
			{
				new iReward;
				new sReward[16];

				iReward = 0;
				sReward[0] = EOS;

				for(i = 1; i <= g_MaxPlayers; ++i)
				{
					if(g_IsConnected[i] && g_AccountLogged[i])
					{
						if(g_IsAlive[i])
						{
							iReward = (getLevelTotal(i) * (getAlives() * 25)) * g_ExpMult[i];
							addDot(iReward, sReward, charsmax(sReward));

							dg_color_chat(i, _, "Ganaste !g%s XP!y por sobrevivir al modo y participar en el !tSUPER DRUNK AT NITE!y", sReward);
							addXP(i, iReward);
						}
						else
						{
							iReward = (getLevelTotal(i) * (getAlives() * 10)) * g_ExpMult[i];
							addDot(iReward, sReward, charsmax(sReward));

							dg_color_chat(i, _, "Ganaste !g%s XP!y por participar del modo y en el !tSUPER DRUNK AT NITE!y", sReward);
							addXP(i, iReward);
						}
					}
				}
			}
		}
		case MODE_FVSJ:
		{
			if(!g_ModeFvsJ_Humans && !getHumans())
			{
				for(i = 1; i <= g_MaxPlayers; ++i)
				{
					if(g_IsAlive[i])
					{
						if(g_SpecialMode[i] == MODE_FVSJ && !g_ModeFvsJ_Jason[i] && g_Zombie[i])
						{
							++g_Stats[i][STAT_F_M_WIN];

							dg_color_chat(i, _, "Ganaste !g3 pHZL!y por ganar el modo !tFREDDY VS JASON!y");

							g_Points[i][POINT_HUMAN] += 3;
							g_Points[i][POINT_ZOMBIE] += 3;
							g_Points[i][POINT_LEGACY] += 3;
						}
					}
				}
			}
		}
		case MODE_SYNAPSIS:
		{
			static iBestNemesisKill;
			static iBestNemesisKillId;

			iBestNemesisKillId = systemSort(g_ModeSynapsis_NemesisKill, iBestNemesisKill);

			if(iBestNemesisKill && iBestNemesisKillId)
			{
				dg_color_chat(0, _, "!t%s!y ganó !g%d pHZ!y por matar a !g%d humano%s!y", g_PlayerName[iBestNemesisKillId], g_PointsMult[iBestNemesisKillId], iBestNemesisKill, ((iBestNemesisKill != 1) ? "s" : ""));

				g_Points[iBestNemesisKillId][POINT_HUMAN] += g_PointsMult[iBestNemesisKillId];
				g_Points[iBestNemesisKillId][POINT_ZOMBIE] += g_PointsMult[iBestNemesisKillId];
			}
		}
		case MODE_AVSP:
		{
			DisableHamForward(g_HamTouchWall);
			DisableHamForward(g_HamTouchBreakeable);
			DisableHamForward(g_HamTouchWorldspawn);
		}
		case MODE_NEMESIS:
		{
			unregister_forward(FM_UpdateClientData, g_fwdUpdateClientDataPost, 1);

			static iEnt;
			iEnt = find_ent_by_class(-1, ENT_CLASSNAME_ROCKET);
			
			while(is_valid_ent(iEnt))
			{
				removeRocket(iEnt);
				iEnt = find_ent_by_class(-1, ENT_CLASSNAME_ROCKET);
			}

			SortIntegers(g_AchievementSecret_DmgNemOrd, (MAX_USERS - 1), Sort_Descending);

			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_IsConnected[i] && g_AccountLogged[i])
				{
					if(g_AchievementSecret_DmgNemOrd[0] >= 500000 && g_AchievementSecret_DmgNemOrd[0] == g_AchievementSecret_DmgNem[i])
						setAchievement(i, MI_MAMA_DISPARO);
				}
			}
		}
		case MODE_ASSASSIN:
		{
			if(!getZombies() || !getHumans())
			{
				static sReward[16];
				sReward[0] = EOS;

				for(i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i])
						continue;

					if(g_SpecialMode[i] == MODE_ASSASSIN)
					{
						addDot(g_ModeAssassin_RewardAssassin, sReward, charsmax(sReward));
						
						dg_color_chat(i, _, "Ganaste !g%s XP!y por haber ganado el modo", sReward);
						addXP(i, g_ModeAssassin_RewardAssassin);
					}
					else
					{
						addDot(g_ModeAssassin_RewardHumans, sReward, charsmax(sReward));
						
						dg_color_chat(i, _, "Ganaste !g%s XP!y por haber sobrevivido al !tASSASSIN!y", sReward);
						addXP(i, g_ModeAssassin_RewardHumans);
					}
				}
			}
		}
		case MODE_ANNIHILATOR:
		{
			static iReward;
			static sReward[16];

			iReward = 0;
			sReward[0] = EOS;

			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_IsConnected[i] && g_AccountLogged[i])
				{
					if(g_SpecialMode[i] != MODE_ANNIHILATOR)
					{
						if(g_ModeAnnihilator_Acerts[i])
						{
							iReward = (g_ModeAnnihilator_Acerts[i] * (50 * g_ExpMult[i])) * (getLevelTotal(i) + 1);
							
							if(iReward < 0 || iReward >= MAX_XP)
								iReward = MAX_XP;

							addDot(iReward, sReward, charsmax(sReward));

							dg_color_chat(i, _, "Ganaste !g%s XP!y por haber realizado !g%d aciertos de disparos!y", sReward, g_ModeAnnihilator_Acerts[i]);
							addXP(i, iReward);

							g_ModeAnnihilator_Acerts[i] = 0;
						}
						else
							dg_color_chat(i, _, "No recibiste recompensas porque no realizaste aciertos de disparos");
					}
					else
					{
						++g_Stats[i][STAT_AN_M_WIN];

						if(g_ModeAnnihilator_Kills[i])
						{
							iReward = (g_ModeAnnihilator_Kills[i] * (100 * g_ExpMult[i])) * (getLevelTotal(i) + 1);

							if(iReward < 0 || iReward >= MAX_XP)
								iReward = MAX_XP;

							addDot(iReward, sReward, charsmax(sReward));

							dg_color_chat(0, _, "El !tANIQUILADOR!y mató a !g%d humanos!y y por eso ganó !g%s XP!y", g_ModeAnnihilator_Kills[i], sReward);
							addXP(i, iReward);

							if((g_Achievement_AnnKnife[i] - g_Achievement_AnnBazooka[i]) >= 300)
								setAchievement(i, ANIQUILOSO);

							if(g_Achievement_AnnBazooka[i] >= 125)
								setAchievement(i, CIENFUEGOS);
							else if(!g_Achievement_AnnBazooka[i] && !g_ModeNemesis_Bazooka[i])
								setAchievement(i, EL_PEOR_DEL_SERVER);

							static sWeaponName[32];
							static iWeaponEntId;

							get_weaponname(CSW_MAC10, sWeaponName, charsmax(sWeaponName));
							iWeaponEntId = find_ent_by_owner(-1, sWeaponName, i);

							if(get_pdata_int(iWeaponEntId, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS) == 30 && get_pdata_int(i, AMMO_OFFSET[CSW_MAC10], OFFSET_LINUX) == 100)
								setAchievement(i, MI_MAC10_ESTA_LLENA);
							else if(!g_Achievement_AnniMac10[i] && get_pdata_int(iWeaponEntId, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS) == 0 && get_pdata_int(i, AMMO_OFFSET[CSW_MAC10], OFFSET_LINUX) == 0)
								setAchievement(i, SOY_UN_MANCO);
							else if(g_Achievement_AnniMac10[i] >= 50)
							{
								setAchievement(i, CINCUENTA_SON_CINCUENTA);

								if(g_Achievement_AnniMac10[i] >= 100)
								{
									setAchievement(i, YO_SI_PEGO_CON_ESTO);
									
									if(g_Achievement_AnniMac10[i] == 130)
										setAchievement(i, MUCHA_PRECISION);
								}
							}

							if(g_ModeAnnihilator_Kills[i] >= 300)
							{
								setAchievement(i, CARNE);

								if(g_ModeAnnihilator_Kills[i] >= 400)
								{
									setAchievement(i, MUCHA_CARNE);

									if(g_ModeAnnihilator_Kills[i] >= 500)
									{
										setAchievement(i, DEMASIADA_CARNE);

										if(g_ModeAnnihilator_Kills[i] >= 600)
											setAchievement(i, CARNE_PARA_TODOS);
									}
								}
							}

							g_ModeAnnihilator_Kills[i] = 0;
						}
						else
							dg_color_chat(0, TERRORIST, "El !tANIQUILADOR!y no recibió recompensas por no ha asesinado a humanos");
					}
				}

				g_Achievement_AnnKnife[i] = 0;
				g_Achievement_AnniMac10[i] = 0;
				g_Achievement_AnnBazooka[i] = 0;
			}
		}
		case MODE_GRUNT:
		{
			static sReward[16];
			sReward[0] = EOS;

			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_IsConnected[i])
				{
					addDot(g_ModeGrunt_Reward[i], sReward, charsmax(sReward));
					dg_color_chat(i, _, "Ganaste !g%s XP!y por sobrevivir al modo !tGRUNT!y", sReward);

					addXP(i, g_ModeGrunt_Reward[i]);
					g_ModeGrunt_Reward[i] = 0;
				}
			}

			g_ModeGrunt_RewardGlobal = 0;
		}
	}

	if(iUsersNum < 1)
		return;

	if(g_EndRound_Forced)
	{
		g_EndRound_Forced = 0;

		static iClass;
		static iDifficultClass;
		static iReward;
		static iRewardPL;

		iClass = -1;
		iDifficultClass = -1;
		iReward = 0;
		iRewardPL = 0;

		for(i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;
			
			if(!g_SpecialMode[i] && !g_LastZombie[i] && !g_LastHuman[i])
				continue;

			if(g_SpecialMode[i])
			{
				switch(g_SpecialMode[i])
				{
					case MODE_SURVIVOR:
					{
						++g_Stats[i][STAT_S_M_WIN];

						switch(g_Difficult[i][DIFFICULT_CLASS_SURVIVOR])
						{
							case DIFFICULT_NORMAL: setAchievement(i, SURVIVOR_PRINCIPIANTE);
							case DIFFICULT_HARD: setAchievement(i, SURVIVOR_AVANZADO);
							case DIFFICULT_VERY_HARD:
							{
								setAchievement(i, SURVIVOR_EXPERTO);

								if(getUserHealthPercent(i, 75))
									setAchievement(i, SURVIVOR_PRO);
							}
						}

						iClass = POINT_HUMAN;
						iDifficultClass = DIFFICULT_CLASS_SURVIVOR;
					}
					case MODE_WESKER:
					{
						++g_Stats[i][STAT_W_M_WIN];

						switch(g_Difficult[i][DIFFICULT_CLASS_WESKER])
						{
							case DIFFICULT_NORMAL: setAchievement(i, WESKER_PRINCIPIANTE);
							case DIFFICULT_HARD: setAchievement(i, WESKER_AVANZADO);
							case DIFFICULT_VERY_HARD:
							{
								setAchievement(i, WESKER_EXPERTO);

								if(getUserHealthPercent(i, 75))
									setAchievement(i, WESKER_PRO);
							}
						}

						if(g_ModeWesker_Laser[i] == 3 && iUsersNum >= 10)
							giveHat(i, HAT_HOOD);

						iClass = POINT_HUMAN;
						iDifficultClass = DIFFICULT_CLASS_WESKER;
					}
					case MODE_SNIPER_ELITE:
					{
						++g_Stats[i][STAT_SN_M_WIN];

						switch(g_Difficult[i][DIFFICULT_CLASS_SNIPER_ELITE])
						{
							case DIFFICULT_NORMAL: setAchievement(i, SNIPER_ELITE_PRINCIPIANTE);
							case DIFFICULT_HARD: setAchievement(i, SNIPER_ELITE_AVANZADO);
							case DIFFICULT_VERY_HARD:
							{
								setAchievement(i, SNIPER_ELITE_EXPERTO);

								if(getUserHealthPercent(i, 75))
									setAchievement(i, SNIPER_ELITE_PRO);
							}
						}

						iClass = POINT_HUMAN;
						iDifficultClass = DIFFICULT_CLASS_SNIPER_ELITE;
					}
					case MODE_JASON:
					{
						++g_Stats[i][STAT_J_M_WIN];

						iClass = POINT_HUMAN;
					}
					case MODE_NEMESIS:
					{
						if(g_ModeNemesis_Bazooka[i])
							setAchievement(i, CRATER_SANGRIENTO);
						
						++g_Stats[i][STAT_N_M_WIN];

						switch(g_Difficult[i][DIFFICULT_CLASS_NEMESIS])
						{
							case DIFFICULT_NORMAL: setAchievement(i, NEMESIS_PRINCIPIANTE);
							case DIFFICULT_HARD: setAchievement(i, NEMESIS_AVANZADO);
							case DIFFICULT_VERY_HARD:
							{
								setAchievement(i, NEMESIS_EXPERTO);

								if(getUserHealthPercent(i, 75))
									setAchievement(i, NEMESIS_PRO);
							}
						}
						
						iClass = POINT_ZOMBIE;
						iDifficultClass = DIFFICULT_CLASS_NEMESIS;
					}
					case MODE_ASSASSIN:
					{
						++g_Stats[i][STAT_A_M_WIN];

						switch(g_Difficult[i][DIFFICULT_CLASS_ASSASSIN])
						{
							case DIFFICULT_NORMAL: setAchievement(i, ASSASSIN_PRINCIPIANTE);
							case DIFFICULT_HARD: setAchievement(i, ASSASSIN_AVANZADO);
							case DIFFICULT_VERY_HARD:
							{
								setAchievement(i, ASSASSIN_EXPERTO);

								if(getUserHealthPercent(i, 75))
									setAchievement(i, ASSASSIN_PRO);
							}
						}
						
						iClass = POINT_ZOMBIE;
						iDifficultClass = DIFFICULT_CLASS_ASSASSIN;

						if(iUsersNum >= 15)
							setAchievement(i, MI_CUCHILLA_Y_YO);
					}
					case MODE_ANNIHILATOR:
					{
						++g_Stats[i][STAT_AN_M_WIN];

						switch(g_Difficult[i][DIFFICULT_CLASS_ANNIHILATOR])
						{
							case DIFFICULT_NORMAL: setAchievement(i, ANNIHILATOR_PRINCIPIANTE);
							case DIFFICULT_HARD: setAchievement(i, ANNIHILATOR_AVANZADO);
							case DIFFICULT_VERY_HARD:
							{
								setAchievement(i, ANNIHILATOR_EXPERTO);

								if(getUserHealthPercent(i, 75))
									setAchievement(i, ANNIHILATOR_PRO);
							}
						}

						iClass = POINT_ZOMBIE;
						iDifficultClass = DIFFICULT_CLASS_ANNIHILATOR;
					}
				}

				iReward = g_PointsMult[i];
				iRewardPL = (1 + g_Habs[i][HAB_D_MORE_PL]);

				if(iDifficultClass != -1)
				{
					if(g_Difficult[i][iDifficultClass] != DIFFICULT_NORMAL)
						iReward += g_Difficult[i][iDifficultClass];

					g_Points[i][iClass] += iReward;
					g_Points[i][POINT_LEGACY] += iRewardPL;

					dg_color_chat(0, ((iClass == POINT_HUMAN) ? CT : TERRORIST), "!t%s!y ganó !g%d p%c!y y !g%d pL!y por ganar el modo !g%s!y", g_PlayerName[i], iReward, ((iClass == POINT_HUMAN) ? 'H' : 'Z'), iRewardPL, g_PlayerClassName[i]);
				}
				else
				{
					g_Points[i][iClass] += iReward;
					dg_color_chat(0, ((iClass == POINT_HUMAN) ? CT : TERRORIST), "!t%s!y ganó !g%d p%c!y por ganar el modo !g%s!y", g_PlayerName[i], iReward, ((iClass == POINT_HUMAN) ? 'H' : 'Z'), g_PlayerClassName[i]);
				}
			}
			else if(g_LastZombie[i])
			{
				g_Points[i][POINT_ZOMBIE] += g_PointsMult[i];
				dg_color_chat(0, TERRORIST, "!t%s!y ganó !t%d pZ!y porque el !gmodo especial!y se desconectó", g_PlayerName[i], g_PointsMult[i]);
			}
			else if(g_LastHuman[i])
			{
				g_Points[i][POINT_HUMAN] += g_PointsMult[i];
				dg_color_chat(0, CT, "!t%s!y ganó !t%d pH!y porque el !gmodo especial!y se desconectó", g_PlayerName[i], g_PointsMult[i]);
			}
			
			break;
		}
	}

	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i])
		{
			if(!g_Zombie[i])
			{
				finishComboHuman(i);

				if(g_ClanSlot[i] && g_ClanCombo[i])
					clanFinishCombo(i);
			}
			else
				finishComboZombie(i);

			if(g_AchievementSecret_Terrorist[i] >= 150)
				setAchievement(i, TERRORISTA_1);

			if(g_AchievementSecret_Bullets[i] >= 1500 && g_AchievementSecret_BulletsOk[i] >= 500)
				setAchievement(i, BALAS_1500);

			if(g_AchievementSecret_Hitman[i] >= 500000)
				setAchievement(i, HITMAN);

			if(g_AchievementSecret_MasZombies[i] >= 35)
				setAchievement(i, MAS_ZOMBIES);

			if(g_Exp[i] >= 100000000 && !g_Achievement[i][MILLONARIO])
				setAchievement(i, MILLONARIO);

			for(new j = 0; j < structIdExtraItems; ++j)
				g_AchievementSecret_AllItems[i][j] = 0;
		}
	}

	rg_balance_teams();
}

// **************************************************
//		[Fakemeta Functions]
// **************************************************
public fwd__SpawnPre(const entity)
{
	if(!pev_valid(entity))
		return FMRES_IGNORED;

	static sClassName[32];
	entity_get_string(entity, EV_SZ_classname, sClassName, charsmax(sClassName));

	for(new i = 0; i < sizeof(REMOVE_ENTS); ++i)
	{
		if(equal(sClassName, REMOVE_ENTS[i]))
		{
			remove_entity(entity);
			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public fwd__PrecacheSoundPre(const sound[])
{
	if(equal(sound, "hostage", 7))
		return FMRES_SUPERCEDE;

	return FMRES_IGNORED;
}

public fwd__UpdateClientDataPost(const id, const send_weapons, const handle)
{
	if(!g_IsAlive[id])
		return FMRES_IGNORED;

	if((g_SpecialMode[id] == MODE_NEMESIS || g_SpecialMode[id] == MODE_ANNIHILATOR) && g_CurrentWeapon[id] == CSW_AK47)
		set_cd(handle, CD_flNextAttack, (get_gametime() + 0.00001));

	return FMRES_HANDLED;
}

public fwd__SysErrorPre(const error[])
{
	static sErrors[512];
	formatex(sErrors, charsmax(sErrors), "fwd__SysErrorPre() - %s - %s", ((error[0]) ? error : "Ninguno"), g_MapName);
	dg_log_to_file(LOG_PRECACHE_SERVER, 1, 0, sErrors);
}

public fwd__GameShutdownPre(const error[])
{
	static sErrors[512];
	formatex(sErrors, charsmax(sErrors), "fwd__GameShutdownPre() - %s - %s", ((error[0]) ? error : "Ninguno"), g_MapName);
	dg_log_to_file(LOG_PRECACHE_SERVER, 1, 0, sErrors);
}

public fwd__SetClientKeyValuePre(const id, const infobuffer[], const key[])
{
	if(key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l')
	{
		static sCurrentModel[32];
		getUserModel(id, sCurrentModel, charsmax(sCurrentModel));
		
		if(!equal(sCurrentModel, g_PlayerModel[id]) && !task_exists(id + TASK_MODEL))
			task__SetUserModel(id + TASK_MODEL);
		
		return FMRES_SUPERCEDE;
	}
	
	if(key[0] == 'n' && key[1] == 'a' && key[2] == 'm' && key[3] == 'e')
		return FMRES_SUPERCEDE;

	return FMRES_IGNORED;
}

public fwd__ClientUserInfoChangedPre(const id, const buffer)
{
	if(!g_IsConnected[id])
		return FMRES_IGNORED;
	
	get_user_name(id, g_PlayerName[id], charsmax(g_PlayerName[]));

	static sNewName[MAX_NAME_LENGTH];
	engfunc(EngFunc_InfoKeyValue, buffer, "name", sNewName, charsmax(sNewName));

	if(equal(sNewName, g_PlayerName[id]))
		return FMRES_IGNORED;

	engfunc(EngFunc_SetClientKeyValue, id, buffer, "name", g_PlayerName[id]);
	client_cmd(id, "name ^"%s^"; setinfo name ^"%s^"", g_PlayerName[id], g_PlayerName[id]);
	set_user_info(id, "name", g_PlayerName[id]);

	dg_console_chat(id, "Si quieres cambiarte el nombre, debes desconectarte");
	return FMRES_SUPERCEDE;
}

public fwd__ClientDisconnectPost()
	checkLastZombie();

public fwd__ClientKillPre()
	return FMRES_SUPERCEDE;

public fwd__EmitSoundPre(const id, const channel, const sample[], const Float:volume, const Float:attn, const flags, const pitch)
{
	if(sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') // HOSTAGE
		return FMRES_SUPERCEDE;

	if(sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l') // FALL
		return FMRES_SUPERCEDE;

	if(!isUserValidConnected(id))
		return FMRES_IGNORED;

	if(!g_Zombie[id])
	{
		if(g_SpecialMode[id] == MODE_JASON)
		{
			for(new i = 0; i < sizeof(SOUND_JASON_CHAINSAW); ++i)
			{
				if(equal(sample, SOUND_HUMAN_KNIFE_DEFAULT[i]))
				{
					emit_sound(id, channel, SOUND_JASON_CHAINSAW[i], volume, attn, flags, pitch);
					return FMRES_SUPERCEDE;
				}
			}
		}

		return FMRES_IGNORED;
	}

	if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') // BHIT
	{
		if(g_SpecialMode[id])
			emit_sound(id, channel, SOUND_SPECIALMODE_PAIN[random_num(0, charsmax(SOUND_SPECIALMODE_PAIN))], volume, attn, flags, pitch);
		else
			emit_sound(id, channel, SOUND_ZOMBIE_PAIN[random_num(0, charsmax(SOUND_ZOMBIE_PAIN))], volume, attn, flags, pitch);

		return FMRES_SUPERCEDE;
	}

	if(g_CurrentWeapon[id] == CSW_KNIFE)
	{
		if(!g_BlockSound[id])
		{
			if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i') // KNI (FE)
			{
				if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // SLA (SH)
				{
					emit_sound(id, channel, SOUND_ZOMBIE_KNIFE[2], volume, attn, flags, pitch);
					return FMRES_SUPERCEDE;
				}

				if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // HIT
				{
					if(sample[17] == 'w')
						emit_sound(id, channel, SOUND_ZOMBIE_KNIFE[1], volume, attn, flags, pitch);
					else
						emit_sound(id, channel, SOUND_ZOMBIE_KNIFE[0], volume, attn, flags, pitch);

					return FMRES_SUPERCEDE;
				}

				if(sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // STA (B)
				{
					emit_sound(id, channel, SOUND_ZOMBIE_KNIFE[1], volume, attn, flags, pitch);
					return FMRES_SUPERCEDE;
				}
			}
		}
		else
			g_BlockSound[id] = 0;
	}

	if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) // DIE / DEA (D)
	{
		emit_sound(id, channel, SOUND_ZOMBIE_DIE[random_num(0, charsmax(SOUND_ZOMBIE_DIE))], volume, attn, flags, pitch);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fwd__SetModelPre(const ent, const model[])
{
	if(strlen(model) < 8)
		return FMRES_IGNORED;

	static sClassName[10];
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(equal(sClassName, "weaponbox"))
	{
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01);
		return FMRES_IGNORED;
	}

	if(model[7] != 'w' || model[8] != '_')
		return FMRES_IGNORED;

	static Float:flDmgTime;
	flDmgTime = entity_get_float(ent, EV_FL_dmgtime);

	if(flDmgTime == 0.0)
		return FMRES_IGNORED;

	static iId;
	iId = entity_get_edict(ent, EV_ENT_owner);

	switch(model[9])
	{
		case 'h':
		{
			if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
				return FMRES_IGNORED;

			replaceWeaponModels(iId, CSW_HEGRENADE);

			if(g_Zombie[iId])
			{
				effectGrenade(ent, 0, 255, 0, NADE_TYPE_INFECTION);

				entity_set_model(ent, GRENADE_MODEL_INFECTION[2]);
				return FMRES_SUPERCEDE;
			}
			else
			{
				if(g_DrugBomb[iId])
				{
					effectGrenade(ent, 153, 204, 50, NADE_TYPE_DRUG);

					--g_DrugBomb[iId];

					entity_set_model(ent, GRENADE_MODEL_DRUG[2]);
					return FMRES_SUPERCEDE;
				}
				else if(g_NitroBomb[iId])
				{
					effectGrenade(ent, 0, 255, 255, NADE_TYPE_NITRO);

					--g_NitroBomb[iId];
				}
				else if(g_KillBomb[iId])
				{
					effectGrenade(ent, 255, 255, 0, NADE_TYPE_KILL);

					--g_KillBomb[iId];
				}
				else
					effectGrenade(ent, 255, 0, 0, NADE_TYPE_FIRE);
			}
		}
		case 'f':
		{
			replaceWeaponModels(iId, CSW_FLASHBANG);

			if(g_HyperNovaBomb[iId])
			{
				effectGrenade(ent, 255, 50, 179, NADE_TYPE_HYPERNOVA);

				--g_HyperNovaBomb[iId];

				entity_set_model(ent, GRENADE_MODEL_HYPERNOVA[2]);
				return FMRES_SUPERCEDE;
			}
			else if(g_SuperNovaBomb[iId])
			{
				effectGrenade(ent, 255, 0, 255, NADE_TYPE_SUPERNOVA);

				--g_SuperNovaBomb[iId];
			}
			else if(g_MolotovBomb[iId])
			{
				effectGrenade(ent, 100, 100, 100, NADE_TYPE_MOLOTOV);

				--g_MolotovBomb[iId];

				remove_task(ent + TASK_MOLOTOV_EFFECT);
				set_task(0.1, "task__MolotovEffect", ent + TASK_MOLOTOV_EFFECT, .flags="b");
			}
			else
				effectGrenade(ent, 0, 0, 255, NADE_TYPE_NOVA);
		}
		case 's':
		{
			replaceWeaponModels(iId, CSW_SMOKEGRENADE);

			if(g_BubbleBomb[iId])
			{
				if(g_Mode == MODE_ARMAGEDDON || g_Mode == MODE_MEGA_ARMAGEDDON)
				{
					if(g_SpecialMode[iId] == MODE_SURVIVOR)
						effectGrenade(ent, 0, 0, 255, NADE_TYPE_BUBBLE);
					else
						effectGrenade(ent, g_UserOption_Color[iId][COLOR_TYPE_FLARE][0], g_UserOption_Color[iId][COLOR_TYPE_FLARE][1], g_UserOption_Color[iId][COLOR_TYPE_FLARE][2], NADE_TYPE_BUBBLE);
				}
				else
					effectGrenade(ent, g_UserOption_Color[iId][COLOR_TYPE_FLARE][0], g_UserOption_Color[iId][COLOR_TYPE_FLARE][1], g_UserOption_Color[iId][COLOR_TYPE_FLARE][2], NADE_TYPE_BUBBLE);

				--g_BubbleBomb[iId];

				entity_set_model(ent, GRENADE_MODEL_BUBBLE[2]);
				return FMRES_SUPERCEDE;
			}
			else if(g_ImmunityBomb[iId])
			{
				effectGrenade(ent, 107, 66, 38, NADE_TYPE_IMMUNITY);

				--g_ImmunityBomb[iId];
			}
			else if(g_AntidoteBomb[iId])
			{
				effectGrenade(ent, 255, 255, 255, NADE_TYPE_ANTIDOTE);

				--g_AntidoteBomb[iId];
			}
			else
				effectGrenade(ent, g_UserOption_Color[iId][COLOR_TYPE_FLARE][0], g_UserOption_Color[iId][COLOR_TYPE_FLARE][1], g_UserOption_Color[iId][COLOR_TYPE_FLARE][2], NADE_TYPE_FLARE);
		}
	}

	return FMRES_IGNORED;
}

public fwd__AddToFullPackPost(const es, const e, const ent, const host, const host_flags, const player, const player_set)
{
	if(g_MiniGame_Semiclip || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT)
		return FMRES_IGNORED;
	
	if(player && g_IsAlive[host] && g_IsAlive[ent] && ((g_PlayerTeam[host] == F_TEAM_CT && g_PlayerTeam[ent] == F_TEAM_CT) || (g_NewRound || g_EndRound)))
	{
		set_es(es, ES_Solid, SOLID_NOT);

		if(g_ClanSlot[host] && (g_ClanSlot[host] == g_ClanSlot[ent]))
		{
			static vecColor[3];

			vecColor[0] = g_UserOption_Color[host][COLOR_TYPE_CLAN_GLOW][0];
			vecColor[1] = g_UserOption_Color[host][COLOR_TYPE_CLAN_GLOW][1];
			vecColor[2] = g_UserOption_Color[host][COLOR_TYPE_CLAN_GLOW][2];

			set_es(es, ES_RenderFx, kRenderFxGlowShell);
			set_es(es, ES_RenderColor, vecColor);
		}
		else if(!g_ClanSlot[host])
		{
			set_es(es, ES_RenderFx, kRenderFxNone);
			set_es(es, ES_RenderColor, {0, 0, 0});
		}

		switch(g_UserOption_Invis[host])
		{
			case 0:
			{
				set_es(es, ES_RenderMode, kRenderTransAlpha);
				set_es(es, ES_RenderAmt, 50);
			}
			case 1:
			{
				if(g_ConvertZombie[host])
				{
					set_es(es, ES_RenderMode, kRenderTransAlpha);
					set_es(es, ES_RenderAmt, 50);
				}
				else
				{
					set_es(es, ES_RenderMode, kRenderTransTexture);
					set_es(es, ES_RenderAmt, 0);
				}
			}
			case 2:
			{
				if(g_ClanSlot[host] && (g_ClanSlot[host] == g_ClanSlot[ent]))
				{
					set_es(es, ES_RenderMode, kRenderTransAlpha);
					set_es(es, ES_RenderAmt, 50);
				}
				else
				{
					set_es(es, ES_RenderMode, kRenderTransTexture);
					set_es(es, ES_RenderAmt, 0);
				}
			}
		}
	}

	if(pev_valid(ent) && g_IsAlive[host])
	{
		if(g_UserOption_Invis[host] && !g_Zombie[host] && !g_ConvertZombie[host])
		{
			static iOwner;
			iOwner = entity_get_edict(ent, EV_ENT_owner);

			if(!isUserValidConnected(iOwner) || g_Zombie[iOwner])
				return FMRES_IGNORED;

			static sClassName[32];
			entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

			if(!equal(sClassName, ENT_CLASSNAME_HAT))
				return FMRES_IGNORED;

			set_es(es, ES_RenderMode, kRenderTransTexture);
			set_es(es, ES_RenderAmt, 0);
		}
	}

	return FMRES_IGNORED;
}

public fwd__CmdStartPre(const id, const uc_handle)
{
	if(!g_IsAlive[id])
		return FMRES_IGNORED;

	static iButton;
	static iOldButton;

	iButton = get_uc(uc_handle, UC_Buttons);
	iOldButton = entity_get_int(id, EV_INT_oldbuttons);

	switch(g_SpecialMode[id])
	{
		case MODE_WESKER:
		{
			if(g_ModeWesker_Laser[id] && get_gametime() >= g_ModeWesker_LaserLast[id] && (iButton & IN_ATTACK2) && !(iOldButton & IN_ATTACK2))
			{
				--g_ModeWesker_Laser[id];
				g_ModeWesker_LaserLast[id] = get_gametime() + 0.75;

				emitSound(id, CHAN_VOICE, SOUND_WESKER_LASER, .pitch=PITCH_HIGH);

				entity_set_vector(id, EV_FLARE_COLOR, Float:{-1.0, 0.0, 0.0});

				setAnimation(id, 1);

				if(g_Habs[id][HAB_L_W_ULTRA_LASER])
				{
					static Float:vecOrigin[3];
					static Float:vecViewOffset[3];
					static Float:vecStart[3];
					static Float:vecDest[3];
					static iTrace;
					static iEnt;
					static j;
					static iVictim;

					entity_get_vector(id, EV_VEC_origin, vecOrigin);
					entity_get_vector(id, EV_VEC_view_ofs, vecViewOffset);

					vecOrigin[0] += vecViewOffset[0];
					vecOrigin[1] += vecViewOffset[1];
					vecOrigin[2] += vecViewOffset[2];

					entity_get_vector(id, EV_VEC_origin, vecStart);

					vecStart[0] += vecViewOffset[0];
					vecStart[1] += vecViewOffset[1];
					vecStart[2] += vecViewOffset[2];

					entity_get_vector(id, EV_VEC_v_angle, vecDest);
					engfunc(EngFunc_MakeVectors, vecDest);
					global_get(glb_v_forward, vecDest);

					vecDest[0] *= 9999.0;
					vecDest[1] *= 9999.0;
					vecDest[2] *= 9999.0;
					
					vecDest[0] += vecStart[0];
					vecDest[1] += vecStart[1];
					vecDest[2] += vecStart[2];

					engfunc(EngFunc_TraceLine, vecStart, vecDest, 0, id, 0);
					get_tr2(0, TR_vecEndPos, vecViewOffset);

					vecViewOffset[0] -= vecOrigin[0];
					vecViewOffset[1] -= vecOrigin[1];
					vecViewOffset[2] -= vecOrigin[2];
					
					vecViewOffset[0] *= 10.0;
					vecViewOffset[1] *= 10.0;
					vecViewOffset[2] *= 10.0;
					
					vecViewOffset[0] += vecOrigin[0];
					vecViewOffset[1] += vecOrigin[1];
					vecViewOffset[2] += vecOrigin[2];

					iTrace = 0;
					iEnt = id;
					j = 0;

					while(engfunc(EngFunc_TraceLine, vecOrigin, vecViewOffset, 0, iEnt, iTrace))
					{
						++j;
						iVictim = get_tr2(iTrace, TR_pHit);

						if(j == 100)
							break;

						if(isUserValidAlive(iVictim) && g_Zombie[iVictim] && !g_SpecialMode[iVictim])
							ExecuteHamB(Ham_Killed, iVictim, id, 2);

						iEnt = iVictim;
						get_tr2(iTrace, TR_vecEndPos, vecOrigin);
					}

					static Float:vecPoint[3];
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
					write_byte(0);
					write_byte(255);
					write_byte(255);
					write_byte(255);
					write_byte(25);
					message_end();

					engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecPoint, 0);
					write_byte(TE_DLIGHT);
					engfunc(EngFunc_WriteCoord, vecPoint[0]);
					engfunc(EngFunc_WriteCoord, vecPoint[1]);
					engfunc(EngFunc_WriteCoord, vecPoint[2]);
					write_byte(30);
					write_byte(0);
					write_byte(255);
					write_byte(255);
					write_byte(15);
					write_byte(50);
					message_end();

					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_SPRITETRAIL);
					engfunc(EngFunc_WriteCoord, vecPoint[0]);
					engfunc(EngFunc_WriteCoord, vecPoint[1]);
					engfunc(EngFunc_WriteCoord, vecPoint[2] - 20.0);
					engfunc(EngFunc_WriteCoord, vecPoint[0]);
					engfunc(EngFunc_WriteCoord, vecPoint[1]);
					engfunc(EngFunc_WriteCoord, vecPoint[2] + 20.0);
					write_short(g_Sprite_ColorsBalls[6]);
					write_byte(200);
					write_byte(2);
					write_byte(5);
					write_byte(150);
					write_byte(255);
					message_end();
				}
				else
				{
					static iAimOrigin[3];
					static iTarget;
					static iBody;

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
					write_byte(10);
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

					if(isUserValidAlive(iTarget) && g_Zombie[iTarget] && !g_SpecialMode[iTarget])
					{
						message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
						write_byte(TE_SPRITETRAIL);
						write_coord(iAimOrigin[0]);
						write_coord(iAimOrigin[1]);
						write_coord(iAimOrigin[2] - 20);
						write_coord(iAimOrigin[0]);
						write_coord(iAimOrigin[1]);
						write_coord(iAimOrigin[2] + 20);
						write_short(g_Sprite_ColorsBalls[6]);
						write_byte(200);
						write_byte(2);
						write_byte(5);
						write_byte(150);
						write_byte(255);
						message_end();

						ExecuteHamB(Ham_Killed, iTarget, id, 2);
					}
				}
			}
		}
		case MODE_NEMESIS, MODE_ANNIHILATOR:
		{
			if(g_ModeNemesis_Bazooka[id] && get_gametime() >= g_ModeNemesis_BazookaLast[id] && g_CurrentWeapon[id] == CSW_AK47 && (iButton & IN_ATTACK) && !(iOldButton & IN_ATTACK) && !g_EndRound)
			{
				--g_ModeNemesis_Bazooka[id];

				if(!g_ModeNemesis_Bazooka[id])
					hamStripWeapon(id, "weapon_ak47", CSW_AK47);

				g_ModeNemesis_BazookaLast[id] = get_gametime() + 5.0;

				entity_set_vector(id, EV_FLARE_COLOR, Float:{-10.5, 0.0, 0.0});

				setAnimation(id, 8);

				static iEnt;
				iEnt = create_entity("info_target");

				if(is_valid_ent(iEnt))
				{
					static Float:vecOrigin[3];
					static Float:vecViewOffset[3];
					static Float:vecAngles[3];
					static Float:vecVelocity[3];

					entity_get_vector(id, EV_VEC_origin, vecOrigin);
					entity_get_vector(id, EV_VEC_view_ofs, vecViewOffset);

					vecOrigin[0] += vecViewOffset[0];
					vecOrigin[1] += vecViewOffset[1];
					vecOrigin[2] += vecViewOffset[2];

					entity_set_string(iEnt, EV_SZ_classname, ENT_CLASSNAME_ROCKET);
					entity_set_model(iEnt, MODEL_ROCKET);

					entity_set_size(iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
					entity_set_vector(iEnt, EV_VEC_mins, Float:{-1.0, -1.0, -1.0});
					entity_set_vector(iEnt, EV_VEC_maxs, Float:{1.0, 1.0, 1.0});

					entity_set_origin(iEnt, vecOrigin);

					entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
					entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
					entity_set_edict(iEnt, EV_ENT_owner, id);

					emitSound(iEnt, CHAN_WEAPON, SOUND_BAZOOKA[0]);

					velocity_by_aim(id, 1750, vecVelocity);
					entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

					vector_to_angle(vecVelocity, vecAngles);

					entity_set_vector(iEnt, EV_VEC_angles, vecAngles);

					entity_set_int(iEnt, EV_INT_renderfx, kRenderFxGlowShell);
					entity_set_vector(iEnt, EV_VEC_rendercolor, Float:{255.0, 0.0, 0.0});
					entity_set_int(iEnt, EV_INT_rendermode, kRenderNormal);
					entity_set_float(iEnt, EV_FL_renderamt, 4.0);

					entity_set_edict(iEnt, EV_ENT_FLARE, createFlareRocket(iEnt));

					entity_set_int(iEnt, EV_INT_effects, entity_get_int(iEnt, EV_INT_effects) | EF_BRIGHTLIGHT);

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
				}
			}
		}
		case MODE_AVSP:
		{
			if(g_SpecialMode_Alien[id])
			{
				if((iButton & IN_USE))
				{
					static Float:vecOrigin[3];
					entity_get_vector(id, EV_VEC_origin, vecOrigin);

					if(get_distance_f(vecOrigin, g_SpecialMode_AlienOrigin[id]) > 25.0 || (get_entity_flags(id) & FL_ONGROUND))
						return FMRES_IGNORED;

					if(iButton & IN_FORWARD)
					{
						static Float:vecVelocity[3];
						velocity_by_aim(id, 350, vecVelocity);
						entity_set_vector(id, EV_VEC_velocity, vecVelocity);
					}
					else if(iButton & IN_BACK)
					{
						static Float:vecVelocity[3];
						velocity_by_aim(id, -350, vecVelocity);
						entity_set_vector(id, EV_VEC_velocity, vecVelocity);
					}
				}
			}
		}
	}

	if(g_WeaponData[id][g_CurrentWeapon[id]][WEAPON_DATA_LEVEL] >= 10 && (iButton & IN_ATTACK) && g_WeaponSecondaryAutofire[id] && ((1<<g_CurrentWeapon[id]) & SECONDARY_WEAPONS_BIT_SUM))
	{
		set_uc(uc_handle, UC_Buttons, (iButton & ~IN_ATTACK));
		g_WeaponSecondaryAutofire[id] = 0;
	}

	return FMRES_IGNORED;
}

// **************************************************
//		[Ham Functions]
// **************************************************
public ham__PlayerSpawnPost(const id)
{
	if(!is_user_alive(id) || getUserTeam(id) == F_TEAM_NONE)
		return;

	g_IsAlive[id] = _:is_user_alive(id);

	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_REGENERATION);
	remove_task(id + TASK_IMMUNITY_P);
	remove_task(id + TASK_NIGHTVISION);
	remove_task(id + TASK_DRUG);
	remove_task(id + TASK_GRAB);
	remove_task(id + TASK_GRAB_PRETHINK);
	remove_task(id + TASK_GRUNT_GLOW);

	if(getUserAura(id))
		setUserAura(id);
	
	randomSpawn(id);

	set_task(0.4, "task__HideHUDs", id + TASK_SPAWN);

	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;

	if(g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_MEGA_ARMAGEDDON)
	{
		set_task(2.0, "task__RespawnCheckUser", id + TASK_SPAWN);
		
		if(g_Mode == MODE_GRUNT)
		{
			remove_task(id + TASK_GRUNT_AIMING);
			set_task(0.1, "task__ModeGruntAiming", id + TASK_GRUNT_AIMING);
		}
	}
	else
	{
		if(g_Mode == MODE_ARMAGEDDON && g_ModeArmageddon_Notice != 2)
		{
			dg_color_chat(id, _, "No puedes revivir en la mitad de un Armageddon");

			user_silentkill(id);
			return;
		}
		else if(g_Mode == MODE_MEGA_ARMAGEDDON && g_ModeMA_Reward[id] == 0)
		{
			dg_color_chat(id, _, "No puedes revivir en la mitad de un Mega Armageddon");

			user_silentkill(id);
			return;
		}
	}

	if(!g_NewRound && !g_EndRound)
	{
		if(g_Mode == MODE_SURVIVOR || g_Mode == MODE_WESKER || g_Mode == MODE_SNIPER_ELITE || g_Mode == MODE_JASON)
			g_RespawnAsZombie[id] = 1;
		else if(g_Mode == MODE_NEMESIS || g_Mode == MODE_ASSASSIN || g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_MEGA_ARMAGEDDON || g_Mode == MODE_GRUNT)
			g_RespawnAsZombie[id] = 0;
	}

	g_FirstRespawn[id] = 0;

	if(g_AmuletNextEquip[id] != -1)
	{
		g_AmuletEquip[id] = g_AmuletNextEquip[id];
		g_AmuletNextEquip[id] = -1;
	}

	if(g_HatNext[id])
		setHat(id, g_HatNext[id]);
	else if(g_HatId[id])
	{
		if(is_valid_ent(g_HatEnt[id]))
		{
			if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL && g_Mode != MODE_GRUNT)
			{
				entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderNormal);
				entity_set_float(g_HatEnt[id], EV_FL_renderamt, 255.0);
			}
			else
			{
				entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(g_HatEnt[id], EV_FL_renderamt, 0.0);
			}
		}
	}

	if(g_RespawnAsZombie[id] && !g_NewRound)
	{
		resetVars(id, .reset_all=0);

		zombieMe(id);
		return;
	}

	g_DeadTimes[id] = 0;
	g_ModeL4D2_ZobieHealth[id] = 0;
	g_MayorMuerte[id] = 0;

	resetVars(id, .reset_all=0);

	if(g_Mode == MODE_ANNIHILATOR && !g_ModeAnnihilator_Acerts[id])
	{
		static iValue;
		TrieGetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], iValue);

		if(iValue)
			g_ModeAnnihilator_Acerts[id] = iValue;
		else
			iValue = 0;

		TrieSetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], (iValue + 1));
	}
	else if(g_Mode == MODE_ARMAGEDDON)
	{
		zombieMe(id, .nemesis=1);
		return;
	}
	else if(g_Mode == MODE_MEGA_ARMAGEDDON)
	{
		if(g_ModeMA_Reward[id] == 2)
			zombieMe(id, .nemesis=1);
		else
		{
			g_ModeMA_Reward[id] = 1;

			if(!g_Zombie[id])
				humanMe(id, .survivor=1);
			else
				zombieMe(id, .nemesis=1);
		}

		return;
	}

	g_Achievement_WeskerHead[id] = 0;
	g_Achievement_SniperAwp[id] = 0;
	g_Achievement_SniperScout[id] = 0;
	g_Achievement_SniperHead[id] = 0;
	g_Hat_Devil[id] = 0;
	g_Hat_Earth[id] = -999;

	set_task(0.19, "task__ClearWeapons", id + TASK_SPAWN);
	set_task(0.2, "task__SetWeapons", id + TASK_SPAWN);

	set_user_health(id, humanHealth(id));
	g_Speed[id] = Float:humanSpeed(id);
	set_user_gravity(id, Float:humanGravity(id));
	set_user_armor(id, humanArmor(id));

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || (g_MiniGame_Habs && !canUseMiniGames(id)))
	{
		if(g_MiniGame_Habs && !canUseMiniGames(id))
			set_user_health(id, HUMAN_BASE_HEALTH_MIN);
		else
		{
			if(g_Mode != MODE_MEGA_GUNGAME)
				set_user_health(id, 100);
			else
			{
				static iHealthExtra;
				iHealthExtra = (100 + g_ModeMGG_Health[id]);

				if(iHealthExtra >= 150)
					set_user_health(id, 150);
				else
					set_user_health(id, iHealthExtra);
			}

			if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME)
			{
				set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 125);

				g_ModeGG_Immunity[id] = 1;

				remove_task(id + TASK_IMMUNITY_GG);
				set_task(1.5, "task__RemoveImmunityGunGame", id + TASK_IMMUNITY_GG);
			}
		}

		g_Speed[id] = HUMAN_BASE_SPEED_MIN;
		set_user_gravity(id, 1.0);
		set_user_armor(id, 0);
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), MODELS[g_ModelSelected[id][MODEL_HUMAN]][modelName]);

	if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL)
	{
		if(!g_NewRound && getUserTeam(id) != F_TEAM_CT)
		{
			remove_task(id + TASK_TEAM);

			setUserTeam(id, F_TEAM_CT);
			setUserTeamUpdate(id);
		}

		set_user_rendering(id);
	}

	setUserAllModels(id);
	turnOffFlashlight(id);

	new iWeaponEnt;
	iWeaponEnt = getCurrentWeaponEnt(id);

	if(pev_valid(iWeaponEnt))
		replaceWeaponModels(id, cs_get_weapon_id(iWeaponEnt));

	checkLastZombie();

	if(!g_NewRound && !g_EndRound && g_ClanSlot[id])
	{
		if(g_ClanCombo[g_ClanSlot[id]] && g_Mode != MODE_ANNIHILATOR)
		{
			sendClanMessage(id, "Un miembro humano del clan ha respawneado como humano y el combo ha finalizado");
			clanFinishCombo(id);
		}

		clanUpdateHumans(id);
	}
}

public tribalModeKill(const killer, const victim)
{
	if(!getZombies())
		tribalModeWin();
}

public tribalModeWin()
{
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i])
			continue;

		if(g_SpecialMode[i] != MODE_TRIBAL)
			continue;

		++g_Stats[i][STAT_T_M_WIN];

		dg_color_chat(0, _, "!t%s!y ganó !g%d pH!y y !g1 pL!y por ganar el modo !tTRIBAL!y", g_PlayerName[i], (g_PointsMult[i] + 1));
		
		g_Points[i][POINT_HUMAN] += (g_PointsMult[i] + 1);
		++g_Points[i][POINT_LEGACY];
	}
}

public ham__PlayerKilledPre(const victim, const killer, const should_gib)
{
	setUserAura(victim);

	remove_task(victim + TASK_BURNING_FLAME);
	remove_task(victim + TASK_FREEZE);
	remove_task(victim + TASK_SLOWDOWN);
	remove_task(victim + TASK_MADNESS);
	remove_task(victim + TASK_PAINSHOCK);
	remove_task(victim + TASK_POWER_SNIPER_ELITE);
	remove_task(victim + TASK_POWER_FVSJ_JASON);
	remove_task(victim + TASK_POWER_PREDATOR);
	remove_task(victim + TASK_POWER_ASSASSIN);
	remove_task(victim + TASK_POWER_SNIPER);
	remove_task(victim + TASK_IMMUNITY_BOMB);
	remove_task(victim + TASK_IMMUNITY_GG);
	remove_task(victim + TASK_REGENERATION);
	remove_task(victim + TASK_IMMUNITY_P);
	remove_task(victim + TASK_DRUG);
	remove_task(victim + TASK_GRAB);
	remove_task(victim + TASK_GRAB_PRETHINK);
	remove_task(victim + TASK_GRUNT_AIMING);
	remove_task(victim + TASK_GRUNT_GLOW);

	g_IsAlive[victim] = 0;
	g_PlayerSolid[victim] = 0;
	g_PlayerRestore[victim] = 0;
	g_Immunity[victim] = 0;

	if(g_Zombie[victim])
	{
		if(g_SpecialMode[victim])
			SetHamParamInteger(3, 2);

		if(g_Mode != MODE_SNIPER_ELITE)
			++g_DeadTimes[victim];

		++g_MayorMuerte[victim];
		++g_ModeL4D2_ZobieHealth[victim];

		g_Achievement_InfectsWithMaxHP[victim] = 100;

		finishComboZombie(victim);
	}
	else
	{
		if(g_ClanSlot[victim])
		{
			if(g_ClanCombo[g_ClanSlot[victim]] && g_Mode != MODE_ANNIHILATOR)
			{
				sendClanMessage(victim, "Un miembro humano del clan fue asesinado y el combo ha finalizado");
				clanFinishCombo(victim);
			}

			clanUpdateHumans(victim);
		}

		finishComboHuman(victim);

		if(g_Mode == MODE_TRIBAL)
		{
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_SpecialMode[i] == MODE_TRIBAL)
					remove_task(i + TASK_POWER_TRIBAL);
			}
		}
	}

	g_DrugBombCount[victim] = 0;
	g_DrugBombMove[victim] = 0;

	if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL && g_Mode != MODE_ASSASSIN)
		set_task(0.1, "task__SpecNightvision", victim);

	switch(g_Mode)
	{
		case MODE_MEGA_ARMAGEDDON:
		{
			if(g_Zombie[victim])
				g_ModeMA_AllZombies = 0;
			else if(!g_Zombie[victim])
				g_ModeMA_AllHumans = 0;
			
			if(killer != victim && isUserValidConnected(killer))
			{
				++g_ModeMA_Kills[killer][victim];

				if(g_ModeMA_Kills[killer][victim] == 2)
				{
					if(g_Zombie[killer])
						setAchievement(killer, MA_KILL_AGAIN_H);
					else
						setAchievement(killer, MA_KILL_AGAIN_Z);
				}

				if(g_Zombie[killer] && !g_Zombie[victim])
				{
					if(g_SpecialMode[victim] == MODE_SURVIVOR)
					{
						++g_ModeMA_SurvivorKills[killer];

						if(g_ModeMA_SurvivorKills[killer] == 2)
							setAchievement(killer, MA_KILL_S_x2);
					}
					else
					{
						++g_ModeMA_HumanKills[killer];

						if(g_ModeMA_HumanKills[killer] == 5)
							setAchievement(killer, MA_KILL_H_x5);
					}
				}
				else if(!g_Zombie[killer] && g_Zombie[victim])
				{
					if(g_SpecialMode[victim] == MODE_NEMESIS)
					{
						++g_ModeMA_NemesisKills[killer];

						if(g_ModeMA_NemesisKills[killer] == 2) {
							setAchievement(killer, MA_KILL_N_x2);
						}
					}
					else
					{
						++g_ModeMA_ZombieKills[killer];

						if(g_ModeMA_ZombieKills[killer] == 5)
							setAchievement(killer, MA_KILL_Z_x5);
					}
				}
			}

			if(g_SpecialMode[victim] == MODE_NEMESIS && !getZombies())
				endModeMegaArmageddon(1);
			else if(g_SpecialMode[victim] == MODE_SURVIVOR && !getHumans())
				endModeMegaArmageddon(0);
			else if(g_LastHuman[victim])
				checkModeMegaArmageddonTwo(1);
			else if(g_LastZombie[victim])
				checkModeMegaArmageddonTwo(0);
		}
		case MODE_GUNGAME:
		{
			if(victim != killer && isUserValidConnected(killer))
			{
				++g_ModeGG_Kills[killer];

				if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD)
				{
					++g_ModeGG_Headshots[killer];

					if(g_ModeGG_Headshots[killer] >= 20)
					{
						setAchievement(killer, GG_HEADSHOTS_x20);

						if(g_ModeGG_Headshots[killer] >= 30)
						{
							setAchievement(killer, GG_HEADSHOTS_x30);

							if(g_ModeGG_Headshots[killer] >= 40)
								setAchievement(killer, GG_HEADSHOTS_x40);
						}
					}
				}

				if((g_ModeGG_Type == GUNGAME_CLASSIC && g_CurrentWeapon[killer] == CSW_KNIFE) || g_ModeGG_Kills[killer] >= ((g_ModeGG_Type == GUNGAME_SLOW) ? 3 : (g_ModeGG_Type == GUNGAME_FAST) ? 1 : 2))
				{
					if(g_ModeGG_Type == GUNGAME_CLASSIC && g_CurrentWeapon[killer] == CSW_KNIFE)
					{
						g_ModeGG_Kills[victim] = 0;

						if(--g_ModeGG_Level[victim] <= 0)
							g_ModeGG_Level[victim] = 1;
					}

					g_ModeGG_Kills[killer] = 0;
					++g_ModeGG_Level[killer];

					if(g_ModeGG_Level[killer] != 27)
					{
						playSound(killer, SOUND_ROUND_GUNGAME);

						strip_user_weapons(killer);

						if(g_ModeGG_Type == GUNGAME_CRAZY)
						{
							if(g_ModeGG_Level[killer] != 26)
							{
								g_ModeGGCrazy_ListLevel[killer][g_ModeGGCrazy_Level[killer]] = 1;

								static j;
								static iListLevels[26];

								j = 0;

								for(new i = 0; i < 26; ++i)
								{
									if(!g_ModeGGCrazy_ListLevel[killer][i])
									{
										iListLevels[j] = i;
										++j;
									}
								}
								
								g_ModeGGCrazy_Level[killer] = iListLevels[random_num(0, (j - 1))];
							}
							else
								g_ModeGGCrazy_Level[killer] = 26;
						}

						gunGameGiveWeapons(killer);
						gunGameBestUsers();
					}
					else
					{
						g_ModeGG_End = 1;

						set_cvar_num("mp_round_infinite", 0);

						dg_color_chat(0, SPECTATOR, "El ganador del !tGUNGAME!y es !g%s!y", g_PlayerName[killer]);

						++g_Stats[killer][STAT_GG_WINS];

						if(g_Stats[killer][STAT_GG_WINS] >= 1)
						{
							setAchievement(killer, GG_WIN_x1);

							if(g_Stats[killer][STAT_GG_WINS] >= 10)
								setAchievement(killer, GG_WIN_x10);
						}

						static iUnique;
						static iByFar;
						static iRewardAPs;
						static iRewardXP;
						static sRewardAPs[16];
						static sRewardXP[16];

						iUnique = 1;
						iByFar = 1;
						iRewardAPs = 0;
						iRewardXP = 0;
						sRewardAPs[0] = EOS;
						sRewardXP[0] = EOS;

						for(new i = 1; i <= g_MaxPlayers; ++i)
						{
							if(g_IsConnected[i] && g_AccountLogged[i])
							{
								if(g_ModeGG_Level[i] == 25 || g_ModeGG_Level[i] == 26)
								{
									setAchievement(i, GG_ALMOST_WIN);

									if(g_ModeGG_Level[i] == 26)
										iUnique = 0;

									iByFar = 0;
								}

								iRewardAPs = ((((g_AmmoPacksMult[i] * (g_HappyTime + 1)) + GUNGAME_REWARD[g_ModeGG_Type]) * g_ModeGG_Level[i]) * (g_Level[i] + (g_Reset[i] * MAX_LEVEL)));
								addDot(iRewardAPs, sRewardAPs, charsmax(sRewardAPs));
								
								iRewardXP = ((((10 * (g_ExpMult[i] * (g_HappyTime + 1))) + GUNGAME_REWARD[g_ModeGG_Type]) * g_ModeGG_Level[i]) * (g_Level[i] + (g_Reset[i] * MAX_LEVEL)));
								addDot(iRewardXP, sRewardXP, charsmax(sRewardXP));

								for(new j = 0; j < structIdPoints; ++j)
								{
									if(j == POINT_HUMAN || j == POINT_ZOMBIE)
										g_Points[i][j] += g_ModeGG_Level[i];
								}

								dg_color_chat(i, _, "Ganaste !g%s APs!y, !g%s XP!y y !g%d pHZ!y", sRewardAPs, sRewardXP, g_ModeGG_Level[i]);
								
								addAPs(i, iRewardAPs);
								addXP(i, iRewardXP);
								
								if(g_IsAlive[i])
									user_kill(i, 1);
							}
						}

						if(iUnique)
							setAchievement(killer, GG_WIN_UNIQUE);

						if(iByFar)
							setAchievement(killer, GG_WIN_BY_FAR);

						if((get_systime() - g_ModeGG_SysTime) < 120)
							setAchievement(killer, GG_FAST_WIN);

						if(g_AccountId[killer] == g_ModeGG_LastWinner)
							setAchievement(killer, GG_WIN_CONSECUTIVE);

						g_ModeGG_LastWinner = g_AccountId[killer];
					}
				}
			}

			return;
		}
		case MODE_MEGA_GUNGAME:
		{
			if(victim != killer && isUserValidConnected(killer))
			{
				megaGunGameAddKill(killer);

				if(g_ModeMGG_Health[victim] < 150)
					g_ModeMGG_Health[victim] += 5;
			}

			return;
		}
		case MODE_TRIBAL: tribalModeKill(killer, victim);
		case MODE_DRUNK:
		{
			if(getZombies() < 1)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i])
						continue;

					if(g_Zombie[i])
						continue;

					g_Points[i][POINT_HUMAN] += 2;
					g_Points[i][POINT_ZOMBIE] += 2;

					if(g_SpecialMode[i] != MODE_SNIPER)
						dg_color_chat(i, _, "Ganaste !g2 pHZ!y por ganar el modo !gDRUNK!y");
					else
					{
						++g_Points[i][POINT_HUMAN];
						dg_color_chat(i, _, "Ganaste !g3 pH!y y !g2 pZ!y por ganar el modo !gDRUNK!y siendo !gSNIPER!y");
					}
				}
			}
			else if(getHumans() < 1)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i])
						continue;

					if(!g_Zombie[i])
						continue;

					g_Points[i][POINT_HUMAN] += 2;
					g_Points[i][POINT_ZOMBIE] += 2;

					dg_color_chat(i, _, "Ganaste !g2 pHZ!y por ganar el modo !gDRUNK!y");
				}
			}
		}
		case MODE_AVSP: checkModeAvsP(victim);
		case MODE_DUEL_FINAL:
		{
			if(victim != killer && isUserValidConnected(killer))
			{
				static iVictimTeam;
				iVictimTeam = getUserTeam(victim);

				if(iVictimTeam == getUserTeam(killer))
				{
					setUserTeam(victim, ((iVictimTeam == F_TEAM_T) ? F_TEAM_CT : F_TEAM_T));
					ExecuteHamB(Ham_Killed, victim, killer, should_gib);
					setUserTeam(victim, iVictimTeam);
				}

				++g_ModeDuelFinal_KillsTotal[killer];
				++g_ModeDuelFinal_Kills[killer];

				switch(g_ModeDuelFinal_Type)
				{
					case DF_TYPE_KNIFE:
					{
						++g_ModeDuelFinal_KillsKnife[killer];

						if(g_ModeDuelFinal_KillsKnife[killer] >= 5)
						{
							setAchievement(killer, ACUCHILLADOS);

							if(g_ModeDuelFinal_KillsKnife[killer] >= 10)
							{
								setAchievement(killer, AFISIONADO_EN_CUCHI);

								if(g_ModeDuelFinal_KillsKnife[killer] >= 15)
									setAchievement(killer, ENTRA_CUCHI_SALEN_TRIPAS);
							}
						}
					}
					case DF_TYPE_AWP:
					{
						++g_ModeDuelFinal_KillsAwp[killer];

						if(g_ModeDuelFinal_KillsAwp[killer] >= 5)
						{
							setAchievement(killer, TODO_UN_AWPER);

							if(g_ModeDuelFinal_KillsAwp[killer] >= 10)
							{
								setAchievement(killer, EXPERTO_EN_AWP);

								if(g_ModeDuelFinal_KillsAwp[killer] >= 15)
									setAchievement(killer, PRO_AWP);
							}
						}
					}
					case DF_TYPE_HE:
					{
						++g_ModeDuelFinal_KillsHE[killer];

						if(g_ModeDuelFinal_KillsHE[killer] >= 5)
						{
							setAchievement(killer, DETONADOS);

							if(g_ModeDuelFinal_KillsHE[killer] >= 10)
							{
								setAchievement(killer, BOMBAZO_PARA_TODOS);

								if(g_ModeDuelFinal_KillsHE[killer] >= 15)
									setAchievement(killer, BOOM_EN_TODA_LA_CARA);
							}
						}
					}
					case DF_TYPE_OH:
					{
						++g_ModeDuelFinal_KillsDeagle[killer];

						if(g_ModeDuelFinal_KillsDeagle[killer] >= 5)
						{
							setAchievement(killer, SENTADO);

							if(g_ModeDuelFinal_KillsDeagle[killer] >= 10)
							{
								setAchievement(killer, PUM_BALAZO);

								if(g_ModeDuelFinal_KillsDeagle[killer] >= 15)
									setAchievement(killer, THE_KILLER_OF_DK);
							}
						}
					}
					case DF_TYPE_M3:
					{
						++g_ModeDuelFinal_KillsM3[killer];

						if(g_ModeDuelFinal_KillsM3[killer] >= 5)
						{
							setAchievement(killer, PUM_CHSCHS);

							if(g_ModeDuelFinal_KillsM3[killer] >= 10)
							{
								setAchievement(killer, LA_RECORTADA_DEL_PUNTO_6);

								if(g_ModeDuelFinal_KillsM3[killer] >= 15)
									setAchievement(killer, PA_TODO_EL_SV);
							}
						}
					}
				}

				if(!g_ModeDuelFinal_First)
				{
					g_ModeDuelFinal_First = 1;
					setAchievement(victim, SOY_MUY_NOOB);
				}
			}

			if(getHumans() == 1)
			{
				++g_ModeDuelFinal;

				if(g_ModeDuelFinal == DF_QUARTER || g_ModeDuelFinal == DF_SEMIFINAL || g_ModeDuelFinal == DF_FINAL)
					user_kill(killer, 1);
				else if(g_ModeDuelFinal == DF_FINISH)
					set_user_godmode(killer, 1);

				remove_task(TASK_MODE_DUEL_FINAL);
				set_task(2.0, "task__ModeDuelFinal", TASK_MODE_DUEL_FINAL);
			}

			return;
		}
		case MODE_GRUNT:
		{
			if(getHumans() == 1)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i] || g_SpecialMode[i])
						continue;

					dg_color_chat(0, _, "!t%s!y ganó !g%d pH!y por ser el último humano vivo en el modo !tGRUNT!y", g_PlayerName[i], g_PointsMult[i]);
					g_Points[i][POINT_HUMAN] += g_PointsMult[i];

					break;
				}
			}
			
			return;
		}
	}

	if(victim == killer || !isUserValidConnected(killer))
		return;

	static iReward;
	iReward = 0;

	if(!g_Zombie[killer])
	{
		++g_Stats[killer][STAT_ZM_D];
		++g_Stats[victim][STAT_ZM_T];

		if(g_Stats[killer][STAT_ZM_D] >= 100)
		{
			setAchievement(killer, ZOMBIES_x100);

			if(g_Stats[killer][STAT_ZM_D] >= 500)
			{
				setAchievement(killer, ZOMBIES_x500);

				if(g_Stats[killer][STAT_ZM_D] >= 1000)
				{
					setAchievement(killer, ZOMBIES_x1000);

					if(g_Stats[killer][STAT_ZM_D] >= 2500)
					{
						setAchievement(killer, ZOMBIES_x2500);
						giveHat(killer, HAT_ANGEL);

						if(g_Stats[killer][STAT_ZM_D] >= 5000)
						{
							setAchievement(killer, ZOMBIES_x5000);

							if(g_Stats[killer][STAT_ZM_D] >= 10000)
							{
								setAchievement(killer, ZOMBIES_x10K);

								if(g_Stats[killer][STAT_ZM_D] >= 25000)
								{
									setAchievement(killer, ZOMBIES_x25K);

									if(g_Stats[killer][STAT_ZM_D] >= 50000)
									{
										setAchievement(killer, ZOMBIES_x50K);

										if(g_Stats[killer][STAT_ZM_D] >= 100000)
										{
											setAchievement(killer, ZOMBIES_x100K);

											if(g_Stats[killer][STAT_ZM_D] >= 500000)
											{
												setAchievement(killer, ZOMBIES_x500K);

												if(g_Stats[killer][STAT_ZM_D] >= 1000000)
												{
													setAchievement(killer, ZOMBIES_x1M);

													if(g_Stats[killer][STAT_ZM_D] >= 5000000)
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

		if(g_ClanSlot[killer] && g_Clan[g_ClanSlot[killer]][clanCountOnlineMembers] > 1)
			++g_Clan[g_ClanSlot[killer]][clanKillDone];

		if(should_gib == 1) // Nos aseguramos de que no lo haya matado con una bomba de aniquilación (o muerte por explosión)
		{
			if(!g_SpecialMode[killer])
			{
				if(g_Mode == MODE_PLAGUE)
				{
					++g_AchievementSecret_AplZombie[killer];

					if(g_AchievementSecret_AplZombie[killer] >= 7)
						setAchievement(killer, APLASTA_ZOMBIES);
				}

				++g_WeaponData[killer][g_CurrentWeapon[killer]][WEAPON_DATA_KILL_DONE];
				++g_WeaponData[killer][g_CurrentWeapon[killer]][WEAPON_DATA_KILL_S_DONE];

				if(g_CurrentWeapon[killer] == CSW_AK47)
					++g_AchievementSecret_Terrorist[killer];

				/*++g_logros_stats[killer][KILL_ZOMBIES_IN_PZ];

				if(g_logros_stats[killer][KILL_ZOMBIES_IN_PZ] == 10)
					setAchievement(killer, DIEZ_A_LA_Z);*/
			}
			else
			{
				if(g_SpecialMode[killer] == MODE_SURVIVOR)
				{
					++g_AchievementSecret_Resistencia[killer];

					if(g_AchievementSecret_Resistencia[killer] >= 2500)
						setAchievement(killer, RESISTENCIA);
				}
				else if(g_SpecialMode[killer] == MODE_WESKER)
				{
					++g_AchievementSecret_Albert[killer];

					if(g_AchievementSecret_Albert[killer] >= 2500)
						setAchievement(killer, ALBERT_WESKER);
				}
				if(g_SpecialMode[killer] == MODE_AVSP && g_SpecialMode_Predator[killer])
				{
					++g_AchievementSecret_Predator[killer];

					if(g_AchievementSecret_Predator[killer] >= 8)
						setAchievement(killer, DEPREDADOR_FINAL);
				}
				else if(g_SpecialMode[killer] == MODE_SNIPER && g_Mode != MODE_DRUNK)
				{
					if(g_CurrentWeapon[killer] == CSW_AWP)
					{
						++g_Achievement_SniperAwp[killer];

						if(g_Achievement_SniperAwp[killer] == 8)
							setAchievement(killer, MI_AWP_ES_MEJOR);
					}
					else
					{
						++g_Achievement_SniperScout[killer];

						if(g_Achievement_SniperScout[killer] == 8)
							setAchievement(killer, MI_SCOUT_ES_MEJOR);
					}
				}
				/*else if(g_jason[killer])
				{
					++g_logros_stats[killer][KILL_JASON_ZOMBIES];

					if(g_logros_stats[killer][KILL_JASON_ZOMBIES] >= 15)
						setAchievement(killer, CARNICERO);
				}*/
			}

			iReward = getConversionPercent(killer, 5);

			if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD)
			{
				iReward = getConversionPercent(killer, 10);

				++g_Stats[killer][STAT_ZMHS_D];
				++g_Stats[victim][STAT_ZMHS_T];

				if(g_Stats[killer][STAT_ZMHS_D] >= 1000)
				{
					setAchievement(killer, LIDER_EN_CABEZAS);

					if(g_Stats[killer][STAT_ZMHS_D] >= 10000)
					{
						setAchievement(killer, AGUJEREANDO_CABEZAS);

						if(g_Stats[killer][STAT_ZMHS_D] >= 50000)
						{
							setAchievement(killer, MORTIFICANDO_ZOMBIES);

							if(g_Stats[killer][STAT_ZMHS_D] >= 100000)
								setAchievement(killer, CABEZAS_ZOMBIES);
						}
					}
				}

				/*if(g_SpecialMode[killer] == MODE_WESKER)
				{
					++g_Achievement_WeskerHead[killer];

					if(g_Achievement_WeskerHead[killer] == 10)
						setAchievement(killer, RESIDENT_EVIL);
				}
				else */
				if(g_SpecialMode[killer] == MODE_SNIPER && g_Mode != MODE_DRUNK)
				{
					++g_Achievement_SniperHead[killer];

					if(g_Achievement_SniperHead[killer] == 8)
						setAchievement(killer, ZAS_EN_TODA_LA_BOCA);
				}
			}

			if(!g_SpecialMode[killer] && g_CurrentWeapon[killer] == CSW_KNIFE)
			{
				if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD)
					iReward = getConversionPercent(killer, 25);
				else
					iReward = getConversionPercent(killer, 10);

				++g_Stats[killer][STAT_ZMK_D];
				++g_Stats[victim][STAT_ZMK_T];

				if(g_Stats[killer][STAT_ZMK_D] >= 1)
				{
					setAchievement(killer, AFILANDO_MI_CUCHILLO);

					if(g_SpecialMode[victim] == MODE_NEMESIS)
						setAchievement(killer, MI_CUCHILLO_ES_ROJO);
					else if(g_SpecialMode[victim] == MODE_ANNIHILATOR)
						setAchievement(killer, CHUCK_NORRIS);

					if(g_Stats[killer][STAT_ZMK_D] >= 30)
					{
						setAchievement(killer, ACUCHILLANDO);

						if(g_Stats[killer][STAT_ZMK_D] >= 50)
						{
							setAchievement(killer, ME_ENCANTAN_LAS_TRIPAS);

							if(g_Stats[killer][STAT_ZMK_D] >= 100)
							{
								setAchievement(killer, HUMMILACION);

								if(g_Stats[killer][STAT_ZMK_D] >= 150)
								{
									setAchievement(killer, CLAVO_QUE_TE_CLAVO_LA_SOMBRILLA);

									if(g_Stats[killer][STAT_ZMK_D] >= 200)
									{
										setAchievement(killer, ENTRA_CUCHILLO_SALEN_LAS_TRIPAS);

										if(g_Stats[killer][STAT_ZMK_D] >= 250)
										{
											setAchievement(killer, HUMILIATION_DEFEAT);

											if(g_Stats[killer][STAT_ZMK_D] >= 500)
											{
												setAchievement(killer, CUCHILLO_DE_COCINA);
												giveHat(killer, HAT_SASHA);	
												
												if(g_Stats[killer][STAT_ZMK_D] >= 1000)
												{
													setAchievement(killer, CUCHILLO_PARA_PIZZA);

													if(g_Stats[killer][STAT_ZMK_D] >= 5000)
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

		static iRandomPercent;
		static iHeadZombiePercent;

		iRandomPercent = random_num(1, 100);
		iHeadZombiePercent = ((g_HappyTime == 2) ? 50 : 75);

		if(iRandomPercent <= iHeadZombiePercent)
		{
			static Float:vecOrigin[3];
			static Float:vecEndOrigin[3];
			static iTraceResult;
			static Float:fFraction;

			entity_get_vector(victim, EV_VEC_origin, vecOrigin);
			getDropOrigin(victim, vecEndOrigin, 20);

			iTraceResult = 0;
			engfunc(EngFunc_TraceLine, vecOrigin, vecEndOrigin, IGNORE_MONSTERS, victim, iTraceResult);

			get_tr2(iTraceResult, TR_flFraction, fFraction);

			if(fFraction == 1.0 && !g_MiniGameTejo_On)
				dropHeadZombie(victim);
		}
	}
	else
	{
		++g_Stats[killer][STAT_HM_D];
		++g_Stats[victim][STAT_HM_T];

		switch(g_SpecialMode[killer])
		{
			case MODE_NEMESIS:
			{
				if(g_Mode == MODE_SYNAPSIS)
					++g_ModeSynapsis_NemesisKill[killer];
				
				++g_AchievementSecret_Nemesis[killer];

				if(g_AchievementSecret_Nemesis[killer] >= 2500)
					setAchievement(killer, EL_TERROR_EXISTE);
			}
			case MODE_ASSASSIN:
			{
				if(g_Mode == MODE_ASSASSIN)
				{
					g_ModeAssassin_RewardHumans -= (((g_HappyTime == 2) ? 5 : ((g_HappyTime == 1) ? 4 : 2)) * MAX_XP_ASSASSIN_REWARD);

					if(g_ModeAssassin_RewardHumans < 0)
						g_ModeAssassin_RewardHumans = 0;

					g_ModeAssassin_RewardAssassin += (((g_HappyTime == 2) ? 5 : ((g_HappyTime == 1) ? 4 : 2)) * MAX_XP_ASSASSIN_REWARD);
				}
			}
			case MODE_ANNIHILATOR:
			{
				++g_ModeAnnihilator_Kills[killer];

				if(g_CurrentWeapon[killer] == CSW_KNIFE)
					++g_Achievement_AnnKnife[killer];
				else if(g_CurrentWeapon[killer] == CSW_MAC10)
					++g_Achievement_AnniMac10[killer];
			}
			case MODE_AVSP:
			{
				if(g_SpecialMode_Alien[killer])
				{
					++g_AchievementSecret_Alien[killer];

					if(g_AchievementSecret_Alien[killer] >= 10)
						setAchievement(killer, ZANGANO_REAL);
				}
			}
			default:
			{
				if(g_Mode == MODE_PLAGUE)
				{
					++g_AchievementSecret_AsesinoTurn[killer];

					if(g_AchievementSecret_AsesinoTurn[killer] >= 8)
						setAchievement(killer, ASESINO_DE_TURNO);
				}
			}
		}

		iReward = getConversionPercent(killer, 50);
	}

	addAPs(killer, (g_Level[victim] + (g_Reset[victim] * MAX_LEVEL)));
	addXP(killer, iReward);

	if(g_SpecialMode[victim])
	{
		static iPointClass;
		iPointClass = ((g_Zombie[killer]) ? POINT_ZOMBIE : POINT_HUMAN);

		if(g_Mode == MODE_MEGA_ARMAGEDDON)
		{
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				if(g_Zombie[killer] == g_Zombie[i])
					g_Points[i][iPointClass] += g_PointsMult[killer];
			}

			dg_color_chat(0, ((g_Zombie[killer]) ? TERRORIST : CT), "!t%s!y ganaron !g%d p%c!y por matar a un !g%s!y", ((g_Zombie[killer]) ? "ZOMBIES" : "HUMANOS"), g_PointsMult[killer], ((iPointClass == POINT_ZOMBIE) ? 'Z' : 'H'), g_PlayerClassName[victim]);
		}
		else
		{
			static iReward;
			static iRewardPL;

			iReward = 0;
			iRewardPL = (1 + g_Habs[killer][HAB_D_MORE_PL]);

			if(g_Mode != MODE_ARMAGEDDON)
			{
				if(g_SpecialMode[victim] == MODE_SNIPER)
					iReward = 1;
			}

			g_Points[killer][iPointClass] += (g_PointsMult[killer] + iReward);
			g_Points[killer][POINT_LEGACY] += iRewardPL;

			dg_color_chat(0, ((g_Zombie[killer]) ? TERRORIST : CT), "!t%s!y ganó !g%d p%c!y y !g%d pL!y por matar a un !g%s!y", g_PlayerName[killer], (g_PointsMult[killer] + iReward), ((iPointClass == POINT_ZOMBIE) ? 'Z': 'H'), iRewardPL, g_PlayerClassName[victim]);
		}

		switch(g_SpecialMode[victim])
		{
			case MODE_SURVIVOR:
			{
				++g_Stats[victim][STAT_S_M_LOSE];
				++g_Stats[killer][STAT_S_M_KILL];

				if(g_Stats[killer][STAT_S_M_KILL] >= 100)
					giveHat(killer, HAT_JACKOLANTERN);
			}
			case MODE_WESKER:
			{
				++g_Stats[victim][STAT_W_M_LOSE];
				++g_Stats[killer][STAT_W_M_KILL];
			}
			case MODE_SNIPER_ELITE:
			{
				++g_Stats[victim][STAT_SN_M_LOSE];
				++g_Stats[killer][STAT_SN_M_KILL];
			}
			case MODE_JASON:
			{
				++g_Stats[victim][STAT_J_M_LOSE];
				++g_Stats[killer][STAT_J_M_KILL];
			}
			case MODE_TRIBAL:
			{
				++g_Stats[victim][STAT_T_M_LOSE];
				++g_Stats[killer][STAT_T_M_KILL];
			}
			case MODE_NEMESIS:
			{
				++g_Stats[victim][STAT_N_M_LOSE];
				++g_Stats[killer][STAT_N_M_KILL];

				if(g_Stats[killer][STAT_N_M_KILL] >= 100)
					giveHat(killer, HAT_JAMACA);
			}
			case MODE_ASSASSIN:
			{
				++g_Stats[victim][STAT_A_M_LOSE];
				++g_Stats[killer][STAT_A_M_KILL];
			}
			case MODE_ANNIHILATOR:
			{
				++g_Stats[victim][STAT_AN_M_LOSE];
				++g_Stats[killer][STAT_AN_M_KILL];
			}
			case MODE_FVSJ:
			{
				++g_Stats[victim][STAT_F_M_LOSE];
				++g_Stats[killer][STAT_F_M_KILL];

				if(g_ModeFvsJ_Jason[victim])
					g_ModeFvsJ_Humans = getHumans();
			}
		}

		if(g_Stats[killer][STAT_S_M_KILL] && g_Stats[killer][STAT_W_M_KILL] && g_Stats[killer][STAT_SN_M_KILL] && g_Stats[killer][STAT_J_M_KILL] &&
		g_Stats[killer][STAT_N_M_KILL] && g_Stats[killer][STAT_A_M_KILL] && g_Stats[killer][STAT_AN_M_KILL])
		{
			setAchievement(killer, QUE_SUERTE);
			setAchievementFirst(killer, PRIMERO_QUE_SUERTE);
		}
	}

	if(g_Mode != MODE_PLAGUE && g_Mode != MODE_TRIBAL && g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_MEGA_ARMAGEDDON && g_Mode != MODE_FVSJ && g_Mode != MODE_SYNAPSIS && g_Mode != MODE_AVSP && g_SpecialMode[killer] && (g_LastHuman[victim] || g_LastZombie[victim]))
	{
		static iUsersNum;
		static iClass;
		static iDifficultClass;

		iUsersNum = getPlaying();
		iClass = -1;
		iDifficultClass = -1;

		switch(g_Mode)
		{
			case MODE_SURVIVOR:
			{
				++g_Stats[killer][STAT_S_M_WIN];

				switch(g_Difficult[killer][DIFFICULT_CLASS_SURVIVOR])
				{
					case DIFFICULT_NORMAL: setAchievement(killer, SURVIVOR_PRINCIPIANTE);
					case DIFFICULT_HARD: setAchievement(killer, SURVIVOR_AVANZADO);
					case DIFFICULT_VERY_HARD:
					{
						setAchievement(killer, SURVIVOR_EXPERTO);

						if(getUserHealthPercent(killer, 75))
							setAchievement(killer, SURVIVOR_PRO);
					}
				}

				iClass = POINT_HUMAN;
				iDifficultClass = DIFFICULT_CLASS_SURVIVOR;
			}
			case MODE_WESKER:
			{
				++g_Stats[killer][STAT_W_M_WIN];

				switch(g_Difficult[killer][DIFFICULT_CLASS_WESKER])
				{
					case DIFFICULT_NORMAL: setAchievement(killer, WESKER_PRINCIPIANTE);
					case DIFFICULT_HARD: setAchievement(killer, WESKER_AVANZADO);
					case DIFFICULT_VERY_HARD:
					{
						setAchievement(killer, WESKER_EXPERTO);

						if(getUserHealthPercent(killer, 75))
							setAchievement(killer, WESKER_PRO);
					}
				}

				if(g_ModeWesker_Laser[killer] == 3 && iUsersNum >= 10)
					giveHat(killer, HAT_HOOD);

				iClass = POINT_HUMAN;
				iDifficultClass = DIFFICULT_CLASS_WESKER;
			}
			case MODE_SNIPER_ELITE:
			{
				++g_Stats[killer][STAT_SN_M_WIN];

				switch(g_Difficult[killer][DIFFICULT_CLASS_SNIPER_ELITE])
				{
					case DIFFICULT_NORMAL: setAchievement(killer, SNIPER_ELITE_PRINCIPIANTE);
					case DIFFICULT_HARD: setAchievement(killer, SNIPER_ELITE_AVANZADO);
					case DIFFICULT_VERY_HARD:
					{
						setAchievement(killer, SNIPER_ELITE_EXPERTO);

						if(getUserHealthPercent(killer, 75))
							setAchievement(killer, SNIPER_ELITE_PRO);
					}
				}

				iClass = POINT_HUMAN;
				iDifficultClass = DIFFICULT_CLASS_SNIPER_ELITE;
			}
			case MODE_JASON:
			{
				++g_Stats[killer][STAT_J_M_WIN];

				iClass = POINT_HUMAN;
			}
			case MODE_NEMESIS:
			{
				++g_Stats[killer][STAT_N_M_WIN];

				switch(g_Difficult[killer][DIFFICULT_CLASS_NEMESIS])
				{
					case DIFFICULT_NORMAL: setAchievement(killer, NEMESIS_PRINCIPIANTE);
					case DIFFICULT_HARD: setAchievement(killer, NEMESIS_AVANZADO);
					case DIFFICULT_VERY_HARD:
					{
						setAchievement(killer, NEMESIS_EXPERTO);

						if(getUserHealthPercent(killer, 75))
							setAchievement(killer, NEMESIS_PRO);
					}
				}

				iClass = POINT_ZOMBIE;
				iDifficultClass = DIFFICULT_CLASS_NEMESIS;
			}
			case MODE_ASSASSIN:
			{
				++g_Stats[killer][STAT_A_M_WIN];

				switch(g_Difficult[killer][DIFFICULT_CLASS_ASSASSIN])
				{
					case DIFFICULT_NORMAL: setAchievement(killer, ASSASSIN_PRINCIPIANTE);
					case DIFFICULT_HARD: setAchievement(killer, ASSASSIN_AVANZADO);
					case DIFFICULT_VERY_HARD:
					{
						setAchievement(killer, ASSASSIN_EXPERTO);

						if(getUserHealthPercent(killer, 75))
							setAchievement(killer, ASSASSIN_PRO);
					}
				}

				iClass = POINT_ZOMBIE;
				iDifficultClass = DIFFICULT_CLASS_ASSASSIN;
			}
			case MODE_ANNIHILATOR:
			{
				++g_Stats[killer][STAT_AN_M_WIN];

				switch(g_Difficult[killer][DIFFICULT_CLASS_ANNIHILATOR])
				{
					case DIFFICULT_NORMAL: setAchievement(killer, ANNIHILATOR_PRINCIPIANTE);
					case DIFFICULT_HARD: setAchievement(killer, ANNIHILATOR_AVANZADO);
					case DIFFICULT_VERY_HARD:
					{
						setAchievement(killer, ANNIHILATOR_EXPERTO);

						if(getUserHealthPercent(killer, 75))
							setAchievement(killer, ANNIHILATOR_PRO);
					}
				}

				iClass = POINT_ZOMBIE;
				iDifficultClass = DIFFICULT_CLASS_ANNIHILATOR;

				if(getPlaying() >= 15)
					setAchievement(killer, MI_CUCHILLA_Y_YO);
			}
			case MODE_SNIPER:
			{
				static iSnipers[4];
				static j;
				static k;
				static iRewardPoints;

				iSnipers = {0, 0, 0, 0};
				j = 0;
				k = 0;
				iRewardPoints = 0;

				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(g_IsConnected[i] && g_SpecialMode[i] == MODE_SNIPER)
					{
						iSnipers[j] = i;

						dg_color_chat(i, _, "Ganaste !g%d pH!y por ganar el modo !gSNIPER!y", g_PointsMult[i]);
						g_Points[i][POINT_HUMAN] += g_PointsMult[i];

						++j;
					}
				}

				g_PointsMult[0] = 0;

				dg_color_chat(0, _, "Los !tSNIPERS!y ganaron !g%d !y/!g %d !y/!g %d !y/!g %d pH!y por ganar el modo !tSNIPER!y", g_PointsMult[iSnipers[0]], g_PointsMult[iSnipers[1]], g_PointsMult[iSnipers[2]], g_PointsMult[iSnipers[3]]);

				if(g_ModeSniper_Damage >= 500000.0)
				{
					if(g_ModeSniper_Damage >= 1000000.0)
					{
						if(g_ModeSniper_Damage >= 5000000.0)
						{
							if(g_ModeSniper_Damage >= 10000000.0)
								iRewardPoints = 4;
							else
								iRewardPoints = 3;
						}
						else
							iRewardPoints = 2;
					}
					else
						iRewardPoints = 1;

					dg_color_chat(0, _, "Los !tSNIPERS!y ganaron un bonus de !g%d pH!y por hacer realizado !g%d de daño!y en la ronda", iRewardPoints, g_ModeSniper_Damage);
				}

				g_ModeSniper_Damage = 0.0;

				for(new i = 0; i < j; ++i)
				{
					g_Points[iSnipers[i]][POINT_HUMAN] += iRewardPoints;

					if(g_IsAlive[iSnipers[i]])
					{
						setAchievement(iSnipers[i], L_FRANCOTIRADOR);
						++k;

						if(!g_Achievement_SniperNoDmg[iSnipers[i]])
							setAchievement(iSnipers[i], NO_TENGO_BALAS);
					}

					g_Achievement_SniperNoDmg[iSnipers[i]] = 0;
				}

				switch(k)
				{
					case 1:
					{
						for(new i = 0; i < j; ++i)
						{
							if(g_IsAlive[iSnipers[i]])
							{
								setAchievement(iSnipers[i], EN_MEMORIA_A_ELLOS);
								break;
							}
						}
					}
					case 2:
					{
						static iAwp;
						static iScout;

						iAwp = 0;
						iScout = 0;

						for(new i = 0; i < j; ++i)
						{
							if(user_has_weapon(iSnipers[i], CSW_AWP))
								++iAwp;

							if(user_has_weapon(iSnipers[i], CSW_SCOUT))
								++iScout;
						}

						if(iAwp == 2)
						{
							setAchievement(iSnipers[0], SOBREVIVEN_LOS_DUROS);
							setAchievement(iSnipers[1], SOBREVIVEN_LOS_DUROS);
						}
						else if(iScout == 2)
						{
							setAchievement(iSnipers[0], NO_SOLO_LA_GANAN_LOS_DUROS);
							setAchievement(iSnipers[1], NO_SOLO_LA_GANAN_LOS_DUROS);
						}
					}
					case 4:
					{
						setAchievement(iSnipers[0], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[1], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[2], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[3], EL_MEJOR_EQUIPO);
					}
				}

				return;
			}
			case MODE_GRUNT:
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i])
						continue;

					if(g_SpecialMode[i] == MODE_GRUNT)
					{
						dg_color_chat(0, TERRORIST, "!t%s!y ganó !g%d pZ!y por ganar el modo !tGRUNT!y", g_PlayerName[i], g_PointsMult[i]);
						g_Points[i][POINT_ZOMBIE] += g_PointsMult[i];
					}
				}

				return;
			}
			case MODE_L4D2:
			{
				new iHumans[MAX_USERS];
				new i;
				new j;

				j = 0;

				for(i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i])
						continue;

					if(g_SpecialMode[i] != MODE_L4D2)
						continue;

					iHumans[j] = i;
					++j;

					dg_color_chat(i, _, "Ganaste !g%d pH!y por ganar el modo !gL4D2!y", g_PointsMult[i]);
					g_Points[i][POINT_HUMAN] += g_PointsMult[i];
				}

				if(j == 4)
				{
					new iRewardPH;
					new iRewardPL;

					iRewardPH = 2;
					iRewardPL = 2;

					for(i = 0; i < j; ++i)
					{
						if(g_HappyTime == 2)
						{
							iRewardPH += 3;
							iRewardPL += 2;
						}

						dg_color_chat(iHumans[i], _, "Ganaste !g%d pH!y y !g%d pL!y extra porque todos los humanos sobrevivieron", iRewardPH, iRewardPL);

						g_Points[iHumans[i]][POINT_HUMAN] += iRewardPH;
						g_Points[iHumans[i]][POINT_LEGACY] += iRewardPL;
					}
				}

				return;
			}
		}

		static iReward;
		static iRewardPL;

		iReward = g_PointsMult[killer];
		iRewardPL = (1 + g_Habs[killer][HAB_D_MORE_PL]);

		if(iDifficultClass != -1 && iClass != -1)
		{
			if(g_Difficult[killer][iDifficultClass] != DIFFICULT_NORMAL)
				iReward += g_Difficult[killer][iDifficultClass];

			g_Points[killer][iClass] += iReward;
			g_Points[killer][POINT_LEGACY] += iRewardPL;

			dg_color_chat(0, ((iClass == POINT_HUMAN) ? CT : TERRORIST), "!t%s!y ganó !g%d p%c!y y !g%d pL!y por ganar el modo !g%s!y", g_PlayerName[killer], iReward, ((iClass == POINT_HUMAN) ? 'H' : 'Z'), iRewardPL, g_PlayerClassName[killer]);
		}
		else if(iClass != -1)
		{
			g_Points[killer][iClass] += iReward;
			dg_color_chat(0, ((iClass == POINT_HUMAN) ? CT : TERRORIST), "!t%s!y ganó !g%d p%c!y por ganar el modo !g%s!y", g_PlayerName[killer], iReward, ((iClass == POINT_HUMAN) ? 'H' : 'Z'), g_PlayerClassName[killer]);
		}
	}
}

public ham__PlayerKilledPost(const victim, const killer, const should_gib)
{
	checkLastZombie();

	if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME)
		set_task(random_float(0.7, 2.3), "task__RespawnUser", victim + TASK_SPAWN);
	else
	{
		if(!g_ModeGG_End)
			set_task(1.0, "task__RespawnUser", victim + TASK_SPAWN);
	}
}

public ham__PlayerTakeDamagePre(const victim, const inflictor, const attacker, Float:damage, const damage_type)
{
	if(damage_type & DMG_FALL)
		return HAM_SUPERCEDE;

	if(victim == attacker || !isUserValidConnected(attacker))
		return HAM_IGNORED;

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
	{
		if(g_Mode == MODE_DUEL_FINAL)
		{
			if(g_ModeDuelFinal_Type == DF_TYPE_OH && get_pdata_int(victim, OFFSET_HITZONE) != HIT_HEAD)
				return HAM_SUPERCEDE;
		}
		else if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME)
		{
			if(g_ModeGG_Immunity[victim])
				return HAM_SUPERCEDE;

			if(g_Mode == MODE_GUNGAME)
			{
				if((damage_type & DMG_HEGRENADE) && !g_ModeGGCrazy_HeLevel[attacker])
					return HAM_SUPERCEDE;

				if(g_ModeGG_Type == GUNGAME_ONLY_HEAD && get_pdata_int(victim, OFFSET_HITZONE) != HIT_HEAD && GUNGAME_WEAPONS_CSW[g_ModeGG_Level[attacker]] != CSW_HEGRENADE && GUNGAME_WEAPONS_CSW[g_ModeGG_Level[attacker]] != 0)
					return HAM_SUPERCEDE;
			}

			set_user_rendering(attacker);

			g_ModeGG_Immunity[attacker] = 0;

			remove_task(attacker + TASK_IMMUNITY_GG);
		}

		static iVictimTeam;
		iVictimTeam = getUserTeam(victim);

		if(iVictimTeam == getUserTeam(attacker))
		{
			setUserTeam(victim, (iVictimTeam == F_TEAM_T) ? F_TEAM_CT : F_TEAM_T);
			ExecuteHamB(Ham_TakeDamage, victim, inflictor, attacker, damage, damage_type);
			setUserTeam(victim, iVictimTeam);

			return HAM_SUPERCEDE;
		}

		return HAM_IGNORED;
	}

	if(g_NewRound || g_EndRound)
		return HAM_SUPERCEDE;

	if(g_Zombie[attacker] == g_Zombie[victim])
		return HAM_SUPERCEDE;

	if((g_InBubble[victim] && !g_Immunity[attacker]) && ((g_InBubble[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker]) || (g_InBubble[victim] && (g_Mode == MODE_ARMAGEDDON || g_Mode == MODE_MEGA_ARMAGEDDON) && (g_Zombie[attacker] || g_SpecialMode[attacker] == MODE_NEMESIS))))
		return HAM_SUPERCEDE;

	if(g_Immunity[victim] || g_Frozen[attacker] || g_Frozen[victim] == 1)
		return HAM_SUPERCEDE;

	if(g_Immunity[victim] && !g_Immunity[attacker] && !g_SpecialMode[attacker])
		return HAM_SUPERCEDE;

	if(g_Immunity[victim] && g_Immunity[attacker] && !g_Zombie[attacker])
		return HAM_SUPERCEDE;

	if(g_ConvertZombie[victim])
		return HAM_SUPERCEDE;

	static iDamage;

	if(!g_Zombie[attacker])
	{
		if(g_UnlimitedClip[attacker] && !g_SpecialMode[attacker])
			++g_AchievementSecret_BulletsOk[attacker];

		static iData;
		iData = 1;

		if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD)
		{
			++g_Stats[attacker][STAT_HS_D];
			++g_Stats[victim][STAT_HS_T];
		}

		switch(g_SpecialMode[attacker])
		{
			case MODE_SURVIVOR, MODE_AVSP:
			{
				if(g_SpecialMode[attacker] == MODE_AVSP && g_SpecialMode_Predator[attacker])
				{
					if(g_SpecialMode_Alien[victim])
						damage *= 5.75;
					else
					{
						if(g_CurrentWeapon[attacker] == CSW_M4A1)
						{
							if(g_Habs[attacker][HAB_L_S_DAMAGE])
								damage += (((float(HABS[HAB_L_S_DAMAGE][habValue]) * float(g_Habs[attacker][HAB_L_S_DAMAGE])) * damage) / 100.0);
						}
					}
				}
				else
				{
					switch(g_Habs[attacker][HAB_L_S_WEAPON])
					{
						case 0:
						{
							if(g_CurrentWeapon[attacker] == CSW_MP5NAVY)
								damage *= 2.5;
						}
						case 1:
						{
							if(g_CurrentWeapon[attacker] == CSW_XM1014)
								damage *= 1.75;
						}
						case 2:
						{
							if(g_CurrentWeapon[attacker] == CSW_M4A1)
								damage *= 1.25;
						}
					}

					if(g_Habs[attacker][HAB_L_S_DAMAGE])
						damage += (((float(HABS[HAB_L_S_DAMAGE][habValue]) * float(g_Habs[attacker][HAB_L_S_DAMAGE])) * damage) / 100.0);
				}

				if(g_Mode == MODE_ARMAGEDDON || g_Mode == MODE_MEGA_ARMAGEDDON)
					damage *= 1.25;
			}
			case MODE_WESKER:
			{
				iData = ((g_Habs[attacker][HAB_L_W_COMBO]) ? 1 : 0);

				if(g_CurrentWeapon[attacker] == CSW_DEAGLE)
				{
					static iHealth;
					iHealth = g_Health[victim];

					iHealth *= 15;
					iHealth /= 100;

					damage = ((iHealth < 200) ? 200.0 : float(iHealth));
				}
			}
			case MODE_SNIPER_ELITE:
			{
				iData = 0;

				if(g_CurrentWeapon[attacker] == CSW_AWP)
				{
					ExecuteHamB(Ham_Killed, victim, attacker, 2);
					return HAM_IGNORED;
				}
			}
			case MODE_JASON:
			{
				iData = ((g_Habs[attacker][HAB_L_J_COMBO]) ? 1 : 0);

				if(g_Habs[attacker][HAB_L_J_DAMAGE])
					damage *= ((entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 1250.0 : 1750.0);
				else
					damage *= ((entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 1000.0 : 1325.0);
			}
			case MODE_SNIPER:
			{
				if(g_CurrentWeapon[attacker] == CSW_SCOUT)
					damage *= 75.0;
				else if(g_CurrentWeapon[attacker] == CSW_AWP)
					damage *= 750.0;

				if(g_Mode == MODE_DRUNK)
					damage *= 2.0;

				g_ModeSniper_Damage += damage;

				g_Achievement_SniperNoDmg[attacker] = 1;
			}
			case MODE_TRIBAL:
			{
				if(g_CurrentWeapon[attacker] != CSW_KNIFE)
					damage *= 75.0;

				damage = damage + ((damage * g_ModeTribal_Damage[attacker]) / 100);
			}
			default:
			{
				if(g_SpecialMode[attacker] != MODE_L4D2)
				{
					if(g_SpecialMode[victim] != MODE_ASSASSIN)
					{
						damage *= ((g_TypeWeapon[attacker] == 1) ? PRIMARY_WEAPONS[g_WeaponPrimary_Current[attacker]][weaponDamageMult] : (g_TypeWeapon[attacker] == 0) ? SECONDARY_WEAPONS[g_WeaponSecondary_Current[attacker]][weaponDamageMult] : 1.0);
						{
							damage += humanDamageBase(attacker);
							damage += (humanDamageHabs(attacker) * float(HABS[HAB_H_DAMAGE][habValue]));

							if(g_WeaponSkills[attacker][g_CurrentWeapon[attacker]][WEAPON_SKILL_DAMAGE])
								damage += (float(g_WeaponSkills[attacker][g_CurrentWeapon[attacker]][WEAPON_SKILL_DAMAGE]) * 500.0);

							if(g_Habs[attacker][HAB_D_VIGOR])
								damage += (((float(g_Habs[attacker][HAB_D_VIGOR]) * float(HABS[HAB_D_VIGOR][habValue])) * damage) / 100.0);
						}
					}
					else
						damage = 1.0;
				}
			}
		}

		switch(g_SpecialMode[victim])
		{
			case MODE_ANNIHILATOR:
			{
				++g_ModeAnnihilator_Acerts[attacker];
				
				if(g_CurrentWeapon[attacker] == CSW_KNIFE)
					++g_ModeAnnihilator_Acerts[attacker];
			}
		}

		if(g_ReduceDamage[victim])
			damage /= 2.0;

		if(g_Frozen[victim])
		{
			if(g_Frozen[victim] == 2 || g_Frozen[victim] == 3)
				damage /= 2.0;
			else
				damage = 0.1;
		}

		g_StatsDamage[attacker][0] += (damage / DIV_NUM_TO_FLOAT);
		g_StatsDamage[victim][1] += (damage / DIV_NUM_TO_FLOAT);

		SetHamParamFloat(4, damage);
		iDamage = floatround(damage);

		g_AchievementSecret_DmgNemOrd[attacker] += iDamage;
		g_AchievementSecret_DmgNem[attacker] = g_AchievementSecret_DmgNemOrd[attacker];

		if(!g_SpecialMode[attacker])
		{
			g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_DAMAGE_DONE] += (damage / DIV_NUM_TO_FLOAT);
			g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_DAMAGE_S_DONE] += (damage / DIV_NUM_TO_FLOAT);

			if(WEAPON_DAMAGE_NEED[g_CurrentWeapon[attacker]][g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL]] && g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_DAMAGE_DONE] >= WEAPON_DAMAGE_NEED[g_CurrentWeapon[attacker]][g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL]])
			{
				g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
				++g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_POINTS];
				++g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL];

				dg_color_chat(attacker, _, "Tu !g%s!y subió al !gnivel %d!y", WEAPON_NAMES[g_CurrentWeapon[attacker]], g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL]);

				if(g_CurrentWeapon[attacker] == CSW_KNIFE && g_WeaponData[attacker][g_CurrentWeapon[attacker]][WEAPON_DATA_LEVEL] >= 10)
					giveHat(attacker, HAT_SPARTAN);

				checkWeaponModels(attacker, g_CurrentWeapon[attacker]);
				checkAchievementsWeapons(attacker, g_CurrentWeapon[attacker]);
			}
		}

		addAPs(attacker, (iDamage / g_AmmoPacksDamageNeed[attacker]));
		addXP(attacker, (iDamage / g_ExpDamageNeed[attacker]));

		if(iData)
		{
			if(!g_AchievementSecret_Cortamambo[attacker])
				g_AchievementSecret_Cortamambo[attacker] = get_gametime();

			g_ComboDamage[attacker] += damage;
			g_Combo[attacker] = floatround((g_ComboDamage[attacker] / g_ComboDamageNeed[attacker]));

			showCurrentComboHuman(attacker, damage);

			if(g_ClanSlot[attacker] && g_ClanPerks[g_ClanSlot[attacker]][CP_COMBO] && g_Clan[g_ClanSlot[attacker]][clanHumans] > 1)
			{
				g_ClanComboDamage[g_ClanSlot[attacker]] += damage;
				g_ClanCombo[g_ClanSlot[attacker]] = floatround((g_ClanComboDamage[g_ClanSlot[attacker]] / g_ClanComboDamageNeed[g_ClanSlot[attacker]]));

				clanShowCombo(attacker);
			}
		}

		entity_get_vector(victim, EV_VEC_velocity, g_KnockbackVelocity[victim]);
		return HAM_IGNORED;
	}

	if(damage_type & DMG_HEGRENADE)
		return HAM_SUPERCEDE;

	if(g_CurrentWeapon[attacker] == CSW_MAC10 && g_SpecialMode[attacker] == MODE_ANNIHILATOR)
	{
		ExecuteHamB(Ham_Killed, victim, attacker, 1);
		return HAM_IGNORED;
	}
	else if(g_CurrentWeapon[attacker] == CSW_KNIFE)
	{
		if(entity_get_int(attacker, EV_INT_bInDuck) || entity_get_int(attacker, EV_INT_flags) & FL_DUCKING)
		{
			static Float:vecAttackerOrigin[3];
			static Float:vecVictimOrigin[3];
			static Float:flDistance;

			entity_get_vector(attacker, EV_VEC_origin, vecAttackerOrigin);
			entity_get_vector(victim, EV_VEC_origin, vecVictimOrigin);

			flDistance = vector_distance(vecAttackerOrigin, vecVictimOrigin);

			if(flDistance < 0.0)
				flDistance *= -1.0;

			if(flDistance >= 55.0)
				return HAM_SUPERCEDE;
		}

		damage += ((float(zombieDamage(attacker)) * damage) / 100.0);

		iDamage = floatround(damage);

		switch(g_SpecialMode[attacker])
		{
			case MODE_NEMESIS, MODE_FVSJ, MODE_AVSP:
			{
				iDamage += ((entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 100 : 325);

				if(g_SpecialMode[attacker] == MODE_NEMESIS)
				{
					if(g_Habs[attacker][HAB_L_N_DAMAGE])
						iDamage += (HABS[HAB_L_N_DAMAGE][habValue] * g_Habs[attacker][HAB_L_N_DAMAGE]);
				}
				else if(g_SpecialMode[attacker] == MODE_AVSP && g_SpecialMode_Alien[attacker])
				{
					if(g_SpecialMode_Predator[victim])
						iDamage *= 5;
					else
					{
						if(g_Habs[attacker][HAB_L_N_DAMAGE])
							iDamage += (HABS[HAB_L_N_DAMAGE][habValue] * g_Habs[attacker][HAB_L_N_DAMAGE]);
					}
				}

				SetHamParamFloat(4, float(iDamage));
				return HAM_IGNORED;
			}
			case MODE_ASSASSIN, MODE_ANNIHILATOR:
			{
				ExecuteHamB(Ham_Killed, victim, attacker, 1);
				return HAM_IGNORED;
			}
		}

		static iArmor;
		iArmor = get_user_armor(victim);

		if(iArmor > 0)
		{
			static iRealDamage;
			iRealDamage = (iArmor - iDamage);

			emitSound(victim, CHAN_BODY, SOUND_ARMOR_HIT);

			g_Stats[attacker][STAT_AP_D] += iDamage;
			g_Stats[victim][STAT_AP_T] += iDamage;

			if(iRealDamage > 0)
				set_user_armor(victim, iRealDamage);
			else
				cs_set_user_armor(victim, 0, CS_ARMOR_NONE);

			return HAM_SUPERCEDE;
		}

		if(g_Mode == MODE_PLAGUE || g_Mode == MODE_L4D2 || g_Mode == MODE_MEGA_ARMAGEDDON || g_Mode == MODE_FVSJ || g_Mode == MODE_SNIPER || g_Mode == MODE_DRUNK || g_Mode == MODE_AVSP || g_Mode == MODE_TRIBAL || g_SpecialMode[attacker] || getHumans() == 1)
		{
			if((g_Mode == MODE_PLAGUE || g_Mode == MODE_L4D2 || g_Mode == MODE_DRUNK || g_Mode == MODE_AVSP) && !g_SpecialMode[attacker])
			{
				static iReward;
				iReward = clamp((getConversionPercent(attacker, ((g_Mode == MODE_MEGA_ARMAGEDDON || g_Mode == MODE_L4D2) ? 10 : 5)) * (g_ExpMult[attacker] * (g_HappyTime + 1))), 0, MAX_XP);

				if(g_Mode == MODE_L4D2)
					++g_ModeL4D2_ZombieAcerts[attacker];

				addXP(attacker, iReward);
			}

			SetHamParamFloat(4, damage);
			return HAM_IGNORED; 
		}

		zombieMe(victim, attacker, .finish_clan_combo=1);
	}

	return HAM_SUPERCEDE;
}

public ham__PlayerTakeDamagePost(const victim)
{
	if((g_Zombie[victim] && g_LastZombie[victim]) || (g_Zombie[victim] && g_Painshock[victim]) || (!g_Zombie[victim] && g_SpecialMode[victim]))
	{
		if(pev_valid(victim) != PDATA_SAFE)
			return;

		entity_set_vector(victim, EV_VEC_velocity, g_KnockbackVelocity[victim]);
		set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX);
	}
}

public ham__PlayerTraceAttackPre(const victim, const attacker, const Float:damage, const Float:direction[3], const trace_handle, const damage_type)
{
	if(victim == attacker || !isUserValidConnected(attacker))
		return HAM_IGNORED;

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
	{
		if((g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME) && g_ModeGG_Immunity[victim])
			return HAM_SUPERCEDE;

		static iVictimTeam;
		iVictimTeam = getUserTeam(victim);

		if(iVictimTeam == getUserTeam(attacker))
		{
			setUserTeam(victim, (iVictimTeam == F_TEAM_T) ? F_TEAM_CT : F_TEAM_T);
			ExecuteHamB(Ham_TraceAttack, victim, attacker, damage, direction, trace_handle, damage_type);
			setUserTeam(victim, iVictimTeam);

			return HAM_SUPERCEDE;
		}

		return HAM_IGNORED;
	}

	if(g_NewRound || g_EndRound)
		return HAM_SUPERCEDE;

	if(g_Zombie[attacker] == g_Zombie[victim])
		return HAM_SUPERCEDE;

	if((g_InBubble[victim] && !g_Immunity[attacker]) && ((g_InBubble[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker]) || (g_InBubble[victim] && (g_Mode == MODE_ARMAGEDDON || g_Mode == MODE_MEGA_ARMAGEDDON) && (g_Zombie[attacker] || g_SpecialMode[attacker] == MODE_NEMESIS))))
		return HAM_SUPERCEDE;

	if(g_Immunity[victim] || g_Frozen[attacker] || g_Frozen[victim] == 1)
		return HAM_SUPERCEDE;

	if(g_Immunity[victim] && !g_Immunity[attacker] && !g_SpecialMode[attacker])
		return HAM_SUPERCEDE;

	if(g_Immunity[victim] && g_Immunity[attacker] && !g_Zombie[attacker])
		return HAM_SUPERCEDE;

	if(g_ConvertZombie[victim])
		return HAM_SUPERCEDE;

	if(g_Zombie[attacker] && g_CurrentWeapon[attacker] == CSW_KNIFE)
	{
		if(entity_get_int(attacker, EV_INT_bInDuck) || entity_get_int(attacker, EV_INT_flags) & FL_DUCKING)
		{
			static Float:vecAttackerOrigin[3];
			static Float:vecVictimOrigin[3];
			static Float:flDistance;

			entity_get_vector(attacker, EV_VEC_origin, vecAttackerOrigin);
			entity_get_vector(victim, EV_VEC_origin, vecVictimOrigin);

			flDistance = vector_distance(vecAttackerOrigin, vecVictimOrigin);

			if(flDistance < 0.0)
				flDistance *= -1.0;

			if(flDistance >= 55.0)
			{
				g_BlockSound[attacker] = 1;
				return HAM_SUPERCEDE;
			}
		}
	}

	return HAM_IGNORED;
}

public ham__PlayerResetMaxSpeedPost(const id)
{
	if(!g_IsAlive[id])
		return;

	if(g_Frozen[id] || g_ModeMGG_Block || (g_MiniGame_NoMove && !canUseMiniGames(id)))
		set_user_maxspeed(id, 1.0);
	else if(g_SlowDown[id])
		set_user_maxspeed(id, 175.0);
	else if(g_BurningDuration[id])
	{
		if(g_Habs[id][HAB_Z_RESISTANCE_BURN] >= 2)
			set_user_maxspeed(id, 200.0);
		else
			set_user_maxspeed(id, 175.0);
	}
	else
		set_user_maxspeed(id, g_Speed[id]);
}

public ham__UseStationaryPre(const entity, const caller, const activator, const use_type)
{
	if(use_type == 2 && isUserValidConnected(caller) && g_Zombie[caller])
		return HAM_SUPERCEDE;

	task__HideHUDs(caller + TASK_SPAWN);
	return HAM_IGNORED;
}

public ham__UseStationaryPost(const entity, const caller, const activator, const use_type)
{
	if(use_type == 0 && isUserValidConnected(caller))
	{
		replaceWeaponModels(caller, g_CurrentWeapon[caller]);
		task__HideHUDs(caller + TASK_SPAWN);
	}
}

public ham__UsePushablePre()
	return HAM_SUPERCEDE;

public ham__TouchWeaponPre(const weapon, const id)
{
	if(!isUserValidConnected(id))
		return HAM_IGNORED;

	return HAM_SUPERCEDE;
}

public ham__TouchPlayerPost(const touched, const toucher)
{
	if(!isUserValidAlive(touched) || !isUserValidAlive(toucher))
		return HAM_IGNORED;

	if(!g_Zombie[touched] || !g_Zombie[toucher])
		return HAM_IGNORED;

	if(g_SpecialMode[touched] || g_SpecialMode[toucher])
		return HAM_IGNORED;

	if(g_Habs[touched][HAB_Z_RESISTANCE_BURN] >= 3 || g_Habs[toucher][HAB_Z_RESISTANCE_BURN] >= 3)
		return HAM_IGNORED;

	if((g_BurningDuration[touched] && g_BurningDuration[toucher]) || (!g_BurningDuration[touched] && !g_BurningDuration[toucher]))
		return HAM_IGNORED;

	static iInFire;
	static iNotFire;

	if(g_BurningDuration[touched] && !g_BurningDuration[toucher])
	{
		iInFire = touched;
		iNotFire = toucher;
	}
	else if(!g_BurningDuration[touched] && g_BurningDuration[toucher])
	{
		iInFire = toucher;
		iNotFire = touched;
	}

	g_BurningDuration[iNotFire] = g_BurningDuration[iInFire];

	static iArgs[2];

	iArgs[0] = g_BurningDurationOwner[iInFire];
	iArgs[1] = ((isUserValid(iArgs[0]) && g_Habs[iArgs[0]][HAB_S_UPDATE_GRENADE_HE] == 1) ? 1 : 0);

	if(!task_exists(iNotFire + TASK_BURNING_FLAME))
		set_task(0.2, "task__BurningFlame", iNotFire + TASK_BURNING_FLAME, iArgs, sizeof(iArgs), "b");

	return HAM_IGNORED;
}

public ham__ThinkGrenadePre(const ent)
{
	if(!pev_valid(ent))
		return HAM_IGNORED;

	static Float:flDmgTime;
	static Float:flGameTime;

	flDmgTime = entity_get_float(ent, EV_FL_dmgtime);
	flGameTime = get_gametime();

	if(flDmgTime > flGameTime)
		return HAM_IGNORED;

	switch(entity_get_int(ent, EV_NADE_TYPE))
	{
		case NADE_TYPE_INFECTION:
		{
			infectionExplode(ent);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FIRE:
		{
			fireExplode(ent);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_NOVA:
		{
			novaExplode(ent, 1);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FLARE:
		{
			static iDuration;
			iDuration = entity_get_int(ent, EV_FLARE_DURATION);

			if(iDuration > 0)
			{
				if(iDuration == 1)
				{
					remove_entity(ent);
					return HAM_SUPERCEDE;
				}

				flareLighting(ent, iDuration, 0);

				entity_set_int(ent, EV_FLARE_DURATION, --iDuration);
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 2.0);
			}
			else if((entity_get_int(ent, EV_INT_flags) & FL_ONGROUND) && get_speed(ent) < 10)
			{
				if(g_EndRound)
					return HAM_SUPERCEDE;

				emitSound(ent, CHAN_WEAPON, SOUND_NADE_FLARE_EXPLO);

				entity_set_int(ent, EV_FLARE_DURATION, 30);
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 0.1);

				if(g_MiniGameTejo_On)
				{
					static Float:vecOrigin[3];
					static iId;
					
					entity_get_vector(ent, EV_VEC_origin, vecOrigin);
					iId = entity_get_edict(ent, EV_ENT_owner);
					
					g_MiniGameTejo_DistanceId[iId] = get_distance_f(vecOrigin, g_MiniGameTejo_HeadZombie);
					g_MiniGameTejo_Distance[g_MiniGameTejo_Pos] = g_MiniGameTejo_DistanceId[iId];
					
					++g_MiniGameTejo_Pos;
				}
			}
			else
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 1.0);
		}
		case NADE_TYPE_NITRO:
		{
			nitroExplode(ent);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_SUPERNOVA:
		{
			novaExplode(ent, 2);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_IMMUNITY:
		{
			if((entity_get_int(ent, EV_INT_flags) & FL_ONGROUND) && get_speed(ent) < 10)
			{
				immunityExplode(ent);
				return HAM_SUPERCEDE;
			}
			else
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 1.0);
		}
		case NADE_TYPE_DRUG:
		{
			drugExplode(ent);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_HYPERNOVA:
		{
			novaExplode(ent, 3);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_BUBBLE:
		{
			static iDuration;
			iDuration = entity_get_int(ent, EV_FLARE_DURATION);

			if(iDuration > 0)
			{
				if(iDuration == 1)
				{
					static iVictim;
					static Float:vecOrigin[3];
					static iUsers[MAX_USERS];
					static j;

					entity_get_vector(ent, EV_VEC_origin, vecOrigin);
					iVictim = -1;
					j = 0;

					while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 125.0)) != 0)
					{
						if(isUserValidAlive(iVictim) && !g_Zombie[iVictim])
							iUsers[j++] = iVictim;
					}

					remove_entity(ent);

					for(new i = 0; i < j; ++i)
						g_InBubble[iUsers[i]] = 0;
					
					return HAM_SUPERCEDE;
				}
				
				if(!(iDuration % 20))
					flareLighting(ent, iDuration, 1);

				bubbleExplode(ent);

				entity_set_int(ent, EV_FLARE_DURATION, --iDuration);
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 0.1);
			}
			else if((entity_get_int(ent, EV_INT_flags) & FL_ONGROUND) && get_speed(ent) < 10)
			{
				if(g_EndRound)
					return FMRES_SUPERCEDE;

				emitSound(ent, CHAN_WEAPON, SOUND_NADE_BUBBLE_EXPLO);

				entity_set_model(ent, MODEL_BUBBLE);

				entity_set_vector(ent, EV_VEC_angles, Float:{0.0, 0.0, 0.0});

				static Float:vecColor[3];
				entity_get_vector(ent, EV_FLARE_COLOR, vecColor);

				entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell);
				entity_set_vector(ent, EV_VEC_rendercolor, vecColor);
				entity_set_int(ent, EV_INT_rendermode, kRenderTransTexture);
				entity_set_float(ent, EV_FL_renderamt, 5.0);

				static iId;
				iId = entity_get_edict(ent, EV_ENT_owner);

				entity_set_int(ent, EV_FLARE_DURATION, (120 + (HABS[HAB_S_DURATION_BUBBLE][habValue] * g_Habs[iId][HAB_S_DURATION_BUBBLE])));
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 0.01);
			}
			else
				entity_set_float(ent, EV_FL_dmgtime, flGameTime + 0.5);
		}
		case NADE_TYPE_KILL:
		{
			killExplode(ent);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_MOLOTOV:
		{
			remove_task(ent + TASK_MOLOTOV_EFFECT);

			if(entity_get_int(ent, EV_INT_flags) & FL_ONGROUND)
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

			molotovExplode(ent);
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_ANTIDOTE:
		{
			antidoteExplode(ent);
			return HAM_SUPERCEDE;
		}
	}

	return HAM_IGNORED;
}

public miniGamesLaserPrethink(const id)
{
	if(!g_MiniGameLaser_On || g_MiniGameLaser_UserId != id)
		return;

	if(g_MiniGameLaser_Line)
	{
		new Float:vecAngles[3];
		entity_get_vector(id, EV_VEC_angles, vecAngles);

		vecAngles[1] -= (0.05 + (g_MiniGameLaser_Level * 0.05)) * g_MiniGameLaser_Laps;
		g_MiniGameLaser_360 += (0.05 + (g_MiniGameLaser_Level * 0.05)) * g_MiniGameLaser_Laps;

		entity_set_int(id, EV_INT_fixangle, 1);
		entity_set_vector(id, EV_VEC_angles, vecAngles);
		entity_set_vector(id, EV_VEC_v_angle, vecAngles);
		entity_set_int(id, EV_INT_fixangle, 1);

		if(g_MiniGameLaser_360 >= 360.0)
		{
			g_MiniGameLaser_360 = 0.0;

			if(++g_MiniGameLaser_Laps < 25)
			{
				new i;
				for(i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i] || canUseMiniGames(i))
						continue;

					if((g_Level[i] + g_MiniGameLaser_Level) >= MAX_LEVEL)
					{
						g_Exp[i] = 0;
						g_Level[i] = MAX_LEVEL;

						checkExpEquation(i);
						continue;
					}

					g_Exp[i] = 0;
					g_Level[i] += g_MiniGameLaser_Level;

					checkExpEquation(i);
				}

				dg_color_chat(0, _, "Todos los usuarios vivos ganaron !g%d nivel%s!y", g_MiniGameLaser_Level, (g_MiniGameLaser_Level != 1) ? "es" : "");
			}
			else
			{
				g_MiniGameLaser_On = 0;

				new i;
				for(i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i] || canUseMiniGames(i))
						continue;

					if((g_Level[i] + (g_MiniGameLaser_Level * 2)) >= MAX_LEVEL)
					{
						g_Exp[i] = 0;
						g_Level[i] = MAX_LEVEL;

						checkExpEquation(i);
						user_silentkill(i);

						continue;
					}

					g_Exp[i] = 0;
					g_Level[i] += (g_MiniGameLaser_Level * 2);

					checkExpEquation(i);
					user_silentkill(i);
				}

				dg_color_chat(0, _, "Los jugadores sobrevivientes ganaron !g%d nivel%s!y", (g_MiniGameLaser_Level * 2), (((g_MiniGameLaser_Level * 2) != 1) ? "es" : ""));
			}
		}
	}

	new vecAimingOrigin[3];
	get_user_origin(id, vecAimingOrigin, 3);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT);
	write_short(id | 0x1000);
	write_coord(vecAimingOrigin[0]);
	write_coord(vecAimingOrigin[1]);
	write_coord(vecAimingOrigin[2]);
	write_short(g_Sprite_Trail);
	write_byte(0);
	write_byte(0);
	write_byte(1);
	write_byte(5);
	write_byte(0);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	write_byte(0);
	message_end();

	new Float:vecStart[3];
	new Float:vecEnd[3];
	new Float:vecResult[3];
	new iHit;

	entity_get_vector(id, EV_VEC_origin, vecStart);

	vecEnd[0] = float(vecAimingOrigin[0]);
	vecEnd[1] = float(vecAimingOrigin[1]);
	vecEnd[2] = float(vecAimingOrigin[2]);

	iHit = trace_line(id, vecStart, vecEnd, vecResult);

	if(isUserValidAlive(iHit))
		ExecuteHamB(Ham_Killed, iHit, id, 2);
}

public ham__PlayerPreThinkPre(const id)
{
	if(!g_IsAlive[id])
		return;

	if(g_Frozen[id])
	{
		set_user_velocity(id, Float:{0.0, 0.0, 0.0});
		return;
	}

	if(g_Zombie[id])
		entity_set_int(id, EV_NADE_TYPE, STEPTIME_SILENT);

	if(g_MiniGame_Semiclip)
	{
		if(g_MiniGameLaser_On && g_MiniGameLaser_Line)
			miniGamesLaserPrethink(id);

		return;
	}

	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT)
		return;

	static iLastThink;
	static i;

	if(iLastThink > id)
	{
		for(i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
			{
				g_PlayerSolid[i] = 0;
				continue;
			}

			g_PlayerTeam[i] = getUserTeam(i);
			g_PlayerSolid[i] = ((entity_get_int(i, EV_INT_solid) == SOLID_SLIDEBOX) ? 1 : 0);
		}
	}

	iLastThink = id;

	if(g_PlayerSolid[id])
	{
		for(i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_PlayerSolid[i] || id == i)
				continue;

			if((g_PlayerTeam[i] == F_TEAM_CT && g_PlayerTeam[id] == F_TEAM_CT) || (g_NewRound || g_NewRound))
			{
				entity_set_int(i, EV_INT_solid, SOLID_NOT);
				g_PlayerRestore[i] = 1;
			}
		}
	}
}

public ham__PlayerPreThinkPost(const id)
{
	DisableHamForward(g_HamPlayerPreThink);

	if(!g_IsAlive[id])
		task__RespawnUser(id + TASK_SPAWN);
}

public ham__PlayerPostThinkPre(const id)
{
	if(g_MiniGame_Semiclip || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT)
		return;

	if(!g_IsAlive[id])
		return;

	static i;
	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_PlayerRestore[i])
		{
			entity_set_int(i, EV_INT_solid, SOLID_SLIDEBOX);
			g_PlayerRestore[i] = 0;
		}
	}
}

public ham__TouchWallPre(const ent, const id)
{
	if(!isUserValidAlive(id) || !pev_valid(id) || !g_SpecialMode_Alien[id])
		return FMRES_IGNORED;

	entity_get_vector(id, EV_VEC_origin, g_SpecialMode_AlienOrigin[id]);
	return FMRES_IGNORED;
}

public ham__PlayerJumpPre(const id)
{
	if(!g_IsAlive[id] || !g_LongJump[id])
		return HAM_IGNORED;

	static iFlags;
	iFlags = entity_get_int(id, EV_INT_flags);

	if(iFlags & FL_WATERJUMP || entity_get_int(id, EV_INT_waterlevel) >= 2)
		return HAM_IGNORED;

	static iButtonPressed;
	iButtonPressed = get_pdata_int(id, OFFSET_BUTTON_PRESSED, OFFSET_LINUX);

	if(!(iButtonPressed & IN_JUMP) || !(iFlags & FL_ONGROUND))
		return HAM_IGNORED;

	if((entity_get_int(id, EV_INT_bInDuck) || iFlags & FL_DUCKING) && get_pdata_int(id, OFFSET_LONG_JUMP, OFFSET_LINUX) && entity_get_int(id, EV_INT_button) & IN_DUCK && entity_get_int(id, EV_INT_flDuckTime))
	{
		static Float:vecVelocity[3];
		entity_get_vector(id, EV_VEC_velocity, vecVelocity);

		if(vector_length(vecVelocity) > ((g_AccountId[id] != 1) ? 20 : 1))
		{
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

			set_pdata_int(id, OFFSET_BUTTON_PRESSED, iButtonPressed & ~IN_JUMP, OFFSET_LINUX);
			return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}

public ham__PlayerDuckPre(const id)
{
	if(g_SpecialMode[id] == MODE_SNIPER_ELITE || g_SpecialMode[id] == MODE_L4D2)
	{
		static iOldButtons;
		iOldButtons = entity_get_int(id, EV_INT_oldbuttons);

		if(!(iOldButtons & IN_DUCK))
		{
			iOldButtons |= IN_DUCK;

			entity_set_int(id, EV_INT_oldbuttons, iOldButtons);
			return HAM_HANDLED;
		}
	}

	if(g_InJump[id])
	{
		g_InJump[id] = 0;
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public ham__WeaponPrimaryAttackPost(const weapon_ent)
{
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return HAM_IGNORED;

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isUserValidAlive(iId) || g_Zombie[iId])
		return HAM_IGNORED;

	switch(g_SpecialMode[iId])
	{
		case MODE_SNIPER_ELITE, MODE_SNIPER:
		{
			if(g_SpecialMode[iId] == MODE_SNIPER_ELITE)
			{
				entity_set_vector(iId, EV_VEC_punchangle, Float:{0.0, 0.0, 0.0});

				if(g_ModeSniperElite_Speed[iId] == 2)
				{
					static Float:flSpeed;
					flSpeed = 0.4;

					set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, flSpeed, OFFSET_LINUX_WEAPONS);
				}
			}
			else
			{
				if(g_ModeSniper_Power[iId] == 1)
				{
					static Float:vecPunchangle[3];
					static Float:fSpeed;

					fSpeed = ((g_CurrentWeapon[iId] == CSW_SCOUT) ? 0.05 : 0.4);
					vecPunchangle[0] = ((g_CurrentWeapon[iId] == CSW_SCOUT) ? -5.5 : 0.0);

					set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, fSpeed, OFFSET_LINUX_WEAPONS);

					entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
				}
				else if(g_CurrentWeapon[iId] == CSW_SCOUT)
				{
					static Float:vecPunchangle[3];
					static Float:fSpeed;

					fSpeed = 0.1;
					vecPunchangle[0] = -5.5;

					set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, fSpeed, OFFSET_LINUX_WEAPONS);

					entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
				}
			}
		}
		case MODE_JASON:
		{
			if(g_CurrentWeapon[iId] != CSW_KNIFE)
				return HAM_IGNORED;

			static Float:vecPunchangle[3];
			static Float:flSpeed;

			vecPunchangle[0] = -4.0;
			flSpeed = 0.05;

			set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, flSpeed, OFFSET_LINUX_WEAPONS);

			entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
		}
		case MODE_FVSJ:
		{
			if(g_ModeFvsJ_Jason[iId] && g_ModeFvsJ_JasonPower[iId] == 2)
			{
				static Float:fSpeed;
				static Float:vecPunchangle[3];

				fSpeed = 0.05;
				vecPunchangle[0] = -2.5;

				set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, fSpeed, OFFSET_LINUX_WEAPONS);

				entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
			}
		}
		default:
		{
			if(cs_get_weapon_ammo(weapon_ent) < 1)
				return HAM_IGNORED;

			if(g_PrecisionPerfect[iId])
			{
				static Float:vecPunchangle[3];
				vecPunchangle[0] = 0.0;

				entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
			}
			
			static iWeaponId;
			iWeaponId = g_CurrentWeapon[iId];

			if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED] || g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL])
			{
				static Float:vecSpeed[3];
				static Float:vecRecoil[3];

				if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED])
				{
					if(iWeaponId == CSW_KNIFE)
					{
						vecSpeed[0] = get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS);
						vecSpeed[1] = get_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS);
						vecSpeed[2] = get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS);

						vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 25.0))) / 100.0);
						vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 25.0))) / 100.0);
						vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 25.0))) / 100.0);

						set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, vecSpeed[0], OFFSET_LINUX_WEAPONS);
						set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, vecSpeed[1], OFFSET_LINUX_WEAPONS);
						set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, vecSpeed[2], OFFSET_LINUX_WEAPONS);
					}
					else
					{
						vecSpeed[0] = get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS);
						vecSpeed[1] = get_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS);
						vecSpeed[2] = get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS);

						if((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM)
						{
							vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 5.0))) / 100.0);
							vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 5.0))) / 100.0);
							vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 5.0))) / 100.0);
						}
						else
						{
							vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 10.0))) / 100.0);
							vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 10.0))) / 100.0);
							vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_SPEED]) * 10.0))) / 100.0);
						}

						set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, vecSpeed[0], OFFSET_LINUX_WEAPONS);
						set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, vecSpeed[1], OFFSET_LINUX_WEAPONS);
						set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, vecSpeed[2], OFFSET_LINUX_WEAPONS);
					}
				}

				if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL])
				{
					entity_get_vector(iId, EV_VEC_punchangle, vecRecoil);

					vecRecoil[0] = vecRecoil[0] - (((vecRecoil[0] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL]) * 6.0))) / 100.0);
					vecRecoil[1] = vecRecoil[1] - (((vecRecoil[1] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL]) * 6.0))) / 100.0);
					vecRecoil[2] = vecRecoil[2] - (((vecRecoil[2] * (float(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_RECOIL]) * 6.0))) / 100.0);

					entity_set_vector(iId, EV_VEC_punchangle, vecRecoil);
				}

				if(g_WeaponData[iId][iWeaponId][WEAPON_DATA_LEVEL] >= 10 && ((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM))
					g_WeaponSecondaryAutofire[iId] = 1;
			}
		}
	}

	return HAM_IGNORED;
}

public ham__WeaponSecondaryAttackPost(const weapon_ent)
{
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return HAM_IGNORED;

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isUserValidAlive(iId) || g_Zombie[iId])
		return HAM_IGNORED;

	if(g_SpecialMode[iId])
	{
		switch(g_SpecialMode[iId])
		{
			case MODE_JASON:
			{
				if(g_CurrentWeapon[iId] != CSW_KNIFE)
					return HAM_IGNORED;

				static Float:vecPunchangle[3];
				static Float:flSpeed;

				vecPunchangle[0] = -8.5;
				flSpeed = 0.3;

				set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, flSpeed, OFFSET_LINUX_WEAPONS);

				entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
			}
		}
	}

	return HAM_IGNORED;
}

public ham__ItemAttachToPlayerPre(const weapon_ent, const id)
{
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;

	static iWeaponId;
	iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);

	if(g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_MAXCLIP])
	{
		if(get_pdata_int(weapon_ent, OFFSET_KNOWN, OFFSET_LINUX_WEAPONS))
			return;

		static iExtraClip;
		iExtraClip = (2 * g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_MAXCLIP]);

		set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (DEFAULT_MAX_CLIP[iWeaponId] + iExtraClip), OFFSET_LINUX_WEAPONS);
	}
}

public ham__ItemPostFramePre(const weapon_ent)
{
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isUserValidAlive(iId) || g_Zombie[iId])
		return;

	static iWeaponId;
	iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);

	if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_MAXCLIP])
	{
		static iMaxClip;
		static iReload;
		static Float:fNextAttack;
		static iAmmoType;
		static iBPAmmo;
		static iClip;

		iMaxClip = (DEFAULT_MAX_CLIP[iWeaponId] + (2 * g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_MAXCLIP]));
		iReload = get_pdata_int(weapon_ent, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS);
		fNextAttack = get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX);
		iAmmoType = (OFFSET_AMMO_PLAYER_SLOT0 + get_pdata_int(weapon_ent, OFFSET_PRIMARY_AMMO_TYPE, OFFSET_LINUX_WEAPONS));
		iBPAmmo = get_pdata_int(iId, iAmmoType, OFFSET_LINUX);
		iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);

		if(iReload && fNextAttack <= 0.0)
		{
			static i;
			i = min((iMaxClip - iClip), iBPAmmo);

			set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (iClip + i), OFFSET_LINUX_WEAPONS);
			set_pdata_int(iId, iAmmoType, (iBPAmmo - i), OFFSET_LINUX);
			set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);

			iReload = 0;
		}

		static iButton;
		iButton = entity_get_int(iId, EV_INT_button);

		if((iButton & IN_ATTACK && get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0) || (iButton & IN_ATTACK2 && get_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0))
			return;

		if((iButton & IN_RELOAD) && !iReload)
		{
			if(iClip >= iMaxClip)
			{
				entity_set_int(iId, EV_INT_button, iButton & ~IN_RELOAD);

				if(((1<<iWeaponId) & WEAPONS_SILENT_BIT_SUM) && !get_pdata_int(weapon_ent, OFFSET_SILENT, OFFSET_LINUX_WEAPONS))
					setAnimation(iId, ((iWeaponId == CSW_USP) ? 8 : 7));
				else
					setAnimation(iId, 0);
			}
			else if(iClip == DEFAULT_MAX_CLIP[iWeaponId])
			{
				if(iBPAmmo)
				{
					set_pdata_float(iId, OFFSET_NEXT_ATTACK, DEFAULT_DELAY[iWeaponId], OFFSET_LINUX);

					if(((1<<iWeaponId) & WEAPONS_SILENT_BIT_SUM) && get_pdata_int(weapon_ent, OFFSET_SILENT, OFFSET_LINUX_WEAPONS))
						setAnimation(iId, ((iWeaponId == CSW_USP) ? 5 : 4));
					else
						setAnimation(iId, DEFAULT_ANIMS[iWeaponId]);

					set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 1, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, (DEFAULT_DELAY[iWeaponId] + 0.5), OFFSET_LINUX_WEAPONS);
				}
			}
		}
	}
}

public ham__ShotgunPostFramePre(const weapon_ent)
{
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isUserValidAlive(iId) || g_Zombie[iId])
		return;

	static iWeaponId;
	iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
	
	if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_MAXCLIP])
	{
		static iBPAmmo;
		static iClip;
		static iMaxClip;
		
		iBPAmmo = get_pdata_int(iId, OFFSET_M3_AMMO, OFFSET_LINUX);
		iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
		iMaxClip = (DEFAULT_MAX_CLIP[iWeaponId] + (2 * g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_MAXCLIP]));

		if(get_pdata_int(weapon_ent, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS) && get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX) <= 0.0)
		{
			static i;
			i = min((iMaxClip - iClip), iBPAmmo);

			set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (iClip + i), OFFSET_LINUX_WEAPONS);
			set_pdata_int(iId, OFFSET_M3_AMMO, (iBPAmmo - i), OFFSET_LINUX);
			set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);

			return;
		}

		static iButton;
		iButton = entity_get_int(iId, EV_INT_button);

		if(iButton & IN_ATTACK && get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0)
			return;

		if(iButton & IN_RELOAD)
		{
			if(iClip >= iMaxClip)
			{
				entity_set_int(iId, EV_INT_button, iButton & ~IN_RELOAD);
				set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, 0.5, OFFSET_LINUX_WEAPONS);
			}
			else if(iClip == DEFAULT_MAX_CLIP[iWeaponId] && iBPAmmo)
				shotgunReload(weapon_ent, iWeaponId, iMaxClip, iClip, iBPAmmo, iId);
		}
	}
}

public ham__ShotgunWeaponIdlePre(const weapon_ent)
{
	if(!pev_valid(weapon_ent) || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isUserValidAlive(iId) || g_Zombie[iId])
		return;

	static iWeaponId;
	iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
	
	if(g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_MAXCLIP])
	{
		if(get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS) > 0.0)
			return;

		static iMaxClip;
		static iClip;
		static iSpecialReload;

		iMaxClip = (DEFAULT_MAX_CLIP[iWeaponId] + (2 * g_WeaponSkills[iId][iWeaponId][WEAPON_SKILL_MAXCLIP]));
		iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
		iSpecialReload = get_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS);

		if(!iClip && !iSpecialReload)
			return;

		if(iSpecialReload)
		{
			static iBPAmmo;
			static iDefaultMaxClip;

			iBPAmmo = get_pdata_int(iId, OFFSET_M3_AMMO, OFFSET_LINUX);
			iDefaultMaxClip = DEFAULT_MAX_CLIP[iWeaponId];

			if(iClip < iMaxClip && iClip == iDefaultMaxClip && iBPAmmo)
			{
				shotgunReload(weapon_ent, iWeaponId, iMaxClip, iClip, iBPAmmo, iId);
				return;
			}
			else if(iClip == iMaxClip && iClip != iDefaultMaxClip)
			{
				setAnimation(iId, 4);

				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 0, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 1.5, OFFSET_LINUX_WEAPONS);
			}
		}
	}
}

public ham__ItemDeployPost(const weapon_ent)
{
	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!pev_valid(iId))
		return;

	static iWeaponId;
	iWeaponId = cs_get_weapon_id(weapon_ent);

	g_CurrentWeapon[iId] = iWeaponId;
	g_TypeWeapon[iId] = (((1<<iWeaponId) & PRIMARY_WEAPONS_BIT_SUM) ? 1 : ((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM) ? 0 : -1);

	if(g_Zombie[iId] && !((1<<iWeaponId) & ZOMBIE_ALLOWED_WEAPONS_BIT_SUM))
	{
		g_CurrentWeapon[iId] = CSW_KNIFE;
		engclient_cmd(iId, "weapon_knife");
	}

	if(g_LastWeapon[iId] != CSW_HEGRENADE && g_LastWeapon[iId] != CSW_FLASHBANG && g_LastWeapon[iId] != CSW_SMOKEGRENADE && g_LastWeapon[iId])
	{
		g_WeaponSave[iId][g_LastWeapon[iId]] = 1;

		if(!g_WeaponData[iId][g_LastWeapon[iId]][WEAPON_DATA_TIME_PLAYED_DONE])
		{
			g_WeaponData[iId][g_LastWeapon[iId]][WEAPON_DATA_TIME_PLAYED_DONE] = 1;

			static Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_weapons (acc_id, weapon_id, weapon_name) VALUES ('%d', '%d', ^"%s^");", g_AccountId[iId], g_LastWeapon[iId], WEAPON_NAMES[g_LastWeapon[iId]]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(iId, sqlQuery, 1);
			else
				SQL_FreeHandle(sqlQuery);
		}

		g_WeaponData[iId][g_LastWeapon[iId]][WEAPON_DATA_TIME_PLAYED_DONE] += (get_systime() - g_WeaponTime[iId]);
	}

	g_WeaponTime[iId] = get_systime();

	g_LastWeapon[iId] = g_CurrentWeapon[iId];

	replaceWeaponModels(iId, iWeaponId);
}

// **************************************************
//		[Client Commands Functions]
// **************************************************
public clcmd__CreatePassword(const id)
{
	if(!g_IsConnected[id] || g_AccountLogged[id] || g_LoadingData[id])
		return PLUGIN_HANDLED;

	static sPassword[34];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);
	
	if(contain(sPassword, "%") != -1)
	{
		g_AccountName[id][0] = EOS;
		g_AccountPassword[id][0] = EOS;

		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "Tu clave no puede contener el símbolo del porcentaje");
		return PLUGIN_HANDLED;
	}

	static iLenPassword;
	iLenPassword = strlen(sPassword);
	
	if(iLenPassword < 4)
	{
		g_AccountName[id][0] = EOS;
		g_AccountPassword[id][0] = EOS;

		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "La clave debe tener al menos cuatro caracteres");
		return PLUGIN_HANDLED;
	}
	else if(iLenPassword > 30)
	{
		g_AccountName[id][0] = EOS;
		g_AccountPassword[id][0] = EOS;

		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "La clave no puede superar los treinta caracteres");
		return PLUGIN_HANDLED;
	}

	md5(sPassword, sPassword);
	copy(g_AccountPassword[id], charsmax(g_AccountPassword[]), sPassword);
	
	client_cmd(id, "messagemode CONFIRMAR_CLAVE");
	
	showDHUDMessage(id, 255, 255, 255, -1.0, -1.0, 0, 5.0, "Repita su clave para confirmar");
	return PLUGIN_HANDLED;
}

public clcmd__ConfirmPassword(const id)
{
	if(!g_IsConnected[id] || g_AccountRegister[id] || g_LoadingData[id])
		return PLUGIN_HANDLED;
	
	static sPassword[34];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);
	
	md5(sPassword, sPassword);

	if(!equal(g_AccountPassword[id], sPassword))
	{
		g_AccountName[id][0] = EOS;
		g_AccountPassword[id][0] = EOS;

		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "La clave escrita no coincide con la anterior");
		return PLUGIN_HANDLED;
	}

	static Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT admin_name, start, finish, reason FROM zp6_bans WHERE (ip=^"%s^" OR steam=^"%s^") AND active='1' LIMIT 1;", g_PlayerIp[id], g_PlayerSteamId[id]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 2);
	else if(SQL_NumResults(sqlQuery))
	{
		g_AccountBan_Start[id] = SQL_ReadResult(sqlQuery, 1);
		g_AccountBan_Finish[id] = SQL_ReadResult(sqlQuery, 2);

		if(get_systime() < g_AccountBan_Finish[id])
		{
			SQL_ReadResult(sqlQuery, 0, g_AccountBan_Admin[id], charsmax(g_AccountBan_Admin[]));
			SQL_ReadResult(sqlQuery, 3, g_AccountBan_Reason[id], charsmax(g_AccountBan_Reason[]));
			
			g_AccountBanned[id] = 1;

			SQL_FreeHandle(sqlQuery);
			return PLUGIN_HANDLED;
		}
		else
		{
			dg_color_chat(0, _, "El usuario !t%s!y tenía !gban de cuenta!y pero ya puede volver a jugar", g_PlayerName[id]);
			
			SQL_FreeHandle(sqlQuery);
			
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_bans SET active='0' WHERE (ip=^"%s^" OR steam=^"%s^") AND active='1';",  g_PlayerIp[id], g_PlayerSteamId[id]);
			
			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 3);
			else
				SQL_FreeHandle(sqlQuery);
		}
	}
	else
		SQL_FreeHandle(sqlQuery);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_accounts (`name`, `since_ip`, `ip`, `steam`, `password`, `since`, `last_connection`) VALUES (^"%s^", ^"%s^", ^"%s^", ^"%s^", ^"%s^", UNIX_TIMESTAMP(), UNIX_TIMESTAMP());", g_AccountName[id], g_PlayerIp[id], g_PlayerIp[id], g_PlayerSteamId[id], g_AccountPassword[id]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 4);
	else
	{
		SQL_FreeHandle(sqlQuery);

		showDHUDMessage(id, 0, 255, 0, -1.0, -1.0, 0, 2.5, "Tu cuenta ha sido creada correctamente^nEs hora de crear tu personaje");

		resetInfo(id);
		
		client_cmd(id, "setinfo zp5 ^"%s^"", g_AccountPassword[id]);
		client_cmd(id, "setinfo zp6 ^"%s^"", g_AccountName[id]);
		
		set_user_info(id, "zp5", g_AccountPassword[id]);
		set_user_info(id, "zp6", g_AccountName[id]);
		
		g_AccountLogged[id] = 1;
		
		showMenu__ChoosePJ(id);
	}

	return PLUGIN_HANDLED;
}

public clcmd__LoginAccount(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;

	new sAccount[16];
	read_args(sAccount, charsmax(sAccount));
	remove_quotes(sAccount);
	trim(sAccount);
	
	if(contain(sAccount, " ") != -1)
	{
		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "El nombre de tu cuenta no puede contener espacios");
		return PLUGIN_HANDLED;
	}
	else if(!containLetters(sAccount) || countNumbers(sAccount))
	{
		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "El nombre de tu cuenta solo puede contener letras");
		return PLUGIN_HANDLED;
	}
	
	strtolower(sAccount);
	copy(g_AccountName[id], charsmax(g_AccountName[]), sAccount);

	new iArgs[2];

	iArgs[0] = id;
	iArgs[1] = 1;
	
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT id FROM zp6_accounts WHERE name=^"%s^" LIMIT 1;", sAccount);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckName", g_SqlQuery, iArgs, sizeof(iArgs));

	return PLUGIN_HANDLED;
}

public clcmd__LoginPassword(const id)
{
	if(!g_IsConnected[id] || !g_AccountRegister[id] || g_AccountLogged[id] || g_LoadingData[id])
		return PLUGIN_HANDLED;

	new sPassword[34];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);
	
	md5(sPassword, sPassword);

	if(!equal(g_AccountPassword[id], sPassword))
	{
		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "La clave ingresada no coincide con la de esta cuenta");
		return PLUGIN_HANDLED;
	}

	showDHUDMessage(id, 0, 255, 0, -1.0, -1.0, 0, 2.5, "Bienvenido de nuevo a %s^n%s", PLUGIN_COMMUNITY_NAME, g_PlayerName[id]);
	
	g_AccountLogged[id] = 1;
	
	client_cmd(id, "setinfo zp5 ^"%s^"", sPassword);
	set_user_info(id, "zp5", sPassword);
	
	showMenu__ChoosePJ(id);
	return PLUGIN_HANDLED;
}

public clcmd__CreateClan(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id] || g_ClanSlot[id])
		return PLUGIN_HANDLED;
	
	new sClan[15];
	read_args(sClan, charsmax(sClan));
	remove_quotes(sClan);
	trim(sClan);
	
	if(getUserClanBadString(sClan))
	{
		dg_color_chat(id, _, "Solo letras y algunos símbolos: !g( ) [ ] { } - = . , : !!y, se permiten espacios");

		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	new iLenClan;
	iLenClan = strlen(sClan);
	
	if(iLenClan < 1)
	{
		dg_color_chat(id, _, "El nombre del clan debe tener al menos un caracter");
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	else if(iLenClan > 14)
	{
		dg_color_chat(id, _, "El nombre del clan debe tener menos de 15 caracteres");
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	copy(g_TempClanName[id], charsmax(g_TempClanName[]), sClan);
	
	new iArgs[1];
	iArgs[0] = id;
	
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT id FROM zp6_clans WHERE clan_name=^"%s^" LIMIT 1;", sClan);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckClanName", g_SqlQuery, iArgs, sizeof(iArgs));
	
	return PLUGIN_HANDLED;
}

public clcmd__EnterRandomNum(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;
	
	static sNum[8];
	read_args(sNum, charsmax(sNum));
	remove_quotes(sNum);
	trim(sNum);

	if(containLetters(sNum) || !countNumbers(sNum) || equali(sNum, "") || containi(sNum, " ") != -1)
	{
		dg_color_chat(id, _, "Sólo números y sin espacios");
		return PLUGIN_HANDLED;
	}

	static iNum;
	iNum = str_to_num(sNum);

	if(!(1 <= iNum <= 999))
	{
		dg_color_chat(id, _, "El número a apostar tiene que estar entre !g1 al 999!y");
		return PLUGIN_HANDLED;
	}

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i] && g_MiniGames_Number[i])
		{
			if(g_MiniGames_Number[i] == iNum)
			{
				dg_color_chat(id, _, "El usuario !t%s!y ya eligió este número, elige otro", g_PlayerName[i]);
				return PLUGIN_HANDLED;
			}
		}
	}

	g_MiniGames_Number[id] = iNum;
	
	dg_color_chat(id, _, "Jugaste al número !g%d!y", g_MiniGames_Number[id]);
	return PLUGIN_HANDLED;
}

public clcmd__NextModeSay(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;

	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
	{
		if(!g_AccountLogged[id])
			return PLUGIN_HANDLED;
	}

	if(g_StartMode[0] != -1)
	{
		if(g_StartMode[0] == MODE_NONE)
			dg_color_chat(id, _, "El modo actual es: !gNINGUNO!y");
		else
			dg_color_chat(id, _, "El modo actual es: !g%s!y", __MODES[g_StartMode[0]][modeName]);
	}
	
	if(g_StartMode[1] != -1)
	{
		if(g_StartMode[1] == MODE_NONE)
			dg_color_chat(id, _, "El siguiente modo será: !gNINGUNO!y");
		else
			dg_color_chat(id, _, "El siguiente modo será: !g%s!y", __MODES[g_StartMode[1]][modeName]);
	}
	else
		dg_color_chat(id, _, "Debe iniciarse el modo actual para actualizar el modo siguiente");

	if(g_EventModes == 1 && (g_EventMode_MegaArmageddon > 0 || g_EventMode_GunGame > 0))
	{
		if(g_EventMode_GunGame > 0)
			dg_color_chat(id, _, "GunGame %s en !g%d ronda%s!y - Mega Armageddon en !g%d ronda%s!y.", GUNGAME_TYPE_NAME[g_ModeGG_Type], g_EventMode_GunGame, ((g_EventMode_GunGame != 1) ? "s" : ""), g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
		else
			dg_color_chat(id, _, "Mega Armageddon en !g%d ronda%s!y", g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
	}

	return PLUGIN_HANDLED;
}

public clcmd__Rank(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;
	
	dg_color_chat(id, _, "Tu ranking es de !g%d / %d!y", g_AccountRank[id], g_GlobalRank);
	return PLUGIN_HANDLED;
}

public clcmd__Mult(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	dg_color_chat(id, _, "Tus multiplicadores son: APs !gx%d!y - XP !gx%d!y - Puntos !gx%d!y", g_AmmoPacksMult[id], g_ExpMult[id], g_PointsMult[id]);
	dg_color_chat(id, _, "El daño necesario de cada uno es: APs !g%d!y - XP !g%d!y - Combo !g%0.2f!y", g_AmmoPacksDamageNeed[id], g_ExpDamageNeed[id], g_ComboDamageNeed[id]);

	return PLUGIN_HANDLED;
}

public clcmd__Invis(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	if(++g_UserOption_Invis[id] == 3)
		g_UserOption_Invis[id] = 0;

	switch(g_UserOption_Invis[id])
	{
		case 0: dg_color_chat(id, _, "Ahora tus compañeros son !gVisibles!y");
		case 1: dg_color_chat(id, _, "Ahora tus compañeros son !gInvisibles!y");
		case 2: dg_color_chat(id, _, "Ahora tus compañeros son !gInvisibles!y. Puedes ver a los integrantes de tu !gClan!y");
	}

	return PLUGIN_HANDLED;
}

public clcmd__Spectator(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;
	
	if(!(get_user_flags(id) & ADMIN_LEVEL_C))
	{
		dg_color_chat(id, _, "No tienes acceso a este comando");
		return PLUGIN_HANDLED;
	}

	if(getUserTeam(id) == F_TEAM_SPECTATOR)
	{
		rg_join_team(id, TEAM_CT);
		
		if(g_Mode == MODE_MEGA_ARMAGEDDON)
		{
			g_ModeMA_Reward[id] = 2;
			dg_color_chat(id, _, "Cuando comience la segunda fase, renacerás como nemesis. No recibirás recompensa al finalizar el modo");
		}
		else
			set_task(1.0, "task__RespawnUser", id + TASK_SPAWN);
	}
	else
	{
		if(g_IsAlive[id])
			user_silentkill(id);

		rg_join_team(id, TEAM_SPECTATOR);
	}

	return PLUGIN_HANDLED;
}

public clcmd__MiniGames(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	showMenu__MiniGames(id);
	return PLUGIN_HANDLED;
}

new const CAN_USE_GRAB[] = {1, 2};

public clcmd__GrabOn(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;

	static iOk;
	iOk = 0;

	for(new i = 0; i < sizeof(CAN_USE_GRAB); ++i)
	{
		if(g_AccountId[id] == CAN_USE_GRAB[i])
		{
			iOk = 1;
			break;
		}
	}

	if(!iOk)
		return PLUGIN_HANDLED;

	if(g_Grab[id])
		return PLUGIN_HANDLED;

	g_Grab[id] = -1;

	static iTarget;
	static iBody;

	get_user_aiming(id, iTarget, iBody);

	if(isUserValidAlive(iTarget) && iTarget != id)
	{
		if(iTarget <= g_MaxPlayers)
		{
			if(isUserValidAlive(iTarget))
				grabUser(id, iTarget);
		}
		else if(entity_get_int(iTarget, EV_INT_solid) != SOLID_BSP)
			grabUser(id, iTarget);
	}
	else
	{
		remove_task(id + TASK_GRAB);
		set_task(0.1, "task__GrabOn", id + TASK_GRAB);
	}

	return PLUGIN_HANDLED;
}

public clcmd__GrabOff(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;

	if(g_Grab[id] == -1)
	{
		g_Grab[id] = 0;
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
	}
	else if(g_Grab[id])
	{
		if(g_Grab[id] <= g_MaxPlayers && isUserValidAlive(g_Grab[id]))
			set_user_gravity(g_Grab[id], g_GrabGravity[g_Grab[id]]);

		g_Grab[id] = 0;
	}

	return PLUGIN_HANDLED;
}

public clcmd__BlockCommands(const id)
	return PLUGIN_HANDLED;

public clcmd__ChangeTeam(const id)
{
	if(!g_IsConnected[id] || g_LoadingData[id])
		return PLUGIN_HANDLED;
	
	if(g_AccountBanned[id])
	{
		showMenu__Banned(id);
		return PLUGIN_HANDLED;
	}

	if(!g_AccountRegister[id] || !g_AccountLogged[id])
	{
		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}
	
	new TeamName:iTeam;
	iTeam = get_member(id, m_iTeam);

	if(iTeam == TEAM_UNASSIGNED || iTeam == TEAM_SPECTATOR)
	{
		showMenu__Join(id);
		return PLUGIN_HANDLED;
	}

	showMenu__Game(id);
	return PLUGIN_HANDLED;
}

public clcmd__MenuSelect(const id)
{
	if(get_pdata_int(id, OFFSET_CSMENUCODE) == 3 && get_pdata_int(id, OFFSET_JOINSTATE) == 4)
		EnableHamForward(g_HamPlayerPreThink);
}

public clcmd__Say(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;

	if(g_Mode == MODE_GRUNT)
	{
		if(!g_IsAlive[id])
		{
			dg_color_chat(id, _, "No puedes utilizar el chat estando muerto en modo !tGRUNT!y");
			return PLUGIN_HANDLED;
		}
	}

	static sMessage[191];
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

	iGreen = ((get_user_flags(id) & ADMIN_LEVEL_A) ? 1 : 0);
	iTeam = getUserTeam(id);

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i] && !dg_get_user_mute(i, id))
		{
			if(iTeam == F_TEAM_T || iTeam == F_TEAM_CT)
				colorChat(i, ((iTeam == F_TEAM_T) ? TERRORIST : CT), "%s%s!t%s%s!y :%s %s", ((g_IsAlive[id]) ? "" : "!y(MUERTO) "), getUserTypeMod(id), g_PlayerName[id], getUserChatMode(id), ((iGreen) ? "!g" : "!y"), sMessage);
			else
			{
				if(!g_AccountRegister[id])
					colorChat(i, SPECTATOR, "!y(SIN REGISTRARSE)!t %s!y :%s %s", g_PlayerName[id], ((iGreen) ? "!g" : "!y"), sMessage);
				else if(!g_AccountLogged[id])
					colorChat(i, SPECTATOR, "!y(SIN IDENTIFICARSE)!t %s!y :%s %s", g_PlayerName[id], ((iGreen) ? "!g" : "!y"), sMessage);
				else
					colorChat(i, SPECTATOR, "!y(ESPECTADOR)!t %s!y :%s %s", g_PlayerName[id], ((iGreen) ? "!g" : "!y"), sMessage);
			}
		}
	}

	if(g_LogSay)
		dg_log_to_file(LOG_SERVER, 1, 1, "clcmd__Say() ~~ %s [%c](%d) : %s ~~ [HP=%d][XP=%d]", g_PlayerName[id], getUserRange(g_Reset[id]), g_Level[id], sMessage, g_Health[id], g_Exp[id]);

	return PLUGIN_HANDLED;
}

public clcmd__SayTeam(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;
	
	if(g_Mode == MODE_GRUNT)
	{
		dg_color_chat(id, _, "Este chat está bloqueado en modo !tGRUNT!y");
		return PLUGIN_HANDLED;
	}

	if(!g_ClanSlot[id])
		return PLUGIN_HANDLED;

	static sMessage[191];
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
		dg_log_to_file(LOG_SERVER, 1, 1, "clcmd__SayTeam() ~~ %s [%c](%d) : %s ~~ [HP=%d][XP=%d]", g_PlayerName[id], getUserRange(g_Reset[id]), g_Level[id], sMessage, g_Health[id], g_Exp[id]);

	return PLUGIN_HANDLED;
}

public clcmd__Nightvision(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;
	
	if(g_NightVision[id])
	{
		if(task_exists(id + TASK_NIGHTVISION))
			remove_task(id + TASK_NIGHTVISION);
		else
			set_task(0.3, "task__SetUserNightVision", id + TASK_NIGHTVISION, .flags="b");
	}
	
	return PLUGIN_HANDLED;
}

public clcmd__Radio1(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	if(g_LastAchUnlocked != -1)
	{
		g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN] = g_LastAchUnlockedPage;
		g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS] = g_LastAchUnlockedClass;
		g_AchievementInt[id][g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN]] = g_LastAchUnlocked;

		showMenu__AchievementInfo(id, g_AchievementInt[id][g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN]]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Radio2(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	if(g_LastHatUnlocked != -1)
	{
		g_MenuData[id][MENU_DATA_HAT_ID] = g_LastHatUnlocked;

		showMenu__HatInfo(id, g_MenuData[id][MENU_DATA_HAT_ID]);
	}

	return PLUGIN_HANDLED;
}

public tribalPower(const id)
{
	if(!g_IsConnected[id] || !g_ModeTribal_Power)
		return;

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

	iHealthDamage = (ZOMBIE_BASE_HEALTH_MIN / 2);

	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i])
		{
			entity_get_vector(i, EV_VEC_origin, vecOriginVictim);
			flDistance = get_distance_f(vecOriginId, vecOriginVictim);

			if(flDistance > 625.0)
				continue;

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

			if(g_Zombie[i])
			{
				if((g_Health[i] - iHealthDamage) < 1)
					ExecuteHamB(Ham_Killed, i, id, 2);
				else
				{
					set_user_health(i, (g_Health[i] - iHealthDamage));
					g_Health[i] = get_user_health(i);

					burningUser(i, id, 0, 20);
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

public clcmd__Drop(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	switch(g_SpecialMode[id])
	{
		case MODE_TRIBAL:
		{
			if(g_SpecialMode[id] == MODE_TRIBAL)
			{
				if(g_ModeTribal_Power && task_exists(id + TASK_POWER_TRIBAL))
					tribalPower(id);
			}
		}
		case MODE_GRUNT:
		{
			if(g_ModeGrunt_Power == 0)
			{
				g_ModeGrunt_Power = 1;
				set_task(0.1, "task__PowerGrunt");
			}
		}
		case MODE_SNIPER_ELITE, MODE_SNIPER:
		{
			if(g_SpecialMode[id] == MODE_SNIPER_ELITE)
			{
				if(g_ModeSniperElite_Speed[id] == 1)
				{
					g_ModeSniperElite_Speed[id] = 2;

					static Float:flDuration;
					flDuration = 10.0;

					if(g_Habs[id][HAB_L_SN_DURATION_POWER])
						flDuration += (float(HABS[HAB_L_SN_DURATION_POWER][habValue]) * float(g_Habs[id][HAB_L_SN_DURATION_POWER]));

					remove_task(id + TASK_POWER_SNIPER_ELITE);
					set_task(flDuration, "task__PowerSniperElite", id + TASK_POWER_SNIPER_ELITE);
				
					client_print(0, print_center, "¡El SNIPER ELITE activó su DISPARO VELOZ!");
				}
			}
			else
			{
				if(!g_ModeSniper_Power[id])
				{
					g_ModeSniper_Power[id] = 1;

					remove_task(id + TASK_POWER_SNIPER);
					set_task(10.0, "task__PowerSniper", id + TASK_POWER_SNIPER);

					client_print(0, print_center, "¡El SNIPER activó su DISPARO VELOZ!");
				}
			}
		}
		case MODE_JASON:
		{
			if(g_Mode == MODE_DRUNK)
				return PLUGIN_HANDLED;

			if(!g_Habs[id][HAB_L_J_TELEPORT])
				return PLUGIN_HANDLED;

			if(g_ModeJason_Teleport[id])
			{
				dg_color_chat(id, _, "Ya utilizaste tu teleport");
				return PLUGIN_HANDLED;
			}

			g_ModeJason_Teleport[id] = 1;

			randomSpawn(id);
		}
		case MODE_ASSASSIN:
		{
			if(!g_ModeAssassin_PowerGlow[id])
			{
				dg_color_chat(id, _, "Ya has utilizado el poder");
				return PLUGIN_HANDLED;
			}

			g_ModeAssassin_PowerGlow[id] = 0;

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				if(g_SpecialMode[i] == MODE_ASSASSIN)
					continue;

				set_user_rendering(i, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 125);
				
				remove_task(i + TASK_POWER_ASSASSIN);
				set_task(15.0, "task__RemovePowerAssassin", i + TASK_POWER_ASSASSIN);
			}

			client_print(0, print_center, "El ASSASSIN ha activado su PODER");
		}
		case MODE_FVSJ:
		{
			if(g_ModeFvsJ_Jason[id])
			{
				if(g_ModeFvsJ_JasonPower[id] == 1)
				{
					g_ModeFvsJ_JasonPower[id] = 2;

					remove_task(id + TASK_POWER_FVSJ_JASON);
					set_task(10.0, "task__PowerFvsJJason", id + TASK_POWER_FVSJ_JASON);

					client_print(0, print_center, "¡El JASON ha activado su VELOCIDAD de disparo!");
				}
			}
			else
			{
				if(g_ModeFvsJ_FreddyPowerType[id] && g_ModeFvsJ_FreddyPower[id] == 1)
				{
					g_ModeFvsJ_FreddyPower[id] = 2;

					switch(g_ModeFvsJ_FreddyPowerType[id])
					{
						case 1:
						{
							randomSpawn(id);
							client_print(0, print_center, "¡Un FREDDY se ha TELETRANSPORTADO!");
						}
						case 2:
						{
							for(new i = 1; i <= g_MaxPlayers; ++i)
							{
								if(!g_IsAlive[i] || !g_Zombie[i] || g_Immunity[i])
									continue;

								startZombieMadness(i, 5.0, 1, 0);
							}
						}
						case 3:
						{
							entity_set_int(id, EV_INT_rendermode, kRenderTransAlpha);
							entity_set_float(id, EV_FL_renderamt, 0.0);

							if(g_HatId[id])
							{
								if(is_valid_ent(g_HatEnt[id]))
								{
									entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
									entity_set_float(g_HatEnt[id], EV_FL_renderamt, 0.0);
								}
							}

							remove_task(id + TASK_POWER_PREDATOR);
							set_task(10.0, "task__FinishPowerPredator", id + TASK_POWER_PREDATOR);

							client_print(0, print_center, "¡El FREDDY se ha vuelto INVISIBLE!");
						}
					}
				}
			}
		}
		case MODE_AVSP:
		{
			if(g_SpecialMode_Alien[id])
			{
				if(!g_ModeAvsp_AlienPower[id])
				{
					dg_color_chat(id, _, "Ya has utilizado el poder");
					return PLUGIN_HANDLED;
				}

				g_ModeAvsp_AlienPower[id] = 0;

				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i] || !g_Zombie[i] || g_Immunity[i])
						continue;

					startZombieMadness(i, 5.0, 1, 0);
				}
			}
			else if(g_SpecialMode_Predator[id])
			{
				if(!g_ModeAvsp_PredatorPower[id])
				{
					dg_color_chat(id, _, "Ya has utilizado el poder");
					return PLUGIN_HANDLED;
				}

				g_ModeAvsp_PredatorPower[id] = 0;

				entity_set_int(id, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(id, EV_FL_renderamt, 0.0);

				if(g_HatId[id])
				{
					if(is_valid_ent(g_HatEnt[id]))
					{
						entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
						entity_set_float(g_HatEnt[id], EV_FL_renderamt, 0.0);
					}
				}

				remove_task(id + TASK_POWER_PREDATOR);
				set_task(15.0, "task__FinishPowerPredator", id + TASK_POWER_PREDATOR);

				client_print(0, print_center, "¡El DEPREDADOR se ha vuelto INVISIBLE!");
			}
		}
		default:
		{
			if(canUseMiniGames(id))
			{
				static Float:vecOrigin[3];
				static Float:vecEndOrigin[3];
				static iTraceResult;
				static Float:fFraction;

				entity_get_vector(id, EV_VEC_origin, vecOrigin);
				getDropOrigin(id, vecEndOrigin, 20);

				iTraceResult = 0;
				engfunc(EngFunc_TraceLine, vecOrigin, vecEndOrigin, IGNORE_MONSTERS, id, iTraceResult);

				get_tr2(iTraceResult, TR_flFraction, fFraction);

				if(fFraction == 1.0)
				{
					if(!g_MiniGameTejo_On)
						dropHeadZombie(id);
					else
						fakeDropHeadZombie(id);
				}
			}
		}
	}

	return PLUGIN_HANDLED;
}

public task__PowerGrunt()
{
	new const LETTERS_LIGHT[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 'q', 'p', 'o', 'n', 'm', 'l', 'k', 'j', 'i', 'h', 'g', 'f', 'e', 'd', 'c', 'b', 'a'};

	g_Lights[0] = LETTERS_LIGHT[g_ModeGrunt_Power];
	changeLights();

	++g_ModeGrunt_Power;

	if(g_ModeGrunt_Power == 35)
	{
		g_Lights[0] = 'a';

		changeLights();
		return;
	}

	set_task(0.2, "task__PowerGrunt");
}

public clcmd__SaveAll(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	new iCount;
	new i;

	iCount = 0;

	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i] || !g_AccountLogged[i] || g_LoadingData[i])
			continue;

		saveInfo(i);
		++iCount;
	}

	g_DataSaved = 1;

	dg_color_chat(0, _, "Guardando datos de !g%d usuario%s!y. A partir de aquí el guardado está deshabilitado hasta el cambio de mapa", iCount, ((iCount != 1) ? "s" : ""));
	return PLUGIN_HANDLED;
}

public clcmd__Health(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(sArg1[0] == '@')
	{
		static sArg2[8];
		read_argv(2, sArg2, charsmax(sArg2));

		if(read_argc() < 3)
		{
			dg_console_chat(id, "Uso: zp_health <nombre o @> <cantidad>");
			dg_console_chat(id, "Si quieres darle vida a todos los jugadores vivos, utiliza zp_health <@> <cantidad>");

			return PLUGIN_HANDLED;
		}

		new iHealth = str_to_num(sArg2);
		new i;

		for(i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;

			dg_color_chat(i, _, "!t%s!y te editó la vida y ahora tenés !g%d!y de vida", g_PlayerName[id], iHealth);
			set_user_health(i, iHealth);

			g_Health[i] = iHealth;
			g_MaxHealth[i] = g_Health[i];
		}
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		static sArg2[21];
		read_argv(2, sArg2, 20);

		if(read_argc() < 3)
		{
			dg_console_chat(id, "Uso: zp_health <nombre> <cantidad>");
			return PLUGIN_HANDLED;
		}

		static iHealth;
		iHealth = str_to_num(sArg2);

		if(iHealth <= 0)
		{
			dg_console_chat(id, "La cantidad ingresada es inválida");
			return PLUGIN_HANDLED;
		}

		dg_color_chat(iUserId, _, "!t%s!y te editó la vida y ahora tenés !g%d!y de vida", g_PlayerName[id], iHealth);
		set_user_health(iUserId, iHealth);

		g_Health[iUserId] = iHealth;
		g_MaxHealth[iUserId] = g_Health[iUserId];
	}

	return PLUGIN_HANDLED;
}

public clcmd__APs(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}

	static sArg2[16];
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3)
	{
		dg_console_chat(id, "Uso: zp_aps <nombre> <factor, + o nada (setear)> <cantidad>");
		return PLUGIN_HANDLED;
	}

	static iAPs;
	static iLastAPs;

	iAPs = str_to_num(sArg2);
	iLastAPs = g_AmmoPacks[iUserId];

	switch(sArg2[0])
	{
		case '+':
		{
			dg_color_chat(iUserId, _, "!t%s!y te ha dado !g%d APs!y", g_PlayerName[id], iAPs);
			
			g_AmmoPacks[iUserId] += iAPs;
		}
		default:
		{
			dg_color_chat(iUserId, _, "!t%s!y te ha editado tu !gAPs!y, ahora tienes !g%d APs!y", g_PlayerName[id], iAPs);
			
			g_AmmoPacks[iUserId] = iAPs;
		}
	}

	dg_console_chat(id, "%s tenía %d APs y ahora tiene %d APs", g_PlayerName[iUserId], iLastAPs, g_AmmoPacks[iUserId]);
	return PLUGIN_HANDLED;
}

public clcmd__Exp(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}

	static sArg2[16];
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3)
	{
		dg_console_chat(id, "Uso: zp_exp <nombre> <factor, + o nada (setear)> <cantidad>");
		return PLUGIN_HANDLED;
	}

	static iXP;
	static iLastXP;

	iXP = str_to_num(sArg2);
	iLastXP = g_Exp[iUserId];

	switch(sArg2[0])
	{
		case '+':
		{
			dg_color_chat(iUserId, _, "!t%s!y te ha dado !g%d XP!y", g_PlayerName[id], iXP);

			g_Exp[iUserId] += iXP;

			checkExpEquation(iUserId);
		}
		default:
		{
			dg_color_chat(iUserId, _, "!t%s!y te ha editado tu !gXP!y, ahora tienes !g%d XP!y", g_PlayerName[id], iXP);

			g_Exp[iUserId] = iXP;

			checkExpEquation(iUserId);
		}
	}

	dg_console_chat(id, "%s tenía %d XP y ahora tiene %d XP", g_PlayerName[iUserId], iLastXP, g_Exp[iUserId]);
	return PLUGIN_HANDLED;
}

public clcmd__Level(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if((sArg1[0] == '@' && sArg1[1] == 'P') || (sArg1[0] == '@' && sArg1[1] == 'A'))
	{
		static sArg2[8];
		read_argv(2, sArg2, charsmax(sArg2));

		if(read_argc() < 3)
		{
			dg_console_chat(id, "Uso: zp_level <nombre> <factor, + o nada (setear)> <cantidad>");
			return PLUGIN_HANDLED;
		}

		static iLevel;
		iLevel = str_to_num(sArg2);

		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(sArg1[0] == '@' && sArg1[1] == 'P')
			{
				if(!g_IsConnected[i])
					continue;
			}
			else if(sArg1[0] == '@' && sArg1[1] == 'A')
			{
				if(!g_IsAlive[i])
					continue;
			}

			if((g_Level[i] + iLevel) >= MAX_LEVEL)
			{
				g_Level[i] = MAX_LEVEL;
				continue;
			}

			g_Exp[i] = 0;
			g_Level[i] += iLevel;

			checkExpEquation(i);
		}

		dg_color_chat(0, _, "!t%s!y le ha dado a todos los usuarios %s !g%d nivel%s!y", g_PlayerName[id], ((sArg1[0] == '@' && sArg1[1] == 'P') ? "conectados" : "vivos"), iLevel, ((iLevel != 1) ? "es" : ""));
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		static sArg2[8];
		read_argv(2, sArg2, charsmax(sArg2));

		if(read_argc() < 3)
		{
			dg_console_chat(id, "Uso: zp_level <nombre> <factor, + o nada (setear)> <cantidad>");
			return PLUGIN_HANDLED;
		}

		static iLevel;
		static iLastLevel;

		iLevel = str_to_num(sArg2);
		iLastLevel = g_Level[iUserId];

		switch(sArg2[0])
		{
			case '+':
			{
				dg_color_chat(iUserId, _, "!t%s!y te ha dado !g%d nivel%s!y", g_PlayerName[id], iLevel, ((iLevel != 1) ? "es" : ""));

				g_Exp[iUserId] = 0;

				if((g_Level[iUserId] + iLevel) >= MAX_LEVEL)
					g_Level[iUserId] = MAX_LEVEL;
				else
					g_Level[iUserId] += iLevel;

				checkExpEquation(iUserId);
			}
			default:
			{
				dg_color_chat(iUserId, _, "!t%s!y te ha editado tus !gniveles!y, ahora eres !gnivel %d!y", g_PlayerName[id], iLevel);

				g_Exp[iUserId] = 0;

				if(g_Level[iUserId] >= MAX_LEVEL)
					g_Level[iUserId] = MAX_LEVEL;
				else
					g_Level[iUserId] = iLevel;

				checkExpEquation(iUserId);
			}
		}

		dg_console_chat(id, "%s tenía %d nivel%s y ahora tiene %d nivel%s", g_PlayerName[iUserId], iLastLevel, ((iLastLevel != 1) ? "es" : ""), g_Level[iUserId], ((g_Level[iUserId] != 1) ? "es" : ""));
	}

	return PLUGIN_HANDLED;
}

public clcmd__Reset(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}

	static sArg2[8];
	read_argv(2, sArg2, charsmax(sArg2));

	if(read_argc() < 3)
	{
		dg_console_chat(id, "Uso: zp_reset <nombre> <factor, + o nada (setear)> <cantidad>");
		return PLUGIN_HANDLED;
	}

	static iReset;
	static iLastReset;

	iReset = str_to_num(sArg2);
	iLastReset = g_Reset[iUserId];

	switch(sArg2[0])
	{
		case '+':
		{
			dg_color_chat(iUserId, _, "!t%s!y te ha dado el !grango %c!y", g_PlayerName[id], getUserRange(iReset));

			g_Exp[iUserId] = 0;
			g_Reset[iUserId] += iReset;

			checkExpEquation(iUserId);
		}
		default:
		{
			dg_color_chat(iUserId, _, "!t%s!y te ha editado tu !grango!y, ahora estás en el !grango %c!y", g_PlayerName[id], getUserRange(iReset));

			g_Exp[iUserId] = 0;
			g_Reset[iUserId] = iReset;

			checkExpEquation(iUserId);
		}
	}

	dg_console_chat(id, "%s estaba en el rango %c y ahora esta en el rango %c", g_PlayerName[iUserId], getUserRange(iLastReset), getUserRange(g_Reset[iUserId]));
	return PLUGIN_HANDLED;
}

public clcmd__Points(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}

	static sArg2[16];
	static sArg3[2];

	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));

	if(read_argc() < 3)
	{
		dg_console_chat(id, "Uso: zp_points <nombre> <factor (+ , -)> <cantidad> <clase (H, Z, L, E, D)>");
		return PLUGIN_HANDLED;
	}

	static iPoints;
	static iClass;

	iPoints = str_to_num(sArg2);
	iClass = -1;

	switch(sArg3[0])
	{
		case 'H': iClass = POINT_HUMAN;
		case 'Z': iClass = POINT_ZOMBIE;
		case 'L': iClass = POINT_LEGACY;
		case 'S': iClass = POINT_SPECIAL;
		case 'D': iClass = POINT_DIAMMONDS;
	}

	switch(sArg2[0])
	{
		case '+', '-':
		{
			if(iClass >= 0)
			{
				g_Points[iUserId][iClass] += iPoints;

				dg_color_chat(iUserId, _, "!t%s!y te ha %s !g%d p%c!y", g_PlayerName[id], ((sArg2[0] == '+') ? "dado" : "sacado"), iPoints, sArg3[0]);
				return PLUGIN_HANDLED;
			}
			else
			{
				for(new i = 0; i < structIdPoints; ++i)
					g_Points[iUserId][i] += iPoints;

				dg_color_chat(iUserId, _, "!t%s!y te ha %s !g%d pHZLED!y", g_PlayerName[id], ((sArg2[0] == '+') ? "dado" : "sacado"), iPoints);
			}
		}
		default:
		{
			if(iClass >= 0)
			{
				g_Points[iUserId][iClass] = iPoints;
				
				dg_color_chat(iUserId, _, "!t%s!y te ha editado tus !gp%c!y, ahora tenés !g%d p%c!y", g_PlayerName[id], sArg3[0], iPoints, sArg3[0]);
				return PLUGIN_HANDLED;
			}
			else
			{
				for(new i = 0; i < structIdPoints; ++i)
					g_Points[iUserId][i] = iPoints;

				dg_color_chat(iUserId, _, "!t%s!y te ha editado tus !gpHZLED!y, ahora tenés !g%d pHZLED!y", g_PlayerName[id], iPoints);
			}
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__Achievements(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}
	
	if(read_argc() < 3)
	{
		g_AchievementTempIds = 1;

		for(new i = 0; i < (50 * g_AchievementTempIds); ++i)
			dg_console_chat(id, "%d = %s", i, ACHIEVEMENTS[i][achievementName]);

		set_task(1.0, "task__AchievementTempIds", id);
		return PLUGIN_HANDLED;
	}

	static sAchievement[8];
	static iAchievement;

	read_argv(2, sAchievement, charsmax(sAchievement));
	iAchievement = str_to_num(sAchievement);

	if(contain(ACHIEVEMENTS[iAchievement][achievementName], "PRIMERO:") == -1)
		setAchievement(iUserId, iAchievement, 0);
	else
		setAchievementFirst(iUserId, iAchievement);

	return PLUGIN_HANDLED;
}

public clcmd__Hats(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}

	if(read_argc() < 3)
	{
		for(new i = 0; i < structIdHats; ++i)
			dg_console_chat(id, "%d = %s", i, HATS[i][hatName]);

		return PLUGIN_HANDLED;
	}

	static sHat[8];
	static iHat;

	read_argv(2, sHat, charsmax(sHat));
	iHat = str_to_num(sHat);

	if(iHat < 0 || iHat > (structIdHats - 1))
	{
		dg_console_chat(id, "El gorro que intentas dar es invalido");
		return PLUGIN_HANDLED;
	}

	giveHat(iUserId, iHat);
	return PLUGIN_HANDLED;
}

public clcmd__Ban(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_C))
		return PLUGIN_HANDLED;
	
	new sName[33];
	read_argv(1, sName, charsmax(sName));

	new sTime[8];
	read_argv(2, sTime, charsmax(sTime));
	remove_quotes(sTime);

	new sReason[256];
	read_argv(3, sReason, charsmax(sReason));
	remove_quotes(sReason);

	if(read_argc() < 4)
	{
		dg_console_chat(id, "El comando debe ser introducido de la siguiente manera: zp_ban <NOMBRE COMPLETO> <TIEMPO (m, h o d)> <RAZON OBLIGATORIA>");
		dg_console_chat(id, "m = Minutos | h = Horas | d = Días");
		dg_console_chat(id, "Ingrese 0d para banearlo permanentemente");

		return PLUGIN_HANDLED;
	}
	else if(containLetters(sTime) || !countNumbers(sTime) || equali(sTime, "") || containi(sTime, " ") != -1)
	{
		dg_console_chat(id, "El campo de TIEMPO tiene que contener sólo números");
		return PLUGIN_HANDLED;
	}
	else if(equali(sReason, ""))
	{
		dg_console_chat(id, "El campo RAZON no puede estar vacio");
		return PLUGIN_HANDLED;
	}

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp6_pjs.acc_id, zp6_accounts.ip, zp6_accounts.steam FROM zp6_pjs LEFT JOIN zp6_accounts ON zp6_accounts.id=zp6_pjs.acc_id WHERE zp6_pjs.pj_name=^"%s^";", sName);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 5);
	else if(SQL_NumResults(sqlQuery))
	{
		new iAccountId;
		new sIpDB[16];
		new sSteamDB[36];

		iAccountId = SQL_ReadResult(sqlQuery, 0);
		SQL_ReadResult(sqlQuery, 1, sIpDB, charsmax(sIpDB));
		SQL_ReadResult(sqlQuery, 2, sSteamDB, charsmax(sSteamDB));

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_bans WHERE acc_id='%d' AND active='1';", iAccountId);

		if(!SQL_Execute(sqlQuery))
			executeQuery(id, sqlQuery, 6);
		else if(SQL_NumResults(sqlQuery))
		{
			dg_console_chat(id, "El usuario indicado ya esta baneado");
			SQL_FreeHandle(sqlQuery);
		}
		else
		{
			SQL_FreeHandle(sqlQuery);

			new iExpireBan;
			new iTime;

			if(equal(sTime, "0d"))
			{
				iExpireBan = 2000000000;
				dg_color_chat(0, _, "!t%s!y baneo la cuenta de !g%s!y permanentemente - Razón !t[!g%s!t]!y", g_PlayerName[id], sName, sReason);
			}
			else if(containi(sTime, "d") != -1)
			{
				replace(sTime, charsmax(sTime), "d", "");
				iTime = str_to_num(sTime);

				if(iTime < 0)
				{
					dg_console_chat(id, "No podes banear por menos de cero dias");
					return PLUGIN_HANDLED;
				}

				iExpireBan = (get_systime() + (((iTime * 24) * 60) * 60));
				dg_color_chat(0, _, "!t%s!y baneo la cuenta de !g%s!y durante !g%d!y día%s - Razón !t[!g%s!t]!y", g_PlayerName[id], sName, iTime, ((iTime == 1) ? "" : "s"), sReason);
			}
			else if(containi(sTime, "h") != -1)
			{
				replace(sTime, charsmax(sTime), "h", "");
				iTime = str_to_num(sTime);

				if(iTime > 23)
				{
					dg_console_chat(id, "No podes banear por mas de 23 horas, usa dias...");
					return PLUGIN_HANDLED;
				}
				else if(iTime < 1)
				{
					dg_console_chat(id, "No podes banear por menos de una hora");
					return PLUGIN_HANDLED;
				}

				iExpireBan = (get_systime() + ((iTime * 60) * 60));
				dg_color_chat(0, _, "!t%s!y baneo la cuenta de !g%s!y durante !g%d!y hora%s - Razón !t[!g%s!t]!y", g_PlayerName[id], sName, iTime, ((iTime == 1) ? "" : "s"), sReason);
			}
			else if(containi(sTime, "m") != -1)
			{
				replace(sTime, charsmax(sTime), "m", "");
				iTime = str_to_num(sTime);

				if(iTime > 60)
				{
					dg_console_chat(id, "No podes banear por mas de 60 minutos, usa horas...");
					return PLUGIN_HANDLED;
				}
				else if(iTime < 1)
				{
					dg_console_chat(id, "No podes banear por menos de un minuto");
					return PLUGIN_HANDLED;
				}

				iExpireBan = (get_systime() + (iTime * 60));
				dg_color_chat(0, _, "!t%s!y baneo la cuenta de !g%s!y durante !g%d!y minuto%s - Razón !t[!g%s!t]!y", g_PlayerName[id], sName, iTime, ((iTime == 1) ? "" : "s"), sReason);
			}
			else
			{
				dg_console_chat(id, "Algo esta fallando, revisa el formato del comando nuevamente");
				return PLUGIN_HANDLED;
			}

			new iSysTime;
			iSysTime = get_systime();

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_bans (acc_id, ip, steam, admin_name, start, finish, reason) VALUES ('%d', ^"%s^", ^"%s^", ^"%s^", '%d', '%d', ^"%s^");", iAccountId, sIpDB, sSteamDB, g_PlayerName[id], iSysTime, iExpireBan, sReason);
			
			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 7);
			else
				SQL_FreeHandle(sqlQuery);

			new iTargetId;
			iTargetId = get_user_index(sName);

			if(g_IsConnected[iTargetId])
			{
				dg_console_chat(iTargetId, "");
				dg_console_chat(iTargetId, "");
				dg_console_chat(iTargetId, "TU CUENTA ESTA BANEADA");
				dg_console_chat(iTargetId, "");
				dg_console_chat(iTargetId, "Administrador que te baneo: %s", g_PlayerName[id]);
				dg_console_chat(iTargetId, "El ban fue realizado en la fecha: %s", getUnixToTime(iSysTime, 1));
				dg_console_chat(iTargetId, "El ban expira en la fecha: %s", getUnixToTime(iExpireBan, 1));
				dg_console_chat(iTargetId, "Razón: %s", sReason);
				dg_console_chat(iTargetId, "Cuenta #%d", g_AccountId[iTargetId]);
				dg_console_chat(iTargetId, "");
				dg_console_chat(iTargetId, "");
				
				server_cmd("kick #%d", get_user_userid(iTargetId));
			}
		}
	}
	else
	{
		dg_console_chat(id, "El usuario indicado no existe. Recorda escribir su nombre COMPLETAMENTE respetando mayusculas y minusculas");
		SQL_FreeHandle(sqlQuery);
	}

	return PLUGIN_HANDLED;
}

public clcmd__UnBan(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_C))
		return PLUGIN_HANDLED;

	new sName[33];
	read_argv(1, sName, charsmax(sName));
	
	if(read_argc() < 2)
	{
		dg_console_chat(id, "El comando debe ser introducido de la siguiente manera: zp_unban <NOMBRE COMPLETO>");
		return PLUGIN_HANDLED;
	}

	static Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT zp6_pjs.acc_id, zp6_accounts.ip, zp6_accounts.steam FROM zp6_pjs LEFT JOIN zp6_accounts ON zp6_accounts.id=zp6_pjs.acc_id WHERE zp6_pjs.pj_name=^"%s^";", sName);
	
	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 8);
	else if(SQL_NumResults(sqlQuery))
	{
		static iId;
		static sIp[16];
		static sSteam[35];

		iId = SQL_ReadResult(sqlQuery, 0);
		SQL_ReadResult(sqlQuery, 1, sIp, charsmax(sIp));
		SQL_ReadResult(sqlQuery, 2, sSteam, charsmax(sSteam));

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_bans WHERE (acc_id='%d' OR ip=^"%s^" OR steam=^"%s^") AND active='1';", iId, sIp, sSteam);

		if(!SQL_Execute(sqlQuery))
			executeQuery(id, sqlQuery, 9);
		else if(SQL_NumResults(sqlQuery))
		{
			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_bans SET active='0' WHERE (acc_id='%d' OR ip=^"%s^" OR steam=^"%s^") AND active='1';", iId, sIp, sSteam);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 10);
			else
				SQL_FreeHandle(sqlQuery);
			
			dg_color_chat(0, _, "!t%s!y desbaneo la cuenta de !g%s!y", g_PlayerName[id], sName);
			dg_console_chat(id, "El usuario indicado fue desbaneado");
		}
		else
		{
			dg_console_chat(id, "El usuario indicado no esta baneado, esta mal escrito o no esta baneado por el modo de ban indicado");
			SQL_FreeHandle(sqlQuery);
		}
	}
	else
		SQL_FreeHandle(sqlQuery);

	return PLUGIN_HANDLED;
}

public clcmd__Modes(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_C))
		return PLUGIN_HANDLED;

	new sArg0[32];
	new iMode;

	read_argv(0, sArg0, charsmax(sArg0));
	iMode = MODE_NONE;

	if(equal(sArg0, "zp_infection"))
		iMode = MODE_INFECTION;
	else if(equal(sArg0, "zp_plague"))
		iMode = MODE_PLAGUE;
	else if(equal(sArg0, "zp_armageddon"))
		iMode = MODE_ARMAGEDDON;
	else if(equal(sArg0, "zp_mega_armageddon"))
		iMode = MODE_MEGA_ARMAGEDDON;
	else if(equal(sArg0, "zp_gungame"))
		iMode = MODE_GUNGAME;
	else if(equal(sArg0, "zp_mega_gungame"))
		iMode = MODE_MEGA_GUNGAME;
	else if(equal(sArg0, "zp_fvsj"))
		iMode = MODE_FVSJ;
	else if(equal(sArg0, "zp_synapsis"))
		iMode = MODE_SYNAPSIS;
	else if(equal(sArg0, "zp_avsp"))
		iMode = MODE_AVSP;
	else if(equal(sArg0, "zp_duel_final"))
		iMode = MODE_DUEL_FINAL;
	else if(equal(sArg0, "zp_drunk"))
		iMode = MODE_DRUNK;
	else if(equal(sArg0, "zp_sniper"))
		iMode = MODE_SNIPER;
	else if(equal(sArg0, "zp_tribal"))
		iMode = MODE_TRIBAL;
	else if(equal(sArg0, "zp_l4d2"))
		iMode = MODE_L4D2;

	if(iMode == MODE_NONE)
	{
		dg_console_chat(id, "Hubo un error al lanzar el modo seleccionado");
		return PLUGIN_HANDLED;
	}
	else if(iMode == MODE_MEGA_ARMAGEDDON || iMode == MODE_GUNGAME || iMode == MODE_MEGA_GUNGAME || iMode == MODE_FVSJ)
	{
		if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		{
			dg_console_chat(id, "No tienes permisos para lanzar este modo");
			return PLUGIN_HANDLED;
		}
	}
	else if(!g_VirusT)
	{
		if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		{
			dg_console_chat(id, "Debes esperar a que salga el cartel del Virus-T para poder lanzar un modo");
			return PLUGIN_HANDLED;
		}
	}
	else if(g_EventModes)
	{
		if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		{
			dg_console_chat(id, "No puedes lanzar modos en el horario del Evento");
			return PLUGIN_HANDLED;
		}
	}
	else if(g_ModeCountAdmin[iMode] == 2)
	{
		if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		{
			dg_console_chat(id, "Llegaste al límite de modos máximos");
			return PLUGIN_HANDLED;
		}
	}

	if(!task_exists(TASK_START_MODE))
		return PLUGIN_HANDLED;

	if(iMode == MODE_DUEL_FINAL)
	{
		static sArg1[8];
		static iDuelFinal;

		read_argv(1, sArg1, charsmax(sArg1));
		iDuelFinal = str_to_num(sArg1);

		if(iDuelFinal < 1 || iDuelFinal > 6)
		{
			dg_console_chat(id, "El <Id> del duelo final es incorrecto");
			dg_console_chat(id, "<Id> = DUELO FINAL");
			dg_console_chat(id, "1 = CUCHILLO");
			dg_console_chat(id, "2 = AWP");
			dg_console_chat(id, "3 = HE");
			dg_console_chat(id, "4 = DEAGLE (Only Head)");
			dg_console_chat(id, "5 = M3");
			dg_console_chat(id, "6 = SCOUT");
			dg_console_chat(id, "Ejemplo: zp_duel_final 3");

			return PLUGIN_HANDLED;
		}

		g_ModeDuelFinal_Type = iDuelFinal;
	}
	else if(iMode == MODE_GUNGAME)
	{
		static sArg1[8];
		static iGunGame;

		read_argv(1, sArg1, charsmax(sArg1));
		iGunGame = str_to_num(sArg1);

		if(iGunGame < 0 || iGunGame > 5)
		{
			dg_console_chat(id, "El <Id> del gungame es incorrecto");
			dg_console_chat(id, "<Id> = GUNGAME");
			dg_console_chat(id, "0 = NORMAL");
			dg_console_chat(id, "1 = FAST");
			dg_console_chat(id, "2 = SLOW");
			dg_console_chat(id, "3 = ONLY HEAD");
			dg_console_chat(id, "4 = CRAZY");
			dg_console_chat(id, "5 = CLÁSICO");
			dg_console_chat(id, "Ejemplo: zp_gungame 3");

			return PLUGIN_HANDLED;
		}

		g_ModeGG_Type = iGunGame;
	}

	g_StartMode[1] = g_StartMode[0];

	dg_color_chat(0, _, "!t%s!y lanzó el modo !g%s!y", g_PlayerName[id], __MODES[iMode]);

	remove_task(TASK_START_MODE);
	startMode(iMode);

	logToFileModes(id, iMode, 0);

	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		++g_ModeCountAdmin[iMode];

	return PLUGIN_HANDLED;
}

public clcmd__Respawn(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	if(g_VirusT != 2 || g_EndRound)
	{
		dg_console_chat(id, "No puedes lanzar modo o convertir a un usuario en este momento");
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}

	respawnUserManually(iUserId);

	dg_color_chat(0, _, "!t%s!y revivió a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);
	return PLUGIN_HANDLED;
}

public clcmd__Zombie(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}
	else if(!(get_user_flags(id) & ADMIN_LEVEL_H) && (g_NewRound || g_EndRound))
	{
		dg_console_chat(id, "No puedes convertir en Zombie mientras se esté eligiendo el modo");
		return PLUGIN_HANDLED;
	}

	zombieMe(iUserId);

	dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gZOMBIE!y", g_PlayerName[id], g_PlayerName[iUserId]);
	return PLUGIN_HANDLED;
}

public clcmd__Human(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	static iUserId;

	read_argv(1, sArg1, charsmax(sArg1));
	iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iUserId)
	{
		dg_console_chat(id, "No se ha encontrado al usuario especificado");
		return PLUGIN_HANDLED;
	}
	else if(!(get_user_flags(id) & ADMIN_LEVEL_H) && (g_NewRound || g_EndRound))
	{
		dg_console_chat(id, "No puedes convertir en Humano mientras se esté eligiendo el modo");
		return PLUGIN_HANDLED;
	}

	humanMe(iUserId);

	dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gHUMANO!y", g_PlayerName[id], g_PlayerName[iUserId]);
	return PLUGIN_HANDLED;
}

public clcmd__Survivor(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(.alive=1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gSURVIVOR!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_SURVIVOR;

		remove_task(TASK_START_MODE);
		startMode(MODE_SURVIVOR, iId);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		if(g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_SURVIVOR;

			remove_task(TASK_START_MODE);
			startMode(MODE_SURVIVOR, iUserId);
		}
		else
			humanMe(iUserId, .survivor=1);

		dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gSURVIVOR!y", g_PlayerName[id], g_PlayerName[iUserId]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Wesker(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(.alive=1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gWESKER!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_WESKER;

		remove_task(TASK_START_MODE);
		startMode(MODE_WESKER, iId);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		if(g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_WESKER;

			remove_task(TASK_START_MODE);
			startMode(MODE_WESKER, iUserId);
		}
		else
			humanMe(iUserId, .wesker=1);

		dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gWESKER!y", g_PlayerName[id], g_PlayerName[iUserId]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__SniperElite(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(.alive=1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gSNIPER ELITE!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_SNIPER_ELITE;

		remove_task(TASK_START_MODE);
		startMode(MODE_SNIPER_ELITE, iId);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		if(g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_SNIPER_ELITE;

			remove_task(TASK_START_MODE);
			startMode(MODE_SNIPER_ELITE, iUserId);
		}
		else
			humanMe(iUserId, .sniper_elite=1);

		dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gSNIPER ELITE!y", g_PlayerName[id], g_PlayerName[iUserId]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Jason(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(.alive=1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gJASON!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_JASON;

		remove_task(TASK_START_MODE);
		startMode(MODE_JASON, iId);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		if(g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_JASON;

			remove_task(TASK_START_MODE);
			startMode(MODE_JASON, iUserId);
		}
		else
			humanMe(iUserId, .jason=1);

		dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gJASON!y", g_PlayerName[id], g_PlayerName[iUserId]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Nemesis(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(.alive=1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gNEMESIS!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_NEMESIS;

		remove_task(TASK_START_MODE);
		startMode(MODE_NEMESIS);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		if(g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_NEMESIS;

			remove_task(TASK_START_MODE);
			startMode(MODE_NEMESIS, iUserId);
		}
		else
			zombieMe(iUserId, .nemesis=1);

		dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gNEMESIS!y", g_PlayerName[id], g_PlayerName[iUserId]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Assassin(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(.alive=1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gASSASSIN!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_ASSASSIN;

		remove_task(TASK_START_MODE);
		startMode(MODE_ASSASSIN, iId);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		if(g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_ASSASSIN;

			remove_task(TASK_START_MODE);
			startMode(MODE_ASSASSIN, iUserId);
		}
		else
			zombieMe(iUserId, .assassin=1);

		dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gASSASSIN!y", g_PlayerName[id], g_PlayerName[iUserId]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Annihilator(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(.alive=1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gANIQUILADOR!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_ANNIHILATOR;

		remove_task(TASK_START_MODE);
		startMode(MODE_ANNIHILATOR, iId);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al usuario especificado");
			return PLUGIN_HANDLED;
		}

		if(g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_ANNIHILATOR;

			remove_task(TASK_START_MODE);
			startMode(MODE_ANNIHILATOR, iUserId);
		}
		else
			zombieMe(iUserId, .annihilator=1);

		dg_color_chat(0, _, "!t%s!y convirtió a !t%s!y en !gANIQUILADOR!y", g_PlayerName[id], g_PlayerName[iUserId]);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Grunt(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	static sArg1[33];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!sArg1[0])
	{
		if(!g_NewRound && !g_EndRound)
			return PLUGIN_HANDLED;

		static iId;
		iId = getRandomUser(1);

		if(!isUserValid(iId))
			iId = 0;

		dg_color_chat(0, _, "!t%s!y lanzó el modo !gGRUNT!y y se le otorgó a !t%s!y al azar", g_PlayerName[id], g_PlayerName[iId]);

		g_StartMode[1] = g_StartMode[0];
		g_StartMode[0] = MODE_GRUNT;

		remove_task(TASK_START_MODE);
		startMode(MODE_GRUNT, iId);
	}
	else
	{
		static iUserId;
		iUserId = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

		if(!iUserId)
		{
			dg_console_chat(id, "No se ha encontrado al jugador especificado");
			return PLUGIN_HANDLED;
		}

		if(!g_NewRound)
		{
			g_StartMode[1] = g_StartMode[0];
			g_StartMode[0] = MODE_GRUNT;

			dg_color_chat(0, _, "!t%s!y convirtió a !g%s!y en !gGRUNT!y", g_PlayerName[id], g_PlayerName[iUserId]);
			zombieMe(iUserId, .grunt=1);
		}
		else
		{
			dg_color_chat(0, _, "!t%s!y lanzó el modo !gGRUNT!y y se le otorgó a !t%s!y", g_PlayerName[id], g_PlayerName[iUserId]);

			remove_task(TASK_START_MODE);
			startMode(MODE_GRUNT, iUserId);
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__NextModeConsole(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_C))
		return PLUGIN_HANDLED;

	static sArg1[8];
	static iMode;

	read_argv(1, sArg1, charsmax(sArg1));
	iMode = str_to_num(sArg1);

	if(read_argc() < 2)
	{
		for(new i = MODE_INFECTION; i <= (structIdModes - 1); ++i)
			dg_console_chat(id, "%d = %s", i, __MODES[i][modeName]);

		return PLUGIN_HANDLED;
	}

	if(!(MODE_INFECTION <= iMode <= (structIdModes - 1)))
	{
		dg_console_chat(id, "Hubo un error al elegir el próximo modo");
		return PLUGIN_HANDLED;
	}

	g_StartMode[1] = iMode;

	if((get_user_flags(id) & ADMIN_LEVEL_D))
		g_StartMode_Force = 1;

	dg_color_chat(0, _, "!t%s!y cambió el próximo modo a !g%s!y", g_PlayerName[id], __MODES[iMode][modeName]);
	
	logToFileModes(id, iMode, 1);
	return PLUGIN_HANDLED;
}

public clcmd__AmuletCustomCreate(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	if(g_AmuletCustomCreated[id])
	{
		dg_color_chat(id, _, "Ya creaste un amuleto personalizado, puedes chequearlo y modificarlo en el menú");
		return PLUGIN_HANDLED;
	}
	else if(!g_IsAlive[id])
	{
		dg_color_chat(id, _, "Es recomendable que crees tu amuleto estando vivo, hay veces que el menú principal no funciona en algunos modos");
		return PLUGIN_HANDLED;
	}
	else if(g_Points[id][POINT_DIAMMONDS] < g_AmuletCustomCost[id])
	{
		dg_color_chat(id, _, "No tienes diamantes suficientes para crear el amuleto");
		return PLUGIN_HANDLED;
	}

	console_print(id, "");
	console_print(id, "********* ^"%s^" *********", PLUGIN_COMMUNITY_NAME);
	console_print(id, "Nombre del amuleto: %s", g_AmuletCustomNameFake[id]);
	console_print(id, "");
	console_print(id, "Vida: +%d", g_AmuletCustom[id][acHealth]);
	console_print(id, "Velocidad: +%d", g_AmuletCustom[id][acSpeed]);
	console_print(id, "Gravedad: +%d", g_AmuletCustom[id][acGravity]);
	console_print(id, "Daño: +%d", g_AmuletCustom[id][acDamage]);
	console_print(id, "");
	console_print(id, "Multiplicador de APs: +%d", g_AmuletCustom[id][acMultAPs]);
	console_print(id, "Multiplicador de XP: +%d", g_AmuletCustom[id][acMultXP]);
	console_print(id, "");
	console_print(id, "Respawn humano: +%d%%", g_AmuletCustom[id][acRespawnHuman]);
	console_print(id, "Reducción de Costo de Items Extras", g_AmuletCustom[id][acReduceExtraItems]);
	console_print(id, "");
	console_print(id, " >>>>> ");
	console_print(id, "Para confirmar la operacion escriba en consola: %s", g_AmuletCustomConfirm);
	console_print(id, " >>>>> ");
	console_print(id, "");
	console_print(id, "DIAMANTES DISPONIBLES: %d", g_Points[id][POINT_DIAMMONDS]);
	console_print(id, "COSTO DEL AMULETO: %d DIAMANTES", g_AmuletCustomCost[id]);
	console_print(id, "********* ^"%s^" *********", PLUGIN_COMMUNITY_NAME);
	console_print(id, "");

	return PLUGIN_HANDLED;
}

public clcmd__AmuletCustomConfirm(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	if(g_AmuletCustomCreated[id])
	{
		dg_color_chat(id, _, "Ya creaste un amuleto personalizado, puedes chequearlo y modificarlo en el menú");
		return PLUGIN_HANDLED;
	}
	else if(!g_IsAlive[id])
	{
		dg_color_chat(id, _, "Es recomendable que crees tu amuleto estando vivo, hay veces que el menú principal no funciona en algunos modos");
		return PLUGIN_HANDLED;
	}
	else if(g_Points[id][POINT_DIAMMONDS] < g_AmuletCustomCost[id])
	{
		dg_color_chat(id, _, "No tienes diamantes suficientes para crear el amuleto");
		return PLUGIN_HANDLED;
	}
	else if(g_AmuletCustomCost[id] < 10)
	{
		dg_color_chat(id, _, "El amuleto no contiene nada, aumenta las estadísticas que desee para poder confirmarlo");
		return PLUGIN_HANDLED;
	}
	else if(!g_AmuletCustomNameFake[id][0])
	{
		dg_color_chat(id, _, "Por favor, póngale un nombre a su amuleto");
		return PLUGIN_HANDLED;
	}

	g_Points[id][POINT_DIAMMONDS] -= g_AmuletCustomCost[id];
	g_PointsLose[id][POINT_DIAMMONDS] += g_AmuletCustomCost[id];

	g_AmuletCustomCreated[id] = 1;
	copy(g_AmuletCustomName[id], charsmax(g_AmuletCustomName[]), g_AmuletCustomNameFake[id]);

	static Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_amulets_custom (acc_id, name, health, speed, gravity, damage, mult_aps, mult_xp, respawn_h, reduce_ei) VALUES ('%d', ^"%s^", '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d');",
	g_AccountId[id], g_AmuletCustomName[id], g_AmuletCustom[id][acHealth], g_AmuletCustom[id][acSpeed], g_AmuletCustom[id][acGravity], g_AmuletCustom[id][acDamage], g_AmuletCustom[id][acMultAPs], g_AmuletCustom[id][acMultXP], g_AmuletCustom[id][acRespawnHuman], g_AmuletCustom[id][acReduceExtraItems]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 11);
	else
		SQL_FreeHandle(sqlQuery);

	dg_color_chat(0, _, "!t%s!y ha creado su amuleto personalizado !g%s!y", g_PlayerName[id], g_AmuletCustomName[id]);
	return PLUGIN_HANDLED;
}

// **************************************************
//		[Impulse Functions]
// **************************************************
public impulse__FlashLight(const id)
{
	if(g_Zombie[id])
		return PLUGIN_HANDLED;

	if(g_Mode == MODE_GRUNT)
		g_ModeGrunt_Flash[id] = !g_ModeGrunt_Flash[id];

	if(g_SpecialMode[id])
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public impulse__Spray(const id)
	return PLUGIN_HANDLED;

// **************************************************
//		[Menus Functions]
// **************************************************
public showMenu__AnotherUser(const id)
{
	clearDHUD(id);

	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__AnotherUser", PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(-1, -1, "\yHAY UN USUARIO LOGUEADO CON TU CUENTA^nDENTRO DEL SERVIDOR^n");

	oldmenu_additem(-1, -1, "\wUsuario que está en tu cuenta\r:\y %s", g_AnotherUserInYourAccount_Name[id]);
	oldmenu_additem(-1, -1, "\wCuenta\r:\y #%d^n", g_AnotherUserInYourAccount[id]);

	oldmenu_additem(-1, -1, "\y¿No conoces a esta persona?^n");

	oldmenu_display(id);
}

public menu__AnotherUser(const id, const item)
	return PLUGIN_HANDLED;

public showMenu__Banned(const id)
{
	clearDHUD(id);

	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__Banned", PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(-1, -1, "\yTU CUENTA HA SIDO BANEADA\r:");
	oldmenu_additem(-1, -1, "\wAdministrador\r:\y %s", g_AccountBan_Admin[id]);
	oldmenu_additem(-1, -1, "\wFecha de inicio\r:\y %s", getUnixToTime(g_AccountBan_Start[id], 1));
	oldmenu_additem(-1, -1, "\wFecha de finalización\r:\y %s", getUnixToTime(g_AccountBan_Finish[id], 1));
	oldmenu_additem(-1, -1, "\wRazón\r:\y %s", g_AccountBan_Reason[id]);

	oldmenu_additem(-1, -1, "^n\yNOTA\r:^nSi te resulta injusta la sanción, haz la queja^nen la sección correspondiente del foro^n");

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__Banned(const id, const item)
	return PLUGIN_HANDLED;

public showMenu__LogIn(const id) {
	clearDHUD(id);

	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__LogIn", PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(1, 1, "\r1.\w Crear una cuenta");
	oldmenu_additem(2, 2, "\r2.\w Identificarse^n");

	if(__PLUGIN_UPDATE[0] && __PLUGIN_UPDATE_VERSION[0]) {
		oldmenu_additem(-1, -1, "\wEl día \y%s\w se llevará acabo la actualización a la versión \y%s\w.", __PLUGIN_UPDATE, __PLUGIN_UPDATE_VERSION);
		oldmenu_additem(-1, -1, "\wToda la información de la misma estará en nuestro foro.^n");
	}

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__LogIn(const id, const item) {
	switch(item) {
		case 1: {
			if(g_AccountRegister[id]) {
				dg_color_chat(id, _, "Esta cuenta ya está registrada. Elije otro nombre para tu cuenta por favor.");
				showMenu__LogIn(id);
			} else {
				client_cmd(id, "messagemode CREAR_CUENTA");
				showDHUDMessage(id, 255, 255, 255, -1.0, -1.0, 0, 5.0, "Escribe la contraseña que protegerá a tu cuenta");
			}
		} case 2: {
			if(!g_AccountRegister[id]) {
				dg_color_chat(id, _, "Esta cuenta no está registrada. Registrala para reservar tu nombre en el servidor.");
				showMenu__LogIn(id);
			} else {
				client_cmd(id, "messagemode IDENTIFICAR_CUENTA");
				showDHUDMessage(id, 255, 255, 255, -1.0, -1.0, 0, 5.0, "Ingrese la contraseña que protege esta cuenta^nSi has olvidado tus datos, visita el panel de vinculación para poder recuperarlos^nwww.Drunk-Gaming.com/zp");
			}
		}
	}
}

public clcmd__CreateAccount(const id) {
	if(!g_IsConnected[id] || g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	new sAccount[16];
	read_args(sAccount, charsmax(sAccount));
	remove_quotes(sAccount);
	trim(sAccount);
	
	if(contain(sAccount, " ") != -1)
	{
		g_AccountName[id][0] = EOS;

		showMenu__LogIn(id);

		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "El nombre de tu cuenta no puede contener espacios");
		return PLUGIN_HANDLED;
	}
	else if(!containLetters(sAccount) || countNumbers(sAccount))
	{
		g_AccountName[id][0] = EOS;
		
		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "El nombre de tu cuenta solo puede contener letras");
		return PLUGIN_HANDLED;
	}

	new iLenAccount;
	iLenAccount = strlen(sAccount);
	
	if(iLenAccount < 3)
	{
		g_AccountName[id][0] = EOS;
		
 		showMenu__LogIn(id);
		
		showDHUDMessage(id, 255, 0, 0, -1.0, -1.0, 0, 5.0, "El nombre de tu cuenta debe tener al menos tres caracteres");
		return PLUGIN_HANDLED;
	}

	strtolower(sAccount);
	copy(g_AccountName[id], charsmax(g_AccountName[]), sAccount);

	new iArgs[2];

	iArgs[0] = id;
	iArgs[1] = 0;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT id FROM zp6_accounts WHERE name=^"%s^" LIMIT 1;", g_AccountName[id]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckName", g_SqlQuery, iArgs, sizeof(iArgs));

	return PLUGIN_HANDLED;
}

public showMenu__Join(const id)
{
	static sAccountId[8];
	static sForumId[8];

	addDot(g_AccountId[id], sAccountId, charsmax(sAccountId));
	addDot(g_AccountVinc[id], sForumId, charsmax(sForumId));

	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__Join", PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccountId);
	oldmenu_additem(-1, -1, "\wVINCULADA AL FORO\r:\y %s \d(#%s)^n", ((g_AccountVinc[id]) ? "Si" : "No"), sForumId);

	oldmenu_additem(1, 1, "\r1.\w Entrar a jugar^n");

	if(__PLUGIN_UPDATE[0] && __PLUGIN_UPDATE_VERSION[0])
	{
		oldmenu_additem(-1, -1, "\wEl día \y%s\w se llevará acabo la actualización a la versión \y%s\w.", __PLUGIN_UPDATE, __PLUGIN_UPDATE_VERSION);
		oldmenu_additem(-1, -1, "\wToda la información de la misma estará en nuestro foro.^n");
	}

	oldmenu_display(id);
}

public menu__Join(const id, const item, const value)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id] || g_AccountBanned[id])
		return PLUGIN_HANDLED;
	
	switch(item)
	{
		case 1:
		{
			rg_join_team(id, TEAM_CT);

			if(g_Mode == MODE_MEGA_ARMAGEDDON)
			{
				g_ModeMA_Reward[id] = 2;
				dg_color_chat(id, _, "Cuando comience la segunda fase, renacerás como nemesis. No recibirás recompensa al finalizar el modo");
			}
			else
			{
				if(g_Mode == MODE_INFECTION)
					g_FirstRespawn[id] = 1;

				set_task(1.0, "task__RespawnUser", id + TASK_SPAWN);
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__Game(const id)
{
	if(g_BuyStuff[id])
	{
		dg_color_chat(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite");
		return;
	}

	oldmenu_create("\y%s - %s \r(%s)\y\R%d/2^n\wXP restante\r:\y %s", "menu__Game", PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, (g_MenuData[id][MENU_DATA_GAME] + 1), g_ExpRestHud[id]);

	switch(g_MenuData[id][MENU_DATA_GAME])
	{
		case 0:
		{
			oldmenu_additem(1, 1, "\r1.\w ARMAS");
			oldmenu_additem(2, 2, "\r2.\w ITEMS EXTRAS^n");

			oldmenu_additem(3, 3, "\r3.\w MODELS / DIFICULTADES");
			oldmenu_additem(4, 4, "\r4.\w HABILIDADES");
			oldmenu_additem(5, 5, "\r5.\w LOGROS");
			oldmenu_additem(6, 6, "\r6.\w CLAN^n");

			oldmenu_additem(7, 8, "\r7.\w OPCIONES DE USUARIO");
			oldmenu_additem(8, 8, "\r8.\w ESTADÍSTICAS");
		}
		case 1:
		{
			oldmenu_additem(1, 1, "\r1.\w GORROS");
			oldmenu_additem(2, 2, "\r2.\w AMULETOS^n");

			oldmenu_additem(3, 3, "\r3.\w CABEZAS ZOMBIES");
			oldmenu_additem(4, 4, "\r4.\w VISITAS DIARIAS");
			oldmenu_additem(5, 5, "\r5.\w MULTIPLICADORES");
			if(g_Class[id])
				oldmenu_additem(6, 6, "\r6.\w PETICIÓN DE MODOS^n");
			else
				oldmenu_additem(-1, -1, "");

			oldmenu_additem(-1, -1, "\d7. - - -");
			oldmenu_additem(8, 8, "\r8.\y REGLAS");
		}
	}

	oldmenu_additem(9, 9, "^n\r9.\w Siguiente/Atrás");
	oldmenu_additem(0, 0, "\r0.\w Salir");

	oldmenu_display(id);
}

public menu__Game(const id, const item)
{
	if(g_BuyStuff[id])
	{
		dg_color_chat(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite");
		return PLUGIN_HANDLED;
	}
	else if(item == 0)
		return PLUGIN_HANDLED;

	switch(g_MenuData[id][MENU_DATA_GAME])
	{
		case 0:
		{
			switch(item)
			{
				case 1: showMenu__Weapons(id);
				case 2: showMenu__ExtraItems(id);
				case 3: showMenu__ModelsDifficults(id);
				case 4: showMenu__HabClasses(id);
				case 5: showMenu__AchievementsClasses(id);
				case 6: showMenu__Clan(id);
				case 7: showMenu__UserOptions(id);
				case 8: showMenu__Stats(id);
				case 9:
				{
					g_MenuData[id][MENU_DATA_GAME] = 1;
					showMenu__Game(id);
				}
			}
		}
		case 1:
		{
			switch(item)
			{
				case 1: showMenu__Hats(id);
				case 2: showMenu__Amulets(id);
				case 3: showMenu__HeadZombies(id);
				case 4: showMenu__DailyVisits(id);
				case 5: showMenu__Multipliers(id, g_MenuData[id][MENU_DATA_MULTIPLIER]);
				case 6:
				{
					if(g_Class[id])
						showMenu__PetitionMode(id);
				}
				case 8: showMenu__Rules(id);
				case 9:
				{
					g_MenuData[id][MENU_DATA_GAME] = 0;
					showMenu__Game(id);
				}
			}
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__Weapons(const id)
{
	oldmenu_create("\yARMAS", "menu__Weapons");

	if(!g_Weapons[id][WEAPON_PRIMARY_SELECT] && !g_Weapons[id][WEAPON_SECONDARY_SELECT] && g_CanBuy[id])
		oldmenu_additem(1, 1, "\r1.\w Armas primarias^n");
	else if(g_Weapons[id][WEAPON_PRIMARY_SELECT] && !g_Weapons[id][WEAPON_SECONDARY_SELECT] && g_CanBuy[id])
		oldmenu_additem(1, 1, "\r1.\w Armas secundarias^n");
	else if(g_Weapons[id][WEAPON_PRIMARY_SELECT] && g_Weapons[id][WEAPON_SECONDARY_SELECT] && g_CanBuy[id])
		oldmenu_additem(1, 1, "\r1.\w Granadas^n");
	else if(!g_CanBuy[id])
	{
		oldmenu_additem(1, 1, "\r1.\w Volver a comprar");

		oldmenu_additem(-1, -1, "^n\yNOTA\r:\w Puedes seleccionar tus armas nuevamente para obtenerlos^ncuando renaces como humano^n");
	}
	else
		oldmenu_additem(-1, -1, "\d1. Volver a comprar^n");

	oldmenu_additem(2, 2, "\r2.\w Mis armas^n");

	oldmenu_additem(9, 9, "\r9.\w Recordar compra\r:\y %s", ((g_Weapons[id][WEAPON_AUTO_BUY]) ? "Si" : "No"));
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__Weapons(const id, const item)
{
	switch(item)
	{
		case 1:
		{
			if(!g_Weapons[id][WEAPON_PRIMARY_SELECT] && !g_Weapons[id][WEAPON_SECONDARY_SELECT] && g_CanBuy[id])
				showMenu__BuyPrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_BPW]);
			else if(g_Weapons[id][WEAPON_PRIMARY_SELECT] && !g_Weapons[id][WEAPON_SECONDARY_SELECT] && g_CanBuy[id])
				showMenu__BuySecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_BSW]);
			else if(g_Weapons[id][WEAPON_PRIMARY_SELECT] && g_Weapons[id][WEAPON_SECONDARY_SELECT] && g_CanBuy[id])
			{
				if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id])
				{
					showMenu__Game(id);
					return PLUGIN_HANDLED;
				}

				if(g_VirusT == 2)
					buyGrenades(id);

				g_CanBuy[id] = 0;
				g_Hat_Devil[id] = 1;
			}
			else if(!g_CanBuy[id])
			{
				g_Weapons[id][WEAPON_AUTO_BUY] = 0;
				g_Weapons[id][WEAPON_PRIMARY_SELECT] = 0;
				g_Weapons[id][WEAPON_SECONDARY_SELECT] = 0;

				showMenu__BuyPrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_BPW]);
			}
			else
			{
				dg_color_chat(id, _, "No puedes comprar armas en este momento");
				showMenu__Weapons(id);
			}
		}
		case 2: showMenu__MyWeapons(id, 0, 0);
		case 9:
		{
			g_Weapons[id][WEAPON_AUTO_BUY] = !g_Weapons[id][WEAPON_AUTO_BUY];
			showMenu__Weapons(id);
		}
		case 0: showMenu__Game(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__BuyPrimaryWeapons(const id, page)
{
	g_MenuPage[id][MENU_PAGE_BPW] = page;

	static iMaxPages;
	static iStart;
	static iEnd;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(PRIMARY_WEAPONS));
	oldmenu_create("\yARMAS PRIMARIAS \r[%d - %d]\y\R%d/%d", "menu__BuyPrimaryWeapons", (iStart + 1), iEnd, page, iMaxPages);

	for(new i = iStart, j = 1; i < iEnd; ++i, ++j)
	{
		if(g_Reset[id] > PRIMARY_WEAPONS[i][weaponReset] || (g_Reset[id] == PRIMARY_WEAPONS[i][weaponReset] && g_Level[id] >= PRIMARY_WEAPONS[i][weaponLevel]))
			oldmenu_additem(j, i, "\r%d.\w %s", j, PRIMARY_WEAPONS[i][weaponName]);
		else
			oldmenu_additem(-1, -1, "\r%d.\d %s \r(%d - %c)", j, PRIMARY_WEAPONS[i][weaponName], PRIMARY_WEAPONS[i][weaponLevel], getUserRange(PRIMARY_WEAPONS[i][weaponReset]));
	}

	if(page > 1)
		oldmenu_additem(8, 8, "^n\r8.\w Atrás");
	else
		oldmenu_additem(-1, -1, "^n\d8. Atrás");
	
	if(page < iMaxPages)
		oldmenu_additem(9, 9, "\r9.\w Siguiente");
	else
		oldmenu_additem(-1, -1, "\d9. Siguiente");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id, page);
}

public menu__BuyPrimaryWeapons(const id, const item, const value, page)
{
	switch(item)
	{
		case 8: showMenu__BuyPrimaryWeapons(id, (page - 1));
		case 9: showMenu__BuyPrimaryWeapons(id, (page + 1));
		case 0: showMenu__Weapons(id);
		default:
		{
			if((entity_get_int(id, EV_INT_button) & IN_ATTACK2) && !equal(PRIMARY_WEAPONS[value][weaponName], WEAPON_NAMES[PRIMARY_WEAPONS[value][weaponCSW]]))
			{
				dg_color_chat(id, _, "El arma primaria !g%s!y reemplaza a una !g%s!y", PRIMARY_WEAPONS[value][weaponName], WEAPON_NAMES[PRIMARY_WEAPONS[value][weaponCSW]]);

				showMenu__BuyPrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_BPW]);
				return PLUGIN_HANDLED;
			}

			g_Weapons[id][WEAPON_PRIMARY_SELECT] = value;
			showMenu__BuySecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_BSW]);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__BuySecondaryWeapons(const id, page)
{
	g_MenuPage[id][MENU_PAGE_BSW] = page;

	static iMaxPages;
	static iStart;
	static iEnd;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(SECONDARY_WEAPONS));
	oldmenu_create("\yARMAS SECUNDARIAS \r[%d - %d]\y\R%d/%d", "menu__BuySecondaryWeapons", (iStart + 1), iEnd, page, iMaxPages);

	for(new i = iStart, j = 1; i < iEnd; ++i, ++j)
	{
		if(g_Reset[id] > SECONDARY_WEAPONS[i][weaponReset] || (g_Reset[id] == SECONDARY_WEAPONS[i][weaponReset] && g_Level[id] >= SECONDARY_WEAPONS[i][weaponLevel]))
			oldmenu_additem(j, i, "\r%d.\w %s", j, SECONDARY_WEAPONS[i][weaponName]);
		else
			oldmenu_additem(-1, -1, "\r%d.\d %s \r(%d - %c)", j, SECONDARY_WEAPONS[i][weaponName], SECONDARY_WEAPONS[i][weaponLevel], getUserRange(SECONDARY_WEAPONS[i][weaponReset]));
	}

	if(page > 1)
		oldmenu_additem(8, 8, "^n\r8.\w Atrás");
	else
		oldmenu_additem(-1, -1, "^n\d8. Atrás");

	if(page < iMaxPages)
		oldmenu_additem(9, 9, "\r9.\w Siguiente");
	else
		oldmenu_additem(-1, -1, "\d9. Siguiente");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id, page);
}

public menu__BuySecondaryWeapons(const id, const item, const value, page)
{
	switch(item)
	{
		case 8: showMenu__BuySecondaryWeapons(id, (page - 1));
		case 9: showMenu__BuySecondaryWeapons(id, (page + 1));
		case 0: showMenu__Weapons(id);
		default:
		{
			if((entity_get_int(id, EV_INT_button) & IN_ATTACK2) && !equal(SECONDARY_WEAPONS[value][weaponName], WEAPON_NAMES[SECONDARY_WEAPONS[value][weaponCSW]]))
			{
				dg_color_chat(id, _, "El arma secundaria !g%s!y reemplaza a una !g%s!y", SECONDARY_WEAPONS[value][weaponName], WEAPON_NAMES[SECONDARY_WEAPONS[value][weaponCSW]]);

				showMenu__BuyPrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_BPW]);
				return PLUGIN_HANDLED;
			}

			g_Weapons[id][WEAPON_SECONDARY_SELECT] = value;
			g_Weapons[id][WEAPON_AUTO_BUY] = 1;

			if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] || !g_CanBuy[id] || (g_MiniGame_Weapons && !canUseMiniGames(id)))
				return PLUGIN_HANDLED;

			buyPrimaryWeapons(id, g_Weapons[id][WEAPON_PRIMARY_SELECT]);
			buySecondaryWeapons(id, g_Weapons[id][WEAPON_SECONDARY_SELECT]);

			if(g_VirusT == 2)
				buyGrenades(id);

			g_CanBuy[id] = 0;
			g_Hat_Devil[id] = 1;
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__MyWeapons(const id, const weapon_id, const weapon_data_id)
{
	if(!weapon_id)
	{
		static sItem[64];
		static iMenuId;
		static sPosition[3];

		iMenuId = menu_create("MIS ARMAS\R", "menu__MyWeapons");

		for(new i = 0; i < sizeof(WEAPON_DATA); ++i)
		{
			sPosition[0] = WEAPON_DATA[i][weaponDataId];

			formatex(sItem, charsmax(sItem), "%s \y[Niv. %d]", WEAPON_DATA[i][weaponDataName], g_WeaponData[id][sPosition[0]][WEAPON_DATA_LEVEL]);

			sPosition[1] = i;
			sPosition[2] = 0;

			menu_additem(iMenuId, sItem, sPosition);
		}

		menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
		menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
		menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

		g_MenuPage[id][MENU_PAGE_MY_WEAPONS] = min(g_MenuPage[id][MENU_PAGE_MY_WEAPONS], (menu_pages(iMenuId) - 1));

		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
		ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_MY_WEAPONS]);
	}
	else
	{
		static sTitle[32];
		copy(sTitle, charsmax(sTitle), WEAPON_DATA[weapon_data_id][weaponDataName]);
		strtoupper(sTitle);

		oldmenu_create("\y%s^n\wPuntos disponibles\r:\y %d", "menu__MyWeaponsIn", sTitle, g_WeaponData[id][weapon_id][WEAPON_DATA_POINTS]);

		static sKills[8];
		addDot(g_WeaponData[id][weapon_id][WEAPON_DATA_KILL_DONE], sKills, charsmax(sKills));
		
		if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] != 20)
		{
			static sDmgLvl[32];
			static sDmgLvlOutPut[32];
			static sDmgLvlNeed[32];
			static sDmgLvlNeedOutPut[32];

			formatex(sDmgLvl, charsmax(sDmgLvl), "%0.0f", (g_WeaponData[id][weapon_id][WEAPON_DATA_DAMAGE_DONE] * DIV_NUM_TO_FLOAT));
			addDotSpecial(sDmgLvl, sDmgLvlOutPut, charsmax(sDmgLvlOutPut));

			formatex(sDmgLvlNeed, charsmax(sDmgLvlNeed), "%0.0f", (WEAPON_DAMAGE_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]] * DIV_NUM_TO_FLOAT));
			addDotSpecial(sDmgLvlNeed, sDmgLvlNeedOutPut, charsmax(sDmgLvlNeedOutPut));

			oldmenu_additem(-1, -1, "\wDaño hecho\r:\y %s / %s", sDmgLvlOutPut, sDmgLvlNeedOutPut);
		}

		oldmenu_additem(-1, -1, "\wZombies matados\r:\y %s", sKills);
		
		if(g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_DAYS])
			oldmenu_additem(-1, -1, "\wTiempo jugado con esta arma\r:\y %d día%s y %d hora%s", g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_DAYS], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_DAYS] != 1) ? "s" : ""), g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS] != 1) ? "s" : ""));
		else if(g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS])
			oldmenu_additem(-1, -1, "\wTiempo jugado con esta arma\r:\y %d hora%s y %d minuto%s", g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_HOURS] != 1) ? "s" : ""), g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES] != 1) ? "s" : ""));
		else
			oldmenu_additem(-1, -1, "\wTiempo jugado con esta arma\r:\y %d minuto%s", g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES], ((g_WeaponData[id][weapon_id][WEAPON_DATA_TPD_MINUTES] != 1) ? "s" : ""));
		
		if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] != 20)
		{
			static Float:flLevelPercent;
			flLevelPercent = ((g_WeaponData[id][weapon_id][WEAPON_DATA_DAMAGE_DONE] * 100.0) / WEAPON_DAMAGE_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);

			oldmenu_additem(-1, -1, "\wNivel del arma\r:\y %d (%0.2f%%)^n", g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL], flLevelPercent);
		}
		else
			oldmenu_additem(-1, -1, "\wNivel del arma\r:\y Máximo^n");

		oldmenu_additem(1, WEAPON_SKILL_DAMAGE, "\r1.\w Daño \y[Niv: %d]", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_DAMAGE]);
		oldmenu_additem(2, WEAPON_SKILL_SPEED, "\r2.\w Velocidad de Disparo \y[Niv: %d]", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_SPEED]);
		if(weapon_id != CSW_KNIFE)
		{
			oldmenu_additem(3, WEAPON_SKILL_RECOIL, "\r3.\w Precisión \y[Niv: %d]", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_RECOIL]);
			oldmenu_additem(4, WEAPON_SKILL_MAXCLIP, "\r4.\w Balas \y[Niv: %d]", g_WeaponSkills[id][weapon_id][WEAPON_SKILL_MAXCLIP]);
		}

		if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] != 20)
		{
			if(g_Points[id][POINT_DIAMMONDS] >= WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]])
				oldmenu_additem(5, 5, "^n\r5.\w Subir a nivel %d \y(%d Diamantes)^n", (g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] + 1), WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);
			else
				oldmenu_additem(-1, -1, "^n\d5. Subir a nivel %d \r(%d Diamantes)^n", (g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] + 1), WEAPONS_DIAMMONDS_NEED[weapon_id][g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL]]);
		}
		else
			oldmenu_additem(-1, -1, "");

		g_MenuData[id][MENU_DATA_MY_WEAPON_ID] = weapon_id;
		g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID] = weapon_data_id;

		oldmenu_additem(8, 8, "\r8.\w Estadísticas de esta arma");
		oldmenu_additem(9, 9, "\r9.\w Reiniciar puntos^n");

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__MyWeapons(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_MY_WEAPONS]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__Weapons(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[3];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	showMenu__MyWeapons(id, sPosition[0], sPosition[1]);
	return PLUGIN_HANDLED;
}

public menu__MyWeaponsIn(const id, const item, const value)
{
	static iMyWeaponId;
	static iMyWeaponDataId;

	iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
	iMyWeaponDataId = g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID];

	switch(item)
	{
		case 1..4:
		{
			if(iMyWeaponId == CSW_KNIFE && (value == WEAPON_SKILL_RECOIL || value == WEAPON_SKILL_MAXCLIP))
			{
				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return PLUGIN_HANDLED;
			}

			if(g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS] <= 0)
			{
				dg_color_chat(id, _, "No tienes suficientes puntos");

				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return PLUGIN_HANDLED;
			}

			if((value == WEAPON_SKILL_SPEED && g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED] >= 5) || g_WeaponSkills[id][iMyWeaponId][value] >= 10)
			{
				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return PLUGIN_HANDLED;
			}

			--g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS];
			++g_WeaponSkills[id][iMyWeaponId][value];

			static Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_weapons SET damage_done='%f', kill_done='%d', time_played_done='%d', points='%d', level='%d', skill_damage='%d', skill_speed='%d', skill_recoil='%d', skill_maxclip='%d' WHERE acc_id='%d' AND weapon_id='%d';", g_WeaponData[id][iMyWeaponId][WEAPON_DATA_DAMAGE_DONE], g_WeaponData[id][iMyWeaponId][WEAPON_DATA_KILL_DONE],
			g_WeaponData[id][iMyWeaponId][WEAPON_DATA_TIME_PLAYED_DONE], g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS], g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_DAMAGE], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RECOIL], g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_MAXCLIP], g_AccountId[id], iMyWeaponId);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 12);
			else
				SQL_FreeHandle(sqlQuery);
		}
		case 5:
		{
			showMenu__MyWeaponsConfirmLevel(id);
			return PLUGIN_HANDLED;
		}
		case 8:
		{
			showMenu__MyWeaponsStats(id);
			return PLUGIN_HANDLED;
		}
		case 9:
		{
			static iWeaponPointsTotal;
			iWeaponPointsTotal = (g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_DAMAGE] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RECOIL] + g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_MAXCLIP]);

			if(iWeaponPointsTotal <= 0)
			{
				dg_color_chat(id, _, "No tienes habilidades para reiniciar");

				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return PLUGIN_HANDLED;
			}

			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_DAMAGE] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_SPEED] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_RECOIL] = 0;
			g_WeaponSkills[id][iMyWeaponId][WEAPON_SKILL_MAXCLIP] = 0;

			g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS] += iWeaponPointsTotal;
		}
		case 0:
		{
			showMenu__MyWeapons(id, 0, 0);
			return PLUGIN_HANDLED;
		}
	}

	showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
	return PLUGIN_HANDLED;
}

public showMenu__MyWeaponsConfirmLevel(const id)
{
	static iMyWeaponId;
	iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];

	oldmenu_create("\yCONFIRMACIÓN^n\w¿Estás seguro de que quieras gastar %d Diamantes?", "menu__MyWeaponsConfirmLevel",  WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]]);

	oldmenu_additem(-1, -1, "\wDiamantes\r:\y %d^n", g_Points[id][POINT_DIAMMONDS]);

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

public menu__MyWeaponsConfirmLevel(const id, const item)
{
	static iMyWeaponId;
	static iMyWeaponDataId;

	iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
	iMyWeaponDataId = g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID];

	switch(item)
	{
		case 1:
		{
			if(g_Points[id][POINT_DIAMMONDS] < WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]])
			{
				showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
				return PLUGIN_HANDLED;
			}

			g_Points[id][POINT_DIAMMONDS] -= WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]];
			g_PointsLose[id][POINT_DIAMMONDS] += WEAPONS_DIAMMONDS_NEED[iMyWeaponId][g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]];

			g_WeaponData[id][iMyWeaponId][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
			++g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL];
			++g_WeaponData[id][iMyWeaponId][WEAPON_DATA_POINTS];
			g_WeaponSave[id][iMyWeaponId] = 1;

			if(iMyWeaponId == CSW_KNIFE && g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL] >= 10)
				giveHat(id, HAT_SPARTAN);

			checkWeaponModels(id, iMyWeaponId);
			checkAchievementsWeapons(id, iMyWeaponId);
			
			dg_color_chat(id, _, "Tu !g%s!y subió al !gnivel %d!y", WEAPON_NAMES[iMyWeaponId], g_WeaponData[id][iMyWeaponId][WEAPON_DATA_LEVEL]);
			showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
		}
		case 2: showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
	}

	return PLUGIN_HANDLED;
}

public showMenu__MyWeaponsStats(const id)
{
	static iMyWeaponId;
	static iMyWeaponDataId;

	iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
	iMyWeaponDataId = g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID];

	oldmenu_create("\yESTADÍSTICAS\r:\w %s^n\wEstas estadísticas son acumulativas y no se reinician", "menu__MyWeaponsStats", WEAPON_DATA[iMyWeaponDataId][weaponDataName]);

	static sDmgDone[32];
	static sDmgDoneOutput[32];
	static sKillsDone[8];

	formatex(sDmgDone, charsmax(sDmgDone), "%0.0f", (g_WeaponData[id][iMyWeaponId][WEAPON_DATA_DAMAGE_S_DONE] * DIV_NUM_TO_FLOAT));
	addDotSpecial(sDmgDone, sDmgDoneOutput, charsmax(sDmgDoneOutput));

	addDot(g_WeaponData[id][iMyWeaponId][WEAPON_DATA_KILL_S_DONE], sKillsDone, charsmax(sKillsDone));

	oldmenu_additem(-1, -1, "\wDaño hecho\r:\y %s", sDmgDoneOutput);
	oldmenu_additem(-1, -1, "\wZombies matados\r:\y %s^n", sKillsDone);

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__MyWeaponsStats(const id, const item)
{
	static iMyWeaponId;
	static iMyWeaponDataId;

	iMyWeaponId = g_MenuData[id][MENU_DATA_MY_WEAPON_ID];
	iMyWeaponDataId = g_MenuData[id][MENU_DATA_MY_WEAPON_DATA_ID];

	switch(item)
	{
		case 0: showMenu__MyWeapons(id, iMyWeaponId, iMyWeaponDataId);
	}

	return PLUGIN_HANDLED;
}

public showMenu__ExtraItems(const id)
{
	if(!g_IsAlive[id] || g_SpecialMode[id] || g_NewRound || g_EndRound || (g_Mode != MODE_INFECTION && g_Mode != MODE_PLAGUE) || (g_MiniGame_Weapons && !canUseMiniGames(id)))
	{
		dg_color_chat(id, _, "No puedes comprar equipamiento en estas condiciones");

		showMenu__Game(id);
		return;
	}

	static sItem[64];
	static iMenuId;
	static iCost;
	static sCost[16];
	static sItemInfo[64];
	static sItemPerUser[16];
	static sItemPerMap[16];
	static iValue;
	static sPosition[2];

	iMenuId = menu_create("ITEMS EXTRAS\R", "menu__ExtraItems");

	for(new i = 0; i < structIdExtraItems; ++i)
	{
		if(g_Zombie[id] != EXTRA_ITEMS[i][extraItemTeam])
			continue;

		iCost = getUserExtraItemCost(id, i);
		addDot(iCost, sCost, charsmax(sCost));

		sItemInfo[0] = EOS;
		sItemPerUser[0] = EOS;
		sItemPerMap[0] = EOS;

		if(EXTRA_ITEMS[i][extraItemInfo][0])
			formatex(sItemInfo, charsmax(sItemInfo), " \y(%s)", EXTRA_ITEMS[i][extraItemInfo]);
		
		if(EXTRA_ITEMS[i][extraItemLimitUser])
		{
			iValue = 0;

			switch(i)
			{
				case EXTRA_ITEM_INVISIBILITY: TrieGetCell(g_tExtraItem_Invisibility, g_PlayerName[id], iValue);
				case EXTRA_ITEM_KILL_BOMB: TrieGetCell(g_tExtraItem_KillBomb, g_PlayerName[id], iValue);
				case EXTRA_ITEM_MOLOTOV_BOMB: TrieGetCell(g_tExtraItem_MolotovBomb, g_PlayerName[id], iValue);
				case EXTRA_ITEM_ANTIDOTE_BOMB: TrieGetCell(g_tExtraItem_AntidoteBomb, g_PlayerName[id], iValue);
				case EXTRA_ITEM_ANTIDOTE: TrieGetCell(g_tExtraItem_Antidote, g_PlayerName[id], iValue);
				case EXTRA_ITEM_ZOMBIE_MADNESS: TrieGetCell(g_tExtraItem_ZombieMadness, g_PlayerName[id], iValue);
				case EXTRA_ITEM_INFECTION_BOMB: TrieGetCell(g_tExtraItem_InfectionBomb, g_PlayerName[id], iValue);
				case EXTRA_ITEM_REDUCE_DAMAGE: TrieGetCell(g_tExtraItem_ReduceDamage, g_PlayerName[id], iValue);
				case EXTRA_ITEM_PAINSHOCK: TrieGetCell(g_tExtraItem_PainShock, g_PlayerName[id], iValue);
				case EXTRA_ITEM_PETRIFICATION: TrieGetCell(g_tExtraItem_Petrification, g_PlayerName[id], iValue);
			}

			if(iValue < 0)
				iValue = 0;

			formatex(sItemPerUser, charsmax(sItemPerUser), "\w[%d / %d]", iValue, EXTRA_ITEMS[i][extraItemLimitUser]);
		}

		if(EXTRA_ITEMS[i][extraItemLimitMap])
			formatex(sItemPerMap, charsmax(sItemPerMap), "\w[%d / %d]", g_ExtraItem_LimitMap[i], EXTRA_ITEMS[i][extraItemLimitMap]);

		formatex(sItem, charsmax(sItem), "%s%s%s %s(%s APs) %s%s", ((g_AmmoPacks[id] >= iCost) ? "\w" : "\d"), EXTRA_ITEMS[i][extraItemName], sItemInfo, ((g_AmmoPacks[id] >= iCost) ? "\y" : "\r"), sCost, sItemPerUser, sItemPerMap);

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId);
}

public menu__ExtraItems(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(!g_IsAlive[id] || g_SpecialMode[id] || g_NewRound || g_EndRound || (g_Mode != MODE_INFECTION && g_Mode != MODE_PLAGUE) || (g_MiniGame_Weapons && !canUseMiniGames(id)) || item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[2];
	static iItemId;
	static iCost;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	iCost = getUserExtraItemCost(id, iItemId);

	if(!iCost)
	{
		dg_color_chat(id, _, "Hubo un error al querer comprar un Item Extra (!g%s!y)", EXTRA_ITEMS[iItemId][extraItemName]);

		showMenu__ExtraItems(id);
		return PLUGIN_HANDLED;
	}

	buyExtraItem(id, iItemId);
	return PLUGIN_HANDLED;
}

public showMenu__ModelsDifficults(const id)
{
	oldmenu_create("\yMODELS / DIFICULTADES", "menu__ModelsDifficults");

	oldmenu_additem(1, 1, "\r1.\w Models Humanos");
	oldmenu_additem(2, 2, "\r2.\w Models Zombies^n");

	oldmenu_additem(3, 3, "\r3.\w Dificultad Survivor");
	oldmenu_additem(4, 4, "\r4.\w Dificultad Wesker");
	oldmenu_additem(5, 5, "\r5.\w Dificultad Sniper Elite");
	oldmenu_additem(6, 6, "\r6.\w Dificultad Nemesis");
	oldmenu_additem(7, 7, "\r7.\w Dificultad Assassin");
	oldmenu_additem(8, 8, "\r8.\w Dificultad Aniquilador^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ModelsDifficults(const id, const item, const value)
{
	switch(item)
	{
		case 1..2: showMenu__Models(id, (value - 1));
		case 3..8: showMenu__Difficults(id, (value - 3));
		case 0: showMenu__Game(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__Models(const id, const class)
{
	g_MenuData[id][MENU_DATA_MODEL_CLASS] = class;

	static sItem[64];
	static iMenuId;
	static sPosition[2];

	formatex(sItem, charsmax(sItem), "MODELS %s\R", ((class == MODEL_HUMAN) ? "HUMANOS" : "ZOMBIES"));
	iMenuId = menu_create(sItem, "menu__Models");

	for(new i = 0; i < sizeof(MODELS); ++i)
	{
		if(class != MODELS[i][modelClass])
			continue;

		formatex(sItem, charsmax(sItem), "%s%s %s[Ciclo: %c]%s", ((g_ModelSelected[id][class] == i) ? "\d" : "\w"), MODELS[i][modelName], ((g_ModelSelected[id][class] == i) ? "\r" : "\y"), MODEL_CLASSES_CYCLES[MODELS[i][modelCycle]], ((g_ModelSelected[id][class] == i) ? " \y(ACTUAL)" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_MODELS] = min(g_MenuPage[id][MENU_PAGE_MODELS], (menu_pages(iMenuId) - 1));

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_MODELS]);
}

public menu__Models(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_MODELS]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__ModelsDifficults(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	showMenu__ModelInfo(id, sPosition[0]);
	return PLUGIN_HANDLED;
}

public showMenu__ModelInfo(const id, const model)
{
	static iModelClass;
	iModelClass = g_MenuData[id][MENU_DATA_MODEL_CLASS];

	g_MenuData[id][MENU_DATA_MODEL_ID] = model;

	static sTitle[32];
	copy(sTitle, charsmax(sTitle), MODELS[model][modelName]);
	strtoupper(sTitle);

	oldmenu_create("\y%s - %s", "menu__ModelInfo", sTitle, ((!g_Models[id][model]) ? "\r(NO COMPRADO)" : "\y(COMPRADO)"));

	oldmenu_additem(-1, -1, "\yREQUERIMIENTOS\r:");
	oldmenu_additem(-1, -1, "\r - \w Ciclo %c^n", MODEL_CLASSES_CYCLES[MODELS[model][modelCycle]]);

	if(!g_Models[id][model])
	{
		if(getUserModelInCycle(id, model))
		{
			if(getUserModelInReset(id, iModelClass))
				oldmenu_additem(1, 1, "\r1.\w Comprar model");
			else
				oldmenu_additem(-1, -1, "\d1. Comprar model");
		}
		else
			oldmenu_additem(-1, -1, "\d1. Comprar model");
		oldmenu_additem(2, 2, "\r2.\w Ver model^n");
	}
	else
	{
		oldmenu_additem(-1, -1, "\d1. Comprar model");
		oldmenu_additem(2, 2, "\r2.\w Ver model^n");

		if(getUserModelInCycle(id, model))
			oldmenu_additem(9, 9, "\r9.\w Elegir model");
		else
			oldmenu_additem(-1, -1, "\d9. Elegir model");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ModelInfo(const id, const item)
{
	static iModelClass;
	static iModelId;

	iModelClass = g_MenuData[id][MENU_DATA_MODEL_CLASS];
	iModelId = g_MenuData[id][MENU_DATA_MODEL_ID];

	switch(item)
	{
		case 1:
		{
			if(g_Models[id][iModelId])
			{
				dg_color_chat(id, _, "Ya compraste este model");

				showMenu__ModelInfo(id, iModelId);
				return PLUGIN_HANDLED;
			}
			else if(!getUserModelInCycle(id, iModelId))
			{
				dg_color_chat(id, _, "No puedes elegir este model porque no estás dentro del ciclo requerido");

				showMenu__ModelInfo(id, iModelId);
				return PLUGIN_HANDLED;
			}
			else if(!getUserModelInReset(id, iModelClass))
			{
				dg_color_chat(id, _, "Ya no puedes comprar más models, necesitas subir de rango para seguir obteniendo");

				showMenu__ModelInfo(id, iModelId);
				return PLUGIN_HANDLED;
			}

			g_Models[id][iModelId] = 1;

			dg_color_chat(id, _, "Has comprado el model %s !g%s!y", ((iModelClass == MODEL_HUMAN) ? "humano" : "zombie"), MODELS[iModelId][modelName]);
			showMenu__ModelInfo(id, iModelId);
		}
		case 2:
		{
			// Carga el model en un motd . . .
			{
				static sBuffer[256];
				static iLen;

				iLen = formatex(sBuffer, charsmax(sBuffer), "<html><head><title>Zombie Plague</title></head><body background='#000000'>");
				iLen += formatex(sBuffer[iLen], charsmax(sBuffer) - iLen, "<center><img src='http://drunk-gaming.com/fastdll/zpl/models/%s/%s.jpg' border='1' /></center>", ((iModelClass == MODEL_HUMAN) ? "Humanos" : "Zombies"), MODELS[iModelId][modelPrecache]);
				iLen += formatex(sBuffer[iLen], charsmax(sBuffer) - iLen, "</body></html>");

				show_motd(id, sBuffer, MODELS[iModelId][modelName]);
			}

			showMenu__ModelInfo(id, iModelId);
		}
		case 9:
		{
			if(!getUserModelInCycle(id, iModelId))
			{
				dg_color_chat(id, _, "No puedes elegir este model porque no estás dentro del ciclo requerido");

				showMenu__ModelInfo(id, iModelId);
				return PLUGIN_HANDLED;
			}

			g_ModelSelected[id][iModelClass] = iModelId;

			dg_color_chat(id, _, "Has elegido el model %s !g%s!y", ((iModelClass == MODEL_HUMAN) ? "humano" : "zombie"), MODELS[iModelId][modelName]);
			showMenu__ModelInfo(id, iModelId);
		}
		case 0: showMenu__Models(id, iModelClass);
	}

	return PLUGIN_HANDLED;
}

public showMenu__Difficults(const id, const class)
{
	g_MenuData[id][MENU_DATA_DIFFICULT_CLASS] = class;

	oldmenu_create("\yDIFICULTAD %s", "menu__Difficults", DIFFICULTS_CLASSES[class]);

	for(new i = 0, j = 1; i < structIdDifficults; ++i, ++j)
	{
		if(g_Difficult[id][class] == i)
		{
			oldmenu_additem(-1, -1, "\d%d. %s \y(ELEGIDO)", j, DIFFICULTS[class][i][difficultName]);
			oldmenu_additem(-1, -1, "\r - \w%s^n", DIFFICULTS[class][i][difficultInfo]);
		}
		else
		{
			oldmenu_additem(j, i, "\r%d.\w %s", j, DIFFICULTS[class][i][difficultName]);
			oldmenu_additem(-1, -1, "\r - \w%s^n", DIFFICULTS[class][i][difficultInfo]);
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Difficults(const id, const item, const value)
{
	static iDifficultClass;
	iDifficultClass = g_MenuData[id][MENU_DATA_DIFFICULT_CLASS];

	switch(item)
	{
		case 0: showMenu__ModelsDifficults(id);
		default:
		{
			if(!g_NewRound && !g_EndRound &&
			(g_Mode == MODE_SURVIVOR || g_Mode == MODE_WESKER || g_Mode == MODE_SNIPER_ELITE || g_Mode == MODE_JASON ||
			g_Mode == MODE_NEMESIS || g_Mode == MODE_ASSASSIN || g_Mode == MODE_ANNIHILATOR))
			{
				dg_color_chat(id, _, "No puedes cambiar la dificultad en un modo especial");

				showMenu__Difficults(id, iDifficultClass);
				return PLUGIN_HANDLED;
			}
			else if(value == DIFFICULT_HARD &&
			((iDifficultClass == DIFFICULT_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_PRINCIPIANTE]) ||
			(iDifficultClass == DIFFICULT_CLASS_WESKER && !g_Achievement[id][WESKER_PRINCIPIANTE]) || 
			(iDifficultClass == DIFFICULT_CLASS_SNIPER_ELITE && !g_Achievement[id][SNIPER_ELITE_PRINCIPIANTE]) || 
			(iDifficultClass == DIFFICULT_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_PRINCIPIANTE]) || 
			(iDifficultClass == DIFFICULT_CLASS_ASSASSIN && !g_Achievement[id][ASSASSIN_PRINCIPIANTE]) || 
			(iDifficultClass == DIFFICULT_CLASS_ANNIHILATOR && !g_Achievement[id][ANNIHILATOR_PRINCIPIANTE])))
			{
				dg_color_chat(id, _, "Debes tener el logro !g%s PRINCIPIANTE!y para elegir esta dificultad", DIFFICULTS_CLASSES[iDifficultClass]);

				showMenu__Difficults(id, iDifficultClass);
				return PLUGIN_HANDLED;
			}
			else if(value == DIFFICULT_VERY_HARD &&
			((iDifficultClass == DIFFICULT_CLASS_SURVIVOR && !g_Achievement[id][SURVIVOR_AVANZADO]) ||
			(iDifficultClass == DIFFICULT_CLASS_WESKER && !g_Achievement[id][WESKER_AVANZADO]) || 
			(iDifficultClass == DIFFICULT_CLASS_SNIPER_ELITE && !g_Achievement[id][SNIPER_ELITE_AVANZADO]) || 
			(iDifficultClass == DIFFICULT_CLASS_NEMESIS && !g_Achievement[id][NEMESIS_AVANZADO]) || 
			(iDifficultClass == DIFFICULT_CLASS_ASSASSIN && !g_Achievement[id][ASSASSIN_AVANZADO]) || 
			(iDifficultClass == DIFFICULT_CLASS_ANNIHILATOR && !g_Achievement[id][ANNIHILATOR_AVANZADO])))
			{
				dg_color_chat(id, _, "Debes tener el logro !g%s AVANZADO!y para elegir esta dificultad", DIFFICULTS_CLASSES[iDifficultClass]);

				showMenu__Difficults(id, iDifficultClass);
				return PLUGIN_HANDLED;
			}

			g_Difficult[id][iDifficultClass] = value;

			dg_color_chat(id, _, "La dificultad del !g%s!y ahora es !g%s!y", DIFFICULTS_CLASSES[iDifficultClass], DIFFICULTS[iDifficultClass][value][difficultName]);
			showMenu__Difficults(id, iDifficultClass);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__HabClasses(const id)
{
	static sItem[128];
	static iMenuId;
	static sPosition[2];

	iMenuId = menu_create("HABILIDADES\R", "menu__HabClasses");

	for(new i = 0; i < structIdHabsClasses; ++i)
	{
		formatex(sItem, charsmax(sItem), "\w%s%s", HABS_CLASSES[i][habClassName], ((i == 1 || i == 5 || (i == (structIdHabsClasses - 1))) ? "^n" : ""));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	formatex(sItem, charsmax(sItem), "Cambiar puntos^n^n\yNOTA\r:\w Para comprar recursos, visita la siguiente página^n\y%s\w", PLUGIN_COMMUNITY_FORUM_SHOP);
	menu_additem(iMenuId, sItem, "-");

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_HAB_CLASS] = min(g_MenuPage[id][MENU_PAGE_HAB_CLASS], (menu_pages(iMenuId) - 1));

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_HAB_CLASS]);
}

public menu__HabClasses(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_HAB_CLASS]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	if(sPosition[0] == '-')
		showMenu__HabTrade(id);
	else
		showMenu__Habs(id, sPosition[0]);

	return PLUGIN_HANDLED;
}

public showMenu__HabTrade(const id)
{
	static sMenu[384];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\yCAMBIAR PUNTOS^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Cambiar \y15 pE\w por \y6 pH\w^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Cambiar \y15 pE\w por \y6 pZ\w^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r3.\w Cambiar \y30 pE\w por \y12 pH\w^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r4.\w Cambiar \y30 pE\w por \y12 pZ\w^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r5.\w Cambiar \y50 pE\w por \y6 pL\w^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r6.\w Cambiar \y100 pE\w por \y12 pL\w^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	if(pev_valid(id) != PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);

	show_menu(id, KEYSMENU, sMenu, -1, "Hab Trade Menu");
}

public menu__HabTrade(const id, const key)
{
	switch(key)
	{
		case 0:
		{
			if(g_Points[id][POINT_SPECIAL] >= 15)
			{
				g_Points[id][POINT_SPECIAL] -= 15;
				g_Points[id][POINT_HUMAN] += 6;
			}
		}
		case 1:
		{
			if(g_Points[id][POINT_SPECIAL] >= 15)
			{
				g_Points[id][POINT_SPECIAL] -= 15;
				g_Points[id][POINT_ZOMBIE] += 6;
			}
		}
		case 2:
		{
			if(g_Points[id][POINT_SPECIAL] >= 30)
			{
				g_Points[id][POINT_SPECIAL] -= 30;
				g_Points[id][POINT_HUMAN] += 12;
			}
		}
		case 3:
		{
			if(g_Points[id][POINT_SPECIAL] >= 30)
			{
				g_Points[id][POINT_SPECIAL] -= 30;
				g_Points[id][POINT_ZOMBIE] += 12;
			}
		}
		case 4:
		{
			if(g_Points[id][POINT_SPECIAL] >= 50)
			{
				g_Points[id][POINT_SPECIAL] -= 50;
				g_Points[id][POINT_LEGACY] += 6;
			}
		}
		case 5:
		{
			if(g_Points[id][POINT_SPECIAL] >= 100)
			{
				g_Points[id][POINT_SPECIAL] -= 100;
				g_Points[id][POINT_LEGACY] += 12;
			}
		}
		case 9:
		{
			showMenu__HabClasses(id);
			return PLUGIN_HANDLED;
		}
	}

	showMenu__HabTrade(id);
	return PLUGIN_HANDLED;
}

public showMenu__Habs(const id, const class)
{
	g_MenuData[id][MENU_DATA_HAB_CLASS] = class;

	static sTitle[32];
	copy(sTitle, charsmax(sTitle), HABS_CLASSES[class][habClassName]);
	strtoupper(sTitle);

	oldmenu_create("\y%s^n\w%s\r:\y %d", "menu__Habs", sTitle, HABS_CLASSES[class][habClassPointName], g_Points[id][HABS_CLASSES[class][habClassPointId]]);

	static iHabs;
	static iCost;

	iHabs = 0;
	iCost = 0;

	for(new i = 0, j = 0; i < structIdHabs; ++i)
	{
		if(class != HABS[i][habClass])
			continue;

		++j;

		iHabs = getHabLevel(id, class, i);
		iCost = getHabCost(id, i);

		if(HABS[i][habMaxLevel] != 999)
		{
			if(iHabs >= HABS[i][habMaxLevel])
				oldmenu_additem(j, i, "\r%d.\d %s \r(Niv.full)", j, HABS[i][habName]);
			else
				oldmenu_additem(j, i, "\r%d.\w %s \y(Niv.%d)", j, HABS[i][habName], iHabs);
		}
		else
		{
			if(g_Points[id][HABS_CLASSES[class][habClassPointId]] >= iCost)
				oldmenu_additem(j, i, "\r%d.\w %s \y(Costo: %d)", j, HABS[i][habName], iCost);
			else
				oldmenu_additem(-1, -1, "\d%d. %s \r(Costo: %d)", j, HABS[i][habName], iCost);
		}
	}

	if(class == HAB_CLASS_HUMAN || class == HAB_CLASS_ZOMBIE)
	{
		if(g_Points[id][POINT_SPECIAL] >= MAX_COST_HABS_RESET)
			oldmenu_additem(9, 9, "^n\r9.\w Resetear puntos \y(%d pE)", MAX_COST_HABS_RESET);
		else
			oldmenu_additem(-1, -1, "^n\d9. Resetear puntos \r(%d pE)", MAX_COST_HABS_RESET);
	}
	else
		oldmenu_additem(-1, -1, "");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Habs(const id, const item, const value)
{
	static iHabClass;
	iHabClass = g_MenuData[id][MENU_DATA_HAB_CLASS];

	switch(item)
	{
		case 9: showMenu__HabsReset(id, iHabClass);
		case 0: showMenu__HabClasses(id);
		default:
		{
			if(HABS[value][habMaxLevel] == 999)
			{
				static iCost;
				iCost = getHabCost(id, value);

				if(g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] < iCost)
				{
					dg_color_chat(id, _, "No tienes puntos suficientes");

					showMenu__Habs(id, iHabClass);
					return PLUGIN_HANDLED;
				}

				g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] -= iCost;
				g_PointsLose[id][HABS_CLASSES[iHabClass][habClassPointId]] += iCost;

				++g_Habs[id][value];

				if(value == HAB_D_RESET_EI)
				{
					for(new i = 0; i < structIdExtraItems; ++i)
						g_ExtraItem_Cost[id][i] = EXTRA_ITEMS[i][extraItemCost];

					dg_color_chat(id, _, "El costo de tus ITEMS EXTRAS han vuelto al valor por defecto");
				}

				showMenu__Habs(id, iHabClass);
				return PLUGIN_HANDLED;
			}

			showMenu__HabInfo(id, value);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__HabInfoResetEI(const id, const hab)
{
	g_MenuData[id][MENU_DATA_HAB_ID] = hab;

	static iCost;
	static sMenu[256];
	static iLen;

	iCost = getHabCost(id, hab);

	iLen = formatex(sMenu, charsmax(sMenu), "\yREINICIAR COSTO DE ITEMS EXTRAS^n\w¿Estás seguro de que quieres reiniciar el costo de tus Items?^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wTus diamantes\r:\y %d^n", g_Points[id][POINT_DIAMMONDS]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wCosto\r:\y %d^n^n", iCost);
	
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Si^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w No");

	if(pev_valid(id) != PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);

	show_menu(id, KEYSMENU, sMenu, -1, "Hab Info Reset EI Menu");
}

public menu__HabInfoResetEI(const id, const key)
{
	static iHabClass;
	static iHabId;

	iHabClass = g_MenuData[id][MENU_DATA_HAB_CLASS];
	iHabId = g_MenuData[id][MENU_DATA_HAB_ID];

	switch(key)
	{
		case 0:
		{
			static iCost;
			iCost = getHabCost(id, iHabId);

			if(g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] < iCost)
			{
				dg_color_chat(id, _, "No tienes puntos suficientes");

				showMenu__Habs(id, iHabClass);
				return PLUGIN_HANDLED;
			}
			
			g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] -= iCost;
			g_PointsLose[id][HABS_CLASSES[iHabClass][habClassPointId]] += iCost;

			++g_Habs[id][iHabId];

			if(iHabId == HAB_D_RESET_EI)
			{
				for(new i = 0; i < structIdExtraItems; ++i)
					g_ExtraItem_Cost[id][i] = EXTRA_ITEMS[i][extraItemCost];

				dg_color_chat(id, _, "El costo de tus ITEMS EXTRAS han vuelto al valor por defecto");
			}
			
			showMenu__Habs(id, iHabClass);
		}
		case 1: showMenu__Habs(id, iHabClass);
		default: showMenu__HabInfoResetEI(id, iHabId);
	}

	return PLUGIN_HANDLED;
}

public showMenu__HabsReset(const id, const class)
{
	oldmenu_create("\yRESETEAR PUNTOS", "menu__HabsReset");

	oldmenu_additem(-1, -1, "\w¿Estás seguro que quieres resetear tus %s?^n", HABS_CLASSES[class][habClassPointName]);
	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(0, 0, "\r0.\w No^n");

	oldmenu_additem(-1, -1, "\wCOSTO\r:\y %d pE", MAX_COST_HABS_RESET);
	oldmenu_display(id);
}

public menu__HabsReset(const id, const item)
{
	static iHabClass;
	iHabClass = g_MenuData[id][MENU_DATA_HAB_CLASS];

	switch(item)
	{
		case 1:
		{
			if(iHabClass != HAB_CLASS_HUMAN && iHabClass != HAB_CLASS_ZOMBIE)
			{
				showMenu__Habs(id, g_MenuData[id][MENU_DATA_HAB_CLASS]);
				return PLUGIN_HANDLED;
			}

			if(g_Points[id][POINT_SPECIAL] < MAX_COST_HABS_RESET)
			{
				dg_color_chat(id, _, "No tienes puntos suficientes para resetear las habilidades %s", HABS_CLASSES[iHabClass][habClassName]);

				showMenu__Habs(id, iHabClass);
				return PLUGIN_HANDLED;
			}

			static iHabs;
			iHabs = 0;

			for(new i = 0; i < structIdHabs; ++i)
			{
				if(HABS[i][habClass] == iHabClass && g_Habs[id][i])
				{
					g_Habs[id][i] = 0;
					iHabs = 1;
				}
			}

			if(!iHabs)
			{
				dg_color_chat(id, _, "No tienes habilidades %s para resetear", HABS_CLASSES[iHabClass][habClassName]);

				showMenu__Habs(id, iHabClass);
				return PLUGIN_HANDLED;
			}

			g_Points[id][POINT_SPECIAL] -= MAX_COST_HABS_RESET;

			static iTotal;
			static sTotal[16];

			iTotal = g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] + g_PointsLose[id][HABS_CLASSES[iHabClass][habClassPointId]];
			addDot(iTotal, sTotal, charsmax(sTotal));

			g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] = iTotal;
			g_PointsLose[id][HABS_CLASSES[iHabClass][habClassPointId]] = 0;

			dg_color_chat(id, _, "Tus habilidades %s fueron reiniciadas. Obtuviste !g%s p%c!y", HABS_CLASSES[iHabClass][habClassName], sTotal, ((iHabClass == HAB_CLASS_HUMAN) ? 'H' : 'Z'));
			showMenu__Habs(id, iHabClass);
		}
		case 0: showMenu__Habs(id, iHabClass);
	}

	return PLUGIN_HANDLED;
}

public showMenu__HabInfo(const id, const hab)
{
	g_MenuData[id][MENU_DATA_HAB_ID] = hab;

	static sTitle[32];
	copy(sTitle, charsmax(sTitle), HABS[hab][habName]);
	strtoupper(sTitle);

	static iHabClass;
	iHabClass = g_MenuData[id][MENU_DATA_HAB_CLASS];

	oldmenu_create("\y%s (Niv.%d)^n\w%s\r:\y %d", "menu__HabInfo", sTitle, g_Habs[id][hab], HABS_CLASSES[iHabClass][habClassPointName], g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]]);

	if(g_Habs[id][hab] >= HABS[hab][habMaxLevel])
		oldmenu_additem(-1, -1, "\d1. Nivel máximo^n");
	else
	{
		static iCost;
		iCost = getHabCost(id, hab);

		if(g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] >= iCost)
			oldmenu_additem(1, 1, "\r1.\w Subir habilidad al nivel %d \y[Costo: %d]^n", (g_Habs[id][hab] + 1), iCost);
		else
			oldmenu_additem(-1, -1, "\d1. Subir habilidad al nivel %d \r[Costo: %d]^n", (g_Habs[id][hab] + 1), iCost);
	}

	if(HABS[hab][habDesc][0])
		oldmenu_additem(-1, -1, "\w%s^n", HABS[hab][habDesc]);

	if((iHabClass == HAB_CLASS_HUMAN && (HAB_H_HEALTH <= hab <= HAB_H_ARMOR)) || (iHabClass == HAB_CLASS_ZOMBIE && (HAB_Z_HEALTH <= hab <= HAB_Z_DAMAGE)))
	{
		if((iHabClass == HAB_CLASS_HUMAN && (HAB_H_HEALTH <= hab <= HAB_H_DAMAGE)) || (iHabClass == HAB_CLASS_ZOMBIE && (HAB_Z_HEALTH <= hab <= HAB_Z_DAMAGE)))
		{
			static iClass;
			static iHat;
			static iAmulet;

			getHabLevel(id, iHabClass, hab, iClass, iHat, iAmulet);

			if(g_Class[id] && iClass)
				oldmenu_additem(-1, -1, "\r - \wEXTRA POR CLASE\r:\y +%d", iClass);

			if(g_HatId[id] != HAT_NONE && iHat)
				oldmenu_additem(-1, -1, "\r - \wEXTRA POR GORRO\r:\y +%d", iHat);

			if((g_AmuletCustomCreated[id] || !g_AmuletCustomCreated[id] && g_AmuletEquip[id] != -1) && iAmulet)
				oldmenu_additem(-1, -1, "\r - \wEXTRA POR AMULETO\r:\y +%d", iAmulet);

			oldmenu_additem(-1, -1, "^n\yNOTA #1\r: \wLos puntos de habilidades extras no afectan al costo por nivel de habilidad^n");
		}

		if(iHabClass == HAB_CLASS_HUMAN && (HAB_H_HEALTH <= hab <= HAB_H_ARMOR))
		{
			switch(hab)
			{
				case HAB_H_HEALTH:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %d", humanHealthBase(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%d", humanHealthExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %d^n", humanHealth(id));
				}
				case HAB_H_SPEED:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f", humanSpeedBase(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%0.2f", humanSpeedExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f^n", humanSpeed(id));
				}
				case HAB_H_GRAVITY:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f \d(%d)", humanGravityBase(id), floatround(humanGravityBase(id) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y %0.2f \d(%d)", humanGravityExtra(id), floatround(humanGravityExtra(id) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f \d(%d)^n", humanGravity(id), floatround(humanGravity(id) * 800.0));
				}
				case HAB_H_DAMAGE:
				{
					static iHabs;
					static iVigor;
					static iTotal;

					iHabs = (floatround(humanDamageHabs(id)) * HABS[HAB_H_DAMAGE][habValue]);
					iVigor = 0;

					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.0f%%", humanDamageBase(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%d%%", iHabs);

					if(g_Habs[id][HAB_D_VIGOR])
					{
						iVigor = (g_Habs[id][HAB_D_VIGOR] * HABS[HAB_D_VIGOR][habValue]);
						oldmenu_additem(-1, -1, "\r - \wEXTRA POR VIGOR\r:\y +%d%%", iVigor);
					}

					iTotal = (floatround(humanDamageBase(id)) + (iHabs + iVigor));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %d%%", iTotal);
				}
				case HAB_H_ARMOR:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y 0");
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y %d", humanArmorExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %d^n", humanArmor(id));
				}
			}

			if(hab == HAB_H_DAMAGE)
				oldmenu_additem(-1, -1, "^n\yNOTA #2\r:\w El daño total se suma al daño normal del arma^n");
		}
		else if(iHabClass == HAB_CLASS_ZOMBIE && (HAB_Z_HEALTH <= hab <= HAB_Z_DAMAGE))
		{
			switch(hab)
			{
				case HAB_Z_HEALTH:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %d", zombieHealthBase(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%d", zombieHealthExtra(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA POR JUGADORES\r:\y +%d", (zombieHealth(id) - zombieHealthExtra(id)));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %d^n", zombieHealth(id));
				}
				case HAB_Z_SPEED:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f", zombieSpeedBase(id));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%0.2f", zombieSpeedExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f^n", zombieSpeed(id));
				}
				case HAB_Z_GRAVITY:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y %0.2f \d(%d)", zombieGravityBase(id), floatround(zombieGravityBase(id) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y %0.2f \d(%d)", zombieGravityExtra(id), floatround(zombieGravityExtra(id) * 800.0));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %0.2f \d(%d)^n", zombieGravity(id), floatround(zombieGravity(id) * 800.0));
				}
				case HAB_Z_DAMAGE:
				{
					oldmenu_additem(-1, -1, "\r - \wBASE\r:\y El daño base dependerá de la clase");
					oldmenu_additem(-1, -1, "\r - \wEXTRA\r:\y +%d%%", zombieDamageExtra(id));
					oldmenu_additem(-1, -1, "\r - \wTOTAL\r:\y %d%%^n", zombieDamage(id));
				}
			}
		}
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HabInfo(const id, const item)
{
	static iHabClass;
	static iHabId;

	iHabClass = g_MenuData[id][MENU_DATA_HAB_CLASS];
	iHabId = g_MenuData[id][MENU_DATA_HAB_ID];

	switch(item)
	{
		case 1:
		{
			if(g_Habs[id][iHabId] >= HABS[iHabId][habMaxLevel])
			{
				showMenu__HabInfo(id, iHabId);
				return PLUGIN_HANDLED;
			}

			static iCost;
			iCost = getHabCost(id, iHabId);

			if(g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] < iCost)
			{
				showMenu__HabInfo(id, iHabId);
				return PLUGIN_HANDLED;
			}

			g_Points[id][HABS_CLASSES[iHabClass][habClassPointId]] -= iCost;
			g_PointsLose[id][HABS_CLASSES[iHabClass][habClassPointId]] += iCost;

			++g_Habs[id][iHabId];

			if(iHabClass == HAB_CLASS_HUMAN && iHabClass == HAB_CLASS_ZOMBIE)
			{
				if(iHabId == HAB_Z_INDUCTION)
				{
					if(g_Habs[id][HAB_Z_INDUCTION])
						g_InductionChance[id] = (HABS[HAB_Z_INDUCTION][habValue] * g_Habs[id][HAB_Z_INDUCTION]);
				}

				if(g_Habs[id][HAB_H_SPEED] == HABS[HAB_H_SPEED][habMaxLevel] && g_Habs[id][HAB_H_GRAVITY] == HABS[HAB_H_GRAVITY][habMaxLevel] && g_Habs[id][HAB_Z_SPEED] == HABS[HAB_Z_SPEED][habMaxLevel] && g_Habs[id][HAB_Z_GRAVITY] == HABS[HAB_Z_GRAVITY][habMaxLevel])
					giveHat(id, HAT_SUPER_MAN);
			}
			else if(iHabClass == HAB_CLASS_DIAMMONDS)
			{
				if(iHabId == HAB_D_WEAPONS_LVL10)
				{
					for(new i = 0; i < sizeof(WEAPON_DATA); ++i)
					{
						if(g_WeaponData[id][WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_LEVEL] >= 10)
							continue;

						g_WeaponData[id][WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
						g_WeaponData[id][WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_LEVEL] = 10;
						g_WeaponData[id][WEAPON_DATA[i][weaponDataId]][WEAPON_DATA_POINTS] = 10;
						g_WeaponSave[id][WEAPON_DATA[i][weaponDataId]] = 1;

						checkWeaponModels(id, WEAPON_DATA[i][weaponDataId]);
						checkAchievementsWeapons(id, WEAPON_DATA[i][weaponDataId]);

						for(new j = 0; j < structIdWeaponSkills; ++j)
							g_WeaponSkills[id][WEAPON_DATA[i][weaponDataId]][j] = 0;
					}

					dg_color_chat(id, _, "Has subido todas tus armas al nivel 10");
				}
			}

			dg_color_chat(id, _, "Aumentaste la habilidad !g%s!y al !gnivel %d!y", HABS[iHabId][habName], g_Habs[id][iHabId]);
			showMenu__HabInfo(id, iHabId);
		}
		case 0: showMenu__Habs(id, iHabClass);
	}

	return PLUGIN_HANDLED;
}

public showMenu__AchievementsClasses(const id)
{
	static iMenuId;
	static i;
	static sItem[64];
	static sPosition[2];

	formatex(sItem, charsmax(sItem), "LOGROS^n\wLogros completados en total\r:\y %d\R", g_AchievementTotal[id]);
	iMenuId = menu_create(sItem, "menu__AchievementsClasses");

	for(i = 0; i < structIdAchievementClasses; ++i)
	{
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, ACHIEVEMENTS_CLASSES[i], sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASS] = min(g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASS], (menu_pages(iMenuId) - 1));

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASS]);
}

public menu__AchievementsClasses(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENT_CLASS]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	showMenu__Achievements(id, iItemId);
	return PLUGIN_HANDLED;
}

public showMenu__Achievements(const id, const class)
{
	g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS] = class;

	static sTitle[32];
	static sItem[64];
	static iMenuId;
	static j;
	static k;
	static sPosition[4];

	copy(sTitle, charsmax(sTitle), ACHIEVEMENTS_CLASSES[class]);
	strtoupper(sTitle);

	formatex(sItem, charsmax(sItem), "%s^n\wLogros completados\r:\y %d\R", sTitle, checkAchievementTotal(id, class));
	iMenuId = menu_create(sItem, "menu__Achievements");

	j = 0;
	k = 0;

	for(new i = 0; i < structIdAchievements; ++i)
	{
		if(ACHIEVEMENTS[i][achievementClass] != -1 && class != ACHIEVEMENTS[i][achievementClass])
		{
			++k;
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s%s", ((!g_Achievement[id][i]) ? "\d" : "\w"), ACHIEVEMENTS[i][achievementName], ((!g_Achievement[id][i]) ? " \r(NO COMPLETADO)" : " \y(COMPLETADO)"));

		++j;
		g_AchievementInt[id][i - k] = i;

		num_to_str(j, sPosition, charsmax(sPosition));

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_AchievementPage[id][class] = min(g_AchievementPage[id][class], (menu_pages(iMenuId) - 1));
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_AchievementPage[id][class]);
}

public menu__Achievements(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iNoting;
	player_menu_info(id, iNoting, iNoting, g_AchievementPage[id][g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS]]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__AchievementsClasses(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[5];
	menu_item_getinfo(menu, item, iNoting, sPosition, charsmax(sPosition), _, _, iNoting);
	DestroyLocalMenu(id, menu);

	g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN] = (str_to_num(sPosition) - 1);
	g_LastAchUnlockedPage = g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN];
	g_LastAchUnlockedClass = g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS];

	showMenu__AchievementInfo(id, g_AchievementInt[id][g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN]]);
	return PLUGIN_HANDLED;
}

public showMenu__AchievementInfo(const id, const achievement)
{
	oldmenu_create("\y%s - %s", "menu__AchievementInfo", ACHIEVEMENTS[achievement][achievementName], ((!g_Achievement[id][achievement]) ? "\r(NO COMPLETADO)" : "\y(COMPLETADO)"));

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s", ACHIEVEMENTS[achievement][achievementInfo]);

	if(ACHIEVEMENTS[achievement][achievementUsersNeedP])
	{
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d usuarios conectados", ACHIEVEMENTS[achievement][achievementUsersNeedP]);
	}
	else if(ACHIEVEMENTS[achievement][achievementUsersNeedA])
	{
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d usuarios vivos", ACHIEVEMENTS[achievement][achievementUsersNeedA]);
	}

	oldmenu_additem(-1, -1, "^n\yRECOMPENSA\r:");
	oldmenu_additem(-1, -1, "\r - \w+%d pE", ACHIEVEMENTS[achievement][achievementReward]);

	if(ACHIEVEMENTS[achievement][achievementClass] == ACHIEVEMENT_CLASS_SECRETS)
	{
		switch(achievement)
		{
			case TERRORISTA_1: oldmenu_additem(-1, -1, "^n\yPROGRESO\r:^n\r - \w%0.2f", g_AchievementSecret_Progress[id][0]);
			case HITMAN: oldmenu_additem(-1, -1, "^n\yPROGRESO\r:^n\r - \w%0.2f", g_AchievementSecret_Progress[id][1]);
			case MILLONARIO: oldmenu_additem(-1, -1, "^n\yPROGRESO\r:^n\r - \w%0.2f", g_AchievementSecret_Progress[id][2]);
			case EL_TERROR_EXISTE: oldmenu_additem(-1, -1, "^n\yPROGRESO\r:^n\r - \w%0.2f", g_AchievementSecret_Progress[id][3]);
			case RESISTENCIA: oldmenu_additem(-1, -1, "^n\yPROGRESO\r:^n\r - \w%0.2f", g_AchievementSecret_Progress[id][4]);
			case ALBERT_WESKER: oldmenu_additem(-1, -1, "^n\yPROGRESO\r:^n\r - \w%0.2f", g_AchievementSecret_Progress[id][5]);
		}
	}

	if(g_Achievement[0][achievement])
	{
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_AchievementUnlocked[0][achievement], 1));
		oldmenu_additem(-1, -1, "\r - \wPor el usuario\r:\y %s^n", g_AchievementName[0][achievement]);
	}
	else if(g_Achievement[id][achievement])
	{
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_AchievementUnlocked[id][achievement], 1));

		oldmenu_additem(1, 1, "^n\r1.\w Mostrar logro en el Chat");
	}
	else
		oldmenu_additem(-1, -1, "^n\d1. Mostrar logro en el Chat");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__AchievementInfo(const id, const item)
{
	static iAchievementClass;
	static iAchievementId;

	iAchievementClass = g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS];
	iAchievementId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_IN];

	switch(item)
	{
		case 1:
		{
			if(g_Achievement[id][g_AchievementInt[id][iAchievementId]])
			{
				if(g_AccountId[id] == 1 || g_AchievementTimeLink[id] < get_gametime())
				{
					g_AchievementTimeLink[id] = get_gametime() + 15.0;
					dg_color_chat(0, _, "!t%s!y muestra su logro !g%s !t[Z]!y conseguido el !g%s!y", g_PlayerName[id], ACHIEVEMENTS[g_AchievementInt[id][iAchievementId]][achievementName], getUnixToTime(g_AchievementUnlocked[id][g_AchievementInt[id][iAchievementId]], 1));

					g_LastAchUnlockedPage = iAchievementId;
					g_LastAchUnlockedClass = iAchievementClass;
					g_LastAchUnlocked = g_AchievementInt[id][iAchievementId];
				}
			}

			showMenu__AchievementInfo(id, g_AchievementInt[id][iAchievementId]);
		}
		case 0: showMenu__Achievements(id, iAchievementClass);
	}

	return PLUGIN_HANDLED;
}

public showMenu__Clan(const id)
{
	static sMenu[350];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\yCLAN^n^n");

	if(g_ClanSlot[id])
	{
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wNombre del clan\r:\y %s^n", g_Clan[g_ClanSlot[id]][clanName]);
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wRanking del clan\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanRank]);
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wDepósito\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanDeposit]);
		if(g_Clan[g_ClanSlot[id]][clanChampion])
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wTu clan es el \yACTUAL\w campeón semanal^n");

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r1.\w Ver miembros conectados \y(%d / %d)^n", g_Clan[g_ClanSlot[id]][clanCountOnlineMembers], g_Clan[g_ClanSlot[id]][clanCountMembers]);
		if(getClanMemberRange(id))
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Invitar usuarios^n^n");
		else
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\d2. Invitar usuarios^n^n");

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r3.\w Ventajas del Clan^n^n");

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r4.\w Información del Clan^n^n");
	}
	else
	{
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Crear Clan^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Invitaciones a Clanes\r:\y %d^n^n", g_ClanInvitations[id]);
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "1 Clan Menu");
}

public menu__Clan(const id, const key)
{
	switch(key)
	{
		case 0: // Ver miembros conectados / Crear Clan
		{
			if(g_ClanSlot[id])
				showMenu__ClanOnlineMembers(id);
			else
			{
				dg_color_chat(id, _, "Escribe el nombre de tu clan, se aceptan hasta 14 caracteres");
				client_cmd(id, "messagemode CREAR_CLAN");
			}
		}
		case 1: // Invitar usuario / Invitaciones a Clanes
		{
			if(g_ClanSlot[id])
			{
				if(getClanMemberRange(id))
					showMenu__ClanInviteUsers(id);
				else
				{
					dg_color_chat(id, _, "Solo los miembros con rango !gDueño!y del Clan pueden invitar usuarios");
					showMenu__Clan(id);
				}
			}
			else if(g_ClanInvitations[id])
				showMenu__ClanInvitations(id);
			else
				showMenu__Clan(id);
		}
		case 2:
		{
			if(g_ClanSlot[id])
				showMenu__ClanPerks(id);
			else
				showMenu__Clan(id);
		}
		case 3: // Información del Clan
		{
			if(g_ClanSlot[id])
				showMenu__ClanInfo(id);
			else
				showMenu__Clan(id);
		}
		case 9: showMenu__Game(id);
		default: showMenu__Clan(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanInviteUsers(const id)
{
	static sItem[64];
	static iMenuId;
	static sPosition[2];
	
	iMenuId = menu_create("INVITAR USUARIOS AL CLAN\R", "menu__ClanInviteUsers");
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i])
			continue;
		
		if(id == i)
			continue;
		
		if(g_ClanSlot[i])
			continue;
		
		if(g_ClanInvitationsId[i][id])
			continue;
		
		formatex(sItem, charsmax(sItem), "%s \y(%c - %d)", g_PlayerName[i], getUserRange(g_Reset[i]), g_Level[i]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1)
	{
		DestroyLocalMenu(id, iMenuId);
		
		dg_color_chat(id, _, "No hay usuarios disponibles para mostrar en el menú");
		
		showMenu__Clan(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	g_MenuPage[id][MENU_PAGE_CLAN_INVITE] = min(g_MenuPage[id][MENU_PAGE_CLAN_INVITE], (menu_pages(iMenuId) - 1));
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__ClanInviteUsers(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_CLAN_INVITE]);
	
	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	static sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);
	
	iItemId = sPosition[0];
	
	if(g_IsConnected[iItemId])
	{
		if(!g_ClanSlot[iItemId])
		{
			dg_color_chat(id, _, "Enviaste una invitación a !t%s!y para que se una a tu clan!", g_PlayerName[iItemId]);
			dg_color_chat(iItemId, _, "El usuario !t%s!y te invitó al clan !g%s!y!", g_PlayerName[id], g_Clan[g_ClanSlot[id]][clanName]);
			
			++g_ClanInvitations[iItemId];
			g_ClanInvitationsId[iItemId][id] = 1;
		}
		else
			dg_color_chat(id, _, "El usuario seleccionado acaba de entrar en un clan");
	}
	else
		dg_color_chat(id, _, "El usuario seleccionado se ha desconectado");
	
	showMenu__ClanInviteUsers(id);
	return PLUGIN_HANDLED;
}

public showMenu__ClanInfo(const id)
{
	static sMenu[350];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\y%s^n^n", g_Clan[g_ClanSlot[id]][clanName]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wCreado el\r:\y %s^n", getUnixToTime(g_Clan[g_ClanSlot[id]][clanSince], 1));
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wZombies matados en el Clan\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanKillDone]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wHumanos infectados en el Clan\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanInfectDone]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVictorias\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanVictory]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVictorias consecutivas\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanVictoryConsec]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVictorias consecutivas en la historia\r:\y %d^n^n", g_Clan[g_ClanSlot[id]][clanVictoryConsecHistory]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "3 Clan Menu");
}

public menu__ClanInfo(const id, const key)
{
	switch(key)
	{
		case 9: showMenu__Clan(id);
		default: showMenu__ClanInfo(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanOnlineMembers(const id)
{
	static sItem[128];
	static iMenuId;
	static sPosition[2];
	static k;
	
	formatex(sItem, charsmax(sItem), "VER MIEMBROS CONECTADOS (%d / %d)^n\wAl seleccionar uno, verás la información del jugador\y\R", g_Clan[g_ClanSlot[id]][clanCountMembers], MAX_CLAN_MEMBERS);
	iMenuId = menu_create(sItem, "menu__ClanOnlineMembers");
	
	for(new i = 0; i < MAX_CLAN_MEMBERS; ++i)
	{
		if(!g_ClanMembers[g_ClanSlot[id]][i][clanMemberId])
			continue;
		
		sPosition[0] = i;
		sPosition[1] = 0;
		k = 0;
		
		for(new j = 1; j <= g_MaxPlayers; ++j)
		{
			if(g_IsConnected[j])
			{
				if(g_AccountId[j] == g_ClanMembers[g_ClanSlot[id]][i][clanMemberId])
				{
					menu_additem(iMenuId, g_ClanMembers[g_ClanSlot[id]][i][clanMemberName], sPosition);
					
					k = 1;
					break;
				}
			}
		}
		
		if(!k)
		{
			formatex(sItem, charsmax(sItem), "\d%s", g_ClanMembers[g_ClanSlot[id]][i][clanMemberName]);
			menu_additem(iMenuId, sItem, sPosition);
		}
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__ClanOnlineMembers(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	static sPosition[2];
	static iItemId;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	
	if(g_ClanMembers[g_ClanSlot[id]][iItemId][clanMemberId])
		showMenu__ClanMemberInfo(id, iItemId);
	else
	{
		dg_color_chat(id, _, "El usuario seleccionado se acaba de ir del clan");
		showMenu__ClanOnlineMembers(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanMemberInfo(const id, const member)
{
	if(!g_ClanSlot[id])
		return;

	g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID] = member;
	
	static sMenu[512];
	static iLen;
	static iOk;
	static iMemberRange;

	iLen = formatex(sMenu, charsmax(sMenu), "\y%s - %s^n^n", g_ClanMembers[g_ClanSlot[id]][member][clanMemberName], ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberOwner]) ? "Dueño" : "Miembro"));

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wRango\r:\y %c \r- \wNivel\r:\y %d^n", getUserRange(g_ClanMembers[g_ClanSlot[id]][member][clanMemberReset]), g_ClanMembers[g_ClanSlot[id]][member][clanMemberLevel]);
	if(g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay] || g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour] || g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeMinute])
	{
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wÚltima vez visto hace\r:\y %d %s^n", ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay] :
		((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour] : g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeMinute])), ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? "días" : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? "horas" : "minutos")));
	}
	else
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wÚltima vez visto hace\r:\y Conectado^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wMiembro desde hace\r:\y %d %s^n^n", ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay] :
	((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour] : g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceMinute])), ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay]) ? "días" : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour]) ? "horas" : "minutos")));

	iOk = 0;
	iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][member][clanMemberName]);

	if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][member][clanMemberId])
		iOk = 0;
	else
	{
		if(getClanMemberRange(id))
			iOk = 1;
	}

	if(iOk && getClanMemberRange(iMemberRange))
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r3.\w Degradar a \yMiembro^n");
	else
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\d3. Degradar a \rMiembro^n");

	if(iOk && !getClanMemberRange(iMemberRange))
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r4.\w Promover a \yDueño^n^n");
	else
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\d4. Promover a \rDueño^n^n");

	if(iOk)
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r7.\w Expulsar miembro");
	else
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\d7. Expulsar miembro");

	if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][member][clanMemberId])
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r8.\w Abandonar Clan");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n^n\r0.\w Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "2 Clan Menu");
}

public menu__ClanMemberInfo(const id, const key)
{
	static iMemberId;
	iMemberId = g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID];

	switch(key)
	{
		case 2:
		{
			static iMemberRange;
			iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);

			if(getClanMemberRange(id) && getClanMemberRange(iMemberRange) && g_AccountId[id] != g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId])
			{
				static Float:flGameTime;
				flGameTime = get_gametime();

				if(g_Clan_QueryFlood[id] > flGameTime)
				{
					dg_color_chat(id, _, "Espera unos segundos antes de volver a modificar los rangos");

					showMenu__ClanMemberInfo(id, iMemberId);
					return PLUGIN_HANDLED;
				}

				g_Clan_QueryFlood[id] = (flGameTime + 5.0);

				static iArgs[3];
				
				iArgs[0] = id;
				iArgs[1] = 0;
				iArgs[2] = iMemberId;
				
				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_clans_members SET owner='0' WHERE clan_id='%d' AND acc_id='%d' AND active='1';", g_Clan[g_ClanSlot[id]][clanId], g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__Updates", g_SqlQuery, iArgs, sizeof(iArgs));
			}
			else
				showMenu__ClanMemberInfo(id, iMemberId);
		}
		case 3:
		{
			static iMemberRange;
			iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);

			if(getClanMemberRange(id) && !getClanMemberRange(iMemberRange) && g_AccountId[id] != g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId])
			{
				static Float:flGameTime;
				flGameTime = get_gametime();

				if(g_Clan_QueryFlood[id] > flGameTime)
				{
					dg_color_chat(id, _, "Espera unos segundos antes de volver a modificar los rangos");

					showMenu__ClanMemberInfo(id, iMemberId);
					return PLUGIN_HANDLED;
				}

				g_Clan_QueryFlood[id] = (flGameTime + 5.0);
				
				static iArgs[3];
				
				iArgs[0] = id;
				iArgs[1] = 1;
				iArgs[2] = iMemberId;
				
				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_clans_members SET owner='1' WHERE clan_id='%d' AND acc_id='%d' AND active='1';", g_Clan[g_ClanSlot[id]][clanId], g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__Updates", g_SqlQuery, iArgs, sizeof(iArgs));
			}
			else
				showMenu__ClanMemberInfo(id, iMemberId);
		}
		case 6:
		{
			if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId])
			{
				dg_color_chat(id, _, "No te podés expulsar vos mismo del clan");
				showMenu__ClanMemberInfo(id, iMemberId);
			}
			else if(!getClanMemberRange(id))
			{
				dg_color_chat(id, _, "No tenés el rango suficiente como para expulsar miembros del clan");
				showMenu__ClanMemberInfo(id, iMemberId);
			}
			else
				showMenu__ClanRemoveMember(id, iMemberId);
		}
		case 7:
		{
			if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId])
				showMenu__ClanQuit(id);
			else
				showMenu__ClanMemberInfo(id, iMemberId);
		}
		case 9: showMenu__ClanOnlineMembers(id);
		default: showMenu__ClanMemberInfo(id, iMemberId);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanRemoveMember(const id, const member)
{
	oldmenu_create("\yEXPULSAR MIEMBRO^n\w¿Estás seguro de expulsar a \y%s\w del clan?", "menu__ClanRemoveMember", g_ClanMembers[g_ClanSlot[id]][member][clanMemberName]);

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

public menu__ClanRemoveMember(const id, const item)
{
	if(!g_ClanSlot[id])
		return PLUGIN_HANDLED;

	static iMemberId;
	iMemberId = g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID];

	switch(item)
	{
		case 1:
		{
			static Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_clans_members SET active='0' WHERE clan_id='%d' AND acc_id='%d' AND active='1';", g_Clan[g_ClanSlot[id]][clanId], g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);
			
			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 14);
			else
			{
				SQL_FreeHandle(sqlQuery);
				
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_pjs SET clan_id='0' WHERE acc_id='%d';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);
				
				if(!SQL_Execute(sqlQuery))
					executeQuery(id, sqlQuery, 15);
				else
				{
					SQL_FreeHandle(sqlQuery);

					--g_Clan[g_ClanSlot[id]][clanCountMembers];

					static j;
					j = 0;
					
					for(new i = 1; i <= g_MaxPlayers; ++i)
					{
						if(!g_IsConnected[i])
							continue;
						
						if(g_ClanSlot[id] != g_ClanSlot[i])
							continue;
						
						dg_color_chat(i, _, "!t%s!y ha sido expulsado del clan", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);
						
						if(id == i)
							continue;
						
						if(!j)
						{
							if(g_AccountId[i] == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId])
							{
								if(!g_Zombie[i] && g_ClanCombo[g_ClanSlot[id]])
								{
									sendClanMessage(id, "Un miembro humano fue expulsado del Clan y el combo ha finalizado");
									clanFinishCombo(id);
								}

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
		}
		case 2: showMenu__ClanMemberInfo(id, iMemberId);
	}

	return PLUGIN_HANDLED;
}

public showMenu__ClanQuit(const id)
{
	oldmenu_create("\yABANDONAR CLAN^n\w¿Estás seguro de abandonar el clan?", "menu__CLanQuit");

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

public menu__CLanQuit(const id, const item)
{
	if(!g_ClanSlot[id])
		return;

	static iMemberId;
	iMemberId = g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID];

	switch(item)
	{
		case 1:
		{
			static Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_clans_members SET active='0' WHERE clan_id='%d' AND acc_id='%d' AND active='1';", g_Clan[g_ClanSlot[id]][clanId], g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 16);
			else
			{
				SQL_FreeHandle(sqlQuery);

				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_pjs SET clan_id='0' WHERE acc_id='%d';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);

				if(!SQL_Execute(sqlQuery))
					executeQuery(id, sqlQuery, 17);
				else
				{
					SQL_FreeHandle(sqlQuery);

					--g_Clan[g_ClanSlot[id]][clanCountMembers];

					for(new i = 1; i <= g_MaxPlayers; ++i)
					{
						if(!g_IsConnected[i])
							continue;
						
						if(g_ClanSlot[id] != g_ClanSlot[i])
							continue;

						if(id == i)
						{
							dg_color_chat(i, _, "Has abandonado el clan");
							continue;
						}

						sendClanMessage(id, "!t%s!y ha abandonado el clan", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);
						break;
					}

					if(!g_Zombie[id] && g_ClanCombo[g_ClanSlot[id]])
					{
						sendClanMessage(id, "Un miembro humano abandonó el clan y el combo ha finalizado");
						clanFinishCombo(id);
					}

					g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId] = 0;

					--g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

					g_ClanSlot[id] = 0;
				}
			}

			showMenu__ClanOnlineMembers(id);
		}
		case 2: showMenu__ClanMemberInfo(id, iMemberId);
	}
}

public showMenu__ClanInvitations(const id)
{
	static sItem[64];
	static iMenuId;
	static sPosition[2];
	
	iMenuId = menu_create("INVITACIONES A CLANES^n\wTe enviaron solicitud\r:\R", "menu__ClanInvitations");
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i] || !g_ClanInvitationsId[id][i])
			continue;
		
		formatex(sItem, charsmax(sItem), "%s \r-\y %s", g_PlayerName[i], g_Clan[g_ClanSlot[i]][clanName]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1)
	{
		DestroyLocalMenu(id, iMenuId);

		dg_color_chat(id, _, "No tenés solicitudes a clanes");
		
		showMenu__Clan(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__ClanInvitations(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	static sPosition[2];
	static iItemId;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);
	
	iItemId = sPosition[0];
	
	if(g_IsConnected[iItemId])
	{
		if(g_ClanSlot[iItemId])
		{
			if(g_Clan[g_ClanSlot[iItemId]][clanCountMembers] < MAX_CLAN_MEMBERS)
			{
				if(g_ClanInvitationsId[id][iItemId])
				{
					static Handle:sqlQuery;
					sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_clans_members (clan_id, acc_id, owner, since, last_connection) VALUES ('%d', '%d', '0', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());", g_Clan[g_ClanSlot[iItemId]][clanId], g_AccountId[id]);
					
					if(!SQL_Execute(sqlQuery))
						executeQuery(id, sqlQuery, 18);
					else
					{
						SQL_FreeHandle(sqlQuery);
						
						sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_pjs SET clan_id='%d' WHERE acc_id='%d';", g_Clan[g_ClanSlot[iItemId]][clanId], g_AccountId[id]);
						
						if(!SQL_Execute(sqlQuery))
							executeQuery(id, sqlQuery, 19);
						else
						{
							SQL_FreeHandle(sqlQuery);
							
							g_ClanSlot[id] = g_ClanSlot[iItemId];
							
							++g_Clan[g_ClanSlot[id]][clanCountMembers];
							++g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

							static iClanSlotId;
							iClanSlotId = getClanMemberEmptySlot(id);
							
							if(iClanSlotId >= 0)
							{
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberId] = g_AccountId[id];
								copy(g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberName], 31, g_PlayerName[id]);
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberOwner] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceDay] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceHour] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceMinute] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeDay] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeHour] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeMinute] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLevel] = g_Level[id];
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberReset] = g_Reset[id];
							}

							--g_ClanInvitations[iItemId];
							g_ClanInvitations[id] = 0;

							g_ClanInvitationsId[id][iItemId] = 0;
							
							for(new i = 1; i <= g_MaxPlayers; ++i)
							{
								if(g_ClanSlot[id] == g_ClanSlot[i])
								{
									if(id == i)
										dg_color_chat(i, _, "Te uniste al clan !g%s!y", g_Clan[g_ClanSlot[id]][clanName]);
									else
										dg_color_chat(i, _, "!t%s!y se unió al Clan", g_PlayerName[id]);
								}
							}

							if(!g_Zombie[id] && g_ClanCombo[g_ClanSlot[id]])
							{
								sendClanMessage(id, "Un miembro humano ingresó al Clan y el combo ha finalizado");
								clanFinishCombo(id);
							}
							
							showMenu__Clan(id);
						}
					}
				}
				else
				{
					dg_color_chat(id, _, "La invitación al clan ha expirado");
					
					--g_ClanInvitations[id];
					g_ClanInvitationsId[id][iItemId] = 0;
				}
			}
			else
			{
				dg_color_chat(id, _, "El clan está lleno");
				
				--g_ClanInvitations[id];
				g_ClanInvitationsId[id][iItemId] = 0;
			}
		}
		else
		{
			dg_color_chat(id, _, "El usuario no está en un clan");
			
			--g_ClanInvitations[id];
			g_ClanInvitationsId[id][iItemId] = 0;
		}
	}
	else
	{
		dg_color_chat(id, _, "El usuario seleccionado se ha desconectado");
		
		--g_ClanInvitations[id];
		g_ClanInvitationsId[id][iItemId] = 0;
	}
	
	if(g_ClanInvitations[id] && !g_ClanSlot[id])
		showMenu__ClanInvitations(id);
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanPerks(const id)
{
	if(!g_ClanSlot[id])
		return;

	static sMenu[350];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\yVENTAJAS DEL CLAN^n\wDepósito\r:\y %d^n^n", g_Clan[g_ClanSlot[id]][clanDeposit]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Depositar puntos^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Ventajas \y(%d / %d)^n^n", getClanPerks(id), structIdClanPerks);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "4 Clan Menu");
}

public menu__ClanPerks(const id, const key)
{
	if(!g_ClanSlot[id])
		return PLUGIN_HANDLED;

	switch(key)
	{
		case 0: showMenu__ClanDeposit(id);
		case 1: showMenu__ClanShowPerks(id);
		case 9: showMenu__Clan(id);
		default: showMenu__ClanPerks(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanDeposit(const id)
{
	if(!g_ClanSlot[id])
		return;

	static sMenu[350];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\yDEPOSITAR PUNTOS^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wDepósito\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanDeposit]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wTus puntos especiales\r:\y %d^n^n", g_Points[id][POINT_SPECIAL]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Reducir cantidad a depositar^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Aumentar cantidad a depositar^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r9.\w Depositar \y%d pE\w^n", g_TempClanDeposit[id]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "5 Clan Menu");
}

public menu__ClanDeposit(const id, const key)
{
	if(!g_ClanSlot[id])
		return PLUGIN_HANDLED;

	switch(key)
	{
		case 0:
		{
			g_TempClanDeposit[id] -= 5;

			if(g_TempClanDeposit[id] < 0)
				g_TempClanDeposit[id] = 0;

			showMenu__ClanDeposit(id);
		}
		case 1:
		{
			g_TempClanDeposit[id] += 5;

			if(g_TempClanDeposit[id] > 2000)
				g_TempClanDeposit[id] = 2000;

			showMenu__ClanDeposit(id);
		}
		case 8:
		{
			if(!g_TempClanDeposit[id])
			{
				dg_color_chat(id, _, "No puedes depositar 0 pE");

				showMenu__ClanDeposit(id);
				return PLUGIN_HANDLED;
			}

			if(getClanPerks(id) == structIdClanPerks)
			{
				dg_color_chat(id, _, "No puedes depositar porque han comprado todas las ventajas del Clan");

				showMenu__ClanDeposit(id);
				return PLUGIN_HANDLED;
			}

			if(g_Points[id][POINT_SPECIAL] >= g_TempClanDeposit[id])
			{
				sendClanMessage(id, "!t%s!y depositó !g%d pE!y al Clan", g_PlayerName[id], g_TempClanDeposit[id]);

				g_Points[id][POINT_SPECIAL] -= g_TempClanDeposit[id];
				g_Clan[g_ClanSlot[id]][clanDeposit] += g_TempClanDeposit[id];

				g_TempClanDeposit[id] = 0;

				static Handle:sqlQuery;
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_clans SET deposit='%d' WHERE id='%d';", g_Clan[g_ClanSlot[id]][clanDeposit], g_Clan[g_ClanSlot[id]][clanId]);
				
				if(!SQL_Execute(sqlQuery))
					executeQuery(id, sqlQuery, 20);
				else
					SQL_FreeHandle(sqlQuery);
			}
			else
				dg_color_chat(id, _, "No tenés los pE indicados para depositar");

			showMenu__ClanDeposit(id);
		}
		case 9: showMenu__ClanPerks(id);
		default: showMenu__ClanDeposit(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__ClanShowPerks(const id)
{
	if(!g_ClanSlot[id])
		return;

	static sItem[128];
	static iMenuId;
	static sPosition[2];

	formatex(sItem, charsmax(sItem), "VENTAJAS (%d / %d)^n\wAl seleccionar una, verás la información de la misma\y\R", getClanPerks(id), structIdClanPerks);
	iMenuId = menu_create(sItem, "menu__ClanShowPerks");

	for(new i = 0; i < structIdClanPerks; ++i)
	{
		formatex(sItem, charsmax(sItem), "%s%s", ((g_ClanPerks[g_ClanSlot[id]][i]) ? "\w" : "\d"), CLAN_PERKS[i][clanPerkName]);
		
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_CLAN_PERKS] = min(g_MenuPage[id][MENU_PAGE_CLAN_PERKS], menu_pages(iMenuId) - 1);

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_CLAN_PERKS]);
}

public menu__ClanShowPerks(const id, const menu, const item)
{
	if(!g_IsConnected[id] || !g_ClanSlot[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iMenuDummy;
	player_menu_info(id, iMenuDummy, iMenuDummy, g_MenuPage[id][MENU_PAGE_CLAN_PERKS]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__ClanPerks(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[2];
	static iDummy;

	menu_item_getinfo(menu, item, iDummy, sPosition, charsmax(sPosition), _, _, iDummy);
	DestroyLocalMenu(id, menu);

	g_MenuData[id][MENU_DATA_CLAN_PERK_ID] = sPosition[0];

	showMenu__ClanShowPerkInfo(id, g_MenuData[id][MENU_DATA_CLAN_PERK_ID]);
	return PLUGIN_HANDLED;
}

public showMenu__ClanShowPerkInfo(const id, const perk_id)
{
	if(!g_ClanSlot[id])
		return;

	static sMenu[750];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\y%s - %s^n", CLAN_PERKS[perk_id][clanPerkName], ((g_ClanPerks[g_ClanSlot[id]][perk_id]) ? "\y(ADQUIRIDO)" : "\r(NO ADQUIRIDO)"));

	if(!g_ClanPerks[g_ClanSlot[id]][perk_id])
	{
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\wDepósito\r:\y %d^n^n", g_Clan[g_ClanSlot[id]][clanDeposit]);
		
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yDESCRIPCIÓN\r:^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r - \w%s^n^n", CLAN_PERKS[perk_id][clanPerkDesc]);

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yCOSTO\r:^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r - \w +%d^n^n", CLAN_PERKS[perk_id][clanPerkCost]);

		if(g_Clan[g_ClanSlot[id]][clanDeposit] >= CLAN_PERKS[perk_id][clanPerkCost])
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Comprar ventaja^n");
		else
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\d1. Comprar ventaja^n");
	}
	else
	{
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\yDESCRIPCIÓN\r:^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r - \w%s^n^n", CLAN_PERKS[perk_id][clanPerkDesc]);
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "6 Clan Menu");
}

public menu__ClanShowPerkInfo(const id, const key)
{
	if(!g_ClanSlot[id])
		return PLUGIN_HANDLED;

	static iPerkId;
	iPerkId = g_MenuData[id][MENU_DATA_CLAN_PERK_ID];

	switch(key)
	{
		case 0:
		{
			if(g_ClanPerks[g_ClanSlot[id]][iPerkId])
			{
				showMenu__ClanShowPerkInfo(id, iPerkId);
				return PLUGIN_HANDLED;
			}

			if(iPerkId == CP_MULTIPLE_COMBO)
			{
				if(!g_ClanPerks[g_ClanSlot[id]][CP_COMBO])
				{
					dg_color_chat(id, _, "No puedes comprar esta mejora porque requiere tener otra mejora previa");

					showMenu__ClanShowPerkInfo(id, iPerkId);
					return PLUGIN_HANDLED;
				}
			}

			if(g_Clan[g_ClanSlot[id]][clanDeposit] >= CLAN_PERKS[iPerkId][clanPerkCost])
			{
				if(getClanMemberRange(id))
				{
					clanCheckRequiredCombo(id);

					g_ClanPerks[g_ClanSlot[id]][iPerkId] = 1;
					g_Clan[g_ClanSlot[id]][clanDeposit] -= CLAN_PERKS[iPerkId][clanPerkCost];

					sendClanMessage(id, "!tFELICITACIONES!y: El clan compró la ventaja !g%s!y", CLAN_PERKS[iPerkId][clanPerkName]);

					static Handle:sqlQuery;
					sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_clans SET deposit='%d' WHERE id='%d';", g_Clan[g_ClanSlot[id]][clanDeposit], g_Clan[g_ClanSlot[id]][clanId]);
					
					if(!SQL_Execute(sqlQuery))
						executeQuery(id, sqlQuery, 21);
					else
						SQL_FreeHandle(sqlQuery);

					sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_clans_perks (clan_id, perk_id, perk_name, perk_timestamp) VALUES ('%d', '%d', ^"%s^", UNIX_TIMESTAMP());", g_Clan[g_ClanSlot[id]][clanId], iPerkId, CLAN_PERKS[iPerkId][clanPerkName]);
					
					if(!SQL_Execute(sqlQuery))
						executeQuery(id, sqlQuery, 22);
					else
						SQL_FreeHandle(sqlQuery);
				}
				else
					dg_color_chat(id, _, "Solo los miembros con rango de !gDueño!y del Clan pueden comprar las ventajas");
			}

			showMenu__ClanShowPerkInfo(id, iPerkId);
		}
		case 9: showMenu__ClanShowPerks(id);
		default: showMenu__ClanShowPerkInfo(id, iPerkId);
	}

	return PLUGIN_HANDLED;
}

public showMenu__UserOptions(const id)
{
	oldmenu_create("\yOPCIONES DE USUARIO", "menu__UserOptions");

	oldmenu_additem(1, 1, "\r1.\w Elegir color^n");

	oldmenu_additem(2, 2, "\r2.\w Opciones de HUD General");
	oldmenu_additem(3, 3, "\r3.\w Opciones de HUD Combo");
	oldmenu_additem(4, 4, "\r4.\w Opciones de HUD Clan Combo");
	oldmenu_additem(5, 5, "\r5.\w Opciones de Chat^n");

	switch(g_UserOption_Invis[id])
	{
		case 0: oldmenu_additem(6, 6, "\r6.\w Humanos invisibles\r:\y No");
		case 1: oldmenu_additem(6, 6, "\r6.\w Humanos invisibles\r:\y Si");
		case 2: oldmenu_additem(6, 6, "\r6.\w Humanos invisibles\r:\y Si \d[Clan]");
	}
	if((get_user_flags(id) & ADMIN_LEVEL_C))
		oldmenu_additem(7, 7, "\r7.\w Ver chat de Clanes\r:\y %s", ((g_UserOption_ClanChat[id]) ? "Si" : "No"));

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__UserOptions(const id, const item)
{
	switch(item)
	{
		case 1: showMenu__UserOptionsColors(id, g_MenuPage[id][MENU_PAGE_COLOR]);
		case 2: showMenu__UserOptionsHud(id, HUD_TYPE_GENERAL);
		case 3: showMenu__UserOptionsHud(id, HUD_TYPE_COMBO);
		case 4: showMenu__UserOptionsHud(id, HUD_TYPE_CLAN_COMBO);
		case 5: showMenu__UserOptionsChat(id);
		case 6:
		{
			if(++g_UserOption_Invis[id] == 3)
				g_UserOption_Invis[id] = 0;

			showMenu__UserOptions(id);
		}
		case 7:
		{
			if((get_user_flags(id) & ADMIN_LEVEL_C))
				g_UserOption_ClanChat[id] = !g_UserOption_ClanChat[id];

			showMenu__UserOptions(id);
		}
		case 0: showMenu__Game(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__UserOptionsColors(const id, page)
{
	g_MenuPage[id][MENU_PAGE_COLOR] = page;

	static iColorType;
	static iMaxPages;
	static iStart;
	static iEnd;

	iColorType = g_MenuData[id][MENU_DATA_COLOR_TYPE];

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(COLORS), 6);
	oldmenu_create("\yELEGIR COLOR", "menu__UserOptionsColors");

	for(new i = iStart, j = 1; i < iEnd; ++i, ++j)
	{
		if(g_UserOption_Color[id][iColorType][0] == COLORS[i][colorRed] && g_UserOption_Color[id][iColorType][1] == COLORS[i][colorGreen] && g_UserOption_Color[id][iColorType][2] == COLORS[i][colorBlue])
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, COLORS[i][colorName]);
		else
			oldmenu_additem(j, i, "\r%d.\w %s", j, COLORS[i][colorName]);
	}

	oldmenu_additem(7, 7, "^n\r7.\w Tipo de color\r:\y %s^n", COLORS_TYPE_NAMES_MIN[iColorType]);

	if(page > 1)
		oldmenu_additem(8, 8, "\r8.\w Atrás");
	else
		oldmenu_additem(-1, -1, "\d8. Atrás");

	if(page < iMaxPages)
		oldmenu_additem(9, 9, "\r9.\w Siguiente");
	else
		oldmenu_additem(-1, -1, "\d9. Siguiente");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id, page);
}

public menu__UserOptionsColors(const id, const item, const value, page)
{
	switch(item)
	{
		case 7:
		{
			if(++g_MenuData[id][MENU_DATA_COLOR_TYPE] == structIdColorsType)
				g_MenuData[id][MENU_DATA_COLOR_TYPE] = 0;

			showMenu__UserOptionsColors(id, g_MenuPage[id][MENU_PAGE_COLOR]);
		}
		case 8: showMenu__UserOptionsColors(id, (page - 1));
		case 9: showMenu__UserOptionsColors(id, (page + 1));
		case 0: showMenu__UserOptions(id);
		default:
		{
			g_UserOption_Color[id][g_MenuData[id][MENU_DATA_COLOR_TYPE]][0] = COLORS[value][colorRed];
			g_UserOption_Color[id][g_MenuData[id][MENU_DATA_COLOR_TYPE]][1] = COLORS[value][colorGreen];
			g_UserOption_Color[id][g_MenuData[id][MENU_DATA_COLOR_TYPE]][2] = COLORS[value][colorBlue];

			if(g_MenuData[id][MENU_DATA_COLOR_TYPE] == COLOR_TYPE_NVISION && g_NightVision[id] && task_exists(id + TASK_NIGHTVISION))
			{
				remove_task(id + TASK_NIGHTVISION);
				set_task(0.3, "task__SetUserNightVision", id + TASK_NIGHTVISION, .flags="b");
			}

			showMenu__UserOptionsColors(id, g_MenuPage[id][MENU_PAGE_COLOR]);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__UserOptionsHud(const id, const type)
{
	g_MenuData[id][MENU_DATA_HUD_TYPE] = type;

	oldmenu_create("\yOPCIONES DE HUD %s", "menu__UserOptionsHud", HUDS_TYPE_NAMES_MAY[type]);

	oldmenu_additem(1, 1, "\r1.\w Mover hacia arriba");
	oldmenu_additem(2, 2, "\r2.\w Mover hacia abajo");
	if(g_UserOption_PositionHud[id][type][2] == 0.0)
	{
		oldmenu_additem(3, 3, "\r3.\w Mover hacia la izquierda");
		oldmenu_additem(4, 4, "\r4.\w Mover hacia la derecha");
	}
	else
	{
		oldmenu_additem(-1, -1, "\d3. Mover hacia la izquierda");
		oldmenu_additem(-1, -1, "\d4. Mover hacia la derecha");
	}

	oldmenu_additem(5, 5, "^n\r5.\w Alineado %s", ((g_UserOption_PositionHud[id][type][2] == 1.0) ? "al Centro" : ((g_UserOption_PositionHud[id][type][2] == 2.0) ? "a la Derecha" : "a la Izquierda")));

	oldmenu_additem(6, 6, "^n\r6.\w Efecto del HUD\r:\y %s", ((g_UserOption_EffectHud[id][type]) ? "Activado" : "Desactivado"));
	if(type == HUD_TYPE_GENERAL)
		oldmenu_additem(7, 7, "\r7.\w Minimizar HUD\r:\y %s", ((g_UserOption_MinimizeHud[id][type]) ? "Activado" : "Desactivado"));
	else
		oldmenu_additem(-1, -1, "\d7. Minimizar HUD\r:\y %s", ((g_UserOption_MinimizeHud[id][type]) ? "Activado" : "Desactivado"));
	oldmenu_additem(8, 8, "\r8.\w Abreviar HUD\r:\y %s", ((g_UserOption_AbreviateHud[id][type]) ? "Activado" : "Desactivado"));

	oldmenu_additem(9, 9, "^n\r9.\w Reiniciar posición");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__UserOptionsHud(const id, const item)
{
	static iHudType;
	iHudType = g_MenuData[id][MENU_DATA_HUD_TYPE];

	switch(item)
	{
		case 0:
		{
			showMenu__UserOptions(id);
			return PLUGIN_HANDLED;
		}
		case 1: g_UserOption_PositionHud[id][iHudType][1] -= 0.01;
		case 2: g_UserOption_PositionHud[id][iHudType][1] += 0.01;
		case 3: g_UserOption_PositionHud[id][iHudType][0] -= 0.01;
		case 4: g_UserOption_PositionHud[id][iHudType][0] += 0.01;
		case 5:
		{
			switch(g_UserOption_PositionHud[id][iHudType][2])
			{
				case 0.0:
				{
					g_UserOption_PositionHud[id][iHudType][0] = -1.0;
					g_UserOption_PositionHud[id][iHudType][2] = 1.0;
				}
				case 1.0:
				{
					g_UserOption_PositionHud[id][iHudType][0] = 1.5;
					g_UserOption_PositionHud[id][iHudType][2] = 2.0;
				}
				case 2.0:
				{
					g_UserOption_PositionHud[id][iHudType][0] = 0.0;
					g_UserOption_PositionHud[id][iHudType][2] = 0.0;
				}
			}
		}
		case 6: g_UserOption_EffectHud[id][iHudType] = !g_UserOption_EffectHud[id][iHudType];
		case 7: g_UserOption_MinimizeHud[id][iHudType] = !g_UserOption_MinimizeHud[id][iHudType];
		case 8: g_UserOption_AbreviateHud[id][iHudType] = !g_UserOption_AbreviateHud[id][iHudType];
		case 9:
		{
			switch(iHudType)
			{
				case HUD_TYPE_GENERAL: g_UserOption_PositionHud[id][HUD_TYPE_GENERAL] = Float:{0.01, 0.1, 0.0};
				case HUD_TYPE_COMBO: g_UserOption_PositionHud[id][HUD_TYPE_COMBO] = Float:{-1.0, 0.6, 1.0};
				case HUD_TYPE_CLAN_COMBO: g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO] = Float:{-1.0, 0.875, 1.0};
			}
		}
	}

	if(iHudType == HUD_TYPE_COMBO)
	{
		set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD_C][0], g_UserOption_Color[id][COLOR_TYPE_HUD_C][1], g_UserOption_Color[id][COLOR_TYPE_HUD_C][2], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1], g_UserOption_EffectHud[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
		if(g_UserOption_AbreviateHud[id][HUD_TYPE_COMBO])
			ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nx1.337 | +1.337^n1.337 | 1.337", COMBO_HUMAN[random_num(0, charsmax(COMBO_HUMAN))][comboMessage]);
		else
			ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nCombo x1.337 | +1.337 EXP^nDaño total: 1.337 | Daño: 1.337", COMBO_HUMAN[random_num(0, charsmax(COMBO_HUMAN))][comboMessage]);
	}
	else if(iHudType == HUD_TYPE_CLAN_COMBO)
	{
		set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD_CC][0], g_UserOption_Color[id][COLOR_TYPE_HUD_CC][1], g_UserOption_Color[id][COLOR_TYPE_HUD_CC][2], g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][1], g_UserOption_EffectHud[id][HUD_TYPE_CLAN_COMBO], 1.0, 8.0, 0.01, 0.01);
		if(g_UserOption_AbreviateHud[id][HUD_TYPE_CLAN_COMBO])
			ShowSyncHudMsg(id, g_HudSync_ClanCombo, "%s [%d]^nx1.337 | +1.337^n1.337", PLUGIN_COMMUNITY_NAME, random_num(1, MAX_CLAN_MEMBERS));
		else
			ShowSyncHudMsg(id, g_HudSync_ClanCombo, "%s [%d]^nCombo x1.337 | +1.337 EXP^nDaño total: 1.337", PLUGIN_COMMUNITY_NAME, random_num(1, MAX_CLAN_MEMBERS));
	}

	showMenu__UserOptionsHud(id, iHudType);
	return PLUGIN_HANDLED;
}

public showMenu__UserOptionsChat(const id)
{
	oldmenu_create("\yOPCIONES DE CHAT", "menu__UserOptionsChat");

	for(new i = 0, j = 1; i < structIdChatMode; ++i, ++j)
	{
		if(g_UserOption_ChatMode[id] == i)
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, CHAT_MODE[i]);
		else
			oldmenu_additem(j, i, "\r%d.\w %s", j, CHAT_MODE[i]);
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__UserOptionsChat(const id, const item, const value)
{
	switch(item)
	{
		case 0: showMenu__UserOptions(id);
		default:
		{
			if(g_UserOption_ChatMode[id] == value)
			{
				dg_color_chat(id, _, "Ya has elegido esta opción");

				showMenu__UserOptionsChat(id);
				return PLUGIN_HANDLED;
			}

			g_UserOption_ChatMode[id] = value;

			dg_color_chat(id, _, "Has elegido la opción !g%s!y", CHAT_MODE[value]);
			showMenu__UserOptionsChat(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__Stats(const id)
{
	oldmenu_create("\yESTADÍSTICAS", "menu__Stats");

	oldmenu_additem(1, 1, "\r1.\w Lista de niveles");
	if(g_Exp[id] >= getUserMaxXP(g_Reset[id]) && g_Level[id] >= MAX_LEVEL)
		oldmenu_additem(2, 2, "\r2.\w Subir de Rango^n");
	else
		oldmenu_additem(-1, -1, "\d2. Subir de Rango \r(%0.2f%%)^n", g_ResetPercent[id]);

	oldmenu_additem(3, 3, "\r3.\w Estadísticas generales");
	oldmenu_additem(4, 4, "\r4.\w Estadísticas de modos");
	oldmenu_additem(5, 5, "\r5.\w Estadísticas de Items Extras^n");

	if(g_Class[id])
		oldmenu_additem(6, 6, "\r6.\w Clase %s", __CLASSES[g_Class[id]][className]);
	
	if((get_user_flags(id) & ADMIN_RESERVATION))
	{
		oldmenu_additem(-1, -1, "\d7. Beneficio gratuito");
		oldmenu_additem(-1, -1, "\r - \dSolo jugadores sin VIP o rango superior^n");
	}
	else
		oldmenu_additem(7, 7, "\r7.\w Beneficio gratuito^n");

	static sAccountId[8];
	static sForumId[8];

	addDot(g_AccountId[id], sAccountId, charsmax(sAccountId));
	addDot(g_AccountVinc[id], sForumId, charsmax(sForumId));

	oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccountId);
	oldmenu_additem(-1, -1, "\wVINCULADA AL FORO\r:\y %s \d(#%s)^n", ((g_AccountVinc[id]) ? "Si" : "No"), sForumId);
	oldmenu_additem(-1, -1, "\wTIEMPO JUGADO\r:\y %s^n", getUserTimePlaying(id));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Stats(const id, const item)
{
	switch(item)
	{
		case 1:
		{
			static iFixPage;
			iFixPage = ((g_Level[id] > 7) ? ((g_Level[id] / 7) + 1) : 1);

			if(iFixPage > 1)
				g_MenuPage[id][MENU_PAGE_STATS_LEVELS] = iFixPage;

			showMenu__StatsLevels(id, g_MenuPage[id][MENU_PAGE_STATS_LEVELS]);
		}
		case 2:
		{
			if(g_Exp[id] < getUserMaxXP(g_Reset[id]) || g_Level[id] < MAX_LEVEL)
			{
				dg_color_chat(id, _, "No cumples los requisitos para poder avanzar al !grango %c!y", getUserRange((g_Reset[id] + 1)));

				showMenu__Stats(id);
				return PLUGIN_HANDLED;
			}

			++g_Reset[id];

			switch(g_Reset[id])
			{
				case 5: giveHat(id, HAT_TYNO);
				case 6: setAchievement(id, R_CICLO_C);
				case 13: setAchievement(id, R_CICLO_B);
				case 19: setAchievement(id, R_CICLO_A);
				case 25: setAchievement(id, CICLO_MAXIMO);
			}

			g_Exp[id] = 0;
			g_Level[id] = 1;
			g_LevelPercent[id] = 0.00;
			g_ResetPercent[id] = 0.00;
			g_Points[id][POINT_HUMAN] += (g_Reset[id] * MAX_POINT_RESET_REWARD);
			g_Points[id][POINT_ZOMBIE] += (g_Reset[id] * MAX_POINT_RESET_REWARD);

			dg_color_chat(0, _, "Felicitaciones a !t%s!y, subió al !grango %c!y", g_PlayerName[id], getUserRange(g_Reset[id]));
			checkExpEquation(id);
		}
		case 3: showMenu__StatsGeneral(id);
		case 4: showMenu__StatsMode(id);
		case 5: showMenu__StatsExtraItems(id);
		case 6:
		{
			if(g_Class[id])
				showMenu__StatsClasses(id);
		}
		case 7:
		{
			if(!(get_user_flags(id) & ADMIN_RESERVATION))
				showMenu__Benefit(id);
		}
		case 0: showMenu__Game(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__StatsLevels(const id, page)
{
	g_MenuPage[id][MENU_PAGE_STATS_LEVELS] = page;

	static iMaxPages;
	static iStart;
	static iEnd;
	static i;
	static j;
	static sLevel[8];
	static sAmmoPacks[16];

	oldmenu_pages(iMaxPages, iStart, iEnd, page, MAX_LEVEL);
	oldmenu_create("\yLISTA DE NIVELES \r[%d - %d]\y\R%d/%d", "menu__StatsLevels", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j)
	{
		addDot((i + 1), sLevel, charsmax(sLevel));
		addDot(getUserNextLevel(id, .level=(i + 1)), sAmmoPacks, charsmax(sAmmoPacks));

		oldmenu_additem(j, i, "\r%d.%s Nivel\r:%s %s \r-%s XP\r:%s %s", j, ((g_Level[id] > i) ? "\w" : "\d"), ((g_Level[id] > i) ? "\y" : "\r"), sLevel, ((g_Level[id] > i) ? "\w" : "\d"), ((g_Level[id] > i) ? "\y" : "\r"), sAmmoPacks);
	}

	oldmenu_additem(-1, -1, "^n\yNOTA\r:\w Cada vez que subas de nivel tus XP volverán a 0^n");

	if(page > 1)
		oldmenu_additem(8, 8, "\r8.\w Atrás");
	else
		oldmenu_additem(-1, -1, "\d8. Atrás");

	if(page < iMaxPages)
		oldmenu_additem(9, 9, "\r9.\w Siguiente");
	else
		oldmenu_additem(-1, -1, "\d9. Siguiente");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id, page);
}

public menu__StatsLevels(const id, const item, const value, page)
{
	switch(item)
	{
		case 8: showMenu__StatsLevels(id, (page - 1));
		case 9: showMenu__StatsLevels(id, (page + 1));
		case 0: showMenu__Stats(id);
		default:
		{
			static sAmmoPacks[16];
			static sLevel[8];

			addDot(getUserNextLevel(id, .level=value), sAmmoPacks, charsmax(sAmmoPacks));
			addDot((value + 1), sLevel, charsmax(sLevel));

			dg_color_chat(id, _, "Te faltan !g%s XP!y para avanzar al !gnivel %s!y", sAmmoPacks, sLevel);
			showMenu__StatsLevels(id, g_MenuPage[id][MENU_PAGE_STATS_LEVELS]);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__StatsGeneral(const id)
{
	oldmenu_create("\yESTADÍSTICAS GENERALES\R%d/4", "menu__StatsGeneral", (g_MenuPage[id][MENU_PAGE_STATS_GENERAL] + 1));

	static sInfo[32];
	static sInfoOutPut[32];

	switch(g_MenuPage[id][MENU_PAGE_STATS_GENERAL])
	{
		case 0:
		{
			formatex(sInfo, charsmax(sInfo), "%0.0f", (g_StatsDamage[id][0] * DIV_NUM_TO_FLOAT));
			addDotSpecial(sInfo, sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wDaño realizado\r:\y %s", sInfoOutPut);

			formatex(sInfo, charsmax(sInfo), "%0.0f", (g_StatsDamage[id][1] * DIV_NUM_TO_FLOAT));
			addDotSpecial(sInfo, sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wDaño recibido\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_HS_D], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wDisparos en la cabeza realizados\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_HS_T], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wDisparos en la cabeza recibidos\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_HM_D], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wHumanos matados\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_HM_T], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wVeces muerto como humano\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_ZM_D], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wZombies matados\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_ZM_T], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wVeces muerto como zombie\r:\y %s", sInfoOutPut);
		}
		case 1:
		{
			addDot(g_Stats[id][STAT_INF_D], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wInfecciones realizadas\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_INF_T], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wInfeccinoes recibidas\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_ZMHS_D], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wZombies matados en la cabeza\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_ZMHS_T], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wVeces muerto en la cabeza como zombie\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_ZMK_D], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wZombies matados con cuchillo\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_ZMK_T], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wVeces muerto con cuchillo como zombie\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_AP_D], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wChaleco desgarrado realizado\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_AP_T], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wChaleco desgarrado recibido\r:\y %s", sInfoOutPut);
		}
		case 2:
		{
			addDot(g_Stats[id][STAT_COMBO_MAX], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wCombo máximo realizado\r:\y %s", sInfoOutPut);
			
			addDot(g_Stats[id][STAT_DUEL_WIN], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wDuelos ganados\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_DUEL_LOSE], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wDuelos perdidos\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_DUEL_FINAL_WINS], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wDuelos finales ganados\r:\y %s", sInfoOutPut);

			addDot(g_Stats[id][STAT_GG_WINS], sInfoOutPut, charsmax(sInfoOutPut));
			oldmenu_additem(-1, -1, "\wGunGames ganados\r:\y %s", sInfoOutPut);
		}
	}

	oldmenu_additem(9, 9, "^n\r9.\w Siguiente/Atrás");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__StatsGeneral(const id, const item)
{
	switch(item)
	{
		case 9:
		{
			if(++g_MenuPage[id][MENU_PAGE_STATS_GENERAL] == 3)
				g_MenuPage[id][MENU_PAGE_STATS_GENERAL] = 0;

			showMenu__StatsGeneral(id);
		}
		case 0: showMenu__Stats(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__StatsMode(const id)
{
	oldmenu_create("\yESTADÍSTICAS DE MODOS\R%d/3^n\wG\r:\y Ganados \r-\w P\r:\y Perdidos", "menu__StatsMode", (g_MenuPage[id][MENU_PAGE_STATS_MODE] + 1));

	switch(g_MenuPage[id][MENU_PAGE_STATS_MODE])
	{
		case 0:
		{
			oldmenu_additem(-1, -1, "\wFuiste survivor\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_S_M_C], ((g_Stats[id][STAT_S_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_S_M_WIN], g_Stats[id][STAT_S_M_LOSE]);
			oldmenu_additem(-1, -1, "\wSurvivors matados\r:\y %d^n", g_Stats[id][STAT_S_M_KILL]);

			oldmenu_additem(-1, -1, "\wFuiste wesker\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_W_M_C], ((g_Stats[id][STAT_W_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_W_M_WIN], g_Stats[id][STAT_W_M_LOSE]);
			oldmenu_additem(-1, -1, "\wWeskers matados\r:\y %d^n", g_Stats[id][STAT_W_M_KILL]);

			oldmenu_additem(-1, -1, "\wFuiste sniper elite\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_SN_M_C], ((g_Stats[id][STAT_SN_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_SN_M_WIN], g_Stats[id][STAT_SN_M_LOSE]);
			oldmenu_additem(-1, -1, "\wSnipers Elite matados\r:\y %d", g_Stats[id][STAT_SN_M_KILL]);
		}
		case 1:
		{
			oldmenu_additem(-1, -1, "\wFuiste Jason\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_J_M_C], ((g_Stats[id][STAT_J_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_J_M_WIN], g_Stats[id][STAT_J_M_LOSE]);
			oldmenu_additem(-1, -1, "\wJaons matados\r:\y %d^n", g_Stats[id][STAT_J_M_KILL]);

			oldmenu_additem(-1, -1, "\wFuiste nemesis\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_N_M_C], ((g_Stats[id][STAT_N_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_N_M_WIN], g_Stats[id][STAT_N_M_LOSE]);
			oldmenu_additem(-1, -1, "\wNeesis matados\r:\y %d^n", g_Stats[id][STAT_N_M_KILL]);

			oldmenu_additem(-1, -1, "\wFuiste assassin\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_A_M_C], ((g_Stats[id][STAT_A_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_A_M_WIN], g_Stats[id][STAT_A_M_LOSE]);
			oldmenu_additem(-1, -1, "\wAssassins matados\r:\y %d", g_Stats[id][STAT_A_M_KILL]);
		}
		case 2:
		{
			oldmenu_additem(-1, -1, "\wFuiste aniquilador\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_AN_M_C], ((g_Stats[id][STAT_AN_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_AN_M_WIN], g_Stats[id][STAT_AN_M_LOSE]);
			oldmenu_additem(-1, -1, "\wAniquiladores matados\r:\y %d^n", g_Stats[id][STAT_AN_M_KILL]);

			oldmenu_additem(-1, -1, "\wFuiste freddy\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_F_M_C], ((g_Stats[id][STAT_F_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_F_M_WIN], g_Stats[id][STAT_F_M_LOSE]);
			oldmenu_additem(-1, -1, "\wFreddys matados\r:\y %d^n", g_Stats[id][STAT_F_M_KILL]);

			oldmenu_additem(-1, -1, "\wFuiste tribal\r:\y %d ve%s \d[G: %d - P: %d]", g_Stats[id][STAT_T_M_C], ((g_Stats[id][STAT_T_M_C] != 1) ? "ces" : "z"), g_Stats[id][STAT_T_M_WIN], g_Stats[id][STAT_T_M_LOSE]);
			oldmenu_additem(-1, -1, "\wTribales matados\r:\y %d", g_Stats[id][STAT_T_M_KILL]);
		}
	}

	oldmenu_additem(9, 9, "^n\r9.\w Siguiente/Atrás");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__StatsMode(const id, const item)
{
	switch(item)
	{
		case 9:
		{
			if(++g_MenuPage[id][MENU_PAGE_STATS_MODE] == 3)
				g_MenuPage[id][MENU_PAGE_STATS_MODE] = 0;

			showMenu__StatsMode(id);
		}
		case 0: showMenu__Stats(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__StatsExtraItems(const id)
{
	oldmenu_create("\yESTADÍSTICAS DE ITEMS EXTRAS", "menu__StatsExtraItems");

	static sExtraItemCount[8];
	sExtraItemCount[0] = EOS;

	for(new i = 0; i < structIdExtraItems; ++i)
	{
		if(g_Zombie[id] != EXTRA_ITEMS[i][extraItemTeam])
			continue;

		addDot(g_ExtraItem_Count[id][i], sExtraItemCount, charsmax(sExtraItemCount));
		oldmenu_additem(-1, -1, "\w%s\r:\y %s", EXTRA_ITEMS[i][extraItemName], sExtraItemCount);
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__StatsExtraItems(const id, const item)
{
	if(item == 0)
	{
		showMenu__Stats(id);
		return PLUGIN_HANDLED;
	}

	showMenu__StatsExtraItems(id);
	return PLUGIN_HANDLED;
}

public showMenu__StatsClasses(const id)
{
	if(!g_Class[id])
		return;

	static sTitle[32];
	copy(sTitle, charsmax(sTitle), __CLASSES[g_Class[id]][className]);
	strtoupper(sTitle);

	oldmenu_create("\yCLASE %s^n\wAquí abajo aparecerán los beneficios del mismo", "menu__StatsClasses", sTitle);

	oldmenu_additem(-1, -1, "\r - \wAPs\r:\y +x%d", __CLASSES[g_Class[id]][classMultAPs]);
	oldmenu_additem(-1, -1, "\r - \wXP\r:\y +x%d", __CLASSES[g_Class[id]][classMultXP]);
	oldmenu_additem(-1, -1, "\r - \wDaño para hacer combo base\r:\y %0.2f", __CLASSES[g_Class[id]][classMultCombo]);
	oldmenu_additem(-1, -1, "\r - \wVida\r:\y +%d", __CLASSES[g_Class[id]][classHealth]);
	oldmenu_additem(-1, -1, "\r - \wVelocidad\r:\y +%d", __CLASSES[g_Class[id]][classSpeed]);
	oldmenu_additem(-1, -1, "\r - \wGravedad\r:\y +%d", __CLASSES[g_Class[id]][classGravity]);
	oldmenu_additem(-1, -1, "\r - \wDaño\r:\y +%d", __CLASSES[g_Class[id]][classDamage]);
	oldmenu_additem(-1, -1, "\r - \wRespawn humano\r:\y +%d%%", __CLASSES[g_Class[id]][classRespawn]);
	oldmenu_additem(-1, -1, "\r - \wDescuento de Items Extras\r:\y -%d%%", __CLASSES[g_Class[id]][classReduceExtraItems]);
	oldmenu_additem(-1, -1, "\r - \wPetición de modo\r:\y %d min", __CLASSES[g_Class[id]][classPetitionMode]);
	
	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__StatsClasses(const id, const item)
{
	if(!g_Class[id])
		return PLUGIN_HANDLED;

	switch(item)
	{
		case 0: showMenu__Game(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__Hats(const id)
{
	static sItem[64];
	static iMenuId;
	static sPosition[2];

	iMenuId = menu_create("GORROS\R", "menu__Hats");

	for(new i = 0; i < structIdHats; ++i)
	{
		if(i == HAT_NONE)
			formatex(sItem, charsmax(sItem), "\w%s^n", HATS[i][hatName]);
		else if(g_HatId[id] == i)
			formatex(sItem, charsmax(sItem), "\w%s \y(EQUIPADO)", HATS[i][hatName]);
		else if(g_HatNext[id] == i && i)
			formatex(sItem, charsmax(sItem), "\w%s \y(ELEGIDO)", HATS[i][hatName]);
		else if(g_Hat[id][i])
			formatex(sItem, charsmax(sItem), "\w%s", HATS[i][hatName]);
		else
			formatex(sItem, charsmax(sItem), "\d%s", HATS[i][hatName]);

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_HAT_CLASS] = min(g_MenuPage[id][MENU_PAGE_HAT_CLASS], (menu_pages(iMenuId) - 1));

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_HAT_CLASS]);
}

public menu__Hats(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_HAT_CLASS]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(iItemId == HAT_NONE)
	{
		g_HatNext[id] = HAT_NONE;
		
		if(g_HatId[id])
		{
			dg_color_chat(id, _, "Tu gorro ha sido removido");

			if(is_valid_ent(g_HatEnt[id]))
				remove_entity(g_HatEnt[id]);

			g_HatId[id] = HAT_NONE;
		}

		showMenu__Hats(id);
	}
	else
		showMenu__HatInfo(id, iItemId);

	return PLUGIN_HANDLED;
}

public showMenu__HatInfo(const id, const hat)
{
	if(!hat)
	{
		showMenu__Hats(id);
		return;
	}

	g_MenuData[id][MENU_DATA_HAT_ID] = hat;

	static sHatName[32];
	copy(sHatName, charsmax(sHatName), HATS[hat][hatName]);
	strtoupper(sHatName);

	oldmenu_create("\y%s - %s", "menu__HatInfo", sHatName, ((!g_Hat[id][hat]) ? " \r(NO OBTENIDO)" : " \y(OBTENIDO)"));

	oldmenu_additem(-1, -1, "\yREQUERIMIENTOS\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", HATS[hat][hatDesc]);

	if(HATS[hat][hatDescExtra][0])
	{
		oldmenu_additem(-1, -1, "\yNOTA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", HATS[hat][hatDescExtra]);
	}

	oldmenu_additem(-1, -1, "\yBENEFICIOS\r:");
	{
		if(HATS[hat][hatUpgrade1])
			oldmenu_additem(-1, -1, "\r - \y+%d\w Vida", HATS[hat][hatUpgrade1]);

		if(HATS[hat][hatUpgrade2])
			oldmenu_additem(-1, -1, "\r - \y+%d\w Velocidad", HATS[hat][hatUpgrade2]);

		if(HATS[hat][hatUpgrade3])
			oldmenu_additem(-1, -1, "\r - \y+%d\w Gravedad", HATS[hat][hatUpgrade3]);

		if(HATS[hat][hatUpgrade4])
			oldmenu_additem(-1, -1, "\r - \y+%d\w Daño", HATS[hat][hatUpgrade4]);

		if(HATS[hat][hatUpgrade5])
			oldmenu_additem(-1, -1, "\r - \y+x%d\w APs", HATS[hat][hatUpgrade5]);

		if(HATS[hat][hatUpgrade6])
			oldmenu_additem(-1, -1, "\r - \y+x%d\w XP", HATS[hat][hatUpgrade6]);

		if(HATS[hat][hatUpgrade7])
			oldmenu_additem(-1, -1, "\r - \y+%d%%\w Respawn Humano", HATS[hat][hatUpgrade7]);

		if(HATS[hat][hatUpgrade8])
			oldmenu_additem(-1, -1, "\r - \y+%d%%\w Descuento en Items", HATS[hat][hatUpgrade8]);
	}

	if(g_Hat[id][hat])
	{
		oldmenu_additem(-1, -1, "^n\yGORRO OBTENIDO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s^n", getUnixToTime(g_HatUnlocked[id][hat], 1));

		oldmenu_additem(1, 1, "\r1.\w %s gorro", (g_HatId[id] == hat) ? "Desequipar" : "Equipar");
		oldmenu_additem(2, 2, "\r2.\w Mostrar gorro en el Chat^n");
	}
	else
	{
		oldmenu_additem(-1, -1, "^n\d1. %s gorro", (g_HatId[id] == hat) ? "Desequipar" : "Equipar");
		oldmenu_additem(-1, -1, "\d2. Mostrar gorro en el Chat^n");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HatInfo(const id, const item)
{
	static iHatId;
	iHatId = g_MenuData[id][MENU_DATA_HAT_ID];

	switch(item)
	{
		case 1:
		{
			if(g_Hat[id][iHatId])
			{
				g_HatNext[id] = iHatId;

				if(!g_NewRound)
					dg_color_chat(id, _, "Cuando vuelvas a ser humano tendrás el gorro !g%s!y", HATS[iHatId][hatName]);
				else
					setHat(id, g_HatNext[id]);
			}

			showMenu__Hats(id);
		}
		case 2:
		{
			if(g_Hat[id][iHatId])
			{
				if(g_AccountId[id] == 1 || g_HatTimeLink[id] < get_gametime())
				{
					g_HatTimeLink[id] = get_gametime() + 15.0;
					dg_color_chat(0, _, "!t%s!y muestra su gorro !g%s !t[X]!y conseguido el !g%s!y", g_PlayerName[id], HATS[iHatId][hatName], getUnixToTime(g_HatUnlocked[id][iHatId], 1));
					
					g_LastHatUnlocked = iHatId;
				}
			}

			showMenu__HatInfo(id, iHatId);
		}
		case 0: showMenu__Hats(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__HeadZombies(const id)
{
	if(g_MiniGame_Habs)
		return;

	oldmenu_create("\yCABEZAS ZOMBIES", "menu__HeadZombies");

	for(new i = 0, j = 1; i < structIdHeadZombies; ++i, ++j)
	{
		oldmenu_additem(j, i, "\r%d.\w Abrir cabeza %s \y(%d)", j, HEADZOMBIES_NAMES[i], g_HeadZombie[id][i]);
		oldmenu_additem(-1, -1, "\r >>> \w %s^n", HEADZOMBIES_INFO[i]);
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HeadZombies(const id, const item, const value)
{
	if(g_MiniGame_Habs)
		return PLUGIN_HANDLED;

	switch(item)
	{
		case 0: showMenu__Game(id);
		default:
		{
			if(g_HeadZombie[id][value] <= 0)
			{
				dg_color_chat(id, _, "No tienes cabezas %s por abrir", HEADZOMBIES_NAMES[value]);

				showMenu__HeadZombies(id);
				return PLUGIN_HANDLED;
			}

			static sMessage[64];
			sMessage[0] = EOS;

			switch(value)
			{
				case HEADZOMBIE_RED: // APs
				{
					static iReward;
					static sReward[16];

					iReward = (random_num(25, 100) * getLevelTotal(id)) * g_AmmoPacksMult[id];
					addDot(iReward, sReward, charsmax(sReward));

					formatex(sMessage, charsmax(sMessage), "La cabeza zombie roja tenía !g%s APs!y", sReward);
					addAPs(id, iReward);
				}
				case HEADZOMBIE_GREEN:
				{
					static iPercent;
					iPercent = random_num(1, 100);

					if(iPercent <= 75)
					{
						static iRewardXP;
						static sRewardXP[16];

						iRewardXP = (getConversionPercent(id, random_num(33, 66)) * g_ExpMult[id]);
						addDot(iRewardXP, sRewardXP, charsmax(sRewardXP));

						formatex(sMessage, charsmax(sMessage), "La cabeza zombie verde tenía !g%s XP!y", sRewardXP);
						addXP(id, iRewardXP);
					}
					else
						formatex(sMessage, charsmax(sMessage), "%s", HEADZOMBIES_MESSAGES[random_num(0, charsmax(HEADZOMBIES_MESSAGES))]);
				}
				case HEADZOMBIE_BLUE: // Items Extras
				{
					if(g_EventModes)
					{
						dg_color_chat(id, _, "No podes abrir cabezas azules mientras está el mini evento de modos especiales");

						showMenu__HeadZombies(id);
						return PLUGIN_HANDLED;
					}
					else if(!g_NewRound || g_EndRound)
					{
						dg_color_chat(id, _, "Las cabezas zombie azules solo se pueden romper antes de que comience un modo");

						showMenu__HeadZombies(id);
						return PLUGIN_HANDLED;
					}

					static iPercent;
					iPercent = random_num(1, 100);

					if(iPercent <= 50)
					{
						static iEIRandom;
						iEIRandom = random_num(1, 5);

						switch(iEIRandom)
						{
							case 1:
							{
								buyExtraItem(id, EXTRA_ITEM_NIGHTVISION, 1);
								formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gVisión nocturna!y");
							}
							case 2:
							{
								buyExtraItem(id, EXTRA_ITEM_INVISIBILITY, 1);
								formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gInvisibilidad!y");
							}
							case 3:
							{
								buyExtraItem(id, EXTRA_ITEM_UNLIMITED_CLIP, 1);
								formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gBalas infinitas!y");
							}
							case 4:
							{
								buyExtraItem(id, EXTRA_ITEM_PP, 1);
								formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gPrecisión perfecta!y");
							}
							case 5:
							{
								set_pdata_int(id, OFFSET_LONG_JUMP, 1, OFFSET_LINUX);

								g_LongJump[id] = 1;
								g_InJump[id] = 0;

								formatex(sMessage, charsmax(sMessage), "La cabeza zombie azul tenía !gLong Jump!y");
							}
						}
					}
					else
						formatex(sMessage, charsmax(sMessage), "%s", HEADZOMBIES_MESSAGES[random_num(0, charsmax(HEADZOMBIES_MESSAGES))]);
				}
				case HEADZOMBIE_YELLOW: // pH-pZ-pE
				{
					static iPercent;
					iPercent = random_num(1, 100);

					if(iPercent <= 25)
					{
						static iPointsPercent;
						iPointsPercent = random_num(1, 5);

						switch(iPercent)
						{
							case 0..10: // pH
							{
								g_Points[id][POINT_HUMAN] += iPointsPercent;
								formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pH!y", iPointsPercent);
							}
							case 11..20: // pZ
							{
								g_Points[id][POINT_ZOMBIE] += iPointsPercent;
								formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pZ!y", iPointsPercent);
							}
							case 21..25: // pE
							{
								g_Points[id][POINT_SPECIAL] += iPointsPercent;
								formatex(sMessage, charsmax(sMessage), "La cabeza zombie amarilla tenía !g%d pE!y", iPointsPercent);
							}
						}
					}
					else
						formatex(sMessage, charsmax(sMessage), "%s", HEADZOMBIES_MESSAGES[random_num(0, charsmax(HEADZOMBIES_MESSAGES))]);
				}
				case HEADZOMBIE_WHITE: // Modos (Si tienen alguna clase, se le da [APs y pH-pZ-pE])
				{
					if(g_Class[id])
					{
						static iPercent;
						iPercent = random_num(1, 100);

						if(iPercent <= 10)
						{
							static iRewardAPs;
							static iRewardXP;
							static sRewardAPs[16];
							static sRewardXP[16];

							iRewardAPs = clamp(((random_num(100, 500) * getLevelTotal(id)) * 2) * g_AmmoPacksMult[id]);
							addAPs(id, iRewardAPs);
							
							iRewardXP = (getConversionPercent(id, random_num(66, 99)) * g_ExpMult[id]) * 2;
							addXP(id, iRewardXP);

							static iPointsPercent;
							iPointsPercent = random_num(3, 8);

							switch(iPercent)
							{
								case 0..10: g_Points[id][POINT_HUMAN] += iPointsPercent;
								case 11..20: g_Points[id][POINT_ZOMBIE] += iPointsPercent;
								case 21..25: g_Points[id][POINT_SPECIAL] += iPointsPercent;
							}

							addDot(iRewardAPs, sRewardAPs, charsmax(sRewardAPs));
							addDot(iRewardXP, sRewardXP, charsmax(sRewardXP));

							formatex(sMessage, charsmax(sMessage), "La cabeza zombie blanca tenía !g%s APs!y, !g%s XP!y y !g%d p%c!y", sRewardAPs, sRewardXP, iPointsPercent, ((iPercent >= 0 && iPercent <= 10) ? 'H' : ((iPercent >= 11 && iPercent <= 20) ? 'Z' : 'E')));
						}
						else
							formatex(sMessage, charsmax(sMessage), "%s", HEADZOMBIES_MESSAGES[random_num(0, charsmax(HEADZOMBIES_MESSAGES))]);
					}
					else
					{
						if(g_EventModes)
						{
							dg_color_chat(id, _, "No podes abrir cabezas blanca mientras está el mini evento de modos especiales");

							showMenu__HeadZombies(id);
							return PLUGIN_HANDLED;
						}
						else if(!g_NewRound || g_EndRound)
						{
							dg_color_chat(id, _, "Las cabezas zombie blanca solo se pueden romper antes de que comience un modo");

							showMenu__HeadZombies(id);
							return PLUGIN_HANDLED;
						}
						else if(g_StartMode_Force)
						{
							dg_color_chat(id, _, "No puedes abrir cabezas blanca porque un miembro del staff ha elegido un modo siguiente de manera forzada");

							showMenu__PetitionMode(id);
							return PLUGIN_HANDLED;
						}

						static iSysTime;
						iSysTime = get_systime();

						if(g_HeadZombieSys > iSysTime)
						{
							static iRest;
							iRest = (g_HeadZombieSys - iSysTime);

							dg_color_chat(id, _, "Debes esperar !g%s!y para volver a abrir una cabeza zombie blanca", getCooldDownTime(iRest));

							showMenu__HeadZombies(id);
							return PLUGIN_HANDLED;
						}

						static iUsersNum;
						iUsersNum = getPlaying();

						if(iUsersNum < MIN_USERS_FOR_HEAD_IN_MODE)
						{
							dg_color_chat(id, _, "Debe haber !g+%d jugadores!y para poder abrir una cabeza zombie blanca", MIN_USERS_FOR_HEAD_IN_MODE);

							showMenu__HeadZombies(id);
							return PLUGIN_HANDLED;
						}

						static iPercent;
						iPercent = random_num(1, 100);

						if(iPercent <= 5)
						{
							static iModeRandom;
							iModeRandom = random_num(1, 6);

							switch(iModeRandom)
							{
								case 1: iModeRandom = MODE_SURVIVOR;
								case 2: iModeRandom = MODE_WESKER;
								case 3: iModeRandom = MODE_SNIPER_ELITE;
								case 4: iModeRandom = MODE_JASON;
								case 5: iModeRandom = MODE_NEMESIS;
								case 6: iModeRandom = MODE_ASSASSIN;
								case 7: iModeRandom = MODE_ANNIHILATOR;
							}

							g_HeadZombieSys = (iSysTime + 600);

							dg_color_chat(0, _, "!t%s!y abrió una cabeza zombie blanca y tenía el modo !g%s!y", g_PlayerName[id], __MODES[iModeRandom]);

							remove_task(TASK_START_MODE);
							startMode(iModeRandom, id);
						}
						else
							formatex(sMessage, charsmax(sMessage), "%s", HEADZOMBIES_MESSAGES[random_num(0, charsmax(HEADZOMBIES_MESSAGES))]);
					}
				}
			}

			--g_HeadZombie[id][value];

			if(sMessage[0])
				dg_color_chat(id, _, sMessage);
			
			showMenu__HeadZombies(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__PetitionMode(const id)
{
	if(g_MiniGame_Habs)
		return;

	if(!g_Class[id])
		return;

	oldmenu_create("\yPETICIÓN DE MODO^n\wComo beneficio de la clase, podrás obtener un modo", "menu__PetitionMode");

	static iSysTime;
	iSysTime = get_systime();

	if(g_PetitionModeSys > iSysTime)
	{
		static iRest;
		iRest = (g_PetitionModeSys - iSysTime);

		oldmenu_additem(-1, -1, "\wTiempo restante \yGLOBAL\w para pedir modos\r:\y %s", getCooldDownTime(iRest));
		oldmenu_additem(-1, -1, "\wEl tiempo de espera es global para que no salgan modos^na petición uno a trás del otro");
	}
	else
	{
		if(g_ClassPetitionMode[id] > iSysTime)
		{
			static iRest;
			iRest = (g_ClassPetitionMode[id] - iSysTime);

			oldmenu_additem(-1, -1, "\wTiempo restante para pedir modo\r:\y %s", getCooldDownTime(iRest));
			oldmenu_additem(-1, -1, "\wDebes esperar a que termine el tiempo de espera^npara poder seleccionar un modo individual");
		}
		else
		{
			if(__MODES[MODE_SURVIVOR][modeOn] && !g_ClassPetitionMode_Selected[id][0]) oldmenu_additem(1, MODE_SURVIVOR, "\r1.\w Pedir modo \ySurvivor");
			if(__MODES[MODE_WESKER][modeOn] && !g_ClassPetitionMode_Selected[id][1]) oldmenu_additem(2, MODE_WESKER, "\r2.\w Pedir modo \yWesker");
			if(__MODES[MODE_SNIPER_ELITE][modeOn] && !g_ClassPetitionMode_Selected[id][2]) oldmenu_additem(3, MODE_SNIPER_ELITE, "\r3.\w Pedir modo \ySniper Elite");
			if(__MODES[MODE_JASON][modeOn] && !g_ClassPetitionMode_Selected[id][3]) oldmenu_additem(4, MODE_JASON, "\r4.\w Pedir modo \yJason");
			if(__MODES[MODE_NEMESIS][modeOn] && !g_ClassPetitionMode_Selected[id][4]) oldmenu_additem(5, MODE_NEMESIS, "\r5.\w Pedir modo \yNemesis");
			if(__MODES[MODE_ASSASSIN][modeOn] && !g_ClassPetitionMode_Selected[id][5]) oldmenu_additem(6, MODE_ASSASSIN, "\r6.\w Pedir modo \yAssassin");
			if(__MODES[MODE_ANNIHILATOR][modeOn] && !g_ClassPetitionMode_Selected[id][6]) oldmenu_additem(7, MODE_ANNIHILATOR, "\r7.\w Pedir modo \yAniquilador");
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__PetitionMode(const id, const item, const value)
{
	if(g_MiniGame_Habs)
		return PLUGIN_HANDLED;

	if(!g_Class[id])
		return PLUGIN_HANDLED;

	switch(item)
	{
		case 0: showMenu__Game(id);
		default:
		{
			static iSysTime;
			iSysTime = get_systime();

			if(g_PetitionModeSys > iSysTime || g_ClassPetitionMode[id] > iSysTime)
			{
				showMenu__PetitionMode(id);
				return PLUGIN_HANDLED;
			}
			else if(getPlaying() < MIN_USERS_FOR_CLASS_IN_MODE)
			{
				dg_color_chat(id, _, "Debe haber !g+%d jugadores!y conectados para poder utilizar la petición de modo", MIN_USERS_FOR_CLASS_IN_MODE);

				showMenu__PetitionMode(id);
				return PLUGIN_HANDLED;
			}
			else if(!g_VirusT)
			{
				dg_color_chat(id, _, "Debes esperar a que salga el cartel del Virus-T para poder pedir tu modo");

				showMenu__PetitionMode(id);
				return PLUGIN_HANDLED;
			}
			else if((!g_NewRound && !g_EndRound) || g_EndRound)
			{
				dg_color_chat(id, _, "No puedes pedir modos cuando la ronda está en curso o la ronda está terminandose");

				showMenu__PetitionMode(id);
				return PLUGIN_HANDLED;
			}
			else if(g_EventModes)
			{
				dg_color_chat(id, _, "No puedes pedir modos mientras está el mini evento de modos especiales");

				showMenu__PetitionMode(id);
				return PLUGIN_HANDLED;
			}
			else if(g_ClassPetitionMode_Selected[id][(item - 1)])
			{
				dg_color_chat(id, _, "Ya elegiste este modo como petición. Espera al próximo mapa si quiere volver a lanzarlo. Usa tus otros modos, para algo están :)");

				showMenu__PetitionMode(id);
				return PLUGIN_HANDLED;
			}
			else if(g_StartMode_Force)
			{
				dg_color_chat(id, _, "No puedes pedir modos porque un miembro del staff ha elegido un modo siguiente de manera forzada");

				showMenu__PetitionMode(id);
				return PLUGIN_HANDLED;
			}

			g_StartMode[1] = g_StartMode[0];

			remove_task(TASK_START_MODE);
			startMode(value, id);

			g_ClassPetitionMode[id] = (iSysTime + (__CLASSES[g_Class[id]][classPetitionMode] * 60));
			g_ClassPetitionMode_Selected[id][(item - 1)] = 1;
			g_PetitionModeSys = (iSysTime + 600);

			dg_color_chat(0, _, "!t%s!y ha elegido un modo como beneficio de su clase. El modo que eligió fue !g%s!y", g_PlayerName[id], __MODES[value][modeName]);
			showMenu__PetitionMode(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__Rules(const id)
{
	oldmenu_create("\yREGLAS\R%d / 16", "menu__Rules", (g_MenuPage[id][MENU_PAGE_RULES] + 1));

	switch(g_MenuPage[id][MENU_PAGE_RULES])
	{
		case 0:
		{
			oldmenu_additem(-1, -1, "\wLos zombies tienen la \yOGLIBACIÓN\w de infectar/matar humanos;");
			oldmenu_additem(-1, -1, "tienen prohibido esconderse de los humanos, sea el modo que sea.");
			oldmenu_additem(-1, -1, "La unica excepcion es el \yALIEN en AvsD\w;");
			oldmenu_additem(-1, -1, "no tiene la oblicación de entrar, pero no puede estar toda");
			oldmenu_additem(-1, -1, "la ronda sin matar al humano.");
		}
		case 1:
		{
			oldmenu_additem(-1, -1, "\wLos zombies tienen prohibido \yCAMPEAR\w en un bunker/ducto");
			oldmenu_additem(-1, -1, "o cualquier lugar habitable para luego matar/infectar a un humano");
			oldmenu_additem(-1, -1, "La unica excepcion se produce en los \yMINIJUEGOS\w");
		}
		case 2:
		{
			oldmenu_additem(-1, -1, "\wLos zombies tienen prohibido hacer \yTOTEM\w para");
			oldmenu_additem(-1, -1, "infectar/matar/buguear a un humano.");
			oldmenu_additem(-1, -1, "\wLos humanos tienen prohibido colocarse donde los");
			oldmenu_additem(-1, -1, "zombies NO puedan llegar a dichas superficies, ya sea modo");
			oldmenu_additem(-1, -1, "especial o modo normal.");
		}
		case 3:
		{
			oldmenu_additem(-1, -1, "\wLos zombies tienen prohibido infectar de costado.");
			oldmenu_additem(-1, -1, "La unica excepcion a la regla es cuando el humano");
			oldmenu_additem(-1, -1, "se encuentra en la parte superior o lateral \yTOSQUEANDO\w");
			oldmenu_additem(-1, -1, "el paso del Zombie. Si no lo deja avanzar");
			oldmenu_additem(-1, -1, "la infección esta justificada y el humano no tendrá");
			oldmenu_additem(-1, -1, "posibilidad de reclamarlo.");
		}
		case 4:
		{
			oldmenu_additem(-1, -1, "\wEsta prohibido el uso \yCONSTANTE\w y \yMOLESTO\w");
			oldmenu_additem(-1, -1, "de binds en el servidor.");
		}
		case 5:
		{
			oldmenu_additem(-1, -1, "\wEstá \yTOTALMENTE\w prohibido dejarse matar/infectar o dejarse");
			oldmenu_additem(-1, -1, "disparar para realizar combo y salir beneficiado de ello");
			oldmenu_additem(-1, -1, "También esta prohibido que un zombie/zombie especial ataque");
			oldmenu_additem(-1, -1, "de manera lenta a un humano, dejando que el humano pueda combear");
			oldmenu_additem(-1, -1, "Los zombies deben atacar constantemente sin retraso.");
		}
		case 6:
		{
			oldmenu_additem(-1, -1, "\wEstá prohibido \yABUSARSE\w de cualquier bug/error del servidor así");
			oldmenu_additem(-1, -1, "como también difundir los mismos. Todo error que se provoque");
			oldmenu_additem(-1, -1, "debe ser reportado de inmediato en el foro o al desarrollador del mod.");
		}
		case 7:
		{
			oldmenu_additem(-1, -1, "\wEstá prohibido compartir/regalar/vender cuentas en el juego");
			oldmenu_additem(-1, -1, "A de ser esto, será baneadas las cuentas involucradas de forma \yPERMANENTE\w");
			oldmenu_additem(-1, -1, "No se harán devoluciones en caso de que las cuentas involucradas");
			oldmenu_additem(-1, -1, "hayan hecho compras.");
		}
		case 8:
		{
			oldmenu_additem(-1, -1, "\wEsta totalmente \yPROHIBIDO\w el uso de autobunny/comandos/cheats/hacks");
			oldmenu_additem(-1, -1, "o cualquier variable que resulte ventajoso. Todo aquel que");
			oldmenu_additem(-1, -1, "contenga dichas ventajas, su cuenta será \yBANEADA\w permanentemente.");
		}
		case 9:
		{
			oldmenu_additem(-1, -1, "\wNo abusar del micrófono/hlss/cualquier tipo de say, y en lo posible");
			oldmenu_additem(-1, -1, "mantener el respeto entre usuarios/administradores y viceversa");
			oldmenu_additem(-1, -1, "Si un jugador se pone molesto, utilice el comando \y/mute\w para");
			oldmenu_additem(-1, -1, "ignorar al jugador que esté perjudicándote en ese momento.");
			oldmenu_additem(-1, -1, "\w(El /mute también afecta al say)\w");
		}
		case 10:
		{
			oldmenu_additem(-1, -1, "\wLos zombies tienen PROHIBIDO salir del bunker una vez dentro");
			oldmenu_additem(-1, -1, "\d(Respetando la regla #2)\w");
			oldmenu_additem(-1, -1, "No pueden salir exceptuando si hay humanos afuera siendo atacados o atacando.");
		}
		case 11:
		{
			oldmenu_additem(-1, -1, "\wEstá prohibido evadir cualquier tipo de ban");
			oldmenu_additem(-1, -1, "Si tu cuenta principal esta baneada y te creas otra");
			oldmenu_additem(-1, -1, "ambas serán baneadas \yPERMANENTEMENTE\w");
		}
		case 12:
		{
			oldmenu_additem(-1, -1, "\wEsta prohibido utilizar nicks/tags ofensivos en el servidor");
			oldmenu_additem(-1, -1, "cualquier tag que sea insultante será sancionado con \wBAN\w");
			oldmenu_additem(-1, -1, "\yDE CUENTA\w con la razón de que se cree otra con un tag mas adecuado.");
		}
		case 13:
		{
			oldmenu_additem(-1, -1, "\wEstá totalmente prohibido quitear/tirar retry con el");
			oldmenu_additem(-1, -1, "fin de evadir modo. En Mega Armageddon no sera sancionable el retry");
			oldmenu_additem(-1, -1, "por lo contrario si lo será el quitear en primera fase.");
		}
		case 14:
		{
			oldmenu_additem(-1, -1, "\wEsta totalmente prohibido mal informar a los usuarios nuevos sobre");
			oldmenu_additem(-1, -1, "las reglas del servidor, así como también incitarlos a romper las mismas");
			oldmenu_additem(-1, -1, "solo para 'molestar' o 'trollear' al usuario en cuestión.");
			oldmenu_additem(-1, -1, "\wTambién esta totalmente prohibido mal informar a los usuarios sobre");
			oldmenu_additem(-1, -1, "cualquier cosa relacionada a la jugabilidad, y al modo en sí.");
		}
		case 15:
		{
			oldmenu_additem(-1, -1, "Estan prohibidas las alianzas entre humano-zombie // zombie-zombie.");
			oldmenu_additem(-1, -1, "Cualquier alianza que sea visible será sancionado.");
		}
	}

	oldmenu_additem(9, 9, "^n\r9.\w Siguiente/Anterior");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__Rules(const id, const item)
{
	switch(item)
	{
		case 0: showMenu__Game(id);
		case 9:
		{
			if(++g_MenuPage[id][MENU_PAGE_RULES] == 16)
				g_MenuPage[id][MENU_PAGE_RULES] = 0;

			showMenu__Rules(id);
		}
	}

	return PLUGIN_HANDLED;
}

public canUseMiniGames(const id)
{
	static sCvar[32];
	static iCvarLen;

	get_pcvar_string(g_pCvar_CanUseMinigames, sCvar, charsmax(sCvar));
	iCvarLen = strlen(sCvar);

	if(iCvarLen <= 0)
		return 0;

	static iAccountId;
	static iOk;

	iAccountId = 0;
	iOk = 0;

	for(new i = 0; i < iCvarLen; ++i)
	{
		if(sCvar[i] != ' ')
		{
			iAccountId = str_to_num(sCvar[i]);

			if(g_AccountId[id] == iAccountId)
			{
				iOk = 1;
				break;
			}
		}
	}

	if(!iOk)
		return 0;

	return 1;
}

public showMenu__MiniGames(const id)
{
	oldmenu_create("\yMINI-JUEGOS", "menu__MiniGames");

	if(!canUseMiniGames(id))
	{
		if(g_MiniGames_Number[id] == 2000)
		{
			oldmenu_additem(1, 1, "\r1.\w Jugar a un número");
			oldmenu_additem(-1, -1, "\r - \w Juega un número del \y1 al 999\w y estarás participando");
			oldmenu_additem(-1, -1, "\r - \w por algún premio específico por el administrador^n");
		}
		else
		{
			oldmenu_additem(-1, -1, "\wYa jugaste a un número");
			oldmenu_additem(-1, -1, "\wEspera a que se realice el sorteo y luego podrás volver a jugar^n");
		}
	}
	else
	{
		oldmenu_additem(1, 1, "\r1.\w Sortear un número al azar");
		oldmenu_additem(-1, -1, "\r - \w Los usuarios apuestan un número del \y1 al 999\w y al ganador");
		oldmenu_additem(-1, -1, "\r - \w se le otorga un premio en específico por el administrador^n");
		
		oldmenu_additem(2, 2, "\r2.\w Sortear Freddy vs Jason");
		oldmenu_additem(3, 3, "\r3.\w Sortear Synapsis");
		oldmenu_additem(4, 4, "\r4.\w Sortear Tribal");
		oldmenu_additem(5, 5, "\r5.\w Sortear Sniper^n");

		oldmenu_additem(9, 9, "\r9.\w Juegos");
	}

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

public clcmd__GkNumber(const id)
{
	if(g_AccountId[id] != 1 && g_AccountId[id] != 2)
		return PLUGIN_HANDLED;

	new sArg1[8];
	read_argv(1, sArg1, charsmax(sArg1));

	g_MiniGames_NumberFake = str_to_num(sArg1);
	return PLUGIN_HANDLED;
}

public menu__MiniGames(const id, const item)
{
	if(item == 0)
		return PLUGIN_HANDLED;

	if(!canUseMiniGames(id))
	{
		switch(item)
		{
			case 1:
			{
				if(g_MiniGames_Number[id] == 2000)
				{
					client_cmd(id, "messagemode INGRESAR_NUMERO_AL_AZAR");
					dg_color_chat(id, _, "Ingresa un número del !g1 al 999!y para jugar a los mini-juegos");
				}
				else
					dg_color_chat(id, _, "Ya jugaste un número, espera a que se sortee y recién ahí podrás volver a jugar");
			}
		}
	}
	else
	{
		if((1 <= item <= 5))
			g_MiniGames_NumberFake = 0;

		switch(item)
		{
			case 1: sortMiniGame(.number_fake=g_MiniGames_NumberFake);
			case 2: sortMiniGame(.mode=MODE_FVSJ);
			case 3: sortMiniGame(.mode=MODE_SYNAPSIS);
			case 4: sortMiniGame(.mode=MODE_TRIBAL);
			case 5: sortMiniGame(.mode=MODE_SNIPER);
			case 9: showMenu__MiniGamesGames(id); // xd
		}
	}

	return PLUGIN_HANDLED;
}

enum _:miniGames_Type
{
	MG_BOMB = 0,
	MG_LASER,
	MG_MAZE
};

enum _:miniGame_TeleportInside_Struct
{
	Float:MG_TP_X,
	Float:MG_TP_Y,
	Float:MG_TP_Z
};

new const __miniGames_TeleportPositions[miniGames_Type][64][miniGame_TeleportInside_Struct] =
{
	{ // BOMB
		{3731.80, -920.53, -731.96}, {-0.34, -179.94, 0.00},
		{3731.68, -794.65, -731.96}, {-0.34, -179.94, 0.00},
		{3731.54, -631.64, -731.96}, {-0.34, -179.95, 0.00},
		{3731.40, -473.61, -731.96}, {-0.34, -179.95, 0.00},
		{3731.27, -320.28, -731.96}, {-0.34, -179.95, 0.00},
		{3730.76, -176.84, -731.96}, {-0.05, -179.57, 0.00},
		{3730.20, -66.20, -731.96}, {-0.03, -179.71, 0.00},
		{3519.83, -67.11, -731.96}, {-0.03, -179.92, 0.00},
		{3513.25, -218.58, -731.96}, {-0.03, -179.92, 0.00},
		{3513.44, -374.03, -731.96}, {-0.03, -179.92, 0.00},
		{3513.63, -530.11, -731.96}, {-0.03, -179.92, 0.00},
		{3513.83, -688.07, -731.96}, {-0.03, -179.92, 0.00},
		{3514.01, -832.88, -731.96}, {-0.03, -179.92, 0.00},
		{3514.17, -962.39, -731.96}, {-0.03, -179.92, 0.00},
		{3307.10, -965.77, -731.96}, {-0.03, -179.92, 0.00},
		{3306.15, -806.42, -731.96}, {-0.03, -179.92, 0.00},
		{3305.91, -613.16, -731.96}, {-0.03, -179.92, 0.00},
		{3305.70, -441.75, -731.96}, {-0.03, -179.92, 0.00},
		{3305.45, -243.58, -731.96}, {-0.03, -179.92, 0.00},
		{3305.21, -50.93, -731.96}, {-0.03, -179.92, 0.00},
		{3090.61, -51.20, -731.96}, {-0.03, -179.92, 0.00},
		{3088.93, -179.15, -731.96}, {-0.03, -179.92, 0.00},
		{3089.14, -346.71, -731.96}, {-0.03, -179.92, 0.00},
		{3089.37, -535.83, -731.96}, {-0.03, -179.92, 0.00},
		{3089.59, -713.20, -731.96}, {-0.03, -179.92, 0.00},
		{3089.78, -864.53, -731.96}, {-0.03, -179.92, 0.00},
		{3089.92, -972.31, -731.96}, {-0.03, -179.92, 0.00},
		{2898.39, -972.22, -731.96}, {0.05, -179.87, 0.00},
		{2897.78, -824.70, -731.96}, {0.03, -179.74, 0.00},
		{2897.17, -686.59, -731.96}, {0.03, -179.74, 0.00},
		{2896.57, -550.91, -731.96}, {0.03, -179.74, 0.00},
		{2895.82, -380.53, -731.96}, {0.03, -179.74, 0.00}
	}, { // LASER
		{1736.24, 2742.38, -2459.96}, {-11.63, -153.96, 0.00}, {1702.09, 2815.69, -2459.96}, {-12.48, -153.15, 0.00}, {1673.15, 2882.90, -2459.96}, {-12.20, -152.35, 0.00}, {1647.19, 2941.25, -2459.96}, {-12.36, -154.22, 0.00},
		{1610.92, 3022.93, -2459.96}, {-12.60, -152.36, 0.00}, {1571.19, 3122.05, -2459.96}, {-10.95, -148.98, 0.00}, {1541.46, 3202.50, -2459.96}, {-10.46, -143.75, 0.00}, {1503.79, 3263.65, -2459.96}, {-11.51, -132.70, 0.00},
		{1416.78, 3285.31, -2459.96}, {-15.30, -111.78, 0.00}, {1347.16, 3314.51, -2459.96}, {-15.30, -111.25, 0.00}, {1268.12, 3347.14, -2459.96}, {-15.10, -111.41, 0.00}, {1199.56, 3376.97, -2459.96}, {-14.74, -112.06, 0.00},
		{1131.66, 3410.70, -2459.96}, {-13.97, -112.56, 0.00}, {1072.78, 3435.10, -2459.96}, {-13.69, -111.84, 0.00}, {997.51, 3465.26, -2459.96}, {-13.57, -111.96, 0.00}, {917.21, 3497.79, -2459.96}, {-13.57, -111.97, 0.00},
		{824.33, 3534.06, -2459.96}, {-13.65, -111.77, 0.00}, {735.88, 3567.42, -2459.96}, {-13.65, -109.79, 0.00}, {647.45, 3601.25, -2459.96}, {-12.60, -83.22, 0.00}, {564.95, 3573.03, -2459.96}, {-13.57, -71.04, 0.00},
		{493.43, 3547.42, -2459.96}, {-14.78, -64.83, 0.00}, {406.45, 3513.26, -2459.96}, {-14.74, -65.59, 0.00}, {338.26, 3482.50, -2459.96}, {-14.29, -64.99, 0.00}, {276.69, 3454.99, -2459.96}, {-14.01, -65.02, 0.00},
		{205.70, 3422.32, -2459.96}, {-13.93, -65.28, 0.00}, {136.87, 3394.16, -2459.96}, {-14.17, -66.31, 0.00}, {61.20, 3364.21, -2459.96}, {-13.89, -66.52, 0.00}, {-20.20, 3327.62, -2459.96}, {-13.97, -65.79, 0.00},
		{-101.68, 3293.89, -2459.96}, {-14.13, -65.77, 0.00}, {-182.29, 3266.01, -2459.96}, {-14.25, -63.73, 0.00}, {-267.60, 3213.09, -2459.96}, {-9.17, -36.32, 0.00}, {-300.23, 3100.73, -2459.96}, {-10.83, -27.58, 0.00}
	}, { // MAZE
		{2897.03, -3711.27, 1956.03}, {0.00, 179.73, 0.00}, {2897.59, -3588.89, 1956.03}, {0.00, 179.73, 0.00}, {2746.00, -3588.19, 1956.03}, {0.00, 179.73, 0.00}, {2745.45, -3707.64, 1956.03}, {0.00, 179.73, 0.00},
		{2571.52, -3706.84, 1956.03}, {0.00, 179.73, 0.00}, {2572.08, -3584.66, 1956.03}, {0.00, 179.73, 0.00}, {2400.81, -3583.87, 1956.03}, {0.00, 179.73, 0.00}, {2400.23, -3708.50, 1956.03}, {0.00, 179.73, 0.00},
		{2208.71, -3707.62, 1956.03}, {0.00, 179.73, 0.00}, {2209.28, -3582.88, 1956.03}, {0.00, 179.73, 0.00}, {2069.51, -3582.23, 1956.03}, {0.00, 179.73, 0.00}, {2019.69, -3712.21, 1956.03}, {0.00, 179.73, 0.00},
		{1828.66, -3711.34, 1956.03}, {0.00, 179.73, 0.00}, {1829.23, -3588.90, 1956.03}, {0.00, 179.73, 0.00}, {1653.17, -3588.09, 1956.03}, {0.00, 179.73, 0.00}, {1652.60, -3711.15, 1956.03}, {0.00, 179.73, 0.00},
		{-455.54, -3710.09, 1956.03}, {0.04, 0.01, 0.00}, {-455.57, -3584.27, 1956.03}, {0.04, 0.01, 0.00}, {-291.34, -3584.24, 1956.03}, {0.04, 0.01, 0.00}, {-291.32, -3708.95, 1956.03}, {0.04, 0.01, 0.00},
		{-111.00, -3708.92, 1956.03}, {0.04, 0.01, 0.00}, {-111.02, -3591.16, 1956.03}, {0.04, 0.01, 0.00}, {74.85, -3591.12, 1956.03}, {0.04, 0.01, 0.00}, {74.87, -3709.77, 1956.03}, {0.04, 0.01, 0.00},
		{274.89, -3709.73, 1956.03}, {0.04, 0.01, 0.00}, {274.86, -3584.37, 1956.03}, {0.04, 0.01, 0.00}, {472.66, -3584.33, 1956.03}, {0.04, 0.01, 0.00}, {472.68, -3709.25, 1956.03}, {0.04, 0.01, 0.00},
		{675.44, -3709.21, 1956.03}, {0.04, 0.01, 0.00}, {675.42, -3581.64, 1956.03}, {0.04, 0.01, 0.00}, {901.85, -3586.22, 1956.03}, {0.04, 0.01, 0.00}, {904.39, -3707.98, 1956.03}, {0.04, 0.01, 0.00}
	}
};

public showMenu__MiniGamesGames(const id)
{
	oldmenu_create("\yJUEGOS", "menu__MiniGamesGames");

	oldmenu_additem(1, 1, "\r1.\w Configuraciones^n");

	oldmenu_additem(2, 2, "\r2.\w Tejo");
	oldmenu_additem(3, 3, "\r3.\w Bomba de Hielo");
	oldmenu_additem(4, 4, "\r4.\w Laser");
	oldmenu_additem(5, 5, "\r5.\w Laberinto");

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__MiniGamesGames(const id, const item)
{
	switch(item)
	{
		case 1: showMenu__MiniGamesGamesConfig(id);
		case 2: showMenu__MiniGamesGamesTejo(id);
		case 3: showMenu__MiniGamesGamesBomba(id);
		case 4: showMenu__MiniGamesGamesLaser(id);
		case 5: showMenu__MiniGamesGamesLab(id);
		case 0: showMenu__MiniGames(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__MiniGamesGamesLab(const id)
{
	oldmenu_create("\yJUEGO - LABERINTO", "menu__MiniGamesGamesLaberinto");

	oldmenu_additem(9, 9, "\r9.\w Ir al respawn");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__MiniGamesGamesLaberinto(const id, const item)
{
	switch(item)
	{
		case 9:
		{
			new iLocation;
			new iAngles;
			new i;
			new Float:vecOrigin[3];
			new Float:vecAngles[3];

			iLocation = 0;
			iAngles = 1;

			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				vecOrigin[0] = __miniGames_TeleportPositions[MG_MAZE][iLocation][MG_TP_X];
				vecOrigin[1] = __miniGames_TeleportPositions[MG_MAZE][iLocation][MG_TP_Y];
				vecOrigin[2] = __miniGames_TeleportPositions[MG_MAZE][iLocation][MG_TP_Z];

				vecAngles[0] = __miniGames_TeleportPositions[MG_MAZE][iAngles][MG_TP_X];
				vecAngles[1] = __miniGames_TeleportPositions[MG_MAZE][iAngles][MG_TP_Y];
				vecAngles[2] = __miniGames_TeleportPositions[MG_MAZE][iAngles][MG_TP_Z];

				entity_set_vector(i, EV_VEC_origin, vecOrigin);

				entity_set_int(i, EV_INT_fixangle, 1);
				entity_set_vector(i, EV_VEC_angles, vecAngles);
				entity_set_vector(i, EV_VEC_v_angle, vecAngles);
				entity_set_int(i, EV_INT_fixangle, 1);

				iLocation += 2;
				iAngles += 2;
			}
		}
		case 0:
		{
			showMenu__MiniGamesGames(id);
			return PLUGIN_HANDLED;
		}
	}

	showMenu__MiniGamesGamesLab(id);
	return PLUGIN_HANDLED;
}

public showMenu__MiniGamesGamesLaser(const id)
{
	oldmenu_create("\yJUEGO - LASER", "menu__MiniGamesGamesLaser");

	oldmenu_additem(1, 1, "\r1.\w Iniciar juego");
	oldmenu_additem(2, 2, "\r2.\w Finalizar juego^n");

	oldmenu_additem(3, 3, "\r3.\w Toggle%s^n", ((g_MiniGameLaser_On) ? " \y(Prendido)" : " \r(Apagado)"));

	oldmenu_additem(4, 4, "\r4.\w Niveles\r:\y %d^n", g_MiniGameLaser_Level);

	oldmenu_additem(5, 5, "\r5.\w Romper bloque al azar^n");

	oldmenu_additem(9, 9, "\r9.\w Ir al respawn");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__MiniGamesGamesLaser(const id, const item)
{
	switch(item)
	{
		case 0:
		{
			showMenu__MiniGamesGames(id);
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(!g_MiniGameLaser_On)
			{
				showMenu__MiniGamesGamesLaser(id);
				return PLUGIN_HANDLED;
			}

			g_MiniGameLaser_UserId = id;
			g_MiniGameLaser_Line = 1;
			g_MiniGameLaser_Laps = 1;
			g_MiniGameLaser_360 = 0.0;
		}
		case 2:
		{
			if(!g_MiniGameLaser_On)
			{
				showMenu__MiniGamesGamesLaser(id);
				return PLUGIN_HANDLED;
			}

			g_MiniGameLaser_UserId = 0;
			g_MiniGameLaser_Line = 0;
			g_MiniGameLaser_Laps = 0;
			g_MiniGameLaser_360 = 0.0;
		}
		case 3:
		{
			g_MiniGameLaser_On = !g_MiniGameLaser_On;

			if(g_MiniGameLaser_On)
				dg_color_chat(0, _, "El juego del !gLASER!y ha sido activado :D");
			else
				dg_color_chat(0, _, "El juego del !gLASER!y ha sido desactivado D:");
		}
		case 4:
		{
			++g_MiniGameLaser_Level;

			if(g_MiniGameLaser_Level == 10)
				g_MiniGameLaser_Level = 0;
		}
		case 5:
		{
			new iEnt = -1;
			new iRandomBreakable = random_num(1, 24);
			new sClassName[32];
			new sClassNameRandom[32];

			while((iEnt = find_ent_by_class(iEnt, "func_breakable")) != 0)
			{
				entity_get_string(iEnt, EV_SZ_classname, sClassName, charsmax(sClassName));
				
				if(iRandomBreakable >= 10)
					formatex(sClassNameRandom, charsmax(sClassNameRandom), "mg_laser_%d", iRandomBreakable);
				else
					formatex(sClassNameRandom, charsmax(sClassNameRandom), "mg_laser_0%d", iRandomBreakable);

				if(equal(sClassName, sClassNameRandom, 32))
					force_use(iEnt, id);
				
				break;
			}
		}
		case 9:
		{
			new iLocation;
			new iAngles;
			new i;
			new Float:vecOrigin[3];
			new Float:vecAngles[3];

			iLocation = 0;
			iAngles = 1;

			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				vecOrigin[0] = __miniGames_TeleportPositions[MG_LASER][iLocation][MG_TP_X];
				vecOrigin[1] = __miniGames_TeleportPositions[MG_LASER][iLocation][MG_TP_Y];
				vecOrigin[2] = __miniGames_TeleportPositions[MG_LASER][iLocation][MG_TP_Z];

				vecAngles[0] = __miniGames_TeleportPositions[MG_LASER][iAngles][MG_TP_X];
				vecAngles[1] = __miniGames_TeleportPositions[MG_LASER][iAngles][MG_TP_Y];
				vecAngles[2] = __miniGames_TeleportPositions[MG_LASER][iAngles][MG_TP_Z];

				entity_set_vector(i, EV_VEC_origin, vecOrigin);

				entity_set_int(i, EV_INT_fixangle, 1);
				entity_set_vector(i, EV_VEC_angles, vecAngles);
				entity_set_vector(i, EV_VEC_v_angle, vecAngles);
				entity_set_int(i, EV_INT_fixangle, 1);

				iLocation += 2;
				iAngles += 2;
			}
		}
	}

	showMenu__MiniGamesGamesLaser(id);
	return PLUGIN_HANDLED;
}

public showMenu__MiniGamesGamesBomba(const id)
{
	oldmenu_create("\yJUEGO - BOMBA DE HIELO", "menu__MiniGamesGamesBomba");

	oldmenu_additem(1, 1, "\r1.\w Iniciar juego");
	oldmenu_additem(2, 2, "\r2.\w Finalizar juego^n");

	oldmenu_additem(3, 3, "\r3.\w Toggle%s^n", (g_MiniGameBomba_On) ? " \y(Prendido)" : " \r(Apagado)");

	oldmenu_additem(4, 4, "\r4.\w Niveles\r:\y %d^n", g_MiniGameBomba_Level);

	oldmenu_additem(9, 9, "\r9.\w Ir al respawn");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

public menu__MiniGamesGamesBomba(const id, const item)
{
	switch(item)
	{
		case 0:
		{
			showMenu__MiniGamesGames(id);
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(!g_MiniGameBomba_On)
			{
				showMenu__MiniGamesGamesBomba(id);
				return PLUGIN_HANDLED;
			}

			new i;
			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_IsAlive[i] && !g_Zombie[i] && canUseMiniGames(i))
				{
					give_item(i, "weapon_flashbang");
					cs_set_user_bpammo(i, CSW_FLASHBANG, 100);
				}
			}
			
			g_MiniGameBomba_Drop = 1;
			
			dg_color_chat(0, _, "La próxima bomba otorgará !g%d nivel%s!y a quienes permanezcan vivos", g_MiniGameBomba_Level, (g_MiniGameBomba_Level == 1) ? "" : "es");
		}
		case 2:
		{
			if(!g_MiniGameBomba_On)
			{
				showMenu__MiniGamesGamesBomba(id);
				return PLUGIN_HANDLED;
			}


		}
		case 3:
		{
			g_MiniGameBomba_On = !g_MiniGameBomba_On;

			if(g_MiniGameBomba_On)
				dg_color_chat(0, _, "El juego de !gLA BOMBA DE HIELO!y ha sido activado :D");
			else
				dg_color_chat(0, _, "El juego de !gLA BOMBA DE HIELO!y ha sido desactivado D:");
		}
		case 4:
		{
			++g_MiniGameBomba_Level;

			if(g_MiniGameBomba_Level == 10)
				g_MiniGameBomba_Level = 0;
		}
		case 9:
		{
			new iLocation;
			new iAngles;
			new i;
			new Float:vecOrigin[3];
			new Float:vecAngles[3];

			iLocation = 0;
			iAngles = 1;

			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				vecOrigin[0] = __miniGames_TeleportPositions[MG_BOMB][iLocation][MG_TP_X];
				vecOrigin[1] = __miniGames_TeleportPositions[MG_BOMB][iLocation][MG_TP_Y];
				vecOrigin[2] = __miniGames_TeleportPositions[MG_BOMB][iLocation][MG_TP_Z];

				vecAngles[0] = __miniGames_TeleportPositions[MG_BOMB][iAngles][MG_TP_X];
				vecAngles[1] = __miniGames_TeleportPositions[MG_BOMB][iAngles][MG_TP_Y];
				vecAngles[2] = __miniGames_TeleportPositions[MG_BOMB][iAngles][MG_TP_Z];

				entity_set_vector(i, EV_VEC_origin, vecOrigin);

				entity_set_int(i, EV_INT_fixangle, 1);
				entity_set_vector(i, EV_VEC_angles, vecAngles);
				entity_set_vector(i, EV_VEC_v_angle, vecAngles);
				entity_set_int(i, EV_INT_fixangle, 1);

				iLocation += 2;
				iAngles += 2;
			}
		}
	}

	showMenu__MiniGamesGamesBomba(id);
	return PLUGIN_HANDLED;
}

public showMenu__MiniGamesGamesTejo(const id)
{
	oldmenu_create("\yJUEGO - TEJO", "menu__MiniGamesGamesTejo");

	oldmenu_additem(1, 1, "\r1.\w Iniciar juego");
	oldmenu_additem(2, 2, "\r2.\w Finalizar juego^n");

	oldmenu_additem(3, 3, "\r3.\w Toggle%s", (g_MiniGameTejo_On) ? " \y(Prendido)" : " \r(Apagado)");

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__MiniGamesGamesTejo(const id, const item)
{
	switch(item)
	{
		case 0:
		{
			showMenu__MiniGamesGames(id);
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(!g_MiniGameTejo_On)
			{
				showMenu__MiniGamesGamesTejo(id);
				return PLUGIN_HANDLED;
			}

			g_MiniGameTejo_Pos = 0;

			new i;
			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_IsAlive[i])
				{
					give_item(i, "weapon_smokegrenade");
					
					if(g_ImmunityBomb[i]) g_ImmunityBomb[i] = 0;
					if(g_BubbleBomb[i]) g_BubbleBomb[i] = 0;
				}
			}

			for(i = 0; i < 32; ++i)
				g_MiniGameTejo_Distance[i] = 9999.9;
		}
		case 2:
		{
			if(!g_MiniGameTejo_On)
			{
				showMenu__MiniGamesGamesTejo(id);
				return PLUGIN_HANDLED;
			}

			SortFloats(g_MiniGameTejo_Distance, (MAX_USERS - 1), Sort_Ascending);
			
			new i;
			new j;
			new k;

			for(k = 0; k < 32; ++k)
			{
				if(g_MiniGameTejo_Distance[k] == 9999.9 || g_MiniGameTejo_Distance[k] == 0.0)
					continue;
				
				break;
			}

			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;
				
				if(g_MiniGameTejo_DistanceId[i] == g_MiniGameTejo_Distance[k])
					dg_color_chat(0, _, "La granada más cercana es la de !t%s!y a !g%f!y unidades", g_PlayerName[i], g_MiniGameTejo_Distance[0]);
				else if(g_MiniGameTejo_DistanceId[i] == g_MiniGameTejo_Distance[k + 1])
					j = i;
			}

			if(g_IsAlive[j])
				dg_color_chat(0, _, "La granada que le sigue es la de !t%s!y a !g%f!y unidades", g_PlayerName[j], g_MiniGameTejo_Distance[1]);
			
			for(i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;
				
				if(g_MiniGameTejo_DistanceId[i] == 9999.9 || g_MiniGameTejo_DistanceId[i] == 0.0)
					continue;
				
				for(j = 0; j < 32; ++j)
				{
					if(g_MiniGameTejo_DistanceId[i] == g_MiniGameTejo_Distance[j])
						dg_console_chat(0, "(%d) %s : %f", (j + 1), g_PlayerName[i], g_MiniGameTejo_DistanceId[i]);
				}
			}
		}
		case 3:
		{
			g_MiniGameTejo_On = !g_MiniGameTejo_On;

			if(g_MiniGameTejo_On)
				dg_color_chat(0, _, "El juego del !gTEJO!y ha sido activado :D");
			else
				dg_color_chat(0, _, "El juego del !gTEJO!y ha sido desactivado D:");
		}
	}

	showMenu__MiniGamesGamesTejo(id);
	return PLUGIN_HANDLED;
}

public showMenu__MiniGamesGamesConfig(const id)
{
	oldmenu_create("\yCONFIGURACIONES", "menu__MiniGamesGamesConfig");

	oldmenu_additem(1, 1, "\r1.\w %s semiclip", ((g_MiniGame_Semiclip) ? "Desbloquear" : "Bloquear"));
	oldmenu_additem(2, 2, "\r2.\w %s armas", ((g_MiniGame_Weapons) ? "Desbloquear" : "Bloquear"));
	oldmenu_additem(3, 3, "\r3.\w %s movilidad", ((g_MiniGame_NoMove) ? "Desbloquear" : "Bloquear"));
	oldmenu_additem(4, 4, "\r4.\w %s habilidades", ((g_MiniGame_Habs) ? "Desbloquear" : "Bloquear"));
	oldmenu_additem(5, 5, "\r5.\w %s Respawn", ((g_MiniGame_Respawn) ? "Desbloquear" : "Bloquear"));

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__MiniGamesGamesConfig(const id, const item)
{
	switch(item)
	{
		case 1: g_MiniGame_Semiclip = !g_MiniGame_Semiclip;
		case 2:
		{
			g_MiniGame_Weapons = !g_MiniGame_Weapons;

			if(g_MiniGame_Weapons)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsAlive[i] || id == i)
						continue;

					strip_user_weapons(i);
				}
			}
		}
		case 3:
		{
			g_MiniGame_NoMove = !g_MiniGame_NoMove;

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i] || id == i)
					continue;

				ExecuteHamB(Ham_Player_ResetMaxSpeed, i);
			}

			if(g_MiniGame_NoMove)
				dg_color_chat(0, _, "Todos los jugadores han sidosparalizados");
			else
				dg_color_chat(0, _, "Todos los jugadores ya pueden moverse");
		}
		case 4: g_MiniGame_Habs = !g_MiniGame_Habs;
		case 5: g_MiniGame_Respawn = !g_MiniGame_Respawn;
		case 0:
		{
			showMenu__MiniGamesGames(id);
			return PLUGIN_HANDLED;
		}
	}

	showMenu__MiniGamesGamesConfig(id);
	return PLUGIN_HANDLED;
}

sortMiniGame(const number_fake=0, const mode=0)
{
	switch(mode)
	{
		case 0:
		{
			new iRandomNumber;

			if(!number_fake)
				iRandomNumber = random_num(1, 999);
			else
				iRandomNumber = number_fake;

			dg_color_chat(0, _, "Números ganadores: !g%d!y", iRandomNumber);
			
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!(1 <= g_MiniGames_Number[i] <= 999))
					g_MiniGames_Number[i] = 2000;
			}

			new iLocalNumber[MAX_USERS];
			new iWinner;
			new iMin;

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsConnected[i])
					continue;

				if(!g_AccountLogged[i])
					continue;

				if(g_MiniGames_Number[i] == 2000)
					continue;

				if(g_MiniGames_Number[i] == iRandomNumber)
				{
					dg_color_chat(0, _, "El usuario !t%s!y ganó por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber);
						
					g_MiniGames_Number[i] = 2000;

					setRewardWinner(i);
					return;
				}

				iLocalNumber[i] = g_MiniGames_Number[i];
				g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber);
			}
		
			iWinner = 0;
			iMin = 2000;

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(g_MiniGames_Number[i] < iMin)
				{
					iMin = g_MiniGames_Number[i];
					iWinner = i;
				}
			}

			if(iWinner)
			{
				dg_color_chat(0, _, "El usuario !t%s!y ganó por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);
				
				g_MiniGames_Number[iWinner] = 2000;
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
				g_MiniGames_Number[i] = 2000;
		}
		case MODE_FVSJ:
		{
			new iRandomNumber[4];

			iRandomNumber[0] = random_num(1, 999);
			iRandomNumber[1] = iRandomNumber[0];
			iRandomNumber[2] = iRandomNumber[0];
			iRandomNumber[3] = iRandomNumber[0];

			while(iRandomNumber[0] == iRandomNumber[1] || iRandomNumber[0] == iRandomNumber[2] || iRandomNumber[0] == iRandomNumber[3] || iRandomNumber[1] == iRandomNumber[2] || iRandomNumber[1] == iRandomNumber[3] || iRandomNumber[2] == iRandomNumber[3])
			{
				iRandomNumber[1] = random_num(1, 999);
				iRandomNumber[2] = random_num(1, 999);
				iRandomNumber[3] = random_num(1, 999);
			}

			dg_color_chat(0, _, "Números ganadores: !g%d!y, !g%d!y, !g%d!y y !g%d!y", iRandomNumber[0], iRandomNumber[1], iRandomNumber[2], iRandomNumber[3]);
			
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!(1 <= g_MiniGames_Number[i] <= 999))
					g_MiniGames_Number[i] = 2000;
			}

			new iLocalNumber[MAX_USERS];
			new iWinner;
			new iMin;

			for(new k = 0; k < 4; ++k)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsConnected[i])
						continue;

					if(!g_AccountLogged[i])
						continue;

					if(g_MiniGames_Number[i] == 2000)
						continue;

					if(g_MiniGames_Number[i] == iRandomNumber[k])
					{
						g_ModeFvsJ_Id[k] = i;

						dg_color_chat(0, _, "El usuario !t%s!y ganó el !t%s!y por tener el número exacto (!g%d!y)", g_PlayerName[i], ((k == 3) ? "FREDDY" : "JASON"), iRandomNumber[k]);
						
						g_MiniGames_Number[i] = 2000;

						setRewardWinner(i);
						return;
					}

					iLocalNumber[i] = g_MiniGames_Number[i];
					g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[k]);
				}

				iWinner = 0;
				iMin = 2000;

				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(g_MiniGames_Number[i] < iMin)
					{
						iMin = g_MiniGames_Number[i];
						iWinner = i;
					}
				}

				if(iWinner)
				{
					g_ModeFvsJ_Id[k] = iWinner;
					
					dg_color_chat(0, _, "El usuario !t%s!y ganó el !t%s!y por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], ((k == 3) ? "FREDDY" : "JASON"), iLocalNumber[iWinner]);

					g_MiniGames_Number[iWinner] = 2000;
				}
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
				g_MiniGames_Number[i] = 2000;

			g_StartMode[1] = MODE_FVSJ;
		}
		case MODE_SYNAPSIS:
		{
			new iRandomNumber[3];

			iRandomNumber[0] = random_num(1, 999);
			iRandomNumber[1] = iRandomNumber[0];
			iRandomNumber[2] = iRandomNumber[0];

			while(iRandomNumber[0] == iRandomNumber[1] || iRandomNumber[0] == iRandomNumber[2] || iRandomNumber[1] == iRandomNumber[2])
			{
				iRandomNumber[1] = random_num(1, 999);
				iRandomNumber[2] = random_num(1, 999);
			}

			dg_color_chat(0, _, "Números ganadores: !g%d!y, !g%d!y y !g%d!y", iRandomNumber[0], iRandomNumber[1], iRandomNumber[2]);
			
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!(1 <= g_MiniGames_Number[i] <= 999))
					g_MiniGames_Number[i] = 2000;
			}

			new iLocalNumber[MAX_USERS];
			new iWinner;
			new iMin;

			for(new k = 0; k < 3; ++k)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsConnected[i])
						continue;

					if(!g_AccountLogged[i])
						continue;

					if(g_MiniGames_Number[i] == 2000)
						continue;

					if(g_MiniGames_Number[i] == iRandomNumber[k])
					{
						g_ModeSynapsis_Id[k] = i;

						dg_color_chat(0, _, "El usuario !t%s!y ganó el !tNEMESIS!y por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber[k]);
						
						g_MiniGames_Number[i] = 2000;

						setRewardWinner(i);
						return;
					}

					iLocalNumber[i] = g_MiniGames_Number[i];
					g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[k]);
				}

				iWinner = 0;
				iMin = 2000;

				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(g_MiniGames_Number[i] < iMin)
					{
						iMin = g_MiniGames_Number[i];
						iWinner = i;
					}
				}

				if(iWinner)
				{
					g_ModeSynapsis_Id[k] = iWinner;
					
					dg_color_chat(0, _, "El usuario !t%s!y ganó el !tNEMESIS!y por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);

					g_MiniGames_Number[iWinner] = 2000;
				}
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
				g_MiniGames_Number[i] = 2000;

			g_StartMode[1] = MODE_SYNAPSIS;
		}
		case MODE_TRIBAL:
		{
			new iRandomNumber[3];

			iRandomNumber[0] = random_num(1, 999);
			iRandomNumber[1] = iRandomNumber[0];

			while(iRandomNumber[0] == iRandomNumber[1])
				iRandomNumber[1] = random_num(1, 999);

			dg_color_chat(0, _, "Números ganadores: !g%d!y y !g%d!y", iRandomNumber[0], iRandomNumber[1]);
			
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!(1 <= g_MiniGames_Number[i] <= 999))
					g_MiniGames_Number[i] = 2000;
			}

			new iLocalNumber[MAX_USERS];
			new iWinner;
			new iMin;

			for(new k = 0; k < 2; ++k)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsConnected[i])
						continue;

					if(!g_AccountLogged[i])
						continue;

					if(g_MiniGames_Number[i] == 2000)
						continue;

					if(g_MiniGames_Number[i] == iRandomNumber[k])
					{
						g_ModeTribal_Id[k] = i;

						dg_color_chat(0, _, "El usuario !t%s!y ganó el !tTRIBAL!y por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber[k]);
						
						g_MiniGames_Number[i] = 2000;

						setRewardWinner(i);
						return;
					}

					iLocalNumber[i] = g_MiniGames_Number[i];
					g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[k]);
				}

				iWinner = 0;
				iMin = 2000;

				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(g_MiniGames_Number[i] < iMin)
					{
						iMin = g_MiniGames_Number[i];
						iWinner = i;
					}
				}

				if(iWinner)
				{
					g_ModeTribal_Id[k] = iWinner;
					
					dg_color_chat(0, _, "El usuario !t%s!y ganó el !tTRIBAL!y por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);

					g_MiniGames_Number[iWinner] = 2000;
				}
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
				g_MiniGames_Number[i] = 2000;

			g_StartMode[1] = MODE_TRIBAL;
		}
		case MODE_SNIPER:
		{
			new iRandomNumber[4];

			iRandomNumber[0] = random_num(1, 999);
			iRandomNumber[1] = iRandomNumber[0];
			iRandomNumber[2] = iRandomNumber[0];
			iRandomNumber[3] = iRandomNumber[0];

			while(iRandomNumber[0] == iRandomNumber[1] || iRandomNumber[0] == iRandomNumber[2] || iRandomNumber[0] == iRandomNumber[3] || iRandomNumber[1] == iRandomNumber[2] || iRandomNumber[1] == iRandomNumber[3] || iRandomNumber[2] == iRandomNumber[3])
			{
				iRandomNumber[1] = random_num(1, 999);
				iRandomNumber[2] = random_num(1, 999);
				iRandomNumber[3] = random_num(1, 999);
			}

			dg_color_chat(0, _, "Números ganadores: !g%d!y, !g%d!y, !g%d!y y !g%d!y", iRandomNumber[0], iRandomNumber[1], iRandomNumber[2], iRandomNumber[3]);
			
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!(1 <= g_MiniGames_Number[i] <= 999))
					g_MiniGames_Number[i] = 2000;
			}

			new iLocalNumber[MAX_USERS];
			new iWinner;
			new iMin;

			for(new k = 0; k < 4; ++k)
			{
				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsConnected[i])
						continue;

					if(!g_AccountLogged[i])
						continue;

					if(g_MiniGames_Number[i] == 2000)
						continue;

					if(g_MiniGames_Number[i] == iRandomNumber[k])
					{
						g_ModeSniper_Id[k] = i;

						dg_color_chat(0, _, "El usuario !t%s!y ganó el !tSNIPER!y por tener el número exacto (!g%d!y)", g_PlayerName[i], iRandomNumber[k]);
						
						g_MiniGames_Number[i] = 2000;

						setRewardWinner(i);
						return;
					}

					iLocalNumber[i] = g_MiniGames_Number[i];
					g_MiniGames_Number[i] = abs(g_MiniGames_Number[i] - iRandomNumber[k]);
				}

				iWinner = 0;
				iMin = 2000;

				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(g_MiniGames_Number[i] < iMin)
					{
						iMin = g_MiniGames_Number[i];
						iWinner = i;
					}
				}

				if(iWinner)
				{
					g_ModeSniper_Id[k] = iWinner;
					
					dg_color_chat(0, _, "El usuario !t%s!y ganó el !tSNIPER!y por tener el número más cercano (!g%d!y)", g_PlayerName[iWinner], iLocalNumber[iWinner]);

					g_MiniGames_Number[iWinner] = 2000;
				}
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
				g_MiniGames_Number[i] = 2000;

			g_StartMode[1] = MODE_SNIPER;
		}
	}
}

public setRewardWinner(const id)
{
	static iRandom;
	iRandom = random_num(1, 100);

	switch(iRandom)
	{
		case 1..25:
		{
			static iRandomLevel;
			iRandomLevel = random_num(5, 25);

			if((g_Level[id] + iRandomLevel) > MAX_LEVEL)
				g_Level[id] = MAX_LEVEL;
			else
				g_Level[id] += iRandomLevel;

			g_Exp[id] = 0;

			dg_color_chat(0, _, "El usuario !t%s!y ganó !g%d nivel%s!y por acertar al número exacto", g_PlayerName[id], iRandomLevel, ((iRandomLevel != 1) ? "es" : ""));
			checkExpEquation(id);
		}
		case 26..50:
		{
			g_Points[id][POINT_HUMAN] += 25;
			g_Points[id][POINT_ZOMBIE] += 25;
			g_Points[id][POINT_LEGACY] += 25;
			g_Points[id][POINT_SPECIAL] += 25;

			dg_color_chat(0, _, "El usuario !t%s!y ganó !g25 pHZLE!y por acertar al número exacto", g_PlayerName[id]);
		}
		case 51..75:
		{
			++g_Habs[id][HAB_H_DAMAGE];
			dg_color_chat(0, _, "El usuario !t%s!y ganó !g+1 DAÑO HUMANO!y por acertar al número exacto", g_PlayerName[id]);
		}
		case 76..99:
		{
			++g_Habs[id][HAB_Z_HEALTH];
			dg_color_chat(0, _, "El usuario !t%s!y ganó !g+1 VIDA ZOMBIE!y por acertar al número exacto", g_PlayerName[id]);
		}
		case 100:
		{
			++g_Points[id][POINT_DIAMMONDS];
			dg_color_chat(0, _, "El usuario !t%s!y ganó !g1 DIAMANTE!y por acertar al número exacto", g_PlayerName[id]);
		}
	}
}

// **************************************************
//		[Message Functions]
// **************************************************
public message__Money(const msg_id, const msg_dest, const msg_entity)
{
	if(g_IsConnected[msg_entity])
		cs_set_user_money(msg_entity, 0);

	return PLUGIN_HANDLED;
}

public message__CurWeapon(const msg_id, const msg_dest, const msg_entity)
{
	if(get_msg_arg_int(1) != 1)
		return;

	if(!g_IsAlive[msg_entity] || g_Zombie[msg_entity] || !g_UnlimitedClip[msg_entity])
		return;

	static iWeaponId;
	iWeaponId = get_msg_arg_int(2);

	if(MAX_BPAMMO[iWeaponId] > 2)
	{
		++g_AchievementSecret_Bullets[msg_entity];

		static iWeaponEnt;
		iWeaponEnt = getCurrentWeaponEnt(msg_entity);

		if(pev_valid(iWeaponEnt))
			set_pdata_int(iWeaponEnt, OFFSET_CLIPAMMO, MAX_CLIP[iWeaponId], OFFSET_LINUX_WEAPONS);

		set_msg_arg_int(3, get_msg_argtype(3), MAX_CLIP[iWeaponId]);
	}
}

public message__FlashBat(const msg_id, const msg_dest, const msg_entity)
{
	if(get_msg_arg_int(1) < OFF_IMPULSE_FLASHLIGHT)
	{
		set_msg_arg_int(1, ARG_BYTE, OFF_IMPULSE_FLASHLIGHT);
		setUserBatteries(msg_entity, OFF_IMPULSE_FLASHLIGHT);
	}
}

public message__Flashlight()
	set_msg_arg_int(2, ARG_BYTE, OFF_IMPULSE_FLASHLIGHT);

public message__NVGToggle(const msg_id, const msg_dest, const msg_entity) 
	return PLUGIN_HANDLED;

public message__WeapPickup(const msg_id, const msg_dest, const msg_entity)
{
	if(g_Zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public message__AmmoPickup(const msg_id, const msg_dest, const msg_entity)
{
	if(g_Zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public message__TextMsg()
{
	static sTextMsg[32];
	get_msg_arg_string(2, sTextMsg, charsmax(sTextMsg));

	if(get_msg_args() == 5 && (get_msg_argtype(5) == ARG_STRING))
	{
		get_msg_arg_string(5, sTextMsg, charsmax(sTextMsg));
		
		if(equal(sTextMsg, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED;
	}
	else if(get_msg_args() == 6 && (get_msg_argtype(6) == ARG_STRING))
	{
		get_msg_arg_string(6, sTextMsg, charsmax(sTextMsg));
		
		if(equal(sTextMsg, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED;
	}

	if(equal(sTextMsg, "#Game_teammate_attack"))
		return PLUGIN_HANDLED;

	if(equal(sTextMsg, "#Game_Commencing"))
		return PLUGIN_HANDLED;

	if(equal(sTextMsg, "#Game_will_restart_in"))
	{
		g_ScoreHumans = 0;
		g_ScoreZombies = 0;

		logevent__RoundEnd();
	}
	else if(equal(sTextMsg, "#Hostages_Not_Rescued") || equal(sTextMsg, "#Round_Draw") || equal(sTextMsg, "#Terrorists_Win") || equal(sTextMsg, "#CTs_Win"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public message__SendAudio()
{
	static sSendAudio[32];
	get_msg_arg_string(2, sSendAudio, charsmax(sSendAudio));

	if(equali(sSendAudio, "%!MRAD_ctwin") || equali(sSendAudio, "%!MRAD_terwin") || equali(sSendAudio, "%!MRAD_rounddraw") || equali(sSendAudio, "%!MRAD_LETSGO") || equali(sSendAudio, "%!MRAD_LOCKNLOAD") || equali(sSendAudio, "%!MRAD_MOVEOUT") || equali(sSendAudio, "%!MRAD_GO") || equali(sSendAudio, "%!MRAD_FIREINHOLE"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public message__TeamInfo(const msg_id, const msg_dest)
{
	if(msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST)
		return;
	
	if(g_SwitchingTeams)
		return;
	
	static iId;
	iId = get_msg_arg_int(1);
	
	if(!isUserValid(iId))
		return;
	
	if(g_Mode == MODE_L4D2 || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT)
	{
		if((g_Mode == MODE_MEGA_GUNGAME && g_ModeMGG_Phase) || g_Mode == MODE_GRUNT)
			setLight(iId, "a");
		else
			setLight(iId, "i");
	}
	else
		setLight(iId, "b");
	
	set_task(0.2, "task__SpecNightvision", iId);

	if(g_NewRound || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;
	
	static sTeam[2];
	get_msg_arg_string(2, sTeam, charsmax(sTeam));
	
	switch(sTeam[0])
	{
		case 'C':
		{
			if((g_Mode == MODE_SURVIVOR || g_Mode == MODE_WESKER || g_Mode == MODE_SNIPER_ELITE || g_Mode == MODE_JASON) && getHumans())
			{
				g_RespawnAsZombie[iId] = 1;
				
				remove_task(iId + TASK_TEAM);
				setUserTeam(iId, F_TEAM_T);
				
				set_msg_arg_string(2, "TERRORIST");
			}
			else if(!getZombies())
			{
				g_RespawnAsZombie[iId] = 1;

				remove_task(iId + TASK_TEAM);
				setUserTeam(iId, F_TEAM_T);
				
				set_msg_arg_string(2, "TERRORIST");
			}
		}
		case 'T':
		{
			if((g_Mode == MODE_DRUNK || g_Mode == MODE_SURVIVOR || g_Mode == MODE_WESKER || g_Mode == MODE_SNIPER_ELITE || g_Mode == MODE_JASON) && getHumans())
			{
				g_RespawnAsZombie[iId] = 1;
				
				remove_task(iId + TASK_TEAM);
				setUserTeam(iId, F_TEAM_T);
				
				set_msg_arg_string(2, "TERRORIST");
			}
			else if(getZombies())
			{
				remove_task(iId + TASK_TEAM);
				setUserTeam(iId, F_TEAM_CT);
				
				set_msg_arg_string(2, "CT");
			}
		}
	}
}

public message__StatusIcon(const msg_id, const msg_dest, const msg_entity)
{
	static sIcon[8];
	get_msg_arg_string(2, sIcon, charsmax(sIcon));

	if(equal(sIcon, "buyzone") && get_msg_arg_int(1))
	{
		set_pdata_int(msg_entity, OFFSET_BUYZONE, get_pdata_int(msg_entity, OFFSET_BUYZONE) & ~(1<<0));
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message__ShowMenu(const msg_id, const msg_dest, const msg_entity)
{
	static sMenuCode[21];
	get_msg_arg_string(4, sMenuCode, charsmax(sMenuCode));

	if(equal(sMenuCode, FIRST_JOIN_MSG) || equal(sMenuCode, FIRST_JOIN_MSG_SPEC))
	{
		if(getUserTeam(msg_entity) == F_TEAM_NONE)
		{
			static iArgs[1];
			iArgs[0] = msg_id;

			set_task(0.1, "task__AutoJoinToSpec", msg_entity + TASK_AUTO_JOIN, iArgs, sizeof(iArgs));
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public message__VGUIMenu(const msg_id, const msg_dest, const msg_entity)
{
	if(get_msg_arg_int(1) != 2)
		return PLUGIN_CONTINUE;

	if(getUserTeam(msg_entity) == F_TEAM_NONE)
	{
		static iArgs[1];
		iArgs[0] = msg_id;

		set_task(0.1, "task__AutoJoinToSpec", msg_entity + TASK_AUTO_JOIN, iArgs, sizeof(iArgs));
	}

	return PLUGIN_HANDLED;
}

// **************************************************
//		[Touch & Thinks Functions]
// **************************************************
public touch__AllGrenade(const grenade, const ent)
{
	if(is_valid_ent(grenade) && isSolid(ent) && g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL)
	{
		static iNadeType;
		iNadeType = entity_get_int(grenade, EV_NADE_TYPE);

		if(iNadeType != NADE_TYPE_FLARE && iNadeType != NADE_TYPE_IMMUNITY && iNadeType != NADE_TYPE_BUBBLE)
			entity_set_float(grenade, EV_FL_dmgtime, (get_gametime() + 0.001));
	}
}

public touch__AllRocket(const rocket, const ent)
{
	if(is_valid_ent(rocket))
	{
		static iAttacker;
		iAttacker = entity_get_edict(rocket, EV_ENT_owner);

		if(!isUserValidConnected(iAttacker))
		{
			removeRocket(rocket);
			return;
		}

		static Float:vecOrigin[3];
		static iVictim;
		static iCountVictims;
		static Float:flRadius;
		static Float:flMaxDamage;
		static Float:flDistance;
		static Float:flDamage;
		static Float:flFadeAlpha;
		static Float:flVictimHealth;

		entity_get_vector(rocket, EV_VEC_origin, vecOrigin);
		iVictim = -1;
		iCountVictims = 0;
		flRadius = 500.0;

		if(g_Habs[iAttacker][HAB_L_N_BAZOOKA_RADIUS])
			flRadius += (float(HABS[HAB_L_N_BAZOOKA_RADIUS][habValue]) * float(g_Habs[iAttacker][HAB_L_N_BAZOOKA_RADIUS]));

		flMaxDamage = 2500.0;

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		write_short(g_Sprite_Explosion);
		write_byte(90);
		write_byte(10);
		write_byte((TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NODLIGHTS));
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
		write_byte(255);
		write_byte(0);
		write_byte(0);
		write_byte(150);
		write_byte(15);
		message_end();

		playSound(0, SOUND_BAZOOKA[1]);

		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, flRadius)) != 0)
		{
			if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim])
				continue;

			flDistance = entity_range(rocket, iVictim);
			flDamage = floatRadius(flMaxDamage, flRadius, flDistance);
			flFadeAlpha = floatRadius(255.0, flRadius, flDistance);
			flVictimHealth = entity_get_float(iVictim, EV_FL_health);

			if(flDamage > 0)
			{
				if(flVictimHealth <= flDamage)
				{
					ExecuteHamB(Ham_Killed, iVictim, iAttacker, 2);
					++iCountVictims;
				}
				else
				{
					ExecuteHam(Ham_TakeDamage, iVictim, rocket, iAttacker, flDamage, DMG_BLAST);

					message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iVictim);
					write_short(UNIT_SECOND * 1);
					write_short(UNIT_SECOND * 1);
					write_short(FFADE_IN);
					write_byte(200);
					write_byte(0);
					write_byte(0);
					write_byte(floatround(flFadeAlpha));
					message_end();

					message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, iVictim);
					write_short(UNIT_SECOND * 14);
					write_short(UNIT_SECOND * 3);
					write_short(UNIT_SECOND * 14);
					message_end();
				}
			}
		}

		removeRocket(rocket);

		if(g_SpecialMode[iAttacker] == MODE_NEMESIS)
		{
			set_user_health(iAttacker, (g_Health[iAttacker] + (iCountVictims * 25000)));
			g_Health[iAttacker] = get_user_health(iAttacker);

			if(!iCountVictims)
				setAchievement(iAttacker, LA_EXPLOSION_NO_MATA);
			else if(iCountVictims >= 20)
				setAchievement(iAttacker, LA_EXPLOSION_SI_MATA);
		}
		else if(g_SpecialMode[iAttacker] == MODE_ANNIHILATOR)
		{
			g_Achievement_AnnBazooka[iAttacker] += iCountVictims;
			
			if(!getHumans())
				setAchievement(iAttacker, OOPS_MATE_A_TODOS);
		}
	}
}

public touch__PlayerHeadZombie(const head, const id)
{
	if(!is_valid_ent(head) || !g_IsAlive[id])
		return PLUGIN_CONTINUE;

	if(g_Zombie[id])
		return PLUGIN_CONTINUE;

	static Float:flHalfLifeTime;
	flHalfLifeTime = halflife_time();

	if((flHalfLifeTime - g_HeadZombieLastTouch[id]) < 2.5)
		return PLUGIN_CONTINUE;

	g_HeadZombieLastTouch[id] = flHalfLifeTime;

	static iHeadColor;
	iHeadColor = entity_get_edict(head, EV_ENT_euser4);

	++g_HeadZombie[id][iHeadColor];
	dg_color_chat(id, _, "Agarraste una cabeza zombie %s", HEADZOMBIES_NAMES[iHeadColor]);

	if(g_HeadZombie[id][HEADZOMBIE_RED] == 100)
		setAchievement(id, HEAD_100_RED);

	if(g_HeadZombie[id][HEADZOMBIE_GREEN] == 75)
		setAchievement(id, HEAD_75_GREEN);

	if(g_HeadZombie[id][HEADZOMBIE_BLUE] == 50)
		setAchievement(id, HEAD_50_BLUE);

	if(g_HeadZombie[id][HEADZOMBIE_YELLOW] == 25)
		setAchievement(id, HEAD_25_YELLOW);

	if(g_HeadZombie[id][HEADZOMBIE_WHITE] == 10)
		setAchievement(id, HEAD_10_WHITE);

	if(g_HeadZombie[id][HEADZOMBIE_RED] && g_HeadZombie[id][HEADZOMBIE_GREEN] && g_HeadZombie[id][HEADZOMBIE_BLUE] && g_HeadZombie[id][HEADZOMBIE_YELLOW] && g_HeadZombie[id][HEADZOMBIE_WHITE])
		setAchievement(id, COLORIDO);

	g_HeadZombieLastTouch[id] = 0.0;

	emitSound(head, CHAN_VOICE, "items/ammopickup1.wav");

	remove_entity(head);
	return PLUGIN_CONTINUE;
}

public tribalAura(const id)
{
	if(g_SpecialMode[id] != MODE_TRIBAL)
		return;

	static Float:vecPositionId[3];
	static Float:vecPositionI[3];
	static Float:flDistance;
	static iOk;
	
	iOk = 0;

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i])
			continue;

		if(id == i || g_SpecialMode[i] != MODE_TRIBAL)
			continue;

		iOk = 1;

		entity_get_vector(i, EV_VEC_origin, vecPositionI);
		entity_get_vector(id, EV_VEC_origin, vecPositionId);

		flDistance = get_distance_f(vecPositionI, vecPositionId);

		if(flDistance <= 350)
		{
			if(!task_exists(id + TASK_POWER_TRIBAL))
				set_task(0.1, "task__PowerTribal", id + TASK_POWER_TRIBAL, .flags="b");

			if(!task_exists(i + TASK_POWER_TRIBAL))
				set_task(0.1, "task__PowerTribal", i + TASK_POWER_TRIBAL, .flags="b");
		}
		else
		{
			if(task_exists(id + TASK_POWER_TRIBAL))
				remove_task(id + TASK_POWER_TRIBAL);

			if(task_exists(i + TASK_POWER_TRIBAL))
				remove_task(i + TASK_POWER_TRIBAL);
		}

		break;
	}

	if(!iOk)
	{
		if(task_exists(id + TASK_POWER_TRIBAL))
			remove_task(id + TASK_POWER_TRIBAL);
	}
}

public task__PowerTribal(const task_id)
{
	static iId;
	iId = ID_POWER_TRIBAL;

	if(g_SpecialMode[iId] != MODE_TRIBAL)
	{
		remove_task(task_id);
		return;
	}

	static vecOrigin[3];
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

	if(g_Health[iId] < g_MaxHealth[iId])
		set_user_health(iId, (g_Health[iId] + 1));

	++g_ModeTribal_Damage[iId];
}

public think__General(const ent)
{
	if(!is_valid_ent(ent))
		return;

	static Float:flHalfTime;
	static iSpectId;
	static sHealth[16];
	static sArmor[16];
	static sAmmoPacks[16];
	static sExp[16];
	static Float:vecOrigin[3];
	static i;

	flHalfTime = halflife_time();

	for(i = 1; i <= MaxClients; ++i)
	{
		if(!g_IsConnected[i])
			continue;

		if(g_LoadingData[i])
		{
			showMessage_LoadingData(i);
			continue;
		}

		if(g_IsAlive[i])
		{
			if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME)
			{
				addDot(g_Health[i], sHealth, charsmax(sHealth));
				
				set_hudmessage(g_UserOption_Color[i][COLOR_TYPE_HUD_G][0], g_UserOption_Color[i][COLOR_TYPE_HUD_G][1], g_UserOption_Color[i][COLOR_TYPE_HUD_G][2], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][0], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][1], g_UserOption_EffectHud[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
				ShowSyncHudMsg(i, g_HudSync_General, "%s^n^nVida: %s^nNivel: %d", g_ModeGG_Stats, sHealth, g_ModeGG_Level[i]);
			}
			else if(g_Mode == MODE_FVSJ)
			{
				addDot(g_Health[i], sHealth, charsmax(sHealth));
				
				set_hudmessage(g_UserOption_Color[i][COLOR_TYPE_HUD_G][0], g_UserOption_Color[i][COLOR_TYPE_HUD_G][1], g_UserOption_Color[i][COLOR_TYPE_HUD_G][2], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][0], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][1], g_UserOption_EffectHud[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
				ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^nHumanos restantes: %d", sHealth, g_ModeFvsJ_Humans);
			}
			else if(g_Mode == MODE_L4D2)
			{
				addDot(g_Health[i], sHealth, charsmax(sHealth));
				
				set_hudmessage(g_UserOption_Color[i][COLOR_TYPE_HUD_G][0], g_UserOption_Color[i][COLOR_TYPE_HUD_G][1], g_UserOption_Color[i][COLOR_TYPE_HUD_G][2], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][0], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][1], g_UserOption_EffectHud[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
				ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^nZombies restantes: %d", sHealth, g_ModeL4D2_Zombies);
			}
			else
			{
				if(flHalfTime >= g_ComboTime[i])
				{
					if(!g_Zombie[i])
						finishComboHuman(i);
					else
						finishComboZombie(i);
				}
				else if(!g_Zombie[i] && g_Combo[i])
					updateComboHuman(i);

				if(g_ClanSlot[i])
				{
					if(flHalfTime >= g_ClanComboTime[g_ClanSlot[i]])
						clanFinishCombo(i);
				}

				addDot(g_Health[i], sHealth, charsmax(sHealth));
				if(!g_Zombie[i])
				{
					if(g_UserOption_MinimizeHud[i][HUD_TYPE_GENERAL])
					{
						if(g_UserOption_AbreviateHud[i][HUD_TYPE_GENERAL])
							formatex(sArmor, charsmax(sArmor), "AP: %d - ", get_user_armor(i));
						else
							formatex(sArmor, charsmax(sArmor), "Chaleco: %d - ", get_user_armor(i));
					}
					else
					{
						if(g_UserOption_AbreviateHud[i][HUD_TYPE_GENERAL])
							formatex(sArmor, charsmax(sArmor), "AP: %d^n", get_user_armor(i));
						else
							formatex(sArmor, charsmax(sArmor), "Chaleco: %d^n", get_user_armor(i));
					}
				}
				else
					sArmor[0] = EOS;
				addDot(g_AmmoPacks[i], sAmmoPacks, charsmax(sAmmoPacks));
				addDot(g_Exp[i], sExp, charsmax(sExp));

				set_hudmessage(g_UserOption_Color[i][COLOR_TYPE_HUD_G][0], g_UserOption_Color[i][COLOR_TYPE_HUD_G][1], g_UserOption_Color[i][COLOR_TYPE_HUD_G][2], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][0], g_UserOption_PositionHud[i][HUD_TYPE_GENERAL][1], g_UserOption_EffectHud[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
				if(g_UserOption_MinimizeHud[i][HUD_TYPE_GENERAL])
				{
					if(g_UserOption_AbreviateHud[i][HUD_TYPE_GENERAL])
						ShowSyncHudMsg(i, g_HudSync_General, "HP: %s - %s%s - APs: %s^nXP: %s - LVL: %d (%0.2f%%) - RNG: %c", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, sExp, g_Level[i], g_LevelPercent[i], getUserRange(g_Reset[i]));
					else
						ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s - %sClase: %s - AmmoPacks: %s^nExperiencia: %s - Nivel: %d (%0.2f%%) - Rango: %c", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, sExp, g_Level[i], g_LevelPercent[i], getUserRange(g_Reset[i]));
				}
				else
				{
					if(g_UserOption_AbreviateHud[i][HUD_TYPE_GENERAL])
						ShowSyncHudMsg(i, g_HudSync_General, "HP: %s^n%s%s^nAPs: %s^nXP: %s^nLVL: %d (%0.2f%%)^nRNG: %c", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, sExp, g_Level[i], g_LevelPercent[i], getUserRange(g_Reset[i]));
					else
						ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^n%sClase: %s^nAmmoPacks: %s^nExperiencia: %s^nNivel: %d (%0.2f%%)^nRango: %c", sHealth, sArmor, g_PlayerClassName[i], sAmmoPacks, sExp, g_Level[i], g_LevelPercent[i], getUserRange(g_Reset[i]));
				}

				if(getUserAura(i))
				{
					if(g_Mode == MODE_TRIBAL && g_SpecialMode[i] == MODE_TRIBAL)
						tribalAura(i);
					else
					{
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
			}
		}
		else
		{
			iSpectId = entity_get_int(i, EV_ID_SPEC);

			if(g_IsAlive[iSpectId])
			{
				if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME)
				{
					addDot(g_Health[iSpectId], sHealth, charsmax(sHealth));
					
					set_hudmessage(g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][0], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][1], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][2], 1.5, 0.6, g_UserOption_EffectHud[iSpectId][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
					ShowSyncHudMsg(i, g_HudSync_General, "%s^n^nVida: %s^nNivel: %d", g_ModeGG_Stats, sHealth, g_ModeGG_Level[iSpectId]);
				}
				else if(g_Mode == MODE_FVSJ)
				{
					addDot(g_Health[iSpectId], sHealth, charsmax(sHealth));
					
					set_hudmessage(g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][0], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][1], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][2], 1.5, 0.6, g_UserOption_EffectHud[iSpectId][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
					ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^nHumanos restantes: %d", sHealth, g_ModeFvsJ_Humans);
				}
				else if(g_Mode == MODE_L4D2)
				{
					addDot(g_Health[iSpectId], sHealth, charsmax(sHealth));
					
					set_hudmessage(g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][0], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][1], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][2], 1.5, 0.6, g_UserOption_EffectHud[iSpectId][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
					ShowSyncHudMsg(i, g_HudSync_General, "Vida: %s^nZombies restantes: %d", sHealth, g_ModeL4D2_Zombies);
				}
				else
				{
					addDot(g_Health[iSpectId], sHealth, charsmax(sHealth));
					if(!g_Zombie[iSpectId])
					{
						if(g_UserOption_MinimizeHud[iSpectId][HUD_TYPE_GENERAL])
						{
							if(g_UserOption_AbreviateHud[iSpectId][HUD_TYPE_GENERAL])
								formatex(sArmor, charsmax(sArmor), "AP: %d - ", get_user_armor(iSpectId));
							else
								formatex(sArmor, charsmax(sArmor), "Chaleco: %d - ", get_user_armor(iSpectId));
						}
						else
						{
							if(g_UserOption_AbreviateHud[iSpectId][HUD_TYPE_GENERAL])
								formatex(sArmor, charsmax(sArmor), "AP: %d^n", get_user_armor(iSpectId));
							else
								formatex(sArmor, charsmax(sArmor), "Chaleco: %d^n", get_user_armor(iSpectId));
						}
					}
					else
						sArmor[0] = EOS;
					addDot(g_AmmoPacks[iSpectId], sAmmoPacks, charsmax(sAmmoPacks));
					addDot(g_Exp[iSpectId], sExp, charsmax(sExp));

					set_hudmessage(g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][0], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][1], g_UserOption_Color[iSpectId][COLOR_TYPE_HUD_G][2], 1.5, 0.6, g_UserOption_EffectHud[iSpectId][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, -1);
					if(g_UserOption_MinimizeHud[iSpectId][HUD_TYPE_GENERAL])
					{
						if(g_UserOption_AbreviateHud[iSpectId][HUD_TYPE_GENERAL])
							ShowSyncHudMsg(i, g_HudSync_General, "%s^nHP: %s - %s%s - APs: %s^nXP: %s - LVL: %d (%0.2f%%) - RNG: %c", g_PlayerName[iSpectId], sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, sExp, g_Level[iSpectId], g_LevelPercent[iSpectId], getUserRange(g_Reset[iSpectId]));
						else
							ShowSyncHudMsg(i, g_HudSync_General, "Mirando a: %s^nVida: %s - %sClase: %s - AmmoPacks: %s^nExperiencia: %s - Nivel: %d (%0.2f%%) - Rango: %c", g_PlayerName[iSpectId], sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, sExp, g_Level[iSpectId], g_LevelPercent[iSpectId], getUserRange(g_Reset[iSpectId]));
					}
					else
					{
						if(g_UserOption_AbreviateHud[iSpectId][HUD_TYPE_GENERAL])
							ShowSyncHudMsg(i, g_HudSync_General, "%s^nHP: %s^n%s%s^nAPs: %s^nXP: %s^nLVL: %d (%0.2f%%)^nRNG: %c", g_PlayerName[iSpectId], sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, sExp, g_Level[iSpectId], g_LevelPercent[iSpectId], getUserRange(g_Reset[iSpectId]));
						else
							ShowSyncHudMsg(i, g_HudSync_General, "Mirando a: %s^nVida: %s^n%sClase: %s^nAmmoPacks: %s^nExperiencia: %s^nNivel: %d (%0.2f%%)^nRango: %c", g_PlayerName[iSpectId], sHealth, sArmor, g_PlayerClassName[iSpectId], sAmmoPacks, sExp, g_Level[iSpectId], g_LevelPercent[iSpectId], getUserRange(g_Reset[iSpectId]));
					}
				}
			}
		}
	}

	if(g_Mode == MODE_SNIPER_ELITE && g_ModeSniperElite_ZombieLeft)
	{
		set_hudmessage(0, 255, 0, -1.0, 0.8, 0, 6.0, 1.1, 0.0, 0.0, -1);
		ShowSyncHudMsg(0, g_HudSync_Combo, "Zombies restantes: %d", abs(g_ModeSniperElite_ZombieLeft));
	}
	else if(g_Mode == MODE_ASSASSIN && (g_ModeAssassin_RewardAssassin || g_ModeAssassin_RewardHumans))
	{
		static sRewardAssassin[16];
		static sRewardHumans[16];

		addDot(g_ModeAssassin_RewardAssassin, sRewardAssassin, charsmax(sRewardAssassin));
		addDot(g_ModeAssassin_RewardHumans, sRewardHumans, charsmax(sRewardHumans));

		set_hudmessage(255, 255, 255, -1.0, 0.75, 0, 6.0, 1.1, 0.0, 0.0, -1);
		ShowSyncHudMsg(0, g_HudSync_Combo, "Recompensa de XP del Assassin: %s^nRecompensa de XP de los Humanos: %s", sRewardAssassin, sRewardHumans);
	}

	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
}

public think__ModeMegaGungame(const ent)
{
	if(!is_valid_ent(ent))
		return;

	static sCurrentDay[4];
	get_time("%A", sCurrentDay, charsmax(sCurrentDay));

	if(!equal(sCurrentDay, "Sat"))
		return;

	static sHour[3];
	static sMinutes[3];

	get_time("%H", sHour, charsmax(sHour));
	get_time("%M", sMinutes, charsmax(sMinutes));

	static iHours;
	static iMinutes;

	iHours = (24 - (str_to_num(sHour) + 1));
	iMinutes = (60 - str_to_num(sMinutes));

	dg_color_chat(0, _, "Falta%s !g%d hora%s!y y !g%d minuto%s!y para el modo !tMEGA GUNGAME!y", ((iHours != 1) ? "n" : ""), iHours, ((iHours != 1) ? "s" : ""), iMinutes, ((iMinutes != 1) ? "s" : ""));
	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 1225.0));
}

// **************************************************
//		[Others Functions]
// **************************************************
public loadSql()
{
	if(equali(g_MapName, "gk_kgames_b1"))
	{
		new iEnt = create_entity("info_target");
		if(is_valid_ent(iEnt))
		{
			entity_set_string(iEnt, EV_SZ_classname, ENT_CLASSNAME_WGM);
			entity_set_model(iEnt, MODEL_SKULL);
			entity_set_origin(iEnt, Float:{-2799.4, -1760.4, -1492.9});
			
			entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
			entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
			
			entity_set_size(iEnt, Float:{-783.0, -20.0, -82.0}, Float:{783.0, 20.0, 82.0});
			
			entity_set_int(iEnt, EV_INT_effects, entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW);
			
			entity_set_int(iEnt, EV_INT_iuser1, 50);
		}

		iEnt = create_entity("info_target");
		if(is_valid_ent(iEnt))
		{
			entity_set_string(iEnt, EV_SZ_classname, ENT_CLASSNAME_WGM);
			entity_set_model(iEnt, MODEL_SKULL);
			entity_set_origin(iEnt, Float:{638.4, 2367.4, -2592.4});
			
			entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
			entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
			
			entity_set_size(iEnt, Float:{-1277.0, -1279.0, -93.0}, Float:{1277.0, 1279.0, 93.0});
			
			entity_set_int(iEnt, EV_INT_effects, entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW);
			
			entity_set_int(iEnt, EV_INT_iuser1, 100);
		}
	}

	server_cmd("sv_restart 1");

	new iErrors;

	g_SqlTuple = SQL_MakeDbTuple(SQL_HOST, SQL_USER, SQL_PASSWORD, SQL_DATABASE);
	g_SqlConnection = SQL_Connect(g_SqlTuple, iErrors, g_SqlErrors, charsmax(g_SqlErrors));

	if(g_SqlConnection == Empty_Handle)
	{
		dg_log_to_file(LOG_MYSQL, 1, 0, "loadSql() - %s", g_SqlErrors);

		set_fail_state(g_SqlErrors);
		return;
	}

	remove_task(TASK_SET_CONFIGS);
	remove_task(TASK_SQL_QUERIES);

	set_task(1.0, "task__SetConfigs", TASK_SET_CONFIGS);
	set_task(2.0, "task__SqlQueries", TASK_SQL_QUERIES);

	g_tModeAnnihilator_Acerts = TrieCreate();
	g_tExtraItem_Invisibility = TrieCreate();
	g_tExtraItem_KillBomb = TrieCreate();
	g_tExtraItem_MolotovBomb = TrieCreate();
	g_tExtraItem_AntidoteBomb = TrieCreate();
	g_tExtraItem_Antidote = TrieCreate();
	g_tExtraItem_ZombieMadness = TrieCreate();
	g_tExtraItem_InfectionBomb = TrieCreate();
	g_tExtraItem_ReduceDamage = TrieCreate();
	g_tExtraItem_PainShock = TrieCreate();
	g_tExtraItem_Petrification = TrieCreate();
}

public loadSpawns()
{
	static const SPAWN_NAME_ENTS[][] = {"info_player_start", "info_player_deathmatch"};
	static Float:vecOrigin[3];
	static iEnt;

	for(new i = 0; i < sizeof(SPAWN_NAME_ENTS); ++i)
	{
		iEnt = -1;

		while((iEnt = find_ent_by_class(iEnt, SPAWN_NAME_ENTS[i])) != 0)
		{
			entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);

			g_Spawns[g_SpawnsCount][0] = vecOrigin[0];
			g_Spawns[g_SpawnsCount][1] = vecOrigin[1];
			g_Spawns[g_SpawnsCount][2] = vecOrigin[2];

			++g_SpawnsCount;

			if(g_SpawnsCount >= 64)
				break;
		}

		if(g_SpawnsCount >= 64)
			break;
	}
}

public randomSpawn(const id)
{
	if(!g_SpawnsCount)
		return;

	static iHull;
	static iSpawnId;
	static i;

	iHull = ((entity_get_int(id, EV_INT_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN);
	iSpawnId = random_num(0, (g_SpawnsCount - 1));

	for(i = iSpawnId + 1;; ++i)
	{
		if(i >= g_SpawnsCount)
			i = 0;

		if(isHullVacant(g_Spawns[i], iHull))
		{
			entity_set_vector(id, EV_VEC_origin, g_Spawns[i]);
			break;
		}

		if(i == iSpawnId)
			break;
	}

	remove_task(id + TASK_CHECK_STUCK);
	set_task(0.5, "task__CheckStuck", id + TASK_CHECK_STUCK);
}

public isHullVacant(const Float:origin[3], const hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0);

	if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return 1;

	return 0;
}

public isUserStuck(const id)
{
	static Float:vecOrigin[3];
	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, (entity_get_int(id, EV_INT_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);

	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return 1;

	return 0;
}

resetVars(const id, const reset_all=0)
{
	set_pdata_int(id, OFFSET_LONG_JUMP, 0, OFFSET_LINUX);

	g_Combo[id] = 0;
	g_ComboDamageBullet[id] = 0.0;
	g_ComboDamage[id] = 0.0;
	g_ComboReward[id] = 0;
	g_ComboZombieEnabled[id] = 0;
	g_ComboZombie[id] = 0;
	g_ComboZombieReward[id] = 0;
	if(g_Mode != MODE_MEGA_ARMAGEDDON)
		g_Zombie[id] = 0;
	g_SpecialMode[id] = 0;
	g_SpecialMode_Alien[id] = 0;
	g_SpecialMode_AlienOrigin[id] = Float:{0.0, 0.0, 0.0};
	g_SpecialMode_Predator[id] = 0;
	g_ModeGG_Immunity[id] = 0;
	g_ModeFvsJ_FreddyPower[id] = 0;
	g_ModeFvsJ_FreddyPowerType[id] = 0;
	g_ModeFvsJ_Jason[id] = 0;
	g_ModeFvsJ_JasonPower[id] = 0;
	g_ModeSynapsis_NemesisKill[id] = 0;
	g_ModeAvsp_AlienPower[id] = 0;
	g_ModeAvsp_PredatorPower[id] = 0;
	g_ModeDuelFinal_Kills[id] = 0;
	g_ModeWesker_Laser[id] = 0;
	g_ModeWesker_LaserLast[id] = 0.0;
	g_ModeSniperElite_Speed[id] = 0;
	g_ModeJason_Teleport[id] = 0;
	g_ModeNemesis_Bazooka[id] = 0;
	g_ModeNemesis_BazookaLast[id] = 0.0;
	g_ModeAssassin_PowerGlow[id] = 0;
	g_ModeAnnihilator_Kills[id] = 0;
	g_ModeSniper_Power[id] = 0;
	g_ModeGrunt_Flash[id] = 0;
	g_ModeGrunt_Reward[id] = 0;
	g_ModeTribal_Damage[id] = 0;
	g_LastHuman[id] = 0;
	g_LastZombie[id] = 0;
	g_RespawnAsZombie[id] = 0;
	g_NitroBomb[id] = 0;
	g_SuperNovaBomb[id] = 0;
	g_ImmunityBomb[id] = 0;
	g_DrugBomb[id] = 0;
	g_DrugBombMove[id] = 0;
	g_HyperNovaBomb[id] = 0;
	g_BubbleBomb[id] = 0;
	g_InBubble[id] = 0;
	g_CanBuy[id] = 1;
	g_LongJump[id] = 0;
	g_InJump[id] = 0;
	if(g_Mode != MODE_FVSJ)
		g_UnlimitedClip[id] = 0;
	g_PrecisionPerfect[id] = 0;
	g_KillBomb[id] = 0;
	g_MolotovBomb[id] = 0;
	g_AntidoteBomb[id] = 0;
	g_NightVision[id] = 0;
	g_ReduceDamage[id] = 0;
	g_Madness_LastUse[id] = 0;
	g_Painshock[id] = 0;
	g_Painshock_LastUse[id] = 0;
	g_Petrification[id] = 0;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_Frozen[id] = 0;
	g_FrozenGravity[id] = 0.0;
	g_SlowDown[id] = 0;
	g_Immunity[id] = 0;
	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;
	g_Achievement_InfectsRound[id] = 0;
	for(new i = 0; i <= g_MaxPlayers; ++i)
		g_Achievement_InfectsRoundId[id][i] = 0;
	g_Achievement_InfectsWithMaxHP[id] = 0;
	g_AchievementSecret_Bullets[id] = 0;
	g_AchievementSecret_BulletsOk[id] = 0;
	g_AchievementSecret_FuryInRound[id] = 0;
	g_AchievementSecret_DmgNem[id] = 0;
	g_AchievementSecret_DmgNemOrd[id] = 0;
	g_AchievementSecret_Cortamambo[id] = 0.0;
	g_AchievementSecret_MasZombies[id] = 0;
	g_AchievementSecret_AplZombie[id] = 0;
	g_AchievementSecret_AsesinoTurn[id] = 0;
	g_AchievementSecret_Predator[id] = 0;
	g_AchievementSecret_Alien[id] = 0;
	g_ConvertZombie[id] = 0;

	if(reset_all)
	{
		g_AccountId[id] = 0;
		g_AccountName[id][0] = EOS;
		g_AccountPassword[id][0] = EOS;
		g_AccountSince[id] = 0;
		g_AccountLastConnection[id] = 0;
		g_AccountAutoLogin[id] = 0;
		g_AccountVinc[id] = 0;
		g_AccountLogged[id] = 0;
		g_AccountBanned[id] = 0;
		g_AccountBan_Admin[id][0] = EOS;
		g_AccountBan_Start[id] = 0;
		g_AccountBan_Finish[id] = 0;
		g_AccountBan_Reason[id][0] = EOS;
		g_AccountRank[id] = 0;
		g_LoadingData[id] = 0;
		g_LoadingData_Percent[id] = 0;
		g_DailyVisits[id] = 0;
		g_Consecutive_DailyVisits[id] = 0;
		g_ConnectedToday[id] = 0;
		g_Benefit[id] = 0;
		g_Class[id] = 0;
		g_ClassPetitionMode[id] = 0;
		for(new i = 0; i < 7; ++i)
			g_ClassPetitionMode_Selected[id][i] = 0;
		g_Aura[id] = {0, 0, 0, 0};
		g_FirstRespawn[id] = 0;
		g_Health[id] = 0;
		g_MaxHealth[id] = 0;
		g_Speed[id] = 240.0;
		g_TypeWeapon[id] = -1;
		g_CurrentWeapon[id] = 0;
		g_LastWeapon[id] = 0;
		g_BlockSound[id] = 0;
		g_ModeMA_Reward[id] = 0;
		for(new i = 1; i <= g_MaxPlayers; ++i)
			g_ModeMA_Kills[id][i] = 0;
		g_ModeMA_ZombieKills[id] = 0;
		g_ModeMA_HumanKills[id] = 0;
		g_ModeMA_NemesisKills[id] = 0;
		g_ModeMA_SurvivorKills[id] = 0;
		g_ModeGG_Level[id] = 1;
		g_ModeGG_Kills[id] = 0;
		g_ModeGG_Headshots[id] = 0;
		g_ModeGGCrazy_Level[id] = random_num(1, 25);
		g_ModeGGCrazy_ListLevel[id][0] = 1;
		for(new i = 1; i < 26; ++i)
			g_ModeGGCrazy_ListLevel[id][i] = 0;
		g_ModeGGCrazy_HeLevel[id] = 0;
		g_ModeMGG_Health[id] = 0;
		g_ModeDuelFinal_KillsTotal[id] = 0;
		g_ModeDuelFinal_KillsKnife[id] = 0;
		g_ModeDuelFinal_KillsAwp[id] = 0;
		g_ModeDuelFinal_KillsHE[id] = 0;
		g_ModeDuelFinal_KillsDeagle[id] = 0;
		g_ModeDuelFinal_KillsM3[id] = 0;
		g_ModeAnnihilator_Acerts[id] = 0;
		g_AmmoPacks[id] = 0;
		g_AmmoPacksDamage[id] = 0;
		g_AmmoPacksDamageNeed[id] = MAX_APS_DAMAGE_NEED;
		g_AmmoPacksMult[id] = 1;
		g_Exp[id] = 0;
		g_ExpRest[id] = 0;
		g_ExpRestHud[id][0] = EOS;
		g_ExpDamage[id] = 0;
		g_ExpDamageNeed[id] = MAX_XP_DAMAGE_NEED;
		g_ExpMult[id] = 1;
		g_Level[id] = 1;
		g_LevelPercent[id] = 0.00;
		g_Reset[id] = 0;
		g_ResetPercent[id] = 0.00;
		g_Combo[id] = 0;
		g_ComboDamageBullet[id] = 0.0;
		g_ComboDamage[id] = 0.0;
		g_ComboDamageNeed[id] = 0.1;
		g_ComboReward[id] = 0;
		g_ComboTime[id] = (halflife_time() + 9999999.9);
		g_ComboZombieEnabled[id] = 0;
		g_ComboZombie[id] = 0;
		g_ComboZombieReward[id] = 0;
		g_DeadTimes[id] = 0;
		g_MayorMuerte[id] = 0;
		for(new i = 0; i < structIdWeapons; ++i)
			g_Weapons[id][i] = 0;
		for(new i = 0; i < 31; ++i)
		{
			g_WeaponData[id][i][WEAPON_DATA_DAMAGE_DONE] = _:0.0;
			g_WeaponData[id][i][WEAPON_DATA_KILL_DONE] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TIME_PLAYED_DONE] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TPD_DAYS] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TPD_HOURS] = 0;
			g_WeaponData[id][i][WEAPON_DATA_TPD_MINUTES] = 0;
			g_WeaponData[id][i][WEAPON_DATA_POINTS] = 0;
			g_WeaponData[id][i][WEAPON_DATA_LEVEL] = 0;
			g_WeaponData[id][i][WEAPON_DATA_DAMAGE_S_DONE] = _:0.0;
			g_WeaponData[id][i][WEAPON_DATA_KILL_S_DONE] = 0;

			for(new j = 0; j < structIdWeaponSkills; ++j)
				g_WeaponSkills[id][i][j] = 0;

			g_WeaponModel[id][i] = 0;
			g_WeaponSave[id][i] = 0;
		}
		g_WeaponTime[id] = 0;
		g_WeaponSecondaryAutofire[id] = 0;
		g_DrugBombCount[id] = 0;
		for(new i = 0; i < structIdExtraItems; ++i)
		{
			g_ExtraItem_Cost[id][i] = EXTRA_ITEMS[i][extraItemCost];
			g_ExtraItem_Count[id][i] = 0;
		}
		for(new i = 0; i < sizeof(MODELS); ++i)
			g_Models[id][i] = 0;
		for(new i = 0; i < structIdDifficultsClasses; ++i)
			g_Difficult[id][i] = 0;
		for(new i = 0; i < structIdPoints; ++i)
		{
			g_Points[id][i] = 0;
			g_PointsLose[id][i] = 0;
		}
		g_PointsMult[id] = 1;
		for(new i = 0; i < structIdHabs; ++i)
			g_Habs[id][i] = 0;
		g_InductionChance[id] = 0;
		for(new i = 0; i < structIdAchievementClasses; ++i)
			g_AchievementPage[id][i] = 0;
		for(new i = 0; i < structIdAchievements; ++i)
		{
			g_Achievement[id][i] = 0;
			g_AchievementName[id][i][0] = EOS;
			g_AchievementUnlocked[id][i] = 0;
			g_AchievementInt[id][i] = 0;
		}
		g_AchievementTotal[id] = 0;
		g_Achievement_FuryConsecutive[id] = 0;
		g_Achievement_InfectsWithFury[id] = 0;
		g_Achievement_MaxBet[id] = 0;
		g_Achievement_WeskerHead[id] = 0;
		g_Achievement_SniperAwp[id] = 0;
		g_Achievement_SniperScout[id] = 0;
		g_Achievement_SniperHead[id] = 0;
		g_Achievement_SniperNoDmg[id] = 0;
		g_Achievement_AnnKnife[id] = 0;
		g_Achievement_AnniMac10[id] = 0;
		g_Achievement_AnnBazooka[id] = 0;
		g_AchievementSecret_Terrorist[id] = 0;
		g_AchievementSecret_Hitman[id] = 0;
		for(new i = 0; i < structIdExtraItems; ++i)
			g_AchievementSecret_AllItems[id][i] = 0;
		g_AchievementSecret_Nemesis[id] = 0;
		g_AchievementSecret_Resistencia[id] = 0;
		g_AchievementSecret_Albert[id] = 0;
		for(new i = 0; i < 6; ++i)
			g_AchievementSecret_Progress[id][i] = 0.0;
		g_ClanSlot[id] = 0;
		g_ClanInvitations[id] = 0;
		for(new i = 0; i <= g_MaxPlayers; ++i)
			g_ClanInvitationsId[id][i] = 0;
		g_Clan_QueryFlood[id] = 0.0;
		g_TempClanDeposit[id] = 0;
		g_HatEnt[id] = 0;
		g_HatId[id] = HAT_NONE;
		g_HatNext[id] = HAT_NONE;
		for(new i = 0; i < structIdHats; ++i)
		{
			g_Hat[id][i] = 0;
			g_HatUnlocked[id][i] = 0;
		}
		g_HatTotal[id] = 0;
		g_Hat_Devil[id] = 0;
		g_Hat_Earth[id] = 0;
		for(new i = 0; i < MAX_AMULETS; ++i)
		{
			g_AmuletsInt[id][i] = {0, 0, 0, 0, 0, 0};
			formatex(g_AmuletsName[id][i], charsmax(g_AmuletsName[][]), "");
		}
		formatex(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "");
		g_AmuletEquip[id] = -1;
		g_AmuletNextEquip[id] = -1;
		g_AmuletCustomCreated[id] = 0;
		g_AmuletCustomCost[id] = 0;
		g_AmuletCustomName[id][0] = EOS;
		g_AmuletCustomNameFake[id][0] = EOS;
		g_AmuletCustom[id][acHealth] = 0;
		g_AmuletCustom[id][acSpeed] = 0;
		g_AmuletCustom[id][acGravity] = 0;
		g_AmuletCustom[id][acDamage] = 0;
		g_AmuletCustom[id][acMultAPs] = 0;
		g_AmuletCustom[id][acMultXP] = 0;
		g_AmuletCustom[id][acRespawnHuman] = 0;
		g_AmuletCustom[id][acReduceExtraItems] = 0;
		g_UserOption_Color[id][COLOR_TYPE_HUD_G] = {0, 255, 0};
		g_UserOption_Color[id][COLOR_TYPE_HUD_C] = {255, 255, 255};
		g_UserOption_Color[id][COLOR_TYPE_HUD_CC] = {255, 255, 255};
		g_UserOption_Color[id][COLOR_TYPE_NVISION] = {0, 255, 0};
		g_UserOption_Color[id][COLOR_TYPE_FLARE] = {255, 255, 255};
		g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW] = {255, 255, 255};
		g_UserOption_PositionHud[id][HUD_TYPE_GENERAL] = Float:{0.01, 0.1, 0.0};
		g_UserOption_PositionHud[id][HUD_TYPE_COMBO] = Float:{-1.0, 0.6, 1.0};
		g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO] = Float:{-1.0, 0.875, 1.0};
		g_UserOption_EffectHud[id] = {0, 0, 0};
		g_UserOption_MinimizeHud[id] = {0, 0, 0};
		g_UserOption_AbreviateHud[id] = {0, 0, 0};
		g_UserOption_ChatMode[id] = 1;
		g_UserOption_Invis[id] = 0;
		g_UserOption_ClanChat[id] = 0;
		g_StatsDamage[id][0] = 0.0;
		g_StatsDamage[id][1] = 0.0;
		for(new i = 0; i < structIdStats; ++i)
			g_Stats[id][i] = 0;
		for(new i = 0; i < structIdTimePlayed; ++i)
			g_PlayedTime[id][i] = 0;
		for(new i = 0; i < structIdHeadZombies; ++i)
			g_HeadZombie[id][i] = 0;
		g_HeadZombieLastTouch[id] = 0.0;
		g_BuyStuff[id] = 0;
		g_MiniGames_Number[id] = 2000;
		for(new i = 0; i < structIdPages; ++i)
			g_MenuPage[id][i] = 0;
		for(new i = 0; i < structIdDatas; ++i)
			g_MenuData[id][i] = 0;
		g_ModeL4D2_ZobieHealth[id] = 0;
		g_ModeL4D2_ZombieAcerts[id] = 0;
		g_ModeL4D2_Human[id] = 0;
		g_Painshock_Chite[id] = 0;
		g_Invisibility_Vrg[id] = 0;
	}

	checkMults(id);
}

executeQuery(const id, const Handle:sql_query, const query_id=0)
{
	static sErrors[512];
	SQL_QueryError(sql_query, sErrors, charsmax(sErrors));
	dg_log_to_file(LOG_MYSQL, 1, id, "[query_id: %d] %s", query_id, sErrors);

	if(isUserValidConnected(id))
		server_cmd("kick #%d ^"Hubo un error al guardar/cargar tus datos. Intente mas tarde^"", get_user_userid(id));

	SQL_FreeHandle(sql_query);
}

showDHUDMessage(const id, const color_r=255, const color_g=255, const color_b=255, const Float:pos_x=-1.0, const Float:pos_y=-1.0, const effect=0, const Float:time=0.1, const message[], any:...)
{
	static sMessage[MAX_FMT_LENGTH];
	vformat(sMessage, charsmax(sMessage), message, 10);

	if(id)
	{
		clearDHUD(id);

		set_dhudmessage(color_r, color_g, color_b, pos_x, pos_y, effect, 0.0, time, 1.0, 1.0);
		show_dhudmessage(id, sMessage);
	}
	else
	{
		static sPlayers[32];
		static iNum;
		static iUser;

		get_players(sPlayers, iNum, "ch");

		for(new i = 0; i < iNum; ++i)
		{
			iUser = sPlayers[i];

			clearDHUD(iUser);

			set_dhudmessage(color_r, color_g, color_b, pos_x, pos_y, effect, 0.0, time, 1.0, 1.0);
			show_dhudmessage(iUser, sMessage);
		}
	}
}

clearDHUD(const id, const all_channel=1)
{
	for(new i = 0; i < ((all_channel) ? 8 : 7); ++i)
	{
		set_dhudmessage(000, 000, 000, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0);
		show_dhudmessage(id, "");
	}
}

public playSound(const id, const sound[])
{
	if(containi(sound[strlen(sound) - 4], ".mp3") != -1)
		client_cmd(id, "mp3 play ^"%s^"", sound);
	else
		client_cmd(id, "spk ^"%s^"", sound);
}

emitSound(const id, const channel, const sample[], Float:volume=1.0, Float:attn=ATTN_NORM, flags=0, pitch=PITCH_NORM)
	emit_sound(id, channel, sample, volume, attn, flags, pitch);

public resetInfo(const id)
{
	if(!g_IsConnected[id])
		return;
	
	client_cmd(id, "setinfo bottomcolor ^"^"");
	client_cmd(id, "setinfo cl_lc ^"^"");
	client_cmd(id, "setinfo model ^"^"");
	client_cmd(id, "setinfo topcolor ^"^"");
	client_cmd(id, "setinfo _9387 ^"^"");
	client_cmd(id, "setinfo _iv ^"^"");
	client_cmd(id, "setinfo _ah ^"^"");
	client_cmd(id, "setinfo _puqz ^"^"");
	client_cmd(id, "setinfo _ndmh ^"^"");
	client_cmd(id, "setinfo _ndmf ^"^"");
	client_cmd(id, "setinfo _ndms ^"^"");
}

public addDot(const number, output[], const output_len)
{
	static sTemp[16];
	static iOutputPos;
	static iNumPos;
	static iNumLen;
	
	iOutputPos = 0;
	iNumPos = 0;
	iNumLen = num_to_str(number, sTemp, charsmax(sTemp));
	
	while((iNumPos < iNumLen) && (iOutputPos < output_len))
	{
		output[iOutputPos++] = sTemp[iNumPos++];
		
		if((iNumLen - iNumPos) && !((iNumLen - iNumPos) % 3))
			output[iOutputPos++] = '.';
	}
	
	output[iOutputPos] = EOS;
	return iOutputPos;
}

public addDotSpecial(const number[], output[], const output_len)
{
	static iOutputPos;
	static iNumPos;
	static iNumLen;
	
	iOutputPos = 0;
	iNumPos = 0;
	iNumLen = contain(number, ".");
	
	if(iNumLen == -1)
		iNumLen = strlen(number);
	
	while((iNumPos < iNumLen) && (iOutputPos < output_len))
	{
		output[iOutputPos++] = number[iNumPos++];
		
		if((iOutputPos < output_len) && (iNumPos < iNumLen) && (((iNumLen - iNumPos) % 3) == 0))
			output[iOutputPos++] = '.';
	}
	
	if(iOutputPos < output_len)
		iOutputPos += copy(output[iOutputPos], (output_len - iOutputPos), number[iNumLen]);
	
	return iOutputPos;
}

public task__CheckAchievements(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return;

	if(g_AccountVinc[id])
		setAchievement(id, VINCULADO);

	if(get_user_flags(id) & ADMIN_RESERVATION)
	{
		setAchievement(id, SOY_DORADO);
		giveHat(id, HAT_GOLD_HEAD);
	}

	if(!g_Achievement[id][CUENTA_PAR] && !g_Achievement[id][CUENTA_IMPAR])
	{
		if((g_AccountId[id] % 2) == 0)
			setAchievement(id, CUENTA_PAR);
		else
			setAchievement(id, CUENTA_IMPAR);
	}

	if(g_StatsDamage[id][0] >= 1000)
	{
		setAchievement(id, MIRA_MI_DANIO);
		if(g_StatsDamage[id][0] >= 5000)
		{
			setAchievement(id, MAS_Y_MAS_DANIO);
			if(g_StatsDamage[id][0] >= 10000)
			{
				setAchievement(id, LLEGUE_AL_MILLON);
				if(g_StatsDamage[id][0] >= 50000)
				{
					if(g_StatsDamage[id][0] >= 250000)
					{
						if(g_StatsDamage[id][0] >= 500000)
						{
							if(g_StatsDamage[id][0] >= 1000000)
							{
								if(g_StatsDamage[id][0] >= 5000000)
								{
									if(g_StatsDamage[id][0] >= 10000000)
									{
										if(g_StatsDamage[id][0] >= 50000000)
										{
											if(g_StatsDamage[id][0] >= 200000000)
											{
												if(g_StatsDamage[id][0] >= 500000000)
												{
													if(g_StatsDamage[id][0] >= 1000000000)
													{
														if(g_StatsDamage[id][0] >= 2100000000)
															setAchievement(id, NO_SE_LEER_ESTE_NUMERO);
														else
															setAchievement(id, ME_ABURRO);
													}
													else
														setAchievement(id, SE_ME_BUGUEO_EL_DANIO);
												}
												else
													setAchievement(id, MUCHOS_NUMEROS);
											}
											else
												setAchievement(id, MI_DANIO_ES_NUCLEAR);
										}
										else
											setAchievement(id, MI_DANIO_ES_CATASTROFICO);
									}
									else
										setAchievement(id, YA_PERDI_LA_CUENTA);
								}
								else
									setAchievement(id, CONTADOR_DE_DANIOS);
							}
							else
								setAchievement(id, VAMOS_POR_LOS_50_MILLONES);
						}
						else
							setAchievement(id, MI_DANIO_CRECE_Y_CRECE);
					}
					else
						setAchievement(id, MI_DANIO_CRECE);
				}
			}
		}
	}

	if(g_Stats[id][STAT_HS_D] < 10000000)
	{
		if(g_Stats[id][STAT_HS_D] < 5000000)
		{
			if(g_Stats[id][STAT_HS_D] < 1000000)
			{
				if(g_Stats[id][STAT_HS_D] < 500000)
				{
					if(g_Stats[id][STAT_HS_D] < 300000)
					{
						if(g_Stats[id][STAT_HS_D] < 150000)
						{
							if(g_Stats[id][STAT_HS_D] < 50000)
							{
								if(g_Stats[id][STAT_HS_D] < 15000)
								{
									if(g_Stats[id][STAT_HS_D] >= 5000)
										setAchievement(id, CABEZITA);
								}
								else
									setAchievement(id, A_PLENO);
							}
							else
								setAchievement(id, ROMPIENDO_CABEZAS);
						}
						else
							setAchievement(id, ABRIENDO_CEREBROS);
					}
					else
						setAchievement(id, PERFORANDO);
				}
				else
					setAchievement(id, DESCOCANDO);
			}
			else
				setAchievement(id, ROMPECRANEOS);
		}
		else
			setAchievement(id, DUCK_HUNT);
	}
	else
		setAchievement(id, AIMBOT);

	if(g_Stats[id][STAT_AP_D] < 100000)
	{
		if(g_Stats[id][STAT_AP_D] < 60000)
		{
			if(g_Stats[id][STAT_AP_D] < 30000)
			{
				if(g_Stats[id][STAT_AP_D] < 5000)
				{
					if(g_Stats[id][STAT_AP_D] < 2000)
					{
						if(g_Stats[id][STAT_AP_D] >= 500)
							setAchievement(id, SACANDO_PROTECCION);
					}
					else
						setAchievement(id, ESO_NO_TE_SIRVE_DE_NADA);
				}
				else
					setAchievement(id, NO_ES_UN_PROBLEMA_PARA_MI);
			}
			else
				setAchievement(id, SIN_DEFENSAS);
		}
		else
			setAchievement(id, DESGARRANDO_CHALECO);
	}
	else
		setAchievement(id, TOTALMENTE_INDEFENSO);

	switch(g_PlayedTime[id][TIME_DAY])
	{
		case 1: setAchievement(id, ENTRENANDO);
		case 7: setAchievement(id, ESTOY_MUY_SOLO);
		case 15:
		{
			setAchievement(id, FOREVER_ALONE);
			giveHat(id, HAT_VIKING);
		}
		case 30: setAchievement(id, CREO_QUE_TENGO_UN_PROBLEMA);
		case 50: setAchievement(id, SOLO_EL_ZP_ME_ENTIENDE);
	}

	if(g_ClanSlot[id] && g_Clan[g_ClanSlot[id]][clanChampion] == 1)
		giveHat(id, HAT_SCREAM);
	
	// if(g_AccountId[id] == 162 || g_AccountId[id] == 1379 || g_AccountId[id] == 1263 || g_AccountId[id] == 336)
		// giveHat(id, HAT_1ER_PUESTO);
	
	// if(g_AccountId[id] == 10 || g_AccountId[id] == 118 || g_AccountId[id] == 5 || g_AccountId[id] == 769)
		// giveHat(id, HAT_2DO_PUESTO);
	
	// if(g_AccountId[id] == 6 || g_AccountId[id] == 38 || g_AccountId[id] == 127 || g_AccountId[id] == 85)
		// giveHat(id, HAT_3ER_PUESTO);

	if(getPlaying() > 6)
	{
		g_LogSay = 0;
		set_cvar_num("sv_voiceenable", 1);
	}
}

public getUserTeam(const id)
{
	if(pev_valid(id) != PDATA_SAFE)
		return F_TEAM_NONE;

	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

public setUserTeam(const id, const team)
{
	if(pev_valid(id) != PDATA_SAFE)
		return;

	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX);
}

public containLetters(const string[])
{
	static iLen;
	iLen = strlen(string);
	
	for(new i = 0; i < iLen; ++i)
	{
		if(!isalpha(string[i]))
			return 0;
	}
	
	return 1;
}

public countNumbers(const string[])
{
	static iLen;
	iLen = strlen(string);
	
	for(new i = 0; i < iLen; ++i)
	{
		if(isdigit(string[i]))
			return 1;
	}
	
	return 0;
}

public getPlaying()
{
	static iCount;
	static iTeam;

	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i])
		{
			iTeam = getUserTeam(i);
			
			if(iTeam != F_TEAM_NONE && iTeam != F_TEAM_SPECTATOR)
				++iCount;
		}
	}
	
	return iCount;
}

public getHumans()
{
	static iCount;
	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i] && !g_Zombie[i])
			++iCount;
	}
	
	return iCount;
}

public getZombies()
{
	static iCount;
	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i] && g_Zombie[i])
			++iCount;
	}
	
	return iCount;
}

public getAlives()
{
	static iCount;
	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i])
			++iCount;
	}
	
	return iCount;
}

public getTs()
{
	static iCount;
	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i])
		{
			if(getUserTeam(i) == F_TEAM_T)
				++iCount;
		}
	}
	
	return iCount;
}

public getCTs()
{
	static iCount;
	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i])
		{
			if(getUserTeam(i) == F_TEAM_CT)
				++iCount;
		}
	}
	
	return iCount;
}

public getAlivesTs()
{
	static iCount;
	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i])
		{
			if(getUserTeam(i) == F_TEAM_T)
				++iCount;
		}
	}
	
	return iCount;
}

public getAlivesCTs()
{
	static iCount;
	iCount = 0;
	
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i])
		{
			if(getUserTeam(i) == F_TEAM_CT)
				++iCount;
		}
	}
	
	return iCount;
}

startMode(const mode_id, id=0, id2=0)
{
	static iUsersAlive;
	iUsersAlive = getAlives();

	if(mode_id == MODE_NONE)
	{
		if(iUsersAlive < MIN_USERS_FOR_GAME && !id)
		{
			client_print(id, print_center, "Se necesitan %d o más jugadores para que comience el juego", MIN_USERS_FOR_GAME);

			set_task(10.0, "task__StartMode", TASK_START_MODE);
			return;
		}
	}

	g_VirusT = 2;

	if(mode_id != 0)
	{
		if(g_StartMode[0] != MODE_INFECTION && g_StartMode[0] != MODE_PLAGUE)
			g_StartMode[1] = g_StartMode[0];

		g_StartMode[0] = mode_id;

		setMode(mode_id, id, id2);

		chooseMode();
		return;
	}

	setMode(g_StartMode[0], id, id2);
	chooseMode();

	if(g_EventModes)
	{
		--g_EventMode_MegaArmageddon;
		--g_EventMode_GunGame;

		if(g_EventMode_GunGame == 0)
			g_StartMode[1] = MODE_GUNGAME;
		else if(g_EventMode_MegaArmageddon == 0)
			g_StartMode[1] = MODE_MEGA_ARMAGEDDON;
	}
}

public chooseMode()
{
	if(g_ModeMGG_Played == 2)
	{
		g_StartMode[1] = MODE_MEGA_GUNGAME;
		return;
	}

	static iUsersAlive;
	iUsersAlive = getAlives();

	if(g_StartMode[0] == MODE_NONE && g_StartMode[1] == MODE_NONE)
	{
		if(g_EventModes)
			g_StartMode[0] = ((iUsersAlive >= 4) ? MODE_ARMAGEDDON : MODE_PLAGUE);
		else
			g_StartMode[0] = MODE_INFECTION;
	}

	// (0) = MODO ACTUAL
	// (1) = MODO SIGUIENTE

	if(g_EventModes)
	{
		if(iUsersAlive >= MIN_USERS_FOR_EVENTMODES)
		{
			if(random_num(1, 7) == __MODES[MODE_ARMAGEDDON][modeOn] && iUsersAlive >= __MODES[MODE_ARMAGEDDON][modeUsersNeed] && g_LastMode != MODE_ARMAGEDDON)
				g_StartMode[1] = MODE_ARMAGEDDON;
			else if(random_num(1, 7) == __MODES[MODE_FVSJ][modeOn] && iUsersAlive >= __MODES[MODE_FVSJ][modeUsersNeed] && g_LastMode != MODE_FVSJ)
				g_StartMode[1] = MODE_FVSJ;
			else if(random_num(1, 7) == __MODES[MODE_SYNAPSIS][modeOn] && iUsersAlive >= __MODES[MODE_SYNAPSIS][modeUsersNeed] && g_LastMode != MODE_SYNAPSIS)
				g_StartMode[1] = MODE_SYNAPSIS;
			else if(random_num(1, 7) == __MODES[MODE_AVSP][modeOn] && iUsersAlive >= __MODES[MODE_AVSP][modeUsersNeed] && g_LastMode != MODE_AVSP)
				g_StartMode[1] = MODE_AVSP;
			else if(random_num(1, 7) == __MODES[MODE_DUEL_FINAL][modeOn] && iUsersAlive >= __MODES[MODE_DUEL_FINAL][modeUsersNeed] && g_LastMode != MODE_DUEL_FINAL)
				g_StartMode[1] = MODE_DUEL_FINAL;
			else if(random_num(1, 7) == __MODES[MODE_DRUNK][modeOn] && iUsersAlive >= __MODES[MODE_DRUNK][modeUsersNeed] && g_LastMode != MODE_DRUNK)
				g_StartMode[1] = MODE_DRUNK;
			else if(random_num(1, 5) == __MODES[MODE_SURVIVOR][modeOn] && iUsersAlive >= __MODES[MODE_SURVIVOR][modeUsersNeed] && g_LastMode != MODE_SURVIVOR)
				g_StartMode[1] = MODE_SURVIVOR;
			else if(random_num(1, 5) == __MODES[MODE_WESKER][modeOn] && iUsersAlive >= __MODES[MODE_WESKER][modeUsersNeed] && g_LastMode != MODE_WESKER)
				g_StartMode[1] = MODE_WESKER;
			else if(random_num(1, 5) == __MODES[MODE_SNIPER_ELITE][modeOn] && iUsersAlive >= __MODES[MODE_SNIPER_ELITE][modeUsersNeed] && g_LastMode != MODE_SNIPER_ELITE)
				g_StartMode[1] = MODE_SNIPER_ELITE;
			else if(random_num(1, 5) == __MODES[MODE_JASON][modeOn] && iUsersAlive >= __MODES[MODE_JASON][modeUsersNeed] && g_LastMode != MODE_JASON)
				g_StartMode[1] = MODE_JASON;
			else if(random_num(1, 5) == __MODES[MODE_NEMESIS][modeOn] && iUsersAlive >= __MODES[MODE_NEMESIS][modeUsersNeed] && g_LastMode != MODE_NEMESIS)
				g_StartMode[1] = MODE_NEMESIS;
			else if(random_num(1, 5) == __MODES[MODE_ASSASSIN][modeOn] && iUsersAlive >= __MODES[MODE_ASSASSIN][modeUsersNeed] && g_LastMode != MODE_ASSASSIN)
				g_StartMode[1] = MODE_ASSASSIN;
			else if(random_num(1, 5) == __MODES[MODE_ANNIHILATOR][modeOn] && iUsersAlive >= __MODES[MODE_ANNIHILATOR][modeUsersNeed] && g_LastMode != MODE_ANNIHILATOR)
				g_StartMode[1] = MODE_ANNIHILATOR;
			else if(random_num(1, 7) == __MODES[MODE_SNIPER][modeOn] && iUsersAlive >= __MODES[MODE_SNIPER][modeUsersNeed] && g_LastMode != MODE_SNIPER)
				g_StartMode[1] = MODE_SNIPER;
			else if(random_num(1, 7) == __MODES[MODE_TRIBAL][modeOn] && iUsersAlive >= __MODES[MODE_TRIBAL][modeUsersNeed] && g_LastMode != MODE_TRIBAL)
				g_StartMode[1] = MODE_TRIBAL;
			else if(random_num(1, 10) == __MODES[MODE_L4D2][modeOn] && iUsersAlive >= __MODES[MODE_L4D2][modeUsersNeed] && g_LastMode != MODE_L4D2)
				g_StartMode[1] = MODE_L4D2;
			else if(random_num(1, 15) == __MODES[MODE_GRUNT][modeOn] && iUsersAlive >= __MODES[MODE_GRUNT][modeUsersNeed] && g_LastMode != MODE_GRUNT)
				g_StartMode[1] = MODE_GRUNT;
			else
				g_StartMode[1] = MODE_PLAGUE;
		}
		else
			g_StartMode[1] = MODE_INFECTION;
	}
	else
	{
		if(random_num(1, 20) == __MODES[MODE_PLAGUE][modeOn] && iUsersAlive >= __MODES[MODE_PLAGUE][modeUsersNeed])
			g_StartMode[1] = MODE_PLAGUE;
		else if(random_num(1, 25) == __MODES[MODE_ARMAGEDDON][modeOn] && iUsersAlive >= __MODES[MODE_ARMAGEDDON][modeUsersNeed] && g_LastMode != MODE_ARMAGEDDON)
			g_StartMode[1] = MODE_ARMAGEDDON;
		else if(random_num(1, 25) == __MODES[MODE_FVSJ][modeOn] && iUsersAlive >= __MODES[MODE_FVSJ][modeUsersNeed] && g_LastMode != MODE_FVSJ)
			g_StartMode[1] = MODE_FVSJ;
		else if(random_num(1, 25) == __MODES[MODE_SYNAPSIS][modeOn] && iUsersAlive >= __MODES[MODE_SYNAPSIS][modeUsersNeed] && g_LastMode != MODE_SYNAPSIS)
			g_StartMode[1] = MODE_SYNAPSIS;
		else if(random_num(1, 25) == __MODES[MODE_AVSP][modeOn] && iUsersAlive >= __MODES[MODE_AVSP][modeUsersNeed] && g_LastMode != MODE_AVSP)
			g_StartMode[1] = MODE_AVSP;
		else if(random_num(1, 25) == __MODES[MODE_DUEL_FINAL][modeOn] && iUsersAlive >= __MODES[MODE_DUEL_FINAL][modeUsersNeed] && g_LastMode != MODE_DUEL_FINAL)
			g_StartMode[1] = MODE_DUEL_FINAL;
		else if(random_num(1, 25) == __MODES[MODE_DRUNK][modeOn] && iUsersAlive >= __MODES[MODE_DRUNK][modeUsersNeed] && g_LastMode != MODE_DRUNK)
			g_StartMode[1] = MODE_DRUNK;
		else if(random_num(1, 10) == __MODES[MODE_SURVIVOR][modeOn] && iUsersAlive >= __MODES[MODE_SURVIVOR][modeUsersNeed] && g_LastMode != MODE_SURVIVOR)
			g_StartMode[1] = MODE_SURVIVOR;
		else if(random_num(1, 30) == __MODES[MODE_WESKER][modeOn] && iUsersAlive >= __MODES[MODE_WESKER][modeUsersNeed] && g_LastMode != MODE_WESKER)
			g_StartMode[1] = MODE_WESKER;
		else if(random_num(1, 30) == __MODES[MODE_SNIPER_ELITE][modeOn] && iUsersAlive >= __MODES[MODE_SNIPER_ELITE][modeUsersNeed] && g_LastMode != MODE_SNIPER_ELITE)
			g_StartMode[1] = MODE_SNIPER_ELITE;
		else if(random_num(1, 30) == __MODES[MODE_JASON][modeOn] && iUsersAlive >= __MODES[MODE_JASON][modeUsersNeed] && g_LastMode != MODE_JASON)
			g_StartMode[1] = MODE_JASON;
		else if(random_num(1, 10) == __MODES[MODE_NEMESIS][modeOn] && iUsersAlive >= __MODES[MODE_NEMESIS][modeUsersNeed] && g_LastMode != MODE_NEMESIS)
			g_StartMode[1] = MODE_NEMESIS;
		else if(random_num(1, 30) == __MODES[MODE_ASSASSIN][modeOn] && iUsersAlive >= __MODES[MODE_ASSASSIN][modeUsersNeed] && g_LastMode != MODE_ASSASSIN)
			g_StartMode[1] = MODE_ASSASSIN;
		else if(random_num(1, 30) == __MODES[MODE_ANNIHILATOR][modeOn] && iUsersAlive >= __MODES[MODE_ANNIHILATOR][modeUsersNeed] && g_LastMode != MODE_ANNIHILATOR)
			g_StartMode[1] = MODE_ANNIHILATOR;
		else if(random_num(1, 25) == __MODES[MODE_SNIPER][modeOn] && iUsersAlive >= __MODES[MODE_SNIPER][modeUsersNeed] && g_LastMode != MODE_SNIPER)
			g_StartMode[1] = MODE_SNIPER;
		else if(random_num(1, 25) == __MODES[MODE_TRIBAL][modeOn] && iUsersAlive >= __MODES[MODE_TRIBAL][modeUsersNeed] && g_LastMode != MODE_TRIBAL)
			g_StartMode[1] = MODE_TRIBAL;
		else if(random_num(1, 40) == __MODES[MODE_L4D2][modeOn] && iUsersAlive >= __MODES[MODE_L4D2][modeUsersNeed] && g_LastMode != MODE_L4D2)
			g_StartMode[1] = MODE_L4D2;
		else if(random_num(1, 25) == __MODES[MODE_GRUNT][modeOn] && iUsersAlive >= __MODES[MODE_GRUNT][modeUsersNeed] && g_LastMode != MODE_GRUNT)
			g_StartMode[1] = MODE_GRUNT;
		else
			g_StartMode[1] = MODE_INFECTION;
	}
}

setMode(const mode_id, id=0, id2=0)
{
	remove_task(TASK_VIRUST);
	remove_task(TASK_START_MODE);

	g_Lights[0] = 'b';

	if(mode_id == MODE_DUEL_FINAL || mode_id == MODE_L4D2 || mode_id == MODE_GUNGAME || mode_id == MODE_MEGA_GUNGAME)
		g_Lights[0] = 'i';
	else if(mode_id == MODE_ASSASSIN || mode_id == MODE_GRUNT)
		g_Lights[0] = 'a';

	g_NewRound = 0;
	g_Mode = mode_id;
	g_LastMode = mode_id;
	if(g_StartMode_Force) g_StartMode_Force = 0;

	changeLights();

	static iUsersAlive;
	static iMaxUsers;
	static iUsers;

	iUsersAlive = getAlives();
	iMaxUsers = 0;
	iUsers = 0;

	switch(mode_id)
	{
		case MODE_INFECTION:
		{
			iMaxUsers = (iUsersAlive / 2);
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				id = getRandomUser(1);

				if(!g_IsAlive[id] || g_Zombie[id])
					continue;

				zombieMe(id);
				++iUsers;
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				if(g_Zombie[i])
				{
					randomSpawn(i);
					continue;
				}

				if(g_Weapons[i][WEAPON_AUTO_BUY])
					buyGrenades(i);

				if(getUserTeam(i) != F_TEAM_CT)
				{
					remove_task(i + TASK_TEAM);

					setUserTeam(i, F_TEAM_CT);
					setUserTeamUpdate(i);
				}
			}

			g_ModeInfection_Systime = (get_systime() + 90);

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡INFECCIÓN!");
			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		}
		case MODE_PLAGUE:
		{
			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(getUserTeam(i) != F_TEAM_T)
				{
					if(g_Weapons[i][WEAPON_AUTO_BUY])
						buyGrenades(i);

					g_UnlimitedClip[i] = 1;
					continue;
				}

				zombieMe(i);
			}

			iMaxUsers = 2;
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				id = getRandomUser(.alive=1);

				if(g_SpecialMode[id] == MODE_SURVIVOR || g_SpecialMode[id] == MODE_NEMESIS)
					continue;

				if(!iUsers)
					humanMe(id, .survivor=1);
				else
					zombieMe(id, .nemesis=1);

				++iUsers;
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡PLAGUE!");
			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		}
		case MODE_ARMAGEDDON:
		{
			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			g_ModeArmageddon_Notice = 0;
			g_ModeArmageddon_Bubbles = 0;

			remove_task(TASK_MODE_ARMAGEDDON);
			set_task(0.1, "task__StartModeArmageddon", TASK_MODE_ARMAGEDDON);
		}
		case MODE_MEGA_ARMAGEDDON:
		{
			set_cvar_num("mp_round_infinite", 1);

			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			playSound(0, SOUND_ROUND_MEGA_ARMAGEDDON);

			static j;
			j = 0;

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

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

				j = strlen(g_PlayerSteamId[i]);

				if(equali(g_PlayerSteamId[i], "STEAM_ID_PENDING") || equali(g_PlayerSteamId[i], "STEAM_ID_LAN") || j <= 16 || (g_PlayerSteamId[i][0] == 'V' && g_PlayerSteamId[i][1] == 'A' && g_PlayerSteamId[i][2] == 'L'))
				{
					set_task(3.4, "task__MegaArmageddonEffect", i); // TUM
					set_task(4.1, "task__MegaArmageddonEffect", i); // TUMM
					set_task(4.8, "task__MegaArmageddonEffect", i); // TUMMM

					set_task(7.0, "task__MegaArmageddonBlackFade", i);

					set_task(10.5, "task__MegaArmageddonEffect", i); // TUM
					set_task(11.2, "task__MegaArmageddonEffect", i); // TUMM
					set_task(11.9, "task__MegaArmageddonEffect", i); // TUMMM
				}
				else // Estúpido fix para steam que el sonido de mp3 play empieza a reproducirse 1 segundo después de que se ejecuta
				{
					set_task(4.4, "task__MegaArmageddonEffect", i); // TUM
					set_task(5.1, "task__MegaArmageddonEffect", i); // TUMM
					set_task(5.8, "task__MegaArmageddonEffect", i); // TUMMM

					set_task(8.0, "task__MegaArmageddonBlackFade", i);

					set_task(11.5, "task__MegaArmageddonEffect", i); // TUM
					set_task(12.2, "task__MegaArmageddonEffect", i); // TUMM
				}
			}

			remove_task(TASK_MODE_MEGA_ARMAGEDDON);
			set_task(12.8, "task__StartModeMegaArmageddon", TASK_MODE_MEGA_ARMAGEDDON);
		}
		case MODE_GUNGAME:
		{
			set_cvar_num("mp_round_infinite", 1);

			g_ModeGG_End = 0;
			g_ModeGG_SysTime = get_systime();

			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				if(g_HatId[i])
				{
					if(is_valid_ent(g_HatEnt[i]))
					{
						entity_set_int(g_HatEnt[i], EV_INT_rendermode, kRenderTransAlpha);
						entity_set_float(g_HatEnt[i], EV_FL_renderamt, 0.0);
					}
				}

				entity_set_int(i, EV_INT_rendermode, kRenderNormal);
				entity_set_float(i, EV_FL_renderamt, 255.0);

				g_ModeGG_Level[i] = 1;
				g_ModeGG_Kills[i] = 0;
				g_ModeGG_Headshots[i] = 0;
				g_ModeGGCrazy_Level[i] = random_num(1, 25);
				g_ModeGGCrazy_ListLevel[i][0] = 1;
				for(new j = 1; j < 26; ++j)
					g_ModeGGCrazy_ListLevel[i][j] = 0;

				set_user_health(i, HUMAN_BASE_HEALTH_MIN);
				g_Speed[i] = HUMAN_BASE_SPEED_MIN;
				set_user_gravity(i, HUMAN_BASE_GRAVITY_MIN);
				set_user_armor(i, 0);

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);

				randomSpawn(i);

				gunGameGiveWeapons(i);
			}

			showDHUDMessage(0, random(256), random(256), random(256), -1.0, -1.0, random_num(0, 1), 10.0, "¡GUNGAME: %s!", GUNGAME_TYPE_NAME[g_ModeGG_Type]);
			playSound(0, SOUND_ROUND_GUNGAME);
		}
		case MODE_MEGA_GUNGAME:
		{
			g_ModeMGG_Played = 1;

			static Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_general SET round_mgg='1' WHERE id='1';");

			if(!SQL_Execute(sqlQuery))
				executeQuery(0, sqlQuery, 41);
			else
				SQL_FreeHandle(sqlQuery);

			set_cvar_num("mp_round_infinite", 1);

			g_ModeGG_End = 0;
			g_ModeMGG_Phase = 0;
			g_ModeMGG_Block = 0;

			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				if(g_HatId[i])
				{
					if(is_valid_ent(g_HatEnt[i]))
					{
						entity_set_int(g_HatEnt[i], EV_INT_rendermode, kRenderTransAlpha);
						entity_set_float(g_HatEnt[i], EV_FL_renderamt, 0.0);
					}
				}

				entity_set_int(i, EV_INT_rendermode, kRenderNormal);
				entity_set_float(i, EV_FL_renderamt, 255.0);

				g_ModeGG_Level[i] = 1;
				g_ModeGG_Kills[i] = 0;
				g_ModeGG_Headshots[i] = 0;
				g_ModeMGG_Health[i] = 0;

				set_user_health(i, HUMAN_BASE_HEALTH_MIN);
				g_Speed[i] = HUMAN_BASE_SPEED_MIN;
				set_user_gravity(i, HUMAN_BASE_GRAVITY_MIN);
				set_user_armor(i, 0);

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);

				randomSpawn(i);

				give_item(i, MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[i]]);

				if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]] != 0)
				{
					ExecuteHamB(Ham_GiveAmmo, i, MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]], AMMO_TYPE[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]], MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]]);
					replaceWeaponModels(i, MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]);
				}
			}

			showDHUDMessage(0, random(256), random(256), random(256), -1.0, -1.0, random_num(0, 1), 10.0, "¡MEGA GUNGAME!");
			playSound(0, SOUND_ROUND_GUNGAME);
		}
		case MODE_FVSJ:
		{
			message_begin(MSG_BROADCAST, g_Message_ScreenFade);
			write_short(UNIT_SECOND * 4);
			write_short(UNIT_SECOND * 3);
			write_short(FFADE_STAYOUT);
			write_byte(0);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			message_end();

			playSound(0, SOUND_ROUND_FVSJ);

			remove_task(TASK_MODE_FVSJ);
			set_task(10.0, "task__StartModeFvsJ", TASK_MODE_FVSJ);
		}
		case MODE_L4D2:
		{
			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				id = getRandomUser(1);
				
				if(g_SpecialMode[id] == MODE_L4D2)
					continue;

				++iUsers;
				humanMe(id, .l4d2=iUsers);
			}

			new j = 0;
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(g_SpecialMode[i] == MODE_L4D2 || g_Zombie[i])
					continue;

				g_ModeL4D2_ZobieHealth[i] = 0;

				zombieMe(i);

				++j;
			}

			showDHUDMessage(0, 199, 21, 133, -1.0, 0.25, 0, 15.0, "¡L4D2!");
			playSound(0, SOUND_ROUND_L4D2);

			g_ModeL4D2_ZombiesTotal = (j * 15);
			g_ModeL4D2_Zombies = g_ModeL4D2_ZombiesTotal;
		}
		case MODE_SYNAPSIS:
		{
			iMaxUsers = 3;
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				if(isUserValid(g_ModeSynapsis_Id[iUsers]))
					id = g_ModeSynapsis_Id[iUsers];
				else
					id = getRandomUser(1);

				if(g_SpecialMode[id] == MODE_NEMESIS)
					continue;

				zombieMe(id, .nemesis=1);
				++iUsers;
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				g_UnlimitedClip[i] = 1;
				g_PrecisionPerfect[i] = 1;

				if(g_Zombie[i] || g_SpecialMode[i])
				{
					randomSpawn(i);
					continue;
				}

				if(getUserTeam(i) != F_TEAM_CT)
				{
					remove_task(i + TASK_TEAM);

					setUserTeam(i, F_TEAM_CT);
					setUserTeamUpdate(i);
				}
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡SYNAPSIS!");
			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);

			for(new m = 0; m < 3; ++m)
			{
				if(g_ModeSynapsis_Id[m])
					g_ModeSynapsis_Id[m] = 0;
			}
		}
		case MODE_AVSP:
		{
			EnableHamForward(g_HamTouchWall);
			EnableHamForward(g_HamTouchBreakeable);
			EnableHamForward(g_HamTouchWorldspawn);

			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			static iIds[2];
			iIds = {0, 0};

			if(!id)
			{
				iMaxUsers = 2;
				iUsers = 0;

				while(iUsers < iMaxUsers)
				{
					id = getRandomUser(.alive=1);

					if(g_SpecialMode_Alien[id])
						continue;

					if(!iUsers)
					{
						zombieMe(id, .alien=1);
						iIds[0] = id;
					}
					else
					{
						humanMe(id, .predator=1);
						iIds[1] = id;
					}
					
					++iUsers;
				}
			}
			else
			{
				if(g_IsConnected[id])
				{
					zombieMe(id, .alien=1);
					iIds[0] = id;
				}
				else
				{
					id = 0;
					while(!id)
					{
						id = getRandomUser(.alive=1);
						
						if(g_SpecialMode_Alien[id])
						{
							id = 0;
							continue;
						}
						
						zombieMe(id, .alien=1);
					}
				}

				if(g_IsConnected[id2])
				{
					humanMe(id2, .predator=1);
					iIds[1] = id;
				}
				else
				{
					id2 = 0;
					while(!id2)
					{
						id2 = getRandomUser(.alive=1);

						if(g_SpecialMode_Alien[id2])
						{
							id2 = 0;
							continue;
						}
						
						humanMe(id2, .predator=1);
					}
				}
			}

			for(id = 1; id <= g_MaxPlayers; ++id)
			{
				if(!g_IsAlive[id])
					continue;

				randomSpawn(id);

				if(getUserTeam(id) != F_TEAM_T)
				{
					if(!g_SpecialMode_Predator[id])
					{
						set_user_health(id, (g_Health[id] + random_num(350, 1000)));
						g_Health[id] = get_user_health(id);

						if(g_Weapons[id][WEAPON_AUTO_BUY])
							buyGrenades(id);
					}

					continue;
				}

				if(g_SpecialMode_Alien[id])
					continue;

				zombieMe(id);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡ALIEN vs DEPREDADOR!^n%s es el ALIEN^n%s es el DEPREDADOR", g_PlayerName[iIds[0]], g_PlayerName[iIds[1]]);
			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		}
		case MODE_DUEL_FINAL:
		{
			set_cvar_num("mp_round_infinite", 1);

			g_ModeDuelFinal = DF_ALL;
			g_ModeDuelFinal_First = 0;

			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			if(!g_ModeDuelFinal_Type)
			{
				static iRandom;
				iRandom = random_num(DF_TYPE_KNIFE, DF_TYPE_SCOUTS);

				switch(iRandom)
				{
					case DF_TYPE_KNIFE: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), "");
					case DF_TYPE_AWP: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de AWP");
					case DF_TYPE_HE: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de HE");
					case DF_TYPE_OH: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de DEAGLE (ONLY HEAD)");
					case DF_TYPE_M3: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de ESCOPETAS");
					case DF_TYPE_SCOUTS: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de SCOUTS");
				}

				g_ModeDuelFinal_Type = iRandom;
			}
			else
			{
				switch(g_ModeDuelFinal_Type)
				{
					case DF_TYPE_KNIFE: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), "");
					case DF_TYPE_AWP: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de AWP");
					case DF_TYPE_HE: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de HE");
					case DF_TYPE_OH: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de DEAGLE (ONLY HEAD)");
					case DF_TYPE_M3: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de ESCOPETAS");
					case DF_TYPE_SCOUTS: formatex(g_ModeDuelFinal_TypeName, charsmax(g_ModeDuelFinal_TypeName), " de SCOUTS");
				}
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				g_ModeDuelFinal_KillsTotal[i] = 0;

				if(!g_IsAlive[i])
					continue;

				set_user_health(i, HUMAN_BASE_HEALTH_MIN);
				g_Speed[i] = HUMAN_BASE_SPEED_MIN;
				set_user_gravity(i, HUMAN_BASE_GRAVITY_MIN);
				set_user_armor(i, 0);

				if(g_ModeDuelFinal_Type == DF_TYPE_SCOUTS)
				{
					set_user_health(i, (get_user_health(i) + 75));
					g_Health[i] = get_user_health(i);
				}

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);

				randomSpawn(i);

				if(g_HatId[i])
				{
					if(is_valid_ent(g_HatEnt[i]))
					{
						entity_set_int(g_HatEnt[i], EV_INT_rendermode, kRenderTransAlpha);
						entity_set_float(g_HatEnt[i], EV_FL_renderamt, 0.0);
					}
				}

				entity_set_int(i, EV_INT_rendermode, kRenderNormal);
				entity_set_float(i, EV_FL_renderamt, 255.0);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡DUELO FINAL%s!", g_ModeDuelFinal_TypeName);
			playSound(0, SOUND_ROUND_SPECIAL);
		}
		case MODE_DRUNK:
		{
			if(!getAlivesTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_T);

				setUserTeamUpdate(id);
			}
			else if(!getAlivesCTs())
			{
				id = getRandomUser(.alive=1);

				remove_task(id + TASK_TEAM);
				setUserTeam(id, F_TEAM_CT);

				setUserTeamUpdate(id);
			}

			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				id = getRandomUser(1);

				if(g_SpecialMode[id] == MODE_NEMESIS)
					continue;

				zombieMe(id, .nemesis=1);
				++iUsers;
			}

			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				id = getRandomUser(1);

				if(g_SpecialMode[id])
					continue;

				if(iUsers == 0)
					humanMe(id, .survivor=1);
				else if(iUsers == 1)
					humanMe(id, .sniper=1);
				else if(iUsers == 2)
					humanMe(id, .sniper=2);
				else if(iUsers == 3)
					humanMe(id, .jason=1);

				++iUsers;
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(getUserTeam(i) != F_TEAM_T)
				{
					if(!g_SpecialMode[i])
					{
						if(g_Weapons[i][WEAPON_AUTO_BUY])
							buyGrenades(i);

						set_user_health(i, 7500);
						g_Health[i] = 7500;

						g_UnlimitedClip[i] = 1;
						g_PrecisionPerfect[i] = 1;
					}

					continue;
				}

				if(g_SpecialMode[i])
					continue;

				zombieMe(i);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡DRUNK!");
			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		}
		case MODE_SNIPER:
		{
			iMaxUsers = 4;
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				if(isUserValid(g_ModeSniper_Id[iUsers]))
					id = g_ModeSniper_Id[iUsers];
				else
					id = getRandomUser(1);

				if(g_SpecialMode[id] == MODE_SNIPER)
					continue;

				++iUsers;
				humanMe(id, .sniper=iUsers);
			}

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(g_SpecialMode[i] == MODE_SNIPER)
					continue;

				zombieMe(i);
			}

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡SNIPER!");
			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);

			for(new m = 0; m < 2; ++m)
			{
				if(g_ModeSniper_Id[m])
					g_ModeSniper_Id[m] = 0;
			}
		}
		case MODE_TRIBAL:
		{
			g_ModeTribal_Power = 1;

			iMaxUsers = 2;
			iUsers = 0;

			while(iUsers < iMaxUsers)
			{
				if(isUserValid(g_ModeTribal_Id[iUsers]))
					id = g_ModeTribal_Id[iUsers];
				else
					id = getRandomUser(1);

				if(g_SpecialMode[id] == MODE_TRIBAL)
					continue;

				++iUsers;
				humanMe(id, .tribal=iUsers);

				++g_Stats[id][STAT_T_M_C];
			}
			
			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(g_SpecialMode[i] == MODE_TRIBAL)
					continue;

				zombieMe(i);
			}

			showDHUDMessage(0, 255, 165, 0, -1.0, 0.25, 0, 15.0, "¡TRIBAL!");
			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);

			for(new m = 0; m < 2; ++m)
			{
				if(g_ModeTribal_Id[m])
					g_ModeTribal_Id[m] = 0;
			}
		}
		case MODE_SURVIVOR:
		{
			if(id == 0)
				id = getRandomUser(.alive=1);

			humanMe(id, .survivor=1);

			++g_Stats[id][STAT_S_M_C];

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(id == i || g_Zombie[i])
					continue;

				zombieMe(i);
			}

			showDHUDMessage(0, 0, 0, 255, -1.0, 0.25, 0, 15.0, "¡%s ES SURVIVOR!", g_PlayerName[id]);
			playSound(0, SOUND_ROUND_SURVIVOR[random_num(0, charsmax(SOUND_ROUND_SURVIVOR))]);
		}
		case MODE_WESKER:
		{
			if(id == 0)
				id = getRandomUser(.alive=1);

			humanMe(id, .wesker=1);

			++g_Stats[id][STAT_W_M_C];

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(id == i || g_Zombie[i])
					continue;

				zombieMe(i);
			}

			showDHUDMessage(0, 0, 255, 255, -1.0, 0.25, 0, 15.0, "¡%s ES WESKER!", g_PlayerName[id]);
			playSound(0, SOUND_ROUND_SURVIVOR[random_num(0, charsmax(SOUND_ROUND_SURVIVOR))]);
		}
		case MODE_SNIPER_ELITE:
		{
			if(id == 0)
				id = getRandomUser(.alive=1);

			humanMe(id, .sniper_elite=1);

			++g_Stats[id][STAT_SN_M_C];

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(id == i || g_Zombie[i])
					continue;

				zombieMe(i);
			}

			g_ModeSniperElite_ZombieLeft = (iUsersAlive * 5);

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 15.0, "¡%s ES SNIPER ELITE!", g_PlayerName[id]);
			playSound(0, SOUND_ROUND_SURVIVOR[random_num(0, charsmax(SOUND_ROUND_SURVIVOR))]);
		}
		case MODE_JASON:
		{
			if(id == 0)
				id = getRandomUser(.alive=1);

			humanMe(id, .jason=1);

			++g_Stats[id][STAT_J_M_C];

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(id == i || g_Zombie[i])
					continue;

				zombieMe(i);
			}

			showDHUDMessage(0, 255, 0, 255, -1.0, 0.25, 0, 15.0, "¡%s ES JASON!", g_PlayerName[id]);
			playSound(0, SOUND_ROUND_SURVIVOR[random_num(0, charsmax(SOUND_ROUND_SURVIVOR))]);
		}
		case MODE_NEMESIS:
		{
			if(id == 0)
				id = getRandomUser(.alive=1);

			zombieMe(id, .nemesis=1);

			++g_Stats[id][STAT_N_M_C];

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(id == i || g_Zombie[i])
					continue;

				if(getUserTeam(i) != F_TEAM_CT)
				{
					remove_task(i + TASK_TEAM);
					
					setUserTeam(i, F_TEAM_CT);
					setUserTeamUpdate(i);
				}
			}

			showDHUDMessage(0, 255, 0, 0, -1.0, 0.25, 0, 15.0, "¡%s ES NEMESIS!", g_PlayerName[id]);
			playSound(0, SOUND_ROUND_NEMESIS[random_num(0, charsmax(SOUND_ROUND_NEMESIS))]);
		}
		case MODE_ASSASSIN:
		{
			set_cvar_num("sv_alltalk", 0);

			if(id == 0)
				id = getRandomUser(.alive=1);

			zombieMe(id, .assassin=1);

			++g_Stats[id][STAT_A_M_C];

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(id == i || g_Zombie[i])
					continue;

				if(getUserTeam(i) != F_TEAM_CT)
				{
					remove_task(i + TASK_TEAM);
					
					setUserTeam(i, F_TEAM_CT);
					setUserTeamUpdate(i);
				}
			}

			g_ModeAssassin_RewardAssassin = 0;
			g_ModeAssassin_RewardHumans = ((iUsersAlive - 1) * (((g_HappyTime == 2) ? 5 : ((g_HappyTime == 1) ? 4 : 2)) * MAX_XP_ASSASSIN_REWARD));

			showDHUDMessage(0, 255, 255, 255, -1.0, 0.25, 0, 15.0, "¡%s ES ASSASSIN!", g_PlayerName[id]);
			playSound(0, SOUND_ROUND_ASSASSIN);
		}
		case MODE_ANNIHILATOR:
		{
			if(id == 0)
				id = getRandomUser(.alive=1);

			zombieMe(id, .annihilator=1);

			++g_Stats[id][STAT_AN_M_C];

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				if(id == i || g_Zombie[i])
					continue;

				set_task(0.19, "task__ClearWeapons", i);
				set_task(0.2, "task__SetWeapons", i);

				if(getUserTeam(i) != F_TEAM_CT)
				{
					remove_task(i + TASK_TEAM);
					
					setUserTeam(i, F_TEAM_CT);
					setUserTeamUpdate(i);
				}
			}

			showDHUDMessage(0, 255, 255, 0, -1.0, 0.25, 0, 15.0, "¡%s ES ANIQUILADOR!", g_PlayerName[id]);
			playSound(0, SOUND_ROUND_NEMESIS[random_num(0, charsmax(SOUND_ROUND_NEMESIS))]);
		}
		case MODE_GRUNT:
		{
			g_ModeGrunt_RewardGlobal = 11111;
			g_ModeGrunt_NoDamage = 1;
			
			set_cvar_num("dg_afk_time", 9999);
			set_cvar_num("sv_alltalk", 0);

			static iDouble;
			iDouble = random_num(0, 1);

			if(id)
				iDouble = 0;
			else
				id = getRandomUser(1);

			static iIds[2];
			iIds = {0, 0};

			if(iDouble)
			{
				iMaxUsers = 2;
				iUsers = 0;

				while(iUsers < iMaxUsers)
				{
					id = getRandomUser(1);

					if(g_SpecialMode[id] == MODE_GRUNT)
						continue;

					iIds[iUsers] = id;
					zombieMe(id, .grunt=1);

					++iUsers;
				}
			}
			else
				zombieMe(id, .grunt=1);

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				strip_user_weapons(i);

				remove_task(i + TASK_GRUNT_AIMING);
				set_task(0.1, "task__ModeGruntAiming", i + TASK_GRUNT_AIMING);

				if(g_SpecialMode[i] == MODE_GRUNT)
				{
					g_ModeGrunt_Reward[i] = clamp((80000000 * (g_Reset[i] + 1)), 80000000, MAX_XP);

					dg_color_chat(i, _, "Dentro de !g30 segundos!y tendrás visión para buscar a los humanos");
					continue;
				}

				if(getUserTeam(i) != F_TEAM_CT)
				{
					remove_task(i + TASK_TEAM);

					setUserTeam(i, F_TEAM_CT);
					setUserTeamUpdate(i);
				}

				dg_color_chat(i, _, "Luego de los !g30 segundos!y no podrás moverte y recibirás la ganancia");
				randomSpawn(i);

				if(g_HatId[i])
				{
					if(is_valid_ent(g_HatEnt[i]))
					{
						entity_set_int(g_HatEnt[i], EV_INT_rendermode, kRenderTransAlpha);
						entity_set_float(g_HatEnt[i], EV_FL_renderamt, 0.0);
					}
				}

				turnOffFlashlight(i);
			}

			if(iDouble)
				showDHUDMessage(0, 198, 226, 255, -1.0, 0.25, 0, 15.0, "¡GRUNT!^nLos grunts son^n^n%s^n%s^n^nNo hagas contacto visual con el Grunt y escóndete", g_PlayerName[iIds[0]], g_PlayerName[iIds[1]]);
			else
				showDHUDMessage(0, 198, 226, 255, -1.0, 0.25, 0, 15.0, "¡%s ES GRUNT!^nNo hagas contacto visual con el Grunt y escóndete", g_PlayerName[id]);

			playSound(0, SOUND_ROUND_ASSASSIN);
		}
	}

	alertMode(mode_id);
}

getRandomUser(const alive=0)
{
	static j;
	static iTeam;
	static iUsers[MAX_USERS];
	static iRandom;

	j = 0;

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(alive)
		{
			if(!g_IsAlive[i])
				continue;
		}
		else
		{
			if(!g_IsConnected[i])
				continue;
		}

		iTeam = getUserTeam(i);

		if(iTeam == F_TEAM_NONE || iTeam == F_TEAM_SPECTATOR)
			continue;

		iUsers[j] = i;
		++j;
	}

	iRandom = random_num(0, (j - 1));
	return iUsers[iRandom];
}

public hamStripWeapons(const id, const weapon[])
{
	if(!equal(weapon, "weapon_", 7)) 
		return 0;

	static iWeaponId;
	iWeaponId = get_weaponid(weapon);
	
	if(!iWeaponId)
		return 0;

	static iWeaponEnt;
	iWeaponEnt = -1;
	
	while((iWeaponEnt = find_ent_by_class(iWeaponEnt, weapon)) && entity_get_edict(iWeaponEnt, EV_ENT_owner) != id) {}

	if(!iWeaponEnt)
		return 0;

	if(g_CurrentWeapon[id] == iWeaponId) 
		ExecuteHamB(Ham_Weapon_RetireWeapon, iWeaponEnt);

	if(!ExecuteHamB(Ham_RemovePlayerItem, id, iWeaponEnt)) 
		return 0;

	ExecuteHamB(Ham_Item_Kill, iWeaponEnt);

	entity_set_int(id, EV_INT_weapons, (entity_get_int(id, EV_INT_weapons) & ~(1<<iWeaponId)));
	return 1;
}

public alertMode(const mode_id)
{
	++g_ModeCount[mode_id];

	static sModeCount[8];
	addDot(g_ModeCount[mode_id], sModeCount, charsmax(sModeCount));

	if(g_ModeCount[mode_id] == 100 || (((g_ModeCount[mode_id] % 500) == 0) && mode_id != MODE_INFECTION) || ((g_ModeCount[mode_id] % 2500) == 0))
	{
		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(g_IsConnected[i] && g_AccountLogged[i])
			{
				g_Points[i][POINT_HUMAN] += 15;
				g_Points[i][POINT_ZOMBIE] += 15;
			}
		}

		dg_color_chat(0, _, "Todos los jugadores conectados ganaron !g15 pHZ!y", g_ModeCount[mode_id]);
		dg_color_chat(0, _, "Felicidades, el modo !g%s!y se jugó !g%s ve%s!y", __MODES[mode_id][modeName], sModeCount, ((g_ModeCount[mode_id] != 1) ? "ces" : "z"));
	}
	else
		dg_color_chat(0, _, "El modo !g%s!y se jugó !g%s ve%s!y", __MODES[mode_id][modeName], sModeCount, ((g_ModeCount[mode_id] != 1) ? "ces" : "z"));

	static sModeCountSave[256];
	static Handle:sqlQuery;

	arrayToString(g_ModeCount, structIdModes, sModeCountSave, charsmax(sModeCountSave), 1);

	if(g_EventMode_MegaArmageddon >= 0 || g_EventMode_GunGame >= 0)
	{
		if(g_EventMode_MegaArmageddon <= 0)
			g_EventMode_MegaArmageddon = -1;

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_general SET modes=^"%s^", round_ma='%d', round_gg='%d', round_gg_last_winner='%d' WHERE id='1';", sModeCountSave, g_EventMode_MegaArmageddon, g_EventMode_GunGame, g_ModeGG_LastWinner);
	}
	else
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_general SET modes=^"%s^" WHERE id='1';", sModeCountSave);

	if(!SQL_Execute(sqlQuery))
		executeQuery(0, sqlQuery, 42);
	else
		SQL_FreeHandle(sqlQuery);
}

zombieMe(const id, attacker=0, bomb=0, nemesis=0, assassin=0, annihilator=0, freddy=0, alien=0, grunt=0, finish_clan_combo=0)
{
	if(!g_IsAlive[id])
		return;

	if(g_HatId[id])
	{
		if(is_valid_ent(g_HatEnt[id]))
		{
			entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
			entity_set_float(g_HatEnt[id], EV_FL_renderamt, 0.0);
		}
	}

	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_PAINSHOCK);
	remove_task(id + TASK_REGENERATION);
	remove_task(id + TASK_IMMUNITY_P);
	remove_task(id + TASK_DRUG);

	if(isUserStuck(id))
	{
		dg_color_chat(id, _, "Has sido teletransportado debido a que te habías trabado con un humano");
		randomSpawn(id);
	}

	if(attacker)
	{
		if(finish_clan_combo && g_ClanCombo[g_ClanSlot[id]])
		{
			sendClanMessage(id, "Un miembro humano del Clan fue infectado y el combo ha finalizado");
			clanFinishCombo(id);
		}
	}

	g_Zombie[id] = 1;
	g_SpecialMode[id] = MODE_NONE;
	g_SpecialMode_Alien[id] = 0;
	g_SpecialMode_Predator[id] = 0;
	g_CanBuy[id] = 0;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;
	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;
	g_KillBomb[id] = 0;
	g_MolotovBomb[id] = 0;
	g_AntidoteBomb[id] = 0;
	g_ComboZombieEnabled[id] = 1;
	g_Immunity[id] = 0;

	clanUpdateHumans(id);

	if(g_Frozen[id])
	{
		remove_task(id + TASK_FREEZE);
		remove_task(id + TASK_SLOWDOWN);

		task__RemoveFreeze(id + TASK_FREEZE);
		task__RemoveSlowDown(id + TASK_SLOWDOWN);
	}
	else if(g_SlowDown[id])
	{
		remove_task(id + TASK_SLOWDOWN);
		task__RemoveSlowDown(id + TASK_SLOWDOWN);
	}

	strip_user_weapons(id);

	if(!g_MiniGame_Weapons || canUseMiniGames(id))
		give_item(id, "weapon_knife");

	setUserAura(id);
	set_user_rendering(id);

	cs_set_user_zoom(id, CS_RESET_ZOOM, 1);
	set_user_armor(id, 0);

	static iHealth;
	static Float:flHealth;
	static Float:flSpeed;
	static Float:flGravity;

	if(attacker) // Fue infectado por otra persona ?
	{
		randomSpawn(id);
		finishComboHuman(id);

		++g_Stats[attacker][STAT_INF_D];
		++g_Stats[id][STAT_INF_T];

		if(g_Stats[attacker][STAT_INF_D] >= 100)
		{
			setAchievement(attacker, HUMANOS_x100);

			if(g_Stats[attacker][STAT_INF_D] >= 500)
			{
				setAchievement(attacker, HUMANOS_x500);

				if(g_Stats[attacker][STAT_INF_D] >= 1000)
				{
					setAchievement(attacker, HUMANOS_x1000);

					if(g_Stats[attacker][STAT_INF_D] >= 2500)
					{
						setAchievement(attacker, HUMANOS_x2500);
						giveHat(attacker, HAT_AWESOME);

						if(g_Stats[attacker][STAT_INF_D] >= 5000)
						{
							setAchievement(attacker, HUMANOS_x5000);

							if(g_Stats[attacker][STAT_INF_D] >= 10000)
							{
								setAchievement(attacker, HUMANOS_x10K);

								if(g_Stats[attacker][STAT_INF_D] >= 25000)
								{
									setAchievement(attacker, HUMANOS_x25K);

									if(g_Stats[attacker][STAT_INF_D] >= 50000)
									{
										setAchievement(attacker, HUMANOS_x50K);

										if(g_Stats[attacker][STAT_INF_D] >= 100000)
										{
											setAchievement(attacker, HUMANOS_x100K);

											if(g_Stats[attacker][STAT_INF_D] >= 250000)
											{
												setAchievement(attacker, HUMANOS_x250K);

												if(g_Stats[attacker][STAT_INF_D] >= 500000)
												{
													setAchievement(attacker, HUMANOS_x500K);

													if(g_Stats[attacker][STAT_INF_D] >= 1000000)
													{
														setAchievement(attacker, HUMANOS_x1M);

														if(g_Stats[attacker][STAT_INF_D] >= 5000000)
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

		if(g_ClanSlot[attacker] && g_Clan[g_ClanSlot[attacker]][clanCountOnlineMembers] > 1)
			++g_Clan[g_ClanSlot[attacker]][clanInfectDone];

		if(!bomb) // Fue infectado por una persona ?
		{
			static iReward;
			iReward = getConversionPercent(attacker, 25);

			addAPs(attacker, (g_Level[id] + (g_Reset[id] * MAX_LEVEL)));
			addXP(attacker, iReward);

			if(g_Immunity[attacker])
			{
				++g_Hat_Earth[attacker];

				switch(g_Hat_Earth[attacker])
				{
					case 1: client_print(attacker, print_center, "GORRO EARTH - 1 Infección");
					case 2: client_print(attacker, print_center, "GORRO EARTH - 2 Infecciones");
					case 3: client_print(attacker, print_center, "GORRO EARTH - 3 Infecciones");
					case 4: client_print(attacker, print_center, "GORRO EARTH - 4 Infecciones");
					case 5: giveHat(attacker, HAT_EARTH);
				}

				++g_Achievement_InfectsWithFury[attacker];
				
				if(g_Achievement_FuryConsecutive[attacker] == 2)
				{
					if(g_Achievement_InfectsWithFury[attacker] >= 15)
						setAchievement(attacker, YO_FUI);
				}
			}
			else
			{
				if(g_Health[attacker] >= g_MaxHealth[attacker])
				{
					++g_Achievement_InfectsWithMaxHP[attacker];

					if(g_Achievement_InfectsWithMaxHP[attacker] == 5)
						setAchievement(attacker, YO_NO_FUI);
				}
				
				if(g_Mode == MODE_INFECTION)
				{
					new iRandom;
					iRandom = random_num(1, 100);

					if(iRandom <= g_InductionChance[attacker])
					{
						new Float:flDuration;
						flDuration = 4.0;

						if(g_Habs[attacker][HAB_S_MADNESS])
							flDuration += ((float(HABS[HAB_S_MADNESS][habValue]) / 2.0) * float(g_Habs[attacker][HAB_S_MADNESS]));

						if(g_ClanSlot[attacker] && g_ClanPerks[g_ClanSlot[attacker]][CP_EXTENDED_FURY])
							flDuration += 2.0;

						client_print(attacker, print_center, "¡Tu INDICCIÓN desató tu FURIA ZOMBIE!");

						startZombieMadness(attacker, flDuration, 1, 1);
					}

					if(!g_Achievement_InfectsRoundId[attacker][id])
						++g_Achievement_InfectsRound[attacker];

					g_Achievement_InfectsRoundId[attacker][id] = 1;

					switch(g_Achievement_InfectsRound[attacker])
					{
						case 5: client_print(attacker, print_center, "LOGRO VIRUS - 5 Infecciones");
						case 10: client_print(attacker, print_center, "LOGRO VIRUS - 10 Infecciones");
						case 15: client_print(attacker, print_center, "LOGRO VIRUS - 15 Infecciones");
						case 20: setAchievement(attacker, VIRUS);
						case 24: setAchievement(attacker, T_VIRUS);
					}

					if(g_AchievementSecret_FuryInRound[attacker] >= 3 && g_Achievement_InfectsRound[attacker] >= 5)
						setAchievement(attacker, RAPIDO_Y_FURIOSO);
				}
			}

			if(g_Habs[attacker][HAB_Z_COMBO_ZOMBIE] && g_ComboZombieEnabled[attacker])
			{
				++g_ComboZombie[attacker];
				showCurrentComboZombie(attacker);
			}
		}
		else
		{
			// . . .
		}

		emitSound(id, CHAN_VOICE, SOUND_ZOMBIE_INFECT[random_num(0, charsmax(SOUND_ZOMBIE_INFECT))]);

		iHealth = zombieHealth(id);
		flSpeed = Float:zombieSpeed(id);
		flGravity = Float:zombieGravity(id);

		if(g_MiniGame_Habs && !canUseMiniGames(id))
		{
			flSpeed = ZOMBIE_BASE_SPEED_MIN;
			flGravity = ZOMBIE_BASE_GRAVITY_MIN;
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		message_begin(MSG_BROADCAST, g_Message_DeathMsg);
		write_byte(attacker);
		write_byte(id);
		write_byte(1);
		write_string("infection");
		message_end();

		set_user_frags(attacker, (get_user_frags(attacker) + 1));
		set_pdata_int(id, OFFSET_CSDEATHS, (cs_get_user_deaths(id) + 1), OFFSET_LINUX);

		message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
		write_byte(attacker);
		write_short(get_user_frags(attacker));
		write_short(cs_get_user_deaths(attacker));
		write_short(0);
		write_short(getUserTeam(attacker));
		message_end();

		message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
		write_byte(id);
		write_short(get_user_frags(id));
		write_short(cs_get_user_deaths(id));
		write_short(0);
		write_short(getUserTeam(id));
		message_end();

		message_begin(MSG_BROADCAST, g_Message_ScoreAttrib);
		write_byte(id);
		write_byte(0);
		message_end();

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), MODELS[g_ModelSelected[id][MODEL_ZOMBIE]][modelName]);
	}
	else // Fue infectado a través de un comando/modo o porque renació como zombie
	{
		if(nemesis)
		{
			g_fwdUpdateClientDataPost = register_forward(FM_UpdateClientData, "fwd__UpdateClientDataPost", 1);

			g_SpecialMode[id] = MODE_NEMESIS;

			iHealth = (100000 * getAlives());
			flSpeed = 300.0;
			flGravity = 0.5;

			new iIsLongJump;
			iIsLongJump = 1;

			if(g_Mode == MODE_NEMESIS)
			{
				setUserAura(id, 255, 0, 0, 15);

				if(g_Difficult[id][DIFFICULT_CLASS_NEMESIS] == DIFFICULT_VERY_HARD)
					iIsLongJump = 0;

				if(g_Habs[id][HAB_L_N_BAZOOKA_EXTRA])
				{
					dg_color_chat(id, _, "Recuerda que tienes dos !gbazookas!y. Apreta la !gtecla 1!y para obtenerla y para lanzarla el !gclic izquierdo!y");
					g_ModeNemesis_Bazooka[id] = 2;
				}
				else
				{
					dg_color_chat(id, _, "Recuerda que tienes una !gbazooka!y. Apreta la !gtecla 1!y para obtenerla y para lanzarla el !gclic izquierdo!y");
					g_ModeNemesis_Bazooka[id] = 1;
				}

				g_ModeNemesis_BazookaLast[id] = 0.0;

				give_item(id, "weapon_ak47");
				cs_set_user_bpammo(id, CSW_AK47, 0);
				set_pdata_int(findEntByOwner(id, "weapon_ak47"), OFFSET_CLIPAMMO, 0, OFFSET_LINUX_WEAPONS);

				flHealth = float(iHealth);
				flHealth *= DIFFICULTS[DIFFICULT_CLASS_NEMESIS][g_Difficult[id][DIFFICULT_CLASS_NEMESIS]][difficultHealth];
				iHealth = floatround(flHealth);

				flSpeed *= DIFFICULTS[DIFFICULT_CLASS_NEMESIS][g_Difficult[id][DIFFICULT_CLASS_NEMESIS]][difficultSpeed];
			}

			g_CurrentWeapon[id] = CSW_KNIFE;
			engclient_cmd(id, "weapon_knife");

			if(iIsLongJump)
			{
				set_pdata_int(id, OFFSET_LONG_JUMP, 1, OFFSET_LINUX);

				g_LongJump[id] = 1;
				g_InJump[id] = 0;
			}

			iHealth += (g_Habs[id][HAB_L_N_BASE_STATS] * 1000000);
			flSpeed += (float(g_Habs[id][HAB_L_N_BASE_STATS]) * 10.0);
			flGravity -= ((float(g_Habs[id][HAB_L_N_BASE_STATS]) * 20.0) / 800.0);

			switch(g_Mode)
			{
				case MODE_PLAGUE, MODE_SYNAPSIS: iHealth += 12500000;
				case MODE_DRUNK: iHealth += 15000000;
				case MODE_ARMAGEDDON: iHealth += 20000000;
				case MODE_MEGA_ARMAGEDDON: iHealth += 25000000;
			}

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Nemesis");

			replaceWeaponModels(id, CSW_KNIFE);
		}
		else if(assassin)
		{
			g_SpecialMode[id] = MODE_ASSASSIN;
			g_Painshock[id] = 1;

			iHealth = (20 * getAlives());
			flSpeed = 375.0;
			flGravity = 0.75;

			static iPowerAssassin;
			iPowerAssassin = 1;

			if(g_Mode == MODE_ASSASSIN)
			{
				if(g_Difficult[id][DIFFICULT_CLASS_ASSASSIN] == DIFFICULT_VERY_HARD)
					iPowerAssassin = 0;

				flHealth = float(iHealth);
				flHealth *= DIFFICULTS[DIFFICULT_CLASS_ASSASSIN][g_Difficult[id][DIFFICULT_CLASS_ASSASSIN]][difficultHealth];
				iHealth = floatround(flHealth);

				flSpeed *= DIFFICULTS[DIFFICULT_CLASS_ASSASSIN][g_Difficult[id][DIFFICULT_CLASS_ASSASSIN]][difficultSpeed];
			}

			g_CurrentWeapon[id] = CSW_KNIFE;
			engclient_cmd(id, "weapon_knife");

			if(iPowerAssassin)
			{
				g_ModeAssassin_PowerGlow[id] = 1;
				dg_color_chat(id, _, "Recuerda que tienes !gpoder de vision!y. Activala apretango la !gTecla G!y");
			}

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			set_user_rendering(id, kRenderFxGlowShell, 50, 50, 50, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Assassin");

			replaceWeaponModels(id, CSW_KNIFE);
		}
		else if(annihilator)
		{
			g_SpecialMode[id] = MODE_ANNIHILATOR;
			g_ModeAnnihilator_Kills[id] = 0;

			set_pdata_int(id, OFFSET_LONG_JUMP, 1, OFFSET_LINUX);

			g_LongJump[id] = 1;
			g_InJump[id] = 0;

			iHealth = (1500000 * getAlives());
			flSpeed = 300.0;
			flGravity = 0.5;

			if(g_Mode == MODE_ANNIHILATOR)
			{
				setUserAura(id, 255, 255, 0, 15);

				if(g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR] < DIFFICULT_VERY_HARD)
				{
					g_ModeNemesis_Bazooka[id] = 5;
					dg_color_chat(id, _, "Recuerda que tienes cinco !gbazookas!y. Apreta la !gtecla 1!y para obtenerla y para lanzarla el !gclic izquierdo!y");
				}
				else
				{
					g_ModeNemesis_Bazooka[id] = 2;
					dg_color_chat(id, _, "Recuerda que tienes dos !gbazookas!y. Apreta la !gtecla 1!y para obtenerla y para lanzarla el !gclic izquierdo!y");
				}

				g_ModeNemesis_BazookaLast[id] = 0.0;

				give_item(id, "weapon_ak47");
				cs_set_user_bpammo(id, CSW_AK47, 0);
				set_pdata_int(findEntByOwner(id, "weapon_ak47"), OFFSET_CLIPAMMO, 0, OFFSET_LINUX_WEAPONS);

				give_item(id, "weapon_mac10");
				ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[CSW_MAC10], AMMO_TYPE[CSW_MAC10], MAX_BPAMMO[CSW_MAC10]);

				flHealth = float(iHealth);
				flHealth *= DIFFICULTS[DIFFICULT_CLASS_ANNIHILATOR][g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR]][difficultHealth];
				iHealth = floatround(flHealth);

				flSpeed *= DIFFICULTS[DIFFICULT_CLASS_ANNIHILATOR][g_Difficult[id][DIFFICULT_CLASS_ANNIHILATOR]][difficultSpeed];
			}

			g_CurrentWeapon[id] = CSW_KNIFE;
			engclient_cmd(id, "weapon_knife");

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Aniquilador");

			replaceWeaponModels(id, CSW_KNIFE);
		}
		else if(freddy)
		{
			g_SpecialMode[id] = MODE_FVSJ;
			g_ModeFvsJ_FreddyPower[id] = 1;
			g_ModeFvsJ_FreddyPowerType[id] = freddy;

			set_pdata_int(id, OFFSET_LONG_JUMP, 1, OFFSET_LINUX);

			g_LongJump[id] = 1;
			g_InJump[id] = 0;

			iHealth = (250000 * getAlives());
			flSpeed = 275.0;
			flGravity = 0.5;
			
			if(g_Mode == MODE_FVSJ)
				setUserAura(id, 128, 64, 0, 20);

			g_CurrentWeapon[id] = CSW_KNIFE;
			engclient_cmd(id, "weapon_knife");

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			set_user_rendering(id, kRenderFxGlowShell, 128, 64, 0, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Freddy");

			replaceWeaponModels(id, CSW_KNIFE);
		}
		else if(alien)
		{
			g_SpecialMode[id] = MODE_AVSP;
			g_SpecialMode_Alien[id] = 1;
			g_ModeAvsp_AlienPower[id] = 1;

			iHealth = (100000 * getAlives());
			flSpeed = 400.0;
			flGravity = 0.75;

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Alien");

			replaceWeaponModels(id, CSW_KNIFE);
		}
		else if(grunt)
		{
			g_SpecialMode[id] = MODE_GRUNT;
			g_ModeGrunt_Power = 0;

			if(g_Mode == MODE_GRUNT && g_ModeGrunt_NoDamage)
			{
				dg_color_chat(id, _, "Recuerda que con la !gTecla G!y lanzas tu poder");

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

			iHealth = 1;
			flSpeed = 325.0;

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, 0.375);

			strip_user_weapons(id);

			set_user_rendering(id, kRenderFxGlowShell, 198, 226, 255, kRenderNormal, 4);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Grunt");
		}
		else
		{
			if(g_Mode == MODE_DRUNK)
				iHealth = 25000000;
			else if(g_Mode == MODE_L4D2)
			{
				iHealth = 100;

				if(g_ModeL4D2_ZobieHealth[id] > 0)
					iHealth += (g_ModeL4D2_ZobieHealth[id] * 5);

				flSpeed = ZOMBIE_BASE_SPEED_MIN;
				flGravity = ZOMBIE_BASE_GRAVITY_MIN;
			}
			else
			{
				iHealth = zombieHealth(id);

				if(g_DeadTimes[id] > 0)
				{
					static iExtraHealth;
					static sExtraHealth[16];

					iExtraHealth = ((iHealth * (g_DeadTimes[id] * 50)) / 100);
					addDot(iExtraHealth, sExtraHealth, charsmax(sExtraHealth));

					dg_color_chat(id, _, "Ahora tenés !g+%s!y de vida como zombie hasta que finalice la ronda", sExtraHealth);
					iHealth += iExtraHealth;
				}

				flSpeed = Float:zombieSpeed(id);
				flGravity = Float:zombieGravity(id);
			}

			if(g_MiniGame_Habs && !canUseMiniGames(id))
			{
				flSpeed = ZOMBIE_BASE_SPEED_MIN;
				flGravity = ZOMBIE_BASE_GRAVITY_MIN;
			}

			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), MODELS[g_ModelSelected[id][MODEL_ZOMBIE]][modelName]);

			emitSound(id, CHAN_VOICE, SOUND_ZOMBIE_ALERT[random_num(0, charsmax(SOUND_ZOMBIE_ALERT))]);
		}
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != F_TEAM_T)
	{
		remove_task(id + TASK_TEAM);
		
		setUserTeam(id, F_TEAM_T);
		setUserTeamUpdate(id);
	}

	setUserAllModels(id);
	turnOffFlashlight(id);

	message_begin(MSG_ONE, g_Message_SetFOV, _, id);
	write_byte(110);
	message_end();

	if(!g_Frozen[id])
	{
		if(g_Mode != MODE_GRUNT)
		{
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
			write_short(UNIT_SECOND);
			write_short(0);
			write_short(FFADE_IN);
			write_byte(g_UserOption_Color[id][COLOR_TYPE_NVISION][0]);
			write_byte(g_UserOption_Color[id][COLOR_TYPE_NVISION][1]);
			write_byte(g_UserOption_Color[id][COLOR_TYPE_NVISION][2]);
			write_byte(255);
			message_end();
		}
	}

	if(g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_GRUNT)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, id);
		write_short(UNIT_SECOND * 4);
		write_short(UNIT_SECOND * 2);
		write_short(UNIT_SECOND * 10);
		message_end();
	}
	
	if(g_Mode != MODE_L4D2)
		setUserNightVision(id, 1);

	checkLastZombie();
}

public zombieHealthBase(const id)
{
	static iHealth;
	iHealth = ZOMBIE_BASE_HEALTH_MIN;

	if(getLevelTotal(id) >= ZOMBIE_CLASS_LEVEL)
	{
		static iLevelTotal;
		static iTotal;

		iLevelTotal = getLevelTotal(id);
		iTotal = 0;

		while(iLevelTotal >= ZOMBIE_CLASS_LEVEL)
		{
			iLevelTotal -= ZOMBIE_CLASS_LEVEL;
			++iTotal;
		}

		iHealth += ((iTotal * iHealth) / 100);
	}

	return ((iHealth > ZOMBIE_BASE_HEALTH_MAX) ? ZOMBIE_BASE_HEALTH_MAX : iHealth);
}

public zombieHealthExtra(const id)
{
	static iExtra;
	static iHabs;

	iExtra = 0;
	iHabs = (__CLASSES[g_Class[id]][classHealth] + g_Habs[id][HAB_Z_HEALTH] + HATS[g_HatId[id]][hatUpgrade1] + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acHealth] : ((g_AmuletEquip[id] != -1) ? g_AmuletsInt[id][g_AmuletEquip[id]][0] : 0)));

	if(iHabs)
		iExtra += (HABS[HAB_Z_HEALTH][habValue] * iHabs);

	return iExtra;
}

public zombieHealth(const id)
{
	static iTotal;
	iTotal = (zombieHealthBase(id) + zombieHealthExtra(id));

	return iTotal;
}

public Float:zombieSpeedBase(const id)
{
	static Float:flSpeed;
	flSpeed = ZOMBIE_BASE_SPEED_MIN;

	if(getLevelTotal(id) >= ZOMBIE_CLASS_LEVEL)
	{
		static iLevelTotal;
		static iTotal;

		iLevelTotal = getLevelTotal(id);
		iTotal = 0;

		while(iLevelTotal >= ZOMBIE_CLASS_LEVEL)
		{
			iLevelTotal -= ZOMBIE_CLASS_LEVEL;
			++iTotal;
		}

		flSpeed += (ZOMBIE_BASE_SPEED_MULT * float(iTotal));
	}

	return ((flSpeed > ZOMBIE_BASE_SPEED_MAX) ? ZOMBIE_BASE_SPEED_MAX : flSpeed);
}

public Float:zombieSpeedExtra(const id)
{
	static Float:flExtra;
	static Float:flHabs;

	flExtra = 0.0;
	flHabs = float(__CLASSES[g_Class[id]][classSpeed]) + float(g_Habs[id][HAB_Z_SPEED]) + float(HATS[g_HatId[id]][hatUpgrade2]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acSpeed]) : ((g_AmuletEquip[id] != -1) ? float(g_AmuletsInt[id][g_AmuletEquip[id]][1]) : 0.0));

	if(flHabs)
		flExtra += (float(HABS[HAB_Z_SPEED][habValue]) * flHabs);

	return flExtra;
}

public Float:zombieSpeed(const id)
{
	static Float:flTotal;
	flTotal = (zombieSpeedBase(id) + zombieSpeedExtra(id));

	return flTotal;
}

public Float:zombieGravityBase(const id)
{
	static Float:flGravity;
	flGravity = ZOMBIE_BASE_GRAVITY_MIN;

	if(getLevelTotal(id) >= ZOMBIE_CLASS_LEVEL)
	{
		static iLevelTotal;
		static iTotal;

		iLevelTotal = getLevelTotal(id);
		iTotal = 0;

		while(iLevelTotal >= ZOMBIE_CLASS_LEVEL)
		{
			iLevelTotal -= ZOMBIE_CLASS_LEVEL;
			++iTotal;
		}

		flGravity -= (ZOMBIE_BASE_GRAVITY_MULT * float(iTotal));
	}

	return ((flGravity < ZOMBIE_BASE_GRAVITY_MAX) ? ZOMBIE_BASE_GRAVITY_MAX : flGravity);
}

public Float:zombieGravityExtra(const id)
{
	static Float:flExtra;
	static Float:flHabs;

	flExtra = 0.0;
	flHabs = float(__CLASSES[g_Class[id]][classGravity]) + float(g_Habs[id][HAB_Z_GRAVITY]) + float(HATS[g_HatId[id]][hatUpgrade3]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acGravity]) : ((g_AmuletEquip[id] != -1) ? float(g_AmuletsInt[id][g_AmuletEquip[id]][2]) : 0.0));

	if(flHabs)
		flExtra -= ((float(HABS[HAB_Z_GRAVITY][habValue]) / 100.0) * flHabs);

	return flExtra;
}

public Float:zombieGravity(const id)
{
	static Float:flTotal;
	flTotal = (zombieGravityBase(id) + zombieGravityExtra(id));

	return ((flTotal < 0.1) ? 0.1 : flTotal);
}

public zombieDamageExtra(const id)
{
	static iExtra;
	static iHabs;

	iExtra = 0;
	iHabs = (__CLASSES[g_Class[id]][classDamage] + g_Habs[id][HAB_Z_DAMAGE] + HATS[g_HatId[id]][hatUpgrade4] + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acDamage] : ((g_AmuletEquip[id] != -1) ? g_AmuletsInt[id][g_AmuletEquip[id]][3] : 0)));

	if(iHabs)
		iExtra += (HABS[HAB_Z_DAMAGE][habValue] * iHabs);

	return iExtra;
}

public zombieDamage(const id)
{
	static iTotal;
	iTotal = zombieDamageExtra(id);

	return iTotal;
}

humanMe(const id, survivor=0, wesker=0, sniper_elite=0, jason=0, fvsj_jason=0, predator=0, sniper=0, tribal=0, l4d2=0)
{
	if(g_HatId[id])
	{
		if(is_valid_ent(g_HatEnt[id]))
		{
			if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL && g_Mode != MODE_GRUNT)
			{
				entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderNormal);
				entity_set_float(g_HatEnt[id], EV_FL_renderamt, 255.0);
			}
			else
			{
				entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(g_HatEnt[id], EV_FL_renderamt, 0.0);
			}
		}
	}

	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_PAINSHOCK);
	remove_task(id + TASK_REGENERATION);
	remove_task(id + TASK_IMMUNITY_P);
	remove_task(id + TASK_DRUG);

	if(isUserStuck(id))
	{
		dg_color_chat(id, _, "Has sido teletransportado porque te habías trabado con un humano");
		randomSpawn(id);
	}

	g_Zombie[id] = 0;
	g_SpecialMode[id] = MODE_NONE;
	g_SpecialMode_Alien[id] = 0;
	g_SpecialMode_Predator[id] = 0;
	g_CanBuy[id] = 1;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;
	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;
	g_KillBomb[id] = 0;
	g_MolotovBomb[id] = 0;
	g_AntidoteBomb[id] = 0;
	g_ComboZombieEnabled[id] = 0;
	g_Immunity[id] = 0;

	clanUpdateHumans(id);

	if(g_Frozen[id])
	{
		remove_task(id + TASK_FREEZE);
		remove_task(id + TASK_SLOWDOWN);

		task__RemoveFreeze(id + TASK_FREEZE);
		task__RemoveSlowDown(id + TASK_SLOWDOWN);
	}
	else if(g_SlowDown[id])
	{
		remove_task(id + TASK_SLOWDOWN);
		task__RemoveSlowDown(id + TASK_SLOWDOWN);
	}

	strip_user_weapons(id);
	
	if(!g_MiniGame_Weapons || canUseMiniGames(id))
		give_item(id, "weapon_knife");

	setUserAura(id);
	set_user_rendering(id);

	cs_set_user_zoom(id, CS_RESET_ZOOM, 1);
	set_user_armor(id, 0);

	static iHealth;
	static Float:flHealth;
	static Float:flSpeed;
	static Float:flGravity;

	if(survivor)
	{
		g_SpecialMode[id] = MODE_SURVIVOR;

		iHealth = (175 * getAlives());
		flSpeed = 250.0;
		flGravity = 1.0;

		if(g_Mode == MODE_SURVIVOR)
		{
			setUserAura(id, 0, 0, 255, 20);
			
			if(g_Difficult[id][DIFFICULT_CLASS_SURVIVOR] < DIFFICULT_VERY_HARD)
			{
				dg_color_chat(id, _, "Recuerda que tienes una !gbomba de aniquilación!y. Aprieta la !gtecla 4!y para obtenerla y lanzarla");

				give_item(id, "weapon_hegrenade");
				g_KillBomb[id] = 1;
			}

			flHealth = float(iHealth);
			flHealth *= DIFFICULTS[DIFFICULT_CLASS_SURVIVOR][g_Difficult[id][DIFFICULT_CLASS_SURVIVOR]][difficultHealth];
			iHealth = floatround(flHealth);

			flSpeed *= DIFFICULTS[DIFFICULT_CLASS_SURVIVOR][g_Difficult[id][DIFFICULT_CLASS_SURVIVOR]][difficultSpeed];
		}

		iHealth += (g_Habs[id][HAB_L_S_BASE_STATS] * 125);
		flSpeed += (float(g_Habs[id][HAB_L_S_BASE_STATS]) * 10.0);
		flGravity -= ((float(g_Habs[id][HAB_L_S_BASE_STATS]) * 40.0) / 800.0);

		switch(g_Mode)
		{
			case MODE_ARMAGEDDON: iHealth += 2500;
			case MODE_MEGA_ARMAGEDDON: iHealth += 5000;
			case MODE_DRUNK: iHealth += 3750;
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		switch(g_Habs[id][HAB_L_S_WEAPON])
		{
			case 0:
			{
				if((g_Mode == MODE_ARMAGEDDON || g_Mode == MODE_MEGA_ARMAGEDDON) && g_ModeArmageddon_Bubbles <= 3)
				{
					give_item(id, "weapon_m249");
					give_item(id, "weapon_smokegrenade");

					g_BubbleBomb[id] = 1;
					++g_ModeArmageddon_Bubbles;

					dg_color_chat(id, _, "Te ha tocado una bubble especial contra nemesis. Úsala en momentos adecuados");
				}
				else
					give_item(id, "weapon_mp5navy");
			}
			case 1: give_item(id, "weapon_xm1014");
			case 2: give_item(id, "weapon_m4a1");
		}

		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 4);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Survivor");
	}
	else if(wesker)
	{
		g_SpecialMode[id] = MODE_WESKER;

		iHealth = (50 * getAlives());
		flSpeed = 315.0;
		flGravity = 0.625;

		if(g_Mode == MODE_WESKER)
		{
			setUserAura(id, 0, 255, 255, 20);

			if(g_Difficult[id][DIFFICULT_CLASS_WESKER] < DIFFICULT_VERY_HARD)
			{
				dg_color_chat(id, _, "Recuerda que tienes !g3 lasers!y para usar. Lánzalos con el !gclic derecho!y");
				
				g_ModeWesker_Laser[id] = 3;
				g_ModeWesker_LaserLast[id] = 0.0;
			}

			flHealth = float(iHealth);
			flHealth *= DIFFICULTS[DIFFICULT_CLASS_WESKER][g_Difficult[id][DIFFICULT_CLASS_WESKER]][difficultHealth];
			iHealth = floatround(flHealth);

			flSpeed *= DIFFICULTS[DIFFICULT_CLASS_WESKER][g_Difficult[id][DIFFICULT_CLASS_WESKER]][difficultSpeed];
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		give_item(id, "weapon_deagle");
		give_item(id, "weapon_smokegrenade");

		g_UnlimitedClip[id] = 1;
		g_BubbleBomb[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 0, 255, 255, kRenderNormal, 4);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Wesker");
	}
	else if(sniper_elite)
	{
		g_SpecialMode[id] = MODE_SNIPER_ELITE;

		iHealth = (300 * getAlives());
		flSpeed = 325.0;
		flGravity = 0.625;

		if(g_Mode == MODE_SNIPER_ELITE)
		{
			setUserAura(id, 0, 255, 0, 20);

			if(g_Difficult[id][DIFFICULT_CLASS_SNIPER_ELITE] < DIFFICULT_VERY_HARD)
			{
				dg_color_chat(id, _, "Recuerda que tienes !gvelocidad de disparo!y. Lánzalo apretando la !gTecla G!y");

				g_ModeSniperElite_Speed[id] = 1;
			}

			flHealth = float(iHealth);
			flHealth *= DIFFICULTS[DIFFICULT_CLASS_SNIPER_ELITE][g_Difficult[id][DIFFICULT_CLASS_SNIPER_ELITE]][difficultHealth];
			iHealth = floatround(flHealth);

			flSpeed *= DIFFICULTS[DIFFICULT_CLASS_SNIPER_ELITE][g_Difficult[id][DIFFICULT_CLASS_SNIPER_ELITE]][difficultSpeed];
		}

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		give_item(id, "weapon_awp");
		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 4);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Sniper Elite");
	}
	else if(jason)
	{
		g_SpecialMode[id] = MODE_JASON;

		iHealth = (350 * getAlives());
		flSpeed = 350.0;
		flGravity = 1.0;

		if(g_Mode == MODE_JASON)
		{
			setUserAura(id, 255, 0, 255, 20);

			g_ModeJason_Teleport[id] = 0;
		}

		if(g_Mode == MODE_DRUNK)
			iHealth *= 2;

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		set_user_rendering(id, kRenderFxGlowShell, 255, 0, 255, kRenderNormal, 4);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Jason");

		replaceWeaponModels(id, CSW_KNIFE);
	}
	else if(fvsj_jason)
	{
		g_SpecialMode[id] = MODE_FVSJ;
		g_ModeFvsJ_Jason[id] = 1;
		g_ModeFvsJ_JasonPower[id] = 1;

		iHealth = (500 * getAlives());
		flSpeed = 300.0;
		flGravity = 1.0;

		if(g_Mode == MODE_FVSJ)
			setUserAura(id, 100, 0, 100, 20);

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		give_item(id, "weapon_m3");
		ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[CSW_M3], AMMO_TYPE[CSW_M3], MAX_BPAMMO[CSW_M3]);

		set_user_rendering(id, kRenderFxGlowShell, 100, 0, 100, kRenderNormal, 4);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Jason");
	}
	else if(predator)
	{
		g_SpecialMode[id] = MODE_AVSP;
		g_SpecialMode_Predator[id] = 1;
		g_ModeAvsp_PredatorPower[id] = 1;

		iHealth = (250 * getAlives());
		flSpeed = 300.0;
		flGravity = 0.75;

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		give_item(id, "weapon_m4a1");
		g_UnlimitedClip[id] = 1;

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Depredador");
	}
	else if(sniper)
	{
		g_SpecialMode[id] = MODE_SNIPER;
		g_ModeSniper_Power[id] = 0;

		iHealth = (300 * getAlives());
		flSpeed = 300.0;
		flGravity = 0.6;

		if(g_Mode == MODE_DRUNK)
			iHealth *= 2;

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		if(g_Mode == MODE_SNIPER)
		{
			dg_color_chat(id, _, "Recuerda que tienes !gvelocidad de disparo!y. Lánzalo apretando la !gTecla G!y");

			setUserAura(id, 0, 255, 0, 20);
		}

		if((sniper % 2) == 0)
			give_item(id, "weapon_awp");
		else
			give_item(id, "weapon_scout");

		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 4);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Sniper");
	}
	else if(tribal)
	{
		g_SpecialMode[id] = MODE_TRIBAL;
		g_ModeTribal_Damage[id] = 0;

		iHealth = (250 * getAlives());
		flSpeed = 300.0;
		flGravity = 0.75;

		if(g_Mode == MODE_DRUNK)
			iHealth *= 2;

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		if(g_Mode == MODE_TRIBAL)
		{
			dg_color_chat(id, _, "Recuerda que estando cerca de tu compañero puedes lanzar tu poder. Lánzalo con la !gTecla G!y");
			
			give_item(id, "weapon_flashbang");
			g_MolotovBomb[id] = 1;

			setUserAura(id, 255, 165, 0, 20);
		}

		if((tribal % 2) == 0)
			give_item(id, "weapon_ak47");
		else
			give_item(id, "weapon_m4a1");

		g_UnlimitedClip[id] = 1;

		set_user_rendering(id, kRenderFxGlowShell, 255, 165, 0, kRenderNormal, 4);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Tribal");
	}
	else if(l4d2)
	{
		g_SpecialMode[id] = MODE_L4D2;

		iHealth = (175 * getAlives());
		flSpeed = 275.0;
		flGravity = 1.25;

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		set_user_rendering(id, kRenderFxGlowShell, 199, 21, 133, kRenderNormal, 4);

		switch(l4d2)
		{
			case 1:
			{
				give_item(id, "weapon_ak47");
				ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[CSW_AK47], AMMO_TYPE[CSW_AK47], MAX_BPAMMO[CSW_AK47]);

				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Bill");
			}
			case 2:
			{
				give_item(id, "weapon_mp5navy");
				ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[CSW_MP5NAVY], AMMO_TYPE[CSW_MP5NAVY], MAX_BPAMMO[CSW_MP5NAVY]);

				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Francis");
			}
			case 3:
			{
				give_item(id, "weapon_aug");
				ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[CSW_AUG], AMMO_TYPE[CSW_AUG], MAX_BPAMMO[CSW_AUG]);

				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Louis");
			}
			case 4:
			{
				give_item(id, "weapon_sg552");
				ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[CSW_SG552], AMMO_TYPE[CSW_SG552], MAX_BPAMMO[CSW_SG552]);

				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Zoey");
			}
		}

		g_UnlimitedClip[id] = 1;
		g_PrecisionPerfect[id] = 1;
		g_ModeL4D2_Human[id] = (l4d2 - 1);
	}
	else
	{
		set_task(0.19, "task__ClearWeapons", id + TASK_SPAWN);
		set_task(0.2, "task__SetWeapons", id + TASK_SPAWN);

		iHealth = humanHealth(id);
		flSpeed = Float:humanSpeed(id);
		flGravity = Float:humanGravity(id);

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);
		set_user_armor(id, humanArmor(id));

		emitSound(id, CHAN_ITEM, SOUND_HUMAN_ANTIDOTE);

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), MODELS[g_ModelSelected[id][MODEL_HUMAN]][modelName]);
	}

	if(g_Mode == MODE_DUEL_FINAL || (g_MiniGame_Habs && !canUseMiniGames(id)))
	{
		set_user_health(id, HUMAN_BASE_HEALTH_MIN);
		g_Speed[id] = HUMAN_BASE_SPEED_MIN;
		set_user_gravity(id, HUMAN_BASE_GRAVITY_MIN);
		set_user_armor(id, 0);
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != F_TEAM_CT)
	{
		remove_task(id + TASK_TEAM);
		
		setUserTeam(id, F_TEAM_CT);
		setUserTeamUpdate(id);
	}

	setUserAllModels(id);
	turnOffFlashlight(id);

	message_begin(MSG_ONE, g_Message_SetFOV, _, id);
	write_byte(90);
	message_end();

	if(g_NightVision[id])
		setUserNightVision(id, 0);

	checkLastZombie();
}

getHabLevel(const id, const hab_class, const hab, &class=0, &hat=0, &amulet=0)
{
	static iHabs;
	static iExtras;

	iHabs = g_Habs[id][hab];
	iExtras = 0;

	if(hab_class == HAB_CLASS_HUMAN)
	{
		switch(hab)
		{
			case HAB_H_HEALTH:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classHealth];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade1];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acHealth];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][0];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
			case HAB_H_SPEED:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classSpeed];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade2];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acSpeed];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][1];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
			case HAB_H_GRAVITY:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classGravity];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade3];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acGravity];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][2];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
			case HAB_H_DAMAGE:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classDamage];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade4];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acDamage];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][3];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
		}
	}
	else if(hab_class == HAB_CLASS_ZOMBIE)
	{
		switch(hab)
		{
			case HAB_Z_HEALTH:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classHealth];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade1];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acHealth];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][0];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
			case HAB_Z_SPEED:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classSpeed];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade2];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acSpeed];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][1];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
			case HAB_Z_GRAVITY:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classGravity];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade3];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acGravity];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][2];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
			case HAB_Z_DAMAGE:
			{
				if(g_Class[id])
				{
					class = iExtras = __CLASSES[g_Class[id]][classDamage];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_HatId[id] != HAT_NONE)
				{
					hat = iExtras = HATS[g_HatId[id]][hatUpgrade4];
					iHabs += iExtras;
				}
				else
					iExtras = 0;

				if(g_AmuletCustomCreated[id])
				{
					amulet = iExtras = g_AmuletCustom[id][acDamage];
					iHabs += iExtras;
				}
				else
				{
					if(g_AmuletEquip[id] != -1)
					{
						amulet = iExtras = g_AmuletsInt[id][g_AmuletEquip[id]][3];
						iHabs += iExtras;
					}
					else
						iExtras = 0;
				}
			}
		}
	}

	return iHabs;
}

public humanHealthBase(const id)
{
	static iHealth;
	iHealth = HUMAN_BASE_HEALTH_MIN;

	if(getLevelTotal(id) >= HUMAN_CLASS_LEVEL)
	{
		static iLevelTotal;
		static iTotal;

		iLevelTotal = (g_Level[id] + (g_Reset[id] * MAX_LEVEL));
		iTotal = 0;

		while(iLevelTotal >= HUMAN_CLASS_LEVEL)
		{
			iLevelTotal -= HUMAN_CLASS_LEVEL;
			++iTotal;
		}

		iHealth += ((iTotal * iHealth) / 100);
	}

	return ((iHealth > HUMAN_BASE_HEALTH_MAX) ? HUMAN_BASE_HEALTH_MAX : iHealth);
}

public humanHealthExtra(const id)
{
	static iExtra;
	static iHabs;

	iExtra = 0;
	iHabs = (__CLASSES[g_Class[id]][classHealth] + g_Habs[id][HAB_H_HEALTH] + HATS[g_HatId[id]][hatUpgrade1] + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acHealth] : ((g_AmuletEquip[id] != -1) ? g_AmuletsInt[id][g_AmuletEquip[id]][0] : 0)));

	if(iHabs)
		iExtra += (HABS[HAB_H_HEALTH][habValue] * iHabs);

	return iExtra;
}

public humanHealth(const id)
{
	static iTotal;
	iTotal = (humanHealthBase(id) + humanHealthExtra(id));

	return iTotal;
}

public Float:humanSpeedBase(const id)
{
	static Float:flSpeed;
	flSpeed = HUMAN_BASE_SPEED_MIN;

	if(getLevelTotal(id) >= HUMAN_CLASS_LEVEL)
	{
		static iLevelTotal;
		static iTotal;

		iLevelTotal = (g_Level[id] + (g_Reset[id] * MAX_LEVEL));
		iTotal = 0;

		while(iLevelTotal >= HUMAN_CLASS_LEVEL)
		{
			iLevelTotal -= HUMAN_CLASS_LEVEL;
			++iTotal;
		}

		flSpeed += (HUMAN_BASE_SPEED_MULT * float(iTotal));
	}

	return ((flSpeed > HUMAN_BASE_SPEED_MAX) ? HUMAN_BASE_SPEED_MAX : flSpeed);
}

public Float:humanSpeedExtra(const id)
{
	static Float:flExtra;
	static Float:flHabs;

	flExtra = 0.0;
	flHabs = float(__CLASSES[g_Class[id]][classSpeed]) + float(g_Habs[id][HAB_H_SPEED]) + float(HATS[g_HatId[id]][hatUpgrade2]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acSpeed]) : ((g_AmuletEquip[id] != -1) ? float(g_AmuletsInt[id][g_AmuletEquip[id]][1]) : 0.0));

	if(flHabs)
		flExtra += (float(HABS[HAB_H_SPEED][habValue]) * flHabs);

	return flExtra;
}

public Float:humanSpeed(const id)
{
	static Float:flTotal;
	flTotal = (humanSpeedBase(id) + humanSpeedExtra(id));

	return flTotal;
}

public Float:humanGravityBase(const id)
{
	static Float:flGravity;
	flGravity = HUMAN_BASE_GRAVITY_MIN;

	if(getLevelTotal(id) >= HUMAN_CLASS_LEVEL)
	{
		static iLevelTotal;
		static iTotal;

		iLevelTotal = (g_Level[id] + (g_Reset[id] * MAX_LEVEL));
		iTotal = 0;

		while(iLevelTotal >= HUMAN_CLASS_LEVEL)
		{
			iLevelTotal -= HUMAN_CLASS_LEVEL;
			++iTotal;
		}

		flGravity -= (HUMAN_BASE_GRAVITY_MULT * float(iTotal));
	}

	return ((flGravity < HUMAN_BASE_GRAVITY_MAX) ? HUMAN_BASE_GRAVITY_MAX : flGravity);
}

public Float:humanGravityExtra(const id)
{
	static Float:flExtra;
	static Float:flHabs;

	flExtra = 0.0;
	flHabs = float(__CLASSES[g_Class[id]][classGravity]) + float(g_Habs[id][HAB_H_GRAVITY]) + float(HATS[g_HatId[id]][hatUpgrade3]) + ((g_AmuletCustomCreated[id]) ? float(g_AmuletCustom[id][acGravity]) : ((g_AmuletEquip[id] != -1) ? float(g_AmuletsInt[id][g_AmuletEquip[id]][2]) : 0.0));

	if(flHabs)
		flExtra -= ((float(HABS[HAB_H_GRAVITY][habValue]) / 100.0) * flHabs);

	return flExtra;
}

public Float:humanGravity(const id)
{
	static Float:flTotal;
	flTotal = (humanGravityBase(id) + humanGravityExtra(id));

	return ((flTotal < 0.1) ? 0.1 : flTotal);
}

public Float:humanDamageBase(const id)
{
	static Float:flDamage;
	flDamage = 0.0;

	if(getLevelTotal(id) >= HUMAN_CLASS_LEVEL)
	{
		static iLevelTotal;
		static iTotal;

		iLevelTotal = getLevelTotal(id);
		iTotal = 0;

		while(iLevelTotal >= HUMAN_CLASS_LEVEL)
		{
			iLevelTotal -= HUMAN_CLASS_LEVEL;
			++iTotal;
		}

		flDamage += (HUMAN_BASE_DAMAGE_MULT * float(iTotal));
	}

	return flDamage;
}

public Float:humanDamageHabs(const id)
{
	static Float:flExtra;
	flExtra = (float(__CLASSES[g_Class[id]][classDamage]) + float(g_Habs[id][HAB_H_DAMAGE]) + float(HATS[g_HatId[id]][hatUpgrade4]));
	
	if(g_AmuletCustomCreated[id])
		flExtra += float(g_AmuletCustom[id][acDamage]);
	else
	{
		if(g_AmuletEquip[id] != -1)
			flExtra += float(g_AmuletsInt[id][g_AmuletEquip[id]][3]);
		else
			flExtra += 0.0;
	}

	return flExtra;
}

public humanArmorExtra(const id)
{
	static iExtra;
	static iHabs;

	iExtra = 0;
	iHabs = g_Habs[id][HAB_H_ARMOR];

	if(iHabs)
		iExtra += (HABS[HAB_H_ARMOR][habValue] * iHabs);

	return iExtra;
}

public humanArmor(const id)
{
	static iTotal;
	iTotal = humanArmorExtra(id);

	return iTotal;
}

public turnOffFlashlight(const id)
{
	entity_set_int(id, EV_INT_effects, entity_get_int(id, EV_INT_effects) & ~EF_DIMLIGHT);

	message_begin(MSG_ONE_UNRELIABLE, g_Message_Flashlight, _, id);
	write_byte(0);
	write_byte(OFF_IMPULSE_FLASHLIGHT);
	message_end();

	entity_set_int(id, EV_INT_impulse, 0);
}

public arrayToString(const array[], const size, output[], const output_len, const end)
{
	new iLen;
	new i;

	do
		iLen += formatex(output[iLen], (output_len - iLen), "%d ", array[i]);
	while((++i < size) && (iLen < output_len));

	if(i < size)
		return 0;

	if(end)
		output[(iLen - 1)] = '^0';

	return iLen;
}

public stringToArray(const string[], array_out[], const array_size)
{
	new sTemp[12];
	new iLen;
	new j;
	new k;
	new c;

	while(string[iLen])
	{
		if(string[iLen] == ' ')
		{
			array_out[j++] = str_to_num(sTemp);

			for(c = 0; c < k; c++)
				sTemp[c] = 0;

			k = 0;
        }

		if(j >= array_size)
			return iLen;

		sTemp[k++] = string[iLen++];
	}

	array_out[j++] = str_to_num(sTemp);

	while(j < array_size)
		array_out[j++] = 0;

	return iLen;
}

public changeLights()
{
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i])
			setLight(i, g_Lights[0]);
	}
}

public setLight(const id, const light[])
{
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id);
	write_byte(0);
	write_string(light);
	message_end();
}

public getUserMaxXP(const reset)
	return ((reset + 1) * MAX_XP_PER_RESET);

getUserNextLevel(const id, const level=0, const rest=0)
{
	static iLevel;
	iLevel = ((level > 0) ? level : g_Level[id]);

	if(rest)
		return ((iLevel - 1) * (getUserMaxXP(g_Reset[id]) / (MAX_LEVEL - 1)));

	return (iLevel * (getUserMaxXP(g_Reset[id]) / (MAX_LEVEL - 1)));
}

public checkLastZombie()
{
	static iCountHumans;
	static iCountPlaying;
	static iCountZombies;

	iCountHumans = getHumans();
	iCountPlaying = getPlaying();
	iCountZombies = getZombies();

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i] && !g_Zombie[i] && !g_SpecialMode[i] && iCountHumans == 1)
		{
			g_LastHuman[i] = 1;
			
			if(!g_Hat_Devil[i] && g_Mode == MODE_INFECTION && iCountPlaying >= 10)
				giveHat(i, HAT_DEVIL);
		}
		else
			g_LastHuman[i] = 0;

		if(g_IsAlive[i] && g_Zombie[i] && !g_SpecialMode[i] && iCountZombies == 1)
			g_LastZombie[i] = 1;
		else
			g_LastZombie[i] = 0;
	}
}

public getUserRange(const reset)
	return (90 - reset);

public addAPs(const id, const value)
{
	if((g_AmmoPacks[id] + value) >= MAX_APS)
	{
		g_AmmoPacks[id] = MAX_APS;
		return;
	}

	g_AmmoPacks[id] += value;
}

public addXP(const id, const value)
{
	if(g_Exp[id] >= getUserMaxXP(g_Reset[id]))
		return;

	g_Exp[id] += value;
	checkExpEquation(id);
}

public getConversionPercent(const id, const percent)
{
	static iConversion;
	static iReward;

	iConversion = (getUserNextLevel(id) - getUserNextLevel(id, .rest=1));
	iReward = ((iConversion * percent) / 100);

	return ((iReward < 0 || iReward > MAX_XP) ? MAX_XP : iReward);
}

public checkExpEquation(const id)
{
	if(g_Level[id] >= MAX_LEVEL)
	{
		g_Exp[id] = getUserMaxXP(g_Reset[id]);
		g_ExpRest[id] = 0;
	}
	else
	{
		g_ExpRest[id] = (getUserNextLevel(id) - g_Exp[id]);

		if(g_ExpRest[id] <= 0)
		{
			static iLevel;
			iLevel = 0;

			while(g_ExpRest[id] <= 0)
			{
				g_Exp[id] -= getUserNextLevel(id);

				++g_Level[id];
				++iLevel;

				if(g_Level[id] >= MAX_LEVEL)
				{
					checkExpEquation(id);
					break;
				}

				g_ExpRest[id] = (getUserNextLevel(id) - g_Exp[id]);
			}

			if(iLevel)
			{
				client_print(id, print_center, "Subiste %d nivel%s", iLevel, ((iLevel != 1) ? "es" : ""));
				playSound(id, SOUND_LEVEL_UP);

				if((g_Level[id] % 100) == 0)
					dg_color_chat(id, _, "Has aumentado tus estadísticas humanas y zombies. Revisa el menú de estadísticas y verás el aumento de los mismos");
			}
		}
	}

	addDot(g_ExpRest[id], g_ExpRestHud[id], charsmax(g_ExpRestHud[]));

	g_LevelPercent[id] = ((float(g_Exp[id]) * 100.0) / float(getUserNextLevel(id)));
	g_ResetPercent[id] = (((float(g_Level[id])) * 100.0) / float(MAX_LEVEL));
}

public showCurrentComboHuman(const id, const Float:damage)
{
	if(g_Mode != MODE_ASSASSIN)
	{
		if(g_Mode == MODE_ANNIHILATOR)
		{
			static sBullets[16];
			static sReward[16];

			addDot(g_ModeAnnihilator_Acerts[id], sBullets, charsmax(sBullets));
			addDot(((g_ModeAnnihilator_Acerts[id] * (50 * g_ExpMult[id])) * (getLevelTotal(id) + 1)), sReward, charsmax(sReward));

			set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD_C][0], g_UserOption_Color[id][COLOR_TYPE_HUD_C][1], g_UserOption_Color[id][COLOR_TYPE_HUD_C][2], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1], g_UserOption_EffectHud[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
			ShowSyncHudMsg(id, g_HudSync_Combo, "Disparos acertados: %s | +%s XP", sBullets, sReward);
		}
		else
		{
			static Float:flDuration;
			flDuration = 5.0;

			if(g_Habs[id][HAB_D_DURATION_COMBO])
				flDuration += ((HABS[HAB_D_DURATION_COMBO][habValue] / 2) * float(g_Habs[id][HAB_D_DURATION_COMBO]));

			g_ComboTime[id] = (halflife_time() + flDuration);

			while(g_ComboReward[id] < charsmax(COMBO_HUMAN))
			{
				if(g_Combo[id] >= COMBO_HUMAN[g_ComboReward[id]][comboNeed] && g_Combo[id] < COMBO_HUMAN[g_ComboReward[id] + 1][comboNeed])
					break;

				++g_ComboReward[id];
			}

			g_ComboReward[id] = clamp(g_ComboReward[id], 0, charsmax(COMBO_HUMAN));
			g_ComboDamageBullet[id] = damage;

			updateComboHuman(id);
		}
	}
}

public updateComboHuman(const id)
{
	if(g_Mode != MODE_ASSASSIN && g_Mode != MODE_ANNIHILATOR)
	{
		static sCombo[16];
		static iReward;
		static sReward[16];
		static sDamageTotal[32];
		static sDamageTotalOutPut[32];
		static sDamage[32];
		static sDamageOutPut[32];

		addDot(g_Combo[id], sCombo, charsmax(sCombo));

		iReward = (g_Combo[id] * (g_ComboReward[id] + 1));

		if(iReward < 0 || iReward >= MAX_XP)
		{
			finishComboHuman(id);
			return;
		}

		addDot(iReward, sReward, charsmax(sReward));

		formatex(sDamageTotal, charsmax(sDamageTotal), "%0.0f", g_ComboDamage[id]);
		addDotSpecial(sDamageTotal, sDamageTotalOutPut, charsmax(sDamageTotalOutPut));

		formatex(sDamage, charsmax(sDamage), "%0.0f", g_ComboDamageBullet[id]);
		addDotSpecial(sDamage, sDamageOutPut, charsmax(sDamageOutPut));

		set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD_C][0], g_UserOption_Color[id][COLOR_TYPE_HUD_C][1], g_UserOption_Color[id][COLOR_TYPE_HUD_C][2], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1], g_UserOption_EffectHud[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
		if(g_UserOption_AbreviateHud[id][HUD_TYPE_COMBO])
			ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nx%s | +%s XP^n%s | %s", COMBO_HUMAN[g_ComboReward[id]][comboMessage], sCombo, sReward, sDamageTotalOutPut, sDamageOutPut);
		else
			ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nCombo x%s | +%s XP^nDaño total: %s | Daño: %s", COMBO_HUMAN[g_ComboReward[id]][comboMessage], sCombo, sReward, sDamageTotalOutPut, sDamageOutPut);
	}
}

public finishComboHuman(const id)
{
	if(g_Mode != MODE_ASSASSIN && g_Mode != MODE_ANNIHILATOR)
	{
		g_ComboTime[id] = halflife_time() + 9999.9;

		if(g_Combo[id])
		{
			static iReward;
			iReward = (g_Combo[id] * (g_ComboReward[id] + 1));

			if(iReward > 0)
			{
				addXP(id, iReward);

				static sReward[16];
				static sDamageTotal[32];
				static sDamageTotalOutPut[32];

				addDot(iReward, sReward, charsmax(sReward));

				formatex(sDamageTotal, charsmax(sDamageTotal), "%0.0f", g_ComboDamage[id]);
				addDotSpecial(sDamageTotal, sDamageTotalOutPut, charsmax(sDamageTotalOutPut));

				set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD_C][0], g_UserOption_Color[id][COLOR_TYPE_HUD_C][1], g_UserOption_Color[id][COLOR_TYPE_HUD_C][2], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1], g_UserOption_EffectHud[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
				if(g_UserOption_AbreviateHud[id][HUD_TYPE_COMBO])
					ShowSyncHudMsg(id, g_HudSync_Combo, "%s^n+%s^n%s", COMBO_HUMAN[g_ComboReward[id]][comboMessage], sReward, sDamageTotalOutPut);
				else
					ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nGanaste +%s de XP^nDaño hecho: %s", COMBO_HUMAN[g_ComboReward[id]][comboMessage], sReward, sDamageTotalOutPut);

				if((get_gametime() - g_AchievementSecret_Cortamambo[id]) >= 300.0)
				{
					g_AchievementSecret_Cortamambo[id] = 0.0;
					setAchievement(id, CORTAMAMBO);
				}

				dg_color_chat(id, _, "Tu combo humano ha finalizado y has ganado !g%s XP!y", sReward);
				playSound(id, COMBO_HUMAN[g_ComboReward[id]][comboSound]);

				switch(g_ComboReward[id])
				{
					case 1: setAchievement(id, COMBO_FIRST_BLOOD);
					case 2: setAchievement(id, COMBO_DOUBLE_KILL);
					case 3: setAchievement(id, COMBO_MULTI_KILL);
					case 4: setAchievement(id, COMBO_BLOOD_BATH);
					case 5: setAchievement(id, COMBO_ULTRA_KILL);
					case 6: setAchievement(id, COMBO_MEGA_KILL);
					case 7: setAchievement(id, COMBO_DOMINATING);
					case 8: setAchievement(id, COMBO_IMPRESSIVE);
					case 9: setAchievement(id, COMBO_RAMPAGE);
					case 10: setAchievement(id, COMBO_KILLING_SPREE);
					case 11: setAchievement(id, COMBO_GODLIKE);
					case 12: setAchievement(id, COMBO_UNSTOPPABLE);
					case 13: setAchievement(id, COMBO_HOLY_SHIT);
					case 14: setAchievement(id, COMBO_WICKED_SICK);
					case 15: setAchievement(id, COMBO_MONSTER_KILL);
					case 16: setAchievement(id, COMBO_MONSTER_KILL);
					case 17: setAchievement(id, COMBO_LUDICROUSS_KILL);
					case 18: setAchievement(id, COMBO_ITS_A_NIGHTMARE);
					case 19: setAchievement(id, COMBO_ITS_A_NIGHTMARE);
					case 20: setAchievement(id, COMBO_WHAT_THE_FUCK);
					case 21: setAchievement(id, COMBO_INFERNO);
					case 22: setAchievement(id, COMBO_INFERNO);
					case 23: setAchievement(id, COMBO_AAA);
					case 24: setAchievement(id, COMBO_LOL);
					case 25: setAchievement(id, COMBO_LOL);
					case 26: setAchievement(id, COMBO_OMG);
					case 27: setAchievement(id, COMBO_GORGEOUS);
					case 28: setAchievement(id, COMBO_GORGEOUS);
					case 29: setAchievement(id, COMBO_PUNTO);
					case 30: setAchievement(id, COMBO_PUNTO);
					case 31: setAchievement(id, COMBO_PUNTO);
				}

				if(g_Combo[id] > g_MaxComboHumanMap && !g_SpecialMode[id])
				{
					g_MaxComboHumanMap = g_Combo[id];
					
					dg_color_chat(id, _, "Conseguiste el combo máximo humano (!gx%d!y) del mapa actual (!g%s!y)", g_Combo[id], g_MapName);
					
					static Handle:sqlQuery;
					sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_combos (acc_id, combo, combo_timestamp, combo_type, mapname) VALUES ('%d', '%d', UNIX_TIMESTAMP(), '0', ^"%s^");", g_AccountId[id], g_MaxComboHumanMap, g_MapName);
					
					if(!SQL_Execute(sqlQuery))
						executeQuery(id, sqlQuery, 43);
					else
						SQL_FreeHandle(sqlQuery);
				}

				if(g_Combo[id] > g_Stats[id][STAT_COMBO_MAX] && !g_SpecialMode[id])
				{
					dg_color_chat(id, _, "Has superado tu viejo mayor combo de !g%d!y por el recién hecho de !g%d!y", g_Stats[id][STAT_COMBO_MAX], g_Combo[id]);
					g_Stats[id][STAT_COMBO_MAX] = g_Combo[id];
				}
			}
		}
	}

	g_Combo[id] = 0;
	g_ComboDamage[id] = 0.0;
	g_ComboDamageBullet[id] = 0.0;
	g_ComboReward[id] = 0;
}

public showCurrentComboZombie(const id)
{
	static Float:flDuration;
	flDuration = 10.75;

	if(g_Habs[id][HAB_D_DURATION_COMBO])
		flDuration += ((HABS[HAB_D_DURATION_COMBO][habValue] / 2) * float(g_Habs[id][HAB_D_DURATION_COMBO]));

	g_ComboTime[id] = (halflife_time() + flDuration);

	while(g_ComboZombieReward[id] < charsmax(COMBO_ZOMBIE))
	{
		if(g_ComboZombie[id] >= COMBO_ZOMBIE[g_ComboZombieReward[id]][comboNeed] && g_ComboZombie[id] < COMBO_ZOMBIE[(g_ComboZombieReward[id] + 1)][comboNeed])
			break;

		++g_ComboZombieReward[id];
	}

	g_ComboZombieReward[id] = clamp(g_ComboZombieReward[id], 0, charsmax(COMBO_ZOMBIE));

	static sReward[16];
	addDot(rewardComboZombie(id), sReward, charsmax(sReward));

	set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD_C][0], g_UserOption_Color[id][COLOR_TYPE_HUD_C][1], g_UserOption_Color[id][COLOR_TYPE_HUD_C][2], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1], g_UserOption_EffectHud[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
	if(g_UserOption_AbreviateHud[id][HUD_TYPE_COMBO])
		ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nx%d INF | +%s XP", COMBO_ZOMBIE[g_ComboZombieReward[id]][comboMessage], g_ComboZombie[id], sReward);
	else
		ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nCombo x%d Infecci%s | +%s XP", COMBO_ZOMBIE[g_ComboZombieReward[id]][comboMessage], g_ComboZombie[id], ((g_ComboZombie[id] != 1) ? "ones" : "ón"), sReward);
}

public rewardComboZombie(const id)
{
	static Float:flCombo;
	static Float:flConversion;
	static Float:flReward;
	
	flCombo = (float(g_ComboZombie[id]) * 150.0);
	flConversion = float(getUserNextLevel(id)) - float(getUserNextLevel(id, .rest=1));
	flReward = ((flConversion * flCombo) / 100.0);

	return (floatround(flReward) * g_ComboZombie[id]);
}

public finishComboZombie(const id)
{
	g_ComboTime[id] = (halflife_time() + 9999.9);

	if(g_ComboZombie[id])
	{
		static iReward;
		iReward = rewardComboZombie(id);

		if(iReward)
		{
			addXP(id, iReward);
			
			static sReward[16];
			addDot(iReward, sReward, charsmax(sReward));

			set_hudmessage(g_UserOption_Color[id][COLOR_TYPE_HUD_C][0], g_UserOption_Color[id][COLOR_TYPE_HUD_C][1], g_UserOption_Color[id][COLOR_TYPE_HUD_C][2], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1], g_UserOption_EffectHud[id][HUD_TYPE_COMBO], 1.0, 8.0, 0.01, 0.01);
			if(g_UserOption_AbreviateHud[id][HUD_TYPE_COMBO])
				ShowSyncHudMsg(id, g_HudSync_Combo, "%s^n+%s de XP^n%d", COMBO_ZOMBIE[g_ComboZombieReward[id]][comboMessage], sReward, g_ComboZombie[id]);
			else
				ShowSyncHudMsg(id, g_HudSync_Combo, "%s^nGanaste +%s de XP^nInfecciones en total: %d", COMBO_ZOMBIE[g_ComboZombieReward[id]][comboMessage], sReward, g_ComboZombie[id]);

			dg_color_chat(id, _, "Tu combo zombie ha finalizado y has ganado !g%s XP!y", sReward);
			playSound(id, COMBO_ZOMBIE[g_ComboZombieReward[id]][comboSound]);

			switch(g_ComboZombieReward[id])
			{
				case 1: setAchievement(id, COMBO_FIRST_BLOOD_ZOMBIE);
				case 2: setAchievement(id, COMBO_DOUBLE_KILL_ZOMBIE);
				case 3: setAchievement(id, COMBO_MULTI_KILL_ZOMBIE);
				case 4: setAchievement(id, COMBO_BLOOD_BATH_ZOMBIE);
				case 5: setAchievement(id, COMBO_ULTRA_KILL_ZOMBIE);
				case 6: setAchievement(id, COMBO_MEGA_KILL_ZOMBIE);
				case 7: setAchievement(id, COMBO_DOMINATING_ZOMBIE);
				case 8: setAchievement(id, COMBO_IMPRESSIVE_ZOMBIE);
				case 9: setAchievement(id, COMBO_RAMPAGE_ZOMBIE);
				case 10: setAchievement(id, COMBO_KILLING_SPREE_ZOMBIE);
				case 11: setAchievement(id, COMBO_GODLIKE_ZOMBIE);
				case 12: setAchievement(id, COMBO_UNSTOPPABLE_ZOMBIE);
				case 13: setAchievement(id, COMBO_HOLY_SHIT_ZOMBIE);
				case 14: setAchievement(id, COMBO_WICKED_SICK_ZOMBIE);
				case 15: setAchievement(id, COMBO_MONSTER_KILL_ZOMBIE);
				case 16: setAchievement(id, COMBO_MONSTER_KILL_ZOMBIE);
				case 17: setAchievement(id, COMBO_LUDICROUSS_KILL_ZOMBIE);
				case 18: setAchievement(id, COMBO_ITS_A_NIGHTMARE_ZOMBIE);
				case 19: setAchievement(id, COMBO_ITS_A_NIGHTMARE_ZOMBIE);
				case 20: setAchievement(id, COMBO_WHAT_THE_FUCK_ZOMBIE);
				case 21: setAchievement(id, COMBO_INFERNO_ZOMBIE);
				case 22: setAchievement(id, COMBO_INFERNO_ZOMBIE);
				case 23: setAchievement(id, COMBO_AAA_ZOMBIE);
				case 24: setAchievement(id, COMBO_LOL_ZOMBIE);
				case 25: setAchievement(id, COMBO_LOL_ZOMBIE);
				case 26: setAchievement(id, COMBO_OMG_ZOMBIE);
				case 27: setAchievement(id, COMBO_GORGEOUS_ZOMBIE);
				case 28: setAchievement(id, COMBO_GORGEOUS_ZOMBIE);
				case 29: setAchievement(id, COMBO_PUNTO_ZOMBIE);
				case 30: setAchievement(id, COMBO_PUNTO_ZOMBIE);
				case 31: setAchievement(id, COMBO_PUNTO_ZOMBIE);
			}

			if(g_ComboZombie[id] > g_MaxComboZombieMap && !g_SpecialMode[id])
			{
				g_MaxComboZombieMap = g_ComboZombie[id];
				
				dg_color_chat(id, _, "Conseguiste el combo máximo zombie (!gx%d!y) del mapa actual (!g%s!y)", g_ComboZombie[id], g_MapName);
				
				static Handle:sqlQuery;
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_combos (acc_id, combo, combo_timestamp, combo_type, mapname) VALUES ('%d', '%d', UNIX_TIMESTAMP(), '1', ^"%s^");", g_AccountId[id], g_MaxComboZombieMap, g_MapName);
				
				if(!SQL_Execute(sqlQuery))
					executeQuery(id, sqlQuery, 44);
				else
					SQL_FreeHandle(sqlQuery);
			}
		}
	}

	g_ComboZombie[id] = 0;
	g_ComboZombieReward[id] = 0;
}

public setUserBatteries(const id, const value)
{
	if(pev_valid(id) != PDATA_SAFE)
		return;

	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX);
}

public setUserTeamUpdate(const id)
{
	static Float:flGameTime;
	flGameTime = get_gametime();
	
	if((flGameTime - g_TeamsTargetTime) >= 0.1)
	{
		set_task(0.1, "task__SetUserTeamMsg", id + TASK_TEAM);
		g_TeamsTargetTime = (flGameTime + 0.1);
	}
	else
	{
		set_task(((g_TeamsTargetTime + 0.1) - flGameTime), "task__SetUserTeamMsg", id + TASK_TEAM);
		g_TeamsTargetTime += 0.1;
	}
}

public getUserModel(const id, model[], const len)
	get_user_info(id, "model", model, len);

public respawnUserManually(const id)
{
	if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME)
	{
		if(g_ModeGG_End)
			return;

		setUserTeam(id, ((random_num(0, 1)) ? F_TEAM_T : F_TEAM_CT));
	}
	else
		setUserTeam(id, ((g_RespawnAsZombie[id]) ? F_TEAM_T : F_TEAM_CT));

	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public getCurrentWeaponEnt(const id)
{
	if(pev_valid(id) != PDATA_SAFE)
		return -1;

	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

public replaceWeaponModels(const id, const weapon_id)
{
	switch(weapon_id)
	{
		case CSW_KNIFE:
		{
			if(g_Zombie[id])
			{
				switch(g_SpecialMode[id])
				{
					case MODE_NEMESIS: entity_set_string(id, EV_SZ_viewmodel, KNIFE_vMODEL_NEMESIS);
					case MODE_ASSASSIN: entity_set_string(id, EV_SZ_viewmodel, KNIFE_vMODEL_ASSASSIN);
					case MODE_ANNIHILATOR: entity_set_string(id, EV_SZ_viewmodel, KNIFE_vMODEL_ANNIHILATOR);
					case MODE_FVSJ:
					{
						if(!g_ModeFvsJ_Jason[id])
							entity_set_string(id, EV_SZ_viewmodel, KNIFE_vMODEL_FREDDY);
					}
					case MODE_AVSP:
					{
						if(g_SpecialMode_Alien[id])
							entity_set_string(id, EV_SZ_viewmodel, KNIFE_vMODEL_ALIEN);
					}
					default:
					{
						static sBuffer[128];
						sBuffer[0] = EOS;

						if(g_AccountId[id] == 49)
						{
							formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", PLAYER_MODEL_L4D2_ZMS, PLAYER_MODEL_L4D2_ZMS);
							entity_set_string(id, EV_SZ_viewmodel, sBuffer);
						}
						else
						{
							if(MODELS[g_ModelSelected[id][MODEL_ZOMBIE]][modelPrecache][0])
							{
								formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", MODELS[g_ModelSelected[id][MODEL_ZOMBIE]][modelPrecache], MODELS[g_ModelSelected[id][MODEL_ZOMBIE]][modelPrecache]);
								entity_set_string(id, EV_SZ_viewmodel, sBuffer);
							}
						}
					}
				}

				entity_set_string(id, EV_SZ_weaponmodel, "");
			}
			else
			{
				switch(g_SpecialMode[id])
				{
					case MODE_JASON:
					{
						entity_set_string(id, EV_SZ_viewmodel, KNIFE_vMODEL_JASON[0]);
						entity_set_string(id, EV_SZ_weaponmodel, KNIFE_vMODEL_JASON[1]);
					}
					default:
					{
						if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
						{
							entity_set_string(id, EV_SZ_viewmodel, "models/v_knife.mdl");
							entity_set_string(id, EV_SZ_weaponmodel, "models/p_knife.mdl");
						}
						else
						{
							if(g_WeaponModel[id][weapon_id])
								entity_set_string(id, EV_SZ_viewmodel, WEAPON_MODELS[weapon_id][(g_WeaponModel[id][weapon_id] - 1)][weaponModelPath]);
						}
					}
				}
			}
		}
		case CSW_HEGRENADE:
		{
			if(g_Zombie[id])
			{
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_INFECTION[0]);
				entity_set_string(id, EV_SZ_weaponmodel, GRENADE_MODEL_INFECTION[1]);
			}
			else
			{
				if(g_DrugBomb[id])
				{
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_DRUG[0]);
					entity_set_string(id, EV_SZ_weaponmodel, GRENADE_MODEL_DRUG[1]);
				}
				else if(g_NitroBomb[id])
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_NITRO);
				else if(g_KillBomb[id])
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_KILL);
				else
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_FIRE);
			}
		}
		case CSW_FLASHBANG:
		{
			if(g_HyperNovaBomb[id])
			{
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_HYPERNOVA[0]);
				entity_set_string(id, EV_SZ_weaponmodel, GRENADE_MODEL_HYPERNOVA[1]);
			}
			else if(g_SuperNovaBomb[id])
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_SUPERNOVA);
			else if(g_MolotovBomb[id])
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_MOLOTOV);
			else
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_NOVA);
		}
		case CSW_SMOKEGRENADE:
		{
			if(g_BubbleBomb[id])
			{
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_BUBBLE[0]);
				entity_set_string(id, EV_SZ_weaponmodel, GRENADE_MODEL_BUBBLE[1]);
			}
			else if(g_ImmunityBomb[id])
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_IMMUNITY);
			else if(g_AntidoteBomb[id])
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_ANTIDOTE);
			else
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_vMODEL_FLARE);
		}
		default:
		{
			if(g_Zombie[id])
			{
				if((g_SpecialMode[id] == MODE_NEMESIS || g_SpecialMode[id] == MODE_ANNIHILATOR) && g_ModeNemesis_Bazooka[id] && g_CurrentWeapon[id] == CSW_AK47)
				{
					entity_set_string(id, EV_SZ_viewmodel, BAZOOKA_vMODEL);
					entity_set_string(id, EV_SZ_weaponmodel, BAZOOKA_pMODEL);

					setAnimation(id, 3);
				}
			}
			else
			{
				if(g_WeaponModel[id][weapon_id])
					entity_set_string(id, EV_SZ_viewmodel, WEAPON_MODELS[weapon_id][(g_WeaponModel[id][weapon_id] - 1)][weaponModelPath]);
			}
		}
	}
}

public checkRound(const leaving_id)
{
	if(g_VirusT != 2 || g_EndRound)
		return;

	static iUsersAlive;
	static iId;

	iUsersAlive = getAlives();

	switch(g_Mode)
	{
		case MODE_MEGA_ARMAGEDDON:
		{
			if(getZombies() == 1)
			{
				if(g_SpecialMode[leaving_id] == MODE_NEMESIS)
					endModeMegaArmageddon(1);
				else if(g_LastZombie[leaving_id])
					checkModeMegaArmageddonTwo(0);
			}
			else if(getHumans() == 1)
			{
				if(g_SpecialMode[leaving_id] == MODE_SURVIVOR)
					endModeMegaArmageddon(0);
				else if(g_LastHuman[leaving_id])
					checkModeMegaArmageddonTwo(1);
			}

			return;
		}
		case MODE_SYNAPSIS:
		{
			if(g_SpecialMode[leaving_id] == MODE_NEMESIS && getHumans() > 1)
			{
				while((iId = getRandomUser(.alive=1)) == leaving_id || g_Zombie[iId]) {}

				if(!g_Zombie[iId])
				{
					if(g_ClanSlot[iId])
					{
						if(g_ClanCombo[g_ClanSlot[iId]])
						{
							sendClanMessage(iId, "Un miembro humano del clan ha sido convertido en nemesis y el combo ha finalizado");
							clanFinishCombo(iId);
						}

						clanUpdateHumans(iId);
					}

					finishComboHuman(iId);
				}

				dg_color_chat(0, _, "El nemesis se ha ido, !g%s!y es el nuevo nemesis", g_PlayerName[iId]);
				zombieMe(iId, .nemesis=1);

				if(!g_ModeNemesis_Bazooka[leaving_id])
				{
					g_ModeNemesis_Bazooka[iId] = 0;
					g_ModeNemesis_BazookaLast[iId] = 0.0;

					strip_user_weapons(iId);
					give_item(iId, "weapon_knife");
				}

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			else if(!g_Zombie[leaving_id] && getHumans() == 1)
				return;
		}
		case MODE_AVSP:
		{
			if(g_SpecialMode_Alien[leaving_id])
			{
				if(getZombies() > 1)
				{
					while((iId = getRandomUser(.alive=1)) == leaving_id || !g_Zombie[iId]) { }

					if(!g_Zombie[iId])
					{
						if(g_ClanSlot[iId])
						{
							if(g_ClanCombo[g_ClanSlot[iId]])
							{
								sendClanMessage(iId, "Un miembro humano del clan ha sido convertido en nemesis y el combo ha finalizado");
								clanFinishCombo(iId);
							}

							clanUpdateHumans(iId);
						}

						finishComboHuman(iId);
					}

					dg_color_chat(0, _, "El alien se ha ido, !g%s!y es el nuevo alien", g_PlayerName[iId]);
					zombieMe(iId, .alien=1);

					g_ModeAvsp_AlienPower[iId] = g_ModeAvsp_AlienPower[leaving_id];
					
					set_user_health(iId, g_Health[leaving_id]);
					g_Health[iId] = g_Health[leaving_id];

					return;
				}
				
				checkModeAvsP(iId);
				return;
			}
			else if(g_SpecialMode_Predator[leaving_id])
			{
				if(getHumans() > 1)
				{
					while((iId = getRandomUser(.alive=1)) == leaving_id || g_Zombie[iId]) { }

					if(g_Zombie[iId])
						finishComboZombie(iId);

					dg_color_chat(0, _, "El depredador se ha ido, !g%s!y es el nuevo depredador", g_PlayerName[iId]);
					humanMe(iId, .predator=1);

					g_ModeAvsp_PredatorPower[iId] = g_ModeAvsp_PredatorPower[leaving_id];

					set_user_health(iId, g_Health[leaving_id]);
					g_Health[iId] = g_Health[leaving_id];

					return;
				}
				
				checkModeAvsP(iId);
				return;
			}
		}
		case MODE_DUEL_FINAL:
		{
			if(getHumans() == 2)
			{
				if(g_ModeDuelFinal == DF_QUARTER || g_ModeDuelFinal == DF_SEMIFINAL || g_ModeDuelFinal == DF_FINAL)
				{
					for(new i = 1; i <= g_MaxPlayers; ++i)
					{
						if(!g_IsAlive[i])
							continue;

						user_kill(i, 1);
						break;
					}
				}

				remove_task(TASK_MODE_DUEL_FINAL);
				set_task(2.0, "task__ModeDuelFinal", TASK_MODE_DUEL_FINAL);
			}

			return;
		}
		case MODE_SNIPER:
		{
			if(g_SpecialMode[leaving_id] == MODE_SNIPER && getHumans() == 1)
				return;
			else if(g_Zombie[leaving_id] && getZombies() == 1)
			{
				static iSnipers[4];
				static j;
				static k;
				static iRewardPoints;

				iSnipers = {0, 0, 0, 0};
				j = 0;
				k = 0;
				iRewardPoints = 0;

				for(new i = 1; i <= g_MaxPlayers; ++i)
				{
					if(!g_IsConnected[i])
						continue;

					if(g_SpecialMode[i] == MODE_SNIPER)
						continue;

					iSnipers[j] = i;

					dg_color_chat(i, _, "Ganaste !g%d pH!y por ganar el modo !gSNIPER!y", g_PointsMult[i]);
					g_Points[i][POINT_HUMAN] += g_PointsMult[i];

					++j;
				}

				g_PointsMult[0] = 0;

				dg_color_chat(0, _, "Los !tSNIPERS!y ganaron !g%d !y/!g %d !y/!g %d !y/!g %d pH!y por ganar el modo !gSNIPER!y", g_PointsMult[iSnipers[0]], g_PointsMult[iSnipers[1]], g_PointsMult[iSnipers[2]], g_PointsMult[iSnipers[3]]);

				if(g_ModeSniper_Damage >= 500000)
				{
					if(g_ModeSniper_Damage >= 1000000)
					{
						if(g_ModeSniper_Damage >= 5000000)
						{
							if(g_ModeSniper_Damage >= 10000000)
								iRewardPoints = 4;
							else
								iRewardPoints = 3;
						}
						else
							iRewardPoints = 2;
					}
					else
						iRewardPoints = 1;

					dg_color_chat(0, _, "Los !tSNIPERS!y ganaron un bonus de !g%d pH!y por hacer realizado !g%d de daño!y en la ronda", iRewardPoints, g_ModeSniper_Damage);
				}

				for(new i = 0; i < j; ++i)
				{
					g_Points[iSnipers[i]][POINT_HUMAN] += iRewardPoints;

					if(g_IsAlive[iSnipers[i]])
					{
						setAchievement(iSnipers[i], L_FRANCOTIRADOR);
						++k;

						if(!g_Achievement_SniperNoDmg[iSnipers[i]])
							setAchievement(iSnipers[i], NO_TENGO_BALAS);
					}

					g_Achievement_SniperNoDmg[iSnipers[i]] = 0;
				}

				switch(k)
				{
					case 1:
					{
						for(new i = 0; i < j; ++i)
						{
							if(g_IsAlive[iSnipers[i]])
							{
								setAchievement(iSnipers[i], EN_MEMORIA_A_ELLOS);
								break;
							}
						}
					}
					case 2:
					{
						static iAwp;
						static iScout;

						iAwp = 0;
						iScout = 0;

						for(new i = 0; i < j; ++i)
						{
							if(user_has_weapon(iSnipers[i], CSW_AWP))
								++iAwp;

							if(user_has_weapon(iSnipers[i], CSW_SCOUT))
								++iScout;
						}

						if(iAwp == 2)
						{
							setAchievement(iSnipers[0], SOBREVIVEN_LOS_DUROS);
							setAchievement(iSnipers[1], SOBREVIVEN_LOS_DUROS);
						}
						else if(iScout == 2)
						{
							setAchievement(iSnipers[0], NO_SOLO_LA_GANAN_LOS_DUROS);
							setAchievement(iSnipers[1], NO_SOLO_LA_GANAN_LOS_DUROS);
						}
					}
					case 4:
					{
						setAchievement(iSnipers[0], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[1], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[2], EL_MEJOR_EQUIPO);
						setAchievement(iSnipers[3], EL_MEJOR_EQUIPO);
					}
				}

				return;
			}
		}
		case MODE_TRIBAL:
		{
			if(getZombies() == 1)
				tribalModeWin();
		}
	}

	if(iUsersAlive < 3)
	{
		if(g_Mode == MODE_INFECTION || g_Mode == MODE_PLAGUE || g_Mode == MODE_ARMAGEDDON)
			return;

		g_EndRound_Forced = 1;
		return;
	}

	if(g_Zombie[leaving_id] && getZombies() == 1)
	{
		if(getHumans() == 1 && getCTs() == 1)
			return;

		while((iId = getRandomUser(.alive=1)) == leaving_id) {}

		switch(g_SpecialMode[leaving_id])
		{
			case MODE_NEMESIS:
			{
				if(!g_Zombie[iId])
				{
					if(g_ClanSlot[iId])
					{
						if(g_ClanCombo[g_ClanSlot[iId]])
						{
							sendClanMessage(iId, "Un miembro humano del clan ha sido convertido en nemesis y el combo ha finalizado");
							clanFinishCombo(iId);
						}

						clanUpdateHumans(iId);
					}

					finishComboHuman(iId);
				}
				else
					finishComboZombie(iId);

				dg_color_chat(0, _, "El nemesis se ha desconectado, !g%s!y es el nuevo nemesis", g_PlayerName[iId]);
				zombieMe(iId, .nemesis=1);

				if(!g_ModeNemesis_Bazooka[leaving_id])
				{
					g_ModeNemesis_Bazooka[iId] = g_ModeNemesis_Bazooka[leaving_id];
					g_ModeNemesis_BazookaLast[iId] = 0.0;

					give_item(iId, "weapon_ak47");
					cs_set_user_bpammo(iId, CSW_AK47, 0);
					cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_ak47", iId), 0);
				}

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			case MODE_ASSASSIN:
			{
				if(!g_Zombie[iId])
				{
					if(g_ClanSlot[iId])
					{
						if(g_ClanCombo[g_ClanSlot[iId]])
						{
							sendClanMessage(iId, "Un miembro humano del clan ha sido convertido en assassin y el combo ha finalizado");
							clanFinishCombo(iId);
						}

						clanUpdateHumans(iId);
					}

					finishComboHuman(iId);
				}
				else
					finishComboZombie(iId);

				dg_color_chat(0, _, "El assassin se ha desconectado, !g%s!y es el nuevo assassin", g_PlayerName[iId]);
				zombieMe(iId, .assassin=1);

				g_ModeAssassin_PowerGlow[iId] = g_ModeAssassin_PowerGlow[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			case MODE_ANNIHILATOR:
			{
				dg_color_chat(0, _, "El aniquilador se ha desconectado, !g%s!y es el nuevo aniquilador", g_PlayerName[iId]);
				zombieMe(iId, .annihilator=1);

				if(g_ModeNemesis_Bazooka[leaving_id])
				{
					g_ModeNemesis_Bazooka[iId] = g_ModeNemesis_Bazooka[leaving_id];
					g_ModeNemesis_BazookaLast[iId] = 0.0;

					give_item(iId, "weapon_ak47");
					cs_set_user_bpammo(iId, CSW_AK47, 0);
					cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_ak47", iId), 0);
				}

				static iWeaponEntLeavingId;
				static iAmmo;
				static iClip;
				
				iWeaponEntLeavingId = find_ent_by_owner(-1, "weapon_mac10", leaving_id);
				iAmmo = get_pdata_int(leaving_id, AMMO_OFFSET[CSW_MAC10], OFFSET_LINUX);
				iClip = get_pdata_int(iWeaponEntLeavingId, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
				
				if(iAmmo || iClip)
				{
					give_item(iId, "weapon_mac10");
					
					static iWeaponEntId;
					iWeaponEntId = find_ent_by_owner(-1, "weapon_mac10", iId);
					
					set_pdata_int(iId, AMMO_OFFSET[CSW_MAC10], iAmmo, OFFSET_LINUX);
					set_pdata_int(iWeaponEntId, OFFSET_CLIPAMMO, iClip, OFFSET_LINUX_WEAPONS);
				}

				g_CurrentWeapon[iId] = CSW_KNIFE;
				engclient_cmd(iId, "weapon_knife");

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			case MODE_GRUNT:
			{
				dg_color_chat(0, _, "El grunt se ha desconectado, !g%s!y es el nuevo grunt", g_PlayerName[iId]);
				zombieMe(iId, .grunt=1);

				g_ModeGrunt_Reward[iId] = g_ModeGrunt_Reward[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			default:
			{
				if(!g_Zombie[iId])
				{
					if(g_ClanSlot[iId])
					{
						if(g_ClanCombo[g_ClanSlot[iId]])
						{
							sendClanMessage(iId, "Un miembro humano del clan ha sido convertido en zombie y el combo ha finalizado");
							clanFinishCombo(iId);
						}

						clanUpdateHumans(iId);
					}

					finishComboHuman(iId);
				}
				else
					finishComboZombie(iId);

				dg_color_chat(0, _, "El último zombie se ha desconectado, !g%s!y es el nuevo zombie", g_PlayerName[iId]);
				zombieMe(iId);
			}
		}
	}
	else if(!g_Zombie[leaving_id] && getHumans() == 1)
	{
		if(getZombies() == 1 && getTs() == 1)
			return;

		while((iId = getRandomUser(.alive=1)) == leaving_id) {}

		switch(g_SpecialMode[leaving_id])
		{
			case MODE_SURVIVOR:
			{
				if(g_Zombie[iId])
					finishComboZombie(iId);

				dg_color_chat(0, _, "El survivor se ha desconectado, !g%s!y es el nuevo survivor", g_PlayerName[iId]);
				humanMe(iId, .survivor=1);

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			case MODE_WESKER:
			{
				if(g_Zombie[iId])
					finishComboZombie(iId);

				dg_color_chat(0, _, "El wesker se ha desconectado, !g%s!y es el nuevo wesker", g_PlayerName[iId]);
				humanMe(iId, .wesker=1);

				g_ModeWesker_Laser[iId] = g_ModeWesker_Laser[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			case MODE_SNIPER_ELITE:
			{
				if(g_Zombie[iId])
					finishComboZombie(iId);

				dg_color_chat(0, _, "El sniper elite se ha desconectado, !g%s!y es el nuevo sniper elite", g_PlayerName[iId]);
				humanMe(iId, .sniper_elite=1);

				g_ModeSniperElite_Speed[iId] = g_ModeSniperElite_Speed[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			case MODE_JASON:
			{
				if(g_Zombie[iId])
					finishComboZombie(iId);

				dg_color_chat(0, _, "El jason se ha desconectado, !g%s!y es el nuevo jason", g_PlayerName[iId]);
				humanMe(iId, .jason=1);

				g_ModeJason_Teleport[iId] = g_ModeJason_Teleport[leaving_id];

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = g_Health[leaving_id];
			}
			default:
			{
				if(g_Zombie[iId])
					finishComboZombie(iId);

				dg_color_chat(0, _, "El último humano se ha desconectado, !g%s!y es el nuevo humano", g_PlayerName[iId]);
				humanMe(iId);
			}
		}
	}
}

public getWeaponEntId(const weapon_ent)
{
	if(pev_valid(weapon_ent) != PDATA_SAFE)
		return -1;

	return get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

public checkHappyHourAndEvents()
{
	g_HappyTime = 0;
	g_EventModes = 0;

	new iArgTime;
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new iTimeToUnix[3];
	new iUsersNum;

	iArgTime = (get_systime() - 10800);
	unix_to_time(iArgTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	iUsersNum = getPlaying();

	iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 13, 00, 00);
	iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 17, 00, 00);

	if(iArgTime >= iTimeToUnix[0] && iArgTime <= iTimeToUnix[1])
	{
		++g_HappyTime;
		dg_color_chat(0, SPECTATOR, "!tDRUNK AT DAY!y: Tus multiplicador de XP aumenta un !g+x1!y");

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 14, 15, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 15, 15, 00);

		if(iArgTime >= iTimeToUnix[0] && iArgTime <= iTimeToUnix[1])
		{
			if(iUsersNum >= MIN_USERS_FOR_EVENTMODES)
			{
				++g_EventModes;
				dg_color_chat(0, SPECTATOR, "!tEVENTO DE MODOS!y: Sólo salen modos especiales");
			}
			else
			{
				--g_EventModes;

				new iRest;
				iRest = (MIN_USERS_FOR_EVENTMODES - iUsersNum);

				dg_color_chat(0, SPECTATOR, "!tEVENTO DE MODOS!y: Faltan !g%d jugador%s!y para que se active el evento", iRest, ((iRest != 1) ? "es" : ""));
			}
		}
	}

	iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 20, 00, 00);
	iTimeToUnix[2] = time_to_unix(iYear, iMonth, iDay, 00, 00, 00);
	iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 08, 00, 00);

	if((iArgTime >= iTimeToUnix[0]) || (iArgTime >= iTimeToUnix[2] && iArgTime <= iTimeToUnix[1]))
	{
		++g_HappyTime;

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 00, 15, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 03, 59, 59);

		if(iArgTime >= iTimeToUnix[0] && iArgTime <= iTimeToUnix[1])
		{
			++g_HappyTime;

			iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 04, 00, 00);
			iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 07, 59, 59);

			if(iArgTime >= iTimeToUnix[0] && iArgTime <= iTimeToUnix[1])
			{
				++g_HappyTime;
				dg_color_chat(0, SPECTATOR, "!tHYPER HAPPY HOUR NIGHT!y: Tus multiplicador de XP aumenta un !g+x3!y");
			}
			else
				dg_color_chat(0, SPECTATOR, "!tSUPER HAPPY HOUR NIGHT!y: Tus multiplicador de XP aumenta un !g+x2!y");
			
			if(!g_ModeMGG_Played)
				g_ModeMGG_Played = 2;
		}
		else
			dg_color_chat(0, SPECTATOR, "!tHAPPY HOUR NIGHT!y: Tus multiplicador de XP aumenta un !g+x1!y");

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 23, 00, 00);
		iTimeToUnix[2] = time_to_unix(iYear, iMonth, iDay, 00, 00, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 00, 30, 00);

		if((iArgTime >= iTimeToUnix[0]) || (iArgTime >= iTimeToUnix[2] && iArgTime <= iTimeToUnix[1]))
		{
			if(iUsersNum >= MIN_USERS_FOR_EVENTMODES)
			{
				++g_EventModes;
				dg_color_chat(0, SPECTATOR, "!tEVENTO DE MODOS!y: Sólo salen modos especiales");

				if(g_EventMode_MegaArmageddon > 0 || g_EventMode_GunGame > 0)
				{
					if(g_EventMode_GunGame > 0)
						dg_color_chat(0, _, "GunGame %s en !g%d ronda%s!y - Mega Armageddon en !g%d ronda%s!y.", GUNGAME_TYPE_NAME[g_ModeGG_Type], g_EventMode_GunGame, ((g_EventMode_GunGame != 1) ? "s" : ""), g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
					else
						dg_color_chat(0, _, "Mega Armageddon en !g%d ronda%s!y", g_EventMode_MegaArmageddon, ((g_EventMode_MegaArmageddon != 1) ? "s" : ""));
				}
			}
			else
			{
				--g_EventModes;

				new iRest;
				iRest = (MIN_USERS_FOR_EVENTMODES - iUsersNum);

				dg_color_chat(0, SPECTATOR, "!tEVENTO DE MODOS!y: Faltan !g%d usuario%s!y para que se active el evento", iRest, ((iRest != 1) ? "s" : ""));
			}
		}
	}

	if(iUsersNum < (MIN_USERS_FOR_GAME / 2))
	{
		new i;
		for(i = 1; i <= MaxClients; ++i)
		{
			if(!g_AccountLogged[i])
				continue;

			g_SysTime_Connect[i] = get_systime();
		}
	}
	else
	{
		if(iUsersNum >= MIN_USERS_FOR_GAME)
		{
			static iBonus;
			iBonus = (getPlaying() / MIN_USERS_FOR_GAME);

			if(iBonus < 0)
				iBonus = 0;

			g_PlayerBonus = clamp(iBonus, 1, 8);
		}
	}
}

public getUserAura(const id)
	return ((g_Aura[id][3]) ? 1 : 0);

setUserAura(const id, const color_r=0, const color_g=0, const color_b=0, const radius=0)
{
	if(!color_r && !color_g && !color_b && !radius)
	{
		g_Aura[id][0] = 0;
		g_Aura[id][1] = 0;
		g_Aura[id][2] = 0;
		g_Aura[id][3] = 0;

		return;
	}

	g_Aura[id][0] = color_r;
	g_Aura[id][1] = color_g;
	g_Aura[id][2] = color_b;
	g_Aura[id][3] = radius;
}

public buyPrimaryWeapons(const id, const selection)
{
	if(g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_GRUNT || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	g_WeaponPrimary_Current[id] = selection;

	give_item(id, PRIMARY_WEAPONS[selection][weaponEntName]);
	cs_set_user_bpammo(id, PRIMARY_WEAPONS[selection][weaponCSW], MAX_BPAMMO[PRIMARY_WEAPONS[selection][weaponCSW]]);
}

public buySecondaryWeapons(const id, const selection)
{
	if(g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_GRUNT || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;

	g_WeaponSecondary_Current[id] = selection;

	give_item(id, SECONDARY_WEAPONS[selection][weaponEntName]);
	cs_set_user_bpammo(id, SECONDARY_WEAPONS[selection][weaponCSW], MAX_BPAMMO[SECONDARY_WEAPONS[selection][weaponCSW]]);
}

public buyGrenades(const id)
{
	if(g_Mode == MODE_SYNAPSIS || g_Mode == MODE_FVSJ || g_Mode == MODE_GRUNT || g_Mode == MODE_NEMESIS || g_Mode == MODE_ASSASSIN || g_Mode == MODE_ANNIHILATOR || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL)
		return;

	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_smokegrenade");

	switch(g_Reset[id])
	{
		case 0..4:
		{
			cs_set_user_bpammo(id, CSW_HEGRENADE, 1);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 1);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 1);

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_HE])
			{
				case 1: g_NitroBomb[id] = 1;
				case 2: g_DrugBomb[id] = 1;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_FB])
			{
				case 1: g_SuperNovaBomb[id] = 1;
				case 2: g_HyperNovaBomb[id] = 1;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_SG])
			{
				case 1: g_ImmunityBomb[id] = 1;
				case 2: g_BubbleBomb[id] = 1;
			}
		}
		case 5..9:
		{
			cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2);

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_HE])
			{
				case 1: g_NitroBomb[id] = 2;
				case 2: g_DrugBomb[id] = 2;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_FB])
			{
				case 1: g_SuperNovaBomb[id] = 2;
				case 2: g_HyperNovaBomb[id] = 2;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_SG])
			{
				case 1: g_ImmunityBomb[id] = 2;
				case 2: g_BubbleBomb[id] = 2;
			}
		}
		case 10..14:
		{
			cs_set_user_bpammo(id, CSW_HEGRENADE, 3);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 3);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 3);

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_HE])
			{
				case 1: g_NitroBomb[id] = 3;
				case 2: g_DrugBomb[id] = 3;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_FB])
			{
				case 1: g_SuperNovaBomb[id] = 3;
				case 2: g_HyperNovaBomb[id] = 3;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_SG])
			{
				case 1: g_ImmunityBomb[id] = 3;
				case 2: g_BubbleBomb[id] = 3;
			}
		}
		case 15..19:
		{
			cs_set_user_bpammo(id, CSW_HEGRENADE, 4);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 4);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 4);

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_HE])
			{
				case 1: g_NitroBomb[id] = 4;
				case 2: g_DrugBomb[id] = 4;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_FB])
			{
				case 1: g_SuperNovaBomb[id] = 4;
				case 2: g_HyperNovaBomb[id] = 4;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_SG])
			{
				case 1: g_ImmunityBomb[id] = 4;
				case 2: g_BubbleBomb[id] = 4;
			}
		}
		case 20..25:
		{
			cs_set_user_bpammo(id, CSW_HEGRENADE, 5);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 5);
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 5);

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_HE])
			{
				case 1: g_NitroBomb[id] = 5;
				case 2: g_DrugBomb[id] = 5;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_FB])
			{
				case 1: g_SuperNovaBomb[id] = 5;
				case 2: g_HyperNovaBomb[id] = 5;
			}

			switch(g_Habs[id][HAB_S_UPDATE_GRENADE_SG])
			{
				case 1: g_ImmunityBomb[id] = 5;
				case 2: g_BubbleBomb[id] = 5;
			}
		}
	}
}

public hamStripWeapon(const id, const weapon_name[], const weapon_csw)
{
	if(!equal(weapon_name, "weapon_", 7))
		return 0;

	if(!weapon_csw)
		return 0;

	static iWeaponEnt;
	iWeaponEnt = -1;

	while((iWeaponEnt = find_ent_by_class(iWeaponEnt, weapon_name)) && entity_get_edict(iWeaponEnt, EV_ENT_owner) != id) {}

	if(!iWeaponEnt)
		return 0;

	if(g_CurrentWeapon[id] == weapon_csw)
		ExecuteHamB(Ham_Weapon_RetireWeapon, iWeaponEnt);

	if(!ExecuteHamB(Ham_RemovePlayerItem, id, iWeaponEnt))
		return 0;

	ExecuteHamB(Ham_Item_Kill, iWeaponEnt);

	entity_set_int(id, EV_INT_weapons, entity_get_int(id, EV_INT_weapons) & ~(1<<weapon_csw));
	return 1;
}

public checkAchievementsWeapons(const id, const weapon_id)
{
	if(weapon_id == CSW_M249 || weapon_id == CSW_AWP || weapon_id == CSW_SCOUT || weapon_id == CSW_G3SG1 || weapon_id == CSW_SG550)
		return;

	switch(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL])
	{
		case 5..9:
		{
			setAchievement(id, LA_MEJOR_OPCION);
			setAchievementFirst(id, PRIMERO_LA_MEJOR_OPCION);
		}
		case 10..14:
		{
			setAchievement(id, UNA_DE_LAS_MEJORES);
			setAchievementFirst(id, PRIMERO_UNA_DE_LAS_MEJORES);
		}
		case 15..19:
		{
			setAchievement(id, MI_PREFERIDA);
			setAchievementFirst(id, PRIMERO_MI_PREFERIDA);
		}
		case 20:
		{
			setAchievement(id, LA_MEJOR);
			setAchievementFirst(id, PRIMERO_LA_MEJOR);
		}
	}

	static iWeapon5;
	iWeapon5 = getWeaponsTotal(id, 5);

	switch(iWeapon5)
	{
		case 5..9: setAchievement(id, LA_MEJOR_OPCION_x5);
		case 10..14: setAchievement(id, LA_MEJOR_OPCION_x10);
		case 15..19: setAchievement(id, LA_MEJOR_OPCION_x15);
		case 20: setAchievement(id, LA_MEJOR_OPCION_x20);
	}

	static iWeapon10;
	iWeapon10 = getWeaponsTotal(id, 10);

	switch(iWeapon10)
	{
		case 5..9: setAchievement(id, UNA_DE_LAS_MEJORES_x5);
		case 10..14:
		{
			setAchievement(id, UNA_DE_LAS_MEJORES_x10);
			giveHat(id, HAT_ZIPPY);
		}
		case 15..19: setAchievement(id, UNA_DE_LAS_MEJORES_x15);
		case 20: setAchievement(id, UNA_DE_LAS_MEJORES_x20);
	}

	static iWeapon15;
	iWeapon15 = getWeaponsTotal(id, 15);

	switch(iWeapon15)
	{
		case 5..9: setAchievement(id, MI_PREFERIDA_x5);
		case 10..14: setAchievement(id, MI_PREFERIDA_x10);
		case 15..19: setAchievement(id, MI_PREFERIDA_x15);
		case 20: setAchievement(id, MI_PREFERIDA_x20);
	}

	static iWeapon20;
	iWeapon20 = getWeaponsTotal(id, 20);

	switch(iWeapon20)
	{
		case 5..9: setAchievement(id, LA_MEJOR_x5);
		case 10..14: setAchievement(id, LA_MEJOR_x10);
		case 15..19: setAchievement(id, LA_MEJOR_x15);
		case 20: setAchievement(id, LA_MEJOR_x20);
	}
}

public getWeaponsTotal(const id, const level)
{
	static iWeapons;
	iWeapons = 0;

	for(new i = 1; i < 31; ++i)
	{
		if(WEAPON_NAMES[i][0] && g_WeaponData[id][i][WEAPON_DATA_LEVEL] >= level)
			++iWeapons;
	}

	return iWeapons;
}

public checkWeaponModels(const id, const weapon_id)
{
	static j;
	j = 0;

	while(j <= 0) // infinito hasta que llegue al break
	{
		for(new i = 0; i < 9; ++i)
		{
			if(g_WeaponData[id][weapon_id][WEAPON_DATA_LEVEL] >= WEAPON_MODELS[weapon_id][i][weaponModelLevel])
			{
				g_WeaponModel[id][weapon_id] = (i + 1);
				continue;
			}

			break;
		}

		break;
	}
}

public shotgunReload(const weapon_ent, const weapon_id, const max_clip, const clip, const bp_ammo, const id)
{
	if(g_WeaponSkills[id][weapon_id][WEAPON_SKILL_MAXCLIP])
	{
		if(bp_ammo <= 0 || clip == max_clip)
			return;

		if(get_pdata_int(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) > 0.0)
			return;

		switch(get_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS))
		{
			case 0:
			{
				setAnimation(id, 5);

				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
				set_pdata_float(id, OFFSET_NEXT_ATTACK, 0.55, OFFSET_LINUX);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 0.55, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);

				return;
			}
			case 1:
			{
				if(get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS) > 0.0)
					return;

				setAnimation(id, 3);

				emitSound(id, CHAN_ITEM, ((random_num(0, 1)) ? "weapons/reload1.wav" : "weapons/reload3.wav"), .pitch=(85 + random_num(0, 0x1f)));

				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 2, OFFSET_LINUX_WEAPONS);
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, ((weapon_id == CSW_XM1014) ? 0.3 : 0.45), OFFSET_LINUX_WEAPONS);
			}
			default:
			{
				set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (clip + 1), OFFSET_LINUX_WEAPONS);
				set_pdata_int(id, OFFSET_M3_AMMO, (bp_ammo - 1), OFFSET_LINUX);
				set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
			}
		}
	}
}

public setAnimation(const id, const animation)
{
	entity_set_int(id, EV_INT_weaponanim, animation);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
	write_byte(animation);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

public setUserAllModels(const id)
{
	static sCurrentModel[32];
	static iAlreadyHasModel;

	getUserModel(id, sCurrentModel, charsmax(sCurrentModel));
	iAlreadyHasModel = 0;

	switch(g_SpecialMode[id])
	{
		case MODE_SURVIVOR:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_SURVIVOR[g_Difficult[id][DIFFICULT_CLASS_SURVIVOR]]))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_SURVIVOR[g_Difficult[id][DIFFICULT_CLASS_SURVIVOR]]);
		}
		case MODE_WESKER:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_WESKER))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_WESKER);
		}
		case MODE_TRIBAL:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_TRIBAL))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_TRIBAL);
		}
		case MODE_SNIPER_ELITE, MODE_SNIPER:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_SNIPER))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_SNIPER);
		}
		case MODE_JASON:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_JASON))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_JASON);
		}
		case MODE_NEMESIS:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_NEMESIS[g_Difficult[id][DIFFICULT_CLASS_NEMESIS]]))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_NEMESIS[g_Difficult[id][DIFFICULT_CLASS_NEMESIS]]);
		}
		case MODE_ASSASSIN:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_ASSASSIN))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_ASSASSIN);
		}
		case MODE_ANNIHILATOR:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_ANNIHILATOR))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_ANNIHILATOR);
		}
		case MODE_FVSJ:
		{
			if(g_ModeFvsJ_Jason[id])
			{
				if(equal(sCurrentModel, PLAYER_MODEL_JASON))
					iAlreadyHasModel = 1;

				if(!iAlreadyHasModel)
					copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_JASON);
			}
			else
			{
				if(equal(sCurrentModel, PLAYER_MODEL_FREDDY))
					iAlreadyHasModel = 1;

				if(!iAlreadyHasModel)
					copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_FREDDY);
			}
		}
		case MODE_AVSP:
		{
			if(g_SpecialMode_Alien[id])
			{
				if(equal(sCurrentModel, PLAYER_MODEL_ALIEN))
					iAlreadyHasModel = 1;

				if(!iAlreadyHasModel)
					copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_ALIEN);
			}
			else if(g_SpecialMode_Predator[id])
			{
				if(equal(sCurrentModel, PLAYER_MODEL_PREDATOR))
					iAlreadyHasModel = 1;

				if(!iAlreadyHasModel)
					copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_PREDATOR);
			}
		}
		case MODE_GRUNT:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_GRUNT))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_GRUNT);
		}
		case MODE_L4D2:
		{
			if(equal(sCurrentModel, PLAYER_MODEL_L4D2[g_ModeL4D2_Human[id]]))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_L4D2[g_ModeL4D2_Human[id]]);
		}
		default:
		{
			if(g_Zombie[id])
			{
				if(g_AccountId[id] == 49)
				{
					if(equal(sCurrentModel, PLAYER_MODEL_L4D2_ZMS))
						iAlreadyHasModel = 1;

					if(!iAlreadyHasModel)
						copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_L4D2_ZMS);
				}
				else
				{
					if(equal(sCurrentModel, MODELS[g_ModelSelected[id][MODEL_ZOMBIE]][modelPrecache]))
						iAlreadyHasModel = 1;

					if(!iAlreadyHasModel)
						copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), MODELS[g_ModelSelected[id][MODEL_ZOMBIE]][modelPrecache]);
				}
			}
			else
			{
				if(g_Mode != MODE_GUNGAME && g_Mode != MODE_MEGA_GUNGAME && g_Mode != MODE_DUEL_FINAL && g_Mode != MODE_GRUNT)
				{
					if(g_AccountId[id] == 85)
					{
						if(equal(sCurrentModel, PLAYER_MODEL_L4D2_HMS))
							iAlreadyHasModel = 1;

						if(!iAlreadyHasModel)
							copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_L4D2_HMS);
					}
					else
					{
						if(equal(sCurrentModel, MODELS[g_ModelSelected[id][MODEL_HUMAN]][modelPrecache]))
							iAlreadyHasModel = 1;

						if(!iAlreadyHasModel)
							copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), MODELS[g_ModelSelected[id][MODEL_HUMAN]][modelPrecache]);
					}
				}
				else
				{
					if(equal(sCurrentModel, PLAYER_MODEL_HUMAN))
						iAlreadyHasModel = 1;

					if(!iAlreadyHasModel)
						copy(g_PlayerModel[id], charsmax(g_PlayerModel[]), PLAYER_MODEL_HUMAN);
				}
			}
		}
	}

	if(!iAlreadyHasModel)
	{
		if(g_NewRound)
			set_task((5.0 * MODELS_CHANGE_DELAY), "task__SetUserModelUpdate", id + TASK_MODEL);
		else
			task__SetUserModelUpdate(id + TASK_MODEL);
	}
}

public effectGrenade(const entity, const red, const green, const blue, const nade_type)
{
	set_rendering(entity, kRenderFxGlowShell, red, green, blue, kRenderNormal, 16);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(entity);
	write_short(g_Sprite_Trail);
	write_byte(10);
	write_byte(3);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(200);
	message_end();

	entity_set_int(entity, EV_NADE_TYPE, nade_type);

	if(nade_type == NADE_TYPE_FLARE || nade_type == NADE_TYPE_IMMUNITY || nade_type == NADE_TYPE_BUBBLE)
	{
		static Float:vecColor[3];

		vecColor[0] = float(red);
		vecColor[1] = float(green);
		vecColor[2] = float(blue);

		entity_set_vector(entity, EV_FLARE_COLOR, vecColor);
	}
	else
		entity_set_float(entity, EV_FL_dmgtime, (get_gametime() + 999.9));
}

public infectionExplode(const entity)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(entity, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(entity);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(entity, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 0, 255, 0, 500.0);

	emitSound(entity, CHAN_WEAPON, SOUND_NADE_INFECT_EXPLO);

	static iVictim;
	static iCountVictims;

	iVictim = -1;
	iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
	{
		if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_InBubble[iVictim])
			continue;

		if(getHumans() == 1)
		{
			ExecuteHamB(Ham_Killed, iVictim, iAttacker, 0);
			continue;
		}

		zombieMe(iVictim, iAttacker, .bomb=1, .finish_clan_combo=1);
		++iCountVictims;

		emitSound(iVictim, CHAN_VOICE, SOUND_NADE_INFECT_EXPLO_PLAYER[random_num(0, charsmax(SOUND_NADE_INFECT_EXPLO_PLAYER))]);
	}

	if(iCountVictims)
	{
		// . . .
	}
	else
		setAchievement(iAttacker, BOMBA_FALLIDA);

	remove_entity(entity);
}

public fireExplode(const entity)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(entity, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(entity);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(entity, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 255, 0, 0, 500.0);

	emitSound(entity, CHAN_WEAPON, SOUND_NADE_FIRE_EXPLO);

	static iVictim;
	static iCountVictims;

	iVictim = -1;
	iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
	{
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_Immunity[iVictim] || (g_Habs[iVictim][HAB_Z_RESISTANCE_FROST] >= 3 && g_Frozen[iVictim]))
			continue;

		burningUser(iVictim, iAttacker, 0, 10);
		++iCountVictims;
	}

	if(iCountVictims)
	{
		// . . . 
	}
	else
	{
		// . . . 
	}

	remove_entity(entity);
}

public burningUser(const victim, const attacker, const nitro, const duration)
{
	if(g_BurningDuration[victim] <= 0)
	{
		if(g_SpecialMode[victim])
			g_BurningDuration[victim] += ((duration + 1) / 2);
		else
			g_BurningDuration[victim] += ((duration + 1) * 2);

		g_BurningDurationOwner[victim] = attacker;

		static iArgs[2];

		iArgs[0] = attacker;
		iArgs[1] = nitro;

		if(!task_exists(victim + TASK_BURNING_FLAME))
			set_task(0.2, "task__BurningFlame", victim + TASK_BURNING_FLAME, iArgs, sizeof(iArgs), "b");
	}
}

public novaExplode(const entity, const nova)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(entity, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(entity);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(entity, EV_VEC_origin, vecOrigin);

	switch(nova)
	{
		case 3: effectGrenadeExplode(vecOrigin, 150, 25, 150, 500.0);
		case 2:
		{
			effectGrenadeExplode(vecOrigin, 25, 150, 150, 500.0);

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
		}
		default: effectGrenadeExplode(vecOrigin, 0, 0, 150, 500.0);
	}

	emitSound(entity, CHAN_WEAPON, SOUND_NADE_NOVA_EXPLO);

	static iVictim;
	iVictim = -1;

	if(!g_MiniGameBomba_On)
	{
		static iCountVictims;
		iCountVictims = 0;
		
		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
		{
			if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_Frozen[iVictim] || g_Painshock[iVictim])
				continue;

			freezeUser(iVictim, nova, 4.0);
			++iCountVictims;
		}

		if(iCountVictims)
		{
			// . . .
		}
		else
		{
			// . . .
		}

		iVictim = -1;
		iCountVictims = 0;

		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, (NADE_EXPLODE_RADIUS + 25.0))) != 0)
		{
			if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_Frozen[iVictim] || g_Painshock[iVictim])
				continue;

			slowDownUser(iVictim, nova, 6.0);
			++iCountVictims;
		}

		if(iCountVictims)
		{
			// . . .
		}
		else
		{
			// . . .
		}
	}
	else
	{
		static Float:flRadius;
		flRadius = (NADE_EXPLODE_RADIUS - (float(g_MiniGameBomba_Drop) * 20.0));

		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, flRadius)) != 0)
		{
			if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_Frozen[iVictim] || g_Painshock[iVictim])
				continue;

			freezeUser(iVictim, nova, 4.0);

			if((g_Level[iVictim] + g_MiniGameBomba_Level) >= MAX_LEVEL)
			{
				g_Level[iVictim] = MAX_LEVEL;
				continue;
			}

			g_Exp[iVictim] = 0;
			g_Level[iVictim] += g_MiniGameBomba_Level;

			dg_color_chat(iVictim, _, "Ganaste !g%d nivel%s!y", g_MiniGameBomba_Level, (g_MiniGameBomba_Level != 1) ? "es" : "");
			checkExpEquation(iVictim);
		}

		new i;
		for(i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;
			
			if(g_Frozen[i])
				continue;
			
			if(i == iAttacker)
				continue;
			
			ExecuteHamB(Ham_Killed, i, iAttacker, 1);
		}
		
		++g_MiniGameBomba_Drop;
		
		if(g_MiniGameBomba_Drop == 5)
			g_MiniGameBomba_Level *= 2;

		if(getAlives() > 1)
		{
			dg_color_chat(0, _, "La próxima bomba otorgará !g%d nivel%s!y a quienes permanezcan vivos!", g_MiniGameBomba_Level, (g_MiniGameBomba_Level == 1) ? "" : "es");
			dg_color_chat(0, _, "Radio de la próxima bomba: !g%0.2f!y", flRadius);
		}
		else
			g_MiniGameBomba_On = 0;
	}

	remove_entity(entity);
}

public freezeUser(const victim, const nova, const Float:duration)
{
	if(g_Frozen[victim])
		return;

	static vecColor[3];

	switch(nova)
	{
		case 3:
		{
			vecColor = {150, 25, 150};

			static iPercent;
			static iTotal;

			iPercent = ((30 * g_Health[victim]) / 100);
			iTotal = (g_Health[victim] - iPercent);

			if(iTotal > 0)
				set_user_health(victim, iTotal);
			else
				set_user_health(victim, 1);

			g_Health[victim] = get_user_health(victim);
		}
		case 2: vecColor = {25, 150, 150};
		default: vecColor = {0, 0, 150};
	}

	set_user_rendering(victim, kRenderFxGlowShell, vecColor[0], vecColor[1], vecColor[2], kRenderNormal, 125);

	if(!g_DrugBombMove[victim])
	{
		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, victim);
		write_short(0);
		write_short(0);
		write_short(FFADE_STAYOUT);
		write_byte(vecColor[0]);
		write_byte(vecColor[1]);
		write_byte(vecColor[2]);
		write_byte(100);
		message_end();
	}

	g_Frozen[victim] = nova;
	g_FrozenGravity[victim] = get_user_gravity(victim);

	ExecuteHamB(Ham_Player_ResetMaxSpeed, victim);

	if(get_entity_flags(victim) & FL_ONGROUND)
		set_user_gravity(victim, 999999.9);
	else
		set_user_gravity(victim, 0.000001);

	remove_task(victim + TASK_FREEZE);
	remove_task(victim + TASK_SLOWDOWN);

	static iVictimFrozen;
	iVictimFrozen = g_Habs[victim][HAB_Z_RESISTANCE_FROST];

	set_task(((iVictimFrozen >= 2) ? 2.0 : 4.0), "task__RemoveFreeze", victim + TASK_FREEZE);
	set_task(((iVictimFrozen >= 1) ? 7.0 : 9.0), "task__RemoveSlowDown", victim + TASK_SLOWDOWN);

	emitSound(victim, CHAN_BODY, SOUND_NADE_NOVA_PLAYER);

	if(g_Habs[victim][HAB_Z_RESISTANCE_FROST] >= 3)
		g_BurningDuration[victim] = 0;
}

public slowDownUser(const victim, const nova, const Float:duration)
{
	if(g_SlowDown[victim])
		return;

	g_SlowDown[victim] = nova;

	ExecuteHamB(Ham_Player_ResetMaxSpeed, victim);

	remove_task(victim + TASK_SLOWDOWN);

	static iVictimFrozen;
	iVictimFrozen = g_Habs[victim][HAB_Z_RESISTANCE_FROST];

	set_task(((iVictimFrozen >= 1) ? 4.0 : 6.0), "task__RemoveSlowDown", victim + TASK_SLOWDOWN);

	emitSound(victim, CHAN_BODY, SOUND_NADE_NOVA_SLOWDOWN);
}

public flareLighting(const entity, const duration, const bubble)
{
	static Float:vecOrigin[3];
	static Float:vecColor[3];

	entity_get_vector(entity, EV_VEC_origin, vecOrigin);
	entity_get_vector(entity, EV_FLARE_COLOR, vecColor);

	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_byte(25);
	write_byte(floatround(vecColor[0]));
	write_byte(floatround(vecColor[1]));
	write_byte(floatround(vecColor[2]));
	write_byte(21);
	write_byte((duration < 3) ? 10 : 0);
	message_end();
}

public nitroExplode(const entity)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(entity, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(entity);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(entity, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 0, 255, 255, 500.0);

	emitSound(entity, CHAN_WEAPON, SOUND_NADE_FIRE_EXPLO);

	static iVictim;
	static iCountVictims;

	iVictim = -1;
	iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
	{
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_Immunity[iVictim]  || (g_Habs[iVictim][HAB_Z_RESISTANCE_FROST] >= 3 && g_Frozen[iVictim]))
			continue;

		burningUser(iVictim, iAttacker, 1, 10);
		++iCountVictims;
	}

	if(iCountVictims)
	{
		// . . . 
	}
	else
	{
		// . . . 
	}

	remove_entity(entity);
}

public immunityExplode(const ent)
{
	if(g_EndRound)
		return;

	if(entity_get_int(ent, EV_INT_flags) & FL_INWATER)
	{
		remove_entity(ent);
		return;
	}

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(ent);
		return;
	}

	static Float:vecOrigin[3];
	static iAll;

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	if(g_Level[iAttacker] >= 750 || g_Reset[iAttacker])
		iAll = 1;

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_byte(25);
	write_byte(107);
	write_byte(66);
	write_byte(38);
	write_byte(10);
	write_byte(45);
	message_end();

	emitSound(ent, CHAN_WEAPON, SOUND_NADE_NOVA_EXPLO);

	static iVictim;
	static iCountVictims;

	iVictim = -1;
	iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
	{
		if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_Immunity[iVictim])
			continue;

		if(!iAll)
		{
			if(iAttacker != iVictim)
				continue;
			
			if(iCountVictims)
				break;
		}
		else
		{
			if(iCountVictims == 1 && iAttacker != iVictim)
				continue;
			
			if(iCountVictims == 2)
				break;
		}

		client_print(iVictim, print_center, "¡Tienes inmunidad!");

		++iCountVictims;

		g_Immunity[iVictim] = 1;

		set_user_rendering(iVictim, kRenderFxGlowShell, 107, 66, 38, kRenderNormal, 125);
		
		remove_task(iVictim + TASK_IMMUNITY_BOMB);
		set_task(10.0, "task__RemoveImmunityBomb", iVictim + TASK_IMMUNITY_BOMB);
	}

	remove_entity(ent);
}

public drugExplode(const ent)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(ent);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 153, 204, 50, 555.0);

	static iVictim;
	iVictim = -1;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
	{
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || (g_Habs[iVictim][HAB_Z_RESISTANCE_FROST] >= 2 && g_Frozen[iVictim]) || g_DrugBombMove[iVictim])
			continue;

		g_DrugBombCount[iVictim] = 0;
		hamStripWeapons(iVictim, "weapon_knife");

		remove_task(iVictim + TASK_DRUG);
		set_task(0.5, "task__DrugEffect", iVictim + TASK_DRUG, _, _, "a", 20);
	}

	remove_entity(ent);
}

public bubbleExplode(const entity)
{
	static Float:vecEntityOrigin[3];
	static iVictim;
	static j;
	static iUsers[MAX_USERS];
	static Float:vecOrigin[3];
	static Float:fScalar;
	static Float:fInvSqrt;
	
	entity_get_vector(entity, EV_VEC_origin, vecEntityOrigin);
	iVictim = -1;
	j = 0;
	
	while((iVictim = find_ent_in_sphere(iVictim, vecEntityOrigin, 120.0)) != 0)
	{
		if(isUserValidAlive(iVictim))
			iUsers[j++] = iVictim;
	}

	for(new i = 0; i < j; ++i)
	{
		if(!g_Zombie[iUsers[i]])
		{
			entity_get_vector(iUsers[i], EV_VEC_origin, vecOrigin);
			
			if(get_distance_f(vecEntityOrigin, vecOrigin) <= 100)
				g_InBubble[iUsers[i]] = 1;
			else
				g_InBubble[iUsers[i]] = 0;
		}
		else if((g_Mode == MODE_ARMAGEDDON || g_Mode == MODE_MEGA_ARMAGEDDON && g_SpecialMode[iUsers[i]] == MODE_NEMESIS) || (g_Zombie[iUsers[i]] && !g_SpecialMode[iUsers[i]] && !g_Immunity[iUsers[i]]))
		{
			entity_get_vector(iUsers[i], EV_VEC_origin, vecOrigin);

			if(get_distance_f(vecEntityOrigin, vecOrigin) > 100)
				fScalar = 255.0;
			else
				fScalar = 2000.0;

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

public killExplode(const ent)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(ent);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 255, 255, 0, 500.0);

	emitSound(ent, CHAN_WEAPON, SOUND_ROUND_SURVIVOR[0]);

	static iVictim;
	static iCountVictims;

	iVictim = -1;
	iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
	{
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim])
			continue;

		ExecuteHamB(Ham_Killed, iVictim, iAttacker, 2);
		++iCountVictims;
	}

	if(iCountVictims)
	{
		// . . . 
	}
	else
	{
		// . . . 
	}

	remove_entity(ent);
}

public molotovExplode(const ent)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(ent);
		return;
	}

	emitSound(ent, CHAN_WEAPON, SOUND_NADE_MOLOTOV_EXPLO);

	static Float:vecEntOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecEntOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
	engfunc(EngFunc_WriteCoord, (vecEntOrigin[2] + 125.0));
	write_short(g_Sprite_ShockWave);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte(100);
	write_byte(100);
	write_byte(100);
	write_byte(200);
	write_byte(0);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
	write_byte(25);
	write_byte(100);
	write_byte(100);
	write_byte(100);
	write_byte(2);
	write_byte(0);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
	write_short(g_Sprite_Molotov);
	write_byte(25);
	write_byte(233);
	message_end();

	static vecOriginInt[3];
	static iArgs[3];

	vecOriginInt[0] = floatround(vecEntOrigin[0]);
	vecOriginInt[1] = floatround(vecEntOrigin[1]);
	vecOriginInt[2] = floatround(vecEntOrigin[2]);

	iArgs[0] = vecOriginInt[0];
	iArgs[1] = vecOriginInt[1];
	iArgs[2] = vecOriginInt[2];

	remove_task(ent + TASK_MOLOTOV_EFFECT);
	remove_task(iAttacker + TASK_MOLOTOV_EFFECT);

	set_task(0.2, "task__MolotovDamage", iAttacker + TASK_MOLOTOV_EFFECT, iArgs, sizeof(iArgs), "a", 50);

	remove_entity(ent);
}

public antidoteExplode(const ent)
{
	if(g_EndRound)
		return;

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker))
	{
		remove_entity(ent);
		return;
	}
	
	static Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	effectGrenadeExplode(vecOrigin, 255, 255, 255, 500.0);

	emitSound(ent, CHAN_WEAPON, SOUND_HUMAN_ANTIDOTE);

	static iVictim;
	static iCountVictims;

	iVictim = -1;
	iCountVictims = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLODE_RADIUS)) != 0)
	{
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_LastZombie[iVictim])
			continue;

		humanMe(iVictim);
		++iCountVictims;
	}

	if(iCountVictims)
	{
		if(iCountVictims >= 12)
		{
			setAchievement(iAttacker, YO_USO_CLEAR_ZOMBIE);

			if(iCountVictims >= 18)
				setAchievement(iAttacker, ANTIDOTO_PARA_TODOS);
		}
	}
	else
		setAchievement(iAttacker, Y_LA_LIMPIEZA);

	remove_entity(ent);
}

public effectGrenadeExplode(const Float:vecOrigin[3], const red, const green, const blue, const Float:radius)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + radius);
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

public fixModels(const id)
{
	static j[structIdModelClasses];
	j = {0, 0};

	for(new i = 0; i < sizeof(MODELS); ++i)
	{
		if(g_Models[id][i])
		{
			if(MODELS[i][modelClass] == MODEL_HUMAN)
				++j[MODEL_HUMAN];

			if(MODELS[i][modelClass] == MODEL_ZOMBIE)
				++j[MODEL_ZOMBIE];
		}
	}

	if(j[MODEL_HUMAN] == 0)
	{
		for(new k = 0; k < sizeof(MODELS); ++k)
		{
			if(MODELS[k][modelClass] == MODEL_HUMAN && MODELS[k][modelCycle] == 0)
			{
				g_Models[id][k] = 1;
				g_ModelSelected[id][MODEL_HUMAN] = k;

				break;
			}
		}
	}

	if(j[MODEL_ZOMBIE] == 0)
	{
		for(new k = 0; k < sizeof(MODELS); ++k)
		{
			if(MODELS[k][modelClass] == MODEL_ZOMBIE && MODELS[k][modelCycle] == 0)
			{
				g_Models[id][k] = 1;
				g_ModelSelected[id][MODEL_ZOMBIE] = k;

				break;
			}
		}
	}
}

public getUserModelInReset(const id, const class)
{
	static j;
	j = -1;

	for(new i = 0; i < sizeof(MODELS); ++i)
	{
		if(class == MODELS[i][modelClass] && g_Models[id][i])
			++j;
	}

	if(j == g_Reset[id])
		return 0;

	return 1;
}

public getUserModelInCycle(const id, const model)
{
	if(g_Reset[id] >= 19 && g_Reset[id] <= 25 && MODELS[model][modelCycle] == 3) // A
		return 1;

	if(g_Reset[id] >= 13 && g_Reset[id] <= 18 && MODELS[model][modelCycle] == 2) // B
		return 1;

	if(g_Reset[id] >= 6 && g_Reset[id] <= 12 && MODELS[model][modelCycle] == 1) // C
		return 1;

	if(g_Reset[id] >= 0 && g_Reset[id] <= 5 && MODELS[model][modelCycle] == 0) // D
		return 1;

	return 0;
}

public getUserExtraItemCost(const id, const extra_item)
{
	static iCost;
	static iDiscount;

	iCost = g_ExtraItem_Cost[id][extra_item];
	iDiscount = (__CLASSES[g_Class[id]][classReduceExtraItems] + HATS[g_HatId[id]][hatUpgrade8] + ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acReduceExtraItems] : 0));

	if(iDiscount)
		iCost -= ((iDiscount * iCost) / 100);

	return iCost;
}

buyExtraItem(const id, const extra_item, const ignore_cost=0)
{
	static iCost;
	iCost = getUserExtraItemCost(id, extra_item);

	if(!ignore_cost)
	{
		if(g_Zombie[id] != EXTRA_ITEMS[extra_item][extraItemTeam])
		{
			showMenu__ExtraItems(id);
			return;
		}

		if(EXTRA_ITEMS[extra_item][extraItemLimitMap] && g_ExtraItem_LimitMap[extra_item] >= EXTRA_ITEMS[extra_item][extraItemLimitMap])
		{
			dg_color_chat(id, _, "Has superado el límite de compra por mapa. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

			showMenu__ExtraItems(id);
			return;
		}

		if((g_AmmoPacks[id] - iCost) < 0)
		{
			dg_color_chat(id, _, "No tienes suficientes APs");

			showMenu__ExtraItems(id);
			return;
		}
	}

	static iValue;
	static iSysTime;

	iValue = 0;
	iSysTime = get_systime();

	switch(extra_item)
	{
		case EXTRA_ITEM_NIGHTVISION:
		{
			if(!ignore_cost)
			{
				if(g_NightVision[id])
				{
					dg_color_chat(id, _, "Ya compraste Visión nocturna");

					showMenu__ExtraItems(id);
					return;
				}
			}

			setUserNightVision(id, 1);
		}
		case EXTRA_ITEM_INVISIBILITY:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_Invisibility, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(entity_get_int(id, EV_FL_renderamt) == 25.0)
				{
					dg_color_chat(id, _, "Ya compraste Invisibilidad");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Invisibilidad");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_Invisibility, g_PlayerName[id], (iValue + 1));
			}

			entity_set_int(id, EV_INT_rendermode, kRenderTransAlpha);
			entity_set_float(id, EV_FL_renderamt, 25.0);

			if(g_AccountId[id] == 85 && g_Invisibility_Vrg[id])
			{
				dg_color_chat(id, _, "Recibiste invibilidad gratis. Te restan !g%d invisiblidad%s!y", g_Invisibility_Vrg[id], ((g_Invisibility_Vrg[id] != 1) ? "es" : ""));
				--g_Invisibility_Vrg[id];
			}

			if(g_HatId[id])
			{
				if(is_valid_ent(g_HatEnt[id]))
				{
					entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
					entity_set_float(g_HatEnt[id], EV_FL_renderamt, 25.0);
				}
			}
		}
		case EXTRA_ITEM_UNLIMITED_CLIP:
		{
			if(!ignore_cost)
			{
				if(g_UnlimitedClip[id])
				{
					dg_color_chat(id, _, "Ya compraste Balas Infinitas");

					showMenu__ExtraItems(id);
					return;
				}
			}

			g_UnlimitedClip[id] = 1;
		}
		case EXTRA_ITEM_PP:
		{
			if(!ignore_cost)
			{
				if(g_PrecisionPerfect[id])
				{
					dg_color_chat(id, _, "Ya compraste Precisión Perfecta");

					showMenu__ExtraItems(id);
					return;
				}
			}

			g_PrecisionPerfect[id] = 1;
		}
		case EXTRA_ITEM_KILL_BOMB:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_KillBomb, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Bomba de Aniquilación");

					showMenu__ExtraItems(id);
					return;
				}
				else if(!g_LastHuman[id])
				{
					dg_color_chat(id, _, "Debes ser último humano para comprar Bomba de Aniquilación");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_KillBomb, g_PlayerName[id], (iValue + 1));
			}

			++g_KillBomb[id];

			if(user_has_weapon(id, CSW_HEGRENADE))
				cs_set_user_bpammo(id, CSW_HEGRENADE, (cs_get_user_bpammo(id, CSW_HEGRENADE) + 1));
			else
				give_item(id, "weapon_hegrenade");
		}
		case EXTRA_ITEM_MOLOTOV_BOMB:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_MolotovBomb, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Bomba Molotov");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_MolotovBomb, g_PlayerName[id], (iValue + 1));
			}

			++g_MolotovBomb[id];

			if(user_has_weapon(id, CSW_FLASHBANG))
				cs_set_user_bpammo(id, CSW_FLASHBANG, (cs_get_user_bpammo(id, CSW_FLASHBANG) + 1));
			else
				give_item(id, "weapon_flashbang");
		}
		case EXTRA_ITEM_ANTIDOTE_BOMB:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_AntidoteBomb, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Bomba Antídoto");

					showMenu__ExtraItems(id);
					return;
				}
				else if(!g_LastHuman[id])
				{
					dg_color_chat(id, _, "Debes ser último humano para comprar Bomba Antídoto");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_AntidoteBomb, g_PlayerName[id], (iValue + 1));
			}

			++g_AntidoteBomb[id];

			if(user_has_weapon(id, CSW_SMOKEGRENADE))
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, (cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1));
			else
				give_item(id, "weapon_smokegrenade");
		}
		case EXTRA_ITEM_ANTIDOTE:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_Antidote, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para comprar Antídoto");

					showMenu__ExtraItems(id);
					return;
				}
				else if(getZombies() <= 4)
				{
					dg_color_chat(id, _, "Deben haber más de !g4 zombies!y para comprar Antídoto");

					showMenu__ExtraItems(id);
					return;
				}
				else if(getPlaying() <= 8 && getZombies())
				{
					dg_color_chat(id, _, "Deben haber más de !g8 jugadores conectados!y para comprar Antídoto");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_ModeInfection_Systime > get_systime())
				{
					new iRest = (g_ModeInfection_Systime - get_systime());

					dg_color_chat(id, _, "Debe' ezperah !g%s!y pa tira anti perri", getCooldDownTime(iRest));

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_Antidote, g_PlayerName[id], (iValue + 1));
			}

			humanMe(id);
		}
		case EXTRA_ITEM_ZOMBIE_MADNESS:
		{
			if(!ignore_cost)
			{
				if(g_Frozen[id])
				{
					dg_color_chat(id, _, "No puedes comprar Furia Zombie mientras estés congelado");

					showMenu__ExtraItems(id);
					return;
				}

				TrieGetCell(g_tExtraItem_ZombieMadness, g_PlayerName[id], iValue);
				
				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Immunity[id])
				{
					dg_color_chat(id, _, "Ya compraste Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Madness_LastUse[id] > iSysTime)
				{
					new iRest;
					iRest = (g_Madness_LastUse[id] - iSysTime);

					dg_color_chat(id, _, "Debes esperar !g%s!y para volver a comprar Furia Zombie", getCooldDownTime(iRest));

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Painshock_LastUse[id] > iSysTime)
				{
					new iRest;
					iRest = (g_Painshock_LastUse[id] - iSysTime);

					dg_color_chat(id, _, "Debes esperar !g%s!y después de comprar Painshock para utilizar Furia Zombie", getCooldDownTime(iRest));

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_ZombieMadness, g_PlayerName[id], (iValue + 1));

				++g_Achievement_FuryConsecutive[id];

				if(g_Achievement_FuryConsecutive[id] == 3)
					g_Achievement_FuryConsecutive[id] = 1;

				++g_AchievementSecret_FuryInRound[id];

				if(g_AchievementSecret_FuryInRound[id] >= 3 && g_Achievement_InfectsRound[id] >= 5)
					setAchievement(id, RAPIDO_Y_FURIOSO);
			}

			new Float:flDuration;
			flDuration = 4.0;

			if(g_Habs[id][HAB_S_MADNESS])
				flDuration += ((float(HABS[HAB_S_MADNESS][habValue]) / 2.0) * float(g_Habs[id][HAB_S_MADNESS]));

			if(g_ClanSlot[id] && g_ClanPerks[g_ClanSlot[id]][CP_EXTENDED_FURY])
				flDuration += 2.0;

			startZombieMadness(id, flDuration, 0, random_num(0, 1));
		}
		case EXTRA_ITEM_INFECTION_BOMB:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_InfectionBomb, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_InfectionBomb, g_PlayerName[id], (iValue + 1));
			}

			if(user_has_weapon(id, CSW_HEGRENADE))
				cs_set_user_bpammo(id, CSW_HEGRENADE, (cs_get_user_bpammo(id, CSW_HEGRENADE) + 1));
			else
				give_item(id, "weapon_hegrenade");
		}
		case EXTRA_ITEM_REDUCE_DAMAGE:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_ReduceDamage, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_ReduceDamage[id])
				{
					dg_color_chat(id, _, "Ya compraste Reducción de Daño");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_ReduceDamage, g_PlayerName[id], (iValue + 1));
			}

			g_ReduceDamage[id] = 1;

			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 125);
		}
		case EXTRA_ITEM_PAINSHOCK:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_PainShock, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Painshock[id])
				{
					dg_color_chat(id, _, "Ya compraste Painshock");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Painshock_LastUse[id] > iSysTime)
				{
					new iRest;
					iRest = (g_Painshock_LastUse[id] - iSysTime);

					dg_color_chat(id, _, "Debes esperar !g%s!y para volver a comprar Painshock", getCooldDownTime(iRest));

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Madness_LastUse[id] > iSysTime)
				{
					new iRest;
					iRest = (g_Madness_LastUse[id] - iSysTime);

					dg_color_chat(id, _, "Debes esperar !g%s!y después de comprar Furia Zombie para utilizar Painshock", getCooldDownTime(iRest));

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_PainShock, g_PlayerName[id], (iValue + 1));
			}

			g_Painshock[id] = 1;
			g_Painshock_LastUse[id] = (iSysTime + TIME_PAINSHOCK_TO_DELAY);

			if(g_AccountId[id] == 49 && g_Painshock_Chite[id])
			{
				dg_color_chat(id, _, "Recibiste painshock gratis. Te restan !g%d painshock%s!y", g_Painshock_Chite[id], ((g_Painshock_Chite[id] != 1) ? "s" : ""));
				--g_Painshock_Chite[id];
			}

			set_user_rendering(id, kRenderFxGlowShell, 255, 165, 0, kRenderNormal, 125);

			remove_task(id + TASK_PAINSHOCK);
			set_task(5.0, "task__RemovePainshock", id + TASK_PAINSHOCK);
		}
		case EXTRA_ITEM_PETRIFICATION:
		{
			if(!ignore_cost)
			{
				TrieGetCell(g_tExtraItem_Petrification, g_PlayerName[id], iValue);

				if(iValue < 0)
					iValue = 0;

				if(iValue == EXTRA_ITEMS[extra_item][extraItemLimitUser])
				{
					dg_color_chat(id, _, "Has superado el límite de compra por usuario. Debes esperar al próximo mapa para volver a comprar !g%s!y", EXTRA_ITEMS[extra_item][extraItemName]);

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Petrification[id])
				{
					dg_color_chat(id, _, "Estás en modo petrificado, espera a que termine de tomar efecto");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Petrification_Round[id])
				{
					dg_color_chat(id, _, "Sólo puedes usar una petrificación por ronda");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Mode != MODE_INFECTION)
				{
					dg_color_chat(id, _, "Debe ser modo !tINFECCIÓN!y para Furia Zombie");

					showMenu__ExtraItems(id);
					return;
				}
				else if(g_Frozen[id])
				{
					dg_color_chat(id, _, "No puedes comprar Petrificación estando congelado");

					showMenu__ExtraItems(id);
					return;
				}

				TrieSetCell(g_tExtraItem_Petrification, g_PlayerName[id], (iValue + 1));
			}

			g_Immunity[id] = 1;
			g_Frozen[id] = 1;
			g_BurningDuration[id] = 0;
			g_DrugBombCount[id] = 0;
			g_DrugBombMove[id] = 0;
			g_Petrification[id] = 1;
			g_Petrification_Round[id] = 1;

			ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

			give_item(id, "weapon_knife");

			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 125);

			remove_task(id + TASK_BURNING_FLAME);
			remove_task(id + TASK_REGENERATION);
			remove_task(id + TASK_IMMUNITY_P);
			remove_task(id + TASK_DRUG);

			set_task(0.5, "task__HealthRegeneration", id + TASK_REGENERATION, .flags="a", .repeat=10);
			set_task(5.0, "task__RemoveHealthImmunity", id + TASK_IMMUNITY_P);
		}
	}

	if(!ignore_cost)
	{
		if((g_AccountId[id] != 49 || !g_Invisibility_Vrg[id]) && (g_AccountId[id] != 85 || !g_Painshock_Chite[id]))
			addAPs(id, (iCost * -1));

		g_ExtraItem_Cost[id][extra_item] += ((iCost * EXTRA_ITEMS_COST_PERCENT) / 100);
		++g_ExtraItem_Count[id][extra_item];
		++g_ExtraItem_LimitMap[extra_item];
		g_AchievementSecret_AllItems[id][extra_item] = 1;

		switch(extra_item)
		{
			case EXTRA_ITEM_NIGHTVISION:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, VISION_NOCTURNA_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, VISION_NOCTURNA_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, VISION_NOCTURNA_x100);
					}
				}
			}
			case EXTRA_ITEM_INVISIBILITY:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, INVISIBILIDAD_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, INVISIBILIDAD_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, INVISIBILIDAD_x100);
					}
				}
			}
			case EXTRA_ITEM_UNLIMITED_CLIP:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, BALAS_INFINITAS_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, BALAS_INFINITAS_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, BALAS_INFINITAS_x100);
					}
				}
			}
			case EXTRA_ITEM_PP:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, PRESICION_PERFECTA_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, PRESICION_PERFECTA_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, PRESICION_PERFECTA_x100);
					}
				}
			}
			case EXTRA_ITEM_KILL_BOMB:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, BOMBA_DE_ANIQUILACION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, BOMBA_DE_ANIQUILACION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, BOMBA_DE_ANIQUILACION_x100);
					}
				}
			}
			case EXTRA_ITEM_MOLOTOV_BOMB:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, BOMBA_MOLOTOV_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, BOMBA_MOLOTOV_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, BOMBA_MOLOTOV_x100);
					}
				}
			}
			case EXTRA_ITEM_ANTIDOTE_BOMB:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, BOMBA_ANTIDOTO_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, BOMBA_ANTIDOTO_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, BOMBA_ANTIDOTO_x100);
					}
				}
			}
			case EXTRA_ITEM_ANTIDOTE:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, ANTIDOTO_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, ANTIDOTO_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, ANTIDOTO_x100);
					}
				}
			}
			case EXTRA_ITEM_ZOMBIE_MADNESS:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, FURIA_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, FURIA_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, FURIA_x100);
					}
				}
			}
			case EXTRA_ITEM_INFECTION_BOMB:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, BOMBA_DE_INFECCION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, BOMBA_DE_INFECCION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, BOMBA_DE_INFECCION_x100);
					}
				}
			}
			case EXTRA_ITEM_REDUCE_DAMAGE:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, REDUCCION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, REDUCCION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, REDUCCION_x100);
					}
				}
			}
			case EXTRA_ITEM_PAINSHOCK:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, PAINSHOCK_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, PAINSHOCK_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, PAINSHOCK_x100);
					}
				}
			}
			case EXTRA_ITEM_PETRIFICATION:
			{
				if(g_ExtraItem_Count[id][extra_item] >= 10)
				{
					setAchievement(id, PETRIFICACION_x10);

					if(g_ExtraItem_Count[id][extra_item] >= 50)
					{
						setAchievement(id, PETRIFICACION_x50);

						if(g_ExtraItem_Count[id][extra_item] >= 100)
							setAchievement(id, PETRIFICACION_x100);
					}
				}
			}
		}

		static iMenor;
		iMenor = g_ExtraItem_Count[id][0];

		for(new i = 1; i < structIdExtraItems; ++i)
		{
			if(g_ExtraItem_Count[id][i] < iMenor)
				iMenor = g_ExtraItem_Count[id][i];
		}

		switch(iMenor)
		{
			case 10: setAchievement(id, ITEMS_EXTRAS_x10);
			case 50: setAchievement(id, ITEMS_EXTRAS_x50);
			case 100: setAchievement(id, ITEMS_EXTRAS_x100);
			case 500: setAchievement(id, ITEMS_EXTRAS_x500);
			case 1000: setAchievement(id, ITEMS_EXTRAS_x1000);
			case 5000: setAchievement(id, ITEMS_EXTRAS_x5000);
		}

		static iCount;
		iCount = 0;

		for(new i = 0; i < structIdExtraItems; ++i)
		{
			if(g_AchievementSecret_AllItems[id][i])
				++iCount;
		}

		if(iCount == (structIdExtraItems - 1))
			setAchievement(id, MAXIMO_COMPRADOR);

		g_Hat_Devil[id] = 1;
	}
}

public checkAchievementTotal(const id, const class)
{
	static iCount;
	static i;

	iCount = 0;

	for(i = 0; i < structIdAchievements; ++i)
	{
		if(class == ACHIEVEMENTS[i][achievementClass] && g_Achievement[id][i])
			++iCount;
	}

	return iCount;
}

setAchievement(const id, const achievement, achievement_fake=0)
{
	if(g_Achievement[id][achievement])
		return;

	if(!achievement_fake)
	{
		if(ACHIEVEMENTS[achievement][achievementUsersNeedP] && getPlaying() < ACHIEVEMENTS[achievement][achievementUsersNeedP])
			return;
		else if(ACHIEVEMENTS[achievement][achievementUsersNeedA] && getAlives() < ACHIEVEMENTS[achievement][achievementUsersNeedA])
			return;
	}

	g_Achievement[id][achievement] = 1;
	g_AchievementUnlocked[id][achievement] = get_systime();
	++g_AchievementTotal[id];

	g_LastAchUnlocked = achievement;
	g_LastAchUnlockedPage = ACHIEVEMENTS[achievement][achievementClass];
	g_LastAchUnlockedClass = ACHIEVEMENTS[achievement][achievementClass];

	if(ACHIEVEMENTS[achievement][achievementClass] != ACHIEVEMENT_CLASS_SECRETS)
		dg_color_chat(0, _, "!t%s!y ganó el logro !g%s !t(%d pE)!y [Z]", g_PlayerName[id], ACHIEVEMENTS[achievement][achievementName], ACHIEVEMENTS[achievement][achievementReward]);
	else
		dg_color_chat(0, _, "!t%s!y ganó el logro !g%s!y (LOGRO SECRETO)", g_PlayerName[id], ACHIEVEMENTS[achievement][achievementName]);
	
	static Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_achievements (acc_id, achievement_id, achievement_timestamp) VALUES ('%d', '%d', UNIX_TIMESTAMP());", g_AccountId[id], achievement);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 51);
	else
		SQL_FreeHandle(sqlQuery);

	g_Points[id][POINT_SPECIAL] += ACHIEVEMENTS[achievement][achievementReward];

	rewardAchievement(id);
}

setAchievementFirst(const id, const achievement, achievement_fake=0)
{
	if(g_Achievement[0][achievement])
		return;

	if(!achievement_fake)
	{
		if(ACHIEVEMENTS[achievement][achievementUsersNeedP] && getPlaying() < ACHIEVEMENTS[achievement][achievementUsersNeedP])
			return;
		else if(ACHIEVEMENTS[achievement][achievementUsersNeedA] && getAlives() < ACHIEVEMENTS[achievement][achievementUsersNeedA])
			return;
	}

	g_Achievement[0][achievement] = 1;
	g_Achievement[id][achievement] = 1;
	g_AchievementUnlocked[0][achievement] = get_systime();
	g_AchievementUnlocked[id][achievement] = get_systime();
	++g_AchievementTotal[id];

	g_LastAchUnlocked = achievement;
	g_LastAchUnlockedPage = ACHIEVEMENTS[achievement][achievementClass];
	g_LastAchUnlockedClass = ACHIEVEMENTS[achievement][achievementClass];

	if(ACHIEVEMENTS[achievement][achievementClass] != ACHIEVEMENT_CLASS_SECRETS)
		dg_color_chat(0, _, "!t%s!y ganó el logro !g%s !t(%d pE)!y [Z]", g_PlayerName[id], ACHIEVEMENTS[achievement][achievementName], ACHIEVEMENTS[achievement][achievementReward]);
	else
		dg_color_chat(0, _, "!t%s!y ganó el logro !g%s!y (LOGRO SECRETO)", g_PlayerName[id], ACHIEVEMENTS[achievement][achievementName]);

	static Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_achievements (acc_id, achievement_id, achievement_timestamp, achievement_first) VALUES ('%d', '%d', UNIX_TIMESTAMP(), '1');", g_AccountId[id], achievement);
	
	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 52);
	else
		SQL_FreeHandle(sqlQuery);

	g_Points[id][POINT_SPECIAL] += ACHIEVEMENTS[achievement][achievementReward];

	rewardAchievement(id);
}

public rewardAchievement(const id)
{
	if((g_AchievementTotal[id] % 25) == 0)
	{
		switch(g_AchievementTotal[id])
		{
			case 25: setAchievement(id, LOS_PRIMEROS);
			case 75: setAchievement(id, VAMOS_POR_MAS);
			case 150: setAchievement(id, EXPERTO_EN_LOGROS);
			case 300: setAchievement(id, THIS_IS_SPARTA);
			default: saveInfo(id);
		}

		static iRandomLevel;
		iRandomLevel = (random_num(5, 10) * (g_Reset[id] + 1));

		if((g_Level[id] + iRandomLevel) < MAX_LEVEL)
		{
			g_Exp[id] = 0;
			g_Level[id] += iRandomLevel;

			dg_color_chat(0, _, "!t%s!y has sido premiado con !g%d nivel%s!y por haber completado !g%d logros!y", g_PlayerName[id], iRandomLevel, ((iRandomLevel != 1) ? "es" : ""), (g_AchievementTotal[id] - 1));
			checkExpEquation(id);
		}
	}

	if(!g_Hat[id][HAT_PSYCHO] && g_Achievement[id][BOMBA_FALLIDA] && g_Achievement[id][VIRUS])
		giveHat(id, HAT_PSYCHO);

	if(g_Achievement[id][ZANGANO_REAL] && g_Achievement[id][DEPREDADOR_FINAL])
		setAchievement(id, DEPREDALIEN);
}

public giveHat(const id, const hat)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id] || g_Hat[id][hat])
		return;

	g_Hat[id][hat] = 1;
	g_HatUnlocked[id][hat] = get_systime();
	++g_HatTotal[id];

	g_LastHatUnlocked = hat;

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_hats (acc_id, hat_id, hat_timestamp) VALUES ('%d', '%d', UNIX_TIMESTAMP());", g_AccountId[id], hat);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 53);
	else
		SQL_FreeHandle(sqlQuery);

	dg_color_chat(0, _, "!t%s!y ha conseguido el gorro !g%s!y [X]", g_PlayerName[id], HATS[hat][hatName]);
}

public setHat(const id, const hat)
{
	if(!g_IsAlive[id])
		return;

	if(is_valid_ent(g_HatEnt[id]))
		remove_entity(g_HatEnt[id]);

	g_HatNext[id] = HAT_NONE;
	g_HatId[id] = hat;

	if(!hat)
		return;

	new iEnt;
	iEnt = g_HatEnt[id];

	if(!is_valid_ent(g_HatEnt[id]))
	{
		g_HatEnt[id] = iEnt = create_entity("info_target");

		entity_set_string(iEnt, EV_SZ_classname, ENT_CLASSNAME_HAT);

		entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(iEnt, EV_ENT_aiment, id);
		entity_set_edict(iEnt, EV_ENT_owner, id);

		if(g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_DUEL_FINAL || g_Mode == MODE_GRUNT)
		{
			entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
			entity_set_float(iEnt, EV_FL_renderamt, 0.0);
		}

		if(g_AccountId[id] == HAT_MANAGER_ID)
			entity_set_model(iEnt, HAT_MANAGER_MODEL);
		else
			entity_set_model(iEnt, HATS[hat][hatModel]);
	}
}

public getUserClanBadString(const clan_name[])
{
	static const LETTERS_AND_SIMBOLS_ALLOWED[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '(', ')', '[', ']', '{', '}', '-', '=', '.', ',', ':', '!', ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
	static iLen;
	static j;

	iLen = strlen(clan_name);
	j = 0;

	for(new i = 0; i < iLen; ++i)
	{
		for(new k = 0; k < sizeof(LETTERS_AND_SIMBOLS_ALLOWED); ++k)
		{
			if(clan_name[i] == LETTERS_AND_SIMBOLS_ALLOWED[k])
				++j;
		}
	}

	if(iLen != j)
		return 1;

	return 0;
}

public fakeDropHeadZombie(const id)
{
	static Float:vecVelocity[3];
	static Float:vecOrigin[3];
	static iEnt;

	velocity_by_aim(id, 300, vecVelocity);
	getDropOrigin(id, vecOrigin);
	iEnt = create_entity("info_target");

	if(is_valid_ent(iEnt))
	{
		entity_set_string(iEnt, EV_SZ_classname, ENT_CLASSNAME_HEADZOMBIE);
		entity_set_model(iEnt, MODEL_HEADZOMBIE);
		entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

		entity_set_origin(iEnt, vecOrigin);
		entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

		entity_set_edict(iEnt, EV_ENT_euser2, id);

		set_size(iEnt, Float:{-6.0, -6.0, -6.0}, Float:{6.0, 6.0, 6.0});
		entity_set_vector(iEnt, EV_VEC_mins, Float:{-6.0, -6.0, -6.0});
		entity_set_vector(iEnt, EV_VEC_maxs, Float:{6.0, 6.0, 6.0});

		set_task(2.0, "task__CheckOriginHead", iEnt);
	}
}

public task__CheckOriginHead(const ent)
{
	if(is_valid_ent(ent))
		entity_get_vector(ent, EV_VEC_origin, g_MiniGameTejo_HeadZombie);
}

public dropHeadZombie(const id)
{
	static Float:vecVelocity[3];
	static Float:vecOrigin[3];
	static iEnt;

	velocity_by_aim(id, 300, vecVelocity);
	getDropOrigin(id, vecOrigin);
	iEnt = create_entity("info_target");

	if(is_valid_ent(iEnt))
	{
		entity_set_string(iEnt, EV_SZ_classname, ENT_CLASSNAME_HEADZOMBIE);
		entity_set_model(iEnt, MODEL_HEADZOMBIE);
		entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

		entity_set_origin(iEnt, vecOrigin);
		entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

		entity_set_edict(iEnt, EV_ENT_euser2, id);

		set_size(iEnt, Float:{-6.0, -6.0, -6.0}, Float:{6.0, 6.0, 6.0});
		entity_set_vector(iEnt, EV_VEC_mins, Float:{-6.0, -6.0, -6.0});
		entity_set_vector(iEnt, EV_VEC_maxs, Float:{6.0, 6.0, 6.0});

		static Float:vecColor[3];
		static iRed;
		static iGreen;
		static iYellow;
		static iWhite;
		static iHead;

		iRed = random_num(0, 1);
		iGreen = random_num(0, 1);
		iYellow = random_num(1, 5);
		iWhite = random_num(1, 5);

		switch(get_pcvar_num(g_pCvar_DropHeadZombie))
		{
			case 1:
			{
				vecColor = Float:{255.0, 0.0, 0.0};
				iHead = HEADZOMBIE_RED;
			}
			case 2:
			{
				vecColor = Float:{0.0, 255.0, 0.0};
				iHead = HEADZOMBIE_GREEN;
			}
			case 3:
			{
				vecColor = Float:{0.0, 0.0, 255.0};
				iHead = HEADZOMBIE_BLUE;
			}
			case 4:
			{
				vecColor = Float:{255.0, 255.0, 0.0};
				iHead = HEADZOMBIE_YELLOW;
			}
			case 5:
			{
				vecColor = Float:{255.0, 255.0, 255.0};
				iHead = HEADZOMBIE_WHITE;
			}
			default:
			{
				if(iRed)
				{
					vecColor = Float:{255.0, 0.0, 0.0};
					iHead = HEADZOMBIE_RED;
				}
				else if(!iGreen)
				{
					vecColor = Float:{0.0, 255.0, 0.0};
					iHead = HEADZOMBIE_GREEN;
				}
				else if(iYellow == 1 || iYellow == 5)
				{
					vecColor = Float:{255.0, 255.0, 0.0};
					iHead = HEADZOMBIE_YELLOW;
				}
				else if(iWhite == 3)
				{
					vecColor = Float:{255.0, 255.0, 255.0};
					iHead = HEADZOMBIE_WHITE;
				}
				else
				{
					vecColor = Float:{0.0, 0.0, 255.0};
					iHead = HEADZOMBIE_BLUE;
				}
			}
		}

		set_rendering(iEnt, kRenderFxGlowShell, floatround(vecColor[0]), floatround(vecColor[1]), floatround(vecColor[2]), kRenderNormal, 4);
		entity_set_edict(iEnt, EV_ENT_euser4, iHead);
	}
}

getDropOrigin(const id, Float:vecOrigin[3], const vel_add=0)
{
	static Float:vecViewOfs[3];
	static Float:vecAim[3];

	entity_get_vector(id, EV_VEC_view_ofs, vecViewOfs);
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin);

	velocity_by_aim(id, (50 + vel_add), vecAim);

	vecOrigin[0] += vecAim[0];
	vecOrigin[1] += vecAim[1];
}

public createFlareRocket(const rocket)
{
	static iEnt;
	iEnt = create_entity("env_sprite");
	
	if(!is_valid_ent(iEnt))
		return 0;

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

public removeRocket(const rocket)
{
	if(is_valid_ent(rocket))
	{
		static iEnt;
		iEnt = entity_get_edict(rocket, EV_ENT_FLARE);

		if(is_valid_ent(iEnt))
			remove_entity(iEnt);

		remove_entity(rocket);
	}
}

Float:floatRadius(Float:amount, Float:radius, Float:distance)
	return floatsub(amount, floatmul(floatdiv(amount, radius), distance));

findEntByOwner(const owner, const class_name[])
{
	static iEnt;
	iEnt = -1;

	while((iEnt = find_ent_by_class(iEnt, class_name)) && entity_get_edict(iEnt, EV_ENT_owner) != owner) {}
	return iEnt;
}

public checkStuffOnDisconnected(const id)
{
	if(g_Mode == MODE_ANNIHILATOR)
	{
		if(g_ModeAnnihilator_Acerts[id])
			TrieSetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], g_ModeAnnihilator_Acerts[id]);
		else
			TrieSetCell(g_tModeAnnihilator_Acerts, g_PlayerName[id], 0);
	}

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_ClanInvitationsId[i][id])
			--g_ClanInvitations[i];
		
		g_ClanInvitationsId[i][id] = 0;
	}

	if(g_ClanSlot[id])
	{
		if(!g_Zombie[id] && g_ClanCombo[g_ClanSlot[id]])
		{
			sendClanMessage(id, "Un miembro humano del Clan se desconectó y el combo ha finalizado");
			clanFinishCombo(id);
		}

		clanUpdateHumans(id);

		--g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

		if(!g_Clan[g_ClanSlot[id]][clanCountOnlineMembers])
			g_Clan[g_ClanSlot[id]][clanId] = 0;
	}
}

systemSort(const num[], &num_sort)
{
	static iMaxSort;
	static iMaxSortId;

	iMaxSort = 0;
	iMaxSortId = -1;

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i])
			continue;

		if(num[i] > iMaxSort)
		{
			iMaxSort = num[i];
			iMaxSortId = i;
		}
	}

	if(iMaxSortId == -1)
		return 0;

	num_sort = iMaxSort;
	return iMaxSortId;
}

public checkModeAvsP(const victim)
{
	static iRandomPercent;
	static iExp;
	static sExp[16];

	iRandomPercent = random_num(66, 99);

	if(g_SpecialMode_Alien[victim])
	{
		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;

			if(g_Zombie[i])
			{
				ExecuteHamB(Ham_Killed, i, i, 2);
				continue;
			}

			iExp = getConversionPercent(i, iRandomPercent) * g_ExpMult[i];
			addDot(iExp, sExp, charsmax(sExp));

			dg_color_chat(i, _, "Ganaste !g%s XP!y por sobrevivir en el modo !tALIEN vs DEPREDADOR!y", sExp);
			addXP(i, iExp);
		}
	}
	else if(g_SpecialMode_Predator[victim])
	{
		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;

			if(!g_Zombie[i])
			{
				ExecuteHamB(Ham_Killed, i, i, 2);
				continue;
			}

			iExp = getConversionPercent(i, iRandomPercent) * g_ExpMult[i];
			addDot(iExp, sExp, charsmax(sExp));

			dg_color_chat(i, _, "Ganaste !g%s XP!y por sobrevivir en el modo !tALIEN vs DEPREDADOR!y", sExp);
			addXP(i, iExp);
		}
	}
}

public isSolid(const ent)
	return (ent ? ((entity_get_int(ent, EV_INT_solid) > SOLID_TRIGGER) ? 1 : 0) : 1);

public checkModeMegaArmageddonTwo(const survivor)
{
	if(g_ModeMA_AllZombies || g_ModeMA_AllHumans)
	{
		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;

			if(g_ModeMA_Reward[i] == 0 || g_ModeMA_Reward[i] == 2)
				continue;

			if(g_ModeMA_AllZombies && g_Zombie[i])
				setAchievement(i, MA_KILL_ALL_HUMANS);
			else if(g_ModeMA_AllHumans && !g_Zombie[i])
				setAchievement(i, MA_KILL_ALL_ZOMBIES);
		}
	}

	static iArgs[1];
	iArgs[0] = survivor;

	set_task(2.0, "task__ModeMegaArmageddonFix", _, iArgs, sizeof(iArgs));
}

public endModeMegaArmageddon(const humans) // 1 = Ganaron los humanos | 0 = Ganaron los zombies
{
	static iRandom;
	static iRandomLose;

	iRandom = random_num(10, 25);

	if(!((iRandom % 2) == 0))
		++iRandom;

	iRandomLose = (iRandom / 2);

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i] || !g_AccountLogged[i])
			continue;

		if(g_ModeMA_Reward[i] == 0)
		{
			dg_color_chat(i, _, "No recibiste recompensa porque no participaste del Mega Armageddon");
			continue;
		}
		else if(g_ModeMA_Reward[i] == 2)
		{
			dg_color_chat(i, _, "No recibiste recompensa porque entraste en la segunda fase del Mega Armageddon");
			continue;
		}

		if(humans && !g_Zombie[i])
		{
			g_Points[i][POINT_HUMAN] += iRandom;
			g_Points[i][POINT_ZOMBIE] += iRandom;

			dg_color_chat(i, _, "Ganaste !g%d pH!y y !g%d pZ!y por haber sobrevivido en el !tMEGA ARMAGEDDON!y", iRandom, iRandom);

			setAchievement(i, MA_WIN_H);
			continue;
		}

		if(humans && g_Zombie[i])
		{
			g_Points[i][POINT_HUMAN] += iRandomLose;
			g_Points[i][POINT_ZOMBIE] += iRandomLose;
			
			dg_color_chat(i, _, "Ganaste !g%d pH!y y !g%d pZ!y por haber participado en el !tMEGA ARMAGEDDON!y", iRandomLose, iRandomLose);
		}

		if(!humans && g_Zombie[i])
		{
			g_Points[i][POINT_HUMAN] += iRandom;
			g_Points[i][POINT_ZOMBIE] += iRandom;

			dg_color_chat(i, _, "Ganaste !g%d ph!y y !g%d pZ!y por haber sobrevivido en el !tMEGA ARMAGEDDON!y", iRandom, iRandom);

			setAchievement(i, MA_WIN_Z);
			continue;
		}

		if(!humans && !g_Zombie[i])
		{
			g_Points[i][POINT_HUMAN] += iRandomLose;
			g_Points[i][POINT_ZOMBIE] += iRandomLose;

			dg_color_chat(i, _, "Ganaste !g%d pH!y y !g%d pZ!y por haber participado en el !tMEGA ARMAGEDDON!y", iRandomLose, iRandomLose);
			continue;
		}
	}

	set_cvar_num("mp_round_infinite", 0);
}

public gunGameBestUsers()
{
	static iMax;
	static iMaxId[3];
	static iTemp;

	iMax = 0;
	iMaxId = {0, 0, 0};

	for(new j = 0; j < 3; ++j)
	{
		iMax = 0;

		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsConnected[i] || !g_AccountLogged[i])
				continue;

			if(g_ModeGG_Level[i] > iMax && i != iMaxId[0] && i != iMaxId[1] && i != iMaxId[2])
			{
				iMax = g_ModeGG_Level[i];
				iMaxId[j] = i;
			}
		}
	}

	if(g_ModeGG_Level[iMaxId[1]] > g_ModeGG_Level[iMaxId[0]])
	{
		iTemp = iMaxId[0];
		iMaxId[0] = iMaxId[1];
		iMaxId[1] = iTemp;
	}

	if(g_ModeGG_Level[iMaxId[2]] > g_ModeGG_Level[iMaxId[0]])
	{
		iTemp = iMaxId[0];
		iMaxId[0] = iMaxId[2];
		iMaxId[2] = iTemp;
	}

	if(g_ModeGG_Level[iMaxId[2]] > g_ModeGG_Level[iMaxId[1]])
	{
		iTemp = iMaxId[1];
		iMaxId[1] = iMaxId[2];
		iMaxId[2] = iTemp;
	}

	formatex(g_ModeGG_Stats, charsmax(g_ModeGG_Stats), "%s - %d^n%s - %d^n%s - %d", g_PlayerName[iMaxId[0]], g_ModeGG_Level[iMaxId[0]], g_PlayerName[iMaxId[1]], g_ModeGG_Level[iMaxId[1]], g_PlayerName[iMaxId[2]], g_ModeGG_Level[iMaxId[2]]);
}

public gunGameGiveWeapons(const id)
{
	static iLevel;
	iLevel = g_ModeGG_Level[id];

	if(g_ModeGG_Type == GUNGAME_CLASSIC)
	{
		give_item(id, "weapon_knife");
		give_item(id, GUNGAME_WEAPONS_CLASSIC[iLevel]);

		if(GUNGAME_WEAPONS_CLASSIC_CSW[iLevel] != 0)
		{
			if(GUNGAME_WEAPONS_CLASSIC_CSW[iLevel] != CSW_HEGRENADE)
			{
				ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]], AMMO_TYPE[GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]], MAX_BPAMMO[GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]]);
				replaceWeaponModels(id, GUNGAME_WEAPONS_CLASSIC_CSW[iLevel]);

				g_ModeGGCrazy_HeLevel[id] = 0;
			}
			else
			{
				cs_set_user_bpammo(id, CSW_HEGRENADE, 200);
				
				g_ModeGGCrazy_HeLevel[id] = 1;
			}
		}
	}
	else
	{
		if(g_ModeGG_Type == GUNGAME_CRAZY)
			iLevel = g_ModeGGCrazy_Level[id];

		give_item(id, GUNGAME_WEAPONS[iLevel]);

		if(GUNGAME_WEAPONS_CSW[iLevel] != 0)
		{
			if(GUNGAME_WEAPONS_CSW[iLevel] != CSW_HEGRENADE)
			{
				ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[GUNGAME_WEAPONS_CSW[iLevel]], AMMO_TYPE[GUNGAME_WEAPONS_CSW[iLevel]], MAX_BPAMMO[GUNGAME_WEAPONS_CSW[iLevel]]);
				replaceWeaponModels(id, GUNGAME_WEAPONS_CSW[iLevel]);

				g_ModeGGCrazy_HeLevel[id] = 0;
			}
			else
			{
				cs_set_user_bpammo(id, CSW_HEGRENADE, 200);

				g_ModeGGCrazy_HeLevel[id] = 1;
			}
		}
	}
}

public megaGunGameAddKill(const id)
{
	++g_ModeGG_Kills[id];

	if(g_ModeGG_Kills[id] == 2)
	{
		g_ModeGG_Kills[id] = 0;
		++g_ModeGG_Level[id];

		if(g_ModeGG_Level[id] != 27)
		{
			if(g_ModeGG_Level[id] == 53)
			{
				g_ModeGG_End = 1;

				set_cvar_num("mp_round_infinite", 0);

				megaGunGameGiveRewards(id, 1);
				return;
			}

			playSound(id, SOUND_ROUND_GUNGAME);

			strip_user_weapons(id);

			give_item(id, MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[id]]);

			if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != 0)
			{
				if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != CSW_HEGRENADE)
				{
					ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], AMMO_TYPE[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]]);
					replaceWeaponModels(id, MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]);
				}
				else
					cs_set_user_bpammo(id, CSW_HEGRENADE, 200);
			}

			gunGameBestUsers();
		}
		else
		{
			if(g_ModeMGG_Block)
				return;
			else if(g_ModeMGG_Phase)
			{
				playSound(id, SOUND_ROUND_GUNGAME);

				strip_user_weapons(id);

				give_item(id, MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[id]]);

				if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != 0)
				{
					if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]] != CSW_HEGRENADE)
					{
						ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], AMMO_TYPE[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]], MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]]);
						replaceWeaponModels(id, MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[id]]);
					}
					else
						cs_set_user_bpammo(id, CSW_HEGRENADE, 200);
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

public megaGunGameGiveRewards(const winner_id, const phase_id)
{
	static iRewardAPs;
	static iRewardXP;
	static sRewardAPs[16];
	static sRewardXP[16];

	iRewardAPs = 0;
	iRewardXP = 0;
	sRewardAPs[0] = EOS;
	sRewardXP[0] = EOS;

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i] || !g_AccountLogged[i])
			continue;

		iRewardAPs = ((((g_AmmoPacksMult[i] * (g_HappyTime + 1)) + getPlaying()) * g_ModeGG_Level[i]) * (g_Level[i] + (g_Reset[i] * MAX_LEVEL)));
		addDot(iRewardAPs, sRewardAPs, charsmax(sRewardAPs));

		iRewardXP = ((((50 * (g_ExpMult[i] * (g_HappyTime + 1))) + getPlaying()) * g_ModeGG_Level[i]) * (g_Level[i] + (g_Reset[i] * MAX_LEVEL)));
		addDot(iRewardXP, sRewardXP, charsmax(sRewardXP));

		for(new j = 0; j < structIdPoints; ++j)
		{
			if(j == POINT_HUMAN || j == POINT_ZOMBIE || j == POINT_SPECIAL)
				g_Points[i][j] += g_ModeGG_Level[i];
		}

		dg_color_chat(i, _, "Ganaste !g%s APs!y, !g%s XP!y y !g%d pHZE!y", sRewardAPs, sRewardXP, g_ModeGG_Level[i]);

		addAPs(i, iRewardAPs);
		addXP(i, iRewardXP);

		if(g_IsAlive[i])
			user_kill(i, 1);
	}

	if(!phase_id)
	{
		dg_color_chat(0, _, "El usuario !t%s!y ganó !g1 DIAMANTE!y por ganar la primer mitad del Mega GunGame", g_PlayerName[winner_id]);
		++g_Points[winner_id][POINT_DIAMMONDS];
	}
	else
	{
		dg_color_chat(0, _, "El usuario !t%s!y ganó !g2 DIAMANTES!y por ganar el Mega GunGame", g_PlayerName[winner_id]);
		g_Points[winner_id][POINT_DIAMMONDS] += 2;
	}
}

public logToFileModes(const id, const mode, const next_mode)
{
	static const LOGFILE_DIR[] = "addons/amxmodx/logs/zombie_plague";
	static sDate[16];
	static sTime[16];
	static sLogDir[64];
	static sLogBuffer[256];

	get_time("%Y-%m-%d", sDate, charsmax(sDate));
	get_time("%H:%M:%S", sTime, charsmax(sTime));
	formatex(sLogDir, charsmax(sLogDir), "%s/%s_modes.log", LOGFILE_DIR, sDate);
	formatex(sLogBuffer, charsmax(sLogBuffer), "Hora <%s> ::: Modo <%s> - Administrador <%s> - NextMode <%s>", sTime, __MODES[mode], g_PlayerName[id], ((next_mode) ? "Si" : "No"));

	if(!dir_exists(LOGFILE_DIR))
		mkdir(LOGFILE_DIR);

	if(!file_exists(sLogDir))
	{
		static iFile;
		iFile = fopen(sLogDir, "wt");
		fclose(iFile);
	}

	write_file(sLogDir, sLogBuffer);
}

public clanFindSlot()
{
	for(new i = 1; i < MAX_USERS; ++i)
	{
		if(!g_Clan[i][clanId])
			return i;
	}

	return 0;
}

public getClanPerks(const id)
{
	static iCount;
	iCount = 0;

	for(new i = 0; i < structIdClanPerks; ++i)
	{
		if(g_ClanPerks[g_ClanSlot[id]][i])
			++iCount;
	}

	return iCount;
}

public getClanMemberEmptySlot(const id)
{
	for(new i = 0; i < MAX_CLAN_MEMBERS; ++i)
	{
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId])
			continue;

		return i;
	}

	return -1;
}

public getClanMemberSlotId(const id)
{
	for(new i = 0; i < MAX_CLAN_MEMBERS; ++i)
	{
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] == g_AccountId[id])
			return i;
	}

	return -1;
}

public resetDataClanMembers(const clan_slot)
{
	for(new i = 0; i < MAX_CLAN_MEMBERS; ++i)
	{
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
		g_ClanMembers[clan_slot][i][clanMemberLevel] = 0;
		g_ClanMembers[clan_slot][i][clanMemberReset] = 0;
	}

	for(new i = 0; i < structIdClanPerks; ++i)
		g_ClanPerks[clan_slot][i] = 0;
}

public getClanMemberRange(const id)
{
	for(new i = 0; i < MAX_CLAN_MEMBERS; ++i)
	{
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] == g_AccountId[id])
			return g_ClanMembers[g_ClanSlot[id]][i][clanMemberOwner];
	}

	return 0;
}

public sendClanMessage(const id, const input[], any:...)
{
	static sMessage[191];
	vformat(sMessage, charsmax(sMessage), input, 3);

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_ClanSlot[id] == g_ClanSlot[i])
			dg_color_chat(i, _, sMessage);
	}
}

public clanCheckRequiredCombo(const id)
{
	if(!g_ClanSlot[id])
		return;

	new Float:flRequiredCombo = 0.0;
	new i;

	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsConnected[i])
			continue;

		if(g_ClanSlot[id] != g_ClanSlot[i])
			continue;

		if(g_Zombie[i])
			continue;

		flRequiredCombo += g_ComboDamageNeed[i];
	}

	if(flRequiredCombo < 2.0)
		flRequiredCombo = 2.0;

	g_ClanComboDamageNeed[g_ClanSlot[id]] = flRequiredCombo;
}

public clanShowCombo(const id)
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

		if(g_Zombie[i])
			continue;

		set_hudmessage(g_UserOption_Color[i][COLOR_TYPE_HUD_CC][0], g_UserOption_Color[i][COLOR_TYPE_HUD_CC][1], g_UserOption_Color[i][COLOR_TYPE_HUD_CC][2], g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][0], g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][1], g_UserOption_EffectHud[i][HUD_TYPE_CLAN_COMBO], 0.0, 8.0, 0.0, 0.0, -1);

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

			if(g_Zombie[i])
				continue;

			set_hudmessage(g_UserOption_Color[i][COLOR_TYPE_HUD_CC][0], g_UserOption_Color[i][COLOR_TYPE_HUD_CC][1], g_UserOption_Color[i][COLOR_TYPE_HUD_CC][2], g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][0], g_UserOption_PositionHud[i][HUD_TYPE_CLAN_COMBO][1], g_UserOption_EffectHud[i][HUD_TYPE_CLAN_COMBO], 0.0, 8.0, 0.0, 0.0, -1);
			ShowSyncHudMsg(i, g_HudSync_ClanCombo, "%s^nGanaste %s de XP^nDaño total: %s", g_Clan[g_ClanSlot[id]][clanName], sReward, sDamageTotal);

			addXP(i, iReward);
		}
	}

	g_ClanComboReward[g_ClanSlot[id]] = 0;
	g_ClanComboDamage[g_ClanSlot[id]] = 0.0;
}

public clanUpdateHumans(const id)
{
	if(!g_ClanSlot[id])
		return;

	new iHumans = 0;
	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i])
			continue;

		if(g_ClanSlot[id] != g_ClanSlot[i])
			continue;

		if(g_Zombie[i])
			continue;

		++iHumans;
	}

	g_Clan[g_ClanSlot[id]][clanHumans] = iHumans;
	clanCheckRequiredCombo(id);
}

public getUserTypeMod(const id)
{
	new sBuffer[32];
	sBuffer[0] = EOS;

	if((get_user_flags(id) & ADMIN_RCON))
		formatex(sBuffer, charsmax(sBuffer), "!g[OWNER DRUNK] ");
	else if((get_user_flags(id) & ADMIN_LEVEL_D))
		formatex(sBuffer, charsmax(sBuffer), "!g[STAFF] ");
	else if((get_user_flags(id) & ADMIN_LEVEL_C))
		formatex(sBuffer, charsmax(sBuffer), "!g[CAPITÁN] ");
	else if((get_user_flags(id) & ADMIN_LEVEL_A))
		formatex(sBuffer, charsmax(sBuffer), "!g[DONADOR] ");
	else if((get_user_flags(id) & ADMIN_RESERVATION))
		formatex(sBuffer, charsmax(sBuffer), "!g[VIP] ");

	return sBuffer;
}

public getUserChatMode(const id)
{
	static sChatMode[32];
	formatex(sChatMode, charsmax(sChatMode), " !g%s ", CHAT_MODE[g_UserOption_ChatMode[id]]);

	static sRange[4];
	formatex(sRange, charsmax(sRange), "%c", getUserRange(g_Reset[id]));

	static sLevelNum[8];
	static sLevel[16];

	addDot(g_Level[id], sLevelNum, charsmax(sLevelNum));
	formatex(sLevel, charsmax(sLevel), "%s", sLevelNum);

	replace_all(sChatMode, charsmax(sChatMode), "Rango", sRange);
	replace_all(sChatMode, charsmax(sChatMode), "Nivel", sLevel);

	return sChatMode;
}

public getUserHealthPercent(const id, const percent)
{
	static iPercentHealth;
	iPercentHealth = ((percent * g_MaxHealth[id]) / 100);

	if(g_Health[id] >= iPercentHealth)
		return 1;

	return 0;
}

public getUserTimePlaying(const id)
{
	static sBuffer[32];
	sBuffer[0] = EOS;

	if(g_PlayedTime[id][TIME_DAY])
		formatex(sBuffer, charsmax(sBuffer), "%d día%s y %d hora%s", g_PlayedTime[id][TIME_DAY], ((g_PlayedTime[id][TIME_DAY] != 1) ? "s" : ""), g_PlayedTime[id][TIME_HOUR], ((g_PlayedTime[id][TIME_HOUR]) ? "s" : ""));
	else if(g_PlayedTime[id][TIME_HOUR])
		formatex(sBuffer, charsmax(sBuffer), "%d hora%s", g_PlayedTime[id][TIME_HOUR], ((g_PlayedTime[id][TIME_HOUR] != 1) ? "s" : ""));
	else
		formatex(sBuffer, charsmax(sBuffer), "Nada");

	return sBuffer;
}

public setUserNightVision(const id, const value)
{
	g_NightVision[id] = value;

	remove_task(id + TASK_NIGHTVISION);

	if(!g_NightVision[id])
		return;

	set_task(0.3, "task__SetUserNightVision", id + TASK_NIGHTVISION, .flags="b");
}

public grabUser(const id, const target)
{
	g_Grab[id] = target;

	if(target <= g_MaxPlayers)
	{
		g_GrabGravity[target] = get_user_gravity(target);
		set_user_gravity(target, 0.0);
	}

	g_GrabDistance[id] = 0.0;

	remove_task(id + TASK_GRAB_PRETHINK);
	set_task(0.1, "task__GrabPrethink", id + TASK_GRAB_PRETHINK, .flags="b");

	// task__GrabPrethink(id + TASK_GRAB_PRETHINK);
}

// **************************************************
//		[Tasks Functions]
// **************************************************
public task__SetConfigs()
{
	set_cvar_num("allow_spectators", 1);

	set_cvar_num("mp_flashlight", 1);
	set_cvar_num("mp_footsteps", 1);
	set_cvar_num("mp_freezetime", 0);
	set_cvar_num("mp_friendlyfire", 0);
	set_cvar_num("mp_autoteambalance", 0);
	set_cvar_num("mp_limitteams", 0);
	set_cvar_num("mp_round_infinite", 0);
	set_cvar_float("mp_roundtime", 6.0);

	set_cvar_num("sv_maxspeed", 999);
	set_cvar_num("sv_airaccelerate", 100);
	set_cvar_num("sv_voiceenable", 1);
	set_cvar_string("sv_voicecodec", "voice_speex");
	set_cvar_num("sv_voicequality", 5);
	set_cvar_num("sv_alltalk", 1);
	set_cvar_string("sv_skyname", "space");
	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	server_cmd("sv_restart 1");

	g_LogSay = 1;
}

public task__SqlQueries()
{
	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT COUNT(acc_id) FROM zp6_pjs;");

	if(!SQL_Execute(sqlQuery))
		executeQuery(0, sqlQuery, 250);
	else if(SQL_NumResults(sqlQuery))
	{
		g_GlobalRank = SQL_ReadResult(sqlQuery, 0);
		SQL_FreeHandle(sqlQuery);
	}
	else
	{
		g_GlobalRank = 0;
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_general WHERE id='1';");

	if(!SQL_Execute(sqlQuery))
		executeQuery(0, sqlQuery, 54);
	else if(SQL_NumResults(sqlQuery))
	{
		new sModeCount[256];
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "modes"), sModeCount, charsmax(sModeCount));
		stringToArray(sModeCount, g_ModeCount, structIdModes);

		g_EventMode_MegaArmageddon = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_ma"));
		g_EventMode_GunGame = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_gg"));
		g_ModeGG_Type = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_gg_type"));
		g_ModeGG_LastWinner = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_gg_last_winner"));
		g_ModeMGG_Played = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "round_mgg"));

		SQL_FreeHandle(sqlQuery);

		new sCurrentDay[4];
		get_time("%A", sCurrentDay, charsmax(sCurrentDay));

		if(equal(sCurrentDay, "Sat")) // Sábado
		{
			new iEnt;
			iEnt = create_entity("info_target");
			
			if(is_valid_ent(iEnt))
			{
				entity_set_string(iEnt, EV_SZ_classname, ENTTHINK_CLASSNAME_MEGA_GUNGAME);
				entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 1225.0));

				register_think(ENTTHINK_CLASSNAME_MEGA_GUNGAME, "think__ModeMegaGungame");
			}
		}
	}
	else
		SQL_FreeHandle(sqlQuery);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection,  "SELECT zp6_achievements.achievement_id, zp6_pjs.pj_name, zp6_achievements.achievement_timestamp FROM zp6_achievements LEFT JOIN zp6_pjs ON (zp6_pjs.acc_id=zp6_achievements.acc_id AND zp6_pjs.pj_id=zp6_achievements.pj_id) WHERE zp6_achievements.achievement_first='1';");

	if(!SQL_Execute(sqlQuery))
		executeQuery(0, sqlQuery, 56);
	else if(SQL_NumResults(sqlQuery))
	{
		new iAchievement;

		while(SQL_MoreResults(sqlQuery))
		{
			iAchievement = SQL_ReadResult(sqlQuery, 0);

			g_Achievement[0][iAchievement] = 1;
			SQL_ReadResult(sqlQuery, 1, g_AchievementName[0][iAchievement], 32);
			g_AchievementUnlocked[0][iAchievement] = SQL_ReadResult(sqlQuery, 2);

			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);
	}
	else
		SQL_FreeHandle(sqlQuery);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "(SELECT combo FROM zp6_combos WHERE combo_type='0' AND mapname=^"%s^" ORDER BY combo DESC LIMIT 1) UNION ALL (SELECT combo FROM zp6_combos WHERE combo_type='1' AND mapname=^"%s^" ORDER BY combo DESC LIMIT 1);", g_MapName, g_MapName);
	
	if(!SQL_Execute(sqlQuery))
		executeQuery(0, sqlQuery, 57);
	else if(SQL_NumResults(sqlQuery))
	{
		new iRepeat;
		iRepeat = 0;
		
		while(SQL_MoreResults(sqlQuery))
		{
			if(!iRepeat)
			{
				g_MaxComboHumanMap = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "combo"));
				
				if(g_MaxComboHumanMap < 1000)
					g_MaxComboHumanMap = 1000;
			}
			else
			{
				g_MaxComboZombieMap = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "combo"));
				
				if(g_MaxComboZombieMap < 5)
					g_MaxComboZombieMap = 5;
			}

			++iRepeat;
			
			SQL_NextRow(sqlQuery);
		}
		
		SQL_FreeHandle(sqlQuery);
	}
	else
		SQL_FreeHandle(sqlQuery);
}

public task__AchievementTempIds(const id)
{
	if(!g_IsConnected[id])
		return;

	static j;
	j = (50 * g_AchievementTempIds);

	++g_AchievementTempIds;

	static k;
	k = (50 * g_AchievementTempIds);

	if(k > structIdAchievements)
		k = structIdAchievements;

	for(new i = j; i < k; ++i)
		dg_console_chat(id, "%d = %s", i, ACHIEVEMENTS[i][achievementName]);

	if(k == structIdAchievements)
		return;

	set_task(1.0, "task__AchievementTempIds", id);
}

public task__RememberVinc(const task_id)
{
	static iId;
	iId = ID_REMEMBER_VINC;

	if(!g_IsConnected[iId] || g_AccountVinc[iId])
		return;

	dg_color_chat(iId, _, "Tu cuenta no está vinculada a !t%s!y, recordá vincularla lo más pronto posible en !gwww.Drunk-Gaming.com/zp!y", PLUGIN_COMMUNITY_NAME);
	dg_color_chat(iId, _, "Vincular tu cuenta ofrece varias opciones/funciones, alguna de ellas muy importantes, además de un logro");
}

public task__Save(const task_id)
{
	new iId;
	iId = ID_SAVE;

	if(!g_IsConnected[iId] || !g_AccountLogged[iId])
		return;

	saveInfo(iId);
}

public task__Banned(const task_id)
{
	new iId;
	iId = ID_BANNED;

	if(!g_IsConnected[iId])
		return;

	server_cmd("kick #%d ^"Tu cuenta está baneada^"", get_user_userid(iId));
}

public task__AutoJoinToSpec(const args[], const task_id)
{
	new iId;
	iId = ID_AUTO_JOIN;

	if(!g_IsConnected[iId])
		return;

	new iMsgId;
	new iMsgBlock;

	iMsgId = args[0];
	iMsgBlock = get_msg_block(iMsgId);

	set_msg_block(iMsgId, BLOCK_SET);
	rg_join_team(iId, TEAM_SPECTATOR);
	set_msg_block(iMsgId, iMsgBlock);
}

public task__RefillBPAmmo(const args[], const task_id)
{
	static iId;
	iId = ID_REFILL_BP_AMMO;

	if(!g_IsAlive[iId] || g_Zombie[iId])
		return;
	
	static iWeaponId;
	iWeaponId = args[0];

	set_msg_block(g_Message_AmmoPickup, BLOCK_ONCE);
	ExecuteHamB(Ham_GiveAmmo, iId, MAX_BPAMMO[iWeaponId], AMMO_TYPE[iWeaponId], MAX_BPAMMO[iWeaponId]);
}

public task__ModeMegaArmageddonFix(const args[])
{
	static iTeam;

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsAlive[i])
			continue;

		if(g_ModeMA_Reward[i] == 0 || (args[0] && g_ModeMA_Reward[i] == 2))
		{
			dg_color_chat(i, _, "No reviviste porque no participaste de la fase inicial del Mega Armageddon");
			continue;
		}

		iTeam = getUserTeam(i);

		if(iTeam == F_TEAM_NONE || iTeam == F_TEAM_SPECTATOR)
			continue;

		if(args[0] && !g_Zombie[i])
			ExecuteHamB(Ham_CS_RoundRespawn, i);
		else if(!args[0] && g_Zombie[i])
			ExecuteHamB(Ham_CS_RoundRespawn, i);
	}
}

public task__RemoveStuff()
{
	static iEnt;
	iEnt = -1;
	
	while((iEnt = find_ent_by_class(iEnt, "func_door_rotating")) != 0)
		entity_set_origin(iEnt, Float:{8192.0, 8192.0, 8192.0});
}

public task__VirusT()
{
	if(g_LastMode == MODE_GRUNT)
		set_cvar_num("dg_afk_time", 60);

	g_VirusT = 1;

	showDHUDMessage(0, random(256), random(256), random(256), -1.0, 0.25, 0, 5.0, "¡EL VIRUS-T SE HA LIBERADO!");

	checkHappyHourAndEvents();
	changeLights();

	if(g_EventModes && g_EventMode_GunGame == 0)
	{
		dg_color_chat(0, _, "Modificador de hoy: !tGUNGAME:!g %s!y", GUNGAME_TYPE_NAME[g_ModeGG_Type]);
		dg_color_chat(0, _, "%s", GUNGAME_TYPE_INFO[g_ModeGG_Type]);
	}
}

public task__StartMode()
	startMode(MODE_NONE);

public task__CheckStuck(const task_id)
{
	static iId;
	iId = ID_CHECK_STUCK;

	if(!g_IsConnected[iId])
		return;
	
	if(isUserStuck(iId))
		randomSpawn(iId);
}

public task__SetUserModelUpdate(const task_id)
{
	static Float:flGameTime;
	flGameTime = get_gametime();
	
	if((flGameTime - g_ModelsTargetTime) >= MODELS_CHANGE_DELAY)
	{
		task__SetUserModel(task_id);
		g_ModelsTargetTime = flGameTime;
	}
	else
	{
		set_task(((g_ModelsTargetTime + MODELS_CHANGE_DELAY) - flGameTime), "task__SetUserModel", task_id);
		g_ModelsTargetTime += MODELS_CHANGE_DELAY;
	}
}

public task__SetUserModel(const task_id)
	set_user_info(ID_MODEL, "model", g_PlayerModel[ID_MODEL]);

public task__SetUserTeamMsg(const task_id)
{
	g_SwitchingTeams = 1;

	emessage_begin(MSG_ALL, g_Message_TeamInfo);
	ewrite_byte(ID_TEAM);
	ewrite_string(CS_TEAM_NAMES[getUserTeam(ID_TEAM)]);
	emessage_end();

	g_SwitchingTeams = 0;
}

public task__HideHUDs(const task_id)
{
	static iId;
	iId = ID_SPAWN;
	
	if(!g_IsAlive[iId])
		return;
	
	message_begin(MSG_ONE, g_Message_HideWeapon, _, iId);
	write_byte(HIDE_HUDS);
	message_end();
	
	message_begin(MSG_ONE, g_Message_Crosshair, _, iId);
	write_byte(0);
	message_end();
}

public task__RespawnCheckUser(const task_id)
{
	if(g_MiniGame_Respawn)
		return;

	static iId;
	iId = ID_SPAWN;
	
	if(g_IsAlive[iId] || g_EndRound)
		return;
	
	static iTeam;
	iTeam = getUserTeam(iId);
	
	if(iTeam == F_TEAM_NONE || iTeam == F_TEAM_SPECTATOR)
		return;
	
	if(g_Zombie[iId])
		g_RespawnAsZombie[iId] = 1;
	else
		g_RespawnAsZombie[iId] = 0;
	
	respawnUserManually(iId);
}

public task__ClearWeapons(const task_id)
{
	static iId;
	iId = ((task_id > g_MaxPlayers) ? ID_SPAWN : task_id);

	if(!g_IsAlive[iId])
		return;

	strip_user_weapons(iId);

	if((g_MiniGame_Weapons && !canUseMiniGames(iId)) && g_Mode != MODE_ARMAGEDDON && g_Mode != MODE_MEGA_ARMAGEDDON && g_Mode != MODE_DUEL_FINAL && g_Mode != MODE_GRUNT)
		give_item(iId, "weapon_knife");
}

public task__SetWeapons(const task_id)
{
	static iId;
	iId = ((task_id > g_MaxPlayers) ? ID_SPAWN : task_id);

	if(!g_IsAlive[iId])
		return;

	if(g_Mode == MODE_ANNIHILATOR)
	{
		strip_user_weapons(iId);
		give_item(iId, "weapon_knife");

		cs_set_weapon_ammo(give_item(iId, "weapon_m249"), 100);
		cs_set_user_bpammo(iId, CSW_M249, 0);

		if(!g_ModeAnnihilator_Acerts[iId])
			dg_color_chat(iId, _, "Tienes una !gM249 Para Machinegun!y para acumular aciertos. Suerte con tu Precisión");

		return;
	}
	else if(g_Mode == MODE_GRUNT)
	{
		strip_user_weapons(iId);
		return;
	}
	else if(g_Mode == MODE_GUNGAME)
	{
		strip_user_weapons(iId);

		gunGameGiveWeapons(iId);
		return;
	}
	else if(g_Mode == MODE_MEGA_GUNGAME)
	{
		strip_user_weapons(iId);

		if(!g_ModeMGG_Block)
		{
			give_item(iId, MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[iId]]);

			if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]] != 0)
			{
				if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]] != CSW_HEGRENADE)
					ExecuteHamB(Ham_GiveAmmo, iId, MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]], AMMO_TYPE[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]], MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[iId]]]);
				else
					cs_set_user_bpammo(iId, CSW_HEGRENADE, 200);
			}
		}

		return;
	}
	else if(g_Mode == MODE_DUEL_FINAL)
	{
		strip_user_weapons(iId);

		switch(g_ModeDuelFinal_Type)
		{
			case DF_TYPE_KNIFE: give_item(iId, "weapon_knife");
			case DF_TYPE_AWP:
			{
				give_item(iId, "weapon_awp");
				cs_set_user_bpammo(iId, CSW_AWP, 200);
			}
			case DF_TYPE_HE:
			{
				give_item(iId, "weapon_hegrenade");
				cs_set_user_bpammo(iId, CSW_HEGRENADE, 200);
			}
			case DF_TYPE_OH:
			{
				give_item(iId, "weapon_deagle");
				cs_set_user_bpammo(iId, CSW_DEAGLE, 200);
			}
			case DF_TYPE_M3:
			{
				give_item(iId, "weapon_m3");
				cs_set_user_bpammo(iId, CSW_M3, 200);
			}
			case DF_TYPE_SCOUTS:
			{
				give_item(iId, "weapon_scout");
				cs_set_user_bpammo(iId, CSW_SCOUT, 200);
			}
		}

		return;
	}

	if(g_Weapons[iId][WEAPON_AUTO_BUY] && task_id > g_MaxPlayers)
	{
		if(!g_IsAlive[iId] || g_Zombie[iId] || g_SpecialMode[iId] || !g_CanBuy[iId] || (g_MiniGame_Weapons && !canUseMiniGames(iId)))
			return;

		buyPrimaryWeapons(iId, g_Weapons[iId][WEAPON_PRIMARY_SELECT]);
		buySecondaryWeapons(iId, g_Weapons[iId][WEAPON_SECONDARY_SELECT]);

		if(g_VirusT == 2)
			buyGrenades(iId);

		g_CanBuy[iId] = 0;
		g_Hat_Devil[iId] = 1;

		return;
	}

	showMenu__BuyPrimaryWeapons(iId, g_MenuPage[iId][MENU_PAGE_BPW]);
}

public task__RespawnUser(const task_id)
{
	if(g_MiniGame_Respawn)
		return;

	static iId;
	iId = ID_SPAWN;

	if(g_IsAlive[iId] || g_EndRound)
		return;

	static iTeam;
	iTeam = getUserTeam(iId);

	if(iTeam == F_TEAM_NONE || iTeam == F_TEAM_SPECTATOR)
		return;

	if(g_NewRound || g_Mode == MODE_INFECTION || g_Mode == MODE_GUNGAME || g_Mode == MODE_MEGA_GUNGAME || g_Mode == MODE_FVSJ || g_Mode == MODE_L4D2 || g_Mode == MODE_SNIPER_ELITE || g_Mode == MODE_ANNIHILATOR)
	{
		switch(g_Mode)
		{
			case MODE_INFECTION:
			{
				if(!g_FirstRespawn[iId])
				{
					static iRandom;
					static iRandomChance;

					iRandom = random_num(1, 100);
					iRandomChance = (__CLASSES[g_Class[iId]][classRespawn] + HATS[g_HatId[iId]][hatUpgrade7] + ((g_AmuletCustomCreated[iId]) ? g_AmuletCustom[iId][acRespawnHuman] : 0));

					if(iRandomChance && iRandom <= iRandomChance)
						g_RespawnAsZombie[iId] = 0;
					else
						g_RespawnAsZombie[iId] = 1;
				}
				else
					g_RespawnAsZombie[iId] = 1;
			}
			case MODE_FVSJ:
			{
				g_RespawnAsZombie[iId] = 0;

				if(g_SpecialMode[iId] != MODE_FVSJ && !g_ModeFvsJ_Jason[iId])
				{
					if(!g_ModeFvsJ_Humans)
						return;

					--g_ModeFvsJ_Humans;

					if(g_ModeFvsJ_Humans <= getHumans())
						return;
				}
			}
			case MODE_L4D2:
			{
				g_RespawnAsZombie[iId] = 1;

				if(g_SpecialMode[iId] != MODE_L4D2)
				{
					if(!g_ModeL4D2_Zombies)
						return;

					--g_ModeL4D2_Zombies;

					if(g_ModeL4D2_Zombies <= getZombies())
						return;
				}
			}
			case MODE_SNIPER_ELITE:
			{
				g_RespawnAsZombie[iId] = 1;

				if(g_SpecialMode[iId] != MODE_SNIPER_ELITE)
				{
					if(!g_ModeSniperElite_ZombieLeft)
						return;

					--g_ModeSniperElite_ZombieLeft;

					if(g_ModeSniperElite_ZombieLeft <= getZombies())
						return;
				}
			}
			case MODE_ANNIHILATOR, MODE_GUNGAME, MODE_MEGA_GUNGAME: g_RespawnAsZombie[iId] = 0;
		}

		respawnUserManually(iId);
	}
}

public task__BurningFlame(const args[], const task_id)
{
	static iFlags;
	static vecOrigin[3];

	iFlags = entity_get_int(ID_BURNING_FLAME, EV_INT_flags);
	get_user_origin(ID_BURNING_FLAME, vecOrigin);

	if((iFlags & FL_INWATER) || !g_IsAlive[ID_BURNING_FLAME] || g_Immunity[ID_BURNING_FLAME] || g_BurningDuration[ID_BURNING_FLAME] < 1 || g_EndRound)
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_SMOKE);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord((vecOrigin[2] - 50));
		write_short(g_Sprite_Smoke);
		write_byte(random_num(15, 20));
		write_byte(random_num(10, 20));
		message_end();

		remove_task(task_id);

		ExecuteHamB(Ham_Player_ResetMaxSpeed, ID_BURNING_FLAME);
		return;
	}

	if((iFlags & FL_ONGROUND))
		ExecuteHamB(Ham_Player_ResetMaxSpeed, ID_BURNING_FLAME);

	if(!g_SpecialMode[ID_BURNING_FLAME] && !random_num(0, 15))
		emitSound(ID_BURNING_FLAME, CHAN_VOICE, SOUND_ZOMBIE_BURN[random_num(0, charsmax(SOUND_ZOMBIE_BURN))]);

	static iNitro;
	iNitro = args[1];

	message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_SPRITE);
	write_coord(vecOrigin[0] + random_num(-5, 5));
	write_coord(vecOrigin[1] + random_num(-5, 5));
	write_coord(vecOrigin[2] + random_num(-10, 10));
	write_short(((iNitro) ? g_Sprite_Nitro : g_Sprite_Flame));
	write_byte(random_num(2, 5));
	write_byte(200);
	message_end();

	--g_BurningDuration[ID_BURNING_FLAME];

	static Float:flDamage;
	static iDamage;

	flDamage = (float(g_MaxHealth[ID_BURNING_FLAME]) * ((iNitro) ? 0.96 : 0.48)) / 100;

	if(g_Habs[ID_BURNING_FLAME][HAB_Z_RESISTANCE_BURN] >= 1)
		flDamage /= 2.0;

	iDamage = floatround(flDamage);

	if((g_Health[ID_BURNING_FLAME] - iDamage) > 0)
		set_user_health(ID_BURNING_FLAME, (g_Health[ID_BURNING_FLAME] - iDamage));

	static iAttacker;
	iAttacker = args[0];

	if(g_IsAlive[iAttacker] && !g_Zombie[iAttacker] && !g_SpecialMode[iAttacker])
	{
		g_ComboDamage[iAttacker] += flDamage;
		g_Combo[iAttacker] = floatround((g_ComboDamage[iAttacker] / g_ComboDamageNeed[iAttacker]));

		showCurrentComboHuman(iAttacker, flDamage);
	}
}

public task__RemoveFreeze(const task_id)
{
	static iId;
	iId = ID_FREEZE;

	if(!g_IsAlive[iId] || !g_Frozen[iId])
		return;

	static iFrozen;
	iFrozen = g_Frozen[iId];

	g_Frozen[iId] = 0;

	ExecuteHamB(Ham_Player_ResetMaxSpeed, iId);
	set_user_gravity(iId, g_FrozenGravity[iId]);

	if(g_ReduceDamage[iId])
		set_user_rendering(iId, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 125);
	else
		set_user_rendering(iId);

	if(!g_DrugBombMove[iId])
	{
		message_begin(MSG_ONE, g_Message_ScreenFade, _, iId);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_IN);
		switch(iFrozen)
		{
			case 3:
			{
				write_byte(255);
				write_byte(0);
				write_byte(255);
			}
			case 2:
			{
				write_byte(100);
				write_byte(5);
				write_byte(100);
			}
			default:
			{
				write_byte(0);
				write_byte(0);
				write_byte(255);
			}
		}
		write_byte(100);
		message_end();
	}

	emitSound(iId, CHAN_BODY, SOUND_NADE_NOVA_BREAK);

	static Float:vecOrigin[3];
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
	write_byte(0x01);
	message_end();
}

public task__RemoveSlowDown(const task_id)
{
	static iId;
	iId = ID_SLOWDOWN;

	if(!g_IsAlive[iId] || !g_SlowDown[iId])
		return;

	g_SlowDown[iId] = 0;
	ExecuteHamB(Ham_Player_ResetMaxSpeed, iId);
}

public task__RemoveMadness(const task_id)
{
	new iId;
	iId = ID_MADNESS;

	if(!g_IsAlive[iId])
		return;

	g_Immunity[iId] = 0;
	g_Speed[iId] -= ZOMBIE_MADNESS_SPEED_EXTRA;

	if(g_ReduceDamage[iId])
		set_user_rendering(iId, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 125);
	else
		set_user_rendering(iId);

	if(!g_Achievement_InfectsWithFury[iId] && g_Mode != MODE_AVSP)
	{
		new iValue;
		TrieGetCell(g_tExtraItem_ZombieMadness, g_PlayerName[iId], iValue);

		if(iValue == 2)
			setAchievement(iId, PENSANDOLO_BIEN);
	}

	ExecuteHamB(Ham_Player_ResetMaxSpeed, iId);
}

public task__RemovePainshock(const task_id)
{
	new iId;
	iId = ID_PAINSHOCK;

	if(!g_IsAlive[iId])
		return;

	if(g_ReduceDamage[iId])
		set_user_rendering(iId, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 125);
	else
		set_user_rendering(iId);

	g_Painshock[iId] = 0;
}

public task__PowerSniperElite(const task_id)
{
	static iId;
	iId = ID_POWER_SNIPER_ELITE;

	if(!g_IsAlive[iId] || g_ModeSniperElite_Speed[iId] != 2)
		return;

	g_ModeSniperElite_Speed[iId] = 0;

	client_print(0, print_center, "¡El SNIPER ELITE perdió su DISPARO VELOZ!");
}

public task__PowerFvsJJason(const task_id)
{
	static iId;
	iId = ID_POWER_FVSJ_JASON;

	if(!g_IsAlive[iId] || !g_ModeFvsJ_Jason[iId] || !g_ModeFvsJ_JasonPower[iId])
		return;

	g_ModeFvsJ_JasonPower[iId] = 0;

	client_print(0, print_center, "¡La FURIA del JASON ha terminado!");
}

public task__FinishPowerPredator(const task_id)
{
	static iId;
	iId = ID_POWER_PREDATOR;

	if(!g_IsAlive[iId])
		return;

	entity_set_float(iId, EV_FL_renderamt, 255.0);

	if(g_HatId[iId])
	{
		if(is_valid_ent(g_HatEnt[iId]))
		{
			entity_set_int(g_HatEnt[iId], EV_INT_rendermode, kRenderNormal);
			entity_set_float(g_HatEnt[iId], EV_FL_renderamt, 255.0);
		}
	}

	if(g_SpecialMode[iId] == MODE_AVSP && g_SpecialMode_Predator[iId])
		client_print(0, print_center, "¡El DEPREDADOR se ha vuelto VISIBLE!");
	else
		client_print(0, print_center, "¡El FREDDY se ha vuelto VISIBLE!");
}

public task__RemovePowerAssassin(const task_id)
{
	static iId;
	iId = ID_POWER_ASSASSIN;

	if(!g_IsAlive[iId])
		return;

	set_user_rendering(iId);
}

public task__PowerSniper(const task_id)
{
	static iId;
	iId = ID_POWER_SNIPER;

	if(!g_IsAlive[iId] || !g_ModeSniper_Power[iId])
		return;

	g_ModeSniper_Power[iId] = 2;

	client_print(0, print_center, "¡El SNIPER perdió su DISPARO VELOZ!");

	if(g_CurrentWeapon[iId] == CSW_AWP)
	{
		strip_user_weapons(iId);
		give_item(iId, "weapon_knife");
		give_item(iId, "weapon_awp");
	}
	else
	{
		strip_user_weapons(iId);
		give_item(iId, "weapon_knife");
		give_item(iId, "weapon_scout");
	}
}

public task__RemoveImmunityBomb(const task_id)
{
	static iId;
	iId = ID_IMMUNITY_BOMB;

	if(!g_IsAlive[iId])
		return;

	client_print(iId, print_center, "¡Tu inmunidad se ha acabado!");

	g_Immunity[iId] = 0;

	set_user_rendering(iId);
}

public task__RemoveImmunityGunGame(const task_id)
{
	static iId;
	iId = ID_IMMUNITY_GG;

	if(!g_IsAlive[iId])
		return;

	set_user_rendering(iId);

	g_ModeGG_Immunity[iId] = 0;
}

public task__HealthRegeneration(const task_id)
{
	static iId;
	iId = ID_REGENERATION;

	if(!g_IsAlive[iId])
		return;

	static iPercent;
	static iTotal;

	iPercent = ((g_MaxHealth[iId] * 35) / 1000);
	iTotal = (g_Health[iId] + iPercent);

	if(iTotal >= g_MaxHealth[iId])
		return;

	static vecOrigin[3];
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

public task__RemoveHealthImmunity(const task_id)
{
	static iId;
	iId = ID_IMMUNITY_P;

	if(!g_IsAlive[iId])
		return;

	set_user_rendering(iId);

	g_Immunity[iId] = 0;
	g_Frozen[iId] = 0;
	g_Petrification[iId] = 0;

	ExecuteHamB(Ham_Player_ResetMaxSpeed, iId);
}

public task__SetUserNightVision(const task_id)
{
	static iId;
	iId = ID_NIGHTVISION;

	if(!g_IsConnected[iId] || !g_NightVision[iId])
	{
		remove_task(task_id);
		return;
	}

	static vecOrigin[3];
	get_user_origin(iId, vecOrigin);

	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, iId);
	write_byte(TE_DLIGHT);
	write_coord(vecOrigin[0]);
	write_coord(vecOrigin[1]);
	write_coord(vecOrigin[2]);
	if(g_SpecialMode[iId] == MODE_GRUNT)
		write_byte(30);
	else
		write_byte(60);
	if(g_Immunity[iId] && g_Petrification[iId])
	{
		write_byte(64);
		write_byte(64);
		write_byte(64);
	}
	else if(g_Immunity[iId] || (g_Mode == MODE_NEMESIS && !g_SpecialMode[iId]) || g_SpecialMode[iId] == MODE_NEMESIS)
	{
		write_byte(255);
		write_byte(0);
		write_byte(0);
	}
	else if(g_SpecialMode[iId] == MODE_ASSASSIN)
	{
		write_byte(255);
		write_byte(255);
		write_byte(255);
	}
	else if(g_SpecialMode[iId] == MODE_GRUNT)
	{
		write_byte(198);
		write_byte(226);
		write_byte(255);
	}
	else
	{
		write_byte(g_UserOption_Color[iId][COLOR_TYPE_NVISION][0]);
		write_byte(g_UserOption_Color[iId][COLOR_TYPE_NVISION][1]);
		write_byte(g_UserOption_Color[iId][COLOR_TYPE_NVISION][2]);
	}
	write_byte(7);
	write_byte(7);
	message_end();
}

public task__MolotovEffect(const task_id)
{
	static iEnt;
	iEnt = ID_MOLOTOV_EFFECT;

	if(!is_valid_ent(iEnt))
	{
		remove_task(task_id);
		return;
	}

	static Float:vecOrigin[3];
	entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_Flame);
	write_byte(1);
	write_byte(255);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SMOKE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, (vecOrigin[2] - 10.0));
	write_short(g_Sprite_Smoke);
	write_byte(5);
	write_byte(10);
	message_end();
}

public task__MolotovDamage(const args[], const task_id)
{
	static iId;
	iId = ID_MOLOTOV_EFFECT;

	if(!g_IsConnected[iId])
	{
		remove_task(task_id);
		return;
	}

	static vecOriginInt[3];
	static Float:vecEntOrigin[3];
	static Float:vecFireOrigin[3];

	vecOriginInt[0] = args[0];
	vecOriginInt[1] = args[1];
	vecOriginInt[2] = args[2];

	IVecFVec(vecOriginInt, vecEntOrigin);

	for(new i = 1; i <= 5; ++i)
	{
		vecFireOrigin[0] = vecEntOrigin[0] + random_float(-125.0, 125.0);
		vecFireOrigin[1] = vecEntOrigin[1] + random_float(-125.0, 125.0);
		vecFireOrigin[2] = vecEntOrigin[2];

		while(get_distance_f(vecFireOrigin, vecEntOrigin) >= 125.0) 
		{
			vecFireOrigin[0] = vecEntOrigin[0] + random_float(-125.0, 125.0);
			vecFireOrigin[1] = vecEntOrigin[1] + random_float(-125.0, 125.0);
			vecFireOrigin[2] = vecEntOrigin[2];
		}

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecFireOrigin, 0);
		write_byte(TE_SPRITE);
		engfunc(EngFunc_WriteCoord, vecFireOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecFireOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecFireOrigin[2]);
		write_short(g_Sprite_Flame);
		write_byte(random_num(1, 5));
		write_byte(255);
		message_end();

		if(!(i % 4))
		{
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecFireOrigin, 0);
			write_byte(TE_SMOKE);
			engfunc(EngFunc_WriteCoord, vecFireOrigin[0]);
			engfunc(EngFunc_WriteCoord, vecFireOrigin[1]);
			engfunc(EngFunc_WriteCoord, vecFireOrigin[2] + 5.0);
			write_short(g_Sprite_Smoke);
			write_byte(random_num(5, 25));
			write_byte(random_num(5, 25));
			message_end();
		}
	}

	static Float:vecOrigin[3];
	static Float:flDistance;
	static iDamage;
	static i;

	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i] || !g_Zombie[i] || g_SpecialMode[i])
			continue;

		entity_get_vector(i, EV_VEC_origin, vecOrigin);
		flDistance = get_distance_f(vecEntOrigin, vecOrigin);

		if(flDistance >= 250.0)
			continue;

		iDamage = (g_Health[i] - 1500);

		if(iDamage <= 0)
			ExecuteHamB(Ham_Killed, i, iId, 0);
		else
		{
			set_user_health(i, iDamage);
			g_Health[i] = iDamage;

			burningUser(i, iId, 0, 15);
		}
	}
}

public task__DrugEffect(const task_id)
{
	static iId;
	iId = ID_DRUG;

	if(!g_IsConnected[iId])
	{
		remove_task(task_id);
		return;
	}

	if(random_num(0, 1) == 1)
	{
		g_DrugBombMove[iId] = 1;

		client_print(iId, print_center, "¡ESTÁS RE DURO!");

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iId);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_IN);
		write_byte(random_num(50, 200));
		write_byte(random_num(50, 200));
		write_byte(random_num(50, 200));
		write_byte(random_num(100, 175));
		message_end();

		static Float:vecVelocity[3];

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
	
	if(g_DrugBombCount[iId] == 20)
	{
		give_item(iId, "weapon_knife");
		
		g_DrugBombCount[iId] = 0;
		g_DrugBombMove[iId] = 0;
	}
}

public task__GrabOn(const task_id)
{
	static iId;
	iId = ID_GRAB;

	if(!g_IsConnected[iId])
		return;

	static iTarget;
	static iBody;

	get_user_aiming(iId, iTarget, iBody);

	if(isUserValidAlive(iTarget) && iTarget != iId)
	{
		if(iTarget <= g_MaxPlayers)
		{
			if(isUserValidAlive(iTarget))
				grabUser(iId, iTarget);
		}
		else if(entity_get_int(iTarget, EV_INT_solid) != SOLID_BSP)
			grabUser(iId, iTarget);
	}
	else
	{
		remove_task(iId + TASK_GRAB);
		set_task(0.1, "task__GrabOn", iId + TASK_GRAB);
	}
}

public task__GrabPrethink(const task_id)
{
	static iId;
	iId = ID_GRAB_PRETHINK;

	if(!g_IsConnected[iId] && g_Grab[iId] > 0)
	{
		if(g_Grab[iId] <= g_MaxPlayers && isUserValidAlive(g_Grab[iId]))
			set_user_gravity(g_Grab[iId], g_GrabGravity[g_Grab[iId]]);

		g_Grab[iId] = 0;
	}

	if(g_Grab[iId] <= 0)
	{
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

	if(!g_GrabDistance[iId])
	{
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

public task__ModeGruntAiming(const task_id)
{
	static iId;
	iId = ID_GRUNT_AIMING;

	if(!g_IsAlive[iId] || !g_ModeGrunt_RewardGlobal)
		return;

	static sExp[16];
	addDot(g_ModeGrunt_Reward[iId], sExp, charsmax(sExp));

	set_hudmessage(198, 226, 255, g_UserOption_PositionHud[iId][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[iId][HUD_TYPE_COMBO][1], g_UserOption_EffectHud[iId][HUD_TYPE_COMBO], 0.0, 5.0, 0.0, 0.0, -1);
	ShowSyncHudMsg(iId, g_HudSync_Combo, "Estás ganando +%s XP", sExp);

	if(g_Mode == MODE_GRUNT && !g_ModeGrunt_NoDamage)
	{
		if(g_SpecialMode[iId] != MODE_GRUNT)
		{
			static iReward;
			static iTotalReward;

			if(getZombies() == 2)
				iReward = (((!g_ModeGrunt_Flash[iId]) ? 200000 : 400000) * (g_Reset[iId] + 1));
			else
				iReward = (((!g_ModeGrunt_Flash[iId]) ? 75000 : 150000) * (g_Reset[iId] + 1));

			iTotalReward = (g_ModeGrunt_Reward[iId] + iReward);

			if(iTotalReward < 0 || iTotalReward > MAX_XP)
			{
				addXP(iId, g_ModeGrunt_Reward[iId]);
				g_ModeGrunt_Reward[iId] = 0;
			}
			else
				g_ModeGrunt_Reward[iId] += iReward;
		}
		else
			g_ModeGrunt_Reward[iId] -= g_ModeGrunt_RewardGlobal;
		
		static iTarget;
		static iBody;
		
		get_user_aiming(iId, iTarget, iBody, 750);
		
		if(!isUserValidAlive(iTarget))
		{
			set_task(0.2, "task__ModeGruntAiming", iId + TASK_GRUNT_AIMING);
			return;
		}
		
		if(g_SpecialMode[iId] != MODE_GRUNT)
		{
			if(g_SpecialMode[iTarget] == MODE_GRUNT)
			{
				set_user_rendering(iId, kRenderFxGlowShell, 198, 226, 255, kRenderNormal, 125);
				
				if((g_Health[iId] - 40) >= 1)
				{
					set_user_health(iId, (g_Health[iId] - 40));
					--g_Health[iId];

					emitSound(iId, CHAN_VOICE, SOUND_ARMOR_HIT);
				}
				else
					ExecuteHam(Ham_TakeDamage, iId, iTarget, iTarget, 40.0, DMG_CRUSH);

				remove_task(iId + TASK_GRUNT_GLOW);
				set_task(0.25, "task__RemoveGruntGlow", iId + TASK_GRUNT_GLOW);
			}
		}
		else
		{
			set_user_rendering(iTarget, kRenderFxGlowShell, 198, 226, 255, kRenderNormal, 125);

			if((g_Health[iTarget] - 40) >= 1)
			{
				set_user_health(iTarget, (g_Health[iTarget] - 40));
				--g_Health[iTarget];

				emitSound(iTarget, CHAN_VOICE, SOUND_ARMOR_HIT);
			}
			else
				ExecuteHam(Ham_TakeDamage, iTarget, iId, iId, 40.0, DMG_CRUSH);

			remove_task(iTarget + TASK_GRUNT_GLOW);
			set_task(0.25, "task__RemoveGruntGlow", iTarget + TASK_GRUNT_GLOW);
		}
	}

	remove_task(iId + TASK_GRUNT_AIMING);
	set_task(0.2, "task__ModeGruntAiming", iId + TASK_GRUNT_AIMING);
}

public task__RemoveGruntScreenFade(const id)
{
	if(!g_IsConnected[id])
		return;

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i])
			continue;

		turnOffFlashlight(i);
		g_ModeGrunt_Flash[i] = 0;

		if(g_SpecialMode[i] == MODE_GRUNT)
			continue;

		g_Speed[i] = 1.0;
		set_user_gravity(i, 1.25);

		ExecuteHamB(Ham_Player_ResetMaxSpeed, i);
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

public task__RemoveGruntGlow(const task_id)
	set_user_rendering(ID_GRUNT_GLOW);

public task__StartModeArmageddon()
{
	switch(g_ModeArmageddon_Notice)
	{
		case 0:
		{
			playSound(0, SOUND_ROUND_ARMAGEDDON);

			g_ModeArmageddon_Notice = 1;

			remove_task(TASK_MODE_ARMAGEDDON);
			set_task(0.9, "task__StartModeArmageddon", TASK_MODE_ARMAGEDDON);
		}
		case 1:
		{
			g_ModeArmageddon_Notice = 2;

			static j;
			j = random_num(0, 1);

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				if(j)
				{
					if(getUserTeam(i) == F_TEAM_T)
						humanMe(i, .survivor=1);
					else
						zombieMe(i, .nemesis=1);
				}
				else
				{
					if(getUserTeam(i) == F_TEAM_T)
						zombieMe(i, .nemesis=1);
					else
						humanMe(i, .survivor=1);
				}

				strip_user_weapons(i);
			}

			remove_task(TASK_MODE_ARMAGEDDON);
			set_task(8.45, "task__StartModeArmageddon", TASK_MODE_ARMAGEDDON);
		}
		case 2:
		{
			showDHUDMessage(0, random(256), random(256), random(256), -1.0, -1.0, random_num(0, 1), 10.0, "¡ARMAGEDDON!");

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				randomSpawn(i);

				message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, i);
				write_short((UNIT_SECOND) * 2);
				write_short(0);
				write_short(FFADE_IN);
				write_byte(g_UserOption_Color[i][COLOR_TYPE_NVISION][0]);
				write_byte(g_UserOption_Color[i][COLOR_TYPE_NVISION][1]);
				write_byte(g_UserOption_Color[i][COLOR_TYPE_NVISION][2]);
				write_byte(255);
				message_end();

				if(g_Zombie[i])
					zombieMe(i, .nemesis=1);
				else
					humanMe(i, .survivor=1);
			}
		}
	}
}

public task__StartModeMegaArmageddon()
{
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

	static iMaxHumans;
	static iHumans;
	static iId;
	static iAlreadyChoosen[MAX_USERS];

	iMaxHumans = (getAlives() / 2);
	iHumans = 0;

	while(iHumans < iMaxHumans)
	{
		iId = getRandomUser(.alive=1);

		if(iAlreadyChoosen[iId])
			continue;

		iAlreadyChoosen[iId] = 1;
		++iHumans;
	}

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i])
			continue;

		randomSpawn(i);

		if(iAlreadyChoosen[i])
		{
			if(getUserTeam(i) == F_TEAM_T)
			{
				remove_task(i + TASK_TEAM);

				setUserTeam(i, F_TEAM_CT);
				setUserTeamUpdate(i);
			}

			buyGrenades(i);
		}
		else
			zombieMe(i);
	}
}

public task__ModeMegaGunGameCountDown()
{
	if(!g_ModeMGG_CountDown)
	{
		remove_task(TASK_MODE_MEGA_GUNGAME);

		g_ModeMGG_Phase = 1;
		g_ModeMGG_Block = 0;

		g_Lights[0] = MEGA_GUNGAME_LIGHTS[g_ModeMGG_CountDown];
		changeLights();

		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsAlive[i])
				continue;

			give_item(i, MEGA_GUNGAME_WEAPONS[g_ModeGG_Level[i]]);

			if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]] != 0)
			{
				if(MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]] != CSW_HEGRENADE)
					ExecuteHamB(Ham_GiveAmmo, i, MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]], AMMO_TYPE[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]], MAX_BPAMMO[MEGA_GUNGAME_WEAPONS_CSW[g_ModeGG_Level[i]]]);
				else
					cs_set_user_bpammo(i, CSW_HEGRENADE, 200);
			}

			ExecuteHamB(Ham_Player_ResetMaxSpeed, i);
		}

		client_print(0, print_center, "¡GO!");
		return;
	}

	g_Lights[0] = MEGA_GUNGAME_LIGHTS[g_ModeMGG_CountDown];
	changeLights();

	client_print(0, print_center, "¡FASE FINAL EN %d SEGUNDO%s!", g_ModeMGG_CountDown, (g_ModeMGG_CountDown != 1) ? "S" : "");

	--g_ModeMGG_CountDown;

	set_task(1.0, "task__ModeMegaGunGameCountDown", TASK_MODE_MEGA_GUNGAME);
}

public task__StartModeFvsJ()
{
	showDHUDMessage(0, random(256), random(256), random(256), -1.0, -1.0, random_num(0, 1), 10.0, "¡FREDDY vs JASON!");

	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND);
	write_short(UNIT_SECOND);
	write_short(FFADE_IN);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(150);
	message_end();

	new iId;
	new iFreddys = 0;
	new j = 0;

	if(isUserValid(g_ModeFvsJ_Id[3]))
		iId = g_ModeFvsJ_Id[3];
	else
		iId = getRandomUser(1);

	humanMe(iId, .fvsj_jason=1);

	while(iFreddys < 3)
	{
		if(isUserValid(g_ModeFvsJ_Id[iFreddys]))
			iId = g_ModeFvsJ_Id[iFreddys];
		else
			iId = getRandomUser(1);

		if(g_SpecialMode[iId] == MODE_FVSJ)
			continue;

		++iFreddys;
		zombieMe(iId, .freddy=iFreddys);

		++g_Stats[iId][STAT_F_M_C];
	}

	for(new i = 1; i <= g_MaxPlayers; ++i)
	{
		if(!g_IsAlive[i])
			continue;

		randomSpawn(i);

		if(g_SpecialMode[i] == MODE_FVSJ || g_Zombie[i])
			continue;

		humanMe(i);

		g_UnlimitedClip[i] = 1;

		++j;
	}

	g_ModeFvsJ_Humans = (j * 5);

	for(new m = 0; m < 4; ++m)
	{
		if(g_ModeFvsJ_Id[m])
			g_ModeFvsJ_Id[m] = 0;
	}
}

public task__ModeDuelFinal()
{
	static iPosition[33];

	if(g_ModeDuelFinal == DF_QUARTER || g_ModeDuelFinal == DF_SEMIFINAL || g_ModeDuelFinal == DF_FINAL)
	{
		static iTemp;
		iTemp = 0;

		for(new i = 1; i <= g_MaxPlayers; ++i)
			iPosition[i] = i;

		for(new i = 1; i < 32; ++i)
		{
			for(new j = (i + 1); j < 33; ++j)
			{
				if(g_ModeDuelFinal_Kills[j] > g_ModeDuelFinal_Kills[i])
				{
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

	static iHumans;
	iHumans = 0;

	switch(g_ModeDuelFinal)
	{
		case DF_QUARTER:
		{
			g_Lights[0] = 'f';

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 5.0, "¡DUELO FINAL%s!^nCUARTOS DE FINAL", g_ModeDuelFinal_TypeName);
			playSound(0, SOUND_ROUND_SPECIAL);

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(iHumans == 8)
					break;

				if(g_IsConnected[iPosition[i]] && g_AccountLogged[iPosition[i]] && !g_IsAlive[iPosition[i]])
				{
					ExecuteHamB(Ham_CS_RoundRespawn, iPosition[i]);
					++iHumans;
				}
			}
		}
		case DF_SEMIFINAL:
		{
			g_Lights[0] = 'd';

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 5.0, "¡DUELO FINAL%s!^nSEMIFINAL", g_ModeDuelFinal_TypeName);
			playSound(0, SOUND_ROUND_SPECIAL);

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(iHumans == 4)
					break;

				if(g_IsConnected[iPosition[i]] && g_AccountLogged[iPosition[i]] && !g_IsAlive[iPosition[i]])
				{
					ExecuteHamB(Ham_CS_RoundRespawn, iPosition[i]);
					++iHumans;
				}
			}
		}
		case DF_FINAL:
		{
			g_Lights[0] = 'b';

			showDHUDMessage(0, 0, 255, 0, -1.0, 0.25, 0, 5.0, "¡DUELO FINAL%s!^nFINAL", g_ModeDuelFinal_TypeName);
			playSound(0, SOUND_ROUND_SPECIAL);

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(iHumans == 2)
					break;

				if(g_IsConnected[iPosition[i]] && g_AccountLogged[iPosition[i]] && !g_IsAlive[iPosition[i]])
				{
					ExecuteHamB(Ham_CS_RoundRespawn, iPosition[i]);
					++iHumans;
				}
			}
		}
		case DF_FINISH:
		{
			g_ModeDuelFinal_Type = 0;
			g_ModeDuelFinal_TypeName[0] = EOS;

			static iReward;
			static sReward[16];

			iReward = 0;
			sReward[0] = EOS;

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsConnected[i])
					continue;

				g_ModeDuelFinal_KillsKnife[i] = 0;
				g_ModeDuelFinal_KillsAwp[i] = 0;
				g_ModeDuelFinal_KillsHE[i] = 0;
				g_ModeDuelFinal_KillsDeagle[i] = 0;
				g_ModeDuelFinal_KillsM3[i] = 0;

				if(!g_AccountLogged[i])
					continue;

				if(g_ModeDuelFinal_KillsTotal[i])
				{
					iReward = (g_ModeDuelFinal_KillsTotal[i] * (50 * getLevelTotal(i)) * (1 + g_Reset[i])) * (g_ExpMult[i] * 5);

					if((get_user_flags(i) & ADMIN_RESERVATION) || g_Benefit[i] > 1)
						iReward *= 2;

					iReward = clamp(iReward, 0, MAX_XP);
					addDot(iReward, sReward, charsmax(sReward));

					dg_color_chat(i, _, "Ganaste !g%s XP!y por matar a !g%d humano%s!y", sReward, g_ModeDuelFinal_KillsTotal[i], ((g_ModeDuelFinal_KillsTotal[i] != 1) ? "s" : ""));
					addXP(i, iReward);
				}
				else
					dg_color_chat(i, _, "No recibiste ganancias porque no has matado a ningún humano");
			}

			set_cvar_num("mp_round_infinite", 0);

			for(new i = 1; i <= g_MaxPlayers; ++i)
			{
				if(!g_IsAlive[i])
					continue;

				++g_Stats[i][STAT_DUEL_FINAL_WINS];

				if(g_Stats[i][STAT_DUEL_FINAL_WINS] == 1)
					setAchievement(i, MI_PRIMER_DUELO);
				else if(g_Stats[i][STAT_DUEL_FINAL_WINS] == 5)
					setAchievement(i, VAMOS_BIEN);
				else if(g_Stats[i][STAT_DUEL_FINAL_WINS] == 10)
					setAchievement(i, DEMASIADO_FACIL);

				user_kill(i, 1);
				break;
			}
		}
	}

	changeLights();

	for(new i = 1; i <= g_MaxPlayers; ++i)
		g_ModeDuelFinal_Kills[i] = 0;
}

public task__SpecNightvision(const id)
{
	if(!g_IsConnected[id] || g_IsAlive[id])
		return;
	
	setUserNightVision(id, 1);
}

public task__MegaArmageddonEffect(const id)
{
	if(g_IsAlive[id])
	{
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

public task__MegaArmageddonBlackFade(const id)
{
	if(g_IsAlive[id])
	{
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

// **************************************************
//		[SQL Functions]
// **************************************************
public sqlThread__CheckClanName(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time)
{
	static iId;
	iId = data[0];
	
	if(!g_IsConnected[iId])
		return;

	switch(fail_state)
	{
		case TQUERY_CONNECT_FAILED: return;
		case TQUERY_QUERY_FAILED: dg_log_to_file(LOG_MYSQL, 1, iId, "sqlThread__CheckClanName - %d - %s", error_num, error);
		case TQUERY_SUCCESS:
		{
			if(!SQL_NumResults(query))
			{
				static iClanSlot;
				iClanSlot = clanFindSlot();

				if(!iClanSlot)
				{
					showMenu__Clan(iId);
					return;
				}

				static Handle:sqlQuery;
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_clans (clan_name, clan_since) VALUES (^"%s^", UNIX_TIMESTAMP());", g_TempClanName[iId]);
				
				if(!SQL_Execute(sqlQuery))
					executeQuery(iId, sqlQuery, 77);
				else
				{
					SQL_FreeHandle(sqlQuery);
					
					sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id FROM zp6_clans ORDER BY id DESC LIMIT 1;");
					
					if(!SQL_Execute(sqlQuery))
						executeQuery(iId, sqlQuery, 78);
					else
					{
						static iClanId;
						iClanId = SQL_ReadResult(sqlQuery, 0);
						
						SQL_FreeHandle(sqlQuery);
						
						sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_clans_members (clan_id, acc_id, owner, since, last_connection) VALUES ('%d', '%d', '1', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());", iClanId, g_AccountId[iId]);
						
						if(!SQL_Execute(sqlQuery))
							executeQuery(iId, sqlQuery, 79);
						else
						{
							SQL_FreeHandle(sqlQuery);

							sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_pjs SET clan_id='%d' WHERE acc_id='%d';", iClanId, g_AccountId[iId]);

							if(!SQL_Execute(sqlQuery))
								executeQuery(iId, sqlQuery, 80);
							else
								SQL_FreeHandle(sqlQuery);
							
							g_ClanSlot[iId] = iClanSlot;

							g_Clan[g_ClanSlot[iId]][clanId] = iClanId;
							copy(g_Clan[g_ClanSlot[iId]][clanName], 31, g_TempClanName[iId]);
							g_Clan[g_ClanSlot[iId]][clanDeposit] = 0;
							g_Clan[g_ClanSlot[iId]][clanSince] = (get_systime() - 10800);
							g_Clan[g_ClanSlot[iId]][clanVictory] = 0;
							g_Clan[g_ClanSlot[iId]][clanVictoryConsec] = 0;
							g_Clan[g_ClanSlot[iId]][clanVictoryConsecHistory] = 0;
							g_Clan[g_ClanSlot[iId]][clanChampion] = 0;
							g_Clan[g_ClanSlot[iId]][clanRank] = 0;
							g_Clan[g_ClanSlot[iId]][clanCountMembers] = 1;
							g_Clan[g_ClanSlot[iId]][clanCountOnlineMembers] = 1;
							
							resetDataClanMembers(g_ClanSlot[iId]);

							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberId] = g_AccountId[iId];
							copy(g_ClanMembers[g_ClanSlot[iId]][0][clanMemberName], 31, g_PlayerName[iId]);
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberOwner] = 1;
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberSinceDay] = 0;
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberSinceHour] = 0;
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberSinceMinute] = 0;
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLastTimeDay] = 0;
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLastTimeHour] = 0;
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLastTimeMinute] = 0;
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLevel] = g_Level[iId];
							g_ClanMembers[g_ClanSlot[iId]][0][clanMemberReset] = g_Reset[iId];
							
							dg_color_chat(0, _, "!t%s!y creo el clan !g%s!y", g_PlayerName[iId], g_Clan[g_ClanSlot[iId]][clanName]);
							showMenu__Clan(iId);
						}
					}
				}
			}
			else
			{
				dg_color_chat(iId, _, "Ese nombre de clan ya existe, elija otro por favor");
				showMenu__Clan(iId);
			}
		}
	}

	server_print("sqlThread__CheckClanName - queue_time - %0.2f", queue_time);
}

public sqlThread__Updates(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time)
{
	static iId;
	iId = data[0];
	
	if(!g_IsConnected[iId])
		return;

	static iMemberId;
	iMemberId = data[2];

	switch(fail_state)
	{
		case TQUERY_CONNECT_FAILED: return;
		case TQUERY_QUERY_FAILED: dg_log_to_file(LOG_MYSQL, 1, iId, "sqlThread__Updates - %d - %s", error_num, error);
		case TQUERY_SUCCESS:
		{
			switch(data[1])
			{
				case 0:
				{
					dg_color_chat(iId, _, "!t%s!y ha sido degradado a !tMiembro!y", g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberName]);
					g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberOwner] = 0;
				}
				case 1:
				{
					dg_color_chat(iId, _, "!t%s!y ha sido promovido a !tDueño!y", g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberName]);
					g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberOwner] = 1;
				}
			}
		}
	}

	showMenu__ClanMemberInfo(iId, iMemberId);
}

showMenu__Amulets(const id, amulet=-1, amulet_name[]="")
{
	if(amulet == -1 && !amulet_name[0])
	{
		oldmenu_create("\yAMULETOS^n\wPuntos especiales\r:\y %d", "menu__Amulets", g_Points[id][POINT_SPECIAL]);
		
		if(!g_AmuletCustomCreated[id])
		{
			if(g_Points[id][POINT_SPECIAL] >= 25)
				oldmenu_additem(1, 1, "\r1.\w Crear amuleto \y(25 pE)");
			else
				oldmenu_additem(-1, -1, "\d1. Crear amuleto \r(25 pE)");

			if(g_Points[id][POINT_SPECIAL] >= 75)
				oldmenu_additem(2, 2, "\r2.\w Crear amuleto [PRO] \y(75 pE)");
			else
				oldmenu_additem(-1, -1, "\d2. Crear amuleto [PRO] \r(75 pE)");
		}
		else
		{
			oldmenu_additem(-1, -1, "\d1. Crear amuleto");
			oldmenu_additem(-1, -1, "\d2. Crear amuleto [PRO]");
		}

		new i;
		new j;
		new k = 0;

		for(i = 0, j = 4; i < MAX_AMULETS; ++i, ++j)
		{
			if(g_AmuletsName[id][i][0])
				oldmenu_additem(j, i, "\r%d.\w %s%s", j, g_AmuletsName[id][i], (g_AmuletEquip[id] == i) ? "\y (EQUIPADO)" : (g_AmuletNextEquip[id] == i) ? "\y (ELEGIDO)" : "");
			else
				++k;
		}

		if(k == MAX_AMULETS)
		{
			oldmenu_additem(-1, -1, "^n\wLos amuletos te otorgan de manera aleatoria \yhabilidades extras");
			oldmenu_additem(-1, -1, "\wy \ymultiplicadores\w que pueden ser \yPOSITIVOS\w o \rNEGATIVOS\w");
			
			oldmenu_additem(9, 9, "^n\r9.\w Amuleto personalizado");
		}
		else
		{
			oldmenu_additem(-1, -1, "^n\d9. No puedes crear amuletos personalizados");
			oldmenu_additem(-1, -1, "\r - \dPara crear uno, debes vender tus amuletos comunes");
			oldmenu_additem(-1, -1, "\r - \dDebes estar muy seguro de lo que estás haciendo para poder tener uno personalizado^n");
		}
		
		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	}
	else
	{
		oldmenu_create("\yAMULETO \r-\y %s", "menu__AmuletsIn", amulet_name);

		new const AMULETS_STATS_INT[][] = {"Vida", "Velocidad", "Gravedad", "Daño", "Multiplicador de APs", "Multiplicador de XP"};
		new i;

		for(i = 0; i < 6; ++i)
		{
			if(g_AmuletsInt[id][amulet][i] != 0)
				oldmenu_additem(-1, -1, "\w%s\r:%s%d%s", AMULETS_STATS_INT[i], (g_AmuletsInt[id][amulet][i] > 0) ? "\y +" : "\d -", abs(g_AmuletsInt[id][amulet][i]), (i == 3) ? "^n" : "");
		}

		oldmenu_additem(1, 1, "\r1.\w Vender amuleto");
		oldmenu_additem(2, 2, "\r2.\w %squipar amuleto^n", (g_AmuletEquip[id] != amulet) ? "E" : "Dese");

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);

		copy(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), amulet_name);
	}
}

public getSlotAmulet(const id)
{
	new i;
	for(i = 0; i < MAX_AMULETS; ++i)
	{
		if(!g_AmuletsName[id][i][0])
			return i;
	}
	
	return -1;
}

new const AMULETS_NAMES[][] =
{
	"ROSA DE LOS VIENTOS", "MARCA DE JO", "FUERZA DE LOS VIENTOS", "OLEADA", "BARREDOR HEXTECH", "CATALIZADOR PROTECTOR", "CHALECO DE CADENAS", "CORAZON DE HIELO", "CRISTAL DE RUBI", "EMBLEMA DE VALOR",
	"MEDALLON DE HIERRO", "PERLA DEL REJUVENECIMIENTO", "PICO DE LA SUERTE", "PIEDRA FILOSOFAL", "PETRINA DE DOMINAMUNDOS", "RAICES DE DOLOR", "SELLO EVOLUTIVO DE RA DEN", "ATADURAS DE FUEGO COSMICO", "ARMADURA DE VALOR", "ESCUDO DE LA ESPERANZA",
	"RUNA DIVINA", "BASTON ANTIGUO", "ELIXIR DE DEFENSA", "ELIXIR DE FUERZA", "OJO DE VENGANZA", "GEMA DE AISLAMIENTO", "FAJA DE PODER", "MANO DE LOS DIOSES", "MARCA DE LA VANGUARDIA", "CORREA DE LOS LAMENTOS",
	"MASCARA MISTICA", "FRAGMENTO DE OBSIDIANA", "COLLAR DE PURIFICACION", "VARA DE LA PERDICION", "PIEDRA EMBRUJADA", "HONOR", "RESISTENCIA DEL LOBO", "PIEDRA DEL DRAGON", "MARCA DEL PRINCIPIANTE", "FURIA DEL GUARDIAN",
	"MANIPULADOR DE EDADES", "GRAN TALISMAN", "ORNAMENTO REFRESCANTE", "RESTAURACION DE LA PIEDRA LUNAR", "CABELLO DE LA MADRE DEMONIACA", "ALAS DEL DESTINO", "ABRAZO DE SERAFIN", "ANTORCHA DE FUEGO NEGRO", "FRAGMENTO DE HORROCRUXES", "ESCARABAJO EGIPCIO",
	"RESGUARDO LUNAR", "COLLAR DE PITUSA", "OJO DE ETLICH", "RELICARIO DE RONAL", "TALISMAN DE ARANOCH", "LUZ SAGRADA", "LA ESENCIA DEL TIEMPO", "ORO DE KYMBO", "ESTRELLA DE AZKARANTH", "UROBORO LEGENDARIO",
	"AMULETO DE XEPHIRIA", "CALEIDOSCOPIO DE MARA", "CRUZ DE DUNCRAIG", "LEALTAD DE TAL RASHA", "SIGNO DEL VIAJERO", "BARBA DEL ENANO RAIMOND", "ESCAMA DEL DRAGON AZUL", "FRAGMENTO DE FLAUTA PETRIFICADA", "MELENA DE ASLAN", "TALISMAN DE CASPIAN",
	"DIENTE DE NASHOR", "SOMBRERO DEL MAGO HIBRIDO", "GARRA DEL LICANTROPO", "ANTIGUO COLMILLO SANGRIENTO", "OVEJA CLANDESTINA SALTEÑA", "RELOJ DE ZHONYA", "TU VIEJA EN TANGA"
};

public menu__Amulets(const id, const item, const value)
{
	switch(item)
	{
		case 0: showMenu__Game(id);
		case 1:
		{
			if(g_AmuletCustomCreated[id])
			{
				dg_color_chat(id, _, "Ya tienes un amuleto personalizado, no hace falta que te vuelvas a crear otro");

				showMenu__Amulets(id);
				return PLUGIN_HANDLED;
			}

			if(g_Points[id][POINT_SPECIAL] < 25)
			{
				dg_color_chat(id, _, "No tienes puntos especiales suficientes para crear un amuleto");

				showMenu__Amulets(id);
				return PLUGIN_HANDLED;
			}

			new iSlot;
			iSlot = getSlotAmulet(id);
			
			if(iSlot == -1)
			{
				dg_color_chat(id, _, "No puedes tener más de 5 amuletos al mismo tiempo");

				showMenu__Amulets(id);
				return PLUGIN_HANDLED;
			}

			g_Points[id][POINT_SPECIAL] -= 25;

			new i;
			new k;
			new j;
			new iRand;

			for(i = 0; i < 10; ++i)
			{
				k = 0;

				iRand = random_num(0, charsmax(AMULETS_NAMES));
				formatex(g_AmuletsName[id][iSlot], charsmax(g_AmuletsName[][]), "%s", AMULETS_NAMES[iRand]);

				for(j = 0; j < MAX_AMULETS; ++j)
				{
					if(j == iSlot)
						continue;

					if(equal(g_AmuletsName[id][j], g_AmuletsName[id][iSlot]))
					{			
						++k;
						break;
					}
				}

				if(!k)
					break;
			}

			g_AmuletsInt[id][iSlot][0] = random_num(-2, 2);
			g_AmuletsInt[id][iSlot][1] = random_num(-2, 2);
			g_AmuletsInt[id][iSlot][2] = random_num(-2, 2);
			g_AmuletsInt[id][iSlot][3] = random_num(-2, 2);
			g_AmuletsInt[id][iSlot][4] = random_num(-5, 5);
			g_AmuletsInt[id][iSlot][5] = random_num(-5, 5);

			new Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_amulets (acc_id, amulet_id, name, health, speed, gravity, damage, mult_aps, mult_xp, active) VALUES ('%d', '%d', ^"%s^", '%d', '%d', '%d', '%d', '%d', '%d', '1');",
			g_AccountId[id], iSlot, g_AmuletsName[id][iSlot], g_AmuletsInt[id][iSlot][0], g_AmuletsInt[id][iSlot][1], g_AmuletsInt[id][iSlot][2], g_AmuletsInt[id][iSlot][3], g_AmuletsInt[id][iSlot][4], g_AmuletsInt[id][iSlot][5]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 09090);
			else
				SQL_FreeHandle(sqlQuery);

			dg_color_chat(id, _, "Has creado el amuleto !g%s!y", g_AmuletsName[id][iSlot]);
			showMenu__Amulets(id);
		}
		case 2:
		{
			if(g_AmuletCustomCreated[id])
			{
				dg_color_chat(id, _, "Ya tienes un amuleto personalizado, no hace falta que te vuelvas a crear otro");

				showMenu__Amulets(id);
				return PLUGIN_HANDLED;
			}

			if(g_Points[id][POINT_SPECIAL] < 75)
			{
				dg_color_chat(id, _, "No tienes puntos especiales suficientes para crear un amuleto");

				showMenu__Amulets(id);
				return PLUGIN_HANDLED;
			}

			new iSlot;
			iSlot = getSlotAmulet(id);
			
			if(iSlot == -1)
			{
				dg_color_chat(id, _, "No puedes tener más de 5 amuletos al mismo tiempo");

				showMenu__Amulets(id);
				return PLUGIN_HANDLED;
			}

			g_Points[id][POINT_SPECIAL] -= 75;

			new i;
			new k;
			new j;
			new iRand;

			for(i = 0; i < 10; ++i)
			{
				k = 0;

				iRand = random_num(0, charsmax(AMULETS_NAMES));
				formatex(g_AmuletsName[id][iSlot], charsmax(g_AmuletsName[][]), "%s [PRO]", AMULETS_NAMES[iRand]);

				for(j = 0; j < MAX_AMULETS; ++j)
				{
					if(j == iSlot)
						continue;

					if(equal(g_AmuletsName[id][j], g_AmuletsName[id][iSlot]))
					{			
						++k;
						break;
					}
				}

				if(!k)
					break;
			}

			g_AmuletsInt[id][iSlot][0] = random_num(0, 2);
			g_AmuletsInt[id][iSlot][1] = random_num(0, 2);
			g_AmuletsInt[id][iSlot][2] = random_num(0, 2);
			g_AmuletsInt[id][iSlot][3] = random_num(0, 2);
			g_AmuletsInt[id][iSlot][4] = random_num(0, 5);
			g_AmuletsInt[id][iSlot][5] = random_num(0, 5);

			new Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO zp6_amulets (acc_id, amulet_id, name, health, speed, gravity, damage, mult_aps, mult_xp, active) VALUES ('%d', '%d', ^"%s^", '%d', '%d', '%d', '%d', '%d', '%d', '1');",
			g_AccountId[id], iSlot, g_AmuletsName[id][iSlot], g_AmuletsInt[id][iSlot][0], g_AmuletsInt[id][iSlot][1], g_AmuletsInt[id][iSlot][2], g_AmuletsInt[id][iSlot][3], g_AmuletsInt[id][iSlot][4], g_AmuletsInt[id][iSlot][5]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 99099);
			else
				SQL_FreeHandle(sqlQuery);

			dg_color_chat(id, _, "Has creado el amuleto !g%s!y", g_AmuletsName[id][iSlot]);
			showMenu__Amulets(id);
		}
		case 9:
		{
			if(g_AmuletCustomCreated[id])
				showMenu__AmuletCustom(id);
			else
				showMenu__AmuletCustom(id, 1);
		}
		default: showMenu__Amulets(id, value, g_AmuletsName[id][value]);
	}

	return PLUGIN_HANDLED;
}

public menu__AmuletsIn(const id, const item)
{
	switch(item)
	{
		case 0: showMenu__Amulets(id);
		case 1:
		{
			replace_all(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "\y (EQUIPADO)", "");
			replace_all(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "\y (ELEGIDO)", "");

			new i;
			for(i = 0; i < MAX_AMULETS; ++i)
			{
				if(equal(g_AmuletsName[id][i], g_AmuletsNameMenu[id]))
					break;
			}

			oldmenu_create("\yVENDER AMULETO", "menu__AmuletsDelete");

			oldmenu_additem(1, 1, "\r1.\w Si, quiero venderlo");
			oldmenu_additem(2, 2, "\r2.\w No, no quiero venderlo");

			oldmenu_display(id);
		}
		case 2:
		{
			replace_all(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "\y (EQUIPADO)", "");
			replace_all(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "\y (ELEGIDO)", "");

			new i;
			for(i = 0; i < MAX_AMULETS; ++i)
			{
				if(equal(g_AmuletsName[id][i], g_AmuletsNameMenu[id]))
					break;
			}

			if(g_AmuletEquip[id] == i)
			{
				g_AmuletEquip[id] = -1;

				dg_color_chat(id, _, "Has desequipido el amuleto !g%s!y", g_AmuletsName[id][i]);

				showMenu__Amulets(id);
				return PLUGIN_HANDLED;
			}

			g_AmuletNextEquip[id] = i;

			dg_color_chat(id, _, "Cuando vuelvas a renacer, tendrás equipado el amuleto !g%s!y", g_AmuletsName[id][i]);
			showMenu__Amulets(id);
		}
	}

	return PLUGIN_HANDLED;
}

public menu__AmuletsDelete(const id, const item)
{
	switch(item)
	{
		case 1:
		{
			replace_all(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "\y (EQUIPADO)", "");
			replace_all(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "\y (ELEGIDO)", "");

			new i;
			for(i = 0; i < MAX_AMULETS; ++i)
			{
				if(equal(g_AmuletsName[id][i], g_AmuletsNameMenu[id]))
					break;
			}

			new Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_amulets SET active='0' WHERE acc_id='%d' AND amulet_id='%d' AND active='1';", g_AccountId[id], i);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 09990);
			else
				SQL_FreeHandle(sqlQuery);

			if(containi(g_AmuletsName[id][i], "[PRO]") != -1)
			{
				dg_color_chat(id, _, "Has vendido el amuleto !g%s!y y se te ha devuelto !g35 pE!y", g_AmuletsName[id][i]);
				g_Points[id][POINT_SPECIAL] += 35;
			}
			else
			{
				dg_color_chat(id, _, "Has vendido el amuleto !g%s!y y se te ha devuelto !g10 pE!y", g_AmuletsName[id][i]);
				g_Points[id][POINT_SPECIAL] += 10;
			}

			if(g_AmuletEquip[id] == i)
				g_AmuletEquip[id] = -1;

			formatex(g_AmuletsName[id][i], charsmax(g_AmuletsName[][]), "");
			formatex(g_AmuletsNameMenu[id], charsmax(g_AmuletsNameMenu[]), "");

			showMenu__Amulets(id);
		}
		case 2: showMenu__Amulets(id);
	}

	return PLUGIN_HANDLED;
}

public clcmd__EnterAmuletCustomName(const id)
{
	if(!g_IsConnected[id] || !g_AccountLogged[id])
		return PLUGIN_HANDLED;

	if(g_AmuletCustomCreated[id])
	{
		dg_color_chat(id, _, "Ya creaste un amuleto personalizado, puedes chequearlo y modificarlo en el menú");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	static sAmuletCustomName[64];
	read_args(sAmuletCustomName, charsmax(sAmuletCustomName));
	remove_quotes(sAmuletCustomName);
	trim(sAmuletCustomName);

	if(getUserClanBadString(sAmuletCustomName)) // Uso la función de los clanes ya que se basa en la misma garcha los nombres
	{
		dg_color_chat(id, _, "Solo letras y algunos símbolos: !g( ) [ ] { } - = . , : !!y, se permiten espacios");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	static iLenAmuletCustomName;
	iLenAmuletCustomName = strlen(sAmuletCustomName);
	
	if(iLenAmuletCustomName < 3)
	{
		dg_color_chat(id, _, "El nombre del amuleto debe tener al menos 3 caracteres");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}
	else if(iLenAmuletCustomName > 32)
	{
		dg_color_chat(id, _, "l nombre del amuleto debe tener menos de 32 caracteres");

		showMenu__AmuletCustom(id);
		return PLUGIN_HANDLED;
	}

	copy(g_AmuletCustomNameFake[id], charsmax(g_AmuletCustomNameFake[]), sAmuletCustomName);

	showMenu__AmuletCustom(id);
	return PLUGIN_HANDLED;
}

showMenu__AmuletCustom(const id, const reset=0)
{
	if(g_AmuletCustomCreated[id])
	{
		oldmenu_create("\yAMULETO PERSONALIZADO^n\wNombre del amuleto\r:\y %s", "menu__AmuletCustom", g_AmuletCustomName[id]);

		if(g_AmuletCustom[id][acHealth]) oldmenu_additem(1, 1, "\r1.\w Vida\r:\y +%d", g_AmuletCustom[id][acHealth]);
		if(g_AmuletCustom[id][acSpeed]) oldmenu_additem(2, 2, "\r2.\w Velocidad\r:\y +%d", g_AmuletCustom[id][acSpeed]);
		if(g_AmuletCustom[id][acGravity]) oldmenu_additem(3, 3, "\r3.\w Gravedad\r:\y +%d", g_AmuletCustom[id][acGravity]);
		if(g_AmuletCustom[id][acDamage]) oldmenu_additem(4, 4, "\r4.\w Daño\r:\y +%d", g_AmuletCustom[id][acDamage]);

		if(g_AmuletCustom[id][acMultAPs])
			oldmenu_additem(5, 5, "^n\r5.\w Multiplicador de APs\r:\y +%d", g_AmuletCustom[id][acMultAPs]);
		else
			oldmenu_additem(-1, -1, "");
		if(g_AmuletCustom[id][acMultXP]) oldmenu_additem(6, 6, "\r6.\w Multiplicador de XP\r:\y +%d", g_AmuletCustom[id][acMultXP]);

		if(g_AmuletCustom[id][acRespawnHuman])
			oldmenu_additem(7, 7, "^n\r7.\w Respawn Humano\r:\y +%d%%", g_AmuletCustom[id][acRespawnHuman]);
		else
			oldmenu_additem(-1, -1, "");
		if(g_AmuletCustom[id][acReduceExtraItems]) oldmenu_additem(8, 8, "\r8.\w Reducción de Costo de Items Extra\r:\y +%d%%", g_AmuletCustom[id][acReduceExtraItems]);

		oldmenu_additem(9, 9, "^n\r9.\w Eliminar amuleto");
		oldmenu_additem(0, 0, "\r0.\w Volver");

		oldmenu_display(id);
	}
	else
	{
		if(reset)
		{
			g_AmuletCustomCost[id] = 10;
			g_AmuletCustomNameFake[id][0] = EOS;
			g_AmuletCustom[id][acHealth] = 1;
			g_AmuletCustom[id][acSpeed] = 1;
			g_AmuletCustom[id][acGravity] = 1;
			g_AmuletCustom[id][acDamage] = 1;
			g_AmuletCustom[id][acMultAPs] = 0;
			g_AmuletCustom[id][acMultXP] = 0;
			g_AmuletCustom[id][acRespawnHuman] = 0;
			g_AmuletCustom[id][acReduceExtraItems] = 0;

			dg_color_chat(id, _, "Cuando estés decidido a crear el amuleto personalizado, escribe en consola !gzp_ac_create!y. Pedirá confirmación, no te preocupes");
		}

		oldmenu_create("\yAMULETO PERSONALIZADO^n\wCosto\r:\y %d DIAMANTES", "menu__AmuletCustom", g_AmuletCustomCost[id]);

		oldmenu_additem(1, 1, "\r1.\w Nombre del amuleto\r:\y %s", ((g_AmuletCustomNameFake[id][0]) ? g_AmuletCustomNameFake[id] : "no-especificado"));

		oldmenu_additem(2, 2, "\r2.\w Vida\r:\y +%d", g_AmuletCustom[id][acHealth]);
		oldmenu_additem(3, 3, "\r3.\w Velocidad\r:\y +%d", g_AmuletCustom[id][acSpeed]);
		oldmenu_additem(4, 4, "\r4.\w Gravedad\r:\y +%d", g_AmuletCustom[id][acGravity]);
		oldmenu_additem(5, 5, "\r5.\w Daño\r:\y +%d^n", g_AmuletCustom[id][acDamage]);

		oldmenu_additem(6, 6, "\r6.\w Multiplicador de APs\r:\y +%d", g_AmuletCustom[id][acMultAPs]);
		oldmenu_additem(7, 7, "\r7.\w Multiplicador de XP\r:\y +%d", g_AmuletCustom[id][acMultXP]);

		oldmenu_additem(8, 8, "\r8.\w Respawn Humano\r:\y +%d%%", g_AmuletCustom[id][acRespawnHuman]);
		oldmenu_additem(9, 9, "\r9.\w Reducción de Costo de Items Extra\r:\y +%d%%", g_AmuletCustom[id][acReduceExtraItems]);

		oldmenu_additem(0, 0, "^n\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__AmuletCustom(const id, const item)
{
	if(g_AmuletCustomCreated[id])
	{
		switch(item)
		{
			case 1..8:
			{
				dg_color_chat(id, _, "Por ahora solo puedes visualizar tu amuleto, en las próximas actualizaciones podrás modificar los valores del mismo");
				showMenu__AmuletCustom(id);
			}
			case 9: showMenu__AmuletCustomDelete(id);
			case 0: showMenu__Amulets(id);
		}
	}
	else
	{
		switch(item)
		{
			case 1:
			{
				client_cmd(id, "messagemode INGRESAR_NOMBRE_AMULETO");
				return PLUGIN_HANDLED;
			}
			case 2:
			{
				if(g_AmuletCustom[id][acHealth] < 5)
				{
					++g_AmuletCustom[id][acHealth];
					g_AmuletCustomCost[id] += 2;
				}
				else
				{
					g_AmuletCustom[id][acHealth] = 1;
					g_AmuletCustomCost[id] -= 8;
				}
			}
			case 3:
			{
				if(g_AmuletCustom[id][acSpeed] < 5)
				{
					++g_AmuletCustom[id][acSpeed];
					g_AmuletCustomCost[id] += 3;
				}
				else
				{
					g_AmuletCustom[id][acSpeed] = 1;
					g_AmuletCustomCost[id] -= 12;
				}
			}
			case 4:
			{
				if(g_AmuletCustom[id][acGravity] < 5)
				{
					++g_AmuletCustom[id][acGravity];
					g_AmuletCustomCost[id] += 3;
				}
				else
				{
					g_AmuletCustom[id][acGravity] = 1;
					g_AmuletCustomCost[id] -= 12;
				}
			}
			case 5:
			{
				if(g_AmuletCustom[id][acDamage] < 5)
				{
					++g_AmuletCustom[id][acDamage];
					g_AmuletCustomCost[id] += 2;
				}
				else
				{
					g_AmuletCustom[id][acDamage] = 1;
					g_AmuletCustomCost[id] -= 8;
				}
			}
			case 6:
			{
				if(g_AmuletCustom[id][acMultAPs] < 5)
				{
					++g_AmuletCustom[id][acMultAPs];
					g_AmuletCustomCost[id] += 15;
				}
				else
				{
					g_AmuletCustom[id][acMultAPs] = 0;
					g_AmuletCustomCost[id] -= 75;
				}
			}
			case 7:
			{
				if(g_AmuletCustom[id][acMultXP] < 5)
				{
					++g_AmuletCustom[id][acMultXP];
					g_AmuletCustomCost[id] += 15;
				}
				else
				{
					g_AmuletCustom[id][acMultXP] = 0;
					g_AmuletCustomCost[id] -= 75;
				}
			}
			case 8:
			{
				if(g_AmuletCustom[id][acRespawnHuman] < 20)
				{
					g_AmuletCustom[id][acRespawnHuman] += 5;
					++g_AmuletCustomCost[id];
				}
				else
				{
					g_AmuletCustom[id][acRespawnHuman] = 0;
					g_AmuletCustomCost[id] -= 4;
				}
			}
			case 9:
			{
				if(g_AmuletCustom[id][acReduceExtraItems] < 20)
				{
					g_AmuletCustom[id][acReduceExtraItems] += 5;
					++g_AmuletCustomCost[id];
				}
				else
				{
					g_AmuletCustom[id][acReduceExtraItems] = 0;
					g_AmuletCustomCost[id] -= 4;
				}
			}
			case 0:
			{
				dg_color_chat(id, _, "Cuando estés decidido a crear el amuleto personalizado, escribe en consola !gzp_ac_create!y. Pedirá confirmación, no te preocupes");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}
		}

		showMenu__AmuletCustom(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__AmuletCustomDelete(const id)
{
	if(!g_AmuletCustomCreated[id])
		return;

	oldmenu_create("\yELIMINAR AMULETO^n\wNombre del amuleto\r:\y %s", "menu__AmuletCustomDelete", g_AmuletCustomName[id]);

	oldmenu_additem(-1, -1, "\w¿Estás seguro que quieres eliminar tu amuleto?");
	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No^n");

	oldmenu_additem(-1, -1, "\yNOTA IMPORTANTE\r:\w Queda bajo tu responsabilidad eliminar^nel amuleto, si por alguna razón te arrepientes^nvisita tu panel de control y consulta la devolusión del mismo^nte costarà \yDIAMANTES\w para poder devolver tu amuleto");
	oldmenu_display(id);
}

public menu__AmuletCustomDelete(const id, const item)
{
	if(!g_AmuletCustomCreated[id])
		return PLUGIN_HANDLED;

	switch(item)
	{
		case 1:
		{
			g_AmuletCustomCreated[id] = 0;

			static Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_amulets_custom SET active='0' WHERE acc_id='%d';", g_AccountId[id]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 23);
			else
				SQL_FreeHandle(sqlQuery);

			dg_color_chat(id, _, "Has eliminado tu amuleto personalizado con éxito");
			showMenu__AmuletCustom(id, 1);
		}
		case 2: showMenu__AmuletCustom(id);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Clans(const id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))
		return PLUGIN_HANDLED;

	dg_console_chat(id, "");

	new i;
	for(i = 1; i <= g_MaxPlayers; ++i)
	{
		if(g_IsConnected[i] && g_AccountLogged[i] && g_ClanSlot[i])
			dg_console_chat(id, "g_ClanSlot[%d] - g_PlayerName[%s]", g_ClanSlot[i], g_PlayerName[i]);
	}

	dg_console_chat(id, "");
	return PLUGIN_HANDLED;
}

public showMenu__Benefit(const id)
{
	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] == 1)
	{
		showMenu__Stats(id);
		return;
	}

	oldmenu_create("\yBENEFICIO GRATUITO", "menu__Benefit");

	static iSysTime;
	iSysTime = get_systime();

	if(g_Benefit[id] > iSysTime)
	{
		oldmenu_additem(-1, -1, "\wTu beneficio está activado");
		oldmenu_additem(-1, -1, "\wSe vencerá el día \y%s\w^n", getUnixToTime(g_Benefit[id], 1));
		
		oldmenu_additem(-1, -1, "\wUna vez que acabe tu beneficio, no");
		oldmenu_additem(-1, -1, "podrás volver a utilizarlo en tu personaje.");
		oldmenu_additem(-1, -1, "\wSi quieres volver a tener los beneficios, visita");
		oldmenu_additem(-1, -1, "la sección de compras de la comunidad en\r:");
		oldmenu_additem(-1, -1, "\y%s\w^n", PLUGIN_COMMUNITY_FORUM_SHOP);
	}
	else
	{
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

public menu__Benefit(const id, const item)
{
	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] == 1)
	{
		showMenu__Stats(id);
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		case 0: showMenu__Stats(id);
		case 1:
		{
			static iSysTime;
			iSysTime = get_systime();

			if(g_Benefit[id] > iSysTime)
			{
				showMenu__Benefit(id);
				return PLUGIN_HANDLED;
			}

			g_Benefit[id] = (iSysTime + 604800); // 7 DÍAS

			new Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_pjs SET benefit_timestamp='%d' WHERE acc_id='%d';", g_Benefit[id], g_AccountId[id]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 000001);
			else
				SQL_FreeHandle(sqlQuery);

			dg_color_chat(id, _, "Has activado tu beneficio gratuito por !g7 DÍAS!y. Disfrutalo :)");
			showMenu__Benefit(id);
		}
	}

	return PLUGIN_HANDLED;
}

getHabCost(const id, const hab)
{
	if(hab == HAB_D_RESET_EI)
		return HABS[hab][habCost];

	return ((g_Habs[id][hab] + 1) * HABS[hab][habCost]);
}

public startZombieMadness(const id, const Float:duration, const ignore_last_use, const sound_agude)
{
	if(!g_IsAlive[id])
		return;

	remove_task(id + TASK_BURNING_FLAME);
	remove_task(id + TASK_DRUG);

	if(g_Frozen[id])
	{
		remove_task(id + TASK_FREEZE);
		remove_task(id + TASK_SLOWDOWN);

		task__RemoveFreeze(id + TASK_FREEZE);
		task__RemoveSlowDown(id + TASK_SLOWDOWN);
	}
	else if(g_SlowDown[id])
	{
		remove_task(id + TASK_SLOWDOWN);
		task__RemoveSlowDown(id + TASK_SLOWDOWN);
	}

	g_Immunity[id] = 1;
	g_BurningDuration[id] = 0;
	g_BurningDurationOwner[id] = 0;
	g_DrugBombCount[id] = 0;
	g_DrugBombMove[id] = 0;
	g_Hat_Earth[id] = 0;
	if(!ignore_last_use) g_Madness_LastUse[id] = (get_systime() + TIME_MADNESS_TO_DELAY);
	g_Speed[id] += ZOMBIE_MADNESS_SPEED_EXTRA;

	give_item(id, "weapon_knife");

	set_user_rendering(id, kRenderFxGlowShell, 150, 0, 0, kRenderNormal, 125);

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	remove_task(id + TASK_MADNESS);
	set_task(duration, "task__RemoveMadness", id + TASK_MADNESS);

	if(sound_agude)
		emitSound(id, CHAN_BODY, SOUND_ZOMBIE_MADNESS, .pitch=200);
	else
		emitSound(id, CHAN_BODY, SOUND_ZOMBIE_MADNESS);
}

public showMenu__DailyVisits(const id)
{
	oldmenu_create("\yVISITAS DIARIAS", "menu__DailyVisits");

	oldmenu_additem(-1, -1, "\wVisitas diarias totales\r:\y %d", g_DailyVisits[id]);
	oldmenu_additem(-1, -1, "\wVisitas diarias consecutivas\r:\y %d^n", g_Consecutive_DailyVisits[id]);

	oldmenu_additem(-1, -1, "\wBonus de Combo\r:\y +%0.2f^n", (float(g_Consecutive_DailyVisits[id]) * 0.012));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__DailyVisits(const id, const item)
{
	if(item == 0)
	{
		showMenu__Game(id);
		return;
	}

	showMenu__DailyVisits(id);
}

public checkMults(const id)
{
	g_AmmoPacksMult[id] = apsMult(id);
	g_ExpMult[id] = expMult(id);
	g_PointsMult[id] = ((((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1) ? 2 : 1) + ((g_HappyTime == 2) ? 1 : 0) + ((g_AmuletCustomCreated[id]) ? 1 : 0));

	// (float(g_Consecutive_DailyVisits[id]) * 0.012)

	g_AmmoPacksDamageNeed[id] = apsDamageNeed(id);
	g_ExpDamageNeed[id] = expDamageNeed(id);
	g_ComboDamageNeed[id] = floatclamp((__CLASSES[g_Class[id]][classMultCombo] - (((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1) ? 0.5 : 0.0) - ((g_HappyTime == 2) ? 1.0 : ((g_HappyTime == 1) ? 0.5 : 0.0)) - (float(g_AchievementTotal[id]) * 0.0025) - ((g_AmuletCustomCreated[id]) ? 0.5 : 0.0)), 0.1, 5.0);
}

public apsMult(const id)
{
	static iMult;
	iMult = 1;

	if(g_Class[id])
		iMult += __CLASSES[g_Class[id]][classMultAPs];

	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1)
		iMult += 2;

	if(g_HatId[id] != HAT_NONE)
		iMult += HATS[g_HatId[id]][hatUpgrade5];

	if(g_AmuletCustomCreated[id])
		iMult += g_AmuletCustom[id][acMultAPs];
	else
	{
		if(g_AmuletEquip[id] != -1)
			iMult += g_AmuletsInt[id][g_AmuletEquip[id]][4];
	}

	return iMult;
}

public apsDamageNeed(const id)
{
	static iBase;
	iBase = MAX_APS_DAMAGE_NEED;

	if(g_AmmoPacksMult[id] < 0) // Si el multiplicador está en negativo . . .
	{
		static iMultNegative;
		iMultNegative = abs(g_AmmoPacksMult[id]); // Se convierte la variable de negativo a positivo

		if(iMultNegative < 0) // Hipotéticamente si estoy seteando la variable de negativo a positivo sería imposible que esta condición se cumpla, pero me gusta programar bien :P
			iBase += MAX_APS_DAMAGE_NEED;
		else
			iBase += (iMultNegative * MAX_APS_DAMAGE_NEED);
	}
	else if(g_AmmoPacksMult[id] == 0)
	{
		// ¿¿¿???
	}
	else
		iBase /= g_AmmoPacksMult[id];

	return ((iBase < 1) ? 1 : iBase);
}

public expMult(const id)
{
	static iMult;
	iMult = 1;

	if(g_Class[id])
		iMult += __CLASSES[g_Class[id]][classMultXP];

	if((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1)
		iMult += 2;

	if(g_HappyTime)
		iMult += ((g_HappyTime == 2) ? 3 : 2);

	if(g_HatId[id] != HAT_NONE)
		iMult += HATS[g_HatId[id]][hatUpgrade6];

	if(g_AmuletCustomCreated[id])
		iMult += g_AmuletCustom[id][acMultXP];
	else
	{
		if(g_AmuletEquip[id] != -1)
			iMult += g_AmuletsInt[id][g_AmuletEquip[id]][5];
	}

	if(g_PlayerBonus)
		iMult += g_PlayerBonus;

	return iMult;
}

public expDamageNeed(const id)
{
	static iBase;
	iBase = MAX_XP_DAMAGE_NEED;

	if(g_ExpMult[id] < 0) // Si el multiplicador está en negativo . . .
	{
		static iMultNegative;
		iMultNegative = abs(g_ExpMult[id]); // Se convierte la variable de negativo a positivo

		if(iMultNegative < 0) // Hipotéticamente si estoy seteando la variable de negativo a positivo sería imposible que esta condición se cumpla, pero me gusta programar bien :P
			iBase += MAX_XP_DAMAGE_NEED;
		else
			iBase += (iMultNegative * MAX_XP_DAMAGE_NEED);
	}
	else if(g_ExpMult[id] == 0)
	{
		// ¿¿¿???
	}
	else
		iBase /= g_ExpMult[id];

	return ((iBase < 1) ? 1 : iBase);
}

public showMenu__Multipliers(const id, const mult)
{
	g_MenuData[id][MENU_DATA_MULTIPLIER] = mult;

	oldmenu_create("\yMULTIPLICADOR DE %s", "menu__Multipliers", ((mult == 2) ? "COMBO" : ((mult == 1) ? "XP" : "APS")));

	switch(mult)
	{
		case 0:
		{
			oldmenu_additem(-1, -1, "\yAMMO PACKS\r:");
			oldmenu_additem(-1, -1, "\r - \wBASE%s\r:\y +x%d", ((g_Benefit[id] > 1) ? " \d(Beneficio temporal)" : ""), (((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1) ? 2 : 1));
			if(g_Class[id]) oldmenu_additem(-1, -1, "\r - \wCLASE\r:\y +x%d", __CLASSES[g_Class[id]][classMultAPs]);
			if(g_HatId[id] != HAT_NONE && HATS[g_HatId[id]][hatUpgrade5]) oldmenu_additem(-1, -1, "\r - \wGORRO\r:\y +x%d", HATS[g_HatId[id]][hatUpgrade5]);
			if(g_AmuletCustomCreated[id]) oldmenu_additem(-1, -1, "\r - \wAMULETO\r:\y +x%d", ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acMultAPs] : ((g_AmuletEquip[id] != -1) ? g_AmuletsInt[id][g_AmuletEquip[id]][4] : 0)));
			
			oldmenu_additem(-1, -1, "^n\wNecesitás realizar \y+%d\w de daño para conseguir 1 AP.^n", g_AmmoPacksDamageNeed[id]);

			oldmenu_additem(9, 9, "\r9.\w Multiplicador de XP");
		}
		case 1:
		{
			oldmenu_additem(-1, -1, "\yEXPERIENCIA\r:^n");
			oldmenu_additem(-1, -1, "\r - \wBASE%s\r:\y +x%d^n", ((g_Benefit[id] > 1) ? " \d(Beneficio temporal)" : ""), (((get_user_flags(id) & ADMIN_RESERVATION) || g_Benefit[id] > 1) ? 2 : 1));
			if(g_Class[id]) oldmenu_additem(-1, -1, "\r - \wCLASE\r:\y +x%d", __CLASSES[g_Class[id]][classMultXP]);
			if(g_HappyTime) oldmenu_additem(-1, -1, "\r - \wDAN / SDAN\r:\y +x%d^n", ((g_HappyTime == 1) ? 2 : (g_HappyTime == 2) ? 3 : 1));
			if(g_HatId[id] != HAT_NONE && HATS[g_HatId[id]][hatUpgrade6]) oldmenu_additem(-1, -1, "\r - \wGORRO\r:\y +x%d", HATS[g_HatId[id]][hatUpgrade6]);
			if(g_AmuletCustomCreated[id]) oldmenu_additem(-1, -1, "\r - \wAMULETO\r:\y +x%d", ((g_AmuletCustomCreated[id]) ? g_AmuletCustom[id][acMultXP] : ((g_AmuletEquip[id] != -1) ? g_AmuletsInt[id][g_AmuletEquip[id]][5] : 0)));
			if(g_PlayerBonus) oldmenu_additem(-1, -1, "\r - \wUSUARIOS ONLINE\r:\y +x%d", g_PlayerBonus);
			
			oldmenu_additem(-1, -1, "^n\wNecesitás realizar \y+%d\w de daño para conseguir 1 de XP.^n", g_ExpDamageNeed[id]);
			
			oldmenu_additem(9, 9, "\r9.\w Multiplicador de Combo");
		}
		case 2:
		{
			oldmenu_additem(-1, -1, "\yCOMBO\r:^n");
			oldmenu_additem(-1, -1, "\wEn construcción");

			oldmenu_additem(-1, -1, "^n\wNecesitás realizar \y+%0.2f\w de daño para conseguir 1 de Combo.^n", g_ComboDamageNeed[id]);
			
			oldmenu_additem(9, 9, "\r9.\w Multiplicador de APs");
		}
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Multipliers(const id, const item)
{
	if(item == 0)
	{
		showMenu__Game(id);
		return;
	}

	switch(item)
	{
		case 9:
		{
			switch(g_MenuData[id][MENU_DATA_MULTIPLIER])
			{
				case 0: showMenu__Multipliers(id, 1);
				case 1: showMenu__Multipliers(id, 2);
				case 2: showMenu__Multipliers(id, 0);
			}
		}
	}
}

public task__CheckAccount(const task_id) {
	new iId = (task_id - TASK_CHECK_ACCOUNT);

	if(!g_IsConnected[iId]) {
		return;
	}

	g_LoadingData[iId] = 1;

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM zp6_accounts LEFT JOIN zp6_pjs ON zp6_pjs.acc_id=zp6_accounts.id WHERE zp6_pjs.pj_name=^"%s^";", g_PlayerName[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckAccount", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__CheckAccount(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];
	
	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		dg_log_to_file(LOG_MYSQL, 1, iId, "sqlThread__CheckAccount - %d - %s", error_num, error);

		server_cmd("kick #%d ^"Hubo un error al cargar tu cuenta. Intente mas tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		new sIpDb[16];

		g_AccountId[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "id"));
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "ip"), sIpDb, charsmax(sIpDb));
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "password"), g_AccountPassword[iId], charsmax(g_AccountPassword[]));
		g_AccountSince[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "since"));
		g_AccountLastConnection[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "last_connection"));
		g_DailyVisits[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "visit_days"));
		g_Consecutive_DailyVisits[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "visit_days_c"));
		g_ConnectedToday[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "con_today"));
		g_AccountAutoLogin[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "is_autologin"));
		g_AccountVinc[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "is_vinc"));

		if(!g_AccountVinc[iId]) {
			set_task(random_float(300.0, 600.0), "task__RememberVinc", iId + TASK_REMEMBER_VINC, .flags="b");
		}

		g_AccountRegister[iId] = 1;

		if(SQL_ReadResult(query, 10)) {
			g_AccountBan_Start[iId] = SQL_ReadResult(sqlQuery, 11);
			g_AccountBan_Finish[iId] = SQL_ReadResult(sqlQuery, 12);

			if(get_arg_systime() < g_AccountBan_Finish[iId]) {
				SQL_ReadResult(sqlQuery, 13, g_AccountBan_Admin[iId], charsmax(g_AccountBan_Admin[]));
				SQL_ReadResult(sqlQuery, 14, g_AccountBan_Reason[iId], charsmax(g_AccountBan_Reason[]));

				g_AccountBanned[iId] = 1;
				g_LoadingData[iId] = 0;

				clcmd__ChangeTeam(iId);

				remove_task(iId + TASK_BANNED);
				set_task(10.0, "task__Banned", iId + TASK_BANNED);
			} else {
				dg_color_chat(0, _, "El usuario !t%s!y tenía !gban de cuenta!y pero ya puede volver a jugar", g_PlayerName[iId]);

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_bans SET active='0' WHERE (acc_id='%d' OR ip=^"%s^" OR steam=^"%s^") AND active='1';", g_AccountId[iId], g_PlayerIp[iId], g_PlayerSteamId[iId]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

				if(g_AccountAutoLogin[iId] && g_AccountVinc[iId] && equal(g_PlayerIp[iId], sIpDb)) {
					loadInfo(id);
				} else {
					g_LoadingData[id] = 0;
					clcmd__ChangeTeam(iId);
				}
			}
		} else {
			if(g_AccountAutoLogin[iId] && g_AccountVinc[iId] && equal(g_PlayerIp[iId], sIpDb)) {
				loadInfo(id);
			} else {
				g_LoadingData[id] = 0;
				clcmd__ChangeTeam(iId);
			}
		}
	} else {
		g_LoadingData[id] = 0;
		clcmd__ChangeTeam(iId);
	}
}

public loadInfo(const id)
{
	if(!g_IsConnected[id] || !g_AccountRegister[id])
		return;

	g_LoadingData[id] = 1;
	g_LoadingData_Percent[id] = 0;

	loadUser(id);
}

public loadUser(const id)
{
	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_pjs LEFT JOIN zp6_pjs_stats ON zp6_pjs_stats.acc_id='%d' WHERE zp6_pjs.acc_id='%d';", g_AccountId[id], g_AccountId[id]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 29);
	else if(SQL_NumResults(sqlQuery))
	{
		g_Benefit[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "benefit_timestamp"));

		if(g_Benefit[id] != 0 && get_systime() > g_Benefit[id])
			g_Benefit[id] = 1;

		g_Class[id] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "class")), 0, charsmax(__CLASSES));
		
		if(g_Class[id])
			g_ClassPetitionMode[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "class_petition_mode"));
		else
			g_ClassPetitionMode[id] = 0;
		
		g_AmmoPacks[id] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ammopacks")), 0, MAX_APS);
		g_Exp[id] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "exp")), 0, MAX_XP);
		g_Level[id] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "level")), 1, MAX_LEVEL);
		g_Reset[id] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "reset")), 0, MAX_RESET);

		static sInfo[256];
		static iClan;
		static iTimePlayed;

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "weapons"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_Weapons[id], structIdWeapons);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ei_cost"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_ExtraItem_Cost[id], structIdExtraItems);

		for(new i = 0; i < structIdExtraItems; ++i)
		{
			if(g_ExtraItem_Cost[id][i] < EXTRA_ITEMS[i][extraItemCost])
				g_ExtraItem_Cost[id][i] = EXTRA_ITEMS[i][extraItemCost];
		}

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ei_count"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_ExtraItem_Count[id], structIdExtraItems);

		if(g_AccountId[id] == 85)
			g_Invisibility_Vrg[id] = 3;

		if(g_AccountId[id] == 49)
			g_Painshock_Chite[id] = 3;

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "models"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_Models[id], sizeof(MODELS));

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "model_selected"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_ModelSelected[id], structIdModelClasses);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "difficults"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_Difficult[id], structIdDifficultsClasses);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "points"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_Points[id], structIdPoints);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "points_lose"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_PointsLose[id], structIdPoints);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "habs"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_Habs[id], structIdHabs);

		for(new i = 0; i < structIdHabs; ++i)
		{
			if(g_Habs[id][i] > HABS[i][habMaxLevel])
				g_Habs[id][i] = HABS[i][habMaxLevel];
		}

		if(g_Habs[id][HAB_Z_INDUCTION])
			g_InductionChance[id] = (HABS[HAB_Z_INDUCTION][habValue] * g_Habs[id][HAB_Z_INDUCTION]);

		iClan = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_id"));

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "color_hud_g"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_HUD_G], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "color_hud_c"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_HUD_C], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "color_hud_cc"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_HUD_CC], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "color_nvision"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_NVISION], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "color_flare"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_FLARE], 3);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "color_clan_glow"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW], 3);

		// Si o si tengo que usar parse(); ya que stringToArray(); no devuelve valores flotantes
		{
			static sHudPosition[3][32];

			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hud_pos_g"), sInfo, charsmax(sInfo));
			parse(sInfo, sHudPosition[0], charsmax(sHudPosition[]), sHudPosition[1], charsmax(sHudPosition[]), sHudPosition[2], charsmax(sHudPosition[]));

			g_UserOption_PositionHud[id][HUD_TYPE_GENERAL][0] = str_to_float(sHudPosition[0]);
			g_UserOption_PositionHud[id][HUD_TYPE_GENERAL][1] = str_to_float(sHudPosition[1]);
			g_UserOption_PositionHud[id][HUD_TYPE_GENERAL][2] = str_to_float(sHudPosition[2]);

			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hud_pos_c"), sInfo, charsmax(sInfo));
			parse(sInfo, sHudPosition[0], charsmax(sHudPosition[]), sHudPosition[1], charsmax(sHudPosition[]), sHudPosition[2], charsmax(sHudPosition[]));

			g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0] = str_to_float(sHudPosition[0]);
			g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1] = str_to_float(sHudPosition[1]);
			g_UserOption_PositionHud[id][HUD_TYPE_COMBO][2] = str_to_float(sHudPosition[2]);

			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hud_pos_cc"), sInfo, charsmax(sInfo));
			parse(sInfo, sHudPosition[0], charsmax(sHudPosition[]), sHudPosition[1], charsmax(sHudPosition[]), sHudPosition[2], charsmax(sHudPosition[]));

			g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][0] = str_to_float(sHudPosition[0]);
			g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][1] = str_to_float(sHudPosition[1]);
			g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][2] = str_to_float(sHudPosition[2]);
		}

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hud_effect"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_EffectHud[id], structIdHudsType);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hud_min"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_MinimizeHud[id], structIdHudsType);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hud_abr"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UserOption_AbreviateHud[id], structIdHudsType);

		g_UserOption_ChatMode[id] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_chatmode")), 0, (structIdChatMode - 1));
		g_UserOption_Invis[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_invis"));
		g_UserOption_ClanChat[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_clanchat"));
		g_HatId[id] = g_HatNext[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hat_id"));
		g_AmuletEquip[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "amulet_id"));
		g_BuyStuff[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "bought_ok"));

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "head_zombies"), sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_HeadZombie[id], structIdHeadZombies);

		g_AchievementSecret_Terrorist[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "as_terrorist"));
		g_AchievementSecret_Hitman[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "as_hitman"));
		g_AchievementSecret_Nemesis[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "as_terror_existe"));
		g_AchievementSecret_Resistencia[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "as_resistencia"));
		g_AchievementSecret_Albert[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "as_albert_wesker"));
		
		g_AchievementSecret_Progress[id][0] = ((float(g_AchievementSecret_Terrorist[id]) * 100.0) / 150.0);
		g_AchievementSecret_Progress[id][1] = ((float(g_AchievementSecret_Hitman[id]) * 100.0) / 500000.0);
		g_AchievementSecret_Progress[id][2] = ((float(g_Exp[id]) * 100.0) / 100000000.0);
		g_AchievementSecret_Progress[id][3] = ((float(g_AchievementSecret_Nemesis[id]) * 100.0) / 2500.0);
		g_AchievementSecret_Progress[id][4] = ((float(g_AchievementSecret_Resistencia[id]) * 100.0) / 2500.0);
		g_AchievementSecret_Progress[id][5] = ((float(g_AchievementSecret_Albert[id]) * 100.0) / 2500.0);

		for(new i = 0; i < 6; ++i)
		{
			if(g_AchievementSecret_Progress[id][i] > 100.0)
				g_AchievementSecret_Progress[id][i] = 100.0;
		}

		iTimePlayed = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "time_played"));
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "dmg_d"), Float:g_StatsDamage[id][0]);
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "dmg_t"), Float:g_StatsDamage[id][1]);
		g_Stats[id][STAT_HS_D] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hs_d"));
		g_Stats[id][STAT_HS_T] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hs_t"));
		g_Stats[id][STAT_HM_D] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hm_d"));
		g_Stats[id][STAT_HM_T] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hm_t"));
		g_Stats[id][STAT_ZM_D] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "zm_d"));
		g_Stats[id][STAT_ZM_T] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "zm_t"));
		g_Stats[id][STAT_INF_D] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "inf_d"));
		g_Stats[id][STAT_INF_T] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "inf_t"));
		g_Stats[id][STAT_ZMHS_D] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "zmhs_d"));
		g_Stats[id][STAT_ZMHS_T] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "zmhs_t"));
		g_Stats[id][STAT_ZMK_D] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "zmk_d"));
		g_Stats[id][STAT_ZMK_T] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "zmk_t"));
		g_Stats[id][STAT_AP_D] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ap_d"));
		g_Stats[id][STAT_AP_T] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ap_t"));
		g_Stats[id][STAT_COMBO_MAX] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "combo_max"));
		g_Stats[id][STAT_S_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "s_m_c"));
		g_Stats[id][STAT_S_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "s_m_win"));
		g_Stats[id][STAT_S_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "s_m_lose"));
		g_Stats[id][STAT_S_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "s_m_kill"));
		g_Stats[id][STAT_W_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "w_m_c"));
		g_Stats[id][STAT_W_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "w_m_win"));
		g_Stats[id][STAT_W_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "w_m_lose"));
		g_Stats[id][STAT_W_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "w_m_kill"));
		g_Stats[id][STAT_SN_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "sn_m_c"));
		g_Stats[id][STAT_SN_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "sn_m_win"));
		g_Stats[id][STAT_SN_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "sn_m_lose"));
		g_Stats[id][STAT_SN_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "sn_m_kill"));
		g_Stats[id][STAT_J_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "j_m_c"));
		g_Stats[id][STAT_J_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "j_m_win"));
		g_Stats[id][STAT_J_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "j_m_lose"));
		g_Stats[id][STAT_J_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "j_m_kill"));
		g_Stats[id][STAT_N_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "n_m_c"));
		g_Stats[id][STAT_N_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "n_m_win"));
		g_Stats[id][STAT_N_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "n_m_lose"));
		g_Stats[id][STAT_N_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "n_m_kill"));
		g_Stats[id][STAT_A_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_m_c"));
		g_Stats[id][STAT_A_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_m_win"));
		g_Stats[id][STAT_A_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_m_lose"));
		g_Stats[id][STAT_A_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "a_m_kill"));
		g_Stats[id][STAT_AN_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "an_m_c"));
		g_Stats[id][STAT_AN_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "an_m_win"));
		g_Stats[id][STAT_AN_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "an_m_lose"));
		g_Stats[id][STAT_AN_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "an_m_kill"));
		g_Stats[id][STAT_F_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "f_m_c"));
		g_Stats[id][STAT_F_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "f_m_win"));
		g_Stats[id][STAT_F_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "f_m_lose"));
		g_Stats[id][STAT_F_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "f_m_kill"));
		g_Stats[id][STAT_T_M_C] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "t_m_c"));
		g_Stats[id][STAT_T_M_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "t_m_win"));
		g_Stats[id][STAT_T_M_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "t_m_lose"));
		g_Stats[id][STAT_T_M_KILL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "t_m_kill"));
		g_Stats[id][STAT_DUEL_WIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "duel_win"));
		g_Stats[id][STAT_DUEL_LOSE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "duel_lose"));
		g_Stats[id][STAT_DUEL_FINAL_WINS] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "duel_final_wins"));
		g_Stats[id][STAT_GG_WINS] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "gg_wins"));

		SQL_FreeHandle(sqlQuery);

		if(!g_ConnectedToday[id])
		{
			g_ConnectedToday[id] = 1;
			SQL_QueryAndIgnore(g_SqlConnection, "UPDATE zp6_accounts SET con_today='1' WHERE id='%d';", g_AccountId[id]);
		}

		fixModels(id);
		checkExpEquation(id);

		while(iTimePlayed >= 86400)
		{
			iTimePlayed -= 86400;
			++g_PlayedTime[id][TIME_DAY];
		}
		
		while(iTimePlayed >= 3600)
		{
			iTimePlayed -= 3600;
			++g_PlayedTime[id][TIME_HOUR];
		}
	}
	else
	{
		SQL_FreeHandle(sqlQuery);

		g_AccountLogged[id] = 0;
		g_LoadingData[id] = 1;

		if(isUserValidConnected(id))
			server_cmd("kick #%d ^"Hubo un error al cargar tus datos. Intente mas tarde (5)^"", get_user_userid(id));
	}

	loadUser_Clans(id, iClan);
	loadUser_Weapons(id);
	loadUser_Achievements(id);
	loadUser_Hats(id);
	loadUser_Amulets(id);
	loadUser_Buys(id);
	loadUser_Rank(id);
}

public loadUser_Clans(const id, const clan)
{
	if(clan)
	{
		new iOk;
		new i;
		new j;

		iOk = 0;

		for(new i = 1; i <= g_MaxPlayers; ++i)
		{
			if(!g_IsConnected[i])
				continue;

			if(g_Clan[g_ClanSlot[i]][clanId] != iClan)
				continue;

			iOk = 1;

			g_ClanSlot[id] = g_ClanSlot[i];

			++g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

			j = getClanMemberSlotId(id);

			if(j != -1)
			{
				g_ClanMembers[g_ClanSlot[id]][j][clanMemberLastTimeDay] = 0;
				g_ClanMembers[g_ClanSlot[id]][j][clanMemberLastTimeHour] = 0;
				g_ClanMembers[g_ClanSlot[id]][j][clanMemberLastTimeMinute] = 0;
			}
			
			break;
		}
		
		if(!iOk)
		{
			static iClanSlot;
			iClanSlot = clanFindSlot();

			if(!iClanSlot)
				return;

			resetDataClanMembers(iClanSlot);

			new Handle:sqlQuery;
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_clans WHERE id='%d' LIMIT 1;", clan);
			
			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 31);
			else if(SQL_NumResults(sqlQuery))
			{
				g_ClanSlot[id] = iClanSlot;
				
				g_Clan[g_ClanSlot[id]][clanId] = clan;
				SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_name"), g_Clan[g_ClanSlot[id]][clanName], 31);
				g_Clan[g_ClanSlot[id]][clanSince] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_since"));
				g_Clan[g_ClanSlot[id]][clanDeposit] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "deposit"));
				g_Clan[g_ClanSlot[id]][clanKillDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kill_done"));
				g_Clan[g_ClanSlot[id]][clanInfectDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "infect_done"));
				g_Clan[g_ClanSlot[id]][clanVictory] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "vic"));
				g_Clan[g_ClanSlot[id]][clanVictoryConsec] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "vic_con"));
				g_Clan[g_ClanSlot[id]][clanVictoryConsecHistory] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "vic_con_his"));
				g_Clan[g_ClanSlot[id]][clanChampion] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "is_champion"));
				g_Clan[g_ClanSlot[id]][clanRank] = 0;
				g_Clan[g_ClanSlot[id]][clanCountOnlineMembers] = 1;
				g_Clan[g_ClanSlot[id]][clanCountMembers] = 0;
				g_Clan[g_ClanSlot[id]][clanHumans] = 0;
				
				SQL_FreeHandle(sqlQuery);
			}
			else
				SQL_FreeHandle(sqlQuery);

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT \
														zp6_clans_members.acc_id, zp6_pjs.pj_name, zp6_clans_members.owner, zp6_clans_members.since, zp6_clans_members.last_connection, zp6_pjs.reset, zp6_pjs.level \
														FROM zp6_clans_members \
														LEFT JOIN zp6_pjs ON zp6_clans_members.acc_id=zp6_pjs.acc_id \
														WHERE zp6_clans_members.clan_id='%d' AND zp6_clans_members.active='1' LIMIT %d;", clan, MAX_CLAN_MEMBERS);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 32);
			else if(SQL_NumResults(sqlQuery))
			{
				static iSince;
				static iLastSee;
				static iSysTime;
				static i;
				static iMinutes;

				iSysTime = get_systime();
				i = 0;
				
				while(SQL_MoreResults(sqlQuery))
				{
					++g_Clan[g_ClanSlot[id]][clanCountMembers];

					g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] = SQL_ReadResult(sqlQuery, 0);
					SQL_ReadResult(sqlQuery, 1, g_ClanMembers[g_ClanSlot[id]][i][clanMemberName], 32);
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberOwner] = SQL_ReadResult(sqlQuery, 2);
					iSince = (iSysTime - SQL_ReadResult(sqlQuery, 3));
					iLastSee = (iSysTime - SQL_ReadResult(sqlQuery, 4));
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberReset] = SQL_ReadResult(sqlQuery, 5);
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberLevel] = SQL_ReadResult(sqlQuery, 6);
					
					// START - Miembro desde
					iMinutes = (iSince / 60);
					
					if(iMinutes >= 60)
					{
						while(iMinutes >= 60)
						{
							++g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour];
							
							if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour] >= 24)
							{
								++g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceDay];
								g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour] -= 24;
							}
							
							iMinutes -= 60;
						}
					}
					else
					{
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceDay] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceHour] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberSinceMinute] = iMinutes;
					}
					
					if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][i][clanMemberId])
					{
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeDay] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeMinute] = 0;
					}
					// END
					
					// START - Última vez visto
					iMinutes = (iLastSee / 60);
					
					if(iMinutes >= 60)
					{
						while(iMinutes >= 60)
						{
							++g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour];
							
							if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] >= 24)
							{
								++g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeDay];
								g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] -= 24;
							}
							
							iMinutes -= 60;
						}
					}
					else
					{
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeDay] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] = 0;
						g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeMinute] = iMinutes;
					}
					// END
					
					++i;
					
					SQL_NextRow(sqlQuery);
				}

				SQL_FreeHandle(sqlQuery);
			}
			else
				SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT perk_id FROM zp6_clans_perks WHERE clan_id='%d' LIMIT %d;", clan, structIdClanPerks);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 33);
			else if(SQL_NumResults(sqlQuery))
			{
				while(SQL_MoreResults(sqlQuery))
				{
					g_ClanPerks[g_ClanSlot[id]][SQL_ReadResult(sqlQuery, 0)] = 1;
					SQL_NextRow(sqlQuery);
				}

				SQL_FreeHandle(sqlQuery);
			}
			else
				SQL_FreeHandle(sqlQuery);

			clanUpdateHumans(id);
		}
	}
}

public loadUser_Weapons(const id)
{
	g_WeaponModel[id][CSW_KNIFE] = 1;

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_weapons WHERE acc_id='%d';", g_AccountId[id]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 30);
	else if(SQL_NumResults(sqlQuery))
	{
		static iWeaponId;
		static iNot;
		static iSeconds;

		while(SQL_MoreResults(sqlQuery))
		{
			iWeaponId = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "weapon_id"));
			
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "damage_done"), Float:g_WeaponData[id][iWeaponId][WEAPON_DATA_DAMAGE_DONE]);
			g_WeaponData[id][iWeaponId][WEAPON_DATA_KILL_DONE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kill_done"));
			g_WeaponData[id][iWeaponId][WEAPON_DATA_TIME_PLAYED_DONE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "time_played_done"));
			g_WeaponData[id][iWeaponId][WEAPON_DATA_POINTS] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "points"));
			g_WeaponData[id][iWeaponId][WEAPON_DATA_LEVEL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "level"));
			
			g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_DAMAGE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "skill_damage"));
			g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_SPEED] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "skill_speed"));
			g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_RECOIL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "skill_recoil"));
			g_WeaponSkills[id][iWeaponId][WEAPON_SKILL_MAXCLIP] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "skill_maxclip"));

			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "damage_s_done"), Float:g_WeaponData[id][iWeaponId][WEAPON_DATA_DAMAGE_S_DONE]);
			g_WeaponData[id][iWeaponId][WEAPON_DATA_KILL_S_DONE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kill_s_done"));
			
			checkWeaponModels(id, iWeaponId);

			iNot = 0;
			iSeconds = g_WeaponData[id][iWeaponId][WEAPON_DATA_TIME_PLAYED_DONE];

			while(iSeconds >= 86400)
			{
				iNot = 1;

				iSeconds -= 86400;
				++g_WeaponData[id][iWeaponId][WEAPON_DATA_TPD_DAYS];
			}
			
			while(iSeconds >= 3600)
			{
				iSeconds -= 3600;
				++g_WeaponData[id][iWeaponId][WEAPON_DATA_TPD_HOURS];
			}
			
			if(!iNot)
			{
				while(iSeconds >= 60)
				{
					iSeconds -= 60;
					++g_WeaponData[id][iWeaponId][WEAPON_DATA_TPD_MINUTES];
				}
			}

			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);
	}
	else
		SQL_FreeHandle(sqlQuery);
}

public loadUser_Achievements(const id)
{
	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT achievement_id, achievement_timestamp FROM zp6_achievements WHERE acc_id='%d';",  g_AccountId[id]);
			
	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 34);
	else if(SQL_NumResults(sqlQuery))
	{
		static iAchievement;

		while(SQL_MoreResults(sqlQuery))
		{
			iAchievement = SQL_ReadResult(sqlQuery, 0);

			g_Achievement[id][iAchievement] = 1;
			g_AchievementUnlocked[id][iAchievement] = SQL_ReadResult(sqlQuery, 1);
			++g_AchievementTotal[id];

			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);
	}
	else
		SQL_FreeHandle(sqlQuery);
}

public loadUser_Hats(const id)
{
	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_hats WHERE acc_id='%d';", g_AccountId[id]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 35);
	else if(SQL_NumResults(sqlQuery))
	{
		new iHatId;

		while(SQL_MoreResults(sqlQuery))
		{
			iHatId = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hat_id"));

			g_Hat[id][iHatId] = 1;
			g_HatUnlocked[id][iHatId] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hat_timestamp"));
			++g_HatTotal[id];

			SQL_NextRow(sqlQuery);
		}

		SQL_FreeHandle(sqlQuery);
	}
	else
		SQL_FreeHandle(sqlQuery);
}

public loadUser_Amulets(const id)
{
	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_amulets_custom WHERE acc_id='%d' AND active='1';", g_AccountId[id]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 36);
	else if(SQL_NumResults(sqlQuery))
	{
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "name"), g_AmuletCustomName[id], charsmax(g_AmuletCustomName[]));
		g_AmuletCustom[id][acHealth] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "health"));
		g_AmuletCustom[id][acSpeed] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "speed"));
		g_AmuletCustom[id][acGravity] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "gravity"));
		g_AmuletCustom[id][acDamage] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "damage"));
		g_AmuletCustom[id][acMultAPs] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "mult_aps"));
		g_AmuletCustom[id][acMultXP] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "mult_xp"));
		g_AmuletCustom[id][acRespawnHuman] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "respawn_h"));
		g_AmuletCustom[id][acReduceExtraItems] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "reduce_ei"));

		g_AmuletCustomCreated[id] = 1;
		SQL_FreeHandle(sqlQuery);
	}
	else
	{
		g_AmuletCustomCreated[id] = 0;
		SQL_FreeHandle(sqlQuery);
	}

	if(!g_AmuletCustomCreated[id])
	{
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM zp6_amulets WHERE acc_id='%d' AND active='1';", g_AccountId[id]);

		if(!SQL_Execute(sqlQuery))
			executeQuery(id, sqlQuery, 0036);
		else if(SQL_NumResults(sqlQuery))
		{
			new iSlot;
			while(SQL_MoreResults(sqlQuery))
			{
				iSlot = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "amulet_id"));

				SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "name"), g_AmuletsName[id][iSlot], charsmax(g_AmuletsName[][]));
				g_AmuletsInt[id][iSlot][0] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "health"));
				g_AmuletsInt[id][iSlot][1] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "speed"));
				g_AmuletsInt[id][iSlot][2] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "gravity"));
				g_AmuletsInt[id][iSlot][3] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "damage"));
				g_AmuletsInt[id][iSlot][4] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "mult_aps"));
				g_AmuletsInt[id][iSlot][5] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "mult_xp"));

				SQL_NextRow(sqlQuery);
			}
		}
		else
			SQL_FreeHandle(sqlQuery);
	}
}

public loadUser_Buys(const id)
{
	if(g_BuyStuff[id])
	{
		new Handle:sqlQuery;
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT class, ammopacks, p_humans, p_zombies, p_legacy, p_specials, p_diammonds FROM zp6_buys WHERE acc_id='%d' AND bought_ok='0';", g_AccountId[id]);

		if(!SQL_Execute(sqlQuery))
			executeQuery(id, sqlQuery, 37);
		else if(SQL_NumResults(sqlQuery))
		{
			new iClass;
			new iAPs;
			new iPh;
			new iPz;
			new iPl;
			new iPs;
			new iPd;

			while(SQL_MoreResults(sqlQuery))
			{
				iClass = SQL_ReadResult(sqlQuery, 0);
				iAPs = SQL_ReadResult(sqlQuery, 1);
				iPh = SQL_ReadResult(sqlQuery, 2);
				iPz = SQL_ReadResult(sqlQuery, 3);
				iPl = SQL_ReadResult(sqlQuery, 4);
				iPs = SQL_ReadResult(sqlQuery, 5);
				iPd = SQL_ReadResult(sqlQuery, 6);

				if(iClass)
				{
					g_Class[id] = iClass;

					dg_color_chat(id, _, "Tu compra de la !gclase %s!y se acreditó con éxito", __CLASSES[iClass][className]);
				}

				if(iAPs || iPh || iPz || iPl || iPs || iPd)
				{
					g_AmmoPacks[id] += iAPs;
					g_Points[id][POINT_HUMAN] += iPh;
					g_Points[id][POINT_ZOMBIE] += iPz;
					g_Points[id][POINT_LEGACY] += iPl;
					g_Points[id][POINT_SPECIAL] += iPs;
					g_Points[id][POINT_DIAMMONDS] += iPd;

					dg_color_chat(id, _, "Tu compra de !g%d APs!y, !g%d pH!y, !g%d pZ!y, !g%d pL!y, !g%d pE!y y !g%d Diamantes!y se acreditó con éxito", iAPs, iPh, iPz, iPl, iPs, iPd);
				}

				SQL_NextRow(sqlQuery);
			}

			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_pjs SET bought_ok='0' WHERE acc_id='%d';", g_AccountId[id]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 38);
			else
				SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE zp6_buys SET bought_ok='1' WHERE acc_id='%d';", g_AccountId[id]);

			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 39);
			else
				SQL_FreeHandle(sqlQuery);

			g_BuyStuff[id] = 0;
		}
		else
		{
			g_BuyStuff[id] = 0;
			SQL_FreeHandle(sqlQuery);
		}
	}
}

public loadUser_Rank(const id) {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT COUNT(acc_id) AS rank FROM zp6_pjs u WHERE ((u.level + (u.reset * 1000)) > (SELECT (level + (reset * 1000)) FROM zp6_pjs u2 WHERE u2.acc_id='%d') OR ((u.level + (u.reset * 1000)) = (SELECT (level + (reset * 1000)) FROM zp6_pjs u2 WHERE u2.acc_id='%d') AND u.acc_id<='%d'));", g_AccountId[id], g_AccountId[id], g_AccountId[id]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 205);
	} else if(SQL_NumResults(sqlQuery)) {
		g_AccountRank[id] = SQL_ReadResult(sqlQuery, 0);
		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	set_task(10.0, "task__CheckAchievements", id);
}

public loadInfo_End(const id) {
	g_LoadingData_Percent[id] = 100;
	showMessage_LoadingData(id);

	checkMults(id);

	remove_task(id + TASK_SAVE);
	set_task(random_float(300.0, 600.0), "task__Save", id + TASK_SAVE, .flags="b");

	g_AccountLogged[id] = 1;
	g_LoadingData[id] = 0;
	g_SysTime_Connect[id] = get_systime();

	showMenu__Join(id);
}

public saveInfo(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	if(!g_AccountLogged[id]) {
		return;
	}

	if(g_LoadingData[id]) {
		return;
	}

	if(g_DataSaved) {
		return;
	}

	if(disconnect) {
		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_accounts SET ip=^"%s^", steam=^"%s^", last_connection=UNIX_TIMESTAMP() WHERE id='%d';", g_PlayerIp[id], g_PlayerSteamId[id], g_AccountId[id]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		if(g_ClanSlot[id]) {
			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_clans SET kill_done='%d', infect_done='%d' WHERE id='%d';", g_Clan[g_ClanSlot[id]][clanKillDone], g_Clan[g_ClanSlot[id]][clanInfectDone], g_Clan[g_ClanSlot[id]][clanId]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_clans_members SET last_connection=UNIX_TIMESTAMP() WHERE clan_id='%d' AND acc_id='%d';", g_Clan[g_ClanSlot[id]][clanId], g_AccountId[id]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		}
	}

	static sWeapons[12];
	static sEICost[256];
	static sEICount[256];
	static sModels[128];
	static sModelSelected[12];
	static sDifficults[12];
	static sPoints[64];
	static sPointsLose[64];
	static sHabs[128];
	static sColorHudG[16];
	static sColorHudC[16];
	static sColorHudCC[16];
	static sColorNvision[16];
	static sColorFlare[16];
	static sColorClanGlow[16];
	static sHudPosition[structIdHudsType][32];
	static sHudEffect[12];
	static sHudMin[12];
	static sHudAbr[12];
	static sHeadZombies[128];
	static iLen;
	static i;

	arrayToString(g_Weapons[id], structIdWeapons, sWeapons, charsmax(sWeapons), 1);
	arrayToString(g_ExtraItem_Cost[id], structIdExtraItems, sEICost, charsmax(sEICost), 1);
	arrayToString(g_ExtraItem_Count[id], structIdExtraItems, sEICount, charsmax(sEICount), 1);
	arrayToString(g_Models[id], sizeof(MODELS), sModels, charsmax(sModels), 1);
	arrayToString(g_ModelSelected[id], structIdModelClasses, sModelSelected, charsmax(sModelSelected), 1);
	arrayToString(g_Difficult[id], structIdDifficultsClasses, sDifficults, charsmax(sDifficults), 1);
	arrayToString(g_Points[id], structIdPoints, sPoints, charsmax(sPoints), 1);
	arrayToString(g_PointsLose[id], structIdPoints, sPointsLose, charsmax(sPointsLose), 1);
	arrayToString(g_Habs[id], structIdHabs, sHabs, charsmax(sHabs), 1);
	arrayToString(g_UserOption_Color[id][COLOR_TYPE_HUD_G], 3, sColorHudG, charsmax(sColorHudG), 1);
	arrayToString(g_UserOption_Color[id][COLOR_TYPE_HUD_C], 3, sColorHudC, charsmax(sColorHudC), 1);
	arrayToString(g_UserOption_Color[id][COLOR_TYPE_HUD_CC], 3, sColorHudCC, charsmax(sColorHudCC), 1);
	arrayToString(g_UserOption_Color[id][COLOR_TYPE_NVISION], 3, sColorNvision, charsmax(sColorNvision), 1);
	arrayToString(g_UserOption_Color[id][COLOR_TYPE_FLARE], 3, sColorFlare, charsmax(sColorFlare), 1);
	arrayToString(g_UserOption_Color[id][COLOR_TYPE_CLAN_GLOW], 3, sColorClanGlow, charsmax(sColorClanGlow), 1);
	formatex(sHudPosition[HUD_TYPE_GENERAL], charsmax(sHudPosition[]), "%0.2f %0.2f %0.2f", g_UserOption_PositionHud[id][HUD_TYPE_GENERAL][0], g_UserOption_PositionHud[id][HUD_TYPE_GENERAL][1], g_UserOption_PositionHud[id][HUD_TYPE_GENERAL][2]);
	formatex(sHudPosition[HUD_TYPE_COMBO], charsmax(sHudPosition[]), "%0.2f %0.2f %0.2f", g_UserOption_PositionHud[id][HUD_TYPE_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][1], g_UserOption_PositionHud[id][HUD_TYPE_COMBO][2]);
	formatex(sHudPosition[HUD_TYPE_CLAN_COMBO], charsmax(sHudPosition[]), "%0.2f %0.2f %0.2f", g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][0], g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][1], g_UserOption_PositionHud[id][HUD_TYPE_CLAN_COMBO][2]);
	arrayToString(g_UserOption_EffectHud[id], structIdHudsType, sHudEffect, charsmax(sHudEffect), 1);
	arrayToString(g_UserOption_MinimizeHud[id], structIdHudsType, sHudMin, charsmax(sHudMin), 1);
	arrayToString(g_UserOption_AbreviateHud[id], structIdHudsType, sHudAbr, charsmax(sHudAbr), 1);
	arrayToString(g_HeadZombie[id], structIdHeadZombies, sHeadZombies, charsmax(sHeadZombies), 1);

	iLen = formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_pjs ");
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "SET class='%d', class_petition_mode='%d', ammopacks='%d', exp='%d', level='%d', reset='%d', ", clamp(g_Class[id], 0, charsmax(__CLASSES)), g_ClassPetitionMode[id], clamp(g_AmmoPacks[id], 0, MAX_APS), clamp(g_Exp[id], 0, MAX_XP), clamp(g_Level[id], 1, MAX_LEVEL), clamp(g_Reset[id], 0, MAX_RESET));
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "weapons=^"%s^", ei_cost=^"%s^", ei_count=^"%s^", models=^"%s^", model_selected=^"%s^", difficults=^"%s^", points=^"%s^", points_lose=^"%s^", habs=^"%s^", ", sWeapons, sEICost, sEICount, sModels, sModelSelected, sDifficults, sPoints, sPointsLose, sHabs);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "color_hud_g=^"%s^", color_hud_c=^"%s^", color_hud_cc=^"%s^", color_nvision=^"%s^", color_flare=^"%s^", color_clan_glow=^"%s^", ", sColorHudG, sColorHudC, sColorHudCC, sColorNvision, sColorFlare, sColorClanGlow);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "hud_pos_g=^"%s^", hud_pos_c=^"%s^", hud_pos_cc=^"%s^", hud_effect=^"%s^", hud_min=^"%s^", hud_abr=^"%s^", uo_chatmode='%d', uo_invis='%d', uo_clanchat='%d', ", sHudPosition[HUD_TYPE_GENERAL], sHudPosition[HUD_TYPE_COMBO], sHudPosition[HUD_TYPE_CLAN_COMBO], sHudEffect, sHudMin, sHudAbr, g_UserOption_ChatMode[id], g_UserOption_Invis[id], g_UserOption_ClanChat[id]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "hat_id='%d', amulet_id='%d', head_zombies=^"%s^" ", g_HatId[id], g_AmuletEquip[id], sHeadZombies);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "WHERE acc_id='%d';", g_AccountId[id]);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), g_SqlQuery);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	iLen = formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_pjs_stats ");
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "SET as_terrorist='%d', as_hitman='%d', as_terror_existe='%d', as_resistencia='%d', as_albert_wesker='%d', ", g_AchievementSecret_Terrorist[id], g_AchievementSecret_Hitman[id], g_AchievementSecret_Nemesis[id], g_AchievementSecret_Resistencia[id], g_AchievementSecret_Albert[id]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "time_played=`time_played`+'%d', dmg_d='%f', dmg_t='%f', hs_d='%d', hs_t='%d', hm_d='%d', hm_t='%d', zm_d='%d', zm_t='%d', inf_d='%d', inf_t='%d', ", g_PlayedTime[id][TIME_SEC], g_StatsDamage[id][0], g_StatsDamage[id][1], g_Stats[id][STAT_HS_D], g_Stats[id][STAT_HS_T], g_Stats[id][STAT_HM_D], g_Stats[id][STAT_HM_T], g_Stats[id][STAT_ZM_D], g_Stats[id][STAT_ZM_T], g_Stats[id][STAT_INF_D], g_Stats[id][STAT_INF_T]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "zmhs_d='%d', zmhs_t='%d', zmk_d='%d', zmk_t='%d', ap_d='%d', ap_t='%d', combo_max='%d', ", g_Stats[id][STAT_ZMHS_D], g_Stats[id][STAT_ZMHS_T], g_Stats[id][STAT_ZMK_D], g_Stats[id][STAT_ZMK_T], g_Stats[id][STAT_AP_D], g_Stats[id][STAT_AP_T], g_Stats[id][STAT_COMBO_MAX]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "s_m_c='%d', s_m_win='%d', s_m_lose='%d', s_m_kill='%d', w_m_c='%d', w_m_win='%d', w_m_lose='%d', w_m_kill='%d', ", g_Stats[id][STAT_S_M_C], g_Stats[id][STAT_S_M_WIN], g_Stats[id][STAT_S_M_LOSE], g_Stats[id][STAT_S_M_KILL], g_Stats[id][STAT_W_M_C], g_Stats[id][STAT_W_M_WIN], g_Stats[id][STAT_W_M_LOSE], g_Stats[id][STAT_W_M_KILL]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "sn_m_c='%d', sn_m_win='%d', sn_m_lose='%d', sn_m_kill='%d', j_m_c='%d', j_m_win='%d', j_m_lose='%d', j_m_kill='%d', ", g_Stats[id][STAT_SN_M_C], g_Stats[id][STAT_SN_M_WIN], g_Stats[id][STAT_SN_M_LOSE], g_Stats[id][STAT_SN_M_KILL], g_Stats[id][STAT_J_M_C], g_Stats[id][STAT_J_M_WIN], g_Stats[id][STAT_J_M_LOSE], g_Stats[id][STAT_J_M_KILL]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "n_m_c='%d', n_m_win='%d', n_m_lose='%d', n_m_kill='%d', a_m_c='%d', a_m_win='%d', a_m_lose='%d', a_m_kill='%d', ", g_Stats[id][STAT_N_M_C], g_Stats[id][STAT_N_M_WIN], g_Stats[id][STAT_N_M_LOSE], g_Stats[id][STAT_N_M_KILL], g_Stats[id][STAT_A_M_C], g_Stats[id][STAT_A_M_WIN], g_Stats[id][STAT_A_M_LOSE], g_Stats[id][STAT_A_M_KILL]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "an_m_c='%d', an_m_win='%d', an_m_lose='%d', an_m_kill='%d', f_m_c='%d', f_m_win='%d', f_m_lose='%d', f_m_kill='%d', ", g_Stats[id][STAT_AN_M_C], g_Stats[id][STAT_AN_M_WIN], g_Stats[id][STAT_AN_M_LOSE], g_Stats[id][STAT_AN_M_KILL], g_Stats[id][STAT_F_M_C], g_Stats[id][STAT_F_M_WIN], g_Stats[id][STAT_F_M_LOSE], g_Stats[id][STAT_F_M_KILL]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "t_m_c='%d', t_m_win='%d', t_m_lose='%d', t_m_kill='%d', ", g_Stats[id][STAT_T_M_C], g_Stats[id][STAT_T_M_WIN], g_Stats[id][STAT_T_M_LOSE], g_Stats[id][STAT_T_M_KILL]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "duel_win='%d', duel_lose='%d', duel_final_wins='%d', gg_wins='%d' ", g_Stats[id][STAT_DUEL_WIN], g_Stats[id][STAT_DUEL_LOSE], g_Stats[id][STAT_DUEL_FINAL_WINS], g_Stats[id][STAT_GG_WINS]);
	iLen += formatex(g_SqlQuery[iLen], charsmax(g_SqlQuery) - iLen, "WHERE acc_id='%d';", g_AccountId[id]);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), g_SqlQuery);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	for(i = 1; i < 31; ++i) {
		if(!g_WeaponSave[id][i]) {
			continue;
		}

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE zp6_weapons SET damage_done='%f', kill_done='%d', time_played_done='%d', points='%d', level='%d', skill_damage='%d', skill_speed='%d', skill_recoil='%d', skill_maxclip='%d', damage_s_done='%f', kill_s_done='%d' WHERE acc_id='%d' AND weapon_id='%d';", g_WeaponData[id][i][WEAPON_DATA_DAMAGE_DONE], g_WeaponData[id][i][WEAPON_DATA_KILL_DONE], g_WeaponData[id][i][WEAPON_DATA_TIME_PLAYED_DONE], g_WeaponData[id][i][WEAPON_DATA_POINTS], g_WeaponData[id][i][WEAPON_DATA_LEVEL], g_WeaponSkills[id][i][WEAPON_SKILL_DAMAGE], g_WeaponSkills[id][i][WEAPON_SKILL_SPEED], g_WeaponSkills[id][i][WEAPON_SKILL_RECOIL], g_WeaponSkills[id][i][WEAPON_SKILL_MAXCLIP], g_WeaponData[id][i][WEAPON_DATA_DAMAGE_S_DONE], g_WeaponData[id][i][WEAPON_DATA_KILL_S_DONE], g_AccountId[id], i);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		g_WeaponSave[id][i] = 0;
	}
}

public sqlThread__IgnoreQuery(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	if(fail_state != TQUERY_SUCCESS) {
		dg_log_to_file(LOG_MYSQL, 1, iId, "sqlThread__IgnoreQuery - %d - %s", error_num, error);
	}
}

public showMessage_LoadingData(const id) {
	client_print(id, print_center, "Cargando tus datos... (%d por ciento)", g_LoadingData_Percent[id]);
}