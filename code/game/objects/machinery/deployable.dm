/obj/machinery/deployable
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	hud_possible = list(MACHINE_HEALTH_HUD)
	obj_flags = CAN_BE_HIT
	flags_pass = PASSAIR
	///Since /obj/machinery/deployable aquires its sprites from an item and are set in New(), initial(icon_state) would return null. This var exists as a substitute.
	var/default_icon_state
	///Item that is deployed to create src.
	var/obj/item/internal_item

/obj/machinery/deployable/Initialize(mapload, _internal_item, deployer)
	. = ..()
	internal_item = _internal_item

	name = internal_item.name
	desc = internal_item.desc

	icon = initial(internal_item.icon)
	default_icon_state = initial(internal_item.icon_state) + "_deployed"
	icon_state = default_icon_state

	soft_armor = internal_item.soft_armor
	hard_armor = internal_item.hard_armor

	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)

	update_icon()

/obj/machinery/deployable/Destroy()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.remove_from_hud(src)
	return ..()

/obj/machinery/deployable/get_internal_item()
	return internal_item

/obj/machinery/deployable/clear_internal_item()
	internal_item = null

/obj/machinery/deployable/update_icon()
	. = ..()
	hud_set_machine_health()

///Repairs machine
/obj/machinery/deployable/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 120, 5 SECONDS)

///Dissassembles the device
/obj/machinery/deployable/proc/disassemble(mob/user)
	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return
	var/obj/item/item = internal_item
	if(CHECK_BITFIELD(item.flags_item, DEPLOYED_NO_PICKUP))
		to_chat(user, span_notice("The [src] is anchored in place and cannot be disassembled."))
		return
	operator?.unset_interaction()
	SEND_SIGNAL(src, COMSIG_ITEM_UNDEPLOY, user)

/obj/machinery/deployable/Destroy()
	if(internal_item)
		QDEL_NULL(internal_item)
	operator?.unset_interaction()
	return ..()

/obj/machinery/deployable/examine(mob/user)
	. = ..()
	. += internal_item.examine(user)

/obj/machinery/deployable/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(over_object != user || !in_range(src, user))
		return
	if(CHECK_BITFIELD(internal_item.flags_item, DEPLOYED_WRENCH_DISASSEMBLE))
		to_chat(user, span_notice("You cannot disassemble [src] without a wrench."))
		return
	disassemble(user)

/obj/machinery/deployable/wrench_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(internal_item.flags_item, DEPLOYED_WRENCH_DISASSEMBLE))
		return ..()
	disassemble(user)

/obj/machinery/deployable/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	if(soft_armor.getRating(BOMB) >= 100)
		return FALSE
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(200, damage_flag = BOMB, effects = TRUE)
		if(EXPLODE_LIGHT)
			take_damage(100, damage_flag = BOMB, effects = TRUE)
