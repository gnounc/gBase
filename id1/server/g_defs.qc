.float cheated;

//weapons

.hashtable inventory;

.entity e_weapon;
.entity e_armor;
.entity e_powerup;

.string ammo_type;

.void() func_attack;
.void() func_melee_attack;
.void() func_reload;
.void() func_raise;
.void() func_lower;
.float(entity targ, entity inflictor, entity attacker, float damage) func_armor;


.vector spread;
.float projectile_count;
.float attack_type;

.float reload_time;
.float reload_amount;
.float reload_finished;	//so we can interrupt reloads without it becoming exploitable

.string projectile_model;

.float kick;

.float ammo_max;
.float ammo_consumption;


//.string killstring; in normal defs.
.string underwater_killstring;
.string gibstring;
.string quad_gibstring;
.string quad_gibstring2;
.string quad_gibstring3;

.string pickup_model;

.string pickup_sound;
.string attack_sound;
.string empty_sound;
.string raise_sound;
.string lower_sound;
.string reload_sound;

.string hud_icon;

.float attack_time;

.void()	player_animation;

void(float num, float type, .__variant fld) clientstat = #232;
void(float num, float type, string name) globalstat = #233;

const float AS_STRING 			= 1;
const float AS_FLOAT_TRUNCATED 	= 2; // int value
const float AS_FLOAT			= 8;


const float SVC_CGAMEPACKET = 83;
const float MSG_BROADCAST = 0;
const float MSG_ONE = 1;
const float MSG_ALL = 2;
const float MSG_INIT = 3;
const float MSG_MULTICAST = 4;
const float MSG_ENTITY = 5;
const float MULTICAST_ALL = 0;
const float MULTICAST_PHS = 1;
const float MULTICAST_PVS = 2;
const float MULTICAST_ONE = 6;
const float MULTICAST_ALL_R = 3;
const float MULTICAST_PHS_R = 4;
const float MULTICAST_PVS_R = 5;
const float MULTICAST_ONE_R = 7;

void(float to, float val) WriteByte = #52; /*
		Writes a single byte into a network message buffer. Typically you will find a more correct alternative to writing arbitary data. 'to' should be one of the MSG_* constants. MSG_ONE must have msg_entity set first. */

void(float to, float val) WriteChar = #53;
void(float to, float val) WriteShort = #54;
void(float to, float val) WriteLong = #55;
void(float to, float val) WriteCoord = #56;
void(float to, float val) WriteAngle = #57;
void(float to, string val) WriteString = #58;
void(float to, entity val) WriteEntity = #59;
void(vector where, float set) multicast = #82;

float(float value, float exp) pow = #97; /* Part of DP_QC_SINCOSSQRTPOW*/

.float healamount, healtype;	//moved from above healthpacks in items.qc --gnounc
string nextmap;	//moved from client
