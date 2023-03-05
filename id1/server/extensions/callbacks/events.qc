
.entity lnk, next;
.void(entity p) th_callback;

entity events;

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
	//register callbacks below
//	registerCallback(checkCheevies, "event_all");		//i think perhaps event_all isnt registering
}

void addTail(entity l)
{
	if(!events)
	{	
		events = l;
		return;
	}

	entity e, en;

	for(e = events; e.lnk; e = e.lnk)
	{
		if(e.classname == l.classname)
		{	//find tail
			en = e;
			while(en.next)
				en = en.next;

			//tack on new entity
			en.next = l;				
			return;
		}
	}

	//create new link
	e.lnk = l;
}

//ONLY FUNCTION REMAINING TO BE REWRITTEN!!!!!!!!!!!!!!!!!!!!!!!!!!!!
void unregisterCallback(void(entity p) event_cb, string s_event)
{
	entity e, l, prev_l, prev_e;
	e = l = prev_l = prev_e = world;

	for(e = events; e; e = e.next)
	{
		if(e.classname == s_event)
		{
			for(l = e; l; l = l.lnk)
			{
				if(l.th_callback == event_cb)
				{
					//if it has a next its top teir and has no previous link
					if(l.next)
					{
						l.lnk.next = l.next;	

						if(prev_e)
							prev_e.next = l.lnk;
						else
							events = l.lnk;
					}
					//if its not top tier, it has a previous link, but no previous entity
					else
					{
						prev_l.lnk = l.lnk;
					}

					remove(l);
				}

				prev_l = l;
			}
		}		
		prev_e = e;
	}
}

void registerCallback(void(entity p) event_cb, string s_event)
{
	entity e;
	e = spawn();
	e.th_callback = event_cb;
	e.classname = s_event;

	addTail(e);
}


void checkCallbacks(entity p, string s_event)
{
	entity e, l, osef;

	for(e = events; e; e = e.lnk)
	{
		if((e.classname == s_event) || (e.classname == "event_all"))
		{
			for(l = e; l; l = l.next)
			{
				osef = self;
				self = l;
//				self.th_callback(p, s_event);
				self = osef;
			}			
		}
	}
}

void listRegistered()
{
	entity e, l;
	for(e = events; e; e = e.lnk)
	{
		for(l = e; l; l = l.next)
		{
			bprint(e.classname);
		}			
			bprint("\n");
	}
}

