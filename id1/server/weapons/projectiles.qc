
void() GrenadeTouch;
void() GrenadeExplode;
void() spike_touch;

entity create_projectile(string s_classname, float f_lifetime, void() func_touch)
{
	string basepath = strcat("data/projectiles/", s_classname,"/");
	precache_model (strcat(basepath, "view_model.mdl"));

	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = s_classname;

	makevectors (self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.angles = vectoangles(missile.velocity);

	missile.touch = func_touch;
	
	if(f_lifetime)
	{
		missile.nextthink = time + f_lifetime;
		missile.think = SUB_Remove;		
	}

	setmodel (missile, strcat(basepath,"view_model.mdl"));
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');

	return missile;
}


void spike()
{
	entity missile = create_projectile("spike", 0, spike_touch);
	
	missile.velocity = missile.velocity * 1000;
}

void grenade()
{
	entity missile = create_projectile("grenade", 2.5, GrenadeTouch);

	if (self.v_angle_x)
	{
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	}

	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;
}

void missile()
{
	entity missile = create_projectile("missile", 5, T_MissileTouch);
	
	missile.velocity = missile.velocity * 1000;
	setsize (missile, VEC_ORIGIN, VEC_ORIGIN);		

}

