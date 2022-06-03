/* AMX Mod X
*	[ZP] Extra: Skull-4
*
* http://aghl.ru/forum/ - Russian Half-Life and Adrenaline Gamer Community
*
* This file is provided as is (no warranties)
*/

// Undefine for Zombie Plague 5.0 support
//#define ZP50

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

native zp_get_user_zombie(const id);
native zp_get_user_specialmode(const id);
forward zp_user_infected_post(const id, const attacker, const silent_mode, const bomb, const first_zombie, const nemesis);
forward zp_user_humanized_post(const id, const silent_mode, const survivor);

#define PLUGIN "[ZP] Extra: Skull-4"
#define VERSION "1.0"
#define AUTHOR "KORD_12.7"

#pragma semicolon 1
#pragma ctrlchar '\'

//**********************************************
//* Weapon Settings.                           *
//**********************************************

// Main
#define WEAPON_NAME 			"weapon_skull4"
#define WEAPON_REFERANCE		"weapon_ak47"
#define WEAPON_MAX_CLIP			48
#define WEAPON_DEFAULT_AMMO		200
#define WEAPON_MAX_SPEED		220.0

#define WEAPON_MULTIPLIER_DAMAGE 	1.5

#define WEAPON_TIME_NEXT_IDLE 		2.03
#define WEAPON_TIME_NEXT_ATTACK 	0.0955
#define WEAPON_TIME_DELAY_DEPLOY 	1.23
#define WEAPON_TIME_DELAY_RELOAD 	3.43

// #define ZP_ITEM_NAME			"[Dual carbines] Skull-4" 
// #define ZP_ITEM_COST			25

// Models
#define MODEL_WORLD		"models/w_skull4.mdl"
#define MODEL_VIEW		"models/v_skull4.mdl"
#define MODEL_PLAYER		"models/p_skull4.mdl"
#define MODEL_SHELL		"models/rshell.mdl"

// Sounds
#define SOUND_FIRE		"weapons/skull4_shoot1.wav"
#define SOUND_DRAW		"weapons/skull4_draw.wav"
#define SOUND_CLIPIN		"weapons/skull4_clipin.wav"
#define SOUND_CLIPOUT		"weapons/skull4_clipout.wav"

// Sprites
#define WEAPON_HUD_TXT		"sprites/weapon_skull4.txt"
#define WEAPON_HUD_SPR_1	"sprites/640hud7.spr"
#define WEAPON_HUD_SPR_2	"sprites/640hud87.spr"

// Animation
#define ANIM_EXTENSION		"dualpistols"

// Animation sequences
enum
{	
	ANIM_IDLE,
	ANIM_RELOAD,
	ANIM_DRAW,
	ANIM_SHOOT_RIGHT,
	ANIM_SHOOT_LEFT
};

//**********************************************
//* Some macroses.                             *
//**********************************************

#define MDLL_Spawn(%0)			dllfunc(DLLFunc_Spawn, %0)
#define MDLL_Touch(%0,%1)		dllfunc(DLLFunc_Touch, %0, %1)

#define SET_MODEL(%0,%1)		engfunc(EngFunc_SetModel, %0, %1)
#define SET_ORIGIN(%0,%1)		engfunc(EngFunc_SetOrigin, %0, %1)

#define PRECACHE_MODEL(%0)		engfunc(EngFunc_PrecacheModel, %0)
#define PRECACHE_SOUND(%0)		engfunc(EngFunc_PrecacheSound, %0)
#define PRECACHE_GENERIC(%0)		engfunc(EngFunc_PrecacheGeneric, %0)

#define MESSAGE_BEGIN(%0,%1,%2,%3)	engfunc(EngFunc_MessageBegin, %0, %1, %2, %3)
#define MESSAGE_END()			message_end()

#define WRITE_ANGLE(%0)			engfunc(EngFunc_WriteAngle, %0)
#define WRITE_BYTE(%0)			write_byte(%0)
#define WRITE_COORD(%0)			engfunc(EngFunc_WriteCoord, %0)
#define WRITE_STRING(%0)		write_string(%0)
#define WRITE_SHORT(%0)			write_short(%0)

#define INSTANCE(%0)			((%0 == -1) ? 0 : %0)

//**********************************************
//* PvData Offsets.                            *
//**********************************************

// Linux extra offsets
#define extra_offset_weapon		4
#define extra_offset_player		5

// CWeaponBox
#define m_rgpPlayerItems_CWeaponBox	34

// CBasePlayerItem
#define m_pPlayer			41
#define m_pNext				42

