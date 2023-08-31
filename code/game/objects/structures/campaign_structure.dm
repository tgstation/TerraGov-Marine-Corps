/obj/structure/campaign
	name = "GENERIC CAMPAIGN STRUCTURE"
	desc = "THIS SHOULDN'T BE VISIBLE"
	density = TRUE
	anchored = TRUE
	allow_pass_flags = PASSABLE
	//resistance_flags = RESIST_ALL
	destroy_sound = 'sound/effects/meteorimpact.ogg'

	icon = 'icons/obj/structures/structures.dmi'


/obj/structure/campaign/destruction_objective
	name = "GENERIC CAMPAIGN DESTRUCTION OBJECTIVE"
	soft_armor = list(MELEE = 200, BULLET = 200, LASER = 200, ENERGY = 200, BOMB = 200, BIO = 200, FIRE = 200, ACID = 200)

/obj/structure/campaign/destruction_objective/Initialize(mapload)
	. = ..()
	GLOB.campaign_destroy_objectives += src

/obj/structure/campaign/destruction_objective/Destroy()
	disable()
	return ..()

///Handles the objective being destroyed, disabled or otherwise completed
/obj/structure/campaign/destruction_objective/proc/disable()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED, src)
	GLOB.campaign_destroy_objectives -= src

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
