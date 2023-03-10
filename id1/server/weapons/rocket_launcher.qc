
void() W_FireRocket 

entity e_rocket_launcher()
{
	entity e = create_e_weapon("rocket_launcher", "rockets");

	e.kick = 2;
	e.attack_time = 0.5;

	e.ammo_max = 8;
	e.currentammo = 4;
	e.ammo_consumption = 1;
	e.reload_amount = 1;
	e.reload_time = 0.6;

	e.projectile_count = 6;
	e.spread = [0.04, 0.04, 0];
	e.func_attack = W_FireRocket;
	e.func_raise = shotgun_raise1;
	e.func_lower = shotgun_lower1;
	e.func_reload = shotgun_reload1;

	e.player_animation = player_shot1;

	e.killstring = "{0} rids {1}'s rocket\n";
	e.gibstring = "{0} was gibbed by {1}'s rocket\n";

	e.quad_gibstring = "{0} was brutalized by {1}'s quad rocket\n";
	e.quad_gibstring2 = "{0} was smeared by {1}'s quad rocket\n";
	e.quad_gibstring3 = "{0} rips {1} a new one\n";

						
	return e;
}


void() W_FireRocket =
{
	bprint("firerocket fired.\n");

	entity e_attacker = self.owner;
	entity e_weap = self;

	//for ai
	entity e_enemy = e_attacker.enemy; 

	entity missile;
		
	missile = spawn ();
	missile.owner = e_attacker;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
	// set missile speed	
	makevectors (e_attacker.v_angle);

	vector direction = '0 0 0';
	if(e_attacker.classname != "player")
	{
		direction = e_enemy.origin - e_enemy.velocity*0.2;
		direction = normalize (direction - e_attacker.origin);
	}
	else
	{
		direction = aim (e_weap, 1000);
	}

	missile.velocity = direction;
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = T_MissileTouch;
	
	// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, e_attacker.origin + v_forward*8 + '0 0 16');
};