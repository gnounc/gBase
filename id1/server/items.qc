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
void() W_SetCurrentAmmo;
void() ammo_touch;
void() weapon_touch;
entity() e_shotgun;
entity() e_super_shotgun;
entity() e_nailgun;
entity() e_super_nailgun;
entity() e_grenade_launcher;
entity() e_rocket_launcher;
entity() e_lightning_gun;

entity(entity e_player, entity ammoContainer) moveAmmo;
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */

void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};



/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos(self.origin));
	dprint ("\n");
	remove (self);
};



/*============
PlaceItem

plants the object on the floor
============*/
void() PlaceItem =
{
	local float	oldz;

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;

	if (!droptofloor())
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);

		return;
	}
};

/*============
StartItem

Sets the clipping size and plants the object on the floor
============*/
void() StartItem =
{
	setsize (self, '0 0 0', '32 32 56');
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};

/*=========================================================================

HEALTH BOX

=========================================================================*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
	if (e.health <= 0)
		return 0;

	if ((!ignore) && (e.health >= e.max_health))
		return 0;

	checkCallbacks(e, "event_heal");

	healamount = ceil(healamount);

	e.health = e.health + healamount;

	if ((!ignore) && (e.health >= e.max_health))
		e.health = e.max_health;
		
	if (e.health > 250)
		e.health = 250;

	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
//.float	healamount, healtype;
void() health_touch;
void() item_megahealth_rot;

void() item_health =
{	
	self.touch = health_touch;

	if (self.spawnflags & H_ROTTEN)
	{
		precache_model("maps/b_bh10.bsp");

		precache_sound("items/r_item1.wav");
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}

	else if (self.spawnflags & H_MEGA)
	{
		precache_model("maps/b_bh100.bsp");
		precache_sound("items/r_item2.wav");
		setmodel(self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}

	else
	{
		precache_model("maps/b_bh25.bsp");
		precache_sound("items/health1.wav");
		setmodel(self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

void() health_touch =
{
	local	string	s;
	
	if (other.classname != "player")
		return;
	
	if (self.healtype == 2) // Megahealth?  Ignore max_health...
	{
		if (other.health >= 250)
			return;
		if (!T_Heal(other, self.healamount, 1))
			return;
	}

	else
	{
		if (!T_Heal(other, self.healamount, 0))
			return;
	}
	
	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");
	
	// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	stuffcmd (other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
		other.items = other.items | IT_SUPERHEALTH;
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		self.owner = other;
	}

	else
	{
		if (deathmatch != 2)		// deathmatch 2 is the silly old rules
		{
			if (deathmatch)
				self.nextthink = time + 20;
			self.think = SUB_regen;
		}
	}
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};	

void() item_megahealth_rot =
{
	other = self.owner;
	
	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;

		return;
	}

	// it is possible for a player to die and respawn between rots, so don't
	// just blindly subtract the flag off
	other.items = other.items - (other.items & IT_SUPERHEALTH);
	
	if (deathmatch == 1)	// deathmatch 2 is silly old rules
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
};

/*===============================================================================

ARMOR

===============================================================================*/

