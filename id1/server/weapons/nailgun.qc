

entity e_nailgun()
{
	entity e = create_e_weapon("nailgun", "nails");

	e.kick = 2;
	e.attack_time = 0.5;

	e.currentammo = 4;
	e.ammo_max = 40;
	e.ammo_consumption = 1;
	e.reload_amount = 40;
	e.reload_time = 0.6;

	e.projectile_count = 6;
	e.spread = [0.04, 0.04, 0];
	e.func_attack = W_FireSpikes;
	e.func_raise = shotgun_raise1;
	e.func_lower = shotgun_lower1;
	e.func_reload = shotgun_reload1;
	e.func_reload = shotgun_reload1;

	e.player_animation = player_shot1;
	e.killstring = "{0} was nailed by {1}\n";

	return e;
}

