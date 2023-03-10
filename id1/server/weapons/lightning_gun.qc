
void() W_FireLightning 

entity e_lightning_gun()
{
	entity e = create_e_weapon("lightning_gun", "cells");

	e.kick = 2;
	e.attack_time = 0.5;

	e.ammo_max = 80;
	e.currentammo = 4;
	e.ammo_consumption = 1;
	e.reload_amount = 20;
	e.reload_time = 0.6;

	e.projectile_count = 6;
	e.spread = [0.04, 0.04, 0];
	e.func_attack = W_FireLightning;
	e.func_raise = shotgun_raise1;
	e.func_lower = shotgun_lower1;
	e.func_reload = shotgun_reload1;

	e.player_animation = player_shot1;

	e.killstring = "{0} accepts {1}'s shaft\n";
	e.underwater_killstring= "{0} accepts {1}'s discharge\n";
						
	return e;
}

void() W_FireLightning =
{
	bprint("firerocket fired.\n");

	entity e_attacker = self.owner;
	entity e_weap = self;

	//for ai
	entity e_enemy = e_attacker.enemy; 

	vector		org;

	// explode if under water
	if (e_attacker.waterlevel > 1)
	{
		e_weap.currentammo = 0;
		T_RadiusDamage (e_attacker, e_attacker, 35*e_weap.currentammo, world);
		return;
	}

	if (e_attacker.t_width < time)
	{
		e_attacker.t_width = time + 0.6;
	}

	org = e_attacker.origin + '0 0 16';
	
	makevectors (e_attacker.v_angle);
	
	vector direction = '0 0 0';
	if(e_attacker.classname != "player")
	{
		direction = e_enemy.origin - e_enemy.velocity*0.2;
		direction = normalize (direction - e_attacker.origin);
	}
	else
	{
		direction = v_forward;
	}

	traceline (org, org + direction*600, TRUE, e_attacker);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	LightningDamage (e_attacker.origin, trace_endpos + v_forward*4, e_attacker, 30);
};