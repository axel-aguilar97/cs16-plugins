#include <dg>

#include <cstrike>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <xs>
#include <sqlx>

native ze_get_balrog1(const id);
native ze_get_balrog11(const id);
native ze_get_plasmagun(const id);
native ze_get_skull4(const id);
native ze_get_thunderbolt(const id);

#pragma dynamic	131072
#pragma semicolon 1
#pragma tabsize 0

/*

*/

new const PLUGIN_NAME[] = "Zombie Escape";
new const PLUGIN_VERSION[] = "v2.9.1";
new const PLUGIN_AUTHOR[] = "KISKE & Atsel.";

const MAX_USERS = 33;
const MAX_SPAWNS = 128;
const MAX_LEVEL = 500;
const MAX_XP = 5000000;
const HEALTH_ZOMBIE_EXTRA_PERCENT = 5;

enum _:structZombieClasses
{
	zombieClassName[32],
	zombieClassInfo[64],
	zombieClassModel[128],
	zombieClassClawModel[128],
	zombieClassHealth,
	Float:zombieClassSpeed,
	Float:zombieClassGravity,
	Float:zombieClassKnockback
};

enum _:structIdZombieClasses
{
	ZOMBIE_CLASS_PSYCHO = 0,
	ZOMBIE_CLASS_HEAVY,
	ZOMBIE_CLASS_BANCHEE,
	ZOMBIE_CLASS_VOODOO,
	ZOMBIE_CLASS_LUSTYROSE,
	ZOMBIE_CLASS_TOXICO,
	ZOMBIE_CLASS_FARAHON
};

new const __ZOMBIE_CLASSES[structIdZombieClasses][structZombieClasses] =
{
	{"Zombie Psycho", "Balanceado", "zombie_warz", "models/zombie_plague/zp_manos/v_knife_zombie.mdl", 6000, 270.0, 0.8, 2.0},
	{"Zombie Heavy", "F >>> Poner una Trampa", "dg_heavy", "models/zombie_plague/zp_manos/v_knife_heavy.mdl", 6500, 265.0, 0.8, 2.0},
	{"Zombie Banchee", "F >>> Lanzar murcielagos", "witch_zombi_origin", "models/zombie_plague/zp_manos/v_knife_witch_zombi.mdl", 6000, 270.0, 0.8, 2.0},
	{"Zombie Voodoo", "F >>> Curacion", "dg_voodoo", "models/zombie_plague/zp_manos/v_knife_voodoo.mdl", 6500, 270.0, 0.8, 2.0},
	{"Zombie Lusty Rose", "F >>> Invisivilidad", "dg_lustyrose", "models/zombie_plague/zp_manos/v_knife_lusty_rose.mdl", 6000, 270.0, 0.8, 2.0},
	{"Zombie Tóxico", "F >>> Lanzar ácido", "ze_zombie_toxico_00", "models/zombie_plague/zp_manos/v_zombie_knife_toxico_00.mdl", 6000, 265.0, 0.8, 2.0},
	{"Zombie Farahon", "R >>> Bola de Fuego", "ze_zombie_farahon_00", "models/zombie_plague/zp_manos/v_zombie_knife_farahon_00.mdl", 6000, 270.0, 0.8, 2.0}
};

new const MODEL_TRAMP[] = "models/ze_warz/zombie_trap.mdl";
new const MODEL_BANCHEE[] = "models/zombie_plague/bat_witch.mdl";
new const MODEL_CLAW_INVI[] = "models/zombie_plague/zp_manos/v_knife_lusty_rose_inv.mdl";
new const MODEL_SPIT[] = "models/spit.mdl";
new const MODEL_FIRE[] = "sprites/3dmflared.spr";

new const SOUND_BANCHEE_FIRE[] = "zombie_plague/zombi_banshee_pulling_fire.wav";
new const SOUND_BANCHEE_HIT[] = "zombie_plague/zombi_banshee_laugh.wav";
new const SOUND_BANCHEE_MISS[] = "zombie_plague/zombi_banshee_pulling_fail.wav";
new const SOUND_TOXIC_SPIT_HIT[] = "bullchicken/bc_spithit2.wav";
new const SOUND_TOXIC_SPIT_LAUNCH[] = "zombie_plague/spitter_spit.wav";

new g_ZombieClassHeavy_MakeTramp[MAX_USERS];
new g_ZombieClassHeavy_Trampped[MAX_USERS];
new g_ZombieClassHeavy_TrampCount = 0;
new g_ZombieClassBanchee_BatTime[MAX_USERS];
new g_ZombieClassBanchee_Stat[MAX_USERS];
new g_ZombieClassBanchee_Enemy[MAX_USERS];
new g_ZombieClassBanchee_Sprite;
new g_ZombieClassVoodoo_CanHealth[MAX_USERS];
new g_ZombieClassVoodoo_Sprite;
new g_ZombieClassLusty_Invi[MAX_USERS]; // 1 = Zombie Invisible | 0 = Zombie Visible
new g_ZombieClassLusty_InviWait[MAX_USERS]; // 1 = El zombie ha usado su invisibilidad | 0 = El zombie puede volver a usar su invisibilidad
new Float:g_ZombieClassToxico_LastUsed[MAX_USERS];
new g_ZombieClassToxic_Sprite;
new Float:g_ZombieClassFarahon_LastUsed[MAX_USERS];

new g_UnlimitedClip_Available;
new g_Antidote_Available;

new g_AmbienceSound_Muted[MAX_USERS];
new g_UnlimitedClip[MAX_USERS];
new g_PipeBomb[MAX_USERS];
new g_SBox_CollectedInSameRound[MAX_USERS];
new g_DB_SupplyBox;
new Float:g_DB_SupplyBox_Position[6][3];
new Float:g_DB_SupplyBox_Angles[6][3];
new g_ModeJeruzalem_RewardExp[MAX_USERS];
new g_VIPsKilled[MAX_USERS];
new g_VIPsDead;
new g_ModeJeruzalem_AlreadyRewarded;
new g_AutoMode_Jeruzalem_RoundsLeft = 1337;
new g_AutoMode_Jeruzalem_Count = 1337;
new g_AutoMode_Jeruzalem_Enabled;
new g_Secret_CrazyMode_Enabled = false;
new g_Secret_CrazyMode;
new g_Secret_AlreadySayCrazy[MAX_USERS];
new g_Secret_CrazyMode_Count;
new g_Vinc[MAX_USERS];
new g_VincAppMobile[MAX_USERS];
new g_AchievementLink_Id = -1;
new g_AchievementLink_Class;
new g_AchievementLink_MenuPage;
new g_DailyVisit[MAX_USERS];
new g_DailyVisitAlreadyCounted[MAX_USERS];
new g_EscapeButtonId = -1;
new g_EscapeButtonAlreadyCalled;
new g_RewardAmmoPacksKill[MAX_USERS];
new g_RewardAmmoPacksDamage[MAX_USERS];
new g_RewardAmmoPacksInfect[MAX_USERS];
new g_Secret_NextCrazyMode;

const Float:MODELS_CHANGE_DELAY = 0.5;
const Float:DIV_DAMAGE = 100.0;

enum _:happyHourIds {
	HAPPY_HOUR_OFF = 0,
	DRUNK_AT_DAY,
	DRUNK_AT_NITE
};

enum _:structHappyHour {
	hhExpKillReward,
	hhAPsKillReward_Admin,
	hhAPsKillReward_Vip,
	hhAPsKillReward_Normal,
	hhAPsDamageReward_Admin,
	hhAPsDamageReward_Vip,
	hhAPsDamageReward_Normal,
	hhExpDamage,
	hhPURewardEscape_Vip,
	hhPURewardEscape_Normal,
	hhExpRewardEscape_Vip,
	hhExpRewardEscape_Normal,
	hhAPsRewardEscape_Admin,
	hhAPsRewardEscape_Vip,
	hhAPsRewardEscape_Normal,
	hhExpRewardInfection,
	hhAPsInfectionReward_Admin,
	hhAPsInfectionReward_Admin,
	hhAPsInfectionReward_Vip,
	hhAPsInfectionReward_Normal
};

new const HAPPY_HOUR[happyHourIds][structHappyHour] = {
	// HAPPY HOUR OFF
		{5, 2, 2, 1, 3, 2, 1, 2, 3, 1, 25, 20, 3, 2, 1, 5, 3, 2, 1},
	// DRUNK AT DAY
		{7, 3, 3, 2, 4, 3, 2, 3, 4, 2, 35, 30, 4, 3, 2, 7, 4, 3, 2},
	// DRUNK AT NITE
		{10, 4, 4, 2, 6, 4, 2, 4, 6, 2, 50, 40, 6, 4, 2, 10, 6, 4, 2}
};

const IMPULSE_FLASHLIGHT = 100;
const IMPULSE_SPRAY = 201;

#define isUserValid(%0) (1 <= %0 <= g_MaxUsers)
#define isUserValidAlive(%0) (isUserValid(%0) && g_IsAlive[%0])
#define isUserValidConnected(%0) (isUserValid(%0) && g_IsConnected[%0])

enum _:struckIdTasks (+= 236877) {
	TASK_CHECK_ACCOUNT = 54276,
	TASK_SAVE,
	TASK_HELLOAGAIN,
	TASK_SPAWN,
	TASK_MODEL,
	TASK_TEAM,
	TASK_BURN,
	TASK_FROZEN,
	TASK_MADNESS,
	TASK_IMMUNITY,
	TASK_CHECK_ACHIEVEMENTS,
	TASK_30SEC_ZOMBIE,
	TASK_MADNESS_BOMB,
	TASK_BUTTONED,
	TASK_COUNTDOWN,
	TASK_STARTMODE,
	TASK_AMBIENCESOUNDS,
	TASK_NVISION,
	TASK_ZHEAVY_COOLDOWN,
	TASK_ZHEAVY_REMOVE_TRAMP,
	TASK_ZBANCHEE_START,
	TASK_ZBANCHEE_REMOVE_STAT,
	TASK_ZVOODOO_COOLDOWN,
	TASK_ZLUSTY_INVI,
	TASK_ZLUSTY_INVI_WAIT
};

#define ID_NVISION (taskId - TASK_NVISION)

enum _:struckIdNades (+= 1111) {
	NADE_TYPE_INFECTION = 1111,
	NADE_TYPE_KNOCKBACK,
	NADE_TYPE_FIRE,
	NADE_TYPE_FROST,
	NADE_TYPE_FLARE,
	NADE_TYPE_GRENADE,
	NADE_TYPE_BUBBLE,
	NADE_TYPE_MADNESS,
	NADE_TYPE_PIPE
};

enum _:structIdModes {
	MODE_NONE = 0,
	MODE_MULTI,
	MODE_SWARM,
	MODE_MULTI_ORIGINAL,
	MODE_PLAGUE,
	MODE_ARMAGEDDON,
	MODE_SURVIVOR,
	MODE_NEMESIS,
	MODE_NEMESIS_EXTREM,
	MODE_JERUZALEM
};

enum _:structIdAmbienceSounds { // Que coincida con el enum de structIdModes
	AMBIENCE_SOUNDS_NONE = 0,
	AMBIENCE_SOUNDS_MULTI,
	AMBIENCE_SOUNDS_SWARM,
	AMBIENCE_SOUNDS_MULTI_ORIGINAL,
	AMBIENCE_SOUNDS_PLAGUE,
	AMBIENCE_SOUNDS_ARMAGEDDON,
	AMBIENCE_SOUNDS_SURVIVOR,
	AMBIENCE_SOUNDS_NEMESIS,
	AMBIENCE_SOUNDS_NEMESIS_EXTREME,
	AMBIENCE_SOUND_JERUZALEM
};

enum _:ambienceSoundMuted {
	AMBIENCE_MUTED_NONE = 0,
	AMBIENCE_MUTED_MULTI = 1,
	AMBIENCE_MUTED_SWARM = 2,
	AMBIENCE_MUTED_MULTI_ORIGINAL = 4,
	AMBIENCE_MUTED_PLAGUE = 8,
	AMBIENCE_MUTED_ARMAGEDDON = 16,
	AMBIENCE_MUTED_SURVIVOR = 32,
	AMBIENCE_MUTED_NEMESIS = 64,
	AMBIENCE_MUTED_NEMESIS_EXTREME = 128,
	AMBIENCE_MUTED_JERUZALEM = 256
};

new const AMBIENCE_MUTED_SOUNDS[][] = {
	{MODE_NONE, AMBIENCE_MUTED_NONE},
	{MODE_MULTI, AMBIENCE_MUTED_MULTI},
	{MODE_SWARM, AMBIENCE_MUTED_SWARM},
	{MODE_MULTI_ORIGINAL, AMBIENCE_MUTED_MULTI_ORIGINAL},
	{MODE_PLAGUE, AMBIENCE_MUTED_PLAGUE},
	{MODE_ARMAGEDDON, AMBIENCE_MUTED_ARMAGEDDON},
	{MODE_SURVIVOR, AMBIENCE_MUTED_SURVIVOR},
	{MODE_NEMESIS, AMBIENCE_MUTED_NEMESIS},
	{MODE_NEMESIS_EXTREM, AMBIENCE_MUTED_NEMESIS_EXTREME},
	{MODE_JERUZALEM, AMBIENCE_MUTED_JERUZALEM}
};

enum _:structIdExtraItem
{
	EXTRA_ITEM_ANTIDOTE = 0,
	EXTRA_ITEM_MADNESS,
	EXTRA_ITEM_INFECTION_BOMB,
	EXTRA_ITEM_BUBBLE_BOMB,
	EXTRA_ITEM_ANTI_FIRE,
	EXTRA_ITEM_ANTI_FROST,
	EXTRA_ITEM_MADNESS_BOMB,
	EXTRA_ITEM_BALROG_I,
	EXTRA_ITEM_BALROG_XI,
	EXTRA_ITEM_PLASMAGUN,
	EXTRA_ITEM_SKULL_IV,
	EXTRA_ITEM_THUNDERBOLT,
	EXTRA_ITEM_UNLIMITED_CLIP
};

enum _:structIdExtraItemTeam
{
	ZP_TEAM_HUMAN = 0,
	ZP_TEAM_ZOMBIE
};

enum _:structExtraItem
{
	extraItemName[32],
	extraItemCost,
	extraItemTeam
};

new const EXTRA_ITEMS[structIdExtraItem][structExtraItem] =
{
	// {"Visión nocturna", 0, 0},
	{"Antídoto", 30, ZP_TEAM_ZOMBIE},
	{"Furia Zombie", 40, ZP_TEAM_ZOMBIE},
	{"Bomba de Infección", 80, ZP_TEAM_ZOMBIE},
	{"Campo de Fuerza", 20, ZP_TEAM_HUMAN},
	{"Anti Incendiaria", 5, ZP_TEAM_ZOMBIE},
	{"Anti Congelación", 5, ZP_TEAM_ZOMBIE},
	{"Bomba de Droga", 20, ZP_TEAM_HUMAN},
	{"Balrog I", 10, ZP_TEAM_HUMAN},
	{"Balrog XI", 25, ZP_TEAM_HUMAN},
	{"Plasmagun", 30, ZP_TEAM_HUMAN},
	{"Skull IV", 20, ZP_TEAM_HUMAN},
	{"Thunderbolt", 30, ZP_TEAM_HUMAN},
	{"Balas Infinitas", 60, ZP_TEAM_HUMAN}
};

enum _:structIdAchievements {
	CUENTA_PAR = 0,
	CUENTA_IMPAR,
	x15_ZOMBIES,
	x30_ZOMBIES,
	x50_ZOMBIES,
	x80_ZOMBIES,
	x110_ZOMBIES,
	x220_ZOMBIES,
	x320_ZOMBIES,
	x450_ZOMBIES,
	x500_ZOMBIES,
	x600_ZOMBIES,
	x30_HUMANS,
	x60_HUMANS,
	x100_HUMANS,
	x160_HUMANS,
	x220_HUMANS,
	x280_HUMANS,
	x340_HUMANS,
	x500_HUMANS,
	x700_HUMANS,
	x1000_HUMANS,
	x40_ESCAPES,
	x100_ESCAPES,
	x180_ESCAPES,
	x280_ESCAPES,
	x400_ESCAPES,
	x540_ESCAPES,
	x700_ESCAPES,
	x800_ESCAPES,
	x1080_ESCAPES,
	x1300_ESCAPES,
	SOY_DORADO,
	ESCAPISTA_PRO,
	MEGA_ARMAGEDDON,
	x10_SURVIVORS,
	x25_SURVIVORS,
	x50_SURVIVORS,
	x100_SURVIVORS,
	x200_SURVIVORS,
	x300_SURVIVORS,
	x400_SURVIVORS,
	x500_SURVIVORS,
	x10_NEMESIS,
	x25_NEMESIS,
	x50_NEMESIS,
	x100_NEMESIS,
	x200_NEMESIS,
	x300_NEMESIS,
	x400_NEMESIS,
	x500_NEMESIS,
	AFILANDO_CUCHILLO,
	LIDER_EN_CABEZAS,
	AGUJEREANDO_CABEZAS,
	DANIO_100_000,
	DANIO_500_000,
	DANIO_1_000_000,
	DANIO_5_000_000,
	DANIO_25_000_000,
	DANIO_50_000_000,
	DANIO_100_000_000,
	DANIO_500_000_000,
	DANIO_1_000_000_000,
	DANIO_5_000_000_000,
	DANIO_20_000_000_000,
	DANIO_50_000_000_000,
	DANIO_100_000_000_000,
	DANIO_EVER,
	NIVEL_50,
	NIVEL_100,
	NIVEL_150,
	NIVEL_200,
	NIVEL_250,
	ESTOY_MUY_SOLO,
	FOREVER_ALONE,
	CREO_QUE_TENGO_UN_PROBLEMA,
	SOLO_EL_ZE_ME_ENTIENDE,
	VINCULADO,
	HEAD_5000,
	HEAD_15000,
	HEAD_50000,
	HEAD_150K,
	HEAD_300K,
	HEAD_500K,
	HEAD_1M,
	VENGAN_LOS_ESPERO,
	SOLO_WIN,
	VID_DESINSTALA,
	x2500_ESCAPES,
	x5000_ESCAPES,
	x7500_ESCAPES,
	x12500_ESCAPES,
	x30000_ESCAPES,
	x50000_ESCAPES,
	x100000_ESCAPES,
	PRIMERO_x30000_ESCAPES,
	PRIMERO_x100000_ESCAPES,
	x50_LOGROS,
	x100_LOGROS,
	x250_LOGROS,
	x1000_ZOMBIES,
	x2500_ZOMBIES,
	x5000_ZOMBIES,
	x10000_ZOMBIES,
	x15000_ZOMBIES,
	x20000_ZOMBIES,
	x25000_ZOMBIES,
	x35000_ZOMBIES,
	x50000_ZOMBIES,
	x2500_INFECTS,
	x5000_INFECTS,
	x10000_INFECTS,
	x25000_INFECTS,
	x50000_INFECTS,
	x75000_INFECTS,
	x100000_INFECTS,
	x250000_INFECTS,
	x500000_INFECTS,
	x1000000_INFECTS,
	VID_DESINSTALA_x2,
	SUPPLY_BOX_X1,
	SUPPLY_BOX_X10,
	SUPPLY_BOX_X50,
	SUPPLY_BOX_X100,
	SUPPLY_BOX_X500,
	SUPPLY_BOX_X1000,
	FIRST_SUPPLY_BOX_X1000,
	SUPPLY_BOX_X2_SAME_ROUND,
	SUPPLY_BOX_X3_SAME_ROUND,
	SUPPLY_BOX_X4_SAME_ROUND,
	SUPPLY_BOX_X5_SAME_ROUND,
	FIRST_SUPPLY_BOX_X5_SAME_ROUND,
	SECRET_VIIDRIKO,
	SECRET_VIIDFEO,
	SECRET_VIVA_ALEMANIA,
	SECRET_DANTRE_MICOMANDANTRE,
	SECRET_JAIRO_ES_MI_PICHURRIA,
	SECRET_DANIELSITO_TAPPER,
	SECRET_STUPID,
	MODE_JERUZALEM_2VIPS_ESCAPE,
	MODE_JERUZALEM_KILL_1VIP,
	MODE_JERUZALEM_KILL_2VIP,
	MODE_JERUZALEM_WIN_AS_ZOMBIE,
	SECRET_RUSH_B_MARY,
	SECRET_DRUNKEY_O_JUANITO,
	SECRET_ESTE_LOGRO_AKIRA,
	SECRET_FANGBLADE_ES_MI_BRO,
	SECRET_WARLOCK_ES_MI_BRO,
	SECRET_ESCAPAR_CON_BERZOX,
	SECRET_JAIRITO_TAS_GRABANDO,
	SECRET_CRAZY_MODE,
	APP_VINC,
	APP_ANDROID,
	APP_DAILY_VISIT,
	APP_LAST_BUTTON,
	SECRET_MADURO,
	SECRET_MACRI,
	SECRET_PERU,
	SECRET_BERZOX,
	SECRET_FAFIU,
	SECRET_LA_NEBU,
	SECRET_MALDAD_ETERNA,
	SECRET_ESSKEET,
	SECRET_GORDO_MILANESERO,
	SECRET_DEJO_LOS_ESTUDIOS
};

enum _:structSecretAchievementsSay {
	secretAchievementSay[32],
	secretAchievementId
};

new const MAX_SECRET_ACHIEVEMENTS_SAY = 26;
new const SECRET_ACHIEVEMENTS_SAY[26][structSecretAchievementsSay] = {
	{"viidjuegakuzenbo", VID_DESINSTALA},
	{"jeruzalemisback", VID_DESINSTALA_x2},
	{"viidsitotapper", SECRET_VIIDRIKO},
	{"viidburro", SECRET_VIIDFEO},
	{"genezekiswhite", SECRET_VIVA_ALEMANIA},
	{"comandantrex", SECRET_DANTRE_MICOMANDANTRE},
	{"danielsitotapper", SECRET_JAIRO_ES_MI_PICHURRIA},
	{"jairoesmipichurria", SECRET_DANIELSITO_TAPPER},
	{":v", SECRET_STUPID},
	{"maryrushb", SECRET_RUSH_B_MARY},
	{"silencedota", SECRET_DRUNKEY_O_JUANITO},
	{"berzoxgordo", SECRET_ESTE_LOGRO_AKIRA},
	{"warlock2011", SECRET_FANGBLADE_ES_MI_BRO},
	{"fangblade2011", SECRET_WARLOCK_ES_MI_BRO},
	{"akiral4d2", SECRET_ESCAPAR_CON_BERZOX},
	{"jairito", SECRET_JAIRITO_TAS_GRABANDO},
	{"maduromamaguevo", SECRET_MADURO},
	{"gatomacri", SECRET_MACRI},
	{"mundialperu", SECRET_PERU},
	{"ellogrodefinitivo", SECRET_BERZOX},
	{"masilean", SECRET_FAFIU},
	{"delakristipa", SECRET_LA_NEBU},
	{"morgenze", SECRET_MALDAD_ETERNA},
	{"lilpump", SECRET_ESSKEET},
	{"aguantelamilanesa", SECRET_GORDO_MILANESERO},
	{"alejaestudia", SECRET_DEJO_LOS_ESTUDIOS}
};

enum _:structIdAchClasses {
	ACH_CLASS_HUMAN = 0,
	ACH_CLASS_ZOMBIE,
	ACH_CLASS_MODES,
	ACH_CLASS_OTHERS,
	ACH_CLASS_ESCAPES,
	ACH_CLASS_FIRST,
	ACH_CLASS_SECRET,
	ACHIEVEMENT_CLASS_SUPPLY_BOXES,
	ACHIEVEMENT_CLASS_MOBILE
};

enum _:structIdMetaAchievements {
	MAESTRO_ESCAPES = 0,
	MASTER_SUPPLY_BOXES
};

enum _:struckIdStatsGeneral {
	STATS_INFECTS_D = 0,
	STATS_INFECTS_T,
	STATS_ZOMBIES_D,
	STATS_ZOMBIES_T,
	STATS_HUMANS_D,
	STATS_HUMANS_T,
	STATS_HEAD_D,
	STATS_HEAD_T,
	STATS_ZOMBIES_HEAD_D,
	STATS_ZOMBIES_HEAD_T,
	STATS_ZOMBIES_KNIFE_D,
	STATS_ZOMBIES_KNIFE_T,
	STATS_ARMOR_D,
	STATS_ARMOR_T,
	STATS_ESCAPE_D,
	STATS_ACHIEVEMENTS_D,
	STATS_SURVIVOR_D,
	STATS_NEMESIS_D,
	STATS_SUPPLY_BOX_COLLECTED
};

enum _:structIdColors {
	COLOR_NONE = 0,
	COLOR_HUD,
	COLOR_FLARE
};

enum _:structIdRGB {
	__R = 0,
	__G,
	__B
};

enum _:struckIdPages {
	PAGE_PRIMARY_WEAPON = 0,
	PAGE_SECONDARY_WEAPON,
	PAGE_HUMAN_CLASSES,
	PAGE_ZOMBIE_CLASSES,
	PAGE_SURVIVOR_CLASSES,
	PAGE_NEMESIS_CLASSES,
	PAGE_ACH_CLASSES,
	PAGE_STATS_LVL,
	PAGE_STATS_TOPS15,
	PAGE_STATS_GENERAL,
	PAGE_COLORS,
	PAGE_METAACHIEVEMENTS
};

enum _:struckIdData {
	DATA_UPGRADES = 0,
	DATA_ACH_CLASSES,
	DATA_ACH_IN,
	DATA_HAT_SELECTED,
	DATA_COLORS,
	DATA_METAACHIEVEMENT_IN,
	DATA_UPGRADE_ITEM_ID
};

enum _:structModes {
	modeName[24],
	modeScore,
	modeUsersNeed
};

enum _:struckWeapons {
	weaponCSW,
	weaponEnt[24],
	weaponName[32],
	weaponModel[128]
};

enum _:structGrenades {
	grenadeName[64],
	grenadeAmountHe,
	grenadeAmountFb,
	grenadeAmountSg,
	grenadeLevel
};

enum _:structHumanClasses {
	humanClassName[32],
	humanClassInfo[256],
	humanClassHealth,
	Float:humanClassSpeed,
	Float:humanClassGravity,
	humanClassVip
};

enum _:structSurvivorClasses {
	survivorClassName[32],
	survivorClassInfo[256],
	survivorClassHealth,
	Float:survivorClassSpeed,
	Float:survivorClassGravity,
	survivorClassVip
};

enum _:structNemesisClasses {
	nemesisClassName[32],
	nemesisClassInfo[256],
	nemesisClassHealth,
	Float:nemesisClassSpeed,
	Float:nemesisClassGravity,
	nemesisClassVip
};

enum _:structAchievements {
	achName[64],
	achInfo[256],
	achRewardExp,
	achRewardPU,
	achClass,
	achUsersNeed,
	achievementCanBeRepeated
};

enum _:struckColors {
	colorName[32],
	colorRed,
	colorGreen,
	colorBlue
};

enum _:structTop15 {
	top15Name[32],
	top15URL[64]
};

new const PLAYER_MODEL_SURVIVOR[] = "dg_survivor2";
new const PLAYER_MODEL_NEMESIS[] = "dg_supernemesis";
new const PLAYER_MODEL_JERUZALEM_VIP[] = "jeruzalem_jzm";

new const WEAPON_MODEL_SURVIVOR[][] = {
	"models/zp_models/cso_armas/v_m249_cso.mdl",
	"models/zp_models/cso_armas/p_m249_cso2.mdl"
};
new const KNIFE_MODEL_NEMESIS[] = "models/dg_jeruzalem/v_nemesis_zeh.mdl";
new const GRENADE_MODEL_vINFECTION[][] = { // Infection y Knockback - Mismo Model
	"models/zombie_plague/v_infect_warz.mdl",
	"models/zombie_plague/p_infect_warz.mdl"
};
new const GRENADE_MODEL_vFIRE[] = "models/dg_jeruzalem/v_snowbomb_zehn.mdl";
new const GRENADE_MODEL_vFROST[] = "models/dg_jeruzalem/v_frozen_zeh.mdl";
new const GRENADE_MODEL_vFLARE[] = "models/dg_jeruzalem/v_snowman_zehn.mdl";
new const GRENADE_MODEL_vBUBBLE[] = "models/zombie_plague/tcs_v_bubble.mdl";
new const GRENADE_MODEL_wBUBBLE[] = "models/zombie_plague/tcs_w_bubble.mdl";
new const WEAPON_MODEL_vBAZOOKA[] = "models/zombie_plague/tcs_v_bazooka.mdl";
new const WEAPON_MODEL_pBAZOOKA[] = "models/zombie_plague/tcs_p_bazooka.mdl";
new const MODEL_FROST[] = "models/zombie_plague/_frozen.mdl";
new const MODEL_BUBBLE[] = "models/zombie_plague/dg_halloween.mdl";
new const MODEL_SUPPLYBOX[] = "models/dg_jeruzalem/fun_supplybox.mdl";
new const MODEL_ROCKET[] = "models/zombie_plague/tcs_rocket_1.mdl";
new const g_MODEL_V_PIPE[] = "models/zp_tcs/v_pipe.mdl";
new const g_MODEL_W_PIPE[] = "models/zp_tcs/w_pipe.mdl";

new const SOUND_ANTIDOTE[] = "items/smallmedkit1.wav";
new const SOUND_AMMOPICKUP[] = "items/ammopickup1.wav";
new const SOUND_BUTTON_OK[] = "buttons/button9.wav";
new const SOUND_BUTTON_BAD[] = "buttons/button2.wav";
new const SOUND_WIN_HUMANS[] = "ze_sound/zekf_winhuman.wav";
new const SOUND_WIN_ZOMBIES[] = "ze_sound/zekf_winzombies.wav";
new const SOUND_WIN_NO_ONE[] = "ze_sound/winnoone.wav";
new const SOUND_KNIFE_HUMAN_00[][] = {
	"weapons/knife_deploy1.wav",
	"hero/box_hand_hit_01.wav",
	"hero/box_hand_hit_02.wav",
	"hero/box_hand_hit_03.wav",
	"hero/box_hand_wall_00.wav",
	"hero/box_hand_wall_01.wav",
	"hero/box_hand_slash.wav",
	"hero/box_hand_slash.wav",
	"hero/box_hand_hit_02.wav"
};
new const SOUND_KNIFE_DEFAULT[][] = { // NO PRECACHE
	"weapons/knife_deploy1.wav",
	"weapons/knife_hit1.wav",
	"weapons/knife_hit2.wav",
	"weapons/knife_hit3.wav",
	"weapons/knife_hit4.wav",
	"weapons/knife_hitwall1.wav",
	"weapons/knife_slash1.wav",
	"weapons/knife_slash2.wav",
	"weapons/knife_stab.wav"
};
new const SOUND_ZOMBIE_PAIN[][] = {
	"ze_sound/zombi_pre_idle_1.wav",
	"ze_sound/zombi_pre_idle_2.wav"
};
new const SOUND_NEMESIS_PAIN[][] = {
	"ze_sound/nemesis_pain_1.wav",
	"ze_sound/nemesis_pain_2.wav"
};
new const SOUND_ZOMBIE_CLAW_SLASH[][] = {
	"ze_sound/zombi_swing_1.wav"
};
new const SOUND_ZOMBIE_CLAW_WALL[][] = {
	"ze_sound/zombi_wall_1.wav",
	"ze_sound/zombi_wall_2.wav"
};
new const SOUND_ZOMBIE_CLAW_HIT[][] = {
	"ze_sound/zombi_attack_1.wav",
	"ze_sound/zombi_attack_2.wav",
	"ze_sound/zombi_attack_3.wav"
};
new const SOUND_ZOMBIE_CLAW_STAB[] = "ze_sound/zombi_trapped.wav";
new const SOUND_ZOMBIE_DIE[][] = {
	"ze_sound/zombi_death_2.wav"
};
new const SOUND_ZOMBIE_ALERT[][] = {
	"zombie_plague/tcs_alert_1.wav",
	"zombie_plague/tcs_alert_2.wav",
	"zombie_plague/tcs_alert_3.wav"
};
new const SOUND_ZOMBIE_INFECT[][] = {
	"ze_sound/human_death_01.wav",
	"ze_sound/human_death_02.wav"
};
new const SOUND_ZOMBIE_MADNESS[] = "zombie_plague/zombie_madness1.wav";
new const SOUND_ROUND_GENERAL[][] = {
	"ambience/the_horror2.wav",
	"zp5/mode_00.wav",
	"zp5/gk_mode_01.wav",
	"zp6/gk_mode_03.wav",
	"zp6/gk_mode_09.wav"
};
new const SOUND_ROUND_MODES[][] = {
	"zombie_plague/survivor1.wav",
	"zombie_plague/survivor2.wav",
	"zombie_plague/nemesis1.wav",
	"zombie_plague/nemesis2.wav"
};
new const SOUND_ROUND_ARMAGEDDON[][] = {
	"zp5/gk_siren.wav",
	"sound/zp6/gk_sound_op2.mp3"
};
new const SOUND_GRENADE_INFECT[] = "zombie_plague/grenade_infect.wav";
new const SOUND_GRENADE_KNOCKBACK[] = "nst_zombie/zombi_bomb_exp.wav";
new const SOUND_GRENADE_FIRE[] = "ze_sound/zm_molotov.wav";
new const SOUND_GRENADE_FROST[] = "warcraft3/frostnova.wav";
new const SOUND_GRENADE_FROST_BREAK[] = "warcraft3/impalelaunch1.wav";
new const SOUND_GRENADE_FROST_PLAYER[] = "warcraft3/impalehit.wav";
new const SOUND_GRENADE_FLARE[] = "items/nvg_on.wav";
new const SOUND_GRENADE[] = "misc/molotov_explosion.wav";
new const SOUND_GRENADE_BUBBLE[] = "buttons/button1.wav";
new const SOUND_LEVEL_UP[] = "zp6/gk_lvl_up.wav";
new const SOUND_AMBIENCE[structIdAmbienceSounds][] = {
	"",
	"sound/dg_jeruzalem/zeh_escape.mp3",
	"sound/dg_jeruzalem/zeh_escape.mp3",
	"sound/dg_jeruzalem/zeh_escape.mp3",
	"sound/dg_jeruzalem/zeh_escape.mp3",
	"sound/zombie_plague/ze_armageddon_dg.mp3",
	"sound/zombie_plague/ze_survivor_dg.mp3",
	"sound/zombie_plague/ze_nemesis_dg.mp3",
	"sound/zombie_plague/ze_nemesis_dg.mp3",
	"sound/dg_jeruzalem/jeruzalem_ze.mp3"
};
new const SOUND_ROCKET_00[] = "weapons/rocketfire1.wav";
new const SOUND_ROCKET_01[] = "weapons/mortarhit.wav";
new const SOUND_ROCKET_02[] = "weapons/c4_explode1.wav";
new const SOUND_PIPE_BOMB[] = "zp5/gk_pipe.wav";

new const SPRITE_LASERBEAM[] = "sprites/lgtning.spr";
new const SPRITE_FLAME[] = "sprites/fire4green.spr";
new const SPRITE_SMOKE[] = "sprites/black_smoke3.spr";
new const SPRITE_FROST_EXPLODE[] = "sprites/zp6/ne.spr";
new const SPRITE_GLASS[] = "models/glassgibs.mdl";
new const SPRITE_SHOCKWAVE[] = "sprites/shockwave.spr";
new const SPRITE_BALL_COLORS[][] = {
	"sprites/glow04.spr",
	"sprites/fireworks/rflare.spr",
	"sprites/fireworks/gflare.spr",
	"sprites/fireworks/bflare.spr",
	"sprites/fireworks/yflare.spr",
	"sprites/fireworks/pflare.spr",
	"sprites/fireworks/tflare.spr",
	"sprites/hotglow.spr"
};
new const SPRITE_EXPLOSION[] = "sprites/zp_tcs/molotov_explosion.spr";
new const SPRITE_KNOCKBACK[] = "sprites/zombiebomb_exp.spr";
new const SPRITE_EXPLODE_BAZOOKA[] = "sprites/fexplo2.spr";

new const __MODES[structIdModes][structModes] = {
	{"", 0, 0},
	{"NORMAL", 0, 0},
	{"SWARM", 25, 4},
	{"INFECCIÓN MÚLTIPLE", 10, 6},
	{"PLAGUE", 40, 12},
	{"ARMAGEDDON", 60, 16},
	{"SURVIVOR", 25, 6},
	{"NEMESIS", 25, 6},
	{"NEMESIS EXTREMO", 0, 16},
	{"JERUZALEM", 0, 16}
};

new const PRIMARY_WEAPONS[][struckWeapons] = {
	{CSW_GALIL, "weapon_galil", "Galil Star", "models/dg_jeruzalem/armas/v_galil_zeh.mdl"},
	{CSW_AK47, "weapon_ak47", "AK-47 Militar", "models/dg_jeruzalem/armas/v_ak47_zeh.mdl"},
	{CSW_M4A1, "weapon_m4a1", "M4A1 Force", "models/dg_jeruzalem/armas/v_m4a1_zeh3.mdl"},
	{CSW_SG552, "weapon_sg552", "SG-552 Camuflado", "models/dg_jeruzalem/armas/v_sg552_zeh.mdl"},
	{CSW_AWP, "weapon_awp", "AWP Rayo", "models/dg_jeruzalem/armas/v_awp_zeh.mdl"},
	{CSW_M3, "weapon_m3", "M3 Medieval", "models/dg_jeruzalem/armas/v_m3_zeh.mdl"},
	{CSW_XM1014, "weapon_xm1014", "XM1014 Camuflada", "models/dg_jeruzalem/armas/v_xm1014_zeh.mdl"},
	{CSW_MP5NAVY, "weapon_mp5navy", "MP5 Doble", "models/dg_jeruzalem/armas/v_hkmp5_zeh.mdl"}
};

new const SECONDARY_WEAPONS[][struckWeapons] = {
	{CSW_ELITE, "weapon_elite", "Dual Pistol", "models/dg_jeruzalem/armas/v_elite_zeh2.mdl"},
	{CSW_DEAGLE, "weapon_deagle", "Desert Eagle Gold", "models/dg_jeruzalem/armas/v_deagle_zeh.mdl"}
};

new const GRENADES[][structGrenades] = {
	{"1 GH | 1 GF | 1 GB", 1, 1, 1, 1},
	{"1 GH | 2 GF | 1 GB", 1, 2, 1, 30},
	{"2 GH | 2 GF | 1 GB", 2, 2, 1, 50},
	{"2 GH | 2 GF | 2 GB", 2, 2, 2, 100},
	{"2 GH | 3 GF | 2 GB", 2, 3, 2, 150},
	{"3 GH | 3 GF | 2 GB", 3, 3, 2, 200},
	{"3 GH | 3 GF | 3 GB", 3, 3, 3, 250}
};

enum _:structIdModels {
	ZE_MODEL_NONE = 0,
	ZE_MODEL_MAN,
	ZE_MODEL_WOMAN
};
new const MODEL_HUMAN[structIdModels][] = {"sas", "comando_warz", "zeh_alicedg"};
new g_ModelHuman[MAX_USERS];

enum _:structIdHumanClasses
{
	HUMAN_CIVIL = 0,
	HUMAN_ACTIVO,
	HUMAN_LIVIANO,
	HUMAN_LECIO,
	HUMAN_BLAZE,
	HUMAN_NINJA,
	HUMAN_SNIPER,
	HUMAN_CENTINLA,
	HUMAN_SHARPSHOOTER,
	HUMAN_RADIACTIVO,
	HUMAN_MEDICO
};

new const HUMAN_CLASSES[structIdHumanClasses][structHumanClasses] =
{
	{"Civil", "Balanceado", 100, 240.0, 1.0, 0},
	{"Activo", "Velocidad aumentada", 100, 247.0, 1.0, 0},
	{"Liviano", "Gravedad Reducida", 100, 240.0, 0.85, 0},
	{"Recio", "Vida aumentada", 200, 240.0, 1.1, 0},
	{"Blaze", "Mejorado", 150, 243.0, 0.9, 0},
	{"Ninja", "+Daño con Cuchillo", 100, 240.0, 1.0, 0},
	{"Sniper", "+Daño con Francotiradores", 100, 242.0, 1.0, 0},
	{"Centinela", "+10 de Armadura", 100, 240.0, 1.0, 0},
	{"Sharpshooter", "Presición perfecta", 100, 240.0, 1.0, 0},
	{"Radiactivo", "Sin daño por caidas", 100, 245.0, 0.8, 1},
	{"Médico", "Otorga +10% de vida a sus aliados", 125, 240.0, 1.0, 0}
};

new const SURVIVOR_CLASSES[][structSurvivorClasses] = {
	{"Survivor común", "Rasgos balanceados", 150, 240.0, 1.0, 0},
	{"Survivor rápido", "Velocidad aumentada", 140, 260.0, 1.1, 0},
	{"Survivor ligero", "Gravedad Reducida", 140, 240.0, 0.8, 0},
	{"Survivor poderoso", "Vida aumentada", 160, 240.0, 1.2, 0},
	{"Survivor mejorado", "Rasgos mejorados", 175, 250.0, 0.9, 1}
};

new const NEMESIS_CLASSES[][structNemesisClasses] = {
	{"Nemesis común", "Rasgos balanceados", 800, 250.0, 0.6, 0},
	{"Nemesis rápido", "Velocidad aumentada", 790, 260.0, 0.7, 0},
	{"Nemesis ligero", "Gravedad Reducida", 790, 240.0, 0.5, 0},
	{"Nemesis poderoso", "Vida aumentada", 820, 240.0, 0.7, 0},
	{"Nemesis mejorado", "Rasgos mejorados", 810, 250.0, 0.6, 1}
};

new const UPGRADES_CLASS[][] = {
	"PERSONAJE", "GORRO / MOCHILA", "CUCHILLO"
};

enum _:structUpgrades
{
	upgradeName[32],
	upgradeModelV[128],
	upgradeModelP[128],
	upgradeCost,
	upgradeVip,
	upgradeAppMobile
};

new const UPGRADES_SKIN[][structUpgrades] =
{
	{"Ninguno", "", "", 0, 0, 0},
	{"Payday Wolf", "models/player/zeh_payday/zeh_payday.mdl", "zeh_payday", 2000, 0, 0},
	{"Sarash Black", "models/player/zeh_sarash/zeh_sarash.mdl", "zeh_sarash", 2500, 0, 0},
	{"Chickenator", "models/player/chickenator_wzp/chickenator_wzp.mdl", "chickenator_wzp", 3000, 0, 0},
	{"Lady Hunter", "models/player/classhunter_wzp/classhunter_wzp.mdl", "classhunter_wzp", 3500, 0, 0},
	{"Blade Reaper", "models/player/zeh_blade/zeh_blade.mdl", "zeh_blade", 3500, 0, 0},
	{"Kaitlyn", "models/player/zeh_kaitlyn/zeh_kaitlyn.mdl", "zeh_kaitlyn", 4000, 0, 0},
	{"Crysis Black", "models/player/zeh_crysisblack/zeh_crysisblack.mdl", "zeh_crysisblack", 5000, 0, 0},
	{"Obispo Maldito", "models/player/zeh_curamaldito/zeh_curamaldito.mdl", "zeh_curamaldito", 5500, 0, 0},
	{"Albert Wesker", "models/player/zeh_wesker/zeh_wesker.mdl", "zeh_wesker", 6000, 0, 0},
	{"Predator", "models/player/zeh_predator/zeh_predator.mdl", "zeh_predator", 0, 1, 0},
	{"Agente Angel", "models/player/zeh_agenteangel/zeh_agenteangel.mdl", "zeh_agenteangel", 0, 1, 0},
	{"Kaze", "models/player/zeh_kaze/zeh_kaze.mdl", "zeh_kaze", 2750, 0, 0},
	{"Anarchy", "models/player/jzm_anarchist/jzm_anarchist.mdl", "jzm_anarchist", 3250, 0, 0},
	{"Hitler", "models/player/zeh_hitler/zeh_hitler.mdl", "zeh_hitler", 4500, 0, 0},
	{"Steam Punk", "models/player/zeh_punk/zeh_punk.mdl", "zeh_punk", 5000, 0, 0},
	{"Android Smith", "models/player/jzm_smith_app/jzm_smith_app.mdl", "jzm_smith_app", 0, 0, 1},
	{"Lady Spop", "models/player/ze_ladyspop/ze_ladyspop.mdl", "ze_ladyspop", 2000, 0, 0},
	{"Anonymous", "models/player/ze_anonimous/ze_anonimous.mdl", "ze_anonimous", 3000, 0, 0},
	{"DeathStroke", "models/player/zeh_deathstroke/zeh_deathstroke.mdl", "zeh_deathstroke", 3500, 0, 0}
};

new const UPGRADES_HAT[][structUpgrades] =
{
	{"Ninguno", "", "", 0, 0, 0},
	{"Feliz Halloween", "models/dg_jeruzalem/hats/ogro_zeh.mdl", "", 0, 0, 0},
	{"Bandera Drunk Gaming", "models/ze_hatwarz/14_flagdrunk.mdl", "", 0, 0, 0},
	{"Gazowa", "models/dg_jeruzalem/hats/gazowa_zeh.mdl", "", 300, 0, 0},
	{"Bicho", "models/dg_jeruzalem/hats/bicho_zeh.mdl", "", 400, 0, 0},
	{"Hombre de Nieve", "models/dg_jeruzalem/hats/hombrenieve_zeh.mdl", "", 600, 0, 0},
	{"Tigresa", "models/dg_jeruzalem/hats/tigresa_zeh.mdl", "", 1000, 0, 0},
	{"Nemesis", "models/dg_jeruzalem/hats/nemesis_zeh.mdl", "", 1200, 0, 0},
	{"Black Dragon", "models/dg_jeruzalem/hats/blackdragon_zeh.mdl", "", 1500, 0, 0},
	{"Tutan", "models/dg_jeruzalem/hats/tutan_zeh.mdl", "", 1800, 0, 0},
	{"Red Dragon", "models/dg_jeruzalem/hats/dragonred_zeh.mdl", "", 2000, 0, 0},
	{"Musulman", "models/dg_jeruzalem/hats/musulman_zeh.mdl", "", 2200, 0, 0},
	{"Baby Dino", "models/dg_jeruzalem/hats/babydino_zeh.mdl", "", 2500, 0, 0},
	{"Ladron", "models/dg_jeruzalem/hats/ladron_zeh.mdl", "", 0, 1, 0},
	{"Android Hat", "models/dg_jeruzalem/hats/app_android.mdl", "", 0, 0, 1}
};

new const UPGRADES_KNIFE[][structUpgrades] =
{
	{"Bate Baseball", "models/dg_jeruzalem/knife/v_batezombie.mdl", "models/dg_jeruzalem/knife/p_batezombie.mdl", 0, 0, 0},
	{"Antorcha", "models/dg_jeruzalem/knife/v_antorcha.mdl", "models/dg_jeruzalem/knife/p_antorcha.mdl", 500, 0, 0},
	{"Axe Xmas", "models/dg_jeruzalem/knife/v_axe_xmas.mdl", "models/dg_jeruzalem/knife/p_axe_xmas.mdl", 1500, 0, 0},
	{"Jay Daggers", "models/dg_jeruzalem/knife/v_dagger.mdl", "models/dg_jeruzalem/knife/p_dagger.mdl", 2500, 0, 0},
	{"Dragon Sword", "models/dg_jeruzalem/knife/v_dragonsword.mdl", "models/dg_jeruzalem/knife/p_dragonsword.mdl", 3500, 0, 0},
	{"Dragon Tails", "models/dg_jeruzalem/knife/v_dragontail.mdl", "models/dg_jeruzalem/knife/p_dragontail.mdl", 4500, 0, 0},
	{"Ice Doll", "models/dg_jeruzalem/knife/v_icedoll.mdl", "models/dg_jeruzalem/knife/p_icedoll.mdl", 5500, 0, 0},
	{"Skull Axe II", "models/dg_jeruzalem/knife/v_skullaxe2.mdl", "models/dg_jeruzalem/knife/p_skullaxe2.mdl", 6500, 0, 0},
	{"Shadow Mourne", "models/dg_jeruzalem/knife/v_shadowmourne.mdl", "models/dg_jeruzalem/knife/p_skullaxe2.mdl", 8500, 0, 0},
	{"War Hammer", "models/dg_jeruzalem/knife/v_warhammer.mdl", "models/dg_jeruzalem/knife/p_warhammer.mdl", 0, 1, 0},
	{"Katana Buffed", "models/dg_jeruzalem/knife/v_buffkatana.mdl", "models/dg_jeruzalem/knife/p_buffkatana.mdl", 10000, 0, 0},
	{"Thanatos Android", "models/dg_jeruzalem/knife/v_thanatos_android.mdl", "models/dg_jeruzalem/knife/p_thanatos_android.mdl", 0, 0, 1}
};

new const ACH_CLASSES[structIdAchClasses][] = {
	"HUMANOS", "ZOMBIES", "MODOS", "OTROS", "ESCAPES", "PRIMEROS", "SECRETOS", "CAJAS", "MOBILE"
};

new const ACHS[structIdAchievements][structAchievements] = {
	{"CUENTA PAR", "Número de cuenta par", 0, 2, ACH_CLASS_OTHERS, 0, 0},
	{"CUENTA IMPAR", "Número de cuenta impar", 0, 2, ACH_CLASS_OTHERS, 0, 0},
	{"x15 ZOMBIES", "Mata a 15 zombies", 100, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x30 ZOMBIES", "Mata a 30 zombies", 200, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x50 ZOMBIES", "Mata a 50 zombies", 400, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x80 ZOMBIES", "Mata a 80 zombies", 700, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x110 ZOMBIES", "Mata a 110 zombies", 1100, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x220 ZOMBIES", "Mata a 220 zombies", 1600, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x320 ZOMBIES", "Mata a 320 zombies", 2200, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x450 ZOMBIES", "Mata a 450 zombies", 2900, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x500 ZOMBIES", "Mata a 500 zombies", 3700, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x600 ZOMBIES", "Mata a 600 zombies", 4600, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x30 INFECCIONES", "Infecta a 30 humanos", 100, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x60 INFECCIONES", "Infecta a 60 humanos", 200, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x100 INFECCIONES", "Infecta a 100 humanos", 400, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x160 INFECCIONES", "Infecta a 160 humanos", 700, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x220 INFECCIONES", "Infecta a 200 humanos", 1100, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x280 INFECCIONES", "Infecta a 280 humanos", 1600, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x340 INFECCIONES", "Infecta a 340 humanos", 2200, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x500 INFECCIONES", "Infecta a 500 humanos", 2900, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x700 INFECCIONES", "Infecta a 700 humanos", 3700, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x1.000 INFECCIONES", "Infecta a 1.000 humanos", 4600, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x40 ESCAPES", "Logra escapar en el vehículo de rescate unas 40 veces", 100, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x100 ESCAPES", "Logra escapar en el vehículo de rescate unas 100 veces", 200, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x180 ESCAPES", "Logra escapar en el vehículo de rescate unas 180 veces", 400, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x280 ESCAPES", "Logra escapar en el vehículo de rescate unas 280 veces", 700, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x400 ESCAPES", "Logra escapar en el vehículo de rescate unas 400 veces", 1100, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x540 ESCAPES", "Logra escapar en el vehículo de rescate unas 540 veces", 1600, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x700 ESCAPES", "Logra escapar en el vehículo de rescate unas 700 veces", 2200, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x800 ESCAPES", "Logra escapar en el vehículo de rescate unas 800 veces", 2900, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x1.080 ESCAPES", "Logra escapar en el vehículo de rescate unas 1.080 veces", 3700, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x1.300 ESCAPES", "Logra escapar en el vehículo de rescate unas 1.300 veces", 4600, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"SOY DORADO", "Se un usuario VIP", 0, 5, ACH_CLASS_OTHERS, 0, 0},
	{"ESCAPISTA PRO", "Logra escapar en la zona secreta del mapa \yze_dg_aztec_b1", 100, 5, ACH_CLASS_FIRST, 20, 0},
	{"MEGA ARMAGEDDON", "Participa del Mega effecto del modo Armageddon", 0, 2, ACH_CLASS_OTHERS, 0, 0},
	{"x10 SURVIVORS", "Mata a 10 survivors", 0, 10, ACH_CLASS_MODES, 0, 0},
	{"x25 SURVIVORS", "Mata a 25 survivors", 0, 25, ACH_CLASS_MODES, 0, 0},
	{"x50 SURVIVORS", "Mata a 50 survivors", 0, 50, ACH_CLASS_MODES, 0, 0},
	{"x100 SURVIVORS", "Mata a 100 survivors", 0, 100, ACH_CLASS_MODES, 0, 0},
	{"x200 SURVIVORS", "Mata a 200 survivors", 0, 200, ACH_CLASS_MODES, 0, 0},
	{"x300 SURVIVORS", "Mata a 300 survivors", 0, 300, ACH_CLASS_MODES, 0, 0},
	{"x400 SURVIVORS", "Mata a 400 survivors", 0, 400, ACH_CLASS_MODES, 0, 0},
	{"x500 SURVIVORS", "Mata a 500 survivors", 0, 500, ACH_CLASS_MODES, 0, 0},
	{"x10 NEMESIS", "Mata a 10 nemesis", 0, 10, ACH_CLASS_MODES, 0, 0},
	{"x25 NEMESIS", "Mata a 25 nemesis", 0, 25, ACH_CLASS_MODES, 0, 0},
	{"x50 NEMESIS", "Mata a 50 nemesis", 0, 50, ACH_CLASS_MODES, 0, 0},
	{"x100 NEMESIS", "Mata a 100 nemesis", 0, 100, ACH_CLASS_MODES, 0, 0},
	{"x200 NEMESIS", "Mata a 200 nemesis", 0, 200, ACH_CLASS_MODES, 0, 0},
	{"x300 NEMESIS", "Mata a 300 nemesis", 0, 300, ACH_CLASS_MODES, 0, 0},
	{"x400 NEMESIS", "Mata a 400 nemesis", 0, 400, ACH_CLASS_MODES, 0, 0},
	{"x500 NEMESIS", "Mata a 500 nemesis", 0, 500, ACH_CLASS_MODES, 0, 0},
	{"AFILANDO MI CUCHILLO", "Mata a un zombie con cuchillo", 25, 25, ACH_CLASS_HUMAN, 15, 0},
	{"LÍDER EN CABEZAS", "Mata a 1.000 zombies con disparos en la cabeza", 50, 25, ACH_CLASS_HUMAN, 0, 0},
	{"AGUJEREANDO CABEZAS", "Mata a 10.000 zombies con disparos en la cabeza", 100, 50, ACH_CLASS_HUMAN, 0, 0},
	{"MIRA MI DAÑO", "Realiza 100.000 de daño", 25, 10, ACH_CLASS_HUMAN, 0, 0},
	{"MÁS Y MÁS DAÑO", "Realiza 500.000 de daño", 50, 20, ACH_CLASS_HUMAN, 0, 0},
	{"LLEGUÉ AL MILLÓN", "Realiza 1.000.000 de daño", 75, 30, ACH_CLASS_HUMAN, 0, 0},
	{"MI DAÑO CRECE", "Realiza 5.000.000 de daño", 150, 40, ACH_CLASS_HUMAN, 0, 0},
	{"MI DAÑO CRECE Y CRECE", "Realiza 25.000.000 de daño", 250, 50, ACH_CLASS_HUMAN, 0, 0},
	{"VAMOS POR LOS 50 MILLONES", "Realiza 50.000.000 de daño", 400, 60, ACH_CLASS_HUMAN, 0, 0},
	{"CONTADOR DE DAÑOS", "Realiza 100.000.000 de daño", 750, 70, ACH_CLASS_HUMAN, 0, 0},
	{"YA PERDÍ LA CUENTA", "Realiza 500.000.000 de daño", 1000, 80, ACH_CLASS_HUMAN, 0, 0},
	{"MI DAÑO ES CATASTRÓFICO", "Realiza 1.000.000.000 de daño", 1250, 90, ACH_CLASS_HUMAN, 0, 0},
	{"MI DAÑO ES NUCLEAR", "Realiza 5.000.000.000 de daño", 1750, 100, ACH_CLASS_HUMAN, 0, 0},
	{"MUCHOS NÚMEROS", "Realiza 20.000.000.000 de daño", 2500, 120, ACH_CLASS_HUMAN, 0, 0},
	{"¿SE ME BUGUEO EL DAÑO? ... BAZINGA", "Realiza 50.000.000.000 de daño", 3000, 140, ACH_CLASS_HUMAN, 0, 0},
	{"ME ABURROOOOO", "Realiza 100.000.000.000 de daño", 5000, 160, ACH_CLASS_HUMAN, 0, 0},
	{"NO SÉ LEER ESTE NÚMERO", "Realiza 214.748.364.800 de daño", 7500, 200, ACH_CLASS_HUMAN, 0, 0},
	{"NIVEL: 50", "Alcanza el nivel 50", 0, 5, ACH_CLASS_OTHERS, 0, 0},
	{"NIVEL: 100", "Alcanza el nivel 100", 0, 10, ACH_CLASS_OTHERS, 0, 0},
	{"NIVEL: 150", "Alcanza el nivel 150", 0, 20, ACH_CLASS_OTHERS, 0, 0},
	{"NIVEL: 200", "Alcanza el nivel 200", 0, 30, ACH_CLASS_OTHERS, 0, 0},
	{"NIVEL: 250", "Alcanza el nivel 250", 0, 50, ACH_CLASS_OTHERS, 0, 0},
	{"ESTOY MUY SOLO", "Juega 7 días", 50, 5, ACH_CLASS_OTHERS, 0, 0},
	{"FOREVER ALONE", "Juega 15 días", 125, 10, ACH_CLASS_OTHERS, 0, 0},
	{"CREO QUE TENGO UN PROBLEMA", "Juega 30 días", 250, 15, ACH_CLASS_OTHERS, 0, 0},
	{"SOLO EL ZE ME ENTIENDE", "Juega 50 días", 500, 20, ACH_CLASS_OTHERS, 0, 0},
	{"VINCULADO", "Te la creiste, we xd", 50, 5, ACH_CLASS_OTHERS, 0, 0},
	{"CABEZITA", "Realiza 5.000 disparos en la cabeza", 50, 5, ACH_CLASS_HUMAN, 0, 0},
	{"A PLENO", "Realiza 15.000 disparos en la cabeza", 150, 8, ACH_CLASS_HUMAN, 0, 0},
	{"ROMPIENDO CABEZAS", "Realiza 50.000 disparos en la cabeza", 300, 12, ACH_CLASS_HUMAN, 0, 0},
	{"ABRIENDO CEREBROS", "Realiza 150.000 disparos en la cabeza", 500, 16, ACH_CLASS_HUMAN, 0, 0},
	{"PERFORANDO", "Realiza 300.000 disparos en la cabeza", 750, 20, ACH_CLASS_HUMAN, 0, 0},
	{"DESCOCANDO", "Realiza 500.000 disparos en la cabeza", 1000, 25, ACH_CLASS_HUMAN, 0, 0},
	{"ROMPECRANEOS", "Realiza 1.000.000 disparos en la cabeza", 1250, 30, ACH_CLASS_HUMAN, 0, 0},
	{"VENGAN, LOS ESPERO", "Consigue escapar o ganar la ronda siendo el último humano", 75, 10, ACH_CLASS_HUMAN, 20, 0},
	{"SOLO WIN", "Gana la ronda siendo el último humano contra todos los Zombies", 20, 5, ACH_CLASS_HUMAN, 24, 0},
	{"VIID DESINSTALA", "Logro \rSECRETO", 250, 2, ACH_CLASS_SECRET, 0, 0},
	{"x2.500 ESCAPES", "Logra escapar en el vehículo de rescate unas 2.500 vecess", 7500, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x5.000 ESCAPES", "Logra escapar en el vehículo de rescate unas 5.000 vecess", 9000, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x7.500 ESCAPES", "Logra escapar en el vehículo de rescate unas 7.500 vecess", 12500, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x12.500 ESCAPES", "Logra escapar en el vehículo de rescate unas 12.500 vecess", 17500, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x30.000 ESCAPES", "Logra escapar en el vehículo de rescate unas 30.000 vecess", 25000, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x50.000 ESCAPES", "Logra escapar en el vehículo de rescate unas 50.000 vecess", 30000, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"x100.000 ESCAPES", "Logra escapar en el vehículo de rescate unas 100.000 vecess", 50000, 0, ACH_CLASS_ESCAPES, 0, 0},
	{"PRIMERO: x30.000 ESCAPES", "Se el primero en escapar en el vehículo de rescate unas 30.000 vecess", 25000, 250, ACH_CLASS_FIRST, 0, 0},
	{"PRIMERO: x100.000 ESCAPES", "Se el primero en escapar en el vehículo de rescate unas 100.000 vecess", 50000, 500, ACH_CLASS_FIRST, 0, 0},
	{"x50 LOGROS", "Realiza 50 logros", 250, 5, ACH_CLASS_OTHERS, 0, 0},
	{"x100 LOGROS", "Realiza 100 logros", 500, 10, ACH_CLASS_OTHERS, 0, 0},
	{"x250 LOGROS", "Realiza 250 logros", 1000, 25, ACH_CLASS_OTHERS, 0, 0},
	{"x1.000 ZOMBIES", "Mata a 1.000 zombies", 7500, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x2.500 ZOMBIES", "Mata a 2.500 zombies", 9000, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x5.000 ZOMBIES", "Mata a 5.000 zombies", 12500, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x10.000 ZOMBIES", "Mata a 10.000 zombies", 11750, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x15.000 ZOMBIES", "Mata a 15.000 zombies", 25000, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x20.000 ZOMBIES", "Mata a 20.000 zombies", 30000, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x25.000 ZOMBIES", "Mata a 25.000 zombies", 35000, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x35.000 ZOMBIES", "Mata a 35.000 zombies", 45000, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x50.000 ZOMBIES", "Mata a 50.000 zombies", 75000, 0, ACH_CLASS_HUMAN, 0, 0},
	{"x2.500 INFECCIONES", "Infecta a 2.500 humanos", 7500, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x5.000 INFECCIONES", "Infecta a 5.000 humanos", 9000, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x10.000 INFECCIONES", "Infecta a 10.000 humanos", 12500, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x25.000 INFECCIONES", "Infecta a 25.000 humanos", 17500, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x50.000 INFECCIONES", "Infecta a 50.000 humanos", 25000, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x75.000 INFECCIONES", "Infecta a 75.000 humanos", 35000, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x100.000 INFECCIONES", "Infecta a 100.000 humanos", 50000, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x250.000 INFECCIONES", "Infecta a 250.000 humanos", 75000, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x500.000 INFECCIONES", "Infecta a 500.000 humanos", 90000, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"x1.000.000 INFECCIONES", "Infecta a 1.000.000 humanos", 125000, 0, ACH_CLASS_ZOMBIE, 0, 0},
	{"VIID DESINSTALA x2", "Logro \rSECRETO", 250, 2, ACH_CLASS_SECRET, 0, 0},
	{"SUPPLY BOX x1", "Junta 1 caja", 250, 0, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 8, 0},
	{"SUPPLY BOX x10", "Junta 10 cajas.", 500, 1, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 8, 0},
	{"SUPPLY BOX x50", "Junta 50 cajas.", 1000, 2, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 8, 0},
	{"SUPPLY BOX x100", "Junta 100 cajas.", 1500, 3, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 8, 0},
	{"SUPPLY BOX x500", "Junta 500 cajas.", 3000, 4, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 8, 0},
	{"SUPPLY BOX x1.000", "Junta 1.000 cajas.", 5000, 5, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 8, 0},
	{"PRIMERO: SUPPLY BOX x1.000", "Primero del servidor en juntar 1.000 cajas.", 5000, 5, ACH_CLASS_FIRST, 0, 0},
	{"SUPPLY BOX x2 EN UNA RONDA", "Junta 2 cajas en una misma ronda.", 1000, 1, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 16, 0},
	{"SUPPLY BOX x3 EN UNA RONDA", "Junta 3 cajas en una misma ronda.", 2000, 3, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 16, 0},
	{"SUPPLY BOX x4 EN UNA RONDA", "Junta 4 cajas en una misma ronda.", 3000, 5, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 16, 0},
	{"SUPPLY BOX x5 EN UNA RONDA", "Junta 5 cajas en una misma ronda.", 5000, 10, ACHIEVEMENT_CLASS_SUPPLY_BOXES, 16, 0},
	{"PRIMERO: SUPPLY BOX x5 EN UNA RONDA", "Primero del servidor en juntar^n5 cajas en una misma ronda.", 5000, 10, ACH_CLASS_FIRST, 0, 0},
	{"VIIDRIKO", "Logro \rSECRETO", 150, 1, ACH_CLASS_SECRET, 0, 0},
	{"VIIDFEO", "Logro \rSECRETO", 150, 1, ACH_CLASS_SECRET, 0, 0},
	{"VIVA ALEMANIA!", "Logro \rSECRETO", 150, 1, ACH_CLASS_SECRET, 0, 0},
	{"DANTRE MI COMANDANTRE!", "Logro \rSECRETO", 150, 1, ACH_CLASS_SECRET, 0, 0},
	{"JAIRO ES MI PICHURRIA!", "Logro \rSECRETO", 150, 1, ACH_CLASS_SECRET, 0, 0},
	{"DANIELSITO TAPPER", "Logro \rSECRETO", 150, 1, ACH_CLASS_SECRET, 0, 0},
	{"STUPID", "Demuestra tu estupidez al mundo!", 150, 1, ACH_CLASS_SECRET, 0, 0},
	{"ESCAPE DE LOS VIPS", "Escapa junto a los dos VIPs.", 500, 2, ACH_CLASS_MODES, 0, 0},
	{"MATA A UN VIP", "Matá a un VIP", 500, 1, ACH_CLASS_MODES, 0, 0},
	{"MATA A LOS DOS VIP", "En la misma ronda, matá a los dos VIPs.", 1000, 2, ACH_CLASS_MODES, 0, 0},
	{"LOS VIPS NO PUEDEN ESCAPAR", "Ganá el modo JERUZALEM siendo zombie.", 250, 1, ACH_CLASS_MODES, 0, 0},
	{"RUSH B MARY!", "Logro \rSECRETO", 250, 1, ACH_CLASS_SECRET, 0, 0},
	{"DRUNK EY O JUANITO", "Logro \rSECRETO", 250, 1, ACH_CLASS_SECRET, 0, 0},
	{"ESTE LOGRO SE LO COMIO AKIRA", "Logro \rSECRETO", 250, 1, ACH_CLASS_SECRET, 0, 0},
	{"FANGBLADE ES MI HERMANO!", "Logro \rSECRETO", 250, 1, ACH_CLASS_SECRET, 0, 0},
	{"WARLOCK ES MI HERMANO!", "Logro \rSECRETO", 250, 1, ACH_CLASS_SECRET, 0, 0},
	{"ESCAPAR CON BERZOX!", "Logro \rSECRETO", 250, 1, ACH_CLASS_SECRET, 0, 0},
	{"JAIRITO TAS GRABANDO?", "Logro \rSECRETO", 250, 1, ACH_CLASS_SECRET, 0, 0},
	{"CRAZY MODE", "Participa en un\y CRAZY MODE\w!", 500, 5, ACH_CLASS_SECRET, 0, 1},
	{"VINCULACIÓN MOBILE", "Vinculá tu cuenta con la aplicación mobile.^nDescargá la aplicación desde la \yPlay Store\w!", 5000, 10, ACHIEVEMENT_CLASS_MOBILE, 0, 0},
	{"ANDROID", "Escribí \yandroid\w desde el chat de la aplicación mientras estás conectado!", 500, 2, ACHIEVEMENT_CLASS_MOBILE, 0, 0},
	{"VISITA DIARIA", "Escribí \yvisita\w desde el chat de la aplicación mientras estás conectado!", 1, 2, ACHIEVEMENT_CLASS_MOBILE, 0, 1},
	{"BOTÓN DE ESCAPE", "Se el primero en presionar el botón de escape!", 0, 1, ACHIEVEMENT_CLASS_MOBILE, 8, 1},
	{"MADURO COÑO DE TU MADRE!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"MACRI GATO!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"PERÚ AL MUNDIAL!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"BERZOX ES MI WAIFU", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"QUE HACE FAFIUUUUUU!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"LA NEBU PA JUGAR AL CONTER!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"MALDAD ETERNA!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"ESSKEETITTTTTTTT!!!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"GORDO MILANESERO!", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0},
	{"DEJO LOS ESTUDIOS PA JUGAR ZE :v", "Logro \rSECRETO", 150, 2, ACH_CLASS_SECRET, 0, 0}
};

new const META_ACHIEVEMENTS[structIdMetaAchievements][structAchievements] = {
	{"MAESTRO DEL ESCAPE", "Completa TODOS los logros de la sección \yESCAPES", 100, 50, -1, 0, 0},
	{"MAESTRO DE LAS CAJAS", "Completa TODOS los logros de la sección \yCAJAS", 5000, 100, -1, 0, 0}
};

new const __COLORS[][struckColors] = {
	{"Blanco", 255, 255, 255},
	{"Rojo", 255, 0, 0},
	{"Verde", 0, 255, 0},
	{"Azul", 0, 0, 255},
	{"Amarillo", 255, 255, 0},
	{"Violeta", 255, 0, 255},
	{"Celeste", 0, 255, 255},
	{"Naranja", 200, 100, 0},

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

new const TOPS_15[][structTop15] =
{
	{"General", "top15_general.php"},
	{"Zombies matados", "top15_zombies_killed.php"},
	{"Humanos matados", "top15_humans_killed.php"},
	{"Humanos infectados", "top15_humans_infected.php"},
	{"Daño", "top15_damage_done.php"},
	{"Disparos en la cabeza", "top15_headshot.php"},
	{"Zombies en la cabeza", "top15_zombies_hs_killed.php"},
	{"Zombies con cuchillo", "top15_zombies_knife_killed.php"},
	{"Survivors matados", "top15_survivors_killed.php"},
	{"Nemesis matados", "top15_nemesis_killed.php"},
	{"Chaleco desgarrado", "top15_armor.php"},
	{"Logros desbloqueados", "top15_achievements_unlocked.php"},
	{"Escapes", "top15_escapes.php"},
	{"Tiempo jugado", "top15_played_time.php"}
};

new const RANGES[51][] =
{
	"Inexperto", "Civil Infectado", "Civil Limpio", "Soldado X", "Soldado Solar", "Capitan de Escape", "Coronel de Escape", "General de Escape", "Heroe de Escape", "Escapista Clase I", "Escapista Clase II",
	"Escapista Global", "Supremo Clase I", "Supremo Clase II", "Supremo Clase III", "Cazador Rank C", "Cazador Rank B", "Cazador Rank A+", "Sobreviviente", "Veterano", "Escapista Mitico",
	"Escapista Noble", "Super Nova", "Heredero", "Heredero Final", "Leyenda", "Leyenda X", "Leyenda XL", "Mitico", "Soldado Noble", "Eclipse Negro", "Eclipse Blanco", "El Fuhrer", "Forerunner",
	"Reclamador", "Reclamador II", "Reclamador III", "Escape Ranger", "Escape Ranger II", "Escape Ranger XL", "Ultra Escapista", "Mega Escapista", "Escapista Maximo", "Semi-Dios",
	"Hijo del Escape", "Escape Master", "Escape Master II", "Escape Master III", "Escape Master X", "Escape Master X", "Hijo de Jairito"
};

new const SPAWN_NAME_ENTS[][] = {"info_player_start", "info_player_deathmatch"};

new const SKIES_TYPES[][] = {"bk.tga", "dn.tga", "ft.tga", "lf.tga", "rt.tga", "up.tga"};
new const SKIES[][] = {"mbas"};

new const REMOVE_ENTS[][] = {
	"func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity", "monster_scientist", "info_hostage_rescue", "func_hostage_rescue",
	"func_vehicle", "func_buyzone", "func_tank", "func_tankcontrols", "item_longjump"
};

new const WEAPON_ENT_NAMES[][] = {
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug",
	"weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil",
	"weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1",
	"weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90"
};

new const BLOCK_COMMANDS[][] =	{
	"buy", "buyequip", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47", "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
	"sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "fiveseven", "12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum",
	"d3au1", "krieg550", "smg", "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative",
	"enemydown", "radio3"
};

new const CLASSNAME_THINK_HUD[] = "entThink__Hud";
new const CLASSNAME_THINK_FROST[] = "entThink__Frost";

new const LOGFILE_SERVER_ERROR[] = "ze_server_errors.log";
new const LOGFILE_SQL_ERRORS[] = "ze_sql_errors.log";

new const SQL_HOST[] = "127.0.0.1";
new const SQL_USER[] = "dg_zeuser";
new const SQL_PASSWORD[] = "iIdkx2rLWZl4xYwP";
new const SQL_DATABASE[] = "dg_ze";

new const NEED_EXP_TOTAL[MAX_LEVEL + 2] =
{
	0, 5, 10, 25, 50, 100, 150, 300, 400, 500, 600, 700, 800, 900, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3500, 4000, // 25
	4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000, 12500, 15000, 17500, 20000, 22500, 25000, 27500, 30000, 32500, 35000, 37500, 40000, 42500, // 50
	45000, 47500, 50000, 52500, 55000, 57500, 60000, 62500, 65000, 67500, 70000, 72500, 75000, 77500, 80000, 82500, 85000, 87500, 90000, 92500, 95000, 97500, 100000, 102500, 105000, // 75
	110000, 115000, 120000, 125000, 130000, 135000, 140000, 145000, 150000, 155000, 160000, 165000, 170000, 175000, 180000, 185000, 190000, 195000, 200000, 205000, 210000, 215000, 220000, 225000, 230000, // 100
	235000, 240000, 245000, 250000, 255000, 260000, 265000, 270000, 275000, 280000, 285000, 290000, 295000, 300000, 305000, 310000, 315000, 320000, 325000, 330000, 335000, 340000, 345000, 350000, 355000, // 125
	360000, 365000, 370000, 375000, 380000, 385000, 390000, 395000, 400000, 405000, 410000, 415000, 420000, 425000, 430000, 435000, 440000, 445000, 450000, 455000, 460000, 465000, 470000, 475000, 480000, // 150
	485000, 490000, 495000, 500000, 510000, 520000, 530000, 540000, 550000, 560000, 570000, 580000, 590000, 600000, 610000, 620000, 630000, 640000, 650000, 660000, 670000, 680000, 690000, 700000, 710000, // 175
	720000, 730000, 740000, 750000, 760000, 770000, 780000, 790000, 800000, 810000, 820000, 830000, 840000, 850000, 860000, 870000, 880000, 890000, 900000, 910000, 920000, 930000, 940000, 950000, 960000, // 200
	970000, 980000, 990000, 1000000, 1010000, 1020000, 1030000, 1040000, 1050000, 1060000, 1070000, 1080000, 1090000, 1100000, 1110000, 1120000, 1130000, 1140000, 1150000, 1160000, 1170000, 1180000, 1190000, 1200000, 1210000, // 225
	1220000, 1230000, 1240000, 1250000, 1260000, 1270000, 1280000, 1290000, 1300000, 1310000, 1320000, 1330000, 1340000, 1350000, 1360000, 1370000, 1380000, 1390000, 1400000, 1410000, 1420000, 1430000, 1440000, 1450000, 1500000, // 250
	1510000, 1520000, 1530000, 1540000, 1550000, 1560000, 1570000, 1580000, 1590000, 1600000, 1610000, 1620000, 1630000, 1640000, 1650000, 1660000, 1670000, 1680000, 1690000, 1700000, 1710000, 1720000, 1730000, 1740000, 1750000, // 275
	1760000, 1770000, 1780000, 1790000, 1800000, 1810000, 1820000, 1830000, 1840000, 1850000, 1860000, 1870000, 1880000, 1890000, 1900000, 1910000, 1920000, 1930000, 1940000, 1950000, 1960000, 1970000, 1980000, 1990000, 2000000, // 300
	2010000, 2020000, 2030000, 2040000, 2050000, 2060000, 2070000, 2080000, 2090000, 2100000, 2110000, 2120000, 2130000, 2140000, 2150000, 2160000, 2170000, 2180000, 2190000, 2200000, 2210000, 2220000, 2230000, 2240000, 2250000, // 325
	2260000, 2270000, 2280000, 2290000, 2300000, 2310000, 2320000, 2330000, 2340000, 2350000, 2360000, 2370000, 2380000, 2390000, 2400000, 2410000, 2420000, 2430000, 2440000, 2450000, 2460000, 2470000, 2480000, 2490000, 2500000, // 350
	2510000, 2520000, 2530000, 2540000, 2550000, 2560000, 2570000, 2580000, 2590000, 2600000, 2610000, 2620000, 2630000, 2640000, 2650000, 2660000, 2670000, 2680000, 2690000, 2700000, 2710000, 2720000, 2730000, 2740000, 2750000, // 375
	2760000, 2770000, 2780000, 2790000, 2800000, 2810000, 2820000, 2830000, 2840000, 2850000, 2860000, 2870000, 2880000, 2890000, 2900000, 2910000, 2920000, 2930000, 2940000, 2950000, 2960000, 2970000, 2980000, 2990000, 3000000, // 400
	3020000, 3040000, 3060000, 3080000, 3100000, 3120000, 3140000, 3160000, 3180000, 3200000, 3220000, 3240000, 3260000, 3280000, 3300000, 3320000, 3340000, 3360000, 3380000, 3400000, 3420000, 3440000, 3460000, 3480000, 3500000, // 425
	3520000, 3540000, 3560000, 3580000, 3600000, 3620000, 3640000, 3660000, 3680000, 3700000, 3720000, 3740000, 3760000, 3780000, 3800000, 3820000, 3840000, 3860000, 3880000, 3900000, 3920000, 3940000, 3960000, 3980000, 4000000, // 450
	4020000, 4040000, 4060000, 4080000, 4100000, 4120000, 4140000, 4160000, 4180000, 4200000, 4220000, 4240000, 4260000, 4280000, 4300000, 4320000, 4340000, 4360000, 4380000, 4400000, 4420000, 4440000, 4460000, 4480000, 4500000, // 475
	4512500, 4525000, 4537500, 4550000, 4562500, 4575000, 4587500, 4600000, 4612500, 4625000, 4637500, 4650000, 4662500, 4675000, 4687500, 4700000, 4720000, 4740000, 4760000, 4780000, 4800000, 4850000, 4900000, 4950000, 5000000, // 500

	2100000000
};

new const MAX_BPAMMO[] = {-1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100};
new const AMMO_WEAPON[] = {0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4};
new const AMMO_TYPE[][] = {"", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm"};

new const Float:BULLET_DAMAGE_COORDS[][] = {{0.50, 0.40}, {0.56, 0.44}, {0.60, 0.50}, {0.56, 0.56}, {0.50, 0.60}, {0.44, 0.56}, {0.40, 0.50}, {0.44, 0.44}};
new const Float:WEAPON_KNOCKBACK_POWER[] = {-1.0, 4.0, -1.0, 6.5, -1.0, 8.0, -1.0, 3.0, 5.0, -1.0, 2.4, 2.0, 2.4, 5.3, 5.5, 5.5, 2.2, 2.0, 10.0, 2.5, 6.0, 8.0, 6.0, 2.4, 6.5, -1.0, 5.3, 5.0, 6.0, -1.0, 5.0};

const HIDE_HUDS = (1<<3)|(1<<5);
const UNIT_SECOND = (1<<12);
const DMG_HEGRENADE = (1<<24);
const STEPTIME_SILENT = 999;
const FFADE_IN = 0x0000;
const FFADE_OUT = 0x0001;
const FFADE_STAYOUT = 0x0004;

const Float:NADE_EXPLOSION_RADIUS = 250.0;

const EV_ID_SPEC = EV_INT_iuser2;
const EV_ENT_FLARE = EV_ENT_euser3;
const EV_NADE_TYPE = EV_INT_flTimeStepSound;
const EV_FLARE_COLOR = EV_VEC_punchangle;
const EV_FLARE_DURATION = EV_INT_flSwimTime;

const PDATA_SAFE = 2;
const OFFSET_LINUX_WEAPONS = 4;
const OFFSET_LINUX = 5;
const OFFSET_LEAP = 8;
const OFFSET_WEAPONOWNER = 41;
#if cellbits == 32
const OFFSET_CLIPAMMO = 51;
#else
const OFFSET_CLIPAMMO = 65;
#endif
const OFFSET_ACTIVITY = 73;
const OFFSET_SILENT = 74;
const OFFSET_HITZONE = 75;
const OFFSET_PAINSHOCK = 108;
const OFFSET_PRIMARY_WEAPON = 116;
const OFFSET_JOINSTATE = 121;
const OFFSET_BLOCKTEAM = 125;
const OFFSET_CSMENUCODE = 205;
const OFFSET_FLASHLIGHT_BATTERY = 244;
const OFFSET_BUTTON_PRESSED = 246;
const OFFSET_LONG_JUMP = 356;
const OFFSET_ACTIVE_ITEM = 373;
const OFFSET_CSDEATHS = 444;
const OFFSET_VGUI = 510;

const PRIMARY_WEAPONS_BIT_SUM = (1 << CSW_SCOUT)|(1 << CSW_XM1014)|(1 << CSW_MAC10)|(1 << CSW_AUG)|(1 << CSW_UMP45)|(1 << CSW_SG550)|(1 << CSW_GALIL)|(1 << CSW_FAMAS)|
(1 << CSW_AWP)|(1 << CSW_MP5NAVY)|(1 << CSW_M249)|(1 << CSW_M3)|(1 << CSW_M4A1)|(1 << CSW_TMP)|(1 << CSW_G3SG1)|(1 << CSW_SG552)|(1 << CSW_AK47)|(1 << CSW_P90);
const SECONDARY_WEAPONS_BIT_SUM = (1 << CSW_P228)|(1 << CSW_ELITE)|(1 << CSW_FIVESEVEN)|(1 << CSW_USP)|(1 << CSW_GLOCK18)|(1 << CSW_DEAGLE);
const ZOMBIE_ALLOWED_WEAPONS_BIT_SUM = (1<<CSW_KNIFE)|(1<<CSW_SG550)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE);
const WEAPONS_SILENT_BIT_SUM = (1 << CSW_USP)|(1 << CSW_M4A1);

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

new g_IsConnected[MAX_USERS];
new g_IsAlive[MAX_USERS];
new g_AllowChangeTeam[MAX_USERS];
new g_User_Model[MAX_USERS][32];
new g_User_Name[MAX_USERS][32];
new g_User_Ip[MAX_USERS][21];
new g_User_SteamId[MAX_USERS][35];
new g_Account_Id[MAX_USERS];
new g_AccountJoined[MAX_USERS];
new g_AccountCheck[MAX_USERS];
new g_AccountRegistering[MAX_USERS];
new g_AccountLoading[MAX_USERS];
new g_Account_Password[MAX_USERS][24];
new g_Account_Register[MAX_USERS];
new g_Account_Logged[MAX_USERS];
new g_Account_Banned[MAX_USERS];
new g_Account_RegisterSince[MAX_USERS][32];
new g_Account_LastConnection[MAX_USERS][32];
new g_Account_Rank[MAX_USERS];
new g_AccountPremium[MAX_USERS];
new g_SysTime_In[MAX_USERS];
new g_ClassName[MAX_USERS][32];
new g_Health[MAX_USERS];
new g_MaxHealth[MAX_USERS];
new g_LongJump[MAX_USERS];
new g_InJump[MAX_USERS];
new g_BlockSound[MAX_USERS];
new g_TypeWeapon[MAX_USERS];
new g_CurrentWeapon[MAX_USERS];
new g_Weapon_AutoBuy[MAX_USERS];
new g_WeaponPrimary_Selection[MAX_USERS];
new g_WeaponSecondary_Selection[MAX_USERS];
new g_WeaponPrimary_Bought[MAX_USERS];
new g_WeaponSecondary_Bought[MAX_USERS];
new g_WeaponPrimary_Current[MAX_USERS];
new g_WeaponSecondary_Current[MAX_USERS];
new g_Zombie[MAX_USERS];
new g_SpecialMode[MAX_USERS];
new g_RespawnAsZombie[MAX_USERS];
new g_FirstZombie[MAX_USERS];
new g_LastZombie[MAX_USERS];
new g_LastHuman[MAX_USERS];
new g_LastHuman_1000hp[MAX_USERS];
new g_HumanClass[MAX_USERS];
new g_HumanClassNext[MAX_USERS];
new g_ZombieClass[MAX_USERS];
new g_ZombieClassNext[MAX_USERS];
new g_SurvivorClass[MAX_USERS];
new g_SurvivorClassNext[MAX_USERS];
new g_NemesisClass[MAX_USERS];
new g_NemesisClassNext[MAX_USERS];
new g_Immunity[MAX_USERS];
new g_ImmunityFire[MAX_USERS];
new g_ImmunityFrost[MAX_USERS];
new g_Frozen[MAX_USERS];
new g_Burning_Duration[MAX_USERS];
new g_KnockBackBomb[MAX_USERS];
new g_GrenadeBomb[MAX_USERS];
new g_BubbleBomb[MAX_USERS];
new g_BubbleIn[MAX_USERS];
new g_MadnessBomb[MAX_USERS];
new g_MadnessBomb_Count[MAX_USERS];
new g_MadnessBomb_Move[MAX_USERS];
new g_IsEscaped[MAX_USERS];
new g_Level[MAX_USERS];
new g_Exp[MAX_USERS];
new g_ExpRest[MAX_USERS];
new g_AmmoPacks[MAX_USERS];
new g_PlayedTime[MAX_USERS][4];
new g_Points[MAX_USERS];
new g_PointsLose[MAX_USERS];
new g_UpgradesSkin[MAX_USERS][sizeof(UPGRADES_SKIN)];
new g_UpgradesHat[MAX_USERS][sizeof(UPGRADES_HAT)];
new g_UpgradesKnife[MAX_USERS][sizeof(UPGRADES_KNIFE)];
new g_UpgradeSelect[MAX_USERS][3];
new g_MenuPage_Upgrades[MAX_USERS][3];
new g_Achievement[MAX_USERS][structIdAchievements];
new g_AchievementCount[MAX_USERS][structIdAchievements];
new g_AchievementName[MAX_USERS][structIdAchievements][32];
new g_AchievementUnlocked[MAX_USERS][structIdAchievements][32];
new g_MenuPage_Achievements[MAX_USERS][structIdAchClasses];
new g_MetaAchievement[MAX_USERS][structIdMetaAchievements];
new g_MetaAchievementUnlocked[MAX_USERS][structIdMetaAchievements][32];
new g_Stats_General[MAX_USERS][struckIdStatsGeneral];
new g_Color[MAX_USERS][structIdColors][structIdRGB];
new g_HudGeneral_Effect[MAX_USERS];
new g_HudGeneral_Abrev[MAX_USERS];
new g_HudGeneral_Mini[MAX_USERS];
new g_MenuPage[MAX_USERS][struckIdPages];
new g_MenuData[MAX_USERS][struckIdData];
new g_HatNext[MAX_USERS];
new g_HatId[MAX_USERS];
new g_HatEnt[MAX_USERS];
new g_Invis[MAX_USERS];
new g_UserBullet[MAX_USERS];
new g_Range[MAX_USERS];
new g_Escaped[MAX_USERS];
new g_Camera[MAX_USERS];
new g_Breakabled[MAX_USERS];
new g_Buttoned[MAX_USERS];
new g_Bazooka[MAX_USERS];

new Float:g_AmmoDamage[MAX_USERS];
new Float:g_ExpDamage[MAX_USERS];
new Float:g_Speed[MAX_USERS];
new Float:g_SpeedGravity[MAX_USERS];
new Float:g_FrozenGravity[MAX_USERS];
new Float:g_KnockBack[MAX_USERS];
new Float:g_LevelPercent[MAX_USERS];
new Float:g_HudGeneral_Position[MAX_USERS][3];
new Float:g_Stats_DamageCount[MAX_USERS][2];
new Float:g_SysTime_Link[MAX_USERS];
new Float:g_SysTime_Tops15[MAX_USERS];

new g_MaxUsers;
new g_MenuDisabled;
new g_Sprite_Laserbeam;
new g_Sprite_Flame;
new g_Sprite_Smoke;
new g_Sprite_FrostExplode;
new g_Sprite_Glass;
new g_Sprite_Shockwave;
new g_Sprite_ColorBall[sizeof(SPRITE_BALL_COLORS)];
new g_Sprite_Explosion;
new g_Sprite_KnockBack;
new g_Sprite_ExplodeBazooka;
new g_Message_Money;
new g_Message_FlashBat;
new g_Message_Flashlight;
new g_Message_NVGToggle;
new g_Message_WeapPickup;
new g_Message_AmmoPickup;
new g_Message_TextMsg;
new g_Message_SendAudio;
new g_Message_TeamScore;
new g_Message_TeamInfo;
new g_Message_HideWeapon;
new g_Message_Crosshair;
new g_Message_Fov;
new g_Message_DeathMsg;
new g_Message_ScoreInfo;
new g_Message_ScoreAttrib;
new g_Message_ScreenFade;
new g_Message_ScreenShake;
new g_Message_ShowMenu;
new g_Message_VGUIMenu;
new g_Hud_Event;
new g_Hud_Cooldown;
new g_Hud_General;
new g_Hud_Players;
new g_AmbienceSounds[structIdAmbienceSounds];

new g_CouldDown = 0;
new g_RankGlobal = 0;
new g_SpawnCount = 0;
new g_NewRound = 0;
new g_EndRound = 0;
new g_MapEscaped = 0;
// new g_MapHurted = 0;
new g_Mode = 0;
new g_ModeArmageddon_NoDamage = 0;
new g_LastMode = 0;
new g_SwitchingTeams = 0;
new g_ScoreHumans = 0;
new g_ScoreZombies = 0;
new g_HappyHour = HAPPY_HOUR_OFF;
new g_ExtraItem_InfectionBomb = 0;
new g_ExtraItem_BubbleBomb = 0;
new g_ExtraItem_MadnessBomb = 0;
new g_FirstInfect = 0;
new g_LeaderType = 0;
new g_LeaderLevel_Name[32];
new g_LeaderLevel_Level;
new g_LeaderLevel_Exp[12];
new g_LeaderTime_Name[32];
new g_LeaderTime_Minutes;
new g_LeaderTime_Hours;
new g_LeaderTime_Days;
new g_LeaderAchievement_Name[32];
new g_LeaderAchievement_Total;
new g_Supplybox[6];
new Float:g_SupplyboxOrigin[6][3];
new g_SupplyboxNums = 0;

new g_SQLErrors[512];
new g_SQLQuery[1024];
new g_MapName[32];
new g_Lights[2];
new g_ModeCounts[structIdModes];

new Float:g_Spawns[MAX_SPAWNS][3];
new Float:g_ModelsTargetTime;
new Float:g_TeamsTargetTime;

new g_Cvar_CountDown;
new g_Cvar_Delay;
new g_Cvar_DamageBase;
new g_Cvar_KnockbackBomb_Speed;

new g_fwdSpawn;
new g_fwdPrecacheSound;
new g_fwKeyValue;
new g_fwRoundStarted;
new g_fwInfectedPost;
new g_fwHumanizedPost;
new g_fwUnFrozen;
new g_fwDummy;

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

new HamHook:g_HamPreThink;

new Handle:g_SqlTuple;
new Handle:g_SqlConnection;

public plugin_natives()
{
	register_native("zp_get_user_ammo_packs", "native__GetUserAmmoPacks", 1);
	register_native("zp_set_user_ammo_packs", "native__SetUserAmmoPacks", 1);
	register_native("zp_get_user_zombie", "native__GetUserZombie", 1);
	register_native("zp_get_user_specialmode", "native__GetUserSpecialMode", 1);
	register_native("zp_get_user_zombie_class", "native__GetUserZombieClass", 1);
	register_native("zp_get_zombie_maxhealth", "native__GetZombieMaxHealth", 1);
	register_native("zp_get_zombie_frozen", "native__GetZombieFrozen", 1);

	register_native("zp_has_round_started", "native__HasRoundStarted", 1);
	register_native("zp_get_mode", "native__GetMode", 1);

	register_native("ze_has_pipe_bomb", "native__HasPipeBomb", 1);
}

public plugin_precache() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	get_mapname(g_MapName, charsmax(g_MapName));
	strtolower(g_MapName);

	register_forward(FM_Sys_Error, "fwd__SysErrorPre", 0);

	new sBuffer[128];
	new sNum[3];
	new iEnt;
	new i;
	new j;

	precache_model("models/rpgrocket.mdl");

	for(i = 0; i < structIdZombieClasses; ++i)
	{
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", __ZOMBIE_CLASSES[i][zombieClassModel], __ZOMBIE_CLASSES[i][zombieClassModel]);
		precache_model(sBuffer);

		copy(sBuffer[strlen(sBuffer) - 4], charsmax(sBuffer) - (strlen(sBuffer) - 4), "T.mdl");
		
		if(file_exists(sBuffer))
			precache_model(sBuffer);

		precache_model(__ZOMBIE_CLASSES[i][zombieClassClawModel]);
	}

	precache_model(MODEL_TRAMP);
	precache_model(MODEL_BANCHEE);
	precache_model(MODEL_CLAW_INVI);
	precache_model(MODEL_SPIT);
	precache_model(MODEL_FIRE);

	precache_sound(SOUND_BANCHEE_FIRE);
	precache_sound(SOUND_BANCHEE_HIT);
	precache_sound(SOUND_BANCHEE_MISS);
	precache_sound(SOUND_TOXIC_SPIT_HIT);
	precache_sound(SOUND_TOXIC_SPIT_LAUNCH);
	precache_sound("zombie_plague/husk_pre_fire.wav");
	precache_sound("zombie_plague/husk_wind_down.wav");
	precache_sound("zombie_plague/husk_fireball_fire.wav");
	precache_sound("zombie_plague/husk_fireball_loop.wav");
	precache_sound("zombie_plague/husk_fireball_explode.wav");

	g_ZombieClassBanchee_Sprite = precache_model("sprites/ef_bat.spr");
	g_ZombieClassVoodoo_Sprite = precache_model("sprites/zb3/zp_restore_health.spr");
	g_ZombieClassToxic_Sprite = precache_model("sprites/bubble.spr");

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", MODEL_HUMAN[ZE_MODEL_MAN], MODEL_HUMAN[ZE_MODEL_MAN]);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", MODEL_HUMAN[ZE_MODEL_WOMAN], MODEL_HUMAN[ZE_MODEL_WOMAN]);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_SURVIVOR, PLAYER_MODEL_SURVIVOR);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_NEMESIS, PLAYER_MODEL_NEMESIS);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PLAYER_MODEL_JERUZALEM_VIP, PLAYER_MODEL_JERUZALEM_VIP);
	precache_model(sBuffer);

	precache_model(WEAPON_MODEL_SURVIVOR[0]);
	precache_model(WEAPON_MODEL_SURVIVOR[1]);
	precache_model(KNIFE_MODEL_NEMESIS);
	precache_model(GRENADE_MODEL_vINFECTION[0]);
	precache_model(GRENADE_MODEL_vINFECTION[1]);
	precache_model(GRENADE_MODEL_vFIRE);
	precache_model(GRENADE_MODEL_vFROST);
	precache_model(GRENADE_MODEL_vFLARE);
	precache_model(GRENADE_MODEL_vBUBBLE);
	precache_model(GRENADE_MODEL_wBUBBLE);
	precache_model(WEAPON_MODEL_vBAZOOKA);
	precache_model(WEAPON_MODEL_pBAZOOKA);
	precache_model(MODEL_FROST);
	precache_model(MODEL_BUBBLE);
	precache_model(MODEL_SUPPLYBOX);
	precache_model(MODEL_ROCKET);
	//precache_model(g_MODEL_V_PIPE);
	//precache_model(g_MODEL_W_PIPE);

	for(i = 0; i < sizeof(PRIMARY_WEAPONS); ++i) {
		if(PRIMARY_WEAPONS[i][weaponModel][0]) {
			precache_model(PRIMARY_WEAPONS[i][weaponModel]);
		}
	}

	for(i = 0; i < sizeof(SECONDARY_WEAPONS); ++i) {
		if(SECONDARY_WEAPONS[i][weaponModel][0]) {
			precache_model(SECONDARY_WEAPONS[i][weaponModel]);
		}
	}

	for(i = 0; i < sizeof(UPGRADES_SKIN); ++i) {
		if(UPGRADES_SKIN[i][upgradeModelV][0]) {
			precache_model(UPGRADES_SKIN[i][upgradeModelV]);
		}
	}

	for(i = 0; i < sizeof(UPGRADES_HAT); ++i) {
		if(UPGRADES_HAT[i][upgradeModelV][0]) {
			precache_model(UPGRADES_HAT[i][upgradeModelV]);
		}
	}

	for(i = 0; i < sizeof(UPGRADES_KNIFE); ++i) {
		if(UPGRADES_KNIFE[i][upgradeModelV][0]) {
			precache_model(UPGRADES_KNIFE[i][upgradeModelV]);
		}

		if(UPGRADES_KNIFE[i][upgradeModelP][0]) {
			precache_model(UPGRADES_KNIFE[i][upgradeModelP]);
		}
	}

	precache_sound(SOUND_ANTIDOTE);
	precache_sound(SOUND_AMMOPICKUP);
	precache_sound(SOUND_BUTTON_OK);
	precache_sound(SOUND_BUTTON_BAD);
	precache_sound(SOUND_WIN_HUMANS);
	precache_sound(SOUND_WIN_ZOMBIES);
	precache_sound(SOUND_WIN_NO_ONE);
	for(i = 0; i < sizeof(SOUND_KNIFE_HUMAN_00); ++i) {
		precache_sound(SOUND_KNIFE_HUMAN_00[i]);
	}
	for(i = 0; i < sizeof(SOUND_ZOMBIE_PAIN); ++i) {
		precache_sound(SOUND_ZOMBIE_PAIN[i]);
	}
	for(i = 0; i < sizeof(SOUND_NEMESIS_PAIN); ++i) {
		precache_sound(SOUND_NEMESIS_PAIN[i]);
	}
	for(i = 0; i < sizeof(SOUND_ZOMBIE_CLAW_SLASH); ++i) {
		precache_sound(SOUND_ZOMBIE_CLAW_SLASH[i]);
	}
	for(i = 0; i < sizeof(SOUND_ZOMBIE_CLAW_WALL); ++i) {
		precache_sound(SOUND_ZOMBIE_CLAW_WALL[i]);
	}
	for(i = 0; i < sizeof(SOUND_ZOMBIE_CLAW_HIT); ++i) {
		precache_sound(SOUND_ZOMBIE_CLAW_HIT[i]);
	}
	precache_sound(SOUND_ZOMBIE_CLAW_STAB);
	for(i = 0; i < sizeof(SOUND_ZOMBIE_DIE); ++i) {
		precache_sound(SOUND_ZOMBIE_DIE[i]);
	}
	for(i = 0; i < sizeof(SOUND_ZOMBIE_ALERT); ++i) {
		precache_sound(SOUND_ZOMBIE_ALERT[i]);
	}
	for(i = 0; i < sizeof(SOUND_ZOMBIE_INFECT); ++i) {
		precache_sound(SOUND_ZOMBIE_INFECT[i]);
	}
	precache_sound(SOUND_ZOMBIE_MADNESS);
	for(i = 0; i < sizeof(SOUND_ROUND_GENERAL); ++i) {
		precache_sound(SOUND_ROUND_GENERAL[i]);
	}
	for(i = 0; i < sizeof(SOUND_ROUND_MODES); ++i) {
		precache_sound(SOUND_ROUND_MODES[i]);
	}
	precache_sound(SOUND_ROUND_ARMAGEDDON[0]);
	precache_generic(SOUND_ROUND_ARMAGEDDON[1]);
	precache_sound(SOUND_GRENADE_INFECT);
	precache_sound(SOUND_GRENADE_KNOCKBACK);
	precache_sound(SOUND_GRENADE_FIRE);
	precache_sound(SOUND_GRENADE_FROST);
	precache_sound(SOUND_GRENADE_FROST_BREAK);
	precache_sound(SOUND_GRENADE_FROST_PLAYER);
	precache_sound(SOUND_GRENADE_FLARE);
	precache_sound(SOUND_GRENADE);
	precache_sound(SOUND_GRENADE_BUBBLE);
	precache_sound(SOUND_LEVEL_UP);
	for(i = 0; i < structIdAmbienceSounds; ++i) {
		if(SOUND_AMBIENCE[i][0]) {
			g_AmbienceSounds[i] = 1;
			precache_generic(SOUND_AMBIENCE[i]);
		}
	}
	precache_sound(SOUND_ROCKET_00);
	precache_sound(SOUND_ROCKET_01);
	precache_sound(SOUND_ROCKET_02);
	//precache_sound(SOUND_PIPE_BOMB);
	for(i = 0; i < 10; ++i) {
		num_to_str((i + 1), sNum, charsmax(sNum));

		formatex(sBuffer, charsmax(sBuffer), "zombie_escape/conteo/%s.wav", sNum);
		precache_sound(sBuffer);
	}

	g_Sprite_Laserbeam = precache_model(SPRITE_LASERBEAM);
	g_Sprite_Flame = precache_model(SPRITE_FLAME);
	g_Sprite_Smoke = precache_model(SPRITE_SMOKE);
	g_Sprite_FrostExplode = precache_model(SPRITE_FROST_EXPLODE);
	g_Sprite_Glass = precache_model(SPRITE_GLASS);
	g_Sprite_Shockwave = precache_model(SPRITE_SHOCKWAVE);
	for(i = 0; i < sizeof(SPRITE_BALL_COLORS); ++i) {
		g_Sprite_ColorBall[i] = precache_model(SPRITE_BALL_COLORS[i]);
	}
	g_Sprite_Explosion = precache_model(SPRITE_EXPLOSION);
	g_Sprite_KnockBack = precache_model(SPRITE_KNOCKBACK);
	g_Sprite_ExplodeBazooka = precache_model(SPRITE_EXPLODE_BAZOOKA);
	precache_model("sprites/animglow01.spr");

	for(i = 0; i < sizeof(SKIES_TYPES); ++i)
	{
		for(j = 1; j < sizeof(SKIES); ++j)
		{
			formatex(sBuffer, charsmax(sBuffer), "gfx/env/%s%s", SKIES[j], SKIES_TYPES[i]);
			precache_generic(sBuffer);
		}
	}

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

	iEnt = create_entity("env_fog");
	if(is_valid_ent(iEnt)) {
		DispatchKeyValue(iEnt, "density", "0.0002");
		DispatchKeyValue(iEnt, "rendercolor", "204 0 0");
	}

	g_fwdSpawn = register_forward(FM_Spawn, "fwd__SpawnPre", 0);
	g_fwdPrecacheSound = register_forward(FM_PrecacheSound, "fwd__PrecacheSoundPre", 0);
	g_fwKeyValue = register_forward(FM_KeyValue, "fwd__KeyValuePost", 1);
}

public plugin_init() {
	if(g_MapName[0] != 'z' && g_MapName[1] != 'e' && g_MapName[2] == '_') {
		set_fail_state("[ZE] El mapa especificado no es válido. Los mapas válidos empiezan con ze_");
		return;
	}

	g_UnlimitedClip_Available = canBuyUnlimitedClips();

	new iEnt;
	new i;

	set_task(0.4, "task__StartSQL");

	register_event("HLTV", "event__HLTV", "a", "1=0", "2=0");
	register_event("30", "event__Intermission", "a");
	register_event("AmmoX", "event__AmmoX", "be");
	register_event("Health", "event__Health", "be");
	register_event("Damage", "event__Damage", "b", "2>0", "3=0");
	register_event("StatusValue", "event__ShowStatus", "be", "1=2", "2!0");
	register_event("StatusValue", "event__HideStatus", "be", "1=1", "2=0");

	register_logevent("logevent__RoundEnd", 2, "1=Round_End");

	register_forward(FM_SetClientKeyValue, "fwd__SetClientKeyValuePre", 0);
	register_forward(FM_ClientUserInfoChanged, "fwd__ClientUserInfoChangedPre", 0);
	register_forward(FM_ClientDisconnect, "fwd__ClientDisconnectPost", 1);
	register_forward(FM_ClientKill, "fwd__ClientKillPre", 0);
	register_forward(FM_EmitSound, "fwd__EmitSoundPre", 0);
	register_forward(FM_SetModel, "fwd__SetModelPre", 0);
	register_forward(FM_CmdStart, "fwd__CmdStartPre", 0);
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1);

	unregister_forward(FM_Spawn, g_fwdSpawn);
	unregister_forward(FM_PrecacheSound, g_fwdPrecacheSound);
	unregister_forward(FM_KeyValue, g_fwKeyValue);

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
	RegisterHam(Ham_Think, "grenade", "ham__ThinkGrenadePre", 0);
	RegisterHam(Ham_Player_Jump, "player", "ham__PlayerJumpPre", 0);
	RegisterHam(Ham_Player_Duck, "player", "ham__PlayerDuckPre", 0);
	RegisterHam(Ham_Player_PreThink, "player", "ham__PlayerPreThinkPre", 0);
	DisableHamForward(g_HamPreThink = RegisterHam(Ham_Player_PreThink, "player", "ham__PlayerPreThinkPost", 1));

	for(i = 1; i < sizeof(WEAPON_ENT_NAMES); ++i) {
		if(WEAPON_ENT_NAMES[i][0]) {
			if(i != CSW_HEGRENADE && i != CSW_C4 && i != CSW_SMOKEGRENADE && i != CSW_G3SG1 && i != CSW_SG550 && i != CSW_FLASHBANG) {
				RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_ENT_NAMES[i], "ham__WeaponPrimaryAttackPost", 1);
			}

			if(i == CSW_SG550 || i == CSW_G3SG1) {
				RegisterHam(Ham_Weapon_SecondaryAttack, WEAPON_ENT_NAMES[i], "ham__AutomaticWeaponZoom", 0);
			}

			RegisterHam(Ham_Item_Deploy, WEAPON_ENT_NAMES[i], "ham__ItemDeployPost", 1);
		}
	}

	RegisterHam(Ham_Touch, "trigger_multiple", "ham__TouchZoneEscapePost", 1);

	RegisterHam(Ham_Use, "func_button", "ham__UseButtonPre", 0);
	RegisterHam(Ham_TakeDamage, "func_breakable", "ham__BreakableTakeDamagePost", 1);

	register_touch("ent__Supplybox", "player", "touch__Supplybox");
	register_touch("ent__Rocket", "*", "touch__Rocket");
	register_touch("entZombieHeavyTramp", "*", "touch__Tramp");
	register_touch("entZombieBanchee", "*", "touch__Banchee");
	register_think("entZombieBanchee", "think__Banchee");
	register_touch("entZombieToxic", "*", "touch__Toxic");
	register_touch("entZombieFarahon", "*", "touch__Farahon");

	register_clcmd("CREAR_CONTRASENIA", "clcmd__CreatePassword");
	register_clcmd("REPETIR_CONTRASENIA", "clcmd__RepeatPassword");
	register_clcmd("INGRESAR_CONTRASENIA", "clcmd__EnterPassword");

	register_clcmd("say /noclip", "clcmd__NoClip");
	register_clcmd("say /rank", "clcmd__Rank");
	register_clcmd("say /invis", "clcmd__Invis");
	register_clcmd("say /escape", "clcmd__EscapeTest");
	register_clcmd("say /log", "clcmd__ShowLogs");
	register_clcmd("say_team /log", "clcmd__ShowLogs");
	register_clcmd("say /logs", "clcmd__ShowLogs");
	register_clcmd("say_team /logs", "clcmd__ShowLogs");
	register_clcmd("say /cam", "clcmd__Camera");
	register_clcmd("say_team /cam", "clcmd__Camera");
	register_clcmd("say /crazy", "clcmd__Crazy");
	register_clcmd("test", "clcmd__Test");
	register_clcmd("radio2", "clcmd__Radio2");
	register_clcmd("ze_escape_button", "clcmd__EscapeButton");

	for(i = 0; i < sizeof(BLOCK_COMMANDS); ++i) {
		register_clcmd(BLOCK_COMMANDS[i], "clcmd__Block");
	}
	register_clcmd("radio1", "clcmd__Radio1");
	// register_clcmd("drop", "clcmd__Drop");
	register_clcmd("nightvision", "clcmd__NightVision");
	register_clcmd("chooseteam", "clcmd__ChangeTeam");
	register_clcmd("jointeam", "clcmd__ChangeTeam");
	register_clcmd("menuselect", "clcmd__MenuSelect");
	register_clcmd("joinclass", "clcmd__MenuSelect");

	new sCommand[64];
	for(i = 0; i < MAX_SECRET_ACHIEVEMENTS_SAY; ++i) {
		formatex(sCommand, charsmax(sCommand), "say %s", SECRET_ACHIEVEMENTS_SAY[i][secretAchievementSay]);
		register_clcmd(sCommand, "clcmd__SecretAchievement");
	}

	register_clcmd("say", "clcmd__Say");
	register_clcmd("say_team", "clcmd__SayTeam");

	register_concmd("ze_supplybox", "concmd__Supplybox", ADMIN_LEVEL_E, " - Abre el menú de cajas");
	register_concmd("ze_level", "concmd__Level", ADMIN_LEVEL_H, "<Nombre o #Id> <Cantidad> - Otorga (NO SUMA) niveles al jugador");
	register_concmd("ze_exp", "concmd__Exp", ADMIN_LEVEL_H, "<Nombre o #Id> <Cantidad> - Otorga (NO SUMA) experiencia al jugador");
	register_concmd("ze_ammopacks", "concmd__AmmoPacks", ADMIN_LEVEL_H, "<Nombre o #Id> <Cantidad> - Otorga (NO SUMA) ammo packs al jugador");
	register_concmd("ze_points", "concmd__Points", ADMIN_LEVEL_H, "<Nombre o #Id> <Cantidad> - Otorga (NO SUMA) puntos upgrade");
	register_concmd("ze_achievements", "concmd__Achievements", ADMIN_LEVEL_H, "<Nombre o #Id> <Id de logro> - Otorga el logro al usuario");
	register_concmd("ze_revive", "concmd__Revive", ADMIN_LEVEL_E, "<Target> - Revive a User");
	register_concmd("ze_zombie", "concmd__Zombie", ADMIN_LEVEL_E, "<Target> - Turn a Zombie");
	register_concmd("ze_multi", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Multi");
	register_concmd("ze_swarm", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Swarm");
	register_concmd("ze_multi_original", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Multi Original");
	register_concmd("ze_plague", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Plague");
	register_concmd("ze_armageddon", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Armageddon");
	register_concmd("ze_survivor", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Survivor");
	register_concmd("ze_nemesis", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Nemesis");
	register_concmd("ze_nemesis_extrem", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Nemesis Extrem");
	register_concmd("ze_jeruzalem", "concmd__Mode", ADMIN_LEVEL_E, " - Start Mode Jeruzalem");

	register_menu("LogIn Menu", KEYSMENU, "menu__LogIn");
	register_menu("Join Menu", KEYSMENU, "menu__Join");
	register_menu("Game Menu", KEYSMENU, "menu__Game");
	register_menu("Buy Primary Weapon Menu", KEYSMENU, "menu__BuyPrimaryWeapon");
	register_menu("Buy Secondary Weapon Menu", KEYSMENU, "menu__BuySecondaryWeapon");
	register_menu("Upgrades Menu", KEYSMENU, "menu__Upgrades");
	register_menu("Upgrades Preview Menu", KEYSMENU, "menu__Upgrades_Preview");
	register_menu("Achievements Info Menu", KEYSMENU, "menu__AchievementsInfo");
	register_menu("Achievements Meta Info Menu", KEYSMENU, "menu__MetaAchievementsInfo");
	register_menu("Stats Menu", KEYSMENU, "menu__Stats");
	register_menu("Stats General Menu", KEYSMENU, "menu__StatsGeneral");
	register_menu("Choose Type Color Menu", KEYSMENU, "menu__ChooseTypeColor");
	register_menu("Choose Color Menu", KEYSMENU, "menu__ChooseColor");
	register_menu("ChooseWhatMusicToHear", KEYSMENU, "menu__ChooseWhatMusicToHear");

	g_Message_Money = get_user_msgid("Money");
	g_Message_FlashBat = get_user_msgid("FlashBat");
	g_Message_Flashlight = get_user_msgid("Flashlight");
	g_Message_NVGToggle = get_user_msgid("NVGToggle");
	g_Message_WeapPickup = get_user_msgid("WeapPickup");
	g_Message_AmmoPickup = get_user_msgid("AmmoPickup");
	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SendAudio = get_user_msgid("SendAudio");
	g_Message_TeamScore = get_user_msgid("TeamScore");
	g_Message_TeamInfo = get_user_msgid("TeamInfo");
	g_Message_HideWeapon = get_user_msgid("HideWeapon");
	g_Message_Crosshair = get_user_msgid("Crosshair");
	g_Message_Fov = get_user_msgid("SetFOV");
	g_Message_DeathMsg = get_user_msgid("DeathMsg");
	g_Message_ScoreInfo = get_user_msgid("ScoreInfo");
	g_Message_ScoreAttrib = get_user_msgid("ScoreAttrib");
	g_Message_ScreenFade = get_user_msgid("ScreenFade");
	g_Message_ScreenShake = get_user_msgid("ScreenShake");
	g_Message_ShowMenu = get_user_msgid("ShowMenu");
	g_Message_VGUIMenu = get_user_msgid("VGUIMenu");

	register_message(g_Message_Money, "message__Money");
	register_message(g_Message_FlashBat, "message__FlashBat");
	register_message(g_Message_Flashlight, "message__Flashlight");
	register_message(g_Message_NVGToggle, "message__NVGToggle");
	register_message(g_Message_WeapPickup, "message__WeapPickup");
	register_message(g_Message_AmmoPickup, "message__AmmoPickup");
	register_message(g_Message_TextMsg, "message__TextMsg");
	register_message(g_Message_SendAudio, "message__SendAudio");
	register_message(g_Message_TeamScore, "message__TeamScore");
	register_message(g_Message_TeamInfo, "message__TeamInfo");
	register_message(g_Message_ShowMenu, "message__ShowMenu");
	register_message(g_Message_VGUIMenu, "message__VGUIMenu");
	register_message(get_user_msgid("CurWeapon"), "message__CurWeapon");

	register_impulse(IMPULSE_FLASHLIGHT, "impulse__Flashlight");
	register_impulse(IMPULSE_SPRAY, "impulse__Spray");

	g_Cvar_CountDown = register_cvar("ze_countdown", "7");
	g_Cvar_Delay = register_cvar("ze_delay", "1");
	g_Cvar_DamageBase = register_cvar("ze_damage_base", "50");
	g_Cvar_KnockbackBomb_Speed = register_cvar("ze_knockback_bomb_speed", "600");

	iEnt = create_entity("info_target");
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, CLASSNAME_THINK_HUD);
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.0);

		register_think(CLASSNAME_THINK_HUD, "think__Hud");
	}

	register_think(CLASSNAME_THINK_FROST, "think__Frost");

	g_fwRoundStarted = CreateMultiForward("zp_round_started", ET_IGNORE, FP_CELL, FP_CELL);
	g_fwInfectedPost = CreateMultiForward("zp_user_infected_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	g_fwHumanizedPost = CreateMultiForward("zp_user_humanized_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	g_fwUnFrozen = CreateMultiForward("zp_user_unfrozen", ET_IGNORE, FP_CELL);

	set_cvar_string("sv_skyname", SKIES[random_num(0, charsmax(SKIES))]);
	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	g_MaxUsers = get_maxplayers();

	g_Hud_Event = CreateHudSyncObj();
	g_Hud_Cooldown = CreateHudSyncObj();
	g_Hud_General = CreateHudSyncObj();
	g_Hud_Players = CreateHudSyncObj();

	g_Lights[0] = 'a';

	checkSpawns();

	g_MenuDisabled = menu_makecallback("callback__DisabledMenu");
}

public plugin_cfg()
{
	new sBuffer[64];
	get_configsdir(sBuffer, 63);

	server_cmd("exec %s/zombieescape_specials.cfg", sBuffer);
	server_cmd("exec %s/zombieescape_zclass.cfg", sBuffer);

	set_task(0.5, "event__HLTV");

	new i;
	for(i = 0; i < structIdModes; ++i)
		g_ModeCounts[i] = 0;
}

public plugin_end()
{
	SQL_FreeHandle(g_SqlConnection);
	SQL_FreeHandle(g_SqlTuple);
}

public client_authorized(id) {
	get_user_authid(id, g_User_SteamId[id], charsmax(g_User_SteamId[]));
}

public client_putinserver(id) {
	g_IsConnected[id] = 1;
	g_IsAlive[id] = 0;

	get_user_name(id, g_User_Name[id], 31);
	get_user_ip(id, g_User_Ip[id], charsmax(g_User_Ip[]), 1);

	if(containi(g_User_Name[id], "DROP TABLE") != -1 ||
	containi(g_User_Name[id], "TRUNCATE") != -1 ||
	containi(g_User_Name[id], "INSERT") != -1 ||
	containi(g_User_Name[id], "UPDATE") != -1 ||
	containi(g_User_Name[id], "DELETE") != -1 ||
	containi(g_User_Name[id], "\\") != -1) {
		server_cmd("kick #%d ^"Tu nombre tiene palabras no permitidas!^"", get_user_userid(id));
		return;
	}

	resetVars(id, 1);

	remove_task(id + TASK_CHECK_ACCOUNT);
	set_task(0.3, "task__CheckAccount", id + TASK_CHECK_ACCOUNT);

	set_task(3.0, "task__ModifCommands", id);
}

public client_disconnected(id) {
	remove_task(id + TASK_CHECK_ACCOUNT);
	remove_task(id + TASK_SAVE);
	remove_task(id + TASK_HELLOAGAIN);
	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_TEAM);
	remove_task(id + TASK_BURN);
	remove_task(id + TASK_FROZEN);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_IMMUNITY);
	remove_task(id + TASK_CHECK_ACHIEVEMENTS);
	remove_task(id + TASK_30SEC_ZOMBIE);
	remove_task(id + TASK_MADNESS_BOMB);
	remove_task(id + TASK_BUTTONED);
	remove_task(id + TASK_NVISION);
	remove_task(id + TASK_ZHEAVY_COOLDOWN);
	remove_task(id + TASK_ZHEAVY_REMOVE_TRAMP);
	remove_task(id + TASK_ZBANCHEE_START);
	remove_task(id + TASK_ZBANCHEE_REMOVE_STAT);
	remove_task(id + TASK_ZVOODOO_COOLDOWN);
	remove_task(id + TASK_ZLUSTY_INVI);
	remove_task(id + TASK_ZLUSTY_INVI_WAIT);

	if(g_IsAlive[id]) {
		checkRound(id);
	}

	if(g_Secret_AlreadySayCrazy[id]) {
		--g_Secret_CrazyMode_Count;
	}

	removeFrostCube(id);

	if(is_valid_ent(g_HatEnt[id])) {
		remove_entity(g_HatEnt[id]);
	}

	if(g_Account_Logged[id])
	{
		g_SysTime_In[id] = (get_systime() - g_SysTime_In[id]);
		if(g_SysTime_In[id] >= 18000) {
			g_SysTime_In[id] = 0;
		}

		g_PlayedTime[id][0] += (g_SysTime_In[id] / 60);

		saveInfo(id);
	}

	g_IsConnected[id] = 0;
	g_IsAlive[id] = 0;
}

public event__HLTV()
{
	g_EscapeButtonAlreadyCalled = false;

	set_cvar_num("dg_afk_time", 60);
	set_cvar_num("sv_alltalk", 1);
	set_cvar_num("sv_airaccelerate", 100);

	g_Lights[0] = 'g';
	changeLights();

	set_task(0.1, "task__RemoveStuff");

	static iUsersPlaying;
	static i;

	iUsersPlaying = getPlaying();

	setSupplyBoxRandomReward();

	g_CouldDown = get_pcvar_num(g_Cvar_CountDown);
	g_NewRound = 1;
	g_EndRound = 0;
	g_MapEscaped = 0;
	// g_MapHurted = 0;
	g_Mode = MODE_NONE;
	g_ExtraItem_InfectionBomb = 0;
	g_ExtraItem_BubbleBomb = 0;
	g_ExtraItem_MadnessBomb = 0;
	g_FirstInfect = 0;
	g_Antidote_Available = true;
	g_Secret_CrazyMode = false;
	g_Secret_CrazyMode_Count = 0;
	g_ZombieClassHeavy_TrampCount = 0;

	remove_task(TASK_COUNTDOWN);
	set_task(2.0, "task__VirusT", TASK_COUNTDOWN);

	remove_task(TASK_STARTMODE);
	set_task(2.0 + float(g_CouldDown) + get_pcvar_num(g_Cvar_Delay), "task__StartMode", TASK_STARTMODE);

	g_HappyHour = HAPPY_HOUR_OFF;

	static sHour[3];
	static iHour;

	get_time("%H", sHour, charsmax(sHour));
	iHour = str_to_num(sHour);

	if(iHour >= 22 || (iHour >= 0 && iHour < 6))
	{
		g_HappyHour = DRUNK_AT_NITE;
		dg_color_chat(0, print_team_grey, "!tDRUNK AT NITE!y: Tus ganancias aumentan un +x1");
	}
	else if(iHour >= 11 && iHour < 15) // 12:00 to 16:00 (ARG)
	{
		g_HappyHour = DRUNK_AT_DAY;
		dg_color_chat(0, print_team_grey, "!tDRUNK AT DAY!y: Tus ganancias aumentan un +x0.5");
	}

	for(i = 1; i <= g_MaxUsers; ++i)
	{
		g_SBox_CollectedInSameRound[i] = 0;
		g_Secret_AlreadySayCrazy[i] = false;
		g_ZombieClassHeavy_MakeTramp[i] = 0;
		g_ZombieClassHeavy_Trampped[i] = 0;
		g_ZombieClassBanchee_BatTime[i] = 0;
		g_ZombieClassBanchee_Stat[i] = 0;
		g_ZombieClassBanchee_Enemy[i] = 0;
		g_ZombieClassVoodoo_CanHealth[i] = 0;

		if(iUsersPlaying < 4)
		{
			if(!g_Account_Logged[i])
				continue;

			g_SysTime_In[i] = get_systime();
		}

		if(g_Account_Id[i] == 14131 && g_EscapeButtonId == -1)
			dg_color_chat(i, _, "!gESTE MAPA NO TIENE ASIGNADO UN BOTÓN DE ESCAPE");

		if(g_IsConnected[i] && g_Account_Logged[i])
			updateRewardsByFlags(i);
	}

	checkAutoMode_Jeruzalem();
}

public checkSupplyBox()
{
	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT box_origin_x, box_origin_y, box_origin_z, box_angles_x, box_angles_y, box_angles_z FROM ze1_supplybox WHERE box_mapname=^"%s^";", g_MapName);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadSupplyBox", g_SQLQuery);
}

public event__Intermission() {
	remove_task(TASK_AMBIENCESOUNDS);
	client_cmd(0, "mp3 stop; stopsound");
}

public event__AmmoX(const id) {
	if(g_Zombie[id]) {
		return;
	}

	static iType;
	iType = read_data(1);

	if(iType >= sizeof(AMMO_WEAPON)) {
		return;
	}

	static iWeapon;
	iWeapon = AMMO_WEAPON[iType];

	if(MAX_BPAMMO[iWeapon] <= 2) {
		return;
	}

	static iAmount;
	iAmount = read_data(2);

	if(iAmount < MAX_BPAMMO[iWeapon]) {
		static sArgs[1];

		sArgs[0] = iWeapon;

		set_task(0.1, "task__RefillBPAmmo", id, sArgs, sizeof(sArgs));
	}
}

public event__Health(const id) {
	g_Health[id] = get_user_health(id);
}

public event__Damage(const iVictim) {
	if((read_data(4) || read_data(5) || read_data(6))) {
		static id;
		id = get_user_attacker(iVictim);

		if(isUserValidConnected(id)) {
			static sPos[8];
			static iPos;

			iPos = ++g_UserBullet[id];

			if(iPos == sizeof(BULLET_DAMAGE_COORDS)) {
				iPos = g_UserBullet[id] = 0;
			}

			addDot(read_data(2), sPos, charsmax(sPos));

			set_hudmessage(40, 80, 160, Float:BULLET_DAMAGE_COORDS[iPos][0], Float:BULLET_DAMAGE_COORDS[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1);
			show_hudmessage(id, "%s", sPos);
		}
	}
}

public event__ShowStatus(const id) {
	static iTarget;
	static iOk;

	iTarget = read_data(2);
	iOk = 0;

	if(!g_Zombie[iTarget] && !g_Zombie[id]) {
		iOk = 1;
	} else if(g_Zombie[iTarget] && g_Zombie[id]) {
		iOk = 1;
	}

	if(!iOk) {
		return;
	}

	static sHealth[12];
	addDot(g_Health[iTarget], sHealth, 11);

	set_hudmessage(0, 200, 200, -1.0, 0.75, 0, 0.01, 7.0, 0.01, 0.01, 4);
	ShowSyncHudMsg(id, g_Hud_Players, "Vida: %s^nNivel: %d - Experiencia: %d", sHealth, g_Level[iTarget], g_Exp[iTarget]);
}

public event__HideStatus(const id) {
	ClearSyncHud(id, g_Hud_Players);
}

public logevent__RoundEnd() {
	new iEnt = find_ent_by_class(-1, "ent__Supplybox");
	while(iEnt > 0)	{
		remove_entity(iEnt);
		iEnt = find_ent_by_class(-1, "ent__Supplybox");
	}

	static Float:fLastEndTime;
	static Float:fCurrentTime;

	fCurrentTime = get_gametime();

	if((fCurrentTime - fLastEndTime) < 0.5) {
		return;
	}

	fLastEndTime = fCurrentTime;

	remove_task(TASK_COUNTDOWN);
	remove_task(TASK_STARTMODE);
	if(g_AmbienceSounds[g_Mode]) {
		remove_task(TASK_AMBIENCESOUNDS);
		client_cmd(0, "mp3 stop; stopsound");
	}

	g_EndRound = 1;

	if(!getZombies()) {
		set_hudmessage(0, 0, 255, -1.0, 0.25, 0, 1.0, 7.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(0, g_Hud_Event, "¡ GANARON LOS ESCAPISTAS !");

		playSound(0, SOUND_WIN_HUMANS);

		if(g_Mode == MODE_JERUZALEM) {
			modeJeruzalemFinish(TEAM_CT);
		}
	} else if(!getHumans()) {
		set_hudmessage(255, 0, 0, -1.0, 0.25, 0, 1.0, 7.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(0, g_Hud_Event, "¡ LOS ZOMBIES DOMINARON EL MUNDO !");

		playSound(0, SOUND_WIN_ZOMBIES);
	} else {
		set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 1.0, 7.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(0, g_Hud_Event, "¡ NO GANÓ NADIE !");

		playSound(0, SOUND_WIN_NO_ONE);
	}

	static iUsersNum;
	static i;

	iUsersNum = getPlaying();

	if(iUsersNum < 1) {
		return;
	}

	static TeamName:iTeam[MAX_USERS];
	static iMaxTerrors;
	static iTerrors;

	iMaxTerrors = iUsersNum / 2;
	iTerrors = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		g_ImmunityFire[i] = 0;
		g_ImmunityFrost[i] = 0;

		if(!g_IsConnected[i]) {
			continue;
		}

		iTeam[i] = get_member(i, m_iTeam);

		if(iTeam[i] == TEAM_SPECTATOR || iTeam[i] == TEAM_UNASSIGNED) {
			continue;
		}

		remove_task(i + TASK_TEAM);

		setUserTeam(i, TEAM_CT);
		iTeam[i] = TEAM_CT;

		if(!g_IsAlive[i]) {
			continue;
		}

		g_Speed[i] = 75.0;
		ExecuteHamB(Ham_Player_ResetMaxSpeed, i);

		if(g_Frozen[i]) {
			removeFrostCube(i);
		}

		message_begin(MSG_ONE, g_Message_Fov, _, i);
		write_byte(110);
		message_end();

		if(g_LastHuman[i] && g_LastHuman_1000hp[i]) {
			setAchievement(i, VENGAN_LOS_ESPERO);
		} else if(g_LastHuman[i]) {
			if(g_Mode != MODE_MULTI && g_Mode != MODE_MULTI_ORIGINAL) {
				setAchievement(i, SOLO_WIN);
			}
		}
	}

	i = 0;

	while(iTerrors < iMaxTerrors) {
		if(++i > g_MaxUsers) {
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

public think__Hud(const entity) {
	if(!is_valid_ent(entity)) {
		return;
	}

	static sHealth[12];
	static sAmmoPacks[8];
	static sXpNeed[8];
	static sXp[8];
	static iSpect;
	static i;

	iSpect = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!g_IsConnected[i]) {
			continue;
		}

		if(g_IsAlive[i]) {
			if(g_Mode == MODE_JERUZALEM && g_ModeJeruzalem_RewardExp[i] != -5) {
				g_ModeJeruzalem_RewardExp[i] += 5;

				set_hudmessage(255, 255, 255, -1.0, 0.2, 0, 6.0, 1.1, 0.0, 0.0, -1);
				ShowSyncHudMsg(i, g_Hud_Cooldown, "EXPERIENCIA ACUMULADA: +%d", g_ModeJeruzalem_RewardExp[i]);
			}

			set_hudmessage(g_Color[i][COLOR_HUD][__R], g_Color[i][COLOR_HUD][__G], g_Color[i][COLOR_HUD][__B], g_HudGeneral_Position[i][0], g_HudGeneral_Position[i][1], g_HudGeneral_Effect[i], 6.0, 1.1, 0.0, 0.0, 3);

			addDot(g_Health[i], sHealth, 11);
			addDot(g_AmmoPacks[i], sAmmoPacks, 7);
			addDot(g_Exp[i], sXp, 7);
			addDot(NEED_EXP_TOTAL[g_Level[i]], sXpNeed, charsmax(sXpNeed));

			if(g_HudGeneral_Abrev[i]) {
				if(g_HudGeneral_Mini[i]) {
					ShowSyncHudMsg(i, g_Hud_General, "%sHP: %s - AP: %d - %s - APs: %s^nLVL: %d (%0.2f%%) - EXP: %s / %s - RNG: %s", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_ClassName[i], sAmmoPacks, g_Level[i], g_LevelPercent[i], sXp, sXpNeed, RANGES[g_Range[i]]);
				} else {
					ShowSyncHudMsg(i, g_Hud_General, "%sHP: %s^nAP: %d^n%s^nAPs: %s^nLVL: %d (%0.2f%%)^nEXP: %s / %s^nRNG: %s", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_ClassName[i], sAmmoPacks, g_Level[i], g_LevelPercent[i], sXp, sXpNeed, RANGES[g_Range[i]]);
				}
			} else {
				if(g_HudGeneral_Mini[i]) {
					ShowSyncHudMsg(i, g_Hud_General, "%sVida: %s - Armadura: %d - Clase: %s - Ammo packs: %s^nNivel: %d (%0.2f%%) - Experiencia: %s / %s - Rango: %s", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_ClassName[i], sAmmoPacks, g_Level[i], g_LevelPercent[i], sXp, sXpNeed, RANGES[g_Range[i]]);
				} else {
					ShowSyncHudMsg(i, g_Hud_General, "%sVida: %s^nArmadura: %d^nClase: %s^nAmmo packs: %s^nNivel: %d (%0.2f%%)^nExperiencia: %s / %s^nRango: %s", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_ClassName[i], sAmmoPacks, g_Level[i], g_LevelPercent[i], sXp, sXpNeed, RANGES[g_Range[i]]);
				}
			}
		} else {
			iSpect = entity_get_int(i, EV_ID_SPEC);

			if(!g_IsAlive[iSpect]) {
				continue;
			}

			set_hudmessage(g_Color[iSpect][COLOR_HUD][__R], g_Color[iSpect][COLOR_HUD][__G], g_Color[iSpect][COLOR_HUD][__B], 0.6, 0.6, g_HudGeneral_Effect[iSpect], 6.0, 1.1, 0.0, 0.0, 3);

			addDot(g_Health[iSpect], sHealth, 11);
			addDot(g_AmmoPacks[iSpect], sAmmoPacks, 7);
			addDot(g_Exp[iSpect], sXp, 7);

			if(g_HudGeneral_Abrev[iSpect]) {
				if(g_HudGeneral_Mini[iSpect]) {
					ShowSyncHudMsg(i, g_Hud_General, "%s^nHP: %s - AP: %d - %s - APS: %s^nLVL: %d - XP: %s - RNG: %s", g_User_Name[iSpect], sHealth, get_user_armor(iSpect), g_ClassName[iSpect], sAmmoPacks, g_Level[iSpect], sXp, RANGES[g_Range[iSpect]]);
				} else {
					ShowSyncHudMsg(i, g_Hud_General, "%s^nHP: %s^nAP: %d^n%s^nAPS: %s^nLVL: %d^nXP: %s^nRNG: %s", g_User_Name[iSpect], sHealth, get_user_armor(iSpect), g_ClassName[iSpect], sAmmoPacks, g_Level[iSpect], sXp, RANGES[g_Range[iSpect]]);
				}
			} else {
				if(g_HudGeneral_Mini[iSpect]) {
					ShowSyncHudMsg(i, g_Hud_General, "Nombre: %s^nVida: %s - Chaleco: %d - Clase: %s - Ammo Packs: %s^nNivel: %d - Experiencia: %s - Rango: %s", g_User_Name[iSpect], sHealth, get_user_armor(iSpect), g_ClassName[iSpect], sAmmoPacks, g_Level[iSpect], sXp, RANGES[g_Range[iSpect]]);
				} else {
					ShowSyncHudMsg(i, g_Hud_General, "Nombre: %s^nVida: %s^nChaleco: %d^nClase: %s^nAmmo Packs: %s^nNivel: %d^nExperiencia: %s^nRango: %s", g_User_Name[iSpect], sHealth, get_user_armor(iSpect), g_ClassName[iSpect], sAmmoPacks, g_Level[iSpect], sXp, RANGES[g_Range[iSpect]]);
				}
			}
		}
	}

	entity_set_float(entity, EV_FL_nextthink, get_gametime() + 1.00);
}

public think__Frost(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}

	remove_entity(ent);
}

public fwd__SysErrorPre(const error[]) {
	static sError[512];
	formatex(sError, charsmax(sError), "FORWARD: FM_Sys_Error | Error: %s | MAPA: %s", (error[0]) ? error : "Ninguno", g_MapName);

	log_to_file(LOGFILE_SERVER_ERROR, sError);
}

public fwd__SpawnPre(const entity) {
	if(!pev_valid(entity)) {
		return FMRES_IGNORED;
	}

	static sClassName[32];
	static i;

	entity_get_string(entity, EV_SZ_classname, sClassName, charsmax(sClassName));

	for(i = 0; i < sizeof(REMOVE_ENTS); ++i) {
		if(equal(sClassName, REMOVE_ENTS[i])) {
			remove_entity(entity);
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

public fwd__KeyValuePost(const ent, const kvd_handle) {
	if(!is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}

	new sInfo[32];
	get_kvd(kvd_handle, KV_ClassName, sInfo, 31);

	if(!equal(sInfo, "trigger_hurt")) {
		return FMRES_IGNORED;
	}

	get_kvd(kvd_handle, KV_KeyName, sInfo, 31);

	if(contain(sInfo, "dmg") == -1) {
		return FMRES_IGNORED;
	}

	new sValue[12];
	get_kvd(kvd_handle, KV_Value, sValue, 11);

	server_print("trigger_hurt - %s - %s", sInfo, sValue);
	return FMRES_IGNORED;
}

public fwd__SetClientKeyValuePre(const id, const buffer[], const key[]) {
	if(key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l') {
		return FMRES_SUPERCEDE;
	}

	if(key[0] == 'n' && key[1] == 'a' && key[2] == 'm' && key[3] == 'e') {
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fwd__ClientUserInfoChangedPre(const id, const buffer) {
	if(!g_IsConnected[id]) {
		return FMRES_IGNORED;
	}

	get_user_name(id, g_User_Name[id], charsmax(g_User_Name[]));

	static sCurrentModel[32];
	getUserModel(id, sCurrentModel, charsmax(sCurrentModel));

	if(!equal(sCurrentModel, g_User_Model[id]) && !task_exists(id + TASK_MODEL)) {
		setUserModel(id + TASK_MODEL);
	}

	static sNewName[32];
	engfunc(EngFunc_InfoKeyValue, buffer, "name", sNewName, charsmax(sNewName));

	if(equal(sNewName, g_User_Name[id])) {
		return FMRES_IGNORED;
	}

	engfunc(EngFunc_SetClientKeyValue, id, buffer, "name", g_User_Name[id]);
	client_cmd(id, "name ^"%s^"; setinfo name ^"%s^"", g_User_Name[id], g_User_Name[id]);

	set_user_info(id, "name", g_User_Name[id]);
	return FMRES_SUPERCEDE;
}

public fwd__ClientDisconnectPost() {
	checkLastZombie();
}

public fwd__ClientKillPre() {
	return FMRES_SUPERCEDE;
}

public fwd__EmitSoundPre(const id, const channel, const sample[], const Float:volume, const Float:attn, const flags, const pitch) {
	if(sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') { // HOSTAGE
		return FMRES_SUPERCEDE;
	}

	if(sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l') { // FALL
		return FMRES_SUPERCEDE;
	}

	if(!isUserValidConnected(id)) {
		return FMRES_IGNORED;
	}

	if(!g_Zombie[id]) {
		if(g_CurrentWeapon[id] == CSW_KNIFE) {
			static i;

			if(g_UpgradeSelect[id][2] == 0) { // PUÑOS
				for(i = 0; i < sizeof(SOUND_KNIFE_HUMAN_00); ++i) {
					if(equal(sample, SOUND_KNIFE_DEFAULT[i])) {
						emit_sound(id, channel, SOUND_KNIFE_HUMAN_00[i], 1.0, ATTN_NORM, 0, PITCH_NORM);
						return FMRES_SUPERCEDE;
					}
				}
			}
		}

		return FMRES_IGNORED;
	}

	if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') { // BHIT
		if(g_SpecialMode[id] == MODE_NEMESIS) {
			emit_sound(id, channel, SOUND_NEMESIS_PAIN[random_num(0, charsmax(SOUND_NEMESIS_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		} else {
			emit_sound(id, channel, SOUND_ZOMBIE_PAIN[random_num(0, charsmax(SOUND_ZOMBIE_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		}

		return FMRES_SUPERCEDE;
	}

	if(g_CurrentWeapon[id] == CSW_KNIFE) {
		if(!g_BlockSound[id]) {
			if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i') { // KNI
				if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') { // SLA
					emit_sound(id, channel, SOUND_ZOMBIE_CLAW_SLASH[random_num(0, charsmax(SOUND_ZOMBIE_CLAW_SLASH))], 1.0, ATTN_NORM, 0, PITCH_NORM);
					return FMRES_SUPERCEDE;
				}

				if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') { // HIT
					if(sample[17] == 'w') { // WALL
						emit_sound(id, channel, SOUND_ZOMBIE_CLAW_WALL[random_num(0, charsmax(SOUND_ZOMBIE_CLAW_WALL))], 1.0, ATTN_NORM, 0, PITCH_NORM);
						return FMRES_SUPERCEDE;
					} else {
						emit_sound(id, channel, SOUND_ZOMBIE_CLAW_HIT[random_num(0, charsmax(SOUND_ZOMBIE_CLAW_HIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
						return FMRES_SUPERCEDE;
					}
				}

				if(sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') { // STAB
					emit_sound(id, channel, SOUND_ZOMBIE_CLAW_STAB, 1.0, ATTN_NORM, 0, PITCH_NORM);
					return FMRES_SUPERCEDE;
				}
			}
		} else {
			g_BlockSound[id] = 0;
		}
	}

	if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) { // DIE / DEAD
		emit_sound(id, channel, SOUND_ZOMBIE_DIE[random_num(0, charsmax(SOUND_ZOMBIE_DIE))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fwd__SetModelPre(const ent, const model[])
{
	if(strlen(model) < 8)
		return FMRES_IGNORED;

	static sClassName[16];
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(equal(sClassName, "weaponbox"))
	{
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 5.0);
		return FMRES_IGNORED;
	}

	if(model[7] != 'w' || model[8] != '_')
		return FMRES_IGNORED;

	static Float:fDamageTime;
	fDamageTime = entity_get_float(ent, EV_FL_dmgtime);

	if(fDamageTime == 0.0)
		return FMRES_IGNORED;

	static id;
	id = entity_get_edict(ent, EV_ENT_owner);

	switch(model[9])
	{
		case 'h':
		{
			if(!g_Zombie[id])
			{
				if(g_PipeBomb[id]) {
					effectGrenade(ent, 255, 0, 0, NADE_TYPE_PIPE);
					--g_PipeBomb[id];

					entity_set_model(ent, g_MODEL_W_PIPE);
					entity_set_int(ent, EV_INT_solid, SOLID_NOT);

					replaceWeaponModels(id, CSW_HEGRENADE);

					return FMRES_SUPERCEDE;
				} else if(g_MadnessBomb[id]) {
					effectGrenade(ent, random(256), random(256), random(256), NADE_TYPE_MADNESS);
					--g_MadnessBomb[id];
				}
				else
					effectGrenade(ent, 255, 0, 0, NADE_TYPE_FIRE);
			}
			else
			{
				if(g_KnockBackBomb[id])
				{
					effectGrenade(ent, 25, 25, 25, NADE_TYPE_KNOCKBACK);
					--g_KnockBackBomb[id];
				}
				else
					effectGrenade(ent, 0, 255, 0, NADE_TYPE_INFECTION);
			}

			replaceWeaponModels(id, CSW_HEGRENADE);
		}
		case 'f':
		{
			if(!g_Zombie[id])
				effectGrenade(ent, 0, 0, 255, NADE_TYPE_FROST);

			replaceWeaponModels(id, CSW_FLASHBANG);
		}
		case 's':
		{
			if(!g_Zombie[id])
			{
				if(g_BubbleBomb[id])
				{
					effectGrenade(ent, random(256), random(256), random(256), NADE_TYPE_BUBBLE);
					--g_BubbleBomb[id];

					replaceWeaponModels(id, CSW_SMOKEGRENADE);

					entity_set_model(ent, GRENADE_MODEL_wBUBBLE);
					return FMRES_SUPERCEDE;
				}
				else if(g_GrenadeBomb[id])
				{
					effectGrenade(ent, 200, 100, 0, NADE_TYPE_GRENADE);
					--g_GrenadeBomb[id];
				}
				else
					effectGrenade(ent, g_Color[id][COLOR_FLARE][__R], g_Color[id][COLOR_FLARE][__G], g_Color[id][COLOR_FLARE][__B], NADE_TYPE_FLARE);
			}

			replaceWeaponModels(id, CSW_SMOKEGRENADE);
		}
	}

	return FMRES_IGNORED;
}

public fwd__CmdStartPre(const id, const uc_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;

	static iButton;
	static iOldButton;

	iButton = get_uc(uc_handle, UC_Buttons);
	iOldButton = entity_get_int(id, EV_INT_oldbuttons);

	if(g_SpecialMode[id] == MODE_NEMESIS && g_Bazooka[id] && g_CurrentWeapon[id] == CSW_SG550)
	{
		if(iButton & IN_ATTACK && !(iOldButton & IN_ATTACK))
			fireBazooka(id);
	}
	else if(g_Zombie[id] && !g_SpecialMode[id] && g_ZombieClass[id] == ZOMBIE_CLASS_FARAHON)
	{
		if((iButton & IN_RELOAD) && !(iOldButton & IN_RELOAD))
		{
			static Float:flGameTime;
			flGameTime = get_gametime();

			if((flGameTime - g_ZombieClassFarahon_LastUsed[id]) < 25.0)
			{
				dg_color_chat(id, _, "Debes esperar !g%0.0f segundos!y para volver a lanzar una bola de fuego", (25.0 - (flGameTime - g_ZombieClassFarahon_LastUsed[id])));
				return FMRES_IGNORED;
			}

			g_ZombieClassFarahon_LastUsed[id] = flGameTime;

			message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id);
			write_byte(1);
			write_byte(0);
			message_end();
			
			emit_sound(id, CHAN_ITEM, "zombie_plague/husk_pre_fire.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			set_task(1.0, "MakeFire", id);
		}

		if((iOldButton & IN_RELOAD) && !(iButton & IN_RELOAD))
		{
			if(task_exists(id))
			{
				dg_color_chat(id, _, "Puedes volver a utilizar tu habilidad");
				
				g_ZombieClassFarahon_LastUsed[id] = 0.0;
				
				emit_sound(id, CHAN_ITEM, "zombie_plague/husk_wind_down.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			
			message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id);
			write_byte(0);
			write_byte(0);
			message_end();
			
			remove_task(id);
		}
	}

	return FMRES_IGNORED;
}

public MakeFire(id)
{
	new Float:Origin[3];
	new Float:vAngle[3];
	new Float:flVelocity[3];
	
	// Get position from eyes
	get_user_eye_position(id, Origin);
	
	// Get View Angles
	entity_get_vector(id, EV_VEC_v_angle, vAngle);
	
	new NewEnt = create_entity("info_target");
	
	entity_set_string(NewEnt, EV_SZ_classname, "entZombieFarahon");
	entity_set_model(NewEnt, MODEL_FIRE);
	entity_set_size(NewEnt, Float:{ -1.5, -1.5, -1.5 }, Float:{ 1.5, 1.5, 1.5 });
	entity_set_origin(NewEnt, Origin);
	
	// Set Entity Angles (thanks to Arkshine)
	make_vector(vAngle);
	entity_set_vector(NewEnt, EV_VEC_angles, vAngle);
	
	entity_set_int(NewEnt, EV_INT_solid, SOLID_BBOX);
	
	entity_set_float(NewEnt, EV_FL_scale, 0.3);
	entity_set_int(NewEnt, EV_INT_spawnflags, SF_SPRITE_STARTON);
	entity_set_float(NewEnt, EV_FL_framerate, 25.0);
	set_rendering(NewEnt, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 255);
	
	entity_set_int(NewEnt, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(NewEnt, EV_ENT_owner, id);
	
	// Set Entity Velocity
	velocity_by_aim(id, 600, flVelocity);
	entity_set_vector(NewEnt, EV_VEC_velocity, flVelocity);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(NewEnt);
	write_short(g_Sprite_Laserbeam);
	write_byte(5);
	write_byte(6);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
	
	set_task(0.2, "effect_fire", NewEnt, _, _, "b");
	
	emit_sound(id, CHAN_ITEM, "zombie_plague/husk_fireball_fire.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(NewEnt, CHAN_ITEM, "zombie_plague/husk_fireball_loop.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public effect_fire(entity)
{
	if(!pev_valid(entity))
	{
		remove_task(entity);
		return;
	}
	
	static Float:originF[3];
	pev(entity, pev_origin, originF);
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, originF[0]);
	engfunc(EngFunc_WriteCoord, originF[1]);
	engfunc(EngFunc_WriteCoord, originF[2]+30);
	write_short(g_Sprite_Flame);
	write_byte(5);
	write_byte(200);
	message_end();
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_SMOKE);
	engfunc(EngFunc_WriteCoord, originF[0]);
	engfunc(EngFunc_WriteCoord, originF[1]);
	engfunc(EngFunc_WriteCoord, originF[2]);
	write_short(g_Sprite_Smoke);
	write_byte(13);
	write_byte(15);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, originF[0]);
	engfunc(EngFunc_WriteCoord, originF[0]);
	engfunc(EngFunc_WriteCoord, originF[0]);
	write_byte(25);
	write_byte(255);
	write_byte(128);
	write_byte(0);
	write_byte(2);
	write_byte(3);
	message_end();
}

public touch__Farahon(const ent, const id)
{
	if(!is_valid_ent(ent) || !g_IsAlive[id])
		return;

	fireExplode(ent, 0);
	remove_entity(ent);
}

public get_user_eye_position(id, Float:flOrigin[3])
{
	new Float:flViewOffs[3];
	entity_get_vector(id, EV_VEC_view_ofs, flViewOffs);
	entity_get_vector(id, EV_VEC_origin, flOrigin);
	xs_vec_add(flOrigin, flViewOffs, flOrigin);
}

public make_vector(Float:flVec[3])
{
	flVec[0] -= 30.0;
	engfunc(EngFunc_MakeVectors, flVec);
	flVec[0] = -(flVec[0] + 30.0);
}

public ham__PlayerSpawnPost(const id)
{
	if(!is_user_alive(id))
		return;
	
	new TeamName:iTeam;
	iTeam = get_member(id, m_iTeam);

	if(iTeam == TEAM_UNASSIGNED || iTeam == TEAM_SPECTATOR)
		return;

	g_IsAlive[id] = _:is_user_alive(id);

	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_BURN);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_IMMUNITY);
	remove_task(id + TASK_MADNESS_BOMB);
	remove_task(id + TASK_BUTTONED);
	remove_task(id + TASK_ZHEAVY_REMOVE_TRAMP);
	remove_task(id + TASK_ZBANCHEE_REMOVE_STAT);

	g_MadnessBomb_Count[id] = 0;
	g_MadnessBomb_Move[id] = 0;

	randomSpawn(id);

	set_task(0.4, "task__HideHUDs", id + TASK_SPAWN);

	if(g_Mode != MODE_ARMAGEDDON) {
		set_task(2.0, "task__RespawnUserCheck", id + TASK_SPAWN);
	} else {
		user_silentkill(id);

		dg_color_chat(id, _, "No podés revivir en mitad de un Armageddón");
		return;
	}

	if(!g_NewRound && !g_EndRound) {
		if(g_Mode == MODE_SURVIVOR) {
			g_RespawnAsZombie[id] = 1;
		} else if(g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_EXTREM) {
			g_RespawnAsZombie[id] = 0;
		}
	}

	if(g_RespawnAsZombie[id] && !g_NewRound) {
		resetVars(id, 0);

		zombieMe(id);
		return;
	}

	resetVars(id, 0);

	set_task(0.1, "task__ClearWeapons", id + TASK_SPAWN);
	set_task(0.2, "task__ShowMenuWeapons", id + TASK_SPAWN);

	if(g_HatNext[id]) {
		setHat(id, g_HatNext[id]);
	} else if(g_HatId[id]) {
		if(is_valid_ent(g_HatEnt[id])) {
			entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderNormal);
			entity_set_float(g_HatEnt[id], EV_FL_renderamt, 255.0);
		}
	}

	g_HumanClass[id] = g_HumanClassNext[id];

	set_user_health(id, humanHealth(id, g_HumanClass[id]));
	// set_user_armor(id, 0);
	g_Speed[id] = Float:humanSpeed(id, g_HumanClass[id]);
	set_user_gravity(id, Float:humanGravity(id, g_HumanClass[id]));

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	copy(g_ClassName[id], charsmax(g_ClassName[]), HUMAN_CLASSES[g_HumanClass[id]][humanClassName]);

	set_task(1.0, "task__SetClassHumans", id + TASK_SPAWN);

	if(!g_NewRound && iTeam != TEAM_CT)
	{
		remove_task(id + TASK_TEAM);

		setUserTeam(id, TEAM_CT);
		task__UserTeamUpdate(id);
	}

	static sCurrentModel[32];
	static iAlreadyHasModel;

	getUserModel(id, sCurrentModel, charsmax(sCurrentModel));
	iAlreadyHasModel = 0;

	if(equal(sCurrentModel, getUserHumanModel(id))) {
		iAlreadyHasModel = 1;
	}

	if(!iAlreadyHasModel) {
		copy(g_User_Model[id], charsmax(g_User_Model[]), getUserHumanModel(id));

		if(g_NewRound) {
			set_task((5.0 * MODELS_CHANGE_DELAY), "task__UserModelUpdate", id + TASK_MODEL);
		} else {
			task__UserModelUpdate(id + TASK_MODEL);
		}
	}

	set_user_rendering(id);
	turnOffFlashlight(id);

	new iWeaponEnt;
	iWeaponEnt = getCurrentWeaponEnt(id);

	if(pev_valid(iWeaponEnt)) {
		replaceWeaponModels(id, cs_get_weapon_id(iWeaponEnt));
	}

	checkLastZombie();
}

public ham__PlayerKilledPre(const victim, const killer, const shouldgib)
{
	g_IsAlive[victim] = 0;
	g_Immunity[victim] = 0;
	g_ImmunityFire[victim] = 0;
	g_ImmunityFrost[victim] = 0;
	g_MadnessBomb_Count[victim] = 0;
	g_MadnessBomb_Move[victim] = 0;
	g_ZombieClassBanchee_Stat[victim] = 0;
	g_ZombieClassBanchee_Enemy[victim] = 0;

	remove_task(victim + TASK_BUTTONED);
	remove_task(victim + TASK_ZHEAVY_REMOVE_TRAMP);
	remove_task(victim + TASK_ZBANCHEE_REMOVE_STAT);

	if(g_Zombie[victim])
	{
		remove_task(victim + TASK_BURN);
		remove_task(victim + TASK_IMMUNITY);
		remove_task(victim + TASK_MADNESS_BOMB);
		remove_task(victim + TASK_ZHEAVY_COOLDOWN);
		remove_task(victim + TASK_ZBANCHEE_START);
		remove_task(victim + TASK_ZVOODOO_COOLDOWN);
		remove_task(victim + TASK_ZLUSTY_INVI);
		remove_task(victim + TASK_ZLUSTY_INVI_WAIT);

		if(g_Frozen[victim])
		{
			remove_task(victim + TASK_FROZEN);
			removeFrostCube(victim);
		}

		if(g_SpecialMode[victim])
			SetHamParamInteger(3, 2);
	}

	set_user_rendering(victim);

	if(g_SpecialMode[victim] == MODE_JERUZALEM)
	{
		--g_VIPsDead;

		if(!g_VIPsDead)
			modeJeruzalemFinish(TEAM_TERRORIST);
	}

	if(victim == killer || !isUserValidConnected(killer))
		return;
	
	if(!g_Zombie[killer])
	{
		++g_Stats_General[killer][STATS_ZOMBIES_D];
		++g_Stats_General[victim][STATS_ZOMBIES_T];

		switch(g_Stats_General[killer][STATS_ZOMBIES_D])
		{
			case 15: setAchievement(killer, x15_ZOMBIES);
			case 30: setAchievement(killer, x30_ZOMBIES);
			case 50: setAchievement(killer, x50_ZOMBIES);
			case 80: setAchievement(killer, x80_ZOMBIES);
			case 110: setAchievement(killer, x110_ZOMBIES);
			case 220: setAchievement(killer, x220_ZOMBIES);
			case 320: setAchievement(killer, x320_ZOMBIES);
			case 450: setAchievement(killer, x450_ZOMBIES);
			case 500: setAchievement(killer, x500_ZOMBIES);
			case 600: setAchievement(killer, x600_ZOMBIES);
			case 1000: setAchievement(killer, x1000_ZOMBIES);
			case 2500: setAchievement(killer, x2500_ZOMBIES);
			case 5000: setAchievement(killer, x5000_ZOMBIES);
			case 10000: setAchievement(killer, x10000_ZOMBIES);
			case 15000: setAchievement(killer, x15000_ZOMBIES);
			case 20000: setAchievement(killer, x20000_ZOMBIES);
			case 25000: setAchievement(killer, x25000_ZOMBIES);
			case 35000: setAchievement(killer, x35000_ZOMBIES);
			case 50000: setAchievement(killer, x50000_ZOMBIES);
		}

		if(shouldgib == 1) {
			if(g_CurrentWeapon[killer] == CSW_KNIFE) {
				++g_Stats_General[killer][STATS_ZOMBIES_KNIFE_D];
				++g_Stats_General[victim][STATS_ZOMBIES_KNIFE_T];

				if(g_Stats_General[killer][STATS_ZOMBIES_KNIFE_D] == 1) {
					setAchievement(killer, AFILANDO_CUCHILLO);
				}

				if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD) {
					++g_Stats_General[killer][STATS_ZOMBIES_HEAD_D];
					++g_Stats_General[victim][STATS_ZOMBIES_HEAD_T];

					if(g_Stats_General[killer][STATS_ZOMBIES_HEAD_D] == 1000) {
						setAchievement(killer, LIDER_EN_CABEZAS);
					} else if(g_Stats_General[killer][STATS_ZOMBIES_HEAD_D] == 10000) {
						setAchievement(killer, AGUJEREANDO_CABEZAS);
					}
				}
			} else {
				if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD) {
					++g_Stats_General[killer][STATS_ZOMBIES_HEAD_D];
					++g_Stats_General[victim][STATS_ZOMBIES_HEAD_T];
				}
			}
		}
	} else {
		++g_Stats_General[killer][STATS_HUMANS_D];
		++g_Stats_General[victim][STATS_HUMANS_T];
	}

	if(!g_SpecialMode[killer])
	{
		giveExperience(killer, HAPPY_HOUR[g_HappyHour][hhExpKillReward]);
		g_AmmoPacks[killer] += g_RewardAmmoPacksKill[killer];
	}

	if(g_SpecialMode[victim]) {
		switch(g_SpecialMode[victim]) {
			case MODE_SURVIVOR: {
				++g_Stats_General[killer][STATS_SURVIVOR_D];

				switch(g_Stats_General[killer][STATS_SURVIVOR_D]) {
					case 10: setAchievement(killer, x10_SURVIVORS);
					case 25: setAchievement(killer, x25_SURVIVORS);
					case 50: setAchievement(killer, x50_SURVIVORS);
					case 100: setAchievement(killer, x100_SURVIVORS);
					case 200: setAchievement(killer, x200_SURVIVORS);
					case 300: setAchievement(killer, x300_SURVIVORS);
					case 400: setAchievement(killer, x400_SURVIVORS);
					case 500: setAchievement(killer, x500_SURVIVORS);
				}
			} case MODE_NEMESIS: {
				++g_Stats_General[killer][STATS_NEMESIS_D];

				switch(g_Stats_General[killer][STATS_NEMESIS_D]) {
					case 10: setAchievement(killer, x10_NEMESIS);
					case 25: setAchievement(killer, x25_NEMESIS);
					case 50: setAchievement(killer, x50_NEMESIS);
					case 100: setAchievement(killer, x100_NEMESIS);
					case 200: setAchievement(killer, x200_NEMESIS);
					case 300: setAchievement(killer, x300_NEMESIS);
					case 400: setAchievement(killer, x400_NEMESIS);
					case 500: setAchievement(killer, x500_NEMESIS);
				}
			} case MODE_JERUZALEM: {
				g_Points[killer] += 10;
				dg_color_chat(0, killer, "El zombie !t%s!y ganó !g+10 pU!y por matar a un !gVIP!y", g_User_Name[killer]);

				++g_VIPsKilled[killer];

				if(g_VIPsKilled[killer]) {
					if(g_VIPsKilled[killer] == 2) {
						setAchievement(killer, MODE_JERUZALEM_KILL_2VIP);
					} else {
						setAchievement(killer, MODE_JERUZALEM_KILL_1VIP);
					}
				}
			}
		}
	}
}

public ham__PlayerKilledPost(const victim) {
	checkLastZombie();

	set_task(random_float(0.5, 3.0), "task__RespawnUser", victim + TASK_SPAWN);
}

public ham__PlayerTakeDamagePre(const victim, const inflictor, const attacker, Float:damage, const damageType) {
	if(((g_NewRound || g_EndRound) || g_HumanClass[victim] == HUMAN_RADIACTIVO) && (damageType & DMG_FALL)) {
		return HAM_SUPERCEDE;
	}

	if(victim == attacker || !isUserValidConnected(attacker)) {
		return HAM_IGNORED;
	}

	if(g_NewRound || g_EndRound) {
		return HAM_SUPERCEDE;
	}

	if(g_Zombie[attacker] == g_Zombie[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_FirstInfect && (g_BubbleIn[victim] && !g_Immunity[attacker]) && (g_BubbleIn[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker])) {
		return HAM_SUPERCEDE;
	}

	if(g_Frozen[attacker] || g_Frozen[victim] || g_Immunity[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_ModeArmageddon_NoDamage) {
		return HAM_SUPERCEDE;
	}

	static iDamage;

	if(!g_Zombie[attacker]) {
		if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD) {
			++g_Stats_General[attacker][STATS_HEAD_D];
			++g_Stats_General[victim][STATS_HEAD_T];
		}

		damage += ((float(g_Level[attacker]) * get_pcvar_float(g_Cvar_DamageBase)) / 100.0);

		if(g_SpecialMode[attacker]) {
			damage *= 3.25;
		} else {
			if((g_CurrentWeapon[attacker] == CSW_KNIFE) && g_HumanClass[attacker] == 5) {
				damage *= 5.0;
			}

			if((g_CurrentWeapon[attacker] == CSW_AWP || g_CurrentWeapon[attacker] == CSW_SCOUT) && g_HumanClass[attacker] == 6) {
				damage *= 2.75;
			}

			if(g_CurrentWeapon[attacker] == CSW_MP5NAVY) {
				damage *= 1.075;
			}
		}

		g_Stats_DamageCount[attacker][0] += damage / DIV_DAMAGE;
		g_Stats_DamageCount[victim][1] += damage / DIV_DAMAGE;

		SetHamParamFloat(4, damage);
		iDamage = floatround(damage);

		if(!g_SpecialMode[attacker]) {
			g_AmmoDamage[attacker] += damage;

			while(g_AmmoDamage[attacker] >= 1000.0) {
				g_AmmoPacks[attacker] += g_RewardAmmoPacksDamage[attacker];
				g_AmmoDamage[attacker] -= 1000.0;
			}
		}

		g_ExpDamage[attacker] += damage;

		while(g_ExpDamage[attacker] >= 2500.0) {
			giveExperience(attacker, HAPPY_HOUR[g_HappyHour][hhExpDamage]);
			g_ExpDamage[attacker] -= 2500.0;
		}

		return HAM_IGNORED;
	}

	if(damageType & DMG_HEGRENADE) {
		return HAM_SUPERCEDE;
	}

	if(g_CurrentWeapon[attacker] == CSW_KNIFE) {
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

		switch(g_SpecialMode[attacker]) {
			case MODE_NEMESIS: {
				damage += (entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 250.0 : 500.0;
			}
		}

		SetHamParamFloat(4, damage);
		iDamage = floatround(damage);

		static iArmor;
		iArmor = get_user_armor(victim);

		if(iArmor > 0/* && !g_FirstZombie[attacker]*/) {
			static iRealDamage;
			iRealDamage = (iArmor - iDamage);

			g_Stats_General[attacker][STATS_ARMOR_D] += iDamage;
			g_Stats_General[victim][STATS_ARMOR_T] += iDamage;

			if(iRealDamage > 0) {
				set_user_armor(victim, iRealDamage);
			} else {
				cs_set_user_armor(victim, 0, CS_ARMOR_NONE);
			}

			return HAM_SUPERCEDE;
		}

		if(g_Mode == MODE_SWARM || g_Mode == MODE_PLAGUE || g_Mode == MODE_JERUZALEM || g_SpecialMode[attacker] || getHumans() == 1) {
			SetHamParamFloat(4, damage);
			return HAM_IGNORED;
		}

		zombieMe(victim, attacker);
	}

	return HAM_SUPERCEDE;
}

public ham__PlayerTakeDamagePost(const victim) {
	if((g_Zombie[victim] && g_LastZombie[victim]) ||
	(!g_Zombie[victim] && g_SpecialMode[victim])) {
		if(pev_valid(victim) != PDATA_SAFE) {
			return;
		}

		set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX);
	}
}

public ham__PlayerTraceAttackPre(const victim, const attacker, const Float:damage, Float:direction[3], const tracehandle, const damageType) {
	if(victim == attacker || !isUserValidConnected(attacker)) {
		return HAM_IGNORED;
	}

	if(g_NewRound || g_EndRound) {
		return HAM_SUPERCEDE;
	}

	if(g_Zombie[attacker] == g_Zombie[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_FirstInfect && (g_BubbleIn[victim] && !g_Immunity[attacker]) && (g_BubbleIn[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker])) {
		return HAM_SUPERCEDE;
	}

	if(g_Frozen[attacker] || g_Frozen[victim] || g_Immunity[victim]) {
		return HAM_SUPERCEDE;
	}

	if(g_ModeArmageddon_NoDamage) {
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

	if(!g_Zombie[victim] || !(damageType & DMG_BULLET)) {
		return HAM_IGNORED;
	}

	// if(!g_SpecialMode[victim] && (1<<get_tr2(traceHandle, TR_iHitgroup))) {
		// return HAM_SUPERCEDE;
	// }

	static iDucking;
	iDucking = entity_get_int(victim, EV_INT_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND);

	if(iDucking) {
		return HAM_IGNORED;
	}

	static vecOriginAttacker[3];
	static vecOriginVictim[3];

	get_user_origin(attacker, vecOriginAttacker);
	get_user_origin(victim, vecOriginVictim);

	if(get_distance(vecOriginVictim, vecOriginAttacker) > 500) {
		return HAM_IGNORED;
	}

	static Float:vecVelocity[3];
	entity_get_vector(victim, EV_VEC_velocity, vecVelocity);

	xs_vec_mul_scalar(direction, damage, direction);

	if(WEAPON_KNOCKBACK_POWER[g_CurrentWeapon[attacker]] > 0.0) {
		xs_vec_mul_scalar(direction, WEAPON_KNOCKBACK_POWER[g_CurrentWeapon[attacker]], direction);
	}

	if(iDucking) {
		xs_vec_mul_scalar(direction, 0.25, direction);
	}

	xs_vec_mul_scalar(direction, g_KnockBack[victim], direction);

	xs_vec_add(vecVelocity, direction, direction);
	direction[2] = vecVelocity[2];

	entity_set_vector(victim, EV_VEC_velocity, direction);
	return HAM_IGNORED;
}

public ham__PlayerResetMaxSpeedPost(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	set_user_maxspeed(id, g_Speed[id]);
}

public ham__UseStationaryPre(const entity, const caller, const activator, const use_type) {
	if(use_type == 2 && isUserValidConnected(caller) && g_Zombie[caller]) {
		return HAM_SUPERCEDE;
	}

	task__HideHUDs(caller + TASK_SPAWN);
	return HAM_IGNORED;
}

public ham__UseStationaryPost(const entity, const caller, const activator, const use_type) {
	if(use_type == 0 && isUserValidConnected(caller)) {
		replaceWeaponModels(caller, g_CurrentWeapon[caller]);

		task__HideHUDs(caller + TASK_SPAWN);
	}
}

public ham__UsePushablePre() {
	return HAM_SUPERCEDE;
}

public ham__TouchWeaponPre(const weapon, const id)
{
	if(!isUserValidConnected(id))
		return HAM_IGNORED;

	if(g_Zombie[id] || g_SpecialMode[id])
		return HAM_SUPERCEDE;

	return HAM_IGNORED;
}

public ham__ThinkGrenadePre(const entity) {
	if(!pev_valid(entity)) {
		return HAM_IGNORED;
	}

	new Float:fDamageTime;
	new Float:fCurrentTime;

	fDamageTime = entity_get_float(entity, EV_FL_dmgtime);
	fCurrentTime = get_gametime();

	if(fDamageTime > fCurrentTime) {
		return HAM_IGNORED;
	}

	switch(entity_get_int(entity, EV_NADE_TYPE)) {
		case NADE_TYPE_INFECTION: {
			infectionExplode(entity);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_KNOCKBACK: {
			knockBackExplode(entity);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_FIRE: {
			fireExplode(entity, 1);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_FROST: {
			frostExplode(entity);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_FLARE: {
			new iDuration;
			iDuration = entity_get_int(entity, EV_FLARE_DURATION);

			if(iDuration > 0) {
				if(iDuration == 1) {
					remove_entity(entity);
					return HAM_SUPERCEDE;
				}

				flareLighting(entity, iDuration);

				entity_set_int(entity, EV_FLARE_DURATION, --iDuration);
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 2.0);
			} else if((get_entity_flags(entity) & FL_ONGROUND) && get_speed(entity) < 10) {
				if(g_EndRound) {
					return HAM_SUPERCEDE;
				}

				emitSound(entity, CHAN_WEAPON, SOUND_GRENADE_FLARE);

				entity_set_int(entity, EV_FLARE_DURATION, 30);
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 0.1);
			} else {
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 1.0);
			}
		} case NADE_TYPE_GRENADE: {
			grenadeExplode(entity);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_BUBBLE: {
			new iDuration;
			iDuration = entity_get_int(entity, EV_FLARE_DURATION);

			if(iDuration > 0) {
				new i;

				if(iDuration == 1) {
					new iUsers[MAX_USERS];
					new Float:vecOrigin[3];
					new iVictim;
					new j;

					entity_get_vector(entity, EV_VEC_origin, vecOrigin);

					iVictim = -1;
					j = 0;

					while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 125.0)) != 0) {
						if(is_user_alive(iVictim) && !g_Zombie[iVictim]) {
							iUsers[j++] = iVictim;
						}
					}

					remove_entity(entity);

					for(i = 0; i < j; ++i) {
						g_BubbleIn[iUsers[i]] = 0;
					}

					return HAM_SUPERCEDE;
				}

				if(!(iDuration % 20)) {
					i = entity_get_edict(entity, EV_ENT_owner);
					flareLighting(entity, iDuration);
				}

				bubblePush(entity);

				entity_set_int(entity, EV_FLARE_DURATION, --iDuration);
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 0.1);
			} else if((get_entity_flags(entity) & FL_ONGROUND) && get_speed(entity) < 10) {
				if(g_EndRound) {
					return FMRES_SUPERCEDE;
				}

				emitSound(entity, CHAN_WEAPON, SOUND_GRENADE_BUBBLE);

				entity_set_model(entity, MODEL_BUBBLE);

				entity_set_vector(entity, EV_VEC_angles, Float:{0.0, 0.0, 0.0});

				new Float:vecColor[3];
				entity_get_vector(entity, EV_FLARE_COLOR, vecColor);

				entity_set_int(entity, EV_INT_renderfx, kRenderFxGlowShell);
				entity_set_vector(entity, EV_VEC_rendercolor, vecColor);
				entity_set_int(entity, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(entity, EV_FL_renderamt, 32.0);

				entity_set_int(entity, EV_FLARE_DURATION, 150);
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 0.01);
			} else {
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 0.5);
			}
		} case NADE_TYPE_MADNESS: {
			madnessExplode(entity);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_PIPE: {
			if(get_entity_flags(entity) & FL_ONGROUND) {
				entity_set_int(entity, EV_INT_solid, SOLID_BBOX);
			}

			static iDuration;
			iDuration = entity_get_int(entity, EV_FLARE_DURATION);

			if(iDuration > 0) {
				static Float:vecEntOrigin[3];
				entity_get_vector(entity, EV_VEC_origin, vecEntOrigin);

				static Float:vecOrigin[3];
				static Float:flDistance;

				if(iDuration == 1) {
					new id;
					id = entity_get_edict(entity, EV_ENT_owner);

					if(!is_user_connected(id)) {
						id = 0;
					}

					emitSound(entity, CHAN_WEAPON, SOUND_GRENADE);

					engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
					write_byte(TE_DLIGHT);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
					write_byte(30);
					write_byte(255);
					write_byte(0);
					write_byte(0);
					write_byte(5);
					write_byte(5);
					message_end();

					engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
					write_byte(TE_EXPLOSION);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
					engfunc(EngFunc_WriteCoord, vecEntOrigin[2] + 5.0);
					write_short(g_Sprite_Explosion);
					write_byte(50);
					write_byte(35);
					write_byte(0);
					message_end();

					new i;
					new iHealth;

					for(i = 1; i <= g_MaxUsers; ++i) {
						if(!g_IsAlive[i]) {
							continue;
						}

						if(!g_Zombie[i]) {
							continue;
						}

						if(g_SpecialMode[i]) {
							continue;
						}

						entity_get_vector(i, EV_VEC_origin, vecOrigin);

						flDistance = get_distance_f(vecEntOrigin, vecOrigin);

						if(flDistance >= 1000.0) {
							continue;
						}

						if(!id) {
							id = i;
						}

						iHealth = g_Health[i] - random_num(1000, 1100);

						if(iHealth > 0) {
							set_user_health(i, iHealth);
							g_Health[i] = iHealth;
						} else {
							ExecuteHamB(Ham_Killed, i, id, 2);
						}
					}

					remove_entity(entity);
					return HAM_SUPERCEDE;
				}

				static Float:vecDirection[3];
				static i;

				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
				write_byte(TE_DLIGHT);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
				write_byte(30);
				write_byte(255);
				write_byte(0);
				write_byte(0);
				write_byte(2);
				write_byte(0);
				message_end();

				for(i = 1; i <= g_MaxUsers; ++i) {
					if(!g_IsAlive[i]) {
						continue;
					}

					if(!g_Zombie[i]) {
						continue;
					}

					if(g_SpecialMode[i]) {
						continue;
					}

					entity_get_vector(i, EV_VEC_origin, vecOrigin);

					flDistance = get_distance_f(vecEntOrigin, vecOrigin);

					if(flDistance >= 1000.0) {
						continue;
					}

					xs_vec_sub(vecOrigin, vecEntOrigin, vecDirection);
					xs_vec_mul_scalar(vecDirection, -5.0, vecDirection);

					entity_set_vector(i, EV_VEC_velocity, vecDirection);
				}

				entity_set_int(entity, EV_FLARE_DURATION, --iDuration);
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 0.1);
			} else {
				emit_sound(entity, CHAN_WEAPON, SOUND_PIPE_BOMB, 1.0, ATTN_NORM, 0, PITCH_NORM);

				entity_set_int(entity, EV_FLARE_DURATION, 72);
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 0.1);
			}
		}
	}

	return HAM_IGNORED;
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

	/*static iOldButtonPressed;
	iOldButtonPressed = entity_get_int(id, EV_INT_oldbuttons);

	if(g_Zombie[id] && g_SpecialMode[id] && (iOldButtonPressed & IN_JUMP) && (iFlags & FL_ONGROUND)) {
		iOldButtonPressed &= ~IN_JUMP;

		entity_set_int(id, EV_INT_oldbuttons, iOldButtonPressed);
		entity_set_int(id, EV_INT_gaitsequence, 6);

		entity_set_float(id, EV_FL_frame, 0.0);
		return HAM_IGNORED;
	}*/

	if((entity_get_int(id, EV_INT_bInDuck) || iFlags & FL_DUCKING) && get_pdata_int(id, OFFSET_LONG_JUMP, OFFSET_LINUX) && entity_get_int(id, EV_INT_button) & IN_DUCK && entity_get_int(id, EV_INT_flDuckTime)) {
		static Float:vecVelocity[3];
		entity_get_vector(id, EV_VEC_velocity, vecVelocity);

		if(vector_length(vecVelocity) > 5) {
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
	if(g_InJump[id])
	{
		g_InJump[id] = 0;
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
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

	if(g_LongJump[id])
	{
		entity_set_float(id, EV_FL_fuser2, 0.0);

		if(entity_get_int(id, EV_INT_button) & 2)
		{
			static iFlags;
			iFlags = entity_get_int(id, EV_INT_flags);

			if(iFlags & FL_WATERJUMP)
				return;
			
			if(entity_get_int(id, EV_INT_waterlevel) >= 2)
				return;

			if(!(iFlags & FL_ONGROUND))
				return;

			static Float:fVelocity[3];
			entity_get_vector(id, EV_VEC_velocity, fVelocity);

			fVelocity[2] += 250.0;

			entity_set_vector(id, EV_VEC_velocity, fVelocity);
			entity_set_int(id, EV_INT_gaitsequence, 6);
		}
	}

	if(g_ZombieClassBanchee_Stat[id])
	{
		static iOwner;
		iOwner = g_ZombieClassBanchee_Enemy[id];

		if(isUserValidConnected(iOwner))
		{
			static Float:vecOriginOwn[3];
			static Float:vecVelocity[3];

			entity_get_vector(iOwner, EV_VEC_origin, vecOriginOwn);
			aimAtOrigin(id, vecOriginOwn, vecVelocity);
			engfunc(EngFunc_MakeVectors, vecVelocity);
			global_get(glb_v_forward, vecVelocity);

			vecVelocity[0] *= 100.0;
			vecVelocity[1] *= 100.0;
			vecVelocity[2] = 0.0;
			
			entity_set_vector(id, EV_VEC_velocity, vecVelocity);
		}
	}
}

public aimAtOrigin(const id, const Float:target[], Float:angles[])
{
	static Float:vecOrigin[3];
	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	vecOrigin[0] = (target[0] - vecOrigin[0]);
	vecOrigin[1] = (target[1] - vecOrigin[1]);
	vecOrigin[2] = (target[2] - vecOrigin[2]);

	engfunc(EngFunc_VecToAngles, vecOrigin, angles);

	angles[0] *= -1.0;
	angles[2] = 0.0;
}

public getUserAim(const id, const Float:distance, Float:vecOrigin[3])
{
	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	new Float:vecAngles[3];
	entity_get_vector(id, EV_VEC_v_angle, vecAngles);
	engfunc(EngFunc_MakeVectors, vecAngles);
	global_get(glb_v_forward, vecAngles);

	vecAngles[0] *= distance;
	vecAngles[1] *= distance;
	vecAngles[2] *= distance;

	vecOrigin[0] += vecAngles[0];
	vecOrigin[1] += vecAngles[1];
	vecOrigin[2] += vecAngles[2];
}

public getBrushOrigin(const target, Float:vecOrigin[3], const absolute)
{
	new Float:vecMins[3];
	new Float:vecMaxs[3];

	entity_get_vector(target, EV_VEC_origin, vecOrigin);
	entity_get_vector(target, EV_VEC_mins, vecMins);
	entity_get_vector(target, EV_VEC_maxs, vecMaxs);

	vecOrigin[0] = (vecMins[0] + vecMaxs[0]) / 2.0 + ((absolute) ? vecOrigin[0] : 0.0);
	vecOrigin[1] = (vecMins[1] + vecMaxs[1]) / 2.0 + ((absolute) ? vecOrigin[1] : 0.0);
	vecOrigin[2] = (vecMins[2] + vecMaxs[2]) / 2.0 + ((absolute) ? vecOrigin[2] : 0.0);
}

public ham__PlayerPreThinkPost(const id)
{
	DisableHamForward(g_HamPreThink);

	if(!g_IsAlive[id])
		task__RespawnUser(id + TASK_SPAWN);
}

public ham__WeaponPrimaryAttackPost(const weapon_ent) {
	if(!pev_valid(weapon_ent)) {
		return HAM_IGNORED;
	}

	static id;
	id = getWeaponEntId(weapon_ent);

	if(!isUserValidAlive(id) || g_Zombie[id] || g_SpecialMode[id]) {
		return HAM_IGNORED;
	}

	if(g_HumanClass[id] == 8) {
		if(cs_get_weapon_ammo(weapon_ent) < 1) {
			return HAM_IGNORED;
		}

		static Float:vecPunchangle[3];
		entity_get_vector(id, EV_VEC_punchangle, vecPunchangle);

		vecPunchangle[0] = vecPunchangle[0] - ((vecPunchangle[0] * 100.0) / 100.0);
		vecPunchangle[1] = vecPunchangle[1] - ((vecPunchangle[1] * 100.0) / 100.0);
		vecPunchangle[2] = vecPunchangle[2] - ((vecPunchangle[2] * 100.0) / 100.0);

		entity_set_vector(id, EV_VEC_punchangle, vecPunchangle);
	}

	return HAM_IGNORED;
}

public ham__AutomaticWeaponZoom(const weapon) {
	return HAM_SUPERCEDE;
}

public ham__ItemDeployPost(const weapon_ent) {
	static id;
	id = getWeaponEntId(weapon_ent);

	if(!pev_valid(id)) {
		return;
	}

	static iWeaponId;
	iWeaponId = cs_get_weapon_id(weapon_ent);

	g_CurrentWeapon[id] = iWeaponId;

	g_TypeWeapon[id] = ((1<<iWeaponId) & PRIMARY_WEAPONS_BIT_SUM) ? 1 : ((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM) ? 2 : 0;

	if(g_Zombie[id] && !((1<<iWeaponId) & ZOMBIE_ALLOWED_WEAPONS_BIT_SUM)) {
		g_CurrentWeapon[id] = CSW_KNIFE;
		engclient_cmd(id, "weapon_knife");
	}

	replaceWeaponModels(id, iWeaponId);
}

public ham__TouchZoneEscapePost(const zone, const id) {
	if(!is_valid_ent(zone)) {
		return HAM_IGNORED;
	}

	if(!isUserValidAlive(id)) {
		return HAM_IGNORED;
	}

	static sTargetName[12];
	entity_get_string(zone, EV_SZ_targetname, sTargetName, charsmax(sTargetName));

	if(equal(sTargetName, "")) {
		if(getAlives() < 4) {
			return HAM_SUPERCEDE;
		}

		if(g_Escaped[id]) {
			return HAM_SUPERCEDE;
		}

		++g_Stats_General[id][STATS_ESCAPE_D];

		switch(g_Stats_General[id][STATS_ESCAPE_D]) {
			case 40: setAchievement(id, x40_ESCAPES);
			case 100: setAchievement(id, x100_ESCAPES);
			case 180: setAchievement(id, x180_ESCAPES);
			case 280: setAchievement(id, x280_ESCAPES);
			case 400: setAchievement(id, x400_ESCAPES);
			case 540: setAchievement(id, x540_ESCAPES);
			case 700: setAchievement(id, x700_ESCAPES);
			case 800: setAchievement(id, x800_ESCAPES);
			case 1080: setAchievement(id, x1080_ESCAPES);
			case 1300: setAchievement(id, x1300_ESCAPES);
			case 2500: setAchievement(id, x2500_ESCAPES);
			case 5000: setAchievement(id, x5000_ESCAPES);
			case 7500: setAchievement(id, x7500_ESCAPES);
			case 12500: setAchievement(id, x12500_ESCAPES);
			case 30000: {
				setAchievement(id, x30000_ESCAPES);
				setAchievementFirst(id, PRIMERO_x30000_ESCAPES);
			}
			case 50000: setAchievement(id, x50000_ESCAPES);
			case 100000: {
				setAchievement(id, x100000_ESCAPES);
				setAchievementFirst(id, PRIMERO_x100000_ESCAPES);
			}
		}

		g_MapEscaped = 1;

		new iRewardPoints;
		new iRewardExp;
		new iRewardAPs;

		if(get_user_flags(id) & ADMIN_RESERVATION || get_user_flags(id) & ADMIN_IMMUNITY) {
			iRewardPoints = HAPPY_HOUR[g_HappyHour][hhPURewardEscape_Vip];
			iRewardExp = HAPPY_HOUR[g_HappyHour][hhExpRewardEscape_Vip];

			if(get_user_flags(id) & ADMIN_IMMUNITY) {
				iRewardAPs =  HAPPY_HOUR[g_HappyHour][hhAPsRewardEscape_Admin];
			} else {
				iRewardAPs =  HAPPY_HOUR[g_HappyHour][hhAPsRewardEscape_Vip];
			}
		} else {
			iRewardPoints = HAPPY_HOUR[g_HappyHour][hhPURewardEscape_Normal];
			iRewardExp = HAPPY_HOUR[g_HappyHour][hhExpRewardEscape_Normal];
			iRewardAPs =  HAPPY_HOUR[g_HappyHour][hhAPsRewardEscape_Normal];
		}

		giveExperience(id, iRewardExp);
		g_AmmoPacks[id] += iRewardAPs;
		g_Points[id] += iRewardPoints;

		dg_color_chat(id, _, "Has pasado la zona segura y has ganado !g%d EXP!y - !g%d APs!y - !g%d pU!y", iRewardExp, iRewardAPs, iRewardPoints);

		if(equali(g_MapName, "ze_dg_aztec_b1")) {
			setAchievementFirst(id, ESCAPISTA_PRO);
		}

		if(g_Mode == MODE_JERUZALEM) {
			modeJeruzalemFinish(TEAM_CT);
		}

		g_Escaped[id] = 1;
	}

	return HAM_IGNORED;
}

public ham__UseButtonPre(const this, const caller, const activator, const useType, const Float:value) {
	if(caller != activator) {
		return HAM_IGNORED;
	}

	if(entity_get_float(this, EV_FL_frame) > 0.0) {
		return HAM_IGNORED;
	}

	if(g_Zombie[caller]) {
		return HAM_IGNORED;
	}

	if(g_Buttoned[caller]) {
		return HAM_IGNORED;
	}

	g_Buttoned[caller] = 1;

	remove_task(caller + TASK_BUTTONED);
	set_task(10.0, "task__Buttoned", caller + TASK_BUTTONED);

	dg_color_chat(0, _, "!t%s!y ha usado un botón [!g%d!y]", g_User_Name[caller], this);

	if(g_EscapeButtonId != -1 && this == g_EscapeButtonId && !g_EscapeButtonAlreadyCalled) {
		g_EscapeButtonAlreadyCalled = true;

		if(g_VincAppMobile[caller]) {
			setAchievement(caller, APP_LAST_BUTTON);
		}
	}

	return HAM_IGNORED;
}

public task__Buttoned(taskId) {
	new id;
	id = taskId - TASK_BUTTONED;

	if(!is_user_alive(id)) {
		return;
	}

	g_Buttoned[id] = 0;
}

public ham__BreakableTakeDamagePost(const ent, const inflictor, const attacker, Float:damage, const damageBits) {
	if(!is_valid_ent(ent)) {
		return HAM_IGNORED;
	}

	if(isUserValidConnected(attacker)) {
		if(g_Breakabled[attacker] == 2) {
			return HAM_IGNORED;
		}

		new Float:flHealth;
		flHealth = entity_get_float(ent, EV_FL_health);

		if((flHealth - damage) < 0) {
			g_Breakabled[attacker] = 1;

			if(g_Breakabled[attacker] == 1) {
				g_Breakabled[attacker] = 2;
				dg_color_chat(0, _, "!t%s!y ha roto un objeto [!g%d!y]", g_User_Name[attacker], ent);
			}
		}
	}

	return HAM_IGNORED;
}

public touch__Supplybox(const box, const id) {
	if(!is_valid_ent(box) || !is_user_alive(id)) {
		return PLUGIN_CONTINUE;
	}

	if(g_Zombie[id] || g_SpecialMode[id]) {
		return PLUGIN_CONTINUE;
	}

	new iUsersPlaying = getPlaying();

	switch(entity_get_edict(box, EV_ENT_euser4)) {
		case 0: {
			ze_get_balrog1(id);
			dg_color_chat(id, _, "La caja tenía el arma !gBalrog I!y");
		} case 1: {
			ze_get_balrog11(id);
			dg_color_chat(id, _, "La caja tenía el arma !gBalrog XI!y");
		} case 2: {
			ze_get_plasmagun(id);
			dg_color_chat(id, _, "La caja tenía el arma !gPlasmaGun!y");
		} case 3: {
			ze_get_skull4(id);
			dg_color_chat(id, _, "La caja tenía el arma !gSkull-4!y");
		} case 4: {
			ze_get_thunderbolt(id);
			dg_color_chat(id, _, "La caja tenía el arma !gThunderbolt!y");
		} case 5: {
			if(iUsersPlaying >= 4) {
				++g_Points[id];
				dg_color_chat(id, _, "La caja tenía !g+1pU!y");
			} else {
				dg_color_chat(id, _, "La caja tenía !g+1pU!y pero no lo recibiste porque hay muy pocos jugadores conectados");
			}

		}
	}

	if(iUsersPlaying >= 8) {
		++g_Stats_General[id][STATS_SUPPLY_BOX_COLLECTED];

		if(iUsersPlaying >= 16) {
			++g_SBox_CollectedInSameRound[id];
		}
	}

	checkAchievementOfSupplyBoxes(id);

	emit_sound(box, CHAN_VOICE, SOUND_AMMOPICKUP, 1.0, ATTN_NORM, 0, PITCH_NORM);

	remove_entity(box);
	return PLUGIN_CONTINUE;
}

public touch__Rocket(const rocket, const toucher) {
	if(!is_valid_ent(rocket)) {
		return PLUGIN_CONTINUE;
	}

	new iAttacker;
	iAttacker = entity_get_edict(rocket, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(rocket);
		return PLUGIN_CONTINUE;
	}

	new Float:vecOrigin[3];
	entity_get_vector(rocket, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_ExplodeBazooka);
	write_byte(120);
	write_byte(10);
	write_byte(TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NODLIGHTS);
	message_end();

	emitSound(rocket, CHAN_WEAPON, SOUND_ROCKET_02);
	emitSound(rocket, CHAN_VOICE, SOUND_ROCKET_02);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_WORLDDECAL);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_byte(random_num(46, 48));
	message_end();

	createExplosion(vecOrigin, 255, 0, 0, 1);

	if((toucher > 0) && is_valid_ent(toucher)) {
		new sClassName[32];
		entity_get_string(toucher, EV_SZ_classname, sClassName, 31);

		if(equal(sClassName, "func_breakable")) {
			force_use(rocket, toucher);
		} else if(equal(sClassName, "player") && isUserValidAlive(toucher)) {
			if(!g_Zombie[toucher]) {
				ExecuteHamB(Ham_Killed, toucher, iAttacker, 2);
			}
		}
	}

	playSound(0, SOUND_ROCKET_02);

	new iVictim;
	new Float:flDistance;
	new Float:flDamage;
	new Float:flFadeAlpha;
	new Float:flVictimHealth;

	iVictim = -1;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 750.0)) != 0) {
		if(!isUserValidAlive(iVictim) || (g_Zombie[iVictim] && iVictim != iAttacker)) {
			continue;
		}

		flDistance = entity_range(rocket, iVictim);
		flDamage = floatradius(250.0, 750.0, flDistance);
		flFadeAlpha = floatradius(255.0, 750.0, flDistance);
		flVictimHealth = entity_get_float(iVictim, EV_FL_health);

		if(flDamage > 0) {
			if(flVictimHealth <= flDamage) {
				ExecuteHamB(Ham_Killed, iVictim, iAttacker, 2);
			} else {
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

	new iFlare;
	iFlare = entity_get_edict(rocket, EV_ENT_euser3);

	if(is_valid_ent(iFlare)) {
		remove_entity(iFlare);
	}

	remove_entity(rocket);
	return PLUGIN_CONTINUE;
}

stock Float:floatradius(Float:flMaxAmount, Float:flRadius, Float:flDistance) {
	return floatsub(flMaxAmount, floatmul(floatdiv(flMaxAmount, flRadius), flDistance));
}

public clcmd__CreatePassword(const id) {
	if(!g_IsConnected[id] || g_Account_Register[id]) {
		return PLUGIN_HANDLED;
	}

	static iLenName;
	iLenName = strlen(g_User_Name[id]);

	if(iLenName < 3) {
		playSound(id, SOUND_BUTTON_BAD);

		dg_color_chat(id, _, "Tu nombre debe contener +3 caracteres");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	} else if(iLenName > 20) {
		playSound(id, SOUND_BUTTON_BAD);

		dg_color_chat(id, _, "Tu nombre no debe contener +20 caracteres");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	if((containi(g_User_Name[id], "%%") != -1 || containi(g_User_Name[id], "%") != -1) || containi(g_User_Name[id], "#") != -1) {
		playSound(id, SOUND_BUTTON_BAD);

		dg_color_chat(id, _, "Tu nombre no debe contener los símbolos de porcentaje o numeral");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	static sPassword[24];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	if(contain(sPassword, "%") != -1) {
		playSound(id, SOUND_BUTTON_BAD);

		dg_color_chat(id, _, "Tu contraseña no puede contener el simbolo de porcentaje");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	static iLenPassword;
	iLenPassword = strlen(sPassword);

	if(iLenPassword < 4) {
		playSound(id, SOUND_BUTTON_BAD);

		dg_color_chat(id, _, "La clave debe tener al menos cuatro caracteres");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	} else if(iLenPassword > 23) {
		playSound(id, SOUND_BUTTON_BAD);

		dg_color_chat(id, _, "La clave no puede superar los veinticuatro caracteres");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	copy(g_Account_Password[id], charsmax(g_Account_Password[]), sPassword);

	client_cmd(id, "messagemode REPETIR_CONTRASENIA");
	playSound(id, SOUND_BUTTON_OK);

	dg_color_chat(id, _, "Escriba la clave nuevamente para su confirmación");
	return PLUGIN_HANDLED;
}

public clcmd__RepeatPassword(const id) {
	if(!g_IsConnected[id] || g_Account_Register[id]) {
		return PLUGIN_HANDLED;
	}

	static sPassword[24];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	if(!equal(g_Account_Password[id], sPassword)) {
		playSound(id, SOUND_BUTTON_BAD);

		g_Account_Password[id][0] = EOS;

		dg_color_chat(id, _, "La contraseña escrita no coincide con la anterior");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	g_AccountRegistering[id] = 1;

	static sMD5_Password[34];
	hash_string(sPassword, Hash_Md5, sMD5_Password, charsmax(sMD5_Password));
	sMD5_Password[6] = EOS;

	playSound(id, SOUND_BUTTON_OK);

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO ze1_users (`username`, `password`, `ip`) VALUES (^"%s^", ^"%s^", ^"%s^");", g_User_Name[id], sMD5_Password, g_User_Ip[id]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 5);
	} else {
		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id FROM ze1_users WHERE username=^"%s^";", g_User_Name[id]);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 10);
		} else if(SQL_NumResults(sqlQuery)) {
			g_Account_Id[id] = SQL_ReadResult(sqlQuery, 0);

			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO ze1_stats (`ze_id`) VALUES ('%d');", g_Account_Id[id]);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 15);
			} else {
				SQL_FreeHandle(sqlQuery);

				new sAccounts[8];
				addDot(g_Account_Id[id], sAccounts, charsmax(sAccounts));
				dg_color_chat(0, id, "Bienvenido !t%s!y, éres la cuenta registrada !g#%s!y", g_User_Name[id], sAccounts);

				if(g_Account_Id[id] == 100 || g_Account_Id[id] == 1000 || g_Account_Id[id] == 5000 || g_Account_Id[id] == 10000) {
					dg_color_chat(0, _, "Todos los jugadores conectados ganaron !g25 pU!y");

					new i;
					for(i = 1; i <= g_MaxUsers; ++i) {
						if(!g_IsConnected[i] || !g_Account_Logged[i]) {
							continue;
						}

						g_Points[i] += 25;
					}
				}

				g_Account_Register[id] = 1;
				g_Account_Logged[id] = 1;
				g_AccountJoined[id] = 1;

				g_SysTime_In[id] = get_systime();
			}
		} else {
			SQL_FreeHandle(sqlQuery);
			return PLUGIN_HANDLED;
		}

		remove_task(id + TASK_SAVE);
		set_task(random_float(300.0, 600.0), "task__SaveInfo", id + TASK_SAVE, .flags="b");

		resetInfo(id);
		client_cmd(id, "setinfo ze1 ^"%s^"", sMD5_Password);

		g_AccountRegistering[id] = 0;
		showMenu__Join(id);
	}

	return PLUGIN_HANDLED;
}

public clcmd__EnterPassword(const id) {
	if(!g_IsConnected[id] || !g_Account_Register[id] || g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	static sPassword[24];
	static sMD5_Password[34];

	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	hash_string(sPassword, Hash_Md5, sMD5_Password, charsmax(sMD5_Password));
	sMD5_Password[6] = EOS;

	if(!equal(g_Account_Password[id], sMD5_Password)) {
		playSound(id, SOUND_BUTTON_BAD);

		dg_color_chat(id, _, "La contraseña ingresada no coincide con la de esta cuenta");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	playSound(id, SOUND_BUTTON_OK);

	g_Account_Logged[id] = 1;
	g_AccountJoined[id] = 1;

	g_SysTime_In[id] = get_systime();

	resetInfo(id);
	client_cmd(id, "setinfo ze1 ^"%s^"", sMD5_Password);

	loadInfo(id);

	remove_task(id + TASK_SAVE);
	set_task(random_float(300.0, 600.0), "task__SaveInfo", id + TASK_SAVE, .flags="b");

	remove_task(id + TASK_HELLOAGAIN);
	set_task(random_float(5.0, 15.0), "task__HelloAgain", id + TASK_HELLOAGAIN);

	showMenu__Join(id);
	return PLUGIN_HANDLED;
}

public clcmd__NoClip(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id] || !checkScripterAccess(id)) {
		return PLUGIN_HANDLED;
	}

	if(!get_user_noclip(id)) {
		set_user_noclip(id, 1);
		set_user_godmode(id, 1);

		strip_user_weapons(id);

		entity_set_int(id, EV_INT_rendermode, kRenderTransAlpha);
		entity_set_float(id, EV_FL_renderamt, 0.0);

		entity_set_int(id, EV_INT_solid, SOLID_NOT);
	} else {
		set_user_noclip(id, 0);
		set_user_godmode(id, 0);

		give_item(id, "weapon_knife");

		entity_set_int(id, EV_INT_solid, SOLID_BBOX);
	}

	return PLUGIN_HANDLED;
}

public clcmd__Rank(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	dg_color_chat(id, _, "Tu ranking: !g%d !y/!g %d!y", g_Account_Rank[id], g_RankGlobal);
	return PLUGIN_HANDLED;
}

public clcmd__Invis(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	g_Invis[id] = !g_Invis[id];

	dg_color_chat(id, _, "Ahora los humanos son !g%svisibles!y", (g_Invis[id]) ? "in" : "");
	return PLUGIN_HANDLED;
}

public clcmd__EscapeTest(const id) {
	if(!g_IsConnected[id] || !checkScripterAccess(id)) {
		return PLUGIN_HANDLED;
	}

	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		g_Escaped[i] = 0;
	}

	return PLUGIN_HANDLED;
}

public clcmd__ShowLogs(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	menu__Join(id, 1);
	return PLUGIN_HANDLED;
}

public clcmd__Camera(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(!is_user_alive(id)) {
		dg_color_chat(id, _, "Debes estar vivo para usar este comando");
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

public clcmd__Block(const id)
	return PLUGIN_HANDLED;

// public clcmd__Drop(const id)
// {
	// if(!g_IsAlive[id])
	// {
		// dg_color_chat(id, _, "Debes estar vivo para utilizar este comando");
		// return PLUGIN_HANDLED;
	// }
	// else if(!g_Zombie[id] || g_SpecialMode[id])
	// {
		// dg_color_chat(id, _, "Debes ser zombie para utilizar este comando");
		// return PLUGIN_HANDLED;
	// }

	// return PLUGIN_CONTINUE;
// }

public clcmd__NightVision(const id) {
	if(task_exists(id + TASK_NVISION)) {
		remove_task(id + TASK_NVISION);
	} else {
		set_task(0.2, "setUserNightvision", id + TASK_NVISION, _, _, "b");
	}

	return PLUGIN_HANDLED;
}

public clcmd__ChangeTeam(const id)
{
	if(!g_AccountCheck[id])
		return PLUGIN_HANDLED;

	if(g_AccountRegistering[id])
	{
		client_print(id, print_center, "Registrando cuenta...");
		return PLUGIN_HANDLED;
	}
	else if(g_AccountLoading[id])
	{
		client_print(id, print_center, "Cargando cuenta...");
		return PLUGIN_HANDLED;
	}

	if(g_AllowChangeTeam[id])
		return PLUGIN_CONTINUE;

	if(!g_Account_Register[id] || !g_Account_Logged[id])
	{
		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	if(g_AccountJoined[id] == 1)
	{
		showMenu__Join(id);
		return PLUGIN_HANDLED;
	}

	new TeamName:iTeam;
	iTeam = get_member(id, m_iTeam);

	if(iTeam == TEAM_UNASSIGNED || iTeam == TEAM_SPECTATOR)
		return PLUGIN_CONTINUE;

	showMenu__Game(id);
	return PLUGIN_HANDLED;
}

public clcmd__MenuSelect(const id)
{
	if(get_pdata_int(id, OFFSET_CSMENUCODE) == 3 && get_pdata_int(id, OFFSET_JOINSTATE) == 4)
		EnableHamForward(g_HamPreThink);
}

public clcmd__Say(const id)
{
	if(!g_IsConnected[id])
		return PLUGIN_HANDLED;

	static sMsg[191];
	read_args(sMsg, charsmax(sMsg));

	replace_all(sMsg, charsmax(sMsg), "#", "");
	replace_all(sMsg, charsmax(sMsg), "%", "");
	replace_all(sMsg, charsmax(sMsg), "!y", "");
	replace_all(sMsg, charsmax(sMsg), "!t", "");
	replace_all(sMsg, charsmax(sMsg), "!g", "");

	if(equal(sMsg, "") || sMsg[0] == '/' || sMsg[0] == '@' || sMsg[0] == '!')
		return PLUGIN_HANDLED;

	remove_quotes(sMsg);
	trim(sMsg);

	static allMessage[191];

	if(!checkScripterAccess(id))
	{
		static TeamName:iTeam;
		iTeam = get_member(id, m_iTeam);

		if(iTeam == TEAM_TERRORIST || iTeam == TEAM_CT)
		{
			formatex(allMessage, 190, "%s^4%s^1[^4%s^1]^3 %s%s : %s", ((g_IsAlive[id]) ? "" : "^1(MUERTO) "), getUserAdmin(id), getUserRange(id), g_User_Name[id], (((get_user_flags(id) & ADMIN_LEVEL_A)) ? "^4" : "^1"), sMsg);
			client_print_color(0, id, allMessage);
		}
		else
		{
			if(g_Account_Logged[id])
				formatex(allMessage, 190, "^1(ESPECTADOR)^3 %s%s : %s", g_User_Name[id], (((get_user_flags(id) & ADMIN_LEVEL_A)) ? "^4" : "^1"), sMsg);
			else if(g_Account_Register[id])
				formatex(allMessage, 190, "^1(SIN IDENTIFICARSE)^3 %s%s : %s", g_User_Name[id], (((get_user_flags(id) & ADMIN_LEVEL_A)) ? "^4" : "^1"), sMsg);
			else
				formatex(allMessage, 190, "^1(SIN REGISTRARSE)^3 %s%s : %s", g_User_Name[id], (((get_user_flags(id) & ADMIN_LEVEL_A)) ? "^4" : "^1"), sMsg);

			client_print_color(0, id, allMessage);
		}
	}
	else
	{
		formatex(allMessage, 190, "^4%s^1 : %s", g_User_Name[id], sMsg);
		client_print_color(0, id, allMessage);
	}

	if(g_Secret_CrazyMode_Enabled && !g_Secret_AlreadySayCrazy[id])
	{
		if(containi(sMsg, "crazy") != -1)
		{
			g_Secret_AlreadySayCrazy[id] = true;
			++g_Secret_CrazyMode_Count;

			if(g_Secret_CrazyMode_Count >= 28)
				activateCrazyMode();
			else
				client_print(0, print_center, "%d", (28 - g_Secret_CrazyMode_Count));
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__SayTeam(const id)
	return PLUGIN_HANDLED;

public concmd__Supplybox(const id, const level, const cid)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;

	if(g_Account_Id[id] != 14131)
	{
		if(!cmd_access(id, level, cid, 1))
			return PLUGIN_HANDLED;
	}

	createSupplybox(id);
	return PLUGIN_HANDLED;
}

public createSupplybox(const id) {
	if(g_SupplyboxNums >= 6) {
		return;
	}

	new vecOriginId[3];
	new Float:vecOrigin[3];
	new Float:vecTargetOrigin[3];
	new Float:vecAngles[3];

	get_user_origin(id, vecOriginId, 3);
	IVecFVec(vecOriginId, vecOrigin);
	vecOrigin[2] += 5.0;

	new iEnt;
	iEnt = create_entity("info_target");

	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, "ent__Supplybox");
		dllfunc(DLLFunc_Spawn, iEnt);

		entity_set_model(iEnt, MODEL_SUPPLYBOX);
		entity_set_origin(iEnt, vecOrigin);

		entity_set_size(iEnt, Float:{-2.0, -2.0, -2.0}, Float:{5.0, 5.0, 5.0});

		entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

		drop_to_floor(iEnt);

		entity_set_size(iEnt, Float:{-2.0, -2.0, -2.0}, Float:{5.0, 5.0, 5.0});

		entity_get_vector(id, EV_VEC_origin, vecTargetOrigin);
		entitySetAim(iEnt, vecOrigin, vecTargetOrigin);

		entity_get_vector(iEnt, EV_VEC_angles, vecAngles);
		vecAngles[0] = 0.0;
		entity_set_vector(iEnt, EV_VEC_angles, vecAngles);

		entity_set_edict(iEnt, EV_ENT_euser4, g_SupplyboxNums);

		entity_set_int(iEnt, EV_INT_sequence, 0);
		entity_set_float(iEnt, EV_FL_animtime, get_gametime());
		entity_set_float(iEnt, EV_FL_framerate, 1.0);

		//set_rendering(iEnt, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16);
	}

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO ze1_supplybox (`box_id`, `box_origin_x`, `box_origin_y`, `box_origin_z`, `box_angles_x`, `box_angles_y`, `box_angles_z`, `box_mapname`) VALUES ('%d', '%f', '%f', '%f', '%f', '%f', '%f', ^"%s^");", g_SupplyboxNums, vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2], g_MapName);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 591723);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	++g_SupplyboxNums;
	dg_color_chat(id, _, "Has creado una caja con éxito");
}

entitySetAim(const iEnt, const Float:vecEntOrigin[3], const Float:vecTargetOrigin[3], const Float:fVelocity=0.0, const iAngleMode=0) { // s_esa
	static Float:vC[3];
	static Float:vD[3];

	xs_vec_sub(vecTargetOrigin, vecEntOrigin, vC);
	vector_to_angle(vC, vD);

	switch(iAngleMode) {
		case 1: {
			vD[0] = 0.0;
		} case 4: {
			vD[0] = 0.0;
			vD[1] += 180.0;
		} case 1337: {
			vD[0] = -45.0;
		}
	}

	entity_set_int(iEnt, EV_INT_fixangle, 1);

	entity_set_vector(iEnt, EV_VEC_angles, vD);
	entity_set_vector(iEnt, EV_VEC_v_angle, vD);

	entity_set_int(iEnt, EV_INT_fixangle, 1);

	if(fVelocity) {
		xs_vec_normalize(vC, vC);
		xs_vec_mul_scalar(vC, fVelocity, vC);

		if(iAngleMode) {
			vC[2] = 0.02;
		}

		entity_set_vector(iEnt, EV_VEC_velocity, vC);
	}
}

public concmd__Level(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iTarget) {
		dg_console_chat(id, "El usuario especificado no existe");
		return PLUGIN_HANDLED;
	}

	static sArg2[4];
	static iLevel;

	read_argv(2, sArg2, charsmax(sArg2));
	iLevel = str_to_num(sArg2);

	if(iLevel < 1 || iLevel > MAX_LEVEL) {
		dg_console_chat(id, "No puedes asignar niveles menor a 1 o mayor a %d", MAX_LEVEL);
		return PLUGIN_HANDLED;
	}

	g_Level[iTarget] = clamp(iLevel, 1, MAX_LEVEL);
	fixExperience(iTarget);

	dg_color_chat(iTarget, id, "!t%s!y te asignó al nivel !g%d!y", g_User_Name[id], g_Level[iTarget]);
	return PLUGIN_HANDLED;
}

public concmd__Exp(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iTarget) {
		dg_console_chat(id, "El usuario especificado no existe");
		return PLUGIN_HANDLED;
	}

	static sArg2[8];
	static iExp;

	read_argv(2, sArg2, charsmax(sArg2));
	iExp = str_to_num(sArg2);

	if(iExp < 0) {
		dg_console_chat(id, "No puedes asignar menos de 0 EXP");
		return PLUGIN_HANDLED;
	}

	g_Exp[iTarget] = clamp(iExp, 0, MAX_XP);

	dg_color_chat(iTarget, id, "!t%s!y te asignó a !g%d XP!y", g_User_Name[id], g_Exp[iTarget]);
	return PLUGIN_HANDLED;
}

public concmd__AmmoPacks(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iTarget) {
		dg_console_chat(id, "El usuario especificado no existe");
		return PLUGIN_HANDLED;
	}

	static sArg2[8];
	static iAmmoPacks;

	read_argv(2, sArg2, charsmax(sArg2));
	iAmmoPacks = str_to_num(sArg2);

	if(iAmmoPacks < 0) {
		dg_console_chat(id, "No puedes asignar menos de 0 ammo packs");
		return PLUGIN_HANDLED;
	}

	g_AmmoPacks[iTarget] = iAmmoPacks;

	dg_color_chat(iTarget, id, "!t%s!y te asignó a !g%d APs!y", g_User_Name[id], g_AmmoPacks[iTarget]);
	return PLUGIN_HANDLED;
}

public concmd__Points(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iTarget) {
		dg_console_chat(id, "El jugador especificado no existe");
		return PLUGIN_HANDLED;
	}

	static sArg2[8];
	static iPoints;

	read_argv(2, sArg2, charsmax(sArg2));
	iPoints = str_to_num(sArg2);

	if(!iPoints) {
		dg_console_chat(id, "No puedes otorgar 0 puntos");
		return PLUGIN_HANDLED;
	}

	g_Points[iTarget] = iPoints;

	dg_color_chat(iTarget, id, "!t%s!y te asignó !g%d pU!y", g_User_Name[id], g_Points[iTarget]);
	return PLUGIN_HANDLED;
}

new g_Temp_AchievementsIds;
public concmd__Achievements(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(read_argc() < 3) {
		g_Temp_AchievementsIds = 1;

		new i;
		for(i = 0; i < (50 * g_Temp_AchievementsIds); ++i) {
			dg_console_chat(id, "%d = %s", i, ACHS[i][achName]);
		}

		set_task(1.0, "sendInfo__Achievement", id);
		return PLUGIN_HANDLED;
	}

	if(!iTarget) {
		dg_console_chat(id, "El jugador especificado no existe");
		return PLUGIN_HANDLED;
	}

	static sArg2[8];
	static iAchievement;

	read_argv(2, sArg2, charsmax(sArg2));
	iAchievement = str_to_num(sArg2);

	if(contain(ACHS[iAchievement][achName], "PRIMERO:") == -1) {
		setAchievement(iTarget, iAchievement, 1);
	} else {
		setAchievementFirst(iTarget, iAchievement, 1);
	}

	return PLUGIN_HANDLED;
}

public sendInfo__Achievement(const id) {
	if(g_IsConnected[id]) {
		new i;
		new j = 50 * g_Temp_AchievementsIds;

		++g_Temp_AchievementsIds;

		new k = 50 * g_Temp_AchievementsIds;

		if(k > structIdAchievements) {
			k = structIdAchievements;
		}

		for(i = j; i < k; ++i) {
			console_print(id, "%d = %s", i, ACHS[i][achName]);
		}

		if(k == structIdAchievements) {
			return;
		}

		set_task(1.0, "sendInfo__Achievement", id);
	}
}

public concmd__Revive(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iTarget)
	{
		dg_console_chat(id, "El jugador especificado no existe");
		return PLUGIN_HANDLED;
	}

	if(g_EndRound)
	{
		dg_console_chat(id, "No puedes revivir en fin de ronda");
		return PLUGIN_HANDLED;
	}

	if(get_member(iTarget, m_iTeam) == TEAM_SPECTATOR || get_member(iTarget, m_iTeam) == TEAM_UNASSIGNED)
	{
		dg_console_chat(id, "El jugador especificado no está en un equipo actualmente");
		return PLUGIN_HANDLED;
	}

	respawnUser(iTarget);

	dg_color_chat(id, iTarget, "!t%s!y revivió a !g%s!y", g_User_Name[id], g_User_Name[iTarget]);
	return PLUGIN_HANDLED;
}

public concmd__Zombie(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}

	static sArg1[32];
	static iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));

	if(!iTarget) {
		dg_console_chat(id, "El jugador especificado no existe");
		return PLUGIN_HANDLED;
	}

	if(g_EndRound) {
		dg_console_chat(id, "No puedes convertir en zombie/humano en el final de ronda");
		return PLUGIN_HANDLED;
	}

	if(g_NewRound) {
		setMode(MODE_MULTI, iTarget, .fakeMode=true);
	} else {
		if(g_Zombie[iTarget]) {
			humanMe(iTarget);
		} else {
			zombieMe(iTarget);
		}
	}

	dg_color_chat(0, iTarget, "!t%s!y convirtió en %s a !g%s!y", g_User_Name[id], (g_Zombie[iTarget]) ? "zombie" : "humano", g_User_Name[iTarget]);
	return PLUGIN_HANDLED;
}

public concmd__Mode(const id, const level, const cid) {
	if(!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}

	static sArg0[24];
	read_argv(0, sArg0, charsmax(sArg0));

	if(!sArg0[0]) {
		return PLUGIN_HANDLED;
	}

	static iMode;
	iMode = MODE_NONE;

	if(equali(sArg0, "ze_multi")) {
		iMode = MODE_MULTI;
	} else if(equali(sArg0, "ze_swarm")) {
		iMode = MODE_SWARM;
	} else if(equali(sArg0, "ze_multi_original")) {
		iMode = MODE_MULTI_ORIGINAL;
	} else if(equali(sArg0, "ze_plague")) {
		iMode = MODE_PLAGUE;
	} else if(equali(sArg0, "ze_armageddon")) {
		iMode = MODE_ARMAGEDDON;
	} else if(equali(sArg0, "ze_survivor")) {
		iMode = MODE_SURVIVOR;
	} else if(equali(sArg0, "ze_nemesis")) {
		iMode = MODE_NEMESIS;
	} else if(equali(sArg0, "ze_nemesis_extrem")) {
		iMode = MODE_NEMESIS_EXTREM;
	} else if(equali(sArg0, "ze_jeruzalem")) {
		iMode = MODE_JERUZALEM;
	}

	if(iMode == MODE_NONE) {
		dg_console_chat(id, "No se ha seleccionado el modo correctamente");
		return PLUGIN_HANDLED;
	} else if(iMode == MODE_JERUZALEM && !(get_user_flags(id) & ADMIN_LEVEL_H)) {
		dg_console_chat(id, "Solo usuarios con rango DIRECTOR pueden lanzar este modo");
		return PLUGIN_HANDLED;
	}

	if(!checkScripterAccess(id)) {
		static iUsersNeed;
		iUsersNeed = __MODES[iMode][modeUsersNeed];

		if(getPlaying() < iUsersNeed) {
			dg_console_chat(id, "No puedes lanzar el modo por que el mismo requiere %d jugadores online", iUsersNeed);
			return PLUGIN_HANDLED;
		}
	}

	switch(iMode)
	{
		case MODE_SURVIVOR, MODE_NEMESIS:
		{
			static sArg1[32];
			read_argv(1, sArg1, charsmax(sArg1));

			if(!sArg1[0])
			{
				if(!task_exists(TASK_STARTMODE))
					return PLUGIN_HANDLED;

				remove_task(TASK_COUNTDOWN);
				remove_task(TASK_STARTMODE);

				setMode(iMode, .fakeMode=true);
				dg_color_chat(0, _, "!t%s!y comenzó el modo !g%s!y", g_User_Name[id], __MODES[iMode][modeName]);
			}
			else
			{
				static iTarget;
				iTarget = cmd_target(id, sArg1, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));

				if(!iTarget)
				{
					dg_console_chat(id, "El jugador especificado no existe");
					return PLUGIN_HANDLED;
				}

				if(task_exists(TASK_STARTMODE))
				{
					remove_task(TASK_COUNTDOWN);
					remove_task(TASK_STARTMODE);

					setMode(iMode, iTarget, .fakeMode=true);
				}
				else
				{
					if(iMode == MODE_NEMESIS)
						zombieMe(iTarget, .nemesis=1);
					else if(iMode == MODE_SURVIVOR)
						humanMe(iTarget, .survivor=1);
				}

				dg_color_chat(0, iTarget, "!t%s!y convirtió en %s a !g%s!y", g_User_Name[id], (iMode == MODE_SURVIVOR) ? "survivor" : "nemesis", g_User_Name[iTarget]);
			}
		}
		default:
		{
			remove_task(TASK_COUNTDOWN);
			remove_task(TASK_STARTMODE);

			setMode(iMode, .fakeMode=true);
			dg_color_chat(0, _, "!t%s!y comenzó el modo !g%s!y", g_User_Name[id], __MODES[iMode][modeName]);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__LogIn(const id)
{
	if(!g_IsConnected[id] || g_Account_Logged[id] || g_Account_Banned[id])
		return;

	static sMenu[200];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\y%s - %s \r(%s)^n\dby %s^n^n", PLUGIN_COMMUNITY_NAME, PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\%s Crear una cuenta^n", (g_Account_Register[id]) ? "d" : "w");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\%s Identificarse^n", (g_Account_Register[id]) ? "w" : "d");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "LogIn Menu");
}

public menu__LogIn(const id, const key)
{
	if(!g_IsConnected[id] || g_Account_Logged[id] || g_Account_Banned[id])
		return PLUGIN_HANDLED;

	switch(key)
	{
		case 0:
		{
			if(g_Account_Register[id])
			{
				playSound(id, SOUND_BUTTON_BAD);

				dg_color_chat(id, _, "Este nombre ya está siendo utilizado como personaje. Por lo tanto, está registrado");

				showMenu__LogIn(id);
				return PLUGIN_HANDLED;
			}

			playSound(id, SOUND_BUTTON_OK);

			client_cmd(id, "messagemode CREAR_CONTRASENIA");
			dg_color_chat(id, _, "Escribe la contraseña que protegerá a tu cuenta");
		}
		case 1:
		{
			if(!g_Account_Register[id])
			{
				playSound(id, SOUND_BUTTON_BAD);

				dg_color_chat(id, _, "Este nombre no está siendo utilizado como personaje. Por lo tanto, no está registrado");

				showMenu__LogIn(id);
				return PLUGIN_HANDLED;
			}

			playSound(id, SOUND_BUTTON_OK);

			client_cmd(id, "messagemode INGRESAR_CONTRASENIA");
			dg_color_chat(id, _, "Escribe la contraseña que protege tu cuenta");
		}
		default: showMenu__LogIn(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__Join(const id)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id] || g_Account_Banned[id])
		return;

	static sMenu[300];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\y%s - %s \r(%s)^n\dby %s^n^n", PLUGIN_COMMUNITY_NAME, PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wCUENTA\r:\y #%d^n", g_Account_Id[id]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVINCULADO AL FORO\r:\y %s \d(#%d)^n", ((g_Vinc[id]) ? "Si" : "No"), g_Vinc[id]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVINCULADO A LA APP MOBILE\r:\y %s^n^n", ((g_VincAppMobile[id]) ? "Si" : "No"));

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Entrar a jugar^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Ver cambios^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wForo\r:\y %s", PLUGIN_COMMUNITY_FORUM);

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "Join Menu");
}

public menu__Join(const id, const key)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id] || g_Account_Banned[id])
		return PLUGIN_HANDLED;

	switch(key)
	{
		case 0:
		{
			if(g_ModelHuman[id])
			{
				g_AccountJoined[id] = 2;
				setUserTeamForce(id, "5");
			}
			else
				showMenu__ChooseModel(id);
		}
		case 1:
		{
			new sTitle[64];
			new sUrl[256];

			formatex(sTitle, charsmax(sTitle), "%s - Cambios", PLUGIN_NAME);
			formatex(sUrl, charsmax(sUrl), "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=http://drunk-gaming.com/tops/01_zombie_escape/changelog.html^"></head><body><p>Cargando...</p></body></html>");
			
			show_motd(id, sUrl, sTitle);
		}
		default: showMenu__Join(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__ChooseModel(const id)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id] || g_Account_Banned[id] || g_AccountJoined[id] == 2)
		return;

	new iMenuId;
	iMenuId = menu_create("ELEGIR TU GÉNERO PARA TU SKIN DEFAULT", "menu__ChooseModel");

	menu_additem(iMenuId, "Hombre", "1");
	menu_additem(iMenuId, "Mujer", "2");

	menu_setprop(iMenuId, MPROP_EXIT, MEXIT_NEVER);

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId);
}

public menu__ChooseModel(const id, const menu, const item)
{
	if(!is_user_connected(id) || item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new sItem[3];
	new iDummy;
	new iItemId;

	menu_item_getinfo(menu, item, iDummy, sItem, 2, _, _, iDummy);
	DestroyLocalMenu(id, menu);

	iItemId = str_to_num(sItem);

	g_ModelHuman[id] = clamp(iItemId, ZE_MODEL_MAN, ZE_MODEL_WOMAN);
	dg_color_chat(id, _, "Has elegido el model por defecto de !g%s!y", (g_ModelHuman[id] == ZE_MODEL_MAN) ? "Humbre" : "Mujer");

	showMenu__Join(id);
	return PLUGIN_HANDLED;
}

public showMenu__Game(const id)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id] || g_Account_Banned[id])
		return;

	static sMenu[400];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\y%s - %s \r(%s)^n\dby %s^n^n", PLUGIN_COMMUNITY_NAME, PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w ARMAS^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.%s ARMAS ESPECIALES^n", (g_IsAlive[id] && !g_SpecialMode[id] && !g_NewRound && !g_EndRound) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r3.\w PERSONAJE^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r4.%s^n^n", (g_IsAlive[id] && isUserStuck(id)) ? "\w Destrabarme" : "\d No estás trabado");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r6.\w ESTADÍSTICAS^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r7.\w CONFIGURACIÓN^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r9.%s ADMINISTRACIÓN^n^n", (get_user_flags(id) & ADMIN_IMMUNITY) ? "\w" : "\d");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Salir");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "Game Menu");
}

public menu__Game(const id, const key)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id] || g_Account_Banned[id])
		return PLUGIN_HANDLED;

	switch(key)
	{
		case 0:
		{
			if(!g_IsAlive[id])
			{
				dg_color_chat(id, _, "Debes estar vivo para utilizar este menú");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			if(g_Zombie[id])
			{
				dg_color_chat(id, _, "Debes ser humano para utilizar este menú");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			if(g_Weapon_AutoBuy[id])
			{
				g_Weapon_AutoBuy[id] = 0;
				dg_color_chat(id, _, "Has re-activado la compra de armas. Vuelve a pulsar en el menú para elegir armas");

				if(g_NewRound)
				{
					g_WeaponPrimary_Bought[id] = 0;
					g_WeaponSecondary_Bought[id] = 0;

					showMenu__BuyPrimaryWeapon(id);
					return PLUGIN_HANDLED;
				}

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			if(checkWeaponBuy(id))
			{
				dg_color_chat(id, _, "Ya has realizado la compra. Espera al próximo respawn humano para elegir armas");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			showMenu__BuyPrimaryWeapon(id);
		}
		case 1:
		{
			if(!g_IsAlive[id])
			{
				dg_color_chat(id, _, "Debes estar vivo para utilizar este menú");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			if(g_SpecialMode[id])
			{
				dg_color_chat(id, _, "Sólo los humanos/zombies pueden utilizar este menú");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			if(g_NewRound || g_EndRound)
			{
				dg_color_chat(id, _, "No puedes utilizar este menú en el inicio/final de la ronda");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			showMenu__ExtraItems(id);
		}
		case 2: showMenu__Character(id);
		case 3:
		{
			if(!g_IsAlive[id])
			{
				dg_color_chat(id, _, "Debes estar vivo para utilizar esta función");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			if(!isUserStuck(id))
			{
				dg_color_chat(id, _, "No estás trabado");

				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}

			randomSpawn(id);
		}
		case 5: showMenu__Stats(id);
		case 6: showMenu__Config(id);
		case 8:
		{
			if(get_user_flags(id) & ADMIN_IMMUNITY)
				showMenu__Admin(id);
			else
				dg_color_chat(id, _, "No tienes acceso a este menú");
		}
		case 9: return PLUGIN_HANDLED;
		default: showMenu__Game(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__BuyPrimaryWeapon(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	if(g_WeaponPrimary_Bought[id]) {
		showMenu__BuySecondaryWeapon(id);
		return;
	}

	static sMenu[350];
	static iStartLoop;
	static iEndLoop;
	static iLen;
	static i;
	static j;

	iLen = 0;
	j = 0;

	iStartLoop = (g_MenuPage[id][PAGE_PRIMARY_WEAPON] * 7);
	iEndLoop = clamp(((g_MenuPage[id][PAGE_PRIMARY_WEAPON] + 1) * 7), 0, sizeof(PRIMARY_WEAPONS));

	iLen = formatex(sMenu, charsmax(sMenu), "\yARMAS PRIMARIAS \r[%d - %d]^n^n", (iStartLoop + 1), iEndLoop);

	for(i = iStartLoop; i < iEndLoop; ++i) {
		++j;

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r%d.\w %s^n", j, PRIMARY_WEAPONS[i][weaponName]);
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r8.\w ¿ Recordar compra ? \y[%s]^n", (g_Weapon_AutoBuy[id]) ? "SI" : "NO");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r9.\w SIGUIENTE / ATRÁS");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r0.\w VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Buy Primary Weapon Menu");
}

public menu__BuyPrimaryWeapon(const id, const key) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_WeaponPrimary_Bought[id]) {
		showMenu__BuySecondaryWeapon(id);
		return PLUGIN_HANDLED;
	}

	static iSelection;
	static iWeapons;

	iSelection = (g_MenuPage[id][PAGE_PRIMARY_WEAPON] * 7) + key;
	iWeapons = sizeof(PRIMARY_WEAPONS);

	if(key >= 7 || iSelection >= iWeapons) {
		switch(key) {
			case 7: {
				g_Weapon_AutoBuy[id] = !g_Weapon_AutoBuy[id];
			} case 8: {
				if(((g_MenuPage[id][PAGE_PRIMARY_WEAPON] + 1) * 7) < iWeapons) {
					++g_MenuPage[id][PAGE_PRIMARY_WEAPON];
				} else {
					g_MenuPage[id][PAGE_PRIMARY_WEAPON] = 0;
				}
			} case 9: {
				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}
		}

		showMenu__BuyPrimaryWeapon(id);
		return PLUGIN_HANDLED;
	}

	g_WeaponPrimary_Selection[id] = iSelection;

	showMenu__BuySecondaryWeapon(id);

	g_WeaponPrimary_Bought[id] = 1;
	return PLUGIN_HANDLED;
}

public showMenu__BuySecondaryWeapon(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	if(g_WeaponSecondary_Bought[id]) {
		showMenu__Game(id);

		dg_color_chat(id, _, "Ya has realizado la compra. Espera al próximo respawn humano para elegir armas");
		return;
	}

	static sMenu[500];
	static iStartLoop;
	static iEndLoop;
	static iLen;
	static i;
	static j;

	iLen = 0;
	j = 0;

	iStartLoop = (g_MenuPage[id][PAGE_SECONDARY_WEAPON] * 7);
	iEndLoop = clamp(((g_MenuPage[id][PAGE_SECONDARY_WEAPON] + 1) * 7), 0, sizeof(SECONDARY_WEAPONS));

	iLen = formatex(sMenu, charsmax(sMenu), "\yARMAS SECUNDARIAS \r[%d - %d]^n^n", (iStartLoop + 1), iEndLoop);

	for(i = iStartLoop; i < iEndLoop; ++i) {
		++j;

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r%d.\w %s^n", j, SECONDARY_WEAPONS[i][weaponName]);
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r8.\w ¿ Recordar compra ? \y[%s]^n", (g_Weapon_AutoBuy[id]) ? "SI" : "NO");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r9.\w SIGUIENTE / ATRÁS");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r0.\w VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Buy Secondary Weapon Menu");
}

public menu__BuySecondaryWeapon(const id, const keyId) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_WeaponSecondary_Bought[id]) {
		showMenu__Game(id);

		dg_color_chat(id, _, "Ya has realizado la compra. Espera al próximo respawn humano para elegir armas");
		return PLUGIN_HANDLED;
	}

	static iSelection;
	static iWeapons;

	iSelection = (g_MenuPage[id][PAGE_SECONDARY_WEAPON] * 7) + keyId;
	iWeapons = sizeof(SECONDARY_WEAPONS);

	if(keyId >= 7 || iSelection >= iWeapons) {
		switch(keyId) {
			case 7: {
				g_Weapon_AutoBuy[id] = !g_Weapon_AutoBuy[id];
			} case 8: {
				if(((g_MenuPage[id][PAGE_SECONDARY_WEAPON] + 1) * 7) < iWeapons) {
					++g_MenuPage[id][PAGE_SECONDARY_WEAPON];
				} else {
					g_MenuPage[id][PAGE_SECONDARY_WEAPON] = 0;
				}
			} case 9: {
				showMenu__Game(id);
				return PLUGIN_HANDLED;
			}
		}

		showMenu__BuySecondaryWeapon(id);
		return PLUGIN_HANDLED;
	}

	g_WeaponSecondary_Selection[id] = iSelection;

	if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] || checkWeaponBuy(id)) {
		return PLUGIN_HANDLED;
	}

	buyPrimaryWeapon(id, g_WeaponPrimary_Selection[id]);
	buySecondaryWeapon(id, g_WeaponSecondary_Selection[id]);

	g_WeaponSecondary_Bought[id] = 1;

	iSelection = 0;
	static i;

	for(i = 0; i < sizeof(GRENADES); ++i) {
		if(g_Level[id] >= GRENADES[iSelection][grenadeLevel]) {
			iSelection = i;
		}
	}

	if(GRENADES[iSelection][grenadeAmountHe]) {
		give_item(id, "weapon_hegrenade");
		cs_set_user_bpammo(id, CSW_HEGRENADE, GRENADES[iSelection][grenadeAmountHe]);
	}

	if(GRENADES[iSelection][grenadeAmountFb]) {
		give_item(id, "weapon_flashbang");
		cs_set_user_bpammo(id, CSW_FLASHBANG, GRENADES[iSelection][grenadeAmountFb]);
	}

	if(GRENADES[iSelection][grenadeAmountSg]) {
		give_item(id, "weapon_smokegrenade");
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, GRENADES[iSelection][grenadeAmountSg]);

		g_GrenadeBomb[id] += GRENADES[iSelection][grenadeAmountSg];
	}

	return PLUGIN_HANDLED;
}

public showMenu__ExtraItems(const id)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id])
		return;

	if(!g_IsAlive[id] || g_SpecialMode[id] || g_NewRound || g_EndRound)
	{
		showMenu__Game(id);
		return;
	}

	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static iTeam;
	static iCost;
	static i;

	iMenuId = menu_create("ITEMS EXTRAS\R", "menu__ExtraItems");

	for(i = 0; i < sizeof(EXTRA_ITEMS); ++i)
	{
		iCost = EXTRA_ITEMS[i][extraItemCost];
		iTeam = EXTRA_ITEMS[i][extraItemTeam];

		if((!g_Zombie[id] && iTeam == ZP_TEAM_ZOMBIE) || (g_Zombie[id] && iTeam == ZP_TEAM_HUMAN))
			continue;

		formatex(sMenu, charsmax(sMenu), "%s \y[%d APs]", EXTRA_ITEMS[i][extraItemName], iCost);

		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, sMenu, sItem, .callback=(g_AmmoPacks[id] >= iCost) ? -1 : g_MenuDisabled);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId);
}

public menu__ExtraItems(const id, const menu, const item)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(!g_IsAlive[id] || g_SpecialMode[id] || g_NewRound || g_EndRound || item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	static iItemId;

	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if(iItemId == -1)
	{
		dg_color_chat(id, _, "Hubo un error al seleccionar un ITEM del menú");

		showMenu__ExtraItems(id);
		return PLUGIN_HANDLED;
	}

	buyExtraItem(id, iItemId, 0);
	return PLUGIN_HANDLED;
}

public buyExtraItem(const id, const itemId, const ignoreCost)
{
	static iCost;
	static iTeam;

	iCost = EXTRA_ITEMS[itemId][extraItemCost];
	iTeam = EXTRA_ITEMS[itemId][extraItemTeam];

	if((!g_Zombie[id] && iTeam == ZP_TEAM_ZOMBIE) || (g_Zombie[id] && iTeam == ZP_TEAM_HUMAN))
	{
		dg_color_chat(id, _, "No puedes comprar ITEM humanos siendo zombie o ITEMS zombies siendo humano");

		showMenu__ExtraItems(id);
		return;
	}

	if(!ignoreCost)
	{
		if((g_AmmoPacks[id] - iCost) < 0.0)
		{
			dg_color_chat(id, _, "No tenés suficientes ammo packs");

			showMenu__ExtraItems(id);
			return;
		}
	}

	new iOk_UnlimitedClip = 0;

	switch(itemId)
	{
		case EXTRA_ITEM_ANTIDOTE:
		{
			if(!checkScripterAccess(id))
			{
				if(g_Antidote_Available)
				{
					if(getZombies() == 1 || getHumans() == 1)
					{
						dg_color_chat(id, _, "No puedes comprar este ITEM cuando hay un único humano/zombie vivo");

						showMenu__ExtraItems(id);
						return;
					}

					if(g_Mode != MODE_MULTI && g_Mode != MODE_MULTI_ORIGINAL)
					{
						dg_color_chat(id, _, "No puedes comprar este ITEM en este modo");

						showMenu__ExtraItems(id);
						return;
					}
				}

				dg_color_chat(0, id, "El usuario !t%s!y compró un antidoto", g_User_Name[id]);
			}

			humanMe(id);
		}
		case EXTRA_ITEM_MADNESS:
		{
			if(!checkScripterAccess(id))
			{
				if(g_Mode != MODE_MULTI && g_Mode != MODE_MULTI_ORIGINAL)
				{
					dg_color_chat(id, _, "No puedes comprar este ITEM en este modo");

					showMenu__ExtraItems(id);
					return;
				}
			}

			g_Immunity[id] = 1;
			g_MadnessBomb_Count[id] = 0;
			g_MadnessBomb_Move[id] = 0;

			if(g_Frozen[id])
			{
				remove_task(id + TASK_FROZEN);
				task__RemoveFreeze(id + TASK_FROZEN);
			}

			remove_task(id + TASK_MADNESS_BOMB);
			remove_task(id + TASK_MADNESS);

			set_task(6.0, "task__RemoveMadness", id + TASK_MADNESS);

			emitSound(id, CHAN_BODY, SOUND_ZOMBIE_MADNESS);
		}
		case EXTRA_ITEM_INFECTION_BOMB:
		{
			if(!checkScripterAccess(id))
			{
				if(g_ExtraItem_InfectionBomb)
				{
					dg_color_chat(id, _, "Ya compraron la bomba de infección");

					showMenu__ExtraItems(id);
					return;
				}

				if(g_Mode != MODE_MULTI && g_Mode != MODE_MULTI_ORIGINAL)
				{
					dg_color_chat(id, _, "No puedes comprar este ITEM en este modo");

					showMenu__ExtraItems(id);
					return;
				}

				if(g_KnockBackBomb[id])
				{
					dg_color_chat(id, _, "No podes comprar este ITEM ya que tienes la bomba Knockback");

					showMenu__ExtraItems(id);
					return;
				}

				++g_ExtraItem_InfectionBomb;
			}

			if(user_has_weapon(id, CSW_HEGRENADE))
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1);
			else
				give_item(id, "weapon_hegrenade");
		}
		case EXTRA_ITEM_BUBBLE_BOMB:
		{
			if(!checkScripterAccess(id))
			{
				if(g_ExtraItem_BubbleBomb)
				{
					dg_color_chat(id, _, "Ya compraron Campo de Fuerza");

					showMenu__ExtraItems(id);
					return;
				}

				if(g_BubbleBomb[id])
				{
					dg_color_chat(id, _, "Ya posees un Campo de Fuerza");

					showMenu__ExtraItems(id);
					return;
				}

				++g_ExtraItem_BubbleBomb;
				++g_BubbleBomb[id];
			}

			if(user_has_weapon(id, CSW_SMOKEGRENADE))
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1);
			else
				give_item(id, "weapon_smokegrenade");
		}
		case EXTRA_ITEM_ANTI_FIRE:
		{
			if(g_ImmunityFire[id])
			{
				dg_color_chat(id, _, "Ya posees anti incendiaria");

				showMenu__ExtraItems(id);
				return;
			}

			g_ImmunityFire[id] = 1;
		}
		case EXTRA_ITEM_ANTI_FROST:
		{
			if(g_ImmunityFrost[id])
			{
				dg_color_chat(id, _, "Ya posees anti incendiaria");

				showMenu__ExtraItems(id);
				return;
			}

			g_ImmunityFrost[id] = 1;
		}
		case EXTRA_ITEM_MADNESS_BOMB:
		{
			if(!checkScripterAccess(id))
			{
				if(g_ExtraItem_MadnessBomb)
				{
					dg_color_chat(id, _, "Ya compraron Bomba de Droga");

					showMenu__ExtraItems(id);
					return;
				}

				if(g_MadnessBomb[id])
				{
					dg_color_chat(id, _, "Ya posees una bomba de droga");

					showMenu__ExtraItems(id);
					return;
				}

				++g_ExtraItem_MadnessBomb;
				++g_MadnessBomb[id];
			}

			if(user_has_weapon(id, CSW_HEGRENADE))
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1);
			else
				give_item(id, "weapon_hegrenade");
		}
		case EXTRA_ITEM_BALROG_I:
		{
			dropWeapons(id, 2);
			ze_get_balrog1(id);
		}
		case EXTRA_ITEM_BALROG_XI:
		{
			dropWeapons(id, 1);
			ze_get_balrog11(id);
		}
		case EXTRA_ITEM_PLASMAGUN:
		{
			dropWeapons(id, 1);
			ze_get_plasmagun(id);
		}
		case EXTRA_ITEM_SKULL_IV:
		{
			dropWeapons(id, 1);
			ze_get_skull4(id);
		}
		case EXTRA_ITEM_THUNDERBOLT:
		{
			dropWeapons(id, 1);
			ze_get_thunderbolt(id);
		}
		case EXTRA_ITEM_UNLIMITED_CLIP:
		{
			if(g_UnlimitedClip_Available)
			{
				if(g_UnlimitedClip[id])
					iOk_UnlimitedClip = 1;
				else
				{
					g_UnlimitedClip[id] = true;
					iOk_UnlimitedClip = 0;
				}
			}
			else
				dg_color_chat(id, _, "Las balas infinitas están desactivadas en este mapa");
		}
	}

	if(!ignoreCost || iOk_UnlimitedClip)
		g_AmmoPacks[id] -= iCost;
}

public canBuyUnlimitedClips()
	return (equal(g_MapName, "ze_black_hawk_warz") || equal(g_MapName, "ze_atix_panic_v1") || equal(g_MapName, "zm_atix_helicopter") || equal(g_MapName, "zm_chavo_helicopter_lg"));

public showMenu__Character(const id) {
	static iMenuId;
	iMenuId = menu_create("CLASES / APARIENCIAS / LOGROS", "menu__Character");

	menu_additem(iMenuId, "Elegir clase", "1");
	menu_additem(iMenuId, "Apariencias", "2");
	menu_additem(iMenuId, "Logros", "3");
	menu_additem(iMenuId, "Meta-Logros", "4");

	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	ShowLocalMenu(id, iMenuId);
}

public menu__Character(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	static iItemId;

	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = str_to_num(sItem);

	switch(iItemId) {
		case 1: { // ELEGIR CLASE
			showMenu__ChooseClass(id);
		} case 2: { // APARIENCIAS
			showMenu__Upgrades(id);
		} case 3: { // LOGROS
			showMenu__AchClass(id);
		} case 4: { // META-LOGROS
			showMenu__MetaAchievements(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__ChooseClass(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static iMenuId;
	iMenuId = menu_create("ELEGIR CLASE", "menu__ChooseClass");

	menu_additem(iMenuId, "Humana", "1");
	menu_additem(iMenuId, "Zombie", "2");
	menu_additem(iMenuId, "Survivor", "3");
	menu_additem(iMenuId, "Nemesis", "4");

	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	ShowLocalMenu(id, iMenuId);
}

public menu__ChooseClass(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	static iItemId;

	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = str_to_num(sItem);

	switch(iItemId) {
		case 1: { // CLASES HUMANAS
			showMenu__ChooseHumanClass(id);
		} case 2: { // CLASES ZOMBIES
			showMenu__ChooseZombieClass(id);
		} case 3: { // CLASES SURVIVORS
			showMenu__ChooseSurvivorClass(id);
		} case 4: { // CLASES NEMESIS
			showMenu__ChooseNemesisClass(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__ChooseHumanClass(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static i;

	iMenuId = menu_create("CLASES HUMANAS\R", "menu__ChooseHumanClass");

	for(i = 0; i < sizeof(HUMAN_CLASSES); ++i) {
		if(g_HumanClass[id] == i) {
			formatex(sMenu, charsmax(sMenu), "\d%s \y(ACTUAL)", HUMAN_CLASSES[i][humanClassName]);
		} else if(g_HumanClassNext[id] == i) {
			formatex(sMenu, charsmax(sMenu), "\d%s \y(ELEGIDO)", HUMAN_CLASSES[i][humanClassName]);
		} else {
			formatex(sMenu, charsmax(sMenu), "\w%s \y(%s)", HUMAN_CLASSES[i][humanClassName], HUMAN_CLASSES[i][humanClassInfo]);
		}

		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, sMenu, sItem);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGUIENTE");

	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage[id][PAGE_HUMAN_CLASSES] = min(g_MenuPage[id][PAGE_HUMAN_CLASSES], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_HUMAN_CLASSES]);
}

public menu__ChooseHumanClass(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_HUMAN_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__ChooseClass(id);
		return PLUGIN_HANDLED;
	}

	new sItem[3];
	menu_item_getinfo(menu, item, iItemId, sItem, 2, _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if(g_HumanClass[id] == iItemId) {
		dg_color_chat(id, _, "Ya tienes puesta la clase humana !t%s!y", HUMAN_CLASSES[iItemId][humanClassName]);
	} else if(g_HumanClassNext[id] == iItemId) {
		dg_color_chat(id, _, "Ya has elegido la clase humana !t%s!y. Espera a tu próximo respawn humano para obtenerlo", HUMAN_CLASSES[iItemId][humanClassName]);
	} else {
		if(HUMAN_CLASSES[iItemId][humanClassVip]) {
			if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
				dg_color_chat(id, _, "La clase elegida es solo para usuarios VIP");

				showMenu__ChooseHumanClass(id);
				return PLUGIN_HANDLED;
			}
		}

		g_HumanClassNext[id] = iItemId;

		dg_color_chat(id, _, "En tu próxima respawn tu clase será !t%s!y", HUMAN_CLASSES[g_HumanClassNext[id]][humanClassName]);
		dg_color_chat(id, _, "Vida: !g%d!y | Velocidad: !g%0.2f!y | Gravedad: !g%d!y", HUMAN_CLASSES[g_HumanClassNext[id]][humanClassHealth], HUMAN_CLASSES[g_HumanClassNext[id]][humanClassSpeed], floatround(Float:HUMAN_CLASSES[g_HumanClassNext[id]][humanClassGravity] * 800.0));
	}

	showMenu__ChooseHumanClass(id);
	return PLUGIN_HANDLED;
}

public showMenu__ChooseZombieClass(const id)
{
	new iMenuId;
	new i;
	new sMenu[64];
	new sPosition[2];

	iMenuId = menu_create("CLASES ZOMBIES\R", "menu__ChooseZombieClass");

	for(i = 0; i < structIdZombieClasses; ++i)
	{
		if(g_ZombieClass[id] == i)
			formatex(sMenu, charsmax(sMenu), "\d%s \r(%s)\d - \y(ACTUAL)", __ZOMBIE_CLASSES[i][zombieClassName], __ZOMBIE_CLASSES[i][zombieClassInfo]);
		else if(g_ZombieClassNext[id] == i)
			formatex(sMenu, charsmax(sMenu), "\d%s \r(%s)\d - \y(ELEGIDO)", __ZOMBIE_CLASSES[i][zombieClassName], __ZOMBIE_CLASSES[i][zombieClassInfo]);
		else
			formatex(sMenu, charsmax(sMenu), "\w%s \r(%s)", __ZOMBIE_CLASSES[i][zombieClassName], __ZOMBIE_CLASSES[i][zombieClassInfo]);

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sMenu, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][PAGE_ZOMBIE_CLASSES] = min(g_MenuPage[id][PAGE_ZOMBIE_CLASSES], menu_pages(iMenuId)- 1);

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_ZOMBIE_CLASSES]);
}

public menu__ChooseZombieClass(const id, const menu, const item)
{
	if(!g_IsConnected[id])
	{
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_ZOMBIE_CLASSES]);

	if(item == MENU_EXIT)
	{
		DestroyLocalMenu(id, menu);

		showMenu__ChooseClass(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(g_ZombieClass[id] == iItemId)
		dg_color_chat(id, _, "Ya tienes puesta la clase zombie !g%s!y", __ZOMBIE_CLASSES[iItemId][zombieClassName]);
	else if(g_ZombieClassNext[id] == iItemId)
		dg_color_chat(id, _, "Ya has elegido la clase zombie !g%s!y. Espera a tu próximo respawn zombie o infección para obtenerlo", __ZOMBIE_CLASSES[iItemId][zombieClassName]);
	else
	{
		g_ZombieClassNext[id] = iItemId;

		dg_color_chat(id, _, "En tu próxima respawn zombie o infección tu clase será !g%s!y", __ZOMBIE_CLASSES[iItemId][zombieClassName]);
		dg_color_chat(id, _, "Vida: !g%d!y | Velocidad: !g%0.0f!y | Gravedad: !g%0.0f!y | KnockBack: !g%0.0f%%!y", __ZOMBIE_CLASSES[iItemId][zombieClassHealth], __ZOMBIE_CLASSES[iItemId][zombieClassSpeed], (__ZOMBIE_CLASSES[iItemId][zombieClassGravity] * 800.0), (__ZOMBIE_CLASSES[iItemId][zombieClassKnockback] * 100.0));
	}

	showMenu__ChooseZombieClass(id);
	return PLUGIN_HANDLED;
}

public showMenu__ChooseSurvivorClass(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static i;

	iMenuId = menu_create("CLASES SURVIVORS\R", "menu__ChooseSurvivorClass");

	for(i = 0; i < sizeof(SURVIVOR_CLASSES); ++i) {
		if(g_SurvivorClass[id] == i) {
			formatex(sMenu, charsmax(sMenu), "\d%s \y(ACTUAL)", SURVIVOR_CLASSES[i][survivorClassName]);
		} else if(g_SurvivorClassNext[id] == i) {
			formatex(sMenu, charsmax(sMenu), "\d%s \y(ELEGIDO)", SURVIVOR_CLASSES[i][survivorClassName]);
		} else {
			formatex(sMenu, charsmax(sMenu), "\w%s \y(%s)", SURVIVOR_CLASSES[i][survivorClassName], SURVIVOR_CLASSES[i][survivorClassInfo]);
		}

		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, sMenu, sItem);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGUIENTE");

	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage[id][PAGE_SURVIVOR_CLASSES] = min(g_MenuPage[id][PAGE_SURVIVOR_CLASSES], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_SURVIVOR_CLASSES]);
}

public menu__ChooseSurvivorClass(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_SURVIVOR_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__ChooseClass(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if(g_SurvivorClass[id] == iItemId) {
		dg_color_chat(id, _, "Ya tienes puesta la clase survivor !t%s!y", SURVIVOR_CLASSES[iItemId][survivorClassName]);
	} else if(g_SurvivorClassNext[id] == iItemId) {
		dg_color_chat(id, _, "Ya has elegido la clase survivor !t%s!y. Espera a tu próximo respawn survivor para obtenerlo", SURVIVOR_CLASSES[iItemId][survivorClassName]);
	} else {
		if(SURVIVOR_CLASSES[iItemId][survivorClassVip]) {
			if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
				dg_color_chat(id, _, "La clase elegida es solo para usuarios VIP");

				showMenu__ChooseSurvivorClass(id);
				return PLUGIN_HANDLED;
			}
		}

		g_SurvivorClassNext[id] = iItemId;

		dg_color_chat(id, _, "En tu próxima respawn tu clase será !t%s!y", SURVIVOR_CLASSES[g_SurvivorClassNext[id]][survivorClassName]);
		dg_color_chat(id, _, "Vida base: !g%d!y | Velocidad: !g%0.2f!y | Gravedad: !g%d!y", SURVIVOR_CLASSES[g_SurvivorClassNext[id]][survivorClassHealth], SURVIVOR_CLASSES[g_SurvivorClassNext[id]][survivorClassSpeed], floatround(Float:SURVIVOR_CLASSES[g_SurvivorClassNext[id]][survivorClassGravity] * 800.0));
	}

	showMenu__ChooseSurvivorClass(id);
	return PLUGIN_HANDLED;
}

public showMenu__ChooseNemesisClass(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static i;

	iMenuId = menu_create("CLASES NEMESIS\R", "menu__ChooseNemesisClasses");

	for(i = 0; i < sizeof(NEMESIS_CLASSES); ++i) {
		if(g_NemesisClass[id] == i) {
			formatex(sMenu, charsmax(sMenu), "\d%s \y(ACTUAL)", NEMESIS_CLASSES[i][nemesisClassName]);
		} else if(g_NemesisClassNext[id] == i) {
			formatex(sMenu, charsmax(sMenu), "\d%s \y(ELEGIDO)", NEMESIS_CLASSES[i][nemesisClassName]);
		} else {
			formatex(sMenu, charsmax(sMenu), "\w%s \y(%s)", NEMESIS_CLASSES[i][nemesisClassName], NEMESIS_CLASSES[i][nemesisClassInfo]);
		}

		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, sMenu, sItem);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGUIENTE");

	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage[id][PAGE_NEMESIS_CLASSES] = min(g_MenuPage[id][PAGE_NEMESIS_CLASSES], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_NEMESIS_CLASSES]);
}

public menu__ChooseNemesisClasses(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_NEMESIS_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__ChooseClass(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if(g_NemesisClass[id] == iItemId) {
		dg_color_chat(id, _, "Ya tienes puesta la clase nemesis !t%s!y", NEMESIS_CLASSES[iItemId][nemesisClassName]);
	} else if(g_NemesisClassNext[id] == iItemId) {
		dg_color_chat(id, _, "Ya has elegido la clase nemesis !t%s!y. Espera a tu próximo respawn nemesis para obtenerlo", NEMESIS_CLASSES[iItemId][nemesisClassName]);
	} else {
		if(NEMESIS_CLASSES[iItemId][nemesisClassVip]) {
			if(!(get_user_flags(id) & ADMIN_RESERVATION)) {
				dg_color_chat(id, _, "La clase elegida es solo para usuarios VIP");

				showMenu__ChooseNemesisClass(id);
				return PLUGIN_HANDLED;
			}
		}

		g_NemesisClassNext[id] = iItemId;

		dg_color_chat(id, _, "En tu próxima respawn tu clase será !t%s!y", NEMESIS_CLASSES[g_NemesisClassNext[id]][nemesisClassName]);
		dg_color_chat(id, _, "Vida base: !g%d!y | Velocidad: !g%0.2f!y | Gravedad: !g%d!y", NEMESIS_CLASSES[g_NemesisClassNext[id]][nemesisClassHealth], NEMESIS_CLASSES[g_NemesisClassNext[id]][nemesisClassSpeed], floatround(Float:NEMESIS_CLASSES[g_NemesisClassNext[id]][nemesisClassGravity] * 800.0));
	}

	showMenu__ChooseNemesisClass(id);
	return PLUGIN_HANDLED;
}

public showMenu__Upgrades(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[350];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\yMEJORAS^n");

	static sPoints[8];
	addDot(g_Points[id], sPoints, charsmax(sPoints));
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wPuntos de Poder\r:\y %s^n^n", sPoints);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w PERSONAJE \y[%s]^n", UPGRADES_SKIN[g_UpgradeSelect[id][0]][upgradeName]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w GORRO / MOCHILA \y[%s]^n", UPGRADES_HAT[g_UpgradeSelect[id][1]][upgradeName]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r3.\w CUCHILLO \y[%s]^n", UPGRADES_KNIFE[g_UpgradeSelect[id][2]][upgradeName]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\yNOTA\r:^n\wLos puntos de poder se utiliza para comprar^nelementos estéticos, los mismos se desbloquean con^n\yLOGROS^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r0.\w VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Upgrades Menu");
}

public menu__Upgrades(const id, const key) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	switch(key) {
		case 9: {
			showMenu__Character(id);
		} case 0, 1, 2: {
			g_MenuData[id][DATA_UPGRADES] = key;
			showMenu__UpgradesIn(id);
		} default: {
			showMenu__Upgrades(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__UpgradesIn(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static iClass;
	iClass = g_MenuData[id][DATA_UPGRADES];

	if(!(0 <= iClass <= sizeof(UPGRADES_CLASS))) {
		dg_color_chat(id, _, "Hubo un error al seleccionar la mejora en el menú");

		showMenu__Game(id);
		return;
	}

	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static i;

	formatex(sMenu, charsmax(sMenu), "MEJORAR %s\R", UPGRADES_CLASS[iClass]);
	iMenuId = menu_create(sMenu, "menu__UpgradesIn");

	switch(iClass) {
		case 0: { // SKIN
			for(i = 0; i < sizeof(UPGRADES_SKIN); ++i) {
				sItem[0] = i;
				sItem[1] = 0;

				if(g_UpgradesSkin[id][i]) {
					if(g_UpgradeSelect[id][0] == i) {
						formatex(sMenu, charsmax(sMenu), "%s \y[ACTUAL]", UPGRADES_SKIN[i][upgradeName]);
					} else {
						formatex(sMenu, charsmax(sMenu), "%s", UPGRADES_SKIN[i][upgradeName]);
					}
				} else {
					formatex(sMenu, charsmax(sMenu), "\d%s", UPGRADES_SKIN[i][upgradeName]);
				}

				menu_additem(iMenuId, sMenu, sItem);
			}
		} case 1: { // HAT
			for(i = 0; i < sizeof(UPGRADES_HAT); ++i) {
				sItem[0] = i;
				sItem[1] = 0;

				if(g_UpgradesHat[id][i]) {
					if(g_UpgradeSelect[id][1] == i) {
						formatex(sMenu, charsmax(sMenu), "%s \y[ACTUAL]", UPGRADES_HAT[i][upgradeName]);
					} else {
						formatex(sMenu, charsmax(sMenu), "%s", UPGRADES_HAT[i][upgradeName]);
					}
				} else {
					formatex(sMenu, charsmax(sMenu), "\d%s", UPGRADES_HAT[i][upgradeName]);
				}

				menu_additem(iMenuId, sMenu, sItem);
			}
		} case 2: { // KNIFE
			new iCost;
			for(i = 0; i < sizeof(UPGRADES_KNIFE); ++i) {
				iCost = UPGRADES_KNIFE[i][upgradeCost];

				sItem[0] = i;
				sItem[1] = 0;

				if(g_UpgradesKnife[id][i]) {
					if(g_UpgradeSelect[id][2] == i) {
						formatex(sMenu, charsmax(sMenu), "%s \y[ACTUAL]", UPGRADES_KNIFE[i][upgradeName]);
					} else {
						formatex(sMenu, charsmax(sMenu), "%s", UPGRADES_KNIFE[i][upgradeName]);
					}
				} else {
					if(g_Stats_General[id][STATS_ESCAPE_D] >= iCost) {
						formatex(sMenu, charsmax(sMenu), "%s", UPGRADES_KNIFE[i][upgradeName]);
					} else {
						formatex(sMenu, charsmax(sMenu), "\d%s", UPGRADES_KNIFE[i][upgradeName]);
					}
				}

				menu_additem(iMenuId, sMenu, sItem);
			}
		}
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGUIENTE");

	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage_Upgrades[id][iClass] = min(g_MenuPage_Upgrades[id][iClass], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage_Upgrades[id][iClass]);
}

public menu__UpgradesIn(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Upgrades[id][g_MenuData[id][DATA_UPGRADES]]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Upgrades(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if(g_MenuData[id][DATA_UPGRADES] >= 0 && g_MenuData[id][DATA_UPGRADES] <= 2) {
		g_MenuData[id][DATA_UPGRADE_ITEM_ID] = iItemId;
		showMenu__UpgradesPreview(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__AchClass(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static i;

	formatex(sMenu, charsmax(sMenu), "\yLOGROS^n\wLogros completados en total\r:\y %d\R", g_Stats_General[id][STATS_ACHIEVEMENTS_D]);
	iMenuId = menu_create(sMenu, "menu__AchClass");

	for(i = 0; i < structIdAchClasses; ++i) {
		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, ACH_CLASSES[i], sItem);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage[id][PAGE_ACH_CLASSES] = min(g_MenuPage[id][PAGE_ACH_CLASSES], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_ACH_CLASSES]);
}

public menu__AchClass(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_ACH_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];
	g_MenuData[id][DATA_ACH_CLASSES] = iItemId;

	showMenu__Achievements(id, g_MenuData[id][DATA_ACH_CLASSES]);
	return PLUGIN_HANDLED;
}

public showMenu__Achievements(const id, const class) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[64];
	static sItem[4];
	static sAchievementCount[16];
	static iMenuId;
	static i;
	static j;
	static k;

	formatex(sMenu, charsmax(sMenu), "\yLOGROS\r:\w %s\y\R", ACH_CLASSES[class]);
	iMenuId = menu_create(sMenu, "menu__Achievements");

	sItem = {0, 0, 0, 0};
	j = 0;
	k = -1;

	for(i = 0; i < structIdAchievements; ++i) {
		++k;

		if(class != ACHS[i][achClass]) {
			continue;
		}

		while(k > 127) {
			sItem[j] = 127;
			++j;

			k -= 127;
		}

		sItem[j] = k;
		sItem[3] = 0;

		if(!g_Achievement[0][i]) {
			formatex(sAchievementCount, charsmax(sAchievementCount), " \y(x%d)", g_AchievementCount[id][i]);
			formatex(sMenu, charsmax(sMenu), "%s%s%s", (!g_Achievement[id][i]) ? "\d" : "\w", ACHS[i][achName], (g_AchievementCount[id][i] <= 1) ? "" : sAchievementCount);
		} else {
			formatex(sMenu, charsmax(sMenu), "%s%s", (!g_Achievement[id][i]) ? "\r" : "\w", ACHS[i][achName]);
		}

		menu_additem(iMenuId, sMenu, sItem);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage_Achievements[id][class] = min(g_MenuPage_Achievements[id][class], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage_Achievements[id][class]);
}

public menu__Achievements(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage_Achievements[id][g_MenuData[id][DATA_ACH_CLASSES]]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__AchClass(id);
		return PLUGIN_HANDLED;
	}

	static sItem[4];
	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	g_MenuData[id][DATA_ACH_IN] = sItem[0] + sItem[1] + sItem[2];

	showMenu__AchievementsInfo(id, g_MenuData[id][DATA_ACH_IN]);
	return PLUGIN_HANDLED;
}

public showMenu__AchievementsInfo(const id, const achievement) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[450];
	static sAchievementCount[16];
	static iLen;

	formatex(sAchievementCount, charsmax(sAchievementCount), " \y(x%d)", g_AchievementCount[id][achievement]);
	iLen = formatex(sMenu, charsmax(sMenu), "\y%s%s \w- %s^n^n", ACHS[achievement][achName], (g_AchievementCount[id][achievement] <= 1) ? "" : sAchievementCount, (!g_Achievement[id][achievement]) ? "\r(BLOQUEADO)" : "\y(DESBLOQUEADO)");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yDESCRIPCIÓN\r:^n\w%s^n", ACHS[achievement][achInfo]);

	if(ACHS[achievement][achUsersNeed]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\yREQUISITOS EXTRAS\r:^n\w%d usuarios conectados^n", ACHS[achievement][achUsersNeed]);
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\yRECOMPENSA\r:^n");
	if(ACHS[achievement][achRewardExp]) {
		if(achievement != APP_DAILY_VISIT) {
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\w\r - \y+%d\w EXP^n", ACHS[achievement][achRewardExp]);
		} else {
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\w\r - \y+%d\w EXP^n", ((g_DailyVisit[id]+1) * 25));
		}
	}

	if(ACHS[achievement][achRewardPU]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\w\r - \y+%d\w pU^n", ACHS[achievement][achRewardPU]);
	}

	if(g_Achievement[id][achievement]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\yLOGRO DESBLOQUEADO EL DÍA\r:^n\w%s^n", g_AchievementUnlocked[id][achievement]);
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r1.\w LINKEAR AL CHAT^n");
	} else if(g_Achievement[0][achievement]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\wLOGRO DESBLOQUEADO POR \y%s^n\w EL DÍA\r:\y%s^n", g_AchievementName[0][achievement], g_AchievementUnlocked[0][achievement]);
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r1.\d LINKEAR AL CHAT^n");
	} else {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r1.\d LINKEAR AL CHAT^n");
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r0.\w VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Achievements Info Menu");
}

public menu__AchievementsInfo(const id, const keyId) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	static iAchievementId;
	iAchievementId = g_MenuData[id][DATA_ACH_IN];

	switch(keyId) {
		case 0: {
			if(g_Achievement[id][iAchievementId]) {
				if(g_SysTime_Link[id] < get_gametime() || checkScripterAccess(id)) {
					new sAchievementCount[16];
					sAchievementCount[0] = EOS;

					if(g_AchievementCount[id][iAchievementId] > 1) {
						formatex(sAchievementCount, charsmax(sAchievementCount), " !t(x%d)", g_AchievementCount[id][iAchievementId]);
					}

					g_SysTime_Link[id] = get_gametime() + 30.0;
					dg_color_chat(0, id, "!t%s!y muestra su logro !g%s%s!t [X]!y, conseguido el día !t%s!y", g_User_Name[id], ACHS[iAchievementId][achName], sAchievementCount, g_AchievementUnlocked[id][iAchievementId]);

					g_AchievementLink_Id = iAchievementId;
					g_AchievementLink_Class = g_MenuData[id][DATA_ACH_CLASSES];
					g_AchievementLink_MenuPage = g_MenuPage_Achievements[id][g_AchievementLink_Class];
				}
			}

			showMenu__AchievementsInfo(id, iAchievementId);
		} case 9: {
			showMenu__Achievements(id, g_MenuData[id][DATA_ACH_CLASSES]);
		} default: {
			showMenu__AchievementsInfo(id, iAchievementId);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__MetaAchievements(const id) {
	static sBuffer[64];
	static sPosition[3];
	static iMenuId;
	static i;

	iMenuId = menu_create("META-LOGROS\R", "menu__MetaAchievements");

	for(i = 0; i < sizeof(META_ACHIEVEMENTS); ++i) {
		num_to_str((i + 1), sPosition, 2);

		formatex(sBuffer, charsmax(sBuffer), "%s%s", (!g_MetaAchievement[id][i]) ? "\d" : "\w", META_ACHIEVEMENTS[i][achName]);
		menu_additem(iMenuId, sBuffer, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage[id][PAGE_METAACHIEVEMENTS] = min(g_MenuPage[id][PAGE_METAACHIEVEMENTS], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_METAACHIEVEMENTS]);
}

public menu__MetaAchievements(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_METAACHIEVEMENTS]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	static sBuffer[3];
	menu_item_getinfo(menu, item, iItemId, sBuffer, charsmax(sBuffer), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	g_MenuData[id][DATA_METAACHIEVEMENT_IN] = str_to_num(sBuffer) - 1;

	showMenu__MetaAchievementsInfo(id, g_MenuData[id][DATA_METAACHIEVEMENT_IN]);
	return PLUGIN_HANDLED;
}

public showMenu__MetaAchievementsInfo(const id, const metaAchId) {
	static sMenu[450];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\y%s \w- %s^n^n", META_ACHIEVEMENTS[metaAchId][achName], (!g_MetaAchievement[id][metaAchId]) ? "\r(BLOQUEADO)" : "\y(DESBLOQUEADO)");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yDESCRIPCIÓN\r:^n\w%s^n", META_ACHIEVEMENTS[metaAchId][achInfo]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\yRECOMPENSA\r:^n");
	if(META_ACHIEVEMENTS[metaAchId][achRewardExp]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\w\r - \y+%d\w EXP^n", META_ACHIEVEMENTS[metaAchId][achRewardExp]);
	}
	if(META_ACHIEVEMENTS[metaAchId][achRewardPU]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\w\r - \y+%d\w pU^n", META_ACHIEVEMENTS[metaAchId][achRewardPU]);
	}

	if(g_MetaAchievement[id][metaAchId]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\yMETA-LOGRO DESBLOQUEADO EL DÍA\r:^n\w%s^n", g_MetaAchievementUnlocked[id][metaAchId]);

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r1.\w LINKEAR AL CHAT^n");
	} else {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r1.\d LINKEAR AL CHAT^n");
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r0.\w VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Achievements Meta Info Menu");
}

public menu__MetaAchievementsInfo(const id, const key) {
	static iMetaAchievementId;
	iMetaAchievementId = g_MenuData[id][DATA_METAACHIEVEMENT_IN];

	switch(key) {
		case 0: {
			if(g_MetaAchievement[id][iMetaAchievementId]) {
				if(g_SysTime_Link[id] < get_gametime() || checkScripterAccess(id)) {
					g_SysTime_Link[id] = get_gametime() + 60.0;
					dg_color_chat(0, id, "!t%s!y muestra su meta-logro !g%s!y, conseguido el día !t%s!y", g_User_Name[id], META_ACHIEVEMENTS[iMetaAchievementId][achName], g_MetaAchievementUnlocked[id][iMetaAchievementId]);
				}
			}

			showMenu__MetaAchievementsInfo(id, iMetaAchievementId);
		} case 9: {
			showMenu__MetaAchievements(id);
		} default: {
			showMenu__MetaAchievementsInfo(id, iMetaAchievementId);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__Stats(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[350];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\yESTADÍSTICAS^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Lista de Niveles^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Tops 15^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r3.\w Estadísticas generales^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r4.\w Ver todas mis estadísticas^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wCUENTA NÚMERO\r:\y %d^n^n", g_Account_Id[id]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wUSUARIO DESDE EL DÍA\r:\y %s^n", g_Account_RegisterSince[id]);
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wÚLTIMA CONEXIÓN\r:\y %s^n^n", g_Account_LastConnection[id]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wTIEMPO JUGADO:^n\y%d día%s, %d hora%s, %d minuto%s^n^n", g_PlayedTime[id][2], (g_PlayedTime[id][2] != 1) ? "s" : "", g_PlayedTime[id][1], (g_PlayedTime[id][1] != 1) ? "s" : "", g_PlayedTime[id][3], (g_PlayedTime[id][3] != 1) ? "s" : "");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Stats Menu");
}

public menu__Stats(const id, const key) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	switch(key) {
		case 9: {
			showMenu__Game(id);
		} case 0: {
			showMenu__StatsLvl(id);
		} case 1: {
			showMenu__StatsTop15(id);
		} case 2: {
			showMenu__StatsGeneral(id);
		} case 3: {
			static sBufferURL[256];
			formatex(sBufferURL, charsmax(sBufferURL), "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=http://drunk-gaming.com/tops/01_zombie_escape/user_data.php?id=%d^"></head><body><p>Cargando...</p></body></html>", g_Account_Id[id]);
			show_motd(id, sBufferURL, "ESTADÍSTICAS");
		} default: {
			showMenu__Stats(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__StatsLvl(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	if(g_Level[id] >= MAX_LEVEL) {
		dg_color_chat(id, _, "Ya superaste el nivel máximo");

		showMenu__Stats(id);
		return;
	}

	static sXpNeed[12];
	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static i;

	iMenuId = menu_create("LISTA DE NIVELES\R", "menu__StatsLvl");

	for(i = 1; i <= MAX_LEVEL; ++i) {
		addDot(NEED_EXP_TOTAL[i], sXpNeed, charsmax(sXpNeed));

		if(g_Level[id] >= i) {
			formatex(sMenu, charsmax(sMenu), "\wNivel\r:\y %d \r-\w EXP\r:\y %s", i, sXpNeed);
		} else {
			formatex(sMenu, charsmax(sMenu), "\dNivel\r:\d %d \r-\d EXP\r:\d %s", i, sXpNeed);
		}

		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, sMenu, sItem);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][PAGE_STATS_LVL] = min(g_MenuPage[id][PAGE_STATS_LVL], menu_pages(iMenuId) - 1);
	if(g_MenuPage[id][PAGE_STATS_LVL] == 0) {
		g_MenuPage[id][PAGE_STATS_LVL] = g_Level[id] / 7;
	}

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_STATS_LVL]);
}

public menu__StatsLvl(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_STATS_LVL]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Stats(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	menu_item_getinfo(menu, item, iItemId, sItem, 2, _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if(iItemId < 1 || iItemId > MAX_LEVEL) {
		showMenu__StatsLvl(id);
		return PLUGIN_HANDLED;
	}

	static sXpNeed[12];
	addDot(NEED_EXP_TOTAL[iItemId], sXpNeed, charsmax(sXpNeed));

	dg_color_chat(id, _, "Te faltan !g%s EXP!y para el nivel %d", sXpNeed, iItemId);

	showMenu__StatsLvl(id);
	return PLUGIN_HANDLED;
}

public showMenu__StatsTop15(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sItem[3];
	static iMenuId;
	static i;

	iMenuId = menu_create("TOP 15\R", "menu__StatsTop15");

	for(i = 0; i < sizeof(TOPS_15); ++i) {
		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, TOPS_15[i][top15Name], sItem);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	g_MenuPage[id][PAGE_STATS_TOPS15] = min(g_MenuPage[id][PAGE_STATS_TOPS15], menu_pages(iMenuId) - 1);

	ShowLocalMenu(id, iMenuId, g_MenuPage[id][PAGE_STATS_TOPS15]);
}

public menu__StatsTop15(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_STATS_TOPS15]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Stats(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if((g_SysTime_Tops15[id] > get_gametime()) && !checkScripterAccess(id)) {
		dg_color_chat(id, _, "Tenés que esperar !g%0.2f segundos!y para ver otro tipo de Top15", (get_gametime() - g_SysTime_Tops15[id]));

		showMenu__StatsTop15(id);
		return PLUGIN_HANDLED;
	}

	g_SysTime_Tops15[id] = get_gametime() + 10.0;

	static sBuffer[256];
	formatex(sBuffer, charsmax(sBuffer), "<html><head><style>body {background:#000;color:#FFF;}</style><meta http-equiv=^"Refresh^" content=^"0;url=http://drunk-gaming.com/tops/01_zombie_escape/%s?id=%d^"></head><body><p>Cargando . . .</p></body></html>", TOPS_15[iItemId][top15URL], g_Account_Id[id]);
	show_motd(id, sBuffer, "TOP 15");

	showMenu__StatsTop15(id);
	return PLUGIN_HANDLED;
}

public showMenu__StatsGeneral(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[450];
	static iLen;

	iLen = formatex(sMenu, charsmax(sMenu), "\yESTADÍSTICAS GENERALES\R%d/3^n^n", g_MenuPage[id][PAGE_STATS_GENERAL] + 1);

	switch(g_MenuPage[id][PAGE_STATS_GENERAL]) {
		case 0: {
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wInfecciones hechas\r:\y %d^n", g_Stats_General[id][STATS_INFECTS_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wInfecciones recibidas\r:\y %d^n", g_Stats_General[id][STATS_INFECTS_T]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wZombies matados\r:\y %d^n", g_Stats_General[id][STATS_ZOMBIES_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVeces muerto como Zombie\r:\y %d^n", g_Stats_General[id][STATS_ZOMBIES_T]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wHumanos matados\r:\y %d^n", g_Stats_General[id][STATS_HUMANS_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVeces muerto como Humano\r:\y %d^n", g_Stats_General[id][STATS_HUMANS_T]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wDisparos en la cabeza hechos\r:\y %d^n", g_Stats_General[id][STATS_HEAD_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wDisparos en la cabeza recibidos\r:\y %d^n", g_Stats_General[id][STATS_HEAD_T]);
		} case 1: {
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wZombies matados con disparos en la cabeza\r:\y %d^n", g_Stats_General[id][STATS_ZOMBIES_HEAD_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVeces muerto con disparos en la cabeza\r:\y %d^n", g_Stats_General[id][STATS_ZOMBIES_HEAD_T]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wZombies matados con cuchillo\r:\y %d^n", g_Stats_General[id][STATS_ZOMBIES_KNIFE_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wVeces muerto con cuchillo\r:\y %d^n", g_Stats_General[id][STATS_ZOMBIES_KNIFE_T]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wChaleco desgarrado hecho\r:\y %d^n", g_Stats_General[id][STATS_ARMOR_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wChaleco desgarrado recibido\r:\y %d^n", g_Stats_General[id][STATS_ARMOR_T]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wEscapes exitosos\r:\y %d^n", g_Stats_General[id][STATS_ESCAPE_D]);
		} case 2: {
			static sDamage[64];
			static sOutputDamage[64];

			formatex(sDamage, charsmax(sDamage), "%0.0f", (g_Stats_DamageCount[id][0] * DIV_DAMAGE));
			addDot__Special(sDamage, sOutputDamage, charsmax(sOutputDamage));
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wDaño hecho\r:\y %s^n", sOutputDamage);

			formatex(sDamage, charsmax(sDamage), "%0.0f", (g_Stats_DamageCount[id][1] * DIV_DAMAGE));
			addDot__Special(sDamage, sOutputDamage, charsmax(sOutputDamage));
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wDaño recibido\r:\y %s^n", sOutputDamage);

			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wLogros completados\r:\y %d^n", g_Stats_General[id][STATS_ACHIEVEMENTS_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wSurvivors matados\r:\y %d^n", g_Stats_General[id][STATS_SURVIVOR_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wNemesis matados\r:\y %d^n", g_Stats_General[id][STATS_NEMESIS_D]);
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wCajas recolectadas\r:\y %d^n", g_Stats_General[id][STATS_SUPPLY_BOX_COLLECTED]);
		}
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r9.\w Siguiente / Atrás^n");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Stats General Menu");
}

public menu__StatsGeneral(const id, const key) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	switch(key) {
		case 9: {
			showMenu__Stats(id);
		}
		case 8: {
			if(++g_MenuPage[id][PAGE_STATS_GENERAL] == 3) {
				g_MenuPage[id][PAGE_STATS_GENERAL] = 0;
			}

			showMenu__StatsGeneral(id);
		}
		default: {
			showMenu__StatsGeneral(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__Config(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static iMenuId;
	iMenuId = menu_create("CONFIGURACIÓN", "menu__Config");

	menu_additem(iMenuId, "Elegir colores", "1");
	menu_additem(iMenuId, "HUD General^n", "2");
	menu_additem(iMenuId, "Elegir que canciones escuchar", "3");

	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	ShowLocalMenu(id, iMenuId);
}

public menu__Config(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	static iItemId;

	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = str_to_num(sItem);

	switch(iItemId) {
		case 1: { // ELEGIR COLOR
			showMenu__ChooseTypeColor(id, COLOR_NONE);
		} case 2: { // CONFIGURAR HUD GENERAL
			showMenu__ConfigHudGeneral(id);
		} case 3: { // ELEGIR QUE CANCIONES ESCUCHAR
			showMenu__ChooseWhatSongsToHear(id);
		}
	}

	return PLUGIN_HANDLED;
}

public showMenu__ChooseTypeColor(const id, const colorId) {
	if(colorId == COLOR_NONE) {
		if(pev_valid(id) == PDATA_SAFE) {
			set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
		}

		show_menu(id, KEYSMENU, "\yELEGIR COLORES^n^n\r1.\w HUD general^n\r2.\w Luz / Bubble^n^n\r0.\w VOLVER", -1, "Choose Type Color Menu");
		return;
	}

	static sMenu[200];
	static iCheck;
	static iLen;
	static i;
	static iOk;

	iOk = 1;
	iLen = 0;

	g_MenuData[id][DATA_COLORS] = colorId;

	switch(colorId) {
		case COLOR_HUD: {
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yCOLOR - HUD GENERAL\R^n^n");
			iOk = 0;
		} case COLOR_FLARE: {
			formatex(sMenu, charsmax(sMenu), "COLOR - LUZ / BUBBLE\R");
		}
	}

	if(iOk) {
		static sPosition[3];
		static sItem[48];
		static iMenu;

		iMenu = menu_create(sMenu, "menu__ChooseColorNew");

		for(i = 0; i < sizeof(__COLORS); ++i) {
			iCheck = (g_Color[id][colorId][__R] == __COLORS[i][colorRed] && g_Color[id][colorId][__G] == __COLORS[i][colorGreen] && g_Color[id][colorId][__B] == __COLORS[i][colorBlue]) ? 1 : 0;
			formatex(sItem, 47, "%s%s%s", (!iCheck) ? "\w" : "\d", __COLORS[i][colorName], (!iCheck) ? "" : " \y(ACTUAL)");

			num_to_str((i + 1), sPosition, 2);
			menu_additem(iMenu, sItem, sPosition);
		}

		menu_setprop(iMenu, MPROP_BACKNAME, "PÁG. ANTERIOR");
		menu_setprop(iMenu, MPROP_NEXTNAME, "PÁG. SIGUIENTE");

		menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");

		g_MenuPage[id][PAGE_COLORS] = min(g_MenuPage[id][PAGE_COLORS], menu_pages(iMenu) - 1);

		if(pev_valid(id) == PDATA_SAFE) {
			set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
		}

		ShowLocalMenu(id, iMenu, g_MenuPage[id][PAGE_COLORS]);
	} else {
		for(i = 0; i < 8; ++i) {
			iCheck = (g_Color[id][colorId][__R] == __COLORS[i][colorRed] && g_Color[id][colorId][__G] == __COLORS[i][colorGreen] && g_Color[id][colorId][__B] == __COLORS[i][colorBlue]) ? 1 : 0;
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r%d.%s %s%s^n", (i + 1), (!iCheck) ? "\w" : "\d", __COLORS[i][colorName], (!iCheck) ? "" : " \y(ACTUAL)");
		}

		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r0.\w VOLVER");

		if(pev_valid(id) == PDATA_SAFE) {
			set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
		}

		show_menu(id, KEYSMENU, sMenu, -1, "Choose Color Menu");
	}
}

public menu__ChooseTypeColor(const id, const key) {
	if(key >= 3) {
		if(key == 9) {
			showMenu__Config(id);
		} else {
			showMenu__ChooseTypeColor(id, g_MenuData[id][DATA_COLORS]);
		}

		return PLUGIN_HANDLED;
	}

	showMenu__ChooseTypeColor(id, (key + 1));
	return PLUGIN_HANDLED;
}

public menu__ChooseColorNew(const id, const menuId, const itemId) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}

	static iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][PAGE_COLORS]);

	if(itemId == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);

		showMenu__ChooseTypeColor(id, COLOR_NONE);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	menu_item_getinfo(menuId, itemId, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menuId);

	iItemId = str_to_num(sItem) - 1;

	// LUZ

	g_Color[id][g_MenuData[id][DATA_COLORS]][__R] = __COLORS[iItemId][colorRed];
	g_Color[id][g_MenuData[id][DATA_COLORS]][__G] = __COLORS[iItemId][colorGreen];
	g_Color[id][g_MenuData[id][DATA_COLORS]][__B] = __COLORS[iItemId][colorBlue];

	showMenu__ChooseTypeColor(id, g_MenuData[id][DATA_COLORS]);
	return PLUGIN_HANDLED;
}

public menu__ChooseColor(const id, const key) {
	if(key >= 8) {
		if(key == 9) {
			showMenu__ChooseTypeColor(id, COLOR_NONE);
		} else {
			showMenu__ChooseTypeColor(id, g_MenuData[id][DATA_COLORS]);
		}

		return PLUGIN_HANDLED;
	}

	g_Color[id][g_MenuData[id][DATA_COLORS]][__R] = __COLORS[key][colorRed];
	g_Color[id][g_MenuData[id][DATA_COLORS]][__G] = __COLORS[key][colorGreen];
	g_Color[id][g_MenuData[id][DATA_COLORS]][__B] = __COLORS[key][colorBlue];

	showMenu__ChooseTypeColor(id, g_MenuData[id][DATA_COLORS]);
	return PLUGIN_HANDLED;
}

public showMenu__ConfigHudGeneral(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sBuffer[64];
	static iMenuId;

	iMenuId = menu_create("CONFIGURAR HUD GENERAL", "menu__ConfigHudGeneral");

	menu_additem(iMenuId, "MOVER HUD HACIA ARRIBA", "1");
	menu_additem(iMenuId, "MOVER HUD HACIA ABAJO", "2");
	menu_additem(iMenuId, "MOVER HUD HACIA LA IZQUIERDA", "3", .callback=(!g_HudGeneral_Position[id][2]) ? -1 : g_MenuDisabled);
	menu_additem(iMenuId, "MOVER HUD HACIA LA DERECHA^n", "4", .callback=(!g_HudGeneral_Position[id][2]) ? -1 : g_MenuDisabled);

	formatex(sBuffer, charsmax(sBuffer), "HUD ALINEADO %s^n", (!g_HudGeneral_Position[id][2]) ? "A LA IZQUIERDA" : (g_HudGeneral_Position[id][2] == 2.0) ? "A LA DERECHA" : "AL CENTRO");
	menu_additem(iMenuId, sBuffer, "5");

	formatex(sBuffer, charsmax(sBuffer), "EFECTO DEL HUD \y(%sACTIVADO)", (g_HudGeneral_Effect[id]) ? "" : "DES");
	menu_additem(iMenuId, sBuffer, "6");

	formatex(sBuffer, charsmax(sBuffer), "ABREVIAR HUD \y(%sACTIVADO)", (g_HudGeneral_Abrev[id]) ? "" : "DES");
	menu_additem(iMenuId, sBuffer, "7");

	formatex(sBuffer, charsmax(sBuffer), "MINIMIZAR HUD \y(%sACTIVADO)^n", (g_HudGeneral_Mini[id]) ? "" : "DES");
	menu_additem(iMenuId, sBuffer, "8");

	menu_additem(iMenuId, "REINICIAR HUD^n", "9");

	menu_additem(iMenuId, "VOLVER", "0");

	menu_setprop(iMenuId, MPROP_PERPAGE, 0);

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	ShowLocalMenu(id, iMenuId);
}

public menu__ConfigHudGeneral(const id, const menuId, const itemId) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}

	if(itemId == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);

		showMenu__Config(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	static iItemId;

	menu_item_getinfo(menuId, itemId, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menuId);

	iItemId = str_to_num(sItem);

	switch(iItemId) {
		case 0: { // VOLVER
			showMenu__Config(id);
			return PLUGIN_HANDLED;
		}
		case 1: {
			g_HudGeneral_Position[id][1] -= 0.01;
		}
		case 2: {
			g_HudGeneral_Position[id][1] += 0.01;
		}
		case 3: {
			g_HudGeneral_Position[id][0] -= 0.01;
			g_HudGeneral_Position[id][2] = 0.0;
		}
		case 4: {
			g_HudGeneral_Position[id][0] += 0.01;
			g_HudGeneral_Position[id][2] = 0.0;
		}
		case 5: { // ALINEAR
			g_HudGeneral_Position[id][2] += 1.0;

			if(g_HudGeneral_Position[id][2] > 2.0) {
				g_HudGeneral_Position[id][2] = 0.0;
			}

			if(g_HudGeneral_Position[id][2] == 2.0) { // DERECHA
				g_HudGeneral_Position[id][0] = 1.5;
			} else if(g_HudGeneral_Position[id][2] == 1.0) { // CENTRO
				g_HudGeneral_Position[id][0] = -1.0;
			} else { // IZQUIERDA
				g_HudGeneral_Position[id][0] = 0.02;
			}
		}
		case 6: {
			g_HudGeneral_Effect[id] = !g_HudGeneral_Effect[id];
		}
		case 7: {
			g_HudGeneral_Abrev[id] = !g_HudGeneral_Abrev[id];
		}
		case 8: {
			g_HudGeneral_Mini[id] = !g_HudGeneral_Mini[id];
		}
		case 9: { // REINICIAR HUD
			g_HudGeneral_Position[id] = Float:{0.75, 0.2, 0.0};
		}
	}

	showMenu__ConfigHudGeneral(id);
	return PLUGIN_HANDLED;
}

public showMenu__Admin(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[64];
	static sItem[3];
	static iMenuId;
	static i;

	iMenuId = menu_create("MENU DE ADMIN\R", "menu__Admin");

	for(i = 2; i < sizeof(__MODES); ++i) {
		formatex(sMenu, charsmax(sMenu), "%s %s[%s]", __MODES[i][modeName], (getPlaying() >= __MODES[i][modeUsersNeed]) ? "\y" : "\r", (getPlaying() >= __MODES[i][modeUsersNeed]) ? "Disponible" : "Faltan jugadores");

		sItem[0] = i;
		sItem[1] = 0;

		menu_additem(iMenuId, sMenu, sItem, .callback=(getPlaying() >= __MODES[i][modeUsersNeed]) ? -1 : g_MenuDisabled);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGIUENTE");

	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	ShowLocalMenu(id, iMenuId);
}

public menu__Admin(const id, const menu, const item) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	static sItem[3];
	static iItemId;

	menu_item_getinfo(menu, item, iItemId, sItem, charsmax(sItem), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sItem[0];

	if(g_ModeCounts[iItemId] >= 2) {
		dg_color_chat(id, _, "Has sobrepasado el límite del modo !t%s!y", __MODES[iItemId][modeName]);

		showMenu__Admin(id);
		return PLUGIN_HANDLED;
	}

	if(!g_NewRound || g_EndRound || g_Mode != MODE_NONE) {
		dg_color_chat(id, _, "No puedes lanzar el modo en plena ronda o fin de ronda");

		showMenu__Admin(id);
		return PLUGIN_HANDLED;
	}

	if(iItemId == MODE_JERUZALEM && !(get_user_flags(id) & ADMIN_LEVEL_H)) {
		dg_console_chat(id, "Solo usuarios con rango DIRECTOR pueden lanzar este modo");

		showMenu__Admin(id);
		return PLUGIN_HANDLED;
	}

	remove_task(TASK_COUNTDOWN);
	remove_task(TASK_STARTMODE);

	setMode(iItemId, .fakeMode=true);

	++g_ModeCounts[iItemId];

	dg_color_chat(0, id, "!t%s!y comenzó el modo !g%s!y", g_User_Name[id], __MODES[iItemId][modeName]);
	return PLUGIN_HANDLED;
}

public callback__DisabledMenu() {
	return ITEM_DISABLED;
}

public message__Money(const msgId, const dest, const id) {
	if(g_IsConnected[id]) {
		cs_set_user_money(id, 0);
	}

	return PLUGIN_HANDLED;
}

public message__FlashBat(const msgId, const dest, const id) {
	if(get_msg_arg_int(1) < 100) {
		set_msg_arg_int(1, ARG_BYTE, 100);
		setUserBatteries(id, 100);
	}
}

public message__Flashlight() {
	set_msg_arg_int(2, ARG_BYTE, 100);
}

public message__NVGToggle() {
	return PLUGIN_HANDLED;
}

public message__WeapPickup(const msgId, const dest, const id) {
	if(g_Zombie[id]) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message__AmmoPickup(const msgId, const dest, const id) {
	if(g_Zombie[id]) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message__TextMsg() {
	static sMsg[24];
	get_msg_arg_string(2, sMsg, charsmax(sMsg));

	// #Fire_in_the_hole
	if(get_msg_args() == 5 && (get_msg_argtype(5) == ARG_STRING)) {
		get_msg_arg_string(5, sMsg, charsmax(sMsg));

		if(equal(sMsg, "#Fire_in_the_hole")) {
			return PLUGIN_HANDLED;
		}
	} else if(get_msg_args() == 6 && (get_msg_argtype(6) == ARG_STRING)) {
		get_msg_arg_string(6, sMsg, charsmax(sMsg));

		if(equal(sMsg, "#Fire_in_the_hole")) {
			return PLUGIN_HANDLED;
		}
	}

	// #Game_teammate_attack
	if(equal(sMsg, "#Game_teammate_attack")) {
		return PLUGIN_HANDLED;
	}

	// #Game_Commencing
	if(equal(sMsg, "#Game_Commencing")) {
		 return PLUGIN_HANDLED;
	}

	// #Game_will_restart_in
	if(equal(sMsg, "#Game_will_restart_in")) {
		g_ScoreHumans = 0;
		g_ScoreZombies = 0;

		logevent__RoundEnd();
	}

	// #Hostages_Not_Rescued | #Round_Draw | #Terrorists_Win | #CTs_Win
	else if(equal(sMsg, "#Hostages_Not_Rescued") || equal(sMsg, "#Round_Draw") || equal(sMsg, "#Terrorists_Win") || equal(sMsg, "#CTs_Win")) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message__TeamScore() {
	static sTeam[2];
	get_msg_arg_string(1, sTeam, charsmax(sTeam));

	switch(sTeam[0]) {
		case 'C': {
			set_msg_arg_int(2, get_msg_argtype(2), g_ScoreHumans);
		} case 'T': {
			set_msg_arg_int(2, get_msg_argtype(2), g_ScoreZombies);
		}
	}
}

public message__SendAudio() {
	static sAudio[19];
	get_msg_arg_string(2, sAudio, charsmax(sAudio));

	if((sAudio[7] == 't' && sAudio[8] == 'e' && sAudio[9] == 'r' && sAudio[10] == 'w' && sAudio[11] == 'i' && sAudio[12] == 'n') ||
	(sAudio[7] == 'c' && sAudio[8] == 't' && sAudio[9] == 'w' && sAudio[10] == 'i' && sAudio[11] == 'n') ||
	(sAudio[7] == 'r' && sAudio[8] == 'o' && sAudio[9] == 'u' && sAudio[10] == 'n' && sAudio[11] == 'd' && sAudio[12] == 'd' && sAudio[13] == 'r' && sAudio[14] == 'a' && sAudio[15] == 'w') ||
	equal(sAudio, "%!MRAD_FIREINHOLE")) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message__TeamInfo(const msgId, const dest) {
	if(dest != MSG_ALL && dest != MSG_BROADCAST) {
		return;
	}

	if(g_SwitchingTeams) {
		return;
	}

	static id;
	id = get_msg_arg_int(1);

	if(!isUserValid(id)) {
		return;
	}

	setLight(id, g_Lights[0]);

	if(g_NewRound) {
		return;
	}

	static sTeam[2];
	get_msg_arg_string(2, sTeam, charsmax(sTeam));

	switch(sTeam[0]) {
		case 'C': {
			if((g_Mode == MODE_SURVIVOR) && getHumans()) {
				g_RespawnAsZombie[id] = 1;

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_TERRORIST);

				set_msg_arg_string(2, "TERRORIST");
			} else if(!getZombies()) {
				g_RespawnAsZombie[id] = 1;

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_TERRORIST);

				set_msg_arg_string(2, "TERRORIST");
			}
		} case 'T': {
			if((g_Mode == MODE_SWARM || g_Mode == MODE_SURVIVOR || g_Mode == MODE_JERUZALEM) && getHumans()) {
				g_RespawnAsZombie[id] = 1;

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_TERRORIST);

				set_msg_arg_string(2, "TERRORIST");
			} else if(getZombies()) {
				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_CT);

				set_msg_arg_string(2, "CT");
			}
		}
	}
}

public message__ShowMenu(const msg_id, const dest, const id)
{
	static sMenuCode[32];
	get_msg_arg_string(4, sMenuCode, 31);

	if(equal(sMenuCode, "#Team_Select") || equal(sMenuCode, "#Team_Select_Spect"))
	{
		if(get_member(id, m_iTeam) == TEAM_UNASSIGNED)
		{
			static sArgs[1];
			sArgs[0] = msg_id;

			set_task(0.1, "task__AutoJoinToSpec", id, sArgs, 1);
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public message__VGUIMenu(const msg_id, const dest, const id)
{
	if(get_msg_arg_int(1) != 2)
		return PLUGIN_CONTINUE;

	if(get_member(id, m_iTeam) == TEAM_UNASSIGNED)
	{
		static sArgs[1];
		sArgs[0] = msg_id;

		set_task(0.1, "task__AutoJoinToSpec", id, sArgs, 1);
	}

	return PLUGIN_HANDLED;
}

public task__AutoJoinToSpec(const sArgs[1], const id)
{
	if(!is_user_connected(id))
		return;

	static iMsgBlock;
	iMsgBlock = get_msg_block(sArgs[0]);

	set_msg_block(sArgs[0], BLOCK_SET);
	setUserTeamForce(id, "6");
	set_msg_block(sArgs[0], iMsgBlock);
}

public impulse__Flashlight(const id)
{
	if(g_Zombie[id])
	{
		if(!g_IsAlive[id])
		{
			dg_color_chat(id, _, "Debes estar vivo para utilizar este comando");
			return PLUGIN_HANDLED;
		}
		else if(g_SpecialMode[id])
		{
			dg_color_chat(id, _, "Debes ser zombie para utilizar este comando");
			return PLUGIN_HANDLED;
		}
		else
		{
			switch(g_ZombieClass[id])
			{
				case ZOMBIE_CLASS_HEAVY:
				{
					if(!g_ZombieClassHeavy_MakeTramp[id])
					{
						dg_color_chat(id, _, "Debes esperar !g10 segundos!y para volver a colocar una trampa");
						return PLUGIN_HANDLED;
					}
					else if(g_ZombieClassHeavy_TrampCount == 3)
					{
						dg_color_chat(id, _, "Ya has pasado el límite de trampas");
						return PLUGIN_HANDLED;
					}

					new iEntTramp = create_entity("info_target");

					if(is_valid_ent(iEntTramp))
					{
						new Float:vecOrigin[3];
						entity_get_vector(id, EV_VEC_origin, vecOrigin);

						vecOrigin[2] -= 35.0;

						entity_set_vector(iEntTramp, EV_VEC_origin, vecOrigin);
						entity_set_string(iEntTramp, EV_SZ_classname, "entZombieHeavyTramp");
						entity_set_model(iEntTramp, MODEL_TRAMP);
						entity_set_int(iEntTramp, EV_INT_solid, SOLID_TRIGGER);

						entity_set_float(iEntTramp, EV_FL_takedamage, 1.0);
						entity_set_float(iEntTramp, EV_FL_health, 100.0);

						entity_set_byte(iEntTramp, EV_BYTE_controller1, 125);
						entity_set_byte(iEntTramp, EV_BYTE_controller2, 125);
						entity_set_byte(iEntTramp, EV_BYTE_controller3, 125);
						entity_set_byte(iEntTramp, EV_BYTE_controller4, 125);

						entity_set_size(iEntTramp, Float:{-5.0, -5.0, -5.0}, Float:{5.0, 5.0, 5.0});

						entity_set_float(iEntTramp, EV_FL_animtime, 2.0);
						entity_set_float(iEntTramp, EV_FL_framerate, 1.0);
						entity_set_int(iEntTramp, EV_INT_sequence, 0);

						drop_to_floor(iEntTramp);

						g_ZombieClassHeavy_MakeTramp[id] = 0;
						++g_ZombieClassHeavy_TrampCount;

						remove_task(id + TASK_ZHEAVY_COOLDOWN);
						set_task(10.0, "task__ZombieHeavyCooldown", id + TASK_ZHEAVY_COOLDOWN);
					}
				}
				case ZOMBIE_CLASS_BANCHEE:
				{
					if(!g_ZombieClassBanchee_BatTime[id])
					{
						dg_color_chat(id, _, "Debes esperar !g10 segundos!y para volver a lanzar murcielagos");
						return PLUGIN_HANDLED;
					}

					new iEntBanchee = create_entity("info_target");

					if(is_valid_ent(iEntBanchee))
					{
						new Float:vecOrigin[3];
						new Float:vecAngle[3];
						new Float:vecForward[3];
						new Float:vecVelocity[3];

						getUserStartpos(id, 5.0, 2.0, -1.0, vecOrigin);

						entity_get_vector(id, EV_VEC_angles, vecAngle);
						engfunc(EngFunc_MakeVectors, vecAngle);
						global_get(glb_v_forward, vecForward);

						velocity_by_aim(id, 600, vecVelocity);

						entity_set_vector(iEntBanchee, EV_VEC_origin, vecOrigin);
						entity_set_vector(iEntBanchee, EV_VEC_angles, vecAngle);

						entity_set_model(iEntBanchee, MODEL_BANCHEE);
						entity_set_string(iEntBanchee, EV_SZ_classname, "entZombieBanchee");
						entity_set_int(iEntBanchee, EV_INT_movetype, MOVETYPE_FLY);
						entity_set_int(iEntBanchee, EV_INT_solid, SOLID_BBOX);

						entity_set_size(iEntBanchee, Float:{-20.0,-15.0, -8.0}, Float:{20.0, 15.0, 8.0});

						entity_set_float(iEntBanchee, EV_FL_animtime, get_gametime());
						entity_set_float(iEntBanchee, EV_FL_framerate, 1.0);
						entity_set_edict(iEntBanchee, EV_ENT_owner, id);
						entity_set_vector(iEntBanchee, EV_VEC_velocity, vecVelocity);
						entity_set_float(iEntBanchee, EV_FL_nextthink, (get_gametime() + 3.0));

						emit_sound(iEntBanchee, CHAN_WEAPON, SOUND_BANCHEE_FIRE, 1.0, ATTN_NORM, 0, PITCH_NORM);

						setUserAnimation(id, 2);

						g_ZombieClassBanchee_BatTime[id] = 0;
						g_Speed[id] = 1.0;

						ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

						remove_task(id + TASK_ZBANCHEE_START);
						set_task(10.0, "task__ZombieBancheeStart", id + TASK_ZBANCHEE_START);
					}
				}
				case ZOMBIE_CLASS_VOODOO:
				{
					if(!g_ZombieClassVoodoo_CanHealth[id])
					{
						dg_color_chat(id, _, "Debes esperar !g15 segundos!y para volver a curar a tus compañeros zombies");
						return PLUGIN_HANDLED;
					}

					new iDistance;
					new i;
					new Float:vecOrigin[3];

					for(i = 1; i <= MaxClients; ++i)
					{
						if(g_IsAlive[i] && g_Zombie[i] && !g_SpecialMode[i])
						{
							iDistance = get_entity_distance(i, id);

							if(iDistance <= 300) 
							{
								entity_get_vector(i, EV_VEC_origin, vecOrigin);

								engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
								write_byte(TE_SPRITE);
								engfunc(EngFunc_WriteCoord, vecOrigin[0]);
								engfunc(EngFunc_WriteCoord, vecOrigin[1]);
								engfunc(EngFunc_WriteCoord, vecOrigin[2] + 20.0);
								write_short(g_ZombieClassVoodoo_Sprite);
								write_byte(0);
								write_byte(200);
								message_end();

								if(g_Health[i] < g_MaxHealth[i])
								{
									set_user_health(i, (g_Health[id] + 1500));
									g_Health[i] = get_user_health(i);
								}
							}
						}
					}

					g_ZombieClassVoodoo_CanHealth[id] = 0;

					remove_task(id + TASK_ZVOODOO_COOLDOWN);
					set_task(15.0, "task__ZombieVoodooCooldown", id + TASK_ZVOODOO_COOLDOWN);
				}
				case ZOMBIE_CLASS_LUSTYROSE:
				{
					if(g_ZombieClassLusty_Invi[id] || g_ZombieClassLusty_InviWait[id])
					{
						if(g_ZombieClassLusty_Invi[id])
							dg_color_chat(id, _, "Debes esperar !g10 segundos!y para volver a hacerte invisible");
						else
							dg_color_chat(id, _, "Debes esperar a que termine tu invisibilidad, luego espera !g10 segundos!y para volver a utilizar tu habilidad");
						
						return PLUGIN_HANDLED;
					}

					new iPercent = ((20 * g_Health[id]) / 100);
					new iHealth = (g_Health[id] - iPercent);

					set_user_health(id, iHealth);
					g_Health[id] = get_user_health(id);

					set_user_rendering(id, kRenderFxGlowShell, 15, 15, 15, kRenderTransAlpha, 4);
					set_user_footsteps(id, 1);

					replaceWeaponModels(id, CSW_KNIFE);

					remove_task(id + TASK_ZLUSTY_INVI);
					set_task(10.0, "task__ZombieLustyInvi", id + TASK_ZLUSTY_INVI);

					g_ZombieClassLusty_Invi[id] = 1;
					g_ZombieClassLusty_InviWait[id] = 1;
				}
				case ZOMBIE_CLASS_TOXICO:
				{
					new Float:flGameTime = get_gametime();

					if((flGameTime - g_ZombieClassToxico_LastUsed[id]) < 20.0)
					{
						dg_color_chat(id, _, "Debes esperar !g20 segundos!y para volver a escupir ácido");
						return PLUGIN_HANDLED;
					}

					g_ZombieClassToxico_LastUsed[id] = flGameTime;

					new NewEnt = create_entity("info_target");

					if(is_valid_ent(NewEnt))
					{
						new Float:Origin[3];
						new Float:Velocity[3];
						new Float:vAngle[3];

						entity_get_vector(id, EV_VEC_origin, Origin);
						entity_get_vector(id, EV_VEC_v_angle, vAngle);
						
						entity_set_string(NewEnt, EV_SZ_classname, "entZombieToxic");
						entity_set_model(NewEnt, MODEL_SPIT);
						entity_set_size(NewEnt, Float:{-1.5, -1.5, -1.5}, Float:{1.5, 1.5, 1.5});
						entity_set_origin(NewEnt, Origin);
						entity_set_vector(NewEnt, EV_VEC_angles, vAngle);
						entity_set_int(NewEnt, EV_INT_solid, 2);
						entity_set_int(NewEnt, EV_INT_rendermode, 5);
						entity_set_float(NewEnt, EV_FL_renderamt, 200.0);
						entity_set_float(NewEnt, EV_FL_scale, 1.00);
						entity_set_int(NewEnt, EV_INT_movetype, 5);
						entity_set_edict(NewEnt, EV_ENT_owner, id);
						velocity_by_aim(id, 700, Velocity);
						entity_set_vector(NewEnt, EV_VEC_velocity, Velocity);

						message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
						write_byte(TE_BEAMFOLLOW);
						write_short(NewEnt);
						write_short(g_Sprite_Laserbeam);
						write_byte(10);
						write_byte(10);
						write_byte(0);
						write_byte(250);
						write_byte(0);
						write_byte(200);
						message_end();

						emit_sound(id, CHAN_STREAM, SOUND_TOXIC_SPIT_LAUNCH, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

						if((g_Health[id] - 250) > 0)
						{
							fakedamage(id, "Spit acid", 250.0, 256);

							new origin1[3];
							get_user_origin(id, origin1);
							bubble_break(id, origin1);
						}
					}
				}
			}
		}

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public touch__Toxic(const ent, const id)
{
	if(!pev_valid(ent))
		return;
		
	new sClassName[32];
	entity_get_string(id, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(equal(sClassName, "player"))
	{
		if(isUserValidAlive(id))
		{
			if(!g_Zombie[id] && !g_SpecialMode[id])
			{
				new iOwner = entity_get_edict(ent, EV_ENT_owner);
				new iHealth = get_user_health(id);

				if(iHealth >= 1 && iHealth <= 25)
				{
					emit_sound(id, CHAN_BODY, SOUND_TOXIC_SPIT_HIT, 1.0, ATTN_NORM, 0, PITCH_NORM);
					ExecuteHamB(Ham_Killed, id, iOwner, 0);

					++g_AmmoPacks[iOwner];

					new origin1[3];
					get_user_origin(id, origin1);
					bubble_break(id, origin1);
				}
				else
				{	
					emit_sound(id, CHAN_BODY, SOUND_TOXIC_SPIT_HIT, 1.0, ATTN_NORM, 0, PITCH_NORM);

					set_user_health(id, g_Health[id] - 25);
					g_Health[id] = get_user_health(id);

					++g_AmmoPacks[iOwner];

					new origin1[3];
					get_user_origin(id, origin1);
					bubble_break(id, origin1);
				}
			}
			else
			{
				emit_sound(id, CHAN_BODY, SOUND_TOXIC_SPIT_HIT, 1.0, ATTN_NORM, 0, PITCH_NORM);

				new origin1[3];
				get_user_origin(id, origin1);
				bubble_break(id, origin1);
			}
		}
	}

	if(equal(sClassName, "func_breakable") && entity_get_int(id, EV_INT_solid) != SOLID_NOT)
		force_use(ent, id);

	remove_entity(ent);
}

public bubble_break(const id, const origin1[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin1);
	write_byte(TE_BREAKMODEL);
	write_coord(origin1[0]);
	write_coord(origin1[1]);
	write_coord(origin1[2] + 24);
	write_coord(16);
	write_coord(16);
	write_coord(16);
	write_coord(random_num(-50, 50));
	write_coord(random_num(-50, 50));
	write_coord(25);
	write_byte(10);
	write_short(g_ZombieClassToxic_Sprite);
	write_byte(10);
	write_byte(38);
	write_byte(BREAK_GLASS);
	message_end();
}

public task__ZombieLustyInvi(task_id)
{
	new iId = (task_id - TASK_ZLUSTY_INVI);

	if(!g_IsAlive[iId])
	{
		remove_task(task_id);
		return;
	}

	g_ZombieClassLusty_Invi[iId] = 0;
	if(!g_ZombieClassLusty_InviWait[iId]) g_ZombieClassLusty_InviWait[iId] = 1;

	set_user_rendering(iId);
	set_user_footsteps(iId, 0);

	replaceWeaponModels(iId, CSW_KNIFE);

	remove_task(iId + TASK_ZLUSTY_INVI_WAIT);
	set_task(10.0, "task__ZombieLustyInviWait", iId + TASK_ZLUSTY_INVI_WAIT);
}

public task__ZombieLustyInviWait(task_id)
{
	new iId = (task_id - TASK_ZLUSTY_INVI_WAIT);

	if(!g_IsAlive[iId])
	{
		remove_task(task_id);
		return;
	}

	g_ZombieClassLusty_InviWait[iId] = 0;

	dg_color_chat(iId, _, "Puedes volver a utilizar tu habilidad");

	replaceWeaponModels(iId, CSW_KNIFE);
}

public task__ZombieVoodooCooldown(task_id)
{
	new iId = (task_id - TASK_ZVOODOO_COOLDOWN);

	if(!g_IsAlive[iId])
	{
		remove_task(task_id);
		return;
	}

	dg_color_chat(iId, _, "Puedes volver a utilizar tu habilidad");
	g_ZombieClassVoodoo_CanHealth[iId] = 1;
}

public task__ZombieBancheeStart(task_id)
{
	new iId = (task_id - TASK_ZBANCHEE_START);

	if(!g_IsAlive[iId])
	{
		remove_task(task_id);
		return;
	}

	dg_color_chat(iId, _, "Puedes volver a utilizar tu habilidad");

	g_ZombieClassBanchee_BatTime[iId] = 1;
	g_ZombieClassBanchee_Stat[iId] = 0;
}

public getUserStartpos(const id, const Float:forwardd, const Float:right, const Float:up, Float:vecStart[])
{
	new Float:vecOrigin[3];
	new Float:vecAngle[3];
	new Float:vecForward[3];
	new Float:vecRight[3];
	new Float:vecUp[3];
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	entity_get_vector(id, EV_VEC_v_angle, vecAngle);
	
	engfunc(EngFunc_MakeVectors, vecAngle);
	
	global_get(glb_v_forward, vecForward);
	global_get(glb_v_right, vecRight);
	global_get(glb_v_up, vecUp);
	
	vecStart[0] = (vecOrigin[0] + (vecForward[0] * forwardd) + (vecRight[0] * right) + (vecUp[0] * up));
	vecStart[1] = (vecOrigin[1] + (vecForward[1] * forwardd) + (vecRight[1] * right) + (vecUp[1] * up));
	vecStart[2] = (vecOrigin[2] + (vecForward[2] * forwardd) + (vecRight[2] * right) + (vecUp[2] * up));
}

public task__ZombieHeavyCooldown(task_id)
{
	new iId = (task_id - TASK_ZHEAVY_COOLDOWN);

	if(!g_IsAlive[iId] || !g_Zombie[iId] || g_SpecialMode[iId] || g_ZombieClass[iId] != ZOMBIE_CLASS_HEAVY)
	{
		remove_task(task_id);
		return;
	}

	dg_color_chat(iId, _, "Puedes volver a utilizar tu habilidad");
	g_ZombieClassHeavy_MakeTramp[iId] = 1;
}

public impulse__Spray() {
	return PLUGIN_HANDLED;
}

public task__StartSQL()
{
	server_cmd("sv_voicecodec ^"voice_speex^"");

	set_cvar_num("sv_alltalk", 1);
	set_cvar_num("sv_voicequality", 3);
	set_cvar_num("sv_airaccelerate", 100);
	set_cvar_num("sv_voiceenable", 1);
	set_cvar_num("sv_maxspeed", 500);
	set_cvar_num("mp_flashlight", 0);
	set_cvar_num("mp_footsteps", 1);
	set_cvar_num("mp_freezetime", 0);
	set_cvar_num("mp_friendlyfire", 0);
	set_cvar_num("mp_limitteams", 0);
	set_cvar_num("mp_autoteambalance", 0);
	set_cvar_float("mp_roundtime", 6.0);
	set_cvar_num("allow_spectators", 1);

	server_cmd("sv_restart 1");

	new iError;

	g_SqlTuple = SQL_MakeDbTuple(SQL_HOST, SQL_USER, SQL_PASSWORD, SQL_DATABASE);
	g_SqlConnection = SQL_Connect(g_SqlTuple, iError, g_SQLErrors, charsmax(g_SQLErrors));

	if(g_SqlConnection == Empty_Handle)
	{
		log_to_file(LOGFILE_SQL_ERRORS, " - LOG: [-1] - %s", g_SQLErrors);

		set_fail_state("Hubo un error al conectar con la base de datos (SQL_Connect - Method[])");
		return;
	}

	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT COUNT(id) FROM ze1_users;");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CountAccounts", g_SQLQuery);

	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT ze1_users.username, achievement_id, achievement_date FROM ze1_achievements LEFT JOIN ze1_users ON ze1_users.id=ze1_achievements.ze_id WHERE achievement_first='1';");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadAchievementsF", g_SQLQuery);

	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT username, level, exp FROM ze1_users WHERE ban <> 1 ORDER BY level DESC, exp DESC LIMIT 1;");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadLeader00", g_SQLQuery);

	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT username, time_played FROM ze1_users WHERE ban <> 1 ORDER BY time_played DESC LIMIT 1;");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadLeader01", g_SQLQuery);

	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT ze1_users.username, achievement_d FROM ze1_users LEFT JOIN ze1_stats ON ze1_users.id=ze1_stats.ze_id WHERE ze1_users.ban <> 1 ORDER BY achievement_d DESC LIMIT 1;");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadLeader02", g_SQLQuery);

	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT button_id FROM ze1_escape_buttons WHERE mapname=^"%s^" LIMIT 1;", g_MapName);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadEscapeButton", g_SQLQuery);

	new iThinkTOP = create_entity("info_target");
	if(is_valid_ent(iThinkTOP))
	{
		entity_set_string(iThinkTOP, EV_SZ_classname, "entThink__Tops");
		entity_set_float(iThinkTOP, EV_FL_nextthink, get_gametime() + 300.0);

		register_think("entThink__Tops", "think__Tops");
	}

	checkSupplyBox();
	checkAutoModeJeruzalem();
	checkCrazyMode();
}

public sqlThread__CountAccounts(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime)
{
	if(failstate != TQUERY_SUCCESS)
	{
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__CountAccounts - %d - %s", errorNum, error);
		return;
	}

	if(!SQL_NumResults(query))
		return;

	g_RankGlobal = SQL_ReadResult(query, 0);
}

public sqlThread__LoadAchievementsF(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime)
{
	if(failstate != TQUERY_SUCCESS)
	{
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadAchievementsF - %d - %s", errorNum, error);
		return;
	}

	if(!SQL_NumResults(query))
		return;

	new iAchievementId;

	while(SQL_MoreResults(query))
	{
		iAchievementId = SQL_ReadResult(query, 1);

		SQL_ReadResult(query, 0, g_AchievementName[0][iAchievementId], charsmax(g_AchievementName[][]));
		g_Achievement[0][iAchievementId] = 1;
		SQL_ReadResult(query, 2, g_AchievementUnlocked[0][iAchievementId], 31);

		SQL_NextRow(query);
	}
}

public sqlThread__LoadLeader00(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime)
{
	if(failstate != TQUERY_SUCCESS)
	{
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadLeader00 - %d - %s", errorNum, error);
		return;
	}

	if(!SQL_NumResults(query))
		return;

	SQL_ReadResult(query, 0, g_LeaderLevel_Name, 31);
	g_LeaderLevel_Level = SQL_ReadResult(query, 1);
	addDot(SQL_ReadResult(query, 2), g_LeaderLevel_Exp, 11);
}

public sqlThread__LoadLeader01(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime)
{
	if(failstate != TQUERY_SUCCESS)
	{
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadLeader01 - %d - %s", errorNum, error);
		return;
	}

	if(!SQL_NumResults(query))
		return;

	SQL_ReadResult(query, 0, g_LeaderTime_Name, 31);
	g_LeaderTime_Minutes = SQL_ReadResult(query, 1);

	g_LeaderTime_Days = 0;
	g_LeaderTime_Hours = (g_LeaderTime_Minutes / 60);

	while(g_LeaderTime_Hours >= 24)
	{
		++g_LeaderTime_Days;
		g_LeaderTime_Hours -= 24;
	}

	g_LeaderTime_Minutes -= ((g_LeaderTime_Hours * 60) + (g_LeaderTime_Days * 24 * 60));
}

public sqlThread__LoadLeader02(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime)
{
	if(failstate != TQUERY_SUCCESS)
	{
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadLeader02 - %d - %s", errorNum, error);
		return;
	}

	if(!SQL_NumResults(query))
		return;

	SQL_ReadResult(query, 0, g_LeaderAchievement_Name, 31);
	g_LeaderAchievement_Total = SQL_ReadResult(query, 1);
}

public sqlThread__LoadSupplyBox(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime)
{
	if(failstate != TQUERY_SUCCESS)
	{
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadSupplyBox - %d - %s", errorNum, error);
		return;
	}

	g_DB_SupplyBox = 0;

	if(!SQL_NumResults(query))
		return;

	new i = 0;

	while(SQL_MoreResults(query))
	{
		SQL_ReadResult(query, 0, Float:g_DB_SupplyBox_Position[i][0]);
		SQL_ReadResult(query, 1, Float:g_DB_SupplyBox_Position[i][1]);
		SQL_ReadResult(query, 2, Float:g_DB_SupplyBox_Position[i][2]);
		SQL_ReadResult(query, 3, Float:g_DB_SupplyBox_Angles[i][0]);
		SQL_ReadResult(query, 4, Float:g_DB_SupplyBox_Angles[i][1]);
		SQL_ReadResult(query, 5, Float:g_DB_SupplyBox_Angles[i][2]);

		++i;
		++g_DB_SupplyBox;

		SQL_NextRow(query);
	}
}

public loadSupplybox(Float:vecOrigin[3], Float:vecAngles[3], eUser4)
{
	g_Supplybox[g_SupplyboxNums] = create_entity("info_target");

	if(is_valid_ent(g_Supplybox[g_SupplyboxNums]))
	{
		entity_set_string(g_Supplybox[g_SupplyboxNums], EV_SZ_classname, "ent__Supplybox");

		dllfunc(DLLFunc_Spawn, g_Supplybox[g_SupplyboxNums]);

		g_SupplyboxOrigin[g_SupplyboxNums][0] = vecOrigin[0];
		g_SupplyboxOrigin[g_SupplyboxNums][1] = vecOrigin[1];
		g_SupplyboxOrigin[g_SupplyboxNums][2] = vecOrigin[2] + 32.0;

		entity_set_model(g_Supplybox[g_SupplyboxNums], MODEL_SUPPLYBOX);
		entity_set_origin(g_Supplybox[g_SupplyboxNums], g_SupplyboxOrigin[g_SupplyboxNums]);
		entity_set_vector(g_Supplybox[g_SupplyboxNums], EV_VEC_angles, vecAngles);

		entity_set_size(g_Supplybox[g_SupplyboxNums], Float:{-2.0, -2.0, -2.0}, Float:{5.0, 5.0, 5.0});

		entity_set_int(g_Supplybox[g_SupplyboxNums], EV_INT_solid, SOLID_TRIGGER);
		entity_set_int(g_Supplybox[g_SupplyboxNums], EV_INT_movetype, MOVETYPE_TOSS);

		drop_to_floor(g_Supplybox[g_SupplyboxNums]);

		entity_set_edict(g_Supplybox[g_SupplyboxNums], EV_ENT_euser4, eUser4);

		entity_set_int(g_Supplybox[g_SupplyboxNums], EV_INT_sequence, 0);
		entity_set_float(g_Supplybox[g_SupplyboxNums], EV_FL_animtime, get_gametime());
		entity_set_float(g_Supplybox[g_SupplyboxNums], EV_FL_framerate, 1.0);

		//set_rendering(g_Supplybox[g_SupplyboxNums], kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16);
	}

	++g_SupplyboxNums;
}

public think__Tops(const ent)
{
	switch(g_LeaderType)
	{
		case 0: dg_color_chat(0, _, "!t%s!y está liderando en !gniveles!y siendo !gnivel %d!y con !g%s de EXP!y", g_LeaderLevel_Name, g_LeaderLevel_Level, g_LeaderLevel_Exp);
		case 1: dg_color_chat(0, _, "!t%s!y es el más !gviciado del servidor!y con !g%d días!y, !g%d horas!y y !g%d minutos!y jugados", g_LeaderTime_Name, g_LeaderTime_Days, g_LeaderTime_Hours, g_LeaderTime_Minutes);
		case 2: dg_color_chat(0, _, "!t%s!y está liderando en !glogros hechos!y con !g%d!y logros", g_LeaderAchievement_Name, g_LeaderAchievement_Total);
	}

	if(++g_LeaderType == 3)
		g_LeaderType = 0;

	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 300.0);
}

public executeQuery(const id, const Handle:query, const queryId)
{
	SQL_QueryError(query, g_SQLErrors, charsmax(g_SQLErrors));
	log_to_file(LOGFILE_SQL_ERRORS, " - LOG: [%d] - %s", queryId, g_SQLErrors);

	if(isUserValidConnected(id))
		server_cmd("kick #%d ^"Hubo un error al guardar/cargar tus datos. Intente mas tarde^"", get_user_userid(id));

	SQL_FreeHandle(query);
}

public task__RemoveStuff()
{
	new iEnt = -1;

	while((iEnt = find_ent_by_class(iEnt, "func_button")) > 0)
		call_think(iEnt);

	while((iEnt = fm_find_ent_by_class(iEnt, "trigger_hurt")))
	{
		if(is_valid_ent(iEnt) && entity_get_float(iEnt, EV_FL_dmg) == 50000.0)
			entity_set_float(iEnt, EV_FL_dmg, 0.0);
	}

	removeTramp();
}

public task__VirusT() {
	if(!g_CouldDown) {
		ClearSyncHud(0, g_Hud_Cooldown);

		remove_task(TASK_COUNTDOWN);
		return;
	}

	if(g_CouldDown == get_pcvar_num(g_Cvar_CountDown)) {
		set_hudmessage(255, 0, 0, -1.0, 0.25, 1, 3.0, 4.0, 4.0, 3.0, -1);
		ShowSyncHudMsg(0, g_Hud_Event, "¡ EL VIRUS-T SE HA LIBERADO !");
	} else if(g_CouldDown <= 5) {
		ClearSyncHud(0, g_Hud_Event);

		static sBuffer[64];
		static sNum[3];

		num_to_str(g_CouldDown, sNum, charsmax(sNum));
		formatex(sBuffer, charsmax(sBuffer), "zombie_escape/conteo/%s.wav", sNum);

		playSound(0, sBuffer);

		set_hudmessage(random(256), random(256), random(256), -1.0, 0.4, 2, 0.02, 1.0, 0.01, 0.1, 10);
		ShowSyncHudMsg(0, g_Hud_Cooldown, "¡Faltan %d segundo%s para que comience el modo!", g_CouldDown, (g_CouldDown != 1) ? "s" : "");
	}

	--g_CouldDown;

	set_task(1.0, "task__VirusT", TASK_COUNTDOWN);
}

public task__StartMode() {
	new iUsersAlive = getAlives();

	if(iUsersAlive < 4) {
		client_print(0, print_center, "Se necesitan +4 jugadores vivos para que comience un modo!");

		set_task(10.0, "task__StartMode", TASK_STARTMODE);
		return;
	}

	if(g_AutoMode_Jeruzalem_Enabled && g_AutoMode_Jeruzalem_Count < 2) {
		if(!g_AutoMode_Jeruzalem_RoundsLeft) {
			setMode(MODE_JERUZALEM);
			return;
		} else {
			--g_AutoMode_Jeruzalem_RoundsLeft;

			new sQuery[128];
			formatex(sQuery, 127, "UPDATE ze1_general SET automode_jeruzalem_rounds='%d' WHERE id=1;", g_AutoMode_Jeruzalem_RoundsLeft);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__SaveAndIgnore", sQuery);
		}
	}

	static iUsersNeed;
	static iChance;
	static iMode;
	static i;

	iMode = 0;

	for(i = 0; i < structIdModes; ++i) {
		iUsersNeed = __MODES[i][modeUsersNeed];
		iChance = __MODES[i][modeScore];

		if(!iChance || !iUsersNeed) {
			continue;
		}

		if(random_num(1, iChance) != 1 || iUsersAlive < iUsersNeed || g_LastMode == i) {
			continue;
		}

		iMode = i;
		break;
	}

	if(iMode) {
		setMode(iMode);
	} else {
		setMode(MODE_MULTI);
	}
}

public task__ArmageddonStartPre() {
	static i;
	static j;

	j = random_num(0, 1);

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!g_IsAlive[i]) {
			continue;
		}

		if(!j) {
			if(get_member(i, m_iTeam) == TEAM_TERRORIST) {
				humanMe(i, .survivor=1);
			} else {
				zombieMe(i, .nemesis=1);
			}
		} else {
			if(get_member(i, m_iTeam) == TEAM_TERRORIST) {
				zombieMe(i, .nemesis=1);
			} else {
				humanMe(i, .survivor=1);
			}
		}

		strip_user_weapons(i);
	}
}

public task__ArmageddonStartPost() {
	g_ModeArmageddon_NoDamage = 0;

	set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
	ShowSyncHudMsg(0, g_Hud_Event, "¡ARMAGEDDON!");

	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!g_IsAlive[i]) {
			continue;
		}

		randomSpawn(i);

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, i);
		write_short((UNIT_SECOND) * 2);
		write_short(0);
		write_short(FFADE_IN);
		write_byte(255);
		write_byte(255);
		write_byte(0);
		write_byte(255);
		message_end();

		give_item(i, "weapon_knife");
		if(!g_Zombie[i]) {
			give_item(i, "weapon_m249");
		}
	}

	playSound(0, SOUND_ROUND_GENERAL[random_num(2, charsmax(SOUND_ROUND_GENERAL))]);
}

public task__AmbienceSoundsEffect() {
	if(!g_AmbienceSounds[g_Mode]) {
		return;
	}

	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsConnected[i]) {
			if((g_AmbienceSound_Muted[i] & AMBIENCE_MUTED_SOUNDS[g_Mode][1]) == AMBIENCE_MUTED_SOUNDS[g_Mode][1]) {
				continue;
			}

			playSound(i, SOUND_AMBIENCE[g_Mode]);
		}
	}

	set_task(120.0, "task__AmbienceSoundsEffect", TASK_AMBIENCESOUNDS);
}

public task__CheckAccount(taskId)
{
	static iId;
	iId = taskId - TASK_CHECK_ACCOUNT;

	if(!is_user_connected(iId))
		return;

	g_AccountCheck[iId] = 1;
	g_AccountLoading[iId] = 1;

	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id, password, ip, register_since, last_connection, ban, expire_ban, admin_ban, reason_ban, vinc FROM ze1_users WHERE username=^"%s^";", g_User_Name[iId]);
	if(!SQL_Execute(sqlQuery))
		executeQuery(iId, sqlQuery, 123);
	else if(SQL_NumResults(sqlQuery))
	{
		g_Account_Register[iId] = 1;

		new sPassword[24];
		new sIPdb[21];

		g_Account_Id[iId] = SQL_ReadResult(sqlQuery, 0);
		SQL_ReadResult(sqlQuery, 1, g_Account_Password[iId], 23);
		SQL_ReadResult(sqlQuery, 2, sIPdb, 20);
		SQL_ReadResult(sqlQuery, 3, g_Account_RegisterSince[iId], 31);
		SQL_ReadResult(sqlQuery, 4, g_Account_LastConnection[iId], 31);
		g_Account_Banned[iId] = SQL_ReadResult(sqlQuery, 5);
		// 6 = EXPIRE_BAN
		// 7 = ADMIN_BAN
		// 8 = REASON_BAN
		// 9 = VINC

		get_user_info(iId, "ze1", sPassword, 23);

		if(g_Account_Banned[iId]) // 5 = BAN
		{
			SQL_FreeHandle(sqlQuery);

			// ...
		}
		else
		{
			SQL_FreeHandle(sqlQuery);

			if(equal(sIPdb, g_User_Ip[iId]) && equal(g_Account_Password[iId], sPassword))
			{
				g_Account_Logged[iId] = 1;
				g_AccountJoined[iId] = 1;

				g_SysTime_In[iId] = get_systime();

				loadInfo(iId);

				remove_task(iId + TASK_SAVE);
				set_task(random_float(300.0, 600.0), "task__SaveInfo", iId + TASK_SAVE, .flags="b");

				remove_task(iId + TASK_HELLOAGAIN);
				set_task(random_float(5.0, 15.0), "task__HelloAgain", iId + TASK_HELLOAGAIN);
			}
		}

		g_AccountLoading[iId] = 0;
		clcmd__ChangeTeam(iId);
	}
	else
	{
		g_AccountLoading[iId] = 0;

		SQL_FreeHandle(sqlQuery);
		clcmd__ChangeTeam(iId);
	}
}

public task__ModifCommands(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	client_cmd(id, "cl_minmodels 0");
	client_cmd(id, "cl_solid_players 1");

	if(get_user_flags(id) & ADMIN_RESERVATION) {
		g_AccountPremium[id] = 1;

		if(get_user_flags(id) & ADMIN_IMMUNITY) {
			g_AccountPremium[id] = 2;
		}
	}
}

public task__SaveInfo(taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SAVE) : taskId;

	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	saveInfo(id);
}

public task__HelloAgain(taskId) {
	new id;
	id = taskId - TASK_HELLOAGAIN;

	if(!isUserValidConnected(id)) {
		return;
	}

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT COUNT(id) AS rank FROM ze1_users u WHERE (u.level > (SELECT level FROM ze1_users u2 WHERE u2.id = %d) OR (u.level = (SELECT level FROM ze1_users u2 WHERE u2.id = %d) AND u.id <= %d));", g_Account_Id[id], g_Account_Id[id], g_Account_Id[id]);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 50);
	} else if(SQL_NumResults(sqlQuery)) {
		g_Account_Rank[id] = SQL_ReadResult(sqlQuery, 0);
		SQL_FreeHandle(sqlQuery);
	} else {
		g_Account_Rank[id] = 0;
		SQL_FreeHandle(sqlQuery);
	}
}

public task__UserModelUpdate(const taskId) {
	static Float:fCurrentTime;
	fCurrentTime = get_gametime();

	if((fCurrentTime - g_ModelsTargetTime) >= MODELS_CHANGE_DELAY) {
		setUserModel(taskId);
		g_ModelsTargetTime = fCurrentTime;
	} else {
		set_task((g_ModelsTargetTime + MODELS_CHANGE_DELAY) - fCurrentTime, "setUserModel", taskId);
		g_ModelsTargetTime += MODELS_CHANGE_DELAY;
	}
}

public task__UserTeamUpdate(const id) {
	static Float:fCurrentTime;
	fCurrentTime = get_gametime();

	if(fCurrentTime - g_TeamsTargetTime >= 0.1) {
		set_task(0.1, "task__SetUserTeamMsg", id + TASK_TEAM);
		g_TeamsTargetTime = fCurrentTime + 0.1;
	} else {
		set_task((g_TeamsTargetTime + 0.1) - fCurrentTime, "task__SetUserTeamMsg", id + TASK_TEAM);
		g_TeamsTargetTime += 0.1;
	}
}

new const CS_TEAM_NAMES[][] = {"UNASSIGNED", "TERRORIST", "CT", "SPECTATOR"};

public task__SetUserTeamMsg(taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_TEAM) : taskId;

	if(!isUserValidConnected(id)) {
		return;
	}

	g_SwitchingTeams = 1;

	emessage_begin(MSG_ALL, g_Message_TeamInfo);
	ewrite_byte(id);
	ewrite_string(CS_TEAM_NAMES[get_member(id, m_iTeam)]);
	emessage_end();

	g_SwitchingTeams = 0;
}

public task__HideHUDs(const taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SPAWN) : taskId;

	if(!g_IsAlive[id]) {
		return;
	}

	message_begin(MSG_ONE, g_Message_HideWeapon, _, id);
	write_byte(HIDE_HUDS);
	message_end();

	message_begin(MSG_ONE, g_Message_Crosshair, _, id);
	write_byte(0);
	message_end();
}

public task__CheckStuck(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	if(isUserStuck(id)) {
		randomSpawn(id);
	}
}

public task__RefillBPAmmo(const args[], const id) {
	if(!g_IsAlive[id] || g_Zombie[id]) {
		return;
	}

	set_msg_block(g_Message_AmmoPickup, BLOCK_ONCE);
	ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[args[0]], AMMO_TYPE[args[0]], MAX_BPAMMO[args[0]]);
}

public task__RespawnUser(const taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SPAWN) : taskId;

	if(g_IsAlive[id] || g_EndRound) {
		return;
	}

	if(g_Mode != MODE_NEMESIS_EXTREM && g_MapEscaped) {
		return;
	}

	static TeamName:iTeam;
	iTeam = get_member(id, m_iTeam);

	if(iTeam == TEAM_SPECTATOR || iTeam == TEAM_UNASSIGNED) {
		return;
	}

	if(g_NewRound ||/* g_Mode == MODE_MULTI || g_Mode == MODE_MULTI_ORIGINAL ||*/ g_Mode == MODE_NEMESIS_EXTREM) {
		if(g_Mode == MODE_NEMESIS_EXTREM) {
			g_RespawnAsZombie[id] = 0;
		} else {
			g_RespawnAsZombie[id] = 1;
		}

		respawnUser(id);
	}
}

public task__RespawnUserCheck(const taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SPAWN) : taskId;

	if(g_IsAlive[id] || g_EndRound) {
		return;
	}

	static TeamName:iTeam;
	iTeam = get_member(id, m_iTeam);

	if(iTeam == TEAM_SPECTATOR || iTeam == TEAM_UNASSIGNED) {
		return;
	}

	g_RespawnAsZombie[id] = g_Zombie[id];
	respawnUser(id);
}

public task__BurningFlame(const taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_BURN) : taskId;

	if(!g_IsAlive[id]) {
		remove_task(taskId);
		return;
	}

	static vecOrigin[3];
	static iFlags;

	get_user_origin(id, vecOrigin);
	iFlags = get_entity_flags(id);

	if(g_Immunity[id] || (iFlags & FL_INWATER) || g_Burning_Duration[id] < 1) {
		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_SMOKE);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord(vecOrigin[2] - 50);
		write_short(g_Sprite_Smoke);
		write_byte(random_num(15, 20));
		write_byte(random_num(10, 20));
		message_end();

		remove_task(taskId);
		return;
	}

	if((g_Health[id] - 5) > 0) {
		set_user_health(id, (g_Health[id] - 5));
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

	--g_Burning_Duration[id];
}

public task__RemoveFreeze(const taskId)
{
	new id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_FROZEN) : taskId;

	if(!g_IsAlive[id] || !g_Frozen[id])
		return;

	g_Speed[id] = g_SpeedGravity[id];
	set_user_gravity(id, g_FrozenGravity[id]);
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	if(g_ZombieClass[id] == ZOMBIE_CLASS_LUSTYROSE && g_ZombieClassLusty_Invi[id])
		set_user_rendering(id, kRenderFxGlowShell, 15, 15, 15, kRenderTransAlpha, 4);
	else
		set_user_rendering(id);

	if(!g_MadnessBomb_Move[id])
	{
		message_begin(MSG_ONE, g_Message_ScreenFade, _, id);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_IN);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		write_byte(100);
		message_end();
	}

	static vecOrigin[3];
	get_user_origin(id, vecOrigin);

	message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_BREAKMODEL);
	write_coord(vecOrigin[0]);
	write_coord(vecOrigin[1]);
	write_coord(vecOrigin[2] + 24);
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

	g_Frozen[id] = 0;

	ExecuteForward(g_fwUnFrozen, g_fwDummy, id);
}

public task__RemoveMadness(const taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_MADNESS) : taskId;

	if(!g_IsAlive[id]) {
		return;
	}

	g_Immunity[id] = 0;
}

public task__ClearWeapons(const taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SPAWN) : taskId;

	if(!g_IsAlive[id]) {
		return;
	}

	strip_user_weapons(id);

	set_pdata_int(id, OFFSET_PRIMARY_WEAPON, OFFSET_LINUX);

	give_item(id, "weapon_knife");
}

public task__ShowMenuWeapons(const taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SPAWN) : taskId;

	if(!g_IsConnected[id]) {
		return;
	}

	if(g_Weapon_AutoBuy[id] && taskId > g_MaxUsers) {
		if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] || checkWeaponBuy(id)) {
			return;
		}

		buyPrimaryWeapon(id, g_WeaponPrimary_Selection[id]);
		buySecondaryWeapon(id, g_WeaponSecondary_Selection[id]);

		g_WeaponPrimary_Bought[id] = 1;
		g_WeaponSecondary_Bought[id] = 1;

		static iSelection;
		static i;

		iSelection = 0;

		for(i = 0; i < sizeof(GRENADES); ++i) {
			if(g_Level[id] >= GRENADES[iSelection][grenadeLevel]) {
				iSelection = i;
			}
		}

		if(GRENADES[iSelection][grenadeAmountHe]) {
			give_item(id, "weapon_hegrenade");
			cs_set_user_bpammo(id, CSW_HEGRENADE, GRENADES[iSelection][grenadeAmountHe]);
		}

		if(GRENADES[iSelection][grenadeAmountFb]) {
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id, CSW_FLASHBANG, GRENADES[iSelection][grenadeAmountFb]);
		}

		if(GRENADES[iSelection][grenadeAmountSg]) {
			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, GRENADES[iSelection][grenadeAmountSg]);

			g_GrenadeBomb[id] += GRENADES[iSelection][grenadeAmountSg];
		}

		return;
	}

	showMenu__BuyPrimaryWeapon(id);
}

public task__SetClassHumans(taskId) {
	new id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SPAWN) : taskId;

	if(!isUserValidAlive(id)) {
		return;
	}

	if(g_HumanClass[id]) {
		switch(g_HumanClass[id]) {
			case 6: {
				set_user_armor(id, 0);
			} case 7: {
				set_user_armor(id, 10);
			} case 9: {
				set_user_rendering(id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 5);
			} case HUMAN_MEDICO: {
				set_user_armor(id, 10);
				//set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 5);
			}
		}
	}

	if(get_user_flags(id) & ADMIN_RESERVATION) {
		set_user_armor(id, 100);
	}
}

public task__CheckAchievements(taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_CHECK_ACHIEVEMENTS) : taskId;

	if(!isUserValidConnected(id)) {
		return;
	}

	if((g_Account_Id[id] % 2) == 0) {
		setAchievement(id, CUENTA_PAR);
	} else {
		setAchievement(id, CUENTA_IMPAR);
	}

	if(get_user_flags(id) & ADMIN_RESERVATION) {
		setAchievement(id, SOY_DORADO);
	}

	if(g_Vinc[id])
		setAchievement(id, VINCULADO);

	if(g_Stats_General[id][STATS_HEAD_D] >= 5000)
	{
		setAchievement(id, HEAD_5000);
		if(g_Stats_General[id][STATS_HEAD_D] >= 15000)
		{
			setAchievement(id, HEAD_15000);
			if(g_Stats_General[id][STATS_HEAD_D] >= 50000)
			{
				setAchievement(id, HEAD_50000);
				if(g_Stats_General[id][STATS_HEAD_D] >= 150000)
				{
					setAchievement(id, HEAD_150K);
					if(g_Stats_General[id][STATS_HEAD_D] >= 300000)
					{
						setAchievement(id, HEAD_300K);
						if(g_Stats_General[id][STATS_HEAD_D] >= 500000)
						{
							setAchievement(id, HEAD_500K);
							if(g_Stats_General[id][STATS_HEAD_D] >= 1000000)
								setAchievement(id, HEAD_1M);
						}
					}
				}
			}
		}
	}

	if(g_Stats_DamageCount[id][0] >= 1000.0) // SI EL DIV_DAMAGE ES 1000 HAY QUE SACAR UN 0 EN TODOS
	{
		setAchievement(id, DANIO_100_000);
		if(g_Stats_DamageCount[id][0] >= 5000.0)
		{
			setAchievement(id, DANIO_500_000);
			if(g_Stats_DamageCount[id][0] >= 10000.0)
			{
				setAchievement(id, DANIO_1_000_000);
				if(g_Stats_DamageCount[id][0] >= 50000.0)
				{
					setAchievement(id, DANIO_5_000_000);
					if(g_Stats_DamageCount[id][0] >= 250000.0)
					{
						if(g_Stats_DamageCount[id][0] >= 500000.0)
						{
							if(g_Stats_DamageCount[id][0] >= 1000000.0)
							{
								if(g_Stats_DamageCount[id][0] >= 5000000.0)
								{
									if(g_Stats_DamageCount[id][0] >= 10000000.0)
									{
										if(g_Stats_DamageCount[id][0] >= 50000000.0)
										{
											if(g_Stats_DamageCount[id][0] >= 200000000.0)
											{
												if(g_Stats_DamageCount[id][0] >= 500000000.0)
												{
													if(g_Stats_DamageCount[id][0] >= 1000000000.0)
													{
														if(g_Stats_DamageCount[id][0] >= 2147483648.0)
															setAchievement(id, DANIO_EVER);
														else
															setAchievement(id, DANIO_100_000_000_000);
													}
													else
														setAchievement(id, DANIO_50_000_000_000);
												}
												else
													setAchievement(id, DANIO_20_000_000_000);
											}
											else
												setAchievement(id, DANIO_5_000_000_000);
										}
										else
											setAchievement(id, DANIO_1_000_000_000);
									}
									else
										setAchievement(id, DANIO_500_000_000);
								}
								else
									setAchievement(id, DANIO_100_000_000);
							}
							else
								setAchievement(id, DANIO_50_000_000);
						}
						else
							setAchievement(id, DANIO_25_000_000);
					}
				}
			}
		}
	}

	if(g_Level[id] >= 50) {
		setAchievement(id, NIVEL_50);

		if(g_Level[id] >= 100) {
			setAchievement(id, NIVEL_100);

			if(g_Level[id] >= 150) {
				setAchievement(id, NIVEL_150);

				if(g_Level[id] >= 200) {
					setAchievement(id, NIVEL_200);

					if(g_Level[id] >= 250) {
						setAchievement(id, NIVEL_250);
					}
				}
			}
		}
	}

	if(g_PlayedTime[id][2] == 7)
		setAchievement(id, ESTOY_MUY_SOLO);
	else if(g_PlayedTime[id][2] == 15)
		setAchievement(id, FOREVER_ALONE);
	else if(g_PlayedTime[id][2] == 30)
		setAchievement(id, CREO_QUE_TENGO_UN_PROBLEMA);
	else if(g_PlayedTime[id][2] == 50)
		setAchievement(id, SOLO_EL_ZE_ME_ENTIENDE);

	if(!g_MetaAchievement[id][MASTER_SUPPLY_BOXES] && g_Achievement[id][SUPPLY_BOX_X1] && g_Achievement[id][SUPPLY_BOX_X10] && g_Achievement[id][SUPPLY_BOX_X50] && g_Achievement[id][SUPPLY_BOX_X100] &&
	g_Achievement[id][SUPPLY_BOX_X500] && g_Achievement[id][SUPPLY_BOX_X1000] && g_Achievement[id][SUPPLY_BOX_X2_SAME_ROUND] && g_Achievement[id][SUPPLY_BOX_X3_SAME_ROUND] && g_Achievement[id][SUPPLY_BOX_X4_SAME_ROUND] && g_Achievement[id][SUPPLY_BOX_X5_SAME_ROUND]) {
		setMetaAchievement(id, MASTER_SUPPLY_BOXES);
	}

	if(g_VincAppMobile[id])
		setAchievement(id, APP_VINC);

	while(g_AchievementCount[id][APP_DAILY_VISIT] < g_DailyVisit[id])
		setAchievement(id, APP_DAILY_VISIT);
}

public checkSpawns() {
	static Float:vecOrigin[3];
	static iEnt;
	static i;

	for(i = 0; i < sizeof(SPAWN_NAME_ENTS); ++i) {
		iEnt = -1;

		while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", SPAWN_NAME_ENTS[i])) != 0) {
			entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);

			g_Spawns[g_SpawnCount][0] = vecOrigin[0];
			g_Spawns[g_SpawnCount][1] = vecOrigin[1];
			g_Spawns[g_SpawnCount][2] = vecOrigin[2];

			++g_SpawnCount;

			if(g_SpawnCount >= MAX_SPAWNS) {
				break;
			}
		}

		if(g_SpawnCount >= MAX_SPAWNS) {
			break;
		}
	}
}

public changeLights() {
	static i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!g_IsConnected[i]) {
			continue;
		}

		setLight(i, g_Lights[0]);
	}
}

public checkLastZombie() {
	static iZombies;
	static iHumans;
	static i;

	iZombies = getZombies();
	iHumans = getHumans();

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i] && g_Zombie[i] && !g_SpecialMode[i] && iZombies == 1) {
			g_LastZombie[i] = 1;
		} else {
			g_LastZombie[i] = 0;
		}

		if(g_IsAlive[i] && !g_Zombie[i] && !g_SpecialMode[i] && iHumans == 1) {
			g_LastHuman[i] = 1;

			if((g_Mode == MODE_MULTI || g_Mode == MODE_MULTI_ORIGINAL) && !g_LastHuman_1000hp[i]) {
				g_LastHuman_1000hp[i] = 1;
				set_user_health(i, get_user_health(i) + 1000);
			}
		} else {
			g_LastHuman[i] = 0;
		}
	}
}

public loadInfo(const id)
{
	if(!g_IsConnected[id] || !g_Account_Logged[id])
		return;

	static Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM ze1_users LEFT JOIN ze1_stats ON ze1_stats.ze_id='%d' WHERE ze1_users.id='%d';", g_Account_Id[id], g_Account_Id[id]);

	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 250);
	else if(SQL_NumResults(sqlQuery))
	{
		// 0 = ID
		// 1 = NAME
		// 2 = PASSWORD
		// 3 = IP
		// 4 = REGISTER_C
		// 5 = LAST_C
		// 6 = BAN
		// 7 = EXPIRE_BAN
		// 8 = ADMIN_BAN
		// 9 = REASON_BAN
		g_Vinc[id] = SQL_ReadResult(sqlQuery, 10);
		g_VincAppMobile[id] = SQL_ReadResult(sqlQuery, 11);
		// 12 = PREMIUM

		static sInfo[64];
		static i;

		g_Level[id] = SQL_ReadResult(sqlQuery, 13);
		g_Range[id] = clamp((g_Level[id] / 10), 0, charsmax(RANGES));
		g_Exp[id] = SQL_ReadResult(sqlQuery, 14);
		// 15 = clan_id
		g_HumanClassNext[id] = clamp(SQL_ReadResult(sqlQuery, 16), 0, charsmax(HUMAN_CLASSES));
		g_HumanClass[id] = g_HumanClassNext[id];
		g_ZombieClassNext[id] = clamp(SQL_ReadResult(sqlQuery, 17), 0, (structIdZombieClasses - 1));
		g_ZombieClass[id] = g_ZombieClassNext[id];
		g_SurvivorClassNext[id] = clamp(SQL_ReadResult(sqlQuery, 18), 0, charsmax(SURVIVOR_CLASSES));
		g_SurvivorClass[id] = g_SurvivorClassNext[id];
		g_NemesisClassNext[id] = clamp(SQL_ReadResult(sqlQuery, 19), 0, charsmax(NEMESIS_CLASSES));
		g_NemesisClass[id] = g_NemesisClassNext[id];
		g_Points[id] = SQL_ReadResult(sqlQuery, 20);
		g_PointsLose[id] = SQL_ReadResult(sqlQuery, 21);

		static sWeapons[3][3];
		SQL_ReadResult(sqlQuery, 22, sInfo, charsmax(sInfo));
		parse(sInfo, sWeapons[0], 2, sWeapons[1], 2, sWeapons[2], 2);

		g_Weapon_AutoBuy[id] = str_to_num(sWeapons[0]);
		g_WeaponPrimary_Selection[id] = str_to_num(sWeapons[1]);
		g_WeaponSecondary_Selection[id] = str_to_num(sWeapons[2]);

		SQL_ReadResult(sqlQuery, 23, sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UpgradesSkin[id], sizeof(UPGRADES_SKIN));

		SQL_ReadResult(sqlQuery, 24, sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UpgradesHat[id], sizeof(UPGRADES_HAT));

		SQL_ReadResult(sqlQuery, 25, sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UpgradesKnife[id], sizeof(UPGRADES_KNIFE));

		SQL_ReadResult(sqlQuery, 26, sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_UpgradeSelect[id], sizeof(UPGRADES_CLASS));

		g_HatNext[id] = g_UpgradeSelect[id][1];

		g_PlayedTime[id][0] = SQL_ReadResult(sqlQuery, 27);

		static iHour;
		static iDay;

		iHour = g_PlayedTime[id][0] / 60;
		iDay = 0;

		while(iHour >= 24)
		{
			++iDay;
			iHour -= 24;
		}

		g_PlayedTime[id][3] = g_PlayedTime[id][0] - ((iHour * 60) + (iDay * 24 * 60));
		g_PlayedTime[id][1] = iHour;
		g_PlayedTime[id][2] = iDay;

		static sHudPosition[3][12];
		SQL_ReadResult(sqlQuery, 28, sInfo, charsmax(sInfo));
		parse(sInfo, sHudPosition[0], 11, sHudPosition[1], 11, sHudPosition[2], 11);

		g_HudGeneral_Position[id][0] = str_to_float(sHudPosition[0]);
		g_HudGeneral_Position[id][1] = str_to_float(sHudPosition[1]);
		g_HudGeneral_Position[id][2] = str_to_float(sHudPosition[2]);

		static sHudConfig[3][3];
		SQL_ReadResult(sqlQuery, 29, sInfo, charsmax(sInfo));
		parse(sInfo, sHudConfig[0], 2, sHudConfig[1], 2, sHudConfig[2], 2);

		g_HudGeneral_Effect[id] = str_to_num(sHudConfig[0]);
		g_HudGeneral_Abrev[id] = str_to_num(sHudConfig[1]);
		g_HudGeneral_Mini[id] = str_to_num(sHudConfig[2]);

		SQL_ReadResult(sqlQuery, 30, sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_Color[id][COLOR_HUD], structIdRGB);

		SQL_ReadResult(sqlQuery, 31, sInfo, charsmax(sInfo));
		stringToArray(sInfo, g_Color[id][COLOR_FLARE], structIdRGB);

		g_ModelHuman[id] = clamp(SQL_ReadResult(sqlQuery, 32), ZE_MODEL_MAN, ZE_MODEL_WOMAN);
		g_DailyVisit[id] = SQL_ReadResult(sqlQuery, 33);

		updateRewardsByFlags(id);

		// 34 = connected_today

		// 35 = ID
		// 36 = ZE_ID

		SQL_ReadResult(sqlQuery, 37, Float:g_Stats_DamageCount[id][0]);
		SQL_ReadResult(sqlQuery, 38, Float:g_Stats_DamageCount[id][1]);
		g_AmbienceSound_Muted[id] = SQL_ReadResult(sqlQuery, 39);

		for(i = 0; i < struckIdStatsGeneral; ++i)
			g_Stats_General[id][i] = SQL_ReadResult(sqlQuery, (i + 40));

		g_Invis[id] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "invis"));

		SQL_FreeHandle(sqlQuery);

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT achievement_id, achievement_date, achievement_type, achievement_count FROM ze1_achievements WHERE ze_id='%d';", g_Account_Id[id]);

		if(!SQL_Execute(sqlQuery))
			executeQuery(id, sqlQuery, 500);
		else if(SQL_NumResults(sqlQuery))
		{
			new iType;
			new iAchId;
			new iCount;

			iCount = 0;

			while(SQL_MoreResults(sqlQuery))
			{
				iType = SQL_ReadResult(sqlQuery, 2);
				++iCount;

				switch(iType)
				{
					case 0: // Logros
					{
						iAchId = SQL_ReadResult(sqlQuery, 0);

						g_Achievement[id][iAchId] = 1;
						SQL_ReadResult(sqlQuery, 1, g_AchievementUnlocked[id][iAchId], 31);
						g_AchievementCount[id][iAchId] = SQL_ReadResult(sqlQuery, 3);
					}
					case 1: // Meta-Logros
					{
						iAchId = SQL_ReadResult(sqlQuery, 0);

						g_MetaAchievement[id][iAchId] = 1;
						SQL_ReadResult(sqlQuery, 1, g_MetaAchievementUnlocked[id][iAchId], 31);
						g_AchievementCount[id][iAchId] = SQL_ReadResult(sqlQuery, 3);
					}
				}

				SQL_NextRow(sqlQuery);
			}

			SQL_FreeHandle(sqlQuery);

			g_Stats_General[id][STATS_ACHIEVEMENTS_D] = iCount; // Fix Achievement Total
		}
		else
			SQL_FreeHandle(sqlQuery);
	}
	else
		SQL_FreeHandle(sqlQuery);

	remove_task(id + TASK_CHECK_ACHIEVEMENTS);
	set_task(random_float(5.0, 10.0), "task__CheckAchievements", id + TASK_CHECK_ACHIEVEMENTS);

	event__Health(id);
}

public saveInfo(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static Handle:sqlQuery;
	static sWeap[12];
	static sUpgradesSkins[64];
	static sUpgradesHats[64];
	static sUpgradesKnifes[64];
	static sUpgradeSelected[12];
	static sHudPosition[128];
	static sHudConfig[12];
	static sColorHud[32];
	static sColorFlare[32];
	static sQuery[1028];
	static iLen;

	formatex(sWeap, charsmax(sWeap), "%d %d %d", g_Weapon_AutoBuy[id], g_WeaponPrimary_Selection[id], g_WeaponSecondary_Selection[id]);
	arrayToString(g_UpgradesSkin[id], sizeof(UPGRADES_SKIN), sUpgradesSkins, charsmax(sUpgradesSkins), 1);
	arrayToString(g_UpgradesHat[id], sizeof(UPGRADES_HAT), sUpgradesHats, charsmax(sUpgradesHats), 1);
	arrayToString(g_UpgradesKnife[id], sizeof(UPGRADES_KNIFE), sUpgradesKnifes, charsmax(sUpgradesKnifes), 1);
	arrayToString(g_UpgradeSelect[id], sizeof(UPGRADES_CLASS), sUpgradeSelected, charsmax(sUpgradeSelected), 1);
	formatex(sHudPosition, charsmax(sHudPosition), "%f %f %f", g_HudGeneral_Position[id][0], g_HudGeneral_Position[id][1], g_HudGeneral_Position[id][2]);
	formatex(sHudConfig, charsmax(sHudConfig), "%d %d %d", g_HudGeneral_Effect[id], g_HudGeneral_Abrev[id], g_HudGeneral_Mini[id]);
	arrayToString(g_Color[id][COLOR_HUD], structIdRGB, sColorHud, charsmax(sColorHud), 1);
	arrayToString(g_Color[id][COLOR_FLARE], structIdRGB, sColorFlare, charsmax(sColorFlare), 1);

	iLen = 0;
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "UPDATE ze1_users ");
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "SET ip=^"%s^", last_connection=now(), ", g_User_Ip[id]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "premium='%d', level='%d', exp='%d', ", g_AccountPremium[id], g_Level[id], g_Exp[id]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "hclass='%d', zclass='%d', sclass='%d', nclass='%d', ", g_HumanClassNext[id], g_ZombieClassNext[id], g_SurvivorClassNext[id], g_NemesisClassNext[id]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "points='%d', points_lose='%d', ", g_Points[id], g_PointsLose[id]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "weapons=^"%s^", upgrades_skins=^"%s^", upgrades_hats=^"%s^", upgrades_knifes=^"%s^", upgrade_selected=^"%s^", ", sWeap, sUpgradesSkins, sUpgradesHats, sUpgradesKnifes, sUpgradeSelected);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "time_played='%d', hud_position=^"%s^", hud_config=^"%s^", color_hud=^"%s^", color_flare=^"%s^", model='%d' ", g_PlayedTime[id][0], sHudPosition, sHudConfig, sColorHud, sColorFlare, g_ModelHuman[id]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "WHERE id='%d';", g_Account_Id[id]);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, sQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 300);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	iLen = 0;
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "UPDATE ze1_stats ");
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "SET damage_d='%f', damage_t='%f', ", g_Stats_DamageCount[id][0], g_Stats_DamageCount[id][1]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "infect_d='%d', infect_t='%d', zombie_d='%d', zombie_t='%d', human_d='%d', human_t='%d', ", g_Stats_General[id][STATS_INFECTS_D], g_Stats_General[id][STATS_INFECTS_T], g_Stats_General[id][STATS_ZOMBIES_D], g_Stats_General[id][STATS_ZOMBIES_T], g_Stats_General[id][STATS_HUMANS_D], g_Stats_General[id][STATS_HUMANS_T]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "head_d='%d', head_t='%d', zombie_head_d='%d', zombie_head_t='%d', zombie_knife_d='%d', zombie_knife_t='%d', ", g_Stats_General[id][STATS_HEAD_D], g_Stats_General[id][STATS_HEAD_T], g_Stats_General[id][STATS_ZOMBIES_HEAD_D], g_Stats_General[id][STATS_ZOMBIES_HEAD_T], g_Stats_General[id][STATS_ZOMBIES_KNIFE_D], g_Stats_General[id][STATS_ZOMBIES_KNIFE_T]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "armor_d='%d', armor_t='%d', escape_d='%d', achievement_d='%d', ", g_Stats_General[id][STATS_ARMOR_D], g_Stats_General[id][STATS_ARMOR_T], g_Stats_General[id][STATS_ESCAPE_D], g_Stats_General[id][STATS_ACHIEVEMENTS_D]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "survivor_d='%d',nemesis_d='%d',ambience_sounds='%d',supply_boxes='%d' ", g_Stats_General[id][STATS_SURVIVOR_D], g_Stats_General[id][STATS_NEMESIS_D], g_AmbienceSound_Muted[id], g_Stats_General[id][STATS_SUPPLY_BOX_COLLECTED]);
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "WHERE ze_id='%d';", g_Account_Id[id]);

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, sQuery);

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 350);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

public buyPrimaryWeapon(const id, const selection) {
	dropWeapons(id, 1);

	if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id]) {
		return;
	}

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	static iWeaponId;
	iWeaponId = PRIMARY_WEAPONS[selection][weaponCSW];

	g_WeaponPrimary_Current[id] = selection;

	give_item(id, PRIMARY_WEAPONS[selection][weaponEnt]);
	ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[iWeaponId], AMMO_TYPE[iWeaponId], MAX_BPAMMO[iWeaponId]);
}

public buySecondaryWeapon(const id, const selection) {
	dropWeapons(id, 2);

	if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id]) {
		return;
	}

	if(selection > sizeof(SECONDARY_WEAPONS)) {
		g_Weapon_AutoBuy[id] = 0;

		g_WeaponPrimary_Bought[id] = 0;
		g_WeaponSecondary_Bought[id] = 0;

		g_WeaponPrimary_Current[id] = 0;
		g_WeaponSecondary_Current[id] = 0;

		showMenu__BuyPrimaryWeapon(id);
		return;
	}

	static iWeaponId;
	iWeaponId = SECONDARY_WEAPONS[selection][weaponCSW];

	g_WeaponSecondary_Current[id] = selection;

	give_item(id, SECONDARY_WEAPONS[selection][weaponEnt]);
	ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[iWeaponId], AMMO_TYPE[iWeaponId], MAX_BPAMMO[iWeaponId]);
}

public TeamName:getUserTeam(const id)
	return get_member(id, m_iTeam);

setMode(modeId, id=0, fakeMode=false) {
	client_cmd(0, "stopsound");

	remove_task(TASK_STARTMODE);

	static Float:fDelayAmbience;
	static iUsersAlive;
	static iMaxZombies;
	static iZombies;
	static i;

	fDelayAmbience = 2.0;
	iUsersAlive = getAlives();
	iMaxZombies = 0;
	iZombies = 0;

	g_NewRound = 0;
	g_Mode = modeId;
	g_LastMode = modeId;

	if(g_Mode != MODE_MULTI && g_Mode != MODE_MULTI_ORIGINAL) {
		g_FirstInfect = 1;
	}

	g_Lights[0] = 'g';
	changeLights();

	switch(modeId)
	{
		case MODE_MULTI:
		{
			iMaxZombies = floatround((iUsersAlive * 0.16), floatround_ceil);

			while(iZombies < iMaxZombies)
			{
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(!g_IsAlive[id] || g_Zombie[id])
					continue;

				zombieMe(id, .firstZombie=1);
				set_task(30.0, "removeImmunityBombs", id + TASK_30SEC_ZOMBIE);

				++iZombies;
			}

			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(g_Zombie[i] || id == i) {
					randomSpawn(i);
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					remove_task(i + TASK_TEAM);

					setUserTeam(i, TEAM_CT);
					task__UserTeamUpdate(i);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "JERUZALEM SE INFECTOOOO . . .^n¡HORA DE ESCAPARRRR!");

			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		} case MODE_SWARM: {
			if(!getAliveTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_TERRORIST);

				task__UserTeamUpdate(id);
			} else if(!getAliveCTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_CT);

				task__UserTeamUpdate(id);
			}

			for(i = 1; i <= g_MaxUsers; ++i)
			{
				if(!is_user_alive(i))
					continue;

				if(getUserTeam(i) != TEAM_TERRORIST)
					continue;

				zombieMe(i, .silentMode=1);
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "¡MASACRE EN JERUZALEM!");

			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		}
		case MODE_MULTI_ORIGINAL:
		{
			iMaxZombies = 5;

			if(iUsersAlive >= (iMaxZombies + 1))
			{
				iZombies = 0;

				while(iZombies < iMaxZombies)
				{
					id = getRandomAlive(random_num(1, iUsersAlive));

					if(!is_user_alive(id) || g_Zombie[id])
						continue;

					zombieMe(id, .firstZombie=1);
					++iZombies;
				}
			}
			else
			{
				id = getRandomAlive(random_num(1, iUsersAlive));
				zombieMe(id, .firstZombie=1);
			}

			for(i = 1; i <= g_MaxUsers; ++i)
			{
				if(!is_user_alive(i))
					continue;

				if(g_Zombie[i] || id == i)
					continue;

				if(getUserTeam(i) != TEAM_CT)
				{
					remove_task(i + TASK_TEAM);

					setUserTeam(i, TEAM_CT);
					task__UserTeamUpdate(i);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "¡INFECCION MULTIPLE EN JERUZALEM!");

			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		} case MODE_PLAGUE: {
			iMaxZombies = 2;
			iZombies = 0;

			while(iZombies < iMaxZombies) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id] == MODE_SURVIVOR) {
					continue;
				}

				humanMe(id, .survivor=1);

				++iZombies;
			}

			iMaxZombies = 2;
			iZombies = 0;

			while(iZombies < iMaxZombies) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id] == MODE_SURVIVOR || g_SpecialMode[id] == MODE_NEMESIS) {
					continue;
				}

				zombieMe(id, .nemesis=1);

				++iZombies;
			}

			iMaxZombies = (iUsersAlive - 4) / 2;
			iZombies = 0;
			id = 0;

			while(iZombies < iMaxZombies) {
				if(++id > g_MaxUsers) {
					id = 1;
				}

				if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] == MODE_SURVIVOR) {
					continue;
				}

				if(random_num(0, 1)) {
					zombieMe(id);
					set_user_health(id, get_user_health(id) + 1000);

					++iZombies;
				}
			}

			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(g_Zombie[i] || g_SpecialMode[i] == MODE_SURVIVOR) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					remove_task(i + TASK_TEAM);

					setUserTeam(i, TEAM_CT);
					task__UserTeamUpdate(i);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "¡LA PLAGA LLEGO A JERUZALEMMM!");

			playSound(0, SOUND_ROUND_GENERAL[random_num(0, charsmax(SOUND_ROUND_GENERAL))]);
		} case MODE_ARMAGEDDON: {
			set_cvar_num("pbk_afk_time", 9999);

			if(!getAliveTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_TERRORIST);

				task__UserTeamUpdate(id);
			} else if(!getAliveCTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_CT);

				task__UserTeamUpdate(id);
			}

			g_ModeArmageddon_NoDamage = 1;
			fDelayAmbience = 20.0;

			checkArmageddonEffect();
		} case MODE_SURVIVOR: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			humanMe(id, .survivor=1);

			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!g_IsAlive[i] || id == i) {
					continue;
				}

				zombieMe(i, .silentMode=1);
			}

			set_hudmessage(0, 0, 255, -1.0, 0.25, 0, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "¡ %s ES SURVIVOR !", g_User_Name[id]);

			playSound(0, SOUND_ROUND_MODES[random_num(0, charsmax(SOUND_ROUND_MODES))]);
		} case MODE_NEMESIS: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			zombieMe(id, .nemesis=1);

			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!g_IsAlive[i] || id == i) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					remove_task(i + TASK_TEAM);

					setUserTeam(i, TEAM_CT);
					task__UserTeamUpdate(i);
				}
			}

			set_hudmessage(255, 0, 0, -1.0, 0.25, 0, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "¡ %s ES NEMESIS !", g_User_Name[id]);

			playSound(0, SOUND_ROUND_MODES[random_num(0, charsmax(SOUND_ROUND_MODES))]);
		} case MODE_NEMESIS_EXTREM: {
			iMaxZombies = 4;
			iZombies = 0;

			while(iZombies < iMaxZombies) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id] == MODE_NEMESIS) {
					continue;
				}

				zombieMe(id, .nemesis=1);

				++iZombies;
			}

			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!g_IsAlive[i] || g_Zombie[i] || g_SpecialMode[i] == MODE_NEMESIS) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					remove_task(i + TASK_TEAM);

					setUserTeam(i, TEAM_CT);
					task__UserTeamUpdate(i);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "¡ NEMESIS EXTREMO !");

			playSound(0, SOUND_ROUND_MODES[random_num(0, charsmax(SOUND_ROUND_MODES))]);
		} case MODE_JERUZALEM: {
			if(!getAliveTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_TERRORIST);

				task__UserTeamUpdate(id);
			} else if(!getAliveCTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				remove_task(id + TASK_TEAM);
				setUserTeam(id, TEAM_CT);

				task__UserTeamUpdate(id);
			}

			new i;
			new iMaxHumans = iUsersAlive / 2;
			new iHumans = 0;
			new iAlreadyChoosen[MAX_USERS];
			new iVIPs[2];
			new iMaxVIPs = 0;

			g_VIPsDead = 0;
			g_ModeJeruzalem_AlreadyRewarded = false;

			while(iHumans < iMaxHumans) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(iAlreadyChoosen[id]) {
					continue;
				}

				iAlreadyChoosen[id] = true;

				if(iMaxVIPs < 2) {
					iVIPs[iMaxVIPs] = id;
					++g_VIPsDead;
				}

				++iHumans;
				++iMaxVIPs;
			}

			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(iAlreadyChoosen[i]) {
					if(getUserTeam(i) == TEAM_TERRORIST) {
						remove_task(i + TASK_TEAM);

						setUserTeam(i, TEAM_CT);
						task__UserTeamUpdate(i);
					}

					if(i == iVIPs[0] || i == iVIPs[1]) {
						humanMe(i, .jeruzalemVip=true);
					}
				} else {
					zombieMe(i, .silentMode=true, .respawnAgain=true);
				}
			}

			set_hudmessage(0, 255, 128, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_Hud_Event, "¡JERUZALEM!^n^nVIPS:^n%s^n%s", g_User_Name[iVIPs[0]], g_User_Name[iVIPs[1]]);

			if(!fakeMode) {
				++g_AutoMode_Jeruzalem_Count;

				new sQuery[128];
				formatex(sQuery, 127, "UPDATE ze1_general SET automode_jeruzalem_count='%d' WHERE id=1;", g_AutoMode_Jeruzalem_Count);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__SaveAndIgnore", sQuery);
			}
		}
	}

	checkTriggerHurt();

	if(g_AmbienceSounds[g_Mode]) {
		remove_task(TASK_AMBIENCESOUNDS);
		set_task(fDelayAmbience, "task__AmbienceSoundsEffect", TASK_AMBIENCESOUNDS);
	}

	ExecuteForward(g_fwRoundStarted, g_fwDummy, modeId, id);
}

public checkTriggerHurt() {
	new iEnt;
	iEnt = -1;

	while((iEnt = fm_find_ent_by_class(iEnt, "trigger_hurt"))) {
		if(is_valid_ent(iEnt) && entity_get_float(iEnt, EV_FL_dmg) == 0.0) {
			entity_set_float(iEnt, EV_FL_dmg, 50000.0);
		}
	}
}

zombieMe(const id, attacker=0, silentMode=0, bomb=0, firstZombie=0, nemesis=0, respawnAgain=false) {
	if(!g_IsAlive[id]) {
		return;
	}

	if(g_HatId[id]) {
		if(is_valid_ent(g_HatEnt[id])) {
			entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
			entity_set_float(g_HatEnt[id], EV_FL_renderamt, 0.0);
		}
	}

	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_BURN);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_IMMUNITY);
	remove_task(id + TASK_ZHEAVY_COOLDOWN);
	remove_task(id + TASK_ZHEAVY_REMOVE_TRAMP);
	remove_task(id + TASK_ZBANCHEE_START);
	remove_task(id + TASK_ZBANCHEE_REMOVE_STAT);
	remove_task(id + TASK_ZVOODOO_COOLDOWN);
	remove_task(id + TASK_ZLUSTY_INVI);
	remove_task(id + TASK_ZLUSTY_INVI_WAIT);

	setUserLongJump(id, 0);

	g_Zombie[id] = 1;
	g_FirstZombie[id] = 0;
	g_SpecialMode[id] = 0;
	g_WeaponPrimary_Bought[id] = 0;
	g_WeaponSecondary_Bought[id] = 0;
	g_ZombieClassBanchee_Stat[id] = 0;
	g_ZombieClassBanchee_Enemy[id] = 0;
	g_ZombieClassLusty_Invi[id] = 0;
	g_ZombieClassLusty_InviWait[id] = 0;
	g_ZombieClassToxico_LastUsed[id] = get_gametime();
	g_ZombieClassFarahon_LastUsed[id] = 0.0;

	cs_set_user_zoom(id, CS_RESET_ZOOM, 1);
	// set_user_armor(id, 0);

	strip_user_weapons(id);

	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;

	give_item(id, "weapon_knife");

	set_user_rendering(id);

	g_ZombieClass[id] = g_ZombieClassNext[id];
	g_NemesisClass[id] = g_NemesisClassNext[id];

	static sCurrentModel[32];
	static iAlreadyHasModel;
	static iHealth;

	getUserModel(id, sCurrentModel, charsmax(sCurrentModel));
	iAlreadyHasModel = 0;
	iHealth = 0;

	if(attacker)
	{
		g_FirstInfect = 1;

		if(!bomb)
		{
			giveExperience(attacker, HAPPY_HOUR[g_HappyHour][hhExpRewardInfection]);
			g_AmmoPacks[attacker] += g_RewardAmmoPacksInfect[attacker];
		}

		++g_Stats_General[attacker][STATS_INFECTS_D];
		++g_Stats_General[id][STATS_INFECTS_T];

		switch(g_Stats_General[attacker][STATS_INFECTS_D])
		{
			case 30: setAchievement(attacker, x30_HUMANS);
			case 60: setAchievement(attacker, x60_HUMANS);
			case 100: setAchievement(attacker, x100_HUMANS);
			case 160: setAchievement(attacker, x160_HUMANS);
			case 220: setAchievement(attacker, x220_HUMANS);
			case 280: setAchievement(attacker, x280_HUMANS);
			case 340: setAchievement(attacker, x340_HUMANS);
			case 500: setAchievement(attacker, x500_HUMANS);
			case 700: setAchievement(attacker, x700_HUMANS);
			case 1000: setAchievement(attacker, x1000_HUMANS);
			case 2500: setAchievement(attacker, x2500_INFECTS);
			case 5000: setAchievement(attacker, x5000_INFECTS);
			case 10000: setAchievement(attacker, x10000_INFECTS);
			case 25000: setAchievement(attacker, x25000_INFECTS);
			case 50000: setAchievement(attacker, x50000_INFECTS);
			case 75000: setAchievement(attacker, x75000_INFECTS);
			case 100000: setAchievement(attacker, x100000_INFECTS);
			case 250000: setAchievement(attacker, x250000_INFECTS);
			case 500000: setAchievement(attacker, x500000_INFECTS);
			case 1000000: setAchievement(attacker, x1000000_INFECTS);
		}

		iHealth = zombieHealth(id, g_ZombieClass[id]);

		set_user_health(id, iHealth);
		g_Speed[id] = zombieSpeed(id, g_ZombieClass[id]);
		set_user_gravity(id, zombieGravity(id, g_ZombieClass[id]));
		g_KnockBack[id] = __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassKnockback];

		g_MaxHealth[id] = iHealth;

		if(equal(sCurrentModel, __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]))
			iAlreadyHasModel = 1;

		if(!iAlreadyHasModel)
			copy(g_User_Model[id], charsmax(g_User_Model[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]);

		emitSound(id, CHAN_VOICE, SOUND_ZOMBIE_INFECT[random_num(0, charsmax(SOUND_ZOMBIE_INFECT))]);

		copy(g_ClassName[id], charsmax(g_ClassName[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);

		sendDeathMsg(attacker, id);
		fixDeadAttrib(id);

		replaceWeaponModels(id, CSW_KNIFE);
	}
	else
	{
		if(!silentMode) {
			if(nemesis) {
				g_SpecialMode[id] = MODE_NEMESIS;

				iHealth = NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassHealth] * getAlives();

				set_user_health(id, iHealth);
				g_Speed[id] = Float:NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassSpeed];
				set_user_gravity(id, Float:NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassGravity]);
				g_KnockBack[id] = 0.25;

				g_MaxHealth[id] = iHealth;

				if(g_Mode == MODE_NEMESIS) {
					g_Bazooka[id] = 1;
					give_item(id, "weapon_sg550");

					cs_set_user_bpammo(id, CSW_SG550, 0);
					cs_set_weapon_ammo(fm_find_ent_by_owner(-1, "weapon_sg550", id), 0);

					g_CurrentWeapon[id] = CSW_KNIFE;
					engclient_cmd(id, "weapon_knife");
				}

				setUserLongJump(id, 1);

				if(equal(sCurrentModel, PLAYER_MODEL_NEMESIS)) {
					iAlreadyHasModel = 1;
				}

				if(!iAlreadyHasModel) {
					copy(g_User_Model[id], charsmax(g_User_Model[]), PLAYER_MODEL_NEMESIS);
				}

				copy(g_ClassName[id], charsmax(g_ClassName[]), NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassName]);

				replaceWeaponModels(id, CSW_KNIFE);
			}
			else
			{
				iHealth = zombieHealth(id, g_ZombieClass[id]);

				if(g_Mode == MODE_MULTI)
				{
					if(firstZombie)
					{
						g_FirstZombie[id] = 1;
						g_KnockBackBomb[id] = 2;

						give_item(id, "weapon_hegrenade");
						cs_set_user_bpammo(id, CSW_HEGRENADE, 2);

						iHealth += 2000;
					}
				}

				set_user_health(id, iHealth);
				g_Speed[id] = zombieSpeed(id, g_ZombieClass[id]);
				set_user_gravity(id, zombieGravity(id, g_ZombieClass[id]));
				g_KnockBack[id] = __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassKnockback];

				g_MaxHealth[id] = iHealth;

				if(equal(sCurrentModel, __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]))
					iAlreadyHasModel = 1;

				if(!iAlreadyHasModel)
					copy(g_User_Model[id], charsmax(g_User_Model[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]);

				emitSound(id, CHAN_VOICE, SOUND_ZOMBIE_ALERT[random_num(0, charsmax(SOUND_ZOMBIE_ALERT))]);

				copy(g_ClassName[id], charsmax(g_ClassName[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);

				if(!firstZombie)
					replaceWeaponModels(id, CSW_KNIFE);
			}
		}
		else
		{
			iHealth = zombieHealth(id, g_ZombieClass[id]);

			set_user_health(id, iHealth);
			g_Speed[id] = zombieSpeed(id, g_ZombieClass[id]);
			set_user_gravity(id, zombieGravity(id, g_ZombieClass[id]));
			g_KnockBack[id] = __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassKnockback];

			g_MaxHealth[id] = iHealth;

			if(equal(sCurrentModel, __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]))
				iAlreadyHasModel = 1;

			if(!iAlreadyHasModel)
				copy(g_User_Model[id], charsmax(g_User_Model[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]);

			copy(g_ClassName[id], charsmax(g_ClassName[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);

			replaceWeaponModels(id, CSW_KNIFE);
		}
	}

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != TEAM_TERRORIST)
	{
		remove_task(id + TASK_TEAM);

		setUserTeam(id, TEAM_TERRORIST);
		task__UserTeamUpdate(id);
	}

	if(!iAlreadyHasModel)
	{
		if(g_NewRound)
			set_task((5.0 * MODELS_CHANGE_DELAY), "task__UserModelUpdate", id + TASK_MODEL);
		else
			task__UserModelUpdate(id + TASK_MODEL);
	}

	if(g_Mode != MODE_ARMAGEDDON) {
		if(!g_Frozen[id]) {
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
			write_short(UNIT_SECOND);
			write_short(0);
			write_short(FFADE_IN);
			write_byte((g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_EXTREM || g_Immunity[id]) ? 255 : 0);
			write_byte((g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_EXTREM || g_Immunity[id]) ? 0 : 255);
			write_byte((g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_EXTREM || g_Immunity[id]) ? 0 : 0);
			write_byte(255);
			message_end();
		}

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, id);
		write_short(UNIT_SECOND * 4);
		write_short(UNIT_SECOND * 2);
		write_short(UNIT_SECOND * 10);
		message_end();
	}

	message_begin(MSG_ONE, g_Message_Fov, _, id);
	write_byte(110);
	message_end();

	turnOffFlashlight(id);
	checkZombiePowers(id);

	ExecuteForward(g_fwInfectedPost, g_fwDummy, id, attacker, silentMode, bomb, nemesis);

	if(respawnAgain) {
		ExecuteHamB(Ham_CS_RoundRespawn, id);
	}

	checkLastZombie();
}

public checkZombiePowers(const id)
{
	if(g_IsAlive[id] && g_Zombie[id] && !g_SpecialMode[id])
	{
		switch(g_ZombieClass[id])
		{
			case ZOMBIE_CLASS_HEAVY:
			{
				dg_color_chat(id, _, "Recuerdas que con la !gTecla F!y colocas una trampa");

				g_ZombieClassHeavy_MakeTramp[id] = 1;

				remove_task(id + TASK_ZHEAVY_COOLDOWN);
			}
			case ZOMBIE_CLASS_BANCHEE:
			{
				dg_color_chat(id, _, "Recuerdas que con la !gTecla F!y lanzas murcielagos");

				g_ZombieClassBanchee_BatTime[id] = 1;
			}
			case ZOMBIE_CLASS_VOODOO:
			{
				dg_color_chat(id, _, "Recuerdas que con la !gTecla F!y curas a tus compañeros zombies");

				g_ZombieClassVoodoo_CanHealth[id] = 1;
			}
			case ZOMBIE_CLASS_LUSTYROSE:
			{
				dg_color_chat(id, _, "Recuerdas que con la !gTecla F!y te haces invisible");

				if(g_ZombieClassLusty_Invi[id]) g_ZombieClassLusty_Invi[id] = 0;
				if(g_ZombieClassLusty_InviWait[id]) g_ZombieClassLusty_InviWait[id] = 0;
			}
			case ZOMBIE_CLASS_TOXICO:
			{
				dg_color_chat(id, _, "Recuerdas que con la !gTecla F!y lanzas escupitajos de ácidos");

				g_ZombieClassToxico_LastUsed[id] = get_gametime();
			}
			case ZOMBIE_CLASS_FARAHON:
			{
				dg_color_chat(id, _, "Recuerdas que con la !gTecla R!y lanzas bolas de fuego");

				g_ZombieClassFarahon_LastUsed[id] = 0.0;
			}
		}
	}

	if(g_ZombieClassHeavy_Trampped[id])
	{
		g_ZombieClassHeavy_Trampped[id] = 0;

		removeTramp();

		g_ZombieClassHeavy_TrampCount = 0;

		remove_task(id + TASK_ZHEAVY_REMOVE_TRAMP);
	}
}

public removeTramp()
{
	new iEnt = find_ent_by_class(-1, "entZombieHeavyTramp");
	while(iEnt > 0)
	{
		remove_entity(iEnt);
		iEnt = find_ent_by_class(-1, "entZombieHeavyTramp");
	}
}

public removeImmunityBombs(const taskid) {
	g_FirstInfect = 1;
}

humanMe(const id, silentMode=0, survivor=0, jeruzalemVip=false) {
	if(!g_IsAlive[id]) {
		return;
	}

	if(g_HatId[id]) {
		if(is_valid_ent(g_HatEnt[id])) {
			entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderNormal);
			entity_set_float(g_HatEnt[id], EV_FL_renderamt, 255.0);
		}
	}

	remove_task(id + TASK_MODEL);
	remove_task(id + TASK_BURN);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_IMMUNITY);
	remove_task(id + TASK_ZHEAVY_COOLDOWN);
	remove_task(id + TASK_ZHEAVY_REMOVE_TRAMP);
	remove_task(id + TASK_ZBANCHEE_START);
	remove_task(id + TASK_ZBANCHEE_REMOVE_STAT);
	remove_task(id + TASK_ZVOODOO_COOLDOWN);
	remove_task(id + TASK_ZLUSTY_INVI);
	remove_task(id + TASK_ZLUSTY_INVI_WAIT);

	setUserLongJump(id, 0);

	g_Zombie[id] = 0;
	g_FirstZombie[id] = 0;
	g_SpecialMode[id] = 0;
	g_WeaponPrimary_Bought[id] = 0;
	g_WeaponSecondary_Bought[id] = 0;
	g_ZombieClassBanchee_Stat[id] = 0;
	g_ZombieClassBanchee_Enemy[id] = 0;
	g_ZombieClassLusty_Invi[id] = 0;
	g_ZombieClassLusty_InviWait[id] = 0;
	g_ZombieClassToxico_LastUsed[id] = get_gametime();
	g_ZombieClassFarahon_LastUsed[id] = 0.0;

	if(g_Frozen[id]) {
		remove_task(id + TASK_FROZEN);

		removeFrostCube(id);
		task__RemoveFreeze(id + TASK_FROZEN);
	}

	strip_user_weapons(id);

	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;

	give_item(id, "weapon_knife");

	set_user_rendering(id);

	g_HumanClass[id] = g_HumanClassNext[id];
	g_SurvivorClass[id] = g_SurvivorClassNext[id];

	static sCurrentModel[32];
	static iAlreadyHasModel;
	static iHealth;

	getUserModel(id, sCurrentModel, charsmax(sCurrentModel));
	iAlreadyHasModel = 0;
	iHealth = 0;

	if(survivor) {
		g_SpecialMode[id] = MODE_SURVIVOR;

		iHealth = SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassHealth] * getAlives();

		set_user_health(id, iHealth);
		g_Speed[id] = Float:SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassSpeed];
		set_user_gravity(id, Float:SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassGravity]);

		g_MaxHealth[id] = iHealth;
		g_UnlimitedClip[id] = true;

		give_item(id, "weapon_m249");
		cs_set_user_bpammo(id, CSW_M249, 0);
		cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_m249", id), 100);

		setUserLongJump(id, 1);

		if(equal(sCurrentModel, PLAYER_MODEL_SURVIVOR)) {
			iAlreadyHasModel = 1;
		}

		if(!iAlreadyHasModel) {
			copy(g_User_Model[id], charsmax(g_User_Model[]), PLAYER_MODEL_SURVIVOR);
		}

		copy(g_ClassName[id], charsmax(g_ClassName[]), SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassName]);

		if(g_Mode == MODE_ARMAGEDDON) {
			if(g_HatId[id]) {
				if(is_valid_ent(g_HatEnt[id])) {
					entity_set_int(g_HatEnt[id], EV_INT_rendermode, kRenderTransAlpha);
					entity_set_float(g_HatEnt[id], EV_FL_renderamt, 0.0);
				}
			}
		}
	} else {
		set_task(0.1, "task__ClearWeapons", id + TASK_SPAWN);
		set_task(0.2, "task__ShowMenuWeapons", id + TASK_SPAWN);

		iHealth = humanHealth(id, g_HumanClass[id]);

		set_user_health(id, iHealth);
		g_Speed[id] = Float:humanSpeed(id, g_HumanClass[id]);
		set_user_gravity(id, Float:humanGravity(id, g_HumanClass[id]));

		set_task(1.0, "task__SetClassHumans", id + TASK_SPAWN);

		if(!silentMode) {
			emitSound(id, CHAN_ITEM, SOUND_ANTIDOTE);
		}

		if(equal(sCurrentModel, getUserHumanModel(id))) {
			iAlreadyHasModel = 1;
		}

		if(!iAlreadyHasModel) {
			copy(g_User_Model[id], charsmax(g_User_Model[]), getUserHumanModel(id));
		}

		copy(g_ClassName[id], charsmax(g_ClassName[]), HUMAN_CLASSES[g_HumanClass[id]][humanClassName]);

		if(jeruzalemVip) {
			set_task(0.5, "task__ActivateVIP", id + TASK_SPAWN);
		}
	}

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != TEAM_CT) {
		remove_task(id + TASK_TEAM);

		setUserTeam(id, TEAM_CT);
		task__UserTeamUpdate(id);
	}

	if(!iAlreadyHasModel) {
		if(g_NewRound) {
			set_task(5.0 * MODELS_CHANGE_DELAY, "task__UserModelUpdate", id + TASK_MODEL);
		} else {
			task__UserModelUpdate(id + TASK_MODEL);
		}
	}

	message_begin(MSG_ONE, g_Message_Fov, _, id);
	write_byte(90);
	message_end();

	ExecuteForward(g_fwHumanizedPost, g_fwDummy, id, silentMode, survivor);

	checkLastZombie();
}

public task__ActivateVIP(taskId) {
	new id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_SPAWN) : taskId;

	if(!isUserValidAlive(id)) {
		return;
	}

	static sCurrentModel[32];
	static iAlreadyHasModel;

	getUserModel(id, sCurrentModel, charsmax(sCurrentModel));
	iAlreadyHasModel = 0;

	g_SpecialMode[id] = MODE_JERUZALEM;

	if(equal(sCurrentModel, PLAYER_MODEL_JERUZALEM_VIP)) {
		iAlreadyHasModel = 1;
	}

	if(!iAlreadyHasModel) {
		copy(g_User_Model[id], charsmax(g_User_Model[]), PLAYER_MODEL_JERUZALEM_VIP);
	}

	set_user_rendering(id, kRenderFxGlowShell, 0, 255, 128, kRenderNormal, 5);

	if(!iAlreadyHasModel) {
		if(g_NewRound) {
			set_task(5.0 * MODELS_CHANGE_DELAY, "task__UserModelUpdate", id + TASK_MODEL);
		} else {
			task__UserModelUpdate(id + TASK_MODEL);
		}
	}
}

public checkArmageddonEffect() {
	static sCurrentDay[4];
	get_time("%A", sCurrentDay, charsmax(sCurrentDay));

	if(equali(sCurrentDay, "Sat") || equali(sCurrentDay, "Sun")) {
		static i;
		static j;

		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!g_IsConnected[i]) {
				continue;
			}

			playSound(i, SOUND_ROUND_ARMAGEDDON[1]);

			if(!g_IsAlive[i]) {
				continue;
			}

			strip_user_weapons(i);

			message_begin(MSG_BROADCAST, g_Message_ScreenFade, _, 0);
			write_short(UNIT_SECOND * 4);
			write_short(UNIT_SECOND * 3);
			write_short(FFADE_OUT);
			write_byte(0);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			message_end();

			j = strlen(g_User_SteamId[i]);

			if(equali(g_User_SteamId[i], "STEAM_ID_PENDING") || equali(g_User_SteamId[i], "STEAM_ID_LAN") || j <= 16 || (g_User_SteamId[i][0] == 'V' && g_User_SteamId[i][1] == 'A' && g_User_SteamId[i][2] == 'L')) {
				set_task(3.4, "task__ArmageddonEffect", i); // TUM
				set_task(4.1, "task__ArmageddonEffect", i); // TUMM
				set_task(4.8, "task__ArmageddonEffect", i); // TUMMM

				set_task(7.0, "task__ArmageddonBlackFade", i);

				set_task(10.5, "task__ArmageddonEffect", i); // TUM
				set_task(11.2, "task__ArmageddonEffect", i); // TUMM
				set_task(11.9, "task__ArmageddonEffect", i); // TUMMM
			} else { // Estúpido fix para steam que el sonido de mp3 play empieza a reproducirse 1 segundo después de que se ejecuta
				set_task(4.4, "task__ArmageddonEffect", i); // TUM
				set_task(5.1, "task__ArmageddonEffect", i); // TUMM
				set_task(5.8, "task__ArmageddonEffect", i); // TUMMM

				set_task(8.0, "task__ArmageddonBlackFade", i);

				set_task(11.5, "task__ArmageddonEffect", i); // TUM
				set_task(12.2, "task__ArmageddonEffect", i); // TUMM
			}

			setAchievement(i, MEGA_ARMAGEDDON);
		}

		set_task(13.0, "task__ArmageddonStartPre");
		set_task(13.5, "task__ArmageddonStartPost");
	} else {
		set_task(1.0, "task__ArmageddonStartPre");
		set_task(9.5, "task__ArmageddonStartPost");

		playSound(0, SOUND_ROUND_ARMAGEDDON[0]);
	}
}

public task__ArmageddonEffect(const id) {
	if(g_IsAlive[id]) {
		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_STAYOUT);
		write_byte(random_num(0, 255));
		write_byte(random_num(0, 255));
		write_byte(random_num(0, 255));
		write_byte(255);
		message_end();
	}
}

public task__ArmageddonBlackFade(const id) {
	if(g_IsAlive[id]) {
		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
		write_short(UNIT_SECOND * 4);
		write_short(UNIT_SECOND * 3);
		write_short(FFADE_OUT);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
}

public zombieHealth(const id, const classId)
{
	new iHealth;
	iHealth = __ZOMBIE_CLASSES[classId][zombieClassHealth];

	if(g_Level[id])
		iHealth += ((g_Level[id] - 1) * 5);

	iHealth += (HEALTH_ZOMBIE_EXTRA_PERCENT * iHealth) / 100;
	return iHealth;
}

public Float:zombieSpeed(const id, const classId)
{
	new Float:fSpeed;
	fSpeed = __ZOMBIE_CLASSES[classId][zombieClassSpeed];

	if(g_Level[id])
		fSpeed += ((g_Level[id] - 1) * 0.013);

	return fSpeed;
}

public Float:zombieGravity(const id, const classId)
{
	new Float:fGravity;
	fGravity = __ZOMBIE_CLASSES[classId][zombieClassGravity];

	if(g_Level[id])
		fGravity -= ((g_Level[id] - 1) * 0.0006);

	return fGravity;
}

public humanHealth(const id, const classId)
{
	static iHealth;
	iHealth = HUMAN_CLASSES[classId][humanClassHealth];

	if(g_Level[id])
		iHealth += ((g_Level[id] - 1) * 1);

	return iHealth;
}

public Float:humanSpeed(const id, const classId) {
	static Float:fSpeed;
	fSpeed = HUMAN_CLASSES[classId][humanClassSpeed];

	if(g_Level[id]) {
		fSpeed += ((g_Level[id] - 1) * 0.013);
	}

	return fSpeed;
}

public Float:humanGravity(const id, const classId) {
	static Float:fGravity;
	fGravity = HUMAN_CLASSES[classId][humanClassGravity];

	if(g_Level[id]) {
		fGravity -= ((g_Level[id] - 1) * 0.0006); // 0.00128
	}

	return fGravity;
}

public getUserAdmin(const id)
{
	new sAdmin[32];
	sAdmin[0] = EOS;

	if((get_user_flags(id) & ADMIN_RCON))
		formatex(sAdmin, charsmax(sAdmin), "[OWNER DRUNK]");
	else if((get_user_flags(id) & ADMIN_LEVEL_D))
		formatex(sAdmin, charsmax(sAdmin), "[STAFF]");
	else if((get_user_flags(id) & ADMIN_LEVEL_C))
		formatex(sAdmin, charsmax(sAdmin), "[CAPITÁN]");
	else if((get_user_flags(id) & ADMIN_LEVEL_A))
		formatex(sAdmin, charsmax(sAdmin), "[DONADOR]");
	else if((get_user_flags(id) & ADMIN_RESERVATION))
		formatex(sAdmin, charsmax(sAdmin), "[VIP]");

	return sAdmin;
}

public getUserRange(const id)
{
	new sRange[32];
	sRange[0] = EOS;

	if(g_Zombie[id])
		copy(sRange, charsmax(sRange), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);
	else
		copy(sRange, charsmax(sRange), RANGES[g_Range[id]]);

	return sRange;
}

public getHealthSpecialMode(const id) {
	static sHealth[32];
	sHealth[0] = EOS;

	if(g_Mode == MODE_SURVIVOR && getSurvivorId() != id) {
		formatex(sHealth, charsmax(sHealth), "Vida del Survivor: %d^n", get_user_health(getSurvivorId()));
	} else if(g_Mode == MODE_NEMESIS && getNemesisId() != id) {
		formatex(sHealth, charsmax(sHealth), "Vida del Nemesis: %d^n", get_user_health(getNemesisId()));
	}

	return sHealth;
}

public getUserHumanModel(const id) {
	new sModelHuman[32];

	if(g_UpgradeSelect[id][0]) { // DEFAULT
		copy(sModelHuman, 31, UPGRADES_SKIN[g_UpgradeSelect[id][0]][upgradeModelP]); // g_aUpgradesSkin
	} else {
		copy(sModelHuman, 31, MODEL_HUMAN[g_ModelHuman[id]]);
	}

	return sModelHuman;
}

public respawnUser(const id) {
	setUserTeam(id, (g_RespawnAsZombie[id]) ? TEAM_TERRORIST : TEAM_CT);
	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public randomSpawn(const id) {
	static iHull;
	iHull = (get_entity_flags(id) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN;

	if(!g_SpawnCount) {
		return;
	}

	static iSpawnId;
	static i;

	iSpawnId = random_num(0, g_SpawnCount - 1);

	for(i = iSpawnId + 1; /* - */; ++i) {
		if(i >= g_SpawnCount) {
			i = 0;
		}

		if(isHullVacant(g_Spawns[i], iHull)) {
			entity_set_vector(id, EV_VEC_origin, g_Spawns[i]);
			break;
		}

		if(i == iSpawnId) {
			break;
		}
	}

	set_task(0.5, "task__CheckStuck", id);
}

public effectGrenade(const entity, const red, const green, const blue, const nade_type) {
	static Float:vecColor[3];

	vecColor[0] = float(red);
	vecColor[1] = float(green);
	vecColor[2] = float(blue);

	entity_set_int(entity, EV_INT_renderfx, kRenderFxGlowShell);
	entity_set_vector(entity, EV_VEC_rendercolor, vecColor);
	entity_set_int(entity, EV_INT_rendermode, kRenderNormal);
	entity_set_float(entity, EV_FL_renderamt, 1.0);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(entity);
	write_short(g_Sprite_Laserbeam);
	write_byte(10);
	write_byte(3);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(200);
	message_end();

	entity_set_int(entity, EV_NADE_TYPE, nade_type);

	switch(nade_type) {
		case NADE_TYPE_FLARE, NADE_TYPE_BUBBLE: {
			entity_set_vector(entity, EV_FLARE_COLOR, vecColor);
		}
	}
}

public infectionExplode(const entity) {
	if(g_EndRound) {
		return;
	}

	static iAttacker;
	iAttacker = entity_get_edict(entity, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(entity);
		return;
	}

	static Float:vecOrigin[3];
	static iVictim;

	entity_get_vector(entity, EV_VEC_origin, vecOrigin);
	iVictim = -1;

	createExplosion(vecOrigin, 0, 255, 0, 0);

	emitSound(entity, CHAN_WEAPON, SOUND_GRENADE_INFECT);

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLOSION_RADIUS)) > 0) {
		if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim]) {
			continue;
		}

		giveExperience(iAttacker, 10 * (g_HappyHour + 1));

		if(getHumans() == 1) {
			ExecuteHamB(Ham_Killed, iVictim, iAttacker, 0);
			break;
		}

		zombieMe(iVictim, iAttacker, .bomb=1);
	}

	remove_entity(entity);
}

public knockBackExplode(const entity) {
	if(g_EndRound) {
		return;
	}

	new iAttacker;
	iAttacker = entity_get_edict(entity, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(entity);
		return;
	}

	new Float:vecOrigin[3];
	entity_get_vector(entity, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 45.0);
	write_short(g_Sprite_KnockBack);
	write_byte(35);
	write_byte(186);
	message_end();

	createExplosion(vecOrigin, 25, 25, 25, 0);

	emitSound(entity, CHAN_WEAPON, SOUND_GRENADE_KNOCKBACK);

	new Float:vecOriginVictim[3];
	new Float:flDistance;
	new Float:flSpeed;
	new Float:vecVelocity[3];
	new iVictim;

	iVictim = -1;

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLOSION_RADIUS)) > 0) {
		if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_ImmunityFire[iVictim]) {
			continue;
		}

		entity_get_vector(iVictim, EV_VEC_origin, vecOriginVictim);
		flDistance = get_distance_f(vecOrigin, vecOriginVictim);

		if(flDistance <= 150.0) {
			flSpeed = get_pcvar_float(g_Cvar_KnockbackBomb_Speed) * (1.0 - (flDistance / 150.0));

			getSpeedVector(vecOrigin, vecOriginVictim, flSpeed, vecVelocity);
			entity_set_vector(iVictim, EV_VEC_velocity, vecVelocity);

			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, iVictim);
			write_short(UNIT_SECOND * 4);
			write_short(UNIT_SECOND * 10);
			write_short(UNIT_SECOND * 10);
			message_end();
		}
	}

	remove_entity(entity);
}

public getSpeedVector(const Float:vecOrigin[3], const Float:vecOriginVictim[3], const Float:speed, Float:vecVelocity[3]) {
	new Float:flVelocity;

	vecVelocity[0] = vecOriginVictim[0] - vecOrigin[0];
	vecVelocity[1] = vecOriginVictim[1] - vecOrigin[1];
	vecVelocity[2] = vecOriginVictim[2] - vecOrigin[2];

	flVelocity = floatsqroot(speed * speed / (vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2]));

	vecVelocity[0] *= flVelocity;
	vecVelocity[1] *= flVelocity;
	vecVelocity[2] *= flVelocity;

	return 1;
}

public fireExplode(const entity, const bomb)
{
	if(bomb)
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
		static iVictim;

		entity_get_vector(entity, EV_VEC_origin, vecOrigin);
		iVictim = -1;

		createExplosion(vecOrigin, 255, 0, 0, 0);

		emitSound(entity, CHAN_WEAPON, SOUND_GRENADE_FIRE);

		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLOSION_RADIUS)) > 0)
		{
			if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Burning_Duration[iVictim] || g_Immunity[iVictim] || g_ImmunityFire[iVictim])
				continue;

			g_Burning_Duration[iVictim] += 50;

			if(!task_exists(iVictim + TASK_BURN))
				set_task(0.2, "task__BurningFlame", iVictim + TASK_BURN, .flags="b");
		}
	}
	else
	{
		if(!is_valid_ent(entity))
			return;

		static Float:vecOrigin[3];
		entity_get_vector(entity, EV_VEC_origin, vecOrigin);

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		write_short(g_Sprite_Explosion);
		write_byte(40);
		write_byte(25);
		write_byte(TE_EXPLFLAG_NOSOUND);
		message_end();

		emit_sound(entity, CHAN_ITEM, "zombie_plague/husk_fireball_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

		static iVictim;
		iVictim = -1;

		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 175.0)) > 0)
		{
			if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim])
				continue;

			g_Burning_Duration[iVictim] += random_num(1, 10);

			if(!task_exists(iVictim + TASK_BURN))
				set_task(0.2, "task__BurningFlame", iVictim + TASK_BURN, .flags="b");
		}
	}

	remove_entity(entity);
}

public frostExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	if(get_entity_flags(ent) & FL_INWATER) {
		remove_entity(ent);
		return;
	}

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	static Float:vecOrigin[3];
	static iVictim;

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	iVictim = -1;

	createExplosion(vecOrigin, 0, 0, 255, 1);

	emitSound(ent, CHAN_WEAPON, SOUND_GRENADE_FROST);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 5.0);
	write_short(g_Sprite_FrostExplode);
	write_byte(20);
	write_byte(24);
	write_byte(TE_EXPLFLAG_NOSOUND);
	message_end();

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLOSION_RADIUS)) > 0) {
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Frozen[iVictim] || g_Immunity[iVictim] || g_ImmunityFrost[iVictim] || (g_FirstZombie[iVictim] && !g_FirstInfect)) {
			continue;
		}

		if(!g_MadnessBomb_Move[iVictim]) {
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iVictim);
			write_short(0);
			write_short(0);
			write_short(FFADE_STAYOUT);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			write_byte(150);
			message_end();
		}

		frostExplodeCube(iVictim);

		g_Frozen[iVictim] = 1;
		g_FrozenGravity[iVictim] = get_user_gravity(iVictim);

		if(get_entity_flags(iVictim) & FL_ONGROUND) {
			set_user_gravity(iVictim, 999999.9);
		} else {
			set_user_gravity(iVictim, 0.000001);
		}

		g_SpeedGravity[iVictim] = g_Speed[iVictim];
		g_Speed[iVictim] = 1.0;

		ExecuteHamB(Ham_Player_ResetMaxSpeed, iVictim);

		remove_task(iVictim + TASK_FROZEN);
		set_task(4.0, "task__RemoveFreeze", iVictim + TASK_FROZEN);

		emitSound(iVictim, CHAN_BODY, SOUND_GRENADE_FROST_PLAYER);
	}

	remove_entity(ent);
}

public frostExplodeCube(const victim) {
	static Float:vecOrigin[3];
	static iEnt;

	if(!is_valid_ent((iEnt = create_entity("info_target")))) {
		return;
	}

	entity_set_string(iEnt, EV_SZ_classname, CLASSNAME_THINK_FROST);

	entity_set_int(iEnt, EV_INT_body, 1);
	entity_set_model(iEnt, MODEL_FROST);

	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);

	if(entity_get_int(victim, EV_INT_button) & IN_DUCK) {
		entity_set_int(victim, EV_INT_button, entity_get_int(victim, EV_INT_button) & ~IN_DUCK);
	}

	entity_get_vector(victim, EV_VEC_origin, vecOrigin);
	vecOrigin[2] -= 36.0;
	entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);

	entity_set_edict(iEnt, EV_ENT_owner, victim);
	entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_NO);
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 4.0);
}

public removeFrostCube(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	static iEnt;
	iEnt = -1;

	if(is_valid_ent((iEnt = find_ent_by_owner(0, CLASSNAME_THINK_FROST, id)))) {
		remove_entity(iEnt);
	}
}

public flareLighting(const entity, const duration) {
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

public grenadeExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	if(get_entity_flags(ent) & FL_INWATER) {
		remove_entity(ent);
		return;
	}

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	static Float:vecOrigin[3];
	static iVictim;

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	iVictim = -1;

	createExplosion(vecOrigin, 200, 100, 0, 0);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_Explosion);
	write_byte(40);
	write_byte(25);
	write_byte(0);
	message_end();

	emitSound(ent, CHAN_WEAPON, SOUND_GRENADE);

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, NADE_EXPLOSION_RADIUS)) > 0) {
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim]) {
			continue;
		}

		if((get_user_health(iVictim) - 500) > 0) {
			set_user_health(iVictim, (get_user_health(iVictim) - 500));
		}
	}

	remove_entity(ent);
}

public createExplosion(const Float:vecOrigin[3], const red, const green, const blue, const balls) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 555.0);
	write_short(g_Sprite_Shockwave);
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

	if(balls) {
		engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_SPRITETRAIL);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		if(red == 0 && green == 0 && blue == 255) { // FrostNade
			write_short(g_Sprite_ColorBall[3]);
		} else if(red == 255 && green == 0 && blue == 0) { // Bazooka
			write_short(g_Sprite_ColorBall[1]);
		}
		write_byte(100);
		write_byte(1);
		write_byte(2);
		write_byte(50);
		write_byte(50);
		message_end();
	}

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

public replaceWeaponModels(const id, const weaponId)
{
	switch(weaponId)
	{
		case CSW_KNIFE:
		{
			if(g_Zombie[id])
			{
				if(g_SpecialMode[id] == MODE_NEMESIS)
					entity_set_string(id, EV_SZ_viewmodel, KNIFE_MODEL_NEMESIS);
				else
				{
					if(g_ZombieClass[id] == ZOMBIE_CLASS_LUSTYROSE && g_ZombieClassLusty_Invi[id])
						entity_set_string(id, EV_SZ_viewmodel, MODEL_CLAW_INVI);
					else
						entity_set_string(id, EV_SZ_viewmodel, __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassClawModel]);
				}

				entity_set_string(id, EV_SZ_weaponmodel, "");
			}
			else
			{
				entity_set_string(id, EV_SZ_viewmodel, UPGRADES_KNIFE[g_UpgradeSelect[id][2]][upgradeModelV]);
				entity_set_string(id, EV_SZ_weaponmodel, UPGRADES_KNIFE[g_UpgradeSelect[id][2]][upgradeModelP]);
			}
		}
		case CSW_HEGRENADE:
		{
			if(!g_Zombie[id]) {
				if(g_MadnessBomb[id]) {
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_vFIRE); // Falta Model
				} else if(g_PipeBomb[id]) {
					entity_set_string(id, EV_SZ_viewmodel, g_MODEL_V_PIPE);
					entity_set_string(id, EV_SZ_weaponmodel, "");
				} else {
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_vFIRE);
				}
			} else { // Infection y Knockback - Mismo Model
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_vINFECTION[0]);
				entity_set_string(id, EV_SZ_weaponmodel, GRENADE_MODEL_vINFECTION[1]);
			}
		} case CSW_FLASHBANG: {
			if(!g_Zombie[id]) {
				entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_vFROST);
			}
		} case CSW_SMOKEGRENADE: {
			if(!g_Zombie[id]) {
				if(g_BubbleBomb[id]) {
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_vBUBBLE);
				} else {
					entity_set_string(id, EV_SZ_viewmodel, GRENADE_MODEL_vFLARE);
				}
			}
		} default: {
			switch(g_SpecialMode[id]) {
				case MODE_SURVIVOR: {
					if(g_CurrentWeapon[id] == CSW_M249) {
						entity_set_string(id, EV_SZ_viewmodel, WEAPON_MODEL_SURVIVOR[0]);
						entity_set_string(id, EV_SZ_weaponmodel, WEAPON_MODEL_SURVIVOR[1]);
					}
				} case MODE_NEMESIS: {
					if(g_Bazooka[id]) {
						if(g_CurrentWeapon[id] == CSW_SG550) {
							entity_set_string(id, EV_SZ_viewmodel, WEAPON_MODEL_vBAZOOKA);
							entity_set_string(id, EV_SZ_weaponmodel, WEAPON_MODEL_pBAZOOKA);
						}

						setUserAnimation(id, 3);
					}
				} default: {
					if(g_Zombie[id]) {
						// . . .
					} else {
						if(g_TypeWeapon[id] == 1 && g_CurrentWeapon[id] == PRIMARY_WEAPONS[g_WeaponPrimary_Current[id]][weaponCSW] && PRIMARY_WEAPONS[g_WeaponPrimary_Current[id]][weaponModel][0]) {
							entity_set_string(id, EV_SZ_viewmodel, PRIMARY_WEAPONS[g_WeaponPrimary_Current[id]][weaponModel]);
						} else if(g_TypeWeapon[id] == 2 && g_CurrentWeapon[id] == SECONDARY_WEAPONS[g_WeaponSecondary_Current[id]][weaponCSW] && SECONDARY_WEAPONS[g_WeaponSecondary_Current[id]][weaponModel][0]) {
							entity_set_string(id, EV_SZ_viewmodel, SECONDARY_WEAPONS[g_WeaponSecondary_Current[id]][weaponModel]);
						}
					}
				}
			}
		}
	}
}

public giveExperience(const id, const value) {
	g_Exp[id] += value;
	checkLevel(id);
}

public fixExperience(const id) {
	g_Exp[id] = NEED_EXP_TOTAL[g_Level[id] - 1];
	checkLevel(id);
}

public checkLevel(const id) {
	g_ExpRest[id] = NEED_EXP_TOTAL[g_Level[id]] - g_Exp[id];

	if(g_ExpRest[id] <= 0) {
		if(g_Level[id] >= MAX_LEVEL) {
			g_ExpRest[id] = 0;
			return;
		}

		static iLevel;
		iLevel = 0;

		while(g_ExpRest[id] <= 0) {
			++g_Level[id];
			++iLevel;

			if(g_Level[id] == MAX_LEVEL) {
				g_ExpRest[id] = 0;
				break;
			}

			g_ExpRest[id] = NEED_EXP_TOTAL[g_Level[id]] - g_Exp[id];
		}

		if(iLevel) {
			playSound(id, SOUND_LEVEL_UP);

			client_print(id, print_center, "Felicidades! Avanzaste al nivel %d", g_Level[id]);

			g_Range[id] = clamp((g_Level[id] / 10), 0, charsmax(RANGES));
		}
	}

	g_LevelPercent[id] = clampfloat(((float(g_Exp[id]) - float(NEED_EXP_TOTAL[g_Level[id] - 1])) * 100.0) / (float(NEED_EXP_TOTAL[g_Level[id]]) - float(NEED_EXP_TOTAL[g_Level[id] - 1])), 0.0, 100.0);
}

public checkRound(const leavingId) {
	if(g_EndRound || task_exists(TASK_STARTMODE)) {
		return;
	}

	static iUsersNum;
	static iId;

	iUsersNum = getAlives();

	if(iUsersNum < 3) {
		return;
	}

	if(g_Zombie[leavingId] && getZombies() == 1) {
		if(g_Mode == MODE_JERUZALEM) {
			modeJeruzalemFinish(TEAM_CT, leavingId);
			return;
		}

		if(getHumans() == 1 && getCTs() == 1) {
			return;
		}

		while((iId = getRandomAlive(random_num(1, iUsersNum))) == leavingId) {
			// ...
		}

		switch(g_SpecialMode[leavingId]) {
			case MODE_NEMESIS: {
				dg_color_chat(0, _, "El NEMESIS se ha desconectado, !g%s!y es el nuevo NEMESIS", g_User_Name[iId]);
				zombieMe(iId, .nemesis = 1);

				set_user_health(iId, g_Health[leavingId]);
			} default: {
				dg_color_chat(0, _, "El último zombie se ha desconectado, !g%s!y es el nuevo zombie", g_User_Name[iId]);
				zombieMe(iId);
			}
		}
	} else if(!g_Zombie[leavingId]) {
		if(g_SpecialMode[leavingId] == MODE_JERUZALEM) {
			--g_VIPsDead;

			if(g_VIPsDead) {
				dg_color_chat(0, _, "Uno de los VIPs se desconectó");
			} else {
				dg_color_chat(0, _, "El único VIP vivo se desconectó y los zombies ganan la ronda");

				modeJeruzalemFinish(TEAM_TERRORIST, leavingId);
				return;
			}
		}

		if(getHumans() == 1) {
			if(getZombies() == 1 && getTs() == 1) {
				return;
			}

			while((iId = getRandomAlive(random_num(1, iUsersNum))) == leavingId) {
				// ...
			}

			switch(g_SpecialMode[leavingId]) {
				case MODE_SURVIVOR: {
					dg_color_chat(0, _, "El SURVIVOR se ha desconectado, !g%s!y es el nuevo SURVIVOR", g_User_Name[iId]);
					humanMe(iId, .survivor = 1);

					set_user_health(iId, g_Health[leavingId]);
				} default: {
					dg_color_chat(0, _, "El último humano se ha desconectado, !g%s!y es el nuevo humano", g_User_Name[iId]);
					humanMe(iId);
				}
			}
		}
	}
}

setAchievement(const id, const achId, achFake=0) {
	if(!g_Account_Logged[id]) {
	    return;
	}

	if(g_Achievement[id][achId] && !ACHS[achId][achievementCanBeRepeated]) {
		return;
	}

	if(ACHS[achId][achUsersNeed] && !achFake) {
		if(getPlaying() < ACHS[achId][achUsersNeed]) {
			return;
		}
	}

	g_Achievement[id][achId] = 1;
	++g_AchievementCount[id][achId];
	get_time("%Y-%m-%d %H:%M:%S", g_AchievementUnlocked[id][achId], 31);

	new sQuery[512];
	new sAchievementCount[16];

	if(g_AchievementCount[id][achId] == 1) {
		formatex(sQuery, 511, "INSERT INTO ze1_achievements (`ze_id`, `achievement_id`, `achievement_name`, `achievement_date`, `achievement_type`) VALUES ('%d', '%d', ^"%s^", now(), '0');", g_Account_Id[id], achId, ACHS[achId][achName]);
	} else {
		formatex(sQuery, 511, "UPDATE ze1_achievements SET achievement_count=%d WHERE ze_id=%d AND achievement_id=%d;", g_AchievementCount[id][achId], g_Account_Id[id], achId);
		formatex(sAchievementCount, 15, " (x%d)", g_AchievementCount[id][achId]);
	}

	SQL_ThreadQuery(g_SqlTuple, "sqlThread__Achievement", sQuery);

	if(ACHS[achId][achRewardExp] && !ACHS[achId][achRewardPU]) {
		giveExperience(id, ACHS[achId][achRewardExp]);
		dg_color_chat(0, id, "!t%s!y ganó el logro !g%s%s!y !t(%d EXP) [X]!y", g_User_Name[id], ACHS[achId][achName], (g_AchievementCount[id][achId] == 1) ? "" : sAchievementCount, ACHS[achId][achRewardExp]);
	} else if(!ACHS[achId][achRewardExp] && ACHS[achId][achRewardPU]) {
		g_Points[id] += ACHS[achId][achRewardPU];
		dg_color_chat(0, id, "!t%s!y ganó el logro !g%s%s!y !t(%d pU) [X]!y", g_User_Name[id], ACHS[achId][achName], (g_AchievementCount[id][achId] == 1) ? "" : sAchievementCount, ACHS[achId][achRewardPU]);
	} else {
		g_Points[id] += ACHS[achId][achRewardPU];

		if(achId != APP_DAILY_VISIT) {
			giveExperience(id, ACHS[achId][achRewardExp]);
			dg_color_chat(0, id, "!t%s!y ganó el logro !g%s%s!y !t(%d EXP - %d pU) [X]!y", g_User_Name[id], ACHS[achId][achName], (g_AchievementCount[id][achId] == 1) ? "" : sAchievementCount, ACHS[achId][achRewardExp], ACHS[achId][achRewardPU]);
		} else {
			giveExperience(id, g_AchievementCount[id][achId] * 25);
			dg_color_chat(0, id, "!t%s!y ganó el logro !g%s%s!y !t(%d EXP - %d pU) [X]!y", g_User_Name[id], ACHS[achId][achName], (g_AchievementCount[id][achId] == 1) ? "" : sAchievementCount, (g_AchievementCount[id][achId] * 25), ACHS[achId][achRewardPU]);
		}
	}

	g_AchievementLink_Id = achId;
	g_AchievementLink_Class = ACHS[achId][achClass];
	g_AchievementLink_MenuPage = 0;

	++g_Stats_General[id][STATS_ACHIEVEMENTS_D];

	if(g_Stats_General[id][STATS_ACHIEVEMENTS_D] >= 50) {
		switch(g_Stats_General[id][STATS_ACHIEVEMENTS_D]) {
			case 50: setAchievement(id, x50_LOGROS);
			case 100: setAchievement(id, x100_LOGROS);
			case 250: setAchievement(id, x250_LOGROS);
		}

		return;
	}

	if(!g_MetaAchievement[id][MAESTRO_ESCAPES] && g_Achievement[id][x40_ESCAPES] && g_Achievement[id][x100_ESCAPES] && g_Achievement[id][x280_ESCAPES] && g_Achievement[id][x400_ESCAPES] && g_Achievement[id][x540_ESCAPES] &&
	g_Achievement[id][x700_ESCAPES] && g_Achievement[id][x800_ESCAPES] && g_Achievement[id][x1080_ESCAPES] && g_Achievement[id][x1300_ESCAPES] && g_Achievement[id][x2500_ESCAPES] && g_Achievement[id][x5000_ESCAPES] &&
	g_Achievement[id][x7500_ESCAPES] && g_Achievement[id][x12500_ESCAPES] && g_Achievement[id][x30000_ESCAPES] && g_Achievement[id][x50000_ESCAPES] && g_Achievement[id][x100000_ESCAPES])
	{
		setMetaAchievement(id, MAESTRO_ESCAPES);
		return;
	}

	if(!g_MetaAchievement[id][MASTER_SUPPLY_BOXES] && g_Achievement[id][SUPPLY_BOX_X1] && g_Achievement[id][SUPPLY_BOX_X10] && g_Achievement[id][SUPPLY_BOX_X50] && g_Achievement[id][SUPPLY_BOX_X100] &&
	g_Achievement[id][SUPPLY_BOX_X500] && g_Achievement[id][SUPPLY_BOX_X1000] && g_Achievement[id][SUPPLY_BOX_X2_SAME_ROUND] && g_Achievement[id][SUPPLY_BOX_X3_SAME_ROUND] && g_Achievement[id][SUPPLY_BOX_X4_SAME_ROUND] && g_Achievement[id][SUPPLY_BOX_X5_SAME_ROUND])
	{
		setMetaAchievement(id, MASTER_SUPPLY_BOXES);
		return;
	}

	saveInfo(id);
}

public sqlThread__Achievement(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime) {
	switch(failstate) {
		case TQUERY_CONNECT_FAILED: {
			log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__Achievement - %d - %s", errorNum, error);
			return;
		} case TQUERY_QUERY_FAILED: {
			log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__Achievement - %d - %s", errorNum, error);
		}
	}
}

setAchievementFirst(const id, const achId, achFake=0) {
	if(g_Achievement[0][achId]) {
		return;
	}

	if(ACHS[achId][achUsersNeed] && !achFake) {
		if(getPlaying() < ACHS[achId][achUsersNeed]) {
			return;
		}
	}

	g_Achievement[0][achId] = 1;
	get_time("%Y-%m-%d %H:%M:%S", g_AchievementUnlocked[0][achId], 31);
	g_Achievement[id][achId] = 1;
	get_time("%Y-%m-%d %H:%M:%S", g_AchievementUnlocked[id][achId], 31);

	new sQuery[512];
	formatex(sQuery, 511, "INSERT INTO ze1_achievements (`ze_id`, `achievement_id`, `achievement_name`, `achievement_date`, `achievement_type`, `achievement_first`) VALUES ('%d', '%d', ^"%s^", now(), '0', '1');", g_Account_Id[id], achId, ACHS[achId][achName]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__Achievement", sQuery);

	if(ACHS[achId][achRewardExp] && !ACHS[achId][achRewardPU]) {
		giveExperience(id, ACHS[achId][achRewardExp]);
		dg_color_chat(0, id, "!t%s!y ganó el logro !g%s!y !t(%d EXP)!y", g_User_Name[id], ACHS[achId][achName], ACHS[achId][achRewardExp]);
	} else if(!ACHS[achId][achRewardExp] && ACHS[achId][achRewardPU]) {
		g_Points[id] += ACHS[achId][achRewardPU];
		dg_color_chat(0, id, "!t%s!y ganó el logro !g%s!y !t(%d pU)!y", g_User_Name[id], ACHS[achId][achName], ACHS[achId][achRewardPU]);
	} else {
		giveExperience(id, ACHS[achId][achRewardExp]);
		g_Points[id] += ACHS[achId][achRewardPU];

		dg_color_chat(0, id, "!t%s!y ganó el logro !g%s!y !t(%d EXP - %d pU)!y", g_User_Name[id], ACHS[achId][achName], ACHS[achId][achRewardExp], ACHS[achId][achRewardPU]);
	}

	++g_Stats_General[id][STATS_ACHIEVEMENTS_D];

	saveInfo(id);
}

setMetaAchievement(const id, const metaAchId) {
	if(g_MetaAchievement[id][metaAchId]) {
		return;
	}

	g_MetaAchievement[id][metaAchId] = 1;
	get_time("%Y-%m-%d %H:%M:%S", g_MetaAchievementUnlocked[id][metaAchId], 31);

	new sQuery[512];
	formatex(sQuery, 511, "INSERT INTO ze1_achievements (`ze_id`, `achievement_id`, `achievement_name`, `achievement_date`, `achievement_type`) VALUES ('%d', '%d', ^"%s^", now(), '1');", g_Account_Id[id], metaAchId, META_ACHIEVEMENTS[metaAchId][achName]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__MetaAchievement", sQuery);

	if(META_ACHIEVEMENTS[metaAchId][achRewardExp] && !META_ACHIEVEMENTS[metaAchId][achRewardPU]) {
		giveExperience(id, META_ACHIEVEMENTS[metaAchId][achRewardExp]);
		dg_color_chat(0, id, "!t%s!y ganó el meta-logro !g%s!y !t(%d EXP)!y", g_User_Name[id], META_ACHIEVEMENTS[metaAchId][achName], META_ACHIEVEMENTS[metaAchId][achRewardExp]);
	} else if(!META_ACHIEVEMENTS[metaAchId][achRewardExp] && META_ACHIEVEMENTS[metaAchId][achRewardPU]) {
		g_Points[id] += META_ACHIEVEMENTS[metaAchId][achRewardPU];
		dg_color_chat(0, id, "!t%s!y ganó el meta-logro !g%s!y !t(%d pU)!y", g_User_Name[id], META_ACHIEVEMENTS[metaAchId][achName], META_ACHIEVEMENTS[metaAchId][achRewardPU]);
	} else {
		giveExperience(id, META_ACHIEVEMENTS[metaAchId][achRewardExp]);
		g_Points[id] += META_ACHIEVEMENTS[metaAchId][achRewardPU];

		dg_color_chat(0, id, "!t%s!y ganó el meta-logro !g%s!y !t(%d EXP - %d pU)!y", g_User_Name[id], META_ACHIEVEMENTS[metaAchId][achName], META_ACHIEVEMENTS[metaAchId][achRewardExp], META_ACHIEVEMENTS[metaAchId][achRewardPU]);
	}

	++g_Stats_General[id][STATS_ACHIEVEMENTS_D];

	saveInfo(id);
}

public sqlThread__MetaAchievement(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime) {
	switch(failstate) {
		case TQUERY_CONNECT_FAILED: {
			log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__AchievementFirst - %d - %s", errorNum, error);
			return;
		} case TQUERY_QUERY_FAILED: {
			log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__AchievementFirst - %d - %s", errorNum, error);
		}
	}
}

public setHat(const id, hatId) {
	if(!g_IsAlive[id]) {
		return;
	}

	if(is_valid_ent(g_HatEnt[id])) {
		remove_entity(g_HatEnt[id]);
	}

	g_HatNext[id] = 0;
	g_HatId[id] = hatId;

	if(!hatId) {
		return;
	}

	g_HatEnt[id] = create_entity("info_target");

	if(is_valid_ent(g_HatEnt[id]))
	{
		entity_set_string(g_HatEnt[id], EV_SZ_classname, "entHat");

		entity_set_int(g_HatEnt[id], EV_INT_solid, SOLID_NOT);
		entity_set_int(g_HatEnt[id], EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(g_HatEnt[id], EV_ENT_aiment, id);
		entity_set_edict(g_HatEnt[id], EV_ENT_owner, id);

		entity_set_int(g_HatEnt[id], EV_INT_iuser3, 1337);

		entity_set_model(g_HatEnt[id], UPGRADES_HAT[hatId][upgradeModelV]); // g_aUpgradesHat
	}
}

public resetInfo(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

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
	client_cmd(id, "setinfo zpt ^"^"");
	client_cmd(id, "setinfo zp4 ^"^"");
	client_cmd(id, "setinfo jb1 ^"^"");
}

public resetVars(const id, const resetAll)
{
	g_WeaponPrimary_Bought[id] = 0;
	g_WeaponSecondary_Bought[id] = 0;
	g_WeaponPrimary_Current[id] = 0;
	g_WeaponSecondary_Current[id] = 0;
	g_Zombie[id] = 0;
	g_FirstZombie[id] = 0;
	g_SpecialMode[id] = 0;
	g_RespawnAsZombie[id] = 0;
	g_LastZombie[id] = 0;
	g_LastHuman[id] = 0;
	g_LastHuman_1000hp[id] = 0;
	g_Immunity[id] = 0;
	g_ImmunityFire[id] = 0;
	g_ImmunityFrost[id] = 0;
	g_Frozen[id] = 0;
	g_Burning_Duration[id] = 0;
	g_KnockBackBomb[id] = 0;
	g_GrenadeBomb[id] = 0;
	g_BubbleBomb[id] = 0;
	g_BubbleIn[id] = 0;
	g_MadnessBomb[id] = 0;
	g_MadnessBomb_Count[id] = 0;
	g_MadnessBomb_Move[id] = 0;
	g_IsEscaped[id] = 0;
	g_UserBullet[id] = 0;
	if(g_Mode != MODE_NEMESIS_EXTREM)
		g_Escaped[id] = 0;
	g_Breakabled[id] = 0;
	g_Buttoned[id] = 0;
	g_Bazooka[id] = 0;
	g_UnlimitedClip[id] = false;
	g_PipeBomb[id] = 0;
	g_ModeJeruzalem_RewardExp[id] = 0;
	g_VIPsKilled[id] = 0;
	g_ZombieClassHeavy_Trampped[id] = 0;
	g_ZombieClassBanchee_Stat[id] = 0;
	g_ZombieClassBanchee_Enemy[id] = 0;
	g_ZombieClassVoodoo_CanHealth[id] = 0;
	g_ZombieClassLusty_Invi[id] = 0;
	g_ZombieClassLusty_InviWait[id] = 0;
	g_ZombieClassToxico_LastUsed[id] = get_gametime();
	g_ZombieClassFarahon_LastUsed[id] = 0.0;

	set_user_rendering(id);
	setUserLongJump(id, 0);

	if(resetAll)
	{
		static i;

		g_RewardAmmoPacksKill[id] = 0;
		g_RewardAmmoPacksDamage[id] = 0;
		g_RewardAmmoPacksInfect[id] = 0;

		g_DailyVisitAlreadyCounted[id] = 0;
		g_DailyVisit[id] = 0;
		g_ModelHuman[id] = 0;
		g_AllowChangeTeam[id] = 0;
		g_Account_Id[id] = 0;
		g_AccountJoined[id] = 0;
		g_AccountCheck[id] = 0;
		g_AccountRegistering[id] = 0;
		g_AccountLoading[id] = 0;
		g_Account_Password[id][0] = EOS;
		g_Account_Register[id] = 0;
		g_Account_Logged[id] = 0;
		g_Account_Banned[id] = 0;
		g_Account_RegisterSince[id][0] = EOS;
		g_Account_LastConnection[id][0] = EOS;
		g_Account_Rank[id] = 0;
		g_AccountPremium[id] = 0;
		g_BlockSound[id] = 0;
		g_Weapon_AutoBuy[id] = 0;
		g_WeaponPrimary_Selection[id] = 0;
		g_WeaponSecondary_Selection[id] = 0;
		g_HumanClass[id] = g_HumanClassNext[id] = 0;
		g_ZombieClass[id] = 0;
		g_ZombieClassNext[id] = 0;
		g_ZombieClassHeavy_MakeTramp[id] = 0;
		g_ZombieClassBanchee_BatTime[id] = 0;
		g_SurvivorClass[id] = g_SurvivorClassNext[id] = 0;
		g_NemesisClass[id] = g_NemesisClassNext[id] = 0;
		g_Level[id] = 1;
		g_Exp[id] = 0;
		g_ExpRest[id] = 0;
		g_AmmoPacks[id] = 20;
		g_PlayedTime[id] = {0, 0, 0, 0};
		g_Points[id] = 0;
		g_PointsLose[id] = 0;
		for(i = 0; i < sizeof(UPGRADES_SKIN); ++i) {
			g_UpgradesSkin[id][i] = 0;
		}
		for(i = 0; i < sizeof(UPGRADES_HAT); ++i) {
			g_UpgradesHat[id][i] = 0;
		}
		for(i = 0; i < sizeof(UPGRADES_KNIFE); ++i) {
			g_UpgradesKnife[id][i] = 0;
		}
		g_UpgradeSelect[id] = {0, 0, 0};
		for(i = 0; i < structIdAchievements; ++i) {
			g_Achievement[id][i] = 0;
			g_AchievementCount[id][i] = 0;
			g_AchievementUnlocked[id][i][0] = EOS;
		}
		for(i = 0; i < structIdMetaAchievements; ++i) {
			g_MetaAchievement[id][i] = 0;
			g_MetaAchievementUnlocked[id][i][0] = EOS;
		}
		for(i = 0; i < struckIdStatsGeneral; ++i) {
			g_Stats_General[id][i] = 0;
		}
		g_Color[id][COLOR_HUD] = {255, 165, 0};
		g_Color[id][COLOR_FLARE] = {255, 255, 255};
		g_HudGeneral_Effect[id] = 0;
		g_HudGeneral_Abrev[id] = 0;
		g_HudGeneral_Mini[id] = 0;
		for(i = 0; i < struckIdPages; ++i) {
			g_MenuPage[id][i] = 0;
		}
		for(i = 0; i < struckIdData; ++i) {
			g_MenuData[id][i] = 0;
		}
		g_HatNext[id] = 0;
		g_HatId[id] = 0;
		g_HatEnt[id] = 0;
		g_Invis[id] = 0;
		g_Range[id] = 0;
		g_AmmoDamage[id] = 500.0;
		g_ExpDamage[id] = 1000.0;
		g_Speed[id] = 240.0;
		g_KnockBack[id] = 1.0;
		g_LevelPercent[id] = 0.0;
		g_HudGeneral_Position[id] = Float:{0.75, 0.2, 0.0};
		g_Stats_DamageCount[id][0] = 0.0;
		g_Stats_DamageCount[id][1] = 0.0;

		g_AmbienceSound_Muted[id] = AMBIENCE_MUTED_NONE;
		g_Secret_AlreadySayCrazy[id] = false;
		g_Vinc[id] = false;
		g_VincAppMobile[id] = false;
	}
}

public fireBazooka(const id) {
	--g_Bazooka[id];

	if(g_Bazooka[id] < 1) {
		strip_user_weapons(id);
		give_item(id, "weapon_knife");
	}

	entity_set_vector(id, EV_FLARE_COLOR, Float:{-10.5, 0.0, 0.0});

	setUserAnimation(id, 8);

	new Float:flViewOffs[3];
	new Float:flOrigin[3];
	new Float:flAngles[3];

	entity_get_vector(id, EV_VEC_view_ofs, flViewOffs);
	entity_get_vector(id, EV_VEC_origin, flOrigin);
	xs_vec_add(flOrigin, flViewOffs, flOrigin);
	entity_get_vector(id, EV_VEC_v_angle, flAngles);

	new iEnt;
	iEnt = create_entity("info_target");

	if(!is_valid_ent(iEnt)) {
		return;
	}

	entity_set_string(iEnt, EV_SZ_classname, "ent__Rocket");
	entity_set_model(iEnt, MODEL_ROCKET);

	set_size(iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
	entity_set_vector(iEnt, EV_VEC_mins, Float:{-1.0, -1.0, -1.0});
	entity_set_vector(iEnt, EV_VEC_maxs, Float:{1.0, 1.0, 1.0});

	entity_set_origin(iEnt, flOrigin);

	flAngles[0] -= 45.0;
	engfunc(EngFunc_MakeVectors, flAngles);
	flAngles[0] = -(flAngles[0] + 45.0);

	entity_set_vector(iEnt, EV_VEC_angles, flAngles);
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(iEnt, EV_ENT_owner, id);

	emitSound(iEnt, CHAN_VOICE, SOUND_ROCKET_01);
	emitSound(iEnt, CHAN_WEAPON, SOUND_ROCKET_00);

	new Float:flVelocity[3];
	VelocityByAim(id, 1200, flVelocity);
	entity_set_vector(iEnt, EV_VEC_velocity, flVelocity);

	set_rendering(iEnt, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 50);

	entity_set_edict(iEnt, EV_ENT_FLARE, fn_create_flare(iEnt));
	entity_set_int(iEnt, EV_INT_effects, entity_get_int(iEnt, EV_INT_effects) | EF_BRIGHTLIGHT);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iEnt);
	write_short(g_Sprite_Laserbeam);
	write_byte(30);
	write_byte(3);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(200);
	message_end();

	set_task(0.1, "spritetrail_rocket", iEnt);
}

public spritetrail_rocket(entity) {
	if(!is_valid_ent(entity)) {
		return;
	}

	new Float:flOriginEnt[3];
	new ent_origin[3];

	entity_get_vector(entity, EV_VEC_origin, flOriginEnt);
	ent_origin[0] = floatround(flOriginEnt[0]);
	ent_origin[1] = floatround(flOriginEnt[1]);
	ent_origin[2] = floatround(flOriginEnt[2]);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITETRAIL);
	write_coord(ent_origin[0]);
	write_coord(ent_origin[1]);
	write_coord(ent_origin[2] - 20);
	write_coord(ent_origin[0]);
	write_coord(ent_origin[1]);
	write_coord(ent_origin[2] + 20);
	write_short(g_Sprite_ColorBall[1]);
	write_byte(30);
	write_byte(2);
	write_byte(5);
	write_byte(random_num(5, 50));
	write_byte(40);
	message_end();

	set_task(0.2, "spritetrail_rocket", entity);
}

fn_create_flare(rocket) {
	new entity = create_entity("env_sprite");

	if(!is_valid_ent(entity)) {
		return 0;
	}

	entity_set_model(entity, "sprites/animglow01.spr");

	entity_set_float(entity, EV_FL_scale, 0.7);
	entity_set_int(entity, EV_INT_spawnflags, SF_SPRITE_STARTON);
	entity_set_int(entity, EV_INT_solid, SOLID_NOT);
	entity_set_int(entity, EV_INT_movetype, MOVETYPE_FOLLOW);
	entity_set_edict(entity, EV_ENT_aiment, rocket);
	entity_set_edict(entity, EV_ENT_owner, rocket);
	entity_set_float(entity, EV_FL_framerate, 25.0);

	set_rendering(entity, kRenderFxNone, 255, 0, 0, kRenderTransAdd, 255);

	DispatchSpawn(entity);
	return entity;
}

public playSound(const id, const sound[]) {
	if(equal(sound[strlen(sound) - 4], ".mp3")) {
		client_cmd(id, "mp3 play %s", sound);
	} else {
		client_cmd(id, "spk ^"%s^"", sound);
	}
}

emitSound(const id, const channel, const sample[], Float:volume = 1.0, Float:attn = ATTN_NORM, flags = 0, pitch = PITCH_NORM) {
	emit_sound(id, channel, sample, volume, attn, flags, pitch);
}

public addDot(const number, sOutPut[], const len) {
	static sTemp[11];
	static iOutputPos;
	static iNumPos;
	static iNumLen;

	iOutputPos = 0;
	iNumPos = 0;
	iNumLen = num_to_str(number, sTemp, charsmax(sTemp));

	while((iNumPos < iNumLen) && (iOutputPos < len)) {
		sOutPut[iOutputPos++] = sTemp[iNumPos++];

		if((iNumLen - iNumPos) && !((iNumLen - iNumPos) % 3)) {
			sOutPut[iOutputPos++] = '.';
		}
	}

	sOutPut[iOutputPos] = EOS;
	return iOutputPos;
}

public addDot__Special(const number[], sOutPut[], const len) {
	static iStop;
	static iOut;
	static i;

	iStop = contain(number, ".");
	iOut = 0;
	i = 0;

	if(iStop == -1) {
		iStop = strlen(number);
	}

	while(i < iStop && iOut < len) {
		sOutPut[iOut++] = number[i++];

		if(iOut < len && i < iStop && ((iStop - i) % 3) == 0) {
			sOutPut[iOut++] = '.';
		}
	}

	if(iOut < len) {
		iOut += copy(sOutPut[iOut], len - iOut, number[iStop]);
	}

	return iOut;
}

public turnOffFlashlight(const id) {
	entity_set_int(id, EV_INT_effects, entity_get_int(id, EV_INT_effects) & ~EF_DIMLIGHT);

	message_begin(MSG_ONE_UNRELIABLE, g_Message_Flashlight, _, id);
	write_byte(0);
	write_byte(100);
	message_end();

	entity_set_int(id, EV_INT_impulse, 0);
}

public isHullVacant(const Float:origin[3], const hull) {
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0);

	if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen)) {
		return 1;
	}

	return 0;
}

public isUserStuck(const id) {
	static Float:vecOrigin[3];
	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, (entity_get_int(id, EV_INT_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);

	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen)) {
		return 1;
	}

	return 0;
}

public isSolid(const entity) {
	return (entity ? ((entity_get_int(entity, EV_INT_solid) > SOLID_TRIGGER) ? 1 : 0) : 1);
}

public containLetters(const string[]) {
	new const iLen = strlen(string);
	new i;

	for(i = 0; i < iLen; ++i) {
		if(!isalpha(string[i])) {
			return 0;
		}
	}

	return 1;
}

public countNumbers(const string[]) {
	new const iLen = strlen(string);
	new i;

	for(i = 0; i < iLen; ++i) {
		if(isdigit(string[i])) {
			return 1;
		}
	}

	return 0;
}

public checkWeaponBuy(const id) {
	if(g_WeaponPrimary_Bought[id] && g_WeaponSecondary_Bought[id]) {
		return 1;
	}

	return 0;
}

public dropWeapons(const id, const dropwhat) {
	if(!g_IsConnected[id]) {
		return;
	}

	static sWeapons[32];
	static iWeaponId;
	static iNum;
	static i;

	iNum = 0;
	get_user_weapons(id, sWeapons, iNum);

	for(i = 0; i < iNum; ++i) {
		iWeaponId = sWeapons[i];

		if((dropwhat == 1 && ((1<<iWeaponId) & PRIMARY_WEAPONS_BIT_SUM)) ||
		(dropwhat == 2 && ((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM))) {
			static sWeaponName[32];
			get_weaponname(iWeaponId, sWeaponName, charsmax(sWeaponName));

			engclient_cmd(id, "drop", sWeaponName);
		}
	}
}

public sendDeathMsg(const attacker, const victim) {
	message_begin(MSG_BROADCAST, g_Message_DeathMsg);
	write_byte(attacker);
	write_byte(victim);
	write_byte(1);
	write_string("infection");
	message_end();

	set_user_frags(attacker, get_user_frags(attacker) + 1);
	set_pdata_int(victim, OFFSET_CSDEATHS, cs_get_user_deaths(victim) + 1, OFFSET_LINUX);

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

public fixDeadAttrib(const id) {
	message_begin(MSG_BROADCAST, g_Message_ScoreAttrib);
	write_byte(id);
	write_byte(0);
	message_end();
}

public setUserLongJump(const id, const value) {
	if(pev_valid(id) != PDATA_SAFE) {
		return;
	}

	set_pdata_int(id, OFFSET_LONG_JUMP, value, OFFSET_LINUX);

	g_LongJump[id] = value;
	g_InJump[id] = 0;
}

public setLight(const id, const light[]) {
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id);
	write_byte(0);
	write_string(light);
	message_end();
}

public setUserAnimation(const id, const animation) {
	entity_set_int(id, EV_INT_weaponanim, animation);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
	write_byte(animation);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

public setUserTeam(const id, const TeamName:team)
	rg_set_user_team(id, team);

public setUserModel(taskId) {
	static id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_MODEL) : taskId;

	if(!isUserValidConnected(id)) {
		return;
	}

	set_user_info(id, "model", g_User_Model[id]);
}

public getUserModel(const id, model[], const len) {
	get_user_info(id, "model", model, len);
}

public getWeaponEntId(const entity) {
	if(pev_valid(entity) != PDATA_SAFE) {
		return -1;
	}

	return get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

public getCurrentWeaponEnt(const id) {
	if(pev_valid(id) != PDATA_SAFE) {
		return -1;
	}

	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

public setUserBatteries(const id, const value) {
	if(pev_valid(id) != PDATA_SAFE) {
		return;
	}

	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX);
}

public getRandomAlive(const number) {
	static iAlive;
	static i;

	iAlive = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i]) {
			++iAlive;
		}

		if(iAlive == number) {
			return i;
		}
	}

	return -1;
}

public getPlaying() {
	static iCount;
	static i;

	iCount = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsConnected[i] && (getUserTeam(i) == TEAM_TERRORIST || getUserTeam(i) == TEAM_CT)) {
			++iCount;
		}
	}

	return iCount;
}

public getCTs() {
	static iCTs;
	static id;

	iCTs = 0;

	for(id = 1; id <= g_MaxUsers; ++id) {
		if(g_IsConnected[id]) {
			if(getUserTeam(id) == TEAM_CT) {
				++iCTs;
			}
		}
	}

	return iCTs;
}

public getTs() {
	static iTs;
	static id;

	iTs = 0;

	for(id = 1; id <= g_MaxUsers; ++id) {
		if(g_IsConnected[id]) {
			if(getUserTeam(id) == TEAM_TERRORIST) {
				++iTs;
			}
		}
	}

	return iTs;
}

public getAlives() {
	static iCount;
	static i;

	iCount = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i]) {
			++iCount;
		}
	}

	return iCount;
}

public getHumans() {
	static iCount;
	static i;

	iCount = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i] && !g_Zombie[i]) {
			++iCount;
		}
	}

	return iCount;
}

public getZombies() {
	static iCount;
	static i;

	iCount = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i] && g_Zombie[i]) {
			++iCount;
		}
	}

	return iCount;
}

public getAliveTs() {
	static iCount;
	static i;

	iCount = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i]) {
			if(getUserTeam(i) == TEAM_TERRORIST) {
				++iCount;
			}
		}
	}

	return iCount;
}

public getAliveCTs() {
	static iCount;
	static i;

	iCount = 0;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i]) {
			if(getUserTeam(i) == TEAM_CT) {
				++iCount;
			}
		}
	}

	return iCount;
}

public getSurvivorId() {
	if(g_Mode != MODE_SURVIVOR) {
		return -1;
	}

	static i;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i] && g_SpecialMode[i] == MODE_SURVIVOR) {
			return i;
		}
	}

	return -1;
}

public getNemesisId() {
	if(g_Mode != MODE_NEMESIS) {
		return -1;
	}

	static i;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(g_IsAlive[i] && g_SpecialMode[i] == MODE_NEMESIS) {
			return i;
		}
	}

	return -1;
}

public Float:clampfloat(const Float:value, const Float:min, const Float:max) {
	if(value < min) {
		return min;
	} else if(value > max) {
		return max;
	}

	return value;
}

public arrayToString(const array[], const size, output[], const len, const end) {
	new iLen;
	new i;

	do {
		iLen += formatex(output[iLen], len - iLen, "%d ", array[i]);
	} while(++i < size && iLen < len);

	if(i < size) {
		return 0;
	}

	if(end) {
		output[iLen - 1] = '^0';
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

public checkScripterAccess(const id)
{
	if(equal(g_User_SteamId[id], "STEAM_0:1:424403388")) // Atsel.
		return 1;

	return 0;
}

public bubblePush(const entity) {
	static iVictim;
	static Float:fInvSqrt;
	static Float:fScalar;
	static Float:vecOrigin[3];
	static Float:vecEntityOrigin[3];
	static iUsers[MAX_USERS];
	static i;
	static j;

	entity_get_vector(entity, EV_VEC_origin, vecEntityOrigin);

	iVictim = -1;
	j = 0;

	while((iVictim = find_ent_in_sphere(iVictim, vecEntityOrigin, 120.0)) != 0) {
		if(is_user_alive(iVictim)) {
			iUsers[j++] = iVictim;
		}
	}

	for(i = 0; i < j; ++i) {
		if(!g_Zombie[iUsers[i]]) {
			entity_get_vector(iUsers[i], EV_VEC_origin, vecOrigin);

			if(get_distance_f(vecEntityOrigin, vecOrigin) <= 100) {
				g_BubbleIn[iUsers[i]] = 1;
			} else {
				g_BubbleIn[iUsers[i]] = 0;
			}
		} else if(g_Zombie[iUsers[i]] && !g_SpecialMode[iUsers[i]] && !g_Immunity[iUsers[i]] && g_FirstInfect) {
			entity_get_vector(iUsers[i], EV_VEC_origin, vecOrigin);

			if(get_distance_f(vecEntityOrigin, vecOrigin) > 100) {
				fScalar = 255.0;
			} else {
				fScalar = 2750.0;
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

public madnessExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	static iAttacker;
	iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	static Float:vecOrigin[3];
	static iVictim;

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	iVictim = -1;

	createExplosion(vecOrigin, random(256), random(256), random(256), 0);

	emitSound(ent, CHAN_WEAPON, SOUND_GRENADE_FIRE);

	while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOrigin, NADE_EXPLOSION_RADIUS)) != 0) {
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_MadnessBomb_Move[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || (g_FirstZombie[iVictim] && !g_FirstInfect)) {
			continue;
		}

		g_MadnessBomb_Count[iVictim] = 0;

		remove_task(iVictim + TASK_MADNESS_BOMB);
		set_task(0.5, "confuseVictim", iVictim + TASK_MADNESS_BOMB, _, _, "a", 20);
	}

	remove_entity(ent);
}

public confuseVictim(taskId)
{
	new id;
	id = (taskId > g_MaxUsers) ? (taskId - TASK_MADNESS_BOMB) : taskId;

	if(!g_IsConnected[id])
		return;

	if(random_num(0, 1) == 1)
	{
		g_MadnessBomb_Move[id] = 1;

		client_print(id, print_center, "¡ESTÁS RE DURO!");

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_IN);
		write_byte(random(256));
		write_byte(random(256));
		write_byte(random(256));
		write_byte(random_num(100, 175));
		message_end();

		static Float:vecVelocity[3];

		vecVelocity[0] = random_float(100.0, 250.0);
		vecVelocity[1] = random_float(100.0, 250.0);
		vecVelocity[2] = random_float(100.0, 250.0);

		entity_set_vector(id, EV_VEC_punchangle, vecVelocity);
		entity_get_vector(id, EV_VEC_velocity, vecVelocity);

		vecVelocity[0] /= 3.0;
		vecVelocity[1] /= 2.0;

		entity_set_vector(id, EV_VEC_velocity, vecVelocity);
	}

	++g_MadnessBomb_Count[id];

	if(g_MadnessBomb_Count[id] == 20)
	{
		g_MadnessBomb_Count[id] = 0;
		g_MadnessBomb_Move[id] = 0;
	}
}

public native__GetUserAmmoPacks(const id) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return -1;
	}

	return g_AmmoPacks[id];
}

public native__SetUserAmmoPacks(const id, const value) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return;
	}

	g_AmmoPacks[id] += value;
}

public native__GetUserZombie(const id) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return -1;
	}

	return g_Zombie[id];
}

public native__GetUserSpecialMode(const id) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return -1;
	}

	return g_SpecialMode[id];
}

public native__GetUserZombieClass(const id) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return -1;
	}

	return g_ZombieClass[id];
}

public native__GetZombieMaxHealth(const id) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return -1;
	}

	return g_MaxHealth[id];
}

public native__GetZombieFrozen(const id) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return -1;
	}

	return g_Frozen[id];
}

public native__HasPipeBomb(const id) {
	if(!isUserValid(id)) {
		log_error(AMX_ERR_NATIVE, "Usuario no valido (%d)", id);
		return -1;
	}

	return g_PipeBomb[id];
}

public native__HasRoundStarted() {
	if(g_NewRound) {
		return 0;
	} else if(g_Mode) { // Si es mayor a 1 es por que un modo se está ejecutando
		return 1;
	}

	return 2;
}

public native__GetMode() {
	return g_Mode;
}

stock setUserTeamForce(const id, const team[])
{
	g_AllowChangeTeam[id] = 1;

	set_pdata_int(id, OFFSET_BLOCKTEAM, (get_pdata_int(id, OFFSET_BLOCKTEAM, OFFSET_LINUX) & ~(1<<8)), OFFSET_LINUX);

	static iRestore;

	if((iRestore = get_pdata_int(id, OFFSET_VGUI)) & 1<<0)
		set_pdata_int(id, OFFSET_VGUI, iRestore & ~(1<<0));

	set_msg_block(g_Message_ShowMenu, BLOCK_SET);
	set_msg_block(g_Message_VGUIMenu, BLOCK_SET);

	engclient_cmd(id, "jointeam", team);
	if(team[0] != '6')
		engclient_cmd(id, "joinclass", "1");

	set_msg_block(g_Message_ShowMenu, BLOCK_NOT);
	set_msg_block(g_Message_VGUIMenu, BLOCK_NOT);

	if(iRestore & (1<<0))
		set_pdata_int(id, OFFSET_VGUI, iRestore);

	g_AllowChangeTeam[id] = 0;
}

new Float:g_SysTime_HumanMedico[33];
public clcmd__Radio1(const id)
{
	if(g_AccountJoined[id] < 2)
		return PLUGIN_HANDLED;

	if(g_HumanClass[id] == HUMAN_MEDICO)
	{
		if(g_SysTime_HumanMedico[id] > get_gametime())
			return PLUGIN_HANDLED;

		new Float:vecOrigin[3];
		entity_get_vector(id, EV_VEC_origin, vecOrigin);

		new iVictim = -1;
		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 75.0)) != 0)
		{
			if(!is_user_alive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim])
				continue;

			set_user_health(iVictim, get_user_health(iVictim) + 50);
			client_print(iVictim, print_center, "Un humano con clase médico te curó con +50 de HP");
		}

		g_SysTime_HumanMedico[id] = get_gametime() + 40.0;
	}

	return PLUGIN_HANDLED;
}

public showMenu__ChooseWhatSongsToHear(const id) {
	static sMenu[400];
	static iLen;

	iLen = 0;

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yELEGIR QUE CANCIONES ESCUCHAR^n^n");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.%s JERUZALEM SE INFECTOOOO^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_MULTI) != AMBIENCE_MUTED_MULTI) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.%s MASACRE EN JERUZALEM^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_SWARM) != AMBIENCE_MUTED_SWARM) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r3.%s INFECCION MULTIPLE EN JERUZALEM^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_MULTI_ORIGINAL) != AMBIENCE_MUTED_MULTI_ORIGINAL) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r4.%s LA PLAGA LLEGO A JERUZALEMMM^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_PLAGUE) != AMBIENCE_MUTED_PLAGUE) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r5.%s ARMAGEDDON^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_ARMAGEDDON) != AMBIENCE_MUTED_ARMAGEDDON) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r6.%s SURVIVOR^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_SURVIVOR) != AMBIENCE_MUTED_SURVIVOR) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r7.%s NEMESIS^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_NEMESIS) != AMBIENCE_MUTED_NEMESIS) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r8.%s NEMESIS EXTREMO^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_NEMESIS_EXTREME) != AMBIENCE_MUTED_NEMESIS_EXTREME) ? "\w" : "\d");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r9.%s JERUZALEM^n^n", ((g_AmbienceSound_Muted[id] & AMBIENCE_MUTED_JERUZALEM) != AMBIENCE_MUTED_JERUZALEM) ? "\w" : "\d");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r0.\w VOLVER");

	show_menu(id, KEYSMENU, sMenu, -1, "ChooseWhatMusicToHear");
}

public menu__ChooseWhatMusicToHear(const id, const key) {
	if(key == 9) {
		showMenu__Config(id);
		return PLUGIN_HANDLED;
	}

	if((g_AmbienceSound_Muted[id] & (1 << (key))) != (1 << (key))) {
		g_AmbienceSound_Muted[id] |= (1 << (key));
	} else {
		g_AmbienceSound_Muted[id] &= ~(1 << (key));
	}

	showMenu__ChooseWhatSongsToHear(id);
	return PLUGIN_HANDLED;
}

public message__CurWeapon(const msg_id, const msg_dest, const msg_entity) {
	if(g_IsAlive[msg_entity] && g_UnlimitedClip[msg_entity]) {
		if(get_msg_arg_int(1) != 1) {
			return;
		}

		static iWeapon;
		iWeapon = get_msg_arg_int(2);

		if(MAX_BPAMMO[iWeapon] > 2) {
			static iWeaponEnt;
			iWeaponEnt = getCurrentWeaponEnt(msg_entity);

			if(pev_valid(iWeaponEnt)) {
				cs_set_weapon_ammo(iWeaponEnt, 30);
			}

			set_msg_arg_int(3, get_msg_argtype(3), 30);
		}
	}
}

public checkAchievementOfSupplyBoxes(const id) {
	switch(g_Stats_General[id][STATS_SUPPLY_BOX_COLLECTED]) {
		case 1: {
			setAchievement(id, SUPPLY_BOX_X1);
		} case 10: {
			setAchievement(id, SUPPLY_BOX_X10);
		} case 50: {
			setAchievement(id, SUPPLY_BOX_X50);
		} case 100: {
			setAchievement(id, SUPPLY_BOX_X100);
		} case 500: {
			setAchievement(id, SUPPLY_BOX_X500);
		} case 1000: {
			setAchievement(id, SUPPLY_BOX_X1000);
			setAchievementFirst(id, FIRST_SUPPLY_BOX_X1000);
		}
	}

	switch(g_SBox_CollectedInSameRound[id]) {
		case 2: {
			setAchievement(id, SUPPLY_BOX_X2_SAME_ROUND);
		} case 3: {
			setAchievement(id, SUPPLY_BOX_X3_SAME_ROUND);
		} case 4: {
			setAchievement(id, SUPPLY_BOX_X4_SAME_ROUND);
		} case 5: {
			setAchievement(id, SUPPLY_BOX_X5_SAME_ROUND);
			setAchievementFirst(id, FIRST_SUPPLY_BOX_X5_SAME_ROUND);
		}
	}
}

public setSupplyBoxRandomReward() {
	new iListRandomRewards[6] = {0, 1, 2, 3, 4, 5};
	new iTempReward1;
	new iRandomNumber1;
	new iRandomNumber2;
	new i;

	g_SupplyboxNums = 0;

	for(i = 0; i < 20; ++i) {
		iRandomNumber1 = random_num(0, 5);
		iRandomNumber2 = random_num(0, 5);

		iTempReward1 = iListRandomRewards[iRandomNumber1];

		iListRandomRewards[iRandomNumber1] = iListRandomRewards[iRandomNumber2];
		iListRandomRewards[iRandomNumber2] = iTempReward1;
	}

	for(i = 0; i < g_DB_SupplyBox; ++i) {
		loadSupplybox(g_DB_SupplyBox_Position[i], g_DB_SupplyBox_Angles[i], iListRandomRewards[i]);
	}
}

public clcmd__SecretAchievement(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	static TeamName:iTeam;
	iTeam = getUserTeam(id);

	if(iTeam == TEAM_TERRORIST || iTeam == TEAM_CT) {
		static sMessage[32];
		read_args(sMessage, charsmax(sMessage));

		remove_quotes(sMessage);
		trim(sMessage);
		strtolower(sMessage);

		static i;
		for(i = 0; i < MAX_SECRET_ACHIEVEMENTS_SAY; ++i) {
			if(equal(sMessage, SECRET_ACHIEVEMENTS_SAY[i][secretAchievementSay])) {
				setAchievement(id, SECRET_ACHIEVEMENTS_SAY[i][secretAchievementId]);
				return PLUGIN_HANDLED;
			}
		}
	}

	return PLUGIN_HANDLED;
}

modeJeruzalemFinish(const TeamName:winnerTeam, userDisconnectedId=0) {
	if(g_ModeJeruzalem_AlreadyRewarded) {
		return;
	}

	g_ModeJeruzalem_AlreadyRewarded = true;

	new i;

	if(winnerTeam == TEAM_TERRORIST) {
		killUsersAlive(0, userDisconnectedId);

		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			if(!g_Zombie[i]) {
				continue;
			}

			g_Points[i] += 20;
			setAchievement(i, MODE_JERUZALEM_WIN_AS_ZOMBIE);
		}

		dg_color_chat(0, _, "Todos los !tzombies vivos!y ganaron !g+20 pU!y");
	} else {
		killUsersAlive(1, userDisconnectedId);

		new iRewardPoints = g_VIPsDead * 10;

		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			if(g_Zombie[i]) {
				continue;
			}

			g_Points[i] += iRewardPoints;
			setAchievement(i, MODE_JERUZALEM_2VIPS_ESCAPE);
		}

		dg_color_chat(0, _, "Todos los !thumanos vivos!y ganaron !g+%d pU!y", iRewardPoints);
	}
}

public killUsersAlive(const killTeam, const userDisconnectedId) {
	new i;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		if(i == userDisconnectedId) {
			continue;
		}

		giveExperience(i, g_ModeJeruzalem_RewardExp[i]);
		dg_color_chat(i, _, "Ganaste !g+%d!y de experiencia", g_ModeJeruzalem_RewardExp[i]);

		g_ModeJeruzalem_RewardExp[i] = -5;

		if(!is_user_alive(i)) {
			continue;
		}

		if(g_Zombie[i] == killTeam) {
			user_kill(i, 1);
		}
	}
}

public checkAutoModeJeruzalem() {
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new argTime = get_systime() - 10800;
	new i21Hour;
	new iDifference;

	unix_to_time(argTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	i21Hour = time_to_unix(iYear, iMonth, iDay, 21, 00, 00);

	iDifference = i21Hour - argTime;

	if(iDifference >= -3600 && iDifference <= 3600) {
		set_task(600.0, "task__AutoMode_Jeruzalem");
		loadAutoModes();
	}
}

public task__AutoMode_Jeruzalem() {
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new argTime = get_systime() - 10800;
	new i21Hour;
	new iDifference;

	unix_to_time(argTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	i21Hour = time_to_unix(iYear, iMonth, iDay, 21, 00, 00);

	iDifference = i21Hour - argTime;

	if(iDifference < 0) {
		return;
	}

	new iMins = iDifference / 60;

	dg_color_chat(0, _, "En !g%d minutos!y aproximadamente saldrá el modo !gJeruzalem!y", iMins+5);

	set_task(600.0, "task__AutoMode_Jeruzalem");
}

public loadAutoModes() {
	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT automode_jeruzalem_rounds, automode_jeruzalem_count FROM ze1_general WHERE id=1;");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadAutoModes", g_SQLQuery);
}

public sqlThread__LoadAutoModes(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime) {
	if(failstate != TQUERY_SUCCESS)	{
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadAutoModes - %d - %s", errorNum, error);
		return;
	}

	if(!SQL_NumResults(query)) {
		return;
	}

	g_AutoMode_Jeruzalem_RoundsLeft = SQL_ReadResult(query, 0);
	g_AutoMode_Jeruzalem_Count = SQL_ReadResult(query, 1);

	if(g_AutoMode_Jeruzalem_Count < 2) {
		if(g_AutoMode_Jeruzalem_RoundsLeft < 1) {
			g_AutoMode_Jeruzalem_RoundsLeft = random_num(4, 6);
		}
	}
}

public checkAutoMode_Jeruzalem() {
	if(g_AutoMode_Jeruzalem_Count >= 2) {
		g_AutoMode_Jeruzalem_Enabled = false;
		return;
	}

	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new argTime = get_systime() - 10800;
	new i21Hour;

	unix_to_time(argTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	i21Hour = time_to_unix(iYear, iMonth, iDay, 21, 00, 00);

	if(argTime >= i21Hour) {
		g_AutoMode_Jeruzalem_Enabled = true;

		if(g_AutoMode_Jeruzalem_RoundsLeft) {
			dg_color_chat(0, _, "En !g%d ronda%s!y comenzará el modo !gJeruzalem!y", g_AutoMode_Jeruzalem_RoundsLeft, (g_AutoMode_Jeruzalem_RoundsLeft != 1) ? "s" : "");
		} else {
			dg_color_chat(0, _, "En !gla siguiente ronda!y comenzará otro modo !gJeruzalem!y");
		}
	}
}

public sqlThread__SaveAndIgnore(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime) {
	switch(failstate) {
		case TQUERY_CONNECT_FAILED: {
			log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__SaveAndIgnore - %d - %s", errorNum, error);
			return;
		} case TQUERY_QUERY_FAILED: {
			log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__SaveAndIgnore - %d - %s", errorNum, error);
		}
	}
}

public clcmd__Test(const id) {
	if(!checkScripterAccess(id)) {
		return;
	}
}

public checkCrazyMode() {
	formatex(g_SQLQuery, charsmax(g_SQLQuery), "SELECT crazy_mode, next_crazy_mode FROM ze1_general WHERE id=1;");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadCrazyMode", g_SQLQuery);
}

public sqlThread__LoadCrazyMode(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime) {
    if(failstate != TQUERY_SUCCESS) {
        log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadCrazyMode - %d - %s", errorNum, error);
        return;
    }

    if(!SQL_NumResults(query)) {
        return;
    }

    g_Secret_CrazyMode_Enabled = SQL_ReadResult(query, 0);
    g_Secret_NextCrazyMode = SQL_ReadResult(query, 1);
}

public activateCrazyMode() {
	if(!g_Secret_CrazyMode_Enabled) {
		return;
	}

	g_Secret_CrazyMode_Enabled = false;
	g_Secret_CrazyMode = true;

	new sQuery[64];
	formatex(sQuery, 63, "UPDATE ze1_general SET crazy_mode='0' WHERE id=1;");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__SaveAndIgnore", sQuery);

	set_dhudmessage(random_num(75, 255), random_num(75, 255), random_num(75, 255), -1.0, 0.4, 1, 0.0, 5.0, 5.0, 5.0);
	show_dhudmessage(0, "¡CRAZY MODE!");

	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!g_IsConnected[i]) {
			continue;
		}

		setAchievement(i, SECRET_CRAZY_MODE);
	}

	set_cvar_num("sv_airaccelerate", -100);

	set_task(3.0, "task__CrazyMode");
}

public task__CrazyMode() {
	if(!g_Secret_CrazyMode) {
		return;
	}

	new iUsersAlive = getAlives();
	new iUsers = iUsersAlive / 4;
	new iAffected = 0;
	new iRandomUser;
	new Float:vecOrigin[3];

	while(iAffected < iUsers) {
		++iAffected;
		iRandomUser = getRandomAlive(random_num(1, iUsersAlive));

		entity_get_vector(iRandomUser, EV_VEC_origin, vecOrigin);

		xs_vec_sub(vecOrigin, vecOrigin, vecOrigin);
		xs_vec_normalize(vecOrigin, vecOrigin);
		xs_vec_mul_scalar(vecOrigin, random_float(-250.0, 250.0) * random_float(-50.0, 50.0), vecOrigin);

		entity_set_vector(iRandomUser, EV_VEC_velocity, vecOrigin);
	}

	set_task(3.0, "task__CrazyMode");
}

public clcmd__Radio2(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_AchievementLink_Id != -1) {
		g_MenuData[id][DATA_ACH_CLASSES] = g_AchievementLink_Class;
		g_MenuPage_Achievements[id][g_MenuData[id][DATA_ACH_CLASSES]] = g_AchievementLink_MenuPage;

		showMenu__AchievementsInfo(id, g_AchievementLink_Id);
	}

	return PLUGIN_HANDLED;
}

public clcmd__EscapeButton(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(g_Account_Id[id] != 14131) {
		return PLUGIN_HANDLED;
	}

	new sButtonId[32];
	read_argv(1, sButtonId, 31);

	if(!sButtonId[0]) {
		return PLUGIN_HANDLED;
	}

	if(g_EscapeButtonId != -1) {
		client_print(id, print_console, "Este mapa ya tiene un botón de escape asignado!");
		return PLUGIN_HANDLED;
	}

	new iButtonId = str_to_num(sButtonId);
	new sQuery[128];

	formatex(sQuery, 127, "INSERT INTO ze1_escape_buttons (mapname,button_id) VALUES (^"%s^",'%d');", g_MapName, iButtonId);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__InsertMessage", sQuery);

	client_print(id, print_console, "Botón guardado exitosamente!");

	return PLUGIN_HANDLED;
}

public sqlThread__LoadEscapeButton(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime) {
	if(failstate != TQUERY_SUCCESS) {
		log_to_file(LOGFILE_SQL_ERRORS, "sqlThread__LoadEscapeButton - %d - %s", errorNum, error);
		return;
	}

	if(!SQL_NumResults(query)) {
		return;
	}

	g_EscapeButtonId = SQL_ReadResult(query, 0);
}

public updateRewardsByFlags(const id)
{
	new iFlags = get_user_flags(id);

	if(iFlags & ADMIN_LEVEL_A)
	{
		g_RewardAmmoPacksKill[id] = HAPPY_HOUR[g_HappyHour][hhAPsKillReward_Admin];
		g_RewardAmmoPacksDamage[id] = HAPPY_HOUR[g_HappyHour][hhAPsDamageReward_Admin];
		g_RewardAmmoPacksInfect[id] = HAPPY_HOUR[g_HappyHour][hhAPsInfectionReward_Admin];
	}
	else if(iFlags & ADMIN_RESERVATION)
	{
		g_RewardAmmoPacksKill[id] = HAPPY_HOUR[g_HappyHour][hhAPsKillReward_Vip];
		g_RewardAmmoPacksDamage[id] = HAPPY_HOUR[g_HappyHour][hhAPsDamageReward_Vip];
		g_RewardAmmoPacksInfect[id] = HAPPY_HOUR[g_HappyHour][hhAPsInfectionReward_Vip];
	}
	else
	{
		g_RewardAmmoPacksKill[id] = HAPPY_HOUR[g_HappyHour][hhAPsKillReward_Normal];
		g_RewardAmmoPacksDamage[id] = HAPPY_HOUR[g_HappyHour][hhAPsDamageReward_Normal];
		g_RewardAmmoPacksInfect[id] = HAPPY_HOUR[g_HappyHour][hhAPsInfectionReward_Normal];
	}
}

public fw_AddToFullPack_Post(const es, const e, const ent, const host, const host_flags, const player, const player_set) {
	if(g_Mode == MODE_JERUZALEM) {
		return FMRES_IGNORED;
	}

	if(player && g_IsAlive[host] && g_IsAlive[ent] && !g_Zombie[host] && !g_Zombie[ent]) {
		set_es(es, ES_Solid, SOLID_NOT);

		if(g_Invis[host]) {
			set_es(es, ES_RenderMode, kRenderTransTexture);
			set_es(es, ES_RenderAmt, 0);
		}
	} else if(pev_valid(ent) && g_IsAlive[host] && g_Invis[host] && !g_Zombie[host]) {
		static iOwner;
		iOwner = entity_get_edict(ent, EV_ENT_owner);

		if(!isUserValidConnected(iOwner)) {
			return FMRES_IGNORED;
		}

		if(g_Zombie[iOwner]) {
			return FMRES_IGNORED;
		}

		if(entity_get_int(ent, EV_INT_iuser3) == 1337) { // Hat
			set_es(es, ES_RenderMode, kRenderTransTexture);
			set_es(es, ES_RenderAmt, 0);
		}
	}

	return FMRES_IGNORED;
}

public setUserNightvision(const taskId) {
	static vecOrigin[3];
	get_user_origin(ID_NVISION, vecOrigin);

	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NVISION);
	write_byte(TE_DLIGHT);
	write_coord(vecOrigin[0]);
	write_coord(vecOrigin[1]);
	write_coord(vecOrigin[2]);
	write_byte(70);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(7);
	write_byte(7);
	message_end();
}

public clcmd__Crazy(const id) {
	if(!g_Secret_CrazyMode_Enabled) {
		new argTime = get_systime() - 10800;
		new iDifference = g_Secret_NextCrazyMode - argTime;

		if(iDifference <= 0) {
			dg_color_chat(id, _, "El crazy mode está disponible para ser activado pero debes esperar al próximo mapa");
		} else {
			new iDays = 0;
			new iHours = 0;
			new iMinutes = iDifference / 60;

			while(iMinutes >= 60) {
				++iHours;

				if(iHours == 24) {
					++iDays;
					iHours = 0;
				}

				iMinutes -= 60;
			}

			dg_color_chat(id, _, "Faltan !g%d día%s!y, !g%d hora%s!y y !g%d minuto%s!y para que se active el crazy mode", iDays, (iDays != 1) ? "s" : "", iHours, (iHours != 1) ? "s" : "", iMinutes, (iMinutes != 1) ? "s" : "");
		}
	} else {
		dg_color_chat(id, _, "El crazy mode está disponible para ser activado");
	}

	return PLUGIN_HANDLED;
}

public showMenu__UpgradesPreview(const id) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return;
	}

	static sMenu[350];
	static iLen;

	switch(g_MenuData[id][DATA_UPGRADES]) {
		case 0: {
			iLen = formatex(sMenu, charsmax(sMenu), "\y%s^n", UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);
		} case 1: {
			iLen = formatex(sMenu, charsmax(sMenu), "\y%s^n", UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);
		} case 2: {
			iLen = formatex(sMenu, charsmax(sMenu), "\y%s^n", UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);
		}
	}

	static sPoints[8];
	static iCost;
	static sCost[8];

	addDot(g_Points[id], sPoints, charsmax(sPoints));
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wPuntos de Poder\r:\y %s^n^n", sPoints);

	switch(g_MenuData[id][DATA_UPGRADES]) {
		case 0: {
			if(g_UpgradesSkin[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]]) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Equipar^n");
			} else if(UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\d Comprar \r[VIP]^n");
			} else if(UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeAppMobile] && !g_VincAppMobile[id]) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\d Comprar \r[APP MOBILE]^n");
			} else {
				iCost = UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost];
				addDot(iCost, sCost, charsmax(sCost));

				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\%s Comprar \%s[%s pU]^n", (g_Points[id] >= iCost) ? "w" : "d", (g_Points[id] >= iCost) ? "y" : "r", sCost);
			}
		} case 1: {
			if(g_UpgradesHat[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]]) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Equipar^n");
			} else if(UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\d Comprar \r[VIP]^n");
			} else if(UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeAppMobile] && !g_VincAppMobile[id]) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\d Comprar \r[APP MOBILE]^n");
			} else {
				iCost = UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost];
				addDot(iCost, sCost, charsmax(sCost));

				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\%s Comprar \%s[%s pU]^n", (g_Points[id] >= iCost) ? "w" : "d", (g_Points[id] >= iCost) ? "y" : "r", sCost);
			}
		} case 2: {
			if(g_UpgradesKnife[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]]) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Equipar^n");
			} else if(UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\d Comprar \r[VIP]^n");
			} else if(UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeAppMobile] && !g_VincAppMobile[id]) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\d Comprar \r[APP MOBILE]^n");
			} else {
				if(g_Stats_General[id][STATS_ESCAPE_D] < UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost]) {
					iCost = UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost];
					addDot(iCost, sCost, charsmax(sCost));

					iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\d Bloqueado \r[%s ESCAPES]^n", sCost); // No se compran, se desbloquean
				} else {
					iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w Equipar^n"); // No se compran, se desbloquean
				}
			}
		}
	}

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.\w Previsualizar");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n^n\r0.\w Volver");

	if(pev_valid(id) == PDATA_SAFE) {
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	}

	show_menu(id, KEYSMENU, sMenu, -1, "Upgrades Preview Menu");
}

public menu__Upgrades_Preview(const id, const key) {
	if(!g_IsConnected[id] || !g_Account_Logged[id]) {
		return PLUGIN_HANDLED;
	}

	switch(key) {
		case 0: { // COMPRAR / EQUIPAR
			switch(g_MenuData[id][DATA_UPGRADES]) {
				case 0: {
					if(!UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost]) {
						if(UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
							dg_color_chat(id, _, "Esta mejora sólo está disponible para usuarios vip");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						} else if(UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeAppMobile] && !g_VincAppMobile[id]) {
							dg_color_chat(id, _, "Este personaje sólo está disponible para usuarios que vincularon su cuenta con la aplicación mobile");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						}
					}

					if(g_UpgradesSkin[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]]) {
						if(g_UpgradeSelect[id][0] == g_MenuData[id][DATA_UPGRADE_ITEM_ID]) {
							dg_color_chat(id, _, "Ya has elegido este personaje");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						}

						g_UpgradeSelect[id][0] = g_MenuData[id][DATA_UPGRADE_ITEM_ID];
						dg_color_chat(id, _, "Has elegido el personaje !t%s!y. En tu próximo respawn se te otorgará", UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);

						showMenu__UpgradesPreview(id);
						return PLUGIN_HANDLED;
					} else if(g_Points[id] < UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost]) {
						showMenu__UpgradesPreview(id);
						return PLUGIN_HANDLED;
					}

					g_Points[id] -= UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost];
					g_PointsLose[id] += UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost];

					g_UpgradesSkin[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]] = 1;
					dg_color_chat(id, _, "Has comprado el personaje !t%s!y", UPGRADES_SKIN[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);
				} case 1: {
					if(!UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost]) {
						if(UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
							dg_color_chat(id, _, "Este gorro sólo está disponible para usuarios vip");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						} else if(UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeAppMobile] && !g_VincAppMobile[id]) {
							dg_color_chat(id, _, "Este gorro sólo está disponible para usuarios que vincularon su cuenta con la aplicación mobile");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						}
					}

					if(g_UpgradesHat[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]]) {
						if(g_UpgradeSelect[id][1] == g_MenuData[id][DATA_UPGRADE_ITEM_ID]) {
							dg_color_chat(id, _, "Ya has elegido este gorro");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						}

						g_UpgradeSelect[id][1] = g_MenuData[id][DATA_UPGRADE_ITEM_ID];
						dg_color_chat(id, _, "Has elegido el gorro !t%s!y. En tu próximo respawn se te otorgará", UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);

						if(g_NewRound) {
							setHat(id, g_MenuData[id][DATA_UPGRADE_ITEM_ID]);
						} else {
							g_HatNext[id] = g_MenuData[id][DATA_UPGRADE_ITEM_ID];
							dg_color_chat(id, _, "En tu próximo respawn, se te otorgará el gorro correspondiente");
						}

						showMenu__UpgradesPreview(id);
						return PLUGIN_HANDLED;
					} else if(g_Points[id] < UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost]) {
						showMenu__UpgradesPreview(id);
						return PLUGIN_HANDLED;
					}

					g_Points[id] -= UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost];
					g_PointsLose[id] += UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost];

					g_UpgradesHat[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]] = 1;
					dg_color_chat(id, _, "Has comprado el gorro !t%s!y", UPGRADES_HAT[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);
				} case 2: {
					if(!UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost]) {
						if(UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
							dg_color_chat(id, _, "Este cuchillo sólo está disponible para usuarios vip");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						} else if(UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeAppMobile] && !g_VincAppMobile[id]) {
							dg_color_chat(id, _, "Este cuchillo sólo está disponible para usuarios que vincularon su cuenta con la aplicación mobile");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						}
					}

					if(g_Stats_General[id][STATS_ESCAPE_D] < UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeCost]) {
						showMenu__UpgradesPreview(id);
						return PLUGIN_HANDLED;
					} else {
						g_UpgradesKnife[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]] = 1;
					}

					if(g_UpgradesKnife[id][g_MenuData[id][DATA_UPGRADE_ITEM_ID]]) {
						if(g_UpgradeSelect[id][2] == g_MenuData[id][DATA_UPGRADE_ITEM_ID]) {
							dg_color_chat(id, _, "Ya has elegido este cuchillo");

							showMenu__UpgradesPreview(id);
							return PLUGIN_HANDLED;
						}

						g_UpgradeSelect[id][2] = g_MenuData[id][DATA_UPGRADE_ITEM_ID];
						dg_color_chat(id, _, "Has elegido el cuchillo !t%s!y. En tu próximo respawn se te otorgará", UPGRADES_KNIFE[g_MenuData[id][DATA_UPGRADE_ITEM_ID]][upgradeName]);

						showMenu__UpgradesPreview(id);
						return PLUGIN_HANDLED;
					}
				}
			}
		} case 1: { // PREVISUALIZAR
			if(g_MenuData[id][DATA_UPGRADES] == 1 && !g_MenuData[id][DATA_UPGRADE_ITEM_ID]) { // Hat NINGUNO
				showMenu__UpgradesPreview(id);
				return PLUGIN_HANDLED;
			} else if(g_MenuData[id][DATA_UPGRADES] == 0 && !g_MenuData[id][DATA_UPGRADE_ITEM_ID]) { // Skin NINGUNO
				showMenu__UpgradesPreview(id);
				return PLUGIN_HANDLED;
			}

			static iId;
			iId = g_MenuData[id][DATA_UPGRADE_ITEM_ID];

			if(g_MenuData[id][DATA_UPGRADES] == 2) {
				++iId;
			}

			static sBuffer[256];
			formatex(sBuffer, charsmax(sBuffer), "<html><head><style>body {background:#000;color:#FFF;}</style><meta http-equiv=^"Refresh^" content=^"0;url=http://drunk-gaming.com/tops/01_zombie_escape/upg_preview.php?cat=%d&id=%d^"></head><body><p>Cargando . . .</p></body></html>", g_MenuData[id][DATA_UPGRADES], iId);
			show_motd(id, sBuffer, "PREVISUALIZACIÓN");
		} case 9: { // VOLVER
			showMenu__UpgradesIn(id);
			return PLUGIN_HANDLED;
		}
	}

	showMenu__UpgradesPreview(id);
	return PLUGIN_HANDLED;
}

public touch__Tramp(const ent, const id)
{
	if(!is_valid_ent(ent) || !g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id])
		return;

	new iEnt = find_ent_by_class(0, "entZombieHeavyTramp");
	entity_set_int(iEnt, EV_INT_sequence, 1);

	g_ZombieClassHeavy_Trampped[id] = 1;
	g_Speed[id] = 1.0;
	set_user_gravity(id, 999999.9);

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	remove_task(id + TASK_ZHEAVY_REMOVE_TRAMP);
	set_task(5.0, "task__ZombieHeavyRemoveTramp", id + TASK_ZHEAVY_REMOVE_TRAMP);
}

public task__ZombieHeavyRemoveTramp(task_id)
{
	new iId = (task_id - TASK_ZHEAVY_REMOVE_TRAMP);

	if(!g_IsAlive[iId] || g_Zombie[iId] || g_SpecialMode[iId])
	{
		remove_task(task_id);
		return;
	}

	g_ZombieClassHeavy_Trampped[iId] = 0;
	g_Speed[iId] = Float:zombieSpeed(iId, g_ZombieClass[iId]);
	set_user_gravity(iId, Float:zombieGravity(iId, g_ZombieClass[iId]));
	--g_ZombieClassHeavy_TrampCount;

	ExecuteHamB(Ham_Player_ResetMaxSpeed, iId);

	removeTramp();
}

public think__Banchee(const ent)
{
	if(!is_valid_ent(ent))
		return;

	static iOwner;
	iOwner = entity_get_edict(ent, EV_ENT_owner);

	startBanchee(ent, iOwner);
}

startBanchee(const ent, const owner=0)
{
	if(!is_valid_ent(ent))
		return;

	static Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_ZombieClassBanchee_Sprite);
	write_byte(40);
	write_byte(30);
	write_byte(14);
	message_end();

	emit_sound(ent, CHAN_WEAPON, SOUND_BANCHEE_MISS, 1.0, ATTN_NORM, 0, PITCH_NORM);

	g_Speed[owner] = Float:zombieSpeed(owner, g_ZombieClass[owner]);
	ExecuteHamB(Ham_Player_ResetMaxSpeed, owner);

	remove_entity(ent);
}

public touch__Banchee(const ent, const id)
{
	if(!pev_valid(ent))
		return;

	static iOwner;
	iOwner = entity_get_edict(ent, EV_ENT_owner);

	if(!pev_valid(id))
	{
		startBanchee(ent, iOwner);
		return;
	}

	if(isUserValidAlive(id) && !g_Zombie[id] && !g_SpecialMode[id] && id != iOwner)
	{
		g_Speed[iOwner] = Float:zombieSpeed(iOwner, g_ZombieClass[iOwner]);
		g_ZombieClassBanchee_Enemy[id] = iOwner;

		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 3.0));
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(ent, EV_ENT_aiment, id);

		emit_sound(iOwner, CHAN_VOICE, SOUND_BANCHEE_HIT, 1.0, ATTN_NORM, 0, PITCH_NORM);

		ExecuteHamB(Ham_Player_ResetMaxSpeed, iOwner);

		remove_task(id + TASK_ZBANCHEE_REMOVE_STAT);
		set_task(3.0, "task__ZombieBancheeRemoveStat", id + TASK_ZBANCHEE_REMOVE_STAT);

		g_ZombieClassBanchee_Stat[id] = 1;
	}
}

public task__ZombieBancheeRemoveStat(task_id)
{
	new iId = (task_id - TASK_ZBANCHEE_REMOVE_STAT);

	if(!g_IsAlive[iId] || g_Zombie[iId])
	{
		remove_task(task_id);
		return;
	}

	g_ZombieClassBanchee_Enemy[iId] = 0;
	g_ZombieClassBanchee_Stat[iId] = 0;
}