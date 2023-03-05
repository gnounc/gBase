
//the one limitation of the callback stylizer, is that i cant move elements
//or resize them. otherwise the clickhandler will not know the proper bounds.
//moving click handler into the style callback ruins the implied ownership and flow, so its not allowed.
void drawList(vector pos, string list, void(vector pos, vector sz, string item, float idx, void(float idx) clickCallback) styleCallback, void(float idx) clickCallback)
{

	string item;
	vector sz;
	float idx, listLength, listWidth;

	listWidth = longestString(list);
	listLength = tokenizebyseparator(list, ";");

	sz = [listWidth*15, 17];

	drawfill(pos, [(listWidth*15) + 2, (listLength*20) + 2], '0.3 0.3 0.3', 1, 0);

	for(idx = 0; (item = argv(idx)); idx++)
	{
		pos_y += 17;
	
		styleCallback(pos, sz, item, idx, clickCallback);
	}
}

//create a different style handler function
//say MainMenuStyle
//to stylize the individual items drawstrings and drawfills
//think css
void listStyleHandler(vector pos, vector sz, string item, float idx, void(float idx) clickCallback)
{
	vector altcolor, oddcolor, evencolor, selectcolor;

	oddcolor = '0.3 0.3 0.3';
	evencolor = '0.6 0.6 0.6';
	selectcolor = '1 0 0';

	altcolor = mod(idx,2) ? oddcolor : evencolor;

	if(pointInBounds(mpos, pos, sz))
	{
		altcolor = selectcolor;
		clickCallback(idx);
	}

	drawfill(pos, sz, altcolor, 1, 0);
	drawstring(pos + '1 1', item, '15 15', '1 1 1', 1, 0);
}

//create a different click handler function
//say MainMenuClicks
//to tell the list what functions shoudl be associated with clicking which list item
void listClickHandler(float idx)
{
//		cprint(("click handled: "), ftos(idx));

	if(!(mButton & LMB))
		return;

	mButton -= LMB;

	switch(idx)
	{
		case 0:
			cprint("you clicked zee row");
			break;
		case 1:
			cprint("you clicked juan");
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
	}
}