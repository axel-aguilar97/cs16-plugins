#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <xs>

native zp_get_user_zombie(const id);
native zp_get_user_specialmode(const id);
forward zp_user_infected_post(const id, const attacker, const silent_mode, const bomb, const first_zombie, const nemesis);
forward zp_user_humanized_post(const id, const silent_mode, const survivor);

const PDATA_SAFE = 2;
const OFFSET_LINUX_WEAPONS = 4;
const OFFSET_LINUX = 5;
const OFFSET_WEAPONOWNER = 41;
const OFFSET_KNOWN = 44;
const OFFSET_NEXT_PRIMARY_ATTACK = 46;
const OFFSET_NEXT_SECONDARY_ATTACK = 47;
const OFFSET_TIME_WEAPON_IDLE = 48;
const OFFSET_CLIPAMMO = 51;
const OFFSET_IN_RELOAD = 54;
const OFFSET_NEXT_ATTACK = 83;

#define isUserValid(%1) (1 <= %1 <= MaxClients)
#define isUserValidAlive(%1) (isUserValid(%1) && is_user_alive(%1))
#define isUserValidConnected(%1) (isUserValid(%1) && is_user_connected(%1))

#define b1_SHOOT1			2
#define b1_SHOOT2		  	3
#define b1_SHOOT_EMPTY		3
#define b1_RELOAD			4
#define b1_DRAW				5

new const Fire_Sounds[][] = {"weapons/balrog1-1.wav", "weapons/balrog1-2.wav"}

new b1_V_MODEL[64] = "models/v_balrog1.mdl"
new b1_P_MODEL[64] = "models/p_balrog1.mdl"

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new cvar_dmg_b1, cvar_recoil_b1, cvar_clip_b1, cvar_spd_b1, cvar_b1_ammo, cvar_dmg_exp
new g_orig_event_b1, g_IsInPrimaryAttack, g_iClip
new m_iBlood[2]
new g_has_b1[MAX_PLAYERS + 1], g_clip_ammo[MAX_PLAYERS + 1], oldweap[MAX_PLAYERS + 1], g_b1_TmpClip[MAX_PLAYERS + 1]
new gMode[MAX_PLAYERS + 1], sExplo
new g_CurrentWeapon[MAX_PLAYERS + 1];

new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_deagle", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
"weapon_ak47", "weapon_knife", "weapon_p90" }

public plugin_init()
{
	register_plugin("[ZP] Extra: Balrog-I", "1.0", "Barney")

	for(new i = 1; i < sizeof WEAPONENTNAMES; i++)
	{
		if(WEAPONENTNAMES[i][0])
			RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	}
	RegisterHam(Ham_Item_PostFrame, "weapon_deagle", "b1_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, "weapon_deagle", "b1_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_deagle", "b1_Reload_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_b1_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_b1_PrimaryAttack_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Spawn, "player", "ham__PlayerSpawnPost", 1);

	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)

	cvar_dmg_b1 = register_cvar("ze_balrog1_damage", "1.25")
	cvar_dmg_exp = register_cvar("ze_balrog1_damage_explode", "125.0")
	cvar_recoil_b1 = register_cvar("ze_balrog1_recoil", "1.0")
	cvar_clip_b1 = register_cvar("ze_balrog1_maxclip", "10")
	cvar_spd_b1 = register_cvar("ze_balrog1_speed", "0.7")
	cvar_b1_ammo = register_cvar("ze_balrog1_bpammo", "100")
}

public plugin_precache()
{
	precache_model(b1_V_MODEL)
	precache_model(b1_P_MODEL)

	for(new i = 0; i < sizeof Fire_Sounds; i++)
		precache_sound(Fire_Sounds[i])

	precache_sound("weapons/balrog1_changea.wav")
	precache_sound("weapons/balrog1_changeb.wav")
	precache_sound("weapons/balrog1_draw.wav")
	precache_sound("weapons/balrog1_reload.wav")
	precache_sound("weapons/balrog1_reloadb.wav")

	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	sExplo = precache_model("sprites/balrogcritical.spr")

	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
}

