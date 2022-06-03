#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

#include <dg>

#pragma tabsize 0
// #pragma semicolon 1

new const __PLUGIN_NAME[] = "Grab";
new const __PLUGIN_VERSION[] = "v1.0";
new const __PLUGIN_AUTHOR[] = "Nickron (Edited by Atsel.)";

#define TSK_CHKE 50

new client_data[33][4]

#define GRABBED  0
#define GRABBER  1
#define GRAB_LEN 2
#define FLAGS    3

#define CDF_IN_PUSH   (1<<0)
#define CDF_IN_PULL   (1<<1)
#define CDF_NO_CHOKE  (1<<2)

new const Menu[][] = 
{
	"",
	"Kickear del Server",
	"Matar",
	"Desarmar",
	"Enterrar",
	"Desenterrar",
	"Traerlo"
};

new p_players_only
new p_grab_force
new p_auto_choke
new speed_off[33]
new g_short
new model_gibs
new SVC_SCREENSHAKE, SVC_SCREENFADE, WTF_DAMAGE

public plugin_init() {
	register_plugin(__PLUGIN_NAME, __PLUGIN_VERSION, __PLUGIN_AUTHOR);

	register_event("CurWeapon", "CurrentWeapon", "be", "1=1")
	
	RegisterHam(Ham_Spawn, "player", "SpawnPlayer")
	
	register_forward( FM_PlayerPreThink, "fm_player_prethink" )

	p_players_only = register_cvar( "gp_players_only", "0" )
	p_grab_force = register_cvar( "gp_grab_force", "8" )
	p_auto_choke = register_cvar( "gp_auto_choke", "1" )
	
	register_concmd("amx_grab", "concmd__Grab", ADMIN_IMMUNITY, "<nombre> - Agarras a alguien con el grab de forma forzada");
	
	register_clcmd("+grab", "clcmd__Grab")
	register_clcmd("-grab", "clcmd__UnGrab")
	
	register_clcmd( "+push", "push", ADMIN_IMMUNITY, "bind a key to +push" )
	register_clcmd( "-push", "push" )
	register_clcmd( "+pull", "pull", ADMIN_IMMUNITY, "bind a key to +pull" )
	register_clcmd( "-pull", "pull" )
	register_clcmd( "push", "push2" )
	register_clcmd( "pull", "pull2" )
	
	register_clcmd( "drop" ,"throw" )
	
	register_event( "DeathMsg", "DeathMsg", "a" )
	
	SVC_SCREENFADE = get_user_msgid( "ScreenFade" )
	SVC_SCREENSHAKE = get_user_msgid( "ScreenShake" )
	WTF_DAMAGE = get_user_msgid( "Damage" )
}

public plugin_precache( )
{
	precache_sound("player/PL_PAIN2.WAV")
	g_short = precache_model("sprites/MG_grab/energy_grab.spr");
	model_gibs = precache_model("models/rockgibs.mdl")
}

public fm_player_prethink( id )
{
	new target
	//Search for a target
	if ( client_data[id][GRABBED] == -1 )
	{
		new Float:orig[3], Float:ret[3]
		get_view_pos( id, orig )
		ret = vel_by_aim( id, 9999 )
		
		ret[0] += orig[0]
		ret[1] += orig[1]
		ret[2] += orig[2]
		
		target = traceline( orig, ret, id, ret )
		
		if( 0 < target <= MaxClients )
		{
			if( is_grabbed( target, id ) ) return FMRES_IGNORED
			set_grabbed( id, target )
		}
		else if( !get_pcvar_num( p_players_only ) )
		{
			new movetype
			if( target && pev_valid( target ) )
			{
				movetype = pev( target, pev_movetype )
				if( !( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS ) )
					return FMRES_IGNORED
			}
			else
			{
				target = 0
				new ent = engfunc( EngFunc_FindEntityInSphere, -1, ret, 12.0 )
				while( !target && ent > 0 )
				{
					movetype = pev( ent, pev_movetype )
					if( ( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS )
							&& ent != id  )
						target = ent
					ent = engfunc( EngFunc_FindEntityInSphere, ent, ret, 12.0 )
				}
			}
			if( target )
			{
				if( is_grabbed( target, id ) ) return FMRES_IGNORED
				set_grabbed( id, target )
			}
		}
	}
	
	target = client_data[id][GRABBED]
	//If they've grabbed something
	if( target > 0 )
	{
		if( !pev_valid( target ) || ( pev( target, pev_health ) < 1 && pev( target, pev_max_health ) ) )
		{
			clcmd__UnGrab( id )
			return FMRES_IGNORED
		}
		 
		//Use key choke
		if( pev( id, pev_button ) & IN_USE )
			do_choke( id )
		
		//Push and pull
		new cdf = client_data[id][FLAGS]
		if ( cdf & CDF_IN_PULL )
			do_pull( id )
		else if ( cdf & CDF_IN_PUSH )
			do_push( id )
		
		if( target > MaxClients ) grab_think( id )
	}
	
	//If they're grabbed
	target = client_data[id][GRABBER]
	if( target > 0 ) grab_think( target )
	
	return FMRES_IGNORED
}

