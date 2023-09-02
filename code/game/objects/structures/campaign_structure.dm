/obj/structure/campaign
	name = "GENERIC CAMPAIGN STRUCTURE"
	desc = "THIS SHOULDN'T BE VISIBLE"
	density = TRUE
	anchored = TRUE
	allow_pass_flags = PASSABLE
	//resistance_flags = RESIST_ALL
	destroy_sound = 'sound/effects/meteorimpact.ogg'

	icon = 'icons/obj/structures/campaign_structures.dmi'


/obj/structure/campaign/destruction_objective
	name = "GENERIC CAMPAIGN DESTRUCTION OBJECTIVE"
	soft_armor = list(MELEE = 200, BULLET = 200, LASER = 200, ENERGY = 200, BOMB = 200, BIO = 200, FIRE = 200, ACID = 200)

/obj/structure/campaign/destruction_objective/Initialize(mapload)
	. = ..()
	GLOB.campaign_objectives += src

/obj/structure/campaign/destruction_objective/Destroy()
	disable()
	return ..()

///Handles the objective being destroyed, disabled or otherwise completed
/obj/structure/campaign/destruction_objective/proc/disable()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED, src)
	GLOB.campaign_objectives -= src

/obj/structure/campaign/destruction_objective/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	pixel_x = -16

#define BLUESPACE_CORE_OK "bluespace_core_ok"
#define BLUESPACE_CORE_UNSTABLE "bluespace_core_unstable"
#define BLUESPACE_CORE_BROKEN "bluespace_core_broken"

/obj/structure/campaign/destruction_objective/bluespace_core
	name = "\improper Bluespace Teleportation Displacement Core"
	desc = "An incredibly sophisticated piece of bluespace technology that is the engine behind any number of quantum entangled bluespace teleporter devices in the system."
	icon = 'icons/obj/machines/bluespacedrive.dmi'
	icon_state = "bsd_core"
	bound_height = 64
	bound_width = 64
	pixel_y = -18
	pixel_x = -16
	var/status = BLUESPACE_CORE_OK

/obj/structure/campaign/destruction_objective/bluespace_core/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/campaign/destruction_objective/bluespace_core/update_icon_state()
	. = ..()
	if(status == BLUESPACE_CORE_BROKEN)
		icon_state = "bsd_core_broken"
	else
		icon_state = "bsd_core"

/obj/structure/campaign/destruction_objective/bluespace_core/update_overlays()
	. = ..()
	switch(status)
		if(BLUESPACE_CORE_OK)
			. += image(icon, icon_state = "top_overlay", layer = ABOVE_MOB_LAYER)
			. += image(icon, icon_state = "bsd_c_s", layer = TANK_BARREL_LAYER)
		if(BLUESPACE_CORE_UNSTABLE)
			. += image(icon, icon_state = "top_overlay", layer = ABOVE_MOB_LAYER)
			. += image(icon, icon_state = "bsd_c_u", layer = TANK_BARREL_LAYER)
		if(BLUESPACE_CORE_BROKEN)
			. += image(icon, icon_state = "top_overlay_broken", layer = ABOVE_MOB_LAYER)

///Changes the status of the object
/obj/structure/campaign/destruction_objective/bluespace_core/proc/change_status(new_status)
	if(status == new_status)
		return
	status = new_status
	update_icon()
	if(status == BLUESPACE_CORE_BROKEN)
		disable()

/obj/structure/campaign/fulton_objective
	name = "phoron crate"
	desc = "A crate packed full of valuable phoron, ready to claim."
	icon_state = "orebox_phoron"
	resistance_flags = RESIST_ALL
	var/fulton_status = FALSE
	///Reference to the balloon vis obj effect
	var/atom/movable/vis_obj/fulton_balloon/balloon
	///Vis copy of the object when it is fultoned
	var/obj/effect/fulton_extraction_holder/holder_obj

/obj/structure/campaign/fulton_objective/Initialize(mapload)
	. = ..()
	GLOB.campaign_objectives += src
	balloon = new()
	holder_obj = new()


/obj/structure/campaign/fulton_objective/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(user.stat)
		return
	if(user.do_actions)
		user.balloon_alert(user, "You are already doing something!")
		return
	extract(user)

///Starts the fulton process
/obj/structure/campaign/fulton_objective/proc/extract(mob/living/user)
	user.visible_message(span_notice("[user] starts activating a fulton on [src]."),\
	span_notice("You start activating a fulton on [src]..."), null, 5)
	if(!do_after(user, 5 SECONDS, TRUE, src))
		return
	if(fulton_status)
		balloon_alert(user, "Already extracting!")
	if(!isturf(src.loc))
		balloon_alert(user, "Must extract on the ground")
		return

	do_extract(user)
	user.visible_message(span_notice("[user] finishes attaching the fulton to [src] and activates it."),\
	span_notice("You attach a fulton to [src] and activate it."), null, 5)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_FULTON_OBJECTIVE_EXTRACTED, src, user)
	qdel(src)

///Fultons the object
/obj/structure/campaign/fulton_objective/proc/do_extract(mob/user)
	fulton_status = TRUE
	holder_obj.appearance = appearance
	holder_obj.forceMove(loc)
	if(anchored)
		anchored = FALSE
	moveToNullspace()
	balloon.icon_state = initial(balloon.icon_state)
	holder_obj.vis_contents += balloon

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(holder_obj), 'sound/items/fultext_deploy.ogg', 50, TRUE), 0.4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(holder_obj), 'sound/items/fultext_launch.ogg', 50, TRUE), 7.4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(cleanup_extraction)), 8 SECONDS)

	flick("fulton_expand", balloon)
	balloon.icon_state = "fulton_balloon"
	animate(holder_obj, pixel_z = 0, time = 0.4 SECONDS)
	animate(pixel_z = 10, time = 2 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = SCREEN_PIXEL_SIZE, time = 1 SECONDS)

///Cleans up after fulton is complete
/obj/structure/campaign/fulton_objective/proc/cleanup_extraction()
	holder_obj.moveToNullspace()
	holder_obj.pixel_z = initial(pixel_z)
	holder_obj.vis_contents -= balloon
	balloon.icon_state = initial(balloon.icon_state)
	fulton_status = FALSE
