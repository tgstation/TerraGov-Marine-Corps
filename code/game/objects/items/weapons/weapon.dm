//items designed as weapon
/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/items/weapons/misc.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/melee_right.dmi',
	)
	hitsound = SFX_SWING_HIT
	var/caliber = "missing from codex" //codex
	var/load_method = null //codex, defines are below.
	var/max_shells = 0 //codex, bullets, shotgun shells TODO: KILL THESE TWO VARS
	var/max_shots = 0 //codex, energy weapons
	var/scope_zoom = FALSE//codex
	var/self_recharge = FALSE //codex

/obj/item/weapon/melee_attack_chain(mob/user, atom/target, params, rightclick)
	if(target == user && !user.do_self_harm)
		return
	return ..()

/obj/item/weapon/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if((item_flags & WIELDED))
		return
	var/obj/item/weapon/gun/offhand_gun = (user.r_hand == src ? user.l_hand : user.r_hand)
	if(!istype(offhand_gun))
		return
	var/list/modifiers = params2list(click_parameters)
	modifiers -= "right"
	click_parameters = list2params(modifiers)
	offhand_gun.start_fire(null, src, target, null, click_parameters, TRUE)
