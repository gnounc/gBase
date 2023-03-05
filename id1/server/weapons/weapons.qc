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

void() W_FireShotgun;
void() W_FireSuperShotgun;
void() W_FireGrenade;
void() W_FireRocket;
void() ImpulseCommands;


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};

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

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	switch(self.weapon)
	{
		case IT_AXE:
			self.currentammo = 0;
			self.weaponmodel = "progs/v_axe.mdl";
			break;
		case IT_SHOTGUN:
			self.currentammo = self.ammo_shells;
			self.weaponmodel = "progs/v_shot.mdl";
			self.items = self.items | IT_SHELLS;
			break;
		case IT_SUPER_SHOTGUN:
			self.currentammo = self.ammo_shells;
			self.weaponmodel = "progs/v_shot2.mdl";
			self.items = self.items | IT_SHELLS;
			break;
		case IT_NAILGUN:
			self.currentammo = self.ammo_nails;
			self.weaponmodel = "progs/v_nail.mdl";
			self.items = self.items | IT_NAILS;
			break;
		case IT_SUPER_NAILGUN:
			self.currentammo = self.ammo_nails;
			self.weaponmodel = "progs/v_nail2.mdl";
			self.items = self.items | IT_NAILS;
			break;
		case IT_GRENADE_LAUNCHER:
			self.currentammo = self.ammo_rockets;
			self.weaponmodel = "progs/v_rock.mdl";
			self.items = self.items | IT_ROCKETS;
			break;
		case IT_ROCKET_LAUNCHER:
			self.currentammo = self.ammo_rockets;
			self.weaponmodel = "progs/v_rock2.mdl";
			self.items = self.items | IT_ROCKETS;
			break;
		case IT_LIGHTNING:
			self.currentammo = self.ammo_cells;
			self.weaponmodel = "progs/v_light.mdl";
			self.items = self.items | IT_CELLS;
			break;
		default:
			self.currentammo = 0;
			self.weaponmodel = string_null;
			break;
	}

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
//gnounc
//wanted to get rid of the horrible triple negative when reading the call to checkNoAmmo. 
//also it was unclear what checkNoAmmo should return for no ammo
float() W_hasNoAmmo =
{
	if (self.currentammo)
		return FALSE;	//player has ammo	--gnounc

	if (self.weapon == IT_AXE)
		return FALSE;	//the axe doesnt need ammo. so we lie. Player Totally has ammo..Promise! --gnounc
	
	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
	// drop the weapon down
	return TRUE;
};


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

void() W_Attack =
{
	local	float	r;

//	listRegistered();

	if (W_hasNoAmmo())
		return;

	makevectors	(self.v_angle);		// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	switch(self.weapon)
	{
		case IT_AXE:
			sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
			r = random();
			if (r < 0.25)
				player_axe1 ();

			else if (r<0.5)
				player_axeb1 ();

			else if (r<0.75)
				player_axec1 ();

			else
				player_axed1 ();

			self.attack_finished = time + 0.5;
			break;
		case IT_SHOTGUN:
			player_shot1 ();
			W_FireShotgun ();
			self.attack_finished = time + 0.5;
			break;
		case IT_SUPER_SHOTGUN:
			player_shot1 ();
			W_FireSuperShotgun ();
			self.attack_finished = time + 0.7;
			break;
		case IT_NAILGUN:
			player_nail1 ();
			break;
		case IT_SUPER_NAILGUN:
			player_nail1 ();
			break;
		case IT_GRENADE_LAUNCHER:
			player_rocket1();
			W_FireGrenade();
			self.attack_finished = time + 0.6;
			break;
		case IT_ROCKET_LAUNCHER:
			player_rocket1();
			W_FireRocket();
			self.attack_finished = time + 0.8;
			break;
		case IT_LIGHTNING:
			player_light1();
			self.attack_finished = time + 0.1;
			sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
			break;
		default:
			break;
	}


	checkCallbacks(self, "event_attack");
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
	fl = it = self.items;
	am = 0;

	fl = pow(2, (self.impulse - 2));
	switch(fl)
	{
		case 0.5:
			fl = IT_AXE;
			break;
		case IT_SHOTGUN:
			if (self.ammo_shells < 1)
				am = 1;
			break;
		case IT_SUPER_SHOTGUN:
			if (self.ammo_shells < 2)
				am = 1;
			break;
		case IT_NAILGUN:
			if (self.ammo_nails < 1)
				am = 1;
			break;
		case IT_SUPER_NAILGUN:
			if (self.ammo_nails < 2)
				am = 1;
			break;
		case IT_GRENADE_LAUNCHER:
			if (self.ammo_rockets < 1)
				am = 1;
			break;
		case IT_ROCKET_LAUNCHER:
			if (self.ammo_rockets < 1)
				am = 1;
			break;
		case IT_LIGHTNING:
			if (self.ammo_cells < 1)
				am = 1;
			break;
		default:
			self.currentammo = 0;
			self.weaponmodel = string_null;				
			break;
	}

	self.impulse = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = fl;		
	W_SetCurrentAmmo ();
};