public grab_think( id ) //id of the grabber
{
	new target = client_data[id][GRABBED]
	
	//Keep grabbed clients from sticking to ladders
	if( pev( target, pev_movetype ) == MOVETYPE_FLY && !(pev( target, pev_button ) & IN_JUMP ) ) client_cmd( target, "+jump;wait;-jump" )
	
	//Move targeted client
	new Float:tmpvec[3], Float:tmpvec2[3], Float:torig[3], Float:tvel[3]
	
	get_view_pos( id, tmpvec )
	
	tmpvec2 = vel_by_aim( id, client_data[id][GRAB_LEN] )
	
	torig = get_target_origin_f( target )
	
	new force = get_pcvar_num( p_grab_force )
	
	tvel[0] = ( ( tmpvec[0] + tmpvec2[0] ) - torig[0] ) * force
	tvel[1] = ( ( tmpvec[1] + tmpvec2[1] ) - torig[1] ) * force
	tvel[2] = ( ( tmpvec[2] + tmpvec2[2] ) - torig[2] ) * force
	
	set_pev( target, pev_velocity, tvel )
}

stock Float:get_target_origin_f( id )
{
	new Float:orig[3]
	pev( id, pev_origin, orig )
	
	//If grabbed is not a player, move origin to center
	if( id > MaxClients )
	{
		new Float:mins[3], Float:maxs[3]
		pev( id, pev_mins, mins )
		pev( id, pev_maxs, maxs )
		
		if( !mins[2] ) orig[2] += maxs[2] / 2
	}
	
	return orig
}

public clcmd__Grab(const id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY))
		return PLUGIN_HANDLED
	
	if ( !client_data[id][GRABBED] )
		client_data[id][GRABBED] = -1
	
	return PLUGIN_HANDLED
}

public SpawnPlayer(id)
	speed_off[id] = false

public CurrentWeapon(id)
{
	if(speed_off[id])
		set_pev(id, pev_maxspeed, 00000.0)
}

public grab_menu(id) 
{
	new name[32]
	new target = client_data[id][GRABBED]
	if(target && is_user_alive(target))
	{
		get_user_name(target, name, charsmax(name))
	}
	new Item[512], Str[10], menu;

	formatex(Item, charsmax(Item), "GRAB\r:\w %s", name);
	menu = menu_create(Item, "menu_handler")

	for(new i = 1; i <= charsmax(Menu); i++)
	{
		num_to_str(i, Str, charsmax(Str));

		formatex(Item, charsmax(Item), "%s", Menu[i]);
		menu_additem(menu, Item, Str, 0);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Salir");

	ShowLocalMenu(id, menu, 0);
	return PLUGIN_HANDLED;
}
	 
public menu_handler(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		DestroyLocalMenu(id, menu)
		return PLUGIN_HANDLED
	}
	     
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	     
	new key = str_to_num(data)
	new target = client_data[id][GRABBED]
	     
	switch(key) 
	{
		case 1:
		{
			if(target && is_user_alive(target))
			{
				grab_eff_zd(id, target)
				server_cmd("kick #%d ^"Has sido expulsado por el Grab^"", get_user_userid(target))
			}
		}
		case 2:
		{
			if(target && is_user_alive(target))
			{
				user_kill(target)
			}
		}
		case 3:
		{
			if(target && is_user_alive(target))
			{
				strip_user_weapons(target)
				give_item(target, "weapon_knife")				
			}
		}
		case 4:
		{
			if(target && is_user_alive(target))
			{
				Bury(id, target)
			}
		}
		case 5:
		{
			if(target && is_user_alive(target))
			{
				Bury_off(id, target)
			}
		}
		case 6:
		{
			if(target && is_user_alive(target))
			{
				pull(id)
			}
		}
		case 7:
		{
			if(target && is_user_alive(target))
			{
				set_pev(target, pev_punchangle, { 400.0, 999.0, 400.0 })
			}
		}
	}
	return PLUGIN_HANDLED
}

