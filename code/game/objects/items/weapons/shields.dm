/obj/item/weapon/shield
	name = "shield"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/shields_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/shields_right.dmi',
	)

/obj/item/weapon/shield/Initialize(mapload)
	. = ..()
	set_shield()

/obj/item/weapon/shield/proc/set_shield()
	AddComponent(/datum/component/shield, SHIELD_PARENT_INTEGRITY, shield_cover = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 80, BIO = 30, FIRE = 50, ACID = 80))
	AddComponent(/datum/component/stun_mitigation)

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "riot"
	max_integrity = 200
	flags_item = IMPEDE_JETPACK
	flags_equip_slot = ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("shoved", "bashed")
	soft_armor = list(MELEE = 40, BULLET = 20, LASER = 0, ENERGY = 70, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	hard_armor = list(MELEE = 5, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	hit_sound = 'sound/effects/grillehit.ogg'
	destroy_sound = 'sound/effects/glassbr3.ogg'
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/examine(mob/user, distance, infix, suffix)
	. = ..()
	var/health_status = (obj_integrity-integrity_failure) * 100 / (max_integrity-integrity_failure)
	if(integrity_failure && obj_integrity <= integrity_failure)
		. += span_notice("It's completely broken, with gaping holes everywhere!")
		return
	switch(health_status)
		if(0 to 20)
			. += span_notice("It's falling apart under its own weight!")
		if(20 to 40)
			. += span_notice("It's barely holding its shape.")
		if(40 to 60)
			. += span_notice("It's still holding up.")
		if(60 to 80)
			. += span_notice("It's slightly damaged.")
		if(80 to 100)
			. += span_notice("It's in perfect condition.")

/obj/item/weapon/shield/riot/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/metal_sheets = I
		if(obj_integrity > integrity_failure)
			return

		if(metal_sheets.get_amount() < 1)
			to_chat(user, span_warning("You need one metal sheet to restore the structural integrity of [src]."))
			return

		visible_message(span_notice("[user] begins to restore the structural integrity of [src]."))

		if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return

		if(!metal_sheets.use(1))
			return

		repair_damage(max_integrity * 0.2, user)
		visible_message(span_notice("[user] restores the structural integrity of [src]."))

	else if(istype(I, /obj/item/weapon) && world.time >= cooldown)
		user.visible_message(span_warning("[user] bashes [src] with [I]!"))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 25, 1)
		cooldown = world.time + 2.5 SECONDS


/obj/item/weapon/shield/riot/welder_act(mob/living/user, obj/item/I)
	. = welder_repair_act(user, I, max_integrity * 0.15, 4 SECONDS, integrity_failure / max_integrity, SKILL_ENGINEER_METAL)
	if(. == BELOW_INTEGRITY_THRESHOLD)
		balloon_alert(user, "Too damaged. Use metal sheets.")


/obj/item/weapon/shield/riot/marine
	name = "\improper TL-172 defensive shield"
	desc = "A heavy shield adept at blocking blunt or sharp objects from connecting with the shield wielder. Looks very robust. Alt click to tighten the strap."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "marine_shield"
	flags_equip_slot = ITEM_SLOT_BACK
	max_integrity = 400
	integrity_failure = 100
	soft_armor = list(MELEE = 40, BULLET = 50, LASER = 20, ENERGY = 70, BOMB = 15, BIO = 50, FIRE = 0, ACID = 30)
	hard_armor = list(MELEE = 0, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	force = 20
	slowdown = 0.5

/obj/item/weapon/shield/riot/marine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)

/obj/item/weapon/shield/riot/marine/update_icon_state()
	if(obj_integrity <= integrity_failure)
		icon_state = initial(icon_state) + "_broken"
	else
		icon_state = initial(icon_state)


	if(!isliving(loc))
		return
	var/mob/living/holder = loc
	if(holder.l_hand == src)
		holder.update_inv_l_hand()
		return
	if(holder.r_hand == src)
		holder.update_inv_r_hand()
		return
	holder.update_inv_back()

/obj/item/weapon/shield/riot/marine/metal
	icon_state = "riot_metal"

/obj/item/weapon/shield/riot/marine/som
	name = "\improper S-144 boarding shield"
	desc = "A robust, heavy shield designed to be shot instead of the person holding it. Commonly employed by the SOM during boarding actions and other close quarter combat scenarios. This one has a SOM flag emblazoned on the front. Alt click to tighten the strap."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "som_shield"
	soft_armor = list(MELEE = 35, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, BIO = 50, FIRE = 0, ACID = 15)

//A shield that can be deployed as a barricade
/obj/item/weapon/shield/riot/marine/deployable
	name = "\improper TL-182 deployable shield"
	desc = "A compact shield adept at blocking blunt or sharp objects from connecting with the shield wielder. Can be deployed as a barricade. Alt click to tighten the strap."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "folding_shield"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	integrity_failure = 50
	soft_armor = list(MELEE = 35, BULLET = 30, LASER = 20, ENERGY = 40, BOMB = 25, BIO = 50, FIRE = 0, ACID = 30)
	slowdown = 0.3
	flags_item = IS_DEPLOYABLE
	///The item this deploys into
	var/deployable_item = /obj/structure/barricade/metal/deployable
	///Time to deploy
	var/deploy_time = 1 SECONDS
	///Time to undeploy
	var/undeploy_time = 1 SECONDS
	///Whether it is wired
	var/is_wired = FALSE

/obj/item/weapon/shield/riot/marine/deployable/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, deploy_time, undeploy_time)

/obj/item/weapon/shield/riot/marine/deployable/set_shield()
	AddComponent(/datum/component/shield, SHIELD_PARENT_INTEGRITY, shield_cover = list(MELEE = 40, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 40, BIO = 15, FIRE = 30, ACID = 35))

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags_atom = CONDUCT|NOBLOODY
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("shoved", "bashed")
	var/on_force = 10

/obj/item/weapon/shield/energy/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)

/obj/item/weapon/shield/energy/set_shield()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING)

/obj/item/weapon/shield/energy/attack_self(mob/living/user)
	toggle_active()
	icon_state = "eshield[active]"
	if(active)
		force = on_force
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 25, TRUE)
		to_chat(user, span_notice("[src] is now active."))
	else
		force = initial(force)
		w_class = WEIGHT_CLASS_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', 25, TRUE)
		to_chat(user, span_notice("[src] can now be concealed."))
	add_fingerprint(user, "turned [active ? "on" : "off"]")

