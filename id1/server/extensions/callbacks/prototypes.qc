void initEvents();
void registerCallback(void(entity p) event_cb, string s_event);
void unregisterCallback(void(entity p) event_cb, string s_event);
void checkCallbacks(entity p, string s_event);

/*		Availabale Events
	
	event_mapend
	event_jump
	event_land
	event_killed
	event_damage
	event_heal
	event_weapon
	event_key
	event_sigil
	event_powerups
	event_gib
	event_multitrigger
	event_teleport
	event_skill
	event_attack
*/