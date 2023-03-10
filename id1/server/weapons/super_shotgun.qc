

entity e_super_shotgun()
{
	entity e = create_e_weapon("super_shotgun", "shells");

	e.kick = 4;
	e.attack_time = 0.5;

	e.ammo_max = 2;
	e.currentammo = 2;
	e.ammo_consumption = 2;
	e.reload_amount = 2;
	e.reload_time = 0.9;

	e.projectile_count = 14;
	e.spread = [0.14, 0.08, 0];
	e.func_attack = FireBullets;
	e.func_raise = shotgun_raise1;
	e.func_lower = shotgun_lower1;
	e.func_reload = shotgun_reload1;

	e.player_animation = player_shot1;
	e.killstring = "{0} ate 2 loads of {1}'s buckshot\n";

	return e;
}

