#if defined _zp9_included
	#endinput
#endif
#define _zp9_included

// #define WARMUP_ENABLED

const WARMUP_TIME = 45;
const PREPARE_TIME = 9;
const PREPARE_TIME_IN_EVENTMODE = 4;
const ROUND_TIME = 300;

const GAMEMODE_LAUNCH_MINALIVES = 4; // Cantidad de jugadores (vivos) mínimos para que se lance un modo

const MIN_LOTTERY_BET = 25000;

const MAX_TIME_TO_BONUS = 1635476400; // Bonus de apertura hasta el 29 de Octubre
const MAX_CLAN_MEMBERS = 8;
const MAX_AMMOPACKS = 2000000000;
const MAX_LEVELS = 300;
const MAX_RESETS = 50;
const MAX_PRESTIGE = 27;
const MAX_LOTTERY_BET = 100000;

const COST_HAB_RESET_POINTS = 10;

const FFADE_IN = 0x0000; // Just here so we don't pass 0 into the function
const FFADE_OUT = 0x0001; // Fade out (not in)
const FFADE_MODULATE = 0x0002;  // Modulate (don't blend)
const FFADE_STAYOUT = 0x0004; // ignores the duration, stays faded out until new ScreenFade message received

const UNIT_SECOND = (1<<12);

enum {
	PLAYERID_MODE_EVERYONE,
	PLAYERID_MODE_TEAMONLY,
	PLAYERID_MODE_OFF,
};

enum {
	SBAR_TARGETTYPE_TEAMMATE = 1,
	SBAR_TARGETTYPE_ENEMY,
	SBAR_TARGETTYPE_HOSTAGE,
};

enum {
	SBAR_TARGET_TYPE,
	SBAR_TARGET_ID,
	SBAR_TARGET_HEALTH,
	SBAR_TARGET_ARMOR,
	SBAR_TARGET_CLASS,
	SBAR_TARGET_AMMOPACKS,
	SBAR_TARGET_LEVEL,
	SBAR_TARGET_RESET,
	SBAR_TARGET_PRESTIGE,

	SBAR_END,
};

enum IconState {
	ICONSTATE_HIDE,
	ICONSTATE_AVAILABLE,
	ICONSTATE_COOLDOWN,
};

#define fixedUnsigned16(%0,%1) clamp(floatround(%0 * %1), 0, 0xFFFF)

stock utilSetRendering(const id, const fx=kRenderFxNone, const Float:vecColor[3]=NULL_VECTOR, const mode=kRenderNormal, const Float:amount=0.0) {
	set_entvar(id, var_renderfx, fx);
	set_entvar(id, var_rendercolor, vecColor);
	set_entvar(id, var_rendermode, mode);
	set_entvar(id, var_renderamt, amount);
}

stock utilWeaponAnim(const id, const anim, const body=0) {
	set_entvar(id, var_weaponanim, anim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
	write_byte(anim);
	write_byte(body);
	message_end();
}

stock utilScreenFade(const id, const Float:fade_time, const Float:fade_hold=0.0, const fade_flags=0, const color[3]={0, 0, 0}, const alpha=0) {
	static iMessage;

	if(!iMessage) {
		iMessage = get_user_msgid("ScreenFade");
	}

	new iDuration = fixedUnsigned16(fade_time, UNIT_SECOND);
	new iHoldTime = fixedUnsigned16(fade_hold, UNIT_SECOND);

	message_begin(MSG_ONE, iMessage, _, id);
	write_short(iDuration);
	write_short(iHoldTime);
	write_short(fade_flags);
	write_byte(color[0]);
	write_byte(color[1]);
	write_byte(color[2]);
	write_byte(alpha);
	message_end();
}

stock bool:isHullVacant(const id, const Float:vecOrigin[3], const hull) {
	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, hull, id, 0);

	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen)) {
		return false;
	}

	return true;
}

stock arrayToString(const array[], const size, output[], const output_len, const end) {
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

stock stringToArray(const string[], array_out[], const array_size) {
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

stock bool:getUnlimitedClip(const id) {
	return get_member(id, m_iWeaponInfiniteAmmo);
}

stock setUnlimitedClip(const id, const bool:enabled) {
	if(enabled) {
		set_member(id, m_iWeaponInfiniteAmmo, 1);
	} else {
		set_member(id, m_iWeaponInfiniteAmmo, 0);
	}
}

stock getDropOrigin(const id, Float:vecOrigin[3], const velocity) {
	new Float:vecViewOfs[3];
	new Float:vecAim[3];

	get_entvar(id, var_origin, vecOrigin);
	get_entvar(id, var_view_ofs, vecViewOfs);

	vecOrigin[0] = (vecOrigin[0] + vecViewOfs[0]);
	vecOrigin[1] = (vecOrigin[1] + vecViewOfs[1]);
	vecOrigin[2] = (vecOrigin[2] + vecViewOfs[2]);

	velocity_by_aim(id, (50 + velocity), vecAim);

	vecOrigin[0] += vecAim[0];
	vecOrigin[1] += vecAim[1];
}