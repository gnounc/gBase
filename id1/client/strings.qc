
string getSbarImg(float it_num)
{
	switch(it_num)
	{
		case IT_SHOTGUN:
			return "inv_shotgun";
		case IT_SUPER_SHOTGUN:
			return  "inv_sshotgun";
		case IT_NAILGUN:
			return  "inv_nailgun";
		case IT_SUPER_NAILGUN:
			return  "inv_sshotgun";
		case IT_GRENADE_LAUNCHER:
			return  "inv_rlaunch";
		case IT_ROCKET_LAUNCHER:
			return  "inv_srlaunch";
		case IT_LIGHTNING:
			return  "inv_lightng";
		case IT_ARMOR1:
			return  "sb_armor1";
		case IT_ARMOR2:
			return  "sb_armor2";
		case IT_ARMOR3:
			return  "sb_armor3";
		case IT_SHELLS:
			return  "sb_shells";
		case IT_NAILS:
			return  "sb_nails";
		case IT_ROCKETS:
			return  "sb_rocket";
		case IT_CELLS:
			return  "sb_cells";
		case IT_KEY1:
			return  "sb_key1";
		case IT_KEY2:
			return  "sb_key2";
		case IT_INVISIBILITY:
			return  "sb_invis";
		case IT_INVULNERABILITY:
			return  "sb_invuln";
		case IT_SUIT:
			return  "sb_suit";
		case IT_QUAD:
			return  "sb_quad";
		default:
			return "";
/*
		case :
			return  "sbar";
		case :
			return  "scorebar";
		case :
			return  "sb_sigil1";
		case :
			return  "sb_sigil2";
		case :
			return  "sb_sigil3";
		case :
			return  "sb_sigil4";
*/
	}
}

float longestString(string list)
{
	tokenizebyseparator(list, ";");

	string item, longest;
	float idx, longestLength;

	longest = "";
	longestLength = 0;

	for(idx = 0; (item = argv(idx)); idx++)
	{
		if(strlen(argv(idx)) > strlen(longest))
		{
			longest = argv(idx);
			longestLength = strlen(longest);
		}
	}
	return longestLength;
}