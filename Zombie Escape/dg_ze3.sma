#include <dg>

#include <cstrike>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <sqlx>
#include <fun>
#include <xs>
#include <curl>

native zp_weapon_balrog1(const id);
native zp_weapon_balrog11(const id);
native zp_weapon_plasmagun(const id);
native zp_weapon_skull4(const id);
native zp_weapon_thunderbolt(const id);

#pragma dynamic 131072
#pragma semicolon 1
#pragma tabsize 0

/*

*/

new const __PLUGIN_NAME[] = "Zombie Escape";
new const __PLUGIN_VERSION[] = "v3.7";
new const __PLUGIN_UPDATE[] = "";
new const __PLUGIN_UPDATE_VERSION[] = "";
new const __PLUGIN_AUTHOR[] = "Atsel.";

const MAX_SUPPLYBOX = 6;
const MAX_CLAN_MEMBERS = 8;

const PDATA_SAFE = 2;
const OFFSET_LINUX_WEAPONS = 4;
const OFFSET_LINUX = 5;
const OFFSET_LEAP = 8;
const OFFSET_WEAPONOWNER = 41;
const OFFSET_ACTIVITY = 73;
const OFFSET_SILENT = 74;
const OFFSET_HITZONE = 75;
const OFFSET_PAINSHOCK = 108;
const OFFSET_BUYZONE = 235;
const OFFSET_FLASHLIGHT_BATTERY = 244;
const OFFSET_BUTTON_PRESSED = 246;
const OFFSET_LONG_JUMP = 356;
const OFFSET_ACTIVE_ITEM = 373;
const OFFSET_CSDEATHS = 444;
const OFFSET_TANK = 1408;

const UNIT_SECOND = (1<<12);
const DMG_HEGRENADE = (1<<24);
const IMPULSE_FLASHLIGHT = 100;
const IMPULSE_SPRAY = 201;
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
const ZOMBIE_ALLOWED_WEAPONS_BIT_SUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE);
const WEAPON_NOT_GUNS = ((1<<_:WEAPON_GLOCK)|(1<<_:WEAPON_KNIFE)|(1<<_:WEAPON_C4)|(1<<_:WEAPON_HEGRENADE)|(1<<_:WEAPON_FLASHBANG)|(1<<_:WEAPON_SMOKEGRENADE)|(1<<_:WEAPON_KNIFE));
const WEAPON_PISTOLS = ((1<<_:WEAPON_P228)|(1<<_:WEAPON_ELITE)|(1<<_:WEAPON_FIVESEVEN)|(1<<_:WEAPON_USP)|(1<<_:WEAPON_GLOCK18)|(1<<_:WEAPON_DEAGLE));

const MAX_LEVEL = 500;
const MAX_RANGE = 50;

enum _:structIdTasks (+= 236877) {
	TASK_CHECK_ACCOUNT = 54276,
	TASK_HELLO_AGAIN,
	TASK_TIME_PLAYED,
	TASK_CHECK_ACHIEVEMENTS,
	TASK_MESSAGE_VINC,
	TASK_SAVE,
	TASK_SPAWN,
	TASK_NVISION,
	TASK_BURN_FLAME,
	TASK_FROZEN,
	TASK_IMMUNITY_BOMBS,
	TASK_MADNESS_BOMB,
	TASK_MADNESS,
	TASK_BUTTONED,
	TASK_POWER_ZOMBIE,
	TASK_HUMAN_MEDICO_ACTIVE,
	TASK_ZOMBIE_VOODOO,
	TASK_ZOMBIE_LUSTY_ROSE,
	TASK_ZOMBIE_LUSTY_ROSE_WAIT,
	TASK_ZOMBIE_FARAHON,
	TASK_ZOMBIE_FLESHPOUND,
	TASK_ZOMBIE_FLESHPOUND_ACTIVE,
	TASK_ZOMBIE_FLESHPOUND_AURA,
	TASK_VIRUST,
	TASK_COUNTDOWN,
	TASK_STARTMODE,
	TASK_ZOMBIE_BACK,
	TASK_MODE_ARMAGEDDON_1,
	TASK_MODE_ARMAGEDDON_2,
	TASK_MODE_ARMAGEDDON_3,
	TASK_MODE_ARMAGEDDON_4,
	TASK_AMBIENCESOUNDS,
	TASK_ACHIEVEMENT_VALENTINA_TE_AMO
};

enum _:struckIdNades (+= 1111) {
	NADE_TYPE_INFECTION = 1111,
	NADE_TYPE_FIRE,
	NADE_TYPE_FROST,
	NADE_TYPE_EXPLOSIVE,
	NADE_TYPE_BUBBLE,
	NADE_TYPE_MADNESS
};

enum _:structIdModes {
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE,
	MODE_ARMAGEDDON,
	MODE_SURVIVOR,
	MODE_NEMESIS,
	MODE_NEMESIS_X,
	MODE_JERUZALEM
};

enum _:structIdAmbienceSounds {
	AMBIENCE_SOUNDS_NONE = 0,
	AMBIENCE_SOUNDS_INFECTION,
	AMBIENCE_SOUNDS_SWARM,
	AMBIENCE_SOUNDS_MULTI,
	AMBIENCE_SOUNDS_PLAGUE,
	AMBIENCE_SOUNDS_ARMAGEDDON,
	AMBIENCE_SOUNDS_SURVIVOR,
	AMBIENCE_SOUNDS_NEMESIS,
	AMBIENCE_SOUNDS_NEMESIS_X,
	AMBIENCE_SOUNDS_JERUZALEM
};

enum _:structIdAmbienceMuted {
	AMBIENCE_MUTED_NONE = 0,
	AMBIENCE_MUTED_INFECTION = 1,
	AMBIENCE_MUTED_SWARM = 2,
	AMBIENCE_MUTED_MULTI = 4,
	AMBIENCE_MUTED_PLAGUE = 8,
	AMBIENCE_MUTED_ARMAGEDDON = 16,
	AMBIENCE_MUTED_SURVIVOR = 32,
	AMBIENCE_MUTED_NEMESIS = 64,
	AMBIENCE_MUTED_NEMESIS_X = 128,
	AMBIENCE_MUTED_JERUZALEM = 256
};

enum _:structIdWeapons {
	WEAPON_AUTO_BUY = 0,
	WEAPON_PRIMARY_SELECTION,
	WEAPON_PRIMARY_CURRENT,
	WEAPON_PRIMARY_BOUGHT,
	WEAPON_SECONDARY_SELECTION,
	WEAPON_SECONDARY_CURRENT,
	WEAPON_SECONDARY_BOUGHT
};

enum _:structIdExtraItem {
	EXTRA_ITEM_ANTIDOTE = 0,
	EXTRA_ITEM_MADNESS,
	EXTRA_ITEM_INFECTION_BOMB,
	EXTRA_ITEM_UNLIMITED_CLIP,
	EXTRA_ITEM_BUBBLE_BOMB,
	EXTRA_ITEM_MADNESS_BOMB,
	EXTRA_ITEM_ANTI_FIRE,
	EXTRA_ITEM_ANTI_FROST,
	EXTRA_ITEM_BALROG_I,
	EXTRA_ITEM_BALROG_XI,
	EXTRA_ITEM_PLASMAGUN,
	EXTRA_ITEM_SKULL_IV,
	EXTRA_ITEM_THUNDERBOLT
};

enum _:structIdExtraItemTeam {
	EXTRA_ITEM_TEAM_HUMAN = 0,
	EXTRA_ITEM_TEAM_ZOMBIE
};

enum _:structIdHumanClasses {
	HUMAN_CLASS_CIVIL = 0,
	HUMAN_CLASS_ACTIVO,
	HUMAN_CLASS_LIVIANO,
	HUMAN_CLASS_RECIO,
	HUMAN_CLASS_BLAZE,
	HUMAN_CLASS_NINJA,
	HUMAN_CLASS_SNIPER,
	HUMAN_CLASS_CENTINELA,
	HUMAN_CLASS_SHARAPSHOOTER,
	HUMAN_CLASS_RADIOACTIVO,
	HUMAN_CLASS_MEDICO
};

enum _:structIdZombieClasses {
	ZOMBIE_CLASS_PSYCHO = 0,
	ZOMBIE_CLASS_VOODOO,
	ZOMBIE_CLASS_LUSTY_ROSE,
	ZOMBIE_CLASS_BANSHEE,
	ZOMBIE_CLASS_FARAHON,
	ZOMBIE_CLASS_FLESHPOUND,
	ZOMBIE_CLASS_TOXICO
};

enum _:structIdSurvivorClasses {
	SURVIVOR_CLASS_COMUN = 0,
	SURVIVOR_CLASS_LIGERO,
	SURVIVOR_CLASS_RAPIDO,
	SURVIVOR_CLASS_MEJORADO
};

enum _:structIdNemesisClasses {
	NEMESIS_CLASS_COMUN = 0,
	NEMESIS_CLASS_LIGERO,
	NEMESIS_CLASS_RAPIDO,
	NEMESIS_CLASS_MEJORADO
};

enum _:structIdAchievements {
	CUENTA_PAR = 0,
	CUENTA_IMPAR,
	SOY_DORADO,
	VINCULADO_WEB,
	VINCULADO_MOBILE,
	x25_ZOMBIES,
	x50_ZOMBIES,
	x100_ZOMBIES,
	x250_ZOMBIES,
	x500_ZOMBIES,
	x750_ZOMBIES,
	x1000_ZOMBIES,
	x2500_ZOMBIES,
	x5000_ZOMBIES,
	x7500_ZOMBIES,
	x10000_ZOMBIES,
	x15000_ZOMBIES,
	x20000_ZOMBIES,
	x25000_ZOMBIES,
	x35000_ZOMBIES,
	x45000_ZOMBIES,
	x55000_ZOMBIES,
	x75000_ZOMBIES,
	x25_INFECTIONS,
	x50_INFECTIONS,
	x100_INFECTIONS,
	x250_INFECTIONS,
	x500_INFECTIONS,
	x750_INFECTIONS,
	x1000_INFECTIONS,
	x2500_INFECTIONS,
	x5000_INFECTIONS,
	x7500_INFECTIONS,
	x10000_INFECTIONS,
	x15000_INFECTIONS,
	x20000_INFECTIONS,
	x25000_INFECTIONS,
	x35000_INFECTIONS,
	x45000_INFECTIONS,
	x55000_INFECTIONS,
	x75000_INFECTIONS,
	x25_ESCAPES,
	x50_ESCAPES,
	x100_ESCAPES,
	x250_ESCAPES,
	x500_ESCAPES,
	x750_ESCAPES,
	x1000_ESCAPES,
	x2500_ESCAPES,
	x5000_ESCAPES,
	x7500_ESCAPES,
	x10000_ESCAPES,
	x15000_ESCAPES,
	x20000_ESCAPES,
	x25000_ESCAPES,
	x35000_ESCAPES,
	x45000_ESCAPES,
	x55000_ESCAPES,
	x75000_ESCAPES,
	PRIMERO_x1000_ESCAPES,
	PRIMERO_x25000_ESCAPES,
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
	MODE_JERUZALEM_2VIPS_ESCAPE,
	MODE_JERUZALEM_KILL_1VIP,
	MODE_JERUZALEM_KILL_2VIP,
	MODE_JERUZALEM_WIN_AS_ZOMBIE,
	VENGAN_LOS_ESPERO,
	SOLO_WIN,
	SECRET_CRAZY_MODE,
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
	VALENTINA_TE_AMO,
	x100000_ZOMBIES,
	x125000_ZOMBIES,
	x150000_ZOMBIES,
	x175000_ZOMBIES,
	x200000_ZOMBIES,
	x225000_ZOMBIES,
	x250000_ZOMBIES,
	x100000_INFECTIONS,
	x125000_INFECTIONS,
	x150000_INFECTIONS,
	x175000_INFECTIONS,
	x200000_INFECTIONS,
	x225000_INFECTIONS,
	x250000_INFECTIONS,
	x85000_ESCAPES,
	x100000_ESCAPES,
	SUPPLY_BOX_X1500,
	SUPPLY_BOX_X2000,
	SUPPLY_BOX_X2500,
	SUPPLY_BOX_X3000,
	SUPPLY_BOX_X3500,
	SUPPLY_BOX_X4000,
	SUPPLY_BOX_X4500,
	SUPPLY_BOX_X5000,
	SUPPLY_BOX_X6000,
	SUPPLY_BOX_X7000,
	SUPPLY_BOX_X8000,
	SUPPLY_BOX_X9000,
	SUPPLY_BOX_X10000
};

enum _:structIdAchievementsClass {
	ACHIEVEMENT_CLASS_GENERAL = 0,
	ACHIEVEMENT_CLASS_HUMAN,
	ACHIEVEMENT_CLASS_ZOMBIE,
	ACHIEVEMENT_CLASS_MODE,
	ACHIEVEMENT_CLASS_FIRST,
	ACHIEVEMENT_CLASS_SECRET
};

enum _:structIdColorTypes {
	COLOR_TYPE_HUD_GENERAL = 0,
	COLOR_TYPE_GLOW_GROUP
};

enum _:structIdHudTypes {
	HUD_TYPE_GENERAL = 0
};

enum _:structIdStats {
	STAT_HK_DONE = 0,
	STAT_HK_TAKE,
	STAT_ZK_DONE,
	STAT_ZK_TAKE,
	STAT_I_DONE,
	STAT_I_TAKE,
	STAT_SURVIVOR_DONE,
	STAT_NEMESIS_DONE,
	STAT_ZK_HS_DONE,
	STAT_ZK_HS_TAKE,
	STAT_ZK_KNIFE_DONE,
	STAT_ZK_KNIFE_TAKE,
	STAT_ARMOR_DONE,
	STAT_ARMOR_TAKE,
	STAT_ESCAPES_DONE,
	STAT_ACHIEVEMENTS_DONE,
	STAT_SUPPLYBOX_DONE
};

enum _:structIdTimePlayed {
	TIME_PLAYED_MIN = 0,
	TIME_PLAYED_HOUR,
	TIME_PLAYED_DAY
};

enum _:structIdMenuPages {
    MENU_PAGE_WPN_P = 0,
    MENU_PAGE_WPN_S,
    MENU_PAGE_WPN_G,
    MENU_PAGE_HUMAN_CLASSES,
    MENU_PAGE_ZOMBIE_CLASSES,
    MENU_PAGE_SURVIVOR_CLASSES,
    MENU_PAGE_NEMESIS_CLASSES,
    MENU_PAGE_SKINS,
	MENU_PAGE_KNIFES,
	MENU_PAGE_HATS,
    MENU_PAGE_SHC,
    MENU_PAGE_SZC,
    MENU_PAGE_GROUP_INVITE,
    MENU_PAGE_CLAN_INVITE,
	MENU_PAGE_ACHIEVEMENTS_CLASS,
	MENU_PAGE_ACHIEVEMENTS[structIdAchievementsClass],
	MENU_PAGE_COLOR_CHOOSEN,
    MENU_PAGE_STATS_LEVELS,
    MENU_PAGE_STATS_TOP15,
    MENU_PAGE_STATS_GENERAL,
    MENU_PAGE_MODES
};

enum _:structIdMenuDatas {
	MENU_DATA_SKIN_ID = 0,
	MENU_DATA_KNIFE_ID,
	MENU_DATA_HAT_ID,
	MENU_DATA_CLASS_HUMAN_ID,
	MENU_DATA_CLASS_ZOMBIE_ID,
	MENU_DATA_CLASS_SURVIVOR_ID,
	MENU_DATA_CLASS_NEMESIS_ID,
	MENU_DATA_SHC_LEVEL,
	MENU_DATA_SZC_LEVEL,
	MENU_DATA_GROUP_MEMBER_ID,
	MENU_DATA_CLAN_MEMBER_ID,
	MENU_DATA_ACHIEVEMENT_CLASS,
	MENU_DATA_ACHIEVEMENT_ID,
	MENU_DATA_COLOR_CHOOSEN,
	MENU_DATA_ADMIN_PLAYERS
};

enum _:structModes {
	modeName[32],
	modeChance,
	modeUsersNeed
};

enum _:structWeapons {
	weaponCSW,
	weaponEntName[32],
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

enum _:structExtraItem {
	extraItemName[32],
	extraItemCost,
	extraItemLimitUserInRound,
	extraItemLimitMap,
	extraItemTeam
};

enum _:structHumanClasses {
	humanClassName[32],
	humanClassInfo[256],
	humanClassHealth,
	Float:humanClassSpeed,
	Float:humanClassGravity,
	humanClassVip
};

enum _:structZombieClasses {
	zombieClassName[32],
	zombieClassInfo[256],
	zombieClassModel[160],
	zombieClassHealth,
	Float:zombieClassSpeed,
	Float:zombieClassGravity,
	zombieClassPowerOn
};

enum _:structSurvivorClasses {
	survivorClassName[32],
	survivorClassNameMin[32],
	survivorClassInfo[256],
	survivorClassHealth,
	Float:survivorClassSpeed,
	Float:survivorClassGravity,
	survivorClassVip
};

enum _:structNemesisClasses {
	nemesisClassName[32],
	nemesisClassNameMin[32],
	nemesisClassInfo[256],
	nemesisClassHealth,
	Float:nemesisClassSpeed,
	Float:nemesisClassGravity,
	nemesisClassVip
};

enum _:structSkins {
	skinName[32],
	skinModelName[128],
	skinReq,
	skinVip,
	skinAppMobile
};

enum _:structKnifes {
	knifeName[32],
	knifeModelNameV[128],
	knifeModelNameP[128],
	knifeReqLevel,
	knifeReqPoints,
	knifeVip,
	knifeAppMobile
};

enum _:structHats {
	hatName[32],
	hatModelName[128],
	hatReq,
	hatVip,
	hatAppMobile
};

enum _:structAchievements {
	achievementName[32],
	achievementInfo[128],
	achievementReward,
	achievementUsersneedP,
	achievementUsersneedA,
	achievementClass
};

enum _:structClans {
	clanId,
	clanName[16],
	clanTimestamp,
	clanDeposit,
	clanKillsHumanDone,
	clanKillsZombieDone,
	clanInfectionsDone,
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
	clanMemberLevel
};

enum _:structColors {
	colorName[16],
	colorRed,
	colorGreen,
	colorBlue
};

enum _:structTop15 {
	top15Name[32],
	top15URL[64]
};

enum _:structHappyHours {
	hhAPsKillReward_Vip,
	hhAPsKillReward_Normal,
	hhXPKillReward,
	hhAPsDamageReward_Vip,
	hhAPsDamageReward_Normal,
	hhXPDamage,
	hhPLRewardEscape_Vip,
	hhPLRewardEscape_Normal,
	hhXPRewardEscape_Vip,
	hhXPRewardEscape_Normal,
	hhAPsRewardEscape_Vip,
	hhAPsRewardEscape_Normal,
	hhXPRewardInfection,
	hhAPsInfectionReward_Vip,
	hhAPsInfectionReward_Normal
};

new const __SERVER_FILE[] = "server.log";
new const __CHATCLAN_FILE[] = "chatclan.log";
new const __SQL_FILE[] = "mysql.log";

new const __ENT_THINK_HUD[] = "entThinkHud";
new const __ENT_THINK_LEADERS[] = "entThinkLeaders";
new const __ENT_THINK_FROST[] = "entThinkFrost";
new const __ENT_CLASSNAME_BANSHEE[] = "entClassNameBanshee";
new const __ENT_CLASSNAME_SUPPLYBOX[] = "entClassNameSupplyBox";
new const __ENT_CLASSNAME_FARAHON[] = "entClassNameFarahon";
new const __ENT_CLASSNAME_TOXICO[] = "entClassNameToxico";
new const __ENT_CLASSNAME_HAT[] = "entHat";

new const __REMOVE_ENTS[][] = {
	"func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity", "monster_scientist", "info_hostage_rescue", "func_hostage_rescue",
	"func_vehicle", "info_map_parameters", "func_buyzone", "func_tank", "func_tankcontrols", "item_longjump"
};

new const __WEAPON_ENTNAME_LIST[][] = {
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil",
	"weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90"
};

new const __MAX_BPAMMO[] = {
	-1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100
};

new const __AMMO_WEAPON[] = {
	0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4
};

new const __AMMO_TYPE[][] = {
	"", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm"
};

new const Float:__BULLET_DAMAGE_COORDS[][] = {
	{0.50, 0.40}, {0.56, 0.44}, {0.60, 0.50}, {0.56, 0.56}, {0.50, 0.60}, {0.44, 0.56}, {0.40, 0.50}, {0.44, 0.44}
};

new const __BLOCK_COMMANDS[][] = {
	"buy", "buyequip", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47", "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
	"sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "fiveseven", "12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum",
	"d3au1", "krieg550", "smg", "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown",
	"radio2", "radio3"
};

new const __RANGES[MAX_RANGE + 1][] = {
	"Inexperto", "Civil Infectado", "Civil Limpio", "Soldado X", "Soldado Solar", "Capitan de Escape", "Coronel de Escape", "General de Escape", "Heroe de Escape", "Escapista Clase I", "Escapista Clase II",
	"Escapista Global", "Supremo Clase I", "Supremo Clase II", "Supremo Clase III", "Cazador Rank C", "Cazador Rank B", "Cazador Rank A+", "Sobreviviente", "Veterano", "Escapista Mitico",
	"Escapista Noble", "Super Nova", "Heredero", "Heredero Final", "Leyenda", "Leyenda X", "Leyenda XL", "Mitico", "Soldado Noble", "Eclipse Negro", "Eclipse Blanco", "El Fuhrer", "Forerunner",
	"Reclamador", "Reclamador II", "Reclamador III", "Escape Ranger", "Escape Ranger II", "Escape Ranger XL", "Ultra Escapista", "Mega Escapista", "Escapista Maximo", "Semi-Dios",
	"Hijo del Escape", "Escape Master", "Escape Master II", "Escape Master III", "Escape Master X", "Hijo de Jairito",

	"Hijo de Jairito"
};

new const __MODES[structIdModes][structModes] = {
	{"", 0, 0},
	{"INFECCIÓN", 0, 4},
	{"SWARM", 30, 4},
	{"INFECCIÓN MÚLTIPLE", 10, 4},
	{"PLAGUE", 40, 8},
	{"ARMAGEDDON", 75, 12},
	{"SURVIVOR", 25, 4},
	{"NEMESIS", 25, 4},
	{"NEMESIS EXTREMO", 0, 12},
	{"JERUZALEM", 0, 16}
};

new const __AMBIENCE_MUTED_SOUNDS[][] = {
	{MODE_NONE, AMBIENCE_MUTED_NONE},
	{MODE_INFECTION, AMBIENCE_MUTED_INFECTION},
	{MODE_SWARM, AMBIENCE_MUTED_SWARM},
	{MODE_MULTI, AMBIENCE_MUTED_MULTI},
	{MODE_PLAGUE, AMBIENCE_MUTED_PLAGUE},
	{MODE_ARMAGEDDON, AMBIENCE_MUTED_ARMAGEDDON},
	{MODE_SURVIVOR, AMBIENCE_MUTED_SURVIVOR},
	{MODE_NEMESIS, AMBIENCE_MUTED_NEMESIS},
	{MODE_NEMESIS_X, AMBIENCE_MUTED_NEMESIS_X},
	{MODE_JERUZALEM, AMBIENCE_MUTED_JERUZALEM}
};

new const __PRIMARY_WEAPONS[][structWeapons] = {
	{CSW_GALIL, "weapon_galil", "IMI Galil", "models/dg/ze3/v_galil_w4.mdl"},
	{CSW_M4A1, "weapon_m4a1", "M4A1 Carbine", "models/dg/ze3/v_m4a1_w4.mdl"},
	{CSW_AK47, "weapon_ak47", "AK-47 Kalashnikov", "models/dg/ze3/v_ak47_w4.mdl"},
	{CSW_SG552, "weapon_sg552", "Krieg SG552", "models/dg/ze3/v_sg552_w4.mdl"},
	{CSW_M3, "weapon_m3", "M3 Super 90", "models/dg/ze3/v_m3_w4.mdl"},
	{CSW_XM1014, "weapon_xm1014", "XM1014 M4", "models/dg/ze3/v_xm1014_w4.mdl"},
	{CSW_MP5NAVY, "weapon_mp5navy", "MP5 Navy", "models/dg/ze3/v_mp5_w4.mdl"},
	{CSW_AWP, "weapon_awp", "AWP Magnum Sniper", "models/dg/ze3/v_awp_w4.mdl"}
};

new const __SECONDARY_WEAPONS[][structWeapons] = {
	{CSW_DEAGLE, "weapon_deagle", "Desert Eagle .50", "models/dg/ze3/v_deagle_w4.mdl"},
	{CSW_ELITE, "weapon_elite", "Dual Elite Berettas", "models/dg/ze3/v_elite_w4.mdl"},
	{CSW_USP, "weapon_usp", "USP .45 ACP Tactical", "models/dg/ze3/v_usp_2.mdl"},
	{CSW_GLOCK18, "weapon_glock18", "Glock 18C", "models/dg/ze3/v_glock18_1.mdl"}
};

new const __GRENADES[][structGrenades] = {
	{"\y+\w1 Fuego \r|\w \y+\w1 Hielo \r|\w \y+\w1 Explosiva", 1, 1, 1, 1},
	{"\y+\w1 Fuego \r|\w \y+\w2 Hielo \r|\w \y+\w1 Explosiva", 1, 2, 1, 50},
	{"\y+\w2 Fuego \r|\w \y+\w2 Hielo \r|\w \y+\w1 Explosiva", 2, 2, 1, 100},
	{"\y+\w3 Fuego \r|\w \y+\w2 Hielo \r|\w \y+\w2 Explosiva", 3, 2, 2, 150},
	{"\y+\w3 Fuego \r|\w \y+\w3 Hielo \r|\w \y+\w3 Explosiva", 3, 3, 3, 200}
};

new const __EXTRA_ITEMS[structIdExtraItem][structExtraItem] = {
	{"Antídoto", 30, 1, 5, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Furia Zombie", 35, 1, 6, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Bomba de Infección", 60, 1, 1, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Balas Infinitas", 60, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Campo de Fuerza", 20, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Bomba de Droga", 20, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Anti-Incendiaria", 5, 0, 0, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Anti-Congelacion", 5, 0, 0, EXTRA_ITEM_TEAM_ZOMBIE},
	{"Balrog I", 10, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Balrog XI", 20, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Plasmagun", 20, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Skull IV", 20, 0, 0, EXTRA_ITEM_TEAM_HUMAN},
	{"Thunderbolt", 25, 0, 0, EXTRA_ITEM_TEAM_HUMAN}
};

new const __HUMAN_CLASSES[structIdHumanClasses][structHumanClasses] = {
	{"Civil", "Balanceado", 100, 240.0, 1.0, 0},
	{"Activo", "Velocidad aumentada x1.5", 100, 245.0, 1.0, 0},
	{"Liviano" ,"Gravedad reducida x3", 100, 240.0, 0.85, 0},
	{"Recio" ,"Vida aumentada x2", 200, 240.0, 1.05, 0},
	{"Blaze" ,"Estadísticas base mejoradas", 145, 242.5, 0.9, 0},
	{"Ninja" ,"Otorga un +125% de daño con Cuchillo", 100, 240.0, 1.0, 0},
	{"Sniper" ,"Otorga +20 de Chaleco y un +25% de daño con Snipers", 100, 245.0, 1.0, 0},
	{"Centinela" ,"Otorga +20 de Chaleco", 100, 242.0, 0.95, 0},
	{"Sharpshooter", "Sus balas no tienen retroceso en cualquier arma", 100, 240.0, 1.1, 0},
	{"Radiactivo (VIP)", "Humano Mejorado con Brillo Verde", 120, 242.0, 0.8, 1},
	{"Médico", "Puede curar humanos aliados en un radio cercano^n\d[Tecla F]\w", 125, 240.0, 1.0, 0}
};

new const __ZOMBIE_CLASSES[structIdZombieClasses][structZombieClasses] = {
	{"Heavy Santa", "Balanceado", "dg-ze_zombie_xmas1", 12000, 270.0, 0.8, 1},
	{"Voodo", "Puede curar zombies aliados^n\d[Tecla F]\w", "dg-ze_voodoo_02", 12000, 270.0, 0.75, 1},
	{"Lusty Rose", "Puede volverse invisible^n\d[Tecla F]\w", "dg-ze_zombie_lr_02", 12000, 270.0, 0.75, 1},
	{"Banshee", "Lanza murcielagos^n\d[Tecla F]\w", "dg-ze_zombie_banshee0", 12000, 270.0, 0.75, 1},
	{"Farahon", "Lanzan bolas de fuego^n\d[Mantener Tecla R]\w", "ze_zombie_farahon_02", 12000, 270.0, 0.75, 1},
	{"Fleshpound", "Puede desatar su ira^n\d[Tecla F]\w", "dg-ze_fleshpound_01", 12000, 270.0, 0.75, 1},
	{"Tóxico", "Escupe ácido causando daño^n\d[Tecla F]\w", "ze_zombie_toxico_02", 12000, 270.0, 0.75, 1}
};

new const __SURVIVOR_CLASSES[structIdSurvivorClasses][structSurvivorClasses] = {
	{"Común", "común", "Balanceado", 4000, 245.0, 0.9, 0},
	{"Ligero", "ligero", "Velocidad aumentada", 4000, 239.0, 1.1, 0},
	{"Rápido", "rápido", "Gravedad reducida", 4000, 234.0, 0.9, 0},
	{"Mejorado (VIP)", "mejorado", "Vida aumentada", 4500, 235.0, 0.83, 1}
};

new const __NEMESIS_CLASSES[structIdNemesisClasses][structNemesisClasses] = {
	{"Común", "común", "Balanceado", 20000, 245.0, 0.9, 0},
	{"Ligero", "ligero", "Velocidad aumentada", 20000, 239.0, 1.1, 0},
	{"Rápido", "rápido", "Gravedad reducida", 20000, 234.0, 0.9, 0},
	{"Mejorado (VIP)", "mejorado", "Vida aumentada", 22500, 235.0, 0.83, 1}
};

new const __SKINS[][structSkins] = {
	{"Ninguno", "", 0, 0, 0},
	{"Payday Wolf", "dg-ze_human_01", 2500, 0, 0},
	{"Sarash Black", "dg-ze_human_02", 3250, 0, 0},
	{"Chickenator", "dg-ze_human_03", 4000, 0, 0},
	{"Lady Hunter", "dg-ze_human_04", 4750, 0, 0},
	{"Blade Reaper", "dg-ze_human_05", 5500, 0, 0},
	{"Kaitlyn", "dg-ze_human_06b", 6250, 0, 0},
	{"Crysis Black", "dg-ze_human_07", 7000, 0, 0},
	{"Axion", "dg-ze_human_08b", 7750, 0, 0},
	{"Albert Wesker", "dg-ze_human_09b", 8500, 0, 0},
	{"Predator (VIP)", "dg-ze_human_10", 0, 1, 0},
	{"Agente Angel", "dg-ze_human_11", 9250, 0, 0},
	{"Kaze", "dg-ze_human_12", 10000, 0, 0},
	{"Ying", "dg-ze_human_13a", 11000, 0, 0},
	{"Steam Punk", "dg-ze_human_14", 12000, 0, 0},
	{"Cyborg CSO", "dg-ze_human_15b", 13000, 0, 0},
	{"Mike Noble (VIP)", "dg-ze_mike_noble", 0, 1, 0},
	{"The Joker", "dg-ze_human_17b", 14000, 0, 0},
	{"Iron Man", "dg-ze_human_18", 15000, 0, 0},
	{"Halo LightBlue", "dg-ze_human_19b", 17500, 0, 0},
	{"Alice CSO (VIP)", "dg-ze_human_20b", 0, 1, 0 },
	{"Spawn", "dg-ze_human_21", 10000, 0, 0},
	{"Cyborg Queen CSO", "dg-ze_human_22", 13000, 0, 0},
	{"Boss David CSO", "dg-ze_human_23", 17500, 0, 0},
	{"Ka-LEL CSO", "dg-ze_human_24", 20000, 0, 0}
};

new const __KNIFES[][structKnifes] = {
	{"Ninguno", "", "", 0, 0, 0, 0},
	{"Bate Baseball", "models/dg/ze3/knife/v_batezombie.mdl", "models/dg/ze3/knife/p_batezombie.mdl", 1, 500, 0, 0},
	{"Antorcha", "models/dg/ze3/knife/v_antorcha.mdl", "models/dg/ze3/knife/p_antorcha.mdl", 30, 1500, 0, 0},
	{"Dragon Sword", "models/dg/ze3/knife/v_dragonsword.mdl", "models/dg/ze3/knife/p_dragonsword.mdl", 60, 2500, 0, 0},
	{"Axe Xmas", "models/dg/ze3/knife/v_axe_xmas.mdl", "models/dg/ze3/knife/p_axe_xmas.mdl", 90, 3500, 0, 0},
	{"Jay Daggers", "models/dg/ze3/knife/v_dagger.mdl", "models/dg/ze3/knife/p_dagger.mdl", 120, 5000, 0, 0},
	{"Dragon Tails", "models/dg/ze3/knife/v_dragontail.mdl", "models/dg/ze3/knife/p_dragontail.mdl", 150, 7000, 0, 0},
	{"Ice Doll", "models/dg/ze3/knife/v_icedoll.mdl", "models/dg/ze3/knife/p_icedoll.mdl", 180, 9000, 0, 0},
	{"Shadow Mourne", "models/dg/ze3/knife/v_shadowmourne.mdl", "models/dg/ze3/knife/p_skullaxe2.mdl", 210, 11500, 0, 0},
	{"Skull Axe II", "models/dg/ze3/knife/v_skullaxe2.mdl", "models/dg/ze3/knife/p_skullaxe2.mdl", 240, 14000, 0, 0},
	{"Katana Buffed", "models/dg/ze3/knife/v_buffkatana.mdl", "models/dg/ze3/knife/p_buffkatana.mdl", 275, 17500, 0, 0},
	{"Renger XMAS (VIP)", "models/dg/ze3/knife/v_renger_xmas.mdl", "models/dg/ze3/knife/p_renger_xmas.mdl", 1, 0, 1, 0},
	{"Thanatos Android (VIP)", "models/dg/ze3/knife/v_thanatos_android.mdl", "models/dg/ze3/knife/p_thanatos_android.mdl", 1, 0, 1, 0}
};

new const __HATS[][structHats] = {
	{"Ninguno", "models/v_usp.mdl", 0, 0, 0},
	{"Ogro Peligroso", "models/dg/ze3/hats/doccabi.mdl", 500, 0, 0},
	{"Gazowa", "models/dg/ze3/hats/gazowa.mdl", 1000, 0, 0},
	{"Bicho", "models/dg/ze3/hats/bicho.mdl", 1500, 0, 0},
	{"Yeti", "models/dg/ze3/hats/yeti.mdl", 2000, 0, 0},
	{"Koala", "models/dg/ze3/hats/koala.mdl", 2500, 0, 0},
	{"Panda", "models/dg/ze3/hats/elpanda.mdl", 3000, 0, 0},
	{"Black Dragon", "models/dg/ze3/hats/blackdragon.mdl", 3500, 0, 0},
	{"Conejo Malo", "models/dg/ze3/hats/rabbit.mdl", 4000, 0, 0},
	{"El Diablo", "models/dg/ze3/hats/eldiablo2.mdl", 4500, 0, 0},
	{"Musulman", "models/dg/ze3/hats/musulman.mdl", 5000, 0, 0},
	{"Baby Dino", "models/dg/ze3/hats/babydino.mdl", 6000, 0, 0},
	{"Ladron", "models/dg/ze3/hats/ladron.mdl", 7000, 0, 0},
	{"Deimos CSO", "models/dg/ze3/hats/deimos.mdl", 8000, 0, 0},
	{"Xmas CSO", "models/dg/ze3/hats/christmas.mdl", 9000, 0, 0},
	{"Bomba de Infeccion", "models/dg/ze3/hats/infection.mdl", 10000, 0, 0},
	{"Ghost", "models/dg/ze3/hats/ghost.mdl", 12500, 0, 0},
	{"Heavy CSO", "models/dg/ze3/hats/heavy.mdl", 15000, 0, 0},
	{"Indio CSO", "models/dg/ze3/hats/indian.mdl", 17500, 0, 0},
	{"Bandera Drunks", "models/dg/ze3/hats/flagdrunk.mdl", 0, 1, 0},
	{"TV Drunk Gaming", "models/dg/ze3/hats/latvdg.mdl", 0, 1, 0}
};

new const __ACHIEVEMENTS[structIdAchievements][structAchievements] = {
	{"CUENTA PAR", "Tu número de cuenta es Par", 5, 0, 0, ACHIEVEMENT_CLASS_GENERAL},
	{"CUENTA IMPAR", "Tu número de cuenta es Impar", 5, 0, 0, ACHIEVEMENT_CLASS_GENERAL},
	{"SOY DORADO", "Se un jugador VIP", 10, 0, 0, ACHIEVEMENT_CLASS_GENERAL},
	{"VINCULADO WEB", "Vincula tu cuenta del Zombie Escape con la del foro", 15, 0, 0, ACHIEVEMENT_CLASS_GENERAL},
	{"VINCULADO MOVIL", "Vincula tu cuenta del Zombie Escape con la de la APP Mobile", 15, 0, 0, ACHIEVEMENT_CLASS_GENERAL},
	{"25 ZOMBIES", "Mata a +25 zombies", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"50 ZOMBIES", "Mata a +50 zombies", 4, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"100 ZOMBIES", "Mata a +100 zombies", 6, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"250 ZOMBIES", "Mata a +250 zombies", 8, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"500 ZOMBIES", "Mata a +500 zombies", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"750 ZOMBIES", "Mata a +750 zombies", 12, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"1.000 ZOMBIES", "Mata a +1.000 zombies", 14, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"2.500 ZOMBIES", "Mata a +2.500 zombies", 16, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"5.000 ZOMBIES", "Mata a +5.000 zombies", 18, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"7.500 ZOMBIES", "Mata a +7.500 zombies", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"10.000 ZOMBIES", "Mata a +10.000 zombies", 22, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"15.000 ZOMBIES", "Mata a +15.000 zombies", 24, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"20.000 ZOMBIES", "Mata a +20.000 zombies", 26, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"25.000 ZOMBIES", "Mata a +25.000 zombies", 28, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"35.000 ZOMBIES", "Mata a +35.000 zombies", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"45.000 ZOMBIES", "Mata a +45.000 zombies", 32, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"55.000 ZOMBIES", "Mata a +55.000 zombies", 34, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"75.000 ZOMBIES", "Mata a +75.000 zombies", 36, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"25 INFECCIONES", "Infectar a +25 humanos", 2, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"50 INFECCIONES", "Infectar a +50 humanos", 4, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"100 INFECCIONES", "Infectar a +100 humanos", 6, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"250 INFECCIONES", "Infectar a +250 humanos", 8, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"500 INFECCIONES", "Infectar a +500 humanos", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"750 INFECCIONES", "Infectar a +750 humanos", 12, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"1.000 INFECCIONES", "Infectar a +1.000 humanos", 14, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"2.500 INFECCIONES", "Infectar a +2.500 humanos", 16, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"5.000 INFECCIONES", "Infectar a +5.000 humanos", 18, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"7.500 INFECCIONES", "Infectar a +7.500 humanos", 20, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"10.000 INFECCIONES", "Infectar a +10.000 humanos", 22, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"15.000 INFECCIONES", "Infectar a +15.000 humanos", 24, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"20.000 INFECCIONES", "Infectar a +20.000 humanos", 26, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"25.000 INFECCIONES", "Infectar a +25.000 humanos", 28, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"35.000 INFECCIONES", "Infectar a +35.000 humanos", 30, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"45.000 INFECCIONES", "Infectar a +45.000 humanos", 32, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"55.000 INFECCIONES", "Infectar a +55.000 humanos", 34, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"75.000 INFECCIONES", "Infectar a +75.000 humanos", 36, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"25 ESCAPES", "Realiza +25 escapes", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"50 ESCAPES", "Realiza +50 escapes", 4, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"100 ESCAPES", "Realiza +100 escapes", 6, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"250 ESCAPES", "Realiza +250 escapes", 8, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"500 ESCAPES", "Realiza +500 escapes", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"750 ESCAPES", "Realiza +750 escapes", 12, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"1.000 ESCAPES", "Realiza +1.000 escapes", 14, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"2.500 ESCAPES", "Realiza +2.500 escapes", 16, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"5.000 ESCAPES", "Realiza +5.000 escapes", 18, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"7.500 ESCAPES", "Realiza +7.500 escapes", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"10.000 ESCAPES", "Realiza +10.000 escapes", 22, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"15.000 ESCAPES", "Realiza +15.000 escapes", 24, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"20.000 ESCAPES", "Realiza +20.000 escapes", 26, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"25.000 ESCAPES", "Realiza +25.000 escapes", 28, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"35.000 ESCAPES", "Realiza +35.000 escapes", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"45.000 ESCAPES", "Realiza +45.000 escapes", 32, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"55.000 ESCAPES", "Realiza +55.000 escapes", 34, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"75.000 ESCAPES", "Realiza +75.000 escapes", 36, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"PRIMERO: 1.000 ESCAPES", "Se el primero en realizar +1.000 escapes", 14, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"PRIMERO: 25.000 ESCAPES", "Se el primero en realizar +25.000 escapes", 20, 0, 0, ACHIEVEMENT_CLASS_FIRST},
	{"10 SURVIVORS", "Mata a +10 survivors", 5, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"25 SURVIVORS", "Mata a +25 survivors", 10, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"50 SURVIVORS", "Mata a +50 survivors", 15, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"100 SURVIVORS", "Mata a +100 survivors", 20, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"200 SURVIVORS", "Mata a +200 survivors", 25, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"300 SURVIVORS", "Mata a +300 survivors", 30, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"400 SURVIVORS", "Mata a +400 survivors", 35, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"500 SURVIVORS", "Mata a +500 survivors", 40, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"10 NEMESIS", "Mata a +10 nemesis", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"25 NEMESIS", "Mata a +25 nemesis", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"50 NEMESIS", "Mata a +50 nemesis", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"100 NEMESIS", "Mata a +100 nemesis", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"200 NEMESIS", "Mata a +200 nemesis", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"300 NEMESIS", "Mata a +300 nemesis", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"400 NEMESIS", "Mata a +400 nemesis", 35, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"500 NEMESIS", "Mata a +500 nemesis", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"AFILANDO CUCHILLO", "Mata a un zombie con cuchillo", 15, 0, 10, ACHIEVEMENT_CLASS_HUMAN},
	{"LIDER EN CABEZAS", "Mata a +1.000 zombies con disparos en la cabeza", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"AGUJEREANDO CABEZAS", "Mata a +10.000 zombies con disparos en la cabeza", 30, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"ESCAPE DE LOS VIPS", "Escapa junto a los dos VIPs", 10, 0, 0, ACHIEVEMENT_CLASS_MODE},
	{"MATA A UN VIP", "Matá a un VIP", 5, 0, 0, ACHIEVEMENT_CLASS_MODE},
	{"MATA A LOS DOS VIP", "En la misma ronda, matá a los dos VIPs", 10, 0, 0, ACHIEVEMENT_CLASS_MODE},
	{"LOS VIPS NO PUEDEN ESCAPAR", "Ganá el modo JERUZALEM siendo zombie", 5, 0, 0, ACHIEVEMENT_CLASS_MODE},
	{"VENGAN, LOS ESPERO", "Consigue escapar o ganar la ronda siendo el último humano", 15, 0, 10, ACHIEVEMENT_CLASS_HUMAN},
	{"SOLO WIN", "Gana la ronda siendo el último humano contra todos...", 10, 0, 10, ACHIEVEMENT_CLASS_HUMAN},
	{"CRAZY MODE", "Logro secreto", 20, 0, 0, ACHIEVEMENT_CLASS_SECRET},
	{"CAJAS x1", "Agarra una caja", 2, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x10", "Agarra 10 o más cajas", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x50", "Agarra 50 o más cajas", 10, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x100", "Agarra 100 o más cajas", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x500", "Agarra 500 o más cajas", 20, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x1.000", "Agarra 1.000 o más cajas", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"PRIMERO: CAJAS x1.000", "Se el primero en agarrar 1.000 o más cajas", 25, 0, 0, ACHIEVEMENT_CLASS_SECRET},
	{"CAJAS EN LA RONDA x2", "Agarra 2 cajas en una misma ronda", 5, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS EN LA RONDA x3", "Agarra 3 cajas en una misma ronda", 15, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS EN LA RONDA x4", "Agarra 4 cajas en una misma ronda", 25, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS EN LA RONDA x5", "Agarra 5 cajas en una misma ronda", 35, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"PRIMERO: CAJAS EN LA RONDA x5", "Se el primero en agarrar 2 cajas en una misma rond...", 35, 0, 0, ACHIEVEMENT_CLASS_SECRET},
	{"VALENTINA TE AMO", "Logro secreto", 10, 0, 0, ACHIEVEMENT_CLASS_SECRET},
	{"100K ZOMBIES", "Mata a +100K zombies", 38, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"125K ZOMBIES", "Mata a +125K zombies", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"150K ZOMBIES", "Mata a +150K zombies", 42, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"175K ZOMBIES", "Mata a +175K zombies", 44, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"200K ZOMBIES", "Mata a +200K zombies", 46, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"225K ZOMBIES", "Mata a +225K zombies", 48, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"250K ZOMBIES", "Mata a +250K zombies", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"100K INFECCIONES", "Infectar a +100K humanos", 38, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"125K INFECCIONES", "Infectar a +125K humanos", 40, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"150K INFECCIONES", "Infectar a +150K humanos", 42, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"175K INFECCIONES", "Infectar a +175K humanos", 44, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"200K INFECCIONES", "Infectar a +200K humanos", 46, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"225K INFECCIONES", "Infectar a +225K humanos", 48, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"250K INFECCIONES", "Infectar a +250K humanos", 50, 0, 0, ACHIEVEMENT_CLASS_ZOMBIE},
	{"85.000 ESCAPES", "Realiza +85.000 escapes", 40, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"100.000 ESCAPES", "Realiza +100.000 escapes", 42, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x1.500", "Agarra 1.500 o más cajas", 50, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x2.000", "Agarra 2.000 o más cajas", 75, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x2.500", "Agarra 2.500 o más cajas", 100, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x3.000", "Agarra 3.000 o más cajas", 150, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x3.500", "Agarra 3.500 o más cajas", 200, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x4.000", "Agarra 4.000 o más cajas", 250, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x4.500", "Agarra 4.500 o más cajas", 300, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x5.000", "Agarra 5.000 o más cajas", 350, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x6.000", "Agarra 6.000 o más cajas", 400, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x7.000", "Agarra 7.000 o más cajas", 450, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x8.000", "Agarra 8.000 o más cajas", 500, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x9.000", "Agarra 9.000 o más cajas", 600, 0, 0, ACHIEVEMENT_CLASS_HUMAN},
	{"CAJAS x10.000", "Agarra 10.000 o más cajas", 700, 0, 0, ACHIEVEMENT_CLASS_HUMAN}
};

new const __ACHIEVEMENTS_CLASS[structIdAchievementsClass][] = {
	"General", "Humanos", "Zombies", "Modos", "Primeros", "Secretos"
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
	"HUD General", "Grupo"
};

new const __HUD_TYPES[][] = {
	"GENERAL"
};

new const __HUD_STYLES[][] = {
	"Normal", "Normal con corchetes", "Minimizado", "Minimizado con corchetes", "Minimizado con guiones"
};

new const __TOP15[][structTop15] = {
	{"General", "top15_general.php"},
	{"Tiempo jugado", "top15_played_time.php"},
	{"Humanos matados", "top15_humans_killed.php"},
	{"Zombies matados", "top15_zombies_killed.php"},
	{"Humanos infectados", "top15_humans_infected.php"},
	{"Survivors matados", "top15_survivors_killed.php"},
	{"Nemesis matados", "top15_nemesis_killed.php"},
	{"Zombies matados en la cabeza", "top15_zombies_hs_killed.php"},
	{"Zombies matados con cuchillo", "top15_zombies_knife_killed.php"},
	{"Chaleco desgarrado", "top15_armor.php"},
	{"Escapes", "top15_escapes.php"},
	{"Logros desbloqueados", "top15_achievements_unlocked.php"},
	{"Cajas agarradas", "top15_supplybox_given.php"}
};

new const __XP_NEED[MAX_LEVEL + 2] = {
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

new const __HAPPY_HOUR[][structHappyHours] = {
	{ // DRUNK AT NITE [OFF]
		2 /*VIP*/, 1 /*Normal*/, 	// Recompensa al matar (APs)
		10, 						// Recompensa al matar (XP)
		2 /*VIP*/, 1 /*Normal*/,	// Recompensa al realizar daño (APs)
		4,							// Recompensa al realizar daño (XP)
		8 /*VIP*/, 6 /*Normal*/,	// Recompensa al escapar (Puntos)
		40 /*VIP*/, 20 /*Normal*/,	// Recompensa al escapar (XP)
		2 /*VIP*/, 1 /*Normal*/,	// Recompensa al escapar (APs)
		15,							// Recompensa al infectar (XP)
		2 /*VIP*/, 1 /*Normal*/		// Recompensa al infectar (APs)
	},
	{ // DRUNK AT NITE [ON]
		4 /*VIP*/, 2 /*Normal*/, 	// Recompensa al matar (APs)
		20,							// Recompensa al matar (XP)
		4 /*VIP*/, 2 /*Normal*/,	// Recompensa al realizar daño (APs)
		8,							// Recompensa al realizar daño (XP)
		10 /*VIP*/, 8 /*Normal*/,	// Recompensa al escapar (Puntos)
		60 /*VIP*/, 30 /*Normal*/,	// Recompensa al escapar (XP)
		4 /*VIP*/, 2 /*Normal*/,	// Recompensa al escapar (APs)
		30,							// Recompensa al infectar (XP)
		4 /*VIP*/, 2 /*Normal*/		// Recompensa al infectar (APs)
	}
};

new const Float:__WEAPON_KNOCKBACK_POWER[] = {
	-1.0, 4.0, -1.0, 6.5, -1.0, 8.0, -1.0, 3.0, 5.0, -1.0, 2.4, 2.0, 2.4, 5.3, 5.5, 5.5, 2.2, 2.0, 10.0, 2.5, 6.0, 8.0, 6.0, 2.4, 6.5, -1.0, 5.3, 5.0, 6.0, -1.0, 5.0
};

new const __PLAYER_MODEL_HUMAN[] = "dg-ze_human_x1";
new const __PLAYER_MODEL_SURVIVOR[] = "dg-ze_survivor_00";
new const __PLAYER_MODEL_NEMESIS[] = "dg-ze_nemesis_00";
new const __PLAYER_MODEL_JERUZALEM_VIP[] = "dg-ze_jeruzalem_vip";

new const __WEAPON_MODEL_SURVIVOR_V[] = "models/dg/ze3/v_m249_s.mdl";
new const __WEAPON_MODEL_SURVIVOR_P[] = "models/dg/ze3/p_m249_s.mdl";
new const __WEAPON_MODEL_BAZOOKA_V[] = "models/dg/ze3/v_bazooka_00.mdl";
new const __WEAPON_MODEL_BAZOOKA_P[] = "models/dg/ze3/p_bazooka_00.mdl";
new const __GRENADE_MODEL_INFECTION_V[] = "models/dg/ze3/v_grenade_infection_00.mdl";
new const __GRENADE_MODEL_INFECTION_P[] = "models/dg/ze3/p_grenade_infection_00.mdl";
new const __GRENADE_MODEL_FIRE_V[] = "models/dg/ze3/v_fire_xmas.mdl";
new const __GRENADE_MODEL_FROST_V[] = "models/dg/ze3/v_hielo_w4.mdl";
new const __GRENADE_MODEL_EXPLOSIVE_V[] = "models/dg/ze3/v_explosion_w4.mdl";
new const __GRENADE_MODEL_MADNESS_V[] = "models/dg/ze3/v_grenade_madness_01.mdl";
new const __GRENADE_MODEL_BUBBLE_V[] = "models/dg/ze3/v_grenade_bubble_00.mdl";
new const __GRENADE_MODEL_BUBBLE_W[] = "models/dg/ze3/w_grenade_bubble_00.mdl";
new const __MODEL_ROCKET[] = "models/dg/ze3/rocket_00.mdl";
new const __MODEL_FROST[] = "models/dg/ze3/frozen_00.mdl";
new const __MODEL_BUBBLE[] = "models/dg/ze3/bubble_00.mdl";
new const __MODEL_SUPPLYBOX[] = "models/dg/ze3/supplybox_00.mdl";
new const __MODEL_BANSHEE[] = "models/zombie_plague/bat_witch.mdl";
new const __MODEL_FARAHON[] = "sprites/3dmflared.spr";
new const __MODEL_SPIT[] = "models/spit.mdl";

new const __SOUND_AMMOPICKUP[] = "items/ammopickup1.wav";
new const __SOUND_ANTIDOTE[] = "items/smallmedkit1.wav";
new const __SOUND_AMMO_PICKUP[] = "items/ammopickup1.wav";
new const __SOUND_WIN_HUMANS[] = "dg/ze3/win_human.wav";
new const __SOUND_WIN_ZOMBIES[] = "dg/ze3/win_zombies.wav";
new const __SOUND_WIN_NO_ONE[] = "dg/ze3/win_no_one.wav";
new const __SOUND_ROUND_GENERAL[][] = {
	"ambience/the_horror2.wav", "dg/ze3/r_general_00.wav", "dg/ze3/r_general_01.wav", "dg/ze3/r_general_02.wav", "dg/ze3/r_general_03.wav"
};
new const __SOUND_ROUND_MODES[][] = {
	"dg/ze3/r_mode_00.wav", "dg/ze3/r_mode_01.wav", "dg/ze3/r_mode_02.wav", "dg/ze3/r_mode_03.wav"
};
new const __SOUND_ROUND_ARMAGEDDON[] = "dg/ze3/r_armageddon_00.wav";
new const __SOUND_AMBIENCE[structIdAmbienceSounds][] = {
	"", "sound/dg/ze3/aa_mode_xmas.mp3", "sound/dg/ze3/aa_mode_xmas.mp3", "sound/dg/ze3/aa_mode_xmas.mp3", "sound/dg/ze3/aa_mode_xmas.mp3", "sound/dg/ze3/a_armageddon_00.mp3", "sound/dg/ze3/a_survivor_00.mp3", "sound/dg/ze3/a_nemesis_00.mp3", "sound/dg/ze3/a_nemesis_00.mp3", "sound/dg_jeruzalem/jeruzalem_ze.mp3"
};
new const __SOUND_ZOMBIE_PAIN[][] = {
	"dg/ze3/zombie_pain_00.wav", "dg/ze3/zombie_pain_01.wav", "dg/ze3/zombie_pain_02.wav", "dg/ze3/zombie_pain_03.wav", "dg/ze3/zombie_pain_04.wav"
};
new const __SOUND_ZOMBIE_CLAW_SLASH[] = "dg/ze3/zombie_claw_slash_00.wav";
new const __SOUND_ZOMBIE_CLAW_WALL[][] = {
	"dg/ze3/zombie_claw_wall_00.wav", "dg/ze3/zombie_claw_wall_01.wav"
};
new const __SOUND_ZOMBIE_CLAW_HIT[][] = {
	"dg/ze3/zombie_claw_hit_00.wav", "dg/ze3/zombie_claw_hit_01.wav", "dg/ze3/zombie_claw_hit_02.wav"
};
new const __SOUND_ZOMBIE_CLAW_STAB[] = "dg/ze3/zombie_claw_stab_00.wav";
new const __SOUND_ZOMBIE_DIE[][] = {
	"dg/ze3/zombie_die_00.wav", "dg/ze3/zombie_die_01.wav", "dg/ze3/zombie_die_02.wav"
};
new const __SOUND_ZOMBIE_ALERT[][] = {
	"dg/ze3/zombie_alert_00.wav", "dg/ze3/zombie_alert_01.wav", "dg/ze3/zombie_alert_02.wav"
};
new const __SOUND_ZOMBIE_INFECT[][] = {
	"dg/ze3/zombie_infect_00.wav", "dg/ze3/zombie_infect_01.wav", "dg/ze3/zombie_infect_02.wav"
};
new const __SOUND_ZOMBIE_MADNESS[] = "dg/ze3/zombie_madness_00.wav";
new const __SOUND_ZOMBIE_BANSHEE[][] = {
	"zombie_plague/zombi_banshee_pulling_fire.wav", "zombie_plague/zombi_banshee_laugh.wav", "zombie_plague/zombi_banshee_pulling_fail.wav"
};
new const __SOUND_ZOMBIE_FARAHON[][] = {
	"zombie_plague/husk_fireball_fire.wav", "zombie_plague/husk_fireball_loop.wav", "zombie_plague/husk_fireball_explode.wav", "zombie_plague/husk_pre_fire.wav", "zombie_plague/husk_wind_down.wav"
};
new const __SOUND_ZOMBIE_TOXIC[][] = {
	"bullchicken/bc_spithit2.wav", "zombie_plague/spitter_spit.wav"
};
new const __SOUND_ZOMBIE_LUSTYROSA_ACTIVE[] = "zombie_plague/lustyrosa_active_00.wav";
new const __SOUND_NEMESIS_PAIN[][] = {
	"dg/ze3/nemesis_pain_00.wav", "dg/ze3/nemesis_pain_01.wav", "dg/ze3/nemesis_pain_02.wav", "dg/ze3/nemesis_pain_03.wav", "dg/ze3/nemesis_pain_04.wav"
};
new const __SOUND_ROCKET_00[] = "weapons/rocketfire1.wav";
new const __SOUND_ROCKET_01[] = "weapons/mortarhit.wav";
new const __SOUND_ROCKET_02[] = "weapons/c4_explode1.wav";
new const __SOUND_GRENADE_INFECT[] = "dg/ze3/grenade_infect_00.wav";
new const __SOUND_GRENADE_FIRE[] = "dg/ze3/grenade_fire_00.wav";
new const __SOUND_GRENADE_FROST[] = "dg/ze3/grenade_frost_00.wav";
new const __SOUND_GRENADE_FROST_BREAK[] = "dg/ze3/grenade_frost_break_00.wav";
new const __SOUND_GRENADE_FROST_PLAYER[] = "dg/ze3/grenade_frost_player_00.wav";
new const __SOUND_GRENADE_EXPLODE[] = "weapons/he_bounce-1.wav";
new const __SOUND_GRENADE_BUBBLE[] = "buttons/button1.wav";
new const __SOUND_LEVEL_UP[] = "dg/ze3/level_up.wav";
new const __SOUND_COUNTDOWN[][] = {
	"dg/ze3/vox/biohazard_detected.wav",
	"dg/ze3/vox/one.wav",
	"dg/ze3/vox/two.wav",
	"dg/ze3/vox/three.wav",
	"dg/ze3/vox/four.wav",
	"dg/ze3/vox/five.wav"
};

new const __SKIES_TYPES[][] = {
	"bk.tga", "dn.tga", "ft.tga", "lf.tga", "rt.tga", "up.tga"
};
new const __SKIES[][] = {
	"jungle"
};

new g_PlayerSteamId[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new g_PlayerName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_PlayerIp[MAX_PLAYERS + 1][MAX_IP_LENGTH];
new g_PlayerModel[MAX_PLAYERS + 1][32];
new g_PlayerClassName[MAX_PLAYERS + 1][32];
new g_IsConnected[MAX_PLAYERS + 1];
new g_IsAlive[MAX_PLAYERS + 1];
new g_AccountLoading[MAX_PLAYERS + 1];
new g_AccountLoading_Steps[MAX_PLAYERS + 1];
new g_AccountLoading_MaxSteps[MAX_PLAYERS + 1];
new g_AccountId[MAX_PLAYERS + 1];
new g_AccountIp[MAX_PLAYERS + 1][16];
new g_AccountPassword[MAX_PLAYERS + 1][34];
new g_AccountAutologin[MAX_PLAYERS + 1];
new g_AccountVinc[MAX_PLAYERS + 1];
new g_AccountVincMail[MAX_PLAYERS + 1][128];
new g_AccountVincPassword[MAX_PLAYERS + 1][128];
new g_AccountVincAppMobile[MAX_PLAYERS + 1];
new g_AccountRegister[MAX_PLAYERS + 1];
new g_AccountRegistering[MAX_PLAYERS + 1];
new g_AccountBanned[MAX_PLAYERS + 1];
new g_AccountBanned_StaffName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_AccountBanned_Start[MAX_PLAYERS + 1];
new g_AccountBanned_Finish[MAX_PLAYERS + 1];
new g_AccountBanned_Reason[MAX_PLAYERS + 1][128];
new g_AccountLogged[MAX_PLAYERS + 1];
new g_AccountJoined[MAX_PLAYERS + 1];
new g_AccountRanking[MAX_PLAYERS + 1];
new g_Health[MAX_PLAYERS + 1];
new g_MaxHealth[MAX_PLAYERS + 1];
new Float:g_Speed[MAX_PLAYERS + 1];
new g_ZombieBack[MAX_PLAYERS + 1];
new g_Zombie[MAX_PLAYERS + 1];
new g_SpecialMode[MAX_PLAYERS + 1];
new g_RespawnAsZombie[MAX_PLAYERS + 1];
new g_FirstZombie[MAX_PLAYERS + 1];
new g_LastZombie[MAX_PLAYERS + 1];
new g_LastHuman[MAX_PLAYERS + 1];
new g_LastHuman_1000hp[MAX_PLAYERS + 1];
new g_HumanClass[MAX_PLAYERS + 1];
new g_HumanClass_Medico[MAX_PLAYERS + 1];
new g_HumanClass_MedicoActive[MAX_PLAYERS + 1];
new g_HumanClassNext[MAX_PLAYERS + 1];
new g_ZombieClass[MAX_PLAYERS + 1];
new g_ZombieClass_Voodoo[MAX_PLAYERS + 1];
new g_ZombieClass_LustyRose[MAX_PLAYERS + 1];
new g_ZombieClass_LustyRoseActive[MAX_PLAYERS + 1];
new Float:g_ZombieClass_FarahonLastTime[MAX_PLAYERS + 1];
new g_ZombieClass_Fleshpound[MAX_PLAYERS + 1];
new g_ZombieClass_FleshpoundActive[MAX_PLAYERS + 1];
new Float:g_ZombieClass_ToxicoLastTime[MAX_PLAYERS + 1];
new g_ZombieClass_Banshee[MAX_PLAYERS + 1];
new g_ZombieClass_BansheeActive[MAX_PLAYERS + 1];
new g_ZombieClass_BansheeStat[MAX_PLAYERS + 1];
new g_ZombieClass_BansheeOwner[MAX_PLAYERS + 1];
new g_ZombieClassNext[MAX_PLAYERS + 1];
new g_SurvivorClass[MAX_PLAYERS + 1];
new g_SurvivorClassNext[MAX_PLAYERS + 1];
new g_NemesisClass[MAX_PLAYERS + 1];
new g_NemesisClassNext[MAX_PLAYERS + 1];
new Float:g_LongJump_LastTime[MAX_PLAYERS + 1];
new g_CurrentWeapon[MAX_PLAYERS + 1];
new g_TypeWeapon[MAX_PLAYERS + 1];
new g_Weapons[MAX_PLAYERS + 1][structIdWeapons];
new g_BubbleBomb[MAX_PLAYERS + 1];
new g_InBubble[MAX_PLAYERS + 1];
new g_Immunity[MAX_PLAYERS + 1];
new g_ImmunityBombs[MAX_PLAYERS + 1];
new g_ImmunityFire[MAX_PLAYERS + 1];
new g_ImmunityFrost[MAX_PLAYERS + 1];
new g_Burning_Duration[MAX_PLAYERS + 1];
new g_Frozen[MAX_PLAYERS + 1];
new Float:g_FrozenGravity[MAX_PLAYERS + 1];
new g_Skin[MAX_PLAYERS + 1];
new g_Skin_Choosed[MAX_PLAYERS + 1];
new g_Skin_Unlocked[MAX_PLAYERS + 1][sizeof(__SKINS)];
new g_Skin_UnlockedTimeStamp[MAX_PLAYERS + 1][sizeof(__SKINS)];
new Float:g_Skin_GameTime[MAX_PLAYERS + 1];
new g_Knife[MAX_PLAYERS + 1];
new g_Knife_Choosed[MAX_PLAYERS + 1];
new g_Knife_Unlocked[MAX_PLAYERS + 1][sizeof(__KNIFES)];
new g_Knife_UnlockedTimeStamp[MAX_PLAYERS + 1][sizeof(__KNIFES)];
new Float:g_Knife_GameTime[MAX_PLAYERS + 1];
new g_Hat[MAX_PLAYERS + 1];
new g_Hat_Choosed[MAX_PLAYERS + 1];
new g_Hat_Unlocked[MAX_PLAYERS + 1][sizeof(__HATS)];
new g_Hat_UnlockedTimeStamp[MAX_PLAYERS + 1][sizeof(__HATS)];
new Float:g_Hat_GameTime[MAX_PLAYERS + 1];
new g_Achievement[MAX_PLAYERS + 1][structIdAchievements];
new g_Achievement_UnlockedPlayerName[MAX_PLAYERS + 1][structIdAchievements][MAX_NAME_LENGTH];
new g_Achievement_UnlockedTimeStamp[MAX_PLAYERS + 1][structIdAchievements];
new Float:g_Achievement_GameTime[MAX_PLAYERS + 1];
new g_InGroup[MAX_PLAYERS + 1];
new g_GroupInvitations[MAX_PLAYERS + 1];
new g_GroupInvitationsId[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_MyGroup[MAX_PLAYERS + 1];
new g_GroupId[14][4];
new g_ClanSlot[MAX_PLAYERS + 1];
new g_Clan[33][structClans];
new g_ClanMembers[33][MAX_CLAN_MEMBERS][structClansMembers];
new g_ClanInvitations[MAX_PLAYERS + 1];
new g_ClanInvitationsId[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_TempClanName[MAX_PLAYERS + 1][15];
new g_TempClanDeposit[MAX_PLAYERS + 1];
new Float:g_Clan_QueryFlood[MAX_PLAYERS + 1];
new g_UserOptions_Color[MAX_PLAYERS + 1][structIdColorTypes][3];
new Float:g_UserOptions_Hud[MAX_PLAYERS + 1][structIdHudTypes][3];
new g_UserOptions_HudEffect[MAX_PLAYERS + 1][structIdHudTypes];
new g_UserOptions_HudStyle[MAX_PLAYERS + 1][structIdHudTypes];
new g_UserOptions_Invis[MAX_PLAYERS + 1];
new g_UserOptions_ClanChat[MAX_PLAYERS + 1];
new g_UserOptions_GlowInGroup[MAX_PLAYERS + 1];
new g_APs[MAX_PLAYERS + 1];
new Float:g_APsDamage[MAX_PLAYERS + 1];
new g_APsRewardKill[MAX_PLAYERS + 1];
new g_APsRewardDamage[MAX_PLAYERS + 1];
new g_APsRewradInfect[MAX_PLAYERS + 1];
new g_XP[MAX_PLAYERS + 1];
new g_XPRest[MAX_PLAYERS + 1];
new Float:g_XPDamage[MAX_PLAYERS + 1];
new g_Level[MAX_PLAYERS + 1];
new Float:g_LevelPercent[MAX_PLAYERS + 1];
new g_Range[MAX_PLAYERS + 1];
new g_Points[MAX_PLAYERS + 1];
new g_PointsLose[MAX_PLAYERS + 1];
new g_Stats[MAX_PLAYERS + 1][structIdStats];
new g_StatsRound_SupplyBoxDone[MAX_PLAYERS + 1];
new g_TimePlayed[MAX_PLAYERS + 1][structIdTimePlayed];
new g_SysTime_Top15[MAX_PLAYERS + 1];
new g_MenuPage[MAX_PLAYERS + 1][structIdMenuPages];
new g_MenuData[MAX_PLAYERS + 1][structIdMenuDatas];
new g_UserBullet[MAX_PLAYERS + 1];
new g_AmbienceSound_Muted[MAX_PLAYERS + 1];
new g_Camera[MAX_PLAYERS + 1];
new g_Escaped[MAX_PLAYERS + 1];
new g_Buttoned[MAX_PLAYERS + 1];
new g_Breakabled[MAX_PLAYERS + 1];
new g_Secret_AlreadySayCrazy[MAX_PLAYERS + 1];
new g_MadnessBomb[MAX_PLAYERS + 1];
new g_MadnessBomb_Count[MAX_PLAYERS + 1];
new g_MadnessBomb_Move[MAX_PLAYERS + 1];
new g_ExtraItem_InRound[MAX_PLAYERS + 1][structIdExtraItem];
new g_NVision[MAX_PLAYERS + 1];
new g_BuyStuff[MAX_PLAYERS + 1];
new g_ModeJeruzalem_RewardExp[MAX_PLAYERS + 1];
new g_VIPsKilled[MAX_PLAYERS + 1];

new g_MapName[32];
new g_fwdSpawn;
new g_fwdPrecacheSound;
new g_fwdRoundStarted;
new g_fwdUserInfectedPost;
new g_fwdHUserdumanizedPost;
new g_fwdDummy;
new g_Sprite_Laserbeam;
new g_Sprite_Flame;
new g_Sprite_Smoke;
new g_Sprite_FrostExplode;
new g_Sprite_Explode;
new g_Sprite_Glass;
new g_Sprite_Shockwave;
new g_Sprite_Health;
new g_Sprite_Bat;
new g_Sprite_Toxico;
new Handle:g_SqlTuple;
new Handle:g_SqlConnection;
new g_SqlQuery[1024];
new g_GlobalRank;
new g_Message_Money;
new g_Message_FlashBat;
new g_Message_Flashlight;
new g_Message_NVGToggle;
new g_Message_WeapPickup;
new g_Message_AmmoPickup;
new g_Message_TextMsg;
new g_Message_SendAudio;
new g_Message_TeamScore;
new g_Message_StatusIcon;
new g_Message_Fov;
new g_Message_ScreenFade;
new g_Message_ScreenShake;
new g_Message_DeathMsg;
new g_Message_ScoreInfo;
new g_Message_ScoreAttrib;
new g_Message_BarTime;
new g_HudSync_CountDown;
new g_HudSync_Damage;
new g_HudSync_Event;
new g_HudSync_Player;
new g_HudSync_General;
new g_HudSync_ZombiePower;
new g_pCvar_Delay;
new Float:g_Spawns[64][3];
new g_SpawnCount;
// new g_FirstRound;
new g_ScoreHumans = 0;
new g_ScoreZombies = 0;
new g_CountDown;
new g_NewRound;
new g_EndRound;
new g_EndRound_Forced;
new g_Mode;
new g_CurrentMode;
new g_NextMode;
new g_LastMode;
new g_AmbienceSounds[structIdAmbienceSounds];
new g_HappyHour;
new g_EventModes;
new g_EventMode_Count = 0;
new g_ExtraItem_InfectionBomb;
new g_ExtraItem_UnlimitedClipOn;
new g_ExtraItem_BubbleBomb;
new g_ExtraItem_MadnessBomb;
new g_LeaderType = 0;
new g_LeaderLevel_Name[MAX_NAME_LENGTH];
new g_LeaderLevel_Level;
new g_LeaderLevel_Exp[16];
new g_LeaderTime_Name[MAX_NAME_LENGTH];
new g_LeaderTime_Time[structIdTimePlayed];
new g_LeaderAchievement_Name[MAX_NAME_LENGTH];
new g_LeaderAchievement_Total[8];
new g_Link_AchievementId = -1;
new g_Link_AchievementClass;
new g_Secret_CrazyMode_Enabled = 0;
new g_Secret_CrazyMode;
new g_Secret_CrazyMode_Count;
new g_Secret_NextCrazyMode;
new g_SupplyBox_File[128];
new g_SupplyBox[MAX_SUPPLYBOX];
new g_SupplyBox_Ent[MAX_SUPPLYBOX];
new Float:g_SupplyBox_Origin[MAX_SUPPLYBOX][3];
new Float:g_SupplyBox_Angles[MAX_SUPPLYBOX][3];
new g_SupplyBox_Total = 0;
new g_SupplyBox_ShowTotal = 0;
new g_ModeCount[structIdModes];
new g_ModeCountAdmin[structIdModes];
new g_DataSaved = 0;
new g_Achievement_ValentinaTeAmo;
new g_ExtraItem_InMap[structIdExtraItem];
new g_Restore;
new g_MapEscaped;
new g_AutoMode_Jeruzalem_RoundsLeft = 1337;
new g_AutoMode_Jeruzalem_Count = 1337;
new g_AutoMode_Jeruzalem_Enabled;
new g_ModeJeruzalem_AlreadyRewarded;
new g_VIPsDead;

#define isUserValid(%0) (1 <= %0 <= MaxClients)
#define isUserValidConnected(%0) (isUserValid(%0) && g_IsConnected[%0])
#define isUserValidAlive(%0) (isUserValid(%0) && g_IsAlive[%0])

public plugin_precache() {
	get_mapname(g_MapName, charsmax(g_MapName));
	strtolower(g_MapName);

	register_forward(FM_Sys_Error, "fwd__SysErrorPre", 0);
	register_forward(FM_GameShutdown, "fwd__GameShutdownPre", 0);

	new iEnt;
	new sBuffer[160];
	new i;
	new j;

	for(i = 0; i < sizeof(__PRIMARY_WEAPONS); ++i) {
		if(__PRIMARY_WEAPONS[i][weaponModel][0]) {
			precache_model(__PRIMARY_WEAPONS[i][weaponModel]);
		}
	}

	for(i = 0; i < sizeof(__SECONDARY_WEAPONS); ++i) {
		if(__SECONDARY_WEAPONS[i][weaponModel][0]) {
			precache_model(__SECONDARY_WEAPONS[i][weaponModel]);
		}
	}

	for(i = 0; i < structIdZombieClasses; ++i) {
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", __ZOMBIE_CLASSES[i][zombieClassModel], __ZOMBIE_CLASSES[i][zombieClassModel]);
		precache_model(sBuffer);

		copy(sBuffer[strlen(sBuffer) - 4], charsmax(sBuffer) - (strlen(sBuffer) - 4), "T.mdl");
		
		if(file_exists(sBuffer)) {
			precache_model(sBuffer);
		}

		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", __ZOMBIE_CLASSES[i][zombieClassModel], __ZOMBIE_CLASSES[i][zombieClassModel]);
		precache_model(sBuffer);

		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s_power.mdl", __ZOMBIE_CLASSES[i][zombieClassModel], __ZOMBIE_CLASSES[i][zombieClassModel]);
		
		if(file_exists(sBuffer)) {
			precache_model(sBuffer);
		}
	}

	for(i = 0; i < sizeof(__SKINS); ++i) {
		if(__SKINS[i][skinModelName][0]) {
			formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", __SKINS[i][skinModelName], __SKINS[i][skinModelName]);
			precache_model(sBuffer);

			copy(sBuffer[strlen(sBuffer) - 4], charsmax(sBuffer) - (strlen(sBuffer) - 4), "T.mdl");
			
			if(file_exists(sBuffer)) {
				precache_model(sBuffer);
			}
		}
	}

	for(i = 0; i < sizeof(__KNIFES); ++i) {
		if(__KNIFES[i][knifeModelNameV][0]) {
			precache_model(__KNIFES[i][knifeModelNameV]);
		}

		if(__KNIFES[i][knifeModelNameP][0]) {
			precache_model(__KNIFES[i][knifeModelNameP]);
		}
	}

	for(i = 0; i < sizeof(__HATS); ++i) {
		if(__HATS[i][hatModelName][0]) {
			precache_model(__HATS[i][hatModelName]);
		}
	}

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", __PLAYER_MODEL_HUMAN, __PLAYER_MODEL_HUMAN);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%sT.mdl", __PLAYER_MODEL_HUMAN, __PLAYER_MODEL_HUMAN);
	if(file_exists(sBuffer)) {
		precache_model(sBuffer);
	}

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", __PLAYER_MODEL_SURVIVOR, __PLAYER_MODEL_SURVIVOR);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", __PLAYER_MODEL_NEMESIS, __PLAYER_MODEL_NEMESIS);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", __PLAYER_MODEL_NEMESIS, __PLAYER_MODEL_NEMESIS);
	precache_model(sBuffer);

	formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", __PLAYER_MODEL_JERUZALEM_VIP, __PLAYER_MODEL_JERUZALEM_VIP);
	precache_model(sBuffer);

	precache_model("models/rpgrocket.mdl");
	precache_model(__WEAPON_MODEL_SURVIVOR_V);
	precache_model(__WEAPON_MODEL_SURVIVOR_P);
	precache_model(__WEAPON_MODEL_BAZOOKA_V);
	precache_model(__WEAPON_MODEL_BAZOOKA_P);
	precache_model(__GRENADE_MODEL_INFECTION_V);
	precache_model(__GRENADE_MODEL_INFECTION_P);
	precache_model(__GRENADE_MODEL_FIRE_V);
	precache_model(__GRENADE_MODEL_FROST_V);
	precache_model(__GRENADE_MODEL_EXPLOSIVE_V);
	precache_model(__GRENADE_MODEL_MADNESS_V);
	precache_model(__GRENADE_MODEL_BUBBLE_V);
	precache_model(__GRENADE_MODEL_BUBBLE_W);
	precache_model(__MODEL_ROCKET);
	precache_model(__MODEL_FROST);
	precache_model(__MODEL_BUBBLE);
	precache_model(__MODEL_SUPPLYBOX);
	precache_model(__MODEL_BANSHEE);
	precache_model(__MODEL_FARAHON);
	precache_model(__MODEL_SPIT);

	precache_sound(__SOUND_AMMOPICKUP);
	precache_sound(__SOUND_ANTIDOTE);
	precache_sound(__SOUND_AMMO_PICKUP);
	precache_sound(__SOUND_WIN_HUMANS);
	precache_sound(__SOUND_WIN_ZOMBIES);
	precache_sound(__SOUND_WIN_NO_ONE);
	for(i = 0; i < sizeof(__SOUND_ROUND_GENERAL); ++i) {
		precache_sound(__SOUND_ROUND_GENERAL[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ROUND_MODES); ++i) {
		precache_sound(__SOUND_ROUND_MODES[i]);
	}
	precache_sound(__SOUND_ROUND_ARMAGEDDON);
	for(i = 0; i < structIdAmbienceSounds; ++i) {
		if(__SOUND_AMBIENCE[i][0]) {
			g_AmbienceSounds[i] = 1;
			precache_generic(__SOUND_AMBIENCE[i]);
		}
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_PAIN); ++i) {
		precache_sound(__SOUND_ZOMBIE_PAIN[i]);
	}
	precache_sound(__SOUND_ZOMBIE_CLAW_SLASH);
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_CLAW_WALL); ++i) {
		precache_sound(__SOUND_ZOMBIE_CLAW_WALL[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_CLAW_HIT); ++i) {
		precache_sound(__SOUND_ZOMBIE_CLAW_HIT[i]);
	}
	precache_sound(__SOUND_ZOMBIE_CLAW_STAB);
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_DIE); ++i) {
		precache_sound(__SOUND_ZOMBIE_DIE[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_ALERT); ++i) {
		precache_sound(__SOUND_ZOMBIE_ALERT[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_INFECT); ++i) {
		precache_sound(__SOUND_ZOMBIE_INFECT[i]);
	}
	precache_sound(__SOUND_ZOMBIE_MADNESS);
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_BANSHEE); ++i) {
		precache_sound(__SOUND_ZOMBIE_BANSHEE[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_FARAHON); ++i) {
		precache_sound(__SOUND_ZOMBIE_FARAHON[i]);
	}
	for(i = 0; i < sizeof(__SOUND_ZOMBIE_TOXIC); ++i) {
		precache_sound(__SOUND_ZOMBIE_TOXIC[i]);
	}
	precache_sound(__SOUND_ZOMBIE_LUSTYROSA_ACTIVE);
	for(i = 0; i < sizeof(__SOUND_NEMESIS_PAIN); ++i) {
		precache_sound(__SOUND_NEMESIS_PAIN[i]);
	}
	precache_sound(__SOUND_ROCKET_00);
	precache_sound(__SOUND_ROCKET_01);
	precache_sound(__SOUND_ROCKET_02);
	precache_sound(__SOUND_GRENADE_INFECT);
	precache_sound(__SOUND_GRENADE_FIRE);
	precache_sound(__SOUND_GRENADE_FROST);
	precache_sound(__SOUND_GRENADE_FROST_BREAK);
	precache_sound(__SOUND_GRENADE_FROST_PLAYER);
	precache_sound(__SOUND_GRENADE_EXPLODE);
	precache_sound(__SOUND_GRENADE_BUBBLE);
	precache_sound(__SOUND_LEVEL_UP);
	for(i = 0; i < sizeof(__SOUND_COUNTDOWN); ++i) {
		precache_sound(__SOUND_COUNTDOWN[i]);
	}

	g_Sprite_Laserbeam = precache_model("sprites/dg/ze3/laserbeam_00.spr");
	g_Sprite_Flame = precache_model("sprites/dg/ze3/flame_00.spr");
	g_Sprite_Smoke = precache_model("sprites/black_smoke3.spr");
	g_Sprite_FrostExplode = precache_model("sprites/dg/ze3/frostexplode_00.spr");
	g_Sprite_Explode = precache_model("sprites/fexplo.spr");
	g_Sprite_Glass = precache_model("models/glassgibs.mdl");
	g_Sprite_Shockwave = precache_model("sprites/shockwave.spr");
	g_Sprite_Health = precache_model("sprites/zb3/zp_restore_health.spr");
	g_Sprite_Bat = precache_model("sprites/ef_bat.spr");
	g_Sprite_Toxico = precache_model("sprites/bubble.spr");

	for(i = 0; i < sizeof(__SKIES_TYPES); ++i) {
		for(j = 1; j < sizeof(__SKIES); ++j) {
			formatex(sBuffer, charsmax(sBuffer), "gfx/env/%s%s", __SKIES[j], __SKIES_TYPES[i]);
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
		DispatchKeyValue(iEnt, "density", "0.0003");
		DispatchKeyValue(iEnt, "rendercolor", "151 154 154");
	}

	g_fwdSpawn = register_forward(FM_Spawn, "fwd__SpawnPre", 0);
	g_fwdPrecacheSound = register_forward(FM_PrecacheSound, "fwd__PrecacheSoundPre", 0);
}

public plugin_natives() {
	register_native("zp_get_user_zombie", "native__GetUserZombie", 1);
	register_native("zp_get_user_specialmode", "native__GetUserSpecialMode", 1);
	register_native("zp_has_round_started", "native__HasRoundStarted", 1);
}

public native__GetUserZombie(const id) {
	return g_Zombie[id];
}

public native__GetUserSpecialMode(const id) {
	return g_SpecialMode[id];
}

public native__HasRoundStarted() {
	if(g_NewRound) {
		return 0;
	} else if(g_Mode) {
		return 1;
	}

	return 2;
}

public plugin_init() {
	if(g_MapName[0] != 'z' && g_MapName[1] != 'e' && g_MapName[2] == '_') {
		set_fail_state("El mapa especificado no es válido. Los mapas válidos empiezan con ze_");
		return;
	}

	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	RegisterHookChain(RG_CSGameRules_RestartRound, "onGameRules__RestartRoundPre", false);

	RegisterHookChain(RG_ThrowHeGrenade, "onGrenade__ThrowHeGrenadePre", false);
	RegisterHookChain(RG_ThrowSmokeGrenade, "onGrenade__ThrowSmokeGrenadePre", false);

	RegisterHookChain(RG_RoundEnd, "onGameRules__RoundEndPost", true);
	RegisterHookChain(RG_ShowMenu, "onClient__ShowMenuPre", false);
	RegisterHookChain(RG_ShowVGUIMenu, "onClient__ShowVGUIMenuPre", false);
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "onClient__HandleMenuChooseTeamPre", false);

	register_event("30", "event__Intermission", "a");
	register_event("AmmoX", "event__AmmoX", "be");
	register_event("Health", "event__Health", "be");
	register_event("StatusValue", "event__ShowStatus", "be", "1=2", "2!0");
	register_event("StatusValue", "event__HideStatus", "be", "1=1", "2=0");
	register_event("HideWeapon", "event__HideWeapon", "b");

	register_forward(FM_ClientDisconnect, "fwd__ClientDisconnectPost", 1);
	register_forward(FM_ClientKill, "fwd__ClientKillPre", 0);
	// register_forward(FM_SetClientKeyValue, "fwd__SetClientKeyValuePre", 0);
	// register_forward(FM_ClientUserInfoChanged, "fwd__ClientUserInfoChangedPre", 0);
	register_forward(FM_EmitSound, "fwd__EmitSoundPre", 0);
	register_forward(FM_SetModel, "fwd__SetModelPre", 0);
	register_forward(FM_AddToFullPack, "fwd__AddToFullPackPost", 1);
	register_forward(FM_CmdStart, "fwd__CmdStartPre", 0);
	unregister_forward(FM_Spawn, g_fwdSpawn);
	unregister_forward(FM_PrecacheSound, g_fwdPrecacheSound);

	RegisterHam(Ham_Spawn, "player", "ham__PlayerSpawnPost", 1);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPre", 0);
	RegisterHam(Ham_Killed, "player", "ham__PlayerKilledPost", 1);
	RegisterHam(Ham_TakeDamage, "player", "ham__PlayerTakeDamagePre", 0);
	RegisterHam(Ham_TakeDamage, "player", "ham__PlayerTakeDamagePost", 1);
	RegisterHam(Ham_TraceAttack, "player", "ham__PlayerTraceAttackPre", 0);
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "ham__PlayerResetMaxSpeedPost", 1);
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
	RegisterHam(Ham_Player_PreThink, "player", "ham__PlayerPreThinkPre", 0);

	for(new i = 1; i < sizeof(__WEAPON_ENTNAME_LIST); ++i) {
		if(__WEAPON_ENTNAME_LIST[i][0]) {
			if(i != CSW_HEGRENADE && i != CSW_C4 && i != CSW_SMOKEGRENADE && i != CSW_G3SG1 && i != CSW_SG550 && i != CSW_FLASHBANG) {
				RegisterHam(Ham_Weapon_PrimaryAttack, __WEAPON_ENTNAME_LIST[i], "ham__WeaponPrimaryAttackPost", 1);
			}

			if(i == CSW_SG550 || i == CSW_G3SG1) {
				RegisterHam(Ham_Weapon_SecondaryAttack, __WEAPON_ENTNAME_LIST[i], "ham__AutomaticWeaponZoom", 0);
			}

			RegisterHam(Ham_Item_Deploy, __WEAPON_ENTNAME_LIST[i], "ham__ItemDeployPost", 1);
		}
	}

	fixWeaponOnSemiclip();

	RegisterHam(Ham_Touch, "trigger_multiple", "ham__TouchZoneEscapePost", 1);
	RegisterHam(Ham_Use, "func_button", "ham__UseButtonPre", 0);
	RegisterHam(Ham_TakeDamage, "func_breakable", "ham__BreakableTakeDamagePost", 1);

	register_touch("trigger_hurt", "player", "touch__TriggerHurt");
	register_touch(__ENT_CLASSNAME_SUPPLYBOX, "player", "touch__Supplybox");
	register_touch(__ENT_CLASSNAME_FARAHON, "*", "touch__Farahon");
	register_touch(__ENT_CLASSNAME_TOXICO, "*", "touch__Toxico");
	register_touch(__ENT_CLASSNAME_BANSHEE, "*", "touch__Banshee");
	register_think(__ENT_CLASSNAME_BANSHEE, "think__Banshee");

	register_clcmd("CREAR_CUENTA", "clcmd__CreateAccount");
	register_clcmd("CONFIRMAR_CUENTA", "clcmd__ConfirmAccount");
	register_clcmd("IDENTIFICAR_CUENTA", "clcmd__EnterAccount");
	register_clcmd("CREAR_CLAN", "clcmd__CreateClan");
	register_clcmd("V_INGRESAR_MAIL", "clcmd__VEnterMail");
	register_clcmd("V_INGRESAR_CLAVE", "clcmd__VEnterPassword");

	register_clcmd("say /game", "clcmd__Game");
	register_clcmd("say /cam", "clcmd__Cam");
	register_clcmd("say /crazy", "clcmd__Crazy");
	register_clcmd("say /hh", "clcmd__DrunkAtNite");
	register_clcmd("say /dan", "clcmd__DrunkAtNite");
	register_clcmd("say /invis", "clcmd__Invis");
	register_clcmd("say /top15", "clcmd__Top15");
	register_clcmd("say /nextmode", "clcmd__NextModeSay");
	register_clcmd("say /modo", "clcmd__NextModeSay");
	register_clcmd("say /spect", "clcmd__Spect");

	for(new i = 0; i < sizeof(__BLOCK_COMMANDS); ++i) {
		register_clcmd(__BLOCK_COMMANDS[i], "clcmd__BlockCommand");
	}
	register_clcmd("radio1", "clcmd__Radio1");
	register_clcmd("nightvision", "clcmd__NVision");
	register_clcmd("say", "clcmd__Say");
	register_clcmd("say_team", "clcmd__SayTeam");

	register_clcmd("ze_test", "clcmd__Test");
	register_clcmd("ze_next_mode", "clcmd__NextMode");
	register_clcmd("ze_save_all", "clcmd__SaveAll");
	register_clcmd("ze_aps", "clcmd__APs");
	register_clcmd("ze_xp", "clcmd__XP");
	register_clcmd("ze_level", "clcmd__Level");
	register_clcmd("ze_points", "clcmd__Points");
	register_clcmd("ze_revive", "clcmd__Revive");
	register_clcmd("ze_modes", "clcmd__Modes");
	register_clcmd("ze_supplybox_add", "clcmd__SupplyBoxAdd");
	register_clcmd("ze_supplybox_remove", "clcmd__SupplyBoxRemove");
	register_clcmd("ze_supplybox_save", "clcmd__SupplyBoxSave");

	oldmenu_register();

	g_Message_Money = get_user_msgid("Money");
	g_Message_FlashBat = get_user_msgid("FlashBat");
	g_Message_Flashlight = get_user_msgid("Flashlight");
	g_Message_NVGToggle = get_user_msgid("NVGToggle");
	g_Message_WeapPickup = get_user_msgid("WeapPickup");
	g_Message_AmmoPickup = get_user_msgid("AmmoPickup");
	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SendAudio = get_user_msgid("SendAudio");
	g_Message_TeamScore = get_user_msgid("TeamScore");
	g_Message_StatusIcon = get_user_msgid("StatusIcon");
	g_Message_Fov = get_user_msgid("SetFOV");
	g_Message_ScreenFade = get_user_msgid("ScreenFade");
	g_Message_ScreenShake = get_user_msgid("ScreenShake");
	g_Message_DeathMsg = get_user_msgid("DeathMsg");
	g_Message_ScoreInfo = get_user_msgid("ScoreInfo");
	g_Message_ScoreAttrib = get_user_msgid("ScoreAttrib");
	g_Message_BarTime = get_user_msgid("BarTime");

	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET);

	register_message(g_Message_Money, "message__Money");
	register_message(g_Message_FlashBat, "message__FlashBat");
	register_message(g_Message_Flashlight, "message__Flashlight");
	register_message(g_Message_NVGToggle, "message__NVGToggle");
	register_message(g_Message_WeapPickup, "message__WeapPickup");
	register_message(g_Message_AmmoPickup, "message__AmmoPickup");
	register_message(g_Message_TextMsg, "message__TextMsg");
	register_message(g_Message_SendAudio, "message__SendAudio");
	register_message(g_Message_TeamScore, "message__TeamScore");
	register_message(g_Message_StatusIcon, "message__StatusIcon");

	register_impulse(IMPULSE_FLASHLIGHT, "impulse__Flashlight");
	register_impulse(IMPULSE_SPRAY, "impulse__Spray");

	g_pCvar_Delay = register_cvar("ze_delay", "7");

	new iEnt = create_entity("info_target");
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, __ENT_THINK_HUD);
		entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 1.0));

		register_think(__ENT_THINK_HUD, "think__Hud");
	}

	register_think(__ENT_THINK_FROST, "think__Frost");

	g_fwdRoundStarted = CreateMultiForward("zp_round_started", ET_IGNORE, FP_CELL, FP_CELL);
	g_fwdUserInfectedPost = CreateMultiForward("zp_user_infected_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	g_fwdHUserdumanizedPost = CreateMultiForward("zp_user_humanized_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);

	g_CurrentMode = MODE_INFECTION;
	g_NextMode = -1;

	set_cvar_string("sv_skyname", __SKIES[random_num(0, charsmax(__SKIES))]);

	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	g_HudSync_CountDown = CreateHudSyncObj();
	g_HudSync_Damage = CreateHudSyncObj();
	g_HudSync_Event = CreateHudSyncObj();
	g_HudSync_Player = CreateHudSyncObj();
	g_HudSync_General = CreateHudSyncObj();
	g_HudSync_ZombiePower = CreateHudSyncObj();

	loadSql();
	loadSpawns();
	createHats();
}

public loadSql() {
	arrayset(g_ModeCount, 0, structIdModes);
	arrayset(g_ModeCountAdmin, 0, structIdModes);

	new sData[128];
	SQL_SetAffinity("mysql");
	SQL_GetAffinity(sData, charsmax(sData));

	if(!equal(sData, "mysql")) {
		set_fail_state("loadSql() - No se pudo establecer la afinidad del driver SQL a MySQL.");
		return;
	}

	new iErrorNum;

	g_SqlTuple = SQL_MakeDbTuple("127.0.0.1", __SERVERS[SV_ZE][serverSqlUsername], __SERVERS[SV_ZE][serverSqlPassword], __SERVERS[SV_ZE][serverSqlDatabase]);
	g_SqlConnection = SQL_Connect(g_SqlTuple, iErrorNum, sData, charsmax(sData));

	if(g_SqlConnection == Empty_Handle) {
		set_fail_state("loadSql() - Error en la conexión a la base de datos - [%d] %s.", iErrorNum, sData);
		return;
	}

	loadQueries();
	set_task(0.5, "task__LoadConfigs");
	checkSupplyBox();
	checkAutoModeJeruzalem();
	checkCrazyMode();
}

public loadQueries() {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT COUNT(id) FROM ze3_accounts;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 1);
	} else if(SQL_NumResults(sqlQuery)) {
		g_GlobalRank = SQL_ReadResult(sqlQuery, 0);
		SQL_FreeHandle(sqlQuery);
	} else {
		g_GlobalRank = 0;
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM ze3_general WHERE id='1';");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 20);
	} else if(SQL_NumResults(sqlQuery)) {
		new sModeCount[256];
		SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "modes"), sModeCount, charsmax(sModeCount));
		stringToArray(sModeCount, g_ModeCount, structIdModes);

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT achievement_id, achievement_timestamp FROM ze3_achievements WHERE achievement_first='1';");
	
	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 000);
	} else if(SQL_NumResults(sqlQuery)) {
		new iAchievementId;
		
		while(SQL_MoreResults(sqlQuery)) {
			iAchievementId = SQL_ReadResult(sqlQuery, 0);
			
			g_Achievement[0][iAchievementId] = 1;
			g_Achievement_UnlockedTimeStamp[0][iAchievementId] = SQL_ReadResult(sqlQuery, 1);

			SQL_NextRow(sqlQuery);
		}
		
		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	g_LeaderType = 0;

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT ze3_accounts.name, ze3_pjs.level, ze3_pjs.exp FROM ze3_pjs LEFT JOIN ze3_accounts ON ze3_accounts.id=ze3_pjs.acc_id ORDER BY ze3_pjs.level DESC, ze3_pjs.exp DESC LIMIT 1;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 6);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_ReadResult(sqlQuery, 0, g_LeaderLevel_Name, charsmax(g_LeaderLevel_Name));
		g_LeaderLevel_Level = SQL_ReadResult(sqlQuery, 1);
		addDot(SQL_ReadResult(sqlQuery, 2), g_LeaderLevel_Exp, charsmax(g_LeaderLevel_Exp));

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT ze3_accounts.name, ze3_pjs_stats.time_played FROM ze3_pjs_stats LEFT JOIN ze3_accounts ON ze3_accounts.id=ze3_pjs_stats.acc_id ORDER BY ze3_pjs_stats.time_played DESC LIMIT 1;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 7);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_ReadResult(sqlQuery, 0, g_LeaderTime_Name, charsmax(g_LeaderTime_Name));
		g_LeaderTime_Time[TIME_PLAYED_MIN] = SQL_ReadResult(sqlQuery, 1);

		if(g_LeaderTime_Time[TIME_PLAYED_MIN] >= 60) {
			new iHour = (g_LeaderTime_Time[TIME_PLAYED_MIN] / 60);
			new iDay = 0;

			while(iHour >= 24) {
				++iDay;
				iHour -= 24;
			}

			g_LeaderTime_Time[TIME_PLAYED_HOUR] = iHour;
			g_LeaderTime_Time[TIME_PLAYED_DAY] = iDay;
		} else {
			g_LeaderTime_Time[TIME_PLAYED_HOUR] = 0;
			g_LeaderTime_Time[TIME_PLAYED_DAY] = 0;
		}

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT ze3_accounts.name, ze3_pjs_stats.achievements_done FROM ze3_pjs_stats LEFT JOIN ze3_accounts ON ze3_accounts.id=ze3_pjs_stats.acc_id ORDER BY ze3_pjs_stats.achievements_done DESC LIMIT 1;");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 8);
	} else if(SQL_NumResults(sqlQuery)) {
		SQL_ReadResult(sqlQuery, 0, g_LeaderAchievement_Name, charsmax(g_LeaderAchievement_Name));
		addDot(SQL_ReadResult(sqlQuery, 1), g_LeaderAchievement_Total, charsmax(g_LeaderAchievement_Total));

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	new iEnt = create_entity("info_target");
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, __ENT_THINK_LEADERS);
		entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 300.0));

		register_think(__ENT_THINK_LEADERS, "think__Tops");
	}
}

public think__Tops(const ent) {
	switch(g_LeaderType) {
		case 0: {
			clientPrintColor(0, _, "!t%s!y es el líder en el ranking siendo !gnivel %d!y con !g%s de XP!y", g_LeaderLevel_Name, g_LeaderLevel_Level, g_LeaderLevel_Exp);
		} case 1: {
			clientPrintColor(0, _, "!t%s!y es el líder en tiempo jugado con !g%s!y", g_LeaderTime_Name, getLeaderPlayingTime());
		} case 2: {
			clientPrintColor(0, _, "!t%s!y es el líder en logros completados con !g+%d!y", g_LeaderAchievement_Name, g_LeaderAchievement_Total);
		}
	}

	++g_LeaderType;

	if(g_LeaderType == 3) {
		g_LeaderType = 0;
	}

	entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 300.0));
}

public executeQuery(const id, const Handle:query, const query_id) {
	new sErrors[MAX_FMT_LENGTH];
	SQL_QueryError(query, sErrors, charsmax(sErrors));
	log_to_file(__SQL_FILE, "executeQuery() - [%d] - <%s>", query_id, sErrors);

	if(isUserValidConnected(id)) {
		g_AccountRegister[id] = 0;
		g_AccountLogged[id] = 0;
		g_AccountJoined[id] = 0;

		server_cmd("kick #%d ^"Hubo un error al guardar/cargar tus datos. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(id));
	}

	SQL_FreeHandle(query);
}

public task__LoadConfigs() {
	server_cmd("hostname ^"#01 ZOMBIE ESCAPE [%s] | www.DrunkGaming.net^"", __PLUGIN_VERSION);

	set_cvar_num("allow_spectators", 1);
	set_cvar_num("sv_alltalk", 1);
	set_cvar_string("sv_voicecodec", "voice_speex");
	set_cvar_num("sv_voicequality", 5);
	set_cvar_num("sv_airaccelerate", 100);
	set_cvar_num("sv_voiceenable", 1);
	set_cvar_num("sv_maxspeed", 999);
	set_cvar_float("mp_roundtime", 6.0);
	set_cvar_num("mp_flashlight", 0);
	set_cvar_num("mp_footsteps", 1);
	set_cvar_num("mp_freezetime", 0);
	set_cvar_num("mp_friendlyfire", 0);
	set_cvar_num("mp_limitteams", 0);
	set_cvar_num("mp_autoteambalance", 0);
}

public plugin_cfg() {
	g_ExtraItem_InfectionBomb = 0;
	g_ExtraItem_UnlimitedClipOn = canBuyUnlimitedClips();
	g_ExtraItem_BubbleBomb = 0;
	g_ExtraItem_MadnessBomb = 0;
	g_Achievement_ValentinaTeAmo = 0;

	new i;
	for(i = 0; i < structIdExtraItem; ++i) {
		g_ExtraItem_InMap[i] = 0;
	}
}

public plugin_end() {
	SQL_FreeHandle(g_SqlConnection);
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
}

public client_putinserver(id) {
	g_PlayerModel[id][0] = EOS;
	g_IsConnected[id] = 1;
	g_IsAlive[id] = 0;

	resetVars(id, 1);

	if(!is_user_bot(id) && !is_user_hltv(id)) {
		remove_task(id + TASK_CHECK_ACCOUNT);

		set_task(0.2, "task__CheckAccount", id + TASK_CHECK_ACCOUNT);
		set_task(3.0, "task__ModifCommands", id);
	}
}

public resetVars(const id, const reset_all) {
	setUserUnlimitedClip(id, 0);

	g_ZombieBack[id] = 0;
	g_Zombie[id] = 0;
	g_SpecialMode[id] = 0;
	g_RespawnAsZombie[id] = 0;
	g_FirstZombie[id] = 0;
	g_LastZombie[id] = 0;
	g_LastHuman[id] = 0;
	g_LastHuman_1000hp[id] = 0;
	g_HumanClass_Medico[id] = 0;
	g_HumanClass_MedicoActive[id] = 0;
	g_ZombieClass_Voodoo[id] = 0;
	g_ZombieClass_LustyRose[id] = 0;
	g_ZombieClass_LustyRoseActive[id] = 0;
	g_ZombieClass_FarahonLastTime[id] = 0.0;
	g_ZombieClass_Fleshpound[id] = 0;
	g_ZombieClass_FleshpoundActive[id] = 0;
	g_ZombieClass_Banshee[id] = 0;
	g_ZombieClass_BansheeActive[id] = 0;
	g_ZombieClass_BansheeStat[id] = 0;
	g_ZombieClass_BansheeOwner[id] = 0;
	g_ZombieClass_ToxicoLastTime[id] = 0.0;
	g_Weapons[id][WEAPON_PRIMARY_CURRENT] = 0;
	g_Weapons[id][WEAPON_PRIMARY_BOUGHT] = 0;
	g_Weapons[id][WEAPON_SECONDARY_CURRENT] = 0;
	g_Weapons[id][WEAPON_SECONDARY_BOUGHT] = 0;
	g_BubbleBomb[id] = 0;
	g_InBubble[id] = 0;
	g_Immunity[id] = 0;
	g_ImmunityFire[id] = 0;
	g_ImmunityFrost[id] = 0;
	g_Frozen[id] = 0;
	g_Burning_Duration[id] = 0;
	g_UserBullet[id] = 0;
	g_Buttoned[id] = 0;
	g_Breakabled[id] = 0;
	g_MadnessBomb[id] = 0;
	g_MadnessBomb_Count[id] = 0;
	g_MadnessBomb_Move[id] = 0;
	g_NVision[id] = 0;
	if(g_Mode != MODE_NEMESIS_X) {
		g_Escaped[id] = 0;
	}
	g_ModeJeruzalem_RewardExp[id] = 0;
	g_VIPsKilled[id] = 0;

	if(reset_all) {
		g_AccountLoading[id] = 0;
		g_AccountLoading_Steps[id] = 0;
		g_AccountLoading_MaxSteps[id] = 0;
		g_AccountId[id] = 0;
		g_AccountIp[id][0] = EOS;
		g_AccountPassword[id][0] = EOS;
		g_AccountAutologin[id] = 0;
		g_AccountVinc[id] = 0;
		g_AccountVincMail[id][0] = EOS;
		g_AccountVincPassword[id][0] = EOS;
		g_AccountVincAppMobile[id] = 0;
		g_AccountRegister[id] = 0;
		g_AccountRegistering[id] = 0;
		g_AccountBanned[id] = 0;
		g_AccountBanned_StaffName[id][0] = EOS;
		g_AccountBanned_Start[id] = 0;
		g_AccountBanned_Finish[id] = 0;
		g_AccountBanned_Reason[id][0] = EOS;
		g_AccountLogged[id] = 0;
		g_AccountJoined[id] = 0;
		g_AccountRanking[id] = 0;
		g_Health[id] = 100;
		g_MaxHealth[id] = 100;
		g_Speed[id] = 240.0;
		g_HumanClass[id] = 0;
		g_HumanClassNext[id] = 0;
		g_ZombieClass[id] = 0;
		g_ZombieClassNext[id] = 0;
		g_SurvivorClass[id] = 0;
		g_SurvivorClassNext[id] = 0;
		g_NemesisClass[id] = 0;
		g_NemesisClassNext[id] = 0;
		g_Weapons[id][WEAPON_AUTO_BUY] = 0;
		g_Weapons[id][WEAPON_PRIMARY_SELECTION] = 0;
		g_Weapons[id][WEAPON_SECONDARY_SELECTION] = 0;
		g_Skin_GameTime[id] = get_gametime();
		g_Knife_GameTime[id] = get_gametime();
		g_Hat_GameTime[id] = get_gametime();
		g_InGroup[id] = 0;
		g_GroupInvitations[id] = 0;
		for(new i = 0; i <= MaxClients; ++i) {
			g_GroupInvitationsId[id][i] = 0;
		}
		g_MyGroup[id] = 0;
		g_ClanSlot[id] = 0;
		g_ClanInvitations[id] = 0;
		for(new i = 0; i <= MaxClients; ++i) {
			g_ClanInvitationsId[id][i] = 0;
		}
		g_Clan_QueryFlood[id] = 0.0;
		g_TempClanDeposit[id] = 0;
		g_UserOptions_Color[id][COLOR_TYPE_HUD_GENERAL] = {0, 255, 0};
		g_UserOptions_Color[id][COLOR_TYPE_GLOW_GROUP] = {255, 255, 255};
		g_UserOptions_Hud[id][HUD_TYPE_GENERAL] = Float:{0.02, 0.1, 0.0};
		g_UserOptions_HudEffect[id][HUD_TYPE_GENERAL] = 0;
		g_UserOptions_HudStyle[id][HUD_TYPE_GENERAL] = 1;
		g_UserOptions_Invis[id] = 0;
		g_UserOptions_ClanChat[id] = 0;
		g_UserOptions_GlowInGroup[id] = 0;
		g_APs[id] = 20;
		g_APsDamage[id] = 0.0;
		g_APsRewardKill[id] = 0;
		g_APsRewardDamage[id] = 0;
		g_APsRewradInfect[id] = 0;
		g_XP[id] = 0;
		g_XPRest[id] = 0;
		g_XPDamage[id] = 0.0;
		g_Level[id] = 1;
		g_LevelPercent[id] = 0.0;
		g_Range[id] = 0;
		g_Points[id] = 0;
		g_PointsLose[id] = 0;
		for(new i = 0; i < structIdStats; ++i) {
			g_Stats[id][i] = 0;
		}
		g_StatsRound_SupplyBoxDone[id] = 0;
		g_TimePlayed[id] = {0, 0, 0};
		g_SysTime_Top15[id] = 0;
		for(new i = 0; i < structIdMenuPages; ++i) {
			g_MenuPage[id][i] = 0;
		}
		for(new i = 0; i < structIdMenuDatas; ++i) {
			g_MenuData[id][i] = 0;
		}
		g_AmbienceSound_Muted[id] = AMBIENCE_MUTED_NONE;
		g_Camera[id] = 0;
		g_Secret_AlreadySayCrazy[id] = 0;
		for(new i = 0; i < structIdAchievements; ++i) {
			g_Achievement[id][i] = 0;
			g_Achievement_UnlockedPlayerName[id][i][0] = EOS;
			g_Achievement_UnlockedTimeStamp[id][i] = 0;
		}
		for(new i = 0; i < structIdExtraItem; ++i) {
			g_ExtraItem_InRound[id][i] = 0;
		}
		g_BuyStuff[id] = 0;
	}
}

public task__CheckAccount(const task_id) {
	new iId = (task_id - TASK_CHECK_ACCOUNT);

	if(!g_IsConnected[iId]) {
		return;
	}

	g_AccountLoading[iId] = 1;

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM ze3_accounts WHERE name=^"%s^";", g_PlayerName[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckAccount", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__CheckAccount(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__CheckAccount() - [%d] - <%s>", error_num, error);

		g_AccountLoading[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(!SQL_NumResults(query)) {
		g_AccountLoading[iId] = 0;

		showMenu__LogIn(iId);
		return;
	}

	g_AccountId[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "id"));
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "last_ip"), g_AccountIp[iId], charsmax(g_AccountIp[]));
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "password"), g_AccountPassword[iId], charsmax(g_AccountPassword[]));
	g_AccountAutologin[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "autologin"));
	g_AccountVinc[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "vinc"));

	if(!g_AccountVinc[iId]) {
		set_task(180.0, "task__MessageVinc", iId + TASK_MESSAGE_VINC);
	}

	g_AccountRegister[iId] = 1;

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM ze3_bans WHERE acc_id='%d' AND active='1';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckBan", g_SqlQuery, iArgs, sizeof(iArgs));
}

public task__MessageVinc(const task_id) {
	new iId = (task_id - TASK_MESSAGE_VINC);
	
	if(!g_IsConnected[iId] || g_AccountVinc[iId]) {
		return;
	}

	clientPrintColor(iId, _, "Tu cuenta no está vinculada a !g%s!y, recordá vincularla lo más pronto posible en el menú de !gOPCIONES DE USUARIO!y", __PLUGIN_COMMUNITY_NAME);
	clientPrintColor(iId, _, "Vincular tu cuenta ofrece varias opciones/funciones, alguna de ellas muy importantes, además de un logro. Para verlas, visita !twww.drunkgaming.net!y");

	set_task(300.0, "task__MessageVinc", iId + TASK_MESSAGE_VINC);
}

public sqlThread__CheckBan(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__CheckBan() - [%d] - <%s>", error_num, error);

		g_AccountLoading[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar tu cuenta en busca de un ban reciente. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	resetSomeVars(iId);

	if(SQL_NumResults(query)) {
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "staff_name"), g_AccountBanned_StaffName[iId], charsmax(g_AccountBanned_StaffName[]));
		g_AccountBanned_Start[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "start"));
		g_AccountBanned_Finish[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "finish"));
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "reason"), g_AccountBanned_Reason[iId], charsmax(g_AccountBanned_Reason[]));
		
		if(get_arg_systime() < g_AccountBanned_Finish[iId]) {
			g_AccountBanned[iId] = 1;
			showMenu__Banned(iId);
		} else {
			clientPrintColor(0, iId, "!t%s!y estaba baneado por cuenta y ahora podrá volver a jugar", g_PlayerName[iId]);

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_bans SET active='0' WHERE acc_id='%d' AND active='1';", g_AccountId[iId]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			if(equali(g_AccountIp[iId], g_PlayerIp[iId]) && g_AccountAutologin[iId] && g_AccountVinc[iId]) {
				g_AccountLogged[iId] = 1;
				loadInfo(iId);
			} else {
				g_AccountLoading[iId] = 0;
				showMenu__LogIn(iId);
			}
		}
	} else {
		if(equali(g_AccountIp[iId], g_PlayerIp[iId]) && g_AccountAutologin[iId] && g_AccountVinc[iId]) {
			g_AccountLogged[iId] = 1;
			loadInfo(iId);
		} else {
			g_AccountLoading[iId] = 0;
			showMenu__LogIn(iId);
		}
	}
}

public sqlThread__IgnoreQuery(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__IgnoreQuery() - [%d] - <%s>", error_num, error);
	}
}

public resetSomeVars(const id) {
	new i;

	g_Skin[id] = 0;
	g_Skin_Choosed[id] = 0;
	g_Knife[id] = 0;
	g_Knife_Choosed[id] = 0;
	g_Hat[id] = 0;
	g_Hat_Choosed[id] = 0;

	for(i = 0; i < sizeof(__SKINS); ++i) {
		g_Skin_Unlocked[id][i] = 0;
		g_Skin_UnlockedTimeStamp[id][i] = 0;

		if(i == 0 || ((get_user_flags(id) & ADMIN_RESERVATION) && !__SKINS[i][skinReq] && __SKINS[i][skinVip])) {
			g_Skin_Unlocked[id][i] = 1;
			g_Skin_UnlockedTimeStamp[id][i] = get_arg_systime();
		}
	}

	for(i = 0; i < sizeof(__KNIFES); ++i) {
		g_Knife_Unlocked[id][i] = 0;
		g_Knife_UnlockedTimeStamp[id][i] = 0;

		if(i == 0 || ((get_user_flags(id) & ADMIN_RESERVATION) && !__KNIFES[i][knifeReqPoints] && __KNIFES[i][knifeVip])) {
			g_Knife_Unlocked[id][i] = 1;
			g_Knife_UnlockedTimeStamp[id][i] = get_arg_systime();
		}
	}

	for(i = 0; i < sizeof(__HATS); ++i) {
		g_Hat_Unlocked[id][i] = 0;
		g_Hat_UnlockedTimeStamp[id][i] = 0;

		if(i == 0 || ((get_user_flags(id) & ADMIN_RESERVATION) && !__HATS[i][hatReq] && __HATS[i][hatVip])) {
			g_Hat_Unlocked[id][i] = 1;
			g_Hat_UnlockedTimeStamp[id][i] = get_arg_systime();
		}
	}
}

public loadInfo(const id) {
	if(!g_AccountLogged[id]) {
		return;
	}

	new iArgs[1];
	iArgs[0] = id;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM ze3_pjs LEFT JOIN ze3_pjs_stats ON ze3_pjs.acc_id=ze3_pjs_stats.acc_id WHERE ze3_pjs.acc_id='%d';", g_AccountId[id]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadInfo", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__LoadInfo(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadInfo() - [%d] - <%s>", error_num, error);

		g_AccountLoading[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar los datos de tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	new iClanId;
	new sInfo[32];
	new sWeapons[3][12];
	new sHudPosition[3][32];

	g_ExtraItem_InRound[iId][EXTRA_ITEM_ANTIDOTE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "ei_antidote_buy"));

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "weapons"), sInfo, charsmax(sInfo));
	parse(sInfo, sWeapons[0], charsmax(sWeapons[]), sWeapons[1], charsmax(sWeapons[]), sWeapons[2], charsmax(sWeapons[]));

	g_Weapons[iId][WEAPON_AUTO_BUY] = str_to_num(sWeapons[0]);
	g_Weapons[iId][WEAPON_PRIMARY_SELECTION] = str_to_num(sWeapons[1]);
	g_Weapons[iId][WEAPON_SECONDARY_SELECTION] = str_to_num(sWeapons[2]);

	g_HumanClass[iId] = g_HumanClassNext[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hc"));
	g_ZombieClass[iId] = g_ZombieClassNext[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zc"));
	g_SurvivorClass[iId] = g_SurvivorClassNext[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "sc"));
	g_NemesisClass[iId] = g_NemesisClassNext[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "nc"));

	g_Skin_Choosed[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "skin_choosed"));

	if(g_Skin_Choosed[iId] && __SKINS[g_Skin_Choosed[iId]][skinVip] && !(get_user_flags(iId) & ADMIN_RESERVATION)) {
		g_Skin_Choosed[iId] = 0;
	}

	g_Knife_Choosed[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "knife_choosed"));

	if(g_Knife_Choosed[iId] && __KNIFES[g_Knife_Choosed[iId]][knifeVip] && !(get_user_flags(iId) & ADMIN_RESERVATION)) {
		g_Knife_Choosed[iId] = 0;
	}

	g_Hat_Choosed[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hat_choosed"));

	if(g_Hat_Choosed[iId] && __HATS[g_Hat_Choosed[iId]][hatVip] && !(get_user_flags(iId) & ADMIN_RESERVATION)) {
		g_Hat_Choosed[iId] = 0;
	}

	g_XP[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "exp"));
	g_Level[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "level"));
	g_Range[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "level_range"));
	g_Points[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "points"));
	g_PointsLose[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "points_lose"));
	iClanId = SQL_ReadResult(query, SQL_FieldNameToNum(query, "clan_id"));

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "color_hud_general"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_UserOptions_Color[iId][COLOR_TYPE_HUD_GENERAL], 3);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "color_glow_group"), sInfo, charsmax(sInfo));
	stringToArray(sInfo, g_UserOptions_Color[iId][COLOR_TYPE_GLOW_GROUP], 3);

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_general_position"), sInfo, charsmax(sInfo));
	parse(sInfo, sHudPosition[0], charsmax(sHudPosition[]), sHudPosition[1], charsmax(sHudPosition[]), sHudPosition[2], charsmax(sHudPosition[]));

	g_UserOptions_Hud[iId][HUD_TYPE_GENERAL][0] = str_to_float(sHudPosition[0]);
	g_UserOptions_Hud[iId][HUD_TYPE_GENERAL][1] = str_to_float(sHudPosition[1]);
	g_UserOptions_Hud[iId][HUD_TYPE_GENERAL][2] = str_to_float(sHudPosition[2]);

	g_UserOptions_HudEffect[iId][HUD_TYPE_GENERAL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_general_effect"));
	g_UserOptions_HudStyle[iId][HUD_TYPE_GENERAL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "hud_general_style"));
	g_UserOptions_Invis[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_invis"));
	g_UserOptions_ClanChat[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_clanchat"));
	g_UserOptions_GlowInGroup[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "uo_glowingroup"));
	g_BuyStuff[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "bought_ok"));
	g_TimePlayed[iId][TIME_PLAYED_MIN] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "time_played"));

	if(g_TimePlayed[iId][TIME_PLAYED_MIN] >= 60) {
		new iHour = (g_TimePlayed[iId][TIME_PLAYED_MIN] / 60);
		new iDay = 0;

		while(iHour >= 24) {
			++iDay;
			iHour -= 24;
		}

		g_TimePlayed[iId][TIME_PLAYED_HOUR] = iHour;
		g_TimePlayed[iId][TIME_PLAYED_DAY] = iDay;
	} else {
		g_TimePlayed[iId][TIME_PLAYED_HOUR] = 0;
		g_TimePlayed[iId][TIME_PLAYED_DAY] = 0;
	}
	
	g_Stats[iId][STAT_HK_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "human_kill_done"));
	g_Stats[iId][STAT_HK_TAKE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "human_kill_take"));
	g_Stats[iId][STAT_ZK_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zombie_kill_done"));
	g_Stats[iId][STAT_ZK_TAKE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zombie_kill_take"));
	g_Stats[iId][STAT_I_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "infection_done"));
	g_Stats[iId][STAT_I_TAKE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "infection_take"));
	g_Stats[iId][STAT_SURVIVOR_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "survivor_done"));
	g_Stats[iId][STAT_NEMESIS_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "nemesis_done"));
	g_Stats[iId][STAT_ZK_HS_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zombie_kill_hs_done"));
	g_Stats[iId][STAT_ZK_HS_TAKE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zombie_kill_hs_take"));
	g_Stats[iId][STAT_ZK_KNIFE_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zombie_kill_knife_done"));
	g_Stats[iId][STAT_ZK_KNIFE_TAKE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "zombie_kill_knife_take"));
	g_Stats[iId][STAT_ARMOR_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "armor_done"));
	g_Stats[iId][STAT_ARMOR_TAKE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "armor_take"));
	g_Stats[iId][STAT_ESCAPES_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "escape_done"));
	g_Stats[iId][STAT_ACHIEVEMENTS_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "achievements_done"));
	g_Stats[iId][STAT_SUPPLYBOX_DONE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "supplybox_done"));

	g_AccountLoading_MaxSteps[iId] = 4;

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT skin_id, skin_timestamp FROM ze3_skins WHERE acc_id='%d';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadSkins", g_SqlQuery, iArgs, sizeof(iArgs));

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT knife_id, knife_timestamp FROM ze3_knifes WHERE acc_id='%d';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadKnifes", g_SqlQuery, iArgs, sizeof(iArgs));

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT hat_id, hat_timestamp FROM ze3_hats WHERE acc_id='%d';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadHats", g_SqlQuery, iArgs, sizeof(iArgs));

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT achievement_id, achievement_timestamp FROM ze3_achievements WHERE acc_id='%d';", g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadAchievements", g_SqlQuery, iArgs, sizeof(iArgs));

	remove_task(iId + TASK_HELLO_AGAIN);
	remove_task(iId + TASK_TIME_PLAYED);
	remove_task(iId + TASK_SAVE);

	set_task(random_float(5.0, 10.0), "task__HelloAgain", iId + TASK_HELLO_AGAIN);
	set_task(360.0, "task__TimePlayed", iId + TASK_TIME_PLAYED, .flags="b");
	set_task(random_float(300.0, 600.0), "task__Save", iId + TASK_SAVE, .flags="b");

	loadClans(iId, iClanId);
	updateRewardsByFlags(iId);
}

public loadClans(const id, const clan_id) {
	if(!clan_id) {
		return;
	}

	new iOk = 0;
	new i;
	new j;

	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || g_Clan[g_ClanSlot[i]][clanId] != clan_id) {
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

		new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM ze3_clans WHERE id='%d' LIMIT 1;", clan_id);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 31);
		} else if(SQL_NumResults(sqlQuery)) {
			g_ClanSlot[id] = iClanSlot;

			g_Clan[g_ClanSlot[id]][clanId] = clan_id;
			SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_name"), g_Clan[g_ClanSlot[id]][clanName], 31);
			g_Clan[g_ClanSlot[id]][clanTimestamp] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "clan_timestamp"));
			g_Clan[g_ClanSlot[id]][clanDeposit] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "deposit"));
			g_Clan[g_ClanSlot[id]][clanKillsHumanDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kills_h_done"));
			g_Clan[g_ClanSlot[id]][clanKillsZombieDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "kills_z_done"));
			g_Clan[g_ClanSlot[id]][clanInfectionsDone] = SQL_ReadResult(sqlQuery, SQL_FieldNameToNum(sqlQuery, "infections_done"));
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

		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT ze3_clans_members.acc_id, ze3_accounts.name, ze3_clans_members.owner, ze3_pjs_stats.time_played, ze3_clans_members.last_connection, ze3_clans_members.since_connection, ze3_pjs.level FROM ze3_clans_members LEFT JOIN ze3_pjs ON ze3_clans_members.acc_id=ze3_pjs.acc_id LEFT JOIN ze3_accounts ON ze3_clans_members.acc_id=ze3_accounts.id LEFT JOIN ze3_pjs_stats ON ze3_clans_members.acc_id=ze3_pjs_stats.acc_id WHERE ze3_clans_members.clan_id='%d' AND ze3_clans_members.active='1' LIMIT %d;", clan_id, MAX_CLAN_MEMBERS);

		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 32);
		} else if(SQL_NumResults(sqlQuery)) {
			new iTimePlayed;
			new iSince;
			new iLastSee;
			new iSysTime = get_arg_systime();
			new i = 0;
			new iMinutes;
			new iHours;
			
			while(SQL_MoreResults(sqlQuery)) {
				++g_Clan[g_ClanSlot[id]][clanCountMembers];

				g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] = SQL_ReadResult(sqlQuery, 0);
				SQL_ReadResult(sqlQuery, 1, g_ClanMembers[g_ClanSlot[id]][i][clanMemberName], 32);
				g_ClanMembers[g_ClanSlot[id]][i][clanMemberOwner] = SQL_ReadResult(sqlQuery, 2);
				iTimePlayed = (SQL_ReadResult(sqlQuery, 3) * 60);
				iLastSee = (iSysTime - SQL_ReadResult(sqlQuery, 4));
				iSince = (iSysTime - SQL_ReadResult(sqlQuery, 5));
				g_ClanMembers[g_ClanSlot[id]][i][clanMemberLevel] = SQL_ReadResult(sqlQuery, 6);

				// START - Tiempo jugado
				iMinutes = (iTimePlayed / 60);
				iHours = 0;
				
				if(iMinutes >= 60) {
					while(iMinutes >= 60) {
						++iHours;
						iMinutes -= 60;
					}
				}
				
				if(iHours) {
					formatex(g_ClanMembers[g_ClanSlot[id]][i][clanMemberTimePlayed], 31, "%d hora%s y %d minuto%s", iHours, ((iHours != 1) ? "s" : ""), iMinutes, ((iMinutes != 1) ? "s" : ""));
				} else {
					formatex(g_ClanMembers[g_ClanSlot[id]][i][clanMemberTimePlayed], 31, "%d minuto%s", iMinutes, ((iMinutes != 1) ? "s" : ""));
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
				
				if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeDay] = 0;
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeHour] = 0;
					g_ClanMembers[g_ClanSlot[id]][i][clanMemberLastTimeMinute] = 0;
				}
				// END
				
				++i;
				
				SQL_NextRow(sqlQuery);
			}

			SQL_FreeHandle(sqlQuery);
		} else {
			SQL_FreeHandle(sqlQuery);
		}

		clanUpdateHumans(id);
	}
}

public sqlThread__LoadSkins(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadSkins() - [%d] - <%s>", error_num, error);

		g_AccountLoading[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar los skins de tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		new iSkinId;

		while(SQL_MoreResults(query)) {
			iSkinId = SQL_ReadResult(query, 0);

			g_Skin_Unlocked[iId][iSkinId] = 1;
			g_Skin_UnlockedTimeStamp[iId][iSkinId] = SQL_ReadResult(query, 1);

			SQL_NextRow(query);
		}
	}

	loadInfoEnd(iId);
}

public sqlThread__LoadKnifes(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadKnifes() - [%d] - <%s>", error_num, error);

		g_AccountLoading[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar los cuchillos de tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		new iKnifeId;

		while(SQL_MoreResults(query)) {
			iKnifeId = SQL_ReadResult(query, 0);

			g_Knife_Unlocked[iId][iKnifeId] = 1;
			g_Knife_UnlockedTimeStamp[iId][iKnifeId] = SQL_ReadResult(query, 1);

			SQL_NextRow(query);
		}
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

		g_AccountLoading[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar los cuchillos de tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		new iHatId;

		while(SQL_MoreResults(query)) {
			iHatId = SQL_ReadResult(query, 0);

			g_Hat_Unlocked[iId][iHatId] = 1;
			g_Hat_UnlockedTimeStamp[iId][iHatId] = SQL_ReadResult(query, 1);

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

		g_AccountLoading[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar los logros de tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		new iAchievementId;
		new iCount = 0;

		while(SQL_MoreResults(query)) {
			iAchievementId = SQL_ReadResult(query, 0);

			g_Achievement[iId][iAchievementId] = 1;
			g_Achievement_UnlockedTimeStamp[iId][iAchievementId] = SQL_ReadResult(query, 1);
			++iCount;

			SQL_NextRow(query);
		}

		g_Stats[iId][STAT_ACHIEVEMENTS_DONE] = iCount;
	}

	loadInfoEnd(iId);

	remove_task(iId + TASK_CHECK_ACHIEVEMENTS);
	set_task(1.0, "task__CheckAchievements", iId + TASK_CHECK_ACHIEVEMENTS);
}

public task__CheckAchievements(const task_id) {
	new iId = (task_id - TASK_CHECK_ACHIEVEMENTS);

	if(!g_IsConnected[iId] || !g_AccountLogged[iId] || g_AccountLoading[iId]) {
		return;
	}

	if((g_AccountId[iId] % 2) == 0) {
		setAchievement(iId, CUENTA_PAR);
	} else {
		setAchievement(iId, CUENTA_IMPAR);
	}

	if((get_user_flags(iId) & ADMIN_RESERVATION)) {
		setAchievement(iId, SOY_DORADO);
	}

	if(g_AccountVinc[iId]) {
		setAchievement(iId, VINCULADO_WEB);
	}

	if(g_AccountVincAppMobile[iId]) {
		setAchievement(iId, VINCULADO_MOBILE);
	}
}

public loadInfoEnd(const id) {
	++g_AccountLoading_Steps[id];

	if(g_AccountLoading_Steps[id] != g_AccountLoading_MaxSteps[id]) {
		return;
	}

	g_AccountLoading[id] = 0;
	showMenu__Join(id);
}

public task__Save(const task_id) {
	new iId = (task_id - TASK_SAVE);

	if(!g_IsConnected[iId] || !g_AccountLogged[iId]) {
		return;
	}

	saveInfo(iId, 0);
}

public showMenu__LogIn(const id) {
	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__LogIn", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(1, 1, "\r1.\w Crear una cuenta");
	oldmenu_additem(2, 2, "\r2.\w Identificarse^n");

	if(__PLUGIN_UPDATE[0] && __PLUGIN_UPDATE_VERSION[0]) {
		oldmenu_additem(-1, -1, "\wEl día \y%s\w se llevará acabo la actualización a la versión \y%s\w.", __PLUGIN_UPDATE, __PLUGIN_UPDATE_VERSION);
		oldmenu_additem(-1, -1, "\wToda la información de la misma estará en nuestro foro.^n");
	}

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", __PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__LogIn(const id, const item) {
	switch(item) {
		case 1: {
			if(g_AccountRegister[id]) {
				clientPrintColor(id, _, "Esta cuenta ya está registrada. Elije otro nombre para tu cuenta por favor");

				showMenu__LogIn(id);
				return;
			}

			client_cmd(id, "messagemode CREAR_CUENTA");
			clientPrintColor(id, _, "Escriba una contraseña para proteger a tu cuenta");
		} case 2: {
			if(!g_AccountRegister[id]) {
				clientPrintColor(id, _, "Esta cuenta no está registrada. Registrala para reservar tu nombre en el servidor");

				showMenu__LogIn(id);
				return;
			}

			client_cmd(id, "messagemode IDENTIFICAR_CUENTA");
			clientPrintColor(id, _, "Escribe tu contraseña que protege a tu cuenta");
		}
	}
}

public clcmd__CreateAccount(const id) {
	if(!g_IsConnected[id] || g_AccountRegister[id]) {
		return PLUGIN_HANDLED;
	}

	new sPassword[64];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	if(contain(sPassword, "%") != -1) {
		clientPrintColor(id, _, "La contraseña no puede contener el simbolo del porcentaje");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	new iLenPassword = strlen(sPassword);

	if(iLenPassword < 4) {
		clientPrintColor(id, _, "La contraseña debe tener al menos 4 caracteres");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	} else if(iLenPassword > 30) {
		clientPrintColor(id, _, "La contraseña no puede superar los 30 caracteres");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	copy(g_AccountPassword[id], charsmax(g_AccountPassword[]), sPassword);

	client_cmd(id, "messagemode CONFIRMAR_CUENTA");
	clientPrintColor(id, _, "Por favor, confirma tu contraseña para continuar");

	return PLUGIN_HANDLED;
}

public clcmd__ConfirmAccount(const id) {
	if(!g_IsConnected[id] || g_AccountRegister[id] || g_AccountRegistering[id]) {
		return PLUGIN_HANDLED;
	}

	new sPassword[64];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	if(!equal(g_AccountPassword[id], sPassword)) {
		g_AccountPassword[id][0] = EOS;

		clientPrintColor(id, _, "La contraseña escrita no coincide con la anterior");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	g_AccountRegistering[id] = 1;

	hash_string(sPassword, Hash_Md5, g_AccountPassword[id], charsmax(g_AccountPassword[]));

	new iArgs[1];
	iArgs[0] = id;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_accounts` (`name`, `since_ip`, `last_ip`, `since_steam`, `last_steam`, `password`, `since_connection`, `last_connection`) VALUES (^"%s^", ^"%s^", ^"%s^", ^"%s^", ^"%s^", ^"%s^", '%d', '%d');", g_PlayerName[id], g_PlayerIp[id], g_PlayerIp[id], g_PlayerSteamId[id], g_PlayerSteamId[id], g_AccountPassword[id], get_arg_systime(), get_arg_systime());
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__RegisterAccount", g_SqlQuery, iArgs, sizeof(iArgs));

	return PLUGIN_HANDLED;
}

public sqlThread__RegisterAccount(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__RegisterAccount() - [%d] - <%s>", error_num, error);

		g_AccountRegistering[iId] = 0;
		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al registrar tu cuenta. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	g_AccountId[iId] = SQL_GetInsertId(query);

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM `ze3_bans` WHERE (`ip`=^"%s^" OR `steam`=^"%s^") AND `active`='1';", g_PlayerIp[iId], g_PlayerSteamId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckBanInRegister", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__CheckBanInRegister(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	g_AccountRegistering[iId] = 0;

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__CheckBanInRegister() - [%d] - <%s>", error_num, error);

		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al buscar un ban registrado. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "staff_name"), g_AccountBanned_StaffName[iId], charsmax(g_AccountBanned_StaffName[]));
		g_AccountBanned_Start[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "start"));
		g_AccountBanned_Finish[iId] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "finish"));
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "reason"), g_AccountBanned_Reason[iId], charsmax(g_AccountBanned_Reason[]));

		g_AccountBanned[iId] = 1;

		clientPrintColor(0, iId, "!t%s!y ha sido baneado porque se ha encontrado coincidencias con otro usuario baneado por cuenta", g_PlayerName[iId]);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_bans` (`acc_id`, `ip`, `steam`, `staff_name`, `start`, `finish`, `reason`) VALUES ('%d', ^"%s^", ^"%s^", ^"%s^", '%d', '%d', ^"%s^");", g_AccountId[iId], g_PlayerIp[iId], g_PlayerSteamId[iId], g_AccountBanned_StaffName[iId], g_AccountBanned_Start[iId], g_AccountBanned_Finish[iId], g_AccountBanned_Reason[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
	} else {
		formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_pjs` (`acc_id`) VALUES ('%d');", g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_pjs_stats` (`acc_id`) VALUES ('%d');", g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		++g_GlobalRank;

		new sAccount[8];
		addDot(g_GlobalRank, sAccount, charsmax(sAccount));
		clientPrintColor(0, iId, "Bienvenido !t%s!y, eres la cuenta registrada !g#%s!y", g_PlayerName[iId], sAccount);

		g_AccountRegister[iId] = 1;
		g_AccountLogged[iId] = 1;

		showMenu__Join(iId);

		remove_task(iId + TASK_TIME_PLAYED);
		remove_task(iId + TASK_SAVE);
		
		set_task(360.0, "task__TimePlayed", iId + TASK_TIME_PLAYED, .flags="b");
		set_task(random_float(300.0, 600.0), "task__Save", iId + TASK_SAVE, .flags="b");
	}
}

public clcmd__EnterAccount(const id) {
	if(!g_IsConnected[id] || !g_AccountRegister[id] || g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sPassword[64];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	hash_string(sPassword, Hash_Md5, sPassword, charsmax(sPassword));
	
	if(!equal(g_AccountPassword[id], sPassword)) {
		clientPrintColor(id, _, "La contraseña ingresada no coincide con la de esta cuenta");

		showMenu__LogIn(id);
		return PLUGIN_HANDLED;
	}

	g_AccountLogged[id] = 1;

	loadInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__Join(const id) {
	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__Join", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	new sAccount[8];
	new sForum[8];

	addDot(g_AccountId[id], sAccount, charsmax(sAccount));
	addDot(g_AccountVinc[id], sForum, charsmax(sForum));

	oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccount);
	oldmenu_additem(-1, -1, "\wVINCULADO AL FORO\r:\y %s \d(#%s)", ((g_AccountVinc[id]) ? "Si" : "No"), sForum);
	oldmenu_additem(-1, -1, "\wVINCULADO A LA APP MOBILE\r:\y %s^n", ((g_AccountVincAppMobile[id]) ? "Si" : "No"));

	oldmenu_additem(1, 1, "\r1.\w Entrar a jugar");
	oldmenu_additem(2, 2, "\r2.\w Vincular cuenta^n");

	if(__PLUGIN_UPDATE[0] && __PLUGIN_UPDATE_VERSION[0]) {
		oldmenu_additem(-1, -1, "\wEl día \y%s\w se llevará acabo la actualización a la versión \y%s\w.", __PLUGIN_UPDATE, __PLUGIN_UPDATE_VERSION);
		oldmenu_additem(-1, -1, "\wToda la información de la misma estará en nuestro foro.^n");
	}

	oldmenu_additem(-1, -1, "\wForo\r:\y %s", __PLUGIN_COMMUNITY_FORUM);
	oldmenu_display(id);
}

public menu__Join(const id, const item) {
	switch(item) {
		case 1: {
			rg_join_team(id, rg_get_join_team_priority());
			
			if(!g_AccountJoined[id]) {
				g_AccountJoined[id] = 1;
			}
		} case 2: {
			showMenu__UserOptions_Vinc(id);
		}
	}
}

public showMenu__Game(const id)	{
	if(g_AccountLoading[id]) {
		return;
	} else if(g_BuyStuff[id]) {
		clientPrintColor(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite");
		return;
	}

	oldmenu_create("\y%s - %s \r(%s)^n\dby %s", "menu__Game", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(1, 1, "\r1.\w ARMAS");
	oldmenu_additem(2, 2, "\r2.\w ITEMS EXTRAS");
	oldmenu_additem(3, 3, "\r3.\w PERSONAJE^n");

	oldmenu_additem(4, 4, "\r4.\w DESTRABAR");
	oldmenu_additem(5, 5, "\r5.\w GRUPO");
	oldmenu_additem(6, 6, "\r6.\w CLAN");
	oldmenu_additem(7, 7, "\r7.\w OPCIONES DE USUARIO^n");

	oldmenu_additem(8, 8, "\r8.\w ESTADÍSTICAS");
	oldmenu_additem(9, 9, "\r9.\y REGLAS^n");

	oldmenu_additem(0, 0, "\r0.\w Salir");
	oldmenu_display(id);
}

public menu__Game(const id, const item) {
	if(!item) {
		return;
	} else if(g_AccountLoading[id]) {
		return;
	} else if(g_BuyStuff[id]) {
		clientPrintColor(id, _, "Posiblemente está cargando una compra realizada, espere un momento por favor hasta que se acredite");
		return;
	}

	switch(item) {
		case 1: {
			if(!g_IsAlive[id]) {
				clientPrintColor(id, _, "Debes estar vivo para abrir el menú de armas");

				showMenu__Game(id);
				return;
			}

			if(g_Zombie[id] || g_SpecialMode[id]) {
				clientPrintColor(id, _, "Debes ser humano para abrir el menú de armas");

				showMenu__Game(id);
				return;
			}
			
			if(g_Weapons[id][WEAPON_AUTO_BUY]) {
				g_Weapons[id][WEAPON_AUTO_BUY] = 0;
				clientPrintColor(id, _, "Has re-activado la compra de armas. Vuelve a pulsar en el menú para elegir armas");

				if(g_NewRound) {
					g_Weapons[id][WEAPON_PRIMARY_BOUGHT] = 0;
					g_Weapons[id][WEAPON_SECONDARY_BOUGHT] = 0;

					showMenu__PrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_P]);
					return;
				}

				showMenu__Game(id);
				return;
			}

			if(checkWeaponBuy(id)) {
				clientPrintColor(id, _, "Ya has realizado la compra. Espera al próximo respawn humano para elegir armas");

				showMenu__Game(id);
				return;
			}

			showMenu__PrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_P]);
		} case 2: {
			if(!g_IsAlive[id]) {
				clientPrintColor(id, _, "Debes estar vivo para abrir el menú de Items Extras");

				showMenu__Game(id);
				return;
			}

			if(g_SpecialMode[id]) {
				clientPrintColor(id, _, "Debes ser humano o zombie para abrir el menú de Items Extras");

				showMenu__Game(id);
				return;
			}

			if(g_NewRound || g_EndRound) {
				clientPrintColor(id, _, "Debes esperar a que comience un modo para abrir el menú de Items Extras");

				showMenu__Game(id);
				return;
			}

			showMenu__ExtraItems(id);
		} case 3: {
			showMenu__Character(id);
		} case 4: {
			if(!g_IsAlive[id]) {
				clientPrintColor(id, _, "Debes estar vivo para utilizar esta función");

				showMenu__Game(id);
				return;
			}

			if(!isUserStuck(id)) {
				clientPrintColor(id, _, "No estás trabado");

				showMenu__Game(id);
				return;
			}

			checkStuck(id);
		} case 5: {
			showMenu__Group(id);
		} case 6: {
			showMenu__Clan(id);
		} case 7: {
			showMenu__UserOptions(id);
		} case 8: {
			showMenu__Stats(id);
		} case 9: {
			new sTitle[64];
			new sFile[32];
			new sUrl[256];

			formatex(sTitle, charsmax(sTitle), "%s - Reglas", __PLUGIN_NAME);
			formatex(sFile, charsmax(sFile), "rules.html");
			formatex(sUrl, charsmax(sUrl), "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=https://%s/tops/01_zombie_escape/%s^"></head><body><p>Cargando...</p></body></html>", __PLUGIN_COMMUNITY_FORUM, sFile);

			show_motd(id, sUrl, sTitle);
		}
	}
}

public checkWeaponBuy(const id) {
	if(g_Weapons[id][WEAPON_PRIMARY_BOUGHT] && g_Weapons[id][WEAPON_SECONDARY_BOUGHT]) {
		return 1;
	}

	return 0;
}

public showMenu__PrimaryWeapons(const id, page)  {
	if(g_Weapons[id][WEAPON_PRIMARY_BOUGHT]) {
		showMenu__SecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_S]);
		return;
	}

	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__PRIMARY_WEAPONS), 6);
	oldmenu_create("\yARMAS PRIMARIAS \r[%d - %d]\y\R%d / %d", "menu__PrimaryWeapons", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s", j, __PRIMARY_WEAPONS[i][weaponName]);
	}

	oldmenu_additem(7, 7, "^n\r7.\w ¿Recordar compra?%s", ((g_Weapons[id][WEAPON_AUTO_BUY]) ? " \y[Si]" : " \r[No]"));

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__PrimaryWeapons(const id, const item, const value, page)  {
	if(!item || value > sizeof(__PRIMARY_WEAPONS)) {
		showMenu__Game(id);
		return;
	} else if(g_Weapons[id][WEAPON_PRIMARY_BOUGHT]) {
		showMenu__SecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_S]);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_WPN_P] = iNewPage;

		showMenu__PrimaryWeapons(id, iNewPage);
		return;
	} else if(item == 7) {
		g_Weapons[id][WEAPON_AUTO_BUY] = !g_Weapons[id][WEAPON_AUTO_BUY];

		showMenu__PrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_P]);
		return;
	}

	g_Weapons[id][WEAPON_PRIMARY_SELECTION] = value;

	showMenu__SecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_S]);

	g_Weapons[id][WEAPON_PRIMARY_BOUGHT] = 1;
}

public buyPrimaryWeapon(const id, const selection) {
	if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id]) {
		return;
	}

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	g_Weapons[id][WEAPON_PRIMARY_CURRENT] = selection;

	give_item(id, __PRIMARY_WEAPONS[selection][weaponEntName]);
	cs_set_user_bpammo(id, __PRIMARY_WEAPONS[selection][weaponCSW], 200);
}

public showMenu__SecondaryWeapons(const id, page) {
	if(g_Weapons[id][WEAPON_SECONDARY_BOUGHT]) {
		showMenu__Game(id);

		clientPrintColor(id, _, "Ya has realizado la compra. Espera al próximo respawn humano para elegir armas");
		return;
	}

	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__SECONDARY_WEAPONS), 6);
	oldmenu_create("\yARMAS SECUNDARIAS \r[%d - %d]\y\R%d / %d", "menu__SecondaryWeapons", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.\w %s", j, __SECONDARY_WEAPONS[i][weaponName]);
	}

	oldmenu_additem(7, 7, "^n\r7.\w ¿Recordar compra?%s", ((g_Weapons[id][WEAPON_AUTO_BUY]) ? " \y[Si]" : " \r[No]"));

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__SecondaryWeapons(const id, const item, const value, page) {
	if(!item || value > sizeof(__SECONDARY_WEAPONS)) {
		showMenu__Game(id);
		return;
	} else if(g_Weapons[id][WEAPON_SECONDARY_BOUGHT]) {
		showMenu__Game(id);

		clientPrintColor(id, _, "Ya has realizado la compra. Espera al próximo respawn humano para elegir armas");
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_WPN_S] = iNewPage;

		showMenu__SecondaryWeapons(id, iNewPage);
		return;
	} else if(item == 7) {
		g_Weapons[id][WEAPON_AUTO_BUY] = !g_Weapons[id][WEAPON_AUTO_BUY];

		showMenu__SecondaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_S]);
		return;
	}

	g_Weapons[id][WEAPON_SECONDARY_SELECTION] = value;

	if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] || checkWeaponBuy(id)) {
		return;
	}

	buyPrimaryWeapon(id, g_Weapons[id][WEAPON_PRIMARY_SELECTION]);
	buySecondaryWeapon(id, g_Weapons[id][WEAPON_SECONDARY_SELECTION]);
	buyGrenades(id);

	g_Weapons[id][WEAPON_SECONDARY_BOUGHT] = 1;
}

public buySecondaryWeapon(const id, const selection) {
	if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id]) {
		return;
	}

	if(selection > sizeof(__SECONDARY_WEAPONS)) {
		g_Weapons[id][WEAPON_AUTO_BUY] = 0;
		g_Weapons[id][WEAPON_PRIMARY_CURRENT] = 0;
		g_Weapons[id][WEAPON_PRIMARY_BOUGHT] = 0;
		g_Weapons[id][WEAPON_SECONDARY_CURRENT] = 0;
		g_Weapons[id][WEAPON_SECONDARY_BOUGHT] = 0;

		showMenu__PrimaryWeapons(id, g_MenuPage[id][MENU_PAGE_WPN_P]);
		return;
	}

	g_Weapons[id][WEAPON_SECONDARY_CURRENT] = selection;

	give_item(id, __SECONDARY_WEAPONS[selection][weaponEntName]);
	cs_set_user_bpammo(id, __SECONDARY_WEAPONS[selection][weaponCSW], 200);
}

public buyGrenades(const id) {
	new iSelection = 0;
	new i;

	for(i = 0; i < sizeof(__GRENADES); ++i) {
		if(g_Level[id] >= __GRENADES[iSelection][grenadeLevel]) {
			iSelection = i;
		}
	}

	if(__GRENADES[iSelection][grenadeAmountHe]) {
		give_item(id, "weapon_hegrenade");
		cs_set_user_bpammo(id, CSW_HEGRENADE, __GRENADES[iSelection][grenadeAmountHe]);
	}

	if(__GRENADES[iSelection][grenadeAmountFb]) {
		give_item(id, "weapon_flashbang");
		cs_set_user_bpammo(id, CSW_FLASHBANG, __GRENADES[iSelection][grenadeAmountFb]);
	}

	if(__GRENADES[iSelection][grenadeAmountSg]) {
		give_item(id, "weapon_smokegrenade");
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, __GRENADES[iSelection][grenadeAmountSg]);
	}
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

public checkRound(const leaving_id) {
	if(g_EndRound || task_exists(TASK_STARTMODE)) {
		return;
	}

	static iUsersAlive;
	static iId;

	iUsersAlive = getUsersAlive();

	if(iUsersAlive < 3) {
		return;
	}

	if(g_Zombie[leaving_id] && getZombies() == 1) {
		if(g_Mode == MODE_JERUZALEM) {
			modeJeruzalemFinish(TEAM_CT, leaving_id);
			return;
		}

		if(getHumans() == 1 && getCTs() == 1) {
			return;
		}

		while((iId = getRandomAlive(random_num(1, iUsersAlive))) == leaving_id) {

		}

		switch(g_SpecialMode[leaving_id]) {
			case MODE_NEMESIS: {
				clientPrintColor(0, iId, "El nemesis se ha desconectado, !g%s!y es el nuevo nemesis", g_PlayerName[iId]);
				zombieMe(iId, .nemesis=1);

				set_user_health(iId, g_Health[leaving_id]);
				g_Health[iId] = get_user_health(iId);
			} default: {
				clientPrintColor(0, _, "El último zombie se ha desconectado, !g%s!y es el nuevo zombie", g_PlayerName[iId]);
				zombieMe(iId);
			}
		}
	} else if(!g_Zombie[leaving_id]) {
		if(g_SpecialMode[leaving_id] == MODE_JERUZALEM) {
			--g_VIPsDead;

			if(g_VIPsDead) {
				clientPrintColor(0, _, "Uno de los VIPs se desconectó");
			} else {
				clientPrintColor(0, _, "El único VIP vivo se desconectó y los zombies ganan la ronda");
				
				modeJeruzalemFinish(TEAM_TERRORIST, leaving_id);
				return;
			}
		}

		if(getHumans() == 1) {
			if(getZombies() == 1 && getTs() == 1) {
				return;
			}

			while((iId = getRandomAlive(random_num(1, iUsersAlive))) == leaving_id) {

			}

			switch(g_SpecialMode[leaving_id]) {
				case MODE_SURVIVOR: {
					clientPrintColor(0, iId, "El survivor se ha desconectado, !g%s!y es el nuevo survivor", g_PlayerName[iId]);
					humanMe(iId, .survivor=1);

					set_user_health(iId, g_Health[leaving_id]);
					g_Health[iId] = get_user_health(iId);
				} default: {
					clientPrintColor(0, iId, "El último humano se ha desconectado, !g%s!y es el nuevo humano", g_PlayerName[iId]);
					humanMe(iId);
				}
			}
		}
	}
}

public client_disconnected(id, bool:drop, message[], maxlen) {
	remove_task(id + TASK_CHECK_ACCOUNT);
	remove_task(id + TASK_HELLO_AGAIN);
	remove_task(id + TASK_TIME_PLAYED);
	remove_task(id + TASK_CHECK_ACHIEVEMENTS);
	remove_task(id + TASK_MESSAGE_VINC);
	remove_task(id + TASK_SAVE);
	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_NVISION);
	remove_task(id + TASK_BURN_FLAME);
	remove_task(id + TASK_FROZEN);
	remove_task(id + TASK_IMMUNITY_BOMBS);
	remove_task(id + TASK_MADNESS_BOMB);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_BUTTONED);
	remove_task(id + TASK_POWER_ZOMBIE);
	remove_task(id + TASK_HUMAN_MEDICO_ACTIVE);
	remove_task(id + TASK_ZOMBIE_VOODOO);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE_WAIT);
	remove_task(id + TASK_ZOMBIE_FARAHON);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_ACTIVE);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_AURA);

	if(g_IsAlive[id]) {
		checkRound(id);
	}

	checkGroupOnDisconnected(id);
	checkClanOnDisconnected(id);

	if(g_Secret_AlreadySayCrazy[id]) {
		--g_Secret_CrazyMode_Count;
	}

	removeFrostCube(id);

	if(g_AccountLogged[id] && !g_AccountLoading[id]) {
		saveInfo(id, 1);
	}

	g_IsAlive[id] = 0;
	g_IsConnected[id] = 0;
}

public saveInfo(const id, const disconnect) {
	if(g_AccountLoading[id] || !g_AccountLogged[id] || g_DataSaved) {
		return;
	}

	if(disconnect) {
		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_accounts SET last_ip=^"%s^", last_steam=^"%s^", last_connection='%d' WHERE id='%d';", g_PlayerIp[id], g_PlayerSteamId[id], get_arg_systime(), g_AccountId[id]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		
		if(g_ClanSlot[id]) {
			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_clans SET kills_h_done='%d', kills_z_done='%d', infections_done='%d' WHERE id='%d';", g_Clan[g_ClanSlot[id]][clanKillsHumanDone], g_Clan[g_ClanSlot[id]][clanKillsZombieDone], g_Clan[g_ClanSlot[id]][clanInfectionsDone], g_Clan[g_ClanSlot[id]][clanId]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_clans_members SET last_connection='%d' WHERE acc_id='%d' AND clan_id='%d';", get_arg_systime(), g_AccountId[id], g_Clan[g_ClanSlot[id]][clanId]);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		}
	}

	new sWeapons[12];
	new sColorHudGeneral[12];
	new sColorGlowGroup[12];
	new sHudGeneralPosition[32];

	formatex(sWeapons, charsmax(sWeapons), "%d %d %d", g_Weapons[id][WEAPON_AUTO_BUY], g_Weapons[id][WEAPON_PRIMARY_SELECTION], g_Weapons[id][WEAPON_SECONDARY_SELECTION]);
	arrayToString(g_UserOptions_Color[id][COLOR_TYPE_HUD_GENERAL], 3, sColorHudGeneral, charsmax(sColorHudGeneral), 1);
	arrayToString(g_UserOptions_Color[id][COLOR_TYPE_GLOW_GROUP], 3, sColorGlowGroup, charsmax(sColorGlowGroup), 1);
	formatex(sHudGeneralPosition, charsmax(sHudGeneralPosition), "%0.2f %0.2f %0.2f", g_UserOptions_Hud[id][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[id][HUD_TYPE_GENERAL][1], g_UserOptions_Hud[id][HUD_TYPE_GENERAL][2]);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_pjs SET ei_antidote_buy='%d', weapons=^"%s^", hc='%d', zc='%d', sc='%d', nc='%d', skin_choosed='%d', knife_choosed='%d', hat_choosed='%d', exp='%d', level='%d', level_range='%d', points='%d', points_lose='%d', color_hud_general=^"%s^", color_glow_group=^"%s^", hud_general_position=^"%s^", hud_general_effect='%d', hud_general_style='%d', uo_invis='%d', uo_clanchat='%d', uo_glowingroup='%d' WHERE acc_id='%d';", g_ExtraItem_InRound[id][EXTRA_ITEM_ANTIDOTE], sWeapons, g_HumanClassNext[id], g_ZombieClassNext[id], g_SurvivorClassNext[id], g_NemesisClassNext[id], g_Skin_Choosed[id], g_Knife_Choosed[id], g_Hat_Choosed[id], g_XP[id], g_Level[id], g_Range[id], g_Points[id], g_PointsLose[id], sColorHudGeneral, sColorGlowGroup, sHudGeneralPosition, g_UserOptions_HudEffect[id][HUD_TYPE_GENERAL], g_UserOptions_HudStyle[id][HUD_TYPE_GENERAL], g_UserOptions_Invis[id], g_UserOptions_ClanChat[id], g_UserOptions_GlowInGroup[id], g_AccountId[id]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_pjs_stats SET time_played='%d', human_kill_done='%d', human_kill_take='%d', zombie_kill_done='%d', zombie_kill_take='%d', infection_done='%d', infection_take='%d', survivor_done='%d', nemesis_done='%d', zombie_kill_hs_done='%d', zombie_kill_hs_take='%d', zombie_kill_knife_done='%d', zombie_kill_knife_take='%d', armor_done='%d', armor_take='%d', escape_done='%d', achievements_done='%d', supplybox_done='%d' WHERE acc_id='%d';", g_TimePlayed[id][TIME_PLAYED_MIN], g_Stats[id][STAT_HK_DONE], g_Stats[id][STAT_HK_TAKE], g_Stats[id][STAT_ZK_DONE], g_Stats[id][STAT_ZK_TAKE], g_Stats[id][STAT_I_DONE], g_Stats[id][STAT_I_TAKE], g_Stats[id][STAT_SURVIVOR_DONE], g_Stats[id][STAT_NEMESIS_DONE], g_Stats[id][STAT_ZK_HS_DONE], g_Stats[id][STAT_ZK_HS_TAKE], g_Stats[id][STAT_ZK_KNIFE_DONE], g_Stats[id][STAT_ZK_KNIFE_TAKE], g_Stats[id][STAT_ARMOR_DONE], g_Stats[id][STAT_ARMOR_TAKE], g_Stats[id][STAT_ESCAPES_DONE], g_Stats[id][STAT_ACHIEVEMENTS_DONE], g_Stats[id][STAT_SUPPLYBOX_DONE], g_AccountId[id]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
}

public showMenu__Banned(const id) {
	oldmenu_create("\y%s \r-\y %s \r(%s)^n\dby %s", "menu__Banned", __PLUGIN_COMMUNITY_NAME, __PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	oldmenu_additem(-1, -1, "\yTU CUENTA HA SIDO BANEADA\r:");
	oldmenu_additem(-1, -1, "\r - \wAdministrador\r:\y %s", g_AccountBanned_StaffName[id]);
	oldmenu_additem(-1, -1, "\r - \wFecha de Inicio\r:\y %s",  getUnixToTime(g_AccountBanned_Start[id]));
	oldmenu_additem(-1, -1, "\r - \wFecha de Finalización\r:\y %s", getUnixToTime(g_AccountBanned_Finish[id]));
	oldmenu_additem(-1, -1, "\r - \wRazón\r:\y %s^n", g_AccountBanned_Reason[id]);

	oldmenu_additem(0, 0, "\r0.\w Salir del servidor");
	oldmenu_display(id);
}

public menu__Banned(const id, const item) {
	if(item == 0) {
		server_cmd("kick #%d ^"Tu cuenta ha sido baneada. Para consultar sobre la misma, haz la queja en el foro %s^"", get_user_userid(id), __PLUGIN_COMMUNITY_FORUM);
	}
}

public checkEvents() {
	g_HappyHour = 0;
	g_EventModes = 0;

	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new iTimeToUnix[3];

	unix_to_time(iSysTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);

	iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 22, 00, 00);
	iTimeToUnix[2] = time_to_unix(iYear, iMonth, iDay, 00, 00, 00);
	iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 09, 59, 00);

	if((iSysTime >= iTimeToUnix[0]) || (iSysTime >= iTimeToUnix[2] && iSysTime <= iTimeToUnix[1])) {
		g_HappyHour = 1;

		iTimeToUnix[0] = time_to_unix(iYear, iMonth, iDay, 00, 15, 00);
		iTimeToUnix[1] = time_to_unix(iYear, iMonth, iDay, 01, 45, 00);

		if(iSysTime >= iTimeToUnix[0] && iSysTime < iTimeToUnix[1]) {
			g_EventModes = 1;
		}
	}

	checkAuto_ModeJeruzalem();
}

public checkAuto_ModeJeruzalem() {
	if(g_AutoMode_Jeruzalem_Count >= 2) {
		g_AutoMode_Jeruzalem_Enabled = 0;
		return;
	}

	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new i;

	unix_to_time(iSysTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	i = time_to_unix(iYear, iMonth, iDay, 21, 00, 00);

	if(iSysTime >= i) {
		g_AutoMode_Jeruzalem_Enabled = 1;

		if(g_AutoMode_Jeruzalem_RoundsLeft) {
			clientPrintColor(0, _, "En !g%d ronda%s!y comenzará el modo !gJeruzalem!y!", g_AutoMode_Jeruzalem_RoundsLeft, ((g_AutoMode_Jeruzalem_RoundsLeft != 1) ? "s" : ""));
		} else {
			clientPrintColor(0, _, "En !gla siguiente ronda!y comenzará otro modo !gJeruzalem!y!");
		}
	}
}

public checkAutoModeJeruzalem() {
	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new i;
	new iDifference;

	unix_to_time(iSysTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	i = time_to_unix(iYear, iMonth, iDay, 21, 00, 00);

	iDifference = (i - iSysTime);

	if(iDifference >= -3600 && iDifference <= 3600) {
		set_task(600.0, "task__AutoMode_Jeruzalem");
		loadAutoModes();
	}
}

public task__AutoMode_Jeruzalem() {
	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new i;
	new iDifference;

	unix_to_time(iSysTime, iYear, iMonth, iDay, iHour, iMinute, iSecond);
	i = time_to_unix(iYear, iMonth, iDay, 21, 00, 00);

	iDifference = (i - iSysTime);

	if(iDifference < 0) {
		return;
	}

	new iMins = (iDifference / 60);

	clientPrintColor(0, _, "En !g%d minutos!y aproximadamente saldrá el modo !gJeruzalem!y", (iMins + 5));

	set_task(600.0, "task__AutoMode_Jeruzalem");
}

public loadAutoModes() {
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT automode_jeruzalem_rounds, automode_jeruzalem_count FROM ze3_general WHERE id='1';");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadAutoModes", g_SqlQuery);
}

public sqlThread__LoadAutoModes(const failstate, const Handle:query, const error[], const errorNum, const data[], const size, const Float:queuetime) {
	if(failstate != TQUERY_SUCCESS)	{
		log_to_file(__SQL_FILE, "sqlThread__LoadAutoModes() - [%d] - <%s>", errorNum, error);
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

public task__VirusT() {
	set_hudmessage(0, 125, 200, -1.0, 0.25, random_num(0, 1), 0.0, 3.0, 2.0, 1.0);
	ShowSyncHudMsg(0, g_HudSync_Event, "¡EL VIRUS-T SE HA LIBERADO!");

	if(g_HappyHour) {
		clientPrintColor(0, _, "!tDRUNK AT NITE!y: Tu multiplicador de XP aumenta un !g+x2!y");

		if(g_EventModes) {
			clientPrintColor(0, _, "!tEVENTO DE MODOS!y: Solo saldrán modos especiales");
		}
	}
}

public task__StartMode() {
	startModePre(MODE_NONE);
}

startModePre(const mode, id=0, fake_mode=0) {
	if(g_AutoMode_Jeruzalem_Enabled && g_AutoMode_Jeruzalem_Count < 2) {
		if(!g_AutoMode_Jeruzalem_RoundsLeft) {
			startModePost(MODE_JERUZALEM, id, fake_mode);
			return;
		} else {
			--g_AutoMode_Jeruzalem_RoundsLeft;

			formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_general SET automode_jeruzalem_rounds='%d' WHERE id='1';", g_AutoMode_Jeruzalem_RoundsLeft);
			SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
		}
	}

	new iUsersAlive = getUsersAlive();

	if(mode == MODE_NONE) {
		if(iUsersAlive < 4 && !id) {
			clientPrint(0, print_center, "Se necesitan +4 jugadores vivos para que comience un modo");

			set_task(10.0, "task__StartMode", TASK_STARTMODE);
			return;
		}
	}

	g_NewRound = 0;

	if(mode != MODE_NONE) {
		if(g_CurrentMode != MODE_INFECTION && g_CurrentMode != MODE_SWARM && g_CurrentMode != MODE_MULTI && g_CurrentMode != MODE_PLAGUE) {
			g_NextMode = g_CurrentMode;
		}

		g_CurrentMode = mode;

		startModePost(g_CurrentMode, id, fake_mode);
		chooseMode();

		return;
	}

	startModePost(g_CurrentMode, id, fake_mode);
	chooseMode();
}

chooseMode() {
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
			MODE_SWARM, MODE_PLAGUE, MODE_ARMAGEDDON, MODE_SURVIVOR, MODE_NEMESIS, MODE_NEMESIS_X, MODE_JERUZALEM
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

startModePost(const mode, id=0, fake_mode=0) {
	client_cmd(0, "stopsound");

	remove_task(TASK_VIRUST);
	remove_task(TASK_COUNTDOWN);
	remove_task(TASK_STARTMODE);

	// g_FirstRound = 0;
	g_Mode = mode;
	g_LastMode = mode;

	new Float:flDelayAmbience;
	new iUsersAlive;
	new iMaxZombies;
	new iZombies;
	new i;

	flDelayAmbience = 2.0;
	iUsersAlive = getUsersAlive();
	iMaxZombies = 0;
	iZombies = 0;

	switch(mode) {
		case MODE_INFECTION: {
			if(!id) {
				if(iUsersAlive < 4) {
					iMaxZombies = 1;
				} else {
					iMaxZombies = floatround((iUsersAlive * 0.16), floatround_ceil);
				}

				iZombies = 0;

				while(iZombies < iMaxZombies) {
					id = getRandomAlive(random_num(1, iUsersAlive));

					if(!g_IsAlive[id] || g_Zombie[id] || g_ZombieBack[id]) {
						continue;
					}

					zombieMe(id, .first_zombie=1);

					g_ZombieBack[id] = 1;
					g_ImmunityBombs[id] = 1;

					remove_task(id + TASK_IMMUNITY_BOMBS);
					set_task(20.0, "task__RemoveImmunityBombs", id + TASK_IMMUNITY_BOMBS);

					++iZombies;
				}
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(g_Zombie[i] || id == i) {
					randomSpawn(i);
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_HudSync_Event, "INFECCIÓN^n%d jugador%s ha%s sido infectado%s", iZombies, ((iZombies != 1) ? "es" : ""), ((iZombies != 1) ? "n" : ""), ((iZombies != 1) ? "s" : ""));

			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);
		} case MODE_SWARM: {
			// if(!getUsersAliveTs()) {
				// id = getRandomAlive(random_num(1, iUsersAlive));
				// setUserTeam(id, TEAM_TERRORIST);
			// } else if(!getUsersAliveCTs()) {
				// id = getRandomAlive(random_num(1, iUsersAlive));
				// setUserTeam(id, TEAM_CT);
			// }

			new iAlreadyChoosen[MAX_PLAYERS + 1];

			iMaxZombies = (iUsersAlive / 2);
			iZombies = 0;

			while(iZombies < iMaxZombies) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(iAlreadyChoosen[id]) {
					continue;
				}

				iAlreadyChoosen[id] = 1;
				++iZombies;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				// if(getUserTeam(i) != TEAM_TERRORIST) {
					// continue;
				// }

				if(iAlreadyChoosen[i]) {
					zombieMe(i, .silent_mode=1);
				} else {
					if(getUserTeam(i) != TEAM_CT) {
						setUserTeam(i, TEAM_CT);
					}
				}
			}

			// set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			// ShowSyncHudMsg(0, g_HudSync_Event, "¡SWARM!");

			showDHUDMessage(0, 0, 255, 0, -1.0, -1.0, random_num(0, 1), 10.0, "¡SWARM!");
			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);
		} case MODE_MULTI: {
			iMaxZombies = (iUsersAlive / 3);
			iZombies = 0;
			id = 0;

			while(iZombies < iMaxZombies) {
				if(++id > MaxClients) {
					id = 1;
				}

				if(!g_IsAlive[id] || g_Zombie[id]) {
					continue;
				}

				if(random_num(0, 1)) {
					zombieMe(id);

					++iZombies;
				}
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(g_Zombie[i]) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_HudSync_Event, "¡INFECCION MULTIPLE!");

			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);
		} case MODE_PLAGUE: {
			iMaxZombies = 1;
			iZombies = 0;

			while(iZombies < iMaxZombies) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id] == MODE_SURVIVOR) {
					continue;
				}

				humanMe(id, .survivor=1);

				++iZombies;
			}

			iMaxZombies = 1;
			iZombies = 0;

			while(iZombies < iMaxZombies) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(g_SpecialMode[id] == MODE_SURVIVOR || g_SpecialMode[id] == MODE_NEMESIS) {
					continue;
				}

				zombieMe(id, .nemesis=1);

				++iZombies;
			}

			iMaxZombies = floatround(((iUsersAlive - 2) * 0.5), floatround_ceil);
			iZombies = 0;
			id = 0;

			while(iZombies < iMaxZombies) {
				if(++id > MaxClients) {
					id = 1;
				}

				if(!g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] == MODE_SURVIVOR) {
					continue;
				}

				if(random_num(0, 1)) {
					zombieMe(id, .silent_mode=1);

					++iZombies;
				}
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || g_Zombie[i] || g_SpecialMode[i] == MODE_SURVIVOR) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_HudSync_Event, "¡PLAGUE!");

			playSound(0, __SOUND_ROUND_GENERAL[random_num(0, charsmax(__SOUND_ROUND_GENERAL))]);
		} case MODE_ARMAGEDDON: {
			// if(!getUsersAliveTs()) {
				// id = getRandomAlive(random_num(1, iUsersAlive));
				// setUserTeam(id, TEAM_TERRORIST);
			// } else if(!getUsersAliveCTs()) {
				// id = getRandomAlive(random_num(1, iUsersAlive));
				// setUserTeam(id, TEAM_CT);
			// }

			playSound(0, __SOUND_ROUND_ARMAGEDDON);

			flDelayAmbience = 20.0;

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				g_Speed[i] = 100.0;
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);
			}

			message_begin(MSG_BROADCAST, g_Message_ScreenFade);
			write_short((UNIT_SECOND * 4));
			write_short(floatround(UNIT_SECOND * 12.2));
			write_short(FFADE_OUT);
			write_byte(0);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			message_end();

			remove_task(TASK_MODE_ARMAGEDDON_1);
			remove_task(TASK_MODE_ARMAGEDDON_3);
			remove_task(TASK_MODE_ARMAGEDDON_4);

			set_task(0.1, "task__Armageddon1", TASK_MODE_ARMAGEDDON_1);
			set_task(10.0, "task__Armageddon3", TASK_MODE_ARMAGEDDON_3);
			set_task(12.0, "task__Armageddon4", TASK_MODE_ARMAGEDDON_4);
		} case MODE_SURVIVOR: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			humanMe(id, .survivor=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(id == i) {
					continue;
				}

				zombieMe(i, .silent_mode=1);
			}

			set_hudmessage(0, 0, 255, -1.0, 0.25, 0, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_HudSync_Event, "¡%s ES SURVIVOR!", g_PlayerName[id]);

			playSound(0, __SOUND_ROUND_MODES[random_num(0, charsmax(__SOUND_ROUND_MODES))]);
		} case MODE_NEMESIS: {
			if(!id) {
				id = getRandomAlive(random_num(1, iUsersAlive));
			}

			zombieMe(id, .nemesis=1);

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(id == i) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			set_hudmessage(255, 0, 0, -1.0, 0.25, 0, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_HudSync_Event, "¡%s ES NEMESIS!", g_PlayerName[id]);

			playSound(0, __SOUND_ROUND_MODES[random_num(0, charsmax(__SOUND_ROUND_MODES))]);
		} case MODE_NEMESIS_X: {
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

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i] || g_Zombie[i] || g_SpecialMode[i] == MODE_NEMESIS) {
					continue;
				}

				if(getUserTeam(i) != TEAM_CT) {
					setUserTeam(i, TEAM_CT);
				}
			}

			set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_HudSync_Event, "¡NEMESIS EXTREMO!");

			playSound(0, __SOUND_ROUND_MODES[random_num(0, charsmax(__SOUND_ROUND_MODES))]);
		} case MODE_JERUZALEM: {
			if(!getUsersAliveTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_TERRORIST);
			} else if(!getUsersAliveCTs()) {
				id = getRandomAlive(random_num(1, iUsersAlive));
				setUserTeam(id, TEAM_CT);
			}

			new i;
			new iMaxHumans = (iUsersAlive / 2);
			new iHumans = 0;
			new iAlreadyChoosen[MAX_PLAYERS + 1];
			new iVIPs[2];
			new iMaxVIPs = 0;

			g_VIPsDead = 0;
			g_ModeJeruzalem_AlreadyRewarded = false;

			while(iHumans < iMaxHumans) {
				id = getRandomAlive(random_num(1, iUsersAlive));

				if(iAlreadyChoosen[id]) {
					continue;
				}

				iAlreadyChoosen[id] = 1;

				if(iMaxVIPs < 2) {
					iVIPs[iMaxVIPs] = id;
					++g_VIPsDead;
				}

				++iHumans;
				++iMaxVIPs;
			}

			for(i = 1; i <= MaxClients; ++i) {
				if(!g_IsAlive[i]) {
					continue;
				}

				if(iAlreadyChoosen[i]) {
					if(getUserTeam(i) != TEAM_CT) {
						setUserTeam(i, TEAM_CT);
					}

					if(i == iVIPs[0] || i == iVIPs[1]) {
						humanMe(i, .vip=1);
					}
				} else {
					zombieMe(i, .silent_mode=1);
					randomSpawn(i);
				}
			}

			set_hudmessage(0, 255, 128, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
			ShowSyncHudMsg(0, g_HudSync_Event, "¡JERUZALEM!^n^nVIPS:^n%s^n%s", g_PlayerName[iVIPs[0]], g_PlayerName[iVIPs[1]]);

			if(!fake_mode) {
				++g_AutoMode_Jeruzalem_Count;

				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_general SET automode_jeruzalem_count='%d' WHERE id='1';", g_AutoMode_Jeruzalem_Count);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
			}
		}
	}

	alertMode(mode);

	if(g_AmbienceSounds[g_Mode]) {
		remove_task(TASK_AMBIENCESOUNDS);
		set_task(flDelayAmbience, "task__AmbienceSoundsEffect", TASK_AMBIENCESOUNDS);
	}

	ExecuteForward(g_fwdRoundStarted, g_fwdDummy, mode, id);
}

public task__CountDown() {
	if(!g_NewRound) {
		return;
	}

	if(g_CountDown >= 0) {
		playSound(0, __SOUND_COUNTDOWN[g_CountDown]);

		set_hudmessage(random(256), random(256), random(256), -1.0, 0.2725, 2, 0.02, 1.0, 0.01, 0.1, 10);

		if(g_CountDown > 0) {
			ShowSyncHudMsg(0, g_HudSync_CountDown, "-----------------------------------------^n¡Nueva amenaza en %d segundo%s!^n-----------------------------------------", g_CountDown, ((g_CountDown != 1) ? "s" : ""));
		}
	}

	--g_CountDown;

	if(g_CountDown > 0) {
		set_task(1.0, "task__CountDown", TASK_COUNTDOWN);
	} else {
		remove_task(TASK_COUNTDOWN);
	}
}

public task__ZombieBack() {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i] && !g_Zombie[i] && g_ZombieBack[i]) {
			g_ZombieBack[i] = 0;
		}
	}
}

public getRandomAlive(const n) {
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
			if(g_IsConnected[i] && g_AccountLogged[i]) {
				g_Points[i] += iPointsReward;
			}
		}

		clientPrintColor(0, _, "Todos los jugadores conectados ganaron !g%d pL!y", iPointsReward);
		clientPrintColor(0, _, "Felicidades, el modo !g%s!y se jugó !g%s ve%s!y", __MODES[mode][modeName], sModeCount, ((g_ModeCount[mode] != 1) ? "ces" : "z"));
	} else {
		clientPrintColor(0, _, "El modo !g%s!y se jugó !g%s ve%s!y", __MODES[mode][modeName], sModeCount, ((g_ModeCount[mode] != 1) ? "ces" : "z"));
	}

	new sModeCountSave[256];
	arrayToString(g_ModeCount, structIdModes, sModeCountSave, charsmax(sModeCountSave), 1);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_general SET modes=^"%s^" WHERE id='1';", sModeCountSave);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
}

public task__Armageddon1() {
	set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
	ShowSyncHudMsg(0, g_HudSync_Event, "¡EL FIN HA LLEGADO!");

	remove_task(TASK_MODE_ARMAGEDDON_2);
	set_task(4.3, "task__Armageddon2", TASK_MODE_ARMAGEDDON_2);
}

public task__Armageddon2() {
	set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 3.0, 7.0, 7.0, 3.0, -1);
	ShowSyncHudMsg(0, g_HudSync_Event, "¡ARMAGEDDON!");
}

public task__Armageddon3() {
	message_begin(MSG_BROADCAST, g_Message_ScreenFade);
	write_short((UNIT_SECOND * 4));
	write_short(floatround(UNIT_SECOND * 1.0));
	write_short(FFADE_IN);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
}

public task__Armageddon4() {
	new iUsersAlive = getUsersAlive();
	new iMaxHumans = (iUsersAlive / 2);
	new iHumans = 0;
	new iId;
	new iAlreadyChoosen[MAX_PLAYERS + 1];
	new i;

	while(iHumans < iMaxHumans) {
		iId = getRandomAlive(random_num(1, iUsersAlive));	

		if(iAlreadyChoosen[iId]) {
			continue;
		}

		iAlreadyChoosen[iId] = 1;
		++iHumans;
	}

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			if(iAlreadyChoosen[i]) {
				humanMe(i, .survivor=1);
			} else {
				zombieMe(i, .nemesis=1);
			}
		}
	}
}

public getUsersAliveTs() {
	new iCount = 0;
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			iTeam = getUserTeam(i);

			if((iTeam == TEAM_TERRORIST)) {
				++iCount;
			}
		}
	}

	return iCount;
}

public getUsersAliveCTs() {
	new iCount = 0;
	new i;
	new TeamName:iTeam;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i]) {
			iTeam = getUserTeam(i);

			if((iTeam == TEAM_CT)) {
				++iCount;
			}
		}
	}

	return iCount;
}

emitSound(const id, const channel, const sample[], const Float:volume=1.0, const Float:attn=ATTN_NORM, const flags=0, const pitch=PITCH_NORM) {
	emit_sound(id, channel, sample, volume, attn, flags, pitch);
}

public event__Intermission() {
	remove_task(TASK_AMBIENCESOUNDS);
	client_cmd(0, "mp3 stop; stopsound");
}

public event__Health(const id) {
	g_Health[id] = get_user_health(id);
}

public event__ShowStatus(const id) {
	if(g_IsConnected[id]) {
		static iTarget;
		iTarget = read_data(2);

		if(g_Zombie[id] == g_Zombie[iTarget]) {
			static sHealth[8];
			addDot(g_Health[iTarget], sHealth, charsmax(sHealth));

			if(g_Zombie[id]) {
				set_hudmessage(255, 50, 0, -1.0, 0.6, 1, 0.01, 3.0, 0.01, 0.01, -1);
			} else {
				set_hudmessage(0, 50, 255, -1.0, 0.6, 1, 0.01, 3.0, 0.01, 0.01, -1);
			}

			ShowSyncHudMsg(id, g_HudSync_Player, "%s^n%s^n[Vida: %s | Chaleco: %d]^n[Nivel: %d | Rango: %s]", g_PlayerClassName[iTarget], g_PlayerName[iTarget], sHealth, get_user_armor(iTarget), g_Level[iTarget], __RANGES[g_Range[iTarget]]);
		}
	}
}

public event__HideStatus(const id) {
	ClearSyncHud(id, g_HudSync_Player);
}

public task__HelloAgain(const task_id) {
	new iId = (task_id - TASK_HELLO_AGAIN);

	if(!g_IsConnected[iId] || !g_AccountLogged[iId] || g_AccountLoading[iId]) {
		return;
	}

	new iArgs[1];
	iArgs[0] = iId;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT COUNT(acc_id) AS rank FROM ze3_pjs u WHERE (u.level > (SELECT level FROM ze3_pjs u2 WHERE u2.acc_id='%d') OR (u.level = (SELECT level FROM ze3_pjs u2 WHERE u2.acc_id='%d') AND u.acc_id<='%d'));", g_AccountId[iId], g_AccountId[iId], g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadRanking", g_SqlQuery, iArgs, sizeof(iArgs));
}

public sqlThread__LoadRanking(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadRanking() - [%d] - <%s>", error_num, error);

		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar tu ranking. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		g_AccountRanking[iId] = SQL_ReadResult(query, 0);
	} else {
		g_AccountRanking[iId] = 0;
	}

	if(g_BuyStuff[iId]) {
		new iArgs[1];
		iArgs[0] = iId;

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT * FROM ze3_buys WHERE acc_id='%d' AND bought_ok='0';", g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__LoadBuys", g_SqlQuery, iArgs, sizeof(iArgs));
	}
}

public sqlThread__LoadBuys(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];

	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__LoadBuys() - [%d] - <%s>", error_num, error);

		g_AccountRegister[iId] = 0;
		g_AccountLogged[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al cargar tu compra. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(SQL_NumResults(query)) {
		new iPL;

		while(SQL_MoreResults(query)) {
			iPL = SQL_ReadResult(query, SQL_FieldNameToNum(query, "p_legacy"));

			g_Points[iId] += iPL;

			clientPrintColor(iId, _, "Tu compra de !g%d pL!y se ha acreditado con éxito", iPL);
			SQL_NextRow(query);
		}

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_pjs SET bought_ok='0' WHERE acc_id='%d' AND bought_ok='1';", g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_buys SET bought_ok='1' WHERE acc_id='%d' AND bought_ok='0';", g_AccountId[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

		formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_payments SET ok='1' WHERE member_id='%d' AND ok='0';", g_AccountVinc[iId]);
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
	}

	g_BuyStuff[iId] = 0;
}

public clcmd__Ranking(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	if(!g_AccountRanking[id]) {
		clientPrintColor(id, _, "No se ha detectado tu ranking");
		return PLUGIN_HANDLED;
	}

	clientPrintColor(id, _, "Tu ranking es !g%d / %d!y", g_AccountRanking[id], g_GlobalRank);
	return PLUGIN_HANDLED;
}

public ham__PlayerSpawnPost(const id) {
	if(!is_user_alive(id) || getUserTeam(id) == TEAM_UNASSIGNED) {
		return;
	}

	g_IsAlive[id] = _:is_user_alive(id);

	remove_task(id + TASK_SPAWN);
	remove_task(id + TASK_NVISION);
	remove_task(id + TASK_BURN_FLAME);
	remove_task(id + TASK_MADNESS_BOMB);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_BUTTONED);
	remove_task(id + TASK_POWER_ZOMBIE);
	remove_task(id + TASK_HUMAN_MEDICO_ACTIVE);
	remove_task(id + TASK_ZOMBIE_VOODOO);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE_WAIT);
	remove_task(id + TASK_ZOMBIE_FARAHON);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_ACTIVE);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_AURA);

	g_MadnessBomb_Count[id] = 0;
	g_MadnessBomb_Move[id] = 0;

	randomSpawn(id);

	if(g_Mode != MODE_ARMAGEDDON) {
		set_task(2.0, "task__RespawnUserCheck", id + TASK_SPAWN);
	} else {
		user_silentkill(id);

		clientPrintColor(id, _, "No puedes revivir en la mitad del modo Armageddon");
		return;
	}

	if(!g_NewRound && !g_EndRound) {
		if(g_Mode == MODE_SURVIVOR) {
			g_RespawnAsZombie[id] = 1;
		} else if(g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_X) {
			g_RespawnAsZombie[id] = 0;
		}
	}

	if(g_RespawnAsZombie[id] && !g_NewRound) {
		resetVars(id, 0);

		zombieMe(id);
		return;
	}

	resetVars(id, 0);

	set_task(0.19, "task__ClearWeapons", id + TASK_SPAWN);
	set_task(0.2, "task__ShowMenuWeapons", id + TASK_SPAWN);

	if(g_Skin[id] != g_Skin_Choosed[id]) {
		g_Skin[id] = g_Skin_Choosed[id];
	}

	if(g_Knife[id] != g_Knife_Choosed[id]) {
		g_Knife[id] = g_Knife_Choosed[id];
	}

	updatePlayerHat(id);

	if(g_HumanClass[id] != g_HumanClassNext[id]) {
		g_HumanClass[id] = g_HumanClassNext[id];
	}

	set_user_health(id, humanHealth(id, g_HumanClass[id]));
	g_Speed[id] = Float:humanSpeed(id, g_HumanClass[id]);
	set_user_gravity(id, Float:humanGravity(id, g_HumanClass[id]));

	new iArmor = 0;

	if(g_HumanClass[id] == HUMAN_CLASS_SNIPER) {
		iArmor = 20;

		if((get_user_flags(id) & ADMIN_RESERVATION)) {
			iArmor += 80;

			if((get_user_flags(id) & ADMIN_IMMUNITY)) {
				iArmor += 0;
			}
		}
	} else if(g_HumanClass[id] == HUMAN_CLASS_CENTINELA) {
		iArmor = 20;

		if((get_user_flags(id) & ADMIN_RESERVATION)) {
			iArmor += 80;

			if((get_user_flags(id) & ADMIN_IMMUNITY)) {
				iArmor += 0;
			}
		}
	} else {
		iArmor = 0;

		if((get_user_flags(id) & ADMIN_RESERVATION)) {
			iArmor += 100;

			if((get_user_flags(id) & ADMIN_IMMUNITY)) {
				iArmor += 0;
			}
		}
	}

	set_user_armor(id, iArmor);

	copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), __HUMAN_CLASSES[g_HumanClass[id]][humanClassName]);

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	
	// if(!g_NewRound && getUserTeam(id) != TEAM_CT) {
		// setUserTeam(id, TEAM_CT);
	// }

	set_user_rendering(id);
	checkHumanPowers(id);
	setUserAllModels(id);
	turnOffFlashlight(id);

	new iWeaponEnt = getCurrentWeaponEnt(id);

	if(pev_valid(iWeaponEnt)) {
		replaceWeaponModels(id, cs_get_weapon_id(iWeaponEnt));
	}

	checkLastZombie();

	if(!g_NewRound && !g_EndRound && g_ClanSlot[id]) {
		clanUpdateHumans(id);
	}
}

humanHealth(const id, const class, const level=0) {
	new iHealth = __HUMAN_CLASSES[class][humanClassHealth];

	if(level) {
		iHealth += ((level - 1) * 1);
	} else {
		if(g_Level[id]) {
			iHealth += ((g_Level[id] - 1) * 1);
		}
	}

	return iHealth;
}

Float:humanSpeed(const id, const class, const level=0) {
	new Float:flSpeed = __HUMAN_CLASSES[class][humanClassSpeed];

	if(level) {
		flSpeed += ((level - 1.0) * 0.013);
	} else {
		if(g_Level[id]) {
			flSpeed += ((g_Level[id] - 1.0) * 0.013);
		}
	}

	return flSpeed;
}

Float:humanGravity(const id, const class, const level=0) {
	new Float:flGravity = __HUMAN_CLASSES[class][humanClassGravity];

	if(level) {
		flGravity -= ((level - 1.0) * 0.0006);
	} else {
		if(g_Level[id]) {
			flGravity -= ((g_Level[id] - 1.0) * 0.0006);
		}
	}

	return flGravity;
}

Float:humanDamage(const id, const level=0) {
	new Float:flDamage = 0.0;

	if(level) {
		flDamage += (((float(level) - 1.0) * 40.0) / 100.0);
	} else {
		if(g_Level[id]) {
			flDamage += (((float(g_Level[id]) - 1.0) * 40.0) / 100.0);
		}
	}

	return flDamage;
}

zombieHealth(const id, const class, const level=0) {
	new iHealth = __ZOMBIE_CLASSES[class][zombieClassHealth];

	if(level) {
		iHealth += ((level - 1) * 5);
	} else {
		if(g_Level[id]) {
			iHealth += ((g_Level[id] - 1) * 5);
		}
	}

	return iHealth;
}

Float:zombieSpeed(const id, const class, const level=0) {
	new Float:flSpeed = __ZOMBIE_CLASSES[class][zombieClassSpeed];

	if(level) {
		flSpeed += ((level - 1) * 0.013);
	} else {
		if(g_Level[id]) {
			flSpeed += ((g_Level[id] - 1) * 0.013);
		}
	}

	return flSpeed;
}

Float:zombieGravity(const id, const class, const level=0) {
	new Float:flGravity = __ZOMBIE_CLASSES[class][zombieClassGravity];

	if(level) {
		flGravity -= ((level - 1) * 0.0006);
	} else {
		if(g_Level[id]) {
			flGravity -= ((g_Level[id] - 1) * 0.0006);
		}
	}

	return flGravity;
}

public getCurrentWeaponEnt(const id) {
	if(pev_valid(id) != PDATA_SAFE) {
		return -1;
	}

	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

public ham__PlayerKilledPre(const victim, const killer, const should_gib) {
	g_IsAlive[victim] = 0;
	g_Immunity[victim] = 0;
	g_ImmunityBombs[victim] = 0;
	g_ImmunityFire[victim] = 0;
	g_ImmunityFrost[victim] = 0;
	g_MadnessBomb_Count[victim] = 0;
	g_MadnessBomb_Move[victim] = 0;
	g_ZombieClass_BansheeStat[victim] = 0;
	g_ZombieClass_BansheeOwner[victim] = 0;

	remove_task(victim + TASK_BURN_FLAME);

	if(g_Frozen[victim]) {
		removeFrostCube(victim);
		remove_task(victim + TASK_FROZEN);
	}

	remove_task(victim + TASK_IMMUNITY_BOMBS);
	remove_task(victim + TASK_BUTTONED);
	remove_task(victim + TASK_POWER_ZOMBIE);
	remove_task(victim + TASK_HUMAN_MEDICO_ACTIVE);

	if(g_Zombie[victim]) {
		remove_task(victim + TASK_MADNESS_BOMB);
		remove_task(victim + TASK_ZOMBIE_VOODOO);
		remove_task(victim + TASK_ZOMBIE_LUSTY_ROSE);
		remove_task(victim + TASK_ZOMBIE_LUSTY_ROSE_WAIT);
		remove_task(victim + TASK_ZOMBIE_FARAHON);
		remove_task(victim + TASK_ZOMBIE_FLESHPOUND);
		remove_task(victim + TASK_ZOMBIE_FLESHPOUND_ACTIVE);
		remove_task(victim + TASK_ZOMBIE_FLESHPOUND_AURA);

		if(g_SpecialMode[victim]) {
			SetHamParamInteger(3, 2);
		}
	} else {
		if(g_ClanSlot[victim]) {
			clanUpdateHumans(victim);
		}
	}

	set_user_rendering(victim);

	set_task(0.2, "task__SpectNVision", victim);

	if(g_SpecialMode[victim] == MODE_JERUZALEM) {
		--g_VIPsDead;

		if(!g_VIPsDead) {
			modeJeruzalemFinish(TEAM_TERRORIST);
		}
	}

	if(victim == killer || !isUserValidConnected(killer)) {
		return;
	}

	if(!g_Zombie[killer]) {
		++g_Stats[killer][STAT_ZK_DONE];
		++g_Stats[victim][STAT_ZK_TAKE];

		if(g_Stats[killer][STAT_ZK_DONE] >= 25) {
			setAchievement(killer, x25_ZOMBIES);

			if(g_Stats[killer][STAT_ZK_DONE] >= 50) {
				setAchievement(killer, x50_ZOMBIES);

				if(g_Stats[killer][STAT_ZK_DONE] >= 100) {
					setAchievement(killer, x100_ZOMBIES);

					if(g_Stats[killer][STAT_ZK_DONE] >= 250) {
						setAchievement(killer, x250_ZOMBIES);

						if(g_Stats[killer][STAT_ZK_DONE] >= 500) {
							setAchievement(killer, x500_ZOMBIES);

							if(g_Stats[killer][STAT_ZK_DONE] >= 750) {
								setAchievement(killer, x750_ZOMBIES);

								if(g_Stats[killer][STAT_ZK_DONE] >= 1000) {
									setAchievement(killer, x1000_ZOMBIES);

									if(g_Stats[killer][STAT_ZK_DONE] >= 2500) {
										setAchievement(killer, x2500_ZOMBIES);

										if(g_Stats[killer][STAT_ZK_DONE] >= 5000) {
											setAchievement(killer, x5000_ZOMBIES);

											if(g_Stats[killer][STAT_ZK_DONE] >= 7500) {
												setAchievement(killer, x7500_ZOMBIES);

												if(g_Stats[killer][STAT_ZK_DONE] >= 10000) {
													setAchievement(killer, x10000_ZOMBIES);

													if(g_Stats[killer][STAT_ZK_DONE] >= 15000) {
														setAchievement(killer, x15000_ZOMBIES);

														if(g_Stats[killer][STAT_ZK_DONE] >= 20000) {
															setAchievement(killer, x20000_ZOMBIES);

															if(g_Stats[killer][STAT_ZK_DONE] >= 25000) {
																setAchievement(killer, x25000_ZOMBIES);

																if(g_Stats[killer][STAT_ZK_DONE] >= 35000) {
																	setAchievement(killer, x35000_ZOMBIES);

																	if(g_Stats[killer][STAT_ZK_DONE] >= 45000) {
																		setAchievement(killer, x45000_ZOMBIES);

																		if(g_Stats[killer][STAT_ZK_DONE] >= 55000) {
																			setAchievement(killer, x55000_ZOMBIES);

																			if(g_Stats[killer][STAT_ZK_DONE] >= 75000) {
																				setAchievement(killer, x75000_ZOMBIES);
																				
																				if(g_Stats[killer][STAT_ZK_DONE] >= 100000) {
																					setAchievement(killer, x100000_ZOMBIES);
																							
																					if(g_Stats[killer][STAT_ZK_DONE] >= 125000) {
																						setAchievement(killer, x125000_ZOMBIES);
																								
																						if(g_Stats[killer][STAT_ZK_DONE] >= 150000) {
																							setAchievement(killer, x150000_ZOMBIES);
																									
																							if(g_Stats[killer][STAT_ZK_DONE] >= 175000) {
																								setAchievement(killer, x175000_ZOMBIES);
																								
																								if(g_Stats[killer][STAT_ZK_DONE] >= 2000000) {
																									setAchievement(killer, x200000_ZOMBIES);
																									
																									if(g_Stats[killer][STAT_ZK_DONE] >= 225000) {
																										setAchievement(killer, x225000_ZOMBIES);
																										
																										if(g_Stats[killer][STAT_ZK_DONE] >= 250000) {
																											setAchievement(killer, x250000_ZOMBIES);
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

		if(g_ClanSlot[killer] && g_Clan[g_ClanSlot[killer]][clanCountOnlineMembers] > 1) {
			++g_Clan[g_ClanSlot[killer]][clanKillsZombieDone];
		}

		if(should_gib == 1) {
			if(g_CurrentWeapon[killer] == CSW_KNIFE) {
				++g_Stats[killer][STAT_ZK_KNIFE_DONE];
				++g_Stats[victim][STAT_ZK_KNIFE_TAKE];

				if(!g_SpecialMode[killer] && g_Stats[killer][STAT_ZK_KNIFE_DONE] == 1) {
					setAchievement(killer, AFILANDO_CUCHILLO);
				}

				if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD) {
					++g_Stats[killer][STAT_ZK_HS_DONE];
					++g_Stats[victim][STAT_ZK_HS_TAKE];

					if(g_Stats[killer][STAT_ZK_HS_DONE] == 1000) {
						setAchievement(killer, LIDER_EN_CABEZAS);
					} else if(g_Stats[killer][STAT_ZK_HS_DONE] == 10000) {
						setAchievement(killer, AGUJEREANDO_CABEZAS);
					}
				}
			} else {
				if(get_pdata_int(victim, OFFSET_HITZONE) == HIT_HEAD) {
					++g_Stats[killer][STAT_ZK_HS_DONE];
					++g_Stats[victim][STAT_ZK_HS_TAKE];
				}
			}
		}
	} else {
		++g_Stats[killer][STAT_HK_DONE];
		++g_Stats[victim][STAT_HK_TAKE];

		if(g_ClanSlot[killer] && g_Clan[g_ClanSlot[killer]][clanCountOnlineMembers] > 1) {
			++g_Clan[g_ClanSlot[killer]][clanKillsHumanDone];
		}
	}

	if(!g_SpecialMode[killer]) {
		giveXP(killer, __HAPPY_HOUR[g_HappyHour][hhXPKillReward]);
		g_APs[killer] += g_APsRewardKill[killer];
	}

	if(g_SpecialMode[victim]) {
		switch(g_SpecialMode[victim]) {
			case MODE_SURVIVOR: {
				++g_Stats[killer][STAT_SURVIVOR_DONE];

				if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 10) {
					setAchievement(killer, x10_SURVIVORS);

					if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 25) {
						setAchievement(killer, x25_SURVIVORS);

						if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 50) {
							setAchievement(killer, x50_SURVIVORS);

							if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 100) {
								setAchievement(killer, x100_SURVIVORS);

								if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 200) {
									setAchievement(killer, x200_SURVIVORS);

									if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 300) {
										setAchievement(killer, x300_SURVIVORS);

										if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 400) {
											setAchievement(killer, x400_SURVIVORS);

											if(g_Stats[killer][STAT_SURVIVOR_DONE] >= 500) {
												setAchievement(killer, x500_SURVIVORS);
											}
										}
									}
								}
							}
						}
					}
				}
			} case MODE_NEMESIS: {
				++g_Stats[killer][STAT_NEMESIS_DONE];

				if(g_Stats[killer][STAT_NEMESIS_DONE] >= 10) {
					setAchievement(killer, x10_NEMESIS);

					if(g_Stats[killer][STAT_NEMESIS_DONE] >= 25) {
						setAchievement(killer, x25_NEMESIS);

						if(g_Stats[killer][STAT_NEMESIS_DONE] >= 50) {
							setAchievement(killer, x50_NEMESIS);

							if(g_Stats[killer][STAT_NEMESIS_DONE] >= 100) {
								setAchievement(killer, x100_NEMESIS);

								if(g_Stats[killer][STAT_NEMESIS_DONE] >= 200) {
									setAchievement(killer, x200_NEMESIS);

									if(g_Stats[killer][STAT_NEMESIS_DONE] >= 300) {
										setAchievement(killer, x300_NEMESIS);

										if(g_Stats[killer][STAT_NEMESIS_DONE] >= 400) {
											setAchievement(killer, x400_NEMESIS);

											if(g_Stats[killer][STAT_NEMESIS_DONE] >= 500) {
												setAchievement(killer, x500_NEMESIS);
											}
										}
									}
								}
							}
						}
					}
				}
			} case MODE_JERUZALEM: {
				g_Points[killer] += 10;
				clientPrintColor(0, _, "El zombie !t%s!y ganó !g+10 pL!y por matar a un !gVIP!y", g_PlayerName[killer]);

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

public updateRewardsByFlags(const id) {
	new iUserFlags = get_user_flags(id);

	if((iUserFlags & ADMIN_RESERVATION)) {
		g_APsRewardKill[id] = __HAPPY_HOUR[g_HappyHour][hhAPsKillReward_Vip];
		g_APsRewardDamage[id] = __HAPPY_HOUR[g_HappyHour][hhAPsDamageReward_Vip];
		g_APsRewradInfect[id] = __HAPPY_HOUR[g_HappyHour][hhAPsInfectionReward_Vip];
	} else {
		g_APsRewardKill[id] = __HAPPY_HOUR[g_HappyHour][hhAPsKillReward_Normal];
		g_APsRewardDamage[id] = __HAPPY_HOUR[g_HappyHour][hhAPsDamageReward_Normal];
		g_APsRewradInfect[id] = __HAPPY_HOUR[g_HappyHour][hhAPsInfectionReward_Normal];
	}
}

public ham__PlayerKilledPost(const victim) {
	checkLastZombie();

	set_task(1.0, "task__RespawnUser", victim + TASK_SPAWN);
}

public task__RespawnUser(const task_id) {
	new iId = (task_id - TASK_SPAWN);

	if(g_IsAlive[iId] || g_EndRound || (g_Mode != MODE_NEMESIS_X && g_MapEscaped)) {
		return;
	}

	new TeamName:iTeam = getUserTeam(iId);

	if((iTeam == TEAM_UNASSIGNED) || (iTeam == TEAM_SPECTATOR)) {
		return;
	}

	if(g_NewRound || g_Mode == MODE_NEMESIS_X) {
		if(g_Mode == MODE_NEMESIS_X) {
			g_RespawnAsZombie[iId] = 0;
		} else {
			g_RespawnAsZombie[iId] = 1;
		}
	
		respawnUser(iId);
	}
}

public task__RespawnUserCheck(const task_id) {
	new iId = (task_id - TASK_SPAWN);

	if(g_IsAlive[iId] || g_EndRound) {
		return;
	}

	new TeamName:iTeam = getUserTeam(iId);

	if((iTeam == TEAM_UNASSIGNED) || (iTeam == TEAM_SPECTATOR)) {
		return;
	}

	g_RespawnAsZombie[iId] = g_Zombie[iId];
	respawnUser(iId);
}

public respawnUser(const id) {
	setUserTeam(id, ((g_RespawnAsZombie[id]) ? TEAM_TERRORIST : TEAM_CT));
	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public isHullVacant(const Float:vecOrigin[3], const hull) {
	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, hull, 0, 0);

	if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen)) {
		return 1;
	}

	return 0;
}

public isUserStuck(const id) {
	new Float:vecOrigin[3];
	new iHull = ((get_entvar(id, var_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN);

	get_entvar(id, var_origin, vecOrigin);

	return (trace_hull(vecOrigin, iHull, id, DONT_IGNORE_MONSTERS) != 0);
}

public task__CheckStuck(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	if(isUserStuck(id)) {
		randomSpawn(id);
	}
}

public randomSpawn(const id) {
	if(!g_SpawnCount) {
		return;
	}

	new iHull = ((get_entity_flags(id) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN);
	new iSpawnId = random_num(0, (g_SpawnCount - 1));
	new i;

	for(i = iSpawnId + 1;; ++i) {
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

public loadSpawns() {
	new const __SPAWN_NAME_ENTS[][] = {"info_player_start", "info_player_deathmatch"};
	new Float:vecOrigin[3];
	new iEnt;
	new i;

	for(i = 0; i < sizeof(__SPAWN_NAME_ENTS); ++i) {
		iEnt = -1;

		while((iEnt = find_ent_by_class(iEnt, __SPAWN_NAME_ENTS[i])) != 0) {
			entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);

			g_Spawns[g_SpawnCount][0] = vecOrigin[0];
			g_Spawns[g_SpawnCount][1] = vecOrigin[1];
			g_Spawns[g_SpawnCount][2] = vecOrigin[2];

			++g_SpawnCount;

			if(g_SpawnCount >= 64) {
				break;
			}
		}

		if(g_SpawnCount >= 64) {
			break;
		}
	}
}

public ham__UseStationaryPre(const entity, const caller, const activator, const use_type) {
	if(use_type == 2 && isUserValidConnected(caller) && g_Zombie[caller]) {
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public ham__UseStationaryPost(const entity, const caller, const activator, const use_type) {
	if(!use_type && isUserValidConnected(caller)) {
		replaceWeaponModels(caller, g_CurrentWeapon[caller]);
	}
}

public ham__UsePushablePre() {
	return HAM_SUPERCEDE;
}

public ham__TouchWeaponPre(const weapon, const id) {
	if(!isUserValidConnected(id)) {
		return HAM_IGNORED;
	}

	if(g_Zombie[id] || g_SpecialMode[id]) {
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public replaceWeaponModels(const id, const weapon_id) {
	switch(weapon_id) {
		case CSW_KNIFE: {
			if(g_Zombie[id]) {
				new sBuffer[128];
				sBuffer[0] = EOS;

				if(g_SpecialMode[id] == MODE_NEMESIS) {
					formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", __PLAYER_MODEL_NEMESIS, __PLAYER_MODEL_NEMESIS);
					entity_set_string(id, EV_SZ_viewmodel, sBuffer);
				} else {
					if(g_ZombieClass[id] == ZOMBIE_CLASS_LUSTY_ROSE && g_ZombieClass_LustyRoseActive[id] == 2) {
						formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s_power.mdl", __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel], __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]);
						entity_set_string(id, EV_SZ_viewmodel, sBuffer);
					} else {
						formatex(sBuffer, charsmax(sBuffer), "models/player/%s/v_%s.mdl", __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel], __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]);
						entity_set_string(id, EV_SZ_viewmodel, sBuffer);
					}
				}

				entity_set_string(id, EV_SZ_weaponmodel, "");
			} else {
				if(g_Knife[id]) {
					if(__KNIFES[g_Knife[id]][knifeModelNameV][0] && __KNIFES[g_Knife[id]][knifeModelNameP][0]) {
						entity_set_string(id, EV_SZ_viewmodel, __KNIFES[g_Knife[id]][knifeModelNameV]);
						entity_set_string(id, EV_SZ_weaponmodel, __KNIFES[g_Knife[id]][knifeModelNameP]);
					} else {
						entity_set_string(id, EV_SZ_viewmodel, "models/v_knife.mdl");
						entity_set_string(id, EV_SZ_weaponmodel, "models/p_knife.mdl");
					}
				} else {
					entity_set_string(id, EV_SZ_viewmodel, "models/v_knife.mdl");
					entity_set_string(id, EV_SZ_weaponmodel, "models/p_knife.mdl");
				}
			}
		} case CSW_HEGRENADE: {
			if(g_Zombie[id]) {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_INFECTION_V);
				entity_set_string(id, EV_SZ_weaponmodel, __GRENADE_MODEL_INFECTION_P);
			} else {
				if(g_MadnessBomb[id]) {
					entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_MADNESS_V);
				} else {
					entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_FIRE_V);
				}
			}
		} case CSW_FLASHBANG: {
			if(g_Zombie[id]) {

			} else {
				entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_FROST_V);
			}
		} case CSW_SMOKEGRENADE: {
			if(g_Zombie[id]) {

			} else {
				if(g_BubbleBomb[id]) {
					entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_BUBBLE_V);
				} else {
					entity_set_string(id, EV_SZ_viewmodel, __GRENADE_MODEL_EXPLOSIVE_V);
				}
			}
		} default: {
			if(g_SpecialMode[id] == MODE_SURVIVOR && g_CurrentWeapon[id] == CSW_M249) {
				entity_set_string(id, EV_SZ_viewmodel, __WEAPON_MODEL_SURVIVOR_V);
				entity_set_string(id, EV_SZ_weaponmodel, __WEAPON_MODEL_SURVIVOR_P);
			} else {
				if(g_TypeWeapon[id] == 1 && g_CurrentWeapon[id] == __PRIMARY_WEAPONS[g_Weapons[id][WEAPON_PRIMARY_CURRENT]][weaponCSW] && __PRIMARY_WEAPONS[g_Weapons[id][WEAPON_PRIMARY_CURRENT]][weaponModel][0]) {
					entity_set_string(id, EV_SZ_viewmodel, __PRIMARY_WEAPONS[g_Weapons[id][WEAPON_PRIMARY_CURRENT]][weaponModel]);
				} else if(g_TypeWeapon[id] == 2 && g_CurrentWeapon[id] == __SECONDARY_WEAPONS[g_Weapons[id][WEAPON_SECONDARY_CURRENT]][weaponCSW] && __SECONDARY_WEAPONS[g_Weapons[id][WEAPON_SECONDARY_CURRENT]][weaponModel][0]) {
					entity_set_string(id, EV_SZ_viewmodel, __SECONDARY_WEAPONS[g_Weapons[id][WEAPON_SECONDARY_CURRENT]][weaponModel]);
				}
			}
		}
	}
}

humanMe(const id, silent_mode=0, survivor=0, vip=0) {
	remove_task(id + TASK_NVISION);
	remove_task(id + TASK_BURN_FLAME);
	remove_task(id + TASK_IMMUNITY_BOMBS);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_POWER_ZOMBIE);
	remove_task(id + TASK_HUMAN_MEDICO_ACTIVE);
	remove_task(id + TASK_ZOMBIE_VOODOO);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE_WAIT);
	remove_task(id + TASK_ZOMBIE_FARAHON);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_ACTIVE);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_AURA);

	g_Zombie[id] = 0;
	g_SpecialMode[id] = 0;
	g_FirstZombie[id] = 0;
	g_Immunity[id] = 0;
	g_ZombieClass_LustyRoseActive[id] = 0;
	g_Weapons[id][WEAPON_PRIMARY_CURRENT] = 0;
	g_Weapons[id][WEAPON_PRIMARY_BOUGHT] = 0;
	g_Weapons[id][WEAPON_SECONDARY_CURRENT] = 0;
	g_Weapons[id][WEAPON_SECONDARY_BOUGHT] = 0;

	clanUpdateHumans(id);

	if(g_Frozen[id]) {
		removeFrostCube(id);

		remove_task(id + TASK_FROZEN);
		task__RemoveFreeze(id + TASK_FROZEN);
	}

	setUserUnlimitedClip(id, 0);
	
	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	set_user_rendering(id);

	if(g_Skin[id] != g_Skin_Choosed[id]) {
		g_Skin[id] = g_Skin_Choosed[id];
	}

	if(g_Knife[id] != g_Knife_Choosed[id]) {
		g_Knife[id] = g_Knife_Choosed[id];
	}

	updatePlayerHat(id);

	if(g_HumanClass[id] != g_HumanClassNext[id]) {
		g_HumanClass[id] = g_HumanClassNext[id];
	}

	if(g_SurvivorClass[id] != g_SurvivorClassNext[id]) {
		g_SurvivorClass[id] = g_SurvivorClassNext[id];
	}

	new iHealth;
	new Float:flSpeed;
	new Float:flGravity;

	if(survivor) {
		g_SpecialMode[id] = MODE_SURVIVOR;

		iHealth = __SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassHealth];
		flSpeed = Float:__SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassSpeed];
		flGravity = Float:__SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassGravity];

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		give_item(id, "weapon_m249");
		setUserUnlimitedClip(id, 1);

		if(g_Mode == MODE_PLAGUE) {
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 4);
		}

		formatex(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Survivor %s", __SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassNameMin]);
	} else {
		set_task(0.19, "task__ClearWeapons", id + TASK_SPAWN);
		set_task(0.2, "task__ShowMenuWeapons", id + TASK_SPAWN);
		
		iHealth = humanHealth(id, g_HumanClass[id]);
		flSpeed = Float:humanSpeed(id, g_HumanClass[id]);
		flGravity = Float:humanGravity(id, g_HumanClass[id]);

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		if(g_HumanClass[id] == HUMAN_CLASS_SNIPER) {
			set_user_armor(id, 50);

			if((get_user_flags(id) & ADMIN_IMMUNITY)) {
				set_user_armor(id, 125);
			}
		} else if(g_HumanClass[id] == HUMAN_CLASS_CENTINELA) {
			set_user_armor(id, 10);

			if((get_user_flags(id) & ADMIN_IMMUNITY)) {
				set_user_armor(id, 75);
			}
		} else {
			set_user_armor(id, 0);

			if((get_user_flags(id) & ADMIN_IMMUNITY)) {
				set_user_armor(id, 100);
			}
		}

		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), __HUMAN_CLASSES[g_HumanClass[id]][humanClassName]);

		if(!silent_mode) {
			emitSound(id, CHAN_ITEM, __SOUND_ANTIDOTE);
		}

		if(vip) {
			set_task(0.5, "task__ActivateVIP", id + TASK_SPAWN);
		}
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != TEAM_CT) {
		setUserTeam(id, TEAM_CT);
	}

	setUserAllModels(id);
	checkHumanPowers(id);

	message_begin(MSG_ONE, g_Message_Fov, _, id);
	write_byte(90);
	message_end();

	if(g_SpecialMode[id]) {
		setUserNVision(id, 1);
	}

	ExecuteForward(g_fwdHUserdumanizedPost, g_fwdDummy, id, silent_mode, survivor);

	checkLastZombie();
}

public task__ClearWeapons(const task_id) {
	new iId = (task_id - TASK_SPAWN);

	if(!g_IsAlive[iId]) {
		return;
	}

	strip_user_weapons(iId);
	give_item(iId, "weapon_knife");
}

public task__ShowMenuWeapons(const task_id) {
	new iId = (task_id - TASK_SPAWN);

	if(!g_IsConnected[iId]) {
		return;
	}

	if(g_Weapons[iId][WEAPON_AUTO_BUY] && task_id > MaxClients) {
		if(!g_IsAlive[iId] || g_Zombie[iId] || g_SpecialMode[iId] || checkWeaponBuy(iId)) {
			return;
		}

		buyPrimaryWeapon(iId, g_Weapons[iId][WEAPON_PRIMARY_SELECTION]);
		buySecondaryWeapon(iId, g_Weapons[iId][WEAPON_SECONDARY_SELECTION]);
		buyGrenades(iId);

		g_Weapons[iId][WEAPON_PRIMARY_BOUGHT] = 1;
		g_Weapons[iId][WEAPON_SECONDARY_BOUGHT] = 1;

		return;
	}

	showMenu__PrimaryWeapons(iId, g_MenuPage[iId][MENU_PAGE_WPN_P]);

	if(g_HumanClass[iId] == HUMAN_CLASS_RADIOACTIVO) {
		set_user_rendering(iId, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 4);
	} else if(g_HumanClass[iId] == HUMAN_CLASS_MEDICO) {
		set_user_rendering(iId, kRenderFxGlowShell, 64, 64, 64, kRenderNormal, 4);
	} else {
		set_user_rendering(iId);
	}
}

zombieMe(const id, attacker=0, silent_mode=0, bomb=0, first_zombie=0, nemesis=0) {
	if(!g_IsAlive[id]) {
		return;
	}

	remove_task(id + TASK_NVISION);
	remove_task(id + TASK_BURN_FLAME);
	remove_task(id + TASK_IMMUNITY_BOMBS);
	remove_task(id + TASK_MADNESS);
	remove_task(id + TASK_POWER_ZOMBIE);
	remove_task(id + TASK_HUMAN_MEDICO_ACTIVE);
	remove_task(id + TASK_ZOMBIE_VOODOO);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE);
	remove_task(id + TASK_ZOMBIE_LUSTY_ROSE_WAIT);
	remove_task(id + TASK_ZOMBIE_FARAHON);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_ACTIVE);
	remove_task(id + TASK_ZOMBIE_FLESHPOUND_AURA);

	g_Zombie[id] = 1;
	g_SpecialMode[id] = 0;
	g_FirstZombie[id] = 0;
	g_Immunity[id] = 0;
	g_ZombieClass_LustyRoseActive[id] = 0;
	g_Weapons[id][WEAPON_PRIMARY_CURRENT] = 0;
	g_Weapons[id][WEAPON_PRIMARY_BOUGHT] = 0;
	g_Weapons[id][WEAPON_SECONDARY_CURRENT] = 0;
	g_Weapons[id][WEAPON_SECONDARY_BOUGHT] = 0;

	clanUpdateHumans(id);

	cs_set_user_zoom(id, CS_RESET_ZOOM, 1);
	set_user_armor(id, 0);

	setUserUnlimitedClip(id, 0);

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	set_user_rendering(id);

	updatePlayerHat(id);

	if(g_ZombieClass[id] != g_ZombieClassNext[id]) {
		g_ZombieClass[id] = g_ZombieClassNext[id];
	}

	if(g_NemesisClass[id] != g_NemesisClassNext[id]) {
		g_NemesisClass[id] = g_NemesisClassNext[id];
	}

	new iHealth;
	new Float:flSpeed;
	new Float:flGravity;

	if(attacker) {
		if(!bomb) {
			giveXP(attacker, __HAPPY_HOUR[g_HappyHour][hhXPRewardInfection]);
			g_APs[attacker] += g_APsRewradInfect[attacker];
		} else {

		}

		g_ImmunityBombs[attacker] = 0;

		remove_task(attacker + TASK_IMMUNITY_BOMBS);

		++g_Stats[attacker][STAT_I_DONE];
		++g_Stats[id][STAT_I_TAKE];

		if(g_Stats[attacker][STAT_I_DONE] >= 25) {
			setAchievement(attacker, x25_INFECTIONS);

			if(g_Stats[attacker][STAT_I_DONE] >= 50) {
				setAchievement(attacker, x50_INFECTIONS);

				if(g_Stats[attacker][STAT_I_DONE] >= 100) {
					setAchievement(attacker, x100_INFECTIONS);

					if(g_Stats[attacker][STAT_I_DONE] >= 250) {
						setAchievement(attacker, x250_INFECTIONS);

						if(g_Stats[attacker][STAT_I_DONE] >= 500) {
							setAchievement(attacker, x500_INFECTIONS);

							if(g_Stats[attacker][STAT_I_DONE] >= 750) {
								setAchievement(attacker, x750_INFECTIONS);

								if(g_Stats[attacker][STAT_I_DONE] >= 1000) {
									setAchievement(attacker, x1000_INFECTIONS);

									if(g_Stats[attacker][STAT_I_DONE] >= 2500) {
										setAchievement(attacker, x2500_INFECTIONS);

										if(g_Stats[attacker][STAT_I_DONE] >= 5000) {
											setAchievement(attacker, x5000_INFECTIONS);

											if(g_Stats[attacker][STAT_I_DONE] >= 7500) {
												setAchievement(attacker, x7500_INFECTIONS);

												if(g_Stats[attacker][STAT_I_DONE] >= 10000) {
													setAchievement(attacker, x10000_INFECTIONS);

													if(g_Stats[attacker][STAT_I_DONE] >= 15000) {
														setAchievement(attacker, x15000_INFECTIONS);

														if(g_Stats[attacker][STAT_I_DONE] >= 20000) {
															setAchievement(attacker, x20000_INFECTIONS);

															if(g_Stats[attacker][STAT_I_DONE] >= 25000) {
																setAchievement(attacker, x25000_INFECTIONS);

																if(g_Stats[attacker][STAT_I_DONE] >= 35000) {
																	setAchievement(attacker, x35000_INFECTIONS);

																	if(g_Stats[attacker][STAT_I_DONE] >= 45000) {
																		setAchievement(attacker, x45000_INFECTIONS);

																		if(g_Stats[attacker][STAT_I_DONE] >= 55000) {
																			setAchievement(attacker, x55000_INFECTIONS);
																			
																			if(g_Stats[attacker][STAT_I_DONE] >= 75000) {
																				setAchievement(attacker, x75000_INFECTIONS);
																				
																				if(g_Stats[attacker][STAT_I_DONE] >= 100000) {
																					setAchievement(attacker, x100000_INFECTIONS);
																				
																					if(g_Stats[attacker][STAT_I_DONE] >= 125000) {
																						setAchievement(attacker, x125000_INFECTIONS);
																				
																						if(g_Stats[attacker][STAT_I_DONE] >= 150000) {
																							setAchievement(attacker, x150000_INFECTIONS);
																				
																							if(g_Stats[attacker][STAT_I_DONE] >= 175000) {
																								setAchievement(attacker, x175000_INFECTIONS);
																				
																								if(g_Stats[attacker][STAT_I_DONE] >= 200000) {
																									setAchievement(attacker, x200000_INFECTIONS);
																				
																									if(g_Stats[attacker][STAT_I_DONE] >= 225000) {
																										setAchievement(attacker, x225000_INFECTIONS);
																				
																										if(g_Stats[attacker][STAT_I_DONE] >= 75000) {
																											setAchievement(attacker, x250000_INFECTIONS);
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

		if(g_ClanSlot[attacker] && g_Clan[g_ClanSlot[attacker]][clanCountOnlineMembers] > 1) {
			++g_Clan[g_ClanSlot[attacker]][clanInfectionsDone];
		}

		iHealth = zombieHealth(id, g_ZombieClass[id]);
		flSpeed = Float:zombieSpeed(id, g_ZombieClass[id]);
		flGravity = Float:zombieGravity(id, g_ZombieClass[id]);

		set_user_health(id, iHealth);
		g_Speed[id] = flSpeed;
		set_user_gravity(id, flGravity);

		emitSound(id, CHAN_VOICE, __SOUND_ZOMBIE_INFECT[random_num(0, charsmax(__SOUND_ZOMBIE_INFECT))]);
		
		copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);

		sendDeathMsg(attacker, id);
		fixDeadAttrib(id);

		replaceWeaponModels(id, CSW_KNIFE);
	} else {
		if(!silent_mode) {
			if(nemesis) {
				g_SpecialMode[id] = MODE_NEMESIS;

				iHealth = __NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassHealth];
				flSpeed = Float:__NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassSpeed];
				flGravity = Float:__NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassGravity];

				set_user_health(id, iHealth);
				g_Speed[id] = flSpeed;
				set_user_gravity(id, flGravity);

				if(g_Mode == MODE_PLAGUE) {
					set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
				}

				formatex(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), "Nemesis %s", __NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassNameMin]);

				replaceWeaponModels(id, CSW_KNIFE);
			} else {
				iHealth = zombieHealth(id, g_ZombieClass[id]);
				flSpeed = Float:zombieSpeed(id, g_ZombieClass[id]);
				flGravity = Float:zombieGravity(id, g_ZombieClass[id]);

				if(g_Mode == MODE_INFECTION && first_zombie) {
					g_FirstZombie[id] = 1;

					iHealth = 12000;
				}

				set_user_health(id, iHealth);
				g_Speed[id] = flSpeed;
				set_user_gravity(id, flGravity);

				emitSound(id, CHAN_VOICE, __SOUND_ZOMBIE_ALERT[random_num(0, charsmax(__SOUND_ZOMBIE_ALERT))]);

				copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);

				replaceWeaponModels(id, CSW_KNIFE);
			}
		} else {
			iHealth = zombieHealth(id, g_ZombieClass[id]);
			flSpeed = Float:zombieSpeed(id, g_ZombieClass[id]);
			flGravity = Float:zombieGravity(id, g_ZombieClass[id]);
			
			set_user_health(id, iHealth);
			g_Speed[id] = flSpeed;
			set_user_gravity(id, flGravity);

			copy(g_PlayerClassName[id], charsmax(g_PlayerClassName[]), __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);

			replaceWeaponModels(id, CSW_KNIFE);
		}
	}

	g_Health[id] = get_user_health(id);
	g_MaxHealth[id] = g_Health[id];

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

	if(getUserTeam(id) != TEAM_TERRORIST) {
		setUserTeam(id, TEAM_TERRORIST);
	}

	setUserAllModels(id);
	turnOffFlashlight(id);
	checkZombiePowers(id);

	if(g_Mode != MODE_ARMAGEDDON) {
		if(!g_Frozen[id]) {
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, id);
			write_short(UNIT_SECOND);
			write_short(0);
			write_short(FFADE_IN);
			write_byte((g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_X || g_Immunity[id]) ? 255 : 0);
			write_byte((g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_X || g_Immunity[id]) ? 0 : 255);
			write_byte((g_Mode == MODE_NEMESIS || g_Mode == MODE_NEMESIS_X || g_Immunity[id]) ? 0 : 0);
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

	setUserNVision(id, 1);

	ExecuteForward(g_fwdUserInfectedPost, g_fwdDummy, id, attacker, silent_mode, bomb, first_zombie, nemesis);

	checkLastZombie();
}

public ham__PlayerResetMaxSpeedPost(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	set_user_maxspeed(id, g_Speed[id]);
}

public fwd__ClientDisconnectPost() {
	checkLastZombie();
}

public fwd__ClientKillPre() {
	return FMRES_SUPERCEDE;
}

// public fwd__SetClientKeyValuePre(const id, const buffer[], const key[]) {
	// if(key[0] == 'n' && key[1] == 'a' && key[2] == 'm' && key[3] == 'e') {
		// return FMRES_SUPERCEDE;
	// }

	// return FMRES_IGNORED;
// }

// public fwd__ClientUserInfoChangedPre(const id, const buffer) {
	// if(!g_IsConnected[id]) {
		// return FMRES_IGNORED;
	// }

	// get_user_name(id, g_PlayerName[id], charsmax(g_PlayerName[]));

	// static sNewName[MAX_NAME_LENGTH];
	// engfunc(EngFunc_InfoKeyValue, buffer, "name", sNewName, charsmax(sNewName));

	// if(equal(sNewName, g_PlayerName[id])) {
		// return FMRES_IGNORED;
	// }

	// engfunc(EngFunc_SetClientKeyValue, id, buffer, "name", g_PlayerName[id]);
	// client_cmd(id, "name ^"%s^"; setinfo name ^"%s^"", g_PlayerName[id], g_PlayerName[id]);
	// set_user_info(id, "name", g_PlayerName[id]);

	// return FMRES_SUPERCEDE;
// }

public checkLastZombie() {
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
			g_LastHuman[i] = 1;

			if((g_Mode == MODE_INFECTION || g_Mode == MODE_MULTI) && !g_LastHuman_1000hp[i]) {
				g_LastHuman_1000hp[i] = 1;

				set_user_health(i, 1000);
				g_Health[i] = get_user_health(i);
			}
		} else {
			g_LastHuman[i] = 0;
		}
	}
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

public ham__PlayerTakeDamagePre(const victim, const inflictor, const attacker, Float:damage, const damage_type) {
	if(((g_NewRound || g_EndRound) || g_HumanClass[victim] == HUMAN_CLASS_RADIOACTIVO) && (damage_type & DMG_FALL)) {
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

	if(g_Immunity[victim] || g_Frozen[attacker] || g_Frozen[victim]) {
		return HAM_SUPERCEDE;
	}

	if(((g_InBubble[victim] && !g_Immunity[attacker]) && (g_InBubble[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker]))) {
		return HAM_SUPERCEDE;
	}

	if(!g_Zombie[attacker]) {
		damage += humanDamage(attacker);

		if(g_SpecialMode[attacker]) {
			switch(g_SpecialMode[attacker]) {
				case MODE_SURVIVOR: {
					damage += ((damage * 250.0) / 100.0);
				}
			}
		} else {
			switch(g_HumanClass[attacker]) {
				case HUMAN_CLASS_NINJA: {
					if(g_CurrentWeapon[attacker] == CSW_KNIFE) {
						damage += ((damage * 250.0) / 100.0);
					}
				} case HUMAN_CLASS_SNIPER: {
					if(g_CurrentWeapon[attacker] == CSW_SCOUT || g_CurrentWeapon[attacker] == CSW_AWP) {
						damage += ((damage * 100.0) / 100.0);
					}
				}
			}
		}

		SetHamParamFloat(4, damage);

		if(!g_SpecialMode[attacker]) {
			g_APsDamage[attacker] += damage;

			while(g_APsDamage[attacker] >= 1000.0) {
				g_APs[attacker] += g_APsRewardDamage[attacker];
				g_APsDamage[attacker] -= 1000.0;
			}
		}

		g_XPDamage[attacker] += damage;

		while(g_XPDamage[attacker] >= 2500.0) {
			giveXP(attacker, __HAPPY_HOUR[g_HappyHour][hhXPDamage]);
			g_XPDamage[attacker] -= 2500.0;
		}

		showBulletDamage(victim, attacker, damage, 0);
		return HAM_IGNORED;
	}

	if(damage_type & DMG_HEGRENADE) {
		return HAM_SUPERCEDE;
	}

	if(g_SpecialMode[attacker] == MODE_NEMESIS) {
		damage += (entity_get_int(attacker, EV_INT_button) & IN_ATTACK) ? 250.0 : 500.0;

		SetHamParamFloat(4, damage);
		return HAM_IGNORED;
	}

	static iArmor;
	iArmor = get_user_armor(victim);

	if(iArmor > 0) {
		static iDamage;
		static iRealDamage;

		iDamage = floatround(damage);
		iRealDamage = (iArmor - iDamage);

		g_Stats[attacker][STAT_ARMOR_DONE] += iDamage;
		g_Stats[victim][STAT_ARMOR_TAKE] += iDamage;

		if(iRealDamage > 0) {
			set_user_armor(victim, iRealDamage);
		} else {
			cs_set_user_armor(victim, 0, CS_ARMOR_NONE);
		}

		return HAM_SUPERCEDE;
	}

	if(g_Mode == MODE_SWARM || g_Mode == MODE_PLAGUE || g_Mode == MODE_JERUZALEM || g_SpecialMode[attacker] || getHumans() == 1) {
		showBulletDamage(victim, attacker, damage, 1);

		SetHamParamFloat(4, damage);
		return HAM_IGNORED;
	}

	zombieMe(victim, attacker);
	return HAM_SUPERCEDE;
}

public ham__PlayerTakeDamagePost(const victim) {
	if((g_Zombie[victim] && g_LastZombie[victim]) || (!g_Zombie[victim] && g_SpecialMode[victim])) {
		if(pev_valid(victim) != PDATA_SAFE) {
			return;
		}

		set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX);
	}
}

public turnOffFlashlight(const id) {
	entity_set_int(id, EV_INT_effects, entity_get_int(id, EV_INT_effects) & ~EF_DIMLIGHT);

	message_begin(MSG_ONE_UNRELIABLE, g_Message_Flashlight, _, id);
	write_byte(0);
	write_byte(100);
	message_end();

	entity_set_int(id, EV_INT_impulse, 0);
}

public message__Money(const msgId, const dest, const id) {
	if(g_IsConnected[id]) {
		cs_set_user_money(id, 0);
	}

	return PLUGIN_HANDLED;
}

public message__FlashBat(const msgId, const dest, const id) {
	if(get_msg_arg_int(1) < IMPULSE_FLASHLIGHT) {
		set_msg_arg_int(1, ARG_BYTE, IMPULSE_FLASHLIGHT);
		setUserBatteries(id, IMPULSE_FLASHLIGHT);
	}
}

public setUserBatteries(const id, const value) {
	if(pev_valid(id) != PDATA_SAFE) {
		return;
	}

	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX);
}

public message__Flashlight() {
	set_msg_arg_int(2, ARG_BYTE, IMPULSE_FLASHLIGHT);
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
		// g_FirstRound = 1;
		return PLUGIN_HANDLED;
	}

	if(equal(sTextMsg, "#Game_will_restart_in")) {
		// g_FirstRound = 1;
		g_ScoreHumans = 0;
		g_ScoreZombies = 0;
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

public fwd__SpawnPre(const ent) {
	if(!pev_valid(ent)) {
		return FMRES_IGNORED;
	}

	new sClassName[32];
	new i;

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

public fwd__SysErrorPre(const error[]) {
	log_to_file(__SERVER_FILE, "FORWARD: FM_Sys_Error | Error: %s | Mapa: %s", ((error[0]) ? error : "Ninguno"), g_MapName);
}

public fwd__GameShutdownPre(const error[]) {
	log_to_file(__SERVER_FILE, "FORWARD: FM_GameShutdown | Error: %s | Mapa: %s", ((error[0]) ? error : "Ninguno"), g_MapName);
}

public showMenu__Stats(const id) {
	oldmenu_create("\yESTADÍSTICAS", "menu__Stats");

	oldmenu_additem(1, 1, "\r1.\w Lista de niveles");
	oldmenu_additem(2, 2, "\r2.\w Top 15^n");

	oldmenu_additem(3, 3, "\r3.\w Estadísticas generales");
	oldmenu_additem(4, 4, "\r4.\w Ver todas mis estadísticas^n");

	new sAccount[8];
	new sForum[8];

	addDot(g_AccountId[id], sAccount, charsmax(sAccount));
	addDot(g_AccountVinc[id], sForum, charsmax(sForum));

	oldmenu_additem(-1, -1, "\wCUENTA\r:\y #%s", sAccount);
	oldmenu_additem(-1, -1, "\wVINCULADO AL FORO\r:\y %s \d(#%s)", ((g_AccountVinc[id]) ? "Si" : "No"), sForum);
	oldmenu_additem(-1, -1, "\wVINCULADO A LA APP MOBILE\r:\y %s", ((g_AccountVincAppMobile[id]) ? "Si" : "No"));
	
	new sBuffer1[16];
	new sBuffer2[16];
	new sBufferFinish[64];

	sBuffer1[0] = EOS;
	sBuffer2[0] = EOS;
	sBufferFinish[0] = EOS;

	if(g_TimePlayed[id][TIME_PLAYED_DAY] >= 1) {
		formatex(sBuffer1, charsmax(sBuffer1), "%d día%s", g_TimePlayed[id][TIME_PLAYED_DAY], ((g_TimePlayed[id][TIME_PLAYED_DAY] != 1) ? "s" : ""));
	}

	if(g_TimePlayed[id][TIME_PLAYED_HOUR] >= 1) {
		formatex(sBuffer2, charsmax(sBuffer2), "%d hora%s", g_TimePlayed[id][TIME_PLAYED_HOUR], ((g_TimePlayed[id][TIME_PLAYED_HOUR] != 1) ? "s" : ""));
	}

	format(sBufferFinish, charsmax(sBufferFinish), "%s%s%s", sBuffer1, ((sBuffer1[0] && sBuffer2[0]) ? " con " : ""), sBuffer2);

	if(sBuffer1[0] || sBuffer2[0]) {
		oldmenu_additem(-1, -1, "\wTIEMPO JUGADO\r:\y %s^n", sBufferFinish);
	} else {
		oldmenu_additem(-1, -1, "\wTIEMPO JUGADO\r:\y Nada^n");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public getLeaderPlayingTime() {
	new sBuffer1[16];
	new sBuffer2[16];
	new sBufferFinish[64];

	sBuffer1[0] = EOS;
	sBuffer2[0] = EOS;
	sBufferFinish[0] = EOS;

	if(g_LeaderTime_Time[TIME_PLAYED_DAY] >= 1) {
		formatex(sBuffer1, charsmax(sBuffer1), "%d día%s", g_LeaderTime_Time[TIME_PLAYED_DAY], ((g_LeaderTime_Time[TIME_PLAYED_DAY] != 1) ? "s" : ""));
	}

	if(g_LeaderTime_Time[TIME_PLAYED_HOUR] >= 1) {
		formatex(sBuffer2, charsmax(sBuffer2), "%d hora%s", g_LeaderTime_Time[TIME_PLAYED_HOUR], ((g_LeaderTime_Time[TIME_PLAYED_HOUR] != 1) ? "s" : ""));
	}

	if(sBuffer1[0] || sBuffer2[0]) {
		format(sBufferFinish, charsmax(sBufferFinish), "%s%s%s", sBuffer1, ((sBuffer1[0] && sBuffer2[0]) ? " con " : ""), sBuffer2);
	} else {
		format(sBufferFinish, charsmax(sBufferFinish), "Nada");
	}

	return sBufferFinish;
}

public menu__Stats(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			new iFix = calculatedPageLevels(id);

			if(iFix) {
				g_MenuPage[id][MENU_PAGE_STATS_LEVELS] = iFix;
			}

			showMenu__StatsLevels(id, g_MenuPage[id][MENU_PAGE_STATS_LEVELS]);
		} case 2: {
			showMenu__StatsTop15(id);
		} case 3: {
			showMenu__StatsGeneral(id);
		} case 4: {
			showMenu__Stats(id);

			new sTitle[64];
			new sUrl[256];
			
			formatex(sTitle, charsmax(sTitle), "Ver todas mis estadísticas");
			formatex(sUrl, charsmax(sUrl), "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=https://drunkgaming.net/tops/01_zombie_escape/users_all_stats.php?id=%d^"></head><body><p>Cargando...</p></body></html>", g_AccountId[id]);
			
			show_motd(id, sUrl, sTitle);
		}
	}
}

public calculatedPageLevels(const id) {
	new iLevel = g_Level[id];
	new iTotal = 1;

	while(iLevel >= 7) {
		++iTotal;
		iLevel -= 7;
	}

	return iTotal;
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
	oldmenu_create("\yLISTA DE NIVELES \r[%d - %d]\R\y%d / %d", "menu__StatsLevels", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		addDot((i + 1), sLevel, charsmax(sLevel));
		addDot(__XP_NEED[(i + 1)], sXP, charsmax(sXP));

		oldmenu_additem(j, i, "\r%d.%s Nivel\r:%s %s \r-%s XP\r:%s %s", j, ((g_Level[id] > i) ? "\w" : "\d"), ((g_Level[id] > i) ? "\y" : "\r"), sLevel, ((g_Level[id] > i) ? "\w" : "\d"), ((g_Level[id] > i) ? "\y" : "\r"), sXP);
	}

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

	new iXP = __XP_NEED[(value + 1)];
	new sXP[16];
	new sLevel[8];

	addDot(iXP, sXP, charsmax(sXP));
	addDot((value + 1), sLevel, charsmax(sLevel));

	clientPrintColor(id, _, "Te faltan !g%s XP!y para avanzar al !gnivel %s!y", sXP, sLevel);
	showMenu__StatsLevels(id, g_MenuPage[id][MENU_PAGE_STATS_LEVELS]);
}

public showMenu__StatsTop15(const id) {
	new iMenuId;
	new i;
	new sPosition[2];

	iMenuId = menu_create("TOP 15\R", "menu__StatsTop15");

	for(i = 0; i < sizeof(__TOP15); ++i) {
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, __TOP15[i][top15Name], sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_STATS_TOP15] = min(g_MenuPage[id][MENU_PAGE_STATS_TOP15], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_STATS_TOP15]);
}

public menu__StatsTop15(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_STATS_TOP15]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Stats(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];

	if(g_SysTime_Top15[id] > get_arg_systime()) {
		new iRest = (g_SysTime_Top15[id] - get_arg_systime());

		clientPrintColor(id, _, "Tenés que esperar !g%s!y para ver otro tipo de Top15", getCooldDownTime(iRest));

		showMenu__StatsTop15(id);
		return PLUGIN_HANDLED;
	}

	g_SysTime_Top15[id] = (get_arg_systime() + 5);

	new sBuffer[256];
	formatex(sBuffer, charsmax(sBuffer), "<html><head><style>body {background:#000;color:#FFF;}</style><meta http-equiv=^"Refresh^" content=^"0;url=http://drunkgaming.net/tops/01_zombie_escape/%s?id=%d^"></head><body><p>Cargando . . .</p></body></html>", __TOP15[iItemId][top15URL], g_AccountId[id]);
	show_motd(id, sBuffer, "TOP 15");

	showMenu__StatsTop15(id);
	return PLUGIN_HANDLED;
}

public showMenu__StatsGeneral(const id) {
	oldmenu_create("\yESTADÍSTICAS GENERALES \r[1 - 8]\y\R%d / 2", "menu__StatsGeneral", (g_MenuPage[id][MENU_PAGE_STATS_GENERAL] + 1));

	new sData[8];
	sData[0] = EOS;

	switch(g_MenuPage[id][MENU_PAGE_STATS_GENERAL]) {
		case 0: {
			addDot(g_Stats[id][STAT_HK_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wHumanos matados\r:\y %s", sData);

			addDot(g_Stats[id][STAT_HK_TAKE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wVeces muerto como humano\r:\y %s", sData);

			addDot(g_Stats[id][STAT_ZK_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wZombies matados\r:\y %s", sData);

			addDot(g_Stats[id][STAT_ZK_TAKE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wVeces muerto como zombie\r:\y %s", sData);

			addDot(g_Stats[id][STAT_I_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wInfecciones realizadas\r:\y %s", sData);

			addDot(g_Stats[id][STAT_I_TAKE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wInfecciones recibidas\r:\y %s", sData);

			addDot(g_Stats[id][STAT_SURVIVOR_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wSurvivors matados\r:\y %s", sData);

			addDot(g_Stats[id][STAT_NEMESIS_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wNemesis matados\r:\y %s", sData);
		} case 1: {
			addDot(g_Stats[id][STAT_ZK_HS_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wZombies matados a la cabeza\r:\y %s", sData);

			addDot(g_Stats[id][STAT_ZK_HS_TAKE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wVeces muerto como zombie en la cabeza\r:\y %s", sData);

			addDot(g_Stats[id][STAT_ZK_KNIFE_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wZombies matados con cuchillo\r:\y %s", sData);
			
			addDot(g_Stats[id][STAT_ZK_KNIFE_TAKE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wVeces muerto como zombie con cuchillo\r:\y %s", sData);

			addDot(g_Stats[id][STAT_ARMOR_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wChaleco desgarrado realizado\r:\y %s", sData);
			
			addDot(g_Stats[id][STAT_ARMOR_TAKE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wChaleco desgarrado recibido\r:\y %s", sData);

			addDot(g_Stats[id][STAT_ESCAPES_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wEscapes exitosos\r:\y %s", sData);

			addDot(g_Stats[id][STAT_ACHIEVEMENTS_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wLogros realizados\r:\y %s", sData);
		} case 2: {
			addDot(g_Stats[id][STAT_SUPPLYBOX_DONE], sData, charsmax(sData));
			oldmenu_additem(-1, -1, "\wCajas agarradas\r:\y %s", sData);
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

			if(g_MenuPage[id][MENU_PAGE_STATS_GENERAL] == 3) {
				g_MenuPage[id][MENU_PAGE_STATS_GENERAL] = 0;
			}

			showMenu__StatsGeneral(id);
		}
	}
}

public removeStuffInEndRound() {
	new iEnt = find_ent_by_class(-1, __ENT_CLASSNAME_SUPPLYBOX);

	while(iEnt > 0)	{
		remove_entity(iEnt);
		iEnt = find_ent_by_class(-1, __ENT_CLASSNAME_SUPPLYBOX);
	}
}

public task__AmbienceSoundsEffect() {
	if(!g_AmbienceSounds[g_Mode]) {
		return;
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			if((g_AmbienceSound_Muted[i] & __AMBIENCE_MUTED_SOUNDS[g_Mode][1]) == __AMBIENCE_MUTED_SOUNDS[g_Mode][1]) {
				continue;
			}

			playSound(i, __SOUND_AMBIENCE[g_Mode]);
		}
	}

	set_task(120.0, "task__AmbienceSoundsEffect", TASK_AMBIENCESOUNDS);
}

public showMenu__UserOptions(const id) {
	oldmenu_create("\yOPCIONES DE USUARIO", "menu__UserOptions");

	oldmenu_additem(1, 1, "\r1.\w Elegir colores");
	oldmenu_additem(2, 2, "\r2.\w Elegir música de ambiente^n");

	oldmenu_additem(3, 3, "\r3.\w Opciones de HUD General^n");

	switch(g_UserOptions_Invis[id]) {
		case 0: {
			oldmenu_additem(4, 4, "\r4.\w Humanos invisibles\r:\y No");
		} case 1: {
			oldmenu_additem(4, 4, "\r4.\w Humanos invisibles\r:\y Si");
		} case 2: {
			oldmenu_additem(4, 4, "\r4.\w Humanos invisibles\r:\y Si \d[Grupo]");
		}
	}

	if((get_user_flags(id) & ADMIN_LEVEL_D)) {
		oldmenu_additem(5, 5, "\r5.\w Ver chat de Clanes\r:\y %s", ((g_UserOptions_ClanChat[id]) ? "Si" : "No"));
	}

	oldmenu_additem(6, 6, "\r6.\w Glow en grupos:\y %s", ((g_UserOptions_GlowInGroup[id]) ? "Si" : "No"));

	oldmenu_additem(9, 9, "^n\r9.\w Vincular cuenta");

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
			showMenu__UserOptions_AmbienceSong(id);
		} case 3: {
			showMenu__UserOptions_Hud(id, HUD_TYPE_GENERAL);
		} case 4: {
			++g_UserOptions_Invis[id];

			if(g_UserOptions_Invis[id] == 3) {
				g_UserOptions_Invis[id] = 0;
			}

			showMenu__UserOptions(id);
		} case 5: {
			if((get_user_flags(id) & ADMIN_LEVEL_D)) {
				g_UserOptions_ClanChat[id] = !g_UserOptions_ClanChat[id];
			}

			showMenu__UserOptions(id);
		} case 6: {
			g_UserOptions_GlowInGroup[id] = !g_UserOptions_GlowInGroup[id];
			showMenu__UserOptions(id);
		} case 9: {
			showMenu__UserOptions_Vinc(id);
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
	}

	g_UserOptions_Color[id][g_MenuData[id][MENU_DATA_COLOR_CHOOSEN]][0] = __COLORS[value][colorRed];
	g_UserOptions_Color[id][g_MenuData[id][MENU_DATA_COLOR_CHOOSEN]][1] = __COLORS[value][colorGreen];
	g_UserOptions_Color[id][g_MenuData[id][MENU_DATA_COLOR_CHOOSEN]][2] = __COLORS[value][colorBlue];

	showMenu__UserOptions_ColorChoosen(id, g_MenuPage[id][MENU_PAGE_COLOR_CHOOSEN]);
}

public showMenu__UserOptions_AmbienceSong(const id) {
	new i;
	new j;

	oldmenu_create("\yELEGIR MÚSICA DE AMBIENTE", "menu__UserOptions_AmbienceSong");

	for(i = 0; i < structIdModes; ++i) {
		if(!__MODES[i][modeName][0]) {
			continue;
		}

		++j;

		oldmenu_additem(j, i, "\r%d.%s %s", j, (((g_AmbienceSound_Muted[id] & i) != i) ? "\w" : "\d"), __MODES[i][modeName]);
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__UserOptions_AmbienceSong(const id, const item, const value) {
	if(!item) {
		showMenu__UserOptions(id);
		return;
	}

	if((g_AmbienceSound_Muted[id] & (1<<(value))) != (1<<(value))) {
		g_AmbienceSound_Muted[id] |= (1<<(value));
	} else {
		g_AmbienceSound_Muted[id] &= ~(1<<(value));
	}

	showMenu__UserOptions_AmbienceSong(id);
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
	oldmenu_additem(7, type_hud, "\r7.\w Estilos del HUD \y(%s)^n", __HUD_STYLES[g_UserOptions_HudStyle[id][type_hud]]);

	oldmenu_additem(9, type_hud, "\r9.\w Reiniciar valores^n");

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
			++g_UserOptions_HudStyle[id][value];

			if(g_UserOptions_HudStyle[id][value] == sizeof(__HUD_STYLES)) {
				g_UserOptions_HudStyle[id][value] = 0;
			}
		} case 9: {
			switch(value) {
				case HUD_TYPE_GENERAL: {
					g_UserOptions_Hud[id][value] = Float:{0.02, 0.1, 0.0};
					g_UserOptions_HudEffect[id][value] = 0;
					g_UserOptions_HudStyle[id][value] = 1;
				}
			}
		}
	}

	showMenu__UserOptions_Hud(id, value);
}

public fwd__EmitSoundPre(const id, const channel, const sample[], const Float:volume, const Float:attn, const flags, const pitch) {
	if(sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') { // HOSTAGE
		return FMRES_SUPERCEDE;
	}

	if(sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l') { // FALL
		return FMRES_SUPERCEDE;
	}

	if(!isUserValidConnected(id) || !g_Zombie[id]) {
		return FMRES_IGNORED;
	}

	if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') { // BHIT
		if(g_SpecialMode[id] == MODE_NEMESIS) {
			emit_sound(id, channel, __SOUND_NEMESIS_PAIN[random_num(0, charsmax(__SOUND_NEMESIS_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		} else {
			emit_sound(id, channel, __SOUND_ZOMBIE_PAIN[random_num(0, charsmax(__SOUND_ZOMBIE_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		}

		return FMRES_SUPERCEDE;
	}

	if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i') { // KNI
		if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') { // SLA
			emit_sound(id, channel, __SOUND_ZOMBIE_CLAW_SLASH, 1.0, ATTN_NORM, 0, PITCH_NORM);
			return FMRES_SUPERCEDE;
		}

		if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') { // HIT
			if(sample[17] == 'w') { // WALL
				emit_sound(id, channel, __SOUND_ZOMBIE_CLAW_WALL[random_num(0, charsmax(__SOUND_ZOMBIE_CLAW_WALL))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				return FMRES_SUPERCEDE;
			} else {
				emit_sound(id, channel, __SOUND_ZOMBIE_CLAW_HIT[random_num(0, charsmax(__SOUND_ZOMBIE_CLAW_HIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				return FMRES_SUPERCEDE;
			}
		}

		if(sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') { // STAB
			emit_sound(id, channel, __SOUND_ZOMBIE_CLAW_STAB, 1.0, ATTN_NORM, 0, PITCH_NORM);
			return FMRES_SUPERCEDE;
		}
	}

	if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) { // DIE / DEAD
		emit_sound(id, channel, __SOUND_ZOMBIE_DIE[random_num(0, charsmax(__SOUND_ZOMBIE_DIE))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public setUserAllModels(const id) {
	rg_reset_user_model(id);

	switch(g_SpecialMode[id]) {
		case MODE_SURVIVOR: {
			rg_set_user_model(id, __PLAYER_MODEL_SURVIVOR);
		} case MODE_NEMESIS: {
			rg_set_user_model(id, __PLAYER_MODEL_NEMESIS);
		} default: {
			if(g_Zombie[id]) {
				rg_set_user_model(id, __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassModel]);
			} else {
				if(g_Skin[id]) {
					rg_set_user_model(id, __SKINS[g_Skin[id]][skinModelName]);
				} else {
					rg_set_user_model(id, __PLAYER_MODEL_HUMAN);
				}
			}
		}
	}
}

public fwd__SetModelPre(const ent, const model[]) {
	if(strlen(model) < 8) {
		return FMRES_IGNORED;
	}

	static sClassName[16];
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(equal(sClassName, "weaponbox")) {
		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 5.0));
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
			if(!g_Zombie[iId]) {
				if(g_MadnessBomb[iId]) {
					effectGrenade(ent, random(256), random(256), random(256), NADE_TYPE_MADNESS);
					--g_MadnessBomb[iId];
				} else {
					effectGrenade(ent, 255, 0, 0, NADE_TYPE_FIRE);
				}
			} else {
				effectGrenade(ent, 0, 255, 0, NADE_TYPE_INFECTION);
			}

			replaceWeaponModels(iId, CSW_HEGRENADE);
		} case 'f': {
			if(!g_Zombie[iId]) {
				effectGrenade(ent, 0, 0, 255, NADE_TYPE_FROST);
			}

			replaceWeaponModels(iId, CSW_FLASHBANG);
		} case 's': {
			if(!g_Zombie[iId]) {
				if(g_BubbleBomb[iId]) {
					effectGrenade(ent, 255, 255, 255, NADE_TYPE_BUBBLE);

					--g_BubbleBomb[iId];

					replaceWeaponModels(iId, CSW_SMOKEGRENADE);

					entity_set_model(ent, __GRENADE_MODEL_BUBBLE_W);
					return FMRES_SUPERCEDE;
				} else {
					effectGrenade(ent, 200, 100, 0, NADE_TYPE_EXPLOSIVE);
				}
			}

			replaceWeaponModels(iId, CSW_SMOKEGRENADE);
		}
	}

	return FMRES_IGNORED;
}

public effectGrenade(const ent, const red, const green, const blue, const nade_type) {
	static Float:vecColor[3];

	vecColor[0] = float(red);
	vecColor[1] = float(green);
	vecColor[2] = float(blue);

	entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell);
	entity_set_vector(ent, EV_VEC_rendercolor, vecColor);
	entity_set_int(ent, EV_INT_rendermode, kRenderNormal);
	entity_set_float(ent, EV_FL_renderamt, 1.0);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent);
	write_short(g_Sprite_Laserbeam);
	write_byte(10);
	write_byte(3);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(200);
	message_end();

	entity_set_int(ent, EV_NADE_TYPE, nade_type);

	switch(nade_type) {
		case NADE_TYPE_BUBBLE: {
			entity_set_vector(ent, EV_FLARE_COLOR, vecColor);
		}
	}
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
			frostExplode(ent);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_EXPLOSIVE: {
			explosiveExplode(ent);
			return HAM_SUPERCEDE;
		} case NADE_TYPE_BUBBLE: {
			new iDuration = entity_get_int(ent, EV_FLARE_DURATION);

			if(iDuration > 0) {
				new i;

				if(iDuration == 1) {
					new iPlayers[MAX_PLAYERS + 1];
					new Float:vecOrigin[3];
					new iVictim = -1;
					new j = 0;

					entity_get_vector(ent, EV_VEC_origin, vecOrigin);

					while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 125.0)) != 0) {
						if(isUserValidAlive(iVictim) && !g_Zombie[iVictim]) {
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
					i = entity_get_edict(ent, EV_ENT_owner);
					flareLighting(ent, iDuration, 0);
				}

				bubblePush(ent);

				entity_set_int(ent, EV_FLARE_DURATION, --iDuration);
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 0.1));
			} else if((entity_get_int(ent, EV_INT_flags) & FL_ONGROUND) && get_speed(ent) < 10) {
				if(g_EndRound) {
					return FMRES_SUPERCEDE;
				}

				emitSound(ent, CHAN_WEAPON, __SOUND_GRENADE_BUBBLE);

				entity_set_model(ent, __MODEL_BUBBLE);

				entity_set_vector(ent, EV_VEC_angles, Float:{0.0, 0.0, 0.0});

				new Float:vecColor[3];
				entity_get_vector(ent, EV_FLARE_COLOR, vecColor);

				entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell);
				entity_set_vector(ent, EV_VEC_rendercolor, vecColor);
				entity_set_int(ent, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(ent, EV_FL_renderamt, 32.0);

				entity_set_int(ent, EV_FLARE_DURATION, 150);
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 0.01));
			} else {
				entity_set_float(ent, EV_FL_dmgtime, (flGameTime + 0.5));
			}
		} case NADE_TYPE_MADNESS: {
			madnessExplode(ent);
			return HAM_SUPERCEDE;
		}
	}

	return HAM_IGNORED;
}

public ham__PlayerTraceAttackPre(const victim, const attacker, const Float:damage, Float:direction[3], const trace_handle, const damage_type) {
	if(victim == attacker || !isUserValidConnected(attacker)) {
		return HAM_IGNORED;
	}

	if(g_NewRound || g_EndRound) {
		return HAM_SUPERCEDE;
	}

	if(g_Zombie[attacker] == g_Zombie[victim]) {
		return HAM_SUPERCEDE;
	}
	
	if(g_Immunity[victim] || g_Frozen[attacker] || g_Frozen[victim]) {
		return HAM_SUPERCEDE;
	}

	if(((g_InBubble[victim] && !g_Immunity[attacker]) && (g_InBubble[victim] && g_Zombie[attacker] && !g_SpecialMode[attacker]))) {
		return HAM_SUPERCEDE;
	}

	if(!g_Zombie[victim] || !(damage_type & DMG_BULLET)) {
		return HAM_IGNORED;
	}

	static vecOriginAttacker[3];
	static vecOriginVictim[3];

	get_user_origin(attacker, vecOriginAttacker);
	get_user_origin(victim, vecOriginVictim);

	if(get_distance(vecOriginVictim, vecOriginAttacker) > 500) {
		return HAM_IGNORED;
	}

	xs_vec_mul_scalar(direction, damage, direction);

	if(__WEAPON_KNOCKBACK_POWER[g_CurrentWeapon[attacker]] > 0.0) {
		xs_vec_mul_scalar(direction, __WEAPON_KNOCKBACK_POWER[g_CurrentWeapon[attacker]], direction);
	}

	static iDucking;
	iDucking = entity_get_int(victim, EV_INT_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND);

	if(iDucking) {
		xs_vec_mul_scalar(direction, 0.25, direction);
	}

	if(g_SpecialMode[victim] == MODE_NEMESIS) {
		xs_vec_mul_scalar(direction, 0.25, direction);
	} else {
		xs_vec_mul_scalar(direction, 2.0, direction);
	}

	static Float:vecVelocity[3];
	entity_get_vector(victim, EV_VEC_velocity, vecVelocity);

	xs_vec_add(vecVelocity, direction, direction);

	direction[2] = vecVelocity[2];

	entity_set_vector(victim, EV_VEC_velocity, direction);
	return HAM_IGNORED;
}

public ham__AutomaticWeaponZoom(const weapon_ent) {
	return HAM_SUPERCEDE;
}

public ham__ItemDeployPost(const weapon_ent) {
	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!pev_valid(iId)) {
		return;
	}

	static iWeaponId;
	iWeaponId = cs_get_weapon_id(weapon_ent);

	g_CurrentWeapon[iId] = iWeaponId;
	g_TypeWeapon[iId] = (((1<<iWeaponId) & PRIMARY_WEAPONS_BIT_SUM) ? 1 : (((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM) ? 2 : 0));

	if(g_Zombie[iId]) {
		if(!((1<<iWeaponId) & ZOMBIE_ALLOWED_WEAPONS_BIT_SUM)) {
			g_CurrentWeapon[iId] = CSW_KNIFE;
			engclient_cmd(iId, "weapon_knife");
		}
	}

	replaceWeaponModels(iId, iWeaponId);
}

public getWeaponEntId(const ent) {
	if(pev_valid(ent) != PDATA_SAFE) {
		return -1;
	}

	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

public clcmd__BlockCommand(const id) {
	return PLUGIN_HANDLED;
}

public task__ModifCommands(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	client_cmd(id, "cl_minmodels 0");
	client_cmd(id, "cl_solid_players 1");
}

public showMenu__Character(const id) {
	oldmenu_create("\yPERSONAJE", "menu__Character");

	oldmenu_additem(1, 1, "\r1.\w Clases humanas \y[%s]", __HUMAN_CLASSES[g_HumanClass[id]][humanClassName]);
	oldmenu_additem(2, 2, "\r2.\w Clases zombies \y[%s]", __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);
	oldmenu_additem(3, 3, "\r3.\w Clases survivors \y[%s]", __SURVIVOR_CLASSES[g_SurvivorClass[id]][survivorClassName]);
	oldmenu_additem(4, 4, "\r4.\w Clases nemesis \y[%s]^n", __NEMESIS_CLASSES[g_NemesisClass[id]][nemesisClassName]);

	oldmenu_additem(5, 5, "\r5.\w Ver estadísticas humanas/zombies^n");

	oldmenu_additem(6, 6, "\r6.\w Skin \y[%s]", __SKINS[g_Skin[id]][skinName]);
	oldmenu_additem(7, 7, "\r7.\w Cuchillo \y[%s]", __KNIFES[g_Knife[id]][knifeName]);
	oldmenu_additem(8, 8, "\r8.\w Gorro \y[%s]^n", __HATS[g_Hat[id]][hatName]);

	oldmenu_additem(9, 9, "\r9.\w Logros^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Character(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			showMenu__ChooseHumanClass(id);
		} case 2: {
			showMenu__ChooseZombieClass(id);
		} case 3: {
			showMenu__ChooseSurvivorClass(id);
		} case 4: {
			showMenu__ChooseNemesisClass(id);
		} case 5: {
			showMenu__StatsHumanZombie(id);
		} case 6: {
			if(g_MenuPage[id][MENU_PAGE_SKINS] < 1) {
				g_MenuPage[id][MENU_PAGE_SKINS] = 1;
			}

			showMenu__Skins(id, g_MenuPage[id][MENU_PAGE_SKINS]);
		} case 7: {
			if(g_MenuPage[id][MENU_PAGE_KNIFES] < 1) {
				g_MenuPage[id][MENU_PAGE_KNIFES] = 1;
			}

			showMenu__Knifes(id, g_MenuPage[id][MENU_PAGE_KNIFES]);
		} case 8: {
			if(g_MenuPage[id][MENU_PAGE_HATS] < 1) {
				g_MenuPage[id][MENU_PAGE_HATS] = 1;
			}

			showMenu__Hats(id, g_MenuPage[id][MENU_PAGE_HATS]);
		} case 9: {
			showMenu__AchievementsClass(id);
		}
	}
}

public showMenu__StatsHumanZombie(const id) {
	oldmenu_create("\yVER ESTADÍSTICAS HUMANAS/ZOMBIES", "menu__StatsHumanZombie");

	oldmenu_additem(1, 1, "\r1.\w Ver estadísticas humanas");
	oldmenu_additem(2, 2, "\r2.\w Ver estadísticas zombies^n");

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__StatsHumanZombie(const id, const item) {
	if(!item) {
		showMenu__Character(id);
		return;
	}

	switch(item) {
		case 1: {
			showMenu__StatsHumanClass(id, -1);
		} case 2: {
			showMenu__StatsZombieClass(id, -1);
		}
	}
}

public showMenu__ChooseHumanClass(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("CLASES HUMANAS\R", "menu__ChooseHumanClass");

	for(i = 0; i < structIdHumanClasses; ++i) {
		if(g_HumanClass[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ACTUAL)", __HUMAN_CLASSES[i][humanClassName]);
		} else if(g_HumanClassNext[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ELEGIDO)", __HUMAN_CLASSES[i][humanClassName]);
		} else {
			formatex(sItem, charsmax(sItem), "\w%s", __HUMAN_CLASSES[i][humanClassName]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_HUMAN_CLASSES] = min(g_MenuPage[id][MENU_PAGE_HUMAN_CLASSES], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_HUMAN_CLASSES]);
}

public menu__ChooseHumanClass(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_HUMAN_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData[id][MENU_DATA_CLASS_HUMAN_ID] = iItemId;

	showMenu__ChooseHumanClassInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__ChooseHumanClassInfo(const id) {
	new iClassId = g_MenuData[id][MENU_DATA_CLASS_HUMAN_ID];

	if(!(0 <= iClassId <= (structIdHumanClasses - 1))) {
		showMenu__ChooseHumanClass(id);
		return;
	}

	new sClassHumanName[32];
	copy(sClassHumanName, charsmax(sClassHumanName), __HUMAN_CLASSES[iClassId][humanClassName]);
	strtoupper(sClassHumanName);

	oldmenu_create("\yCLASE HUMANA - %s", "menu__ChooseHumanClassInfo", sClassHumanName);

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __HUMAN_CLASSES[iClassId][humanClassInfo]);

	if(__HUMAN_CLASSES[iClassId][humanClassVip]) {
		oldmenu_additem(-1, -1, "\yREQUERIMIENTOS\r:");
		oldmenu_additem(-1, -1, "\r - \wSer jugador \yVIP\w^n");
	}

	oldmenu_additem(-1, -1, "\yESTADÍSTICAS BASE\r:");
	oldmenu_additem(-1, -1, "\r - \wVIDA\r:\y %d", __HUMAN_CLASSES[iClassId][humanClassHealth]);
	oldmenu_additem(-1, -1, "\r - \wVELOCIDAD\r:\y %0.2f", __HUMAN_CLASSES[iClassId][humanClassSpeed]);
	oldmenu_additem(-1, -1, "\r - \wGRAVEDAD\r:\y %0.2f^n", (__HUMAN_CLASSES[iClassId][humanClassGravity] * 800.0));

	if((!(get_user_flags(id) & ADMIN_RESERVATION) && __HUMAN_CLASSES[iClassId][humanClassVip])) {
		oldmenu_additem(-1, -1, "\d1. Debes ser \rVIP\w para elegir esta clase");
	} else {
		if(g_HumanClass[id] == iClassId) {
			oldmenu_additem(-1, -1, "\d1. Ya tienes esta clase");
		} else if(g_HumanClassNext[id] == iClassId) {
			oldmenu_additem(-1, -1, "\d1. Ya elegiste esta clase");
		} else {
			oldmenu_additem(1, 1, "\r1.\w Elegir clase");
		}
	}
	
	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ChooseHumanClassInfo(const id, const item) {
	if(!item) {
		showMenu__ChooseHumanClass(id);
		return;
	}

	new iClassId = g_MenuData[id][MENU_DATA_CLASS_HUMAN_ID];

	switch(item) {
		case 1: {
			if(!(get_user_flags(id) & ADMIN_RESERVATION) && __HUMAN_CLASSES[iClassId][humanClassVip]) {
				clientPrintColor(id, _, "La clase elegida es solo para usuarios VIP");
			} else {
				if(g_HumanClass[id] == iClassId) {
					clientPrintColor(id, _, "Ya tienes puesta la clase humana !t%s!y", __HUMAN_CLASSES[iClassId][humanClassName]);
				} else if(g_HumanClassNext[id] == iClassId) {
					clientPrintColor(id, _, "Ya has elegido la clase humana !t%s!y. Espera a tu próximo respawn humano para obtenerlo", __HUMAN_CLASSES[iClassId][humanClassName]);
				} else {
					g_HumanClassNext[id] = iClassId;
					clientPrintColor(id, _, "En tu próxima respawn tu clase humana será !t%s!y", __HUMAN_CLASSES[iClassId][humanClassName]);
				}
			}

			showMenu__ChooseHumanClass(id);
		}
	}
}

public showMenu__StatsHumanClass(const id, const level) {
	if(level != -1) {
		oldmenu_create("\yVER ESTADÍSTICAS HUMANAS - NIVEL %d^n\wAquí podrás ver las estadísticas por cada nivel siendo humano", "menu__StatsHumanClassIn", level);

		oldmenu_additem(-1, -1, "\wVIDA\r:\y %d \d(+%d)", humanHealth(id, g_HumanClass[id], level), (humanHealth(id, g_HumanClass[id], level) - __HUMAN_CLASSES[0][humanClassHealth]));
		oldmenu_additem(-1, -1, "\wVELOCIDAD\r:\y %0.2f \d(+%0.2f)", humanSpeed(id, g_HumanClass[id], level), (humanSpeed(id, g_HumanClass[id], level) - __HUMAN_CLASSES[0][humanClassSpeed]));
		oldmenu_additem(-1, -1, "\wGRAVEDAD\r:\y %0.2f \d(%0.2f)", (humanGravity(id, g_HumanClass[id], level) * 800.0), ((humanGravity(id, g_HumanClass[id], level) * 800.0) - (__HUMAN_CLASSES[0][humanClassGravity] * 800.0)));
		oldmenu_additem(-1, -1, "\wDAÑO\r:\y +%0.0f", humanDamage(id, level));

		oldmenu_additem(0, 0, "^n\r0.\w Volver");
		oldmenu_display(id);
	} else {
		oldmenu_create("\yVER ESTADÍSTICAS HUMANAS^n\wAquí podrás ver las estadísticas por cada nivel siendo humano", "menu__StatsHumanClass");

		oldmenu_additem(-1, -1, "\wVIDA\r:\y %d \d(+%d)", humanHealth(id, g_HumanClass[id], g_Level[id]), (humanHealth(id, g_HumanClass[id], g_Level[id]) - __HUMAN_CLASSES[0][humanClassHealth]));
		oldmenu_additem(-1, -1, "\wVELOCIDAD\r:\y %0.2f \d(+%0.2f)", humanSpeed(id, g_HumanClass[id], g_Level[id]), (humanSpeed(id, g_HumanClass[id], g_Level[id]) - __HUMAN_CLASSES[0][humanClassSpeed]));
		oldmenu_additem(-1, -1, "\wGRAVEDAD\r:\y %0.2f \d(%0.2f)", (humanGravity(id, g_HumanClass[id], g_Level[id]) * 800.0), ((humanGravity(id, g_HumanClass[id], g_Level[id]) * 800.0) - (__HUMAN_CLASSES[0][humanClassGravity] * 800.0)));
		oldmenu_additem(-1, -1, "\wDAÑO\r:\y +%0.0f", humanDamage(id, g_Level[id]));

		oldmenu_additem(-1, -1, "^n\yNOTA\r:\w Por cada nivel que subas, aumentas un mínimo porcentaje^na tus estadísticas base.^n");

		oldmenu_additem(1, 1, "\r1.\w Actualizar");
		oldmenu_additem(2, 2, "\r2.\w Ver mejoras por nivel^n");

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__StatsHumanClass(const id, const item) {
	if(!item) {
		showMenu__StatsHumanZombie(id);
		return;
	}

	switch(item) {
		case 1: {
			showMenu__StatsHumanClass(id, -1);
		} case 2: {
			if(g_MenuPage[id][MENU_PAGE_SHC] < 1) {
				g_MenuPage[id][MENU_PAGE_SHC] = 1;
			}

			showMenu__StatsHumanClassAll(id, g_MenuPage[id][MENU_PAGE_SHC]);
		}
	}
}

public menu__StatsHumanClassIn(const id, const item) {
	if(!item) {
		showMenu__StatsHumanClassAll(id, g_MenuPage[id][MENU_PAGE_SHC]);
		return;
	}

	showMenu__StatsHumanClass(id, g_MenuData[id][MENU_DATA_SHC_LEVEL]);
}

public showMenu__StatsHumanClassAll(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, MAX_LEVEL, 7, 1);
	oldmenu_create("\yVER MEJORAS POR NIVEL \r[%d - %d]\R\y%d / %d", "menu__StatsHumanClassAll", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.%s Nivel\r:%s %d", j, ((g_Level[id] >= i) ? "\w" : "\d"), ((g_Level[id] >= i) ? "\y" : "\d"), i);
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__StatsHumanClassAll(const id, const item, const value, const page) {
	if(!item || value > MAX_LEVEL) {
		showMenu__StatsHumanClass(id, -1);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_SHC] = iNewPage;

		showMenu__StatsHumanClassAll(id, iNewPage);
		return;
	}

	showMenu__StatsHumanClass(id, value);
}

public showMenu__ChooseSurvivorClass(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("CLASES SURVIVORS\R", "menu__ChooseSurvivorClass");

	for(i = 0; i < structIdSurvivorClasses; ++i) {
		if(g_SurvivorClass[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ACTUAL)", __SURVIVOR_CLASSES[i][survivorClassName]);
		} else if(g_SurvivorClassNext[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ELEGIDO)", __SURVIVOR_CLASSES[i][survivorClassName]);
		} else {
			formatex(sItem, charsmax(sItem), "\w%s", __SURVIVOR_CLASSES[i][survivorClassName]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_SURVIVOR_CLASSES] = min(g_MenuPage[id][MENU_PAGE_SURVIVOR_CLASSES], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_SURVIVOR_CLASSES]);
}

public menu__ChooseSurvivorClass(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_SURVIVOR_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData[id][MENU_DATA_CLASS_SURVIVOR_ID] = iItemId;

	showMenu__ChooseSurvivorClassInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__ChooseSurvivorClassInfo(const id) {
	new iClassId = g_MenuData[id][MENU_DATA_CLASS_SURVIVOR_ID];

	if(!(0 <= iClassId <= (structIdSurvivorClasses - 1))) {
		showMenu__ChooseSurvivorClass(id);
		return;
	}

	new sClassSurvivorName[32];
	copy(sClassSurvivorName, charsmax(sClassSurvivorName), __SURVIVOR_CLASSES[iClassId][survivorClassName]);
	strtoupper(sClassSurvivorName);

	oldmenu_create("\yCLASE SURVIVOR - %s", "menu__ChooseSurvivorClassInfo", sClassSurvivorName);

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __SURVIVOR_CLASSES[iClassId][survivorClassInfo]);

	oldmenu_additem(-1, -1, "\yESTADÍSTICAS BASE\r:");
	oldmenu_additem(-1, -1, "\r - \wVIDA\r:\y %d", __SURVIVOR_CLASSES[iClassId][survivorClassHealth]);
	oldmenu_additem(-1, -1, "\r - \wVELOCIDAD\r:\y %0.2f", __SURVIVOR_CLASSES[iClassId][survivorClassSpeed]);
	oldmenu_additem(-1, -1, "\r - \wGRAVEDAD\r:\y %0.2f^n", (__SURVIVOR_CLASSES[iClassId][survivorClassGravity] * 800.0));

	if(__SURVIVOR_CLASSES[iClassId][survivorClassVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
		oldmenu_additem(-1, -1, "\d1. Debes ser \rVIP\w para tener esta clase");
	} else {
		if(g_SurvivorClass[id] == iClassId) {
			oldmenu_additem(-1, -1, "\d1. Ya tienes esta clase");
		} else if(g_SurvivorClassNext[id] == iClassId) {
			oldmenu_additem(-1, -1, "\d1. Ya elegiste esta clase");
		} else {
			oldmenu_additem(1, 1, "\r1.\w Elegir clase");
		}
	}
	
	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ChooseSurvivorClassInfo(const id, const item) {
	if(!item) {
		showMenu__ChooseSurvivorClass(id);
		return;
	}

	new iClassId = g_MenuData[id][MENU_DATA_CLASS_SURVIVOR_ID];

	switch(item) {
		case 1: {
			if(__SURVIVOR_CLASSES[iClassId][survivorClassVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
				clientPrintColor(id, _, "Debes ser !gVIP!y para poder tener esta clase");
			} else {
				if(g_SurvivorClass[id] == iClassId) {
					clientPrintColor(id, _, "Ya tienes puesta la clase survivor !t%s!y", __SURVIVOR_CLASSES[iClassId][survivorClassName]);
				} else if(g_SurvivorClassNext[id] == iClassId) {
					clientPrintColor(id, _, "Ya has elegido la clase survivor !t%s!y. Espera a tu próximo respawn survivor para obtenerlo", __SURVIVOR_CLASSES[iClassId][survivorClassName]);
				} else {
					g_SurvivorClassNext[id] = iClassId;
					clientPrintColor(id, _, "En tu próximo respawn tu clase survivor será !t%s!y", __SURVIVOR_CLASSES[iClassId][survivorClassName]);
				}
			}
			
			showMenu__ChooseSurvivorClass(id);
		}
	}
}

public showMenu__ChooseNemesisClass(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("CLASES NEMESIS\R", "menu__ChooseNemesisClass");

	for(i = 0; i < structIdNemesisClasses; ++i) {
		if(g_NemesisClass[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ACTUAL)", __NEMESIS_CLASSES[i][nemesisClassName]);
		} else if(g_NemesisClassNext[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ELEGIDO)", __NEMESIS_CLASSES[i][nemesisClassName]);
		} else {
			formatex(sItem, charsmax(sItem), "\w%s", __NEMESIS_CLASSES[i][nemesisClassName]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_NEMESIS_CLASSES] = min(g_MenuPage[id][MENU_PAGE_NEMESIS_CLASSES], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_NEMESIS_CLASSES]);
}

public menu__ChooseNemesisClass(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_NEMESIS_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData[id][MENU_DATA_CLASS_NEMESIS_ID] = iItemId;

	showMenu__ChooseNemesisClassInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__ChooseNemesisClassInfo(const id) {
	new iClassId = g_MenuData[id][MENU_DATA_CLASS_NEMESIS_ID];

	if(!(0 <= iClassId <= (structIdNemesisClasses - 1))) {
		showMenu__ChooseNemesisClass(id);
		return;
	}

	new sClassNemesisName[32];
	copy(sClassNemesisName, charsmax(sClassNemesisName), __NEMESIS_CLASSES[iClassId][nemesisClassName]);
	strtoupper(sClassNemesisName);

	oldmenu_create("\yCLASE NEMESIS - %s", "menu__ChooseNemesisClassInfo", sClassNemesisName);

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __NEMESIS_CLASSES[iClassId][nemesisClassInfo]);

	oldmenu_additem(-1, -1, "\yESTADÍSTICAS BASE\r:");
	oldmenu_additem(-1, -1, "\r - \wVIDA\r:\y %d", __NEMESIS_CLASSES[iClassId][nemesisClassHealth]);
	oldmenu_additem(-1, -1, "\r - \wVELOCIDAD\r:\y %0.2f", __NEMESIS_CLASSES[iClassId][nemesisClassSpeed]);
	oldmenu_additem(-1, -1, "\r - \wGRAVEDAD\r:\y %0.2f^n", (__NEMESIS_CLASSES[iClassId][nemesisClassGravity] * 800.0));

	if(__NEMESIS_CLASSES[iClassId][nemesisClassVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
		oldmenu_additem(-1, -1, "\d1. Debes ser \rVIP\w para tener esta clase");
	} else {
		if(g_NemesisClass[id] == iClassId) {
			oldmenu_additem(-1, -1, "\d1. Ya tienes esta clase");
		} else if(g_NemesisClassNext[id] == iClassId) {
			oldmenu_additem(-1, -1, "\d1. Ya elegiste esta clase");
		} else {
			oldmenu_additem(1, 1, "\r1.\w Elegir clase");
		}
	}
	
	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ChooseNemesisClassInfo(const id, const item) {
	if(!item) {
		showMenu__ChooseNemesisClass(id);
		return;
	}

	new iClassId = g_MenuData[id][MENU_DATA_CLASS_NEMESIS_ID];

	switch(item) {
		case 1: {
			if(__NEMESIS_CLASSES[iClassId][nemesisClassVip] && !(get_user_flags(id) & ADMIN_RESERVATION)) {
				clientPrintColor(id, _, "Debes tener !gVIP!y para tener esta clase");
			} else {
				if(g_NemesisClass[id] == iClassId) {
					clientPrintColor(id, _, "Ya tienes puesta la clase nemesis !t%s!y", __NEMESIS_CLASSES[iClassId][nemesisClassName]);
				} else if(g_NemesisClassNext[id] == iClassId) {
					clientPrintColor(id, _, "Ya has elegido la clase nemesis !t%s!y. Espera a tu próximo respawn nemesis para obtenerlo", __NEMESIS_CLASSES[iClassId][nemesisClassName]);
				} else {
					g_NemesisClassNext[id] = iClassId;
					clientPrintColor(id, _, "En tu próximo respawn tu clase nemesis será !t%s!y", __NEMESIS_CLASSES[iClassId][nemesisClassName]);
				}
			}

			showMenu__ChooseNemesisClass(id);
		}
	}
}

public showMenu__ChooseZombieClass(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];

	iMenuId = menu_create("CLASES ZOMBIES\R", "menu__ChooseZombieClass");

	for(i = 0; i < structIdZombieClasses; ++i) {
		if(g_ZombieClass[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ACTUAL)", __ZOMBIE_CLASSES[i][zombieClassName]);
		} else if(g_ZombieClassNext[id] == i) {
			formatex(sItem, charsmax(sItem), "\d%s \y(ELEGIDO)", __ZOMBIE_CLASSES[i][zombieClassName]);
		} else {
			formatex(sItem, charsmax(sItem), "\w%s", __ZOMBIE_CLASSES[i][zombieClassName]);
		}

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_ZOMBIE_CLASSES] = min(g_MenuPage[id][MENU_PAGE_ZOMBIE_CLASSES], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_ZOMBIE_CLASSES]);
}

public menu__ChooseZombieClass(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_ZOMBIE_CLASSES]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Character(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData[id][MENU_DATA_CLASS_ZOMBIE_ID] = iItemId;

	showMenu__ChooseZombieClassInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__ChooseZombieClassInfo(const id) {
	new iClassId = g_MenuData[id][MENU_DATA_CLASS_ZOMBIE_ID];

	if(!(0 <= iClassId <= (structIdZombieClasses - 1))) {
		showMenu__ChooseZombieClass(id);
		return;
	}

	new sClassZombieName[32];
	copy(sClassZombieName, charsmax(sClassZombieName), __ZOMBIE_CLASSES[iClassId][zombieClassName]);
	strtoupper(sClassZombieName);

	oldmenu_create("\yCLASE ZOMBIE - %s", "menu__ChooseZombieClassInfo", sClassZombieName);

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s^n", __ZOMBIE_CLASSES[iClassId][zombieClassInfo]);

	oldmenu_additem(-1, -1, "\yESTADÍSTICAS BASE\r:");
	oldmenu_additem(-1, -1, "\r - \wVIDA\r:\y %d", __ZOMBIE_CLASSES[iClassId][zombieClassHealth]);
	oldmenu_additem(-1, -1, "\r - \wVELOCIDAD\r:\y %0.2f", __ZOMBIE_CLASSES[iClassId][zombieClassSpeed]);
	oldmenu_additem(-1, -1, "\r - \wGRAVEDAD\r:\y %0.2f^n", (__ZOMBIE_CLASSES[iClassId][zombieClassGravity] * 800.0));

	if(g_ZombieClass[id] == iClassId) {
		oldmenu_additem(-1, -1, "\d1. Ya tienes esta clase");
	} else if(g_ZombieClassNext[id] == iClassId) {
		oldmenu_additem(-1, -1, "\d1. Ya elegiste esta clase");
	} else {
		oldmenu_additem(1, 1, "\r1.\w Elegir clase");
	}
	
	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ChooseZombieClassInfo(const id, const item) {
	if(!item) {
		showMenu__ChooseZombieClass(id);
		return;
	}

	new iClassId = g_MenuData[id][MENU_DATA_CLASS_ZOMBIE_ID];

	switch(item) {
		case 1: {
			if(g_ZombieClass[id] == iClassId) {
				clientPrintColor(id, _, "Ya tienes puesta la clase zombie !t%s!y", __ZOMBIE_CLASSES[iClassId][zombieClassName]);
			} else if(g_ZombieClassNext[id] == iClassId) {
				clientPrintColor(id, _, "Ya has elegido la clase zombie !t%s!y. Espera a tu próxima infección zombie para obtenerla", __ZOMBIE_CLASSES[iClassId][zombieClassName]);
			} else {
				g_ZombieClassNext[id] = iClassId;
				clientPrintColor(id, _, "En tu próxima infección tu clase zombie será !t%s!y", __ZOMBIE_CLASSES[iClassId][zombieClassName]);
			}

			showMenu__ChooseZombieClass(id);
		}
	}
}

public showMenu__StatsZombieClass(const id, const level) {
	if(level != -1) {
		oldmenu_create("\yVER ESTADÍSTICAS ZOMBIES - NIVEL %d^n\wAquí podrás ver las estadísticas por cada nivel siendo zombie", "menu__StatsZombieClassIn", level);

		oldmenu_additem(-1, -1, "\wVIDA\r:\y %d \d(+%d)", zombieHealth(id, g_ZombieClass[id], level), (zombieHealth(id, g_ZombieClass[id], level) - __ZOMBIE_CLASSES[0][zombieClassHealth]));
		oldmenu_additem(-1, -1, "\wVELOCIDAD\r:\y %0.2f \d(+%0.2f)", zombieSpeed(id, g_ZombieClass[id], level), (zombieSpeed(id, g_ZombieClass[id], level) - __ZOMBIE_CLASSES[0][zombieClassSpeed]));
		oldmenu_additem(-1, -1, "\wGRAVEDAD\r:\y %0.2f \d(%0.2f)", (zombieGravity(id, g_ZombieClass[id], level) * 800.0), ((zombieGravity(id, g_ZombieClass[id], level) * 800.0) - (__ZOMBIE_CLASSES[0][zombieClassGravity] * 800.0)));

		oldmenu_additem(0, 0, "^n\r0.\w Volver");
		oldmenu_display(id);
	} else {
		oldmenu_create("\yVER ESTADÍSTICAS ZOMBIES^n\wAquí podrás ver las estadísticas por cada nivel siendo zombie", "menu__StatsZombieClass");

		oldmenu_additem(-1, -1, "\wVIDA\r:\y %d \d(+%d)", zombieHealth(id, g_ZombieClass[id], g_Level[id]), (zombieHealth(id, g_ZombieClass[id], g_Level[id]) - __ZOMBIE_CLASSES[0][zombieClassHealth]));
		oldmenu_additem(-1, -1, "\wVELOCIDAD\r:\y %0.2f \d(+%0.2f)", zombieSpeed(id, g_ZombieClass[id], g_Level[id]), (zombieSpeed(id, g_ZombieClass[id], g_Level[id]) - __ZOMBIE_CLASSES[0][zombieClassSpeed]));
		oldmenu_additem(-1, -1, "\wGRAVEDAD\r:\y %0.2f \d(%0.2f)", (zombieGravity(id, g_ZombieClass[id], g_Level[id]) * 800.0), ((zombieGravity(id, g_ZombieClass[id], g_Level[id]) * 800.0) - (__ZOMBIE_CLASSES[0][zombieClassGravity] * 800.0)));

		oldmenu_additem(-1, -1, "^n\yNOTA\r:\w Por cada nivel que subas, aumentas un mínimo porcentaje^na tus estadísticas base.^n");

		oldmenu_additem(1, 1, "\r1.\w Actualizar");
		oldmenu_additem(2, 2, "\r2.\w Ver mejoras por nivel^n");

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__StatsZombieClass(const id, const item) {
	if(!item) {
		showMenu__StatsHumanZombie(id);
		return;
	}

	switch(item) {
		case 1: {
			showMenu__StatsZombieClass(id, -1);
		} case 2: {
			if(g_MenuPage[id][MENU_PAGE_SZC] < 1) {
				g_MenuPage[id][MENU_PAGE_SZC] = 1;
			}

			showMenu__StatsZombieClassAll(id, g_MenuPage[id][MENU_PAGE_SZC]);
		}
	}
}

public menu__StatsZombieClassIn(const id, const item) {
	if(!item) {
		showMenu__StatsZombieClassAll(id, g_MenuPage[id][MENU_PAGE_SZC]);
		return;
	}

	showMenu__StatsZombieClass(id, g_MenuData[id][MENU_DATA_SZC_LEVEL]);
}

public showMenu__StatsZombieClassAll(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, MAX_LEVEL, 7, 1);
	oldmenu_create("\yVER MEJORAS POR NIVEL \r[%d - %d]\R\y%d / %d", "menu__StatsZombieClassAll", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		oldmenu_additem(j, i, "\r%d.%s Nivel\r:%s %d", j, ((g_Level[id] >= i) ? "\w" : "\d"), ((g_Level[id] >= i) ? "\y" : "\d"), i);
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__StatsZombieClassAll(const id, const item, const value, const page) {
	if(!item || value > MAX_LEVEL) {
		showMenu__StatsZombieClass(id, -1);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_SZC] = iNewPage;

		showMenu__StatsZombieClassAll(id, iNewPage);
		return;
	}

	showMenu__StatsZombieClass(id, value);
}

public showMenu__Skins(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__SKINS));
	oldmenu_create("\ySKINS \r[%d - %d]\R\y%d / %d^n\wPuntos de Legado\r:\y %d", "menu__Skins", (iStart + 1), iEnd, page, iMaxPages, g_Points[id]);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_Skin[id] == i) {
			oldmenu_additem(-1, -1, "\r%d.\d %s \y(EQUIPADO)%s", j, __SKINS[i][skinName], ((i == 0) ? "^n" : ""));
		} else if(g_Skin_Choosed[id] == i) {
			oldmenu_additem(-1, -1, "\r%d.\d %s \y(ELEGIDO)%s", j, __SKINS[i][skinName], ((i == 0) ? "^n" : ""));
		} else if(g_Skin_Unlocked[id][i]) {
			oldmenu_additem(j, i, "\r%d.\w %s%s", j, __SKINS[i][skinName], ((i == 0) ? "^n" : ""));
		} else {
			oldmenu_additem(j, i, "\r%d.\d %s%s", j, __SKINS[i][skinName], ((i == 0) ? "^n" : ""));
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__Skins(const id, const item, const value, page) {
	if(!item || value > sizeof(__SKINS)) {
		showMenu__Character(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_SKINS] = iNewPage;

		showMenu__Skins(id, iNewPage);
		return;
	}

	if(!value) {
		g_Skin_Choosed[id] = 0;
		
		if(g_Skin[id]) {
			clientPrintColor(id, _, "Tu skin actual se removerá en la próxima ronda");
		}
		
		showMenu__Skins(id, g_MenuPage[id][MENU_PAGE_SKINS]);
		return;
	}

	g_MenuData[id][MENU_DATA_SKIN_ID] = value;
	showMenu__SkinChoosen(id);
}

public showMenu__SkinChoosen(const id) {
	new iSkinId = g_MenuData[id][MENU_DATA_SKIN_ID];

	if(iSkinId > sizeof(__SKINS)) {
		showMenu__Character(id);
		return;
	}

	new sSkinNameUpper[32];
	copy(sSkinNameUpper, charsmax(sSkinNameUpper), __SKINS[iSkinId][skinName]);
	strtoupper(sSkinNameUpper);

	oldmenu_create("\ySKIN - %s^n\wPuntos de Legado\r:\y %d", "menu__SkinChoosen", sSkinNameUpper, g_Points[id]);

	oldmenu_additem(-1, -1, "\yREQUERIMIENTO\r:");
	if(__SKINS[iSkinId][skinReq]) {
		oldmenu_additem(-1, -1, "\r - \y+%d\w pL", __SKINS[iSkinId][skinReq]);
	}
	if(__SKINS[iSkinId][skinVip]) {
		oldmenu_additem(-1, -1, "\r - \wSer jugador \yVIP\w");
	}
	if(__SKINS[iSkinId][skinAppMobile]) {
		oldmenu_additem(-1, -1, "\r - \wTener vinculado tu cuenta a la \yAPP Mobile\w");
	}

	if(!g_Skin_Unlocked[id][iSkinId]) {
		if(g_Points[id] >= __SKINS[iSkinId][skinReq]) {
			oldmenu_additem(1, 1, "^n\r1.\w Comprar skin");
		} else {
			oldmenu_additem(-1, -1, "^n\d1. Comprar skin");
		}

		oldmenu_additem(-1, -1, "\d2. Mostrar en el chat");
	} else {
		oldmenu_additem(1, 1, "^n\r1.\w Equipar skin");
		oldmenu_additem(2, 2, "\r2.\w Mostrar en el chat");
	}

	oldmenu_additem(5, 5, "^n\r5.\w Vista previa");

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__SkinChoosen(const id, const item) {
	new iPage = g_MenuPage[id][MENU_PAGE_SKINS];
	new iSkinId = g_MenuData[id][MENU_DATA_SKIN_ID];

	if(!item || iSkinId > sizeof(__SKINS)) {
		showMenu__Skins(id, iPage);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Skin_Unlocked[id][iSkinId]) {
				g_Skin_Choosed[id] = iSkinId;
				clientPrintColor(id, _, "En tu próximo respawn tu skin será !g%s!y", __SKINS[iSkinId][skinName]);
			} else if((!(get_user_flags(id) & ADMIN_RESERVATION) && __SKINS[iSkinId][skinVip]) || (!g_AccountVincAppMobile[id] && __SKINS[iSkinId][skinAppMobile])) {
				clientPrintColor(id, _, "No cumples los requisitos necesarios para utilizar este skin");

				showMenu__SkinChoosen(id);
				return;
			} else {
				if(g_Points[id] >= __SKINS[iSkinId][skinReq]) {
					clientPrintColor(id, _, "Compraste el skin !g%s!y", __SKINS[iSkinId][skinName]);

					g_Points[id] -= __SKINS[iSkinId][skinReq];
					g_PointsLose[id] += __SKINS[iSkinId][skinReq];
					g_Skin_Unlocked[id][iSkinId] = 1;

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_skins` (`acc_id`, `skin_id`, `skin_timestamp`) VALUES ('%d', '%d', '%d');", g_AccountId[id], iSkinId, get_arg_systime());
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
				} else {
					clientPrintColor(id, _, "No tienes suficientes puntos de legado");
				}

				showMenu__SkinChoosen(id);
				return;
			}

			showMenu__Skins(id, iPage);
		} case 2: {
			if(g_Skin_Unlocked[id][iSkinId]) {
				new Float:flGameTime = get_gametime();

				if(g_Skin_GameTime[id] < flGameTime) {
					g_Skin_GameTime[id] = (flGameTime + 15.0);
					clientPrintColor(0, id, "!t%s!y muestra su skin !g%s!y, conseguido el día !g%s!y", g_PlayerName[id], __SKINS[iSkinId][skinName], getUnixToTime(g_Skin_UnlockedTimeStamp[id][iSkinId]));
				}
			}

			showMenu__SkinChoosen(id);
		} case 5: {
			new sBuffer[256];
			formatex(sBuffer, charsmax(sBuffer), "<body bgcolor=^"black^"><img src=^"https://drunk-gaming.com/tops/01_zombie_escape/skins/%d.jpg^" width=^"100%%^" height=^"100%%^" border=^"0^" align=^"center^">", iSkinId);
			show_motd(id, sBuffer, "Previsualización");
		}
	}
}

public showMenu__Knifes(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__KNIFES));
	oldmenu_create("\yCUCHILLOS \r[%d - %d]\R\y%d / %d^n\wPuntos de Legado\r:\y %d", "menu__Knife", (iStart + 1), iEnd, page, iMaxPages, g_Points[id]);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_Knife[id] == i) {
			oldmenu_additem(-1, -1, "\r%d.\d %s \y(EQUIPADO)%s", j, __KNIFES[i][knifeName], ((i == 0) ? "^n" : ""));
		} else if(g_Knife_Choosed[id] == i) {
			oldmenu_additem(-1, -1, "\r%d.\d %s \y(ELEGIDO)%s", j, __KNIFES[i][knifeName], ((i == 0) ? "^n" : ""));
		} else if(g_Knife_Unlocked[id][i]) {
			oldmenu_additem(j, i, "\r%d.\w %s%s", j, __KNIFES[i][knifeName], ((i == 0) ? "^n" : ""));
		} else {
			oldmenu_additem(j, i, "\r%d.\d %s%s", j, __KNIFES[i][knifeName], ((i == 0) ? "^n" : ""));
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__Knife(const id, const item, const value, page) {
	if(!item || value > sizeof(__KNIFES)) {
		showMenu__Character(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_KNIFES] = iNewPage;

		showMenu__Knifes(id, iNewPage);
		return;
	}

	if(!value) {
		g_Knife_Choosed[id] = 0;
		
		if(g_Knife[id]) {
			clientPrintColor(id, _, "Tu cuchillo actual se removerá en la próxima ronda");
		}
		
		showMenu__Knifes(id, g_MenuPage[id][MENU_PAGE_KNIFES]);
		return;
	}

	g_MenuData[id][MENU_DATA_KNIFE_ID] = value;
	showMenu__KnifeChoosen(id);
}

public showMenu__KnifeChoosen(const id) {
	new iKnifeId = g_MenuData[id][MENU_DATA_KNIFE_ID];

	if(iKnifeId > sizeof(__KNIFES)) {
		showMenu__Character(id);
		return;
	}

	new sKnifeNameUpper[32];
	copy(sKnifeNameUpper, charsmax(sKnifeNameUpper), __KNIFES[iKnifeId][knifeName]);
	strtoupper(sKnifeNameUpper);

	oldmenu_create("\yCUCHILLO - %s^n\wPuntos de Legado\r:\y %d", "menu__KnifeChoosen", sKnifeNameUpper, g_Points[id]);

	oldmenu_additem(-1, -1, "\yREQUERIMIENTO\r:");
	if(__KNIFES[iKnifeId][knifeReqPoints]) {
		oldmenu_additem(-1, -1, "\r - \y+%d\w pL", __KNIFES[iKnifeId][knifeReqPoints]);
	}
	if(__KNIFES[iKnifeId][knifeVip]) {
		oldmenu_additem(-1, -1, "\r - \wSer jugador \yVIP\w");
	}
	if(__KNIFES[iKnifeId][knifeAppMobile]) {
		oldmenu_additem(-1, -1, "\r - \wTener vinculado tu cuenta a la \yAPP Mobile\w");
	}

	if(!g_Knife_Unlocked[id][iKnifeId]) {
		if(g_Level[id] >= __KNIFES[iKnifeId][knifeReqLevel]) {
			if(g_Points[id] >= __KNIFES[iKnifeId][knifeReqPoints]) {
				oldmenu_additem(1, 1, "^n\r1.\w Comprar cuchillo");
			} else {
				oldmenu_additem(-1, -1, "^n\d1. Comprar cuchillo");
			}
		} else {
			oldmenu_additem(-1, -1, "^n\d1. Comprar cuchillo \r(N: %d)\w", __KNIFES[iKnifeId][knifeReqLevel]);
		}

		oldmenu_additem(-1, -1, "\d2. Mostrar en el chat");
	} else {
		oldmenu_additem(1, 1, "^n\r1.\w Equipar cuchillo");
		oldmenu_additem(2, 2, "\r2.\w Mostrar en el chat");
	}

	oldmenu_additem(5, 5, "^n\r5.\w Vista previa");

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__KnifeChoosen(const id, const item) {
	new iPage = g_MenuPage[id][MENU_PAGE_KNIFES];
	new iKnifeId = g_MenuData[id][MENU_DATA_KNIFE_ID];

	if(!item || iKnifeId > sizeof(__KNIFES)) {
		showMenu__Knifes(id, iPage);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Knife_Unlocked[id][iKnifeId]) {
				g_Knife_Choosed[id] = iKnifeId;
				clientPrintColor(id, _, "En tu próximo respawn tu cuchillo será !g%s!y", __KNIFES[iKnifeId][knifeName]);
			} else if((!(get_user_flags(id) & ADMIN_RESERVATION) && __KNIFES[iKnifeId][knifeVip]) || (!g_AccountVincAppMobile[id] && __KNIFES[iKnifeId][knifeAppMobile])) {
				clientPrintColor(id, _, "No cumples los requisitos necesarios para utilizar este cuchillo");

				showMenu__KnifeChoosen(id);
				return;
			} else {
				if(g_Level[id] >= __KNIFES[iKnifeId][knifeReqLevel]) {
					if(g_Points[id] >= __KNIFES[iKnifeId][knifeReqPoints]) {
						clientPrintColor(id, _, "Compraste el cuchillo !g%s!y", __KNIFES[iKnifeId][knifeName]);

						g_Points[id] -= __KNIFES[iKnifeId][knifeReqPoints];
						g_PointsLose[id] += __KNIFES[iKnifeId][knifeReqPoints];
						g_Knife_Unlocked[id][iKnifeId] = 1;

						formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_knifes` (`acc_id`, `knife_id`, `knife_timestamp`) VALUES ('%d', '%d', '%d');", g_AccountId[id], iKnifeId, get_arg_systime());
						SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
					} else {
						clientPrintColor(id, _, "No tienes suficientes puntos de legado");
					}
				} else {
					clientPrintColor(id, _, "No tienes suficiente nivel");
				}

				showMenu__KnifeChoosen(id);
				return;
			}

			showMenu__Knifes(id, iPage);
		} case 2: {
			if(g_Knife_Unlocked[id][iKnifeId]) {
				new Float:flGameTime = get_gametime();

				if(g_Knife_GameTime[id] < flGameTime) {
					g_Knife_GameTime[id] = (flGameTime + 15.0);
					clientPrintColor(0, id, "!t%s!y muestra su cuchillo !g%s!y, conseguido el día !g%s!y", g_PlayerName[id], __KNIFES[iKnifeId][knifeName], getUnixToTime(g_Knife_UnlockedTimeStamp[id][iKnifeId]));
				}
			}

			showMenu__KnifeChoosen(id);
		} case 5: {
			new sBuffer[256];
			formatex(sBuffer, charsmax(sBuffer), "<html><head><style>body {background:#000;color:#FFF;}</style><meta http-equiv=^"Refresh^" content=^"0;url=https://www.drunkgaming.net/tops/01_ze/preview/preview.php?cat=2&id=%d^"></head><body><p>Cargando . . .</p></body></html>", iKnifeId);
			show_motd(id, sBuffer, "Previsualización");
		}
	}
}

public showMenu__Hats(const id, page) {
	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__HATS));
	oldmenu_create("\yGORROS \r[%d - %d]\R\y%d / %d^n\wPuntos de Legado\r:\y %d", "menu__Hats", (iStart + 1), iEnd, page, iMaxPages, g_Points[id]);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(g_Hat[id] == i) {
			oldmenu_additem(-1, -1, "\r%d.\d %s \y(EQUIPADO)%s", j, __HATS[i][hatName], ((i == 0) ? "^n" : ""));
		} else if(g_Hat_Choosed[id] == i) {
			oldmenu_additem(-1, -1, "\r%d.\d %s \y(ELEGIDO)%s", j, __HATS[i][hatName], ((i == 0) ? "^n" : ""));
		} else if(g_Hat_Unlocked[id][i]) {
			oldmenu_additem(j, i, "\r%d.\w %s%s", j, __HATS[i][hatName], ((i == 0) ? "^n" : ""));
		} else {
			oldmenu_additem(j, i, "\r%d.\d %s%s", j, __HATS[i][hatName], ((i == 0) ? "^n" : ""));
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__Hats(const id, const item, const value, page) {
	if(!item || value > sizeof(__HATS)) {
		showMenu__Character(id);
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_HATS] = iNewPage;

		showMenu__Hats(id, iNewPage);
		return;
	}

	if(!value) {
		g_Hat_Choosed[id] = 0;
		
		if(g_Hat[id]) {
			clientPrintColor(id, _, "Tu gorro actual se removerá en la próxima ronda");
		}
		
		showMenu__Hats(id, g_MenuPage[id][MENU_PAGE_HATS]);
		return;
	}

	g_MenuData[id][MENU_DATA_HAT_ID] = value;
	showMenu__HatChoosen(id);
}

public showMenu__HatChoosen(const id) {
	new iHatId = g_MenuData[id][MENU_DATA_HAT_ID];

	if(iHatId > sizeof(__HATS)) {
		showMenu__Character(id);
		return;
	}

	new sHatNameUpper[32];
	copy(sHatNameUpper, charsmax(sHatNameUpper), __HATS[iHatId][hatName]);
	strtoupper(sHatNameUpper);

	oldmenu_create("\yGORRO - %s^n\wPuntos de Legado\r:\y %d", "menu__HatChoosen", sHatNameUpper, g_Points[id]);

	oldmenu_additem(-1, -1, "\yREQUERIMIENTO\r:");
	if(__HATS[iHatId][hatReq]) {
		oldmenu_additem(-1, -1, "\r - \y+%d\w pL", __HATS[iHatId][hatReq]);
	}
	if(__HATS[iHatId][hatVip]) {
		oldmenu_additem(-1, -1, "\r - \wSer jugador \yVIP\w");
	}
	if(__HATS[iHatId][hatAppMobile]) {
		oldmenu_additem(-1, -1, "\r - \wTener vinculado tu cuenta a la \yAPP Mobile\w");
	}

	if(!g_Hat_Unlocked[id][iHatId]) {
		if(g_Points[id] >= __HATS[iHatId][hatReq]) {
			oldmenu_additem(1, 1, "^n\r1.\w Comprar gorro");
		} else {
			oldmenu_additem(-1, -1, "^n\d1. Comprar gorro");
		}

		oldmenu_additem(-1, -1, "\d2. Mostrar en el chat");
	} else {
		oldmenu_additem(1, 1, "^n\r1.\w Equipar gorro");
		oldmenu_additem(2, 2, "\r2.\w Mostrar en el chat");
	}

	oldmenu_additem(5, 5, "^n\r5.\w Vista previa");

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__HatChoosen(const id, const item) {
	new iPage = g_MenuPage[id][MENU_PAGE_HATS];
	new iHatId = g_MenuData[id][MENU_DATA_HAT_ID];

	if(!item || iHatId > sizeof(__HATS)) {
		showMenu__Hats(id, iPage);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Hat_Unlocked[id][iHatId]) {
				g_Hat_Choosed[id] = iHatId;
				clientPrintColor(id, _, "En tu próximo respawn tu gorro será !g%s!y", __HATS[iHatId][hatName]);
			} else if((!(get_user_flags(id) & ADMIN_RESERVATION) && __HATS[iHatId][hatVip]) || (!g_AccountVincAppMobile[id] && __HATS[iHatId][hatAppMobile])) {
				clientPrintColor(id, _, "No cumples los requisitos necesarios para utilizar este gorro");

				showMenu__HatChoosen(id);
				return;
			} else {
				if(g_Points[id] >= __HATS[iHatId][hatReq]) {
					clientPrintColor(id, _, "Compraste el gorro !g%s!y", __HATS[iHatId][hatName]);

					g_Points[id] -= __HATS[iHatId][hatReq];
					g_PointsLose[id] += __HATS[iHatId][hatReq];
					g_Hat_Unlocked[id][iHatId] = 1;

					formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_hats` (`acc_id`, `hat_id`, `hat_timestamp`) VALUES ('%d', '%d', '%d');", g_AccountId[id], iHatId, get_arg_systime());
					SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);
				} else {
					clientPrintColor(id, _, "No tienes suficientes puntos de legado");
				}

				showMenu__HatChoosen(id);
				return;
			}

			showMenu__Hats(id, iPage);
		} case 2: {
			if(g_Hat_Unlocked[id][iHatId]) {
				new Float:flGameTime = get_gametime();

				if(g_Hat_GameTime[id] < flGameTime) {
					g_Hat_GameTime[id] = (flGameTime + 15.0);
					clientPrintColor(0, id, "!t%s!y muestra su gorro !g%s!y, conseguido el día !g%s!y", g_PlayerName[id], __HATS[iHatId][hatName], getUnixToTime(g_Hat_UnlockedTimeStamp[id][iHatId]));
				}
			}

			showMenu__HatChoosen(id);
		} case 5: {
			new sBuffer[256];
			formatex(sBuffer, charsmax(sBuffer), "<body bgcolor=^"black^"><img src=^"https://drunk-gaming.com/tops/01_zombie_escape/hats/%d.jpg^" width=^"100%%^" height=^"100%%^" border=^"0^" align=^"center^">", iHatId);
			show_motd(id, sBuffer, "Previsualización");
		}
	}
}

public clcmd__Radio1(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_Link_AchievementId != -1) {
		g_MenuData[id][MENU_DATA_ACHIEVEMENT_ID] = g_Link_AchievementId;
		g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS] = g_Link_AchievementClass;

		showMenu__AchievementInfo(id);
	}

	return PLUGIN_HANDLED;
}

public showMenu__ExtraItems(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	new iCost;
	new iTeam;
	new sExtraMap[16];

	iMenuId = menu_create("ITEMS EXTRAS\R", "menu__ExtraItems");

	for(i = 0; i < structIdExtraItem; ++i) {
		iCost = __EXTRA_ITEMS[i][extraItemCost];
		iTeam = __EXTRA_ITEMS[i][extraItemTeam];

		if((!g_Zombie[id] && iTeam == EXTRA_ITEM_TEAM_ZOMBIE) || (g_Zombie[id] && iTeam == EXTRA_ITEM_TEAM_HUMAN)) {
			continue;
		}

		sExtraMap[0] = EOS;

		if(__EXTRA_ITEMS[i][extraItemLimitMap]) {
			formatex(sExtraMap, charsmax(sExtraMap), " %s[%d / %d]", ((g_APs[id] >= iCost) ? "\w" : "\d"), g_ExtraItem_InMap[i], __EXTRA_ITEMS[i][extraItemLimitMap]);
		}

		formatex(sItem, charsmax(sItem), "%s %s(%d APs)%s", __EXTRA_ITEMS[i][extraItemName], ((g_APs[id] >= iCost) ? "\y" : "\r"), iCost, sExtraMap);

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

	if(!g_IsAlive[id] || g_SpecialMode[id] || g_NewRound || g_EndRound || item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	new iItemId;

	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	buyExtraItem(id, sPosition[0], 0);
	return PLUGIN_HANDLED;
}

public buyExtraItem(const id, const extra_item, const ignore_cost) {
	new iCost = __EXTRA_ITEMS[extra_item][extraItemCost];
	new iTeam = __EXTRA_ITEMS[extra_item][extraItemTeam];

	if((!g_Zombie[id] && iTeam == EXTRA_ITEM_TEAM_ZOMBIE) || (g_Zombie[id] && iTeam == EXTRA_ITEM_TEAM_HUMAN)) {
		clientPrintColor(id, _, "Debes ser humano para comprar Items humanos o zombie para comprar Items zombies");

		showMenu__ExtraItems(id);
		return;
	}

	if(__EXTRA_ITEMS[extra_item][extraItemLimitUserInRound] && g_ExtraItem_InRound[id][extra_item] >= __EXTRA_ITEMS[extra_item][extraItemLimitUserInRound]) {
		clientPrintColor(id, _, "Has superado el límite de compra en esta ronda. En la próxima ronda podrás volver a utilizarlo");

		showMenu__ExtraItems(id);
		return;
	}

	if(__EXTRA_ITEMS[extra_item][extraItemLimitMap] && g_ExtraItem_InMap[extra_item] >= __EXTRA_ITEMS[extra_item][extraItemLimitMap]) {
		clientPrintColor(id, _, "Has superado el límite de compra en este mapa");

		showMenu__ExtraItems(id);
		return;
	}

	if(!ignore_cost) {
		if((g_APs[id] - iCost) < 0.0) {
			clientPrintColor(id, _, "No tenés suficientes APs");

			showMenu__ExtraItems(id);
			return;
		}
	}

	switch(extra_item) {
		case EXTRA_ITEM_ANTIDOTE: {
			if(getZombies() <= 1) {
				clientPrintColor(id, _, "Deben haber 2 o más zombies para comprar Antídoto");

				showMenu__ExtraItems(id);
				return;
			} else if(getHumans() <= 1) {
				clientPrintColor(id, _, "Ya hay un último humano y en estas instancias no puedes comprar Antídito");

				showMenu__ExtraItems(id);
				return;
			} else if(g_Mode != MODE_INFECTION && g_Mode != MODE_MULTI) {
				clientPrintColor(id, _, "No puedes comprar Antídoto en el moco actual (!g%s!y)", __MODES[g_Mode][modeName]);

				showMenu__ExtraItems(id);
				return;
			}

			clientPrintColor(0, id, "!t%s!y compró antidoto", g_PlayerName[id]);
			humanMe(id);
		} case EXTRA_ITEM_MADNESS: {
			if(g_Mode != MODE_INFECTION && g_Mode != MODE_MULTI) {
				clientPrintColor(id, _, "No puedes comprar Furia Zombie en el moco actual (!g%s!y)", __MODES[g_Mode][modeName]);

				showMenu__ExtraItems(id);
				return;
			}

			g_Immunity[id] = 1;
			g_MadnessBomb_Count[id] = 0;
			g_MadnessBomb_Move[id] = 0;

			if(g_Frozen[id]) {
				removeFrostCube(id);

				remove_task(id + TASK_FROZEN);
				task__RemoveFreeze(id + TASK_FROZEN);
			}

			remove_task(id + TASK_MADNESS_BOMB);
			remove_task(id + TASK_MADNESS);

			set_task(6.0, "task__RemoveMadness", id + TASK_MADNESS);

			emitSound(id, CHAN_BODY, __SOUND_ZOMBIE_MADNESS);
		} case EXTRA_ITEM_INFECTION_BOMB: {
			if(g_ExtraItem_InfectionBomb) {
				clientPrintColor(id, _, "Ya compraron la Bomba de Infección");

				showMenu__ExtraItems(id);
				return;
			} else if(g_Mode != MODE_INFECTION && g_Mode != MODE_MULTI) {
				clientPrintColor(id, _, "No puedes comprar Bomba de Infección en el modo actual (!g%s!y)", __MODES[g_Mode][modeName]);

				showMenu__ExtraItems(id);
				return;
			}

			++g_ExtraItem_InfectionBomb;

			if(user_has_weapon(id, CSW_HEGRENADE)) {
				cs_set_user_bpammo(id, CSW_HEGRENADE, (cs_get_user_bpammo(id, CSW_HEGRENADE) + 1));
			} else {
				give_item(id, "weapon_hegrenade");
			}
		} case EXTRA_ITEM_UNLIMITED_CLIP: {
			if(!g_ExtraItem_UnlimitedClipOn) {
				clientPrintColor(id, _, "Las balas infinitas están desactivadas en este mapa.");

				showMenu__ExtraItems(id);
				return;
			} else if(getUserUnlimitedClip(id)) {
				clientPrintColor(id, _, "Ya compraste Balas infinitas.");

				showMenu__ExtraItems(id);
				return;
			}

			setUserUnlimitedClip(id, 1);
		} case EXTRA_ITEM_BUBBLE_BOMB: {
			if(g_ExtraItem_BubbleBomb) {
				clientPrintColor(id, _, "Ya compraron la Bomba de Fuerza");

				showMenu__ExtraItems(id);
				return;
			} else if(g_BubbleBomb[id]) {
				clientPrintColor(id, _, "Ya posees una Bomba de Fuerza");

				showMenu__ExtraItems(id);
				return;
			}

			++g_ExtraItem_BubbleBomb;
			++g_BubbleBomb[id];

			if(user_has_weapon(id, CSW_SMOKEGRENADE)) {
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, (cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1));
			} else {
				give_item(id, "weapon_smokegrenade");
			}
		} case EXTRA_ITEM_MADNESS_BOMB: {
			if(g_ExtraItem_MadnessBomb) {
				clientPrintColor(id, _, "Ya compraron la Bomba droga");

				showMenu__ExtraItems(id);
				return;
			} else if(g_MadnessBomb[id]) {
				clientPrintColor(id, _, "Ya posees una Bomba droga");

				showMenu__ExtraItems(id);
				return;
			}

			++g_ExtraItem_MadnessBomb;
			++g_MadnessBomb[id];

			if(user_has_weapon(id, CSW_HEGRENADE)) {
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1);
			} else {
				give_item(id, "weapon_hegrenade");
			}
		} case EXTRA_ITEM_ANTI_FIRE: {
			if(g_ImmunityFire[id]) {
				clientPrintColor(id, _, "Ya posees Anti-Incendiaria");

				showMenu__ExtraItems(id);
				return;
			}

			g_ImmunityFire[id] = 1;
		} case EXTRA_ITEM_ANTI_FROST: {
			if(g_ImmunityFrost[id]) {
				clientPrintColor(id, _, "Ya posees Anti-Congelación");

				showMenu__ExtraItems(id);
				return;
			}

			g_ImmunityFrost[id] = 1;
		} case EXTRA_ITEM_BALROG_I: {
			dropWeapons(id, 2);
			zp_weapon_balrog1(id);
		} case EXTRA_ITEM_BALROG_XI: {
			dropWeapons(id, 1);
			zp_weapon_balrog11(id);
		} case EXTRA_ITEM_PLASMAGUN: {
			dropWeapons(id, 1);
			zp_weapon_plasmagun(id);
		} case EXTRA_ITEM_SKULL_IV: {
			dropWeapons(id, 1);
			zp_weapon_skull4(id);
		} case EXTRA_ITEM_THUNDERBOLT: {
			dropWeapons(id, 1);
			zp_weapon_thunderbolt(id);
		}
	}

	if(!ignore_cost) {
		g_APs[id] -= iCost;

		++g_ExtraItem_InRound[id][extra_item];
		++g_ExtraItem_InMap[extra_item];
	}
}

public canBuyUnlimitedClips() {
	return (equal(g_MapName, "ze_black_hawk_warz") || equal(g_MapName, "ze_atix_panic_v1") || equal(g_MapName, "zm_atix_helicopter") || equal(g_MapName, "ze_chavo_defense_b2"));
}

public clcmd__Say(const id) {
	if(!g_IsConnected[id]) {
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

	static TeamName:iTeam;
	static iGreen;
	static i;

	iGreen = ((get_user_flags(id) & ADMIN_RESERVATION) ? 1 : 0);
	iTeam = getUserTeam(id);

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i] && !dg_get_user_mute(i, id)) {
			if(iTeam == TEAM_TERRORIST || iTeam == TEAM_CT) {
				client_print_color(i, id, "%s%s%s^3 %s%s : %s", ((g_IsAlive[id]) ? "" : "^1(MUERTO) "), getUserTypeMod(id), getUserRange(id), g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
			} else {
				if(g_AccountLogged[id]) {
					client_print_color(i, id, "^1(ESPECTADOR)^3 %s%s : %s", g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
				} else if(g_AccountRegister[id]) {
					client_print_color(i, id, "^1(SIN IDENTIFICARSE)^3 %s%s : %s", g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
				} else {
					client_print_color(i, id, "^1(SIN REGISTRARSE)^3 %s%s : %s", g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
				}
			}
		}
	}

	if(g_Secret_CrazyMode_Enabled && !g_Secret_AlreadySayCrazy[id]) {
		if(containi(sMessage, "crazy") != -1) {
			g_Secret_AlreadySayCrazy[id] = 1;
			++g_Secret_CrazyMode_Count;

			if(g_Secret_CrazyMode_Count >= 25) {
				activateCrazyMode();
			} else {
				clientPrint(0, print_center, "%d", (25 - g_Secret_CrazyMode_Count));
			}
		}
	}

	if(containi(sMessage, "valentina te amo") != -1 && !g_Achievement_ValentinaTeAmo) {
		setAchievement(id, VALENTINA_TE_AMO);

		g_Achievement_ValentinaTeAmo = 1;

		remove_task(TASK_ACHIEVEMENT_VALENTINA_TE_AMO);
		set_task(random_float(15.0, 45.0), "task__AchievementValentinaTeAmo", TASK_ACHIEVEMENT_VALENTINA_TE_AMO);
	}

	// appMobileSendMessage(id, sMessage);
	return PLUGIN_HANDLED;
}

public task__AchievementValentinaTeAmo() {
	g_Achievement_ValentinaTeAmo = 0;
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

public getUserRange(const id) {
	new sRange[32];

	if(g_Zombie[id]) {
		formatex(sRange, charsmax(sRange), "^4[^1%s - %d^4]", __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName], g_Level[id]);
	} else {
		formatex(sRange, charsmax(sRange), "^4[^1%s - %d^4]", __RANGES[g_Range[id]], g_Level[id]);
	}

	return sRange;
}

public clcmd__SayTeam(const id) {
	if(!g_IsConnected[id] || !g_ClanSlot[id]) {
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

	iGreen = ((get_user_flags(id) & ADMIN_IMMUNITY) ? 1 : 0);

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i] && !dg_get_user_mute(i, id)) {
			if((get_user_flags(i) & ADMIN_LEVEL_D) && g_UserOptions_ClanChat[i]) {
				if(g_ClanSlot[id] == g_ClanSlot[i]) {
					client_print_color(i, id, "%s^4[%s] ^3%s^1 :%s %s", ((g_IsAlive[id]) ? "" : "^1(MUERTO) "), g_Clan[g_ClanSlot[id]][clanName], g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
				} else {
					client_print_color(i, id, "^1[%d] - %s^4[%s] ^3%s^1 :%s %s", g_ClanSlot[id], ((g_IsAlive[id]) ? "" : "(MUERTO) "), g_Clan[g_ClanSlot[id]][clanName], g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
				}
			}

			if(g_ClanSlot[id] == g_ClanSlot[i] && !(get_user_flags(i) & ADMIN_LEVEL_D)) {
				client_print_color(i, id, "%s^4[%s] ^3%s^1 :%s %s", ((g_IsAlive[id]) ? "" : "^1(MUERTO) "), g_Clan[g_ClanSlot[id]][clanName], g_PlayerName[id], ((iGreen) ? "^4" : "^1"), sMessage);
			}
		}
	}

	log_to_file(__CHATCLAN_FILE, "[%s] <%s><%s><%s> - (APs:%d)(XP:%d)(N:%d) - %s", g_Clan[g_ClanSlot[id]][clanName], g_PlayerName[id], g_PlayerIp[id], g_PlayerSteamId[id], g_APs[id], g_XP[id], g_Level[id], sMessage);
	return PLUGIN_HANDLED;
}

public giveXP(const id, const value) {
	g_XP[id] += value;
	checkLevel(id);
}

public fixXP(const id) {
	g_XP[id] = __XP_NEED[(g_Level[id] - 1)];
	checkLevel(id);
}

public checkLevel(const id) {
	g_XPRest[id] = (__XP_NEED[g_Level[id]] - g_XP[id]);

	if(g_XPRest[id] <= 0) {
		if(g_Level[id] >= MAX_LEVEL) {
			g_XPRest[id] = 0;
			return;
		}

		new iLevel = 0;

		while(g_XPRest[id] <= 0) {
			++g_Level[id];
			++iLevel;

			if(g_Level[id] == MAX_LEVEL) {
				g_XPRest[id] = 0;
				break;
			}

			g_XPRest[id] = (__XP_NEED[g_Level[id]] - g_XP[id]);
		}

		if(iLevel) {
			playSound(id, __SOUND_LEVEL_UP);

			clientPrintColor(id, _, "Felicidades, subiste !g+%d nivel%s!y. Ahora estás en el !gnivel %d!y", iLevel, ((iLevel != 1) ? "es" : ""), g_Level[id]);

			g_Range[id] = clamp((g_Level[id] / 10), 0, charsmax(__RANGES));
		}
	}

	g_LevelPercent[id] = clampFloat(((float(g_XP[id]) - float(__XP_NEED[(g_Level[id] - 1)])) * 100.0) / (float(__XP_NEED[g_Level[id]]) - float(__XP_NEED[(g_Level[id] - 1)])), 0.0, 100.0);
}

public clcmd__Cam(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	} else if(!g_IsAlive[id]) {
		clientPrintColor(id, _, "Debes estar vivo para utilizar este comando");
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

public task__RemoveImmunityBombs(const task_id) {
	new iId = (task_id - TASK_IMMUNITY_BOMBS);

	if(!g_IsConnected[iId]) {
		return;
	}

	g_ImmunityBombs[iId] = 0;
}

public think__Hud(const ent) {
	if(is_valid_ent(ent)) {
		static i;
		static iSpect;
		static sHealth[8];
		static sAPs[8];
		static sXP[16];
		static sXPNeed[16];

		iSpect = 0;

		for(i = 1; i <= MaxClients; ++i) {
			if(g_IsConnected[i]) {
				if(g_IsAlive[i]) {
					if(g_Mode == MODE_JERUZALEM && g_ModeJeruzalem_RewardExp[i] != -5) {
						g_ModeJeruzalem_RewardExp[i] += 5;

						set_hudmessage(255, 255, 255, -1.0, 0.2, 0, 6.0, 1.1, 0.0, 0.0, -1);
						ShowSyncHudMsg(i, g_HudSync_CountDown, "XP ACUMULADA: +%d", g_ModeJeruzalem_RewardExp[i]);
					}

					addDot(g_Health[i], sHealth, charsmax(sHealth));
					addDot(g_APs[i], sAPs, charsmax(sAPs));
					addDot(g_XP[i], sXP, charsmax(sXP));
					addDot(__XP_NEED[g_Level[i]], sXPNeed, charsmax(sXPNeed));

					set_hudmessage(g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[i][COLOR_TYPE_HUD_GENERAL][2], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][0], g_UserOptions_Hud[i][HUD_TYPE_GENERAL][1], g_UserOptions_HudEffect[i][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, 3);
					
					switch(g_UserOptions_HudStyle[i][HUD_TYPE_GENERAL]) {
						case 0: {
							ShowSyncHudMsg(i, g_HudSync_General, "%sVida: %s^nChaleco: %d^nClase: %s^nAPs: %s^nXP: %s / %s^nNivel: %d (%0.2f%%)^nRango: %s", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_PlayerClassName[i], sAPs, sXP, sXPNeed, g_Level[i], g_LevelPercent[i], __RANGES[g_Range[i]]);
						} case 1: {
							ShowSyncHudMsg(i, g_HudSync_General, "%s[Vida: %s]^n[Chaleco: %d]^n[Clase: %s]^n[APs: %s]^n[XP: %s / %s]^n[Nivel: %d (%0.2f%%)]^n[Rango: %s]", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_PlayerClassName[i], sAPs, sXP, sXPNeed, g_Level[i], g_LevelPercent[i], __RANGES[g_Range[i]]);
						} case 2: {
							ShowSyncHudMsg(i, g_HudSync_General, "%sVida: %s - Chaleco: %d - Clase: %s - APs: %s^nXP: %s / %s - Nivel: %d (%0.2f%%) - Rango: %s", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_PlayerClassName[i], sAPs, sXP, sXPNeed, g_Level[i], g_LevelPercent[i], __RANGES[g_Range[i]]);
						} case 3: {
							ShowSyncHudMsg(i, g_HudSync_General, "%s[Vida: %s] - [Chaleco: %d] - [Clase: %s] - [APs: %s]^n[XP: %s / %s] - [Nivel: %d (%0.2f%%)] - [Rango: %s]", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_PlayerClassName[i], sAPs, sXP, sXPNeed, g_Level[i], g_LevelPercent[i], __RANGES[g_Range[i]]);
						} case 4: {
							ShowSyncHudMsg(i, g_HudSync_General, "%s - Vida: %s - Chaleco: %d - Clase: %s - APs: %s - ^n - XP: %s / %s - Nivel: %d (%0.2f%%) - Rango: %s - ", getHealthSpecialMode(i), sHealth, get_user_armor(i), g_PlayerClassName[i], sAPs, sXP, sXPNeed, g_Level[i], g_LevelPercent[i], __RANGES[g_Range[i]]);
						}
					}
				} else {
					iSpect = entity_get_int(i, EV_ID_SPEC);

					if(g_IsAlive[iSpect]) {
						addDot(g_Health[iSpect], sHealth, charsmax(sHealth));
						addDot(g_APs[iSpect], sAPs, charsmax(sAPs));
						addDot(g_XP[iSpect], sXP, charsmax(sXP));
						addDot(__XP_NEED[g_Level[iSpect]], sXPNeed, charsmax(sXPNeed));

						set_hudmessage(g_UserOptions_Color[iSpect][COLOR_TYPE_HUD_GENERAL][0], g_UserOptions_Color[iSpect][COLOR_TYPE_HUD_GENERAL][1], g_UserOptions_Color[iSpect][COLOR_TYPE_HUD_GENERAL][2], 0.6, 0.6, g_UserOptions_HudEffect[iSpect][HUD_TYPE_GENERAL], 6.0, 1.1, 0.0, 0.0, 3);

						switch(g_UserOptions_HudStyle[iSpect][HUD_TYPE_GENERAL]) {
							case 0: {
								ShowSyncHudMsg(i, g_HudSync_General, "Siguiendo a: %s^nVida: %s^nChaleco: %d^nClase: %s^nAPs: %s^nXP: %s / %s^nNivel: %d (%0.2f%%)^nRango: %s", g_PlayerName[iSpect], sHealth, get_user_armor(iSpect), g_PlayerClassName[iSpect], sAPs, sXP, sXPNeed, g_Level[iSpect], g_LevelPercent[iSpect], __RANGES[g_Range[iSpect]]);
							} case 1: {
								ShowSyncHudMsg(i, g_HudSync_General, "[Siguiendo a: %s]^n[Vida: %s]^n[Chaleco: %d]^n[Clase: %s]^n[APs: %s]^n[XP: %s / %s]^n[Nivel: %d (%0.2f%%)]^n[Rango: %s]", g_PlayerName[iSpect], sHealth, get_user_armor(iSpect), g_PlayerClassName[iSpect], sAPs, sXP, sXPNeed, g_Level[iSpect], g_LevelPercent[iSpect], __RANGES[g_Range[iSpect]]);
							} case 2: {
								ShowSyncHudMsg(i, g_HudSync_General, "Siguiendo a: %s^nVida: %s - Chaleco: %d - Clase: %s - APs: %s^nXP: %s / %s - Nivel: %d (%0.2f%%) - Rango: %s", g_PlayerName[iSpect], sHealth, get_user_armor(iSpect), g_PlayerClassName[iSpect], sAPs, sXP, sXPNeed, g_Level[iSpect], g_LevelPercent[iSpect], __RANGES[g_Range[iSpect]]);
							} case 3: {
								ShowSyncHudMsg(i, g_HudSync_General, "[Siguiendo a: %s]^n[Vida: %s] - [Chaleco: %d] - [Clase: %s] - [APs: %s]^n[XP: %s / %s] - [Nivel: %d (%0.2f%%)] - [Rango: %s]", g_PlayerName[iSpect], sHealth, get_user_armor(iSpect), g_PlayerClassName[iSpect], sAPs, sXP, sXPNeed, g_Level[iSpect], g_LevelPercent[iSpect], __RANGES[g_Range[iSpect]]);
							} case 4: {
								ShowSyncHudMsg(i, g_HudSync_General, " - Siguiendo a: %s - ^n - Vida: %s - Chaleco: %d - Clase: %s - APs: %s - ^n - XP: %s / %s - Nivel: %d (%0.2f%%) - Rango: %s - ", g_PlayerName[iSpect], sHealth, get_user_armor(iSpect), g_PlayerClassName[iSpect], sAPs, sXP, sXPNeed, g_Level[iSpect], g_LevelPercent[iSpect], __RANGES[g_Range[iSpect]]);
							}
						}
					}
				}
			}
		}

		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 1.0));
	}
}

public fireExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	new iVictim = -1;
	new iArgs[2];

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	createExplosion(vecOrigin, 255, 0, 0, 555.0);

	emitSound(ent, CHAN_WEAPON, __SOUND_GRENADE_FIRE);

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) > 0) {
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Burning_Duration[iVictim] || g_Immunity[iVictim] || g_ImmunityBombs[iVictim] || g_ImmunityFire[iVictim]) {
			continue;
		}

		g_Burning_Duration[iVictim] += 60;
		
		iArgs[0] = iAttacker;
		iArgs[1] = 1; // ¿Afecta a los Zombies?

		if(!task_exists(iVictim + TASK_BURN_FLAME)) {
			set_task(0.2, "task__BurningFlame", iVictim + TASK_BURN_FLAME, iArgs, sizeof(iArgs), "b");
		}
	}

	remove_entity(ent);
}

public task__BurningFlame(const args[], const task_id) {
	static iId;
	iId = (task_id - TASK_BURN_FLAME);

	if(!g_IsConnected[iId]) {
		remove_task(task_id);
		return;
	}

	static vecOrigin[3];
	static iFlags;
	static iAffectZombie;

	get_user_origin(iId, vecOrigin);
	iFlags = entity_get_int(iId, EV_INT_flags);
	iAffectZombie = args[1];

	if((!iAffectZombie && g_Zombie[iId]) || g_Immunity[iId] || (iFlags & FL_INWATER) || g_Burning_Duration[iId] < 1) {
		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_SMOKE);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord(vecOrigin[2] - 50);
		write_short(g_Sprite_Smoke);
		write_byte(random_num(15, 20));
		write_byte(random_num(10, 20));
		message_end();

		remove_task(task_id);
		return;
	}

	if(!iAffectZombie && (iFlags & FL_ONGROUND)) {
		static Float:vecVelocity[3];
		entity_get_vector(iId, EV_VEC_velocity, vecVelocity);
		xs_vec_mul_scalar(vecVelocity, 1.0, vecVelocity);
		entity_set_vector(iId, EV_VEC_velocity, vecVelocity);
	}

	static iDamage;
	static iTotalDamage;

	iDamage = ((!iAffectZombie) ? 1 : 6);
	iTotalDamage = (g_Health[iId] - iDamage);

	if(iTotalDamage < g_Health[iId]) {
		set_user_health(iId, iTotalDamage);
		g_Health[iId] = get_user_health(iId);
	} else {
		if(!iAffectZombie) {
			ExecuteHamB(Ham_Killed, iId, args[0], 1);
		}
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

	--g_Burning_Duration[iId];
}

public frostExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	if(get_entity_flags(ent) & FL_INWATER) {
		remove_entity(ent);
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	new iVictim = -1;

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	createExplosion(vecOrigin, 0, 0, 255, 555.0);

	emitSound(ent, CHAN_WEAPON, __SOUND_GRENADE_FROST);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, (vecOrigin[2] + 5.0));
	write_short(g_Sprite_FrostExplode);
	write_byte(20);
	write_byte(24);
	write_byte(TE_EXPLFLAG_NOSOUND);
	message_end();

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) > 0) {
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Frozen[iVictim] || g_Immunity[iVictim] || g_ImmunityBombs[iVictim] || g_ImmunityFrost[iVictim]) {
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

		g_Speed[iVictim] = 1.0;
		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iVictim);

		remove_task(iVictim + TASK_FROZEN);
		set_task(4.0, "task__RemoveFreeze", iVictim + TASK_FROZEN);

		emitSound(iVictim, CHAN_BODY, __SOUND_GRENADE_FROST_PLAYER);

		if(task_exists(iVictim + TASK_ZOMBIE_FLESHPOUND_AURA)) {
			remove_task(iVictim + TASK_ZOMBIE_FLESHPOUND);
			remove_task(iVictim + TASK_ZOMBIE_FLESHPOUND_AURA);

			set_task(0.1, "task__ZombieFleshpound", iVictim + TASK_ZOMBIE_FLESHPOUND);
		}
	}

	remove_entity(ent);
}

public frostExplodeCube(const victim) {
	new iEnt = create_entity("info_target");

	if(!is_valid_ent(iEnt)) {
		return;
	}

	entity_set_string(iEnt, EV_SZ_classname, __ENT_THINK_FROST);

	entity_set_int(iEnt, EV_INT_body, 1);
	entity_set_model(iEnt, __MODEL_FROST);

	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);

	if(entity_get_int(victim, EV_INT_button) & IN_DUCK) {
		entity_set_int(victim, EV_INT_button, entity_get_int(victim, EV_INT_button) & ~IN_DUCK);
	}

	new Float:vecOrigin[3];

	entity_get_vector(victim, EV_VEC_origin, vecOrigin);
	vecOrigin[2] -= 36.0;
	entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);

	entity_set_edict(iEnt, EV_ENT_owner, victim);
	entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_NO);
	entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 4.0));
}

public removeFrostCube(const id) {
	if(g_IsConnected[id]) {
		new iEnt = -1;

		if(is_valid_ent((iEnt = find_ent_by_owner(0, __ENT_THINK_FROST, id)))) {
			remove_entity(iEnt);
		}
	}
}

public task__RemoveFreeze(const task_id) {
	new iId = (task_id - TASK_FROZEN);

	if(!g_IsAlive[iId] || !g_Frozen[iId]) {
		return;
	}

	g_Speed[iId] = Float:zombieSpeed(iId, g_ZombieClass[iId]);
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);

	set_user_gravity(iId, g_FrozenGravity[iId]);

	if(g_Zombie[iId] && g_ZombieClass[iId] == ZOMBIE_CLASS_LUSTY_ROSE && g_ZombieClass_LustyRoseActive[iId] == 2) {
		set_user_rendering(iId, kRenderFxGlowShell, 20, 20, 20, kRenderTransAlpha, 5);
	} else {
		set_user_rendering(iId);
	}

	if(!g_MadnessBomb_Move[iId]) {
		message_begin(MSG_ONE, g_Message_ScreenFade, _, iId);
		write_short(UNIT_SECOND);
		write_short(0);
		write_short(FFADE_IN);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		write_byte(100);
		message_end();
	}

	new vecOrigin[3];
	get_user_origin(iId, vecOrigin);

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

	g_Frozen[iId] = 0;
}

public think__Frost(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}

	remove_entity(ent);
}

public ham__PlayerPreThinkPre(const id) {
	if(!g_IsAlive[id]) {
		return;
	}

	if(g_Zombie[id]) {
		entity_set_int(id, EV_NADE_TYPE, STEPTIME_SILENT);
	} else {
		if(!g_SpecialMode[id] && g_ZombieClass_BansheeStat[id] && g_ZombieClass_BansheeOwner[id]) {
			static Float:vecOriginId[3];
			static Float:vecOriginOwner[3];
			static Float:vecNewOrigin[3];
			static Float:vecVelocity[3];

			entity_get_vector(id, EV_VEC_origin, vecOriginId);
			entity_get_vector(g_ZombieClass_BansheeOwner[id], EV_VEC_origin, vecOriginOwner);
			
			vecNewOrigin[0] = (vecOriginOwner[0] - vecOriginId[0]);
			vecNewOrigin[1] = (vecOriginOwner[1] - vecOriginId[1]);
			vecNewOrigin[2] = (vecOriginOwner[2] - vecOriginId[2]);

			engfunc(EngFunc_VecToAngles, vecNewOrigin, vecVelocity);
			engfunc(EngFunc_MakeVectors, vecVelocity);

			global_get(glb_v_forward, vecVelocity);

			vecVelocity[0] *= 100.0;
			vecVelocity[1] *= 100.0;
			vecVelocity[2] = 0.0;
			
			entity_set_vector(id, EV_VEC_velocity, vecVelocity);
		}
	}

	if(g_Frozen[id]) {
		set_user_velocity(id, Float:{0.0, 0.0, 0.0});
		return;
	}

	if(g_SpecialMode[id]) {
		static Float:flGameTime;
		static Float:flCoolDown;

		flGameTime = get_gametime();
		flCoolDown = 0.0;

		if((flGameTime - g_LongJump_LastTime[id]) < flCoolDown) {
			return;
		}

		if(!(entity_get_int(id, EV_INT_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK))) {
			return;
		}

		if(!(entity_get_int(id, EV_INT_flags) & FL_ONGROUND) || get_speed(id) < 5) {
			return;
		}

		static Float:vecVelocity[3];
		velocity_by_aim(id, 500, vecVelocity);
		vecVelocity[2] = 300.0;
		entity_set_vector(id, EV_VEC_velocity, vecVelocity);

		g_LongJump_LastTime[id] = flGameTime;
	}
}

public explosiveExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	if(entity_get_int(ent, EV_INT_flags) & FL_INWATER) {
		remove_entity(ent);
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	new iVictim = -1;
	new iDamage = random_num(500, 1000);
	new iTotal;

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	createExplosion(vecOrigin, 200, 100, 0, 555.0);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_Explode);
	write_byte(40);
	write_byte(25);
	write_byte(0);
	message_end();

	emitSound(ent, CHAN_WEAPON, __SOUND_GRENADE_EXPLODE);

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) > 0) {
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_ImmunityBombs[iVictim]) {
			continue;
		}

		iTotal = (g_Health[iVictim] - iDamage);

		if(iTotal < g_Health[iVictim]) {
			set_user_health(iVictim, iTotal);
			g_Health[iVictim] = get_user_health(iVictim);
		} else {
			ExecuteHamB(Ham_Killed, iVictim, iAttacker, 1);
		}
	}

	remove_entity(ent);
}

public flareLighting(const entity, const duration, const flare_size) {
	new Float:vecOrigin[3];
	new Float:vecColor[3];

	entity_get_vector(entity, EV_VEC_origin, vecOrigin);
	entity_get_vector(entity, EV_FLARE_COLOR, vecColor);

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

public bubblePush(const ent) {
	static iVictim;
	static Float:fInvSqrt;
	static Float:fScalar;
	static Float:vecOrigin[3];
	static Float:vecEntityOrigin[3];
	static iUsers[MAX_PLAYERS + 1];
	static i;
	static j;

	entity_get_vector(ent, EV_VEC_origin, vecEntityOrigin);
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
				g_InBubble[iUsers[i]] = 1;
			} else {
				g_InBubble[iUsers[i]] = 0;
			}
		} else if(g_Zombie[iUsers[i]] && !g_SpecialMode[iUsers[i]] && !g_Immunity[iUsers[i]] && !g_ImmunityBombs[iUsers[i]]) {
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

public createExplosion(const Float:vecOrigin[3], const red, const green, const blue, const Float:radios) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, (vecOrigin[2] + radios));
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

public task__RemoveMadness(const task_id) {
	new iId = (task_id - TASK_MADNESS);

	if(!g_IsAlive[iId]) {
		remove_task(task_id);
		return;
	}

	g_Immunity[iId] = 0;
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

public fixDeadAttrib(const id) {
	message_begin(MSG_BROADCAST, g_Message_ScoreAttrib);
	write_byte(id);
	write_byte(0);
	message_end();
}

public ham__UseButtonPre(const this, const caller, const activator, const useType, const Float:value) {
	if(caller != activator || entity_get_float(this, EV_FL_frame) > 0.0 || g_Zombie[caller] || g_Buttoned[caller]) {
		return HAM_IGNORED;
	}

	g_Buttoned[caller] = 1;

	remove_task(caller + TASK_BUTTONED);
	set_task(10.0, "task__Buttoned", caller + TASK_BUTTONED);

	clientPrintColor(0, caller, "!t%s!y ha usado un botón [!t%d!y]", g_PlayerName[caller], this);
	return HAM_IGNORED;
}

public task__Buttoned(const task_id) {
	new iId = (task_id - TASK_BUTTONED);

	if(!g_IsAlive[iId]) {
		return;
	}

	g_Buttoned[iId] = 0;
}

public ham__BreakableTakeDamagePost(const ent, const inflictor, const attacker, Float:damage, const damageBits) {
	if(!is_valid_ent(ent)) {
		return HAM_IGNORED;
	}

	if(isUserValidConnected(attacker)) {
		if(g_Breakabled[attacker] == 2) {
			return HAM_IGNORED;
		}

		new Float:flHealth = entity_get_float(ent, EV_FL_health);

		if((flHealth - damage) < 0) {
			g_Breakabled[attacker] = 1;

			if(g_Breakabled[attacker] == 1) {
				g_Breakabled[attacker] = 2;
				clientPrintColor(0, _, "!t%s!y ha roto un objeto [!t%d!y]", g_PlayerName[attacker], ent);
			}
		}
	}

	return HAM_IGNORED;
}

public clcmd__Crazy(const id) {
	if(!g_Secret_CrazyMode_Enabled) {
		new iSysTime = get_arg_systime();
		new iDifference = (g_Secret_NextCrazyMode - iSysTime);

		if(iDifference <= 0) {
			clientPrintColor(id, _, "El crazy mode está disponible para ser activado pero debes esperar al próximo mapa");
		} else {
			new iDays = 0;
			new iHours = 0;
			new iMinutes = (iDifference / 60);

			while(iMinutes >= 60) {
				++iHours;

				if(iHours == 24) {
					++iDays;
					iHours = 0;
				}

				iMinutes -= 60;
			}

			clientPrintColor(id, _, "Faltan !g%d día%s!y, !g%d hora%s!y y !g%d minuto%s!y para que se active el crazy mode", iDays, ((iDays != 1) ? "s" : ""), iHours, ((iHours != 1) ? "s" : ""), iMinutes, ((iMinutes != 1) ? "s" : ""));
		}
	} else {
		clientPrintColor(id, _, "El crazy mode está disponible para ser activado");
	}

	return PLUGIN_HANDLED;
}

public task__CrazyMode() {
	if(!g_Secret_CrazyMode) {
		return;
	}

	new iUsersAlive = getUsersAlive();
	new iUsers = (iUsersAlive / 4);
	new iAffected = 0;
	new iRandomUser;
	new Float:vecOrigin[3];

	while(iAffected < iUsers) {
		++iAffected;
		iRandomUser = getRandomAlive(random_num(1, iUsersAlive));

		entity_get_vector(iRandomUser, EV_VEC_origin, vecOrigin);

		xs_vec_sub(vecOrigin, vecOrigin, vecOrigin);
		xs_vec_normalize(vecOrigin, vecOrigin);
		xs_vec_mul_scalar(vecOrigin, (random_float(-250.0, 250.0) * random_float(-50.0, 50.0)), vecOrigin);

		entity_set_vector(iRandomUser, EV_VEC_velocity, vecOrigin);
	}

	set_task(3.0, "task__CrazyMode");
}

public activateCrazyMode() {
	if(!g_Secret_CrazyMode_Enabled) {
		return;
	}

	g_Secret_CrazyMode_Enabled = 0;
	g_Secret_CrazyMode = 1;

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_general SET crazy_mode='0' WHERE id='1';");
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	set_dhudmessage(random(256), random(256), random(256), -1.0, -1.0, 1, 0.0, 5.0, 5.0, 5.0);
	show_dhudmessage(0, "¡CRAZY!");

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i]) {
			continue;
		}

		setAchievement(i, SECRET_CRAZY_MODE);
	}

	set_cvar_num("sv_airaccelerate", -100);

	set_task(3.0, "task__CrazyMode");
}

public checkCrazyMode() {
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT crazy_mode, next_crazy_mode FROM ze3_general WHERE id='1';");

	if(!SQL_Execute(sqlQuery)) {
		executeQuery(0, sqlQuery, 9);
	} else if(SQL_NumResults(sqlQuery)) {
		g_Secret_CrazyMode_Enabled = SQL_ReadResult(sqlQuery, 0);
		g_Secret_NextCrazyMode = SQL_ReadResult(sqlQuery, 1);

		SQL_FreeHandle(sqlQuery);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
}

public fwd__AddToFullPackPost(const es, const e, const ent, const host, const host_flags, const player, const player_set) {
	if(g_Mode == MODE_JERUZALEM) {
		return FMRES_IGNORED;
	}

	if(player && g_IsAlive[host] && g_IsAlive[ent] && !g_Zombie[host] && !g_Zombie[ent]) {
		set_es(es, ES_Solid, SOLID_NOT);

		if(g_UserOptions_GlowInGroup[host]) {
			if(g_InGroup[host] && (g_InGroup[host] == g_InGroup[ent])) {
				// static vecColor[3];

				// vecColor[0] = g_UserOptions_Color[host][COLOR_TYPE_GLOW_GROUP][0];
				// vecColor[1] = g_UserOptions_Color[host][COLOR_TYPE_GLOW_GROUP][1];
				// vecColor[2] = g_UserOptions_Color[host][COLOR_TYPE_GLOW_GROUP][2];

				// set_es(es, ES_RenderFx, kRenderFxGlowShell);
				// set_es(es, ES_RenderColor, vecColor);
			} else if(!g_InGroup[host]) {
				set_es(es, ES_RenderFx, kRenderFxNone);
				set_es(es, ES_RenderColor, {0, 0, 0});
			}
		} else {
			set_es(es, ES_RenderFx, kRenderFxNone);
			set_es(es, ES_RenderColor, {0, 0, 0});
		}

		switch(g_UserOptions_Invis[host]) {
			case 0: {
				set_es(es, ES_RenderMode, kRenderTransAlpha);
				set_es(es, ES_RenderAmt, 255);
			} case 1: {
				set_es(es, ES_RenderMode, kRenderTransTexture);
				set_es(es, ES_RenderAmt, 0);
			} case 2: {
				if(g_UserOptions_GlowInGroup[host]) {
					if(g_InGroup[host] && (g_InGroup[host] == g_InGroup[ent])) {
						set_es(es, ES_RenderMode, kRenderTransAlpha);
						set_es(es, ES_RenderAmt, 75);
					} else {
						set_es(es, ES_RenderMode, kRenderTransTexture);
						set_es(es, ES_RenderAmt, 0);
					}
				} else {
					set_es(es, ES_RenderMode, kRenderTransAlpha);
					set_es(es, ES_RenderAmt, 255);
				}
			}
		}
	}

	return FMRES_IGNORED;
}

public checkStuck(const id) {
	if(!g_IsAlive[id] || !isUserStuck(id)) {
		return;
	}

	new const Float:__CHECK_STUCK[][3] = {
	    {0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	    {0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	    {0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	    {0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	    {0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
	};
	new Float:vecOrigin[3];
	new iHull = ((entity_get_int(id, EV_INT_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN);

	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	if(!isHullVacant(vecOrigin, iHull)) {
		new Float:vecMins[3];
		new Float:vecOriginFix[3];
		new i;

		entity_get_vector(id, EV_VEC_mins, vecMins);
		vecOriginFix[2] = vecOrigin[2];

		for(i = 0; i < sizeof(__CHECK_STUCK); ++i) {
			vecOriginFix[0] = (vecOrigin[0] - (vecMins[0] * __CHECK_STUCK[i][0]));
			vecOriginFix[1] = (vecOrigin[1] - (vecMins[1] * __CHECK_STUCK[i][1]));
			vecOriginFix[2] = (vecOrigin[2] - (vecMins[2] * __CHECK_STUCK[i][2]));

			if(isHullVacant(vecOriginFix, iHull))  {
				entity_set_origin(id, vecOriginFix);

				set_user_velocity(id, Float:{0.0, 0.0, 0.0});
				break;
			}
		}
	}
}

public infectionExplode(const entity) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(entity, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(entity);
		return;
	}

	new Float:vecOrigin[3];
	new iVictim = -1;

	entity_get_vector(entity, EV_VEC_origin, vecOrigin);
	createExplosion(vecOrigin, 0, 255, 0, 555.0);

	emitSound(entity, CHAN_WEAPON, __SOUND_GRENADE_INFECT);

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) > 0) {
		if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_InBubble[iVictim]) {
			continue;
		}

		giveXP(iAttacker, (5 * ((g_HappyHour) ? 2 : 1)));

		if(getHumans() == 1) {
			ExecuteHamB(Ham_Killed, iVictim, iAttacker, 0);
			break;
		}

		zombieMe(iVictim, iAttacker, .bomb=1);
	}

	remove_entity(entity);
}

public showMenu__AchievementsClass(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	
	formatex(sItem, charsmax(sItem), "LOGROS^n\wLogros completados\r:\y %d\R", g_Stats[id][STAT_ACHIEVEMENTS_DONE]);
	iMenuId = menu_create(sItem, "menu__AchievementsClass");
	
	for(i = 0; i < structIdAchievementsClass; ++i) {
		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, __ACHIEVEMENTS_CLASS[i], sPosition);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS_CLASS] = min(g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS_CLASS], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS_CLASS]);
}

public menu__AchievementsClass(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS_CLASS]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS] = iItemId;

	showMenu__Achievements(id);
	return PLUGIN_HANDLED;
}

public getAchievementTotal(const id, const class_id) {
	new iCount = 0;
	new i;

	for(i = 0; i < structIdAchievements; ++i) {
		if(class_id == __ACHIEVEMENTS[i][achievementClass] && g_Achievement[id][i]) {
			++iCount;
		}
	}

	return iCount;
}

public showMenu__Achievements(const id) {
	new iClassId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS];

	if(!(ACHIEVEMENT_CLASS_GENERAL <= iClassId <= (structIdAchievementsClass - 1))) {
		showMenu__AchievementsClass(id);
		return;
	}

	new iMenuId;
	new i;
	new sAchievementsClass[32];
	new sItem[64];
	new sPosition[2];

	copy(sAchievementsClass, charsmax(sAchievementsClass), __ACHIEVEMENTS_CLASS[iClassId]);
	strtoupper(sAchievementsClass);

	formatex(sItem, charsmax(sItem), "LOGROS %s^n\wLogros completados en esta sección\r:\y %d\R", sAchievementsClass, getAchievementTotal(id, iClassId));
	iMenuId = menu_create(sItem, "menu__Achievements");

	for(i = 0; i < structIdAchievements; ++i) {
		if(iClassId != __ACHIEVEMENTS[i][achievementClass]) {
			continue;
		}

		formatex(sItem, charsmax(sItem), "%s%s%s", ((!g_Achievement[id][i]) ? "\d" : "\w"), __ACHIEVEMENTS[i][achievementName], ((!g_Achievement[id][i]) ? " \r(INCOMPLETO)" : " \y(COMPLETO)"));

		sPosition[0] = i;
		sPosition[1] = 0;

		menu_additem(iMenuId, sItem, sPosition);
	}

	if(!menu_items(iMenuId)) {
		clientPrintColor(id, _, "No hay logros disponibles para mostrar en el menú");

		DestroyLocalMenu(id, iMenuId);

		showMenu__AchievementsClass(id);
		return;
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");

	g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS][iClassId] = min(g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS][iClassId], (menu_pages(iMenuId) - 1));

	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS][iClassId]);
}

public menu__Achievements(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}

	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_ACHIEVEMENTS][g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS]]);

	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);

		showMenu__AchievementsClass(id);
		return PLUGIN_HANDLED;
	}

	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);

	iItemId = sPosition[0];
	g_MenuData[id][MENU_DATA_ACHIEVEMENT_ID] = iItemId;

	showMenu__AchievementInfo(id);
	return PLUGIN_HANDLED;
}

public showMenu__AchievementInfo(const id) {
	new iAchievementId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_ID];

	if(!(0 <= iAchievementId < (structIdAchievements - 1))) {
		showMenu__Achievements(id);
		return;
	}

	oldmenu_create("\yLOGRO - %s", "menu__AchievementInfo", __ACHIEVEMENTS[iAchievementId][achievementName]);

	oldmenu_additem(-1, -1, "\yDESCRIPCIÓN\r:");
	oldmenu_additem(-1, -1, "\r - \w%s", __ACHIEVEMENTS[iAchievementId][achievementInfo]);

	if(__ACHIEVEMENTS[iAchievementId][achievementUsersneedP]) {
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d usuarios conectados", __ACHIEVEMENTS[iAchievementId][achievementUsersneedP]);
	} else if(__ACHIEVEMENTS[iAchievementId][achievementUsersneedA]) {
		oldmenu_additem(-1, -1, "^n\yREQUERIMIENTOS EXTRAS\r:");
		oldmenu_additem(-1, -1, "\r - \w%d usuarios vivos", __ACHIEVEMENTS[iAchievementId][achievementUsersneedA]);
	}

	oldmenu_additem(-1, -1, "^n\yRECOMPENSA\r:");
	oldmenu_additem(-1, -1, "\r - \w+%d pL", __ACHIEVEMENTS[iAchievementId][achievementReward]);

	if(g_Achievement[id][iAchievementId]) {
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO EL DÍA\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_Achievement_UnlockedTimeStamp[id][iAchievementId]));

		oldmenu_additem(1, 1, "^n\r1.\w Mostrar logro en el Chat");
	} else if(g_Achievement[0][iAchievementId]) {
		oldmenu_additem(-1, -1, "^n\yLOGRO COMPLETADO POR\r:");
		oldmenu_additem(-1, -1, "\r - \w%s", g_Achievement_UnlockedPlayerName[id][iAchievementId]);
		oldmenu_additem(-1, -1, "\r - \w%s", getUnixToTime(g_Achievement_UnlockedTimeStamp[id][iAchievementId]));

		oldmenu_additem(-1, -1, "^n\d1. Mostrar logro en el Chat");
	} else {
		oldmenu_additem(-1, -1, "^n\d1. Mostrar logro en el Chat");
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__AchievementInfo(const id, const item) {
	new iAchievementId = g_MenuData[id][MENU_DATA_ACHIEVEMENT_ID];

	if(!item || !(0 <= iAchievementId < (structIdAchievements - 1))) {
		showMenu__Achievements(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_Achievement[id][iAchievementId]) {
				new Float:flGameTime = get_gametime();

				if(g_Achievement_GameTime[id] < flGameTime) {
					g_Achievement_GameTime[id] = (flGameTime + 30.0);

					clientPrintColor(0, _, "!t%s!y muestra su logro !g%s !t[Z]!y, conseguido el !g%s!y", g_PlayerName[id], __ACHIEVEMENTS[iAchievementId][achievementName], getUnixToTime(g_Achievement_UnlockedTimeStamp[id][iAchievementId]));

					g_Link_AchievementId = iAchievementId;
					g_Link_AchievementClass = g_MenuData[id][MENU_DATA_ACHIEVEMENT_CLASS];
				}
			}

			showMenu__AchievementInfo(id);
		}
	}
}

public impulse__Spray(const id) {
	return PLUGIN_HANDLED;
}

setAchievement(const id, const achievement, const achievement_first=0, const achievement_fake=0) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return;
	}

	if(achievement_first) {
		if(g_Achievement[0][achievement]) {
			return;
		}
	} else {
		if(g_Achievement[id][achievement]) {
			return;
		}
	}

	if(!achievement_fake) {
		if(__ACHIEVEMENTS[achievement][achievementUsersneedP] && getUsersPlaying() < __ACHIEVEMENTS[achievement][achievementUsersneedP]) {
			return;
		} else if(__ACHIEVEMENTS[achievement][achievementUsersneedA] && getUsersAlive() < __ACHIEVEMENTS[achievement][achievementUsersneedA]) {
			return;
		}
	}

	new iArgSystime = get_arg_systime();

	g_Achievement[id][achievement] = 1;
	g_Achievement_UnlockedTimeStamp[id][achievement] = iArgSystime;

	if(achievement_first) {
		g_Achievement[0][achievement] = 1;
		g_Achievement_UnlockedTimeStamp[0][achievement] = iArgSystime;
	}

	++g_Stats[id][STAT_ACHIEVEMENTS_DONE];

	g_Link_AchievementId = achievement;
	g_Link_AchievementClass = __ACHIEVEMENTS[achievement][achievementClass];

	clientPrintColor(0, id, "!t%s!y ganó el logro !g%s !t(%d pL)!y [Z]", g_PlayerName[id], __ACHIEVEMENTS[achievement][achievementName], __ACHIEVEMENTS[achievement][achievementReward]);

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "INSERT INTO `ze3_achievements` (`acc_id`, `achievement_id`, `achievement_timestamp`, `achievement_first`) VALUES ('%d', '%d', '%d', '%d');", g_AccountId[id], achievement, iArgSystime, achievement_first);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

	g_Points[id] += __ACHIEVEMENTS[achievement][achievementReward];

	saveInfo(id, 0);
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

	static iWeapon;
	iWeapon = __AMMO_WEAPON[iType];

	if(__MAX_BPAMMO[iWeapon] <= 2) {
		return;
	}

	static iAmount;
	iAmount = read_data(2);

	if(iAmount < __MAX_BPAMMO[iWeapon]) {
		static iArgs[1];
		iArgs[0] = iWeapon;

		set_task(0.1, "task__RefillBPAmmo", id, iArgs, sizeof(iArgs));
	}
}

public task__RefillBPAmmo(const args[], const id) {
	if(!g_IsAlive[id] || g_Zombie[id]) {
		return;
	}

	set_msg_block(g_Message_AmmoPickup, BLOCK_ONCE);
	ExecuteHamB(Ham_GiveAmmo, id, __MAX_BPAMMO[args[0]], __AMMO_TYPE[args[0]], __MAX_BPAMMO[args[0]]);
}

public clcmd__SupplyBoxAdd(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(g_SupplyBox_Total == MAX_SUPPLYBOX) {
		consolePrint(id, "El mapa ha alcanzado el límite máximo de %d cajas", MAX_SUPPLYBOX);
		return PLUGIN_HANDLED;
	}

	new iSupplyBoxId = get_arg_systime();
	new iTempEnt = -1;
	new iTempSupplyBoxId;

	while((iTempEnt = find_ent_by_class(iTempEnt, __ENT_CLASSNAME_SUPPLYBOX)) != 0) {
		if(is_valid_ent(iTempEnt)) {
			iTempSupplyBoxId = entity_get_int(iTempEnt, EV_INT_iuser1);

			if(iSupplyBoxId == iTempSupplyBoxId) {
				consolePrint(id, "Por favor, espera al menos un segundo para volver a crear otra caja");
				return PLUGIN_HANDLED;
			}
		}
	}

	new iEnt = create_entity("info_target");

	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_SUPPLYBOX);
		dllfunc(DLLFunc_Spawn, iEnt);

		new vecOriginId[3];
		new Float:vecOrigin[3];
		new Float:vecTargetOrigin[3];
		new Float:vecAngles[3];

		get_user_origin(id, vecOriginId, 3);
		IVecFVec(vecOriginId, vecOrigin);
		vecOrigin[2] += 5.0;

		entity_set_model(iEnt, __MODEL_SUPPLYBOX);
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

		entity_set_int(iEnt, EV_INT_iuser1, iSupplyBoxId);
		entity_set_int(iEnt, EV_INT_iuser2, g_SupplyBox_Total);

		entity_set_int(iEnt, EV_INT_sequence, 0);
		entity_set_float(iEnt, EV_FL_animtime, get_gametime());
		entity_set_float(iEnt, EV_FL_framerate, 1.0);

		g_SupplyBox[g_SupplyBox_Total] = iSupplyBoxId;
		g_SupplyBox_Ent[g_SupplyBox_Total] = iEnt;
		g_SupplyBox_Origin[g_SupplyBox_Total] = vecOrigin;
		g_SupplyBox_Angles[g_SupplyBox_Total] = vecAngles;
		++g_SupplyBox_Total;
	}

	consolePrint(id, "Caja creada correctamente");
	return PLUGIN_HANDLED;
}

public clcmd__SupplyBoxRemove(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new Float:vecOrigin[3];
	new iSupplyBoxEnt = -1;
	new sClassName[32];
	new i;
	new iSupplyBox;

	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	while((iSupplyBoxEnt = engfunc(EngFunc_FindEntityInSphere, iSupplyBoxEnt, vecOrigin, 32.0)) != 0) {
		entity_get_string(iSupplyBoxEnt, EV_SZ_classname, sClassName, charsmax(sClassName));

		if(equal(sClassName, __ENT_CLASSNAME_SUPPLYBOX)) {
			if(is_valid_ent(iSupplyBoxEnt)) {
				iSupplyBox = entity_get_int(iSupplyBoxEnt, EV_INT_iuser1);

				for(i = 0; i < g_SupplyBox_Total; ++i) {
					if(!g_SupplyBox[i]) {
						continue;
					}

					if(g_SupplyBox[i] == iSupplyBox) {
						g_SupplyBox[i] = 0;
						break;
					}
				}

				remove_entity(iSupplyBoxEnt);
			}

			consolePrint(id, "Caja eliminada correctamente");
			return PLUGIN_HANDLED;
		}
	}

	consolePrint(id, "No se ha detectado la caja a eliminar. Acércate a una para eliminarla");
	return PLUGIN_HANDLED;
}

public clcmd__SupplyBoxSave(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	if(file_exists(g_SupplyBox_File)) {
		delete_file(g_SupplyBox_File);
	}

	new iFile = fopen(g_SupplyBox_File, "wt");
	new iEnt = -1;
	new iSupplyBox;
	new Float:vecOrigin[3];
	new Float:vecAngles[3];

	while((iEnt = find_ent_by_class(iEnt, __ENT_CLASSNAME_SUPPLYBOX)) != 0) {
		iSupplyBox = entity_get_int(iEnt, EV_INT_iuser1);
		entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
		entity_get_vector(iEnt, EV_VEC_angles, vecAngles);

		fprintf(iFile, "%d %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f^n", iSupplyBox, vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2]);
	}

	fclose(iFile);

	consolePrint(id, "Cajas guardadas correctamente");
	return PLUGIN_HANDLED;
}

public checkSupplyBox() {
	get_localinfo("amxx_configsdir", g_SupplyBox_File, charsmax(g_SupplyBox_File));
	format(g_SupplyBox_File, charsmax(g_SupplyBox_File), "%s/zombieescape", g_SupplyBox_File);

	if(!dir_exists(g_SupplyBox_File)) {
		mkdir(g_SupplyBox_File);
		return;
	}

	format(g_SupplyBox_File, charsmax(g_SupplyBox_File), "%s/%s.ini", g_SupplyBox_File, g_MapName);

	if(!file_exists(g_SupplyBox_File)) {
		return;
	}

	new iFile = fopen(g_SupplyBox_File, "rt");
	new sBuffer[256];
	new sId[16];
	new sOrigin[3][8];
	new sAngles[3][8];

	g_SupplyBox_Total = 0;

	while(!feof(iFile)) {
		fgets(iFile, sBuffer, charsmax(sBuffer));
		trim(sBuffer);

		if(parse(sBuffer, sId, charsmax(sId), sOrigin[0], charsmax(sOrigin[]), sOrigin[1], charsmax(sOrigin[]), sOrigin[2], charsmax(sOrigin[]), sAngles[0], charsmax(sAngles[]), sAngles[1], charsmax(sAngles[]), sAngles[2], charsmax(sAngles[])) != 7) {
			continue;
		}

		g_SupplyBox[g_SupplyBox_Total] = str_to_num(sId);
		g_SupplyBox_Origin[g_SupplyBox_Total][0] = str_to_float(sOrigin[0]);
		g_SupplyBox_Origin[g_SupplyBox_Total][1] = str_to_float(sOrigin[1]);
		g_SupplyBox_Origin[g_SupplyBox_Total][2] = str_to_float(sOrigin[2]);
		g_SupplyBox_Angles[g_SupplyBox_Total][0] = str_to_float(sAngles[0]);
		g_SupplyBox_Angles[g_SupplyBox_Total][1] = str_to_float(sAngles[1]);
		g_SupplyBox_Angles[g_SupplyBox_Total][2] = str_to_float(sAngles[2]);
		++g_SupplyBox_Total;
	}

	fclose(iFile);
}

entitySetAim(const iEnt, const Float:vecEntOrigin[3], const Float:vecTargetOrigin[3], const Float:fVelocity=0.0, const iAngleMode=0) {
	new Float:vC[3];
	new Float:vD[3];

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

public showSupplyBox() {
	g_SupplyBox_ShowTotal = 0;

	new iListRandomRewards[6] = {0, 1, 2, 3, 4, 5};
	new iTempReward1;
	new iRandomNumber1;
	new iRandomNumber2;
	new i;

	for(i = 0; i < 20; ++i) {
		iRandomNumber1 = random_num(0, 5);
		iRandomNumber2 = random_num(0, 5);

		iTempReward1 = iListRandomRewards[iRandomNumber1];

		iListRandomRewards[iRandomNumber1] = iListRandomRewards[iRandomNumber2];
		iListRandomRewards[iRandomNumber2] = iTempReward1;
	}

	for(i = 0; i < g_SupplyBox_Total; ++i) {
		loadSupplybox(g_SupplyBox_Origin[i], g_SupplyBox_Angles[i], iListRandomRewards[i]);
	}
}

public loadSupplybox(Float:vecOrigin[3], Float:vecAngles[3], const supplybox_i) {
	g_SupplyBox_Ent[g_SupplyBox_ShowTotal] = create_entity("info_target");

	if(is_valid_ent(g_SupplyBox_Ent[g_SupplyBox_ShowTotal])) {
		entity_set_string(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_SZ_classname, __ENT_CLASSNAME_SUPPLYBOX);
		dllfunc(DLLFunc_Spawn, g_SupplyBox_Ent[g_SupplyBox_ShowTotal]);

		g_SupplyBox_Origin[g_SupplyBox_ShowTotal][0] = vecOrigin[0];
		g_SupplyBox_Origin[g_SupplyBox_ShowTotal][1] = vecOrigin[1];
		g_SupplyBox_Origin[g_SupplyBox_ShowTotal][2] = (vecOrigin[2] + 32.0);

		entity_set_model(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], __MODEL_SUPPLYBOX);
		entity_set_origin(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], g_SupplyBox_Origin[g_SupplyBox_ShowTotal]);
		entity_set_vector(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_VEC_angles, vecAngles);

		entity_set_size(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], Float:{-2.0, -2.0, -2.0}, Float:{5.0, 5.0, 5.0});

		entity_set_int(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_INT_solid, SOLID_TRIGGER);
		entity_set_int(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_INT_movetype, MOVETYPE_TOSS);

		drop_to_floor(g_SupplyBox_Ent[g_SupplyBox_ShowTotal]);

		entity_set_int(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_INT_iuser1, g_SupplyBox[g_SupplyBox_ShowTotal]);
		entity_set_int(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_INT_iuser2, supplybox_i);

		entity_set_int(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_INT_sequence, 0);
		entity_set_float(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_FL_animtime, get_gametime());
		entity_set_float(g_SupplyBox_Ent[g_SupplyBox_ShowTotal], EV_FL_framerate, 1.0);
	}

	++g_SupplyBox_ShowTotal;
}

public touch__Supplybox(const box, const id) {
	if(!is_valid_ent(box) || !g_IsAlive[id] || g_Zombie[id] || g_SpecialMode[id] || g_AccountId[id] == 1) {
		return PLUGIN_CONTINUE;
	}

	switch(entity_get_int(box, EV_INT_iuser2)) {
		case 0: {
			clientPrintColor(id, _, "La caja tenía el arma !gBalrog I!y");
			
			dropWeapons(id, 2);
			zp_weapon_balrog1(id);
		} case 1: {
			clientPrintColor(id, _, "La caja tenía el arma !gBalrog XI!y");
			
			dropWeapons(id, 1);
			zp_weapon_balrog11(id);
		} case 2: {
			clientPrintColor(id, _, "La caja tenía el arma !gPlasmaGun!y");

			dropWeapons(id, 1);
			zp_weapon_plasmagun(id);
		} case 3: {
			clientPrintColor(id, _, "La caja tenía el arma !gSkull-4!y");

			dropWeapons(id, 1);
			zp_weapon_skull4(id);
		} case 4: {
			clientPrintColor(id, _, "La caja tenía el arma !gThunderbolt!y");

			dropWeapons(id, 1);
			zp_weapon_thunderbolt(id);
		} case 5: {
			clientPrintColor(id, _, "Oops, la caja tenía pedazos de restos de !gKyo!y :v");
		}
	}

	new iUsersPlaying = getUsersPlaying();

	if(iUsersPlaying >= 8) {
		++g_Stats[id][STAT_SUPPLYBOX_DONE];

		if(iUsersPlaying >= 16) {
			++g_StatsRound_SupplyBoxDone[id];
		}
	}

	checkAchievementOfSupplyBoxes(id);

	emitSound(box, CHAN_VOICE, __SOUND_AMMOPICKUP);

	remove_entity(box);
	return PLUGIN_CONTINUE;
}

public checkAchievementOfSupplyBoxes(const id) {
	if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 1) {
		setAchievement(id, SUPPLY_BOX_X1);

		if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 10) {
			setAchievement(id, SUPPLY_BOX_X10);

			if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 50) {
				setAchievement(id, SUPPLY_BOX_X50);

				if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 100) {
					setAchievement(id, SUPPLY_BOX_X100);

					if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 500) {
						setAchievement(id, SUPPLY_BOX_X500);

						if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 1000) {
							setAchievement(id, SUPPLY_BOX_X1000);
							setAchievement(id, FIRST_SUPPLY_BOX_X1000, 1);
							
							if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 1500) {
								setAchievement(id, SUPPLY_BOX_X1500);
									
								if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 2000) {
									setAchievement(id, SUPPLY_BOX_X2000);
									
									if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 2500) {
										setAchievement(id, SUPPLY_BOX_X2500);
									
										if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 3000) {
											setAchievement(id, SUPPLY_BOX_X3000);
									
											if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 3500) {
												setAchievement(id, SUPPLY_BOX_X3500);
									
												if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 4000) {
													setAchievement(id, SUPPLY_BOX_X4000);
									
													if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 4500) {
														setAchievement(id, SUPPLY_BOX_X4500);
									
														if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 5000) {
															setAchievement(id, SUPPLY_BOX_X5000);
									
															if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 6000) {
																setAchievement(id, SUPPLY_BOX_X6000);
									
																if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 7000) {
																	setAchievement(id, SUPPLY_BOX_X7000);
									
																	if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 8000) {
																		setAchievement(id, SUPPLY_BOX_X8000);
									
																		if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 9000) {
																			setAchievement(id, SUPPLY_BOX_X9000);
									
																			if(g_Stats[id][STAT_SUPPLYBOX_DONE] >= 10000) {
																				setAchievement(id, SUPPLY_BOX_X10000);
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
						}
					}
				}
			}
		}
	}

	if(g_StatsRound_SupplyBoxDone[id] >= 2) {
		setAchievement(id, SUPPLY_BOX_X2_SAME_ROUND);

		if(g_StatsRound_SupplyBoxDone[id] >= 3) {
			setAchievement(id, SUPPLY_BOX_X3_SAME_ROUND);

			if(g_StatsRound_SupplyBoxDone[id] >= 4) {
				setAchievement(id, SUPPLY_BOX_X4_SAME_ROUND);

				if(g_StatsRound_SupplyBoxDone[id] >= 5) {
					setAchievement(id, SUPPLY_BOX_X5_SAME_ROUND);
					setAchievement(id, FIRST_SUPPLY_BOX_X5_SAME_ROUND, 1);
				}
			}
		}
	}
}

public showMenu__Group(const id) {
	oldmenu_create("\yGRUPO^n\wMáximo por grupo\r:\y 3", "menu__Group");
	
	new i;
	for(i = 1; i < 4; ++i) {
		if(g_InGroup[id] && g_GroupId[g_InGroup[id]][i]) {
			oldmenu_additem(i, i, "\r%d.\w %s \y(N: %d)", i, g_PlayerName[g_GroupId[g_InGroup[id]][i]], g_Level[g_GroupId[g_InGroup[id]][i]]);
		} else {
			oldmenu_additem(i, i, "\dHueco libre . . .");
		}
	}
	
	oldmenu_additem(4, 4, "^n\r4.\w Invitar jugadores");
	oldmenu_additem(5, 5, "\r5.\w Invitación a otros grupos\r:\y %d^n", g_GroupInvitations[id]);

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
		}
		case 4: {			
			if((g_MyGroup[id] && groupFindSlot(g_InGroup[id])) || !g_InGroup[id]) {
				showMenu__GroupInvite(id);
			} else {
				showMenu__Group(id);
			}
		}
		case 5: {
			if(!g_GroupInvitations[id] || g_InGroup[id]) {
				showMenu__Group(id);
			} else {
				showMenu__GroupInvitations(id);
			}
		}
	}
}

public showMenu__GroupInfo(const id, const user) {
	g_MenuData[id][MENU_DATA_GROUP_MEMBER_ID] = user;
	
	if(g_GroupId[g_InGroup[id]][user] != id) {
		oldmenu_create("\yGRUPO", "menu__GroupInfo");

		oldmenu_additem(-1, -1, "\r¿\w Deseas expulsar a \y%s\w de tu grupo \r?\w", g_PlayerName[g_GroupId[g_InGroup[id]][user]]);
		oldmenu_additem(1, 1, "\r1.\w Si");
		oldmenu_additem(2, 2, "\r2.\w No^n");

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	} else {
		oldmenu_create("\yGRUPO", "menu__GroupInfo");

		oldmenu_additem(-1, -1, "\r¿\wDeseas salir de este grupo\r?\w");
		oldmenu_additem(1, 1, "\r1.\w Si");
		oldmenu_additem(2, 2, "\r2.\w No^n");

		oldmenu_additem(0, 0, "\r0.\w Volver");
		oldmenu_display(id);
	}
}

public menu__GroupInfo(const id, const item) {
	if(!item) {
		showMenu__Group(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_InGroup[id]) {
				checkGroupIn(id, g_MenuData[id][MENU_DATA_GROUP_MEMBER_ID], g_GroupId[g_InGroup[id]][g_MenuData[id][MENU_DATA_GROUP_MEMBER_ID]]);
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
	new sPosition[2];
	
	iMenuId = menu_create("INVITAR JUGADORES\R", "menu__GroupInvite");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || !g_AccountLogged[i] || id == i || g_InGroup[i] || g_GroupInvitationsId[i][id]) {
			continue;
		}
		
		formatex(sItem, charsmax(sItem), "%s \y(N: %d)", g_PlayerName[i], g_Level[i]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1) {
		clientPrintColor(id, _, "No hay jugadores disponibles para mostrar en el menú");
		
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

public menu__GroupInvite(const id, const menuid, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menuid);
		return PLUGIN_HANDLED;
	}
	
	new iUser;
	player_menu_info(id, iUser, iUser, g_MenuPage[id][MENU_PAGE_GROUP_INVITE]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuid);
		
		showMenu__Group(id);
		return PLUGIN_HANDLED;
	}
	
	static sPosition[2];
	menu_item_getinfo(menuid, item, iUser, sPosition, charsmax(sPosition), _, _, iUser);
	DestroyLocalMenu(id, menuid);
	
	iUser = sPosition[0];
	
	if(g_IsConnected[iUser]) {
		if(!g_InGroup[iUser]) {
			clientPrintColor(id, _, "Enviaste una invitación a !t%s!y para que se una a tu grupo", g_PlayerName[iUser]);
			clientPrintColor(iUser, _, "El jugador !t%s!y te invitó a su grupo", g_PlayerName[id]);
			
			++g_GroupInvitations[iUser];
			g_GroupInvitationsId[iUser][id] = 1;
		} else {
			clientPrintColor(id, _, "El jugador seleccionado acaba de entrar en un grupo");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado");
	}
	
	showMenu__GroupInvite(id);
	return PLUGIN_HANDLED;
}

public showMenu__GroupInvitations(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("INVITACIONES A OTROS GRUPOS\R", "menu__GroupInvitations");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || !g_AccountLogged[i] || !g_GroupInvitationsId[id][i]) {
			continue;
		}
		
		formatex(sItem, charsmax(sItem), "%s \y(N: %d)", g_PlayerName[i], g_Level[i]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1) {
		clientPrintColor(id, _, "No hay solicitudes disponibles para mostrar en el menú");
		
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

public menu__GroupInvitations(const id, const menuid, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menuid);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuid);
		
		showMenu__Group(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	new iUser;
	
	menu_item_getinfo(menuid, item, iUser, sPosition, charsmax(sPosition), _, _, iUser);
	DestroyLocalMenu(id, menuid);
	
	iUser = sPosition[0];
	
	if(g_IsConnected[iUser]) {
		if(g_GroupInvitationsId[id][iUser]) {
			new iSlot;
			new i;
			
			if(!g_InGroup[iUser]) { // Está en grupo el que te invitó? Si no es así, crear un grupo!
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
			
			iSlot = groupFindSlot(g_InGroup[iUser]); // Buscar un slot para el usuario que está intentando entrar
			
			if(iSlot) {
				g_InGroup[id] = g_InGroup[iUser];
				g_GroupId[g_InGroup[iUser]][iSlot] = id;
				
				for(i = 1; i < 4; ++i) {
					if(g_GroupId[g_InGroup[iUser]][i]) {
						clientPrintColor(g_GroupId[g_InGroup[iUser]][i], _, "!t%s!y se unió a tu grupo", g_PlayerName[id]);
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
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado");
	}
	
	if(g_GroupInvitations[id] && !g_InGroup[id]) {
		showMenu__GroupInvitations(id);
	}
	
	return PLUGIN_HANDLED;
}

public checkGroupOnDisconnected(const id) {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_GroupInvitationsId[i][id]) {
			--g_GroupInvitations[i];
		}
		
		g_GroupInvitationsId[i][id] = 0;
	}
	
	if(g_InGroup[id]) {
		for(i = 1; i < 4; ++i) {
			if(g_GroupId[g_InGroup[id]][i] == id) {
				break;
			}
		}
		
		checkGroupIn(id, i, id);
	}
}

public checkGroupIn(const id, const user, const leave_id) {
	new i = g_InGroup[id];
	new j;
	new k = 0;
	
	if(id == leave_id) { // LA PERSONA SALIO DEL GRUPO POR SU CUENTA
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[i][j]) {
				clientPrintColor(g_GroupId[i][j], _, "!t%s!y se ha ido del grupo", g_PlayerName[leave_id]);
				++k;
			}
		}
	} else { // LO EXPULSARON
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[i][j]) {
				clientPrintColor(g_GroupId[i][j], _, "!t%s!y ha sido expulsado del grupo", g_PlayerName[leave_id]);
				++k;
			}
		}
	}
	
	g_InGroup[leave_id] = 0;
	g_GroupId[i][user] = 0;
	
	if(k < 3) { // Si el grupo solo tenía 2 personas en total, disolver grupo!
		for(j = 1; j < 4; ++j) {
			if(g_GroupId[i][j]) {
				clientPrintColor(g_GroupId[i][j], _, "Tu grupo se ha disuelto");
				
				g_InGroup[g_GroupId[i][j]] = 0;
				g_MyGroup[g_GroupId[i][j]] = 0;
				g_GroupId[i][j] = 0;
			}
		}
		
		g_GroupId[i][0] = 0; // Liberar id del grupo
	} else if(g_MyGroup[leave_id]) { // El que se fue era el dueño del grupo, darselo a otro!
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

groupFindId() {
	new i;
	for(i = 1; i < 14; ++i) {
		if(!g_GroupId[i][0]) {
			return i;
		}
	}
	
	return 0;
}

groupFindSlot(const group) {
	new i;
	for(i = 1; i < 4; ++i) {
		if(!g_GroupId[group][i]) {
			return i;
		}
	}
	
	return 0;
}

public message__StatusIcon(const msg_id, const msg_dest, const id) {
	new sIcon[8];
	get_msg_arg_string(2, sIcon, charsmax(sIcon));
	
	if(equal(sIcon, "buyzone") && get_msg_arg_int(1)) {
		if(pev_valid(id) != PDATA_SAFE) {
			return PLUGIN_CONTINUE;
		}

		set_pdata_int(id, OFFSET_BUYZONE, get_pdata_int(id, OFFSET_BUYZONE) & ~(1<<0));
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public ham__TouchZoneEscapePost(const zone, const id) {
	if(!is_valid_ent(zone) || !isUserValidAlive(id)) {
		return HAM_IGNORED;
	}

	static sTargetName[12];
	entity_get_string(zone, EV_SZ_targetname, sTargetName, charsmax(sTargetName));

	if(equali(sTargetName, "")) {
		if(getUsersPlaying() < 4 || g_Escaped[id]) {
			return HAM_SUPERCEDE;
		}

		g_Escaped[id] = 1;

		++g_Stats[id][STAT_ESCAPES_DONE];

		if(g_Stats[id][STAT_ESCAPES_DONE] >= 25) {
			setAchievement(id, x25_ESCAPES);

			if(g_Stats[id][STAT_ESCAPES_DONE] >= 50) {
				setAchievement(id, x50_ESCAPES);

				if(g_Stats[id][STAT_ESCAPES_DONE] >= 100) {
					setAchievement(id, x100_ESCAPES);

					if(g_Stats[id][STAT_ESCAPES_DONE] >= 250) {
						setAchievement(id, x250_ESCAPES);

						if(g_Stats[id][STAT_ESCAPES_DONE] >= 500) {
							setAchievement(id, x500_ESCAPES);

							if(g_Stats[id][STAT_ESCAPES_DONE] >= 750) {
								setAchievement(id, x750_ESCAPES);

								if(g_Stats[id][STAT_ESCAPES_DONE] >= 1000) {
									setAchievement(id, x1000_ESCAPES);
									setAchievement(id, PRIMERO_x1000_ESCAPES, 1);

									if(g_Stats[id][STAT_ESCAPES_DONE] >= 2500) {
										setAchievement(id, x2500_ESCAPES);

										if(g_Stats[id][STAT_ESCAPES_DONE] >= 5000) {
											setAchievement(id, x5000_ESCAPES);

											if(g_Stats[id][STAT_ESCAPES_DONE] >= 7500) {
												setAchievement(id, x7500_ESCAPES);

												if(g_Stats[id][STAT_ESCAPES_DONE] >= 10000) {
													setAchievement(id, x10000_ESCAPES);

													if(g_Stats[id][STAT_ESCAPES_DONE] >= 15000) {
														setAchievement(id, x15000_ESCAPES);

														if(g_Stats[id][STAT_ESCAPES_DONE] >= 20000) {
															setAchievement(id, x20000_ESCAPES);

															if(g_Stats[id][STAT_ESCAPES_DONE] >= 25000) {
																setAchievement(id, x25000_ESCAPES);
																setAchievement(id, PRIMERO_x25000_ESCAPES, 1);

																if(g_Stats[id][STAT_ESCAPES_DONE] >= 35000) {
																	setAchievement(id, x35000_ESCAPES);

																	if(g_Stats[id][STAT_ESCAPES_DONE] >= 45000) {
																		setAchievement(id, x45000_ESCAPES);

																		if(g_Stats[id][STAT_ESCAPES_DONE] >= 55000) {
																			setAchievement(id, x55000_ESCAPES);

																			if(g_Stats[id][STAT_ESCAPES_DONE] >= 75000) {
																				setAchievement(id, x75000_ESCAPES);
																				
																				if(g_Stats[id][STAT_ESCAPES_DONE] >= 85000) {
																					setAchievement(id, x85000_ESCAPES);
																					
																					if(g_Stats[id][STAT_ESCAPES_DONE] >= 100000) {
																						setAchievement(id, x100000_ESCAPES);
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
								}
							}
						}
					}
				}
			}
		}

		g_MapEscaped = 1;

		static iRewardAPs;
		static iRewardXP;
		static iRewardPoints;

		if((get_user_flags(id) & ADMIN_RESERVATION)) {
			iRewardAPs =  __HAPPY_HOUR[g_HappyHour][hhAPsRewardEscape_Vip];
			iRewardXP = __HAPPY_HOUR[g_HappyHour][hhXPRewardEscape_Vip];
			iRewardPoints = __HAPPY_HOUR[g_HappyHour][hhPLRewardEscape_Vip];
		} else {
			iRewardAPs =  __HAPPY_HOUR[g_HappyHour][hhAPsRewardEscape_Normal];
			iRewardXP = __HAPPY_HOUR[g_HappyHour][hhXPRewardEscape_Normal];
			iRewardPoints = __HAPPY_HOUR[g_HappyHour][hhPLRewardEscape_Normal];
		}

		if(g_InGroup[id]) {
			static i;
			for(i = 1; i < 4; ++i) {
				if(g_GroupId[g_InGroup[id]][i] && g_IsAlive[g_GroupId[g_InGroup[id]][i]] && !g_Zombie[g_GroupId[g_InGroup[id]][i]] && !g_Escaped[g_GroupId[g_InGroup[id]][i]]) {
					iRewardXP += 10;
				}
			}
		}

		g_APs[id] += iRewardAPs;
		giveXP(id, iRewardXP);
		g_Points[id] += iRewardPoints;

		clientPrintColor(id, _, "Has pasado la zona segura y has ganado !g%d APs!y - !g%d XP!y - !g%d pL!y!", iRewardAPs, iRewardXP, iRewardPoints);
		
		if(g_Mode == MODE_JERUZALEM) {
			modeJeruzalemFinish(TEAM_CT);
		}
	}

	return HAM_IGNORED;
}

public touch__TriggerHurt(const ent, const id) {
	if(g_NewRound) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public clcmd__DrunkAtNite(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	new iDate[3];
	new iUnix24;
	new iUnixDif;
	new iSysTime = get_arg_systime();
	new iYear;
	new iMonth;
	new iDay;
	new iHour;
	new iMinute;
	new iSecond;
	new sHour[16];
	new sMinute[16];
	new sSecond[16];

	date(iDate[0], iDate[1], iDate[2]);

	if(g_HappyHour) {
		iUnix24 = time_to_unix(iDate[0], iDate[1], iDate[2], 09, 59, 00);
		iUnixDif = (iUnix24 - iSysTime);

		unix_to_time(iUnixDif, iYear, iMonth, iDay, iHour, iMinute, iSecond);

		formatex(sHour, charsmax(sHour), " !g%02d!y hora%s,", iHour, ((iHour == 1) ? "" : "s"));
		formatex(sMinute, charsmax(sMinute), " !g%02d!y minuto%s", iMinute, ((iMinute == 1) ? "" : "s"));
		formatex(sSecond, charsmax(sSecond), " !g%02d!y segundo%s", iSecond, ((iSecond == 1) ? "" : "s"));
		
		clientPrintColor(id, _, "Faltan%s%s%s para que acabe !gDRUNK AT NITE!y", ((iHour < 1) ? "" : sHour), ((iMinute < 1) ? "" : sMinute), ((iSecond < 1) ? "" : sSecond));
	} else {
		iUnix24 = time_to_unix(iDate[0], iDate[1], iDate[2], 22, 00, 00);
		iUnixDif = (iUnix24 - iSysTime);

		unix_to_time(iUnixDif, iYear, iMonth, iDay, iHour, iMinute, iSecond);

		formatex(sHour, charsmax(sHour), " !g%02d!y hora%s,", iHour, ((iHour == 1) ? "" : "s"));
		formatex(sMinute, charsmax(sMinute), " !g%02d!y minuto%s", iMinute, ((iMinute == 1) ? "" : "s"));
		formatex(sSecond, charsmax(sSecond), " !g%02d!y segundo%s", iSecond, ((iSecond == 1) ? "" : "s"));

		clientPrintColor(id, _, "Faltan%s%s%s para que sea !gDRUNK AT NITE!y", ((iHour < 1) ? "" : sHour), ((iMinute < 1) ? "" : sMinute), ((iSecond < 1) ? "" : sSecond));
	}

	return PLUGIN_HANDLED;
}

public checkHumanPowers(const id) {
	if(!g_Zombie[id] && !g_SpecialMode[id]) {
		switch(g_HumanClass[id]) {
			case HUMAN_CLASS_MEDICO: {
				clientPrintColor(id, _, "Recuerda que con la !gTecla F!y puedes curar humanos aliados en un radio cercano");

				g_HumanClass_Medico[id] = 1;
				g_HumanClass_MedicoActive[id] = 0;
			}
		}
	}
}

public checkZombiePowers(const id) {
	if(g_Zombie[id] && !g_SpecialMode[id]) {
		if(!__ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassPowerOn]) {
			clientPrintColor(id, _, "El poder del !gZombie %s!y está deshabilitado temporalmente", __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);
			return;
		}

		switch(g_ZombieClass[id]) {
			case ZOMBIE_CLASS_VOODOO: {
				clientPrintColor(id, _, "Recuerda que !gapretando la Tecla F!y curas a tus compañeros zombies");

				g_ZombieClass_Voodoo[id] = 1;
			} case ZOMBIE_CLASS_LUSTY_ROSE: {
				clientPrintColor(id, _, "Recuerda que !gapretando la Tecla F!y te haces invisible");

				g_ZombieClass_LustyRose[id] = 1;
			} case ZOMBIE_CLASS_BANSHEE: {
				clientPrintColor(id, _, "Recuerda que !gapretando la Tecla F!y lanzas murcielagos");

				g_ZombieClass_Banshee[id] = 1;
				g_ZombieClass_BansheeActive[id] = 0;
				g_ZombieClass_BansheeStat[id] = 0;
				g_ZombieClass_BansheeOwner[id] = 0;
			} case ZOMBIE_CLASS_FARAHON: {
				clientPrintColor(id, _, "Recuerda que !gapretando la Tecla R!y lanzas bolas de fuego");

				g_ZombieClass_FarahonLastTime[id] = get_gametime();
			} case ZOMBIE_CLASS_FLESHPOUND: {
				clientPrintColor(id, _, "Recuerda que !gapretando la Tecla F!y puedes activar tu furia");

				g_ZombieClass_Fleshpound[id] = 1;
				g_ZombieClass_FleshpoundActive[id] = 0;
			} case ZOMBIE_CLASS_TOXICO: {
				clientPrintColor(id, _, "Recuerda que !gapretando la Tecla F!y puedes lanzar ácido");

				g_ZombieClass_ToxicoLastTime[id] = get_gametime();
			}
		}
	}
}

public impulse__Flashlight(const id) {
	if(g_IsAlive[id] && !g_SpecialMode[id]) {
		if(g_Zombie[id]) {
			if(!__ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassPowerOn]) {
				clientPrintColor(id, _, "El poder del !gZombie %s!y está deshabilitado temporalmente", __ZOMBIE_CLASSES[g_ZombieClass[id]][zombieClassName]);
				return PLUGIN_HANDLED;
			}

			switch(g_ZombieClass[id]) {
				case ZOMBIE_CLASS_VOODOO: {
					if(!g_ZombieClass_Voodoo[id]) {
						clientPrintColor(id, _, "Debes esperar !g15 segundos!y para volver a utilizar tu poder");
						return PLUGIN_HANDLED;
					}

					new Float:vecOrigin[3];
					new iVictim = -1;
					new iCountVictims = 0;
					new Float:vecOriginVictim[3];
					new iExtraHealth = 0;

					entity_get_vector(id, EV_VEC_origin, vecOrigin);

					while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 200.0)) != 0) {
						if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim]) {
							continue;
						}

						iExtraHealth = (g_Health[id] + 1500);

						if(iExtraHealth < g_MaxHealth[iVictim]) {
							set_user_health(iVictim, iExtraHealth);
							g_Health[iVictim] = get_user_health(iVictim);
						}

						if(iVictim != id) {
							++iCountVictims;

							entity_get_vector(iVictim, EV_VEC_origin, vecOriginVictim);

							engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOriginVictim, 0);
							write_byte(TE_SPRITE);
							engfunc(EngFunc_WriteCoord, vecOriginVictim[0]);
							engfunc(EngFunc_WriteCoord, vecOriginVictim[1]);
							engfunc(EngFunc_WriteCoord, (vecOriginVictim[2] + 20.0));
							write_short(g_Sprite_Health);
							write_byte(0);
							write_byte(200);
							message_end();
						}
					}

					if(iCountVictims) {
						createExplosion(vecOrigin, 0, 50, 0, 200.0);
					}

					g_ZombieClass_Voodoo[id] = 0;

					remove_task(id + TASK_ZOMBIE_VOODOO);
					set_task(15.0, "task__ZombieVoodoo", id + TASK_ZOMBIE_VOODOO);
				} case ZOMBIE_CLASS_LUSTY_ROSE: {
					if(!g_ZombieClass_LustyRose[id]) {
						clientPrintColor(id, _, "Debes esperar !g15 segundos!y para volver a utilizar tu poder");
						return PLUGIN_HANDLED;
					} else if(g_ZombieClass_LustyRoseActive[id]) {
						clientPrintColor(id, _, "Debes esperar a que termine tu invisibilidad, luego espera !g15 segundos!y para volver a utilizar tu poder");
						return PLUGIN_HANDLED;
					}

					emitSound(id, CHAN_BODY, __SOUND_ZOMBIE_LUSTYROSA_ACTIVE);

					set_user_rendering(id, kRenderFxGlowShell, 20, 20, 20, kRenderTransAlpha, 5);
					set_user_footsteps(id, 1);

					g_ZombieClass_LustyRose[id] = 0;
					g_ZombieClass_LustyRoseActive[id] = 2;

					replaceWeaponModels(id, CSW_KNIFE);

					set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, 11.0, 0.1, 0.1, 4);
					ShowSyncHudMsg(id, g_HudSync_ZombiePower, "[Estás invisible]");

					remove_task(id + TASK_ZOMBIE_LUSTY_ROSE);
					set_task(15.0, "task__ZombieLustyRose", id + TASK_ZOMBIE_LUSTY_ROSE);
				} case ZOMBIE_CLASS_BANSHEE: {
					if(!g_ZombieClass_Banshee[id]) {
						clientPrintColor(id, _, "No puedes utilizar el poder en este momento");
						return PLUGIN_HANDLED;
					} else if(g_ZombieClass_BansheeActive[id]) {
						clientPrintColor(id, _, "Ya has utilizado el poder");
						return PLUGIN_HANDLED;
					}

					new iEnt = create_entity("info_target");

					if(is_valid_ent(iEnt)) {
						new Float:vecOrigin[3];
						new Float:vecAngle[3];
						new Float:vecForward[3];
						new Float:vecRight[3];
						new Float:vecUp[3];
						new Float:vecVelocity[3];

						entity_get_vector(id, EV_VEC_origin, vecOrigin);
						entity_get_vector(id, EV_VEC_v_angle, vecAngle);

						engfunc(EngFunc_MakeVectors, vecAngle);

						global_get(glb_v_forward, vecForward);
						global_get(glb_v_right, vecRight);
						global_get(glb_v_up, vecUp);

						vecOrigin[0] = (vecOrigin[0] + (vecForward[0] * 5.0) + (vecRight[0] * 2.0) + (vecUp[0] * -1.0));
						vecOrigin[1] = (vecOrigin[1] + (vecForward[1] * 5.0) + (vecRight[1] * 2.0) + (vecUp[1] * -1.0));
						vecOrigin[2] = (vecOrigin[2] + (vecForward[2] * 5.0) + (vecRight[2] * 2.0) + (vecUp[2] * -1.0));
						
						entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
						entity_set_vector(iEnt, EV_VEC_angles, vecAngle);

						velocity_by_aim(id, 600, vecVelocity);
						entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

						entity_set_model(iEnt, __MODEL_BANSHEE);
						entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_BANSHEE);
						entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
						entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);

						set_size(iEnt, Float:{-20.0,-15.0, -8.0}, Float:{20.0, 15.0, 8.0});
						entity_set_vector(iEnt, EV_VEC_mins, Float:{-20.0,-15.0, -8.0});
						entity_set_vector(iEnt, EV_VEC_maxs, Float:{20.0, 15.0, 8.0});

						entity_set_float(iEnt, EV_FL_animtime, get_gametime());
						entity_set_float(iEnt, EV_FL_framerate, 1.0);
						entity_set_edict(iEnt, EV_ENT_owner, id);
						entity_set_float(iEnt, EV_FL_nextthink, (get_gametime() + 3.0));

						emitSound(iEnt, CHAN_WEAPON, __SOUND_ZOMBIE_BANSHEE[0]);
						
						setAnimation(id, 2);

						g_Speed[id] = 1.0;
						ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
					}

					g_ZombieClass_BansheeActive[id] = 1;
					g_ZombieClass_BansheeStat[id] = 0;
					g_ZombieClass_BansheeOwner[id] = 0;

					remove_task(id + TASK_POWER_ZOMBIE);
					set_task(30.0, "task__RemovePowerZombie", id + TASK_POWER_ZOMBIE);
				} case ZOMBIE_CLASS_FLESHPOUND: {
					if(!g_ZombieClass_Fleshpound[id]) {
						clientPrintColor(id, _, "No puedes utilizar el poder en este momento");
						return PLUGIN_HANDLED;
					} else if(g_ZombieClass_FleshpoundActive[id]) {
						clientPrintColor(id, _, "Ya has utilizado el poder, espera 20 segundos.");
						return PLUGIN_HANDLED;
					}

					g_ZombieClass_FleshpoundActive[id] = 1;

					if(g_Frozen[id]) {
						removeFrostCube(id);

						remove_task(id + TASK_FROZEN);
						task__RemoveFreeze(id + TASK_FROZEN);
					}

					clientPrint(id, print_center, "¡Has aumentado tu ira!");

					g_Speed[id] = 300.0;
					ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

					remove_task(id + TASK_ZOMBIE_FLESHPOUND);
					remove_task(id + TASK_ZOMBIE_FLESHPOUND_ACTIVE);
					remove_task(id + TASK_ZOMBIE_FLESHPOUND_AURA);

					set_task(4.0, "task__ZombieFleshpound", id + TASK_ZOMBIE_FLESHPOUND);
					set_task(20.0, "task__ZombieFleshpoundActive", id + TASK_ZOMBIE_FLESHPOUND_ACTIVE);
					set_task(0.1, "task__ZombieFleshpoundAura", id + TASK_ZOMBIE_FLESHPOUND_AURA, .flags="b");
				} case ZOMBIE_CLASS_TOXICO: {
					new Float:flGameTime = get_gametime();

					if((flGameTime - g_ZombieClass_ToxicoLastTime[id]) < 25.0) {
						new Float:flRest = (25.0 - (flGameTime - g_ZombieClass_ToxicoLastTime[id]));
						new iRest = floatround(flRest);

						clientPrintColor(id, _, "Debes esperar !g%s!y para volver a utilizar tu poder", getCooldDownTime(iRest));
						return PLUGIN_HANDLED;
					}

					g_ZombieClass_ToxicoLastTime[id] = flGameTime;

					new iEnt = create_entity("info_target");

					if(is_valid_ent(iEnt)) {
						new Float:vecOrigin[3];
						new Float:vecVAngle[3];
						new Float:vecVelocity[3];

						entity_get_vector(id, EV_VEC_origin, vecOrigin);
						entity_get_vector(id, EV_VEC_v_angle, vecVAngle);
						
						entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_TOXICO);
						entity_set_model(iEnt, __MODEL_SPIT);
						entity_set_size(iEnt, Float:{-1.5, -1.5, -1.5}, Float:{1.5, 1.5, 1.5});
						entity_set_origin(iEnt, vecOrigin);
						entity_set_vector(iEnt, EV_VEC_angles, vecVAngle);
						entity_set_int(iEnt, EV_INT_solid, 2);
						entity_set_int(iEnt, EV_INT_rendermode, 5);
						entity_set_float(iEnt, EV_FL_renderamt, 200.0);
						entity_set_float(iEnt, EV_FL_scale, 1.00);
						entity_set_int(iEnt, EV_INT_movetype, 5);
						entity_set_edict(iEnt, EV_ENT_owner, id);
						velocity_by_aim(id, 700, vecVelocity);
						entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

						message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
						write_byte(TE_BEAMFOLLOW);
						write_short(iEnt);
						write_short(g_Sprite_Laserbeam);
						write_byte(10);
						write_byte(10);
						write_byte(0);
						write_byte(250);
						write_byte(0);
						write_byte(200);
						message_end();

						emitSound(id, CHAN_STREAM, __SOUND_ZOMBIE_TOXIC[1]);

						new iDamage = 250;
						new iTotalHealth = (g_Health[id] - iDamage);

						if(iTotalHealth > 0) {
							fakedamage(id, "Spit acid", float(iDamage), 256);

							new vecOrigin[3];
							get_user_origin(id, vecOrigin);
							bubbleBreak(id, vecOrigin);
						}
					}
				}
			}
		} else {
			switch(g_HumanClass[id]) {
				case HUMAN_CLASS_MEDICO: {
					if(!g_HumanClass_Medico[id]) {
						clientPrintColor(id, _, "No puedes utilizar el poder en este momento");
						return PLUGIN_HANDLED;
					} else if(g_HumanClass_MedicoActive[id]) {
						clientPrintColor(id, _, "Ya has utilizado el poder");
						return PLUGIN_HANDLED;
					}

					new Float:vecOrigin[3];
					new iVictim = -1;
					new iCountVictims = 0;

					entity_get_vector(id, EV_VEC_origin, vecOrigin);
					createExplosion(vecOrigin, 100, 100, 100, 150.0);

					while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 150.0)) != 0) {
						if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim]) {
							continue;
						}

						set_user_health(iVictim, (g_Health[iVictim] + 35));
						g_Health[iVictim] = get_user_health(iVictim);

						if(iVictim != id) {
							++iCountVictims;
						}
					}

					g_HumanClass_MedicoActive[id] = 1;

					if(iCountVictims) {
						clientPrint(id, print_center, "¡Has curado a %d humano%s aliado%s!", iCountVictims, ((iCountVictims != 1) ? "s" : ""), ((iCountVictims != 1) ? "s" : ""));
					}

					remove_task(id + TASK_HUMAN_MEDICO_ACTIVE);
					set_task(30.0, "task__HumanMedicoActive", id + TASK_HUMAN_MEDICO_ACTIVE);
				}
			}
		}
	}

	return PLUGIN_HANDLED;
}

public task__ZombieVoodoo(const task_id) {
	new iId = (task_id - TASK_ZOMBIE_VOODOO);

	if(!g_IsAlive[iId]) {
		return;
	}

	clientPrintColor(iId, _, "Puedes volver a utilizar tu habilidad");

	g_ZombieClass_Voodoo[iId] = 1;
}

public task__ZombieLustyRose(const task_id) {
	new iId = (task_id - TASK_ZOMBIE_LUSTY_ROSE);

	if(!g_IsAlive[iId]) {
		return;
	}

	g_ZombieClass_LustyRose[iId] = 1;
	g_ZombieClass_LustyRoseActive[iId] = 1;

	emitSound(iId, CHAN_BODY, __SOUND_ZOMBIE_LUSTYROSA_ACTIVE);

	set_user_rendering(iId);
	set_user_footsteps(iId, 0);

	replaceWeaponModels(iId, CSW_KNIFE);

	remove_task(iId + TASK_ZOMBIE_LUSTY_ROSE_WAIT);
	set_task(10.0, "task__ZombieLustyRoseWait", iId + TASK_ZOMBIE_LUSTY_ROSE_WAIT);

	ClearSyncHud(iId, g_HudSync_ZombiePower);
}

public task__ZombieLustyRoseWait(const task_id) {
	new iId = (task_id - TASK_ZOMBIE_LUSTY_ROSE_WAIT);

	if(!g_IsAlive[iId]) {
		return;
	}

	clientPrintColor(iId, _, "Puedes volver a utilizar tu habilidad");

	replaceWeaponModels(iId, CSW_KNIFE);

	g_ZombieClass_LustyRoseActive[iId] = 0;
}

public task__ZombieFleshpound(const task_id) {
	new iId = (task_id - TASK_ZOMBIE_FLESHPOUND);

	if(!g_IsConnected[iId]) {
		remove_task(task_id);
		return;
	}

	clientPrint(iId, print_center, "¡Has normalizado tu ira!");

	g_Speed[iId] = Float:zombieSpeed(iId, g_ZombieClass[iId]);
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iId);

	remove_task(iId + TASK_ZOMBIE_FLESHPOUND_AURA);
}

public task__ZombieFleshpoundActive(const task_id) {
	new iId = (task_id - TASK_ZOMBIE_FLESHPOUND_ACTIVE);

	if(!g_IsConnected[iId] || !g_ZombieClass_FleshpoundActive[iId]) {
		remove_task(task_id);
		return;
	}

	clientPrintColor(iId, _, "Puedes volver a utilizar tu poder");

	g_ZombieClass_FleshpoundActive[iId] = 0;
}

public task__ZombieFleshpoundAura(const task_id) {
	new iId = (task_id - TASK_ZOMBIE_FLESHPOUND_AURA);

	if(!g_IsConnected[iId]) {
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
	write_byte(13);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(1);
	write_byte(0);
	message_end();
}

public task__HumanMedicoActive(const task_id) {
	new iId = (task_id - TASK_HUMAN_MEDICO_ACTIVE);

	if(!g_IsConnected[iId] || !g_HumanClass_MedicoActive[iId]) {
		remove_task(task_id);
		return;
	}

	g_HumanClass_MedicoActive[iId] = 0;

	clientPrintColor(iId, _, "Puedes volver a utilizar tu poder");
}

public arrayToString(const array[], const size, output[], const len, const end) {
	new iLen;
	new i;

	do {
		iLen += formatex(output[iLen], (len - iLen), "%d ", array[i]);
	} while(++i < size && iLen < len);

	if(i < size) {
		return 0;
	}

	if(end) {
		output[(iLen - 1)] = '^0';
	}

	return iLen;
}

public stringToArray(const string[], array_out[], const array_size) {
	new sTemp[16];
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

public showMenu__Clan(const id) {
	oldmenu_create("\yCLAN", "menu__Clan");

	if(g_ClanSlot[id]) {
		oldmenu_additem(-1, -1, "\wNombre del clan\r:\y %s%s", g_Clan[g_ClanSlot[id]][clanName], ((g_Clan[g_ClanSlot[id]][clanChampion]) ? " \y(ACTUAL CAMPEÓN)\w" : ""));
		if(g_Clan[g_ClanSlot[id]][clanRank]) {
			oldmenu_additem(-1, -1, "\wRanking del clan\r:\y #%d", g_Clan[g_ClanSlot[id]][clanRank]);
		} else {
			oldmenu_additem(-1, -1, "\wRanking del clan\r:\y sin-definir");
		}
		oldmenu_additem(-1, -1, "\wDepósito\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanDeposit]);

		oldmenu_additem(1, 1, "\r1.\w Ver miembros conectados \y(%d / %d)", g_Clan[g_ClanSlot[id]][clanCountOnlineMembers], g_Clan[g_ClanSlot[id]][clanCountMembers]);

		if(getClanMemberRange(id)) {
			oldmenu_additem(2, 2, "\r2.\w Invitar jugadores^n");
		} else {
			oldmenu_additem(-1, -1, "\d2. Invitar jugadores^n");
		}

		oldmenu_additem(9, 9, "\r9.\w Información del Clan");
	} else {
		oldmenu_additem(1, 1, "\r1.\w Crear Clan");
		oldmenu_additem(2, 2, "\r2.\w Invitaciones a otros clanes\r:\y %d^n", g_ClanInvitations[id]);
	}

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__Clan(const id, const item) {
	if(!item) {
		showMenu__Game(id);
		return;
	}

	switch(item) {
		case 1: {
			if(g_ClanSlot[id]) {
				showMenu__ClanOnlineMembers(id);
			} else {
				clientPrintColor(id, _, "Escribe el nombre de tu clan, se aceptan hasta 14 caracteres");
				client_cmd(id, "messagemode CREAR_CLAN");
			}
		} case 2: {
			if(g_ClanSlot[id]) {
				if(getClanMemberRange(id)) {
					showMenu__ClanInvitePlayer(id);
				} else {
					clientPrintColor(id, _, "Solo los miembros con rango !gDueño!y del Clan pueden invitar jugadores");
					showMenu__Clan(id);
				}
			} else {
				showMenu__ClanInvitations(id);
			}
		} case 9: {
			if(g_ClanSlot[id]) {
				showMenu__ClanInfo(id);
			} else {
				showMenu__Clan(id);
			}
		}
	}
}

public clcmd__CreateClan(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id] || g_ClanSlot[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sClan[15];
	read_args(sClan, charsmax(sClan));
	remove_quotes(sClan);
	trim(sClan);
	
	if(getUserClanBadString(sClan)) {
		clientPrintColor(id, _, "Solo letras y algunos símbolos: !g( ) [ ] { } - = . , : !!y, se permiten espacios");

		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	new iLenClan = strlen(sClan);
	
	if(iLenClan < 3) {
		clientPrintColor(id, _, "El nombre del clan debe tener al menos 3 caracteres");
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	} else if(iLenClan > 14) {
		clientPrintColor(id, _, "El nombre del clan debe tener menos de 15 caracteres");
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	copy(g_TempClanName[id], charsmax(g_TempClanName[]), sClan);
	
	new iArgs[1];
	iArgs[0] = id;
	
	formatex(g_SqlQuery, charsmax(g_SqlQuery), "SELECT id FROM ze3_clans WHERE clan_name=^"%s^" LIMIT 1;", sClan);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__CheckClanName", g_SqlQuery, iArgs, sizeof(iArgs));
	
	return PLUGIN_HANDLED;
}

public sqlThread__CheckClanName(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];
	
	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__CheckClanName() - [%d] - <%s>", error_num, error);

		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al crear un clan. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	if(!SQL_NumResults(query)) {
		new iClanSlot = clanFindSlot();

		if(!iClanSlot) {
			showMenu__Clan(iId);
			return;
		}

		new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO ze3_clans (clan_name, clan_timestamp) VALUES (^"%s^", '%d');", g_TempClanName[iId], get_arg_systime());
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(iId, sqlQuery, 77);
		} else {
			SQL_FreeHandle(sqlQuery);

			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id FROM ze3_clans ORDER BY id DESC LIMIT 1;");

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(iId, sqlQuery, 78);
			} else {
				new iClanId = SQL_ReadResult(sqlQuery, 0);

				SQL_FreeHandle(sqlQuery);

				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO ze3_clans_members (acc_id, clan_id, since_connection, last_connection) VALUES ('%d', '%d', '%d', '%d');", g_AccountId[iId], iClanId, get_arg_systime(), get_arg_systime());

				if(!SQL_Execute(sqlQuery)) {
					executeQuery(iId, sqlQuery, 79);
				} else {
					SQL_FreeHandle(sqlQuery);

					sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE ze3_pjs SET clan_id='%d' WHERE acc_id='%d';", iClanId, g_AccountId[iId]);

					if(!SQL_Execute(sqlQuery)) {
						executeQuery(iId, sqlQuery, 80);
					} else {
						SQL_FreeHandle(sqlQuery);
					}

					g_ClanSlot[iId] = iClanSlot;

					g_Clan[g_ClanSlot[iId]][clanId] = iClanId;
					copy(g_Clan[g_ClanSlot[iId]][clanName], 31, g_TempClanName[iId]);
					g_Clan[g_ClanSlot[iId]][clanTimestamp] = get_arg_systime();
					g_Clan[g_ClanSlot[iId]][clanDeposit] = 0;
					g_Clan[g_ClanSlot[iId]][clanKillsHumanDone] = 0;
					g_Clan[g_ClanSlot[iId]][clanKillsZombieDone] = 0;
					g_Clan[g_ClanSlot[iId]][clanInfectionsDone] = 0;
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
					g_ClanMembers[g_ClanSlot[iId]][0][clanMemberTimePlayed][0] = EOS;
					g_ClanMembers[g_ClanSlot[iId]][0][clanMemberLevel] = g_Level[iId];

					clientPrintColor(0, _, "!t%s!y creo el clan !g%s!y", g_PlayerName[iId], g_Clan[g_ClanSlot[iId]][clanName]);
					showMenu__Clan(iId);
				}
			}
		}
	} else {
		clientPrintColor(iId, _, "Ese nombre de clan ya existe, elija otro por favor");
		showMenu__Clan(iId);
	}
}

public showMenu__ClanInvitePlayer(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("INVITAR JUGADORES\R", "menu__ClanInviteUsers");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || !g_AccountLogged[i] || id == i || g_ClanSlot[i] || g_ClanInvitationsId[i][id]) {
			continue;
		}
		
		formatex(sItem, charsmax(sItem), "%s \y(N: %d)", g_PlayerName[i], g_Level[i]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1) {
		DestroyLocalMenu(id, iMenuId);
		
		clientPrintColor(id, _, "No hay usuarios disponibles para mostrar en el menú");
		
		showMenu__Clan(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	g_MenuPage[id][MENU_PAGE_CLAN_INVITE] = min(g_MenuPage[id][MENU_PAGE_CLAN_INVITE], (menu_pages(iMenuId) - 1));
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__ClanInviteUsers(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
		DestroyLocalMenu(id, menu);
		return PLUGIN_HANDLED;
	}
	
	new iItemId;
	player_menu_info(id, iItemId, iItemId, g_MenuPage[id][MENU_PAGE_CLAN_INVITE]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menu);
		
		showMenu__Clan(id);
		return PLUGIN_HANDLED;
	}
	
	new sPosition[2];
	menu_item_getinfo(menu, item, iItemId, sPosition, charsmax(sPosition), _, _, iItemId);
	DestroyLocalMenu(id, menu);
	
	iItemId = sPosition[0];
	
	if(g_IsConnected[iItemId]) {
		if(!g_ClanSlot[iItemId]) {
			clientPrintColor(id, _, "Enviaste una invitación a !t%s!y para que se una a tu clan", g_PlayerName[iItemId]);
			clientPrintColor(iItemId, _, "El jugador !t%s!y te invitó al clan !g%s!y", g_PlayerName[id], g_Clan[g_ClanSlot[id]][clanName]);
			
			++g_ClanInvitations[iItemId];
			g_ClanInvitationsId[iItemId][id] = 1;
		} else {
			clientPrintColor(id, _, "El jugador seleccionado acaba de entrar en un clan");
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado");
	}
	
	showMenu__ClanInvitePlayer(id);
	return PLUGIN_HANDLED;
}

public showMenu__ClanInvitations(const id) {
	new iMenuId;
	new i;
	new sItem[64];
	new sPosition[2];
	
	iMenuId = menu_create("INVITACIONES A OTROS CLANES\R", "menu__ClanInvitations");
	
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || !g_AccountLogged[i] || !g_ClanInvitationsId[id][i]) {
			continue;
		}
		
		formatex(sItem, charsmax(sItem), "%s \r-\y %s", g_PlayerName[i], g_Clan[g_ClanSlot[i]][clanName]);
		
		sPosition[0] = i;
		sPosition[1] = 0;
		
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	if(menu_items(iMenuId) < 1) {
		DestroyLocalMenu(id, iMenuId);

		clientPrintColor(id, _, "No hay solicitudes disponibles para mostrar en el menú");
		
		showMenu__Clan(id);
		return;
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "Atrás");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "Siguiente");
	menu_setprop(iMenuId, MPROP_EXITNAME, "Volver");
	
	fix_pdata_menu(id);
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__ClanInvitations(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
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
	
	if(g_IsConnected[iItemId]) {
		if(g_ClanSlot[iItemId]) {
			if(g_Clan[g_ClanSlot[iItemId]][clanCountMembers] < MAX_CLAN_MEMBERS) {
				if(g_ClanInvitationsId[id][iItemId]) {
					new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO ze3_clans_members (acc_id, clan_id, owner, since_connection, last_connection) VALUES ('%d', '%d', '0', '%d', '%d');", g_AccountId[id], g_Clan[g_ClanSlot[iItemId]][clanId], get_arg_systime(), get_arg_systime());
					
					if(!SQL_Execute(sqlQuery)) {
						executeQuery(id, sqlQuery, 18);
					} else {
						SQL_FreeHandle(sqlQuery);
						
						sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE ze3_pjs SET clan_id='%d' WHERE acc_id='%d';", g_Clan[g_ClanSlot[iItemId]][clanId], g_AccountId[id]);
						
						if(!SQL_Execute(sqlQuery)) {
							executeQuery(id, sqlQuery, 19);
						} else {
							SQL_FreeHandle(sqlQuery);
							
							g_ClanSlot[id] = g_ClanSlot[iItemId];
							
							++g_Clan[g_ClanSlot[id]][clanCountMembers];
							++g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

							new iClanSlotId = getClanMemberEmptySlot(id);
							
							if(iClanSlotId >= 0) {
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberId] = g_AccountId[id];
								copy(g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberName], 31, g_PlayerName[id]);
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberOwner] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceDay] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceHour] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberSinceMinute] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeDay] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeHour] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLastTimeMinute] = 0;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberTimePlayed][0] = EOS;
								g_ClanMembers[g_ClanSlot[id]][iClanSlotId][clanMemberLevel] = g_Level[id];
							}

							--g_ClanInvitations[iItemId];
							g_ClanInvitations[id] = 0;

							g_ClanInvitationsId[id][iItemId] = 0;
							
							new i;
							for(i = 1; i <= MaxClients; ++i) {
								if(g_ClanSlot[id] == g_ClanSlot[i]) {
									clientPrintColor(i, _, "!t%s!y se unió al Clan", g_PlayerName[id]);
								}
							}

							showMenu__Clan(id);
						}
					}
				} else {
					clientPrintColor(id, _, "La invitación al clan ha expirado");
					
					--g_ClanInvitations[id];
					g_ClanInvitationsId[id][iItemId] = 0;
				}
			} else {
				clientPrintColor(id, _, "El clan está lleno");
				
				--g_ClanInvitations[id];
				g_ClanInvitationsId[id][iItemId] = 0;
			}
		} else {
			clientPrintColor(id, _, "El jugador no está en un clan");
			
			--g_ClanInvitations[id];
			g_ClanInvitationsId[id][iItemId] = 0;
		}
	} else {
		clientPrintColor(id, _, "El jugador seleccionado se ha desconectado");
		
		--g_ClanInvitations[id];
		g_ClanInvitationsId[id][iItemId] = 0;
	}
	
	if(g_ClanInvitations[id] && !g_ClanSlot[id]) {
		showMenu__ClanInvitations(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanInfo(const id) {
	oldmenu_create("\yCLAN - %s", "menu__ClanInfo", g_Clan[g_ClanSlot[id]][clanName]);

	oldmenu_additem(-1, -1, "\wCreado el\r:\y %s", getUnixToTime(g_Clan[g_ClanSlot[id]][clanTimestamp]));
	oldmenu_additem(-1, -1, "\wHumanos matados en el Clan\r:\y %d", g_Clan[g_ClanSlot[id]][clanKillsHumanDone]);
	oldmenu_additem(-1, -1, "\wZombies matados en el Clan\r:\y %d", g_Clan[g_ClanSlot[id]][clanKillsZombieDone]);
	oldmenu_additem(-1, -1, "\wHumanos infectados en el Clan\r:\y %d", g_Clan[g_ClanSlot[id]][clanInfectionsDone]);
	oldmenu_additem(-1, -1, "\wVictorias\r:\y %d", g_Clan[g_ClanSlot[id]][clanVictory]);
	oldmenu_additem(-1, -1, "\wVictorias consecutivas\r:\y %d", g_Clan[g_ClanSlot[id]][clanVictoryConsec]);
	oldmenu_additem(-1, -1, "\wVictorias consecutivas en la historia\r:\y %d^n", g_Clan[g_ClanSlot[id]][clanVictoryConsecHistory]);

	oldmenu_additem(0, 0, "\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ClanInfo(const id, const item) {
	if(!item) {
		showMenu__Clan(id);
		return;
	}

	showMenu__ClanInfo(id);
}

public showMenu__ClanOnlineMembers(const id) {
	new iMenuId;
	new i;
	new j;
	new k;
	new sItem[128];
	new sPosition[2];
	
	formatex(sItem, charsmax(sItem), "VER MIEMBROS CONECTADOS (%d / %d)^n\wAl seleccionar uno, verás la información del jugador\y\R", g_Clan[g_ClanSlot[id]][clanCountMembers], MAX_CLAN_MEMBERS);
	iMenuId = menu_create(sItem, "menu__ClanOnlineMembers");
	
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(!g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
			continue;
		}
		
		sPosition[0] = i;
		sPosition[1] = 0;
		k = 0;
		
		for(j = 1; j <= MaxClients; ++j) {
			if(g_IsConnected[j]) {
				if(g_AccountId[j] == g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
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

public menu__ClanOnlineMembers(const id, const menu, const item) {
	if(!g_IsConnected[id]) {
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
		clientPrintColor(id, _, "El jugador seleccionado se acaba de ir del clan");
		showMenu__ClanOnlineMembers(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClanMemberInfo(const id, const member) {
	if(!g_ClanSlot[id]) {
		return;
	}

	g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID] = member;
	
	oldmenu_create("\y%s - %s", "menu__ClanMemberInfo", g_ClanMembers[g_ClanSlot[id]][member][clanMemberName], ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberOwner]) ? "Dueño" : "Miembro"));

	oldmenu_additem(-1, -1, "\wNivel\r:\y %d", g_ClanMembers[g_ClanSlot[id]][member][clanMemberLevel]);

	if(g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay] || g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour] || g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeMinute]) {
		oldmenu_additem(-1, -1, "\wÚltima vez visto hace\r:\y %d %s", ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay] : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeHour] : g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeMinute])), ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? "días" : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberLastTimeDay]) ? "horas" : "minutos")));
	} else {
		oldmenu_additem(-1, -1, "\wÚltima vez visto hace\r:\y Ahora");
	}
	
	oldmenu_additem(-1, -1, "\wMiembro desde hace\r:\y %d %s^n", ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay] : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour]) ? g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour] : g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceMinute])), ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceDay]) ? "días" : ((g_ClanMembers[g_ClanSlot[id]][member][clanMemberSinceHour]) ? "horas" : "minutos")));

	new iOk = 0;
	new iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][member][clanMemberName]);

	if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][member][clanMemberId]) {
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

	if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][member][clanMemberId]) {
		oldmenu_additem(8, 8, "\r8.\w Abandonar Clan");
	}

	oldmenu_additem(0, 0, "^n\r0.\w Volver");
	oldmenu_display(id);
}

public menu__ClanMemberInfo(const id, const item) {
	if(!item) {
		showMenu__ClanOnlineMembers(id);
		return;
	}

	new iMemberId = g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID];

	switch(item) {
		case 3: {
			new iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);

			if(getClanMemberRange(id) && getClanMemberRange(iMemberRange) && g_AccountId[id] != g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				new Float:flGameTime = get_gametime();

				if(g_Clan_QueryFlood[id] > flGameTime) {
					clientPrintColor(id, _, "Espera unos segundos antes de volver a modificar los rangos");

					showMenu__ClanMemberInfo(id, iMemberId);
					return;
				}

				g_Clan_QueryFlood[id] = (flGameTime + 5.0);

				new iArgs[3];
				
				iArgs[0] = id;
				iArgs[1] = 0;
				iArgs[2] = iMemberId;
				
				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_clans_members SET owner='0' WHERE acc_id='%d' AND clan_id='%d' AND active='1';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__UpdateClanRange", g_SqlQuery, iArgs, sizeof(iArgs));
			} else {
				showMenu__ClanMemberInfo(id, iMemberId);
			}
		} case 4: {
			new iMemberRange = get_user_index(g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);

			if(getClanMemberRange(id) && !getClanMemberRange(iMemberRange) && g_AccountId[id] != g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				new Float:flGameTime = get_gametime();

				if(g_Clan_QueryFlood[id] > flGameTime) {
					clientPrintColor(id, _, "Espera unos segundos antes de volver a modificar los rangos");

					showMenu__ClanMemberInfo(id, iMemberId);
					return;
				}

				g_Clan_QueryFlood[id] = (flGameTime + 5.0);
				
				new iArgs[3];
				
				iArgs[0] = id;
				iArgs[1] = 1;
				iArgs[2] = iMemberId;
				
				formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_clans_members SET owner='1' WHERE acc_id='%d' AND clan_id='%d' AND active='1';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);
				SQL_ThreadQuery(g_SqlTuple, "sqlThread__UpdateClanRange", g_SqlQuery, iArgs, sizeof(iArgs));
			} else {
				showMenu__ClanMemberInfo(id, iMemberId);
			}
		} case 7: {
			if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				clientPrintColor(id, _, "No te podés expulsar vos mismo del clan");
				showMenu__ClanMemberInfo(id, iMemberId);
			} else if(!getClanMemberRange(id)) {
				clientPrintColor(id, _, "No tenés el rango suficiente como para expulsar miembros del clan");
				showMenu__ClanMemberInfo(id, iMemberId);
			} else {
				showMenu__ClanRemoveMember(id, iMemberId);
			}
		} case 8: {
			if(g_AccountId[id] == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
				showMenu__ClanQuit(id);
			} else {
				showMenu__ClanMemberInfo(id, iMemberId);
			}
		}
	}
}

public sqlThread__UpdateClanRange(const fail_state, const Handle:query, const error[], const error_num, const data[], const data_size, const Float:queue_time) {
	new iId = data[0];
	
	if(!g_IsConnected[iId]) {
		return;
	}

	if(fail_state != TQUERY_SUCCESS) {
		log_to_file(__SQL_FILE, "sqlThread__UpdateClanRange() - [%d] - <%s>", error_num, error);

		g_AccountLogged[iId] = 0;
		g_AccountJoined[iId] = 0;

		server_cmd("kick #%d ^"Hubo un error al actualizar el rango de un miembro del clan. Contáctese con el desarrollador para más información e inténtalo más tarde^"", get_user_userid(iId));
		return;
	}

	new iType = data[1];
	new iMemberId = data[2];

	switch(iType) {
		case 0: {
			clientPrintColor(iId, _, "!t%s!y ha sido degradado a !tMiembro!y", g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberName]);
			g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberOwner] = 0;
		} case 1: {
			clientPrintColor(iId, _, "!t%s!y ha sido promovido a !tDueño!y", g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberName]);
			g_ClanMembers[g_ClanSlot[iId]][iMemberId][clanMemberOwner] = 1;
		}
	}

	showMenu__ClanMemberInfo(iId, iMemberId);
}

public showMenu__ClanRemoveMember(const id, const member) {
	oldmenu_create("\yEXPULSAR MIEMBRO^n\w¿Estás seguro de expulsar a \y%s\w del clan?", "menu__ClanRemoveMember", g_ClanMembers[g_ClanSlot[id]][member][clanMemberName]);

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

public menu__ClanRemoveMember(const id, const item) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new iMemberId = g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID];

	switch(item) {
		case 1: {
			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE ze3_clans_members SET active='0' WHERE acc_id='%d' AND clan_id='%d' AND active='1';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);
			
			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 14);
			} else {
				SQL_FreeHandle(sqlQuery);
				
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE ze3_pjs SET clan_id='0' WHERE acc_id='%d';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);
				
				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 15);
				} else {
					SQL_FreeHandle(sqlQuery);

					--g_Clan[g_ClanSlot[id]][clanCountMembers];

					new i;
					new j = 0;
					
					for(i = 1; i <= MaxClients; ++i) {
						if(!g_IsConnected[i] || g_ClanSlot[id] != g_ClanSlot[i]) {
							continue;
						}
						
						clientPrintColor(i, _, "!t%s!y ha sido expulsado del clan", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);
						
						if(id == i) {
							continue;
						}
						
						if(!j) {
							if(g_AccountId[i] == g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]) {
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
}

public showMenu__ClanQuit(const id) {
	oldmenu_create("\yABANDONAR CLAN^n\w¿Estás seguro de abandonar el clan?", "menu__CLanQuit");

	oldmenu_additem(1, 1, "\r1.\w Si");
	oldmenu_additem(2, 2, "\r2.\w No");

	oldmenu_display(id);
}

public menu__CLanQuit(const id, const item) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new iMemberId = g_MenuData[id][MENU_DATA_CLAN_MEMBER_ID];

	switch(item) {
		case 1: {
			new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE ze3_clans_members SET active='0' WHERE acc_id='%d' AND clan_id='%d' AND active='1';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId], g_Clan[g_ClanSlot[id]][clanId]);

			if(!SQL_Execute(sqlQuery)) {
				executeQuery(id, sqlQuery, 16);
			} else {
				SQL_FreeHandle(sqlQuery);

				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE ze3_pjs SET clan_id='0' WHERE acc_id='%d';", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId]);

				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 17);
				} else {
					SQL_FreeHandle(sqlQuery);

					sendClanMessage(id, "!t%s!y ha abandonado el clan", g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberName]);

					--g_Clan[g_ClanSlot[id]][clanCountMembers];
					--g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

					g_ClanMembers[g_ClanSlot[id]][iMemberId][clanMemberId] = 0;
					g_ClanSlot[id] = 0;
				}
			}

			showMenu__Clan(id);
		} case 2: {
			showMenu__ClanMemberInfo(id, iMemberId);
		}
	}
}

public getUserClanBadString(const clan_name[]) {
	new const LETTERS_AND_SIMBOLS_ALLOWED[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '(', ')', '[', ']', '{', '}', '-', '=', '.', ',', ':', '!', ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
	new iLen = strlen(clan_name);
	new i;
	new j = 0;
	new k;

	for(i = 0; i < iLen; ++i) {
		for(k = 0; k < sizeof(LETTERS_AND_SIMBOLS_ALLOWED); ++k) {
			if(clan_name[i] == LETTERS_AND_SIMBOLS_ALLOWED[k]) {
				++j;
			}
		}
	}

	if(iLen != j) {
		return 1;
	}

	return 0;
}

public checkClanOnDisconnected(const id) {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_ClanInvitationsId[i][id]) {
			--g_ClanInvitations[i];
		}
		
		g_ClanInvitationsId[i][id] = 0;
	}

	if(g_ClanSlot[id]) {
		clanUpdateHumans(id);

		--g_Clan[g_ClanSlot[id]][clanCountOnlineMembers];

		if(!g_Clan[g_ClanSlot[id]][clanCountOnlineMembers]) {
			g_Clan[g_ClanSlot[id]][clanId] = 0;
		}
	}
}

public clanFindSlot() {
	new i;
	for(i = 1; i < 33; ++i) {
		if(!g_Clan[i][clanId]) {
			return i;
		}
	}

	return 0;
}

public getClanMemberEmptySlot(const id) {
	new i;
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId]) {
			continue;
		}

		return i;
	}

	return -1;
}

public getClanMemberSlotId(const id) {
	new i;
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] == g_AccountId[id]) {
			return i;
		}
	}

	return -1;
}

public resetDataClanMembers(const clan_slot) {
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
		g_ClanMembers[clan_slot][i][clanMemberLevel] = 0;
	}
}

public getClanMemberRange(const id) {
	new i;
	for(i = 0; i < MAX_CLAN_MEMBERS; ++i) {
		if(g_ClanMembers[g_ClanSlot[id]][i][clanMemberId] == g_AccountId[id]) {
			return g_ClanMembers[g_ClanSlot[id]][i][clanMemberOwner];
		}
	}

	return 0;
}

public sendClanMessage(const id, const input[], any:...) {
	static sMessage[191];
	static i;

	vformat(sMessage, charsmax(sMessage), input, 3);

	for(i = 1; i <= MaxClients; ++i) {
		if(g_ClanSlot[id] == g_ClanSlot[i]) {
			clientPrintColor(i, _, sMessage);
		}
	}
}

public clanUpdateHumans(const id) {
	if(!g_ClanSlot[id]) {
		return;
	}

	new iHumans = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsAlive[i] || g_ClanSlot[id] != g_ClanSlot[i] || g_Zombie[i]) {
			continue;
		}

		++iHumans;
	}

	g_Clan[g_ClanSlot[id]][clanHumans] = iHumans;
}

public clcmd__Game(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	new TeamName:iTeam = getUserTeam(id);

	if((iTeam != TEAM_SPECTATOR)) {
		clientPrintColor(id, _, "Sólo los espectadores pueden utilizar este comando");
		return PLUGIN_HANDLED;
	}

	showMenu__Game(id);
	return PLUGIN_HANDLED;
}

public task__TimePlayed(const task_id) {
	new iId = (task_id - TASK_TIME_PLAYED);

	if(!g_IsConnected[iId] || !g_AccountLogged[iId]) {
		return;
	}

	g_TimePlayed[iId][TIME_PLAYED_MIN] += 6;
}

public clcmd__SaveAll(const id) {
	if(g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	new iCount = 0;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i] || g_AccountLoading[i] || !g_AccountLogged[i]) {
			continue;
		}

		saveInfo(i, 1);
		++iCount;
	}

	g_DataSaved = 1;

	clientPrintColor(0, _, "Guardando datos de !g%d jugador%s!y. A partir de aquí el guardado está deshabilitado hasta el próximo cambio de mapa", iCount, ((iCount != 1) ? "es" : ""));
	return PLUGIN_HANDLED;
}

public clcmd__APs(const id) {
	if(g_AccountId[id] != 1) {
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
	new iAPs;

	read_argv(2, sArg2, charsmax(sArg2));
	iAPs = str_to_num(sArg2);

	if(iAPs < 0) {
		consolePrint(id, "Ingresa un valor válido o mayor que 0");
		return PLUGIN_HANDLED;
	}

	g_APs[iTarget] = iAPs;

	clientPrintColor(iTarget, id, "!t%s!y te asignó !g%d APs!y!", g_PlayerName[id], g_APs[iTarget]);
	return PLUGIN_HANDLED;
}

public clcmd__XP(const id) {
	if(g_AccountId[id] != 1) {
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
	new iXP;

	read_argv(2, sArg2, charsmax(sArg2));
	iXP = str_to_num(sArg2);

	if(iXP < 0) {
		consolePrint(id, "Ingresa un valor válido o mayor que 0");
		return PLUGIN_HANDLED;
	}

	g_XP[iTarget] = iXP;

	clientPrintColor(iTarget, id, "!t%s!y te asignó !g%d XP!y!", g_PlayerName[id], g_XP[iTarget]);
	return PLUGIN_HANDLED;
}

public clcmd__Level(const id) {
	if(g_AccountId[id] != 1) {
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
	new iLevel;

	read_argv(2, sArg2, charsmax(sArg2));
	iLevel = str_to_num(sArg2);

	if(iLevel < 1 || iLevel > MAX_LEVEL) {
		consolePrint(id, "No puedes asignar niveles menor a 1 o mayor a %d", MAX_LEVEL);
		return PLUGIN_HANDLED;
	}

	g_Level[iTarget] = clamp(iLevel, 1, MAX_LEVEL);
	fixXP(iTarget);

	clientPrintColor(iTarget, id, "!t%s!y te asignó al nivel !g%d!y", g_PlayerName[id], g_Level[iTarget]);
	return PLUGIN_HANDLED;
}

public clcmd__Points(const id) {
	if(g_AccountId[id] != 1) {
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
	new iPoints;

	read_argv(2, sArg2, charsmax(sArg2));
	iPoints = str_to_num(sArg2);

	if(iPoints < 0) {
		consolePrint(id, "Ingresa un valor válido o mayor que 0");
		return PLUGIN_HANDLED;
	}

	g_Points[iTarget] = iPoints;

	clientPrintColor(iTarget, id, "!t%s!y te asignó !g%d pL!y!", g_PlayerName[id], g_Points[iTarget]);
	return PLUGIN_HANDLED;
}

public clcmd__Revive(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_D)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[MAX_NAME_LENGTH];
	new iTarget;

	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);

	if(!iTarget) {
		return PLUGIN_HANDLED;
	} else if(g_NewRound || g_EndRound) {
		consolePrint(id, "No puedes revivir a un jugador en estas instancias de la ronda");
		return PLUGIN_HANDLED;
	}

	clientPrintColor(0, id, "!t%s!y ha revivido a !g%s!y", g_PlayerName[id], g_PlayerName[iTarget]);

	respawnUser(iTarget);
	return PLUGIN_HANDLED;
}

public ham__WeaponPrimaryAttackPost(const weapon_ent) {
	if(!pev_valid(weapon_ent)) {
		return HAM_IGNORED;
	}

	static iId;
	iId = getWeaponEntId(weapon_ent);

	if(!isUserValidAlive(iId) || g_Zombie[iId] || g_SpecialMode[iId] || g_HumanClass[iId] != HUMAN_CLASS_SHARAPSHOOTER) {
		return HAM_IGNORED;
	}

	if(cs_get_weapon_ammo(weapon_ent) < 1) {
		return HAM_IGNORED;
	}

	static Float:vecPushAngle[3];
	vecPushAngle[0] = 0.0;

	entity_set_vector(iId, EV_VEC_punchangle, vecPushAngle);
	return HAM_IGNORED;
}

public clcmd__Invis(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	++g_UserOptions_Invis[id];

	if(g_UserOptions_Invis[id] == 3) {
		g_UserOptions_Invis[id] = 0;
	}

	switch(g_UserOptions_Invis[id]) {
		case 0: {
			clientPrintColor(id, _, "Ahora tus compañeros son !gVisibles!y");
		} case 1: {
			clientPrintColor(id, _, "Ahora tus compañeros son !gInvisibles!y");
		} case 2: {
			clientPrintColor(id, _, "Ahora tus compañeros son !gInvisibles!y. Puedes ver a los integrantes de tu !gGrupo!y");
		}
	}

	return PLUGIN_HANDLED;
}

public clcmd__Top15(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	showMenu__StatsTop15(id);
	return PLUGIN_HANDLED;
}

public dropWeapons(const id, const drop_what) {
	new sWeapons[32];
	new iNum = 0;
	new i;
	new iWeaponId;

	get_user_weapons(id, sWeapons, iNum);

	for(i = 0; i < iNum; ++i) {
		iWeaponId = sWeapons[i];

		if((drop_what == 1 && ((1<<iWeaponId) & PRIMARY_WEAPONS_BIT_SUM)) || (drop_what == 2 && ((1<<iWeaponId) & SECONDARY_WEAPONS_BIT_SUM))) {
			new sWeaponName[32];
			get_weaponname(iWeaponId, sWeaponName, charsmax(sWeaponName));

			engclient_cmd(id, "drop", sWeaponName);
		}
	}
}

public fwd__CmdStartPre(const id, const uc_handle) {
	if(!g_IsAlive[id]) {
		return;
	}

	static iButton;
	static iOldButtons;

	iButton = get_uc(uc_handle, UC_Buttons);
	iOldButtons = entity_get_int(id, EV_INT_oldbuttons);

	if(g_Zombie[id] && g_ZombieClass[id] == ZOMBIE_CLASS_FARAHON && !g_SpecialMode[id]) {
		if((iButton & IN_RELOAD) && !(iOldButtons & IN_RELOAD)) {
			static Float:flGameTime;
			flGameTime = get_gametime();

			if((flGameTime - g_ZombieClass_FarahonLastTime[id]) < 20.0) {
				static Float:flRest;
				static iRest;

				flRest = (20.0 - (flGameTime - g_ZombieClass_FarahonLastTime[id]));
				iRest = floatround(flRest);

				clientPrintColor(id, _, "Debes esperar !g%s!y para volver a utilizar tu poder", getCooldDownTime(iRest));
				return;
			}

			g_ZombieClass_FarahonLastTime[id] = get_gametime();

			message_begin(MSG_ONE, g_Message_BarTime, _, id);
			write_byte(1);
			write_byte(0);
			message_end();

			emitSound(id, CHAN_ITEM, __SOUND_ZOMBIE_FARAHON[3]);

			remove_task(id + TASK_ZOMBIE_FARAHON);
			set_task(1.0, "task__ZombieFarahon", id + TASK_ZOMBIE_FARAHON);
		}

		if(iOldButtons & IN_RELOAD && !(iButton & IN_RELOAD)) {
			if(task_exists(id + TASK_ZOMBIE_FARAHON)) {
				clientPrintColor(id, _, "Recuerda que !gmanteniendo apretando la Tecla R!y lanzas bolas de fuego");

				g_ZombieClass_FarahonLastTime[id] = 0.0;

				emitSound(id, CHAN_ITEM, __SOUND_ZOMBIE_FARAHON[4]);
			}

			message_begin(MSG_ONE, g_Message_BarTime, _, id);
			write_byte(0);
			write_byte(0);
			message_end();

			remove_task(id + TASK_ZOMBIE_FARAHON);
		}
	}
}

public task__ZombieFarahon(const task_id) {
	new iId = (task_id - TASK_ZOMBIE_FARAHON);

	if(!g_IsAlive[iId]) {
		return;
	}

	new Float:vecOrigin[3];
	new Float:vecVAngle[3];
	new iEnt = create_entity("info_target");
	new Float:vecVelocity[3];

	getUserEyePosition(iId, vecOrigin);
	entity_get_vector(iId, EV_VEC_v_angle, vecVAngle);

	if(!iEnt || !is_valid_ent(iEnt)) {
		return;
	}

	entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_FARAHON);
	entity_set_model(iEnt, __MODEL_FARAHON);
	entity_set_size(iEnt, Float:{-1.5, -1.5, -1.5}, Float:{1.5, 1.5, 1.5});
	entity_set_origin(iEnt, vecOrigin);

	makeVector(vecVAngle);
	entity_set_vector(iEnt, EV_VEC_angles, vecVAngle);

	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);

	entity_set_float(iEnt, EV_FL_scale, 0.3);
	entity_set_int(iEnt, EV_INT_spawnflags, SF_SPRITE_STARTON);
	entity_set_float(iEnt, EV_FL_framerate, 25.0);
	
	set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 255);

	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(iEnt, EV_ENT_owner, iId);

	velocity_by_aim(iId, 700, vecVelocity);
	entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iEnt);
	write_short(g_Sprite_Laserbeam);
	write_byte(5);
	write_byte(6);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();

	set_task(0.2, "task__ZombieFarahonEnt", iEnt, .flags="b");

	emitSound(iId, CHAN_ITEM, __SOUND_ZOMBIE_FARAHON[0]);
	emitSound(iEnt, CHAN_ITEM, __SOUND_ZOMBIE_FARAHON[1]);
}

public getUserEyePosition(const id, Float:vecOrigin[3]) {
	new Float:vecViewOfs[3];

	entity_get_vector(id, EV_VEC_view_ofs, vecViewOfs);
	entity_get_vector(id, EV_VEC_origin, vecOrigin);

	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin);
}

public makeVector(Float:vecVector[3]) {
	vecVector[0] -= 30.0;

	engfunc(EngFunc_MakeVectors, vecVector);

	vecVector[0] = -(vecVector[0] + 30.0);
}

public task__ZombieFarahonEnt(const ent) {
	if(!pev_valid(ent)) {
		remove_task(ent);
		return;
	}

	new Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, (vecOrigin[2] + 30));
	write_short(g_Sprite_Flame);
	write_byte(5);
	write_byte(200);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SMOKE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_Smoke);
	write_byte(13);
	write_byte(15);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	write_byte(25);
	write_byte(255);
	write_byte(128);
	write_byte(0);
	write_byte(2);
	write_byte(3);
	message_end();
}

public touch__Farahon(const ball_ent, const ent) {
	if(!is_valid_ent(ball_ent)) {
		return;
	}

	static iAttacker;
	iAttacker = entity_get_edict(ball_ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ball_ent);
		return;
	}

	static Float:vecOrigin[3];
	static iVictim;
	static iArgs[2];

	entity_get_vector(ball_ent, EV_VEC_origin, vecOrigin);
	iVictim = -1;

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_Explode);
	write_byte(40);
	write_byte(25);
	write_byte(TE_EXPLFLAG_NOSOUND);
	message_end();

	emitSound(ball_ent, CHAN_ITEM, __SOUND_ZOMBIE_FARAHON[2]);

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 150.0)) != 0) {
		if(!isUserValidAlive(iVictim) || g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_ImmunityFire[iVictim]) {
			continue;
		}

		g_Burning_Duration[iVictim] += 20;

		iArgs[0] = iAttacker;
		iArgs[1] = 0; // ¿Afecta a los Zombies?

		if(!task_exists(iVictim + TASK_BURN_FLAME)) {
			set_task(0.5, "task__BurningFlame", iVictim + TASK_BURN_FLAME, iArgs, sizeof(iArgs), "b");
		}
	}

	remove_entity(ball_ent);
}

public madnessExplode(const ent) {
	if(g_EndRound) {
		return;
	}

	new iAttacker = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iAttacker)) {
		remove_entity(ent);
		return;
	}

	new Float:vecOrigin[3];
	new iVictim = -1;

	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	createExplosion(vecOrigin, random(256), random(256), random(256), 0.0);

	emitSound(ent, CHAN_WEAPON, __SOUND_GRENADE_FIRE);

	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 240.0)) > 0) {
		if(!isUserValidAlive(iVictim) || !g_Zombie[iVictim] || g_SpecialMode[iVictim] || g_Immunity[iVictim] || g_ImmunityBombs[iVictim] || g_MadnessBomb_Move[iVictim]) {
			continue;
		}

		g_MadnessBomb_Count[iVictim] = 0;

		remove_task(iVictim + TASK_MADNESS_BOMB);
		set_task(0.5, "task__ConfuseVictim", iVictim + TASK_MADNESS_BOMB, _, _, "a", 20);
	}

	remove_entity(ent);
}

public task__ConfuseVictim(const task_id) {
	new iId = (task_id - TASK_MADNESS_BOMB);

	if(!g_IsConnected[iId]) {
		return;
	}

	if(random_num(0, 1) == 1) {
		g_MadnessBomb_Move[iId] = 1;

		clientPrint(iId, print_center, "¡ESTÁS RE DURO!");

		message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenFade, _, iId);
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

		entity_set_vector(iId, EV_VEC_punchangle, vecVelocity);
		entity_get_vector(iId, EV_VEC_velocity, vecVelocity);

		vecVelocity[0] /= 3.0;
		vecVelocity[1] /= 2.0;

		entity_set_vector(iId, EV_VEC_velocity, vecVelocity);
	}

	++g_MadnessBomb_Count[iId];

	if(g_MadnessBomb_Count[iId] == 20) {
		g_MadnessBomb_Count[iId] = 0;
		g_MadnessBomb_Move[iId] = 0;
	}
}

public Float:clampFloat(const Float:value, const Float:min, const Float:max) {
	if(value < min) {
		return min;
	} else if(value > max) {
		return max;
	}

	return value;
}

public showBulletDamage(const victim, const attacker, const Float:damage, const zombie) {
	if(isUserValidAlive(victim) && isUserValidAlive(attacker) && damage > 0.0) {
		++g_UserBullet[attacker];

		if(g_UserBullet[attacker] == sizeof(__BULLET_DAMAGE_COORDS)) {
			g_UserBullet[attacker] = 0;
		}

		new iRed = ((zombie && g_Zombie[attacker]) ? 200 : 25);
		new iBlue = ((zombie && g_Zombie[attacker]) ? 25 : 200);

		set_hudmessage(iRed, 125, iBlue, __BULLET_DAMAGE_COORDS[g_UserBullet[attacker]][0], __BULLET_DAMAGE_COORDS[g_UserBullet[attacker]][1], 0, 0.1, 2.5, 0.02, 0.02, -1);
		ShowSyncHudMsg(attacker, g_HudSync_Damage, "%0.0f", damage);
	}
}

public task__RemoveStuff() {
	new iEnt = -1;

	while((iEnt = find_ent_by_class(iEnt, "func_button")) > 0) {
		call_think(iEnt);
	}
}

public getHealthSpecialMode(const id) {
	new sHealth[8];
	new sHealthOutput[32];
	new iSurvivorId = getSurvivorId();
	new iNemesisId = getNemesisId();

	sHealth[0] = EOS;
	sHealthOutput[0] = EOS;

	if(g_Mode == MODE_SURVIVOR && isUserValidConnected(iSurvivorId) && iSurvivorId != id) {
		addDot(g_Health[iSurvivorId], sHealth, charsmax(sHealth));

		switch(g_UserOptions_HudStyle[id][HUD_TYPE_GENERAL]) {
			case 0: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "Vida del Survivor: %s^n", sHealth);
			} case 1: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "[Vida del Survivor: %s]^n", sHealth);
			} case 2: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "Vida del Survivor: %s^n", sHealth);
			} case 3: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "[Vida del Survivor: %s]^n", sHealth);
			} case 4: {
				formatex(sHealthOutput, charsmax(sHealthOutput), " - Vida del Survivor: %s^n", sHealth);
			}
		}
	} else if(g_Mode == MODE_NEMESIS && isUserValidConnected(iNemesisId) && iNemesisId != id) {
		addDot(g_Health[iNemesisId], sHealth, charsmax(sHealth));

		switch(g_UserOptions_HudStyle[id][HUD_TYPE_GENERAL]) {
			case 0: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "Vida del Nemesis: %s^n", sHealth);
			} case 1: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "[Vida del Nemesis: %s]^n", sHealth);
			} case 2: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "Vida del Nemesis: %s^n", sHealth);
			} case 3: {
				formatex(sHealthOutput, charsmax(sHealthOutput), "[Vida del Nemesis: %s]^n", sHealth);
			} case 4: {
				formatex(sHealthOutput, charsmax(sHealthOutput), " - Vida del Nemesis: %s^n", sHealth);
			}
		}
	}

	return sHealthOutput;
}

public getSurvivorId() {
	if(g_Mode != MODE_SURVIVOR) {
		return -1;
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
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

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsAlive[i] && g_SpecialMode[i] == MODE_NEMESIS) {
			return i;
		}
	}

	return -1;
}

public clcmd__Modes(const id) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return PLUGIN_HANDLED;
	}

	showMenu__Modes(id, g_MenuPage[id][MENU_PAGE_MODES]);
	return PLUGIN_HANDLED;
}

public showMenu__Modes(const id, page) {
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
		return;
	}

	new iMaxPages;
	new iStart;
	new iEnd;
	new i;
	new j;
	new iUsersNum = getUsersPlaying();
	new k = 0;

	oldmenu_pages(iMaxPages, iStart, iEnd, page, sizeof(__MODES));
	oldmenu_create("\yMODOS \r[%d - %d]\y\R%d / %d", "menu__Modes", (iStart + 1), iEnd, page, iMaxPages);

	for(i = iStart, j = 1; i < iEnd; ++i, ++j) {
		if(__MODES[i][modeName][0]) {
			if(!g_NewRound || g_EventModes) {
				oldmenu_additem(-1, -1, "\d%d. %s", j, __MODES[i][modeName]);
			} else {
				if(iUsersNum >= __MODES[i][modeUsersNeed]) {
					oldmenu_additem(j, i, "\r%d.\w %s", j, __MODES[i][modeName]);
				} else {
					k = (__MODES[i][modeUsersNeed] - iUsersNum);
					oldmenu_additem(-1, -1, "\d%d. %s \r(Faltan %d jugador%s)", j, __MODES[i][modeName], k, ((k != 1) ? "es" : ""));
				}
			}
		} else {
			oldmenu_additem(-1, -1, "\d%d. - - - -", j);
		}
	}

	oldmenu_pagination(page, iMaxPages);
	oldmenu_display(id, page);
}

public menu__Modes(const id, const item, const value, page) {
	if(!item || value > sizeof(__MODES)) {
		return;
	}

	if(item > 7) {
		new iNewPage = (page + value);

		g_MenuPage[id][MENU_PAGE_MODES] = iNewPage;

		showMenu__Modes(id, iNewPage);
		return;
	}

	if(!g_NewRound) {
		clientPrintColor(id, _, "No puedes lanzar modos en estas instancias de la ronda");
		return;
	} else if(g_EventModes) {
		clientPrintColor(id, _, "No puedes lanzar modos en horarios de eventos");
		return;
	} else if(value == MODE_JERUZALEM && !(get_user_flags(id) & ADMIN_LEVEL_E)) {
		clientPrintColor(id, _, "Solo gente del Staff puede lanzar este modo");
		return;
	}

	new iUsersNum = getUsersPlaying();

	if(iUsersNum < __MODES[value][modeUsersNeed]) {
		new k = (__MODES[value][modeUsersNeed] - iUsersNum);

		clientPrintColor(id, _, "Faltan !g%d jugador%s!y para lanzar el modo", k, ((k != 1) ? "es" : ""));
		return;
	}

	clientPrintColor(0, id, "!t%s!y lanzó el modo !g%s!y", g_PlayerName[id], __MODES[value][modeName]);
	startModePre(value, .fake_mode=1);
}

public touch__Toxico(const ent, const id) {
	if(!is_valid_ent(ent)) {
		return;
	}

	new sClassName[32];
	entity_get_string(id, EV_SZ_classname, sClassName, charsmax(sClassName));

	if(equal(sClassName, "player")) {
		if(isUserValidAlive(id)) {
			emitSound(id, CHAN_BODY, __SOUND_ZOMBIE_TOXIC[0]);

			if(!g_Zombie[id] && !g_SpecialMode[id]) {
				new iOwner = entity_get_edict(ent, EV_ENT_owner);

				if(isUserValidAlive(iOwner)) {
					new iTotalHealth = (g_Health[id] - 30);

					if(iTotalHealth >= g_Health[id]) {
						ExecuteHamB(Ham_Killed, id, iOwner, 0);
					} else {
						set_user_health(id, iTotalHealth);
						g_Health[id] = get_user_health(id);
					}

					++g_APs[iOwner];
				}
			}

			new vecOrigin[3];
			get_user_origin(id, vecOrigin);
			bubbleBreak(id, vecOrigin);
		}
	}

	if(equal(sClassName, "func_breakable") && entity_get_int(id, EV_INT_solid) != SOLID_NOT) {
		force_use(ent, id);
	}

	remove_entity(ent);
}

public bubbleBreak(const id, const vecOrigin[3]) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin);
	write_byte(TE_BREAKMODEL);
	write_coord(vecOrigin[0]);
	write_coord(vecOrigin[1]);
	write_coord((vecOrigin[2] + 24));
	write_coord(16);
	write_coord(16);
	write_coord(16);
	write_coord(random_num(-50, 50));
	write_coord(random_num(-50, 50));
	write_coord(25);
	write_byte(10);
	write_short(g_Sprite_Toxico);
	write_byte(10);
	write_byte(38);
	write_byte(BREAK_GLASS);
	message_end();
}

public task__SpectNVision(const id) {
	if(!g_IsConnected[id] || g_IsAlive[id]) {
		return;
	}

	setUserNVision(id, 1);
}

public clcmd__NVision(const id) {
	if(!g_IsConnected[id]) {
		return PLUGIN_HANDLED;
	}

	if(g_NVision[id]) {
		if(task_exists(id + TASK_NVISION)) {
			remove_task(id + TASK_NVISION);
		} else {
			set_task(0.3, "task__SetNVision", id + TASK_NVISION, .flags="b");
		}
	}

	return PLUGIN_HANDLED;
}

public task__SetNVision(const task_id) {
	new iId = (task_id - TASK_NVISION);

	if(!g_NVision[iId]) {
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
	write_byte(60);
	if(g_Immunity[iId]) {
		write_byte(255);
		write_byte(255);
		write_byte(255);
	}
	// else if(g_Immunity[iId] && g_Petrification[iId])
	// {
		// write_byte(64);
		// write_byte(64);
		// write_byte(64);
	// }
	else if(g_SpecialMode[iId]) {
		switch(g_SpecialMode[iId]) {
			case MODE_NEMESIS: {
				write_byte(255);
				write_byte(70);
				write_byte(70);
			} default: {
				write_byte(255);
				write_byte(255);
				write_byte(255);
			}
		}
	} else {
		write_byte(255);
		write_byte(255);
		write_byte(255);
	}
	write_byte(7);
	write_byte(7);
	message_end();
}

public setUserNVision(const id, const value) {
	g_NVision[id] = value;

	remove_task(id + TASK_NVISION);

	// if(!g_NVision[id]) {
		// return;
	// }

	// set_task(0.3, "task__SetNVision", id + TASK_NVISION, .flags="b");
}

public showMenu__UserOptions_Vinc(const id) {
	oldmenu_create("\yVINCULAR CUENTA", "menu__UserOptions_Vinc");

	oldmenu_additem(-1, -1, "\wPara vincular tu cuenta del Zombie Plague");
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

public menu__UserOptions_Vinc(const id, const item) {
	if(!item) {
		if(g_AccountJoined[id]) {
			showMenu__UserOptions(id);
		} else {
			showMenu__Join(id);
		}

		return;
	}

	switch(item) {
		case 1: {
			if(g_AccountVinc[id]) {
				clientPrintColor(id, _, "Tu cuenta ya ha sido vinculada. Visita nuestro foro para ver tus datos en el Panel de Vinculación !g%s!y", __PLUGIN_COMMUNITY_FORUM);

				showMenu__UserOptions_Vinc(id);
				return;
			}

			clientPrintColor(id, _, "Ingresa tu E-Mail con el que te registraste en el foro !t%s!y", __PLUGIN_COMMUNITY_FORUM);
			client_cmd(id, "messagemode V_INGRESAR_MAIL");
		}
	}
}

public clcmd__VEnterMail(const id) {
	if(!g_AccountLogged[id] || g_AccountVinc[id]) {
		return PLUGIN_HANDLED;
	}

	new sMail[128];
	read_args(sMail, charsmax(sMail));
	remove_quotes(sMail);
	trim(sMail);

	copy(g_AccountVincMail[id], charsmax(g_AccountVincMail[]), sMail);

	clientPrintColor(id, _, "Ingresa tu contraseña con el que ingresas en el foro !t%s!y", __PLUGIN_COMMUNITY_FORUM);
	client_cmd(id, "messagemode V_INGRESAR_CLAVE");

	return PLUGIN_HANDLED;
}

public clcmd__VEnterPassword(const id) {
	if(!g_AccountLogged[id] || g_AccountVinc[id]) {
		return PLUGIN_HANDLED;
	}

	new sPassword[128];
	read_args(sPassword, charsmax(sPassword));
	remove_quotes(sPassword);
	trim(sPassword);

	copy(g_AccountVincPassword[id], charsmax(g_AccountVincPassword[]), sPassword);

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

	if(!isUserValidConnected(iId)) {
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

	if(!isUserValidConnected(iId)) {
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

	formatex(g_SqlQuery, charsmax(g_SqlQuery), "UPDATE ze3_accounts SET vinc='%d' WHERE id='%d';", g_AccountVinc[iId], g_AccountId[iId]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__IgnoreQuery", g_SqlQuery);

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

public setAnimation(const id, const animation) {
	entity_set_int(id, EV_INT_weaponanim, animation);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
	write_byte(animation);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

public fixWeaponOnSemiclip() {
	new WeaponIdType:i;
	new sWeapon[32];

	for(i = WEAPON_P228; i <= WEAPON_P90; ++i) {
		if(WEAPON_NOT_GUNS & (1<< _:i)) {
			continue;
		}

		rg_get_weapon_info(i, WI_NAME, sWeapon, charsmax(sWeapon));

		RegisterHam(Ham_Weapon_PrimaryAttack, sWeapon, "ham__WeaponPrimaryAttackPre", false);
		RegisterHam(Ham_Weapon_PrimaryAttack, sWeapon, "ham__WeaponPrimaryAttackPost2", true);
	}
}

public ham__WeaponPrimaryAttackPre(const weapon_ent) {
	if(!get_member(weapon_ent, m_Weapon_iClip)) {
		return HAM_IGNORED;
	}

	new WeaponIdType:iType = get_member(weapon_ent, m_iId);

	if((WEAPON_PISTOLS & (1<< _:iType)) && (get_member(weapon_ent, m_Weapon_iShotsFired) > 0)) {
		return HAM_IGNORED;
	}

	new iOwner = get_member(weapon_ent, m_pPlayer);
	new iTeam = get_member(iOwner, m_iTeam);
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		if((i == iOwner) || !g_IsAlive[i] || (get_member(i, m_iTeam) != iTeam)) {
			continue;
		}

		set_entvar(i, var_solid, SOLID_NOT);
		g_Restore |= (1<<(i & 31));
	}

	return HAM_IGNORED;
}

public ham__WeaponPrimaryAttackPost2(const weapon_ent) {
	if(!g_Restore) {
		return HAM_IGNORED;
	}

	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(~g_Restore & (1<<(i & 31))) {
			continue;
		}

		set_entvar(i, var_solid, SOLID_BBOX);
	}

	g_Restore = 0;
	return HAM_IGNORED;
}

public task__ActivateVIP(const task_id) {
	new iId = ((task_id > MaxClients) ? (task_id - TASK_SPAWN) : task_id);

	if(!g_IsAlive[iId]) {
		return;
	}

	g_SpecialMode[iId] = MODE_JERUZALEM;

	rg_reset_user_model(iId);
	rg_set_user_model(iId, __PLAYER_MODEL_JERUZALEM_VIP);

	set_user_rendering(iId, kRenderFxGlowShell, 0, 255, 128, kRenderNormal, 5);
}

modeJeruzalemFinish(const TeamName:winnerTeam, userDisconnectedId=0) {
	if(g_ModeJeruzalem_AlreadyRewarded) {
		return;
	}

	g_ModeJeruzalem_AlreadyRewarded = true;

	new i;

	if(winnerTeam == TEAM_TERRORIST) {
		killUsersAlive(0, userDisconnectedId);

		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}

			if(!g_Zombie[i]) {
				continue;
			}

			g_Points[i] += 20;
			setAchievement(i, MODE_JERUZALEM_WIN_AS_ZOMBIE);
		}

		clientPrintColor(0, _, "Todos los !tzombies vivos!y ganaron !g+20 pL!y");
	} else {
		killUsersAlive(1, userDisconnectedId);

		new iRewardPoints = g_VIPsDead * 10;

		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}

			if(g_Zombie[i]) {
				continue;
			}

			g_Points[i] += iRewardPoints;
			setAchievement(i, MODE_JERUZALEM_2VIPS_ESCAPE);
		}

		clientPrintColor(0, _, "Todos los !thumanos vivos!y ganaron !g+%d pL!y", iRewardPoints);
	}
}

public killUsersAlive(const killTeam, const userDisconnectedId) {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i]) {
			continue;
		}

		if(i == userDisconnectedId) {
			continue;
		}

		giveXP(i, g_ModeJeruzalem_RewardExp[i]);
		clientPrintColor(i, _, "Ganaste !g+%d!y de XP", g_ModeJeruzalem_RewardExp[i]);

		g_ModeJeruzalem_RewardExp[i] = -5;

		if(!g_IsAlive[i]) {
			continue;
		}

		if(g_Zombie[i] == killTeam) {
			user_kill(i, 1);
		}
	}
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

	return PLUGIN_HANDLED;
}

public getUserUnlimitedClip(const id) {
	return get_member(id, m_iWeaponInfiniteAmmo);
}

public setUserUnlimitedClip(const id, const value) {
	set_member(id, m_iWeaponInfiniteAmmo, value);
}

public clcmd__Test(const id) {
	if(!g_IsConnected[id] || g_AccountId[id] != 1) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public createHats() {
	new iEnt;
	new i;

	for(i = 1; i <= MaxClients; ++i) {
		iEnt = create_entity("info_target");
		
		entity_set_string(iEnt, EV_SZ_classname, __ENT_CLASSNAME_HAT);
		entity_set_model(iEnt, __HATS[0][hatModelName]);
		
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW);
		
		entity_set_edict(iEnt, EV_ENT_aiment, i);
		entity_set_edict(iEnt, EV_ENT_owner, i);
	}
}

public getHatByOwner(const ent) {
	return find_ent_by_owner(-1, __ENT_CLASSNAME_HAT, ent);
}

public updatePlayerHat(const id) {
	new iEnt = getHatByOwner(id);

	if(!g_IsConnected[id] || !g_AccountLogged[id] || !is_valid_ent(iEnt)) {
		return;
	}

	g_Hat[id] = g_Hat_Choosed[id];

	if(!g_Hat[id]) {
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
		return;
	}

	entity_set_model(iEnt, __HATS[g_Hat[id]][hatModelName]);

	if(g_Zombie[id] || g_SpecialMode[id]) {
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW));
	} else {
		entity_set_int(iEnt, EV_INT_effects, (entity_get_int(iEnt, EV_INT_effects) & ~EF_NODRAW));
	}
}

public clcmd__NextMode(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_E)) {
		return PLUGIN_HANDLED;
	}

	new sArg1[8];
	new iMode;

	read_argv(1, sArg1, charsmax(sArg1));
	iMode = str_to_num(sArg1);

	if(read_argc() < 2) {
		new i;
		for(i = 0; i < structIdModes; ++i) {
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
	return PLUGIN_HANDLED;
}

public task__RemovePowerZombie(const task_id) {
	new iId = (task_id - TASK_POWER_ZOMBIE);

	if(!g_IsAlive[iId] || !g_Zombie[iId] || g_SpecialMode[iId] || g_ZombieClass[iId] != ZOMBIE_CLASS_BANSHEE) {
		return;
	}

	g_ZombieClass_BansheeActive[iId] = 0;

	clientPrintColor(iId, _, "Ya puedes volver a utilizar el poder");
}

public think__Banshee(const ent) {
	if(!is_valid_ent(ent)) {
		return;
	}

	static iOwner;
	iOwner = entity_get_edict(ent, EV_ENT_owner);

	if(!isUserValidConnected(iOwner)) {
		return;
	}

	startBanshee(ent, iOwner);
}

public touch__Banshee(const ent, const toucher) {
	if(!is_valid_ent(ent)) {
		return;
	}

	static iOwner;
	iOwner = entity_get_edict(ent, EV_ENT_owner);

	if(!is_valid_ent(toucher) && isUserValidConnected(iOwner)) {
		startBanshee(ent, iOwner);
		return;
	}

	if(isUserValidAlive(toucher) && toucher != iOwner && !g_Zombie[toucher] && !g_SpecialMode[toucher]) {
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(ent, EV_ENT_aiment, toucher);
		entity_set_float(ent, EV_FL_nextthink, (get_gametime() + 3.0));

		emitSound(iOwner, CHAN_VOICE, __SOUND_ZOMBIE_BANSHEE[1]);

		g_Speed[iOwner] = Float:zombieSpeed(iOwner, g_ZombieClass[iOwner]);
		ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, iOwner);

		g_ZombieClass_BansheeStat[toucher] = 1;
		g_ZombieClass_BansheeOwner[toucher] = iOwner;

		set_task(3.0, "task__ZombieBansheeStat", toucher);
	}
}

public task__ZombieBansheeStat(const id) {
	g_ZombieClass_BansheeStat[id] = 0;
	g_ZombieClass_BansheeOwner[id] = 0;
}

public startBanshee(const ent, const id) {
	new Float:vecOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_Sprite_Bat);
	write_byte(40);
	write_byte(30);
	write_byte(14);
	message_end();

	emitSound(ent, CHAN_WEAPON, __SOUND_ZOMBIE_BANSHEE[2]);

	g_Speed[id] = Float:zombieSpeed(id, g_ZombieClass[id]);
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

	remove_entity(ent);
}

public clcmd__Spect(const id) {
	if(!g_IsConnected[id] || !g_AccountLogged[id]) {
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

public onGameRules__RestartRoundPre() {
	rg_balance_teams();

	set_task(0.1, "task__RemoveStuff");

	set_cvar_num("amx_afk_time", 60);
	set_cvar_num("sv_alltalk", 1);
	set_cvar_num("sv_airaccelerate", 100);

	g_CountDown = 5;
	g_NewRound = 1;
	g_EndRound = 0;
	g_Mode = 0;
	g_ExtraItem_InfectionBomb = 0;
	g_ExtraItem_BubbleBomb = 0;
	g_ExtraItem_MadnessBomb = 0;
	g_Secret_CrazyMode = 0;
	g_Secret_CrazyMode_Count = 0;
	g_Achievement_ValentinaTeAmo = 0;
	g_MapEscaped = 0;

	remove_task(TASK_VIRUST);
	remove_task(TASK_STARTMODE);
	remove_task(TASK_COUNTDOWN);
	remove_task(TASK_ZOMBIE_BACK);

	set_task(2.0, "task__VirusT", TASK_VIRUST);
	set_task((2.0 + get_pcvar_num(g_pCvar_Delay)), "task__StartMode", TASK_STARTMODE);
	set_task(3.0, "task__CountDown", TASK_COUNTDOWN);
	set_task(15.0, "task__ZombieBack", TASK_ZOMBIE_BACK);

	if(g_NextMode != -1) {
		g_CurrentMode = g_NextMode;
		g_NextMode = -1;
	}

	new i;
	new j;

	for(i = 1; i <= MaxClients; ++i) {
		if(g_IsConnected[i]) {
			g_ZombieClass_Voodoo[i] = 0;
			g_ZombieClass_LustyRose[i] = 0;
			g_ZombieClass_LustyRoseActive[i] = 0;
			g_ZombieClass_FarahonLastTime[i] = 0.0;
			g_ZombieClass_Fleshpound[i] = 0;
			g_ZombieClass_FleshpoundActive[i] = 0;
			g_ZombieClass_Banshee[i] = 0;
			g_ZombieClass_BansheeActive[i] = 0;
			g_ZombieClass_BansheeStat[i] = 0;
			g_ZombieClass_BansheeOwner[i] = 0;
			g_StatsRound_SupplyBoxDone[i] = 0;
			g_Secret_AlreadySayCrazy[i] = 0;
			g_Escaped[i] = 0;

			for(j = 0; j < structIdExtraItem; ++j) {
				g_ExtraItem_InRound[i][j] = 0;
			}

			if(g_AccountLogged[i]) {
				updateRewardsByFlags(i);
			}
		}
	}

	showSupplyBox();
	checkEvents();
}

public onGameRules__RoundEndPost(const WinStatus:status, const ScenarioEventEndRound:event, const Float:delay) {
	removeStuffInEndRound();

	// static Float:flGameTime;
	// static Float:flLastEndTime;

	// flGameTime = get_gametime();

	// if((flGameTime - flLastEndTime) < 0.5) {
		// return;
	// }

	// flLastEndTime = flGameTime;

	g_EndRound = 1;

	remove_task(TASK_VIRUST);
	remove_task(TASK_COUNTDOWN);
	remove_task(TASK_STARTMODE);
	remove_task(TASK_ZOMBIE_BACK);
	remove_task(TASK_MODE_ARMAGEDDON_1);
	remove_task(TASK_MODE_ARMAGEDDON_2);
	remove_task(TASK_MODE_ARMAGEDDON_3);
	remove_task(TASK_MODE_ARMAGEDDON_4);
	if(g_AmbienceSounds[g_Mode]) {
		remove_task(TASK_AMBIENCESOUNDS);
		client_cmd(0, "mp3 stop; stopsound");
	}
	remove_task(TASK_ACHIEVEMENT_VALENTINA_TE_AMO);

	new iUsersPlaying = getUsersPlaying();
	new i;
	
	if(!getZombies()) {
		message_begin(MSG_BROADCAST, g_Message_ScreenFade);
		write_short(UNIT_SECOND * 4);
		write_short(floatround(UNIT_SECOND * 11.2));
		write_short(FFADE_OUT);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		write_byte(100);
		message_end();

		set_hudmessage(0, 0, 255, -1.0, 0.25, 0, 1.0, 7.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(0, g_HudSync_Event, "¡GANARON LOS ESCAPISTAS!");

		playSound(0, __SOUND_WIN_HUMANS);

		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}

			g_Speed[i] = 125.0;
			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);

			if(iUsersPlaying >= 10) {
				if(g_LastHuman[i] && g_LastHuman_1000hp[i]) {
					setAchievement(i, VENGAN_LOS_ESPERO);
				} else if(g_LastHuman[i]) {
					if(g_Mode != MODE_INFECTION && g_Mode != MODE_MULTI) {
						setAchievement(i, SOLO_WIN);
					}
				}
			}
		}

		if(g_Mode == MODE_JERUZALEM) {
			modeJeruzalemFinish(TEAM_CT);
		}
	} else if(!getHumans()) {
		message_begin(MSG_BROADCAST, g_Message_ScreenFade);
		write_short(UNIT_SECOND * 4);
		write_short(floatround(UNIT_SECOND * 11.2));
		write_short(FFADE_OUT);
		write_byte(255);
		write_byte(0);
		write_byte(0);
		write_byte(100);
		message_end();

		set_hudmessage(255, 0, 0, -1.0, 0.25, 0, 1.0, 7.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(0, g_HudSync_Event, "¡GANARON LOS ZOMBIES!");

		playSound(0, __SOUND_WIN_ZOMBIES);

		for(i = 1; i <= MaxClients; ++i) {
			if(!g_IsAlive[i]) {
				continue;
			}

			g_Speed[i] = 75.0;
			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, i);
			
			if(g_Frozen[i]) {
				removeFrostCube(i);
			}
		}
	} else {
		message_begin(MSG_BROADCAST, g_Message_ScreenFade);
		write_short(UNIT_SECOND * 4);
		write_short(floatround(UNIT_SECOND * 11.2));
		write_short(FFADE_OUT);
		write_byte(255);
		write_byte(255);
		write_byte(255);
		write_byte(100);
		message_end();

		set_hudmessage(255, 255, 255, -1.0, 0.25, 0, 1.0, 7.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(0, g_HudSync_Event, "¡NO GANÓ NADIE!");

		playSound(0, __SOUND_WIN_NO_ONE);
	}

	if(iUsersPlaying < 1) {
		return;
	}

	if(g_EndRound_Forced) {
		g_EndRound_Forced = 0;
	}

	// if(g_FirstRound) {
		// return;
	// }

	// static iMaxTerrors;
	// static iTerrors;
	// static TeamName:iTeam[MAX_PLAYERS + 1];

	// iMaxTerrors = (iUsersPlaying / 2);
	// iTerrors = 0;

	for(i = 1; i <= MaxClients; ++i) {
		if(!g_IsConnected[i]) {
			continue;
		}

		g_ImmunityFire[i] = 0;
		g_ImmunityFrost[i] = 0;

		// iTeam[i] = getUserTeam(i);

		// if((iTeam[i] == TEAM_UNASSIGNED) || (iTeam[i] == TEAM_SPECTATOR)) {
			// continue;
		// }

		// setUserTeam(i, TEAM_CT);
		// iTeam[i] = TEAM_CT;
	}

	// i = 0;

	// while(iTerrors < iMaxTerrors) {
		// if(++i > MaxClients) {
			// i = 1;
		// }

		// if(!g_IsConnected[i]) {
			// continue;
		// }

		// if(iTeam[i] != TEAM_CT) {
			// continue;
		// }

		// if(random_num(0, 1)) {
			// setUserTeam(i, TEAM_TERRORIST);
			// iTeam[i] = TEAM_TERRORIST;

			// ++iTerrors;
		// }
	// }
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

	if(!g_AccountRegistering[id] && !g_AccountLoading[id]) {
		if(g_AccountBanned[id]) {
			showMenu__Banned(id);
		} else {
			if((!g_AccountRegister[id] || !g_AccountLogged[id]) && !g_AccountJoined[id]) {
				showMenu__LogIn(id);
			} else {
				if(!g_AccountJoined[id]) {
					showMenu__Join(id);
				} else {
					showMenu__Game(id);
				}
			}
		}

		SetHookChainReturn(ATYPE_INTEGER, 0);
	}

	return HC_BREAK;
}

public onClient__HandleMenuChooseTeamPre(const id, const MenuChooseTeam:slot) {
	SetHookChainReturn(ATYPE_INTEGER, 0);
	return HC_BREAK;
}

public event__HideWeapon(const id) {
	if(!g_IsConnected[id]) {
		return;
	}

	set_member(id, m_iClientHideHUD, 0);
	set_member(id, m_iHideHUD, (HIDEHUD_HEALTH | HIDEHUD_MONEY));
}

public onGrenade__ThrowHeGrenadePre(const id, Float:vecStart[3], Float:vecVelocity[3], Float:time, const team, const usEvent) {
	if(!g_SpecialMode[id]) {
		if(g_Zombie[id]) {
			clientPrintColor(0, id, "!t%s!y ha lanzado una Bomba de Infección.", g_PlayerName[id]);
		} else {
			if(g_MadnessBomb[id]) {
				clientPrintColor(0, id, "!t%s!y ha lanzado una Bomba de Droga.", g_PlayerName[id]);
			}
		}
	}
}

public onGrenade__ThrowSmokeGrenadePre(const id, Float:vecStart[3], Float:vecVelocity[3], Float:time, const usEvent) {
	if(!g_Zombie[id] && !g_SpecialMode[id] && g_BubbleBomb[id]) {
		clientPrintColor(0, id, "!t%s!y ha lanzado un Campo de Fuerza.", g_PlayerName[id]);
	}
}