/obj/item/weapon/twohanded
	var/force_wielded = 0
	var/wieldsound
	var/unwieldsound
	flags_item = TWOHANDED

/obj/item/weapon/twohanded/update_icon()
	return


/obj/item/weapon/twohanded/mob_can_equip(mob/user)
	unwield(user)
	return ..()


/obj/item/weapon/twohanded/dropped(mob/user)
	. = ..()
	unwield(user)


/obj/item/weapon/twohanded/pickup(mob/user)
	unwield(user)


/obj/item/proc/wield(mob/user)
	if(!(flags_item & TWOHANDED) || flags_item & WIELDED)
		return FALSE

	var/obj/item/offhand = user.get_inactive_held_item()
	if(offhand)
		if(offhand == user.r_hand)
			user.drop_r_hand()
		else if(offhand == user.l_hand)
			user.drop_l_hand()
		if(user.get_inactive_held_item()) //Failsafe; if there's somehow still something in the off-hand (undroppable), bail.
			to_chat(user, span_warning("You need your other hand to be empty!"))
			return FALSE

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/datum/limb/hand = wielder.get_limb(check_hand)
		if(!istype(hand) || !hand.is_usable())
			to_chat(user, span_warning("Your other hand can't hold [src]!"))
			return FALSE

	toggle_wielded(user, TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_WIELD, user)
	name = "[name] (Wielded)"
	update_item_state()
	place_offhand(user, name)
	return TRUE


/obj/item/proc/unwield(mob/user)
	if(!CHECK_MULTIPLE_BITFIELDS(flags_item, TWOHANDED|WIELDED))
		return FALSE

	toggle_wielded(user, FALSE)
	SEND_SIGNAL(src, COMSIG_ITEM_UNWIELD, user)
	var/sf = findtext(name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		name = copytext(name, 1, sf)
	else
		name = "[initial(name)]"
	update_item_state()
	remove_offhand(user)
	return TRUE


/obj/item/proc/place_offhand(mob/user, item_name)
	to_chat(user, span_notice("You grab [item_name] with both hands."))
	var/obj/item/weapon/twohanded/offhand/offhand = new /obj/item/weapon/twohanded/offhand(user)
	offhand.name = "[item_name] - offhand"
	offhand.desc = "Your second grip on the [item_name]."
	user.put_in_inactive_hand(offhand)
	user.update_inv_l_hand()
	user.update_inv_r_hand()


/obj/item/proc/remove_offhand(mob/user)
	to_chat(user, span_notice("You are now carrying [name] with one hand."))
	var/obj/item/weapon/twohanded/offhand/offhand = user.get_inactive_held_item()
	if(istype(offhand) && !QDELETED(offhand))
		qdel(offhand)
	user.update_inv_l_hand()
	user.update_inv_r_hand()


/obj/item/proc/toggle_wielded(user, new_value)
	switch(new_value)
		if(null)
			flags_item ^= WIELDED
		if(FALSE)
			flags_item &= ~WIELDED
		if(TRUE)
			flags_item |= WIELDED


/obj/item/weapon/twohanded/wield(mob/user)
	. = ..()
	if(!.)
		return

	if(wieldsound)
		playsound(user, wieldsound, 15, 1)

	force = force_wielded


/obj/item/weapon/twohanded/unwield(mob/user)
	. = ..()
	if(!.)
		return

	if(unwieldsound)
		playsound(user, unwieldsound, 15, 1)

	force = initial(force)


/obj/item/weapon/twohanded/attack_self(mob/user)
	. = ..()
	if(ismonkey(user)) //TODO MAKE THIS A SPECIES FLAG
		to_chat(user, span_warning("It's too heavy for you to wield fully!"))
		return

	if(flags_item & WIELDED)
		unwield(user)
	else
		wield(user)


///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = WEIGHT_CLASS_HUGE
	icon_state = "offhand"
	name = "offhand"
	flags_item = DELONDROP|TWOHANDED|WIELDED
	resistance_flags = RESIST_ALL


/obj/item/weapon/twohanded/offhand/Destroy()
	if(ismob(loc))
		var/mob/user = loc
		var/obj/item/main_hand = user.get_active_held_item()
		if(main_hand)
			main_hand.unwield(user)
	return ..()


/obj/item/weapon/twohanded/offhand/unwield(mob/user)
	return


/obj/item/weapon/twohanded/offhand/dropped(mob/user)
	return


/obj/item/weapon/twohanded/offhand/forceMove(atom/destination)
	if(!ismob(destination))
		qdel(src)
	return ..()



/*
* Fireaxe
*/
/obj/item/weapon/twohanded/fireaxe
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	icon_state = "fireaxe"
	item_state = "fireaxe"
	force = 20
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	flags_atom = CONDUCT
	flags_item = TWOHANDED
	force_wielded = 75
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")


/obj/item/weapon/twohanded/fireaxe/wield(mob/user)
	. = ..()
	if(!.)
		return
	pry_capable = IS_PRY_CAPABLE_SIMPLE


/obj/item/weapon/twohanded/fireaxe/unwield(mob/user)
	. = ..()
	if(!.)
		return
	pry_capable = 0


/*
* Double-Bladed Energy Swords - Cheridan
*/
/obj/item/weapon/twohanded/dualsaber
	name = "double-bladed energy sword"
	desc = "Handle with care."
	icon_state = "dualsaber"
	item_state = "dualsaber"
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	force_wielded = 150
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	flags_atom = NOBLOODY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1


/obj/item/weapon/twohanded/dualsaber/Initialize()
	. = ..()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING)

