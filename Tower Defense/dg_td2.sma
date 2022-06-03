#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta_util>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <orpheu>
#include <orpheu_memory>
#include <orpheu_stocks>
#include <dhudmessage_old>
#include <safemenu>
#include <colorchat>
#include <sqlx>
#include <unixtime>
#include <entity_maths>

#pragma semicolon 1

new const PLUGIN_NAME[] = "Tower Defense";
new const PLUGIN_VERSION[] = "v2.12.3";
new const PLUGIN_AUTHOR[] = "KISKE & Atsel.";

/*

*/

#define MAX_USERS 11

#define SQL_HOST "45.58.126.18"
#define SQL_USER "dg_tduser"
#define SQL_PASS "6EqAbkooO9WKClvn"
#define SQL_TABLE "dg_td"

new g_PoderScouter[33];
new g_Pistolero_AutoFire[33];
new g_Lights[2];

new const MAPNAME_FIX[][] = {
	"td_kmid_v2", "td_orange"
};

enum _:LogrosInt {
	BETA_TESTER = 0, BETA_TESTER_AVANZADO,
	NIVEL_10G, NIVEL_20G, NIVEL_30G, NIVEL_40G, NIVEL_50G, NIVEL_60G, NIVEL_70G, NIVEL_80G, NIVEL_90G, NIVEL_100G,
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
	NONE_00, NONE_01, NONE_02, NONE_03
};

enum _:mapStruct {
	mapName[32],
	mapDesc[32],
	mapBlock,
	mapAchievement,
	mapBossCoord,
	mapSpecial,
	mapTowerHealth,
	mapExtraMonsters
};

enum _:bossCoords {
	__X = 0,
	__Y,
	__Z
};

enum _:mapsIds
{
	TD_KMID = 0,
	TD_ORANGE,
	TD_KWOOL_SMALL,
	TD_GEMPIRE,
	TD_DARK_NIGHT,
	TD_CITY2,
	TD_KHELL,
	TD_CASTLE_X2,
	TD_KSUB,
	TD_KSUB_WOOL,
	TD_KWHITE,
	TD_PLAZA2,
	TD_KWOOL_X2,
	TD_MINECRAFT,
	TD_OLD_DUST
};

new const MAPS_DESC[mapsIds][mapStruct] =
{
	{"td_kmid_v2", "", 0, NOOB_KMID, __X, 0, 500, 0},
	{"td_orange", "", 0, NOOB_ORANGE, __X, 0, 500, 0},
	{"td_kwool_small", "", 0, NOOB_KWOOL, __X, 0, 500, 0},
	{"td_gempire", "", 0, NOOB_GEMPIRE, __X, 0, 500, 0},
	{"td_dark_night", "", 0, NOOB_DARK_NIGHT, __X, 0, 500, 0},
	{"td_city2", "", 0, NOOB_CITY, __X, 0, 500, 0},
	{"td_khell_v2", "", 0, NOOB_KGELL, __Y, 2, 1000, 50},
	{"td_castle_x2-fix2", "", 0, NOOB_CASTLE, __X, 2, 1000, 30},
	{"td_ksub_v2", "", 0, NOOB_KSUB, __X, 0, 500, 0},
	{"td_ksub_wool", " \r(NIGHTMARE+)", 1, NOOB_KSUB_WOOL, __X, 1, 1000, 25},
	{"td_kwhite", " \r(NIGHTMARE+)", 1, NOOB_KWHITE, __X, 0, 500, 0},
	{"td_plaza2", " \r(NIGHTMARE+)", 1, NOOB_PLAZA, __X, 0, 500, 0},
	{"td_kwool_x2", " \r(NIGHTMARE+)", 1, NOOB_KWOOL_X2, __X, 1, 1000, 30},
	{"td_minecraft", " \r(SUICIDAL+)", 2, NOOB_MINECRAFT, __X, 0, 500, 0},
	{"td_old_dust", " \r(SUICIDAL+)", 2, NOOB_OLD_DUST, __X, 0, 500, 0}
};

new const BOSS_ACHIEVEMENT[] = {
	BOSS_GORILA_NOOB, BOSS_FIRE_NOOB, BOSS_FT_NOOB, BOSS_GUARDIANES_NOOB
};

enum _:uniqueZombiesIds {
	ZOMBIE_NORMAL = 0,
	ZOMBIE_ALIEN
};

enum _:structHabilities {
	HAB_CRITICO = 0,
	HAB_RESISTENCIA,
	HAB_THOR,
	HAB_UNLOCK_APOYO,
	HAB_UNLOCK_PESADO,
	HAB_UNLOCK_ASALTO,
	HAB_UNLOCK_COMANDANTE,
	HAB_SPEED
};

enum _:struct__Habilities {
	menuHabName[32],
	menuHabInfo[48],
	upgMaxLevel,
	upgValue,
	upgCost
};

new const __HABILITIES[structHabilities][struct__Habilities] = {
	{"CRÍTICO", "Tus balas tienen % de hacer daño crítico", 10, 2, 3},
	{"RESISTENCIA", "Menos daño recibido por zombies", 5, 1, 3},
	{"THOR", "Tu rayo afecta a 3-4 zombies más", 1, 1, 15},
	{"CLASE: APOYO", "Te permite utilizar la clase APOYO", 1, 1, 25},
	{"CLASE: PESADO", "Te permite utilizar la clase PESADO", 1, 1, 25},
	{"CLASE: ASALTO", "Te permite utilizar la clase ASALTO", 1, 1, 25},
	{"CLASE: COMANDANTE", "Te permite utilizar la clase COMANDANTE", 1, 1, 25},
	{"VELOCIDAD", "Te permite correr más rápido", 10, 16, 5}
};

new g_Upgrades[MAX_USERS][structHabilities];

new const MONSTER_MODELS_NORMAL[][] = {	"gk_td/gk_m_normal1", "gk_td/gk_m_normal2", "player/gk_zombie_10/gk_zombie_10", "gk_td/gk_m_normal4", "gk_td/gk_m_speed1", "gk_td/gk_m_speed2", "gk_td/gk_m_speed3", "player/tcs_zombie_2/tcs_zombie_2",
										"player/tcs_zombie_5/tcs_zombie_5", "gk_td/gk_z_normal_01", "gk_td/gk_z_normal_02", "player/tcs_zombie_18/tcs_zombie_18"};
new const MONSTER_MODELS_SPEED[][] = {"gk_td/gk_m_speed1", "gk_td/gk_m_speed2", "gk_td/gk_m_speed3"};
new const MONSTER_UNIQUE_MODELS[][] = {"gk_td/gk_z_special_01"};
new const TOWER_MODEL[] = "models/gk_td/gk_tower.mdl";
new const MODEL_SENTRY_BASE[] = "models/gk_td/gk_base.mdl";
new const MODEL_SENTRY_BASE_LV4_LV6[] = "models/gk_td/gk_sentry_newbase.mdl";
new const MODEL_SENTRY_LEVEL[][] = {"models/gk_td/gk_sentry1.mdl", "models/gk_td/gk_sentry2.mdl", "models/gk_td/gk_sentry3.mdl", "models/gk_td/gk_sentry_new3.mdl", "models/gk_td/gk_sentry_new4.mdl", "models/gk_td/gk_sentry_new5.mdl"};
// new const MODEL_ROBOT[][] = {"models/gk_td/gk_bait_lv1.mdl", "models/gk_td/gk_bait_lv2.mdl"};
new const MODEL_GAMINGA[] = "models/gk_td/mun_00/mun_00.mdl";
new const MODEL_V_TOOL[] = "models/gk_td/gk_v_tool.mdl";
new const MODEL_P_TOOL[] = "models/gk_td/gk_p_tool.mdl";
new const MODEL_EGG[] = "models/gk_td/gk_egg.mdl";
new const MODEL_RANKS[] = "models/gk_td/gk_ranks_fix.mdl";
new const MODEL_HATS[] = "models/gk_td/gk_hats.mdl";
new const MODEL_MINIBOSS[] = "models/gk_td/gk_miniboss.mdl";
new const MODEL_BOSS[][] = {"models/gk_td/gk_boss.mdl", "models/gk_td/gk_boss_fire.mdl", "models/gk_td/gk_fallen_titan.mdl", "models/gk_td/gk_m_special1.mdl"};
new const MONSTER_MODEL_SPECIAL[][] = {"player/zp_tcs_l4d_boomer/zp_tcs_l4d_boomer"};
new const MODEL_FIREBALL[] = "models/gk_td/gk_fireball.mdl";
new const MODEL_TANK_ROCK_GIBS[] = "models/rockgibs.mdl";
new const MODEL_SPITTER_AURA[] = "models/gk_td/gk_spitter_aura.mdl";
new const MODEL_FT_AURA[] = "models/gk_td/gk_ft_aura.mdl";
new const MODEL_ION_BOMB_V[] = "models/gk_td/gk_v_ionbomb.mdl";
new const MODEL_ION_BOMB_P[] = "models/gk_td/gk_p_ionbomb.mdl";
new const MODEL_ION_BOMB_W[] = "models/gk_td/gk_w_ionbomb.mdl";
new const MODEL_GIB_BONE[] = "models/gib_b_bone.mdl";
new const MODEL_GIB_GIB[] = "models/gib_b_gib.mdl";
new const MODEL_GIB_LEG[] = "models/gib_legbone.mdl";
new const MODEL_GIB_LUNG[] = "models/gib_lung.mdl";
new const MODEL_GIB_SKULL[] = "models/gib_skull.mdl";
new const MODEL_TENTACLE[] = "models/gk_td/gk_tentacle.mdl";
new const MODEL_AWP_LV7[] = "models/gk_td/gk_v_awp.mdl";

new const MONSTER_SOUNDS_DEATH[][] = {"zp5/zombie_death_00.wav", "zombie_plague/tcs_zombie_die_1.wav", "zombie_plague/tcs_zombie_die_2.wav", "zombie_plague/zombie_die1.wav"};
new const MONSTER_SOUNDS_PAIN[][] = {"zombie_plague/zombie_pain_1_t.wav", "zombie_plague/zombie_pain_2_t.wav", "zombie_plague/zombie_pain1.wav", "zombie_plague/zombie_pain5.wav"};
new const MONSTER_SOUNDS_CLAW[][] = {"zombie_plague/zombie_claw_wall_1.wav", "zombie_plague/zombie_claw_wall_2.wav"};
new const SOUND_THUNDER[] = "ambience/thunder_clap.wav";
new const SOUND_SENTRY_BASE[] = "gk_td/gk_base.wav";
new const SOUND_SENTRY_HEAD[] = "gk_td/gk_head.wav";
new const SOUND_SENTRY_FIRE[] = "weapons/m249-1.wav";
new const SOUND_SENTRY_FOUND[] = "gk_td/gk_found.wav";
new const MONSTER_SOUNDS_LASER[][] = {"weapons/electro4.wav", "weapons/electro5.wav", "weapons/electro6.wav"};
new const SOUND_BUTTON_OK[] = "buttons/button9.wav";
new const SOUND_BUTTON_BAD[] = "buttons/button2.wav";
new const SOUND_SENTRY_FIRE_LV56[][] = {"weapons/hks1.wav", "weapons/hks2.wav", "weapons/hks3.wav"};
new const SOUND_WIN_GAME[] = "sound/gk_td/gk_win_game.mp3";
new const SOUND_BOSS_ROLL_LOOP[] = "gk_td/gk_boss_rolling_loop.wav";
new const SOUND_BOSS_ROLL_FINISH[] = "gk_td/gk_boss_rolling_finish.wav";
// new const SOUND_BOSS_GALIO[] = "sound/gk_td/gk_boss_galio4.mp3";
new const SOUND_BOSS_PHIT[][] = {"player/bhit_flesh-1.wav", "player/bhit_flesh-2.wav", "player/bhit_flesh-3.wav"};
// new const SOUND_FAKEBOSS_LAUGH[] = "gk_td/gk_mode_03.wav";
new const SOUND_BOSS_EXPLODE[] = "gk_td/gk_boss_fire_explode.wav";
new const SOUND_BOSS_IMPACT[] = "gk_td/gk_boss_fire_impact.wav";
new const SOUND_BOSS_FIREBALL_LAUNCH2[] = "gk_td/gk_boss_fire_launch2.wav";
new const SOUND_BOSS_FIREBALL_LAUNCH4[] = "gk_td/gk_boss_fire_launch4.wav";
new const SOUND_BOSS_FIREBALL_EXPLODE[] = "gk_td/gk_boss_fire_fireball_explode.wav";
new const SOUND_SPITTER_SPIT[] = "zombie_plague/spitter_spit_01.wav";
new const SOUND_BOOMER_EXPLODE[] = "zp6/bomb_explode.wav";
// new const SOUND_ROBOT_MISSILE_FIRED[] = "weapons/rocketfire1.wav";
new const SOUND_FT_CANNON[] = "gk_td/gk_boss_ft_cannon.wav";
new const SOUND_FT_SCREAM[] = "gk_td/gk_boss_ft_scream.wav";

new const MONSTER_SPRITE_SPAWN[] = "sprites/gk_spawn.spr";
new const MONSTER_SPRITE_BLOOD[] = "sprites/blood.spr";
new const MONSTER_SPRITE_BLOODSPRAY[] = "sprites/bloodspray.spr";
new const SPRITE_TRAIL[] = "sprites/laserbeam.spr";
new const SPRITE_DOT[] = "sprites/dot.spr";
new const SPRITE_THUNDER[] = "sprites/lgtning.spr";
// new const SPRITE_SHOCKWAVE[] = "sprites/shockwave.spr";
new const MONSTER_SPRITE_HEALTH_BOSS[] = "sprites/gk_healthbar_boss.spr";

new g_SpecialMonsters_Spawn;
new g_SpecialMonsters_Kills;
new g_Monsters_Spawn;
new g_Monsters_Kills;

new Handle:g_SqlTuple;
new Handle:g_SqlConnection;

new HamHook:g_HamTakeDamage;
new HamHook:g_HamKilled;

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

new OrpheuStruct:g_UserMove;

new g_SqlError[512];

new Float:g_SentryOrigin[MAX_USERS][3];
new Float:g_NoReload[MAX_USERS];
new Float:g_Options_HUD_Position[MAX_USERS][2];
new Float:g_AchievementLink[MAX_USERS];

new g_UserName[MAX_USERS][32];
new g_UserSteam[MAX_USERS][48];
new g_AccountPassword[MAX_USERS][32];
new g_AccountBan_Start[MAX_USERS][32];
new g_AccountBan_Finish[MAX_USERS][32];
new g_AccountBan_Admin[MAX_USERS][32];
new g_AccountBan_Reason[MAX_USERS][128];

new g_Kiske[MAX_USERS];
new g_Gold[MAX_USERS];
new g_PowerActual[MAX_USERS];
new g_Sentry[MAX_USERS];
// new g_Robot[MAX_USERS];
new g_InBuilding[MAX_USERS];
new g_CurrentWeapon[MAX_USERS];
new g_Menu_Sentry[MAX_USERS];
new g_AccountLogged[MAX_USERS];
new g_AccountRegister[MAX_USERS];
new g_Kills[MAX_USERS];
new g_UserId[MAX_USERS];
new g_LevelG[MAX_USERS];
new g_ClassId[MAX_USERS];
new g_Menu_ClassId[MAX_USERS];
new g_Class_Soporte_Bonus[MAX_USERS];
new g_VoteDifficulty[MAX_USERS];
new g_Menu_Difficulty[MAX_USERS];
new g_AllowChangeTeam[MAX_USERS];
new g_SentryDamage[MAX_USERS];
new g_Rank[MAX_USERS];
new g_Hat[MAX_USERS];
new g_MenuPage_ShowLevelG[MAX_USERS];
new g_MenuPage_FavoriteDiff[MAX_USERS];
new g_MenuPage_LevelG[MAX_USERS];
new g_Points[MAX_USERS];
new g_Menu_HabsPoints[MAX_USERS];
new g_MenuPage_Habilities[MAX_USERS];
new g_InBlockZone[MAX_USERS];
new g_KillsPerWave[MAX_USERS][12];
new g_Health[MAX_USERS];
new g_AccountVinc[MAX_USERS];
new g_Options_HUD_Effect[MAX_USERS];
new g_Options_HUD_Center[MAX_USERS];
new g_Options_HUD_ProgressClass[MAX_USERS];
new g_DamageDone[MAX_USERS];
new g_DamageDoneForKill[MAX_USERS];
new g_AchievementCount[MAX_USERS];
new g_Osmio[MAX_USERS];
new g_OsmioLost[MAX_USERS];
new g_WinMVP[MAX_USERS];
new g_WinMVP_Next[MAX_USERS];
new g_GoldG[MAX_USERS];
new g_AchievementMap[MAX_USERS];
new g_Tutorial[MAX_USERS];
new g_MenuPageTutorial[MAX_USERS];
new g_Options_HUD_KillsPerWave[MAX_USERS];
new g_GoldGaben[MAX_USERS];
new g_WinMVPGaben[MAX_USERS];
new Float:g_AFK_Time[MAX_USERS];
new g_AFK_Damage[MAX_USERS];
new g_MenuPage_TOPS[MAX_USERS];
new Float:g_SysTime_TOPS[MAX_USERS];
new g_SupportHab[MAX_USERS];
new g_MenuPage_Upgrades[MAX_USERS];
new g_CriticChance[MAX_USERS];
new Float:g_Speed[MAX_USERS];
new g_GordoBomba_Kills[MAX_USERS];
new g_Unlimited_Clip[MAX_USERS];
new g_UnlimitedClip_WavesLeft[MAX_USERS];
new g_PrecisionPerfecta[MAX_USERS];
new g_PrecisionPerfecta_WavesLeft[MAX_USERS];
new g_Top15_MapId[MAX_USERS];
new g_VoteMap_MapVoted[MAX_USERS];
new g_AlreadyJoined[MAX_USERS];
new g_Sentry_TransferMenu[MAX_USERS];
new g_Dance[MAX_USERS];
new g_Option_LowFPS_Models[MAX_USERS];
new g_Option_LowFPS_Glow[MAX_USERS];
new g_Option_LowFPS_Sentries[MAX_USERS];
new g_Option_LowFPS_ZombieDead[MAX_USERS];
new g_AutoDifficult[MAX_USERS][mapsIds];
new g_MenuPage_Classes[MAX_USERS];
new g_UserPremium[MAX_USERS];

new Array:g_Array_MapName;

new g_Wave;
new g_MonstersAlive;
new g_WaveInProgress;
new g_TempRoundType;
new g_TempMonsterNum;
new g_TempMonsterTrack;
new g_Tower[2];
new g_MaxUsers;
new g_FixStart[2];
new g_Message_HideWeapon;
new g_Message_Crosshair;
new g_Message_RoundTime;
new g_FwSpawn;
new g_FwPrecacheSound;
new g_TotalMonsters;
new g_EntHUD;
new g_HudDamage;
new g_Sprite_Blood;
new g_Sprite_BloodSpray;
new g_Message_ScoreInfo;
new g_NextWaveIncoming;
new g_EndGame;
new g_EntGaminga[20];
new g_StartGame;
new g_StartSeconds;
new g_Sprite_Trail;
new g_MonstersWithShield;
new g_MonstersShield;
new g_TowerHealth;
new g_TOWER_MAX_HEALTH;
new g_HudGeneral;
new g_Sprite_Dot;
new g_MaxZones;
new g_ZoneId;
new g_SetUnits = 10;
new g_Direction;
new g_EditorId;
new g_Sprite_Thunder;
new g_SentryCount;
// new g_RobotCount;
new g_Message_TextMsg;
new g_Message_SendAudio;
new g_HudDamageTower;
new g_MonstersKills;
new g_Difficulty;
new g_EndVote;
new g_Message_ShowMenu;
new g_Message_VGUIMenu;
new g_Message_TeamInfo;
new g_MapsNum;
new g_FORWARD_AddToFullPack;
new g_FORWARD_AddToFullPack_Status;
new g_VoteMap;
new g_MapMenu_TimeLeft;
new g_MapMenu_Maxvotes = 0;
new g_EggCache;
new g_EntGamingaNums;
new g_BestUserKills;
new g_BestUserId;
new g_BlockDiff;
new g_Message_Screenfade;
// new g_Sprite_ShockWave;
new g_Message_ClCorpse;
new g_Message_ScreenShake;
new g_BossPower[3];
new g_BossLastPower[2];
new g_Boss = 0;
new g_Message_AmmoPickup;
new g_Boss_HealthBar;
new g_DamageNeedToGold;
new g_WinMVP_Last;
new g_MapId;
new g_MaxHealth = 0;
new g_MVP_More;
new g_ExtraWaveSpeed;
new g_ExtraWaveStrength;
new g_SpecialWave;
new g_TimePerWave_Users[MAX_USERS][32];
new g_TimePerWave_SysTime[11];
new g_SendMonsterSpecial;
new g_EntCheckAFK;
new g_Message_CurWeapon;
new g_SPRITE_ArrowExplode;
new g_BossId;
new g_BossPower_Explode;
new g_Boss_Fire_UltimateHealth = 9999999;
new g_Boss_Fire_Ultimate;
new g_Achievement_DefensaAbsoluta;
new g_MiniBoss_Ids[3];
new g_Boss_Guardians;
new g_Boss_Guardians_Ids[2];
new g_Boss_Guardians_HealthBar[2];
new g_Tramposo = 0;
new g_GordoHealth;
new g_BlockGame;
new g_AdminOn;
new g_IonUsed = 0;
new g_ModelGibBone;
new g_ModelGibGib;
new g_Model_GibLeg;
new g_Model_GibLung;
new g_Model_GibSkull;
// new g_RobotDamage = 0;
// new g_RobotEnt = 0;
// new g_RobotMissileAllowed;
new g_Dances = 0;
new g_ZombieModels;
new g_Boss_Gorila_AttractPowerHP[2];
new g_LowFPS_ModelIndex_Zombie;
new g_Boss_FT_UltimateHealth = 9999999;
new g_Boss_FT_Enrage = 0;
new g_Boss_FT_UltimateCannons;
new g_Boss_FT_LastPower = 0;
new g_BossMenu_TimeLeft;
new g_Boss_FT_HyperUltimate = 0;
new g_FinishGame;
new g_DamageForKill = 10000;

new g_MapMenu_Votes[128];
new g_MapName[32];
new g_TowerInRegen;

new Float:g_VecStartOrigin[2][3];
new Float:g_VecEndOrigin[2][3];
new Float:g_EntGamingaOrigin[20][3];
new Float:g_VecMonsterTowerOrigin[2][3];
new Float:g_ZoneBox[2][3];
new Float:g_VecSpecialOrigin[3];
new Float:g_EntViewTowerFallingOrigin[3];
new Float:g_VecSpecial2Origin[3];
new Float:g_Teams_Time;
new Float:g_Boss_TimePower[2];
new Float:g_Boss_Respawn[3];
new Float:g_BossRollSpeed[2];

enum _:Tasks (+= 236877) {
	TASK_WAVES = 54276,
	TASK_DAMAGE_TOWER,
	TASK_SPAWN,
	TASK_START_GAME,
	TASK_SHOWZONE,
	TASK_SENTRY_THINK,
	TASK_SAVE,
	TASK_ALLOW_ANOTHER_MONSTER,
	TASK_REGEN_TOWER,
	TASK_TEAM,
	TASK_BUGFIX,
	TASK_SPECIAL_HEAL,
	TASK_VINC,
	TASK_ION_BOMB_EXPLODE
};

enum _:BossList {
	BOSS_GORILA = 0,
	BOSS_FIRE,
	BOSS_FALLEN_TITAN,
	BOSS_GUARDIANES
};

new const BOSSES_NAME[][] = {
	"Gorila \y(FÁCIL)",
	"Fire Monster \y(DIFÍCIL)",
	"Fallen Titan \y(MUY DIFÍCIL)",
	"Guardianes de Kyra \y(IMPOSIBLE)"
};

new const BOSSES_NAME_FF[][] = {
	"GORILA",
	"FIRE MONSTER",
	"FALLEN TITAN",
	"GUARDIANES DE KYRA"
};

new g_BossMenu_Votes[BossList];
new g_BossMenu_Maxvotes;

enum _:BossPowers {
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
};

#define ID_DAMAGE_TOWER				(taskid - TASK_DAMAGE_TOWER)
#define ID_SPAWN					(taskid - TASK_SPAWN)
#define ID_SENTRY_THINK				(taskid - TASK_SENTRY_THINK)
#define ID_SAVE						(taskid - TASK_SAVE)
#define ID_TEAM						(taskid - TASK_TEAM)
#define ID_SPECIAL_HEAL				(taskid - TASK_SPECIAL_HEAL)
#define ID_VINC						(taskid - TASK_VINC)
#define ID_ION_BOMB_EXPLODE			(taskid - TASK_ION_BOMB_EXPLODE)

#define TIME_CHECK_AFK				5.0
#define THINK_CHECK_AFK				get_gametime() + TIME_CHECK_AFK

enum _:RoundsTypes {
	ROUND_NORMAL = 240,
	EGG_MONSTER,
	MONSTER_BOSS,
	ROUND_SPECIAL_SPEED,
	MONSTER_SPECIAL,
	ROUND_SPECIAL_STRENGTH
};

enum _:LogrosStruct {
    logroName[64],
    logroDesc[256],
    logroReward,
    logroClass,
	logroUsersNeed
};

enum _:LogrosClass {
	LOGRO_GENERALES = 0,
	LOGRO_OLEADAS,
	LOGRO_MAPAS,
	LOGRO_BETA,
	LOGRO_BOSSES,
	LOGRO_PODERES,
	
	LOGRO_CLASS_MAX
};

new const LOGROS_CLASS[][] = {"GENERALES", "OLEADAS", "MAPAS", "BETA", "JEFES", "PODERES"};
new const LOGROS_CLASS_IN[][] = {"GENERALES", "DE OLEADAS", "DE MAPAS", "DE LA BETA", "DE JEFES", "DE PODERES"};

new const LOGROS[LogrosInt][LogrosStruct] = {
	{"BETA TESTER", "Jugar en la BETA del TD v1.0", 1, LOGRO_BETA, 0},
	{"BETA TESTER AVANZADO", "Subir hasta nivel 9G! en la BETA del TD v1.0", 1, LOGRO_BETA, 0}, 
	{"NIVEL 10G!", "Alcanza el nivel 10G!", 1, LOGRO_GENERALES, 0},
	{"NIVEL 20G!", "Alcanza el nivel 20G!", 2, LOGRO_GENERALES, 0},
	{"NIVEL 30G!", "Alcanza el nivel 30G!", 3, LOGRO_GENERALES, 0},
	{"NIVEL 40G!", "Alcanza el nivel 40G!", 4, LOGRO_GENERALES, 0},
	{"NIVEL 50G!", "Alcanza el nivel 50G!", 5, LOGRO_GENERALES, 0},
	{"NIVEL 60G!", "Alcanza el nivel 60G!", 6, LOGRO_GENERALES, 0},
	{"NIVEL 70G!", "Alcanza el nivel 70G!", 7, LOGRO_GENERALES, 0},
	{"NIVEL 80G!", "Alcanza el nivel 80G!", 8, LOGRO_GENERALES, 0},
	{"NIVEL 90G!", "Alcanza el nivel 90G!", 9, LOGRO_GENERALES, 0},
	{"NIVEL 100G!", "Alcanza el nivel 100G!", 10, LOGRO_GENERALES, 0},
	{"100 OLEADAS N", "Supera 100 oleadas en dificultad \yNORMAL", 1, LOGRO_OLEADAS, 0},
	{"500 OLEADAS N", "Supera 500 oleadas en dificultad \yNORMAL", 1, LOGRO_OLEADAS, 0},
	{"1.000 OLEADAS N", "Supera 1.000 oleadas en dificultad \yNORMAL", 2, LOGRO_OLEADAS, 0},
	{"2.500 OLEADAS N", "Supera 2.500 oleadas en dificultad \yNORMAL", 2, LOGRO_OLEADAS, 0},
	{"5.000 OLEADAS N", "Supera 5.000 oleadas en dificultad \yNORMAL", 3, LOGRO_OLEADAS, 0},
	{"10.000 OLEADAS N", "Supera 10.000 oleadas en dificultad \yNORMAL", 3, LOGRO_OLEADAS, 0},
	{"25.000 OLEADAS N", "Supera 25.000 oleadas en dificultad \yNORMAL", 4, LOGRO_OLEADAS, 0},
	{"50.000 OLEADAS N", "Supera 50.000 oleadas en dificultad \yNORMAL", 4, LOGRO_OLEADAS, 0},
	{"100.000 OLEADAS N", "Supera 100.000 oleadas en dificultad \yNORMAL", 5, LOGRO_OLEADAS, 0},
	{"250.000 OLEADAS N", "Supera 250.000 oleadas en dificultad \yNORMAL", 5, LOGRO_OLEADAS, 0},
	{"500.000 OLEADAS N", "Supera 500.000 oleadas en dificultad \yNORMAL", 6, LOGRO_OLEADAS, 0},
	{"1.000.000 DE OLEADAS N", "Supera 1.000.000 de oleadas en dificultad \yNORMAL", 10, LOGRO_OLEADAS, 0},
	{"NOOB EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kmid_v2", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kmid_v2", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kmid_v2", 3, LOGRO_MAPAS, 0},
	{"PRO EN KMID", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kmid_v2", 4, LOGRO_MAPAS, 0},
	{"NOOB EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_orange", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_orange", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_orange", 3, LOGRO_MAPAS, 0},
	{"PRO EN ORANGE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_orange", 4, LOGRO_MAPAS, 0},
	{"NOOB EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kwool_small", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kwool_small", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kwool_small", 3, LOGRO_MAPAS, 0},
	{"PRO EN KWOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kwool_small", 4, LOGRO_MAPAS, 0},
	{"NOOB EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kwhite", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kwhite", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kwhite", 3, LOGRO_MAPAS, 0},
	{"PRO EN KWHITE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kwhite", 4, LOGRO_MAPAS, 0},
	{"NOOB EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_plaza2", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_plaza2", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_plaza2", 3, LOGRO_MAPAS, 0},
	{"PRO EN PLAZA", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_plaza2", 4, LOGRO_MAPAS, 0},
	{"TUTORIAL", "Lee el tutorial básico del juego", 1, LOGRO_GENERALES, 0},
	{"100 OLEADAS NN", "Supera 100 oleadas en dificultad \yNIGHTMARE", 3, LOGRO_OLEADAS, 0},
	{"500 OLEADAS NN", "Supera 500 oleadas en dificultad \yNIGHTMARE", 3, LOGRO_OLEADAS, 0},
	{"1.000 OLEADAS NN", "Supera 1.000 oleadas en dificultad \yNIGHTMARE", 4, LOGRO_OLEADAS, 0},
	{"2.500 OLEADAS NN", "Supera 2.500 oleadas en dificultad \yNIGHTMARE", 4, LOGRO_OLEADAS, 0},
	{"5.000 OLEADAS NN", "Supera 5.000 oleadas en dificultad \yNIGHTMARE", 5, LOGRO_OLEADAS, 0},
	{"10.000 OLEADAS NN", "Supera 10.000 oleadas en dificultad \yNIGHTMARE", 5, LOGRO_OLEADAS, 0},
	{"25.000 OLEADAS NN", "Supera 25.000 oleadas en dificultad \yNIGHTMARE", 6, LOGRO_OLEADAS, 0},
	{"50.000 OLEADAS NN", "Supera 50.000 oleadas en dificultad \yNIGHTMARE", 6, LOGRO_OLEADAS, 0},
	{"100.000 OLEADAS NN", "Supera 100.000 oleadas en dificultad \yNIGHTMARE", 7, LOGRO_OLEADAS, 0},
	{"250.000 OLEADAS NN", "Supera 250.000 oleadas en dificultad \yNIGHTMARE", 7, LOGRO_OLEADAS, 0},
	{"500.000 OLEADAS NN", "Supera 500.000 oleadas en dificultad \yNIGHTMARE", 8, LOGRO_OLEADAS, 0},
	{"1.000.000 DE OLEADAS NN", "Supera 1.000.000 de oleadas en dificultad \yNIGHTMARE", 15, LOGRO_OLEADAS, 0},
	{"100 OLEADAS S", "Supera 100 oleadas en dificultad \ySUICIDAL", 5, LOGRO_OLEADAS, 0},
	{"500 OLEADAS S", "Supera 500 oleadas en dificultad \ySUICIDAL", 5, LOGRO_OLEADAS, 0},
	{"1.000 OLEADAS S", "Supera 1.000 oleadas en dificultad \ySUICIDAL", 6, LOGRO_OLEADAS, 0},
	{"2.500 OLEADAS S", "Supera 2.500 oleadas en dificultad \ySUICIDAL", 6, LOGRO_OLEADAS, 0},
	{"5.000 OLEADAS S", "Supera 5.000 oleadas en dificultad \ySUICIDAL", 7, LOGRO_OLEADAS, 0},
	{"10.000 OLEADAS S", "Supera 10.000 oleadas en dificultad \ySUICIDAL", 7, LOGRO_OLEADAS, 0},
	{"25.000 OLEADAS S", "Supera 25.000 oleadas en dificultad \ySUICIDAL", 8, LOGRO_OLEADAS, 0},
	{"50.000 OLEADAS S", "Supera 50.000 oleadas en dificultad \ySUICIDAL", 8, LOGRO_OLEADAS, 0},
	{"100.000 OLEADAS S", "Supera 100.000 oleadas en dificultad \ySUICIDAL", 9, LOGRO_OLEADAS, 0},
	{"250.000 OLEADAS S", "Supera 250.000 oleadas en dificultad \ySUICIDAL", 9, LOGRO_OLEADAS, 0},
	{"500.000 OLEADAS S", "Supera 500.000 oleadas en dificultad \ySUICIDAL", 15, LOGRO_OLEADAS, 0},
	{"1.000.000 DE OLEADAS S", "Supera 1.000.000 de oleadas en dificultad \ySUICIDAL", 30, LOGRO_OLEADAS, 0},
	{"100 OLEADAS H", "Supera 100 oleadas en dificultad \yHELL", 10, LOGRO_OLEADAS, 0},
	{"500 OLEADAS H", "Supera 500 oleadas en dificultad \yHELL", 15, LOGRO_OLEADAS, 0},
	{"1.000 OLEADAS H", "Supera 1.000 oleadas en dificultad \yHELL", 20, LOGRO_OLEADAS, 0},
	{"2.500 OLEADAS H", "Supera 2.500 oleadas en dificultad \yHELL", 25, LOGRO_OLEADAS, 0},
	{"5.000 OLEADAS H", "Supera 5.000 oleadas en dificultad \yHELL", 30, LOGRO_OLEADAS, 0},
	{"10.000 OLEADAS H", "Supera 10.000 oleadas en dificultad \yHELL", 35, LOGRO_OLEADAS, 0},
	{"25.000 OLEADAS H", "Supera 25.000 oleadas en dificultad \yHELL", 40, LOGRO_OLEADAS, 0},
	{"50.000 OLEADAS H", "Supera 50.000 oleadas en dificultad \yHELL", 45, LOGRO_OLEADAS, 0},
	{"100.000 OLEADAS H", "Supera 100.000 oleadas en dificultad \yHELL", 50, LOGRO_OLEADAS, 0},
	{"250.000 OLEADAS H", "Supera 250.000 oleadas en dificultad \yHELL", 100, LOGRO_OLEADAS, 0},
	{"500.000 OLEADAS H", "Supera 500.000 oleadas en dificultad \yHELL", 200, LOGRO_OLEADAS, 0},
	{"1.000.000 DE OLEADAS H", "Supera 1.000.000 de oleadas en dificultad \yHELL", 500, LOGRO_OLEADAS, 0},
	{"POBRE", "Acumula 10K de Oro", 1, LOGRO_GENERALES, 0},
	{"SUELDO EN MANO", "Acumula 50K de Oro", 3, LOGRO_GENERALES, 0},
	{"DINERITO", "Acumula 100K de Oro", 5, LOGRO_GENERALES, 0},
	{"BILLETÍN BILLETÍN", "Acumula 500K de Oro", 7, LOGRO_GENERALES, 0},
	{"MONETARIO", "Acumula 1M de Oro", 9, LOGRO_GENERALES, 0},
	{"RICO", "Acumula 2.5M de Oro", 11, LOGRO_GENERALES, 0},
	{"EMPRENDEDOR", "Acumula 5M de Oro", 13, LOGRO_GENERALES, 0},
	{"PRÓSPERO", "Acumula 10M de Oro", 15, LOGRO_GENERALES, 0},
	{"ACOMODADO", "Acumula 25M de Oro", 17, LOGRO_GENERALES, 0},
	{"ADINERADO", "Acumula 50M de Oro", 19, LOGRO_GENERALES, 0},
	{"ACAUDALADO", "Acumula 100M de Oro", 21, LOGRO_GENERALES, 0},
	{"HACENDADO", "Acumula 500M de Oro", 23, LOGRO_GENERALES, 0},
	{"MILLONARIO", "Acumula 1.000M de Oro", 25, LOGRO_GENERALES, 0},
	{"PRIMERO", "Consigue 1 MVP", 1, LOGRO_GENERALES, 3},
	{"DIEZ VECES EN PRIMER LUGAR", "Consigue 10 MVP", 2, LOGRO_GENERALES, 3},
	{"1/4", "Consigue 25 MVP", 3, LOGRO_GENERALES, 3},
	{"MEJORANDO", "Consigue 50 MVP", 4, LOGRO_GENERALES, 3},
	{"EL MEJORCITO", "Consigue 100 MVP", 5, LOGRO_GENERALES, 3},
	{"UNO DE LOS MEJORES", "Consigue 250 MVP", 6, LOGRO_GENERALES, 3},
	{"EL MEJOR", "Consigue 500 MVP", 7, LOGRO_GENERALES, 3},
	{"SIN DUDAS, EL MEJOR", "Consigue 1.000 MVP", 8, LOGRO_GENERALES, 3},
	{"EL MEJOR, LEJOS", "Consigue 2.500 MVP", 10, LOGRO_GENERALES, 3},
	{"POR ALLÁ ARRIBA", "Consigue 5.000 MVP", 12, LOGRO_GENERALES, 3},
	{"EN EL CIELO", "Consigue 10.000 MVP", 14, LOGRO_GENERALES, 3},
	{"SUPERIOR", "Consigue 25.000 MVP", 16, LOGRO_GENERALES, 3},
	{"SUPERIOR A TODOS", "Consigue 50.000 MVP", 18, LOGRO_GENERALES, 3},
	{"FAR FAR AWAY", "Consigue 100.000 MVP", 20, LOGRO_GENERALES, 3},
	{"MVP", "Consigue 250.000 MVP", 22, LOGRO_GENERALES, 3},
	{"MOST VALUABLE PLAYER", "Consigue 500.000 MVP", 25, LOGRO_GENERALES, 3},
	{"EL REY", "Consigue 1.000.000 MVP", 30, LOGRO_GENERALES, 3},
	{"VINCULADO", "Vincula tu cuenta del TD con la del foro", 5, LOGRO_GENERALES, 0},
	{"NOOB EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_gempire", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_gempire", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_gempire", 3, LOGRO_MAPAS, 0},
	{"PRO EN GEMPIRE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_gempire", 4, LOGRO_MAPAS, 0},
	{"2 EN LÍNEA", "Consigue 2 MVP seguidos", 4, LOGRO_GENERALES, 3},
	{"3 EN LÍNEA", "Consigue 3 MVP seguidos", 7, LOGRO_GENERALES, 3},
	{"4 EN LÍNEA", "Consigue 4 MVP seguidos", 10, LOGRO_GENERALES, 3},
	{"5 EN LÍNEA", "Consigue 5 MVP seguidos", 13, LOGRO_GENERALES, 3},
	{"6 EN LÍNEA", "Consigue 6 MVP seguidos", 16, LOGRO_GENERALES, 3},
	{"7 EN LÍNEA", "Consigue 7 MVP seguidos", 19, LOGRO_GENERALES, 3},
	{"8 EN LÍNEA", "Consigue 8 MVP seguidos", 24, LOGRO_GENERALES, 3},
	{"9 EN LÍNEA", "Consigue 9 MVP seguidos", 30, LOGRO_GENERALES, 3},
	{"10 EN LÍNEA", "Consigue 10 MVP seguidos", 50, LOGRO_GENERALES, 3},
	{"COMPRADOR COMPULSIVO", "Desbloquea las clases APOYO, PESADO, ASALTO y COMANDANTE", 10, LOGRO_GENERALES, 0},
	{"NOOB EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_khell_v2", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_khell_v2", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_khell_v2", 3, LOGRO_MAPAS, 0},
	{"PRO EN KHELL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_khell_v2", 4, LOGRO_MAPAS, 0},
	{"GORILA NOOB", "Sobrevive al jefe final \yGORILA\w en dificultad \yNORMAL\w", 1, LOGRO_BOSSES, 0},
	{"GORILA AVANZADO", "Sobrevive al jefe final \yGORILA\w en dificultad \yNIGHTMARE\w", 2, LOGRO_BOSSES, 0},
	{"GORILA EXPERTO", "Sobrevive al jefe final \yGORILA\w en dificultad \ySUICIDAL\w", 3, LOGRO_BOSSES, 0},
	{"GORILA PRO", "Sobrevive al jefe final \yGORILA\w en dificultad \yHELL\w", 4, LOGRO_BOSSES, 0},
	{"FIRE MONSTER NOOB", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \yNORMAL\w", 1, LOGRO_BOSSES, 0},
	{"FIRE MONSTER AVANZADO", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \yNIGHTMARE\w", 2, LOGRO_BOSSES, 0},
	{"FIRE MONSTER EXPERTO", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \ySUICIDAL\w", 3, LOGRO_BOSSES, 0},
	{"FIRE MONSTER PRO", "Sobrevive al jefe final \yFIRE MONSTER\w en dificultad \yHELL\w", 4, LOGRO_BOSSES, 0},
	{"NOOB EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_dark_night", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_dark_night", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_dark_night", 3, LOGRO_MAPAS, 0},
	{"PRO EN DARK NIGHT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_dark_night", 4, LOGRO_MAPAS, 0},
	{"DEFENSA ABSOLUTA NOOB", "Gana la oleada 10 en dificultad \yNORMAL\w^nsin que la torre reciba daño en ninguna oleada", 1, LOGRO_GENERALES, 0},
	{"DEFENSA ABSOLUTA AVANZADO", "Gana la oleada 10 en dificultad \yNIGHTMARE\w^nsin que la torre reciba daño en ninguna oleada", 5, LOGRO_GENERALES, 0},
	{"DEFENSA ABSOLUTA EXPERTO", "Gana la oleada 10 en dificultad \ySUICIDAL\w^nsin que la torre reciba daño en ninguna oleada", 10, LOGRO_GENERALES, 0},
	{"DEFENSA ABSOLUTA PRO", "Gana la oleada 10 en dificultad \yHELL\w^nsin que la torre reciba daño en ninguna oleada", 20, LOGRO_GENERALES, 0},
	{"GUARDIÁN NOOB", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \yNORMAL\w", 5, LOGRO_BOSSES, 0},
	{"GUARDIÁN AVANZADO", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \yNIGHTMARE\w", 10, LOGRO_BOSSES, 0},
	{"GUARDIÁN EXPERTO", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \ySUICIDAL\w", 15, LOGRO_BOSSES, 0},
	{"GUARDIÁN PRO", "Sobrevive al jefe final \yGUARDIANES DE KYRA\w en dificultad \yHELL\w", 20, LOGRO_BOSSES, 0},
	{"TRAMPOSO", "Gana uno o más logros con trampa!", 5, LOGRO_GENERALES, 0},
	{"NOOB EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_kwool_x2", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_kwool_x2", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_kwool_x2", 3, LOGRO_MAPAS, 0},
	{"PRO EN KWOLOLO", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_kwool_x2", 4, LOGRO_MAPAS, 0},
	{"PODER: BALAS INFINITAS", "Mata al jefe \yGuardianes de Kyra\w en dificultad \yNORMAL", 1337, LOGRO_PODERES, 0},
	{"PODER: AIMBOT", "Logro deshabilitado por el desarrollador", 1338, LOGRO_PODERES, 0},
	{"NOOB EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_minecraft", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_minecraft", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_minecraft", 3, LOGRO_MAPAS, 0},
	{"PRO EN MINECRAFT", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_minecraft", 4, LOGRO_MAPAS, 0},
	{"NOOB EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_old_dust", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_old_dust", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_old_dust", 3, LOGRO_MAPAS, 0},
	{"PRO EN OLD DUST", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_old_dust", 4, LOGRO_MAPAS, 0},
	{"NOOB EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_city2", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_city2", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_city2", 3, LOGRO_MAPAS, 0},
	{"PRO EN CITY", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_city2", 4, LOGRO_MAPAS, 0},
	{"666", "666 monstruos", 2, LOGRO_GENERALES, 0},
	{"NOOB EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_castle_x2", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_castle_x2", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_castle_x2", 3, LOGRO_MAPAS, 0},
	{"PRO EN CASTLE", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_castle_x2", 4, LOGRO_MAPAS, 0},
	{"NOOB EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_ksub", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_ksub", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_ksub", 3, LOGRO_MAPAS, 0},
	{"PRO EN KSUB", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_ksub", 4, LOGRO_MAPAS, 0},
	{"KSUB - DIE", "Muere de una manera horrible en el mapa \ytd_ksub\w o \ytd_ksub_wool", 2, LOGRO_MAPAS, 0},
	{"BAILE CON EL FIRE MONSTER", "Baila con el jefe final \yFIRE MONSTER", 5, LOGRO_BOSSES, 0},
	{"FIRE MONSTER - POR UN PELO", "Durante el encuentro con el jefe final \yFIRE MONSTER\w,^nesquiva el poder de la \y'carga'\w por un pelo", 5, LOGRO_BOSSES, 0},
	{"NOOB EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNORMAL\w en el mapa \ytd_ksub_wool", 1, LOGRO_MAPAS, 0},
	{"AVANZADO EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yNIGHTMARE\w en el mapa \ytd_ksub_wool", 2, LOGRO_MAPAS, 0},
	{"EXPERTO EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \ySUICIDAL\w en el mapa \ytd_ksub_wool", 3, LOGRO_MAPAS, 0},
	{"PRO EN KSUB WOOL", "Sobrevive a la oleada 10 y al jefe final^nen dificultad \yHELL\w en el mapa \ytd_ksub_wool", 4, LOGRO_MAPAS, 0},
	{"FALLEN TITAN NOOB", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \yNORMAL\w", 1, LOGRO_BOSSES, 0},
	{"FALLEN TITAN AVANZADO", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \yNIGHTMARE\w", 2, LOGRO_BOSSES, 0},
	{"FALLEN TITAN EXPERTO", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \ySUICIDAL\w", 3, LOGRO_BOSSES, 0},
	{"FALLEN TITAN PRO", "Sobrevive al jefe final \yFALLEN TITAN\w en dificultad \yHELL\w", 4, LOGRO_BOSSES, 0},
	{"GOLPEADO POR UN TITÁN", "Consigue ser golpeado por el jefe final \yFALLEN TITAN\w^nmientras hace el poder de la \y'carga'\w contra alguien", 3, LOGRO_BOSSES, 0},
	{"PISTOLERO", "Acierta 186 disparos con la^n\yDesert Eagle .50 AE\w sin desconectarte", 1339, LOGRO_GENERALES, 0},
	{"LA BONEASTE", "Se el primero en morir en el mini Jefe", 1, LOGRO_GENERALES, 4},
	{"NONE 00", "Logro deshabilitado", 1, LOGRO_MAPAS, 0},
	{"NONE 01", "Logro deshabilitado", 2, LOGRO_MAPAS, 0},
	{"NONE 02", "Logro deshabilitado", 3, LOGRO_MAPAS, 0},
	{"NONE 03", "Logro deshabilitado", 4, LOGRO_MAPAS, 0}
};

new g_Achievement[MAX_USERS][LogrosInt];
new g_AchievementInt[MAX_USERS][LogrosInt];
new g_AchievementUnlock[MAX_USERS][LogrosInt];
new g_MenuPage[MAX_USERS][LOGRO_CLASS_MAX + 2];
new g_AchievementTrack_Pistolero[MAX_USERS];

enum _:ColorsEnum {
	C_RED = 0,
	C_GREEN,
	C_BLUE
};

enum _:MenuColorsStruct {
	colorName[20],
	colorRed,
	colorGreen,
	colorBlue
};

new const COLORS[][MenuColorsStruct] = {
	{"BLANCO", 255, 255, 255},
	{"ROJO", 255, 0, 0},
	{"VERDE", 0, 255, 0},
	{"AZUL", 0, 0, 255},
	{"AMARILLO", 255, 255, 0},
	{"VIOLETA", 255, 0, 255},
	{"CELESTE", 0, 255, 255},
	{"NARANJA", 255, 165, 0}
};

new g_Options_HUD_Color[MAX_USERS][ColorsEnum];

enum _:HabsId {
	HAB_DAMAGE,
	HAB_PRECISION,
	HAB_VELOCIDAD,
	HAB_BALAS
};

enum _:HabsFId {
	Float:HAB_F_DAMAGE,
	Float:HAB_F_PRECISION,
	Float:HAB_F_VELOCIDAD
};

enum _:habilitiesStruct {
	habName[32],
	habDesc[128],
	habMaxLevel,
	Float:habValue
};

new const HABILITIES[HabsId][habilitiesStruct] = {
	{"DAÑO", "Otorga daño extra a todas tus armas!", 50, 2.0},
	{"PRECISIÓN AL DISPARAR", "Aumenta tu precisión de disparo con armas!", 20, 1.25},
	{"VELOCIDAD AL DISPARAR", "Aumenta tu velocidad de disparo con armas!", 20, 1.25},
	{"BALAS", "Otorga balas extras a todas tus armas!", 10, 10.0}
};

new g_Hab[MAX_USERS][HabsId];
new Float:g_HabCache[MAX_USERS][HabsFId];
new g_HabCacheClip[MAX_USERS];

enum _:classIds {
	CLASS_SOLDADO = 0,
	CLASS_INGENIERO,
	CLASS_SOPORTE,
	CLASS_FRANCOTIRADOR,
	CLASS_APOYO,
	CLASS_PESADO,
	CLASS_ASALTO,
	CLASS_COMANDANTE,
	CLASS_PISTOLERO,
	CLASS_PUBERO,
	CLASS_LEGIONARIO,
	CLASS_BITERO,
	CLASS_SCOUTER
};

enum _:classesStruct {
	className[32],
	classDesc[135],
	classDescLv1[71],
	classDescLv2[73],
	classDescLv3[73],
	classDescLv4[118],
	classDescLv5[177],
	classDescLv6[225],
	classReqLv1,
	classReqLv2,
	classReqLv3,
	classReqLv4,
	classReqLv5,
	classReqLv6,
	classReqLv7
};

new const CLASSES[classIds][classesStruct] = {
	{	"SOLDADO", // KILLS
		"\wEfectivo con \yM4A1 Carbine\w y \yAK-47 Kalashnikov",
		"\r* \y+5% \wVELOCIDAD AL DISPARAR^n\r* \y+6% \wPRECISIÓN AL DISPARAR",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR^n\r* \y+12% \wPRECISIÓN AL DISPARAR",
		"\r* \y+15% \wVELOCIDAD AL DISPARAR^n\r* \y+18% \wPRECISIÓN AL DISPARAR",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR^n\r* \y+24% \wPRECISIÓN AL DISPARAR^n^n\r* \y+5 \wBALAS AL CARGADOR",
		"\r* \y+25% \wVELOCIDAD AL DISPARAR^n\r* \y+30% \wPRECISIÓN AL DISPARAR^n^n\r* \y+10 \wBALAS AL CARGADOR",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \y+40% \wPRECISIÓN AL DISPARAR^n^n\r* \y+10 \wBALAS AL CARGADOR^n\r* \wCOMIENZA CON \yM4A1 CARABINE\w",
		1000, 5000, 10000, 25000, 50000, 100000, 2100999999
	},
	{	"INGENIERO", // DAÑO CON TORRETAS
		"\wEl daño de sus torretas generan \yOro\w para el creador",
		"\r* \y+7% \wDAÑO DE TORRETAS^n\r* \y+5% \wPRECISIÓN DE TORRETAS",
		"\r* \y+14% \wDAÑO DE TORRETAS^n\r* \y+10% \wPRECISIÓN DE TORRETAS",
		"\r* \y+21% \wDAÑO DE TORRETAS^n\r* \y+15% \wPRECISIÓN DE TORRETAS",
		"\r* \y+28% \wDAÑO DE TORRETAS^n\r* \y+20% \wPRECISIÓN DE TORRETAS^n^n\r* \y+500 \wBALAS AL CARGADOR DE LAS TORRETAS",
		"\r* \y+35% \wDAÑO DE TORRETAS^n\r* \y+25% \wPRECISIÓN DE TORRETAS^n^n\r* \y+500 \wBALAS AL CARGADOR DE LAS TORRETAS^n\r* \wPuede subir a \ynivel 4\w cualquier torreta",
		"\r* \y+45% \wDAÑO DE TORRETAS^n\r* \y+30% \wPRECISIÓN DE TORRETAS^n^n\r* \y+1.000 \wBALAS AL CARGADOR DE LAS TORRETAS^n\r* \wPuede subir a \ynivel 5\w cualquier torreta^n\r* \wCOMIENZA CON UNA \yTORRETA\w",
		500000, 1500000, 3000000, 5000000, 7500000, 12500000, 2100999999
	},
	{	"SOPORTE", // DAÑO
		"\wEfectivo con \yXM1014 M4\w^nSu daño \ycon la escopeta\w no se ve reducido^nfrente a los monstruos con protección",
		"\r* \y+5% \wVELOCIDAD AL DISPARAR^n\r* \y+3 \wBALAS AL CARGADOR",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR^n\r* \y+6 \wBALAS AL CARGADOR",
		"\r* \y+15% \wVELOCIDAD AL DISPARAR^n\r* \y+9 \wBALAS AL CARGADOR",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR^n\r* \y+12 \wBALAS AL CARGADOR^n^n\r* \wCOMIENZA CON \y200 ORO\w EXTRA",
		"\r* \y+25% \wVELOCIDAD AL DISPARAR^n\r* \y+15 \wBALAS AL CARGADOR^n^n\r* \wCOMIENZA CON \y200 ORO\w EXTRA^n\r* \wPUEDE RECARGAR SU ARMA INSTANTÁNEAMENTE \yUNA VEZ\w POR OLEADA",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \y+18 \wBALAS AL CARGADOR^n^n\r* \wCOMIENZA CON \y200 ORO\w EXTRA^n\r* \wPUEDE RECARGAR SU ARMA INSTANTÁNEAMENTE \yUNA VEZ\w POR OLEADA^n\r* \wRECIBE MENOS DAÑO DE \yLOS HUEVECILLOS\w",
		500000, 1500000, 3500000, 7500000, 15000000, 25000000, 2100999999
	},
	{	"FRANCOTIRADOR", // DAÑO
		"\wEfectivo con \yAWP Magnum Sniper",
		"\r* \y+15% \wPRECISIÓN AL DISPARAR",
		"\r* \y+30% \wPRECISIÓN AL DISPARAR",
		"\r* \y+45% \wPRECISIÓN AL DISPARAR",
		"\r* \y+60% \wPRECISIÓN AL DISPARAR^n\r* \y+15% \wVELOCIDAD AL DISPARAR^n^n\r* \wCOMIENZA CON \yGRANADA SG",
		"\r* \y+75% \wPRECISIÓN AL DISPARAR^n\r* \y+25% \wVELOCIDAD AL DISPARAR^n^n\r* \wCOMIENZA CON \yGRANADA SG",
		"\r* \yPRECISIÓN PREFECTA^n\r* \y+35% \wVELOCIDAD AL DISPARAR^n^n\r* \wCOMIENZA CON \yGRANADA SG^n\r* \y+15 \wBALAS AL CARGADOR^n\r* \wTUS DISPAROS AL \yGORDO BOMBA\w SON \yCRÍTICOS\w",
		500000, 1000000, 3000000, 6000000, 10000000, 17500000, 2100999999
	},
	{	"APOYO", // DAÑO
		"\wEfectivo con \yM3 Super 90\w y \yMP5 Navy",
		"\r* \y+5% \wVELOCIDAD AL DISPARAR",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR",
		"\r* \y+15% \wVELOCIDAD AL DISPARAR^n\r* \y+12% \wDAÑO",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR^n\r* \y+24% \wDAÑO",
		"\r* \y+25% \wVELOCIDAD AL DISPARAR^n\r* \y+36% \wDAÑO",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \y+50% \wDAÑO",
		500000, 1500000, 3000000, 6000000, 10000000, 17500000, 2100999999
	},
	{	"PESADO", // DAÑO
		"\wEfectivo con \yM249 Para Machinegun",
		"\r* \y+15% \wPRECISIÓN AL DISPARAR",
		"\r* \y+30% \wPRECISIÓN AL DISPARAR",
		"\r* \y+45% \wPRECISIÓN AL DISPARAR",
		"\r* \y+60% \wPRECISIÓN AL DISPARAR^n\r* \y+5% \wVELOCIDAD AL DISPARAR",
		"\r* \y+75% \wPRECISIÓN AL DISPARAR^n\r* \y+10% \wVELOCIDAD AL DISPARAR",
		"\r* \yPRECISIÓN PREFECTA^n\r* \y+15% \wVELOCIDAD AL DISPARAR^n^n\r* \wCOMIENZA CON \yRAYO",
		1000000, 3000000, 6000000, 10000000, 17500000, 25000000, 2100999999
	},
	{	"ASALTO", // KILLS
		"\wEfectivo con \yFamas\w y \yIMI Galil",
		"\r* \y+15% \wPRECISIÓN AL DISPARAR",
		"\r* \y+30% \wPRECISIÓN AL DISPARAR",
		"\r* \y+45% \wPRECISIÓN AL DISPARAR",
		"\r* \y+60% \wPRECISIÓN AL DISPARAR^n\r* \y+12% \wDAÑO",
		"\r* \y+75% \wPRECISIÓN AL DISPARAR^n\r* \y+24% \wDAÑO",
		"\r* \yPRECISIÓN PREFECTA^n\r* \y+36% \wDAÑO^n^n\r* \wCOMIENZA CON \yIMI Galil\w",
		1000, 5000, 10000, 30000, 60000, 120000, 2100999999
	},
	{	"COMANDANTE", // KILLS
		"\wEfectivo con \ySteyr AUG A1\w y \ySG-552 Commando",
		"\r* \y+5% \wVELOCIDAD AL DISPARAR",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR",
		"\r* \y+15% \wVELOCIDAD AL DISPARAR",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR^n\r* \y+12% \wDAÑO",
		"\r* \y+25% \wVELOCIDAD AL DISPARAR^n\r* \y+24% \wDAÑO",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \y+36% \wDAÑO^n^n\r* \wCOMIENZA CON \ySteyr AUG A1\w",
		1150, 5300, 10450, 30600, 60750, 121000, 2100999999
	},
	{	"PISTOLERO", // DISPAROS ACERTADOS
		"\wEfectivo con \yDesert Eagle .50 AE\w",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \y+20% \wDAÑO",
		"\r* \y+40% \wVELOCIDAD AL DISPARAR^n\r* \y+40% \wDAÑO",
		"\r* \y+50% \wVELOCIDAD AL DISPARAR^n\r* \y+75% \wDAÑO",
		"\r* \y+75% \wVELOCIDAD AL DISPARAR^n\r* \y+100% \wDAÑO^n^n\r* \wBALAS INFINITAS Y DISPARO AUTOMATICO\w",
		22222, 44444, 66666, 88888, 111110, 133332, 2100999999
	},
	{	"PUBERO", // DAÑO
		"\wEfectivo con \ySG-550 Auto-Sniper\w y \yG3SG1 Auto-Sniper",
		"\r* \y+15% \wPRECISIÓN AL DISPARAR",
		"\r* \y+30% \wPRECISIÓN AL DISPARAR",
		"\r* \y+45% \wPRECISIÓN AL DISPARAR",
		"\r* \y+60% \wPRECISIÓN AL DISPARAR^n^n\r* \y+6 \wBALAS AL CARGADOR",
		"\r* \y+75% \wPRECISIÓN AL DISPARAR^n^n\r* \y+12 \wBALAS AL CARGADOR",
		"\r* \yPRECISIÓN PREFECTA^n^n\r* \y+18 \wBALAS AL CARGADOR^n\r* \wCOMIENZA CON \yG3SG1 Auto-Sniper\w^n\r* \y+10% \wCHANCE DE CRÍTICO",
		1000000, 3000000, 6000000, 10000000, 17500000, 25000000, 2100999999
	},
	{	"LEGIONARIO", // DAÑO
		"\wEfectivo con \yES P90\w",
		"\r* \y+5% \wVELOCIDAD AL DISPARAR^n\r* \y+15% \wPRECISIÓN AL DISPARAR",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR^n\r* \y+30% \wPRECISIÓN AL DISPARAR",
		"\r* \y+15% \wVELOCIDAD AL DISPARAR^n\r* \y+45% \wPRECISIÓN AL DISPARAR",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR^n\r* \y+60% \wPRECISIÓN AL DISPARAR^n^n\r* \y+3% \wCHANCE DE CRÍTICO",
		"\r* \y+25% \wVELOCIDAD AL DISPARAR^n\r* \y+75% \wPRECISIÓN AL DISPARAR^n^n\r* \y+6% \wCHANCE DE CRÍTICO",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \yPRECISIÓN PREFECTA^n^n\r* \y+10% \wCHANCE DE CRÍTICO^n\r* \wCARGADORES INFINITOS\w",
		500000, 1500000, 3000000, 6000000, 10000000, 17500000, 2100999999
	},
	{	"BITERO", // KILLS
		"\wEfectivo con \yIngram MAC-10\w y \ySchmidt TMP\w",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR^n\r* \y+15% \wPRECISIÓN AL DISPARAR",
		"\r* \y+15% \wVELOCIDAD AL DISPARAR^n\r* \y+30% \wPRECISIÓN AL DISPARAR",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR^n\r* \y+45% \wPRECISIÓN AL DISPARAR",
		"\r* \y+25% \wVELOCIDAD AL DISPARAR^n\r* \y+60% \wPRECISIÓN AL DISPARAR^n^n\r* \y+12% \wDAÑO",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \y+75% \wPRECISIÓN AL DISPARAR^n^n\r* \y+24% \wDAÑO",
		"\r* \y+40% \wVELOCIDAD AL DISPARAR^n\r* \yPRECISIÓN PREFECTA^n^n\r* \y+36% \wDAÑO^n\r* \wBALAS INFINITAS CON LAS ARMAS EFECTIVAS\w",
		100, 187, 375, 750, 1500, 3125, 2100999999
	},
	{	"SCOUTER", // DAÑO
		"\wEfectivo con \ySchmidt Scout\w",
		"\r* \y+10% \wVELOCIDAD AL DISPARAR^n\r* \y+15% \wPRECISIÓN AL DISPARAR",
		"\r* \y+15% \wVELOCIDAD AL DISPARAR^n\r* \y+30% \wPRECISIÓN AL DISPARAR",
		"\r* \y+20% \wVELOCIDAD AL DISPARAR^n\r* \y+45% \wPRECISIÓN AL DISPARAR",
		"\r* \y+25% \wVELOCIDAD AL DISPARAR^n\r* \y+60% \wPRECISIÓN AL DISPARAR^n^n\r* \y+6 \wBALAS AL CARGADOR",
		"\r* \y+30% \wVELOCIDAD AL DISPARAR^n\r* \y+75% \wPRECISIÓN AL DISPARAR^n^n\r* \y+12 \wBALAS AL CARGADOR",
		"\r* \y+40% \wVELOCIDAD AL DISPARAR^n\r* \yPRECISIÓN PREFECTA^n^n\r* \y+18 \wBALAS AL CARGADOR^n\r* \wPODER: DISPARO VELOZ POR 10 SEG\w",
		500000, 1500000, 3000000, 6000000, 10000000, 17500000, 2100999999
	}
};

new const CLASSES_WEAPONS[classIds][2] = {
	{CSW_M4A1, CSW_AK47},
	{CSW_C4, CSW_C4},
	{CSW_XM1014, CSW_C4},
	{CSW_AWP, CSW_C4},
	{CSW_M3, CSW_MP5NAVY},
	{CSW_M249, CSW_C4},
	{CSW_FAMAS, CSW_GALIL},
	{CSW_AUG, CSW_SG552},
	{CSW_DEAGLE, CSW_C4},
	{CSW_SG550, CSW_G3SG1},
	{CSW_P90, CSW_C4},
	{CSW_MAC10, CSW_TMP},
	{CSW_SCOUT, CSW_C4}
};

enum _:classesAttribStruct {
	Float:classAttrib_Speed,
	Float:classAttrib_Recoil,
	classAttrib_Clip,
	Float:classAttrib_Damage,
	Float:classAttrib_Sentry_Damage,
	Float:classAttrib_Sentry_Recoil,
	classAttrib_Sentry_Clip,
	classAttrib_ExtraCrit
};

new const CLASSES_ATTRIB[classIds][7][classesAttribStruct] = {
	// SOLDADO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{5.0, 			6.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{10.0, 			12.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{15.0, 			18.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{20.0, 			24.0, 		5,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{25.0, 			30.0, 		10,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{30.0, 			40.0, 		10,			0.0,		0.0,			0.0,				0,				0} 	// LV 6
	}, 
	// INGENIERO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{0.0, 			0.0, 		0,			0.0,		7.0,			5.0,				0,				0}, // LV 1
		{0.0, 			0.0, 		0,			0.0,		14.0,			10.0,				0,				0}, // LV 2
		{0.0, 			0.0, 		0,			0.0,		21.0,			15.0,				0,				0}, // LV 3
		{0.0, 			0.0, 		0,			0.0,		28.0,			20.0,				500,			0}, // LV 4
		{0.0, 			0.0, 		0,			0.0,		35.0,			25.0,				500,			0}, // LV 5
		{0.0, 			0.0, 		0,			0.0,		45.0,			30.0,				1000,			0} 	// LV 6
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
		{15.0, 			60.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{25.0, 			75.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{35.0, 			100.0, 		15,			0.0,		0.0,			0.0,				0,				0} 	// LV 6
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
		{20.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{30.0, 			0.0, 		0,			20.0,		0.0,			0.0,				0,				0}, // LV 3
		{40.0, 			0.0, 		0,			40.0,		0.0,			0.0,				0,				0}, // LV 4
		{50.0, 			0.0, 		0,			75.0,		0.0,			0.0,				0,				0}, // LV 5
		{75.0, 			100.0, 		0,			100.0,		0.0,			0.0,				0,				25} // LV 6
	},
	// PUBERO
	{	// SPEED 		RECOIL		CLIP 		DAMAGE 		SENTRY_DMG 		SENTRY_RECOIL		SENTRY_CLIP 	EXTRA_CRIT
		{0.0, 			0.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 0
		{0.0, 			15.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 1
		{0.0, 			30.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 2
		{0.0, 			45.0, 		0,			0.0,		0.0,			0.0,				0,				0}, // LV 3
		{0.0, 			60.0, 		6,			0.0,		0.0,			0.0,				0,				0}, // LV 4
		{0.0, 			75.0, 		12,			0.0,		0.0,			0.0,				0,				0}, // LV 5
		{0.0, 			100.0, 		18,			0.0,		0.0,			0.0,				0,				10} 	// LV 6
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

new g_ClassLevel[MAX_USERS][classIds];
new g_ClassReqs[MAX_USERS][classIds];

enum _:LevelsStruct {
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

new const LEVELS_G[101][LevelsStruct] = {
	{25, 5, 0, 0, 0, 0, 0, 0, 0},
	{35, 10, 0, 0, 0, 0, 0, 0, 0},
	{50, 15, 0, 0, 0, 0, 0, 0, 0},
	{75, 20, 0, 0, 0, 0, 0, 0, 0},
	{100, 25, 0, 0, 0, 0, 0, 0, 0},
	{150, 30, 0, 0, 0, 0, 0, 0, 0},
	{200, 35, 0, 0, 0, 0, 0, 0, 0},
	{250, 40, 0, 0, 0, 0, 0, 0, 0},
	{300, 50, 0, 0, 0, 0, 0, 0, 0},
	{400, 60, 0, 0, 0, 1, 0, 0, 0},
	{500, 70, 0, 0, 0, 1, 0, 0, 0},
	{650, 80, 0, 0, 0, 1, 0, 0, 0},
	{800, 100, 0, 0, 0, 1, 0, 0, 0},
	{1000, 125, 0, 0, 0, 1, 0, 0, 0},
	{1250, 150, 0, 0, 0, 2, 0, 0, 0},
	{1500, 175, 0, 0, 0, 2, 0, 0, 0},
	{2000, 200, 0, 0, 0, 3, 0, 0, 0},
	{3000, 250, 0, 0, 0, 3, 0, 0, 0},
	{4500, 300, 0, 0, 0, 4, 0, 0, 0},
	{6000, 400, 0, 0, 0, 4, 0, 0, 0},
	{8000, 500, 0, 0, 0, 5, 0, 0, 0},
	{10000, 600, 0, 0, 0, 6, 0, 0, 0},
	{12500, 700, 0, 0, 0, 7, 0, 0, 0},
	{15000, 800, 0, 0, 0, 8, 0, 0, 0},
	{17500, 1000, 0, 0, 0, 10, 0, 0, 0},
	
	{20000, 0, 10, 0, 0, 0, 1, 0, 0},
	{22500, 0, 20, 0, 0, 0, 2, 0, 0},
	{25000, 0, 30, 0, 0, 0, 3, 0, 0},
	{27500, 0, 40, 0, 0, 0, 4, 0, 0},
	{30000, 0, 50, 0, 0, 0, 5, 0, 0},
	{32500, 0, 60, 0, 0, 0, 6, 0, 0},
	{35000, 0, 70, 0, 0, 0, 7, 0, 0},
	{37500, 0, 80, 0, 0, 0, 8, 0, 0},
	{40000, 0, 90, 0, 0, 0, 9, 0, 0},
	{42500, 0, 100, 0, 0, 0, 10, 0, 0},
	{45000, 0, 120, 0, 0, 0, 11, 0, 0},
	{47500, 0, 140, 0, 0, 0, 12, 0, 0},
	{50000, 0, 160, 0, 0, 0, 13, 0, 0},
	{52500, 0, 180, 0, 0, 0, 14, 0, 0},
	{55000, 0, 200, 0, 0, 0, 15, 0, 0},
	{57500, 0, 230, 0, 0, 0, 16, 0, 0},
	{60000, 0, 260, 0, 0, 0, 17, 0, 0},
	{62500, 0, 290, 0, 0, 0, 18, 0, 0},
	{65000, 0, 320, 0, 0, 0, 19, 0, 0},
	{67500, 0, 360, 0, 0, 0, 20, 0, 0},
	{70000, 0, 400, 0, 0, 0, 21, 0, 0},
	{72500, 0, 450, 0, 0, 0, 22, 0, 0},
	{75000, 0, 500, 0, 0, 0, 23, 0, 0},
	{77500, 0, 600, 0, 0, 0, 24, 0, 0},
	{80000, 0, 750, 0, 0, 0, 25, 0, 0},
	
	{83500, 0, 0, 15, 0, 0, 0, 6, 0},
	{87000, 0, 0, 30, 0, 0, 0, 7, 0},
	{90500, 0, 0, 45, 0, 0, 0, 8, 0},
	{94000, 0, 0, 60, 0, 0, 0, 9, 0},
	{97500, 0, 0, 75, 0, 0, 0, 10, 0},
	{101000, 0, 0, 90, 0, 0, 0, 11, 0},
	{104500, 0, 0, 115, 0, 0, 0, 12, 0},
	{108000, 0, 0, 130, 0, 0, 0, 13, 0},
	{111500, 0, 0, 145, 0, 0, 0, 14, 0},
	{115000, 0, 0, 160,0, 0, 0, 15, 0},
	{118500, 0, 0, 175,0, 0, 0, 16, 0},
	{122000, 0, 0, 190, 0, 0, 0, 17, 0},
	{125500, 0, 0, 230, 0, 0, 0, 18, 0},
	{129000, 0, 0, 260, 0, 0, 0, 19, 0},
	{132500, 0, 0, 290, 0, 0, 0, 20, 0},
	{136000, 0, 0, 320, 0, 0, 0, 21, 0},
	{140000, 0, 0, 360, 0, 0, 0, 22, 0},
	{144000, 0, 0, 400, 0, 0, 0, 23, 0},
	{148000, 0, 0, 450, 0, 0, 0, 24, 0},
	{152000, 0, 0, 500, 0, 0, 0, 25, 0},
	{156000, 0, 0, 600, 0, 0, 0, 26, 0},
	{160000, 0, 0, 700, 0, 0, 0, 27, 0},
	{170000, 0, 0, 800, 0, 0, 0, 28, 0},
	{180000, 0, 0, 900, 0, 0, 0, 29, 0},
	{190000, 0, 0, 1000, 0, 0, 0, 30, 0},
	
	{200000, 0, 0, 0, 10, 0, 0, 0, 1},
	{210000, 0, 0, 0, 20, 0, 0, 0, 2},
	{220000, 0, 0, 0, 30, 0, 0, 0, 3},
	{230000, 0, 0, 0, 40, 0, 0, 0, 4},
	{240000, 0, 0, 0, 50, 0, 0, 0, 5},
	{250000, 0, 0, 0, 60, 0, 0, 0, 6},
	{260000, 0, 0, 0, 70, 0, 0, 0, 7},
	{270000, 0, 0, 0, 80, 0, 0, 0, 8},
	{280000, 0, 0, 0, 90, 0, 0, 0, 9},
	{290000, 0, 0, 0, 100, 0, 0, 0, 10},
	{300000, 0, 0, 0, 125, 0, 0, 0, 11},
	{340000, 0, 0, 0, 150, 0, 0, 0, 12},
	{380000, 0, 0, 0, 175, 0, 0, 0, 13},
	{420000, 0, 0, 0, 200, 0, 0, 0, 14},
	{460000, 0, 0, 0, 250, 0, 0, 0, 15},
	{500000, 0, 0, 0, 300, 0, 0, 0, 16},
	{540000, 0, 0, 0, 350, 0, 0, 0, 17},
	{580000, 0, 0, 0, 400, 0, 0, 0, 18},
	{620000, 0, 0, 0, 500, 0, 0, 0, 19},
	{660000, 0, 0, 0, 600, 0, 0, 0, 20},
	{700000, 0, 0, 0, 700, 0, 0, 0, 21},
	{750000, 0, 0, 0, 800, 0, 0, 0, 22},
	{800000, 0, 0, 0, 900, 0, 0, 0, 23},
	{900000, 0, 0, 0, 1000, 0, 0, 0, 25},
	{1000000, 0, 0, 0, 2000, 0, 0, 0, 30},
	
	{2100000000, 0, 0, 0, 2100000000, 0, 0, 0, 2100000000}
};

enum _:difficultiesIds {
	DIFF_NORMAL = 0,
	DIFF_NIGHTMARE,
	DIFF_SUICIDAL,
	DIFF_HELL
};

new const difficultNames[difficultiesIds][] = {
	"NORMAL",
	"NIGHTMARE",
	"SUICIDAL",
	"HELL"
};

new g_WavesWins[MAX_USERS][difficultiesIds + 1][11];
new g_BossKills[MAX_USERS][difficultiesIds + 1];

enum _:Teams {
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
};

enum _:weaponStruct {
	weaponEnt[32],
	weaponName[32],
	weaponId,
	weaponGold,
	weaponClassRecommended,
	weaponPremium
};

new const WEAPON_NAMES[][weaponStruct] = {
	{"weapon_m4a1", "M4A1 Carbine", CSW_M4A1, 500, CLASS_SOLDADO, 0},
	{"weapon_ak47", "AK-47 Kalashnikov", CSW_AK47, 500, CLASS_SOLDADO, 0},
	{"weapon_awp", "AWP Magnum Sniper", CSW_AWP, 350, CLASS_FRANCOTIRADOR, 0},
	{"weapon_xm1014", "XM1014 M4", CSW_XM1014, 200, CLASS_SOPORTE, 0},
	{"weapon_m3", "M3 Super 90", CSW_M3, 200, CLASS_APOYO, 0},
	{"weapon_mp5navy", "MP5 Navy", CSW_MP5NAVY, 300, CLASS_APOYO, 0},
	{"weapon_m249", "M249 Para Machinegun", CSW_M249, 400, CLASS_PESADO, 0},
	{"weapon_famas", "Famas", CSW_FAMAS, 500, CLASS_ASALTO, 0},
	{"weapon_galil", "IMI Galil", CSW_GALIL, 500, CLASS_ASALTO, 0},
	{"weapon_aug", "Steyr AUG A1", CSW_AUG, 500, CLASS_COMANDANTE, 0},
	{"weapon_sg552", "SG-552 Commando", CSW_SG552, 500, CLASS_COMANDANTE, 0},
	{"weapon_g3sg1", "G3SG1 Auto-Sniper", CSW_G3SG1, 600, CLASS_PUBERO, 1},
	{"weapon_sg550", "SG-550 Auto-Sniper", CSW_SG550, 600, CLASS_PUBERO, 1},
	{"weapon_p90", "ES P90", CSW_P90, 400, CLASS_LEGIONARIO, 1},
	{"weapon_mac10", "Ingram MAC-10", CSW_MAC10, 200, CLASS_BITERO, 1},
	{"weapon_tmp", "Schmidt TMP", CSW_TMP, 200, CLASS_BITERO, 1},
	{"weapon_scout", "Schmidt Scout", CSW_SCOUT, 350, CLASS_SCOUTER, 1}// ,
	// {"weapon_deagle", "Desert Eagle .50", CSW_DEAGLE, 1000, CLASS_PISTOLERO, 0}
};

enum _:grenadesType {
	NADE_EXPLOSION = 0,
	NADE_REMUEVE_PROTECCION,
	NADE_AUMENTA_DMG_RECIBIDO,
	NADE_ION_BOMB
};

enum _:grenadesTypes (+= 1234) {
	NADE_TYPE_EXPLOSION = 12345,
	NADE_TYPE_REMUEVE_PROTECCION,
	NADE_TYPE_AUMENTA_DMG_RECIBIDO,
	NADE_TYPE_ION_BOMB
};

new g_Nades[MAX_USERS][grenadesType];

new const GRENADES_NAMES[grenadesType][weaponStruct] = {
	{"weapon_hegrenade", "HE: Explosión", CSW_HEGRENADE, 250},
	{"weapon_flashbang", "FB: Remueve protección", CSW_FLASHBANG, 20},
	{"weapon_smokegrenade", "SG: Aumenta el daño recibido", CSW_SMOKEGRENADE, 500},
	{"weapon_hegrenade", "HE: Bomba Ión", CSW_HEGRENADE, 1500}
};

enum _:Powers {
	POWER_NONE = 0,
	POWER_RAYO,
	POWER_BALAS_INFINITAS,
	POWER_PRECISION_PERFECTA
};

enum _:powerStruct {
	powerName[32],
	powerGold
};

new const POWER_NAMES[][powerStruct] = {
	{"Ninguno", 0},
	{"Rayo", 750},
	{"Balas Infinitas", 3000},
	{"Precisión perfecta", 2500}
};

new g_Power[MAX_USERS][Powers];

enum _:othersStruct {
	otherName[32],
	otherGold
};

new const OTHERS_NAME[][othersStruct] = {
	{"Torreta", 1500}// ,
	// {"Robot", 1750}
};

enum _:sentriesAnims {
	sentryAnimIddle,
	sentryAnimFire,
	sentryAnimSpin
};

enum _:difficultiesStruct {
	difficultyName[32],
	difficultyDesc[450]
};

new const DIFFICULTIES[][difficultiesStruct] = {
	{	"NORMAL",
		"\r* \wVIDA MONSTRUOS\r: \y100%^n\r* \wVELOCIDAD MONSTRUOS\r: \y100%^n\r* \wORO GANADO\r: \y150%^n\r* \wMONSTRUOS POR OLEADA\r: \y100%^n\r* \wBALAS DE TORRETA\r: \yINFINITAS^n\r* \wDAÑO QUE RECIBE LA TORRE\r: \y100%^n\
		\r* \wREGENERACIÓN DE TORRE\r: \y+10 CADA 5 SEG.^n\r* \wHUEVECILLOS\r: \yOLEADA 8+"
	},
	{
		"NIGHTMARE",
		"\r* \wVIDA MONSTRUOS\r: \y150%^n\r* \wVELOCIDAD MONSTRUOS\r: \y120%^n\r* \wORO GANADO\r: \y125%^n\r* \wMONSTRUOS POR OLEADA\r: \y125%^n\r* \wBALAS DE TORRETA\r: \ySI^n\r* \wDAÑO QUE RECIBE LA TORRE\r: \y125%^n\
		\r* \wREGENERACIÓN DE TORRE\r: \y+7 CADA 5 SEG.^n\r* \wHUEVECILLOS\r: \yOLEADA 5+"
	},
	{
		"SUICIDAL",
		"\r* \wVIDA MONSTRUOS\r: \y200%^n\r* \wVELOCIDAD MONSTRUOS\r: \y140%^n\r* \wORO GANADO\r: \y100%^n\r* \wMONSTRUOS POR OLEADA\r: \y150%^n\r* \wBALAS DE TORRETA\r: \ySI^n\r* \wDAÑO QUE RECIBE LA TORRE\r: \y150%^n\
		\r* \wREGENERACIÓN DE TORRE\r: \y+5 CADA 5 SEG.^n\r* \wHUEVECILLOS\r: \yOLEADA 4+^n\r* \wOLEADA EXTRA\r: \yVELOCES^n\r* \wHUEVECILLOS\r: \yMÁS DAÑO Y MÁS VELOCIDAD"
	},
	{
		"HELL",
		"\r* \wVIDA MONSTRUOS\r: \y300%^n\r* \wVELOCIDAD MONSTRUOS\r: \y150%^n\r* \wORO GANADO\r: \y75%^n\r* \wMONSTRUOS POR OLEADA\r: \y200%^n\r* \wBALAS DE TORRETA\r: \ySI^n\r* \wDAÑO QUE RECIBE LA TORRE\r: \y200%^n\
		\r* \wREGENERACIÓN DE TORRE\r: \yNO^n\r* \wHUEVECILLOS\r: \yOLEADA 4+^n\r* \wOLEADA EXTRA\r: \yVELOCES^n\r* \wHUEVECILLOS\r: \yMÁS DAÑO Y MÁS VELOCIDAD^n\r* \wOLEADA EXTRA\r: \yDUROS^n\r* \wHUEVECILLOS\r: \yUNO EXTRA"
	}
};

enum _:difficultiesValueStruct {
	difficultyHealth,
	Float:difficultySpeed,
	difficultyGold,
	difficultyMaxMonsters,
	difficultyDamageTower,
	difficultyTowerRegen,
	
	difficultyExtraWave_Speed,
	difficultyEgg_DmgSpeed,
	
	difficultyExtraWave_Heavy,
	difficultyEgg_Extra,
	
	difficultyBossGorilaHealth,
	Float:difficultyBossGorilaDamage
};

new const DIFFICULTIES_VALUES[difficultiesIds][difficultiesValueStruct] = {
	{0, 0.0, 150, 0, 0, 10, 0, 0, 0, 0, 5000, 30.0},
	{50, 20.0, 125, 25, 25, 7, 0, 0, 0, 0, 6000, 40.0},
	{100, 40.0, 100, 50, 50, 5, 1, 1, 0, 0, 8000, 60.0},
	{200, 50.0, 75, 100, 100, 0, 1, 1, 1, 1, 10000, 80.0}
};

new const UNLIMITED_CLIP_WAVES_LEFT[difficultiesIds] = {
	5, 4, 3, 2
};

new const PRECISION_PERFECTA_WAVES_LEFT[difficultiesIds] = {
	5, 4, 3, 2
};

enum _:zoneMode {
	ZM_NOTHING,
	ZM_BLOCK_ALL,
	ZM_KILL,
	ZM_KILL_T1,
	ZM_KILL_T2,
	ZM_BLOCK_ALL_2
};

new ZONE_MODE[zoneMode][] = {"Sin funcion", "NO DEJAR PASAR A NADIE 1", "MATA A QUIEN LO TOCA", "ZONA BLOQUEADA", "ZONA NO BLOQUEADA", "NO DEJAR PASAR A NADIE 2"};
new ZONE_NAME[zoneMode][] = {"wgz_none", "wgz_block_all", "wgz_kill", "wgz_kill_t1", "wgz_kill_t2", "wgz_block_all_2"};
new ZONE_SOLID_TYPE[zoneMode] = {SOLID_NOT, SOLID_BBOX, SOLID_TRIGGER, SOLID_TRIGGER, SOLID_TRIGGER, SOLID_BBOX};
new NAME_COORD[3][] = {"Coordenada X", "Coordenada Y", "Coordenada Z"};

#define MONSTER_TYPE				EV_INT_iuser1
#define MONSTER_TRACK				EV_INT_iuser2
#define MONSTER_MAXHEALTH			EV_INT_iuser3
#define MONSTER_TARGET				EV_INT_iuser4
#define MONSTER_LOW_FPS				EV_INT_iStepLeft
#define MONSTER_UNIQUE				EV_INT_flDuckTime

#define MONSTER_SPEED				EV_FL_fuser1
#define MONSTER_SHIELD				EV_FL_fuser2

#define MONSTER_HEALTHBAR			EV_ENT_euser1

#define NEXTTHINK_THINK_HUD		get_gametime() + 0.000001
#define NEXTTHINK_THINK_HUDGRAL	get_gametime() + 1.0

new const ENT_EGG_MONSTER_CLASSNAME[] =		"entEggMonster";
new const ENT_SPECIAL_MONSTER_CLASSNAME[] =	"entSpecialMonster";
new const ENT_MONSTER_CLASSNAME[] =			"entMonster";
new const ENT_MINIBOSS_CLASSNAME[] =		"entMiniBoss";
new const ENT_BOSS_CLASSNAME[] =			"entBoss";
new const ENT_BOSS_GUARDIANS[] =			"entBoss_Guardians";

#define ZONE_ID						EV_INT_iuser1
#define MAX_ZONES	 				10

#define SENTRY_INT_FIRE				EV_INT_iuser1
#define SENTRY_OWNER				EV_INT_iuser2
#define SENTRY_INT_LEVEL			EV_INT_iuser3
#define SENTRY_CLIP					EV_INT_iuser4
#define SENTRY_LOW_FPS				EV_INT_team

#define SENTRY_ENT_TARGET			EV_ENT_euser1
#define BASE_ENT_SENTRY				EV_ENT_euser1
#define SENTRY_ENT_BASE				EV_ENT_euser2

#define SENTRY_PARAM_01				EV_FL_fuser1
#define SENTRY_MAXCLIP				EV_FL_fuser2
#define SENTRY_EXTRA_DAMAGE			EV_FL_fuser3
#define SENTRY_EXTRA_RATIO			EV_FL_fuser4

#define SENTRY_TILT_LV4				EV_BYTE_controller1
#define SENTRY_TILT_TURRET			EV_BYTE_controller2
#define SENTRY_TILT_LAUNCHER		EV_BYTE_controller3
#define SENTRY_TILT_RADAR			EV_BYTE_controller4

new const ENT_SENTRY_CLASSNAME[]			= "entSentry";
new const ENT_SENTRY_BASE_CLASSNAME[] 		= "FIX_entSentryBase";

//#define THE_MAGIC					57.2957795131

new const TD_PREFIX[]				= "!g[TD]!y ";

enum _:sentriesDamageStruct {
	sentryMinDamage = 0,
	sentryMaxDamage
};

new const SENTRIES_DAMAGE[][sentriesDamageStruct] = {
	{5, 18},
	{5, 18},
	{11, 25},
	{18, 33},
	{33, 56},
	{56, 73},
	{73, 99}
};

new const Float:SENTRIES_HIT_RATIO[]	= {0.5, 0.5, 0.6, 0.7, 0.7, 0.7, 0.8};
new const Float:SENTRIES_THINK[] 		= {1.5, 1.5, 1.0, 0.5, 0.5, 0.5, 0.4};
new const SENTRIES_UPGRADE_COST[] 		= {1000, 1750, 2500, 3500, 3500, 5000};
new const SENTRIES_MAXCLIP[] 			= {1000000, 500, 100, 100, 100, 150, 250};

// #define ROBOT_INT_HEALTH	EV_INT_iuser1
// #define ROBOT_INT_FIRE		EV_INT_iuser2
// #define ROBOT_INT_BLOCKED	EV_INT_iuser3
// #define ROBOT_INT_COMPLETED	EV_INT_iuser4
// #define ROBOT_ENT_TARGET	EV_ENT_euser1

// enum _:robotSequences {
	// ROBOT_APPEAR = 1,
	// ROBOT_IDLE,
	// ROBOT_DEATH = 4,
	// ROBOT_FIRE = 9,
	// ROBOT_START_MISSILE = 11,
	// ROBOT_MISSILE,
	// ROBOT_STOP_MISSILE
// };

// new const ENT_ROBOT_CLASSNAME[] = "entRobot";

new g_Zone[MAX_ZONES];

const PDATA_SAFE 					= 2;
const OFFSET_LINUX_WEAPONS			= 4;
const OFFSET_LINUX 					= 5;
const OFFSET_WEAPONOWNER 			= 41;
const OFFSET_ID						= 43;
const OFFSET_KNOWN 					= 44;
const OFFSET_NEXT_PRIMARY_ATTACK 	= 46;
const OFFSET_NEXT_SECONDARY_ATTACK 	= 47;
const OFFSET_TIME_WEAPON_IDLE 		= 48;
const OFFSET_PRIMARY_AMMO_TYPE 		= 49;
const OFFSET_CLIPAMMO 				= 51;
const OFFSET_IN_RELOAD 				= 54;
const OFFSET_IN_SPECIAL_RELOAD 		= 55;
const OFFSET_SILENT					= 74;
const OFFSET_LAST_FIRE_TIME			= 79;
const OFFSET_NEXT_ATTACK 			= 83;
const OFFSET_CSTEAMS 				= 114;
const OFFSET_CSMENUCODE 			= 205;
const OFFSET_ACTIVE_ITEM 			= 373;
const OFFSET_AMMO_PLAYER_SLOT0		= 376;
const OFFSET_M3_AMMO 				= 381;
// const OFFSET_MODEL_INDEX			= 491;

const FFADE_IN 						= 0x0000;
const FFADE_OUT						= 0x0001;
const UNIT_SECOND 					= (1 << 12);

new const FIRST_JOIN_MSG[] 			= "#Team_Select";
new const FIRST_JOIN_MSG_SPEC[] 	= "#Team_Select_Spect";

new const Float:DEFAULT_DELAY[] 	= {0.00, 2.70, 0.00, 2.00, 0.00, 0.55, 0.00, 3.15, 3.30, 0.00, 4.50, 2.70, 3.50, 3.35, 2.45, 3.30, 2.70, 2.20, 2.50, 2.63, 4.70, 0.55, 3.05, 2.12, 3.50, 0.00, 2.20, 3.00, 2.45, 0.00, 3.40};
new const DEFAULT_MAXCLIP[] 		= {-1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50};
new const DEFAULT_ANIMS[] 			= {-1, 5, -1, 3, -1, 6, -1, 1, 1, -1, 14, 4, 2, 3, 1, 1, 13, 7, 4, 1, 3, 6, 11, 1, 3, -1, 4, 1, 1, -1, 1};

new const MAX_BPAMMO[] = {-1, 200, -1, 200, 1, 200, 1, 200, 200, 1, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 2, 200, 200, 200, -1, 200};
new const AMMO_TYPE[][] = {"", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm"};
new const AMMO_WEAPON[] = {0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4};

const WEAPONS_SILENT_BIT_SUM 		= (1 << CSW_USP) | (1 << CSW_M4A1);

const MAX_WAVES						= 10;

const HIDE_HUDS				 		= (1 << 5) | (1 << 3);
const HIDE_HUDS_FULL 				= (1 << 6) | (1 << 5) | (1 << 3) | (1 << 0);

const EV_NADE_TYPE 					= EV_INT_flTimeStepSound;

const KEYSMENU 						= MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9 | MENU_KEY_0;

new const WEAPON_ENT_NAMES[][] = {"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas",
"weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90"};

#define is_user_valid_connected(%1) 		(1 <= %1 <= g_MaxUsers && is_user_connected(%1))
#define is_user_valid_alive(%1)			(1 <= %1 <= g_MaxUsers && is_user_alive(%1))

public plugin_precache() {
	g_FwSpawn = register_forward(FM_Spawn, "fw_Spawn");
	g_FwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound");
	
	precache_model("models/rpgrocket.mdl"); // Es una boludes precachear un conchudo model para ciertas funcionalidades... Pero el CS es así
	precache_generic(SOUND_WIN_GAME);
	
	new const PRECACHE_MODELS_IN_GK_TD[][] = {
		"gk_m_normal1", "gk_m_normal2", "gk_m_normal4", "gk_m_speed1", "gk_m_speed2", "gk_m_speed3", "gk_z_normal_01", "gk_z_normal_02", "gk_z_special_01"
	};
	
	new const PRECACHE_MODELS_IN_PLAYER[][] = {
		"gk_zombie_10", "tcs_zombie_2", "tcs_zombie_5", "zp_tcs_l4d_boomer", "tcs_zombie_18"
	};
	
	new i;
	new sBuffer[64];
	
	for(i = 0; i < sizeof(PRECACHE_MODELS_IN_GK_TD); ++i) {
		formatex(sBuffer, charsmax(sBuffer), "models/gk_td/%s.mdl", PRECACHE_MODELS_IN_GK_TD[i]);
		precache_model(sBuffer);
	}
	
	for(i = 0; i < sizeof(PRECACHE_MODELS_IN_PLAYER); ++i) {
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%s.mdl", PRECACHE_MODELS_IN_PLAYER[i], PRECACHE_MODELS_IN_PLAYER[i]);
		precache_model(sBuffer);
		
		formatex(sBuffer, charsmax(sBuffer), "models/player/%s/%sT.mdl", PRECACHE_MODELS_IN_PLAYER[i], PRECACHE_MODELS_IN_PLAYER[i]);
		
		if(file_exists(sBuffer)) {
			precache_model(sBuffer);
		}
	}

	g_LowFPS_ModelIndex_Zombie = precache_model("models/player/leet/leet.mdl");
	
	for(i = 0; i < sizeof(MODEL_SENTRY_LEVEL); ++i) {
		precache_model(MODEL_SENTRY_LEVEL[i]);
	}

	// for(i = 0; i < sizeof(MODEL_ROBOT); ++i) {
		// precache_model(MODEL_ROBOT[i]);
	// }
	
	for(i = 0; i < sizeof(MODEL_BOSS); ++i) {
		precache_model(MODEL_BOSS[i]);
	}
	
	precache_model(MODEL_SENTRY_BASE);
	precache_model(MODEL_SENTRY_BASE_LV4_LV6);
	precache_model(MODEL_GAMINGA);
	precache_model("models/gk_td/mun_00/mun_00T.mdl");
	precache_model(TOWER_MODEL);
	precache_model(MODEL_V_TOOL);
	precache_model(MODEL_P_TOOL);
	precache_model(MODEL_EGG);
	precache_model("models/w_usp.mdl");
	precache_model(MODEL_RANKS);
	precache_model(MODEL_HATS);
	precache_model(MODEL_MINIBOSS);
	precache_model(MODEL_FIREBALL);
	precache_model(MODEL_TANK_ROCK_GIBS);
	precache_model("sprites/gk_td/gk_flame.spr");
	precache_model(MODEL_SPITTER_AURA);
	precache_model(MODEL_FT_AURA);
	precache_model(MODEL_ION_BOMB_V);
	precache_model(MODEL_ION_BOMB_P);
	precache_model(MODEL_ION_BOMB_W);
	g_ModelGibBone = precache_model(MODEL_GIB_BONE);
	g_ModelGibGib = precache_model(MODEL_GIB_GIB);
	g_Model_GibLeg = precache_model(MODEL_GIB_LEG);
	g_Model_GibLung = precache_model(MODEL_GIB_LUNG);
	g_Model_GibSkull = precache_model(MODEL_GIB_SKULL);
	precache_model(MODEL_TENTACLE);
	precache_model(MODEL_AWP_LV7);
	
	for(i = 0; i < sizeof(MONSTER_SOUNDS_PAIN); ++i)
		precache_sound(MONSTER_SOUNDS_PAIN[i]);
	
	for(i = 0; i < sizeof(MONSTER_SOUNDS_DEATH); ++i)
		precache_sound(MONSTER_SOUNDS_DEATH[i]);
	
	for(i = 0; i < sizeof(MONSTER_SOUNDS_CLAW); ++i)
		precache_sound(MONSTER_SOUNDS_CLAW[i]);
	
	for(i = 0; i < sizeof(MONSTER_SOUNDS_LASER); ++i)
		precache_sound(MONSTER_SOUNDS_LASER[i]);

	for(i = 0; i < sizeof(SOUND_SENTRY_FIRE_LV56); ++i)
		precache_sound(SOUND_SENTRY_FIRE_LV56[i]);
	
	for(i = 0; i < sizeof(SOUND_BOSS_PHIT); ++i)
		precache_sound(SOUND_BOSS_PHIT[i]);
	
	precache_sound(SOUND_THUNDER);
	precache_sound(SOUND_SENTRY_BASE);
	precache_sound(SOUND_SENTRY_HEAD);
	precache_sound(SOUND_SENTRY_FIRE);
	precache_sound(SOUND_SENTRY_FOUND);
	precache_sound(SOUND_BUTTON_OK);
	precache_sound(SOUND_BUTTON_BAD);
	precache_sound(SOUND_BOSS_ROLL_LOOP);
	precache_sound(SOUND_BOSS_ROLL_FINISH);
	// precache_generic(SOUND_BOSS_GALIO);
	precache_sound("weapons/xbow_fire1.wav");
	// precache_sound(SOUND_FAKEBOSS_LAUGH);
	precache_sound(SOUND_BOSS_EXPLODE);
	precache_sound(SOUND_BOSS_IMPACT);
	precache_sound(SOUND_BOSS_FIREBALL_LAUNCH2);
	precache_sound(SOUND_BOSS_FIREBALL_LAUNCH4);
	precache_sound(SOUND_BOSS_FIREBALL_EXPLODE);
	precache_sound(SOUND_SPITTER_SPIT);
	precache_sound(SOUND_BOOMER_EXPLODE);
	// precache_sound(SOUND_ROBOT_MISSILE_FIRED);
	precache_sound(SOUND_FT_CANNON);
	precache_sound(SOUND_FT_SCREAM);

	precache_model(MONSTER_SPRITE_SPAWN);
	precache_model(MONSTER_SPRITE_HEALTH_BOSS);
	g_Sprite_Blood = precache_model(MONSTER_SPRITE_BLOOD);
	g_Sprite_BloodSpray = precache_model(MONSTER_SPRITE_BLOODSPRAY);
	g_Sprite_Trail = precache_model(SPRITE_TRAIL);
	g_Sprite_Dot = precache_model(SPRITE_DOT);
	g_Sprite_Thunder = precache_model(SPRITE_THUNDER);
	// g_Sprite_ShockWave = precache_model(SPRITE_SHOCKWAVE);
	g_SPRITE_ArrowExplode = precache_model("sprites/zerogxplode.spr");
	precache_model("sprites/animglow01.spr");
}

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	get_mapname(g_MapName, charsmax(g_MapName));
	strtolower(g_MapName);
	
	new i;
	
	for(i = 1; i < mapsIds; ++i) {
		if(equal(g_MapName, MAPS_DESC[i][mapName])) {
			g_MapId = i;
			g_BlockDiff = MAPS_DESC[i][mapBlock];
			
			break;
		}
	}
	
	if(!checkMap()) {
		set_fail_state("El modo no funciona en el mapa actual!");
	}
	
	set_task(0.4, "pluginSQL");
	
	formatex(g_UserName[0], 31, "www.drunk-gaming.com");
	
	g_ExtraWaveSpeed = random_num(2, 9);

	do {
		g_ExtraWaveStrength = random_num(3, 10);
	} while(g_ExtraWaveStrength == g_ExtraWaveSpeed);
	
	new sText[72];
	formatex(sText, charsmax(sText), "addons/amxmodx/configs/evas/%s", g_MapName);
	
	if(!dir_exists(sText)) {
		mkdir(sText);
	}
	
	register_event("Health", "event_Health", "be");
	register_event("AmmoX", "event_AmmoX", "be");

	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_flashbang", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_hegrenade", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_smokegrenade", "fw_WeaponFireRate_Fix", 0);
	
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_flashbang", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_hegrenade", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_m4a1", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_smokegrenade", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_usp", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_awp", "fw_WeaponFireRate_Fix", 0);
	
	RegisterHam(Ham_Weapon_Reload, "weapon_m3", "fw_WeaponFireRate_Fix", 0);
	RegisterHam(Ham_Weapon_Reload, "weapon_xm1014", "fw_WeaponFireRate_Fix", 0);

	for(i = 1; i < sizeof(WEAPON_ENT_NAMES); ++i) {
		if(WEAPON_ENT_NAMES[i][0]) {
			RegisterHam(Ham_Item_Deploy, WEAPON_ENT_NAMES[i], "fw_WeaponFireRate_Fix", 0);
			RegisterHam(Ham_Item_Deploy, WEAPON_ENT_NAMES[i], "fw_Item_Deploy_Post", 1);

			if(i == CSW_P228 || i == CSW_HEGRENADE || i == CSW_C4 || i == CSW_SMOKEGRENADE || i == CSW_ELITE || i == CSW_FIVESEVEN || i == CSW_UMP45 || i == CSW_USP || i == CSW_GLOCK18 || i == CSW_FLASHBANG || i == CSW_KNIFE) {
				continue;
			}

			RegisterHam(Ham_Item_AttachToPlayer, WEAPON_ENT_NAMES[i], "fw_Item_AttachToPlayer");
			
			RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_ENT_NAMES[i], "fw_WeaponFireRate_Fix", 0);
			RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_ENT_NAMES[i], "fw_Weapon_PrimaryAttack_Post", 1);
			
			if(i != CSW_XM1014 && i != CSW_M3) {
				RegisterHam(Ham_Item_PostFrame, WEAPON_ENT_NAMES[i], "fw_Item_PostFrame");
			} else {
				RegisterHam(Ham_Item_PostFrame, WEAPON_ENT_NAMES[i], "fw_Shotgun_PostFrame");
				RegisterHam(Ham_Weapon_WeaponIdle, WEAPON_ENT_NAMES[i], "fw_Shotgun_WeaponIdle");
			}
		}
	}
	
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack");
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled");
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeed__Post", 1);
	
	RegisterHam(Ham_TakeDamage, "info_target", "fw_MonsterTakeDamage");
	RegisterHam(Ham_TraceAttack, "info_target", "fw_MonsterTraceAttack");
	RegisterHam(Ham_Killed, "info_target", "fw_MonsterKilled");

	register_clcmd("say /cam", "clcmd__Cam");
	
	new j = 0;
	for(i = 0; i < sizeof(MAPNAME_FIX); ++i) {
		if(equal(g_MapName, MAPNAME_FIX[i])) {
			RegisterHam(Ham_Touch, "info_target", MAPNAME_FIX[i], 1);
			j = 1;
			
			break;
		}
	}
	
	if(!j) {
		RegisterHam(Ham_Touch, "info_target", "fw_TouchMonster_Post", 1);
	}
	
	register_touch("grenade", "*", "touch__GrenadeAll");
	
	register_forward(FM_ClientKill, "fw_ClientKill");
	register_forward(FM_CmdStart, "fw_CmdStart");
	register_forward(FM_SetModel, "fw_SetModel");
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade");
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue");
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged");
	register_forward(FM_Touch, "fw_Touch");
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1);
	
	unregister_forward(FM_Spawn, g_FwSpawn);
	unregister_forward(FM_PrecacheSound, g_FwPrecacheSound);
	
	register_think(ENT_SPECIAL_MONSTER_CLASSNAME, "think__SpecialMonster");
	register_think(ENT_SENTRY_CLASSNAME, "think__Sentry");
	
	new const WEAPON_COMMANDS[][] =	{
		"buy", "buyammo1", "buyammo2", "buyequip", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47", "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
		"sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "fiveseven", "12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum",
		"d3au1", "krieg550", "smg", "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown"
	};
	
	register_clcmd("CREAR_CONTRASENIA", "clcmd_CreatePassword");
	register_clcmd("REPETIR_CONTRASENIA", "clcmd_RepeatPassword");
	register_clcmd("INGRESAR_CONTRASENIA", "clcmd_EnterPassword");
	register_clcmd("chooseteam", "clcmd_Changeteam");
	register_clcmd("jointeam", "clcmd_Changeteam");
	register_clcmd("say /log", "clcmd__ChangeLog");
	register_clcmd("say /tut", "clcmd__Tutorial");
	register_clcmd("say /tutorial", "clcmd__Tutorial");
	register_clcmd("say /start", "clcmd_Start");
	register_clcmd("say /noclip", "clcmd_Noclip");
	register_clcmd("say /test", "clcmd_Test");
	register_clcmd("say /boss", "clcmd_BossTest");
	register_clcmd("say /bossgorila", "clcmd_GorilaTest");
	register_clcmd("say /bossfire", "clcmd_FireTest");
	register_clcmd("say /bossft", "clcmd_FTTest");
	register_clcmd("say /bosskyra", "clcmd_KyraTest");
	register_clcmd("say /egg", "clcmd_BTest");
	register_clcmd("say /tramposo", "clcmd_VTest");
	register_clcmd("say /block", "clcmd__MTest");
	register_clcmd("say /bailar", "clcmd__Dance");
	register_clcmd("radio1", "clcmd_PowerUp");
	register_clcmd("radio2", "clcmd_PowerLeft");
	register_clcmd("radio3", "clcmd_PowerRight");
	register_clcmd("drop", "clcmd__ChangeNadeType");
	for(i = 0; i < sizeof(WEAPON_COMMANDS); ++i) {
		register_clcmd(WEAPON_COMMANDS[i], "clcmd_BlockCommand");
	}
	register_clcmd("say", "clcmd_Say");
	register_clcmd("say_team", "clcmd_Say");
	
	register_menucmd(register_menuid("#Buy", 1), 511, "menucmd_CsBuy");
	register_menucmd(register_menuid("BuyPistol", 1), 511, "menucmd_CsBuy");
	register_menucmd(register_menuid("BuyShotgun", 1), 511, "menucmd_CsBuy");
	register_menucmd(register_menuid("BuySub", 1), 511, "menucmd_CsBuy");
	register_menucmd(register_menuid("BuyRifle", 1), 511, "menucmd_CsBuy");
	register_menucmd(register_menuid("BuyMachine", 1), 511, "menucmd_CsBuy");
	register_menucmd(register_menuid("BuyItem", 1), 511, "menucmd_CsBuy");
	register_menucmd(register_menuid("BuyEquip", 1), 511, "menucmd_CsBuy");
	register_menucmd(-28, 511, "menucmd_CsBuy");
	register_menucmd(-29, 511, "menucmd_CsBuy");
	register_menucmd(-30, 511, "menucmd_CsBuy");
	register_menucmd(-32, 511, "menucmd_CsBuy");
	register_menucmd(-31, 511, "menucmd_CsBuy");
	register_menucmd(-33, 511, "menucmd_CsBuy");
	register_menucmd(-34, 511, "menucmd_CsBuy");
	
	register_menu("Register Login Menu", KEYSMENU, "menu__RegisterLogin");
	register_menu("WGM Main", KEYSMENU, "menu__WGM_Main");
	register_menu("WGM Edit", KEYSMENU, "menu__WGM_Edit");
	register_menu("WGM Kill", KEYSMENU, "menu__WGM_Kill");
	register_menu("WGM Create New Zone", KEYSMENU, "menu__WGM_CreateNewZone");
	register_menu("Info Sentry", KEYSMENU, "menu__InfoSentry");
	register_menu("Info Level Classes", KEYSMENU, "menu__ClassesINFO_LEVELS");
	register_menu("Info Difficulty", KEYSMENU, "menu__DifficultyINFO");
	register_menu("Requeriments Level G", KEYSMENU, "menu__RequerimentsLevelG");
	register_menu("Menu Habilities", KEYSMENU, "menu__Habilities");
	register_menu("Info Habilities", KEYSMENU, "menu__InfoHabilities");
	register_menu("Menu Join", KEYSMENU, "menu__Join");
	register_menu("Menu Tutorial", KEYSMENU, "menu__Tutorial");
	register_menu("Upgrades Menu", KEYSMENU, "menu__Upgrades");
	register_menu("Transfer Sentry", KEYSMENU, "menu__TransferTurretOwner");
	register_menu("Move Sentry", KEYSMENU, "menu__MoveTurret");
	register_menu("Options Low FPS", KEYSMENU, "menu__LowFPS");
	// register_menu("Info Robot", KEYSMENU, "menu__InfoRobot");
	
	register_impulse(100, "impulse_Flashlight");
	
	register_concmd("gc", "concmd_CreateGaminga");
	register_concmd("g_wgm", "concmd_WalkGuardMenu");
	register_concmd("td_level", "concmd_Level");
	register_concmd("td_levelg", "concmd_LevelG");
	register_concmd("td_points", "concmd_Points");
	register_concmd("td_gold", "concmd_Gold");
	register_concmd("td_health", "concmd_Health");
	register_concmd("td_tower_health", "concmd__TowerHealth");
	register_concmd("td_os", "concmd__Os");
	register_concmd("td_ban", "concmd__BanAccount");
	register_concmd("td_unban", "concmd__UnbanAccount");
	register_concmd("td_lights", "concmd__Lights");
	
	g_Message_HideWeapon = get_user_msgid("HideWeapon");
	g_Message_Crosshair = get_user_msgid("Crosshair");
	g_Message_RoundTime = get_user_msgid("RoundTime");
	g_Message_ScoreInfo = get_user_msgid("ScoreInfo");
	g_Message_TextMsg = get_user_msgid("TextMsg");
	g_Message_SendAudio = get_user_msgid("SendAudio");
	g_Message_ShowMenu = get_user_msgid("ShowMenu");
	g_Message_VGUIMenu = get_user_msgid("VGUIMenu");
	g_Message_TeamInfo = get_user_msgid("TeamInfo");
	g_Message_Screenfade = get_user_msgid("ScreenFade");
	g_Message_ClCorpse = get_user_msgid("ClCorpse");
	g_Message_ScreenShake = get_user_msgid("ScreenShake");
	g_Message_AmmoPickup = get_user_msgid("AmmoPickup");
	g_Message_CurWeapon = get_user_msgid("CurWeapon");
	
	register_message(g_Message_RoundTime, "message__RoundTime");
	register_message(g_Message_TextMsg, "message__TextMsg");
	register_message(g_Message_SendAudio, "message__SendAudio");
	register_message(g_Message_ShowMenu, "message__ShowMenu");
	register_message(g_Message_VGUIMenu, "message__VGUIMenu");
	register_message(g_Message_ClCorpse, "message_ClCorpse");
	register_message(g_Message_CurWeapon, "message__CurWeapon");
	
	g_MaxUsers = get_maxplayers();
	
	g_HudGeneral = CreateHudSyncObj();
	g_HudDamage = CreateHudSyncObj();
	g_HudDamageTower = CreateHudSyncObj();
	
	OrpheuRegisterHook(OrpheuGetFunction("CheckMapConditions", "CHalfLifeMultiplay"), "orpheu__BlockGameConditions");
	OrpheuRegisterHook(OrpheuGetFunction("CheckWinConditions", "CHalfLifeMultiplay"), "orpheu__BlockGameConditions");
	OrpheuRegisterHook(OrpheuGetFunction("HasRoundTimeExpired", "CHalfLifeMultiplay"), "orpheu__BlockGameConditions");
	
	g_EntHUD = create_entity("info_target");
	if(is_valid_ent(g_EntHUD)) {
		entity_set_string(g_EntHUD, EV_SZ_classname, "entThinkHUD");
		entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
		
		register_think("entThinkHUD", "think__HUD");
	}
	
	new iEntHUD = create_entity("info_target");
	if(is_valid_ent(iEntHUD)) {
		entity_set_string(iEntHUD, EV_SZ_classname, "entThinkHUDGeneral");
		entity_set_float(iEntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUDGRAL);
		
		register_think("entThinkHUDGeneral", "think__HUDGeneral");
	}
	
	loadGaminga();
	
	g_StartGame = 1;
	g_StartSeconds = 59;
	
	set_task(60.0, "checkStartGame", TASK_START_GAME);
	set_task(1.0, "repeatHUD2", TASK_START_GAME, _, _, "a", 59);
	set_task(59.0, "__endVote_Difficulty");
	
	g_Array_MapName = ArrayCreate(64);
	
	loadWGM();
	loadMaps();
	
	g_Achievement_DefensaAbsoluta = 1;
	g_ZombieModels = random_num(0, charsmax(MONSTER_MODELS_NORMAL));
	g_IonUsed = 1;
	g_FinishGame = 0;
	g_Lights[0] = 'i';
}

public plugin_cfg() {
	set_cvar_num("mp_freezetime", 0);
	set_cvar_num("sv_maxvelocity", 4000);
	set_cvar_num("amx_afk_time", 9999);
	set_cvar_num("amx_reservation", 0);

	set_lights(g_Lights[0]);
}

public client_authorized(id) {
	new iUsersNum = get_playersnum(1);

	get_user_authid(id, g_UserSteam[id], charsmax(g_UserSteam[]));

	if(equal(g_UserSteam[id], "STEAM_0:1:55557321")) {
		g_Kiske[id] = 1;
	}

	if(g_AdminOn) {
		return PLUGIN_CONTINUE;
	}
	
	if(iUsersNum > 12 && !g_Kiske[id]) {
		server_cmd("kick #%d ^"Este último slot está reservado para administradores.^"", get_user_userid(id));
	}

	return PLUGIN_CONTINUE;
}

public client_putinserver(id) {
	new i;
	new j;
	
	get_user_name(id, g_UserName[id], charsmax(g_UserName[]));
	get_user_authid(id, g_UserSteam[id], charsmax(g_UserSteam[]));
	
	g_PoderScouter[id] = 0;
	g_Pistolero_AutoFire[id] = 0;
	g_Kiske[id] = 0;
	g_Gold[id] = 800;
	g_PowerActual[id] = 0;
	g_Sentry[id] = 0;
	// g_Robot[id] = 0;
	g_AccountPassword[id][0] = EOS;
	g_AccountLogged[id] = 0;
	g_AccountRegister[id] = 0;
	g_UserId[id] = 0;
	g_Kills[id] = 0;
	g_LevelG[id] = 0;
	g_ClassId[id] = 0;
	g_Class_Soporte_Bonus[id] = 0;
	g_VoteDifficulty[id] = DIFF_NORMAL;
	g_AllowChangeTeam[id] = 0;
	g_SentryDamage[id] = 0;
	g_Rank[id] = 0;
	g_Hat[id] = 0;
	g_NoReload[id] = 0.0;
	g_Points[id] = 0;
	g_Menu_HabsPoints[id] = 1;
	g_MenuPage_Habilities[id] = 0;
	g_MenuPage_FavoriteDiff[id] = 0;
	g_HabCacheClip[id] = 0;
	g_AccountVinc[id] = 0;
	g_Options_HUD_Effect[id] = 0;
	g_Options_HUD_Position[id] = Float:{0.02, 0.15};
	g_Options_HUD_Center[id] = 0;
	g_Options_HUD_Color[id] = {255, 255, 255};
	g_Options_HUD_ProgressClass[id] = 0;
	g_DamageDone[id] = 0;
	g_DamageDoneForKill[id] = 0;
	g_AchievementCount[id] = 0;
	g_Osmio[id] = 0;
	g_OsmioLost[id] = 0;
	g_AchievementLink[id] = 0.0;
	g_WinMVP[id] = 0;
	g_WinMVP_Next[id] = 0;
	g_GoldG[id] = 0;
	g_AchievementMap[id] = 0;
	g_MenuPageTutorial[id] = 0;
	g_Options_HUD_KillsPerWave[id] = 0;
	g_GoldGaben[id] = 0;
	g_WinMVPGaben[id] = 0;
	g_AFK_Time[id] = 0.0;
	g_AFK_Damage[id] = 0;
	g_MenuPage_TOPS[id] = 0;
	g_SysTime_TOPS[id] = 0.0;
	g_SupportHab[id] = 0;
	g_MenuPage_Upgrades[id] = 0;
	g_CriticChance[id] = 0;
	g_GordoBomba_Kills[id] = 0;
	g_Unlimited_Clip[id] = 0;
	g_UnlimitedClip_WavesLeft[id] = 0;
	g_PrecisionPerfecta[id] = 0;
	g_PrecisionPerfecta_WavesLeft[id] = 0;
	g_Top15_MapId[id] = 0;
	g_VoteMap_MapVoted[id] = -1;
	g_AlreadyJoined[id] = 0;
	g_Sentry_TransferMenu[id] = 0;
	g_Option_LowFPS_Models[id] = 0;
	g_Option_LowFPS_Glow[id] = 0;
	g_Option_LowFPS_Sentries[id] = 0;
	g_Option_LowFPS_ZombieDead[id] = 0;
	g_AchievementTrack_Pistolero[id] = 0;
	g_UserPremium[id] = (get_user_flags(id) & ADMIN_RESERVATION) ? 1 : 0;
	
	for(i = 0; i < structHabilities; ++i) {
		g_Upgrades[id][i] = 0;
	}
	
	for(i = 0; i < LogrosInt; ++i) {
		g_Achievement[id][i] = 0;
		g_AchievementInt[id][i] = 0;
		g_AchievementUnlock[id][i] = 0;
	}
	
	for(i = 0; i < (LOGRO_CLASS_MAX + 2); ++i) {
		g_MenuPage[id][i] = 0;
	}
	
	if(g_VoteDifficulty[id] < g_BlockDiff) {
		g_VoteDifficulty[id] = g_BlockDiff;
	}
	
	for(i = 0; i < 12; ++i) {
		g_KillsPerWave[id][i] = 0;
	}
	
	for(i = 0; i < HabsId; ++i) {
		g_Hab[id][i] = 0;
	}
	
	for(i = 0; i < HabsFId; ++i) {
		g_HabCache[id][i] = 0.0;
	}
	
	for(i = 0; i < (difficultiesIds + 1); ++i) {
		for(j = 0; j < 11; ++j) {
			g_WavesWins[id][i][j] = 0;
		}
		
		g_BossKills[id][i] = 0;
	}
	
	for(i = 0; i < classIds; ++i) {
		g_ClassLevel[id][i] = 0;
		g_ClassReqs[id][i] = 0;
	}
	
	for(i = 0; i < grenadesType; ++i) {
		g_Nades[id][i] = 0;
	}
	
	for(i = 0; i < Powers; ++i) {
		g_Power[id][i] = 0;
	}

	for(i = 0; i < mapsIds; ++i) {
		g_AutoDifficult[id][i] = -1;
	}
	
	if(containi(g_UserName[id], "DROP TABLE") != -1 || containi(g_UserName[id], "TRUNCATE") != -1 || containi(g_UserName[id], "INSERT") != -1 || containi(g_UserName[id], "UPDATE") != -1 || containi(g_UserName[id], "DELETE") != -1 || 
	containi(g_UserName[id], "\") != -1) {
		server_cmd("kick #%d ^"Tu nombre tiene un caracter invalido^"", get_user_userid(id));
		return;
	}
	
	if(equal(g_UserSteam[id], "STEAM_0:1:55557321")) {
		g_Kiske[id] = 1;
		g_AdminOn = 1;
	}
	
	set_task(0.3, "checkAccount", id);
	set_task(1.5, "showHUD");
}

public client_disconnect(id) {
	if(equal(g_UserSteam[id], "STEAM_0:1:55557321")) {
		g_AdminOn = 0;
	}

	remove_task(id + TASK_SAVE);
	remove_task(id + TASK_TEAM);
	remove_task(id + TASK_VINC);

	if(g_VoteMap_MapVoted[id] != -1) {
		--g_MapMenu_Votes[g_VoteMap_MapVoted[id]];
		--g_MapMenu_Maxvotes;
	}
	if(g_BestUserId == id) {
		g_BestUserKills = 0;
		g_BestUserId = 0;
	}
	
	if(g_Rank[id] && is_valid_ent(g_Rank[id])) {
		remove_entity(g_Rank[id]);
	}

	if(g_Hat[id] && is_valid_ent(g_Hat[id])) {
		remove_entity(g_Hat[id]);
		g_Hat[id] = 0;
	}
	
	new iEnt = -1;
	
	while((iEnt = fm_find_ent_by_class(iEnt, ENT_SENTRY_CLASSNAME))) {
		if(is_valid_ent(iEnt)) {
			if(id == entity_get_int(iEnt, SENTRY_OWNER)) {
				entity_set_int(iEnt, SENTRY_OWNER, 0);
				
				entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
				entity_set_float(iEnt, EV_FL_animtime, 1.0);
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				fm_set_rendering(iEnt, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 3);

				new entBase = entity_get_edict(iEnt, SENTRY_ENT_BASE);
				entity_set_int(entBase, SENTRY_OWNER, 0);
			}
		}
	}
	
	saveInfo(id);
	
	// new iAlives = 0;
	// new i;
	
	// for(i = 1; i <= g_MaxUsers; ++i) {
		// if(id == i) {
			// continue;
		// }
		
		// if(is_user_alive(i)) {
			// ++iAlives;
		// }
	// }
	
	// ESTA MIERDA TIRA EL SV Y NO TENGO IDEA POKER
	
	// if(!iAlives) {
		// removeAllEnts(1);
		// __finishGame();
	// }
}

public checkStartGame() {
	if(getUsersAlive() >= 1) {
		g_NextWaveIncoming = 1;
		g_StartGame = 0;
		
		clearDHUDs();
		entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
		
		set_task(3.0, "startWave", TASK_WAVES);
	} else {
		g_StartSeconds = 59;
		g_NextWaveIncoming = 0;
		g_StartGame = 1;
		
		set_task(60.0, "checkStartGame", TASK_START_GAME);
		set_task(1.0, "repeatHUD2", TASK_START_GAME, _, _, "a", 59);
		set_task(59.0, "__endVote_Difficulty");
	}
}

public repeatHUD2() {
	--g_StartSeconds;
	
	if(!g_StartSeconds) {
		g_StartGame = 0;
		g_NextWaveIncoming = 1;
	}
	
	clearDHUDs();
	entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
}

public showHUD() {
	clearDHUDs();
	entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
}

public clcmd_Changeteam(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	if(g_AllowChangeTeam[id]) {
		return PLUGIN_CONTINUE;
	}
	
	if(!g_AccountRegister[id] || !g_AccountLogged[id]) {
		showMenu__RegisterLogin(id);
		return PLUGIN_HANDLED;
	}
	
	static iTeam;
	iTeam = getUserTeam(id);
	
	if(iTeam == FM_CS_TEAM_SPECTATOR || iTeam == FM_CS_TEAM_UNASSIGNED) {
		return PLUGIN_CONTINUE;
	}
	
	if(!g_VoteMap) {
		showMenu__Game(id);
	}
	
	return PLUGIN_HANDLED;
}

public respawnUser(const id) {
	if(!is_user_connected(id))
		return;
	
	if(is_user_alive(id))
		return;
	
	if(g_WaveInProgress)
		return;
	
	if(getUserTeam(id) != FM_CS_TEAM_CT && getUserTeam(id) != FM_CS_TEAM_T)
		return;
	
	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public clcmd__ChangeLog(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[256];
	formatex(sBuffer, 255, "<html><head><style>body {background:#000;color:#FFF;}</style><meta http-equiv=^"Refresh^" content=^"0;url=http://drunk-gaming.com/servidores/27060/cambios.html^"></head><body><p>Cargando...</p></body></html>");
	show_motd(id, sBuffer, "CAMBIOS");

	return PLUGIN_HANDLED;
}

public clcmd__Tutorial(const id) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}

	if(!g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}

	showMenu__Tutorial(id, 0);

	return PLUGIN_HANDLED;
}

public clcmd_Start(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	remove_task(TASK_START_GAME);
	
	g_StartGame = 0;
	g_NextWaveIncoming = 1;
	
	g_MaxHealth = 100000;
	
	g_DamageNeedToGold = 7;
	
	clearDHUDs();
	entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
	
	set_task(3.0, "startWave", TASK_WAVES);
	
	return PLUGIN_HANDLED;
}

public clcmd_Noclip(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	set_user_noclip(id, get_user_noclip(id) ? 0 : 1);
	
	new Float:vecOrigin[3];
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	colorChat(id, _, "!y{%f, %f, %f}", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
	
	entity_get_vector(id, EV_VEC_v_angle, vecOrigin);
	colorChat(id, _, "!y{%f, %f, %f}", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
	
	return PLUGIN_HANDLED;
}

public clcmd_Test(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	new Float:vecOrigin[3];
	new Float:vecAngles[3];
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	entity_get_vector(id, EV_VEC_angles, vecAngles);
	
	new iEnt;
	iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, "entViewTower");
		
		entity_set_model(iEnt, "models/w_usp.mdl");
		entity_set_origin(iEnt, vecOrigin);
		
		entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
		
		entity_set_int(iEnt, EV_INT_sequence, 0);
		entity_set_float(iEnt, EV_FL_animtime, 2.0);
		
		entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
		entity_set_float(iEnt, EV_FL_renderamt, 0.0);
		
		entity_set_size(iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
		
		entity_set_vector(iEnt, EV_VEC_v_angle, vecAngles);
		entity_set_vector(iEnt, EV_VEC_angles, vecAngles);
		
		new iFound;
		new iPos;
		new sData[32];
		new sFile[40];
		
		formatex(sFile, charsmax(sFile), "addons/amxmodx/configs/view_tower.ini");
		new iFile = fopen(sFile, "r+");
		
		if(iFile) {
			while(!feof(iFile)) {
				fgets(iFile, sData, charsmax(sData));
				parse(sData, sData, charsmax(sData));
				
				++iPos;
				
				if(equal(sData, g_MapName)) {
					iFound = 1;
					
					new sText[128];
					formatex(sText, charsmax(sText), "%s %f %f %f %f %f %f", g_MapName, vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2]);
					
					write_file(sFile, sText, iPos - 1);
					
					break;
				}
			}
			
			if(!iFound)
				fprintf(iFile, "%s %f %f %f %f %f %f^n", g_MapName, vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2]);
			
			fclose(iFile);
			
			colorChat(id, _, "%sEl archivo !g%s!y ha sido guardado exitosamente!", TD_PREFIX, sFile);
		}
	}
	
	return PLUGIN_HANDLED;
}

public clcmd_BossTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	// set_task(0.1, "__autoAim", id);
	
	g_Wave = 1337;
	
	return PLUGIN_HANDLED;
}

public clcmd_GorilaTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	// set_task(0.1, "__autoAim", id);
	
	g_Wave = 1338;
	g_BossId = BOSS_GORILA;
	
	return PLUGIN_HANDLED;
}

public clcmd_FireTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	g_Wave = 1338;
	g_BossId = BOSS_FIRE;
	
	return PLUGIN_HANDLED;
}

public clcmd_FTTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	g_Wave = 1338;
	g_BossId = BOSS_FALLEN_TITAN;
	
	return PLUGIN_HANDLED;
}

public clcmd_KyraTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	g_Wave = 1338;
	g_BossId = BOSS_GUARDIANES;
	
	return PLUGIN_HANDLED;
}

public clcmd_BTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	createSpecialMonster(0, 0);
	
	return PLUGIN_HANDLED;
}

public clcmd_VTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	g_Wave = 9;
	g_Tramposo = 1;
	
	return PLUGIN_HANDLED;
}

public clcmd__MTest(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}

	g_BlockGame = 1;

	return PLUGIN_HANDLED;
}

// public __autoAim(const id) {
	// if(!is_user_alive(id))
		// return;
	
	// static Float:fRange;
	// static Float:fMaxRange;
	// static Float:vecIdOrigin[3];
	// static Float:vecMonsterOrigin[3];
	// static Float:vecAngles[3];
	// static Float:vecDiff[3];
	// static Float:vecNormalize[3];
	// static Float:fDot;
	// static Float:fFov;
	// static iEnt;
	
	// fMaxRange = 8192.0;
	// iEnt = -1;
	
	// entity_get_vector(id, EV_VEC_origin, vecIdOrigin);
	// entity_get_vector(id, EV_VEC_angles, vecAngles);
	// fFov = entity_get_float(id, EV_FL_fov);
	
	// engfunc(EngFunc_MakeVectors, vecAngles);
	// global_get(glb_v_forward, vecAngles);
	
	// vecAngles[2] = 0.0;
	
	// while((iEnt = fm_find_ent_by_class(iEnt, ENT_MONSTER_CLASSNAME))) {
		// if(entity_get_int(iEnt, MONSTER_TYPE)) {
			// entitySetAim(id, iEnt, 3);
			
			// entity_get_vector(iEnt, EV_VEC_origin, vecMonsterOrigin);
			
			// xs_vec_sub(vecMonsterOrigin, vecIdOrigin, vecDiff);
			// vecDiff[2] = 0.0;
			// xs_vec_normalize(vecDiff, vecNormalize);
			
			// fDot = xs_vec_dot(vecNormalize, vecAngles);
			
			// if(fDot < floatcos((fFov * 3.14159265358979323846) / 360)) {
				// colorChat(id, _, "!yBUSCAR A OTRO");
			// }
		// }
	// }
	
	// set_task(0.1, "__autoAim", id);
// }

public clcmd_PowerUp(const id) {
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	switch(g_PowerActual[id]) {
		case POWER_RAYO: {
			if(g_Power[id][g_PowerActual[id]]) {
				--g_Power[id][g_PowerActual[id]];
				
				if(!g_Power[id][g_PowerActual[id]])
					g_PowerActual[id] = 0;
				
				emit_sound(id, CHAN_VOICE, SOUND_THUNDER, 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				new iOrigin[3];
				new startOrigin[3];
				new iEnt = -1;
				new iMaxMonsters = random_num(6, 7);
				new iMonsters = 0;
				new Float:vecOrigin[3];
				new iMonsterType;
				
				if(g_Upgrades[id][HAB_THOR]) {
					iMaxMonsters += random_num(3, 4);
				}
				
				while((iEnt = fm_find_ent_by_class(iEnt, ENT_MONSTER_CLASSNAME))) {
					if(iMonsters >= iMaxMonsters) {
						break;
					}
					
					iMonsterType = entity_get_int(iEnt, MONSTER_TYPE);
					
					if(iMonsterType != 0 && iMonsterType != MONSTER_BOSS && iMonsterType != MONSTER_SPECIAL) {
						entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
						
						iOrigin[0] = floatround(vecOrigin[0]);
						iOrigin[1] = floatround(vecOrigin[1]);
						iOrigin[2] = floatround(vecOrigin[2]);
						
						iOrigin[2] -= 26;
						
						startOrigin[0] = iOrigin[0] + 150;
						startOrigin[1] = iOrigin[1] + 150;
						startOrigin[2] = iOrigin[2] + 800;
						
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
						
						removeMonster(iEnt, id, .rayo=1);
						
						++iMonsters;
					}
				}
				
				if(iMonsters) {
					set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
					ShowSyncHudMsg(id, g_HudDamage, "¡MATADO! [x%d]", iMonsters);
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
			if(g_Power[id][g_PowerActual[id]] && g_Wave > 0 && g_Wave < 11) {
				--g_Power[id][g_PowerActual[id]];
				
				if(!g_Power[id][g_PowerActual[id]]) {
					g_PowerActual[id] = 0;
				}
				
				g_Unlimited_Clip[id] = 1;
				g_UnlimitedClip_WavesLeft[id] += UNLIMITED_CLIP_WAVES_LEFT[g_Difficulty];

				colorChat(id, _, "%sTus balas infinitas fueron activadas, oleadas restantes: !g%d!y", TD_PREFIX, g_UnlimitedClip_WavesLeft[id]);
			} else {
				colorChat(id, _, "%sTus balas infinitas no pueden activarse en este momento.", TD_PREFIX);
			}
		} case POWER_PRECISION_PERFECTA: {
			if(g_Power[id][g_PowerActual[id]] && g_Wave > 0 && g_Wave < 11) {
				--g_Power[id][g_PowerActual[id]];
				
				if(!g_Power[id][g_PowerActual[id]]) {
					g_PowerActual[id] = 0;
				}

				g_PrecisionPerfecta[id] = 1;
				g_PrecisionPerfecta_WavesLeft[id] += PRECISION_PERFECTA_WAVES_LEFT[g_Difficulty];

				colorChat(id, _, "%sTu precisión perfecta fueron activadas, oleadas restantes: !g%d!y", TD_PREFIX, g_PrecisionPerfecta_WavesLeft[id]);
			} else {
				colorChat(id, _, "%sTu precisión perfecta no pueden activarse en este momento.", TD_PREFIX);
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public clcmd_PowerLeft(const id) {
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	new iPower;
	new i;
	new j;
	
	iPower = g_PowerActual[id];
	
	while(i == 0) {
		--iPower;
		
		if(iPower < 0) {
			j = 1;
			while(j >= 0) {
				if(g_Power[id][Powers-j]) {
					g_PowerActual[id] = Powers-j;
					break;
				} else {
					++j;
					g_PowerActual[id] = 0;

					if(Powers-j < 0) {
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

public clcmd_PowerRight(const id) {
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	new iPower;
	new i;
	
	iPower = g_PowerActual[id];
	
	while(i == 0) {
		++iPower;
		
		if(iPower >= Powers) {
			g_PowerActual[id] = 0;
			break;
		} else if(g_Power[id][iPower]) {
			g_PowerActual[id] = iPower;
			break;
		}
	}
	
	return PLUGIN_HANDLED;
}

public clcmd_BlockCommand(const id) {
	return PLUGIN_HANDLED;
}

public menucmd_CsBuy(const id, const key) {
	return PLUGIN_HANDLED;
}

public startWave() {
	if(g_EndGame || g_BlockGame) {
		return;
	}
	
	if(!getUsersAlive()) {
		if(g_Wave) {
			g_NextWaveIncoming = 0;
			g_TotalMonsters = 59;
			
			clearDHUDs();
			entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
			
			set_task(64.0, "startWave", TASK_WAVES);
			set_task(1.0, "repeatHUD", _, _, _, "a", 60);
		} else {
			g_StartGame = 1;
			g_StartSeconds = 59;
			g_NextWaveIncoming = 0;
			
			set_task(60.0, "checkStartGame", TASK_START_GAME);
			set_task(1.0, "repeatHUD2", TASK_START_GAME, _, _, "a", 59);
			set_task(59.0, "__endVote_Difficulty");
		}
		
		return;
	}
	
	g_MonstersAlive = 0;
	g_NextWaveIncoming = 0;
	g_WaveInProgress = 1;
	g_MonstersKills = 0;
	g_EggCache = 0;
	g_BestUserKills = 0;
	g_BestUserId = 0;
	g_SpecialMonsters_Spawn = 0;
	g_SpecialMonsters_Kills = 0;
	g_Monsters_Spawn = 0;
	g_Monsters_Kills = 0;
	g_SpecialWave = 0;
	g_SendMonsterSpecial = 0;
	// g_RobotMissileAllowed = 1;
	
	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		g_SupportHab[i] = 0;
		g_PoderScouter[i] = 0;
	}

	if(g_Wave == 1337) {
		g_Wave = 10;
		__endGame();
		
		return;
	} else if(g_Wave == 1338) {
		g_Wave = 10;
	}
	
	if((g_Wave + 1) == g_ExtraWaveSpeed && g_Difficulty >= DIFF_SUICIDAL) {
		g_SpecialWave = ROUND_SPECIAL_SPEED;
		
		removeAllEnts(0);
		
		g_TotalMonsters = 0;
		g_TotalMonsters += random_num(50, 75);
		
		g_MonstersShield = 0;
		g_MonstersWithShield = 6;
		
		clearDHUDs();
		entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
		
		set_task(0.5, "countDown__SendMonsters");
		
		return;
	} else if((g_Wave + 1) == g_ExtraWaveStrength && g_Difficulty >= DIFF_HELL) {
		g_SpecialWave = ROUND_SPECIAL_STRENGTH;
		
		removeAllEnts(0);
		
		g_TotalMonsters = 0;
		g_TotalMonsters += random_num(25, 50);
		
		g_MonstersShield = 0;
		g_MonstersWithShield = 6;
		
		clearDHUDs();
		entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
		
		set_task(0.5, "countDown__SendMonsters");
		
		return;
	}
	
	++g_Wave;
	
	if(g_Wave < 11) {
		removeAllEnts(0);

		g_DamageForKill = 2000;

		if(DIFFICULTIES_VALUES[g_Difficulty][difficultyHealth]) {
			g_DamageForKill = g_DamageForKill + ((g_DamageForKill * DIFFICULTIES_VALUES[g_Difficulty][difficultyHealth]) / 100);
		}
		
		g_TotalMonsters = 0;
		g_TotalMonsters += clamp(getUsersAlive(), 2, 10) * random_num(4, 5) * g_Wave;
		
		if(DIFFICULTIES_VALUES[g_Difficulty][difficultyMaxMonsters]) {
			g_TotalMonsters = g_TotalMonsters + ((g_TotalMonsters * (DIFFICULTIES_VALUES[g_Difficulty][difficultyMaxMonsters])) / 100);
		}
		
		if(MAPS_DESC[g_MapId][mapExtraMonsters] > 0) {
			g_TotalMonsters = g_TotalMonsters + ((g_TotalMonsters * MAPS_DESC[g_MapId][mapExtraMonsters]) / 100);
		}
		
		if(g_Tramposo) {
			g_TotalMonsters = 20;
		}
		
		--g_TotalMonsters;
		
		g_MonstersShield = 0;
		g_MonstersWithShield = (g_TotalMonsters * 10) / 100;
		
		g_TimePerWave_SysTime[g_Wave - 1] = get_systime();
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}
			
			copy(g_TimePerWave_Users[i], 31, g_UserName[i]);
		}
		
		clearDHUDs();
		entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);

		switch(g_Wave) {
			case 1: {
				for(i = 1; i <= g_MaxUsers; ++i) {
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
							give_item(i, "weapon_m4a1");
							cs_set_user_bpammo(i, CSW_M4A1, 200);
						}
						case CLASS_INGENIERO: {
							++g_Sentry[i];
						}
						case CLASS_FRANCOTIRADOR: {
							if(user_has_weapon(i, CSW_SMOKEGRENADE))
								cs_set_user_bpammo(i, CSW_SMOKEGRENADE, cs_get_user_bpammo(i, CSW_SMOKEGRENADE) + 1);
							else
								give_item(i, "weapon_smokegrenade");
							
							++g_Nades[i][NADE_AUMENTA_DMG_RECIBIDO];
						}
						case CLASS_PESADO: {
							++g_Power[i][POWER_RAYO];
						}
						case CLASS_ASALTO: {
							give_item(i, "weapon_galil");
							cs_set_user_bpammo(i, CSW_GALIL, 200);
						}
						case CLASS_COMANDANTE: {
							give_item(i, "weapon_aug");
							cs_set_user_bpammo(i, CSW_AUG, 200);
						} case CLASS_PUBERO: {
							give_item(i, "weapon_g3sg1");
							cs_set_user_bpammo(i, CSW_G3SG1, 200);
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
			if(g_Difficulty == DIFF_NORMAL && g_Wave >= 8) {
				g_EggCache = 1;
			} else if(g_Difficulty == DIFF_NIGHTMARE && g_Wave >= 5) {
				g_EggCache = 1;
			} else if(g_Difficulty == DIFF_HELL || g_Difficulty == DIFF_SUICIDAL) {
				g_EggCache = 1;
			}
		}
		
		set_task(0.5, "countDown__SendMonsters");
	} else {
		new i;
		new j;
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}
			
			g_Unlimited_Clip[i] = 0;
			g_PrecisionPerfecta[i] = 0;
			
			hamStripWeapons(i, "weapon_hegrenade");
			hamStripWeapons(i, "weapon_flashbang");
			hamStripWeapons(i, "weapon_smokegrenade");
			
			reloadWeapons(i);
			
			g_Sentry[i] = 0;
			// g_Robot[i] = 0;
			
			for(j = 0; j < Powers; ++j) {
				if(j == POWER_BALAS_INFINITAS || j == POWER_PRECISION_PERFECTA) {
					continue;
				}
				
				g_Power[i][j] = 0;
			}
			
			set_user_health(i, 500);
			
			g_PowerActual[i] = POWER_NONE;
		}
		
		removeAllEnts(1);
		
		g_NextWaveIncoming = 2;
		
		clearDHUDs();
		entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
		
		createMiniBoss();
		__specialEffectToBoss();
	}
}

public countDown__SendMonsters() {
	if(!g_EndGame) {
		if(!g_SpecialWave) {
			sendMonsters(ROUND_NORMAL, g_TotalMonsters, 0);
		} else {
			sendMonsters(g_SpecialWave, g_TotalMonsters, 0);
		}
	}
}

public sendMonsters(const roundType, monsterNum, const monsterTrack) {
	if(g_MonstersAlive >= 30) {
		if(monsterNum) {
			g_TempRoundType = roundType;
			g_TempMonsterNum = monsterNum;
			g_TempMonsterTrack = monsterTrack;
			
			set_task(random_float(1.0, 2.0), "sendMonsters__Post");
		}
		
		return;
	}
	
	if(!g_WaveInProgress) {
		return;
	}
	
	new iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, ENT_MONSTER_CLASSNAME);
		
		static sModel[64];
		static iHealth;
		static Float:fVelocity;
		static Float:flNext;
		static iSpecial;
		static iUniqueZombie;
		
		iSpecial = 0;
		iUniqueZombie = 0;
		
		--monsterNum;
		
		if(!monsterNum && g_SendMonsterSpecial) {
			iSpecial = 1;
		}
		
		switch(roundType) {
			case ROUND_NORMAL: {
				switch(iSpecial) {
					case 1: {
						iHealth = (getTotalLevelG() * random_num(200, 300)) + (g_Wave * 10000);

						formatex(sModel, charsmax(sModel), "models/%s.mdl", MONSTER_MODEL_SPECIAL[iSpecial - 1]);

						entity_set_int(iEnt, MONSTER_UNIQUE, ZOMBIE_NORMAL);
					} default: {
						iHealth = (random_num(150, 225) * (clamp(g_Wave, 2, 99) / 2));

						if((monsterNum % 20) != 0 || !monsterNum) {
							formatex(sModel, charsmax(sModel), "models/%s.mdl", MONSTER_MODELS_NORMAL[g_ZombieModels]);

							if(++g_ZombieModels > charsmax(MONSTER_MODELS_NORMAL)) {
								g_ZombieModels = 0;
							}

							entity_set_int(iEnt, MONSTER_UNIQUE, ZOMBIE_NORMAL);
						} else {
							formatex(sModel, charsmax(sModel), "models/%s.mdl", MONSTER_UNIQUE_MODELS[ZOMBIE_ALIEN-1]);
							entity_set_int(iEnt, MONSTER_UNIQUE, ZOMBIE_ALIEN);

							iHealth *= 2;
							iUniqueZombie = 1;
						}
					}
				}
				
				if(!MAPS_DESC[g_MapId][mapSpecial]) {
					flNext = random_float(0.4, 0.5);
				} else {
					flNext = random_float(0.2, 0.3);
				}
			} case ROUND_SPECIAL_SPEED: {
				formatex(sModel, charsmax(sModel), "models/%s.mdl", MONSTER_MODELS_SPEED[random_num(0, charsmax(MONSTER_MODELS_SPEED))]);
				
				iHealth = random_num(50, 75) * getUsersAlive();

				if(!MAPS_DESC[g_MapId][mapSpecial]) {
					flNext = random_float(0.2, 0.4);
				} else {
					flNext = random_float(0.1, 0.2);
				}
			} case ROUND_SPECIAL_STRENGTH: {
				formatex(sModel, charsmax(sModel), "models/%s.mdl", MONSTER_MODELS_NORMAL[g_ZombieModels]);

				if(++g_ZombieModels > charsmax(MONSTER_MODELS_NORMAL)) {
					g_ZombieModels = 0;
				}
				
				iHealth = random_num(750, 1125) * getUsersAlive();

				if(!MAPS_DESC[g_MapId][mapSpecial]) {
					flNext = random_float(1.0, 2.0);
				} else {
					flNext = random_float(0.5, 1.0);
				}
			}
		}
		
		dllfunc(DLLFunc_Spawn, iEnt);
		
		if(DIFFICULTIES_VALUES[g_Difficulty][difficultyHealth] && roundType != ROUND_SPECIAL_STRENGTH) {
			iHealth = iHealth + ((iHealth * DIFFICULTIES_VALUES[g_Difficulty][difficultyHealth]) / 100);
		}
		
		if(iHealth > g_MaxHealth && !iSpecial && !iUniqueZombie) {
			iHealth = g_MaxHealth;
		}
		
		entity_set_model(iEnt, sModel);
		entity_set_float(iEnt, EV_FL_health, float(iHealth));
		entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_YES);
		entity_set_origin(iEnt, g_VecStartOrigin[monsterTrack]);
		entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);

		entity_set_int(iEnt, EV_INT_sequence, (iSpecial != 1) ? 4 : 3);

		entity_set_float(iEnt, EV_FL_animtime, get_gametime());
		entity_set_float(iEnt, EV_FL_gravity, 1.0);
		
		entity_set_int(iEnt, EV_INT_team, monsterTrack);
		
		entity_set_int(iEnt, EV_INT_gamestate, 1);
		
		entity_set_int(iEnt, MONSTER_TARGET, 0);
		
		if(!iSpecial) {
			entity_set_int(iEnt, MONSTER_TYPE, roundType);
			entity_set_int(iEnt, MONSTER_LOW_FPS, 1);
			
			fVelocity = getVelocity();
		} else {
			entity_set_int(iEnt, MONSTER_TYPE, MONSTER_SPECIAL);
			
			fVelocity = 50.0;
			
			g_GordoHealth = iHealth;
		}
		
		if(g_MonstersShield < g_MonstersWithShield && !iUniqueZombie && !iSpecial) {
			new iRandom = random_num(1, 5);
			if(iRandom == 1) {
				++g_MonstersShield;
				
				entity_set_float(iEnt, MONSTER_SHIELD, 1.0);
				
				fm_set_rendering(iEnt, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 4);
			}
		}
		
		if(!g_FixStart[monsterTrack]) {
			drop_to_floor(iEnt);
			
			entity_get_vector(iEnt, EV_VEC_origin, g_VecStartOrigin[monsterTrack]);

			g_VecStartOrigin[monsterTrack][2] += 30.0;
			
			entity_set_origin(iEnt, g_VecStartOrigin[monsterTrack]);
			
			g_FixStart[monsterTrack] = 1;
		}

		static Float:vecMins[3];
		static Float:vecMax[3];
		
		vecMins = Float:{-16.0, -16.0, -30.0};
		vecMax = Float:{16.0, 16.0, 36.0};
		
		entity_set_size(iEnt, vecMins, vecMax);
		
		entity_set_vector(iEnt, EV_VEC_mins, vecMins);
		entity_set_vector(iEnt, EV_VEC_maxs, vecMax);
		
		entity_set_float(iEnt, MONSTER_SPEED, fVelocity);
		
		if(!iSpecial) {
			entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
		} else {
			entity_set_float(iEnt, EV_FL_framerate, 1.5);
		}
		
		entity_set_int(iEnt, MONSTER_MAXHEALTH, iHealth);
		
		static Float:vecMonsterOrigin[3];
		entity_get_vector(iEnt, EV_VEC_origin, vecMonsterOrigin);
		
		++g_MonstersAlive;
		++g_Monsters_Spawn;
		
		static Float:vecTargetOrigin[3];
		static iTarget;
		
		if(!monsterTrack) {
			entity_set_int(iEnt, MONSTER_TRACK, 1);
			iTarget = find_ent_by_tname(-1, "track1");
		} else {
			entity_set_int(iEnt, MONSTER_TRACK, 100);
			iTarget = find_ent_by_tname(-1, "track100");
		}
		
		entity_get_vector(iTarget, EV_VEC_origin, vecTargetOrigin);
		
		entitySetAim(iEnt, vecMonsterOrigin, vecTargetOrigin, fVelocity);
		
		if(monsterNum) {
			g_TempRoundType = roundType;
			g_TempMonsterNum = monsterNum;
			
			if(MAPS_DESC[g_MapId][mapSpecial]) {
				g_TempMonsterTrack = !monsterTrack;
			}
			
			set_task(flNext, "sendMonsters__Post");
		}
	}
}

public sendMonsters__Post() {
	sendMonsters(g_TempRoundType, g_TempMonsterNum, g_TempMonsterTrack);
}

public removeAllEnts(const sentry) {
	if(g_FinishGame) {
		return;
	}

	new iEnt;
	
	iEnt = find_ent_by_class(-1, ENT_MONSTER_CLASSNAME);
	while(is_valid_ent(iEnt)) {
		entity_set_int(iEnt, MONSTER_TYPE, 0);
		entity_set_int(iEnt, MONSTER_TRACK, 0);
		entity_set_int(iEnt, MONSTER_MAXHEALTH, 0);
		entity_set_float(iEnt, MONSTER_SPEED, 0.0);
		
		entity_set_edict(iEnt, MONSTER_HEALTHBAR, 0);
		
		remove_task(iEnt + TASK_SPECIAL_HEAL);
		
		remove_entity(iEnt);
		
		iEnt = find_ent_by_class(-1, ENT_MONSTER_CLASSNAME);
	}
	
	iEnt = find_ent_by_class(-1, ENT_SPECIAL_MONSTER_CLASSNAME);
	while(is_valid_ent(iEnt)) {
		entity_set_int(iEnt, MONSTER_MAXHEALTH, 0);
		
		remove_entity(iEnt);
		
		iEnt = find_ent_by_class(-1, ENT_SPECIAL_MONSTER_CLASSNAME);
	}
	
	iEnt = find_ent_by_class(-1, ENT_EGG_MONSTER_CLASSNAME);
	while(is_valid_ent(iEnt)) {
		remove_entity(iEnt);
		
		iEnt = find_ent_by_class(-1, ENT_EGG_MONSTER_CLASSNAME);
	}
	
	if(sentry) {
		iEnt = find_ent_by_class(-1, ENT_SENTRY_CLASSNAME);
		while(is_valid_ent(iEnt)) {
			remove_entity(iEnt);
			
			iEnt = find_ent_by_class(-1, ENT_SENTRY_CLASSNAME);
		}
		
		iEnt = find_ent_by_class(-1, ENT_SENTRY_BASE_CLASSNAME);
		while(is_valid_ent(iEnt)) {
			remove_entity(iEnt);
			
			iEnt = find_ent_by_class(-1, ENT_SENTRY_BASE_CLASSNAME);
		}
	}
	
	iEnt = find_ent_by_class(-1, ENT_MINIBOSS_CLASSNAME);
	while(is_valid_ent(iEnt)) {
		remove_entity(iEnt);
		
		iEnt = find_ent_by_class(-1, ENT_MINIBOSS_CLASSNAME);
	}
	
	iEnt = find_ent_by_class(-1, ENT_BOSS_CLASSNAME);
	while(is_valid_ent(iEnt)) {
		remove_entity(iEnt);
		
		iEnt = find_ent_by_class(-1, ENT_BOSS_CLASSNAME);
	}
	
	iEnt = find_ent_by_class(-1, ENT_BOSS_GUARDIANS);
	while(is_valid_ent(iEnt)) {
		remove_entity(iEnt);
		
		iEnt = find_ent_by_class(-1, ENT_BOSS_GUARDIANS);
	}
	
	if(g_FORWARD_AddToFullPack_Status) {
		g_FORWARD_AddToFullPack_Status = 0;
		unregister_forward(FM_AddToFullPack, g_FORWARD_AddToFullPack, 1);
	}
	
	if(is_valid_ent(g_Boss_HealthBar)) {
		remove_entity(g_Boss_HealthBar);
	}
}

public checkMap() {
	new iEnt;
	new i;
	new j = 0;
	
	for(i = 0; i < 2; ++i) {
		iEnt = find_ent_by_tname(-1, (!i) ? "start" : "start1");
		if(is_valid_ent(iEnt) && iEnt != 0) {
			j = 1;
			
			entity_get_vector(iEnt, EV_VEC_origin, g_VecStartOrigin[i]);
			
			new iSprite;
			iSprite = create_entity("env_sprite");
			
			if(!is_valid_ent(iSprite))
				return 0;
			
			entity_set_model(iSprite, MONSTER_SPRITE_SPAWN);
			
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
	
	if(!j) {
		return 0;
	}
	
	j = 0;
	
	for(i = 0; i < 2; ++i) {
		iEnt = find_ent_by_tname(-1, (!i) ? "end" : "end1");
		if(is_valid_ent(iEnt) && iEnt != 0) {
			j = 1;
			entity_get_vector(iEnt, EV_VEC_origin, g_VecEndOrigin[i]);
			
			g_Tower[i] = create_entity("info_target");
			
			entity_set_string(g_Tower[i], EV_SZ_classname, "entEnd");
			entity_set_model(g_Tower[i], TOWER_MODEL);
			
			entity_set_origin(g_Tower[i], g_VecEndOrigin[i]);
			
			entity_set_int(g_Tower[i], EV_INT_solid, SOLID_BBOX);
			entity_set_int(g_Tower[i], EV_INT_movetype, MOVETYPE_TOSS);
			
			drop_to_floor(g_Tower[i]);
			
			entity_set_size(g_Tower[i], Float:{-114.419998, -116.209999, -104.780029}, Float:{117.220001, 114.709999, 574.730003});
			
			g_VecEndOrigin[i][2] -= 40.0;
			
			entity_set_origin(g_Tower[i], g_VecEndOrigin[i]);
			
			entity_get_vector(g_Tower[i], EV_VEC_origin, g_VecEndOrigin[i]);
		}
	}

	g_TowerHealth = MAPS_DESC[g_MapId][mapTowerHealth];
	g_TOWER_MAX_HEALTH = g_TowerHealth;
	
	if(!j) {
		return 0;
	}
	
	iEnt = find_ent_by_tname(-1, "respawn_special");
	if(is_valid_ent(iEnt) && iEnt != 0) {
		entity_get_vector(iEnt, EV_VEC_origin, g_VecSpecialOrigin);

		if(equali(MAPS_DESC[g_MapId][mapName], "td_ksub") || equali(MAPS_DESC[g_MapId][mapName], "td_ksub_wool")) {
			g_VecSpecialOrigin[2] -= 48.0; // 24.0
		}
	}
	
	iEnt = find_ent_by_tname(-1, "respawn_special2");
	if(is_valid_ent(iEnt) && iEnt != 0) {
		entity_get_vector(iEnt, EV_VEC_origin, g_VecSpecial2Origin);

		if(equali(MAPS_DESC[g_MapId][mapName], "td_kwhite")) {
			g_VecSpecial2Origin[2] -= 12.0;
		} else if(equali(MAPS_DESC[g_MapId][mapName], "td_ksub") || equali(MAPS_DESC[g_MapId][mapName], "td_ksub_wool")) {
			g_VecSpecial2Origin[2] -= 48.0; // 24.0
		}
	}
	
	return 1;
}

public fw_TraceAttack(const victim, const attacker, const Float:damage, const Float:direction[3], const tracehandle, const damage_type) {
	if(is_user_alive(victim)) {
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public fw_TakeDamage(const victim, const inflictor, const attacker, Float:damage, const damage_type) {
	if(is_user_alive(victim)) {
		if(damage_type == 131072 && damage > 300000.0) {
			setAchievement(victim, KSUB_DEATH);
			return HAM_IGNORED;
		}

		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public fw_PlayerSpawn_Post(const id) {
	if(!is_user_alive(id) || !getUserTeam(id)) {
		return;
	}
	
	remove_task(id + TASK_SPAWN);
	
	if(getUserTeam(id) != FM_CS_TEAM_CT) {
		remove_task(id + TASK_TEAM);
		
		setUserTeam(id, FM_CS_TEAM_CT);
		userTeamUpdate(id);
	}
	
	if(g_WaveInProgress) {
		user_silentkill(id);
		
		colorChat(id, TERRORIST, "%sTenés que esperar a la !tsiguiente oleada!y para empezar a jugar. No podés entrar en la mitad!", TD_PREFIX);
		return;
	}
	
	g_HabCache[id][_:HAB_F_DAMAGE] = float(g_Hab[id][HAB_DAMAGE]) * 2.0;
	g_HabCache[id][_:HAB_F_PRECISION] = float(g_Hab[id][HAB_PRECISION]) * 1.25;
	g_HabCache[id][_:HAB_F_VELOCIDAD] = float(g_Hab[id][HAB_VELOCIDAD]) * 1.25;
	g_HabCacheClip[id] = g_Hab[id][HAB_BALAS] * 10;
	
	g_CriticChance[id] = __HABILITIES[HAB_CRITICO][upgValue] * g_Upgrades[id][HAB_CRITICO];
	
	g_Speed[id] = 230.0 + float((__HABILITIES[HAB_SPEED][upgValue] * g_Upgrades[id][HAB_SPEED]));
	
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
	
	g_InBlockZone[id] = 0;
	
	set_task(0.4, "hideHUDs", id + TASK_SPAWN);
	set_task(0.2, "clearWeapons", id + TASK_SPAWN);
	
	cs_set_user_money(id, 0, 0);
}

public fw_PlayerKilled(const victim, const killer, const shouldgib) {
	if(!is_user_connected(victim)) {
		return;
	}

	if(killer == g_Boss) {
		SetHamParamInteger(3, 2);
	}
	
	g_Unlimited_Clip[victim] = 0;
	g_PrecisionPerfecta[victim] = 0;
	
	if(g_Rank[victim] && is_valid_ent(g_Rank[victim])) {
		remove_entity(g_Rank[victim]);
	}

	if(g_Hat[victim] && is_valid_ent(g_Hat[victim])) {
		remove_entity(g_Hat[victim]);
		g_Hat[victim] = 0;
	}

	if(!g_WaveInProgress) {
		set_task(0.3, "respawnUser", victim);
	}

	if(!getUsersAlive()) {
		removeAllEnts(1);
		__finishGame();
	}
}

public fw_Item_Deploy_Post(const weapon_ent) {
	static iId;
	iId = getWeaponEntId(weapon_ent);
	
	if(!pev_valid(iId)) {
		return;
	}
	
	static iWeaponId;
	iWeaponId = get_pdata_int(weapon_ent, OFFSET_ID, OFFSET_LINUX_WEAPONS);
	
	g_CurrentWeapon[iId] = iWeaponId;

	replaceWeaponModels(iId, iWeaponId);

	if(iWeaponId == CSW_KNIFE) {
		set_pdata_float(weapon_ent, OFFSET_NEXT_PRIMARY_ATTACK, 99999.0, OFFSET_LINUX_WEAPONS);
		set_pdata_float(weapon_ent, OFFSET_NEXT_SECONDARY_ATTACK, 99999.0, OFFSET_LINUX_WEAPONS);
	}
}

public fw_MonsterTakeDamage(const monster, const inflictor, const attacker, Float:damage, const damagebits) {
	if(!is_valid_ent(monster) || !is_user_alive(attacker) || !isMonster(monster)) {
		return HAM_IGNORED;
	}
	
	static Float:fShield;
	static iDamage;
	
	fShield = entity_get_float(monster, MONSTER_SHIELD);
	
	damage += ((g_HabCache[attacker][HAB_F_DAMAGE] * damage) / 100.0);
	
	if(g_CurrentWeapon[attacker] == CLASSES_WEAPONS[g_ClassId[attacker]][0] || g_CurrentWeapon[attacker] == CLASSES_WEAPONS[g_ClassId[attacker]][1]) {
		if(CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttrib_Damage]) {
			damage += ((CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttrib_Damage] * damage) / 100.0); 
		}
	}

	if(g_CurrentWeapon[attacker] == CSW_SG550 || g_CurrentWeapon[attacker] == CSW_G3SG1) {
		if(damage > 105.0) {
			damage = random_float(80.0, 105.0);
		}
	}
	
	iDamage = floatround(damage);
	
	if(fShield == 1.0 && (g_ClassId[attacker] != CLASS_SOPORTE || (g_ClassId[attacker] == CLASS_SOPORTE && g_CurrentWeapon[attacker] != CSW_XM1014))) {
		iDamage /= 2;
	} else if(fShield == 2.0) {
		iDamage *= 2;
	}
	
	if(g_CriticChance[attacker]) {
		static iRandom;
		iRandom = random_num(1, 100);

		if(iRandom <= (g_CriticChance[attacker] + CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttrib_ExtraCrit])) {
			fShield = 5.0;
			iDamage *= 2;
		}
	}
	
	g_DamageDone[attacker] = iDamage;
	g_AFK_Damage[attacker] = iDamage;
	
	if(!isSpecialMonster(monster)) {
		while(g_DamageDone[attacker] >= g_DamageNeedToGold) {
			g_DamageDone[attacker] -= g_DamageNeedToGold;
			
			++g_Gold[attacker];
			++g_GoldG[attacker];
		}

		g_DamageDoneForKill[attacker] += iDamage;

		if(g_DamageDoneForKill[attacker] >= g_DamageForKill && g_LevelG[attacker] < 75) {
			g_DamageDoneForKill[attacker] -= g_DamageForKill;
			addKill(attacker);
		}

		__checkAttackerLevelUp(attacker, iDamage);
	} else {
		if(g_GordoHealth) {
			if(g_ClassId[attacker] == CLASS_FRANCOTIRADOR && g_ClassLevel[attacker][CLASS_FRANCOTIRADOR] == 6 && g_CurrentWeapon[attacker] == CSW_AWP && fShield != 5.0) {
				fShield = 5.0;
				iDamage *= 2;
			}

			g_GordoHealth -= iDamage;
		}
	}
	
	if(damagebits & DMG_BULLET) {
		if(fShield != 5.0) {
			set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
			ShowSyncHudMsg(attacker, g_HudDamage, "%d", iDamage);
		} else {
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
			ShowSyncHudMsg(attacker, g_HudDamage, "%d  ¡CRÍTICO!", iDamage);

			if(isSpecialMonster(monster)) {
				++g_Gold[attacker];
				++g_GoldG[attacker];
			}
		}
	}
	
	SetHamParamFloat(4, float(iDamage));
	
	emit_sound(monster, CHAN_BODY, MONSTER_SOUNDS_PAIN[random_num(0, charsmax(MONSTER_SOUNDS_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	// new Float:vecOrigin[3];
	// entity_get_vector(monster, EV_VEC_origin, vecOrigin);

	// vecOrigin[0] += random_float(-2.0, 3.0);
	// vecOrigin[1] += random_float(-2.0, 3.0);
	// vecOrigin[2] += random_float(4.0, 10.0);

	// effectBlood(vecOrigin);
	return HAM_IGNORED;
}

public fw_MonsterTraceAttack(const monster, const attacker, const Float:damage, const Float:direction[3], const traceHandle, const damageType) {
	if(!is_valid_ent(monster) || !is_user_alive(attacker)) {
		return HAM_IGNORED;
	}

	if(!isMonster(monster) && !isBoss(monster)) {
		return HAM_IGNORED;
	}

	new Float:vecEndPos[3];
	get_tr2(traceHandle, TR_vecEndPos, vecEndPos);

	effectBlood(vecEndPos);
	return HAM_IGNORED;
}

public fw_MonsterKilled(const monster, const killer, const shouldgib) {
	if(!is_user_alive(killer) || !isMonster(monster)) {
		return HAM_IGNORED;
	}
	
	set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
	ShowSyncHudMsg(killer, g_HudDamage, "¡MATADO!");
	
	removeMonster(monster, killer);
	
	return HAM_SUPERCEDE;
}

removeMonster(const monster, const killer, rayo=0) { // rm_r
	if(!is_valid_ent(monster)) {
		return;
	}
	
	remove_task(monster + TASK_DAMAGE_TOWER);
	remove_task(monster + TASK_SPECIAL_HEAL);
	
	new iDeadSeq;
	new iUniqueZombie = entity_get_int(monster, MONSTER_UNIQUE);

	switch(random_num(1, 3)) {
		case 1: iDeadSeq = lookup_sequence(monster, "death1");
		case 2: iDeadSeq = lookup_sequence(monster, "death2");
		case 3: iDeadSeq = lookup_sequence(monster, "death3");
	}
	
	if(iDeadSeq == -1) {
		iDeadSeq = lookup_sequence(monster, "death");
	}

	--g_MonstersAlive;
	--g_TotalMonsters;
	++g_MonstersKills;
	
	if(isEggMonster(monster)) {
		++g_SpecialMonsters_Kills;
	} else {
		++g_Monsters_Kills;
	}
	
	if(isSpecialMonster(monster)) {
		g_GordoHealth = 0;
		
		if(is_user_connected(killer)) {
			colorChat(0, CT, "%s!t%s!y ganó !g100 Oro!y por matar al !gGordo Bomba!y.", TD_PREFIX, g_UserName[killer]);
			
			g_Gold[killer] += 100;
			g_GoldG[killer] += 100;
			
			++g_GordoBomba_Kills[killer];
			
			if(g_GordoBomba_Kills[killer] == 2) {
				colorChat(0, CT, "%s!t%s!y ganó !gBalas Infinitas x1!y por matar dos !gGordo Bomba!y en el mismo mapa.", TD_PREFIX, g_UserName[killer]);
				
				++g_Power[killer][POWER_BALAS_INFINITAS];
			}
		}
	}

	if(g_TotalMonsters == 666) {
		new i;
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}

			if(!g_AccountLogged[i]) {
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
	//entity_set_float(monster, EV_FL_frame, 3.0);
	
	emit_sound(monster, CHAN_BODY, MONSTER_SOUNDS_DEATH[random_num(0, charsmax(MONSTER_SOUNDS_DEATH))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	if(is_user_connected(killer)) {
		++g_Kills[killer];
		
		if(!g_Boss) {
			++g_KillsPerWave[killer][g_Wave];
			
			if(g_KillsPerWave[killer][g_Wave] > g_BestUserKills) {
				g_BestUserKills = g_KillsPerWave[killer][g_Wave];
				g_BestUserId = killer;
				
				g_MVP_More = 0;
				
				new i;
				for(i = 1; i <= g_MaxUsers; ++i) {
					if(!is_user_connected(i)) {
						continue;
					}
					
					if(i == g_BestUserId) {
						continue;
					}
					
					if(g_KillsPerWave[i][g_Wave] == g_BestUserKills) {
						++g_MVP_More;
					}
				}
			}

			if(iUniqueZombie == ZOMBIE_ALIEN) {
				addKillsToEveryone(1);
			}
		}
		
		if(!rayo) {
			__checkKillerLevelUp(killer);
		}
		
		set_user_frags(killer, get_user_frags(killer) + 1);
		
		message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
		write_byte(killer);
		write_short(get_user_frags(killer));
		write_short(cs_get_user_deaths(killer));
		write_short(0);
		write_short(getUserTeam(killer));
		message_end();
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
		g_Boss_TimePower[0] = get_gametime() + 15.0;
		
		entity_set_int(g_Boss, EV_INT_rendermode, kRenderTransAlpha);
		entity_set_float(g_Boss, EV_FL_renderamt, 255.0);
		
		set_task(0.5, "__backToRide", g_Boss);
	} else if(g_TotalMonsters == 3 && (g_BossPower[0] == BOSS_POWER_EGGS || g_BossPower[1] == BOSS_POWER_EGGS)) {
		new i;
		for(i = 0; i < 2; ++i) {
			if(is_valid_ent(g_Boss_Guardians_Ids[i])) {
				g_BossPower[i] = 0;
				g_Boss_TimePower[i] = get_gametime() + 15.0;
				
				entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_renderamt, 255.0);
				
				set_task(0.5, "__backToRide", g_Boss_Guardians_Ids[i]);
			}
		}
	}
	
	clearDHUDs();
	entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
	
	if(entity_get_int(monster, MONSTER_TARGET) == 1337) {
		entity_set_int(monster, MONSTER_TARGET, 0);
		
		new iEnt = -1;
		new iMonstersInTower = 0;
		
		while((iEnt = fm_find_ent_by_class(iEnt, ENT_MONSTER_CLASSNAME))) {
			if(entity_get_int(monster, MONSTER_TARGET) == 1337) {
				++iMonstersInTower;
			}
		}
		
		if(!iMonstersInTower) {
			ClearSyncHud(0, g_HudDamageTower);
		}
	}
	
	if(g_Wave <= MAX_WAVES) {
		remove_task(TASK_BUGFIX);
		set_task(6.0, "checkZombiesBug", TASK_BUGFIX);
	}

	if(killer == 15000) {
		return;
	} else if(killer == 16000) {
		new Float:vecOrigin[3];
		new iOrigin[3];

		entity_get_vector(monster, EV_VEC_origin, vecOrigin);

		iOrigin[0] = floatround(vecOrigin[0]);
		iOrigin[1] = floatround(vecOrigin[1]);
		iOrigin[2] = floatround(vecOrigin[2]);

		explodeInGibs(.origin=iOrigin, .up=40, .model=g_Model_GibSkull, .lifeTime=50);
		explodeInGibs(.origin=iOrigin, .up=40, .model=g_ModelGibBone, .lifeTime=50);
		explodeInGibs(.origin=iOrigin, .up=40, .model=g_ModelGibGib, .lifeTime=50);
		explodeInGibs(.origin=iOrigin, .up=40, .model=g_ModelGibGib, .lifeTime=50);
		explodeInGibs(.origin=iOrigin, .up=40, .model=g_Model_GibLeg, .lifeTime=50);
		explodeInGibs(.origin=iOrigin, .up=40, .model=g_Model_GibLung, .lifeTime=50);

		if(is_valid_ent(monster)) {
			remove_entity(monster);
		}

		return;
	}
	
	set_task(5.0, "deleteMonsterEnt", monster);
}

public explodeInGibs(const origin[3], const up, const model, const lifeTime) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_MODEL);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2] + up);
	write_coord(80 + random_num(0, 80));
	write_coord(80 + random_num(0, 80));
	write_coord(80 + random_num(80, 200));
	write_angle(random_num(0, 360));
	write_short(model);
	write_byte(0);
	write_byte(lifeTime);
	message_end();
}

public deleteMonsterEnt(const monster) {
	if(is_valid_ent(monster)) {
		remove_entity(monster);
	}
}

public checkZombiesBug(const monster) {
	if(!g_WaveInProgress) {
		return;
	}
	
	new iEnt = -1;
	new iMonstersAlive = 0;
	
	while((iEnt = fm_find_ent_by_class(iEnt, ENT_MONSTER_CLASSNAME))) {
		if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
			++iMonstersAlive;
		}
	}
	
	iEnt = -1;
	while((iEnt = fm_find_ent_by_class(iEnt, ENT_EGG_MONSTER_CLASSNAME))) {
		if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
			++iMonstersAlive;
		}
	}
	
	iEnt = -1;
	while((iEnt = fm_find_ent_by_class(iEnt, ENT_SPECIAL_MONSTER_CLASSNAME))) {
		if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
			++iMonstersAlive;
		}
	}
	
	while(g_MonstersAlive > iMonstersAlive) {
		// log_to_file("td_bug.log", "g_MonstersAlive=%d | g_TotalMonsters=%d | g_WaveInProgress=%d | Wave=%d", g_MonstersAlive, g_TotalMonsters, g_WaveInProgress, g_Wave);
		// log_to_file("td_bug.log", "g_SpecialMonsters_Spawn=%d | g_SpecialMonsters_Kills=%d | g_Monsters_Spawn=%d | g_Monsters_Kills=%d", g_SpecialMonsters_Spawn, g_SpecialMonsters_Kills, g_Monsters_Spawn, g_Monsters_Kills);
		// log_to_file("td_bug.log", "iMonstersAlive=%d", iMonstersAlive);
		
		// new Float:vecOrigin[3];
		
		// iEnt = -1;
		// while((iEnt = fm_find_ent_by_class(iEnt, ENT_MONSTER_CLASSNAME))) {
			// if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file("td_bug.log", "VIVO (1) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// } else {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file("td_bug.log", "MUERTO (1) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// }
		// }
		
		// iEnt = -1;
		// while((iEnt = fm_find_ent_by_class(iEnt, ENT_EGG_MONSTER_CLASSNAME))) {
			// if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file("td_bug.log", "VIVO (2) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// } else {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file("td_bug.log", "MUERTO (2) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// }
		// }
		
		// iEnt = -1;
		// while((iEnt = fm_find_ent_by_class(iEnt, ENT_SPECIAL_MONSTER_CLASSNAME))) {
			// if(entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file("td_bug.log", "VIVO (3) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// } else {
				// entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				// log_to_file("td_bug.log", "MUERTO (3) | Coord: %f, %f, %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
			// }
		// }
		
		--g_MonstersAlive;
		--g_TotalMonsters;
	}
	
	if(g_TotalMonsters < 1) {
		endWave();
	}
}

public fw_MiniBoss_TakeDamage(const miniBoss, const inflictor, const attacker, Float:damage, const damagebits) {
	if(!is_valid_ent(miniBoss) || !is_user_alive(attacker)) {
		return HAM_IGNORED;
	}
	
	new Float:vecOrigin[3];
	entity_get_vector(miniBoss, EV_VEC_origin, vecOrigin);
	
	vecOrigin[0] += random_float(-2.0, 3.0);
	vecOrigin[1] += random_float(-2.0, 3.0);
	vecOrigin[2] += random_float(4.0, 10.0);
	
	if(!entity_get_int(miniBoss, MONSTER_MAXHEALTH)) {
		set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
		ShowSyncHudMsg(attacker, g_HudDamage, "¡INVULNERABLE!");
		
		SetHamParamFloat(4, 0.0);
		
		effectBlood(vecOrigin);
		return HAM_IGNORED;
	}
	
	new iDamage;
	iDamage = floatround(damage);
	
	__checkAttackerLevelUp(attacker, iDamage);
	
	if(damagebits & DMG_BULLET) {
		set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
		ShowSyncHudMsg(attacker, g_HudDamage, "%0.0f", damage);
	}
	
	emit_sound(miniBoss, CHAN_BODY, MONSTER_SOUNDS_PAIN[random_num(0, charsmax(MONSTER_SOUNDS_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	effectBlood(vecOrigin);
	return HAM_IGNORED;
}

public fw_MiniBoss_Killed(const miniBoss, const killer, const shouldgib) {
	if(!is_valid_ent(miniBoss) || !is_user_alive(killer)) {
		return HAM_IGNORED;
	}
	
	if(!entity_get_int(miniBoss, MONSTER_MAXHEALTH)) {
		return HAM_IGNORED;
	}
	
	entity_set_int(miniBoss, EV_INT_sequence, 2);
	entity_set_float(miniBoss, EV_FL_animtime, get_gametime());
	entity_set_float(miniBoss, EV_FL_framerate, 1.0);
	
	entity_set_int(miniBoss, EV_INT_gamestate, 1);
	
	entity_set_float(miniBoss, EV_FL_health, 9999.0);
	entity_set_int(miniBoss, MONSTER_MAXHEALTH, 0);
	
	new Float:vecMins[3];
	new Float:vecMax[3];
	
	vecMins = Float:{-16.0, -16.0, -18.0};
	vecMax = Float:{16.0, 16.0, 32.0};
	
	entity_set_size(miniBoss, vecMins, vecMax);
	
	entity_set_vector(miniBoss, EV_VEC_mins, vecMins);
	entity_set_vector(miniBoss, EV_VEC_maxs, vecMax);
	
	drop_to_floor(miniBoss);
	
	entity_set_vector(miniBoss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
	
	entity_set_int(miniBoss, EV_INT_solid, SOLID_NOT);
	
	entity_set_float(miniBoss, EV_FL_nextthink, get_gametime() + 9999.0);
	
	if(g_BossId != BOSS_GUARDIANES) {
		set_task(3.0, "__effectSpecialBoss", miniBoss);
	} else {
		new i;
		for(i = 0; i < 3; ++i) {
			if(entity_get_int(g_MiniBoss_Ids[i], MONSTER_MAXHEALTH)) {
				return HAM_SUPERCEDE;
			}
		}
		
		set_task(3.0, "__effectSpecialBoss", miniBoss);
	}
	
	return HAM_SUPERCEDE;
}

public fw_Boss_TakeDamage(const boss, const inflictor, const attacker, Float:damage, const damagebits) {
	if(!is_valid_ent(boss) || !is_user_alive(attacker)) {
		return HAM_IGNORED;
	}
	
	if(isMonster(boss)) {
		return HAM_IGNORED;
	}

	damage += ((g_HabCache[attacker][HAB_F_DAMAGE] * damage) / 100.0);
	
	if(g_CurrentWeapon[attacker] == CLASSES_WEAPONS[g_ClassId[attacker]][0] || g_CurrentWeapon[attacker] == CLASSES_WEAPONS[g_ClassId[attacker]][1]) {
		if(CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttrib_Damage]) {
			damage += ((CLASSES_ATTRIB[g_ClassId[attacker]][g_ClassLevel[attacker][g_ClassId[attacker]]][classAttrib_Damage] * damage) / 100.0); 
		}
	}

	if(g_CurrentWeapon[attacker] == CSW_SG550 || g_CurrentWeapon[attacker] == CSW_G3SG1) {
		if(damage > 105.0) {
			damage = random_float(80.0, 105.0);
		}
	}

	static Float:flHealth;
	flHealth = entity_get_float(boss, EV_FL_health);

	switch(g_BossId) {
		case BOSS_GORILA: {
			if(flHealth < g_Boss_Gorila_AttractPowerHP[0]) {
				g_Boss_Gorila_AttractPowerHP[0] = -10000;

				entity_set_float(boss, EV_FL_nextthink, get_gametime() + 9999.9);

				g_BossPower[0] = BOSS_POWER_ATTRACT;
				g_BossLastPower[0] = g_BossPower[0];
				
				entity_set_int(boss, EV_INT_sequence, 0);
				entity_set_float(boss, EV_FL_animtime, get_gametime());
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				fm_set_rendering(boss, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
				
				set_lights("a");
				
				new Float:flEndTime = 3.7;
				new Float:flRepeat = (flEndTime / 0.1) - 1.0;
				
				set_task(0.1, "bossPower_Closer", boss, _, _, "a", floatround(flRepeat));
				set_task(flEndTime, "__endBossPower_Closer", boss);

				entity_set_int(boss, MONSTER_TARGET, 0);
			}
		} case BOSS_FIRE: {
			if(!g_BossPower[0] && !g_Boss_Fire_Ultimate && flHealth <= g_Boss_Fire_UltimateHealth) {
				g_Boss_Fire_Ultimate = 1;
				
				new Float:flGameTime = get_gametime();
				
				g_BossPower[0] = BOSS_POWER_FIREBALL_RAIN;
				g_Boss_TimePower[0] = flGameTime + 16.0;
				
				entity_set_int(boss, EV_INT_sequence, 12);
				entity_set_float(boss, EV_FL_animtime, flGameTime);
				entity_set_float(boss, EV_FL_framerate, 1.0);
				
				entity_set_int(boss, EV_INT_gamestate, 1);
				
				entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
				entity_set_float(boss, EV_FL_nextthink, flGameTime + 10.4);
				
				set_task(4.4, "bossPower__Ultimate", boss);
			}
		} case BOSS_FALLEN_TITAN: {
			if(!g_BossPower[0]) {
				if(flHealth <= g_Boss_FT_UltimateHealth) {
					g_Boss_FT_UltimateHealth = -10000;
					
					new Float:flGameTime = get_gametime();
					
					g_BossPower[0] = BOSS_FT_SCREAM;
					g_Boss_TimePower[0] = flGameTime + 8.0;
					
					entity_set_int(boss, EV_INT_sequence, 4); // SCREAM
					entity_set_float(boss, EV_FL_animtime, flGameTime);
					entity_set_float(boss, EV_FL_framerate, 1.0);
					
					entity_set_int(boss, EV_INT_gamestate, 1);
					
					entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
					entity_set_float(boss, EV_FL_nextthink, flGameTime + 4.7);

					client_cmd(0, "spk ^"%s^"", SOUND_FT_SCREAM);
					
					set_task(0.66, "bossFallenTitan__Screaming");
					set_task(4.69, "bossFT__StartHyperCannon");
				} else if(!g_Boss_FT_HyperUltimate && flHealth <= 3500) {
					g_Boss_FT_HyperUltimate = 1;

					client_cmd(0, "spk ^"%s^"", SOUND_FT_SCREAM);
					bossFT__InfiniteCannons();
				}
			}
		} case BOSS_GUARDIANES: {
			new bossIndex = -1;

			if(boss == g_Boss_Guardians_Ids[0]) {
				bossIndex = 0;
			} else if(boss == g_Boss_Guardians_Ids[1]) {
				bossIndex = 1;
			}

			if(bossIndex != -1) {
				if(flHealth < g_Boss_Gorila_AttractPowerHP[bossIndex]) {
					g_Boss_Gorila_AttractPowerHP[bossIndex] = -10000;

					entity_set_float(boss, EV_FL_nextthink, get_gametime() + 9999.9);

					g_BossPower[bossIndex] = BOSS_POWER_ATTRACT;
					g_BossLastPower[bossIndex] = g_BossPower[bossIndex];
					
					entity_set_int(boss, EV_INT_sequence, 0);
					entity_set_float(boss, EV_FL_animtime, get_gametime());
					entity_set_float(boss, EV_FL_framerate, 1.0);
					
					entity_set_int(boss, EV_INT_gamestate, 1);
					
					entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
					
					fm_set_rendering(boss, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
					
					set_lights("a");
					
					new Float:flEndTime = 3.7;
					new Float:flRepeat = (flEndTime / 0.1) - 1.0;
					
					set_task(0.1, "bossPower_Closer", boss, _, _, "a", floatround(flRepeat));
					set_task(flEndTime, "__endBossPower_Closer", boss);

					entity_set_int(boss, MONSTER_TARGET, 0);
				}
			}
		}
	}
	
	if(damagebits & DMG_BULLET) {
		static iOk;
		iOk = 0;
		
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
			set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
			ShowSyncHudMsg(attacker, g_HudDamage, "¡INVULNERABLE!");
			
			SetHamParamFloat(4, 0.0);
			
			return HAM_IGNORED;
		}

		__checkAttackerLevelUp(attacker, floatround(damage));
		
		set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
		ShowSyncHudMsg(attacker, g_HudDamage, "%0.0f", damage);
	}
	
	emit_sound(boss, CHAN_BODY, MONSTER_SOUNDS_PAIN[random_num(0, charsmax(MONSTER_SOUNDS_PAIN))], 1.0, ATTN_NORM, 0, PITCH_NORM);

	if(g_BossId != BOSS_GUARDIANES) {
		if(is_valid_ent(g_Boss_HealthBar)) {
			entity_set_float(g_Boss_HealthBar, EV_FL_frame, ((flHealth * 100.0) / float(entity_get_int(boss, MONSTER_MAXHEALTH))));
		}
	} else {
		if(g_Boss != boss) {
			static i;
			for(i = 0; i < 2; ++i) {
				if(g_Boss_Guardians_Ids[i] == boss) {
					if(is_valid_ent(g_Boss_Guardians_HealthBar[i])) {
						entity_set_float(g_Boss_Guardians_HealthBar[i], EV_FL_frame, ((flHealth * 100.0) / float(entity_get_int(boss, MONSTER_MAXHEALTH))));
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

public fw_Boss_Killed(const boss, const killer, const shouldgib) {
	if(!is_valid_ent(boss) || !is_user_alive(killer)) {
		return HAM_IGNORED;
	}
	
	if(!isBoss(boss)) {
		return HAM_IGNORED;
	}
	
	entity_set_int(boss, MONSTER_MAXHEALTH, 0); // Lo pongo acá arriba porque se utiliza en el medio
	
	new iDeadSeq;
	
	if(g_BossId != BOSS_GUARDIANES) {
		switch(g_BossId) {
			case BOSS_GORILA: iDeadSeq = random_num(49, 55);
			case BOSS_FIRE: iDeadSeq = 16;
			case BOSS_FALLEN_TITAN: iDeadSeq = 19;
		}
	} else {
		new iOk = 1;
		
		if(g_Boss != boss) {
			iDeadSeq = random_num(49, 55);
			
			new i;
			for(i = 0; i < 2; ++i) {
				if(g_Boss_Guardians_Ids[i] == boss) {
					g_BossPower[i] = 0;
					
					if(is_valid_ent(g_Boss_Guardians_HealthBar[i])) {
						remove_entity(g_Boss_Guardians_HealthBar[i]);
						
						--g_Boss_Guardians;
					}
					
					break;
				}
			}
			
			for(i = 0; i < 2; ++i) {
				if(is_valid_ent(g_Boss_Guardians_Ids[i]) && entity_get_int(g_Boss_Guardians_Ids[i], MONSTER_MAXHEALTH)) {
					iOk = 0;
					break;
				}
			}
			
			if(iOk) {
				if(g_FORWARD_AddToFullPack_Status) {
					g_FORWARD_AddToFullPack_Status = 0;
					unregister_forward(FM_AddToFullPack, g_FORWARD_AddToFullPack, 1);
					
					g_Boss_HealthBar = create_entity("env_sprite");
					
					if(g_Boss_HealthBar) {
						entity_set_int(g_Boss_HealthBar, EV_INT_spawnflags, SF_SPRITE_STARTON);
						entity_set_int(g_Boss_HealthBar, EV_INT_solid, SOLID_NOT);
						
						entity_set_model(g_Boss_HealthBar, MONSTER_SPRITE_HEALTH_BOSS);
						
						entity_set_float(g_Boss_HealthBar, EV_FL_scale, 0.5);
						
						entity_set_float(g_Boss_HealthBar, EV_FL_frame, 100.0);
						
						//g_Boss_Respawn[2] += 200.0;
						entity_set_origin(g_Boss_HealthBar, g_Boss_Respawn);
						
						g_FORWARD_AddToFullPack_Status = 1;
						g_FORWARD_AddToFullPack = register_forward(FM_AddToFullPack, "fw_AddToFullPack__BOSS_Post", 1);
					}
				}
				
				entity_set_float(g_Boss, EV_FL_takedamage, DAMAGE_YES);
				
				entity_set_int(g_Boss, EV_INT_solid, SOLID_BBOX);
				
				entity_set_float(g_Boss, EV_FL_nextthink, get_gametime() + 0.01);
			}
		} else {
			iDeadSeq = random_num(138, 144);
		}
	}

	++g_Kills[killer];
	
	__checkKillerLevelUp(killer);

	set_user_frags(killer, get_user_frags(killer) + 1);
	
	message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
	write_byte(killer);
	write_short(get_user_frags(killer));
	write_short(cs_get_user_deaths(killer));
	write_short(0);
	write_short(getUserTeam(killer));
	message_end();
	
	entity_set_int(boss, MONSTER_TYPE, 0);
	entity_set_int(boss, MONSTER_TRACK, 0);
	entity_set_float(boss, MONSTER_SPEED, 0.0);
	
	entity_set_edict(boss, MONSTER_HEALTHBAR, 0);
	
	entity_set_vector(boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
	entity_set_int(boss, EV_INT_solid, SOLID_NOT);
	
	entity_set_int(boss, EV_INT_sequence, iDeadSeq);
	entity_set_float(boss, EV_FL_animtime, get_gametime());
	entity_set_float(boss, EV_FL_framerate, 1.0);
	//entity_set_float(boss, EV_FL_frame, 3.0);
	
	emit_sound(boss, CHAN_BODY, MONSTER_SOUNDS_DEATH[random_num(0, charsmax(MONSTER_SOUNDS_DEATH))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	set_task(16.0, "deleteMonsterEnt__Boss", boss);
	
	if(g_Boss == boss) { // Para asegurarnos de que no sean los Guardianes!
		if(g_FORWARD_AddToFullPack_Status) {
			g_FORWARD_AddToFullPack_Status = 0;
			unregister_forward(FM_AddToFullPack, g_FORWARD_AddToFullPack, 1);
		}
		
		if(is_valid_ent(g_Boss_HealthBar)) {
			remove_entity(g_Boss_HealthBar);
		}
		
		__checkUsersSomeThings();
		
		g_EndGame = 1;
		g_WaveInProgress = 0;
		g_BossId = 0;
		
		set_task(2.0, "__VoteMap");
	}
	
	return HAM_SUPERCEDE;
}

public deleteMonsterEnt__Boss(const boss) {
	if(is_valid_ent(boss)) {
		remove_entity(boss);
		
		/*if(g_Boss == boss) {
			removeAllEnts(1);
		}*/
	}
}

new const CLASSES_NAMES[classIds][] = {
	"SOLDADO", "INGENIERO", "SOPORTE", "FRANCOTIRADOR", "APOYO", "PESADO", "ASALTO", "COMANDANTE", "PISTOLERO", "PUBERO", "LEGIONARIO", "BITERO", "SCOUTER"
};

public __checkKillerLevelUp(const killer) {
	switch(g_ClassId[killer]) {
		case CLASS_SOLDADO, CLASS_ASALTO, CLASS_COMANDANTE, CLASS_BITERO: {
			if(g_CurrentWeapon[killer] == CLASSES_WEAPONS[g_ClassId[killer]][0] || g_CurrentWeapon[killer] == CLASSES_WEAPONS[g_ClassId[killer]][1]) {
				static iClassReq;
				iClassReq = CLASSES[g_ClassId[killer]][classReqLv1 + g_ClassLevel[killer][g_ClassId[killer]]];

				if(g_UserPremium[killer]) {
					iClassReq = iClassReq - ((iClassReq * 20) / 100);
				}

				++g_ClassReqs[killer][g_ClassId[killer]];
				
				if(g_ClassReqs[killer][g_ClassId[killer]] >= iClassReq) {
					++g_ClassLevel[killer][g_ClassId[killer]];

					colorChat(0, CT, "%s!t%s!y subió de nivel a su !t%s!y al nivel !g%d!y", TD_PREFIX, g_UserName[killer], CLASSES_NAMES[g_ClassId[killer]], g_ClassLevel[killer][g_ClassId[killer]]);
				}
			}
		}
	}
}

public __checkAttackerLevelUp(const attacker, const iDamage) {
	switch(g_ClassId[attacker]) {
		case CLASS_SOPORTE, CLASS_FRANCOTIRADOR, CLASS_APOYO, CLASS_PESADO, CLASS_PUBERO, CLASS_LEGIONARIO, CLASS_SCOUTER: {
			if(g_CurrentWeapon[attacker] == CLASSES_WEAPONS[g_ClassId[attacker]][0] || g_CurrentWeapon[attacker] == CLASSES_WEAPONS[g_ClassId[attacker]][1]) {
				static iClassReq;
				iClassReq = CLASSES[g_ClassId[attacker]][classReqLv1 + g_ClassLevel[attacker][g_ClassId[attacker]]];

				if(g_UserPremium[attacker]) {
					iClassReq = iClassReq - ((iClassReq * 20) / 100);
				}

				g_ClassReqs[attacker][g_ClassId[attacker]] += iDamage;
				
				if(g_ClassReqs[attacker][g_ClassId[attacker]] >= iClassReq) {
					++g_ClassLevel[attacker][g_ClassId[attacker]];
					
					colorChat(0, CT, "%s!t%s!y subió de nivel a su !t%s!y al nivel !g%d!y", TD_PREFIX, g_UserName[attacker], CLASSES_NAMES[g_ClassId[attacker]], g_ClassLevel[attacker][g_ClassId[attacker]]);
				}

				return;
			}
		} case CLASS_PISTOLERO: {
			if(g_CurrentWeapon[attacker] == CSW_DEAGLE) {
				static iClassReq;
				iClassReq = CLASSES[g_ClassId[attacker]][classReqLv1 + g_ClassLevel[attacker][g_ClassId[attacker]]];

				if(g_UserPremium[attacker]) {
					iClassReq = iClassReq - ((iClassReq * 20) / 100);
				}

				++g_ClassReqs[attacker][g_ClassId[attacker]];
				
				if(g_ClassReqs[attacker][g_ClassId[attacker]] >= iClassReq) {
					++g_ClassLevel[attacker][g_ClassId[attacker]];
					
					colorChat(0, CT, "%s!t%s!y subió de nivel a su !t%s!y al nivel !g%d!y", TD_PREFIX, g_UserName[attacker], CLASSES_NAMES[g_ClassId[attacker]], g_ClassLevel[attacker][g_ClassId[attacker]]);
				}

				return;
			}
		}
	}

	if(g_CurrentWeapon[attacker] == CSW_DEAGLE) {
		++g_AchievementTrack_Pistolero[attacker];

		if(g_AchievementTrack_Pistolero[attacker] == 186) {
			setAchievement(attacker, PISTOLERO_UNLOCKED);
		}
	}
}

public __checkUsersSomeThings() {
	new i;
	new iRep;

	new const bossReward[BossList][difficultiesIds] = {
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

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}
		
		if(g_ClassId[i] == CLASS_INGENIERO) {
			new iClassReq = CLASSES[CLASS_INGENIERO][classReqLv1 + g_ClassLevel[i][CLASS_INGENIERO]];

			if(g_UserPremium[i]) {
				iClassReq = iClassReq - ((iClassReq * 20) / 100);
			}

			if(g_ClassReqs[i][CLASS_INGENIERO] >= iClassReq) {
				++g_ClassLevel[i][CLASS_INGENIERO];
				
				colorChat(0, CT, "%s!t%s!y subió de nivel a su !tINGENIERO!y al nivel !g%d!y", TD_PREFIX, g_UserName[i], g_ClassLevel[i][CLASS_INGENIERO]);
			}
		}
		
		switch(g_Difficulty) {
			case DIFF_NORMAL: {
				++g_BossKills[i][DIFF_NORMAL];
			}
			case DIFF_NIGHTMARE: {
				++g_BossKills[i][DIFF_NORMAL];
				++g_BossKills[i][DIFF_NIGHTMARE];
			}
			case DIFF_SUICIDAL: {
				++g_BossKills[i][DIFF_NORMAL];
				++g_BossKills[i][DIFF_NIGHTMARE];
				++g_BossKills[i][DIFF_SUICIDAL];
			}
			case DIFF_HELL: {
				++g_BossKills[i][DIFF_NORMAL];
				++g_BossKills[i][DIFF_NIGHTMARE];
				++g_BossKills[i][DIFF_SUICIDAL];
				++g_BossKills[i][DIFF_HELL];
			}
		}
		
		if(g_LevelG[i] < 100) {
			if(g_Kills[i] >= LEVELS_G[g_LevelG[i]][levelKills] &&
			g_WavesWins[i][DIFF_NORMAL][0] >= LEVELS_G[g_LevelG[i]][levelWaveNormal] &&
			g_WavesWins[i][DIFF_NIGHTMARE][0] >= LEVELS_G[g_LevelG[i]][levelWaveNightmare] &&
			g_WavesWins[i][DIFF_SUICIDAL][0] >= LEVELS_G[g_LevelG[i]][levelWaveSuicidal] &&
			g_WavesWins[i][DIFF_HELL][0] >= LEVELS_G[g_LevelG[i]][levelWaveHell] &&
			g_BossKills[i][DIFF_NORMAL] >= LEVELS_G[g_LevelG[i]][levelBossNormal] &&
			g_BossKills[i][DIFF_NIGHTMARE] >= LEVELS_G[g_LevelG[i]][levelBossNightmare] &&
			g_BossKills[i][DIFF_SUICIDAL] >= LEVELS_G[g_LevelG[i]][levelBossSuicidal] &&
			g_BossKills[i][DIFF_HELL] >= LEVELS_G[g_LevelG[i]][levelBossHell]) {
				++g_LevelG[i];
				client_print(i, print_center, "SUBISTE DE NIVEL G!");
				
				switch(g_LevelG[i]) {
					case 10: setAchievement(i, NIVEL_10G);
					case 20: setAchievement(i, NIVEL_20G);
					case 30: setAchievement(i, NIVEL_30G);
					case 40: setAchievement(i, NIVEL_40G);
					case 50: setAchievement(i, NIVEL_50G);
					case 60: setAchievement(i, NIVEL_60G);
					case 70: setAchievement(i, NIVEL_70G);
					case 80: setAchievement(i, NIVEL_80G);
					case 90: setAchievement(i, NIVEL_90G);
					case 100: setAchievement(i, NIVEL_100G);
				}
				
				++g_Points[i];

				if(is_user_alive(i)) {
					updateRankAndHat(i);
				}
			}
		}
		
		if(is_user_alive(i)) {
			set_user_health(i, 100000);

			if(g_AchievementMap[i]) {
				iRep = g_Difficulty + 1;
				
				while(iRep) {
					--iRep;
					setAchievement(i, (MAPS_DESC[g_MapId][mapAchievement] + iRep));
				}
			}
			
			iRep = g_Difficulty + 1;
			
			while(iRep) {
				--iRep;
				setAchievement(i, (BOSS_ACHIEVEMENT[g_BossId] + iRep));
			}

			g_Osmio[i] += bossReward[g_BossId][g_Difficulty];

			client_print(i, print_center, "+%d Os por sobrevivir al jefe final!", bossReward[g_BossId][g_Difficulty]);
		}
	}
}

public __effectSpecialBoss(const miniBoss) {
	message_begin(MSG_BROADCAST, g_Message_Screenfade);
	write_short(UNIT_SECOND * 4);
	write_short(UNIT_SECOND * 4);
	write_short(FFADE_OUT);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
	
	set_task(4.5, "__removeEffectSpecialBoss", miniBoss);
}

public damageTower(const taskid) {
	if(!is_valid_ent(ID_DAMAGE_TOWER))
		return;
	
	if(!entity_get_int(ID_DAMAGE_TOWER, MONSTER_MAXHEALTH))
		return;
	
	new iDamage = 5;
	
	if(DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower]) {
		iDamage = iDamage + ((iDamage * DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower]) / 100);
	}
	
	g_Achievement_DefensaAbsoluta = 0;
	
	g_TowerHealth -= iDamage;
	
	if(g_TowerHealth > 0) {
		if(!isEggMonster(ID_DAMAGE_TOWER)) {
			emit_sound(ID_DAMAGE_TOWER, CHAN_BODY, MONSTER_SOUNDS_CLAW[random_num(0, charsmax(MONSTER_SOUNDS_CLAW))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	} else {
		removeAllEnts(1);
		__finishGame();
		
		return;
	}
	
	if(!entity_get_int(ID_DAMAGE_TOWER, MONSTER_TARGET))
		entity_set_int(ID_DAMAGE_TOWER, MONSTER_TARGET, 1337);
	
	set_task(1.0, "damageTower", TASK_DAMAGE_TOWER + ID_DAMAGE_TOWER);
	
	if(!g_TowerInRegen) {
		g_TowerInRegen = 1;
		if(DIFFICULTIES_VALUES[g_Difficulty][difficultyTowerRegen]) {
			set_task(5.0, "regenTower", TASK_REGEN_TOWER);
		}
	}
}

public regenTower() {
	if(g_TowerHealth && g_TowerHealth < g_TOWER_MAX_HEALTH) {
		g_TowerHealth = clamp(g_TowerHealth + DIFFICULTIES_VALUES[g_Difficulty][difficultyTowerRegen], 0, g_TOWER_MAX_HEALTH);
		set_task(5.0, "regenTower", TASK_REGEN_TOWER);
		
		if(g_TowerHealth >= g_TOWER_MAX_HEALTH) {
			g_TowerInRegen = 0;
		}
	}
}

public __finishGame() {
	if(g_FinishGame) {
		return;
	}

	g_FinishGame = 1;
	g_EndGame = 1;
	g_WaveInProgress = 0;

	ClearSyncHud(0, g_HudDamageTower);
	
	__moveView();
	
	new i;
	for(i = 0; i < 2; ++i) {
		if(is_valid_ent(g_Tower[i])) {
			entity_set_float(g_Tower[i], EV_FL_animtime, get_gametime());
			entity_set_float(g_Tower[i], EV_FL_framerate, 1.0);
			entity_set_int(g_Tower[i], EV_INT_sequence, 1);
		}
	}
	
	set_task(2.0, "__VoteMap");
}

public isMonster(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	new iMonsterType = entity_get_int(ent, MONSTER_TYPE);
	return (iMonsterType == ROUND_NORMAL || iMonsterType == EGG_MONSTER || iMonsterType == ROUND_SPECIAL_SPEED || iMonsterType == ROUND_SPECIAL_STRENGTH || iMonsterType == MONSTER_SPECIAL) ? 1 : 0;
}

public isBoss(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	new iMonsterType = entity_get_int(ent, MONSTER_TYPE);
	return (iMonsterType == MONSTER_BOSS) ? 1 : 0;
}

public isEggMonster(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	return (entity_get_int(ent, MONSTER_TYPE) == EGG_MONSTER) ? 1 : 0;
}

public isMonster_LowFPS(const ent) {
	return entity_get_int(ent, MONSTER_LOW_FPS);
}

public isSentry_LowFPS(const ent) {
	return entity_get_int(ent, SENTRY_LOW_FPS);
}

public isSpecialMonster(const ent) {
	if(!is_valid_ent(ent)) {
		return 0;
	}
	
	return (entity_get_int(ent, MONSTER_TYPE) == MONSTER_SPECIAL) ? 1 : 0;
}

public fw_ClientKill() {
	return FMRES_SUPERCEDE;
}

public fw_CmdStart(const id, const handle)
{
	if(is_user_alive(id) && !g_VoteMap)
	{
		static iButton;
		static iOldButton;

		iButton = get_uc(handle, UC_Buttons);
		iOldButton = entity_get_int(id, EV_INT_oldbuttons);

		if((iButton & IN_USE) && !(iOldButton & IN_USE))
		{
			static Float:vecOrigin[3];
			static Float:fDistance;
			static i;

			entity_get_vector(id, EV_VEC_origin, vecOrigin);

			for(i = 0; i < g_EntGamingaNums; ++i)
			{
				fDistance = get_distance_f(g_EntGamingaOrigin[i], vecOrigin);

				if(fDistance <= 150.0)
				{
					showMenu__Shop(id);

					i = 1337;
					break;
				}
			}

			if(i != 1337)
			{
				if(g_CurrentWeapon[id] == CSW_KNIFE)
					showMenu__Others(id);
			}
		}
		else if((iButton & IN_ATTACK) && ((1<<g_CurrentWeapon[id]) & CSW_DEAGLE) && (g_ClassLevel[id][CLASS_PISTOLERO] == 6 && g_ClassId[id] == CLASS_PISTOLERO) && g_Pistolero_AutoFire[id])
		{
			set_uc(handle, UC_Buttons, iButton & ~IN_ATTACK);
			g_Pistolero_AutoFire[id] = 0;
		}
	}
}

public fw_SetModel(const entity, const model[]) {
	if(strlen(model) < 8)
		return FMRES_IGNORED;
	
	static sClassName[10];
	entity_get_string(entity, EV_SZ_classname, sClassName, charsmax(sClassName));
	
	if(equal(sClassName, "weaponbox")) {
		entity_set_float(entity, EV_FL_nextthink, get_gametime() + 0.01);
		return FMRES_IGNORED;
	}
	
	if(model[7] != 'w' || model[8] != '_')
		return FMRES_IGNORED;
	
	static Float:fDamageTime;
	fDamageTime = entity_get_float(entity, EV_FL_dmgtime);
	
	if(fDamageTime == 0.0)
		return FMRES_IGNORED;
	
	static id;
	id = entity_get_edict(entity, EV_ENT_owner);
	
	if(model[9] == 'h') {
		if(g_Nades[id][NADE_ION_BOMB]) {
			effectGrenade(entity, 71, 60, 139, _, _, NADE_TYPE_ION_BOMB);
			--g_Nades[id][NADE_ION_BOMB];

			replaceWeaponModels(id, CSW_HEGRENADE);

			entity_set_model(entity, MODEL_ION_BOMB_W);
			return FMRES_SUPERCEDE;
		} else  if(g_Nades[id][NADE_EXPLOSION]) {
			effectGrenade(entity, 255, 0, 0, _, _, NADE_TYPE_EXPLOSION);
			--g_Nades[id][NADE_EXPLOSION];
		} 
	} else if(model[9] == 'f') {
		if(g_Nades[id][NADE_REMUEVE_PROTECCION]) {
			effectGrenade(entity, 255, 255, 255, _, _, NADE_TYPE_REMUEVE_PROTECCION);
			--g_Nades[id][NADE_REMUEVE_PROTECCION];
		}
	} else if(model[9] == 's') {
		if(g_Nades[id][NADE_AUMENTA_DMG_RECIBIDO]) {
			effectGrenade(entity, 0, 255, 0, _, _, NADE_TYPE_AUMENTA_DMG_RECIBIDO);
			--g_Nades[id][NADE_AUMENTA_DMG_RECIBIDO];
		}
	}
	
	return FMRES_IGNORED;
}

public fw_ThinkGrenade(const entity) {
	if(!pev_valid(entity)) {
		return HAM_IGNORED;
	}
	
	static Float:fDamageTime;
	static Float:fCurrentTime;
	
	fDamageTime = entity_get_float(entity, EV_FL_dmgtime);
	fCurrentTime = get_gametime();
	
	if(fDamageTime > fCurrentTime) {
		return HAM_IGNORED;
	}
	
	static iType;
	iType = entity_get_int(entity, EV_NADE_TYPE);
	
	if(iType) {
		new id;
		id = entity_get_edict(entity, EV_ENT_owner);
		
		if(!is_user_connected(id)) {
			remove_entity(entity);
			return HAM_IGNORED;
		}
		
		new Float:vecOrigin[3];
		new iVictim;
		
		entity_get_vector(entity, EV_VEC_origin, vecOrigin);
		
		switch(iType) {
			case NADE_TYPE_EXPLOSION: {
				new sText[32];
				new Float:fHealth;
				new Float:fDamage;
				new Float:fDamageTotal = 0.0;
				new iCountVictims;
				new iCount;
				
				createExplosion(vecOrigin, 255, 0, 0);
				
				iVictim = -1;
				iCount = 0;
				iCountVictims = 0;
				
				while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOrigin, 500.0)) != 0) {
					if(!isMonster(iVictim))
						continue;
					
					++iCount;
					
					fDamage = random_float(35.0, 85.0);
					fHealth = entity_get_float(iVictim, EV_FL_health) - fDamage;
					fDamageTotal += fDamage;
					
					if(fHealth > 0.0) {
						entity_set_float(iVictim, EV_FL_health, fHealth);
					} else {
						removeMonster(iVictim, id, .rayo = 1);
						++iCountVictims;
					}
				}
				
				formatex(sText, charsmax(sText), "^n¡%d MATADO%s!", iCountVictims, (iCountVictims != 1) ? "s" : "");
				
				set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 6.0, 1.0, 0.0, 0.4, 2);
				ShowSyncHudMsg(id, g_HudDamage, "%0.0f [%d Hit%s]%s", fDamageTotal, iCount, (iCount != 1) ? "s" : "", sText);
			} case NADE_TYPE_REMUEVE_PROTECCION: {
				createExplosion(vecOrigin, 255, 255, 255);
				
				iVictim = -1;
				
				while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOrigin, 500.0)) != 0) {
					if(!isMonster(iVictim))
						continue;
					
					if(entity_get_float(iVictim, MONSTER_SHIELD) == 1.0) {
						entity_set_float(iVictim, MONSTER_SHIELD, 0.0);
						fm_set_rendering(iVictim);
					}
				}
			} case NADE_TYPE_AUMENTA_DMG_RECIBIDO: {
				createExplosion(vecOrigin, 0, 255, 0);
				
				iVictim = -1;
				
				while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOrigin, 600.0)) != 0) {
					if(!isMonster(iVictim))
						continue;
					
					entity_set_float(iVictim, MONSTER_SHIELD, 2.0);
					fm_set_rendering(iVictim, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
				}
			} case NADE_TYPE_ION_BOMB: {
				new iIonMode = entity_get_int(entity, EV_INT_flSwimTime);

				if(iIonMode) {
					new iOk = 0;
					/*new Float:fVelocity;
					new iTrack;
					new sText[12];
					new Float:vecTrackOrigin[3];
					new Float:vecMonsterOrigin[3];
					new iTargetEnt;*/

					iVictim = -1;
					
					while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOrigin, 750.0)) != 0) {
						if(!pev_valid(iVictim)) {
							continue;
						}

						if(!isMonster(iVictim)) {
							continue;
						}

						if(isSpecialMonster(iVictim)) {
							continue;
						}

						if(entity_get_float(iVictim, EV_FL_takedamage) != DAMAGE_YES) {
							continue;
						}

						if(entity_get_int(iVictim, EV_INT_flTimeStepSound) == 1337) {
							continue;
						}

						fm_set_rendering(iVictim, kRenderFxGlowShell, 71, 60, 139, kRenderNormal, 4);

						entity_set_int(iVictim, EV_INT_flTimeStepSound, 1337);

						iOk = 1;
					}

					if(iOk) {
						if(!task_exists(entity + TASK_ION_BOMB_EXPLODE)) {
							set_task(6.0, "ionBombExplode", entity + TASK_ION_BOMB_EXPLODE);
						}
					}

					entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 0.1);
					return HAM_IGNORED;
				} else {
					entity_set_int(entity, EV_INT_flSwimTime, 1);
				}
				
				entity_set_float(entity, EV_FL_dmgtime, fCurrentTime + 35.0);
				return HAM_IGNORED;
			}
		}
		
		remove_entity(entity);
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public ionBombExplode(const taskid) {
	if(!is_valid_ent(ID_ION_BOMB_EXPLODE)) {
		return;
	}

	new Float:vecOrigin[3];
	new iVictim;

	entity_set_int(ID_ION_BOMB_EXPLODE, EV_INT_flSwimTime, 0);
	
	entity_get_vector(ID_ION_BOMB_EXPLODE, EV_VEC_origin, vecOrigin);
	
	createExplosion(vecOrigin, 71, 60, 139, 120);

	iVictim = -1;
	
	while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOrigin, 9999.9)) != 0) {
		if(!pev_valid(iVictim)) {
			continue;
		}

		if(!isMonster(iVictim)) {
			continue;
		}

		if(isSpecialMonster(iVictim)) {
			continue;
		}

		if(entity_get_float(iVictim, EV_FL_takedamage) != DAMAGE_YES) {
			continue;
		}

		if(entity_get_int(iVictim, EV_INT_flTimeStepSound) != 1337) {
			continue;
		}

		removeMonster(iVictim, 1337, .rayo=1);
	}
}

public fw_SetClientKeyValue(id, const infobuffer[], const key[]) {
	if(key[0] == 'n' && key[1] == 'a' && key[2] == 'm' && key[3] == 'e') {
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public fw_ClientUserInfoChanged(const id, const buffer) {
	if(!is_user_connected(id)) {
		return FMRES_IGNORED;
	}
	
	get_user_name(id, g_UserName[id], charsmax(g_UserName[]));
	
	static sNewName[32];
	engfunc(EngFunc_InfoKeyValue, buffer, "name", sNewName, charsmax(sNewName));
	
	if(equal(sNewName, g_UserName[id])) {
		return FMRES_IGNORED;
	}
	
	engfunc(EngFunc_SetClientKeyValue, id, buffer, "name", g_UserName[id]);
	client_cmd(id, "name ^"%s^"; setinfo name ^"%s^"", g_UserName[id], g_UserName[id]);
	set_user_info(id, "name", g_UserName[id]);
	
	console_print(id, "[TD] No podes cambiarte el nombre dentro del servidor.");
	
	return FMRES_SUPERCEDE;
}

public fw_Touch(const ent, const id) {
	if(!pev_valid(ent)) {
		return FMRES_IGNORED;
	}
	
	if(!is_user_alive(id)) {
		return FMRES_IGNORED;
	}
	
	zoneTouch(id, ent);
	
	return FMRES_IGNORED;
}

createExplosion(const Float:vecOrigin[3], const red, const green, const blue, radius=80) {
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

effectGrenade(const entity, const red, const green, const blue, life = 10, width = 2, const nade_type) {
	fm_set_rendering(entity, kRenderFxGlowShell, red, green, blue, kRenderNormal, 4);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(entity);
	write_short(g_Sprite_Trail);
	write_byte(life);
	write_byte(width);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(200);
	message_end();
	
	entity_set_int(entity, EV_NADE_TYPE, nade_type);
	
	entity_set_float(entity, EV_FL_dmgtime, get_gametime() + 9999.9);
}

public think__SpecialMonster(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(iEnt, MONSTER_TARGET);
	
	if(is_user_alive(iVictim) && !g_InBlockZone[iVictim]) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:fDistance;
		static Float:fDiff;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDiff = (vecEntOrigin[2] - vecVictimOrigin[2]);
		
		if(fDiff < -64.0 || fDiff > 64.0) {
			entity_set_int(iEnt, MONSTER_TARGET, 0);
			
			if(is_valid_ent(iEnt)) // WTF...
				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);

			return;
		}
		
		fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		if(fDistance <= 64.0) {
			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
			
			static Float:fDamage;
			
			entity_set_int(iEnt, EV_INT_sequence, 76);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 6.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_get_vector(iVictim, EV_VEC_velocity, vecEntOrigin);
			
			vecEntOrigin[0] = 15.0;
			vecEntOrigin[1] = 15.0;
			
			entity_set_vector(iVictim, EV_VEC_velocity, vecEntOrigin);
			
			message_begin(MSG_ONE_UNRELIABLE, g_Message_Screenfade, _, iVictim);
			write_short(UNIT_SECOND * 1);
			write_short(UNIT_SECOND * 1);
			write_short(FFADE_IN);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(152);
			message_end();
			
			if(!DIFFICULTIES_VALUES[g_Difficulty][difficultyEgg_DmgSpeed]) {
				fDamage = 1.0;
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, fDamage, DMG_BULLET);
				
				if(g_Upgrades[iVictim][HAB_RESISTENCIA] && is_valid_ent(iEnt)) {
					static Float:fResist;
					fResist = float(__HABILITIES[HAB_RESISTENCIA][upgValue]) / 10;

					entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1 + fResist);
					return;
				}
			} else {
				fDamage = 2.0;
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, fDamage, DMG_BULLET);
				
				if(g_Upgrades[iVictim][HAB_RESISTENCIA] && is_valid_ent(iEnt)) {
					static Float:fResist;
					fResist = float(__HABILITIES[HAB_RESISTENCIA][upgValue]) / 10;

					entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1 + fResist);
					return;
				}
			}

			if(is_valid_ent(iEnt)) // WTF...
				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
			
			return;
		} else {
			if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
				entity_set_int(iEnt, EV_INT_gamestate, 3);

				entity_set_int(iEnt, EV_INT_sequence, 4);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
			}
			
			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, 265.0, .iAngleMode=1);
		}
	} else {
		iVictim = searchHuman(iEnt);
		entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		
		if(!iVictim && g_Wave < 11) {
			if(task_exists(TASK_DAMAGE_TOWER + iEnt)) {
				remove_task(TASK_DAMAGE_TOWER + iEnt);
				
				new sArgs[7];
				
				set_task(0.1, "damageTower__Effect", TASK_DAMAGE_TOWER + iEnt, sArgs, 6);
				set_task(0.2, "damageTower", TASK_DAMAGE_TOWER + iEnt);
				
				return;
			}
		}
	}
	
	if(is_valid_ent(iEnt)) { // WTF...
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
	}
}

entitySetAim(const iEnt, const Float:vecEntOrigin[3], const Float:vecTargetOrigin[3], const Float:fVelocity=0.0, const iAngleMode=0) { // s_esa
	if(!is_valid_ent(iEnt)) {
		return;
	}

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

public hideHUDs(const taskid) {
	if(!is_user_alive(ID_SPAWN))
		return;
	
	message_begin(MSG_ONE, g_Message_HideWeapon, _, ID_SPAWN);
	write_byte(HIDE_HUDS);
	message_end();
	
	message_begin(MSG_ONE, g_Message_Crosshair, _, ID_SPAWN);
	write_byte(0);
	message_end();
}

public hideHUDs__Full(const taskid) {
	if(!is_user_alive(ID_SPAWN))
		return;
	
	message_begin(MSG_ONE, g_Message_HideWeapon, _, ID_SPAWN);
	write_byte(HIDE_HUDS_FULL);
	message_end();
	
	message_begin(MSG_ONE, g_Message_Crosshair, _, ID_SPAWN);
	write_byte(0);
	message_end();
}

public clearWeapons(const taskid) {
	if(!is_user_alive(ID_SPAWN)) {
		return;
	}
	
	strip_user_weapons(ID_SPAWN);
	
	give_item(ID_SPAWN, "weapon_knife");
	
	give_item(ID_SPAWN, "weapon_deagle");
	cs_set_user_bpammo(ID_SPAWN, CSW_DEAGLE, 200);

	g_Rank[ID_SPAWN] = create_entity("info_target");
	
	if(g_Rank[ID_SPAWN]) {
		new Float:vecColor[3];
		new iRank = (g_LevelG[ID_SPAWN] / 10);

		vecColor = Float:{0.0, 0.0, 0.0};
		
		if(iRank < 1) {
			iRank = 12;
		} else if(iRank >= 4) {
			vecColor = Float:{255.0, 255.0, 0.0};
		}
		
		entity_set_int(g_Rank[ID_SPAWN], EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(g_Rank[ID_SPAWN], EV_ENT_aiment, ID_SPAWN);
		
		entity_set_int(g_Rank[ID_SPAWN], EV_INT_rendermode, kRenderNormal);
		entity_set_int(g_Rank[ID_SPAWN], EV_INT_renderfx, kRenderFxGlowShell);
		entity_set_float(g_Rank[ID_SPAWN], EV_FL_renderamt, 5.0);
		
		entity_set_model(g_Rank[ID_SPAWN], MODEL_RANKS);
		
		entity_set_int(g_Rank[ID_SPAWN], EV_INT_body, iRank);
		
		entity_set_vector(g_Rank[ID_SPAWN], EV_VEC_rendercolor, vecColor);
	}

	g_Hat[ID_SPAWN] = create_entity("info_target");
	
	if(g_Hat[ID_SPAWN]) {
		new iHat = (g_LevelG[ID_SPAWN] / 15);

		if(iHat > 5) {
			iHat = 5;
		}
		
		entity_set_int(g_Hat[ID_SPAWN], EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(g_Hat[ID_SPAWN], EV_ENT_aiment, ID_SPAWN);
		
		entity_set_model(g_Hat[ID_SPAWN], MODEL_HATS);
		
		entity_set_int(g_Hat[ID_SPAWN], EV_INT_body, iHat);
	}
}

public OrpheuHookReturn:orpheu__BlockGameConditions() {
	OrpheuSetReturn(false);
	return OrpheuSupercede;
}

public message__RoundTime() {
	set_msg_arg_int(1, ARG_SHORT, get_timeleft());
}

public message__TextMsg() {
	static sMsg[22];
	get_msg_arg_string(2, sMsg, charsmax(sMsg));
	
	if(get_msg_args() == 5 && (get_msg_argtype(5) == ARG_STRING)) {
		get_msg_arg_string(5, sMsg, charsmax(sMsg));
		
		if(equal(sMsg, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED;
	}
	else if(get_msg_args() == 6 && (get_msg_argtype(6) == ARG_STRING)) {
		get_msg_arg_string(6, sMsg, charsmax(sMsg));
		
		if(equal(sMsg, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public message__SendAudio() {
	static sAudio[32];
	get_msg_arg_string(2, sAudio, charsmax(sAudio));
	
	if(	sAudio[0] == '%' &&
		sAudio[1] == '!' &&
		sAudio[2] == 'M' &&
		sAudio[3] == 'R' &&
		sAudio[4] == 'A' &&
		sAudio[5] == 'D' &&
		sAudio[6] == '_' &&
		sAudio[7] == 'F' &&
		sAudio[8] == 'I' &&
		sAudio[9] == 'R' &&
		sAudio[10] == 'E' &&
		sAudio[11] == 'I' &&
		sAudio[12] == 'N' &&
		sAudio[13] == 'H' &&
		sAudio[14] == 'O' &&
		sAudio[15] == 'L' &&
		sAudio[16] == 'E')
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public message__ShowMenu(const msgId, const destId, const id) {
	static sMenuCode[21];
	get_msg_arg_string(4, sMenuCode, charsmax(sMenuCode));
	
	if(equal(sMenuCode, FIRST_JOIN_MSG) || equal(sMenuCode, FIRST_JOIN_MSG_SPEC)) {
		if(getUserTeam(id) == FM_CS_TEAM_UNASSIGNED) {
			new sArgs[1];
			sArgs[0] = msgId;
			
			set_task(0.1, "__AutoJoinToSpec", id, sArgs, sizeof(sArgs));
			
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public message__VGUIMenu(const msgId, const destId, const id) {
	if(get_msg_arg_int(1) != 2)
		return PLUGIN_CONTINUE;
	
	if(getUserTeam(id) == FM_CS_TEAM_UNASSIGNED) {
		new sArgs[1];
		sArgs[0] = msgId;
		
		set_task(0.1, "__AutoJoinToSpec", id, sArgs, sizeof(sArgs));
	}
	
	return PLUGIN_HANDLED;
}

public fw_Spawn(const entity) {
	if(!pev_valid(entity))
		return FMRES_IGNORED;
	
	new const REMOVE_ENTS[][] =	{
		"func_bomb_target", "info_bomb_target", "func_vip_safetyzone", "func_escapezone", "hostage_entity", "monster_scientist", "info_hostage_rescue",
		"func_hostage_rescue", "env_rain", "env_snow", "env_fog", "func_vehicle", "info_map_parameters", "func_buyzone", "armoury_entity", "game_text"
	};
	
	new i;
	new sClassName[32];
	
	entity_get_string(entity, EV_SZ_classname, sClassName, charsmax(sClassName));
	
	for(i = 0; i < sizeof(REMOVE_ENTS); ++i) {
		if(equal(sClassName, REMOVE_ENTS[i])) {
			remove_entity(entity);
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public fw_PrecacheSound(const sound[]) {
	if(equal(sound, "hostage", 7)) {
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public think__HUD(const ent) {
	if(g_EndGame) {
		return;
	}
	
	if(!g_NextWaveIncoming && !g_StartGame) {
		if(!g_SpecialWave) {
			if(g_WaveInProgress) {
				set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "OLEADA %d^n%d", g_Wave, g_TotalMonsters);
			} else {
				set_dhudmessage(0, 255, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);

				if(g_Wave+1 <= MAX_WAVES) {
					show_dhudmessage(0, "SIGUIENTE OLEADA: %d^n%d", g_Wave+1, g_TotalMonsters);
				} else {
					show_dhudmessage(0, "SIGUIENTE OLEADA: JEFE FINAL^n%d", g_TotalMonsters);
				}
			}
		} else if(g_SpecialWave == ROUND_SPECIAL_SPEED) {
			set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
			show_dhudmessage(0, "OLEADA EXTRA : VELOCES^n%d", g_TotalMonsters);
		} else if(g_SpecialWave == ROUND_SPECIAL_STRENGTH) {
			set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
			show_dhudmessage(0, "OLEADA EXTRA : FUERTES^n%d", g_TotalMonsters);
		}
	} else if(g_StartGame) {
		set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 9999.9, 9999.9, 0.01, 0.01);
		show_dhudmessage(0, "EL JUEGO COMENZARÁ EN %d", g_StartSeconds);
	} else {
		switch(g_NextWaveIncoming) {
			case 1: {
				set_dhudmessage(255, 255, 0, -1.0, -1.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "¡SIGUIENTE OLEADA EN PROGRESO!");
			}
			case 2: {
				set_dhudmessage(255, 255, 0, -1.0, -1.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "¡JEFE FINAL!");
			}
			case 3: {
				set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 9999.9, 9999.9, 0.01, 0.01);
				show_dhudmessage(0, "JEFE FINAL^n%d", g_MonstersAlive);
			}
		}
	}
}

public think__HUDGeneral(const ent) {
	static id;
	static sProgress[56];
	static sProgress_Req[15];
	static sProgress_ReqTotal[15];

	if(g_Wave != 11) {
		static sText[48];
		static sPower[32];
		static sKills[20];
		static sGordoHealth[20];
		
		if(g_BestUserId) {
			formatex(sKills, 19, " +%d", g_MVP_More);
			formatex(sText, 47, "^n^nMVP: %s (%d)%s", g_UserName[g_BestUserId], g_BestUserKills, (!g_MVP_More) ? "" : sKills);
		} else {
			formatex(sText, 47, "^n^nMVP: NADIE");
		}
		
		sGordoHealth[0] = EOS;
		
		if(g_GordoHealth >= 15000) {
			static sGordoHealth_Dot[11];

			addDot(g_GordoHealth, sGordoHealth_Dot, 10);
			formatex(sGordoHealth, 19, "^n^nGordo: %s", sGordoHealth_Dot);
		}
		
		for(id = 1; id <= g_MaxUsers; ++id) {
			if(!is_user_alive(id)) {
				continue;
			}
			
			if(POWER_NAMES[g_PowerActual[id]][powerGold] != 0) {
				formatex(sPower, 31, "%s (x%d)", POWER_NAMES[g_PowerActual[id]][powerName], g_Power[id][g_PowerActual[id]]);
			} else {
				formatex(sPower, 31, "Ninguno");
			}
			
			if(g_Options_HUD_ProgressClass[id]) {
				static iClassReq;
				iClassReq = CLASSES[g_ClassId[id]][classReqLv1 + g_ClassLevel[id][g_ClassId[id]]];

				if(g_UserPremium[id]) {
					iClassReq = iClassReq - ((iClassReq * 20) / 100);
				}

				addDot(g_ClassReqs[id][g_ClassId[id]], sProgress_Req, 14);
				addDot(iClassReq, sProgress_ReqTotal, 14);
				
				formatex(sProgress, 55, "%s: %s / %s^n", CLASSES[g_ClassId[id]][className], sProgress_Req, sProgress_ReqTotal);
			} else {
				sProgress[0] = EOS;
			}
			
			if(g_Options_HUD_KillsPerWave[id]) {
				if(g_Wave <= 11) {
					formatex(sKills, 19, "Matados: %d^n", g_KillsPerWave[id][g_Wave]);
				} else {
					formatex(sKills, 19, "Matados: %d^n", g_KillsPerWave[id][0]);
				}
			} else {
				sKills[0] = EOS;
			}
			
			set_hudmessage(g_Options_HUD_Color[id][C_RED], g_Options_HUD_Color[id][C_GREEN], g_Options_HUD_Color[id][C_BLUE], g_Options_HUD_Position[id][0], g_Options_HUD_Position[id][1], g_Options_HUD_Effect[id], 6.0, 1.1, 0.0, 0.0, 3);
			ShowSyncHudMsg(id, g_HudGeneral, "Torre: %d^nOro: %d^n%s^nVida: %d^n%sPoder: %s%s%s", g_TowerHealth, g_Gold[id], sKills, g_Health[id], sProgress, sPower, sText, sGordoHealth);
		}
	} else {
		for(id = 1; id <= g_MaxUsers; ++id) {
			if(!is_user_alive(id)) {
				continue;
			}
			
			if(g_Options_HUD_ProgressClass[id]) {
				addDot(g_ClassReqs[id][g_ClassId[id]], sProgress_Req, 14);
				addDot(CLASSES[g_ClassId[id]][classReqLv1 + g_ClassLevel[id][g_ClassId[id]]], sProgress_ReqTotal, 14);
				
				formatex(sProgress, 55, "%s: %s / %s^n", CLASSES[g_ClassId[id]][className], sProgress_Req, sProgress_ReqTotal);
			} else {
				sProgress[0] = EOS;
			}
			
			set_hudmessage(g_Options_HUD_Color[id][C_RED], g_Options_HUD_Color[id][C_GREEN], g_Options_HUD_Color[id][C_BLUE], g_Options_HUD_Position[id][0], g_Options_HUD_Position[id][1], g_Options_HUD_Effect[id], 6.0, 1.1, 0.0, 0.0, 3);
			ShowSyncHudMsg(id, g_HudGeneral, "Vida: %d^n%s", g_Health[id], sProgress);
		}
	}
	
	entity_set_float(ent, EV_FL_nextthink, NEXTTHINK_THINK_HUDGRAL);
}

clearDHUDs() {
	new i;
	for(i = 0; i < 8; ++i) {
		set_dhudmessage(0, 0, 0, -1.0, 0.2, 0, 0.0, 0.1, 0.1, 0.1);
		show_dhudmessage(0, "");
	}
}

public getUsersAlive() {
	new iAlives = 0;
	new i;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(is_user_alive(i)) {
			++iAlives;
		}
	}
	
	return iAlives;
}

public getTotalLevelG() {
	new iTotalLevel = 0;
	new i;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(is_user_alive(i)) {
			iTotalLevel += g_LevelG[i];
		}
	}
	
	return iTotalLevel;
}

public getUsersPlaying() {
	new iPlaying = 0;
	new i;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i))
			continue;
		
		++iPlaying;
	}
	
	return iPlaying;
}

stock getUserTeam(const id) {
	if(pev_valid(id) != PDATA_SAFE)
		return FM_CS_TEAM_UNASSIGNED;
	
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

stock setUserTeam(const id, const team) {
	if(pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX);
}

public repeatHUD() {
	--g_TotalMonsters;
	
	if(!g_TotalMonsters) {
		g_NextWaveIncoming = (g_Wave < 10) ? 1 : 2;
	}
	
	clearDHUDs();
	entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
}

public concmd_CreateGaminga(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	new Float:vecOrigin[3];
	new Float:vecTargetOrigin[3];
	new Float:vecAngles[3];
	new vecOriginId[3];
	
	get_user_origin(id, vecOriginId, 3);
	
	IVecFVec(vecOriginId, vecOrigin);
	
	vecOrigin[2] += 5.0;
	
	new iEnt;
	iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, "entGaminga");
		
		dllfunc(DLLFunc_Spawn, iEnt);
		
		entity_set_model(iEnt, MODEL_GAMINGA);
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
		
		new sFile[80];
		new sText[128];
		
		formatex(sFile, charsmax(sFile), "addons/amxmodx/configs/evas/%s/spawns.cfg", g_MapName);
		formatex(sText, charsmax(sText), "%f %f %f %f %f %f", vecOrigin[0], vecOrigin[1], vecOrigin[2], vecAngles[0], vecAngles[1], vecAngles[2]);
		
		new iFile = fopen(sFile, "r+");
		
		if(iFile) {
			write_file(sFile, sText, -1);
			fclose(iFile);
			
			colorChat(id, print_chat, "%sEl archivo !g%s!y ha sido guardado exitosamente!", TD_PREFIX, sFile);
		}
	}
	
	return PLUGIN_HANDLED;
}

public loadGaminga() {
	new sText[80];
	formatex(sText, charsmax(sText), "addons/amxmodx/configs/evas/%s/spawns.cfg", g_MapName);
	
	if(!file_exists(sText))	{
		write_file(sText, "; MAPA <X Y Z ANGLES>", -1);
		return;
	}
	
	new iFile;
	new sLine[256];
	new sOrigin[3][16];
	new sAngles[3][16];
	new Float:vecAngles[3];
	
	iFile = fopen(sText, "rt");
	
	while(!feof(iFile))	{
		fgets(iFile, sLine, charsmax(sLine));
		
		if(!sLine[0] || sLine[0] == ';' || sLine[0] == ' ' || ( sLine[0] == '/' && sLine[1] == '/'))
			continue;
		
		parse(sLine, sOrigin[0], 15, sOrigin[1], 15, sOrigin[2], 15, sAngles[0], 15, sAngles[1], 15, sAngles[2], 15);
		
		g_EntGaminga[g_EntGamingaNums] = create_entity("info_target");
		
		if(is_valid_ent(g_EntGaminga[g_EntGamingaNums])) {
			entity_set_string(g_EntGaminga[g_EntGamingaNums], EV_SZ_classname, "entGaminga");
			
			dllfunc(DLLFunc_Spawn, g_EntGaminga[g_EntGamingaNums]);
			
			g_EntGamingaOrigin[g_EntGamingaNums][0] = str_to_float(sOrigin[0]);
			g_EntGamingaOrigin[g_EntGamingaNums][1] = str_to_float(sOrigin[1]);
			g_EntGamingaOrigin[g_EntGamingaNums][2] = str_to_float(sOrigin[2]) + 32.0;
			
			vecAngles[0] = str_to_float(sAngles[0]);
			vecAngles[1] = str_to_float(sAngles[1]);
			vecAngles[2] = str_to_float(sAngles[2]);
			
			entity_set_model(g_EntGaminga[g_EntGamingaNums], MODEL_GAMINGA);
			entity_set_origin(g_EntGaminga[g_EntGamingaNums], g_EntGamingaOrigin[g_EntGamingaNums]);
			entity_set_vector(g_EntGaminga[g_EntGamingaNums], EV_VEC_angles, vecAngles);

			entity_set_size(g_EntGaminga[g_EntGamingaNums], Float:{-16.0, -16.0, -16.0}, Float:{16.0, 16.0, 9999.0});
			
			entity_set_int(g_EntGaminga[g_EntGamingaNums], EV_INT_solid, SOLID_BBOX);
			entity_set_int(g_EntGaminga[g_EntGamingaNums], EV_INT_movetype, MOVETYPE_TOSS);
			
			entity_set_int(g_EntGaminga[g_EntGamingaNums], EV_INT_sequence, 0);
			entity_set_float(g_EntGaminga[g_EntGamingaNums], EV_FL_animtime, get_gametime());
			entity_set_float(g_EntGaminga[g_EntGamingaNums], EV_FL_gravity, 1.0);
			
			drop_to_floor(g_EntGaminga[g_EntGamingaNums]);

			entity_set_size(g_EntGaminga[g_EntGamingaNums], Float:{-16.0, -16.0, -16.0}, Float:{16.0, 16.0, 9999.0});

			//entity_set_size(g_EntGaminga[g_EntGamingaNums], Float:{-41.559999, -46.900000, -25.940000}, Float:{41.610001, 46.920000, 9999.0});
		}
		
		++g_EntGamingaNums;
	}
	
	fclose(iFile);
}

public showMenu__Shop(const id) {
	new iMenu;
	iMenu = menu_create("Hola,^n¿Qué necesitás?", "menu__Shop");
	
	menu_additem(iMenu, "ARMAS", "1");
	menu_additem(iMenu, "GRANADAS", "2");
	menu_additem(iMenu, "OTROS", "3");
	menu_additem(iMenu, "PODERES^n", "4");
	
	menu_additem(iMenu, "RECARGAR ARMAS \y[10 Oro]", "5");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "SALIR");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public checkDistanceFromGAMINGA(const id) {
	new Float:vecOrigin[3];
	new Float:fDistance;
	new i;
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	for(i = 0; i < g_EntGamingaNums; ++i) {
		fDistance = get_distance_f(g_EntGamingaOrigin[i], vecOrigin);
		
		if(fDistance <= 150.0) {
			return 1;
		}
	}
	
	return 0;
}

public menu__Shop(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	DestroyLocalMenu(id, menuId);
	
	if(g_WaveInProgress && iItem != 4 && iItem != 5) {
		colorChat(id, _, "%sSolo puedo recargar tus armas o vender poderes mientras hay una oleada en marcha.", TD_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	switch(iItem) {
		case 1: showMenu__Weapons(id);
		case 2: showMenu__Grenades(id);
		case 3: showMenu__OthersShop(id);
		case 4: showMenu__Powers(id);
		case 5: {
			if(g_Gold[id] >= 10) {
				if(!checkDistanceFromGAMINGA(id)) {
					colorChat(id, _, "%sEstás demasiado lejos, acercate para poder negociar!", TD_PREFIX);
					return PLUGIN_HANDLED;
				}
				
				new Float:fGameTime;
				fGameTime = g_NoReload[id] - get_gametime();
				
				if(fGameTime > 0.0) {
					colorChat(id, CT, "%sOye oye, despacio cerebrito, tenés que esperar !t%0.2f segundos!y para volver a recargar tus armas.", TD_PREFIX, fGameTime);
					return PLUGIN_HANDLED;
				}
				
				reloadWeapons(id);
			} else {
				colorChat(id, _, "%sLo siento, pero necesitás más oro para !grecargar tus armas!y.", TD_PREFIX);
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public reloadWeapons(const id) {
	new i;
	new iWeapons = 0;
	new iNoLoad = 0;
	new iLoad = 0;
	new iWeaponId;
	new iExtraClip;
	new iWId;
	
	for(i = 0; i < sizeof(WEAPON_NAMES); ++i) {
		iWId = WEAPON_NAMES[i][weaponId];
		if(user_has_weapon(id, iWId)) {
			if(iWId == CSW_DEAGLE && g_ClassId[id] != CLASS_PISTOLERO) {
				continue;
			}

			iWeapons = 1;
			
			iWeaponId = fm_find_ent_by_owner(-1, WEAPON_NAMES[i][weaponEnt], id);
			
			iExtraClip = DEFAULT_MAXCLIP[iWId];
			
			if(g_HabCacheClip[id]) {
				iExtraClip = iExtraClip + ((iExtraClip * g_HabCacheClip[id]) / 100);
			}

			if(iWId == CLASSES_WEAPONS[g_ClassId[id]][0] || iWId == CLASSES_WEAPONS[g_ClassId[id]][1]) {
				iExtraClip += CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip];
			}

			if((cs_get_weapon_ammo(iWeaponId) == iExtraClip)) {
				if(cs_get_user_bpammo(id, iWId) >= 200) {
					iNoLoad = 1;
					continue;
				}
			}
			
			cs_set_weapon_ammo(iWeaponId, iExtraClip);
			cs_set_user_bpammo(id, iWId, 200);
			
			iLoad = 1;
		}
	}
	
	if(!iWeapons) {
		colorChat(id, _, "%sNo tenés armas para recargar.", TD_PREFIX);
		return;
	}
	
	if(iLoad) {
		g_Gold[id] -= 10;
		colorChat(id, _, "%sTus armas han sido recargadas.", TD_PREFIX);
		
		g_NoReload[id] = get_gametime() + 15.0;
	} else if(iNoLoad) {
		colorChat(id, _, "%sTus armas están llenas.", TD_PREFIX);
	}
}

public showMenu__Weapons(const id) {
	new sPosition[3];
	new sWeapon[48];
	new iMenu;
	new i;
	
	iMenu = menu_create("Estas son las armas que tengo:\R", "menu__Weapons");
	
	for(i = 0; i < sizeof(WEAPON_NAMES)-1; ++i) {
		num_to_str((i + 1), sPosition, charsmax(sPosition));

		if(WEAPON_NAMES[i][weaponClassRecommended] != g_ClassId[id]) {
			formatex(sWeapon, charsmax(sWeapon), "%s %s[%d Oro]", WEAPON_NAMES[i][weaponName], (g_Gold[id] >= WEAPON_NAMES[i][weaponGold]) ? "\y" : "\d", WEAPON_NAMES[i][weaponGold]);
		} else {
			formatex(sWeapon, charsmax(sWeapon), "\y%s %s[%d Oro]", WEAPON_NAMES[i][weaponName], (g_Gold[id] >= WEAPON_NAMES[i][weaponGold]) ? "\y" : "\d", WEAPON_NAMES[i][weaponGold]);
		}
		
		menu_additem(iMenu, sWeapon, sPosition);
	}
	
	menu_setprop(iMenu, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenu, MPROP_NEXTNAME, "PÁG. SIGUIENTE");
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__Weapons(const id, const menuId, const item) {
	if(g_WaveInProgress) {
		colorChat(id, _, "%sNo puedo vender cosas mientras hay una oleada en marcha.", TD_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	if(g_Gold[id] >= WEAPON_NAMES[iItem][weaponGold]) {
		if(user_has_weapon(id, WEAPON_NAMES[iItem][weaponId])) {
			colorChat(id, _, "%sYa tenés el arma seleccionada (!g%s!y).", TD_PREFIX, WEAPON_NAMES[iItem][weaponName]);
			
			showMenu__Weapons(id);
			return PLUGIN_HANDLED;
		} else if(WEAPON_NAMES[iItem][weaponPremium] && !g_UserPremium[id]) {
			colorChat(id, _, "%sNecesitás ser usuario premium para poder utilizar esta arma.", TD_PREFIX);
			
			showMenu__Weapons(id);
			return PLUGIN_HANDLED;
		}
		
		//hamStripWeapons(id, "weapon_deagle");
		
		g_Gold[id] -= WEAPON_NAMES[iItem][weaponGold];
		
		give_item(id, WEAPON_NAMES[iItem][weaponEnt]);
		
		cs_set_user_bpammo(id, WEAPON_NAMES[iItem][weaponId], 200);
		
		colorChat(id, _, "%sCompraste !g%s!y.", TD_PREFIX, WEAPON_NAMES[iItem][weaponName]);
	}
	else {
		colorChat(id, _, "%sLo siento, pero necesitás más oro para comprar !g%s!y.", TD_PREFIX, WEAPON_NAMES[iItem][weaponName]);
	}
	
	showMenu__Weapons(id);
	return PLUGIN_HANDLED;
}

public showMenu__Grenades(const id) {
	if(g_Wave >= MAX_WAVES) {
		colorChat(id, _, "%sNo podés comprar granadas en este punto!", TD_PREFIX);
		
		showMenu__Shop(id);
		return;
	}
	
	new sPosition[3];
	new sWeapon[48];
	new iMenu;
	new i;
	
	iMenu = menu_create("Estas son las granadas que tengo:", "menu__Grenades");
	
	for(i = 0; i < sizeof(GRENADES_NAMES); ++i) {
		if(g_IonUsed && i == NADE_ION_BOMB) {
			continue;
		}

		num_to_str((i + 1), sPosition, charsmax(sPosition));
		formatex(sWeapon, charsmax(sWeapon), "%s %s[%d Oro]", GRENADES_NAMES[i][weaponName], (g_Gold[id] >= GRENADES_NAMES[i][weaponGold]) ? "\y" : "\d", GRENADES_NAMES[i][weaponGold]);
		
		menu_additem(iMenu, sWeapon, sPosition);
	}
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__Grenades(const id, const menuId, const item) {
	if(g_WaveInProgress) {
		colorChat(id, _, "%sNo puedo vender cosas mientras hay una oleada en marcha.", TD_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;

	if(g_IonUsed && iItem == NADE_ION_BOMB) {
		showMenu__Grenades(id);
		return PLUGIN_HANDLED;
	}
	
	if(g_Gold[id] >= GRENADES_NAMES[iItem][weaponGold]) {
		g_Gold[id] -= GRENADES_NAMES[iItem][weaponGold];
		
		if(user_has_weapon(id, GRENADES_NAMES[iItem][weaponId])) {
			cs_set_user_bpammo(id, GRENADES_NAMES[iItem][weaponId], cs_get_user_bpammo(id, GRENADES_NAMES[iItem][weaponId]) + 1);
		} else {
			give_item(id, GRENADES_NAMES[iItem][weaponEnt]);
		}
		
		++g_Nades[id][iItem];
		
		colorChat(id, _, "%sCompraste !g%s!y.", TD_PREFIX, GRENADES_NAMES[iItem][weaponName]);

		if(iItem == NADE_ION_BOMB) {
			replaceWeaponModels(id, CSW_HEGRENADE);
			g_IonUsed = 1;
		}
	}
	else {
		colorChat(id, _, "%sLo siento, pero necesitás más oro para comprar !g%s!y.", TD_PREFIX, GRENADES_NAMES[iItem][weaponName]);
	}
	
	showMenu__Grenades(id);
	return PLUGIN_HANDLED;
}

public touch__GrenadeAll(const grenade, const ent) {
	if(is_valid_ent(grenade) && isSolid(ent)) {
		new iNadeType = entity_get_int(grenade, EV_NADE_TYPE);

		if(iNadeType == NADE_TYPE_ION_BOMB) {
			entity_set_vector(grenade, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
		}

		entity_set_float(grenade, EV_FL_dmgtime, get_gametime() + 0.001);
	}
}

stock isSolid(const ent) {
	return (ent ? ((entity_get_int(ent, EV_INT_solid) > SOLID_TRIGGER) ? 1 : 0) : 1);
}

public zoneTouch(const monster, const ent) {
	new iZoneMode;
	iZoneMode = entity_get_int(ent, ZONE_ID);
	
	switch(iZoneMode) {
		case ZM_BLOCK_ALL, ZM_BLOCK_ALL_2: {
			if(isSpecialMonster(monster)) {
				__explodeBoomer(monster);	
				return;
			}
			
			if(isMonster(monster) && entity_get_int(monster, MONSTER_TRACK) != 1) {
				entity_set_int(monster, MONSTER_TRACK, 1);
				
				entity_set_int(monster, EV_INT_sequence, 76);
				entity_set_float(monster, EV_FL_animtime, get_gametime());
				
				entity_set_int(monster, EV_INT_gamestate, 1);
				
				entity_set_vector(monster, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				if(iZoneMode == ZM_BLOCK_ALL) {
					entity_get_vector(monster, EV_VEC_origin, g_VecMonsterTowerOrigin[0]);
				} else {
					entity_get_vector(monster, EV_VEC_origin, g_VecMonsterTowerOrigin[1]);
				}
				
				emit_sound(monster, CHAN_BODY, MONSTER_SOUNDS_CLAW[random_num(0, charsmax(MONSTER_SOUNDS_CLAW))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(monster, MONSTER_TARGET, 1337);
				
				set_hudmessage(255, 255, 0, -1.0, 0.26, 0, 0.0, 10.0, 0.0, 0.0, 4);
				ShowSyncHudMsg(0, g_HudDamageTower, "¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!");
				
				new iDamage = 5;
				
				if(DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower]) {
					iDamage = iDamage + ((iDamage * DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower]) / 100);
				}
				
				g_Achievement_DefensaAbsoluta = 0;
				
				g_TowerHealth -= iDamage;
				
				set_task(1.0, "damageTower", TASK_DAMAGE_TOWER + monster);

				// if(g_RobotEnt && g_RobotMissileAllowed) {
					// g_RobotMissileAllowed = 0;
					// robotFireMissiles();
				// }
			}
		}
		case ZM_KILL_T1: {
			g_InBlockZone[monster] = 1;
		}
		case ZM_KILL_T2: {
			g_InBlockZone[monster] = 0;
		}
	}
}

public createZone(const Float:vecPos[3], const Float:vecMins[3], const Float:vecMaxs[3], const iZoneMode) {
	new iEnt = create_entity("info_target");
	
	if(is_valid_ent(iEnt)) {
		entity_set_string(iEnt, EV_SZ_classname, "entWGM");
		entity_set_model(iEnt, MODEL_GIB_SKULL);
		entity_set_origin(iEnt, vecPos);
		
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
		entity_set_int(iEnt, EV_INT_iuser4, 1337);
		
		if(g_EditorId)
			entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
		else
			entity_set_int(iEnt, EV_INT_solid, ZONE_SOLID_TYPE[iZoneMode]);
		
		entity_set_size(iEnt, vecMins, vecMaxs);
		
		entity_set_int(iEnt, EV_INT_effects, entity_get_int(iEnt, EV_INT_effects) | EF_NODRAW);
		
		entity_set_int(iEnt, ZONE_ID, iZoneMode);
	}
	
	return iEnt;
}

drawLine(const Float:x1, const Float:y1, const Float:z1, const Float:x2, const Float:y2, const Float:z2, green = 0) {
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
	}
	else {
		write_byte(0);
		write_byte(255);
		write_byte(0);
	}
	write_byte(200);
	write_byte(0);
	message_end();
}

public showAllZones() {
	findAllZones();
	
	new i;
	new iZone;
	
	for(i = 0; i < g_MaxZones; ++i) {
		iZone = g_Zone[i];
		
		remove_task(TASK_SHOWZONE + iZone);
		entity_set_int(iZone, EV_INT_solid, SOLID_NOT);
		
		set_task(0.2, "showZoneBox", TASK_SHOWZONE + iZone, _, _, "b");
	}
}

public showZoneBox(entity) {
	entity -= TASK_SHOWZONE;
	
	if((!is_valid_ent(entity)) || !g_EditorId)
		return;
	
	new Float:vecOrigin[3];
	entity_get_vector(entity, EV_VEC_origin, vecOrigin);
	
	new Float:vecEditorOrigin[3];
	new Float:vecHitPoint[3];
	
	entity_get_vector(g_EditorId, EV_VEC_origin, vecEditorOrigin);
	
	fm_trace_line(-1, vecEditorOrigin, vecOrigin, vecHitPoint);
	
	if(entity == g_Zone[g_ZoneId])
		drawLine(vecEditorOrigin[0], vecEditorOrigin[1], vecEditorOrigin[2] - 16.0, vecOrigin[0], vecOrigin[1], vecOrigin[2], 1);
	
	new Float:fDistanceHead = vector_distance(vecEditorOrigin, vecOrigin) - vector_distance(vecEditorOrigin, vecHitPoint);
	if((floatabs(fDistanceHead) > 128.0) && (entity != g_Zone[g_ZoneId]))
		return;
	
	new Float:vecMins[3];
	new Float:vecMax[3];
	
	entity_get_vector(entity, EV_VEC_mins, vecMins);
	entity_get_vector(entity, EV_VEC_maxs, vecMax);
	
	vecMins[0] += vecOrigin[0];
	vecMins[1] += vecOrigin[1];
	vecMins[2] += vecOrigin[2];
	
	vecMax[0] += vecOrigin[0];
	vecMax[1] += vecOrigin[1];
	vecMax[2] += vecOrigin[2];
	
	if(entity != g_Zone[g_ZoneId]) {
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
	}
	else {
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
	
	if(entity != g_Zone[g_ZoneId])
		return;
	
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
	
	if (g_Direction == 2) {
		drawLine(vecMax[0], vecMax[1], vecMax[2], vecMins[0], vecMins[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMins[1], vecMax[2], vecMins[0], vecMax[1], vecMax[2], 1);
		drawLine(vecMax[0], vecMax[1], vecMins[2], vecMins[0], vecMins[1], vecMins[2], 1);
		drawLine(vecMax[0], vecMins[1], vecMins[2], vecMins[0], vecMax[1], vecMins[2], 1);
	}
}

public hideAllZones() {
	g_EditorId = 0;
	
	new i;
	new iId;
	for(i = 0; i < g_MaxZones; ++i)	{
		iId = entity_get_int(g_Zone[i], ZONE_ID);
		entity_set_int(g_Zone[i], EV_INT_solid, ZONE_SOLID_TYPE[iId]);
		
		remove_task(TASK_SHOWZONE + g_Zone[i]);
	}
}

public findAllZones() {
	new iEnt = -1;
	g_MaxZones = 0;
	
	while((iEnt = fm_find_ent_by_class(iEnt, "entWGM"))) {
		g_Zone[g_MaxZones] = iEnt;
		++g_MaxZones;
	}
}

public openWGM(const id) {
	new sMenu[512];
	new iZoneMode = -1;
	
	if(is_valid_ent(g_Zone[g_ZoneId]))
		iZoneMode = entity_get_int(g_Zone[g_ZoneId], ZONE_ID);
	
	format(sMenu, charsmax(sMenu), "\yWGM^n^n\y%d\w zonas encontradas^n", g_MaxZones);
	
	if(iZoneMode != -1)
		format(sMenu, charsmax(sMenu), "%s (Actual: \y%i\r --> \w%s)^n^n\r1.\w Editar zona actual^n\r2.\w Ver zona anterior^n\r3.\w Ver zona siguiente", sMenu, g_ZoneId + 1, ZONE_MODE[zoneMode:iZoneMode]);
	
	format(sMenu, charsmax(sMenu), "%s^n^n\r4.\w Crear nueva zona", sMenu);
	
	if(iZoneMode != -1)
		format(sMenu, charsmax(sMenu), "%s^n^n\r6. \yBORRAR\w zona actual", sMenu);
	
	format(sMenu, charsmax(sMenu), "%s^n^n\r9.\w Guardar todos los cambios^n\r0.\w Salir", sMenu);
	
	show_menu(id, KEYSMENU, sMenu, -1, "WGM Main");
}

public menu__WGM_Main(const id, const key) {
	switch(key)
	{
		case 0: {
			if(is_valid_ent(g_Zone[g_ZoneId]))
				openEditMenu(id);
			else
				openWGM(id);
		}
		case 1: {
			g_ZoneId = (g_ZoneId > 0) ? g_ZoneId - 1 : g_ZoneId;
			openWGM(id);
		}
		case 2: {
			g_ZoneId = (g_ZoneId < g_MaxZones - 1) ? g_ZoneId + 1 : g_ZoneId;
			openWGM(id);
		}
		case 3: openWGM__CreateNewZone(id);
		case 5: show_menu(id, KEYSMENU, "\rATENCION!^n\yBORRAR ZONA ACTUAL ?^n^n\r1.\w NO^n\r0.\w SI", -1, "WGM Kill");
		case 8: {
			new sZoneFile[200];
			
			if(!dir_exists(sZoneFile))
				mkdir(sZoneFile);
			
			formatex(sZoneFile, 199, "addons/amxmodx/configs/walkguard/%s.wgz", g_MapName);
			
			delete_file(sZoneFile);
			
			findAllZones();
			
			new i;
			new iZone;
			new iZoneMode;
			new Float:vecOrigin[3];
			new Float:vecMins[3];
			new Float:vecMaxs[3];
			new sText[128];
			
			for(i = 0; i < g_MaxZones; ++i)
			{
				iZone = g_Zone[i];
				iZoneMode = entity_get_int(iZone, ZONE_ID);
				
				entity_get_vector(iZone, EV_VEC_origin, vecOrigin);
				
				entity_get_vector(iZone, EV_VEC_mins, vecMins);
				entity_get_vector(iZone, EV_VEC_mins, vecMaxs);
				
				formatex(sText, 127, "%s %.1f %.1f %.1f %.0f %.0f %.0f %.0f %.0f %.0f", ZONE_NAME[iZoneMode], vecOrigin[0], vecOrigin[1], vecOrigin[2], vecMins[0], vecMins[1], vecMins[2], vecMaxs[0], vecMaxs[1], vecMaxs[2]);
				
				write_file(sZoneFile, sText);
			}
			
			colorChat(id, _, "%sSe guardo correctamente el archivo: !g%s!y.", TD_PREFIX, sZoneFile);
			openWGM(id);
		}
		case 9: {
			g_EditorId = 0;
			hideAllZones();
		}
	}
}

public openWGM__CreateNewZone(const id) {
	show_menu(id, KEYSMENU, "\r1.\w Crear nueva zona^n^n\r2.\w Apunta arriba a la derecha^n\r3.\w Apunta abajo a la izquierda^n\r4.\w Crear zona predefinida^n^n\r0.\w Salir", -1, "WGM Create New Zone");
}

public menu__WGM_CreateNewZone(const id, const key) {
	switch(key) {
		case 0: {
			if(g_MaxZones < MAX_ZONES - 1) {
				new Float:vecOrigin[3];
				entity_get_vector(id, EV_VEC_origin, vecOrigin);
				
				new Float:vecMins[3] = {-32.0, -32.0, -32.0};
				new Float:vecMaxs[3] = {32.0, 32.0, 32.0};
				
				new iEnt = createZone(vecOrigin, vecMins, vecMaxs, 0);
				
				findAllZones();
				
				new i;
				for(i = 0; i < g_MaxZones; i++) {
					if(g_Zone[i] == iEnt)
						g_ZoneId = i;
				}
				
				showAllZones();
				menu__WGM_Main(id, 0);
			}
			else {
				colorChat(id, _, "%sSolo se pueden crear hasta diez zonas.", TD_PREFIX);
				openWGM__CreateNewZone(id);
			}
		}
		case 1: {
			new Float:vecOrigin[3];
			new vecOriginId[3];
			
			get_user_origin(id, vecOriginId, 3);
			
			IVecFVec(vecOriginId, vecOrigin);
			
			g_ZoneBox[0] = vecOrigin;
			
			openWGM__CreateNewZone(id);
		}
		case 2: {
			new Float:vecOrigin[3];
			new vecOriginId[3];
			
			get_user_origin(id, vecOriginId, 3);
			
			IVecFVec(vecOriginId, vecOrigin);
			
			g_ZoneBox[1] = vecOrigin;
			
			openWGM__CreateNewZone(id);
		}
		case 3: {
			if((g_ZoneBox[0][0] == 0.0 && g_ZoneBox[0][1] == 0.0 && g_ZoneBox[0][2] == 0.0) || (g_ZoneBox[1][0] == 0.0 && g_ZoneBox[1][1] == 0.0 && g_ZoneBox[1][2] == 0.0)) {
				colorChat(id, _, "%sFalta indicar una de las posiciones para crear la zona predefinida.", TD_PREFIX);
				openWGM__CreateNewZone(id);
				
				return;
			}
			
			if(g_MaxZones < MAX_ZONES - 1) {
				new iEnt;
				new Float:vecCenter[3];
				new Float:vecSize[3];
				new Float:vecMins[3];
				new Float:vecMaxs[3];
				
				for(new i = 0; i < 3; ++i) {
					vecCenter[i] = (g_ZoneBox[0][i] + g_ZoneBox[1][i]) / 2.0;
					
					vecSize[i] = getFloatDistance(g_ZoneBox[0][i], g_ZoneBox[1][i]);
					
					vecMins[i] = vecSize[i] / -2.0;
					vecMaxs[i] = vecSize[i] / 2.0;
					
					g_ZoneBox[0][i] = 0.0;
					g_ZoneBox[1][i] = 0.0;
				}
				
				iEnt = createZone(vecCenter, vecMins, vecMaxs, ZM_KILL_T2);
				
				findAllZones();
				
				new i;
				for(i = 0; i < g_MaxZones; i++) {
					if(g_Zone[i] == iEnt)
						g_ZoneId = i;
				}
				
				showAllZones();
				menu__WGM_Main(id, 0);
			}
			else {
				colorChat(id, _, "%sSolo se pueden crear hasta veinte zonas.", TD_PREFIX);
				openWGM(id);
			}
		}
		case 9: {
			openWGM(id);
			return;
		}
	}
}

public openEditMenu(const id) {
	new sMenu[256];
	new iZoneMode = -1;
	
	format(sMenu, charsmax(sMenu), "\yEDITAR ZONA^n^n");
	
	if(is_valid_ent(g_Zone[g_ZoneId]))
		iZoneMode = entity_get_int(g_Zone[g_ZoneId], ZONE_ID);
	
	if(iZoneMode != -1)
		format(sMenu, charsmax(sMenu), "%s\r1.\w Editar funcion: \y%s\w^n", sMenu, ZONE_MODE[zoneMode:iZoneMode]);
	
	format(sMenu, charsmax(sMenu), "%s^n\r4.\w Cambiar coordenada^n\y%s^n^n\r5.\w Acortar^n\r6.\w Alargar^n\r7.\w Acortar^n\r8.\w Alargar^n^n\r9.\w Incrementar en \y%d\w unidades^n^n\r0.\w Salir", sMenu, NAME_COORD[g_Direction], g_SetUnits);
	
	show_menu(id, KEYSMENU, sMenu, -1, "WGM Edit");
}

public menu__WGM_Edit(const id, const key) {
	switch(key) {
		case 0: {
			new iZoneMode = -1;
			iZoneMode = entity_get_int(g_Zone[g_ZoneId], ZONE_ID);
			
			if(iZoneMode == (zoneMode-1))
				iZoneMode = 0;
			else
				++iZoneMode;
			
			entity_set_int(g_Zone[g_ZoneId], ZONE_ID, iZoneMode);
		}
		case 3: g_Direction = (g_Direction < 2) ? g_Direction + 1 : 0;
		case 4: zUrotAddieren();
		case 5: vOnRotAbziehen();
		case 6: vOnGelAbziehen();
		case 7: zUgelAddieren();
		case 8: g_SetUnits = (g_SetUnits < 100) ? g_SetUnits * 10 : 1;
		case 9: {
			openWGM(id);
			return PLUGIN_HANDLED;
		}
	}
	
	openEditMenu(id);
	
	return PLUGIN_HANDLED;
}

public menu__WGM_Kill(const id, const key) {
	if(key == 9) {
		remove_entity(g_Zone[g_ZoneId]);
		
		--g_ZoneId;
		
		if (g_ZoneId < 0)
			g_ZoneId = 0;
		
		colorChat(id, _, "%sZona borrada.", TD_PREFIX);
		findAllZones();
	}
	
	openWGM(id);
}

public vOnRotAbziehen() {
	new iEnt = g_Zone[g_ZoneId];
	
	new Float:vecOrigin[3];
	entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
	
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	entity_get_vector(iEnt, EV_VEC_mins, vecMins);
	entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
	
	vecMins[g_Direction] -= float(g_SetUnits) / 2.0;
	vecMaxs[g_Direction] += float(g_SetUnits) / 2.0;
	vecOrigin[g_Direction] -= float(g_SetUnits) / 2.0;
	
	entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
	entity_set_size(iEnt, vecMins, vecMaxs);
}

public zUrotAddieren() {
	new iEnt = g_Zone[g_ZoneId];
	
	new Float:vecOrigin[3];
	entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
	
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	entity_get_vector(iEnt, EV_VEC_mins, vecMins);
	entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
	
	if((floatabs(vecMins[g_Direction]) + vecMaxs[g_Direction]) < g_SetUnits + 1)
		return;
	
	vecMins[g_Direction] += float(g_SetUnits) / 2.0;
	vecMaxs[g_Direction] -= float(g_SetUnits) / 2.0;
	vecOrigin[g_Direction] += float(g_SetUnits) / 2.0;
	
	entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
	entity_set_size(iEnt, vecMins, vecMaxs);
}

public vOnGelAbziehen() {
	new iEnt = g_Zone[g_ZoneId];
	
	new Float:vecOrigin[3];
	entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
	
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	entity_get_vector(iEnt, EV_VEC_mins, vecMins);
	entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
	
	if((floatabs(vecMins[g_Direction]) + vecMaxs[g_Direction]) < g_SetUnits + 1)
		return;
	
	vecMins[g_Direction] += float(g_SetUnits) / 2.0;
	vecMaxs[g_Direction] -= float(g_SetUnits) / 2.0;
	vecOrigin[g_Direction] -= float(g_SetUnits) / 2.0;
	
	entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
	entity_set_size(iEnt, vecMins, vecMaxs);
}

public zUgelAddieren() {
	new iEnt = g_Zone[g_ZoneId];
	
	new Float:vecOrigin[3];
	entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
	
	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
	entity_get_vector(iEnt, EV_VEC_mins, vecMins);
	entity_get_vector(iEnt, EV_VEC_maxs, vecMaxs);
	
	vecMins[g_Direction] -= float(g_SetUnits) / 2.0;
	vecMaxs[g_Direction] += float(g_SetUnits) / 2.0;
	vecOrigin[g_Direction] += float(g_SetUnits) / 2.0;
	
	entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
	entity_set_size(iEnt, vecMins, vecMaxs);
}

stock Float:getFloatDistance(Float:num1, Float:num2) { 
	if(num1 > num2)
		return (num1 - num2);
	else if(num2 > num1) 
		return (num2 - num1);
	
	return 0.0;
}

public concmd_WalkGuardMenu(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	g_EditorId = id;
	
	findAllZones();
	showAllZones();
	
	openWGM(id);
	
	return PLUGIN_HANDLED;
}

public concmd_Level(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	new sArg1[32];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[2];
	new sArg3[5];
	
	read_argv(2, sArg2, charsmax(sArg2));
	read_argv(3, sArg3, charsmax(sArg3));
	
	if(read_argc() < 3) {
		client_print(id, print_console, "[TD] Uso: td_level <nombre> <classId> <factor (+ , -)> <cantidad>");
		client_print(id, print_console, "classId");
		client_print(id, print_console, "0 = SOLDADO");
		client_print(id, print_console, "1 = INGENIERO");
		client_print(id, print_console, "2 = SOPORTE");
		client_print(id, print_console, "3 = FRANCOTIRADOR");
		client_print(id, print_console, "4 = APOYO");
		client_print(id, print_console, "5 = PESADO");
		client_print(id, print_console, "6 = ASALTO");
		client_print(id, print_console, "7 = COMANDANTE");
		
		return PLUGIN_HANDLED;
	}
	
	new iClassId;
	iClassId = str_to_num(sArg2);
	
	if(iClassId < 0 || iClassId >= classIds) {
		client_print(id, print_console, "[TD] El rango de clases permitido es de 0 a %d.", (classIds-1));
		return PLUGIN_HANDLED;
	}
	
	new iLevel;
	iLevel = str_to_num(sArg3);
	
	if(iLevel < 0 || iLevel > 6) {
		client_print(id, print_console, "[TD] El rango de niveles permitido es de 0 a 6.");
		return PLUGIN_HANDLED;
	}
	
	/*new iLastLevel;
	iLastLevel = g_ClassLevel[iTarget][iClassId];*/
	
	switch(sArg3[0]) {
		case '+', '-': {
			g_ClassLevel[iTarget][iClassId] += iLevel;
		}
		default: {
			g_ClassLevel[iTarget][iClassId] = iLevel;
		}
	}
	
	return PLUGIN_HANDLED;
}

public concmd_LevelG(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	new sArg1[32];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[5];	
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		client_print(id, print_console, "[TD] Uso: td_levelg <nombre> <factor (+ , -)> <cantidad>");
		return PLUGIN_HANDLED;
	}
	
	new iLevelG;
	iLevelG = str_to_num(sArg2);
	
	if(iLevelG < 0 || iLevelG > 100) {
		client_print(id, print_console, "[TD] El rango de niveles permitido es de 0 a 100.");
		return PLUGIN_HANDLED;
	}
	
	switch(sArg2[0]) {
		case '+', '-': {
			g_LevelG[iTarget] += iLevelG;
		}
		default: {
			g_LevelG[iTarget] = iLevelG;
		}
	}
	
	if(g_Rank[iTarget] && is_valid_ent(g_Rank[iTarget])) {
		remove_entity(g_Rank[iTarget]);
		
		g_Rank[iTarget] = create_entity("info_target");
		
		new Float:vecColor[3];
		new iRank = (g_LevelG[iTarget] / 10);
		
		vecColor = Float:{0.0, 0.0, 0.0};

		if(iRank < 1) {
			iRank = 12;
		} else if(iRank >= 4) {
			vecColor = Float:{255.0, 255.0, 0.0};
		}
		
		entity_set_int(g_Rank[iTarget], EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(g_Rank[iTarget], EV_ENT_aiment, iTarget);
		
		entity_set_int(g_Rank[iTarget], EV_INT_rendermode, kRenderNormal);
		entity_set_int(g_Rank[iTarget], EV_INT_renderfx, kRenderFxGlowShell);
		entity_set_float(g_Rank[iTarget], EV_FL_renderamt, 5.0);
		
		entity_set_model(g_Rank[iTarget], MODEL_RANKS);
		
		entity_set_int(g_Rank[iTarget], EV_INT_body, iRank);
		
		entity_set_vector(g_Rank[iTarget], EV_VEC_rendercolor, vecColor);
	}

	if(g_Hat[iTarget] && is_valid_ent(g_Hat[iTarget])) {
		remove_entity(g_Hat[iTarget]);
		
		g_Hat[iTarget] = create_entity("info_target");
		
		new iHat = (g_LevelG[iTarget] / 15);

		if(iHat > 5) {
			iHat = 5;
		}

		entity_set_int(g_Hat[iTarget], EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(g_Hat[iTarget], EV_ENT_aiment, iTarget);
		
		entity_set_model(g_Hat[iTarget], MODEL_HATS);
		
		entity_set_int(g_Hat[iTarget], EV_INT_body, iHat);
	}
	
	return PLUGIN_HANDLED;
}

public concmd__Os(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[32];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[5];	
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		client_print(id, print_console, "[TD] Uso: td_os <nombre> <factor (+ , -)> <cantidad>");
		return PLUGIN_HANDLED;
	}
	
	new iOs;
	iOs = str_to_num(sArg2);

	switch(sArg2[0]) {
		case '+', '-': {
			g_Osmio[iTarget] += iOs;
		}
		default: {
			g_Osmio[iTarget] = iOs;
		}
	}
	
	return PLUGIN_HANDLED;
}

public concmd__TowerHealth(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[32];
	new iTowerHealth;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTowerHealth = str_to_num(sArg1);

	g_TowerHealth = iTowerHealth;

	colorChat(0, _, "%s!t%s!y modificó la vida de la torre y ahora tiene !g%d!y", TD_PREFIX, g_UserName[id], iTowerHealth);
	
	return PLUGIN_HANDLED;
}

public concmd_Points(const id) {
	if(!g_Kiske[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sArg1[32];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[5];	
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		client_print(id, print_console, "[TD] Uso: td_points <nombre> <factor (+ , -)> <cantidad>");
		return PLUGIN_HANDLED;
	}
	
	new iPoints;
	iPoints = str_to_num(sArg2);
	
	if(iPoints < 0 || iPoints > 100) {
		client_print(id, print_console, "[TD] El rango de puntos permitido es de 0 a 100.");
		return PLUGIN_HANDLED;
	}
	
	switch(sArg2[0]) {
		case '+', '-': {
			g_Points[iTarget] += iPoints;
		}
		default: {
			g_Points[iTarget] = iPoints;
		}
	}
	
	return PLUGIN_HANDLED;
}

public concmd_Gold(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	new sArg1[32];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[21];
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		client_print(id, print_console, "[TD] Uso: td_gold <nombre> <factor (+ , -)> <cantidad>");
		return PLUGIN_HANDLED;
	}
	
	new iGold;
	iGold = str_to_num(sArg2);
	
	/*new iLastGold;
	iLastGold = g_Gold[iTarget];*/
	
	switch(sArg2[0]) {
		case '+', '-': {
			g_Gold[iTarget] += iGold;
		}
		default: {
			g_Gold[iTarget] = iGold;
		}
	}

	return PLUGIN_HANDLED;
}

public concmd_Health(const id) {
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;
	
	new sArg1[32];
	new iTarget;
	
	read_argv(1, sArg1, charsmax(sArg1));
	iTarget = cmd_target(id, sArg1, CMDTARGET_ALLOW_SELF);
	
	if(!iTarget) {
		return PLUGIN_HANDLED;
	}
	
	new sArg2[21];
	read_argv(2, sArg2, charsmax(sArg2));
	
	if(read_argc() < 2) {
		client_print(id, print_console, "[TD] Uso: td_health <nombre> <factor (+ , -)> <cantidad>");
		return PLUGIN_HANDLED;
	}
	
	new iHealth;
	iHealth = str_to_num(sArg2);
	
	switch(sArg2[0]) {
		case '+', '-': {
			set_user_health(iTarget, get_user_health(iTarget) + iHealth);
		}
		default: {
			set_user_health(iTarget, iHealth);
		}
	}

	return PLUGIN_HANDLED;
}

public loadWGM() {
	new sFile[100];
	new iFile;
	
	formatex(sFile, charsmax(sFile), "addons/amxmodx/configs/walkguard/%s.wgz", g_MapName);
	iFile = fopen(sFile, "r+");
	
	if(iFile) {
		new sVecPos[3][13];
		new sVecMins[3][13];
		new sVecMaxs[3][13];
		new sData[256];
		new sZoneName[32];
		new iZoneMode = -1;
		new Float:vecMins[3];
		new Float:vecMaxs[3];
		new Float:vecPos[3];
		new i;
	
		while(!feof(iFile)) {
			fgets(iFile, sData, charsmax(sData));
			
			if(sData[0]) {
				parse(sData, sZoneName, charsmax(sZoneName), sVecPos[0], 12, sVecPos[1], 12, sVecPos[2], 12, sVecMins[0], 12, sVecMins[1], 12, sVecMins[2], 12, sVecMaxs[0], 12, sVecMaxs[1], 12, sVecMaxs[2], 12);
				
				iZoneMode = -1;
				
				for(i = 0; i < zoneMode; ++i) {
					if(equal(sZoneName, ZONE_NAME[i])) {
						iZoneMode = i;
						break;
					}
				}
				
				if(iZoneMode == -1)
					continue;
				
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
					if(vecMins[i] > 0.0)
						vecMins[i] *= -1.0;
					
					if(vecMaxs[i] < 0.0)
						vecMaxs[i] *= -1.0;
				}
				
				createZone(vecPos, vecMins, vecMaxs, iZoneMode);
			}
		}
		
		fclose(iFile);
	}
	
	findAllZones();
	hideAllZones();
}

public showMenu__Powers(const id) {
	if(g_Wave > MAX_WAVES || (g_Wave == MAX_WAVES && !g_WaveInProgress)) {
		colorChat(id, _, "%sNo podés comprar poderes en este punto!", TD_PREFIX);
		
		showMenu__Shop(id);
		return;
	}
	
	new sPosition[3];
	new sWeapon[48];
	new iMenu;
	new i;
	
	iMenu = menu_create("Estos son los poderes que tengo:", "menu__Powers");
	
	for(i = 1; i < sizeof(POWER_NAMES); ++i) {
		num_to_str(i, sPosition, charsmax(sPosition));
		formatex(sWeapon, charsmax(sWeapon), "%s %s[%d Oro]", POWER_NAMES[i][powerName], (g_Gold[id] >= POWER_NAMES[i][powerGold]) ? "\y" : "\d", POWER_NAMES[i][powerGold]);
		
		menu_additem(iMenu, sWeapon, sPosition);
	}
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__Powers(const id, const menuId, const item) {
	if(g_Wave > MAX_WAVES || (g_Wave == MAX_WAVES && !g_WaveInProgress)) {
		DestroyLocalMenu(id, menuId);
		
		colorChat(id, _, "%sNo podés comprar poderes en este punto!", TD_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	if(!checkDistanceFromGAMINGA(id)) {
		DestroyLocalMenu(id, menuId);
		
		colorChat(id, _, "%sEstás demasiado lejos, acercate para poder negociar!", TD_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	if(g_Gold[id] >= POWER_NAMES[iItem][powerGold]) {
		if(iItem == POWER_BALAS_INFINITAS) {
			if(!g_Achievement[id][BALAS_INFINITAS]) {
				colorChat(id, _, "%sNecesitás desbloquear el logro !gPODER: BALAS INFINITAS!y antes de poder comprarlas.", TD_PREFIX);

				showMenu__Powers(id);
				return PLUGIN_HANDLED;
			}
		}
		
		g_Gold[id] -= POWER_NAMES[iItem][powerGold];
		
		++g_Power[id][iItem];
		
		colorChat(id, _, "%sCompraste !g%s!y.", TD_PREFIX, POWER_NAMES[iItem][powerName]);
	} else {
		colorChat(id, _, "%sLo siento, pero necesitás más oro para comprar !g%s!y.", TD_PREFIX, POWER_NAMES[iItem][powerName]);
	}
	
	showMenu__Powers(id);	
	return PLUGIN_HANDLED;
}

public showMenu__OthersShop(const id) {
	if(g_Wave >= MAX_WAVES) {
		colorChat(id, _, "%sNo podés comprar otros productos en este punto!", TD_PREFIX);
		
		showMenu__Shop(id);
		return;
	}
	
	new sWeapon[48];
	new iMenu;
	new i;
	
	iMenu = menu_create("Estas son otras de las cosas que tengo:", "menu__OthersShop");
	
	for(i = 0; i < sizeof(OTHERS_NAME); ++i) {
		switch(i) {
			case 0: {
				formatex(sWeapon, charsmax(sWeapon), "%s %s[%d Oro]", OTHERS_NAME[i][otherName], (g_Gold[id] >= OTHERS_NAME[i][otherGold]) ? "\y" : "\d", OTHERS_NAME[i][otherGold]);
				menu_additem(iMenu, sWeapon, "1");
				
				formatex(sWeapon, charsmax(sWeapon), "%sVender %d %s por %d Oro^n", (g_Sentry[id]) ? "\w" : "\d", g_Sentry[id], OTHERS_NAME[i][otherName], (OTHERS_NAME[i][otherGold]*g_Sentry[id]));
				menu_additem(iMenu, sWeapon, "2");
			}//  case 1: {
				// formatex(sWeapon, charsmax(sWeapon), "%s %s[%d Oro]", OTHERS_NAME[i][otherName], (g_Gold[id] >= OTHERS_NAME[i][otherGold]) ? "\y" : "\d", OTHERS_NAME[i][otherGold]);
				// menu_additem(iMenu, sWeapon, "3");
				
				// formatex(sWeapon, charsmax(sWeapon), "%sVender %d %s por %d Oro", (g_Robot[id]) ? "\w" : "\d", g_Robot[id], OTHERS_NAME[i][otherName], (OTHERS_NAME[i][otherGold]*g_Robot[id]));
				// menu_additem(iMenu, sWeapon, "4");
			// }
		}
	}
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__OthersShop(const id, const menuId, const item) {
	if(g_WaveInProgress) {
		colorChat(id, _, "%sNo puedo vender cosas mientras hay una oleada en marcha.", TD_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	if(g_Wave >= MAX_WAVES) {
		colorChat(id, _, "%sNo podés comprar otros productos en este punto!", TD_PREFIX);
		
		showMenu__Shop(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	new iRealItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	switch(iItem) {
		case 0: {
			iRealItem = 0;
			
			if(g_SentryCount == 5) {
				colorChat(id, _, "%sYa hay cinco torretas creadas en el mapa!", TD_PREFIX);
				
				showMenu__OthersShop(id);
				return PLUGIN_HANDLED;
			}
		} case 1: {
			if(g_Sentry[id]) {
				new iReward = g_Sentry[id] * OTHERS_NAME[0][otherGold];
				
				g_Sentry[id] = 0;
				g_Gold[id] += iReward;
				
				colorChat(id, _, "%sRecibiste !g%d Oro!y", TD_PREFIX, iReward);
			}
			
			showMenu__OthersShop(id);
			return PLUGIN_HANDLED;
		}//  case 2: {
			// iRealItem = 1;
			
			// colorChat(id, _, "%sLo siento, este producto está retenido en la aduana, vuelve en unos días e intentalo nuevamente!", TD_PREFIX);

			// if(g_Kiske[id]) {
				// ++g_Robot[id];
			// }

			// if(g_RobotCount == 3) {
				// colorChat(id, _, "%sYa hay tres robots creados en el mapa!", TD_PREFIX);
				
				// showMenu__OthersShop(id);
				// return PLUGIN_HANDLED;
			// }
			
			// showMenu__OthersShop(id);
			// return PLUGIN_HANDLED;
		// } case 3: {
			// if(g_Robot[id]) {
				// new iReward = g_Robot[id] * OTHERS_NAME[1][otherGold];
				
				// g_Robot[id] = 0;
				// g_Gold[id] += iReward;
				
				// colorChat(id, _, "%sRecibiste !g%d Oro!y", TD_PREFIX, iReward);
			// }
			
			// showMenu__OthersShop(id);
			// return PLUGIN_HANDLED;
		// }
	}
	
	if(g_Gold[id] >= OTHERS_NAME[iRealItem][otherGold]) {
		g_Gold[id] -= OTHERS_NAME[iRealItem][otherGold];
		
		++g_Sentry[id];
		
		colorChat(id, _, "%sCompraste !g%s!y.", TD_PREFIX, OTHERS_NAME[iRealItem][otherName]);
	} else {
		colorChat(id, _, "%sLo siento, pero necesitás más oro para comprar !g%s!y.", TD_PREFIX, OTHERS_NAME[iRealItem][otherName]);
	}
	
	showMenu__OthersShop(id);	
	return PLUGIN_HANDLED;
}

public showMenu__Others(const id) {
	new iMenu;	
	iMenu = menu_create("TORRETAS", "menu__Others");
	
	menu_additem(iMenu, "Construir torreta", "1");
	menu_additem(iMenu, "Información de torreta^n", "2");
	
	// menu_additem(iMenu, "Construir robot", "3");
	// menu_additem(iMenu, "Información de robot", "4");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__Others(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	switch(iItem) {
		case 1: {
			if(g_Sentry[id]) {
				sentryBuild(id);
			} else {
				colorChat(id, _, "%sNo tenés torretas para construir.", TD_PREFIX);
			}
			
			showMenu__Others(id);
		} case 2: {
			new iSentry = aimingAtSentry(id);
			if(iSentry) {
				showMenu__InfoSentry(id, iSentry);
			} else {
				colorChat(id, _, "%sNo estás apuntando a ninguna torreta.", TD_PREFIX);
				showMenu__Others(id);
			}
		}//  case 3: {
			// if(g_Robot[id]) {
				// buildRobot(id);
			// } else {
				// colorChat(id, _, "%sNo tenés ningún robot para construir.", TD_PREFIX);
			// }
			
			// showMenu__Others(id);
		// } case 4: {
			// new iRobot = aimingAtRobot(id);
			// if(iRobot) {
				// showMenu__InfoRobot(id, iRobot);
			// } else {
				// colorChat(id, _, "%sNo estás apuntando a ningún robot.", TD_PREFIX);
				// showMenu__Others(id);
			// }
		// }
	}
	
	return PLUGIN_HANDLED;
}

// public showMenu__InfoRobot(const id, const robot) {
	// if(!is_user_connected(id)) {
		// return;
	// }

	// new sMenu[400];
	// formatex(sMenu, charsmax(sMenu), "\yROBOT^n^n\wEn construcción^n^n\r0.\w Volver");

	// set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	// show_menu(id, KEYSMENU, sMenu, -1, "Info Robot");
// }

// public menu__InfoRobot(const id, const key) {
	// switch(key) {
		// case 9: {
			// showMenu__Others(id);
		// }
	// }

	// return PLUGIN_HANDLED;
// }

public showMenu__InfoSentry(const id, const sentry) {
	if(!is_user_connected(id)) {
		return;
	}
	
	new sMenu[400];
	new iMaxClip;
	new iRatio;
	new iMinDamage;
	new iMaxDamage;
	new sItemOwner[50];
	new sItemOptionsForOwners[50];
	new iOwner;
	new iSentryLevel;
	
	iSentryLevel = entity_get_int(sentry, SENTRY_INT_LEVEL);
	g_Menu_Sentry[id] = sentry;
	iMaxClip = floatround(entity_get_float(sentry, SENTRY_MAXCLIP));
	iRatio = floatround(((SENTRIES_HIT_RATIO[iSentryLevel] * 100.0) + entity_get_float(sentry, SENTRY_EXTRA_RATIO)));
	iMinDamage = SENTRIES_DAMAGE[iSentryLevel][sentryMinDamage] + ((SENTRIES_DAMAGE[iSentryLevel][sentryMinDamage] * floatround(entity_get_float(sentry, SENTRY_EXTRA_DAMAGE))) / 100);
	iMaxDamage = SENTRIES_DAMAGE[iSentryLevel][sentryMaxDamage] + ((SENTRIES_DAMAGE[iSentryLevel][sentryMaxDamage] * floatround(entity_get_float(sentry, SENTRY_EXTRA_DAMAGE))) / 100);
	iOwner = entity_get_int(sentry, SENTRY_OWNER);
	sItemOwner[0] = EOS;
	sItemOptionsForOwners[0] = EOS;
	
	if(!iOwner) {
		formatex(sItemOwner, 49, "^n^n\r3.\w ADUEÑARSE DE ESTA TORRETA %s[100 Oro]", (g_Gold[id] >= 100) ? "\y" : "\d");
	} else if(id == iOwner) {
		formatex(sItemOptionsForOwners, charsmax(sItemOptionsForOwners), "^n^n\r4.\w MOVER TORRETA^n\r5.\w TRANSFERIR DUEÑO");
	}
	
	if(iMaxClip != 1000000) {
		formatex(sMenu, charsmax(sMenu), "\yTORRETA^n^n\wDUEÑO\r: \y%s^n\wNIVEL\r: \y%d^n\wPRECISIÓN\r: \y%d%%^n\wDAÑO POR BALA\r: \y%d \ra \y%d^n\wBALAS\r: \y%d \w/ \y%d^n^n\r1.\w SUBIR A \yNIVEL %d %s[%d Oro]^n\r2.\w RECARGAR BALAS [10 Oro]%s%s^n^n\r0.\w VOLVER",
		g_UserName[iOwner], iSentryLevel, iRatio, iMinDamage, iMaxDamage, entity_get_int(sentry, SENTRY_CLIP), iMaxClip, (iSentryLevel + 1),
		(g_Gold[id] < SENTRIES_UPGRADE_COST[iSentryLevel - 1]) ? "\d" : "", SENTRIES_UPGRADE_COST[iSentryLevel - 1], sItemOwner, sItemOptionsForOwners);
	} else {
		formatex(sMenu, charsmax(sMenu), "\yTORRETA^n^n\wDUEÑO\r: \y%s^n\wNIVEL\r: \y%d^n\wPRECISIÓN\r: \y%d%%^n\wDAÑO POR BALA\r: \y%d \ra \y%d^n^n\r1.\w SUBIR A \yNIVEL %d %s[%d Oro]%s%s^n^n\r0.\w VOLVER",
		g_UserName[iOwner], iSentryLevel, iRatio, iMinDamage, iMaxDamage, (iSentryLevel + 1), (g_Gold[id] < SENTRIES_UPGRADE_COST[iSentryLevel - 1]) ? "\d" : "",
		SENTRIES_UPGRADE_COST[iSentryLevel - 1], sItemOwner, sItemOptionsForOwners);
	}
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "Info Sentry");
}

public menu__InfoSentry(const id, const key) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	if(!is_valid_ent(g_Menu_Sentry[id])) {
		return PLUGIN_HANDLED;
	}
	
	switch(key) {
		case 0: { // MEJORAR TORRETA
			new iSentryLevel;
			iSentryLevel = entity_get_int(g_Menu_Sentry[id], SENTRY_INT_LEVEL);
			
			if(iSentryLevel < 6) {
				new iSentryLevelPlus1 = iSentryLevel + 1;
				
				if(g_Gold[id] >= SENTRIES_UPGRADE_COST[iSentryLevel - 1]) {
					if(iSentryLevel == 3 && (g_ClassId[id] != CLASS_INGENIERO || g_ClassLevel[id][g_ClassId[id]] < 5)) {
						colorChat(id, _, "%sSolo los INGENIEROS !gnivel 5!y pueden subir a !gnivel %d!y las torretas.", TD_PREFIX, iSentryLevelPlus1);
						
						showMenu__InfoSentry(id, g_Menu_Sentry[id]);
						return PLUGIN_HANDLED;
					} else if(iSentryLevel == 4 && (g_ClassId[id] != CLASS_INGENIERO || g_ClassLevel[id][g_ClassId[id]] < 6)) {
						colorChat(id, _, "%sSolo los INGENIEROS !gnivel 6!y pueden subir a !gnivel %d!y las torretas.", TD_PREFIX, iSentryLevelPlus1);
						
						showMenu__InfoSentry(id, g_Menu_Sentry[id]);
						return PLUGIN_HANDLED;
					} else if(iSentryLevel == 5) {
						new iOk = 1;

						if(g_ClassId[id] == CLASS_INGENIERO) {
							if(g_ClassLevel[id][CLASS_INGENIERO] < 6) {
								colorChat(id, _, "%sSolo los INGENIEROS !gnivel 6!y pueden subir a !gnivel %d!y las torretas.", TD_PREFIX, iSentryLevelPlus1);
								iOk = 0;
							}
						} else if(g_ClassId[id] == CLASS_FRANCOTIRADOR) {
							if(g_ClassLevel[id][CLASS_FRANCOTIRADOR] < 6) {
								colorChat(id, _, "%sSolo los FRANCOTIRADORES !gnivel 6!y pueden subir a !gnivel %d!y las torretas.", TD_PREFIX, iSentryLevelPlus1);
								iOk = 0;
							}
						} else {
							colorChat(id, _, "%sSolo los INGENIEROS !gnivel 6!y y FRANCOTIRADORES !gnivel 6!y pueden subir a !gnivel %d!y las torretas.", TD_PREFIX, iSentryLevelPlus1);
							iOk = 0;
						}

						if(iOk) {
							new iLv6Part = entity_get_int(g_Menu_Sentry[id], EV_INT_flTimeStepSound);
							iOk = 0;

							switch(iLv6Part) {
								case 0: {
									entity_set_int(g_Menu_Sentry[id], EV_INT_flTimeStepSound, g_ClassId[id]);

									if(g_ClassId[id] == CLASS_INGENIERO) {
										g_Gold[id] -= SENTRIES_UPGRADE_COST[iSentryLevel - 1];
										colorChat(id, _, "%sBien, ahora solo falta la parte del francotirador.", TD_PREFIX);
									} else {
										g_Gold[id] -= SENTRIES_UPGRADE_COST[iSentryLevel - 1];
										colorChat(id, _, "%sBien, ahora solo falta la parte del ingeniero.", TD_PREFIX);
									}
								} case CLASS_INGENIERO: {
									if(g_ClassId[id] != CLASS_FRANCOTIRADOR) {
										colorChat(id, _, "%sLa torreta ya fue subida por un ingeniero, falta la parte del francotirador.", TD_PREFIX);
									} else {
										new entBase;
										entBase = entity_get_edict(g_Menu_Sentry[id], SENTRY_ENT_BASE);

										register_think(ENT_SENTRY_BASE_CLASSNAME, "think__SentryLASER");
										entity_set_float(entBase, EV_FL_nextthink, get_gametime() + 60.0);

										entity_set_int(g_Menu_Sentry[id], EV_INT_flTimeStepSound, 1337);
										iOk = 1;
									}
								} case CLASS_FRANCOTIRADOR: {
									if(g_ClassId[id] != CLASS_INGENIERO) {
										colorChat(id, _, "%sLa torreta ya fue subida por un francotirador, falta la parte del ingeniero.", TD_PREFIX);
									} else {
										new entBase;
										entBase = entity_get_edict(g_Menu_Sentry[id], SENTRY_ENT_BASE);

										register_think(ENT_SENTRY_BASE_CLASSNAME, "think__SentryLASER");
										entity_set_float(entBase, EV_FL_nextthink, get_gametime() + 60.0);

										entity_set_int(g_Menu_Sentry[id], EV_INT_flTimeStepSound, 1337);
										iOk = 1;
									}
								}
							}
						}

						if(!iOk) {
							showMenu__InfoSentry(id, g_Menu_Sentry[id]);
							return PLUGIN_HANDLED;
						}
					}
					
					g_Gold[id] -= SENTRIES_UPGRADE_COST[iSentryLevel - 1];
					entity_set_model(g_Menu_Sentry[id], MODEL_SENTRY_LEVEL[iSentryLevel]);
					
					if(iSentryLevel == 3) {
						entity_set_int(g_Menu_Sentry[id], EV_INT_flTimeStepSound, 0);
						
						new entBase;
						entBase = entity_get_edict(g_Menu_Sentry[id], SENTRY_ENT_BASE);

						entity_set_model(entBase, MODEL_SENTRY_BASE_LV4_LV6);

						/*entity_set_int(entBase, EV_INT_rendermode, kRenderTransAlpha);
						entity_set_float(entBase, EV_FL_renderamt, 0.0);

						new Float:vecOrigin[3];
						entity_get_vector(g_Menu_Sentry[id], EV_VEC_origin, vecOrigin);
						
						vecOrigin[2] -= 16.0;
						
						entity_set_vector(g_Menu_Sentry[id], EV_VEC_origin, vecOrigin);
						
						//entity_set_byte(g_Menu_Sentry[id], SENTRY_TILT_LV4, 127);*/
					}
					
					entity_set_float(g_Menu_Sentry[id], SENTRY_EXTRA_DAMAGE, CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Damage]);
					entity_set_float(g_Menu_Sentry[id], SENTRY_EXTRA_RATIO, CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Recoil]);
					
					new Float:vecMins[3];
					new Float:vecMaxs[3];
					
					vecMins[0] = -16.0;
					vecMins[1] = -16.0;
					vecMins[2] = 0.0;
					
					vecMaxs[0] = 16.0;
					vecMaxs[1] = 16.0;
					vecMaxs[2] = 48.0;
					
					entity_set_size(g_Menu_Sentry[id], vecMins, vecMaxs);
					
					emit_sound(g_Menu_Sentry[id], CHAN_AUTO, SOUND_SENTRY_HEAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
					
					entity_set_int(g_Menu_Sentry[id], SENTRY_INT_LEVEL, iSentryLevelPlus1);
					
					colorChat(id, _, "%sHas subido la torreta seleccionada al !gnivel %d!y.", TD_PREFIX, iSentryLevelPlus1);
					
					if(g_Difficulty == DIFF_NORMAL) {
						entity_set_float(g_Menu_Sentry[id], SENTRY_MAXCLIP, 1000000.0);
					} else {
						entity_set_float(g_Menu_Sentry[id], SENTRY_MAXCLIP, entity_get_float(g_Menu_Sentry[id], SENTRY_MAXCLIP) + float(SENTRIES_MAXCLIP[iSentryLevelPlus1]));
					}
				} else {
					colorChat(id, _, "%sNo tenés oro suficiente para mejorar la torreta.", TD_PREFIX);
				}
			} else {
				colorChat(id, _, "%sLa torreta seleccionada está en su nivel máximo.", TD_PREFIX);
			}
		} case 1: { // RECARGAR BALAS
			if(g_Difficulty != DIFF_NORMAL) {
				if(g_Gold[id] >= 10) {
					if(entity_get_int(g_Menu_Sentry[id], SENTRY_CLIP) != floatround(entity_get_float(g_Menu_Sentry[id], SENTRY_MAXCLIP))) {
						colorChat(id, _, "%sLas balas de esta torreta han sido recargadas.", TD_PREFIX);
						
						g_Gold[id] -= 10;
						
						if(!entity_get_int(g_Menu_Sentry[id], SENTRY_CLIP)) {
							entity_set_float(g_Menu_Sentry[id], SENTRY_PARAM_01, 0.0);
							
							fm_set_rendering(g_Menu_Sentry[id]);
							
							entity_set_float(g_Menu_Sentry[id], EV_FL_nextthink, get_gametime() + 0.01);
						}
						
						entity_set_int(g_Menu_Sentry[id], SENTRY_CLIP, floatround(entity_get_float(g_Menu_Sentry[id], SENTRY_MAXCLIP)));

						new entBase = entity_get_edict(g_Menu_Sentry[id], SENTRY_ENT_BASE);
						entity_set_int(entBase, SENTRY_CLIP, floatround(entity_get_float(g_Menu_Sentry[id], SENTRY_MAXCLIP)));
					} else {
						colorChat(id, _, "%sLa torreta está cargada al máximo!", TD_PREFIX);
					}
				} else {
					colorChat(id, _, "%sNo tenés oro suficiente para recargar las balas de la torreta.", TD_PREFIX);
				}
				
				return PLUGIN_HANDLED;
			}
		} case 2: { // ADUEÑARSE DE LA TORRETA
			if(!entity_get_int(g_Menu_Sentry[id], SENTRY_OWNER)) {
				if(g_Gold[id] >= 100) {
					colorChat(id, _, "%sTe has adueñado de esta torreta.", TD_PREFIX);
					
					g_Gold[id] -= 100;
					
					entity_set_int(g_Menu_Sentry[id], SENTRY_OWNER, id);

					new entBase = entity_get_edict(g_Menu_Sentry[id], SENTRY_ENT_BASE);
					entity_set_int(entBase, SENTRY_OWNER, id);
					
					entity_set_float(g_Menu_Sentry[id], SENTRY_PARAM_01, 0.0);
					
					fm_set_rendering(g_Menu_Sentry[id]);
					
					entity_set_float(g_Menu_Sentry[id], EV_FL_nextthink, get_gametime() + 0.01);

					new iSentryLevel;
					iSentryLevel = entity_get_int(g_Menu_Sentry[id], SENTRY_INT_LEVEL);

					if(iSentryLevel >= 6) {
						new entBase;
						entBase = entity_get_edict(g_Menu_Sentry[id], SENTRY_ENT_BASE);

						entity_set_float(entBase, EV_FL_nextthink, get_gametime() + 60.0);
					}
				} else {
					colorChat(id, _, "%sNo tenés oro suficiente para adueñarte de esta torreta.", TD_PREFIX);
				}
				
				return PLUGIN_HANDLED;
			}
		} case 3: { // MOVER TORRETA
			new iOwner = entity_get_int(g_Menu_Sentry[id], SENTRY_OWNER);

			if(iOwner == id) {
				if(!g_WaveInProgress) {
					showMenu__MoveTurret(id);
					return PLUGIN_HANDLED;
				} else {
					colorChat(id, _, "%sNo podés utilizar esta opción cuando hay una oleada en marcha.", TD_PREFIX);
				}
			}
		} case 4: { // TRANSFERIR DUEÑO
			new iOwner = entity_get_int(g_Menu_Sentry[id], SENTRY_OWNER);

			if(iOwner == id) {
				g_Sentry_TransferMenu[id] = 0;

				showMenu__TransferTurretOwner(id);
				return PLUGIN_HANDLED;
			}
		} case 9: { // ATRÁS
			showMenu__Others(id);
			return PLUGIN_HANDLED;
		}
	}
	
	showMenu__InfoSentry(id, g_Menu_Sentry[id]);
	return PLUGIN_HANDLED;
}

public sentryBuild(const id) {
	if(!is_user_alive(id)) {
		return;
	}
	
	if(g_SentryCount == 5) {
		colorChat(id, _, "%sHay demasiadas torretas creadas.", TD_PREFIX);
		return;
	} else if(g_InBuilding[id]) {
		colorChat(id, _, "%sNo podés crear una torreta mientras estás construyendo otra cosa.", TD_PREFIX);
		return;
	} else if(!(entity_get_int(id, EV_INT_flags) & (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT))) { 
		colorChat(id, _, "%sTenés que estar en el suelo para construir una torreta.", TD_PREFIX);
		return;
	} else if(entity_get_int(id, EV_INT_bInDuck)) {
		colorChat(id, _, "%sNo podes agacharte mientras construyes una torreta.", TD_PREFIX);
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
		++g_SentryCount;
	} else {
		colorChat(id, _, "%sNo podes construir una torreta acá.", TD_PREFIX);
	}
}

public createSentryBase(const Float:vecOrigin[3], const id) {
	if(point_contents(vecOrigin) != CONTENTS_EMPTY || traceCheckCollides(vecOrigin, 24.0)) {
		return 0;
	}
	
	new Float:vecHitPoint[3];
	new Float:vecOriginDown[3];
	new Float:fDistanceFromGround;
	new Float:fDifference;
	
	vecOriginDown = vecOrigin;
	vecOriginDown[2] = -5000.0;
	
	trace_line(0, vecOrigin, vecOriginDown, vecHitPoint);
	
	fDistanceFromGround = vector_distance(vecOrigin, vecHitPoint);
	fDifference = 36.0 - fDistanceFromGround;
	
	if((fDifference <  -20.0) || (fDifference > 20.0)) {
		return 0;
	}
	
	new iEnt = create_entity("func_wall");
	
	if(!iEnt) {
		return 0;
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
	
	entity_set_string(iEnt, EV_SZ_classname, ENT_SENTRY_BASE_CLASSNAME);
	entity_set_model(iEnt, MODEL_SENTRY_BASE);
	
	entity_set_size(iEnt, vecMins, vecMaxs);
	entity_set_origin(iEnt, vecOrigin);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
	
	new iArgs[2];
	iArgs[0] = iEnt;
	iArgs[1] = id;
	
	g_SentryOrigin[id] = vecOrigin;
	g_InBuilding[id] = 1;
	
	emit_sound(id, CHAN_AUTO, SOUND_SENTRY_BASE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	set_task(2.0, "createSentryHead", _, iArgs, 2);
	
	return 1;
}

public createSentryHead(const iArgs[2]) {
	new iEntBase = iArgs[0];
	new id = iArgs[1];
	
	if(!is_user_connected(id)) {
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		--g_SentryCount;
		
		return;
	}
	
	if(!is_valid_ent(iEntBase)) {
		g_InBuilding[id] = 0;
		
		--g_SentryCount;
		
		return;
	}
	
	if(!g_InBuilding[id]) {
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		--g_SentryCount;
		
		return;
	}

	new iEnt = create_entity("func_wall");
	
	if(!iEnt) {
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		--g_SentryCount;
		
		return;
	}

	new Float:vecOrigin[3];
	vecOrigin = g_SentryOrigin[id];

	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
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
	
	entity_set_string(iEnt, EV_SZ_classname, ENT_SENTRY_CLASSNAME);
	entity_set_model(iEnt, MODEL_SENTRY_LEVEL[0]);
	
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

	emit_sound(iEnt, CHAN_AUTO, SOUND_SENTRY_HEAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	entity_set_float(iEnt, SENTRY_PARAM_01, 0.0);
	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.5);
	
	if(g_Difficulty == DIFF_NORMAL) {
		entity_set_int(iEnt, SENTRY_CLIP, 1000000);
		entity_set_int(iEntBase, SENTRY_CLIP, 1000000);

		entity_set_float(iEnt, SENTRY_MAXCLIP, 1000000.0);
	} else {
		entity_set_int(iEnt, SENTRY_CLIP, SENTRIES_MAXCLIP[1] + CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Clip]);
		entity_set_int(iEntBase, SENTRY_CLIP, SENTRIES_MAXCLIP[1] + CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Clip]);

		entity_set_float(iEnt, SENTRY_MAXCLIP, float(SENTRIES_MAXCLIP[1]) + CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Clip]);
	}
	
	entity_set_float(iEnt, SENTRY_EXTRA_DAMAGE, CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Damage]);
	entity_set_float(iEnt, SENTRY_EXTRA_RATIO, CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Recoil]);

	entity_get_vector(iEntBase, EV_VEC_origin, g_SentryOrigin[id]);

	new iParams[4];
	
	iParams[0] = iEntBase;
	iParams[1] = iEnt;
	iParams[2] = id;
	iParams[3] = floatround(g_SentryOrigin[id][2]);
	
	set_task(2.0, "checkSentryStuck", _, iParams, 4);
	
	g_InBuilding[id] = 0;
	
	entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
	entity_set_float(iEnt, EV_FL_animtime, 1.0);
	entity_set_float(iEnt, EV_FL_framerate, 1.0);
}

public checkSentryStuck(const iParams[4]) {
	if(!is_valid_ent(iParams[0])) {
		return;
	}
	
	new Float:vecOrigin[3];
	new iDifference;
	
	entity_get_vector(iParams[0], EV_VEC_origin, vecOrigin);
	iDifference = abs(floatround(vecOrigin[2]) - iParams[3]);
	
	if(iDifference > 2) {
		remove_entity(iParams[0]);

		if(is_valid_ent(iParams[1])) {
			remove_entity(iParams[1]);
		}

		if(is_user_connected(iParams[2])) {
			colorChat(iParams[2], _, "%sLa torreta que acabas de construir se bloqueó con alguna pared invisible, se ha devuelto a tu inventario!", TD_PREFIX);
			
			++g_Sentry[iParams[2]];
			--g_SentryCount;
		}
	} else {
		entity_set_int(iParams[0], SENTRY_LOW_FPS, 2);
		entity_set_int(iParams[1], SENTRY_LOW_FPS, 2);
	}
}

public think__Sentry(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, SENTRY_OWNER)) {
		return;
	}
	
	static iClip;
	iClip = entity_get_int(iEnt, SENTRY_CLIP);
	
	if(!iClip) {
		entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
		entity_set_float(iEnt, EV_FL_animtime, 1.0);
		entity_set_float(iEnt, EV_FL_framerate, 1.0);
		
		fm_set_rendering(iEnt, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 3);
		
		return;
	}
	
	if(entity_get_float(iEnt, SENTRY_PARAM_01)) {
		entity_set_float(iEnt, SENTRY_PARAM_01, 0.0);
		
		entity_set_int(iEnt, EV_INT_sequence, sentryAnimFire);
		entity_set_float(iEnt, EV_FL_animtime, 1.0);
		entity_set_float(iEnt, EV_FL_framerate, 2.0);
	}
	
	static Float:vecSentryOrigin[3];
	static Float:fDistance;
	static iTarget;
	static iSentryLevel;
	
	entity_get_vector(iEnt, EV_VEC_origin, vecSentryOrigin);
	vecSentryOrigin[2] += 20.0;
	
	iTarget = entity_get_edict(iEnt, SENTRY_ENT_TARGET);
	iSentryLevel = entity_get_int(iEnt, SENTRY_INT_LEVEL);
	
	if(entity_get_int(iEnt, SENTRY_INT_FIRE) == 1 && isMonster(iTarget)) {
		static Float:vecTargetOrigin[3];
		entity_get_vector(iTarget, EV_VEC_origin, vecTargetOrigin);
		
		fDistance = vector_distance(vecSentryOrigin, vecTargetOrigin);
		
		if(fDistance <= 800.0) {
			sentryTurnToTarget(iEnt, vecSentryOrigin, iTarget, vecTargetOrigin);
			
			if(iSentryLevel < 4) {
				emit_sound(iEnt, CHAN_WEAPON, SOUND_SENTRY_FIRE, 0.2, ATTN_NORM, 0, PITCH_NORM);
			} else {
				emit_sound(iEnt, CHAN_WEAPON, SOUND_SENTRY_FIRE_LV56[random_num(0, 2)], 0.3, ATTN_NORM, 0, PITCH_NORM);
			}
			
			static iHitRatio;
			iHitRatio = floatround((SENTRIES_HIT_RATIO[iSentryLevel] * 100.0) + entity_get_float(iEnt, SENTRY_EXTRA_RATIO));		

			if(random_num(1, 100) <= iHitRatio) {
				sentryDamageToPlayer(iEnt, iTarget, iSentryLevel);
			}
			
			entity_set_int(iEnt, SENTRY_CLIP, iClip - 1);

			static entBase;
			entBase = entity_get_edict(iEnt, SENTRY_ENT_BASE);

			entity_set_int(entBase, SENTRY_CLIP, iClip - 1);
			
			vecTargetOrigin[2] += random_num(-16, 16);

			effectBlood(vecTargetOrigin);
			effectTracer(vecSentryOrigin, vecTargetOrigin);
			
			entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
			return;
		} else {
			entity_set_int(iEnt, SENTRY_INT_FIRE, 0);
			
			entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
			entity_set_float(iEnt, EV_FL_animtime, 1.0);
			entity_set_float(iEnt, EV_FL_framerate, 1.0);
		}
	}
	
	static iVictim;
	static iClosest;
	static Float:fClosestDistance;
	static Float:vecClosestOrigin[3];
	static Float:vecOrigin[3];

	iVictim = -1;
	iClosest = 0;
	
	while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecSentryOrigin, 800.0)) != 0) {
		if(!isMonster(iVictim)) {
			continue;
		}
		
		entity_get_vector(iVictim, EV_VEC_origin, vecOrigin);
		
		vecOrigin[2] += 10.0;
		
		fDistance = vector_distance(vecSentryOrigin, vecOrigin);
		vecClosestOrigin = vecOrigin;
		
		if(fDistance < fClosestDistance || iClosest == 0) {
			iClosest = iVictim;
			fClosestDistance = fDistance;
		}
	}
	
	if(iClosest) {
		emit_sound(iEnt, CHAN_AUTO, SOUND_SENTRY_FOUND, 0.4, ATTN_NORM, 0, PITCH_NORM);
		sentryTurnToTarget(iEnt, vecSentryOrigin, iClosest, vecClosestOrigin);
		
		entity_set_int(iEnt, SENTRY_INT_FIRE, 1);
		entity_set_edict(iEnt, SENTRY_ENT_TARGET, iClosest);
		
		entity_set_byte(iEnt, SENTRY_TILT_RADAR, 127);
		
		static iArgs[4];
		static iSentryOrigin[3];
		
		FVecIVec(vecSentryOrigin, iSentryOrigin);
		
		iArgs[0] = iSentryOrigin[0];
		iArgs[1] = iSentryOrigin[1];
		iArgs[2] = iSentryOrigin[2];
		iArgs[3] = iClosest;
		
		set_task(0.1, "sentryAimToTarget", TASK_SENTRY_THINK + iEnt, iArgs, 4, "a", 4);
		
		entity_set_float(iEnt, SENTRY_PARAM_01, 1.0);
	} else {
		entity_set_int(iEnt, SENTRY_INT_FIRE, 0);
		
		entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
		entity_set_float(iEnt, EV_FL_animtime, 1.0);
		entity_set_float(iEnt, EV_FL_framerate, 1.0);
	}
	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + SENTRIES_THINK[iSentryLevel]);
}

public sentryAimToTarget(const iArgs[4], const taskid) {
	if(!is_valid_ent(ID_SENTRY_THINK)) {
		return;
	}
	
	if(!entity_get_int(ID_SENTRY_THINK, SENTRY_INT_FIRE)) {
		return;
	}
	
	new iMonster = iArgs[3];
	
	if(!is_valid_ent(iMonster)) {
		return;
	}
	
	new Float:vecSentryOrigin[3];
	new Float:vecClosestOrigin[3];
	
	vecSentryOrigin[0] = float(iArgs[0]);
	vecSentryOrigin[1] = float(iArgs[1]);
	vecSentryOrigin[2] = float(iArgs[2]);
	
	entity_get_vector(iMonster, EV_VEC_origin, vecClosestOrigin);
	
	sentryTurnToTarget(ID_SENTRY_THINK, vecSentryOrigin, iMonster, vecClosestOrigin);
}

sentryTurnToTarget(const ent, const Float:sentryOrigin[3], const iTarget, Float:vecTargetOrigin[3]) {
	if(iTarget) {
		entitySetAim(ent, sentryOrigin, vecTargetOrigin);

		/*new Float:vecNewAngle[3];
		new Float:fRadians;
		new Float:fDegress;
		new Float:fDegressByte;
		new Float:fTilt;
		new Float:x;
		new Float:y;
		new Float:h;
		new Float:b;
		
		entity_get_vector(ent, EV_VEC_angles, vecNewAngle);
		
		x = vecClosestOrigin[0] - sentryOrigin[0];
		y = vecClosestOrigin[1] - sentryOrigin[1];
		fRadians = floatatan(y/x, radian);
		
		vecNewAngle[1] = fRadians * THE_MAGIC;
		
		if(vecClosestOrigin[0] < sentryOrigin[0]) {
			vecNewAngle[1] -= 180.0;
		}
		
		h = vecClosestOrigin[2] - sentryOrigin[2];
		b = vector_distance(sentryOrigin, vecClosestOrigin);
		
		fRadians = floatatan(h/b, radian);
		fDegress = fRadians * THE_MAGIC;
		
		fDegressByte = 3.2421875;
		fTilt = 127.0 - (fDegressByte * fDegress);
		
		entity_set_byte(ent, SENTRY_TILT_TURRET, floatround(fTilt));
		entity_set_vector(ent, EV_VEC_angles, vecNewAngle);*/
	}
}

sentryDamageToPlayer(const sentry, const iTarget, const sentryLevel) {
	static iDamage;
	static iMinDamage;
	static iMaxDamage;
	
	iMinDamage = SENTRIES_DAMAGE[sentryLevel][sentryMinDamage] + ((SENTRIES_DAMAGE[sentryLevel][sentryMinDamage] * floatround(entity_get_float(sentry, SENTRY_EXTRA_DAMAGE))) / 100);
	iMaxDamage = SENTRIES_DAMAGE[sentryLevel][sentryMaxDamage] + ((SENTRIES_DAMAGE[sentryLevel][sentryMaxDamage] * floatround(entity_get_float(sentry, SENTRY_EXTRA_DAMAGE))) / 100);
	
	iDamage = random_num(iMinDamage, iMaxDamage);
	
	static Float:fShield;
	static iOwner;
	
	fShield = entity_get_float(iTarget, MONSTER_SHIELD);
	iOwner = entity_get_int(sentry, SENTRY_OWNER);
	
	if(fShield == 1.0) {
		iDamage /= 2;
	} else if(fShield == 2.0) {
		iDamage *= 2;
	}
	
	static Float:fNewHealth;
	fNewHealth = entity_get_float(iTarget, EV_FL_health) - float(iDamage);
	
	if(is_user_connected(iOwner)) {
		if(!isSpecialMonster(iTarget)) {
			if(g_ClassId[iOwner] == CLASS_INGENIERO) {
				g_ClassReqs[iOwner][CLASS_INGENIERO] += iDamage;
				
				g_SentryDamage[iOwner] += iDamage;
				
				while(g_SentryDamage[iOwner] >= 300) {
					++g_Gold[iOwner];
					++g_GoldG[iOwner];
					
					g_SentryDamage[iOwner] -= 300;
				}
			}
		} else {
			if(g_GordoHealth) {
				g_GordoHealth -= iDamage;
			}
		}
	}

	if(fNewHealth <= 0.0) {
		removeMonster(iTarget, iOwner, .rayo = 1);
	} else {
		entity_set_float(iTarget, EV_FL_health, fNewHealth);
	}
}

public traceCheckCollides(const Float:vecOrigin[3], const Float:fBounds) {
	new Float:vecTraceEnds[8][3];
	new Float:vecTraceHit[3];
	new iHitEnt;
	new i;
	new j;
	
	vecTraceEnds[0][0] = vecOrigin[0] - fBounds;
	vecTraceEnds[0][1] = vecOrigin[1] - fBounds;
	vecTraceEnds[0][2] = vecOrigin[2] - fBounds;
	
	vecTraceEnds[1][0] = vecOrigin[0] - fBounds;
	vecTraceEnds[1][1] = vecOrigin[1] - fBounds;
	vecTraceEnds[1][2] = vecOrigin[2] + fBounds;
	
	vecTraceEnds[2][0] = vecOrigin[0] + fBounds;
	vecTraceEnds[2][1] = vecOrigin[1] - fBounds;
	vecTraceEnds[2][2] = vecOrigin[2] + fBounds;
	
	vecTraceEnds[3][0] = vecOrigin[0] + fBounds;
	vecTraceEnds[3][1] = vecOrigin[1] - fBounds;
	vecTraceEnds[3][2] = vecOrigin[2] - fBounds;
	
	vecTraceEnds[4][0] = vecOrigin[0] - fBounds;
	vecTraceEnds[4][1] = vecOrigin[1] + fBounds;
	vecTraceEnds[4][2] = vecOrigin[2] - fBounds;
	
	vecTraceEnds[5][0] = vecOrigin[0] - fBounds;
	vecTraceEnds[5][1] = vecOrigin[1] + fBounds;
	vecTraceEnds[5][2] = vecOrigin[2] + fBounds;
	
	vecTraceEnds[6][0] = vecOrigin[0] + fBounds;
	vecTraceEnds[6][1] = vecOrigin[1] + fBounds;
	vecTraceEnds[6][2] = vecOrigin[2] + fBounds;
	
	vecTraceEnds[7][0] = vecOrigin[0] + fBounds;
	vecTraceEnds[7][1] = vecOrigin[1] + fBounds;
	vecTraceEnds[7][2] = vecOrigin[2] - fBounds;
	
	for(i = 0; i < 8; ++i) {
		if(point_contents(vecTraceEnds[i]) != CONTENTS_EMPTY)
			return 1;
		
		iHitEnt = trace_line(0, vecOrigin, vecTraceEnds[i], vecTraceHit);
		if(iHitEnt != 0)
			return 1;
		
		for(j = 0; j < 3; ++j) {
			if(vecTraceEnds[i][j] != vecTraceHit[j])
				return 1;
		}
	}

	return 0;
}

aimingAtSentry(const id) {
	new iTarget;
	new iBody;
	
	if(get_user_aiming(id, iTarget, iBody) == 0.0)
		return 0;
	
	if(iTarget) {
		if(isSentry(iTarget)) {
			return iTarget;
		}
		
		return 0;
	}

	return 0;
}

// aimingAtRobot(const id) {
	// new iTarget;
	// new iBody;
	
	// if(get_user_aiming(id, iTarget, iBody) == 0.0)
		// return 0;
	
	// if(iTarget) {
		// if(isRobot(iTarget)) {
			// return iTarget;
		// }
		
		// return 0;
	// }

	// return 0;
// }

// isRobot(const ent) {
	// if(!is_valid_ent(ent))
		// return 0;

	// new sClassName[32];
	// entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));

	// if(	sClassName[0] == 'e' &&
		// sClassName[1] == 'n' &&
		// sClassName[2] == 't' &&
		// sClassName[3] == 'R' &&
		// sClassName[4] == 'o' &&
		// sClassName[5] == 'b' &&
		// sClassName[6] == 'o' &&
		// sClassName[7] == 't' )
		// return 1;

	// return 0;
// }

isSentry(const ent) {
	if(!is_valid_ent(ent))
		return 0;
	
	new sClassName[32];
	entity_get_string(ent, EV_SZ_classname, sClassName, charsmax(sClassName));
	
	if(	sClassName[0] == 'e' &&
		sClassName[1] == 'n' &&
		sClassName[2] == 't' &&
		sClassName[3] == 'S' &&
		sClassName[4] == 'e' &&
		sClassName[5] == 'n' &&
		sClassName[6] == 't' &&
		sClassName[7] == 'r' &&
		sClassName[8] == 'y') 
		return 1;
		
	
	return 0;
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

stock getWeaponEntId(const ent) {
	if(pev_valid(ent) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

public followHuman(const iEnt, const Float:vecEntOrigin[3], const Float:vecVictimOrigin[3], const Float:fDistance, const Float:fVelocity) {
	static Float:vecVelocity[3];
	static Float:fTime;
	
	fTime = fDistance / fVelocity;
	
	vecVelocity[0] = (vecVictimOrigin[0] - vecEntOrigin[0]) / fTime;
	vecVelocity[1] = (vecVictimOrigin[1] - vecEntOrigin[1]) / fTime;
	vecVelocity[2] = 0.0;
	
	entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);
}

public searchHuman(const iEnt) {
	new iVictim = 0;
	new i;
	
	if(!g_Boss) {
		new Float:vecEntOrigin[3];
		new Float:vecOrigin[3];
		new Float:fDiff;
		new Float:fRange;
		new Float:fMaxRange = 8192.0;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(is_user_alive(i) && !g_InBlockZone[i]) {
				entity_get_vector(i, EV_VEC_origin, vecOrigin);
				
				fDiff = (vecEntOrigin[2] - vecOrigin[2]);
				
				if(fDiff < -64.0 || fDiff > 64.0)
					continue;
				
				fRange = entity_range(iEnt, i);
				
				if(fRange <= fMaxRange) {
					fMaxRange = fRange;
					iVictim = i;
				}
			}
		}
	} else {
		new iUsers[MAX_USERS];
		new iCount = -1;
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(is_user_alive(i)) {
				iUsers[++iCount] = i;
			}
		}
		
		iVictim = iUsers[random_num(0, iCount)];
	}
	
	return iVictim;
}

miniBoss__SearchHuman(const iEnt, ignoreThis=0) {
	static Float:fRange;
	static Float:fMaxRange;
	static iVictim;
	static i;
	
	fMaxRange = 8192.0;
	iVictim = 0;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(is_user_alive(i)) {
			if(i == ignoreThis) {
				continue;
			}

			fRange = entity_range(iEnt, i);
			
			if(fRange <= fMaxRange) {
				fMaxRange = fRange;
				iVictim = i;
			}
		}
	}
	
	return iVictim;
}

public miniBoss__SearchRandomHuman(const iEnt) {
	new iRandomUser = 0;
	new iUsers[MAX_USERS];
	new i;
	new j = 0;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(is_user_alive(i)) {
			iUsers[j] = i;
			++j;
		}
	}
	
	iRandomUser = random_num(0, (j - 1));
	
	return iUsers[iRandomUser];
}

public damageTower__Effect(sArgs[7], const taskid) {
	if(!is_valid_ent(ID_DAMAGE_TOWER)) {
		return;
	}
	
	if(!sArgs[6]) {
		new Float:vecOrigin[3];
		new iVecOrigin[3];
		new iVecEndOrigin[3];
		
		entity_get_vector(ID_DAMAGE_TOWER, EV_VEC_origin, vecOrigin);
		
		entity_set_float(ID_DAMAGE_TOWER, EV_FL_nextthink, get_gametime() + 9999.0);
		
		entitySetAim(ID_DAMAGE_TOWER, vecOrigin, g_VecEndOrigin[0], .iAngleMode=1);
		
		FVecIVec(vecOrigin, iVecOrigin);
		FVecIVec(g_VecEndOrigin[0], iVecEndOrigin);
		
		sArgs[0] = iVecOrigin[0];
		sArgs[1] = iVecOrigin[1];
		sArgs[2] = iVecOrigin[2];
		sArgs[3] = iVecEndOrigin[0];
		sArgs[4] = iVecEndOrigin[1];
		sArgs[5] = iVecEndOrigin[2] + random_num(100, 250);
		sArgs[6] = 1;
		
		entity_set_int(ID_DAMAGE_TOWER, EV_INT_sequence, 2);
		entity_set_float(ID_DAMAGE_TOWER, EV_FL_animtime, get_gametime());
		entity_set_float(ID_DAMAGE_TOWER, EV_FL_framerate, 1.0);
		
		entity_set_int(ID_DAMAGE_TOWER, EV_INT_gamestate, 1);
		
		new Float:vecMins[3];
		new Float:vecMax[3];
		
		vecMins = Float:{-16.0, -16.0, -18.0};
		vecMax = Float:{16.0, 16.0, 32.0};
		
		entity_set_size(ID_DAMAGE_TOWER, vecMins, vecMax);
		
		entity_set_vector(ID_DAMAGE_TOWER, EV_VEC_mins, vecMins);
		entity_set_vector(ID_DAMAGE_TOWER, EV_VEC_maxs, vecMax);
		
		drop_to_floor(ID_DAMAGE_TOWER);
		
		entity_set_vector(ID_DAMAGE_TOWER, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(ID_DAMAGE_TOWER, MONSTER_TARGET, 1337);
		
		set_hudmessage(255, 255, 0, -1.0, 0.26, 0, 0.0, 999.0, 0.0, 0.0, 4);
		ShowSyncHudMsg(0, g_HudDamageTower, "¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!^n¡LA TORRE ESTÁ SUFRIENDO DAÑO!");
		
		set_task(0.1, "damageTower__Effect", TASK_DAMAGE_TOWER + ID_DAMAGE_TOWER, sArgs, 7);
		
		return;
	}
	
	emit_sound(ID_DAMAGE_TOWER, CHAN_BODY, MONSTER_SOUNDS_LASER[random_num(0, charsmax(MONSTER_SOUNDS_LASER))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	write_coord(sArgs[0]);
	write_coord(sArgs[1]);
	write_coord(sArgs[2]);
	write_coord(sArgs[3]);
	write_coord(sArgs[4]);
	write_coord(sArgs[5]);
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
	
	set_task(1.0, "damageTower__Effect", TASK_DAMAGE_TOWER + ID_DAMAGE_TOWER, sArgs, 7);
}

public entFly(const iEnt) {
	if(is_valid_ent(iEnt)) {
		if(fm_get_speed(iEnt) < 5) {
			entity_set_string(iEnt, EV_SZ_classname, ENT_SPECIAL_MONSTER_CLASSNAME);
			
			new sModel[64];
			new Float:vecOrigin[3];
			new iHealth = random_num(25, 50) * g_Wave;
			
			if(DIFFICULTIES_VALUES[g_Difficulty][difficultyHealth]) {
				iHealth = iHealth + ((iHealth * DIFFICULTIES_VALUES[g_Difficulty][difficultyHealth]) / 100);
			}
			
			if(iHealth > g_MaxHealth) {
				iHealth = g_MaxHealth;
			}
			
			formatex(sModel, charsmax(sModel), "models/%s.mdl", MONSTER_MODELS_NORMAL[random_num(0, charsmax(MONSTER_MODELS_NORMAL))]);
			
			entity_set_model(iEnt, sModel);
			
			entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
			entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
			
			entity_set_float(iEnt, EV_FL_health, float(iHealth));
			entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_YES);
			
			entity_set_int(iEnt, MONSTER_MAXHEALTH, iHealth);
			
			entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
			vecOrigin[2] += 36.0;
			entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
			
			entity_set_int(iEnt, MONSTER_TYPE, EGG_MONSTER);
			
			new Float:vecMins[3];
			new Float:vecMax[3];
			
			vecMins = Float:{-16.0, -16.0, -30.0};
			vecMax = Float:{16.0, 16.0, 36.0};
			
			entity_set_size(iEnt, vecMins, vecMax);
			
			entity_set_vector(iEnt, EV_VEC_mins, vecMins);
			entity_set_vector(iEnt, EV_VEC_maxs, vecMax);
			
			entity_set_int(iEnt, EV_INT_sequence, 4);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 1.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			if(isStuck(iEnt)) {
				removeMonster(iEnt, 1337);
			} else {
				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
			}
		} else {
			set_task(0.25, "entFly", iEnt);
		}
	}
}

public __changeSolidState(const iEnt) {
	if(is_valid_ent(iEnt)) {
		entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	}
}

public __changeMoveType(const iEnt) {
	if(is_valid_ent(iEnt)) {
		entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
		
		if(g_BossId == BOSS_GUARDIANES && g_Boss == iEnt) {
			entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
		}
	}
}

public backToTrack(const monster) {
	if(is_valid_ent(monster) && entity_get_int(monster, MONSTER_MAXHEALTH)) {
		new sText[20];
		new Float:vecOrigin[3];
		new Float:vecMonsterOrigin[3];
		new iTarget;
		new iTrack;
		new Float:fVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		iTrack = entity_get_int(monster, MONSTER_TRACK);
		
		formatex(sText, charsmax(sText), "track%d", iTrack);
		
		iTarget = find_ent_by_tname(-1, sText);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, (iTrack < 100) ? "end" : "end1");

			if(!is_valid_ent(iTarget)) {
				iTarget = find_ent_by_tname(-1, "end");
			}
		}
		
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, fVelocity);
	}
}

public createSpecialMonster(const powerBoss, const powerRepeat) {
	if(!powerBoss) {
		if(g_Tramposo) {
			return;
		}

		if(MAPS_DESC[g_MapId][mapSpecial] == 2) {
			return;
		}
	}

	static iLastEgg;
	new iRepeat = 1;
	new iEnt;
	new Float:vecMins[3];
	new Float:vecMax[3];
	new Float:fVelocity;
	new Float:vecAngles[3];
	new Float:vecVelocity[3];
	new Float:vecOrigin[3];
	new i;
	
	if(DIFFICULTIES_VALUES[g_Difficulty][difficultyEgg_Extra] && !powerBoss) {
		iRepeat = 2;
	} else if(powerRepeat) {
		entity_get_vector(powerBoss, EV_VEC_angles, vecAngles);
		iRepeat = powerRepeat;
	}
	
	for(i = 0; i < iRepeat; ++i) {
		iEnt = create_entity("info_target");
		
		if(is_valid_ent(iEnt)) {
			if(!powerBoss) {
				if(iRepeat == 1) {
					if(!iLastEgg) {
						i = 1;
					}
				}

				entity_set_string(iEnt, EV_SZ_classname, ENT_EGG_MONSTER_CLASSNAME);
				
				dllfunc(DLLFunc_Spawn, iEnt);
				
				entity_set_model(iEnt, MODEL_EGG);
				entity_set_float(iEnt, EV_FL_health, 99999.0);
				entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_NO);
				
				entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
				entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
				
				entity_set_origin(iEnt, (i == 0) ? g_VecSpecialOrigin : g_VecSpecial2Origin);

				iLastEgg = i;
			} else {
				entity_set_string(iEnt, EV_SZ_classname, ENT_EGG_MONSTER_CLASSNAME);
				
				dllfunc(DLLFunc_Spawn, iEnt);
				
				entity_set_model(iEnt, MODEL_EGG);
				entity_set_float(iEnt, EV_FL_health, 99999.0);
				entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_NO);
				
				entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
				entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
				
				// set_task(0.2, "__changeSolidState", iEnt);
				
				velocity_by_aim(powerBoss, 2000, vecVelocity);
				__getDropOrigin(powerBoss, vecOrigin);
				
				entity_set_origin(iEnt, vecOrigin);
				entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);
				
				vecAngles[1] += 22.5;
				entity_set_vector(powerBoss, EV_VEC_v_angle, vecAngles);
				entity_set_vector(powerBoss, EV_VEC_angles, vecAngles);
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
			
			fVelocity = 220.0 + float((g_Wave * 2));
			
			if(DIFFICULTIES_VALUES[g_Difficulty][difficultyEgg_DmgSpeed]) {
				fVelocity = fVelocity + ((fVelocity * 20.0) / 100.0);
			}
			
			entity_set_float(iEnt, MONSTER_SPEED, fVelocity);
			
			entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
			
			++g_MonstersAlive;
			++g_TotalMonsters;
			++g_SpecialMonsters_Spawn;
			
			clearDHUDs();
			entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
			
			if(!powerBoss) {
				new sArgs[7];
				
				remove_task(TASK_ALLOW_ANOTHER_MONSTER);

				if(g_Difficulty < DIFF_HELL) {
					set_task(0.2, "allowDropAnotherMonster", TASK_ALLOW_ANOTHER_MONSTER);
					set_task(2.9, "entFly", iEnt);
				} else {
					set_task(1.0, "allowDropAnotherMonster", TASK_ALLOW_ANOTHER_MONSTER);
					set_task(0.5, "entFly", iEnt);
				}
			
				set_task(32.9, "damageTower__Effect", TASK_DAMAGE_TOWER + iEnt, sArgs, 6);
				set_task(33.0, "damageTower", TASK_DAMAGE_TOWER + iEnt);
			} else {
				new Float:flRandomFloat = random_float(1.9, 4.9);
				set_task(flRandomFloat, "entFly", iEnt);
			}
		}
	}
}

public allowDropAnotherMonster() {
	return;
}

public checkAccount(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id, password, ip, vinc FROM td_users WHERE name=^"%s^";", g_UserName[id]);
	
	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 3);
	else if(SQL_NumResults(sqlQuery)) {
		new sIP[21];
		new sIPdb[21];
		new sPassword[32];
		
		g_UserId[id] = SQL_ReadResult(sqlQuery, 0);
		SQL_ReadResult(sqlQuery, 1, g_AccountPassword[id], 31);
		SQL_ReadResult(sqlQuery, 2, sIPdb, 20);
		g_AccountVinc[id] = SQL_ReadResult(sqlQuery, 3);
		
		/*if(!g_AccountVinc[id]) {
			set_task(180.0, "rememberVinc", id + TASK_VINC);
		}*/
		
		SQL_FreeHandle(sqlQuery);
		
		// Está baneada la cuenta ?
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT start, finish, name_admin, reason FROM td_bans WHERE td_id='%d' AND activo='1' LIMIT 1;", g_UserId[id]);
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 81512);
		} else if(SQL_NumResults(sqlQuery)) {
			SQL_ReadResult(sqlQuery, 0, g_AccountBan_Start[id], 31);
			SQL_ReadResult(sqlQuery, 1, g_AccountBan_Finish[id], 31);
			SQL_ReadResult(sqlQuery, 2, g_AccountBan_Admin[id], 31);
			SQL_ReadResult(sqlQuery, 3, g_AccountBan_Reason[id], 127);
			
			new sDate[16];
			new sTime[16];
			
			new sYear[5];
			new sMonth[3];
			new sDay[3];
			new sHour[3];
			new sMin[3];
			new sSec[3];
			
			new iYear;
			new iMonth;
			new iDay;
			new iHour;
			new iMin;
			new iSec;
			
			new iActualTime;
			new iBannedTo;
			
			iActualTime = get_systime();
			
			parse(g_AccountBan_Finish[id], sDate, 15, sTime, 15);
			
			replace_all(sDate, 15, "-", " ");
			replace_all(sTime, 15, ":", " ");
			
			parse(sDate, sYear, 4, sMonth, 2, sDay, 2);
			parse(sTime, sHour, 2, sMin, 2, sSec, 2);
			
			iYear = str_to_num(sYear);
			iMonth = str_to_num(sMonth);
			iDay = str_to_num(sDay);
			iHour = str_to_num(sHour);
			iMin = str_to_num(sMin);
			iSec = str_to_num(sSec);
			
			iBannedTo = time_to_unix(iYear, iMonth, iDay, iHour, iMin, iSec);
			
			SQL_FreeHandle(sqlQuery);
			
			if(iActualTime < iBannedTo) {
				set_task(2.0, "task__KickReasonBan", id);
				return;
			} else {
				colorChat(0, TERRORIST, "%sEl usuario !t%s!y tenía !gban de cuenta!y pero ya puede volver a jugar!", TD_PREFIX, g_UserName[id]);
				
				sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE td_bans SET activo='0' WHERE td_id='%d';", g_UserId[id]);
				if(!SQL_Execute(sqlQuery)) {
					executeQuery(id, sqlQuery, 94141);
				} else {
					SQL_FreeHandle(sqlQuery);
				}
			}
		} else {
			SQL_FreeHandle(sqlQuery);
		}
		
		
		get_user_info(id, "td2", sPassword, 31);
		get_user_ip(id, sIP, 20, 1);
		
		g_AccountRegister[id] = 1;
		
		if(equal(sIPdb, sIP) && equal(g_AccountPassword[id], sPassword)) {
			g_AccountLogged[id] = 1;
			
			loadInfo(id);
			
			remove_task(id + TASK_SAVE);
			set_task(random_float(180.0, 360.0), "saveTask", id + TASK_SAVE, _, _, "b");
		} else {
			clcmd_Changeteam(id);
		}
		
		/*message_begin(MSG_ONE_UNRELIABLE, g_Message_ShowMenu, .player = id);
		write_short(0);
		write_char(0);
		write_byte(0);
		write_string("");
		message_end();*/
	} else {
		SQL_FreeHandle(sqlQuery);
		clcmd_Changeteam(id);
	}
}

public saveTask(const taskid) {
	if(!is_user_connected(ID_SAVE)) {
		return;
	}
	
	saveInfo(ID_SAVE);
}

public saveInfo(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	if(!g_AccountLogged[id]) {
		return;
	}
	
	new sIP[21];
	get_user_ip(id, sIP, 20, 1);
	
	new iLen = 0;
	new sQuery[1024];
	
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "UPDATE td_users SET ip=^"%s^",kills='%d',soldier_lvl='%d',soldier_kills='%d',engineer_lvl='%d',engineer_dmg='%d',support_lvl='%d',support_dmg='%d',sniper_lvl='%d',sniper_kills='%d',",
		sIP, g_Kills[id], g_ClassLevel[id][CLASS_SOLDADO], g_ClassReqs[id][CLASS_SOLDADO], g_ClassLevel[id][CLASS_INGENIERO], g_ClassReqs[id][CLASS_INGENIERO], g_ClassLevel[id][CLASS_SOPORTE], g_ClassReqs[id][CLASS_SOPORTE],
		g_ClassLevel[id][CLASS_FRANCOTIRADOR], g_ClassReqs[id][CLASS_FRANCOTIRADOR]);
	
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "pub_lvl='%d',pub_dmg='%d',leg_lvl='%d',leg_dmg='%d',bit_lvl='%d',bit_kills='%d',scout_lvl='%d',scout_dmg='%d',pist_lvl='%d',pist_req='%d',",
		g_ClassLevel[id][CLASS_PUBERO], g_ClassReqs[id][CLASS_PUBERO], g_ClassLevel[id][CLASS_LEGIONARIO], g_ClassReqs[id][CLASS_LEGIONARIO],
		g_ClassLevel[id][CLASS_BITERO], g_ClassReqs[id][CLASS_BITERO], g_ClassLevel[id][CLASS_SCOUTER], g_ClassReqs[id][CLASS_SCOUTER],
		g_ClassLevel[id][CLASS_PISTOLERO], g_ClassReqs[id][CLASS_PISTOLERO]);

	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "last_connect=now(),upg_infi='%d',infi='%d',upg_crit='%d',upg_resist='%d',upg_thor='%d',upg_apoyo='%d',upg_pesado='%d',upg_asalto='%d',upg_comandante='%d',upg_speed='%d',fps=^"%d %d %d %d^",",
		g_Power[id][POWER_PRECISION_PERFECTA], g_Power[id][POWER_BALAS_INFINITAS], g_Upgrades[id][HAB_CRITICO], g_Upgrades[id][HAB_RESISTENCIA], g_Upgrades[id][HAB_THOR], g_Upgrades[id][HAB_UNLOCK_APOYO], g_Upgrades[id][HAB_UNLOCK_PESADO], g_Upgrades[id][HAB_UNLOCK_ASALTO],
		g_Upgrades[id][HAB_UNLOCK_COMANDANTE], g_Upgrades[id][HAB_SPEED], g_Option_LowFPS_Models[id], g_Option_LowFPS_Glow[id], g_Option_LowFPS_Sentries[id], g_Option_LowFPS_ZombieDead[id]);

	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "levelg='%d',points='%d',hud_color_eff_cent_pr=^"%d %d %d %d %d %d %d^",hud_position=^"%f %f^",achievement_count='%d',osmios='%d',mvp=`mvp`+'%d',gold=`gold`+'%d',classid='%d',tut='%d',",
		g_LevelG[id], g_Points[id], g_Options_HUD_Color[id][C_RED], g_Options_HUD_Color[id][C_GREEN], g_Options_HUD_Color[id][C_BLUE], g_Options_HUD_Effect[id], g_Options_HUD_Center[id], g_Options_HUD_ProgressClass[id], g_Options_HUD_KillsPerWave[id],
		g_Options_HUD_Position[id][0], g_Options_HUD_Position[id][1], g_AchievementCount[id], g_Osmio[id], g_WinMVP[id], g_GoldG[id], g_ClassId[id], g_Tutorial[id]);

	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "oslost=`oslost`+'%d',apoyo_lvl='%d',apoyo_dmg='%d',pesado_lvl='%d',pesado_dmg='%d',asalto_lvl='%d',asalto_kills='%d',comandante_lvl='%d',comandante_kills='%d' WHERE id='%d';",
		g_OsmioLost[id], g_ClassLevel[id][CLASS_APOYO], g_ClassReqs[id][CLASS_APOYO], g_ClassLevel[id][CLASS_PESADO], g_ClassReqs[id][CLASS_PESADO], g_ClassLevel[id][CLASS_ASALTO],
		g_ClassReqs[id][CLASS_ASALTO], g_ClassLevel[id][CLASS_COMANDANTE], g_ClassReqs[id][CLASS_COMANDANTE], g_UserId[id]);

	SQL_ThreadQuery(g_SqlTuple, "sqlThread__UpdateData", sQuery);

	g_WinMVP[id] = 0;
	g_GoldG[id] = 0;

	iLen = 0;
	sQuery[0] = EOS;
	
	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "UPDATE td_waveboss SET waves_normal=^"%d %d %d %d %d %d %d %d %d %d %d^",waves_nightmare=^"%d %d %d %d %d %d %d %d %d %d %d^",",
		g_WavesWins[id][DIFF_NORMAL][0], g_WavesWins[id][DIFF_NORMAL][1], g_WavesWins[id][DIFF_NORMAL][2], g_WavesWins[id][DIFF_NORMAL][3], g_WavesWins[id][DIFF_NORMAL][4], g_WavesWins[id][DIFF_NORMAL][5], g_WavesWins[id][DIFF_NORMAL][6],
		g_WavesWins[id][DIFF_NORMAL][7], g_WavesWins[id][DIFF_NORMAL][8], g_WavesWins[id][DIFF_NORMAL][9], g_WavesWins[id][DIFF_NORMAL][10], g_WavesWins[id][DIFF_NIGHTMARE][0], g_WavesWins[id][DIFF_NIGHTMARE][1], g_WavesWins[id][DIFF_NIGHTMARE][2],
		g_WavesWins[id][DIFF_NIGHTMARE][3], g_WavesWins[id][DIFF_NIGHTMARE][4], g_WavesWins[id][DIFF_NIGHTMARE][5], g_WavesWins[id][DIFF_NIGHTMARE][6], g_WavesWins[id][DIFF_NIGHTMARE][7], g_WavesWins[id][DIFF_NIGHTMARE][8],
		g_WavesWins[id][DIFF_NIGHTMARE][9], g_WavesWins[id][DIFF_NIGHTMARE][10]);

	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "waves_suicidal=^"%d %d %d %d %d %d %d %d %d %d %d^",waves_hell=^"%d %d %d %d %d %d %d %d %d %d %d^",",
		g_WavesWins[id][DIFF_SUICIDAL][0], g_WavesWins[id][DIFF_SUICIDAL][1], g_WavesWins[id][DIFF_SUICIDAL][2], g_WavesWins[id][DIFF_SUICIDAL][3], g_WavesWins[id][DIFF_SUICIDAL][4], g_WavesWins[id][DIFF_SUICIDAL][5], g_WavesWins[id][DIFF_SUICIDAL][6],
		g_WavesWins[id][DIFF_SUICIDAL][7], g_WavesWins[id][DIFF_SUICIDAL][8], g_WavesWins[id][DIFF_SUICIDAL][9], g_WavesWins[id][DIFF_SUICIDAL][10], g_WavesWins[id][DIFF_HELL][0], g_WavesWins[id][DIFF_HELL][1], g_WavesWins[id][DIFF_HELL][2],
		g_WavesWins[id][DIFF_HELL][3], g_WavesWins[id][DIFF_HELL][4], g_WavesWins[id][DIFF_HELL][5], g_WavesWins[id][DIFF_HELL][6], g_WavesWins[id][DIFF_HELL][7], g_WavesWins[id][DIFF_HELL][8], g_WavesWins[id][DIFF_HELL][9], g_WavesWins[id][DIFF_HELL][10]);

	iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "boss_normal='%d',boss_nightmare='%d',boss_suicidal='%d',boss_hell='%d',hab_wpn_dmg='%d',hab_wpn_recoil='%d',hab_wpn_speed='%d',hab_wpn_clip='%d' WHERE td_id='%d';",
		g_BossKills[id][DIFF_NORMAL], g_BossKills[id][DIFF_NIGHTMARE], g_BossKills[id][DIFF_SUICIDAL], g_BossKills[id][DIFF_HELL], g_Hab[id][HAB_DAMAGE], g_Hab[id][HAB_PRECISION], g_Hab[id][HAB_VELOCIDAD], g_Hab[id][HAB_BALAS], g_UserId[id]);

	SQL_ThreadQuery(g_SqlTuple, "sqlThread__UpdateData", sQuery);
}

public executeQuery(const id, const Handle:query, const query_num) {
	SQL_QueryError(query, g_SqlError, 511);
	
	log_to_file("td_sql.log", "- LOG: %d - %s", query_num, g_SqlError);
	
	if(is_user_valid_connected(id)) {
		server_cmd("kick #%d ^"Hubo un error al guardar/cargar tus datos. Intente mas tarde^"", get_user_userid(id));
	}
	
	SQL_FreeHandle(query);
}

public pluginSQL() {
	//server_cmd("hostname ^"Drunk-Gaming.com | %s %s | Invasion^"", PLUGIN_NAME, PLUGIN_VERSION);
	server_cmd("sv_voicecodec ^"voice_speex^"");

	set_cvar_num("sv_alltalk", 1);
	set_cvar_num("sv_voicequality", 5);
	set_cvar_num("sv_airaccelerate", 100);
	set_cvar_num("mp_flashlight", 0);
	set_cvar_num("mp_footsteps", 0);
	set_cvar_num("mp_freezetime", 0);
	set_cvar_num("mp_friendlyfire", 0);
	set_cvar_num("mp_limitteams", 32);
	set_cvar_num("mp_autoteambalance", 0);
	set_cvar_num("mp_timelimit", 250);
	set_cvar_num("sv_restart", 1);
	set_cvar_num("amx_afk_time", 9999);
	set_cvar_num("amx_reservation", 0);
	
	set_cvar_string("sv_voicecodec", "voice_speex");
	
	new iSql_ErrorNum;
	
	g_SqlTuple = SQL_MakeDbTuple(SQL_HOST, SQL_USER, SQL_PASS, SQL_TABLE);
	g_SqlConnection = SQL_Connect(g_SqlTuple, iSql_ErrorNum, g_SqlError, 511);

	if(g_SqlConnection == Empty_Handle)
	{
		log_to_file("td_sql_connect.log", "%s", g_SqlError);

		set_fail_state(g_SqlError);
		return;
	}
	
	g_EntCheckAFK = create_entity("info_target");
	
	if(is_valid_ent(g_EntCheckAFK)) {
		entity_set_string(g_EntCheckAFK, EV_SZ_classname, "entCheckAFK");
		entity_set_float(g_EntCheckAFK, EV_FL_nextthink, THINK_CHECK_AFK);
		
		register_think("entCheckAFK", "think__CheckAFK");
	}
}

public plugin_end() {
	SQL_FreeHandle(g_SqlConnection);
	SQL_FreeHandle(g_SqlTuple);
}

public loadInfo(const id) {
	if(!is_user_connected(id)) {
		return;
	}

	new sText[256];
	formatex(sText, 255, "kills, soldier_lvl, soldier_kills, engineer_lvl, engineer_dmg, support_lvl, support_dmg, sniper_lvl, sniper_kills, levelg, points, hud_color_eff_cent_pr, hud_position, achievement_count, osmios, gold, mvp, classid, tut, apoyo_lvl, apoyo_dmg");
	
	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT %s, pesado_lvl,pesado_dmg,asalto_lvl,asalto_kills,comandante_lvl,comandante_kills,upg_crit,upg_resist,upg_thor,upg_apoyo,upg_pesado,upg_asalto,upg_comandante,upg_speed,upg_infi,infi,fps,\
		pist_lvl,pist_req,pub_lvl,pub_dmg,leg_lvl,leg_dmg,bit_lvl,bit_kills,scout_lvl,scout_dmg FROM td_users WHERE id = '%d';", sText, g_UserId[id]);
	
	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 4);
	} else {
		new sInfo__64[64];
		new sHUD_Info[7][4];
		new sHUD_Position[2][10];
		
		g_Kills[id] = SQL_ReadResult(sqlQuery, 0);
		
		g_ClassLevel[id][CLASS_SOLDADO] = SQL_ReadResult(sqlQuery, 1);
		g_ClassReqs[id][CLASS_SOLDADO] = SQL_ReadResult(sqlQuery, 2);
		g_ClassLevel[id][CLASS_INGENIERO] = SQL_ReadResult(sqlQuery, 3);
		g_ClassReqs[id][CLASS_INGENIERO] = SQL_ReadResult(sqlQuery, 4);
		g_ClassLevel[id][CLASS_SOPORTE] = SQL_ReadResult(sqlQuery, 5);
		g_ClassReqs[id][CLASS_SOPORTE] = SQL_ReadResult(sqlQuery, 6);
		g_ClassLevel[id][CLASS_FRANCOTIRADOR] = SQL_ReadResult(sqlQuery, 7);
		g_ClassReqs[id][CLASS_FRANCOTIRADOR] = SQL_ReadResult(sqlQuery, 8);
		
		g_LevelG[id] = SQL_ReadResult(sqlQuery, 9);
		g_Points[id] = SQL_ReadResult(sqlQuery, 10);
		
		SQL_ReadResult(sqlQuery, 11, sInfo__64, 63);
		parse(sInfo__64, sHUD_Info[0], 3, sHUD_Info[1], 3, sHUD_Info[2], 3, sHUD_Info[3], 3, sHUD_Info[4], 3, sHUD_Info[5], 3, sHUD_Info[6], 3);
		
		g_Options_HUD_Color[id][C_RED] = str_to_num(sHUD_Info[0]);
		g_Options_HUD_Color[id][C_GREEN] = str_to_num(sHUD_Info[1]);
		g_Options_HUD_Color[id][C_BLUE] = str_to_num(sHUD_Info[2]);
		g_Options_HUD_Effect[id] = str_to_num(sHUD_Info[3]);
		g_Options_HUD_Center[id] = str_to_num(sHUD_Info[4]);
		g_Options_HUD_ProgressClass[id] = str_to_num(sHUD_Info[5]);
		g_Options_HUD_KillsPerWave[id] = str_to_num(sHUD_Info[6]);
		
		SQL_ReadResult(sqlQuery, 12, sInfo__64, 63);
		parse(sInfo__64, sHUD_Position[0], 9, sHUD_Position[1], 9);
		
		g_Options_HUD_Position[id][0] = str_to_float(sHUD_Position[0]);
		g_Options_HUD_Position[id][1] = str_to_float(sHUD_Position[1]);
		
		g_AchievementCount[id] = SQL_ReadResult(sqlQuery, 13);
		g_Osmio[id] = SQL_ReadResult(sqlQuery, 14);
		g_GoldGaben[id] = SQL_ReadResult(sqlQuery, 15);
		g_WinMVPGaben[id] = SQL_ReadResult(sqlQuery, 16);
		g_ClassId[id] = SQL_ReadResult(sqlQuery, 17);
		g_Tutorial[id] = SQL_ReadResult(sqlQuery, 18);
		
		g_ClassLevel[id][CLASS_APOYO] = SQL_ReadResult(sqlQuery, 19);
		g_ClassReqs[id][CLASS_APOYO] = SQL_ReadResult(sqlQuery, 20);
		g_ClassLevel[id][CLASS_PESADO] = SQL_ReadResult(sqlQuery, 21);
		g_ClassReqs[id][CLASS_PESADO] = SQL_ReadResult(sqlQuery, 22);
		g_ClassLevel[id][CLASS_ASALTO] = SQL_ReadResult(sqlQuery, 23);
		g_ClassReqs[id][CLASS_ASALTO] = SQL_ReadResult(sqlQuery, 24);
		g_ClassLevel[id][CLASS_COMANDANTE] = SQL_ReadResult(sqlQuery, 25);
		g_ClassReqs[id][CLASS_COMANDANTE] = SQL_ReadResult(sqlQuery, 26);
		
		g_Upgrades[id][HAB_CRITICO] = SQL_ReadResult(sqlQuery, 27);
		g_Upgrades[id][HAB_RESISTENCIA] = SQL_ReadResult(sqlQuery, 28);
		g_Upgrades[id][HAB_THOR] = SQL_ReadResult(sqlQuery, 29);
		g_Upgrades[id][HAB_UNLOCK_APOYO] = SQL_ReadResult(sqlQuery, 30);
		g_Upgrades[id][HAB_UNLOCK_PESADO] = SQL_ReadResult(sqlQuery, 31);
		g_Upgrades[id][HAB_UNLOCK_ASALTO] = SQL_ReadResult(sqlQuery, 32);
		g_Upgrades[id][HAB_UNLOCK_COMANDANTE] = SQL_ReadResult(sqlQuery, 33);
		g_Upgrades[id][HAB_SPEED] = SQL_ReadResult(sqlQuery, 34);
		
		g_Power[id][POWER_PRECISION_PERFECTA] = SQL_ReadResult(sqlQuery, 35);
		g_Power[id][POWER_BALAS_INFINITAS] = SQL_ReadResult(sqlQuery, 36);

		SQL_ReadResult(sqlQuery, 37, sInfo__64, 63);
		parse(sInfo__64, sHUD_Info[0], 3, sHUD_Info[1], 3, sHUD_Info[2], 3, sHUD_Info[3], 3);

		g_Option_LowFPS_Models[id] = str_to_num(sHUD_Info[0]);
		g_Option_LowFPS_Glow[id] = str_to_num(sHUD_Info[1]);
		g_Option_LowFPS_Sentries[id] = str_to_num(sHUD_Info[2]);
		g_Option_LowFPS_ZombieDead[id] = str_to_num(sHUD_Info[3]);

		g_ClassLevel[id][CLASS_PISTOLERO] = SQL_ReadResult(sqlQuery, 38);
		g_ClassReqs[id][CLASS_PISTOLERO] = SQL_ReadResult(sqlQuery, 39);
		g_ClassLevel[id][CLASS_PUBERO] = SQL_ReadResult(sqlQuery, 40);
		g_ClassReqs[id][CLASS_PUBERO] = SQL_ReadResult(sqlQuery, 41);
		g_ClassLevel[id][CLASS_LEGIONARIO] = SQL_ReadResult(sqlQuery, 42);
		g_ClassReqs[id][CLASS_LEGIONARIO] = SQL_ReadResult(sqlQuery, 43);
		g_ClassLevel[id][CLASS_BITERO] = SQL_ReadResult(sqlQuery, 44);
		g_ClassReqs[id][CLASS_BITERO] = SQL_ReadResult(sqlQuery, 45);
		g_ClassLevel[id][CLASS_SCOUTER] = SQL_ReadResult(sqlQuery, 46);
		g_ClassReqs[id][CLASS_SCOUTER] = SQL_ReadResult(sqlQuery, 47);
		
		SQL_FreeHandle(sqlQuery);
	}
	
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT * FROM td_waveboss WHERE td_id='%d';", g_UserId[id]);
	
	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 9);
	else {
		/*
			0 = id
			1 = td_id
		*/
		
		new sWaves[128];
		new sWave[11][4][8];
		new i;
		new j;
		
		for(i = 0; i < 4; ++i) {
			SQL_ReadResult(sqlQuery, (2 + i), sWaves, 127);
			parse(sWaves, sWave[0][i], 7, sWave[1][i], 7, sWave[2][i], 7, sWave[3][i], 7, sWave[4][i], 7, sWave[5][i], 7, sWave[6][i], 7, sWave[7][i], 7, sWave[8][i], 7, sWave[9][i], 7, sWave[10][i], 7);
			
			for(j = 0; j < 11; ++j) {
				g_WavesWins[id][i][j] = str_to_num(sWave[j][i]);
			}
		}
		
		g_BossKills[id][DIFF_NORMAL] = SQL_ReadResult(sqlQuery, 6);
		g_BossKills[id][DIFF_NIGHTMARE] = SQL_ReadResult(sqlQuery, 7);
		g_BossKills[id][DIFF_SUICIDAL] = SQL_ReadResult(sqlQuery, 8);
		g_BossKills[id][DIFF_HELL] = SQL_ReadResult(sqlQuery, 9);
		g_Hab[id][HAB_DAMAGE] = SQL_ReadResult(sqlQuery, 10);
		g_Hab[id][HAB_PRECISION] = SQL_ReadResult(sqlQuery, 11);
		g_Hab[id][HAB_VELOCIDAD] = SQL_ReadResult(sqlQuery, 12);
		g_Hab[id][HAB_BALAS] = SQL_ReadResult(sqlQuery, 13);
	
		SQL_FreeHandle(sqlQuery);
	}
	
	if(g_AchievementCount[id]) {
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT achievement_id, achievement_date FROM td_achievements WHERE td_id = '%d';", g_UserId[id]);
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(id, sqlQuery, 21);
		} else if(SQL_NumResults(sqlQuery)) {
			new iAchievement;
			
			while(SQL_MoreResults(sqlQuery)) {
				iAchievement = SQL_ReadResult(sqlQuery, 0);
				
				g_Achievement[id][iAchievement] = 1;
				g_AchievementUnlock[id][iAchievement] = SQL_ReadResult(sqlQuery, 1);
				
				SQL_NextRow(sqlQuery);
			}
			
			SQL_FreeHandle(sqlQuery);
		} else {
			SQL_FreeHandle(sqlQuery);
		}
	}

	loadFavoriteDifficults(id);
	
	set_task(random_float(10.0, 20.0), "checkAchievements", id);
	
	showMenu__Join(id);
}

public showMenu__RegisterLogin(const id) {
	if(!is_user_connected(id))
		return;
	
	static sMenu[450];
	new iLen;
	
	iLen = 0;
	
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yBienvenido a %s \r%s^nby \y%s^n^n", PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.%s REGISTRARSE^n", (g_AccountRegister[id]) ? "\d" : "\w");
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r2.%s IDENTIFICARSE^n^n", (g_AccountRegister[id]) ? "\w" : "\d");
	
	if(g_AccountRegister[id]) {
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\wCUENTA \y#%d", g_UserId[id]);
	}
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "Register Login Menu");
}

public menu__RegisterLogin(const id, const key) {
	if(!is_user_connected(id) || g_AccountLogged[id])
		return PLUGIN_HANDLED;
	
	switch(key) {
		case 0: {
			if(g_AccountRegister[id]) {
				client_print(id, print_center, "Este nombre de usuario ya está registrado");
				
				showMenu__RegisterLogin(id);
				return PLUGIN_HANDLED;
			}
			
			client_cmd(id, "messagemode CREAR_CONTRASENIA");
			client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_OK);
			
			colorChat(id, CT, "%s!tEscribe una contraseña que recuerdes y que sea difícil para proteger tus datos!", TD_PREFIX);
			return PLUGIN_HANDLED;
		}
		case 1: {
			if(!g_AccountRegister[id]) {
				client_print(id, print_center, "Este nombre de usuario no está registrado");
				
				showMenu__RegisterLogin(id);
				return PLUGIN_HANDLED;
			}
			
			client_cmd(id, "messagemode INGRESAR_CONTRASENIA");
			client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_OK);
			
			colorChat(id, CT, "%s!tEscribe la contraseña que protege a esta cuenta!", TD_PREFIX);
			return PLUGIN_HANDLED;
		}
	}
	
	showMenu__RegisterLogin(id);
	return PLUGIN_HANDLED;
}

public clcmd_CreatePassword(const id) {
	if(!is_user_connected(id) || g_AccountRegister[id])
		return PLUGIN_HANDLED;
	
	new sPassword[32];
	
	read_args(sPassword, 31);
	remove_quotes(sPassword);
	trim(sPassword);
	
	if(contain(sPassword, "%") != -1) {
		client_print(id, print_center, "Tu contraseña no puede contener el simbolo %%");
		
		client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_BAD);
		
		showMenu__RegisterLogin(id);
		return PLUGIN_HANDLED;
	}
	
	new iLenPassword = strlen(sPassword);
	new iLenName = strlen(g_UserName[id]);
	
	if(iLenName < 3) {
		client_print(id, print_center, "Tu nombre debe tener al menos tres caracteres");
		
		client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_BAD);
		
		showMenu__RegisterLogin(id);
		return PLUGIN_HANDLED;
	}
	
	if(iLenPassword < 4) {
		client_print(id, print_center, "La contraseña debe tener al menos 4 caracteres");
		
		client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_BAD);
		
		showMenu__RegisterLogin(id);
		return PLUGIN_HANDLED;
	}
	else if(iLenPassword > 30) {
		client_print(id, print_center, "La contraseña no puede superar los treinta caracteres");
		
		client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_BAD);
		
		showMenu__RegisterLogin(id);
		return PLUGIN_HANDLED;
	}
	
	copy(g_AccountPassword[id], 31, sPassword);
	
	client_cmd(id, "messagemode REPETIR_CONTRASENIA");
	client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_OK);
	
	colorChat(id, CT, "%s!tEscriba la contraseña nuevamente para su confirmación!", TD_PREFIX);
	return PLUGIN_HANDLED;
}

public clcmd_RepeatPassword(const id) {
	if(!is_user_connected(id) || g_AccountRegister[id])
		return PLUGIN_HANDLED;
	
	new sPassword[32];
	
	read_args(sPassword, 31);
	remove_quotes(sPassword);
	trim(sPassword);
	
	if(!equal(g_AccountPassword[id], sPassword)) {
		g_AccountPassword[id][0] = EOS;
	
		showMenu__RegisterLogin(id);
		
		client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_BAD);
		
		colorChat(id, CT, "%s!tLa contraseña escrita no coincide con la anterior!", TD_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	new sIP[21];
	new sMD5_Password[34];
	
	get_user_ip(id, sIP, 20, 1);
	
	md5(sPassword, sMD5_Password);
	sMD5_Password[6] = EOS;
	
	client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_OK);
	
	new Handle:sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO td_users (`name`, `password`, `ip`, `last_connect`) VALUES (^"%s^", '%s', '%s', now());", g_UserName[id], sMD5_Password, sIP);
	if(!SQL_Execute(sqlQuery))
		executeQuery(id, sqlQuery, 1);
	else {
		SQL_FreeHandle(sqlQuery);
		
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id FROM td_users WHERE name=^"%s^";", g_UserName[id]);
		if(!SQL_Execute(sqlQuery))
			executeQuery(id, sqlQuery, 2);
		else if(SQL_NumResults(sqlQuery)) {
			g_UserId[id] = SQL_ReadResult(sqlQuery, 0);
			
			SQL_FreeHandle(sqlQuery);
			
			sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO td_waveboss (`td_id`) VALUES ('%d');", g_UserId[id]);
			
			if(!SQL_Execute(sqlQuery))
				executeQuery(id, sqlQuery, 84536);
			else {
				SQL_FreeHandle(sqlQuery);
				
				new sRegisterCount[15];
				addDot(g_UserId[id], sRegisterCount, 14);
				
				colorChat(0, _, "%sBienvenido !g%s!y, eres la cuenta registrada !g#%s!y.", TD_PREFIX, g_UserName[id], sRegisterCount);
				
				g_AccountRegister[id] = 1;
				g_AccountLogged[id] = 1;
				
				g_Points[id] = 10;
				
				showMenu__Join(id);
			}
		}
		else
			SQL_FreeHandle(sqlQuery);
		
		remove_task(id + TASK_SAVE);
		set_task(random_float(180.0, 360.0), "saveTask", id + TASK_SAVE, _, _, "b");
		
		resetInfo(id);
		client_cmd(id, "setinfo td2 ^"%s^"", sMD5_Password);
	}
	
	return PLUGIN_HANDLED;
}

public clcmd_EnterPassword(const id) {
	if(!is_user_connected(id) || !g_AccountRegister[id] || g_AccountLogged[id]) {
		return PLUGIN_HANDLED;
	}
	
	new sPassword[32];
	new sMD5_Password[34];
	
	read_args(sPassword, 31);
	remove_quotes(sPassword);
	trim(sPassword);
	
	md5(sPassword, sMD5_Password);
	sMD5_Password[6] = EOS;
	
	if(!equal(g_AccountPassword[id], sMD5_Password)) {
		showMenu__RegisterLogin(id);
		
		client_cmd(id, "spk ^"%s^"", SOUND_BUTTON_BAD);
		
		colorChat(id, CT, "%s!tLa contraseña ingresada no coincide con la de esta cuenta!", TD_PREFIX);		
		return PLUGIN_HANDLED;
	}
	
	g_AccountLogged[id] = 1;
	
	resetInfo(id);
	client_cmd(id, "setinfo td2 ^"%s^"", sMD5_Password);
	
	loadInfo(id);
	
	remove_task(id + TASK_SAVE);
	set_task(random_float(180.0, 360.0), "saveTask", id + TASK_SAVE, _, _, "b");
	
	showMenu__Join(id);
	return PLUGIN_HANDLED;
}

stock addDot(const number, sOutPut[], const len) {
	new sTemp[15];
	new iOutputPos;
	new iNumPos;
	new iNumLen = num_to_str(number, sTemp, 14);
	
	while((iNumPos < iNumLen) && (iOutputPos < len)) {
		sOutPut[iOutputPos++] = sTemp[iNumPos++];
		
		if((iNumLen - iNumPos) && !((iNumLen - iNumPos) % 3))
			sOutPut[iOutputPos++] = '.';
	}
	
	sOutPut[iOutputPos] = EOS;
	
	return iOutputPos;
}

public resetInfo(const id) {
	if(!is_user_connected(id))
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
	client_cmd(id, "setinfo zpt ^"^"");
}

public td_kmid_v2(const monster, const ent) {
	if(!isMonster(monster) || !is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}
	
	if(isEggMonster(monster)) {
		return FMRES_IGNORED;
	}
	
	static sText[18];	
	entity_get_string(ent, EV_SZ_classname, sText, charsmax(sText));
	
	if(sText[0] == 'f' && sText[5] == 'w') {
		static iTrack;
		iTrack = entity_get_int(monster, MONSTER_TRACK);
		
		static Float:vecOrigin[3];
		static Float:vecMonsterOrigin[3];
		static iTarget;
		static Float:fVelocity;
		
		fVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sText, charsmax(sText), "track%d", (iTrack + 1));
		
		iTarget = find_ent_by_tname(-1, sText);
		
		if(!is_valid_ent(iTarget))
			iTarget = find_ent_by_tname(-1, "end");
		
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		
		if(iTrack == 5) {
			vecMonsterOrigin[2] += 10.0;
			entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		}
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, fVelocity);
		
		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		__damageTower(monster, ent);
	} else {
		__touchSomething(sText, monster, ent);
	}
	
	return FMRES_IGNORED;
}

public td_orange(const monster, const ent) {
	if(!isMonster(monster) || !is_valid_ent(ent))
		return FMRES_IGNORED;
	
	if(isEggMonster(monster))
		return FMRES_IGNORED;
	
	static sText[18];	
	entity_get_string(ent, EV_SZ_classname, sText, charsmax(sText));
	
	if(sText[0] == 'f' && sText[5] == 'w') {
		static iTrack;
		iTrack = entity_get_int(monster, MONSTER_TRACK);
		
		static Float:vecOrigin[3];
		static Float:vecMonsterOrigin[3];
		static iTarget;
		static Float:fVelocity;
		
		fVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		formatex(sText, charsmax(sText), "track%d", (iTrack + 1));
		
		iTarget = find_ent_by_tname(-1, sText);
		
		if(!is_valid_ent(iTarget))
			iTarget = find_ent_by_tname(-1, "end");
		
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		
		switch(iTrack) {
			case 1: {
				vecMonsterOrigin[1] -= 50.0;
				vecMonsterOrigin[2] += 10.0;
				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			}
			case 2: {
				vecMonsterOrigin[2] -= 5.0;
				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			}
			case 3: {
				vecMonsterOrigin[1] += 65.0;
				vecMonsterOrigin[2] += 25.0;
				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			}
			case 4: {
				vecMonsterOrigin[1] += 90.0;
				vecMonsterOrigin[2] -= 17.0;
				entity_set_vector(monster, EV_VEC_origin, vecMonsterOrigin);
			}
		}
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, fVelocity);
		
		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		__damageTower(monster, ent);
	} else {
		__touchSomething(sText, monster, ent);
	}
	
	return FMRES_IGNORED;
}

public fw_TouchMonster_Post(const monster, const ent) {
	if(!isMonster(monster) || !is_valid_ent(ent)) {
		return FMRES_IGNORED;
	}
	
	if(isEggMonster(monster)) {
		return FMRES_IGNORED;
	}
	
	static sText[18];	
	entity_get_string(ent, EV_SZ_classname, sText, charsmax(sText));
	
	if(sText[0] == 'f' && sText[5] == 'w') {
		static iTrack;
		iTrack = entity_get_int(monster, MONSTER_TRACK);
		
		static Float:vecOrigin[3];
		static Float:vecMonsterOrigin[3];
		static iTarget;
		
		formatex(sText, charsmax(sText), "track%d", (iTrack + 1));
		
		iTarget = find_ent_by_tname(-1, sText);
		
		if(!is_valid_ent(iTarget)) {
			iTarget = find_ent_by_tname(-1, (iTrack < 100) ? "end" : "end1");

			if(!is_valid_ent(iTarget)) {
				iTarget = find_ent_by_tname(-1, "end");
			}
		}
		
		entity_get_vector(iTarget, EV_VEC_origin, vecOrigin);
		entity_get_vector(monster, EV_VEC_origin, vecMonsterOrigin);
		
		static Float:fVelocity;
		fVelocity = entity_get_float(monster, MONSTER_SPEED);
		
		entitySetAim(monster, vecMonsterOrigin, vecOrigin, fVelocity);
		
		entity_set_int(monster, MONSTER_TRACK, (iTrack + 1));
	} else if(isMonster(ent)) {
		__damageTower(monster, ent);
	} else {
		__touchSomething(sText, monster, ent);
	}
	
	return FMRES_IGNORED;
}

public __damageTower(const monster, const ent) {
	static iMonster;
	iMonster = (entity_get_int(monster, EV_INT_sequence) == 76) ? ent : monster;
	
	if(entity_get_int(iMonster, MONSTER_TRACK) == 1) {
		return;
	}
	
	if(isSpecialMonster(monster)) {
		__explodeBoomer(monster);
		return;
	}
	
	static iTeam;
	iTeam = entity_get_int(iMonster, EV_INT_team);
	
	entity_set_vector(iMonster, EV_VEC_origin, g_VecMonsterTowerOrigin[iTeam]);
	
	entity_set_int(iMonster, MONSTER_TRACK, 1);
	
	entity_set_int(iMonster, EV_INT_sequence, 76);
	entity_set_float(iMonster, EV_FL_animtime, get_gametime());
	
	entity_set_int(iMonster, EV_INT_gamestate, 1);
	
	entity_set_vector(iMonster, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
	
	emit_sound(iMonster, CHAN_BODY, MONSTER_SOUNDS_CLAW[random_num(0, charsmax(MONSTER_SOUNDS_CLAW))], 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	entity_set_int(iMonster, MONSTER_TARGET, 1337);
	
	static iDamage;
	iDamage = 5;
	
	if(DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower])
		iDamage = iDamage + ((iDamage * DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower]) / 100);
	
	g_TowerHealth -= iDamage;
	
	set_task(1.0, "damageTower", TASK_DAMAGE_TOWER + iMonster);
}

public __touchSomething(const sText[], const monster, const ent) {
	if(sText[0] == 'e' && sText[1] == 'n' && sText[2] == 't' && sText[3] == 'W' && sText[4] == 'G' && sText[5] == 'M') {
		zoneTouch(monster, ent);
	} else if((sText[0] == ENT_SENTRY_CLASSNAME[0] && sText[1] == ENT_SENTRY_CLASSNAME[1] && sText[2] == ENT_SENTRY_CLASSNAME[2] && sText[3] == ENT_SENTRY_CLASSNAME[3] && sText[4] == ENT_SENTRY_CLASSNAME[4] && sText[5] == ENT_SENTRY_CLASSNAME[5] &&
	sText[6] == ENT_SENTRY_CLASSNAME[6] && sText[7] == ENT_SENTRY_CLASSNAME[7] && sText[8] == ENT_SENTRY_CLASSNAME[8]) ||
	(sText[0] == ENT_SENTRY_BASE_CLASSNAME[0] && sText[1] == ENT_SENTRY_BASE_CLASSNAME[1] && sText[2] == ENT_SENTRY_BASE_CLASSNAME[2] && sText[3] == ENT_SENTRY_BASE_CLASSNAME[3] && sText[4] == ENT_SENTRY_BASE_CLASSNAME[4] &&
	sText[5] == ENT_SENTRY_BASE_CLASSNAME[5] && sText[6] == ENT_SENTRY_BASE_CLASSNAME[6] && sText[7] == ENT_SENTRY_BASE_CLASSNAME[7] && sText[8] == ENT_SENTRY_BASE_CLASSNAME[8] && sText[9] == ENT_SENTRY_BASE_CLASSNAME[9] &&
	sText[10] == ENT_SENTRY_BASE_CLASSNAME[10] && sText[11] == ENT_SENTRY_BASE_CLASSNAME[11] && sText[12] == ENT_SENTRY_BASE_CLASSNAME[12] && sText[13] == ENT_SENTRY_BASE_CLASSNAME[13] && sText[14] == ENT_SENTRY_BASE_CLASSNAME[14] &&
	sText[15] == ENT_SENTRY_BASE_CLASSNAME[15] && sText[16] == ENT_SENTRY_BASE_CLASSNAME[16])) {
		static iEnt;
		iEnt = entity_get_edict(ent, SENTRY_ENT_BASE);
		
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

		--g_SentryCount;
		
		set_task(0.1, "backToTrack", monster);
	}
}

public showMenu__Game(const id) {
	new iMenu;
	new sItem[100];
	
	formatex(sItem, charsmax(sItem), "%s \r%s^n\yNIVEL G!\r: \w%d^n^n\yCLASE\r: \w%s^n\yNIVEL\r: \w%d", PLUGIN_NAME, PLUGIN_VERSION, g_LevelG[id], CLASSES[g_ClassId[id]][className], g_ClassLevel[id][g_ClassId[id]]);
	iMenu = menu_create(sItem, "menu__Game");
	
	menu_setprop(iMenu, MPROP_PERPAGE, 0);
	
	menu_additem(iMenu, "CLASES", "1");
	
	formatex(sItem, charsmax(sItem), "DIFICULTADES (\y%s\w)^n", (!g_Wave) ? "EN VOTACIÓN" : (g_Difficulty == DIFF_NORMAL) ? "NORMAL" : (g_Difficulty == DIFF_NIGHTMARE) ? "NIGHTMARE" : (g_Difficulty == DIFF_SUICIDAL) ? "SUICIDAL" : "HELL");
	menu_additem(iMenu, sItem, "2");
	
	formatex(sItem, charsmax(sItem), "HABILIDADES %s", (!g_Points[id]) ? "" : "\w(\r**\w)");
	menu_additem(iMenu, sItem, "3");
	menu_additem(iMenu, "LOGROS", "4");
	menu_additem(iMenu, "\yMEJORAS^n", "5");
	
	menu_additem(iMenu, "REQUERIMIENTO DE NIVEL G!^n", "6");
	
	menu_additem(iMenu, "CONFIGURACIÓN", "7");
	menu_additem(iMenu, "ESTADÍSTICAS Y OTROS", "8");
	
	menu_addblank(iMenu, 1);
	
	menu_additem(iMenu, "SALIR", "0");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__Game(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	DestroyLocalMenu(id, menuId);
	
	switch(iItem) {
		case 1: showMenu__Classes(id);
		case 2: showMenu__ChooseDifficulty(id);
		case 3: showMenu__Habilities(id);
		case 4: showMenu__AchievementsClass(id);
		case 5: showMenu__Upgrades(id);
		case 6: showMenu__RequerimentsLevelG(id, g_LevelG[id]);
		case 7: showMenu__Configuration(id);
		case 8: showMenu__Stats(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__Classes(const id) {
	new iMenu;
	new sItem[80];
	new sPosition[3];
	new i;
	
	formatex(sItem, charsmax(sItem), "SELECCIONA UNA CLASE^n\wTU CLASE\r: \y%s^n\wNIVEL\r: \y%d\R", CLASSES[g_ClassId[id]][className], g_ClassLevel[id][g_ClassId[id]]);
	iMenu = menu_create(sItem, "menu__Classes");
	
	for(i = 0; i < classIds; ++i) {
		num_to_str((i + 1), sPosition, charsmax(sPosition));
		
		if(g_ClassId[id] != i) {
			menu_additem(iMenu, CLASSES[i][className], sPosition);
		} else {
			formatex(sItem, charsmax(sItem), "\d%s", CLASSES[i][className]);
			menu_additem(iMenu, sItem, sPosition);
		}
	}
	
	menu_setprop(iMenu, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenu, MPROP_NEXTNAME, "PÁG. SIGUIENTE");
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");

	g_MenuPage_Classes[id] = min(g_MenuPage_Classes[id], menu_pages(iMenu) - 1);
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, g_MenuPage_Classes[id]);
}

public menu__Classes(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}

	new iMenuDummy;
	player_menu_info(id, iMenuDummy, iMenuDummy, g_MenuPage_Classes[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	showMenu__ClassesINFO(id, iItem);
	
	return PLUGIN_HANDLED;
}

public showMenu__ClassesINFO(const id, const classId) {
	new iMenu;
	new sItem[150];
	new i;
	new sPosition[2];
	
	g_Menu_ClassId[id] = classId;
	
	formatex(sItem, charsmax(sItem), "%s^n\wNIVEL\r: \y%d^n^n%s", CLASSES[classId][className], g_ClassLevel[id][classId], CLASSES[classId][classDesc]);
	iMenu = menu_create(sItem, "menu__ClassesINFO");
	
	menu_additem(iMenu, "ELEGIR CLASE^n", "1", _, menu_makecallback("__checkClass"));
	
	for(i = 2; i < 8; ++i) {
		formatex(sItem, charsmax(sItem), "%sNIVEL %d", (g_ClassLevel[id][classId] >= (i - 1)) ? "\w" : "\d", (i - 1));
		
		num_to_str(i, sPosition, 1);
		
		menu_additem(iMenu, sItem, sPosition);
	}
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public __checkClass(const id, const menuId, const item) {
	if(g_Menu_ClassId[id] == CLASS_PISTOLERO) {
		if(!g_Achievement[id][PISTOLERO_UNLOCKED]) {
			return ITEM_DISABLED;
		}

		return ITEM_ENABLED;
	}

	if(g_ClassId[id] != g_Menu_ClassId[id] && !g_WaveInProgress) {
		if(g_Class_Soporte_Bonus[id] && (g_Gold[id] - 200) < 0) {
			return ITEM_DISABLED;
		}
		
		return ITEM_ENABLED;
	}
	
	return ITEM_DISABLED;
}

public menu__ClassesINFO(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Classes(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	DestroyLocalMenu(id, menuId);
	
	if(iItem > 0) {
		showMenu__ClassesINFO_LEVELS(id, iItem - 1);
	} else {
		if(g_WaveInProgress) {
			colorChat(id, _, "%sNo podés utilizar esta opción cuando hay una oleada en marcha.", TD_PREFIX);
			return PLUGIN_HANDLED;
		}
		
		switch(g_ClassId[id]) {
			case CLASS_SOPORTE: {
				if(g_ClassLevel[id][g_ClassId[id]] >= 1) {
					if(user_has_weapon(id, CSW_XM1014)) {
						new iWeaponId = fm_find_ent_by_owner(-1, "weapon_xm1014", id);
						new iClip = clamp((cs_get_weapon_ammo(iWeaponId) - CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]), 0, 200);
						
						if(g_HabCacheClip[id] && iClip) {
							new iExtraClip = DEFAULT_MAXCLIP[CSW_XM1014];
							iExtraClip = ((iExtraClip * g_HabCacheClip[id]) / 100);
							
							if(iClip > (DEFAULT_MAXCLIP[CSW_XM1014] + iExtraClip)) {
								iClip = DEFAULT_MAXCLIP[CSW_XM1014] + iExtraClip;
							}
						}
						
						cs_set_weapon_ammo(iWeaponId, iClip);
					}
				}
			} case CLASS_SOLDADO: {
				if(g_ClassLevel[id][g_ClassId[id]] >= 4) {
					if(user_has_weapon(id, CSW_M4A1)) {
						new iWeaponId = fm_find_ent_by_owner(-1, "weapon_m4a1", id);
						new iClip = clamp((cs_get_weapon_ammo(iWeaponId) - CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]), 0, 200);
						
						if(g_HabCacheClip[id] && iClip) {
							new iExtraClip = DEFAULT_MAXCLIP[CSW_M4A1];
							iExtraClip = ((iExtraClip * g_HabCacheClip[id]) / 100);
							
							if(iClip > (DEFAULT_MAXCLIP[CSW_M4A1] + iExtraClip)) {
								iClip = DEFAULT_MAXCLIP[CSW_M4A1] + iExtraClip;
							}
						}
						
						cs_set_weapon_ammo(iWeaponId, iClip);
					}
					
					if(user_has_weapon(id, CSW_AK47)) {
						new iWeaponId = fm_find_ent_by_owner(-1, "weapon_ak47", id);
						new iClip = clamp((cs_get_weapon_ammo(iWeaponId) - CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]), 0, 200);
						
						if(g_HabCacheClip[id] && iClip) {
							new iExtraClip = DEFAULT_MAXCLIP[CSW_AK47];
							iExtraClip = ((iExtraClip * g_HabCacheClip[id]) / 100);
							
							if(iClip > (DEFAULT_MAXCLIP[CSW_AK47] + iExtraClip)) {
								iClip = DEFAULT_MAXCLIP[CSW_AK47] + iExtraClip;
							}
						}
						
						cs_set_weapon_ammo(iWeaponId, iClip);
					}
				}
			} case CLASS_PUBERO: {
				if(g_ClassLevel[id][g_ClassId[id]] >= 4) {
					if(user_has_weapon(id, CSW_SG550)) {
						new iWeaponId = fm_find_ent_by_owner(-1, "weapon_sg550", id);
						new iClip = clamp((cs_get_weapon_ammo(iWeaponId) - CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]), 0, 200);
						
						if(g_HabCacheClip[id] && iClip) {
							new iExtraClip = DEFAULT_MAXCLIP[CSW_SG550];
							iExtraClip = ((iExtraClip * g_HabCacheClip[id]) / 100);
							
							if(iClip > (DEFAULT_MAXCLIP[CSW_SG550] + iExtraClip)) {
								iClip = DEFAULT_MAXCLIP[CSW_SG550] + iExtraClip;
							}
						}
						
						cs_set_weapon_ammo(iWeaponId, iClip);
					}
					
					if(user_has_weapon(id, CSW_G3SG1)) {
						new iWeaponId = fm_find_ent_by_owner(-1, "weapon_g3sg1", id);
						new iClip = clamp((cs_get_weapon_ammo(iWeaponId) - CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]), 0, 200);
						
						if(g_HabCacheClip[id] && iClip) {
							new iExtraClip = DEFAULT_MAXCLIP[CSW_G3SG1];
							iExtraClip = ((iExtraClip * g_HabCacheClip[id]) / 100);
							
							if(iClip > (DEFAULT_MAXCLIP[CSW_G3SG1] + iExtraClip)) {
								iClip = DEFAULT_MAXCLIP[CSW_G3SG1] + iExtraClip;
							}
						}
						
						cs_set_weapon_ammo(iWeaponId, iClip);
					}
				}
			} case CLASS_SCOUTER: {
				if(g_ClassLevel[id][g_ClassId[id]] >= 4) {
					if(user_has_weapon(id, CSW_SCOUT)) {
						new iWeaponId = fm_find_ent_by_owner(-1, "weapon_scout", id);
						new iClip = clamp((cs_get_weapon_ammo(iWeaponId) - CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]), 0, 200);
						
						if(g_HabCacheClip[id] && iClip) {
							new iExtraClip = DEFAULT_MAXCLIP[CSW_SCOUT];
							iExtraClip = ((iExtraClip * g_HabCacheClip[id]) / 100);
							
							if(iClip > (DEFAULT_MAXCLIP[CSW_SCOUT] + iExtraClip)) {
								iClip = DEFAULT_MAXCLIP[CSW_SCOUT] + iExtraClip;
							}
						}
						
						cs_set_weapon_ammo(iWeaponId, iClip);
					}
				}
			}
		}
		
		switch(g_Menu_ClassId[id]) {
			case CLASS_APOYO: {
				if(!g_Upgrades[id][HAB_UNLOCK_APOYO]) {
					colorChat(id, _, "%sNecesitás desbloquear esta clase desde el menú !gmejoras!y para utilizarla!", TD_PREFIX);
					
					showMenu__ClassesINFO(id, g_Menu_ClassId[id]);
					return PLUGIN_HANDLED;
				}
			} case CLASS_PESADO: {
				if(!g_Upgrades[id][HAB_UNLOCK_PESADO]) {
					colorChat(id, _, "%sNecesitás desbloquear esta clase desde el menú !gmejoras!y para utilizarla!", TD_PREFIX);
					
					showMenu__ClassesINFO(id, g_Menu_ClassId[id]);
					return PLUGIN_HANDLED;
				}
			} case CLASS_ASALTO: {
				if(!g_Upgrades[id][HAB_UNLOCK_ASALTO]) {
					colorChat(id, _, "%sNecesitás desbloquear esta clase desde el menú !gmejoras!y para utilizarla!", TD_PREFIX);
					
					showMenu__ClassesINFO(id, g_Menu_ClassId[id]);
					return PLUGIN_HANDLED;
				}
			} case CLASS_COMANDANTE: {
				if(!g_Upgrades[id][HAB_UNLOCK_COMANDANTE]) {
					colorChat(id, _, "%sNecesitás desbloquear esta clase desde el menú !gmejoras!y para utilizarla!", TD_PREFIX);
					
					showMenu__ClassesINFO(id, g_Menu_ClassId[id]);
					return PLUGIN_HANDLED;
				}
			} case CLASS_PISTOLERO: {
				if(!g_Achievement[id][PISTOLERO_UNLOCKED]) {
					colorChat(id, _, "%sNecesitás desbloquear el logro !gPISTOLERO!y para utilizar esta clase!", TD_PREFIX);
					
					showMenu__ClassesINFO(id, g_Menu_ClassId[id]);
					return PLUGIN_HANDLED;
				}
			} case CLASS_PUBERO, CLASS_LEGIONARIO, CLASS_BITERO, CLASS_SCOUTER: {
				if(!g_UserPremium[id]) {
					colorChat(id, _, "%sNecesitás ser usuario premium para utilizar esta clase!", TD_PREFIX);
					
					showMenu__ClassesINFO(id, g_Menu_ClassId[id]);
					return PLUGIN_HANDLED;
				}
			}
		}
		
		g_ClassId[id] = g_Menu_ClassId[id];
		
		colorChat(id, _, "%sTu nueva clase es !g%s!y.", TD_PREFIX, CLASSES[g_ClassId[id]][className]);

		if(g_CurrentWeapon[id] == CSW_AWP) {
			replaceWeaponModels(id, CSW_AWP);
		}
		
		if(g_Class_Soporte_Bonus[id]) {
			g_Class_Soporte_Bonus[id] = 0;
			g_Gold[id] -= 200;
		}
		
		if( (g_ClassId[id] == CLASS_SOLDADO && g_ClassLevel[id][g_ClassId[id]] >= 6) ||
			(g_ClassId[id] == CLASS_INGENIERO && g_ClassLevel[id][g_ClassId[id]] >= 6) ||
			(g_ClassId[id] == CLASS_FRANCOTIRADOR && g_ClassLevel[id][g_ClassId[id]] >= 4) ||
			(g_ClassId[id] == CLASS_PESADO && g_ClassLevel[id][g_ClassId[id]] >= 6) ||
			(g_ClassId[id] == CLASS_ASALTO && g_ClassLevel[id][g_ClassId[id]] >= 6) ||
			(g_ClassId[id] == CLASS_COMANDANTE && g_ClassLevel[id][g_ClassId[id]] >= 6) ||
			(g_ClassId[id] == CLASS_PUBERO && g_ClassLevel[id][g_ClassId[id]] >= 6)) {
			colorChat(id, _, "%sSi comienzas con algún arma o equipo predefinido, se te otorgará cuando empiece la oleada!", TD_PREFIX);
		} else if(g_ClassId[id] == CLASS_SOPORTE && g_ClassLevel[id][g_ClassId[id]] >= 4 && !g_Wave && !g_Class_Soporte_Bonus[id]) {
			g_Class_Soporte_Bonus[id] = 1;
			
			colorChat(id, _, "%sHas recibido !g200 Oro!y por tu clase, si cambias de clase se removerá ese beneficio!", TD_PREFIX);
			
			g_Gold[id] += 200;
		}
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ClassesINFO_LEVELS(const id, const classLevel) {
	new sMenu[400];
	new sReq[15];
	new sHaveReq[15];
	new sReqDesc[86];
	new iClassReq;

	iClassReq = CLASSES[g_Menu_ClassId[id]][classReqLv1 + classLevel];

	if(g_UserPremium[id]) {
		iClassReq = iClassReq - ((iClassReq * 20) / 100);
	}

	addDot(iClassReq, sReq, charsmax(sReq));
	addDot(g_ClassReqs[id][g_Menu_ClassId[id]], sHaveReq, charsmax(sHaveReq));
	
	switch(g_Menu_ClassId[id]) {
		case CLASS_SOLDADO: formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON^nM4A1 o AK47\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_INGENIERO: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO POR TORRETAS\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_SOPORTE: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON XM1014\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_FRANCOTIRADOR: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON AWP\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_APOYO: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON M3 o MP5\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_PESADO: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON M249\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_ASALTO: formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON^nFAMAS o GALIL\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_COMANDANTE: formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON^nAUG o SG-552\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_PISTOLERO: formatex(sReqDesc, charsmax(sReqDesc), "\wDISPAROS ACERTADOS CON DEAGLE\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_PUBERO: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON SG-550 o G3SG1\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_LEGIONARIO: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON P90\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_BITERO: formatex(sReqDesc, charsmax(sReqDesc), "\wMONSTRUOS MATADOS CON^nMAC10 o TMP\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
		case CLASS_SCOUTER: formatex(sReqDesc, charsmax(sReqDesc), "\wDAÑO HECHO CON SCOUT\r:^n\w%s \r/ \y%s", sHaveReq, sReq);
	}
	
	switch(classLevel) {
		case 0: formatex(sMenu, charsmax(sMenu), "\y%s^n\wInformación del \yNIVEL %d^n^n%s^n^n%s^n^n\r0. \wVOLVER", CLASSES[g_Menu_ClassId[id]][className], (classLevel + 1), CLASSES[g_Menu_ClassId[id]][classDescLv1], sReqDesc);
		case 1: formatex(sMenu, charsmax(sMenu), "\y%s^n\wInformación del \yNIVEL %d^n^n%s^n^n%s^n^n\r0. \wVOLVER", CLASSES[g_Menu_ClassId[id]][className], (classLevel + 1), CLASSES[g_Menu_ClassId[id]][classDescLv2], sReqDesc);
		case 2: formatex(sMenu, charsmax(sMenu), "\y%s^n\wInformación del \yNIVEL %d^n^n%s^n^n%s^n^n\r0. \wVOLVER", CLASSES[g_Menu_ClassId[id]][className], (classLevel + 1), CLASSES[g_Menu_ClassId[id]][classDescLv3], sReqDesc);
		case 3: formatex(sMenu, charsmax(sMenu), "\y%s^n\wInformación del \yNIVEL %d^n^n%s^n^n%s^n^n\r0. \wVOLVER", CLASSES[g_Menu_ClassId[id]][className], (classLevel + 1), CLASSES[g_Menu_ClassId[id]][classDescLv4], sReqDesc);
		case 4: formatex(sMenu, charsmax(sMenu), "\y%s^n\wInformación del \yNIVEL %d^n^n%s^n^n%s^n^n\r0. \wVOLVER", CLASSES[g_Menu_ClassId[id]][className], (classLevel + 1), CLASSES[g_Menu_ClassId[id]][classDescLv5], sReqDesc);
		case 5: formatex(sMenu, charsmax(sMenu), "\y%s^n\wInformación del \yNIVEL %d^n^n%s^n^n%s^n^n\r0. \wVOLVER", CLASSES[g_Menu_ClassId[id]][className], (classLevel + 1), CLASSES[g_Menu_ClassId[id]][classDescLv6], sReqDesc);
	}
	
	show_menu(id, KEYSMENU, sMenu, -1, "Info Level Classes");
}

public menu__ClassesINFO_LEVELS(const id, const key) {
	if(key == 9) {
		showMenu__ClassesINFO(id, g_Menu_ClassId[id]);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__RequerimentsLevelG(const id, const levelG) {
	new sMenu[400];
	new sKills[15];
	new sReqKills[15];
	new sMenuExtra[29];
	
	addDot(g_Kills[id], sKills, charsmax(sKills));
	addDot(LEVELS_G[levelG][levelKills], sReqKills, charsmax(sReqKills));
	
	formatex(sMenuExtra, charsmax(sMenuExtra), "^n^n\r1. \wVer otros niveles");
	
	if(levelG < 25) {
		formatex(sMenu, charsmax(sMenu), "\yInformación del \yNIVEL G! \r%d^n^n\r* %sMatados: %s \r/ \y%s^n\r* %sOleadas superadas (NORMAL): %d \r/ \y%d^n\r* %sJefes matados (NORMAL): %d \r/ \y%d%s^n^n\r0. \wVOLVER",
		(levelG + 1), (g_Kills[id] < LEVELS_G[levelG][levelKills]) ? "\d" : "\y", sKills, sReqKills,
		(g_WavesWins[id][DIFF_NORMAL][0] < LEVELS_G[levelG][levelWaveNormal]) ? "\d" : "\y", g_WavesWins[id][DIFF_NORMAL][0], LEVELS_G[levelG][levelWaveNormal],
		(g_BossKills[id][DIFF_NORMAL] < LEVELS_G[levelG][levelBossNormal]) ? "\d" : "\y", g_BossKills[id][DIFF_NORMAL], LEVELS_G[levelG][levelBossNormal], (g_LevelG[id] == levelG) ? sMenuExtra : "");
	} else if(levelG < 50) {
		formatex(sMenu, charsmax(sMenu), "\yInformación del \yNIVEL G! %d^n^n\r* %sMatados: %s \r/ \y%s^n\r* %sOleadas superadas (NIGHTMARE): %d \r/ \y%d^n\r* %sJefes matados (NIGHTMARE): %d \r/ \y%d%s^n^n\r0. \wVOLVER",
		(levelG + 1), (g_Kills[id] < LEVELS_G[levelG][levelKills]) ? "\d" : "\y", sKills, sReqKills,
		(g_WavesWins[id][DIFF_NIGHTMARE][0] < LEVELS_G[levelG][levelWaveNightmare]) ? "\d" : "\y", g_WavesWins[id][DIFF_NIGHTMARE][0], LEVELS_G[levelG][levelWaveNightmare],
		(g_BossKills[id][DIFF_NIGHTMARE] < LEVELS_G[levelG][levelBossNightmare]) ? "\d" : "\y", g_BossKills[id][DIFF_NIGHTMARE], LEVELS_G[levelG][levelBossNightmare], (g_LevelG[id] == levelG) ? sMenuExtra : "");
	} else if(levelG < 75) {
		formatex(sMenu, charsmax(sMenu), "\yInformación del \yNIVEL G! %d^n^n\r* %sMatados: %s \r/ \y%s^n\r* %sOleadas superadas (SUICIDAL): %d \r/ \y%d^n\r* %sJefes matados (SUICIDAL): %d \r/ \y%d%s^n^n\r0. \wVOLVER",
		(levelG + 1), (g_Kills[id] < LEVELS_G[levelG][levelKills]) ? "\d" : "\y", sKills, sReqKills,
		(g_WavesWins[id][DIFF_SUICIDAL][0] < LEVELS_G[levelG][levelWaveSuicidal]) ? "\d" : "\y", g_WavesWins[id][DIFF_SUICIDAL][0], LEVELS_G[levelG][levelWaveSuicidal],
		(g_BossKills[id][DIFF_SUICIDAL] < LEVELS_G[levelG][levelBossSuicidal]) ? "\d" : "\y", g_BossKills[id][DIFF_SUICIDAL], LEVELS_G[levelG][levelBossSuicidal], (g_LevelG[id] == levelG) ? sMenuExtra : "");
	} else {
		formatex(sMenu, charsmax(sMenu), "\yInformación del \yNIVEL G! %d^n^n\r* %sMatados: %s \r/ \y%s^n\r* %sOleadas superadas (HELL): %d \r/ \y%d^n\r* %sJefes matados (HELL): %d \r/ \y%d%s^n^n\r0. \wVOLVER",
		(levelG + 1), (g_Kills[id] < LEVELS_G[levelG][levelKills]) ? "\d" : "\y", sKills, sReqKills,
		(g_WavesWins[id][DIFF_HELL][0] < LEVELS_G[levelG][levelWaveHell]) ? "\d" : "\y", g_WavesWins[id][DIFF_HELL][0], LEVELS_G[levelG][levelWaveHell],
		(g_BossKills[id][DIFF_HELL] < LEVELS_G[levelG][levelBossHell]) ? "\d" : "\y", g_BossKills[id][DIFF_HELL], LEVELS_G[levelG][levelBossHell], (g_LevelG[id] == levelG) ? sMenuExtra : "");
	}
	
	g_MenuPage_LevelG[id] = levelG;
	
	show_menu(id, KEYSMENU, sMenu, -1, "Requeriments Level G");
}

public menu__RequerimentsLevelG(const id, const key) {
	if(key == 0 && g_LevelG[id] == g_MenuPage_LevelG[id]) {
		showMenu__ShowLevelG(id);
	}
	else if(key == 9) {
		if(g_MenuPage_LevelG[id] == g_LevelG[id]) {
			showMenu__Game(id);
		} else {
			showMenu__ShowLevelG(id);
		}
	} else {
		showMenu__RequerimentsLevelG(id, g_MenuPage_LevelG[id]);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ShowLevelG(const id) {
	new iMenuId;
	new sItem[32];
	new sItemId[6];
	new i;
	
	iMenuId = menu_create("\yLISTA DE NIVELES G!\R", "menu__ShowLevelG");
	
	for(i = 0; i < 100; ++i) {
		formatex(sItem, 31, "%sNIVEL %s%d", (g_LevelG[id] > i) ? "\w" : "\d", (g_LevelG[id] > i) ? "\y" : "\r", (i + 1));
		
		num_to_str((i + 1), sItemId, 5);
		
		menu_additem(iMenuId, sItem, sItemId);
	}

	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGUIENTE");
	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");
	
	g_MenuPage_ShowLevelG[id] = min(g_MenuPage_ShowLevelG[id], menu_pages(iMenuId) - 1);
	
	if(!g_MenuPage_ShowLevelG[id]) {
		g_MenuPage_ShowLevelG[id] = g_LevelG[id] / 7;
	}
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenuId, g_MenuPage_ShowLevelG[id]);
}

public menu__ShowLevelG(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	new iNothing;
	player_menu_info(id, iNothing, iNothing, g_MenuPage_ShowLevelG[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__RequerimentsLevelG(id, g_LevelG[id]);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[6];
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	DestroyLocalMenu(id, menuId);
	
	showMenu__RequerimentsLevelG(id, iItem);
	return PLUGIN_HANDLED;
}

public showMenu__Configuration(const id) {
	new iMenu;	
	iMenu = menu_create("CONFIGURACIÓN", "menu__Configuration");
	
	menu_additem(iMenu, "CONFIGURAR HUD", "1");
	menu_additem(iMenu, "CALIDAD / RENDIMIENTO", "2");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__Configuration(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	DestroyLocalMenu(id, menuId);
	
	switch(iItem) {
		case 1: {
			showMenu__ConfigurationHUD(id);
		} case 2: {
			showMenu__LowFPS(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ConfigurationHUD(const id) {
	new iMenu;
	new sItem[90];
	
	iMenu = menu_create("CONFIGURACIÓN HUD", "menu__ConfigurationHUD");
	
	menu_additem(iMenu, "ELEGIR COLOR", "1");
	menu_additem(iMenu, "MOVER EL HUD^n", "2");
	
	formatex(sItem, 89, "%sEFECTO DEL HUD%s^n", (!g_Options_HUD_Effect[id]) ? "\d" : "\w", (!g_Options_HUD_Effect[id]) ? " \r(DESHABILITADO)" : " \y(HABILITADO)");
	menu_additem(iMenu, sItem, "3");
	
	formatex(sItem, 89, "%sMOSTRAR PROGRESO DE NIVEL^nDE TU CLASE ACTUAL%s^n", (!g_Options_HUD_ProgressClass[id]) ? "\d" : "\w", (!g_Options_HUD_ProgressClass[id]) ? " \r(DESHABILITADO)" : " \y(HABILITADO)");
	menu_additem(iMenu, sItem, "4");
	
	formatex(sItem, 89, "%sMOSTRAR MATADOS DE OLEADA ACTUAL%s", (!g_Options_HUD_KillsPerWave[id]) ? "\d" : "\w", (!g_Options_HUD_KillsPerWave[id]) ? " \r(DESHABILITADO)" : " \y(HABILITADO)");
	menu_additem(iMenu, sItem, "5");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__ConfigurationHUD(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Configuration(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	DestroyLocalMenu(id, menuId);
	
	switch(iItem) {
		case 1: showMenu__ConfigHUD_Color(id);
		case 2: showMenu__ConfigHUD_Move(id);
		case 3: {
			if(g_Options_HUD_Color[id][C_RED] == 255 && g_Options_HUD_Color[id][C_GREEN] == 255 && g_Options_HUD_Color[id][C_BLUE] == 255) {
				colorChat(id, _, "%sNo podés habilitar el efecto del HUD si el color del HUD es blanco!", TD_PREFIX);
			} else {
				g_Options_HUD_Effect[id] = !g_Options_HUD_Effect[id];
			}
			
			showMenu__ConfigurationHUD(id);
		}
		case 4: {
			g_Options_HUD_ProgressClass[id] = !g_Options_HUD_ProgressClass[id];
			
			showMenu__ConfigurationHUD(id);
		}
		case 5: {
			g_Options_HUD_KillsPerWave[id] = !g_Options_HUD_KillsPerWave[id];
			
			showMenu__ConfigurationHUD(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__ConfigHUD_Color(const id) {
	new iMenu;
	new sItem[48];
	new sPosition[3];
	new iCheck;
	new i;
	
	iMenu = menu_create("ELIGE EL COLOR DE TU HUD", "menu__ConfigHUD_Color");
	
	for(i = 0; i < sizeof(COLORS); ++i) {
		iCheck = (g_Options_HUD_Color[id][C_RED] == COLORS[i][colorRed] && g_Options_HUD_Color[id][C_GREEN] == COLORS[i][colorGreen] && g_Options_HUD_Color[id][C_BLUE] == COLORS[i][colorBlue]) ? 1 : 0;
		formatex(sItem, 47, "%s%s%s", (!iCheck) ? "\w" : "\d", COLORS[i][colorName], (!iCheck) ? "" : " \y(ACTUAL)");
		
		num_to_str((i + 1), sPosition, 2);
		menu_additem(iMenu, sItem, sPosition);
	}
	
	menu_addblank(iMenu);
	
	menu_additem(iMenu, "ATRÁS", "0");
	
	menu_setprop(iMenu, MPROP_PERPAGE, 0);
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__ConfigHUD_Color(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__ConfigurationHUD(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	DestroyLocalMenu(id, menuId);
	
	if(iItem == -1) {
		return PLUGIN_HANDLED;
	}
	
	g_Options_HUD_Color[id][C_RED] = COLORS[iItem][colorRed];
	g_Options_HUD_Color[id][C_GREEN] = COLORS[iItem][colorGreen];
	g_Options_HUD_Color[id][C_BLUE] = COLORS[iItem][colorBlue];
	
	showMenu__ConfigHUD_Color(id);
	return PLUGIN_HANDLED;
}

public showMenu__ConfigHUD_Move(const id) {
	new iMenu;
	new sItem[48];
	
	iMenu = menu_create("POSICIONA TU HUD", "menu__ConfigHUD_Move");
	
	menu_additem(iMenu, "MOVER HACIA ARRIBA", "1");
	menu_additem(iMenu, "MOVER HACIA ABAJO^n", "2");
	
	menu_additem(iMenu, "MOVER HACIA LA IZQUIERDA", "3", _, menu_makecallback("__checkMoveHUD"));
	menu_additem(iMenu, "MOVER HACIA LA DERECHA^n", "4", _, menu_makecallback("__checkMoveHUD"));
	
	formatex(sItem, 47, "%s^n", (g_Options_HUD_Center[id]) ? "DESCENTRAR HUD^n" : "CENTRAR HUD^n");
	menu_additem(iMenu, sItem, "5");
	
	menu_additem(iMenu, "REINICIAR POSICIÓN", "6");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public __checkMoveHUD(const id) {
	if(!g_Options_HUD_Center[id]) {
		return ITEM_ENABLED;
	}
	
	return ITEM_DISABLED;
}

public menu__ConfigHUD_Move(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__ConfigurationHUD(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	DestroyLocalMenu(id, menuId);
	
	switch(iItem) {
		case 1: {
			g_Options_HUD_Position[id][1] -= 0.01;
		}
		case 2: {
			g_Options_HUD_Position[id][1] += 0.01;
		}
		case 3: {
			g_Options_HUD_Position[id][0] -= 0.01;
			g_Options_HUD_Center[id] = 0;
		}
		case 4: {
			g_Options_HUD_Position[id][0] += 0.01;
			g_Options_HUD_Center[id] = 0;
		}
		case 5: {
			if(g_Options_HUD_Center[id]) {
				g_Options_HUD_Position[id][0] = 0.5;
				g_Options_HUD_Position[id][1] = 0.7;
				g_Options_HUD_Center[id] = 0;
			} else {
				g_Options_HUD_Position[id][0] = -1.0;
				g_Options_HUD_Position[id][1] = 0.7;
				g_Options_HUD_Center[id] = 1;
			}
		}
		case 6: {
			g_Options_HUD_Center[id] = 0;
			g_Options_HUD_Position[id] = Float:{0.02, 0.15};
		}
	}
	
	showMenu__ConfigHUD_Move(id);
	return PLUGIN_HANDLED;
}

public fw_Weapon_PrimaryAttack_Post(const __weaponEnt)
{
	if(!pev_valid(__weaponEnt))
		return HAM_IGNORED;

	static id;
	id = getWeaponEntId(__weaponEnt);

	if(!is_user_valid_alive(id))
		return HAM_IGNORED;

	static iWithCorrectWeapon;
	iWithCorrectWeapon = 0;

	if(g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][1])
		iWithCorrectWeapon = 1;

	if(g_HabCache[id][HAB_F_PRECISION] || g_HabCache[id][HAB_F_VELOCIDAD] || iWithCorrectWeapon)
	{
		if(cs_get_weapon_ammo(__weaponEnt) < 1)
			return HAM_IGNORED;

		if(CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Recoil] || g_HabCache[id][HAB_F_PRECISION])
		{
			static Float:vecRecoil[3];
			static Float:fRecoil;
			
			entity_get_vector(id, EV_VEC_punchangle, vecRecoil);
			fRecoil = g_HabCache[id][HAB_F_PRECISION];

			if(iWithCorrectWeapon)
				fRecoil += floatclamp((CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Recoil]), 0.0, 100.0);

			vecRecoil[0] = vecRecoil[0] - ((vecRecoil[0] * fRecoil) / 100.0);
			vecRecoil[1] = vecRecoil[1] - ((vecRecoil[1] * fRecoil) / 100.0);
			vecRecoil[2] = vecRecoil[2] - ((vecRecoil[2] * fRecoil) / 100.0);
			
			entity_set_vector(id, EV_VEC_punchangle, vecRecoil);
		}

		if(CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Speed] || g_HabCache[id][HAB_F_VELOCIDAD])
		{
			static Float:vecSpeed[3];
			static Float:fSpeed;
			
			vecSpeed[0] = get_pdata_float(__weaponEnt, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS);
			vecSpeed[1] = get_pdata_float(__weaponEnt, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS);
			vecSpeed[2] = get_pdata_float(__weaponEnt, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS);

			fSpeed = g_HabCache[id][HAB_F_VELOCIDAD];

			if(iWithCorrectWeapon)
				fSpeed += CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Speed];

 			vecSpeed[0] = vecSpeed[0] - ((vecSpeed[0] * fSpeed) / 100.0);
			vecSpeed[1] = vecSpeed[1] - ((vecSpeed[1] * fSpeed) / 100.0);
			vecSpeed[2] = vecSpeed[2] - ((vecSpeed[2] * fSpeed) / 100.0);
			
			set_pdata_float(__weaponEnt, OFFSET_NEXT_PRIMARY_ATTACK, vecSpeed[0], OFFSET_LINUX_WEAPONS);
			set_pdata_float(__weaponEnt, OFFSET_NEXT_SECONDARY_ATTACK, vecSpeed[1], OFFSET_LINUX_WEAPONS);
			set_pdata_float(__weaponEnt, OFFSET_TIME_WEAPON_IDLE, vecSpeed[2], OFFSET_LINUX_WEAPONS);
		}
	}

	if(((1<<g_CurrentWeapon[id]) & CSW_SCOUT) && (g_ClassLevel[id][CLASS_SCOUTER] == 6 && g_ClassId[id] == CLASS_SCOUTER) && g_PoderScouter[id] == 1)
	{
		if(cs_get_weapon_ammo(__weaponEnt) < 1)
			return HAM_IGNORED;

		static Float:vecPunchangle[3];
		static Float:fSpeed;

		fSpeed = 0.05;
		vecPunchangle[0] = -5.5;

		set_pdata_float(__weaponEnt, OFFSET_NEXT_PRIMARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
		set_pdata_float(__weaponEnt, OFFSET_NEXT_SECONDARY_ATTACK, fSpeed, OFFSET_LINUX_WEAPONS);
		set_pdata_float(__weaponEnt, OFFSET_TIME_WEAPON_IDLE, fSpeed, OFFSET_LINUX_WEAPONS);

		entity_set_vector(id, EV_VEC_punchangle, vecPunchangle);
		return HAM_IGNORED;
	}

	if(g_PrecisionPerfecta[id])
	{
		if(cs_get_weapon_ammo(__weaponEnt) < 1)
			return HAM_IGNORED;

		static Float:vecRecoil[3];
		entity_get_vector(id, EV_VEC_punchangle, vecRecoil);

		vecRecoil[0] = vecRecoil[0] - ((vecRecoil[0] * 100.0) / 100.0);
		vecRecoil[1] = vecRecoil[1] - ((vecRecoil[1] * 100.0) / 100.0);
		vecRecoil[2] = vecRecoil[2] - ((vecRecoil[2] * 100.0) / 100.0);

		entity_set_vector(id, EV_VEC_punchangle, vecRecoil);
	}

	if(((1<<g_CurrentWeapon[id]) & CSW_DEAGLE) && (g_ClassLevel[id][CLASS_PISTOLERO] == 6 && g_ClassId[id] == CLASS_PISTOLERO))
		g_Pistolero_AutoFire[id] = 1;
	
	return HAM_IGNORED;
}

public fw_Item_AttachToPlayer(const iEnt, const id) {
	if(!pev_valid(iEnt)) {
		return;
	}

	static iWithCorrectWeapon;
	iWithCorrectWeapon = 0;

	if(g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][1]) {
		iWithCorrectWeapon = 1;
	}

	if(g_Hab[id][HAB_BALAS] || iWithCorrectWeapon) {
		if(g_Hab[id][HAB_BALAS] || CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]) {
			if(get_pdata_int(iEnt, OFFSET_KNOWN, OFFSET_LINUX_WEAPONS)) {
				return;
			}
			
			new iWeapon = get_pdata_int(iEnt, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			new iExtraClip = DEFAULT_MAXCLIP[iWeapon];
			new iClassExtraClip = 0;

			if(iWithCorrectWeapon) {
				iClassExtraClip = CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip];
			}

			iExtraClip = iExtraClip + ((iExtraClip * g_HabCacheClip[id]) / 100) + iClassExtraClip;
			
			set_pdata_int(iEnt, OFFSET_CLIPAMMO, iExtraClip, OFFSET_LINUX_WEAPONS);
		}
	}
}

public fw_Item_PostFrame(const iEnt) {
	if(!pev_valid(iEnt)) {
		return;
	}
	
	static id;
	id = getWeaponEntId(iEnt);
	
	if(!is_user_valid_alive(id)) {
		return;
	}

	static iWithCorrectWeapon;
	iWithCorrectWeapon = 0;

	if(g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][1]) {
		iWithCorrectWeapon = 1;
	}
	
	if(g_Hab[id][HAB_BALAS] || iWithCorrectWeapon) {
		if(g_Hab[id][HAB_BALAS] || CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]) {
			static iWeapon;
			iWeapon = get_pdata_int(iEnt, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			
			static iMaxClip;
			static iReload;
			static Float:fNextAttack;
			static iAmmoType;
			static iBPAmmo;
			static iClip;
			static iButton;
			static iExtraClip;
			iExtraClip = 0;

			if(iWithCorrectWeapon) {
				iExtraClip = CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip];
			}

			iMaxClip = DEFAULT_MAXCLIP[iWeapon];
			iMaxClip = iMaxClip + ((iMaxClip * g_HabCacheClip[id]) / 100) + iExtraClip;
			iReload = get_pdata_int(iEnt, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS);
			fNextAttack = get_pdata_float(id, OFFSET_NEXT_ATTACK, OFFSET_LINUX);
			iAmmoType = OFFSET_AMMO_PLAYER_SLOT0 + get_pdata_int(iEnt, OFFSET_PRIMARY_AMMO_TYPE, OFFSET_LINUX_WEAPONS);
			iBPAmmo = get_pdata_int(id, iAmmoType, OFFSET_LINUX);
			iClip = get_pdata_int(iEnt, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
			iButton = entity_get_int(id, EV_INT_button);
			
			if(iReload && fNextAttack <= 0.0) {
				static i;
				i = min(iMaxClip - iClip, iBPAmmo);
				
				set_pdata_int(iEnt, OFFSET_CLIPAMMO, iClip + i, OFFSET_LINUX_WEAPONS);
				set_pdata_int(id, iAmmoType, iBPAmmo - i, OFFSET_LINUX);
				set_pdata_int(iEnt, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);
				
				iReload = 0;
			}
			
			if((iButton & IN_ATTACK && get_pdata_float(iEnt, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0) || (iButton & IN_ATTACK2 && get_pdata_float(iEnt, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0)) {
				return;
			}
			
			if((iButton & IN_RELOAD) && !iReload) {
				if(iClip >= iMaxClip) {
					entity_set_int(id, EV_INT_button, iButton & ~IN_RELOAD);
					
					if(((1 << iWeapon) & WEAPONS_SILENT_BIT_SUM) && !get_pdata_int(iEnt, OFFSET_SILENT, OFFSET_LINUX_WEAPONS)) {
						setAnimation(id, (iWeapon == CSW_USP) ? 8 : 7);
					} else {
						setAnimation(id, 0);
					}
				} else if(iClip == DEFAULT_MAXCLIP[iWeapon]) {
					if(iBPAmmo) {
						set_pdata_float(id, OFFSET_NEXT_ATTACK, DEFAULT_DELAY[iWeapon], OFFSET_LINUX);
						
						if(((1<<iWeapon) & WEAPONS_SILENT_BIT_SUM) && get_pdata_int(iEnt, OFFSET_SILENT, OFFSET_LINUX_WEAPONS)) {
							setAnimation(id, (iWeapon == CSW_USP) ? 5 : 4);
						} else {
							setAnimation(id, DEFAULT_ANIMS[iWeapon]);
						}
						
						set_pdata_int(iEnt, OFFSET_IN_RELOAD, 1, OFFSET_LINUX_WEAPONS);
						set_pdata_float(iEnt, OFFSET_TIME_WEAPON_IDLE, DEFAULT_DELAY[iWeapon] + 0.5, OFFSET_LINUX_WEAPONS);
					}
				}
			}
		}
	}
}

public fw_Shotgun_WeaponIdle(const iEnt) {
	if(!pev_valid(iEnt)) {
		return;
	}
	
	static id;
	id = getWeaponEntId(iEnt);
	
	if(!is_user_valid_alive(id)) {
		return;
	}
		
	if(g_Hab[id][HAB_BALAS] || g_CurrentWeapon[id] == CSW_M3 || g_CurrentWeapon[id] == CSW_XM1014) {
		if(g_Hab[id][HAB_BALAS] || CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]) {
			static iWeapon;
			iWeapon = get_pdata_int(iEnt, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			
			if(get_pdata_float(iEnt, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS) > 0.0) {
				return;
			}
			
			static iClip;
			static iSpecialReload;
			
			iClip = get_pdata_int(iEnt, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
			iSpecialReload = get_pdata_int(iEnt, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS);
			
			if(!iClip && !iSpecialReload) {
				return;
			}
			
			if(iSpecialReload) {
				static iMaxClip;
				static iBPAmmo;
				static iExtraClip;
				iExtraClip = 0;

				if(g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][1]) {
					iExtraClip = CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip];
				}
				
				iMaxClip = DEFAULT_MAXCLIP[iWeapon];
				iMaxClip = iMaxClip + ((iMaxClip * g_HabCacheClip[id]) / 100) + iExtraClip;
				iBPAmmo = get_pdata_int(id, OFFSET_M3_AMMO, OFFSET_LINUX);
				
				if(iClip < iMaxClip && iClip == DEFAULT_MAXCLIP[iWeapon] && iBPAmmo) {
					shotgunReload(iEnt, iWeapon, iMaxClip, iClip, iBPAmmo, id);
					return;
				} else if(iClip == iMaxClip && iClip != DEFAULT_MAXCLIP[iWeapon]) {
					setAnimation(id, 4);
					
					set_pdata_int(iEnt, OFFSET_IN_SPECIAL_RELOAD, 0, OFFSET_LINUX_WEAPONS);
					set_pdata_float(iEnt, OFFSET_TIME_WEAPON_IDLE, 1.5, OFFSET_LINUX_WEAPONS);
				}
			}
		}
	}
}

public fw_Shotgun_PostFrame(const iEnt) {
	if(!pev_valid(iEnt)) {
		return;
	}
	
	static id;
	id = getWeaponEntId(iEnt);
	
	if(!is_user_valid_alive(id)) {
		return;
	}

	if(g_Hab[id][HAB_BALAS] || g_CurrentWeapon[id] == CSW_M3 || g_CurrentWeapon[id] == CSW_XM1014) {
		if(g_Hab[id][HAB_BALAS] || CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip]) {
			static iWeapon;
			iWeapon = get_pdata_int(iEnt, OFFSET_ID, OFFSET_LINUX_WEAPONS);
			
			static iBPAmmo;
			static iClip;
			static iMaxClip;
			static iExtraClip;
			iExtraClip = 0;

			if(g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][1]) {
				iExtraClip = CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip];
			}
			
			iBPAmmo = get_pdata_int(id, OFFSET_M3_AMMO, OFFSET_LINUX);
			iClip = get_pdata_int(iEnt, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
			iMaxClip = DEFAULT_MAXCLIP[iWeapon];
			iMaxClip = iMaxClip + ((iMaxClip * g_HabCacheClip[id]) / 100) + iExtraClip;
			
			if(get_pdata_int(iEnt, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS) && get_pdata_float(id, OFFSET_NEXT_ATTACK, OFFSET_LINUX) <= 0.0) {
				static i;
				i = min((iMaxClip - iClip), iBPAmmo);
				
				set_pdata_int(iEnt, OFFSET_CLIPAMMO, iClip + i, OFFSET_LINUX_WEAPONS);
				set_pdata_int(id, OFFSET_M3_AMMO, iBPAmmo - i, OFFSET_LINUX);
				set_pdata_int(iEnt, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);
				
				return;
			}
			
			static iButton;
			iButton = entity_get_int(id, EV_INT_button);
			
			if(iButton & IN_ATTACK && get_pdata_float(iEnt, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) <= 0.0) {
				return;
			}
			
			if(iButton & IN_RELOAD) {
				if(iClip >= iMaxClip) {
					entity_set_int(id, EV_INT_button, iButton & ~IN_RELOAD);
					set_pdata_float(iEnt, OFFSET_NEXT_PRIMARY_ATTACK, 0.5, OFFSET_LINUX_WEAPONS);
				} else if(iClip == DEFAULT_MAXCLIP[iWeapon] && iBPAmmo) {
					shotgunReload(iEnt, iWeapon, iMaxClip, iClip, iBPAmmo, id);
				}
			}
		}
	}
}

shotgunReload(const iEnt, const iWeapon, const iMaxClip, const iClip, const iBPAmmo, const id) {
	if(iBPAmmo <= 0 || iClip == iMaxClip) {
		return;
	}

	if(get_pdata_int(iEnt, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS) > 0.0) {
		return;
	}

	switch(get_pdata_int(iEnt, OFFSET_IN_SPECIAL_RELOAD, OFFSET_LINUX_WEAPONS)) {
		case 0: {
			setAnimation(id, 5);
			
			set_pdata_int(iEnt, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
			set_pdata_float(id, OFFSET_NEXT_ATTACK, 0.55, OFFSET_LINUX);
			set_pdata_float(iEnt, OFFSET_TIME_WEAPON_IDLE, 0.55, OFFSET_LINUX_WEAPONS);
			set_pdata_float(iEnt, OFFSET_NEXT_PRIMARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);
			set_pdata_float(iEnt, OFFSET_NEXT_SECONDARY_ATTACK, 0.55, OFFSET_LINUX_WEAPONS);
			
			return;
		} case 1: {
			if(get_pdata_float(iEnt, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS) > 0.0)
				return;
			
			setAnimation(id, 3);
			
			emit_sound(id, CHAN_ITEM, (random_num(0, 1)) ? "weapons/reload1.wav" : "weapons/reload3.wav", 1.0, ATTN_NORM, 0, (85 + random_num(0, 0x1f)));
			
			set_pdata_int(iEnt, OFFSET_IN_SPECIAL_RELOAD, 2, OFFSET_LINUX_WEAPONS);
			set_pdata_float(iEnt, OFFSET_TIME_WEAPON_IDLE, (iWeapon == CSW_XM1014) ? 0.3 : 0.45, OFFSET_LINUX_WEAPONS);
		} default: {
			set_pdata_int(iEnt, OFFSET_CLIPAMMO, iClip + 1, OFFSET_LINUX_WEAPONS);
			set_pdata_int(id, OFFSET_M3_AMMO, iBPAmmo - 1, OFFSET_LINUX);
			set_pdata_int(iEnt, OFFSET_IN_SPECIAL_RELOAD, 1, OFFSET_LINUX_WEAPONS);
		}
	}
}

stock setAnimation(const id, const animation) {
	entity_set_int(id, EV_INT_weaponanim, animation);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id);
	write_byte(animation);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

public showMenu__ChooseDifficulty(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	if(!g_AccountLogged[id]) {
		return;
	}
	
	static iMenu;
	iMenu = menu_create("SELECCIONA UNA DIFICULTAD", "menu__ChooseDifficulty");
	
	if(g_Wave) {
		menu_additem(iMenu, "NORMAL", "1");
		menu_additem(iMenu, "NIGHTMARE", "2");
		menu_additem(iMenu, "SUICIDAL", "3");
		menu_additem(iMenu, "HELL^n", "4");
	} else {
		static i;
		static iNormal;
		static iNightmare;
		static iSuicidal;
		static iHell;
		static sText[32];
		
		iNormal = 0;
		iNightmare = 0;
		iSuicidal = 0;
		iHell = 0;
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}
			
			if(!g_AccountLogged[i]) {
				continue;
			}
			
			switch(g_VoteDifficulty[i]) {
				case DIFF_NORMAL: ++iNormal;
				case DIFF_NIGHTMARE: ++iNightmare;
				case DIFF_SUICIDAL: ++iSuicidal;
				case DIFF_HELL: ++iHell;
			}
		}
		
		formatex(sText, 31, "NORMAL \y(%d voto%s)", iNormal, (iNormal != 1) ? "s" : "");
		menu_additem(iMenu, sText, "1");
		formatex(sText, 31, "NIGHTMARE \y(%d voto%s)", iNightmare, (iNightmare != 1) ? "s" : "");
		menu_additem(iMenu, sText, "2");
		formatex(sText, 31, "SUICIDAL \y(%d voto%s)", iSuicidal, (iSuicidal != 1) ? "s" : "");
		menu_additem(iMenu, sText, "3");
		formatex(sText, 31, "HELL \y(%d voto%s)^n", iHell, (iHell != 1) ? "s" : "");
		menu_additem(iMenu, sText, "4");
	}

	menu_additem(iMenu, "DIFICULTADES FAVORITAS", "5");

	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__ChooseDifficulty(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	DestroyLocalMenu(id, menuId);

	if(iItem != 4) {
		showMenu__DifficultyINFO(id, iItem);
		g_Menu_Difficulty[id] = iItem;
	} else {
		showMenu__FavoriteDifficults(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__Habilities(const id) {
	new sMenu[325];
	
	formatex(sMenu, charsmax(sMenu), "\yHABILIDADES^n\wPUNTOS: \y%d^n^n\r1.\w DAÑO \y(%d / 50)^n\r2.\w PRECISIÓN AL DISPARAR \y(%d / 20)^n\r3.\w VELOCIDAD AL DISPARAR \y(%d / 20)^n\r4.\w BALAS \y(%d / 10)^n^n\r5.\w AUMENTAR DE A \y%d\w PUNTO%s^n\r6.\w REINICIAR^n^n\r0. \wVOLVER",
	g_Points[id], g_Hab[id][HAB_DAMAGE], g_Hab[id][HAB_PRECISION], g_Hab[id][HAB_VELOCIDAD], g_Hab[id][HAB_BALAS], g_Menu_HabsPoints[id], (g_Menu_HabsPoints[id] == 1) ? "" : "S");
	
	show_menu(id, KEYSMENU, sMenu, -1, "Menu Habilities");
}

public menu__Habilities(const id, const key) {
	if(key < 4) {
		showMenu__InfoHabilities(id, key);
	} else if(key == 4) {
		switch(g_Menu_HabsPoints[id]) {
			case 1: g_Menu_HabsPoints[id] = 5;
			case 5: g_Menu_HabsPoints[id] = 10;
			case 10: g_Menu_HabsPoints[id] = 1;
		}
		
		showMenu__Habilities(id);
	} else if(key == 5) {
		if(g_WaveInProgress) {
			colorChat(id, _, "%sNo podés reiniciar tus habilidades mientras hay una oleada en marcha!", TD_PREFIX);
			
			showMenu__Habilities(id);
			return PLUGIN_HANDLED;
		}
		
		new iReturn;
		iReturn = g_Hab[id][HAB_DAMAGE] + g_Hab[id][HAB_PRECISION] + g_Hab[id][HAB_VELOCIDAD] + g_Hab[id][HAB_BALAS];
		
		if(iReturn) {
			new iFix = 0;
			
			g_Hab[id][HAB_DAMAGE] = 0;
			g_Hab[id][HAB_PRECISION] = 0;
			g_Hab[id][HAB_VELOCIDAD] = 0;
			
			if(g_Hab[id][HAB_BALAS]) {
				iFix = 1;
			}
			
			g_Hab[id][HAB_BALAS] = 0;
			
			g_HabCache[id][_:HAB_F_DAMAGE] = 0.0;
			g_HabCache[id][_:HAB_F_PRECISION] = 0.0;
			g_HabCache[id][_:HAB_F_VELOCIDAD] = 0.0;
			g_HabCacheClip[id] = 0;
			
			g_Points[id] += iReturn;
			
			if(iFix) {
				new iExtraClip;				
				new i;
				new iWeaponId;
				
				for(i = 0; i < sizeof(WEAPON_NAMES); ++i) {
					if(user_has_weapon(id, WEAPON_NAMES[i][weaponId])) {
						iExtraClip = DEFAULT_MAXCLIP[WEAPON_NAMES[i][weaponId]];
						
						if(g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][0] || g_CurrentWeapon[id] == CLASSES_WEAPONS[g_ClassId[id]][1]) {
							iExtraClip += CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Clip];
						}
						
						iWeaponId = fm_find_ent_by_owner(-1, WEAPON_NAMES[i][weaponEnt], id);
						
						cs_set_weapon_ammo(iWeaponId, iExtraClip);
					}
				}
			}
			
			showMenu__Habilities(id);
		} else {
			colorChat(id, _, "%sTus habilidades ya están reiniciadas!", TD_PREFIX);
			showMenu__Habilities(id);
		}
	} else if(key == 9) {
		showMenu__Game(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__InfoHabilities(const id, const habId) {
	new sMenu[470];
	
	formatex(sMenu, charsmax(sMenu), "\y%s (%d / %d)^n\wPUNTOS: \y%d^n^n%s^n^n\r*\y +%0.2f%% \wPOR NIVEL^n\r* \wACTUAL: \y+%0.2f%%^n^n\r1.\w SUBIR HABILIDAD^n\r2.\w AUMENTAR DE A \y%d\w PUNTO%s^n^n\r0. \wVOLVER",
	HABILITIES[habId][habName], g_Hab[id][habId], HABILITIES[habId][habMaxLevel], g_Points[id], HABILITIES[habId][habDesc], HABILITIES[habId][habValue], (float(g_Hab[id][habId]) * HABILITIES[habId][habValue]),
	g_Menu_HabsPoints[id], (g_Menu_HabsPoints[id] == 1) ? "" : "S");
	
	g_MenuPage_Habilities[id] = habId;
	
	show_menu(id, KEYSMENU, sMenu, -1, "Info Habilities");
}

public menu__InfoHabilities(const id, const key) {
	if(key == 0) {
		if(g_WaveInProgress) {
			colorChat(id, _, "%sNo podés subir tus habilidades mientras hay una oleada en marcha!", TD_PREFIX);
			
			showMenu__InfoHabilities(id, g_MenuPage_Habilities[id]);
			return PLUGIN_HANDLED;
		}
		
		if((g_Points[id] - g_Menu_HabsPoints[id]) >= 0) {
			if((g_Hab[id][g_MenuPage_Habilities[id]] + g_Menu_HabsPoints[id]) <= HABILITIES[g_MenuPage_Habilities[id]][habMaxLevel]) {
				g_Hab[id][g_MenuPage_Habilities[id]] += g_Menu_HabsPoints[id];
				g_Points[id] -= g_Menu_HabsPoints[id];
				
				g_HabCache[id][_:HAB_F_DAMAGE] = float(g_Hab[id][HAB_DAMAGE]) * HABILITIES[HAB_DAMAGE][habValue];
				g_HabCache[id][_:HAB_F_PRECISION] = float(g_Hab[id][HAB_PRECISION]) * HABILITIES[HAB_PRECISION][habValue];
				g_HabCache[id][_:HAB_F_VELOCIDAD] = float(g_Hab[id][HAB_VELOCIDAD]) * HABILITIES[HAB_VELOCIDAD][habValue];
				g_HabCacheClip[id] = g_Hab[id][HAB_BALAS] * 10;
			} else {
				colorChat(id, _, "%sLa suma de los puntos invertidos en esta habilidad superarían el límite, reduce la cantidad de puntos!", TD_PREFIX);
			}
		} else {
			colorChat(id, _, "%sNo tenés suficientes puntos!", TD_PREFIX);
		}
	}
	else if(key == 1) {
		switch(g_Menu_HabsPoints[id]) {
			case 1: g_Menu_HabsPoints[id] = 5;
			case 5: g_Menu_HabsPoints[id] = 10;
			case 10: g_Menu_HabsPoints[id] = 1;
		}
	} else if(key == 9) {
		showMenu__Habilities(id);
		return PLUGIN_HANDLED;
	}
	
	showMenu__InfoHabilities(id, g_MenuPage_Habilities[id]);
	return PLUGIN_HANDLED;
}

public showMenu__AchievementsClass(const id) {
	new sPosition[3];
	new iMenuId;
	new i;
	
	iMenuId = menu_create("LOGROS", "menu__AchievementsClass");
	
	for(i = 0; i < LOGRO_CLASS_MAX; ++i) {
		num_to_str((i + 1), sPosition, 2);
		menu_additem(iMenuId, LOGROS_CLASS[i], sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGUIENTE");
	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");
	
	ShowLocalMenu(id, iMenuId, 0);
}

public menu__AchievementsClass(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	DestroyLocalMenu(id, menuId);
	
	showMenu__Achievements(id, str_to_num(sBuffer) - 1);
	
	return PLUGIN_HANDLED;
}

public showMenu__Achievements(const id, const achievementClass) {
	new sItem[64];
	new sPosition[4];
	new iMenuId;
	new i;
	new j = 0;
	new k = 0;
	
	formatex(sItem, charsmax(sItem), "LOGROS %s", LOGROS_CLASS_IN[achievementClass]);
	iMenuId = menu_create(sItem, "menu__Achievements");
	
	for(i = 0; i < LogrosInt; ++i) {
		if(achievementClass != LOGROS[i][logroClass]) {
			++k;
			continue;
		}
		
		++j;
		
		g_AchievementInt[id][i - k] = i;
		
		num_to_str(j, sPosition, 3);
		
		formatex(sItem, charsmax(sItem), "%s%s", (!g_Achievement[id][i]) ? "\d" : "\w", LOGROS[i][logroName]);
		menu_additem(iMenuId, sItem, sPosition);
	}
	
	menu_setprop(iMenuId, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenuId, MPROP_NEXTNAME, "PÁG. SIGUIENTE");
	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");

	g_MenuPage[id][LOGRO_CLASS_MAX] = achievementClass;
	g_MenuPage[id][achievementClass] = min(g_MenuPage[id][achievementClass], menu_pages(iMenuId) - 1);
	
	ShowLocalMenu(id, iMenuId, g_MenuPage[id][achievementClass]);
}

public menu__Achievements(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	new iNothing;
	new iAchievement = g_MenuPage[id][LOGRO_CLASS_MAX];
	
	player_menu_info(id, iNothing, iNothing, g_MenuPage[id][iAchievement]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__AchievementsClass(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[4];
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	
	DestroyLocalMenu(id, menuId);
	
	g_MenuPage[id][LOGRO_CLASS_MAX + 1] = str_to_num(sBuffer) - 1;
	
	showMenu__AchievementDesc(id, g_AchievementInt[id][g_MenuPage[id][LOGRO_CLASS_MAX + 1]]);
	return PLUGIN_HANDLED;
}

public showMenu__AchievementDesc(const id, const achievementId) {
	static sItem[320];
	static sAchievementUnlock[60];
	static sUsersNeed[52];
	static sAchievementReward[52];
	static iMenuId;
	
	if(g_Achievement[id][achievementId]) {
		formatex(sAchievementUnlock, 59, "^n\wLOGRO DESBLOQUEADO EL^n\y%s", getUnixToTime(g_AchievementUnlock[id][achievementId]));
	}
	
	if(LOGROS[achievementId][logroUsersNeed]) {
		formatex(sUsersNeed, 51, "\rREQUISITOS EXTRAS:\w %d usuarios conectados^n", LOGROS[achievementId][logroUsersNeed]);
    }
	
	switch(LOGROS[achievementId][logroReward]) {
		case 1337: {
			formatex(sAchievementReward, 51, "\r    -\w Desbloquea el poder \yBalas Infinitas");
		} case 1338: {
			formatex(sAchievementReward, 51, "\r    -\w Desbloquea el poder \yAimbot");
		} case 1339: {
			formatex(sAchievementReward, 51, "\r    -\w Desbloquea la clase \yPistolero");
		} default: {
			formatex(sAchievementReward, 51, "\r    -\w %d \yOs", LOGROS[achievementId][logroReward]);
		}
	}
	
	formatex(sItem, charsmax(sItem), "%s %s^n^n\yDESCRIPCIÓN:^n\w%s^n%s^n\yRECOMPENSA:^n%s", LOGROS[achievementId][logroName], (!g_Achievement[id][achievementId]) ? "\r(BLOQUEADO)" : "\y(DESBLOQUEADO)", LOGROS[achievementId][logroDesc],
	(!LOGROS[achievementId][logroUsersNeed]) ? "" : sUsersNeed, sAchievementReward);
	
	iMenuId = menu_create(sItem, "menu__AchievementDesc");
	
	if(g_Achievement[id][achievementId]) {
		menu_additem(iMenuId, "MOSTRAR EN EL CHAT", "1");
		menu_addtext(iMenuId, sAchievementUnlock, 1);
	} else {
		menu_additem(iMenuId, "\dMOSTRAR EN EL CHAT", "1");
	}
	
	menu_setprop(iMenuId, MPROP_EXITNAME, "VOLVER");
	
	ShowLocalMenu(id, iMenuId);
}

public menu__AchievementDesc(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	new iAchievement = g_MenuPage[id][LOGRO_CLASS_MAX + 1];
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Achievements(id, g_MenuPage[id][LOGRO_CLASS_MAX]);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[4];
	new iNothing;
	new iItemId;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	DestroyLocalMenu(id, menuId);
	
	iItemId = str_to_num(sBuffer);
	
	if(iItemId == 1 && g_Achievement[id][g_AchievementInt[id][iAchievement]]) {
		if(g_AchievementLink[id] > get_gametime() && !g_Kiske[id]) {
			showMenu__AchievementDesc(id, g_AchievementInt[id][iAchievement]);
			return PLUGIN_HANDLED;
		}
		
		g_AchievementLink[id] = get_gametime() + 15.0;
		colorChat(0, CT, "%s!t%s!y está mostrando que ganó el logro !g%s!y el !t%s!y", TD_PREFIX, g_UserName[id], LOGROS[g_AchievementInt[id][iAchievement]][logroName], getUnixToTime(g_AchievementUnlock[id][g_AchievementInt[id][iAchievement]]));
	}
	
	showMenu__AchievementDesc(id, g_AchievementInt[id][iAchievement]);
	return PLUGIN_HANDLED;
}

public showMenu__DifficultyINFO(const id, const difficulty) {
	new sMenu[500];
	
	formatex(sMenu, charsmax(sMenu), "\y%s\w^n^n%s^n^n\r1.%s VOTAR ESTA DIFICULTAD^n^n\r0. \wVOLVER", DIFFICULTIES[difficulty][difficultyName], DIFFICULTIES[difficulty][difficultyDesc], (g_EndVote /*|| !__checkVoteDiff(id, difficulty)*/) ? "\d" : "\w");
	
	show_menu(id, KEYSMENU, sMenu, -1, "Info Difficulty");
}

// public __checkVoteDiff(const id, const difficulty) {
	// if(difficulty < g_BlockDiff) {
		// return 0;
	// }
	
	// switch(difficulty) {
		// case DIFF_NORMAL: return 1;
		// case DIFF_NIGHTMARE: return 1;
		// case DIFF_SUICIDAL: {
			// if(g_LevelG[id] < 10) {
				// return 0;
			// }
		// }
		// case DIFF_HELL: {
			// if(g_LevelG[id] < 25) {
				// return 0;
			// }
		// }
	// }
	
	// return 1;
// }

public menu__DifficultyINFO(const id, const key) {
	if(key == 0) {
		if(g_EndVote) {
			showMenu__ChooseDifficulty(id);
		} else {
			if(g_Menu_Difficulty[id] < g_BlockDiff) {
				colorChat(id, CT, "%sEsta dificultad no se puede jugar en este mapa!", TD_PREFIX);
				showMenu__ChooseDifficulty(id);
				
				return PLUGIN_HANDLED;
			}
			
			// if(!__checkVoteDiff(id, g_Menu_Difficulty[id])) {
				// colorChat(id, CT, "%sNecesitás un !tNIVEL G!!y más alto para votar esta dificultad!", TD_PREFIX);
				// showMenu__ChooseDifficulty(id);
				
				// return PLUGIN_HANDLED;
			// }
			
			g_VoteDifficulty[id] = g_Menu_Difficulty[id];
		}
	} else {
		showMenu__ChooseDifficulty(id);
	}
	
	return PLUGIN_HANDLED;
}

public __endVote_Difficulty() {
	new i;
	new iNormal = 0;
	new iNightmare = 0;
	new iSuicidal = 0;
	new iHell = 0;
	new iMax;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i))
			continue;
		
		if(!g_AccountLogged[i])
			continue;
		
		switch(g_VoteDifficulty[i]) {
			case DIFF_NORMAL: ++iNormal;
			case DIFF_NIGHTMARE: ++iNightmare;
			case DIFF_SUICIDAL: ++iSuicidal;
			case DIFF_HELL: ++iHell;
		}
	}
	
	if((iNormal + iNightmare + iSuicidal + iHell) < 1) {
		return;
	}
	
	g_EndVote = 1;
	
	new iDifficultyWin = DIFF_NORMAL;
	
	if(iNormal > iMax) {
		iMax = iNormal;
		iDifficultyWin = DIFF_NORMAL;
	}
	
	if(iNightmare > iMax) {
		iMax = iNightmare;
		iDifficultyWin = DIFF_NIGHTMARE;
	}
	
	if(iSuicidal > iMax) {
		iMax = iSuicidal;
		iDifficultyWin = DIFF_SUICIDAL;
	}
	
	if(iHell > iMax) {
		iMax = iHell;
		iDifficultyWin = DIFF_HELL;
	}
	
	g_Difficulty = iDifficultyWin;
	
	colorChat(0, CT, "%s!tVotación finalizada!", TD_PREFIX);
	colorChat(0, TERRORIST, "%sLa dificultad ganadora es !t%s!y con !g%d voto%s!y", TD_PREFIX, DIFFICULTIES[g_Difficulty][difficultyName], iMax, (iMax != 1) ? "s" : "");
	
	new iDiv;
	iDiv = (20 * DIFFICULTIES_VALUES[g_Difficulty][difficultyGold]) / 100;
	
	g_DamageNeedToGold = (225 + (100 * g_Difficulty)) / iDiv;
	
	g_MaxHealth = 100000;
	
	switch(g_Difficulty) {
		case DIFF_NORMAL: g_MaxHealth = 750;
		case DIFF_NIGHTMARE: g_MaxHealth = 1250;
	}
}

public __AutoJoinToSpec(const sArgs[1], const id) {
	if(!is_user_connected(id))
		return;
	
	new iMsgBlock = get_msg_block(sArgs[0]);
	set_msg_block(sArgs[0], BLOCK_SET);
	
	g_AllowChangeTeam[id] = 1;
	
	set_pdata_int(id, 125, (get_pdata_int(id, 125, OFFSET_LINUX) & ~(1<<8)), OFFSET_LINUX);
	engclient_cmd(id, "jointeam", "6");
	
	g_AllowChangeTeam[id] = 0;
	
	set_msg_block(sArgs[0], iMsgBlock);
}

public loadMaps() {
	/*new sFile[64];
	get_cvar_string("mapcyclefile", sFile, charsmax(sFile));
	
	if(!file_exists(sFile))
		return;
	
	new sText[64];
	new sBuffer[256];
	
	new iFile = fopen(sFile, "r");
	
	while(!feof(iFile)) {
		sBuffer[0] = EOS;
		
		fgets(iFile, sBuffer, charsmax(sBuffer));
		parse(sBuffer, sText, charsmax(sText));
		
		if(sText[0] != ';' && validMap(sText)) {
			ArrayPushString(g_Array_MapName, sText);
			++g_MapsNum;
		}
	}
	
	fclose(iFile);*/

	new i;
	for(i = 0; i < mapsIds; ++i) {
		if(validMap(MAPS_DESC[i][mapName])) {
			ArrayPushString(g_Array_MapName, MAPS_DESC[i][mapName]);
			++g_MapsNum;
		}
	}
}

stock validMap(mapname[]) {
	if(is_map_valid(mapname)) {
		return 1;
	}
	
	new iLen = strlen(mapname) - 4;
	
	if(iLen < 0) {
		return 0;
	}
	
	if(equali(mapname[iLen], ".bsp")) {
		mapname[iLen] = EOS;
		
		if(is_map_valid(mapname)) {
			return 1;
		}
	}
	
	return 0;
}

public __VoteMap() {	
	// client_cmd(0, "spk gman/gman_choose1");
	
	g_VoteMap = 1;
	g_MapMenu_TimeLeft = 15;
	g_MapMenu_Maxvotes = 0;

	new i;
	for(i = 0; i < 128; ++i) {
		g_MapMenu_Votes[i] = 0;
	}

	for(i = 1; i <= g_MaxUsers; ++i) {
		g_VoteMap_MapVoted[i] = -1;
	}

	showMenu__VoteMap(0);
	
	set_task(1.0, "__UpdateVoteMap");
}

public __UpdateVoteMap() {
	--g_MapMenu_TimeLeft;

	if(!g_MapMenu_TimeLeft) {
		__FinishVoteMap();
		return;
	}

	if(g_MapsNum == 2) {
		showMenu__VoteMap(0);
	}

	set_task(1.0, "__UpdateVoteMap");
}

public showMenu__VoteMap(const id) {
	new sItem[48];
	new sPosition[4];
	new iMenu;
	new i;
	new iPercent;
	
	if(g_MapsNum > 2) {
		formatex(sItem, charsmax(sItem), "VOTACIÓN DE MAPAS\R");
	} else {
		formatex(sItem, charsmax(sItem), "VOTACIÓN DE MAPAS - %d\R", g_MapMenu_TimeLeft);
	}

	iMenu = menu_create(sItem, "menu__VoteMap");
	
	for(i = 0; i < g_MapsNum; ++i) {
		num_to_str((i + 1), sPosition, 3);
		
		if(g_MapMenu_Maxvotes > 0 && g_MapMenu_Votes[i] > 0 && g_MapsNum == 2) {
			iPercent = (g_MapMenu_Votes[i] * 100) / g_MapMenu_Maxvotes;
			formatex(sItem, charsmax(sItem), "%a%s \y(%d%%)", ArrayGetStringHandle(g_Array_MapName, i), MAPS_DESC[i][mapDesc], iPercent);
		} else {
			formatex(sItem, charsmax(sItem), "%a%s", ArrayGetStringHandle(g_Array_MapName, i), MAPS_DESC[i][mapDesc]);
		}
		
		menu_additem(iMenu, sItem, sPosition);
	}
	
	menu_setprop(iMenu, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenu, MPROP_NEXTNAME, "PÁG. SIGUIENTE");
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER);
	
	if(!id) {
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}
			
			if(!g_AccountLogged[i]) {
				continue;
			}

			menu_display(i, iMenu);
		}
	} else {
		menu_display(id, iMenu);
	}
}

public menu__VoteMap(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;

	if(g_VoteMap_MapVoted[id] != -1) {
		--g_MapMenu_Votes[g_VoteMap_MapVoted[id]];
	} else {
		++g_MapMenu_Maxvotes;
	}

	g_VoteMap_MapVoted[id] = iItem;
	++g_MapMenu_Votes[iItem];
	
	if(g_MapsNum == 2) {
		showMenu__VoteMap(id);
	}

	return PLUGIN_HANDLED;
}

public __FinishVoteMap() {
	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i))
			continue;
		
		if(!g_AccountLogged[i])
			continue;
		
		message_begin(MSG_ONE, g_Message_ShowMenu, .player=i);
		{
			write_short(0);
			write_char(0);
			write_byte(0);
			write_string("");
		}
		message_end();
	}

	new iMaxVote = 0;
	new iMaxItemVote = -1;
	
	for(i = 0; i < g_MapsNum; ++i) {
		if(g_MapMenu_Votes[i] > iMaxVote) {
			iMaxVote = g_MapMenu_Votes[i];
			iMaxItemVote = i;
		}
	}
	
	if(iMaxItemVote >= 0) {
		new iPercent = (g_MapMenu_Votes[iMaxItemVote] * 100) / g_MapMenu_Maxvotes;

		if(iPercent >= 50) {
			colorChat(0, CT, "%sEl mapa ganador es !g%a!y con !t%d%%!y de los votos!", TD_PREFIX, ArrayGetStringHandle(g_Array_MapName, iMaxItemVote), iPercent);

			message_begin(MSG_ALL, SVC_INTERMISSION);
			message_end();
			
			set_task(5.0, "__ChangeMap", iMaxItemVote);
		} else {
			for(i = 1; i <= g_MaxUsers; ++i) {
				g_VoteMap_MapVoted[i] = -1;
			}

			ArrayClear(g_Array_MapName);

			new iWinnerMap = iMaxItemVote;
			iMaxVote = 0;

			for(i = 0; i < g_MapsNum; ++i) {
				if(i == iWinnerMap) {
					continue;
				}

				if(g_MapMenu_Votes[i] > iMaxVote) {
					iMaxVote = g_MapMenu_Votes[i];
					iMaxItemVote = i;
				}
			}

			ArrayPushString(g_Array_MapName, MAPS_DESC[iWinnerMap][mapName]);
			ArrayPushString(g_Array_MapName, MAPS_DESC[iMaxItemVote][mapName]);

			g_MapsNum = 2;

			colorChat(0, CT, "%sNingún mapa obtuvo mayoría de votos, siguiente votación en cinco segundos!", TD_PREFIX);

			set_task(6.0, "__VoteMap");
		}
	} else {
		new iRandomMap = random_num(0, mapsIds-1);
		colorChat(0, CT, "%sNingún mapa fue votado y se eligió uno al azar: !g%s!y", TD_PREFIX, MAPS_DESC[iRandomMap][mapName]);

		message_begin(MSG_ALL, SVC_INTERMISSION);
		message_end();
		
		set_task(5.0, "__ChangeMap", iRandomMap);
	}
}

public __ChangeMap(const mapId) {
	if(mapId >= 0) {
		server_cmd("changelevel %a", ArrayGetStringHandle(g_Array_MapName, mapId));
	} else {
		server_cmd("changelevel td_kmid_v2");
	}
}

public __moveView() {
	new sText[40];
	formatex(sText, charsmax(sText), "addons/amxmodx/configs/view_tower.ini");
	
	if(!file_exists(sText))	{
		write_file(sText, "; MAPA <X Y Z ANGLES>", -1);
		return;
	}
	
	new iFile;
	new sLine[256];
	new sMap[32];
	new sOrigin[3][16];
	new sAngles[3][16];
	new Float:vecAngles[3];
	new iEnt;
	
	iFile = fopen(sText, "rt");
	
	while(!feof(iFile))	{
		fgets(iFile, sLine, charsmax(sLine));
		
		if(!sLine[0] || sLine[0] == ';' || sLine[0] == ' ' || ( sLine[0] == '/' && sLine[1] == '/'))
			continue;
		
		parse(sLine, sMap, 31, sOrigin[0], 15, sOrigin[1], 15, sOrigin[2], 15, sAngles[0], 15, sAngles[1], 15, sAngles[2], 15);
		
		if(equal(sMap, g_MapName)) {
			iEnt = create_entity("info_target");
			
			if(is_valid_ent(iEnt)) {
				g_EntViewTowerFallingOrigin[0] = str_to_float(sOrigin[0]);
				g_EntViewTowerFallingOrigin[1] = str_to_float(sOrigin[1]);
				g_EntViewTowerFallingOrigin[2] = str_to_float(sOrigin[2]);
				
				vecAngles[0] = str_to_float(sAngles[0]);
				vecAngles[1] = str_to_float(sAngles[1]);
				vecAngles[2] = str_to_float(sAngles[2]);
				
				entity_set_string(iEnt, EV_SZ_classname, "entViewTower");
				
				entity_set_model(iEnt, "models/w_usp.mdl");
				entity_set_origin(iEnt, g_EntViewTowerFallingOrigin);
				
				entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
				entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
				
				entity_set_int(iEnt, EV_INT_sequence, 0);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				
				entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(iEnt, EV_FL_renderamt, 0.0);
				
				entity_set_size(iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
				
				entity_set_vector(iEnt, EV_VEC_v_angle, vecAngles);
				entity_set_vector(iEnt, EV_VEC_angles, vecAngles);
			}
			
			break;
		}
	}
	
	fclose(iFile);
	
	if(is_valid_ent(iEnt)) {
		new i;
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}
			
			attach_view(i, iEnt);
		}
	}
}

public clcmd_Say(const id) {
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	static sMessage[191];
	
	read_args(sMessage, 190);
	remove_quotes(sMessage);
	
	replace_all(sMessage, 190, "%", "");
	replace_all(sMessage, 190, "!y", "");
	replace_all(sMessage, 190, "!t", "");
	replace_all(sMessage, 190, "!g", "");
	
	if(equal(sMessage, "") || sMessage[0] == '/' || sMessage[0] == '@' || sMessage[0] == '!')
		return PLUGIN_HANDLED;
	
	colorChat(0, CT, "%s!t%s !g(%dG!) !y: %s", (is_user_alive(id)) ? "" : "!y*DEAD* ", g_UserName[id], g_LevelG[id], sMessage);
	
	return PLUGIN_HANDLED;
}

stock userTeamUpdate(const id) {
	static Float:fCurrentTime;
	fCurrentTime = get_gametime();
	
	if(fCurrentTime - g_Teams_Time >= 0.1) {
		set_task(0.1, "setUserTeamMsg", id + TASK_TEAM);
		g_Teams_Time = fCurrentTime + 0.1;
	} else {
		set_task((g_Teams_Time + 0.1) - fCurrentTime, "setUserTeamMsg", id + TASK_TEAM);
		g_Teams_Time = g_Teams_Time + 0.1;
	}
}

public setUserTeamMsg(const taskid) {
	emessage_begin(MSG_ALL, g_Message_TeamInfo);
	ewrite_byte(ID_TEAM);
	ewrite_string("CT");
	emessage_end();
}

public event_Health(const id) {
	// new iHealth;
	// iHealth = read_data(1);
	
	g_Health[id] = get_user_health(id);
}

public __specialEffectToBoss() {
	message_begin(MSG_BROADCAST, g_Message_Screenfade);
	write_short(UNIT_SECOND * 4);
	write_short(UNIT_SECOND * 4);
	write_short(FFADE_OUT);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(255);
	message_end();
	
	set_task(4.5, "__moveUsersToBoss");
}

public __moveUsersToBoss() {
	new Float:vecOrigin[3];
	new iEnt;
	new i = 1;
	
	iEnt = -1;
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", "info_vip_start")) != 0) {
		entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
		
		while(!is_user_alive(i) && i <= g_MaxUsers) {
			++i;
		}
		
		if(i > g_MaxUsers) {
			break;
		}
		
		entity_set_vector(i, EV_VEC_origin, vecOrigin);
		
		++i;
	}

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}

		g_InBlockZone[i] = 0;
	}
	
	set_task(1.5, "__removeSpecialEffectToBoss");
}

public __removeSpecialEffectToBoss() {
	message_begin(MSG_BROADCAST, g_Message_Screenfade);
	write_short(UNIT_SECOND * 4);
	write_short(0);
	write_short(FFADE_IN);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(255);
	message_end();
	
	g_NextWaveIncoming = 3;
	
	clearDHUDs();
	entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
}

public __removeEffectSpecialBoss(const miniBoss) {
	new Float:vecOrigin[3];
	new iEnt;
	new i = 1;
	new iHealth;

	switch(g_BossId) {
		case BOSS_GUARDIANES: {
			iHealth = 1500;
		} case BOSS_FALLEN_TITAN: {
			iHealth = 750;
		} default: {
			iHealth = 500;
		}
	}
	
	iEnt = -1;
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", "info_vip_start")) != 0) {
		entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
		
		while(!is_user_alive(i) && i <= g_MaxUsers) {
			++i;
		}
		
		if(i > g_MaxUsers) {
			break;
		}

		set_user_health(i, iHealth);
		
		entity_set_vector(i, EV_VEC_origin, vecOrigin);
		
		++i;
	}
	
	message_begin(MSG_BROADCAST, g_Message_Screenfade);
	write_short(UNIT_SECOND * 4);
	write_short(0);
	write_short(FFADE_IN);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
	
	if(g_BossId != BOSS_GUARDIANES) {
		if(is_valid_ent(miniBoss)) {
			remove_entity(miniBoss);
		}
	} else {
		for(i = 0; i < 3; ++i) {
			if(is_valid_ent(g_MiniBoss_Ids[i])) {
				remove_entity(g_MiniBoss_Ids[i]);
			}
		}
	}
	
	createBoss();
}

public showMenu__Join(const id) {
	new sMenu[500];
	new iLen = 0;

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\y%s\w^n\wNIVEL G!\r: \y%d^n^n\
		\wSOLDADO\r: \yLV. %d \r- \wINGENIERO\r: \yLV. %d^n\
		\wSOPORTE\r: \yLV. %d \r- \wFRANCOTIRADOR\r: \yLV. %d^n\
		\wAPOYO\r: \yLV. %d \r- \wPESADO\r: \yLV. %d^n\
		\wASALTO\r: \yLV. %d \r- \wCOMANDANTE\r: \yLV. %d^n",
	g_UserName[id], g_LevelG[id], g_ClassLevel[id][CLASS_SOLDADO], g_ClassLevel[id][CLASS_INGENIERO], g_ClassLevel[id][CLASS_SOPORTE], g_ClassLevel[id][CLASS_FRANCOTIRADOR], g_ClassLevel[id][CLASS_APOYO], g_ClassLevel[id][CLASS_PESADO],
	g_ClassLevel[id][CLASS_ASALTO], g_ClassLevel[id][CLASS_COMANDANTE]);

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\
		\wPUBERO\r: \yLV. %d \r- \wPISTOLERO\r: \yLV. %d^n\
		\wBITERO\r: \yLV. %d \r- \wLEGIONARIO\r: \yLV. %d^n\
		\wSCOUTER\r: \yLV. %d\
		^n^n%s^n^n\r1.\w ¡ENTRAR A JUGAR!",
	g_ClassLevel[id][CLASS_PUBERO], g_ClassLevel[id][CLASS_PISTOLERO], g_ClassLevel[id][CLASS_BITERO], g_ClassLevel[id][CLASS_LEGIONARIO], g_ClassLevel[id][CLASS_SCOUTER], (!g_AccountVinc[id]) ? "\dVINCULADA AL FORO: \rNO" : "\wVINCULADA AL FORO: \ySI");
	
	show_menu(id, KEYSMENU, sMenu, -1, "Menu Join");
}

public menu__Join(const id, const key) {
	if(key == 0) {
		if(g_Tutorial[id]) {
			g_AllowChangeTeam[id] = 1;
			
			set_pdata_int(id, 125, (get_pdata_int(id, 125, OFFSET_LINUX) & ~(1<<8)), OFFSET_LINUX);
			
			engclient_cmd(id, "jointeam", "5");
			engclient_cmd(id, "joinclass", "5");
			
			g_AllowChangeTeam[id] = 0;
			
			set_task(0.5, "respawnUser", id);

			g_AlreadyJoined[id] = 1;
		} else {
			showMenu__Tutorial(id, 0);
		}
	} else {
		showMenu__Join(id);
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__Tutorial(const id, const iPage) {
	new sMenu[500];

	g_MenuPageTutorial[id] = iPage;

	switch(iPage) {
		case 0: {
			formatex(sMenu, charsmax(sMenu), "\yBienvenido a %s \r%s^n\
												by \y%s^n^n\
												\wSi esta es tu primera vez en este servidor,^n\
												se recomienda que leas este sencillo pero breve tutorial para^n\
												entender las funciones básicas del juego!^n^n\
												\r2. \wSIGUIENTE \y(01 / 07)^n^n\
												\r0. \wOMITIR TUTORIAL", PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
		}
		case 1: {
			formatex(sMenu, charsmax(sMenu), "\yTUTORIAL\w^n^n\
												El objetivo principal es sobrevivir a las oleadas y^n\
												subir tu nivel general como el nivel de tus clases.^n^n\
												\r2. \wSIGUIENTE \y(02 / 07)^n^n\
												\r0. \wOMITIR TUTORIAL");
		}
		case 2: {
			formatex(sMenu, charsmax(sMenu), "\yTUTORIAL\w^n^n\
												Para comprar armamento y otras cosas debes^n\
												posicionarte cerca de uno de los tantos^n\
												vendedores (muñecos) y apretar la tecla E.^n^n\
												Junta oro disparando a los enemigos, comprá^n\
												mejor armamento y mejores cosas, no hay^n\
												límite de armas y podés comprar todo lo que querés.^n^n\
												\r2. \wSIGUIENTE \y(03 / 07)^n^n\
												\r0. \wOMITIR TUTORIAL");
		}
		case 3: {
			formatex(sMenu, charsmax(sMenu), "\yTUTORIAL\w^n^n\
												Para seleccionar un poder comprado apretá^n\
												la \ytecla C\w para ir hacia la derecha o^n\
												la \ytecla X\w para ir hacia la izquierda.^n^n\
												Una vez seleccionado tu poder, apretá^n\
												la \ytecla Z\w para activarlo/lanzarlo!^n^n\
												\r2. \wSIGUIENTE \y(04 / 07)^n^n\
												\r0. \wOMITIR TUTORIAL");
		}
		case 4: {
			formatex(sMenu, charsmax(sMenu), "\yTUTORIAL\w^n^n\
												Recordá comprar las armas y otras cosas antes^n\
												de que inicie una oleada, de lo contrario no,^n\
												podrás comprar un arma hasta que termine^n^n\
												Recargá tus armas en el muñeco en cualquier momento.^n^n\
												\r2. \wSIGUIENTE \y(05 / 07)^n^n\
												\r0. \wOMITIR TUTORIAL");
		}
		case 5: {
			formatex(sMenu, charsmax(sMenu), "\yTUTORIAL\w^n^n\
												Una vez finalizadas las 10 oleadas,^n\
												el \yjefe final\w aparece y el objetivo del grupo^n\
												es matarlo. Ten cuidado con este monstruo debido a^n\
												que tiene poderes especiales que realizan mayor daño.^n^n\
												\r2. \wSIGUIENTE \y(06 / 07)^n^n\
												\r0. \wOMITIR TUTORIAL");
		}
		case 6: {
			formatex(sMenu, charsmax(sMenu), "\yTUTORIAL\w^n^n\
												Por último, hay muchas más cosas que^n\
												debes ir descubriendo por ti solo a medida^n\
												que vas jugando, como las \yhabilidades\w, \ydificultades\w,^n\
												\yestrategias\w, \yclases\w, \ylogros\w, y más.^n^n\
												\r2. \wFINALIZAR TUTORIAL");
		}
	}
	
	show_menu(id, KEYSMENU, sMenu, -1, "Menu Tutorial");
}

public menu__Tutorial(const id, const key) {
	if(key == 1) {
		++g_MenuPageTutorial[id];
		
		if(g_MenuPageTutorial[id] == 7) {
			g_Tutorial[id] = 1;
			
			setAchievement(id, TUTORIAL);
			
			if(!g_AlreadyJoined[id]) {
				showMenu__Join(id);
			}

			return PLUGIN_HANDLED;
		}
		
		showMenu__Tutorial(id, g_MenuPageTutorial[id]);
	} else if(key == 9) {
		g_Tutorial[id] = 1;

		if(!g_AlreadyJoined[id]) {
			showMenu__Join(id);
		}
	} else {
		showMenu__Tutorial(id, g_MenuPageTutorial[id]);
	}
	
	return PLUGIN_HANDLED;
}

public __getDropOrigin(const id, Float:vecOrigin[3]) {
	new Float:vecVelocity[3];
	new Float:vecViewOfs[3];
	
	entity_get_vector(id, EV_VEC_view_ofs, vecViewOfs);
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin);
	
	velocity_by_aim(id, 50, vecVelocity);
	
	vecOrigin[0] += vecVelocity[0];
	vecOrigin[1] += vecVelocity[1];
}

public bossPower_Closer(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static Float:vecEntOrigin[3];
	static Float:vecOrigin[3];
	static Float:vecDirection[3];
	static i;
	
	entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
	
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
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_alive(i))
			continue;
		
		entity_get_vector(i, EV_VEC_origin, vecOrigin);
		
		xs_vec_sub(vecOrigin, vecEntOrigin, vecDirection);
		xs_vec_mul_scalar(vecDirection, -0.4, vecDirection);
		
		entity_set_vector(i, EV_VEC_velocity, vecDirection);
	}
}

public __endBossPower_Closer(const iEnt) {
	set_task(1.0, "__lightsOff");
	
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	new Float:vecOrigin[3];
	new Float:vecVictimOrigin[3];
	new Float:fDistance;
	new Float:fDamage;
	new Float:vecDirection[3];
	new Float:flRadius;
	new iVictim;
	
	entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
	
	new i;
	for(i = 1; i < 3; ++i) {
		engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_BEAMTORUS);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2] + ((i == 1) ? 3.0 : 15.0));
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2] + (500.0 * float(i)));
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
	
	flRadius = 512.0;
	iVictim = -1;

	new iVictimHealed[MAX_USERS];
	
	while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, flRadius)) != 0) {
		if(!is_user_alive(iVictim)) {
			continue;
		}

		iVictimHealed[iVictim] = 1;
		
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = get_distance_f(vecVictimOrigin, vecOrigin);
		fDamage = (flRadius + 1.0) - fDistance;
		
		if(fDamage > 0.0) {
			if((get_user_health(iVictim) - floatround(fDamage)) > 0) {
				vecVictimOrigin[2] += 8.0;
				
				xs_vec_sub(vecVictimOrigin, vecOrigin, vecDirection);
				xs_vec_mul_scalar(vecDirection, 2400.0, vecDirection);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecDirection);
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, fDamage, DMG_SLASH);
			} else {
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, 9999.0, DMG_SLASH);
			}
		}
	}

	if(g_BossId == BOSS_GORILA) {
		new iExtraHP = 0;
		new iHP;

		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_alive(i)) {
				continue;
			}

			if(iVictimHealed[i]) {
				continue;
			}

			iHP = get_user_health(i);
			iExtraHP = ((500 - iHP) * 20) / 100;

			set_user_health(i, iHP + iExtraHP);
		}
	}
	
	g_BossPower[0] = 0;
	g_Boss_TimePower[0] = get_gametime() + 11.0;
	
	if(pev_valid(iEnt)) {
		fm_set_rendering(iEnt);
	}
	
	__backToRide(iEnt);
}

public createMiniBoss() {
	if(is_valid_ent(g_Boss)) {
		remove_entity(g_Boss);
	}
	
	new iEnt;
	new iRespawn;
	new Float:vecRespawnOrigin[3];
	new iMiniBoss_Count;
	new iMiniBoss_Health;
	
	if(is_valid_ent(g_EntCheckAFK)) {
		entity_set_float(g_EntCheckAFK, EV_FL_nextthink, 9999.0);
		remove_entity(g_EntCheckAFK);
	}
	
	iMiniBoss_Count = 1;
	g_TotalMonsters = 1;
	g_MonstersAlive = 1;
	iMiniBoss_Health = 500;
	
	register_think(ENT_MINIBOSS_CLASSNAME, "think__MiniBoss");
	
	switch(g_BossId) {
		case BOSS_GORILA: {
			OrpheuRegisterHook(OrpheuGetDLLFunction("pfnPM_Move", "PM_Move"), "OnPM_Move");
			OrpheuRegisterHook(OrpheuGetFunction("PM_Jump"), "OnPM_Jump");
		} case BOSS_GUARDIANES: {
			OrpheuRegisterHook(OrpheuGetDLLFunction("pfnPM_Move", "PM_Move"), "OnPM_Move");
			OrpheuRegisterHook(OrpheuGetFunction("PM_Jump"), "OnPM_Jump");
			
			g_TotalMonsters = 3;
			g_MonstersAlive = 3;
			iMiniBoss_Count = 3;
		}
	}
	
	new i;
	// for(i = 1; i <= g_MaxUsers; ++i) {
		// if(is_user_alive(i)) {
			// g_Speed[i] = 250.0;
			
			// ExecuteHamB(Ham_Player_ResetMaxSpeed, i);
		// }
	// }
	
	iRespawn = find_ent_by_tname(-1, "respawn_boss");
	if(is_valid_ent(iRespawn) && iRespawn != 0) {
		entity_get_vector(iRespawn, EV_VEC_origin, vecRespawnOrigin);
	}
	
	new Float:vecMins[3];
	new Float:vecMax[3];
	new Float:fVelocity;
	
	new iHealth = iMiniBoss_Health * getUsersAlive();
	
	g_HamTakeDamage = RegisterHam(Ham_TakeDamage, "info_target", "fw_MiniBoss_TakeDamage");
	g_HamKilled = RegisterHam(Ham_Killed, "info_target", "fw_MiniBoss_Killed");
	
	for(i = 0; i < iMiniBoss_Count; ++i) {
		iEnt = create_entity("info_target");
		
		if(is_valid_ent(iEnt)) {
			g_MiniBoss_Ids[i] = iEnt;
			
			entity_set_string(iEnt, EV_SZ_classname, ENT_MINIBOSS_CLASSNAME);
			
			dllfunc(DLLFunc_Spawn, iEnt);
			
			entity_set_model(iEnt, MODEL_MINIBOSS);
			entity_set_float(iEnt, EV_FL_health, float(iHealth));
			entity_set_float(iEnt, EV_FL_takedamage, DAMAGE_YES);
			
			entity_set_vector(iEnt, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
			entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);
			
			switch(i) {
				case 1: {
					vecRespawnOrigin[MAPS_DESC[g_MapId][mapBossCoord]] -= 400.0;
				} case 2: {
					vecRespawnOrigin[MAPS_DESC[g_MapId][mapBossCoord]] += 800.0;
				}
			}
			
			entity_set_origin(iEnt, vecRespawnOrigin);
			
			entity_set_float(iEnt, EV_FL_gravity, 1.0);
			
			entity_set_int(iEnt, EV_INT_sequence, 3);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			entity_set_int(iEnt, MONSTER_MAXHEALTH, iHealth);
			entity_set_int(iEnt, MONSTER_TYPE, MONSTER_BOSS);
			entity_set_int(iEnt, MONSTER_TARGET, 0);
			
			vecMins = Float:{-16.0, -16.0, -36.0};
			vecMax = Float:{16.0, 16.0, 36.0};
			
			entity_set_size(iEnt, vecMins, vecMax);
			
			entity_set_vector(iEnt, EV_VEC_mins, vecMins);
			entity_set_vector(iEnt, EV_VEC_maxs, vecMax);
			
			fVelocity = 200.0;
			entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
			
			set_task(4.0, "__changeMoveType", iEnt);
			
			entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 5.0);
		}
	}
	
	clearDHUDs();
	entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
}

new g_Achievement_LaBoneaste = 0;
public think__MiniBoss(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(iEnt, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:fDistance;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		if(fDistance <= 64.0) {
			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
			
			entity_set_int(iEnt, EV_INT_sequence, 76);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 2.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
			
			ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, 9999.0, DMG_SLASH);

			if(iVictim && !g_Achievement_LaBoneaste) {
				g_Achievement_LaBoneaste = 1;
				setAchievement(iVictim, LA_BONEASTE);
			}
		} else {
			static Float:fVelocity;

			if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
				entity_set_int(iEnt, EV_INT_gamestate, 3);

				entity_set_int(iEnt, EV_INT_sequence, 4);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				
				fVelocity = 200.0;
				entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
			}

			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, fVelocity, .iAngleMode=1);
			
			if(fDistance >= 115.0) {
				iVictim = miniBoss__SearchHuman(iEnt);
				entity_set_int(iEnt, MONSTER_TARGET, iVictim);
			}
			
			entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
		}
	} else {
		iVictim = miniBoss__SearchHuman(iEnt);
		entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(iEnt, EV_INT_sequence, 1);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 1.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			return;
		}
		
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
	}
}

public message_ClCorpse() {
	return PLUGIN_HANDLED;
}

public createBoss() {
	new iRespawn;
	
	g_Boss = create_entity("info_target");
	
	if(is_valid_ent(g_Boss)) {
		iRespawn = find_ent_by_tname(-1, "respawn_boss");
		
		if(is_valid_ent(iRespawn) && iRespawn != 0) {
			entity_get_vector(iRespawn, EV_VEC_origin, g_Boss_Respawn);
		}
		
		new Float:vecMins[3];
		new Float:vecMax[3];
		new Float:fVelocity;
		new iHealth;
		new iExtraDamage = getTotalExtraDamage() / 10;
		
		iHealth = DIFFICULTIES_VALUES[g_Difficulty][difficultyBossGorilaHealth] * getUsersAlive();
		
		DisableHamForward(g_HamTakeDamage);
		DisableHamForward(g_HamKilled);
		
		switch(g_BossId) {
			case BOSS_GORILA: {
				OrpheuRegisterHook(OrpheuGetFunction("PM_Duck"), "OnPM_Duck");

				g_Boss_Gorila_AttractPowerHP[0] = random_num(1500, 4000);
				
				vecMins = Float:{-32.0, -32.0, -36.0};
				vecMax = Float:{32.0, 32.0, 9999.0};
				
				register_think(ENT_BOSS_CLASSNAME, "think__Boss");
			} case BOSS_FIRE: {
				iHealth *= 3;
				
				g_Boss_Fire_UltimateHealth = iHealth / 3;
				
				vecMins = Float:{-30.0, -60.0, -40.0};
				vecMax = Float:{30.0, 60.0, 9999.0};
				
				register_think(ENT_BOSS_CLASSNAME, "think__Boss_FireMonster");
				register_think("entFireBall", "think__FireBall");
				
				register_touch(ENT_BOSS_CLASSNAME, "*", "touch__Boss_FireMonster");
				register_touch("entFireBall", "*", "touch__FireBall");
			} case BOSS_FALLEN_TITAN: {
				iHealth *= 4;
				
				g_Boss_FT_UltimateHealth = iHealth / 3;
				
				vecMins = Float:{-30.0, -60.0, -36.0};
				vecMax = Float:{30.0, 60.0, 9999.0};
				
				register_think(ENT_BOSS_CLASSNAME, "think__Boss_FallenTitan");				
				register_touch(ENT_BOSS_CLASSNAME, "*", "touch__Boss_FallenTitan");
			} case BOSS_GUARDIANES: {
				OrpheuRegisterHook(OrpheuGetFunction("PM_Duck"), "OnPM_Duck");
				
				set_lights(g_Lights[0]);
				
				iHealth *= 3;

				g_Boss_Gorila_AttractPowerHP[0] = random_num(2000, 6000);
				g_Boss_Gorila_AttractPowerHP[1] = random_num(2000, 6000);
				
				vecMins = Float:{-32.0, -32.0, -36.0};
				vecMax = Float:{32.0, 32.0, 9999.0};
				
				register_think(ENT_BOSS_CLASSNAME, "think__Boss_Kyra");
			}
		}

		iHealth = iHealth + ((iHealth * iExtraDamage) / 100);
		
		entity_set_string(g_Boss, EV_SZ_classname, ENT_BOSS_CLASSNAME);
		
		dllfunc(DLLFunc_Spawn, g_Boss);
		
		g_HamTakeDamage = RegisterHam(Ham_TakeDamage, "info_target", "fw_Boss_TakeDamage");
		g_HamKilled = RegisterHam(Ham_Killed, "info_target", "fw_Boss_Killed");
		
		entity_set_model(g_Boss, MODEL_BOSS[g_BossId]);
		entity_set_float(g_Boss, EV_FL_health, float(iHealth));
		entity_set_float(g_Boss, EV_FL_takedamage, (g_BossId != BOSS_GUARDIANES) ? DAMAGE_YES : DAMAGE_NO);
		
		entity_set_vector(g_Boss, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(g_Boss, EV_INT_solid, SOLID_BBOX);
		entity_set_int(g_Boss, EV_INT_movetype, MOVETYPE_TOSS);
		
		entity_set_origin(g_Boss, g_Boss_Respawn);
		
		entity_set_float(g_Boss, EV_FL_gravity, 1.0);
		
		set_task(2.0, "__changeMoveType", g_Boss);
		set_task(0.6, "__screenShake_AnimChange");
		
		entity_set_int(g_Boss, EV_INT_sequence, (g_BossId != BOSS_GUARDIANES) ? 1 : 146);
		entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
		
		entity_set_int(g_Boss, EV_INT_gamestate, 1);
		
		entity_set_int(g_Boss, MONSTER_MAXHEALTH, iHealth);
		entity_set_int(g_Boss, MONSTER_TYPE, MONSTER_BOSS);
		entity_set_int(g_Boss, MONSTER_TARGET, 0);
		
		entity_set_size(g_Boss, vecMins, vecMax);
		
		entity_set_vector(g_Boss, EV_VEC_mins, vecMins);
		entity_set_vector(g_Boss, EV_VEC_maxs, vecMax);
		
		drop_to_floor(g_Boss);
		
		fVelocity = 265.0;
		entity_set_float(g_Boss, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0

		if(g_BossId == BOSS_FALLEN_TITAN) {
			entity_set_int(g_Boss, EV_INT_sequence, 5); // IDLE
			entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
			entity_set_float(g_Boss, EV_FL_framerate, 1.0);
			
			entity_set_int(g_Boss, EV_INT_gamestate, 1);
		}
		
		switch(g_BossId) {
			case BOSS_GUARDIANES: {
				g_TotalMonsters = 3;
				g_MonstersAlive = 3;
				
				entity_set_float(g_Boss, EV_FL_nextthink, get_gametime() + 20.0);
				
				createGuardians();
			} default: {
				g_TotalMonsters = 1;
				g_MonstersAlive = 1;
				
				entity_set_float(g_Boss, EV_FL_nextthink, get_gametime() + 3.0);
				
				g_Boss_HealthBar = create_entity("env_sprite");
				
				if(g_Boss_HealthBar) {
					entity_set_int(g_Boss_HealthBar, EV_INT_spawnflags, SF_SPRITE_STARTON);
					entity_set_int(g_Boss_HealthBar, EV_INT_solid, SOLID_NOT);
					
					entity_set_model(g_Boss_HealthBar, MONSTER_SPRITE_HEALTH_BOSS);
					
					entity_set_float(g_Boss_HealthBar, EV_FL_scale, 0.5);
					
					entity_set_float(g_Boss_HealthBar, EV_FL_frame, 100.0);
					
					//g_Boss_Respawn[2] += 200.0;
					entity_set_origin(g_Boss_HealthBar, g_Boss_Respawn);
					
					g_FORWARD_AddToFullPack_Status = 1;
					g_FORWARD_AddToFullPack = register_forward(FM_AddToFullPack, "fw_AddToFullPack__BOSS_Post", 1);
				}
			}
		}
		
		clearDHUDs();
		entity_set_float(g_EntHUD, EV_FL_nextthink, NEXTTHINK_THINK_HUD);
	}
}

new const SEQUENCES_ATTACK_BOSS1[] = {35, 36, 37, 38, 39, 40};
new const Float:SEQUENCES_FRAMES_BOSS1[] = {0.566667, 0.433333, 1.5, 0.566667, 0.566667, 1.466667}; // Abrir modelo con HLMV y hacer la cuenta 'Frames / FPS'

public think__Boss(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(iEnt, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:fDistance;
		static fHeightDifference;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		fHeightDifference = abs(floatround(vecEntOrigin[2] - vecVictimOrigin[2]));

		if(fHeightDifference > 250) {
			new i;
			for(i = 0; i < 16; ++i) {
				iVictim = miniBoss__SearchHuman(iEnt, iVictim);
				entity_set_int(iEnt, MONSTER_TARGET, iVictim);

				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
				return;
			}
		}
		
		if(fDistance <= 64.0) {
			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
			
			if(g_BossPower[0] != BOSS_POWER_ROLL) {
				static iRandomAttackSeq;
				static iRandom;
				
				iRandom = random_num(0, charsmax(SEQUENCES_ATTACK_BOSS1));
				iRandomAttackSeq = SEQUENCES_ATTACK_BOSS1[iRandom];
				
				g_BossRollSpeed[0] = 0.0;
				
				emit_sound(iVictim, CHAN_BODY, SOUND_BOSS_PHIT[random_num(0, 2)], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(iEnt, EV_INT_sequence, iRandomAttackSeq);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				static Float:vecSub[3];
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub); // vec1 - vec2
				xs_vec_mul_scalar(vecSub, 2400.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				// set_user_health(iVictim, 1000000);
				
				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + SEQUENCES_FRAMES_BOSS1[iRandom]);
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, DIFFICULTIES_VALUES[g_Difficulty][difficultyBossGorilaDamage], DMG_SLASH);
				
				return;
			} else {
				client_cmd(0, "stopsound; spk ^"%s^"", SOUND_BOSS_ROLL_FINISH);
				
				g_BossRollSpeed[0] = 0.0;
				
				static Float:flGameTime;
				flGameTime = get_gametime();
				
				g_Boss_TimePower[0] = flGameTime + 5.0;
				g_BossPower[0] = 0;
				
				static Float:vecSub[3];
				
				vecEntOrigin[0] = vecVictimOrigin[0];
				vecEntOrigin[1] = vecVictimOrigin[1];
				vecEntOrigin[2] = vecVictimOrigin[2] + 64.0;
				
				xs_vec_sub(vecEntOrigin, vecVictimOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 5.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(iEnt, EV_INT_sequence, 45);
				entity_set_float(iEnt, EV_FL_animtime, flGameTime);
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 1.2);
				
				return;
			}
		} else {
			static Float:fVelocity;
			
			if(g_BossPower[0] != BOSS_POWER_ROLL) {
				g_BossRollSpeed[0] += 0.5;
				fVelocity = 260.0 + g_BossRollSpeed[0];

				if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
					entity_set_int(iEnt, EV_INT_gamestate, 3);

					entity_set_int(iEnt, EV_INT_sequence, 4);
					entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				}

				entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
			} else {
				g_BossRollSpeed[0] += 5.0;
				fVelocity = 200.0 + g_BossRollSpeed[0];
				
				vecEntOrigin[2] -= 24.0;
				
				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
				write_byte(TE_SPARKS);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
				message_end();
				
				vecEntOrigin[2] += 24.0;
			}
			
			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, fVelocity, .iAngleMode=1);
			
			if(fDistance >= 200.0) {
				static Float:flGameTime;
				flGameTime = get_gametime();
				
				if(fDistance >= 500.0 && !g_BossPower[0] && g_Boss_TimePower[0] <= flGameTime) {
					if(random_num(0, 1)) {
						g_BossPower[0] = BOSS_POWER_ROLL;
						g_BossLastPower[0] = g_BossPower[0];
						
						client_cmd(0, "spk ^"%s^"", SOUND_BOSS_ROLL_LOOP);
						
						entity_set_int(iEnt, EV_INT_sequence, 44);
						entity_set_float(iEnt, EV_FL_animtime, get_gametime());
						entity_set_float(iEnt, EV_FL_framerate, 1.3);
						
						entity_set_int(iEnt, EV_INT_gamestate, 1);
						
						iVictim = miniBoss__SearchRandomHuman(iEnt);
						entity_set_int(iEnt, MONSTER_TARGET, iVictim);
						
						entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 0.1);
						
						return;
					} else {
						new iRandomPower;
						iRandomPower = g_BossLastPower[0];
						
						while(iRandomPower == g_BossLastPower[0]) {
							iRandomPower = random_num(1, 3);
						}
						
						switch(iRandomPower) {
							case BOSS_POWER_ROLL: {
								g_Boss_TimePower[0] = flGameTime + 7.0;
								g_BossLastPower[0] = BOSS_POWER_ROLL;
								
								entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
								
								return;
							}
							case BOSS_POWER_EGGS: {
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
								
								entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
								entity_set_float(iEnt, EV_FL_renderamt, 150.0);
								
								entity_set_int(iEnt, EV_INT_sequence, 1);
								entity_set_float(iEnt, EV_FL_animtime, get_gametime());
								entity_set_float(iEnt, EV_FL_framerate, 1.0);
								
								entity_set_int(iEnt, EV_INT_gamestate, 1);
								
								entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
								
								createSpecialMonster(iEnt, 16);
							}
							case BOSS_POWER_ATTRACT: {
								if(!random_num(0, 3)) {
									g_BossPower[0] = BOSS_POWER_ATTRACT;
									g_BossLastPower[0] = g_BossPower[0];
									
									entity_set_int(iEnt, EV_INT_sequence, 0);
									entity_set_float(iEnt, EV_FL_animtime, get_gametime());
									entity_set_float(iEnt, EV_FL_framerate, 1.0);
									
									entity_set_int(iEnt, EV_INT_gamestate, 1);
									
									entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
									
									fm_set_rendering(iEnt, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
									
									set_lights("a");
									
									new Float:flEndTime = 3.7;
									new Float:flRepeat = (flEndTime / 0.1) - 1.0;
									
									set_task(0.1, "bossPower_Closer", iEnt, _, _, "a", floatround(flRepeat));
									set_task(flEndTime, "__endBossPower_Closer", iEnt);
								} else {
									g_Boss_TimePower[0] = flGameTime + 7.0;
									g_BossLastPower[0] = BOSS_POWER_ROLL;
									
									entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
									
									return;
								}
							}
						}

						entity_set_int(iEnt, MONSTER_TARGET, 0);
						
						return;
					}
				}
				
				iVictim = miniBoss__SearchHuman(iEnt);
				entity_set_int(iEnt, MONSTER_TARGET, iVictim);
			}
		}
	} else {
		iVictim = miniBoss__SearchHuman(iEnt);
		entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(iEnt, EV_INT_sequence, 1);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 1.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			return;
		}
	}
	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
}

// stock checkBBox(const sFile[], const Float:vecBrush[3]) {
	// new iFile = fopen(sFile, "rb");
	// new iBBoff;
	// new Float:vecSize[6];
	
	// fseek(iFile, 160, SEEK_SET);
	// fread(iFile, iBBoff, BLOCK_INT);
	// fseek(iFile, (iBBoff + 8), SEEK_SET);
	// fread_blocks(iFile, _:vecSize, 6, BLOCK_INT);
	// fclose(iFile);
	
	// vecSize[0] = vecSize[3] - vecSize[0];
	// vecSize[1] = vecSize[4] - vecSize[1];
	// vecSize[2] = vecSize[5] - vecSize[2];
// }

public __screenShake_AnimChange() {
	if(is_valid_ent(g_Boss)) {
		message_begin(MSG_BROADCAST, g_Message_ScreenShake);
		write_short(UNIT_SECOND * 5);
		write_short(UNIT_SECOND * 5);
		write_short(UNIT_SECOND * 5);
		message_end();
		
		new Float:vecEntOrigin[3];
		new Float:vecTargetOrigin[3];
		new i = 1;
		new j = 1;
		
		entity_get_vector(g_Boss, EV_VEC_origin, vecTargetOrigin);
		
		while(i <= g_MaxUsers) {
			if(is_user_alive(i)) {
				entity_get_vector(i, EV_VEC_origin, vecEntOrigin);
				
				entitySetAim(i, vecEntOrigin, vecTargetOrigin, .iAngleMode=1);
				
				if(j) {
					entitySetAim(g_Boss, vecTargetOrigin, vecEntOrigin, .iAngleMode=1);
					j = 0;
				}
			}
			
			++i;
		}
	}
}

public OrpheuHookReturn:OnPM_Move(const OrpheuStruct:pmove, const server) {
	g_UserMove = pmove;
}

public OrpheuHookReturn:OnPM_Jump() {
	new id;
	id = OrpheuGetStructMember(g_UserMove, "player_index") + 1;
	
	if(is_user_alive(id)) {
		OrpheuSetStructMember(g_UserMove, "oldbuttons", OrpheuGetStructMember(g_UserMove, "oldbuttons") | IN_JUMP);
	}
}

public OrpheuHookReturn:OnPM_Duck() {
	if(g_BossPower[0] == BOSS_POWER_ATTRACT) {
		new id;
		id = OrpheuGetStructMember(g_UserMove, "player_index") + 1;
		
		if(is_user_alive(id)) {
			new OrpheuStruct:cmd = OrpheuStruct:OrpheuGetStructMember(g_UserMove, "cmd");
			OrpheuSetStructMember(cmd, "buttons", OrpheuGetStructMember(cmd, "buttons" ) & ~IN_DUCK);
		}
	}
}

public __backToRide(const iEnt) {
	if(is_valid_ent(iEnt)) {
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
	}
}

stock hamStripWeapons(const id, const weapon[]) {
	if(!equal(weapon, "weapon_", 7)) {
		return 0;
	}
	
	static iWeaponId;
	iWeaponId = get_weaponid(weapon);
	
	if(!iWeaponId) {
		return 0;
	}
	
	static iWeaponEnt;
	iWeaponEnt = -1;
	
	while((iWeaponEnt = engfunc(EngFunc_FindEntityByString, iWeaponEnt, "classname", weapon)) && entity_get_edict(iWeaponEnt, EV_ENT_owner) != id) { }
	
	if(!iWeaponEnt) {
		return 0;
	}
	
	if(g_CurrentWeapon[id] == iWeaponId) {
		ExecuteHamB(Ham_Weapon_RetireWeapon, iWeaponEnt);
	}
	
	if(!ExecuteHamB(Ham_RemovePlayerItem, id, iWeaponEnt)) {
		return 0;
	}
	
	ExecuteHamB(Ham_Item_Kill, iWeaponEnt);
	
	set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1 << iWeaponId));
	
	return 1;
}

public event_AmmoX(const id) {
	if(g_Wave == 11 || (g_ClassId[id] == CLASS_LEGIONARIO && g_ClassLevel[id][CLASS_LEGIONARIO] == 6)) {
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
			
			set_task(0.1, "refillBPAmmo", id, sArgs, 1);
		}
	}
}

public refillBPAmmo(const args[], const id) {
	if(!is_user_alive(id)) {
		return;
	}
	
	set_msg_block(g_Message_AmmoPickup, BLOCK_ONCE);
	ExecuteHamB(Ham_GiveAmmo, id, MAX_BPAMMO[args[0]], AMMO_TYPE[args[0]], MAX_BPAMMO[args[0]]);
}

public endWave() {
	g_WaveInProgress = 0;
	
	new i;
	
	if(g_SpecialWave) {
		g_SpecialWave = 0;
		g_ExtraWaveSpeed = 1337;
		g_ExtraWaveStrength = 1337;
	} else if(!g_Tramposo) {
		new j = 0;
		new iLen = 0;
		new sQuery[1024];
		
		g_TimePerWave_SysTime[g_Wave - 1] = (get_systime() - g_TimePerWave_SysTime[g_Wave - 1]);
		
		iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "INSERT INTO td_timeperwave (`td_wave`, `td_players`, `td_time_seconds`, `td_diff`, `td_mapname`, ");
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(g_TimePerWave_Users[i][0]) {
				++j;
				
				iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "`td_username%d`, ", j);
			}
		}
		
		sQuery[iLen-2] = EOS;
		iLen -= 2;
		
		iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, ") VALUES ('%d', '%d', '%d', '%d', ^"%s^", ", g_Wave, j, g_TimePerWave_SysTime[g_Wave - 1], g_Difficulty, g_MapName);
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(g_TimePerWave_Users[i][0]) {
				iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, "^"%s^", ", g_TimePerWave_Users[i]);
				g_TimePerWave_Users[i][0] = EOS;
			}
		}
		
		sQuery[iLen-2] = EOS;
		iLen -= 2;
		
		iLen += formatex(sQuery[iLen], charsmax(sQuery) - iLen, ");");
		
		SQL_ThreadQuery(g_SqlTuple, "sqlThread__InsertEndWaveStats", sQuery);
		
		/*new Handle:sqlQuery;
		sqlQuery = SQL_PrepareQuery(g_SqlConnection, "%s", sQuery);
		
		if(!SQL_Execute(sqlQuery)) {
			executeQuery(0, sqlQuery, 1337);
		} else {
			SQL_FreeHandle(sqlQuery);
		}*/
	}
	
	if(g_Wave >= MAX_WAVES) {
		if(!g_Tramposo) {
			new iTime = 0;
			
			for(i = 0; i < 11; ++i) {
				iTime += g_TimePerWave_SysTime[i];
			}

			new sQuery[168];
			formatex(sQuery, charsmax(sQuery), "INSERT INTO td_timepermap (`td_mapname`, `td_time_seconds`, `td_diff`) VALUES (^"%s^", '%d', '%d')", g_MapName, iTime, g_Difficulty);

			SQL_ThreadQuery(g_SqlTuple, "sqlThread__InsertEndMapStats", sQuery);
		}

		__endGame();
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(g_Achievement_DefensaAbsoluta) {
				if(!is_user_connected(i)) {
					continue;
				}
				
				setAchievement(i, (DEFENSA_ABSOLUTA_NOOB + g_Difficulty));
			}
			
			if(!is_user_alive(i)) {
				continue;
			}
			
			g_AchievementMap[i] = 1;
			
			reloadWeapons(i);
		}
	} else {
		switch(g_Difficulty)
		{
			case DIFF_NORMAL:
			{
				g_TotalMonsters = 44;

				set_task(49.0, "startWave", TASK_WAVES); // +5
				set_task(1.0, "repeatHUD", _, _, _, "a", 45); // +1
			}
			case DIFF_NIGHTMARE:
			{
				g_TotalMonsters = 39;

				set_task(44.0, "startWave", TASK_WAVES); // +5
				set_task(1.0, "repeatHUD", _, _, _, "a", 40); // +1
			}
			case DIFF_SUICIDAL:
			{
				g_TotalMonsters = 34;

				set_task(39.0, "startWave", TASK_WAVES); // +5
				set_task(1.0, "repeatHUD", _, _, _, "a", 35); // +1
			}
			case DIFF_HELL:
			{
				g_TotalMonsters = 29;

				set_task(34.0, "startWave", TASK_WAVES); // +5
				set_task(1.0, "repeatHUD", _, _, _, "a", 30); // +1
			}
		}
	}
	
	new iRandomGold = random_num(50, 80) * g_Wave;
	colorChat(0, _, "%sTodos los usuarios vivos ganaron !g%d Oro!y por sobrevivir a la oleada!", TD_PREFIX, iRandomGold);
	
	new iTeam;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}
		
		if(g_ClassId[i] == CLASS_INGENIERO) {
			new iClassReq = CLASSES[CLASS_INGENIERO][classReqLv1 + g_ClassLevel[i][CLASS_INGENIERO]];

			if(g_UserPremium[i]) {
				iClassReq = iClassReq - ((iClassReq * 20) / 100);
			}

			if(g_ClassReqs[i][CLASS_INGENIERO] >= iClassReq) {
				++g_ClassLevel[i][CLASS_INGENIERO];
				
				colorChat(0, CT, "%s!t%s!y subió de nivel a su !tINGENIERO!y al nivel !g%d!y", TD_PREFIX, g_UserName[i], g_ClassLevel[i][CLASS_INGENIERO]);
			}
		}
		
		if(is_user_alive(i)) {
			g_Gold[i] += iRandomGold;
			g_GoldG[i] += iRandomGold;
			
			switch(g_Difficulty) {
				case DIFF_NORMAL: ++g_WavesWins[i][DIFF_NORMAL][0];
				case DIFF_NIGHTMARE: {
					++g_WavesWins[i][DIFF_NORMAL][0];
					++g_WavesWins[i][DIFF_NIGHTMARE][0];
				}
				case DIFF_SUICIDAL: {
					++g_WavesWins[i][DIFF_NORMAL][0];
					++g_WavesWins[i][DIFF_NIGHTMARE][0];
					++g_WavesWins[i][DIFF_SUICIDAL][0];
				}
				case DIFF_HELL: {
					++g_WavesWins[i][DIFF_NORMAL][0];
					++g_WavesWins[i][DIFF_NIGHTMARE][0];
					++g_WavesWins[i][DIFF_SUICIDAL][0];
					++g_WavesWins[i][DIFF_HELL][0];
				}
			}
			
			++g_WavesWins[i][g_Difficulty][g_Wave];
			
			if(g_Difficulty >= DIFF_NORMAL) {
				if(!(g_WavesWins[i][DIFF_NORMAL][0] % 100)) {
					switch(g_WavesWins[i][DIFF_NORMAL][0]) {
						case 100: setAchievement(i, WAVES_NORMAL_100);
						case 500: setAchievement(i, WAVES_NORMAL_500);
						case 1000: setAchievement(i, WAVES_NORMAL_1000);
						case 2500: setAchievement(i, WAVES_NORMAL_2500);
						case 5000: setAchievement(i, WAVES_NORMAL_5000);
						case 10000: setAchievement(i, WAVES_NORMAL_10K);
						case 25000: setAchievement(i, WAVES_NORMAL_25K);
						case 50000: setAchievement(i, WAVES_NORMAL_50K);
						case 100000: setAchievement(i, WAVES_NORMAL_100K);
						case 250000: setAchievement(i, WAVES_NORMAL_250K);
						case 500000: setAchievement(i, WAVES_NORMAL_500K);
						case 1000000: setAchievement(i, WAVES_NORMAL_1M);
					}
				}
				
				if(g_Difficulty >= DIFF_NIGHTMARE) {
					if(!(g_WavesWins[i][DIFF_NIGHTMARE][0] % 100)) {
						switch(g_WavesWins[i][DIFF_NIGHTMARE][0]) {
							case 100: setAchievement(i, WAVES_NIGHTMARE_100);
							case 500: setAchievement(i, WAVES_NIGHTMARE_500);
							case 1000: setAchievement(i, WAVES_NIGHTMARE_1000);
							case 2500: setAchievement(i, WAVES_NIGHTMARE_2500);
							case 5000: setAchievement(i, WAVES_NIGHTMARE_5000);
							case 10000: setAchievement(i, WAVES_NIGHTMARE_10K);
							case 25000: setAchievement(i, WAVES_NIGHTMARE_25K);
							case 50000: setAchievement(i, WAVES_NIGHTMARE_50K);
							case 100000: setAchievement(i, WAVES_NIGHTMARE_100K);
							case 250000: setAchievement(i, WAVES_NIGHTMARE_250K);
							case 500000: setAchievement(i, WAVES_NIGHTMARE_500K);
							case 1000000: setAchievement(i, WAVES_NIGHTMARE_1M);
						}
					}
					
					if(g_Difficulty >= DIFF_SUICIDAL) {
						if(!(g_WavesWins[i][DIFF_SUICIDAL][0] % 100)) {
							switch(g_WavesWins[i][DIFF_SUICIDAL][0]) {
								case 100: setAchievement(i, WAVES_SUICIDAL_100);
								case 500: setAchievement(i, WAVES_SUICIDAL_500);
								case 1000: setAchievement(i, WAVES_SUICIDAL_1000);
								case 2500: setAchievement(i, WAVES_SUICIDAL_2500);
								case 5000: setAchievement(i, WAVES_SUICIDAL_5000);
								case 10000: setAchievement(i, WAVES_SUICIDAL_10K);
								case 25000: setAchievement(i, WAVES_SUICIDAL_25K);
								case 50000: setAchievement(i, WAVES_SUICIDAL_50K);
								case 100000: setAchievement(i, WAVES_SUICIDAL_100K);
								case 250000: setAchievement(i, WAVES_SUICIDAL_250K);
								case 500000: setAchievement(i, WAVES_SUICIDAL_500K);
								case 1000000: setAchievement(i, WAVES_SUICIDAL_1M);
							}
						}
						
						if(g_Difficulty == DIFF_HELL) {
							if(!(g_WavesWins[i][DIFF_HELL][0] % 100)) {
								switch(g_WavesWins[i][DIFF_HELL][0]) {
									case 100: setAchievement(i, WAVES_HELL_100);
									case 500: setAchievement(i, WAVES_HELL_500);
									case 1000: setAchievement(i, WAVES_HELL_1000);
									case 2500: setAchievement(i, WAVES_HELL_2500);
									case 5000: setAchievement(i, WAVES_HELL_5000);
									case 10000: setAchievement(i, WAVES_HELL_10K);
									case 25000: setAchievement(i, WAVES_HELL_25K);
									case 50000: setAchievement(i, WAVES_HELL_50K);
									case 100000: setAchievement(i, WAVES_HELL_100K);
									case 250000: setAchievement(i, WAVES_HELL_250K);
									case 500000: setAchievement(i, WAVES_HELL_500K);
									case 1000000: setAchievement(i, WAVES_HELL_1M);
								}
							}
						}
					}
				}
			}
			
			if(g_LevelG[i] < 100) {
				if(g_Kills[i] >= LEVELS_G[g_LevelG[i]][levelKills] &&
				g_WavesWins[i][DIFF_NORMAL][0] >= LEVELS_G[g_LevelG[i]][levelWaveNormal] &&
				g_WavesWins[i][DIFF_NIGHTMARE][0] >= LEVELS_G[g_LevelG[i]][levelWaveNightmare] &&
				g_WavesWins[i][DIFF_SUICIDAL][0] >= LEVELS_G[g_LevelG[i]][levelWaveSuicidal] &&
				g_WavesWins[i][DIFF_HELL][0] >= LEVELS_G[g_LevelG[i]][levelWaveHell] &&
				g_BossKills[i][DIFF_NORMAL] >= LEVELS_G[g_LevelG[i]][levelBossNormal] &&
				g_BossKills[i][DIFF_NIGHTMARE] >= LEVELS_G[g_LevelG[i]][levelBossNightmare] &&
				g_BossKills[i][DIFF_SUICIDAL] >= LEVELS_G[g_LevelG[i]][levelBossSuicidal] &&
				g_BossKills[i][DIFF_HELL] >= LEVELS_G[g_LevelG[i]][levelBossHell]) {
					++g_LevelG[i];
					client_print(i, print_center, "SUBISTE DE NIVEL G!");
					
					switch(g_LevelG[i]) {
						case 10: setAchievement(i, NIVEL_10G);
						case 20: setAchievement(i, NIVEL_20G);
						case 30: setAchievement(i, NIVEL_30G);
						case 40: setAchievement(i, NIVEL_40G);
						case 50: setAchievement(i, NIVEL_50G);
						case 60: setAchievement(i, NIVEL_60G);
						case 70: setAchievement(i, NIVEL_70G);
						case 80: setAchievement(i, NIVEL_80G);
						case 90: setAchievement(i, NIVEL_90G);
						case 100: setAchievement(i, NIVEL_100G);
					}
					
					++g_Points[i];

					updateRankAndHat(i);
				}
			}
			
			set_user_health(i, 100);
			g_Health[i] = 100;

			if(g_Unlimited_Clip[i]) {
				--g_UnlimitedClip_WavesLeft[i];

				if(!g_UnlimitedClip_WavesLeft[i]) {
					g_Unlimited_Clip[i] = 0;
					colorChat(i, _, "%sTus balas infinitas se terminaron!", TD_PREFIX);
				} else {
					colorChat(i, _, "%sA tus balas infinitas aún le quedan !g%d!y oleadas restantes!", TD_PREFIX, g_UnlimitedClip_WavesLeft[i]);
				}
			}

			if(g_PrecisionPerfecta[i]) {
				--g_PrecisionPerfecta_WavesLeft[i];

				if(!g_PrecisionPerfecta_WavesLeft[i]) {
					g_PrecisionPerfecta[i] = 0;
					colorChat(i, _, "%sTu precisión perfecta se terminaron", TD_PREFIX);
				} else {
					colorChat(i, _, "%sA tu precisión perfecta aun le quedan !g%d!y oleadas restantes", TD_PREFIX, g_PrecisionPerfecta_WavesLeft[i]);
				}
			}

			continue;
		}
		
		iTeam = getUserTeam(i);
		if(iTeam == FM_CS_TEAM_UNASSIGNED || iTeam == FM_CS_TEAM_SPECTATOR) {
			continue;
		}
		
		ExecuteHamB(Ham_CS_RoundRespawn, i);
	}
	
	new iUsers = 0;
	new iMaxId = 0;
	new iMaxKills = 0;
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i))
			continue;
		
		++iUsers;
		
		if(g_KillsPerWave[i][g_Wave] > iMaxKills) {
			iMaxKills = g_KillsPerWave[i][g_Wave];
			iMaxId = i;
		}
	}
	
	if(iUsers > 1 && iMaxId) {
		new iRepeat = 0;
		new sUserNames[MAX_USERS][32];
		new j = 0;
		new k;
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(!is_user_connected(i)) {
				continue;
			}
			
			if(i == iMaxId) {
				continue;
			}
			
			if(g_KillsPerWave[i][g_Wave] == iMaxKills) {
				copy(sUserNames[j], 31, g_UserName[i]);
				
				++iRepeat;
				++j;
			}
		}
		
		iRandomGold /= (2 + iRepeat);
		
		colorChat(0, CT, "%sEl usuario !t%s!y ganó !g%d Oro!y por ser el que más monstruos mató (!g%d!y)", TD_PREFIX, g_UserName[iMaxId], iRandomGold, iMaxKills);
		
		g_Gold[iMaxId] += iRandomGold;
		g_GoldG[iMaxId] += iRandomGold;
		
		if(j) {
			for(k = 0; k < j; ++k) {
				colorChat(0, CT, "%sEl usuario !t%s!y ganó !g%d Oro!y por ser el que más monstruos mató (!g%d!y)", TD_PREFIX, sUserNames[k], iRandomGold, iMaxKills);
			}
			
			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!is_user_connected(i)) {
					continue;
				}
				
				if(i == iMaxId) {
					continue;
				}
				
				if(g_KillsPerWave[i][g_Wave] == iMaxKills) {
					g_Gold[i] += iRandomGold;
					g_GoldG[i] += iRandomGold;
				}
			}
		}
		
		if(getUsersPlaying() > 2) {
			++g_WinMVP[iMaxId];
			++g_WinMVPGaben[iMaxId];
			
			if(g_WinMVPGaben[iMaxId] == 1) {
				setAchievement(iMaxId, MVP_1);
			}
			
			if(!(g_WinMVPGaben[iMaxId] % 5)) {
				switch(g_WinMVPGaben[iMaxId]) {
					case 10: setAchievement(iMaxId, MVP_10);
					case 25: setAchievement(iMaxId, MVP_25);
					case 50: setAchievement(iMaxId, MVP_50);
					case 100: setAchievement(iMaxId, MVP_100);
					case 250: setAchievement(iMaxId, MVP_250);
					case 500: setAchievement(iMaxId, MVP_500);
					case 1000: setAchievement(iMaxId, MVP_1000);
					case 2500: setAchievement(iMaxId, MVP_2500);
					case 5000: setAchievement(iMaxId, MVP_5000);
					case 10000: setAchievement(iMaxId, MVP_10K);
					case 25000: setAchievement(iMaxId, MVP_25K);
					case 50000: setAchievement(iMaxId, MVP_50K);
					case 100000: setAchievement(iMaxId, MVP_100K);
					case 250000: setAchievement(iMaxId, MVP_250K);
					case 500000: setAchievement(iMaxId, MVP_500K);
					case 1000000: setAchievement(iMaxId, MVP_1M);
				}
			}
			
			if(g_WinMVP_Last == iMaxId || !g_WinMVP_Last) {
				++g_WinMVP_Next[iMaxId];
				
				switch(g_WinMVP_Next[iMaxId]) {
					case 2: setAchievement(iMaxId, MVP_2C);
					case 3: setAchievement(iMaxId, MVP_3C);
					case 4: setAchievement(iMaxId, MVP_4C);
					case 5: setAchievement(iMaxId, MVP_5C);
					case 6: setAchievement(iMaxId, MVP_6C);
					case 7: setAchievement(iMaxId, MVP_7C);
					case 8: setAchievement(iMaxId, MVP_8C);
					case 9: setAchievement(iMaxId, MVP_9C);
					case 10: setAchievement(iMaxId, MVP_10C);
				}
			} else {
				for(i = 1; i <= g_MaxUsers; ++i) {
					g_WinMVP_Next[i] = 0;
				}
				
				++g_WinMVP_Next[iMaxId];
			}
		}
		
		g_WinMVP_Last = iMaxId;
	}
}

public __lightsOff() {
	if(g_BossId != BOSS_GUARDIANES) {
		set_lights("#OFF");
	} else {
		set_lights(g_Lights[0]);
	}
}

public fw_AddToFullPack__BOSS_Post(const es_handle, const e, const ent, const host, const hostflags, const player, const set) {
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

public fw_AddToFullPack__GUARDIANS_P(const es_handle, const e, const ent, const host, const hostflags, const player, const set) {
	if(player || !is_user_connected(host)) {
		return FMRES_IGNORED;
	}
	
	if(g_Boss_Guardians_HealthBar[0] == ent && is_valid_ent(g_Boss_Guardians_Ids[0])) {
		static Float:vecOrigin[3];
		entity_get_vector(g_Boss_Guardians_Ids[0], EV_VEC_origin, vecOrigin);
		
		vecOrigin[2] += 65.0;
		
		set_es(es_handle, ES_Origin, vecOrigin);
	} else if(g_Boss_Guardians_HealthBar[1] == ent && is_valid_ent(g_Boss_Guardians_Ids[1])) {
		static Float:vecOrigin[3];
		entity_get_vector(g_Boss_Guardians_Ids[1], EV_VEC_origin, vecOrigin);
		
		vecOrigin[2] += 65.0;
		
		set_es(es_handle, ES_Origin, vecOrigin);
	}
	
	return FMRES_IGNORED;
}

setAchievement(const id, const achievement) { // s_ach
	if(!g_AccountLogged[id]) {
		return;
	}

	if(g_Achievement[id][achievement]) {
		return;
	}
	
	if(LOGROS[achievement][logroUsersNeed]) {
		if(getUsersPlaying() < LOGROS[achievement][logroUsersNeed]) {
			return;
		}
	}
	
	g_Achievement[id][achievement] = 1;
	g_AchievementUnlock[id][achievement] = getTimeToUnix();

	new sQuery[300];
	formatex(sQuery, charsmax(sQuery), "INSERT INTO td_achievements (`td_id`, `username`, `achievement_id`, `achievement_name`, `achievement_date`) VALUES ('%d', ^"%s^", '%d', ^"%s^", unix_timestamp());", g_UserId[id], g_UserName[id], achievement, LOGROS[achievement][logroName]);
	SQL_ThreadQuery(g_SqlTuple, "sqlThread__InsertAchievement", sQuery);

	switch(LOGROS[achievement][logroReward]) {
		case 1337: {
			colorChat(0, CT, "%s!t%s!y ganó el logro !g%s!y !t(Balas Infinitas desbloqueadas)!y", TD_PREFIX, g_UserName[id], LOGROS[achievement][logroName]);
		} case 1338: {
			colorChat(0, CT, "%s!t%s!y ganó el logro !g%s!y !t(Aimbot desbloqueado)!y", TD_PREFIX, g_UserName[id], LOGROS[achievement][logroName]);
		} case 1339: {
			colorChat(0, CT, "%s!t%s!y ganó el logro !g%s!y !t(Pistolero desbloqueado)!y", TD_PREFIX, g_UserName[id], LOGROS[achievement][logroName]);
		} default: {
			colorChat(0, CT, "%s!t%s!y ganó el logro !g%s!y !t(%d Os)!y", TD_PREFIX, g_UserName[id], LOGROS[achievement][logroName], LOGROS[achievement][logroReward]);
			g_Osmio[id] += LOGROS[achievement][logroReward];
		}
	}
	
	++g_AchievementCount[id];

	if(g_Tramposo) {
		if(LOGROS[achievement][logroClass] == LOGRO_MAPAS ||
		LOGROS[achievement][logroClass] == LOGRO_BOSSES ||
		(achievement >= DEFENSA_ABSOLUTA_NOOB && achievement <= DEFENSA_ABSOLUTA_PRO)) {
			setAchievement(id, TRAMPOSO);
			return;
		}
	}

	if(achievement >= BOSS_GUARDIANES_NOOB && achievement <= BOSS_GUARDIANES_PRO) {
		if(achievement >= BOSS_GUARDIANES_NOOB) {
			setAchievement(id, BALAS_INFINITAS);
		}

		return;
	}
	
	saveInfo(id);
}

public getUnixToTime(const unix)
{
	static sTime[32];
	sTime[0] = EOS;

	if(!unix)
	{
		formatex(sTime, 31, "Ninguno");
		return sTime;
	}

	static iDay;
	static iMonth;
	static iYear;
	static iHour;
	static iMinute;
	static iSecond;

	unix_to_time(unix, iYear, iMonth, iDay, iHour, iMinute, iSecond);

	static sDay[4];
	static sMonth[4];
	static sHour[4];
	static sMinute[4];
	static sSecond[4];

	formatex(sMonth, 3, "%s%d", (iMonth < 10) ? "0" : "", iMonth);
	formatex(sDay, 3, "%s%d", (iDay < 10) ? "0" : "", iDay);
	formatex(sHour, 3, "%s%d", (iHour < 10) ? "0" : "", iHour);
	formatex(sMinute, 3, "%s%d", (iMinute < 10) ? "0" : "", iMinute);
	formatex(sSecond, 3, "%s%d", (iSecond < 10) ? "0" : "", iSecond);
	formatex(sTime, 31, "%s-%s-%d - %s:%s:%s", sDay, sMonth, iYear, sHour, sMinute, sSecond);

	if(!sTime[0])
	{
		formatex(sTime, 31, "Ninguno");
		return sTime;
	}

	return sTime;
}

public getTimeToUnix()
{
	static sHour[4];
	static sMinute[4];
	static sSecond[4];
	static iDate[3];
	static iUnix;

	get_time("%H", sHour, 3);
	get_time("%M", sMinute, 3);
	get_time("%S", sSecond, 3);

	date(iDate[0], iDate[1], iDate[2]);
	iUnix = time_to_unix(iDate[0], iDate[1], iDate[2], str_to_num(sHour), str_to_num(sMinute), str_to_num(sSecond));

	if(!iUnix)
		return -1;

	return iUnix;
}

stock Float:getVelocity() {
	new Float:fVelocity;
	
	switch(g_SpecialWave) {
		case ROUND_SPECIAL_SPEED: {
			fVelocity = 350.0;
		} case ROUND_SPECIAL_STRENGTH: {
			return 110.0;
		} default: {
			fVelocity = 220.0 + float((g_Wave * 2));
		}
	}

	if(DIFFICULTIES_VALUES[g_Difficulty][difficultySpeed]) {
		fVelocity = fVelocity + ((fVelocity * DIFFICULTIES_VALUES[g_Difficulty][difficultySpeed]) / 100.0);
	}
	
	return Float:fVelocity;
}

public checkAchievements(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	if(g_GoldGaben[id] >= 10000) {
		setAchievement(id, GOLD_10K);
		
		if(g_GoldGaben[id] >= 50000) {
			setAchievement(id, GOLD_50K);
			
			if(g_GoldGaben[id] >= 100000) {
				setAchievement(id, GOLD_100K);
				
				if(g_GoldGaben[id] >= 500000) {
					setAchievement(id, GOLD_500K);
					
					if(g_GoldGaben[id] >= 1000000) {
						setAchievement(id, GOLD_1M);
						
						if(g_GoldGaben[id] >= 2500000) {
							setAchievement(id, GOLD_2M500K);
							
							if(g_GoldGaben[id] >= 5000000) {
								setAchievement(id, GOLD_5M);
								
								if(g_GoldGaben[id] >= 10000000) {
									setAchievement(id, GOLD_10M);
									
									if(g_GoldGaben[id] >= 25000000) {
										setAchievement(id, GOLD_25M);
										
										if(g_GoldGaben[id] >= 50000000) {
											setAchievement(id, GOLD_50M);
											
											if(g_GoldGaben[id] >= 100000000) {
												setAchievement(id, GOLD_100M);
												
												if(g_GoldGaben[id] >= 500000000) {
													setAchievement(id, GOLD_500M);
													
													if(g_GoldGaben[id] >= 1000000000) {
														setAchievement(id, GOLD_1000M);
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
	
	if(!g_Achievement[id][WAVES_NIGHTMARE_100]) {
		if(g_WavesWins[id][DIFF_NIGHTMARE][0] >= 100) {
			setAchievement(id, WAVES_NIGHTMARE_100);
		}
	}
	
	if(!g_Achievement[id][MVP_10]) {
		if(g_WinMVPGaben[id] >= 1) {
			setAchievement(id, MVP_1);
			
			if(g_WinMVPGaben[id] >= 10) {
				setAchievement(id, MVP_10);
				
				if(g_WinMVPGaben[id] >= 25) {
					setAchievement(id, MVP_25);
					
					if(g_WinMVPGaben[id] >= 50) {
						setAchievement(id, MVP_50);
						
						if(g_WinMVPGaben[id] >= 100) {
							setAchievement(id, MVP_100);
							
							if(g_WinMVPGaben[id] >= 250) {
								setAchievement(id, MVP_250);
							}
						}
					}
				}
			}
		}
	}
	
	if(g_LevelG[id] >= 10) {
		setAchievement(id, NIVEL_10G);
	}
	
	if(g_AccountVinc[id]) {
		setAchievement(id, VINCULADO);
	}

	if(g_Achievement[id][BOSS_GUARDIANES_NOOB]) {
		setAchievement(id, BALAS_INFINITAS);
	}
}

stock isStuck(const id) {
	new Float:vecOrigin[3];
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, HULL_HUMAN, id, 0);
	
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen)) {
		return 1;
	}
	
	return 0;
}

// public specialHeal(const taskid) {
	// entity_set_float(ID_SPECIAL_HEAL, EV_FL_health, entity_get_float(ID_SPECIAL_HEAL, EV_FL_health) + 100.0);
	
	// set_task(3.0, "specialHeal", ID_SPECIAL_HEAL + TASK_SPECIAL_HEAL);
// }

public think__CheckAFK(const ent) {
	if(g_WaveInProgress && g_TotalMonsters > 1 && g_Wave < 11) {
		new i;
		new iTimeAFK;
		
		for(i = 1; i <= g_MaxUsers; ++i) {
			if(is_user_alive(i) && !(get_user_flags(i) & ADMIN_BAN)) {
				if(!g_AFK_Damage[i]) {
					g_AFK_Time[i] += TIME_CHECK_AFK;
					
					if(g_AFK_Time[i] >= 120) {
						server_cmd("kick #%d ^"Has estado ausente por mas de 120 segundos^"", get_user_userid(i));
						colorChat(0, _, "!g[DRUNK GAMING]!y %s ha sido expulsado por estar AFK demasiado tiempo", g_UserName[i]);
					} else {
						iTimeAFK = (120 - floatround(g_AFK_Time[i]));
						if(iTimeAFK <= 20) {
							colorChat(i, _, "!g[DRUNK GAMING]!y Tenés %d segundos para realizar daño o serás expulsado por AFK.", iTimeAFK);
						}
					}
				} else {
					g_AFK_Time[i] = 0.0;
					g_AFK_Damage[i] = 0;
				}
			}
		}
	}
	
	entity_set_float(ent, EV_FL_nextthink, THINK_CHECK_AFK);
}

public showMenu__Stats(const id) {
	new iMenu;
	new sItem[128];
	new sKillsDot[15];
	new sMVPDot[15];
	new sGoldDot[15];
	
	addDot(g_Kills[id], sKillsDot, 14);
	addDot(g_WinMVPGaben[id], sMVPDot, 14);
	addDot(g_GoldGaben[id], sGoldDot, 14);
	
	iMenu = menu_create("ESTADÍSTICAS Y OTROS", "menu__Stats");
	
	formatex(sItem, 127, "VER TOPS^n^nMATADOS\r: \y%s^n\wLOGROS\r: \y%d^n\wMVP GANADOS\r: \y%s^n\wORO GANADO\r: \y%s^n", sKillsDot, g_AchievementCount[id], sMVPDot, sGoldDot);

	menu_additem(iMenu, sItem, "1");
	menu_additem(iMenu, "VER TUTORIAL", "2");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__Stats(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Game(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	DestroyLocalMenu(id, menuId);
	
	switch(iItem) {
		case 1: {
			showMenu__TOPS(id);
		} case 2: {
			showMenu__Tutorial(id, 0);
		}
	}
	
	return PLUGIN_HANDLED;
}

public showMenu__TOPS(const id) {
	new iMenu;	
	iMenu = menu_create("TOPS", "menu__TOPS");
	
	menu_additem(iMenu, "MEJORES JUGADORES^n", "1");

	menu_additem(iMenu, "VER TOPS POR CLASES", "2");
	menu_additem(iMenu, "LOGROS DESBLOQUEADOS", "3");
	menu_additem(iMenu, "MAYOR CANTIDAD DE MVP", "4");
	menu_additem(iMenu, "MAYOR CANTIDAD DE ORO^n", "5");

	menu_additem(iMenu, "VER TOPS POR MAPA", "6");

	menu_setprop(iMenu, MPROP_BACKNAME, "PÁG. ANTERIOR");
	menu_setprop(iMenu, MPROP_NEXTNAME, "PÁG. SIGUIENTE");
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	g_MenuPage_TOPS[id] = min(g_MenuPage_TOPS[id], menu_pages(iMenu) - 1);

	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, g_MenuPage_TOPS[id]);
}

new const TOPS_15[][] = {
	"top15_mejores_jugadores.php",
	"",
	"top15_logros_desbloqueados.php",
	"top15_mayor_cantidad_mvp.php",
	"top15_mayor_cantidad_oro.php"
};

public menu__TOPS(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}

	new iMenuDummy;
	player_menu_info(id, iMenuDummy, iMenuDummy, g_MenuPage_TOPS[id]);
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__Stats(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	DestroyLocalMenu(id, menuId);

	if(iItem == 1) {
		showMenu__TOPS_Classes(id);
		return PLUGIN_HANDLED;
	} else if(iItem == 5) {
		showMenu__TOPS_Maps(id);
		return PLUGIN_HANDLED;
	}
	
	if(g_SysTime_TOPS[id] > get_gametime()) {
		colorChat(id, _, "%sTenés que esperar !g2 segundos!y para ver otro !gTOP!y", TD_PREFIX);
		
		showMenu__TOPS(id);
		return PLUGIN_HANDLED;
	}
	
	g_SysTime_TOPS[id] = get_gametime() + 2.0;
	
	new sTOP_URL[300];
	formatex(sTOP_URL, 299, "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=http://www.drunk-gaming.com/servidores/27060/top15/%s?id=%d^"></head><body><p>Cargando...</p></body></html>", TOPS_15[iItem], g_UserId[id]);
	
	show_motd(id, sTOP_URL, "TOP 15");
	
	showMenu__TOPS(id);
	return PLUGIN_HANDLED;
}

public showMenu__TOPS_Classes(const id) {
	new iMenu;	
	iMenu = menu_create("TOPS DE CLASES", "menu__TOPS_Classes");
	
	menu_additem(iMenu, "MEJORES SOLDADOS", "1");
	menu_additem(iMenu, "MEJORES INGENIEROS", "2");
	menu_additem(iMenu, "MEJORES SOPORTES", "3");
	menu_additem(iMenu, "MEJORES FRANCOTIRADORES", "4");
	menu_additem(iMenu, "MEJORES APOYOS", "5");
	menu_additem(iMenu, "MEJORES PESADOS", "6");
	menu_additem(iMenu, "MEJORES ASALTANTES", "7");
	menu_additem(iMenu, "MEJORES COMANDANTES", "8");

	menu_addblank(iMenu, 1);

	menu_additem(iMenu, "VOLVER", "0");
	
	menu_setprop(iMenu, MPROP_PERPAGE, 0);
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

new const TOPS_15_CLASSES[][] = {
	"top15_mejores_soldados.php",
	"top15_mejores_ingenieros.php",
	"top15_mejores_soportes.php",
	"top15_mejores_francotiradores.php",
	"top15_mejores_apoyo.php",
	"top15_mejores_pesado.php",
	"top15_mejores_asalto.php",
	"top15_mejores_comandante.php"
};

public menu__TOPS_Classes(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__TOPS(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;
	
	DestroyLocalMenu(id, menuId);

	if(iItem == -1) {
		showMenu__TOPS(id);
		return PLUGIN_HANDLED;
	}
	
	if(g_SysTime_TOPS[id] > get_gametime()) {
		colorChat(id, _, "%sTenés que esperar !g2 segundos!y para ver otro !gTOP!y", TD_PREFIX);
		
		showMenu__TOPS(id);
		return PLUGIN_HANDLED;
	}
	
	g_SysTime_TOPS[id] = get_gametime() + 2.0;
	
	new sTOP_URL[300];
	formatex(sTOP_URL, 299, "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=http://www.drunk-gaming.com/servidores/27060/top15/%s?id=%d^"></head><body><p>Cargando...</p></body></html>", TOPS_15_CLASSES[iItem], g_UserId[id]);
	
	show_motd(id, sTOP_URL, "TOP 15");
	
	showMenu__TOPS_Classes(id);
	return PLUGIN_HANDLED;
}

public showMenu__TOPS_Maps(const id) {
	new iMenu;	
	iMenu = menu_create("TOPS POR MAPA", "menu__TOPS_Maps");
	
	new sMapName[64];
	formatex(sMapName, charsmax(sMapName), "MAPA: \y%s^n", MAPS_DESC[g_Top15_MapId[id]][mapName]);

	menu_additem(iMenu, sMapName, "1");

	menu_additem(iMenu, "VER TOP", "2");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	ShowLocalMenu(id, iMenu, 0);
}

public menu__TOPS_Maps(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		DestroyLocalMenu(id, menuId);
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		DestroyLocalMenu(id, menuId);
		
		showMenu__TOPS(id);
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer);
	
	DestroyLocalMenu(id, menuId);

	switch(iItem) {
		case 1: {
			if(++g_Top15_MapId[id] >= mapsIds) {
				g_Top15_MapId[id] = 0;
			}
		} case 2: {
			if(g_SysTime_TOPS[id] > get_gametime()) {
				colorChat(id, _, "%sTenés que esperar !g2 segundos!y para ver otro !gTOP!y", TD_PREFIX);
				
				showMenu__TOPS_Maps(id);
				return PLUGIN_HANDLED;
			}

			g_SysTime_TOPS[id] = get_gametime() + 2.0;
			
			new sTOP_URL[300];
			formatex(sTOP_URL, 299, "<html><head><style>body {background:#000;color:#FFF;</style><meta http-equiv=^"Refresh^" content=^"0;url=http://www.drunk-gaming.com/servidores/27060/top15/top15_waves.php?map=%s^"></head><body><p>Cargando...</p></body></html>", MAPS_DESC[g_Top15_MapId[id]][mapName]);
			
			show_motd(id, sTOP_URL, "TOP 15");
		}
	}
	
	showMenu__TOPS_Maps(id);
	return PLUGIN_HANDLED;
}

/*public rememberVinc(const taskid) {
	colorChat(ID_VINC, _, "%sTu cuenta no está vinculada al foro, recordá vincularla lo más pronto posible.", TD_PREFIX);
	colorChat(ID_VINC, _, "%sVincular tu cuenta ofrece varias opciones/funciones, entre ellas, recuperar/cambiar tu contraseña", TD_PREFIX);
	
	set_task(180.0, "rememberVinc", ID_VINC + TASK_VINC);
}*/

public impulse_Flashlight(const id) {
	if(is_user_alive(id)) {
		if(g_ClassId[id] == CLASS_SOPORTE && g_ClassLevel[id][CLASS_SOPORTE] >= 5) {
			if(!g_SupportHab[id]) {
				if(g_CurrentWeapon[id] == CSW_XM1014) {
					new iWeaponId;
					new iExtraClip;
					
					iWeaponId = fm_find_ent_by_owner(-1, "weapon_xm1014", id);
					
					iExtraClip = 7;
					
					if(g_HabCacheClip[id]) {
						iExtraClip = iExtraClip + ((iExtraClip * g_HabCacheClip[id]) / 100);
					}
					
					iExtraClip += CLASSES_ATTRIB[CLASS_SOPORTE][g_ClassLevel[id][CLASS_SOPORTE]][classAttrib_Clip];
					
					if((cs_get_weapon_ammo(iWeaponId) == iExtraClip) && (cs_get_user_bpammo(id, CSW_XM1014) >= 200)) {
						return PLUGIN_HANDLED;
					}
					
					g_SupportHab[id] = 1;
					
					cs_set_weapon_ammo(iWeaponId, iExtraClip);
					cs_set_user_bpammo(id, CSW_XM1014, 200);
				}
			} else {
				client_print(id, print_center, "Ya usaste tu habilidad de SOPORTE en esta oleada!");
			}
		} else if(g_ClassLevel[id][CLASS_SCOUTER] == 6 && g_ClassId[id] == CLASS_SCOUTER) {
			if(!g_PoderScouter[id]) {
				if(g_CurrentWeapon[id] == CSW_SCOUT) {
					g_PoderScouter[id] = 1;
					set_task(10.5, "task__RemovePowerScouter", id);
				}
			} else {
				client_print(id, print_center, "Ya usaste tu habilidad de SCOUTER en esta oleada!");
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public task__RemovePowerScouter(const id) {
	g_PoderScouter[id] = 2;
}

public showMenu__Upgrades(const id) {
	static sMenu[450];
	static iStartLoop;
	static iEndLoop;
	static iLen;
	static iCost;
	static i;
	static j;
	
	iLen = 0;
	iStartLoop = (g_MenuPage_Upgrades[id] * 3);
	iEndLoop = clamp(((g_MenuPage_Upgrades[id] + 1) * 3), 0, structHabilities);
	
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yMEJORAS \r[%d - %d]^n\wOs\r: \y%d^n^n", (iStartLoop + 1), iEndLoop, g_Osmio[id]);
	
	for(i = iStartLoop; i < iEndLoop; ++i) {
		j = (i + 1 - (g_MenuPage_Upgrades[id] * 3));
		iCost = (g_Upgrades[id][i] + 1) * __HABILITIES[i][upgCost];
		
		if(g_Osmio[id] >= iCost) {
			if(g_Upgrades[id][i] < __HABILITIES[i][upgMaxLevel]) {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r%d.\w %s\w [\y%d\r /\y %d\w][Costo\r:\y %d\w]^n^t\r- \d%s^n^n", j, __HABILITIES[i][menuHabName], g_Upgrades[id][i], __HABILITIES[i][upgMaxLevel], iCost, __HABILITIES[i][menuHabInfo]);
			} else {
				iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r%d.\y %s\w [\y%d\r /\y %d\w]\y[FULL]^n^t\r- \d%s^n^n", j, __HABILITIES[i][menuHabName], g_Upgrades[id][i], __HABILITIES[i][upgMaxLevel], __HABILITIES[i][menuHabInfo]);
			}
		} else {
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r%d.\d %s [%d\r /\d %d][Costo\r:\d %d]^n^t\r- \d%s^n^n", j, __HABILITIES[i][menuHabName], g_Upgrades[id][i], __HABILITIES[i][upgMaxLevel], iCost, __HABILITIES[i][menuHabInfo]);
		}
	}
	
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n\r9.\w Atrás/Siguiente^n\r0. \wVolver");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "Upgrades Menu");
	
	return PLUGIN_HANDLED;
}

public menu__Upgrades(const id, const key) {
	new iSelection;
	iSelection = (g_MenuPage_Upgrades[id] * 3) + key;
	
	if(key >= 3 || iSelection >= structHabilities) {
		switch(key) {
			case 8: {
				if(((g_MenuPage_Upgrades[id] + 1) * 3) < structHabilities) {
					++g_MenuPage_Upgrades[id];
				} else {
					g_MenuPage_Upgrades[id] = 0;
				}
				
				showMenu__Upgrades(id);
			}
			case 9: {
				showMenu__Game(id);
			}
			default: {
				showMenu__Upgrades(id);
			}
		}
		
		return PLUGIN_HANDLED;
	}
	
	new iCost;
	iCost = (g_Upgrades[id][iSelection] + 1) * __HABILITIES[iSelection][upgCost];
	
	if(g_Osmio[id] >= iCost) {
		if(g_Upgrades[id][iSelection] < __HABILITIES[iSelection][upgMaxLevel]) {
			g_Osmio[id] -= iCost;
			g_OsmioLost[id] += iCost;
			
			++g_Upgrades[id][iSelection];
			
			switch(iSelection) {
				case HAB_CRITICO: {
					g_CriticChance[id] = __HABILITIES[HAB_CRITICO][upgValue] * g_Upgrades[id][HAB_CRITICO];
				} case HAB_SPEED: {
					g_Speed[id] = 230.0 + float((__HABILITIES[HAB_SPEED][upgValue] * g_Upgrades[id][HAB_SPEED]));
					
					ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
				}
			}
			
			if(g_Upgrades[id][HAB_UNLOCK_APOYO] && g_Upgrades[id][HAB_UNLOCK_PESADO] && g_Upgrades[id][HAB_UNLOCK_ASALTO] && g_Upgrades[id][HAB_UNLOCK_COMANDANTE]) {
				setAchievement(id, COMPRADOR_COMPULSIVO);
			}
		}
	}
	
	showMenu__Upgrades(id);
	return PLUGIN_HANDLED;
}

public message__CurWeapon(const msg_id, const msg_dest, const msg_entity) {
	if(g_Unlimited_Clip[msg_entity] ||
	(g_ClassLevel[msg_entity][CLASS_PISTOLERO] == 6 && g_ClassId[msg_entity] == CLASS_PISTOLERO && g_CurrentWeapon[msg_entity] == CSW_DEAGLE) ||
	(g_ClassLevel[msg_entity][CLASS_BITERO] == 6 && g_ClassId[msg_entity] == CLASS_BITERO && (g_CurrentWeapon[msg_entity] == CSW_MAC10 || g_CurrentWeapon[msg_entity] == CSW_TMP))) {
		if(get_msg_arg_int(1) != 1) {
			return;
		}
		
		static iWeapon;
		iWeapon = get_msg_arg_int(2);
		
		if(MAX_BPAMMO[iWeapon] > 2) {
			static iWeaponEnt;
			iWeaponEnt = getCurrentWeaponEnt(msg_entity);
			
			if(pev_valid(iWeaponEnt)) {
				set_pdata_int(iWeaponEnt, OFFSET_CLIPAMMO, 100, OFFSET_LINUX_WEAPONS);
			}
			
			set_msg_arg_int(3, get_msg_argtype(3), 100);
		}
	}
}

public getCurrentWeaponEnt(const id) {
	if(pev_valid(id) != PDATA_SAFE) {
		return -1;
	}
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

public fw_WeaponFireRate_Fix(const __weaponEnt) {
	if(pev_valid(__weaponEnt) == PDATA_SAFE) {
		set_pdata_float(__weaponEnt, OFFSET_LAST_FIRE_TIME, 0.0, OFFSET_LINUX_WEAPONS);
	}
}

public fw_ResetMaxSpeed__Post(const id) {
	if(!is_user_alive(id)) {
		return;
	}
	
	setUserMaxspeed(id);
}

public setUserMaxspeed(const id) {
	set_user_maxspeed(id, g_Speed[id]);
}

public think__Boss_FireMonster(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(iEnt, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:fDistance;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		static Float:flGameTime;
		static iRandom;
		
		flGameTime = get_gametime();
		
		if(fDistance <= 260.0) {
			if(g_BossPower[0] != BOSS_POWER_DASH) {
				entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
				
				if(!g_BossPower[0] && g_Boss_TimePower[0] <= flGameTime) {
					if(random_num(0, 1)) {
						g_BossPower[0] = BOSS_POWER_EXPLODE;
						g_Boss_TimePower[0] = flGameTime + 5.0;
						
						entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
						
						entity_set_int(iEnt, EV_INT_sequence, 11);
						entity_set_float(iEnt, EV_FL_animtime, flGameTime);
						entity_set_float(iEnt, EV_FL_framerate, 1.0);
						
						entity_set_int(iEnt, EV_INT_gamestate, 1);
						
						entity_set_int(iEnt, MONSTER_TARGET, 0);
						
						emit_sound(iEnt, CHAN_BODY, SOUND_BOSS_EXPLODE, 0.8, ATTN_NORM, 0, PITCH_NORM);
						
						g_BossPower_Explode = 3;
						set_task(0.25, "bossPower_Explode", _, _, _, "a", 3);
						
						entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 2.6);
						
						return;
					}
				}
				
				emit_sound(iVictim, CHAN_BODY, SOUND_BOSS_PHIT[random_num(0, 2)], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(iEnt, EV_INT_sequence, 8);
				entity_set_float(iEnt, EV_FL_animtime, flGameTime);
				entity_set_float(iEnt, EV_FL_framerate, 3.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				static Float:vecSub[3];
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub); // vec1 - vec2
				xs_vec_mul_scalar(vecSub, 200.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				// set_user_health(iVictim, 1000000);
				
				entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 0.788889);
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, (DIFFICULTIES_VALUES[g_Difficulty][difficultyBossGorilaDamage] * 1.5), DMG_SLASH);
				
				return;
			}
		} else {
			static Float:fVelocity;
			
			if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
				entity_set_int(iEnt, EV_INT_gamestate, 3);

				entity_set_int(iEnt, EV_INT_sequence, 4);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				
				fVelocity = 265.0;
				
				entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
			}

			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, fVelocity, .iAngleMode=1);
			
			if(!g_BossPower[0] && g_Boss_TimePower[0] <= flGameTime) {
				iRandom = random_num(1, 5);
				switch(iRandom) {
					case 1, 3, 5: {
						entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
						
						switch(iRandom) {
							case 1: {
								g_BossPower[0] = BOSS_POWER_DASH;
								
								g_Boss_TimePower[0] = flGameTime + 15.0;
								
								entity_set_int(iEnt, EV_INT_sequence, 5);
								
								set_task(1.533333, "bossPower_Dash");
								
								entity_set_int(iEnt, MONSTER_TARGET, 0);
							} case 3: {
								g_BossPower[0] = BOSS_POWER_FIREBALL_X2;
								g_Boss_TimePower[0] = flGameTime + 6.0;
								
								new iUserId[MAX_USERS];
								new j = 0;
								
								for(iRandom = 1; iRandom <= g_MaxUsers; ++iRandom) {
									if(!is_user_alive(iRandom)) {
										continue;
									}
									
									iUserId[j] = iRandom;
									
									++j;
								}
								
								iRandom = iUserId[random_num(0, (j-1))];
								
								if(is_user_alive(iRandom)) {
									entity_get_vector(iRandom, EV_VEC_origin, vecVictimOrigin);
									
									entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
									
									entity_set_int(iEnt, MONSTER_TARGET, iRandom);
								}
								
								entity_set_int(iEnt, EV_INT_sequence, 9);
								
								client_cmd(0, "spk ^"%s^"", SOUND_BOSS_FIREBALL_LAUNCH2);
								
								set_task(1.2, "bossPower_FireBall_x2");
								
								entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 4.366667);
							} case 5: {
								g_BossPower[0] = BOSS_POWER_FIREBALL_X4;
								g_Boss_TimePower[0] = flGameTime + 8.0;
								
								entity_set_int(iEnt, EV_INT_sequence, 10);
								
								client_cmd(0, "spk ^"%s^"", SOUND_BOSS_FIREBALL_LAUNCH4);
								
								set_task(1.2, "bossPower_FireBall_x4");
								
								entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 5.366667);
							}
						}
						
						entity_set_float(iEnt, EV_FL_animtime, flGameTime);
						entity_set_float(iEnt, EV_FL_framerate, 1.0);
						
						entity_set_int(iEnt, EV_INT_gamestate, 1);
						
						return;
					} default: {
						g_Boss_TimePower[0] = flGameTime + 3.0;
					}
				}
			}
			
			iVictim = miniBoss__SearchHuman(iEnt);
			entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		}
	} else {
		iVictim = miniBoss__SearchHuman(iEnt);
		entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(iEnt, EV_INT_sequence, 1);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 1.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			return;
		}
	}
	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
}

public bossPower_Explode() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static Float:vecExplosion[8][3];
	static Float:vecBallPlace[8][3];
	static i;
	
	entity_get_vector(i, EV_VEC_origin, vecExplosion[0]);
	
	createExplosion(vecExplosion[0], 255, 0, 0);
	
	switch(g_BossPower_Explode) {
		case 3: {
			vecExplosion[3][1] = vecExplosion[4][0] = -100.0;
			
			vecExplosion[3][0] = vecExplosion[5][0] = vecExplosion[5][1] = vecExplosion[6][1] = vecExplosion[7][1] = -50.0;
			
			vecExplosion[0][1] = vecExplosion[0][2] = vecExplosion[1][2] = vecExplosion[2][0] = vecExplosion[2][2] = vecExplosion[3][2] =
			vecExplosion[4][1] = vecExplosion[4][2] = vecExplosion[5][2] = vecExplosion[6][0] = vecExplosion[6][2] = vecExplosion[7][2] = 0.0;
			
			vecExplosion[1][0] = vecExplosion[1][1] = vecExplosion[7][0] = 50.0;
			
			vecExplosion[0][0] = vecExplosion[2][1] = 100.0;
		} case 2: {
			vecExplosion[3][1] = vecExplosion[4][0] = -200.0;
			
			vecExplosion[3][0] = vecExplosion[5][0] = vecExplosion[5][1] = vecExplosion[6][1] = vecExplosion[7][1] = -100.0;
			
			vecExplosion[0][1] = vecExplosion[0][2] = vecExplosion[1][2] = vecExplosion[2][0] = vecExplosion[2][2] = vecExplosion[3][2] =
			vecExplosion[4][1] = vecExplosion[4][2] = vecExplosion[5][2] = vecExplosion[6][0] = vecExplosion[6][2] = vecExplosion[7][2] = 0.0;
			
			vecExplosion[1][0] = vecExplosion[1][1] = vecExplosion[7][0] = 100.0;
			
			vecExplosion[0][0] = vecExplosion[2][1] = 200.0;
		} case 1: {
			vecExplosion[3][1] = vecExplosion[4][0] = -300.0;
			
			vecExplosion[3][0] = vecExplosion[5][0] = vecExplosion[5][1] = vecExplosion[6][1] = vecExplosion[7][1] = -150.0;
			
			vecExplosion[0][1] = vecExplosion[0][2] = vecExplosion[1][2] = vecExplosion[2][0] = vecExplosion[2][2] = vecExplosion[3][2] =
			vecExplosion[4][1] = vecExplosion[4][2] = vecExplosion[5][2] = vecExplosion[6][0] = vecExplosion[6][2] = vecExplosion[7][2] = 0.0;
			
			vecExplosion[1][0] = vecExplosion[1][1] = vecExplosion[7][0] = 150.0;
			
			vecExplosion[0][0] = vecExplosion[2][1] = 300.0;
		}
	}
	
	for(i = 0; i < 8; ++i) {
		if(!is_valid_ent(g_Boss)) {
			return;
		}
		
		if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
			return;
		}

		getDestination(g_Boss, vecExplosion[i][0], vecExplosion[i][1], vecExplosion[i][2], vecBallPlace[i]);
		bombExplosion(g_Boss, vecBallPlace[i]);
	}
	
	--g_BossPower_Explode;
	
	if(!g_BossPower_Explode) {
		g_BossPower[0] = 0;
	}
}

stock getDestination(const pEnt, const Float:flForward, const Float:flRight, const Float:flUp, Float:vecStart[]) {
	static Float:vecOrigin[3];
	static Float:vecAngles[3];
	static Float:vecForward[3];
	static Float:vecRight[3];
	static Float:vecUp[3];
	
	entity_get_vector(pEnt, EV_VEC_origin, vecOrigin);
	entity_get_vector(pEnt, EV_VEC_view_ofs, vecUp);
	
	xs_vec_add(vecOrigin, vecUp, vecOrigin);
	
	entity_get_vector(pEnt, EV_VEC_v_angle, vecAngles);
	
	vecAngles[0] = 0.0;
	
	angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecForward);
	angle_vector(vecAngles, ANGLEVECTOR_RIGHT, vecRight);
	angle_vector(vecAngles, ANGLEVECTOR_UP, vecUp);
	
	vecStart[0] = vecOrigin[0] + vecForward[0] * flForward + vecRight[0] * flRight + vecUp[0] * flUp;
	vecStart[1] = vecOrigin[1] + vecForward[1] * flForward + vecRight[1] * flRight + vecUp[1] * flUp;
	vecStart[2] = vecOrigin[2] + vecForward[2] * flForward + vecRight[2] * flRight + vecUp[2] * flUp;
}

public bombExplosion(const pEnt, Float:vecOrigin[3]) {
	new Float:flDamage = random_float(2.5, 5.0) * (g_Difficulty + 1);
	new i;
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_SPRITE_ArrowExplode);
	write_byte(10);
	write_byte(30);
	write_byte(4);
	message_end();
	
	for(i = 1; i <= g_MaxUsers; i++) {
		if(is_user_alive(i)) {
			static Float:vecOrigin2[3];
			static Float:flDistance;
			
			entity_get_vector(i, EV_VEC_origin, vecOrigin2);
			
			flDistance = get_distance_f(vecOrigin, vecOrigin2);
			
			if(flDistance <= 350.0) {
				message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, i);
				write_short(1<<14);
				write_short(1<<13);
				write_short(1<<13);
				message_end();
				
				message_begin(MSG_ONE_UNRELIABLE, g_Message_Screenfade, _, i);
				write_short(UNIT_SECOND * 5);
				write_short(0);
				write_short(FFADE_IN);
				write_byte(255);
				write_byte(0);
				write_byte(0);
				write_byte(155);
				message_end();
				
				if((get_user_health(i) - floatround(flDamage)) > 0) {
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

public bossPower_Dash() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}
	
	new Float:vecOrigin[3];
	new Float:vecOriginBoss[3];
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

public touch__Boss_FireMonster(const pBoss, const pUser) {
	if(pev_valid(pBoss) && g_BossPower[0] == BOSS_POWER_DASH) {
		g_BossPower[0] = 0;
		
		new Float:flGameTime;
		flGameTime = get_gametime();

		client_cmd(0, "spk ^"%s^"", SOUND_BOSS_IMPACT);
		
		if(pev_valid(pUser) && is_user_alive(pUser)) {
			entity_set_vector(pBoss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(pBoss, EV_INT_sequence, 7);
			entity_set_float(pBoss, EV_FL_animtime, flGameTime);
			entity_set_float(pBoss, EV_FL_framerate, 1.0);
			
			entity_set_int(pBoss, EV_INT_gamestate, 1);
			
			entity_set_float(pBoss, EV_FL_nextthink, flGameTime + 0.866667);
			
			ExecuteHam(Ham_TakeDamage, pUser, 0, pBoss, 9999.0, DMG_BURN);
		} else {
			entity_set_vector(pBoss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(pBoss, EV_INT_sequence, 15);
			entity_set_float(pBoss, EV_FL_animtime, flGameTime);
			entity_set_float(pBoss, EV_FL_framerate, 1.0);
			
			entity_set_int(pBoss, EV_INT_gamestate, 1);
			
			entity_set_float(pBoss, EV_FL_nextthink, flGameTime + 8.033333);

			new Float:vecBossOrigin[3];
			new Float:vecOrigin[3];
			new Float:fDistance;
			new i;

			entity_get_vector(pBoss, EV_VEC_origin, vecBossOrigin);

			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!is_user_alive(i)) {
					continue;
				}

				entity_get_vector(i, EV_VEC_origin, vecOrigin);
				fDistance = vector_distance(vecBossOrigin, vecOrigin);

				if(fDistance <= 130.0) {
					setAchievement(i, BOSS_FIRE_POR_POCO);
				}
			}
		}
	}
}

public bossPower_FireBall_x2() {
	new Float:vecOrigin[3];
	new iBallLeft;
	new iBallRight;
	new Float:flGameTime = get_gametime();
	
	getDestination(g_Boss, 50.0, -25.0, 100.0, vecOrigin);
	
	iBallLeft = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallLeft, EV_FL_nextthink, flGameTime + 0.8);
	
	getDestination(g_Boss, 50.0, 50.0, 100.0, vecOrigin);
	
	iBallRight = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallRight, EV_FL_nextthink, flGameTime + 1.1);
	
	g_BossPower[0] = 0;
}

public bossPower_FireBall_x4() {
	new Float:vecOrigin[3];
	new iBallLeft;
	new iBallRight;
	new Float:flGameTime = get_gametime();
	
	getDestination(g_Boss, 50.0, -25.0, 100.0, vecOrigin);
	
	iBallLeft = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallLeft, EV_FL_nextthink, flGameTime + 0.8);
	
	getDestination(g_Boss, 50.0, 50.0, 100.0, vecOrigin);
	
	iBallRight = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallRight, EV_FL_nextthink, flGameTime + 1.1);
	
	set_task(0.2, "bossPower_FireBall_x4_Go");
}

public bossPower_FireBall_x4_Go() {
	new Float:vecOrigin[3];
	new iBallLeft;
	new iBallRight;
	new Float:flGameTime = get_gametime();
	
	getDestination(g_Boss, 50.0, -25.0, 100.0, vecOrigin);
	
	iBallLeft = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallLeft, EV_FL_nextthink, flGameTime + 0.1);
	
	getDestination(g_Boss, 50.0, 50.0, 100.0, vecOrigin);
	
	iBallRight = createFireBall(g_Boss, vecOrigin);
	
	entity_set_float(iBallRight, EV_FL_nextthink, flGameTime + 0.2);
	
	g_BossPower[0] = 0;
}

public createFireBall(const pBoss, const Float:vecOrigin[3]) {
	new iEnt;
	new iSprite;
	new Float:vecMaxs[3];
	new Float:vecMins[3];
	
	iEnt = create_entity("info_target");
	
	entity_set_origin(iEnt, vecOrigin);
	entity_set_string(iEnt, EV_SZ_classname, "entFireBall");
	entity_set_model(iEnt, MODEL_FIREBALL);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_NONE);
	
	vecMins = Float:{-15.0, -15.0, -15.0};
	vecMaxs = Float:{15.0, 15.0, 15.0};
	
	entity_set_size(iEnt, vecMins, vecMaxs);
	
	entity_set_edict(iEnt, EV_ENT_owner, pBoss);
	
	entity_set_int(iEnt, EV_INT_light_level, 180);
	entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAdd);
	entity_set_float(iEnt, EV_FL_renderamt, 255.0);
	
	entity_set_int(iEnt, MONSTER_TARGET, entity_get_int(pBoss, MONSTER_TARGET));
	
	iSprite = create_entity("env_sprite");
	
	if(!is_valid_ent(iSprite)) {
		return 0;
	}
	
	entity_set_model(iSprite, "sprites/gk_td/gk_flame.spr");
	
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

public followHuman__FireBall(const pEnt, Float:vecOrigin[], const Float:vecVictimOrigin[], const Float:flVelocity) {
	new Float:vecVelocity[3];
	
	vecOrigin[0] = vecVictimOrigin[0] - vecOrigin[0];
	vecOrigin[1] = vecVictimOrigin[1] - vecOrigin[1];
	vecOrigin[2] = vecVictimOrigin[2] - vecOrigin[2];
	
	engfunc(EngFunc_VecToAngles, vecOrigin, vecVelocity);
	
	vecVelocity[0] *= -1.0;
	vecVelocity[2] = 0.0;
	
	engfunc(EngFunc_MakeVectors, vecVelocity);
	
	global_get(glb_v_forward, vecVelocity);
	
	vecVelocity[0] *= flVelocity;
	vecVelocity[1] *= flVelocity;
	vecVelocity[2] *= flVelocity;
	
	entity_set_vector(pEnt, EV_VEC_velocity, vecVelocity);
}

public think__FireBall(const pEnt) {
	if(!is_valid_ent(pEnt)) {
		return;
	}
	
	new iVictim;
	iVictim = entity_get_int(pEnt, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		new Float:vecOrigin[3];
		new Float:vecVictimOrigin[3];
		
		entity_set_int(pEnt, EV_INT_solid, SOLID_BBOX);
		entity_set_int(pEnt, EV_INT_movetype, MOVETYPE_FLY);
		
		entity_get_vector(pEnt, EV_VEC_origin, vecOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		followHuman__FireBall(pEnt, vecOrigin, vecVictimOrigin, 2400.0);
	} else {
		remove_entity(pEnt);
	}
}

public touch__FireBall(const pEnt, const pAll) {
	if(!pev_valid(pEnt)) {
		return;
	}
	
	new Float:vecOrigin[3];
	new i;
	
	entity_get_vector(pEnt, EV_VEC_origin, vecOrigin);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_SPRITE_ArrowExplode);
	write_byte(10);
	write_byte(30);
	write_byte(4);
	message_end();
	
	emit_sound(pEnt, CHAN_BODY, SOUND_BOSS_FIREBALL_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(is_user_alive(i) && entity_range(pEnt, i) <= 240.0) {
			message_begin(MSG_ONE_UNRELIABLE, g_Message_ScreenShake, _, i);
			write_short(1<<14);
			write_short(1<<13);
			write_short(1<<13);
			message_end();
			
			ExecuteHam(Ham_TakeDamage, i, 0, i, (50.0 * float((g_Difficulty + 1))), DMG_BURN);
			
			message_begin(MSG_ONE_UNRELIABLE, g_Message_Screenfade, _, i);
			write_short(UNIT_SECOND * 5);
			write_short(0);
			write_short(FFADE_IN);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(155);
			message_end();
		}
	}
	
	i = entity_get_edict(pEnt, EV_ENT_euser3);
	
	if(is_valid_ent(i)) {
		remove_entity(i);
	}
	
	remove_entity(pEnt);
}

public bossPower__Ultimate(const pBoss) {
	if(is_valid_ent(pBoss)) {
		++g_Boss_Fire_Ultimate;
		
		new Float:vecExplosion[24][3];
		new Float:vecPosition[24][3];
		new i;
		
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
		
		for(i = 0; i < 24; ++i) {
			getDestination(pBoss, vecExplosion[i][0], vecExplosion[i][1], vecExplosion[i][2], vecPosition[i]);
			createFireBall__Ultimate(pBoss, vecPosition[i]);
		}
		
		if(g_Boss_Fire_Ultimate >= 7) {
			g_BossPower[0] = 0;
			return;
		}
		
		set_task(1.0, "bossPower__Ultimate", pBoss);
	}
}

public createFireBall__Ultimate(const pBoss, const Float:vecOrigin[3]) {
	new iEnt;
	iEnt = create_entity("info_target");
	
	new Float:vecAngles[3];
	entity_get_vector(pBoss, EV_VEC_angles, vecAngles);
	
	entity_set_origin(iEnt, vecOrigin);
	
	vecAngles[0] = -100.0;
	entity_set_vector(iEnt, EV_VEC_angles, vecAngles);
	vecAngles[0] = 100.0;
	entity_set_vector(iEnt, EV_VEC_v_angle, vecAngles);
	
	entity_set_string(iEnt, EV_SZ_classname, "entFireBall");
	entity_set_model(iEnt, MODEL_FIREBALL);
	
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);
	
	entity_set_size(iEnt, Float:{-15.0, -15.0, -15.0}, Float:{15.0, 15.0, 15.0});
	
	entity_set_edict(iEnt, EV_ENT_owner, pBoss);
	
	new Float:vecVelocity[3];
	VelocityByAim(iEnt, random_num(400, 1600), vecVelocity);
	
	entity_set_int(iEnt, EV_INT_light_level, 180);
	entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAdd);
	entity_set_float(iEnt, EV_FL_renderamt, 255.0);
	
	entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);
}

public voteBoss() {
	new sItem[48];
	new sPosition[4];
	new iMenu;
	new i;

	iMenu = menu_create("VOTACIÓN DE JEFES", "menu__Bosses");
	
	for(i = 0; i < BossList; ++i) {
		num_to_str((i + 1), sPosition, 3);

		formatex(sItem, 47, "%s", BOSSES_NAME[i]);
		menu_additem(iMenu, sItem, sPosition);
	}

	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER);
	
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}
		
		if(!g_AccountLogged[i]) {
			continue;
		}
		
		menu_display(i, iMenu, 0);
	}
}

public menu__Bosses(const id, const menuId, const item) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	if(item == MENU_EXIT) {
		return PLUGIN_HANDLED;
	}
	
	new sBuffer[3];
	new iNothing;
	new iItem;
	
	menu_item_getinfo(menuId, item, iNothing, sBuffer, charsmax(sBuffer), _, _, iNothing);
	iItem = str_to_num(sBuffer) - 1;

	++g_BossMenu_Votes[iItem];
	++g_BossMenu_Maxvotes;

	return PLUGIN_HANDLED;
}

public __FinishVoteBoss() {
	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_connected(i)) {
			continue;
		}
		
		if(!g_AccountLogged[i]) {
			continue;
		}
		
		message_begin(MSG_ONE, g_Message_ShowMenu, .player=i);
		{
			write_short(0);
			write_char(0);
			write_byte(0);
			write_string("");
		}
		message_end();
	}

	new iMaxVote = 0;
	new iMaxItemVote = 0;
	
	for(i = 0; i < BossList; ++i) {
		if(g_BossMenu_Votes[i] > iMaxVote) {
			iMaxVote = g_BossMenu_Votes[i];
			iMaxItemVote = i;
		}
	}
	
	if(iMaxItemVote >= 0) {
		new iPercent = 100;

		if(g_BossMenu_Maxvotes > 0) {
			iPercent = (g_BossMenu_Votes[iMaxItemVote] * 100) / g_BossMenu_Maxvotes;
		}

		colorChat(0, CT, "%sEl jefe final será !g%s!y con el !t%d%%!y de los votos!", TD_PREFIX, BOSSES_NAME_FF[iMaxItemVote], iPercent);
	}
	
	g_BossId = iMaxItemVote;
}

public task__KickReasonBan(const id) {
	if(is_user_connected(id)) {
		console_print(id, "");
		console_print(id, "");
		console_print(id, "****** DRUNK GAMING ******");
		console_print(id, "");
		console_print(id, "TU CUENTA ESTÁ BANEADA");
		console_print(id, ""); 
		console_print(id, "Administrador que te baneo: %s", g_AccountBan_Admin[id]);
		console_print(id, "Razón: %s", g_AccountBan_Reason[id]);
		console_print(id, "El ban fue realizado en la fecha: %s", g_AccountBan_Start[id]);
		console_print(id, "El ban expira en la fecha: %s", g_AccountBan_Finish[id]);
		console_print(id, "Cuenta #%d", g_UserId[id]);
		console_print(id, "");
		console_print(id, "****** DRUNK GAMING ******");
		console_print(id, "");
		console_print(id, "");
		
		set_task(1.0, "task__KickUser", id);
	}
}

public task__KickUser(const id) {
	if(is_user_connected(id)) {
		server_cmd("kick #%d ^"Tu cuenta está baneada! - Lee tu consola^"", get_user_userid(id));
	}
}

public __voteBoss() {
	--g_BossMenu_TimeLeft;

	if(!g_BossMenu_TimeLeft) {
		voteBoss();
		set_task(10.0, "__FinishVoteBoss");

		return;
	}

	client_print(0, print_center, "La votación de jefes comenzará en %d segundo%s!", g_BossMenu_TimeLeft, (g_BossMenu_TimeLeft != 1) ? "s" : "");

	set_task(1.0, "__voteBoss");
}

public __endGame() {
	client_cmd(0, "mp3 play %s", SOUND_WIN_GAME);
	
	g_TotalMonsters = 29;
	g_BossMenu_TimeLeft = 10;

	set_task(10.0, "__voteBoss");
	set_task(30.0, "startWave", TASK_WAVES);
	set_task(1.0, "repeatHUD", _, _, _, "a", 30);
}

public think__Boss_Kyra(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	if(g_Boss_Guardians) {
		static iVictim;
		static Float:vecVictimOrigin[3];
		static Float:vecBossOrigin[3];
		static Float:vecVelocity[3];
		static iDistance;
		
		iVictim = miniBoss__SearchRandomHuman(iEnt);
		
		entity_get_vector(iEnt, EV_VEC_origin, vecBossOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);	

		entitySetAim(iEnt, vecBossOrigin, vecVictimOrigin, .iAngleMode=1337);
		
		client_cmd(0, "spk ^"%s^"", SOUND_SPITTER_SPIT);
		
		iDistance = floatround(vector_distance(vecBossOrigin, vecVictimOrigin));
		
		velocity_by_aim(iEnt, iDistance, vecVelocity);
		
		new iSpitterBall;
		iSpitterBall = create_entity("info_target");
		
		if(is_valid_ent(iSpitterBall)) {
			entity_set_string(iSpitterBall, EV_SZ_classname, "entSpitterBall");
			entity_set_model(iSpitterBall, MODEL_TANK_ROCK_GIBS);
			
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
			
			register_think("entSpitterBall", "think__SpitterBall");
			
			entity_set_float(iSpitterBall, EV_FL_nextthink, get_gametime() + 0.1);
		}
		
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 15.0);
	} else {
		static iVictim;
		iVictim = entity_get_int(iEnt, MONSTER_TARGET);
		
		if(is_user_alive(iVictim)) {
			static Float:vecEntOrigin[3];
			static Float:vecVictimOrigin[3];
			static Float:fDistance;
			
			entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
			entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
			
			fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
			
			if(fDistance <= 100.0) {
				entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
				
				entity_set_int(iEnt, EV_INT_sequence, 159);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.4);
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, 9999.0, DMG_SLASH);
			} else {
				static Float:fVelocity;

				if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
					entity_set_int(iEnt, EV_INT_gamestate, 3);

					entity_set_int(iEnt, EV_INT_sequence, 148);
					entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				}
				
				fVelocity = 220.0;
				entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
				
				entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, fVelocity, .iAngleMode=1);
				
				if(fDistance >= 135.0) {
					iVictim = miniBoss__SearchHuman(iEnt);
					entity_set_int(iEnt, MONSTER_TARGET, iVictim);
				}
				
				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
			}
		} else {
			iVictim = miniBoss__SearchHuman(iEnt);
			entity_set_int(iEnt, MONSTER_TARGET, iVictim);
			
			if(!iVictim) {
				entity_set_int(iEnt, EV_INT_sequence, 146);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				return;
			}
			
			entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
		}
	}
}

public think__SpitterBall(const iEnt) {
	if(is_valid_ent(iEnt)) {
		if(entity_get_int(iEnt, EV_INT_solid) == SOLID_TRIGGER) {
			static Float:vecOrigin[3];
			static iVictim;
			
			entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
			
			iVictim = -1;
			
			while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 250.0)) != 0) {
				if(!is_user_alive(iVictim)) {
					continue;
				}
				
				emit_sound(iVictim, CHAN_BODY, SOUND_BOSS_PHIT[random_num(0, charsmax(SOUND_BOSS_PHIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				new iHealth = get_user_health(iVictim) - 2;
				
				if(iHealth <= 0) {
					ExecuteHamB(Ham_Killed, iVictim, iVictim, 0);
					
					if(!getUsersAlive()) {
						removeAllEnts(1);
						__finishGame();
					}
				} else {
					set_user_health(iVictim, iHealth);
					
					message_begin(MSG_ONE_UNRELIABLE, g_Message_Screenfade, _, iVictim);
					write_short(UNIT_SECOND * 1);
					write_short(UNIT_SECOND * 1);
					write_short(FFADE_IN);
					write_byte(255);
					write_byte(0);
					write_byte(0);
					write_byte(125);
					message_end();
				}
			}
		} else {
			if((get_entity_flags(iEnt) & FL_ONGROUND) && fm_get_speed(iEnt) < 10) {
				new Float:vecOrigin[3];
				entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
				
				entity_set_vector(iEnt, EV_VEC_angles, Float:{180.0, 0.0, 0.0});
				
				entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				vecOrigin[2] += 30.0;
				entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
				
				entity_set_model(iEnt, MODEL_SPITTER_AURA);
				
				entity_set_int(iEnt, EV_INT_renderfx, kRenderFxPulseSlow);
				entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(iEnt, EV_FL_renderamt, 120.0);
			}
		}

		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
	}
}

public createGuardians() {
	g_Boss_Guardians = 2;
	
	register_think(ENT_BOSS_GUARDIANS, "think__Boss_Guardians");
	
	new i;
	for(i = 0; i < 2; ++i) {
		g_Boss_Guardians_Ids[i] = create_entity("info_target");
		
		if(is_valid_ent(g_Boss_Guardians_Ids[i])) {
			new Float:vecMins[3];
			new Float:vecMax[3];
			new Float:fVelocity;
			new iHealth;
			new iExtraDamage = getTotalExtraDamage() / 10;

			iHealth = 10000 + (DIFFICULTIES_VALUES[g_Difficulty][difficultyBossGorilaHealth] * getUsersAlive());
			iHealth = iHealth + ((iHealth * iExtraDamage) / 100);
			
			vecMins = Float:{-32.0, -32.0, -36.0};
			vecMax = Float:{32.0, 32.0, 9999.0};
			
			entity_set_string(g_Boss_Guardians_Ids[i], EV_SZ_classname, ENT_BOSS_GUARDIANS);
			
			dllfunc(DLLFunc_Spawn, g_Boss_Guardians_Ids[i]);
			
			entity_set_model(g_Boss_Guardians_Ids[i], MODEL_BOSS[BOSS_GORILA]);
			entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_health, float(iHealth));
			entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_takedamage, DAMAGE_YES);
			
			entity_set_vector(g_Boss_Guardians_Ids[i], EV_VEC_angles, Float:{0.0, 0.0, 0.0});
			
			entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_solid, SOLID_BBOX);
			entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_movetype, MOVETYPE_TOSS);
			
			switch(i) {
				case 0: {
					g_Boss_Respawn[MAPS_DESC[g_MapId][mapBossCoord]] -= 400.0;
				} case 1: {
					g_Boss_Respawn[MAPS_DESC[g_MapId][mapBossCoord]] += 400.0;
				}
			}
			
			entity_set_origin(g_Boss_Guardians_Ids[i], g_Boss_Respawn);
			
			entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_gravity, 1.0);
			
			set_task(2.0, "__changeMoveType", g_Boss_Guardians_Ids[i]);
			
			entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_sequence, 1);
			entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_animtime, get_gametime());
			
			entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_gamestate, 1);
			
			entity_set_int(g_Boss_Guardians_Ids[i], MONSTER_MAXHEALTH, iHealth);
			entity_set_int(g_Boss_Guardians_Ids[i], MONSTER_TYPE, MONSTER_BOSS);
			entity_set_int(g_Boss_Guardians_Ids[i], MONSTER_TARGET, 0);
			
			entity_set_size(g_Boss_Guardians_Ids[i], vecMins, vecMax);
			
			entity_set_vector(g_Boss_Guardians_Ids[i], EV_VEC_mins, vecMins);
			entity_set_vector(g_Boss_Guardians_Ids[i], EV_VEC_maxs, vecMax);
			
			drop_to_floor(g_Boss_Guardians_Ids[i]);
			
			fVelocity = 265.0;
			entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0
			
			entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_nextthink, get_gametime() + 3.0);
		
			g_Boss_Guardians_HealthBar[i] = create_entity("env_sprite");
		
			if(is_valid_ent(g_Boss_Guardians_HealthBar[i])) {
				entity_set_int(g_Boss_Guardians_HealthBar[i], EV_INT_spawnflags, SF_SPRITE_STARTON);
				entity_set_int(g_Boss_Guardians_HealthBar[i], EV_INT_solid, SOLID_NOT);
				
				entity_set_model(g_Boss_Guardians_HealthBar[i], MONSTER_SPRITE_HEALTH_BOSS);
				
				entity_set_float(g_Boss_Guardians_HealthBar[i], EV_FL_scale, 0.5);
				
				entity_set_float(g_Boss_Guardians_HealthBar[i], EV_FL_frame, 100.0);
				
				//g_Boss_Respawn[2] += 200.0;
				entity_set_origin(g_Boss_Guardians_HealthBar[i], g_Boss_Respawn);
				
				switch(i) {
					case 0: {
						g_Boss_Respawn[MAPS_DESC[g_MapId][mapBossCoord]] += 400.0;
						//g_Boss_Respawn[2] -= 200.0;
					} case 1: {
						g_Boss_Respawn[MAPS_DESC[g_MapId][mapBossCoord]] -= 400.0;
						//g_Boss_Respawn[2] -= 200.0;
					}
				}
				
				if(!g_FORWARD_AddToFullPack_Status) {
					g_FORWARD_AddToFullPack_Status = 1;
					g_FORWARD_AddToFullPack = register_forward(FM_AddToFullPack, "fw_AddToFullPack__GUARDIANS_P", 1);
				}
			}
		}
	}
}

public think__Boss_Guardians(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(iEnt, MONSTER_TARGET);
	
	static iBoss;
	iBoss = (g_Boss_Guardians_Ids[0] == iEnt) ? 0 : 1;
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:fDistance;
		static fHeightDifference;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		fHeightDifference = abs(floatround(vecEntOrigin[2] - vecVictimOrigin[2]));

		if(fHeightDifference > 250) {
			new i;
			for(i = 0; i < 16; ++i) {
				iVictim = miniBoss__SearchHuman(iEnt, iVictim);
				entity_set_int(iEnt, MONSTER_TARGET, iVictim);

				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
				return;
			}
		}
		
		if(fDistance <= 64.0) {
			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
			
			if(g_BossPower[iBoss] != BOSS_POWER_ROLL) {
				static iRandomAttackSeq;
				static iRandom;
				
				iRandom = random_num(0, charsmax(SEQUENCES_ATTACK_BOSS1));
				iRandomAttackSeq = SEQUENCES_ATTACK_BOSS1[iRandom];
				
				g_BossRollSpeed[iBoss] = 0.0;
				
				emit_sound(iVictim, CHAN_BODY, SOUND_BOSS_PHIT[random_num(0, 2)], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(iEnt, EV_INT_sequence, iRandomAttackSeq);
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				static Float:vecSub[3];
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub); // vec1 - vec2
				xs_vec_mul_scalar(vecSub, 2400.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + SEQUENCES_FRAMES_BOSS1[iRandom]);
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, DIFFICULTIES_VALUES[g_Difficulty][difficultyBossGorilaDamage], DMG_SLASH);
				
				return;
			} else {
				client_cmd(0, "stopsound; spk ^"%s^"", SOUND_BOSS_ROLL_FINISH);
				
				g_BossRollSpeed[iBoss] = 0.0;
				
				static Float:flGameTime;
				flGameTime = get_gametime();
				
				g_Boss_TimePower[iBoss] = flGameTime + 5.0;
				g_BossPower[iBoss] = 0;
				
				static Float:vecSub[3];
				
				vecEntOrigin[0] = vecVictimOrigin[0];
				vecEntOrigin[1] = vecVictimOrigin[1];
				vecEntOrigin[2] = vecVictimOrigin[2] + 64.0;
				
				xs_vec_sub(vecEntOrigin, vecVictimOrigin, vecSub);
				xs_vec_mul_scalar(vecSub, 5.0, vecSub);
				
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_int(iEnt, EV_INT_sequence, 45);
				entity_set_float(iEnt, EV_FL_animtime, flGameTime);
				entity_set_float(iEnt, EV_FL_framerate, 1.0);
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 1.2);
				return;
			}
		} else {
			static Float:fVelocity;
			
			if(g_BossPower[iBoss] != BOSS_POWER_ROLL) {
				if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
					entity_set_int(iEnt, EV_INT_gamestate, 3);

					entity_set_int(iEnt, EV_INT_sequence, 4);
					entity_set_float(iEnt, EV_FL_animtime, get_gametime());
				}

				g_BossRollSpeed[iBoss] += 0.5;
				fVelocity = 260.0 + g_BossRollSpeed[iBoss];

				entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0

			} else {
				g_BossRollSpeed[iBoss] += 5.0;
				fVelocity = 200.0 + g_BossRollSpeed[iBoss];
				
				vecEntOrigin[2] -= 24.0;
				
				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEntOrigin, 0);
				write_byte(TE_SPARKS);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecEntOrigin[2]);
				message_end();
				
				vecEntOrigin[2] += 24.0;
			}
			
			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, fVelocity, .iAngleMode=1);
			
			if(fDistance >= 200.0) {
				static Float:flGameTime;
				flGameTime = get_gametime();
				
				if(fDistance >= 500.0 && !g_BossPower[iBoss] && g_Boss_TimePower[iBoss] <= flGameTime) {
					if(random_num(0, 1)) {
						g_BossPower[iBoss] = BOSS_POWER_ROLL;
						g_BossLastPower[iBoss] = g_BossPower[iBoss];
						
						client_cmd(0, "spk ^"%s^"", SOUND_BOSS_ROLL_LOOP);
						
						entity_set_int(iEnt, EV_INT_sequence, 44);
						entity_set_float(iEnt, EV_FL_animtime, get_gametime());
						entity_set_float(iEnt, EV_FL_framerate, 1.3);
						
						entity_set_int(iEnt, EV_INT_gamestate, 1);
						
						iVictim = miniBoss__SearchRandomHuman(iEnt);
						entity_set_int(iEnt, MONSTER_TARGET, iVictim);
						
						entity_set_float(iEnt, EV_FL_nextthink, flGameTime + 0.1);
						
						return;
					} else {
						new iRandomPower;
						iRandomPower = g_BossLastPower[iBoss];
						
						while(iRandomPower == g_BossLastPower[iBoss]) {
							iRandomPower = random_num(1, (iBoss) ? 2 : 3);
						}
						
						while(iRandomPower == BOSS_POWER_EGGS && g_BossPower[!iBoss]) {
							iRandomPower = random_num(1, (iBoss) ? 2 : 3);
						}
						
						switch(iRandomPower) {
							case BOSS_POWER_ROLL: {
								g_Boss_TimePower[iBoss] = flGameTime + 7.0;
								g_BossLastPower[iBoss] = BOSS_POWER_ROLL;
								
								entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
								
								return;
							}
							case BOSS_POWER_EGGS: { // Ambos guardianes tiran los huevos al mismo tiempo, de lo contrario, podés quedarte encima de los zombies y buguear a los guardianes
								new i;
								for(i = 0; i < 2; ++i) {
									if(is_valid_ent(g_Boss_Guardians_Ids[i]) && entity_get_int(g_Boss_Guardians_Ids[i], MONSTER_MAXHEALTH)) {
										g_BossPower[i] = BOSS_POWER_EGGS;
										g_BossLastPower[i] = BOSS_POWER_EGGS;
										
										entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_rendermode, kRenderTransAlpha);
										entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_renderamt, 150.0);
										
										entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_sequence, 1);
										entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_animtime, get_gametime());
										entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_framerate, 1.0);
										
										entity_set_int(g_Boss_Guardians_Ids[i], EV_INT_gamestate, 1);
										
										entity_set_vector(g_Boss_Guardians_Ids[i], EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
										
										createSpecialMonster(g_Boss_Guardians_Ids[i], 16);
										
										entity_set_int(g_Boss_Guardians_Ids[i], MONSTER_TARGET, 0);
										
										entity_set_float(g_Boss_Guardians_Ids[i], EV_FL_nextthink, get_gametime() + 9999.0);
									}
								}
								
								return;
							}
							case BOSS_POWER_ATTRACT: {
								if(!random_num(0, 3)) {
									g_BossPower[iBoss] = BOSS_POWER_ATTRACT;
									g_BossLastPower[iBoss] = g_BossPower[iBoss];
									
									entity_set_int(iEnt, EV_INT_sequence, 0);
									entity_set_float(iEnt, EV_FL_animtime, get_gametime());
									entity_set_float(iEnt, EV_FL_framerate, 1.0);
									
									entity_set_int(iEnt, EV_INT_gamestate, 1);
									
									entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
									
									fm_set_rendering(iEnt, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
									
									set_lights("a");
									
									new Float:flEndTime = 3.7;
									new Float:flRepeat = (flEndTime / 0.1) - 1.0;
									
									set_task(0.1, "bossPower_Closer", iEnt, _, _, "a", floatround(flRepeat));
									set_task(flEndTime, "__endBossPower_Closer", iEnt);
								} else {
									g_Boss_TimePower[iBoss] = flGameTime + 7.0;
									g_BossLastPower[iBoss] = BOSS_POWER_ROLL;
									
									entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
									
									return;
								}
							}
						}
						
						entity_set_int(iEnt, MONSTER_TARGET, 0);
						
						return;
					}
				}
				
				iVictim = miniBoss__SearchHuman(iEnt);
				entity_set_int(iEnt, MONSTER_TARGET, iVictim);
			}
		}
	} else {
		iVictim = miniBoss__SearchHuman(iEnt);
		entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(iEnt, EV_INT_sequence, 1);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 1.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			return;
		}
	}
	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
}

public __explodeBoomer(const iEnt) {
	message_begin(MSG_BROADCAST, g_Message_Screenfade);
	write_short(UNIT_SECOND * 5);
	write_short(UNIT_SECOND * 5);
	write_short(FFADE_IN);
	write_byte(0);
	write_byte(153);
	write_byte(0);
	write_byte(255);
	message_end();
	
	client_cmd(0, "spk ^"%s^"", SOUND_BOOMER_EXPLODE);
	
	removeMonster(iEnt, 15000);
	deleteMonsterEnt(iEnt);
	
	new iDamage = 150;
	
	if(DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower]) {
		iDamage = iDamage + ((iDamage * DIFFICULTIES_VALUES[g_Difficulty][difficultyDamageTower]) / 100);
	}
	
	g_Achievement_DefensaAbsoluta = 0;
	
	g_TowerHealth -= iDamage;
	
	if(g_TowerHealth < 0.0) {
		removeAllEnts(1);
		__finishGame();
		
		return;
	}
	
	if(!g_TowerInRegen) {
		g_TowerInRegen = 1;
		
		if(DIFFICULTIES_VALUES[g_Difficulty][difficultyTowerRegen]) {
			set_task(5.0, "regenTower", TASK_REGEN_TOWER);
		}
	}
}

public sqlThread__InsertEndWaveStats(const failstate, const Handle:query, const error[], const error_num, const data[], const size, const Float:queuetime) {
	switch(failstate) {
		case TQUERY_CONNECT_FAILED: {
			log_to_file("td_sql.log", "sqlThread__InsertEndWaveStats - %d - %s", error_num, error);
			return;
		} case TQUERY_QUERY_FAILED: {
			log_to_file("td_sql.log", "sqlThread__InsertEndWaveStats - %d - %s", error_num, error);
		}
	}
}

public sqlThread__InsertEndMapStats(const failstate, const Handle:query, const error[], const error_num, const data[], const size, const Float:queuetime) {
	switch(failstate) {
		case TQUERY_CONNECT_FAILED: {
			log_to_file("td_sql.log", "sqlThread__InsertEndMapStats - %d - %s", error_num, error);
			return;
		} case TQUERY_QUERY_FAILED: {
			log_to_file("td_sql.log", "sqlThread__InsertEndMapStats - %d - %s", error_num, error);
		}
	}
}

public sqlThread__InsertAchievement(const failstate, const Handle:query, const error[], const error_num, const data[], const size, const Float:queuetime) {
	switch(failstate) {
		case TQUERY_CONNECT_FAILED: {
			log_to_file("td_sql.log", "sqlThread__InsertAchievement - %d - %s", error_num, error);
			return;
		} case TQUERY_QUERY_FAILED: {
			log_to_file("td_sql.log", "sqlThread__InsertAchievement - %d - %s", error_num, error);
		}
	}
}

public sqlThread__UpdateData(const failstate, const Handle:query, const error[], const error_num, const data[], const size, const Float:queuetime) {
	switch(failstate) {
		case TQUERY_CONNECT_FAILED: {
			log_to_file("td_sql.log", "sqlThread__UpdateData - %d - %s", error_num, error);
			return;
		} case TQUERY_QUERY_FAILED: {
			log_to_file("td_sql.log", "sqlThread__UpdateData - %d - %s", error_num, error);
			return;
		}
	}
}

public updateRankAndHat(const id) {
	if(g_Rank[id] && is_valid_ent(g_Rank[id])) {
		remove_entity(g_Rank[id]);
		
		g_Rank[id] = create_entity("info_target");
		
		new Float:vecColor[3];
		new iRank = (g_LevelG[id] / 10);

		vecColor = Float:{0.0, 0.0, 0.0};
		
		if(iRank < 1) {
			iRank = 12;
		} else if(iRank >= 4) {
			vecColor = Float:{255.0, 255.0, 0.0};
		}
		
		entity_set_int(g_Rank[id], EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(g_Rank[id], EV_ENT_aiment, id);
		
		entity_set_int(g_Rank[id], EV_INT_rendermode, kRenderNormal);
		entity_set_int(g_Rank[id], EV_INT_renderfx, kRenderFxGlowShell);
		entity_set_float(g_Rank[id], EV_FL_renderamt, 5.0);
		
		entity_set_model(g_Rank[id], MODEL_RANKS);
		
		entity_set_int(g_Rank[id], EV_INT_body, iRank);
		
		entity_set_vector(g_Rank[id], EV_VEC_rendercolor, vecColor);
	}

	if(g_Hat[id] && is_valid_ent(g_Hat[id])) {
		remove_entity(g_Hat[id]);
		
		g_Hat[id] = create_entity("info_target");
		
		new iHat = (g_LevelG[id] / 15);

		if(iHat > 5) {
			iHat = 5;
		}

		entity_set_int(g_Hat[id], EV_INT_movetype, MOVETYPE_FOLLOW);
		entity_set_edict(g_Hat[id], EV_ENT_aiment, id);
		
		entity_set_model(g_Hat[id], MODEL_HATS);
		
		entity_set_int(g_Hat[id], EV_INT_body, iHat);
	}
}

public clcmd__ChangeNadeType(const id) {
	if(!is_user_alive(id)) {
		return PLUGIN_HANDLED;
	}

	/*if(g_CurrentWeapon[id] == CSW_HEGRENADE) {
		if(g_Nades[id][NADE_EXPLOSION]) {

		}
	}*/

	return PLUGIN_HANDLED;
}

replaceWeaponModels(const id, const __weaponId) { // rwm_f
	switch(__weaponId) {
		case CSW_KNIFE: {
			entity_set_string(id, EV_SZ_viewmodel, MODEL_V_TOOL);
			entity_set_string(id, EV_SZ_weaponmodel, MODEL_P_TOOL);
		} case CSW_HEGRENADE: {
			if(g_Nades[id][NADE_ION_BOMB]) {
				entity_set_string(id, EV_SZ_viewmodel, MODEL_ION_BOMB_V);
				entity_set_string(id, EV_SZ_weaponmodel, MODEL_ION_BOMB_P);
			}
		} case CSW_AWP: {
			if(g_ClassId[id] == CLASS_FRANCOTIRADOR && g_ClassLevel[id][CLASS_FRANCOTIRADOR] == 6) {
				entity_set_string(id, EV_SZ_viewmodel, MODEL_AWP_LV7);
			}
		}
	}
}

public think__SentryLASER(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}

	new parentEnt = entity_get_edict(iEnt, BASE_ENT_SENTRY);

	if(!is_valid_ent(parentEnt)) {
		return;
	}
	
	if(!entity_get_int(parentEnt, SENTRY_OWNER)) {
		return;
	}

	new Float:vecEntOrigin[3];
	entity_get_vector(parentEnt, EV_VEC_origin, vecEntOrigin);

	new iVictim = -1;
	new iZombies[10];
	new i = 0;

	while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecEntOrigin, 400.0)) != 0) {
		if(!isMonster(iVictim)) {
			continue;
		}

		if(isSpecialMonster(iVictim)) {
			continue;
		}
		
		iZombies[i] = iVictim;
		++i;

		if(i == 10) {
			break;
		}
	}

	if(i > 0) {
		new Float:vecVictimOrigin[3];
		new iEntOrigin[3];
		new iVictimOrigin[3];

		iVictim = iZombies[random_num(0, (i-1))];

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
		write_coord(iEntOrigin[2] + 38);
		write_coord(iVictimOrigin[0]);
		write_coord(iVictimOrigin[1]);
		write_coord(iVictimOrigin[2] + 6);
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

		emit_sound(iEnt, CHAN_BODY, MONSTER_SOUNDS_LASER[random_num(0, charsmax(MONSTER_SOUNDS_LASER))], 1.0, ATTN_NORM, 0, PITCH_NORM);

		removeMonster(iVictim, 1337, .rayo=1);

		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 60.0);
	} else {
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 5.0);
	}
}

public showMenu__MoveTurret(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, "\yMOVER TORRETA^n^n\r1.\w MOVER TORRETA AQUÍ^n^n\r0.\w VOLVER", -1, "Move Sentry");
}

public menu__MoveTurret(const id, const key) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	if(!is_valid_ent(g_Menu_Sentry[id])) {
		return PLUGIN_HANDLED;
	}
	
	switch(key) {
		case 0: { // MOVER TORRETA AQUÍ
			moveSentry(id, g_Menu_Sentry[id]);
		} case 9: { // ATRÁS
			showMenu__InfoSentry(id, g_Menu_Sentry[id]);
			return PLUGIN_HANDLED;
		}
	}
	
	showMenu__InfoSentry(id, g_Menu_Sentry[id]);
	return PLUGIN_HANDLED;
}

public showMenu__TransferTurretOwner(const id) {
	if(!is_user_connected(id)) {
		return;
	}

	new sMenu[128];
	formatex(sMenu, charsmax(sMenu), "\yTRANSFERIR DUEÑO^n^n\r1.\w NUEVO DUEÑO: \y%s^n\r2.\w CONFIRMAR^n^n\r0.\w VOLVER", (!g_Sentry_TransferMenu[id]) ? "YO" : g_UserName[g_Sentry_TransferMenu[id]]);
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "Transfer Sentry");
}

public menu__TransferTurretOwner(const id, const key) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	if(!is_valid_ent(g_Menu_Sentry[id])) {
		return PLUGIN_HANDLED;
	}
	
	switch(key) {
		case 0: { // ELEGIR DUEÑO
			++g_Sentry_TransferMenu[id];

			while(!is_user_valid_connected(g_Sentry_TransferMenu[id]) || g_Sentry_TransferMenu[id] == id) {
				++g_Sentry_TransferMenu[id];

				if(g_Sentry_TransferMenu[id] == id) {
					continue;
				} else if(g_Sentry_TransferMenu[id] > 32) {
					g_Sentry_TransferMenu[id] = 0;
					break;
				}
			}
		} case 1: { // CONFIRMAR
			if(!g_Sentry_TransferMenu[id]) {
				colorChat(id, _, "%sYa sos el dueño de esta torreta.", TD_PREFIX);
			} else if(!is_user_valid_connected(g_Sentry_TransferMenu[id])) {
				colorChat(id, _, "%sEl usuario seleccionado no existe, probablemente se haya desconectado.", TD_PREFIX);
			} else if(!is_user_valid_alive(g_Sentry_TransferMenu[id])) {
				colorChat(id, _, "%sEl usuario seleccionado está muerto.", TD_PREFIX);
			} else {
				colorChat(id, CT, "%sLe has dado una torreta tuya a !t%s!y.", TD_PREFIX, g_UserName[g_Sentry_TransferMenu[id]]);
				colorChat(g_Sentry_TransferMenu[id], CT, "%sEl usuario !t%s!y te ha regalado una de sus torretas.", TD_PREFIX, g_UserName[id]);

				entity_set_int(g_Menu_Sentry[id], SENTRY_OWNER, g_Sentry_TransferMenu[id]);

				new entBase = entity_get_edict(g_Menu_Sentry[id], SENTRY_ENT_BASE);
				entity_set_int(entBase, SENTRY_OWNER, g_Sentry_TransferMenu[id]);

				showMenu__InfoSentry(id, g_Menu_Sentry[id]);
				return PLUGIN_HANDLED;
			}
		} case 9: { // ATRÁS
			showMenu__InfoSentry(id, g_Menu_Sentry[id]);
			return PLUGIN_HANDLED;
		}
	}
	
	showMenu__TransferTurretOwner(id);
	return PLUGIN_HANDLED;
}

public moveSentry(const id, const sentry) {
	if(!is_user_alive(id)) {
		return;
	}
	
	if(g_InBuilding[id]) {
		colorChat(id, _, "%sNo podés mover tu torreta mientras estás construyendo otra cosa.", TD_PREFIX);
		return;
	} else if(!(entity_get_int(id, EV_INT_flags) & (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT))) { 
		colorChat(id, _, "%sTenés que estar en el suelo para mover tu torreta.", TD_PREFIX);
		return;
	} else if(entity_get_int(id, EV_INT_bInDuck)) {
		colorChat(id, _, "%sNo podés agacharte mientras movés tu torreta.", TD_PREFIX);
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
		colorChat(id, _, "%sNo podés mover tu torreta acá.", TD_PREFIX);
	}
}

public moveSentryBase(const Float:vecOrigin[3], const id, const sentry) {
	if(point_contents(vecOrigin) != CONTENTS_EMPTY || traceCheckCollides(vecOrigin, 24.0)) {
		return 0;
	}
	
	new Float:vecHitPoint[3];
	new Float:vecOriginDown[3];
	new Float:fDistanceFromGround;
	new Float:fDifference;
	
	vecOriginDown = vecOrigin;
	vecOriginDown[2] = -5000.0;
	
	trace_line(0, vecOrigin, vecOriginDown, vecHitPoint);
	
	fDistanceFromGround = vector_distance(vecOrigin, vecHitPoint);
	fDifference = 36.0 - fDistanceFromGround;
	
	if((fDifference <  -20.0) || (fDifference > 20.0)) {
		return 0;
	}
	
	new iEnt = create_entity("func_wall");
	
	if(!iEnt) {
		return 0;
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
	
	entity_set_string(iEnt, EV_SZ_classname, ENT_SENTRY_BASE_CLASSNAME);
	entity_set_model(iEnt, MODEL_SENTRY_BASE);

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
	
	emit_sound(id, CHAN_AUTO, SOUND_SENTRY_BASE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	set_task(2.0, "moveSentryHead", _, iArgs, 3);
	
	return 1;
}

public moveSentryHead(const iArgs[3]) {
	new iEntBase = iArgs[0];
	new id = iArgs[1];
	new sentry = iArgs[2];
	
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
		if(is_valid_ent(iEntBase)) {
			remove_entity(iEntBase);
		}
		
		return;
	}

	new Float:vecOrigin[3];
	vecOrigin = g_SentryOrigin[id];

	new Float:vecMins[3];
	new Float:vecMaxs[3];
	
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
	
	entity_set_string(iEnt, EV_SZ_classname, ENT_SENTRY_CLASSNAME);
	entity_set_model(iEnt, MODEL_SENTRY_LEVEL[0]);
	
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

	emit_sound(iEnt, CHAN_AUTO, SOUND_SENTRY_HEAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	entity_set_float(iEnt, SENTRY_PARAM_01, 0.0);
	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.5);
	
	if(g_Difficulty == DIFF_NORMAL) {
		entity_set_int(iEnt, SENTRY_CLIP, 1000000);
		entity_set_int(iEntBase, SENTRY_CLIP, 1000000);

		entity_set_float(iEnt, SENTRY_MAXCLIP, 1000000.0);
	} else {
		entity_set_int(iEnt, SENTRY_CLIP, SENTRIES_MAXCLIP[1] + CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Clip]);
		entity_set_int(iEntBase, SENTRY_CLIP, SENTRIES_MAXCLIP[1] + CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Clip]);

		entity_set_float(iEnt, SENTRY_MAXCLIP, float(SENTRIES_MAXCLIP[1]) + CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Clip]);
	}
	
	entity_set_float(iEnt, SENTRY_EXTRA_DAMAGE, CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Damage]);
	entity_set_float(iEnt, SENTRY_EXTRA_RATIO, CLASSES_ATTRIB[g_ClassId[id]][g_ClassLevel[id][g_ClassId[id]]][classAttrib_Sentry_Recoil]);

	entity_get_vector(iEntBase, EV_VEC_origin, g_SentryOrigin[id]);

	new iParams[5];
	
	iParams[0] = iEntBase;
	iParams[1] = iEnt;
	iParams[2] = id;
	iParams[3] = floatround(g_SentryOrigin[id][2]);
	iParams[4] = sentry;
	
	set_task(2.0, "checkMoveSentryStuck", _, iParams, 5);
	
	g_InBuilding[id] = 0;
	
	entity_set_int(iEnt, EV_INT_sequence, sentryAnimSpin);
	entity_set_float(iEnt, EV_FL_animtime, 1.0);
	entity_set_float(iEnt, EV_FL_framerate, 1.0);
}

public checkMoveSentryStuck(const iParams[5])
{
	if(!is_valid_ent(iParams[0]))
		return;

	new Float:vecEntBaseOrigin[3];
	new Float:vecEntTopOrigin[3];
	new iDifference;

	entity_get_vector(iParams[0], EV_VEC_origin, vecEntBaseOrigin);
	entity_get_vector(iParams[1], EV_VEC_origin, vecEntTopOrigin);

	iDifference = abs(floatround(vecEntBaseOrigin[2]) - iParams[3]);
	
	if(iDifference > 2)
	{
		remove_entity(iParams[0]);

		if(is_valid_ent(iParams[1]))
			remove_entity(iParams[1]);

		if(is_user_connected(iParams[2]))
			colorChat(iParams[2], _, "%sNo se puede mover tu torreta acá porque se bloqueó con una pared invisible!", TD_PREFIX);
	}
	else
	{
		remove_entity(iParams[0]);

		if(is_valid_ent(iParams[1]))
			remove_entity(iParams[1]);

		if(is_valid_ent(iParams[4]))
		{
			new entBase = entity_get_edict(iParams[4], SENTRY_ENT_BASE);
			new Float:vecMins[3];
			new Float:vecMaxs[3];

			vecMins[0] = -16.0;
			vecMins[1] = -16.0;
			vecMins[2] = 0.0;
			
			vecMaxs[0] = 16.0;
			vecMaxs[1] = 16.0;
			vecMaxs[2] = 48.0;

			entity_set_size(iParams[4], vecMins, vecMaxs);

			entity_set_vector(entBase, EV_VEC_origin, vecEntBaseOrigin);
			entity_set_vector(iParams[4], EV_VEC_origin, vecEntTopOrigin);

			entity_set_size(iParams[4], vecMins, vecMaxs);
		}
	}
}

// public buildRobot(const id) {
	// if(!is_user_alive(id)) {
		// return;
	// }
	
	// if(g_RobotCount) {
		// colorChat(id, _, "%sYa hay un robot creado.", TD_PREFIX);
		// return;
	// } else if(g_InBuilding[id]) {
		// colorChat(id, _, "%sNo podés crear un robot mientras estás construyendo otra cosa.", TD_PREFIX);
		// return;
	// } else if(!(entity_get_int(id, EV_INT_flags) & (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT))) { 
		// colorChat(id, _, "%sTenés que estar en el suelo para construir un robot.", TD_PREFIX);
		// return;
	// } else if(entity_get_int(id, EV_INT_bInDuck)) {
		// colorChat(id, _, "%sNo podés agacharte mientras construyes un robot.", TD_PREFIX);
		// return;
	// }
	
	// new Float:vecOrigin[3];
	// new Float:vecNewOrigin[3];
	// new Float:vecTraceDirection[3];
	// new Float:vecTraceEnd[3];
	// new Float:vecTraceResult[3];
	
	// entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	// velocity_by_aim(id, 64, vecTraceDirection);
	
	// vecTraceEnd[0] = vecTraceDirection[0] + vecOrigin[0];
	// vecTraceEnd[1] = vecTraceDirection[1] + vecOrigin[1];
	// vecTraceEnd[2] = vecTraceDirection[2] + vecOrigin[2];
	
	// trace_line(id, vecOrigin, vecTraceEnd, vecTraceResult);
	
	// vecNewOrigin[0] = vecTraceResult[0];
	// vecNewOrigin[1] = vecTraceResult[1];
	// vecNewOrigin[2] = vecOrigin[2];

	// if(createRobot(vecNewOrigin, id)) {
		// --g_Robot[id];
		// ++g_RobotCount;
	// } else {
		// colorChat(id, _, "%sNo podés construir un robot acá.", TD_PREFIX);
	// }
// }

// public createRobot(const Float:vecOrigin[3], const id) {
	// if(point_contents(vecOrigin) != CONTENTS_EMPTY || traceCheckCollides(vecOrigin, 24.0)) {
		// return 0;
	// }
	
	// new Float:vecHitPoint[3];
	// new Float:vecOriginDown[3];
	// new Float:fDistanceFromGround;
	// new Float:fDifference;
	
	// vecOriginDown = vecOrigin;
	// vecOriginDown[2] = -5000.0;
	
	// trace_line(0, vecOrigin, vecOriginDown, vecHitPoint);
	
	// fDistanceFromGround = vector_distance(vecOrigin, vecHitPoint);
	// fDifference = 36.0 - fDistanceFromGround;
	
	// if((fDifference < -20.0) || (fDifference > 20.0)) {
		// return 0;
	// }
	
	// new iEnt = create_entity("func_wall");
	
	// if(!iEnt) {
		// return 0;
	// }
	
	// new Float:vecMins[3];
	// new Float:vecMaxs[3];
	
	// vecMins[0] = -24.0;
	// vecMins[1] = -24.0;
	// vecMins[2] = 0.0;
	
	// vecMaxs[0] = 24.0;
	// vecMaxs[1] = 24.0;
	// vecMaxs[2] = 56.0;

	// drop_to_floor(iEnt);
	
	// DispatchSpawn(iEnt);
	
	// entity_set_string(iEnt, EV_SZ_classname, ENT_ROBOT_CLASSNAME);
	// entity_set_model(iEnt, MODEL_ROBOT[0]);

	// drop_to_floor(iEnt);

	// entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX);
	// entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS);

	// drop_to_floor(iEnt);
	
	// entity_set_size(iEnt, vecMins, vecMaxs);
	// entity_set_origin(iEnt, vecOrigin);

	// setRobotAnimation(iEnt, ROBOT_APPEAR);

	// register_think(ENT_ROBOT_CLASSNAME, "think__Robot");
	// entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.866667); // ROBOT APPEAR

	// g_RobotEnt = iEnt;
	
	// return 1;
// }

// public setRobotAnimation(const iEnt, const iAnimation) {
	// entity_set_int(iEnt, EV_INT_sequence, iAnimation);
	// entity_set_float(iEnt, EV_FL_animtime, get_gametime());
	// entity_set_float(iEnt, EV_FL_framerate, 1.0);
// }

// #define ROBOT_INT_HEALTH	EV_INT_iuser1
// #define ROBOT_INT_FIRE		EV_INT_iuser2
// #define ROBOT_INT_BLOCKED	EV_INT_iuser3
// #define ROBOT_INT_COMPLETED	EV_INT_iuser4
// #define ROBOT_ENT_TARGET	EV_ENT_euser1

// public think__Robot(const iEnt) {
	// if(!is_valid_ent(iEnt)) {
		// return;
	// }

	// if(entity_get_int(iEnt, ROBOT_INT_HEALTH) < 0) {
		// setRobotAnimation(iEnt, ROBOT_DEATH);
		// return;
	// }

	// static Float:vecRobotOrigin[3];
	// static Float:fDistance;
	// static Float:fMaxDistance;
	// static iTarget;
	// static iRobotCompleted;
	
	// entity_get_vector(iEnt, EV_VEC_origin, vecRobotOrigin);
	// vecRobotOrigin[2] += 24.0;
	
	// iTarget = entity_get_edict(iEnt, ROBOT_ENT_TARGET);
	// iRobotCompleted = entity_get_int(iEnt, ROBOT_INT_COMPLETED);
	// fMaxDistance = 800.0 + ((float(iRobotCompleted) * 300.0) / 100.0);
	
	// if(entity_get_int(iEnt, ROBOT_INT_FIRE) == 1 && isMonster(iTarget)) {
		// static Float:vecTargetOrigin[3];

		// entity_get_vector(iTarget, EV_VEC_origin, vecTargetOrigin);
		
		// fDistance = vector_distance(vecRobotOrigin, vecTargetOrigin);
		
		// if(fDistance <= fMaxDistance) {
			// entitySetAim(iEnt, vecRobotOrigin, vecTargetOrigin);
			
			// emit_sound(iEnt, CHAN_WEAPON, SOUND_SENTRY_FIRE, 0.35, ATTN_NORM, 0, PITCH_NORM);

			// static iDamage;
			// static iMinDamage;
			// static iMaxDamage;
			// static iExtraDamage;

			// iExtraDamage = (iRobotCompleted * 75) / 100;
			// iMinDamage = 50 + iExtraDamage;
			// iMaxDamage = 75 + iExtraDamage;

			// iDamage = random_num(iMinDamage, iMaxDamage);
			
			// static Float:fShield;			
			// fShield = entity_get_float(iTarget, MONSTER_SHIELD);
			
			// if(fShield == 1.0) {
				// iDamage /= 2;
			// } else if(fShield == 2.0) {
				// iDamage *= 2;
			// }
			
			// static Float:fNewHealth;
			// fNewHealth = entity_get_float(iTarget, EV_FL_health) - float(iDamage);
			
			// if(!isSpecialMonster(iTarget)) {
				// g_RobotDamage += iDamage;
				
				// if(g_RobotDamage >= 300) {
					// new i;
					// for(i = 1; i <= g_MaxUsers; ++i) {
						// if(!is_user_alive(i)) {
							// continue;
						// }

						// ++g_Gold[i];
						// ++g_GoldG[i];
					// }
					
					// g_RobotDamage -= 300;
				// }
			// } else {
				// if(g_GordoHealth) {
					// g_GordoHealth -= iDamage;
				// }
			// }

			// if(fNewHealth <= 0.0) {
				// removeMonster(iTarget, 1337);
			// } else {
				// entity_set_float(iTarget, EV_FL_health, fNewHealth);
			// }
			
			// vecTargetOrigin[2] += random_num(-16, 16);
			// effectTracer(vecRobotOrigin, vecTargetOrigin);
			
			// entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
			// return;
		// } else {
			// entity_set_int(iEnt, ROBOT_INT_FIRE, 0);
			// setRobotAnimation(iEnt, ROBOT_IDLE);
		// }
	// }
	
	// static iVictim;
	// static iClosest;
	// static Float:fClosestDistance;
	// static Float:vecClosestOrigin[3];
	// static Float:vecOrigin[3];

	// iVictim = -1;
	// iClosest = 0;
	
	// while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecRobotOrigin, fMaxDistance)) != 0) {
		// if(!isMonster(iVictim)) {
			// continue;
		// }
		
		// entity_get_vector(iVictim, EV_VEC_origin, vecOrigin);
		
		// vecOrigin[2] += 10.0;
		
		// fDistance = vector_distance(vecRobotOrigin, vecOrigin);
		// vecClosestOrigin = vecOrigin;
		
		// if(fDistance < fClosestDistance || iClosest == 0) {
			// iClosest = iVictim;
			// fClosestDistance = fDistance;
		// }
	// }
	
	// if(iClosest) {
		// entitySetAim(iEnt, vecRobotOrigin, vecClosestOrigin);
		
		// entity_set_int(iEnt, ROBOT_INT_FIRE, 1);
		// entity_set_edict(iEnt, ROBOT_ENT_TARGET, iClosest);

		// entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
		// return;
	// } else {
		// if(entity_get_int(iEnt, ROBOT_INT_FIRE) == 1) {
			// entity_set_int(iEnt, ROBOT_INT_FIRE, 0);
			// setRobotAnimation(iEnt, ROBOT_IDLE);
		// }
	// }
	
	// entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.25);
// }

// public robotFireMissiles() {
	// if(!is_valid_ent(g_RobotEnt)) {
		// return;
	// }

	// new Float:vecRobotOrigin[3];
	// new iMissiles = 0;
	// new iVictim = -1;
	// new iZombies[16];
	// new i;

	// entity_get_vector(g_RobotEnt, EV_VEC_origin, vecRobotOrigin);

	// while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecRobotOrigin, 9999.9)) != 0) {
		// if(!isMonster(iVictim)) {
			// continue;
		// }

		// if(isSpecialMonster(iVictim)) {
			// continue;
		// }

		// iZombies[iMissiles] = iVictim;
		
		// ++iMissiles;

		// if(iMissiles == 16) {
			// break;
		// }
	// }
	
	// iMissiles /= 2;
	
	// new Float:vecVelocity[3];
	// new iEnt;

	// for(i = 0; i < iMissiles; ++i) {
		// iEnt = create_entity("info_target");
		
		// if(!iEnt) {
			// continue;
		// }

		// entity_set_string(iEnt, EV_SZ_classname, "robot__Missile");
		// entity_set_model(iEnt, MODEL_TANK_ROCK_GIBS);
		
		// entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
		// entity_set_float(iEnt, EV_FL_renderamt, 0.0);
		
		// vecRobotOrigin[2] += 16.0;
		// entity_set_origin(iEnt, vecRobotOrigin);

		// entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
		// entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY);

		// emit_sound(iEnt, CHAN_WEAPON, SOUND_ROBOT_MISSILE_FIRED, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		// vecVelocity = Float:{0.0, 0.0, 64.0};
		// entity_set_vector(iEnt, EV_VEC_velocity, vecVelocity);
		
		// entity_set_edict(iEnt, EV_ENT_euser1, iZombies[i]);
		// entity_set_edict(iEnt, EV_ENT_euser3, createFlare(iEnt));
		
		// message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		// write_byte(TE_BEAMFOLLOW);
		// write_short(iEnt);
		// write_short(g_Sprite_Trail);
		// write_byte(30);
		// write_byte(2);
		// write_byte(255);
		// write_byte(0);
		// write_byte(0);
		// write_byte(255);
		// message_end();

		// set_task(1.0, "rocket__FollowVictim", iEnt);
	// }
// }

// createFlare(const missile) {
	// new iEnt = create_entity("env_sprite");
	
	// if(!is_valid_ent(iEnt))
		// return 0;
	
	// entity_set_model(iEnt, "sprites/animglow01.spr");
	
	// entity_set_float(iEnt, EV_FL_scale, random_float(0.2, 0.4));

	// entity_set_int(iEnt, EV_INT_spawnflags, SF_SPRITE_STARTON);
	// entity_set_int(iEnt, EV_INT_solid, SOLID_NOT);
	// entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW);

	// entity_set_edict(iEnt, EV_ENT_aiment, missile);
	// entity_set_float(iEnt, EV_FL_framerate, 25.0);
	
	// set_rendering(iEnt, kRenderFxNone, 255, 0, 0, kRenderTransAdd, 255);
	
	// DispatchSpawn(iEnt);

	// return iEnt;
// }

// public rocket__FollowVictim(const iEnt) {
	// if(!is_valid_ent(iEnt)) {
		// return;
	// }

	// new iVictim = entity_get_edict(iEnt, EV_ENT_euser1);

	// if(is_valid_ent(iVictim)) {
		// entity_set_follow(iEnt, iVictim, 512.0);
	// }

	// set_task(0.1, "rocket__FollowVictim", iEnt);
// }

public clcmd__Dance(const id) {
	if(!is_user_alive(id)) {
		return PLUGIN_HANDLED;
	}

	if(g_BossId == BOSS_FIRE && is_valid_ent(g_Boss)) {
		if(!g_Dance[id]) {
			g_Dance[id] = 1;

			new Float:flHealth = entity_get_float(g_Boss, EV_FL_health);
			new iHealth = entity_get_int(g_Boss, MONSTER_MAXHEALTH) - 3000;

			if(flHealth >= iHealth) {
				if(++g_Dances == 5) {
					new i;
					for(i = 0; i <= g_MaxUsers; ++i) {
						if(!is_user_alive(i)) {
							continue;
						}

						setAchievement(i, BOSS_FIRE_DANCE);
					}

					entity_set_float(g_Boss, EV_FL_nextthink, get_gametime() + 5.0);

					entity_set_vector(g_Boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
					
					entity_set_int(g_Boss, EV_INT_sequence, 0);

					entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
					entity_set_float(g_Boss, EV_FL_framerate, 1.0);
					
					entity_set_int(g_Boss, EV_INT_gamestate, 1);

					set_task(0.833333, "repeatAnimation_StupidFix", _, _, _, "a", 5);
				}
			}
		}
	}

	return PLUGIN_HANDLED;
}

public repeatAnimation_StupidFix() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}

	entity_set_int(g_Boss, EV_INT_sequence, 0);

	entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
	entity_set_float(g_Boss, EV_FL_framerate, 1.0);
	
	entity_set_int(g_Boss, EV_INT_gamestate, 1);
}

public fw_AddToFullPack_Post(const esHandle, const e, const ent, const host, const hostFlags, const player, const playerSet) {	
	if(is_user_connected(host) && !is_user_connected(ent) && pev_valid(ent)) {
		if(g_Option_LowFPS_Models[host] || g_Option_LowFPS_Glow[host]) {
			if(isMonster_LowFPS(ent)) {
				if(g_Option_LowFPS_Models[host]) {
					set_es(esHandle, ES_ModelIndex, g_LowFPS_ModelIndex_Zombie);
				}

				if(g_Option_LowFPS_Glow[host]) {
					set_es(esHandle, ES_RenderFx, kRenderFxNone);
					//set_es(esHandle, ES_RenderMode, kRenderNormal);
				}
			}
		}

		if(g_Option_LowFPS_ZombieDead[host]) {
			if(isMonster_LowFPS(ent)) {
				if(!entity_get_int(ent, MONSTER_MAXHEALTH)) {
					set_es(esHandle, ES_RenderMode, kRenderTransTexture);
					set_es(esHandle, ES_RenderAmt, 0);
				}
			}
		}

		if(g_Option_LowFPS_Sentries[host]) {
			if(isSentry_LowFPS(ent)) {
				if(entity_get_int(ent, SENTRY_OWNER) && entity_get_int(ent, SENTRY_CLIP)) {
					set_es(esHandle, ES_RenderMode, kRenderTransTexture);
					set_es(esHandle, ES_RenderAmt, 0);
				}
			}
		}
	}
	
	return FMRES_IGNORED;
}

public showMenu__LowFPS(const id) {
	if(!is_user_connected(id)) {
		return;
	}
	
	static sMenu[512];
	new iLen;
	
	iLen = 0;
	
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\yCALIDAD / RENDIMIENTO^n\wAcá podrás sacrificar calidad para ganar FPS!^n^n");
	
	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r1.\w MODELO ZOMBIES: %s^n   \r*\w Actualmente mejora \y%s\w!",
		(!g_Option_LowFPS_Models[id]) ? "\yACTIVADO" : "\rDESACTIVADO",
		(!g_Option_LowFPS_Models[id]) ? "la calidad" : "tus FPS");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n^n\r2.\w BRILLO ZOMBIES: %s^n   \r*\w Actualmente mejora \y%s\w!",
		(!g_Option_LowFPS_Glow[id]) ? "\yACTIVADO" : "\rDESACTIVADO",
		(!g_Option_LowFPS_Glow[id]) ? "la calidad" : "tus FPS");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n^n\r3.\w TORRETAS INVISIBLES: %s^n   \r*\w Actualmente mejora \y%s\w!",
		(!g_Option_LowFPS_Sentries[id]) ? "\yNO" : "\rSI",
		(!g_Option_LowFPS_Sentries[id]) ? "la calidad" : "tus FPS");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n^n\r4.\w ZOMBIES DESAPARECEN CUANDO MUEREN: %s^n   \r*\w Actualmente mejora \y%s\w!",
		(!g_Option_LowFPS_ZombieDead[id]) ? "\yNO" : "\rSI",
		(!g_Option_LowFPS_ZombieDead[id]) ? "la calidad" : "tus FPS");

	iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n^n\r0.\w VOLVER");
	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX);
	show_menu(id, KEYSMENU, sMenu, -1, "Options Low FPS");
}

public menu__LowFPS(const id, const key) {
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED;
	}
	
	switch(key) {
		case 0: {
			g_Option_LowFPS_Models[id] = !g_Option_LowFPS_Models[id];

			if(g_Option_LowFPS_Models[id]) {
				colorChat(id, _, "%sTodos los zombies excepto algunos deberían tener modelo de terrorista para aumentar tus FPS.", TD_PREFIX);
			} else {
				colorChat(id, _, "%sTodos los zombies vuelven a tener su modelo por defecto.", TD_PREFIX);
			}
		} case 1: {
			g_Option_LowFPS_Glow[id] = !g_Option_LowFPS_Glow[id];

			if(g_Option_LowFPS_Glow[id]) {
				colorChat(id, _, "");
				colorChat(id, _, "%sTodos los zombies excepto algunos ya no deberían tener brillo para aumentar tus FPS.", TD_PREFIX);
				colorChat(id, _, "%sTe recordamos que sin el brillo, no podrás ver a los zombies afectados por la Ión, ni aquellos con protección o doble daño.", TD_PREFIX);
			} else {
				colorChat(id, _, "%sTodos los zombies vuelven a tener su brillo por defecto.", TD_PREFIX);
			}
		} case 2: {
			g_Option_LowFPS_Sentries[id] = !g_Option_LowFPS_Sentries[id];

			if(g_Option_LowFPS_Sentries[id]) {
				colorChat(id, _, "");
				colorChat(id, _, "%sTodas las torretas ahora son invisibles para aumentar tus FPS.", TD_PREFIX);
				colorChat(id, _, "%sAquellas torretas sin dueño o sin balas volverán a aparecer para que puedas notarlo.", TD_PREFIX);
			} else {
				colorChat(id, _, "%sTodas las torretas vuelven a ser visibles.", TD_PREFIX);
			}
		} case 3: {
			g_Option_LowFPS_ZombieDead[id] = !g_Option_LowFPS_ZombieDead[id];

			if(g_Option_LowFPS_ZombieDead[id]) {
				colorChat(id, _, "%sCuando mueran los zombies desapareceran instantáneamente para aumentar tus FPS.", TD_PREFIX);
			} else {
				colorChat(id, _, "%sTodos los zombies vuelven a desaparecer normalmente.", TD_PREFIX);
			}
		} case 9: {
			showMenu__Configuration(id);
			return PLUGIN_HANDLED;
		}
	}
	
	showMenu__LowFPS(id);
	return PLUGIN_HANDLED;
}

public concmd__BanAccount(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_B)) {
		return PLUGIN_HANDLED;
	}
	
	new sName[32];
	new sDays[15];
	new iDays;
	new iHours;
	new iMinutes;
	new iSeconds;
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
		console_print(id, "[TD] El comando debe ser introducido de la siguiente manera: td_ban <NOMBRE COMPLETO> <HORAS O DIAS> <RAZON OBLIGATORIA>");
		console_print(id, "[TD] Ingrese 0 dias para banearlo permanentemente");
		console_print(id, "[TD] Si queres introducir el simbolo ~ escribe \0\");
		
		return PLUGIN_HANDLED;
	} else if(!containLetters(sDays) && !countNumbers(sDays)) {
		console_print(id, "[TD] El campo de HORAS O DIAS tiene que contener el Xh o Xd, ejemplo: 10h (banea por diez horas)");
		return PLUGIN_HANDLED;
	} else if(equali(sReason, "")) {
		console_print(id, "[TD] El campo RAZON no puede estar vacio");
		return PLUGIN_HANDLED;
	}
	
	if(equali(sName, "KISKE")) {
		colorChat(0, _, "%s!g%s!y quiso banear a !gKISKE!y :(", TD_PREFIX, g_UserName[id]);
		return PLUGIN_HANDLED;
	}

	if(equali(sName, "LeeVG")) {
		colorChat(0, _, "%s!g%s!y quiso banear a !gLeeVG!y :(", TD_PREFIX, g_UserName[id]);
		return PLUGIN_HANDLED;
	}

	new iUserId;

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id FROM td_users WHERE name=^"%s^";", sName);
	
	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 100500);
		return PLUGIN_HANDLED;
	} else if(SQL_NumResults(sqlQuery)) {
		iUserId = SQL_ReadResult(sqlQuery, 0);
		SQL_FreeHandle(sqlQuery);
	} else {
		console_print(id, "[TD] El nombre ingresado no esta registrado en ninguna cuenta");

		SQL_FreeHandle(sqlQuery);
		return PLUGIN_HANDLED;
	}

	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id FROM td_bans WHERE td_id='%d' AND activo='1';", iUserId);
	
	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 100501);
		return PLUGIN_HANDLED;
	} else if(SQL_NumResults(sqlQuery)) {
		console_print(id, "[TD] La cuenta ingresada ya esta baneada");

		SQL_FreeHandle(sqlQuery);
		return PLUGIN_HANDLED;
	} else {
		SQL_FreeHandle(sqlQuery);
	}

	new iExpireBan;
	if(equal(sDays, "0d")) {
		iExpireBan = 2000000000;

		colorChat(0, _, "%s!g%s!y baneo la cuenta de !g%s!y permanentemente", TD_PREFIX, g_UserName[id], sName);
		colorChat(0, _, "%s!gRazón:!y %s", TD_PREFIX, sReason);
	} else if(containi(sDays, "d") != -1) {
		replace(sDays, charsmax(sDays), "d", "");
		
		iDays = str_to_num(sDays);
		
		if(iDays < 0) {
			console_print(id, "[TD] No podes banear por menos de cero dias.");
			return PLUGIN_HANDLED;
		}
		
		iHours = iDays * 24;
		iMinutes = iHours * 60;
		iSeconds = iMinutes * 60;
		
		iExpireBan = get_systime() + iSeconds;
		
		colorChat(0, _, "%s!g%s!y baneo la cuenta de !g%s!y durante !g%d!y día%s", TD_PREFIX, g_UserName[id], sName, iDays, (iDays == 1) ? "" : "s");
		colorChat(0, _, "%s!gRazón:!y %s", TD_PREFIX, sReason);
	} else if(containi(sDays, "h") != -1) {
		replace(sDays, charsmax(sDays), "h", "");
		
		iHours = str_to_num(sDays);
		
		if(iHours > 23) {
			console_print(id, "[TD] No podes banear por mas de 23 horas, usa dias...");
			return PLUGIN_HANDLED;
		} else if(iHours < 1) {
			console_print(id, "[TD] No podes banear por menos de una hora");
			return PLUGIN_HANDLED;
		}
		
		iMinutes = iHours * 60;
		iSeconds = iMinutes * 60;
		
		iExpireBan = get_systime() + iSeconds;
		
		colorChat(0, _, "%s!g%s!y baneo la cuenta de !g%s!y durante !g%d!y hora%s", TD_PREFIX, g_UserName[id], sName, iHours, (iHours == 1) ? "" : "s");
		colorChat(0, _, "%s!gRazón:!y %s", TD_PREFIX, sReason);
	} else {
		console_print(id, "[TD] Algo esta fallando, revisa el formato del comando nuevamente");
		return PLUGIN_HANDLED;
	}
	
	new sExpireBan[25];
	if(iExpireBan != 2000000000) {
		new iYear;
		new iMonth;
		new iDay;
		new iHour;
		new iMinute;
		new iSecond;
		
		new sMonth[4];
		new sDay[4];
		new sHour[4];
		new sMinute[4];
		new sSecond[4];
		
		unix_to_time(iExpireBan, iYear, iMonth, iDay, iHour, iMinute, iSecond);
		
		formatex(sMonth, charsmax(sMonth), "%s%d", (iMonth < 10) ? "0" : "", iMonth);
		formatex(sDay, charsmax(sDay), "%s%d", (iDay < 10) ? "0" : "", iDay);
		formatex(sHour, charsmax(sHour), "%s%d", (iHour < 10) ? "0" : "", iHour);
		formatex(sMinute, charsmax(sMinute), "%s%d", (iMinute < 10) ? "0" : "", iMinute);
		formatex(sSecond, charsmax(sSecond), "%s%d", (iSecond < 10) ? "0" : "", iSecond);
		
		formatex(sExpireBan, charsmax(sExpireBan), "%d-%s-%s %s:%s:%s", iYear, sMonth, sDay, sHour, sMinute, sSecond);
	} else {
		formatex(sExpireBan, charsmax(sExpireBan), "2020-01-01 00:00:00");
	}
	
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "INSERT INTO td_bans (`td_id`, `start`, `finish`, `name_admin`, `reason`, `activo`) VALUES ('%d', now(), ^"%s^", ^"%s^", ^"%s^", '1');",
		iUserId, sExpireBan, g_UserName[id], sReason);
	
	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 100503);
	} else {
		SQL_FreeHandle(sqlQuery);
	}
	
	new iTarget = get_user_index(sName);
	if(is_user_connected(iTarget)) {
		new sTime[35];
		get_time("%Y-%m-%d %H:%M:%S", sTime, 34);
		
		console_print(iTarget, "");
		console_print(iTarget, "");
		console_print(iTarget, "****** DRUNK GAMING ******");
		console_print(iTarget, "");
		console_print(iTarget, "TU CUENTA ESTA BANEADA");
		console_print(iTarget, "");
		console_print(iTarget, "Administrador que te baneo: %s", g_UserName[id]);
		console_print(iTarget, "Razón: %s", sReason);
		console_print(iTarget, "El ban fue realizado en la fecha: %s", sTime);
		console_print(iTarget, "El ban expira en la fecha: %s", sExpireBan);
		console_print(iTarget, "Cuenta #%d", g_UserId[iTarget]);
		console_print(iTarget, "");
		console_print(iTarget, "****** DRUNK GAMING ******");
		console_print(iTarget, "");
		console_print(iTarget, "");
		
		server_cmd("kick #%d", get_user_userid(iTarget));
	}

	return PLUGIN_HANDLED;
}


public concmd__UnbanAccount(const id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_B)) {
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
		console_print(id, "[TD] El comando debe ser introducido de la siguiente manera: td_unban <NOMBRE COMPLETO>");
		return PLUGIN_HANDLED;
	}

	new iUserId;

	new Handle:sqlQuery;
	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "SELECT id FROM td_users WHERE name=^"%s^";", sName);
	
	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 100499);
	} else if(SQL_NumResults(sqlQuery)) {
		iUserId = SQL_ReadResult(sqlQuery, 0);
		SQL_FreeHandle(sqlQuery);
	} else {
		console_print(id, "[ZP] El usuario indicado no existe. Recorda escribir su nombre completamente respetando mayusculas y minusculas");

		SQL_FreeHandle(sqlQuery);
		return PLUGIN_HANDLED;
	}


	sqlQuery = SQL_PrepareQuery(g_SqlConnection, "UPDATE td_bans SET activo='0' WHERE td_id='%d'", iUserId);
	
	if(!SQL_Execute(sqlQuery)) {
		executeQuery(id, sqlQuery, 18);
	} else {
		console_print(id, "[TD] El usuario indicado fue desbaneado");
		colorChat(0, _, "%s!g%s!y desbaneo la cuenta de !g%s!y", TD_PREFIX, g_UserName[id], sName);

		SQL_FreeHandle(sqlQuery);
	}

	return PLUGIN_HANDLED;
}

stock containLetters(const String[]) {
	new iLen = strlen(String);
	new i;
	
	for(i = 0; i < iLen; ++i) {
		if(isalpha(String[i])) {
			return 1;
		}
	}
	
	return 0;
}

stock countNumbers(const String[], const iLen = sizeof(String)) {
	new iCount = 0;
	new i;
	
	for(i = 0; i < iLen; ++i) {
		if(isdigit(String[i])) {
			++iCount;
		}
	}
	
	return iCount;
}

public think__Boss_FallenTitan(const iEnt) {
	if(!is_valid_ent(iEnt)) {
		return;
	}
	
	if(!entity_get_int(iEnt, MONSTER_MAXHEALTH)) {
		return;
	}
	
	static iVictim;
	iVictim = entity_get_int(iEnt, MONSTER_TARGET);
	
	if(is_user_alive(iVictim)) {
		static Float:vecEntOrigin[3];
		static Float:vecVictimOrigin[3];
		static Float:fDistance;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecEntOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);
		
		fDistance = vector_distance(vecEntOrigin, vecVictimOrigin);
		
		static Float:flGameTime;
		static iRandom;
		
		flGameTime = get_gametime();
		
		if(fDistance <= 260.0) {
			if(g_BossPower[0] != BOSS_FT_DASH) {
				entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
				
				emit_sound(iVictim, CHAN_BODY, SOUND_BOSS_PHIT[random_num(0, 2)], 0.5, ATTN_NORM, 0, PITCH_NORM);
				
				entity_set_int(iEnt, EV_INT_sequence, random_num(11, 12));
				entity_set_float(iEnt, EV_FL_animtime, flGameTime);
				entity_set_float(iEnt, EV_FL_framerate, ((!g_Boss_FT_Enrage) ? 3.0 : 6.0));
				
				entity_set_int(iEnt, EV_INT_gamestate, 1);
				
				static Float:vecSub[3];
				
				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub); // vec1 - vec2
				xs_vec_mul_scalar(vecSub, 2400.0, vecSub);
				
				vecSub[2] = random_float(100.0, 150.0);
				entity_set_vector(iVictim, EV_VEC_velocity, vecSub);
				entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
				
				entity_set_float(iEnt, EV_FL_nextthink, flGameTime + ((!g_Boss_FT_Enrage) ? 1.266667 : 0.633334));
				
				ExecuteHam(Ham_TakeDamage, iVictim, 0, iEnt, (DIFFICULTIES_VALUES[g_Difficulty][difficultyBossGorilaDamage] * ((!g_Boss_FT_Enrage) ? 1.5 : 2.0)), DMG_SLASH);

				g_BossRollSpeed[0] = 0.0;
				
				return;
			}
		} else {
			static Float:fVelocity;

			g_BossRollSpeed[0] += (!g_Boss_FT_Enrage) ? 0.4 : 2.5;
			fVelocity = 265.0 + g_BossRollSpeed[0];
			
			if(entity_get_int(iEnt, EV_INT_gamestate) != 3) {
				entity_set_int(iEnt, EV_INT_gamestate, 3);

				entity_set_int(iEnt, EV_INT_sequence, 6); // WALK
				entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			}

			entity_set_float(iEnt, EV_FL_framerate, fVelocity / 250.0); // VELOCIDAD / 250.0

			entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, fVelocity, .iAngleMode=1);
			
			if(!g_BossPower[0] && g_Boss_TimePower[0] <= flGameTime) {
				iRandom = random_num(1, 5);

				if(g_Boss_FT_LastPower == iRandom) {
					iRandom += 2;

					if(iRandom == 7) {
						iRandom = 1;
					}
				}

				g_Boss_FT_LastPower = iRandom;

				switch(iRandom) {
					case 1, 3, 5: {
						entity_set_vector(iEnt, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});

						switch(iRandom) {
							case 1: {
								g_BossPower[0] = BOSS_FT_DASH;
								g_Boss_TimePower[0] = flGameTime + ((!g_Boss_FT_Enrage) ? 15.0 : 6.0);
								
								entity_set_int(iEnt, EV_INT_sequence, 8); // DASH READY

								set_hudmessage(255, 0, 0, -1.0, 0.5, 0, 0.0, 5.0, 0.0, 0.0, 4);
								ShowSyncHudMsg(0, g_HudDamageTower, "No dejes que el jefe golpee una pared!");
								
								set_task((!g_Boss_FT_Enrage) ? 2.333334 : 1.166667, "bossFallenTitan_PowerDash");
								
								entity_set_int(iEnt, MONSTER_TARGET, 0);
							} case 3: {
								g_BossPower[0] = BOSS_FT_CANNON;
								g_Boss_TimePower[0] = flGameTime + ((!g_Boss_FT_Enrage) ? 7.5 : 3.0);
								
								new iUserId[MAX_USERS];
								new j = 0;
								
								for(iRandom = 1; iRandom <= g_MaxUsers; ++iRandom) {
									if(!is_user_alive(iRandom)) {
										continue;
									}
									
									iUserId[j] = iRandom;
									++j;
								}
								
								iRandom = iUserId[random_num(0, (j-1))];
								
								if(is_user_alive(iRandom)) {
									entity_get_vector(iRandom, EV_VEC_origin, vecVictimOrigin);
									
									entitySetAim(iEnt, vecEntOrigin, vecVictimOrigin, .iAngleMode=1);
									
									entity_set_int(iEnt, MONSTER_TARGET, 0);
								}
								
								entity_set_int(iEnt, EV_INT_sequence, 13); // CANNON READY
								
								new iArgs[2];
								iArgs[0] = iRandom;
								iArgs[1] = 1;

								set_task((!g_Boss_FT_Enrage) ? 1.5 : 0.75, "bossFallenTitan_PowerCannon", _, iArgs, 2);
							} case 5: {
								g_BossPower[0] = BOSS_FT_TENTACLES;
								g_Boss_TimePower[0] = flGameTime + ((!g_Boss_FT_Enrage) ? 8.0 : 4.0);
								
								entity_set_int(iEnt, EV_INT_sequence, 18); // TENTACLES
								
								set_task((!g_Boss_FT_Enrage) ? 1.23 : 0.615, "bossFallenTitan_PowerTentacles");

								entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + ((!g_Boss_FT_Enrage) ? 4.7 : 2.35));
							}
						}
						
						entity_set_float(iEnt, EV_FL_animtime, flGameTime);
						entity_set_float(iEnt, EV_FL_framerate, ((!g_Boss_FT_Enrage) ? 1.0 : 2.0));
						
						entity_set_int(iEnt, EV_INT_gamestate, 1);
						
						return;
					} default: {
						g_Boss_TimePower[0] = flGameTime + ((!g_Boss_FT_Enrage) ? 4.0 : 3.0);
					}
				}
			}
			
			iVictim = miniBoss__SearchHuman(iEnt);
			entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		}
	} else {
		iVictim = miniBoss__SearchHuman(iEnt);
		entity_set_int(iEnt, MONSTER_TARGET, iVictim);
		
		if(!iVictim) {
			entity_set_int(iEnt, EV_INT_sequence, 5);
			entity_set_float(iEnt, EV_FL_animtime, get_gametime());
			entity_set_float(iEnt, EV_FL_framerate, 1.0);
			
			entity_set_int(iEnt, EV_INT_gamestate, 1);
			
			return;
		}
	}
	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
}

public bossFallenTitan_PowerDash() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	set_hudmessage(255, 0, 0, -1.0, 0.5, 0, 0.0, 5.0, 0.0, 0.0, 4);
	ShowSyncHudMsg(0, g_HudDamageTower, "No dejes que el jefe golpee una pared!");
	
	new Float:vecOrigin[3];
	new Float:vecOriginBoss[3];
	new Float:flDistance;
	
	entity_get_vector(g_Boss, EV_VEC_origin, vecOriginBoss);
	
	entity_set_int(g_Boss, EV_INT_sequence, 9); // DASH
	entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
	entity_set_float(g_Boss, EV_FL_framerate, (!g_Boss_FT_Enrage) ? 1.5 : 3.0);
	
	entity_set_int(g_Boss, EV_INT_gamestate, 1);
	
	getDestination(g_Boss, 8192.0, 0.0, 0.0, vecOrigin);
	
	flDistance = get_distance_f(vecOriginBoss, vecOrigin);
	
	followHuman(g_Boss, vecOriginBoss, vecOrigin, flDistance, (!g_Boss_FT_Enrage) ? 375.0 : 750.0);
}

public touch__Boss_FallenTitan(const pBoss, const pUser) {
	if(pev_valid(pBoss) && g_BossPower[0] == BOSS_FT_DASH) {
		g_BossPower[0] = 0;
		
		new Float:flGameTime;
		flGameTime = get_gametime();

		client_cmd(0, "spk ^"%s^"", SOUND_BOSS_IMPACT);

		entity_set_vector(pBoss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});
		
		entity_set_int(pBoss, EV_INT_sequence, 10); // DASH END
		entity_set_float(pBoss, EV_FL_animtime, flGameTime);
		entity_set_float(pBoss, EV_FL_framerate, (!g_Boss_FT_Enrage) ? 1.0 : 2.0);
		
		entity_set_int(pBoss, EV_INT_gamestate, 1);
		
		entity_set_float(pBoss, EV_FL_nextthink, flGameTime + ((!g_Boss_FT_Enrage) ? 1.766667 : 0.883334));

		new Float:vecSub[3];
		new Float:vecEntOrigin[3];
		new Float:vecVictimOrigin[3];

		entity_get_vector(pBoss, EV_VEC_origin, vecEntOrigin);
		
		if(pev_valid(pUser) && is_user_alive(pUser)) {
			setAchievement(pUser, BOSS_FT_HIT);

			entity_get_vector(pUser, EV_VEC_origin, vecVictimOrigin);

			xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub); // vec1 - vec2
			xs_vec_mul_scalar(vecSub, 300.0, vecSub);
			
			vecSub[2] = random_float(150.0, 400.0);
			entity_set_vector(pUser, EV_VEC_velocity, vecSub);
			
			ExecuteHam(Ham_TakeDamage, pUser, 0, pBoss, 50.0, DMG_BLAST);

			message_begin(MSG_ONE_UNRELIABLE, g_Message_Screenfade, _, pUser);
			write_short(UNIT_SECOND * 5);
			write_short(0);
			write_short(FFADE_IN);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(155);
			message_end();
		} else {
			new i;
			for(i = 1; i <= g_MaxUsers; ++i) {
				if(!is_user_alive(i)) {
					continue;
				}

				entity_get_vector(i, EV_VEC_origin, vecVictimOrigin);

				xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub); // vec1 - vec2
				xs_vec_mul_scalar(vecSub, 200.0, vecSub);
				
				vecSub[2] = random_float(150.0, 400.0);
				entity_set_vector(i, EV_VEC_velocity, vecSub);
				
				ExecuteHam(Ham_TakeDamage, i, 0, pBoss, 75.0, DMG_BLAST);
			}

			message_begin(MSG_BROADCAST, g_Message_ScreenShake);
			write_short(1<<14);
			write_short(1<<13);
			write_short(1<<13);
			message_end();
			
			message_begin(MSG_BROADCAST, g_Message_Screenfade);
			write_short(UNIT_SECOND * 5);
			write_short(0);
			write_short(FFADE_IN);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(155);
			message_end();
		}
	}
}

public bossFallenTitan_PowerCannon(const iArgs[2]) {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new iVictim = iArgs[0];
	new playAnim = iArgs[1];

	if(is_user_alive(iVictim)) {
		if(playAnim) {
			entity_set_int(g_Boss, EV_INT_sequence, 14); // CANNON FIRE
			entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
			entity_set_float(g_Boss, EV_FL_framerate, (!g_Boss_FT_Enrage) ? 1.0 : 2.0);
			
			entity_set_int(g_Boss, EV_INT_gamestate, 1);
		}

		new Float:vecBossOrigin[3];
		new Float:vecVictimOrigin[3];
		new Float:vecVelocity[3];

		entity_get_vector(g_Boss, EV_VEC_origin, vecBossOrigin);
		entity_get_vector(iVictim, EV_VEC_origin, vecVictimOrigin);	

		entitySetAim(g_Boss, vecBossOrigin, vecVictimOrigin, .iAngleMode=1337);

		client_cmd(0, "spk ^"%s^"", SOUND_FT_CANNON);
		
		new iDistance = floatround(vector_distance(vecBossOrigin, vecVictimOrigin));
		
		velocity_by_aim(g_Boss, iDistance, vecVelocity);

		entitySetAim(g_Boss, vecBossOrigin, vecVictimOrigin, .iAngleMode=1);
		
		new iSpitterBall;
		iSpitterBall = create_entity("info_target");
		
		if(is_valid_ent(iSpitterBall)) {
			entity_set_string(iSpitterBall, EV_SZ_classname, "entCannonBall");
			entity_set_model(iSpitterBall, MODEL_TANK_ROCK_GIBS);
			
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
			
			register_think("entCannonBall", "think__CannonBall");
			
			entity_set_float(iSpitterBall, EV_FL_nextthink, get_gametime() + 0.1);
		}
	}

	if(playAnim) {
		set_task((!g_Boss_FT_Enrage) ? 1.266667 : 0.633334, "bossFallenTitan_PowerCannon_End");
	}
}

public bossFallenTitan_PowerCannon_End() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	entity_set_int(g_Boss, EV_INT_sequence, 15); // CANNON END
	entity_set_float(g_Boss, EV_FL_animtime, get_gametime());
	entity_set_float(g_Boss, EV_FL_framerate, (!g_Boss_FT_Enrage) ? 1.0 : 2.0);
	
	entity_set_int(g_Boss, EV_INT_gamestate, 1);

	entity_set_float(g_Boss, EV_FL_nextthink, get_gametime() + ((!g_Boss_FT_Enrage) ? 1.5 : 0.75));

	g_BossPower[0] = 0;
}

public think__CannonBall(const iEnt) {
	if(is_valid_ent(iEnt)) {
		if(entity_get_int(iEnt, EV_INT_solid) == SOLID_TRIGGER) {
			static Float:vecOrigin[3];
			static iVictim;
			
			entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
			
			iVictim = -1;
			
			while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 62.5)) != 0) {
				if(!is_user_alive(iVictim)) {
					continue;
				}
				
				emit_sound(iVictim, CHAN_BODY, SOUND_BOSS_PHIT[random_num(0, charsmax(SOUND_BOSS_PHIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				new iHealth = get_user_health(iVictim) - ((!g_Boss_FT_Enrage) ? 1 : 2);
				
				if(iHealth <= 0) {
					ExecuteHamB(Ham_Killed, iVictim, iVictim, 0);
					
					if(!getUsersAlive()) {
						removeAllEnts(1);
						__finishGame();
					}
				} else {
					set_user_health(iVictim, iHealth);
					
					message_begin(MSG_ONE_UNRELIABLE, g_Message_Screenfade, _, iVictim);
					write_short(UNIT_SECOND * 1);
					write_short(UNIT_SECOND * 1);
					write_short(FFADE_IN);
					write_byte(255);
					write_byte(0);
					write_byte(0);
					write_byte(125);
					message_end();
				}
			}
		} else {
			if((get_entity_flags(iEnt) & FL_ONGROUND) && fm_get_speed(iEnt) < 10) {
				new Float:vecOrigin[3];
				entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
				
				entity_set_vector(iEnt, EV_VEC_angles, Float:{180.0, 0.0, 0.0});
				
				entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
				vecOrigin[2] += 30.0;
				entity_set_vector(iEnt, EV_VEC_origin, vecOrigin);
				
				entity_set_model(iEnt, MODEL_FT_AURA);
				
				entity_set_int(iEnt, EV_INT_renderfx, kRenderFxPulseSlow);
				entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAlpha);
				entity_set_float(iEnt, EV_FL_renderamt, 120.0);
			}
		}

		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1);
	}
}

public bossFallenTitan_PowerTentacles() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new Float:vecOrigin[3];
	new iTentacle;
	new i;

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		if(!(get_entity_flags(i) & FL_ONGROUND)) {
			continue;
		}

		if(!random_num(0, (!g_Boss_FT_Enrage) ? 2 : 1)) {
			iTentacle = create_entity("info_target");

			if(is_valid_ent(iTentacle)) {
				entity_set_string(iTentacle, EV_SZ_classname, "entTentacle");
				entity_set_model(iTentacle, MODEL_TENTACLE);

				entity_set_size(iTentacle, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
				
				entity_get_vector(i, EV_VEC_origin, vecOrigin);

				//vecOrigin[2] += 80.0;
				entity_set_origin(iTentacle, vecOrigin);
				
				entity_set_int(iTentacle, EV_INT_solid, SOLID_TRIGGER);
				entity_set_int(iTentacle, EV_INT_movetype, MOVETYPE_FLY);

				entity_set_int(iTentacle, EV_INT_sequence, 1);
				entity_set_float(iTentacle, EV_FL_animtime, get_gametime());
				entity_set_float(iTentacle, EV_FL_framerate, 1.0);
				
				entity_set_int(iTentacle, EV_INT_gamestate, 1);

				register_think("entTentacle", "think__Tentacle");
				entity_set_float(iTentacle, EV_FL_nextthink, get_gametime() + 0.1);
			}
		}
	}

	g_BossPower[0] = 0;
}

public think__Tentacle(const iEnt) {
	if(is_valid_ent(iEnt)) {
		static Float:vecOrigin[3];
		static iVictim;
		
		entity_get_vector(iEnt, EV_VEC_origin, vecOrigin);
		
		iVictim = -1;
		
		while((iVictim = find_ent_in_sphere(iVictim, vecOrigin, 12.0)) != 0) {
			if(!is_user_alive(iVictim)) {
				continue;
			}
			
			emit_sound(iVictim, CHAN_BODY, SOUND_BOSS_PHIT[random_num(0, charsmax(SOUND_BOSS_PHIT))], 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			new iHealth = get_user_health(iVictim) - ((!g_Boss_FT_Enrage) ? 3 : 5);
			
			if(iHealth <= 0) {
				ExecuteHamB(Ham_Killed, iVictim, iVictim, 0);
				
				if(!getUsersAlive()) {
					removeAllEnts(1);
					__finishGame();
				}
			} else {
				set_user_health(iVictim, iHealth);
				
				message_begin(MSG_ONE_UNRELIABLE, g_Message_Screenfade, _, iVictim);
				write_short(UNIT_SECOND * 1);
				write_short(UNIT_SECOND * 1);
				write_short(FFADE_IN);
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

		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.0);
	}
}

public bossFallenTitan__Screaming() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new Float:vecVictimOrigin[3];
	new Float:vecEntOrigin[3];
	new Float:vecSub[3];
	new i;

	entity_get_vector(g_Boss, EV_VEC_origin, vecEntOrigin);

	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		entity_get_vector(i, EV_VEC_origin, vecVictimOrigin);

		xs_vec_sub(vecVictimOrigin, vecEntOrigin, vecSub); // vec1 - vec2
		xs_vec_mul_scalar(vecSub, 300.0, vecSub);
		
		vecSub[2] = random_float(400.0, 650.0);
		entity_set_vector(i, EV_VEC_velocity, vecSub);
		
		ExecuteHam(Ham_TakeDamage, i, 0, g_Boss, random_float(75.0, 125.0), DMG_BLAST);
	}

	message_begin(MSG_BROADCAST, g_Message_ScreenShake);
	write_short((1<<12) * 7);
	write_short((1<<12) * 7);
	write_short((1<<12) * 7);
	message_end();
	
	message_begin(MSG_BROADCAST, g_Message_Screenfade);
	write_short(UNIT_SECOND * 5);
	write_short(0);
	write_short(FFADE_IN);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(155);
	message_end();

	g_BossPower[0] = 0;
}

public bossFallenTitan__HyperCannon() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	static i;
	new iArgs[2];

	iArgs[1] = 0;

	if(i > g_MaxUsers) {
		i = 0;
	}

	while(++i <= g_MaxUsers) {
		if(!is_user_alive(i)) {
			continue;
		}

		iArgs[0] = i;
		bossFallenTitan_PowerCannon(iArgs);

		break;
	}

	--g_Boss_FT_UltimateCannons;

	if(!g_Boss_FT_UltimateCannons) {
		return;
	}

	set_task(0.3, "bossFallenTitan__HyperCannon");
}

public bossFT__StartHyperCannon() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new Float:flGameTime = get_gametime();

	g_BossPower[0] = BOSS_FT_HIPER_CANNON;
	g_Boss_TimePower[0] = flGameTime + 7.0;

	entity_set_int(g_Boss, EV_INT_sequence, 16); // HIPER CANNON
	entity_set_float(g_Boss, EV_FL_animtime, flGameTime);
	entity_set_float(g_Boss, EV_FL_framerate, 1.0);

	entity_set_int(g_Boss, EV_INT_gamestate, 1);

	entity_set_vector(g_Boss, EV_VEC_velocity, Float:{0.0, 0.0, 0.0});

	entity_set_float(g_Boss, EV_FL_nextthink, flGameTime + 6.466667);

	g_Boss_FT_UltimateCannons = 15;
	set_task(1.0, "bossFallenTitan__HyperCannon");

	g_BossPower[0] = 0;
	g_Boss_FT_Enrage = 1;
}

public bossFT__InfiniteCannons() {
	if(!is_valid_ent(g_Boss)) {
		return;
	}
	
	if(!entity_get_int(g_Boss, MONSTER_MAXHEALTH)) {
		return;
	}

	new iUserId[MAX_USERS];
	new j = 0;
	new iArgs[2];
	new iRandom;

	iArgs[1] = 0;

	for(iRandom = 1; iRandom <= g_MaxUsers; ++iRandom) {
		if(!is_user_alive(iRandom)) {
			continue;
		}
		
		iUserId[j] = iRandom;
		++j;
	}

	iRandom = iUserId[random_num(0, (j-1))];

	if(is_user_alive(iRandom)) {
		iArgs[0] = iRandom;
		bossFallenTitan_PowerCannon(iArgs);
	}

	set_task(0.8, "bossFT__InfiniteCannons");
}

public addKillsToEveryone(const kills) {
	new i;
	for(i = 1; i <= g_MaxUsers; ++i) {
		if(!is_user_alive(i)) {
			continue;
		}

		++g_Kills[i];

		__checkKillerLevelUp(i);

		set_user_frags(i, get_user_frags(i) + kills);
		
		message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
		write_byte(i);
		write_short(get_user_frags(i));
		write_short(cs_get_user_deaths(i));
		write_short(0);
		write_short(getUserTeam(i));
		message_end();
	}
}

public addKill(const killer) {
	++g_Kills[killer];

	__checkKillerLevelUp(killer);

	set_user_frags(killer, get_user_frags(killer) + 1);
	
	message_begin(MSG_BROADCAST, g_Message_ScoreInfo);
	write_byte(killer);
	write_short(get_user_frags(killer));
	write_short(cs_get_user_deaths(killer));
	write_short(0);
	write_short(getUserTeam(killer));
	message_end();
}

public concmd__Lights(const id)
{
	if(!g_Kiske[id])
		return PLUGIN_HANDLED;

	new sArg1[4];
	read_argv(1, sArg1, 3);

	if(!containLetters(sArg1))
		return PLUGIN_HANDLED;

	formatex(g_Lights, 1, "%c", sArg1);
	set_lights(g_Lights[0]);

	colorChat(0, SPECTATOR, "%s!t%s!y cambió el grado de iluminación del mapa a !g%c!y", TD_PREFIX, g_UserName[id], sArg1);
	return PLUGIN_HANDLED;
}