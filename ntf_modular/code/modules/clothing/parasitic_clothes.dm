/obj/item/clothing/suit/resin_bodysuit
	name = "living resin bodysuit"
	desc = "Living mass of tentacles pretty much, yuck."
	//get actual sprites.
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'
	worn_icon_list = list(
		slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_wear_suit_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_underwear_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi'
		)
	icon_state = "sneak_leotard"
	color = COLOR_PURPLE
	equip_slot_flags = ITEM_SLOT_UNDERWEAR|ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING

/obj/item/clothing/suit/resin_bodysuit/equipped(mob/user, slot)
	. = ..()
	if(!(slot &= SLOT_L_HAND) || !(slot &= SLOT_R_HAND))
		user.visible_message(span_warning("[src] attaches itself to [user]!"),
				span_warning("[src] attaches itself to you!"),
				span_notice("You hear rustling."))
		ADD_TRAIT(src, TRAIT_NODROP, "parasite_trait")

/obj/item/clothing/suit/resin_bodysuit/unequipped(mob/unequipper, slot)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, "parasite_trait")

/* not meant to fuck apparently
/obj/item/clothing/suit/resin_bodysuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parasitic_clothing)

/obj/item/clothing/suit/resin_bodysuit/Destroy()
	. = ..()
	remove_component(/datum/component/parasitic_clothing)
*/

/obj/item/storage/backpack/marine/resin_sack
	name = "living resin sack"
	desc = "A mass of resin and tentacles stuck to your back, weighting down a bit."
	//get actual sprites.
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'
	worn_icon_list = list(
		slot_back_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		)
	icon_state = "sneak_leotard"
	slowdown = 0.1
	actions_types = list(/datum/action/ability/activable/sack_lay_egg)
	var/evolve_timer

//special egglay
/datum/action/ability/activable/sack_lay_egg
	name = "Lay Pod Egg"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	action_icon_state = "lay_egg"
	desc = "Eject a hugger egg from your pod, even off resin thanks to your stored body fluids."
	ability_cost = 20
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LAY_EGG,
	)
	cooldown_duration = 3 MINUTES

/datum/action/ability/activable/sack_lay_egg/action_activate()
	. = ..()
	var/turf/current_turf = get_turf(owner)

	if(!current_turf.check_alien_construction(owner, planned_building = /obj/alien/egg/hugger))
		return fail_activate()

	owner.visible_message(span_xenonotice("[owner] starts planting an egg."), \
		span_xenonotice("You start planting an egg."), null, 5)

	if(!do_after(owner, 2.5 SECONDS, NONE, current_turf, BUSY_ICON_BUILD, extra_checks = CALLBACK(current_turf, TYPE_PROC_REF(/turf, check_alien_construction), owner)))
		return fail_activate()

	var/datum/component/parasitic_clothing/paracomp = GetComponent(/datum/component/parasitic_clothing)
	new /obj/alien/egg/hugger(current_turf, paracomp.hivenumber)

	playsound(current_turf, 'sound/effects/splat.ogg', 15, 1)

	succeed_activate()
	add_cooldown()
	owner.record_traps_created()

/datum/action/ability/activable/sack_lay_egg/New()
	. = ..()

	update_button_icon()

/datum/action/ability/activable/sack_lay_egg/action_activate()
	. = ..()
	if(!.)
		return
	update_button_icon()

/obj/item/storage/backpack/marine/resin_sack/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parasitic_clothing)

/obj/item/storage/backpack/marine/resin_sack/Destroy()
	. = ..()
	remove_component(/datum/component/parasitic_clothing)

/obj/item/storage/backpack/marine/resin_sack/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_BACK)
		deltimer(evolve_timer)
		evolve_timer = addtimer(CALLBACK(src ,PROC_REF(try_evolve), user), 3 MINUTES, TIMER_STOPPABLE)

/obj/item/storage/backpack/marine/resin_sack/proc/try_evolve(mob/living/carbon/human/victim)
	if(!victim)
		return
	if(istype(victim.w_underwear, /obj/item/clothing/suit/resin_bodysuit))
		return
	if(victim.w_underwear)
		victim.dropItemToGround(victim.w_underwear)
	var/datum/component/parasitic_clothing/ownparacomp = GetComponent(/datum/component/parasitic_clothing)
	var/obj/item/clothing/suit/resin_bodysuit/goobersuit = new /obj/item/clothing/suit/resin_bodysuit(loc)
	var/datum/component/parasitic_clothing/paracomp = goobersuit.GetComponent(/datum/component/parasitic_clothing)
	paracomp.hivenumber = ownparacomp.hivenumber
	victim.visible_message(span_warning("[src] evolves and wraps itself around [victim]!"),
			span_warning("[src] evolves and wraps itself around your body!"),
			span_notice("You hear rustling."))
	victim.equip_to_slot(goobersuit, ITEM_SLOT_UNDERWEAR)

/obj/item/storage/backpack/marine/resin_sack/unequipped(mob/unequipper, slot)
	. = ..()
	deltimer(evolve_timer)
