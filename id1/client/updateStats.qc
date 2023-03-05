void updateStats() = 
{

	player_origin = [getstatf(36), getstatf(37), getstatf(38)];
/*
	player.origin_x = getstatf(36);//added in worldspawn as illustrated below
	player.origin_y = getstatf(37);//added in worldspawn as illustrated below
	player.origin_z = getstatf(38);//added in worldspawn as illustrated below
*/

/*		///////////ssqc////////////
	/////////goes in worldspawn//////////
	globalstat(34,AS_STRING, "surname");
	clientstat(36,AS_FLOAT_TRUNCATED, armortype);
	/////////////////////////////////////

	////goes right here/////////
	armortype = getstati(36);//added in worldspawn as illustrated above
	surname = getstats(34);//added in worldspawn as illustrated above	
	health = getstati(STAT_HEALTH);//predefined in csplat as illustrated below
	///////////////////////////

	///for reference////
	(from csplat.qc)

	#define STAT_HEALTH 0
	#define STAT_WEAPON 2
	#define STAT_AMMO 3
	#define STAT_ARMOR 4
	#define STAT_WEAPONFRAME 5
	#define STAT_SHELLS 6
	#define STAT_NAILS 7
	#define STAT_ROCKETS 8
	#define STAT_CELLS 9
	#define STAT_ACTIVEWEAPON 10
	#define STAT_TOTALSECRETS 11
	#define STAT_TOTALMONSTERS 12
	#define STAT_SECRETS 13
	#define STAT_MONSTERS 14
	#define STAT_ITEMS 15
	#define STAT_VIEWHEIGHT 16
	#define STAT_VIEW2 20
	#define STAT_VIEWZOOM 21
*/
};
