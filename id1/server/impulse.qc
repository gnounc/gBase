
//prototypes
void() W_ChangeWeapon;
void() CycleWeaponCommand;
void() CycleWeaponReverseCommand;
void() W_Reload;

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if(!self.impulse)
		return;

	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon ();
	
	switch(self.impulse)
	{
		case 10:
			CycleWeaponCommand ();
			break;
		case 12:
			CycleWeaponReverseCommand();
			break;
		case 20:
			entity oldself;
			oldself = self;
			self = self.e_weapon;
			
			W_Reload();
			
			self = oldself;
			break;
		default:
			break;
	}
		
	self.impulse = 0;
};