public throw( id )
{
	new target = client_data[id][GRABBED]
	if( target > 0 )
	{
		set_pev( target, pev_velocity, vel_by_aim( id, 1500 ))
		clcmd__UnGrab( id )
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public clcmd__UnGrab( id )
{
	new target = client_data[id][GRABBED]
	if( target > 0 && pev_valid( target ) )
	{
		set_pev( target, pev_renderfx, kRenderFxNone )
		set_pev( target, pev_rendercolor, {255.0, 255.0, 255.0} )
		set_pev( target, pev_rendermode, kRenderNormal )
		set_pev( target, pev_renderamt, 16.0 )
		
		if( 0 < target <= MaxClients )
			client_data[target][GRABBER] = 0
	}
	show_menu(id, 0, "^n", 1)
	client_data[id][GRABBED] = 0
}

//Grabs onto someone
public set_grabbed( id, target )
{
	set_pev( target, pev_renderfx, kRenderFxGlowShell )
	set_pev( target, pev_rendercolor, Float:{255.0, 0.0, 0.0})
	set_pev( target, pev_rendermode, kRenderTransColor )
	set_pev( target, pev_renderamt, 255.0 )
	
	if( 0 < target <= MaxClients )
		client_data[target][GRABBER] = id

	client_data[id][FLAGS] = 0
	client_data[id][GRABBED] = target

	new name[33], name2[33]

	get_user_name(id, name, 32) 
	get_user_name(target, name2, 32)

	if(get_user_team(target) == 1 || get_user_team(target) == 2)
	{
		clientPrint(target, id, "!t%s!y te agarró con el grab", name);
		clientPrint(id, target, "Atrapaste al jugador !t%s!y", name2);

		grab_eff(target)
		grab_menu(id)
	}
	else
	{
		clientPrint(id, _, "Desarmaste al jugador !t%s!y", name2);
	}

	new Float:torig[3], Float:orig[3]
	pev( target, pev_origin, torig )
	pev( id, pev_origin, orig )
	client_data[id][GRAB_LEN] = floatround( get_distance_f( torig, orig ) )
	if( client_data[id][GRAB_LEN] < 90 ) client_data[id][GRAB_LEN] = 90
}

public Bury(id, target)
{
	new name[MAX_NAME_LENGTH];
	get_user_name(id, name, charsmax(name));
	clientPrint(id, _, "Enterraste al jugador !t%s!y", name);

	set_dhudmessage(255, 0, 0, -1.0, 0.20, 0, 0.1, 3.0, 0.1, 2.0)
	show_dhudmessage(id, "HAS ENTERRADO AL JUGADOR^n%s", name)

	grab_eff_zd(id, target)

	if(is_user_alive(target))
	{
		new origin[3]
		get_user_origin(target, origin)
		origin[2] -= 30
		set_user_origin(target, origin)
	}
}

public Bury_off(id, target)
{
	new name[MAX_NAME_LENGTH];
	get_user_name(id, name, charsmax(name));
	clientPrint(id, _, "Desnterraste al jugador !t%s!y", name);

	set_dhudmessage(255, 0, 0, -1.0, 0.20, 0, 0.1, 3.0, 0.1, 2.0)
	show_dhudmessage(target, "HAS SIDO DESENTERRADO")

	if(is_user_alive(target))
	{
		new origin[3]
		get_user_origin(target, origin)
		origin[2] += 30
		set_user_origin(target, origin)
	}
}	

public grab_eff(target)
{
    new origin[3]
   
    get_user_origin(target,origin)
   
    message_begin(MSG_ALL,SVC_TEMPENTITY,{0,0,0},target)
    write_byte(TE_SPRITETRAIL) //РЎРїСЂР°Р№С‚ Р·Р°С…РІР°С‚Р°
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2]+20)
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2]+80)
    write_short(g_short)
    write_byte(20)
    write_byte(20)
    write_byte(4)
    write_byte(20)
    write_byte(10)
    message_end()
}

public grab_eff_zd(id, target)
{
    new origin[3]
    get_user_origin(id, origin, 3)

    message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
    write_byte(TE_BREAKMODEL); // TE_
    write_coord(origin[0]); // X
    write_coord(origin[1]); // Y
    write_coord(origin[2] + 24); // Z
    write_coord(16); // size X
    write_coord(16); // size Y
    write_coord(16); // size Z
    write_coord(random_num(-50,50)); // velocity X
    write_coord(random_num(-50,50)); // velocity Y
    write_coord(25); // velocity Z
    write_byte(10); // random velocity
    write_short(model_gibs); // sprite
    write_byte(9); // count
    write_byte(20); // life
    write_byte(0x08); // flags
    message_end();    
}
	