public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if(!isUserValidAlive(iAttacker) || g_CurrentWeapon[iAttacker] != CSW_DEAGLE || !g_has_b1[iAttacker])
		return

	static Float:flEnd[3];
	get_tr2(ptr, TR_vecEndPos, flEnd);
	
	if(iEnt)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_DECAL);
		engfunc(EngFunc_WriteCoord, flEnd[0]);
		engfunc(EngFunc_WriteCoord, flEnd[1]);
		engfunc(EngFunc_WriteCoord, flEnd[2]);
		write_byte(GUNSHOT_DECALS[random_num(0, sizeof GUNSHOT_DECALS -1)]);
		write_short(iEnt);
		message_end();
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, flEnd[0])
		engfunc(EngFunc_WriteCoord, flEnd[1])
		engfunc(EngFunc_WriteCoord, flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		message_end()
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord, flEnd[0])
	engfunc(EngFunc_WriteCoord, flEnd[1])
	engfunc(EngFunc_WriteCoord, flEnd[2])
	write_short(iAttacker)
	write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
	message_end()
}

public zp_user_infected_post(const id, const attacker, const silent_mode, const bomb, const first_zombie, const nemesis)
	g_has_b1[id] = false;

public zp_user_humanized_post(const id, const silent_mode, const survivor)
	g_has_b1[id] = false;

public fwPrecacheEvent_Post(type, const name[])
{
	if(equal("events/deagle.sc", name))
	{
		g_orig_event_b1 = get_orig_retval()
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}

public client_putinserver(id)
{
	g_has_b1[id] = false
	gMode[id] = 0;
	g_CurrentWeapon[id] = CSW_KNIFE;
}

public ham__PlayerSpawnPost(id)
{
	if(!is_user_alive(id) || !get_user_team(id))
		return;

	g_has_b1[id] = false;
}

public give_b1(id)
{
	new iWep2 = give_item(id, "weapon_deagle");

	if(iWep2 > 0)
	{
		cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_b1));
		cs_set_user_bpammo(id, CSW_DEAGLE, get_pcvar_num(cvar_b1_ammo));

		setAnimation(id, b1_DRAW);
		set_pdata_float(id, OFFSET_NEXT_ATTACK, 1.0, OFFSET_LINUX);
	}

	g_has_b1[id] = true;
}

public plugin_natives()
	register_native("zp_weapon_balrog1", "native_get_balrog1", 1);

public native_get_balrog1(const id)
{
	if(zp_get_user_zombie(id) || zp_get_user_specialmode(id))
		return;

	give_b1(id);
}

public fw_Item_Deploy_Post(const weapon_ent)
{
	static iId;
	iId = getWeaponOwnerId(weapon_ent);

	if(!pev_valid(iId))
		return;

	static iWeaponId;
	iWeaponId = cs_get_weapon_id(weapon_ent);

	g_CurrentWeapon[iId] = iWeaponId;
	replace_weapon_models(iId, iWeaponId);
}

replace_weapon_models(id, weaponid)
{
	switch(weaponid)
	{
		case CSW_DEAGLE:
		{
			if(zp_get_user_zombie(id) || zp_get_user_specialmode(id))
				return;
			
			if(g_has_b1[id])
			{
				entity_set_string(id, EV_SZ_viewmodel, b1_V_MODEL);
				entity_set_string(id, EV_SZ_weaponmodel, b1_P_MODEL);

				if(oldweap[id] != CSW_DEAGLE) 
				{
					setAnimation(id, b1_DRAW);
					set_pdata_float(id, OFFSET_NEXT_ATTACK, 1.0, OFFSET_LINUX);
					gMode[id] = 0;
				}
			}
		}
	}

	oldweap[id] = weaponid;
}

public fw_UpdateClientData_Post(const id, SendWeapons, CD_Handle)
{
	if(!is_user_alive(id) || g_CurrentWeapon[id] != CSW_DEAGLE || !g_has_b1[id])
		return FMRES_IGNORED;

	set_cd(CD_Handle, CD_flNextAttack, (halflife_time() + 0.01));
	return FMRES_HANDLED;
}

public fw_b1_PrimaryAttack(const weapon_entity)
{
	static iId;
	iId = getWeaponOwnerId(weapon_entity);

	if(!isUserValidAlive(iId) || !g_has_b1[iId])
		return;

	g_iClip = g_clip_ammo[iId] = cs_get_weapon_ammo(weapon_entity);
	g_IsInPrimaryAttack = 1;
}

