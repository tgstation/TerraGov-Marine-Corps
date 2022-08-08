
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

/obj/item/weapon/melee_attack_chain(mob/user, atom/target, params, rightclick)
	if(target == user && !user.do_self_harm)
		return
	else
		return ..()
