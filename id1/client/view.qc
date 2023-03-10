// CSQC_UpdateView - Called every rendered frame on the client.  Useful for HUD drawing operations.


void CSQC_UpdateView(float vwidth, float vheight, float notmenu)
{
	screen_size = screen_center = '0 0 0';//prevent noref warning
	screen_size_x = vwidth;
	screen_size_y = vheight;

	screen_center_x = screen_size_x/2;
	screen_center_y = screen_size_y/2;

	// ALWAYS Clear Current Scene First
	clearscene();

	setviewprop(VF_DRAWWORLD, 1);
	setviewprop(VF_DRAWCROSSHAIR, 1);
	setviewprop(VF_DRAWENGINESBAR, 1);

	// Setup Entities to be Rendered (include all base types; normal, engine and viewmodels)
	addentities(MASK_ENGINE | MASK_VIEWMODEL);
	
	// Render the Scene
	renderscene();

	updateStats();


//trying to get this to only show when loading a map :/
	//probably need to stall the game for a bit to show the splashscreen too

		drawfill([screen_size_x - 200, screen_size_y - 40], [117/2, 48/2], '0 0 0', 0.8, 0);
		drawpic([screen_size_x - 200, screen_size_y - 40], "data/gbase.png", [117/2, 48/2], '1 1 1', 0.8, 0);
	
	drawHud();
}
