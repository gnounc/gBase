/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void() FireBullets =
{
	entity e_attacker = self.owner;
	entity e_weap = self;

	//for ai
	entity e_enemy = e_attacker.enemy; 

	bprint(strcat(e_attacker.classname, " fired the ", e_weap.classname, "\n"));

	makevectors(e_attacker.v_angle);

	vector src = e_attacker.origin + v_forward*10;
	src_z = e_attacker.absmin_z + e_attacker.size_z * 0.7;

	vector direction = '0 0 0';
	if(e_attacker.classname != "player")
	{
		direction = e_enemy.origin - e_enemy.velocity*0.2;
		direction = normalize (direction - e_attacker.origin);
	}
	else
	{
		direction = aim (e_attacker, 100000);
	}


	ClearMultiDamage ();
	float shotcount = 0;
	while (e_weap.projectile_count > shotcount)
	{
		direction += crandom()*e_weap.spread_x*v_right + crandom()*e_weap.spread_y*v_up;
		
		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount++;
	}

	sound (e_weap, CHAN_WEAPON, e_weap.attack_sound, 1, ATTN_NORM);	
	ApplyMultiDamage ();
};