// CBasePlayerWeapon
#define m_flNextPrimaryAttack		46
#define m_flNextSecondaryAttack		47
#define m_flTimeWeaponIdle		48
#define m_iPrimaryAmmoType		49
#define m_iClip				51
#define m_fInReload			54
#define m_iDirection			60
#define m_flAccuracy			62
#define m_iShotsFired			64
#define m_fWeaponState			74

// CBaseMonster
#define m_flNextAttack			83

// CBasePlayer
#define m_iFOV				363
#define m_rgpPlayerItems_CBasePlayer	367
#define m_pActiveItem			373
#define m_rgAmmo_CBasePlayer		376
#define m_szAnimExtention		492

#define IsValidPev(%0) (pev_valid(%0) == 2)

//**********************************************
//* Let's code our weapon.                     *
//**********************************************

Weapon_OnPrecache()
{
	PRECACHE_MODEL(MODEL_VIEW);
	PRECACHE_MODEL(MODEL_WORLD);
	PRECACHE_MODEL(MODEL_PLAYER);
	PRECACHE_MODEL(MODEL_SHELL);
	
	PRECACHE_SOUND(SOUND_FIRE);
	PRECACHE_SOUND(SOUND_DRAW);
	PRECACHE_SOUND(SOUND_CLIPIN);
	PRECACHE_SOUND(SOUND_CLIPOUT);
	
	PRECACHE_GENERIC(WEAPON_HUD_TXT);
	PRECACHE_GENERIC(WEAPON_HUD_SPR_1);
	PRECACHE_GENERIC(WEAPON_HUD_SPR_2);
}

Weapon_OnSpawn(const iItem)
{
	// Setting world model.
	SET_MODEL(iItem, MODEL_WORLD);
}

Weapon_OnDeploy(const iItem, const iPlayer, const iClip, const iAmmoPrimary)
{
	#pragma unused iClip, iAmmoPrimary
	
	static iszViewModel;
	if (iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, MODEL_VIEW)))
	{
		set_pev_string(iPlayer, pev_viewmodel2, iszViewModel);
	}
	
	static iszPlayerModel;
	if (iszPlayerModel || (iszPlayerModel = engfunc(EngFunc_AllocString, MODEL_PLAYER)))
	{
		set_pev_string(iPlayer, pev_weaponmodel2, iszPlayerModel);
	}
	
	set_pdata_string(iPlayer, m_szAnimExtention * 4, ANIM_EXTENSION, -1, extra_offset_player * 4);
	
	set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_TIME_DELAY_DEPLOY, extra_offset_weapon);
	set_pdata_float(iPlayer, m_flNextAttack, WEAPON_TIME_DELAY_DEPLOY, extra_offset_player);

	Weapon_SendAnim(iPlayer, ANIM_DRAW);
}

Weapon_OnHolster(const iItem, const iPlayer, const iClip, const iAmmoPrimary)
{
	#pragma unused iPlayer, iClip, iAmmoPrimary
	
	// Cancel any reload in progress.
	set_pdata_int(iItem, m_fInReload, 0, extra_offset_weapon);
}

Weapon_OnIdle(const iItem, const iPlayer, const iClip, const iAmmoPrimary)
{
	#pragma unused iClip, iAmmoPrimary
	
	ExecuteHamB(Ham_Weapon_ResetEmptySound, iItem);

	if (get_pdata_int(iItem, m_flTimeWeaponIdle, extra_offset_weapon) > 0.0)
	{
		return;
	}
	
	set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_TIME_NEXT_IDLE, extra_offset_weapon);
	Weapon_SendAnim(iPlayer, ANIM_IDLE);
}

Weapon_OnReload(const iItem, const iPlayer, const iClip, const iAmmoPrimary)
{
	if (min(WEAPON_MAX_CLIP - iClip, iAmmoPrimary) <= 0)
	{
		return;
	}

	if (get_pdata_int(iPlayer, m_iFOV, extra_offset_player) != 90)
	{
		Weapon_OnSecondaryAttack(iItem, iPlayer, iClip, iAmmoPrimary);
	}
	
	set_pdata_int(iItem, m_iClip, 0, extra_offset_weapon);
	
	ExecuteHam(Ham_Weapon_Reload, iItem);
	
	set_pdata_int(iItem, m_iClip, iClip, extra_offset_weapon);
	
	set_pdata_float(iPlayer, m_flNextAttack, WEAPON_TIME_DELAY_RELOAD, extra_offset_player);
	set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_TIME_DELAY_RELOAD, extra_offset_weapon);
	
	Weapon_SendAnim(iPlayer, ANIM_RELOAD);
}

