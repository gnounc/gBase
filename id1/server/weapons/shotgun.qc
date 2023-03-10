
$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6 shotatt7 shotatt8 shotatt9 shotatt10
$frame shotraise1 shotraise2 shotraise3 shotraise4 shotraise5

void()	shotgun_attack1 =	[$shotatt1, shotgun_attack2	] {self.weaponframe=1; self.owner.effects |= self.owner.effects | EF_MUZZLEFLASH; self.nextthink = time + 0.05;};
void()	shotgun_attack2 =	[$shotatt2, shotgun_attack3	] {self.weaponframe=2; self.nextthink = time + 0.05;};
void()	shotgun_attack3 =	[$shotatt3, shotgun_attack4	] {self.weaponframe=3; self.nextthink = time + 0.05;};
void()	shotgun_attack4 =	[$shotatt4, shotgun_attack5	] {self.weaponframe=4; self.nextthink = time + 0.05;};
void()	shotgun_attack5 =	[$shotatt5, shotgun_attack6	] {self.weaponframe=5; self.nextthink = time + 0.05;};
void()	shotgun_attack6 =	[$shotatt6, shotgun_attack7	] {self.weaponframe=6; self.nextthink = time + 0.05;};
void()	shotgun_attack7 =	[$shotatt7, shotgun_attack8	] {self.weaponframe=7; self.nextthink = time + 0.05;};
void()	shotgun_attack8 =	[$shotatt8, shotgun_attack8	] {self.weaponframe=8; self.nextthink = time + 0.05;};
void()	shotgun_attack9 =	[$shotatt9, shotgun_attack9	] {self.weaponframe=9; self.nextthink = time + 0.05;};
void()	shotgun_attack10 =	[$shotatt10, player_run		] {self.weaponframe=10; self.nextthink = time + 0.05;};
	
void()	shotgun_lower1 =	[$shotraise5, shotgun_lower2	] {bprint(strcat("lower: ", self.classname, "\n")); self.weaponframe=15; self.nextthink = time + 0.05; self.attack_finished = time + 0.5; sound (self, CHAN_AUTO, "items/armor1.wav", 1, ATTN_NORM);};
void()	shotgun_lower2 =	[$shotraise4, shotgun_lower3	] {self.weaponframe=14; self.nextthink = time + 0.05;};
void()	shotgun_lower3 =	[$shotraise3, player_run		] {self.weaponframe=13; self.nextthink = time + 0.05;};

void()	shotgun_raise1 =	[$shotraise1, shotgun_raise2	] {self.weaponframe=11; self.nextthink = time + 0.05; self.attack_finished = time + 0.5; sound (self, CHAN_AUTO, "weapons/super_raise.wav", 1, ATTN_NORM);};
void()	shotgun_raise2 =	[$shotraise2, shotgun_raise3	] {self.weaponframe=12; self.nextthink = time + 0.05;};
void()	shotgun_raise3 =	[$shotraise3, shotgun_raise4	] {self.weaponframe=13; self.nextthink = time + 0.05;};
void()	shotgun_raise4 =	[$shotraise4, shotgun_raise5	] {self.weaponframe=14; self.nextthink = time + 0.05;};
void()	shotgun_raise5 =	[$shotraise5, player_run	 	] {self.weaponframe=15; self.nextthink = time + 0.05;};
	
void()	shotgun_reload1 =	[$shotraise1, shotgun_reload2	] {self.owner.weaponframe=12;}
void()	shotgun_reload2 =	[$shotraise3, shotgun_reload3	] {self.owner.weaponframe=13;}
void()	shotgun_reload3 =	[$shotraise1, player_run		] {self.owner.weaponframe=12;}

entity e_shotgun()
{
	entity e = create_e_weapon("shotgun", "shells");

	e.kick = 2;
	e.attack_time = 0.5;

	e.ammo_max = 12;
	e.currentammo = 4;
	e.ammo_consumption = 1;
	e.reload_amount = 1;
	e.reload_time = 0.6;

	e.projectile_count = 6;
	e.spread = [0.04, 0.04, 0];
	e.func_attack = FireBullets;
	e.func_raise = shotgun_raise1;
	e.func_lower = shotgun_lower1;
	e.func_reload = shotgun_reload1;

	e.player_animation = player_shot1;
	e.killstring = "{0} chewed on {1}'s boomstick\n";

	return e;
}

