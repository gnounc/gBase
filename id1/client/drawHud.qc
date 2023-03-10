
void drawHud()
{
	drawObjectiveMarkers();
	drawDamageCounters();

	drawpic('100 100', "data/player/health.jpeg", '32 32', '1 1 1', 1, 0);
	drawstring('170 100', ftos(health), '8 8', '1 1 1', 1, 0);

	drawpic('100 150', strcat("data/player/armor_", ftos(armortype*10), ".png"), '32 32', '1 1 1', 1, 0);
	drawstring('170 150', ftos(armorvalue), '8 8', '1 1 1', 1, 0);
	drawstring('100 150', ftos(armortype), '8 8', '1 1 1', 1, 0);

	drawpic('100 200', strcat("data/player/ammo_", ftos(ammo_type), ".png"), '32 32', '1 1 1', 1, 0);
	drawstring('170 200', ftos(currentammo), '8 8', '1 1 1', 1, 0);
	drawstring('100 200', ftos(ammo_type), '8 8', '1 1 1', 1, 0);

}