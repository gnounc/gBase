
.void(entity p) th_callback;

hashtable event_table;
void ktest1(entity p)
{
	if(p.enemy.classname != "player")
		return;

	p.enemy.velocity += '0 100 0';

	sprint(p.enemy, strcat("kills: ", ftos(p.enemy.frags), "\n"));
}

void ktest2(entity p)
{
	if(p.enemy.classname != "player")
		return;

	centerprint(p.enemy, "callback removed\n");

	unregisterCallback(ktest1, "event_killed");
}


void initEvents()
{
	event_table = hash_createtab(32, EV_FUNCTION);

	//register callbacks below
//	registerCallback(checkCheevies, "event_all");		//i think perhaps event_all isnt registering
}

//TODO: NOT A REAL METHOD. FAKE STUB.
__variant(hashtable table, string name, float idx) hash_remove
{
	//do nothing, fake stub
	return world;
}

//FIXME hash_remove does not exist, and hash_delete does not support an index
void unregisterCallback(void(entity p) event_cb, string s_event)
{
	//__variant
	float idx = 0;
	void(entity p) s_callback;
	s_callback = hash_get(event_table, s_event, world, EV_FUNCTION, idx);
	while(s_callback)
	{
		//can methods even be tested for equality??
		if(s_callback == event_cb)
		{
			hash_remove(event_table, s_event, idx);
			return;
		}
		s_callback = hash_get(event_table, s_event, world, EV_FUNCTION, idx);
		idx++;
	}	
}

void registerCallback(void(entity p) event_cb, string s_event)
{
	hash_add(event_table, s_event, event_cb, HASH_ADD|EV_FUNCTION);
}

void checkCallbacks(entity p, string s_event)
{
	//__variant
	float idx = 0;
	void(entity p) s_callback;
	s_callback = hash_get(event_table, s_event, world, EV_FUNCTION, idx);
	while(s_callback)
	{
		//wonder if i'll need to set a timer to space these calls out, so that i dont overload the engine
		s_callback(p);
		s_callback = hash_get(event_table, s_event, world, EV_FUNCTION, idx);
	}	
}

void listRegistered()
{
	//??
	//mayhaps keep a separate global string and just attack every string as its registered, and remove it as its unregistered
}
