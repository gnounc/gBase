#define USE_CSQC_OPTIONALFUNCTIONS true

// --------------------------------------------------------------------------
// BEGIN REQUIRED CSQC FUNCTIONS

// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	//list of items that are currently being considered objective markers

	deltalisten("progs/missile.mdl", objective_delta_listen, 0);
	deltalisten("progs/k_spike.mdl", objective_delta_listen, 0);
	deltalisten("progs/soldier.mdl", objective_delta_listen, 0);
	deltalisten("progs/dog.mdl", objective_delta_listen, 0);
	deltalisten("*damageCounter", damagecounter_delta_listen, 0);
	
}
// CSQC_Shutdown : Called every time the CSQC code is shutdown (changing maps, quitting, etc)
void CSQC_Shutdown(void)
{
}

/*
	eventtype: 					0 = key down, 1 = key up, 2 = mouse move delta, 
								3 = mouse move absolute, 4 = accelerometer

	scancode: 					/ mouse x / accelerator x
	unicode(character code):  	/ mouse y / accelerometer y
	key device id:			 	/ mouse device id / accelerometer z
*/

// CSQC_InputEvent : Used to perform actions based on any key pressed or released by the client.
// Return value should be 1 if CSQC handled the key press, otherwise return 0 to have the key passed to the engine.
float CSQC_InputEvent(float eventType, float scanCode, float unicode, float deviceID)
{
	float f_SkipKey;

	f_SkipKey = FALSE;

	switch(eventType)
	{
		case IE_KEYDOWN:
			switch(scanCode)
			{
				case K_MOUSE1:
					mButton |= LMB;
					break;

				case K_MOUSE2:
					mButton |= RMB;
					break;

				case K_MOUSE3:
					mButton |= MMB;
					break;

				case K_ESCAPE:	//dont fuck with the menu buttons. kthx
					f_SkipKey =FALSE;
					break;

				case K_ENTER:	//dont fuck with the menu buttons. kthx
					f_SkipKey = FALSE;	
					break;

				case K_TAB:
					break;

				default:
					break;
			}
			break;

		case IE_KEYUP:
			switch(scanCode)
			{
				case K_TAB:
					break;

				case K_MOUSE1:
					mButton -= LMB;
					break;

				case K_MOUSE2:
					mButton -= RMB;
					break;

				case K_MOUSE3:
					mButton -= MMB;
					break;

				default:
					break;
			}
			break;

		case IE_MOUSEDELTA:

			vector oldmpos = mpos;

			mpos_x += scanCode;
			mpos_y += unicode;			
			mpos_z = deviceID;	//doesnt actually do anything

			//clamp mouse to screen
			if(!(pointInBounds(mpos, '0 0', screen_size)))
				mpos = oldmpos;

		case IE_MOUSEABS:
			break;

		//not sure if this is a delta. i imagine it is. if not change that from += to just =
		case IE_ACCELEROMETER:
			accel_x += scanCode;
			accel_y += unicode;
			accel_z += deviceID;
			break;

		case IE_FOCUS:
			break;

		case IE_JOYAXIS:
			break;

		default:
			break;
	}

	return f_SkipKey;
}