Weapon_OnPrimaryAttack(const iItem, const iPlayer, const iClip, const iAmmoPrimary)
{
	#pragma unused iAmmoPrimary

	CallOrigFireBullets3(iItem, iPlayer);
	
	if (iClip <= 0)
	{
		return;
	}
	
	static iFlags, iAnimDesired; 
	static iWeaponState, iShellModelIndex; 
	
	static szAnimation[64], Float: vecVelocity[3];
	
	#define WEAPONSTATE_ELITE_LEFT (1 << 3)
	
	if (!iShellModelIndex)
	{
		iShellModelIndex = PRECACHE_MODEL(MODEL_SHELL);
	}
	
	iFlags = pev(iPlayer, pev_flags);
	iWeaponState = get_pdata_int(iItem, m_fWeaponState, extra_offset_weapon);
	
	if (iWeaponState & WEAPONSTATE_ELITE_LEFT)
	{	
		iWeaponState &= ~ WEAPONSTATE_ELITE_LEFT;
		
		Weapon_SendAnim(iPlayer, ANIM_SHOOT_LEFT);
		EjectBrass(iPlayer, iShellModelIndex, 1, .flForwardScale = 12.0, .flRightScale = -16.0);
		
		formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", ANIM_EXTENSION);
	}
	else
	{
		iWeaponState |= WEAPONSTATE_ELITE_LEFT;
		
		Weapon_SendAnim(iPlayer, ANIM_SHOOT_RIGHT);
		EjectBrass(iPlayer, iShellModelIndex, 1, .flForwardScale = 8.0);
		
		formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot2_%s" : "ref_shoot2_%s", ANIM_EXTENSION);
	}
	
	if ((iAnimDesired = lookup_sequence(iPlayer, szAnimation)) == -1)
	{
		iAnimDesired = 0;
	}
	
	pev(iPlayer, pev_velocity, vecVelocity);
	set_pev(iPlayer, pev_sequence, iAnimDesired);
	
	set_pdata_int(iItem, m_fWeaponState, iWeaponState, extra_offset_weapon);
	
	set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_TIME_NEXT_IDLE, extra_offset_weapon);
	set_pdata_float(iItem, m_flNextPrimaryAttack, WEAPON_TIME_NEXT_ATTACK, extra_offset_weapon);
	set_pdata_float(iItem, m_flNextSecondaryAttack, WEAPON_TIME_NEXT_ATTACK, extra_offset_weapon);
	
	emit_sound(iPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
	
	if (xs_vec_len(vecVelocity) > 0)
	{
		Weapon_KickBack(iItem, iPlayer, 1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7);
	}
	else if (!(iFlags & FL_ONGROUND))
	{
		Weapon_KickBack(iItem, iPlayer, 2.0, 1.0, 0.5, 0.35, 9.0, 6.0, 5);
	}
	else if (iFlags & FL_DUCKING)
	{
		Weapon_KickBack(iItem, iPlayer, 0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9);
	}
	else
	{
		Weapon_KickBack(iItem, iPlayer, 1.0, 0.375, 0.175, 0.0375, 5.75, 1.75, 8);
	}
}

Weapon_OnSecondaryAttack(const iItem, const iPlayer, const iClip, const iAmmoPrimary)
{
	#pragma unused iClip, iAmmoPrimary

	set_pdata_float(iItem, m_flNextSecondaryAttack, 0.3, extra_offset_weapon);
	set_pdata_int(iPlayer, m_iFOV, get_pdata_int(iPlayer, m_iFOV, extra_offset_player) == 90 ? 55 : 90, extra_offset_player);
}

//*********************************************************************
//*           Don't modify the code below this line unless            *
//*          	 you know _exactly_ what you are doing!!!             *
//*********************************************************************

// new g_iItemID;
new g_iszWeaponKey;
new g_msgWeaponList;

new g_iForwardDecalIndex;
new g_iForwardRegUserMsg;

#define IsCustomItem(%0) (pev(%0, pev_impulse) == g_iszWeaponKey)

