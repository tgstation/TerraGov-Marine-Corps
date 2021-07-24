/obj/machinery/deployable
	///Item that is deployed to create src.
	var/obj/item/internal_item
	///Since /obj/machinery/deployable aquires its sprites from an item and are set in New(), initial(icon_state) would return null. This var exists as a substitute.
	var/default_icon_state

	hud_possible = list(MACHINE_HEALTH_HUD)

/obj/machinery/deployable/Initialize(mapload, _internal_item)
	. = ..()
	internal_item = _internal_item

	name = internal_item.name
	desc = internal_item.desc

	icon = initial(internal_item.icon)
	default_icon_state = initial(internal_item.icon_state) + "_deployed"
	icon_state = default_icon_state

	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)

	update_icon_state()

/obj/machinery/deployable/update_icon_state()
	. = ..()
	hud_set_machine_health()

///Repairs machine
/obj/machinery/deployable/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE

	var/obj/item/tool/weldingtool/WT = I

	if(!WT.isOn())
		return FALSE

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return TRUE

	if(obj_integrity == max_integrity)
		to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
		return TRUE
	
	if(!WT.remove_fuel(2, user))
		to_chat(user, "<span class='warning'>Not enough fuel to finish the task.</span>")
		return TRUE

	var/weld_time = 5 SECONDS

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
		"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
		weld_time  *= ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )

	user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
	"<span class='notice'>You begin repairing the damage to [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, weld_time, TRUE, src, BUSY_ICON_FRIENDLY))
		return TRUE

	if(!WT.remove_fuel(2, user))
		to_chat(user, "<span class='warning'>Not enough fuel to finish the task.</span>")
		return TRUE

	user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
	"<span class='notice'>You repair [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	repair_damage(120)
	update_icon_state()
	return TRUE

///Dissassembles the device
/obj/machinery/deployable/proc/disassemble(mob/user)
	var/obj/item/item = internal_item
	if(CHECK_BITFIELD(item.flags_item, DEPLOYED_NO_PICKUP))
		to_chat(user, "<span class='notice'>The [src] is anchored in place and cannot be disassembled.</span>")
		return
	SEND_SIGNAL(src, COMSIG_ITEM_UNDEPLOY, user)

/obj/machinery/deployable/Destroy()
	if(internal_item)
		QDEL_NULL(internal_item)
	operator?.unset_interaction()
	return ..()

/obj/machinery/deployable/examine(mob/user)
	. = ..()
	internal_item.examine(user)

/obj/machinery/deployable/MouseDrop(over_object, src_location, over_location) 
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(over_object != user || !in_range(src, user))
		return
	if(CHECK_BITFIELD(internal_item.flags_item, DEPLOYED_WRENCH_DISASSEMBLE))
		to_chat(user, "<span class = 'notice'>You cannot disassemble [src] without a wrench.</span>")
		return
	disassemble(user)

/obj/machinery/deployable/wrench_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(internal_item.flags_item, DEPLOYED_WRENCH_DISASSEMBLE))
		return ..()
	disassemble(user)