public push(id)
{
	client_data[id][FLAGS] ^= CDF_IN_PUSH
	return PLUGIN_HANDLED
}

public pull(id)
{
	clientPrint(id, _, "Atraíste a un jugador");
	client_data[id][FLAGS] ^= CDF_IN_PULL
	return PLUGIN_HANDLED
}

public push2( id )
{
	if( client_data[id][GRABBED] > 0 )
	{
		do_push( id )
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public pull2( id )
{
	if( client_data[id][GRABBED] > 0 )
	{
		do_pull( id )
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public do_push( id )
{
	if( client_data[id][GRAB_LEN] < 9999 )
		client_data[id][GRAB_LEN] += 5
}

public do_pull( id )
{
	new mindist = 90
	new len = client_data[id][GRAB_LEN]
	
	if( len > mindist )
	{
		len -= 5
		if( len < mindist ) len = mindist
		client_data[id][GRAB_LEN] = len
	}
	else if( get_pcvar_num( p_auto_choke ) )
		do_choke( id )
}

public do_choke( id )
{
	new target = client_data[id][GRABBED]
	if( client_data[id][FLAGS] & CDF_NO_CHOKE || id == target || target > MaxClients) return
	
	new dmg = 5
	new vec[3]
	FVecIVec( get_target_origin_f( target ), vec )
	
	message_begin( MSG_ONE, SVC_SCREENSHAKE, _, target )
	write_short( 999999 ) //amount
	write_short( 9999 ) //duration
	write_short( 999 ) //frequency
	message_end( )
	
	message_begin( MSG_ONE, SVC_SCREENFADE, _, target )
	write_short( 9999 ) //duration
	write_short( 100 ) //hold
	write_short( SF_FADE_MODULATE ) //flags
	write_byte( 200 ) //r
	write_byte( 0 ) //g
	write_byte( 0 ) //b
	write_byte( 200 ) //a
	message_end( )
	
	message_begin( MSG_ONE, WTF_DAMAGE, _, target )
	write_byte( 0 ) //damage armor
	write_byte( dmg ) //damage health
	write_long( DMG_CRUSH ) //damage type
	write_coord( vec[0] ) //origin[x]
	write_coord( vec[1] ) //origin[y]
	write_coord( vec[2] ) //origin[z]
	message_end( )
		
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BLOODSTREAM )
	write_coord( vec[0] ) //pos.x
	write_coord( vec[1] ) //pos.y
	write_coord( vec[2] + 15 ) //pos.z
	write_coord( random_num( 0, 255 ) ) //vec.x
	write_coord( random_num( 0, 255 ) ) //vec.y
	write_coord( random_num( 0, 255 ) ) //vec.z
	write_byte( 70 ) //col index
	write_byte( random_num( 50, 250 ) ) //speed
	message_end( )
	
	new health = pev( target, pev_health ) - dmg
	set_pev( target, pev_health, float( health ) )
	if( health < 1 ) dllfunc( DLLFunc_ClientKill, target )
	
	emit_sound( target, CHAN_BODY, "player/PL_PAIN2.WAV", VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
	
	client_data[id][FLAGS] ^= CDF_NO_CHOKE
	set_task( 1.5, "clear_no_choke", TSK_CHKE + id )
}

public clear_no_choke( tskid )
{
	new id = tskid - TSK_CHKE
	client_data[id][FLAGS] ^= CDF_NO_CHOKE
}

public concmd__Grab(const id, const level, const cid)
{
	if(!commandAccess(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[MAX_NAME_LENGTH];
	new targetid;

	read_argv(1, arg, charsmax(arg));
	targetid = commandTarget(id, arg);
	
	if(!targetid) {
		return PLUGIN_HANDLED;
	} else if(is_grabbed(targetid, id)) {
		consolePrint(id, "Ya estas agarrando a alguien");
		return PLUGIN_HANDLED
	} else if(!is_user_alive(targetid)) {
		consolePrint(id, "El jugador seleccionado está muerto");
		return PLUGIN_HANDLED
	}
	
	new Float:tmpvec[3], Float:orig[3], Float:torig[3], Float:trace_ret[3], bool:safe = false, i
	
	get_view_pos( id, orig )

	tmpvec = vel_by_aim( id, 90 )
	
	for( new j = 1; j < 11 && !safe; j++ )
	{
		torig[0] = orig[0] + tmpvec[i] * j
		torig[1] = orig[1] + tmpvec[i] * j
		torig[2] = orig[2] + tmpvec[i] * j
		
		traceline( tmpvec, torig, id, trace_ret )
		
		if( get_distance_f( trace_ret, torig ) )
			break
		
		engfunc( EngFunc_TraceHull, torig, torig, 0, HULL_HUMAN, 0, 0 )

		if ( !get_tr2( 0, TR_StartSolid ) && !get_tr2( 0, TR_AllSolid ) && get_tr2( 0, TR_InOpen ) )
			safe = true
	}
	
	pev( id, pev_origin, orig )

	new try[3]
	orig[2] += 2

	while( try[2] < 3 && !safe )
	{
		for( i = 0; i < 3; i++ )
		{
			switch( try[i] )
			{
				case 0 : torig[i] = orig[i] + ( i == 2 ? 80 : 40 )
				case 1 : torig[i] = orig[i]
				case 2 : torig[i] = orig[i] - ( i == 2 ? 80 : 40 )
			}
		}
		
		traceline( tmpvec, torig, id, trace_ret )
		
		engfunc( EngFunc_TraceHull, torig, torig, 0, HULL_HUMAN, 0, 0 )

		if ( !get_tr2( 0, TR_StartSolid ) && !get_tr2( 0, TR_AllSolid ) && get_tr2( 0, TR_InOpen ) && !get_distance_f( trace_ret, torig ) )
			safe = true
		
		try[0]++
		if( try[0] == 3 )
		{
			try[0] = 0
			try[1]++
			if( try[1] == 3 )
			{
				try[1] = 0
				try[2]++
			}
		}
	}
	
	if(safe)
	{
		set_pev( targetid, pev_origin, torig );
		set_grabbed( id, targetid );
	}

	return PLUGIN_HANDLED;
}

public is_grabbed(const target, const grabber) {
	new i;
	for(i = 1; i <= MaxClients; ++i) {
		if(client_data[i][GRABBED] == target) {
			clcmd__UnGrab(grabber);
			return 1;
		}
	}

	return 0;
}

public DeathMsg() {
	kill_grab(read_data(2));
}

public client_disconnected(id) {
	kill_grab(id);
	speed_off[id] = false;
}

public kill_grab(const id) {
	if(client_data[id][GRABBED]) {
		clcmd__UnGrab(id);
	} else if(client_data[id][GRABBER]) {
		clcmd__UnGrab(client_data[id][GRABBER]);
	}
}

public traceline(Float:vecStart[3], Float:vecEnd[3], ignore, Float:vecEndPos[3]) {
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, 0, ignore, 0);
	get_tr2(0, TR_vecEndPos, vecEndPos);
	return get_tr2(0, TR_pHit);
}

public get_view_pos(const id, Float:vecOrigin[3]) {
	new Float:vecViewOfs[3];

	pev(id, pev_origin, vecOrigin);
	pev(id, pev_view_ofs, vecViewOfs);

	vecOrigin[0] += vecViewOfs[0];
	vecOrigin[1] += vecViewOfs[1];
	vecOrigin[2] += vecViewOfs[2];
}

public Float:vel_by_aim(const id, const speed) {
	new Float:vecAngle[3];
	new Float:v2[3];

	pev(id, pev_v_angle, vecAngle);
	engfunc(EngFunc_AngleVectors, vecAngle, vecAngle, v2, v2);

	vecAngle[0] *= speed;
	vecAngle[1] *= speed;
	vecAngle[2] *= speed;

	return vecAngle;
}

clientPrint(const id, const sender=print_team_default, const message[], any:...) {
	static sMessage[192];
	vformat(sMessage, charsmax(sMessage), message, 4);

	sMessage[191] = EOS;

	replace_all(sMessage, charsmax(sMessage), "!g", "^4");
	replace_all(sMessage, charsmax(sMessage), "!t", "^3");
	replace_all(sMessage, charsmax(sMessage), "!y", "^1");

	if(sender == print_team_grey) {
		client_print_color(id, sender, "^4*^1 %s", sMessage);
	} else {
		client_print_color(id, sender, "^4[%s]^1 %s", __PLUGIN_COMMUNITY_PREFIX, sMessage);
	}
}

consolePrint(const id, const message[], any:...) {
	static sMessage[192];
	vformat(sMessage, charsmax(sMessage), message, 3);

	sMessage[191] = EOS;

	console_print(id, "[%s] %s", __PLUGIN_COMMUNITY_PREFIX, sMessage);
}