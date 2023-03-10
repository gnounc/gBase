/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;

void() FireBullets;


//TODO: dont know why the compiler is buggin' here
entity(string s_classname, float f_lifetime, void() f_touch) create_projectile;

void() spike;
void() grenade;
void() missile;

void() ImpulseCommands;


void add_inventory_item(entity player, entity item);
entity get_inventory_item(entity player, string classname)
entity remove_inventory_item(entity player, string classname)


// called by worldspawn
// no longer used --gnounc
void() W_Precache = {};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;

	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};


/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};



/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	player_run ();		// get out of any weapon firing states
	self.weaponframe = 0;
	self.weaponmodel = self.e_weapon.weaponmodel;	//set weaponmodel in case weapon has been changed;
	self.currentammo = self.e_weapon.currentammo;
};

float() W_BestWeapon =
{
	local	float	it;
	
	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
		return IT_LIGHTNING;
	else if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;

	return IT_AXE;
};


entity create_e_weapon(string class_name, string ammo_class)
{
	string basepath = strcat("data/weapons/", class_name, "/");
	string ammo_basepath = strcat("data/ammo/", ammo_class, "/");

	entity e = spawn();

	e.classname = class_name;
	e.ammo_type = ammo_class;

//	precache_sound (strcat(basepath, "/hud"));
	precache_model(strcat(ammo_basepath, "pickup_model.bsp"));
	precache_sound(strcat(ammo_basepath, "pickup_sound.wav"));

	precache_model (strcat(basepath, "view_model.mdl"));
	precache_model (strcat(basepath, "pickup_model.mdl"));
	precache_model (strcat(basepath, "view_model.mdl"));
	
	
	precache_sound (strcat(basepath, "pickup_sound.wav"));
	precache_sound (strcat(basepath, "attack_sound.wav"));

	precache_sound (strcat(basepath, "empty_sound.wav"));
	precache_sound (strcat(basepath, "raise_sound.wav"));
	precache_sound (strcat(basepath, "lower_sound.wav"));
	precache_sound (strcat(basepath, "reload_sound.wav"));

	e.hud_icon = strcat(basepath, "/hud");
	e.weaponmodel = strcat(basepath, "view_model.mdl");
	e.pickup_model = strcat(basepath, "pickup_model.mdl");
	e.pickup_sound = strcat(basepath, "pickup_sound.wav");
	e.attack_sound = strcat(basepath, "attack_sound.wav");

	e.empty_sound = strcat(basepath, "empty_sound.wav");
	e.raise_sound = strcat(basepath, "raise_sound.wav");
	e.lower_sound = strcat(basepath, "lower_sound.wav");
	e.reload_sound = strcat(basepath, "reload_sound.wav");

	e.touch = weapon_touch;
	setmodel (e, e.pickup_model);

	return e;
}


/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_light1;
void()	player_rocket1;


//consider making this and weapon_attack just function pointers in the shotgun.qc files themselves.
void W_Reload()
{
	entity e_weap = self;
	entity e_player = self.owner;

	if(e_weap.reload_finished > time)
	{
		sprint(e_player, "time not finished.\n");

		e_weap.think = W_Reload;
		e_weap.nextthink = e_weap.reload_finished;	//so you can reload immediately after firing, without it being exploitable (cutting out a bit of time so it feels snappier)
		return;
	}

	//calc ammo missing from clip
	float ammo_needed = e_weap.ammo_max - e_weap.currentammo;

	//no ammo needed, so dont reload;
	if(!ammo_needed)
	{
		sprint(e_player, "no ammo needed.\n");
		return;
	}

	//only take up to the reload_amount per reload animation.
	if(ammo_needed > e_weap.reload_amount)
	{
		ammo_needed = e_weap.reload_amount;	
	}

	//find an ammobox in players inventory
	entity e_ammobox = get_inventory_item(e_player, e_weap.ammo_type);

	if(!e_ammobox)
	{
		sprint(e_player, "you dont have an ammobox.\n");
		return;		
	}

	if(!e_ammobox.currentammo)
	{
		sprint(e_player, "the ammobox is empty.\n");
		return;				
	}

	//count ammo available in ammobox (up to the amount needed)
	float ammo_take = 0;
	if(e_ammobox.currentammo > ammo_needed)
	{
		ammo_take = ammo_needed;
	}
	else
	{
		ammo_take = e_ammobox.currentammo;
	}

	//remove ammo from ammobox
	e_ammobox.currentammo -= ammo_take;

	//add ammo to weapon
	e_weap.currentammo += ammo_take;

	//play player animation
	//player_reload();

	//play weapon animation
	e_weap.func_reload();

	//prevent further action until reloading is done
	e_weap.attack_finished += e_weap.reload_time;	//for cartridge reloads, this is per cartridge

	//play reload sound
	sound(e_player, CHAN_WEAPON, e_weap.reload_sound, 1, ATTN_NORM);	

	//update hud
	e_player.currentammo = e_weap.currentammo;

	//if the ammobox has more ammo to give, and the gun isnt full yet, schedule another one.
	if((e_ammobox.currentammo) && (e_weap.currentammo < e_weap.ammo_max))
	{	
		e_weap.think = W_Reload;
		e_weap.nextthink = time + e_weap.reload_time;
		e_weap.reload_finished = time + e_weap.reload_time;
	}

/*
	if ammobox is empty, delete ammobox
	
	if(e_ammobox.currentammo < 1)
	{
		remove_inventory_item(self, "e_weap.ammo_type");
	}
*/
}