void() armor_touch =
{
	if(other.classname != "player")
		return;

	//TODO: put in checks to see if the armor should NOT be picked up. (maybe just use the +use key to swap weapons and armor, halo style)

	//if you dont have armor, or if your armor is completely busted.
	if((!other.e_armor) || (!other.e_armor.armorvalue))
		other.e_armor = self;

	self.solid = SOLID_NOT;
	self.model = string_null;

	if (deathmatch == 1)
		self.nextthink = time + 20;

	self.think = SUB_regen;

	sprint(other, "You got armor\n");
	// armor touch sound
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


entity create_e_armor(vector org, string class_name, float armor_type, float armor_value, float(entity targ, entity inflictor, entity attacker, float damage) armor_func)
{
	entity e = spawn();
	e.classname = class_name;

	e.armortype = armor_type;
	e.armorvalue = armor_value;

	string basepath = strcat("data/armor/");
	string pickup_model = strcat(basepath, class_name, "/pickup_model.mdl");

	e.touch = armor_touch;
	precache_model (pickup_model);
	setmodel (e, pickup_model);
	e.skin = 0;
	e.func_armor = armor_func;

	setorigin(e, org);
	setsize (e, '0 0 0', '32 32 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;

	return e;
//	StartItem ();
}

/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)*/
float func_standard_armor(entity targ, entity inflictor, entity attacker, float damage)
{
	//this should work for yellow and green armor as well. just remember to set armorvalues on the pickup items.
	float save = ceil(targ.e_armor.armortype*damage);

	bprint(strcat("func_standard_armor. save: ", ftos(save),"\n"));

	if(targ.e_armor.armorvalue >= save)
	{
		targ.e_armor.armorvalue -= save;
		return damage - save;
	}

	targ.e_armor.armorvalue = 0;

	return damage - targ.e_armor.armorvalue;
}

void() item_armor1 =
{
	create_e_armor(self.origin, "greenarmor", 0.3, 100, func_standard_armor);
	remove(self);
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)*/

void() item_armor2 =
{
	create_e_armor(self.origin, "yellowarmor", 0.6, 150, func_standard_armor);
	remove(self);
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)*/

void() item_armorInv =
{
	create_e_armor(self.origin, "redarmor", 0.8, 200, func_standard_armor);
	remove(self);
};

entity create_e_ammo(string class_name, float ammo_count, float ammomax)
{
	string basepath = strcat("data/ammo/", class_name, "/");

	entity e = spawn();
	e.classname = class_name;
	e.currentammo = ammo_count;
	e.ammo_max = ammomax;

	e.hud_icon = strcat(basepath, "/hud");
	e.pickup_model = strcat(basepath, "pickup_model.bsp");
	e.pickup_sound = strcat(basepath, "pickup_sound.wav");

//	precache_pic (e.hud_icon);
	precache_model (e.pickup_model);
	precache_sound (e.pickup_sound);

	e.touch = ammo_touch;
	setmodel (e, e.pickup_model);

	return e;
}

/*=============
weapon_touch
=============*/

void() weapon_touch =
{
	entity e_player = other;
	entity e_weap = self;

	if (!(e_player.flags & FL_CLIENT))
		return;

	entity inventory_weapon = moveAmmo(e_player, e_weap);

	sprint(e_player, strcat("You got the ", inventory_weapon.classname, "\n"));
	sound(e_player, CHAN_ITEM, e_weap.pickup_sound, 1, ATTN_NORM);
	stuffcmd (e_player, "bf\n");

	e_player.e_weapon.think = SUB_Null; //stop reloading
	
	entity oldself = self;
	self = other;
	self.e_weapon.func_lower();
	self = oldself;
	
	inventory_weapon.owner = e_player;
	e_player.e_weapon = inventory_weapon;

//	player_run ();		// get out of any weapon firing states
	e_player.weaponframe = 0;
	e_player.weaponmodel = inventory_weapon.weaponmodel;
	e_player.currentammo = inventory_weapon.currentammo;

	self = other;
	W_SetCurrentAmmo ();
	self.e_weapon.func_raise();
	self = oldself;
			
	// remove it in single player, or setup for respawning in deathmatch
	e_weap.model = "";
	e_weap.solid = SOLID_NOT;

	if (deathmatch == 1)
		e_weap.nextthink = time + 30;

	e_weap.think = SUB_regen;
	
	activator = e_player;
	SUB_UseTargets();				// fire all targets / killtargets

	checkCallbacks(e_player, "event_weapon");
};


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)*/
void() weapon_shotgun =
{
	entity e = e_shotgun();
	setorigin(e, self.origin);
	remove(self);

	setsize (e, '-16 -16 0', '16 16 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

void() weapon_supershotgun =
{
	entity e = e_super_shotgun();
	setorigin(e, self.origin);
	remove(self);

	setsize (e, '-16 -16 0', '16 16 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
	entity e = e_nailgun();
	setorigin(e, self.origin);
	remove(self);

	setsize (e, '-16 -16 0', '16 16 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supernailgun =
{
	entity e = e_super_nailgun();
	setorigin(e, self.origin);
	remove(self);

	setsize (e, '-16 -16 0', '16 16 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_grenadelauncher =
{
	entity e = e_grenade_launcher();
	setorigin(e, self.origin);
	remove(self);

	setsize (e, '-16 -16 0', '16 16 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_rocketlauncher =
{
	entity e = e_rocket_launcher();
	setorigin(e, self.origin);
	remove(self);

	setsize (e, '-16 -16 0', '16 16 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};


/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_lightning =
{
	entity e = e_lightning_gun();
	setorigin(e, self.origin);
	remove(self);

	setsize (e, '-16 -16 0', '16 16 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};


//TODO: Maybe put this back in. this spawns ammoboxes in deathmatch
void() item_weapon {}

/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
	entity e_ammo = self;
	entity e_player = other;

	if (e_player.classname != "player")
		return;

	if (e_player.health <= 0)
		return;

	entity existing_ammobox = get_inventory_item(e_player, e_ammo.classname);

	if(!existing_ammobox)
	{
		add_inventory_item(e_player, e_ammo);
	}
	else
	{
		//bail if you didnt even need ammo
		if(existing_ammobox.currentammo == existing_ammobox.ammo_max)
		{
			sprint(e_player, "you dont need ammo.\n");
			return;
		}

		existing_ammobox.currentammo += e_ammo.currentammo;

		if(existing_ammobox.currentammo > existing_ammobox.ammo_max)
		{
			existing_ammobox.currentammo = existing_ammobox.ammo_max;
		}
	}

	sprint (e_player, strcat("You got the ", e_ammo.classname, "\n"));
	sound (e_player, CHAN_ITEM, e_ammo.pickup_sound, 1, ATTN_NORM);
	stuffcmd (e_player, "bf\n");
		
	// remove it in single player, or setup for respawning in deathmatch
	e_ammo.model = string_null;
	e_ammo.solid = SOLID_NOT;

	if (deathmatch == 1)
		e_ammo.nextthink = time + 30;
	
	e_ammo.think = SUB_regen;

	activator = e_player;
	SUB_UseTargets();				// fire all targets / killtargets
};




float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_shells =
{
	entity e = create_e_ammo("shells", 6, 20);
	setorigin (e, self.origin);
	remove(self);

	setsize (e, '0 0 0', '32 32 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_spikes =
{
	entity e = create_e_ammo("nails", 10, 20);
	setorigin (e, self.origin);
	remove(self);

	setsize (e, '0 0 0', '32 32 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_rockets =
{
	entity e = create_e_ammo("rockets", 4, 20);
	setorigin (e, self.origin);
	remove(self);

	setsize (e, '0 0 0', '32 32 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_cells =
{
	entity e = create_e_ammo("cells", 25, 20);
	setorigin (e, self.origin);
	remove(self);

	setsize (e, '0 0 0', '32 32 56');
	e.nextthink = time + 0.2;	// items start after other solids
	e.think = PlaceItem;
};

/*
===============================================================================

KEYS

===============================================================================
*/

void() key_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	if (other.items & self.items)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	if (!coop)
	{	
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	checkCallbacks(other, "event_key");

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


void() key_setsounds =
{
	if (world.worldtype == 0)
	{
		precache_sound ("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}

	if (world.worldtype == 1)
	{
		precache_sound ("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}

	if (world.worldtype == 2)
	{
		precache_sound2 ("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base*/

void() item_key1 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_s_key.mdl");
		setmodel (self, "progs/w_s_key.mdl");
		self.netname = "silver key";
	}

	else if (world.worldtype == 1)
	{
		precache_model ("progs/m_s_key.mdl");
		setmodel (self, "progs/m_s_key.mdl");
		self.netname = "silver runekey";
	}

	else if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
		self.netname = "silver keycard";
	}

	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base*/

void() item_key2 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}

	if (world.worldtype == 1)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}

	if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}

	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	centerprint (other, "You got the rune!");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = string_null;		// so rune doors won't find it
	
	checkCallbacks(other, "event_sigil");

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}

	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}

	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}

	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	if (deathmatch)
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_invulnerability") || (self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
		
		self.think = SUB_regen;
	}	

	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

	// do the apropriate action
	switch(self.classname)
	{
		case "item_artifact_envirosuit":
			other.rad_time = 1;
			other.radsuit_finished = time + 30;
			break;

		case "item_artifact_invulnerability":
			other.invincible_time = 1;
			other.invincible_finished = time + 30;
			break;

		case "item_artifact_invisibility":
			other.invisible_time = 1;
			other.invisible_finished = time + 30;
			break;

		case "item_artifact_super_damage":
			other.super_time = 1;
			other.super_damage_finished = time + 30;
			break;

		case "item_artifact_envirosuit":
			other.rad_time = 1;
			other.radsuit_finished = time + 30;
			break;
		default:
			break;
	}


	checkCallbacks(other, "event_powerups");

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds*/
void() item_artifact_invulnerability =
{
	self.touch = powerup_touch;

	precache_model ("progs/invulner.mdl");
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;

	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds*/
void() item_artifact_invisibility =
{
	self.touch = powerup_touch;

	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage*/
void() item_artifact_super_damage =
{
	self.touch = powerup_touch;

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

//the entirety of BackpackTouch
//copypasta'd directly from gpl'd qw source on github.
void() BackpackTouch =
{
	entity e_player = other;
	entity e_backpack = self;

	if (e_player.classname != "player")
		return;

	if (e_player.health <= 0)
		return;
		
	string str_item;
	entity backpack_item;
	string possibleItems = "shotgun;super_shotgun;nailgun;super_nailgun;grenade_launcher;rocket_launcher;lightning_gun;shells;nails;rockets;cells";

	float tokencount = tokenizebyseparator(possibleItems, ";");

	for (int i = 0; tokencount > i; ++i)
	{
		str_item = argv(i);
		backpack_item = get_inventory_item(e_backpack, str_item);

		bprint(strcat("str_item is: ", str_item, "\n"));

		if(!backpack_item)
			continue;

		moveAmmo(e_player, backpack_item);
	}

	// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	remove(self);
	self = other;
};


/*===============
DropBackpack
===============*/
void() DropBackpack =
{
	entity backpack;

	backpack = spawn();
	backpack.origin = self.origin - '0 0 24';
	backpack.inventory = self.inventory;			//FIXME this does not seem to be doing the trick

	backpack.velocity_z = 300;
	backpack.velocity_x = -100 + (random() * 200);
	backpack.velocity_y = -100 + (random() * 200);
	
	backpack.flags = FL_ITEM;
	backpack.solid = SOLID_TRIGGER;
	backpack.movetype = MOVETYPE_TOSS;
	setmodel (backpack, "progs/backpack.mdl");
	setsize (backpack, '-16 -16 0', '16 16 56');
	backpack.touch = BackpackTouch;
	
	backpack.nextthink = time + 120;    // remove after 2 minutes
	backpack.think = SUB_Remove;
};