public plugin_precache()
{
	Weapon_OnPrecache();
	
	g_iszWeaponKey = engfunc(EngFunc_AllocString, WEAPON_NAME);
	g_iForwardDecalIndex = register_forward(FM_DecalIndex, "FakeMeta_DecalIndex_Post", true);
	
	if ((g_msgWeaponList = get_user_msgid("WeaponList")))
	{
		register_message(g_msgWeaponList, "MsgHook_WeaponList");
	}
	else
	{
		g_iForwardRegUserMsg = register_forward(FM_RegUserMsg, "FakeMeta_RegUserMsg_Post", true);
	}
	
	state TraceAttack_Disabled;
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// g_iItemID = zp_register_extra_item(ZP_ITEM_NAME, ZP_ITEM_COST, ZP_TEAM_HUMAN);
	
	unregister_forward(FM_DecalIndex, g_iForwardDecalIndex, true);
	unregister_forward(FM_RegUserMsg, g_iForwardRegUserMsg, true);
	
	// Weaponbox
	RegisterHam(Ham_Spawn, 		"weaponbox", 		"HamHook_Weaponbox_Spawn_Post", true);
	
	// Hook and change damage to entities
	RegisterHam(Ham_TraceAttack,	"func_breakable",	"HamHook_Entity_TraceAttack", false);
	RegisterHam(Ham_TraceAttack,	"hostage_entity",	"HamHook_Entity_TraceAttack", false);
	RegisterHam(Ham_TraceAttack,	"info_target", 		"HamHook_Entity_TraceAttack", false);
	RegisterHam(Ham_TraceAttack,	"player", 		"HamHook_Entity_TraceAttack", false);
	
	// Item (weapon) hooks
	RegisterHam(Ham_Item_Deploy,		WEAPON_REFERANCE, "HamHook_Item_Deploy_Post",	true);
	RegisterHam(Ham_Item_Holster,		WEAPON_REFERANCE, "HamHook_Item_Holster",	false);
	RegisterHam(Ham_Item_AddToPlayer,	WEAPON_REFERANCE, "HamHook_Item_AddToPlayer",	false);
	RegisterHam(Ham_Item_PostFrame,		WEAPON_REFERANCE, "HamHook_Item_PostFrame",	false);
	RegisterHam(Ham_CS_Item_GetMaxSpeed,	WEAPON_REFERANCE, "HamHook_Item_GetMaxSpeed",	false);
	
	RegisterHam(Ham_Weapon_Reload,		WEAPON_REFERANCE, "HamHook_Item_Reload",		false);
	RegisterHam(Ham_Weapon_WeaponIdle,	WEAPON_REFERANCE, "HamHook_Item_WeaponIdle",	false);
	RegisterHam(Ham_Weapon_PrimaryAttack,	WEAPON_REFERANCE, "HamHook_Item_PrimaryAttack",	false);
	
	// Block client weapon here
	register_forward(FM_UpdateClientData,	"FakeMeta_UpdateClientData_Post", true);
}

public plugin_natives()
	register_native("zp_weapon_skull4", "native_get_skull4", 1);

public native_get_skull4(const id)
{
	if(zp_get_user_zombie(id) || zp_get_user_specialmode(id))
		return;

	Weapon_Give(id);
}

// public zp_extra_item_selected(id, itemid)
// {
	// if (itemid == g_iItemID)
		// Weapon_Give(id);
// }

//**********************************************
//* Block client weapon.                       *
//**********************************************

public FakeMeta_UpdateClientData_Post(const iPlayer, const iSendWeapons, const CD_Handle)
{
	static iActiveItem;
	
	if (!IsValidPev(iPlayer))
	{
		return FMRES_IGNORED;
	}
	
	iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, extra_offset_player);
	
	if (!IsValidPev(iActiveItem) || !IsCustomItem(iActiveItem))
	{
		return FMRES_IGNORED;
	}
	
	set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001);
	return FMRES_IGNORED;
}

//**********************************************
//* Item (weapon) hooks.                       *
//**********************************************

	#define _call.%0(%1,%2) \
								\
	Weapon_On%0						\
	(							\
		%1, 						\
		%2,						\
								\
		get_pdata_int(%1, m_iClip, extra_offset_weapon),	\
								\
		GetAmmoInventory(%2, PrimaryAmmoIndex(%1))	\
	) 

	
public HamHook_Item_GetMaxSpeed(const iItem)
{
	if (!IsValidPev(iItem) || !IsCustomItem(iItem))
	{
		return HAM_IGNORED;
	}
	
	SetHamReturnFloat(WEAPON_MAX_SPEED);
	return HAM_SUPERCEDE;
}

public HamHook_Item_Deploy_Post(const iItem)
{
	new iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	_call.Deploy(iItem, iPlayer);
	return HAM_IGNORED;
}