/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;
	
	while (1)
	{
		am = 0;

		switch(self.weapon)
		{
			case IT_LIGHTNING:		
				self.weapon = IT_AXE;
				break;

			case IT_AXE:
				self.weapon = IT_SHOTGUN;

				if (self.ammo_shells < 1)
					am = 1;
				break;

			case IT_SHOTGUN:
				self.weapon = IT_SUPER_SHOTGUN;

				if (self.ammo_shells < 2)
					am = 1;
				break;		

			case IT_SUPER_SHOTGUN:
				self.weapon = IT_NAILGUN;

				if (self.ammo_nails < 1)
					am = 1;
				break;

			case IT_NAILGUN:
				self.weapon = IT_SUPER_NAILGUN;

				if (self.ammo_nails < 2)
					am = 1;
				break;

			case IT_SUPER_NAILGUN:
				self.weapon = IT_GRENADE_LAUNCHER;

				if (self.ammo_rockets < 1)
					am = 1;
				break;

			case IT_GRENADE_LAUNCHER:
				self.weapon = IT_ROCKET_LAUNCHER;

				if (self.ammo_rockets < 1)
					am = 1;
				break;

			case IT_ROCKET_LAUNCHER:
				self.weapon = IT_LIGHTNING;

				if (self.ammo_cells < 1)
					am = 1;
				break;

			default:
				break;
		}
	
		if ( (self.items & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
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
	local float it, am;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		switch(self.weapon)
		{
			case IT_LIGHTNING:
				self.weapon = IT_ROCKET_LAUNCHER;

				if (self.ammo_rockets < 1)
				am = 1;
				break;

			case IT_ROCKET_LAUNCHER:
				self.weapon = IT_GRENADE_LAUNCHER;

				if (self.ammo_rockets < 1)
				am = 1;
				break;

			case IT_GRENADE_LAUNCHER:
				self.weapon = IT_SUPER_NAILGUN;

				if (self.ammo_nails < 2)
				am = 1;
				break;

			case IT_SUPER_NAILGUN:
				self.weapon = IT_NAILGUN;

				if (self.ammo_nails < 1)
				am = 1;
				break;

			case IT_NAILGUN:
				self.weapon = IT_SUPER_SHOTGUN;

				if (self.ammo_shells < 2)
				am = 1;
				break;

			case IT_SUPER_SHOTGUN:
				self.weapon = IT_SHOTGUN;

				if (self.ammo_shells < 1)
				am = 1;
				break;

			case IT_SHOTGUN:
				self.weapon = IT_AXE;
				break;

			case IT_AXE:
				self.weapon = IT_LIGHTNING;

				if (self.ammo_cells < 1)
				am = 1;
				break;
		}

		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
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

	if (self.impulse)	// gb, stop wasting performance
		ImpulseCommands ();
	
	// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
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


