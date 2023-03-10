
void add_inventory_item(entity player, entity item)
{
	//make items invisible, or theyll show up at worldspawn
	item.model = string_null;
	item.solid = SOLID_NOT;

	bprint(strcat(item.classname, " added to inventory.\n"));

	item.owner = player;
	hash_add(player.inventory, item.classname, item, HASH_REPLACE);
	sprint(player, strcat(item.classname, " added.\n"));
}

entity get_inventory_item(entity player, string classname)
{
	entity e = hash_get(player.inventory, classname, world, EV_ENTITY);
	if(e)
	{
		bprint(strcat(classname, " found in inventory.\n"));
	}
	return e;
}

//returns the deleted item, think pythons pop.
entity remove_inventory_item(entity player, string classname)
{
	bprint(strcat(classname, " removed from inventory.\n"));

	entity item = hash_delete(player.inventory, classname);
	item.owner = world;

	return item;
}

//note, weapons count as ammo containers, so this will pickup weapons.
//move ammo from a weapon or ammo_box, into the players inventory (either filling an existing ammobox, or taking the one that is being taken from)
//returns the ammocontainer. useful for selecting new weapons.
entity moveAmmo(entity e_player, entity ammoContainer)
{
	entity existing_ammobox = get_inventory_item(e_player, ammoContainer.classname);

	if(!existing_ammobox)
	{
		add_inventory_item(e_player, ammoContainer);
		bprint(strcat("inventory item ", ammoContainer.classname, " added.\n"));
		return ammoContainer;
	}
	else
	{
		//bail if you didnt even need ammo
		if(existing_ammobox.currentammo == existing_ammobox.ammo_max)
		{
			return existing_ammobox;
		}

		float take = existing_ammobox.ammo_max - existing_ammobox.currentammo;

		if(take >= ammoContainer.currentammo)
		{
			existing_ammobox.currentammo += take;
			ammoContainer.currentammo -= take;
		}
		else
		{
			existing_ammobox.currentammo += ammoContainer.currentammo;
			ammoContainer.currentammo = 0;
		}

		return existing_ammobox;
	}
}