public HamHook_Item_Holster(const iItem)
{
	new iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	set_pev(iPlayer, pev_viewmodel, 0);
	set_pev(iPlayer, pev_weaponmodel, 0);
	
	_call.Holster(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_WeaponIdle(const iItem)
{
	static iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}

	_call.Idle(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_Reload(const iItem)
{
	static iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	_call.Reload(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_PrimaryAttack(const iItem)
{
	static iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	_call.PrimaryAttack(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_PostFrame(const iItem)
{
	static iButton, iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	// Complete reload
	if (get_pdata_int(iItem, m_fInReload, extra_offset_weapon))
	{
		new iClip		= get_pdata_int(iItem, m_iClip, extra_offset_weapon); 
		new iPrimaryAmmoIndex	= PrimaryAmmoIndex(iItem);
		new iAmmoPrimary		= GetAmmoInventory(iPlayer, iPrimaryAmmoIndex);
		new iAmount		= min(WEAPON_MAX_CLIP - iClip, iAmmoPrimary);
		
		set_pdata_int(iItem, m_iClip, iClip + iAmount, extra_offset_weapon);
		set_pdata_int(iItem, m_fInReload, false, extra_offset_weapon);

		SetAmmoInventory(iPlayer, iPrimaryAmmoIndex, iAmmoPrimary - iAmount);
	}
	
	// Call secondary attack
	if ((iButton = pev(iPlayer, pev_button)) & IN_ATTACK2 
		&& get_pdata_float(iItem, m_flNextSecondaryAttack, extra_offset_weapon) < 0.0)
	{
		_call.SecondaryAttack(iItem, iPlayer);
		set_pev(iPlayer, pev_button, iButton & ~IN_ATTACK2);
	}
	
	return HAM_IGNORED;
}

//**********************************************
//* Fire Bullets.                              *
//**********************************************

CallOrigFireBullets3(const iItem, const iPlayer)
{
	static msgDeathMsg;
	
	static iForwardDeathMsg;
	static iForwardTraceLine;
	static iForwardPlaybackEvent;
	
	static Float: vecPuncheAngle[3];
	
	if (!msgDeathMsg)
	{
		msgDeathMsg = get_user_msgid("DeathMsg");
	}
	
	state TraceAttack_Enabled;
	
	iForwardDeathMsg = register_message(msgDeathMsg, "MsgHook_Death");
	iForwardTraceLine = register_forward(FM_TraceLine, "FakeMeta_TraceLine_Post", true);
	iForwardPlaybackEvent = register_forward(FM_PlaybackEvent, "FakeMeta_PlaybackEvent", false);

	pev(iPlayer, pev_punchangle, vecPuncheAngle);
	
	ExecuteHam(Ham_Weapon_PrimaryAttack, iItem);
	
	set_pev(iPlayer, pev_punchangle, vecPuncheAngle);
	
	unregister_message(msgDeathMsg, iForwardDeathMsg);
	unregister_forward(FM_TraceLine, iForwardTraceLine, true);
	unregister_forward(FM_PlaybackEvent, iForwardPlaybackEvent, false);
	
	state TraceAttack_Disabled;
}

public FakeMeta_TraceLine_Post(const Float: vecTraceStart[3], const Float: vecTraceEnd[3], const fNoMonsters, const iEntToSkip, const iTrace)
{
	static Float: vecEndPos[3];
	
	get_tr2(iTrace, TR_vecEndPos, vecEndPos);
	engfunc(EngFunc_TraceLine, vecEndPos, vecTraceStart, fNoMonsters, iEntToSkip, 0);
	
	UTIL_GunshotDecalTrace(0);
	UTIL_GunshotDecalTrace(iTrace, true);
}

public MsgHook_Death()
{
	static szTruncatedWeaponName[32];
	
	if (szTruncatedWeaponName[0] == EOS)
	{
		copy(szTruncatedWeaponName, charsmax(szTruncatedWeaponName), WEAPON_NAME);
		replace(szTruncatedWeaponName, charsmax(szTruncatedWeaponName), "weapon_", "");
	}
	
	set_msg_arg_string(4, szTruncatedWeaponName);
}

public HamHook_Entity_TraceAttack(const iEntity, const iAttacker, const Float: flDamage) <TraceAttack_Enabled>
{
	SetHamParamFloat(3, flDamage * WEAPON_MULTIPLIER_DAMAGE);
}

public HamHook_Entity_TraceAttack(const iEntity, const iAttacker, const Float: flDamage) <TraceAttack_Disabled>
{ 
	/* Do notning */
}

public FakeMeta_PlaybackEvent()
{
	return FMRES_SUPERCEDE;
}

//**********************************************
//* Brass ejection.                            *
//**********************************************

EjectBrass(const iPlayer, const iModelIndex, const iBounce, const Float:flUpScale = -9.0, const Float: flForwardScale = 16.0, const Float: flRightScale = 0.0)
{
	static i, msgBrass;
	
	static Float: vecUp[3]; 
	static Float: vecRight[3]; 
	static Float: vecForward[3]; 
	
	static Float: vecAngle[3];
	static Float: vecOrigin[3];
	static Float: vecViewOfs[3];
	static Float: vecVelocity[3];
	
	pev(iPlayer, pev_v_angle, vecAngle);
	pev(iPlayer, pev_punchangle, vecOrigin);
	
	xs_vec_add(vecAngle, vecOrigin, vecOrigin);
	engfunc(EngFunc_MakeVectors, vecOrigin);
	
	pev(iPlayer, pev_origin, vecOrigin);
	pev(iPlayer, pev_view_ofs, vecViewOfs);
	pev(iPlayer, pev_velocity, vecVelocity);
	
	global_get(glb_v_up, vecUp);
	global_get(glb_v_right, vecRight);
	global_get(glb_v_forward, vecForward);
	
	for (i = 0; i < 3; i++)
	{
		vecOrigin[i] = vecOrigin[i] + vecViewOfs[i] + vecForward[i] * flForwardScale + vecUp[i] * flUpScale + vecRight[i] * flRightScale;
		vecVelocity[i] = vecVelocity[i] + vecForward[i] * 25.0 + vecUp[i] * random_float(100.0, 150.0) + vecRight[i] * random_float(50.0, 70.0);
	}
	
	if (msgBrass || (msgBrass = get_user_msgid("Brass")))
	{
		MESSAGE_BEGIN(MSG_PVS, msgBrass, vecOrigin, 0);
		WRITE_BYTE(0 /* dummy */);
		WRITE_COORD(vecOrigin[0]);
		WRITE_COORD(vecOrigin[1]);
		WRITE_COORD(vecOrigin[2]);
		WRITE_COORD(0.0 /* dummy */);
		WRITE_COORD(0.0 /* dummy */);
		WRITE_COORD(0.0 /* dummy */);
		WRITE_COORD(vecVelocity[0]);
		WRITE_COORD(vecVelocity[1]);
		WRITE_COORD(vecVelocity[2]);
		WRITE_ANGLE(vecAngle[1]);
		WRITE_SHORT(iModelIndex);
		WRITE_BYTE(iBounce);
		WRITE_BYTE(0 /* dummy */);
		WRITE_BYTE(iPlayer);
		MESSAGE_END();
	}
}

//**********************************************
//* Kick back.                                 *
//**********************************************

Weapon_KickBack(const iItem, const iPlayer, Float: upBase, Float: lateralBase, const Float: upMod, const Float: lateralMod, Float: upMax, Float: lateralMax, const directionChange)
{
	static iDirection; 
	static iShotsFired; 
	
	static Float: vecPunchangle[3];
	pev(iPlayer, pev_punchangle, vecPunchangle);
	
	if ((iShotsFired = get_pdata_int(iItem, m_iShotsFired, extra_offset_weapon)) != 1)
	{
		upBase += iShotsFired * upMod;
		lateralBase += iShotsFired * lateralMod;
	}
	
	upMax *= -1.0;
	vecPunchangle[0] -= upBase;
 
	if (upMax >= vecPunchangle[0])
	{
		vecPunchangle[0] = upMax;
	}
	
	if ((iDirection =  get_pdata_int(iItem, m_iDirection, extra_offset_weapon)))
	{
		vecPunchangle[1] += lateralBase;
		
		if (lateralMax < vecPunchangle[1])
		{
			vecPunchangle[1] = lateralMax;
		}
	}
	else
	{
		lateralMax *=  -1.0;
		vecPunchangle[1] -= lateralBase;
		
		if (lateralMax > vecPunchangle[1])
		{
			vecPunchangle[1] = lateralMax;
		}
	}
	
	if (!random_num(0, directionChange))
	{
		set_pdata_int(iItem, m_iDirection, !iDirection, extra_offset_weapon);
	}
	
	set_pev(iPlayer, pev_punchangle, vecPunchangle);
}

//**********************************************
//* Create and check our custom weapon.        *
//**********************************************

Weapon_Create(const Float: vecOrigin[3] = {0.0, 0.0, 0.0}, const Float: vecAngles[3] = {0.0, 0.0, 0.0})
{
	new iWeapon;

	static iszAllocStringCached;
	if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, WEAPON_REFERANCE)))
	{
		iWeapon = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
	}
	
	if (!IsValidPev(iWeapon))
	{
		return FM_NULLENT;
	}
	
	MDLL_Spawn(iWeapon);
	SET_ORIGIN(iWeapon, vecOrigin);
	
	set_pdata_int(iWeapon, m_iClip, WEAPON_MAX_CLIP, extra_offset_weapon);

	set_pev_string(iWeapon, pev_classname, g_iszWeaponKey );
	set_pev(iWeapon, pev_impulse, g_iszWeaponKey);
	set_pev(iWeapon, pev_angles, vecAngles);
	
	Weapon_OnSpawn(iWeapon);
	
	return iWeapon;
}

public Weapon_Give(const iPlayer)
{
	if (!IsValidPev(iPlayer))
	{
		return FM_NULLENT;
	}
	
	new iWeapon, Float: vecOrigin[3];
	pev(iPlayer, pev_origin, vecOrigin);
	
	if ((iWeapon = Weapon_Create(vecOrigin)) != FM_NULLENT)
	{
		Player_DropWeapons(iPlayer, ExecuteHamB(Ham_Item_ItemSlot, iWeapon));
		
		set_pev(iWeapon, pev_spawnflags, pev(iWeapon, pev_spawnflags) | SF_NORESPAWN);
		MDLL_Touch(iWeapon, iPlayer);
		
		SetAmmoInventory(iPlayer, PrimaryAmmoIndex(iWeapon), WEAPON_DEFAULT_AMMO);
		
		return iWeapon;
	}
	
	return FM_NULLENT;
}

Player_DropWeapons(const iPlayer, const iSlot)
{
	new szWeaponName[32], iItem = get_pdata_cbase(iPlayer, m_rgpPlayerItems_CBasePlayer + iSlot, extra_offset_player);

	while (IsValidPev(iItem))
	{
		pev(iItem, pev_classname, szWeaponName, charsmax(szWeaponName));
		engclient_cmd(iPlayer, "drop", szWeaponName);

		iItem = get_pdata_cbase(iItem, m_pNext, extra_offset_weapon);
	}
}

Weapon_SendAnim(const iPlayer, const iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim);

	MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, iPlayer);
	WRITE_BYTE(iAnim);
	WRITE_BYTE(0);
	MESSAGE_END();
}

bool: CheckItem(const iItem, &iPlayer)
{
	if (!IsValidPev(iItem) || !IsCustomItem(iItem))
	{
		return false;
	}
	
	iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon);
	
	if (!IsValidPev(iPlayer))
	{
		return false;
	}
	
	return true;
}

//**********************************************
//* Decals.                                    *
//**********************************************

new Array: g_hDecals;

public FakeMeta_DecalIndex_Post()
{
	if (!g_hDecals)
	{
		g_hDecals = ArrayCreate(1, 1);
	}
	
	ArrayPushCell(g_hDecals, get_orig_retval());
}

UTIL_GunshotDecalTrace(const iTrace, const bool: bIsGunshot = false)
{
	static iHit;
	static iMessage;
	static iDecalIndex;
	
	static Float: flFraction; 
	static Float: vecEndPos[3];
	
	iHit = INSTANCE(get_tr2(iTrace, TR_pHit));
	
	if (iHit  && !IsValidPev(iHit) || (pev(iHit, pev_flags) & FL_KILLME))
	{
		return;
	}
	
	if (pev(iHit, pev_solid) != SOLID_BSP && pev(iHit, pev_movetype) != MOVETYPE_PUSHSTEP)
	{
		return;
	}
	
	iDecalIndex = ExecuteHamB(Ham_DamageDecal, iHit, 0);
	
	if (iDecalIndex < 0 || iDecalIndex >=  ArraySize(g_hDecals))
	{
		return;
	}
	
	iDecalIndex = ArrayGetCell(g_hDecals, iDecalIndex);
	
	get_tr2(iTrace, TR_flFraction, flFraction);
	get_tr2(iTrace, TR_vecEndPos, vecEndPos);
	
	if (iDecalIndex < 0 || flFraction >= 1.0)
	{
		return;
	}
	
	if (bIsGunshot)
	{
		iMessage = TE_GUNSHOTDECAL;
	}
	else
	{
		iMessage = TE_DECAL;
		
		if (iHit != 0)
		{
			if (iDecalIndex > 255)
			{
				iMessage = TE_DECALHIGH;
				iDecalIndex -= 256;
			}
		}
		else
		{
			iMessage = TE_WORLDDECAL;
			
			if (iDecalIndex > 255)
			{
				iMessage = TE_WORLDDECALHIGH;
				iDecalIndex -= 256;
			}
		}
	}
	
	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, {0.0, 0.0, 0.0}, 0);
	WRITE_BYTE(iMessage);
	WRITE_COORD(vecEndPos[0]);
	WRITE_COORD(vecEndPos[1]);
	WRITE_COORD(vecEndPos[2]);
	
	if (bIsGunshot)
	{
		WRITE_SHORT(iHit);
		WRITE_BYTE(iDecalIndex);
	}
	else 
	{
		WRITE_BYTE(iDecalIndex);
		
		if (iHit)
		{
			WRITE_SHORT(iHit);
		}
	}
    
	MESSAGE_END();
}

