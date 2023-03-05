#define OPTIMAL_DISTANCE 512

//relies on deltalisten set in client main.qc

//objectives show up directly behind you  when you're facing them.
//do a dotproduct and ignore the draw call if you arent facing it..or something.

float objective_delta_listen(float isNew)
{
	if(isNew)
	{
		self.classname = "objective";
	}

	self.visible = time + 0.2;
	return TRUE;
}

void drawObjectiveMarkers()
{
	entity e;

	for(e = find(world, classname, "objective"); e; e = nextent(e))
	{

		if(e.classname != "objective")
			continue;


		vector obj_size, obj_org, obj_color;
		string obj_message;

		obj_org = obj_size = obj_color = '0 0 0';//silence compiler warnings

		obj_org = screenClamp(project(e.origin));
		obj_size_x = 15* (OPTIMAL_DISTANCE / (vlen(player_origin - e.origin)));

		obj_message = strcat(ftos(floor(vlen(player_origin - e.origin)/28)), "m");

		//clamp objective drawstring size.
		if(obj_size_x > 24)
			obj_size_x = 24;

		if(obj_size_x < 6)
			obj_size_x = 6;

		obj_size_y = obj_size_x;

		obj_color = '1 1 1';

		//yellow to indicate medium range
		if (vlen(e.origin - player_origin) > 256)
			obj_color = '1 1 0';

		//red to indicate long range
		if (vlen(e.origin - player_origin) > 512)
			obj_color = '1 0 0';

		if(e.visible > time)
		{
			drawstring(obj_org + [(obj_size_x/2)*strlen(obj_message) - (obj_size_x/2), obj_size_y + 3], "^", obj_size, '1 1 1', 0.8, 0);
			drawstring(obj_org, obj_message, obj_size, obj_color, 0.8, 0);
		}
	}
}