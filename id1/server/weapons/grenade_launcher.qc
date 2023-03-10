
void() GrenadeTouch;
void() GrenadeExplode;
void() W_FireGrenade;

entity e_grenade_launcher()
{
	entity e = create_e_weapon("grenade_launcher", "rockets");

	e.kick = 2;
	e.attack_time = 0.5;

	e.ammo_max = 2;
	e.currentammo = 2;
	e.ammo_consumption = 1;
	e.reload_amount = 1;
	e.reload_time = 0.6;

	e.projectile_count = 6;
	e.spread = [0.04, 0.04, 0];
	e.func_attack = W_FireGrenade;
	e.func_raise = shotgun_raise1;
	e.func_lower = shotgun_lower1;
	e.func_reload = shotgun_reload1;

	e.player_animation = player_shot1;
	e.killstring = "{0} eats {1}'s pineapple\n";
	e.gibstring = "{0} was gibbed by {1}'s grenade";
						
	return e;
}


void() W_FireGrenade =
{
	entity e_attacker = self.owner;
	entity e_weap = self;

	//for ai
	entity e_enemy = e_attacker.enemy; 

	entity missile;

	missile = spawn ();
	missile.owner = e_attacker;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors (e_attacker.v_angle);

	vector direction = '0 0 0';
	if (e_attacker.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;

	else
	{
		if(e_attacker.classname != "player")
		{
			direction = e_enemy.origin - e_enemy.velocity*0.2;
			direction = normalize (direction - e_attacker.origin);
		}
		else
		{
			direction = aim (e_weap, 100000);
		}

		missile.velocity = direction;
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
	// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, e_attacker.origin);
};