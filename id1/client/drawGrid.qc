void drawGrid(vector pos, float width, float rowWidth, float itemCount, void(vector pos, vector sz, float idx, void(float idx) clickCallback) styleCallback, void(float idx) clickCallback)
{
	vector size, padding;

	size = [width, width];
	padding = '10 10';

	float idx;
	float x, y;


	idx = 0;
	for(y = 0;; y++)
	{
		for(x = 0; x < rowWidth; idx++, x++)
		{
			if(idx > itemCount)
				return;

			styleCallback([pos_x + ((size_x + padding_x)*(x)), pos_y + ((size_y + padding_y)*(y))], size, idx, clickCallback);
		}
	}
}

void gridStyleHandler(vector pos, vector sz, float idx, void(float idx) clickCallback)
{
	string list;	//going to have to pull from a global or somethin
	list = "";

//	string tileInfo;
	vector altcolor, oddcolor, evencolor, selectcolor;
	string pic, desc, qty;

	oddcolor = '0.3 0.3 0.3';
	evencolor = '0.6 0.6 0.6';
	selectcolor = '1 0 0';

	altcolor = mod(idx,2) ? oddcolor : evencolor;
	tokenizebyseparator(list, ";");
	tokenizebyseparator(argv(idx), ",");

//	tileInfo = argv(idx);
//	pic = strcat("gfx/inventory/", argv(0));
	pic = strcat(argv(0));
	desc = argv(1);
	qty = argv(2);


	if(pointInBounds(mpos, pos, pos+sz))
	{
		altcolor = selectcolor;

		hovertext = desc;
//		hovertext = argv(idx);
		clickCallback(idx);
	}

	drawfill(pos, sz, altcolor, 1, 0);
	drawpic([pos_x + 1.5, pos_y + 1.5], pic, [sz_x -3, sz_y - 3], altcolor, 1, 0);	

	drawstring(pos + '1 1', ftos(idx), '15 15', '1 1 1', 1, 0);
	drawstring(pos + '10 10', qty, '15 15', '1 1 1', 1, 0);

}


void gridClickHandler(float idx)
{
	//if click
	if((mButton & LMB))
	{
		mButton -= LMB;

		switch(idx)
		{
			case 0:
//				sendInventory(EV_INVENTORY_ADD, 10, 11, 12);
				break;
			case 1:
//				sendInventory(EV_INVENTORY_REMOVE, 10, 11, 12);
				break;
			case 2:
			case 3:
			case 4:
				cprint("you clicked ducks or more");
				break;
			case 5:
				cprint("cheat activated");
				localcmd("impulse 9");
				break;
			default:
				cprint("the rest all say the same thing");
				break;
		}
	}
	//dragOver and dropOver will require more finesse

}