/obj/item/weapon/twohanded/dualsaber/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(TRUE)

/obj/item/weapon/twohanded/dualsaber/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(FALSE)


/obj/item/weapon/twohanded/spear
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	icon_state = "spearglass"
	item_state = "spearglass"
	force = 40
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	force_wielded = 75
	throwforce = 75
	throw_speed = 3
	reach = 2
	edge = 1
	sharp = IS_SHARP_ITEM_SIMPLE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "stabbed", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/spear/tactical
	name = "M-23 spear"
	desc = "A tactical spear. Used for 'tactical' combat."
	icon_state = "spear"
	item_state = "spear"

/obj/item/weapon/twohanded/spear/tactical/harvester
	name = "\improper HP-S Harvester spear"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' spear. An advanced weapon that has the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "vali_spear"
	item_state = "vali_spear"
	force = 32
	force_wielded = 60
	throwforce = 60
	flags_item = TWOHANDED | DRAINS_XENO

	var/obj/item/reagent_containers/glass/beaker/vial/beaker = null
	var/datum/reagent/loaded_reagent = null
	var/list/loadable_reagents = list(
		/datum/reagent/medicine/bicaridine,
		/datum/reagent/medicine/tramadol,
		/datum/reagent/medicine/kelotane,
	)

	var/codex_info = {"<b>Reagent info:</b><BR>
	Bicaridine - heal your target for 10 brute. Usable on both dead and living targets.<BR>
	Kelotane - produce a cone of flames<BR>
	Tramadol - slow your target for 2 seconds<BR>
	<BR>
	<b>Tips:</b><BR>
	> Needs to be connected to the Vali system to collect green blood. You can connect it though the Vali system's configurations menu.<BR>
	> Filled by liquid reagent containers. Emptied by using an empty liquid reagent container.<BR>
	> Toggle unique action (SPACE by default) to load a single-use of the reagent effect after the blade has been filled up."}

/obj/item/weapon/twohanded/spear/tactical/harvester/examine(mob/user)
	. = ..()
	to_chat(user, span_rose("[length(beaker.reagents.reagent_list) ? "It currently holds [beaker.reagents.total_volume]u of [beaker.reagents.reagent_list[1].name]" : "The internal storage is empty"].\n<b>Compatible chemicals:</b>"))
	for(var/R in loadable_reagents)
		var/atom/L = R
		to_chat(user, "[initial(L.name)]")

/obj/item/weapon/twohanded/spear/tactical/harvester/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

/obj/item/weapon/twohanded/spear/tactical/harvester/Initialize()
	. = .. ()
	beaker = new /obj/item/reagent_containers/glass/beaker/vial

/obj/item/weapon/twohanded/spear/tactical/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/spear/tactical/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/twohanded/spear/tactical/harvester/attackby(obj/item/I, mob/user)
	if(user.do_actions)
		return TRUE

	if(!isreagentcontainer(I) || istype(I, /obj/item/reagent_containers/pill))
		to_chat(user, span_rose("[I] isn't compatible with [src]."))
		return TRUE

	var/trans
	var/obj/item/reagent_containers/container = I

	if(!container.reagents.total_volume)
		trans = beaker.reagents.trans_to(container, 30)
		to_chat(user, span_rose("[trans ? "You take [trans]u out of the internal storage. It now contains [beaker.reagents.total_volume]u" : "[src]'s storage is empty."]."))
		return TRUE

	if(length(container.reagents.reagent_list) > 1)
		to_chat(user, span_rose("The solution needs to be uniform and contain only a single type of reagent to be compatible."))
		return TRUE

	if(beaker.reagents.total_volume && (container.reagents.reagent_list[1].type != beaker.reagents.reagent_list[1].type))
		to_chat(user, span_rose("[src]'s internal storage can contain only one kind of solution at the same time. It currently contains <b>[beaker.reagents.reagent_list[1].name]</b>"))
		return TRUE

	if(!locate(container.reagents.reagent_list[1].type) in loadable_reagents)
		to_chat(user, span_rose("This reagent is not compatible with the weapon's mechanism. Check the engraved symbols for further information."))
		return TRUE

	if(container.reagents.total_volume < 5)
		to_chat(user, span_rose("At least 5u of the substance is needed."))
		return TRUE

	if(beaker.reagents.total_volume >= 30)
		to_chat(user, span_rose("The internal storage is full."))
		return TRUE

	to_chat(user, span_notice("You begin filling up the [src] with [container.reagents.reagent_list[1]]."))
	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BAR, null, PROGRESS_BRASS))
		return TRUE

	trans = container.reagents.trans_to(beaker, container.amount_per_transfer_from_this)
	to_chat(user, span_rose("You load [trans]u into the internal system. It now holds [beaker.reagents.total_volume]u."))
	return TRUE

/obj/item/weapon/twohanded/spear/tactical/harvester/unique_action(mob/user)
	. = ..()
	if(loaded_reagent)
		to_chat(user, span_rose("The blade is powered with [loaded_reagent.name]. You can release the effect by stabbing a creature."))
		return FALSE

	if(beaker.reagents.total_volume < 5)
		to_chat(user, span_rose("You don't have enough substance."))
		return FALSE

	if(user.do_actions)
		return FALSE

	to_chat(user, span_rose("You start filling up the small chambers along the blade's edge."))
	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_BAR, ignore_turf_checks = TRUE))
		to_chat(user, span_rose("Due to the sudden movement, the safety machanism drains out the reagent back into the main storage."))
		return FALSE

	loaded_reagent = beaker.reagents.reagent_list[1]
	beaker.reagents.remove_any(5)
	return TRUE

