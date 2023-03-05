
void() barrel_explode;


void killTest(entity p)
{		
	p.velocity = p.velocity + '0 0 1000';
}


void killTest2(entity p)
{
	p = p.enemy;
	if(p.classname != "player")
		return;
	
	p.velocity = p.velocity + '0 0 1000';

	centerprint(p, "Killtest2 Removed\n");

	unregisterCallback(killTest2, EVENT_KILLED);
}
