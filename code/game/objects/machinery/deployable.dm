/obj/machinery/deployable
	///Item that is deployed to create src
	var/obj/item/internal_item
	///Flags for machine functions
	var/deploy_flags = NONE

	var/default_icon_state

	hud_possible = list(MACHINE_HEALTH_HUD)

	var/map_based = FALSE

/obj/machinery/deployable/Initialize(mapload, new_item)
	. = ..()
	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)


/obj/machinery/deployable/proc/create_stats(_internal_item, _deploy_flags)
	internal_item = _internal_item
	deploy_flags = _deploy_flags

	max_integrity = internal_item.max_integrity
	obj_integrity = max_integrity

	name = internal_item.name
	desc = internal_item.desc

	icon = internal_item.icon
	default_icon_state = internal_item.icon_state + "_deployed"
	icon_state = default_icon_state
	update_icon_state()

/obj/machinery/deployable/update_icon_state()
	. = ..()
	hud_set_machine_health()

///Bypasses the depoyable_item component in order to deploy the device without need for user
/obj/machinery/deployable/proc/deploy(obj/item/deploying, direction)
	deploying.forceMove(src)
	setDir(direction)
	SEND_SIGNAL(deploying, COMSIG_DEPLOYABLE_SET_DEPLOYED, TRUE)

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

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
		"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
	"<span class='notice'>You begin repairing the damage to [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
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
/obj/machinery/deployable/proc/disassemble(mob/user, using_wrench)
	if(deploy_flags & DEPLOYED_NO_PICKUP)
		to_chat(user, "<span class='notice'>The [src] is anchored in place and cannot be disassembled.</span>")
		return
	SEND_SIGNAL(src, COMSIG_ITEM_UNDEPLOY, user, using_wrench)

/obj/machinery/deployable/Destroy()
	if(internal_item)
		QDEL_NULL(internal_item)
	operator?.unset_interaction()
	. = ..()

/obj/machinery/deployable/examine(mob/user)
	. = ..()
	internal_item.examine(user)

/obj/machinery/deployable/MouseDrop(over_object, src_location, over_location) 
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr //this is us
	if(over_object == user && in_range(src, user))
		disassemble(user, FALSE)

/obj/machinery/deployable/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	disassemble(user, TRUE)
