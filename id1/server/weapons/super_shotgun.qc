
/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0');
};
