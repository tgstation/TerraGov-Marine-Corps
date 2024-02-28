
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
	RegisterSignals(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DO_RESIST), PROC_REF(stop_looking))

///signal handler for canceling the looking
/obj/structure/periscope/proc/stop_looking(mob/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DO_RESIST))
	source.reset_perspective()