void() W_Attack =
{
	entity e_weap = self;
	entity e_player = self.owner;

//	listRegistered();

	//stop trying to reload if you cancel a reload
	if(e_weap.reload_finished > time)
	{
		e_weap.think = SUB_Null;
	}

	if(e_weap.attack_finished > time)
	{
		return;
	}

	e_weap.attack_finished = time + e_weap.attack_time;

	if(e_weap.currentammo < e_weap.ammo_consumption)
	{
		sound (e_player, CHAN_WEAPON, e_weap.empty_sound, 1, ATTN_NORM);	
		return;
	}

	//attack can interrupt reload. so we need to make sure reload cant interrupt attack...or it will create an exploit for fast-reload
	e_weap.reload_finished = e_weap.reload_time + time;

	makevectors	(e_player.v_angle);		// calculate forward angle for velocity
	e_player.show_hostile = time + 1;	// wake monsters up

//play weapons player animation
	//TODO: Until i figure out how to get a .void() out of a string.
	if(e_weap.player_animation)
		e_weap.player_animation();

	self.func_attack();

//	self.fire_animation();


	e_player.punchangle_x = (e_weap.kick * -1);	//BUG - appears to not work
	e_player.currentammo = e_weap.currentammo -= e_weap.ammo_consumption;

	//update hud
	e_player.currentammo = e_weap.currentammo;

	checkCallbacks(self, "event_attack");
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	if(!self)
	{
		bprint("self is world\n");
	}

	//TODO: this doesnt appear to be working?
	entity weap;
	string str_weapon = "";

	switch(self.impulse)
	{
		case 1:
			str_weapon = "axe";
			break;
		case 2:
			str_weapon = "shotgun";
			break;
		case 3:
			str_weapon = "super_shotgun";
			break;
		case 4:
			str_weapon = "nailgun";
			break;
		case 5:
			str_weapon = "super_nailgun";
			break;
		case 6:
			str_weapon = "grenade_launcher";
			break;
		case 7:
			str_weapon = "rocket_launcher";
			break;
		case 8:
			str_weapon = "lightning_gun";
			break;
		default:
			str_weapon = "axe";
			break;
	}

	weap = get_inventory_item(self, str_weapon);

	self.impulse = 0;
	
	sprint (self, strcat("impulse: ", str_weapon,".\n"));

	if(weap == world)
	{
		sprint (self, "no weapon.\n");
		return;		
	}
	
	if (weap.currentammo < 1)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

	if(!self.e_weapon)
		bprint("no self.e_weapon in changeweapon.\n");

	if(weap.classname == self.e_weapon.classname)
	{
		return;
	}

	self.e_weapon.think = SUB_Null; //stop reloading

	if(!self.e_weapon.func_lower)
	{
		bprint("func_lower is null.\n");
		bprint(strcat("e_weapon.classname", self.e_weapon.classname, "\n"));
	}

	self.e_weapon.func_lower();
	self.e_weapon = weap;
	W_SetCurrentAmmo ();
	self.e_weapon.func_raise();
};


/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/

void() CycleWeaponCommand =
{
	self.impulse = 0;

	float found = 0;
	string str_weapon;
	entity weap = world;	
	string weaponlist = "shotgun;super_shotgun;nailgun;super_nailgun;grenade_launcher;rocket_launcher;lightning_gun;axe;shotgun;super_shotgun;nailgun;super_nailgun;grenade_launcher;rocket_launcher;lightning_gun";

	float tokencount = tokenizebyseparator(weaponlist, ";");

	for (int i = 0; tokencount > i; ++i)
	{
		str_weapon = argv(i);

		if(!found)
		{
			if(str_weapon == self.e_weapon.classname)
			{
				found = 1;
			}

			continue;
		}

		weap = get_inventory_item(self, argv(i));

		if(weap != world)
		{
			self.e_weapon.think = SUB_Null; //stop reloading
			self.e_weapon.func_lower();
			self.e_weapon = weap;
			W_SetCurrentAmmo ();
			self.e_weapon.func_raise();
			return;
		}
	}
};


/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	self.impulse = 0;

	float found = 0;
	string str_weapon;
	entity weap = world;	
	string weaponlist = "lightning_gun;rocket_launcher;grenade_launcher;super_nailgun;nailgun;super_shotgun;shotgun;axe;lightning_gun;rocket_launcher;grenade_launcher;super_nailgun;nailgun;super_shotgun;shotgun";

	float tokencount = tokenizebyseparator(weaponlist, ";");

	for (int i = 0; tokencount > i; ++i)
	{
		str_weapon = argv(i);

		if(!found)
		{
			if(str_weapon == self.e_weapon.classname)
			{
				found = 1;
			}

			continue;
		}

		weap = get_inventory_item(self, argv(i));

		if(weap != world)
		{
			self.e_weapon.think = SUB_Null; //stop reloading
			self.e_weapon.func_lower();
			self.e_weapon = weap;
			W_SetCurrentAmmo ();
			self.e_weapon.func_raise();
			return;
		}
	}
};


/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

	if ((self.impulse) && (!self.button0))	// gb, stop wasting performance
		ImpulseCommands ();
	
	// check for attack
	if (self.button0)
	{
		SuperDamageSound ();

		entity oldself;
		oldself = self;
		self = self.e_weapon;
		
		W_Attack();
		
		self = oldself;
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


