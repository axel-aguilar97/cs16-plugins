#include <dg>
#include <dg_accounts>

#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <fun>
#include <xs>

#include <td4>

#pragma semicolon 1;

/*
	- Se arregló un problema con los logros FALTA DE DEFENSORES y PROTECCIÓN NULA.
	- Se arregló un problema con la Hitbox de los models de los Monstruos y Jefes.
	- Se modificó el logro "PODER: BALAS INFINITAS". Ahora para hacerlo, requerirán TODOS los Jefes en Suicidal.
	- Se arregló un problema con al mover las torretas de lugar.
	- Se aumentó la vida de los Monstruos

	TODO:
	¿Aimbot?
	Cambiar requerimiento del logro PODER: BALAS INFINITAS >>> Ahora que se consiga pasando todos los jefes en SUICIDAL
	Testear el robot
	Top15 (foro)
	PQ > TQ
	Hacer un comando para fixear mapas que haya rampas (mapas nuevos)
	Buffear la granada de explosión

	==========================================

	MODULARIZAR PLUGIN
	 - Walkguard
	 - Plugin Main
	 - Bosses
*/

new const __PLUGIN_NAME[] = "Tower Defense";
new const __PLUGIN_VERSION[] = "v4.1a";
new const __PLUGIN_AUTHOR[] = "Atsul.P";
new const __PLUGIN_AUTHOR_ORIGINAL[] = "KISKE";

const HEALTH_BASE = 100;
const HEALTH_BASE_BOSS_GORILLA = 500;
const HEALTH_BASE_BOSS_FIRE_MONSTER = 600;
const HEALTH_BASE_BOSS_FALLEN_TITAN = 750;
const HEALTH_BASE_BOSS_GUARDIANES_DE_KYRA = 1000;

const Float:MIN_VELOCITY_HUMAN = 240.0;
const Float:MAX_VELOCITY_HUMAN = 340.0;

const MAX_SLOTS = 15;
const MAX_ZONES = 10;
const MAX_WAVES = 10;
const MAX_SENTRIES_PER_PLAYER = 3;
const MAX_VOTEMAP = 5;

const AFK_TIME_KICK = 45;
const SENTRY_DAMAGE_NEED = 500; // Daño necesario para que la torreta haga oro

const SENTRY_COST = 1500;
const ROBOT_COST = 2000;

const OFFSET_LINUX_WEAPONS = 4;
const OFFSET_LINUX = 5;
const OFFSET_WEAPONOWNER = 41;
const OFFSET_ID = 43;
const OFFSET_KNOWN = 44;
const OFFSET_NEXT_PRIMARY_ATTACK = 46;
const OFFSET_NEXT_SECONDARY_ATTACK = 47;
const OFFSET_TIME_WEAPON_IDLE = 48;
const OFFSET_PRIMARY_AMMO_TYPE = 49;
const OFFSET_CLIPAMMO = 51;
const OFFSET_IN_RELOAD = 54;
const OFFSET_IN_SPECIAL_RELOAD = 55;
const OFFSET_SILENT = 74;
const OFFSET_NEXT_ATTACK = 83;
const OFFSET_AMMO_PLAYER_SLOT0 = 376;
const OFFSET_M3_AMMO = 381;

const MONSTER_TYPE = EV_INT_iuser1;
const MONSTER_TRACK = EV_INT_iuser2;
const MONSTER_MAXHEALTH = EV_INT_iuser3;
const MONSTER_TARGET = EV_INT_iuser4;
const MONSTER_LOW_FPS = EV_INT_iStepLeft;
const MONSTER_UNIQUE = EV_INT_flDuckTime;
const MONSTER_SPEED = EV_FL_fuser1;
const MONSTER_SHIELD = EV_FL_fuser2;
const MONSTER_HEALTHBAR = EV_ENT_euser1;

const SENTRY_INT_FIRE = EV_INT_iuser1;
const SENTRY_OWNER = EV_INT_iuser2;
const SENTRY_INT_LEVEL = EV_INT_iuser3;
const SENTRY_CLIP = EV_INT_iuser4;
const SENTRY_LOW_FPS = EV_INT_team;
const SENTRY_ENT_TARGET = EV_ENT_euser1;
const BASE_ENT_SENTRY = EV_ENT_euser1;
const SENTRY_ENT_BASE = EV_ENT_euser2;
const SENTRY_PARAM_01 = EV_FL_fuser1;
const SENTRY_MAXCLIP = EV_FL_fuser2;
const SENTRY_EXTRA_DAMAGE = EV_FL_fuser3;
const SENTRY_EXTRA_RATIO = EV_FL_fuser4;
const SENTRY_TILT_LV4 = EV_BYTE_controller1;
const SENTRY_TILT_TURRET = EV_BYTE_controller2;
const SENTRY_TILT_LAUNCHER = EV_BYTE_controller3;
const SENTRY_TILT_RADAR = EV_BYTE_controller4;

const ROBOT_INT_HEALTH = EV_INT_iuser1;
const ROBOT_INT_FIRE = EV_INT_iuser2;
const ROBOT_INT_BLOCKED = EV_INT_iuser3;
const ROBOT_INT_COMPLETED = EV_INT_iuser4;
const ROBOT_ENT_TARGET = EV_ENT_euser1;

const WEAPONS_SILENT_BIT_SUM = (1<<_:WEAPON_USP)|(1<<_:WEAPON_M4A1);
const UNIT_SECOND = (1<<12);
const SF_FADE_OUT = 0x0000;

enum _:structIdRobotSequences {
	ROBOT_APPEAR = 1,
	ROBOT_IDLE,
	ROBOT_DEATH = 4,
	ROBOT_FIRE = 9,
	ROBOT_START_MISSILE = 11,
	ROBOT_MISSILE,
	ROBOT_STOP_MISSILE
};

enum _:structIdTasks (+= 236877) {
	TASK_SPAWN = 54276,
	TASK_SAVE,
	TASK_TIME_PLAYED,
	TASK_CHECK_ACHIEVEMENTS,
	TASK_CLASS_POWER,

	TASK_SHOW_ZONE,
	TASK_DAMAGE_TOWER,
	TASK_SENTRY_THINK,
	TASK_ION_BOMB_EXPLODE,

	TASK_START_GAME,
	TASK_WAVES,
	TASK_REGEN_TOWER,
	TASK_ALLOW_ANOTHER_MONSTER,
	TASK_BUGFIX,
	TASK_VOTEMAP_END
};

enum _:structIdNadeTypes (+= 1111) {
	NADE_TYPE_EXPLOSION = 1111,
	NADE_TYPE_REMUEVE_PROTECCION,
	NADE_TYPE_AUMENTA_DMG_RECIBIDO,
	NADE_TYPE_ION_BOMB
};

enum _:structIdMaps {
	TD_KMID = 0,
	TD_ORANGE,
	TD_KWOOL_SMALL,
	TD_GEMPIRE,
	TD_DARK_NIGHT,
	TD_KHELL,
	TD_CASTLE_X2, 
	TD_KSUB,
	TD_KSUB_WOOL,
	TD_KWHITE,
	TD_PLAZA2,
	TD_KWOOL_X2,
	TD_CITY2,
	TD_MINECRAFT,
	TD_OLD_DUST,
	TD_DEATH
};

enum _:structIdMonstersType {
	MONSTER_TYPE_NORMAL = 240,
	MONSTER_TYPE_SPECIAL_SPEED,
	MONSTER_TYPE_SPECIAL_STRENGTH,
	MONSTER_TYPE_EGG,
	MONSTER_TYPE_BOOMER,
	MONSTER_TYPE_BOSS
};

enum _:structIdMonsters {
	MONSTER_NORMAL = 0,
	MONSTER_ALIEN,
	MONSTER_TANK
};

enum _:structIdBossCoords {
	__X = 0,
	__Y,
	__Z
};

enum _:structIdBosses {
	BOSS_GORILA = 0,
	BOSS_FIRE,
	BOSS_FALLEN_TITAN,
	BOSS_GUARDIANES
};

enum _:structIdBossesPowers {
	// GORILA
	BOSS_POWER_ROLL = 1,
	BOSS_POWER_EGGS,
	BOSS_POWER_ATTRACT,
	
	// FIRE MONSTER
	BOSS_POWER_DASH,
	BOSS_POWER_FIREBALL_X2,
	BOSS_POWER_FIREBALL_X4,
	BOSS_POWER_EXPLODE,
	BOSS_POWER_FIREBALL_RAIN,

	// FALLEN TITAN
	BOSS_FT_DASH,
	BOSS_FT_SCREAM,
	BOSS_FT_CANNON,
	BOSS_FT_HIPER_CANNON,
	BOSS_FT_TENTACLES

	// GUARDIANES ¿?
};

enum _:structIdClasses {
	CLASS_SOLDADO = 0, // Normal
	CLASS_INGENIERO, // Normal
	CLASS_SOPORTE, // Normal
	CLASS_FRANCOTIRADOR, // Normal
	CLASS_APOYO, // Por habilidad
	CLASS_PESADO, // Por habilidad
	CLASS_ASALTO, // Por habilidad
	CLASS_COMANDANTE, // Por habilidad
	CLASS_PISTOLERO, // Por logro
	CLASS_PUBERO, // VIP
	CLASS_LEGIONARIO, // VIP
	CLASS_BITERO, // VIP
	CLASS_SCOUTER // VIP
};

enum _:structIdDiffs {
	DIFF_NORMAL = 0,
	DIFF_NIGHTMARE,
	DIFF_SUICIDAL,
	DIFF_HELL
};

enum _:structIdHabs {
	HAB_DAMAGE = 0,
	HAB_PRECISION,
	HAB_SPEED_WEAPON,
	HAB_BULLETS
};

enum _:structIdFHabs {
	Float:HAB_F_DAMAGE,
	Float:HAB_F_PRECISION,
	Float:HAB_F_SPEED_WEAPON
};

enum _:structIdAchievementClasses {
	ACHIEVEMENT_CLASS_GENERALS = 0,
	ACHIEVEMENT_CLASS_WAVES,
	ACHIEVEMENT_CLASS_MAPS,
	ACHIEVEMENT_CLASS_BETA,
	ACHIEVEMENT_CLASS_BOSSES,
	ACHIEVEMENT_CLASS_POWERS
};

enum _:structIdAchievements {
	BETA_TESTER = 0, BETA_TESTER_AVANZADO,
	NIVEL_10, NIVEL_20, NIVEL_30, NIVEL_40, NIVEL_50, NIVEL_60, NIVEL_70, NIVEL_80, NIVEL_90, NIVEL_100,
	WAVES_NORMAL_100, WAVES_NORMAL_500, WAVES_NORMAL_1000, WAVES_NORMAL_2500, WAVES_NORMAL_5000, WAVES_NORMAL_10K, WAVES_NORMAL_25K, WAVES_NORMAL_50K, WAVES_NORMAL_100K, WAVES_NORMAL_250K, WAVES_NORMAL_500K, WAVES_NORMAL_1M,
	NOOB_KMID, AVANZADO_KMID, EXPERTO_KMID, PRO_KMID,
	NOOB_ORANGE, AVANZADO_ORANGE, EXPERTO_ORANGE, PRO_ORANGE,
	NOOB_KWOOL, AVANZADO_KWOOL, EXPERTO_KWOOL, PRO_KWOOL,
	NOOB_KWHITE, AVANZADO_KWHITE, EXPERTO_KWHITE, PRO_KWHITE,
	NOOB_PLAZA, AVANZADO_PLAZA, EXPERTO_PLAZA, PRO_PLAZA,
	TUTORIAL,
	WAVES_NIGHTMARE_100, WAVES_NIGHTMARE_500, WAVES_NIGHTMARE_1000, WAVES_NIGHTMARE_2500, WAVES_NIGHTMARE_5000, WAVES_NIGHTMARE_10K, WAVES_NIGHTMARE_25K, WAVES_NIGHTMARE_50K, WAVES_NIGHTMARE_100K, WAVES_NIGHTMARE_250K, WAVES_NIGHTMARE_500K, WAVES_NIGHTMARE_1M,
	WAVES_SUICIDAL_100, WAVES_SUICIDAL_500, WAVES_SUICIDAL_1000, WAVES_SUICIDAL_2500, WAVES_SUICIDAL_5000, WAVES_SUICIDAL_10K, WAVES_SUICIDAL_25K, WAVES_SUICIDAL_50K, WAVES_SUICIDAL_100K, WAVES_SUICIDAL_250K, WAVES_SUICIDAL_500K, WAVES_SUICIDAL_1M,
	WAVES_HELL_100, WAVES_HELL_500, WAVES_HELL_1000, WAVES_HELL_2500, WAVES_HELL_5000, WAVES_HELL_10K, WAVES_HELL_25K, WAVES_HELL_50K, WAVES_HELL_100K, WAVES_HELL_250K, WAVES_HELL_500K, WAVES_HELL_1M,
	GOLD_10K, GOLD_50K, GOLD_100K, GOLD_500K, GOLD_1M, GOLD_2M500K, GOLD_5M, GOLD_10M, GOLD_25M, GOLD_50M, GOLD_100M, GOLD_500M, GOLD_1000M,
	MVP_1, MVP_10, MVP_25, MVP_50, MVP_100, MVP_250, MVP_500, MVP_1000, MVP_2500, MVP_5000, MVP_10K, MVP_25K, MVP_50K, MVP_100K, MVP_250K, MVP_500K, MVP_1M,
	VINCULADO,
	NOOB_GEMPIRE, AVANZADO_GEMPIRE, EXPERTO_GEMPIRE, PRO_GEMPIRE,
	MVP_2C, MVP_3C, MVP_4C, MVP_5C, MVP_6C, MVP_7C, MVP_8C, MVP_9C, MVP_10C,
	COMPRADOR_COMPULSIVO,
	NOOB_KGELL, AVANZADO_KGELL, EXPERTO_KGELL, PRO_KGELL,
	BOSS_GORILA_NOOB, BOSS_GORILA_AVANZADO, BOSS_GORILA_EXPERTO, BOSS_GORILA_PRO,
	BOSS_FIRE_NOOB, BOSS_FIRE_AVANZADO, BOSS_FIRE_EXPERTO, BOSS_FIRE_PRO,
	NOOB_DARK_NIGHT, AVANZADO_DARK_NIGHT, EXPERTO_DARK_NIGHT, PRO_DARK_NIGHT,
	DEFENSA_ABSOLUTA_NOOB, DEFENSA_ABSOLUTA_AVANZADO, DEFENSA_ABSOLUTA_EXPERTO, DEFENSA_ABSOLUTA_PRO,
	BOSS_GUARDIANES_NOOB, BOSS_GUARDIANES_AVANZADO, BOSS_GUARDIANES_EXPERTO, BOSS_GUARDIANES_PRO,
	TRAMPOSO,
	NOOB_KWOOL_X2, AVANZADO_KWOOL_X2, EXPERTO_KWOOL_X2, PRO_KWOOL_X2,
	BALAS_INFINITAS, AIMBOT,
	NOOB_MINECRAFT, AVANZADO_MINECRAFT, EXPERTO_MINECRAFT, PRO_MINECRAFT,
	NOOB_OLD_DUST, AVANZADO_OLD_DUST, EXPERTO_OLD_DUST, PRO_OLD_DUST,
	NOOB_CITY, AVANZADO_CITY, EXPERTO_CITY, PRO_CITY,
	GENERAL_666,
	NOOB_CASTLE, AVANZADO_CASTLE, EXPERTO_CASTLE, PRO_CASTLE,
	NOOB_KSUB, AVANZADO_KSUB, EXPERTO_KSUB, PRO_KSUB, KSUB_DEATH,
	BOSS_FIRE_DANCE, BOSS_FIRE_POR_POCO,
	NOOB_KSUB_WOOL, AVANZADO_KSUB_WOOL, EXPERTO_KSUB_WOOL, PRO_KSUB_WOOL,
	BOSS_FT_NOOB, BOSS_FT_AVANZADO, BOSS_FT_EXPERTO, BOSS_FT_PRO, BOSS_FT_HIT,
	PISTOLERO_UNLOCKED, LA_BONEASTE,
	NOOB_DEATH, AVANZADO_DEATH, EXPERTO_DEATH, PRO_DEATH,
	AVARICIOSO_TOTAL,
	PROTECTOR_NOOB, PROTECTOR_AVANZADO, PROTECTOR_EXPERTO, PROTECTOR_PRO,
	ENTRENANDO, ESTOY_MUY_SOLO, FOREVER_ALONE, CREO_QUE_TENGO_UN_PROBLEMA, SOLO_EL_TD_ME_ENTIENDE,
	FALTA_DE_DEFENSORES, PROTECCION_NULA,
	SOY_DORADO,
	HAGO_LO_QUE_PUEDO, YOU_SHALL_NOT_PASS, CARNICERO, EL_LIDER
};

enum _:structIdUpgrades {
	UPGRADE_CRITICAL = 0,
	UPGRADE_RESISTENCE,
	UPGRADE_THOR,
	UPGRADE_UNLOCK_APOYO,
	UPGRADE_UNLOCK_PESADO,
	UPGRADE_UNLOCK_ASALTO,
	UPGRADE_UNLOCK_COMANDANTE,
	UPGRADE_HEALTH,
	UPGRADE_VELOCITY
};

enum _:structIdTimePlayed {
	TIME_MIN = 0,
	TIME_HOUR,
	TIME_DAY
};

enum _:structIdRGB {
	__R = 0,
	__G,
	__B
};

enum _:structIdNades {
	NADE_EXPLOSION = 0,
	NADE_REMUEVE_PROTECCION,
	NADE_AUMENTA_DMG_RECIBIDO,
	NADE_ION_BOMB
};

enum _:structIdPowers {
	POWER_NONE = 0,
	POWER_RAYO,
	POWER_BALAS_INFINITAS,
	POWER_PRECISION_PERFECTA
};

enum _:structIdZones {
	ZONE_NOTHING = 0,
	ZONE_BLOCK_ALL,
	ZONE_KILL,
	ZONE_KILL_T1, // Zona bloqueada
	ZONE_KILL_T2, // Zona no bloqueada
	ZONE_BLOCK_ALL_2
};

enum _:structMaps {
	mapName[MAX_CHARACTER_MAPNAME],
	mapDesc[24],
	mapBlockDiff,
	mapAchievement,
	mapBossCoord,
	mapSpecial,
	mapTowerHealth,
	mapExtraMonsters,
	mapGordoHealth,
	mapLimitSentries,
	mapLimitRobots
};

enum _:structMapsFix {
	mapFixName[MAX_CHARACTER_MAPNAME],
	mapFixFunction[64]
};

enum _:structBosses {
	bossName[48],
	bossNameFF[32],
	bossAchievement
};

enum _:structLevels {
	levelKills,
	levelWaveNormal,
	levelWaveNightmare,
	levelWaveSuicidal,
	levelWaveHell,
	levelBossNormal,
	levelBossNightmare,
	levelBossSuicidal,
	levelBossHell
};

enum _:structClasses {
	className[32],
	classNameMay[32],
	classDesc[160],
	classDescLv1[96],
	classDescLv2[96],
	classDescLv3[128],
	classDescLv4[128],
	classDescLv5[256],
	classDescLv6[256],
	classReqLv1,
	classReqLv2,
	classReqLv3,
	classReqLv4,
	classReqLv5,
	classReqLv6,
	classReqLv7
};

enum _:structClassesAttrib {
	Float:classAttribSpeed,
	Float:classAttribRecoil,
	classAttribClip,
	Float:classAttribDamage,
	Float:classAttribSentryDamage,
	Float:classAttribSentryRecoil,
	classAttribSentryClip,
	classAttribExtraCritical
};

enum _:structDiffs {
	diffNameMin[32],
	diffNameMay[32],
	diffDesc[450]
};

enum _:structDiffsValues {
	diffValueHealth,
	Float:diffValueSpeed,
	diffValueGold,
	diffValueMaxMonsters,
	diffValueDamageTower,
	diffValueTowerRegen,
	diffValueExtraWaveSpeed,
	diffValueEggDamageSpeed,
	diffValueExtraWaveHeavy,
	diffValueEggExtra,
	diffValueBossHealth,
	Float:diffValueBossDamage
};

enum _:structHabs {
	habName[32],
	habNameMay[32],
	habDesc[128],
	Float:habValue,
	habMaxLevel
};

enum _:structAchievementClasses {
	achievementClassName[16],
	achievementClassNameIn[16]
};

enum _:structAchievements {
	achievementName[32],
	achievementInfo[128],
	achievementReward,
	achievementUsersNeedP,
	achievementUsersNeedA,
	achievementClass
};

enum _:structUpgrades {
	upgradeName[32],
	upgradeDesc[48],
	upgradeMaxLevel,
	upgradeValue,
	upgradeCost
};

enum _:structColors {
	colorName[16],
	colorRed,
	colorGreen,
	colorBlue
};

enum _:structWeapons {
	weaponEnt[32],
	weaponName[32],
	WeaponIdType:weaponId,
	weaponGold,
	weaponClassRecommended,
	weaponVIP,
	weaponLevelReq,
	weaponLimitUser,
	weaponLimit
};

enum _:structPowers {
	powerName[32],
	powerGold
};

enum _:structIdSentriesAnim {
	sentryAnimIddle,
	sentryAnimFire,
	sentryAnimSpin
};

enum _:structSentriesDamage {
	sentryMinDamage,
	sentryMaxDamage
};

new const __MAPS[structIdMaps][structMaps] = {
	// MAPNAME 				MAPDESC 			BLOCKDIFF 	ACHIEVEMENT 		BOSSCOORD 	SPECIAL 	TOWER HEALTH 	EXTRA MONSTERS 		BOOMER 		TORRETAS 	ROBOTS
	{"td_kmid", 			"", 				0, 			NOOB_KMID, 			__X, 		0, 			500,			0,					25000,		5,			1},
	{"td_orange", 			"", 				0, 			NOOB_ORANGE, 		__X, 		0, 			500, 			0,					50000,		5,			1},
	{"td_kwool_small", 		"", 				0, 			NOOB_KWOOL, 		__X, 		0, 			500, 			0,					15000,		4,			1},
	{"td_gempire", 			"", 				0, 			NOOB_GEMPIRE, 		__X, 		0, 			500, 			0,					25000,		5,			1},
	{"td_dark_night", 		"", 				0, 			NOOB_DARK_NIGHT,	__X, 		0, 			500, 			0,					20000,		5,			1},
	{"td_khell", 			"", 				0, 			NOOB_KGELL, 		__Y, 		2, 			1000, 			30,					15000,		4,			1},
	{"td_castle_x2-fix2", 	"", 				0, 			NOOB_CASTLE, 		__X, 		2, 			1000, 			30,					20000,		4,			1},
	{"td_ksub", 			"", 				0, 			NOOB_KSUB, 			__X, 		0, 			500, 			0,					15000,		3,			1},
	{"td_ksub_wool", 		" \r(NIGHTMARE+)", 	1, 			NOOB_KSUB_WOOL, 	__X, 		1, 			1000, 			40,					30000,		5,			1},
	{"td_kwhite", 			" \r(NIGHTMARE+)", 	1, 			NOOB_KWHITE, 		__X, 		0, 			500, 			0,					25000,		5,			1},
	{"td_plaza2", 			" \r(NIGHTMARE+)", 	1, 			NOOB_PLAZA, 		__X, 		0, 			500, 			0,					25000,		4,			1},
	{"td_kwool_x2", 		" \r(NIGHTMARE+)", 	1, 			NOOB_KWOOL_X2, 		__X, 		1, 			1000, 			40,					30000,		5,			1},
	{"td_city2", 			" \r(NIGHTMARE+)", 	1, 			NOOB_CITY, 			__X, 		0, 			500, 			0,					25000,		3,			1},
	{"td_minecraft", 		" \r(SUICIDAL+)", 	2, 			NOOB_MINECRAFT, 	__X, 		0, 			500, 			0,					50000,		5,			1},
	{"td_old_dust", 		" \r(SUICIDAL+)", 	2, 			NOOB_OLD_DUST, 		__X, 		0, 			500, 			0,					40000,		5,			1},
	{"td_death_b2", 		" \r(SUICIDAL+)", 	2, 			NOOB_DEATH, 		__X, 		1, 			1000, 			50,					50000,		5,			1}
	// td_dust_delta NORMAL 2
	// td_ultimate_b3 NIGHTMATE 0
	// td_colorbox HELL 0
};

new const __MAPS_FIX[][structMapsFix] = {
	{"td_kmid", "@Ham_KmidTouchFix_Post"},
	{"td_orange", "@Ham_OrangeTouchFix_Post"},
	{"td_dust_delta", "@Ham_DustDeltaTouchFix_Post"},
	{"td_ultimate_b3", "@Ham_UltimateTouchFix_Post"}
};

new const __BOSSES_NAME[structIdBosses][structBosses] = {
	{"Gorila \y(NORMAL)", "Gorila", BOSS_GORILA_NOOB},
	{"Fire Monster \y(NIGHTMARE)", "Fire Monster", BOSS_FIRE_NOOB},
	{"Fallen Titan \y(SUICIDAL)", "Fallen Titan", BOSS_FT_NOOB},
	{"Guardianes de Kyra \y(HELL)", "Guardianes de Kyra", BOSS_GUARDIANES_NOOB}
};

new const __LEVELS[101][structLevels] = {
	{25, 5, 0, 0, 0, 0, 0, 0, 0},
	{50, 10, 0, 0, 0, 0, 0, 0, 0},
	{75, 15, 0, 0, 0, 0, 0, 0, 0},
	{100, 20, 0, 0, 0, 0, 0, 0, 0},
	{150, 25, 0, 0, 0, 0, 0, 0, 0},
	{200, 30, 0, 0, 0, 0, 0, 0, 0},
	{250, 35, 0, 0, 0, 0, 0, 0, 0},
	{300, 40, 0, 0, 0, 0, 0, 0, 0},
	{350, 50, 0, 0, 0, 0, 0, 0, 0},
	{400, 60, 0, 0, 0, 1, 0, 0, 0},
	{500, 70, 0, 0, 0, 2, 0, 0, 0},
	{650, 80, 0, 0, 0, 3, 0, 0, 0},
	{800, 100, 0, 0, 0, 4, 0, 0, 0},
	{1000, 125, 0, 0, 0, 5, 0, 0, 0},
	{1250, 150, 0, 0, 0, 6, 0, 0, 0},
	{1500, 175, 0, 0, 0, 7, 0, 0, 0},
	{2000, 200, 0, 0, 0, 8, 0, 0, 0},
	{3000, 250, 0, 0, 0, 9, 0, 0, 0},
	{4500, 300, 0, 0, 0, 10, 0, 0, 0},
	{6000, 400, 0, 0, 0, 12, 0, 0, 0},
	{8000, 500, 0, 0, 0, 14, 0, 0, 0},
	{10000, 600, 0, 0, 0, 16, 0, 0, 0},
	{12500, 700, 0, 0, 0, 18, 0, 0, 0},
	{15000, 800, 0, 0, 0, 20, 0, 0, 0},
	{17500, 1000, 0, 0, 0, 25, 0, 0, 0},
	
	{20000, 0, 10, 0, 0, 0, 2, 0, 0},
	{25000, 0, 20, 0, 0, 0, 4, 0, 0},
	{30000, 0, 30, 0, 0, 0, 6, 0, 0},
	{35000, 0, 40, 0, 0, 0, 8, 0, 0},
	{40000, 0, 50, 0, 0, 0, 10, 0, 0},
	{45000, 0, 60, 0, 0, 0, 12, 0, 0},
	{50000, 0, 70, 0, 0, 0, 14, 0, 0},
	{55000, 0, 80, 0, 0, 0, 16, 0, 0},
	{60000, 0, 90, 0, 0, 0, 18, 0, 0},
	{65000, 0, 100, 0, 0, 0, 20, 0, 0},
	{70000, 0, 125, 0, 0, 0, 22, 0, 0},
	{75000, 0, 150, 0, 0, 0, 24, 0, 0},
	{90000, 0, 175, 0, 0, 0, 26, 0, 0},
	{100000, 0, 200, 0, 0, 0, 28, 0, 0},
	{110000, 0, 225, 0, 0, 0, 30, 0, 0},
	{120000, 0, 250, 0, 0, 0, 32, 0, 0},
	{130000, 0, 275, 0, 0, 0, 34, 0, 0},
	{140000, 0, 300, 0, 0, 0, 36, 0, 0},
	{150000, 0, 325, 0, 0, 0, 38, 0, 0},
	{160000, 0, 350, 0, 0, 0, 40, 0, 0},
	{170000, 0, 450, 0, 0, 0, 42, 0, 0},
	{180000, 0, 500, 0, 0, 0, 44, 0, 0},
	{190000, 0, 600, 0, 0, 0, 46, 0, 0},
	{200000, 0, 750, 0, 0, 0, 48, 0, 0},
	{215000, 0, 1000, 0, 0, 0, 50, 0, 0},
	
	{230000, 0, 0, 15, 0, 0, 0, 2, 0},
	{245000, 0, 0, 30, 0, 0, 0, 4, 0},
	{260000, 0, 0, 45, 0, 0, 0, 6, 0},
	{275000, 0, 0, 60, 0, 0, 0, 8, 0},
	{290000, 0, 0, 75, 0, 0, 0, 10, 0},
	{310000, 0, 0, 90, 0, 0, 0, 12, 0},
	{325000, 0, 0, 115, 0, 0, 0, 14, 0},
	{340000, 0, 0, 130, 0, 0, 0, 16, 0},
	{365000, 0, 0, 150, 0, 0, 0, 18, 0},
	{380000, 0, 0, 175, 0, 0, 0, 20, 0},
	{400000, 0, 0, 200, 0, 0, 0, 22, 0},
	{420000, 0, 0, 220, 0, 0, 0, 24, 0},
	{440000, 0, 0, 240, 0, 0, 0, 26, 0},
	{460000, 0, 0, 275, 0, 0, 0, 28, 0},
	{480000, 0, 0, 325, 0, 0, 0, 30, 0},
	{500000, 0, 0, 375, 0, 0, 0, 35, 0},
	{520000, 0, 0, 425, 0, 0, 0, 40, 0},
	{540000, 0, 0, 475, 0, 0, 0, 45, 0},
	{568000, 0, 0, 525, 0, 0, 0, 50, 0},
	{580000, 0, 0, 600, 0, 0, 0, 60, 0},
	{600000, 0, 0, 700, 0, 0, 0, 70, 0},
	{620000, 0, 0, 800, 0, 0, 0, 80, 0},
	{640000, 0, 0, 900, 0, 0, 0, 90, 0},
	{660000, 0, 0, 1000, 0, 0, 0, 100, 0},
	{680000, 0, 0, 1250, 0, 0, 0, 125, 0},
	
	{700000, 0, 0, 0, 10, 0, 0, 0, 1},
	{720000, 0, 0, 0, 20, 0, 0, 0, 2},
	{740000, 0, 0, 0, 30, 0, 0, 0, 3},
	{760000, 0, 0, 0, 40, 0, 0, 0, 4},
	{780000, 0, 0, 0, 50, 0, 0, 0, 5},
	{800000, 0, 0, 0, 60, 0, 0, 0, 6},
	{820000, 0, 0, 0, 70, 0, 0, 0, 7},
	{840000, 0, 0, 0, 80, 0, 0, 0, 8},
	{860000, 0, 0, 0, 90, 0, 0, 0, 9},
	{880000, 0, 0, 0, 100, 0, 0, 0, 10},
	{900000, 0, 0, 0, 125, 0, 0, 0, 11},
	{920000, 0, 0, 0, 150, 0, 0, 0, 12},
	{940000, 0, 0, 0, 175, 0, 0, 0, 13},
	{960000, 0, 0, 0, 200, 0, 0, 0, 14},
	{980000, 0, 0, 0, 250, 0, 0, 0, 15},
	{1000000, 0, 0, 0, 300, 0, 0, 0, 16},
	{1100000, 0, 0, 0, 350, 0, 0, 0, 17},
	{1280000, 0, 0, 0, 400, 0, 0, 0, 18},
	{1300000, 0, 0, 0, 500, 0, 0, 0, 19},
	{1400000, 0, 0, 0, 600, 0, 0, 0, 20},
	{1500000, 0, 0, 0, 700, 0, 0, 0, 21},
	{1600000, 0, 0, 0, 800, 0, 0, 0, 22},
	{1750000, 0, 0, 0, 900, 0, 0, 0, 23},
	{2000000, 0, 0, 0, 1000, 0, 0, 0, 25},
	{2500000, 0, 0, 0, 2000, 0, 0, 0, 30},
	
	{2100000000, 0, 0, 0, 2100000000, 0, 0, 0, 2100000000}
};

new const __CLASSES[structIdClasses][structClasses] = {
	{
		"Soldado", // KILLS
		"SOLDADO",
		"\wEfectivo con \yM4A1 Carbine\w y \yAK-47 Kalashnikov\w",
		"\r* \y+10% \wVelocidad de disparo^n\r* \y+5% \wPrecisión al disparar",
		"\r* \y+15% \wVelocidad de disparo^n\r* \y+10% \wPrecisión al disparar",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+15% \wPrecisión al disparar",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+20% \wPrecisión al disparar^n\r* \y+5 \wBalas extras",
		"\r* \y+30% \wVelocidad de disparo^n\r* \y+30% \wPrecisión al disparar^n\r* \y+10 \wBalas extras",
		"\r* \y+40% \wVelocidad de disparo^n\r* \y+40% \wPrecisión al disparar^n\r* \y+15 \wBalas extras^n\r* \wComienzas con \yM4A1 Carbine\w",
		1500, 4500, 10000, 50000, 100000, 250000, 2100999999
	},
	{
		"Ingeniero", // DAÑO CON TORRETAS
		"INGENIERO",
		"\wEl daño de sus torretas generan \yOro\w para el creador",
		"\r* \y+7% \wDaño de torretas^n\r* \y+5% \wPrecisión de torretas",
		"\r* \y+14% \wDaño de torretas^n\r* \y+10% \wPrecisión de torretas",
		"\r* \y+21% \wDaño de torretas^n\r* \y+15% \wPrecisión de torretas",
		"\r* \y+28% \wDaño de torretas^n\r* \y+20% \wPrecisión de torretas^n\r* \y+500 \wBalas extras al cargador de torretas",
		"\r* \y+35% \wDaño de torretas^n\r* \y+25% \wPrecisión de torretas^n\r* \y+1.000 \wBalas extras al cargador de torretas^n\r* \wPuede subir a \ynivel 4\w cualquier torreta",
		"\r* \y+42% \wDaño de torretas^n\r* \y+30% \wPrecisión de torretas^n\r* \y+1.500 \wBalas extras al cargador de torretas^n\r* \wPuede subir a \ynivel 5\w cualquier torreta^n\r* \wComienzas con \yUNA TORRETA\w",
		500000, 1500000, 3000000, 5000000, 7500000, 12500000, 2100999999
	},
	{
		"Soporte", // DAÑO
		"SOPORTE",
		"\wEfectivo con \yXM1014 M4\w^nSu daño \ycon la escopeta\w no se ve reducido^nfrente a los monstruos con protección",
		"\r* \y+5% \wVelocidad de disparo^n\r* \y+3 \wBalas extras",
		"\r* \y+10% \wVelocidad de disparo^n\r* \y+6 \wBalas extras",
		"\r* \y+15% \wVelocidad de disparo^n\r* \y+9 \wBalas extras",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+12 \wBalas extras^n\r* \wComienzas con \y200 DE ORO\w extra",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+15 \wBalas extras^n\r* \wComienzas con \y200 DE ORO\w extra^n\r* \wPuede recargar su arma instatáneamente \yUNA VEZ\w por oleada",
		"\r* \y+30% \wVelocidad de disparo^n\r* \y+18 \wBalas extras^n\r* \wComienzas con \y200 DE ORO\w extra^n\r* \wPuede recargar su arma instatáneamente \yUNA VEZ\w por oleada^n\r* \wRecibes menos daño de \yLOS HUEVECILLOS\w",
		500000, 1500000, 3500000, 7500000, 15000000, 25000000, 2100999999
	},
	{
		"Francotirador", // DAÑO
		"FRANCOTIRADOR",
		"\wEfectivo con \yAWP Magnum Sniper\w",
		"\r* \y+15% \wPrecisión al disparar",
		"\r* \y+30% \wPrecisión al disparar",
		"\r* \y+45% \wPrecisión al disparar",
		"\r* \y+60% \wPrecisión al disparar^n\r* \y+20% \wVelocidad de disparo^n\r* \wComienzas con \yGranada SG\w",
		"\r* \y+75% \wPrecisión al disparar^n\r* \y+30% \wVelocidad de disparo^n\r* \wComienzas con \yGranada SG\w",
		"\r* \yPrecisión perfecta^n\r* \y+40% \wVelocidad de disparo^n\r* \wComienzas con \yGranada SG\w^n\r* \y+15 \wBalas extras^n\r* \wTus disparos al \yGORDO BOMBA\w son \yCRÍTICOS\w",
		500000, 1000000, 3000000, 6000000, 10000000, 17500000, 2100999999
	},
	{
		"Apoyo", // DAÑO
		"APOYO",
		"\wEfectivo con \yM3 Super 90\w y \yMP5 Navy\w",
		"\r* \y+5% \wVelocidad de disparo",
		"\r* \y+10% \wVelocidad de disparo",
		"\r* \y+15% \wVelocidad de disparo^n\r* \y+12% \wDaño",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+24% \wDaño",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+36% \wDaño",
		"\r* \y+30% \wVelocidad de disparo^n\r* \y+50% \wDaño",
		500000, 1500000, 3000000, 6000000, 10000000, 17500000, 2100999999
	},
	{
		"Pesado", // DAÑO
		"PESADO",
		"\wEfectivo con \yM249 Para Machinegun\w",
		"\r* \y+15% \wPrecisión al disparar",
		"\r* \y+30% \wPrecisión al disparar",
		"\r* \y+45% \wPrecisión al disparar",
		"\r* \y+60% \wPrecisión al disparar^n\r* \y+5% \wVelocidad de disparo",
		"\r* \y+75% \wPrecisión al disparar^n\r* \y+10% \wVelocidad de disparo",
		"\r* \yPrecisión perfecta^n\r* \y+15% \wVelocidad de disparo^n\r* \wComienzas con \yRAYO\w",
		1000000, 3000000, 6000000, 10000000, 17500000, 25000000, 2100999999
	},
	{
		"Asalto", // KILLS
		"ASALTO",
		"\wEfectivo con \yFamas\w y \yIMI Galil\w",
		"\r* \y+15% \wPrecisión al disparar",
		"\r* \y+30% \wPrecisión al disparar",
		"\r* \y+45% \wPrecisión al disparar",
		"\r* \y+60% \wPrecisión al disparar^n\r* \y+12% \wDaño",
		"\r* \y+75% \wPrecisión al disparar^n\r* \y+24% \wDaño",
		"\r* \yPrecisión perfecta^n\r* \y+36% \wDaño^n\r* \wComienzas con \yIMI Galil\w",
		1150, 5300, 10450, 30600, 60750, 121000, 2100999999
	},
	{
		"Comandante", // KILLS
		"COMANDANTE",
		"\wEfectivo con \ySteyr AUG A1\w y \ySG-552 Commando\w",
		"\r* \y+5% \wVelocidad de disparo",
		"\r* \y+10% \wVelocidad de disparo",
		"\r* \y+15% \wVelocidad de disparo",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+12% \wDaño",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+24% \wDaño",
		"\r* \y+30% \wVelocidad de disparo^n\r* \y+36% \wDaño^n\r* \wComienzas con \ySteyr AUG A1\w",
		1150, 5300, 10450, 30600, 60750, 121000, 2100999999
	},
	{
		"Pistolero", // DISPAROS ACERTADOS
		"PISTOLERO",
		"\wEfectivo con \yDesert Eagle .50 AE\w",
		"\r* \y+10% \wVelocidad de disparo",
		"\r* \y+15% \wVelocidad de disparo",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+10% \wDaño",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+20% \wDaño",
		"\r* \y+30% \wVelocidad de disparo^n\r* \y+30% \wDaño",
		"\r* \y+40% \wVelocidad de disparo^n\r* \y+50% \wDaño^n\r* \wTienes balas infinitas y disparo automático",
		20000, 40000, 60000, 80000, 125000, 250000, 2100999999
	},
	{
		"Pubero", // DAÑO
		"PUBERO",
		"\wEfectivo con \ySG-550 Auto-Sniper\w y \yG3SG1 Auto-Sniper\w",
		"\r* \y+15% \wPrecisión al disparar",
		"\r* \y+30% \wPrecisión al disparar",
		"\r* \y+45% \wPrecisión al disparar",
		"\r* \y+60% \wPrecisión al disparar^n\r* \y+6 \wBalas extras",
		"\r* \y+75% \wPrecisión al disparar^n\r* \y+12 \wBalas extras",
		"\r* \yPrecisión perfecta^n\r* \y+18 \wBalas extras^n\r* \y+10% \wChance de daño crítico^n\r* \wComienzas con \yG3SG1 Auto-Sniper\w",
		1000000, 3000000, 6000000, 10000000, 17500000, 25000000, 2100999999
	},
	{
		"Legionario", // DAÑO
		"LEGIONARIO",
		"\wEfectivo con \yES P90\w",
		"\r* \y+5% \wVelocidad de disparo^n\r* \y+15% \wPrecisión al disparar",
		"\r* \y+10% \wVelocidad de disparo^n\r* \y+30% \wPrecisión al disparar",
		"\r* \y+15% \wVelocidad de disparo^n\r* \y+45% \wPrecisión al disparar",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+60% \wPrecisión al disparar^n\r* \y+3% \wChance de daño crítico",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+75% \wPrecisión al disparar^n\r* \y+6% \wChance de daño crítico",
		"\r* \y+30% \wVelocidad de disparo^n\r* \yPrecisión perfecta^n\r* \y+10% \wChance de daño crítico^n\r* \wCargador infinito",
		500000, 1500000, 3000000, 6000000, 10000000, 17500000, 2100999999
	},
	{
		"Bitero", // KILLS
		"BITERO",
		"\wEfectivo con \yIngram MAC-10\w y \ySchmidt TMP\w",
		"\r* \y+10% \wVelocidad de disparo^n\r* \y+15% \wPrecisión al disparar",
		"\r* \y+15% \wVelocidad de disparo^n\r* \y+30% \wPrecisión al disparar",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+45% \wPrecisión al disparar",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+60% \wPrecisión al disparar^n\r* \y+12% \wDaño",
		"\r* \y+30% \wVelocidad de disparo^n\r* \y+75% \wPrecisión al disparar^n\r* \y+24% \wDaño",
		"\r* \y+40% \wVelocidad de disparo^n\r* \yPrecisión perfecta^n\r* \y+36% \wDaño^n\r* \wBalas infinitas con las armas efectivas",
		215, 730, 1545, 4060, 10075, 22100, 2100999999
	},
	{
		"Scouter", // DAÑO
		"SCOUTER",
		"\wEfectivo con \ySchmidt Scout\w",
		"\r* \y+10% \wVelocidad de disparo^n\r* \y+15% \wPrecisión al disparar",
		"\r* \y+15% \wVelocidad de disparo^n\r* \y+30% \wPrecisión al disparar",
		"\r* \y+20% \wVelocidad de disparo^n\r* \y+45% \wPrecisión al disparar",
		"\r* \y+25% \wVelocidad de disparo^n\r* \y+60% \wPrecisión al disparar^n\r* \y+6 \wBalas extras",
		"\r* \y+30% \wVelocidad de disparo^n\r* \y+75% \wPrecisión al disparar^n\r* \y+12 \wBalas extras",
		"\r* \y+40% \wVelocidad de disparo^n\r* \yPrecisión perfecta^n\r* \y+18 \wBalas extras^n\r* \wDisparo veloz durante 10s",
		500000, 1500000, 3000000, 6000000, 10000000, 17500000, 2100999999
	}
};

new const WeaponIdType:__CLASSES_WEAPONS[structIdClasses][2] = {
	{WEAPON_M4A1, WEAPON_AK47},
	{WEAPON_C4, WEAPON_C4},
	{WEAPON_XM1014, WEAPON_C4},
	{WEAPON_AWP, WEAPON_C4},
	{WEAPON_M3, WEAPON_MP5N},
	{WEAPON_M249, WEAPON_C4},
	{WEAPON_FAMAS, WEAPON_GALIL},
	{WEAPON_AUG, WEAPON_SG552},
	{WEAPON_DEAGLE, WEAPON_C4},
	{WEAPON_SG550, WEAPON_G3SG1},
	{WEAPON_P90, WEAPON_C4},
	{WEAPON_MAC10, WEAPON_TMP},
	{WEAPON_SCOUT, WEAPON_C4}
};

new const __CLASSES_ATTRIB[structIdClasses][7][structClassesAttrib] = {
	// SOLDADO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{10.0, 			5.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{15.0, 			10.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{20.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{25.0, 			20.0, 		5,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{30.0, 			30.0, 		10,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{40.0, 			40.0, 		15,			0.0,		0.0,			0.0,				0,				0} 	// LV 6
	}, 
	// INGENIERO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{0.0, 			0.0, 		0,			0.0,		7.0,			5.0,				0,				0}, // LV 1
		{0.0, 			0.0, 		0,			0.0,		14.0,			10.0,				0,				0}, // LV 2
		{0.0, 			0.0, 		0,			0.0,		21.0,			15.0,				0,				0}, // LV 3
		{0.0, 			0.0, 		0,			0.0,		28.0,			20.0,				500,			0}, // LV 4
		{0.0, 			0.0, 		0,			0.0,		35.0,			25.0,				1000,			0}, // LV 5
		{0.0, 			0.0, 		0,			0.0,		42.0,			30.0,				1500,			0} 	// LV 6
	},
	// SOPORTE
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{5.0, 			0.0, 		3,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{10.0, 			0.0, 		6,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{15.0, 			0.0, 		9,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{20.0, 			0.0, 		12,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{25.0, 			0.0, 		15,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{30.0, 			0.0, 		18,			0.0,		0.0,			0.0,				0,				0} 	// LV 6
	},
	// FRANCOTIRADOR
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{0.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{0.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{0.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{20.0, 			60.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{30.0, 			75.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{40.0, 			100.0, 		15,			0.0,		0.0,			0.0,				0,				0} 	// LV 6
	},
	// APOYO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{5.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{10.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{15.0, 			0.0, 		0,			12.0,		0.0,			0.0,				0,				0}, // LV 3
		{20.0, 			0.0, 		0,			24.0,		0.0,			0.0,				0,				0}, // LV 4
		{25.0, 			0.0, 		0,			36.0,		0.0,			0.0,				0,				0}, // LV 5
		{30.0, 			0.0, 		0,			50.0,		0.0,			0.0,				0,				0} 	// LV 6
	},
	// PESADO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{0.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{0.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{0.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{5.0, 			60.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{10.0, 			75.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{15.0, 			100.0, 		0,			0.0,		0.0,			0.0,				0,				0} 	// LV 6
	},
	// ASALTO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{0.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{0.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{0.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{0.0, 			60.0, 		0,			12.0,		0.0,			0.0,				0,				0}, // LV 4
		{0.0, 			75.0, 		0,			24.0,		0.0,			0.0,				0,				0}, // LV 5
		{0.0, 			100.0, 		0,			36.0,		0.0,			0.0,				0,				0} 	// LV 6
	},
	// COMANDANTE
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{5.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{10.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{15.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{20.0, 			0.0, 		0,			12.0,		0.0,			0.0,				0,				0}, // LV 4
		{25.0, 			0.0, 		0,			24.0,		0.0,			0.0,				0,				0}, // LV 5
		{30.0, 			0.0, 		0,			36.0,		0.0,			0.0,				0,				0} 	// LV 6
	},
	// PISTOLERO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{10.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{15.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{20.0, 			0.0, 		0,			10.0,		0.0,			0.0,				0,				0}, // LV 3
		{25.0, 			0.0, 		0,			20.0,		0.0,			0.0,				0,				0}, // LV 4
		{30.0, 			0.0, 		0,			30.0,		0.0,			0.0,				0,				0}, // LV 5
		{40.0, 			0.0, 		0,			50.0,		0.0,			0.0,				0,				0} // LV 6
	},
	// PUBERO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{0.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{0.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{0.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{0.0, 			60.0, 		6,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{0.0, 			75.0, 		12,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{0.0, 			100.0, 		18,			0.0,		0.0,			0.0,				0,				10} // LV 6
	},
	// LEGIONARIO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{5.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{10.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{15.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{20.0, 			60.0, 		0,			0.0,		0.0,			0.0,				0,				3}, // LV 4
		{25.0, 			75.0, 		0,			0.0,		0.0,			0.0,				0,				6}, // LV 5
		{30.0, 			100.0, 		0,			0.0,		0.0,			0.0,				0,				10} // LV 6
	},
	// BITERO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{10.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{15.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{20.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{25.0, 			60.0, 		0,			12.0,		0.0,			0.0,				0,				0}, // LV 4
		{30.0, 			75.0, 		0,			24.0,		0.0,			0.0,				0,				0}, // LV 5
		{40.0, 			100.0, 		0,			36.0,		0.0,			0.0,				0,				0} 	// LV 6
	},
	// SCOUTER
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{10.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{15.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{20.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{25.0, 			60.0, 		6,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{30.0, 			75.0, 		12,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{40.0, 			100.0, 		18,			0.0,		0.0,			0.0,				0,				0} 	// LV 6
	}
};

new const __DIFFS[structIdDiffs][structDiffs] = {
	{
		"Normal",
		"NORMAL",
		"\r* \wVida monstruos\r: \y100%^n\
		\r* \wVelocidad monstruos\r: \y100%^n\
		\r* \wOro ganado\r: \y150%^n\
		\r* \wMonstruos por oleada\r: \y100%^n\
		\r* \wBalas de torretas\r: \yINFINITAS^n\
		\r* \wDaño que recibe la torre\r: \y100%^n\
		\r* \wRegeneración de la torre\r: \y+10 CADA 5s.^n\
		\r* \wHuevecillos\r: \yOLEADA 8+"
	},
	{
		"Nightmare",
		"NIGHTMARE",
		"\r* \wVida monstruos\r: \y150%^n\
		\r* \wVelocidad monstruos\r: \y120%^n\
		\r* \wOro ganado\r: \y125%^n\
		\r* \wMonstruos por oleada\r: \y125%^n\
		\r* \wBalas de torretas\r: \ySI^n\
		\r* \wDaño que recibe la torre\r: \y125%^n\
		\r* \wRegeneración de la torre\r: \y+7 CADA 5 SEG.^n\
		\r* \wHuevecillos\r: \yOLEADA 5+"
	},
	{
		"Suicidal",
		"SUICIDAL",
		"\r* \wVida monstruos\r: \y200%^n\
		\r* \wVelocidad monstruos\r: \y140%^n\
		\r* \wOro ganado\r: \y100%^n\
		\r* \wMonstruos por oleada\r: \y150%^n\
		\r* \wBalas de torretas\r: \ySI^n\
		\r* \wDaño que recibe la torre\r: \y150%^n\
		\r* \wRegeneración de la torre\r: \y+5 CADA 5 SEG.^n\
		\r* \wHuevecillos\r: \yOLEADA 4+^n\
		\r* \wOleada extra\r: \yVELOCES^n\
		\r* \wHuevecillos\r: \yMÁS DAÑO Y MÁS VELOCIDAD"
	},
	{
		"Hell",
		"HELL",
		"\r* \wVida monstruos\r: \y300%^n\
		\r* \wVelocidad monstruos\r: \y150%^n\
		\r* \wOro ganado\r: \y75%^n\
		\r* \wMonstruos por oleada\r: \y200%^n\
		\r* \wBalas de torretas\r: \ySI^n\
		\r* \wDaño que recibe la torre\r: \y200%^n\
		\r* \wRegeneración de la torre\r: \yNO^n\
		\r* \wHuevecillos\r: \yOLEADA 4+^n\
		\r* \wOleada extra\r: \yVELOCES^n\
		\r* \wHuevecillos\r: \yMÁS DAÑO Y MÁS VELOCIDAD^n\
		\r* \wOleada extra\r: \yDUROS^n\
		\r* \wHuevecillos\r: \yUNO EXTRA"
	}
};

new const __DIFFS_VALUES[structIdDiffs][structDiffsValues] = {
	// Health 	// Speed 	// Gold 	// MaxMonsters 	// DamageTower 	// TowerRegen 	// ExtraWaveSpeed 	// EggDamageSpeed 	// ExtraWaveHeavy 	// EggExtra 	// BossGorillaHealth 	// BossGorillaDamage
	{0, 		0.0, 		150, 		0, 				0, 				10, 			0, 					0, 					0, 					0, 				5000, 					30.0},
	{50, 		15.0, 		125, 		25, 			25, 			7, 				0, 					0, 					0, 					0, 				6000, 					40.0},
	{100, 		30.0, 		100, 		50, 			50, 			5, 				1, 					1, 					0, 					0, 				8000, 					60.0},
	{250, 		50.0, 		75, 		100, 			100, 			0, 				1, 					1, 					1, 					1, 				10000, 					80.0}
};

new const __DIFFS_VALUES_UC_WAVES_LEFT[structIdDiffs] = {
	5, 4, 3, 2
};

new const __DIFFS_VALUES_PP_WAVES_LEFT[structIdDiffs] = {
	5, 4, 3, 2
};

new const __HABS[structIdHabs][structHabs] = {
	{"Daño", "DAÑO", "Otorga daño extra a todas tus armas", 2.0, 50},
	{"Precisión al disparar", "PRECISIÓN AL DISPARAR", "Aumenta tu precisión de disparo con armas", 1.20, 25},
	{"Velocidad de disparo", "VELOCIDAD DE DISPARO", "Aumenta tu velocidad de disparo con armas", 1.20, 25},
	{"Balas", "BALAS", "Otorga balas extras a todas tus armas", 10.0, 10}
};

new const __ACHIEVEMENT_CLASSES[structIdAchievementClasses][structAchievementClasses] = {
	{"Generales", "GENERALES"},
	{"Oleadas", "DE OLEADAS"},
	{"Mapas", "DE MAPAS"},
	{"Beta", "DE LA BETA"},
	{"Jefes", "DE JEFES"},
	{"Poderes", "DE PODERES"}
};

new const __ACHIEVEMENTS[structIdAchievements][structAchievements] = {
	{"BETA TESTER", "Jugar en la BETA del TD v4.0", 1, 0, 0, ACHIEVEMENT_CLASS_BETA},
	{"BETA TESTER AVANZADO", "Subir hasta nivel 4 en la BETA del TD v4.0", 1, 0, 0, ACHIEVEMENT_CLASS_BETA}, 
	{"NIVEL 10", "Alcanza el nivel 10", 1, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 20", "Alcanza el nivel 20", 2, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 30", "Alcanza el nivel 30", 3, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 40", "Alcanza el nivel 40", 4, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 50", "Alcanza el nivel 50", 5, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 60", "Alcanza el nivel 60", 6, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 70", "Alcanza el nivel 70", 7, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 80", "Alcanza el nivel 80", 8, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 90", "Alcanza el nivel 90", 9, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NIVEL 100", "Alcanza el nivel 100", 10, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"100 OLEADAS N", "Supera 100 oleadas en dificultad \yNORMAL", 1, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500 OLEADAS N", "Supera 500 oleadas en dificultad \yNORMAL", 1, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000 OLEADAS N", "Supera 1.000 oleadas en dificultad \yNORMAL", 2, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"2.500 OLEADAS N", "Supera 2.500 oleadas en dificultad \yNORMAL", 2, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"5.000 OLEADAS N", "Supera 5.000 oleadas en dificultad \yNORMAL", 3, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"10.000 OLEADAS N", "Supera 10.000 oleadas en dificultad \yNORMAL", 3, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"25.000 OLEADAS N", "Supera 25.000 oleadas en dificultad \yNORMAL", 4, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"50.000 OLEADAS N", "Supera 50.000 oleadas en dificultad \yNORMAL", 4, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"100.000 OLEADAS N", "Supera 100.000 oleadas en dificultad \yNORMAL", 5, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"250.000 OLEADAS N", "Supera 250.000 oleadas en dificultad \yNORMAL", 5, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500.000 OLEADAS N", "Supera 500.000 oleadas en dificultad \yNORMAL", 6, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000.000 DE OLEADAS N", "Supera 1.000.000 de oleadas en dificultad \yNORMAL", 10, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"NOOB EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kmid", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kmid", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kmid", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kmid", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"NOOB EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_orange", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_orange", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_orange", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_orange", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"NOOB EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kwool_small", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kwool_small", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kwool_small", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kwool_small", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"NOOB EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kwhite", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kwhite", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kwhite", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kwhite", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"NOOB EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_plaza2", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_plaza2", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_plaza2", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_plaza2", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"TUTORIAL", "Lee el tutorial básico del juego", 1, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"100 OLEADAS NN", "Supera 100 oleadas en dificultad \yNIGHTMARE", 3, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500 OLEADAS NN", "Supera 500 oleadas en dificultad \yNIGHTMARE", 3, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000 OLEADAS NN", "Supera 1.000 oleadas en dificultad \yNIGHTMARE", 4, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"2.500 OLEADAS NN", "Supera 2.500 oleadas en dificultad \yNIGHTMARE", 4, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"5.000 OLEADAS NN", "Supera 5.000 oleadas en dificultad \yNIGHTMARE", 5, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"10.000 OLEADAS NN", "Supera 10.000 oleadas en dificultad \yNIGHTMARE", 5, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"25.000 OLEADAS NN", "Supera 25.000 oleadas en dificultad \yNIGHTMARE", 6, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"50.000 OLEADAS NN", "Supera 50.000 oleadas en dificultad \yNIGHTMARE", 6, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"100.000 OLEADAS NN", "Supera 100.000 oleadas en dificultad \yNIGHTMARE", 7, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"250.000 OLEADAS NN", "Supera 250.000 oleadas en dificultad \yNIGHTMARE", 7, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500.000 OLEADAS NN", "Supera 500.000 oleadas en dificultad \yNIGHTMARE", 8, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000.000 DE OLEADAS NN", "Supera 1.000.000 de oleadas en dificultad \yNIGHTMARE", 15, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"100 OLEADAS S", "Supera 100 oleadas en dificultad \ySUICIDAL", 5, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500 OLEADAS S", "Supera 500 oleadas en dificultad \ySUICIDAL", 5, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000 OLEADAS S", "Supera 1.000 oleadas en dificultad \ySUICIDAL", 6, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"2.500 OLEADAS S", "Supera 2.500 oleadas en dificultad \ySUICIDAL", 6, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"5.000 OLEADAS S", "Supera 5.000 oleadas en dificultad \ySUICIDAL", 7, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"10.000 OLEADAS S", "Supera 10.000 oleadas en dificultad \ySUICIDAL", 7, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"25.000 OLEADAS S", "Supera 25.000 oleadas en dificultad \ySUICIDAL", 8, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"50.000 OLEADAS S", "Supera 50.000 oleadas en dificultad \ySUICIDAL", 8, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"100.000 OLEADAS S", "Supera 100.000 oleadas en dificultad \ySUICIDAL", 9, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"250.000 OLEADAS S", "Supera 250.000 oleadas en dificultad \ySUICIDAL", 9, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500.000 OLEADAS S", "Supera 500.000 oleadas en dificultad \ySUICIDAL", 15, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000.000 DE OLEADAS S", "Supera 1.000.000 de oleadas en dificultad \ySUICIDAL", 30, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"100 OLEADAS H", "Supera 100 oleadas en dificultad \yHELL", 10, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500 OLEADAS H", "Supera 500 oleadas en dificultad \yHELL", 15, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000 OLEADAS H", "Supera 1.000 oleadas en dificultad \yHELL", 20, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"2.500 OLEADAS H", "Supera 2.500 oleadas en dificultad \yHELL", 25, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"5.000 OLEADAS H", "Supera 5.000 oleadas en dificultad \yHELL", 30, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"10.000 OLEADAS H", "Supera 10.000 oleadas en dificultad \yHELL", 35, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"25.000 OLEADAS H", "Supera 25.000 oleadas en dificultad \yHELL", 40, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"50.000 OLEADAS H", "Supera 50.000 oleadas en dificultad \yHELL", 45, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"100.000 OLEADAS H", "Supera 100.000 oleadas en dificultad \yHELL", 50, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"250.000 OLEADAS H", "Supera 250.000 oleadas en dificultad \yHELL", 100, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"500.000 OLEADAS H", "Supera 500.000 oleadas en dificultad \yHELL", 200, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"1.000.000 DE OLEADAS H", "Supera 1.000.000 de oleadas en dificultad \yHELL", 500, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"POBRE", "Acumula 10K de Oro", 1, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"SUELDO EN MANO", "Acumula 50K de Oro", 3, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"DINERITO", "Acumula 100K de Oro", 5, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"BILLETÍN BILLETÍN", "Acumula 500K de Oro", 7, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"MONETARIO", "Acumula 1M de Oro", 9, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"RICO", "Acumula 2.5M de Oro", 11, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"EMPRENDEDOR", "Acumula 5M de Oro", 13, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"PRÓSPERO", "Acumula 10M de Oro", 15, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"ACOMODADO", "Acumula 25M de Oro", 17, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"ADINERADO", "Acumula 50M de Oro", 19, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"ACAUDALADO", "Acumula 100M de Oro", 21, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"HACENDADO", "Acumula 500M de Oro", 23, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"MILLONARIO", "Acumula 1.000M de Oro", 25, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"PRIMERO", "Consigue 1 MVP", 1, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"DIEZ VECES EN PRIMER LUGAR", "Consigue 10 MVP", 2, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"1/4", "Consigue 25 MVP", 3, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"MEJORANDO", "Consigue 50 MVP", 4, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"EL MEJORCITO", "Consigue 100 MVP", 5, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"UNO DE LOS MEJORES", "Consigue 250 MVP", 6, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"EL MEJOR", "Consigue 500 MVP", 7, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"SIN DUDAS, EL MEJOR", "Consigue 1.000 MVP", 8, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"EL MEJOR, LEJOS", "Consigue 2.500 MVP", 10, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"POR ALLÁ ARRIBA", "Consigue 5.000 MVP", 12, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"EN EL CIELO", "Consigue 10.000 MVP", 14, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"SUPERIOR", "Consigue 25.000 MVP", 16, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"SUPERIOR A TODOS", "Consigue 50.000 MVP", 18, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"FAR FAR AWAY", "Consigue 100.000 MVP", 20, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"MVP", "Consigue 250.000 MVP", 22, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"MOST VALUABLE PLAYER", "Consigue 500.000 MVP", 25, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"EL REY", "Consigue 1.000.000 MVP", 30, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"VINCULADO", "Vincula tu cuenta del TD con la del foro", 5, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NOOB EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_gempire", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_gempire", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_gempire", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_gempire", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"2 EN LÍNEA", "Consigue 2 MVP seguidos", 4, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"3 EN LÍNEA", "Consigue 3 MVP seguidos", 7, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"4 EN LÍNEA", "Consigue 4 MVP seguidos", 10, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"5 EN LÍNEA", "Consigue 5 MVP seguidos", 13, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"6 EN LÍNEA", "Consigue 6 MVP seguidos", 16, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"7 EN LÍNEA", "Consigue 7 MVP seguidos", 19, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"8 EN LÍNEA", "Consigue 8 MVP seguidos", 24, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"9 EN LÍNEA", "Consigue 9 MVP seguidos", 30, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"10 EN LÍNEA", "Consigue 10 MVP seguidos", 50, 3, 3, ACHIEVEMENT_CLASS_GENERALS},
	{"COMPRADOR COMPULSIVO", "Desbloquea las clases APOYO, PESADO, ASALTO y COMANDANTE", 10, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NOOB EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_khell", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_khell", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_khell", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_khell", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"GORILA NOOB", "Sobrevive al jefe final \yGORILA\w en dificultad \yNORMAL\w", 1, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"GORILA AVANZADO", "Sobrevive al jefe final \yGORILA\w en dificultad \yNIGHTMARE\w", 2, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"GORILA EXPERTO", "Sobrevive al jefe final \yGORILA\w en dificultad \ySUICIDAL\w", 3, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"GORILA PRO", "Sobrevive al jefe final \yGORILA\w en dificultad \yHELL\w", 4, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FIRE MONSTER NOOB", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \yNORMAL\w", 1, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FIRE MONSTER AVANZADO", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \yNIGHTMARE\w", 2, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FIRE MONSTER EXPERTO", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \ySUICIDAL\w", 3, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FIRE MONSTER PRO", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \yHELL\w", 4, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"NOOB EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_dark_night", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_dark_night", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_dark_night", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_dark_night", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"DEFENSA ABSOLUTA NOOB", "Gana la oleada 10 en dificultad \yNORMAL\w^nsin que la torre reciba daño en ninguna oleada", 1, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"DEFENSA ABSOLUTA AVANZADO", "Gana la oleada 10 en dificultad \yNIGHTMARE\w^nsin que la torre reciba daño en ninguna oleada", 5, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"DEFENSA ABSOLUTA EXPERTO", "Gana la oleada 10 en dificultad \ySUICIDAL\w^nsin que la torre reciba daño en ninguna oleada", 10, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"DEFENSA ABSOLUTA PRO", "Gana la oleada 10 en dificultad \yHELL\w^nsin que la torre reciba daño en ninguna oleada", 20, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"GUARDIÁN NOOB", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \yNORMAL\w", 5, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"GUARDIÁN AVANZADO", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \yNIGHTMARE\w", 10, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"GUARDIÁN EXPERTO", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \ySUICIDAL\w", 15, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"GUARDIÁN PRO", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \yHELL\w", 20, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"TRAMPOSO", "Gana uno o más logros con trampa", 5, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NOOB EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kwool_x2", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kwool_x2", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kwool_x2", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kwool_x2", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PODER: BALAS INFINITAS", "Consigue todos los logros de los Jefes en dificultad \yHELL", 1337, 0, 0, ACHIEVEMENT_CLASS_POWERS},
	{"PODER: AIMBOT", "Mata al jefe \yGuardianes de Kyra\w en dificultad \yNIGHTMARE", 1338, 0, 0, ACHIEVEMENT_CLASS_POWERS},
	{"NOOB EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_minecraft", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_minecraft", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_minecraft", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_minecraft", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"NOOB EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_old_dust", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_old_dust", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_old_dust", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_old_dust", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"NOOB EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_city2", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_city2", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_city2", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_city2", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"666", "666 monstruos", 2, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"NOOB EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_castle_x2", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_castle_x2", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_castle_x2", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_castle_x2", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"NOOB EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_ksub", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_ksub", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_ksub", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_ksub", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"KSUB - DIE", "Muere de una manera horrible en el mapa \ytd_ksub\w o \ytd_ksub_wool", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"BAILE CON EL FIRE MONSTER", "Baila con el jefe final \yFIRE MONSTER", 5, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FIRE MONSTER - POR UN PELO", "Durante el encuentro con el jefe final \yFIRE MONSTER\w,^nesquiva el poder de la \y'carga'\w por un pelo", 5, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"NOOB EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_ksub_wool", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_ksub_wool", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_ksub_wool", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_ksub_wool", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"FALLEN TITAN NOOB", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \yNORMAL\w", 1, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FALLEN TITAN AVANZADO", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \yNIGHTMARE\w", 2, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FALLEN TITAN EXPERTO", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \ySUICIDAL\w", 3, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"FALLEN TITAN PRO", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \yHELL\w", 4, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"GOLPEADO POR UN TITÁN", "Consigue ser golpeado por el jefe final \yFALLEN TITAN\w^nmientras hace el poder de la \y'carga'\w contra alguien", 3, 0, 0, ACHIEVEMENT_CLASS_BOSSES},
	{"PISTOLERO", "Acierta 186 disparos con la \yDesert Eagle .50 AE\w sin desconectarte", 1339, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"LA BONEASTE", "Se el primero en morir en el mini Jefe", 1, 4, 4, ACHIEVEMENT_CLASS_GENERALS},
	{"NOOB EN DEATH", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_death", 1, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVANZADO EN DEATH", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_death", 2, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"EXPERTO EN DEATH", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_death", 3, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"PRO EN DEATH", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_death", 4, 0, 0, ACHIEVEMENT_CLASS_MAPS},
	{"AVARICIOSO TOTAL", "Junta más de 30.000 de oro en un mapa", 2, 6, 6, ACHIEVEMENT_CLASS_GENERALS},
	{"PROTECTOR NOOB", "Sube 2 clases al nivel 6", 10, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"PROTECTOR AVANZADO", "Sube 5 clases al nivel 6", 20, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"PROTECTOR EXPERTO", "Sube 9 clases al nivel 6", 30, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"PROTECTOR PRO", "Sube TODAS las clases al nivel 6", 50, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"ENTRENANDO", "Juega 1 día", 1, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"ESTOY MUY SOLO", "Juega 7 días", 7, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"FOREVER ALONE", "Juega 15 días", 15, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"CREO QUE TENGO UN PROBLEMA", "Juega 30 días", 30, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"SOLO EL TD ME ENTIENDE", "Juega 50 días", 50, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"FALTA DE DEFENSORES", "Sobrevive una oleada en la que los monstruos hayan dañado el 50% de la torre", 2, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"PROTECCIÓN NULA", "Sobrevive una oleada en la que los monstruos hayan dañado el 90% de la torre", 4, 0, 0, ACHIEVEMENT_CLASS_WAVES},
	{"SOY DORADO", "Se un jugador VIP", 4, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"HAGO LO QUE PUEDO", "Mata 500 monstruos en 1 mapa", 2, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"YOU SHALL NOT PASS", "Mata 1.000 monstruos en 1 mapa", 3, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"CARNICERO", "Mata 2.000 monstruos en 1 mapa", 4, 0, 0, ACHIEVEMENT_CLASS_GENERALS},
	{"EL LIDER", "Mata 3.000 monstruos en 1 mapa", 5, 0, 0, ACHIEVEMENT_CLASS_GENERALS}
};

new const __UPGRADES[structIdUpgrades][structUpgrades] = {
	{"Crítico", "Tus balas tienen % de hacer daño crítico", 10, 2, 3},
	{"Resistencia", "Menos daño recibido por zombies", 5, 1, 3},
	{"Thor", "Tu rayo afecta a 3-4 zombies más", 1, 1, 15},
	{"Clase: Apoyo", "Te permite utilizar la clase APOYO", 1, 1, 25},
	{"Clase: Pesado", "Te permite utilizar la clase PESADO", 1, 1, 25},
	{"Clase: Asalto", "Te permite utilizar la clase ASALTO", 1, 1, 25},
	{"Clase: Comandante", "Te permite utilizar la clase COMANDANTE", 1, 1, 25},
	{"Vida", "Tu vida aumentará para aguantar más daño", 10, 10, 8},
	{"Velocidad", "Te permite correr más rápido", 10, 10, 6}
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

new const __WEAPON_NAMES[][structWeapons] = {
	{"weapon_m4a1", "M4A1 Carbine", WEAPON_M4A1, 500, CLASS_SOLDADO, 0, -1, -1, -1},
	{"weapon_ak47", "AK-47 Kalashnikov", WEAPON_AK47, 500, CLASS_SOLDADO, 0, -1, -1, -1},
	{"weapon_awp", "AWP Magnum Sniper", WEAPON_AWP, 350, CLASS_FRANCOTIRADOR, 0, -1, -1, -1},
	{"weapon_xm1014", "XM1014 M4", WEAPON_XM1014, 200, CLASS_SOPORTE, 0, -1, -1, -1},
	{"weapon_m3", "M3 Super 90", WEAPON_M3, 200, CLASS_APOYO, 0, -1, -1, -1},
	{"weapon_mp5navy", "MP5 Navy", WEAPON_MP5N, 300, CLASS_APOYO, 0, -1, -1, -1},
	{"weapon_m249", "M249 Para Machinegun", WEAPON_M249, 400, CLASS_PESADO, 0, -1, -1, -1},
	{"weapon_famas", "Famas", WEAPON_FAMAS, 500, CLASS_ASALTO, 0, -1, -1, -1},
	{"weapon_galil", "IMI Galil", WEAPON_GALIL, 500, CLASS_ASALTO, 0, -1, -1, -1},
	{"weapon_aug", "Steyr AUG A1", WEAPON_AUG, 500, CLASS_COMANDANTE, 0, -1, -1, -1},
	{"weapon_sg552", "SG-552 Commando", WEAPON_SG552, 500, CLASS_COMANDANTE, 0, -1, -1, -1},
	{"weapon_g3sg1", "G3SG1 Auto-Sniper", WEAPON_G3SG1, 600, CLASS_PUBERO, 1, -1, -1, -1},
	{"weapon_sg550", "SG-550 Auto-Sniper", WEAPON_SG550, 600, CLASS_PUBERO, 1, -1, -1, -1},
	{"weapon_p90", "ES P90", WEAPON_P90, 400, CLASS_LEGIONARIO, 1, -1, -1, -1},
	{"weapon_mac10", "Ingram MAC-10", WEAPON_MAC10, 200, CLASS_BITERO, 1, -1, -1, -1},
	{"weapon_tmp", "Schmidt TMP", WEAPON_TMP, 200, CLASS_BITERO, 1, -1, -1, -1},
	{"weapon_scout", "Schmidt Scout", WEAPON_SCOUT, 350, CLASS_SCOUTER, 1, -1, -1, -1},
	{"weapon_deagle", "Balrog", WEAPON_DEAGLE, 1000, CLASS_PISTOLERO, 0, -1, -1, -1}
};

new const __GRENADES_NAMES[structIdNades][structWeapons] = {
	{"weapon_hegrenade", "HE: Explosión", WEAPON_HEGRENADE, 250, 0, 0, -1, 12, -1},
	{"weapon_flashbang", "FB: Remueve protección", WEAPON_FLASHBANG, 20, 0, 0, -1, 16, -1},
	{"weapon_smokegrenade", "SG: Aumenta el daño recibido", WEAPON_SMOKEGRENADE, 500, 0, 0, -1, 8, -1},
	{"weapon_hegrenade", "HE: Bomba Ión", WEAPON_HEGRENADE, 1500, 0, 0, 25, 1, 2}
};

new const __POWERS[structIdPowers][structPowers] = {
	{"Ninguno", 0},
	{"Rayo", 750},
	{"Balas Infinitas", 3000},
	{"Precisión perfecta", 2500}
};

new const __ZONE_MODE[structIdZones][] = {"Sin funcion", "NO DEJAR PASAR A NADIE 1", "MATA A QUIEN LO TOCA", "ZONA BLOQUEADA", "ZONA NO BLOQUEADA", "NO DEJAR PASAR A NADIE 2"};
new const __ZONE_NAME[structIdZones][] = {"wgz_none", "wgz_block_all", "wgz_kill", "wgz_kill_t1", "wgz_kill_t2", "wgz_block_all_2"};
new const __ZONE_SOLID_TYPE[structIdZones] = {SOLID_NOT, SOLID_BBOX, SOLID_TRIGGER, SOLID_TRIGGER, SOLID_TRIGGER, SOLID_BBOX};
new const __NAME_COORD[3][] = {"Coordenada X", "Coordenada Y", "Coordenada Z"};

new const __SENTRIES_DAMAGE[][structSentriesDamage] = {{5, 18}, {5, 18}, {11, 25}, {18, 33}, {22, 38}, {41, 51}, {55, 75}};
new const Float:__SENTRIES_HIT_RATIO[] = {0.5, 0.5, 0.6, 0.7, 0.7, 0.7, 0.8};
new const Float:__SENTRIES_THINK[] = {1.5, 1.5, 1.0, 0.8, 0.7, 0.6, 0.5};
new const __SENTRIES_UPGRADE_COST[] = {1000, 2000, 3000, 5000, 10000, 15000};
new const __SENTRIES_MAXCLIP[] = {1000000, 500, 100, 100, 100, 150, 250};

new const __ENT_CLASSNAME_WALKGUARD[] = "entWalkGuard";
new const __ENT_CLASSNAME_TOWER[] = "entTower";
new const __ENT_CLASSNAME_VIEW_TOWER[] = "entViewTower";
new const __ENT_CLASSNAME_EVA[] = "entEva";
new const __ENT_CLASSNAME_MONSTER[] = "entMonster";
new const __ENT_CLASSNAME_EGG_MONSTER[] = "entEggMonster";
new const __ENT_CLASSNAME_SPECIAL_MONSTER[] = "entSpecialMonster";
new const __ENT_CLASSNAME_MINIBOSS[] = "entMiniBoss";
new const __ENT_CLASSNAME_BOSS[] = "entBoss";
new const __ENT_CLASSNAME_BOSS_FM_BALL[] = "entFMBall";
new const __ENT_CLASSNAME_BOSS_FT_CANNON_BALL[] = "entFTCannonBall";
new const __ENT_CLASSNAME_BOSS_GK[] = "entBossGK";
new const __ENT_CLASSNAME_BOSS_GK_SPRITTER[] = "entBossGKSpritter";
new const __ENT_CLASSNAME_SENTRY_BASE[] = "entSentryBase";
new const __ENT_CLASSNAME_SENTRY[] = "entSentry";
new const __ENT_CLASSNAME_ROBOT[] = "entRobot";
new const __ENT_CLASSNAME_ROBOT_MISSILES[] = "entRobotMissiles";
new const __ENT_CLASSNAME_CHECK_AFK[] = "entCheckAfk";
new const __ENT_CLASSNAME_HUD[] = "entHud";
new const __ENT_CLASSNAME_HUD_GENERAL[] = "entHudGeneral";

new const __REMOVE_MAPS_ENTS[][] = {"func_bomb_target", "info_bomb_target", "func_vip_safetyzone", "func_escapezone", "hostage_entity", "monster_scientist", "info_hostage_rescue", "func_hostage_rescue", "env_rain", "env_snow", "env_fog", "func_vehicle", "info_map_parameters", "func_buyzone", "armoury_entity", "game_text"};

new const __MODEL_GIB_SKULL[] = "models/gib_skull.mdl";
new const __KNIFE_vTOOL[] = "models/dg/td4/v_tool.mdl";
new const __KNIFE_pTOOL[] = "models/dg/td4/p_tool.mdl";
new const __GRENADE_vION[] = "models/dg/td4/v_grenade_ion.mdl";
new const __GRENADE_pION[] = "models/dg/td4/p_grenade_ion.mdl";
new const __GRENADE_wION[] = "models/dg/td4/w_grenade_ion.mdl";
new const __MODELS_ZOMBIE_NORMAL[][] = {"models/dg/td4/zombies/m_normal1.mdl", "models/dg/td4/zombies/m_normal2.mdl", "models/dg/td4/zombies/m_normal3_fix1.mdl", "models/dg/td4/zombies/m_normal4.mdl", "models/dg/td4/zombies/m_normal5_fix1.mdl", "models/dg/td4/zombies/m_normal6_fix1.mdl", "models/dg/td4/zombies/m_normal7_fix1.mdl", "models/dg/td4/zombies/m_normal8_fix1.mdl", "models/dg/td4/zombies/m_normal9_fix1.mdl", "models/dg/td4/zombies/m_normal10.mdl"};
new const __MODELS_ZOMBIE_SPEED[][] = {"models/dg/td4/zombies/m_speed1_fix1.mdl", "models/dg/td4/zombies/m_speed2_fix1.mdl", "models/dg/td4/zombies/m_speed3.mdl"};
new const __MODELS_ZOMBIE_HARD[][] = {"models/dg/td4/zombies/m_hard1_fix1.mdl", "models/dg/td4/zombies/m_hard2_fix1.mdl", "models/dg/td4/zombies/m_hard3_fix1.mdl"};
new const __MODELS_ZOMBIE_SPECIAL[][] = {"models/dg/td4/zombies/m_special1_fix1.mdl", "models/dg/td4/zombies/m_special2_fix1.mdl"};
new const __MODEL_ZOMBIE_BOOMER[] = "models/dg/td4/zombies/m_boomer1.mdl";
new const __MODEL_MINIBOSS[] = "models/dg/td4/miniboss.mdl";
new const __MODELS_BOSS[][] = {"models/dg/td4/bosses/m_boss1.mdl", "models/dg/td4/bosses/m_boss2.mdl", "models/dg/td4/bosses/m_boss3.mdl", "models/dg/td4/bosses/m_boss4_fix1.mdl"};
new const __MODEL_TANK_ROCK_GIBS[] = "models/rockgibs.mdl";
new const __MODEL_FIREBALL[] = "models/dg/td4/others/fireball.mdl";
new const __MODEL_SPITTER_AURA[] = "models/dg/td4/others/spitter_aura.mdl";
new const __MODEL_FALLEN_TITAN_AURA[] = "models/dg/td4/others/fallen_titan_aura.mdl";
new const __MODEL_TENTACLE[] = "models/dg/td4/others/tentacle.mdl";
new const __MODEL_TOWER[] = "models/dg/td4/tower.mdl";
new const __MODEL_EVA[] = "models/dg/td4/eva/eva.mdl";
new const __MODEL_EVA_T[] = "models/dg/td4/eva/evaT.mdl";
new const __MODEL_EGG[] = "models/dg/td4/egg.mdl";
new const __MODEL_RANKS[] = "models/dg/td4/ranks.mdl";
new const __MODEL_HATS[] = "models/dg/td4/hats.mdl";
new const __MODEL_SENTRY_BASE[] = "models/dg/td4/sentry/base.mdl";
new const __MODEL_SENTRY_BASE_4TO6[] = "models/dg/td4/sentry/base4to6.mdl";
new const __MODELS_SENTRY[][] = {"models/dg/td4/sentry/sentry1.mdl", "models/dg/td4/sentry/sentry2.mdl", "models/dg/td4/sentry/sentry3.mdl", "models/dg/td4/sentry/sentry4.mdl", "models/dg/td4/sentry/sentry5.mdl", "models/dg/td4/sentry/sentry6.mdl"};
new const __MODELS_ROBOT[][] = {"models/dg/td4/robot/bait1.mdl", "models/dg/td4/robot/bait2.mdl"};

new const __SOUND_WIN_GAME[] = "sound/dg/td4/win_game.mp3";
new const __SOUND_ZOMBIE_PAIN[][] = {"dg/zp6/zombie_pain_00.wav", "dg/zp6/zombie_pain_01.wav", "dg/zp6/zombie_pain_02.wav"};
new const __SOUND_ZOMBIE_KNIFE[][] = {"dg/zp6/zombie_knife_00.wav", "dg/zp6/zombie_knife_01.wav", "dg/zp6/zombie_knife_02.wav"};
new const __SOUND_ZOMBIE_DIE[][] = {"dg/zp6/zombie_die_00.wav", "dg/zp6/zombie_die_01.wav", "dg/zp6/zombie_die_02.wav", "dg/zp6/zombie_die_03.wav", "dg/zp6/zombie_die_04.wav"};
new const __SOUND_ZOMBIE_LASER[][] = {"weapons/electro4.wav", "weapons/electro5.wav", "weapons/electro6.wav"};
new const __SOUND_BOOMER_EXPLODE[] = "dg/zp6/bomb_explode.wav";
new const __SOUND_BOSS_ROLL_LOOP[] = "dg/td4/boss_rolling_loop.wav";
new const __SOUND_BOSS_ROLL_FINISH[] = "dg/td4/boss_rolling_finish.wav";
new const __SOUND_BOSS_PHIT[][] = {"player/bhit_flesh-1.wav", "player/bhit_flesh-2.wav", "player/bhit_flesh-3.wav"};
new const __SOUND_BOSS_EXPLODE[] = "dg/td4/boss_fire_explode.wav";
new const __SOUND_BOSS_IMPACT[] = "dg/td4/boss_fire_impact.wav";
new const __SOUND_BOSS_FIREBALL_LAUNCH2[] = "dg/td4/boss_fire_launch2.wav";
new const __SOUND_BOSS_FIREBALL_LAUNCH4[] = "dg/td4/boss_fire_launch4.wav";
new const __SOUND_BOSS_FIREBALL_EXPLODE[] = "dg/td4/boss_fire_fireball_explode.wav";
new const __SOUND_SPITTER_SPIT[] = "zombie_plague/spitter_spit_01.wav";
new const __SOUND_FALLEN_TITAN_CANNON[] = "dg/td4/boss_fallen_titan_cannon.wav";
new const __SOUND_FALLEN_TITAN_SCREAM[] = "dg/td4/boss_fallen_titan_scream.wav";
new const __SOUND_THUNDER[] = "ambience/thunder_clap.wav";
new const __SOUND_SENTRY_BASE[] = "dg/td4/sentry_base.wav";
new const __SOUND_SENTRY_HEAD[] = "dg/td4/sentry_head.wav";
new const __SOUND_SENTRY_FIRE[] = "weapons/m249-1.wav";
new const __SOUND_SENTRY_FIRE_5TO6[][] = {"weapons/hks1.wav", "weapons/hks2.wav", "weapons/hks3.wav"};
new const __SOUND_SENTRY_FOUND[] = "dg/td4/sentry_found.wav";
new const __SOUND_ROBOT_MISSILE_FIRED[] = "weapons/rocketfire1.wav";

new const __SPRITE_FLAME[] = "sprites/dg/td4/flame.spr";
new const __SPRITE_ANIM_GLOW[] = "sprites/animglow01.spr";
new const __SPRITE_MONSTER_SPAWN[] = "sprites/dg/td4/spawn.spr";
new const __SPRITE_MONSTER_BLOODSPRAY[] = "sprites/bloodspray.spr";
new const __SPRITE_MONSTER_BLOOD[] = "sprites/blood.spr";
new const __SPRITE_BOSS_HEALTH[] = "sprites/dg/td4/healthbar_boss.spr";
new const __SPRITE_DOT[] = "sprites/dot.spr";
new const __SPRITE_TRAIL[] = "sprites/laserbeam.spr";
new const __SPRITE_THUNDER[] = "sprites/lgtning.spr";
new const __SPRITE_ARROW_EXPLODE[] = "sprites/zerogxplode.spr";

new const __SERVER_FILE[] = "server.log";
// new const __BUGS_FILE[] = "bugs.log";

new const Float:__DEFAULT_DELAY[] = {0.00, 2.70, 0.00, 2.00, 0.00, 0.55, 0.00, 3.15, 3.30, 0.00, 4.50, 2.70, 3.50, 3.35, 2.45, 3.30, 2.70, 2.20, 2.50, 2.63, 4.70, 0.55, 3.05, 2.12, 3.50, 0.00, 2.20, 3.00, 2.45, 0.00, 3.40};
new const __DEFAULT_MAXCLIP[] = {-1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50};
new const __DEFAULT_ANIMS[] = {-1, 5, -1, 3, -1, 6, -1, 1, 1, -1, 14, 4, 2, 3, 1, 1, 13, 7, 4, 1, 3, 6, 11, 1, 3, -1, 4, 1, 1, -1, 1};

new const __MAX_BPAMMO[] = {-1, 200, -1, 200, 1, 200, 1, 200, 200, 1, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 2, 200, 200, 200, -1, 200};
new const __AMMO_TYPE[][] = {"", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm"};
new const __AMMO_WEAPON[] = {0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4};

new const __SEQUENCES_ATTACK_BOSS1[] = {35, 36, 37, 38, 39, 40};
new const Float:__SEQUENCES_FRAMES_BOSS1[] = {0.566667, 0.433333, 1.5, 0.566667, 0.566667, 1.466667}; // Abrir modelo con HLMV y hacer la cuenta 'Frames / FPS'

new g_PlayerSteamId[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new g_Atsul[MAX_PLAYERS + 1];
new g_Tutorial[MAX_PLAYERS + 1];
new g_Health[MAX_PLAYERS + 1];
new WeaponIdType:g_CurrentWeapon[MAX_PLAYERS + 1];
new g_Nades[MAX_PLAYERS + 1][structIdNades];
new g_Grenades_UsedByPlayer[MAX_PLAYERS + 1][structIdNades];
new g_AfkDamage[MAX_PLAYERS + 1];
new Float:g_AfkTime[MAX_PLAYERS + 1];
new g_InBlockZone[MAX_PLAYERS + 1];
new g_Kills[MAX_PLAYERS + 1];
new g_KillsMap[MAX_PLAYERS + 1];
new g_KillsPerWave[MAX_PLAYERS + 1][(MAX_WAVES + 2)];
new g_WavesWins[MAX_PLAYERS + 1][(structIdDiffs + 1)][(MAX_WAVES + 1)];
new g_BossKills[MAX_PLAYERS + 1][(structIdDiffs + 1)];
new g_GordoBomba_Kills[MAX_PLAYERS + 1];
new g_Dance[MAX_PLAYERS + 1];
new g_Level[MAX_PLAYERS + 1];
new g_Gold[MAX_PLAYERS + 1];
new g_GoldG[MAX_PLAYERS + 1];
new g_GoldGaben[MAX_PLAYERS + 1];
new g_GoldMap[MAX_PLAYERS + 1];
new Float:g_NoReload[MAX_PLAYERS + 1];
new g_DamageDone[MAX_PLAYERS + 1];
new g_WinMVP[MAX_PLAYERS + 1];
new g_WinMVPNext[MAX_PLAYERS + 1];
new g_WinMVPGaben[MAX_PLAYERS + 1];
new g_Power[MAX_PLAYERS + 1][structIdPowers];
new g_PowerActual[MAX_PLAYERS + 1];
new g_UnlimitedClip[MAX_PLAYERS + 1];
new g_UnlimitedClip_WavesLeft[MAX_PLAYERS + 1];
new g_PrecisionPerfecta[MAX_PLAYERS + 1];
new g_PrecisionPerfecta_WavesLeft[MAX_PLAYERS + 1];
new Float:g_SentryOrigin[MAX_PLAYERS + 1][3];
new g_Sentry[MAX_PLAYERS + 1];
new g_SentryDamage[MAX_PLAYERS + 1];
new g_SentryTransferMenu[MAX_PLAYERS + 1];
new g_InBuilding[MAX_PLAYERS + 1];
new g_Robot[MAX_PLAYERS + 1];
new g_ClassId[MAX_PLAYERS + 1];
new g_ClassLevel[MAX_PLAYERS + 1][structIdClasses];
new g_ClassReqs[MAX_PLAYERS + 1][structIdClasses];
new g_ClassSoporte_Hab[MAX_PLAYERS + 1];
new g_ClassSoporte_Bonus[MAX_PLAYERS + 1];
new g_ClassPistolero_AutoFire[MAX_PLAYERS + 1];
new g_ClassScouter_Hab[MAX_PLAYERS + 1];
new g_VoteDiff[MAX_PLAYERS + 1];
new g_AutoDiff[MAX_PLAYERS + 1][structIdMaps];
new g_Points[MAX_PLAYERS + 1];
new g_Hab[MAX_PLAYERS + 1][structIdHabs];
new Float:g_HabCache[MAX_PLAYERS + 1][structIdFHabs];
new g_HabCacheClip[MAX_PLAYERS + 1];
new g_Achievement[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementName[MAX_PLAYERS + 1][structIdAchievements][MAX_NAME_LENGTH];
new g_AchievementUnlocked[MAX_PLAYERS + 1][structIdAchievements];
new g_AchievementInt[MAX_PLAYERS + 1][structIdAchievements];
new Float:g_AchievementTimeLink[MAX_PLAYERS + 1];
new g_AchievementTotal[MAX_PLAYERS + 1];
new g_AchievementMap[MAX_PLAYERS + 1];
new g_AchievementTrackPistolero[MAX_PLAYERS + 1];
new g_Os[MAX_PLAYERS + 1];
new g_OsLost[MAX_PLAYERS + 1];
new g_Upgrades[MAX_PLAYERS + 1][structIdUpgrades];
new g_CriticChance[MAX_PLAYERS + 1];
new g_TimePlayed[MAX_PLAYERS + 1][structIdTimePlayed];
new g_UserOption_HudColor[MAX_PLAYERS + 1][structIdRGB];
new Float:g_UserOption_HudPosition[MAX_PLAYERS + 1][3];
new g_UserOption_HudEffect[MAX_PLAYERS + 1];
new g_UserOption_HudProgressClass[MAX_PLAYERS + 1];
new g_UserOption_HudKillsPerWave[MAX_PLAYERS + 1];
new g_UserOption_LowFpsModels[MAX_PLAYERS + 1];
new g_UserOption_LowFpsGlow[MAX_PLAYERS + 1];
new g_UserOption_LowFpsSentries[MAX_PLAYERS + 1];
new g_UserOption_LowFpsZombieDead[MAX_PLAYERS + 1];
new g_MenuPage_Tutorial[MAX_PLAYERS + 1];
new g_MenuPage_Classes[MAX_PLAYERS + 1];
new g_MenuPage_FavDiffs[MAX_PLAYERS + 1];
new g_MenuPage_AchievementClasses[MAX_PLAYERS + 1];
new g_MenuPage_AchievementClassesIn[MAX_PLAYERS + 1][structIdAchievementClasses];
new g_MenuPage_Upgrade[MAX_PLAYERS + 1];
new g_MenuPage_Level[MAX_PLAYERS + 1];
new g_MenuPage_HudColor[MAX_PLAYERS + 1];
new g_MenuData_ClassId[MAX_PLAYERS + 1];
new g_MenuData_DiffId[MAX_PLAYERS + 1];
new g_MenuData_HabPoints[MAX_PLAYERS + 1];
new g_MenuData_HabId[MAX_PLAYERS + 1];
new g_MenuData_AchievementClassId[MAX_PLAYERS + 1];
new g_MenuData_AchievementClassIn[MAX_PLAYERS + 1];
new g_MenuData_AchievementId[MAX_PLAYERS + 1];
new g_MenuData_Level[MAX_PLAYERS + 1];
new g_MenuData_EntSentry[MAX_PLAYERS + 1];
new g_MenuData_EntRobot[MAX_PLAYERS + 1];

new g_AdminOn;
new g_Lights[2];
new g_CurrentMap[MAX_CHARACTER_MAPNAME];
new g_ModelIndex_ZombieLowFps;
new g_Sprite_BloodSpray;
new g_Sprite_Blood;
new g_Sprite_Dot;
new g_Sprite_Trail;
new g_Sprite_Thunder;
new g_Sprite_ArrowExplode;
new Array:g_aRemoveMapsEnts;
new g_FwdSpawn;
new g_FwdPrecacheSound;
new g_Message_AmmoPickup;
new g_Message_ScreenFade;
new g_Message_ScreenShake;
new g_Message_RoundTime;
new g_Message_TextMsg;
new g_Message_SendAudio;
new g_Message_ClCorpse;
new g_Message_CurWeapon;
// new g_pCvar_MonsterSpeedDefault;
new g_ServerId;
new Handle:g_SqlTuple;
new Handle:g_SqlConnection;
new g_SqlQuery[2048];
new g_EntCheckAfk;
new g_EntHud;
new g_HudSync_General;
new g_ZoneId;
new g_Zone[MAX_ZONES];
new Float:g_ZoneBox[2][3];
new g_MaxZones;
new g_EditorId;
new g_Direction;
new g_SetUnits = 10;
new g_MapId;
new g_BlockDiff;
new Float:g_VecStartOrigin[2][3];
new Float:g_VecEndOrigin[2][3];
new g_HudSync_Damage;
new g_HudSync_DamageTower;
new g_Grenades_Used[structIdNades];
new g_Tower[2];
new g_TowerHealth;
new g_TowerMaxHealth;
new g_TowerInRegen;
new Float:g_VecMonsterTowerOrigin[2][3];
new Float:g_EntViewTowerFallingOrigin[3];
new Float:g_VecSpecialOrigin[3];
new Float:g_VecSpecialOrigin2[3];
new g_ExtraWaveSpeed;
new g_ExtraWaveStrength;
new g_EntEvas[20];
new g_EntEvasNums;
new Float:g_EntEvasOrigin[20][3];
new g_Wave;
new g_WaveInProgress;
new g_NextWaveIncoming;
new g_SpecialWave;
new g_EndVote;
new g_Diff;
new g_StartGame;
new g_StartSeconds;
new g_EndGame;
new g_ZombieModels;
new g_TotalMonsters;
new g_MonstersAlive;
new g_MonstersKills;
new g_MonstersShield;
new g_MonstersWithShield;
new g_MonsterMaxHealth = 0;
new g_SendMonsterSpecial;
new g_BoomerHealth;
new g_EggCache;
new g_FixStart[2];
new g_TempMonsterType;
new g_TempMonsterNum;
new g_TempMonsterTrack;
new g_FinishGame;
new g_DamageNeedToGold;
new g_Tramposo = 0;
new g_SentryCountTotal;
new g_RobotCountTotal;
new g_RobotDamage = 0;
new g_RobotEnt = 0;
new g_RobotMissileAllowed;
new g_TimePerWave_Ids[MAX_PLAYERS + 1];
new g_TimePerWave_SysTime[(MAX_WAVES + 1)];
new g_BestPlayerKills;
new g_BestPlayerId;
new g_MVP_More;
new g_WinMVP_Last;
new g_Achievement_DefensaAbsoluta;
new g_Achievement_FaltaDeDefensores;
new g_Achievement_LaBoneaste;
new HamHook:g_HamHook_Killed;
new HamHook:g_HamHook_TakeDamage;
new g_MiniBoss_Ids[3];
new g_BossMenu_TimeLeft;
new g_BossMenu_MaxVotes = 0;
new g_BossMenu_Votes[structIdBosses];
new g_BossId;
new g_Boss;
new g_Boss_HealthBar;
new Float:g_BossRespawn[3];
new g_BossPower[3];
new g_BossLastPower[2];
new Float:g_BossTimePower[2];
new Float:g_BossRollSpeed[2];
new g_BossGorila_AttractPowerHP[2];
new g_BossFire_UltimateHealth = 9999999;
new g_BossFire_Ultimate;
new g_BossPower_Explode;
new g_BossFT_UltimateHealth = 9999999;
new g_BossFT_Enrage = 0;
new g_BossFT_UltimateCannons;
new g_BossFT_LastPower = 0;
new g_BossFT_HyperUltimate = 0;
new g_BossGuardians;
new g_BossGuardians_Ids[2];
new g_BossGuardians_HealthBar[2];
new g_Dances = 0;
new Array:g_aMapName;
new g_VoteMap;
new g_VoteMap_i = 0;
new g_VoteMap_Count;
new g_VoteMap_SelectMaps = MAX_VOTEMAP;
new g_VoteMap_Next[MAX_VOTEMAP];
new g_VoteMap_VoteCount[MAX_VOTEMAP + 2];
new g_Monsters_Spawn;
new g_Monsters_Kills;
new g_SpecialMonsters_Spawn;
new g_SpecialMonsters_Kills;
new g_FwdAddToFullPack;
new g_FwdAddToFullPack_Status;

#define NEXTTHINK_CHECK_AFK (get_gametime() + 5.0)
#define NEXTTHINK_HUD (get_gametime() + 0.000001)
#define NEXTTHINK_HUD_GENERAL (get_gametime() + 1.0)

public plugin_precache() {
	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);
	register_cvar("td_version", __PLUGIN_VERSION, (FCVAR_SERVER | FCVAR_SPONLY));

	rh_get_mapname(g_CurrentMap, charsmax(g_CurrentMap));
	strtolower(g_CurrentMap);

	register_forward(FM_Sys_Error, "@FM_Sys_Error_Pre", false);
	register_forward(FM_GameShutdown, "@FM_GameShutdown_Pre", false);

	g_ModelIndex_ZombieLowFps = precache_model("models/player/leet/leet.mdl");
	precache_model("models/rpgrocket.mdl");
	precache_model("models/w_usp.mdl");
	precache_model(__MODEL_GIB_SKULL);
	precache_model(__KNIFE_vTOOL);
	precache_model(__KNIFE_pTOOL);
	precache_model(__GRENADE_vION);
	precache_model(__GRENADE_pION);
	precache_model(__GRENADE_wION);

	for(new i = 0; i < sizeof(__MODELS_ZOMBIE_NORMAL); ++i) {
		precache_model(__MODELS_ZOMBIE_NORMAL[i]);
	}

	for(new i = 0; i < sizeof(__MODELS_ZOMBIE_SPEED); ++i) {
		precache_model(__MODELS_ZOMBIE_SPEED[i]);
	}

	for(new i = 0; i < sizeof(__MODELS_ZOMBIE_HARD); ++i) {
		precache_model(__MODELS_ZOMBIE_HARD[i]);
	}

	for(new i = 0; i < sizeof(__MODELS_ZOMBIE_SPECIAL); ++i) {
		precache_model(__MODELS_ZOMBIE_SPECIAL[i]);
	}

	precache_model(__MODEL_ZOMBIE_BOOMER);
	precache_model(__MODEL_MINIBOSS);

	for(new i = 0; i < sizeof(__MODELS_BOSS); ++i) {
		precache_model(__MODELS_BOSS[i]);
	}

	precache_model(__MODEL_TANK_ROCK_GIBS);
	precache_model(__MODEL_FIREBALL);
	precache_model(__MODEL_SPITTER_AURA);
	precache_model(__MODEL_FALLEN_TITAN_AURA);
	precache_model(__MODEL_TENTACLE);
	precache_model(__MODEL_TOWER);
	precache_model(__MODEL_EVA);
	precache_model(__MODEL_EVA_T);
	precache_model(__MODEL_EGG);
	precache_model(__MODEL_RANKS);
	precache_model(__MODEL_HATS);
	precache_model(__MODEL_SENTRY_BASE);
	precache_model(__MODEL_SENTRY_BASE_4TO6);

	for(new i = 0; i < sizeof(__MODELS_SENTRY); ++i) {
		precache_model(__MODELS_SENTRY[i]);
	}

	for(new i = 0; i < sizeof(__MODELS_ROBOT); ++i) {
		precache_model(__MODELS_ROBOT[i]);
	}

	precache_generic(__SOUND_WIN_GAME);

	for(new i = 0; i < sizeof(__SOUND_ZOMBIE_PAIN); ++i) {
		precache_sound(__SOUND_ZOMBIE_PAIN[i]);
	}

	for(new i = 0; i < sizeof(__SOUND_ZOMBIE_KNIFE); ++i) {
		precache_sound(__SOUND_ZOMBIE_KNIFE[i]);
	}

	for(new i = 0; i < sizeof(__SOUND_ZOMBIE_DIE); ++i) {
		precache_sound(__SOUND_ZOMBIE_DIE[i]);
	}

	for(new i = 0; i < sizeof(__SOUND_ZOMBIE_LASER); ++i) {
		precache_sound(__SOUND_ZOMBIE_LASER[i]);
	}

	precache_sound(__SOUND_BOOMER_EXPLODE);
	precache_sound(__SOUND_BOSS_ROLL_LOOP);
	precache_sound(__SOUND_BOSS_ROLL_FINISH);

	for(new i = 0; i < sizeof(__SOUND_BOSS_PHIT); ++i) {
		precache_sound(__SOUND_BOSS_PHIT[i]);
	}

	precache_sound(__SOUND_BOSS_EXPLODE);
	precache_sound(__SOUND_BOSS_IMPACT);
	precache_sound(__SOUND_BOSS_FIREBALL_LAUNCH2);
	precache_sound(__SOUND_BOSS_FIREBALL_LAUNCH4);
	precache_sound(__SOUND_BOSS_FIREBALL_EXPLODE);
	precache_sound(__SOUND_SPITTER_SPIT);
	precache_sound(__SOUND_FALLEN_TITAN_CANNON);
	precache_sound(__SOUND_FALLEN_TITAN_SCREAM);
	precache_sound(__SOUND_THUNDER);
	precache_sound(__SOUND_SENTRY_BASE);
	precache_sound(__SOUND_SENTRY_HEAD);
	precache_sound(__SOUND_SENTRY_FIRE);

	for(new i = 0; i < sizeof(__SOUND_SENTRY_FIRE_5TO6); ++i) {
		precache_sound(__SOUND_SENTRY_FIRE_5TO6[i]);
	}

	precache_sound(__SOUND_SENTRY_FOUND);
	precache_sound(__SOUND_ROBOT_MISSILE_FIRED);

	precache_model(__SPRITE_FLAME);
	precache_model(__SPRITE_ANIM_GLOW);
	precache_model(__SPRITE_MONSTER_SPAWN);
	g_Sprite_BloodSpray = precache_model(__SPRITE_MONSTER_BLOODSPRAY);
	g_Sprite_Blood = precache_model(__SPRITE_MONSTER_BLOOD);
	precache_model(__SPRITE_BOSS_HEALTH);
	g_Sprite_Dot = precache_model(__SPRITE_DOT);
	g_Sprite_Trail = precache_model(__SPRITE_TRAIL);
	g_Sprite_Thunder = precache_model(__SPRITE_THUNDER);
	g_Sprite_ArrowExplode = precache_model(__SPRITE_ARROW_EXPLODE);

	removeMapsEnts();
	g_FwdPrecacheSound = register_forward(FM_PrecacheSound, "@FM_PrecacheSound_Pre", false);
}

public plugin_init() {
	for(new i = 1; i < structIdMaps; ++i) {
		if(equal(g_CurrentMap, __MAPS[i][mapName])) {
			g_MapId = i;
			g_BlockDiff = __MAPS[i][mapBlockDiff];
			
			break;
		}
	}

	if(!checkMap()) {
		set_fail_state("El modo no funciona en el mapa actual.");
	}

	g_ExtraWaveSpeed = random_num(2, 9);

	do {
		g_ExtraWaveStrength = random_num(3, 10);
	} while(g_ExtraWaveStrength == g_ExtraWaveSpeed);

	new sEvasFile[96];
	formatex(sEvasFile, charsmax(sEvasFile), "addons/amxmodx/configs/evas/%s", g_CurrentMap);

	if(!dir_exists(sEvasFile)) {
		mkdir(sEvasFile);
	}

	register_event("Health", "@event__Health", "be");
	register_event("AmmoX", "@event__AmmoX", "be");

	if(g_FwdSpawn) {
		unregister_forward(FM_Spawn, g_FwdSpawn);
		ArrayDestroy(g_aRemoveMapsEnts);
	}

	if(g_FwdPrecacheSound) {
		unregister_forward(FM_PrecacheSound, g_FwdPrecacheSound);
	}

	register_forward(FM_GetGameDescription, "@FM_GetGameDescription_Pre", false);
	register_forward(FM_ClientKill, "@FM_ClientKill_Pre", false);
	register_forward(FM_CmdStart, "@FM_CmdStart_Pre", false);
	register_forward(FM_SetModel, "@FM_SetModel_Pre", false);
	register_forward(FM_Touch, "@FM_Touch_Pre", false);
	register_forward(FM_AddToFullPack, "@FM_AddToFullPack_Post", true);

	RegisterHam(Ham_Spawn, "player", "@Ham_PlayerSpawn_Post", true);
	RegisterHam(Ham_TakeDamage, "player", "@Ham_PlayerTakeDamage_Pre", false);
	RegisterHam(Ham_TraceAttack, "player", "@Ham_PlayerTraceAttack_Pre", false);

	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Pre", false);
	RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "@CBasePlayer_ResetMaxSpeed_Pre", false);
	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "@CBasePlayer_GiveDefaultItems_Pre", false);
	RegisterHookChain(RG_CBasePlayer_OnSpawnEquip, "@CBasePlayer_OnSpawnEquip_Pre", false);

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "@CBasePlayerWeapon_DefaultDeploy_Pre", false);

	RegisterHookChain(RG_ShowMenu, "@ShowMenu_Pre", false);
	RegisterHookChain(RG_ShowVGUIMenu, "@ShowVGUIMenu_Pre", false);
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "@HandleMenu_ChooseTeam_Pre", false);

	RegisterHam(Ham_Think, "grenade", "@Ham_ThinkGrenade_Pre", false);

	for(new WeaponIdType:i = WEAPON_P228, sWeapon[32]; i <= WEAPON_P90; ++i) {
		if(get_weaponname(_:i, sWeapon, charsmax(sWeapon))) {
			// RegisterHam(Ham_Item_Deploy, sWeapon, "@Ham_Item_Deploy_Post", true);

			if(i == WEAPON_UMP45 || i == WEAPON_GLOCK || i == WEAPON_GLOCK18 || i == WEAPON_USP || i == WEAPON_P228 || i == WEAPON_FIVESEVEN || i == WEAPON_ELITE || i == WEAPON_HEGRENADE || i == WEAPON_FLASHBANG || i == WEAPON_SMOKEGRENADE || i == WEAPON_C4 || i == WEAPON_KNIFE) {
				continue;
			}

			RegisterHam(Ham_Item_AttachToPlayer, sWeapon, "@Ham_Item_AttachToPlayer_Pre", false);
			RegisterHam(Ham_Weapon_PrimaryAttack, sWeapon, "@Ham_Weapon_PrimaryAttack_Post", true);
			
			if(i == WEAPON_XM1014 || i == WEAPON_M3) {
				RegisterHam(Ham_Item_PostFrame, sWeapon, "@Ham_Shotgun_PostFrame_Pre", false);
				RegisterHam(Ham_Weapon_WeaponIdle, sWeapon, "@Ham_Shotgun_WeaponIdle_Pre", false);
			} else {
				RegisterHam(Ham_Item_PostFrame, sWeapon, "@Ham_Item_PostFrame_Pre", false);
			}
		}
	}

	RegisterHam(Ham_Killed, "info_target", "@Ham_MonsterKilled_Pre", false);
	RegisterHam(Ham_TakeDamage, "info_target", "@Ham_MonsterTakeDamage_Pre", false);
	RegisterHam(Ham_TraceAttack, "info_target", "@Ham_MonsterTraceAttack_Pre", false);

	new j = 0;
	for(new i = 0; i < sizeof(__MAPS_FIX); ++i) {
		if(equal(g_CurrentMap, __MAPS_FIX[i][mapFixName])) {
			RegisterHam(Ham_Touch, "info_target", __MAPS_FIX[i][mapFixFunction], true);

			j = 1;
			break;
		}
	}
	
	if(!j) {
		RegisterHam(Ham_Touch, "info_target", "@Ham_TouchMonster_Post", true);
	}

	register_clcmd("say /diff", "@clcmd__Diff");
	register_clcmd("say /bailar", "@clcmd__Dance");
	register_clcmd("say /dance", "@clcmd__Dance");

	register_clcmd("say currentmap", "@clcmd__CurrentMap");

	register_clcmd("radio1", "@clcmd__PowerUp");
	register_clcmd("radio2", "@clcmd__PowerLeft");
	register_clcmd("radio3", "@clcmd__PowerRight");
	register_clcmd("say", "@clcmd__Say");
	register_clcmd("say_team", "@clcmd__Say");

	register_menucmd(register_menuid("VoteMap Menu"), (-1 ^ (-1<<g_VoteMap_SelectMaps)), "@menu__VoteMap");
	blockCommands();

	register_clcmd("td_create_eva", "@clcmd__CreateEva");
	register_clcmd("td_view_tower", "@clcmd__ViewTower");
	register_clcmd("td_walkguard", "@clcmd__WalkGuard");
	register_clcmd("td_egg", "@clcmd__Egg");
	register_clcmd("td_miniboss", "@clcmd__MiniBoss");
	register_clcmd("td_boss", "@clcmd__Boss");
	register_clcmd("td_cheats", "@clcmd__Cheats");
	register_clcmd("td_gold", "@clcmd__Gold");
	register_clcmd("td_level", "@clcmd__Level");
	register_clcmd("td_points", "@clcmd__Points");
	register_clcmd("td_class_level", "@clcmd__ClassLevel");
	register_clcmd("td_os", "@clcmd__Os");
	register_clcmd("td_tower_health", "@clcmd__TowerHealth");
	register_clcmd("td_lights", "@clcmd__Lights");

	oldmenu_register();

	g_Message_AmmoPickup = get_user_msgid("AmmoPickup");
	g_Message_ScreenFade = get_user_msgid("ScreenFade");
	g_Message_ScreenShake = get_user_msgid("ScreenShake");
	g_Message_RoundTime = get_user_msgid("RoundTime");
	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SendAudio = get_user_msgid("SendAudio");
	g_Message_ClCorpse = get_user_msgid("ClCorpse");
	g_Message_CurWeapon = get_user_msgid("CurWeapon");

	register_message(g_Message_RoundTime, "@message__RoundTime");
	register_message(g_Message_TextMsg, "@message__TextMsg");
	register_message(g_Message_SendAudio, "@message__SendAudio");
	register_message(g_Message_ClCorpse, "@message__ClCorpse");
	register_message(g_Message_CurWeapon, "@messge__CurWeapon");

	register_impulse(100, "@impulse__Flashlight");

	// g_pCvar_MonsterSpeedDefault = register_cvar("td_monster_speed", "220.0");

	loadStuff();
}

public plugin_cfg() {
	set_cvar_num("sv_maxvelocity", 4000);

	set_cvar_num("mp_autokick_timeout", 0);
	set_cvar_num("mp_freezetime", 0);

	set_cvar_num("amx_slot_reservation", 2);

	loadSql();
}

public plugin_end() {
	SQL_FreeHandle(g_SqlConnection);
	SQL_FreeHandle(g_SqlTuple);
}

public client_authorized(id, const authid[]) {
	new iUsersNum = get_playersnum(1);

	copy(g_PlayerSteamId[id], charsmax(g_PlayerSteamId[]), authid);

	if(equal(g_PlayerSteamId[id], "STEAM_0:1:424403388")) {
		g_Atsul[id] = 1;
	}

	if(g_AdminOn) {
		return PLUGIN_CONTINUE;
	}

	if(iUsersNum > MAX_SLOTS && !g_Atsul[id]) {
		rh_drop_client(id, "Este último slot está reservado para administradores.");
	}

	return PLUGIN_CONTINUE;
}

public client_putinserver(id) {
	g_Atsul[id] = 0;
	g_Tutorial[id] = 0;
	g_CurrentWeapon[id] = WEAPON_NONE;

	for(new i = 0; i < structIdNades; ++i) {
		g_Nades[id][i] = 0;
		g_Grenades_UsedByPlayer[id][i] = 0;
	}

	g_AfkDamage[id] = 0;
	g_AfkTime[id] = 0.0;
	g_InBlockZone[id] = 0;
	g_Kills[id] = 0;
	g_KillsMap[id] = 0;

	for(new i = 0; i < (MAX_WAVES + 2); ++i) {
		g_KillsPerWave[id][i] = 0;
	}

	for(new i = 0; i < (structIdDiffs + 1); ++i) {
		for(new j = 0; j < (MAX_WAVES + 1); ++j) {
			g_WavesWins[id][i][j] = 0;
		}
		
		g_BossKills[id][i] = 0;
	}

	g_GordoBomba_Kills[id] = 0;
	g_Level[id] = 0;
	g_Gold[id] = 800;
	g_GoldG[id] = 0;
	g_GoldGaben[id] = 0;
	g_GoldMap[id] = 0;
	g_NoReload[id] = 0.0;
	g_DamageDone[id] = 0;
	g_WinMVP[id] = 0;
	g_WinMVPNext[id] = 0;
	g_WinMVPGaben[id] = 0;

	for(new i = 0; i < structIdPowers; ++i) {
		g_Power[id][i] = 0;
	}

	g_PowerActual[id] = 0;
	g_UnlimitedClip[id] = 0;
	g_UnlimitedClip_WavesLeft[id] = 0;
	g_PrecisionPerfecta[id] = 0;
	g_PrecisionPerfecta_WavesLeft[id] = 0;
	g_Sentry[id] = 0;
	g_SentryDamage[id] = 0;
	g_SentryTransferMenu[id] = 0;
	g_Robot[id] = 0;
	g_ClassId[id] = 0;

	for(new i = 0; i < structIdClasses; ++i) {
		g_ClassLevel[id][i] = 0;
		g_ClassReqs[id][i] = 0;
	}

	g_ClassSoporte_Hab[id] = 0;
	g_ClassSoporte_Bonus[id] = 0;
	g_ClassPistolero_AutoFire[id] = 0;
	g_ClassScouter_Hab[id] = 0;
	g_VoteDiff[id] = DIFF_NORMAL;

	if(g_VoteDiff[id] < g_BlockDiff) {
		g_VoteDiff[id] = g_BlockDiff;
	}

	for(new i = 0; i < structIdMaps; ++i) {
		g_AutoDiff[id][i] = -1;
	}

	g_Points[id] = 10;

	for(new i = 0; i < structIdHabs; ++i) {
		g_Hab[id][i] = 0;
	}
	
	for(new i = 0; i < structIdFHabs; ++i) {
		g_HabCache[id][i] = 0.0;
	}

	g_HabCacheClip[id] = 0;

	for(new i = 0; i < structIdAchievements; ++i) {
		g_Achievement[id][i] = 0;
		g_AchievementName[id][i][0] = EOS;
		g_AchievementUnlocked[id][i] = 0;
		g_AchievementInt[id][i] = 0;
	}

	g_AchievementTimeLink[id] = 0.0;
	g_AchievementTotal[id] = 0;
	g_AchievementMap[id] = 0;
	g_AchievementTrackPistolero[id] = 0;
	g_Os[id] = 0;
	g_OsLost[id] = 0;

	for(new i = 0; i < structIdUpgrades; ++i) {
		g_Upgrades[id][i] = 0;
	}

	g_CriticChance[id] = 0;

	for(new i = 0; i < structIdTimePlayed; ++i) {
		g_TimePlayed[id][i] = 0;
	}

	g_UserOption_HudColor[id] = {255, 255, 255};
	g_UserOption_HudPosition[id] = Float:{0.02, 0.15, 0.0};
	g_UserOption_HudEffect[id] = 0;
	g_UserOption_HudProgressClass[id] = 1;
	g_UserOption_HudKillsPerWave[id] = 1;
	g_UserOption_LowFpsModels[id] = 0;
	g_UserOption_LowFpsGlow[id] = 0;
	g_UserOption_LowFpsSentries[id] = 0;
	g_UserOption_LowFpsZombieDead[id] = 0;
	g_MenuPage_Tutorial[id] = 0;
	g_MenuPage_Classes[id] = 0;
	g_MenuPage_FavDiffs[id] = 0;
	g_MenuPage_AchievementClasses[id] = 0;

	for(new i = 0; i < structIdAchievementClasses; ++i) {
		g_MenuPage_AchievementClassesIn[id][i] = 0;
	}

	g_MenuPage_Upgrade[id] = 1;
	g_MenuPage_Level[id] = 0;
	g_MenuPage_HudColor[id] = 1;
	g_MenuData_ClassId[id] = 0;
	g_MenuData_DiffId[id] = 0;
	g_MenuData_HabPoints[id] = 1;
	g_MenuData_HabId[id] = 0;
	g_MenuData_AchievementClassId[id] = 0;
	g_MenuData_AchievementClassIn[id] = 0;
	g_MenuData_AchievementId[id] = 0;
	g_MenuData_Level[id] = 0;
	g_MenuData_EntSentry[id] = 0;
	g_MenuData_EntRobot[id] = 0;

	if(equal(g_PlayerSteamId[id], "STEAM_0:1:424403388")) {
		g_Atsul[id] = 1;
		g_AdminOn = 1;
	}

	set_task(1.5, "task__ShowHud");
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	if(equal(g_PlayerSteamId[id], "STEAM_0:1:424403388")) {
		g_AdminOn = 0;
	}

	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_SAVE);
	remove_task(id + TASK_TIME_PLAYED);
	remove_task(id + TASK_CHECK_ACHIEVEMENTS);
	remove_task(id + TASK_CLASS_POWER);

	if(g_BestPlayerId == id) {
		g_BestPlayerKills = 0;
		g_BestPlayerId = 0;
	}

	new iEnt = -1;
	new iEntBase = -1;
	
	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_SENTRY)) != 0) {
		if(is_valid_ent(iEnt)) {
			if(id == entity_get_int(iEnt, SENTRY_OWNER)) {
				entity_set_int(iEnt, SENTRY_OWNER, 0);
				
				entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
				entity_set_float(iEnt, EV_FL_animtime, 1.0);
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				set_rendering(iEnt, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 3);

				iEntBase = entity_get_edict(iEnt, SENTRY_ENT_BASE);
				
				if(is_valid_ent(iEntBase)) {
					entity_set_int(iEntBase, SENTRY_OWNER, 0);
				}
			}
		}
	}
}

public fw_create_player_data(const id, const acc_id) {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `td4_pjs` WHERE (`acc_id`='%d');", acc_id);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 1);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `td4_pjs` (`acc_id`) VALUES ('%d');", acc_id);
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 2);
		} else {
			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO `td4_wave_boss` (`acc_id`) VALUES ('%d');", acc_id);
			
			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 3);
			} else {
				SQL_FreeHandle(sqlQuery);
			}
		}
	}
}

public fw_load_player_data(const id, const acc_id) {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM `td4_pjs` LEFT JOIN `td4_wave_boss` ON `td4_wave_boss`.`acc_id`=`td4_pjs`.`acc_id` WHERE (`td4_pjs`.`acc_id`='%d');", dg_get_user_acc_id(id));

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 4);
	} else if(SQL_NumResults(sqlQuery)) {
		new sInfo[128];
		new sColor[3][12];
		new sHudPosition[3][10];
		new sWave[structIdDiffs][(MAX_WAVES + 1)][8];

		remove_task(id + TASK_SAVE);
		remove_task(id + TASK_TIME_PLAYED);

		set_task(random_float(180.0, 360.0), "task__Save", id + TASK_SAVE, .flags="b");
		set_task(360.0, "task__TimePlayed", id + TASK_TIME_PLAYED, .flags="b");

		g_Tutorial[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "tutorial"));
		g_GoldGaben[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "gold"));
		g_ClassId[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "class_id"));
		g_Kills[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kills"));
		g_Level[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "level"));
		g_Points[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "points"));
		g_Os[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "os"));
		g_OsLost[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "os_lost"));
		g_WinMVPGaben[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "mvp"));

		g_ClassLevel[id][CLASS_SOLDADO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "soldado_level"));
		g_ClassReqs[id][CLASS_SOLDADO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "soldado_kills"));
		g_ClassLevel[id][CLASS_INGENIERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ingeniero_level"));
		g_ClassReqs[id][CLASS_INGENIERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "ingeniero_damage"));
		g_ClassLevel[id][CLASS_SOPORTE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "soporte_level"));
		g_ClassReqs[id][CLASS_SOPORTE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "soporte_damage"));
		g_ClassLevel[id][CLASS_FRANCOTIRADOR] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "francotirador_level"));
		g_ClassReqs[id][CLASS_FRANCOTIRADOR] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "francotirador_damage"));
		g_ClassLevel[id][CLASS_APOYO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "apoyo_level"));
		g_ClassReqs[id][CLASS_APOYO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "apoyo_damage"));
		g_ClassLevel[id][CLASS_PESADO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "pesado_level"));
		g_ClassReqs[id][CLASS_PESADO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "pesado_damage"));
		g_ClassLevel[id][CLASS_ASALTO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "asalto_level"));
		g_ClassReqs[id][CLASS_ASALTO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "asalto_kills"));
		g_ClassLevel[id][CLASS_COMANDANTE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "comandante_level"));
		g_ClassReqs[id][CLASS_COMANDANTE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "comandante_kills"));
		g_ClassLevel[id][CLASS_PISTOLERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "pistolero_level"));
		g_ClassReqs[id][CLASS_PISTOLERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "pistolero_req"));
		g_ClassLevel[id][CLASS_PUBERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "pubero_level"));
		g_ClassReqs[id][CLASS_PUBERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "pubero_damage"));
		g_ClassLevel[id][CLASS_LEGIONARIO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "legionario_level"));
		g_ClassReqs[id][CLASS_LEGIONARIO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "legionario_damage"));
		g_ClassLevel[id][CLASS_BITERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "bitero_level"));
		g_ClassReqs[id][CLASS_BITERO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "bitero_kills"));
		g_ClassLevel[id][CLASS_SCOUTER] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "scouter_level"));
		g_ClassReqs[id][CLASS_SCOUTER] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "scouter_damage"));
		g_Hab[id][HAB_DAMAGE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hab_wpn_damage"));
		g_Hab[id][HAB_PRECISION] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hab_wpn_recoil"));
		g_Hab[id][HAB_SPEED_WEAPON] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hab_wpn_speed"));
		g_Hab[id][HAB_BULLETS] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "hab_wpn_clip"));
		g_Upgrades[id][UPGRADE_CRITICAL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_critical"));
		g_Upgrades[id][UPGRADE_RESISTENCE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_resistence"));
		g_Upgrades[id][UPGRADE_THOR] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_thor"));
		g_Upgrades[id][UPGRADE_UNLOCK_APOYO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_apoyo"));
		g_Upgrades[id][UPGRADE_UNLOCK_PESADO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_pesado"));
		g_Upgrades[id][UPGRADE_UNLOCK_ASALTO] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_asalto"));
		g_Upgrades[id][UPGRADE_UNLOCK_COMANDANTE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_comandante"));
		g_Upgrades[id][UPGRADE_HEALTH] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_health"));
		g_Upgrades[id][UPGRADE_VELOCITY] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "upgrade_velocity"));

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_color"), sInfo, charsmax(sInfo));
		parse(sInfo, sColor[__R], charsmax(sColor[]), sColor[__G], charsmax(sColor[]), sColor[__B], charsmax(sColor[]));
		
		g_UserOption_HudColor[id][__R] = str_to_num(sColor[__R]);
		g_UserOption_HudColor[id][__G] = str_to_num(sColor[__G]);
		g_UserOption_HudColor[id][__B] = str_to_num(sColor[__B]);

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_position"), sInfo, charsmax(sInfo));
		parse(sInfo, sHudPosition[0], charsmax(sHudPosition[]), sHudPosition[1], charsmax(sHudPosition[]), sHudPosition[2], charsmax(sHudPosition[]));
		
		g_UserOption_HudPosition[id][0] = str_to_float(sHudPosition[0]);
		g_UserOption_HudPosition[id][1] = str_to_float(sHudPosition[1]);
		g_UserOption_HudPosition[id][2] = str_to_float(sHudPosition[2]);

		g_UserOption_HudEffect[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_effect"));
		g_UserOption_HudProgressClass[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_progress_class"));
		g_UserOption_HudKillsPerWave[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_hud_kills_per_wave"));
		g_UserOption_LowFpsModels[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_lowfps_zombiemodels"));
		g_UserOption_LowFpsGlow[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_lowfps_glow"));
		g_UserOption_LowFpsSentries[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_lowfps_sentries"));
		g_UserOption_LowFpsZombieDead[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "uo_lowfps_zombiedead"));
		g_Power[id][POWER_BALAS_INFINITAS] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "power_infis")), 0, 10);
		g_Power[id][POWER_PRECISION_PERFECTA] = clamp(SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "power_no_recoil")), 0, 15);

		g_TimePlayed[id][TIME_MIN] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "time_played"));

		new iHour = (g_TimePlayed[id][TIME_MIN] / 60);
		new iDay = 0;
		
		while(iHour >= 24) {
			++iDay;
			iHour -= 24;
		}
		
		g_TimePlayed[id][TIME_HOUR] = iHour;
		g_TimePlayed[id][TIME_DAY] = iDay;

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "waves_normal"), sInfo, charsmax(sInfo));
		parse(sInfo, sWave[DIFF_NORMAL][0], charsmax(sWave[][]), sWave[DIFF_NORMAL][1], charsmax(sWave[][]), sWave[DIFF_NORMAL][2], charsmax(sWave[][]), sWave[DIFF_NORMAL][3], charsmax(sWave[][]), sWave[DIFF_NORMAL][4], charsmax(sWave[][]), sWave[DIFF_NORMAL][5], charsmax(sWave[][]), sWave[DIFF_NORMAL][6], charsmax(sWave[][]), sWave[DIFF_NORMAL][7], charsmax(sWave[][]), sWave[DIFF_NORMAL][8], charsmax(sWave[][]), sWave[DIFF_NORMAL][9], charsmax(sWave[][]), sWave[DIFF_NORMAL][10], charsmax(sWave[][]));
		
		for(new i = 0; i < (MAX_WAVES + 1); ++i) {
			g_WavesWins[id][DIFF_NORMAL][i] = str_to_num(sWave[DIFF_NORMAL][i]);
		}

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "waves_nightmare"), sInfo, charsmax(sInfo));
		parse(sInfo, sWave[DIFF_NIGHTMARE][0], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][1], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][2], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][3], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][4], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][5], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][6], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][7], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][8], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][9], charsmax(sWave[][]), sWave[DIFF_NIGHTMARE][10], charsmax(sWave[][]));
		
		for(new i = 0; i < (MAX_WAVES + 1); ++i) {
			g_WavesWins[id][DIFF_NIGHTMARE][i] = str_to_num(sWave[DIFF_NIGHTMARE][i]);
		}

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "waves_suicidal"), sInfo, charsmax(sInfo));
		parse(sInfo, sWave[DIFF_SUICIDAL][0], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][1], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][2], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][3], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][4], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][5], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][6], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][7], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][8], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][9], charsmax(sWave[][]), sWave[DIFF_SUICIDAL][10], charsmax(sWave[][]));
		
		for(new i = 0; i < (MAX_WAVES + 1); ++i) {
			g_WavesWins[id][DIFF_SUICIDAL][i] = str_to_num(sWave[DIFF_SUICIDAL][i]);
		}

		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "waves_hell"), sInfo, charsmax(sInfo));
		parse(sInfo, sWave[DIFF_HELL][0], charsmax(sWave[][]), sWave[DIFF_HELL][1], charsmax(sWave[][]), sWave[DIFF_HELL][2], charsmax(sWave[][]), sWave[DIFF_HELL][3], charsmax(sWave[][]), sWave[DIFF_HELL][4], charsmax(sWave[][]), sWave[DIFF_HELL][5], charsmax(sWave[][]), sWave[DIFF_HELL][6], charsmax(sWave[][]), sWave[DIFF_HELL][7], charsmax(sWave[][]), sWave[DIFF_HELL][8], charsmax(sWave[][]), sWave[DIFF_HELL][9], charsmax(sWave[][]), sWave[DIFF_HELL][10], charsmax(sWave[][]));
		
		for(new i = 0; i < (MAX_WAVES + 1); ++i) {
			g_WavesWins[id][DIFF_HELL][i] = str_to_num(sWave[DIFF_HELL][i]);
		}

		g_BossKills[id][DIFF_NORMAL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "boss_normal"));
		g_BossKills[id][DIFF_NIGHTMARE] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "boss_nightmare"));
		g_BossKills[id][DIFF_SUICIDAL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "boss_suicidal"));
		g_BossKills[id][DIFF_HELL] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "boss_hell"));

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `achievement_id`, `achievement_timestamp` FROM `td4_achievements` WHERE (`acc_id`='%d');", dg_get_user_acc_id(id));

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 5);
		} else if(SQL_NumResults(sqlQuery)) {
			new iAchievement;
			
			while(SQL_MoreResults(sqlQuery)) {
				iAchievement = SQL_ReadResult(sqlQuery, 0);
				
				g_Achievement[id][iAchievement] = 1;
				g_AchievementUnlocked[id][iAchievement] = SQL_ReadResult(sqlQuery, 1);
				g_AchievementTotal[id]++;

				SQL_NextRow(sqlQuery);
			}

			remove_task(id + TASK_CHECK_ACHIEVEMENTS);
			set_task(random_float(10.0, 20.0), "task__CheckAchievements", id + TASK_CHECK_ACHIEVEMENTS);

			SQL_FreeHandle(sqlQuery);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		for(new i = 0; i < structIdMaps; ++i) {
			g_AutoDiff[id][i] = __MAPS[i][mapBlockDiff];
		}

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT `map_id`, `diff_id` FROM `td4_map_diffs` WHERE (`acc_id`='%d');", dg_get_user_acc_id(id));

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 6);
		} else if(SQL_NumResults(sqlQuery)) {
			new iMapId;
			new iDifficultId;

			while(SQL_MoreResults(sqlQuery)) {
				iMapId = clamp(SQL_ReadResult(sqlQuery, 0), TD_DARK_NIGHT, (structIdMaps - 1));
				iDifficultId = clamp(SQL_ReadResult(sqlQuery, 1), DIFF_NORMAL, DIFF_HELL);

				g_AutoDiff[id][iMapId] = iDifficultId;
				g_VoteDiff[id] = iDifficultId;

				SQL_NextRow(sqlQuery);
			}

			SQL_FreeHandle(sqlQuery);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		dg_set_user_acc_status(id, STATUS_LOGGED);
		dg_get_user_menu_join(id);
	} else {
		rh_drop_client(id, "Hubo un error al detectar los datos de tu personaje al ingresar con tu cuenta. Contáctate con el desarrollador general para más información.");
		SQL_FreeHandle(sqlQuery);
	}
}

public fw_join_player(const id) {
	if(g_Tutorial[id]) {
		dg_set_user_acc_status(id, STATUS_PLAYING);
		rg_join_team(id, TEAM_CT);

		set_member(id, m_bTeamChanged, true);

		remove_task(id + TASK_SPAWN);
		set_task(0.5, "task__RespawnPlayer", id + TASK_SPAWN);
	} else {
		showMenu__Tutorial(id, 0);
	}
}

public fw_vinc_player_success(const id) {
	setAchievement(id, VINCULADO);
}

public fw_save_other_data(const id, const acc_id) {
	savePlayerData(id, acc_id);
}

@event__Health(const id) {
	g_Health[id] = get_user_health(id);
}

@event__AmmoX(const id) {
	if(g_Wave == (MAX_WAVES + 1) || (g_ClassId[id] == CLASS_LEGIONARIO && g_ClassLevel[id][CLASS_LEGIONARIO] == 6)) {
		new iAmmoWeapon = read_data(1);
		
		if(iAmmoWeapon >= sizeof(__AMMO_WEAPON)) {
			return;
		}
		
		new iWeaponId = __AMMO_WEAPON[iAmmoWeapon];
		
		if(__MAX_BPAMMO[iWeaponId] <= 2) {
			return;
		}
		
		new iAmount = read_data(2);
		
		if(iAmount < __MAX_BPAMMO[iWeaponId]) {
			new sArgs[1];
			sArgs[0] = iWeaponId;
			
			set_task(0.1, "task__RefillBPAmmo", id, sArgs, sizeof(sArgs));
		}
	}
}

@FM_Sys_Error_Pre(const errors[]) {
	log_to_file(__SERVER_FILE, "FORWARD: FM_Sys_Error | Error: %s | Mapa: %s", ((errors[0]) ? errors : "Ninguno"), g_CurrentMap);
}

@FM_GameShutdown_Pre(const errors[]) {
	log_to_file(__SERVER_FILE, "FORWARD: FM_GameShutdown | Error: %s | Mapa: %s", ((errors[0]) ? errors : "Ninguno"), g_CurrentMap);
}

@FM_Spawn_Pre(const ent) {
	new sClassName[32];
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(ArrayFindString(g_aRemoveMapsEnts, sClassName) != -1) {
		forward_return(FMV_CELL, -1);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

@FM_PrecacheSound_Pre(const sound[]) {
	if(equal(sound, "hostage", 7)) {
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

@FM_GetGameDescription_Pre() {
	new sGameDescription[64];
	
	if(g_Wave) {
		if(g_Wave != (MAX_WAVES + 1)) {
			formatex(sGameDescription, charsmax(sGameDescription), "%s | %s [%d / %d]", __PLUGIN_COMMUNITY_NAME, __DIFFS[g_Diff][diffNameMay], g_Wave, MAX_WAVES);
		} else {
			formatex(sGameDescription, charsmax(sGameDescription), "%s | %s [%s]", __PLUGIN_COMMUNITY_NAME, __DIFFS[g_Diff][diffNameMay], __BOSSES_NAME[g_BossId][bossNameFF]);
		}
	} else {
		formatex(sGameDescription, charsmax(sGameDescription), "%s | EN VOTACIÓN", __PLUGIN_COMMUNITY_NAME);
	}

	forward_return(FMV_STRING, sGameDescription);
	return FMRES_SUPERCEDE;
}

@FM_ClientKill_Pre() {
	return FMRES_SUPERCEDE;
}

@FM_CmdStart_Pre(const id, const uc_handle, const seed) {
	if(!is_user_alive(id)) {
		return;
	}

	if(g_VoteMap) {
		return;
	}

	static iButton;
	static iOldButton;

	iButton = get_uc(uc_handle, UC_Buttons);
	iOldButton = get_entvar(id, var_oldbuttons);

	if((iButton & IN_USE) && !(iOldButton & IN_USE)) {
		static Float:vecOrigin[3];
		static iShop;
		static i;

		entity_get_vector(id, EV_VEC_origin, vecOrigin);
		iShop = 0;

		for(i = 0; i < g_EntEvasNums; ++i) {
			if(get_distance_f(g_EntEvasOrigin[i], vecOrigin) <= 150.0) {
				iShop = 1337;

				showMenu__Shop(id);
				break;
			}
		}

		if(iShop != 1337) {
			if(g_CurrentWeapon[id] == WEAPON_KNIFE) {
				showMenu__SentryAndRobot(id);
			}
		}
	} else if((iButton & IN_ATTACK) && g_CurrentWeapon[id] == WEAPON_DEAGLE && (g_ClassLevel[id][CLASS_PISTOLERO] == 6 && g_ClassId[id] == CLASS_PISTOLERO) && g_ClassPistolero_AutoFire[id]) {
		set_uc(uc_handle, UC_Buttons, (iButton & ~IN_ATTACK));
		g_ClassPistolero_AutoFire[id] = 0;
	}
}

@FM_SetModel_Pre(const ent, const model[]) {
	if(strlen(model) < 8) {
		return FMRES_IGNORED;
	}
	
	static sClassName[12];
	get_entvar(ent, var_classname, sClassName, charsmax(sClassName));
	
	if(equal(sClassName, "weaponbox")) {
		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.01));
		return FMRES_IGNORED;
	}
	
	if(model[7] != 'w' || model[8] != '_') {
		return FMRES_IGNORED;
	}
	
	static Float:flDamageTime;
	flDamageTime = entity_get_float(ent, EV_FL_dmgtime);

	if(flDamageTime == 0.0) {
		return FMRES_IGNORED;
	}
	
	static iId;
	iId = entity_get_edict(ent, EV_ENT_owner);
	
	switch(model[9]) {
		case 'h': {
			if(g_Nades[iId][NADE_ION_BOMB]) {
				--g_Nades[iId][NADE_ION_BOMB];

				effectGrenade(ent, 71, 60, 139, .nade_type=NADE_TYPE_ION_BOMB);

				entity_set_model(ent, __GRENADE_wION);
				return FMRES_SUPERCEDE;
			} else if(g_Nades[iId][NADE_EXPLOSION]) {
				--g_Nades[iId][NADE_EXPLOSION];

				effectGrenade(ent, 255, 0, 0, .nade_type=NADE_TYPE_EXPLOSION);
			}
		} case 'f': {
			if(g_Nades[iId][NADE_REMUEVE_PROTECCION]) {
				--g_Nades[iId][NADE_REMUEVE_PROTECCION];

				effectGrenade(ent, 255, 255, 255, .nade_type=NADE_TYPE_REMUEVE_PROTECCION);
			}
		} case 's': {
			if(g_Nades[iId][NADE_AUMENTA_DMG_RECIBIDO]) {
				--g_Nades[iId][NADE_AUMENTA_DMG_RECIBIDO];

				effectGrenade(ent, 0, 255, 0, .nade_type=NADE_TYPE_AUMENTA_DMG_RECIBIDO);
			}
		}
	}
	
	return FMRES_IGNORED;
}

@FM_Touch_Pre(const ent, const id) {
	if(!is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}
	
	if(!is_user_alive(id)) {
		return FMRES_IGNORED;
	}
	
	zoneTouch(id, ent);
	return FMRES_IGNORED;
}

@FM_AddToFullPack_Post(const es, const e, const ent, const host, const host_flags, const player, const player_set) {	
	if(is_user_connected(host) && !is_user_connected(ent) && pev_valid(ent)) {
		if(g_UserOption_LowFpsModels[host] || g_UserOption_LowFpsGlow[host]) {
			if(isMonsterLowFps(ent)) {
				if(g_UserOption_LowFpsModels[host]) {
					set_es(es, ES_ModelIndex, g_ModelIndex_ZombieLowFps);
				}

				if(g_UserOption_LowFpsGlow[host]) {
					set_es(es, ES_RenderFx, kRenderFxNone);
					// set_es(es, ES_RenderMode, kRenderNormal);
				}
			}
		}

		if(g_UserOption_LowFpsSentries[host]) {
			if(isSentryLowFps(ent)) {
				if(entity_get_int(ent, SENTRY_OWNER) && entity_get_int(ent, SENTRY_CLIP)) {
					set_es(es, ES_RenderMode, kRenderTransTexture);
					set_es(es, ES_RenderAmt, 0);
				}
			}
		}

		if(g_UserOption_LowFpsZombieDead[host]) {
			if(isMonsterLowFps(ent)) {
				if(!entity_get_int(ent, MONSTER_MAXHEALTH)) {
					set_es(es, ES_RenderMode, kRenderTransTexture);
					set_es(es, ES_RenderAmt, 0);
				}
			}
		}
	}
	
	return FMRES_IGNORED;
}

@Ham_PlayerSpawn_Post(const id) {
	if(!is_user_alive(id)) {
		return;
	}

	new TeamName:iTeam = getUserTeam(id);

	if(iTeam == TEAM_UNASSIGNED) {
		return;
	}

	remove_task(id + TASK_SPAWN);

	if(iTeam != TEAM_CT) {
		setUserTeam(id, TEAM_CT);
	}

	if(g_WaveInProgress) {
		user_silentkill(id);

		clientPrintColor(id, _, "Tenés que esperar a la !gSIGUIENTE OLEADA!y para empezar a jugar. No puedes entrar en la mitad de la misma.");
		return;
	} else if(isPlayerStuck(id)) {
		user_silentkill(id);

		clientPrintColor(id, _, "Has muerto porque te has trabado con un humano.");
		return;
	}

	updateHealth(id, HEALTH_BASE);

	g_HabCache[id][_:HAB_F_DAMAGE] = (float(g_Hab[id][HAB_DAMAGE]) * __HABS[HAB_DAMAGE][habValue]);
	g_HabCache[id][_:HAB_F_PRECISION] = (float(g_Hab[id][HAB_PRECISION]) * __HABS[HAB_PRECISION][habValue]);
	g_HabCache[id][_:HAB_F_SPEED_WEAPON] = (float(g_Hab[id][HAB_SPEED_WEAPON]) * __HABS[HAB_SPEED_WEAPON][habValue]);
	g_HabCacheClip[id] = (g_Hab[id][HAB_BULLETS] * floatround(__HABS[HAB_BULLETS][habValue]));

	g_CriticChance[id] = (g_Upgrades[id][UPGRADE_CRITICAL] * __UPGRADES[UPGRADE_CRITICAL][upgradeValue]);

	g_InBlockZone[id] = 0;

	set_member(id, m_iHideHUD, (get_member(id, m_iHideHUD) | (HIDEHUD_HEALTH | HIDEHUD_MONEY)));

	cs_set_user_money(id, 0, 0);
}

updateHealth(const id, const health_base) {
	set_user_health(id, (health_base + (g_Upgrades[id][UPGRADE_HEALTH] * __UPGRADES[UPGRADE_HEALTH][upgradeValue])));
	g_Health[id] = get_user_health(id);
}

@CBasePlayer_Killed_Pre(const victim, const killer, const should_gib) {
	if(!is_user_connected(victim)) {
		return;
	}

	if(killer == g_Boss) {
		SetHookChainArg(3, ATYPE_INTEGER, 2);
	}
	
	g_UnlimitedClip[victim] = 0;
	g_PrecisionPerfecta[victim] = 0;

	if(!g_WaveInProgress) {
		set_task(0.3, "task__RespawnPlayer", victim + TASK_SPAWN);
	}

	if(!getUsersAlive()) {
		removeAllEnts(1);
		finishGame();
	}
}

@Ham_PlayerTakeDamage_Pre(const victim, const inflictor, const attacker, Float:damage, const bits_damage_type) {
	if(is_user_alive(victim)) {
		if(bits_damage_type == 131072 && damage > 300000.0) {
			setAchievement(victim, KSUB_DEATH);
			return HAM_IGNORED;
		}

		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

@Ham_PlayerTraceAttack_Pre(const victim, const attacker, const Float:damage, const Float:direction[3], const tracehandle, const damage_type) {
	if(is_user_alive(victim)) {
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

@CBasePlayer_ResetMaxSpeed_Pre(const id) {
	if(!is_user_alive(id)) {
		return HC_CONTINUE;
	}

	new Float:flSpeed;

	if(g_NextWaveIncoming == 2) {
		flSpeed = 250.0;
	} else {
		if(g_Upgrades[id][UPGRADE_VELOCITY]) {
			flSpeed = floatclamp((240.0 + float(g_Upgrades[id][UPGRADE_VELOCITY] * (__UPGRADES[UPGRADE_VELOCITY][upgradeValue]))), MIN_VELOCITY_HUMAN, MAX_VELOCITY_HUMAN);
		} else {
			new iActiveItem = get_member(id, m_pActiveItem);
			
			if(!is_nullent(iActiveItem)) {
				ExecuteHamB(Ham_CS_Item_GetMaxSpeed, iActiveItem, flSpeed);
			} else {
				flSpeed = 240.0;
			}
		}
	}

	set_entvar(id, var_maxspeed, flSpeed);
	return HC_SUPERCEDE;
}

@CBasePlayer_GiveDefaultItems_Pre(const id) {
	rg_remove_all_items(id);
	rg_give_item(id, "weapon_knife", GT_APPEND);

	rg_give_item(id, "weapon_deagle", GT_APPEND);
	rg_set_user_bpammo(id, WEAPON_DEAGLE, 200);

	return HC_SUPERCEDE;
}

@CBasePlayer_OnSpawnEquip_Pre(const id, const bool:add_default, const bool:equip_game) {
	SetHookChainArg(3, ATYPE_BOOL, false);
}

@CBasePlayer_Jump_Pre(const id) {
	if(is_user_alive(id)) {
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

@CBasePlayer_Duck_Pre(const id) {
	if(g_BossPower[0] == BOSS_POWER_ATTRACT && is_user_alive(id)) {
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

@CBasePlayerWeapon_DefaultDeploy_Pre(const weapon_ent, const view_odel[], const weapon_model[], const anim, const anim_ext[], const skip_local) {
	new iId = get_member(weapon_ent, m_pPlayer);

	if(!is_user_alive(iId)) {
		return;
	}

	new WeaponIdType:iWeaponId = get_member(weapon_ent, m_iId);
	
	switch(iWeaponId) {
		case WEAPON_KNIFE: {
			set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, 99999.0);
			set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, 99999.0);
			
			SetHookChainArg(2, ATYPE_STRING, __KNIFE_vTOOL);
			SetHookChainArg(3, ATYPE_STRING, __KNIFE_pTOOL);
		} case WEAPON_HEGRENADE: {
			if(g_Nades[iId][NADE_ION_BOMB]) {
				SetHookChainArg(2, ATYPE_STRING, __GRENADE_vION);
				SetHookChainArg(3, ATYPE_STRING, __GRENADE_pION);
			}
		}
	}

	g_CurrentWeapon[iId] = iWeaponId;
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

@HandleMenu_ChooseTeam_Pre(const id, const MenuChooseTeam:slot) {
	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

@Ham_ThinkGrenade_Pre(const ent) {
	if(is_nullent(ent)) {
		return HAM_IGNORED;
	}

	new Float:flDamageTime = get_entvar(ent, var_dmgtime);
	new Float:flGameTime = get_gametime();
	
	if(flDamageTime > flGameTime) {
		return HAM_IGNORED;
	}
	
	new iType = get_entvar(ent, var_flTimeStepSound);

	if(iType) {
		new iId = entity_get_edict(ent, EV_ENT_owner);
		
		if(!is_user_connected(iId)) {
			set_entvar(ent, var_flags, FL_KILLME);
			return HAM_IGNORED;
		}
		
		new Float:vecOrigin[3];
		new iVictim;
		
		get_entvar(ent, var_origin, vecOrigin);

		switch(iType) {
			case NADE_TYPE_EXPLOSION: {
				createExplosion(vecOrigin, 255, 0, 0);

				new iCount = 0;
				new Float:fDamage;
				new Float:fHealth;
				new Float:fDamageTotal = 0.0;
				new iCountVictims = 0;
				new sText[32];
				
				iVictim = -1;
				
				while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 500.0)) != 0) {
					if(!isMonster(iVictim)) {
						continue;
					}

					if(entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_ALIEN || entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_TANK) {
						continue;
					}
					
					++iCount;
					
					fDamage = random_float(35.0, 85.0);
					fHealth = (entity_get_float(iVictim, EV_FL_health) - fDamage);
					fDamageTotal += fDamage;
					
					if(fHealth > 0.0) {
						entity_set_float(iVictim, EV_FL_health, fHealth);
					} else {
						removeMonster(iVictim, iId, 1);
						iCountVictims++;
					}
				}
				
				formatex(sText, charsmax(sText), "^n¡%d MATADO%s!", iCountVictims, ((iCountVictims != 1) ? "s" : ""));
				
				set_hudmessage(255, 255, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
				ShowSyncHudMsg(iId, g_HudSync_Damage, "%0.0f [%d Hit%s]%s", fDamageTotal, iCount, ((iCount != 1) ? "s" : ""), sText);
			} case NADE_TYPE_REMUEVE_PROTECCION: {
				createExplosion(vecOrigin, 255, 255, 255);
				
				iVictim = -1;

				while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 500.0)) != 0) {
					if(!isMonster(iVictim)) {
						continue;
					}
					
					if(entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_ALIEN || entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_TANK) {
						continue;
					}
					
					if(entity_get_float(iVictim, MONSTER_SHIELD) == 1.0) {
						entity_set_float(iVictim, MONSTER_SHIELD, 0.0);
						set_rendering(iVictim);
					}
				}
			} case NADE_TYPE_AUMENTA_DMG_RECIBIDO: {
				createExplosion(vecOrigin, 0, 255, 0);
				
				iVictim = -1;
				
				while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 500.0)) != 0) {
					if(!isMonster(iVictim)) {
						continue;
					}
					
					if(entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_ALIEN || entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_TANK) {
						continue;
					}
					
					entity_set_float(iVictim, MONSTER_SHIELD, 2.0);
					set_rendering(iVictim, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
				}
			} case NADE_TYPE_ION_BOMB: {
				new iIonMode = get_entvar(ent, var_flSwimTime);

				if(iIonMode) {
					new iOk = 0;

					iVictim = -1;

					while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 500.0)) != 0) {
						if(!isMonster(iVictim)) {
							continue;
						}

						if(isBoomerMonster(iVictim)) {
							continue;
						}

						if(entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_ALIEN || entity_get_float(iVictim, MONSTER_UNIQUE) == MONSTER_TANK) {
							continue;
						}
						
						if(entity_get_float(iVictim, EV_FL_takedamage) != DAMAGE_YES) {
							continue;
						}

						if(entity_get_int(iVictim, EV_INT_flTimeStepSound) == 1337) {
							continue;
						}

						set_rendering(iVictim, kRenderFxGlowShell, 71, 60, 139, kRenderNormal, 4);

						entity_set_int(iVictim, EV_INT_flTimeStepSound, 1337);

						iOk = 1;
					}

					if(iOk) {
						if(!task_exists(ent + TASK_ION_BOMB_EXPLODE)) {
							set_task(6.0, "task__IonBombExplode", ent + TASK_ION_BOMB_EXPLODE);
						}
					}

					set_entvar(ent, var_dmgtime, (flGameTime + 0.1));
					return HAM_IGNORED;
				} else {
					set_entvar(ent, var_flSwimTime, 1);
				}
				
				set_entvar(ent, var_dmgtime, (flGameTime + 35.0));
				return HAM_IGNORED;
			}
		}

		set_entvar(ent, var_flags, FL_KILLME);
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

// @Ham_Item_Deploy_Post(const weapon_ent) {
	// new iId = get_member(weapon_ent, m_pPlayer);
	
	// if(is_nullent(iId)) {
		// return;
	// }
	
	// new WeaponIdType:iWeaponId = WeaponIdType:get_member(weapon_ent, m_iId);
	
	// if(iWeaponId == WEAPON_KNIFE) {
		// set_member(weapon_ent, m_Weapon_flNextPrimaryAttack, 99999.0);
		// set_member(weapon_ent, m_Weapon_flNextSecondaryAttack, 99999.0);
	// }

	// g_CurrentWeapon[iId] = iWeaponId;
// }

@Ham_Item_AttachToPlayer_Pre(const weapon_ent, const id) {
	if(is_nullent(weapon_ent)) {
		return;
	}

	new iWithCorrectWeapon = 0;

	if(g_CurrentWeapon[id] == __CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == __CLASSES_WEAPONS[g_ClassId[id]][1]) {
		iWithCorrectWeapon = 1;
	}

	if(g_Hab[id][HAB_BULLETS] || iWithCorrectWeapon) {
		if(g_Hab[id][HAB_BULLETS] || __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip]) {
			if(get_pdata_int(weapon_ent, OFFSET_KNOWN, OFFSET_LINUX_WEAPONS)) {
				return;
			}
			
			new iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			new iClassExtraClip = 0;
			new iExtraClip = __DEFAULT_MAXCLIP[iWeaponId];

			if(iWithCorrectWeapon) {
				iClassExtraClip = __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip];
			}

			iExtraClip = (iExtraClip + ((iExtraClip * g_HabCacheClip[id]) / 100) + iClassExtraClip);
			set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, iExtraClip, OFFSET_LINUX_WEAPONS);
		}
	}
}

@Ham_Weapon_PrimaryAttack_Post(const weapon_ent) {
	if(!pev_valid(weapon_ent)) {
		return HAM_IGNORED;
	}

	new iId = get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
	
	if(!is_user_alive(iId)) {
		return HAM_IGNORED;
	}

	new iWithCorrectWeapon = 0;

	if(g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][0] || g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][1]) {
		iWithCorrectWeapon = 1;
	}

	if(g_HabCache[iId][HAB_F_PRECISION] || g_HabCache[iId][HAB_F_SPEED_WEAPON] || iWithCorrectWeapon) {
		if(cs_get_weapon_ammo(weapon_ent) < 1) {
			return HAM_IGNORED;
		}

		if(__CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribRecoil] || g_HabCache[iId][HAB_F_PRECISION]) {
			new Float:vecRecoil[3];
			new Float:flRecoil = g_HabCache[iId][HAB_F_PRECISION];
			
			entity_get_vector(iId, EV_VEC_punchangle, vecRecoil);
			
			if(iWithCorrectWeapon) {
				flRecoil += __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribRecoil];
			}
			
			if(flRecoil > 100.0) {
				flRecoil = 100.0;
			}

			vecRecoil[0] = vecRecoil[0] - ((vecRecoil[0] * flRecoil) / 100.0);
			vecRecoil[1] = vecRecoil[1] - ((vecRecoil[1] * flRecoil) / 100.0);
			vecRecoil[2] = vecRecoil[2] - ((vecRecoil[2] * flRecoil) / 100.0);
			
			entity_set_vector(iId, EV_VEC_punchangle, vecRecoil);
		}

		if(__CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribSpeed] || g_HabCache[iId][HAB_F_SPEED_WEAPON]) {
			new Float:vecSpeed[3];
			new Float:flSpeed = g_HabCache[iId][HAB_F_SPEED_WEAPON];
			
			vecSpeed[0] = get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS);
			vecSpeed[1] = get_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS);
			vecSpeed[2] = get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS);

			if(iWithCorrectWeapon) {
				flSpeed += __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribSpeed];
			}

 			vecSpeed[0] = vecSpeed[0] - ((vecSpeed[0] * flSpeed) / 100.0);
			vecSpeed[1] = vecSpeed[1] - ((vecSpeed[1] * flSpeed) / 100.0);
			vecSpeed[2] = vecSpeed[2] - ((vecSpeed[2] * flSpeed) / 100.0);
			
			set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, vecSpeed[0], OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, vecSpeed[1], OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, vecSpeed[2], OFFSET_LINUX_WEAPONS);
		}
	}

	if(g_CurrentWeapon[iId] == WEAPON_SCOUT && (g_ClassLevel[iId][CLASS_SCOUTER] == 6 && g_ClassId[iId] == CLASS_SCOUTER) && g_ClassScouter_Hab[iId] == 1) {
		if(cs_get_weapon_ammo(weapon_ent) < 1) {
			return HAM_IGNORED;
		}

		new Float:vecPunchangle[3];
		new Float:flSpeed = 0.05;

		vecPunchangle[0] = -5.5;

		set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
		set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, flSpeed, OFFSET_LINUX_WEAPONS);
		set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, flSpeed, OFFSET_LINUX_WEAPONS);

		entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
		return HAM_IGNORED;
	}

	if(g_PrecisionPerfecta[iId]) {
		if(cs_get_weapon_ammo(weapon_ent) < 1) {
			return HAM_IGNORED;
		}

		new Float:vecRecoil[3];
		entity_get_vector(iId, EV_VEC_punchangle, vecRecoil);

		vecRecoil[0] = vecRecoil[0] - ((vecRecoil[0] * 100.0) / 100.0);
		vecRecoil[1] = vecRecoil[1] - ((vecRecoil[1] * 100.0) / 100.0);
		vecRecoil[2] = vecRecoil[2] - ((vecRecoil[2] * 100.0) / 100.0);

		entity_set_vector(iId, EV_VEC_punchangle, vecRecoil);
	}

	if(g_CurrentWeapon[iId] == WEAPON_DEAGLE && (g_ClassLevel[iId][CLASS_PISTOLERO] == 6 && g_ClassId[iId] == CLASS_PISTOLERO)) {
		g_ClassPistolero_AutoFire[iId] = 1;
	}

	return HAM_IGNORED;
}

@Ham_Shotgun_PostFrame_Pre(const weapon_ent) {
	if(!pev_valid(weapon_ent)) {
		return;
	}

	new iId = get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
	
	if(!is_user_alive(iId)) {
		return;
	}

	if(g_Hab[iId][HAB_BULLETS] || g_CurrentWeapon[iId] == WEAPON_M3 || g_CurrentWeapon[iId] == WEAPON_XM1014) {
		if(g_Hab[iId][HAB_BULLETS] || __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribClip]) {
			new iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			new iExtraClip = 0;
			new iMaxClip = 0;
			new iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
			new iBPAmmo = get_pdata_int(iId, OFFSET_M3_AMMO, OFFSET_LINUX);

			if(g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][0] || g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][1]) {
				iExtraClip = __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribClip];
			}

			iMaxClip = __DEFAULT_MAXCLIP[iWeaponId];
			iMaxClip = (iMaxClip + ((iMaxClip * g_HabCacheClip[iId]) / 100) + iExtraClip);

			if(get_pdata_int(weapon_ent, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS) && get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX) <= 0.0) {
				new i = min((iMaxClip - iClip), iBPAmmo);
				
				set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (iClip + i), OFFSET_LINUX_WEAPONS);
				set_pdata_int(iId, OFFSET_M3_AMMO, (iBPAmmo - i), OFFSET_LINUX);
				set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);
				
				return;
			}

			new iButton = entity_get_int(iId, EV_INT_button);

			if((iButton & IN_ATTACK) && get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0) {
				return;
			}

			if(iButton & IN_RELOAD) {
				if(iClip >= iMaxClip) {
					entity_set_int(iId, EV_INT_button, (iButton & ~IN_RELOAD));
					set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, 0.5, OFFSET_LINUX_WEAPONS);
				} else if(iClip == __DEFAULT_MAXCLIP[iWeaponId] && iBPAmmo) {
					shotgunReload(weapon_ent, iWeaponId, iMaxClip, iClip, iBPAmmo, iId);
				}
			}
		}
	}
}

@Ham_Shotgun_WeaponIdle_Pre(const weapon_ent) {
	if(!pev_valid(weapon_ent)) {
		return;
	}

	new iId = get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
	
	if(!is_user_alive(iId)) {
		return;
	}

	if(g_Hab[iId][HAB_BULLETS] || g_CurrentWeapon[iId] == WEAPON_M3 || g_CurrentWeapon[iId] == WEAPON_XM1014) {
		if(g_Hab[iId][HAB_BULLETS] || __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribClip]) {
			new iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			
			if(get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS) > 0.0) {
				return;
			}

			new iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
			new iSpecialReload = get_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS);

			if(!iClip && !iSpecialReload) {
				return;
			}

			if(iSpecialReload) {
				new iExtraClip = 0;
				new iMaxClip = 0;
				new iBPAmmo;
				
				if(g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][0] || g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][1]) {
					iExtraClip = __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribClip];
				}

				iMaxClip = __DEFAULT_MAXCLIP[_:iWeaponId];
				iMaxClip = (iMaxClip + ((iMaxClip * g_HabCacheClip[iId]) / 100) + iExtraClip);
				iBPAmmo = get_pdata_int(iId, OFFSET_M3_AMMO, OFFSET_LINUX);

				if(iClip < iMaxClip && iClip == __DEFAULT_MAXCLIP[iWeaponId] && iBPAmmo) {
					shotgunReload(weapon_ent, iWeaponId, iMaxClip, iClip, iBPAmmo, iId);
					return;
				} else if(iClip == iMaxClip && iClip != __DEFAULT_MAXCLIP[iWeaponId]) {
					sendWeaponAnimation(iId, 4);
					
					set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 0, OFFSET_LINUX_WEAPONS);
					set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 1.5, OFFSET_LINUX_WEAPONS);
				}
			}
		}
	}
}

@Ham_Item_PostFrame_Pre(const weapon_ent) {
	if(!pev_valid(weapon_ent)) {
		return;
	}

	new iId = get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
	
	if(!is_user_alive(iId)) {
		return;
	}

	new iWithCorrectWeapon = 0;

	if(g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][0] || g_CurrentWeapon[iId] == __CLASSES_WEAPONS[g_ClassId[iId]][1]) {
		iWithCorrectWeapon = 1;
	}

	if(g_Hab[iId][HAB_BULLETS] || iWithCorrectWeapon) {
		if(g_Hab[iId][HAB_BULLETS] || __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribClip]) {
			new iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			new iExtraClip = 0;
			new iMaxClip;
			new iReload;
			new Float:fNextAttack;
			new iAmmoType;
			new iBPAmmo;
			new iClip;
			new iButton;

			if(iWithCorrectWeapon) {
				iExtraClip = __CLASSES_ATTRIB[g_ClassId[iId]][g_ClassLevel[iId][g_ClassId[iId]]][classAttribClip];
			}

			iMaxClip = __DEFAULT_MAXCLIP[iWeaponId];
			iMaxClip = (iMaxClip + ((iMaxClip * g_HabCacheClip[iId]) / 100) + iExtraClip);
			iReload = get_pdata_int(weapon_ent, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS);
			fNextAttack = get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX);
			iAmmoType = (OFFSET_AMMO_PLAYER_SLOT0 + get_pdata_int(weapon_ent, OFFSET_PRIMARY_AMMO_TYPE, OFFSET_LINUX_WEAPONS));
			iBPAmmo = get_pdata_int(iId, iAmmoType, OFFSET_LINUX);
			iClip = get_pdata_int(weapon_ent, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
			iButton = entity_get_int(iId, EV_INT_button);

			if(iReload && fNextAttack <= 0.0) {
				new i = min((iMaxClip - iClip), iBPAmmo);
				
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
						sendWeaponAnimation(iId, ((iWeaponId == CSW_USP) ? 8 : 7));
					} else {
						sendWeaponAnimation(iId, 0);
					}
				} else if(iClip == __DEFAULT_MAXCLIP[iWeaponId]) {
					if(iBPAmmo) {
						set_pdata_float(iId, OFFSET_NEXT_ATTACK, __DEFAULT_DELAY[iWeaponId], OFFSET_LINUX);
						
						if(((1<<iWeaponId) & WEAPONS_SILENT_BIT_SUM) && get_pdata_int(weapon_ent, OFFSET_SILENT, OFFSET_LINUX_WEAPONS)) {
							sendWeaponAnimation(iId, ((iWeaponId == CSW_USP) ? 5 : 4));
						} else {
							sendWeaponAnimation(iId, __DEFAULT_ANIMS[iWeaponId]);
						}
						
						set_pdata_int(weapon_ent, OFFSET_IN_RELOAD, 1, OFFSET_LINUX_WEAPONS);
						set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, (__DEFAULT_DELAY[iWeaponId] + 0.5), OFFSET_LINUX_WEAPONS);
					}
				}
			}
		}
	}
}

@Ham_MonsterKilled_Pre(const monster, const killer, const should_gib) {
	if(!is_user_alive(killer)) {
		return HAM_IGNORED;
	}

	if(!isMonster(monster)) {
		return HAM_IGNORED;
	}

	set_hudmessage(0, 255, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
	ShowSyncHudMsg(killer, g_HudSync_Damage, "¡MATADO!");

	removeMonster(monster, killer);
	return HAM_SUPERCEDE;
}

@Ham_MonsterTakeDamage_Pre(const monster, const inflictor, const attacker, Float:damage, const bits_damage_type) {
	if(!is_valid_ent(monster)) {
		return HAM_IGNORED;
	}

	if(!is_user_alive(attacker)) {
		return HAM_IGNORED;
	}

	if(!isMonster(monster)) {
		return HAM_IGNORED;
	}

	damage += ((g_HabCache[attacker][HAB_F_DAMAGE] * damage) / 100.0);

	if(g_CurrentWeapon[attacker] == __CLASSES_WEAPONS[g_ClassId[attacker]][0] || g_CurrentWeapon[attacker] == __CLASSES_WEAPONS[g_ClassId[attacker]][1]) {
		if(__CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttribDamage]) {
			damage += ((__CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttribDamage] * damage) / 100.0); 
		}
	}

	if(g_CurrentWeapon[attacker] == WEAPON_SG550 || g_CurrentWeapon[attacker] == WEAPON_G3SG1) {
		if(damage > 105.0) {
			damage = random_float(80.0, 105.0);
		}
	}

	static iDamage;
	static Float:fShield;

	iDamage = floatround(damage);
	fShield = entity_get_float(monster, MONSTER_SHIELD);
	
	if(fShield == 1.0 && (g_ClassId[attacker] != CLASS_SOPORTE || (g_ClassId[attacker] == CLASS_SOPORTE && g_CurrentWeapon[attacker] != WEAPON_XM1014))) {
		iDamage /= 2;
	} else if(fShield == 2.0) {
		iDamage *= 2;
	} else if(fShield == 3.0) {
		iDamage /= 3;
	}
	
	if(g_CriticChance[attacker]) {
		static iRandom;
		iRandom = random_num(1, 100);

		if(iRandom <= (g_CriticChance[attacker] + __CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttribExtraCritical])) {
			fShield = 5.0;
			iDamage *= 2;
		}
	}
	
	g_AfkDamage[attacker] = iDamage;
	g_DamageDone[attacker] = iDamage;

	if(!isBoomerMonster(monster)) {
		while(g_DamageDone[attacker] >= g_DamageNeedToGold) {
			++g_Gold[attacker];
			++g_GoldG[attacker];
			++g_GoldMap[attacker];

			g_DamageDone[attacker] -= g_DamageNeedToGold;
		}

		checkAttackerLevelUp(attacker, iDamage);
	} else {
		if(g_BoomerHealth) {
			if(g_ClassId[attacker] == CLASS_FRANCOTIRADOR && g_ClassLevel[attacker][CLASS_FRANCOTIRADOR] == 6 && g_CurrentWeapon[attacker] == WEAPON_AWP && fShield != 5.0) {
				fShield = 5.0;
				iDamage *= 2;
			}

			g_BoomerHealth -= iDamage;
		}
	}

	if((bits_damage_type & DMG_BULLET)) {
		if(fShield != 5.0) {
			set_hudmessage(255, 255, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
			ShowSyncHudMsg(attacker, g_HudSync_Damage, "%d", iDamage);
		} else {
			set_hudmessage(255, 0, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
			ShowSyncHudMsg(attacker, g_HudSync_Damage, "%d  ¡CRÍTICO!", iDamage);

			if(isBoomerMonster(monster)) {
				++g_Gold[attacker];
				++g_GoldG[attacker];
				++g_GoldMap[attacker];
			}
		}
	}
	
	SetHamParamFloat(4, float(iDamage));
	
	rh_emit_sound2(monster, 0, CHAN_BODY, __SOUND_ZOMBIE_PAIN[random_num(0, charsmax(__SOUND_ZOMBIE_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	return HAM_IGNORED;
}

@Ham_MonsterTraceAttack_Pre(const monster, const attacker, const Float:damage, const Float:direction[3], const trace_handle, const bits_damage_type) {
	if(!is_valid_ent(monster)) {
		return HAM_IGNORED;
	}

	if(!is_user_alive(attacker)) {
		return HAM_IGNORED;
	}

	if(!isMonster(monster) && !isBoss(monster)) {
		return HAM_IGNORED;
	}

	new Float:vecEndPos[3];
	get_tr2(trace_handle, TR_vecEndPos, vecEndPos);

	effectBlood(vecEndPos);
	
	if(get_tr2(trace_handle, TR_iHitgroup) == HIT_SHIELD) {
		set_tr2(trace_handle, TR_iHitgroup, HIT_GENERIC);
	}

	return HAM_IGNORED;
}

@Ham_KmidTouchFix_Post(const monster, const ent) {
	if(!isMonster(monster)) {
		return FMRES_IGNORED;
	}
	
	if(!is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}

	if(isEggMonster(monster)) {
		return FMRES_IGNORED;
	}

	new sClassName[18];	
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(sClassName[0] == 'f' && sClassName[5] == 'w') {
		new iTrack = entity_get_int(monster, MONSTER_TRACK);
		new iTarget;
		new Float:vecMonsterOrigin[3];
		new Float:vecOrigin[3];
		new Float:flVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sClassName, charsmax(sClassName), "track%d", (iTrack + 1));
		iTarget = find_ent_by_tname(-1, sClassName);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, "end");
		}
		
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		
		if(iTrack == 5) {
			vecMonsterOrigin[2] += 10.0;
			entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		}
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, flVelocity);

		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		damageTower(monster, ent);
	} else {
		touchSomething(sClassName, monster, ent);
	}

	return FMRES_IGNORED;
}

@Ham_OrangeTouchFix_Post(const monster, const ent) {
	if(!isMonster(monster)) {
		return FMRES_IGNORED;
	}
	
	if(!is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}

	if(isEggMonster(monster)) {
		return FMRES_IGNORED;
	}

	new sClassName[18];	
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(sClassName[0] == 'f' && sClassName[5] == 'w') {
		new iTrack = entity_get_int(monster, MONSTER_TRACK);
		new iTarget;
		new Float:vecMonsterOrigin[3];
		new Float:vecOrigin[3];
		new Float:flVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sClassName, charsmax(sClassName), "track%d", (iTrack + 1));
		iTarget = find_ent_by_tname(-1, sClassName);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, "end");
		}
		
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		
		switch(iTrack) {
			case 1: {
				vecMonsterOrigin[1] -= 50.0;
				vecMonsterOrigin[2] += 10.0;

				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			} case 2: {
				vecMonsterOrigin[2] -= 5.0;

				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			} case 3: {
				vecMonsterOrigin[1] += 65.0;
				vecMonsterOrigin[2] += 25.0;

				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			} case 4: {
				vecMonsterOrigin[1] += 90.0;
				vecMonsterOrigin[2] -= 17.0;

				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			}
		}
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, flVelocity);
		
		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		damageTower(monster, ent);
	} else {
		touchSomething(sClassName, monster, ent);
	}

	return FMRES_IGNORED;
}

@Ham_DustDeltaTouchFix_Post(const monster, const ent) {
	if(!isMonster(monster)) {
		return FMRES_IGNORED;
	}
	
	if(!is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}

	if(isEggMonster(monster)) {
		return FMRES_IGNORED;
	}

	new sClassName[18];	
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(sClassName[0] == 'f' && sClassName[5] == 'w') {
		new iTrack = entity_get_int(monster, MONSTER_TRACK);
		new iTarget;
		new Float:vecMonsterOrigin[3];
		new Float:vecOrigin[3];
		new Float:flVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sClassName, charsmax(sClassName), "track%d", (iTrack + 1));
		iTarget = find_ent_by_tname(-1, sClassName);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, "end");
		}
		
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, flVelocity);
		
		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		damageTower(monster, ent);
	} else {
		touchSomething(sClassName, monster, ent);
	}

	return FMRES_IGNORED;
}

@Ham_UltimateTouchFix_Post(const monster, const ent) {
	if(!isMonster(monster)) {
		return FMRES_IGNORED;
	}
	
	if(!is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}

	if(isEggMonster(monster)) {
		return FMRES_IGNORED;
	}

	new sClassName[18];	
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(sClassName[0] == 'f' && sClassName[5] == 'w') {
		new iTrack = entity_get_int(monster, MONSTER_TRACK);
		new iTarget;
		new Float:vecMonsterOrigin[3];
		new Float:vecOrigin[3];
		new Float:flVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sClassName, charsmax(sClassName), "track%d", (iTrack + 1));
		iTarget = find_ent_by_tname(-1, sClassName);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, "end");
		}
		
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, flVelocity);
		
		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		damageTower(monster, ent);
	} else {
		touchSomething(sClassName, monster, ent);
	}

	return FMRES_IGNORED;
}

@Ham_TouchMonster_Post(const monster, const ent) {
	if(!isMonster(monster)) {
		return FMRES_IGNORED;
	}
	
	if(!is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}

	if(isEggMonster(monster)) {
		return FMRES_IGNORED;
	}

	new sClassName[18];	
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(sClassName[0] == 'f' && sClassName[5] == 'w') {
		new iTrack = entity_get_int(monster, MONSTER_TRACK);
		new iTarget;
		new Float:vecMonsterOrigin[3];
		new Float:vecOrigin[3];
		new Float:flVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sClassName, charsmax(sClassName), "track%d", (iTrack + 1));
		iTarget = find_ent_by_tname(-1, sClassName);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, ((iTrack < 100) ? "end" : "end1"));

			if(!is_valid_ent(iTarget)) {
				iTarget = find_ent_by_tname(-1, "end");
			}
		}
		
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, flVelocity);
		
		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		damageTower(monster, ent);
	} else {
		touchSomething(sClassName, monster, ent);
	}
	
	return FMRES_IGNORED;
}

@Ham_MiniBossKilled_Pre(const miniboss, const killer, const should_gib) {
	if(!is_valid_ent(miniboss)) {
		return HAM_IGNORED;
	}
	
	if(!is_user_alive(killer)) {
		return HAM_IGNORED;
	}
	
	if(!entity_get_int(miniboss, MONSTER_MAXHEALTH)) {
		return HAM_IGNORED;
	}

	new Float:flGameTime = get_gametime();
	
	entity_set_int(miniboss, EV_INT_sequence, 2);
	entity_set_float(miniboss, EV_FL_animtime, flGameTime);
	entity_set_float(miniboss, EV_FL_framerate, 1.0);
	
	entity_set_int(miniboss, EV_INT_gamestate, 1);
	
	entity_set_float(miniboss, EV_FL_health, 9999.0);
	entity_set_int(miniboss, MONSTER_MAXHEALTH, 0);
	
	entity_set_size(miniboss, Float:{-16.0, -16.0, -18.0}, Float:{16.0, 16.0, 32.0});
	
	entity_set_vector(miniboss, EV_VEC_mins, Float:{-16.0, -16.0, -18.0});
	entity_set_vector(miniboss, EV_VEC_maxs, Float:{16.0, 16.0, 32.0});
	
	drop_to_floor(miniboss);
	
	entity_set_vector(miniboss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
	
	entity_set_int(miniboss, EV_INT_solid, SOLID_NOT);
	
	entity_set_float(miniboss, EV_FL_nextthink, (flGameTime + 9999.0));
	
	if(g_BossId != BOSS_GUARDIANES) {
		set_task(3.0, "task__EffectSpecialBoss", miniboss);
	} else {
		for(new i = 0; i < 3; ++i) {
			if(entity_get_int(g_MiniBoss_Ids[i], MONSTER_MAXHEALTH)) {
				return HAM_SUPERCEDE;
			}
		}
		
		set_task(3.0, "task__EffectSpecialBoss", miniboss);
	}
	
	return HAM_SUPERCEDE;
}

@Ham_MiniBossTakeDamage_Pre(const miniboss, const inflictor, const attacker, const Float:damage, const bits_damage_type) {
	if(!is_valid_ent(miniboss)) {
		return HAM_IGNORED;
	}

	if(!is_user_alive(attacker)) {
		return HAM_IGNORED;
	}

	new Float:vecOrigin[3];
	entity_get_vector(miniboss, EV_VEC_origin, vecOrigin);
	
	vecOrigin[0] += random_float(-2.0, 3.0);
	vecOrigin[1] += random_float(-2.0, 3.0);
	vecOrigin[2] += random_float(4.0, 10.0);

	if(!entity_get_int(miniboss, MONSTER_MAXHEALTH)) {
		set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
		ShowSyncHudMsg(attacker, g_HudSync_Damage, "¡INVULNERABLE!");
		
		SetHamParamFloat(4, 0.0);
		
		// effectBlood(vecOrigin);
		return HAM_IGNORED;
	}
	
	checkAttackerLevelUp(attacker, floatround(damage));
	
	if((bits_damage_type & DMG_BULLET)) {
		set_hudmessage(255, 255, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
		ShowSyncHudMsg(attacker, g_HudSync_Damage, "%0.0f", damage);
	}
	
	rh_emit_sound2(miniboss, 0, CHAN_BODY, __SOUND_ZOMBIE_PAIN[random_num(0, charsmax(__SOUND_ZOMBIE_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);

	effectBlood(vecOrigin);
	return HAM_IGNORED;
}

@Ham_BossKilled_Pre(const boss, const killer, const should_gib) {
	if(!is_valid_ent(boss)) {
		return HAM_IGNORED;
	}
	
	if(!is_user_alive(killer)) {
		return HAM_IGNORED;
	}
	
	if(!isBoss(boss)) {
		return HAM_IGNORED;
	}
	
	entity_set_int(boss, MONSTER_MAXHEALTH, 0); // Lo pongo acá arriba porque se utiliza en el medio
	
	new iDeadSeq;
	
	if(g_BossId != BOSS_GUARDIANES) {
		switch(g_BossId) {
			case BOSS_GORILA: {
				iDeadSeq = random_num(49, 55);
			} case BOSS_FIRE: {
				iDeadSeq = 16;
			} case BOSS_FALLEN_TITAN: {
				iDeadSeq = 19;
			}
		}
	} else {
		new iOk = 1;
		
		if(g_Boss != boss) {
			iDeadSeq = random_num(49, 55);
			
			new i;
			for(i = 0; i < 2; ++i) {
				if(g_BossGuardians_Ids[i] == boss) {
					g_BossPower[i] = 0;

					if(is_valid_ent(g_BossGuardians_HealthBar[i])) {
						remove_entity(g_BossGuardians_HealthBar[i]);
						
						--g_BossGuardians;
					}
					
					break;
				}
			}
			
			for(i = 0; i < 2; ++i) {
				if(is_valid_ent(g_BossGuardians_Ids[i]) && entity_get_int(g_BossGuardians_Ids[i], MONSTER_MAXHEALTH)) {
					iOk = 0;
					break;
				}
			}
			
			if(iOk) {
				if(g_FwdAddToFullPack_Status) {
					g_FwdAddToFullPack_Status = 0;
					unregister_forward(FM_AddToFullPack, g_FwdAddToFullPack, 1);
					
					g_Boss_HealthBar = create_entity("env_sprite");
					
					if(g_Boss_HealthBar) {
						entity_set_int(g_Boss_HealthBar, EV_INT_spawnflags, SF_SPRITE_STARTON);
						entity_set_int(g_Boss_HealthBar, EV_INT_solid, SOLID_NOT);
						
						entity_set_model(g_Boss_HealthBar, __SPRITE_BOSS_HEALTH);
						
						entity_set_float(g_Boss_HealthBar, EV_FL_scale, 0.5);
						
						entity_set_float(g_Boss_HealthBar, EV_FL_frame, 100.0);
						
						// g_BossRespawn[2] += 200.0;
						entity_set_origin(g_Boss_HealthBar, g_BossRespawn);
						
						g_FwdAddToFullPack_Status = 1;
						g_FwdAddToFullPack = register_forward(FM_AddToFullPack, "@FM_AddToFullPackBoss_Post", 1);
					}
				}

				entity_set_float(g_Boss, EV_FL_takedamage, DAMAGE_YES);
				
				entity_set_int(g_Boss, EV_INT_solid, SOLID_BBOX);
				
				entity_set_float(g_Boss, EV_FL_nextthink, (get_gametime() + 0.01));
			}
		} else {
			iDeadSeq = random_num(138, 144);
		}
	}

	addKill(killer, 1);

	entity_set_int(boss, MONSTER_TYPE, 0);
	entity_set_int(boss, MONSTER_TRACK, 0);
	entity_set_float(boss, MONSTER_SPEED, 0.0);
	
	entity_set_edict(boss, MONSTER_HEALTHBAR, 0);
	
	entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
	entity_set_int(boss, EV_INT_solid, SOLID_NOT);
	
	entity_set_int(boss, EV_INT_sequence, iDeadSeq);
	entity_set_float(boss, EV_FL_animtime, get_gametime());
	entity_set_float(boss, EV_FL_framerate, 1.0);
	// entity_set_float(boss, EV_FL_frame, 3.0);
	
	rh_emit_sound2(boss, 0, CHAN_BODY, __SOUND_ZOMBIE_DIE[random_num(0, charsmax(__SOUND_ZOMBIE_DIE))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	set_task(16.0, "task__DeleteMonsterEntBoss", boss);
	
	if(g_Boss == boss) { // Para asegurarnos de que no sean los Guardianes
		if(g_FwdAddToFullPack_Status) {
			g_FwdAddToFullPack_Status = 0;
			unregister_forward(FM_AddToFullPack, g_FwdAddToFullPack, 1);
		}
		
		if(is_valid_ent(g_Boss_HealthBar)) {
			remove_entity(g_Boss_HealthBar);
		}

		checkUsersSomeThings();
		
		g_EndGame = 1;
		g_WaveInProgress = 0;
		g_BossId = 0;
		
		set_task(2.0, "task__VoteMap");
	}
	
	return HAM_SUPERCEDE;
}

@Ham_BossTakeDamage_Pre(const boss, const inflictor, const attacker, Float:damage, const bits_damage_type) {
	if(!is_valid_ent(boss)) {
		return HAM_IGNORED;
	}
	
	if(!is_user_alive(attacker)) {
		return HAM_IGNORED;
	}

	if(isMonster(boss)) {
		return HAM_IGNORED;
	}

	damage += ((g_HabCache[attacker][HAB_F_DAMAGE] * damage) / 100.0);
	
	if(g_CurrentWeapon[attacker] == __CLASSES_WEAPONS[g_ClassId[attacker]][0] || g_CurrentWeapon[attacker] == __CLASSES_WEAPONS[g_ClassId[attacker]][1]) {
		if(__CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttribDamage]) {
			damage += ((__CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttribDamage] * damage) / 100.0); 
		}
	}

	if(g_CurrentWeapon[attacker] == WEAPON_SG550 || g_CurrentWeapon[attacker] == WEAPON_G3SG1) {
		if(damage > 105.0) {
			damage = random_float(80.0, 105.0);
		}
	}

	new Float:flHealth = entity_get_float(boss, EV_FL_health);
	new Float:flGameTime = get_gametime();

	switch(g_BossId) {
		case BOSS_GORILA: {
			if(flHealth < g_BossGorila_AttractPowerHP[0]) {
				g_BossGorila_AttractPowerHP[0] = -10000;

				entity_set_float(boss, EV_FL_nextthink, (flGameTime + 9999.9));

				g_BossPower[0] = BOSS_POWER_ATTRACT;
				g_BossLastPower[0] = g_BossPower[0];
				
				entity_set_int(boss, EV_INT_sequence, 0);
				entity_set_float(boss, EV_FL_animtime, flGameTime);
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				set_rendering(boss, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
				
				set_lights("a");
				
				new Float:flEndTime = 3.7;
				new Float:flRepeat = ((flEndTime / 0.1) - 1.0);
				
				set_task(0.1, "task__BossPowerCloser", boss, _, _, "a", floatround(flRepeat));
				set_task(flEndTime, "task__EndBossPowerCloser", boss);

				entity_set_int(boss, MONSTER_TARGET, 0);
			}
		} case BOSS_FIRE: {
			if(!g_BossPower[0] && !g_BossFire_Ultimate && flHealth <= g_BossFire_UltimateHealth) {
				g_BossFire_Ultimate = 1;
				g_BossPower[0] = BOSS_POWER_FIREBALL_RAIN;
				g_BossTimePower[0] = (flGameTime + 16.0);
				
				entity_set_int(boss, EV_INT_sequence, 12);
				entity_set_float(boss, EV_FL_animtime, flGameTime);
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(boss, EV_FL_nextthink, (flGameTime + 10.4));
				
				set_task(4.4, "task__BossPowerUltimate", boss);
			}
		} case BOSS_FALLEN_TITAN: {
			if(!g_BossPower[0]) {
				if(flHealth <= g_BossFT_UltimateHealth) {
					g_BossFT_UltimateHealth = -10000;
					
					g_BossPower[0] = BOSS_FT_SCREAM;
					g_BossTimePower[0] = (flGameTime + 8.0);
					
					entity_set_int(boss, EV_INT_sequence, 4);
					entity_set_float(boss, EV_FL_animtime, flGameTime);
					entity_set_float(boss, EV_FL_framerate, 1.0);
					
					entity_set_int(boss, EV_INT_gamestate, 1);
					
					entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
					entity_set_float(boss, EV_FL_nextthink, (flGameTime + 4.7));

					playSound(0, __SOUND_FALLEN_TITAN_SCREAM);
					
					set_task(0.66, "task__BossFallenTitanScreaming");
					set_task(4.69, "task__bossFallenTitanStartHyperCannon");
				} else if(!g_BossFT_HyperUltimate && flHealth <= 3500) {
					g_BossFT_HyperUltimate = 1;

					playSound(0, __SOUND_FALLEN_TITAN_SCREAM);

					task__BossFallenTitanInfiniteCannons();
				}
			}
		} case BOSS_GUARDIANES: {
			new iBossIndex = -1;

			if(boss == g_BossGuardians_Ids[0]) {
				iBossIndex = 0;
			} else if(boss == g_BossGuardians_Ids[1]) {
				iBossIndex = 1;
			}

			if(iBossIndex != -1) {
				if(flHealth < g_BossGorila_AttractPowerHP[iBossIndex]) {
					g_BossGorila_AttractPowerHP[iBossIndex] = -10000;

					entity_set_float(boss, EV_FL_nextthink, (flGameTime + 9999.9));

					g_BossPower[iBossIndex] = BOSS_POWER_ATTRACT;
					g_BossLastPower[iBossIndex] = g_BossPower[iBossIndex];
					
					entity_set_int(boss, EV_INT_sequence, 0);
					entity_set_float(boss, EV_FL_animtime, flGameTime);
					entity_set_float(boss, EV_FL_framerate, 1.0);
					
					entity_set_int(boss, EV_INT_gamestate, 1);
					
					entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
					
					set_rendering(boss, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
					
					set_lights("a");
					
					new Float:flEndTime = 3.7;
					new Float:flRepeat = ((flEndTime / 0.1) - 1.0);
					
					set_task(0.1, "task__BossPowerCloser", boss, _, _, "a", floatround(flRepeat));
					set_task(flEndTime, "task__EndBossPowerCloser", boss);

					entity_set_int(boss, MONSTER_TARGET, 0);
				}
			}
		}
	}
	
	if((bits_damage_type & DMG_BULLET)) {
		new iOk = 0;
		
		if(g_BossId != BOSS_GUARDIANES) {
			if(g_BossPower[0] == BOSS_POWER_EGGS) {
				iOk = 1;
			}
		} else {
			if(g_BossPower[0] == BOSS_POWER_EGGS || g_BossPower[1] == BOSS_POWER_EGGS) {
				iOk = 1;
			}
		}
		
		if(iOk) {
			set_hudmessage(255, 255, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
			ShowSyncHudMsg(attacker, g_HudSync_Damage, "¡INVULNERABLE!");
			
			SetHamParamFloat(4, 0.0);
			return HAM_IGNORED;
		}

		checkAttackerLevelUp(attacker, floatround(damage));
		
		set_hudmessage(255, 255, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
		ShowSyncHudMsg(attacker, g_HudSync_Damage, "%0.0f", damage);
	}
	
	rh_emit_sound2(boss, 0, CHAN_BODY, __SOUND_ZOMBIE_PAIN[random_num(0, charsmax(__SOUND_ZOMBIE_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	if(g_BossId != BOSS_GUARDIANES) {
		if(is_valid_ent(g_Boss_HealthBar)) {
			entity_set_float(g_Boss_HealthBar, EV_FL_frame, ((flHealth * 100.0) / float(entity_get_int(boss, MONSTER_MAXHEALTH))));
		}
	} else {
		if(g_Boss != boss) {
			new i;
			for(i = 0; i < 2; ++i) {
				if(g_BossGuardians_Ids[i] == boss) {
					if(is_valid_ent(g_BossGuardians_HealthBar[i])) {
						entity_set_float(g_BossGuardians_HealthBar[i], EV_FL_frame, ((flHealth * 100.0) / float(entity_get_int(boss, MONSTER_MAXHEALTH))));
					}
					
					break;
				}
			}
		} else {
			if(is_valid_ent(g_Boss_HealthBar)) {
				entity_set_float(g_Boss_HealthBar, EV_FL_frame, ((flHealth * 100.0) / float(entity_get_int(boss, MONSTER_MAXHEALTH))));
			}
		}
	}

	return HAM_IGNORED;
}

@clcmd__CurrentMap(const id) {
	clientPrintColor(id, _, "El mapa actual es !g%s!y.", g_CurrentMap);
	return PLUGIN_HANDLED;
}

@clcmd__PowerUp(const id) {
	if(!is_user_alive(id)) {
		clientPrintColor(id, _, "Debes estar vivo para utilizar este comando.");
		return PLUGIN_HANDLED;
	} else if(!g_WaveInProgress) {
		clientPrintColor(id, _, "No pudes usar poderes mientras está a la espera de una oleada");
		return PLUGIN_HANDLED;
	}
	
	switch(g_PowerActual[id]) {
		case POWER_RAYO: {
			if(g_Power[id][g_PowerActual[id]]) {
				--g_Power[id][g_PowerActual[id]];
				
				if(!g_Power[id][g_PowerActual[id]]) {
					g_PowerActual[id] = 0;
				}
				
				rh_emit_sound2(id, 0, CHAN_VOICE, __SOUND_THUNDER, 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				new iEnt = -1;
				new iMaxMonsters = random_num(6, 7);
				new iMonsters = 0;
				new iMonsterType;
				new Float:vecOrigin[3];
				new iOrigin[3];
				new startOrigin[3];
				
				if(g_Upgrades[id][UPGRADE_THOR]) {
					iMaxMonsters += random_num(3, 4);
				}
				
				while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_MONSTER))) {
					if(iMonsters >= iMaxMonsters) {
						break;
					}
					
					iMonsterType = entity_get_int(iEnt, MONSTER_TYPE);
					
					if(iMonsterType != 0 && iMonsterType != MONSTER_TYPE_BOSS && iMonsterType != MONSTER_TYPE_BOOMER) {
						entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
						
						iOrigin[0] = floatround(vecOrigin[0]);
						iOrigin[1] = floatround(vecOrigin[1]);
						iOrigin[2] = floatround(vecOrigin[2]);
						
						iOrigin[2] -= 26;
						
						startOrigin[0] = (iOrigin[0] + 150);
						startOrigin[1] = (iOrigin[1] + 150);
						startOrigin[2] = (iOrigin[2] + 800);
						
						message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
						write_byte(TE_BEAMPOINTS);
						write_coord(startOrigin[0]);
						write_coord(startOrigin[1]);
						write_coord(startOrigin[2]);
						write_coord(iOrigin[0]);
						write_coord(iOrigin[1]);
						write_coord(iOrigin[2]);
						write_short(g_Sprite_Thunder);
						write_byte(1);
						write_byte(10);
						write_byte(2);
						write_byte(20);
						write_byte(30);
						write_byte(200);
						write_byte(200);
						write_byte(200);
						write_byte(255);
						write_byte(200);
						message_end();
						
						get_user_origin(id, startOrigin);
						
						message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
						write_byte(TE_BEAMPOINTS);
						write_coord(startOrigin[0]);
						write_coord(startOrigin[1]);
						write_coord(startOrigin[2]);
						write_coord(iOrigin[0]);
						write_coord(iOrigin[1]);
						write_coord(iOrigin[2]);
						write_short(g_Sprite_Thunder);
						write_byte(1);
						write_byte(10);
						write_byte(2);
						write_byte(20);
						write_byte(30);
						write_byte(200);
						write_byte(200);
						write_byte(200);
						write_byte(255);
						write_byte(200);
						message_end();
						
						message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin);
						write_byte(TE_DLIGHT);
						write_coord(iOrigin[0]);
						write_coord(iOrigin[1]);
						write_coord(iOrigin[2]);
						write_byte(20);
						write_byte(255);
						write_byte(255);
						write_byte(255);
						write_byte(10);
						write_byte(10);
						message_end();
						
						removeMonster(iEnt, id, 1);
						
						iMonsters++;
					}
				}
				
				if(iMonsters) {
					set_hudmessage(0, 255, 0, -1.0, 0.57, 0, 6.0, 1.0, 0.0, 0.4, 2);
					ShowSyncHudMsg(id, g_HudSync_Damage, "¡MATADO! [x%d]", iMonsters);
				} else {
					get_user_origin(id, iOrigin, 3);
					get_user_origin(id, startOrigin);
					
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_BEAMPOINTS);
					write_coord(startOrigin[0]);
					write_coord(startOrigin[1]);
					write_coord(startOrigin[2]);
					write_coord(iOrigin[0]);
					write_coord(iOrigin[1]);
					write_coord(iOrigin[2]);
					write_short(g_Sprite_Thunder);
					write_byte(1);
					write_byte(10);
					write_byte(2);
					write_byte(20);
					write_byte(30);
					write_byte(200);
					write_byte(200);
					write_byte(200);
					write_byte(255);
					write_byte(200);
					message_end();
					
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin);
					write_byte(TE_DLIGHT);
					write_coord(iOrigin[0]);
					write_coord(iOrigin[1]);
					write_coord(iOrigin[2]);
					write_byte(20);
					write_byte(255);
					write_byte(255);
					write_byte(255);
					write_byte(10);
					write_byte(10);
					message_end();
				}
			}
		} case POWER_BALAS_INFINITAS: {
			if(g_Power[id][g_PowerActual[id]] && g_Wave > 0 && g_Wave < (MAX_WAVES + 1)) {
				--g_Power[id][g_PowerActual[id]];
				
				if(!g_Power[id][g_PowerActual[id]]) {
					g_PowerActual[id] = 0;
				}
				
				g_UnlimitedClip[id] = 1;
				g_UnlimitedClip_WavesLeft[id] += __DIFFS_VALUES_UC_WAVES_LEFT[g_Diff];
				
				clientPrintColor(id, _, "Tus balas infinitas fueron activadas, oleadas restantes: !g%d!y.", g_UnlimitedClip_WavesLeft[id]);
			} else {
				clientPrintColor(id, _, "Tus balas infinitas no pueden activarse en este momento.");
			}
		} case POWER_PRECISION_PERFECTA: {
			if(g_Power[id][g_PowerActual[id]] && g_Wave > 0 && g_Wave < (MAX_WAVES + 1)) {
				--g_Power[id][g_PowerActual[id]];
				
				if(!g_Power[id][g_PowerActual[id]]) {
					g_PowerActual[id] = 0;
				}

				g_PrecisionPerfecta[id] = 1;
				g_PrecisionPerfecta_WavesLeft[id] += __DIFFS_VALUES_PP_WAVES_LEFT[g_Diff];

				clientPrintColor(id, _, "Tu precisión perfecta fueron activadas, oleadas restantes: !g%d!y.", g_PrecisionPerfecta_WavesLeft[id]);
			} else {
				clientPrintColor(id, _, "Tu precisión perfecta no pueden activarse en este momento.");
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__PowerLeft(const id) {
	if(!is_user_alive(id)) {
		clientPrintColor(id, _, "Debes estar vivo para utilizar este comando.");
		return PLUGIN_HANDLED;
	}
	
	new iPower = g_PowerActual[id];
	new i = 0;
	new j;
	
	while(i == 0) {
		--iPower;
		
		if(iPower < 0) {
			j = 1;

			while(j >= 0) {
				if(g_Power[id][(structIdPowers - j)]) {
					g_PowerActual[id] = (structIdPowers - j);
					break;
				} else {
					++j;
					g_PowerActual[id] = 0;

					if((structIdPowers - j) < 0) {
						break;
					}
				}
			}
			
			break;
		} else if(g_Power[id][iPower] || !iPower) {
			g_PowerActual[id] = iPower;
			break;
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__PowerRight(const id) {
	if(!is_user_alive(id)) {
		clientPrintColor(id, _, "Debes estar vivo para utilizar este comando.");
		return PLUGIN_HANDLED;
	}
	
	new iPower = g_PowerActual[id];
	new i = 0;
	
	while(i == 0) {
		++iPower;
		
		if(iPower >= structIdPowers) {
			g_PowerActual[id] = 0;
			break;
		} else if(g_Power[id][iPower]) {
			g_PowerActual[id] = iPower;
			break;
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__Say(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
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
		if(is_user_connected(i) && !dg_get_user_mute(i, id)) {
			if(dg_get_user_acc_status(id) == STATUS_PLAYING) {
				client_print_color(i, id, "%s%s^3%n ^4(LV: %d)^1 :%s %s", ((is_user_alive(id)) ? "" : "^1(MUERTO) "), getUserTypeMod(id), id, g_Level[id], ((iGreen) ? "^4" : "^1"), sMessage);
			} else {
				client_print_color(i, id, "^1(%s)^3 %n^1 :%s %s", getAccountStatus(id), id, ((iGreen) ? "^4" : "^1"), sMessage);
			}
		}
	}

	return PLUGIN_HANDLED;
}

@clcmd__BlockCommand(const id) {
	return PLUGIN_HANDLED;
}

@clcmd__CreateEva(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}

	new iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		new vecOriginId[3];
		new Float:vecOrigin[3];
		new Float:vecTargetOrigin[3];
		new Float:vecAngles[3];

		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_EVA);
		entity_set_model(iEnt, __MODEL_EVA);
		
		dllfunc(DLLFunc_Spawn, iEnt);
		
		get_user_origin(id, vecOriginId, 3);
		IVecFVec(vecOriginId, vecOrigin);

		vecOrigin[2] += 5.0;
		
		entity_set_origin(iEnt, vecOrigin);

		entity_set_size(iEnt, Float:{-16.0, -16.0, -16.0}, Float:{16.0, 16.0, 9999.0});
		
		entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
		
		entity_set_int(iEnt, EV_INT_sequence, 0);
		entity_set_float(iEnt, EV_FL_animtime, get_gametime());
		entity_set_float(iEnt, EV_FL_gravity, 1.0);
		
		drop_to_floor(iEnt);

		entity_set_size(iEnt, Float:{-16.0, -16.0, -16.0}, Float:{16.0, 16.0, 9999.0});
		
		entity_get_vector(id, EV_VEC_origin, vecTargetOrigin);

		entitySetAim(iEnt, vecOrigin, vecTargetOrigin);
		
		entity_get_vector(iEnt, EV_VEC_angles, vecAngles);
		vecAngles[0] = 0.0;
		entity_set_vector(iEnt, EV_VEC_angles, vecAngles);
		
		new sFile[96];
		new sText[128];

		formatex(sFile, charsmax(sFile), "addons/amxmodx/configs/evas/%s/spawns.cfg", g_CurrentMap);
		formatex(sText, charsmax(sText), "%f %f %f %f %f %f", vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2]);
		
		new iFile = fopen(sFile, "r+");
		
		if(iFile) {
			write_file(sFile, sText, -1);
			fclose(iFile);
			
			clientPrintColor(id, _, "El archivo !g%s!y ha sido guardado exitosamente.", sFile);
		}
	}

	return PLUGIN_HANDLED;
}

@clcmd__ViewTower(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	new iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		new Float:vecOrigin[3];
		new Float:vecAngles[3];
		
		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_VIEW_TOWER);
		entity_set_model(iEnt, "models/w_usp.mdl");

		entity_get_vector(id, EV_VEC_origin, vecOrigin);
		entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
		
		entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
		
		entity_set_int(iEnt, EV_INT_sequence, 0);
		entity_set_float(iEnt, EV_FL_animtime, 2.0);
		
		entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
		entity_set_float(iEnt, EV_FL_renderamt, 0.0);
		
		entity_set_size(iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
		
		entity_get_vector(id, EV_VEC_angles, vecAngles);
		entity_set_vector(iEnt, EV_VEC_v_angle, vecAngles);
		entity_set_vector(iEnt, EV_VEC_angles, vecAngles);
		
		new sViewTowerFile[40];
		new iFile;

		formatex(sViewTowerFile, charsmax(sViewTowerFile), "addons/amxmodx/configs/view_tower.ini");
		iFile = fopen(sViewTowerFile, "r+");
		
		if(iFile) {
			new sData[32];
			new iPos;
			new iFound;

			while(!feof(iFile)) {
				fgets(iFile, sData, charsmax(sData));
				parse(sData, sData, charsmax(sData));
				
				iPos++;
				
				if(equal(sData, g_CurrentMap)) {
					iFound = 1;
					
					new sText[128];
					formatex(sText, charsmax(sText), "%s %f %f %f %f %f %f", g_CurrentMap, vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2]);
					
					write_file(sViewTowerFile, sText, iPos - 1);
					break;
				}
			}
			
			if(!iFound) {
				fprintf(iFile, "%s %f %f %f %f %f %f^n", g_CurrentMap, vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2]);
			}
			
			fclose(iFile);
			
			clientPrintColor(id, _, "El archivo !g%s!y ha sido guardado exitosamente.", sViewTowerFile);
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__WalkGuard(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	g_EditorId = id;
	
	findAllZones();
	showAllZones();
	
	showMenu__WalkGuard(id);
	return PLUGIN_HANDLED;
}

@clcmd__Egg(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	createSpecialMonster(0, 0);
	return PLUGIN_HANDLED;
}

@clcmd__MiniBoss(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}

	g_Wave = 1337;

	clientPrintColor(0, id, "!t%n!y ha determinado para combatir contra el mini-jefe, luego contra un jefe al azar.", id);
	return PLUGIN_HANDLED;
}

@clcmd__Boss(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}

	new sArg1[2];
	new iBossId;

	read_argv(1, sArg1, charsmax(sArg1));
	iBossId = str_to_num(sArg1);

	if(iBossId) {
		g_Wave = 1338;
		g_BossId = (iBossId - 1);

		clientPrintColor(0, id, "!t%n!y ha determinado para combatir contra el jefe !g%s!y.", id, __BOSSES_NAME[g_BossId][bossNameFF]);
	}

	return PLUGIN_HANDLED;
}

@clcmd__Cheats(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}

	g_Wave = (MAX_WAVES - 1);
	g_Tramposo = 1;

	clientPrintColor(0, id, "!t%n!y ha activado el modo !tTRAMPOSO!y. Sobrevive la oleada y el jefe final para ganar el logro.", id);
	return PLUGIN_HANDLED;
}

@clcmd__Gold(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[8];
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		consolePrint(id, "Uso: td_gold <nombre> <factor (+ , -)> <cantidad>.");
		return PLUGIN_HANDLED;
	}
	
	new iGold;
	iGold = str_to_num(sArg2);
	
	switch(sArg2[0]) {
		case '+', '-': {
			g_Gold[iTarget] += iGold;
		} default: {
			g_Gold[iTarget] = iGold;
		}
	}

	return PLUGIN_HANDLED;
}

@clcmd__Level(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[8];	
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		consolePrint(id, "Uso: td_level <nombre> <factor (+ , -)> <cantidad>.");
		return PLUGIN_HANDLED;
	}
	
	new iLevel;
	iLevel = str_to_num(sArg2);
	
	if(iLevel < 0 || iLevel > 100) {
		consolePrint(id, "El rango de niveles permitido es de 0 a 100.");
		return PLUGIN_HANDLED;
	}
	
	switch(sArg2[0]) {
		case '+', '-': {
			g_Level[iTarget] += iLevel;
		} default: {
			g_Level[iTarget] = iLevel;
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__Points(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[5];	
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		consolePrint(id, "Uso: td_points <nombre> <factor (+ , -)> <cantidad>.");
		return PLUGIN_HANDLED;
	}
	
	new iPoints;
	iPoints = str_to_num(sArg2);
	
	if(iPoints < 0 || iPoints > 100) {
		consolePrint(id, "El rango de puntos permitido es de 0 a 100.");
		return PLUGIN_HANDLED;
	}
	
	switch(sArg2[0]) {
		case '+', '-': {
			g_Points[iTarget] += iPoints;
		} default: {
			g_Points[iTarget] = iPoints;
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__ClassLevel(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[4];
	new sArg3[6];
	
	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));
	
	if(read_argc() < 3) {
		consolePrint(id, "Uso: td_class_level <nombre> <classId> <factor (+ , -)> <cantidad>.");
		consolePrint(id, "classId:");
		consolePrint(id, "0 = SOLDADO");
		consolePrint(id, "1 = INGENIERO");
		consolePrint(id, "2 = SOPORTE");
		consolePrint(id, "3 = FRANCOTIRADOR");
		consolePrint(id, "4 = APOYO");
		consolePrint(id, "5 = PESADO");
		consolePrint(id, "6 = ASALTO");
		consolePrint(id, "7 = COMANDANTE");
		consolePrint(id, "8 = PISTOLERO");
		consolePrint(id, "9 = PUBERO");
		consolePrint(id, "10 = LEGIONARIO");
		consolePrint(id, "11 = BITERO");
		consolePrint(id, "12 = SCOUTER");
		
		return PLUGIN_HANDLED;
	}

	new iClassId;
	iClassId = str_to_num(sArg2);
	
	if(iClassId < 0 || iClassId >= structIdClasses) {
		consolePrint(id, "El rango de clases permitido es de 0 a %d.", (structIdClasses - 1));
		return PLUGIN_HANDLED;
	}
	
	new iLevel;
	iLevel = str_to_num(sArg3);
	
	if(iLevel < 0 || iLevel > 6) {
		consolePrint(id, "El rango de niveles permitido es de 0 a 6.");
		return PLUGIN_HANDLED;
	}
	
	switch(sArg3[0]) {
		case '+', '-': {
			g_ClassLevel[iTarget][iClassId] += iLevel;
		} default: {
			g_ClassLevel[iTarget][iClassId] = iLevel;
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__Os(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[MAX_NAME_LENGTH];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[5];	
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		consolePrint(id, "Uso: td_os <nombre> <factor (+ , -)> <cantidad>.");
		return PLUGIN_HANDLED;
	}
	
	new iOs;
	iOs = str_to_num(sArg2);

	switch(sArg2[0]) {
		case '+', '-': {
			g_Os[iTarget] += iOs;
		} default: {
			g_Os[iTarget] = iOs;
		}
	}
	
	return PLUGIN_HANDLED;
}

@clcmd__TowerHealth(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[16];
	new iTowerHealth;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTowerHealth = str_to_num(sArg1);

	g_TowerHealth = iTowerHealth;

	clientPrintColor(0, id, "!t%n!y modificó la vida de la torre y ahora tiene !g%d!y.", id, iTowerHealth);
	return PLUGIN_HANDLED;
}

@clcmd__Lights(const id) {
	if(!g_Atsul[id]) {
		return PLUGIN_HANDLED;
	}

	new sArg1[2];
	read_argv(1, sArg1, charsmax(sArg1));

	if(!isLetter(sArg1)) {
		return PLUGIN_HANDLED;
	}

	formatex(g_Lights, charsmax(g_Lights), "%c", sArg1);
	set_lights(g_Lights[0]);

	clientPrintColor(0, id, "!t%n!y cambió el grado de iluminación del mapa a !g%c!y", id, sArg1);
	return PLUGIN_HANDLED;
}

@clcmd__Diff(const id) {
	if(!is_user_alive(id)) {
		return PLUGIN_HANDLED;
	}

	clientPrintColor(id, _, "Dificultad actual: !g%s!y.", __DIFFS[g_Diff][diffNameMay]);
	return PLUGIN_HANDLED;
}

@clcmd__Dance(const id) {
	if(!is_user_alive(id)) {
		clientPrintColor(id, _, "Tienes que estar vivo para utilizar este comando.");
		return PLUGIN_HANDLED;
	}

	if(g_BossId == BOSS_FIRE && is_valid_ent(g_Boss)) {
		if(!g_Dance[id]) {
			g_Dance[id] = 1;

			new Float:flHealth = entity_get_float(g_Boss, EV_FL_health);
			new iMaxHealth = (entity_get_int(g_Boss, MONSTER_MAXHEALTH) - 3000);

			if(flHealth >= iMaxHealth) {
				++g_Dances;

				if(g_Dances == 5) {
					new i;
					for(i = 1; i <= MaxClients; ++i) {
						if(!is_user_alive(i)) {
							continue;
						}

						setAchievement(i, BOSS_FIRE_DANCE);
					}

					entity_set_float(g_Boss, EV_FL_nextthink, (get_gametime() + 5.0));

					entity_set_vector(g_Boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
					
					entity_set_int(g_Boss, EV_INT_sequence, 0);

					entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
					entity_set_float(g_Boss, EV_FL_framerate, 1.0);
					
					entity_set_int(g_Boss, EV_INT_gamestate, 1);

					set_task(0.833333, "task__RepeatAnimationStupidFix", .flags="a", .repeat=5);
					return PLUGIN_HANDLED;
				}

				clientPrint(0, print_center, "¡Faltan que %d jugador%s saquen a bailar al Jefe!", (5 - g_Dances), (((5 - g_Dances) != 1) ? "es" : ""));
			} else {
				clientPrintColor(id, _, "El Jefe no tiene la suficiente vida para sacarlo a bailar :(.");
			}
		} else {
			clientPrintColor(id, _, "Ya utilizaste este comando.");
		}
	}

	return PLUGIN_HANDLED;
}

showMenu__WalkGuard(const id) {
	SetGlobalTransTarget(id);

	new iZoneMode = -1;
	
	if(is_valid_ent(g_Zone[g_ZoneId])) {
		iZoneMode = entity_get_int(g_Zone[g_ZoneId], EV_INT_iuser1);
	}

	oldmenu_create("\yWALKGUARD^n\wZonas encontradas\r:\y %d", "@menu__WalkGuard", g_MaxZones);

	if(iZoneMode != -1) {
		oldmenu_additem(-1, -1, "\w(Actual\r:\y %i \r--> \w%s)^n", (g_ZoneId + 1), __ZONE_MODE[iZoneMode]);

		oldmenu_additem(1, 1, "\r1.\w Editar zona actual^n");

		oldmenu_additem(2, 2, "\r2.\w Ver zona anterior");
		oldmenu_additem(3, 3, "\r3.\w Ver zona siguiente^n");
	}
	
	oldmenu_additem(4, 4, "\r4.\w Crear nueva zona^n");

	if(iZoneMode != -1) {
		oldmenu_additem(6, 6, "\r6.\w Borrar zona actual^n");
	}

	oldmenu_additem(9, 9, "\r9.\w Guardar todos los cambios");
	oldmenu_additem(0, 0, "\r0.\w Salir");

	oldmenu_display(id);
}

@menu__WalkGuard(const id, const item) {
	if(!item) {
		g_EditorId = 0;

		hideAllZones();
		return;
	} if(!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		clientPrintColor(id, _, "No tienes acceso a este menú.");
		return;
	}

	switch(item) {
		case 1: {
			if(is_valid_ent(g_Zone[g_ZoneId])) {
				showMenu__WalkGuardEdit(id);
			} else {
				showMenu__WalkGuard(id);
			}
		} case 2: {
			g_ZoneId = ((g_ZoneId > 0) ? (g_ZoneId - 1) : g_ZoneId);
			showMenu__WalkGuard(id);
		} case 3: {
			g_ZoneId = ((g_ZoneId < (g_MaxZones - 1)) ? (g_ZoneId + 1) : g_ZoneId);
			showMenu__WalkGuard(id);
		} case 4: {
			showMenu__WalkGuardCreate(id);
		} case 6: {
			showMenu__WalkGuardDelete(id);
		} case 9: {
			new sZoneFile[256];
			formatex(sZoneFile, charsmax(sZoneFile), "addons/amxmodx/configs/walkguard/%s.wgz", g_CurrentMap);
			delete_file(sZoneFile);
			
			findAllZones();
			
			new iZoneMode;
			new Float:vecOrigin[3];
			new Float:vecMins[3];
			new Float:vecMaxs[3];
			new sText[128];
			
			for(new i = 0; i < g_MaxZones; ++i) {
				iZoneMode = entity_get_int(g_Zone[i], EV_INT_iuser1);
				
				entity_get_vector(g_Zone[i], EV_VEC_origin, vecOrigin);
				
				entity_get_vector(g_Zone[i], EV_VEC_mins, vecMins);
				entity_get_vector(g_Zone[i], EV_VEC_mins, vecMaxs);
				
				formatex(sText, charsmax(sText), "%s %.1f %.1f %.1f %.0f %.0f %.0f %.0f %.0f %.0f", __ZONE_NAME[iZoneMode], vecOrigin[0], vecOrigin[1], vecOrigin[2], vecMins[0], vecMins[1], vecMins[2], vecMaxs[0], vecMaxs[1], vecMaxs[2]);
				write_file(sZoneFile, sText);
			}
			
			clientPrintColor(id, _, "Se guardo correctamente el archivo: !g%s!y.", sZoneFile);
			showMenu__WalkGuard(id);
		}
	}
}

showMenu__WalkGuardEdit(const id) {
	SetGlobalTransTarget(id);

	new iZoneMode = -1;
	
	if(is_valid_ent(g_Zone[g_ZoneId])) {
		iZoneMode = entity_get_int(g_Zone[g_ZoneId], EV_INT_iuser1);
	}

	oldmenu_create("\yWALKGUARD - EDITAR ZONA", "@menu__WalkGuardEdit");

	if(iZoneMode != -1) {
		oldmenu_additem(1, 1, "\r1.\w Editar función\r:\y %s^n", __ZONE_MODE[iZoneMode]);
	}

	oldmenu_additem(4, 4, "\r4.\w Cambiar coordenada\r:\y %s^n", __NAME_COORD[g_Direction]);

	oldmenu_additem(5, 5, "\r5.\w Acortar");
	oldmenu_additem(6, 6, "\r6.\w Alargar");
	oldmenu_additem(7, 7, "\r7.\w Acortar");
	oldmenu_additem(8, 8, "\r8.\w Alargar^n");

	oldmenu_additem(9, 9, "\r9.\w Incrementar en \y%d\w unidades", g_SetUnits);
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

@menu__WalkGuardEdit(const id, const item) {
	if(!item) {
		showMenu__WalkGuard(id);
		return;
	}

	switch(item) {
		case 1: {
			new iZoneMode = entity_get_int(g_Zone[g_ZoneId], EV_INT_iuser1);
			
			if(iZoneMode == (structIdZones - 1)) {
				iZoneMode = 0;
			} else {
				iZoneMode++;
			}
			
			entity_set_int(g_Zone[g_ZoneId], EV_INT_iuser1, iZoneMode);
		} case 4: {
			g_Direction = ((g_Direction < 2) ? (g_Direction + 1) : 0);
		} case 5: {
			new iEnt = g_Zone[g_ZoneId];
			
			if(is_valid_ent(iEnt)) {
				new Float:vecOrigin[3];
				new Float:vecMins[3];
				new Float:vecMaxs[3];

				entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				
				entity_get_vector(iEnt, EV_VEC_mins, vecMins);
				entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
				
				if((floatabs(vecMins[g_Direction]) + vecMaxs[g_Direction]) < (g_SetUnits + 1)) {
					showMenu__WalkGuardEdit(id);
					return;
				}
				
				vecOrigin[g_Direction] += (float(g_SetUnits) / 2.0);
				vecMins[g_Direction] += (float(g_SetUnits) / 2.0);
				vecMaxs[g_Direction] -= (float(g_SetUnits) / 2.0);
				
				entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);

				entity_set_vector(iEnt, EV_VEC_mins, vecMins);
				entity_set_vector(iEnt, EV_VEC_maxs, vecMaxs);
			}
		} case 6: {
			new iEnt = g_Zone[g_ZoneId];
	
			if(is_valid_ent(iEnt)) {
				new Float:vecOrigin[3];
				new Float:vecMins[3];
				new Float:vecMaxs[3];

				entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				
				entity_get_vector(iEnt, EV_VEC_mins, vecMins);
				entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
				
				vecOrigin[g_Direction] -= (float(g_SetUnits) / 2.0);
				vecMins[g_Direction] -= (float(g_SetUnits) / 2.0);
				vecMaxs[g_Direction] += (float(g_SetUnits) / 2.0);
				
				entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);

				entity_set_vector(iEnt, EV_VEC_mins, vecMins);
				entity_set_vector(iEnt, EV_VEC_maxs, vecMaxs);
			}
		} case 7: {
			new iEnt = g_Zone[g_ZoneId];
			
			if(is_valid_ent(iEnt)) {
				new Float:vecOrigin[3];
				new Float:vecMins[3];
				new Float:vecMaxs[3];

				entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				
				entity_get_vector(iEnt, EV_VEC_mins, vecMins);
				entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
				
				if((floatabs(vecMins[g_Direction]) + vecMaxs[g_Direction]) < (g_SetUnits + 1)) {
					showMenu__WalkGuardEdit(id);
					return;
				}
				
				vecOrigin[g_Direction] -= (float(g_SetUnits) / 2.0);
				vecMins[g_Direction] += (float(g_SetUnits) / 2.0);
				vecMaxs[g_Direction] -= (float(g_SetUnits) / 2.0);
				
				entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);

				entity_set_vector(iEnt, EV_VEC_mins, vecMins);
				entity_set_vector(iEnt, EV_VEC_maxs, vecMaxs);
			}
		} case 8: {
			new iEnt = g_Zone[g_ZoneId];
			
			if(is_valid_ent(iEnt)) {
				new Float:vecOrigin[3];
				new Float:vecMins[3];
				new Float:vecMaxs[3];

				entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				
				entity_get_vector(iEnt, EV_VEC_mins, vecMins);
				entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
				
				vecOrigin[g_Direction] += (float(g_SetUnits) / 2.0);
				vecMins[g_Direction] -= (float(g_SetUnits) / 2.0);
				vecMaxs[g_Direction] += (float(g_SetUnits) / 2.0);
				
				entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);

				entity_set_vector(iEnt, EV_VEC_mins, vecMins);
				entity_set_vector(iEnt, EV_VEC_maxs, vecMaxs);
			}
		} case 9: {
			g_SetUnits = ((g_SetUnits < 100) ? (g_SetUnits * 10) : 1);
		}
	}

	showMenu__WalkGuardEdit(id);
}

showMenu__WalkGuardCreate(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yWALKGUARD - CREAR ZONA", "@menu__WalkGuardCreate");

	oldmenu_additem(1, 1, "\r1.\w Crear nueva zona^n");

	oldmenu_additem(2, 2, "\r2.\w Apunta arriba a la derecha");
	oldmenu_additem(3, 3, "\r3.\w Apunta abajo a la derecha^n");

	oldmenu_additem(4, 4, "\r4.\w Crear zona predefinida^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__WalkGuardCreate(const id, const item) {
	if(!item) {
		showMenu__WalkGuard(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_MaxZones < (MAX_ZONES - 1)) {
				new Float:vecOrigin[3];
				new iEnt;

				entity_get_vector(id, EV_VEC_origin, vecOrigin);
				iEnt = createZone(vecOrigin, Float:{-32.0, -32.0, -32.0}, Float:{32.0, 32.0, 32.0}, 0);
				
				findAllZones();
				
				for(new i = 0; i < g_MaxZones; ++i) {
					if(g_Zone[i] == iEnt) {
						g_ZoneId = i;
					}
				}
				
				showAllZones();

				showMenu__WalkGuardEdit(id);
			} else {
				clientPrintColor(id, _, "Solo se pueden crear hasta diez zonas.");
				showMenu__WalkGuardCreate(id);
			}
		} case 2: {
			new vecOriginId[3];
			new Float:vecOrigin[3];
			
			get_user_origin(id, vecOriginId, 3);
			IVecFVec(vecOriginId, vecOrigin);
			
			g_ZoneBox[0] = vecOrigin;
			
			showMenu__WalkGuardCreate(id);
		} case 3: {
			new vecOriginId[3];
			new Float:vecOrigin[3];
			
			get_user_origin(id, vecOriginId, 3);
			IVecFVec(vecOriginId, vecOrigin);
			
			g_ZoneBox[1] = vecOrigin;
			
			showMenu__WalkGuardCreate(id);
		} case 4: {
			if((g_ZoneBox[0][0] == 0.0 && g_ZoneBox[0][1] == 0.0 && g_ZoneBox[0][2] == 0.0) || (g_ZoneBox[1][0] == 0.0 && g_ZoneBox[1][1] == 0.0 && g_ZoneBox[1][2] == 0.0)) {
				clientPrintColor(id, _, "Falta indicar una de las posiciones para crear la zona predefinida.");
				
				showMenu__WalkGuardCreate(id);
				return;
			}
			
			if(g_MaxZones < (MAX_ZONES - 1)) {
				new Float:vecCenter[3];
				new Float:vecSize[3];
				new Float:vecMins[3];
				new Float:vecMaxs[3];
				new iEnt;
				
				for(new i = 0; i < 3; ++i) {
					vecCenter[i] = ((g_ZoneBox[0][i] + g_ZoneBox[1][i]) / 2.0);
					vecSize[i] = getFloatDistance(g_ZoneBox[0][i], g_ZoneBox[1][i]);
					vecMins[i] = (vecSize[i] / -2.0);
					vecMaxs[i] = (vecSize[i] / 2.0);
					
					g_ZoneBox[0][i] = 0.0;
					g_ZoneBox[1][i] = 0.0;
				}
				
				iEnt = createZone(vecCenter, vecMins, vecMaxs, ZONE_KILL_T2);
				
				findAllZones();
				
				for(new i = 0; i < g_MaxZones; ++i) {
					if(g_Zone[i] == iEnt) {
						g_ZoneId = i;
					}
				}
				
				showAllZones();

				showMenu__WalkGuardEdit(id);
			} else {
				clientPrintColor(id, _, "Solo se pueden crear hasta diez zonas.");
				showMenu__WalkGuardCreate(id);
			}
		}
	}
}

showMenu__WalkGuardDelete(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yWALKGUARD - BORRAR ZONA ACTUAL", "@menu__WalkGuardDelete");

	oldmenu_additem(-1, -1, "¿Desea borrar la zona actual?");
	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(0, 0, "\r0.\w No");

	oldmenu_display(id);
}

@menu__WalkGuardDelete(const id, const item) {
	if(item) {
		remove_entity(g_Zone[g_ZoneId]);
		
		g_ZoneId--;
		
		if(g_ZoneId < 0) {
			g_ZoneId = 0;
		}
		
		clientPrintColor(id, _, "Zona borrada.");
		findAllZones();
	}

	showMenu__WalkGuard(id);
}

showMenu__Tutorial(const id, const page) {
	if(page == 7) {
		showMenu__Stats(id);
		return;
	}

	g_MenuPage_Tutorial[id] = page;

	oldmenu_create("\y%s \r- \y%s \r(%s)^n\dby %s", "@menu__Tutorial", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	switch(page) {
		case 0: {
			oldmenu_additem(-1, -1, "\wMod originalmente creado por\r:\y %s^n", __PLUGIN_AUTHOR_ORIGINAL);

			oldmenu_additem(-1, -1, "\wSi esta es tu primera vez en este servidor");
			oldmenu_additem(-1, -1, "\wse recomienda que leas este sencillo pero breve tutorial para");
			oldmenu_additem(-1, -1, "\wentender las funciones básicas del juego.^n");

			oldmenu_additem(2, 2, "\r2.\w Siguiente \y(1 / 7)\w");
			oldmenu_additem(0, 0, "\r0.\w Omitir tutorial");
		} case 1: {
			oldmenu_additem(-1, -1, "\wEl objetivo principal es sobrevivir a las oleadas y");
			oldmenu_additem(-1, -1, "\wsubir tu nivel general como el nivel de tus clases.^n");

			oldmenu_additem(2, 2, "\r2.\w Siguiente \y(2 / 7)\w");
			oldmenu_additem(0, 0, "\r0.\w Omitir tutorial");
		} case 2: {
			oldmenu_additem(-1, -1, "\wPara comprar armamento y otras cosas debes");
			oldmenu_additem(-1, -1, "\wposicionarte cerca de uno de los tantos");
			oldmenu_additem(-1, -1, "\wvendedores (muñecos) y apretar la tecla E.^n");

			oldmenu_additem(-1, -1, "\wSolo puedes comprar poderes y recargar tus armas");
			oldmenu_additem(-1, -1, "\wmientras una oleada está en progreso");
			oldmenu_additem(-1, -1, "\wasí que compra todo lo que necesites antes de empezar.^n");

			oldmenu_additem(2, 2, "\r2.\w Siguiente \y(3 / 7)\w");
			oldmenu_additem(0, 0, "\r0.\w Omitir tutorial");
		} case 3: {
			oldmenu_additem(-1, -1, "\wPara seleccionar un poder comprado aprieta");
			oldmenu_additem(-1, -1, "\wla \ytecla C\w para ir hacia la derecha o");
			oldmenu_additem(-1, -1, "\wla \ytecla X\w para ir hacia la izquierda.");
			oldmenu_additem(-1, -1, "\wUna vez seleccionado tu poder, apretá");
			oldmenu_additem(-1, -1, "\wla \ytecla Z\w para activarlo/lanzarlo.^n");

			oldmenu_additem(2, 2, "\r2.\w Siguiente \y(4 / 7)\w");
			oldmenu_additem(0, 0, "\r0.\w Omitir tutorial");
		} case 4: {
			oldmenu_additem(-1, -1, "\wLos zombies que tienen un brillo BLANCO");
			oldmenu_additem(-1, -1, "\wson aquellos que tienen protección");
			oldmenu_additem(-1, -1, "\westos reciben la mitad del daño que les hagas.^n");

			oldmenu_additem(2, 2, "\r2.\w Siguiente \y(5 / 7)\w");
			oldmenu_additem(0, 0, "\r0.\w Omitir tutorial");
		} case 5: {
			oldmenu_additem(-1, -1, "\wUna vez finalizadas las 10 oleadas");
			oldmenu_additem(-1, -1, "\wel \yjefe final\w aparece y el objetivo del grupo");
			oldmenu_additem(-1, -1, "\wes matarlo. Ten cuidado con este monstruo debido a");
			oldmenu_additem(-1, -1, "\wque tiene poderes especiales que hacen mucho daño.^n");

			oldmenu_additem(2, 2, "\r2.\w Siguiente \y(6 / 7)\w");
			oldmenu_additem(0, 0, "\r0.\w Omitir tutorial");
		} case 6: {
			oldmenu_additem(-1, -1, "\wPor último, hay muchas más cosas que");
			oldmenu_additem(-1, -1, "\wdebes ir descubriendo por ti solo a medida");
			oldmenu_additem(-1, -1, "\wque vas jugando, como las \yhabilidades\w, \ydificultades\w,");
			oldmenu_additem(-1, -1, "\yestrategias\w, \yclases\w, \ylogros\w, etc.^n");

			oldmenu_additem(2, 2, "\r2.\w Finalizar tutorial \y(7 / 7)\w");
		}
	}

	oldmenu_display(id);
}

@menu__Tutorial(const id, const item) {
	if(!item) {
		// g_Tutorial[id] = 1;

		if(dg_get_user_acc_status(id) < STATUS_PLAYING) {
			dg_get_user_menu_join(id);
		} else {
			showMenu__Stats(id);
		}

		return;
	}

	switch(item) {
		case 2: {
			++g_MenuPage_Tutorial[id];
			
			if(g_MenuPage_Tutorial[id] == 7 && !g_Tutorial[id]) {
				g_Tutorial[id] = 1;
				
				if(dg_get_user_acc_status(id) < STATUS_PLAYING) {
					dg_get_user_menu_join(id);
				} else {
					showMenu__Stats(id);
				}

				setAchievement(id, TUTORIAL);
				return;
			}
			
			showMenu__Tutorial(id, g_MenuPage_Tutorial[id]);
		}
	}
}

showMenu__Game(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\y%s \r- \y%s \r(%s)^n\dby %s", "@menu__Game", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(-1, -1, "\wNivel\r:\y %d", g_Level[id]);
	oldmenu_additem(-1, -1, "\wClase\r:\y %s \r-\w Nivel\r:\y %d^n", __CLASSES[g_ClassId[id]][className], g_ClassLevel[id][g_ClassId[id]]);

	oldmenu_additem(1, 1, "\r1.\w Clases");

	if(g_Wave) {
		oldmenu_additem(2, 2, "\r2.\w Dificultades \y(%s)", __DIFFS[g_Diff][diffNameMay]);
	} else {
		oldmenu_additem(2, 2, "\r2.\w Dificultades \y(EN VOTACIÓN)");
	}

	if(g_Points[id]) {
		oldmenu_additem(3, 3, "\r3.\w Habilidades \y(\r*\y)^n");
	} else {
		oldmenu_additem(3, 3, "\r3.\w Habilidades^n");
	}

	oldmenu_additem(4, 4, "\r4.\w Logros");
	oldmenu_additem(5, 5, "\r5.\w Mejoras^n");

	oldmenu_additem(6, 6, "\r6.\w Requerimientos de Nivel^n");

	oldmenu_additem(7, 7, "\r7.\w Opciones de usuario");
	oldmenu_additem(8, 8, "\r8.\w Estadísticas^n");

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

@menu__Game(const id, const item) {
	if(!item) {
		return;
	}

	switch(item) {
		case 1: {
			showMenu__Classes(id);
		} case 2: {
			showMenu__ChooseDiff(id);
		} case 3: {
			showMenu__Habs(id);
		} case 4: {
			showMenu__AchievementClasses(id);
		} case 5: {
			if(g_MenuPage_Upgrade[id] < 1) {
				g_MenuPage_Upgrade[id] = 1;
			}

			showMenu__Upgrades(id, g_MenuPage_Upgrade[id]);
		} case 6: {
			showMenu__RequerimentsLevel(id, g_Level[id]);
		} case 7: {
			showMenu__UserOptions(id);
		} case 8: {
			showMenu__Stats(id);
		}
	}
}

showMenu__Classes(const id) {
	SetGlobalTransTarget(id);

	new sItem[128];
	new iMenuId;
	new sPosition[2];
	
	formatex(sItem, charsmax(sItem), "CLASES^n\wClase\r:\y %s \r-\w Nivel\r:\y %d\R", __CLASSES[g_ClassId[id]][className], g_ClassLevel[id][g_ClassId[id]]);
	iMenuId = menu_create(sItem, "@menu__Classes");
	
	for(new i = 0; i < structIdClasses; ++i) {
		formatex(sItem, charsmax(sItem), "%s%s", ((g_ClassId[id] != i) ? "\w" : "\d"), __CLASSES[i][className]);

		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage_Classes[id] = min(g_MenuPage_Classes[id], (menu_pages(iMenuId) - 1));
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_Classes[id]);
}

@menu__Classes(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Classes[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData_ClassId[id] = iItemId;
	
	showMenu__ClassInfo(id);
	return PLUGIN_HANDLED;
}

showMenu__ClassInfo(const id) {
	SetGlobalTransTarget(id);

	new iClassId = g_MenuData_ClassId[id];

	oldmenu_create("\y%s^n\wNivel\r:\y %d", "@menu__ClassInfo", __CLASSES[iClassId][classNameMay], g_ClassLevel[id][iClassId]);

	oldmenu_additem(-1, -1, "\w%s^n", __CLASSES[iClassId][classDesc]);

	if(g_WaveInProgress) {
		oldmenu_additem(-1, -1, "\d1. Elegir clase \y(OLEADA EN MARCHA)^n");
	} else {
		if(g_ClassId[id] == iClassId) {
			oldmenu_additem(-1, -1, "\d1. Elegir clase \y(ELEGIDA)^n");
		} else {
			if(iClassId == CLASS_SOPORTE && g_ClassSoporte_Bonus[id] && (g_Gold[id] - 200) < 0) {
				oldmenu_additem(-1, -1, "\d1. Elegir clase^n");
			} else if(iClassId == CLASS_PISTOLERO && !g_Achievement[id][PISTOLERO_UNLOCKED]) {
				oldmenu_additem(-1, -1, "\d1. Elegir clase^n");
			} else {
				oldmenu_additem(1, 1, "\r1.\w Elegir clase^n");
			}
		}
	}

	for(new i = 2; i < 8; ++i) {
		oldmenu_additem(i, (i - 2), "\r%d.%s Nivel\r:%s %d", i, ((g_ClassLevel[id][iClassId] >= (i - 1)) ? "\w" : "\d"), ((g_ClassLevel[id][iClassId] >= (i - 1)) ? "\y" : "\d"), (i - 1));
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ClassInfo(const id, const item, const value) {
	if(!item) {
		showMenu__Classes(id);
		return;
	}

	new iClassId = g_MenuData_ClassId[id];

	switch(item) {
		case 1: {
			if(g_WaveInProgress) {
				clientPrintColor(id, _, "No puedes utilizar esta opción cuando hay una oleada en marcha.");
				return;
			}

			switch(g_ClassId[id]) {
				case CLASS_SOLDADO: {
					if(g_ClassLevel[id][g_ClassId[id]] >= 4) {
						if(user_has_weapon(id, _:WEAPON_M4A1)) {
							new iWeaponEnt = find_ent_by_owner(-1, "weapon_m4a1", id);
							new iClip = clamp((cs_get_weapon_ammo(iWeaponEnt) - __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip]), 0, 200);

							if(g_HabCacheClip[id] && iClip) {
								new iExtraClip = ((__DEFAULT_MAXCLIP[_:WEAPON_M4A1] * g_HabCacheClip[id]) / 100);
								
								if(iClip > (__DEFAULT_MAXCLIP[_:WEAPON_M4A1] + iExtraClip)) {
									iClip = __DEFAULT_MAXCLIP[_:WEAPON_M4A1] + iExtraClip;
								}
							}
							
							cs_set_weapon_ammo(iWeaponEnt, iClip);
						}
						
						if(user_has_weapon(id, _:WEAPON_AK47)) {
							new iWeaponEnt = find_ent_by_owner(-1, "weapon_ak47", id);
							new iClip = clamp((cs_get_weapon_ammo(iWeaponEnt) - __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip]), 0, 200);

							if(g_HabCacheClip[id] && iClip) {
								new iExtraClip = ((__DEFAULT_MAXCLIP[_:WEAPON_AK47] * g_HabCacheClip[id]) / 100);
								
								if(iClip > (__DEFAULT_MAXCLIP[_:WEAPON_AK47] + iExtraClip)) {
									iClip = __DEFAULT_MAXCLIP[_:WEAPON_AK47] + iExtraClip;
								}
							}
							
							cs_set_weapon_ammo(iWeaponEnt, iClip);
						}
					}
				} case CLASS_SOPORTE: {
					if(g_ClassLevel[id][g_ClassId[id]] >= 1) {
						if(user_has_weapon(id, _:WEAPON_XM1014)) {
							new iWeaponEnt = find_ent_by_owner(-1, "weapon_xm1014", id);
							new iClip = clamp((cs_get_weapon_ammo(iWeaponEnt) - __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip]), 0, 200);

							if(g_HabCacheClip[id] && iClip) {
								new iExtraClip = ((__DEFAULT_MAXCLIP[_:WEAPON_XM1014] * g_HabCacheClip[id]) / 100);
								
								if(iClip > (__DEFAULT_MAXCLIP[_:WEAPON_XM1014] + iExtraClip)) {
									iClip = __DEFAULT_MAXCLIP[_:WEAPON_XM1014] + iExtraClip;
								}
							}
							
							cs_set_weapon_ammo(iWeaponEnt, iClip);
						}
					}
				} case CLASS_PUBERO: {
					if(g_ClassLevel[id][g_ClassId[id]] >= 4) {
						if(user_has_weapon(id, _:WEAPON_SG550)) {
							new iWeaponEnt = find_ent_by_owner(-1, "weapon_sg550", id);
							new iClip = clamp((cs_get_weapon_ammo(iWeaponEnt) - __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip]), 0, 200);

							if(g_HabCacheClip[id] && iClip) {
								new iExtraClip = ((__DEFAULT_MAXCLIP[_:WEAPON_SG550] * g_HabCacheClip[id]) / 100);
								
								if(iClip > (__DEFAULT_MAXCLIP[_:WEAPON_SG550] + iExtraClip)) {
									iClip = __DEFAULT_MAXCLIP[_:WEAPON_SG550] + iExtraClip;
								}
							}
							
							cs_set_weapon_ammo(iWeaponEnt, iClip);
						}

						if(user_has_weapon(id, _:WEAPON_G3SG1)) {
							new iWeaponEnt = find_ent_by_owner(-1, "weapon_g3sg1", id);
							new iClip = clamp((cs_get_weapon_ammo(iWeaponEnt) - __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip]), 0, 200);

							if(g_HabCacheClip[id] && iClip) {
								new iExtraClip = ((__DEFAULT_MAXCLIP[_:WEAPON_G3SG1] * g_HabCacheClip[id]) / 100);
								
								if(iClip > (__DEFAULT_MAXCLIP[_:WEAPON_G3SG1] + iExtraClip)) {
									iClip = __DEFAULT_MAXCLIP[_:WEAPON_G3SG1] + iExtraClip;
								}
							}
							
							cs_set_weapon_ammo(iWeaponEnt, iClip);
						}
					}
				} case CLASS_SCOUTER: {
					if(g_ClassLevel[id][g_ClassId[id]] >= 4) {
						if(user_has_weapon(id, _:WEAPON_SCOUT)) {
							new iWeaponEnt = find_ent_by_owner(-1, "weapon_scout", id);
							new iClip = clamp((cs_get_weapon_ammo(iWeaponEnt) - __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip]), 0, 200);

							if(g_HabCacheClip[id] && iClip) {
								new iExtraClip = ((__DEFAULT_MAXCLIP[_:WEAPON_SCOUT] * g_HabCacheClip[id]) / 100);
								
								if(iClip > (__DEFAULT_MAXCLIP[_:WEAPON_SCOUT] + iExtraClip)) {
									iClip = __DEFAULT_MAXCLIP[_:WEAPON_SCOUT] + iExtraClip;
								}
							}
							
							cs_set_weapon_ammo(iWeaponEnt, iClip);
						}
					}
				}
			}

			switch(iClassId) {
				case CLASS_APOYO, CLASS_PESADO, CLASS_ASALTO, CLASS_COMANDANTE: {
					if((iClassId == CLASS_APOYO && !g_Upgrades[id][UPGRADE_UNLOCK_APOYO]) || (iClassId == CLASS_PESADO && !g_Upgrades[id][UPGRADE_UNLOCK_PESADO]) || (iClassId == CLASS_ASALTO && !g_Upgrades[id][UPGRADE_UNLOCK_ASALTO]) || (iClassId == CLASS_COMANDANTE && !g_Upgrades[id][UPGRADE_UNLOCK_COMANDANTE])) {
						clientPrintColor(id, _, "Necesitas desbloquear esta clase desde el menú de !gmejoras!y para utilizarla.");
						
						showMenu__ClassInfo(id);
						return;
					}
				} case CLASS_PISTOLERO: {
					if(!g_Achievement[id][PISTOLERO_UNLOCKED]) {
						clientPrintColor(id, _, "Necesitas desbloquear el logro !gPISTOLERO!y para utilizar esta clase.");
						
						showMenu__ClassInfo(id);
						return;
					}
				} case CLASS_PUBERO, CLASS_LEGIONARIO, CLASS_BITERO, CLASS_SCOUTER: {
					if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
						clientPrintColor(id, _, "Necesitas ser VIP para utilizar esta clase.");
						
						showMenu__ClassInfo(id);
						return;
					}
				}
			}

			g_ClassId[id] = iClassId;
			
			clientPrintColor(id, _, "Tu nueva clase es !g%s!y.", __CLASSES[g_ClassId[id]][className]);

			if(g_ClassSoporte_Bonus[id]) {
				g_ClassSoporte_Bonus[id] = 0;
				g_Gold[id] -= 200;
			}

			if((g_ClassId[id] == CLASS_SOLDADO && g_ClassLevel[id][g_ClassId[id]] >= 6) || (g_ClassId[id] == CLASS_INGENIERO && g_ClassLevel[id][g_ClassId[id]] >= 6) || (g_ClassId[id] == CLASS_FRANCOTIRADOR && g_ClassLevel[id][g_ClassId[id]] >= 4) || (g_ClassId[id] == CLASS_PESADO && g_ClassLevel[id][g_ClassId[id]] >= 6) || (g_ClassId[id] == CLASS_ASALTO && g_ClassLevel[id][g_ClassId[id]] >= 6) || (g_ClassId[id] == CLASS_COMANDANTE && g_ClassLevel[id][g_ClassId[id]] >= 6) || (g_ClassId[id] == CLASS_PUBERO && g_ClassLevel[id][g_ClassId[id]] >= 6)) {
				clientPrintColor(id, _, "Si comienzas con algún arma o equipo predefinido, se te otorgará cuando empiece la oleada.");
			} else if(g_ClassId[id] == CLASS_SOPORTE && g_ClassLevel[id][g_ClassId[id]] >= 4 && !g_Wave && !g_ClassSoporte_Bonus[id]) {
				clientPrintColor(id, _, "Has recibido !g200 Oro!y por tu clase, si cambias de clase se removerá ese beneficio.");
				
				g_ClassSoporte_Bonus[id] = 1;
				g_Gold[id] += 200;
			}
		} default: {
			showMenu__ClassInfoLevel(id, value);
		}
	}
}

showMenu__ClassInfoLevel(const id, const class_level) {
	SetGlobalTransTarget(id);

	new sClassName[32];
	new iClassId = g_MenuData_ClassId[id];
	new iClassReq = __CLASSES[iClassId][(classReqLv1 + class_level)];
	new sClassReq[16];
	new sHaveReq[16];
	new sReqDesc[96];

	formatex(sClassName, charsmax(sClassName), "%s", __CLASSES[iClassId][className]);
	strtoupper(sClassName);

	oldmenu_create("\y%s^n\wInformación del Nivel\r:\y %d", "@menu__ClassInfoLevel", sClassName, (class_level + 1));

	if((get_user_flags(id) & ADMIN_RESERVATION)) {
		iClassReq = (iClassReq - ((iClassReq * 20) / 100));
	}

	addDot(iClassReq, sClassReq, charsmax(sClassReq));
	addDot(g_ClassReqs[id][iClassId], sHaveReq, charsmax(sHaveReq));

	switch(iClassId) {
		case CLASS_SOLDADO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON M4A1 o AK47\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_INGENIERO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO POR TORRETAS\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_SOPORTE: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON XM1014\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_FRANCOTIRADOR: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON AWP\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_APOYO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON M3 o MP5\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_PESADO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON M249\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_ASALTO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON FAMAS o GALIL\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_COMANDANTE: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON AUG o SG-552\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_PISTOLERO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDISPAROS ACERTADOS CON DEAGLE\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_PUBERO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON SG-550 o G3SG1\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_LEGIONARIO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON P90\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_BITERO: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON MAC10 o TMP\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		} case CLASS_SCOUTER: {
			formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON SCOUT\r:^n\w%s \r/ \y%s", sHaveReq, sClassReq);
		}
	}

	switch(class_level) {
		case 0: {
			oldmenu_additem(-1, -1, "%s^n^n%s", __CLASSES[iClassId][classDescLv1], sReqDesc);
		} case 1: {
			oldmenu_additem(-1, -1, "%s^n^n%s", __CLASSES[iClassId][classDescLv2], sReqDesc);
		} case 2: {
			oldmenu_additem(-1, -1, "%s^n^n%s", __CLASSES[iClassId][classDescLv3], sReqDesc);
		} case 3: {
			oldmenu_additem(-1, -1, "%s^n^n%s", __CLASSES[iClassId][classDescLv4], sReqDesc);
		} case 4: {
			oldmenu_additem(-1, -1, "%s^n^n%s", __CLASSES[iClassId][classDescLv5], sReqDesc);
		} case 5: {
			oldmenu_additem(-1, -1, "%s^n^n%s", __CLASSES[iClassId][classDescLv6], sReqDesc);
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ClassInfoLevel(const id, const item) {
	if(!item) {
		showMenu__ClassInfo(id);
	}
}

showMenu__ChooseDiff(const id) {
	if(!is_user_connected(id) || dg_get_user_acc_status(id) < STATUS_PLAYING) {
		return;
	}

	SetGlobalTransTarget(id);

	new iMenuId = menu_create("\ySELECCIONA UNA DIFICULTAD", "@menu__ChooseDiff");
	
	if(g_Wave) {
		menu_additem(iMenuId, "Normal", "1");
		menu_additem(iMenuId, "Nightmare", "2");
		menu_additem(iMenuId, "Suicidal", "3");
		menu_additem(iMenuId, "Hell^n", "4");
	} else {
		new i;
		new iNormal = 0;
		new iNightmare = 0;
		new iSuicidal = 0;
		new iHell = 0;
		new sItem[32];
		
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			if(dg_get_user_acc_status(i) < STATUS_PLAYING) {
				continue;
			}

			switch(g_VoteDiff[i]) {
				case DIFF_NORMAL: {
					iNormal++;
				} case DIFF_NIGHTMARE: {
					iNightmare++;
				} case DIFF_SUICIDAL: {
					iSuicidal++;
				} case DIFF_HELL: {
					iHell++;
				}
			}
		}
		
		formatex(sItem, charsmax(sItem), "Normal \y(%d voto%s)", iNormal, ((iNormal != 1) ? "s" : ""));
		menu_additem(iMenuId, sItem, "1");
		formatex(sItem, charsmax(sItem), "Nightmare \y(%d voto%s)", iNightmare, ((iNightmare != 1) ? "s" : ""));
		menu_additem(iMenuId, sItem, "2");
		formatex(sItem, charsmax(sItem), "Suicidal \y(%d voto%s)", iSuicidal, ((iSuicidal != 1) ? "s" : ""));
		menu_additem(iMenuId, sItem, "3");
		formatex(sItem, charsmax(sItem), "Hell \y(%d voto%s)^n", iHell, ((iHell != 1) ? "s" : ""));
		menu_additem(iMenuId, sItem, "4");
	}

	menu_additem(iMenuId, "Dificultades favoritas", "5");

	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

@menu__ChooseDiff(const id, const menu, const item) {
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

	iItemId = (str_to_num(sPosition) - 1);
	
	if(iItemId != 4) {
		g_MenuData_DiffId[id] = iItemId;
		showMenu__DiffInfo(id);
	} else {
		showMenu__FavDiffs(id);
	}
	
	return PLUGIN_HANDLED;
}

showMenu__DiffInfo(const id) {
	SetGlobalTransTarget(id);

	new iDiffId = g_MenuData_DiffId[id];

	oldmenu_create("\y%s", "@menu__DifficultyInfo", __DIFFS[iDiffId][diffNameMay]);

	oldmenu_additem(-1, -1, "%s^n", __DIFFS[iDiffId][diffDesc]);

	if(!g_EndVote) {
		oldmenu_additem(1, 1, "\r1.\w Votar esta dificultad");
	} else {
		oldmenu_additem(-1, -1, "\d1. Votar esta dificultad");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__DifficultyInfo(const id, const item) {
	if(!item) {
		showMenu__ChooseDiff(id);
		return;
	}

	new iDiffId = g_MenuData_DiffId[id];

	switch(item) {
		case 1: {
			if(g_EndVote) {
				showMenu__ChooseDiff(id);
				return;
			}

			if(iDiffId < g_BlockDiff) {
				clientPrintColor(id, _, "Esta dificultad no se puede jugar en este mapa.");

				showMenu__ChooseDiff(id);
				return;
			}

			if(!checkVoteDiff(id, iDiffId)) {
				clientPrintColor(id, _, "Necesitas un !gnivel más alto!y para votar esta dificultad.");
				
				showMenu__ChooseDiff(id);
				return;
			}

			g_VoteDiff[id] = iDiffId;
		}
	}
}

showMenu__FavDiffs(const id) {
	if(g_AutoDiff[id][0] == -1) {
		clientPrintColor(id, _, "Tus preferencias se están cargando, por favor, intenta nuevamente en unos segundos.");
		return;
	}

	SetGlobalTransTarget(id);

	new sItem[64];
	new iMenuId;
	new sPosition[2];

	iMenuId = menu_create("\yDIFICULTADES FAVORITAS^n\wElige las dificultades que deseas jugar en cada mapa:\R\y", "@menu__FavDiffs");
	
	for(new i = 0; i < structIdMaps; ++i) {
		formatex(sItem, charsmax(sItem), "\w%s\r:\y %s", __MAPS[i][mapName], __DIFFS[g_AutoDiff[id][i]][diffNameMin]);
		
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Guardar y volver");

	g_MenuPage_FavDiffs[id] = min(g_MenuPage_FavDiffs[id], (menu_pages(iMenuId) - 1));
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_FavDiffs[id]);
}

@menu__FavDiffs(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_FavDiffs[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		saveFavDiffs(id);

		showMenu__ChooseDiff(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	g_AutoDiff[id][iItemId]++;

	if(g_AutoDiff[id][iItemId] > DIFF_HELL) {
		g_AutoDiff[id][iItemId] = __MAPS[iItemId][mapBlockDiff];
	}

	showMenu__FavDiffs(id);
	return PLUGIN_HANDLED;
}

showMenu__Habs(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yHABILIDADES^n\wPuntos\r:\y %d", "@menu__Habs", g_Points[id]);

	for(new i = 0, j = 1; i < structIdHabs; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s \y(%d / %d)", j, __HABS[i][habName], g_Hab[id][i], __HABS[i][habMaxLevel]);
	}

	oldmenu_additem(8, 8, "^n\r8.\w Aumentar de a \y%d punto%s\w", g_MenuData_HabPoints[id], ((g_MenuData_HabPoints[id] != 1) ? "s" : ""));
	oldmenu_additem(9, 9, "\r9.\w Reiniciar puntos^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__Habs(const id, const item, const value) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 8: {
			switch(g_MenuData_HabPoints[id]) {
				case 1: {
					g_MenuData_HabPoints[id] = 5;
				} case 5: {
					g_MenuData_HabPoints[id] = 10;
				} case 10: {
					g_MenuData_HabPoints[id] = 1;
				}
			}

			showMenu__Habs(id);
		} case 9: {
			if(g_WaveInProgress) {
				clientPrintColor(id, _, "No puedes reiniciar tus habilidades mientras hay una oleada en marcha.");
				
				showMenu__Habs(id);
				return;
			}
			
			new iReturn = (g_Hab[id][HAB_DAMAGE] + g_Hab[id][HAB_PRECISION] + g_Hab[id][HAB_SPEED_WEAPON] + g_Hab[id][HAB_BULLETS]);
			
			if(!iReturn) {
				clientPrintColor(id, _, "Tus habilidades ya están reiniciadas.");

				showMenu__Habs(id);
				return;
			}

			new iFix = 0;
			
			g_Hab[id][HAB_DAMAGE] = 0;
			g_Hab[id][HAB_PRECISION] = 0;
			g_Hab[id][HAB_SPEED_WEAPON] = 0;
			
			if(g_Hab[id][HAB_BULLETS]) {
				iFix = 1;
			}
			
			g_Hab[id][HAB_BULLETS] = 0;
			
			g_HabCache[id][_:HAB_F_DAMAGE] = 0.0;
			g_HabCache[id][_:HAB_F_PRECISION] = 0.0;
			g_HabCache[id][_:HAB_F_SPEED_WEAPON] = 0.0;
			g_HabCacheClip[id] = 0;
			
			g_Points[id] += iReturn;
			
			if(iFix) {
				new iExtraClip;
				new iWeaponId;
				
				for(new i = 0; i < sizeof(__WEAPON_NAMES); ++i) {
					if(user_has_weapon(id, _:__WEAPON_NAMES[i][weaponId])) {
						iExtraClip = __DEFAULT_MAXCLIP[_:__WEAPON_NAMES[i][weaponId]];
						
						if(g_CurrentWeapon[id] == __CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == __CLASSES_WEAPONS[g_ClassId[id]][1]) {
							iExtraClip += __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip];
						}
						
						iWeaponId = find_ent_by_owner(-1, __WEAPON_NAMES[i][weaponEnt], id);
						cs_set_weapon_ammo(iWeaponId, iExtraClip);
					}
				}
			}
			
			showMenu__Habs(id);
		} default: {
			g_MenuData_HabId[id] = value;
			showMenu__HabInfo(id);
		}
	}
}

showMenu__HabInfo(const id) {
	SetGlobalTransTarget(id);

	new iHabPoints = g_MenuData_HabPoints[id];
	new iHabId = g_MenuData_HabId[id];

	oldmenu_create("\y%s (%d / %d)^n\wPuntos\r:\y %d", "@menu__HabInfo", __HABS[iHabId][habNameMay], g_Hab[id][iHabId], __HABS[iHabId][habMaxLevel], g_Points[id]);

	oldmenu_additem(-1, -1, "\w%s^n", __HABS[iHabId][habDesc]);

	oldmenu_additem(-1, -1, "\r - \y+%0.2f%%\w Por nivel", __HABS[iHabId][habValue]);
	oldmenu_additem(-1, -1, "\r - \y+%0.2f%%\w Actual^n", (float(g_Hab[id][iHabId]) * __HABS[iHabId][habValue]));

	if(g_WaveInProgress) {
		oldmenu_additem(-1, -1, "\d1. Subir habilidad \y(OLEADA EN PROGRESO)");
	} else {
		oldmenu_additem(1, 1, "\r1.\w Subir habilidad");
	}

	oldmenu_additem(8, 8, "\r8.\w Aumentar de a \y%d punto%s\w^n", iHabPoints, ((iHabPoints != 1) ? "s" : ""));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__HabInfo(const id, const item) {
	if(!item) {
		showMenu__Habs(id);
		return;
	}

	new iHabPoints = g_MenuData_HabPoints[id];
	new iHabId = g_MenuData_HabId[id];

	switch(item) {
		case 1: {
			if(g_WaveInProgress) {
				clientPrintColor(id, _, "No puedes subir tus habilidades mientras hay una oleada en marcha.");

				showMenu__HabInfo(id);
				return;
			}

			if((g_Points[id] - iHabPoints) < 0) {
				clientPrintColor(id, _, "No tienes suficientes puntos.");

				showMenu__HabInfo(id);
				return;
			}

			if((g_Hab[id][iHabId] + iHabPoints) > __HABS[iHabId][habMaxLevel]) {
				clientPrintColor(id, _, "La suma de los puntos invertidos en esta habilidad superarían el límite, reduce la cantidad de puntos.");

				showMenu__HabInfo(id);
				return;
			}

			g_Points[id] -= iHabPoints;
			g_Hab[id][iHabId] += iHabPoints;
			
			g_HabCache[id][_:HAB_F_DAMAGE] = (float(g_Hab[id][HAB_DAMAGE]) * __HABS[HAB_DAMAGE][habValue]);
			g_HabCache[id][_:HAB_F_PRECISION] = (float(g_Hab[id][HAB_PRECISION]) * __HABS[HAB_PRECISION][habValue]);
			g_HabCache[id][_:HAB_F_SPEED_WEAPON] = (float(g_Hab[id][HAB_SPEED_WEAPON]) * __HABS[HAB_SPEED_WEAPON][habValue]);
			g_HabCacheClip[id] = (g_Hab[id][HAB_BULLETS] * floatround(__HABS[HAB_BULLETS][habValue]));
		} case 8: {
			switch(iHabPoints) {
				case 1: {
					g_MenuData_HabPoints[id] = 5;
				} case 5: {
					g_MenuData_HabPoints[id] = 10;
				} case 10: {
					g_MenuData_HabPoints[id] = 1;
				}
			}
		}
	}

	showMenu__HabInfo(id);
}

showMenu__AchievementClasses(const id) {
	SetGlobalTransTarget(id);

	new iMenuId;
	new sPosition[3];
	
	iMenuId = menu_create(fmt("\yLOGROS^n\wLogros completados\r:\y %d\R", g_AchievementTotal[id]), "@menu__AchievementClasses");
	
	for(new i = 0; i < structIdAchievementClasses; ++i) {
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, __ACHIEVEMENT_CLASSES[i][achievementClassName], sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	g_MenuPage_AchievementClasses[id] = min(g_MenuPage_AchievementClasses[id], (menu_pages(iMenuId) - 1));
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_AchievementClasses[id]);
}

@menu__AchievementClasses(const id, const menu, const item) {
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
	
	iItemId = sPosition[0];
	g_MenuData_AchievementClassId[id] = iItemId;

	showMenu__Achievements(id);
	return PLUGIN_HANDLED;
}

showMenu__Achievements(const id) {
	new iAchievementClassId = g_MenuData_AchievementClassId[id];
	new iMenuId;
	new k = 0;
	new j = 0;
	new sItem[64];
	new sPosition[4];

	iMenuId = menu_create(fmt("\yLOGROS %s^n\wLogros completados\r:\y %d\R", __ACHIEVEMENT_CLASSES[iAchievementClassId][achievementClassNameIn], checkAchievementTotal(id, iAchievementClassId)), "@menu__Achievements");
	
	for(new i = 0; i < structIdAchievements; ++i) {
		if(iAchievementClassId != __ACHIEVEMENTS[i][achievementClass]) {
			k++;
			continue;
		}
		
		++j;
		
		g_AchievementInt[id][(i - k)] = i;
		
		formatex(sItem, charsmax(sItem), "%s%s", ((!g_Achievement[id][i]) ? "\d" : "\w"), __ACHIEVEMENTS[i][achievementName]);

		num_to_str(j, sPosition, charsmax(sPosition));
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuData_AchievementClassIn[id] = iAchievementClassId;
	g_MenuPage_AchievementClassesIn[id][iAchievementClassId] = min(g_MenuPage_AchievementClassesIn[id][iAchievementClassId], (menu_pages(iMenuId) - 1));
	
	ShowLocalMenu(id, iMenuId, g_MenuPage_AchievementClassesIn[id][iAchievementClassId]);
}

@menu__Achievements(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	new iItemId;
	new iAchievementClassIn = g_MenuData_AchievementClassIn[id];
	
	player_menu_info(id, iItemId, iItemId, g_MenuPage_AchievementClassesIn[id][iAchievementClassIn]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__AchievementClasses(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[4];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);
	
	g_MenuData_AchievementId[id] = (str_to_num(sPosition) - 1);
	
	showMenu__AchievementInfo(id, g_AchievementInt[id][g_MenuData_AchievementId[id]]);
	return PLUGIN_HANDLED;
}

showMenu__AchievementInfo(const id, const achievement) {
	oldmenu_create("\y%s - %s", "@menu__AchievementInfo", __ACHIEVEMENTS[achievement][achievementName], ((!g_Achievement[id][achievement]) ? "\r(NO COMPLETADO)" : "\y(COMPLETADO)"));

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s", __ACHIEVEMENTS[achievement][achievementInfo]);

	if(__ACHIEVEMENTS[achievement][achievementUsersNeedP]) {
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d jugadores conectados", __ACHIEVEMENTS[achievement][achievementUsersNeedP]);
	} else if(__ACHIEVEMENTS[achievement][achievementUsersNeedA]) {
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d jugadores vivos", __ACHIEVEMENTS[achievement][achievementUsersNeedA]);
	}

	oldmenu_additem(-1, -1, "^n\yRECOMPENSA\r:");
	
	switch(__ACHIEVEMENTS[achievement][achievementReward]) {
		case 1337: {
			oldmenu_additem(-1, -1, "\r - \w Desbloquea el poder \yBalas Infinitas");
		} case 1338: {
			oldmenu_additem(-1, -1, "\r - \w Desbloquea el poder \yAimbot");
		} case 1339: {
			oldmenu_additem(-1, -1, "\r - \w Desbloquea la clase \yPistolero");
		} default: {
			oldmenu_additem(-1, -1, "\r - \y+%d\w Os", __ACHIEVEMENTS[achievement][achievementReward]);
		}
	}

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

	new iAchievementId = g_MenuData_AchievementId[id];

	switch(item) {
		case 1: {
			if(g_Achievement[id][g_AchievementInt[id][iAchievementId]]) {
				if(g_Atsul[id] || g_AchievementTimeLink[id] < get_gametime()) {
					g_AchievementTimeLink[id] = (get_gametime() + 15.0);
					clientPrintColor(0, _, "!t%n!y muestra su logro !g%s!y conseguido el !g%s!y", id, __ACHIEVEMENTS[g_AchievementInt[id][iAchievementId]][achievementName], getUnixToTime(g_AchievementUnlocked[id][g_AchievementInt[id][iAchievementId]]));
				}
			}

			showMenu__AchievementInfo(id, g_AchievementInt[id][iAchievementId]);
		}
	}
}

showMenu__Upgrades(const id, page) {
	SetGlobalTransTarget(id);

	new sOs[16];
	new iMaxPages;
	new iStart;
	new iEnd;
	new iCost;

	addDot(g_Os[id], sOs, charsmax(sOs));

	oldmenu_pages(iMaxPages, iStart, iEnd, page, structIdUpgrades, 3);
	oldmenu_create("\yMEJORAS \r[%d - %d]\y\R%d / %d^n\wOs\r:\y %s", "@menu__Upgrades", (iStart + 1), iEnd, page, iMaxPages, sOs);

	for(new i = iStart, j = 1; i < iEnd; ++i, ++j) {
		iCost = ((g_Upgrades[id][i] + 1) * __UPGRADES[i][upgradeCost]);

		if(g_Upgrades[id][i] < __UPGRADES[i][upgradeMaxLevel]) {
			if(g_Os[id] >= iCost) {
				oldmenu_additem(j, i, "\r%d.\w %s \y[%d / %d][Costo: %d]^n^t\r - \w%s^n", j, __UPGRADES[i][upgradeName], g_Upgrades[id][i], __UPGRADES[i][upgradeMaxLevel], iCost, __UPGRADES[i][upgradeDesc]);
			} else {
				oldmenu_additem(-1, -1, "\d%d. %s \r[%d / %d][Costo: %d]^n^t\r - \d%s^n", j, __UPGRADES[i][upgradeName], g_Upgrades[id][i], __UPGRADES[i][upgradeMaxLevel], iCost, __UPGRADES[i][upgradeDesc]);
			}
		} else {
			oldmenu_additem(-1, -1, "\d%d. %s \r[%d / %d][FULL]^n^t\r - \d%s^n", j, __UPGRADES[i][upgradeName], g_Upgrades[id][i], __UPGRADES[i][upgradeMaxLevel], __UPGRADES[i][upgradeDesc]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

@menu__Upgrades(const id, const item, const value, page) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage_Upgrade[id] = iNewPage;

		showMenu__Upgrades(id, iNewPage);
		return;
	}

	new iCost = (g_Upgrades[id][value] + 1) * __UPGRADES[value][upgradeCost];

	if(g_Os[id] >= iCost) {
		g_Os[id] -= iCost;
		g_OsLost[id] += iCost;
		
		++g_Upgrades[id][value];

		switch(value) {
			 case UPGRADE_CRITICAL: {
				g_CriticChance[id] = (g_Upgrades[id][UPGRADE_CRITICAL] * __UPGRADES[UPGRADE_CRITICAL][upgradeValue]);
			}
		}

		if(g_Upgrades[id][UPGRADE_UNLOCK_APOYO] && g_Upgrades[id][UPGRADE_UNLOCK_PESADO] && g_Upgrades[id][UPGRADE_UNLOCK_ASALTO] && g_Upgrades[id][UPGRADE_UNLOCK_COMANDANTE]) {
			setAchievement(id, COMPRADOR_COMPULSIVO);
		}
	}
}

showMenu__RequerimentsLevel(const id, const level) {
	g_MenuData_Level[id] = level;

	SetGlobalTransTarget(id);

	oldmenu_create("\yREQUERIMIENTOS DE NIVEL^n\wInformación del nivel\r:\y %d", "@menu__RequerimentsLevel", (level + 1));

	new sKills[16];
	new sReqKills[16];

	addDot(g_Kills[id], sKills, charsmax(sKills));
	addDot(__LEVELS[level][levelKills], sReqKills, charsmax(sReqKills));

	oldmenu_additem(-1, -1, "\r*\w Matados\r:%s %s \r/ \y%s", ((g_Kills[id] < __LEVELS[level][levelKills]) ? "\d" : "\y"), sKills, sReqKills);
	
	if(level < 25) {
		oldmenu_additem(-1, -1, "\r*\w Oleadas superadas\d (NORMAL)\r:%s %d \r/%s %d", ((g_WavesWins[id][DIFF_NORMAL][0] < __LEVELS[level][levelWaveNormal]) ? "\d" : "\y"), g_WavesWins[id][DIFF_NORMAL][0], ((g_WavesWins[id][DIFF_NORMAL][0] < __LEVELS[level][levelWaveNormal]) ? "\d" : "\y"), __LEVELS[level][levelWaveNormal]);
		
		if(__LEVELS[level][levelBossNormal]) {
			oldmenu_additem(-1, -1, "\r*\w Jefes matados\d (NORMAL)\r:%s %d \r/%s %d", ((g_BossKills[id][DIFF_NORMAL] < __LEVELS[level][levelBossNormal]) ? "\d" : "\y"), g_BossKills[id][DIFF_NORMAL], ((g_BossKills[id][DIFF_NORMAL] < __LEVELS[level][levelBossNormal]) ? "\d" : "\y"), __LEVELS[level][levelBossNormal]);
		}
	} else if(level < 50) {
		oldmenu_additem(-1, -1, "\r*\w Oleadas superadas\d (NIGHTMARE)\r:%s %d \r/%s %d", ((g_WavesWins[id][DIFF_NIGHTMARE][0] < __LEVELS[level][levelWaveNightmare]) ? "\d" : "\y"), g_WavesWins[id][DIFF_NIGHTMARE][0], ((g_WavesWins[id][DIFF_NIGHTMARE][0] < __LEVELS[level][levelWaveNightmare]) ? "\d" : "\y"), __LEVELS[level][levelWaveNightmare]);
		
		if(__LEVELS[level][levelBossNightmare]) {
			oldmenu_additem(-1, -1, "\r*\w Jefes matados\d (NIGHTMARE)\r:%s %d \r/%s %d", ((g_BossKills[id][DIFF_NIGHTMARE] < __LEVELS[level][levelBossNightmare]) ? "\d" : "\y"), g_BossKills[id][DIFF_NIGHTMARE], ((g_BossKills[id][DIFF_NIGHTMARE] < __LEVELS[level][levelBossNightmare]) ? "\d" : "\y"), __LEVELS[level][levelBossNightmare]);
		}
	} else if(level < 75) {
		oldmenu_additem(-1, -1, "\r*\w Oleadas superadas\d (SUICIDAL)\r:%s %d \r/%s %d", ((g_WavesWins[id][DIFF_SUICIDAL][0] < __LEVELS[level][levelWaveSuicidal]) ? "\d" : "\y"), g_WavesWins[id][DIFF_SUICIDAL][0], ((g_WavesWins[id][DIFF_SUICIDAL][0] < __LEVELS[level][levelWaveSuicidal]) ? "\d" : "\y"), __LEVELS[level][levelWaveSuicidal]);
		
		if(__LEVELS[level][levelBossSuicidal]) {
			oldmenu_additem(-1, -1, "\r*\w Jefes matados\d (SUICIDAL)\r:%s %d \r/%s %d", ((g_BossKills[id][DIFF_SUICIDAL] < __LEVELS[level][levelBossSuicidal]) ? "\d" : "\y"), g_BossKills[id][DIFF_SUICIDAL], ((g_BossKills[id][DIFF_SUICIDAL] < __LEVELS[level][levelBossSuicidal]) ? "\d" : "\y"), __LEVELS[level][levelBossSuicidal]);
		}
	} else {
		oldmenu_additem(-1, -1, "\r*\w Oleadas superadas\d (HELL)\r:%s %d \r/%s %d", ((g_WavesWins[id][DIFF_HELL][0] < __LEVELS[level][levelWaveHell]) ? "\d" : "\y"), g_WavesWins[id][DIFF_HELL][0], ((g_WavesWins[id][DIFF_HELL][0] < __LEVELS[level][levelWaveHell]) ? "\d" : "\y"), __LEVELS[level][levelWaveHell]);
		
		if(__LEVELS[level][levelBossHell]) {
			oldmenu_additem(-1, -1, "\r*\w Jefes matados\d (HELL)\r:%s %d \r/%s %d", ((g_BossKills[id][DIFF_HELL] < __LEVELS[level][levelBossHell]) ? "\d" : "\y"), g_BossKills[id][DIFF_HELL], ((g_BossKills[id][DIFF_HELL] < __LEVELS[level][levelBossHell]) ? "\d" : "\y"), __LEVELS[level][levelBossHell]);
		}
	}

	oldmenu_additem(-1, -1, "");

	if(g_Level[id] == level) {
		oldmenu_additem(1, 1, "\r1.\w Ver otros niveles");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__RequerimentsLevel(const id, const item) {
	new iLevel = g_MenuData_Level[id];

	if(!item) {
		if(iLevel == g_Level[id]) {
			showMenu__Game(id);
		} else {
			showMenu__RequerimentsOtherLevel(id);
		}

		return;
	}

	switch(item) {
		case 1: {
			if(g_Level[id] == iLevel) {
				showMenu__RequerimentsOtherLevel(id);
			}
		}
	}
}

showMenu__RequerimentsOtherLevel(const id) {
	SetGlobalTransTarget(id);

	new iMenuId;
	new sItem[32];
	new sPosition[2];
	
	iMenuId = menu_create("\yLISTA DE NIVELES\R", "@menu__RequerimentsOtherLevel");
	
	for(new i = 0; i < 100; ++i) {
		formatex(sItem, charsmax(sItem), "%sNivel\r:%s %d", ((g_Level[id] > i) ? "\w" : "\d"), ((g_Level[id] > i) ? "\y" : "\d"), (i + 1));
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	g_MenuPage_Level[id] = min(g_MenuPage_Level[id], (menu_pages(iMenuId) - 1));
	
	if(!g_MenuPage_Level[id]) {
		g_MenuPage_Level[id] = (g_Level[id] / 7);
	}
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage_Level[id]);
}

@menu__RequerimentsOtherLevel(const id, const menu, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Level[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__RequerimentsLevel(id, g_Level[id]);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	showMenu__RequerimentsLevel(id, sPosition[0]);
	return PLUGIN_HANDLED;
}

showMenu__Stats(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yESTADÍSTICAS", "@menu__Stats");

	new sKills[16];
	new sGold[16];
	new sWinMVP[16];

	addDot(g_Kills[id], sKills, charsmax(sKills));
	oldmenu_additem(-1, -1, "\wMatados\r:\y %s", sKills);

	addDot(g_GoldGaben[id], sGold, charsmax(sGold));
	oldmenu_additem(-1, -1, "\wOro ganado\r:\y %s", sGold);

	addDot(g_WinMVPGaben[id], sWinMVP, charsmax(sWinMVP));
	oldmenu_additem(-1, -1, "\wMVP ganados\r:\y %s^n", sWinMVP);

	oldmenu_additem(1, 1, "\r1.\w Ver top15");
	oldmenu_additem(2, 2, "\r2.\w Ver tutorial^n");

	new sBuffer[2][32];

	if(g_TimePlayed[id][TIME_DAY] >= 1) {
		formatex(sBuffer[0], charsmax(sBuffer[]), "\y%d\w día%s", g_TimePlayed[id][TIME_DAY], ((g_TimePlayed[id][TIME_DAY] != 1) ? "s" : ""));
	}

	if(g_TimePlayed[id][TIME_HOUR] >= 1) {
		formatex(sBuffer[1], charsmax(sBuffer[]), "\y%d\w hora%s", g_TimePlayed[id][TIME_HOUR], ((g_TimePlayed[id][TIME_HOUR] != 1) ? "s" : ""));
	}

	oldmenu_additem(-1, -1, "\yTIEMPO JUGADO\r:\w");
	oldmenu_additem(-1, -1, "\w%s%s%s^n", sBuffer[0], ((sBuffer[0][0] && sBuffer[1][0]) ? " con " : ""), sBuffer[1]);

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
			clientPrintColor(id, _, "Para ver los top de este servidor, visita la siguiente sección: !thttps://www.drunkgaming.net/servidores/19-tower-defense/!y.");
			showMenu__Stats(id);
		} case 2: {
			showMenu__Tutorial(id, 0);
		}
	}
}

showMenu__UserOptions(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yOPCIONES DE USUARIO", "@menu__UserOptions");

	oldmenu_additem(1, 1, "\r1.\w HUD General");
	oldmenu_additem(2, 2, "\r2.\w Calidad / Rendimiento^n");

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
			showMenu__UserOptionsHud(id);
		} case 2: {
			showMenu__UserOptionsFps(id);
		}
	}
}

showMenu__UserOptionsHud(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yHUD GENERAL", "@menu__UserOptionsHud");

	oldmenu_additem(1, 1, "\r1.\w Elegir colores");
	oldmenu_additem(2, 2, "\r2.\w Mover HUD^n");

	oldmenu_additem(3, 3, "\r3.\w Efecto de HUD\r:\y %s", ((!g_UserOption_HudEffect[id]) ? "DESHABILITADO" : "HABILITADO"));
	oldmenu_additem(4, 4, "\r4.\w Progreso de tu Clase actual\r:\y %s", ((!g_UserOption_HudProgressClass[id]) ? "DESHABILITADO" : "HABILITADO"));
	oldmenu_additem(5, 5, "\r5.\w Matados en Oleada actuall\r:\y %s^n", ((!g_UserOption_HudKillsPerWave[id]) ? "DESHABILITADO" : "HABILITADO"));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__UserOptionsHud(const id, const item) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_MenuPage_HudColor[id] < 1) {
				g_MenuPage_HudColor[id] = 1;
			}

			showMenu__UserOptionsHudColor(id, g_MenuPage_HudColor[id]);
		} case 2: {
			showMenu__UserOptionsHudPosition(id);
		} case 3: {
			if(g_UserOption_HudColor[id][__R] == 255 && g_UserOption_HudColor[id][__G] == 255 && g_UserOption_HudColor[id][__B] == 255) {
				clientPrintColor(id, _, "No puedes habilitar el efecto del HUD si el color del HUD es blanco.");
			} else {
				g_UserOption_HudEffect[id] = !g_UserOption_HudEffect[id];
			}
			
			showMenu__UserOptionsHud(id);
		} case 4: {
			g_UserOption_HudProgressClass[id] = !g_UserOption_HudProgressClass[id];
			showMenu__UserOptionsHud(id);
		} case 5: {
			g_UserOption_HudKillsPerWave[id] = !g_UserOption_HudKillsPerWave[id];
			showMenu__UserOptionsHud(id);
		}
	}
}

showMenu__UserOptionsHudColor(const id, page) {
	SetGlobalTransTarget(id);

	new iMaxPages;
	new iStart;
	new iEnd;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__COLORS));
	oldmenu_create("\yELEGIR COLORES \r[%d - %d]\y\R%d / %d", "@menu__UserOptionsHudColor", (iStart + 1), iEnd, page, iMaxPages);

	for(new i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_UserOption_HudColor[id][0] == __COLORS[i][colorRed] && g_UserOption_HudColor[id][1] == __COLORS[i][colorGreen] && g_UserOption_HudColor[id][2] == __COLORS[i][colorBlue]) {
			oldmenu_additem(-1, -1, "\d%d. %s \y(ACTUAL)", j, __COLORS[i][colorName]);
		} else {
			oldmenu_additem(j, i, "\r%d.\w %s", j, __COLORS[i][colorName]);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

@menu__UserOptionsHudColor(const id, const item, const value, page) {
	if(!item) {
		showMenu__UserOptionsHud(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage_HudColor[id] = iNewPage;

		showMenu__UserOptionsHudColor(id, iNewPage);
		return;
	}

	g_UserOption_HudColor[id][0] = __COLORS[value][colorRed];
	g_UserOption_HudColor[id][1] = __COLORS[value][colorGreen];
	g_UserOption_HudColor[id][2] = __COLORS[value][colorBlue];

	showMenu__UserOptionsHudColor(id, g_MenuPage_HudColor[id]);
}

showMenu__UserOptionsHudPosition(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yMOVER HUD", "@menu__UserOptionsHudPosition");

	oldmenu_additem(1, 1, "\r1.\w Mover hacia arriba");
	oldmenu_additem(2, 2, "\r2.\w Mover hacia abajo^n");
	
	if(g_UserOption_HudPosition[id][2] != 1.0) {
		oldmenu_additem(3, 3, "\r3.\w Mover hacia la izquierda");
		oldmenu_additem(4, 4, "\r4.\w Mover hacia la derecha^n");
	}
	
	oldmenu_additem(5, 5, "\r5.\w HUD alineado %s^n", ((g_UserOption_HudPosition[id][2] == 0.0) ? "a la izquierda" : ((g_UserOption_HudPosition[id][2] == 1.0) ? "al centro" : "a la derecha")));
	
	oldmenu_additem(9, 9, "\r9.\w Reiniciar posición");
	oldmenu_additem(0, 0, "\r0.\w Volver");

	oldmenu_display(id);
}

@menu__UserOptionsHudPosition(const id, const item) {
	if(!item) {
		showMenu__UserOptionsHud(id);
		return;
	}

	switch(item) {
		case 1: {
			g_UserOption_HudPosition[id][1] -= 0.01;
		} case 2: {
			g_UserOption_HudPosition[id][1] += 0.01;
		} case 3: {
			g_UserOption_HudPosition[id][0] -= 0.01;
		} case 4: {
			g_UserOption_HudPosition[id][0] += 0.01;
		} case 5: {
			switch(g_UserOption_HudPosition[id][2]) {
				case 0.0: {
					g_UserOption_HudPosition[id][0] = -1.0;
					g_UserOption_HudPosition[id][2] = 1.0;
				} case 1.0: {
					g_UserOption_HudPosition[id][0] = 1.5;
					g_UserOption_HudPosition[id][2] = 2.0;
				} case 2.0: {
					g_UserOption_HudPosition[id][0] = 0.0;
					g_UserOption_HudPosition[id][2] = 0.0;
				}
			}
		} case 9: {
			g_UserOption_HudPosition[id] = Float:{0.02, 0.15, 0.0};
		}
	}

	showMenu__UserOptionsHudPosition(id);
}

showMenu__UserOptionsFps(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yCALIDAD / RENDIMIENTO^n\wAcá podrás sacrificar calidad para ganar FPS", "@menu__UserOptionsFps");

	oldmenu_additem(1, 1, "\r1.\w Model Zombie\r:\y %s", ((!g_UserOption_LowFpsModels[id]) ? "ACTIVADO" : "DESACTIVADO"));
	oldmenu_additem(-1, -1, "\r - \wActualmente mejora\r:\y %s^n", ((!g_UserOption_LowFpsModels[id]) ? "la calidad" : "tus FPS"));

	oldmenu_additem(2, 2, "\r2.\w Brillo Zombie\r:\y %s", ((!g_UserOption_LowFpsGlow[id]) ? "ACTIVADO" : "DESACTIVADO"));
	oldmenu_additem(-1, -1, "\r - \wActualmente mejora\r:\y %s^n", ((!g_UserOption_LowFpsGlow[id]) ? "la calidad" : "tus FPS"));

	oldmenu_additem(3, 3, "\r3.\w Torretas invisibles\r:\y %s", ((!g_UserOption_LowFpsSentries[id]) ? "NO" : "SI"));
	oldmenu_additem(-1, -1, "\r - \wActualmente mejora\r:\y %s^n", ((!g_UserOption_LowFpsSentries[id]) ? "la calidad" : "tus FPS"));

	oldmenu_additem(4, 4, "\r4.\w Zombies desaparecen al morir\r:\y %s", ((!g_UserOption_LowFpsZombieDead[id]) ? "NO" : "SI"));
	oldmenu_additem(-1, -1, "\r - \wActualmente mejora\r:\y %s^n", ((!g_UserOption_LowFpsZombieDead[id]) ? "la calidad" : "tus FPS"));

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__UserOptionsFps(const id, const item) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	switch(item) {
		case 1: {
			g_UserOption_LowFpsModels[id] = !g_UserOption_LowFpsModels[id];

			if(g_UserOption_LowFpsModels[id]) {
				clientPrintColor(id, _, "Todos los zombies excepto algunos deberían tener modelo de terrorista para aumentar tus FPS.");
			} else {
				clientPrintColor(id, _, "Todos los zombies vuelven a tener su modelo por defecto.");
			}
		} case 2: {
			g_UserOption_LowFpsGlow[id] = !g_UserOption_LowFpsGlow[id];

			if(g_UserOption_LowFpsGlow[id]) {
				clientPrintColor(id, _, "");
				clientPrintColor(id, _, "Todos los zombies excepto algunos ya no deberían tener brillo para aumentar tus FPS.");
				clientPrintColor(id, _, "Te recordamos que sin el brillo, no podrás ver a los zombies afectados por la Ión, ni aquellos con protección o doble daño.");
			} else {
				clientPrintColor(id, _, "Todos los zombies vuelven a tener su brillo por defecto.");
			}
		} case 3: {
			g_UserOption_LowFpsSentries[id] = !g_UserOption_LowFpsSentries[id];

			if(g_UserOption_LowFpsSentries[id]) {
				clientPrintColor(id, _, "");
				clientPrintColor(id, _, "Todas las torretas ahora son invisibles para aumentar tus FPS.");
				clientPrintColor(id, _, "Aquellas torretas sin dueño o sin balas volverán a aparecer para que puedas notarlo.");
			} else {
				clientPrintColor(id, _, "Todas las torretas vuelven a ser visibles.");
			}
		} case 4: {
			g_UserOption_LowFpsZombieDead[id] = !g_UserOption_LowFpsZombieDead[id];

			if(g_UserOption_LowFpsZombieDead[id]) {
				clientPrintColor(id, _, "Cuando mueran los zombies desapareceran instantáneamente para aumentar tus FPS.");
			} else {
				clientPrintColor(id, _, "Todos los zombies vuelven a desaparecer normalmente.");
			}
		}
	}

	showMenu__UserOptionsFps(id);
}

showMenu__Shop(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yHOLA, \w%n^n¿Qué necesitas?", "@menu__Shop", id);

	oldmenu_additem(1, 1, "\r1.\w Armas");
	oldmenu_additem(2, 2, "\r2.\w Granadas");
	oldmenu_additem(3, 3, "\r3.\w Otros");
	oldmenu_additem(4, 4, "\r4.\w Poderes^n");

	oldmenu_additem(5, 5, "\r5.\w Recargar armas \y(10 oro)^n");

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

@menu__Shop(const id, const item) {
	if(!item) {
		return;
	} if(!checkDistanceFromEvas(id)) {
		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return;
	}

	switch(item) {
		case 1: {
			showMenu__ShopWeapons(id);
		} case 2: {
			showMenu__ShopGrenades(id);
		} case 3: {
			showMenu__ShopOthers(id);
		} case 4: {
			showMenu__ShopPowers(id);
		} case 5: {
			if((g_Gold[id] - 10) < 0) {
				clientPrintColor(id, _, "Lo siento, pero necesitas más oro para recargar tus armas.");
				return;
			}

			new Float:flGameTime = (g_NoReload[id] - get_gametime());
			
			if(flGameTime > 0.0) {
				clientPrintColor(id, _, "Oye oye, despacio cerebrito, tienes que esperar !g%0.2f segundos!y para volver a recargar tus armas.", flGameTime);
				return;
			}
			
			reloadWeapons(id);
		}
	}
}

showMenu__ShopWeapons(const id) {
	if(g_WaveInProgress) {
		clientPrintColor(id, _, "No puedo venderte armas mientras hay una oleada en marcha.");
		return;
	} else if(!checkDistanceFromEvas(id)) {
		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return;
	}

	SetGlobalTransTarget(id);

	new iMenuId;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("\yARMAS^n\wEstas son las armas que tengo:\y\R", "@menu__ShopWeapons");
	
	for(new i = 0; i < (sizeof(__WEAPON_NAMES) - 1); ++i) {
		if(__WEAPON_NAMES[i][weaponClassRecommended] == g_ClassId[id]) {
			formatex(sItem, charsmax(sItem), "%s%s %s[%d Oro] \r *", ((g_Gold[id] >= __WEAPON_NAMES[i][weaponGold]) ? "\w" : "\d"), __WEAPON_NAMES[i][weaponName], ((g_Gold[id] >= __WEAPON_NAMES[i][weaponGold]) ? "\y" : "\d"), __WEAPON_NAMES[i][weaponGold]);
		} else {
			formatex(sItem, charsmax(sItem), "%s%s %s[%d Oro]", ((g_Gold[id] >= __WEAPON_NAMES[i][weaponGold]) ? "\w" : "\d"), __WEAPON_NAMES[i][weaponName], ((g_Gold[id] >= __WEAPON_NAMES[i][weaponGold]) ? "\y" : "\d"), __WEAPON_NAMES[i][weaponGold]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

@menu__ShopWeapons(const id, const menu, const item) {
	if(g_WaveInProgress) {
		DestroyLocalMenu(id, menu);

		clientPrintColor(id, _, "No puedo venderte armas mientras hay una oleada en marcha.");
		return PLUGIN_HANDLED;
	}

	if(!checkDistanceFromEvas(id)) {
		DestroyLocalMenu(id, menu);

		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return PLUGIN_HANDLED;
	}

	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	new iItemId;
	new iCost;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	iCost = __WEAPON_NAMES[iItemId][weaponGold];

	if((g_Gold[id] - iCost) < 0) {
		clientPrintColor(id, _, "Lo siento, pero necesitas más oro para comprar !g%s!y.", __WEAPON_NAMES[iItemId][weaponName]);
		
		showMenu__ShopWeapons(id);
		return PLUGIN_HANDLED;
	}
	
	if(user_has_weapon(id, _:__WEAPON_NAMES[iItemId][weaponId])) {
		clientPrintColor(id, _, "Ya tienes el arma seleccionada (!g%s!y).", __WEAPON_NAMES[iItemId][weaponName]);
		
		showMenu__ShopWeapons(id);
		return PLUGIN_HANDLED;
	}

	if(__WEAPON_NAMES[iItemId][weaponVIP] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
		clientPrintColor(id, _, "Necesitas ser VIP para poder utilizar esta arma.");
		
		showMenu__ShopWeapons(id);
		return PLUGIN_HANDLED;
	}
	
	g_Gold[id] -= iCost;
	
	rg_give_item(id, __WEAPON_NAMES[iItemId][weaponEnt]);
	rg_set_user_bpammo(id, __WEAPON_NAMES[iItemId][weaponId], 200);

	clientPrintColor(id, _, "Compraste !g%s!y.", __WEAPON_NAMES[iItemId][weaponName]);

	showMenu__ShopWeapons(id);
	return PLUGIN_HANDLED;
}

showMenu__ShopGrenades(const id) {
	if(g_Wave >= MAX_WAVES) {
		clientPrintColor(id, _, "No puedes comprar granadas en este punto.");
		return;
	} else if(g_WaveInProgress) {
		clientPrintColor(id, _, "No puedo venderte granadas mientras hay una oleada en marcha.");
		return;
	} else if(!checkDistanceFromEvas(id)) {
		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return;
	}

	SetGlobalTransTarget(id);

	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("\yGRANADAS^n\wEstas son las granadas que tengo:\y\R", "@menu__ShopGrenades");
	
	for(i = 0; i < sizeof(__GRENADES_NAMES); ++i) {
		if(__GRENADES_NAMES[i][weaponLimit] != -1 && g_Grenades_Used[i] >= __GRENADES_NAMES[i][weaponLimit]) {
			formatex(sItem, charsmax(sItem), "\d%s \r[Limitado por mapa]", __GRENADES_NAMES[i][weaponName]);
		} else {
			if(__GRENADES_NAMES[i][weaponLimitUser] != -1 && g_Grenades_UsedByPlayer[id][i] >= __GRENADES_NAMES[i][weaponLimitUser]) {
				formatex(sItem, charsmax(sItem), "\d%s \r[Limitado por jugador]", __GRENADES_NAMES[i][weaponName]);
			} else {
				if(__GRENADES_NAMES[i][weaponLevelReq] != -1 && g_Level[id] >= __GRENADES_NAMES[i][weaponLevelReq]) {
					formatex(sItem, charsmax(sItem), "\d%s \r[LV: %d]", __GRENADES_NAMES[i][weaponName], __GRENADES_NAMES[i][weaponLevelReq]);
				} else {
					if(g_Gold[id] >= __GRENADES_NAMES[i][weaponGold]) {
						formatex(sItem, charsmax(sItem), "\w%s \y[%d Oro]", __GRENADES_NAMES[i][weaponName], __GRENADES_NAMES[i][weaponGold]);
					} else {
						formatex(sItem, charsmax(sItem), "\d%s \r[%d Oro]", __GRENADES_NAMES[i][weaponName], __GRENADES_NAMES[i][weaponGold]);
					}
				}
			}
		}
		
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

@menu__ShopGrenades(const id, const menu, const item) {
	if(g_Wave >= MAX_WAVES) {
		DestroyLocalMenu(id, menu);

		clientPrintColor(id, _, "No puedes comprar granadas en este punto.");
		return PLUGIN_HANDLED;
	}

	if(g_WaveInProgress) {
		DestroyLocalMenu(id, menu);

		clientPrintColor(id, _, "No puedo venderte armas mientras hay una oleada en marcha.");
		return PLUGIN_HANDLED;
	}

	if(!checkDistanceFromEvas(id)) {
		DestroyLocalMenu(id, menu);

		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return PLUGIN_HANDLED;
	}

	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	new iItemId;
	new iCost;
	
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(__GRENADES_NAMES[iItemId][weaponLimit] != -1 && g_Grenades_Used[iItemId] >= __GRENADES_NAMES[iItemId][weaponLimit]) {
		clientPrintColor(id, _, "Se ha superado el límite por mapa (!g%s!y) de la granada !g%s!y.", __GRENADES_NAMES[iItemId][weaponLimit], __GRENADES_NAMES[iItemId][weaponName]);

		showMenu__ShopGrenades(id);
		return PLUGIN_HANDLED;
	}

	if(__GRENADES_NAMES[iItemId][weaponLimitUser] != -1 && g_Grenades_UsedByPlayer[id][iItemId] >= __GRENADES_NAMES[iItemId][weaponLimitUser]) {
		clientPrintColor(id, _, "Se ha superado el límite por jugador (!g%s!y) de la granada !g%s!y.", __GRENADES_NAMES[iItemId][weaponLimitUser], __GRENADES_NAMES[iItemId][weaponName]);

		showMenu__ShopGrenades(id);
		return PLUGIN_HANDLED;
	}

	if(__GRENADES_NAMES[iItemId][weaponLevelReq] != -1 && g_Level[id] < __GRENADES_NAMES[iItemId][weaponLevelReq]) {
		clientPrintColor(id, _, "Lo siento, pero necesitas ser !gnivel %d!y para comprar !g%s!y.", __GRENADES_NAMES[iItemId][weaponLevelReq], __GRENADES_NAMES[iItemId][weaponName]);

		showMenu__ShopGrenades(id);
		return PLUGIN_HANDLED;
	}

	iCost = __GRENADES_NAMES[iItemId][weaponGold];

	if((g_Gold[id] - iCost) < 0) {
		clientPrintColor(id, _, "Lo siento, pero necesitas más oro para comprar !g%s!y.", __GRENADES_NAMES[iItemId][weaponName]);

		showMenu__ShopGrenades(id);
		return PLUGIN_HANDLED;
	}
	
	g_Gold[id] -= iCost;
	
	if(user_has_weapon(id, _:__GRENADES_NAMES[iItemId][weaponId])) {
		rg_set_user_bpammo(id, __GRENADES_NAMES[iItemId][weaponId], (rg_get_user_bpammo(id, __GRENADES_NAMES[iItemId][weaponId]) + 1));
	} else {
		rg_give_item(id, __GRENADES_NAMES[iItemId][weaponEnt]);
	}
	
	++g_Nades[id][iItemId];
	++g_Grenades_UsedByPlayer[id][iItemId];
	++g_Grenades_Used[iItemId];
	
	clientPrintColor(id, _, "Compraste !g%s!y.", __GRENADES_NAMES[iItemId][weaponName]);
	
	showMenu__ShopGrenades(id);
	return PLUGIN_HANDLED;
}

showMenu__ShopOthers(const id) {
	if(g_Wave >= MAX_WAVES) {
		clientPrintColor(id, _, "No puedes comprar otros productos en este punto.");
		return;
	} else if(g_WaveInProgress) {
		clientPrintColor(id, _, "No puedo venderte otros productos mientras hay una oleada en marcha.");
		return;
	} else if(!checkDistanceFromEvas(id)) {
		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return;
	}

	SetGlobalTransTarget(id);

	oldmenu_create("\yOTROS^n\wEstos son otras de las cosas que tengo\r:", "@menu__ShopOthers");

	if(g_SentryCountTotal < __MAPS[g_MapId][mapLimitSentries]) {
		if(g_Gold[id] >= SENTRY_COST) {
			oldmenu_additem(1, 1, "\r1.\w Torreta");
		} else {
			oldmenu_additem(-1, -1, "\d1. Torreta \r[%d Oro]", SENTRY_COST);
		}
	} else {
		oldmenu_additem(-1, -1, "\d1. Torreta \r[Limitado]");
	}

	if(g_RobotCountTotal < __MAPS[g_MapId][mapLimitRobots]) {
		if(g_Gold[id] >= ROBOT_COST) {
			oldmenu_additem(2, 2, "\r2.\w Robot");
		} else {
			oldmenu_additem(-1, -1, "\d2. Robot \r[%d Oro]", ROBOT_COST);
		}
	} else {
		oldmenu_additem(-1, -1, "\d2. Robot \r[Limitado]");
	}

	if(g_Sentry[id] || g_Robot[id]) {
		oldmenu_additem(-1, -1, "");

		if(g_Sentry[id]) {
			oldmenu_additem(4, 4, "\r4.\w Vender \y%d torreta%s\w por \y%d Oro\w", g_Sentry[id], ((g_Sentry[id] != 1) ? "s" : ""), (g_Sentry[id] * SENTRY_COST));
		} else if(g_Robot[id]) {
			oldmenu_additem(5, 5, "\r5.\w Vender \y%d robot%s\w por \y%d Oro\w", g_Robot[id], ((g_Robot[id] != 1) ? "s" : ""), (g_Robot[id] * ROBOT_COST));
		}
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

@menu__ShopOthers(const id, const item, const value) {
	if(g_Wave >= MAX_WAVES) {
		clientPrintColor(id, _, "No puedes comprar otros productos en este punto.");
		return;
	} else if(g_WaveInProgress) {
		clientPrintColor(id, _, "No puedo venderte otros productos mientras hay una oleada en marcha.");
		return;
	} else if(!checkDistanceFromEvas(id)) {
		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return;
	} else if(!item) {
		showMenu__Shop(id);
		return;
	}

	switch(item) {
		case 1: { // TORRETA
			g_Gold[id] -= SENTRY_COST;
			++g_Sentry[id];

			clientPrintColor(id, _, "Compraste !g1 Torreta!y.");
		} case 2: { // ROBOT
			if(g_Atsul[id]) {
				g_Gold[id] -= ROBOT_COST;
				++g_Robot[id];

				clientPrintColor(id, _, "Compraste !g1 Robot!y.");
			} else {
				clientPrintColor(id, _, "Lo siento, este producto está retenido en la aduana, vuelve en unos días e intentalo nuevamente.");
			}
		} case 4: { // VENDER TORRETA
			new iSentry = g_Sentry[id];
			new iReward = (iSentry * SENTRY_COST);
			
			g_Gold[id] += iReward;
			g_Sentry[id] = 0;
			
			clientPrintColor(id, _, "Recibiste !g%d Oro!y por vender tu%s torreta%s.", iReward, ((iSentry != 1) ? "s" : ""), ((iSentry != 1) ? "s" : ""));
		} case 5: { // VENDER ROBOT
			if(g_Atsul[id]) {
				new iRobot = g_Robot[id];
				new iReward = (iRobot * ROBOT_COST);
				
				g_Gold[id] += iReward;
				g_Robot[id] = 0;
				
				clientPrintColor(id, _, "Recibiste !g%d Oro!y por vender tu%s robot%s.", iReward, ((iRobot != 1) ? "s" : ""), ((iRobot != 1) ? "s" : ""));
			}
		}
	}

	showMenu__ShopOthers(id);
}

showMenu__ShopPowers(const id) {
	SetGlobalTransTarget(id);

	if(g_Wave > MAX_WAVES || (g_Wave == MAX_WAVES && !g_WaveInProgress)) {
		clientPrintColor(id, _, "No puedes comprar poderes en este punto.");
		return;
	} else if(!checkDistanceFromEvas(id)) {
		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return;
	}
	
	new iMenuId;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("\yPODERES^n\wEstos son los poderes que tengo:", "@menu__ShopPowers");
	
	for(new i = 1; i < sizeof(__POWERS); ++i) {
		formatex(sItem, charsmax(sItem), "%s%s %s[%d Oro]", ((g_Gold[id] >= __POWERS[i][powerGold]) ? "\w" : "\d"), __POWERS[i][powerName], ((g_Gold[id] >= __POWERS[i][powerGold]) ? "\y" : "\d"), __POWERS[i][powerGold]);
		
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

@menu__ShopPowers(const id, const menu, const item) {
	if(g_Wave > MAX_WAVES || (g_Wave == MAX_WAVES && !g_WaveInProgress)) {
		DestroyLocalMenu(id, menu);
		
		clientPrintColor(id, _, "No puedes comprar poderes en este punto.");
		return PLUGIN_HANDLED;
	}

	if(!checkDistanceFromEvas(id)) {
		DestroyLocalMenu(id, menu);

		clientPrintColor(id, _, "Estás demasiado lejos, acercate para poder negociar.");
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[3];
	new iItemId;
	new iCost;

	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(iItemId == POWER_BALAS_INFINITAS) {
		if(!g_Achievement[id][BALAS_INFINITAS]) {
			clientPrintColor(id, _, "Necesitas desbloquear el logro !gPODER: BALAS INFINITAS!y antes de poder comprarlas.");

			showMenu__ShopPowers(id);
			return PLUGIN_HANDLED;
		}
	}
	
	iCost = __POWERS[iItemId][powerGold];

	if((g_Gold[id] - iCost) < 0) {
		clientPrintColor(id, _, "Lo siento, pero necesitás más oro para comprar !g%s!y.", __POWERS[iItemId][powerName]);

		showMenu__ShopPowers(id);
		return PLUGIN_HANDLED;
	}
	
	g_Gold[id] -= iCost;
	++g_Power[id][iItemId];
	
	clientPrintColor(id, _, "Compraste !g%s!y.", __POWERS[iItemId][powerName]);
	
	showMenu__ShopPowers(id);
	return PLUGIN_HANDLED;
}

showMenu__SentryAndRobot(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yTORRETAS Y ROBOTS", "@menu__SentryAndRobot");

	if(g_Sentry[id]) {
		oldmenu_additem(1, 1, "\r1.\w Construir torreta \y(%d)", g_Sentry[id]);
	} else {
		oldmenu_additem(-1, -1, "\d1. Construir torreta");
	}

	oldmenu_additem(2, 2, "\r2.\w Información de torreta^n");

	if(g_Robot[id]) {
		oldmenu_additem(3, 3, "\r3.\w Construir robot \y(%d)", g_Robot[id]);
	} else {
		oldmenu_additem(-1, -1, "\d3. Construir robot");
	}

	oldmenu_additem(4, 4, "\r4.\w Información de robot^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__SentryAndRobot(const id, const item) {
	if(!item) {
		return;
	}

	switch(item) {
		case 1: {
			if(g_WaveInProgress) {
				clientPrintColor(id, _, "No puedes construir una torreta mientras hay una oleada en marcha.");

				showMenu__SentryAndRobot(id);
				return;
			}

			sentryBuild(id);

			showMenu__SentryAndRobot(id);
		} case 2: {
			new iEntSentry = aimingAtSentry(id);

			if(iEntSentry) {
				g_MenuData_EntSentry[id] = iEntSentry;
				showMenu__SentryInfo(id);
			} else {
				clientPrintColor(id, _, "No estás apuntando a ninguna torreta.");
				showMenu__SentryAndRobot(id);
			}
		} case 3: {
			if(g_WaveInProgress) {
				clientPrintColor(id, _, "No puedes construir una torreta mientras hay una oleada en marcha.");

				showMenu__SentryAndRobot(id);
				return;
			}

			robotBuild(id);

			showMenu__SentryAndRobot(id);
		} case 4: {
			new iEntRobot = aimingAtRobot(id);

			if(iEntRobot) {
				g_MenuData_EntRobot[id] = iEntRobot;
				showMenu__RobotInfo(id);
			} else {
				clientPrintColor(id, _, "No estas apuntando a ningún robot.");
				showMenu__SentryAndRobot(id);
			}
		}
	}
}

showMenu__SentryInfo(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	new iEntSentry = g_MenuData_EntSentry[id];

	if(!is_valid_ent(iEntSentry)) {
		return;
	}

	SetGlobalTransTarget(id);

	new iOwner = entity_get_int(iEntSentry, SENTRY_OWNER);
	new iSentryLevel = clamp(entity_get_int(iEntSentry, SENTRY_INT_LEVEL), 1, 6);
	new iRatio = floatround(((__SENTRIES_HIT_RATIO[iSentryLevel] * 100.0) + entity_get_float(iEntSentry, SENTRY_EXTRA_RATIO)));
	new iMinDamage = __SENTRIES_DAMAGE[iSentryLevel][sentryMinDamage] + ((__SENTRIES_DAMAGE[iSentryLevel][sentryMinDamage] * floatround(entity_get_float(iEntSentry, SENTRY_EXTRA_DAMAGE))) / 100);
	new iMaxDamage = __SENTRIES_DAMAGE[iSentryLevel][sentryMaxDamage] + ((__SENTRIES_DAMAGE[iSentryLevel][sentryMaxDamage] * floatround(entity_get_float(iEntSentry, SENTRY_EXTRA_DAMAGE))) / 100);
	new iMaxClip = floatround(entity_get_float(iEntSentry, SENTRY_MAXCLIP));
	new iClip = floatround(entity_get_float(iEntSentry, SENTRY_CLIP));

	oldmenu_create("\yINFORMACIÓN DE TORRETA", "@menu__SentryInfo");

	oldmenu_additem(-1, -1, "\wDueño\r:\y %n", iOwner);
	oldmenu_additem(-1, -1, "\wNivel\r:\y %d", iSentryLevel);
	oldmenu_additem(-1, -1, "\wPrecisión\r:\y %d%%", iRatio);
	oldmenu_additem(-1, -1, "\wDaño por bala\r:\y %d a %d", iMinDamage, iMaxDamage);

	if(iMaxClip != 1000000) {
		oldmenu_additem(-1, -1, "\wBalas\r:\y %d / %d", iClip, iMaxClip);
	}

	if(g_Gold[id] >= __SENTRIES_UPGRADE_COST[(iSentryLevel - 1)]) {
		oldmenu_additem(1, 1, "^n\r1.\w Subir al nivel %d \y[%d Oro]", (iSentryLevel + 1), __SENTRIES_UPGRADE_COST[(iSentryLevel - 1)]);
	} else {
		oldmenu_additem(-1, -1, "^n\d1. Subir al nivel %d", (iSentryLevel + 1));
	}

	if(iMaxClip != 1000000) {
		oldmenu_additem(2, 2, "\r2.\w Recargar balas \y[10 Oro]");
	}

	if(!iOwner) {
		if(g_Gold[id] >= 100) {
			oldmenu_additem(3, 3, "^n\r3.\w Adueñarse de esta torreta \y[100 Oro]");
		} else {
			oldmenu_additem(-1, -1, "^n\d3. Adueñarse de esta torreta");
		}
	} else if(id == iOwner) {
		oldmenu_additem(4, 4, "^n\r4.\w Mover torreta");
		oldmenu_additem(5, 5, "\r5.\w Transferir dueño");
	}
	
	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

@menu__SentryInfo(const id, const item) {
	if(!item) {
		showMenu__SentryAndRobot(id);
		return;
	}

	new iEntSentry = g_MenuData_EntSentry[id];

	if(!is_valid_ent(iEntSentry)) {
		return;
	}

	switch(item) {
		case 1: {
			new iSentryLevel = clamp(entity_get_int(iEntSentry, SENTRY_INT_LEVEL), 1, 6);
			
			if(iSentryLevel < 6) {
				new iSentryLevelPlus1 = (iSentryLevel + 1);
				
				if(g_Gold[id] >= __SENTRIES_UPGRADE_COST[(iSentryLevel - 1)]) {
					if(iSentryLevel == 3 && (g_ClassId[id] != CLASS_INGENIERO || g_ClassLevel[id][g_ClassId[id]] < 5)) {
						clientPrintColor(id, _, "Solo los !tINGENIEROS!g nivel 5!y pueden subir a !gnivel %d!y las torretas.", iSentryLevelPlus1);
						
						showMenu__SentryInfo(id);
						return;
					} else if(iSentryLevel == 4 && (g_ClassId[id] != CLASS_INGENIERO || g_ClassLevel[id][g_ClassId[id]] < 6)) {
						clientPrintColor(id, _, "Solo los !tINGENIEROS!g nivel 6!y pueden subir a !gnivel %d!y las torretas.", iSentryLevelPlus1);
						
						showMenu__SentryInfo(id);
						return;
					} else if(iSentryLevel == 5) {
						new iOk = 1;

						if(g_ClassId[id] == CLASS_INGENIERO) {
							if(g_ClassLevel[id][CLASS_INGENIERO] < 6) {
								clientPrintColor(id, _, "Solo los !tINGENIEROS!g nivel 6!y pueden subir a !gnivel %d!y las torretas.", iSentryLevelPlus1);
								iOk = 0;
							}
						} else if(g_ClassId[id] == CLASS_FRANCOTIRADOR) {
							if(g_ClassLevel[id][CLASS_FRANCOTIRADOR] < 6) {
								clientPrintColor(id, _, "Solo los !tFRANCOTIRADORES!g nivel 6!y pueden subir a !gnivel %d!y las torretas.", iSentryLevelPlus1);
								iOk = 0;
							}
						} else {
							clientPrintColor(id, _, "Solo los !tINGENIEROS!g nivel 6!y y !tFRANCOTIRADORES!g nivel 6!y pueden subir a !gnivel %d!y las torretas.", iSentryLevelPlus1);
							iOk = 0;
						}

						if(iOk) {
							iOk = 0;

							new iLv6Part = entity_get_int(iEntSentry, EV_INT_flTimeStepSound);

							switch(iLv6Part) {
								case 0: {
									entity_set_int(iEntSentry, EV_INT_flTimeStepSound, g_ClassId[id]);

									if(g_ClassId[id] == CLASS_INGENIERO) {
										g_Gold[id] -= __SENTRIES_UPGRADE_COST[(iSentryLevel - 1)];

										clientPrintColor(id, _, "Bien, ahora solo falta la parte del francotirador.");
									} else {
										g_Gold[id] -= __SENTRIES_UPGRADE_COST[(iSentryLevel - 1)];

										clientPrintColor(id, _, "Bien, ahora solo falta la parte del ingeniero.");
									}
								} case CLASS_INGENIERO: {
									if(g_ClassId[id] != CLASS_FRANCOTIRADOR) {
										clientPrintColor(id, _, "La torreta ya fue subida por un ingeniero, falta la parte del francotirador.");
									} else {
										iOk = 1;

										register_think(__ENT_CLASSNAME_SENTRY_BASE, "@think__SentryBase");

										new iEntBase = entity_get_edict(iEntSentry, SENTRY_ENT_BASE);

										if(is_valid_ent(iEntBase)) {
											entity_set_float(iEntBase, EV_FL_nextthink, (get_gametime() + 60.0));
										}

										entity_set_int(iEntSentry, EV_INT_flTimeStepSound, 1337);
									}
								} case CLASS_FRANCOTIRADOR: {
									if(g_ClassId[id] != CLASS_INGENIERO) {
										clientPrintColor(id, _, "La torreta ya fue subida por un francotirador, falta la parte del ingeniero.");
									} else {
										iOk = 1;

										register_think(__ENT_CLASSNAME_SENTRY_BASE, "@think__SentryBase");

										new iEntBase = entity_get_edict(iEntSentry, SENTRY_ENT_BASE);

										if(is_valid_ent(iEntBase)) {
											entity_set_float(iEntBase, EV_FL_nextthink, (get_gametime() + 60.0));
										}

										entity_set_int(iEntSentry, EV_INT_flTimeStepSound, 1337);
									}
								}
							}
						}

						if(!iOk) {
							showMenu__SentryInfo(id);
							return;
						}
					}
					
					g_Gold[id] -= __SENTRIES_UPGRADE_COST[(iSentryLevel - 1)];
					entity_set_model(iEntSentry, __MODELS_SENTRY[iSentryLevel]);
					
					if(iSentryLevel == 3) {
						entity_set_int(iEntSentry, EV_INT_flTimeStepSound, 0);
						
						new iEntBase = entity_get_edict(iEntSentry, SENTRY_ENT_BASE);

						if(is_valid_ent(iEntBase)) {
							entity_set_model(iEntBase, __MODEL_SENTRY_BASE_4TO6);

							/*entity_set_int(iEntBase, EV_INT_rendermode, kRenderTransAlpha);
							entity_set_float(iEntBase, EV_FL_renderamt, 0.0);*/
						}

						/*new Float:vecOrigin[3];
						entity_get_vector(iEntSentry, EV_VEC_origin, vecOrigin);
						
						vecOrigin[2] -= 16.0;
						
						entity_set_vector(iEntSentry, EV_VEC_origin, vecOrigin);
						
						entity_set_byte(iEntSentry, SENTRY_TILT_LV4, 127);*/
					}
					
					entity_set_float(iEntSentry, SENTRY_EXTRA_DAMAGE, __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryDamage]);
					entity_set_float(iEntSentry, SENTRY_EXTRA_RATIO, __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryRecoil]);
					
					entity_set_size(iEntSentry, Float:{-16.0, -16.0, 0.0}, Float:{16.0, 16.0, 48.0});
					
					rh_emit_sound2(iEntSentry, 0, CHAN_AUTO, __SOUND_SENTRY_HEAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
					
					entity_set_int(iEntSentry, SENTRY_INT_LEVEL, iSentryLevelPlus1);
					
					clientPrintColor(id, _, "Has subido la torreta seleccionada al !gnivel %d!y.", iSentryLevelPlus1);
					
					if(g_Diff == DIFF_NORMAL) {
						entity_set_float(iEntSentry, SENTRY_MAXCLIP, 1000000.0);
					} else {
						entity_set_float(iEntSentry, SENTRY_MAXCLIP, (entity_get_float(iEntSentry, SENTRY_MAXCLIP) + float(__SENTRIES_MAXCLIP[iSentryLevelPlus1])));
					}
				} else {
					clientPrintColor(id, _, "No tenés oro suficiente para mejorar la torreta.");
				}
			} else {
				clientPrintColor(id, _, "La torreta seleccionada está en su nivel máximo.");
			}
		} case 2: {
			if(g_Diff != DIFF_NORMAL) {
				if(g_Gold[id] >= 10) {
					if(entity_get_int(iEntSentry, SENTRY_CLIP) != floatround(entity_get_float(iEntSentry, SENTRY_MAXCLIP))) {
						if(!entity_get_int(iEntSentry, SENTRY_CLIP)) {
							entity_set_float(iEntSentry, SENTRY_PARAM_01, 0.0);
							
							set_rendering(iEntSentry);
							
							entity_set_float(iEntSentry, EV_FL_nextthink, (get_gametime() + 0.01));
						}
						
						entity_set_int(iEntSentry, SENTRY_CLIP, floatround(entity_get_float(iEntSentry, SENTRY_MAXCLIP)));

						new iEntBase = entity_get_edict(iEntSentry, SENTRY_ENT_BASE);
						
						if(is_valid_ent(iEntBase)) {
							entity_set_int(iEntBase, SENTRY_CLIP, floatround(entity_get_float(iEntSentry, SENTRY_MAXCLIP)));
						}

						g_Gold[id] -= 10;

						clientPrintColor(id, _, "Las balas de esta torreta han sido recargadas.");
					} else {
						clientPrintColor(id, _, "La torreta está cargada al máximo.");
					}
				} else {
					clientPrintColor(id, _, "No tenés oro suficiente para recargar las balas de la torreta.");
				}
				
				return;
			}
		} case 3: {
			if(!entity_get_int(iEntSentry, SENTRY_OWNER)) {
				if(g_Gold[id] >= 100) {
					entity_set_int(iEntSentry, SENTRY_OWNER, id);

					entity_set_float(iEntSentry, SENTRY_PARAM_01, 0.0);
					
					set_rendering(iEntSentry);
					
					entity_set_float(iEntSentry, EV_FL_nextthink, get_gametime() + 0.01);

					new iEntBase = entity_get_edict(iEntSentry, SENTRY_ENT_BASE);
					
					if(is_valid_ent(iEntBase)) {
						entity_set_int(iEntBase, SENTRY_OWNER, id);
					}
					
					new iSentryLevel = clamp(entity_get_int(iEntSentry, SENTRY_INT_LEVEL), 1, 6);

					if(iSentryLevel >= 6) {
						new iEntBase = entity_get_edict(iEntSentry, SENTRY_ENT_BASE);

						if(is_valid_ent(iEntBase)) {
							entity_set_float(iEntBase, EV_FL_nextthink, (get_gametime() + 60.0));
						}
					}

					g_Gold[id] -= 100;
					
					clientPrintColor(id, _, "Te has adueñado de esta torreta.");
				} else {
					clientPrintColor(id, _, "No tenés oro suficiente para adueñarte de esta torreta.");
				}
				
				return;
			}
		} case 4: {
			new iOwner = entity_get_int(iEntSentry, SENTRY_OWNER);

			if(iOwner == id) {
				if(!g_WaveInProgress) {
					showMenu__SentryInfoMove(id);
					return;
				} else {
					clientPrintColor(id, _, "No puedes utilizar esta opción cuando hay una oleada en marcha.");
				}
			}
		} case 5: {
			new iOwner = entity_get_int(iEntSentry, SENTRY_OWNER);

			if(iOwner == id) {
				g_SentryTransferMenu[id] = 0;

				showMenu__SentryInfoTransferOwner(id);
				return;
			}
		}
	}

	showMenu__SentryInfo(id);
}

showMenu__SentryInfoMove(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yMOVER TORRETA", "@menu__SentryInfoMove");

	oldmenu_additem(1, 1, "\r1.\w Mover aquí^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__SentryInfoMove(const id, const item) {
	if(!item) {
		showMenu__SentryInfo(id);
		return;
	}

	new iEntSentry = g_MenuData_EntSentry[id];

	if(!is_valid_ent(iEntSentry)) {
		return;
	}
	
	switch(item) {
		case 1: {
			moveSentry(id, iEntSentry);
		}
	}
}

showMenu__SentryInfoTransferOwner(const id) {
	SetGlobalTransTarget(id);

	oldmenu_create("\yTRANSFERIR DUEÑO", "@menu__SentryInfoTransferOwner");

	if(!g_SentryTransferMenu[id]) {
		oldmenu_additem(1, 1, "\r1.\w Nuevo dueño\r\y YO");
	} else {
		oldmenu_additem(1, 1, "\r1.\w Nuevo dueño\r\y %n", g_SentryTransferMenu[id]);
	}

	oldmenu_additem(2, 2, "\r2.\w Confirmar^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__SentryInfoTransferOwner(const id, const item) {
	if(!item) {
		showMenu__SentryInfo(id);
		return;
	}

	new iEntSentry = g_MenuData_EntSentry[id];

	if(!is_valid_ent(iEntSentry)) {
		return;
	}
	
	switch(item) {
		case 1: {
			++g_SentryTransferMenu[id];

			while(!is_user_connected(g_SentryTransferMenu[id]) || g_SentryTransferMenu[id] == id) {
				++g_SentryTransferMenu[id];

				if(g_SentryTransferMenu[id] == id) {
					continue;
				} else if(g_SentryTransferMenu[id] > (MAX_PLAYERS + 1)) {
					g_SentryTransferMenu[id] = 0;
					break;
				}
			}
		} case 2: {
			if(!g_SentryTransferMenu[id]) {
				clientPrintColor(id, _, "Ya sos el dueño de esta torreta.");
			} else if(!is_user_connected(g_SentryTransferMenu[id])) {
				clientPrintColor(id, _, "El jugador seleccionado no existe, probablemente se haya desconectado.");
			} else if(!is_user_alive(g_SentryTransferMenu[id])) {
				clientPrintColor(id, _, "El jugador seleccionado está muerto.");
			} else {
				if(g_ClassId[g_SentryTransferMenu[id]] == CLASS_INGENIERO) {
					new iSentryLevel = clamp(entity_get_int(iEntSentry, SENTRY_INT_LEVEL), 1, 6);

					if((g_ClassLevel[g_SentryTransferMenu[id]][g_ClassId[id]] >= 5 && iSentryLevel >= 4) || (g_ClassLevel[g_SentryTransferMenu[id]][g_ClassId[id]] >= 6 && iSentryLevel >= 5)) {
						// Ing Nivel 5 > Torreta nivel 4
						// Ing Nivel 6 > Torreta nivel 5

						clientPrintColor(id, _, "Le has dado una torreta tuya a !t%n!y.", g_SentryTransferMenu[id]);
						clientPrintColor(g_SentryTransferMenu[id], _, "El jugador !t%n!y te ha regalado una de sus torretas.", id);

						entity_set_int(iEntSentry, SENTRY_OWNER, g_SentryTransferMenu[id]);

						new iEntBase = entity_get_edict(iEntSentry, SENTRY_ENT_BASE);

						if(is_valid_ent(iEntBase)) {
							entity_set_int(iEntBase, SENTRY_OWNER, g_SentryTransferMenu[id]);
						}

						showMenu__SentryInfo(id);
						return;
					} else {
						clientPrintColor(id, _, "El jugador debe tener la clase !tINGENIERO!y al nivel requerido del nivel de la torreta para transferirla.");
					}
				} else {
					clientPrintColor(id, _, "El jugador debe tener puesto la clase !tINGENIERO!y para poder transferir tu torreta.");
				}
			}
		}
	}
	
	showMenu__SentryInfoTransferOwner(id);
}

showMenu__VoteBoss(const id) {
	SetGlobalTransTarget(id);

	new i;
	new j;

	oldmenu_create("\yVOTACIÓN DE JEFES", "@menu__VoteBoss");

	for(i = 0, j = 1; i < structIdBosses; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s", j, __BOSSES_NAME[i][bossName]);
	}

	oldmenu_display(id, 1, 10);
}

@menu__VoteBoss(const id, const item, const value) {
	if(!is_user_connected(id)) {
		return;
	}

	++g_BossMenu_Votes[value];
	++g_BossMenu_MaxVotes;
}

@menu__VoteMap(const id, const item) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(item == 9) {
		return PLUGIN_HANDLED;
	}
	
	++g_VoteMap_VoteCount[item];

	clientPrintColor(0, id, "!t%n!y ha votado el mapa !g%a!y", id, ArrayGetStringHandle(g_aMapName, g_VoteMap_Next[item]));
	return PLUGIN_HANDLED;
}

@think__CheckAFK(const ent) {
	if(g_WaveInProgress && g_TotalMonsters > 1 && g_Wave < (MAX_WAVES + 1)) {
		new i;
		new iTimeAFK;
		
		for(i = 1; i <= MaxClients; ++i) {
			if(is_user_alive(i) && !(get_user_flags(i) & ADMIN_LEVEL_G)) {
				if(!g_AfkDamage[i]) {
					g_AfkTime[i] += 5.0;
					
					if(g_AfkTime[i] >= AFK_TIME_KICK) {
						clientPrintColor(0, i, "!t%n!y fue expulsado por estar demasiado sin realizar daño.", i);
						rh_drop_client(i, "Fuiste expulsado por estar demasiado tiempo sin realizar daño.");
					} else {
						iTimeAFK = (AFK_TIME_KICK - floatround(g_AfkTime[i]));
						
						if(iTimeAFK <= 20) {
							clientPrintColor(i, _, "Tenés !g%d segundos!y para realizar daño o serás expulsado por AFK.", iTimeAFK);
						}
					}
				} else {
					g_AfkTime[i] = 0.0;
					g_AfkDamage[i] = 0;
				}
			}
		}
	}
	
	set_entvar(ent, var_nextthink, NEXTTHINK_CHECK_AFK);
}

@think__Hud(const ent) {
	if(g_EndGame) {
		return;
	}

	new sTotalMonsters[8];

	if(!g_NextWaveIncoming && !g_StartGame) {
		addDot(g_TotalMonsters, sTotalMonsters, charsmax(sTotalMonsters));

		if(!g_SpecialWave) {
			if(g_WaveInProgress) {
				set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "OLEADA %d^n%s", g_Wave, sTotalMonsters);
			} else {
				set_dhudmessage(0, 255, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);

				if((g_Wave + 1) <= MAX_WAVES) {
					show_dhudmessage(0, "SIGUIENTE OLEADA: %d^n%s", (g_Wave + 1), sTotalMonsters);
				} else {
					show_dhudmessage(0, "SIGUIENTE OLEADA: JEFE FINAL^n%s", sTotalMonsters);
				}
			}
		} else if(g_SpecialWave == MONSTER_TYPE_SPECIAL_SPEED) {
			set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
			show_dhudmessage(0, "OLEADA EXTRA : VELOCES^n%s", sTotalMonsters);
		} else if(g_SpecialWave == MONSTER_TYPE_SPECIAL_STRENGTH) {
			set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
			show_dhudmessage(0, "OLEADA EXTRA : FUERTES^n%s", sTotalMonsters);
		}
	} else if(g_StartGame) {
		set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 9999.9, 9999.9, 0.01, 0.01);
		show_dhudmessage(0, "EL JUEGO COMENZARÁ EN %d", g_StartSeconds);
	} else {
		switch(g_NextWaveIncoming) {
			case 1: {
				set_dhudmessage(255, 255, 0, -1.0, -1.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "¡SIGUIENTE OLEADA EN PROGRESO!");
			} case 2: {
				set_dhudmessage(255, 255, 0, -1.0, -1.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "¡JEFE FINAL!");
			} case 3: {
				set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "JEFE FINAL^n%d", g_MonstersAlive);
			}
		}
	}
}

@think__HudGeneral(const ent) {
	new sProgress[56];
	new sProgressReq[15];
	new iProgressReqTotal;
	new sProgressReqTotal[15];
	new i;

	if(g_Wave != (MAX_WAVES + 1)) {
		new sKills[16];
		new sText[48];
		new sBoomerHealth[20];
		new sPower[32];
		
		if((1 <= g_BestPlayerId <= MaxClients)) {
			formatex(sKills, charsmax(sKills), " +%d", g_MVP_More);
			formatex(sText, charsmax(sText), "^n^nMVP: %n (%d)%s", g_BestPlayerId, g_BestPlayerKills, ((!g_MVP_More) ? "" : sKills));
		} else {
			formatex(sText, charsmax(sText), "^n^nMVP: NADIE");
		}

		sBoomerHealth[0] = EOS;

		if(g_BoomerHealth) {
			new sBoomerHealthDot[11];
			addDot(g_BoomerHealth, sBoomerHealthDot, charsmax(sBoomerHealthDot));

			formatex(sBoomerHealth, charsmax(sBoomerHealth), "^n^nGordo: %s", sBoomerHealthDot);
		}

		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			if(__POWERS[g_PowerActual[i]][powerGold] != 0) {
				formatex(sPower, charsmax(sPower), "%s (x%d)", __POWERS[g_PowerActual[i]][powerName], g_Power[i][g_PowerActual[i]]);
			} else {
				formatex(sPower, charsmax(sPower), "Ninguno");
			}

			if(g_UserOption_HudProgressClass[i]) {
				iProgressReqTotal = __CLASSES[g_ClassId[i]][(classReqLv1 + g_ClassLevel[i][g_ClassId[i]])];

				if((get_user_flags(i) & ADMIN_RESERVATION)) {
					iProgressReqTotal = (iProgressReqTotal - ((iProgressReqTotal * 20) / 100));
				}

				addDot(g_ClassReqs[i][g_ClassId[i]], sProgressReq, charsmax(sProgressReq));
				addDot(iProgressReqTotal, sProgressReqTotal, charsmax(sProgressReqTotal));
				
				formatex(sProgress, charsmax(sProgress), "%s: %s / %s^n", __CLASSES[g_ClassId[i]][className], sProgressReq, sProgressReqTotal);
			} else {
				sProgress[0] = EOS;
			}

			if(g_UserOption_HudKillsPerWave[i]) {
				if(g_Wave <= (MAX_WAVES + 1)) {
					formatex(sKills, charsmax(sKills), "Matados: %d^n", g_KillsPerWave[i][g_Wave]);
				} else {
					formatex(sKills, charsmax(sKills), "Matados: %d^n", g_KillsPerWave[i][0]);
				}
			} else {
				sKills[0] = EOS;
			}

			set_hudmessage(g_UserOption_HudColor[i][__R], g_UserOption_HudColor[i][__G], g_UserOption_HudColor[i][__B], g_UserOption_HudPosition[i][0], g_UserOption_HudPosition[i][0], g_UserOption_HudEffect[i], 6.0, 1.1, 0.0, 0.0, 3);
			ShowSyncHudMsg(i, g_HudSync_General, "Torre: %d^nOro: %d^n%s^nVida: %d^n%sPoder: %s%s%s", g_TowerHealth, g_Gold[i], sKills, g_Health[i], sProgress, sPower, sText, sBoomerHealth);
		}
	} else {
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}
			
			if(g_UserOption_HudProgressClass[i]) {
				iProgressReqTotal = __CLASSES[g_ClassId[i]][(classReqLv1 + g_ClassLevel[i][g_ClassId[i]])];

				if((get_user_flags(i) & ADMIN_RESERVATION)) {
					iProgressReqTotal = (iProgressReqTotal - ((iProgressReqTotal * 20) / 100));
				}

				addDot(g_ClassReqs[i][g_ClassId[i]], sProgressReq, charsmax(sProgressReq));
				addDot(iProgressReqTotal, sProgressReqTotal, charsmax(sProgressReqTotal));
				
				formatex(sProgress, charsmax(sProgress), "%s: %s / %s^n", __CLASSES[g_ClassId[i]][className], sProgressReq, sProgressReqTotal);
			} else {
				sProgress[0] = EOS;
			}

			set_hudmessage(g_UserOption_HudColor[i][__R], g_UserOption_HudColor[i][__G], g_UserOption_HudColor[i][__B], g_UserOption_HudPosition[i][0], g_UserOption_HudPosition[i][0], g_UserOption_HudEffect[i], 6.0, 1.1, 0.0, 0.0, 3);
			ShowSyncHudMsg(i, g_HudSync_General, "Vida: %d^n%s", g_Health[i], sProgress);
		}
	}

	entity_set_float(ent, EV_FL_nextthink, NEXTTHINK_HUD_GENERAL);
}

@think__Sentry(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}
	
	if(!entity_get_int(ent, SENTRY_OWNER)) {
		return;
	}
	
	static iClip;
	iClip = entity_get_int(ent, SENTRY_CLIP);
	
	if(!iClip) {
		entity_set_int(ent, EV_INT_sequence, sentryAnimSpin);
		entity_set_float(ent, EV_FL_animtime, 1.0);
		entity_set_float(ent, EV_FL_framerate, 1.0);
		
		set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 3);
		return;
	}
	
	if(entity_get_float(ent, SENTRY_PARAM_01)) {
		entity_set_float(ent, SENTRY_PARAM_01, 0.0);
		
		entity_set_int(ent, EV_INT_sequence, sentryAnimFire);
		entity_set_float(ent, EV_FL_animtime, 1.0);
		entity_set_float(ent, EV_FL_framerate, 2.0);
	}
	
	static Float:vecSentryOrigin[3];
	static Float:flDistance;
	static iTarget;
	static iSentryLevel;
	
	entity_get_vector(ent, EV_VEC_origin, vecSentryOrigin);
	vecSentryOrigin[2] += 20.0;
	
	iTarget = entity_get_edict(ent, SENTRY_ENT_TARGET);
	iSentryLevel = clamp(entity_get_int(ent, SENTRY_INT_LEVEL), 1, 6);
	
	if(entity_get_int(ent, SENTRY_INT_FIRE) == 1 && isMonster(iTarget)) {
		static Float:vecTargetOrigin[3];
		entity_get_vector(iTarget, EV_VEC_origin, vecTargetOrigin);
		
		flDistance = vector_distance(vecSentryOrigin, vecTargetOrigin);
		
		if(flDistance <= 800.0) {
			sentryTurnToTarget(ent, vecSentryOrigin, iTarget, vecTargetOrigin);
			
			if(iSentryLevel < 4) {
				rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_SENTRY_FIRE, 0.2, ATTN_NORM, 0, PITCH_NORM);
			} else {
				rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_SENTRY_FIRE_5TO6[random_num(0, charsmax(__SOUND_SENTRY_FIRE_5TO6))], 0.3, ATTN_NORM, 0, PITCH_NORM);
			}
			
			static iHitRatio;
			iHitRatio = floatround((__SENTRIES_HIT_RATIO[iSentryLevel] * 100.0) + entity_get_float(ent, SENTRY_EXTRA_RATIO));		

			if(random_num(1, 100) <= iHitRatio) {
				sentryDamageToPlayer(ent, iTarget, iSentryLevel);
			}
			
			entity_set_int(ent, SENTRY_CLIP, (iClip - 1));

			static iEntBase;
			iEntBase = entity_get_edict(ent, SENTRY_ENT_BASE);

			if(is_valid_ent(iEntBase)) {
				entity_set_int(iEntBase, SENTRY_CLIP, (iClip - 1));
			}
			
			vecTargetOrigin[2] += random_num(-16, 16);

			effectBlood(vecTargetOrigin);
			effectTracer(vecSentryOrigin, vecTargetOrigin);
			
			entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
			return;
		} else {
			entity_set_int(ent, SENTRY_INT_FIRE, 0);
			
			entity_set_int(ent, EV_INT_sequence, sentryAnimSpin);
			entity_set_float(ent, EV_FL_animtime, 1.0);
			entity_set_float(ent, EV_FL_framerate, 1.0);
		}
	}
	
	static iVictim;
	static iClosest;
	static Float:flClosestDistance;
	static Float:vecClosestOrigin[3];
	static Float:vecOrigin[3];

	iVictim = -1;
	iClosest = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecSentryOrigin, 800.0)) != 0) {
		if(!isMonster(iVictim)) {
			continue;
		}
		
		entity_get_vector(iVictim, EV_VEC_origin, vecOrigin);
		vecOrigin[2] += 10.0;
		
		flDistance = vector_distance(vecSentryOrigin, vecOrigin);
		vecClosestOrigin = vecOrigin;
		
		if(flDistance < flClosestDistance || iClosest == 0) {
			iClosest = iVictim;
			flClosestDistance = flDistance;
		}
	}
	
	if(iClosest) {
		rh_emit_sound2(ent, 0, CHAN_AUTO, __SOUND_SENTRY_FOUND, 0.4, ATTN_NORM, 0, PITCH_NORM);
		sentryTurnToTarget(ent, vecSentryOrigin, iClosest, vecClosestOrigin);
		
		entity_set_int(ent, SENTRY_INT_FIRE, 1);
		entity_set_edict(ent, SENTRY_ENT_TARGET, iClosest);
		
		entity_set_byte(ent, SENTRY_TILT_RADAR, 127);
		
		static iArgs[4];
		static iSentryOrigin[3];
		
		FVecIVec(vecSentryOrigin, iSentryOrigin);
		
		iArgs[0] = iSentryOrigin[0];
		iArgs[1] = iSentryOrigin[1];
		iArgs[2] = iSentryOrigin[2];
		iArgs[3] = iClosest;
		
		set_task(0.1, "task__SentryAimToTarget", ent + TASK_SENTRY_THINK, iArgs, sizeof(iArgs), "a", 4);
		
		entity_set_float(ent, SENTRY_PARAM_01, 1.0);
	} else {
		entity_set_int(ent, SENTRY_INT_FIRE, 0);
		
		entity_set_int(ent, EV_INT_sequence, sentryAnimSpin);
		entity_set_float(ent, EV_FL_animtime, 1.0);
		entity_set_float(ent, EV_FL_framerate, 1.0);
	}
	
	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + __SENTRIES_THINK[iSentryLevel]));
}

@think__SentryBase(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}

	static iParentEnt;
	iParentEnt = entity_get_edict(ent, BASE_ENT_SENTRY);

	if(!is_valid_ent(iParentEnt)) {
		return;
	}
	
	if(!entity_get_int(iParentEnt, SENTRY_OWNER)) {
		return;
	}

	static Float:vecEntOrigin[3];
	static iVictim;
	static i;
	static iZombies[10];

	entity_get_vector(iParentEnt, EV_VEC_origin, vecEntOrigin);
	iVictim = -1;
	i = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecEntOrigin, 400.0)) != 0) {
		if(!isMonster(iVictim)) {
			continue;
		}

		if(isBoomerMonster(iVictim)) {
			continue;
		}
		
		iZombies[i] = iVictim;
		++i;

		if(i == 10) {
			break;
		}
	}

	if(i > 0) {
		static Float:vecVictimOrigin[3];
		static iEntOrigin[3];
		static iVictimOrigin[3];

		iVictim = iZombies[random_num(0, (i - 1))];

		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);

		iEntOrigin[0] = floatround(vecEntOrigin[0]);
		iEntOrigin[1] = floatround(vecEntOrigin[1]);
		iEntOrigin[2] = floatround(vecEntOrigin[2]);

		iVictimOrigin[0] = floatround(vecVictimOrigin[0]);
		iVictimOrigin[1] = floatround(vecVictimOrigin[1]);
		iVictimOrigin[2] = floatround(vecVictimOrigin[2]);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMPOINTS);
		write_coord(iEntOrigin[0]);
		write_coord(iEntOrigin[1]);
		write_coord((iEntOrigin[2] + 38));
		write_coord(iVictimOrigin[0]);
		write_coord(iVictimOrigin[1]);
		write_coord((iVictimOrigin[2] + 6));
		write_short(g_Sprite_Trail);
		write_byte(1);
		write_byte(1);
		write_byte(10);
		write_byte(3);
		write_byte(30);
		write_byte(72);
		write_byte(61);
		write_byte(139);
		write_byte(255);
		write_byte(150);
		message_end();

		rh_emit_sound2(ent, 0, CHAN_BODY, __SOUND_ZOMBIE_LASER[random_num(0, charsmax(__SOUND_ZOMBIE_LASER))], 1.0, ATTN_NORM, 0, PITCH_NORM);

		removeMonster(iVictim, 1337, 1);

		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 60.0));
	} else {
		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 5.0));
	}
}

@think__SpecialMonster(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}
	
	if(!entity_get_int(ent, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(ent, MONSTER_TARGET);
	
	if(is_user_alive(iVictim) && !g_InBlockZone[iVictim]) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:flDistance;
		static Float:flDiff;
		
		entity_get_vector(ent, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		flDiff = (vecEntOrigin[2] - vecVictimOrigin[2]);
		
		if(flDiff < -64.0 || flDiff > 64.0) {
			entity_set_int(ent, MONSTER_TARGET, 0);
			
			if(is_valid_ent(ent)) {
				entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
			}

			return;
		}
		
		flDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		if(flDistance <= 64.0) {
			entitySetAim(ent, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
			
			static Float:flDamage;
			
			entity_set_int(ent, EV_INT_sequence, 76);
			entity_set_float(ent, EV_FL_animtime, get_gametime());
			entity_set_float(ent, EV_FL_framerate, 6.0);
			
			entity_set_int(ent, EV_INT_gamestate, 1);
			
			entity_set_vector(ent, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_get_vector(iVictim, EV_VEC_velocity, vecEntOrigin);
			
			vecEntOrigin[0] = 15.0;
			vecEntOrigin[1] = 15.0;
			
			entity_set_vector(iVictim, EV_VEC_velocity, vecEntOrigin);
			
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iVictim);
			write_short(UNIT_SECOND * 1);
			write_short(UNIT_SECOND * 1);
			write_short(SF_FADE_OUT);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(152);
			message_end();
			
			if(!__DIFFS_VALUES[g_Diff][diffValueEggDamageSpeed]) {
				flDamage = 1.0;
				ExecuteHam(Ham_TakeDamage, iVictim, 0, ent, flDamage, DMG_BULLET);
				
				if(g_Upgrades[iVictim][UPGRADE_RESISTENCE] && is_valid_ent(ent)) {
					static Float:flResist;
					flResist = (float(g_Upgrades[iVictim][UPGRADE_RESISTENCE]) * (float(__UPGRADES[UPGRADE_RESISTENCE][upgradeValue]) / 10.0));

					if((g_ClassId[iVictim] == CLASS_SOPORTE && g_ClassLevel[iVictim][g_ClassId[iVictim]] == 6)) {
						flResist += 0.25;
					}

					entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1 + flResist));
					return;
				}
			} else {
				flDamage = 2.0;
				ExecuteHam(Ham_TakeDamage, iVictim, 0, ent, flDamage, DMG_BULLET);
				
				if(g_Upgrades[iVictim][UPGRADE_RESISTENCE] && is_valid_ent(ent)) {
					static Float:flResist;
					flResist = (float(g_Upgrades[iVictim][UPGRADE_RESISTENCE]) * (float(__UPGRADES[UPGRADE_RESISTENCE][upgradeValue]) / 10.0));

					if((g_ClassId[iVictim] == CLASS_SOPORTE && g_ClassLevel[iVictim][g_ClassId[iVictim]] == 6)) {
						flResist += 0.25;
					}

					entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1 + flResist));
					return;
				}
			}

			if(is_valid_ent(ent)) { // ¿?
				entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
			}
			
			return;
		} else {
			if(entity_get_int(ent, EV_INT_gamestate) != 3) {
				entity_set_int(ent, EV_INT_gamestate, 3);

				entity_set_int(ent, EV_INT_sequence, 4);
				entity_set_float(ent, EV_FL_animtime, get_gametime());
				entity_set_float(ent, EV_FL_framerate, 1.0);
			}
			
			entitySetAim(ent, vecEntOrigin, vecVictimOrigin, 265.0, .angle_mode=1);
		}
	} else {
		iVictim = specialMonsterSearchHuman(ent);
		entity_set_int(ent, MONSTER_TARGET, iVictim);
		
		if(!iVictim && g_Wave < (MAX_WAVES + 1)) {
			if(task_exists(ent + TASK_DAMAGE_TOWER)) {
				remove_task(ent + TASK_DAMAGE_TOWER);
				
				new sArgs[7];
				
				set_task(0.1, "task__DamageTowerEffect", TASK_DAMAGE_TOWER + ent, sArgs, 6);
				set_task(0.2, "task__DamageTower", TASK_DAMAGE_TOWER + ent);
				
				return;
			}
		}
	}
	
	if(is_valid_ent(ent)) {
		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
	}
}

@think__MiniBoss(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}
	
	if(!entity_get_int(ent, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	static Float:flGameTime;

	iVictim = entity_get_int(ent, MONSTER_TARGET);
	flGameTime = get_gametime();

	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:flDistance;
		
		entity_get_vector(ent, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		flDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		if(flDistance <= 64.0) {
			entitySetAim(ent, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
			
			entity_set_int(ent, EV_INT_sequence, 76);
			entity_set_float(ent, EV_FL_animtime, flGameTime);
			entity_set_float(ent, EV_FL_framerate, 2.0);
			
			entity_set_int(ent, EV_INT_gamestate, 1);
			
			entity_set_vector(ent, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_set_float(ent, EV_FL_nextthink, (flGameTime + 0.1));
			
			ExecuteHam(Ham_TakeDamage, iVictim, 0, ent, 9999.0, DMG_SLASH);

			if(iVictim && !g_Achievement_LaBoneaste) {
				g_Achievement_LaBoneaste = 1;
				setAchievement(iVictim, LA_BONEASTE);
			}
		} else {
			static Float:flVelocity;

			if(entity_get_int(ent, EV_INT_gamestate) != 3) {
				entity_set_int(ent, EV_INT_gamestate, 3);

				entity_set_int(ent, EV_INT_sequence, 4);
				entity_set_float(ent, EV_FL_animtime, flGameTime);
				
				flVelocity = 200.0;

				entity_set_float(ent, EV_FL_framerate, (flVelocity / 250.0));
			}

			entitySetAim(ent, vecEntOrigin, vecVictimOrigin, flVelocity, .angle_mode=1);
			
			if(flDistance >= 115.0) {
				iVictim = miniBossSearchHuman(ent);
				entity_set_int(ent, MONSTER_TARGET, iVictim);
			}
			
			entity_set_float(ent, EV_FL_nextthink, (flGameTime + 0.1));
		}
	} else {
		iVictim = miniBossSearchHuman(ent);
		entity_set_int(ent, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(ent, EV_INT_sequence, 1);
			entity_set_float(ent, EV_FL_animtime, flGameTime);
			entity_set_float(ent, EV_FL_framerate, 1.0);
			
			entity_set_int(ent, EV_INT_gamestate, 1);
			return;
		}
		
		entity_set_float(ent, EV_FL_nextthink, (flGameTime + 0.1));
	}
}

@think__Boss(const boss) {
	if(!is_valid_ent(boss)) {
		return;
	}
	
	if(!entity_get_int(boss, MONSTER_MAXHEALTH)) {
		return;
	}

	static iVictim;
	iVictim = entity_get_int(boss, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:flDistance;
		static flHeightDifference;

		entity_get_vector(boss, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		flDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		flHeightDifference = abs(floatround(vecEntOrigin[2] - vecVictimOrigin[2]));

		if(flHeightDifference > 250) {
			for(new i = 0; i < 16; ++i) {
				iVictim = miniBossSearchHuman(boss, iVictim);
				entity_set_int(boss, MONSTER_TARGET, iVictim);

				entity_set_float(boss, EV_FL_nextthink, (get_gametime() + 0.1));
				return;
			}
		}
		
		if(flDistance <= 64.0) {
			entitySetAim(boss, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
			
			if(g_BossPower[0] != BOSS_POWER_ROLL) {
				static iRandom;
				static iRandomAttackSeq;
				static Float:vecSub[3];
				
				iRandom = random_num(0, charsmax(__SEQUENCES_ATTACK_BOSS1));
				iRandomAttackSeq = __SEQUENCES_ATTACK_BOSS1[iRandom];
				
				g_BossRollSpeed[0] = 0.0;

				rh_emit_sound2(iVictim, 0, CHAN_BODY, __SOUND_BOSS_PHIT[random_num(0, charsmax(__SOUND_BOSS_PHIT))], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(boss, EV_INT_sequence, iRandomAttackSeq);
				entity_set_float(boss, EV_FL_animtime, get_gametime());
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 2400.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(boss, EV_FL_nextthink, (get_gametime() + __SEQUENCES_FRAMES_BOSS1[iRandom]));
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, boss, __DIFFS_VALUES[g_Diff][diffValueBossDamage], DMG_SLASH);
				return;
			} else {
				static Float:vecSub[3];
				
				playSound(0, __SOUND_BOSS_ROLL_FINISH, 1);
				
				g_BossRollSpeed[0] = 0.0;
				g_BossTimePower[0] = (get_gametime() + 5.0);
				g_BossPower[0] = 0;
				
				vecEntOrigin[0] = vecVictimOrigin[0];
				vecEntOrigin[1] = vecVictimOrigin[1];
				vecEntOrigin[2] = (vecVictimOrigin[2] + 64.0);
				
				xs_vec_sub(vecEntOrigin, vecVictimOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 5.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(boss, EV_INT_sequence, 45);
				entity_set_float(boss, EV_FL_animtime, get_gametime());
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				entity_set_float(boss, EV_FL_nextthink, (get_gametime() + 1.2));
				return;
			}
		} else {
			static Float:flVelocity;
			
			if(g_BossPower[0] != BOSS_POWER_ROLL) {
				g_BossRollSpeed[0] += 0.5;

				flVelocity = (260.0 + g_BossRollSpeed[0]);

				if(entity_get_int(boss, EV_INT_gamestate) != 3) {
					entity_set_int(boss, EV_INT_gamestate, 3);

					entity_set_int(boss, EV_INT_sequence, 4);
					entity_set_float(boss, EV_FL_animtime, get_gametime());
				}

				entity_set_float(boss, EV_FL_framerate, (flVelocity / 250.0));
			} else {
				g_BossRollSpeed[0] += 5.0;

				flVelocity = (200.0 + g_BossRollSpeed[0]);
				
				vecEntOrigin[2] -= 24.0;
				
				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
				write_byte(TE_SPARKS);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
				message_end();
				
				vecEntOrigin[2] += 24.0;
			}
			
			entitySetAim(boss, vecEntOrigin, vecVictimOrigin, flVelocity, .angle_mode=1);
			
			if(flDistance >= 200.0) {
				if(flDistance >= 500.0 && !g_BossPower[0] && g_BossTimePower[0] <= get_gametime()) {
					if(random_num(0, 1)) {
						g_BossPower[0] = BOSS_POWER_ROLL;
						g_BossLastPower[0] = g_BossPower[0];
						
						playSound(0, __SOUND_BOSS_ROLL_LOOP);
						
						entity_set_int(boss, EV_INT_sequence, 44);
						entity_set_float(boss, EV_FL_animtime, get_gametime());
						entity_set_float(boss, EV_FL_framerate, 1.3);
						
						entity_set_int(boss, EV_INT_gamestate, 1);
						
						iVictim = miniBossSearchRandomHuman(boss);
						entity_set_int(boss, MONSTER_TARGET, iVictim);
						
						entity_set_float(boss, EV_FL_nextthink, (get_gametime() + 0.1));
						return;
					} else {
						static iRandomPower;
						iRandomPower = g_BossLastPower[0];
						
						while(iRandomPower == g_BossLastPower[0]) {
							iRandomPower = random_num(1, 3);
						}
						
						switch(iRandomPower) {
							case BOSS_POWER_ROLL: {
								g_BossTimePower[0] = (get_gametime() + 7.0);
								g_BossLastPower[0] = BOSS_POWER_ROLL;
								
								entity_set_float(boss, EV_FL_nextthink, (get_gametime() + 0.1));
								return;
							} case BOSS_POWER_EGGS: {
								g_BossPower[0] = BOSS_POWER_EGGS;
								g_BossLastPower[0] = g_BossPower[0];
								
								engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
								write_byte(TE_IMPLOSION);
								engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
								engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
								engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
								write_byte(256);
								write_byte(20);
								write_byte(5);
								message_end();
								
								entity_set_int(boss, EV_INT_rendermode, kRenderTransAlpha);
								entity_set_float(boss, EV_FL_renderamt, 150.0);
								
								entity_set_int(boss, EV_INT_sequence, 1);
								entity_set_float(boss, EV_FL_animtime, get_gametime());
								entity_set_float(boss, EV_FL_framerate, 1.0);
								
								entity_set_int(boss, EV_INT_gamestate, 1);
								
								entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
								
								createSpecialMonster(boss, 16);
							} case BOSS_POWER_ATTRACT: {
								if(!random_num(0, 3)) {
									g_BossPower[0] = BOSS_POWER_ATTRACT;
									g_BossLastPower[0] = g_BossPower[0];
									
									entity_set_int(boss, EV_INT_sequence, 0);
									entity_set_float(boss, EV_FL_animtime, get_gametime());
									entity_set_float(boss, EV_FL_framerate, 1.0);
									
									entity_set_int(boss, EV_INT_gamestate, 1);
									
									entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
									
									set_rendering(boss, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
									
									set_lights("a");

									static Float:flEndTime;
									static Float:flRepeat;
									
									flEndTime = 3.7;
									flRepeat = ((flEndTime / 0.1) - 1.0);
									
									set_task(0.1, "task__BossPowerCloser", boss, _, _, "a", floatround(flRepeat));
									set_task(flEndTime, "task__EndBossPowerCloser", boss);
								} else {
									g_BossTimePower[0] = (get_gametime() + 7.0);
									g_BossLastPower[0] = BOSS_POWER_ROLL;
									
									entity_set_float(boss, EV_FL_nextthink, (get_gametime() + 0.1));
									return;
								}
							}
						}

						entity_set_int(boss, MONSTER_TARGET, 0);
						return;
					}
				}
				
				iVictim = miniBossSearchHuman(boss);
				entity_set_int(boss, MONSTER_TARGET, iVictim);
			}
		}
	} else {
		iVictim = miniBossSearchHuman(boss);
		entity_set_int(boss, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(boss, EV_INT_sequence, 1);
			entity_set_float(boss, EV_FL_animtime, get_gametime());
			entity_set_float(boss, EV_FL_framerate, 1.0);
			
			entity_set_int(boss, EV_INT_gamestate, 1);
			return;
		}
	}
	
	entity_set_float(boss, EV_FL_nextthink, (get_gametime() + 0.1));
}

@think__BossFireMonster(const boss) {
	if(!is_valid_ent(boss)) {
		return;
	}
	
	if(!entity_get_int(boss, MONSTER_MAXHEALTH)) {
		return;
	}

	static iVictim;
	static Float:flGameTime;
	
	iVictim = entity_get_int(boss, MONSTER_TARGET);
	flGameTime = get_gametime();
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:flDistance;
		static iRandom;
		
		entity_get_vector(boss, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		flDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		if(flDistance <= 260.0) {
			if(g_BossPower[0] != BOSS_POWER_DASH) {
				entitySetAim(boss, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
				
				if(!g_BossPower[0] && g_BossTimePower[0] <= flGameTime) {
					if(random_num(0, 1)) {
						g_BossPower[0] = BOSS_POWER_EXPLODE;
						g_BossTimePower[0] = (flGameTime + 5.0);
						
						entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
						
						entity_set_int(boss, EV_INT_sequence, 11);
						entity_set_float(boss, EV_FL_animtime, flGameTime);
						entity_set_float(boss, EV_FL_framerate, 1.0);
						
						entity_set_int(boss, EV_INT_gamestate, 1);
						
						entity_set_int(boss, MONSTER_TARGET, 0);
						
						rh_emit_sound2(boss, 0, CHAN_BODY, __SOUND_BOSS_EXPLODE, 0.8, ATTN_NORM, 0, PITCH_NORM);
						
						g_BossPower_Explode = 3;

						set_task(0.25, "task__BossPowerExplode", _, _, _, "a", 3);
						
						entity_set_float(boss, EV_FL_nextthink, (flGameTime + 2.6));
						return;
					}
				}
				
				rh_emit_sound2(iVictim, 0, CHAN_BODY, __SOUND_BOSS_PHIT[random_num(0, charsmax(__SOUND_BOSS_PHIT))], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(boss, EV_INT_sequence, 8);
				entity_set_float(boss, EV_FL_animtime, flGameTime);
				entity_set_float(boss, EV_FL_framerate, 3.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				static Float:vecSub[3];
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 200.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.788889));
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, boss, (__DIFFS_VALUES[g_Diff][diffValueBossDamage] * 1.5), DMG_SLASH);
				return;
			}
		} else {
			static Float:flVelocity;
			
			if(entity_get_int(boss, EV_INT_gamestate) != 3) {
				entity_set_int(boss, EV_INT_gamestate, 3);

				entity_set_int(boss, EV_INT_sequence, 4);
				entity_set_float(boss, EV_FL_animtime, flGameTime);
				
				flVelocity = 265.0;
				
				entity_set_float(boss, EV_FL_framerate, (flVelocity / 250.0));
			}

			entitySetAim(boss, vecEntOrigin, vecVictimOrigin, flVelocity, .angle_mode=1);
			
			if(!g_BossPower[0] && g_BossTimePower[0] <= flGameTime) {
				iRandom = random_num(1, 5);

				switch(iRandom) {
					case 1, 3, 5: {
						entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
						
						switch(iRandom) {
							case 1: {
								g_BossPower[0] = BOSS_POWER_DASH;
								g_BossTimePower[0] = (flGameTime + 15.0);
								
								entity_set_int(boss, EV_INT_sequence, 5);
								
								set_task(1.533333, "task__BossPowerDash");
								
								entity_set_int(boss, MONSTER_TARGET, 0);
							} case 3: {
								g_BossPower[0] = BOSS_POWER_FIREBALL_X2;
								g_BossTimePower[0] = (flGameTime + 6.0);
								
								iRandom = getUserRandomAlive();

								if(is_user_alive(iRandom)) {
									entity_get_vector(iRandom, EV_VEC_origin, vecVictimOrigin);
									
									entitySetAim(boss, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
									
									entity_set_int(boss, MONSTER_TARGET, iRandom);
								}
								
								entity_set_int(boss, EV_INT_sequence, 9);
								
								playSound(0, __SOUND_BOSS_FIREBALL_LAUNCH2);
								
								set_task(1.2, "task__BossPowerFireBallx2");
								
								entity_set_float(boss, EV_FL_nextthink, (flGameTime + 4.366667));
							} case 5: {
								g_BossPower[0] = BOSS_POWER_FIREBALL_X4;
								g_BossTimePower[0] = (flGameTime + 8.0);
								
								entity_set_int(boss, EV_INT_sequence, 10);
								
								playSound(0, __SOUND_BOSS_FIREBALL_LAUNCH4);
								
								set_task(1.2, "task__BossPowerFireBallx4");
								
								entity_set_float(boss, EV_FL_nextthink, (flGameTime + 5.366667));
							}
						}
						
						entity_set_float(boss, EV_FL_animtime, flGameTime);
						entity_set_float(boss, EV_FL_framerate, 1.0);
						
						entity_set_int(boss, EV_INT_gamestate, 1);
						return;
					} default: {
						g_BossTimePower[0] = (flGameTime + 3.0);
					}
				}
			}
			
			iVictim = miniBossSearchHuman(boss);
			entity_set_int(boss, MONSTER_TARGET, iVictim);
		}
	} else {
		iVictim = miniBossSearchHuman(boss);
		entity_set_int(boss, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(boss, EV_INT_sequence, 1);
			entity_set_float(boss, EV_FL_animtime, flGameTime);
			entity_set_float(boss, EV_FL_framerate, 1.0);
			
			entity_set_int(boss, EV_INT_gamestate, 1);
			return;
		}
	}
	
	entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.1));
}

@think__FireMonsterBall(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(ent, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		static Float:vecOrigin[3];
		static Float:vecVictimOrigin[3];
		
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY);
		
		entity_get_vector(ent, EV_VEC_origin, vecOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		followHumanFireBall(ent, vecOrigin, vecVictimOrigin, 2400.0);
	} else {
		remove_entity(ent);
	}
}

@think__BossFallenTitan(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}
	
	if(!entity_get_int(ent, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(ent, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:fDistance;
		static iRandom;
		
		entity_get_vector(ent, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		if(fDistance <= 260.0) {
			if(g_BossPower[0] != BOSS_FT_DASH) {
				entitySetAim(ent, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
				
				rh_emit_sound2(iVictim, 0, CHAN_BODY, __SOUND_BOSS_PHIT[random_num(0, charsmax(__SOUND_BOSS_PHIT))], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(ent, EV_INT_sequence, random_num(11, 12));
				entity_set_float(ent, EV_FL_animtime, get_gametime());
				entity_set_float(ent, EV_FL_framerate, ((!g_BossFT_Enrage) ? 3.0 : 6.0));
				
				entity_set_int(ent, EV_INT_gamestate, 1);
				
				static Float:vecSub[3];
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 2400.0, vecSub);
				
				vecSub[2] = random_float(100.0, 150.0);

				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(ent, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(ent, EV_FL_nextthink, (get_gametime() + ((!g_BossFT_Enrage) ? 1.266667 : 0.633334)));
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, ent, (__DIFFS_VALUES[g_Diff][diffValueBossDamage] * ((!g_BossFT_Enrage) ? 1.5 : 2.0)), DMG_SLASH);

				g_BossRollSpeed[0] = 0.0;
				return;
			}
		} else {
			static Float:flVelocity;

			g_BossRollSpeed[0] += ((!g_BossFT_Enrage) ? 0.4 : 2.5);
			flVelocity = (265.0 + g_BossRollSpeed[0]);
			
			if(entity_get_int(ent, EV_INT_gamestate) != 3) {
				entity_set_int(ent, EV_INT_gamestate, 3);

				entity_set_int(ent, EV_INT_sequence, 6);
				entity_set_float(ent, EV_FL_animtime, get_gametime());
			}

			entity_set_float(ent, EV_FL_framerate, (flVelocity / 250.0));

			entitySetAim(ent, vecEntOrigin, vecVictimOrigin, flVelocity, .angle_mode=1);
			
			if(!g_BossPower[0] && g_BossTimePower[0] <= get_gametime()) {
				iRandom = random_num(1, 5);

				if(g_BossFT_LastPower == iRandom) {
					iRandom += 2;

					if(iRandom == 7) {
						iRandom = 1;
					}
				}

				g_BossFT_LastPower = iRandom;

				switch(iRandom) {
					case 1, 3, 5: {
						entity_set_vector(ent, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});

						switch(iRandom) {
							case 1: {
								g_BossPower[0] = BOSS_FT_DASH;
								g_BossTimePower[0] = (get_gametime() + ((!g_BossFT_Enrage) ? 15.0 : 6.0));
								
								entity_set_int(ent, EV_INT_sequence, 8);

								set_hudmessage(255, 0, 0, -1.0, 0.5, 0, 0.0, 5.0, 0.0, 0.0, 4);
								ShowSyncHudMsg(0, g_HudSync_DamageTower, "No dejes que el jefe golpee una pared");
								
								set_task(((!g_BossFT_Enrage) ? 2.333334 : 1.166667), "task__BossFallenTitanPowerDash");
								
								entity_set_int(ent, MONSTER_TARGET, 0);
							} case 3: {
								g_BossPower[0] = BOSS_FT_CANNON;
								g_BossTimePower[0] = (get_gametime() + ((!g_BossFT_Enrage) ? 7.5 : 3.0));
								
								iRandom = getUserRandomAlive();

								if(is_user_alive(iRandom)) {
									entity_get_vector(iRandom, EV_VEC_origin, vecVictimOrigin);
									
									entitySetAim(ent, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
									
									entity_set_int(ent, MONSTER_TARGET, 0);
								}
								
								entity_set_int(ent, EV_INT_sequence, 13);
								
								new iArgs[2];

								iArgs[0] = iRandom;
								iArgs[1] = 1;

								set_task(((!g_BossFT_Enrage) ? 1.5 : 0.75), "task__BossFallenTitanPowerCannon", _, iArgs, sizeof(iArgs));
							} case 5: {
								g_BossPower[0] = BOSS_FT_TENTACLES;
								g_BossTimePower[0] = (get_gametime() + ((!g_BossFT_Enrage) ? 8.0 : 4.0));
								
								entity_set_int(ent, EV_INT_sequence, 18);
								
								set_task(((!g_BossFT_Enrage) ? 1.23 : 0.615), "task__BossFallenTitanPowerTentacles");

								entity_set_float(ent, EV_FL_nextthink, (get_gametime() + ((!g_BossFT_Enrage) ? 4.7 : 2.35)));
							}
						}
						
						entity_set_float(ent, EV_FL_animtime, get_gametime());
						entity_set_float(ent, EV_FL_framerate, ((!g_BossFT_Enrage) ? 1.0 : 2.0));
						
						entity_set_int(ent, EV_INT_gamestate, 1);
						return;
					} default: {
						g_BossTimePower[0] = (get_gametime() + ((!g_BossFT_Enrage) ? 4.0 : 3.0));
					}
				}
			}
			
			iVictim = miniBossSearchHuman(ent);
			entity_set_int(ent, MONSTER_TARGET, iVictim);
		}
	} else {
		iVictim = miniBossSearchHuman(ent);
		entity_set_int(ent, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(ent, EV_INT_sequence, 5);
			entity_set_float(ent, EV_FL_animtime, get_gametime());
			entity_set_float(ent, EV_FL_framerate, 1.0);
			
			entity_set_int(ent, EV_INT_gamestate, 1);
			return;
		}
	}
	
	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
}

@think__BossKyra(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}

	static Float:flGameTime;
	flGameTime = get_gametime();
	
	if(g_BossGuardians) {
		static iVictim;
		static Float:vecBossOrigin[3];
		static Float:vecVictimOrigin[3];
		static iDistance;
		static Float:vecVelocity[3];

		iVictim = miniBossSearchRandomHuman(iEnt);
		
		entity_get_vector(iEnt, EV_VEC_origin, vecBossOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);	

		entitySetAim(iEnt, vecBossOrigin, vecVictimOrigin, .angle_mode=1337);
		
		playSound(0, __SOUND_SPITTER_SPIT);

		iDistance = floatround(vector_distance(vecBossOrigin, vecVictimOrigin));
		
		velocity_by_aim(iEnt, iDistance, vecVelocity);
		
		static iSpitterBall;
		iSpitterBall = create_entity("info_target");
		
		if(is_valid_ent(iSpitterBall)) {
			entity_set_string(iSpitterBall, EV_SZ_classname, __ENT_CLASSNAME_BOSS_GK_SPRITTER);
			entity_set_model(iSpitterBall, __MODEL_TANK_ROCK_GIBS);
			
			entity_set_float(iSpitterBall, EV_FL_scale, 0.1);
			
			entity_set_size(iSpitterBall, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
			entity_set_vector(iSpitterBall, EV_VEC_mins, Float:{-2.0, -2.0, -2.0});
			entity_set_vector(iSpitterBall, EV_VEC_maxs, Float:{2.0, 2.0, 2.0});
			
			vecBossOrigin[2] += 10.0;
			entity_set_origin(iSpitterBall, vecBossOrigin);
			vecBossOrigin[2] -= 10.0;
			
			entity_set_int(iSpitterBall, EV_INT_solid, SOLID_NOT);
			entity_set_int(iSpitterBall, EV_INT_movetype, MOVETYPE_TOSS);
			entity_set_edict(iSpitterBall, EV_ENT_owner, iEnt);
			
			entity_set_float(iSpitterBall, EV_FL_gravity, 1.0);
			entity_set_vector(iSpitterBall, EV_VEC_velocity, vecVelocity);
			
			set_rendering(iSpitterBall, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 4);
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMFOLLOW);
			write_short(iSpitterBall);
			write_short(g_Sprite_Trail);
			write_byte(25);
			write_byte(3);
			write_byte(0);
			write_byte(255);
			write_byte(0);
			write_byte(255);
			message_end();
			
			register_think(__ENT_CLASSNAME_BOSS_GK_SPRITTER, "@think__SpitterBall");
			
			entity_set_float(iSpitterBall, EV_FL_nextthink, (flGameTime + 0.1));
		}
		
		entity_set_float(iEnt, EV_FL_nextthink, (flGameTime + 15.0));
	} else {
		static iVictim;
		iVictim = entity_get_int(iEnt, MONSTER_TARGET);
		
		if(is_user_alive(iVictim)) {
			static Float:vecEntOrigin[3];
			static Float:vecVictimOrigin[3];
			static Float:flDistance;
			
			entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
			entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
			
			flDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
			
			if(flDistance <= 100.0) {
				entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
				
				entity_set_int(iEnt, EV_INT_sequence, 159);
				entity_set_float(iEnt, EV_FL_animtime, flGameTime);
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(iEnt, EV_FL_nextthink, (flGameTime + 1.4));
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, 9999.0, DMG_SLASH);
			} else {
				static Float:flVelocity;

				if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
					entity_set_int(iEnt, EV_INT_gamestate, 3);

					entity_set_int(iEnt, EV_INT_sequence, 148);
					entity_set_float(iEnt, EV_FL_animtime, flGameTime);
				}
				
				flVelocity = 220.0;
				entity_set_float(iEnt, EV_FL_framerate, (flVelocity / 250.0));
				
				entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, flVelocity, .angle_mode=1);
				
				if(flDistance >= 135.0) {
					iVictim = miniBossSearchHuman(iEnt);
					entity_set_int(iEnt, MONSTER_TARGET, iVictim);
				}
				
				entity_set_float(iEnt, EV_FL_nextthink, (flGameTime + 0.1));
			}
		} else {
			iVictim = miniBossSearchHuman(iEnt);
			entity_set_int(iEnt, MONSTER_TARGET, iVictim);
			
			if(!iVictim) {
				entity_set_int(iEnt, EV_INT_sequence, 146);
				entity_set_float(iEnt, EV_FL_animtime, flGameTime);
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				return;
			}
			
			entity_set_float(iEnt, EV_FL_nextthink, (flGameTime + 0.1));
		}
	}
}

@think__Tentacle(const ent) {
	if(is_valid_ent(ent)) {
		static Float:vecOrigin[3];
		static iVictim;
		static iHealth;

		entity_get_vector(ent, EV_VEC_origin, vecOrigin);
		iVictim = -1;
		iHealth = 0;

		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 12.0)) != 0) {
			if(!is_user_alive(iVictim)) {
				continue;
			}
			
			rh_emit_sound2(iVictim, 0, CHAN_BODY, __SOUND_BOSS_PHIT[random_num(0, charsmax(__SOUND_BOSS_PHIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			iHealth = (g_Health[iVictim] - ((!g_BossFT_Enrage) ? 3 : 6));

			if(iHealth <= 0) {
				ExecuteHamB(Ham_Killed, iVictim, iVictim, 0);
				
				if(!getUsersAlive()) {
					removeAllEnts(1);
					finishGame();
				}
			} else {
				set_user_health(iVictim, iHealth);
				
				message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iVictim);
				write_short(UNIT_SECOND * 1);
				write_short(UNIT_SECOND * 1);
				write_short(SF_FADE_OUT);
				write_byte(255);
				write_byte(0);
				write_byte(0);
				write_byte(125);
				message_end();

				entity_get_vector(iVictim, EV_VEC_velocity, vecOrigin);
				vecOrigin[2] = random_float(400.0, 650.0);
				entity_set_vector(iVictim, EV_VEC_velocity, vecOrigin);
			}
		}

		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 1.0));
	}
}

@think__SpitterBall(const ent) {
	if(is_valid_ent(ent)) {
		if(entity_get_int(ent, EV_INT_solid) == SOLID_TRIGGER) {
			static Float:vecOrigin[3];
			static iVictim;
			static iHealth;

			entity_get_vector(ent, EV_VEC_origin, vecOrigin);
			iVictim = -1;
			iHealth = 0;

			while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 250.0)) != 0) {
				if(!is_user_alive(iVictim)) {
					continue;
				}
				
				rh_emit_sound2(iVictim, 0, CHAN_BODY, __SOUND_BOSS_PHIT[random_num(0, charsmax(__SOUND_BOSS_PHIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				iHealth = (g_Health[iVictim] - 2);
				
				if(iHealth <= 0) {
					ExecuteHamB(Ham_Killed, iVictim, iVictim, 0);
					
					if(!getUsersAlive()) {
						removeAllEnts(1);
						finishGame();
					}
				} else {
					set_user_health(iVictim, iHealth);
					
					message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iVictim);
					write_short(UNIT_SECOND * 1);
					write_short(UNIT_SECOND * 1);
					write_short(SF_FADE_OUT);
					write_byte(255);
					write_byte(0);
					write_byte(0);
					write_byte(125);
					message_end();
				}
			}
		} else {
			if((get_entity_flags(ent) & FL_ONGROUND) && get_speed(ent) < 10) {
				static Float:vecOrigin[3];
				entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
				
				entity_set_vector(ent, EV_VEC_angles, Float:{180.0, 0.0, 0.0});
				
				entity_get_vector(ent, EV_VEC_origin, vecOrigin);
				vecOrigin[2] += 30.0;
				entity_set_vector(ent, EV_VEC_origin, vecOrigin);
				
				entity_set_model(ent, __MODEL_SPITTER_AURA);
				
				entity_set_int(ent, EV_INT_renderfx, kRenderFxPulseSlow);
				entity_set_int(ent, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(ent, EV_FL_renderamt, 120.0);
			}
		}

		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
	}
}

@think__BossGuardians(const boss) {
	if(!is_valid_ent(boss)) {
		return;
	}
	
	if(!entity_get_int(boss, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	static Float:flGameTime;
	static iBoss;

	iVictim = entity_get_int(boss, MONSTER_TARGET);
	flGameTime = get_gametime();
	iBoss = ((g_BossGuardians_Ids[0] == boss) ? 0 : 1);
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:flDistance;
		static flHeightDifference;
		
		entity_get_vector(boss, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		flDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		flHeightDifference = abs(floatround(vecEntOrigin[2] - vecVictimOrigin[2]));

		if(flHeightDifference > 250) {
			for(new i = 0; i < 16; ++i) {
				iVictim = miniBossSearchHuman(boss, iVictim);
				entity_set_int(boss, MONSTER_TARGET, iVictim);

				entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.1));
				return;
			}
		}
		
		if(flDistance <= 64.0) {
			entitySetAim(boss, vecEntOrigin, vecVictimOrigin, .angle_mode=1);
			
			if(g_BossPower[iBoss] != BOSS_POWER_ROLL) {
				g_BossRollSpeed[iBoss] = 0.0;

				static iRandom;
				static iRandomAttackSeq;
				static Float:vecSub[3];

				iRandom = random_num(0, charsmax(__SEQUENCES_ATTACK_BOSS1));
				iRandomAttackSeq = __SEQUENCES_ATTACK_BOSS1[iRandom];
				
				rh_emit_sound2(iVictim, 0, CHAN_BODY, __SOUND_BOSS_PHIT[random_num(0, charsmax(__SOUND_BOSS_PHIT))], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(boss, EV_INT_sequence, iRandomAttackSeq);
				entity_set_float(boss, EV_FL_animtime, flGameTime);
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 2400.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(boss, EV_FL_nextthink, (flGameTime + __SEQUENCES_FRAMES_BOSS1[iRandom]));
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, boss, __DIFFS_VALUES[g_Diff][diffValueBossDamage], DMG_SLASH);
				return;
			} else {
				g_BossRollSpeed[iBoss] = 0.0;
				g_BossTimePower[iBoss] = (flGameTime + 5.0);
				g_BossPower[iBoss] = 0;
				
				playSound(0, __SOUND_BOSS_ROLL_FINISH);
				
				static Float:vecSub[3];
				
				vecEntOrigin[0] = vecVictimOrigin[0];
				vecEntOrigin[1] = vecVictimOrigin[1];
				vecEntOrigin[2] = (vecVictimOrigin[2] + 64.0);
				
				xs_vec_sub(vecEntOrigin, vecVictimOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 5.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(boss, EV_INT_sequence, 45);
				entity_set_float(boss, EV_FL_animtime, flGameTime);
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				entity_set_float(boss, EV_FL_nextthink, (flGameTime + 1.2));
				return;
			}
		} else {
			static Float:flVelocity;
			
			if(g_BossPower[iBoss] != BOSS_POWER_ROLL) {
				g_BossRollSpeed[iBoss] += 0.5;

				if(entity_get_int(boss, EV_INT_gamestate) != 3) {
					entity_set_int(boss, EV_INT_gamestate, 3);

					entity_set_int(boss, EV_INT_sequence, 4);
					entity_set_float(boss, EV_FL_animtime, flGameTime);
				}

				flVelocity = (260.0 + g_BossRollSpeed[iBoss]);
				entity_set_float(boss, EV_FL_framerate, (flVelocity / 250.0));

			} else {
				g_BossRollSpeed[iBoss] += 5.0;

				flVelocity = (200.0 + g_BossRollSpeed[iBoss]);
				
				vecEntOrigin[2] -= 24.0;
				
				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
				write_byte(TE_SPARKS);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
				message_end();
				
				vecEntOrigin[2] += 24.0;
			}
			
			entitySetAim(boss, vecEntOrigin, vecVictimOrigin, flVelocity, .angle_mode=1);
			
			if(flDistance >= 200.0) {
				if(flDistance >= 500.0 && !g_BossPower[iBoss] && g_BossTimePower[iBoss] <= flGameTime) {
					if(random_num(0, 1)) {
						g_BossPower[iBoss] = BOSS_POWER_ROLL;
						g_BossLastPower[iBoss] = g_BossPower[iBoss];
						
						playSound(0, __SOUND_BOSS_ROLL_LOOP);
						
						entity_set_int(boss, EV_INT_sequence, 44);
						entity_set_float(boss, EV_FL_animtime, flGameTime);
						entity_set_float(boss, EV_FL_framerate, 1.3);
						
						entity_set_int(boss, EV_INT_gamestate, 1);
						
						iVictim = miniBossSearchRandomHuman(boss);
						entity_set_int(boss, MONSTER_TARGET, iVictim);
						
						entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.1));
						return;
					} else {
						static iRandomPower;
						iRandomPower = g_BossLastPower[iBoss];
						
						while(iRandomPower == g_BossLastPower[iBoss]) {
							iRandomPower = random_num(1, ((iBoss) ? 2 : 3));
						}
						
						while(iRandomPower == BOSS_POWER_EGGS && g_BossPower[!iBoss]) {
							iRandomPower = random_num(1, ((iBoss) ? 2 : 3));
						}
						
						switch(iRandomPower) {
							case BOSS_POWER_ROLL: {
								g_BossTimePower[iBoss] = (flGameTime + 7.0);
								g_BossLastPower[iBoss] = BOSS_POWER_ROLL;
								
								entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.1));
								return;
							} case BOSS_POWER_EGGS: { // Ambos guardianes tiran los huevos al mismo tiempo, de lo contrario, podés quedarte encima de los zombies y buguear a los guardianes
								for(new i = 0; i < 2; ++i) {
									if(is_valid_ent(g_BossGuardians_Ids[i]) && entity_get_int(g_BossGuardians_Ids[i], MONSTER_MAXHEALTH)) {
										g_BossPower[i] = BOSS_POWER_EGGS;
										g_BossLastPower[i] = BOSS_POWER_EGGS;
										
										entity_set_int(g_BossGuardians_Ids[i], EV_INT_rendermode, kRenderTransAlpha);
										entity_set_float(g_BossGuardians_Ids[i], EV_FL_renderamt, 150.0);
										
										entity_set_int(g_BossGuardians_Ids[i], EV_INT_sequence, 1);
										entity_set_float(g_BossGuardians_Ids[i], EV_FL_animtime, flGameTime);
										entity_set_float(g_BossGuardians_Ids[i], EV_FL_framerate, 1.0);
										
										entity_set_int(g_BossGuardians_Ids[i], EV_INT_gamestate, 1);
										
										entity_set_vector(g_BossGuardians_Ids[i], EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
										
										createSpecialMonster(g_BossGuardians_Ids[i], 16);
										
										entity_set_int(g_BossGuardians_Ids[i], MONSTER_TARGET, 0);
										
										entity_set_float(g_BossGuardians_Ids[i], EV_FL_nextthink, (flGameTime + 9999.0));
									}
								}
								
								return;
							} case BOSS_POWER_ATTRACT: {
								if(!random_num(0, 3)) {
									g_BossPower[iBoss] = BOSS_POWER_ATTRACT;
									g_BossLastPower[iBoss] = g_BossPower[iBoss];
									
									entity_set_int(boss, EV_INT_sequence, 0);
									entity_set_float(boss, EV_FL_animtime, flGameTime);
									entity_set_float(boss, EV_FL_framerate, 1.0);
									
									entity_set_int(boss, EV_INT_gamestate, 1);
									
									entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
									
									set_rendering(boss, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
									
									set_lights("a");
									
									static Float:flEndTime;
									static Float:flRepeat;
									
									flEndTime = 3.7;
									flRepeat = ((flEndTime / 0.1) - 1.0);

									set_task(0.1, "task__BossPowerCloser", boss, _, _, "a", floatround(flRepeat));
									set_task(flEndTime, "task__EndBossPowerCloser", boss);
								} else {
									g_BossTimePower[iBoss] = (flGameTime + 7.0);
									g_BossLastPower[iBoss] = BOSS_POWER_ROLL;
									
									entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.1));
									return;
								}
							}
						}
						
						entity_set_int(boss, MONSTER_TARGET, 0);
						return;
					}
				}
				
				iVictim = miniBossSearchHuman(boss);
				entity_set_int(boss, MONSTER_TARGET, iVictim);
			}
		}
	} else {
		iVictim = miniBossSearchHuman(boss);
		entity_set_int(boss, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(boss, EV_INT_sequence, 1);
			entity_set_float(boss, EV_FL_animtime, flGameTime);
			entity_set_float(boss, EV_FL_framerate, 1.0);
			
			entity_set_int(boss, EV_INT_gamestate, 1);
			
			return;
		}
	}
	
	entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.1));
}

@think__CannonBall(const ent) {
	if(is_valid_ent(ent)) {
		static Float:flGameTime;
		flGameTime = get_gametime();

		if(entity_get_int(ent, EV_INT_solid) == SOLID_TRIGGER) {
			static Float:vecOrigin[3];
			static iVictim;
			static iHealth;

			entity_get_vector(ent, EV_VEC_origin, vecOrigin);
			iVictim = -1;
			iHealth = 0;

			while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 62.5)) != 0) {
				if(!is_user_alive(iVictim)) {
					continue;
				}
				
				rh_emit_sound2(iVictim, 0, CHAN_BODY, __SOUND_BOSS_PHIT[random_num(0, charsmax(__SOUND_BOSS_PHIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				iHealth = (g_Health[iVictim] - ((!g_BossFT_Enrage) ? 1 : 2));

				if(iHealth <= 0) {
					ExecuteHamB(Ham_Killed, iVictim, iVictim, 0);
					
					if(!getUsersAlive()) {
						removeAllEnts(1);
						finishGame();
					}
				} else {
					set_user_health(iVictim, iHealth);
					
					message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iVictim);
					write_short(UNIT_SECOND * 1);
					write_short(UNIT_SECOND * 1);
					write_short(SF_FADE_OUT);
					write_byte(255);
					write_byte(0);
					write_byte(0);
					write_byte(125);
					message_end();
				}
			}
		} else {
			if((get_entity_flags(ent) & FL_ONGROUND) && get_speed(ent) < 10) {
				static Float:vecOrigin[3];
				entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
				
				entity_set_vector(ent, EV_VEC_angles, Float:{180.0, 0.0, 0.0});
				
				entity_get_vector(ent, EV_VEC_origin, vecOrigin);
				vecOrigin[2] += 30.0;
				entity_set_vector(ent, EV_VEC_origin, vecOrigin);
				
				entity_set_model(ent, __MODEL_FALLEN_TITAN_AURA);
				
				entity_set_int(ent, EV_INT_renderfx, kRenderFxPulseSlow);
				entity_set_int(ent, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(ent, EV_FL_renderamt, 120.0);
			}
		}

		entity_set_float(ent, EV_FL_nextthink, (flGameTime + 0.1));
	}
}

@touch__GrenadeAll(const grenade, const ent) {
	if(!is_nullent(grenade) && isSolid(ent)) {
		new iNadeType = get_entvar(grenade, var_flTimeStepSound);

		if(iNadeType == NADE_TYPE_ION_BOMB) {
			set_entvar(grenade, var_velocity, Float:{0.0, 0.0, 0.0});
		}

		set_entvar(grenade, var_dmgtime, (get_gametime() + 0.001));
	}
}

@touch__BossFireMonster(const boss, const user) {
	if(pev_valid(boss) && g_BossPower[0] == BOSS_POWER_DASH) {
		g_BossPower[0] = 0;
		
		new Float:flGameTime = get_gametime();

		playSound(0, __SOUND_BOSS_IMPACT);
		
		if(pev_valid(user) && is_user_alive(user)) {
			entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(boss, EV_INT_sequence, 7);
			entity_set_float(boss, EV_FL_animtime, flGameTime);
			entity_set_float(boss, EV_FL_framerate, 1.0);
			
			entity_set_int(boss, EV_INT_gamestate, 1);
			
			entity_set_float(boss, EV_FL_nextthink, (flGameTime + 0.866667));
			
			ExecuteHam(Ham_TakeDamage, user, 0, boss, 9999.0, DMG_BURN);
		} else {
			entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(boss, EV_INT_sequence, 15);
			entity_set_float(boss, EV_FL_animtime, flGameTime);
			entity_set_float(boss, EV_FL_framerate, 1.0);
			
			entity_set_int(boss, EV_INT_gamestate, 1);
			
			entity_set_float(boss, EV_FL_nextthink, (flGameTime + 8.033333));

			new Float:vecBossOrigin[3];
			new Float:vecOrigin[3];
			new Float:flDistance;
			new i;

			entity_get_vector(boss, EV_VEC_origin, vecBossOrigin);

			for(i = 1; i <= MaxClients; ++i) {
				if(!is_user_alive(i)) {
					continue;
				}

				entity_get_vector(i, EV_VEC_origin, vecOrigin);
				flDistance = vector_distance(vecBossOrigin, vecOrigin);

				if(flDistance <= 130.0) {
					setAchievement(i, BOSS_FIRE_POR_POCO);
				}
			}
		}
	}
}

@touch__FireMonsterBall(const ent, const all) {
	if(!pev_valid(ent)) {
		return;
	}
	
	new Float:vecOrigin[3];
	new i;
	
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_ArrowExplode);
	write_byte(10);
	write_byte(30);
	write_byte(4);
	message_end();
	
	rh_emit_sound2(ent, 0, CHAN_BODY, __SOUND_BOSS_FIREBALL_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i) && entity_range(ent, i) <= 240.0) {
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, i);
			write_short(1<<14);
			write_short(1<<13);
			write_short(1<<13);
			message_end();
			
			ExecuteHam(Ham_TakeDamage, i, 0, i, (50.0 * float((g_Diff + 1))), DMG_BURN);
			
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, i);
			write_short(UNIT_SECOND * 5);
			write_short(0);
			write_short(SF_FADE_OUT);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(155);
			message_end();
		}
	}
	
	i = entity_get_edict(ent, EV_ENT_euser3);
	
	if(is_valid_ent(i)) {
		remove_entity(i);
	}
	
	remove_entity(ent);
}

@touch__BossFallenTitan(const boss, const id) {
	if(pev_valid(boss) && g_BossPower[0] == BOSS_FT_DASH) {
		g_BossPower[0] = 0;
		
		new Float:flGameTime = get_gametime();
		new Float:vecEntOrigin[3];
		new Float:vecVictimOrigin[3];
		new Float:vecSub[3];

		playSound(0, __SOUND_BOSS_IMPACT);

		entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(boss, EV_INT_sequence, 10); // DASH END
		entity_set_float(boss, EV_FL_animtime, flGameTime);
		entity_set_float(boss, EV_FL_framerate, ((!g_BossFT_Enrage) ? 1.0 : 2.0));
		
		entity_set_int(boss, EV_INT_gamestate, 1);
		
		entity_set_float(boss, EV_FL_nextthink, (flGameTime + ((!g_BossFT_Enrage) ? 1.766667 : 0.883334)));

		entity_get_vector(boss, EV_VEC_origin, vecEntOrigin);
		
		if(pev_valid(id) && is_user_alive(id)) {
			setAchievement(id, BOSS_FT_HIT);

			entity_get_vector(id, EV_VEC_origin, vecVictimOrigin);

			xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub);
			xs_vec_mul_scalar(vecSub, 300.0, vecSub);
			
			vecSub[2] = random_float(150.0, 400.0);

			entity_set_vector(id, EV_VEC_velocity, vecSub);
			
			ExecuteHam(Ham_TakeDamage, id, 0, boss, 50.0, DMG_BLAST);

			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
			write_short(UNIT_SECOND * 5);
			write_short(0);
			write_short(SF_FADE_OUT);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(155);
			message_end();
		} else {
			new i;
			for(i = 1; i <= MaxClients; ++i) {
				if(!is_user_alive(i)) {
					continue;
				}

				entity_get_vector(i, EV_VEC_origin, vecVictimOrigin);

				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 200.0, vecSub);
				
				vecSub[2] = random_float(150.0, 400.0);
				entity_set_vector(i, EV_VEC_velocity, vecSub);
				
				ExecuteHam(Ham_TakeDamage, i, 0, boss, 75.0, DMG_BLAST);
			}

			message_begin(MSG_BROADCAST, g_Message_ScreenShake);
			write_short(1<<14);
			write_short(1<<13);
			write_short(1<<13);
			message_end();
			
			message_begin(MSG_BROADCAST, g_Message_ScreenFade);
			write_short(UNIT_SECOND * 5);
			write_short(0);
			write_short(SF_FADE_OUT);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(155);
			message_end();
		}
	}
}

public task__RespawnPlayer(const task_id) {
	new iId = (task_id - TASK_SPAWN);

	if(!is_user_connected(iId)) {
		return;
	}
	
	if(is_user_alive(iId)) {
		return;
	}
	
	if(g_WaveInProgress) {
		return;
	}

	new TeamName:iTeam = getUserTeam(iId);

	if(!(TEAM_TERRORIST <= iTeam <= TEAM_CT)) {
		return;
	}
	
	rg_round_respawn(iId);
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

	if(iTeam != TEAM_CT) {
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
						setAchievement(iId, SOLO_EL_TD_ME_ENTIENDE);
					}
				}
			}
		}
	}
}

public task__CheckAchievements(const task_id) {
	new iId = (task_id - TASK_CHECK_ACHIEVEMENTS);

	if(!is_user_connected(iId) || dg_get_user_acc_status(iId) < STATUS_LOGGED) {
		return;
	}

	// if(get_arg_systime() < 1622505600) {
		// setAchievement(iId, BETA_TESTER);

		// if(g_Level[iId] >= 4) {
			// setAchievement(iId, BETA_TESTER_AVANZADO);
		// }
	// }

	if((get_user_flags(iId) & ADMIN_RESERVATION)) {
		setAchievement(iId, SOY_DORADO);
	}

	if(g_GoldGaben[iId] >= 10000) {
		setAchievement(iId, GOLD_10K);
		
		if(g_GoldGaben[iId] >= 50000) {
			setAchievement(iId, GOLD_50K);
			
			if(g_GoldGaben[iId] >= 100000) {
				setAchievement(iId, GOLD_100K);
				
				if(g_GoldGaben[iId] >= 500000) {
					setAchievement(iId, GOLD_500K);
					
					if(g_GoldGaben[iId] >= 1000000) {
						setAchievement(iId, GOLD_1M);
						
						if(g_GoldGaben[iId] >= 2500000) {
							setAchievement(iId, GOLD_2M500K);
							
							if(g_GoldGaben[iId] >= 5000000) {
								setAchievement(iId, GOLD_5M);
								
								if(g_GoldGaben[iId] >= 10000000) {
									setAchievement(iId, GOLD_10M);
									
									if(g_GoldGaben[iId] >= 25000000) {
										setAchievement(iId, GOLD_25M);
										
										if(g_GoldGaben[iId] >= 50000000) {
											setAchievement(iId, GOLD_50M);
											
											if(g_GoldGaben[iId] >= 100000000) {
												setAchievement(iId, GOLD_100M);
												
												if(g_GoldGaben[iId] >= 500000000) {
													setAchievement(iId, GOLD_500M);
													
													if(g_GoldGaben[iId] >= 1000000000) {
														setAchievement(iId, GOLD_1000M);
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
	
	if(!g_Achievement[iId][WAVES_NIGHTMARE_100]) {
		if(g_WavesWins[iId][DIFF_NIGHTMARE][0] >= 100) {
			setAchievement(iId, WAVES_NIGHTMARE_100);
		}
	}
	
	if(!g_Achievement[iId][MVP_10]) {
		if(g_WinMVPGaben[iId] >= 1) {
			setAchievement(iId, MVP_1);
			
			if(g_WinMVPGaben[iId] >= 10) {
				setAchievement(iId, MVP_10);
				
				if(g_WinMVPGaben[iId] >= 25) {
					setAchievement(iId, MVP_25);
					
					if(g_WinMVPGaben[iId] >= 50) {
						setAchievement(iId, MVP_50);
						
						if(g_WinMVPGaben[iId] >= 100) {
							setAchievement(iId, MVP_100);
							
							if(g_WinMVPGaben[iId] >= 250) {
								setAchievement(iId, MVP_250);
							}
						}
					}
				}
			}
		}
	}
	
	if(g_Level[iId] >= 10) {
		setAchievement(iId, NIVEL_10);
	}

	if(dg_get_user_acc_vinc(iId)) {
		setAchievement(iId, VINCULADO);
	}
	
	if(g_Achievement[iId][BOSS_GORILA_EXPERTO] && g_Achievement[iId][BOSS_FIRE_EXPERTO] && g_Achievement[iId][BOSS_FT_EXPERTO] && g_Achievement[iId][BOSS_GUARDIANES_EXPERTO]) {
		setAchievement(iId, BALAS_INFINITAS);
	}

	if(checkClassLevel(iId) >= 2) {
		setAchievement(iId, PROTECTOR_NOOB);

		if(checkClassLevel(iId) >= 5) {
			setAchievement(iId, PROTECTOR_AVANZADO);

			if(checkClassLevel(iId) >= 9) {
				setAchievement(iId, PROTECTOR_EXPERTO);

				if(checkClassLevel(iId) >= (structIdClasses - 1)) {
					setAchievement(iId, PROTECTOR_PRO);
				}
			}
		}
	}
}

checkClassLevel(const id) {
	new i;
	new iCount = 0;

	for(i = 0; i < structIdClasses; ++i) {
		if(g_ClassLevel[id][i] >= 6) {
			++iCount;
		}
	}

	return iCount;
}

public task__RemovePowerScouter(const task_id) {
	new iId = (task_id - TASK_CLASS_POWER);

	if(!is_user_alive(iId)) {
		return;
	}

	g_ClassScouter_Hab[iId] = 2;
}

public task__ShowZoneBox(const task_ent) {
	new iEnt = (task_ent - TASK_SHOW_ZONE);

	if(!is_valid_ent(iEnt) || !g_EditorId) {
		return;
	}
	
	new Float:vecEditorOrigin[3];
	new Float:vecOrigin[3];
	new Float:vecHitPoint[3];

	entity_get_vector(g_EditorId, EV_VEC_origin, vecEditorOrigin);
	entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
	
	trace_line(-1, vecEditorOrigin, vecOrigin, vecHitPoint);
	
	if(iEnt == g_Zone[g_ZoneId]) {
		drawLine(vecEditorOrigin[0], vecEditorOrigin[1], (vecEditorOrigin[2] - 16.0), vecOrigin[0], vecOrigin[1], vecOrigin[2], 1);
	}
	
	new Float:flDistanceHead = (vector_distance(vecEditorOrigin, vecOrigin) - vector_distance(vecEditorOrigin, vecHitPoint));

	if((floatabs(flDistanceHead) > 128.0) && (iEnt != g_Zone[g_ZoneId])) {
		return;
	}
	
	new Float:vecMins[3];
	new Float:vecMax[3];
	
	entity_get_vector(iEnt, EV_VEC_mins, vecMins);
	entity_get_vector(iEnt, EV_VEC_maxs, vecMax);
	
	vecMins[0] += vecOrigin[0];
	vecMins[1] += vecOrigin[1];
	vecMins[2] += vecOrigin[2];
	
	vecMax[0] += vecOrigin[0];
	vecMax[1] += vecOrigin[1];
	vecMax[2] += vecOrigin[2];
	
	if(iEnt != g_Zone[g_ZoneId]) {
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMins[0], vecMax[1], vecMax[2]);
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMax[0], vecMins[1], vecMax[2]);
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMax[0], vecMax[1], vecMins[2]);
		drawLine(vecMins[0], vecMins[1], vecMins[2], vecMax[0], vecMins[1], vecMins[2]);
		drawLine(vecMins[0], vecMins[1], vecMins[2], vecMins[0], vecMax[1], vecMins[2]);
		drawLine(vecMins[0], vecMins[1], vecMins[2], vecMins[0], vecMins[1], vecMax[2]);
		drawLine(vecMins[0], vecMax[1], vecMax[2], vecMins[0], vecMax[1], vecMins[2]);
		drawLine(vecMins[0], vecMax[1], vecMins[2], vecMax[0], vecMax[1], vecMins[2]);
		drawLine(vecMax[0], vecMax[1], vecMins[2], vecMax[0], vecMins[1], vecMins[2]);
		drawLine(vecMax[0], vecMins[1], vecMins[2], vecMax[0], vecMins[1], vecMax[2]);
		drawLine(vecMax[0], vecMins[1], vecMax[2], vecMins[0], vecMins[1], vecMax[2]);
		drawLine(vecMins[0], vecMins[1], vecMax[2], vecMins[0], vecMax[1], vecMax[2]);
	} else {
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMins[0], vecMax[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMax[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMax[0], vecMax[1], vecMins[2], 1);
		drawLine(vecMins[0], vecMins[1], vecMins[2], vecMax[0], vecMins[1], vecMins[2], 1);
		drawLine(vecMins[0], vecMins[1], vecMins[2], vecMins[0], vecMax[1], vecMins[2], 1);
		drawLine(vecMins[0], vecMins[1], vecMins[2], vecMins[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMins[0], vecMax[1], vecMax[2], vecMins[0], vecMax[1], vecMins[2], 1);
		drawLine(vecMins[0], vecMax[1], vecMins[2], vecMax[0], vecMax[1], vecMins[2], 1);
		drawLine(vecMax[0], vecMax[1], vecMins[2], vecMax[0], vecMins[1], vecMins[2], 1);
		drawLine(vecMax[0], vecMins[1], vecMins[2], vecMax[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMins[1], vecMax[2], vecMins[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMins[0], vecMins[1], vecMax[2], vecMins[0], vecMax[1], vecMax[2], 1);
	}
	
	if(iEnt != g_Zone[g_ZoneId]) {
		return;
	}
	
	if(g_Direction == 0) {
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMax[0], vecMins[1], vecMins[2], 1);
		drawLine(vecMax[0], vecMax[1], vecMins[2], vecMax[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMins[0], vecMax[1], vecMax[2], vecMins[0], vecMins[1], vecMins[2], 1);
		drawLine(vecMins[0], vecMax[1], vecMins[2], vecMins[0], vecMins[1], vecMax[2], 1);
	}
	
	if(g_Direction == 1) {
		drawLine(vecMins[0], vecMins[1], vecMins[2], vecMax[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMins[1], vecMins[2], vecMins[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMins[0], vecMax[1], vecMins[2], vecMax[0], vecMax[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMax[1], vecMins[2], vecMins[0], vecMax[1], vecMax[2], 1);
	}
	
	if(g_Direction == 2) {
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMins[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMins[1], vecMax[2], vecMins[0], vecMax[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMax[1], vecMins[2], vecMins[0], vecMins[1], vecMins[2], 1);
		drawLine(vecMax[0], vecMins[1], vecMins[2], vecMins[0], vecMax[1], vecMins[2], 1);
	}
}

public task__DamageTower(const task_ent) {
	new iEnt = (task_ent - TASK_DAMAGE_TOWER);

	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	new iDamage = 5;
	
	if(__DIFFS_VALUES[g_Diff][diffValueDamageTower]) {
		iDamage = (iDamage + ((iDamage * __DIFFS_VALUES[g_Diff][diffValueDamageTower]) / 100));
	}
	
	g_TowerHealth -= iDamage;
	g_Achievement_DefensaAbsoluta = 0;
	g_Achievement_FaltaDeDefensores += iDamage;
	
	if(g_TowerHealth > 0) {
		if(!isEggMonster(iEnt)) {
			rh_emit_sound2(iEnt, 0, CHAN_BODY, __SOUND_ZOMBIE_KNIFE[random_num(0, charsmax(__SOUND_ZOMBIE_KNIFE))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	} else {
		removeAllEnts(1);
		finishGame();
		
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_TARGET)) {
		entity_set_int(iEnt, MONSTER_TARGET, 1337);
	}
	
	set_task(1.0, "task__DamageTower", iEnt + TASK_DAMAGE_TOWER);
	
	if(!g_TowerInRegen) {
		g_TowerInRegen = 1;

		if(__DIFFS_VALUES[g_Diff][diffValueTowerRegen]) {
			set_task(5.0, "task__RegenTower", TASK_REGEN_TOWER);
		}
	}
}

public task__DamageTowerEffect(args[7], const task_ent) {
	new iEnt = (task_ent - TASK_DAMAGE_TOWER);

	if(!is_valid_ent(iEnt)) {
		return;
	}

	new Float:flGameTime = get_gametime();
	
	if(!args[6]) {
		entity_set_float(iEnt, EV_FL_nextthink, (flGameTime + 9999.0));
		
		new Float:vecOrigin[3];
		new iVecOrigin[3];
		new iVecEndOrigin[3];
		
		entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
		FVecIVec(vecOrigin, iVecOrigin);
		
		entitySetAim(iEnt, vecOrigin, g_VecEndOrigin[0], .angle_mode=1);
		FVecIVec(g_VecEndOrigin[0], iVecEndOrigin);
		
		args[0] = iVecOrigin[0];
		args[1] = iVecOrigin[1];
		args[2] = iVecOrigin[2];
		args[3] = iVecEndOrigin[0];
		args[4] = iVecEndOrigin[1];
		args[5] = (iVecEndOrigin[2] + random_num(100, 250));
		args[6] = 1;
		
		entity_set_int(iEnt, EV_INT_sequence, 2);
		entity_set_float(iEnt, EV_FL_animtime, flGameTime);
		entity_set_float(iEnt, EV_FL_framerate, 1.0);
		entity_set_int(iEnt, EV_INT_gamestate, 1);
		
		entity_set_size(iEnt, Float:{-16.0, -16.0, -18.0}, Float:{16.0, 16.0, 32.0});
		
		entity_set_vector(iEnt, EV_VEC_mins, Float:{-16.0, -16.0, -18.0});
		entity_set_vector(iEnt, EV_VEC_maxs, Float:{16.0, 16.0, 32.0});
		
		drop_to_floor(iEnt);
		
		entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(iEnt, MONSTER_TARGET, 1337);
		
		set_hudmessage(255, 255, 0, -1.0, 0.26, 0, 0.0, 999.0, 0.0, 0.0, 4);
		ShowSyncHudMsg(0, g_HudSync_DamageTower, "¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!");
		
		set_task(0.1, "task__DamageTowerEffect", iEnt + TASK_DAMAGE_TOWER, args, 7);
		return;
	}
	
	rh_emit_sound2(iEnt, 0, CHAN_BODY, __SOUND_ZOMBIE_LASER[random_num(0, charsmax(__SOUND_ZOMBIE_LASER))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	write_coord(args[0]);
	write_coord(args[1]);
	write_coord(args[2]);
	write_coord(args[3]);
	write_coord(args[4]);
	write_coord(args[5]);
	write_short(g_Sprite_Trail);
	write_byte(0);
	write_byte(0);
	write_byte(7);
	write_byte(25);
	write_byte(10);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	write_byte(1);
	message_end();
	
	set_task(1.0, "task__DamageTowerEffect", iEnt + TASK_DAMAGE_TOWER, args, 7);
}

public task__SentryAimToTarget(const args[4], const task_ent) {
	new iEnt = (task_ent - TASK_SENTRY_THINK);

	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, SENTRY_INT_FIRE)) {
		return;
	}
	
	new iMonster = args[3];
	
	if(!is_valid_ent(iMonster)) {
		return;
	}
	
	new Float:vecSentryOrigin[3];
	new Float:vecClosestOrigin[3];
	
	vecSentryOrigin[0] = float(args[0]);
	vecSentryOrigin[1] = float(args[1]);
	vecSentryOrigin[2] = float(args[2]);
	
	entity_get_vector(iMonster, EV_VEC_origin, vecClosestOrigin);
	
	sentryTurnToTarget(iEnt, vecSentryOrigin, iMonster, vecClosestOrigin);
}

public task__IonBombExplode(const task_ent) {
	new iEnt = (task_ent - TASK_ION_BOMB_EXPLODE);

	if(is_nullent(iEnt)) {
		return;
	}

	set_entvar(iEnt, var_flSwimTime, 0);

	new Float:vecOrigin[3];
	new iVictim;

	get_entvar(iEnt, var_origin, vecOrigin);
	createExplosion(vecOrigin, 71, 60, 139, 120);

	iVictim = -1;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 9999.9)) != 0) {
		if(is_nullent(iVictim)) {
			continue;
		}

		if(!isMonster(iVictim)) {
			continue;
		}

		if(isBoomerMonster(iVictim)) {
			continue;
		}

		if(entity_get_float(iVictim, EV_FL_takedamage) != DAMAGE_YES) {
			continue;
		}

		if(entity_get_int(iVictim, EV_INT_flTimeStepSound) != 1337) {
			continue;
		}

		removeMonster(iVictim, 1337, 1);
	}
}

public task__SetConfigs() {
	set_cvar_string("hostname", fmt("#19 TOWER DEFENSE [%s] | www.DrunkGaming.net", __PLUGIN_VERSION));
	set_cvar_num("sv_restart", 1);
}

public task__StartGame() {
	if(getUsersAlive() >= 1) {
		g_StartGame = 0;
		g_NextWaveIncoming = 1;
		
		clearDirectorHud();
		set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
		
		set_task(3.0, "task__StartWave", TASK_WAVES);
	} else {
		g_StartGame = 1;
		g_StartSeconds = 59;
		g_NextWaveIncoming = 0;
		
		set_task(60.0, "task__StartGame", TASK_START_GAME);
		set_task(1.0, "task__RepeatHud2", TASK_START_GAME, .flags="a", .repeat=59);
		set_task(59.0, "task__EndVoteDiff");
	}
}

public task__RepeatHud2() {
	--g_StartSeconds;
	
	if(!g_StartSeconds) {
		g_StartGame = 0;
		g_NextWaveIncoming = 1;
	}
	
	clearDirectorHud();
	set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
}

public task__StartWave() {
	if(g_EndGame) {
		return;
	}

	if(!getUsersAlive()) {
		if(g_Wave) {
			g_NextWaveIncoming = 0;
			g_TotalMonsters = 59;
			
			clearDirectorHud();
			set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
			
			set_task(64.0, "task__StartWave", TASK_WAVES);
			set_task(1.0, "task__RepeatHud", .flags="a", .repeat=60);
		} else {
			g_StartGame = 1;
			g_StartSeconds = 59;
			g_NextWaveIncoming = 0;
			
			set_task(60.0, "task__StartGame", TASK_START_GAME);
			set_task(1.0, "task__RepeatHud2", TASK_START_GAME, .flags="a", .repeat=59);
			set_task(59.0, "task__EndVoteDiff");
		}
		
		return;
	}

	new i;
	new j;

	g_WaveInProgress = 1;
	g_NextWaveIncoming = 0;
	g_SpecialWave = 0;
	g_MonstersAlive = 0;
	g_MonstersKills = 0;
	g_SendMonsterSpecial = 0;
	g_EggCache = 0;
	g_BestPlayerKills = 0;
	g_BestPlayerId = 0;
	g_RobotMissileAllowed = 1;
	g_Monsters_Spawn = 0;
	g_Monsters_Kills = 0;
	g_SpecialMonsters_Spawn = 0;
	g_SpecialMonsters_Kills = 0;
	g_Achievement_FaltaDeDefensores = 0;

	for(i = 1; i <= MaxClients; ++i) {
		g_ClassSoporte_Hab[i] = 0;
		g_ClassScouter_Hab[i] = 0;
	}

	if(g_Wave == 1337) {
		g_Wave = MAX_WAVES;

		endGame();
		return;
	} else if(g_Wave == 1338) {
		g_Wave = MAX_WAVES;
	}

	if((g_Wave + 1) == g_ExtraWaveSpeed && g_Diff >= DIFF_SUICIDAL) {
		g_SpecialWave = MONSTER_TYPE_SPECIAL_SPEED;
		
		removeAllEnts(0);
		
		g_TotalMonsters = 0;
		g_TotalMonsters += (((g_Wave + 1) * 25) + getTotalLevel());
		g_MonstersShield = 0;
		g_MonstersWithShield = 6;
		
		clearDirectorHud();
		set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
		
		set_task(0.5, "task__CountDownSendMonsters");
		return;
	} else if((g_Wave + 1) == g_ExtraWaveStrength && g_Diff >= DIFF_HELL) {
		g_SpecialWave = MONSTER_TYPE_SPECIAL_STRENGTH;
		
		removeAllEnts(0);
		
		g_TotalMonsters = 0;
		g_TotalMonsters += (((g_Wave + 1) * 10) + getTotalLevel());
		g_MonstersShield = 0;
		g_MonstersWithShield = 6;
		
		clearDirectorHud();
		set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
		
		set_task(0.5, "task__CountDownSendMonsters");
		return;
	}
	
	++g_Wave;

	if(g_Wave < (MAX_WAVES + 1)) {
		removeAllEnts(0);

		g_TotalMonsters = 0;
		g_TotalMonsters += (clamp(getUsersAlive(), 2, MaxClients) * ((g_Wave + 1) * 10));
		
		if(__DIFFS_VALUES[g_Diff][diffValueMaxMonsters]) {
			g_TotalMonsters = (g_TotalMonsters + ((g_TotalMonsters * (__DIFFS_VALUES[g_Diff][diffValueMaxMonsters])) / 100));
		}
		
		if(__MAPS[g_MapId][mapExtraMonsters] > 0) {
			g_TotalMonsters = (g_TotalMonsters + ((g_TotalMonsters * __MAPS[g_MapId][mapExtraMonsters]) / 100));
		}

		if(g_Tramposo) {
			g_TotalMonsters = 20;
		}

		--g_TotalMonsters;
		g_MonstersShield = 0;
		g_MonstersWithShield = ((g_TotalMonsters * (5 * g_Wave)) / 100);
		
		g_TimePerWave_SysTime[(g_Wave - 1)] = get_arg_systime();
		
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			g_TimePerWave_Ids[i] = i;
		}
		
		clearDirectorHud();
		set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);

		switch(g_Wave) {
			case 1: {
				for(i = 1; i <= MaxClients; ++i) {
					if(!is_user_alive(i)) {
						continue;
					}
					
					if(g_ClassId[i] == CLASS_SOPORTE) {
						continue;
					}

					if(((g_ClassId[i] == CLASS_SOLDADO || g_ClassId[i] == CLASS_INGENIERO || g_ClassId[i] == CLASS_PESADO || g_ClassId[i] == CLASS_ASALTO || g_ClassId[i] == CLASS_COMANDANTE || g_ClassId[i] == CLASS_PUBERO) && g_ClassLevel[i][g_ClassId[i]] < 6) ||
						(g_ClassId[i] == CLASS_FRANCOTIRADOR && g_ClassLevel[i][g_ClassId[i]] < 4)) {
						continue;
					}

					switch(g_ClassId[i]) {
						case CLASS_SOLDADO: {
							rg_give_item(i, "weapon_m4a1", GT_APPEND);
							rg_set_user_bpammo(i, WEAPON_M4A1, 200);
						} case CLASS_INGENIERO: {
							++g_Sentry[i];
						} case CLASS_FRANCOTIRADOR: {
							if(user_has_weapon(i, _:WEAPON_SMOKEGRENADE)) {
								rg_set_user_bpammo(i, WEAPON_SMOKEGRENADE, (rg_get_user_bpammo(i, WEAPON_SMOKEGRENADE) + 1));
							} else {
								rg_give_item(i, "weapon_smokegrenade");
							}
							
							++g_Nades[i][NADE_AUMENTA_DMG_RECIBIDO];
						} case CLASS_PESADO: {
							++g_Power[i][POWER_RAYO];
						} case CLASS_ASALTO: {
							rg_give_item(i, "weapon_galil", GT_APPEND);
							rg_set_user_bpammo(i, WEAPON_GALIL, 200);
						} case CLASS_COMANDANTE: {
							rg_give_item(i, "weapon_aug", GT_APPEND);
							rg_set_user_bpammo(i, WEAPON_AUG, 200);
						} case CLASS_PUBERO: {
							rg_give_item(i, "weapon_g3sg1", GT_APPEND);
							rg_set_user_bpammo(i, WEAPON_G3SG1, 200);
						}
					}
				}
			} case 4, 7, 10: {
				if(!g_Tramposo) {
					g_SendMonsterSpecial = 1;
					++g_TotalMonsters;
				}
			}
		}

		if(g_Wave >= 4) {
			if(g_Diff == DIFF_NORMAL && g_Wave >= 8) {
				g_EggCache = 1;
			} else if(g_Diff == DIFF_NIGHTMARE && g_Wave >= 5) {
				g_EggCache = 1;
			} else if(g_Diff == DIFF_HELL || g_Diff == DIFF_SUICIDAL) {
				g_EggCache = 1;
			}
		}
		
		set_task(0.5, "task__CountDownSendMonsters");
	} else {
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			updateHealth(i, HEALTH_BASE_BOSS_GORILLA);
			
			rg_drop_item(i, "weapon_hegrenade");
			rg_drop_item(i, "weapon_flashbang");
			rg_drop_item(i, "weapon_smokegrenade");
			
			reloadWeapons(i);
			
			g_UnlimitedClip[i] = 0;
			g_PrecisionPerfecta[i] = 0;
			g_PowerActual[i] = POWER_NONE;
			g_Sentry[i] = 0;
			g_Robot[i] = 0;
			
			for(j = 0; j < structIdPowers; ++j) {
				if(j == POWER_BALAS_INFINITAS || j == POWER_PRECISION_PERFECTA) {
					continue;
				}

				g_Power[i][j] = 0;
			}
		}
		
		removeAllEnts(1);
		
		g_NextWaveIncoming = 2;
		
		clearDirectorHud();
		set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
		
		createMiniBoss();
		specialEffectToBoss();
	}
}

public task__RegenTower() {
	if(g_TowerHealth && g_TowerHealth < g_TowerMaxHealth) {
		g_TowerHealth = clamp((g_TowerHealth + __DIFFS_VALUES[g_Diff][diffValueTowerRegen]), 0, g_TowerMaxHealth);

		if(g_TowerHealth >= g_TowerMaxHealth) {
			g_TowerInRegen = 0;
		}

		set_task(5.0, "task__RegenTower", TASK_REGEN_TOWER);
	}
}

public task__AllowDropAnotherMonster() {
	return;
}

public task__CheckZombiesBugFix() {
	if(!g_WaveInProgress) {
		return;
	}
	
	new iEnt = -1;
	new iMonstersAlive = 0;
	// new Float:vecOrigin[3];

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_MONSTER))) {
		if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
			++iMonstersAlive;
		}
	}
	
	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_EGG_MONSTER))) {
		if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
			++iMonstersAlive;
		}
	}
	
	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_SPECIAL_MONSTER))) {
		if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
			++iMonstersAlive;
		}
	}
	
	while(g_MonstersAlive > iMonstersAlive) {
		// log_to_file(__BUGS_FILE, "g_MonstersAlive=%d | g_TotalMonsters=%d | g_WaveInProgress=%d | Wave=%d", g_MonstersAlive, g_TotalMonsters, g_WaveInProgress, g_Wave);
		// log_to_file(__BUGS_FILE, "g_SpecialMonsters_Spawn=%d | g_SpecialMonsters_Kills=%d | g_Monsters_Spawn=%d | g_Monsters_Kills=%d", g_SpecialMonsters_Spawn, g_SpecialMonsters_Kills, g_Monsters_Spawn, g_Monsters_Kills);
		// log_to_file(__BUGS_FILE, "iMonstersAlive=%d", iMonstersAlive);
		
		// while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_MONSTER))) {
			// if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file(__BUGS_FILE, "VIVO (1) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// } else {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file(__BUGS_FILE, "MUERTO (1) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// }
		// }
		
		// while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_EGG_MONSTER))) {
			// if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file(__BUGS_FILE, "VIVO (2) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// } else {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file(__BUGS_FILE, "MUERTO (2) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// }
		// }
		
		// while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_SPECIAL_MONSTER))) {
			// if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file(__BUGS_FILE, "VIVO (3) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// } else {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file(__BUGS_FILE, "MUERTO (3) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// }
		// }
		
		--g_MonstersAlive;
		--g_TotalMonsters;
	}
	
	if(g_TotalMonsters < 1) {
		endWave();
	}
}

public task__BackToRide(const boss) {
	if(is_valid_ent(boss)) {
		entity_set_float(boss, EV_FL_nextthink, (get_gametime() + 0.1));
	}
}

public task__ChangeSolidState(const monster) {
	if(is_valid_ent(monster)) {
		entity_set_int(monster, EV_INT_solid, SOLID_BBOX);
	}
}

public task__ChangeMoveType(const monster) {
	if(is_valid_ent(monster)) {
		entity_set_int(monster, EV_INT_movetype, MOVETYPE_FLY);
		
		if(g_Boss == monster && g_BossId == BOSS_GUARDIANES) {
			entity_set_int(monster, EV_INT_solid, SOLID_NOT);
		}
	}
}

public task__DeleteMonsterEnt(const monster) {
	if(is_valid_ent(monster)) {
		remove_entity(monster);
	}
}

public task__DeleteMonsterEntBoss(const boss) {
	if(is_valid_ent(boss)) {
		remove_entity(boss);
	}
}

public task__BackToTrack(const monster) {
	if(is_valid_ent(monster) && entity_get_int(monster, MONSTER_MAXHEALTH)) {
		new iTrack = entity_get_int(monster, MONSTER_TRACK);
		new sClassName[20];
		new iTarget;
		new Float:vecMonsterOrigin[3];
		new Float:vecOrigin[3];
		new Float:flVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sClassName, charsmax(sClassName), "track%d", iTrack);
		iTarget = find_ent_by_tname(-1, sClassName);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, ((iTrack < 100) ? "end" : "end1"));

			if(!is_valid_ent(iTarget)) {
				iTarget = find_ent_by_tname(-1, "end");
			}
		}
		
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, flVelocity);
	}
}

public task__EntFly(const monster) { // Una vez que respawnee el huevillo, acá convierte la entidad en un monstruo normal.
	if(!is_valid_ent(monster)) {
		remove_entity(monster);
		return;
	}

	new Float:vecVelocity[3];
	new Float:flLength;

	entity_get_vector(monster, EV_VEC_velocity, vecVelocity);
	flLength = vector_length(vecVelocity);

	if(flLength >= 5.0) {
		remove_entity(monster);
		return;
	}

	entity_set_string(monster, EV_SZ_classname, __ENT_CLASSNAME_SPECIAL_MONSTER);
	
	new Float:vecOrigin[3];
	new iHealth = (random_num(100, 150) * g_Wave);
	
	if(__DIFFS_VALUES[g_Diff][diffValueHealth]) {
		iHealth = (iHealth + ((iHealth * __DIFFS_VALUES[g_Diff][diffValueHealth]) / 100));
	}
	
	if(iHealth > g_MonsterMaxHealth) {
		iHealth = g_MonsterMaxHealth;
	}
	
	entity_set_model(monster, __MODELS_ZOMBIE_NORMAL[random_num(0, charsmax(__MODELS_ZOMBIE_NORMAL))]);

	entity_set_int(monster, EV_INT_solid, SOLID_BBOX);
	entity_set_int(monster, EV_INT_movetype, MOVETYPE_FLY);
	
	entity_set_float(monster, EV_FL_health, float(iHealth));
	entity_set_float(monster, EV_FL_takedamage, DAMAGE_YES);
	
	entity_set_int(monster, MONSTER_MAXHEALTH, iHealth);
	
	entity_get_vector(monster, EV_VEC_origin, vecOrigin);
	vecOrigin[2] += 36.0;
	entity_set_vector(monster, EV_VEC_origin, vecOrigin);
	
	entity_set_int(monster, MONSTER_TYPE, MONSTER_TYPE_EGG);
	
	new Float:vecMins[3];
	new Float:vecMax[3];
	
	vecMins = Float:{-16.0, -16.0, -30.0};
	vecMax = Float:{16.0, 16.0, 36.0};
	
	entity_set_size(monster, vecMins, vecMax);
	
	entity_set_vector(monster, EV_VEC_mins, vecMins);
	entity_set_vector(monster, EV_VEC_maxs, vecMax);
	
	entity_set_int(monster, EV_INT_sequence, 4);
	entity_set_float(monster, EV_FL_animtime, get_gametime());
	entity_set_float(monster, EV_FL_framerate, 1.0);
	
	entity_set_int(monster, EV_INT_gamestate, 1);
	
	if(isPlayerStuck(monster)) {
		removeMonster(monster, 1337);
	} else {
		entity_set_float(monster, EV_FL_nextthink, (get_gametime() + 0.1));
	}

	new sArgs[7];

	set_task(32.9, "task__DamageTowerEffect", monster + TASK_DAMAGE_TOWER, sArgs, 6);
	set_task(33.0, "task__DamageTower", monster + TASK_DAMAGE_TOWER);
}

public task__EntFlyInBoss(const monster) {
	if(!is_valid_ent(monster)) {
		remove_entity(monster);
		return;
	}

	new Float:vecVelocity[3];
	new Float:flLength;

	entity_get_vector(monster, EV_VEC_velocity, vecVelocity);
	flLength = vector_length(vecVelocity);

	if(flLength >= 5.0) {
		set_task(0.25, "task__EntFlyInBoss", monster);
		return;
	}

	entity_set_string(monster, EV_SZ_classname, __ENT_CLASSNAME_SPECIAL_MONSTER);
	
	new Float:vecOrigin[3];
	new iHealth = (random_num(100, 150) * g_Wave);
	
	if(__DIFFS_VALUES[g_Diff][diffValueHealth]) {
		iHealth = (iHealth + ((iHealth * __DIFFS_VALUES[g_Diff][diffValueHealth]) / 100));
	}
	
	if(iHealth > g_MonsterMaxHealth) {
		iHealth = g_MonsterMaxHealth;
	}
	
	entity_set_model(monster, __MODELS_ZOMBIE_NORMAL[random_num(0, charsmax(__MODELS_ZOMBIE_NORMAL))]);

	entity_set_int(monster, EV_INT_solid, SOLID_BBOX);
	entity_set_int(monster, EV_INT_movetype, MOVETYPE_FLY);
	
	entity_set_float(monster, EV_FL_health, float(iHealth));
	entity_set_float(monster, EV_FL_takedamage, DAMAGE_YES);
	
	entity_set_int(monster, MONSTER_MAXHEALTH, iHealth);
	
	entity_get_vector(monster, EV_VEC_origin, vecOrigin);
	vecOrigin[2] += 36.0;
	entity_set_vector(monster, EV_VEC_origin, vecOrigin);
	
	entity_set_int(monster, MONSTER_TYPE, MONSTER_TYPE_EGG);
	
	new Float:vecMins[3];
	new Float:vecMax[3];
	
	vecMins = Float:{-16.0, -16.0, -30.0};
	vecMax = Float:{16.0, 16.0, 36.0};
	
	entity_set_size(monster, vecMins, vecMax);
	
	entity_set_vector(monster, EV_VEC_mins, vecMins);
	entity_set_vector(monster, EV_VEC_maxs, vecMax);
	
	entity_set_int(monster, EV_INT_sequence, 4);
	entity_set_float(monster, EV_FL_animtime, get_gametime());
	entity_set_float(monster, EV_FL_framerate, 1.0);
	
	entity_set_int(monster, EV_INT_gamestate, 1);
	
	if(isPlayerStuck(monster)) {
		removeMonster(monster, 1337);
	} else {
		entity_set_float(monster, EV_FL_nextthink, (get_gametime() + 0.1));
	}
}

public task__EffectSpecialBoss(const miniboss) {
	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 4);
	write_short(UNIT_SECOND * 4);
	write_short(SF_FADE_IN);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
	
	set_task(4.5, "task__RemoveEffectSpecialBoss", miniboss);
}

public task__RemoveEffectSpecialBoss(const miniboss) {
	new iHealth;
	new iEnt = -1;
	new Float:vecOrigin[3];
	new i = 1;

	switch(g_BossId) {
		case BOSS_GORILA: {
			iHealth = HEALTH_BASE_BOSS_GORILLA;
		} case BOSS_FIRE: {
			iHealth = HEALTH_BASE_BOSS_FIRE_MONSTER;
		} case BOSS_FALLEN_TITAN: {
			iHealth = HEALTH_BASE_BOSS_FALLEN_TITAN;
		} case BOSS_GUARDIANES: {
			iHealth = HEALTH_BASE_BOSS_GUARDIANES_DE_KYRA;
		}
	}
	
	while((iEnt = rg_find_ent_by_class(iEnt, "info_vip_start")) != 0) {
		get_entvar(iEnt, var_origin, vecOrigin);
		
		while(!is_user_alive(i) && i <= MaxClients) {
			++i;
		}
		
		if(i > MaxClients) {
			break;
		}

		updateHealth(i, iHealth);

		set_entvar(i, var_origin, vecOrigin);
		
		++i;
	}
	
	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 4);
	write_short(0);
	write_short(SF_FADE_OUT);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
	
	if(g_BossId != BOSS_GUARDIANES) {
		if(is_valid_ent(miniboss)) {
			remove_entity(miniboss);
		}
	} else {
		new i;
		for(i = 0; i < 3; ++i) {
			if(is_valid_ent(g_MiniBoss_Ids[i])) {
				remove_entity(g_MiniBoss_Ids[i]);
			}
		}
	}
	
	createBoss();
}

public task__ChangeMap(const map_id) {
	if(map_id >= 0) {
		server_cmd("changelevel %a", ArrayGetStringHandle(g_aMapName, map_id));
	} else {
		server_cmd("changelevel td_kmid");
	}
}

public task__RefillBPAmmo(const args[], const id) {
	if(!is_user_alive(id)) {
		return;
	}
	
	set_msg_block(g_Message_AmmoPickup, BLOCK_ONCE);
	ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[args[0]], __AMMO_TYPE[args[0]], __MAX_BPAMMO[args[0]]);
}

public task__ShowHud() {
	clearDirectorHud();
	set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
}

public task__EndVoteDiff() {
	if(!task_exists(TASK_START_GAME)) {
		return;
	}

	new i;
	new iNormal = 0;
	new iNightmare = 0;
	new iSuicidal = 0;
	new iHell = 0;
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i) || dg_get_user_acc_status(i) < STATUS_PLAYING) {
			continue;
		}

		switch(g_VoteDiff[i]) {
			case DIFF_NORMAL: {
				iNormal++;
			} case DIFF_NIGHTMARE: {
				iNightmare++;
			} case DIFF_SUICIDAL: {
				iSuicidal++;
			} case DIFF_HELL: {
				iHell++;
			}
		}
	}
	
	if((iNormal + iNightmare + iSuicidal + iHell) < 1) {
		return;
	}

	g_EndVote = 1;
	
	new iMax;
	new iDiffWin = DIFF_NORMAL;
	
	if(iNormal > iMax) {
		iMax = iNormal;
		iDiffWin = DIFF_NORMAL;
	}
	
	if(iNightmare > iMax) {
		iMax = iNightmare;
		iDiffWin = DIFF_NIGHTMARE;
	}
	
	if(iSuicidal > iMax) {
		iMax = iSuicidal;
		iDiffWin = DIFF_SUICIDAL;
	}
	
	if(iHell > iMax) {
		iMax = iHell;
		iDiffWin = DIFF_HELL;
	}
	
	g_Diff = iDiffWin;
	
	clientPrintColor(0, _, "Votación finalizada.");
	clientPrintColor(0, _, "La dificultad ganadora es !t%s!y con !g%d voto%s!y.", __DIFFS[g_Diff][diffNameMay], iMax, ((iMax != 1) ? "s" : ""));

	switch(g_Diff) {
		case DIFF_NORMAL: {
			g_MonsterMaxHealth = 750;
		} case DIFF_NIGHTMARE: {
			g_MonsterMaxHealth = 1000;
		} case DIFF_SUICIDAL: {
			g_MonsterMaxHealth = 100000;
		} case DIFF_HELL: {
			g_MonsterMaxHealth = 250000;
		}
	}

	g_DamageNeedToGold = ((400 + (100 * g_Diff)) / ((20 * __DIFFS_VALUES[g_Diff][diffValueGold]) / 100));
}

public task__RepeatHud() {
	--g_TotalMonsters;
	
	if(!g_TotalMonsters) {
		if(g_Wave < MAX_WAVES) {
			g_NextWaveIncoming = 1;
		} else {
			g_NextWaveIncoming = 2;
		}
	}
	
	clearDirectorHud();
	set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
}

public task__CreateSentryHead(const args[2]) {
	new iEntBase = args[0];
	new id = args[1];
	
	if(!is_user_connected(id)) {
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		--g_SentryCountTotal;

		return;
	}
	
	if(!is_valid_ent(iEntBase)) {
		g_InBuilding[id] = 0;
		
		++g_Sentry[id];
		--g_SentryCountTotal;

		return;
	}
	
	if(!g_InBuilding[id]) {
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		++g_Sentry[id];
		--g_SentryCountTotal;

		return;
	}

	new iEnt = create_entity("func_wall");
	
	if(!iEnt) {
		g_InBuilding[id] = 0;

		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}

		++g_Sentry[id];
		--g_SentryCountTotal;

		return;
	}

	new Float:vecOrigin[3];
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	vecOrigin = g_SentryOrigin[id];

	if(is_valid_ent(iEntBase)) {
		vecMins[0] = -16.0;
		vecMins[1] = -16.0;
		vecMins[2] = 0.0;
		
		vecMaxs[0] = 16.0;
		vecMaxs[1] = 16.0;
		vecMaxs[2] = 16.0;
		
		entity_set_size(iEntBase, vecMins, vecMaxs);

		entity_set_edict(iEnt, SENTRY_ENT_BASE, iEntBase);
		entity_set_edict(iEntBase, BASE_ENT_SENTRY, iEnt);
	}
	
	DispatchSpawn(iEnt);
	
	vecMins[0] = -16.0;
	vecMins[1] = -16.0;
	vecMins[2] = 0.0;
	
	vecMaxs[0] = 16.0;
	vecMaxs[1] = 16.0;
	vecMaxs[2] = 48.0;
	
	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_SENTRY);
	entity_set_model(iEnt, __MODELS_SENTRY[0]);
	
	entity_set_size(iEnt, vecMins, vecMaxs);
	
	entity_set_origin(iEnt, vecOrigin);
	
	entity_get_vector(id, EV_VEC_angles, vecOrigin);
	
	entity_set_int(iEnt, SENTRY_OWNER, id);
	entity_set_int(iEntBase, SENTRY_OWNER, id);
	
	vecOrigin[0] = 0.0;
	vecOrigin[1] += 180.0;
	vecOrigin[2] = 0.0;
	
	entity_set_vector(iEnt, EV_VEC_angles, vecOrigin);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
	
	entity_set_byte(iEnt, SENTRY_TILT_TURRET, 127);
	entity_set_byte(iEnt, SENTRY_TILT_LAUNCHER, 127);
	entity_set_byte(iEnt, SENTRY_TILT_RADAR, 127);
	
	entity_set_int(iEnt, SENTRY_INT_LEVEL, 1);
	
	new iColorMap = 150 | (160 << 8);
	entity_set_int(iEnt, EV_INT_colormap, iColorMap);

	rh_emit_sound2(iEnt, 0, CHAN_AUTO, __SOUND_SENTRY_HEAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	entity_set_float(iEnt, SENTRY_PARAM_01, 0.0);
	
	entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 1.5));
	
	if(g_Diff == DIFF_NORMAL) {
		entity_set_int(iEnt, SENTRY_CLIP, 1000000);
		entity_set_int(iEntBase, SENTRY_CLIP, 1000000);

		entity_set_float(iEnt, SENTRY_MAXCLIP, 1000000.0);
	} else {
		entity_set_int(iEnt, SENTRY_CLIP, __SENTRIES_MAXCLIP[1] + __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryClip]);
		entity_set_int(iEntBase, SENTRY_CLIP, __SENTRIES_MAXCLIP[1] + __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryClip]);

		entity_set_float(iEnt, SENTRY_MAXCLIP, float(__SENTRIES_MAXCLIP[1]) + __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryClip]);
	}
	
	entity_set_float(iEnt, SENTRY_EXTRA_DAMAGE, __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryDamage]);
	entity_set_float(iEnt, SENTRY_EXTRA_RATIO, __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryRecoil]);

	entity_get_vector(iEntBase, EV_VEC_origin, g_SentryOrigin[id]);

	new iArgs[4];
	
	iArgs[0] = iEntBase;
	iArgs[1] = iEnt;
	iArgs[2] = id;
	iArgs[3] = floatround(g_SentryOrigin[id][2]);
	
	set_task(2.0, "task__CheckSentryStuck", _, iArgs, sizeof(iArgs));
	
	g_InBuilding[id] = 0;
	
	entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
	entity_set_float(iEnt, EV_FL_animtime, 1.0);
	entity_set_float(iEnt, EV_FL_framerate, 1.0);
}

public task__MoveSentryHead(const args[3]) {
	new iEntBase = args[0];
	new id = args[1];
	new iSentry = args[2];
	
	if(!is_user_connected(id)) {
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		return;
	}

	if(!is_valid_ent(iEntBase)) {
		g_InBuilding[id] = 0;
		
		return;
	}
	
	if(!g_InBuilding[id]) {
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		return;
	}

	new iEnt = create_entity("func_wall");
	
	if(!iEnt) {
		g_InBuilding[id] = 0;

		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		return;
	}

	new Float:vecOrigin[3];
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	vecOrigin = g_SentryOrigin[id];

	if(is_valid_ent(iEntBase)) {
		vecMins[0] = -16.0;
		vecMins[1] = -16.0;
		vecMins[2] = 0.0;
		
		vecMaxs[0] = 16.0;
		vecMaxs[1] = 16.0;
		vecMaxs[2] = 16.0;
		
		entity_set_size(iEntBase, vecMins, vecMaxs);

		entity_set_edict(iEnt, SENTRY_ENT_BASE, iEntBase);
		entity_set_edict(iEntBase, BASE_ENT_SENTRY, iEnt);
	}

	DispatchSpawn(iEnt);
	
	vecMins[0] = -16.0;
	vecMins[1] = -16.0;
	vecMins[2] = 0.0;
	
	vecMaxs[0] = 16.0;
	vecMaxs[1] = 16.0;
	vecMaxs[2] = 48.0;

	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_SENTRY);
	entity_set_model(iEnt, __MODELS_SENTRY[0]);

	entity_set_size(iEnt, vecMins, vecMaxs);
	
	entity_set_origin(iEnt, vecOrigin);
	
	entity_get_vector(id, EV_VEC_angles, vecOrigin);
	
	entity_set_int(iEnt, SENTRY_OWNER, id);
	entity_set_int(iEntBase, SENTRY_OWNER, id);

	vecOrigin[0] = 0.0;
	vecOrigin[1] += 180.0;
	vecOrigin[2] = 0.0;
	
	entity_set_vector(iEnt, EV_VEC_angles, vecOrigin);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
	
	entity_set_byte(iEnt, SENTRY_TILT_TURRET, 127);
	entity_set_byte(iEnt, SENTRY_TILT_LAUNCHER, 127);
	entity_set_byte(iEnt, SENTRY_TILT_RADAR, 127);
	
	entity_set_int(iEnt, SENTRY_INT_LEVEL, 1);

	new iColorMap = 150 | (160 << 8);
	entity_set_int(iEnt, EV_INT_colormap, iColorMap);

	rh_emit_sound2(iEnt, 0, CHAN_AUTO, __SOUND_SENTRY_HEAD, 1.0, ATTN_NORM, 0, PITCH_NORM);

	entity_set_float(iEnt, SENTRY_PARAM_01, 0.0);
	
	entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 1.5));
	
	if(g_Diff == DIFF_NORMAL) {
		entity_set_int(iEnt, SENTRY_CLIP, 1000000);
		entity_set_int(iEntBase, SENTRY_CLIP, 1000000);

		entity_set_float(iEnt, SENTRY_MAXCLIP, 1000000.0);
	} else {
		entity_set_int(iEnt, SENTRY_CLIP, __SENTRIES_MAXCLIP[1] + __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryClip]);
		entity_set_int(iEntBase, SENTRY_CLIP, __SENTRIES_MAXCLIP[1] + __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryClip]);

		entity_set_float(iEnt, SENTRY_MAXCLIP, float(__SENTRIES_MAXCLIP[1]) + __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryClip]);
	}
	
	entity_set_float(iEnt, SENTRY_EXTRA_DAMAGE, __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryDamage]);
	entity_set_float(iEnt, SENTRY_EXTRA_RATIO, __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribSentryRecoil]);

	entity_get_vector(iEntBase, EV_VEC_origin, g_SentryOrigin[id]);

	new iArgs[5];
	
	iArgs[0] = iEntBase;
	iArgs[1] = iEnt;
	iArgs[2] = id;
	iArgs[3] = floatround(g_SentryOrigin[id][2]);
	iArgs[4] = iSentry;
	
	set_task(2.0, "task__CheckMoveSentryStuck", _, iArgs, sizeof(iArgs));
	
	g_InBuilding[id] = 0;
	
	entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
	entity_set_float(iEnt, EV_FL_animtime, 1.0);
	entity_set_float(iEnt, EV_FL_framerate, 1.0);
}

public task__CheckSentryStuck(const args[4]) {
	if(!is_valid_ent(args[0])) {
		return;
	}

	if(!is_valid_ent(args[1])) {
		return;
	}

	new Float:vecOrigin[3];
	new iDifference;
	
	entity_get_vector(args[0], EV_VEC_origin, vecOrigin);
	iDifference = abs(floatround(vecOrigin[2]) - args[3]);

	if(iDifference > 2) {
		remove_entity(args[0]);

		if(is_valid_ent(args[1])) {
			remove_entity(args[1]);
		}

		if(is_user_connected(args[2])) {
			clientPrintColor(args[2], _, "La torreta que acabas de construir se bloqueó con alguna pared invisible, se ha devuelto a tu inventario.");
			
			++g_Sentry[args[2]];
			--g_SentryCountTotal;
		}
	} else {
		entity_set_int(args[0], SENTRY_LOW_FPS, 2);
		entity_set_int(args[1], SENTRY_LOW_FPS, 2);
	}
}

public task__CheckMoveSentryStuck(const args[5]) {
	if(!is_valid_ent(args[0])) {
		return;
	}

	new Float:vecEntBaseOrigin[3];
	new Float:vecEntTopOrigin[3];
	new iDifference;

	entity_get_vector(args[0], EV_VEC_origin, vecEntBaseOrigin);
	entity_get_vector(args[1], EV_VEC_origin, vecEntTopOrigin);

	iDifference = abs(floatround(vecEntBaseOrigin[2]) - args[3]);

	if(iDifference > 2) {
		remove_entity(args[0]);

		if(is_valid_ent(args[1])) {
			remove_entity(args[1]);
		}

		if(is_user_connected(args[2])) {
			clientPrintColor(args[2], _, "No se puede mover tu torreta acá porque se bloqueó con una pared invisible.");
		}
	} else {
		remove_entity(args[0]);

		if(is_valid_ent(args[1])) {
			remove_entity(args[1]);
		}

		if(is_valid_ent(args[4])) {
			new iEntBase = entity_get_edict(args[4], SENTRY_ENT_BASE);
			new Float:vecMins[3];
			new Float:vecMaxs[3];

			vecMins[0] = -16.0;
			vecMins[1] = -16.0;
			vecMins[2] = 0.0;
			
			vecMaxs[0] = 16.0;
			vecMaxs[1] = 16.0;
			vecMaxs[2] = 48.0;

			entity_set_size(args[4], vecMins, vecMaxs);
			
			entity_set_vector(iEntBase, EV_VEC_origin, vecEntBaseOrigin);
			entity_set_vector(args[4], EV_VEC_origin, vecEntTopOrigin);

			entity_set_size(args[4], vecMins, vecMaxs);
		}
	}
}

public task__CountDownSendMonsters() {
	if(!g_EndGame) {
		if(!g_SpecialWave) {
			sendMonsters(MONSTER_TYPE_NORMAL, g_TotalMonsters, 0);
		} else {
			sendMonsters(g_SpecialWave, g_TotalMonsters, 0);
		}
	}
}

public task__SendMonsters_Post() {
	sendMonsters(g_TempMonsterType, g_TempMonsterNum, g_TempMonsterTrack);
}

public task__VoteBoss() {
	--g_BossMenu_TimeLeft;

	if(!g_BossMenu_TimeLeft) {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			if(dg_get_user_acc_status(i) < STATUS_LOGGED) {
				continue;
			}

			showMenu__VoteBoss(i);
		}

		set_task(10.0, "task__FinishVoteBoss");
		return;
	}

	clientPrint(0, print_center, "¡La votación de jefes comenzará en %d segundo%s!", g_BossMenu_TimeLeft, ((g_BossMenu_TimeLeft != 1) ? "s" : ""));

	set_task(1.0, "task__VoteBoss");
}

public task__FinishVoteBoss() {
	new i;
	new iMaxVote = 0;
	new iMaxItemVote = -1;
	
	for(i = 0; i < structIdBosses; ++i) {
		if(g_BossMenu_Votes[i] > iMaxVote) {
			iMaxVote = g_BossMenu_Votes[i];
			iMaxItemVote = i;
		}
	}

	if(iMaxItemVote == -1) {
		g_BossId = random_num(0, (structIdBosses - 1));

		clientPrintColor(0, _, "No se ha votado un Jefe Final, se eligió aleatoriamente el Jefe !g%s!y.", __BOSSES_NAME[g_BossId][bossNameFF]);
	} else {
		new iPercent = 100;

		if(g_BossMenu_MaxVotes > 0) {
			iPercent = ((g_BossMenu_Votes[iMaxItemVote] * 100) / g_BossMenu_MaxVotes);
		}

		g_BossId = iMaxItemVote;

		clientPrintColor(0, _, "El jefe final será !g%s!y con el !t%d%%!y de los votos.", __BOSSES_NAME[g_BossId][bossNameFF], iPercent);
	}
}

public task__MoveUsersToBoss() {
	new iEnt = -1;
	new Float:vecOrigin[3];
	new j = 1;
	new i;

	while((iEnt = rg_find_ent_by_class(iEnt, "info_vip_start")) != 0) {
		get_entvar(iEnt, var_origin, vecOrigin);
		
		while(!is_user_alive(j) && j <= MaxClients) {
			++j;
		}
		
		if(j > MaxClients) {
			break;
		}
		
		set_entvar(j, var_origin, vecOrigin);
		
		++j;
	}
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		g_InBlockZone[i] = 0;
	}
	
	set_task(1.5, "task__RemoveSpecialEffectToBoss");
}

public task__RemoveSpecialEffectToBoss() {
	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 4);
	write_short(0);
	write_short(SF_FADE_OUT);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(255);
	message_end();
	
	g_NextWaveIncoming = 3;
	
	clearDirectorHud();
	set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
}

public task__ScreenShakeAnimChange() {
	if(is_valid_ent(g_Boss)) {
		message_begin(MSG_BROADCAST, g_Message_ScreenShake);
		write_short(UNIT_SECOND * 5);
		write_short(UNIT_SECOND * 5);
		write_short(UNIT_SECOND * 5);
		message_end();
		
		new Float:vecTargetOrigin[3];
		new i = 1;
		new Float:vecEntOrigin[3];
		new j = 1;
		
		entity_get_vector(g_Boss, EV_VEC_origin, vecTargetOrigin);
		
		while(i <= MaxClients) {
			if(is_user_alive(i)) {
				entity_get_vector(i, EV_VEC_origin, vecEntOrigin);
				
				entitySetAim(i, vecEntOrigin, vecTargetOrigin, .angle_mode=1);
				
				if(j) {
					entitySetAim(g_Boss, vecTargetOrigin, vecEntOrigin, .angle_mode=1);
					j = 0;
				}
			}
			
			++i;
		}
	}
}

public task__BossPowerCloser(const boss) {
	if(!is_valid_ent(boss)) {
		return;
	}
	
	if(!entity_get_int(boss, MONSTER_MAXHEALTH)) {
		return;
	}
	
	new Float:vecEntOrigin[3];
	new Float:vecOrigin[3];
	new Float:vecDirection[3];
	new i;

	entity_get_vector(boss, EV_VEC_origin, vecEntOrigin);
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
	write_byte(80);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(2);
	write_byte(0);
	message_end();
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
	write_byte(TE_IMPLOSION);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
	write_byte(128);
	write_byte(20);
	write_byte(3);
	message_end();
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}
		
		entity_get_vector(i, EV_VEC_origin, vecOrigin);
		
		xs_vec_sub(vecOrigin, vecEntOrigin, vecDirection);
		xs_vec_mul_scalar(vecDirection, -0.4, vecDirection);
		
		entity_set_vector(i, EV_VEC_velocity, vecDirection);
	}
}

public task__EndBossPowerCloser(const boss) {
	set_task(1.0, "task__LightsOff");
	
	if(!is_valid_ent(boss)) {
		return;
	}
	
	if(!entity_get_int(boss, MONSTER_MAXHEALTH)) {
		return;
	}
	
	new i;
	new Float:vecOrigin[3];
	new iVictim = -1;
	new Float:vecVictimOrigin[3];
	new Float:fDistance;
	new Float:flDamage;
	new Float:flRadius = 512.0;
	new Float:vecDirection[3];

	entity_get_vector(boss, EV_VEC_origin, vecOrigin);
	
	for(i = 1; i < 3; ++i) {
		engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_BEAMTORUS);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, (vecOrigin[2] + ((i == 1) ? 3.0 : 15.0)));
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, (vecOrigin[2] + (500.0 * float(i))));
		write_short(g_Sprite_Trail);
		write_byte(0);
		write_byte(0);
		write_byte(10);
		write_byte(2);
		write_byte(15);
		write_byte(255);
		write_byte(0);
		write_byte(0);
		write_byte(150);
		write_byte(0);
		message_end();
	}
	
	// engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	// write_byte(TE_BEAMCYLINDER);
	// engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	// engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	// engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	// engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	// engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	// engfunc(EngFunc_WriteCoord, vecOrigin[2] + 200.0);
	// write_short(g_Sprite_ShockWave);
	// write_byte(0);
	// write_byte(0);
	// write_byte(10);
	// write_byte(60);
	// write_byte(5);
	// write_byte(255);
	// write_byte(0);
	// write_byte(0);
	// write_byte(200);
	// write_byte(1);
	// message_end();
	
	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, flRadius)) != 0) {
		if(!is_user_alive(iVictim)) {
			continue;
		}

		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = get_distance_f(vecVictimOrigin, vecOrigin);
		flDamage = ((flRadius + 1.0) - fDistance);
		
		if(flDamage > 0.0) {
			if((float(g_Health[iVictim]) - flDamage) > 0.0) {
				vecVictimOrigin[2] += 8.0;
				
				xs_vec_sub(vecVictimOrigin, vecOrigin, vecDirection);
				xs_vec_mul_scalar(vecDirection, 2400.0, vecDirection);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecDirection);
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, boss, flDamage, DMG_SLASH);
			} else {
				ExecuteHam(Ham_TakeDamage, iVictim, 0, boss, 9999.0, DMG_SLASH);
			}
		}
	}

	g_BossPower[0] = 0;
	g_BossTimePower[0] = (get_gametime() + 11.0);
	
	if(is_valid_ent(boss)) {
		set_rendering(boss);
	}
	
	task__BackToRide(boss);
}

public task__LightsOff() {
	if(g_BossId != BOSS_GUARDIANES) {
		set_lights("#OFF");
	} else {
		set_lights(g_Lights[0]);
	}
}

public task__BossPowerExplode() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}
	
	new Float:vecExplosion[8][3];
	new Float:vecBallPlace[8][3];
	new i;

	entity_get_vector(i, EV_VEC_origin, vecExplosion[0]);
	createExplosion(vecExplosion[0], 255, 0, 0);
	
	switch(g_BossPower_Explode) {
		case 3: {
			vecExplosion[3][1] = vecExplosion[4][0] = -100.0;
			vecExplosion[3][0] = vecExplosion[5][0] = vecExplosion[5][1] = vecExplosion[6][1] = vecExplosion[7][1] = -50.0;
			vecExplosion[0][1] = vecExplosion[0][2] = vecExplosion[1][2] = vecExplosion[2][0] = vecExplosion[2][2] = vecExplosion[3][2] = vecExplosion[4][1] = vecExplosion[4][2] = vecExplosion[5][2] = vecExplosion[6][0] = vecExplosion[6][2] = vecExplosion[7][2] = 0.0;
			vecExplosion[1][0] = vecExplosion[1][1] = vecExplosion[7][0] = 50.0;
			vecExplosion[0][0] = vecExplosion[2][1] = 100.0;
		} case 2: {
			vecExplosion[3][1] = vecExplosion[4][0] = -200.0;
			vecExplosion[3][0] = vecExplosion[5][0] = vecExplosion[5][1] = vecExplosion[6][1] = vecExplosion[7][1] = -100.0;
			vecExplosion[0][1] = vecExplosion[0][2] = vecExplosion[1][2] = vecExplosion[2][0] = vecExplosion[2][2] = vecExplosion[3][2] = vecExplosion[4][1] = vecExplosion[4][2] = vecExplosion[5][2] = vecExplosion[6][0] = vecExplosion[6][2] = vecExplosion[7][2] = 0.0;
			vecExplosion[1][0] = vecExplosion[1][1] = vecExplosion[7][0] = 100.0;
			vecExplosion[0][0] = vecExplosion[2][1] = 200.0;
		} case 1: {
			vecExplosion[3][1] = vecExplosion[4][0] = -300.0;
			vecExplosion[3][0] = vecExplosion[5][0] = vecExplosion[5][1] = vecExplosion[6][1] = vecExplosion[7][1] = -150.0;
			vecExplosion[0][1] = vecExplosion[0][2] = vecExplosion[1][2] = vecExplosion[2][0] = vecExplosion[2][2] = vecExplosion[3][2] = vecExplosion[4][1] = vecExplosion[4][2] = vecExplosion[5][2] = vecExplosion[6][0] = vecExplosion[6][2] = vecExplosion[7][2] = 0.0;
			vecExplosion[1][0] = vecExplosion[1][1] = vecExplosion[7][0] = 150.0;
			vecExplosion[0][0] = vecExplosion[2][1] = 300.0;
		}
	}
	
	for(new j = 0; j < 8; ++j) {
		if(!is_valid_ent(g_Boss)) {
			return;
		}
		
		if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
			return;
		}

		getDestination(g_Boss, vecExplosion[j][0], vecExplosion[j][1], vecExplosion[j][2], vecBallPlace[j]);
		bombExplosion(g_Boss, vecBallPlace[j]);
	}
	
	g_BossPower_Explode--;
	
	if(!g_BossPower_Explode) {
		g_BossPower[0] = 0;
	}
}

public task__BossPowerUltimate(const boss) {
	if(is_valid_ent(boss)) {
		g_BossFire_Ultimate++;
		
		new Float:vecExplosion[24][3];
		new Float:vecPosition[24][3];
		
		vecExplosion[3][0] = random_float(-750.0, -150.0);
		vecExplosion[7][1] = random_float(-750.0, -150.0);
		vecExplosion[13][0] = random_float(-750.0, -150.0);
		vecExplosion[15][0] = random_float(-750.0, -150.0);
		vecExplosion[18][1] = random_float(-750.0, -150.0);
		vecExplosion[19][0] = random_float(-750.0, -150.0);
		vecExplosion[21][1] = random_float(-750.0, -150.0);
		vecExplosion[22][1] = random_float(-750.0, -150.0);
		
		vecExplosion[2][0] = random_float(-450.0, 250.0);
		vecExplosion[6][1] = random_float(-450.0, 250.0);
		vecExplosion[12][0] = random_float(-450.0, 250.0);
		vecExplosion[14][0] = random_float(-450.0, 250.0);
		vecExplosion[16][0] = random_float(-450.0, 250.0);
		vecExplosion[16][1] = random_float(-450.0, 250.0);
		vecExplosion[17][0] = random_float(-450.0, 250.0);
		vecExplosion[17][1] = random_float(-450.0, 250.0);
		vecExplosion[18][0] = random_float(-450.0, 250.0);
		vecExplosion[19][1] = random_float(-450.0, 250.0);
		vecExplosion[20][1] = random_float(-450.0, 250.0);
		vecExplosion[23][1] = random_float(-450.0, 250.0);
		
		vecExplosion[0][1] = vecExplosion[1][1] = vecExplosion[2][1] = vecExplosion[3][1] = vecExplosion[4][0] = vecExplosion[5][0] = vecExplosion[6][0] = vecExplosion[7][0] = 0.0;
		
		vecExplosion[0][0] = random_float(150.0, 850.0);
		vecExplosion[4][1] = random_float(150.0, 850.0);
		vecExplosion[8][0] = random_float(150.0, 850.0);
		vecExplosion[8][1] = random_float(150.0, 850.0);
		vecExplosion[10][0] = random_float(150.0, 850.0);
		vecExplosion[11][1] = random_float(150.0, 850.0);
		vecExplosion[12][1] = random_float(150.0, 850.0);
		vecExplosion[15][1] = random_float(150.0, 850.0);
		vecExplosion[20][0] = random_float(150.0, 850.0);
		vecExplosion[22][0] = random_float(150.0, 850.0);
		
		vecExplosion[1][0] = random_float(350.0, 1050.0);
		vecExplosion[5][1] = random_float(350.0, 1050.0);
		vecExplosion[9][0] = random_float(350.0, 1050.0);
		vecExplosion[9][1] = random_float(350.0, 1050.0);
		vecExplosion[10][1] = random_float(350.0, 1050.0);
		vecExplosion[11][0] = random_float(350.0, 1050.0);
		vecExplosion[13][1] = random_float(350.0, 1050.0);
		vecExplosion[14][1] = random_float(350.0, 1050.0);
		vecExplosion[21][0] = random_float(350.0, 1050.0);
		vecExplosion[23][0] = random_float(350.0, 1050.0);
		
		vecExplosion[0][2] = random_float(50.0, 65.0);
		vecExplosion[1][2] = random_float(50.0, 65.0);
		vecExplosion[2][2] = random_float(50.0, 65.0);
		vecExplosion[3][2] = random_float(50.0, 65.0);
		vecExplosion[4][2] = random_float(50.0, 65.0);
		vecExplosion[5][2] = random_float(50.0, 65.0);
		vecExplosion[6][2] = random_float(50.0, 65.0);
		vecExplosion[7][2] = random_float(50.0, 65.0);
		vecExplosion[8][2] = random_float(50.0, 65.0);
		vecExplosion[9][2] = random_float(50.0, 65.0);
		vecExplosion[10][2] = random_float(50.0, 65.0);
		vecExplosion[11][2] = random_float(50.0, 65.0);
		vecExplosion[12][2] = random_float(50.0, 65.0);
		vecExplosion[13][2] = random_float(50.0, 65.0);
		vecExplosion[14][2] = random_float(50.0, 65.0);
		vecExplosion[15][2] = random_float(50.0, 65.0);
		vecExplosion[17][2] = random_float(50.0, 65.0);
		vecExplosion[17][2] = random_float(50.0, 65.0);
		vecExplosion[18][2] = random_float(50.0, 65.0);
		vecExplosion[19][2] = random_float(50.0, 65.0);
		vecExplosion[20][2] = random_float(50.0, 65.0);
		vecExplosion[21][2] = random_float(50.0, 65.0);
		vecExplosion[22][2] = random_float(50.0, 65.0);
		vecExplosion[23][2] = random_float(50.0, 65.0);
		
		for(new i = 0; i < 24; ++i) {
			getDestination(boss, vecExplosion[i][0], vecExplosion[i][1], vecExplosion[i][2], vecPosition[i]);
			createFireBallUltimate(boss, vecPosition[i]);
		}
		
		if(g_BossFire_Ultimate >= 7) {
			g_BossPower[0] = 0;
			return;
		}
		
		set_task(1.0, "task__BossPowerUltimate", boss);
	}
}

public task__BossPowerDash() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}
	
	new Float:vecOriginBoss[3];
	new Float:vecOrigin[3];
	new Float:flDistance;
	
	entity_get_vector(g_Boss, EV_VEC_origin, vecOriginBoss);
	
	entity_set_int(g_Boss, EV_INT_sequence, 6);
	entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
	entity_set_float(g_Boss, EV_FL_framerate, 9.6);
	
	entity_set_int(g_Boss, EV_INT_gamestate, 1);
	
	getDestination(g_Boss, 8192.0, 0.0, 0.0, vecOrigin);
	
	flDistance = get_distance_f(vecOriginBoss, vecOrigin);
	
	followHuman(g_Boss, vecOriginBoss, vecOrigin, flDistance, 4000.0);
}

public task__BossPowerFireBallx2() {
	new Float:vecOrigin[3];
	new iBallLeft;
	new Float:flGameTime = get_gametime();
	new iBallRight;
	
	getDestination(g_Boss, 50.0, -25.0, 100.0, vecOrigin);
	
	iBallLeft = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallLeft, EV_FL_nextthink, (flGameTime + 0.8));
	
	getDestination(g_Boss, 50.0, 50.0, 100.0, vecOrigin);
	
	iBallRight = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallRight, EV_FL_nextthink, (flGameTime + 1.1));
	
	g_BossPower[0] = 0;
}

public task__BossPowerFireBallx4() {
	new Float:vecOrigin[3];
	new iBallLeft;
	new Float:flGameTime = get_gametime();
	new iBallRight;
	
	getDestination(g_Boss, 50.0, -25.0, 100.0, vecOrigin);
	
	iBallLeft = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallLeft, EV_FL_nextthink, (flGameTime + 0.8));
	
	getDestination(g_Boss, 50.0, 50.0, 100.0, vecOrigin);
	
	iBallRight = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallRight, EV_FL_nextthink, (flGameTime + 1.1));
	
	set_task(0.2, "task__BossPowerFireBallx4Go");
}

public task__BossPowerFireBallx4Go() {
	new Float:vecOrigin[3];
	new iBallLeft;
	new Float:flGameTime = get_gametime();
	new iBallRight;
	
	getDestination(g_Boss, 50.0, -25.0, 100.0, vecOrigin);
	
	iBallLeft = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallLeft, EV_FL_nextthink, (flGameTime + 0.1));
	
	getDestination(g_Boss, 50.0, 50.0, 100.0, vecOrigin);
	
	iBallRight = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallRight, EV_FL_nextthink, (flGameTime + 0.2));
	
	g_BossPower[0] = 0;
}

public task__BossFallenTitanScreaming() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new Float:vecEntOrigin[3];
	new Float:vecVictimOrigin[3];
	new Float:vecSub[3];

	entity_get_vector(g_Boss, EV_VEC_origin, vecEntOrigin);

	for(new i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		entity_get_vector(i, EV_VEC_origin, vecVictimOrigin);

		xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub);
		xs_vec_mul_scalar(vecSub, 300.0, vecSub);
		
		vecSub[2] = random_float(400.0, 650.0);
		entity_set_vector(i, EV_VEC_velocity, vecSub);
		
		ExecuteHam(Ham_TakeDamage, i, 0, g_Boss, random_float(75.0, 125.0), DMG_BLAST);
	}

	message_begin(MSG_BROADCAST, g_Message_ScreenShake);
	write_short(UNIT_SECOND * 7);
	write_short(UNIT_SECOND * 7);
	write_short(UNIT_SECOND * 7);
	message_end();
	
	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 5);
	write_short(0);
	write_short(SF_FADE_OUT);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(155);
	message_end();

	g_BossPower[0] = 0;
}

public task__bossFallenTitanStartHyperCannon() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new Float:flGameTime = get_gametime();

	g_BossPower[0] = BOSS_FT_HIPER_CANNON;
	g_BossTimePower[0] = (flGameTime + 7.0);

	entity_set_int(g_Boss, EV_INT_sequence, 16);
	entity_set_float(g_Boss, EV_FL_animtime, flGameTime);
	entity_set_float(g_Boss, EV_FL_framerate, 1.0);

	entity_set_int(g_Boss, EV_INT_gamestate, 1);

	entity_set_vector(g_Boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});

	entity_set_float(g_Boss, EV_FL_nextthink, (flGameTime + 6.466667));

	g_BossPower[0] = 0;
	g_BossFT_UltimateCannons = 15;
	g_BossFT_Enrage = 1;

	set_task(1.0, "task__BossFallenTitanHyperCannon");
}

public task__BossFallenTitanHyperCannon() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new iArgs[2];
	static i;

	iArgs[1] = 0;

	if(i > MaxClients) {
		i = 0;
	}

	while(++i <= MaxClients) {
		if(!is_user_alive(i)) {
			continue;
		}

		iArgs[0] = i;

		task__BossFallenTitanPowerCannon(iArgs);
		break;
	}

	--g_BossFT_UltimateCannons;

	if(!g_BossFT_UltimateCannons) {
		return;
	}

	set_task(0.3, "task__BossFallenTitanHyperCannon");
}

public task__BossFallenTitanInfiniteCannons() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new iArgs[2];
	new iUserId[MAX_PLAYERS + 1];
	new j = 0;
	new iRandom;

	iArgs[1] = 0;

	for(new i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}
		
		iUserId[j] = i;
		++j;
	}

	iRandom = iUserId[random_num(0, (j - 1))];

	if(is_user_alive(iRandom)) {
		iArgs[0] = iRandom;
		task__BossFallenTitanPowerCannon(iArgs);
	}

	set_task(0.8, "task__BossFallenTitanInfiniteCannons");
}

public task__BossFallenTitanPowerDash() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	set_hudmessage(255, 0, 0, -1.0, 0.5, 0, 0.0, 5.0, 0.0, 0.0, 4);
	ShowSyncHudMsg(0, g_HudSync_DamageTower, "No dejes que el jefe golpee una pared!");
	
	new Float:vecOriginBoss[3];
	new Float:vecOrigin[3];
	new Float:flDistance;
	
	entity_get_vector(g_Boss, EV_VEC_origin, vecOriginBoss);
	
	entity_set_int(g_Boss, EV_INT_sequence, 9);
	entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
	entity_set_float(g_Boss, EV_FL_framerate, ((!g_BossFT_Enrage) ? 1.5 : 3.0));
	
	entity_set_int(g_Boss, EV_INT_gamestate, 1);
	
	getDestination(g_Boss, 8192.0, 0.0, 0.0, vecOrigin);
	
	flDistance = get_distance_f(vecOriginBoss, vecOrigin);
	
	followHuman(g_Boss, vecOriginBoss, vecOrigin, flDistance, ((!g_BossFT_Enrage) ? 375.0 : 750.0));
}

public task__BossFallenTitanPowerCannon(const args[2]) {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new iVictim = args[0];
	new iPlayAnim = args[1];

	if(is_user_alive(iVictim)) {
		if(iPlayAnim) {
			entity_set_int(g_Boss, EV_INT_sequence, 14);
			entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
			entity_set_float(g_Boss, EV_FL_framerate, ((!g_BossFT_Enrage) ? 1.0 : 2.0));
			
			entity_set_int(g_Boss, EV_INT_gamestate, 1);
		}

		new Float:vecBossOrigin[3];
		new Float:vecVictimOrigin[3];
		new Float:vecVelocity[3];

		entity_get_vector(g_Boss, EV_VEC_origin, vecBossOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);	

		entitySetAim(g_Boss, vecBossOrigin, vecVictimOrigin, .angle_mode=1337);

		playSound(0, __SOUND_FALLEN_TITAN_CANNON);
		
		new iDistance = floatround(vector_distance(vecBossOrigin, vecVictimOrigin));
		
		velocity_by_aim(g_Boss, iDistance, vecVelocity);

		entitySetAim(g_Boss, vecBossOrigin, vecVictimOrigin, .angle_mode=1);
		
		new iSpitterBall = create_entity("info_target");
		
		if(is_valid_ent(iSpitterBall)) {
			entity_set_string(iSpitterBall, EV_SZ_classname, __ENT_CLASSNAME_BOSS_FT_CANNON_BALL);
			entity_set_model(iSpitterBall, __MODEL_TANK_ROCK_GIBS);
			
			entity_set_float(iSpitterBall, EV_FL_scale, 0.1);
			
			entity_set_size(iSpitterBall, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
			entity_set_vector(iSpitterBall, EV_VEC_mins, Float:{-2.0, -2.0, -2.0});
			entity_set_vector(iSpitterBall, EV_VEC_maxs, Float:{2.0, 2.0, 2.0});
			
			vecBossOrigin[2] += 32.0;
			entity_set_origin(iSpitterBall, vecBossOrigin);
			
			entity_set_int(iSpitterBall, EV_INT_solid, SOLID_NOT);
			entity_set_int(iSpitterBall, EV_INT_movetype, MOVETYPE_TOSS);
			entity_set_edict(iSpitterBall, EV_ENT_owner, g_Boss);
			
			entity_set_float(iSpitterBall, EV_FL_gravity, 1.0);
			entity_set_vector(iSpitterBall, EV_VEC_velocity, vecVelocity);
			
			set_rendering(iSpitterBall, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMFOLLOW);
			write_short(iSpitterBall);
			write_short(g_Sprite_Trail);
			write_byte(25);
			write_byte(3);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			message_end();
			
			register_think(__ENT_CLASSNAME_BOSS_FT_CANNON_BALL, "@think__CannonBall");
			
			entity_set_float(iSpitterBall, EV_FL_nextthink, get_gametime() + 0.1);
		}
	}

	if(iPlayAnim) {
		set_task(((!g_BossFT_Enrage) ? 1.266667 : 0.633334), "task__BossFallenTitanPowerCannonEnd");
	}
}

public task__BossFallenTitanPowerCannonEnd() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	entity_set_int(g_Boss, EV_INT_sequence, 15);
	entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
	entity_set_float(g_Boss, EV_FL_framerate, ((!g_BossFT_Enrage) ? 1.0 : 2.0));
	
	entity_set_int(g_Boss, EV_INT_gamestate, 1);

	entity_set_float(g_Boss, EV_FL_nextthink, (get_gametime() + ((!g_BossFT_Enrage) ? 1.5 : 0.75)));

	g_BossPower[0] = 0;
}

public task__BossFallenTitanPowerTentacles() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new i;
	new iTentacle;
	new Float:vecOrigin[3];

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		if(!(get_entity_flags(i) & FL_ONGROUND)) {
			continue;
		}

		if(!random_num(0, ((!g_BossFT_Enrage) ? 2 : 1))) {
			iTentacle = create_entity("info_target");

			if(is_valid_ent(iTentacle)) {
				entity_set_string(iTentacle, EV_SZ_classname, "entTentacle");
				entity_set_model(iTentacle, __MODEL_TENTACLE);

				entity_set_size(iTentacle, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
				
				entity_get_vector(i, EV_VEC_origin, vecOrigin);

				// vecOrigin[2] += 80.0;
				entity_set_origin(iTentacle, vecOrigin);
				
				entity_set_int(iTentacle, EV_INT_solid, SOLID_TRIGGER);
				entity_set_int(iTentacle, EV_INT_movetype, MOVETYPE_FLY);

				entity_set_int(iTentacle, EV_INT_sequence, 1);
				entity_set_float(iTentacle, EV_FL_animtime, get_gametime());
				entity_set_float(iTentacle, EV_FL_framerate, 1.0);
				
				entity_set_int(iTentacle, EV_INT_gamestate, 1);

				entity_set_float(iTentacle, EV_FL_nextthink, (get_gametime() + 0.1));

				register_think("entTentacle", "@think__Tentacle");
			}
		}
	}

	g_BossPower[0] = 0;
}

public task__VoteMap() {
	g_VoteMap = 1;

	new sMenu[256];
	new iPosition = formatex(sMenu, charsmax(sMenu), "\yELIGE EL PRÓXIUMO MAPA^n^n");
	new iMax = ((g_VoteMap_Count > g_VoteMap_SelectMaps) ? g_VoteMap_SelectMaps : g_VoteMap_Count);
	new iRandom;
	new iKeys = (1<<(g_VoteMap_SelectMaps + 1));

	for(g_VoteMap_i = 0; g_VoteMap_i < iMax; ++g_VoteMap_i) {
		iRandom = random_num(0, (g_VoteMap_Count - 1));

		while(getMapRandomIn(iRandom)) {
			iRandom++;

			if(iRandom >= g_VoteMap_Count) {
				iRandom = 0;
			}
		}

		g_VoteMap_Next[g_VoteMap_i] = iRandom;

		iPosition += formatex(sMenu[iPosition], charsmax(sMenu), "\r%d.\w %a%s^n", (g_VoteMap_i + 1), ArrayGetStringHandle(g_aMapName, iRandom), __MAPS[iRandom][mapDesc]);
		iKeys |= (1<<g_VoteMap_i);

		g_VoteMap_VoteCount[g_VoteMap_i] = 0;
	}

	sMenu[iPosition++] = '^n';

	g_VoteMap_VoteCount[g_VoteMap_SelectMaps] = 0;
	g_VoteMap_VoteCount[(g_VoteMap_SelectMaps + 1)] = 0;

	// if(!g_VoteMap_Force && g_VoteMap_Extend < 3) {
		// iPosition += formatex(sMenu[iPosition], iLen, "\r%d.\w Extender el mapa 15 minutos más^n", (g_VoteMap_SelectMaps + 1));
		// iKeys |= (1<<g_VoteMap_SelectMaps);
	// }

	formatex(sMenu[iPosition], charsmax(sMenu), "\r0.\w No Votar");

	show_menu(0, iKeys, sMenu, 15, "VoteMap Menu");

	remove_task(TASK_VOTEMAP_END);
	set_task(15.1, "task__VoteMapEnd", TASK_VOTEMAP_END);

	clientPrintColor(0, _, "Es momento de elegir el próximo mapa.");

	client_cmd(0, "spk gman/gman_choose1");
}

public task__VoteMapEnd() {
	g_VoteMap = 0;

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

	if(j == -1) {
		j = random_num(0, (g_VoteMap_Count - 1));

		clientPrintColor(0, _, "Ningún mapa fue votado y se eligió uno al azar: !g%s!y.", __MAPS[g_VoteMap_Next[j]][mapName]);
	} else if(g_VoteMap_VoteCount[j] && g_VoteMap_VoteCount[(g_VoteMap_SelectMaps + 1)] <= g_VoteMap_VoteCount[j]) {
		clientPrintColor(0, _, "El mapa ganador es !g%a!y con !g%d!y / !g%d!y voto%s.", ArrayGetStringHandle(g_aMapName, g_VoteMap_Next[j]), g_VoteMap_VoteCount[j], iMaxVotes, ((g_VoteMap_VoteCount[j] != 1) ? "s" : ""));
	}

	message_begin(MSG_ALL, SVC_INTERMISSION);
	message_end();

	set_task(5.0, "task__ChangeMap", g_VoteMap_Next[j]);
}

public task__RepeatAnimationStupidFix() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}

	entity_set_int(g_Boss, EV_INT_sequence, 0);

	entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
	entity_set_float(g_Boss, EV_FL_framerate, 1.0);
	
	entity_set_int(g_Boss, EV_INT_gamestate, 1);
}

@message__RoundTime() {
	set_msg_arg_int(1, ARG_SHORT, get_timeleft());
}

@message__TextMsg() {
	new sTextMsg[22];
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
	
	return PLUGIN_CONTINUE;
}

@message__SendAudio() {
	new sSendAudio[32];
	get_msg_arg_string(2, sSendAudio, charsmax(sSendAudio));

	if(equali(sSendAudio, "%!MRAD_FIREINHOLE")) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

@message__ClCorpse() {
	return PLUGIN_HANDLED;
}

@messge__CurWeapon(const msg_id, const msg_dest, const msg_entity) {
	if(g_UnlimitedClip[msg_entity] ||
	(g_ClassLevel[msg_entity][CLASS_PISTOLERO] == 6 && g_ClassId[msg_entity] == CLASS_PISTOLERO && g_CurrentWeapon[msg_entity] == WEAPON_DEAGLE) ||
	(g_ClassLevel[msg_entity][CLASS_BITERO] == 6 && g_ClassId[msg_entity] == CLASS_BITERO && (g_CurrentWeapon[msg_entity] == WEAPON_MAC10 || g_CurrentWeapon[msg_entity] == WEAPON_TMP))) {
		if(get_msg_arg_int(1) != 1) {
			return;
		}

		new iWeaponId = get_msg_arg_int(2);

		if(__MAX_BPAMMO[iWeaponId] > 2) {
			new iWeaponEnt = get_member(msg_entity, m_pClientActiveItem);
			
			if(!is_nullent(iWeaponEnt)) {
				set_member(iWeaponEnt, m_Weapon_iClip, 100);
			}
			
			set_msg_arg_int(3, get_msg_argtype(3), 100);
		}
	}
}

@impulse__Flashlight(const id) {
	if(is_user_alive(id)) {
		if(g_ClassId[id] == CLASS_SOPORTE && g_ClassLevel[id][CLASS_SOPORTE] >= 5) {
			if(!g_ClassSoporte_Hab[id]) {
				if(g_CurrentWeapon[id] == WEAPON_XM1014) {
					new iExtraClip = 7;
					new iWeaponEnt = find_ent_by_owner(-1, "weapon_xm1014", id);
					
					if(g_HabCacheClip[id]) {
						iExtraClip = (iExtraClip + ((iExtraClip * g_HabCacheClip[id]) / 100));
					}
					
					iExtraClip += __CLASSES_ATTRIB[CLASS_SOPORTE][g_ClassLevel[id][CLASS_SOPORTE]][classAttribClip];
					
					if((cs_get_weapon_ammo(iWeaponEnt) == iExtraClip) && (cs_get_user_bpammo(id, _:WEAPON_XM1014) >= 200)) {
						return PLUGIN_HANDLED;
					}
					
					g_ClassSoporte_Hab[id] = 1;
					
					cs_set_weapon_ammo(iWeaponEnt, iExtraClip);
					cs_set_user_bpammo(id, _:WEAPON_XM1014, 200);
				}
			} else {
				clientPrintColor(id, _, "Ya usaste tu habilidad de !tSOPORTE!y en esta oleada.");
			}
		} else if(g_ClassLevel[id][CLASS_SCOUTER] == 6 && g_ClassId[id] == CLASS_SCOUTER) {
			if(!g_ClassScouter_Hab[id]) {
				if(g_CurrentWeapon[id] == WEAPON_SCOUT) {
					g_ClassScouter_Hab[id] = 1;

					remove_task(id + TASK_CLASS_POWER);
					set_task(10.5, "task__RemovePowerScouter", id + TASK_CLASS_POWER);
				}
			} else {
				clientPrintColor(id, _, "Ya usaste tu habilidad de SCOUTER en esta oleada.");
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

clearDirectorHud() {
	new i;
	for(i = 0; i < 8; ++i) {
		set_dhudmessage(0, 0, 0, -1.0, 0.2, 0, 0.0, 0.1, 0.1, 0.1);
		show_dhudmessage(0, "");
	}
}

removeMapsEnts() {
	g_aRemoveMapsEnts = ArrayCreate(32, 0);

	new i;
	for(i = 0; i < sizeof(__REMOVE_MAPS_ENTS); ++i) {
		ArrayPushString(g_aRemoveMapsEnts, __REMOVE_MAPS_ENTS[i]);
	}

	if(ArraySize(g_aRemoveMapsEnts)) {
		g_FwdSpawn = register_forward(FM_Spawn, "@FM_Spawn_Pre", false);
	} else {
		ArrayDestroy(g_aRemoveMapsEnts);
	}
}

checkMap() {
	new i = 0;
	new iEnt = -1;
	new j = 0;
	new iSprite = -1;
	new iTower = -1;

	while(i < 2) {
		iEnt = find_ent_by_tname(-1, ((!i) ? "start" : "start1"));

		if(is_valid_ent(iEnt) && iEnt != 0) {
			j = 1;

			entity_get_vector(iEnt, EV_VEC_origin, g_VecStartOrigin[i]);
			
			iSprite = create_entity("env_sprite");
			
			if(is_valid_ent(iSprite)) {
				entity_set_model(iSprite, __SPRITE_MONSTER_SPAWN);
				
				g_VecStartOrigin[i][2] += 10.0;
				entity_set_origin(iSprite, g_VecStartOrigin[i]);
				g_VecStartOrigin[i][2] -= 10.0;
				
				entity_set_float(iSprite, EV_FL_scale, 1.5);
				
				entity_set_int(iSprite, EV_INT_spawnflags, SF_SPRITE_STARTON);
				entity_set_int(iSprite, EV_INT_solid, SOLID_NOT);
				entity_set_int(iSprite, EV_INT_movetype, MOVETYPE_FLY);
				
				entity_set_int(iSprite, EV_INT_rendermode, kRenderTransAdd);
				entity_set_float(iSprite, EV_FL_renderamt, 255.0);
				
				entity_set_float(iSprite, EV_FL_framerate, 13.0);
				
				DispatchSpawn(iSprite);
			}
		}

		++i;
	}

	if(!j) {
		return false;
	}
	
	iEnt = -1;
	i = 0;
	j = 0;

	while(i < 2) {
		iEnt = find_ent_by_tname(-1, ((!i) ? "end" : "end1"));

		if(is_valid_ent(iEnt) && iEnt != 0) {
			j = 1;

			entity_get_vector(iEnt, EV_VEC_origin, g_VecEndOrigin[i]);
			
			iTower = create_entity("info_target");
			
			if(is_valid_ent(iTower)) {
				entity_set_string(iTower, EV_SZ_classname, __ENT_CLASSNAME_TOWER);
				entity_set_model(iTower, __MODEL_TOWER);

				entity_set_origin(iTower, g_VecEndOrigin[i]);
				
				entity_set_int(iTower, EV_INT_solid, SOLID_BBOX);
				entity_set_int(iTower, EV_INT_movetype, MOVETYPE_TOSS);

				drop_to_floor(iTower);
				
				entity_set_size(iTower, Float:{-114.419998, -116.209999, -104.780029}, Float:{117.220001, 114.709999, 574.730003});
				
				g_VecEndOrigin[i][2] -= 40.0;
				entity_set_origin(iTower, g_VecEndOrigin[i]);
				
				entity_get_vector(iTower, EV_VEC_origin, g_VecEndOrigin[i]);

				g_Tower[i] = iTower;
			}
		}

		++i;
	}

	g_TowerHealth = __MAPS[g_MapId][mapTowerHealth];
	g_TowerMaxHealth = g_TowerHealth;
	
	if(!j) {
		return false;
	}

	iEnt = find_ent_by_tname(-1, "respawn_special");

	if(is_valid_ent(iEnt) && iEnt != 0) {
		entity_get_vector(iEnt, EV_VEC_origin, g_VecSpecialOrigin);

		switch(g_MapId) {
			case TD_DARK_NIGHT: {
				g_VecSpecialOrigin[2] -= 24.0;
			} case TD_KWHITE: {
				g_VecSpecialOrigin[2] -= 34.0;
			} case TD_GEMPIRE: {
				g_VecSpecialOrigin[2] -= 40.0;
			} case TD_KSUB, TD_KSUB_WOOL: {
				g_VecSpecialOrigin[2] -= 48.0;
			}
		}
	}
	
	iEnt = find_ent_by_tname(-1, "respawn_special2");

	if(is_valid_ent(iEnt) && iEnt != 0) {
		entity_get_vector(iEnt, EV_VEC_origin, g_VecSpecialOrigin2);

		switch(g_MapId) {
			case TD_KMID, TD_ORANGE, TD_PLAZA2, TD_MINECRAFT: {
				g_VecSpecialOrigin2[2] -= 24.0;
			} case TD_GEMPIRE, TD_KWHITE: {
				g_VecSpecialOrigin2[2] -= 40.0;
			} case TD_KSUB, TD_KSUB_WOOL: {
				g_VecSpecialOrigin2[2] -= 48.0;
			}
		}
	}
	
	return true;
}

blockCommands() {
	new const __WEAPON_COMMANDS[][] = {"drop", "buy", "buyammo1", "buyammo2", "buyequip", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47", "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1", "sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "fiveseven", "12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum", "d3au1", "krieg550", "smg", "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown"};
	new i;

	for(i = 0; i < sizeof(__WEAPON_COMMANDS); ++i) {
		register_clcmd(__WEAPON_COMMANDS[i], "@clcmd__BlockCommand");
	}
}

loadStuff() {
	g_ServerId = dg_get_server_id();

	set_cvar_string("sv_skyname", "space");
	set_cvar_string("sv_skycolor_r", "0");
	set_cvar_string("sv_skycolor_g", "0");
	set_cvar_string("sv_skycolor_b", "0");

	set_member_game(m_bTCantBuy, true);
	set_member_game(m_bCTCantBuy, true);

	loadThinks();
	loadEvas();
	loadGame();
}

loadThinks() {
	g_EntCheckAfk = create_entity("info_target");

	if(is_valid_ent(g_EntCheckAfk)) {
		entity_set_string(g_EntCheckAfk, EV_SZ_classname, __ENT_CLASSNAME_CHECK_AFK);
		entity_set_float(g_EntCheckAfk, EV_FL_nextthink, NEXTTHINK_CHECK_AFK);
		
		register_think(__ENT_CLASSNAME_CHECK_AFK, "@think__CheckAFK");
	}

	g_EntHud = create_entity("info_target");

	if(is_valid_ent(g_EntHud)) {
		entity_set_string(g_EntHud, EV_SZ_classname, __ENT_CLASSNAME_HUD);
		entity_set_float(g_EntHud, EV_FL_nextthink, NEXTTHINK_HUD);

		register_think(__ENT_CLASSNAME_HUD, "@think__Hud");
	}

	new iEntHudGeneral = create_entity("info_target");

	if(is_valid_ent(iEntHudGeneral)) {
		g_HudSync_General = CreateHudSyncObj();

		entity_set_string(iEntHudGeneral, EV_SZ_classname, __ENT_CLASSNAME_HUD_GENERAL);
		entity_set_float(iEntHudGeneral, EV_FL_nextthink, NEXTTHINK_HUD_GENERAL);

		register_think(__ENT_CLASSNAME_HUD_GENERAL, "@think__HudGeneral");
	}

	register_think(__ENT_CLASSNAME_SENTRY, "@think__Sentry");
	register_think(__ENT_CLASSNAME_ROBOT, "@think__Robot");
	register_think(__ENT_CLASSNAME_SPECIAL_MONSTER, "@think__SpecialMonster");

	register_touch("grenade", "*", "@touch__GrenadeAll");
}

loadEvas() {
	new sEvasFile[96];
	formatex(sEvasFile, charsmax(sEvasFile), "addons/amxmodx/configs/evas/%s/spawns.cfg", g_CurrentMap);
	
	if(!file_exists(sEvasFile))	{
		write_file(sEvasFile, "; MAPA <X Y Z ANGLES>", -1);
		return;
	}
	
	new iFile;
	new sLine[256];
	new sOrigin[3][16];
	new sAngles[3][16];
	new Float:vecAngles[3];
	
	iFile = fopen(sEvasFile, "rt");
	
	while(!feof(iFile))	{
		fgets(iFile, sLine, charsmax(sLine));
		
		if(!sLine[0] || sLine[0] == ';' || sLine[0] == ' ' || ( sLine[0] == '/' && sLine[1] == '/')) {
			continue;
		}
		
		parse(sLine, sOrigin[0], charsmax(sOrigin[]), sOrigin[1], charsmax(sOrigin[]), sOrigin[2], charsmax(sOrigin[]), sAngles[0], charsmax(sAngles[]), sAngles[1], charsmax(sAngles[]), sAngles[2], charsmax(sAngles[]));

		g_EntEvas[g_EntEvasNums] = create_entity("info_target");
		
		if(is_valid_ent(g_EntEvas[g_EntEvasNums])) {
			entity_set_string(g_EntEvas[g_EntEvasNums], EV_SZ_classname, __ENT_CLASSNAME_EVA);
			
			dllfunc(DLLFunc_Spawn, g_EntEvas[g_EntEvasNums]);
			
			g_EntEvasOrigin[g_EntEvasNums][0] = str_to_float(sOrigin[0]);
			g_EntEvasOrigin[g_EntEvasNums][1] = str_to_float(sOrigin[1]);
			g_EntEvasOrigin[g_EntEvasNums][2] = (str_to_float(sOrigin[2]) + 32.0);
			
			vecAngles[0] = str_to_float(sAngles[0]);
			vecAngles[1] = str_to_float(sAngles[1]);
			vecAngles[2] = str_to_float(sAngles[2]);

			entity_set_model(g_EntEvas[g_EntEvasNums], __MODEL_EVA);
			entity_set_origin(g_EntEvas[g_EntEvasNums], g_EntEvasOrigin[g_EntEvasNums]);
			entity_set_vector(g_EntEvas[g_EntEvasNums], EV_VEC_angles, vecAngles);

			entity_set_size(g_EntEvas[g_EntEvasNums], Float:{-16.0, -16.0, -16.0}, Float:{16.0, 16.0, 9999.0});
			
			entity_set_int(g_EntEvas[g_EntEvasNums], EV_INT_solid, SOLID_BBOX);
			entity_set_int(g_EntEvas[g_EntEvasNums], EV_INT_movetype, MOVETYPE_TOSS);
			
			entity_set_int(g_EntEvas[g_EntEvasNums], EV_INT_sequence, 0);
			entity_set_float(g_EntEvas[g_EntEvasNums], EV_FL_animtime, get_gametime());
			entity_set_float(g_EntEvas[g_EntEvasNums], EV_FL_gravity, 1.0);
			
			drop_to_floor(g_EntEvas[g_EntEvasNums]);
		}
		
		++g_EntEvasNums;
	}
	
	fclose(iFile);
}

loadGame() {
	g_HudSync_Damage = CreateHudSyncObj();
	g_HudSync_DamageTower = CreateHudSyncObj();

	g_StartGame = 1;
	g_StartSeconds = 59;

	set_task(60.0, "task__StartGame", TASK_START_GAME);
	set_task(1.0, "task__RepeatHud2", TASK_START_GAME, .flags="a", .repeat=59);
	set_task(59.0, "task__EndVoteDiff");

	g_aMapName = ArrayCreate(MAX_CHARACTER_MAPNAME);
	
	loadWalkGuard();
	loadMaps();
	
	g_Achievement_DefensaAbsoluta = 1;
	g_ZombieModels = random_num(0, charsmax(__MODELS_ZOMBIE_NORMAL));
	g_FinishGame = 0;
	g_Lights[0] = 'i';

	set_lights(g_Lights[0]);
}

loadWalkGuard() {
	new sWalkGuardFile[128];
	new iFile;
	
	formatex(sWalkGuardFile, charsmax(sWalkGuardFile), "addons/amxmodx/configs/walkguard/%s.wgz", g_CurrentMap);
	iFile = fopen(sWalkGuardFile, "rt");

	if(iFile) {
		new sData[256];
		new sZoneName[32];
		new sVecPos[3][13];
		new sVecMins[3][13];
		new sVecMaxs[3][13];
		new iZoneMode = -1;
		new i;
		new Float:vecPos[3];
		new Float:vecMins[3];
		new Float:vecMaxs[3];
		
		while(!feof(iFile)) {
			fgets(iFile, sData, charsmax(sData));
			
			if(sData[0]) {
				parse(sData, sZoneName, charsmax(sZoneName), sVecPos[0], charsmax(sVecPos[]), sVecPos[1], charsmax(sVecPos[]), sVecPos[2], charsmax(sVecPos[]), sVecMins[0], charsmax(sVecMins[]), sVecMins[1], charsmax(sVecMins[]), sVecMins[2], charsmax(sVecMins[]), sVecMaxs[0], charsmax(sVecMaxs[]), sVecMaxs[1], charsmax(sVecMaxs[]), sVecMaxs[2], charsmax(sVecMaxs[]));
				
				iZoneMode = -1;
				
				for(i = 0; i < structIdZones; ++i) {
					if(equal(sZoneName, __ZONE_NAME[i])) {
						iZoneMode = i;
						break;
					}
				}
				
				if(iZoneMode == -1) {
					continue;
				}
				
				vecPos[0] = str_to_float(sVecPos[0]);
				vecPos[1] = str_to_float(sVecPos[1]);
				vecPos[2] = str_to_float(sVecPos[2]);
				
				vecMins[0] = str_to_float(sVecMins[0]);
				vecMins[1] = str_to_float(sVecMins[1]);
				vecMins[2] = str_to_float(sVecMins[2]);
				
				vecMaxs[0] = str_to_float(sVecMaxs[0]);
				vecMaxs[1] = str_to_float(sVecMaxs[1]);
				vecMaxs[2] = str_to_float(sVecMaxs[2]);
				
				for(i = 0; i < 3; ++i) {
					if(vecMins[i] > 0.0) {
						vecMins[i] *= -1.0;
					}
					
					if(vecMaxs[i] < 0.0) {
						vecMaxs[i] *= -1.0;
					}
				}
				
				createZone(vecPos, vecMins, vecMaxs, iZoneMode);
			}
		}
		
		server_print("Se ha cargado el archivo <%s> correctamente.", sWalkGuardFile);

		fclose(iFile);
	}
	
	findAllZones();
	hideAllZones();
}

findAllZones() {
	g_MaxZones = 0;

	new iEnt = -1;
	
	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_WALKGUARD)) != 0) {
		g_Zone[g_MaxZones] = iEnt;
		++g_MaxZones;
	}
}

hideAllZones() {
	g_EditorId = 0;
	
	new i;
	for(i = 0; i < g_MaxZones; ++i) {
		entity_set_int(g_Zone[i], EV_INT_solid, __ZONE_SOLID_TYPE[entity_get_int(g_Zone[i], EV_INT_iuser1)]);
		
		remove_task(g_Zone[i] + TASK_SHOW_ZONE);
	}
}

showAllZones() {
	findAllZones();
	
	new i;
	for(i = 0; i < g_MaxZones; ++i) {
		entity_set_int(g_Zone[i], EV_INT_solid, SOLID_NOT);
		
		remove_task(g_Zone[i] + TASK_SHOW_ZONE);
		set_task(0.2, "task__ShowZoneBox", g_Zone[i] + TASK_SHOW_ZONE, .flags="b");
	}
}

loadMaps() {
	new i;
	for(i = 0; i < structIdMaps; ++i) {
		if(validMap(__MAPS[i][mapName])) {
			ArrayPushString(g_aMapName, __MAPS[i][mapName]);
			++g_VoteMap_Count;
		}
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

	if(g_SqlConnection == Empty_Handle) {
		set_fail_state("loadSql() - Error en la conexión a la base de datos - [%d] %s.", iErrorNum, sData);
		return;
	}

	loadQueries();
	set_task(0.5, "task__SetConfigs");
}

loadQueries() {

}

Float:getVelocity() {
	new Float:flVelocity;
	
	switch(g_SpecialWave) {
		case MONSTER_TYPE_SPECIAL_SPEED: {
			flVelocity = 350.0;
		} case MONSTER_TYPE_SPECIAL_STRENGTH: {
			return 110.0;
		} default: {
			flVelocity = (220.0 + float((g_Wave * (2 + g_Diff))));
		}
	}

	if(__DIFFS_VALUES[g_Diff][diffValueSpeed]) {
		flVelocity = (flVelocity + ((flVelocity * __DIFFS_VALUES[g_Diff][diffValueSpeed]) / 100.0));
	}

	return Float:flVelocity;
}

endWave() {
	g_WaveInProgress = 0;
	
	new i;
	
	if(g_SpecialWave) {
		g_SpecialWave = 0;
		g_ExtraWaveSpeed = 1337;
		g_ExtraWaveStrength = 1337;
	} else if(!g_Tramposo) {
		g_TimePerWave_SysTime[(g_Wave - 1)] = (get_arg_systime() - g_TimePerWave_SysTime[(g_Wave - 1)]);
		
		new iLen = 0;
		new j = 0;
		
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "INSERT INTO `td4_time_per_wave` (`wave`, `players`, `time_seconds`, `diff`, `map_name`, ");
		
		for(i = 1; i <= MaxClients; ++i) {
			if(is_user_connected(i) && g_TimePerWave_Ids[i]) {
				++j;
				
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`name%d`, ", j);
			}
		}
		
		g_SqlQuery[(iLen - 2)] = EOS;
		iLen -= 2;
		
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), ") VALUES ('%d', '%d', '%d', '%d', ^"%s^", ", g_Wave, j, g_TimePerWave_SysTime[(g_Wave - 1)], g_Diff, g_CurrentMap);
		
		for(i = 1; i <= MaxClients; ++i) {
			if(is_user_connected(i) && g_TimePerWave_Ids[i]) {
				g_TimePerWave_Ids[i] = 0;

				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "^"%n^", ", i);
			}
		}
		
		g_SqlQuery[(iLen - 2)] = EOS;
		iLen -= 2;
		
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), ");");
		SQL_ThreadQuery(g_SqlTuple, "@sqlThread__IgnoreQuery", g_SqlQuery);
	}

	if(g_Wave >= MAX_WAVES) {
		if(!g_Tramposo) {
			new iTime = 0;
			
			for(i = 0; i < (MAX_WAVES + 1); ++i) {
				iTime += g_TimePerWave_SysTime[i];
			}

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `td4_time_per_map` (`map_name`, `time_seconds`, `diff`) VALUES (^"%s^", '%d', '%d')", g_CurrentMap, iTime, g_Diff);
			SQL_ThreadQuery(g_SqlTuple, "@sqlThread__IgnoreQuery", g_SqlQuery);
		}
		
		endGame();
		
		for(i = 1; i <= MaxClients; ++i) {
			if(g_Achievement_DefensaAbsoluta) {
				if(!is_user_connected(i)) {
					continue;
				}
				
				setAchievement(i, (DEFENSA_ABSOLUTA_NOOB + g_Diff));
			}
			
			if(!is_user_alive(i)) {
				continue;
			}
			
			g_AchievementMap[i] = 1;
			
			reloadWeapons(i);
		}
	} else {
		switch(g_Diff) {
			case DIFF_NORMAL: {
				g_TotalMonsters = 44;

				set_task(49.0, "task__StartWave", TASK_WAVES); // +5
				set_task(1.0, "task__RepeatHud", .flags="a", .repeat=45); // +1
			} case DIFF_NIGHTMARE: {
				g_TotalMonsters = 39;

				set_task(44.0, "task__StartWave", TASK_WAVES); // +5
				set_task(1.0, "task__RepeatHud", .flags="a", .repeat=40); // +1
			} case DIFF_SUICIDAL: {
				g_TotalMonsters = 34;

				set_task(39.0, "task__StartWave", TASK_WAVES); // +5
				set_task(1.0, "task__RepeatHud", .flags="a", .repeat=35); // +1
			} case DIFF_HELL: {
				g_TotalMonsters = 29;

				set_task(34.0, "task__StartWave", TASK_WAVES); // +5
				set_task(1.0, "task__RepeatHud",.flags="a", .repeat=30); // +1
			}
		}
	}

	new iRandomGold = (random_num(50, 80) * g_Wave);
	clientPrintColor(0, _, "Todos los usuarios vivos ganaron !g%d Oro!y por sobrevivir a la oleada.", iRandomGold);

	new iClassReq = 0;
	new TeamName:iTeam = TEAM_UNASSIGNED;
	new iPercent = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}
		
		if(g_ClassId[i] == CLASS_INGENIERO) {
			iClassReq = __CLASSES[CLASS_INGENIERO][classReqLv1 + g_ClassLevel[i][CLASS_INGENIERO]];

			if((get_user_flags(i) & ADMIN_RESERVATION)) {
				iClassReq = iClassReq - ((iClassReq * 20) / 100);
			}

			if(g_ClassReqs[i][CLASS_INGENIERO] >= iClassReq) {
				++g_ClassLevel[i][CLASS_INGENIERO];
				
				clientPrintColor(0, _, "!t%n!y subió de nivel a su !tINGENIERO!y al nivel !g%d!y.", i, g_ClassLevel[i][CLASS_INGENIERO]);
			}

			saveClassesProgress(i, dg_get_user_acc_id(i), CLASS_INGENIERO);
		}
		
		if(is_user_alive(i)) {
			g_Gold[i] += iRandomGold;
			g_GoldG[i] += iRandomGold;
			g_GoldMap[i] += iRandomGold;
			
			switch(g_Diff) {
				case DIFF_NORMAL: {
					++g_WavesWins[i][DIFF_NORMAL][0];
				} case DIFF_NIGHTMARE: {
					++g_WavesWins[i][DIFF_NORMAL][0];
					++g_WavesWins[i][DIFF_NIGHTMARE][0];
				} case DIFF_SUICIDAL: {
					++g_WavesWins[i][DIFF_NORMAL][0];
					++g_WavesWins[i][DIFF_NIGHTMARE][0];
					++g_WavesWins[i][DIFF_SUICIDAL][0];
				} case DIFF_HELL: {
					++g_WavesWins[i][DIFF_NORMAL][0];
					++g_WavesWins[i][DIFF_NIGHTMARE][0];
					++g_WavesWins[i][DIFF_SUICIDAL][0];
					++g_WavesWins[i][DIFF_HELL][0];
				}
			}
			
			++g_WavesWins[i][g_Diff][g_Wave];
			
			if(g_Diff >= DIFF_NORMAL) {
				if(!(g_WavesWins[i][DIFF_NORMAL][0] % 100)) {
					switch(g_WavesWins[i][DIFF_NORMAL][0]) {
						case 100: {
							setAchievement(i, WAVES_NORMAL_100);
						} case 500: {
							setAchievement(i, WAVES_NORMAL_500);
						} case 1000: {
							setAchievement(i, WAVES_NORMAL_1000);
						} case 2500: {
							setAchievement(i, WAVES_NORMAL_2500);
						} case 5000: {
							setAchievement(i, WAVES_NORMAL_5000);
						} case 10000: {
							setAchievement(i, WAVES_NORMAL_10K);
						} case 25000: {
							setAchievement(i, WAVES_NORMAL_25K);
						} case 50000: {
							setAchievement(i, WAVES_NORMAL_50K);
						} case 100000: {
							setAchievement(i, WAVES_NORMAL_100K);
						} case 250000: {
							setAchievement(i, WAVES_NORMAL_250K);
						} case 500000: {
							setAchievement(i, WAVES_NORMAL_500K);
						} case 1000000: {
							setAchievement(i, WAVES_NORMAL_1M);
						}
					}
				}
				
				if(g_Diff >= DIFF_NIGHTMARE) {
					if(!(g_WavesWins[i][DIFF_NIGHTMARE][0] % 100)) {
						switch(g_WavesWins[i][DIFF_NIGHTMARE][0]) {
							case 100: {
								setAchievement(i, WAVES_NIGHTMARE_100);
							} case 500: {
								setAchievement(i, WAVES_NIGHTMARE_500);
							} case 1000: {
								setAchievement(i, WAVES_NIGHTMARE_1000);
							} case 2500: {
								setAchievement(i, WAVES_NIGHTMARE_2500);
							} case 5000: {
								setAchievement(i, WAVES_NIGHTMARE_5000);
							} case 10000: {
								setAchievement(i, WAVES_NIGHTMARE_10K);
							} case 25000: {
								setAchievement(i, WAVES_NIGHTMARE_25K);
							} case 50000: {
								setAchievement(i, WAVES_NIGHTMARE_50K);
							} case 100000: {
								setAchievement(i, WAVES_NIGHTMARE_100K);
							} case 250000: {
								setAchievement(i, WAVES_NIGHTMARE_250K);
							} case 500000: {
								setAchievement(i, WAVES_NIGHTMARE_500K);
							} case 1000000: {
								setAchievement(i, WAVES_NIGHTMARE_1M);
							}
						}
					}
					
					if(g_Diff >= DIFF_SUICIDAL) {
						if(!(g_WavesWins[i][DIFF_SUICIDAL][0] % 100)) {
							switch(g_WavesWins[i][DIFF_SUICIDAL][0]) {
								case 100: {
									setAchievement(i, WAVES_SUICIDAL_100);
								} case 500: {
									setAchievement(i, WAVES_SUICIDAL_500);
								} case 1000: {
									setAchievement(i, WAVES_SUICIDAL_1000);
								} case 2500: {
									setAchievement(i, WAVES_SUICIDAL_2500);
								} case 5000: {
									setAchievement(i, WAVES_SUICIDAL_5000);
								} case 10000: {
									setAchievement(i, WAVES_SUICIDAL_10K);
								} case 25000: {
									setAchievement(i, WAVES_SUICIDAL_25K);
								} case 50000: {
									setAchievement(i, WAVES_SUICIDAL_50K);
								} case 100000: {
									setAchievement(i, WAVES_SUICIDAL_100K);
								} case 250000: {
									setAchievement(i, WAVES_SUICIDAL_250K);
								} case 500000: {
									setAchievement(i, WAVES_SUICIDAL_500K);
								} case 1000000: {
									setAchievement(i, WAVES_SUICIDAL_1M);
								}
							}
						}
						
						if(g_Diff == DIFF_HELL) {
							if(!(g_WavesWins[i][DIFF_HELL][0] % 100)) {
								switch(g_WavesWins[i][DIFF_HELL][0]) {
									case 100: {
										setAchievement(i, WAVES_HELL_100);
									} case 500: {
										setAchievement(i, WAVES_HELL_500);
									} case 1000: {
										setAchievement(i, WAVES_HELL_1000);
									} case 2500: {
										setAchievement(i, WAVES_HELL_2500);
									} case 5000: {
										setAchievement(i, WAVES_HELL_5000);
									} case 10000: {
										setAchievement(i, WAVES_HELL_10K);
									} case 25000: {
										setAchievement(i, WAVES_HELL_25K);
									} case 50000: {
										setAchievement(i, WAVES_HELL_50K);
									} case 100000: {
										setAchievement(i, WAVES_HELL_100K);
									} case 250000: {
										setAchievement(i, WAVES_HELL_250K);
									} case 500000: {
										setAchievement(i, WAVES_HELL_500K);
									} case 1000000: {
										setAchievement(i, WAVES_HELL_1M);
									}
								}
							}
						}
					}
				}
			}
			
			if(g_Level[i] < 100) {
				if(g_Kills[i] >= __LEVELS[g_Level[i]][levelKills] &&
				g_WavesWins[i][DIFF_NORMAL][0] >= __LEVELS[g_Level[i]][levelWaveNormal] &&
				g_WavesWins[i][DIFF_NIGHTMARE][0] >= __LEVELS[g_Level[i]][levelWaveNightmare] &&
				g_WavesWins[i][DIFF_SUICIDAL][0] >= __LEVELS[g_Level[i]][levelWaveSuicidal] &&
				g_WavesWins[i][DIFF_HELL][0] >= __LEVELS[g_Level[i]][levelWaveHell] &&
				g_BossKills[i][DIFF_NORMAL] >= __LEVELS[g_Level[i]][levelBossNormal] &&
				g_BossKills[i][DIFF_NIGHTMARE] >= __LEVELS[g_Level[i]][levelBossNightmare] &&
				g_BossKills[i][DIFF_SUICIDAL] >= __LEVELS[g_Level[i]][levelBossSuicidal] &&
				g_BossKills[i][DIFF_HELL] >= __LEVELS[g_Level[i]][levelBossHell]) {
					++g_Level[i];
					++g_Points[i];

					switch(g_Level[i]) {
						case 10: {
							setAchievement(i, NIVEL_10);
						} case 20: {
							setAchievement(i, NIVEL_20);
						} case 30: {
							setAchievement(i, NIVEL_30);
						} case 40: {
							setAchievement(i, NIVEL_40);
						} case 50: {
							setAchievement(i, NIVEL_50);
						} case 60: {
							setAchievement(i, NIVEL_60);
						} case 70: {
							setAchievement(i, NIVEL_70);
						} case 80: {
							setAchievement(i, NIVEL_80);
						} case 90: {
							setAchievement(i, NIVEL_90);
						} case 100: {
							setAchievement(i, NIVEL_100);
						}
					}
					
					clientPrint(i, print_center, "¡SUBISTE DE NIVEL!");
				}
			}

			updateHealth(i, HEALTH_BASE);

			if(g_UnlimitedClip[i]) {
				--g_UnlimitedClip_WavesLeft[i];

				if(!g_UnlimitedClip_WavesLeft[i]) {
					g_UnlimitedClip[i] = 0;
					clientPrintColor(i, _, "Tus balas infinitas se terminaron.");
				} else {
					clientPrintColor(i, _, "A tus balas infinitas aún le quedan !g%d!y oleadas restantes.", g_UnlimitedClip_WavesLeft[i]);
				}
			}

			if(g_PrecisionPerfecta[i]) {
				--g_PrecisionPerfecta_WavesLeft[i];

				if(!g_PrecisionPerfecta_WavesLeft[i]) {
					g_PrecisionPerfecta[i] = 0;
					clientPrintColor(i, _, "Tu precisión perfecta se terminaron.");
				} else {
					clientPrintColor(i, _, "A tu precisión perfecta aun le quedan !g%d!y oleadas restantes.", g_PrecisionPerfecta_WavesLeft[i]);
				}
			}

			if(g_GoldMap[i] >= 30000) {
				setAchievement(i, AVARICIOSO_TOTAL);
			}

			if(g_Achievement_FaltaDeDefensores) {
				iPercent = ((50 * g_TowerHealth) / 100);

				if(g_Achievement_FaltaDeDefensores >= iPercent) {
					setAchievement(i, FALTA_DE_DEFENSORES);
				}

				iPercent = ((90 * g_TowerHealth) / 100);

				if(g_Achievement_FaltaDeDefensores >= iPercent) {
					setAchievement(i, PROTECCION_NULA);
				}
			}

			continue;
		}
		
		iTeam = getUserTeam(i);

		if(!(TEAM_TERRORIST <= iTeam <= TEAM_CT)) {
			continue;
		}
		
		rg_round_respawn(i);
	}

	new iUsers = 0;
	new iMaxKills = 0;
	new iMaxId = 0;
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}
		
		++iUsers;
		
		if(g_KillsPerWave[i][g_Wave] > iMaxKills) {
			iMaxKills = g_KillsPerWave[i][g_Wave];
			iMaxId = i;
		}
	}

	if(iUsers > 1 && iMaxId) {
		new iIds[MAX_PLAYERS + 1];
		new iRepeat = 0;
		new j = 0;
		new k;
		
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}
			
			if(i == iMaxId) {
				continue;
			}
			
			if(g_KillsPerWave[i][g_Wave] == iMaxKills) {
				iIds[j] = i;
				++iRepeat;
				++j;
			}
		}
		
		iRandomGold /= (2 + iRepeat);
		
		clientPrintColor(0, _, "El jugador !t%n!y ganó !g%d Oro!y por ser el que más monstruos mató (!g%d!y).", iMaxId, iRandomGold, iMaxKills);
		
		g_Gold[iMaxId] += iRandomGold;
		g_GoldG[iMaxId] += iRandomGold;
		g_GoldMap[iMaxId] += iRandomGold;
		
		if(j) {
			for(k = 0; k < j; ++k) {
				if(is_user_connected(k)) {
					clientPrintColor(0, _, "El jugador !t%n!y ganó !g%d Oro!y por ser el que más monstruos mató (!g%d!y).", k, iRandomGold, iMaxKills);
				}
			}
			
			for(i = 1; i <= MaxClients; ++i) {
				if(!is_user_connected(i)) {
					continue;
				}
				
				if(i == iMaxId) {
					continue;
				}
				
				if(g_KillsPerWave[i][g_Wave] == iMaxKills) {
					g_Gold[i] += iRandomGold;
					g_GoldG[i] += iRandomGold;
					g_GoldMap[i] += iRandomGold;
				}
			}
		}

		new iMinPlaying = getUsersPlaying(TEAM_CT);
		
		if(iMinPlaying > 2) {
			++g_WinMVP[iMaxId];
			++g_WinMVPGaben[iMaxId];
			
			if(g_WinMVPGaben[iMaxId] == 1) {
				setAchievement(iMaxId, MVP_1);
			}
			
			if(!(g_WinMVPGaben[iMaxId] % 5)) {
				switch(g_WinMVPGaben[iMaxId]) {
					case 10: {
						setAchievement(iMaxId, MVP_10);
					} case 25: {
						setAchievement(iMaxId, MVP_25);
					} case 50: {
						setAchievement(iMaxId, MVP_50);
					} case 100: {
						setAchievement(iMaxId, MVP_100);
					} case 250: {
						setAchievement(iMaxId, MVP_250);
					} case 500: {
						setAchievement(iMaxId, MVP_500);
					} case 1000: {
						setAchievement(iMaxId, MVP_1000);
					} case 2500: {
						setAchievement(iMaxId, MVP_2500);
					} case 5000: {
						setAchievement(iMaxId, MVP_5000);
					} case 10000: {
						setAchievement(iMaxId, MVP_10K);
					} case 25000: {
						setAchievement(iMaxId, MVP_25K);
					} case 50000: {
						setAchievement(iMaxId, MVP_50K);
					} case 100000: {
						setAchievement(iMaxId, MVP_100K);
					} case 250000: {
						setAchievement(iMaxId, MVP_250K);
					} case 500000: {
						setAchievement(iMaxId, MVP_500K);
					} case 1000000: {
						setAchievement(iMaxId, MVP_1M);
					}
				}
			}
			
			if(g_WinMVP_Last == iMaxId || !g_WinMVP_Last) {
				++g_WinMVPNext[iMaxId];
				
				switch(g_WinMVPNext[iMaxId]) {
					case 2: {
						setAchievement(iMaxId, MVP_2C);
					} case 3: {
						setAchievement(iMaxId, MVP_3C);
					} case 4: {
						setAchievement(iMaxId, MVP_4C);
					} case 5: {
						setAchievement(iMaxId, MVP_5C);
					} case 6: {
						setAchievement(iMaxId, MVP_6C);
					} case 7: {
						setAchievement(iMaxId, MVP_7C);
					} case 8: {
						setAchievement(iMaxId, MVP_8C);
					} case 9: {
						setAchievement(iMaxId, MVP_9C);
					} case 10: {
						setAchievement(iMaxId, MVP_10C);
					}
				}
			} else {
				for(i = 1; i <= MaxClients; ++i) {
					g_WinMVPNext[i] = 0;
				}
				
				++g_WinMVPNext[iMaxId];
			}
		}
		
		g_WinMVP_Last = iMaxId;
	}
}

endGame() {
	client_cmd(0, "mp3 play %s", __SOUND_WIN_GAME);
	
	g_TotalMonsters = 29;
	g_BossMenu_TimeLeft = 10;

	set_task(10.0, "task__VoteBoss");
	set_task(30.0, "task__StartWave", TASK_WAVES);
	set_task(1.0, "task__RepeatHud", .flags="a", .repeat=30);
}

createMiniBoss() {
	if(is_valid_ent(g_Boss)) {
		remove_entity(g_Boss);
	}
	
	if(is_valid_ent(g_EntCheckAfk)) {
		entity_set_float(g_EntCheckAfk, EV_FL_nextthink, 9999.0);
		remove_entity(g_EntCheckAfk);
	}
	
	g_TotalMonsters = 1;
	g_MonstersAlive = 1;
	
	new iMiniBossCount = 1;
	new iMiniBossHealth = 500;
	
	register_think(__ENT_CLASSNAME_MINIBOSS, "@think__MiniBoss");
	
	switch(g_BossId) {
		case BOSS_GORILA: {
			RegisterHookChain(RG_CBasePlayer_Jump, "@CBasePlayer_Jump_Pre", false);

			iMiniBossHealth = 1500;
		} case BOSS_GUARDIANES: {
			RegisterHookChain(RG_CBasePlayer_Jump, "@CBasePlayer_Jump_Pre", false);
			
			g_TotalMonsters = 3;
			g_MonstersAlive = 3;

			iMiniBossCount = 3;
		}
	}
	
	new iRespawn = find_ent_by_tname(-1, "respawn_boss");
	new Float:vecRespawnOrigin[3];

	if(is_valid_ent(iRespawn) && iRespawn != 0) {
		entity_get_vector(iRespawn, EV_VEC_origin, vecRespawnOrigin);
	}
	
	g_HamHook_Killed = RegisterHam(Ham_Killed, "info_target", "@Ham_MiniBossKilled_Pre", false);
	g_HamHook_TakeDamage = RegisterHam(Ham_TakeDamage, "info_target", "@Ham_MiniBossTakeDamage_Pre", false);
	
	new i;
	new iEnt;
	new iHealth = (iMiniBossHealth * getUsersAlive());
	new Float:flVelocity;
	new Float:flGameTime = get_gametime();

	for(i = 0; i < iMiniBossCount; ++i) {
		iEnt = create_entity("info_target");
		
		if(is_valid_ent(iEnt)) {
			g_MiniBoss_Ids[i] = iEnt;
			
			entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_MINIBOSS);
			
			dllfunc(DLLFunc_Spawn, iEnt);
			
			entity_set_model(iEnt, __MODEL_MINIBOSS);
			entity_set_float(iEnt, EV_FL_health, float(iHealth));
			entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_YES);
			
			entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
			entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
			
			switch(i) {
				case 1: {
					vecRespawnOrigin[__MAPS[g_MapId][mapBossCoord]] -= 400.0;
				} case 2: {
					vecRespawnOrigin[__MAPS[g_MapId][mapBossCoord]] += 800.0;
				}
			}
			
			entity_set_origin(iEnt, vecRespawnOrigin);
			
			entity_set_float(iEnt, EV_FL_gravity, 1.0);
			
			entity_set_int(iEnt, EV_INT_sequence, 3);
			entity_set_float(iEnt, EV_FL_animtime, flGameTime);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			entity_set_int(iEnt, MONSTER_MAXHEALTH, iHealth);
			entity_set_int(iEnt, MONSTER_TYPE, MONSTER_TYPE_BOSS);
			entity_set_int(iEnt, MONSTER_TARGET, 0);
			
			entity_set_size(iEnt, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 36.0});
			
			entity_set_vector(iEnt, EV_VEC_mins, Float:{-16.0, -16.0, -36.0});
			entity_set_vector(iEnt, EV_VEC_maxs, Float:{16.0, 16.0, 36.0});
			
			flVelocity = 225.0;

			entity_set_float(iEnt, EV_FL_framerate, (flVelocity / 250.0));
			
			set_task(4.0, "task__ChangeMoveType", iEnt);
			
			entity_set_float(iEnt, EV_FL_nextthink, (flGameTime + 5.0));
		}
	}
	
	clearDirectorHud();
	set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
}

specialEffectToBoss() {
	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 4);
	write_short(UNIT_SECOND * 4);
	write_short(SF_FADE_IN);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(255);
	message_end();
	
	set_task(4.5, "task__MoveUsersToBoss");
}

createBoss() {
	g_Boss = create_entity("info_target");
	
	if(is_valid_ent(g_Boss)) {
		new iRespawn = find_ent_by_tname(-1, "respawn_boss");
		
		if(is_valid_ent(iRespawn) && iRespawn != 0) {
			entity_get_vector(iRespawn, EV_VEC_origin, g_BossRespawn);
		}
		
		DisableHamForward(g_HamHook_Killed);
		DisableHamForward(g_HamHook_TakeDamage);
		
		new iHealth = (__DIFFS_VALUES[g_Diff][diffValueBossHealth] * getUsersAlive());
		new iExtraDamage = (getTotalExtraDamage() / 10);
		new Float:vecMins[3];
		new Float:vecMax[3];
		new Float:flVelocity;
		
		switch(g_BossId) {
			case BOSS_GORILA: {
				g_BossGorila_AttractPowerHP[0] = random_num(1500, 4000);
				
				vecMins = Float:{-32.0, -32.0, -36.0};
				vecMax = Float:{32.0, 32.0, 9999.0};
				
				RegisterHookChain(RG_CBasePlayer_Duck, "@CBasePlayer_Duck_Pre", false);

				register_think(__ENT_CLASSNAME_BOSS, "@think__Boss");
			} case BOSS_FIRE: {
				iHealth *= 3;
				
				g_BossFire_UltimateHealth = (iHealth / 3);
				
				vecMins = Float:{-30.0, -60.0, -40.0};
				vecMax = Float:{30.0, 60.0, 9999.0};
				
				register_think(__ENT_CLASSNAME_BOSS, "@think__BossFireMonster");
				register_think(__ENT_CLASSNAME_BOSS_FM_BALL, "@think__FireMonsterBall");
				
				register_touch(__ENT_CLASSNAME_BOSS, "*", "@touch__BossFireMonster");
				register_touch(__ENT_CLASSNAME_BOSS_FM_BALL, "*", "@touch__FireMonsterBall");
			} case BOSS_FALLEN_TITAN: {
				iHealth *= 4;
				
				g_BossFT_UltimateHealth = (iHealth / 3);
				
				vecMins = Float:{-30.0, -60.0, -36.0};
				vecMax = Float:{30.0, 60.0, 9999.0};
				
				register_think(__ENT_CLASSNAME_BOSS, "@think__BossFallenTitan");				
				register_touch(__ENT_CLASSNAME_BOSS, "*", "@touch__BossFallenTitan");
			} case BOSS_GUARDIANES: {
				set_lights(g_Lights[0]);
				
				iHealth *= 4;

				g_BossGorila_AttractPowerHP[0] = random_num(2000, 6000);
				g_BossGorila_AttractPowerHP[1] = random_num(2000, 6000);
				
				vecMins = Float:{-32.0, -32.0, -36.0};
				vecMax = Float:{32.0, 32.0, 9999.0};
				
				RegisterHookChain(RG_CBasePlayer_Duck, "@CBasePlayer_Duck_Pre", false);
				
				register_think(__ENT_CLASSNAME_BOSS, "@think__BossKyra");
			}
		}

		iHealth = (iHealth + ((iHealth * iExtraDamage) / 100));
		
		entity_set_string(g_Boss, EV_SZ_classname, __ENT_CLASSNAME_BOSS);
		
		dllfunc(DLLFunc_Spawn, g_Boss);
		
		g_HamHook_Killed = RegisterHam(Ham_Killed, "info_target", "@Ham_BossKilled_Pre", false);
		g_HamHook_TakeDamage = RegisterHam(Ham_TakeDamage, "info_target", "@Ham_BossTakeDamage_Pre", false);
		
		entity_set_model(g_Boss, __MODELS_BOSS[g_BossId]);
		entity_set_float(g_Boss, EV_FL_health, float(iHealth));
		entity_set_float(g_Boss, EV_FL_takedamage, ((g_BossId != BOSS_GUARDIANES) ? DAMAGE_YES : DAMAGE_NO));
		
		entity_set_vector(g_Boss, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(g_Boss, EV_INT_solid, SOLID_BBOX);
		entity_set_int(g_Boss, EV_INT_movetype, MOVETYPE_TOSS);
		
		entity_set_origin(g_Boss, g_BossRespawn);
		
		entity_set_float(g_Boss, EV_FL_gravity, 1.0);
		
		set_task(2.0, "task__ChangeMoveType", g_Boss);
		set_task(0.6, "task__ScreenShakeAnimChange");
		
		entity_set_int(g_Boss, EV_INT_sequence, ((g_BossId != BOSS_GUARDIANES) ? 1 : 146));
		entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
		
		entity_set_int(g_Boss, EV_INT_gamestate, 1);
		
		entity_set_int(g_Boss, MONSTER_MAXHEALTH, iHealth);
		entity_set_int(g_Boss, MONSTER_TYPE, MONSTER_TYPE_BOSS);
		entity_set_int(g_Boss, MONSTER_TARGET, 0);
		
		entity_set_size(g_Boss, vecMins, vecMax);
		
		entity_set_vector(g_Boss, EV_VEC_mins, vecMins);
		entity_set_vector(g_Boss, EV_VEC_maxs, vecMax);
		
		drop_to_floor(g_Boss);
		
		flVelocity = 300.0;
		entity_set_float(g_Boss, EV_FL_framerate, (flVelocity / 250.0));

		if(g_BossId == BOSS_FALLEN_TITAN) {
			entity_set_int(g_Boss, EV_INT_sequence, 5);
			entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
			entity_set_float(g_Boss, EV_FL_framerate, 1.0);
			
			entity_set_int(g_Boss, EV_INT_gamestate, 1);
		}
		
		switch(g_BossId) {
			case BOSS_GUARDIANES: {
				g_TotalMonsters = 3;
				g_MonstersAlive = 3;
				
				entity_set_float(g_Boss, EV_FL_nextthink, (get_gametime() + 20.0));
				
				createGuardians();
			} default: {
				g_TotalMonsters = 1;
				g_MonstersAlive = 1;
				
				entity_set_float(g_Boss, EV_FL_nextthink, (get_gametime() + 3.0));

				g_Boss_HealthBar = create_entity("env_sprite");
				
				if(g_Boss_HealthBar) {
					entity_set_int(g_Boss_HealthBar, EV_INT_spawnflags, SF_SPRITE_STARTON);
					entity_set_int(g_Boss_HealthBar, EV_INT_solid, SOLID_NOT);
					
					entity_set_model(g_Boss_HealthBar, __SPRITE_BOSS_HEALTH);
					
					entity_set_float(g_Boss_HealthBar, EV_FL_scale, 0.5);
					
					entity_set_float(g_Boss_HealthBar, EV_FL_frame, 100.0);
					
					// g_BossRespawn[2] += 200.0;
					entity_set_origin(g_Boss_HealthBar, g_BossRespawn);
					
					g_FwdAddToFullPack_Status = 1;
					g_FwdAddToFullPack = register_forward(FM_AddToFullPack, "@FM_AddToFullPackBoss_Post", 1);
				}
			}
		}
		
		clearDirectorHud();
		set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
	}
}

createGuardians() {
	g_BossGuardians = 2;
	
	register_think(__ENT_CLASSNAME_BOSS_GK, "@think__BossGuardians");
	
	new i;
	for(i = 0; i < 2; ++i) {
		g_BossGuardians_Ids[i] = create_entity("info_target");
		
		if(is_valid_ent(g_BossGuardians_Ids[i])) {
			new iHealth;
			new iExtraDamage = (getTotalExtraDamage() / 10);
			new Float:flVelocity;
			new Float:vecMins[3];
			new Float:vecMax[3];

			iHealth = (10000 + (__DIFFS_VALUES[g_Diff][diffValueBossHealth] * getUsersAlive()));
			iHealth = (iHealth + ((iHealth * iExtraDamage) / 100));
			
			vecMins = Float:{-32.0, -32.0, -36.0};
			vecMax = Float:{32.0, 32.0, 9999.0};
			
			entity_set_string(g_BossGuardians_Ids[i], EV_SZ_classname, __ENT_CLASSNAME_BOSS_GK);
			
			dllfunc(DLLFunc_Spawn, g_BossGuardians_Ids[i]);
			
			entity_set_model(g_BossGuardians_Ids[i], __MODELS_BOSS[BOSS_GORILA]);
			entity_set_float(g_BossGuardians_Ids[i], EV_FL_health, float(iHealth));
			entity_set_float(g_BossGuardians_Ids[i], EV_FL_takedamage, DAMAGE_YES);
			
			entity_set_vector(g_BossGuardians_Ids[i], EV_VEC_angles, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(g_BossGuardians_Ids[i], EV_INT_solid, SOLID_BBOX);
			entity_set_int(g_BossGuardians_Ids[i], EV_INT_movetype, MOVETYPE_TOSS);
			
			switch(i) {
				case 0: {
					g_BossRespawn[__MAPS[g_MapId][mapBossCoord]] -= 400.0;
				} case 1: {
					g_BossRespawn[__MAPS[g_MapId][mapBossCoord]] += 800.0; // 400.0
				}
			}
			
			entity_set_origin(g_BossGuardians_Ids[i], g_BossRespawn);
			
			entity_set_float(g_BossGuardians_Ids[i], EV_FL_gravity, 1.0);
			
			set_task(2.0, "task__ChangeMoveType", g_BossGuardians_Ids[i]);
			
			entity_set_int(g_BossGuardians_Ids[i], EV_INT_sequence, 1);
			entity_set_float(g_BossGuardians_Ids[i], EV_FL_animtime, get_gametime());
			
			entity_set_int(g_BossGuardians_Ids[i], EV_INT_gamestate, 1);
			
			entity_set_int(g_BossGuardians_Ids[i], MONSTER_MAXHEALTH, iHealth);
			entity_set_int(g_BossGuardians_Ids[i], MONSTER_TYPE, MONSTER_TYPE_BOSS);
			entity_set_int(g_BossGuardians_Ids[i], MONSTER_TARGET, 0);
			
			entity_set_size(g_BossGuardians_Ids[i], vecMins, vecMax);
			
			entity_set_vector(g_BossGuardians_Ids[i], EV_VEC_mins, vecMins);
			entity_set_vector(g_BossGuardians_Ids[i], EV_VEC_maxs, vecMax);
			
			drop_to_floor(g_BossGuardians_Ids[i]);
			
			flVelocity = 280.0;
			entity_set_float(g_BossGuardians_Ids[i], EV_FL_framerate, (flVelocity / 250.0));
			
			entity_set_float(g_BossGuardians_Ids[i], EV_FL_nextthink, (get_gametime() + 3.0));

			g_BossGuardians_HealthBar[i] = create_entity("env_sprite");
			
			if(is_valid_ent(g_BossGuardians_HealthBar[i])) {
				entity_set_int(g_BossGuardians_HealthBar[i], EV_INT_spawnflags, SF_SPRITE_STARTON);
				entity_set_int(g_BossGuardians_HealthBar[i], EV_INT_solid, SOLID_NOT);
				
				entity_set_model(g_BossGuardians_HealthBar[i], __SPRITE_BOSS_HEALTH);
				
				entity_set_float(g_BossGuardians_HealthBar[i], EV_FL_scale, 0.5);
				
				entity_set_float(g_BossGuardians_HealthBar[i], EV_FL_frame, 100.0);
				
				// g_BossRespawn[2] += 200.0;
				entity_set_origin(g_BossGuardians_HealthBar[i], g_BossRespawn);
				
				switch(i) {
					case 0: {
						g_BossRespawn[__MAPS[g_MapId][mapBossCoord]] += 400.0;
						g_BossRespawn[2] -= 200.0;
					} case 1: {
						g_BossRespawn[__MAPS[g_MapId][mapBossCoord]] -= 400.0;
						g_BossRespawn[2] -= 200.0;
					}
				}
				
				if(!g_FwdAddToFullPack_Status) {
					g_FwdAddToFullPack_Status = 1;
					g_FwdAddToFullPack = register_forward(FM_AddToFullPack, "@FM_AddToFullPackBossGuardians_Post", true);
				}
			}
		}
	}
}

checkUsersSomeThings() {
	new i;
	new const __BOSSES_REWARD[structIdBosses][structIdDiffs] = {
		{ // GORILA
			1,	// NORMAL
			2,	// NIGHTMARE
			3,	// SUICIDAL
			4	// HELL
		}, { // FIRE MONSTER
			2,	// NORMAL
			3,	// NIGHTMARE
			4,	// SUICIDAL
			5	// HELL
		}, { // FALLEN TITAN
			3,	// NORMAL
			4,	// NIGHTMARE
			5,	// SUICIDAL
			6	// HELL
		}, { // GUARDIANES DE KYRA
			4,	// NORMAL
			5,	// NIGHTMARE
			6,	// SUICIDAL
			7	// HELL
		}
	};
	new iRep;
	new iClassReq;

	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}
		
		if(g_ClassId[i] == CLASS_INGENIERO) {
			iClassReq = (__CLASSES[CLASS_INGENIERO][classReqLv1 + g_ClassLevel[i][CLASS_INGENIERO]]);

			if((get_user_flags(i) & ADMIN_RESERVATION)) {
				iClassReq = (iClassReq - ((iClassReq * 20) / 100));
			}

			if(g_ClassReqs[i][CLASS_INGENIERO] >= iClassReq) {
				++g_ClassLevel[i][CLASS_INGENIERO];
				
				clientPrintColor(0, _, "!t%n!y subió de nivel a su !tINGENIERO!y al nivel !g%d!y.", i, g_ClassLevel[i][CLASS_INGENIERO]);
			}

			saveClassesProgress(i, dg_get_user_acc_id(i), CLASS_INGENIERO);
		}
		
		if(is_user_alive(i)) {
			switch(g_Diff) {
				case DIFF_NORMAL: {
					++g_BossKills[i][DIFF_NORMAL];
				} case DIFF_NIGHTMARE: {
					++g_BossKills[i][DIFF_NORMAL];
					++g_BossKills[i][DIFF_NIGHTMARE];
				} case DIFF_SUICIDAL: {
					++g_BossKills[i][DIFF_NORMAL];
					++g_BossKills[i][DIFF_NIGHTMARE];
					++g_BossKills[i][DIFF_SUICIDAL];
				} case DIFF_HELL: {
					++g_BossKills[i][DIFF_NORMAL];
					++g_BossKills[i][DIFF_NIGHTMARE];
					++g_BossKills[i][DIFF_SUICIDAL];
					++g_BossKills[i][DIFF_HELL];
				}
			}
		}
		
		if(g_Level[i] < 100) {
			if(g_Kills[i] >= __LEVELS[g_Level[i]][levelKills] &&
			g_WavesWins[i][DIFF_NORMAL][0] >= __LEVELS[g_Level[i]][levelWaveNormal] &&
			g_WavesWins[i][DIFF_NIGHTMARE][0] >= __LEVELS[g_Level[i]][levelWaveNightmare] &&
			g_WavesWins[i][DIFF_SUICIDAL][0] >= __LEVELS[g_Level[i]][levelWaveSuicidal] &&
			g_WavesWins[i][DIFF_HELL][0] >= __LEVELS[g_Level[i]][levelWaveHell] &&
			g_BossKills[i][DIFF_NORMAL] >= __LEVELS[g_Level[i]][levelBossNormal] &&
			g_BossKills[i][DIFF_NIGHTMARE] >= __LEVELS[g_Level[i]][levelBossNightmare] &&
			g_BossKills[i][DIFF_SUICIDAL] >= __LEVELS[g_Level[i]][levelBossSuicidal] &&
			g_BossKills[i][DIFF_HELL] >= __LEVELS[g_Level[i]][levelBossHell]) {
				++g_Level[i];
				++g_Points[i];

				switch(g_Level[i]) {
					case 10: {
						setAchievement(i, NIVEL_10);
					} case 20: {
						setAchievement(i, NIVEL_20);
					} case 30: {
						setAchievement(i, NIVEL_30);
					} case 40: {
						setAchievement(i, NIVEL_40);
					} case 50: {
						setAchievement(i, NIVEL_50);
					} case 60: {
						setAchievement(i, NIVEL_60);
					} case 70: {
						setAchievement(i, NIVEL_70);
					} case 80: {
						setAchievement(i, NIVEL_80);
					} case 90: {
						setAchievement(i, NIVEL_90);
					} case 100: {
						setAchievement(i, NIVEL_100);
					}
				}

				clientPrint(i, print_center, "¡SUBISTE DE NIVEL!");
			}
		}

		if(is_user_alive(i)) {
			if(g_AchievementMap[i]) {
				iRep = (g_Diff + 1);
				
				while(iRep) {
					--iRep;
					setAchievement(i, (__MAPS[g_MapId][mapAchievement] + iRep));
				}
			}
			
			iRep = (g_Diff + 1);
			
			while(iRep) {
				--iRep;
				setAchievement(i, (__BOSSES_NAME[g_BossId][bossAchievement] + iRep));
			}

			g_Os[i] += __BOSSES_REWARD[g_BossId][g_Diff];

			clientPrint(i, print_center, "¡+%d Os por sobrevivir al jefe final!", __BOSSES_REWARD[g_BossId][g_Diff]);
		}
	}
}

finishGame() {
	if(g_FinishGame) {
		return;
	}

	g_FinishGame = 1;
	g_EndGame = 1;
	g_WaveInProgress = 0;

	ClearSyncHud(0, g_HudSync_DamageTower);

	moveView();

	new i;
	for(i = 0; i < 2; ++i) {
		if(is_valid_ent(g_Tower[i])) {
			entity_set_float(g_Tower[i], EV_FL_animtime, get_gametime());
			entity_set_float(g_Tower[i], EV_FL_framerate, 1.0);
			entity_set_int(g_Tower[i], EV_INT_sequence, 1);
		}
	}

	set_task(2.0, "task__VoteMap");
}

moveView() {
	new sViewTowerFile[64];
	formatex(sViewTowerFile, charsmax(sViewTowerFile), "addons/amxmodx/configs/view_tower.ini");
	
	if(!file_exists(sViewTowerFile)) {
		write_file(sViewTowerFile, "; MAPA <X Y Z ANGLES>", -1);
		return;
	}
	
	new iFile;
	new sLine[256];
	new sMap[MAX_CHARACTER_MAPNAME];
	new sOrigin[3][16];
	new sAngles[3][16];
	new iEnt;
	new Float:vecAngles[3];
	
	iFile = fopen(sViewTowerFile, "rt");
	
	while(!feof(iFile))	{
		fgets(iFile, sLine, charsmax(sLine));

		if(!sLine[0] || sLine[0] == ';' || sLine[0] == ' ' || ( sLine[0] == '/' && sLine[1] == '/')) {
			continue;
		}

		parse(sLine, sMap, charsmax(sMap), sOrigin[0], charsmax(sOrigin[]), sOrigin[1], charsmax(sOrigin[]), sOrigin[2], charsmax(sOrigin[]), sAngles[0], charsmax(sAngles[]), sAngles[1], charsmax(sAngles[]), sAngles[2], charsmax(sAngles[]));
		
		if(equal(sMap, g_CurrentMap)) {
			iEnt = create_entity("info_target");
			
			if(is_valid_ent(iEnt)) {
				g_EntViewTowerFallingOrigin[0] = str_to_float(sOrigin[0]);
				g_EntViewTowerFallingOrigin[1] = str_to_float(sOrigin[1]);
				g_EntViewTowerFallingOrigin[2] = str_to_float(sOrigin[2]);
				
				vecAngles[0] = str_to_float(sAngles[0]);
				vecAngles[1] = str_to_float(sAngles[1]);
				vecAngles[2] = str_to_float(sAngles[2]);
				
				entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_VIEW_TOWER);
				entity_set_model(iEnt, "models/w_usp.mdl");

				entity_set_vector(iEnt, EV_VEC_origin, g_EntViewTowerFallingOrigin);
				
				entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
				entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
				
				entity_set_int(iEnt, EV_INT_sequence, 0);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				
				entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(iEnt, EV_FL_renderamt, 0.0);

				entity_set_size(iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});

				entity_set_vector(iEnt, EV_VEC_mins, Float:{-1.0, -1.0, -1.0});
				entity_set_vector(iEnt, EV_VEC_maxs, Float:{1.0, 1.0, 1.0});
				
				entity_set_vector(iEnt, EV_VEC_v_angle, vecAngles);
				entity_set_vector(iEnt, EV_VEC_angles, vecAngles);
			}
			
			break;
		}
	}
	
	fclose(iFile);
	
	if(is_valid_ent(iEnt)) {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}
			
			attach_view(i, iEnt);
		}
	}
}

getTotalLevel() {
	new i;
	new iTotalLevel = 0;
	
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i)) {
			iTotalLevel += g_Level[i];
		}
	}
	
	return iTotalLevel;
}

getTotalExtraDamage() {
	new i;
	new iExtraDamage = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i)) {
			iExtraDamage += g_Hab[i][HAB_DAMAGE];
		}
	}

	return iExtraDamage;
}

getMapRandomIn(const random) {
	new i;
	for(i = 0; i < g_VoteMap_i; ++i) {
		if(random == g_VoteMap_Next[i]) {
			return 1;
		}
	}
	
	return false;
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

createZone(const Float:vecPos[3], const Float:vecMins[3], const Float:vecMaxs[3], const zone_mode) {
	new iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_WALKGUARD);
		entity_set_model(iEnt, __MODEL_GIB_SKULL);

		entity_set_origin(iEnt, vecPos);
		entity_set_size(iEnt, vecMins, vecMaxs);
		
		if(g_EditorId) {
			entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
		} else {
			entity_set_int(iEnt, EV_INT_solid, __ZONE_SOLID_TYPE[zone_mode]);
		}
		
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
		
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
		
		entity_set_int(iEnt, EV_INT_iuser1, zone_mode);
		entity_set_int(iEnt, EV_INT_iuser4, 1337);
	}
	
	return iEnt;
}

zoneTouch(const monster, const ent) {
	new iZoneMode = get_entvar(ent, var_iuser1);
	
	switch(iZoneMode) {
		case ZONE_BLOCK_ALL, ZONE_BLOCK_ALL_2: {
			if(isBoomerMonster(monster)) {
				explodeBoomer(monster);	
				return;
			}
			
			if(isMonster(monster) && entity_get_int(monster, MONSTER_TRACK) != 1) {
				entity_set_int(monster, MONSTER_TRACK, 1);
				
				entity_set_int(monster, EV_INT_sequence, 76);
				entity_set_float(monster, EV_FL_animtime, get_gametime());
				entity_set_int(monster, EV_INT_gamestate, 1);
				
				entity_set_vector(monster, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				if(iZoneMode == ZONE_BLOCK_ALL) {
					entity_get_vector(monster, EV_VEC_origin, g_VecMonsterTowerOrigin[0]);
				} else {
					entity_get_vector(monster, EV_VEC_origin, g_VecMonsterTowerOrigin[1]);
				}
				
				rh_emit_sound2(monster, 0, CHAN_BODY, __SOUND_ZOMBIE_KNIFE[random_num(0, charsmax(__SOUND_ZOMBIE_KNIFE))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(monster, MONSTER_TARGET, 1337);
				
				set_hudmessage(255, 255, 0, -1.0, 0.26, 0, 0.0, 10.0, 0.0, 0.0, 4);
				ShowSyncHudMsg(0, g_HudSync_DamageTower, "¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!");
				
				new iDamage = 5;
				
				if(__DIFFS_VALUES[g_Diff][diffValueDamageTower]) {
					iDamage = (iDamage + ((iDamage * __DIFFS_VALUES[g_Diff][diffValueDamageTower]) / 100));
				}
				
				g_TowerHealth -= iDamage;
				g_Achievement_DefensaAbsoluta = 0;
				g_Achievement_FaltaDeDefensores += iDamage;
				
				set_task(1.0, "task__DamageTower", monster + TASK_DAMAGE_TOWER);

				if(g_RobotEnt && g_RobotMissileAllowed) {
					g_RobotMissileAllowed = 0;
					robotFireMissiles();
				}
			}
		} case ZONE_KILL_T1: {
			g_InBlockZone[monster] = 1;
		} case ZONE_KILL_T2: {
			g_InBlockZone[monster] = 0;
		}
	}
}

drawLine(const Float:x1, const Float:y1, const Float:z1, const Float:x2, const Float:y2, const Float:z2, const green=0) {
	new vecStart[3];
	new vecStop[3];
	
	vecStart[0] = floatround(x1);
	vecStart[1] = floatround(y1);
	vecStart[2] = floatround(z1);
	
	vecStop[0] = floatround(x2);
	vecStop[1] = floatround(y2);
	vecStop[2] = floatround(z2);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, g_EditorId);
	write_byte(TE_BEAMPOINTS);
	write_coord(vecStart[0]);
	write_coord(vecStart[1]);
	write_coord(vecStart[2]);
	write_coord(vecStop[0]);
	write_coord(vecStop[1]);
	write_coord(vecStop[2]);
	write_short(g_Sprite_Dot);
	write_byte(1);
	write_byte(1);
	write_byte(4);
	write_byte(5);
	write_byte(0);
	if(!green) {
		write_byte(255);
		write_byte(255);
		write_byte(255);
	} else {
		write_byte(0);
		write_byte(255);
		write_byte(0);
	}
	write_byte(200);
	write_byte(0);
	message_end();
}

damageTower(const monster, const ent) {
	new iMonster = ((entity_get_int(monster, EV_INT_sequence) == 76) ? ent : monster);
	
	if(entity_get_int(iMonster, MONSTER_TRACK) == 1) {
		return;
	}
	
	if(isBoomerMonster(monster)) {
		explodeBoomer(monster);
		return;
	}
	
	entity_set_vector(iMonster, EV_VEC_origin, g_VecMonsterTowerOrigin[entity_get_int(iMonster, EV_INT_team)]);
	
	entity_set_int(iMonster, MONSTER_TRACK, 1);
	
	entity_set_int(iMonster, EV_INT_sequence, 76);
	entity_set_float(iMonster, EV_FL_animtime, get_gametime());
	entity_set_int(iMonster, EV_INT_gamestate, 1);
	
	entity_set_vector(iMonster, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
	
	rh_emit_sound2(iMonster, 0, CHAN_BODY, __SOUND_ZOMBIE_KNIFE[random_num(0, charsmax(__SOUND_ZOMBIE_KNIFE))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	entity_set_int(iMonster, MONSTER_TARGET, 1337);
	
	new iDamage = 5;
	
	if(__DIFFS_VALUES[g_Diff][diffValueDamageTower]) {
		iDamage = (iDamage + ((iDamage * __DIFFS_VALUES[g_Diff][diffValueDamageTower]) / 100));
	}
	
	g_TowerHealth -= iDamage;
	
	set_task(1.0, "task__DamageTower", iMonster + TASK_DAMAGE_TOWER);
}

touchSomething(const classname[], const monster, const ent) {
	if(equal(classname, __ENT_CLASSNAME_WALKGUARD)) {
		zoneTouch(monster, ent);
	} else if(equal(classname, __ENT_CLASSNAME_SENTRY) || equal(classname, __ENT_CLASSNAME_SENTRY_BASE)) {
		new iEnt = entity_get_edict(ent, SENTRY_ENT_BASE);
		
		if(is_valid_ent(iEnt)) {
			remove_entity(iEnt);
		} else {
			iEnt = entity_get_edict(ent, BASE_ENT_SENTRY);
			
			if(is_valid_ent(iEnt)) {
				remove_entity(iEnt);
			}
		}
		
		if(is_valid_ent(ent)) {
			remove_entity(ent);
		}

		--g_SentryCountTotal;
		
		set_task(0.1, "task__BackToTrack", monster);
	}
}

Float:getFloatDistance(const Float:num1, const Float:num2) { 
	if(num1 > num2) {
		return (num1 - num2);
	} else if(num2 > num1) {
		return (num2 - num1);
	}
	
	return 0.0;
}

sendWeaponAnimation(const id, const animation) {
	set_entvar(id, var_weaponanim, animation);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
	write_byte(animation);
	write_byte(get_entvar(id, var_body));
	message_end();
}

checkVoteDiff(const id, const diff) {
	if(diff < g_BlockDiff) {
		return 0;
	}
	
	switch(diff) {
		case DIFF_NORMAL: {
			return 1;
		} case DIFF_NIGHTMARE: {
			return 1;
		} case DIFF_SUICIDAL: {
			if(g_Level[id] < 10) {
				return 0;
			}
		} case DIFF_HELL: {
			if(g_Level[id] < 25) {
				return 0;
			}
		}
	}
	
	return 1;
}

saveClassesProgress(const id, const acc_id, const class_id=-1) {
	new iLen = 0;
	new Handle:sqlQuery;

	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE `td4_pjs` SET ");

	if(class_id != -1) {
		switch(class_id) {
			case CLASS_SOLDADO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`soldado_level`='%d', `soldado_kills`='%d' ", g_ClassLevel[id][CLASS_SOLDADO], g_ClassReqs[id][CLASS_SOLDADO]);
			} case CLASS_INGENIERO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`ingeniero_level`='%d', `ingeniero_damage`='%d' ", g_ClassLevel[id][CLASS_INGENIERO], g_ClassReqs[id][CLASS_INGENIERO]);
			} case CLASS_SOPORTE: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`soporte_level`='%d', `soporte_damage`='%d' ", g_ClassLevel[id][CLASS_SOPORTE], g_ClassReqs[id][CLASS_SOPORTE]);
			} case CLASS_FRANCOTIRADOR: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`francotirador_level`='%d', `francotirador_damage`='%d' ", g_ClassLevel[id][CLASS_FRANCOTIRADOR], g_ClassReqs[id][CLASS_FRANCOTIRADOR]);
			} case CLASS_APOYO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`apoyo_level`='%d', `apoyo_damage`='%d' ", g_ClassLevel[id][CLASS_APOYO], g_ClassReqs[id][CLASS_APOYO]);
			} case CLASS_PESADO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`pesado_level`='%d', `pesado_damage`='%d' ", g_ClassLevel[id][CLASS_PESADO], g_ClassReqs[id][CLASS_PESADO]);
			} case CLASS_ASALTO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`asalto_level`='%d', `asalto_kills`='%d' ", g_ClassLevel[id][CLASS_ASALTO], g_ClassReqs[id][CLASS_ASALTO]);
			} case CLASS_COMANDANTE: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`comandante_level`='%d', `comandante_kills`='%d' ", g_ClassLevel[id][CLASS_COMANDANTE], g_ClassReqs[id][CLASS_COMANDANTE]);
			} case CLASS_PISTOLERO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`pistolero_level`='%d', `pistolero_req`='%d' ", g_ClassLevel[id][CLASS_PISTOLERO], g_ClassReqs[id][CLASS_PISTOLERO]);
			} case CLASS_PUBERO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`pubero_level`='%d', `pubero_damage`='%d' ", g_ClassLevel[id][CLASS_PUBERO], g_ClassReqs[id][CLASS_PUBERO]);
			} case CLASS_LEGIONARIO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`legionario_level`='%d', `legionario_damage`='%d' ", g_ClassLevel[id][CLASS_LEGIONARIO], g_ClassReqs[id][CLASS_LEGIONARIO]);
			} case CLASS_BITERO: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`bitero_level`='%d', `bitero_kills`='%d' ", g_ClassLevel[id][CLASS_BITERO], g_ClassReqs[id][CLASS_BITERO]);
			} case CLASS_SCOUTER: {
				iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`scouter_level`='%d', `scouter_damage`='%d' ", g_ClassLevel[id][CLASS_SCOUTER], g_ClassReqs[id][CLASS_SCOUTER]);
			}
		}
	} else {
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`soldado_level`='%d', `soldado_kills`='%d', `ingeniero_level`='%d', `ingeniero_damage`='%d', `soporte_level`='%d', `soporte_damage`='%d', `francotirador_level`='%d', `francotirador_damage`='%d', ", g_ClassLevel[id][CLASS_SOLDADO], g_ClassReqs[id][CLASS_SOLDADO], g_ClassLevel[id][CLASS_INGENIERO], g_ClassReqs[id][CLASS_INGENIERO], g_ClassLevel[id][CLASS_SOPORTE], g_ClassReqs[id][CLASS_SOPORTE], g_ClassLevel[id][CLASS_FRANCOTIRADOR], g_ClassReqs[id][CLASS_FRANCOTIRADOR]);
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`apoyo_level`='%d', `apoyo_damage`='%d', `pesado_level`='%d', `pesado_damage`='%d', `asalto_level`='%d', `asalto_kills`='%d', `comandante_level`='%d', `comandante_kills`='%d', ", g_ClassLevel[id][CLASS_APOYO], g_ClassReqs[id][CLASS_APOYO], g_ClassLevel[id][CLASS_PESADO], g_ClassReqs[id][CLASS_PESADO], g_ClassLevel[id][CLASS_ASALTO], g_ClassReqs[id][CLASS_ASALTO], g_ClassLevel[id][CLASS_COMANDANTE], g_ClassReqs[id][CLASS_COMANDANTE]);
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`pistolero_level`='%d', `pistolero_req`='%d', `pubero_level`='%d', `pubero_damage`='%d', `legionario_level`='%d', `legionario_damage`='%d', `bitero_level`='%d', `bitero_kills`='%d', ", g_ClassLevel[id][CLASS_PISTOLERO], g_ClassReqs[id][CLASS_PISTOLERO], g_ClassLevel[id][CLASS_PUBERO], g_ClassReqs[id][CLASS_PUBERO], g_ClassLevel[id][CLASS_LEGIONARIO], g_ClassReqs[id][CLASS_LEGIONARIO], g_ClassLevel[id][CLASS_BITERO], g_ClassReqs[id][CLASS_BITERO]);
		iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`scouter_level`='%d', `scouter_damage`='%d'", g_ClassLevel[id][CLASS_SCOUTER], g_ClassReqs[id][CLASS_SCOUTER]);
	}

	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE (`acc_id`='%d');", acc_id);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 7);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

savePlayerData(const id, const acc_id, const show_message=0) {
	saveClassesProgress(id, acc_id, -1); // Guarda el progreso de todas las clases.

	new iLen = 0;
	new Handle:sqlQuery;
	new i = 0;

	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE `td4_pjs` SET `tutorial`='%d', `gold`=(`gold`+'%d'), `class_id`='%d', `kills`='%d', `level`='%d', `points`='%d', `os`='%d', `os_lost`='%d', `mvp`=(`mvp`+'%d'), ", g_Tutorial[id], g_GoldG[id], g_ClassId[id], g_Kills[id], g_Level[id], g_Points[id], g_Os[id], g_OsLost[id], g_WinMVP[id]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`hab_wpn_damage`='%d', `hab_wpn_recoil`='%d', `hab_wpn_speed`='%d', `hab_wpn_clip`='%d', ", g_Hab[id][HAB_DAMAGE], g_Hab[id][HAB_PRECISION], g_Hab[id][HAB_SPEED_WEAPON], g_Hab[id][HAB_BULLETS]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`upgrade_critical`='%d', `upgrade_resistence`='%d', `upgrade_thor`='%d', `upgrade_apoyo`='%d', `upgrade_pesado`='%d', `upgrade_asalto`='%d', `upgrade_comandante`='%d', `upgrade_health`='%d', `upgrade_velocity`='%d', ", g_Upgrades[id][UPGRADE_CRITICAL], g_Upgrades[id][UPGRADE_RESISTENCE], g_Upgrades[id][UPGRADE_THOR], g_Upgrades[id][UPGRADE_UNLOCK_APOYO], g_Upgrades[id][UPGRADE_UNLOCK_PESADO], g_Upgrades[id][UPGRADE_UNLOCK_ASALTO], g_Upgrades[id][UPGRADE_UNLOCK_COMANDANTE], g_Upgrades[id][UPGRADE_HEALTH], g_Upgrades[id][UPGRADE_VELOCITY]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`uo_hud_color`=^"%d %d %d^", `uo_hud_position`=^"%f %f %f^", `uo_hud_effect`='%d', `uo_hud_progress_class`='%d', `uo_hud_kills_per_wave`='%d', ", g_UserOption_HudColor[id][__R], g_UserOption_HudColor[id][__G], g_UserOption_HudColor[id][__B], g_UserOption_HudPosition[id][0], g_UserOption_HudPosition[id][1], g_UserOption_HudPosition[id][2], g_UserOption_HudEffect[id], g_UserOption_HudProgressClass[id], g_UserOption_HudKillsPerWave[id]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`uo_lowfps_zombiemodels`='%d', `uo_lowfps_glow`='%d', `uo_lowfps_sentries`='%d', `uo_lowfps_zombiedead`='%d', `power_infis`='%d', `power_no_recoil`='%d', `time_played`='%d' ", g_UserOption_LowFpsModels[id], g_UserOption_LowFpsGlow[id], g_UserOption_LowFpsSentries[id], g_UserOption_LowFpsZombieDead[id], g_Power[id][POWER_BALAS_INFINITAS], g_Power[id][POWER_PRECISION_PERFECTA], g_TimePlayed[id][TIME_MIN]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE (`acc_id`='%d');", acc_id);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 8);
	} else {
		SQL_FreeHandle(sqlQuery);

		++i;
	}

	g_GoldG[id] = 0;
	g_WinMVP[id] = 0;

	iLen = 0;

	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "UPDATE `td4_wave_boss` SET ");
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`waves_normal`=^"%d %d %d %d %d %d %d %d %d %d %d^", ", g_WavesWins[id][DIFF_NORMAL][0], g_WavesWins[id][DIFF_NORMAL][1], g_WavesWins[id][DIFF_NORMAL][2], g_WavesWins[id][DIFF_NORMAL][3], g_WavesWins[id][DIFF_NORMAL][4], g_WavesWins[id][DIFF_NORMAL][5], g_WavesWins[id][DIFF_NORMAL][6], g_WavesWins[id][DIFF_NORMAL][7], g_WavesWins[id][DIFF_NORMAL][8], g_WavesWins[id][DIFF_NORMAL][9], g_WavesWins[id][DIFF_NORMAL][10]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`waves_nightmare`=^"%d %d %d %d %d %d %d %d %d %d %d^", ", g_WavesWins[id][DIFF_NIGHTMARE][0], g_WavesWins[id][DIFF_NIGHTMARE][1], g_WavesWins[id][DIFF_NIGHTMARE][2], g_WavesWins[id][DIFF_NIGHTMARE][3], g_WavesWins[id][DIFF_NIGHTMARE][4], g_WavesWins[id][DIFF_NIGHTMARE][5], g_WavesWins[id][DIFF_NIGHTMARE][6], g_WavesWins[id][DIFF_NIGHTMARE][7], g_WavesWins[id][DIFF_NIGHTMARE][8], g_WavesWins[id][DIFF_NIGHTMARE][9], g_WavesWins[id][DIFF_NIGHTMARE][10]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`waves_suicidal`=^"%d %d %d %d %d %d %d %d %d %d %d^", ", g_WavesWins[id][DIFF_SUICIDAL][0], g_WavesWins[id][DIFF_SUICIDAL][1], g_WavesWins[id][DIFF_SUICIDAL][2], g_WavesWins[id][DIFF_SUICIDAL][3], g_WavesWins[id][DIFF_SUICIDAL][4], g_WavesWins[id][DIFF_SUICIDAL][5], g_WavesWins[id][DIFF_SUICIDAL][6], g_WavesWins[id][DIFF_SUICIDAL][7], g_WavesWins[id][DIFF_SUICIDAL][8], g_WavesWins[id][DIFF_SUICIDAL][9], g_WavesWins[id][DIFF_SUICIDAL][10]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`waves_hell`=^"%d %d %d %d %d %d %d %d %d %d %d^", ", g_WavesWins[id][DIFF_HELL][0], g_WavesWins[id][DIFF_HELL][1], g_WavesWins[id][DIFF_HELL][2], g_WavesWins[id][DIFF_HELL][3], g_WavesWins[id][DIFF_HELL][4], g_WavesWins[id][DIFF_HELL][5], g_WavesWins[id][DIFF_HELL][6], g_WavesWins[id][DIFF_HELL][7], g_WavesWins[id][DIFF_HELL][8], g_WavesWins[id][DIFF_HELL][9], g_WavesWins[id][DIFF_HELL][10]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "`boss_normal`='%d', `boss_nightmare`='%d', `boss_suicidal`='%d', `boss_hell`='%d' ", g_BossKills[id][DIFF_NORMAL], g_BossKills[id][DIFF_NIGHTMARE], g_BossKills[id][DIFF_SUICIDAL], g_BossKills[id][DIFF_HELL]);
	iLen += formatex(g_SqlQuery[iLen], (charsmax(g_SqlQuery) - iLen), "WHERE (`acc_id`='%d');", acc_id);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, g_SqlQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 9);
	} else {
		SQL_FreeHandle(sqlQuery);

		++i;
	}

	if(!show_message && i == 2) {
		clientPrintColor(id, _, "TUS DATOS HAN SIDO GUARDADOS CORRECTAMENTE.");
	}
}

saveFavDiffs(const id) {
	new i;
	for(i = 0; i < structIdMaps; ++i) {
		if(g_AutoDiff[id][i] == __MAPS[i][mapBlockDiff]) {
			continue;
		}

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `td4_map_diffs` (`acc_id`, `map_id`, `map_name`, `diff_id`, `diff_name`) VALUES ('%d', '%d', ^"%s^", '%d', '%d') ON DUPLICATE KEY UPDATE `diff_id`='%d', `diff_name`='%d';", dg_get_user_acc_id(id), i, __MAPS[i][mapName], g_AutoDiff[id][i], (g_AutoDiff[id][i] + 1), g_AutoDiff[id][i], (g_AutoDiff[id][i] + 1));
		SQL_ThreadQuery(g_SqlTuple, "@sqlThread__IgnoreQuery", g_SqlQuery);
	}
}

checkDistanceFromEvas(const id) {
	new Float:vecOrigin[3];
	new i;

	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	for(i = 0; i < g_EntEvasNums; ++i) {
		if(get_distance_f(g_EntEvasOrigin[i], vecOrigin) <= 150.0) {
			return true;
		}
	}
	
	return false;
}

isMonster(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	new iMonsterType = entity_get_int(ent, MONSTER_TYPE);
	return ((iMonsterType == MONSTER_TYPE_NORMAL || iMonsterType == MONSTER_TYPE_EGG || iMonsterType == MONSTER_TYPE_SPECIAL_SPEED || iMonsterType == MONSTER_TYPE_SPECIAL_STRENGTH || iMonsterType == MONSTER_TYPE_BOOMER) ? 1 : 0);
}

isMonsterLowFps(const ent) {
	return entity_get_int(ent, MONSTER_LOW_FPS);
}

isEggMonster(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	return ((entity_get_int(ent, MONSTER_TYPE) == MONSTER_TYPE_EGG) ? 1 : 0);
}

isBoomerMonster(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	return ((entity_get_int(ent, MONSTER_TYPE) == MONSTER_TYPE_BOOMER) ? 1 : 0);
}

isBoss(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	new iMonsterType = entity_get_int(ent, MONSTER_TYPE);
	return ((iMonsterType == MONSTER_TYPE_BOSS) ? 1 : 0);
}

sendMonsters(const monster_type, monster_num, const monster_track) {
	if(g_MonstersAlive >= 30) {
		if(monster_num) {
			g_TempMonsterType = monster_type;
			g_TempMonsterNum = monster_num;
			g_TempMonsterTrack = monster_track;
			
			set_task(random_float(1.0, 2.0), "task__SendMonsters_Post");
		}
		
		return;
	}
	
	if(!g_WaveInProgress) {
		return;
	}

	new iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_MONSTER);

		new sModel[64];
		new iHealth;
		new Float:flVelocity;
		new Float:flNext;
		new iSpecial = 0;
		new iUniqueZombie = 0;
		
		--monster_num;
		
		if(!monster_num && g_SendMonsterSpecial) {
			iSpecial = 1;
		}

		switch(monster_type) {
			case MONSTER_TYPE_NORMAL: {
				switch(iSpecial) {
					case 1: {
						iHealth = (getTotalLevel() * random_num(200, 300)) + (g_Wave * __MAPS[g_MapId][mapGordoHealth]);

						copy(sModel, charsmax(sModel), __MODEL_ZOMBIE_BOOMER);

						entity_set_int(iEnt, MONSTER_UNIQUE, MONSTER_NORMAL);
					} default: {
						iHealth = (random_num(175, 250) * (clamp(g_Wave, 2, MAX_WAVES) / 2));

						if((monster_num % 15) == 0 && monster_num) {
							copy(sModel, charsmax(sModel), __MODELS_ZOMBIE_SPECIAL[0]);

							iHealth *= 3;
							iUniqueZombie = 1;

							entity_set_int(iEnt, MONSTER_UNIQUE, MONSTER_ALIEN);
						} else if((monster_num % 45) == 0 && monster_num) {
							copy(sModel, charsmax(sModel), __MODELS_ZOMBIE_SPECIAL[1]);

							iHealth *= 3;
							iUniqueZombie = 2;

							entity_set_int(iEnt, MONSTER_UNIQUE, MONSTER_TANK);
						} else {
							copy(sModel, charsmax(sModel), __MODELS_ZOMBIE_NORMAL[g_ZombieModels]);

							++g_ZombieModels;

							if(g_ZombieModels > charsmax(__MODELS_ZOMBIE_NORMAL)) {
								g_ZombieModels = 0;
							}

							entity_set_int(iEnt, MONSTER_UNIQUE, MONSTER_NORMAL);
						}
					}
				}

				if(!__MAPS[g_MapId][mapSpecial]) {
					flNext = random_float(0.4, 0.5);
				} else {
					flNext = random_float(0.2, 0.3);
				}
			} case MONSTER_TYPE_SPECIAL_SPEED: {
				copy(sModel, charsmax(sModel), __MODELS_ZOMBIE_SPEED[random_num(0, charsmax(__MODELS_ZOMBIE_SPEED))]);
				
				iHealth = (random_num(50, 75) * getUsersAlive());

				if(!__MAPS[g_MapId][mapSpecial]) {
					flNext = random_float(0.2, 0.4);
				} else {
					flNext = random_float(0.1, 0.2);
				}
			} case MONSTER_TYPE_SPECIAL_STRENGTH: {
				copy(sModel, charsmax(sModel), __MODELS_ZOMBIE_HARD[random_num(0, charsmax(__MODELS_ZOMBIE_HARD))]);

				iHealth = (random_num(750, 1125) * getUsersAlive());

				if(!__MAPS[g_MapId][mapSpecial]) {
					flNext = random_float(1.0, 2.0);
				} else {
					flNext = random_float(0.5, 1.0);
				}
			}
		}

		dllfunc(DLLFunc_Spawn, iEnt);

		if(monster_type == MONSTER_TYPE_SPECIAL_STRENGTH) {
			if(__DIFFS_VALUES[g_Diff][diffValueExtraWaveHeavy]) {
				iHealth = (iHealth + ((iHealth * 20) / 100));
			}
		} else {
			if(__DIFFS_VALUES[g_Diff][diffValueHealth]) {
				iHealth = (iHealth + ((iHealth * __DIFFS_VALUES[g_Diff][diffValueHealth]) / 100));
			}
		}
		
		if(iHealth > g_MonsterMaxHealth && !iSpecial && !iUniqueZombie) {
			iHealth = g_MonsterMaxHealth;
		}

		entity_set_model(iEnt, sModel);
		entity_set_float(iEnt, EV_FL_health, float(iHealth));
		entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_YES);
		entity_set_origin(iEnt, g_VecStartOrigin[monster_track]);
		entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);

		entity_set_int(iEnt, EV_INT_sequence, ((iSpecial != 1) ? 4 : 3));

		entity_set_float(iEnt, EV_FL_animtime, get_gametime());
		entity_set_float(iEnt, EV_FL_gravity, 1.0);
		
		entity_set_int(iEnt, EV_INT_team, monster_track);
		
		entity_set_int(iEnt, EV_INT_gamestate, 1);
		
		entity_set_int(iEnt, MONSTER_TARGET, 0);

		if(!iSpecial) {
			entity_set_int(iEnt, MONSTER_TYPE, monster_type);
			entity_set_int(iEnt, MONSTER_LOW_FPS, 1);
			
			flVelocity = getVelocity();

			if(monster_type == MONSTER_TYPE_SPECIAL_SPEED) {
				if(__DIFFS_VALUES[g_Diff][diffValueExtraWaveSpeed]) {
					flVelocity = (flVelocity + ((flVelocity * 20.0) / 100.0));
				}
			}
		} else {
			entity_set_int(iEnt, MONSTER_TYPE, MONSTER_TYPE_BOOMER);
			
			flVelocity = 50.0;
			
			g_BoomerHealth = iHealth;
		}

		if(g_MonstersShield < g_MonstersWithShield && !iUniqueZombie && !iSpecial) {
			new iRandom = random_num(1, 5);

			if(iRandom == 1) {
				++g_MonstersShield;
				
				entity_set_float(iEnt, MONSTER_SHIELD, 1.0);
				
				set_rendering(iEnt, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 4);
			}
		}

		if(iUniqueZombie == 1) {
			set_rendering(iEnt, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 4);
		} else if(iUniqueZombie == 2) {
			entity_set_float(iEnt, MONSTER_SHIELD, 3.0);

			set_rendering(iEnt, kRenderFxGlowShell, 255, 0, 255, kRenderNormal, 4);
		}
		
		if(!g_FixStart[monster_track]) {
			drop_to_floor(iEnt);
			
			entity_get_vector(iEnt, EV_VEC_origin, g_VecStartOrigin[monster_track]);
			g_VecStartOrigin[monster_track][2] += 30.0;
			entity_set_vector(iEnt, EV_VEC_origin, g_VecStartOrigin[monster_track]);
			
			g_FixStart[monster_track] = 1;
		}

		new Float:vecMins[3];
		new Float:vecMax[3];
		
		vecMins = Float:{-16.0, -16.0, -30.0};
		vecMax = Float:{16.0, 16.0, 36.0};
		
		entity_set_size(iEnt, vecMins, vecMax);
		
		entity_set_vector(iEnt, EV_VEC_mins, vecMins);
		entity_set_vector(iEnt, EV_VEC_maxs, vecMax);
		
		entity_set_float(iEnt, MONSTER_SPEED, flVelocity);
		
		if(!iSpecial) {
			entity_set_float(iEnt, EV_FL_framerate, (flVelocity / 250.0));
		} else {
			entity_set_float(iEnt, EV_FL_framerate, 1.5);
		}
		
		entity_set_int(iEnt, MONSTER_MAXHEALTH, iHealth);
		
		new Float:vecMonsterOrigin[3];
		entity_get_vector(iEnt, EV_VEC_origin, vecMonsterOrigin);

		++g_MonstersAlive;
		++g_Monsters_Spawn;

		new Float:vecTargetOrigin[3];
		new iTarget;

		if(!monster_track) {
			entity_set_int(iEnt, MONSTER_TRACK, 1);
			iTarget = find_ent_by_tname(-1, "track1");
		} else {
			entity_set_int(iEnt, MONSTER_TRACK, 100);
			iTarget = find_ent_by_tname(-1, "track100");
		}
		
		entity_get_vector(iTarget, EV_VEC_origin, vecTargetOrigin);
		
		entitySetAim(iEnt, vecMonsterOrigin, vecTargetOrigin, flVelocity);
		
		if(monster_num) {
			g_TempMonsterType = monster_type;
			g_TempMonsterNum = monster_num;
			
			if(__MAPS[g_MapId][mapSpecial]) {
				g_TempMonsterTrack = !monster_track;
			}
			
			set_task(flNext, "task__SendMonsters_Post");
		}
	}
}

removeMonster(const monster, const killer, const thunder=0) {
	if(!is_valid_ent(monster)) {
		return;
	}
	
	remove_task(monster + TASK_DAMAGE_TOWER);

	new iDeadSeq;
	new iUniqueZombie = entity_get_int(monster, MONSTER_UNIQUE);

	switch(random_num(1, 3)) {
		case 1: {
			iDeadSeq = lookup_sequence(monster, "death1");
		} case 2: {
			iDeadSeq = lookup_sequence(monster, "death2");
		} case 3: {
			iDeadSeq = lookup_sequence(monster, "death3");
		}
	}
	
	if(iDeadSeq == -1) {
		iDeadSeq = lookup_sequence(monster, "death");
	}

	--g_TotalMonsters;
	--g_MonstersAlive;
	++g_MonstersKills;

	if(isEggMonster(monster)) {
		++g_SpecialMonsters_Kills;
	} else {
		++g_Monsters_Kills;
	}
	
	if(isBoomerMonster(monster)) {
		g_BoomerHealth = 0;
		
		if(is_user_connected(killer)) {
			clientPrintColor(0, _, "!t%n!y ganó !g100 Oro!y por matar al !gGordo Bomba!y.", killer);

			g_Gold[killer] += 100;
			g_GoldG[killer] += 100;
			g_GoldMap[killer] += 100;

			++g_GordoBomba_Kills[killer];
			
			if(g_GordoBomba_Kills[killer] == 2) {
				++g_Power[killer][POWER_BALAS_INFINITAS];

				clientPrintColor(0, _, "!t%n!y ganó !gBalas Infinitas x1!y por matar dos !gGordo Bomba!y en el mismo mapa.", killer);
			}
		}
	}

	if(g_TotalMonsters == 666) {
		new i;
		for(i = 1; i <= MaxClients; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			if(dg_get_user_acc_status(i) < STATUS_LOGGED) {
				continue;
			}

			setAchievement(i, GENERAL_666);
		}
	}

	entity_set_int(monster, MONSTER_TYPE, 0);
	entity_set_int(monster, MONSTER_TRACK, 0);
	entity_set_int(monster, MONSTER_MAXHEALTH, 0);
	entity_set_float(monster, MONSTER_SPEED, 0.0);
	
	entity_set_edict(monster, MONSTER_HEALTHBAR, 0);
	
	entity_set_int(monster, EV_INT_solid, SOLID_NOT);
	entity_set_vector(monster, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
	
	entity_set_int(monster, EV_INT_sequence, iDeadSeq);
	entity_set_float(monster, EV_FL_animtime, get_gametime());
	entity_set_float(monster, EV_FL_framerate, 1.0);
	// entity_set_float(monster, EV_FL_frame, 3.0);
	
	rh_emit_sound2(monster, 0, CHAN_BODY, __SOUND_ZOMBIE_DIE[random_num(0, charsmax(__SOUND_ZOMBIE_DIE))], 1.0, ATTN_NORM, 0, PITCH_NORM);

	if(is_user_connected(killer)) {
		++g_Kills[killer];
		++g_KillsMap[killer];
		
		if(!g_Boss) {
			++g_KillsPerWave[killer][g_Wave];
			
			if(g_KillsPerWave[killer][g_Wave] > g_BestPlayerKills) {
				g_BestPlayerKills = g_KillsPerWave[killer][g_Wave];
				g_BestPlayerId = killer;
				g_MVP_More = 0;
				
				new i;
				for(i = 1; i <= MaxClients; ++i) {
					if(!is_user_connected(i)) {
						continue;
					}
					
					if(i == g_BestPlayerId) {
						continue;
					}
					
					if(g_KillsPerWave[i][g_Wave] == g_BestPlayerKills) {
						++g_MVP_More;
					}
				}
			}

			if(iUniqueZombie == MONSTER_ALIEN || iUniqueZombie == MONSTER_TANK) {
				addKillsToEveryone(1);
			}
		}
		
		if(!thunder) {
			checkKillerLevelUp(killer);
		}

		ExecuteHamB(Ham_AddPoints, killer, 1, true);

		checkAchievementKills(killer);
	}

	if(g_TotalMonsters < 1) {
		endWave();
	} else if(g_EggCache && !task_exists(TASK_ALLOW_ANOTHER_MONSTER)) {
		new iRandom = random_num(5, 6);
		
		if(g_MonstersKills >= iRandom) {
			createSpecialMonster(0, 0);
			g_MonstersKills -= iRandom;
		}
	} else if(g_TotalMonsters == 1 && g_BossPower[0] == BOSS_POWER_EGGS) {
		g_BossPower[0] = 0;
		g_BossTimePower[0] = (get_gametime() + 15.0);
		
		entity_set_int(g_Boss, EV_INT_rendermode, kRenderTransAlpha);
		entity_set_float(g_Boss, EV_FL_renderamt, 255.0);
		
		set_task(0.5, "task__BackToRide", g_Boss);
	} else if(g_TotalMonsters == 3 && (g_BossPower[0] == BOSS_POWER_EGGS || g_BossPower[1] == BOSS_POWER_EGGS)) {
		new i;
		for(i = 0; i < 2; ++i) {
			if(is_valid_ent(g_BossGuardians_Ids[i])) {
				g_BossPower[i] = 0;
				g_BossTimePower[i] = (get_gametime() + 15.0);
				
				entity_set_int(g_BossGuardians_Ids[i], EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(g_BossGuardians_Ids[i], EV_FL_renderamt, 255.0);
				
				set_task(0.5, "task__BackToRide", g_BossGuardians_Ids[i]);
			}
		}
	}
	
	clearDirectorHud();
	set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);

	if(entity_get_int(monster, MONSTER_TARGET) == 1337) {
		entity_set_int(monster, MONSTER_TARGET, 0);
		
		new iEnt = -1;
		new iMonstersInTower = 0;
		
		while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_MONSTER)) != 0) {
			if(entity_get_int(monster, MONSTER_TARGET) == 1337) {
				++iMonstersInTower;
			}
		}
		
		if(!iMonstersInTower) {
			ClearSyncHud(0, g_HudSync_DamageTower);
		}
	}

	if(g_Wave <= MAX_WAVES) {
		remove_task(TASK_BUGFIX);
		set_task(6.0, "task__CheckZombiesBugFix", TASK_BUGFIX);
	}

	if(killer == 15000) {
		return;
	}

	set_task(5.0, "task__DeleteMonsterEnt", monster);
}

explodeBoomer(const monster) {
	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short(UNIT_SECOND * 5);
	write_short(UNIT_SECOND * 5);
	write_short(SF_FADE_OUT);
	write_byte(0);
	write_byte(153);
	write_byte(0);
	write_byte(255);
	message_end();
	
	playSound(0, __SOUND_BOOMER_EXPLODE);
	
	removeMonster(monster, 15000);
	task__DeleteMonsterEnt(monster);
	
	new iDamage = (100 + (10 * getUsersAlive()));
	
	if(__DIFFS_VALUES[g_Diff][diffValueDamageTower]) {
		iDamage = (iDamage + ((iDamage * __DIFFS_VALUES[g_Diff][diffValueDamageTower]) / 100));
	}
	
	g_TowerHealth -= iDamage;
	g_Achievement_DefensaAbsoluta = 0;
	g_Achievement_FaltaDeDefensores += iDamage;

	if(g_TowerHealth < 0.0) {
		removeAllEnts(1);
		finishGame();
		
		return;
	}
	
	if(!g_TowerInRegen) {
		g_TowerInRegen = 1;

		if(__DIFFS_VALUES[g_Diff][diffValueTowerRegen]) {
			set_task(5.0, "task__RegenTower", TASK_REGEN_TOWER);
		}
	}
}

createSpecialMonster(const power_boss, const power_repeat) {
	if(!power_boss) {
		if(g_Tramposo) {
			return;
		}

		if(__MAPS[g_MapId][mapSpecial] == 2) { // Mapas que no contiene respawn de huevillos
			return;
		}
	}

	static iLastEgg;
	new iRepeat = 1;
	new iEnt;
	new Float:vecMins[3];
	new Float:vecMax[3];
	new Float:flVelocity;
	new Float:vecAngles[3];
	new Float:vecVelocity[3];
	new Float:vecOrigin[3];
	new i;
	
	if(__DIFFS_VALUES[g_Diff][diffValueEggExtra] && !power_boss) {
		iRepeat = 2;
	} else if(power_repeat) {
		entity_get_vector(power_boss, EV_VEC_angles, vecAngles);
		iRepeat = power_repeat;
	}
	
	for(i = 0; i < iRepeat; ++i) {
		iEnt = create_entity("info_target");
		
		if(is_valid_ent(iEnt)) {
			if(!power_boss) {
				if(iRepeat == 1) {
					if(!iLastEgg) {
						i = 1;
					}
				}

				entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_EGG_MONSTER);
				
				dllfunc(DLLFunc_Spawn, iEnt);
				
				entity_set_model(iEnt, __MODEL_EGG);
				entity_set_float(iEnt, EV_FL_health, 99999.0);
				entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_NO);
				
				entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
				entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
				
				entity_set_origin(iEnt, ((i == 0) ? g_VecSpecialOrigin : g_VecSpecialOrigin2));

				iLastEgg = i;
			} else {
				entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_EGG_MONSTER);
				
				dllfunc(DLLFunc_Spawn, iEnt);
				
				entity_set_model(iEnt, __MODEL_EGG);
				entity_set_float(iEnt, EV_FL_health, 99999.0);
				entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_NO);
				
				entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
				entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
				
				// set_task(0.2, "task__ChangeSolidState", iEnt);
				
				velocity_by_aim(power_boss, 2000, vecVelocity);
				getDropOrigin(power_boss, vecOrigin);
				
				entity_set_origin(iEnt, vecOrigin);
				entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);
				
				vecAngles[1] += 22.5;
				entity_set_vector(power_boss, EV_VEC_v_angle, vecAngles);
				entity_set_vector(power_boss, EV_VEC_angles, vecAngles);
			}
			
			entity_set_int(iEnt, EV_INT_sequence, 1);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_gravity, 1.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			entity_set_int(iEnt, MONSTER_MAXHEALTH, 99999);
			entity_set_int(iEnt, MONSTER_TYPE, 0);
			entity_set_int(iEnt, MONSTER_TARGET, 0);
			
			vecMins = Float:{-16.0, -16.0, -3.97};
			vecMax = Float:{16.0, 16.0, 9999.9};
			
			entity_set_size(iEnt, vecMins, vecMax);
			
			entity_set_vector(iEnt, EV_VEC_mins, vecMins);
			entity_set_vector(iEnt, EV_VEC_maxs, vecMax);
			
			flVelocity = getVelocity();
			
			if(__DIFFS_VALUES[g_Diff][diffValueExtraWaveSpeed]) {
				flVelocity = (flVelocity + ((flVelocity * 20.0) / 100.0));
			}
			
			entity_set_float(iEnt, MONSTER_SPEED, flVelocity);
			
			entity_set_float(iEnt, EV_FL_framerate, (flVelocity / 250.0));
			
			++g_MonstersAlive;
			++g_TotalMonsters;
			++g_SpecialMonsters_Spawn;
			
			clearDirectorHud();
			set_entvar(g_EntHud, var_nextthink, NEXTTHINK_HUD);
			
			if(!power_boss) {
				remove_task(TASK_ALLOW_ANOTHER_MONSTER);

				set_task(0.2, "task__AllowDropAnotherMonster", TASK_ALLOW_ANOTHER_MONSTER);
				set_task(2.9, "task__EntFly", iEnt);

				// if(g_Diff < DIFF_HELL) {
					// set_task(0.2, "task__AllowDropAnotherMonster", TASK_ALLOW_ANOTHER_MONSTER);
					// set_task(2.9, "task__EntFly", iEnt);
				// } else {
					// set_task(1.0, "task__AllowDropAnotherMonster", TASK_ALLOW_ANOTHER_MONSTER);
					// set_task(0.5, "task__EntFly", iEnt);
				// }
			} else {
				set_task(random_float(1.9, 4.9), "task__EntFlyInBoss", iEnt);
			}
		}
	}
}

createFireBall(const boss, const Float:vecOrigin[3]) {
	new iEnt;
	new iSprite;
	
	iEnt = create_entity("info_target");
	
	entity_set_origin(iEnt, vecOrigin);
	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_BOSS_FM_BALL);
	entity_set_model(iEnt, __MODEL_FIREBALL);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_NONE);
	
	entity_set_size(iEnt, Float:{-15.0, -15.0, -15.0}, Float:{15.0, 15.0, 15.0});
	
	entity_set_edict(iEnt, EV_ENT_owner, boss);
	
	entity_set_int(iEnt, EV_INT_light_level, 180);
	entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAdd);
	entity_set_float(iEnt, EV_FL_renderamt, 255.0);
	
	entity_set_int(iEnt, MONSTER_TARGET, entity_get_int(boss, MONSTER_TARGET));
	
	iSprite = create_entity("env_sprite");
	
	if(!is_valid_ent(iSprite)) {
		return 0;
	}
	
	entity_set_model(iSprite, __SPRITE_FLAME);
	
	entity_set_float(iSprite, EV_FL_scale, random_float(0.6, 0.8));
	entity_set_int(iSprite, EV_INT_spawnflags, SF_SPRITE_STARTON);
	entity_set_int(iSprite, EV_INT_solid, SOLID_NOT);
	entity_set_int(iSprite, EV_INT_movetype, MOVETYPE_FOLLOW);
	entity_set_edict(iSprite, EV_ENT_aiment, iEnt);
	entity_set_edict(iSprite, EV_ENT_owner, iEnt);
	entity_set_float(iSprite, EV_FL_framerate, 25.0);
	
	entity_set_int(iSprite, EV_INT_rendermode, kRenderTransAdd);
	entity_set_float(iSprite, EV_FL_renderamt, 255.0);
	entity_set_int(iSprite, EV_INT_light_level, 180);
	
	DispatchSpawn(iSprite);
	
	entity_set_edict(iEnt, EV_ENT_euser3, iSprite);
	return iEnt;
}

createFireBallUltimate(const boss, const Float:vecOrigin[3]) {
	new iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		entity_set_origin(iEnt, vecOrigin);
		
		new Float:vecAngles[3];
		entity_get_vector(boss, EV_VEC_angles, vecAngles);
		
		vecAngles[0] = -100.0;

		entity_set_vector(iEnt, EV_VEC_angles, vecAngles);

		vecAngles[0] = 100.0;

		entity_set_vector(iEnt, EV_VEC_v_angle, vecAngles);
		
		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_BOSS_FM_BALL);
		entity_set_model(iEnt, __MODEL_FIREBALL);
		
		entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
		
		entity_set_size(iEnt, Float:{-15.0, -15.0, -15.0}, Float:{15.0, 15.0, 15.0});
		
		entity_set_edict(iEnt, EV_ENT_owner, boss);
		
		new Float:vecVelocity[3];
		VelocityByAim(iEnt, random_num(400, 1600), vecVelocity);
		
		entity_set_int(iEnt, EV_INT_light_level, 180);
		entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAdd);
		entity_set_float(iEnt, EV_FL_renderamt, 255.0);
		
		entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);
	}
}

bombExplosion(const ent, Float:vecOrigin[3]) {
	if(!is_valid_ent(ent)) {
		return;
	}

	new i;
	new Float:vecOrigin2[3];
	new Float:flDistance;
	new Float:flHealth;
	new Float:flDamage = (random_float(5.0, 10.0) * (g_Diff + 1));
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_ArrowExplode);
	write_byte(10);
	write_byte(30);
	write_byte(4);
	message_end();
	
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i)) {
			entity_get_vector(i, EV_VEC_origin, vecOrigin2);
			flDistance = get_distance_f(vecOrigin, vecOrigin2);
			
			if(flDistance <= 350.0) {
				message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, i);
				write_short(UNIT_SECOND * 3);
				write_short(UNIT_SECOND * 2);
				write_short(UNIT_SECOND * 2);
				message_end();
				
				message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, i);
				write_short(UNIT_SECOND * 5);
				write_short(0);
				write_short(SF_FADE_OUT);
				write_byte(255);
				write_byte(0);
				write_byte(0);
				write_byte(155);
				message_end();

				flHealth = float(g_Health[i]);
				
				if((flHealth - flDamage) > 0.0) {
					vecOrigin[0] = random_float(-750.0, 750.0);
					vecOrigin[1] = random_float(-750.0, 750.0);
					vecOrigin[2] = random_float(200.0, 750.0);
					
					entity_set_vector(i, EV_VEC_velocity, vecOrigin);
					
					ExecuteHam(Ham_TakeDamage, i, 0, g_Boss, flDamage, DMG_BURN);
				} else {
					ExecuteHam(Ham_TakeDamage, i, 0, g_Boss, 9999.0, DMG_BURN);
				}
			}
		}
	}
}

specialMonsterSearchHuman(const ent) {
	new iVictim = 0;
	new i;
	
	if(!g_Boss) {
		new Float:vecEntOrigin[3];
		new Float:vecOrigin[3];
		new Float:fDiff;
		new Float:fRange;
		new Float:fMaxRange = 8192.0;
		
		entity_get_vector(ent, EV_VEC_origin, vecEntOrigin);
		
		for(i = 1; i <= MaxClients; ++i) {
			if(is_user_alive(i) && !g_InBlockZone[i]) {
				entity_get_vector(i, EV_VEC_origin, vecOrigin);
				
				fDiff = (vecEntOrigin[2] - vecOrigin[2]);
				
				if(fDiff < -64.0 || fDiff > 64.0) {
					continue;
				}
				
				fRange = entity_range(ent, i);
				
				if(fRange <= fMaxRange) {
					fMaxRange = fRange;
					iVictim = i;
				}
			}
		}
	} else {
		new iUsers[MAX_PLAYERS + 1];
		new iCount = -1;
		
		for(i = 1; i <= MaxClients; ++i) {
			if(is_user_alive(i)) {
				iUsers[++iCount] = i;
			}
		}
		
		iVictim = iUsers[random_num(0, iCount)];
	}
	
	return iVictim;
}

miniBossSearchRandomHuman(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}

	new i;
	new iUsers[MAX_PLAYERS + 1];
	new j = 0;
	new iRandomUser = 0;
	
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i)) {
			iUsers[j] = i;
			++j;
		}
	}
	
	iRandomUser = random_num(0, (j - 1));
	return iUsers[iRandomUser];
}

miniBossSearchHuman(const ent, const ignore_this=0) {
	new i;
	new Float:flRange;
	new Float:flMaxRange = 8192.0;
	new iVictim = 0;
	
	for(i = 1; i <= MaxClients; ++i) {
		if(is_user_alive(i)) {
			if(i == ignore_this) {
				continue;
			}

			flRange = entity_range(ent, i);
			
			if(flRange <= flMaxRange) {
				flMaxRange = flRange;
				iVictim = i;
			}
		}
	}
	
	return iVictim;
}

aimingAtSentry(const id) {
	new iTarget;
	new iBody;
	
	if(get_user_aiming(id, iTarget, iBody) == 0.0) {
		return 0;
	}
	
	if(iTarget) {
		if(isSentry(iTarget)) {
			return iTarget;
		}
		
		return 0;
	}

	return 0;
}

isSentry(const ent) {
	if(!is_valid_ent(ent)) {
		return false;
	}

	new sClassName[32];
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(equal(sClassName, __ENT_CLASSNAME_SENTRY)) {
		return true;
	}

	return false;
}

isSentryLowFps(const ent) {
	return entity_get_int(ent, SENTRY_LOW_FPS);
}

sentryBuild(const id) {
	if(!is_user_alive(id)) {
		return;
	}

	if(g_SentryCountTotal == __MAPS[g_MapId][mapLimitSentries]) {
		clientPrintColor(id, _, "Se ha alcanzado el límite de torretas (!g%d!y) en este mapa.", __MAPS[g_MapId][mapLimitSentries]);
		return;
	} else if(g_InBuilding[id]) {
		clientPrintColor(id, _, "No puedes crear una torreta mientras estás construyendo otra cosa.");
		return;
	} else if(!(entity_get_int(id, EV_INT_flags) & (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT))) { 
		clientPrintColor(id, _, "Tienes que estar en el suelo para construir una torreta.");
		return;
	} else if(entity_get_int(id, EV_INT_bInDuck)) {
		clientPrintColor(id, _, "No puedes agacharte mientras construyes una torreta.");
		return;
	}

	new Float:vecOrigin[3];
	new Float:vecNewOrigin[3];
	new Float:vecTraceDirection[3];
	new Float:vecTraceEnd[3];
	new Float:vecTraceResult[3];
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	velocity_by_aim(id, 64, vecTraceDirection);
	
	vecTraceEnd[0] = vecTraceDirection[0] + vecOrigin[0];
	vecTraceEnd[1] = vecTraceDirection[1] + vecOrigin[1];
	vecTraceEnd[2] = vecTraceDirection[2] + vecOrigin[2];
	
	trace_line(id, vecOrigin, vecTraceEnd, vecTraceResult);
	
	vecNewOrigin[0] = vecTraceResult[0];
	vecNewOrigin[1] = vecTraceResult[1];
	vecNewOrigin[2] = vecOrigin[2];

	if(createSentryBase(vecNewOrigin, id)) {
		--g_Sentry[id];
		++g_SentryCountTotal;
	} else {
		clientPrintColor(id, _, "No puedes construir una torreta acá.");
	}
}

moveSentry(const id, const sentry) {
	if(!is_user_alive(id)) {
		return;
	}

	if(g_InBuilding[id]) {
		clientPrintColor(id, _, "No puedes mover tu torreta mientras estás construyendo otra cosa.");
		
		showMenu__SentryInfoMove(id);
		return;
	} else if(!(entity_get_int(id, EV_INT_flags) & (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT))) { 
		clientPrintColor(id, _, "Tienes que estar en el suelo para mover tu torreta.");
		
		showMenu__SentryInfoMove(id);
		return;
	} else if(entity_get_int(id, EV_INT_bInDuck)) {
		clientPrintColor(id, _, "No puedes agacharte mientras mueves tu torreta.");
		
		showMenu__SentryInfoMove(id);
		return;
	}

	new Float:vecOrigin[3];
	new Float:vecNewOrigin[3];
	new Float:vecTraceDirection[3];
	new Float:vecTraceEnd[3];
	new Float:vecTraceResult[3];
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	velocity_by_aim(id, 64, vecTraceDirection);
	
	vecTraceEnd[0] = vecTraceDirection[0] + vecOrigin[0];
	vecTraceEnd[1] = vecTraceDirection[1] + vecOrigin[1];
	vecTraceEnd[2] = vecTraceDirection[2] + vecOrigin[2];
	
	trace_line(id, vecOrigin, vecTraceEnd, vecTraceResult);
	
	vecNewOrigin[0] = vecTraceResult[0];
	vecNewOrigin[1] = vecTraceResult[1];
	vecNewOrigin[2] = vecOrigin[2];

	if(!moveSentryBase(vecNewOrigin, id, sentry)) {
		clientPrintColor(id, _, "No puedes mover tu torreta acá.");
	}
}

createSentryBase(const Float:vecOrigin[3], const id) {
	if(point_contents(vecOrigin) != CONTENTS_EMPTY || traceCheckCollides(vecOrigin, 24.0) || !isHullVacant(vecOrigin)) {
		return false;
	}

	new Float:vecOriginDown[3];
	new Float:vecHitPoint[3];
	new Float:flDistanceFromGround;
	new Float:flDifference;

	vecOriginDown = vecOrigin;
	vecOriginDown[2] = -5000.0;

	trace_line(0, vecOrigin, vecOriginDown, vecHitPoint);

	flDistanceFromGround = vector_distance(vecOrigin, vecHitPoint);
	flDifference = (36.0 - flDistanceFromGround);

	if((flDifference < -20.0) || (flDifference > 20.0)) {
		return false;
	}

	new iEnt = create_entity("func_wall");

	if(!iEnt) {
		return false;
	}

	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	vecMins[0] = -16.0;
	vecMins[1] = -16.0;
	vecMins[2] = 0.0;
	
	vecMaxs[0] = 16.0;
	vecMaxs[1] = 16.0;
	vecMaxs[2] = 1000.0;

	DispatchSpawn(iEnt);

	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_SENTRY_BASE);
	entity_set_model(iEnt, __MODEL_SENTRY_BASE);

	entity_set_size(iEnt, vecMins, vecMaxs);
	entity_set_origin(iEnt, vecOrigin);

	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

	g_SentryOrigin[id] = vecOrigin;
	g_InBuilding[id] = 1;

	rh_emit_sound2(id, 0, CHAN_AUTO, __SOUND_SENTRY_BASE, 1.0, ATTN_NORM, 0, PITCH_NORM);

	new iArgs[2];

	iArgs[0] = iEnt;
	iArgs[1] = id;

	set_task(2.0, "task__CreateSentryHead", _, iArgs, sizeof(iArgs));
	return true;
}

moveSentryBase(const Float:vecOrigin[3], const id, const sentry) {
	if(point_contents(vecOrigin) != CONTENTS_EMPTY || traceCheckCollides(vecOrigin, 24.0)) {
		return false;
	}

	new Float:vecHitPoint[3];
	new Float:vecOriginDown[3];
	new Float:fDistanceFromGround;
	new Float:fDifference;
	
	vecOriginDown = vecOrigin;
	vecOriginDown[2] = -5000.0;
	
	trace_line(0, vecOrigin, vecOriginDown, vecHitPoint);
	
	fDistanceFromGround = vector_distance(vecOrigin, vecHitPoint);
	fDifference = (36.0 - fDistanceFromGround);
	
	if((fDifference < -20.0) || (fDifference > 20.0)) {
		return 0;
	}
	
	new iEnt = create_entity("func_wall");

	if(!iEnt) {
		return false;
	}
	
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	vecMins[0] = -16.0;
	vecMins[1] = -16.0;
	vecMins[2] = 0.0;
	
	vecMaxs[0] = 16.0;
	vecMaxs[1] = 16.0;
	vecMaxs[2] = 1000.0;

	DispatchSpawn(iEnt);
	
	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_SENTRY_BASE);
	entity_set_model(iEnt, __MODEL_SENTRY_BASE);

	entity_set_size(iEnt, vecMins, vecMaxs);
	entity_set_origin(iEnt, vecOrigin);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

	new iArgs[3];

	iArgs[0] = iEnt;
	iArgs[1] = id;
	iArgs[2] = sentry;
	
	g_SentryOrigin[id] = vecOrigin;
	g_InBuilding[id] = 1;
	
	rh_emit_sound2(id, 0, CHAN_AUTO, __SOUND_SENTRY_BASE, 1.0, ATTN_NORM, 0, PITCH_NORM);

	set_task(2.0, "task__MoveSentryHead", _, iArgs, sizeof(iArgs));
	return true;
}

sentryTurnToTarget(const ent, const Float:sentryOrigin[3], const target, Float:vecTargetOrigin[3]) {
	if(target) {
		entitySetAim(ent, sentryOrigin, vecTargetOrigin);
	}
}

sentryDamageToPlayer(const sentry, const target, const sentry_level) {
	new iMinDamage = (__SENTRIES_DAMAGE[sentry_level][sentryMinDamage] + ((__SENTRIES_DAMAGE[sentry_level][sentryMinDamage] * floatround(entity_get_float(sentry, SENTRY_EXTRA_DAMAGE))) / 100));
	new iMaxDamage = (__SENTRIES_DAMAGE[sentry_level][sentryMaxDamage] + ((__SENTRIES_DAMAGE[sentry_level][sentryMaxDamage] * floatround(entity_get_float(sentry, SENTRY_EXTRA_DAMAGE))) / 100));
	new iDamage = random_num(iMinDamage, iMaxDamage);
	new Float:flShield = entity_get_float(target, MONSTER_SHIELD);
	
	if(flShield == 1.0) {
		iDamage /= 2;
	} else if(flShield == 2.0) {
		iDamage *= 2;
	} else if(flShield == 3.0) {
		iDamage /= 3;
	}
	
	new iOwner = entity_get_int(sentry, SENTRY_OWNER);
	new Float:flNewHealth = (entity_get_float(target, EV_FL_health) - float(iDamage));
	
	if(is_user_connected(iOwner)) {
		if(!isBoomerMonster(target)) {
			if(g_ClassId[iOwner] == CLASS_INGENIERO) {
				g_ClassReqs[iOwner][CLASS_INGENIERO] += iDamage;
				
				g_SentryDamage[iOwner] += iDamage;
				
				while(g_SentryDamage[iOwner] >= SENTRY_DAMAGE_NEED) {
					++g_Gold[iOwner];
					++g_GoldG[iOwner];
					++g_GoldMap[iOwner];
					
					g_SentryDamage[iOwner] -= SENTRY_DAMAGE_NEED;
				}
			}
		} else {
			if(g_BoomerHealth) {
				g_BoomerHealth -= iDamage;
			}
		}
	}

	if(flNewHealth <= 0.0) {
		removeMonster(target, iOwner, 1);
	} else {
		entity_set_float(target, EV_FL_health, flNewHealth);
	}
}

removeAllEnts(const sentry) {
	if(g_FinishGame) {
		return;
	}

	new iEnt = -1;

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_MONSTER)) != 0) {
		entity_set_int(iEnt, MONSTER_TYPE, 0);
		entity_set_int(iEnt, MONSTER_TRACK, 0);
		entity_set_int(iEnt, MONSTER_MAXHEALTH, 0);
		entity_set_float(iEnt, MONSTER_SPEED, 0.0);
		entity_set_edict(iEnt, MONSTER_HEALTHBAR, 0);
		
		remove_entity(iEnt);
	}

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_SPECIAL_MONSTER)) != 0) {
		entity_set_int(iEnt, MONSTER_MAXHEALTH, 0);
		
		remove_entity(iEnt);
	}

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_EGG_MONSTER)) != 0) {
		remove_entity(iEnt);
	}

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_MINIBOSS)) != 0) {
		remove_entity(iEnt);
	}

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_BOSS)) != 0) {
		remove_entity(iEnt);
	}

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_BOSS_GK)) != 0) {
		remove_entity(iEnt);
	}

	if(sentry) {
		while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_SENTRY_BASE)) != 0) {
			remove_entity(iEnt);
		}

		while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_SENTRY)) != 0) {
			remove_entity(iEnt);
		}
	}

	if(g_FwdAddToFullPack_Status) {
		g_FwdAddToFullPack_Status = 0;
		unregister_forward(FM_AddToFullPack, g_FwdAddToFullPack, 1);
	}

	if(is_valid_ent(g_Boss_HealthBar)) {
		remove_entity(g_Boss_HealthBar);
	}
}

effectBlood(const Float:vecEnd[3]) {	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BLOODSPRITE);
	engfunc(EngFunc_WriteCoord, vecEnd[0]);
	engfunc(EngFunc_WriteCoord, vecEnd[1]);
	engfunc(EngFunc_WriteCoord, vecEnd[2]);
	write_short(g_Sprite_BloodSpray);
	write_short(g_Sprite_Blood);
	write_byte(229);
	write_byte(15);
	message_end();
}

effectTracer(const Float:vecStart[3], const Float:vecEnd[3]) {
	new iStart[3];
	new iEnd[3];

	FVecIVec(vecStart, iStart);
	FVecIVec(vecEnd, iEnd);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_TRACER);
	write_coord(iStart[0]);
	write_coord(iStart[1]);
	write_coord(iStart[2]);
	write_coord(iEnd[0]);
	write_coord(iEnd[1]);
	write_coord(iEnd[2]);
	message_end();
}

addKill(const id, const kills) {
	++g_Kills[id];
	++g_KillsMap[id];

	checkKillerLevelUp(id);

	ExecuteHamB(Ham_AddPoints, id, kills, true);

	checkAchievementKills(id);
}

checkAchievementKills(const id) {
	if(g_KillsMap[id] >= 500) {
		setAchievement(id, HAGO_LO_QUE_PUEDO);

		if(g_KillsMap[id] >= 1000) {
			setAchievement(id, YOU_SHALL_NOT_PASS);

			if(g_KillsMap[id] >= 2000) {
				setAchievement(id, CARNICERO);

				if(g_KillsMap[id] >= 3000) {
					setAchievement(id, EL_LIDER);
				}
			}
		}
	}
}

addKillsToEveryone(const kills) {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		addKill(i, kills);
	}
}

checkKillerLevelUp(const id) {
	switch(g_ClassId[id]) {
		case CLASS_SOLDADO, CLASS_ASALTO, CLASS_COMANDANTE, CLASS_BITERO: {
			if(g_CurrentWeapon[id] == __CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == __CLASSES_WEAPONS[g_ClassId[id]][1]) {
				new iClassReq = __CLASSES[g_ClassId[id]][classReqLv1 + g_ClassLevel[id][g_ClassId[id]]];

				if((get_user_flags(id) & ADMIN_RESERVATION)) {
					iClassReq = (iClassReq - ((iClassReq * 20) / 100));
				}

				++g_ClassReqs[id][g_ClassId[id]];

				if(g_ClassReqs[id][g_ClassId[id]] >= iClassReq) {
					++g_ClassLevel[id][g_ClassId[id]];

					clientPrintColor(0, id, "!t%n!y subió de nivel a su !t%s!y al nivel !g%d!y.", id, __CLASSES[g_ClassId[id]][className], g_ClassLevel[id][g_ClassId[id]]);
				}

				saveClassesProgress(id, dg_get_user_acc_id(id), g_ClassId[id]);
			}
		}
	}
}

checkAttackerLevelUp(const attacker, const damage) {
	switch(g_ClassId[attacker]) {
		case CLASS_SOPORTE, CLASS_FRANCOTIRADOR, CLASS_APOYO, CLASS_PESADO, CLASS_PUBERO, CLASS_LEGIONARIO, CLASS_SCOUTER: {
			if(g_CurrentWeapon[attacker] == __CLASSES_WEAPONS[g_ClassId[attacker]][0] || g_CurrentWeapon[attacker] == __CLASSES_WEAPONS[g_ClassId[attacker]][1]) {
				new iClassReq = __CLASSES[g_ClassId[attacker]][classReqLv1 + g_ClassLevel[attacker][g_ClassId[attacker]]];

				if((get_user_flags(attacker) & ADMIN_RESERVATION)) {
					iClassReq = (iClassReq - ((iClassReq * 20) / 100));
				}

				g_ClassReqs[attacker][g_ClassId[attacker]] += damage;
				
				if(g_ClassReqs[attacker][g_ClassId[attacker]] >= iClassReq) {
					++g_ClassLevel[attacker][g_ClassId[attacker]];
					
					clientPrintColor(0, attacker, "!t%n!y subió de nivel a su !t%s!y al nivel !g%d!y.", attacker, __CLASSES[g_ClassId[attacker]][className], g_ClassLevel[attacker][g_ClassId[attacker]]);
				}

				saveClassesProgress(attacker, dg_get_user_acc_id(attacker), g_ClassId[attacker]);
				return;
			}
		} case CLASS_PISTOLERO: {
			if(g_CurrentWeapon[attacker] == WEAPON_DEAGLE) {
				new iClassReq = __CLASSES[g_ClassId[attacker]][classReqLv1 + g_ClassLevel[attacker][g_ClassId[attacker]]];

				if((get_user_flags(attacker) & ADMIN_RESERVATION)) {
					iClassReq = (iClassReq - ((iClassReq * 20) / 100));
				}

				g_ClassReqs[attacker][g_ClassId[attacker]]++;
				
				if(g_ClassReqs[attacker][g_ClassId[attacker]] >= iClassReq) {
					++g_ClassLevel[attacker][g_ClassId[attacker]];
					
					clientPrintColor(0, attacker, "!t%n!y subió de nivel a su !t%s!y al nivel !g%d!y.", attacker, __CLASSES[g_ClassId[attacker]][className], g_ClassLevel[attacker][g_ClassId[attacker]]);
				}

				saveClassesProgress(attacker, dg_get_user_acc_id(attacker), g_ClassId[attacker]);
				return;
			}
		}
	}

	if(g_CurrentWeapon[attacker] == WEAPON_DEAGLE) {
		++g_AchievementTrackPistolero[attacker];

		if(g_AchievementTrackPistolero[attacker] == 186) {
			setAchievement(attacker, PISTOLERO_UNLOCKED);
		}
	}
}

checkAchievementTotal(const id, const achievement_class) {
	new iCount = 0;
	new i;

	for(i = 0; i < structIdAchievements; ++i) {
		if(achievement_class == __ACHIEVEMENTS[i][achievementClass] && g_Achievement[id][i]) {
			++iCount;
		}
	}

	return iCount;
}

setAchievement(const id, const achievement, const achievement_fake=0) {
	if(dg_get_user_acc_status(id) < STATUS_LOGGED) {
		return;
	}

	if(g_Achievement[id][achievement]) {
		return;
	}

	if(!achievement_fake) {
		new iMinPlaying = getUsersPlaying(TEAM_CT);
		new iMinAlive = getUsersAlive();

		if(__ACHIEVEMENTS[achievement][achievementUsersNeedP] && iMinPlaying < __ACHIEVEMENTS[achievement][achievementUsersNeedP]) {
			return;
		} else if(__ACHIEVEMENTS[achievement][achievementUsersNeedA] && iMinAlive < __ACHIEVEMENTS[achievement][achievementUsersNeedA]) {
			return;
		}
	}

	new iSysTime = get_arg_systime();
	
	g_Achievement[id][achievement] = 1;
	g_AchievementUnlocked[id][achievement] = iSysTime;
	++g_AchievementTotal[id];
	
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `td4_achievements` (`acc_id`, `achievement_id`, `achievement_timestamp`) VALUES ('%d', '%d', '%d');", dg_get_user_acc_id(id), achievement, iSysTime);
	SQL_ThreadQuery(g_SqlTuple, "@sqlThread__IgnoreQuery", g_SqlQuery);

	switch(__ACHIEVEMENTS[achievement][achievementReward]) {
		case 1337: {
			clientPrintColor(0, _, "!t%n!y ganó el logro !g%s!y !t(Balas Infinitas desbloqueadas)!y.", id, __ACHIEVEMENTS[achievement][achievementName]);
		} case 1338: {
			clientPrintColor(0, _, "!t%n!y ganó el logro !g%s!y !t(Aimbot desbloqueado)!y.", id, __ACHIEVEMENTS[achievement][achievementName]);
		} case 1339: {
			clientPrintColor(0, _, "!t%n!y ganó el logro !g%s!y !t(Pistolero desbloqueado)!y.", id, __ACHIEVEMENTS[achievement][achievementName]);
		} default: {
			clientPrintColor(0, _, "!t%n!y ganó el logro !g%s!y !t(%d Os)!y.", id, __ACHIEVEMENTS[achievement][achievementName], __ACHIEVEMENTS[achievement][achievementReward]);
			g_Os[id] += __ACHIEVEMENTS[achievement][achievementReward];
		}
	}

	if(g_Tramposo) {
		if(__ACHIEVEMENTS[achievement][achievementClass] == ACHIEVEMENT_CLASS_MAPS || __ACHIEVEMENTS[achievement][achievementClass] == ACHIEVEMENT_CLASS_BOSSES || (achievement >= DEFENSA_ABSOLUTA_NOOB && achievement <= DEFENSA_ABSOLUTA_PRO)) {
			setAchievement(id, TRAMPOSO);
			return;
		}
	}

	if(achievement >= BOSS_GUARDIANES_NOOB && achievement <= BOSS_GUARDIANES_PRO) {
		if(achievement >= BOSS_GUARDIANES_AVANZADO) {
			setAchievement(id, AIMBOT);
		}

		return;
	}

	savePlayerData(id, dg_get_user_acc_id(id), 1);
}

shotgunReload(const weapon_ent, const weapon_id, const max_clip, const clip, const bpammo, const id) {
	if(bpammo <= 0 || clip == max_clip) {
		return;
	}

	new Float:flNextPrimaryAttack = get_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS);

	if(flNextPrimaryAttack > 0.0) {
		return;
	}

	new iInSpecialReload = get_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS);

	switch(iInSpecialReload) {
		case 0: {
			sendWeaponAnimation(id, 5);
			
			set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
			set_pdata_float(id, OFFSET_NEXT_ATTACK, 0.55, OFFSET_LINUX);
			set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 0.55, OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);
		} case 1: {
			new Float:flTimeWeaponIdle = get_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS);

			if(flTimeWeaponIdle > 0.0) {
				return;
			}
			
			sendWeaponAnimation(id, 3);

			if(random_num(0, 1)) {
				rh_emit_sound2(id, 0, CHAN_ITEM, "weapons/reload1.wav", 1.0, ATTN_NORM, 0, (85 + random_num(0, 0x1f)));
			} else {
				rh_emit_sound2(id, 0, CHAN_ITEM, "weapons/reload3.wav", 1.0, ATTN_NORM, 0, (85 + random_num(0, 0x1f)));
			}
			
			set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 2, OFFSET_LINUX_WEAPONS);

			if(weapon_id == CSW_XM1014) {
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 0.3, OFFSET_LINUX_WEAPONS);
			} else {
				set_pdata_float(weapon_ent, OFFSET_TIME_WEAPON_IDLE, 0.45, OFFSET_LINUX_WEAPONS);
			}
		} default: {
			set_pdata_int(weapon_ent, OFFSET_CLIPAMMO, (clip + 1), OFFSET_LINUX_WEAPONS);
			set_pdata_int(id, OFFSET_M3_AMMO, (bpammo - 1), OFFSET_LINUX);
			set_pdata_int(weapon_ent, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
		}
	}
}

reloadWeapons(const id) {
	new i;
	new WeaponIdType:iWeaponId = WEAPON_NONE;
	new iWeapons = 0;
	new iWeaponEnt = -1;
	new iExtraClip = 0;
	new iNoLoad = 0;
	new iLoad = 0;
	
	for(i = 0; i < sizeof(__WEAPON_NAMES); ++i) {
		iWeaponId = __WEAPON_NAMES[i][weaponId];

		if(user_has_weapon(id, _:iWeaponId)) {
			if(iWeaponId == WEAPON_DEAGLE && g_ClassId[id] != CLASS_PISTOLERO) {
				continue;
			}

			iWeapons = 1;
			iWeaponEnt = find_ent_by_owner(-1, __WEAPON_NAMES[i][weaponEnt], id);
			iExtraClip = __DEFAULT_MAXCLIP[_:iWeaponId];
			
			if(g_HabCacheClip[id]) {
				iExtraClip = (iExtraClip + ((iExtraClip * g_HabCacheClip[id]) / 100));
			}

			if(iWeaponId == __CLASSES_WEAPONS[g_ClassId[id]][0] || iWeaponId == __CLASSES_WEAPONS[g_ClassId[id]][1]) {
				iExtraClip += __CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttribClip];
			}

			if((cs_get_weapon_ammo(iWeaponEnt) == iExtraClip)) {
				if(cs_get_user_bpammo(id, _:iWeaponId) >= 200) {
					iNoLoad = 1;
					continue;
				}
			}

			cs_set_weapon_ammo(iWeaponEnt, iExtraClip);
			cs_set_user_bpammo(id, _:iWeaponId, 200);

			iLoad = 1;
		}
	}

	if(!iWeapons) {
		clientPrintColor(id, _, "No tenés armas para recargar.");
		return;
	}

	if(iLoad) {
		clientPrintColor(id, _, "Tus armas han sido recargadas.");

		g_Gold[id] -= 10;
		g_NoReload[id] = (get_gametime() + 30.0);
	} else if(iNoLoad) {
		clientPrintColor(id, _, "Tus armas están llenas.");
	}
}

effectGrenade(const ent, const red, const green, const blue, const life=10, const width=2, const nade_type) {
	new Float:vecColor[3];

	vecColor[0] = float(red);
	vecColor[1] = float(green);
	vecColor[2] = float(blue);
	
	set_entvar(ent, var_renderfx, kRenderFxGlowShell);
	set_entvar(ent, var_rendercolor, vecColor);
	set_entvar(ent, var_rendermode, kRenderNormal);
	set_entvar(ent, var_renderamt, 4);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent);
	write_short(g_Sprite_Trail);
	write_byte(life);
	write_byte(width);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(200);
	message_end();
	
	set_entvar(ent, var_flTimeStepSound, nade_type);
	set_entvar(ent, var_dmgtime, (get_gametime() + 9999.9));
}

createExplosion(const Float:vecOrigin[3], const red, const green, const blue, const radius=80) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_byte(radius);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(30);
	write_byte(200);
	message_end();
}

@sqlThread__IgnoreQuery(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_LOG_FILE, "sqlThread__IgnoreQuery() - [%d] - <%s>", error_num, error);
	}
}

@FM_AddToFullPackBoss_Post(const es_handle, const e, const ent, const host, const hostflags, const player, const set) {
	if(player || !is_user_connected(host) || ent != g_Boss_HealthBar) {
		return FMRES_IGNORED;
	}
	
	if(is_valid_ent(g_Boss_HealthBar) && is_valid_ent(g_Boss)) {
		static Float:vecOrigin[3];
		entity_get_vector(g_Boss, EV_VEC_origin, vecOrigin);
		
		switch(g_BossId) {
			case BOSS_GORILA, BOSS_GUARDIANES: {
				vecOrigin[2] += 65.0;
			} case BOSS_FIRE, BOSS_FALLEN_TITAN: {
				vecOrigin[2] += 150.0;
			}
		}
		
		set_es(es_handle, ES_Origin, vecOrigin);
	}
	
	return FMRES_IGNORED;
}

@FM_AddToFullPackBossGuardians_Post(const es_handle, const e, const ent, const host, const hostflags, const player, const set) {
	if(player || !is_user_connected(host)) {
		return FMRES_IGNORED;
	}
	
	if(g_BossGuardians_HealthBar[0] == ent && is_valid_ent(g_BossGuardians_Ids[0])) {
		static Float:vecOrigin[3];
		entity_get_vector(g_BossGuardians_Ids[0], EV_VEC_origin, vecOrigin);
		
		vecOrigin[2] += 65.0;
		
		set_es(es_handle, ES_Origin, vecOrigin);
	} else if(g_BossGuardians_HealthBar[1] == ent && is_valid_ent(g_BossGuardians_Ids[1])) {
		static Float:vecOrigin[3];
		entity_get_vector(g_BossGuardians_Ids[1], EV_VEC_origin, vecOrigin);
		
		vecOrigin[2] += 65.0;
		
		set_es(es_handle, ES_Origin, vecOrigin);
	}
	
	return FMRES_IGNORED;
}

isRobot(const ent) {
	if(!is_valid_ent(ent)) {
		return false;
	}

	new sClassName[32];
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(equal(sClassName, __ENT_CLASSNAME_ROBOT)) {
		return true;
	}

	return false;
}

aimingAtRobot(const id) {
	new iTarget;
	new iBody;
	
	if(get_user_aiming(id, iTarget, iBody) == 0.0) {
		return 0;
	}
	
	if(iTarget) {
		if(isRobot(iTarget)) {
			return iTarget;
		}
		
		return 0;
	}

	return 0;
}

robotBuild(const id) {
	if(!is_user_alive(id)) {
		return;
	}

	if(g_RobotCountTotal == __MAPS[g_MapId][mapLimitRobots]) {
		clientPrintColor(id, _, "Se ha alcanzado el límite de robots (!g%d!y) en este mapa.", __MAPS[g_MapId][mapLimitRobots]);
		return;
	} else if(g_InBuilding[id]) {
		clientPrintColor(id, _, "No podés crear un robot mientras estás construyendo otra cosa.");
		return;
	} else if(!(entity_get_int(id, EV_INT_flags) & (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT))) { 
		clientPrintColor(id, _, "Tenés que estar en el suelo para construir un robot.");
		return;
	} else if(entity_get_int(id, EV_INT_bInDuck)) {
		clientPrintColor(id, _, "No podés agacharte mientras construyes un robot.");
		return;
	}
	
	new Float:vecOrigin[3];
	new Float:vecNewOrigin[3];
	new Float:vecTraceDirection[3];
	new Float:vecTraceEnd[3];
	new Float:vecTraceResult[3];
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	velocity_by_aim(id, 64, vecTraceDirection);
	
	vecTraceEnd[0] = (vecTraceDirection[0] + vecOrigin[0]);
	vecTraceEnd[1] = (vecTraceDirection[1] + vecOrigin[1]);
	vecTraceEnd[2] = (vecTraceDirection[2] + vecOrigin[2]);
	
	trace_line(id, vecOrigin, vecTraceEnd, vecTraceResult);
	
	vecNewOrigin[0] = vecTraceResult[0];
	vecNewOrigin[1] = vecTraceResult[1];
	vecNewOrigin[2] = vecOrigin[2];

	if(createRobot(vecNewOrigin, id)) {
		--g_Robot[id];
		++g_RobotCountTotal;
	} else {
		clientPrintColor(id, _, "No puedes construir un robot acá.");
	}
}

public createRobot(const Float:vecOrigin[3], const id) {
	if(point_contents(vecOrigin) != CONTENTS_EMPTY || traceCheckCollides(vecOrigin, 24.0)) {
		return false;
	}
	
	new Float:vecOriginDown[3];
	new Float:vecHitPoint[3];
	new Float:fDistanceFromGround;
	new Float:fDifference;
	
	vecOriginDown = vecOrigin;
	vecOriginDown[2] = -5000.0;
	
	trace_line(0, vecOrigin, vecOriginDown, vecHitPoint);
	
	fDistanceFromGround = vector_distance(vecOrigin, vecHitPoint);
	fDifference = (36.0 - fDistanceFromGround);
	
	if((fDifference < -20.0) || (fDifference > 20.0)) {
		return false;
	}
	
	new iEnt = create_entity("func_wall");
	
	if(!iEnt) {
		return false;
	}
	
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	vecMins[0] = -24.0;
	vecMins[1] = -24.0;
	vecMins[2] = 0.0;
	
	vecMaxs[0] = 24.0;
	vecMaxs[1] = 24.0;
	vecMaxs[2] = 56.0;

	DispatchSpawn(iEnt);
	
	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_ROBOT);
	entity_set_model(iEnt, __MODELS_ROBOT[0]);

	entity_set_size(iEnt, vecMins, vecMaxs);
	entity_set_origin(iEnt, vecOrigin);

	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

	setRobotAnimation(iEnt, ROBOT_APPEAR);

	entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 1.866667));

	g_RobotEnt = iEnt;
	return true;
}

@think__Robot(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}

	if(entity_get_int(ent, ROBOT_INT_HEALTH) < 0) {
		setRobotAnimation(ent, ROBOT_DEATH);
		return;
	}

	static Float:vecRobotOrigin[3];
	static iTarget;
	static iRobotCompleted;
	static Float:fMaxDistance;
	static Float:fDistance;
	
	entity_get_vector(ent, EV_VEC_origin, vecRobotOrigin);
	vecRobotOrigin[2] += 24.0;

	iTarget = entity_get_edict(ent, ROBOT_ENT_TARGET);
	iRobotCompleted = entity_get_int(ent, ROBOT_INT_COMPLETED);
	fMaxDistance = (800.0 + ((float(iRobotCompleted) * 300.0) / 100.0));
	
	if(entity_get_int(ent, ROBOT_INT_FIRE) == 1 && isMonster(iTarget)) {
		static Float:vecTargetOrigin[3];
		entity_get_vector(iTarget, EV_VEC_origin, vecTargetOrigin);
		
		fDistance = vector_distance(vecRobotOrigin, vecTargetOrigin);
		
		if(fDistance <= fMaxDistance) {
			entitySetAim(ent, vecRobotOrigin, vecTargetOrigin);
			
			rh_emit_sound2(ent, 0, CHAN_WEAPON, __SOUND_SENTRY_FIRE, 0.35, ATTN_NORM, 0, PITCH_NORM);

			static iExtraDamage;
			static iMinDamage;
			static iMaxDamage;
			static iDamage;
			static Float:fShield;
			static Float:fNewHealth;

			iExtraDamage = ((iRobotCompleted * 75) / 100);
			iMinDamage = (50 + iExtraDamage);
			iMaxDamage = (75 + iExtraDamage);
			iDamage = random_num(iMinDamage, iMaxDamage);
			fShield = entity_get_float(iTarget, MONSTER_SHIELD);
			
			if(fShield == 1.0) {
				iDamage /= 2;
			} else if(fShield == 2.0) {
				iDamage *= 2;
			} else if(fShield == 3.0) {
				iDamage /= 3;
			}
			
			fNewHealth = (entity_get_float(iTarget, EV_FL_health) - float(iDamage));
			
			if(!isBoomerMonster(iTarget)) {
				g_RobotDamage += iDamage;
				
				if(g_RobotDamage >= 300) {
					new i;
					for(i = 1; i <= MaxClients; ++i) {
						if(!is_user_alive(i)) {
							continue;
						}

						++g_Gold[i];
						++g_GoldG[i];
						++g_GoldMap[i];
					}
					
					g_RobotDamage -= 300;
				}
			} else {
				if(g_BoomerHealth) {
					g_BoomerHealth -= iDamage;
				}
			}

			if(fNewHealth <= 0.0) {
				removeMonster(iTarget, 1337);
			} else {
				entity_set_float(iTarget, EV_FL_health, fNewHealth);
			}
			
			vecTargetOrigin[2] += random_num(-16, 16);
			effectTracer(vecRobotOrigin, vecTargetOrigin);
			
			entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
			return;
		} else {
			entity_set_int(ent, ROBOT_INT_FIRE, 0);
			setRobotAnimation(ent, ROBOT_IDLE);
		}
	}
	
	static iVictim;
	static iClosest;
	static Float:vecOrigin[3];
	static Float:vecClosestOrigin[3];
	static Float:fClosestDistance;

	iVictim = -1;
	iClosest = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecRobotOrigin, fMaxDistance)) != 0) {
		if(!isMonster(iVictim)) {
			continue;
		}
		
		entity_get_vector(iVictim, EV_VEC_origin, vecOrigin);
		vecOrigin[2] += 10.0;

		fDistance = vector_distance(vecRobotOrigin, vecOrigin);
		vecClosestOrigin = vecOrigin;
		
		if(fDistance < fClosestDistance || iClosest == 0) {
			iClosest = iVictim;
			fClosestDistance = fDistance;
		}
	}
	
	if(iClosest) {
		entitySetAim(ent, vecRobotOrigin, vecClosestOrigin);
		
		entity_set_int(ent, ROBOT_INT_FIRE, 1);
		entity_set_edict(ent, ROBOT_ENT_TARGET, iClosest);

		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.1));
		return;
	} else {
		if(entity_get_int(ent, ROBOT_INT_FIRE) == 1) {
			entity_set_int(ent, ROBOT_INT_FIRE, 0);
			setRobotAnimation(ent, ROBOT_IDLE);
		}
	}
	
	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 0.25));
}

setRobotAnimation(const ent, const animation) {
	entity_set_int(ent, EV_INT_sequence, animation);
	entity_set_float(ent, EV_FL_animtime, get_gametime());
	entity_set_float(ent, EV_FL_framerate, 1.0);
}

robotFireMissiles() {
	if(!is_valid_ent(g_RobotEnt)) {
		return;
	}

	new Float:vecRobotOrigin[3];
	new iVictim = -1;
	new iZombies[16];
	new iMissiles = 0;
	new i;
	new Float:vecVelocity[3];
	new iEnt;

	entity_get_vector(g_RobotEnt, EV_VEC_origin, vecRobotOrigin);

	while((iVictim = find_ent_in_sphere(iVictim, vecRobotOrigin, 9999.9)) != 0) {
		if(!isMonster(iVictim)) {
			continue;
		}

		if(isBoomerMonster(iVictim)) {
			continue;
		}

		iZombies[iMissiles] = iVictim;
		++iMissiles;

		if(iMissiles == 16) {
			break;
		}
	}
	
	iMissiles /= 2;
	
	for(i = 0; i < iMissiles; ++i) {
		iEnt = create_entity("info_target");
		
		if(!iEnt) {
			continue;
		}

		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_ROBOT_MISSILES);
		entity_set_model(iEnt, __MODEL_TANK_ROCK_GIBS);
		
		entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
		entity_set_float(iEnt, EV_FL_renderamt, 0.0);
		
		vecRobotOrigin[2] += 16.0;
		entity_set_origin(iEnt, vecRobotOrigin);

		entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);

		rh_emit_sound2(iEnt, 0, CHAN_WEAPON, __SOUND_ROBOT_MISSILE_FIRED, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		vecVelocity = Float:{0.0, 0.0, 64.0};
		entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);
		
		entity_set_edict(iEnt, EV_ENT_euser1, iZombies[i]);
		entity_set_edict(iEnt, EV_ENT_euser3, createFlare(iEnt));
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(iEnt);
		write_short(g_Sprite_Trail);
		write_byte(30);
		write_byte(2);
		write_byte(255);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();

		set_task(1.0, "task__RocketFollowVictim", iEnt);
	}
}

createFlare(const missile) {
	new iEnt = create_entity("env_sprite");
	
	if(!is_valid_ent(iEnt)) {
		return 0;
	}
	
	entity_set_model(iEnt, __SPRITE_ANIM_GLOW);
	
	entity_set_float(iEnt, EV_FL_scale, random_float(0.2, 0.4));

	entity_set_int(iEnt, EV_INT_spawnflags, SF_SPRITE_STARTON);
	entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW);

	entity_set_edict(iEnt, EV_ENT_aiment, missile);
	entity_set_float(iEnt, EV_FL_framerate, 25.0);
	
	set_rendering(iEnt, kRenderFxNone, 255, 0, 0, kRenderTransAdd, 255);
	
	DispatchSpawn(iEnt);
	return iEnt;
}

public task__RocketFollowVictim(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}

	new iVictim = entity_get_edict(ent, EV_ENT_euser1);

	if(is_valid_ent(iVictim)) {
		entitySetFollow(ent, iVictim, 512.0);
	}

	set_task(0.1, "task__RocketFollowVictim", ent);
}

showMenu__RobotInfo(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	new iEntRobot = g_MenuData_EntRobot[id];

	if(!is_valid_ent(iEntRobot)) {
		return;
	}

	SetGlobalTransTarget(id);

	oldmenu_create("\yINFORMACIÓN DEL ROBOT", "@menu__RobotInfo");

	oldmenu_additem(-1, -1, "\wEn construcción^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

@menu__RobotInfo(const id, const item) {
	if(!item) {
		showMenu__SentryAndRobot(id);
		return;
	}

	switch(item) {
		case 1: {

		}
	}
}