//**********************************************
//* Weapon list update.                        *
//**********************************************

public FakeMeta_RegUserMsg_Post(const szMsg[])
{
	if (!strcmp(szMsg, "WeaponList"))
	{
		register_message((g_msgWeaponList = get_orig_retval()), "MsgHook_WeaponList");
	}
}

public HamHook_Item_AddToPlayer(const iItem, const iPlayer)
{
	if (!IsValidPev(iItem) || !IsValidPev(iPlayer))
	{
		return HAM_IGNORED;
	}

	MsgHook_WeaponList(g_msgWeaponList, iItem, iPlayer);
	
	return HAM_IGNORED;
}

public MsgHook_WeaponList(const iMsgID, const iMsgDest, const iMsgEntity)
{
	static arrWeaponListData[8];
	
	if (iMsgEntity)
	{
		MESSAGE_BEGIN(MSG_ONE, iMsgID, {0.0, 0.0, 0.0}, iMsgEntity);
		WRITE_STRING(IsCustomItem(iMsgDest) ? WEAPON_NAME : WEAPON_REFERANCE);
		
		for (new i, a = sizeof arrWeaponListData; i < a; i++)
		{
			WRITE_BYTE(arrWeaponListData[i]);
		}
		
		MESSAGE_END();
	}
	else
	{
		new szWeaponName[32];
		get_msg_arg_string(1, szWeaponName, charsmax(szWeaponName));
		
		if (!strcmp(szWeaponName, WEAPON_REFERANCE))
		{
			for (new i, a = sizeof arrWeaponListData; i < a; i++)
			{
				arrWeaponListData[i] = get_msg_arg_int(i + 2);
			}
		}
	}
}

