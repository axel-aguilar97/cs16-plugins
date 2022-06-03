#if defined _td4_included
	#endinput
#endif
#define _td4_included

stock isSolid(const ent) {
	return (ent ? ((entity_get_int(ent, EV_INT_solid) > SOLID_TRIGGER) ? 1 : 0) : 1);
}

stock bool:isHullVacant(const Float:vecOrigin[3], const hull=HULL_HUMAN) {
	if(!trace_hull(vecOrigin, hull)) {
		return true;
	}

	return false;
}

stock isPlayerStuck(const id) {
	new Float:vecOrigin[3];
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	
	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, HULL_HUMAN, id, 0);
	
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen)) {
		return 1;
	}
	
	return 0;
}

stock entitySetAim(const ent, const Float:vecEntOrigin[3], const Float:vecTargetOrigin[3], const Float:velocity=0.0, const angle_mode=0) {
	new Float:vecSub[3];
	new Float:vecToAngle[3];
	
	xs_vec_sub(vecTargetOrigin, vecEntOrigin, vecSub);
	vector_to_angle(vecSub, vecToAngle);
	
	switch(angle_mode) {
		case 1: {
			vecToAngle[0] = 0.0;
		} case 4: {
			vecToAngle[0] = 0.0;
			vecToAngle[1] += 180.0;
		} case 1337: {
			vecToAngle[0] = -45.0;
		}
	}
	
	entity_set_int(ent, EV_INT_fixangle, 1);
	
	entity_set_vector(ent, EV_VEC_angles, vecToAngle);
	entity_set_vector(ent, EV_VEC_v_angle, vecToAngle);
	
	entity_set_int(ent, EV_INT_fixangle, 1);
	
	if(velocity) {
		xs_vec_normalize(vecSub, vecSub);
		xs_vec_mul_scalar(vecSub, velocity, vecSub);
		
		if(angle_mode) {
			vecSub[2] = 0.02;
		}
		
		entity_set_vector(ent, EV_VEC_velocity, vecSub);
	}
}

stock getDropOrigin(const id, Float:vecOrigin[3]) {
	new Float:vecViewOfs[3];
	new Float:vecVelocity[3];
	
	entity_get_vector(id, EV_VEC_origin, vecOrigin);
	entity_get_vector(id, EV_VEC_view_ofs, vecViewOfs);
	
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin);
	
	velocity_by_aim(id, 50, vecVelocity);
	
	vecOrigin[0] += vecVelocity[0];
	vecOrigin[1] += vecVelocity[1];
}

stock traceCheckCollides(const Float:vecOrigin[3], const Float:bounds) {
	new Float:vecTraceEnds[8][3];
	new Float:vecTraceHit[3];
	new iHitEnt;
	new i;
	new j;
	
	vecTraceEnds[0][0] = (vecOrigin[0] - bounds);
	vecTraceEnds[0][1] = (vecOrigin[1] - bounds);
	vecTraceEnds[0][2] = (vecOrigin[2] - bounds);
	
	vecTraceEnds[1][0] = (vecOrigin[0] - bounds);
	vecTraceEnds[1][1] = (vecOrigin[1] - bounds);
	vecTraceEnds[1][2] = (vecOrigin[2] + bounds);
	
	vecTraceEnds[2][0] = (vecOrigin[0] + bounds);
	vecTraceEnds[2][1] = (vecOrigin[1] - bounds);
	vecTraceEnds[2][2] = (vecOrigin[2] + bounds);
	
	vecTraceEnds[3][0] = (vecOrigin[0] + bounds);
	vecTraceEnds[3][1] = (vecOrigin[1] - bounds);
	vecTraceEnds[3][2] = (vecOrigin[2] - bounds);
	
	vecTraceEnds[4][0] = (vecOrigin[0] - bounds);
	vecTraceEnds[4][1] = (vecOrigin[1] + bounds);
	vecTraceEnds[4][2] = (vecOrigin[2] - bounds);
	
	vecTraceEnds[5][0] = (vecOrigin[0] - bounds);
	vecTraceEnds[5][1] = (vecOrigin[1] + bounds);
	vecTraceEnds[5][2] = (vecOrigin[2] + bounds);
	
	vecTraceEnds[6][0] = (vecOrigin[0] + bounds);
	vecTraceEnds[6][1] = (vecOrigin[1] + bounds);
	vecTraceEnds[6][2] = (vecOrigin[2] + bounds);
	
	vecTraceEnds[7][0] = (vecOrigin[0] + bounds);
	vecTraceEnds[7][1] = (vecOrigin[1] + bounds);
	vecTraceEnds[7][2] = (vecOrigin[2] - bounds);
	
	for(i = 0; i < 8; ++i) {
		if(point_contents(vecTraceEnds[i]) != CONTENTS_EMPTY) {
			return 1;
		}

		iHitEnt = trace_line(0, vecOrigin, vecTraceEnds[i], vecTraceHit);

		if(iHitEnt != 0) {
			return 1;
		}

		for(j = 0; j < 3; ++j) {
			if(vecTraceEnds[i][j] != vecTraceHit[j]) {
				return 1;
			}
		}
	}

	return 0;
}

