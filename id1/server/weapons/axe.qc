void()	shotgun_raise1;
void()	shotgun_lower1;

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	entity e_attacker = self.owner;
	entity e_weap = self;

	//for ai
	entity e_enemy = e_attacker.enemy; 

	vector source;
	vector org;

	//TODO: add direction hack thats in the other weapons files.

	makevectors (e_attacker.v_angle);
	source = e_attacker.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, e_attacker);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 20);
		T_Damage (trace_ent, e_attacker, e_attacker, 20);
	}

	else
	{	// hit wall
		sound (e_attacker, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

entity e_axe()
{
	//TODO: doublecheck w_fire, it may freak out over no ammo type
	//TODO: doublecheck ammo adding, it may freak out over no ammo type
	entity e = create_e_weapon("axe", "melee");

	e.kick = 2;
	e.attack_time = 0.5;

	e.ammo_max = 0;
	e.currentammo = 0;
	e.ammo_consumption = 0;
	e.reload_amount = 0;
	e.reload_time = 0;

	e.projectile_count = 0;
	e.spread = [0, 0, 0];
	e.func_attack = W_FireAxe;
	e.func_raise = shotgun_raise1;
	e.func_lower = shotgun_lower1;

	e.player_animation = player_shot1;

	e.killstring = "{0} chewed on {1}'s boomstick\n";

	return e;
}