public explode(const id)
{
	if(is_user_alive(id))
	{
		static Float:originF[3];
		fm_get_aim_origin(id, originF);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, originF[0]);
		engfunc(EngFunc_WriteCoord, originF[1]);
		engfunc(EngFunc_WriteCoord, originF[2]);
		write_short(sExplo);
		write_byte(20);
		write_byte(50);
		write_byte(0);
		message_end();

		static iVictim;
		iVictim = -1;

		while((iVictim = find_ent_in_sphere(iVictim, originF, 240.0)) != 0)
		{
			if(pev(iVictim, pev_takedamage) != DAMAGE_NO)
				ExecuteHamB(Ham_TakeDamage, iVictim, id, id, get_pcvar_float(cvar_dmg_exp), DMG_BULLET);
		}
	}
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if((eventid != g_orig_event_b1) || !g_IsInPrimaryAttack || !isUserValid(invoker))
		return FMRES_IGNORED;

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_SUPERCEDE;
}

public fw_b1_PrimaryAttack_Post(const weapon_entity)
{
	g_IsInPrimaryAttack = 0;

	static iId;
	iId = getWeaponOwnerId(weapon_entity);

	if(!isUserValidAlive(iId) || g_iClip <= cs_get_weapon_ammo(weapon_entity))
		return;

	if(g_has_b1[iId])
	{
		if(!g_clip_ammo[iId])
			return;

		if(get_pcvar_float(cvar_recoil_b1) > 0.0)
		{
			static Float:vecPunchangle[3];
			entity_get_vector(iId, EV_VEC_punchangle, vecPunchangle);

			vecPunchangle[0] = vecPunchangle[0] - ((vecPunchangle[0] * floatclamp(get_pcvar_float(cvar_recoil_b1), 0.0, 100.0)) / 100.0);
			vecPunchangle[1] = vecPunchangle[1] - ((vecPunchangle[1] * floatclamp(get_pcvar_float(cvar_recoil_b1), 0.0, 100.0)) / 100.0);
			vecPunchangle[2] = vecPunchangle[2] - ((vecPunchangle[2] * floatclamp(get_pcvar_float(cvar_recoil_b1), 0.0, 100.0)) / 100.0);

			entity_set_vector(iId, EV_VEC_punchangle, vecPunchangle);
		}

		if(get_pcvar_float(cvar_spd_b1) > 0.0)
		{
			static Float:vecSpeed[3];

			vecSpeed[0] = get_pdata_float(weapon_entity, OFFSET_NEXT_PRIMARY_ATTACK, OFFSET_LINUX_WEAPONS);
			vecSpeed[1] = get_pdata_float(weapon_entity, OFFSET_NEXT_SECONDARY_ATTACK, OFFSET_LINUX_WEAPONS);
			vecSpeed[2] = get_pdata_float(weapon_entity, OFFSET_TIME_WEAPON_IDLE, OFFSET_LINUX_WEAPONS);

			vecSpeed[0] = vecSpeed[0] - (((vecSpeed[0] * floatclamp(get_pcvar_float(cvar_spd_b1), 0.0, 100.0))) / 100.0);
			vecSpeed[1] = vecSpeed[1] - (((vecSpeed[1] * floatclamp(get_pcvar_float(cvar_spd_b1), 0.0, 100.0))) / 100.0);
			vecSpeed[2] = vecSpeed[2] - (((vecSpeed[2] * floatclamp(get_pcvar_float(cvar_spd_b1), 0.0, 100.0))) / 100.0);

			set_pdata_float(weapon_entity, OFFSET_NEXT_PRIMARY_ATTACK, vecSpeed[0], OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_entity, OFFSET_NEXT_SECONDARY_ATTACK, vecSpeed[1], OFFSET_LINUX_WEAPONS);
			set_pdata_float(weapon_entity, OFFSET_TIME_WEAPON_IDLE, vecSpeed[2], OFFSET_LINUX_WEAPONS);
		}

		if(gMode[iId])
		{
			explode(iId);
			set_pdata_float(iId, 83, 2.0);
		}

		emit_sound(iId, CHAN_WEAPON, Fire_Sounds[gMode[iId]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		setAnimation(iId, ((gMode[iId]) ? b1_SHOOT2 : b1_SHOOT1));

		if(gMode[iId])
			gMode[iId] = 0;
	}
}

public fw_TakeDamage(const victim, const inflictor, const attacker, Float:damage)
{
	if(victim != attacker && isUserValidConnected(attacker))
	{
		if(g_CurrentWeapon[attacker] == CSW_DEAGLE)
		{
			if(g_has_b1[attacker])
				SetHamParamFloat(4, (damage * get_pcvar_float(cvar_dmg_b1)));
		}
	}
}

public getWeaponOwnerId(const weapon_ent)
{
	if(pev_valid(weapon_ent) != PDATA_SAFE)
		return -1;

	return get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

public setAnimation(const id, const sequence)
{
	entity_set_int(id, EV_INT_weaponanim, sequence);

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player=id);
	write_byte(sequence);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
}

public b1_ItemPostFrame(const weapon_entity) 
{
	static iId;
	iId = getWeaponOwnerId(weapon_entity);

	if(!isUserValidAlive(iId) || !g_has_b1[iId])
		return HAM_IGNORED;

	static iBpAmmo;
	static iClip;
	static iClipExtra;
	static Float:flNextAttack;
	static iInReload;

	iBpAmmo = cs_get_user_bpammo(iId, CSW_DEAGLE);
	iClip = get_pdata_int(weapon_entity, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
	iClipExtra = get_pcvar_num(cvar_clip_b1);
	flNextAttack = get_pdata_float(iId, OFFSET_NEXT_ATTACK, OFFSET_LINUX);
	iInReload = get_pdata_int(weapon_entity, OFFSET_IN_RELOAD, OFFSET_LINUX_WEAPONS);

	if(pev(iId, pev_button) & IN_ATTACK2 && flNextAttack <= 0.0)
	{
		setAnimation(iId, ((!gMode[iId]) ? 6 : 7));
		gMode[iId] = ((gMode[iId]) ? 0 : 1);
		set_pdata_float(iId, 83, 2.0);
	}

	if(iInReload && flNextAttack <= 0.0)
	{
		static j;
		j = min((iClipExtra - iClip), iBpAmmo);

		set_pdata_int(weapon_entity, OFFSET_CLIPAMMO, (iClip + j), OFFSET_LINUX_WEAPONS);
		cs_set_user_bpammo(iId, CSW_DEAGLE, (iBpAmmo - j));
		set_pdata_int(weapon_entity, OFFSET_IN_RELOAD, 0, OFFSET_LINUX_WEAPONS);

		iInReload = 0;
	}

	return HAM_IGNORED;
}

public b1_Reload(const weapon_entity) 
{
	static iId;
	iId = getWeaponOwnerId(weapon_entity);

	if(!isUserValidAlive(iId) || !g_has_b1[iId])
		return HAM_IGNORED;

	g_b1_TmpClip[iId] = -1;

	static iBpAmmo;
	static iClip;
	static iClipExtra;

	iBpAmmo = cs_get_user_bpammo(iId, CSW_DEAGLE);
	iClip = get_pdata_int(weapon_entity, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
	iClipExtra = get_pcvar_num(cvar_clip_b1);

	if(iBpAmmo <= 0 || iClip >= iClipExtra)
		return HAM_SUPERCEDE;

	g_b1_TmpClip[iId] = iClip;
	return HAM_IGNORED;
}

public b1_Reload_Post(const weapon_entity) 
{
	static iId;
	iId = getWeaponOwnerId(weapon_entity);

	if(!isUserValidAlive(iId) || !g_has_b1[iId] || g_b1_TmpClip[iId] == -1)
		return HAM_IGNORED;

	set_pdata_int(weapon_entity, OFFSET_CLIPAMMO, g_b1_TmpClip[iId], OFFSET_LINUX_WEAPONS);
	set_pdata_float(weapon_entity, OFFSET_TIME_WEAPON_IDLE, 3.0, OFFSET_LINUX_WEAPONS);
	set_pdata_float(iId, OFFSET_NEXT_ATTACK, 3.0, OFFSET_LINUX);
	set_pdata_int(weapon_entity, OFFSET_IN_RELOAD, 1, OFFSET_LINUX_WEAPONS);
	setAnimation(iId, (gMode[iId]) ? 8 : b1_RELOAD);

	gMode[iId] = 0;
	return HAM_IGNORED;
}