void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self.owner;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	entity e_attacker = self.owner;
	entity e_weap = self;

	//for ai
	entity e_enemy = e_attacker.enemy; 
	
	vector direction = '0 0 0';
	vector org = e_attacker.origin + '0 0 16';
	if(e_attacker.classname != "player")
	{
		direction = e_enemy.origin - e_enemy.velocity*0.2;
		direction = normalize (direction - e_attacker.origin);

		//bug: this doesnt seem to work, maybe its not the problem?
		//push spike out a little farther to be outside the shooters bbox
		org += direction*32;
	}
	else
	{
		direction = aim (e_weap, 1000);
	}

	launch_spike (org, direction);
	newmis.classname = "super_spike";	//so we know the difference --gnounc
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
};

void() W_FireSpikes =
{
	entity e_attacker = self.owner;
	entity e_weap = self;

	//for ai
	entity e_enemy = e_attacker.enemy; 
	
	makevectors (e_attacker.v_angle);
	
	vector direction = '0 0 0';
	vector org = e_attacker.origin + '0 0 16';
	if(e_attacker.classname != "player")
	{
		direction = e_enemy.origin - e_enemy.velocity*0.2;
		direction = normalize (direction - e_attacker.origin);

		//bug: this doesnt seem to work, maybe its not the problem?
		//push spike out a little farther to be outside the shooters bbox
		org += direction*32;
	}
	else
	{
		direction = aim (e_weap, 1000);
	}

	launch_spike (org + direction*(mod(e_weap.currentammo, 2)? 4 : -4), direction);
};

void() spike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9);
	}

	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizard_spike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);

		else if (self.classname == "knight_spike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);

		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);

		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};