//**********************************************
//* Weaponbox world model.                     *
//**********************************************

new g_iForwardSetModel;

public HamHook_Weaponbox_Spawn_Post(const iWeaponBox)
{
	if (!IsValidPev(iWeaponBox))
	{
		return HAM_IGNORED;
	}
	
	new iPlayer = pev(iWeaponBox, pev_owner);
	
	if (!IsValidPev(iPlayer))
	{
		return HAM_IGNORED;
	}
	
	g_iForwardSetModel = register_forward(FM_SetModel, "FakeMeta_SetModel");
	
	return HAM_IGNORED;
}

public FakeMeta_SetModel(const iWeaponBox)
{
	unregister_forward(FM_SetModel, g_iForwardSetModel);
	
	if (!IsValidPev(iWeaponBox))
	{
		return FMRES_IGNORED;
	}
	
	#define MAX_ITEM_TYPES	6
	
	for (new i, iItem; i < MAX_ITEM_TYPES; i++)
	{
		iItem = get_pdata_cbase(iWeaponBox, m_rgpPlayerItems_CWeaponBox + i, extra_offset_weapon);
		
		if (IsValidPev(iItem) && IsCustomItem(iItem))
		{
			SET_MODEL(iWeaponBox, MODEL_WORLD);
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

//**********************************************
//* Ammo Inventory.                            *
//**********************************************

PrimaryAmmoIndex(const iItem)
{
	return get_pdata_int(iItem, m_iPrimaryAmmoType, extra_offset_weapon);
}

GetAmmoInventory(const iPlayer, const iAmmoIndex)
{
	if (iAmmoIndex == -1)
	{
		return -1;
	}

	return get_pdata_int(iPlayer, m_rgAmmo_CBasePlayer + iAmmoIndex, extra_offset_player);
}

SetAmmoInventory(const iPlayer, const iAmmoIndex, const iAmount)
{
	if (iAmmoIndex == -1)
	{
		return 0;
	}

	set_pdata_int(iPlayer, m_rgAmmo_CBasePlayer + iAmmoIndex, iAmount, extra_offset_player);
	return 1;
}