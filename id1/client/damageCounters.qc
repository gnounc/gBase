//relies on deltalisten set in client main.qc
//which relies on the server creating entities in combat.qc and setting mdl to *damageCounters 
//the *name means its an empty, its still precached serverside in world.qc though

float damagecounter_delta_listen(float isNew)
{
	if(isNew)
	{
		self.classname = "damagecounter";
	}

	self.visible = time + 0.2;
	return TRUE;
}

void drawDamageCounters()
{
	entity e;

	float idx;
	idx = 0;
	for(e = find(world, classname, "damagecounter"); e; e = nextent(e))
	{
		if(e.classname != "damagecounter")
			continue;
		
		drawstring(project(e.origin), ftos(e.frame) , '15 15', '0 1 0', 1, 0);
		idx++;
	}
}