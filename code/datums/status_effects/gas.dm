/datum/status_effect/freon
	id = "frozen"
	duration = 100
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/freon
	var/icon/cube
	var/can_melt = TRUE

/obj/screen/alert/status_effect/freon
	name = "Frozen Solid"
	desc = ""
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(owner_resist))
	if(!owner.stat)
		to_chat(owner, "<span class='danger'>I become frozen in a cube!</span>")
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.add_overlay(cube)
	owner.update_mobility()
	return ..()

/datum/status_effect/freon/tick()
	owner.update_mobility()
	if(can_melt && owner.bodytemperature >= BODYTEMP_NORMAL)
		qdel(src)

/datum/status_effect/freon/proc/owner_resist()
	to_chat(owner, "<span class='notice'>I start breaking out of the ice cube...</span>")
	if(do_mob(owner, owner, 40))
		if(!QDELETED(src))
			to_chat(owner, "<span class='notice'>I break out of the ice cube!</span>")
			owner.remove_status_effect(/datum/status_effect/freon)
			owner.update_mobility()

/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		to_chat(owner, "<span class='notice'>The cube melts!</span>")
	owner.cut_overlay(cube)
	owner.adjust_bodytemperature(100)
	owner.update_mobility()
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)

/datum/status_effect/freon/watcher
	duration = 8
	can_melt = FALSE