/obj/item/weapon/twohanded/spear/tactical/harvester/attack(mob/living/M, mob/living/user)
	if(!loaded_reagent)
		return ..()

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return FALSE

	switch(loaded_reagent.type)
		if(/datum/reagent/medicine/tramadol)
			M.apply_damage(force*0.6, BRUTE, user.zone_selected)
			M.apply_status_effect(/datum/status_effect/incapacitating/harvester_slowdown, 1 SECONDS)

		if(/datum/reagent/medicine/kelotane)
			var/list/cone_turfs = generate_cone(user, 2, 1, 91, Get_Angle(user, M.loc))
			for(var/X in cone_turfs)
				var/turf/T = X
				for(var/mob/living/victim in T)
					victim.flamer_fire_act(10)
					victim.apply_damage(max(0, 20 - 20*victim.hard_armor.getRating("fire")), BURN, user.zone_selected, victim.get_soft_armor("fire", user.zone_selected))
					//TODO BRAVEMOLE

		if(/datum/reagent/medicine/bicaridine)
			if(isxeno(M))
				return ..()
			to_chat(user, span_rose("You prepare to stab <b>[M != user ? "[M]" : "yourself"]</b>!"))
			new /obj/effect/temp_visual/telekinesis(get_turf(M))
			if((M != user) && do_after(user, 2 SECONDS, TRUE, M, BUSY_ICON_DANGER))
				M.heal_overall_damage(12.5, 0, TRUE)
			else
				M.adjustStaminaLoss(-30)
				M.heal_overall_damage(6, 0, TRUE)
			loaded_reagent = null
			return FALSE

	loaded_reagent = null
	return ..()

/obj/item/weapon/twohanded/spear/tactical/tacticool
	name = "M-23 TACTICOOL spear"
	icon = 'icons/Marine/gun64.dmi'
	desc = "A TACTICOOL spear. Used for TACTICOOLNESS in combat."

/obj/item/weapon/twohanded/spear/tactical/tacticool/Initialize()
	. = ..()
	AddComponent(/datum/component/attachment_handler, \
	list(ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_UNDER, ATTACHMENT_SLOT_MUZZLE), \
	list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/stock/t12stock,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/angledgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	), \
	attachment_offsets = list("muzzle_x" = 59, "muzzle_y" = 16, "rail_x" = 26, "rail_y" = 18, "under_x" = 40, "under_y" = 12))

/obj/item/weapon/twohanded/glaive
	name = "war glaive"
	icon_state = "glaive"
	item_state = "glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 28
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	force_wielded = 90
	throwforce = 65
	throw_speed = 3
	edge = 1
	sharp = IS_SHARP_ITEM_BIG
	flags_atom = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	resistance_flags = UNACIDABLE
	attack_speed = 12 //Default is 7.


/obj/item/weapon/twohanded/glaive/damaged
	name = "war glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon. This one is ancient and has suffered serious acid damage, making it near-useless."
	force = 18
	force_wielded = 28
