
/obj/structure/periscope
	name = "tank periscope"
	desc = "A periscope for viewing the outside of the vehicle. Resist or move to stop looking through it."
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "periscope"
	density = FALSE
	resistance_flags = RESIST_ALL
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner

/obj/structure/periscope/Destroy()
	owner = null
	return ..()

/obj/structure/periscope/link_interior(datum/interior/link)
	owner = link.container

/obj/structure/periscope/attack_hand(mob/living/user)
	. = ..()
	user.reset_perspective(owner)
	ADD_TRAIT(user, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	user.update_sight()
	user.client.view_size.set_view_radius_to(4.5)
	RegisterSignals(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DO_RESIST, COMSIG_MOB_LOGOUT), PROC_REF(stop_looking))

///signal handler for canceling the looking
/obj/structure/periscope/proc/stop_looking(mob/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DO_RESIST, COMSIG_MOB_LOGOUT))
	source.reset_perspective()
	REMOVE_TRAIT(source, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	source.client.view_size.reset_to_default()
	source.update_sight()

/obj/structure/periscope/apc
	name = "apc periscope"

/obj/structure/periscope/som
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "periscope"
	layer = ABOVE_LYING_MOB_LAYER
	pixel_x = -5

/obj/structure/periscope/som/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/periscope/som/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive")