stock getDestination(const ent, const Float:fforward, const Float:right, const Float:up, Float:vecStart[]) {
	new Float:vecOrigin[3];
	new Float:vecAngles[3];
	new Float:vecForward[3];
	new Float:vecRight[3];
	new Float:vecUp[3];
	
	entity_get_vector(ent, EV_VEC_origin, vecOrigin);
	entity_get_vector(ent, EV_VEC_view_ofs, vecUp);
	
	xs_vec_add(vecOrigin, vecUp, vecOrigin);
	
	entity_get_vector(ent, EV_VEC_v_angle, vecAngles);
	
	vecAngles[0] = 0.0;
	
	angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecForward);
	angle_vector(vecAngles, ANGLEVECTOR_RIGHT, vecRight);
	angle_vector(vecAngles, ANGLEVECTOR_UP, vecUp);
	
	vecStart[0] = (vecOrigin[0] + (vecForward[0] * fforward) + (vecRight[0] * right) + (vecUp[0] * up));
	vecStart[1] = (vecOrigin[1] + (vecForward[1] * fforward) + (vecRight[1] * right) + (vecUp[1] * up));
	vecStart[2] = (vecOrigin[2] + (vecForward[2] * fforward) + (vecRight[2] * right) + (vecUp[2] * up));
}

stock followHuman(const ent, const Float:vecEntOrigin[3], const Float:vecVictimOrigin[3], const Float:distance, const Float:velocity) {
	new Float:vecVelocity[3];
	new Float:fTime = (distance / velocity);
	
	vecVelocity[0] = ((vecVictimOrigin[0] - vecEntOrigin[0]) / fTime);
	vecVelocity[1] = ((vecVictimOrigin[1] - vecEntOrigin[1]) / fTime);
	vecVelocity[2] = 0.0;
	
	entity_set_vector(ent, EV_VEC_velocity, vecVelocity);
}

stock followHumanFireBall(const ent, Float:vecOrigin[3], const Float:vecVictimOrigin[3], const Float:velocity) {
	new Float:vecVelocity[3];
	
	vecOrigin[0] = (vecVictimOrigin[0] - vecOrigin[0]);
	vecOrigin[1] = (vecVictimOrigin[1] - vecOrigin[1]);
	vecOrigin[2] = (vecVictimOrigin[2] - vecOrigin[2]);
	
	engfunc(EngFunc_VecToAngles, vecOrigin, vecVelocity);
	
	vecVelocity[0] *= -1.0;
	vecVelocity[2] = 0.0;
	
	engfunc(EngFunc_MakeVectors, vecVelocity);
	
	global_get(glb_v_forward, vecVelocity);
	
	vecVelocity[0] *= velocity;
	vecVelocity[1] *= velocity;
	vecVelocity[2] *= velocity;
	
	entity_set_vector(ent, EV_VEC_velocity, vecVelocity);
}

stock bool:entitySetFollow(const ent, const target, const Float:speed) {
	if(!is_valid_ent(ent) || !is_valid_ent(target)) {
		return false;
	}

	new Float:vecOriginEnt[3];
	new Float:vecOriginTarget[3];
	new Float:flDiff[3];
	new Float:flLength;
	new Float:vecVelocity[3];

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
	return true;
}

stock bool:validMap(map[]) {
	if(is_map_valid(map)) {
		return true;
	}

	new iLen = (strlen(map) - 4);

	if(iLen < 0) {
		return false;
	}

	if(equali(map[iLen], ".bsp")) {
		map[iLen] = EOS;

		if(is_map_valid(map)) {
			return true;
		}
	}

	return false;
}