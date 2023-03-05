//call from combat.qc
void spawnDamageCounters(vector org, float dam)
{
	//gnounc
	entity dcount;

	dcount = spawn();

	setsize (dcount, '0 0 0', '32 32 32');
	setorigin(dcount, org);
	setmodel(dcount, "*damageCounter");

	dcount.frame = dam;
	
	dcount.movetype = MOVETYPE_TOSS;
	dcount.solid = SOLID_NOT;	

	dcount.velocity_z = 300;
	dcount.velocity_x = -100 + (random() * 200);
	dcount.velocity_y = -100 + (random() * 200);

	dcount.nextthink = time + 1;
	dcount.think = SUB_Remove;
}