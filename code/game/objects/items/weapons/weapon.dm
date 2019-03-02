
//items designed as weapon
/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/items/weapons.dmi'
	hitsound = "swing_hit"
	var/caliber = "missing from codex" //codex
	var/load_method = null //codex, defines are below.
	var/max_shells = 0 //codex, bullets, shotgun shells
	var/max_shots = 0 //codex, energy weapons
	var/scope_zoom = FALSE//codex
	var/self_recharge = FALSE //codex

#define SINGLE_CASING	(1 << 0)
#define SPEEDLOADER		(1 << 1)
#define MAGAZINE		(1 << 2)
#define CELL			(1 << 3)
#define POWERPACK		(1 << 4)
